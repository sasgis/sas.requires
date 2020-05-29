(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_track_saver;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_print,
  vsagps_public_tracks,
  vsagps_public_sysutils,
  vsagps_public_point,
  vsagps_public_position,
  vsagps_public_trackpoint;

type
  Tvsagps_track_saver = class(TObject)
  private
    FUserPointer: Pointer;
    // params to write to gpx
    FVSAGPS_GPX_WRITER_PARAMS: PVSAGPS_GPX_WRITER_PARAMS;
    // callback proc
    FVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC;
    // params for callback proc
    FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS;
    // sync
    FCS: TRTLCriticalSection;

    // add string to log
    procedure InternalLogString(const ATrackType: TVSAGPS_TrackType;
                                const AValue: AnsiString);
  protected
    // active track types
    FActiveTrackTypes: TVSAGPS_TrackTypes;
    // call cakkback for some params
    FCallCallbackOnParams: TVSAGPS_TrackParams;
    // flag to log localtime to sasx
    FWriteSasxLocalTime: LongBool;
    // internal file name and other params (to write to log)
    FExecuteGPSCmd_WaypointData: TExecuteGPSCmd_WaypointData;
    // format
    FFormatSettings: TFormatSettings;
    // params by type
    FTTP_GpxOpened: array [TVSAGPS_TrackType] of Boolean;
    FTTP_TrkOpened: array [TVSAGPS_TrackType] of Boolean;
    FTTP_TrkSegOpened: array [TVSAGPS_TrackType] of Boolean;
    FTTP_SegmentCounter: TVSAGPS_arr_TrackType_DWORD;
    FTTP_SizeInBytes: TVSAGPS_arr_TrackType_DWORD;
    FTTP_SegPointsCounter: TVSAGPS_arr_TrackType_DWORD;
    FTTP_AllPointsCounter: TVSAGPS_arr_TrackType_DWORD;
    FTTP_WayPointsCounter: TVSAGPS_arr_TrackType_DWORD;
    // sync
    procedure LockCS;
    procedure UnlockCS;
    procedure InitializeCallbackParams;
    procedure Internal_TTP_Init(const tt: TVSAGPS_TrackType);
    procedure Internal_TTP_Initialize;
    procedure Clear_FExecuteGPSCmd_WaypointData;
  protected
    // datetime for sasx
    function InternalGetSasxLocalTime: AnsiString;
    // internal filename for sasx
    function InternalGetSasxInternalFileName: AnsiString;
    // make text for wpt and trkpt
    function InternalMakeGpxPointText(const pATP: Pvsagps_AddTrackPoint;
                                      const ANameTrackParam: TVSAGPS_TrackParam;
                                      const ATagName: AnsiString;
                                      const ATimeWithMSec: Boolean): AnsiString;
    // rountine for extensions and optional params
    function InternalGetTrackParamString(const pATP: Pvsagps_AddTrackPoint;
                                         const ATrackParam: TVSAGPS_TrackParam;
                                         var AParamValue: AnsiString): Boolean;
    // simple routine
    procedure InternalAddPredefinedExtensions_Simple(const CArr: TVSAGPS_GPX_Extension_Values;
                                                     const SDelimiter, STail: AnsiString;
                                                     var AResult: AnsiString);

  private
    procedure AddRoundFloat32(
      var AResult: AnsiString;
      const AValue: Single;
      const ARound: ShortInt;
      const ATagName: AnsiString
    );
    procedure AddRoundFloat64(
      var AResult: AnsiString;
      const AValue: Double;
      const ARound: ShortInt;
      const ATagName: AnsiString
    );
  protected
    // add PAnsiChar to log
    procedure InternalLogBuffer(const ATrackType: TVSAGPS_TrackType;
                                const ABuffer: Pointer;
                                const dwBufferSize: DWORD); virtual;
    // restart log
    procedure InternalRestartTooLongTrack(const ATrackType: TVSAGPS_TrackType); virtual;
    // add trackpoint
    procedure DoAddTrackPoint(const ATrackType: TVSAGPS_TrackType;
                              const pATP: Pvsagps_AddTrackPoint);
    // add waypoint
    procedure DoAddWayPoint(const ATrackType: TVSAGPS_TrackType;
                            const pATP: Pvsagps_AddTrackPoint);
    // write track header to log
    procedure DoWriteGpxOpen(const ATrackType: TVSAGPS_TrackType;
                             const pATP: Pvsagps_AddTrackPoint);
    // create new track
    procedure DoWriteTrkOpen(const ATrackType: TVSAGPS_TrackType;
                             const pATP: Pvsagps_AddTrackPoint);
    // create new track segment
    procedure DoWriteTrkSegOpen(const ATrackType: TVSAGPS_TrackType;
                                const pATP: Pvsagps_AddTrackPoint);
    // close track
    procedure DoWriteTrkClose(const ATrackType: TVSAGPS_TrackType);
    // close track segment
    procedure DoWriteTrkSegClose(const ATrackType: TVSAGPS_TrackType);
    // close total
    procedure DoWriteGpxClose(const ATrackType: TVSAGPS_TrackType);

    // add low-level buffer
    procedure DoAddSerialized(const ATrackType: TVSAGPS_TrackType;
                              const ABuffer: PAnsiChar;
                              const dwLen: DWORD);
    // close all
    function InternalCloseALL: LongBool;

    // call user callback function for tag values
    procedure InternalRunCallback(const pATP: Pvsagps_AddTrackPoint;
                                  var sResult: AnsiString;
                                  const tp: TVSAGPS_TrackParam;
                                  const sTag: AnsiString);

    // set params externally
    function SetTrackerParams(const AParamType: Byte;
                              const AParamData: Pointer): LongBool; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // active
    function Active: LongBool; virtual;

    // add low-level packet
    procedure AddPacket(const pBuffer: PAnsiChar;
                        const dwLen: DWORD;
                        const pReserved: PDWORD);

    // add high-level packet
    procedure AddTrackPoint(const pATP: Pvsagps_AddTrackPoint);

    // add point (not in track!)
    procedure AddWayPoint(const pATP: Pvsagps_AddTrackPoint);

    function CloseALL: LongBool; virtual;
    function StartTracks(const ATrackTypes: TVSAGPS_TrackTypes): LongBool;

    property UserPointer: Pointer read FUserPointer;
    property VSAGPS_GPX_WRITER_PARAMS: PVSAGPS_GPX_WRITER_PARAMS read FVSAGPS_GPX_WRITER_PARAMS;
    property VSAGPS_LOGGER_GETVALUES_CALLBACK_PROC: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC read FVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC;
  end;

const
  vsagps_track_saver_set_of_predefined_types = [tpHdrXmlns, tpHdrSchemaLocation, tpTrkName, tpTrkPtExtensions, tpWptExtensions, tpTrkExtensions];

implementation

uses
  vsagps_public_memory;

{ Tvsagps_track_saver }

procedure Tvsagps_track_saver.Clear_FExecuteGPSCmd_WaypointData;
begin
  VSAGPS_FreeAndNil_PAnsiChar(FExecuteGPSCmd_WaypointData.sz_sasx_file_name);
  VSAGPS_FreeAndNil_PAnsiChar(FExecuteGPSCmd_WaypointData.sz_cmt);
  VSAGPS_FreeAndNil_PAnsiChar(FExecuteGPSCmd_WaypointData.sz_desc);
  VSAGPS_FreeAndNil_PAnsiChar(FExecuteGPSCmd_WaypointData.sz_sym);
end;

function Tvsagps_track_saver.CloseALL: LongBool;
begin
  LockCS;
  try
    Result := InternalCloseALL;
  finally
    UnlockCS;
  end;
end;

constructor Tvsagps_track_saver.Create;
begin
  InitializeCriticalSection(FCS);

  Internal_TTP_Initialize;

  FVSAGPS_GPX_WRITER_PARAMS:=nil;
  FVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC:=nil;
  FUserPointer:=nil;
  FWriteSasxLocalTime:=FALSE;
  FActiveTrackTypes:=[];
  FCallCallbackOnParams:=[];

  ZeroMemory(@FExecuteGPSCmd_WaypointData, sizeof(FExecuteGPSCmd_WaypointData));

  ZeroMemory(@FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS, sizeof(FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS));
  FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS.wSize:=sizeof(FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS);

  VSAGPS_PrepareFormatSettings(FFormatSettings);
  with FFormatSettings do begin
    DateSeparator := '.';
    ShortDateFormat := 'dd.mm.yyyy';
    TimeSeparator := ':';
    LongTimeFormat := 'hh:nn:ss';
    ShortTimeFormat := 'hh:nn:ss';
  end;
end;

destructor Tvsagps_track_saver.Destroy;
begin
  CloseALL;
  DeleteCriticalSection(FCS);
  InitializeCallbackParams;
  Clear_FExecuteGPSCmd_WaypointData;
  inherited;
end;

procedure Tvsagps_track_saver.DoAddSerialized(const ATrackType: TVSAGPS_TrackType;
                                              const ABuffer: PAnsiChar;
                                              const dwLen: DWORD);
begin
  case ATrackType of
    ttLocationAPI,
    ttNMEA, ttGarmin: begin
      // counters
      Inc(FTTP_SegPointsCounter[ATrackType]);
      Inc(FTTP_AllPointsCounter[ATrackType]);
      // write to log
      InternalLogBuffer(ATrackType, ABuffer, dwLen);
      // check restart too long logs
      InternalRestartTooLongTrack(ATrackType);
    end;
  end;
end;

procedure Tvsagps_track_saver.DoAddTrackPoint(const ATrackType: TVSAGPS_TrackType;
                                              const pATP: Pvsagps_AddTrackPoint);
var
  bNewSeg: Boolean;
  sRes: AnsiString;
begin
  // skip for low-level logs
  if (ATrackType in [ttNMEA, ttGarmin, ttLocationAPI]) then
    Exit;

  // fill value
  pATP^.eTrackType := ATrackType;

  bNewSeg := (not FTTP_TrkSegOpened[ATrackType]);
  DoWriteTrkSegOpen(ATrackType, pATP);
  sRes := '';

  with pATP^.pPos^ do
  case ATrackType of
    ttPLT: begin
      sRes := Round_Float64_to_StringA(PositionLat, FFormatSettings, round_posn) + ',' +
              Round_Float64_to_StringA(PositionLon, FFormatSettings, round_posn) + ',' +
              IntToStrA(Ord(bNewSeg)) + ',';

      if (NoData_Float64(Altitude)) then
        sRes := sRes + IntToStrA(cPLT_no_Altitude)
      else
        sRes := sRes + Round_Float64_to_StringA(Altitude*cFromMetersToFeet, FFormatSettings, round_ele);

      sRes := sRes + ',' +
            FloatToStrA(UTCDate+UTCTime, FFormatSettings) + ',' +
            DateToStrA(UTCDate, FFormatSettings) + ',' +
            TimeToStrA(UTCTime, FFormatSettings) + #13#10;
    end;

    ttGPX: begin
      sRes := InternalMakeGpxPointText(pATP, tpTrkptName, 'trkpt', TRUE);
    end;
  end;

  if (Length(sRes)>0) then begin
    // counters
    Inc(FTTP_SegPointsCounter[ATrackType]);
    Inc(FTTP_AllPointsCounter[ATrackType]);
    // write to log
    InternalLogString(ATrackType, sRes);
    // check restart too long logs
    InternalRestartTooLongTrack(ATrackType);
  end;
end;

procedure Tvsagps_track_saver.DoAddWayPoint(const ATrackType: TVSAGPS_TrackType;
                                            const pATP: Pvsagps_AddTrackPoint);
var sRes: AnsiString;
begin
  // skip for low-level logs
  if (ATrackType in [ttNMEA, ttGarmin, ttLocationAPI]) then
    Exit;

  // fill value
  pATP^.eTrackType := ATrackType;

  // close tracks
  DoWriteTrkClose(ATrackType);

  sRes := '';

  case ATrackType of
    ttGPX: begin
      sRes:=InternalMakeGpxPointText(pATP, tpWptName, 'wpt', FALSE);
    end;
  end;
  
  if (Length(sRes)>0) then begin
    // counters
    Inc(FTTP_WayPointsCounter[ATrackType]);
    // write to log
    InternalLogString(ATrackType, sRes);
    // check restart too long logs
    InternalRestartTooLongTrack(ATrackType);
  end;
end;

function Tvsagps_track_saver.Active: LongBool;
begin
  Result:=(FActiveTrackTypes<>[]);
end;

procedure Tvsagps_track_saver.AddPacket(const pBuffer: PAnsiChar;
                                        const dwLen: DWORD;
                                        const pReserved: PDWORD);
var i: TVSAGPS_TrackType;
begin
  if (0=dwLen) or (nil=pBuffer) then
    Exit;
  LockCS;
  try
    if Active then
    for i := Low(i) to High(i) do
    if (i in FActiveTrackTypes) then begin
      DoAddSerialized(i, pBuffer, dwLen);
    end;
  finally
    UnlockCS;
  end;
end;

procedure Tvsagps_track_saver.AddRoundFloat32(
  var AResult: AnsiString;
  const AValue: Single;
  const ARound: ShortInt;
  const ATagName: AnsiString
);
begin
  if (not NoData_Float32(AValue)) then begin
    AResult := AResult + '<' + ATagName + '>' +
               Round_Float32_to_StringA(AValue, FFormatSettings, ARound) +
               '</' + ATagName + '>' + #13#10;
  end;
end;

procedure Tvsagps_track_saver.AddRoundFloat64(
  var AResult: AnsiString;
  const AValue: Double;
  const ARound: ShortInt;
  const ATagName: AnsiString
);
begin
  if (not NoData_Float64(AValue)) then begin
    AResult := AResult + '<' + ATagName + '>' +
               Round_Float64_to_StringA(AValue, FFormatSettings, ARound) +
               '</' + ATagName + '>' + #13#10;
  end;
end;

procedure Tvsagps_track_saver.AddTrackPoint(const pATP: Pvsagps_AddTrackPoint);
var
  i: TVSAGPS_TrackType;
  bOK: Boolean;
begin
  if (nil=pATP) then
    Exit;

  // no position - no log
  // if lplf_SkipNoneFix - log only if fixed
  bOK := (pATP^.pPos^.PositionOK) and
         ((pATP^.pPos^.DGPS.Dimentions>=2) or (0=(FVSAGPS_GPX_WRITER_PARAMS^.dwLoggerFlags and lwpf_SkipNoneFix)));

  LockCS;
  try
    if Active then
    for i := Low(i) to High(i) do
    if (i in FActiveTrackTypes) then begin
      if bOK then begin
        // correct point
        DoAddTrackPoint(i, pATP);
      end else begin
        // no signal
        DoWriteTrkSegClose(i);
      end;
    end;
  finally
    UnlockCS;
  end;
end;

procedure Tvsagps_track_saver.AddWayPoint(const pATP: Pvsagps_AddTrackPoint);
var i: TVSAGPS_TrackType;
begin
  if (nil=pATP) then
    Exit;

  // no position - no log
  if (pATP^.pPos^.PositionOK) then begin
    LockCS;
    try
      if Active then
      for i := Low(i) to High(i) do
      if (i in FActiveTrackTypes) then begin
        // write waypoint
        DoAddWayPoint(i, pATP);
      end;
    finally
      UnlockCS;
    end;
  end;
end;

procedure Tvsagps_track_saver.DoWriteTrkClose(const ATrackType: TVSAGPS_TrackType);
begin
  if FTTP_TrkOpened[ATrackType] then begin
    DoWriteTrkSegClose(ATrackType);
    if FTTP_TrkOpened[ATrackType] then
    case ATrackType of
      ttGPX: begin
        InternalLogString(ATrackType, '</trk>'+#13#10);
      end;
    end;
    FTTP_TrkOpened[ATrackType]:=FALSE;
  end;
end;

procedure Tvsagps_track_saver.DoWriteTrkOpen(const ATrackType: TVSAGPS_TrackType;
                                             const pATP: Pvsagps_AddTrackPoint);
var ss: AnsiString;
begin
  // write header (if need)
  DoWriteGpxOpen(ATrackType, pATP);

  // only if track not opened
  if (not FTTP_TrkOpened[ATrackType]) then begin
    case ATrackType of
      ttGPX: begin
        ss := '<trk>'+#13#10;

        // name
        InternalRunCallback(pATP, ss, tpTrkName, 'name');

        // cmt
        InternalRunCallback(pATP, ss, tpTrkCmt, 'cmt');

        // desc
        InternalRunCallback(pATP, ss, tpTrkDesc, 'desc');

        // src
        InternalRunCallback(pATP, ss, tpTrkSrc, 'src');

        // link (full text)
        InternalRunCallback(pATP, ss, tpTrkLink, '');

        // number
        Inc(FTTP_SegmentCounter[ATrackType]);
        ss := ss + '<number>' + IntToStrA(FTTP_SegmentCounter[ATrackType]) + '</number>' + #13#10;

        // type
        InternalRunCallback(pATP, ss, tpTrkType, 'type');

        // extensions
        InternalRunCallback(pATP, ss, tpTrkExtensions, 'extensions');

        InternalLogString(ATrackType, ss);
      end;
    end;
    FTTP_TrkOpened[ATrackType]:=TRUE;
    // after trk write trkseg
    DoWriteTrkSegOpen(ATrackType, pATP);
  end;
end;

procedure Tvsagps_track_saver.DoWriteTrkSegClose(const ATrackType: TVSAGPS_TrackType);
begin
  if FTTP_TrkSegOpened[ATrackType] then begin
    // trkseg
    case ATrackType of
      ttGPX: begin
        InternalLogString(ATrackType, '</trkseg>'+#13#10);
      end;
    end;
    FTTP_TrkSegOpened[ATrackType]:=FALSE;
    // trk
    if C_close_TRK_on_close_TRKSEG then
      DoWriteTrkClose(ATrackType);
  end;
end;

procedure Tvsagps_track_saver.DoWriteTrkSegOpen(const ATrackType: TVSAGPS_TrackType;
                                                const pATP: Pvsagps_AddTrackPoint);
begin
  DoWriteTrkOpen(ATrackType, pATP);

  if (not FTTP_TrkSegOpened[ATrackType]) then begin
    FTTP_SegPointsCounter[ATrackType] := 0;
    case ATrackType of
      ttGPX: begin
        InternalLogString(ATrackType, '<trkseg>'+#13#10);
      end;
    end;
    FTTP_TrkSegOpened[ATrackType]:=TRUE;
  end;
end;

procedure Tvsagps_track_saver.DoWriteGpxClose(const ATrackType: TVSAGPS_TrackType);
begin
  if FTTP_GpxOpened[ATrackType] then begin
    DoWriteTrkClose(ATrackType);
    case ATrackType of
      ttGPX: begin
        InternalLogString(ATrackType, '</gpx>'+#13#10);
      end;
    end;
    FTTP_GpxOpened[ATrackType]:=FALSE;
  end;
end;

procedure Tvsagps_track_saver.DoWriteGpxOpen(const ATrackType: TVSAGPS_TrackType;
                                             const pATP: Pvsagps_AddTrackPoint);
var ss, si: AnsiString;
begin
  if (not FTTP_GpxOpened[ATrackType]) then begin
    FTTP_GpxOpened[ATrackType] := TRUE;
    case ATrackType of
      ttPLT: begin
        // local time
        ss := AnsiString(DateTimeToStr(Now));
        // no commas allowed
        if (PosA(',', ss) > 0) then begin
          StringReplaceSingleCharA(ss, ',', '_');
        end;

        ss := 'OziExplorer Track Point File Version 2.1'+#13#10+
              'WGS 84'+#13#10+
              'Altitude is in Feet'+#13#10+
              'Reserved 3'+#13#10+
              '0,2,255,Track Log File - '+ss+',1,0,2,8421376'+#13#10+
              // Field 1 : always zero (0)
              // Field 2 : width of track plot line on screen - 1 or 2 are usually the best
              // Field 3 : track color (RGB)
              // Field 4 : track description (no commas allowed)
              // Field 5 : track skip value - reduces number of track points plotted, usually set to 1
              // Field 6 : track type - 0 = normal , 10 = closed polygon , 20 = Alarm Zone
              // Field 7 : track fill style - 0 =bsSolid; 1 =bsClear; 2 =bsBdiagonal; 3 =bsFdiagonal; 4 =bsCross; 5 =bsDiagCross; 6 =bsHorizontal; 7 =bsVertical;
              // Field 8 : track fill color (RGB)
              '0'+#13#10; // number of points in track
        InternalLogString(ATrackType, ss);
      end;
      ttGPX: begin
        case FVSAGPS_GPX_WRITER_PARAMS.btStandalone of
          0: si:='yes';
          1: si:='no';
          else
            si:='';
        end;
        if (0<Length(si)) then
          si := ' standalone="'+si+'"';

        // start header
        ss := '<?xml version="1.0" encoding="UTF-8"'+si+' ?>'+#13#10+
              '<gpx'+#13#10+
              'xmlns="http://www.topografix.com/GPX/1/1"'+#13#10;

        // xmlns for extensions
        if InternalGetTrackParamString(pATP, tpHdrXmlns, si) then
          ss := ss + si;

        // creator (required!)
        if not InternalGetTrackParamString(pATP, tpHdrCreator, si) then
          si:='vsagps';
        ss := ss + 'creator="'+si+'"'+#13#10;

        ss := ss + 'version="1.1"'+#13#10+
                   'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+#13#10;

        if (not InternalGetTrackParamString(pATP, tpHdrSchemaLocation, si)) then
          si := '';

        ss := ss + 'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd'+si+'">'+#13#10+
                   '<metadata>'+#13#10;
        // name
        InternalRunCallback(pATP, ss, tpMetaName, 'name');

        // desc
        InternalRunCallback(pATP, ss, tpMetaDesc, 'desc');

        // author
        InternalRunCallback(pATP, ss, tpMetaAuthor, 'author');

        // copyright
        InternalRunCallback(pATP, ss, tpMetaCopyright, 'copyright');

        // link (full text)
        InternalRunCallback(pATP, ss, tpMetaLink, '');

        // time
        ss := ss + '<time>' + DateTime_To_ISO8601A(Now,FALSE)+'</time>'+#13#10;

        // keywords
        InternalRunCallback(pATP, ss, tpMetaKeywords, 'keywords');

        // bounds
        InternalRunCallback(pATP, ss, tpMetaBounds, 'bounds');

        // extensions
        InternalRunCallback(pATP, ss, tpMetaExtensions, 'extensions');

        ss := ss + '</metadata>'+#13#10;

        InternalLogString(ATrackType, ss);
      end;
    end;
  end;
end;

function Tvsagps_track_saver.InternalGetSasxInternalFileName: AnsiString;
begin
  Result := SafeSetStringP(FExecuteGPSCmd_WaypointData.sz_sasx_file_name);
  if (0<Length(Result)) then
    Result:='<sasx:file_name>'+Result+'</sasx:file_name>'+#13#10;
end;

function Tvsagps_track_saver.InternalGetSasxLocalTime: AnsiString;
var
  st, lt: TSystemTime;
  sd, ld: TDateTime;
begin
  Result:='';

  with FVSAGPS_GPX_WRITER_PARAMS^ do
  if (0=btWrite_Sasx_LocalTime) and (0=btWrite_Sasx_SystemTime) and (0=btWrite_Sasx_TimeShift) then
    Exit;
  
  // write system time
  GetSystemTime(st);
  sd := SystemTimeToDateTime(st);
  if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btWrite_Sasx_SystemTime) then
    Result := '<sasx:systemtime>' + DateTime_To_ISO8601A(sd, TRUE) + '</sasx:systemtime>' + #13#10;
    
  // write local time and shift
  if SystemTimeToTzSpecificLocalTime(nil, st, lt) then begin
    ld := SystemTimeToDateTime(lt);
    if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btWrite_Sasx_LocalTime) then begin
      Result := Result + '<sasx:localtime>' + DateTime_To_ISO8601A(ld, TRUE) + '</sasx:localtime>' + #13#10;
    end;
    if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btWrite_Sasx_TimeShift) then begin
      Result := Result + '<sasx:timeshift>' + Round_Float64_to_StringA((ld-sd)*SecsPerDay, FFormatSettings, round_timeshift) + '</sasx:timeshift>' + #13#10;
    end;
  end;
end;

procedure Tvsagps_track_saver.InitializeCallbackParams;
begin
  with FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS do begin
    UsePredefined:=TRUE;
    UseResult:=FALSE;
    if (nil<>AStrResult) then
      VSAGPS_FreeAndNil_PAnsiChar(AStrResult);
    if (nil<>WStrResult) then
      VSAGPS_FreeAndNil_PWideChar(WStrResult);
  end;
end;

procedure Tvsagps_track_saver.InternalAddPredefinedExtensions_Simple(const CArr: TVSAGPS_GPX_Extension_Values;
                                                                     const SDelimiter, STail: AnsiString;
                                                                     var AResult: AnsiString);
var
  i: TVSAGPS_GPX_Extension;
  s: AnsiString;
begin
  for i := Low(TVSAGPS_GPX_Extension) to High(TVSAGPS_GPX_Extension) do
  if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btUse_Predefined_Extensions[i]) then begin
    s:=CArr[i];
    if (0<Length(s)) then
      AResult:=AResult+SDelimiter+s+STail;
  end;
end;

function Tvsagps_track_saver.InternalCloseALL: LongBool;
var i: TVSAGPS_TrackType;
begin
  for i := Low(TVSAGPS_TrackType) to High(TVSAGPS_TrackType) do begin
    DoWriteGpxClose(i);
  end;
  Result:=TRUE;
end;

function Tvsagps_track_saver.InternalGetTrackParamString(const pATP: Pvsagps_AddTrackPoint;
                                                         const ATrackParam: TVSAGPS_TrackParam;
                                                         var AParamValue: AnsiString): Boolean;

  procedure _AddSatsInfo;
  var s: AnsiString;
  begin
    if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btWrite_Sasx_Sats_Info) then
    if (nil<>pATP^.szSatsInfo) then begin
      s := SafeSetStringP(pATP^.szSatsInfo);
      if (0<Length(s)) then
        AParamValue:=AParamValue+'<sasx:sats_info>'+s+'</sasx:sats_info>'+#13#10;
    end;
  end;

begin
  Result := FALSE;
  AParamValue:='';

  // fill param
  pATP^.eTrackParam := ATrackParam;

  InitializeCallbackParams;

  // user handler
  if Assigned(FVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC) then
  try
    FVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC(FUserPointer, Self, pATP, @FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS);
  except
    InitializeCallbackParams;
  end;

  // set result string
  if FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS.UseResult then begin
    AParamValue := SafeSetStringP(FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS.AStrResult);
    Result:=(0<Length(AParamValue));
  end;

  // add predefined
  if FVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS.UsePredefined then
  if (ATrackParam in vsagps_track_saver_set_of_predefined_types) then begin
    if (ttGPX=pATP^.eTrackType) then
    case ATrackParam of

      tpHdrXmlns: begin
        InternalAddPredefinedExtensions_Simple(cGPX_xmlns, '', #13#10, AParamValue);
      end;

      tpHdrSchemaLocation: begin
        InternalAddPredefinedExtensions_Simple(cGPX_schemaLocation, ' ', '', AParamValue);
      end;

      tpTrkName: begin
        // local time to trk name
        if (0<Length(AParamValue)) then
          AParamValue:=AParamValue+' ';
        AParamValue := AParamValue + DateTime_To_ISO8601A(Now,FALSE);
      end;

      tpTrkPtExtensions, tpWptExtensions, tpTrkExtensions: begin
        // sasgis extensions (should be first because of src tag)
        if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btUse_Predefined_Extensions[geSASGIS]) then begin
          // trk or trkpt or wpt
          
          // set user string as src
          if (0<Length(AParamValue)) then begin
            AParamValue:='<sasx:src>'+AParamValue+'</sasx:src>'+#13#10;
          end;

          // set others (not for trk)
          if (tpTrkExtensions<>ATrackParam) then begin
            // additional position params
            if (nil<>pATP^.pPos) then
            with pATP^.pPos^ do begin
              // sasx:course
              AddRoundFloat64(AParamValue, Heading, round_heading, 'sasx:course');
              // sasx:speed_kmh
              AddRoundFloat64(AParamValue, Speed_KMH, round_hspeed, 'sasx:speed_kmh');
              // sasx:vspeed_ms
              AddRoundFloat64(AParamValue, VSpeed_MS, round_vspeed, 'sasx:vspeed_ms');
            end;
            // additional satellites params
            _AddSatsInfo;
          end;
          
          // time - if requested (with flag) or if internal file created
          // for trk - always (without flag)
          if (FWriteSasxLocalTime) or (tpTrkExtensions=ATrackParam) or (nil<>FExecuteGPSCmd_WaypointData.sz_sasx_file_name) then begin
            FWriteSasxLocalTime:=FALSE;
            AParamValue:=AParamValue+InternalGetSasxLocalTime;
          end;

          if (nil<>FExecuteGPSCmd_WaypointData.sz_sasx_file_name) then begin
            AParamValue:=AParamValue+InternalGetSasxInternalFileName;
            VSAGPS_FreeAndNil_PAnsiChar(FExecuteGPSCmd_WaypointData.sz_sasx_file_name);
          end;
        end;

        // nmea extensions
        if (0<>FVSAGPS_GPX_WRITER_PARAMS^.btUse_Predefined_Extensions[geNMEA]) and (nil<>pATP^.pPos) then
        with pATP^.pPos^ do begin
          // nmea:course
          AddRoundFloat64(AParamValue, Heading, round_heading, 'nmea:course');
          // nmea:speed
          AddRoundFloat64(AParamValue, Speed_KMH, round_hspeed, 'nmea:speed');
        end;

        // TODO: garmin extensions
        // http://developer.garmin.com/schemas/gpxx/v3/
        // Temperature
        // Depth

        // finish
        if (0<Length(AParamValue)) then
          AParamValue := #13#10 + AParamValue; // wrap after open tag
      end;
    end;
    Result:=(0<Length(AParamValue));
  end;

  InitializeCallbackParams;
end;

procedure Tvsagps_track_saver.InternalLogBuffer(const ATrackType: TVSAGPS_TrackType;
                                                const ABuffer: Pointer;
                                                const dwBufferSize: DWORD);
begin
  // inc size
  FTTP_SizeInBytes[ATrackType]:=FTTP_SizeInBytes[ATrackType]+dwBufferSize;
end;

procedure Tvsagps_track_saver.InternalLogString(const ATrackType: TVSAGPS_TrackType;
                                                const AValue: AnsiString);
begin
  InternalLogBuffer(ATrackType, PAnsiChar(AValue), Length(AValue));
end;

function Tvsagps_track_saver.InternalMakeGpxPointText(const pATP: Pvsagps_AddTrackPoint;
                                                      const ANameTrackParam: TVSAGPS_TrackParam;
                                                      const ATagName: AnsiString;
                                                      const ATimeWithMSec: Boolean): AnsiString;
var
  si: AnsiString;

  function _NextTP(aShift: Byte): TVSAGPS_TrackParam;
  begin
    Result:=ANameTrackParam;
    while (0<aShift) do begin
      Dec(aShift);
      Inc(Result);
    end;
  end;

  procedure _AddTP(aShift: Byte; const ASubTagName: AnsiString);
  var ntp: TVSAGPS_TrackParam;
  begin
    ntp:=_NextTP(aShift);
    InternalRunCallback(pATP, Result, ntp, ASubTagName);
  end;

begin
  with pATP^.pPos^ do begin
    // lat lon
    Result := '<' + ATagName +
             ' lat="' + Round_Float64_to_StringA(PositionLat, FFormatSettings, round_posn) +
            '" lon="' + Round_Float64_to_StringA(PositionLon, FFormatSettings, round_posn) + '">' + #13#10;

    // ele - Elevation (in meters) of the point
    AddRoundFloat64(Result, Altitude, round_ele, 'ele');

    // time - Creation/modification timestamp for element.
    // Date and time in are in Univeral Coordinated Time (UTC), not local time!
    // Conforms to ISO 8601 specification for date/time representation.
    // Fractional seconds are allowed for millisecond timing in tracklogs
    if UTCDateOK and UTCTimeOK then begin
      Result := Result + '<time>' + DateTime_To_ISO8601A(UTCDate+UTCTime, ATimeWithMSec) + '</time>' + #13#10;
    end;

    // magvar - Magnetic variation (in degrees) at the point
    // VMagVar:=APosition.MagVar;
    if (MagVar.variation_symbol<>#0) then begin
      AddRoundFloat32(Result, MagVar.variation_degree, round_heading, 'magvar');
    end;

    // geoidheight - Height (in meters) of geoid (mean sea level) above WGS84 earth ellipsoid. As defined in NMEA GGA message
    AddRoundFloat64(Result, GeoidHeight, round_ele, 'geoidheight');

    // name
    _AddTP(0, 'name');

    // cmt
    _AddTP(1, 'cmt');

    // desc
    _AddTP(2, 'desc');

    // src - Source of data - "Garmin eTrex", "USGS quad Boston North", e.g
    _AddTP(3, 'src');

    // link (full text)
    _AddTP(4, '');

    // sym
    _AddTP(5, 'sym');

    // type
    _AddTP(6, 'type');

    // fix - value comes from list: {'none'|'2d'|'3d'|'dgps'|'pps'}
    with DGPS do
    if ('P'=Nmea23_Mode) then
      si:='pps'
    else if ('D'=Nmea23_Mode) then
      si:='dgps'
    else if (2<Dimentions) then
      si:='3d'
    else if (1<Dimentions) then
      si:='2d'
    else
      si:='none';
    Result:=Result+'<fix>'+si+'</fix>'+#13#10;

    // sat - nonNegativeInteger (both gp and gl)
    if (nil<>pATP^.pSatFixAll) then begin
      Result := Result + '<sat>' + IntToStrA(Get_PVSAGPS_FIX_ALL_FixCount(pATP^.pSatFixAll, False)) + '</sat>' + #13#10;
    end;

    // hdop
    AddRoundFloat64(Result, HDOP, round_hdop, 'hdop');

    // vdop
    AddRoundFloat64(Result, VDOP, round_vdop, 'vdop');

    // pdop
    AddRoundFloat64(Result, PDOP, round_pdop, 'pdop');

    // ageofdgpsdata
    if ('D'=DGPS.Nmea23_Mode) then begin
      AddRoundFloat32(Result, DGPS.DGPS_Age_Second, round_age_second, 'ageofdgpsdata');
    end;

    // dgpsid - 0 <= value <= 1023 - Represents a differential GPS station
    if ('D'=DGPS.Nmea23_Mode) then begin
      Result := Result + '<dgpsid>' + IntToStrA(DGPS.DGPS_Station_ID) + '</dgpsid>' + #13#10;
    end;

    // speed (m/s) - undocumented (use some apps and devices)
    if (0<>VSAGPS_GPX_WRITER_PARAMS^.btWrite_Undocumented_Speed) then
    if (not NoData_Float64(Speed_KMH)) then begin
      Result := Result + '<speed>' +
                Round_Float64_to_StringA(Speed_KMH/3.6, FFormatSettings, round_hspeed) +
                '</speed>' + #13#10;
    end;

    // course - undocumented (use some apps and devices)
    if (0<>VSAGPS_GPX_WRITER_PARAMS^.btWrite_Undocumented_Course) then begin
      AddRoundFloat64(Result, Heading, round_heading, 'course');
    end;

    // extensions
    _AddTP(7, 'extensions');

    // close tag
    Result := Result + '</' + ATagName + '>' + #13#10;
  end;
end;

procedure Tvsagps_track_saver.InternalRestartTooLongTrack(const ATrackType: TVSAGPS_TrackType);
begin
  // nothing
end;

procedure Tvsagps_track_saver.InternalRunCallback(
  const pATP: Pvsagps_AddTrackPoint;
  var sResult: AnsiString;
  const tp: TVSAGPS_TrackParam;
  const sTag: AnsiString);
var si: AnsiString;
begin
  if (tp in FCallCallbackOnParams)
     OR
     (tp in vsagps_track_saver_set_of_predefined_types) then
  if InternalGetTrackParamString(pATP, tp, si) then
  if (0<Length(si)) then begin
    // add tag name
    if (0<Length(sTag)) then
      si:='<'+sTag+'>'+si+'</'+sTag+'>'+#13#10;
    sResult := sResult + si;
  end;
end;

procedure Tvsagps_track_saver.Internal_TTP_Init(const tt: TVSAGPS_TrackType);
begin
  FTTP_GpxOpened[tt]:=FALSE;
  FTTP_TrkOpened[tt]:=FALSE;
  FTTP_TrkSegOpened[tt]:=FALSE;
  FTTP_SegmentCounter[tt]:=0;
  FTTP_SizeInBytes[tt]:=0;
  FTTP_SegPointsCounter[tt]:=0;
  FTTP_AllPointsCounter[tt]:=0;
  FTTP_WayPointsCounter[tt]:=0;
end;

procedure Tvsagps_track_saver.Internal_TTP_Initialize;
var i: TVSAGPS_TrackType;
begin
  for i := Low(i) to High(i) do begin
    Internal_TTP_Init(i);
  end;
end;

procedure Tvsagps_track_saver.LockCS;
begin
  EnterCriticalSection(FCS);
end;

function Tvsagps_track_saver.SetTrackerParams(const AParamType: Byte;
                                              const AParamData: Pointer): LongBool;
begin
  Result:=TRUE;
  
  case AParamType of
    stp_SetUserPointerParam: begin
      // set user pointer
      FUserPointer:=AParamData;
    end;
    stp_SetGPXWriterParam: begin
      // set pointer to gpx writer params
      FVSAGPS_GPX_WRITER_PARAMS:=AParamData;
    end;
    stp_SetCallbackFilterParam: begin
      // set filter for callback function
      FCallCallbackOnParams:=PVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER(AParamData)^.seCallCallbackOnParams;
    end;
    stp_SetCallbackFuncParam: begin
      // set callback function
      FVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC:=AParamData;
    end;
  end;
end;

function Tvsagps_track_saver.StartTracks(const ATrackTypes: TVSAGPS_TrackTypes): LongBool;
begin
  LockCS;
  try
    FActiveTrackTypes:=ATrackTypes;
    Result := TRUE;
  finally
    UnlockCS;
  end;
end;

procedure Tvsagps_track_saver.UnlockCS;
begin
  LeaveCriticalSection(FCS);
end;

end.