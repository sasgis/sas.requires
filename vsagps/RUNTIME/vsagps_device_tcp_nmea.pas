(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_device_tcp_nmea;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
{$IFDEF HAS_ANSISTRINGS_UNIT}
  AnsiStrings,
{$ELSE}
  StrUtils,
{$ENDIF}
  Winsock2,
  vsagps_winsock2_compat,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_nmea,
  vsagps_public_sysutils,
  vsagps_public_classes,
  vsagps_public_device,
  vsagps_tools,
  vsagps_device_base,
  vsagps_parser_nmea,
  vsagps_device_nmea_common,
  vsagps_runtime;

type
  // what to send to the server at the session start (see [TCP] start_query)
  TTcp_StartQuery_Kind = (
    sq_Default, // nothing for a plain server, the gpsd WATCH on detection
    sq_Custom,  // [TCP] start_query - the string from the ini + CR LF
    sq_None     // [TCP] start_query= (empty value) - send nothing
  );

  Tvsagps_device_tcp_nmea = class(Tvsagps_device_with_nmea)
  private
    FParser: Tvsagps_parser_nmea;
    FNMEABuffer: array [0..cNmea_Buffer_Size-1] of AnsiChar;
    FGlobalNmeaBuffer: AnsiString;
    FSocket: TSocket; // connected socket (INVALID_SOCKET when not connected)
    // set by InternalClose_Socket: a connect which finished after the close
    // started must not publish its socket (it would leak)
    FSessionClosing: Boolean;
    // serializes all the socket calls (select/recv/send/closesocket): the
    // public SendPacket may be called from a user thread while the working
    // thread receives. A mutex is used instead of a critical section because
    // the OS releases it when the owner is killed by TerminateThread
    FSocketMutex: THandle;
    FWSAData: TWSAData; // WinSock initialization info
    FWSAInitialized: Boolean; // WSAStartup/WSACleanup pairing for this object
    FLastDataTick: DWORD; // GetTickCount of the last received data chunk
    FSavedUTCDateTime: TNMEA_Date_Time;
    FUserIni: TStringListA; // user nmea ini (vsagps_nmea.ini)
    FStartQueryKind: TTcp_StartQuery_Kind; // what to send at the session start
    FStartQueryCustom: AnsiString; // the custom query (sq_Custom), sent as is + CR LF
  private
    procedure Do_RequestGPSCommand_Apply_UTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
    function InternalWSAStartup(out ALastError: DWORD): Boolean;
    procedure InternalLoadUserIni;
    function InternalLock_Socket(const ATimeoutMSec: DWORD): Boolean;
    procedure InternalUnlock_Socket;
    procedure InternalClose_Socket(const ATimeoutMSec: DWORD);
    function Internal_TcpConnect(const ADeviceName: AnsiString): Boolean;
    function Probe_Server_Greeting: Boolean;
    function Send_NmeaTcp_Packet(const AFullPacket: AnsiString; out ALastError: DWORD): Boolean;
    function Make_and_Send_NmeaTcp_Packet(const AIncompletePacket: AnsiString; out ALastError: DWORD): Boolean;
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
    // send query packet to gps
    function WorkingThread_SendPacket: Boolean; override;
    // receive packets from device to queue
    function WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean; override;
  end;

implementation

uses
  vsagps_ini,
  vsagps_public_memory,
  vsagps_public_debugstring;

const
  // ERROR_INVALID_PARAMETER from winerror.h (the Windows unit declares it as
  // ERROR_INVALID_PARAMETER, the short name could clash with other units)
  cError_Invalid_Param = 87;

  // version 2.2 of the WinSock specification
  // (not taken from the winsock unit - the RTL unit does not declare it)
  cWSA_Version_2_2 = $0202;

  // one select() slice while waiting for the connection result - the device
  // close is checked between the slices
  cConnectWait_Slice_MSec = 250;

  // the receive wait is split into the same kind of slices: the close path
  // must be able to take the socket mutex between them
  cReceiveWait_Slice_MSec = 100;

  // tcp keepalive: probe an idle connection after 30 sec, 5 sec between the
  // probes (the system defaults are measured in hours)
  cTCP_KeepAliveTime_MSec = 30000;
  cTCP_KeepAliveInterval_MSec = 5000;

  // the send() call is limited - a receiver which stopped reading must not
  // block the sender forever
  cTCP_SendTimeout_MSec = 5000;

  // the idle timeout used when the user has not set btReceiveGPSTimeoutSec
  // (nmea streams are normally about 1 Hz)
  cTCP_IdleTimeout_Default_MSec = 30000;

  // how long a socket call may wait for the mutex: it must be longer than
  // SO_SNDTIMEO, because a send() call holds the mutex; a mutex owned by a
  // terminated thread is released by the OS (WAIT_ABANDONED), so the timeout
  // only covers a live thread
  cTCP_Lock_Timeout_MSec = 10000;

  // the close path waits less: shutdown() already unblocks a pending
  // select/recv/send in the owning thread
  cTCP_Close_Lock_Timeout_MSec = 2000;

  // the minimum share of the remaining connection time which a single
  // resolved address may get (see Internal_TcpConnect)
  cTCP_Address_Timeout_Min_MSec = 1000;

  // gpsd announces itself with this json banner right after the connection
  // is accepted; the device detects it and switches to the gpsd mode
  cGpsd_Version_Prefix = '{"class":"VERSION"';
  // makes gpsd stream the raw nmea sentences (\r\n ended) interleaved with
  // the json reports - the nmea framing drops the json lines
  cGpsd_Watch_Command = '?WATCH={"enable":true,"nmea":true}';

  // how long to wait for the first line of the server greeting before
  // falling back to the default nmea query (gpsd answers at once, regular
  // nmea servers stream at 1 Hz); the wait is sliced and the probed data is
  // queued as the usual packets. The session start callback is fired after
  // the probe, so the wait is kept short: a server which answers only on a
  // query loses nothing (the query is sent right after the probe)
  cGpsdProbe_Timeout_MSec = 1000;
  cGpsdProbe_Slice_MSec = 250;
  // the accumulated greeting is limited: a server which sends data without
  // the line end must not grow it forever (only the first line is needed)
  cGpsdProbe_MaxLen = 4096;

  // SIO_KEEPALIVE_VALS from mstcpip.h - not declared in the RTL Winsock unit
  cSIO_KEEPALIVE_VALS = $98000004;

type
  // tcp_keepalive from mstcpip.h
  TTcpKeepAlive = record
    onoff: u_long;
    keepalivetime: u_long;
    keepaliveinterval: u_long;
  end;

{ Tvsagps_device_tcp_nmea }

constructor Tvsagps_device_tcp_nmea.Create;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Create: begin');
{$ifend}

  // initialize the fields which are used by
  // InternalResetDeviceConnectionParams - the base constructor calls it
  FSocket:=INVALID_SOCKET;
  FSessionClosing:=FALSE;
  FWSAInitialized:=FALSE;
  FLastDataTick:=0;
  FUserIni:=nil;
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

  // windows sockets are initialized lazily on every session start
  // (the error can be temporary, so every start retries it)

  InternalLoadUserIni;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Create: end');
{$ifend}
end;

destructor Tvsagps_device_tcp_nmea.Destroy;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Destroy: begin');
{$ifend}

  // inherited stops the working thread and closes the device
  inherited;

  FreeAndNil(FUserIni);
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
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Destroy: end');
{$ifend}
end;

procedure Tvsagps_device_tcp_nmea.Do_RequestGPSCommand_Apply_UTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
begin
  // the shared implementation works with the same-named fields of the device
  NMEA_Apply_UTCDateTime(FRequestGPSCommand_Apply_UTCDateTime,
                         FSavedUTCDateTime,
                         ADate,
                         ATime);
end;

function Tvsagps_device_tcp_nmea.InternalWSAStartup(out ALastError: DWORD): Boolean;
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
  try
    // WSAStartup returns the real provider error code
    ALastError:=DWORD(WSAStartup(cWSA_Version_2_2, FWSAData));
  except
    // the call itself failed - there is no provider code, report the
    // system one instead of pretending "WSAStartup was not called"
    ALastError:=GetLastError;
    if (0=ALastError) then
      ALastError:=WSANOTINITIALISED;
  end;
  FWSAInitialized:=(0=ALastError);
  Result:=FWSAInitialized;
end;

procedure Tvsagps_device_tcp_nmea.InternalLoadUserIni;
var
  VValue: AnsiString;
begin
  try
    if (nil=FUserIni) then
      FUserIni:=TStringListA.Create;
    FUserIni.LoadFromFile(vsagps_nmea_ini_filename);
    if (0=FUserIni.Count) then
      FreeAndNil(FUserIni);
  except
    FreeAndNil(FUserIni);
  end;
  // the custom start query of this device: [TCP] start_query is sent
  // as is (without the checksum wrapping, only the line end CR LF is
  // appended), an empty value disables the
  // start query at all; by default nothing is sent to a plain server, or
  // the gpsd WATCH is sent on detection. [GLOBAL] readonly is not read
  // here: it is a com nmea option, see the unit header
  FStartQueryKind:=sq_Default;
  FStartQueryCustom:='';
  if VSAGPS_ini_GetSectionValue(FUserIni, vsagps_ini_tcp, vsagps_ini_start_query, VValue) then begin
    if (0=Length(VValue)) then
      FStartQueryKind:=sq_None
    else begin
      FStartQueryKind:=sq_Custom;
      FStartQueryCustom:=VValue;
    end;
  end;
end;

function Tvsagps_device_tcp_nmea.InternalLock_Socket(const ATimeoutMSec: DWORD): Boolean;
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

procedure Tvsagps_device_tcp_nmea.InternalUnlock_Socket;
begin
  if (0<>FSocketMutex) then
    ReleaseMutex(FSocketMutex);
end;

procedure Tvsagps_device_tcp_nmea.InternalClose_Socket(const ATimeoutMSec: DWORD);
var
  VLocked: Boolean;
  VSocket: TSocket;
begin
  // a connect which is still running (or finishes a moment later) must not
  // publish its socket after the close: the flag is re-checked right before
  // the publication in Internal_TcpConnect
  FSessionClosing:=TRUE;

  // the socket value is read and changed only while the mutex is held; the
  // wait is bounded (WAIT_ABANDONED covers a killed owner). A live thread can
  // hold the mutex only inside a send() bounded by SO_SNDTIMEO (5 sec), so
  // the timeout below is normally never reached.
  VLocked:=InternalLock_Socket(ATimeoutMSec);
  try
    VSocket:=FSocket;
    if (INVALID_SOCKET=VSocket) then
      Exit;

    // shutdown is thread safe and unblocks a pending select/recv/send of
    // another thread (normally there is none, because the mutex is held)
    shutdown(VSocket, SD_BOTH);

    FSocket:=INVALID_SOCKET;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    if (not VLocked) then
      VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.InternalClose_Socket: closed without the lock');
{$ifend}
    closesocket(VSocket);
  finally
    if VLocked then
      InternalUnlock_Socket;
  end;
end;

procedure Tvsagps_device_tcp_nmea.InternalResetDeviceConnectionParams;
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
  InternalClose_Socket(cTCP_Close_Lock_Timeout_MSec);
end;

procedure Tvsagps_device_tcp_nmea.Internal_Before_Open_Device;
var
  sName: AnsiString;
  VLastError: DWORD;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Open_Device: begin');
{$ifend}

  inherited;

  // a stale socket of the previous attempt must not be reused
  InternalClose_Socket(cTCP_Close_Lock_Timeout_MSec);
  // the connect below publishes a new socket, so the close flag is cleared
  FSessionClosing:=FALSE;
  FGPSDeviceHandle:=0;

  // connect to the user defined host:port
  sName:=TrimA(FDeviceNameByUser);
  if (0=Length(sName)) then begin
    // no device name
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_No_Device_Name);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Open_Device: no device name');
{$ifend}
    Exit;
  end;

  // remember the name for unit info (device driver name)
  VSAGPS_FreeAndNil_PAnsiChar(FGPSDeviceInfo_NameToConnectInternalA);
  FGPSDeviceInfo_NameToConnectInternalA:=VSAGPS_AllocPCharByString(sName, TRUE);

  // the connection is established here and not in WorkingThread_StartSession:
  // this method is called from the device working thread (see
  // WorkingThread_ConnectToDevice), so the caller is not blocked, and the fake
  // handle below is published only after the connection attempt. The units
  // check FinishReason before the handle, so a failed connect is reported as
  // an error and not as gs_DoneConnected; their connection timeout stays in
  // effect for the whole connecting phase.
  if (not InternalWSAStartup(VLastError)) then begin
    // WinSock failed to initialize - keep the real provider error code
    FWT_Params.dwLastError:=VLastError;
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Open_Device: WSAStartup failed '+IntToStrA(VLastError));
{$ifend}
  end else if (not Internal_TcpConnect(sName)) then begin
    // dwLastError is set by Internal_TcpConnect
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Open_Device: connect failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
  end;

  // the device is a stream, not a file: there is no file handle, so the fake
  // one tells the base class that the open step is done (and keeps CreateFile
  // away from the "host:port" name). A failed connect sets the fake handle
  // too - the units see the finish reason above and start disconnecting, and
  // Internal_Do_Open_Device still must not treat the name as a file name
  FGPSDeviceHandle:=FakeFileHandle;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Open_Device: end');
{$ifend}
end;

procedure Tvsagps_device_tcp_nmea.Internal_Before_Close_Device;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Close_Device: begin');
{$ifend}
  inherited;

  // the socket is closed here and never reported as a device handle, so the
  // base class has nothing to close with CloseHandle
  InternalClose_Socket(cTCP_Close_Lock_Timeout_MSec);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Internal_Before_Close_Device: end');
{$ifend}
end;

function Tvsagps_device_tcp_nmea.Internal_TcpConnect(const ADeviceName: AnsiString): Boolean;
var
  sHost, sPort: AnsiString;
  iPos: Integer;
  VHints: TAddrInfoA;
  VAddrList, VAddr, VItem: Paddrinfo;
  VSocket: TSocket;
  VNonBlocking: u_long;
  VSockError, VOptLen, VOption: Integer;
  VWriteSet, VExceptSet: TFDSet;
  VTimeout: TTimeVal;
  VStartTick, VTimeoutMSec, VElapsedMSec, VSliceMSec: DWORD;
  VRemainingMSec, VAddrStartTick, VAddrTimeoutMSec, VAddrCount: DWORD;
  VSelectResult: Integer;
  VPort, VRes: Integer;
  VPortOk: Boolean;
  VKeepAlive: TTcpKeepAlive;
  VBytesReturned: DWORD;
begin
  Result:=FALSE;
  FWT_Params.dwLastError:=0;

  // the name has a "host:port" format; the port goes after the last colon
  // (for IPv6 literals the host part must be enclosed in square brackets) -
  // searched from the end without copying the whole string
  iPos:=Length(ADeviceName);
  while (0<iPos) and (':'<>ADeviceName[iPos]) do
    Dec(iPos);
  if (iPos<=1) then begin
    // no port in the name
    FWT_Params.dwLastError:=cError_Invalid_Param;
    Exit;
  end;
  sHost:=TrimA(System.Copy(ADeviceName, 1, iPos-1));
  sPort:=TrimA(System.Copy(ADeviceName, iPos+1, Length(ADeviceName)));
  if (0=Length(sHost)) or (0=Length(sPort)) then begin
    FWT_Params.dwLastError:=cError_Invalid_Param;
    Exit;
  end;

  // the port is validated here: a non numeric value would be passed to
  // getaddrinfo as a service name and reported as a name resolution error
  VPortOk:=TryStrToIntA(sPort, VPort);
  if ((not VPortOk) or (VPort<1) or (65535<VPort)) then begin
    FWT_Params.dwLastError:=cError_Invalid_Param;
    Exit;
  end;

  // allow "[::1]:10110" (with brackets) for IPv6 literals
  if (1<Length(sHost)) and ('['=sHost[1]) and (']'=sHost[Length(sHost)]) then begin
    sHost:=System.Copy(sHost, 2, Length(sHost)-2);
  end;
  if (0=Length(sHost)) then begin
    FWT_Params.dwLastError:=cError_Invalid_Param;
    Exit;
  end;

  // the whole connecting phase has a single deadline: the name resolution
  // below and all resolved addresses share one timeout
  VTimeoutMSec:=vssagps_GetConnectionTimeoutSec(FALLDeviceParams)*1000;
  if (0=VTimeoutMSec) then
    VTimeoutMSec:=DWORD(cWorkingThread_Connection_Timeout_Sec)*1000;
  VStartTick:=GetTickCount;

  // the device may be closed before the connection is even started
  if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
    FWT_Params.dwLastError:=WSAEINTR;
    Exit;
  end;

  // resolve the host name to a list of addresses (IPv4 and IPv6, the order
  // is defined by the system resolver policy, RFC 6724 - IPv6 is often the
  // first one). getaddrinfo is a synchronous system call, it can not be
  // interrupted and has no timeout of its own; it runs in the device working
  // thread (see Internal_Before_Open_Device), so it does not block the caller,
  // but the connection time spent here is taken into account below
  ZeroMemory(@VHints, sizeof(VHints));
  VHints.ai_family:=AF_UNSPEC;
  VHints.ai_socktype:=SOCK_STREAM;
  VHints.ai_protocol:=IPPROTO_TCP;

  // the RTL getaddrinfo/freeaddrinfo signatures are used here:
  // getaddrinfo(..., const [Ref] hints: addrinfo; out res: Paddrinfo)
  // freeaddrinfo(var ai: addrinfo) - so the first list item is passed.
  // getaddrinfo returns the error code itself (the EAI_ constants are the
  // WSA codes on Windows), WSAGetLastError is meaningless here
  VRes:=getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList);
  if (0<>VRes) then begin
    // name resolution failed
    FWT_Params.dwLastError:=DWORD(VRes);
    Exit;
  end;

  VSocket:=INVALID_SOCKET;
  try
    VAddr:=VAddrList;
    while (INVALID_SOCKET=VSocket) and (nil<>VAddr) do begin
      // the device may be closed while the addresses are tried
      if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
        FWT_Params.dwLastError:=WSAEINTR;
        Break;
      end;
      // the total connecting time is limited - check the deadline before
      // trying the next address
      VElapsedMSec:=GetTickCount-VStartTick;
      if (VElapsedMSec>=VTimeoutMSec) then begin
        FWT_Params.dwLastError:=WSAETIMEDOUT;
        Break;
      end;
      VRemainingMSec:=VTimeoutMSec-VElapsedMSec;

      // every address gets its fair share of the remaining time: a black
      // holed address (e.g. an unreachable IPv6) must not consume the whole
      // budget, otherwise the IPv4 addresses are never tried
      VAddrCount:=0;
      VItem:=VAddr;
      while (nil<>VItem) do begin
        Inc(VAddrCount);
        VItem:=VItem^.ai_next;
      end;
      VAddrTimeoutMSec:=VRemainingMSec div VAddrCount;
      if (VAddrTimeoutMSec<cTCP_Address_Timeout_Min_MSec) then
        VAddrTimeoutMSec:=cTCP_Address_Timeout_Min_MSec;
      if (VAddrTimeoutMSec>VRemainingMSec) then
        VAddrTimeoutMSec:=VRemainingMSec;
      VAddrStartTick:=GetTickCount;

      // create the socket for this address
      VSocket:=socket(VAddr^.ai_family, SOCK_STREAM, IPPROTO_TCP);
      if (INVALID_SOCKET=VSocket) then begin
        FWT_Params.dwLastError:=DWORD(WSAGetLastError);
        VAddr:=VAddr^.ai_next;
        Continue;
      end;

      // switch the socket to the non-blocking mode to be able to limit
      // the connect() call with our own timeout
      VNonBlocking:=1;
      if (0<>ioctlsocket(VSocket, Longint(FIONBIO), VNonBlocking)) then begin
        FWT_Params.dwLastError:=DWORD(WSAGetLastError);
        closesocket(VSocket);
        VSocket:=INVALID_SOCKET;
        VAddr:=VAddr^.ai_next;
        Continue;
      end;

      // start the asynchronous connection
      if (0=Winsock2.connect(VSocket, VAddr^.ai_addr^, Integer(VAddr^.ai_addrlen))) then begin
        // connected immediately
        Break;
      end;

      VSockError:=WSAGetLastError;
      if (WSAEWOULDBLOCK<>VSockError) then begin
        // immediate connection error
        FWT_Params.dwLastError:=DWORD(VSockError);
        closesocket(VSocket);
        VSocket:=INVALID_SOCKET;
        VAddr:=VAddr^.ai_next;
        Continue;
      end;

      // wait for the connection result: on Windows a successful connection
      // is signalled through writefds and a failed one through exceptfds,
      // so both sets are waited for. The wait is split into short slices to
      // let the device close interrupt it, and it is limited by the budget
      // of this address (not by the whole remaining time).
      VSockError:=0;
      repeat
        VElapsedMSec:=GetTickCount-VAddrStartTick;
        if (VElapsedMSec>=VAddrTimeoutMSec) then begin
          VSockError:=WSAETIMEDOUT;
          Break;
        end;
        VSliceMSec:=VAddrTimeoutMSec-VElapsedMSec;
        if (VSliceMSec>cConnectWait_Slice_MSec) then
          VSliceMSec:=cConnectWait_Slice_MSec;

        FD_ZERO(VWriteSet);
        _FD_SET(VSocket, VWriteSet);
        FD_ZERO(VExceptSet);
        _FD_SET(VSocket, VExceptSet);
        VTimeout.tv_sec:=VSliceMSec div 1000;
        VTimeout.tv_usec:=(VSliceMSec mod 1000)*1000;

        VSelectResult:=select(0, nil, @VWriteSet, @VExceptSet, @VTimeout);
        if (SOCKET_ERROR=Integer(VSelectResult)) then begin
          VSockError:=WSAGetLastError;
          Break;
        end;
        if (0<>VSelectResult) then
          Break; // connected or failed - the result is in SO_ERROR

        // no result within the slice: the device may be closed by the user
        if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
          VSockError:=WSAEINTR;
          Break;
        end;
      until FALSE;

      if (0=VSockError) then begin
        // check the connection result (SO_ERROR also clears the pending error)
        VOptLen:=sizeof(VSockError);
        if (0<>getsockopt(VSocket, SOL_SOCKET, SO_ERROR, @VSockError, VOptLen)) then
          VSockError:=WSAGetLastError;
      end;

      if (0<>VSockError) then begin
        // connection was not established
        FWT_Params.dwLastError:=DWORD(VSockError);
        closesocket(VSocket);
        VSocket:=INVALID_SOCKET;
        if (WSAEINTR=DWORD(VSockError)) then
          Break; // interrupted by the device close - do not try other addresses
        VAddr:=VAddr^.ai_next;
        Continue;
      end;
      // connected
    end;

    if (INVALID_SOCKET=VSocket) then
      Exit;

    // switch the connected socket back to the blocking mode -
    // the receive loop uses select() with its own timeouts
    VNonBlocking:=0;
    if (0<>ioctlsocket(VSocket, Longint(FIONBIO), VNonBlocking)) then begin
      FWT_Params.dwLastError:=DWORD(WSAGetLastError);
      closesocket(VSocket);
      VSocket:=INVALID_SOCKET;
      Exit;
    end;

    // detect a silently dead connection: keepalive probes with short
    // intervals (a failure here is not critical)
    VOption:=1;
    setsockopt(VSocket, SOL_SOCKET, SO_KEEPALIVE, @VOption, sizeof(VOption));
    ZeroMemory(@VKeepAlive, sizeof(VKeepAlive));
    VKeepAlive.onoff:=1;
    VKeepAlive.keepalivetime:=cTCP_KeepAliveTime_MSec;
    VKeepAlive.keepaliveinterval:=cTCP_KeepAliveInterval_MSec;
    VBytesReturned:=0;
    WSAIoctl(VSocket,
             cSIO_KEEPALIVE_VALS,
             @VKeepAlive,
             sizeof(VKeepAlive),
             nil,
             0,
             VBytesReturned,
             nil,
             nil);

    // a receiver which stopped reading must not block the sender forever
    VOption:=cTCP_SendTimeout_MSec;
    setsockopt(VSocket, SOL_SOCKET, SO_SNDTIMEO, @VOption, sizeof(VOption));

    // nmea streams usually come in small frequent chunks - disable the Nagle
    // algorithm for the sending direction (TCP_NODELAY affects only the
    // outgoing data); a failure here is not critical, so just ignore it
    VOption:=1;
    setsockopt(VSocket, IPPROTO_TCP, TCP_NODELAY, @VOption, sizeof(VOption));

    // connected - publish the socket (the close path and the receive loop
    // read it only under the same mutex)
    if (not InternalLock_Socket(cTCP_Lock_Timeout_MSec)) then begin
      FWT_Params.dwLastError:=WSAETIMEDOUT;
      Exit; // the finally block closes the local socket
    end;
    try
      // the close path may have run while this connect was in progress: it
      // saw no socket to close, so the socket must not be published now (it
      // would be leaked and the session would be started after the close)
      if FSessionClosing or VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
        FWT_Params.dwLastError:=WSAEINTR;
        Exit; // the finally block closes the local socket
      end;
      FSocket:=VSocket;
      FLastDataTick:=GetTickCount;
      // the errors of the failed addresses tried before this one are history
      FWT_Params.dwLastError:=0;
      Result:=TRUE;
    finally
      InternalUnlock_Socket;
    end;
  finally
    if (not Result) then begin
      if (INVALID_SOCKET<>VSocket) then
        closesocket(VSocket);
    end;
    freeaddrinfo(VAddrList^);
  end;
end;

procedure Tvsagps_device_tcp_nmea.InternalSetCommunicationError(const ALastError: DWORD);
begin
  // called from the working thread only - FWT_Params is not protected
  FWT_Params.dwLastError:=ALastError;
  FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Communication_Failure);
end;

function Tvsagps_device_tcp_nmea.Make_and_Send_NmeaTcp_Packet(const AIncompletePacket: AnsiString;
                                                              out ALastError: DWORD): Boolean;
begin
  ALastError:=0;
  if (0=Length(AIncompletePacket)) then begin
    // nothing to send
    Result:=TRUE;
    Exit;
  end;
  Result:=Send_NmeaTcp_Packet(MakeNmeaFullString(AIncompletePacket), ALastError);
end;

function Tvsagps_device_tcp_nmea.ParsePacket(const ABuffer: Pointer): DWORD;
begin
  // inherited;
  Result:=Nmea_ParsePacket_Locked(FPtrCS_CloseHandle, FGlobalNmeaBuffer, ABuffer, FParser)
end;

function Tvsagps_device_tcp_nmea.Probe_Server_Greeting: Boolean;
var
  VSocket: TSocket;
  VReadSet: TFDSet;
  VTimeout: TTimeVal;
  VSelectResult: Integer;
  VReceived: Integer;
  VLastError: DWORD;
  VProbe: AnsiString;
  VQueued: Pointer;
  VDeadline, VNow, VSlice: DWORD;
begin
  // gpsd announces itself right after the connection is accepted (the
  // {"class":"VERSION"} json banner) and streams nothing until the WATCH
  // command. Wait shortly for the first line of the server greeting: the
  // probed data is queued as the usual packets (nothing is lost), the
  // accumulated probe is checked for the banner. Regular nmea servers
  // stream immediately (their first \r\n completes the wait), the servers
  // which need a query are detected by the timeout.
  Result:=FALSE;
  VProbe:='';
  VDeadline:=GetTickCount+cGpsdProbe_Timeout_MSec;
  repeat
    VNow:=GetTickCount;
    if ((VNow-VDeadline) < $80000000) then
      Break; // deadline reached
    VSlice:=VDeadline-VNow;
    if (VSlice>cGpsdProbe_Slice_MSec) then
      VSlice:=cGpsdProbe_Slice_MSec;

    if (not InternalLock_Socket(cTCP_Lock_Timeout_MSec)) then
      Break;
    try
      VSocket:=FSocket;
      if (INVALID_SOCKET=VSocket) then
        Break;

      FD_ZERO(VReadSet);
      _FD_SET(VSocket, VReadSet);
      VTimeout.tv_sec:=VSlice div 1000;
      VTimeout.tv_usec:=(VSlice mod 1000)*1000;

      VSelectResult:=select(0, @VReadSet, nil, nil, @VTimeout);
      if (SOCKET_ERROR=VSelectResult) then
        Break; // broken socket - the send step below reports the real error
      if (0<VSelectResult) then begin
        VReceived:=recv(VSocket, FNMEABuffer[0], cNmea_Buffer_Size, 0);
        if (0<VReceived) then begin
          FLastDataTick:=GetTickCount;
          // only the first part of the greeting is kept: a stream without a
          // line end (a wrong port, a binary protocol) must not grow it
          if (Length(VProbe)<cGpsdProbe_MaxLen) then
            VProbe:=VProbe+SafeSetStringL(PAnsiChar(@FNMEABuffer[0]), VReceived);
          // queue the probed data as a usual packet - the parser thread
          // handles it together with the following data
          VQueued:=NmeaPacketCreate(@FNMEABuffer[0], DWORD(VReceived));
          FExternal_Queue.AppendGPSPacket(VQueued, FUnitIndex);
        end else if (0=VReceived) then
          Break // the peer closed - the send step below fails with a real error
        else begin
          VLastError:=DWORD(WSAGetLastError);
          if (WSAEWOULDBLOCK<>VLastError) then
            Break; // socket error - ditto
        end;
      end;
    finally
      InternalUnlock_Socket;
    end;

    // the device is closing - stop the probe, nothing will be sent
    if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then
      Exit;

    // the first line of the greeting is complete (or the accumulated part is
    // large enough) - enough for the detection
    if (0<PosA(AnsiString(#10), VProbe)) then
      Break;
    if (Length(VProbe)>=cGpsdProbe_MaxLen) then
      Break;
  until FALSE;

  // gpsd detection: the banner prefix anywhere in the greeting
  Result:=(0<PosA(cGpsd_Version_Prefix, VProbe));
end;

function Tvsagps_device_tcp_nmea.Send_NmeaTcp_Packet(const AFullPacket: AnsiString;
                                                     out ALastError: DWORD): Boolean;
var
  P: PByte;
  iLeft, iSent: Integer;
  VSocket: TSocket;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Send_NmeaTcp_Packet: "' + AFullPacket + '"');
{$ifend}

  Result:=FALSE;
  ALastError:=0;

  if (0=Length(AFullPacket)) then begin
    // nothing to send
    Result:=TRUE;
    Exit;
  end;

  // the whole send is serialized: the packet bytes of two sentences must not
  // be mixed on the wire and the socket must not be closed in the middle;
  // the wait is limited (the close path can abandon a killed owner)
  if (not InternalLock_Socket(cTCP_Lock_Timeout_MSec)) then begin
    ALastError:=WSAETIMEDOUT;
    Exit;
  end;
  try
    VSocket:=FSocket;
    if (INVALID_SOCKET=VSocket) then begin
      ALastError:=WSAENOTCONN;
      Exit;
    end;

    // send may transfer only a part of the data - loop until everything is sent
    P:=Pointer(AFullPacket);
    iLeft:=Length(AFullPacket);
    while (0<iLeft) do begin
      iSent:=send(VSocket, P^, iLeft, 0);
      if (SOCKET_ERROR=iSent) then begin
        // error
        ALastError:=DWORD(WSAGetLastError);
        Exit;
      end;
      if (0=iSent) then begin
        // no progress - report an error instead of looping forever
        ALastError:=WSAECONNABORTED;
        Exit;
      end;
      Inc(P, iSent);
      Dec(iLeft, iSent);
    end;
    Result:=TRUE;
  finally
    InternalUnlock_Socket;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.Send_NmeaTcp_Packet: ok');
{$ifend}
end;

function Tvsagps_device_tcp_nmea.SerializePacket(const APacket: Pointer;
                                                 out ASerializedSize: DWORD;
                                                 const AReserved: PDWORD): Pointer;
var
  VData: Pointer;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.SerializePacket:');
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

function Tvsagps_device_tcp_nmea.SendPacket(const APacketBuffer: Pointer;
                                            const APacketSize: DWORD;
                                            const AFlags: DWORD): LongBool;
var
  s: AnsiString;
  VLastError: DWORD;
begin
  // invalid parameters
  if (nil=APacketBuffer) then begin
    Result:=FALSE;
    Exit;
  end;

  // nothing to send
  if (0=APacketSize) then begin
    Result:=TRUE;
    Exit;
  end;

  s := SafeSetStringL(PAnsiChar(APacketBuffer), APacketSize);
  // full packet or data only?
  if (gspf_FullPacket = (AFlags and gspf_FullPacket)) then begin
    // full packet
    Result:=Send_NmeaTcp_Packet(s, VLastError);
  end else begin
    // make full packet and send it
    Result:=Make_and_Send_NmeaTcp_Packet(s, VLastError);
  end;
  // FWT_Params is not touched here: SendPacket can be called from a user
  // thread, the error is reported by the result only (the working thread
  // sets the device finish reason when its own data cannot be sent)
end;

function Tvsagps_device_tcp_nmea.WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean;
var
  VSocket: TSocket;
  VReadSet: TFDSet;
  VTimeout: TTimeVal;
  VDelayMSec, VIdleTimeoutMSec: DWORD;
  VStartTick, VElapsedMSec, VSliceMSec: DWORD;
  VSelectResult: Integer;
  VReceived: Integer;
  VLastError, VRecvError: DWORD;
  queued_pointer: Pointer;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_Receive_Packets: begin');
{$ifend}

  Result:=FALSE;

  // wait for the incoming data with a limited timeout, so that the working
  // thread has a chance to check the exit flag between the attempts
  VDelayMSec:=GetDeviceWorkerThreadTimeoutMSec(FALLDeviceParams, FThisDeviceParams);
  if (0=VDelayMSec) then
    VDelayMSec:=cWorkingThread_Default_Delay_Msec;

  // the dead connection watchdog follows the user setting of the data
  // receiving timeout (btReceiveGPSTimeoutSec)
  VIdleTimeoutMSec:=DWORD(GetReceiveGPSTimeoutSec(FALLDeviceParams, FThisDeviceParams))*1000;
  if (0=VIdleTimeoutMSec) then
    VIdleTimeoutMSec:=cTCP_IdleTimeout_Default_MSec;

  VStartTick:=GetTickCount;
  repeat
    // the device may be closed while the data is waited for
    if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then
      Exit;

    // the wait is split into short slices: the close path can take the
    // socket mutex between them and the exit flag is checked too
    VElapsedMSec:=GetTickCount-VStartTick;
    if (VElapsedMSec>=VDelayMSec) then
      Break;
    VSliceMSec:=VDelayMSec-VElapsedMSec;
    if (VSliceMSec>cReceiveWait_Slice_MSec) then
      VSliceMSec:=cReceiveWait_Slice_MSec;

    VRecvError:=0;
    if (not InternalLock_Socket(cTCP_Lock_Timeout_MSec)) then begin
      // a live thread can not hold the mutex longer than the send timeout,
      // so this is a broken state - end the session instead of waiting
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

      // the socket is readable - receive a chunk of data; recv does not
      // block here because select has just reported the data (or the
      // connection close, which is reported as 0)
      VReceived:=recv(VSocket, FNMEABuffer[0], cNmea_Buffer_Size, 0);
      if (0<VReceived) then
        FLastDataTick:=GetTickCount
      else if (0>VReceived) then
        // the error code is read under the lock: releasing the mutex may
        // overwrite the thread last error
        VRecvError:=DWORD(WSAGetLastError);
    finally
      InternalUnlock_Socket;
    end;

    if (0<VReceived) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_Receive_Packets: ok');
{$ifend}
      // packet received - make a buffer with packet size + data into queue
      queued_pointer := NmeaPacketCreate(@FNMEABuffer[0], DWORD(VReceived));

      // add packet to queue
      FExternal_Queue.AppendGPSPacket(queued_pointer, FUnitIndex);

      // check exit after any packet
      if (wtfp_AnyPacket=(AWorkingThreadPacketFilter and wtfp_AnyPacket)) then
        Result:=TRUE;
      Exit;
    end;

    // 0 - the remote peer closed the connection gracefully, <0 - socket error;
    // both cases end the session, but the graceful close keeps dwLastError=0
    // and is reported separately in the debug output
    if (0=VReceived) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_Receive_Packets: connection closed by the peer');
{$ifend}
      InternalSetCommunicationError(0);
    end else begin
      VLastError:=VRecvError;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_Receive_Packets: failed '+IntToStrA(VLastError));
{$ifend}
      InternalSetCommunicationError(VLastError);
    end;
    Exit;

  until FALSE;

  // no data during the whole wait - not an error by itself, but a peer which
  // is silent for too long means that the connection is dead (an expired NAT
  // entry, a broken link, a hung server - without any FIN/RST)
  if (VIdleTimeoutMSec<(GetTickCount-FLastDataTick)) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_Receive_Packets: idle timeout');
{$ifend}
    InternalSetCommunicationError(WSAETIMEDOUT);
  end;
end;

function Tvsagps_device_tcp_nmea.WorkingThread_SendPacket: Boolean;
var
  s: AnsiString;
  VLastError: DWORD;
  VIsGpsd: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_SendPacket: begin');
{$ifend}

  Result:=TRUE;
  VLastError:=0;
  VIsGpsd:=FALSE;

  // gpsd detection: the probe only reads the greeting (an explicit
  // [TCP] start_query disables the detection - the user knows what the
  // server needs)
  if (sq_Default=FStartQueryKind) then begin
    VIsGpsd:=Probe_Server_Greeting;
    // the device is closing - do not send anything
    if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
      Result:=FALSE;
      Exit;
    end;
  end;

  // at most one start message per session: only gpsd needs one (the WATCH
  // subscription), a plain nmea server streams by itself and nothing is
  // written to it; an explicit [TCP] start_query replaces both behaviors
  case FStartQueryKind of
    sq_None: begin
      // [TCP] start_query= (empty value) - nothing is sent at all
    end;
    sq_Custom: begin
      // [TCP] start_query - sent as is, without the checksum wrapping (the
      // gpsd WATCH commands and the like are not nmea sentences); only the
      // line end CR LF is appended - the servers read the commands by lines
      s:=FStartQueryCustom+cNmea_Tail;
      Result:=Send_NmeaTcp_Packet(s, VLastError);
    end;
    else begin
      // default: gpsd announces itself right after the connection is
      // accepted and streams nothing until the WATCH command; a regular
      // nmea server streams immediately, so nothing is sent to it
      if VIsGpsd then
        Result:=Send_NmeaTcp_Packet(cGpsd_Watch_Command+cNmea_Tail, VLastError);
    end;
  end;

  if (not Result) then
    InternalSetCommunicationError(VLastError);

  // the idle watchdog counts from the established session and not from the
  // connect: the gpsd probe (and the start message, if any) take time
  FLastDataTick:=GetTickCount;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_SendPacket: end');
{$ifend}
end;

function Tvsagps_device_tcp_nmea.WorkingThread_StartSession: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_StartSession: begin');
{$ifend}

  Result:=FALSE;

  // the connection is established by Internal_Before_Open_Device (the same
  // working thread, see there): the device handle is already published, so
  // the session may start only when the socket is really there. This is a
  // sanity check only: FSocket is read without the socket mutex (a single
  // aligned read, nothing is done with the value; every real socket call
  // below re-reads it under the mutex)
  if (INVALID_SOCKET=FSocket) then begin
    if (0=FWT_Params.dwLastError) then
      FWT_Params.dwLastError:=WSAENOTCONN;
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_StartSession: no socket');
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
  VSAGPS_DebugAnsiString('Tvsagps_device_tcp_nmea.WorkingThread_StartSession: Done');
{$ifend}

  Result:=TRUE;
end;

end.
