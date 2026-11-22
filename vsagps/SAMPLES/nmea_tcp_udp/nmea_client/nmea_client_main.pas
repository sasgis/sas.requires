unit nmea_client_main;
(*
  Simple manual testing tool: an NMEA0183 client over TCP or UDP, which
  shows the event lines and logs the received stream.

  TCP mode (the transport of the tcp nmea device of the library): connects
  to "host:port", the optional gpsd auto-detection sends ?WATCH on the
  greeting banner.

  UDP mode (the transport of the udp nmea device of the library): the
  "Local addr" field holds the local listener address by the same grammar
  as the device ("port" / "0.0.0.0:port" / "addr:port" - the way to receive
  subnet broadcasts on Windows / "multicast_group:port"); the client binds
  it and receives the datagrams from anyone. There is no connecting phase.
  With the auto-reconnect enabled the client re-binds after the given
  seconds of silence (the same idle-watchdog cycle the udp device runs -
  the emulated stalls of the server look exactly like this).

  Command line: "nmea_client.exe addr:port" - fills the fields and starts
  the connection automatically on start.
    /transport=tcp|udp - the transport (default: tcp)
    /r                 - enable auto-reconnect
    /nmealog[=path]    - save the raw received nmea stream to the log file
                         (default: <exe>.nmea.log)
    /evlog[=path]      - save the event lines to the log file
                         (default: <exe>.events.log; /tcplog is an alias)
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
  vsagps_winsock2_compat,
  nmea_tools_common;

type
  TClientState = (csDisconnected, csConnecting, csConnected);

  TfrmNmeaClient = class(TForm)
    lblHost: TLabel;
    lblPort: TLabel;
    lblStatus: TLabel;
    edHost: TEdit;
    edPort: TEdit;
    btnConnect: TButton;
    btnDisconnect: TButton;
    rgTransport: TRadioGroup;
    chkGpsdAuto: TCheckBox;
    chkAutoReconnect: TCheckBox;
    edRetrySec: TEdit;
    lblRetrySec: TLabel;
    gbLogging: TGroupBox;
    chkLogNmea: TCheckBox;
    chkLogEvents: TCheckBox;
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
    procedure TransportChanged(Sender: TObject);
  private
    FLog: TNmeaToolLog; // the paired log (raw nmea + event lines)
    FSocket: TSocket;
    FState: TClientState;
    FConnectDeadline: DWORD;
    FNextRetryTick: DWORD;
    FIdleDeadline: DWORD; // udp: no data for this long - the session ends (the auto-reconnect re-binds)
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
    FTotalNetErr: Integer; // connect/timeout/select/recv failures
    FTotalConn: Integer;  // established connections
    FLineBuf: AnsiString; // the received data split into complete lines
    FLastFlushTick: Cardinal;
    FAutoConnect: Boolean; // from the command line
  private
    function IsUdp: Boolean;
    procedure AppendMemoLines(const AList: TStrings);
    procedure LogEvent(const S: string);   // timestamped pending line (the timer shows it)
    procedure DrainPendingEvents;          // pending -> memo + file (the timer calls it)
    procedure DoConnect;
    procedure DoDisconnect(const AReason: string; const AIsError: Boolean = FALSE);
    procedure DoTick;
    procedure ProcessReceived(const AData: AnsiString; const AFrom: PSockAddrIn);
    procedure UpdateCounters;
    procedure UpdateStatus;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure ApplyCommandLine(out ANmeaLogName, AEventLogName: string);
  end;

var
  frmNmeaClient: TfrmNmeaClient;

implementation

{$R *.dfm}

const
  cConnect_Timeout_MSec = 5000;
  cLogLines             = 500;   // event memo lines kept
  cNmeaLogExt           = '.nmea.log'; // ChangeFileExt() of the exe name
  cEventLogExt          = '.events.log';
  cFlushIntervalMSec    = 1000;  // the nmea log is written once per second
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

{ TfrmNmeaClient }

procedure TfrmNmeaClient.FormCreate(Sender: TObject);
var
  VWSA: TWSAData;
  VNmeaLogName, VEventLogName: string;
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
  FTotalNetErr := 0;
  FTotalConn := 0;
  FLineBuf := '';

  if (WSAStartup(cNmeaTool_WSA_Version_2_2, VWSA) <> 0) then begin
    lblStatus.Caption := 'WSAStartup failed!';
    Exit;
  end;

  // the settings and the command line are applied before the log is created:
  // the command line may redefine the log file paths
  VNmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt);
  VEventLogName := ChangeFileExt(Application.ExeName, cEventLogExt);
  LoadSettings;
  ApplyCommandLine(VNmeaLogName, VEventLogName);
  chkLogNmea.Hint := 'Saves the raw received NMEA stream to the file:'#13#10 + VNmeaLogName;
  chkLogEvents.Hint := 'Saves the event lines to the file:'#13#10 + VEventLogName;
  FLog := TNmeaToolLog.Create(VNmeaLogName, VEventLogName);
  FLog.SetNmeaEnabled(chkLogNmea.Checked);
  FLog.SetEventEnabled(chkLogEvents.Checked);

  TransportChanged(rgTransport);
  UpdateStatus;
  // the work timer is armed last: it must not tick while the form is
  // being created
  tmrWork.Enabled := TRUE;
end;

procedure TfrmNmeaClient.ApplyCommandLine(out ANmeaLogName, AEventLogName: string);
var
  i, p: Integer;
  s, VRest: string;
begin
  // headless mode for automated testing (see the unit header); the log path
  // keys are applied through the out parameters (the log is not created yet)
  ANmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt);
  AEventLogName := ChangeFileExt(Application.ExeName, cEventLogExt);
  for i := 1 to ParamCount do begin
    s := ParamStr(i);
    if s.StartsWith('/nmealog', True) then begin
      VRest := Copy(s, Length('/nmealog') + 1, MaxInt);
      if (0 = Length(VRest)) then
        ANmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt)
      else if (VRest[1] = '=') then
        ANmeaLogName := Copy(VRest, 2, MaxInt)
      else
        Continue;
      chkLogNmea.Checked := TRUE;
    end else if s.StartsWith('/evlog', True) or s.StartsWith('/tcplog', True) then begin
      if s.StartsWith('/evlog', True) then
        VRest := Copy(s, Length('/evlog') + 1, MaxInt)
      else
        VRest := Copy(s, Length('/tcplog') + 1, MaxInt);
      if (0 = Length(VRest)) then
        AEventLogName := ChangeFileExt(Application.ExeName, cEventLogExt)
      else if (VRest[1] = '=') then
        AEventLogName := Copy(VRest, 2, MaxInt)
      else
        Continue;
      chkLogEvents.Checked := TRUE;
    end else if SameText(s, '/r') then begin
      chkAutoReconnect.Checked := True;
    end else if s.StartsWith('/transport=', True) then begin
      VRest := AnsiUpperCase(Copy(s, Length('/transport=') + 1, MaxInt));
      if ('UDP' = VRest) then
        rgTransport.ItemIndex := 1
      else if ('TCP' = VRest) then
        rgTransport.ItemIndex := 0;
    end else begin
      // "addr:port" (a log path with a drive letter never gets here); it is
      // the remote server for the tcp transport and the local listener
      // address for the udp one
      p := Pos(':', s);
      if (p > 1) then begin
        edHost.Text := Trim(Copy(s, 1, p - 1));
        edPort.Text := Trim(Copy(s, p + 1, MaxInt));
        FAutoConnect := True;
      end;
    end;
  end;
end;

procedure TfrmNmeaClient.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  DoDisconnect('application closed');
  FreeAndNil(FLog);
  WSACleanup;
end;

procedure TfrmNmeaClient.LoadSettings;
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
    rgTransport.ItemIndex := ini.ReadInteger('Connection', 'Transport', 0);
    TransportChanged(rgTransport);
    chkLogNmea.Checked := ini.ReadBool('Logging', 'NmeaToFile', False);
    chkLogEvents.Checked := ini.ReadBool('Logging', 'EventsToFile', False);
  finally
    ini.Free;
  end;
end;

procedure TfrmNmeaClient.SaveSettings;
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
    ini.WriteInteger('Connection', 'Transport', rgTransport.ItemIndex);
    ini.WriteBool('Logging', 'NmeaToFile', chkLogNmea.Checked);
    ini.WriteBool('Logging', 'EventsToFile', chkLogEvents.Checked);
  finally
    ini.Free;
  end;
end;


procedure TfrmNmeaClient.AppendMemoLines(const AList: TStrings);
var
  i: Integer;
begin
  mmLog.Lines.BeginUpdate;
  try
    for i := 0 to AList.Count - 1 do
      mmLog.Lines.Append(AList[i]);
    while (mmLog.Lines.Count > cLogLines) do
      mmLog.Lines.Delete(0);
  finally
    mmLog.Lines.EndUpdate;
  end;
  SendMessage(mmLog.Handle, EM_LINESCROLL, 0, mmLog.Lines.Count);
end;

procedure TfrmNmeaClient.LogEvent(const S: string);
begin
  // the event line is timestamped by the log class; the timer drains it
  // into the memo and the file (this tool is single-threaded, the drain
  // keeps the same order)
  FLog.LogEvent(S);
end;

procedure TfrmNmeaClient.DrainPendingEvents;
var
  VList: TStringList;
begin
  VList := TStringList.Create;
  try
    FLog.DrainEvents(VList);
    if (0 < VList.Count) then begin
      AppendMemoLines(VList);
      FLog.WriteEventFile(VList);
    end;
    // a file error may have disabled the logging from inside - sync the
    // checkboxes back (no OnClick fires on a programmatic change)
    if chkLogNmea.Checked and (not FLog.GetNmeaEnabled) then
      chkLogNmea.Checked := False;
    if chkLogEvents.Checked and (not FLog.GetEventEnabled) then
      chkLogEvents.Checked := False;
  finally
    VList.Free;
  end;
end;

procedure TfrmNmeaClient.LogParamChanged(Sender: TObject);
begin
  // the checkboxes mirror the log enable flags (a file error may have
  // disabled the logging from inside - sync the checkbox back)
  if (FLog = nil) then
    Exit; // the log is created after the command line is applied (FormCreate)
  FLog.SetNmeaEnabled(chkLogNmea.Checked);
  FLog.SetEventEnabled(chkLogEvents.Checked);
end;

function TfrmNmeaClient.IsUdp: Boolean;
begin
  Result := (rgTransport.ItemIndex = 1);
end;

procedure TfrmNmeaClient.TransportChanged(Sender: TObject);
begin
  // the address field semantics depend on the transport
  if IsUdp then begin
    lblHost.Caption := 'Local addr:';
    edHost.Hint := 'The local listener address (the same grammar as the nmea' +
      ' udp device): a port, "0.0.0.0:port", "addr:port" (the way to receive' +
      ' subnet broadcasts on Windows) or "multicast_group:port"';
    chkGpsdAuto.Enabled := False;
    chkAutoReconnect.Caption := 'Re-bind after idle (sec):';
  end else begin
    lblHost.Caption := 'Host:';
    edHost.Hint := '';
    chkGpsdAuto.Enabled := True;
    chkAutoReconnect.Caption := 'Auto-reconnect every';
  end;
  UpdateStatus;
end;

procedure TfrmNmeaClient.UpdateStatus;
begin
  case FState of
    csConnecting:
      lblStatus.Caption := 'connecting to ' + edHost.Text + ':' + edPort.Text + '...';
    csConnected: begin
      if IsUdp then
        lblStatus.Caption := 'listening on ' + edHost.Text + ':' + edPort.Text
      else
        lblStatus.Caption := 'connected';
    end;
  else
    lblStatus.Caption := 'disconnected';
  end;
  btnConnect.Enabled := (FState = csDisconnected);
  btnDisconnect.Enabled := (FState <> csDisconnected);
  // the transport is fixed at the connect - no switching while connected
  rgTransport.Enabled := (FState = csDisconnected);
end;

procedure TfrmNmeaClient.btnConnectClick(Sender: TObject);
begin
  DoConnect;
end;

procedure TfrmNmeaClient.btnDisconnectClick(Sender: TObject);
begin
  // the user disconnect pauses the auto-reconnect until the next connect
  // (the checkbox state is kept as is)
  FAutoReconnectPaused := TRUE;
  DoDisconnect('disconnected by user');
  if chkAutoReconnect.Checked then
    LogEvent('receiving suspended - auto-reconnect paused (the Connect button resumes it)');
end;

procedure TfrmNmeaClient.DoConnect;
var
  sHost, sPort: AnsiString;
  VHints: TAddrInfoA;
  VAddrList, VAddr: Paddrinfo;
  VSocket: TSocket;
  VNonBlocking: u_long;
  VErr: Integer;
begin
  if (FState <> csDisconnected) then
    Exit;

  // a connect (manual or automatic) resumes the auto-reconnect paused earlier
  FAutoReconnectPaused := FALSE;

  // the address is taken from the fields
  // (the command line form "addr:port" is split in FormCreate)
  sHost := AnsiString(Trim(edHost.Text));
  sPort := AnsiString(Trim(edPort.Text));
  if (0 = Length(sHost)) or (0 = Length(sPort)) then begin
    LogEvent('invalid host/port!');
    Exit;
  end;

  if IsUdp then begin
    // the listener bind by the nmea udp device name grammar: there is no
    // connecting phase at all - the socket is ready (or the bind failed)
    FSocket := NmeaTool_CreateUdpListener(sHost + AnsiString(':') + sPort, VErr);
    if (INVALID_SOCKET = FSocket) then begin
      LogEvent('bind failed (' + string(sHost) + ':' + string(sPort) + '): ' + SysErrorMessage(VErr));
      Exit;
    end;
    // the shared helper returns a blocking socket; the timer-driven receive
    // loop drains the queue with repeated recvfrom calls (DoTick): the first
    // call on an already empty queue would park the ui thread until the next
    // datagram arrives (and the next one, and so on - the window freezes,
    // then the counters jump by dozens of packets at once). The socket is
    // switched to the non-blocking mode exactly like the tcp one below, so
    // the drained queue reports WSAEWOULDBLOCK instead of waiting
    VNonBlocking := 1;
    if (0 <> ioctlsocket(FSocket, Longint(FIONBIO), VNonBlocking)) then begin
      VErr := WSAGetLastError;
      closesocket(FSocket);
      FSocket := INVALID_SOCKET;
      LogEvent('cannot switch the udp listener to the non-blocking mode: ' + SysErrorMessage(VErr));
      Exit;
    end;
    FState := csConnected;
    FDataStarted := FALSE;
    Inc(FTotalConn);
    LogEvent('bound to ' + string(sHost) + ':' + string(sPort) + ' - listening');
    // the idle deadline is armed with the auto-reconnect: no data for the
    // given seconds ends the session and the re-bind follows (the same
    // idle-watchdog cycle the udp device runs)
    if chkAutoReconnect.Checked then
      FIdleDeadline := GetTickCount + Cardinal(Max(1, StrToIntDef(edRetrySec.Text, 3))) * 1000;
    UpdateStatus;
    Exit;
  end;

  ZeroMemory(@VHints, sizeof(VHints));
  VHints.ai_family := AF_UNSPEC;
  VHints.ai_socktype := SOCK_STREAM;
  VHints.ai_protocol := IPPROTO_TCP;

  if (0 <> getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList)) then begin
    LogEvent('getaddrinfo failed for "' + string(sHost) + '": ' + IntToStr(WSAGetLastError));
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
      LogEvent('connect failed: ' + SysErrorMessage(WSAGetLastError));
      Exit;
    end;

    FSocket := VSocket;
    FState := csConnecting;
    FConnectDeadline := GetTickCount + cConnect_Timeout_MSec;
    LogEvent('connecting to ' + edHost.Text + ':' + edPort.Text + '...');
  finally
    freeaddrinfo(VAddrList^);
  end;
  UpdateStatus;
end;

procedure TfrmNmeaClient.DoDisconnect(const AReason: string; const AIsError: Boolean);
begin
  if (FSocket <> INVALID_SOCKET) then begin
    closesocket(FSocket);
    FSocket := INVALID_SOCKET;
  end;
  if (FState <> csDisconnected) then begin
    LogEvent('disconnected (' + AReason + ')');
    if AIsError then
      Inc(FTotalNetErr);
    FNextRetryTick := GetTickCount + Cardinal(Max(1, StrToIntDef(edRetrySec.Text, 3))) * 1000;
  end;
  FState := csDisconnected;
  UpdateStatus;
end;

procedure TfrmNmeaClient.tmrWorkTimer(Sender: TObject);
begin
  DoTick;
end;

procedure TfrmNmeaClient.DoTick;
var
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VRes, VReceived, VErr, VOptLen, VGuard, VSent: Integer;
  VBuf: array [0..4095] of AnsiChar;
  VFrom: TSockAddr;    // the RTL recvfrom takes the var TSockAddr
  VFromLen: Integer;
  VGotData: Boolean;
begin
  // the timer drains the pending event lines into the memo and flushes the
  // buffered raw nmea data at least once per second
  DrainPendingEvents;
  if ((GetTickCount - FLastFlushTick) >= cFlushIntervalMSec) then begin
    FLastFlushTick := GetTickCount;
    FLog.FlushNmeaFile;
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
          LogEvent('connected');
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
      VGotData := FALSE;
      FD_ZERO(VSet);
      _FD_SET(FSocket, VSet);
      VTimeout.tv_sec := 0;
      VTimeout.tv_usec := 0;
      VRes := select(0, @VSet, nil, nil, @VTimeout);
      if (SOCKET_ERROR = VRes) then begin
        DoDisconnect('select error ' + IntToStr(WSAGetLastError), TRUE);
      end else if (VRes > 0) then begin
        // drain everything available (bounded - the socket is non-blocking,
        // and the udp readiness is re-checked before every datagram anyway,
        // so the ui thread can never be parked inside recvfrom)
        VGuard := 0;
        VReceived := 0;
        repeat
          if IsUdp then begin
            FD_ZERO(VSet);
            _FD_SET(FSocket, VSet);
            VTimeout.tv_sec := 0;
            VTimeout.tv_usec := 0;
            VRes := select(0, @VSet, nil, nil, @VTimeout);
            if (0 = VRes) then
              Break; // the datagram queue is drained
            if (SOCKET_ERROR = VRes) then begin
              VReceived := SOCKET_ERROR;
              VErr := WSAGetLastError;
              Break;
            end;
            VFromLen := sizeof(VFrom);
            VReceived := recvfrom(FSocket, VBuf[0], sizeof(VBuf), 0, VFrom, VFromLen);
          end else
            VReceived := recv(FSocket, VBuf[0], sizeof(VBuf), 0);
          if (VReceived < 0) then
            VErr := WSAGetLastError // read at once - the log calls change it
          else
            VErr := 0;
          if (VReceived > 0) then begin
            if IsUdp then
              ProcessReceived(Copy(VBuf, 1, VReceived), PSockAddrIn(@VFrom))
            else
              ProcessReceived(Copy(VBuf, 1, VReceived), nil);
            Inc(VGuard);
            VGotData := TRUE;
          end;
        until (VReceived <= 0) or (VGuard >= 64);

        if (not IsUdp) and (VReceived = 0) then begin
          DoDisconnect('closed by peer');
        end else if (VReceived < 0) and (WSAEWOULDBLOCK <> VErr) then begin
          DoDisconnect('recv error ' + IntToStr(VErr), TRUE);
        end else begin
          UpdateStatus;
        end;
      end;

      // udp: the idle deadline - a source which is silent for too long ends
      // the session, the auto-reconnect re-binds (the same cycle the udp
      // device runs; the emulated stalls of the server look like this)
      if IsUdp and chkAutoReconnect.Checked and (FState = csConnected) then begin
        if VGotData then
          FIdleDeadline := GetTickCount + Cardinal(Max(1, StrToIntDef(edRetrySec.Text, 3))) * 1000
        else if ((GetTickCount - FIdleDeadline) < $80000000) then begin
          DoDisconnect('idle timeout - session ended');
          Exit;
        end;
      end;

      // tcp: gpsd auto-detection - the greeting banner is looked for in the
      // accumulated probe data within the short window after the connect
      // (the same protocol the tcp nmea device speaks)
      if (not IsUdp) and FGpsdProbing and (not FGpsdWatching) and (INVALID_SOCKET <> FSocket) then begin
        if (0 < Pos(cGpsd_Version_Prefix, FProbeBuf)) then begin
          VSent := send(FSocket, PAnsiChar(cGpsd_Watch_Cmd)^, Length(cGpsd_Watch_Cmd), 0);
          if (VSent = Length(cGpsd_Watch_Cmd)) then begin
            FGpsdWatching := TRUE;
            LogEvent('gpsd detected - ?WATCH sent');
          end else begin
            // a partial send or a full send buffer - not retried (the
            // failure is visible in the log, the user reconnects)
            FGpsdProbing := FALSE;
            LogEvent('gpsd detected but the WATCH send failed: ' + IntToStr(WSAGetLastError));
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

procedure TfrmNmeaClient.ProcessReceived(const AData: AnsiString; const AFrom: PSockAddrIn);
var
  p: Integer;
  line: AnsiString;
begin
  // the first data of the connection is reported in the memo (the stream
  // itself is not shown there - it goes to the nmea log)
  if (not FDataStarted) then begin
    FDataStarted := TRUE;
    if (nil <> AFrom) then
      LogEvent('receiving NMEA data from ' + NmeaTool_PeerOf(AFrom^))
    else
      LogEvent('receiving NMEA data started');
  end;

  // the received stream is not shown in the memo (it shows the events only);
  // the raw bytes go to the nmea log
  FLog.LogNmeaRaw(AData);

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

procedure TfrmNmeaClient.UpdateCounters;
begin
  sbStatus.Panels[0].Text := 'in: ' + IntToStr(FTotalBytes) + ' b';
  sbStatus.Panels[1].Text := 'nmea: ' + IntToStr(FTotalNmea) +
    ' (err: ' + IntToStr(FTotalNmeaErr) + ')';
  sbStatus.Panels[2].Text := 'json: ' + IntToStr(FTotalJson);
  sbStatus.Panels[3].Text := 'net err: ' + IntToStr(FTotalNetErr) +
    ', conn: ' + IntToStr(FTotalConn);
end;

end.
