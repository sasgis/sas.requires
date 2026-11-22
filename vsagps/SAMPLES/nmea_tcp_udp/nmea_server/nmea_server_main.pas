unit nmea_server_main;
(*
  Simple manual testing tool: an NMEA0183 server which replays a GPX track
  as an NMEA0183 stream (GGA + RMC sentences per track point) over TCP or
  UDP. The playback speed is configurable. The tool can emulate transmission
  stalls (stream pauses) and "connection drops" to check that the clients
  automatically reconnect.

  TCP mode (the transport of the tcp nmea device of the library): every
  client gets its own socket, the gpsd server mode is available.

  UDP mode (the transport of the udp nmea device of the library): the server
  binds 0.0.0.0:port and sends every datagram of the stream
  - to the fixed target (the "Target" field: an unicast address, a subnet
    broadcast address or a multicast group - the way the real muxes send);
  - to the "subscribers" - the endpoints which sent any datagram to this
    port (learned from the datagram source, expired after 10 sec of
    silence; the "Drop all clients" emulation forgets them).
  The received datagrams are drained and counted, the content is ignored.

  Command line:
    /port=N            - start the server on the given port
    /transport=tcp|udp - the transport (default: tcp)
    /target=addr:port  - the udp send target (the udp transport only)
    /gpx=path          - load the given gpx file
    /play              - start the playback after loading
    /speed=X           - playback speed multiplier
    /nmealog[=path]    - save the raw nmea stream to the log file
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
  Variants,
  Classes,
  Generics.Collections,
  Math,
  DateUtils,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  Xml.XMLIntf,
  Xml.XMLDoc,
  Winsock2,
  vsagps_winsock2_compat,
  nmea_tools_common;

type
  TNmeaCue = record
    DelayMs: Cardinal;    // delay from the previous point (real time)
    SGga: AnsiString;     // full $GPGGA sentence with tail
    SRmc: AnsiString;     // full $GPRMC sentence with tail
    // the point values for the gpsd json reports
    DLat: Double;
    DLon: Double;
    DEle: Double;
    DKts: Double;     // speed in knots (as in RMC)
    DTrack: Double;
    DTime: TDateTime; // utc
  end;
  TNmeaCueArray = array of TNmeaCue;

  TClientKind = (ckTcp, ckUdp);

  TClientInfo = record
    Kind: TClientKind;
    Socket: TSocket;    // TCP: the connected socket
    Addr: TSockAddrIn;  // UDP: the subscriber address to send to
    Peer: string;       // "ip:port"
    Watching: Boolean;  // TCP, gpsd mode: the client sent the ?WATCH command
    LastSeen: DWORD;    // UDP: GetTickCount of the last subscriber datagram
  end;

  TAcceptThread = class(TThread)
  public
    Form: TObject; // TfrmNmeaServer (to avoid a circular unit reference)
    ListenSocket: TSocket;
    procedure Execute; override;
  end;

  TfrmNmeaServer = class(TForm)
    dlgOpen: TOpenDialog;
    tmrWork: TTimer;
    panTop: TPanel;
    lblPort: TLabel;
    lblServerState: TLabel;
    edPort: TEdit;
    btnStartServer: TButton;
    btnStopServer: TButton;
    lblTarget: TLabel;
    edTarget: TEdit;
    rgTransport: TRadioGroup;
    gbTrack: TGroupBox;
    lblTrack: TLabel;
    lblSpeed: TLabel;
    lblPlayState: TLabel;
    btnOpenGpx: TButton;
    chkLoop: TCheckBox;
    edSpeed: TEdit;
    btnPlay: TButton;
    btnStopPlay: TButton;
    gbEmulation: TGroupBox;
    lblStallFor: TLabel;
    chkDrop: TCheckBox;
    edDropSec: TEdit;
    chkStall: TCheckBox;
    edStallSec: TEdit;
    edStallMs: TEdit;
    chkGpsd: TCheckBox;
    gbLogging: TGroupBox;
    chkLogNmea: TCheckBox;
    chkLogEvents: TCheckBox;
    gbClients: TGroupBox;
    lbClients: TListBox;
    spl1: TSplitter;
    gbLog: TGroupBox;
    mmLog: TMemo;
    sbStatus: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure btnStopServerClick(Sender: TObject);
    procedure btnOpenGpxClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopPlayClick(Sender: TObject);
    procedure tmrWorkTimer(Sender: TObject);
    procedure EmulParamChanged(Sender: TObject);
    procedure LogParamChanged(Sender: TObject);
    procedure TransportChanged(Sender: TObject);
  private
    FCS: TRTLCriticalSection;

    FClients: TList<TClientInfo>;
    FLog: TNmeaToolLog; // the paired log (raw nmea + event lines)
    FAcceptThread: TAcceptThread;
    FListenSocket: TSocket;
    FWSAOk: Boolean;
    FGpsdMode: Boolean; // the gpsd server emulation, fixed at the server start
    FTransportUdp: Boolean; // the transport, fixed at the server start
    FTargetAddr: TSockAddrIn; // the fixed udp send target (if any)
    FHasTarget: Boolean;
    // playback state
    FCues: TNmeaCueArray;
    FCueIdx: Integer;
    FElapsedMs: Double;
    FLastTick: DWORD;
    FPlaying: Boolean;
    FPausedByServerStop: Boolean; // the playback was paused by StopServer (resumed by StartServer)
    FLastLogDrainTick: Cardinal; // the logs are drained into the files once per second
    // emulation state
    FDropEnabled: Boolean;
    FNextDropTick: DWORD;
    FStallEnabled: Boolean;
    FStallActive: Boolean;
    FNextStallTick: DWORD;
    FStallUntilTick: DWORD;
    // counters for the status bar (the net error counter is incremented
    // from the accept thread too - hence the interlocked increment)
    FStatSentBytes: Int64;   // the nmea stream produced by the playback
    FStatSentNmea: Int64;    // the nmea sentences produced by the playback
    FStatRecvBytes: Int64;   // the bytes received from the clients
    FStatNetErr: Integer;    // send/recv/select/accept failures
  private
    procedure Lock;
    procedure Unlock;
    procedure StartServer;
    procedure StopServer;
    procedure StartPlayback;
    procedure StopPlayback;
    // called from the accept thread (the critical section is recursive)
    procedure AddAcceptedClient(const AClient: TSocket; const AAddr: TSockAddr);
    procedure RemoveClientLocked(AIndex: Integer; const AReason: string);
    procedure RemoveAllClients(const AReason: string);
    procedure SendToAllClients(const AData: AnsiString);
    procedure CheckClients;
    procedure DoWorkTick;
    procedure DrainLogs;
    procedure UpdateClientList;
    procedure UpdateCounters;
    procedure UpdateButtons;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure LoadTrackFromFile(const AFileName: string);
    procedure ApplyCommandLine(out ANmeaLogName, AEventLogName: string;
                                            out AAutoStart: Boolean);
  end;

var
  frmNmeaServer: TfrmNmeaServer;

implementation

{$R *.dfm}

uses
  IniFiles,
  vsagps_parser_nmea; // MakeNmeaFullString

const
  cMaxPointDelayMs = 1000;  // clamp huge gaps between the track times
  cMaxTrackPoints  = 200000;
  cMaxSendPerTick  = 200;   // points per timer tick (more - skip instead of catch up)
  cMaxMemoLines    = 300;   // event memo lines kept
  cMaxSkipWalk     = 100000; // hard guard for the skip loop
  cMaxElapsedBacklogMs = 10000;
  cDefPointDelayMs = 1000;  // delay per point when the track has no times
  cNmeaLogExt      = '.nmea.log'; // ChangeFileExt() of the exe name
  cEventLogExt     = '.events.log';

  // the gpsd greeting banner (sent to every client right after the accept;
  // the gpsd json lines end with a bare \n)
  cGpsd_Banner: AnsiString =
    '{"class":"VERSION","release":"nmea_server","rev":"emul",' +
    '"proto_major":3,"proto_minor":0}'#10;

var
  gFS: TFormatSettings; // invariant (dot decimal separator)

function NowUTC: TDateTime;
var
  st: TSystemTime;
begin
  GetSystemTime(st);
  Result := SystemTimeToDateTime(st);
end;

function F2(const AValue: Double; const ADigits: Integer): string;
begin
  Result := Format('%.*f', [ADigits, AValue], gFS);
end;

// degrees to "ddmm.mmmmm" (lat) or "dddmm.mmmmm" (lon) + hemisphere letter
procedure CoordToStr(const AValue: Double; const AIsLat: Boolean; out ACoord, AHemi: string);
var
  vd: Integer;
  vm: Double;
  sMin: string;
begin
  vm := Abs(AValue);
  vd := Trunc(vm);
  vm := (vm - vd) * 60;
  // the minutes "mm.mmmmm" are zero-padded to the fixed width (the delphi
  // Format pads the floats with spaces, not with zeros)
  sMin := Format('%.5f', [vm], gFS);
  while (Length(sMin) < 8) do
    Insert('0', sMin, 1);
  if AIsLat then begin
    ACoord := Format('%.2d%s', [vd, sMin], gFS);
    AHemi := 'N';
    if (AValue < 0) then
      AHemi := 'S';
  end else begin
    ACoord := Format('%.3d%s', [vd, sMin], gFS);
    AHemi := 'E';
    if (AValue < 0) then
      AHemi := 'W';
  end;
end;

// utc time "hhmmss.sss" and date "ddmmyy" for the nmea sentences
procedure TimeToStrNMEA(const AValue: TDateTime; out ATime, ADate: string);
var
  y, m, d, h, n, s, ms: Word;
begin
  DecodeDate(AValue, y, m, d);
  DecodeTime(AValue, h, n, s, ms);
  ATime := Format('%.2d%.2d%.2d.%.3d', [h, n, s, ms], gFS);
  ADate := Format('%.2d%.2d%.2d', [d, m, (y mod 100)], gFS);
end;

// the gpsd TPV json report for one track point (the nmea clients drop the
// json lines, but the emulation keeps them realistic); like all gpsd json
// lines it ends with a bare \n
function TpvJsonOf(const ACue: TNmeaCue): AnsiString;
var
  sIso: string;
begin
  sIso := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', ACue.DTime, gFS) + 'Z';
  Result := AnsiString(
    '{"class":"TPV","device":"nmea_server","mode":3,"time":"' + sIso +
    '","lat":' + F2(ACue.DLat, 6) +
    ',"lon":' + F2(ACue.DLon, 6) +
    ',"alt":' + F2(ACue.DEle, 1) +
    ',"speed":' + F2(ACue.DKts * 0.514444, 3) + // knots -> m/s
    ',"track":' + F2(ACue.DTrack, 1) + '}') + #10;
end;

// approximate distance between two points in meters (equirectangular)
function DistanceMeters(const ALat1, ALon1, ALat2, ALon2: Double): Double;
const
  R = 6371000;
var
  dLat, dLon, mLat: Double;
begin
  dLat := DegToRad(ALat2 - ALat1);
  dLon := DegToRad(ALon2 - ALon1);
  mLat := DegToRad((ALat1 + ALat2) / 2);
  Result := R * Sqrt(Sqr(dLat) + Sqr(dLon * Cos(mLat)));
end;

// course from the first point to the second one, degrees 0..360 from north
function BearingDeg(const ALat1, ALon1, ALat2, ALon2: Double): Double;
var
  dLon, y, x: Double;
begin
  dLon := DegToRad(ALon2 - ALon1);
  y := Sin(dLon) * Cos(DegToRad(ALat2));
  x := Cos(DegToRad(ALat1)) * Sin(DegToRad(ALat2)) -
       Sin(DegToRad(ALat1)) * Cos(DegToRad(ALat2)) * Cos(dLon);
  Result := RadToDeg(ArcTan2(y, x));
  if (Result < 0) then
    Result := Result + 360;
end;

// load a gpx file and build the list of the sentences to send
procedure LoadGpxTrack(const AFileName: string; var ACues: TNmeaCueArray);
var
  doc: IXMLDocument;
  root, nTrk, nSeg, nPt, nChild: IXMLNode;
  i, j, k, delayMs: Integer;
  sLat, sLon, sTime, sDate: string;
  sLatC, sLatH, sLonC, sLonH: string;
  lat, lon, ele, tPrev: Double;
  t: TDateTime;
  prevLat, prevLon, speed, course, dist: Double;
  hasEle, hasT, hasTPrev, hasPrev: Boolean;

  function _MakeGGA: AnsiString;
  var
    sAlt: string;
  begin
    if hasEle then
      sAlt := F2(ele, 1)
    else
      sAlt := '0.0';
    Result := MakeNmeaFullString(AnsiString(
      'GPGGA,' + sTime + ',' + sLatC + ',' + sLatH + ',' + sLonC + ',' + sLonH +
      ',1,08,0.9,' + sAlt + ',M,0.0,M,,'));
  end;

  function _MakeRMC: AnsiString;
  begin
    Result := MakeNmeaFullString(AnsiString(
      'GPRMC,' + sTime + ',A,' + sLatC + ',' + sLatH + ',' + sLonC + ',' + sLonH +
      ',' + F2(speed, 2) + ',' + F2(course, 1) + ',' + sDate + ',,A'));
  end;

begin
  SetLength(ACues, 0);

  doc := LoadXMLDocument(AFileName);
  if (doc.DocumentElement = nil) then
    Exit;
  root := doc.DocumentElement;

  hasPrev := FALSE;
  hasTPrev := FALSE;
  tPrev := 0;
  speed := 0;
  course := 0;
  prevLat := 0;
  prevLon := 0;

  for i := 0 to root.ChildNodes.Count - 1 do begin
    nTrk := root.ChildNodes[i];
    if (not SameText(nTrk.NodeName, 'trk')) then
      Continue;
    for j := 0 to nTrk.ChildNodes.Count - 1 do begin
      nSeg := nTrk.ChildNodes[j];
      if (not SameText(nSeg.NodeName, 'trkseg')) then
        Continue;
      for k := 0 to nSeg.ChildNodes.Count - 1 do begin
        nPt := nSeg.ChildNodes[k];
        if (not SameText(nPt.NodeName, 'trkpt')) then
          Continue;
        if (Length(ACues) >= cMaxTrackPoints) then
          Exit;

        sLat := VarToStr(nPt.Attributes['lat']);
        sLon := VarToStr(nPt.Attributes['lon']);
        if (0 = Length(sLat)) or (0 = Length(sLon)) then
          Continue;
        lat := StrToFloat(sLat, gFS);
        lon := StrToFloat(sLon, gFS);

        // optional elevation
        ele := 0;
        hasEle := FALSE;
        nChild := nPt.ChildNodes.FindNode('ele');
        if (nChild <> nil) then
          hasEle := TryStrToFloat(VarToStr(nChild.NodeValue), ele, gFS);

        // optional time (utc in gpx)
        hasT := FALSE;
        t := NowUTC;
        nChild := nPt.ChildNodes.FindNode('time');
        if (nChild <> nil) then
          hasT := TryISO8601ToDate(VarToStr(nChild.NodeValue), t, True);

        // delay from the previous point
        if hasPrev then begin
          if hasT and hasTPrev then
            delayMs := Round((t - tPrev) * MSecsPerDay)
          else
            delayMs := cDefPointDelayMs;
          if (delayMs < 0) then
            delayMs := 0;
          if (delayMs > cMaxPointDelayMs) then
            delayMs := cMaxPointDelayMs;
        end else
          delayMs := 0;

        // speed and course from the previous point
        if hasPrev then begin
          dist := DistanceMeters(prevLat, prevLon, lat, lon);
          if (delayMs > 0) then
            speed := dist / (delayMs / 1000) * 3600 / 1852;
          course := BearingDeg(prevLat, prevLon, lat, lon);
        end;

        // build the sentences
        TimeToStrNMEA(t, sTime, sDate);
        CoordToStr(lat, TRUE, sLatC, sLatH);
        CoordToStr(lon, FALSE, sLonC, sLonH);

        SetLength(ACues, Length(ACues) + 1);
        ACues[High(ACues)].DelayMs := delayMs;
        ACues[High(ACues)].SGga := _MakeGGA;
        ACues[High(ACues)].SRmc := _MakeRMC;
        ACues[High(ACues)].DLat := lat;
        ACues[High(ACues)].DLon := lon;
        ACues[High(ACues)].DEle := ele;
        ACues[High(ACues)].DKts := speed;
        ACues[High(ACues)].DTrack := course;
        ACues[High(ACues)].DTime := t;

        prevLat := lat;
        prevLon := lon;
        tPrev := t;
        hasTPrev := hasT;
        hasPrev := TRUE;
      end;
    end;
  end;
end;

{ TAcceptThread }

procedure TAcceptThread.Execute;
var
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VRes: Integer;
  VClient: TSocket;
  VAddr: TSockAddr;
  VLen: Integer;
begin
  while (not Terminated) do begin
    FD_ZERO(VSet);
    _FD_SET(ListenSocket, VSet);
    VTimeout.tv_sec := 0;
    VTimeout.tv_usec := 200 * 1000;
    VRes := select(0, @VSet, nil, nil, @VTimeout);
    if (Terminated) then
      Break;
    if (VRes > 0) then begin
      VLen := sizeof(VAddr);
      VClient := accept(ListenSocket, @VAddr, @VLen);
      if (VClient <> INVALID_SOCKET) then
        TfrmNmeaServer(Form).AddAcceptedClient(VClient, VAddr)
      else begin
        // the failure is logged, not silent: the missing clients are
        // diagnosable from the event log (called from the accept thread -
        // the counter is incremented interlocked)
        InterlockedIncrement(TfrmNmeaServer(Form).FStatNetErr);
        TfrmNmeaServer(Form).FLog.LogEvent('accept() failed: ' + IntToStr(WSAGetLastError));
      end;
    end else if (SOCKET_ERROR = VRes) then begin
      // listen socket closed or failed - exit
      Break;
    end;
  end;
end;

{ TfrmNmeaServer }

procedure TfrmNmeaServer.FormCreate(Sender: TObject);
var
  VWSA: TWSAData;
  VNmeaLogName, VEventLogName: string;
  VAutoStart: Boolean;
begin
  InitializeCriticalSection(FCS);
  FClients := TList<TClientInfo>.Create;
  FAcceptThread := nil;
  FListenSocket := INVALID_SOCKET;
  FWSAOk := (WSAStartup(cNmeaTool_WSA_Version_2_2, VWSA) = 0);
  if (not FWSAOk) then
    lblServerState.Caption := 'WSAStartup failed!';

  // the settings and the command line are applied before the log is created:
  // the command line may redefine the log file paths, the actions it
  // requests (the server start) run after the log is created
  VNmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt);
  VEventLogName := ChangeFileExt(Application.ExeName, cEventLogExt);
  LoadSettings;
  // (the command line may toggle the log checkboxes before the log exists -
  // LogParamChanged skips the nil log, the flags are applied below)
  ApplyCommandLine(VNmeaLogName, VEventLogName, VAutoStart);
  chkLogNmea.Hint := VNmeaLogName;
  chkLogEvents.Hint := VEventLogName;
  FLog := TNmeaToolLog.Create(VNmeaLogName, VEventLogName);
  FLog.SetNmeaEnabled(chkLogNmea.Checked);
  FLog.SetEventEnabled(chkLogEvents.Checked);
  FLog.LogEvent('command line: ' + GetCommandLineW);
  if VAutoStart then
    StartServer;

  UpdateButtons;
  // the work timer is armed last: it must not tick while the form is
  // being created (LoadTrackFromFile pumps the messages, and the tick
  // drains the log - which does not exist yet)
  tmrWork.Enabled := TRUE;
end;

procedure TfrmNmeaServer.ApplyCommandLine(out ANmeaLogName, AEventLogName: string;
                                            out AAutoStart: Boolean);
var
  i: Integer;
  s, VRest: string;
  VPlayRequested: Boolean;
begin
  // headless mode for automated testing (see the unit header); the log path
  // keys are applied through the out parameters (the log is not created yet)
  ANmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt);
  AEventLogName := ChangeFileExt(Application.ExeName, cEventLogExt);
  AAutoStart := False;
  VPlayRequested := False;
  for i := 1 to ParamCount do begin
    s := ParamStr(i);
    if s.StartsWith('/port=', True) then begin
      edPort.Text := Copy(s, 7, MaxInt);
      AAutoStart := True;
    end else if s.StartsWith('/transport=', True) then begin
      VRest := AnsiUpperCase(Copy(s, Length('/transport=') + 1, MaxInt));
      if ('UDP' = VRest) then
        rgTransport.ItemIndex := 1
      else if ('TCP' = VRest) then
        rgTransport.ItemIndex := 0;
      TransportChanged(rgTransport);
    end else if s.StartsWith('/target=', True) then begin
      edTarget.Text := Copy(s, Length('/target=') + 1, MaxInt);
    end else if s.StartsWith('/gpx=', True) then begin
      LoadTrackFromFile(Copy(s, 6, MaxInt));
    end else if SameText(s, '/play') then begin
      VPlayRequested := True;
    end else if s.StartsWith('/speed=', True) then begin
      edSpeed.Text := Copy(s, 8, MaxInt);
    end else if s.StartsWith('/nmealog', True) then begin
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
    end;
  end;
  if VPlayRequested and (0 < Length(FCues)) then
    StartPlayback;
end;

procedure TfrmNmeaServer.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  StopServer;
  FreeAndNil(FLog);
  FreeAndNil(FClients);
  DeleteCriticalSection(FCS);
  if FWSAOk then begin
    FWSAOk := FALSE;
    WSACleanup;
  end;
end;

{ settings (ini next to the exe) }

procedure TfrmNmeaServer.LoadSettings;
var
  ini: TIniFile;
  VDir: string;
  L, T, W, H: Integer;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    // window - apply only when the saved bounds are visible on some monitor
    L := ini.ReadInteger('Window', 'Left', Left);
    T := ini.ReadInteger('Window', 'Top', Top);
    W := ini.ReadInteger('Window', 'Width', Width);
    H := ini.ReadInteger('Window', 'Height', Height);
    if (W >= Constraints.MinWidth) and (H >= Constraints.MinHeight) and
       (L < Screen.DesktopRect.Right) and (L + W > Screen.DesktopRect.Left) and
       (T < Screen.DesktopRect.Bottom) and (T + H > Screen.DesktopRect.Top) then
      SetBounds(L, T, W, H);
    if (1 = ini.ReadInteger('Window', 'Maximized', 0)) then
      WindowState := wsMaximized;

    // pane widths (the splitter keeps the rest)
    gbClients.Width := Max(spl1.MinSize, ini.ReadInteger('Panels', 'ClientsWidth', gbClients.Width));

    // server
    edPort.Text := ini.ReadString('Server', 'Port', edPort.Text);
    chkGpsd.Checked := ini.ReadBool('Server', 'GpsdMode', False);
    rgTransport.ItemIndex := ini.ReadInteger('Server', 'Transport', 0);
    TransportChanged(rgTransport);
    edTarget.Text := ini.ReadString('Server', 'Target', edTarget.Text);

    // playback
    edSpeed.Text := ini.ReadString('Playback', 'Speed', edSpeed.Text);
    chkLoop.Checked := ini.ReadBool('Playback', 'Loop', True);
    VDir := ExtractFilePath(ini.ReadString('Playback', 'LastGpx', ''));
    if (VDir <> '') and DirectoryExists(VDir) then
      dlgOpen.InitialDir := VDir;

    // logging
    chkLogNmea.Checked := ini.ReadBool('Logging', 'NmeaToFile', False);
    chkLogEvents.Checked := ini.ReadBool('Logging', 'EventsToFile', False);

    // emulation
    chkDrop.Checked := ini.ReadBool('Emulation', 'DropEnabled', False);
    edDropSec.Text := ini.ReadString('Emulation', 'DropSec', edDropSec.Text);
    chkStall.Checked := ini.ReadBool('Emulation', 'StallEnabled', False);
    edStallSec.Text := ini.ReadString('Emulation', 'StallSec', edStallSec.Text);
    edStallMs.Text := ini.ReadString('Emulation', 'StallMs', edStallMs.Text);
  finally
    ini.Free;
  end;
end;

procedure TfrmNmeaServer.SaveSettings;
var
  ini: TIniFile;
  wp: TWindowPlacement;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    // window bounds (the restored ones, even when maximized now)
    wp.length := sizeof(wp);
    if GetWindowPlacement(Handle, wp) then begin
      ini.WriteInteger('Window', 'Left', wp.rcNormalPosition.Left);
      ini.WriteInteger('Window', 'Top', wp.rcNormalPosition.Top);
      ini.WriteInteger('Window', 'Width', wp.rcNormalPosition.Right - wp.rcNormalPosition.Left);
      ini.WriteInteger('Window', 'Height', wp.rcNormalPosition.Bottom - wp.rcNormalPosition.Top);
    end;
    ini.WriteInteger('Window', 'Maximized', Ord(WindowState = wsMaximized));

    // pane widths
    ini.WriteInteger('Panels', 'ClientsWidth', gbClients.Width);

    // server
    ini.WriteString('Server', 'Port', edPort.Text);
    ini.WriteBool('Server', 'GpsdMode', chkGpsd.Checked);
    ini.WriteInteger('Server', 'Transport', rgTransport.ItemIndex);
    ini.WriteString('Server', 'Target', edTarget.Text);

    // playback
    ini.WriteString('Playback', 'Speed', edSpeed.Text);
    ini.WriteBool('Playback', 'Loop', chkLoop.Checked);
    if (dlgOpen.FileName <> '') then
      ini.WriteString('Playback', 'LastGpx', dlgOpen.FileName);

    // logging
    ini.WriteBool('Logging', 'NmeaToFile', chkLogNmea.Checked);
    ini.WriteBool('Logging', 'EventsToFile', chkLogEvents.Checked);

    // emulation
    ini.WriteBool('Emulation', 'DropEnabled', chkDrop.Checked);
    ini.WriteString('Emulation', 'DropSec', edDropSec.Text);
    ini.WriteBool('Emulation', 'StallEnabled', chkStall.Checked);
    ini.WriteString('Emulation', 'StallSec', edStallSec.Text);
    ini.WriteString('Emulation', 'StallMs', edStallMs.Text);
  finally
    ini.Free;
  end;
end;

procedure TfrmNmeaServer.Lock;
begin
  EnterCriticalSection(FCS);
end;

procedure TfrmNmeaServer.Unlock;
begin
  LeaveCriticalSection(FCS);
end;

procedure TfrmNmeaServer.UpdateCounters;
var
  VClients: Integer;
begin
  // the clients count is shared with the accept thread, the net error
  // counter is shared too - read both under the lock / interlocked
  Lock;
  try
    VClients := FClients.Count;
  finally
    Unlock;
  end;
  sbStatus.Panels[0].Text := 'clients: ' + IntToStr(VClients);
  sbStatus.Panels[1].Text := 'out: ' + IntToStr(FStatSentBytes) + ' b / ' +
    IntToStr(FStatSentNmea) + ' nmea';
  sbStatus.Panels[2].Text := 'in: ' + IntToStr(FStatRecvBytes) + ' b';
  sbStatus.Panels[3].Text := 'net err: ' + IntToStr(FStatNetErr);
end;

procedure TfrmNmeaServer.UpdateButtons;
begin
  btnStartServer.Enabled := (FListenSocket = INVALID_SOCKET) and FWSAOk;
  btnStopServer.Enabled := (FListenSocket <> INVALID_SOCKET);
  // the transport is fixed at the server start (and the gpsd mode is the
  // tcp-only feature)
  rgTransport.Enabled := (FListenSocket = INVALID_SOCKET);
  chkGpsd.Enabled := (FListenSocket = INVALID_SOCKET) and (rgTransport.ItemIndex = 0);
  edTarget.Enabled := (rgTransport.ItemIndex = 1);
  lblTarget.Enabled := edTarget.Enabled;
  btnPlay.Enabled := (Length(FCues) > 0) and (not FPlaying);
  btnStopPlay.Enabled := FPlaying;
  if (FListenSocket <> INVALID_SOCKET) then begin
    if FTransportUdp then begin
      if FHasTarget then
        lblServerState.Caption := 'udp: 0.0.0.0:' + edPort.Text + ' -> ' + edTarget.Text
      else
        lblServerState.Caption := 'udp: 0.0.0.0:' + edPort.Text + ' (subscribers only)';
    end else
      lblServerState.Caption := 'listening on 0.0.0.0:' + edPort.Text;
  end else
    lblServerState.Caption := 'server stopped';
end;

procedure TfrmNmeaServer.btnStartServerClick(Sender: TObject);
begin
  StartServer;
end;

procedure TfrmNmeaServer.btnStopServerClick(Sender: TObject);
begin
  StopServer;
  UpdateButtons;
end;

procedure TfrmNmeaServer.TransportChanged(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TfrmNmeaServer.StartServer;
var
  VPort: Integer;
  VAddr: TSockAddr;
  VNonBlocking: u_long;
  VErr: Integer;
  sTarget: AnsiString;
begin
  if (FListenSocket <> INVALID_SOCKET) then
    Exit;

  VPort := StrToIntDef(edPort.Text, 0);
  if (VPort < 1) or (VPort > 65535) then begin
    ShowMessage('Invalid port!');
    Exit;
  end;

  FTransportUdp := (rgTransport.ItemIndex = 1);
  // the gpsd mode is fixed at the server start (the checkbox is disabled
  // while the server is running); gpsd speaks tcp only
  FGpsdMode := chkGpsd.Checked and (not FTransportUdp);

  if FTransportUdp then begin
    // bind 0.0.0.0:port (the same port receives the subscriber datagrams)
    FListenSocket := NmeaTool_CreateUdpListener(AnsiString('0.0.0.0:' + IntToStr(VPort)), VErr);
    if (FListenSocket = INVALID_SOCKET) then begin
      ShowMessage('bind() failed: ' + SysErrorMessage(VErr));
      Exit;
    end;
    // the timer sweeps the socket - non-blocking
    VNonBlocking := 1;
    // (the explicit LONGINT cast keeps FIONBIO ($8004667E) warning-free)
    ioctlsocket(FListenSocket, Longint(FIONBIO), VNonBlocking);

    // resolve the fixed send target (an empty target = the subscribers only)
    sTarget := AnsiString(Trim(edTarget.Text));
    if (0 = Length(sTarget)) then begin
      FHasTarget := FALSE;
    end else begin
      FHasTarget := NmeaTool_ResolveUdpTarget(sTarget, FTargetAddr, VErr);
      if (not FHasTarget) then begin
        closesocket(FListenSocket);
        FListenSocket := INVALID_SOCKET;
        ShowMessage('resolve target failed (' + string(sTarget) + '): ' + SysErrorMessage(VErr));
        Exit;
      end;
    end;

    if FHasTarget then
      FLog.LogEvent('udp server started on port ' + IntToStr(VPort) +
        ' -> ' + NmeaTool_PeerOf(FTargetAddr))
    else
      FLog.LogEvent('udp server started on port ' + IntToStr(VPort) + ' (subscribers only)');
  end else begin
    FHasTarget := FALSE;

    FListenSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (FListenSocket = INVALID_SOCKET) then begin
      ShowMessage('socket() failed: ' + SysErrorMessage(WSAGetLastError));
      Exit;
    end;

    // bind to 0.0.0.0:port (the port goes into sa_data in the network byte order)
    FillChar(VAddr, sizeof(VAddr), 0);
    VAddr.sa_family := AF_INET;
    VAddr.sa_data[0] := AnsiChar(Byte(VPort shr 8));
    VAddr.sa_data[1] := AnsiChar(Byte(VPort and $FF));

    if (0 <> bind(FListenSocket, VAddr, sizeof(VAddr))) then begin
      ShowMessage('bind() failed: ' + SysErrorMessage(WSAGetLastError));
      closesocket(FListenSocket);
      FListenSocket := INVALID_SOCKET;
      Exit;
    end;

    if (0 <> listen(FListenSocket, 8)) then begin
      ShowMessage('listen() failed: ' + SysErrorMessage(WSAGetLastError));
      closesocket(FListenSocket);
      FListenSocket := INVALID_SOCKET;
      Exit;
    end;

    FAcceptThread := TAcceptThread.Create(TRUE);
    FAcceptThread.Form := Self;
    FAcceptThread.ListenSocket := FListenSocket;
    FAcceptThread.FreeOnTerminate := FALSE;
    FAcceptThread.Start;

    if FGpsdMode then
      FLog.LogEvent('server started on port ' + IntToStr(VPort) + ' (gpsd mode)')
    else
      FLog.LogEvent('server started on port ' + IntToStr(VPort));
  end;

  // resume the broadcast paused by the previous StopServer (same point)
  if FPausedByServerStop and (0 < Length(FCues)) then begin
    FPausedByServerStop := FALSE;
    FPlaying := TRUE;
    FLastTick := GetTickCount;
  end;
  UpdateButtons;
end;

procedure TfrmNmeaServer.StopServer;
begin
  // pause the broadcast together with the server: StartServer resumes it
  // from the same point (the explicit play/stop buttons clear the pause)
  if FPlaying then begin
    FPlaying := FALSE;
    FPausedByServerStop := TRUE;
    lblPlayState.Caption := 'paused (server stopped)';
  end;
  if (FAcceptThread <> nil) then begin
    FAcceptThread.Terminate;
    // unblock the select() in the accept thread
    if (FListenSocket <> INVALID_SOCKET) then begin
      closesocket(FListenSocket);
      FListenSocket := INVALID_SOCKET;
    end;
    FAcceptThread.WaitFor;
    FreeAndNil(FAcceptThread);
  end;
  RemoveAllClients('server stopped');
  if FTransportUdp then
    FLog.LogEvent('server stopped');
  if (FListenSocket <> INVALID_SOCKET) then begin
    closesocket(FListenSocket);
    FListenSocket := INVALID_SOCKET;
  end;
end;

procedure TfrmNmeaServer.AddAcceptedClient(const AClient: TSocket; const AAddr: TSockAddr);
var
  VInfo: TClientInfo;
  VNonBlocking: u_long;
begin
  // non-blocking sockets - the sender never blocks the ui thread
  // (the explicit LONGINT cast keeps FIONBIO ($8004667E) warning-free)
  VNonBlocking := 1;
  ioctlsocket(AClient, Longint(FIONBIO), VNonBlocking);

  FillChar(VInfo, sizeof(VInfo), 0);
  VInfo.Kind := ckTcp;
  VInfo.Socket := AClient;
  VInfo.Peer := Format('%d.%d.%d.%d:%d', [
    Byte(AAddr.sa_data[2]),
    Byte(AAddr.sa_data[3]),
    Byte(AAddr.sa_data[4]),
    Byte(AAddr.sa_data[5]),
    (Byte(AAddr.sa_data[0]) shl 8) or Byte(AAddr.sa_data[1])]);
  VInfo.Watching := FALSE;

  FLog.LogEvent('client ' + VInfo.Peer + ' connected');

  // gpsd sends the greeting banner to every connected client immediately
  // (before any WATCH command from the client)
  if FGpsdMode then
    send(AClient, PAnsiChar(cGpsd_Banner)^, Length(cGpsd_Banner), 0);

  Lock;
  try
    FClients.Add(VInfo);
  finally
    Unlock;
  end;
end;

procedure TfrmNmeaServer.RemoveClientLocked(AIndex: Integer; const AReason: string);
var
  VPeer: string;
begin
  // the critical section is already locked
  VPeer := FClients[AIndex].Peer;
  if (ckTcp = FClients[AIndex].Kind) then
    closesocket(FClients[AIndex].Socket);
  FClients.Delete(AIndex);
  FLog.LogEvent('client ' + VPeer + ' disconnected (' + AReason + ')');
end;

procedure TfrmNmeaServer.RemoveAllClients(const AReason: string);
begin
  Lock;
  try
    while (FClients.Count > 0) do begin
      if (ckTcp = FClients[0].Kind) then
        closesocket(FClients[0].Socket);
      FLog.LogEvent('client ' + FClients[0].Peer + ' disconnected (' + AReason + ')');
      FClients.Delete(0);
    end;
  finally
    Unlock;
  end;
end;

procedure TfrmNmeaServer.SendToAllClients(const AData: AnsiString);
var
  i, VSent: Integer;
  VSin: TSockAddrIn;
begin
  if (0 = Length(AData)) then
    Exit;
  // the fixed udp target first (it is not in the clients list)
  if FTransportUdp and FHasTarget and (FListenSocket <> INVALID_SOCKET) then begin
    VSent := sendto(FListenSocket, PAnsiChar(AData)^, Length(AData), 0,
                    PSockAddr(@FTargetAddr), sizeof(FTargetAddr));
    if (SOCKET_ERROR = VSent) then begin
      // a persistent send failure (no route, ...) is visible in the errors
      // counter; the single datagram losses of a busy network are not
      // worth the log noise - nothing is removed here
      InterlockedIncrement(FStatNetErr);
    end;
  end;
  Lock;
  try
    for i := FClients.Count - 1 downto 0 do begin
      // gpsd streams only to the clients which sent the WATCH command
      if FGpsdMode and (ckTcp = FClients[i].Kind) and (not FClients[i].Watching) then
        Continue;
      if (ckTcp = FClients[i].Kind) then begin
        VSent := send(FClients[i].Socket, PAnsiChar(AData)^, Length(AData), 0);
        if (SOCKET_ERROR = VSent) then begin
          if (WSAEWOULDBLOCK = WSAGetLastError) then
            Continue; // send buffer is full - skip this chunk
          InterlockedIncrement(FStatNetErr);
          RemoveClientLocked(i, 'send error');
        end;
      end else begin
        VSin := FClients[i].Addr;
        VSent := sendto(FListenSocket, PAnsiChar(AData)^, Length(AData), 0,
                        PSockAddr(@VSin), sizeof(VSin));
        if (SOCKET_ERROR = VSent) then begin
          if (WSAEWOULDBLOCK = WSAGetLastError) then
            Continue;
          InterlockedIncrement(FStatNetErr);
          RemoveClientLocked(i, 'sendto error');
        end;
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TfrmNmeaServer.CheckClients;
var
  i, VReceived, VRes: Integer;
  VInfo: TClientInfo;
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VBuf: array [0..4095] of AnsiChar;
  VFrom: TSockAddr;    // the RTL recvfrom takes the var TSockAddr
  VFromLen: Integer;
  sPeer: string;
  VIdx: Integer;
begin
  // TCP: select() every client with zero timeout, drain the received data
  // (clients may send queries - just ignore them), remove the disconnected.
  // UDP: sweep the bound socket, register the datagram sources as the
  // subscribers and refresh their keepalive
  if FTransportUdp then begin
    if (FListenSocket = INVALID_SOCKET) then
      Exit;
    while (TRUE) do begin
      FD_ZERO(VSet);
      _FD_SET(FListenSocket, VSet);
      VTimeout.tv_sec := 0;
      VTimeout.tv_usec := 0;
      VRes := select(0, @VSet, nil, nil, @VTimeout);
      if (VRes <= 0) then
        Break; // no data (a socket error is handled by the stop path)
      VFromLen := sizeof(VFrom);
      VReceived := recvfrom(FListenSocket, VBuf[0], sizeof(VBuf), 0, VFrom, VFromLen);
      if (VReceived <= 0) then
        Break;
      // the datagram content is ignored, the source becomes a subscriber
      FStatRecvBytes := FStatRecvBytes + VReceived;
      sPeer := NmeaTool_PeerOf(PSockAddrIn(@VFrom)^);
      Lock;
      try
        VIdx := -1;
        for i := 0 to FClients.Count - 1 do begin
          if (ckUdp = FClients[i].Kind) and
             (FClients[i].Addr.sin_addr.S_addr = PSockAddrIn(@VFrom)^.sin_addr.S_addr) and
             (FClients[i].Addr.sin_port = PSockAddrIn(@VFrom)^.sin_port) then begin
            VIdx := i;
            Break;
          end;
        end;
        if (VIdx < 0) then begin
          FillChar(VInfo, sizeof(VInfo), 0);
          VInfo.Kind := ckUdp;
          VInfo.Addr := PSockAddrIn(@VFrom)^;
          VInfo.Peer := sPeer;
          VInfo.LastSeen := GetTickCount;
          FClients.Add(VInfo);
          FLog.LogEvent('udp subscriber ' + sPeer + ' registered');
        end else begin
          VInfo := FClients[VIdx];
          VInfo.LastSeen := GetTickCount;
          FClients[VIdx] := VInfo;
        end;
      finally
        Unlock;
      end;
    end;
    // expire the silent subscribers
    Lock;
    try
      for i := FClients.Count - 1 downto 0 do begin
        if (ckUdp = FClients[i].Kind) and
           (cNmeaTool_Subscriber_Timeout_MSec < (GetTickCount - FClients[i].LastSeen)) then
          RemoveClientLocked(i, 'subscriber expired');
      end;
    finally
      Unlock;
    end;
    Exit;
  end;

  Lock;
  try
    for i := FClients.Count - 1 downto 0 do begin
      FD_ZERO(VSet);
      _FD_SET(FClients[i].Socket, VSet);
      VTimeout.tv_sec := 0;
      VTimeout.tv_usec := 0;
      VRes := select(0, @VSet, nil, nil, @VTimeout);
      if (SOCKET_ERROR = VRes) then begin
        InterlockedIncrement(FStatNetErr);
        RemoveClientLocked(i, 'select error');
        Continue;
      end;
      if (VRes > 0) then begin
        VReceived := recv(FClients[i].Socket, VBuf[0], sizeof(VBuf), 0);
        if (VReceived < 0) then begin
          // select() can report the data which recv() does not find (a rare
          // winsock race) - the client is alive, keep it
          if (WSAEWOULDBLOCK <> WSAGetLastError) then begin
            InterlockedIncrement(FStatNetErr);
            RemoveClientLocked(i, 'recv error');
          end;
        end else if (0 = VReceived) then begin
          RemoveClientLocked(i, 'closed by peer');
        end else begin
          // the client queries are just drained - count the received bytes
          FStatRecvBytes := FStatRecvBytes + VReceived;
          // gpsd mode: the stream starts only after the ?WATCH command
          if FGpsdMode and (not FClients[i].Watching) and
             (0 < Pos(AnsiString('?WATCH='), Copy(VBuf, 1, VReceived))) then begin
            VInfo := FClients[i];
            VInfo.Watching := TRUE;
            FClients[i] := VInfo;
            FLog.LogEvent('client ' + FClients[i].Peer + ': WATCH received - streaming');
          end;
        end;
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TfrmNmeaServer.LoadTrackFromFile(const AFileName: string);
begin
  StopPlayback;
  FCues := nil;
  lblTrack.Caption := ExtractFileName(AFileName) + ' (loading...)';
  Application.ProcessMessages;
  try
    LoadGpxTrack(AFileName, FCues);
    if (0 = Length(FCues)) then
      lblTrack.Caption := ExtractFileName(AFileName) + ': no trkpt found!'
    else
      lblTrack.Caption := ExtractFileName(AFileName) + ': ' + IntToStr(Length(FCues)) + ' points';
  except
    on E: Exception do begin
      FCues := nil;
      lblTrack.Caption := 'failed to load gpx: ' + E.Message;
    end;
  end;
  UpdateButtons;
end;

procedure TfrmNmeaServer.btnOpenGpxClick(Sender: TObject);
begin
  if (not dlgOpen.Execute) then
    Exit;
  LoadTrackFromFile(dlgOpen.FileName);
end;

procedure TfrmNmeaServer.btnPlayClick(Sender: TObject);
begin
  StartPlayback;
end;

procedure TfrmNmeaServer.btnStopPlayClick(Sender: TObject);
begin
  StopPlayback;
end;

procedure TfrmNmeaServer.StartPlayback;
begin
  if (0 = Length(FCues)) then
    Exit;
  FPausedByServerStop := FALSE; // the explicit play overrides the pause
  FCueIdx := 0;
  FElapsedMs := 0;
  FLastTick := GetTickCount;
  FPlaying := TRUE;
  UpdateButtons;
end;

procedure TfrmNmeaServer.StopPlayback;
begin
  FPausedByServerStop := FALSE; // the explicit stop overrides the pause
  FPlaying := FALSE;
  lblPlayState.Caption := '';
  UpdateButtons;
end;

procedure TfrmNmeaServer.EmulParamChanged(Sender: TObject);
begin
  // schedule the next emulation action from the current moment
  if chkDrop.Checked then
    FNextDropTick := GetTickCount + Cardinal(Max(1, StrToIntDef(edDropSec.Text, 10))) * 1000;
  if chkStall.Checked then begin
    FNextStallTick := GetTickCount + Cardinal(Max(1, StrToIntDef(edStallSec.Text, 30))) * 1000;
    FStallActive := FALSE;
  end;
end;

procedure TfrmNmeaServer.tmrWorkTimer(Sender: TObject);
begin
  DoWorkTick;
end;

procedure TfrmNmeaServer.DoWorkTick;
const
  CLogDrainIntervalMSec = 1000; // the logs are written once per second
var
  VNow: DWORD;
  VDue: Boolean;
  VStallMSec, VDropSec, VStallSec: Integer;
  VSpeed: Double;
  VDt: DWORD;
  VSent: Integer;
  VDelay: Cardinal;
  VGuard: Integer;
  sJson: AnsiString;
begin
  // 1) write the pending event lines and the buffered nmea data to the logs
  // (once per second - the ui thread must not do disk i/o on every tick at
  // high playback speeds)
  if ((GetTickCount - FLastLogDrainTick) >= CLogDrainIntervalMSec) then begin
    FLastLogDrainTick := GetTickCount;
    DrainLogs;
  end;

  // 2) refresh the clients list
  UpdateClientList;

  // 3) check the clients for disconnects and drain their queries
  CheckClients;

  VNow := GetTickCount;

  // 4-5) emulation - drops and stalls (only while the server is running:
  // stopping the server pauses the emulation together with the playback,
  // starting the server begins a fresh emulation countdown)
  if (FListenSocket <> INVALID_SOCKET) then begin
    // 4) emulation - drops: the tcp clients are disconnected, the udp
    // subscribers are forgotten (a client which keeps reporting itself is
    // re-registered - the same way a real mux restart looks from outside)
    VDropSec := Max(1, StrToIntDef(edDropSec.Text, 10));
    if (chkDrop.Checked) then begin
      if (not FDropEnabled) then begin
        FDropEnabled := TRUE;
        FNextDropTick := VNow + Cardinal(VDropSec) * 1000;
      end;
      VDue := ((VNow - FNextDropTick) < $80000000);
      if VDue then begin
        FNextDropTick := VNow + Cardinal(VDropSec) * 1000;
        FLog.LogEvent('*** emulated connection drop ***');
        RemoveAllClients('emulated connection drop');
      end;
    end else
      FDropEnabled := FALSE;

    // 5) emulation - transmission stalls (the same for both transports: the
    // stream just pauses - the udp listeners see the silence exactly like
    // the tcp clients see a stalled sender)
    VStallSec := Max(1, StrToIntDef(edStallSec.Text, 30));
    VStallMSec := Max(0, StrToIntDef(edStallMs.Text, 2000));
    if (chkStall.Checked) then begin
      if (not FStallEnabled) then begin
        FStallEnabled := TRUE;
        FNextStallTick := VNow + Cardinal(VStallSec) * 1000;
        FStallActive := FALSE;
      end;
      // the stall lasts a limited time - end it when the deadline is reached
      // (the wrap-safe tick comparison, like the one below)
      if FStallActive and ((VNow - FStallUntilTick) < $80000000) then begin
        FStallActive := FALSE;
        FLog.LogEvent('--- emulated stall ended ---');
      end;
      VDue := ((VNow - FNextStallTick) < $80000000);
      if VDue and (not FStallActive) then begin
        FNextStallTick := VNow + Cardinal(VStallSec) * 1000;
        FStallUntilTick := VNow + Cardinal(VStallMSec);
        FStallActive := TRUE;
        FLog.LogEvent('--- emulated stall for ' + IntToStr(VStallMSec) + ' ms ---');
      end;
    end else begin
      FStallEnabled := FALSE;
      FStallActive := FALSE;
    end;
  end else begin
    // the server is stopped - nothing is emulated until it starts again
    FDropEnabled := FALSE;
    FStallEnabled := FALSE;
    FStallActive := FALSE;
  end;

  // 6) playback (works even without any client - just logs the stream)
  if (not FPlaying) or (0 = Length(FCues)) then begin
    UpdateCounters;
    Exit;
  end;

  if FStallActive then begin
    FLastTick := VNow; // pause the playback clock
    lblPlayState.Caption := 'stalled...';
    UpdateCounters;
    Exit;
  end;

  VDt := VNow - FLastTick;
  FLastTick := VNow;

  VSpeed := StrToFloatDef(edSpeed.Text, 1, gFS);
  if (VSpeed <= 0) then
    VSpeed := 1;
  FElapsedMs := FElapsedMs + VDt * VSpeed;

  VSent := 0;
  while (FCueIdx < Length(FCues)) and (VSent < cMaxSendPerTick) do begin
    VDelay := FCues[FCueIdx].DelayMs;
    if (FElapsedMs < VDelay) then
      Break;
    FElapsedMs := FElapsedMs - VDelay;
    if FGpsdMode then begin
      // gpsd interleaves the json reports with the raw nmea sentences - one
      // TPV per track point (the nmea clients drop the json lines)
      sJson := TpvJsonOf(FCues[FCueIdx]);
      SendToAllClients(sJson);
      FLog.LogNmeaRaw(sJson);
      FStatSentBytes := FStatSentBytes + Length(sJson);
    end;
    SendToAllClients(FCues[FCueIdx].SGga);
    SendToAllClients(FCues[FCueIdx].SRmc);
    FLog.LogNmeaRaw(FCues[FCueIdx].SGga);
    FLog.LogNmeaRaw(FCues[FCueIdx].SRmc);
    // the counters follow the produced stream (the same bytes the nmea log
    // gets) - with a single client it is exactly what was transmitted
    FStatSentBytes := FStatSentBytes +
      (Length(FCues[FCueIdx].SGga) + Length(FCues[FCueIdx].SRmc));
    FStatSentNmea := FStatSentNmea + 2;
    Inc(VSent);
    Inc(FCueIdx);
    if (FCueIdx >= Length(FCues)) then begin
      if chkLoop.Checked then
        FCueIdx := 0
      else begin
        StopPlayback;
        Break;
      end;
    end;
  end;

  if (VSent >= cMaxSendPerTick) and FPlaying then begin
    // the tick can not catch up - skip the missed points instead of
    // growing the backlog (the ui thread must stay responsive)
    VGuard := 0;
    while (FCueIdx < Length(FCues)) and (VGuard < cMaxSkipWalk) do begin
      VDelay := FCues[FCueIdx].DelayMs;
      if (FElapsedMs < VDelay) then
        Break;
      FElapsedMs := FElapsedMs - VDelay;
      Inc(VGuard);
      Inc(FCueIdx);
      if (FCueIdx >= Length(FCues)) then begin
        if chkLoop.Checked then
          FCueIdx := 0
        else begin
          StopPlayback;
          Break;
        end;
      end;
    end;
    if (FElapsedMs > cMaxElapsedBacklogMs) then
      FElapsedMs := 0;
  end;

  if FPlaying then
    lblPlayState.Caption := 'playing: ' + IntToStr(FCueIdx + 1) + ' / ' + IntToStr(Length(FCues));

  UpdateCounters;
end;

procedure TfrmNmeaServer.DrainLogs;
var
  VConn: TStringList;
begin
  VConn := TStringList.Create;
  try
    FLog.DrainEvents(VConn);
    if (VConn.Count > 0) then begin
      // the file gets every line, the memo only the last ones
      FLog.WriteEventFile(VConn);
      mmLog.Lines.BeginUpdate;
      try
        mmLog.Lines.AddStrings(VConn);
        while (mmLog.Lines.Count > cMaxMemoLines) do
          mmLog.Lines.Delete(0);
      finally
        mmLog.Lines.EndUpdate;
      end;
      SendMessage(mmLog.Handle, EM_LINESCROLL, 0, mmLog.Lines.Count);
    end;
    // flush the buffered raw nmea data at least once per second
    FLog.FlushNmeaFile;
  finally
    VConn.Free;
  end;
end;

procedure TfrmNmeaServer.UpdateClientList;
var
  i: Integer;
  VItems: TStringList;
begin
  VItems := TStringList.Create;
  try
    Lock;
    try
      VItems.Append(IntToStr(FClients.Count) + ' connected');
      for i := 0 to FClients.Count - 1 do
        VItems.Append(FClients[i].Peer);
    finally
      Unlock;
    end;
    if FTransportUdp and FHasTarget then
      VItems.Append('target: ' + edTarget.Text);
    lbClients.Items.BeginUpdate;
    try
      lbClients.Items.Assign(VItems);
    finally
      lbClients.Items.EndUpdate;
    end;
  finally
    VItems.Free;
  end;
end;

procedure TfrmNmeaServer.LogParamChanged(Sender: TObject);
begin
  // the checkboxes mirror the log enable flags (a file error may have
  // disabled the logging from inside - sync the checkbox back)
  if (FLog = nil) then
    Exit; // the log is created after the command line is applied (FormCreate)
  FLog.SetNmeaEnabled(chkLogNmea.Checked);
  FLog.SetEventEnabled(chkLogEvents.Checked);
end;

initialization
  // the invariant format settings (dot decimal separator regardless of the
  // current locale) - used by every Format / StrToFloat call of this unit
  gFS := TFormatSettings.Invariant;

end.
