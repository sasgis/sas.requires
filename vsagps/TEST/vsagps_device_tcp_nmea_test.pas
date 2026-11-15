unit vsagps_device_tcp_nmea_test;

interface

uses
  TestFramework,
  Winapi.Winsock2,
  vsagps_test_watchdog,
  vsagps_public_device,
  vsagps_device_tcp_nmea;

type
  Tvsagps_device_tcp_nmea_test = class(Tvsagps_test_case)
  private
    // shared body of the "connect and parse" tests (the name without port)
    procedure InternalConnectParseAndDisconnect(const ADeviceName: AnsiString);
  published
    // check the sentence framing (stream to sentences) of the new device
    procedure TestNmeaParsePacket;
    // full cycle: local TCP server -> device connect -> nmea stream -> handlers
    procedure TestTcpDeviceConnectAndParse;
    // the same, but with the "localhost" name: the resolver returns both
    // ::1 and 127.0.0.1 (the order is defined by the system policy), the
    // server listens on the IPv4 loopback only, so a refused ::1 attempt
    // must not prevent the fallback to 127.0.0.1
    procedure TestTcpDeviceConnectLocalhost;
    // a refused connection must be detected at once (with the real socket
    // error, not after the whole timeout) and must not look like a session
    procedure TestTcpDeviceConnectRefused;
    // a silently idle connection (no data, no FIN/RST) must be ended by the
    // idle data watchdog, so the caller sees a disconnect and can reconnect
    procedure TestTcpDeviceIdleWatchdog;
    // the connecting phase must be interruptible: the device close during
    // the connect ends the session quickly (not after the whole timeout)
    procedure TestTcpDeviceCloseDuringConnect;
    // gpsd auto-detection: the {"class":"VERSION"} greeting banner switches
    // the device to the gpsd mode - the WATCH command is sent (the only
    // message the device sends at all), the json reports interleaved with
    // the stream do not break the framing
    procedure TestTcpDeviceGpsdAutoDetect;
    // [TCP] start_query from vsagps_nmea.ini - the value is sent verbatim
    // (no checksum wrapping) instead of the gpsd WATCH / silence
    procedure TestTcpDeviceStartQueryCustom;
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
  vsagps_device_nmea_common, // common NMEA packet format (NmeaPacketCreate and friends)
  vsagps_units,              // PVSAGPS_UNIT (unit state access in the diagnostics)
  vsagps_object;

const
  // waiting limits for the background threads
  cConnect_Wait_Timeout_MSec = 15000;
  cParse_Wait_Timeout_MSec   = 15000;
  cDisconnect_Wait_Timeout_MSec = 15000;

  // the connection timeout of the device below is 10 sec; a refused
  // connection (writefds + exceptfds) must be reported much faster
  cRefused_Detect_Timeout_MSec = 5000;

  // btReceiveGPSTimeoutSec=2 in the idle test: a silent connection must be
  // ended by the idle watchdog well before this limit
  cIdle_Wait_Timeout_MSec = 8000;

  // btReceiveGPSTimeoutSec=2 in the idle test: the silence must be counted
  // from the session start, so a disconnect sooner than this after the
  // session start callback means that the connecting phase (the gpsd probe)
  // was counted as the silence
  cIdle_Min_Timeout_MSec = 1850;

  // how long to wait for the session start callback (it fires on the device
  // working thread right after the gpsd probe and the start message, if any)
  cSession_Wait_Timeout_MSec = 5000;

  // the connection timeout of the device below is 30 sec; the connect wait
  // is sliced (250 msec) with the exit check between the slices, so the
  // interrupted connecting phase must end much faster than the timeout
  cConnectAbort_Wait_Timeout_MSec = 6000;

  // how long the connecting state is watched: the unreachable address is
  // black holed, so the attempt lasts the whole 30 sec connection timeout
  cConnectObserve_MSec = 1000;

  // how long to wait for a start message of the device (the gpsd detection
  // probe is bounded by 1 sec inside the device, so 5 sec is enough)
  cStartQuery_Wait_Timeout_MSec = 5000;

  // how long to watch a plain server connection for an unexpected write
  // (the probe is bounded by 1 sec, so 1500 ms covers it with a margin)
  cSilence_Watch_MSec = 1500;

  // the gpsd greeting banner (the first line of the server output) and the
  // WATCH commands the device must send (the wire format is pinned here
  // independently of the device constants)
  cGpsd_Banner = '{"class":"VERSION","release":"test","proto_major":3}'#10;
  cGpsd_Watch_Expected = '?WATCH={"enable":true,"nmea":true}'#13#10;
  cGpsd_Watch_Raw_Expected = '?WATCH={"enable":true,"raw":1}'#13#10;

  // verified nmea sentences (checksums are correct)
  cNmea_GGA = '$GPGGA,123519.00,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*69';
  cNmea_RMC = '$GPRMC,123519.00,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W,A*29';

  // the same mixed nmea/binary payload as in the com device test
  CData: array [0..594] of Byte = (
    // NMEA: $GNGBS,114734.00,8.0,8.1,17.2,,,,*6E
    $24, $47, $4E, $47, $42, $53, $2C, $31, $31, $34, $37, $33, $34, $2E, $30, $30,
    $2C, $38, $2E, $30, $2C, $38, $2E, $31, $2C, $31, $37, $2E, $32, $2C, $2C, $2C,
    $2C, $2A, $36, $45, $0D, $0A,

    // UBX binary packet
    $B5, $62, $0A, $04, $FA, $00, $45, $58, $54, $20, $43, $4F, $52, $45, $20, $33,
    $2E, $30, $31, $20, $28, $31, $31, $31, $31, $34, $31, $29, $00, $00, $00, $00,
    $00, $00, $00, $00, $30, $30, $30, $38, $30, $30, $30, $30, $00, $00, $52, $4F,
    $4D, $20, $42, $41, $53, $45, $20, $32, $2E, $30, $31, $20, $28, $37, $35, $33,
    $33, $31, $29, $00, $00, $00, $00, $00, $00, $00, $00, $00, $46, $57, $56, $45,
    $52, $3D, $54, $49, $4D, $20, $31, $2E, $31, $30, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $52, $4F, $54, $56, $45,
    $52, $3D, $32, $32, $2E, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $4D, $4F, $44, $3D, $4E, $45, $4F, $2D,
    $4D, $38, $54, $2D, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $46, $49, $53, $3D, $30, $78, $43, $32, $32, $35,
    $33, $36, $20, $28, $31, $30, $30, $31, $31, $31, $29, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $47, $50, $53, $3B, $47, $4C, $4F, $3B, $47, $41, $4C, $3B,
    $42, $44, $53, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $53, $42, $41, $53, $3B, $49, $4D, $45, $53, $3B, $51, $5A, $53, $53,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $01, $1D,

    // UBX binary packet
    $B5, $62, $01, $30, $A4, $00, $28, $16, $88, $02, $0D, $04, $00, $00, $02, $02,
    $0D, $04, $10, $20, $36, $01, $45, $02, $00, $00, $08, $03, $0D, $04, $09, $1A,
    $62, $00, $49, $04, $00, $00, $06, $04, $14, $01, $00, $56, $08, $00, $00, $00,
    $00, $00, $00, $06, $0D, $04, $17, $43, $0A, $01, $A6, $FD, $FF, $FF, $05, $07,
    $0D, $07, $1B, $22, $A3, $00, $5C, $01, $00, $00, $04, $09, $0D, $04, $10, $53,
    $15, $00, $13, $FB, $FF, $FF, $09, $10, $04, $01, $00, $00, $45, $00, $00, $00,
    $00, $00, $03, $11, $0D, $04, $0A, $09, $D8, $00, $FE, $08, $00, $00, $07, $13,
    $0D, $04, $14, $12, $E7, $00, $D0, $02, $00, $00, $0A, $16, $04, $01, $00, $08,
    $6A, $00, $00, $00, $00, $00, $01, $17, $0D, $07, $24, $34, $36, $00, $BF, $FF,
    $FF, $FF, $0C, $1A, $04, $01, $00, $02, $2D, $00, $00, $00, $00, $00, $0B, $1E,
    $0D, $07, $1C, $08, $BA, $00, $90, $FE, $FF, $FF, $89, $A8,

    // UBX binary packet
    $B5, $62, $01, $03, $10, $00, $28, $16, $88, $02, $03, $DD, $00, $08, $0A, $3F,
    $0B, $00, $53, $A3, $22, $00, $30, $70,

    // NMEA: $GNRMC,114735.00,A,4328.35314,N,00120.69232,E,0.005,,171119,,,A*62
    $24, $47, $4E, $52, $4D, $43, $2C, $31, $31, $34, $37, $33, $35, $2E, $30, $30,
    $2C, $41, $2C, $34, $33, $32, $38, $2E, $33, $35, $33, $31, $34, $2C, $4E, $2C,
    $30, $30, $31, $32, $30, $2E, $36, $39, $32, $33, $32, $2C, $45, $2C, $30, $2E,
    $30, $30, $35, $2C, $2C, $31, $37, $31, $31, $31, $39, $2C, $2C, $2C, $41, $2A,
    $36, $32, $0D, $0A,

    // NMEA: $GNVTG,,T,,M,0.005,N,0.009,K,A*31
    $24, $47, $4E, $56, $54, $47, $2C, $2C, $54, $2C, $2C, $4D, $2C, $30, $2E, $30,
    $30, $35, $2C, $4E, $2C, $30, $2E, $30, $30, $39, $2C, $4B, $2C, $41, $2A, $33,
    $31, $0D, $0A
  );

var
  // counters incremented from the packet parser thread by the nmea handlers
  g_GGA_Packets: Integer;
  g_RMC_Packets: Integer;
  g_SessionStarted: Integer;

{ handlers for the nmea packets - called from the packet parser thread }

// temporary diagnostics
var
  g_StateChanges: Integer;
  // how many times the "connected" state was reported; a failed connect must
  // never reach it (the library used to report it from the fake device handle
  // before the connection attempt was over)
  g_ConnectedStates: Integer;

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

{ helpers for the local test server }

// the temporary directory of the system (with a trailing delimiter)
function GetTestTempDir: string;
var
  VBuf: array [0..MAX_PATH-1] of Char;
begin
  if (0=GetTempPath(MAX_PATH, VBuf)) then
    Result:=GetCurrentDir
  else
    Result:=VBuf;
  Result:=IncludeTrailingPathDelimiter(Result);
end;

// make a TCP server socket listening on the loopback interface;
// the port is assigned by the system and returned via APort
function MakeLocalNmeaServer(out APort: Word): TSocket;
var
  VAddr: TSockAddr;
  VAddrLen: Integer;
begin
  Result:=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (INVALID_SOCKET=Result) then
    Exit;

  // bind to the loopback interface (127.0.0.1) on an ephemeral port
  FillChar(VAddr, sizeof(VAddr), 0);
  VAddr.sa_family:=AF_INET;
  VAddr.sa_data[0]:=AnsiChar(0);   // port = 0 (high byte) - let the system choose
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

  if (0<>listen(Result, 1)) then begin
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

// wait for the incoming connection with a timeout
function AcceptWithTimeout(const AServer: TSocket; const ATimeoutMSec: DWORD): TSocket;
var
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VTicks: DWORD;
  VRes: Integer;
begin
  Result:=INVALID_SOCKET;
  VTicks:=GetTickCount;
  repeat
    FD_ZERO(VSet);
    _FD_SET(AServer, VSet);
    VTimeout.tv_sec:=0;
    VTimeout.tv_usec:=100*1000; // 100 msec per attempt
    VRes:=select(0, @VSet, nil, nil, @VTimeout);
    if (0<VRes) then begin
      // incoming connection
      Result:=accept(AServer, nil, nil);
      Exit;
    end;
    if (SOCKET_ERROR=VRes) then
      Exit;
  until (GetTickCount-VTicks>ATimeoutMSec);
end;

// send the whole buffer to the socket
procedure SendAll(const ASocket: TSocket; const AData: AnsiString);
var
  P: PByte;
  iLeft, iSent: Integer;
begin
  P:=Pointer(AData);
  iLeft:=Length(AData);
  while (0<iLeft) do begin
    iSent:=send(ASocket, P^, iLeft, 0);
    if (SOCKET_ERROR=iSent) then
      raise Exception.Create('send to the test server socket failed');
    Inc(P, iSent);
    Dec(iLeft, iSent);
  end;
end;

// wait until the object state leaves the initial "done disconnected" one
function WaitObjectStateLeavesDoneDisconnected(const AObj: Tvsagps_object;
                                               const ATimeoutMSec: DWORD): Boolean;
var
  VT: DWORD;
begin
  VT:=GetTickCount;
  while (gs_DoneDisconnected=AObj.GPSState) and (GetTickCount-VT<ATimeoutMSec) do begin
    Sleep(10);
    CheckSynchronize;
  end;
  Result:=(gs_DoneDisconnected<>AObj.GPSState);
end;

// wait until the object state comes back to "done disconnected"
function WaitObjectStateDoneDisconnected(const AObj: Tvsagps_object;
                                         const ATimeoutMSec: DWORD): Boolean;
var
  VT: DWORD;
begin
  VT:=GetTickCount;
  while (gs_DoneDisconnected<>AObj.GPSState) and (GetTickCount-VT<ATimeoutMSec) do begin
    Sleep(10);
    CheckSynchronize;
  end;
  Result:=(gs_DoneDisconnected=AObj.GPSState);
end;

// read whatever the peer sends to this socket (bounded wait, one read)
function ReadFromSocket(const ASocket: TSocket; const ATimeoutMSec: DWORD): AnsiString;
var
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VTicks: DWORD;
  VRes, VReceived: Integer;
  VBuf: array [0..4095] of AnsiChar;
begin
  Result:='';
  VTicks:=GetTickCount;
  repeat
    FD_ZERO(VSet);
    _FD_SET(ASocket, VSet);
    VTimeout.tv_sec:=0;
    VTimeout.tv_usec:=100*1000;
    VRes:=select(0, @VSet, nil, nil, @VTimeout);
    if (0<VRes) then begin
      VReceived:=recv(ASocket, VBuf[0], sizeof(VBuf), 0);
      if (0<VReceived) then begin
        // one small write of the device - enough for the assertions
        Result:=Copy(VBuf, 1, VReceived);
        Exit;
      end;
      if (SOCKET_ERROR=VReceived) then
        Exit; // socket error - the caller sees the empty result
    end;
  until (GetTickCount-VTicks>ATimeoutMSec);
end;

// the device never owns the packet: the object packet thread frees it right
// after ParsePacket (VSAGPS_FreeMem - the packet lives in the process heap),
// so a direct ParsePacket call in a test must free it the same way
procedure ParseAndFreePacket(const ADevice: Tvsagps_device_tcp_nmea;
                             const APacket: Pointer);
begin
  try
    ADevice.ParsePacket(APacket);
  finally
    VSAGPS_FreeMem(APacket);
  end;
end;

{ Tvsagps_device_tcp_nmea_test }

procedure Tvsagps_device_tcp_nmea_test.TestNmeaParsePacket;
var
  VSize: Integer;
  VPos: Integer;
  i: Integer;
  VObj: Tvsagps_device_tcp_nmea;
  VPacket: Pointer;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VBig: AnsiString;
  VStress: AnsiString;
begin
  ZeroMemory(@VParams, sizeof(VParams));

  with VParams do begin
    wSize:=sizeof(VParams);
    btAutodetectOnConnect:=0;
    btReceiveGPSTimeoutSec:=10;
    wConnectionTimeoutSec:=10;
    wWorkerThreadTimeoutMSec:=100;
    dwAutodetectFlags:=0;
    dwDeviceFlagsOut:=0;
    iBaudRate:=-1;
  end;
  VParams.pNMEA_GGA_HANDLER:=NMEA_GGA_Handler;

  VObj := Tvsagps_device_tcp_nmea.Create;
  try
    VObj.SetBaseParams(0,0,nil,'',@VParams,nil,nil,nil,nil);

    // feed the mixed nmea/binary payload in small chunks - the framing
    // should split it into sentences and ignore the binary packets
    VPos := 0;
    VSize := 10;
    while VPos + VSize < Length(CData) do begin
      VPacket := NmeaPacketCreate(@CData[VPos], VSize);
      ParseAndFreePacket(VObj, VPacket);
      Inc(VPos, VSize);
    end;

    VPacket := NmeaPacketCreate(@CData[VPos], Length(CData) - VPos);
    ParseAndFreePacket(VObj, VPacket);

    // damaged frames: binary data inside, tail before head, empty messages,
    // proprietary sentence without tail (allowed only when enabled)
    VPacket := NmeaPacketCreate(
      '$' + #01#02 + #13#10 + '$' + #03 + // binary data
      '$123456$' + #13#10 + #13#10 + '$' + #13#10 + // tail before head + empty message
      '$PGRMZ,2282,f,3' + // proprietary without tail
      '$PGRMZ,2282,f,3*21' + #13#10
    );
    ParseAndFreePacket(VObj, VPacket);

    // a large garbage stream without the sentence tail (a wrong port) must
    // not break the framing: exceed cNmea_GlobalBuffer_MaxSize and check
    // that a correct sentence after it is still parsed
    VBig := '$' + AnsiString(StringOfChar(AnsiChar('A'), cNmea_GlobalBuffer_MaxSize + 4096));
    VPacket := NmeaPacketCreate(VBig);
    ParseAndFreePacket(VObj, VPacket);

    g_GGA_Packets:=0;
    VPacket := NmeaPacketCreate(cNmea_GGA + #13#10);
    ParseAndFreePacket(VObj, VPacket);
    Check(0<g_GGA_Packets, 'a sentence is not parsed after the buffer truncation');

    // a stream of thousands of short binary frames: the framing used to skip
    // each one with a recursive call, so the stack grew with the stream
    // length (a wrong port can deliver thousands of such frames per read)
    SetLength(VStress, 20000*5);
    for i := 1 to 20000 do begin
      VStress[(i-1)*5+1] := '$';
      VStress[(i-1)*5+2] := #01;
      VStress[(i-1)*5+3] := #02;
      VStress[(i-1)*5+4] := #13;
      VStress[(i-1)*5+5] := #10;
    end;
    VPacket := NmeaPacketCreate(VStress);
    ParseAndFreePacket(VObj, VPacket);

    // the framing must still work after the stress input
    g_GGA_Packets:=0;
    VPacket := NmeaPacketCreate(cNmea_GGA + #13#10);
    ParseAndFreePacket(VObj, VPacket);
    Check(0<g_GGA_Packets, 'a sentence is not parsed after the stream of the broken frames');
  finally
    VObj.Free;
  end;
end;

procedure Tvsagps_device_tcp_nmea_test.InternalConnectParseAndDisconnect(const ADeviceName: AnsiString);
var
  VWSA: TWSAData;
  VServer: TSocket;
  VClient: TSocket;
  VPort: Word;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VTicks: DWORD;
  VSet: TFDSet;
  VTimeout: TTimeVal;
begin
  // winsock for the test server
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // make a local TCP server which pretends to be an nmea0183 source
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    try
      // reset handler counters
      g_GGA_Packets:=0;
      g_RMC_Packets:=0;
      g_SessionStarted:=0;
      g_StateChanges:=0;
      g_ConnectedStates:=0;

      ZeroMemory(@VParams, sizeof(VParams));
      with VParams do begin
        wSize:=sizeof(VParams);
        btAutodetectOnConnect:=0;
        btReceiveGPSTimeoutSec:=10;
        wConnectionTimeoutSec:=10;
        wWorkerThreadTimeoutMSec:=50;
        dwAutodetectFlags:=0;
        dwDeviceFlagsOut:=0;
        iBaudRate:=-1;
      end;
      VParams.pSessionStartedHandler:=SessionStarted_Handler;
      VParams.pNMEA_GGA_HANDLER:=NMEA_GGA_Handler;
      VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

      VObj:=Tvsagps_object.Create;
      try
        VObj.OnGPSStateChanged:=GPSStateChange_Handler; // temporary diagnostics
        // connect the new device via the common factory
        Check(VObj.GPSConnect(gdt_TCP_NMEA0183,
                              ADeviceName+AnsiString(':'+IntToStr(VPort)),
                              nil,
                              @VParams,
                              nil,
                              nil,
                              @VUnitIndex,
                              nil),
              'GPSConnect failed');

        // the device connects in the background - accept the connection
        VClient:=AcceptWithTimeout(VServer, cConnect_Wait_Timeout_MSec);
        Check(VClient<>INVALID_SOCKET,
              'device ('+string(ADeviceName)+') did not connect to the test server');
        try
          // the plain nmea server is not written to at all: it streams by
          // itself, and the only message the device may send is the gpsd
          // WATCH (this server sends no greeting, so it is not gpsd)
          FD_ZERO(VSet);
          _FD_SET(VClient, VSet);
          VTimeout.tv_sec:=cSilence_Watch_MSec div 1000;
          VTimeout.tv_usec:=(cSilence_Watch_MSec mod 1000)*1000;
          Check(0=select(0, @VSet, nil, nil, @VTimeout),
                'the device wrote to a plain nmea server (nothing must be sent)');

          // emulate an nmea stream - two sentences in one packet
          SendAll(VClient, cNmea_GGA + #13#10 + cNmea_RMC + #13#10);

          // wait until the device parses the sentences
          // (handlers are called on the packet parser thread)
          VTicks:=GetTickCount;
          while ((0=g_GGA_Packets) or (0=g_RMC_Packets)) and
                (GetTickCount-VTicks<cParse_Wait_Timeout_MSec) do
            Sleep(50);

          Check(0<g_SessionStarted, 'session was not started');
          Check(0<g_ConnectedStates, 'the connected state was not reported');
          Check(0<g_GGA_Packets, 'GGA handler was not called');
          Check(0<g_RMC_Packets, 'RMC handler was not called');
        finally
          // closing the server side makes the device fail with the
          // communication error - the library must disconnect by itself
          closesocket(VClient);
        end;

        // wait for the device-initiated disconnect to complete
        VTicks:=GetTickCount;
        while (gs_DoneDisconnected<>VObj.GPSState) and
              (GetTickCount-VTicks<cDisconnect_Wait_Timeout_MSec) do begin
          Sleep(50);
          // the "all disconnected" state is reported from the device thread
          // OnTerminate handler which is delivered via Synchronize - a
          // console application has no message pump, so sync it manually
          CheckSynchronize;
        end;
        Check(gs_DoneDisconnected=VObj.GPSState, 'device is not disconnected');
      finally
        // the destructor also disconnects (with wait) - just in case
        VObj.Free;
      end;
    finally
      closesocket(VServer);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceConnectAndParse;
begin
  InternalConnectParseAndDisconnect('127.0.0.1');
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceConnectLocalhost;
begin
  // "localhost" resolves to both ::1 and 127.0.0.1 (the order is defined by
  // the system resolver policy - IPv6 is often the first one); the test
  // server listens on the IPv4 loopback only, so a refused ::1 attempt must
  // be detected at once (exceptfds) and the device must fall back to the
  // next resolved address instead of burning the whole connection budget
  InternalConnectParseAndDisconnect('localhost');
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceConnectRefused;
var
  VWSA: TWSAData;
  VServer: TSocket;
  VPort: Word;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // a listening server is used only to get a free tcp port, then it is
    // closed - the connection to this port is refused by the system
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    closesocket(VServer);

    g_SessionStarted:=0;
    g_GGA_Packets:=0;
    g_RMC_Packets:=0;
    g_ConnectedStates:=0;

    ZeroMemory(@VParams, sizeof(VParams));
    with VParams do begin
      wSize:=sizeof(VParams);
      btAutodetectOnConnect:=0;
      btReceiveGPSTimeoutSec:=10;
      wConnectionTimeoutSec:=10;
      wWorkerThreadTimeoutMSec:=50;
      dwAutodetectFlags:=0;
      dwDeviceFlagsOut:=0;
      iBaudRate:=-1;
    end;
    VParams.pSessionStartedHandler:=SessionStarted_Handler;
    VParams.pNMEA_GGA_HANDLER:=NMEA_GGA_Handler;
    VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

    VObj:=Tvsagps_object.Create;
    try
      VTicks:=GetTickCount;
      Check(VObj.GPSConnect(gdt_TCP_NMEA0183,
                            AnsiString('127.0.0.1:'+IntToStr(VPort)),
                            nil,
                            @VParams,
                            nil,
                            nil,
                            @VUnitIndex,
                            nil),
            'GPSConnect failed');

      // the connection is refused: the device must report the error and
      // disconnect much faster than the connection timeout (10 sec)
      Check(WaitObjectStateLeavesDoneDisconnected(VObj, cConnect_Wait_Timeout_MSec),
            'the device did not start connecting');
      Check(WaitObjectStateDoneDisconnected(VObj, cConnect_Wait_Timeout_MSec),
            'the device did not disconnect after the refused connection');
      Check((GetTickCount-VTicks)<cRefused_Detect_Timeout_MSec,
            'a refused connection is not detected at once (it is reported as a timeout)');

      // a failed connect must not be reported as a started session and must
      // not be reported as a connection at all
      Check(0=g_SessionStarted, 'a session was started for a refused connection');
      Check(0=g_ConnectedStates, 'a refused connection was reported as connected');
      Check(0=g_GGA_Packets, 'unexpected data after the refused connection');
      Check(gs_DoneDisconnected=VObj.GPSState, 'unexpected final state');
    finally
      VObj.Free;
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceIdleWatchdog;
var
  VWSA: TWSAData;
  VServer: TSocket;
  VClient: TSocket;
  VPort: Word;
  VDev: Tvsagps_device_tcp_nmea;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VTicks: DWORD;
  VElapsed: DWORD;
begin
  // the device object is used directly (without the Tvsagps_object): the
  // object has its own data timeout which starts at the connect request and
  // would hide the device watchdog
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    try
      g_SessionStarted:=0;
      g_GGA_Packets:=0;
      g_RMC_Packets:=0;

      ZeroMemory(@VParams, sizeof(VParams));
      with VParams do begin
        wSize:=sizeof(VParams);
        btAutodetectOnConnect:=0;
        btReceiveGPSTimeoutSec:=2; // the idle data watchdog timeout
        wConnectionTimeoutSec:=10;
        wWorkerThreadTimeoutMSec:=50;
        dwAutodetectFlags:=0;
        dwDeviceFlagsOut:=0;
        iBaudRate:=-1;
      end;
      VParams.pSessionStartedHandler:=SessionStarted_Handler;

      VDev:=Tvsagps_device_tcp_nmea.Create;
      VClient:=INVALID_SOCKET;
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

        // the device connects in the background - accept the connection
        VClient:=AcceptWithTimeout(VServer, cConnect_Wait_Timeout_MSec);
        Check(VClient<>INVALID_SOCKET, 'device did not connect to the test server');

        // wait for the session start callback: it fires right after the gpsd
        // probe (1 sec, the server sends no greeting and gets no writes),
        // and the idle watchdog must count the silence from that moment
        VTicks:=GetTickCount;
        while (0=g_SessionStarted) and (GetTickCount-VTicks<cSession_Wait_Timeout_MSec) do
          Sleep(10);
        Check(0<g_SessionStarted, 'session was not started');
        VTicks:=GetTickCount;

        // NOTE: the client socket is intentionally NOT closed here - the
        // connection stays silently idle (no data, no FIN/RST), only the
        // idle watchdog can end it; the keepalive probes are configured
        // for 30 sec and can not fire within this test
        while (0=VDev.FinishReason) and (GetTickCount-VTicks<cIdle_Wait_Timeout_MSec) do
          Sleep(10);
        VElapsed:=GetTickCount-VTicks;

        Check(0<>VDev.FinishReason,
              'the device is not disconnected after the idle timeout');
        // btReceiveGPSTimeoutSec=2 and the watchdog is checked every 50 msec:
        // the connection can not be ended sooner than the timeout after the
        // session start (before the fix the connecting phase was counted as
        // the silence and the session ended about 1 sec earlier, right after
        // the gpsd probe)
        Check(VElapsed>=cIdle_Min_Timeout_MSec,
              'the idle watchdog fired '+IntToStr(VElapsed)+
              ' msec after the session start (it counts the connecting phase?)');
      finally
        if (INVALID_SOCKET<>VClient) then
          closesocket(VClient);
        VDev.Free;
      end;
    finally
      closesocket(VServer);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceCloseDuringConnect;
var
  VWSA: TWSAData;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VTicks: DWORD;
  VConnectedSeen: Boolean;
  VStillConnecting: Boolean;
  VCloseElapsed: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    g_SessionStarted:=0;
    g_GGA_Packets:=0;
    g_RMC_Packets:=0;
    g_ConnectedStates:=0;

    ZeroMemory(@VParams, sizeof(VParams));
    with VParams do begin
      wSize:=sizeof(VParams);
      btAutodetectOnConnect:=0;
      btReceiveGPSTimeoutSec:=10;
      wConnectionTimeoutSec:=30; // long enough to prove the interruption
      wWorkerThreadTimeoutMSec:=50;
      dwAutodetectFlags:=0;
      dwDeviceFlagsOut:=0;
      iBaudRate:=-1;
    end;
    VParams.pSessionStartedHandler:=SessionStarted_Handler;

    VObj:=Tvsagps_object.Create;
    try
      // TEST-NET-3 - on most networks the SYN packets for this address are
      // silently dropped (a black hole), so the connecting phase would run
      // for the whole timeout if it can not be interrupted; on a network
      // which refuses it at once this test just checks less
      Check(VObj.GPSConnect(gdt_TCP_NMEA0183,
                            AnsiString('203.0.113.1:9'),
                            nil,
                            @VParams,
                            nil,
                            nil,
                            @VUnitIndex,
                            nil),
            'GPSConnect failed');

      // let the working thread enter the connect select loop
      Check(WaitObjectStateLeavesDoneDisconnected(VObj, cConnect_Wait_Timeout_MSec),
            'the device did not start connecting');

      // the fake device handle is published only after the connection
      // attempt is over, so the unit must stay in the connecting state while
      // the unreachable address is tried (before the fix the fake handle
      // made the library report gs_DoneConnected at once)
      VTicks:=GetTickCount;
      VConnectedSeen:=FALSE;
      VStillConnecting:=FALSE;
      while (GetTickCount-VTicks<cConnectObserve_MSec) do begin
        if (gs_DoneConnected=VObj.GPSState) then
          VConnectedSeen:=TRUE;
        if (gs_ProcessConnecting=VObj.GPSState) then
          VStillConnecting:=TRUE;
        Sleep(10);
        CheckSynchronize;
      end;
      Check(not VConnectedSeen,
            'the device reported a successful connection before the connect attempt was over');

      // close the device while the connect is still running: the destructor
      // performs the waited disconnect (the same path as the user disconnect
      // followed by the shutdown), so the connect must abort through the
      // exit flag and not after the whole connection timeout. The connect
      // wait is sliced (250 msec) with the exit check between the slices
      VTicks:=GetTickCount;
      FreeAndNil(VObj);
      VCloseElapsed:=GetTickCount-VTicks;

      // on a network which refuses the address at once the attempt is over
      // before the close and there is nothing to interrupt
      if VStillConnecting then
        Check(VCloseElapsed<cConnectAbort_Wait_Timeout_MSec,
              'the device did not abort the connecting phase in time: '+
              IntToStr(VCloseElapsed)+' msec');

      Check(0=g_SessionStarted, 'a session was started for the failed connect');
      Check(0=g_ConnectedStates, 'a failed connect was reported as connected');
    finally
      // the destructor completes the disconnect of the device
      VObj.Free;
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceGpsdAutoDetect;
var
  VWSA: TWSAData;
  VServer: TSocket;
  VClient: TSocket;
  VPort: Word;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VQuery: AnsiString;
  VStartDir, VTmpDir: string;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // a private working directory without vsagps_nmea.ini - the default
    // behavior (the repository copy of vsagps_nmea.ini must not interfere)
    VStartDir:=GetCurrentDir;
    VTmpDir:=GetTestTempDir+'vsagps_tcp_gpsd_'+IntToStr(GetCurrentProcessId);
    ForceDirectories(VTmpDir);
    try
      SetCurrentDir(VTmpDir);

      VServer:=MakeLocalNmeaServer(VPort);
      Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
      try
        g_SessionStarted:=0;
        g_GGA_Packets:=0;
        g_RMC_Packets:=0;

        ZeroMemory(@VParams, sizeof(VParams));
        with VParams do begin
          wSize:=sizeof(VParams);
          btAutodetectOnConnect:=0;
          btReceiveGPSTimeoutSec:=10;
          wConnectionTimeoutSec:=10;
          wWorkerThreadTimeoutMSec:=50;
          dwAutodetectFlags:=0;
          dwDeviceFlagsOut:=0;
          iBaudRate:=-1;
        end;
        VParams.pSessionStartedHandler:=SessionStarted_Handler;
        VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

        VObj:=Tvsagps_object.Create;
        try
          Check(VObj.GPSConnect(gdt_TCP_NMEA0183,
                                AnsiString('127.0.0.1:'+IntToStr(VPort)),
                                nil,
                                @VParams,
                                nil,
                                nil,
                                @VUnitIndex,
                                nil),
                'GPSConnect failed');

          // pretend to be gpsd: the greeting banner is sent immediately
          // after the connection is accepted
          VClient:=AcceptWithTimeout(VServer, cConnect_Wait_Timeout_MSec);
          Check(VClient<>INVALID_SOCKET, 'device did not connect to the test server');
          try
            SendAll(VClient, cGpsd_Banner);

            // the device must detect gpsd and send the WATCH command
            // instead of the default nmea query
            VQuery:=ReadFromSocket(VClient, cStartQuery_Wait_Timeout_MSec);
            Check(cGpsd_Watch_Expected=VQuery,
                  'the device did not send the gpsd WATCH command: "'+string(VQuery)+'"');

            // gpsd streams the raw nmea sentences interleaved with the json
            // reports - the json lines must not break the framing
            SendAll(VClient,
              '{"class":"TPV","mode":3,"lat":43.6}'#10 +
              cNmea_RMC + #13#10);

            VTicks:=GetTickCount;
            while ((0=g_RMC_Packets) or (0=g_SessionStarted)) and
                  (GetTickCount-VTicks<cParse_Wait_Timeout_MSec) do
              Sleep(50);

            Check(0<g_SessionStarted, 'session was not started');
            Check(0<g_RMC_Packets, 'RMC handler was not called');
          finally
            // closing the server side ends the session
            closesocket(VClient);
          end;
        finally
          VObj.Free;
        end;
      finally
        closesocket(VServer);
      end;
    finally
      SetCurrentDir(VStartDir);
      RemoveDir(VTmpDir);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_device_tcp_nmea_test.TestTcpDeviceStartQueryCustom;
var
  VWSA: TWSAData;
  VServer: TSocket;
  VClient: TSocket;
  VPort: Word;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VQuery: AnsiString;
  VStartDir, VTmpDir, VIniFile: string;
  VStream: TFileStream;
  sIni: AnsiString;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // a private working directory with the custom start query, so the
    // repository copy of vsagps_nmea.ini is not touched (the device reads
    // its ini from the current directory)
    VStartDir:=GetCurrentDir;
    VTmpDir:=GetTestTempDir+'vsagps_tcp_sq_'+IntToStr(GetCurrentProcessId);
    ForceDirectories(VTmpDir);
    VIniFile:=IncludeTrailingPathDelimiter(VTmpDir)+'vsagps_nmea.ini';
    sIni:='[TCP]'#13#10'start_query=?WATCH={"enable":true,"raw":1}'#13#10;
    VStream:=TFileStream.Create(VIniFile, fmCreate);
    try
      VStream.WriteBuffer(PAnsiChar(sIni)^, Length(sIni));
    finally
      VStream.Free;
    end;
    try
      SetCurrentDir(VTmpDir);

      VServer:=MakeLocalNmeaServer(VPort);
      Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
      try
        g_SessionStarted:=0;
        g_GGA_Packets:=0;
        g_RMC_Packets:=0;

        ZeroMemory(@VParams, sizeof(VParams));
        with VParams do begin
          wSize:=sizeof(VParams);
          btAutodetectOnConnect:=0;
          btReceiveGPSTimeoutSec:=10;
          wConnectionTimeoutSec:=10;
          wWorkerThreadTimeoutMSec:=50;
          dwAutodetectFlags:=0;
          dwDeviceFlagsOut:=0;
          iBaudRate:=-1;
        end;
        VParams.pSessionStartedHandler:=SessionStarted_Handler;
        VParams.pNMEA_RMC_HANDLER:=NMEA_RMC_Handler;

        VObj:=Tvsagps_object.Create;
        try
          Check(VObj.GPSConnect(gdt_TCP_NMEA0183,
                                AnsiString('127.0.0.1:'+IntToStr(VPort)),
                                nil,
                                @VParams,
                                nil,
                                nil,
                                @VUnitIndex,
                                nil),
                'GPSConnect failed');

          VClient:=AcceptWithTimeout(VServer, cConnect_Wait_Timeout_MSec);
          Check(VClient<>INVALID_SOCKET, 'device did not connect to the test server');
          try
            // the custom query is sent verbatim - no "$", no checksum, the
            // \r\n tail is added by the device
            VQuery:=ReadFromSocket(VClient, cStartQuery_Wait_Timeout_MSec);
            Check(cGpsd_Watch_Raw_Expected=VQuery,
                  'the device did not send the custom start query: "'+string(VQuery)+'"');

            // the receiving direction still works
            SendAll(VClient, cNmea_RMC + #13#10);
            VTicks:=GetTickCount;
            while (0=g_RMC_Packets) and
                  (GetTickCount-VTicks<cParse_Wait_Timeout_MSec) do
              Sleep(50);

            Check(0<g_SessionStarted, 'session was not started');
            Check(0<g_RMC_Packets, 'RMC handler was not called');
          finally
            closesocket(VClient);
          end;
        finally
          VObj.Free;
        end;
      finally
        closesocket(VServer);
      end;
    finally
      SetCurrentDir(VStartDir);
      DeleteFile(VIniFile);
      RemoveDir(VTmpDir);
    end;
  finally
    WSACleanup;
  end;
end;

initialization
  RegisterTest(Tvsagps_device_tcp_nmea_test.Suite);

end.
