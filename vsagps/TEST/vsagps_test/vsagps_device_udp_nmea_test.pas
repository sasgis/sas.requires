unit vsagps_device_udp_nmea_test;

interface

uses
  TestFramework,
  Winsock2,
  vsagps_winsock2_compat,
  vsagps_test_watchdog,
  vsagps_public_device,
  vsagps_device_udp_nmea;

type
  Tvsagps_device_udp_nmea_test = class(Tvsagps_test_case)
  private
    // shared body of the device-direct "bind, receive and parse" tests: the
    // device works with a test-owned queue and the test parses the received
    // packets itself (the library packet thread is not involved here). When
    // nothing is expected, the queue is watched for cNegative_Wait_MSec, so
    // a datagram which should have been dropped is noticed
    procedure InternalDeviceBindParseAndFree(const ADeviceName: AnsiString;
                                             const APort: Word;
                                             const AGGAExpected, ARMCExpected: Boolean;
                                             const ADatagram, ADatagram2: AnsiString);
  published
    // full cycle: local udp sender -> device binds -> nmea datagrams ->
    // parser handlers; several sentences in one datagram
    procedure TestUdpDeviceConnectAndParse;
    // a bare port name ("10110") must bind the wildcard like "0.0.0.0:10110"
    procedure TestUdpDeviceBarePortName;
    // one sentence split between two datagrams - the shared stream framing
    // assembles it
    procedure TestUdpDeviceSentenceSplitAcrossDatagrams;
    // a datagram with no line end at all ("...*hh") - what the Arduino
    // udp.print() sources send - must be parsed
    procedure TestUdpDeviceNoLineEnd;
    // a datagram with bare LF line ends
    procedure TestUdpDeviceLfLineEnds;
    // a datagram with bare CR line ends
    procedure TestUdpDeviceCrLineEnd;
    // "localhost" must bind the IPv4 address (Windows resolves it to ::1
    // first) and receive the datagrams of the IPv4 sender
    procedure TestUdpDeviceLocalhost;
    // ";from=127.0.0.1" accepts the datagram of this sender
    procedure TestUdpDeviceSenderFilterAllow;
    // ";from=127.0.0.2" drops the datagram of the 127.0.0.1 sender
    procedure TestUdpDeviceSenderFilterReject;
    // a datagram bigger than the receive buffer must not end the session
    procedure TestUdpDeviceOversizedDatagram;
    // the names the device must refuse: a short IPv4 in the sender filter,
    // the multicast interface on a unicast address, an IPv6 group, the
    // all-ones broadcast address
    procedure TestUdpDeviceRejectedNames;
    // a silent source (no datagrams at all) must be ended by the idle data
    // watchdog, so the caller sees a disconnect and can re-bind (udp has no
    // connection loss notification at all)
    procedure TestUdpDeviceIdleWatchdog;
    // an occupied port must be detected at once (WSAEADDRINUSE on bind) and
    // must not look like a session
    procedure TestUdpDeviceBindError;
    // closing the device while the datagrams are arriving must complete the
    // waited disconnect quickly
    procedure TestUdpDeviceCloseDuringReceive;
    // a multicast group name ("239.x.x.y:port") - the device binds the
    // wildcard port and joins the group, a looped multicast datagram is
    // received
    procedure TestUdpDeviceMulticastGroup;
    // the common factory branch: Tvsagps_object.GPSConnect(gdt_UDP_NMEA0183)
    // creates the udp device, the library machinery delivers the sentences
    // to the user handlers
    procedure TestUdpObjectFactorySmoke;
  end;

implementation

uses
  Windows,
  SysUtils,
  Classes,
  vsagps_public_base,
  vsagps_public_memory,
  vsagps_public_types,
  vsagps_device_base,
  vsagps_queue,
  vsagps_units,
  vsagps_object;

const
  // waiting limits for the background threads
  cConnect_Wait_Timeout_MSec = 15000;
  cParse_Wait_Timeout_MSec   = 15000;

  // the bind of an occupied port fails at once; the device must report the
  // finish reason much faster than the connection timeout
  cBindError_Detect_Timeout_MSec = 5000;

  // btReceiveGPSTimeoutSec=2 in the idle test: a silent socket must be
  // ended by the idle watchdog well before this limit
  cIdle_Wait_Timeout_MSec = 8000;

  // btReceiveGPSTimeoutSec=2 in the idle test: the silence must be counted
  // from the session start, so a disconnect sooner than this after the
  // session start callback means that the connecting phase was counted as
  // the silence
  cIdle_Min_Timeout_MSec = 1850;

  // how long to wait for the session start callback (it fires on the device
  // working thread right after the bind - there is no probe for udp)
  cSession_Wait_Timeout_MSec = 5000;

  // how long to wait for the connected state report of the units state
  // machine (its poll interval is the worker thread timeout)
  cState_Wait_Timeout_MSec = 5000;

  // the waited disconnect of a receiving device (the receive loop checks
  // the exit flag between its 100 msec slices)
  cClose_Wait_Timeout_MSec = 5000;

  // how long the device-direct "nothing must be parsed" checks observe the
  // queue: a datagram of a stranger may arrive at any moment, so a short
  // observation window is needed to notice the mistake
  cNegative_Wait_MSec       = 1500;

  // verified nmea sentences (checksums are correct)
  cNmea_GGA = '$GPGGA,123519.00,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*69';
  cNmea_RMC = '$GPRMC,123519.00,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W,A*29';

  // the multicast group for the join test (organization-local scope, an
  // address which no real source would send to)
  cTest_Multicast_Group = '239.255.42.1';

var
  // counters incremented from the nmea handlers
  g_GGA_Packets: Integer;
  g_RMC_Packets: Integer;
  g_SessionStarted: Integer;

  // temporary diagnostics
  g_StateChanges: Integer;
  // how many times the "connected" state was reported; a failed bind must
  // never reach it (the library used to report it from the fake device
  // handle before the bind attempt was over)
  g_ConnectedStates: Integer;

{ handlers for the nmea packets }

procedure GPSStateChange_Handler(const pUserPointer: Pointer;
                                 const btUnitIndex: Byte;
                                 const dwGPSDevType: DWORD;
                                 const eNewState: Tvsagps_GPSState); stdcall;
begin
  InterlockedIncrement(g_StateChanges);
  if (gs_DoneConnected=eNewState) then
    InterlockedIncrement(g_ConnectedStates);
end;


procedure SessionStarted_Handler(const pUserPointer: Pointer;
                                 const btUnitIndex: Byte;
                                 const dwGPSDevType: DWORD;
                                 const pdwReserved: PDWORD); stdcall;
begin
  InterlockedIncrement(g_SessionStarted);
end;

function NMEA_GGA_Handler(const pUserPointer: Pointer;
                          const btUnitIndex: Byte;
                          const dwPacketType: DWORD;
                          const pNmeaData: PNMEA_GGA): DWORD; stdcall;
begin
  InterlockedIncrement(g_GGA_Packets);
  Result:=0;
end;

function NMEA_RMC_Handler(const pUserPointer: Pointer;
                          const btUnitIndex: Byte;
                          const dwPacketType: DWORD;
                          const pNmeaData: PNMEA_RMC): DWORD; stdcall;
begin
  InterlockedIncrement(g_RMC_Packets);
  Result:=0;
end;

{ helpers }

// make an udp socket bound to the loopback on an ephemeral port; the port
// is assigned by the system and returned via APort. AExclusive (set before
// the bind) makes this socket an exclusive owner of the address - the
// occupied port test relies on it
function MakeBoundUdpSocket(const AExclusive: Boolean; out APort: Word): TSocket;
var
  VAddr: TSockAddr;
  VAddrLen: Integer;
  VOptValue: Integer;
begin
  Result:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (INVALID_SOCKET=Result) then
    Exit;

  // the exclusive ownership must be claimed before the bind
  if AExclusive then begin
    VOptValue:=Integer(SO_EXCLUSIVEADDRUSE);
    if (0<>setsockopt(Result, SOL_SOCKET, VOptValue, @VOptValue, sizeof(VOptValue))) then begin
      closesocket(Result);
      Result:=INVALID_SOCKET;
      Exit;
    end;
  end;

  // bind to the loopback interface (127.0.0.1) on an ephemeral port (port
  // = 0 - let the system choose)
  FillChar(VAddr, sizeof(VAddr), 0);
  VAddr.sa_family:=AF_INET;
  VAddr.sa_data[0]:=AnsiChar(0);   // port = 0 (high byte)
  VAddr.sa_data[1]:=AnsiChar(0);   // port = 0 (low byte)
  VAddr.sa_data[2]:=AnsiChar(127); // 127.0.0.1 in the network byte order
  VAddr.sa_data[3]:=AnsiChar(0);
  VAddr.sa_data[4]:=AnsiChar(0);
  VAddr.sa_data[5]:=AnsiChar(1);

  if (0<>bind(Result, VAddr, sizeof(VAddr))) then begin
    closesocket(Result);
    Result:=INVALID_SOCKET;
    Exit;
  end;

  // query the actual port assigned by the system
  VAddrLen:=sizeof(VAddr);
  if (0<>getsockname(Result, VAddr, VAddrLen)) then begin
    closesocket(Result);
    Result:=INVALID_SOCKET;
    Exit;
  end;
  // the port is in the network byte order (big-endian)
  APort:=Word((Byte(VAddr.sa_data[0]) shl 8) or Byte(VAddr.sa_data[1]));
end;

// a udp socket for sending (an ephemeral local port, not bound explicitly)
function MakeUdpSenderSocket: TSocket;
begin
  Result:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
end;

// fill a sockaddr_in with the given ipv4 address string and port
function MakeUdpAddr(const AAddr: AnsiString; const APort: Word): TSockAddrIn;
var
  VHints: TAddrInfoA;
  VAddrList: Paddrinfo;
  VRes: Integer;
begin
  ZeroMemory(@Result, sizeof(Result));
  FillChar(VHints, sizeof(VHints), 0);
  VHints.ai_family:=AF_INET;
  VHints.ai_socktype:=SOCK_DGRAM;
  VHints.ai_protocol:=IPPROTO_UDP;
  VRes:=getaddrinfo(PAnsiChar(AAddr), PAnsiChar(AnsiString(IntToStr(APort))), VHints, VAddrList);
  if (0<>VRes) or (nil=VAddrList) then
    raise Exception.Create('getaddrinfo failed for the test address');
  try
    Move(VAddrList^.ai_addr^, Result, VAddrList^.ai_addrlen);
  finally
    freeaddrinfo(VAddrList^);
  end;
end;

// send the whole datagram to the given address
procedure UdpSendTo(const ASocket: TSocket;
                    const AData: AnsiString;
                    const ASin: TSockAddrIn);
var
  P: PByte;
begin
  P:=Pointer(AData);
  if (SOCKET_ERROR=sendto(ASocket, P^, Length(AData), 0, PSockAddr(@ASin), sizeof(ASin))) then
    raise Exception.Create('sendto to the test address failed');
end;

// reset the handler counters
procedure ResetCounters;
begin
  g_GGA_Packets:=0;
  g_RMC_Packets:=0;
  g_SessionStarted:=0;
  g_StateChanges:=0;
  g_ConnectedStates:=0;
end;

// wait until the session start callback fires (on the device working thread)
function WaitForSessionStarted: Boolean;
var
  VTicks: DWORD;
begin
  VTicks:=GetTickCount;
  while (0=g_SessionStarted) and (GetTickCount-VTicks<cSession_Wait_Timeout_MSec) do
    Sleep(10);
  Result:=(0<g_SessionStarted);
end;

// wait until the device parses the expected sentences
procedure WaitForHandlers(const AGGAExpected, ARMCExpected: Boolean);
var
  VTicks: DWORD;
begin
  VTicks:=GetTickCount;
  while ((AGGAExpected and (0=g_GGA_Packets)) or
         (ARMCExpected and (0=g_RMC_Packets))) and
        (GetTickCount-VTicks<cParse_Wait_Timeout_MSec) do
    Sleep(50);
end;

// the default device params of the tests
procedure MakeTestParams(out AParams: TVSAGPS_ALL_DEVICE_PARAMS);
begin
  ZeroMemory(@AParams, sizeof(AParams));
  with AParams do begin
    wSize:=sizeof(AParams);
    btAutodetectOnConnect:=0;
    btReceiveGPSTimeoutSec:=10;
    wConnectionTimeoutSec:=10;
    wWorkerThreadTimeoutMSec:=50;
    dwAutodetectFlags:=0;
    dwDeviceFlagsOut:=0;
    iBaudRate:=-1;
  end;
end;

// a free udp port for a listener: the holder socket is closed before the
// device binds the same port
function GetFreeUdpPort: Word;
var
  VHolder: TSocket;
begin
  VHolder:=MakeBoundUdpSocket(FALSE, Result);
  if (INVALID_SOCKET=VHolder) then
    raise Exception.Create('MakeBoundUdpSocket failed');
  closesocket(VHolder);
end;

// bind the given name: the device must report a finish reason (a wrong name
// is refused before any data arrives) and must not start a session
function DeviceRejected(const ADeviceName: AnsiString): Boolean;
var
  VDev: Tvsagps_device_udp_nmea;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VTicks: DWORD;
begin
  ResetCounters;

  MakeTestParams(VParams);
  VParams.pSessionStartedHandler:=SessionStarted_Handler;

  VDev:=Tvsagps_device_udp_nmea.Create;
  try
    VDev.SetBaseParams(0, 0, nil, ADeviceName, @VParams, nil, nil, nil, nil);
    VDev.Connect;

    VTicks:=GetTickCount;
    while (0=VDev.FinishReason) and (GetTickCount-VTicks<cBindError_Detect_Timeout_MSec) do
      Sleep(10);
    Result:=(0<>VDev.FinishReason) and (0=g_SessionStarted);
  finally
    VDev.Free;
  end;
end;

// extract all queued packets and parse them with the device (the device-
// direct tests replace the library packet parser thread with this pump)
procedure PumpQueueIntoParser(const AQueue: Tvsagps_queue;
                              const ADev: Tvsagps_device_udp_nmea);
var
  VPacket: Pointer;
  VUnitIndex: Byte;
begin
  while AQueue.ExtractGPSPacket(VPacket, VUnitIndex) do begin
    if (nil<>VPacket) then
    try
      ADev.ParsePacket(VPacket);
    finally
      VSAGPS_FreeMem(VPacket);
    end;
  end;
end;

{ Tvsagps_device_udp_nmea_test }

procedure Tvsagps_device_udp_nmea_test.InternalDeviceBindParseAndFree(const ADeviceName: AnsiString;
                                                                      const APort: Word;
                                                                      const AGGAExpected, ARMCExpected: Boolean;
                                                                      const ADatagram, ADatagram2: AnsiString);
var
  VWSA: TWSAData;
  VSender: TSocket;
  VDev: Tvsagps_device_udp_nmea;
  VQueue: Tvsagps_queue;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VSin: TSockAddrIn;
  VTicks: DWORD;
begin
  // winsock for the test sender
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    ResetCounters;

    MakeTestParams(VParams);
    VParams.pSessionStartedHandler:=SessionStarted_Handler;
    VParams.pNMEA_GGA_HANDLER:=NMEA_GGA_Handler;
    VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

    // the device works with a test-owned queue: the working thread puts the
    // received datagrams there and the test parses them itself - the library
    // packet thread is not involved, so no library thread can outlive the
    // test (the device working thread is a raw win32 thread stopped by the
    // destructor)
    VQueue:=Tvsagps_queue.Create;
    VDev:=Tvsagps_device_udp_nmea.Create;
    try
      VDev.SetBaseParams(0, 0, VQueue, ADeviceName, @VParams, nil, nil, nil, nil);
      VDev.Connect;

      // the bind is instant - there is no connecting phase to wait for
      Check(WaitForSessionStarted, 'session was not started');

      // emulate a udp nmea source
      VSender:=MakeUdpSenderSocket;
      try
        VSin:=MakeUdpAddr('127.0.0.1', APort);

        // the first datagram (the second one is optional - a sentence
        // split between datagrams is sent in two parts)
        UdpSendTo(VSender, ADatagram, VSin);
        if (0<Length(ADatagram2)) then begin
          Sleep(20); // let the first part arrive as its own datagram
          UdpSendTo(VSender, ADatagram2, VSin);
        end;
      finally
        closesocket(VSender);
      end;

      // pump the queue into the parser until the expected handlers fire
      // (when nothing is expected, watch the queue for a short while: a
      // datagram which should have been dropped must not reach the parser)
      VTicks:=GetTickCount;
      repeat
        PumpQueueIntoParser(VQueue, VDev);
        if AGGAExpected or ARMCExpected then begin
          if ((not AGGAExpected) or (0<g_GGA_Packets)) and
             ((not ARMCExpected) or (0<g_RMC_Packets)) then
            Break;
        end else if (GetTickCount-VTicks>=cNegative_Wait_MSec) then
          Break;
        Sleep(10);
      until (GetTickCount-VTicks>=cParse_Wait_Timeout_MSec);

      if AGGAExpected then
        Check(0<g_GGA_Packets, 'GGA handler was not called');
      if ARMCExpected then
        Check(0<g_RMC_Packets, 'RMC handler was not called');
      // nothing is expected only by the negative checks: the datagram must
      // not be parsed at all (it was dropped by the sender filter)
      if (not AGGAExpected) and (not ARMCExpected) then begin
        Check(0=g_GGA_Packets, 'GGA was parsed, the datagram must be dropped');
        Check(0=g_RMC_Packets, 'RMC was parsed, the datagram must be dropped');
      end;
    finally
      VDev.Free;
      VQueue.Free;
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceConnectAndParse;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // get a free udp port for the listener (the holder socket is closed
    // before the device binds the same port)
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    // two sentences in one datagram
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)),
      VPort,
      TRUE, TRUE,
      AnsiString(cNmea_GGA)+#13#10+cNmea_RMC+#13#10,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceBarePortName;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    // a bare port - the wildcard bind; the sender sends to the loopback
    // (the wildcard listener receives the unicast to any interface)
    InternalDeviceBindParseAndFree(
      AnsiString(IntToStr(VPort)),
      VPort,
      TRUE, FALSE,
      AnsiString(cNmea_GGA)+#13#10,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceSentenceSplitAcrossDatagrams;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
  VSentence: AnsiString;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    // the sentence is cut in the middle of its body: the framing must
    // assemble it from the two datagrams
    VSentence:=AnsiString(cNmea_RMC)+#13#10;
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)),
      VPort,
      FALSE, TRUE,
      System.Copy(VSentence, 1, Length(VSentence) div 2),
      System.Copy(VSentence, Length(VSentence) div 2 + 1, Length(VSentence)));
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceNoLineEnd;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // the sentence is the whole datagram and has no line end at all
    // (udp.print() of the Arduino sketches): the device must complete it
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)),
      VPort,
      TRUE, FALSE,
      AnsiString(cNmea_GGA),
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceLfLineEnds;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // bare LF line ends (a source which prints with "\n"): both sentences
    // of the datagram must be parsed
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)),
      VPort,
      TRUE, TRUE,
      AnsiString(cNmea_GGA)+#10+cNmea_RMC+#10,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceCrLineEnd;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // bare CR line ends (a source which prints with "\r" only): both
    // sentences of the datagram must be parsed, the CR is not a terminator
    // of the shared framing by itself
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)),
      VPort,
      TRUE, TRUE,
      AnsiString(cNmea_GGA)+#13+cNmea_RMC+#13,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceLocalhost;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // "localhost" resolves to ::1 first on Windows: the device must bind the
    // IPv4 address, otherwise the IPv4 sender would never reach it
    InternalDeviceBindParseAndFree(
      AnsiString('localhost:'+IntToStr(VPort)),
      VPort,
      TRUE, FALSE,
      AnsiString(cNmea_GGA)+#13#10,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceSenderFilterAllow;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // the sender (127.0.0.1) is in the list - the datagram is accepted
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)+';from=192.168.1.1,127.0.0.1'),
      VPort,
      TRUE, FALSE,
      AnsiString(cNmea_GGA)+#13#10,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceSenderFilterReject;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // the sender (127.0.0.1) is not in the list - the datagram must be
    // dropped and never reach the parser
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)+';from=127.0.0.2'),
      VPort,
      FALSE, FALSE,
      AnsiString(cNmea_GGA)+#13#10,
      '');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceOversizedDatagram;
var
  VWSA: TWSAData;
  VPort: Word;
  VBig: AnsiString;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // a datagram bigger than the receive buffer (a stray packet on the port
    // or a source with a wrong MTU): winsock drops it, the session must stay
    // alive - the next sentence is parsed
    VBig:=AnsiString(StringOfChar('A', 5000));
    InternalDeviceBindParseAndFree(
      AnsiString('127.0.0.1:'+IntToStr(VPort)),
      VPort,
      FALSE, TRUE,
      VBig,
      AnsiString(cNmea_RMC)+#13#10);
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceRejectedNames;
var
  VWSA: TWSAData;
  VPort: Word;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VPort:=GetFreeUdpPort;

    // a short IPv4 ("192.168.1") is not a valid sender address
    Check(DeviceRejected(AnsiString('127.0.0.1:'+IntToStr(VPort)+';from=192.168.1')),
          'a short IPv4 address in the sender filter is accepted');
    // an empty item at the end of the filter list
    Check(DeviceRejected(AnsiString('127.0.0.1:'+IntToStr(VPort)+';from=192.168.1.1,')),
          'an empty item in the sender filter is accepted');
    // the multicast interface makes no sense for a unicast address
    Check(DeviceRejected(AnsiString('127.0.0.1:'+IntToStr(VPort)+'@0.0.0.0')),
          'the multicast interface is accepted for a unicast address');
    // an IPv6 multicast group is not supported
    Check(DeviceRejected(AnsiString('[ff02::1]:'+IntToStr(VPort))),
          'an IPv6 multicast group is accepted');
    // a broadcast address can not be bound (the wildcard receives the
    // broadcasts instead)
    Check(DeviceRejected(AnsiString('255.255.255.255:'+IntToStr(VPort))),
          'the all-ones broadcast address is bound');
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceIdleWatchdog;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
  VDev: Tvsagps_device_udp_nmea;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VTicks: DWORD;
  VElapsed: DWORD;
begin
  // the device object is used directly: the library object has its own data
  // timeout which starts at the connect request and would hide the device
  // watchdog
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // a free udp port for the listener - nothing is ever sent to it (the
    // holder socket is closed before the device binds the same port)
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    g_SessionStarted:=0;
    g_GGA_Packets:=0;
    g_RMC_Packets:=0;

    MakeTestParams(VParams);
    VParams.btReceiveGPSTimeoutSec:=2; // the idle data watchdog timeout
    VParams.pSessionStartedHandler:=SessionStarted_Handler;

    VDev:=Tvsagps_device_udp_nmea.Create;
    try
      VDev.SetBaseParams(0,
                         0,
                         nil,
                         AnsiString('127.0.0.1:'+IntToStr(VPort)),
                         @VParams,
                         nil,
                         nil,
                         nil,
                         nil);
      VDev.Connect;

      // wait for the session start callback: it fires right after the bind
      // and the idle watchdog must count the silence from that moment
      Check(WaitForSessionStarted, 'session was not started');
      VTicks:=GetTickCount;

      // NOTE: nothing is ever sent here - the source is silent, only the
      // idle watchdog can end the session (udp has no FIN/RST to detect)
      while (0=VDev.FinishReason) and (GetTickCount-VTicks<cIdle_Wait_Timeout_MSec) do
        Sleep(10);
      VElapsed:=GetTickCount-VTicks;

      Check(0<>VDev.FinishReason,
            'the device is not disconnected after the idle timeout');
      Check(0=g_GGA_Packets, 'unexpected data on a silent port');
      // btReceiveGPSTimeoutSec=2 and the watchdog is checked every 50 msec:
      // the session can not be ended sooner than the timeout after the
      // session start
      Check(VElapsed>=cIdle_Min_Timeout_MSec,
            'the idle watchdog fired '+IntToStr(VElapsed)+
            ' msec after the session start (it counts the connecting phase?)');
    finally
      VDev.Free;
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceBindError;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
  VDev: Tvsagps_device_udp_nmea;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // occupy the loopback udp port exclusively - the device bind below to
    // the same address must fail (the exclusive flag is claimed inside the
    // helper before the bind)
    VHolder:=MakeBoundUdpSocket(TRUE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    try
      ResetCounters;

      MakeTestParams(VParams);
      VParams.pSessionStartedHandler:=SessionStarted_Handler;

      VDev:=Tvsagps_device_udp_nmea.Create;
      try
        VTicks:=GetTickCount;
        VDev.SetBaseParams(0,
                           0,
                           nil,
                           AnsiString('127.0.0.1:'+IntToStr(VPort)),
                           @VParams,
                           nil,
                           nil,
                           nil,
                           nil);
        VDev.Connect;

        // the port is occupied: the bind fails and the device ends the
        // (never started) session much faster than the connection timeout
        while (0=VDev.FinishReason) and (GetTickCount-VTicks<cBindError_Detect_Timeout_MSec) do
          Sleep(10);

        Check(0<>VDev.FinishReason,
              'the bind error is not reported as a finish reason');
        Check((GetTickCount-VTicks)<cBindError_Detect_Timeout_MSec,
              'an occupied port is not detected at once');

        // a failed bind must not be reported as a started session
        Check(0=g_SessionStarted, 'a session was started for an occupied port');
        Check(0=g_GGA_Packets, 'unexpected data after the bind error');
      finally
        VDev.Free;
      end;
    finally
      closesocket(VHolder);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceCloseDuringReceive;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
  VDev: Tvsagps_device_udp_nmea;
  VQueue: Tvsagps_queue;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VSender: TSocket;
  VSin: TSockAddrIn;
  VTicks: DWORD;
  VElapsed: DWORD;
  i: Integer;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    ResetCounters;

    MakeTestParams(VParams);
    VParams.pSessionStartedHandler:=SessionStarted_Handler;
    VParams.pNMEA_GGA_HANDLER:=NMEA_GGA_Handler;

    VQueue:=Tvsagps_queue.Create;
    VDev:=Tvsagps_device_udp_nmea.Create;
    try
      VDev.SetBaseParams(0, 0, VQueue, AnsiString('127.0.0.1:'+IntToStr(VPort)), @VParams, nil, nil, nil, nil);
      VDev.Connect;

      WaitForSessionStarted;

      // send a burst of datagrams and close the device while they (and the
      // silence after them) are being received: the waited disconnect must
      // complete quickly (the receive loop checks the exit flag between
      // its slices, it must not wait for the data idle timeout)
      VSender:=MakeUdpSenderSocket;
      try
        VSin:=MakeUdpAddr('127.0.0.1', VPort);
        for i := 1 to 10 do
          UdpSendTo(VSender, AnsiString(cNmea_GGA)+#13#10, VSin);
      finally
        closesocket(VSender);
      end;

      // the datagrams received before the close are parsed normally
      VTicks:=GetTickCount;
      repeat
        PumpQueueIntoParser(VQueue, VDev);
        if (0<g_GGA_Packets) then
          Break;
        Sleep(10);
      until (GetTickCount-VTicks>=cParse_Wait_Timeout_MSec);
      Check(0<g_GGA_Packets, 'the datagrams were not parsed before the close');

      // the close must not wait for the data idle timeout
      VTicks:=GetTickCount;
      VDev.Free;
      VElapsed:=GetTickCount-VTicks;
      Check(VElapsed<cClose_Wait_Timeout_MSec,
            'the device did not stop the receiving in time: '+
            IntToStr(VElapsed)+' msec');
    finally
      VQueue.Free;
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpDeviceMulticastGroup;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
  VDev: Tvsagps_device_udp_nmea;
  VQueue: Tvsagps_queue;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VSender: TSocket;
  VSin: TSockAddrIn;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    ResetCounters;

    MakeTestParams(VParams);
    VParams.pSessionStartedHandler:=SessionStarted_Handler;
    VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

    VQueue:=Tvsagps_queue.Create;
    VDev:=Tvsagps_device_udp_nmea.Create;
    try
      VDev.SetBaseParams(0, 0, VQueue, AnsiString(cTest_Multicast_Group+':'+IntToStr(VPort)), @VParams, nil, nil, nil, nil);
      VDev.Connect;

      WaitForSessionStarted;

      // send a multicast datagram: the sender does not join the group, the
      // looped packet must reach the joined device socket on this host
      VSender:=MakeUdpSenderSocket;
      try
        VSin:=MakeUdpAddr(cTest_Multicast_Group, VPort);
        UdpSendTo(VSender, AnsiString(cNmea_RMC)+#13#10, VSin);
      finally
        closesocket(VSender);
      end;

      // pump the queue into the parser until the handler fires
      VTicks:=GetTickCount;
      repeat
        PumpQueueIntoParser(VQueue, VDev);
        if (0<g_RMC_Packets) then
          Break;
        Sleep(10);
      until (GetTickCount-VTicks>=cParse_Wait_Timeout_MSec);

      Check(0<g_RMC_Packets, 'RMC handler was not called (the multicast datagram was not received)');
    finally
      VDev.Free;
      VQueue.Free;
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_udp_nmea_test.TestUdpObjectFactorySmoke;
var
  VWSA: TWSAData;
  VHolder: TSocket;
  VPort: Word;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VSender: TSocket;
  VSin: TSockAddrIn;
  VTicks: DWORD;
begin
  // the factory branch and the full library machinery (the device working
  // thread, the packet queue, the packet parser thread, the units state
  // machine). The teardown frees the object while the units are still
  // disconnecting (right after GPSDisconnect): the destructor terminates
  // the library threads and completes the disconnect itself, so no thread
  // outlives the object and no OnTerminate callback can fire on freed
  // memory (a callback of a freed object corrupts whatever the heap has
  // placed at that address when it is pumped by a later test)
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VHolder:=MakeBoundUdpSocket(FALSE, VPort);
    Check(VHolder<>INVALID_SOCKET, 'MakeBoundUdpSocket failed');
    closesocket(VHolder);

    ResetCounters;

    MakeTestParams(VParams);
    VParams.pSessionStartedHandler:=SessionStarted_Handler;
    VParams.pNMEA_GGA_HANDLER:=NMEA_GGA_Handler;
    VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

    VObj:=Tvsagps_object.Create;
    try
      VObj.OnGPSStateChanged:=GPSStateChange_Handler; // temporary diagnostics
      Check(VObj.GPSConnect(gdt_UDP_NMEA0183,
                            AnsiString('127.0.0.1:'+IntToStr(VPort)),
                            nil,
                            @VParams,
                            nil,
                            nil,
                            @VUnitIndex,
                            nil),
            'GPSConnect failed');

      // wait for the session start
      Check(WaitForSessionStarted, 'session was not started');

      // emulate a udp nmea source
      VSender:=MakeUdpSenderSocket;
      try
        VSin:=MakeUdpAddr('127.0.0.1', VPort);
        UdpSendTo(VSender, AnsiString(cNmea_GGA)+#13#10+cNmea_RMC+#13#10, VSin);
      finally
        closesocket(VSender);
      end;

      // wait until the library parses the sentences (the handlers are
      // called on the packet parser thread)
      WaitForHandlers(TRUE, TRUE);
      Check(0<g_GGA_Packets, 'GGA handler was not called');
      Check(0<g_RMC_Packets, 'RMC handler was not called');

      // the units state machine reports the connected state on its next
      // poll (the bind is instant, the datagram can beat it)
      VTicks:=GetTickCount;
      while (0=g_ConnectedStates) and (GetTickCount-VTicks<cState_Wait_Timeout_MSec) do begin
        Sleep(10);
        CheckSynchronize;
      end;
      Check(0<g_ConnectedStates, 'the connected state was not reported');

      // the async disconnect terminates the library threads (the state is
      // not "done disconnected" here, so they do really exit); the object
      // is freed while the units are still disconnecting - the destructor
      // finishes the disconnect
      VObj.GPSDisconnect;

      // let the terminated threads finish (the library delivers nothing via
      // Synchronize anymore - the flush is a pump safety)
      Vsagps_Test_FlushPendingSyncs;

      FreeAndNil(VObj);
      Vsagps_Test_FlushPendingSyncs;
    finally
      Vsagps_Test_FlushPendingSyncs;
      VObj.Free;
      Vsagps_Test_FlushPendingSyncs;
    end;
  finally
    WSACleanup;
  end;
end;

initialization
  RegisterTest(Tvsagps_device_udp_nmea_test.Suite);

end.
