unit tcp_nmea_client_main;
(*
  Simple manual testing tool: a TCP client which connects to an NMEA0183
  server, shows the tcp events and logs the received stream.

  Command line: "tcp_nmea_client.exe host:port" - fills the fields and
  connects automatically on start.
    /r              - enable auto-reconnect
    /nmealog[=path] - save the raw received nmea stream to the log file
                      (default: <exe>.nmea.log)
    /tcplog[=path]  - save the tcp events to the log file
                      (default: <exe>.tcp.log)
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Math,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  IniFiles,
  Winsock2,
  vsagps_winsock2_compat;

type
  TClientState = (csDisconnected, csConnecting, csConnected);

  TfrmTcpNmeaClient = class(TForm)
    lblHost: TLabel;
    lblPort: TLabel;
    lblStatus: TLabel;
    edHost: TEdit;
    edPort: TEdit;
    btnConnect: TButton;
    btnDisconnect: TButton;
    chkGpsdAuto: TCheckBox;
    chkAutoReconnect: TCheckBox;
    edRetrySec: TEdit;
    lblRetrySec: TLabel;
    gbLogging: TGroupBox;
    chkLogNmea: TCheckBox;
    chkLogTcp: TCheckBox;
    gbLog: TGroupBox;
    mmLog: TMemo;
    sbStatus: TStatusBar;
    tmrWork: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure tmrWorkTimer(Sender: TObject);
    procedure LogParamChanged(Sender: TObject);
  private
    FSocket: TSocket;
    FState: TClientState;
    FConnectDeadline: DWORD;
    FNextRetryTick: DWORD;
    FAutoReconnectPaused: Boolean; // set by the user disconnect, cleared by the next connect
    FDataStarted: Boolean; // the "receiving NMEA data started" line is logged for this connection
    // gpsd auto-detection (armed at the connect when the checkbox is set)
    FGpsdProbing: Boolean;  // the detection window is active
    FGpsdWatching: Boolean; // the WATCH was sent (or the detection gave up)
    FGpsdDeadline: DWORD;
    FProbeBuf: AnsiString;  // the received data accumulated for the detection
    // status bar counters (totals - they survive the reconnects)
    FTotalBytes: Int64;   // all bytes received from the servers
    FTotalNmea: Int64;    // complete nmea sentences with a valid checksum
    FTotalNmeaErr: Int64; // nmea sentences with a broken checksum
    FTotalJson: Int64;    // complete json messages (gpsd reports)
    FTotalTcpErr: Integer; // connect/timeout/select/recv failures
    FTotalConn: Integer;  // established connections
    FLineBuf: AnsiString; // the received data split into complete lines
    // file logs (the files are opened on demand)
    FNmeaBuf: TMemoryStream;  // raw nmea bytes not flushed to the nmea log yet
    FNmeaFile: TFileStream;
    FTcpFile: TFileStream;
    FNmeaLogName: string;
    FTcpLogName: string;
    FNmeaLogFresh: Boolean;   // the file is created (not appended) on the next open
    FTcpLogFresh: Boolean;
    FLastFlushTick: Cardinal;
    FAutoConnect: Boolean; // from the command line
  private
    procedure AppendMemoLine(const ALine: string);
    procedure LogTcp(const S: string);
    procedure LogNmeaRaw(const AData: AnsiString);
    procedure FlushNmeaFile;
    procedure WriteNmeaFile(const AData: AnsiString);
    procedure WriteTcpFile(const S: string);
    procedure CloseLogFiles;
    procedure DoConnect;
    procedure DoDisconnect(const AReason: string; const AIsError: Boolean = FALSE);
    procedure DoTick;
    procedure ProcessReceived(const AData: AnsiString);
    procedure UpdateCounters;
    procedure UpdateStatus;
    procedure LoadSettings;
    procedure SaveSettings;
  end;

var
  frmTcpNmeaClient: TfrmTcpNmeaClient;

implementation

{$R *.dfm}

const
  cWSA_Version_2_2 = $0202; // (the RTL winsock unit does not declare it)

  cConnect_Timeout_MSec = 5000;
  cLogLines             = 500;   // tcp event memo lines kept
  cNmeaBufSize          = 65536; // raw nmea bytes buffered before a disk write
  cFlushIntervalMSec    = 1000;  // the nmea log is written once per second
  cNmeaLogExt           = '.nmea.log'; // ChangeFileExt() of the exe name
  cTcpLogExt            = '.tcp.log';
  cLineBufMaxSize       = 65536; // an incomplete garbage line is dropped beyond this

  // gpsd auto-detection: within this window after the connect the received
  // data is checked for the greeting banner (gpsd sends it immediately)
  cGpsdDetect_Timeout_MSec = 2000;
  cGpsd_Version_Prefix: AnsiString = '{"class":"VERSION"';
  // makes the gpsd server stream the raw nmea sentences
  cGpsd_Watch_Cmd: AnsiString = '?WATCH={"enable":true,"nmea":true}'#13#10;
  cProbeBufMaxSize = 65536; // a greeting flood without the banner is dropped

// validate the nmea checksum of one complete sentence ("$...*hh");
// non-nmea lines (without the starter) are not errors
function NmeaChecksumOk(const ALine: AnsiString): Boolean;
var
  i, p, v: Integer;
  cs: Byte;
begin
  Result := FALSE;
  if (Length(ALine) < 5) or (ALine[1] <> '$') then
    Exit;
  p := Pos(AnsiString('*'), ALine);
  if (p < 3) or (p + 2 > Length(ALine)) then
    Exit;
  cs := 0;
  for i := 2 to p - 1 do
    cs := cs xor Byte(ALine[i]);
  v := StrToIntDef('$' + string(System.Copy(ALine, p + 1, 2)), -1);
  Result := (v >= 0) and (Byte(v) = cs);
end;

// open a log file for appending: a fresh file for every run, then the file is
// reopened with the shared mode so it can be read/tailed while the tool runs
function OpenLogStream(const AFileName: string; const AFresh: Boolean): TFileStream;
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

{ TfrmTcpNmeaClient }

procedure TfrmTcpNmeaClient.FormCreate(Sender: TObject);
var
  VWSA: TWSAData;
  i, p: Integer;
  s, VRest: string;
begin
  FSocket := INVALID_SOCKET;
  FState := csDisconnected;
  FAutoReconnectPaused := FALSE;
  FDataStarted := FALSE;
  FGpsdProbing := FALSE;
  FGpsdWatching := FALSE;
  FGpsdDeadline := 0;
  FProbeBuf := '';
  FTotalBytes := 0;
  FTotalNmea := 0;
  FTotalNmeaErr := 0;
  FTotalJson := 0;
  FTotalTcpErr := 0;
  FTotalConn := 0;
  FLineBuf := '';
  FNmeaBuf := TMemoryStream.Create;
  FNmeaFile := nil;
  FTcpFile := nil;
  FNmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt);
  FTcpLogName := ChangeFileExt(Application.ExeName, cTcpLogExt);
  FNmeaLogFresh := TRUE;
  FTcpLogFresh := TRUE;

  if (WSAStartup(cWSA_Version_2_2, VWSA) <> 0) then begin
    lblStatus.Caption := 'WSAStartup failed!';
    Exit;
  end;

  LoadSettings;

  // command line: "host:port" (and the optional keys)
  for i := 1 to ParamCount do begin
    s := ParamStr(i);
    if s.StartsWith('/nmealog', True) then begin
      VRest := Copy(s, Length('/nmealog') + 1, MaxInt);
      if (0 = Length(VRest)) then
        FNmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt)
      else if (VRest[1] = '=') then
        FNmeaLogName := Copy(VRest, 2, MaxInt)
      else
        Continue;
      chkLogNmea.Checked := TRUE;
    end else if s.StartsWith('/tcplog', True) then begin
      VRest := Copy(s, Length('/tcplog') + 1, MaxInt);
      if (0 = Length(VRest)) then
        FTcpLogName := ChangeFileExt(Application.ExeName, cTcpLogExt)
      else if (VRest[1] = '=') then
        FTcpLogName := Copy(VRest, 2, MaxInt)
      else
        Continue;
      chkLogTcp.Checked := TRUE;
    end else if SameText(s, '/r') then begin
      chkAutoReconnect.Checked := True;
    end else begin
      // "host:port" (a log path with a drive letter never gets here)
      p := Pos(':', s);
      if (p > 1) then begin
        edHost.Text := Trim(Copy(s, 1, p - 1));
        edPort.Text := Trim(Copy(s, p + 1, MaxInt));
        FAutoConnect := True;
      end;
    end;
  end;
  // the log file paths are shown in the checkbox hints
  // (after the command line parsing - the paths may be redefined by the keys)
  chkLogNmea.Hint := 'Saves the raw received NMEA stream to the file:'#13#10 + FNmeaLogName;
  chkLogTcp.Hint := 'Saves the tcp events to the file:'#13#10 + FTcpLogName;

  UpdateStatus;
end;

procedure TfrmTcpNmeaClient.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  DoDisconnect('application closed');
  FlushNmeaFile;
  CloseLogFiles;
  FreeAndNil(FNmeaBuf);
  WSACleanup;
end;

procedure TfrmTcpNmeaClient.LoadSettings;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    edHost.Text := ini.ReadString('Connection', 'Host', edHost.Text);
    edPort.Text := ini.ReadString('Connection', 'Port', edPort.Text);
    chkAutoReconnect.Checked := ini.ReadBool('Connection', 'AutoReconnect', False);
    edRetrySec.Text := ini.ReadString('Connection', 'RetrySec', edRetrySec.Text);
    chkGpsdAuto.Checked := ini.ReadBool('Connection', 'GpsdAuto', False);
    chkLogNmea.Checked := ini.ReadBool('Logging', 'NmeaToFile', False);
    chkLogTcp.Checked := ini.ReadBool('Logging', 'TcpToFile', False);
  finally
    ini.Free;
  end;
end;

procedure TfrmTcpNmeaClient.SaveSettings;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    ini.WriteString('Connection', 'Host', edHost.Text);
    ini.WriteString('Connection', 'Port', edPort.Text);
    ini.WriteBool('Connection', 'AutoReconnect', chkAutoReconnect.Checked);
    ini.WriteString('Connection', 'RetrySec', edRetrySec.Text);
    ini.WriteBool('Connection', 'GpsdAuto', chkGpsdAuto.Checked);
    ini.WriteBool('Logging', 'NmeaToFile', chkLogNmea.Checked);
    ini.WriteBool('Logging', 'TcpToFile', chkLogTcp.Checked);
  finally
    ini.Free;
  end;
end;

procedure TfrmTcpNmeaClient.AppendMemoLine(const ALine: string);
begin
  mmLog.Lines.BeginUpdate;
  try
    mmLog.Lines.Append(ALine);
    while (mmLog.Lines.Count > cLogLines) do
      mmLog.Lines.Delete(0);
  finally
    mmLog.Lines.EndUpdate;
  end;
  SendMessage(mmLog.Handle, EM_LINESCROLL, 0, mmLog.Lines.Count);
end;

procedure TfrmTcpNmeaClient.LogTcp(const S: string);
var
  VLine: string;
begin
  // the tcp event line is timestamped once and goes to the memo and the log file
  VLine := '[' + FormatDateTime('hh:nn:ss.zzz', Now) + '] ' + S;
  AppendMemoLine(VLine);
  if chkLogTcp.Checked then
    WriteTcpFile(VLine);
end;

procedure TfrmTcpNmeaClient.LogNmeaRaw(const AData: AnsiString);
begin
  // raw nmea data - exactly the bytes received from the server, no formatting
  // at all; the buffer is flushed by the timer
  if (0 = Length(AData)) or (not chkLogNmea.Checked) then
    Exit;
  FNmeaBuf.WriteBuffer(PAnsiChar(AData)^, Length(AData));
  if (FNmeaBuf.Size >= cNmeaBufSize) then
    FlushNmeaFile;
end;

procedure TfrmTcpNmeaClient.FlushNmeaFile;
var
  VData: AnsiString;
begin
  if (0 = FNmeaBuf.Size) then
    Exit;
  SetLength(VData, Integer(FNmeaBuf.Size));
  Move(FNmeaBuf.Memory^, PAnsiChar(VData)^, FNmeaBuf.Size);
  FNmeaBuf.Size := 0;
  WriteNmeaFile(VData);
end;

procedure TfrmTcpNmeaClient.WriteNmeaFile(const AData: AnsiString);
begin
  // the log must never break the tool: on a file error the logging is
  // switched off (the checkbox is cleared, no OnClick is fired) and the
  // reason is reported in the tcp events log
  try
    if (FNmeaFile = nil) then begin
      FNmeaFile := OpenLogStream(FNmeaLogName, FNmeaLogFresh);
      FNmeaLogFresh := FALSE;
    end;
    FNmeaFile.WriteBuffer(PAnsiChar(AData)^, Length(AData));
  except
    on E: Exception do begin
      FreeAndNil(FNmeaFile);
      chkLogNmea.Checked := FALSE;
      LogTcp('nmea log file "' + FNmeaLogName + '" failed, logging disabled: ' + E.Message);
    end;
  end;
end;

procedure TfrmTcpNmeaClient.WriteTcpFile(const S: string);
var
  VData: UTF8String;
begin
  VData := UTF8String(S + #13#10);
  try
    if (FTcpFile = nil) then begin
      FTcpFile := OpenLogStream(FTcpLogName, FTcpLogFresh);
      FTcpLogFresh := FALSE;
    end;
    FTcpFile.WriteBuffer(PAnsiChar(VData)^, Length(VData));
  except
    on E: Exception do begin
      FreeAndNil(FTcpFile);
      chkLogTcp.Checked := FALSE;
      // the file is not available - the reason goes to the memo only
      AppendMemoLine('[' + FormatDateTime('hh:nn:ss.zzz', Now) +
        '] tcp log file "' + FTcpLogName + '" failed, logging disabled: ' + E.Message);
    end;
  end;
end;

procedure TfrmTcpNmeaClient.CloseLogFiles;
begin
  FreeAndNil(FNmeaFile);
  FreeAndNil(FTcpFile);
end;

procedure TfrmTcpNmeaClient.LogParamChanged(Sender: TObject);
begin
  // flush what is still buffered before the file is closed
  if (not chkLogNmea.Checked) then begin
    FlushNmeaFile;
    FreeAndNil(FNmeaFile);
  end;
  if (not chkLogTcp.Checked) then
    FreeAndNil(FTcpFile);
end;

procedure TfrmTcpNmeaClient.UpdateStatus;
begin
  case FState of
    csConnecting:
      lblStatus.Caption := 'connecting to ' + edHost.Text + ':' + edPort.Text + '...';
    csConnected:
      lblStatus.Caption := 'connected';
  else
    lblStatus.Caption := 'disconnected';
  end;
  btnConnect.Enabled := (FState = csDisconnected);
  btnDisconnect.Enabled := (FState <> csDisconnected);
end;

procedure TfrmTcpNmeaClient.btnConnectClick(Sender: TObject);
begin
  DoConnect;
end;

procedure TfrmTcpNmeaClient.btnDisconnectClick(Sender: TObject);
begin
  // the user disconnect pauses the auto-reconnect until the next connect
  // (the checkbox state is kept as is)
  FAutoReconnectPaused := TRUE;
  DoDisconnect('disconnected by user');
  if chkAutoReconnect.Checked then
    LogTcp('receiving suspended - auto-reconnect paused (the Connect button resumes it)');
end;

procedure TfrmTcpNmeaClient.DoConnect;
var
  sHost, sPort: AnsiString;
  VHints: TAddrInfoA;
  VAddrList, VAddr: Paddrinfo;
  VSocket: TSocket;
  VNonBlocking: u_long;
begin
  if (FState <> csDisconnected) then
    Exit;

  // a connect (manual or automatic) resumes the auto-reconnect paused earlier
  FAutoReconnectPaused := FALSE;

  // host and port are taken from the fields
  // (the command line form "host:port" is split in FormCreate)
  sHost := AnsiString(Trim(edHost.Text));
  sPort := AnsiString(Trim(edPort.Text));
  if (0 = Length(sHost)) or (0 = Length(sPort)) then begin
    LogTcp('invalid host/port!');
    Exit;
  end;

  ZeroMemory(@VHints, sizeof(VHints));
  VHints.ai_family := AF_UNSPEC;
  VHints.ai_socktype := SOCK_STREAM;
  VHints.ai_protocol := IPPROTO_TCP;

  if (0 <> getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList)) then begin
    LogTcp('getaddrinfo failed for "' + string(sHost) + '": ' + IntToStr(WSAGetLastError));
    Exit;
  end;

  try
    VSocket := INVALID_SOCKET;
    VAddr := VAddrList;
    while (INVALID_SOCKET = VSocket) and (nil <> VAddr) do begin
      VSocket := socket(VAddr^.ai_family, SOCK_STREAM, IPPROTO_TCP);
      if (INVALID_SOCKET = VSocket) then begin
        VAddr := VAddr^.ai_next;
        Continue;
      end;
      VNonBlocking := 1;
      // (the explicit LONGINT cast keeps FIONBIO ($8004667E) warning-free)
      ioctlsocket(VSocket, Longint(FIONBIO), VNonBlocking);
      if (0 = connect(VSocket, VAddr^.ai_addr^, Integer(VAddr^.ai_addrlen))) then
        Break; // connected immediately
      if (WSAEWOULDBLOCK <> WSAGetLastError) then begin
        closesocket(VSocket);
        VSocket := INVALID_SOCKET;
        VAddr := VAddr^.ai_next;
        Continue;
      end;
      // connecting in background
      Break;
    end;

    if (INVALID_SOCKET = VSocket) then begin
      LogTcp('connect failed: ' + SysErrorMessage(WSAGetLastError));
      Exit;
    end;

    FSocket := VSocket;
    FState := csConnecting;
    FConnectDeadline := GetTickCount + cConnect_Timeout_MSec;
    LogTcp('connecting to ' + edHost.Text + ':' + edPort.Text + '...');
  finally
    freeaddrinfo(VAddrList^);
  end;
  UpdateStatus;
end;

procedure TfrmTcpNmeaClient.DoDisconnect(const AReason: string; const AIsError: Boolean);
begin
  if (FSocket <> INVALID_SOCKET) then begin
    closesocket(FSocket);
    FSocket := INVALID_SOCKET;
  end;
  if (FState <> csDisconnected) then begin
    LogTcp('disconnected (' + AReason + ')');
    if AIsError then
      Inc(FTotalTcpErr);
    FNextRetryTick := GetTickCount + Cardinal(Max(1, StrToIntDef(edRetrySec.Text, 3))) * 1000;
  end;
  FState := csDisconnected;
  UpdateStatus;
end;

procedure TfrmTcpNmeaClient.tmrWorkTimer(Sender: TObject);
begin
  DoTick;
end;

procedure TfrmTcpNmeaClient.DoTick;
var
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VRes, VReceived, VErr, VOptLen, VGuard, VSent: Integer;
  VBuf: array [0..4095] of AnsiChar;
begin
  // flush the buffered raw nmea data at least once per second
  if ((GetTickCount - FLastFlushTick) >= cFlushIntervalMSec) then begin
    FLastFlushTick := GetTickCount;
    FlushNmeaFile;
  end;

  case FState of
    csConnecting: begin
      // wait for the socket to become writable
      FD_ZERO(VSet);
      _FD_SET(FSocket, VSet);
      VTimeout.tv_sec := 0;
      VTimeout.tv_usec := 0;
      VRes := select(0, nil, @VSet, nil, @VTimeout);
      if (VRes > 0) then begin
        VErr := 0;
        VOptLen := sizeof(VErr);
        getsockopt(FSocket, SOL_SOCKET, SO_ERROR, @VErr, VOptLen);
        if (0 = VErr) then begin
          FState := csConnected;
          FDataStarted := FALSE;
          Inc(FTotalConn);
          LogTcp('connected');
          // arm the gpsd detection window (the checkbox state is taken at
          // the connect - toggling it takes effect on the next connection)
          FGpsdProbing := chkGpsdAuto.Checked;
          FGpsdWatching := FALSE;
          FProbeBuf := '';
          if FGpsdProbing then
            FGpsdDeadline := GetTickCount + cGpsdDetect_Timeout_MSec;
        end else begin
          DoDisconnect('connect error ' + IntToStr(VErr), TRUE);
        end;
      end else if ((GetTickCount - FConnectDeadline) < $80000000) then begin
        DoDisconnect('connect timeout', TRUE);
      end;
    end;

    csConnected: begin
      FD_ZERO(VSet);
      _FD_SET(FSocket, VSet);
      VTimeout.tv_sec := 0;
      VTimeout.tv_usec := 0;
      VRes := select(0, @VSet, nil, nil, @VTimeout);
      if (SOCKET_ERROR = VRes) then begin
        DoDisconnect('select error ' + IntToStr(WSAGetLastError), TRUE);
      end else if (VRes > 0) then begin
        // drain everything available (bounded - the socket is non-blocking)
        VGuard := 0;
        repeat
          VReceived := recv(FSocket, VBuf[0], sizeof(VBuf), 0);
          if (VReceived < 0) then
            VErr := WSAGetLastError // read at once - the log calls change it
          else
            VErr := 0;
          if (VReceived > 0) then begin
            ProcessReceived(Copy(VBuf, 1, VReceived));
            Inc(VGuard);
          end;
        until (VReceived <= 0) or (VGuard >= 64);
        if (VReceived = 0) then begin
          DoDisconnect('closed by peer');
        end else if (VReceived < 0) and (WSAEWOULDBLOCK <> VErr) then begin
          DoDisconnect('recv error ' + IntToStr(VErr), TRUE);
        end else begin
          UpdateStatus;
        end;
      end;

      // gpsd auto-detection: the greeting banner is looked for in the
      // accumulated probe data within the short window after the connect
      // (the same protocol the tcp nmea device speaks)
      if FGpsdProbing and (not FGpsdWatching) and (INVALID_SOCKET <> FSocket) then begin
        if (0 < Pos(cGpsd_Version_Prefix, FProbeBuf)) then begin
          VSent := send(FSocket, PAnsiChar(cGpsd_Watch_Cmd)^, Length(cGpsd_Watch_Cmd), 0);
          if (VSent = Length(cGpsd_Watch_Cmd)) then begin
            FGpsdWatching := TRUE;
            LogTcp('gpsd detected - ?WATCH sent');
          end else begin
            // a partial send or a full send buffer - not retried (the
            // failure is visible in the log, the user reconnects)
            FGpsdProbing := FALSE;
            LogTcp('gpsd detected but the WATCH send failed: ' + IntToStr(WSAGetLastError));
          end;
          FProbeBuf := '';
        end else if ((GetTickCount - FGpsdDeadline) < $80000000) then begin
          // no gpsd greeting within the window - a regular nmea server
          FGpsdProbing := FALSE;
          FProbeBuf := '';
        end;
      end;
    end;

    csDisconnected: begin
      // auto-reconnect (also handles the command line auto-connect);
      // it stays paused after the user disconnect until the next connect
      if (not FAutoReconnectPaused) and
         (FAutoConnect or chkAutoReconnect.Checked) and
         ((GetTickCount - FNextRetryTick) < $80000000) then begin
        FAutoConnect := False;
        DoConnect;
      end;
    end;
  end;

  UpdateCounters;
end;

procedure TfrmTcpNmeaClient.ProcessReceived(const AData: AnsiString);
var
  p: Integer;
  line: AnsiString;
begin
  // the first data of the connection is reported in the memo (the stream
  // itself is not shown there - it goes to the nmea log)
  if (not FDataStarted) then begin
    FDataStarted := TRUE;
    LogTcp('receiving NMEA data started');
  end;

  // the received stream is not shown in the memo (it shows the tcp events only);
  // the raw bytes go to the nmea log
  LogNmeaRaw(AData);

  // the status bar counters: complete lines are checked for the nmea
  // checksum, the complete json lines (gpsd reports) are counted; the
  // garbage is just skipped
  FTotalBytes := FTotalBytes + Length(AData);
  FLineBuf := FLineBuf + AData;
  while (TRUE) do begin
    p := Pos(AnsiString(#10), FLineBuf);
    if (0 = p) then
      Break;
    line := System.Copy(FLineBuf, 1, p - 1);
    System.Delete(FLineBuf, 1, p);
    // the servers may end the sentence with \r\n or just \n
    if (0 < Length(line)) and (#13 = line[Length(line)]) then
      SetLength(line, Length(line) - 1);
    if (0 < Length(line)) then begin
      if ('$' = line[1]) then begin
        if NmeaChecksumOk(line) then
          Inc(FTotalNmea)
        else
          Inc(FTotalNmeaErr);
      end else if ('{' = line[1]) then begin
        Inc(FTotalJson);
      end;
    end;
  end;
  // an incomplete line without any line end for too long - drop it
  if (Length(FLineBuf) > cLineBufMaxSize) then begin
    FLineBuf := '';
    Inc(FTotalNmeaErr);
  end;

  // the gpsd detection probe accumulates the received data until the
  // banner is found or the window expires
  if FGpsdProbing and (not FGpsdWatching) then begin
    FProbeBuf := FProbeBuf + AData;
    if (Length(FProbeBuf) > cProbeBufMaxSize) then begin
      // a flood without the banner is not a gpsd greeting
      FProbeBuf := '';
      FGpsdProbing := FALSE;
    end;
  end;
end;

procedure TfrmTcpNmeaClient.UpdateCounters;
begin
  sbStatus.Panels[0].Text := 'in: ' + IntToStr(FTotalBytes) + ' b';
  sbStatus.Panels[1].Text := 'nmea: ' + IntToStr(FTotalNmea) +
    ' (err: ' + IntToStr(FTotalNmeaErr) + ')';
  sbStatus.Panels[2].Text := 'json: ' + IntToStr(FTotalJson);
  sbStatus.Panels[3].Text := 'tcp err: ' + IntToStr(FTotalTcpErr) +
    ', conn: ' + IntToStr(FTotalConn);
end;

end.
