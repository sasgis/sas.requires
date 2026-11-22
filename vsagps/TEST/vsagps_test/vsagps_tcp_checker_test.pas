unit vsagps_tcp_checker_test;

interface

uses
  TestFramework,
  Winapi.Winsock2,
  vsagps_test_watchdog,
  vsagps_tcp_checker;

type
  Tvsagps_tcp_checker_test = class(Tvsagps_test_case)
  published
    // the reply of a plain nmea server is classified as nmea
    procedure TestProbeNmea;
    // the gpsd greeting banner is classified as gpsd
    procedure TestProbeGpsd;
    // a connected but silent server is reported as no data
    procedure TestProbeNoData;
    // a refused connection is reported as a connect error with the real
    // socket code and does not consume the whole connection budget
    procedure TestProbeRefused;
    // a name without the port part is reported as invalid parameters
    procedure TestProbeInvalidParams;
  end;

implementation

uses
  Windows,
  SysUtils,
  Classes;

const
  // the probe timeouts used by the tests below
  cProbe_Connect_Timeout_MSec = 10000;
  cProbe_Data_Timeout_MSec    = 2000;
  cProbe_Data_Timeout_Short_MSec = 800;

  // how long to wait for the probe thread to finish (the refused connect
  // and both timeouts above must end the probe much faster)
  cProbe_Thread_Wait_Timeout_MSec = 15000;

  // a refused connection (writefds + exceptfds) must be detected at once
  cRefused_Detect_Timeout_MSec = 5000;

  // how long to wait for the incoming connection of the probe
  cConnect_Wait_Timeout_MSec = 5000;

  // verified nmea sentence (the checksum is correct)
  cNmea_RMC = '$GPRMC,123519.00,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W,A*29';

  // the gpsd greeting banner (the first line of the server output)
  cGpsd_Banner = '{"class":"VERSION","release":"test","proto_major":3}'#10;

type
  // the probe is synchronous - the test runs it on a background thread to
  // be able to accept the connection and to send the reply meanwhile
  TProbeThread = class(TThread)
  protected
    procedure Execute; override;
  public
    HostPort: string;
    ConnectTimeoutMSec: DWORD;
    DataTimeoutMSec: DWORD;
    Info: TTcpProbeInfo;
  end;

{ helpers for the local test server }

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

{ TProbeThread }

procedure TProbeThread.Execute;
begin
  TcpProbeExecute(HostPort, ConnectTimeoutMSec, DataTimeoutMSec, nil, Info);
end;

{ helpers for the probe thread }

function MakeProbeThread(const AHostPort: string;
                         const AConnectTimeoutMSec, ADataTimeoutMSec: DWORD): TProbeThread;
begin
  Result:=TProbeThread.Create(TRUE);
  Result.FreeOnTerminate:=FALSE;
  Result.HostPort:=AHostPort;
  Result.ConnectTimeoutMSec:=AConnectTimeoutMSec;
  Result.DataTimeoutMSec:=ADataTimeoutMSec;
  Result.{$IF CompilerVersion < 23}Resume{$ELSE}Start{$IFEND};
end;

procedure WaitForProbeThread(const AThread: TProbeThread);
var
  VTicks: DWORD;
begin
  VTicks:=GetTickCount;
  while (not AThread.Finished) and (GetTickCount-VTicks<cProbe_Thread_Wait_Timeout_MSec) do
    Sleep(30);
end;

procedure FreeProbeThread(var AThread: TProbeThread);
begin
  // the thread may still be running when a Check above has failed (its
  // timeouts are well below the wait limit, so this must not happen) -
  // freeing a running thread is worse than leaking it in a test process
  if (nil<>AThread) and AThread.Finished then
    FreeAndNil(AThread);
end;

{ Tvsagps_tcp_checker_test }

procedure Tvsagps_tcp_checker_test.TestProbeNmea;
var
  VWSA: TWSAData;
  VServer, VClient: TSocket;
  VPort: Word;
  VThread: TProbeThread;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    try
      VThread:=MakeProbeThread('127.0.0.1:'+IntToStr(VPort),
                               cProbe_Connect_Timeout_MSec,
                               cProbe_Data_Timeout_MSec);
      try
        // the probe connects in the background - accept and emulate the
        // nmea stream
        VClient:=AcceptWithTimeout(VServer, cConnect_Wait_Timeout_MSec);
        Check(VClient<>INVALID_SOCKET, 'the probe did not connect to the test server');
        try
          SendAll(VClient, cNmea_RMC + #13#10);
        finally
          closesocket(VClient);
        end;

        WaitForProbeThread(VThread);
        Check(VThread.Finished, 'the probe did not finish in time');
        Check(tpr_Nmea=VThread.Info.Kind,
              'the nmea server is not detected: '+IntToStr(Integer(VThread.Info.Kind)));
        Check(0<Pos(AnsiString('$GPRMC'), VThread.Info.Sample),
              'the sample does not contain the nmea sentence');
        Check(0=VThread.Info.LastError, 'unexpected winsock error');
        Check(not VThread.Info.Cancelled, 'unexpected cancellation');
      finally
        FreeProbeThread(VThread);
      end;
    finally
      closesocket(VServer);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_tcp_checker_test.TestProbeGpsd;
var
  VWSA: TWSAData;
  VServer, VClient: TSocket;
  VPort: Word;
  VThread: TProbeThread;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    try
      VThread:=MakeProbeThread('127.0.0.1:'+IntToStr(VPort),
                               cProbe_Connect_Timeout_MSec,
                               cProbe_Data_Timeout_MSec);
      try
        // pretend to be gpsd: the greeting banner is sent immediately after
        // the connection is accepted
        VClient:=AcceptWithTimeout(VServer, cConnect_Wait_Timeout_MSec);
        Check(VClient<>INVALID_SOCKET, 'the probe did not connect to the test server');
        try
          SendAll(VClient, cGpsd_Banner);
        finally
          closesocket(VClient);
        end;

        WaitForProbeThread(VThread);
        Check(VThread.Finished, 'the probe did not finish in time');
        Check(tpr_Gpsd=VThread.Info.Kind,
              'the gpsd server is not detected: '+IntToStr(Integer(VThread.Info.Kind)));
        Check(0<Pos(AnsiString('{"class":"VERSION"'), VThread.Info.Sample),
              'the sample does not contain the gpsd banner');
        Check(0=VThread.Info.LastError, 'unexpected winsock error');
      finally
        FreeProbeThread(VThread);
      end;
    finally
      closesocket(VServer);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_tcp_checker_test.TestProbeNoData;
var
  VWSA: TWSAData;
  VServer: TSocket;
  VPort: Word;
  VThread: TProbeThread;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // the listening server accepts the connection on the kernel level (the
    // listen backlog completes the handshake) but sends nothing
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    try
      VThread:=MakeProbeThread('127.0.0.1:'+IntToStr(VPort),
                               cProbe_Connect_Timeout_MSec,
                               cProbe_Data_Timeout_Short_MSec);
      try
        WaitForProbeThread(VThread);
        Check(VThread.Finished, 'the probe did not finish in time');
        Check(tpr_NoData=VThread.Info.Kind,
              'the silent server is not reported as no data: '+IntToStr(Integer(VThread.Info.Kind)));
        Check(0=Length(VThread.Info.Sample), 'unexpected sample');
        Check(0=VThread.Info.LastError, 'unexpected winsock error');
      finally
        FreeProbeThread(VThread);
      end;
    finally
      closesocket(VServer);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_tcp_checker_test.TestProbeRefused;
var
  VWSA: TWSAData;
  VServer: TSocket;
  VPort: Word;
  VThread: TProbeThread;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    // a listening server is used only to get a free tcp port, then it is
    // closed - the connection to this port is refused by the system
    VServer:=MakeLocalNmeaServer(VPort);
    Check(VServer<>INVALID_SOCKET, 'MakeLocalNmeaServer failed');
    closesocket(VServer);

    VThread:=MakeProbeThread('127.0.0.1:'+IntToStr(VPort),
                             cProbe_Connect_Timeout_MSec,
                             cProbe_Data_Timeout_MSec);
    try
      VTicks:=GetTickCount;
      WaitForProbeThread(VThread);
      Check(VThread.Finished, 'the probe did not finish in time');
      Check((GetTickCount-VTicks)<cRefused_Detect_Timeout_MSec,
            'a refused connection is not detected at once (it is reported as a timeout)');
      Check(tpr_ConnectError=VThread.Info.Kind,
            'the refused connection is not reported as a connect error: '+IntToStr(Integer(VThread.Info.Kind)));
      Check(WSAECONNREFUSED=DWORD(VThread.Info.LastError),
            'unexpected winsock error: '+IntToStr(VThread.Info.LastError));
    finally
      FreeProbeThread(VThread);
    end;
  finally
    WSACleanup;
  end;
end;

procedure Tvsagps_tcp_checker_test.TestProbeInvalidParams;
var
  VThread: TProbeThread;
begin
  // no WSAStartup here - the probe must report the bad name before winsock
  // is used; both names below have no port part
  VThread:=MakeProbeThread('127.0.0.1', cProbe_Connect_Timeout_MSec, cProbe_Data_Timeout_MSec);
  try
    WaitForProbeThread(VThread);
    Check(VThread.Finished, 'the probe did not finish in time');
    Check(tpr_InvalidParams=VThread.Info.Kind,
          'the bad name is not reported as invalid params: '+IntToStr(Integer(VThread.Info.Kind)));
  finally
    FreeProbeThread(VThread);
  end;
end;

initialization
  RegisterTest(Tvsagps_tcp_checker_test.Suite);

end.
