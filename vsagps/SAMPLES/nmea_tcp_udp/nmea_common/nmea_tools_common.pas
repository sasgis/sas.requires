unit nmea_tools_common;
(*
  The code shared by the NMEA sample tools (nmea_server, nmea_client):
  the paired log (raw nmea bytes + timestamped event lines) and the udp
  socket helpers (the same listener-name grammar as the nmea udp device of
  the library). Not a part of the library itself - the unit compiles only
  into the sample executables.

  The winsock calls assume the application has done WSAStartup already.
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
  Classes,
  Winsock2,
  vsagps_winsock2_compat;

const
  // version 2.2 of the WinSock specification
  // (not taken from the winsock unit - the RTL unit does not declare it)
  cNmeaTool_WSA_Version_2_2 = $0202;

  // udp subscriber keepalive: an endpoint which sent no datagrams for this
  // long stops receiving the stream (the client tools send the datagrams
  // every 2 sec, the library udp device sends nothing - it is tested with
  // the fixed target address instead of the subscriptions)
  cNmeaTool_Subscriber_Timeout_MSec = 10000;

  // how often the client tools report themselves to the udp server
  cNmeaTool_Hello_Interval_MSec = 2000;

type
  // the paired log of the sample tools:
  // - the event lines are timestamped once and kept pending until the owner
  //   drains them (the owner thread shows them in the memo and this class
  //   appends them to the event file); the pending list may be filled from
  //   the worker threads - all the access is serialized;
  // - the raw nmea bytes are buffered and flushed to the nmea file by the
  //   owner timer (the same bytes which went to the wire, no formatting);
  // - both files are opened on demand (a fresh file per run, then reopened
  //   with the shared access so it can be read/tailed while the tool runs);
  //   any file error switches the corresponding logging off instead of
  //   breaking the tool, the reason is reported as an event line
  TNmeaToolLog = class
  private
    FLock: TRTLCriticalSection;
    FEventPending: TStringList; // timestamped lines waiting for the drain
    FNmeaBuf: TMemoryStream;    // raw nmea bytes waiting for the file
    FNmeaFile: TFileStream;
    FEventFile: TFileStream;
    FNmeaLogName: string;
    FEventLogName: string;
    FNmeaLogFresh: Boolean;     // the file is created (not appended) on the next open
    FEventLogFresh: Boolean;
    FNmeaEnabled: Boolean;
    FEventEnabled: Boolean;
  private
    procedure Lock;
    procedure Unlock;
    function OpenLogStream(const AFileName: string; const AFresh: Boolean): TFileStream;
    procedure WriteEventFileLocked(const AList: TStrings);
    procedure WriteNmeaFileLocked(const AData: AnsiString);
  public
    constructor Create(const ANmeaLogName, AEventLogName: string);
    destructor Destroy; override;
    // the enable flags mirror the logging checkboxes; disabling flushes and
    // closes the corresponding file (the reopen starts a fresh file)
    procedure SetNmeaEnabled(const AValue: Boolean);
    procedure SetEventEnabled(const AValue: Boolean);
    function GetNmeaEnabled: Boolean;
    function GetEventEnabled: Boolean;
    // one timestamped event line into the pending list (thread-safe)
    procedure LogEvent(const S: string);
    // raw nmea bytes into the buffer (thread-safe)
    procedure LogNmeaRaw(const AData: AnsiString);
    // swap the pending event lines out (the caller shows them in the memo)
    procedure DrainEvents(const AList: TStrings);
    // append the given (already drained) lines to the event file
    procedure WriteEventFile(const AList: TStrings);
    // write the buffered raw nmea bytes to the file
    procedure FlushNmeaFile;
    property NmeaLogName: string read FNmeaLogName;
    property EventLogName: string read FEventLogName;
  end;

// the "last colon" split of the nmea udp name: "host:port" (the host of the
// "[::1]" form is unbracketed), ":port" or a bare "port" (the wildcard);
// the port must be numeric 1..65535
function NmeaTool_SplitHostPort(const AName: AnsiString;
                                out AHost: AnsiString;
                                out APort: Integer): Boolean;

// resolve a udp send target ("addr:port" or "group:port"; a bare port is
// meaningless as a target); returns the first resolved ipv4 address
function NmeaTool_ResolveUdpTarget(const AName: AnsiString;
                                   out AAddr: TSockAddrIn;
                                   out ALastError: Integer): Boolean;

// create+bind the udp listener socket by the nmea udp device name grammar
// ("port"/":port"/"0.0.0.0:port" - the wildcard, "addr:port" - the given
// local address, "group:port" - the ipv4 multicast group 224/4: the wildcard
// port bind + the group join; the options are set before the bind:
// SO_REUSEADDR for the multicast path, SO_EXCLUSIVEADDRUSE for the other
// paths - an occupied port reports WSAEADDRINUSE instead of the silent
// SO_REUSEADDR hijacking). Returns INVALID_SOCKET with ALastError set
function NmeaTool_CreateUdpListener(const AName: AnsiString;
                                    out ALastError: Integer): TSocket;

// "a.b.c.d:port" of an ipv4 sockaddr (the same format the tools log)
function NmeaTool_PeerOf(const AAddr: TSockAddrIn): string;

implementation

uses
  vsagps_public_sysutils;

const
  // IP_ADD_MEMBERSHIP from ws2ipdef.h - the current Windows SDK value (the
  // RTL Winapi.WinSock unit declares the obsolete 5, a real join with it
  // fails with WSAENOPROTOOPT; the RTL Winapi.Winsock2 declares no IP
  // socket options at all)
  cNmeaTool_IP_Add_Membership = 12;

type
  // ip_mreq from ws2tcpip.h - not declared in the RTL Winsock units
  TNmeaToolIpMreq = record
    imr_multiaddr: in_addr;
    imr_interface: in_addr;
  end;

{ TNmeaToolLog }

procedure TNmeaToolLog.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TNmeaToolLog.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

constructor TNmeaToolLog.Create(const ANmeaLogName, AEventLogName: string);
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FEventPending := TStringList.Create;
  FNmeaBuf := TMemoryStream.Create;
  FNmeaFile := nil;
  FEventFile := nil;
  FNmeaLogName := ANmeaLogName;
  FEventLogName := AEventLogName;
  FNmeaLogFresh := TRUE;
  FEventLogFresh := TRUE;
  FNmeaEnabled := FALSE;
  FEventEnabled := FALSE;
end;

destructor TNmeaToolLog.Destroy;
begin
  FlushNmeaFile;
  FreeAndNil(FNmeaFile);
  FreeAndNil(FEventFile);
  FreeAndNil(FNmeaBuf);
  FreeAndNil(FEventPending);
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TNmeaToolLog.SetNmeaEnabled(const AValue: Boolean);
begin
  if (AValue = FNmeaEnabled) then
    Exit;
  FNmeaEnabled := AValue;
  if (not AValue) then begin
    // flush what is still buffered before the file is closed
    FlushNmeaFile;
    FreeAndNil(FNmeaFile);
  end;
end;

procedure TNmeaToolLog.SetEventEnabled(const AValue: Boolean);
begin
  if (AValue = FEventEnabled) then
    Exit;
  FEventEnabled := AValue;
  if (not AValue) then
    FreeAndNil(FEventFile);
end;

function TNmeaToolLog.GetNmeaEnabled: Boolean;
begin
  Result := FNmeaEnabled;
end;

function TNmeaToolLog.GetEventEnabled: Boolean;
begin
  Result := FEventEnabled;
end;

procedure TNmeaToolLog.LogEvent(const S: string);
begin
  Lock;
  try
    FEventPending.Append('[' + FormatDateTime('hh:nn:ss.zzz', Now) + '] ' + S);
  finally
    Unlock;
  end;
end;

procedure TNmeaToolLog.LogNmeaRaw(const AData: AnsiString);
begin
  if (0 = Length(AData)) or (not FNmeaEnabled) then
    Exit;
  Lock;
  try
    FNmeaBuf.WriteBuffer(PAnsiChar(AData)^, Length(AData));
  finally
    Unlock;
  end;
end;

procedure TNmeaToolLog.DrainEvents(const AList: TStrings);
begin
  Lock;
  try
    AList.Assign(FEventPending);
    FEventPending.Clear;
  finally
    Unlock;
  end;
end;

// open a log file for appending: a fresh file for every run, then the file
// is reopened with the shared mode so it can be read/tailed while running
function TNmeaToolLog.OpenLogStream(const AFileName: string; const AFresh: Boolean): TFileStream;
var
  VTemp: TFileStream;
begin
  if AFresh or (not FileExists(AFileName)) then begin
    // fmCreate creates the file with the exclusive access
    VTemp := TFileStream.Create(AFileName, fmCreate);
    VTemp.Free;
  end;
  Result := TFileStream.Create(AFileName, fmOpenReadWrite or fmShareDenyNone);
  try
    Result.Seek(0, soEnd);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TNmeaToolLog.WriteEventFile(const AList: TStrings);
begin
  if (0 = AList.Count) or (not FEventEnabled) then
    Exit;
  Lock;
  try
    WriteEventFileLocked(AList);
  finally
    Unlock;
  end;
end;

procedure TNmeaToolLog.WriteEventFileLocked(const AList: TStrings);
var
  i: Integer;
  VData: UTF8String;
begin
  // the critical section is already locked
  if (0 = AList.Count) then
    Exit;
  VData := '';
  for i := 0 to AList.Count - 1 do
    VData := VData + UTF8String(AList[i] + #13#10);
  try
    if (FEventFile = nil) then begin
      FEventFile := OpenLogStream(FEventLogName, FEventLogFresh);
      FEventLogFresh := FALSE;
    end;
    FEventFile.WriteBuffer(PAnsiChar(VData)^, Length(VData));
  except
    on E: Exception do begin
      FreeAndNil(FEventFile);
      FEventEnabled := FALSE;
      // the file is not available - the reason stays in the pending list
      // for the memo (the event file is disabled, so it is never written)
      FEventPending.Append('[' + FormatDateTime('hh:nn:ss.zzz', Now) +
        '] event log file "' + FEventLogName + '" failed, logging disabled: ' + E.Message);
    end;
  end;
end;

procedure TNmeaToolLog.FlushNmeaFile;
var
  VData: AnsiString;
begin
  Lock;
  try
    if (0 = FNmeaBuf.Size) then
      Exit;
    SetLength(VData, Integer(FNmeaBuf.Size));
    Move(FNmeaBuf.Memory^, PAnsiChar(VData)^, FNmeaBuf.Size);
    FNmeaBuf.Size := 0;
    WriteNmeaFileLocked(VData);
  finally
    Unlock;
  end;
end;

procedure TNmeaToolLog.WriteNmeaFileLocked(const AData: AnsiString);
begin
  // the critical section is already locked
  if (0 = Length(AData)) then
    Exit;
  try
    if (FNmeaFile = nil) then begin
      FNmeaFile := OpenLogStream(FNmeaLogName, FNmeaLogFresh);
      FNmeaLogFresh := FALSE;
    end;
    FNmeaFile.WriteBuffer(PAnsiChar(AData)^, Length(AData));
  except
    on E: Exception do begin
      FreeAndNil(FNmeaFile);
      FNmeaEnabled := FALSE;
      // the reason goes to the event lines (the event file may still work)
      FEventPending.Append('[' + FormatDateTime('hh:nn:ss.zzz', Now) +
        '] nmea log file "' + FNmeaLogName + '" failed, logging disabled: ' + E.Message);
    end;
  end;
end;

{ the udp name helpers }

function NmeaTool_SplitHostPort(const AName: AnsiString;
                                out AHost: AnsiString;
                                out APort: Integer): Boolean;
var
  iPos: Integer;
  sPort: AnsiString;
begin
  Result := FALSE;
  AHost := '';
  APort := 0;

  // the port goes after the last colon (for IPv6 literals the host part
  // must be enclosed in square brackets) - searched from the end without
  // copying the whole string
  iPos := Length(AName);
  while (0 < iPos) and (':' <> AName[iPos]) do
    Dec(iPos);
  if (0 = iPos) then begin
    // a bare port - the wildcard host
    AHost := '0.0.0.0';
    sPort := TrimA(AName);
  end else if (1 = iPos) then begin
    // ":port" - ditto
    AHost := '0.0.0.0';
    sPort := TrimA(System.Copy(AName, 2, Length(AName)));
  end else begin
    AHost := TrimA(System.Copy(AName, 1, iPos - 1));
    sPort := TrimA(System.Copy(AName, iPos + 1, Length(AName)));
    // allow "[::1]:10110" (with brackets) for IPv6 literals
    if (1 < Length(AHost)) and ('[' = AHost[1]) and (']' = AHost[Length(AHost)]) then
      AHost := System.Copy(AHost, 2, Length(AHost) - 2);
  end;

  // the port is validated here: a non numeric value would be passed to
  // getaddrinfo as a service name and reported as a resolution error
  if (0 = Length(AHost)) or (0 = Length(sPort)) then
    Exit;
  if (not TryStrToIntA(sPort, APort)) or (APort < 1) or (65535 < APort) then begin
    APort := 0;
    Exit;
  end;
  Result := TRUE;
end;

function NmeaTool_ResolveUdpTarget(const AName: AnsiString;
                                   out AAddr: TSockAddrIn;
                                   out ALastError: Integer): Boolean;
var
  VWSA: TWSAData;
  sHost: AnsiString;
  VPort: Integer;
  VHints: TAddrInfoA;
  VAddrList: Paddrinfo;
  VRes: Integer;
begin
  Result := FALSE;
  ALastError := 0;
  ZeroMemory(@AAddr, sizeof(AAddr));

  if (not NmeaTool_SplitHostPort(TrimA(AName), sHost, VPort)) then begin
    ALastError := 87; // ERROR_INVALID_PARAMETER
    Exit;
  end;
  if (0 = Length(sHost)) or ('0.0.0.0' = sHost) then begin
    // a wildcard or a bare port is meaningless as a send target
    ALastError := 87;
    Exit;
  end;

  // the reference counter of the WinSock provider allows any number of
  // nested WSAStartup/WSACleanup pairs (the caller may have started it too)
  VRes := WSAStartup(cNmeaTool_WSA_Version_2_2, VWSA);
  if (0 <> VRes) then begin
    ALastError := VRes;
    Exit;
  end;
  try
    // the send targets are ipv4 only (the tools are desktop test utilities)
    FillChar(VHints, sizeof(VHints), 0);
    VHints.ai_family := AF_INET;
    VHints.ai_socktype := SOCK_DGRAM;
    VHints.ai_protocol := IPPROTO_UDP;

    // getaddrinfo returns the error code itself (the EAI_ constants are
    // the WSA codes on Windows), WSAGetLastError is meaningless here
    VRes := getaddrinfo(PAnsiChar(sHost), PAnsiChar(AnsiString(IntToStr(VPort))), VHints, VAddrList);
    if (0 <> VRes) then begin
      ALastError := VRes;
      Exit;
    end;
    try
      if (nil = VAddrList) then begin
        ALastError := 87;
        Exit;
      end;
      Move(VAddrList^.ai_addr^, AAddr, VAddrList^.ai_addrlen);
      Result := TRUE;
    finally
      freeaddrinfo(VAddrList^);
    end;
  finally
    WSACleanup;
  end;
end;

function NmeaTool_CreateUdpListener(const AName: AnsiString;
                                    out ALastError: Integer): TSocket;
var
  VWSA: TWSAData;
  sHost: AnsiString;
  VPort: Integer;
  VHints: TAddrInfoA;
  VAddrList, VAddr: Paddrinfo;
  VSin: PSockAddrIn;
  VBindSin: TSockAddrIn;
  VMReq: TNmeaToolIpMreq;
  VSocket: TSocket;
  VOptName, VOptValue, VRes: Integer;
  VIsMulticast: Boolean;
begin
  Result := INVALID_SOCKET;
  ALastError := 0;

  if (not NmeaTool_SplitHostPort(TrimA(AName), sHost, VPort)) then begin
    ALastError := 87; // ERROR_INVALID_PARAMETER
    Exit;
  end;

  VRes := WSAStartup(cNmeaTool_WSA_Version_2_2, VWSA);
  if (0 <> VRes) then begin
    ALastError := VRes;
    Exit;
  end;
  try
    // resolve the name (the wildcard resolves to itself, a hostname to its
    // addresses - the first resolved address is used); getaddrinfo is a
    // synchronous system call, it can not be interrupted
    FillChar(VHints, sizeof(VHints), 0);
    VHints.ai_family := AF_UNSPEC;
    VHints.ai_socktype := SOCK_DGRAM;
    VHints.ai_protocol := IPPROTO_UDP;

    VRes := getaddrinfo(PAnsiChar(sHost), PAnsiChar(AnsiString(IntToStr(VPort))), VHints, VAddrList);
    if (0 <> VRes) then begin
      ALastError := VRes;
      Exit;
    end;

    VSocket := INVALID_SOCKET;
    try
      VAddr := VAddrList;
      if (nil = VAddr) then begin
        ALastError := 87;
        Exit;
      end;

      // multicast detection: an IPv4 class D address (224.0.0.0/4) is a
      // multicast group - the socket is bound to the wildcard port (a group
      // address can not be bound on Windows) and the group is joined below.
      // IPv6 multicast is not supported - the plain bind succeeds for a
      // group address too, but nothing ever arrives
      VIsMulticast := FALSE;
      if (AF_INET = VAddr^.ai_family) then begin
        VSin := PSockAddrIn(VAddr^.ai_addr);
        VIsMulticast := ($E = (ntohl(VSin^.sin_addr.S_addr) shr 28));
      end;

      // create the socket
      VSocket := socket(VAddr^.ai_family, SOCK_DGRAM, IPPROTO_UDP);
      if (INVALID_SOCKET = VSocket) then begin
        ALastError := WSAGetLastError;
        Exit;
      end;

      // the socket options must be set before the bind (the same choice as
      // in the nmea udp device of the library):
      // - a multicast listener shares the port with the other group
      //   listeners (SO_REUSEADDR allows the second bind on the address);
      // - the other listeners claim the address exclusively (an occupied
      //   port is reported instead of a silent address hijacking)
      if VIsMulticast then begin
        VOptName := SO_REUSEADDR;
        VOptValue := 1;
      end else begin
        VOptName := Integer(SO_EXCLUSIVEADDRUSE);
        VOptValue := 1;
      end;
      if (0 <> setsockopt(VSocket, SOL_SOCKET, VOptName, @VOptValue, sizeof(VOptValue))) then begin
        ALastError := WSAGetLastError;
        Exit;
      end;

      // bind the local address (the wildcard for the multicast)
      if VIsMulticast then begin
        ZeroMemory(@VBindSin, sizeof(VBindSin));
        VBindSin.sin_family := AF_INET;
        VBindSin.sin_port := PSockAddrIn(VAddr^.ai_addr)^.sin_port; // resolved port, network byte order
        VBindSin.sin_addr.S_addr := INADDR_ANY;
        if (0 <> bind(VSocket, PSockAddr(@VBindSin)^, sizeof(VBindSin))) then begin
          ALastError := WSAGetLastError;
          Exit;
        end;
      end else begin
        if (0 <> bind(VSocket, VAddr^.ai_addr^, Integer(VAddr^.ai_addrlen))) then begin
          ALastError := WSAGetLastError;
          Exit;
        end;
      end;

      // join the multicast group on the default multicast interface; the
      // membership dies with the socket (no IP_DROP_MEMBERSHIP is needed)
      if VIsMulticast then begin
        ZeroMemory(@VMReq, sizeof(VMReq));
        VMReq.imr_multiaddr := PSockAddrIn(VAddr^.ai_addr)^.sin_addr;
        VMReq.imr_interface.S_addr := INADDR_ANY;
        if (0 <> setsockopt(VSocket, IPPROTO_IP, cNmeaTool_IP_Add_Membership, @VMReq, sizeof(VMReq))) then begin
          // without the membership no group data ever arrives
          ALastError := WSAGetLastError;
          Exit;
        end;
      end;

      Result := VSocket;
      VSocket := INVALID_SOCKET; // owned by the caller now
    finally
      if (INVALID_SOCKET <> VSocket) then
        closesocket(VSocket);
      freeaddrinfo(VAddrList^);
    end;
  finally
    WSACleanup;
  end;
end;

function NmeaTool_PeerOf(const AAddr: TSockAddrIn): string;
begin
  Result := Format('%d.%d.%d.%d:%d', [
    Byte(AAddr.sin_addr.S_un_b.s_b1),
    Byte(AAddr.sin_addr.S_un_b.s_b2),
    Byte(AAddr.sin_addr.S_un_b.s_b3),
    Byte(AAddr.sin_addr.S_un_b.s_b4),
    ntohs(AAddr.sin_port)]);
end;

end.
