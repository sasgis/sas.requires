unit tcp_nmea_server_main;
(*
  Simple manual testing tool: a TCP server which replays a GPX track as an
  NMEA0183 stream (GGA + RMC sentences per track point). The playback speed
  is configurable. The tool can emulate transmission stalls (stream pauses)
  and connection drops to check that the clients automatically reconnect.

  Command line:
    /port=N         - start the server on the given port
    /gpx=path       - load the given gpx file
    /play           - start the playback after loading
    /speed=X        - playback speed multiplier
    /nmealog[=path] - save the raw nmea stream to the log file
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
  Winapi.Winsock2;

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

  TClientInfo = record
    Socket: TSocket;
    Peer: string; // "ip:port"
    Watching: Boolean; // gpsd mode: the client sent the ?WATCH command
  end;

  TAcceptThread = class(TThread)
  public
    Form: TObject; // TfrmTcpNmeaServer (to avoid a circular unit reference)
    ListenSocket: TSocket;
    procedure Execute; override;
  end;

  TfrmTcpNmeaServer = class(TForm)
    dlgOpen: TOpenDialog;
    tmrWork: TTimer;
    panTop: TPanel;
    lblPort: TLabel;
    lblServerState: TLabel;
    edPort: TEdit;
    btnStartServer: TButton;
    btnStopServer: TButton;
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
    chkLogTcp: TCheckBox;
    lblLogFiles: TLabel;
    gbClients: TGroupBox;
    lbClients: TListBox;
    spl1: TSplitter;
    gbTcp: TGroupBox;
    mmTcp: TMemo;
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
  private
    FCS: TRTLCriticalSection;
    FClients: TList<TClientInfo>;
    FConnLog: TStringList; // tcp event lines pending for the memo and the log file
    // file logs (the files are opened on demand and written by the ui thread)
    FNmeaBuf: TMemoryStream;  // raw nmea bytes not flushed to the nmea log yet
    FNmeaFile: TFileStream;
    FTcpFile: TFileStream;
    FNmeaLogName: string;
    FTcpLogName: string;
    FNmeaLogFresh: Boolean;   // the file is created (not appended) on the next open
    FTcpLogFresh: Boolean;
    FAcceptThread: TAcceptThread;
    FListenSocket: TSocket;
    FWSAOk: Boolean;
    FGpsdMode: Boolean; // the gpsd server emulation, fixed at the server start
    // playback state
    FCues: TNmeaCueArray;
    FCueIdx: Integer;
    FElapsedMs: Double;
    FLastTick: DWORD;
    FPlaying: Boolean;
    FPausedByServerStop: Boolean; // the playback was paused by StopServer (resumed by StartServer)
    FLastLogDrainTick: Cardinal; // the logs are drained into the file once per second
    // emulation state
    FDropEnabled: Boolean;
    FNextDropTick: DWORD;
    FStallEnabled: Boolean;
    FStallActive: Boolean;
    FNextStallTick: DWORD;
    FStallUntilTick: DWORD;
    // counters for the status bar (the tcp error counter is incremented
    // from the accept thread too - hence the interlocked increment)
    FStatSentBytes: Int64;   // the nmea stream produced by the playback
    FStatSentNmea: Int64;    // the nmea sentences produced by the playback
    FStatRecvBytes: Int64;   // the bytes received from the clients
    FStatTcpErr: Integer;    // send/recv/select/accept failures
  private
    procedure Lock;
    procedure Unlock;
    procedure LogTcp(const S: string);
    procedure LogNmeaRaw(const AData: AnsiString);
    procedure FlushNmeaFile;
    procedure WriteNmeaFile(const AData: AnsiString);
    procedure WriteTcpFile(const ALines: TStrings);
    procedure CloseLogFiles;
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
    procedure ApplyCommandLine;
  end;

var
  frmTcpNmeaServer: TfrmTcpNmeaServer;

implementation

{$R *.dfm}

uses
  IniFiles,
  vsagps_parser_nmea; // MakeNmeaFullString

const
  cWSA_Version_2_2 = $0202; // (the RTL winsock unit does not declare it)

  cMaxPointDelayMs = 1000;  // clamp huge gaps between the track times
  cMaxTrackPoints  = 200000;
  cMaxSendPerTick  = 200;   // points per timer tick (more - skip instead of catch up)
  cMaxLogPending   = 400;   // tcp event lines pending for the memo
  cMaxMemoLines    = 300;   // tcp event memo lines kept
  cNmeaBufSize     = 65536; // raw nmea bytes buffered before a disk write
  cMaxSkipWalk     = 100000; // hard guard for the skip loop
  cMaxElapsedBacklogMs = 10000;
  cDefPointDelayMs = 1000;  // delay per point when the track has no times
  cNmeaLogExt      = '.nmea.log'; // ChangeFileExt() of the exe name
  cTcpLogExt       = '.tcp.log';

  // the gpsd greeting banner (sent to every client right after the accept;
  // the gpsd json lines end with a bare \n)
  cGpsd_Banner: AnsiString =
    '{"class":"VERSION","release":"tcp_nmea_server","rev":"emul",' +
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
begin
  vm := Abs(AValue);
  vd := Trunc(vm);
  vm := (vm - vd) * 60;
  if AIsLat then begin
    ACoord := Format('%.2d%.5f', [vd, vm], gFS);
    AHemi := 'N';
    if (AValue < 0) then
      AHemi := 'S';
  end else begin
    ACoord := Format('%.3d%.5f', [vd, vm], gFS);
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
    '{"class":"TPV","device":"tcp_nmea_server","mode":3,"time":"' + sIso +
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
        TfrmTcpNmeaServer(Form).AddAcceptedClient(VClient, VAddr)
      else begin
        // the failure is logged, not silent: the missing clients are
        // diagnosable from the tcp event log (called from the accept
        // thread - the counter is incremented interlocked)
        InterlockedIncrement(TfrmTcpNmeaServer(Form).FStatTcpErr);
        TfrmTcpNmeaServer(Form).LogTcp('accept() failed: ' + IntToStr(WSAGetLastError));
      end;
    end else if (SOCKET_ERROR = VRes) then begin
      // listen socket closed or failed - exit
      Break;
    end;
  end;
end;

{ TfrmTcpNmeaServer }

procedure TfrmTcpNmeaServer.FormCreate(Sender: TObject);
var
  VWSA: TWSAData;
begin
  // the invariant format settings: dot decimal separator regardless of the
  // current locale (the tformat settings "create(locale)" overload is
  // windows-only, so it makes the unit platform specific)
  gFS := TFormatSettings.Invariant;
  InitializeCriticalSection(FCS);
  FClients := TList<TClientInfo>.Create;
  FConnLog := TStringList.Create;
  FNmeaBuf := TMemoryStream.Create;
  FNmeaFile := nil;
  FTcpFile := nil;
  FNmeaLogName := ChangeFileExt(Application.ExeName, cNmeaLogExt);
  FTcpLogName := ChangeFileExt(Application.ExeName, cTcpLogExt);
  FNmeaLogFresh := TRUE;
  FTcpLogFresh := TRUE;
  FListenSocket := INVALID_SOCKET;
  FWSAOk := (WSAStartup(cWSA_Version_2_2, VWSA) = 0);
  if (not FWSAOk) then
    lblServerState.Caption := 'WSAStartup failed!';
  LoadSettings;
  UpdateButtons;
  ApplyCommandLine;
end;

procedure TfrmTcpNmeaServer.ApplyCommandLine;
var
  i: Integer;
  s, VRest: string;
  VPlayRequested: Boolean;
begin
  // headless mode for automated testing:
  //   /port=N         - start the server on the given port
  //   /gpx=path       - load the given gpx file
  //   /play           - start the playback after loading
  //   /speed=X        - playback speed multiplier
  //   /nmealog[=path] - save the raw nmea stream to the log file
  //   /tcplog[=path]  - save the tcp events to the log file
  VPlayRequested := False;
  LogTcp('command line: ' + GetCommandLineW);
  for i := 1 to ParamCount do begin
    s := ParamStr(i);
    if s.StartsWith('/port=', True) then begin
      edPort.Text := Copy(s, 7, MaxInt);
      StartServer;
    end else if s.StartsWith('/gpx=', True) then begin
      LoadTrackFromFile(Copy(s, 6, MaxInt));
    end else if SameText(s, '/play') then begin
      VPlayRequested := True;
    end else if s.StartsWith('/speed=', True) then begin
      edSpeed.Text := Copy(s, 8, MaxInt);
    end else if s.StartsWith('/nmealog', True) then begin
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
    end;
  end;
  chkLogNmea.Hint := FNmeaLogName;
  chkLogTcp.Hint := FTcpLogName;
  if VPlayRequested and (0 < Length(FCues)) then
    StartPlayback;
end;

procedure TfrmTcpNmeaServer.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  StopServer;
  FlushNmeaFile;
  CloseLogFiles;
  FreeAndNil(FNmeaBuf);
  FreeAndNil(FClients);
  FreeAndNil(FConnLog);
  DeleteCriticalSection(FCS);
  if FWSAOk then begin
    FWSAOk := FALSE;
    WSACleanup;
  end;
end;

{ settings (ini next to the exe) }

procedure TfrmTcpNmeaServer.LoadSettings;
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

    // playback
    edSpeed.Text := ini.ReadString('Playback', 'Speed', edSpeed.Text);
    chkLoop.Checked := ini.ReadBool('Playback', 'Loop', True);
    VDir := ExtractFilePath(ini.ReadString('Playback', 'LastGpx', ''));
    if (VDir <> '') and DirectoryExists(VDir) then
      dlgOpen.InitialDir := VDir;

    // logging
    chkLogNmea.Checked := ini.ReadBool('Logging', 'NmeaToFile', False);
    chkLogTcp.Checked := ini.ReadBool('Logging', 'TcpToFile', False);

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

procedure TfrmTcpNmeaServer.SaveSettings;
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

    // playback
    ini.WriteString('Playback', 'Speed', edSpeed.Text);
    ini.WriteBool('Playback', 'Loop', chkLoop.Checked);
    if (dlgOpen.FileName <> '') then
      ini.WriteString('Playback', 'LastGpx', dlgOpen.FileName);

    // logging
    ini.WriteBool('Logging', 'NmeaToFile', chkLogNmea.Checked);
    ini.WriteBool('Logging', 'TcpToFile', chkLogTcp.Checked);

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

procedure TfrmTcpNmeaServer.Lock;
begin
  EnterCriticalSection(FCS);
end;

procedure TfrmTcpNmeaServer.Unlock;
begin
  LeaveCriticalSection(FCS);
end;

procedure TfrmTcpNmeaServer.LogTcp(const S: string);
begin
  // the tcp event line is timestamped once and kept pending for the memo and
  // the log file; the file itself is written by the timer (ui thread), the
  // pending list is shared with the accept thread
  Lock;
  try
    FConnLog.Append('[' + FormatDateTime('hh:nn:ss.zzz', Now) + '] ' + S);
    if (FConnLog.Count > cMaxLogPending) then
      FConnLog.Delete(0);
  finally
    Unlock;
  end;
end;

procedure TfrmTcpNmeaServer.LogNmeaRaw(const AData: AnsiString);
begin
  // raw nmea data - exactly the bytes sent to the clients, no formatting at all;
  // called from the ui thread only, the buffer is flushed by the timer
  if (0 = Length(AData)) or (not chkLogNmea.Checked) then
    Exit;
  FNmeaBuf.WriteBuffer(PAnsiChar(AData)^, Length(AData));
  if (FNmeaBuf.Size >= cNmeaBufSize) then
    FlushNmeaFile;
end;

procedure TfrmTcpNmeaServer.FlushNmeaFile;
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

procedure TfrmTcpNmeaServer.WriteNmeaFile(const AData: AnsiString);
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

procedure TfrmTcpNmeaServer.WriteTcpFile(const ALines: TStrings);
var
  i: Integer;
  VData: UTF8String;
begin
  if (0 = ALines.Count) then
    Exit;
  VData := '';
  for i := 0 to ALines.Count - 1 do
    VData := VData + UTF8String(ALines[i] + #13#10);
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
      // the file is not available - the reason goes to the memo list only
      Lock;
      try
        FConnLog.Append('[' + FormatDateTime('hh:nn:ss.zzz', Now) +
          '] tcp log file "' + FTcpLogName + '" failed, logging disabled: ' + E.Message);
      finally
        Unlock;
      end;
    end;
  end;
end;

procedure TfrmTcpNmeaServer.CloseLogFiles;
begin
  FreeAndNil(FNmeaFile);
  FreeAndNil(FTcpFile);
end;

procedure TfrmTcpNmeaServer.LogParamChanged(Sender: TObject);
begin
  // flush what is still buffered before the file is closed
  if (not chkLogNmea.Checked) then begin
    FlushNmeaFile;
    FreeAndNil(FNmeaFile);
  end;
  if (not chkLogTcp.Checked) then
    FreeAndNil(FTcpFile);
end;

procedure TfrmTcpNmeaServer.UpdateCounters;
var
  VClients: Integer;
begin
  // the clients count is shared with the accept thread, the tcp error
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
  sbStatus.Panels[3].Text := 'tcp err: ' + IntToStr(FStatTcpErr);
end;

procedure TfrmTcpNmeaServer.UpdateButtons;
begin
  btnStartServer.Enabled := (FListenSocket = INVALID_SOCKET) and FWSAOk;
  btnStopServer.Enabled := (FListenSocket <> INVALID_SOCKET);
  // the gpsd mode is applied at the server start - no toggling while running
  chkGpsd.Enabled := (FListenSocket = INVALID_SOCKET);
  btnPlay.Enabled := (Length(FCues) > 0) and (not FPlaying);
  btnStopPlay.Enabled := FPlaying;
  if (FListenSocket <> INVALID_SOCKET) then
    lblServerState.Caption := 'listening on 0.0.0.0:' + edPort.Text
  else
    lblServerState.Caption := 'server stopped';
end;

procedure TfrmTcpNmeaServer.btnStartServerClick(Sender: TObject);
begin
  StartServer;
end;

procedure TfrmTcpNmeaServer.btnStopServerClick(Sender: TObject);
begin
  StopServer;
  UpdateButtons;
end;

procedure TfrmTcpNmeaServer.StartServer;
var
  VPort: Integer;
  VAddr: TSockAddr;
begin
  if (FListenSocket <> INVALID_SOCKET) then
    Exit;

  VPort := StrToIntDef(edPort.Text, 0);
  if (VPort < 1) or (VPort > 65535) then begin
    ShowMessage('Invalid port!');
    Exit;
  end;

  // the gpsd mode is fixed at the server start (the checkbox is disabled
  // while the server is running)
  FGpsdMode := chkGpsd.Checked;

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
    LogTcp('server started on port ' + IntToStr(VPort) + ' (gpsd mode)')
  else
    LogTcp('server started on port ' + IntToStr(VPort));
  // resume the broadcast paused by the previous StopServer (same point)
  if FPausedByServerStop and (0 < Length(FCues)) then begin
    FPausedByServerStop := FALSE;
    FPlaying := TRUE;
    FLastTick := GetTickCount;
  end;
  UpdateButtons;
end;

procedure TfrmTcpNmeaServer.StopServer;
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
    LogTcp('server stopped');
  end;
  RemoveAllClients('server stopped');
  if (FListenSocket <> INVALID_SOCKET) then begin
    closesocket(FListenSocket);
    FListenSocket := INVALID_SOCKET;
  end;
end;

procedure TfrmTcpNmeaServer.AddAcceptedClient(const AClient: TSocket; const AAddr: TSockAddr);
var
  VInfo: TClientInfo;
  VNonBlocking: u_long;
begin
  // non-blocking sockets - the sender never blocks the ui thread
  // (the explicit LONGINT cast keeps FIONBIO ($8004667E) warning-free)
  VNonBlocking := 1;
  ioctlsocket(AClient, Longint(FIONBIO), VNonBlocking);

  FillChar(VInfo, sizeof(VInfo), 0);
  VInfo.Socket := AClient;
  VInfo.Peer := Format('%d.%d.%d.%d:%d', [
    Byte(AAddr.sa_data[2]),
    Byte(AAddr.sa_data[3]),
    Byte(AAddr.sa_data[4]),
    Byte(AAddr.sa_data[5]),
    (Byte(AAddr.sa_data[0]) shl 8) or Byte(AAddr.sa_data[1])]);
  VInfo.Watching := FALSE;

  LogTcp('client ' + VInfo.Peer + ' connected');

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

procedure TfrmTcpNmeaServer.RemoveClientLocked(AIndex: Integer; const AReason: string);
var
  VPeer: string;
begin
  // the critical section is already locked
  VPeer := FClients[AIndex].Peer;
  closesocket(FClients[AIndex].Socket);
  FClients.Delete(AIndex);
  LogTcp('client ' + VPeer + ' disconnected (' + AReason + ')');
end;

procedure TfrmTcpNmeaServer.RemoveAllClients(const AReason: string);
begin
  Lock;
  try
    while (FClients.Count > 0) do begin
      closesocket(FClients[0].Socket);
      LogTcp('client ' + FClients[0].Peer + ' disconnected (' + AReason + ')');
      FClients.Delete(0);
    end;
  finally
    Unlock;
  end;
end;

procedure TfrmTcpNmeaServer.SendToAllClients(const AData: AnsiString);
var
  i, VSent: Integer;
begin
  if (0 = Length(AData)) then
    Exit;
  Lock;
  try
    for i := FClients.Count - 1 downto 0 do begin
      // gpsd streams only to the clients which sent the WATCH command
      if FGpsdMode and (not FClients[i].Watching) then
        Continue;
      VSent := send(FClients[i].Socket, PAnsiChar(AData)^, Length(AData), 0);
      if (SOCKET_ERROR = VSent) then begin
        if (WSAEWOULDBLOCK = WSAGetLastError) then
          Continue; // send buffer is full - skip this chunk
        InterlockedIncrement(FStatTcpErr);
        RemoveClientLocked(i, 'send error');
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TfrmTcpNmeaServer.CheckClients;
var
  i, VReceived, VRes: Integer;
  VInfo: TClientInfo;
  VSet: TFDSet;
  VTimeout: TTimeVal;
  VBuf: array [0..4095] of AnsiChar;
begin
  // select() every client with zero timeout, drain the received data
  // (clients may send queries - just ignore them), remove the disconnected
  Lock;
  try
    for i := FClients.Count - 1 downto 0 do begin
      FD_ZERO(VSet);
      _FD_SET(FClients[i].Socket, VSet);
      VTimeout.tv_sec := 0;
      VTimeout.tv_usec := 0;
      VRes := select(0, @VSet, nil, nil, @VTimeout);
      if (SOCKET_ERROR = VRes) then begin
        InterlockedIncrement(FStatTcpErr);
        RemoveClientLocked(i, 'select error');
        Continue;
      end;
      if (VRes > 0) then begin
        VReceived := recv(FClients[i].Socket, VBuf[0], sizeof(VBuf), 0);
        if (VReceived < 0) then begin
          // select() can report the data which recv() does not find (a rare
          // winsock race) - the client is alive, keep it
          if (WSAEWOULDBLOCK <> WSAGetLastError) then begin
            InterlockedIncrement(FStatTcpErr);
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
            LogTcp('client ' + FClients[i].Peer + ': WATCH received - streaming');
          end;
        end;
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TfrmTcpNmeaServer.LoadTrackFromFile(const AFileName: string);
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

procedure TfrmTcpNmeaServer.btnOpenGpxClick(Sender: TObject);
begin
  if (not dlgOpen.Execute) then
    Exit;
  LoadTrackFromFile(dlgOpen.FileName);
end;

procedure TfrmTcpNmeaServer.btnPlayClick(Sender: TObject);
begin
  StartPlayback;
end;

procedure TfrmTcpNmeaServer.btnStopPlayClick(Sender: TObject);
begin
  StopPlayback;
end;

procedure TfrmTcpNmeaServer.StartPlayback;
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

procedure TfrmTcpNmeaServer.StopPlayback;
begin
  FPausedByServerStop := FALSE; // the explicit stop overrides the pause
  FPlaying := FALSE;
  lblPlayState.Caption := '';
  UpdateButtons;
end;

procedure TfrmTcpNmeaServer.EmulParamChanged(Sender: TObject);
begin
  // schedule the next emulation action from the current moment
  if chkDrop.Checked then
    FNextDropTick := GetTickCount + Cardinal(Max(1, StrToIntDef(edDropSec.Text, 10))) * 1000;
  if chkStall.Checked then begin
    FNextStallTick := GetTickCount + Cardinal(Max(1, StrToIntDef(edStallSec.Text, 30))) * 1000;
    FStallActive := FALSE;
  end;
end;

procedure TfrmTcpNmeaServer.tmrWorkTimer(Sender: TObject);
begin
  DoWorkTick;
end;

procedure TfrmTcpNmeaServer.DoWorkTick;
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
  // 1) write the pending tcp events and the buffered nmea data to the logs
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
    // 4) emulation - connection drops
    VDropSec := Max(1, StrToIntDef(edDropSec.Text, 10));
    if (chkDrop.Checked) then begin
      if (not FDropEnabled) then begin
        FDropEnabled := TRUE;
        FNextDropTick := VNow + Cardinal(VDropSec) * 1000;
      end;
      VDue := ((VNow - FNextDropTick) < $80000000);
      if VDue then begin
        FNextDropTick := VNow + Cardinal(VDropSec) * 1000;
        LogTcp('*** emulated connection drop ***');
        RemoveAllClients('emulated connection drop');
      end;
    end else
      FDropEnabled := FALSE;

    // 5) emulation - transmission stalls
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
        LogTcp('--- emulated stall ended ---');
      end;
      VDue := ((VNow - FNextStallTick) < $80000000);
      if VDue and (not FStallActive) then begin
        FNextStallTick := VNow + Cardinal(VStallSec) * 1000;
        FStallUntilTick := VNow + Cardinal(VStallMSec);
        FStallActive := TRUE;
        LogTcp('--- emulated stall for ' + IntToStr(VStallMSec) + ' ms ---');
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
      LogNmeaRaw(sJson);
      FStatSentBytes := FStatSentBytes + Length(sJson);
    end;
    SendToAllClients(FCues[FCueIdx].SGga);
    SendToAllClients(FCues[FCueIdx].SRmc);
    LogNmeaRaw(FCues[FCueIdx].SGga);
    LogNmeaRaw(FCues[FCueIdx].SRmc);
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

procedure TfrmTcpNmeaServer.DrainLogs;
var
  VConn: TStringList;
begin
  VConn := TStringList.Create;
  try
    Lock;
    try
      VConn.Assign(FConnLog);
      FConnLog.Clear;
    finally
      Unlock;
    end;
    if (VConn.Count > 0) then begin
      // the file gets every line, the memo only the last ones
      if chkLogTcp.Checked then
        WriteTcpFile(VConn);
      mmTcp.Lines.BeginUpdate;
      try
        mmTcp.Lines.AddStrings(VConn);
        while (mmTcp.Lines.Count > cMaxMemoLines) do
          mmTcp.Lines.Delete(0);
      finally
        mmTcp.Lines.EndUpdate;
      end;
      SendMessage(mmTcp.Handle, EM_LINESCROLL, 0, mmTcp.Lines.Count);
    end;
    // flush the buffered raw nmea data at least once per second
    FlushNmeaFile;
  finally
    VConn.Free;
  end;
end;

procedure TfrmTcpNmeaServer.UpdateClientList;
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

end.
