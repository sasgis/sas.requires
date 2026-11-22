(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_device_udp_nmea;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
  Winsock2,
  vsagps_winsock2_compat,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_sysutils,
  vsagps_public_device,
  vsagps_tools,
  vsagps_device_base,
  vsagps_parser_nmea,
  vsagps_device_nmea_common,
  vsagps_runtime;

const
  // the size of the sender filter list (";from=ip,ip,...")
  cUDP_AllowedSources_Max = 8;

type
  Tvsagps_device_udp_nmea = class(Tvsagps_device_with_nmea)
  private
    FParser: Tvsagps_parser_nmea;
    FNMEABuffer: array [0..cNmea_Buffer_Size-1] of AnsiChar;
    FGlobalNmeaBuffer: AnsiString;
    FSocket: TSocket; // bound socket (INVALID_SOCKET when not bound)
    // set by InternalClose_Socket: a bind which finished after the close
    // started must not publish its socket (it would leak)
    FSessionClosing: Boolean;
    // serializes all the socket calls (select/recv/closesocket) between the
    // working thread and the close path. A mutex is used instead of a
    // critical section because the OS releases it when the owner is killed
    // by TerminateThread
    FSocketMutex: THandle;
    FWSAData: TWSAData; // WinSock initialization info
    FWSAInitialized: Boolean; // WSAStartup/WSACleanup pairing for this object
    FLastDataTick: DWORD; // GetTickCount of the last received data chunk
    FSavedUTCDateTime: TNMEA_Date_Time;
    // the sender filter (IPv4, network byte order); empty = accept everybody.
    // Filled and read by the working thread only
    FAllowedSources: array [0..cUDP_AllowedSources_Max-1] of DWORD;
    FAllowedSourcesCount: Integer;
  private
    procedure Do_RequestGPSCommand_Apply_UTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
    function InternalWSAStartup(out ALastError: DWORD): Boolean;
    function InternalLock_Socket(const ATimeoutMSec: DWORD): Boolean;
    procedure InternalUnlock_Socket;
    procedure InternalClose_Socket(const ATimeoutMSec: DWORD);
    function Internal_UdpBind(const ADeviceName: AnsiString): Boolean;
    function Internal_ParseSourceFilter(const AList: AnsiString): Boolean;
    procedure InternalSetCommunicationError(const ALastError: DWORD);
  public
    constructor Create; override;
    destructor Destroy; override;

    function SerializePacket(const APacket: Pointer;
                             out ASerializedSize: DWORD;
                             const AReserved: PDWORD): Pointer; override;
    function ParsePacket(const ABuffer: Pointer): DWORD; override;

    function SendPacket(const APacketBuffer: Pointer;
                        const APacketSize: DWORD;
                        const AFlags: DWORD): LongBool; override;
  protected
    procedure InternalResetDeviceConnectionParams; override;
    procedure Internal_Before_Open_Device; override;
    procedure Internal_Before_Close_Device; override;
    // start session - operations to establish connection
    function WorkingThread_StartSession: Boolean; override;
    // send query packet to gps - nothing is ever sent over udp
    function WorkingThread_SendPacket: Boolean; override;
    // receive packets from device to queue
    function WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean; override;
  end;

implementation

uses
  vsagps_public_memory,
  vsagps_public_debugstring;

const
  // version 2.2 of the WinSock specification
  // (not taken from the winsock unit - the RTL unit does not declare it)
  cUDP_WSA_Version_2_2 = $0202;

  // one select() slice while waiting for the incoming data: the device
  // close is checked between the slices and the close path takes the
  // socket mutex between them
  cUDP_ReceiveWait_Slice_MSec = 100;

  // the idle timeout used when the user has not set btReceiveGPSTimeoutSec
  // (nmea streams are normally about 1 Hz)
  cUDP_IdleTimeout_Default_MSec = 30000;

  // how long a socket call may wait for the mutex: the working thread holds
  // it only inside a select/recv slice (up to cUDP_ReceiveWait_Slice_MSec),
  // so the timeout only covers a mutex owned by a killed thread (the OS
  // releases it then - WAIT_ABANDONED)
  cUDP_Lock_Timeout_MSec = 2000;

  // the close path takes the mutex between the receive slices: a slice plus
  // the drain budget is about 130 ms, so one second is more than enough
  cUDP_Close_Lock_Timeout_MSec = 1000;

  // how long one receive call may spend draining the datagrams which are
  // already queued in the socket: a source which is faster than the parser
  // must not keep the socket backlog (and so the whole track) behind the
  // real time forever. GetTickCount ticks every ~15.6 ms, so the real
  // budget is rounded up to two ticks (about 30 ms)
  cUDP_Drain_Budget_MSec = 20;

  // the hard limit of the datagrams drained by one call: the time budget
  // above normally ends the drain much earlier, this bound covers a socket
  // which is refilled by a loopback source as fast as recv drains it (the
  // socket mutex must be released between the refresh periods in any case)
  cUDP_Drain_Batch_Max = 4096;

  // ERROR_INVALID_PARAMETER from winerror.h (the Windows unit declares it
  // as ERROR_INVALID_PARAMETER, the short name could clash with other units)
  cError_Invalid_Param = 87;

  // WSAEOPNOTSUPP from winerror.h - reported for an IPv6 multicast group
  // (only the IPv4 groups are supported in this version)
  cError_Not_Supported = 10045;

  // IP_ADD_MEMBERSHIP from ws2ipdef.h (the current Windows SDK value).
  // CAUTION: the RTL Winapi.WinSock unit declares IP_ADD_MEMBERSHIP=5 -
  // that value is a legacy of the old winsock1 headers, a real join with
  // the option 5 fails with WSAENOPROTOOPT on current Windows; the RTL
  // Winapi.Winsock2 declares no IP socket options at all. The join was
  // verified against the option 12 (a looped multicast datagram received)
  cIP_Add_Membership = 12;

  // the kernel receive buffer of the socket: the base loop sleeps for the
  // refresh period after every receive batch, and everything the source
  // sends during that pause has to fit (the default buffer is small)
  cUDP_RcvBuf_Size = 512*1024;

  // WSAEMSGSIZE from winerror.h - the datagram is bigger than the buffer
  cUDP_WSAEMSGSIZE = 10040;

  // AF_INET6 and the sockaddr_in6 layout (family, port, flowinfo, 16 bytes of
  // the address, scope id): the RTL type is not required, only the offset of
  // the address is needed to recognize a multicast group (ff00::/8)
  cUDP_AF_INET6 = 23;
  cUDP_SockAddrIn6_AddrOffset = 8;
  cUDP_SockAddrIn6_MinLen = 24;

type
  // ip_mreq from ws2tcpip.h - not declared in the RTL Winsock units
  Tip_mreq = record
    imr_multiaddr: in_addr;
    imr_interface: in_addr;
  end;

{ helpers }

// the time elapsed since AStartTick (GetTickCount value). The 32-bit wrap is
// handled in Int64, so it works with the overflow/range checks turned on
function UDP_ElapsedMSec(const AStartTick: DWORD): DWORD;
begin
  Result:=DWORD((Int64(GetTickCount)-Int64(AStartTick)) and $FFFFFFFF);
end;

function UDP_IsHexChar(const AChar: AnsiChar): Boolean;
begin
  Result:=(AChar in ['0'..'9','A'..'F','a'..'f']);
end;

// ASCII only
function UDP_LowerA(const AStr: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result:=AStr;
  for i:=1 to Length(Result) do begin
    if (Result[i] in ['A'..'Z']) then
      Result[i]:=AnsiChar(Ord(Result[i])+32);
  end;
end;

// the first position of AChar, 0 when there is none
function UDP_FindCharA(const AStr: AnsiString; const AChar: AnsiChar): Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=1 to Length(AStr) do begin
    if (AChar=AStr[i]) then begin
      Result:=i;
      Exit;
    end;
  end;
end;

// the last position of AChar, 0 when there is none
function UDP_FindCharLastA(const AStr: AnsiString; const AChar: AnsiChar): Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=Length(AStr) downto 1 do begin
    if (AChar=AStr[i]) then begin
      Result:=i;
      Exit;
    end;
  end;
end;

// a strict dotted IPv4 address ("a.b.c.d", 4 decimal octets) -> network byte
// order. A typo must not open a sender filter or pick a wrong interface, and
// the WinSock inet_addr is too liberal for that: it accepts short
// ("192.168.1"), octal and hex forms and reports a bad string as the
// broadcast address
function UDP_ParseIPv4(const AStr: AnsiString; out AAddr: DWORD): Boolean;
var
  i, VOctet, VDigits, VValue: Integer;
begin
  AAddr:=0;
  VOctet:=0;
  VDigits:=0;
  VValue:=0;
  for i:=1 to Length(AStr) do begin
    if (AStr[i] in ['0'..'9']) then begin
      Inc(VDigits);
      if (3<VDigits) then begin
        Result:=FALSE;
        Exit;
      end;
      VValue:=VValue*10+Ord(AStr[i])-Ord('0');
      if (255<VValue) then begin
        Result:=FALSE;
        Exit;
      end;
    end else if ('.'=AStr[i]) then begin
      if (0=VDigits) or (3<=VOctet) then begin
        Result:=FALSE;
        Exit;
      end;
      AAddr:=AAddr or (DWORD(VValue) shl (8*VOctet));
      Inc(VOctet);
      VValue:=0;
      VDigits:=0;
    end else begin
      Result:=FALSE;
      Exit;
    end;
  end;
  // exactly 4 octets: three dots and the last octet
  Result:=(3=VOctet) and (0<VDigits);
  if Result then
    AAddr:=AAddr or (DWORD(VValue) shl 24);
end;

// bring the line ends of one datagram to the CRLF form the shared nmea
// framing waits for: a lone LF gets the CR before it, a lone CR gets the LF
// after it, and a sentence which ends with its checksum ("*hh") at the very
// end of the datagram gets the CRLF appended (a datagram without any line end
// would never be parsed). An empty result means that nothing has to be
// changed and the received data can be used as is
function UDP_NormalizeLineEnds(const AData: PAnsiChar; const ASize: Integer): AnsiString;
var
  i, VExtra, VAppend, VPos: Integer;
begin
  Result:='';
  if (ASize<=0) then
    Exit;

  // how many CR/LF are missing around the lone ones
  VExtra:=0;
  for i:=1 to ASize do begin
    if (#10=AData[i-1]) then begin
      if ((1=i) or (#13<>AData[i-2])) then
        Inc(VExtra);
    end else if (#13=AData[i-1]) then begin
      if ((ASize=i) or (#10<>AData[i])) then
        Inc(VExtra);
    end;
  end;

  // the end of the datagram: a complete sentence without any line end
  VAppend:=0;
  if (#13<>AData[ASize-1]) and (#10<>AData[ASize-1]) and (3<=ASize) and
     ('*'=AData[ASize-3]) and
     UDP_IsHexChar(AData[ASize-2]) and
     UDP_IsHexChar(AData[ASize-1]) then
    VAppend:=2;

  if (0=VExtra) and (0=VAppend) then
    Exit;

  SetLength(Result, ASize+VExtra+VAppend);
  VPos:=1;
  for i:=1 to ASize do begin
    if (#10=AData[i-1]) and ((1=i) or (#13<>AData[i-2])) then begin
      Result[VPos]:=#13;
      Inc(VPos);
    end;
    Result[VPos]:=AData[i-1];
    Inc(VPos);
    if (#13=AData[i-1]) and ((ASize=i) or (#10<>AData[i])) then begin
      Result[VPos]:=#10;
      Inc(VPos);
    end;
  end;
  if (2=VAppend) then begin
    Result[VPos]:=#13;
    Result[VPos+1]:=#10;
  end;
end;

{ Tvsagps_device_udp_nmea }

constructor Tvsagps_device_udp_nmea.Create;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Create: begin');
{$ifend}

  // initialize the fields which are used by
  // InternalResetDeviceConnectionParams - the base constructor calls it
  FSocket:=INVALID_SOCKET;
  FSessionClosing:=FALSE;
  FWSAInitialized:=FALSE;
  FLastDataTick:=0;
  FAllowedSourcesCount:=0;
  // the mutex is created before inherited - the base constructor resets the
  // connection params, and that calls InternalClose_Socket
  FSocketMutex:=CreateMutex(nil, FALSE, nil);

  // create the parser before inherited - the base constructor resets
  // connection params which touch the parser
  FParser:=Tvsagps_parser_nmea.Create;

  inherited;

  FParser.FOnApplyUTCDateTime:=Do_RequestGPSCommand_Apply_UTCDateTime;
  FParser.FOnECHOSOUNDER:=FParser_FOnECHOSOUNDER;
  FParser.FOnGGA:=FParser_FOnGGA;
  FParser.FOnGLL:=FParser_FOnGLL;
  FParser.FOnGSA:=FParser_FOnGSA;
  FParser.FOnGSV:=FParser_FOnGSV;
  FParser.FOnRMC:=FParser_FOnRMC;
{$if defined(USE_NMEA_VTG)}
  FParser.FOnVTG:=FParser_FOnVTG;
{$ifend}

  // windows sockets are initialized lazily by the first session start and
  // are kept until the destructor (a failed start is retried by the next one,
  // the error can be temporary)

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Create: end');
{$ifend}
end;

destructor Tvsagps_device_udp_nmea.Destroy;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Destroy: begin');
{$ifend}

  // inherited stops the working thread and closes the device
  inherited;

  FreeAndNil(FParser);

  if FWSAInitialized then begin
    FWSAInitialized:=FALSE;
    WSACleanup;
  end;

  if (0<>FSocketMutex) then begin
    CloseHandle(FSocketMutex);
    FSocketMutex:=0;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Destroy: end');
{$ifend}
end;

procedure Tvsagps_device_udp_nmea.Do_RequestGPSCommand_Apply_UTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
begin
  // the shared implementation works with the same-named fields of the device
  NMEA_Apply_UTCDateTime(FRequestGPSCommand_Apply_UTCDateTime,
                         FSavedUTCDateTime,
                         ADate,
                         ATime);
end;

function Tvsagps_device_udp_nmea.InternalWSAStartup(out ALastError: DWORD): Boolean;
begin
  // the reference counter of the WinSock provider allows any number of
  // nested WSAStartup/WSACleanup pairs
  ALastError:=0;
  Result:=FWSAInitialized;
  if Result then
    Exit;
  if (0=FSocketMutex) then begin
    // CreateMutex failed in the constructor: the socket calls can not be
    // serialized, so the device must not be used at all (a system call which
    // should never fail has failed)
    ALastError:=DWORD(WSASYSCALLFAILURE);
    Exit;
  end;
  // WSAStartup returns the real provider error code (it does not raise)
  ALastError:=DWORD(WSAStartup(cUDP_WSA_Version_2_2, FWSAData));
  FWSAInitialized:=(0=ALastError);
  Result:=FWSAInitialized;
end;

function Tvsagps_device_udp_nmea.InternalLock_Socket(const ATimeoutMSec: DWORD): Boolean;
var
  VWaitResult: DWORD;
begin
  // every socket call is serialized, and every wait is limited - a thread
  // which was killed inside a socket call can not block the others forever
  if (0=FSocketMutex) then begin
    // CreateMutex failed in the constructor (practically impossible) - there
    // is nothing to wait for and the calls can not be serialized, so the
    // socket must not be used (see InternalWSAStartup)
    Result:=FALSE;
    Exit;
  end;
  VWaitResult:=WaitForSingleObject(FSocketMutex, ATimeoutMSec);
  // WAIT_ABANDONED: the previous owner was terminated while holding the
  // mutex - the OS gives the ownership to this thread, but the socket state
  // must be re-checked by the caller (see InternalClose_Socket)
  Result:=(WAIT_OBJECT_0=VWaitResult) or (WAIT_ABANDONED=VWaitResult);
end;

procedure Tvsagps_device_udp_nmea.InternalUnlock_Socket;
begin
  if (0<>FSocketMutex) then
    ReleaseMutex(FSocketMutex);
end;

procedure Tvsagps_device_udp_nmea.InternalClose_Socket(const ATimeoutMSec: DWORD);
var
  VLocked: Boolean;
  VSocket: TSocket;
begin
  // a bind which is still running (or finishes a moment later) must not
  // publish its socket after the close: the flag is re-checked right before
  // the publication in Internal_UdpBind
  FSessionClosing:=TRUE;

  // the socket value is read and changed only while the mutex is held; the
  // wait is bounded (WAIT_ABANDONED covers a killed owner). A live thread
  // holds the mutex only inside a select/recv slice (up to
  // cUDP_ReceiveWait_Slice_MSec), so the timeout below is normally never
  // reached. No shutdown() call: udp has no connection to half-close, and
  // the receive loop re-reads the (invalid) socket between its slices.
  VLocked:=InternalLock_Socket(ATimeoutMSec);
  try
    VSocket:=FSocket;
    if (INVALID_SOCKET=VSocket) then
      Exit;

    FSocket:=INVALID_SOCKET;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    if (not VLocked) then
      VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.InternalClose_Socket: closed without the lock');
{$ifend}
    closesocket(VSocket);
  finally
    if VLocked then
      InternalUnlock_Socket;
  end;
end;

procedure Tvsagps_device_udp_nmea.InternalResetDeviceConnectionParams;
begin
  inherited;
  if (nil<>FParser) then begin
    FParser.InitSpecialNmeaCounters;
  end;
  FRequestGPSCommand_Apply_UTCDateTime:=FALSE;
  ZeroMemory(@FSavedUTCDateTime, sizeof(FSavedUTCDateTime));
  FGlobalNmeaBuffer:='';
  FLastDataTick:=0;
  // do not leak the socket if the params are reset while it is still open
  InternalClose_Socket(cUDP_Close_Lock_Timeout_MSec);
end;

procedure Tvsagps_device_udp_nmea.Internal_Before_Open_Device;
var
  sName: AnsiString;
  VLastError: DWORD;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Open_Device: begin');
{$ifend}

  inherited;

  // a stale socket of the previous attempt must not be reused
  InternalClose_Socket(cUDP_Close_Lock_Timeout_MSec);
  // the bind below publishes a new socket, so the close flag is cleared.
  // A close requested by another thread between the close above and this
  // line is not lost: it also sets the exit flag of the working thread, which
  // Internal_UdpBind checks (under the socket mutex) before the publication
  FSessionClosing:=FALSE;
  FGPSDeviceHandle:=0;

  // bind to the user defined address:port (or the bare port)
  sName:=TrimA(FDeviceNameByUser);
  if (0=Length(sName)) then begin
    // no device name
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_No_Device_Name);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Open_Device: no device name');
{$ifend}
    Exit;
  end;

  // remember the name for unit info (device driver name)
  VSAGPS_FreeAndNil_PAnsiChar(FGPSDeviceInfo_NameToConnectInternalA);
  FGPSDeviceInfo_NameToConnectInternalA:=VSAGPS_AllocPCharByString(sName, TRUE);

  // the socket is bound here and not in WorkingThread_StartSession:
  // this method is called from the device working thread (see
  // WorkingThread_ConnectToDevice), so the caller is not blocked, and the
  // fake handle below is published only after the bind attempt. The units
  // check FinishReason before the handle, so a failed bind is reported as
  // an error and not as gs_DoneConnected; their connection timeout stays in
  // effect for the whole connecting phase.
  if (not InternalWSAStartup(VLastError)) then begin
    // WinSock failed to initialize - keep the real provider error code
    FWT_Params.dwLastError:=VLastError;
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Open_Device: WSAStartup failed '+IntToStrA(VLastError));
{$ifend}
  end else if (not Internal_UdpBind(sName)) then begin
    // dwLastError is set by Internal_UdpBind
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Open_Device: bind failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
  end;

  // the device is a stream, not a file: there is no file handle, so the fake
  // one tells the base class that the open step is done (and keeps CreateFile
  // away from the "address:port" name). A failed bind sets the fake handle
  // too - the units see the finish reason above and start disconnecting, and
  // Internal_Do_Open_Device still must not treat the name as a file name
  FGPSDeviceHandle:=FakeFileHandle;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Open_Device: end');
{$ifend}
end;

procedure Tvsagps_device_udp_nmea.Internal_Before_Close_Device;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Close_Device: begin');
{$ifend}
  inherited;

  // the socket is closed here and never reported as a device handle, so the
  // base class has nothing to close with CloseHandle. Closing the socket
  // also drops the multicast memberships of this socket (if any)
  InternalClose_Socket(cUDP_Close_Lock_Timeout_MSec);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_Before_Close_Device: end');
{$ifend}
end;

function Tvsagps_device_udp_nmea.Internal_ParseSourceFilter(const AList: AnsiString): Boolean;
var
  i, iStart: Integer;
  sItem: AnsiString;
  VAddr: DWORD;
begin
  // "ip[,ip...]" -> FAllowedSources; any bad item rejects the whole list
  // (a typo must not silently open the filter)
  Result:=FALSE;
  FAllowedSourcesCount:=0;
  if (0=Length(AList)) then
    Exit;
  iStart:=1;
  for i:=1 to (Length(AList)+1) do begin
    if (i>Length(AList)) or (','=AList[i]) then begin
      sItem:=TrimA(System.Copy(AList, iStart, i-iStart));
      iStart:=i+1;
      if (not UDP_ParseIPv4(sItem, VAddr)) or
         (cUDP_AllowedSources_Max<=FAllowedSourcesCount) then begin
        FAllowedSourcesCount:=0;
        Exit;
      end;
      FAllowedSources[FAllowedSourcesCount]:=VAddr;
      Inc(FAllowedSourcesCount);
    end;
  end;
  Result:=(0<FAllowedSourcesCount);
end;

function Tvsagps_device_udp_nmea.Internal_UdpBind(const ADeviceName: AnsiString): Boolean;
var
  sMain, sOptions, sIface, sHost, sPort: AnsiString;
  iPos: Integer;
  VHints: TAddrInfoA;
  VAddrList, VAddr: Paddrinfo;
  VSocket: TSocket;
  VSin: PSockAddrIn;
  VBindSin: TSockAddrIn;
  VOptName, VOptValue, VRes: Integer;
  VBufSize: Integer;
  VPort: Integer;
  VMReq: Tip_mreq;
  VIsMulticast, VIsBracketed, VHasIface: Boolean;
  VIfaceAddr, VHostAddr: DWORD;
  VAddrByte: PByte;
begin
  Result:=FALSE;
  FWT_Params.dwLastError:=0;
  FAllowedSourcesCount:=0;
  VAddrList:=nil;
  VIsBracketed:=FALSE;
  VHasIface:=FALSE;
  VIfaceAddr:=0;

  sMain:=ADeviceName;

  // the optional sender filter: "<name>;from=ip[,ip...]"
  iPos:=UDP_FindCharA(sMain, ';');
  if (0<iPos) then begin
    sOptions:=TrimA(System.Copy(sMain, iPos+1, Length(sMain)));
    sMain:=TrimA(System.Copy(sMain, 1, iPos-1));
    if (0<Length(sOptions)) then begin
      if ('from='<>System.Copy(UDP_LowerA(sOptions), 1, 5)) or
         (not Internal_ParseSourceFilter(System.Copy(sOptions, 6, Length(sOptions)))) then begin
        FWT_Params.dwLastError:=cError_Invalid_Param;
        Exit;
      end;
    end;
  end;

  // the optional multicast interface: "<group>:<port>@<ipv4>" (the IPv6
  // literals and host names have no '@', so the last one is the separator)
  iPos:=UDP_FindCharLastA(sMain, '@');
  if (0<iPos) then begin
    sIface:=TrimA(System.Copy(sMain, iPos+1, Length(sMain)));
    sMain:=TrimA(System.Copy(sMain, 1, iPos-1));
    if (not UDP_ParseIPv4(sIface, VIfaceAddr)) then begin
      FWT_Params.dwLastError:=cError_Invalid_Param;
      Exit;
    end;
    VHasIface:=TRUE;
  end;

  // the name has a "host:port" format or a bare "port" (bind the wildcard);
  // the port goes after the last colon (for IPv6 literals the host part
  // must be enclosed in square brackets) - searched from the end without
  // copying the whole string
  iPos:=Length(sMain);
  while (0<iPos) and (':'<>sMain[iPos]) do
    Dec(iPos);
  if (0=iPos) then begin
    // a bare port - bind the IPv4 wildcard (all interfaces)
    sHost:='0.0.0.0';
    sPort:=sMain;
  end else if (1=iPos) then begin
    // ":port" - ditto
    sHost:='0.0.0.0';
    sPort:=TrimA(System.Copy(sMain, 2, Length(sMain)));
  end else begin
    sHost:=TrimA(System.Copy(sMain, 1, iPos-1));
    sPort:=TrimA(System.Copy(sMain, iPos+1, Length(sMain)));
    // allow "[::1]:10110" (with brackets) for IPv6 literals
    if (1<Length(sHost)) and ('['=sHost[1]) and (']'=sHost[Length(sHost)]) then begin
      sHost:=System.Copy(sHost, 2, Length(sHost)-2);
      VIsBracketed:=TRUE;
    end;
  end;
  if (0=Length(sHost)) or (0=Length(sPort)) then begin
    FWT_Params.dwLastError:=cError_Invalid_Param;
    Exit;
  end;

  // the port is validated here: a non numeric value would be passed to
  // getaddrinfo as a service name and reported as a name resolution error
  if (not TryStrToIntA(sPort, VPort)) or (VPort<1) or (65535<VPort) then begin
    FWT_Params.dwLastError:=cError_Invalid_Param;
    Exit;
  end;

  // resolve the address: the wildcard above is resolved to itself, a
  // hostname to its addresses. IPv4 goes first for everything but a
  // bracketed literal: "localhost" resolves to ::1 before 127.0.0.1 on
  // Windows, and the usual sources send to IPv4. The first resolved address
  // is used (the bind below fails for a non-local one). The port is a
  // number, so getaddrinfo does no service lookup (AI_NUMERICSERV is not
  // used on purpose: Windows XP rejects it). getaddrinfo is a synchronous
  // system call, it can not be interrupted and has no timeout of its own;
  // it runs in the device working thread (see Internal_Before_Open_Device),
  // so the caller is not blocked. The bind itself can not block
  ZeroMemory(@VHints, sizeof(VHints));
  if VIsBracketed then
    VHints.ai_family:=AF_UNSPEC
  else
    VHints.ai_family:=AF_INET;
  VHints.ai_socktype:=SOCK_DGRAM;
  VHints.ai_protocol:=IPPROTO_UDP;

  // the RTL getaddrinfo/freeaddrinfo signatures are used here:
  // getaddrinfo(..., const [Ref] hints: addrinfo; out res: Paddrinfo)
  // freeaddrinfo(var ai: addrinfo) - so the first list item is passed.
  // getaddrinfo returns the error code itself (the EAI_ constants are the
  // WSA codes on Windows), WSAGetLastError is meaningless here
  VRes:=getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList);
  if (0<>VRes) and (not VIsBracketed) then begin
    // no IPv4 address for the name - let the resolver offer any family
    VAddrList:=nil;
    VHints.ai_family:=AF_UNSPEC;
    VRes:=getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList);
  end;
  if (0<>VRes) then begin
    // name resolution failed
    FWT_Params.dwLastError:=DWORD(VRes);
    Exit;
  end;

  VSocket:=INVALID_SOCKET;
  try
    VAddr:=VAddrList;
    if (nil=VAddr) then begin
      // the resolver returned nothing
      FWT_Params.dwLastError:=cError_Invalid_Param;
      Exit;
    end;

    // address classes:
    // - an IPv4 class D address (224.0.0.0/4) is a multicast group - the
    //   socket is bound to the wildcard port (a group address can not be
    //   bound on Windows) and the group is joined below;
    // - an IPv6 multicast group (ff00::/8) is not supported in this version:
    //   the plain bind may succeed, but nothing would ever arrive, so it is
    //   refused at once instead of ending with the idle timeout.
    // A broadcast address (x.x.x.255, 255.255.255.255) needs no special
    // handling: it is not a local address, the bind fails with
    // WSAEADDRNOTAVAIL, and a socket bound to the wildcard or to an
    // interface address receives the broadcasts anyway
    VIsMulticast:=FALSE;
    if (AF_INET=VAddr^.ai_family) then begin
      VSin:=PSockAddrIn(VAddr^.ai_addr);
      VHostAddr:=ntohl(VSin^.sin_addr.S_addr);
      VIsMulticast:=($E=(VHostAddr shr 28));
    end else if (cUDP_AF_INET6=VAddr^.ai_family) then begin
      if (cUDP_SockAddrIn6_MinLen<=VAddr^.ai_addrlen) then begin
        VAddrByte:=PByte(PAnsiChar(VAddr^.ai_addr)+cUDP_SockAddrIn6_AddrOffset);
        if ($FF=VAddrByte^) then begin
          FWT_Params.dwLastError:=cError_Not_Supported;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
          VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_UdpBind: IPv6 multicast is not supported');
{$ifend}
          Exit;
        end;
      end;
    end;

    // the options which have no meaning for the resolved address are errors,
    // not something to ignore silently (a misconfiguration would only show
    // up as "no data")
    if VHasIface and (not VIsMulticast) then begin
      FWT_Params.dwLastError:=cError_Invalid_Param;
      Exit;
    end;
    if (0<FAllowedSourcesCount) and (AF_INET<>VAddr^.ai_family) then begin
      // the sender filter compares IPv4 addresses
      FWT_Params.dwLastError:=cError_Invalid_Param;
      Exit;
    end;

    // create the socket
    VSocket:=socket(VAddr^.ai_family, SOCK_DGRAM, IPPROTO_UDP);
    if (INVALID_SOCKET=VSocket) then begin
      FWT_Params.dwLastError:=DWORD(WSAGetLastError);
      Exit;
    end;

    // the socket options must be set before the bind:
    // - a multicast listener shares the port with the other group listeners
    //   (SO_REUSEADDR allows the second bind on the same wildcard port);
    // - a unicast listener claims the address exclusively (SO_EXCLUSIVEADDRUSE
    //   prevents the well-known SO_REUSEADDR hijacking and makes an occupied
    //   port report WSAEADDRINUSE instead of silently succeeding); a re-bind
    //   after the session end needs no SO_REUSEADDR - udp sockets have no
    //   TIME_WAIT state
    if VIsMulticast then begin
      VOptName:=SO_REUSEADDR;
      VOptValue:=1;
    end else begin
      VOptName:=Integer(SO_EXCLUSIVEADDRUSE);
      VOptValue:=1;
    end;
    if (0<>setsockopt(VSocket, SOL_SOCKET, VOptName, @VOptValue, sizeof(VOptValue))) then begin
      FWT_Params.dwLastError:=DWORD(WSAGetLastError);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_UdpBind: option failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
      Exit;
    end;

    // a bigger kernel buffer: a failure is not fatal (the default buffer
    // is used then), so the result is not checked
    VBufSize:=cUDP_RcvBuf_Size;
    if (0<>setsockopt(VSocket, SOL_SOCKET, SO_RCVBUF, @VBufSize, sizeof(VBufSize))) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_UdpBind: SO_RCVBUF failed '+IntToStrA(DWORD(WSAGetLastError)));
{$ifend}
    end;

    // bind the local address: for the multicast - the wildcard (the group
    // address itself can not be bound on Windows), otherwise - the resolved
    // address; the name length from the resolver covers both address sizes
    if VIsMulticast then begin
      ZeroMemory(@VBindSin, sizeof(VBindSin));
      VBindSin.sin_family:=AF_INET;
      VBindSin.sin_port:=PSockAddrIn(VAddr^.ai_addr)^.sin_port; // resolved port, network byte order
      VBindSin.sin_addr.S_addr:=INADDR_ANY;
      if (0<>bind(VSocket, PSockAddr(@VBindSin)^, sizeof(VBindSin))) then begin
        FWT_Params.dwLastError:=DWORD(WSAGetLastError);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_UdpBind: bind(mc) failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
        Exit;
      end;
    end else begin
      if (0<>bind(VSocket, VAddr^.ai_addr^, Integer(VAddr^.ai_addrlen))) then begin
        FWT_Params.dwLastError:=DWORD(WSAGetLastError);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_UdpBind: bind failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
        Exit;
      end;
    end;

    // join the multicast group on the requested interface ("@ipv4") or on
    // the default multicast interface; the membership dies with the socket
    // (no IP_DROP_MEMBERSHIP is needed)
    if VIsMulticast then begin
      ZeroMemory(@VMReq, sizeof(VMReq));
      VMReq.imr_multiaddr:=PSockAddrIn(VAddr^.ai_addr)^.sin_addr;
      if VHasIface then
        VMReq.imr_interface.S_addr:=VIfaceAddr
      else
        VMReq.imr_interface.S_addr:=INADDR_ANY;
      if (0<>setsockopt(VSocket, IPPROTO_IP, cIP_Add_Membership, @VMReq, sizeof(VMReq))) then begin
        // without the membership no group data ever arrives - report at once
        FWT_Params.dwLastError:=DWORD(WSAGetLastError);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.Internal_UdpBind: join failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
        Exit;
      end;
    end;

    // bound - publish the socket (the close path and the receive loop read
    // it only under the same mutex)
    if (not InternalLock_Socket(cUDP_Lock_Timeout_MSec)) then begin
      FWT_Params.dwLastError:=WSAETIMEDOUT;
      Exit; // the finally block closes the local socket
    end;
    try
      // the close path may have run while this bind was in progress: it
      // saw no socket to close, so the socket must not be published now
      // (it would be leaked and the session would be started after the close)
      if FSessionClosing or VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
        FWT_Params.dwLastError:=WSAEINTR;
        Exit; // the finally block closes the local socket
      end;
      FSocket:=VSocket;
      VSocket:=INVALID_SOCKET; // owned by the device now
      FLastDataTick:=GetTickCount;
      // the option errors are history
      FWT_Params.dwLastError:=0;
      Result:=TRUE;
    finally
      InternalUnlock_Socket;
    end;
  finally
    if (INVALID_SOCKET<>VSocket) then
      closesocket(VSocket);
    if Assigned(VAddrList) then
      freeaddrinfo(VAddrList^);
  end;
end;

procedure Tvsagps_device_udp_nmea.InternalSetCommunicationError(const ALastError: DWORD);
begin
  // called from the working thread only - FWT_Params is not protected
  FWT_Params.dwLastError:=ALastError;
  FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Communication_Failure);
end;

function Tvsagps_device_udp_nmea.ParsePacket(const ABuffer: Pointer): DWORD;
begin
  // inherited;
  Result:=Nmea_ParsePacket_Locked(FPtrCS_CloseHandle, FGlobalNmeaBuffer, ABuffer, FParser)
end;

function Tvsagps_device_udp_nmea.SerializePacket(const APacket: Pointer;
                                                 out ASerializedSize: DWORD;
                                                 const AReserved: PDWORD): Pointer;
var
  VData: Pointer;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.SerializePacket:');
{$ifend}

  if (APacket<>nil) then begin
    ASerializedSize := NmeaPacketSize(APacket);
    VData := NmeaPacketData(APacket);
    Result := VSAGPS_GetMem(ASerializedSize);
    Move(VData^, Result^, ASerializedSize);
  end else begin
    ASerializedSize := 0;
    Result:=nil;
  end;
end;

function Tvsagps_device_udp_nmea.SendPacket(const APacketBuffer: Pointer;
                                            const APacketSize: DWORD;
                                            const AFlags: DWORD): LongBool;
begin
  // receive-only device: nothing is ever sent over udp - the source streams
  // unconditionally and there is no request protocol. The negative result
  // is reported to the caller only (FWT_Params is not touched here -
  // SendPacket can be called from a user thread)
  Result:=FALSE;
end;

function Tvsagps_device_udp_nmea.WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean;
var
  VSocket: TSocket;
  VReadSet: TFDSet;
  VTimeout: TTimeVal;
  VDelayMSec, VIdleTimeoutMSec: DWORD;
  VStartTick, VElapsedMSec, VSliceMSec: DWORD;
  VDrainStartTick: DWORD;
  VDrainCount: Integer;
  VFrom: array [0..127] of Byte; // sockaddr_storage: IPv4 and IPv6 senders
  VFromLen: Integer;
  VFromAddr: DWORD;
  VAllowed: Boolean;
  VNormalized: AnsiString;
  i: Integer;
  VSelectResult: Integer;
  VReceived: Integer;
  VRecvError: DWORD;
  VBatchCount: Integer;
  VNeedToExit: Boolean;
  queued_pointer: Pointer;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_Receive_Packets: begin');
{$ifend}

  Result:=FALSE;

  // wait for the incoming data with a limited timeout, so that the working
  // thread has a chance to check the exit flag between the attempts
  VDelayMSec:=GetDeviceWorkerThreadTimeoutMSec(FALLDeviceParams, FThisDeviceParams);
  if (0=VDelayMSec) then
    VDelayMSec:=cWorkingThread_Default_Delay_Msec;

  // the dead link watchdog follows the user setting of the data receiving
  // timeout (btReceiveGPSTimeoutSec)
  VIdleTimeoutMSec:=DWORD(GetReceiveGPSTimeoutSec(FALLDeviceParams, FThisDeviceParams))*1000;
  if (0=VIdleTimeoutMSec) then
    VIdleTimeoutMSec:=cUDP_IdleTimeout_Default_MSec;

  VStartTick:=GetTickCount;
  repeat
    // the device may be closed while the data is waited for
    if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then
      Exit;

    // the wait is split into short slices: the close path can take the
    // socket mutex between them and the exit flag is checked too
    VElapsedMSec:=UDP_ElapsedMSec(VStartTick);
    if (VElapsedMSec>=VDelayMSec) then
      Break;
    VSliceMSec:=VDelayMSec-VElapsedMSec;
    if (VSliceMSec>cUDP_ReceiveWait_Slice_MSec) then
      VSliceMSec:=cUDP_ReceiveWait_Slice_MSec;

    VRecvError:=0;
    VBatchCount:=0;
    VNeedToExit:=FALSE;
    if (not InternalLock_Socket(cUDP_Lock_Timeout_MSec)) then begin
      // the mutex must be free between the slices - this is a broken state
      // (the OS releases an abandoned mutex) - end the session instead of
      // waiting
      InternalSetCommunicationError(WSAETIMEDOUT);
      Exit;
    end;
    try
      VSocket:=FSocket;
      if (INVALID_SOCKET=VSocket) then
        Exit;

      // select and recv are called under the same mutex as closesocket, so
      // the descriptor can not be closed between them (no stale socket use)
      FD_ZERO(VReadSet);
      _FD_SET(VSocket, VReadSet);
      VTimeout.tv_sec:=VSliceMSec div 1000;
      VTimeout.tv_usec:=(VSliceMSec mod 1000)*1000;

      VSelectResult:=select(0, @VReadSet, nil, nil, @VTimeout);
      if (SOCKET_ERROR=VSelectResult) then begin
        InternalSetCommunicationError(DWORD(WSAGetLastError));
        Exit;
      end;
      if (0=VSelectResult) then
        Continue; // no data in this slice

      // the socket is readable - drain ALL the datagrams which are already
      // queued in it in one batch. A source sends a group of sentences per
      // its own tick (a simulator or a fast playback sends much more), so
      // one datagram per worker-thread period would not only cap the
      // throughput at a few datagrams per second, it would also leave the
      // socket backlog (and so the track shown to the user) behind the real
      // time - unlike the tcp stream, udp has no flow control which would
      // throttle the source. recv never blocks here: select has just
      // reported the data and every further datagram is pre-checked with a
      // zero-timeout select, so the mutex is never held while waiting
      VDrainStartTick:=GetTickCount;
      VDrainCount:=0;
      repeat
        // recvfrom and not recv: the sender address is needed by the filter
        VFromLen:=SizeOf(VFrom);
        VReceived:=recvfrom(VSocket, FNMEABuffer[0], cNmea_Buffer_Size, 0, PSockAddr(@VFrom)^, VFromLen);
        Inc(VDrainCount);
        if (0<VReceived) then begin
          // the sender filter: a datagram of a stranger is dropped and does
          // not refresh the idle watchdog (a silent real source must still
          // end the session)
          VAllowed:=TRUE;
          if (0<FAllowedSourcesCount) then begin
            VAllowed:=FALSE;
            if (AF_INET=PSockAddrIn(@VFrom)^.sin_family) then begin
              VFromAddr:=PSockAddrIn(@VFrom)^.sin_addr.S_addr;
              for i:=0 to (FAllowedSourcesCount-1) do begin
                if (FAllowedSources[i]=VFromAddr) then begin
                  VAllowed:=TRUE;
                  Break;
                end;
              end;
            end;
          end;

          if VAllowed then begin
            FLastDataTick:=GetTickCount;
            Inc(VBatchCount);

            // the shared framing waits for the CRLF tail, so the line ends
            // are repaired first; a usual CRLF datagram is queued as is
            VNormalized:=UDP_NormalizeLineEnds(@FNMEABuffer[0], VReceived);
            // datagram received - make a buffer with packet size + data into
            // the queue
            if (''<>VNormalized) then
              queued_pointer:=NmeaPacketCreate(@VNormalized[1], DWORD(Length(VNormalized)))
            else
              queued_pointer:=NmeaPacketCreate(@FNMEABuffer[0], DWORD(VReceived));
            FExternal_Queue.AppendGPSPacket(queued_pointer, FUnitIndex);

            // check exit after any packet
            if (wtfp_AnyPacket=(AWorkingThreadPacketFilter and wtfp_AnyPacket)) then
              Result:=TRUE;
          end;
        end else if (0>VReceived) then begin
          // the error code is read under the lock: releasing the mutex may
          // overwrite the thread last error
          VRecvError:=DWORD(WSAGetLastError);
          // a datagram which is bigger than the buffer is not delivered
          // (winsock reports WSAEMSGSIZE and drops the surplus), this is
          // garbage for nmea and not a reason to end the session - skip it
          if (cUDP_WSAEMSGSIZE=VRecvError) then
            VRecvError:=0;
        end;

        // unlike the tcp stream, a zero-length datagram is not a disconnect
        // (udp has no connections at all, recv=0 means an empty datagram) -
        // it is just skipped, and it does not refresh the idle watchdog (a
        // legit source never sends empty datagrams). A socket error ends the
        // session: this socket never sends, so no icmp-triggered
        // WSAECONNRESET is expected, but any real error must not be ignored
        if (0<>VRecvError) then
          Break;

        // the mutex and the outer loop are released between the batches
        if (cUDP_Drain_Batch_Max<=VDrainCount) then
          Break;
        if (cUDP_Drain_Budget_MSec<=UDP_ElapsedMSec(VDrainStartTick)) then
          Break;
        if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
          VNeedToExit:=TRUE;
          Break;
        end;

        // is another datagram already waiting? (the batch is drained only
        // while the data is there - a short silence ends the batch at once)
        FD_ZERO(VReadSet);
        _FD_SET(VSocket, VReadSet);
        VTimeout.tv_sec:=0;
        VTimeout.tv_usec:=0;
        VSelectResult:=select(0, @VReadSet, nil, nil, @VTimeout);
        if (1<>VSelectResult) then begin
          if (SOCKET_ERROR=VSelectResult) then
            VRecvError:=DWORD(WSAGetLastError);
          Break;
        end;
      until FALSE;
    finally
      InternalUnlock_Socket;
    end;

    if (0<>VRecvError) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_Receive_Packets: failed '+IntToStrA(VRecvError));
{$ifend}
      InternalSetCommunicationError(VRecvError);
      Exit;
    end;

    if VNeedToExit then
      Exit;

    if (0<VBatchCount) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_Receive_Packets: ok');
{$ifend}
      // the datagrams are queued - return to the base loop, it checks the
      // exit flag and pauses for the refresh period
      Exit;
    end;

    // only empty, rejected or truncated datagrams in this slice - keep
    // waiting for the data
  until FALSE;

  // no data during the whole wait: udp has no disconnect notification, so
  // a source which is silent for too long means that the link is dead (the
  // mux stopped sending, a broken wifi link, a wrong port) - end the
  // session, the caller reconnects (re-binds) by itself
  if (VIdleTimeoutMSec<UDP_ElapsedMSec(FLastDataTick)) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_Receive_Packets: idle timeout');
{$ifend}
    InternalSetCommunicationError(WSAETIMEDOUT);
  end;
end;

function Tvsagps_device_udp_nmea.WorkingThread_SendPacket: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_SendPacket: begin');
{$ifend}

  // a udp listener never sends anything: the source streams unconditionally
  // and there is no request protocol. The base class implementation returns
  // FALSE (its "cancel" marker) - that would end every session, so this
  // override just reports success and restarts the idle watchdog (it counts
  // from the established session and not from the bind)
  Result:=TRUE;
  FLastDataTick:=GetTickCount;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_SendPacket: end');
{$ifend}
end;

function Tvsagps_device_udp_nmea.WorkingThread_StartSession: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_StartSession: begin');
{$ifend}

  Result:=FALSE;

  // the socket is bound by Internal_Before_Open_Device (the same working
  // thread, see there): the device handle is already published, so the
  // session may start only when the socket is really there. This is a
  // sanity check only: FSocket is read without the socket mutex (a single
  // aligned read, nothing is done with the value; every real socket call
  // below re-reads it under the mutex)
  if (INVALID_SOCKET=FSocket) then begin
    if (0=FWT_Params.dwLastError) then
      FWT_Params.dwLastError:=WSAENOTCONN;
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_StartSession: no socket');
{$ifend}
    Exit;
  end;

  // the socket lives in FSocket only; FGPSDeviceHandle holds the fake
  // handle set by Internal_Before_Open_Device (the whole library treats a
  // non-zero device handle as an established connection)

  // set Communicating flag
  if (0=FGPSDeviceSessionStarted) then
    FGPSDeviceSessionStarted:=1;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_udp_nmea.WorkingThread_StartSession: Done');
{$ifend}

  Result:=TRUE;
end;

end.
