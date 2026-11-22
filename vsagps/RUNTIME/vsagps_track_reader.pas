(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_track_reader;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_tracks,
  vsagps_public_position,
  vsagps_public_trackpoint,
  vsagps_public_unit_info,
  vsagps_public_print,
  vsagps_public_gpx,
  vsagps_public_kml,
  vsagps_public_xml_parser,
  vsagps_public_unicode,
  vsagps_public_sysutils,
  vsagps_public_parser,
  vsagps_public_device,
  vsagps_device_base,
  vsagps_runtime,
  vsagps_parser_nmea;

type
  Tvsagps_track_reader = class(Tvsagps_device_with_nmea)
  private
    FOriginalSourceFiles: WideString;
    FCurrentFile: WideString;
    FPX_options: Tvsagps_XML_ParserOptions;
    FFormatSettings: TFormatSettings;
    // the timestamp of the last played point - the base of the
    // real time pacing (the pause between the points is scaled
    // by the playback speed multiplier)
    FLastPointUTCDateTime: TDateTime;
    FLastPointUTCDateTimeValid: Boolean;
    FLastPointUTCDateTimeWithDate: Boolean;
    // the utc date and time captured from the nmea parser callbacks:
    // the RMC sentences carry the date, the GGA and GLL carry the time only
    FParserUTCDate: TNMEA_Date;
    FParserUTCDateValid: Boolean;
    FParserUTCTime: TNMEA_Time;
    FParserUTCTimeValid: Boolean;
  protected
    Fparser_nmea: Tvsagps_parser_nmea;
  protected
    function InternalSaveToReuse: Boolean;
    procedure InternalCreateNmeaParser;
    procedure InternalLoadAndParseTracks;
    procedure Internal_RunForSingleItem(const ASource: WideString; const ASelfAuxPtr: Pointer);
    procedure Internal_RunForSingleFile(const ASource: WideString; const ASelfAuxPtr: Pointer);
    procedure Internal_RunForSingleFolder(const ASource: WideString; const ASelfAuxPtr: Pointer);
    procedure Internal_RunForList(const ASource: WideString; const ASelfAuxPtr: Pointer);
    // nmea track parser
    procedure InternalParseTrackLines(
      const ASrcFileName: WideString;
      const ALineParserProc: TVSAGPS_DivideStringToLinesA_Proc
    );
    // ONLY for ANSI files!!!
    procedure InternalLineParser_LocationAPI(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
    procedure InternalLineParser_Garmin(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
    procedure InternalLineParser_NMEA(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
    procedure InternalLineParser_PLT(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
    // for kml/coordinates
    procedure InternalKMLCoordsParser(const ACoordinate: WideString; const ASelfAuxPtr: Pointer);
    // callback proc for xml parser
    procedure ParseGPX_UserProc(const pPX_options: Pvsagps_XML_ParserOptions;
                                const pPX_data: Pvsagps_XML_ParserResult;
                                const pPX_state: Pvsagps_XML_ParserState);
    // wait after the point was sent: the pause between the points is taken
    // from the point timestamps (the real time replay) and is scaled by the
    // playback speed multiplier; when the timestamp is not available - the
    // fixed pause is used as a fallback
    procedure SleepAfterTrackPoint(const AUTCDateTime: TDateTime;
                                   const AUTCDateTimeValid: Boolean;
                                   const AUTCDateTimeWithDate: Boolean);
    // wait in short slices to keep the device stop responsive
    procedure SleepWaitSlices(const APauseMSec: Int64);
    // reset the pacing state - called before each source file
    procedure ResetTrackPacingState;
    // true when the sources are requested to be replayed in a circle
    function InternalIsLoopPlayback: Boolean;
    // nmea parser callback - capture the utc date and time of the sentences
    procedure Do_TrackReader_ApplyUTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
    // combine the captured nmea utc date and time into the timestamp
    function Get_Captured_NMEA_UTCTimeStamp(out AUTCDateTime: TDateTime;
                                            out AUTCDateTimeWithDate: Boolean): Boolean;
  protected
    procedure Internal_Before_Open_Device; override;
    // start session - operations to establish connection
    function WorkingThread_StartSession: Boolean; override;
    // send query packet to gps
    function WorkingThread_SendPacket: Boolean; override;
    // receive packets from device to queue
    function WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean; override;
  public
    constructor Create(const APtrSourceFiles: PWideChar); reintroduce;
    destructor Destroy; override;

    function SerializePacket(const APacket: Pointer;
                             out ASerializedSize: DWORD;
                             const AReserved: PDWORD): Pointer; override;
    function ParsePacket(const ABuffer: Pointer): DWORD; override;

    function SendPacket(const APacketBuffer: Pointer;
                        const APacketSize: DWORD;
                        const AFlags: DWORD): LongBool;
  end;

// calc the pause between the two track points in ms at the x1 playback
// speed; the timestamps without the date part (the time only ones) are
// allowed - their midnight wrap is handled; returns 0 when the current
// timestamp is unusable (backward time, the first point, the file change)
function TrackPoints_Pause_MSec(const APrevUTCDateTime: TDateTime;
                                const APrevUTCDateTimeWithDate: Boolean;
                                const ACurUTCDateTime: TDateTime;
                                const ACurUTCDateTimeWithDate: Boolean): Int64;

implementation

uses
  vsagps_public_sats_info,
  vsagps_public_location_api,
  vsagps_public_memory,
  DateUtils;

const
  // the fixed fallback pause between the points without the timestamp is
  // capped: it should not delay the next timestamped point too much
  cTrackReader_MaxPause_MSec = 5000;

function TrackPoints_Pause_MSec(const APrevUTCDateTime: TDateTime;
                                const APrevUTCDateTimeWithDate: Boolean;
                                const ACurUTCDateTime: TDateTime;
                                const ACurUTCDateTimeWithDate: Boolean): Int64;
var
  nDeltaMSec: Int64;
begin
  Result:=0;
  nDeltaMSec:=Round((ACurUTCDateTime-APrevUTCDateTime)*MSecsPerDay);
  if (nDeltaMSec>0) then
    // the usual forward move
    Result:=nDeltaMSec
  else if (nDeltaMSec<0) then begin
    // the negative delta - either the backward time or the midnight wrap
    // on the timestamps without the date part (the time only ones)
    if (not APrevUTCDateTimeWithDate) and (not ACurUTCDateTimeWithDate) and
       (nDeltaMSec<=-(MSecsPerDay div 2)) then
      // the day changed on the time only timestamps: the delta just
      // crossed the midnight, so the real gap is about a day smaller
      Result:=nDeltaMSec+MSecsPerDay;
    // otherwise the time goes back - restart the pacing from this point
  end;
  // the zero delta (the same timestamp) means no pause
end;

procedure rTVSAGPS_ParseGPX_UserProc(const pUserObjPointer: Pointer;
                                     const pUserAuxPointer: Pointer;
                                     const pPX_options: Pvsagps_XML_ParserOptions;
                                     const pPX_result: Pvsagps_XML_ParserResult;
                                     const pPX_state: Pvsagps_XML_ParserState); stdcall;
begin
  Tvsagps_track_reader(pUserObjPointer).ParseGPX_UserProc(pPX_options, pPX_result, pPX_state);
end;

{ Tvsagps_track_reader }

constructor Tvsagps_track_reader.Create(const APtrSourceFiles: PWideChar);
begin
  inherited Create;
  FDefaultPacketType:=(FDefaultPacketType and (not vgpt_Allow_Stats));
  FForceInfiniteTimeout:=TRUE;
  Fparser_nmea:=nil;
  FCurrentFile:='';
  FOriginalSourceFiles := SafeSetStringP(APtrSourceFiles);
  VSAGPS_PrepareFormatSettings(FFormatSettings);
  ResetTrackPacingState;
end;

destructor Tvsagps_track_reader.Destroy;
begin
  FreeAndNil(Fparser_nmea);
  inherited;
end;

procedure Tvsagps_track_reader.InternalCreateNmeaParser;
begin
  if (nil=Fparser_nmea) then begin
    Fparser_nmea:=Tvsagps_parser_nmea.Create;
    Fparser_nmea.FOnECHOSOUNDER:=FParser_FOnECHOSOUNDER;
    Fparser_nmea.FOnGGA:=FParser_FOnGGA;
    Fparser_nmea.FOnGLL:=FParser_FOnGLL;
    Fparser_nmea.FOnGSA:=FParser_FOnGSA;
    Fparser_nmea.FOnGSV:=FParser_FOnGSV;
    Fparser_nmea.FOnRMC:=FParser_FOnRMC;
    Fparser_nmea.FOnApplyUTCDateTime:=Do_TrackReader_ApplyUTCDateTime;
{$if defined(USE_NMEA_VTG)}
    Fparser_nmea.FOnVTG:=FParser_FOnVTG;
{$ifend}
  end;
end;

procedure Tvsagps_track_reader.InternalKMLCoordsParser(const ACoordinate: WideString; const ASelfAuxPtr: Pointer);
var
  tData: TCoordLineData;
  pPacket: PSingleTrackPointData;
begin
  if parse_kml_coordinate(ACoordinate, @tData, FFormatSettings) then
  try
    pPacket:=VSAGPS_GetMemZ(sizeof(pPacket^));
    try
      Sleep(0);
      
      // position
      pPacket^.gps_data.PositionOK:=tData.latlon_ok;
      pPacket^.gps_data.PositionLon:=tData.lon1;
      pPacket^.gps_data.PositionLat:=tData.lat0;

      // alt
      if tData.ele_ok then
        pPacket^.gps_data.Altitude:=tData.ele
      else
        pPacket^.gps_data.Altitude:=cGps_Float32_no_data;

      // no other params - set fix
      pPacket^.gps_data.DGPS.Nmea23_Mode:='A';
      pPacket^.gps_data.DGPS.Dimentions:=3;
      pPacket^.gps_data.FixStatus:=2;
      pPacket^.gps_data.NavMode:='A';

      // send to queue
      FExternal_Queue.AppendGPSPacket(pPacket, FUnitIndex);
      // wait - the kml coordinates have no timestamp
      SleepAfterTrackPoint(0, FALSE, FALSE);
    except
      VSAGPS_FreeMem(pPacket);
    end;
  except
  end;
end;

procedure Tvsagps_track_reader.InternalLineParser_Garmin(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
var
  buf_ptr: PByte;
begin
  // make original garmin buffer from string
  buf_ptr:=VSAGPS_AllocPByteByString(ALine, sizeof(TGarminUSB_Custom_Packet));
  if (nil<>buf_ptr) then
  try
    // send buffer as packet
    Sleep(0);
    Parse_GarminPVT_Packets(Pointer(buf_ptr), 0);
    // wait - no timestamp is captured for the garmin packets here
    SleepAfterTrackPoint(0, FALSE, FALSE);
  finally
    VSAGPS_FreeMem(buf_ptr);
  end;
end;

procedure Tvsagps_track_reader.InternalLineParser_LocationAPI(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
var
  buf_ptr: PByte;
begin
  // make original location api buffer from string
  buf_ptr := VSAGPS_AllocPByteByString(ALine, sizeof(Tvsagps_location_api_packet));
  if (nil<>buf_ptr) then
  try
    // send buffer as packet
    Sleep(0);
    Parse_LocationAPI_Packets(Pointer(buf_ptr), 0);
    // wait - no timestamp is captured for the location api packets here
    SleepAfterTrackPoint(0, FALSE, FALSE);
  finally
    VSAGPS_FreeMem(buf_ptr);
  end;
end;

procedure Tvsagps_track_reader.InternalLineParser_NMEA(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
var
  S: AnsiString;
  VUTCDateTime: TDateTime;
  VUTCDateTimeWithDate: Boolean;
begin
  InternalCreateNmeaParser;
  // del starter and call parser
  S:=ALine;
  if (0<Length(S)) then begin
    if (cNmea_Starter=S[1]) then
      System.Delete(S,1,1);
    Sleep(0);
    Fparser_nmea.Parse_Sentence_Without_Starter(S);
    // wait by the captured sentence timestamp; the sentences without
    // their own timestamp (GSA, GSV and the rest) reuse the timestamp
    // of the previous sentence - their pause is zero
    if Get_Captured_NMEA_UTCTimeStamp(VUTCDateTime, VUTCDateTimeWithDate) then
      SleepAfterTrackPoint(VUTCDateTime, TRUE, VUTCDateTimeWithDate)
    else
      SleepAfterTrackPoint(0, FALSE, FALSE);
  end;
end;

procedure Tvsagps_track_reader.InternalLineParser_PLT(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
var
  pPacket: PSingleTrackPointData;
  tData: TCoordLineData;
  VUTCDateTime: TDateTime;
  VUTCDateTimeValid: Boolean;
begin
  try
    InternalCreateNmeaParser;
    if parse_plt_line(ALine, @tData, Fparser_nmea, FFormatSettings) then begin
      Sleep(0);
      // the timestamp for the pacing (the plt lines carry the full datetime)
      VUTCDateTime:=0;
      VUTCDateTimeValid:=tData.dt_ok;
      if VUTCDateTimeValid then
        VUTCDateTime:=tData.dt;
      pPacket:=VSAGPS_GetMemZ(sizeof(pPacket^));
      try
        // coordinates
        pPacket^.gps_data.PositionLat:=tData.lat0;
        pPacket^.gps_data.PositionLon:=tData.lon1;
        pPacket^.gps_data.PositionOK:=tData.latlon_ok;
        
        // alt
        if tData.ele_ok then
          pPacket^.gps_data.Altitude:=tData.ele*cFootInMeters
        else
          pPacket^.gps_data.Altitude:=cGps_Float32_no_data;

        // datetime
        if tData.dt_ok then begin
          pPacket^.gps_data.UTCDate:=DateOf(tData.dt);
          pPacket^.gps_data.UTCTime:=TimeOf(tData.dt);
          pPacket^.gps_data.UTCDateOK:=TRUE;
          pPacket^.gps_data.UTCTimeOK:=TRUE;
        end;

        // other params
        pPacket^.gps_data.GeoidHeight:=cGps_Float32_no_data;
        pPacket^.gps_data.Speed_KMH:=cGps_Float32_no_data;
        pPacket^.gps_data.Heading:=cGps_Float32_no_data;
        pPacket^.gps_data.HDOP:=cGps_Float32_no_data;
        pPacket^.gps_data.VDOP:=cGps_Float32_no_data;
        pPacket^.gps_data.PDOP:=cGps_Float32_no_data;
        // fix
        pPacket^.gps_data.DGPS.Nmea23_Mode:='A';
        pPacket^.gps_data.NavMode:='A';
        pPacket^.gps_data.FixStatus:=2;

        // send
        FExternal_Queue.AppendGPSPacket(pPacket, FUnitIndex);
        SleepAfterTrackPoint(VUTCDateTime, VUTCDateTimeValid, TRUE);
      except
        VSAGPS_FreeMem(pPacket);
      end;
    end;
  except
  end;
end;

procedure Tvsagps_track_reader.InternalLoadAndParseTracks;

  function _SourceMultiFiles: Boolean;
  begin
{$if defined(VSAGPS_USE_UNICODE)}
    Result:=(LastDelimiterW(#13,FOriginalSourceFiles)>0);
{$else}
    Result:=(System.Pos(#13,FOriginalSourceFiles)>0);
{$ifend}
  end;

begin
  ZeroMemory(@FPX_options, sizeof(FPX_options));

  // tracks from gpx
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  // trk - always
  FPX_options.gpx_options.bParse_trk:=TRUE;
  // just coords?
  if (0=(FALLDeviceParams^.dwSourceFileFlagsIn and dpsffi_OnlyPosition)) then begin
    // not just coords - full
    Inc(FPX_options.gpx_options.bParse_wpt_params);
    Inc(FPX_options.gpx_options.bParse_trk_extensions);
    Inc(FPX_options.gpx_options.bParse_wpt_extensions);
  end;
{$ifend}

  // tracks from kml
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
  //FPX_options.kml_options.
{$ifend}

  // check file(s) or folder
  if _SourceMultiFiles then begin
    // multiple files or folders
    Internal_RunForList(FOriginalSourceFiles, nil);
  end else begin
    // single file or single folder
    Internal_RunForSingleItem(FOriginalSourceFiles, nil);
  end;
end;

procedure Tvsagps_track_reader.InternalParseTrackLines(
  const ASrcFileName: WideString;
  const ALineParserProc: TVSAGPS_DivideStringToLinesA_Proc
);
var
  s: AnsiString;
begin
  s := VSAGPS_ReadFileContent(ASrcFileName);

  if (0 < Length(s)) then begin
    // parse text (divide into lines)
    VSAGPS_DividePCharToLines(PAnsiChar(s), ALineParserProc, nil, False, @(FWT_Params.bAskToExit));
  end;
end;

function Tvsagps_track_reader.InternalSaveToReuse: Boolean;
begin
  Result:=(dpsffi_SaveToReuse=(FALLDeviceParams^.dwSourceFileFlagsIn and dpsffi_SaveToReuse));
end;

function Tvsagps_track_reader.InternalIsLoopPlayback: Boolean;
begin
  Result:=(dpsffi_LoopPlayback=(FALLDeviceParams^.dwSourceFileFlagsIn and dpsffi_LoopPlayback));
end;

procedure Tvsagps_track_reader.Internal_Before_Open_Device;
begin
  inherited;
  FGPSDeviceHandle:=FakeFileHandle;
  // load and parse track (simulate device connecting) - only if save to object
  if InternalSaveToReuse then
    InternalLoadAndParseTracks;
end;

procedure Tvsagps_track_reader.Internal_RunForList(const ASource: WideString; const ASelfAuxPtr: Pointer);
begin
  VSAGPS_DividePCharToLines(PWideChar(ASource), Internal_RunForSingleItem, ASelfAuxPtr, FALSE, @(FWT_Params.bAskToExit));
end;

procedure Tvsagps_track_reader.Internal_RunForSingleFile(const ASource: WideString; const ASelfAuxPtr: Pointer);
var
  sExt,sFN: WideString;
  tttSrc: TVSAGPS_TrackType;
  tttXML: Tvsagps_XML_source_format;

  procedure _BeforeFile;
  begin
    FCurrentFile:=ASource;
    InternalSetUnitInfo(guik_SourceFileName, sFN);
    // the timestamps of the different files are not related
    ResetTrackPacingState;
  end;

begin
  // single file - check type and run parser
{$if defined(VSAGPS_USE_UNICODE)}
  if not FileExistsW(ASource) then
    Exit;
  sExt:=ExtractFileExtW(ASource);
  sFN:=ExtractFileNameW(ASource);
{$else}
  if not FileExists(ASource) then
    Exit;
  sExt:=ExtractFileExt(ASource);
  sFN:=ExtractFileName(ASource);
{$ifend}

  tttXML:=Get_ParseXML_FileExtType(sExt);
  if (xsf_Unsupported=tttXML) then begin
    // not supported by xml loader
    if Get_TrackType_By_Ext(sExt, tttSrc) then begin
      _BeforeFile;
      case tttSrc of
        ttNMEA: begin
          // start nmea parser
          InternalParseTrackLines(FCurrentFile, InternalLineParser_NMEA);
        end;
        ttGarmin: begin
          // start garmin parser
          InternalParseTrackLines(FCurrentFile, InternalLineParser_Garmin);
        end;
        ttLocationAPI: begin
          // start location api parser
          InternalParseTrackLines(FCurrentFile, InternalLineParser_LocationAPI);
        end;
        ttPLT: begin
          // start plt parser
          InternalParseTrackLines(FCurrentFile, InternalLineParser_PLT);
        end;
      end;
    end;
  end else begin
    // supported by xml loader - gpx or kml
    _BeforeFile;
{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
    VSAGPS_LoadAndParseXML(Self, nil, FCurrentFile, nil, TRUE, @FPX_options, rTVSAGPS_ParseGPX_UserProc, FFormatSettings);
{$ifend}
  end;
end;

procedure Tvsagps_track_reader.Internal_RunForSingleFolder(const ASource: WideString; const ASelfAuxPtr: Pointer);
var
  ffdw: TWIN32FindDataW;
  ffdh: THandle;
  ws_lookup, ws_current: WideString;
begin
  // single folder - lookup files
  ws_lookup:=ASource+'\*.*';
  ffdh:=FindFirstFileW(PWideChar(ws_lookup),ffdw);
  if (INVALID_HANDLE_VALUE<>ffdh) then
  try
    repeat
      // check
      if FWT_Params.bAskToExit then
        break;
      // work
      ws_current:=ffdw.cFileName;
      // file or folder
      if (FILE_ATTRIBUTE_DIRECTORY=(ffdw.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)) then begin
        // folder
        if (ws_current<>'.') and (ws_current<>'..') then
          Internal_RunForSingleFolder(ASource+'\'+ws_current, ASelfAuxPtr);
      end else begin
        // file
        Internal_RunForSingleFile(ASource+'\'+ws_current, ASelfAuxPtr);
      end;
      // next
      if (FALSE=FindNextFileW(ffdh,ffdw)) then
        break;
    until FALSE;
  finally
    Windows.FindClose(ffdh);
  end;
end;

procedure Tvsagps_track_reader.Internal_RunForSingleItem(const ASource: WideString; const ASelfAuxPtr: Pointer);
begin
  // check
  if FWT_Params.bAskToExit then
    Exit;
  if
{$if defined(VSAGPS_USE_UNICODE)}
  DirectoryExistsW(ASource)
{$else}
  DirectoryExists(ASource)
{$ifend}
  then begin
    // directory
    Internal_RunForSingleFolder(ASource, ASelfAuxPtr);
  end else begin
    // file
    Internal_RunForSingleFile(ASource, ASelfAuxPtr);
  end;
end;

procedure Tvsagps_track_reader.ParseGPX_UserProc(const pPX_options: Pvsagps_XML_ParserOptions;
                                                 const pPX_data: Pvsagps_XML_ParserResult;
                                                 const pPX_state: Pvsagps_XML_ParserState);
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
var
  pPacket: PSingleTrackPointData;
  iAllocSize: SmallInt;
  VUTCDateTime: TDateTime;
  VUTCDateTimeValid: Boolean;
  VUTCDateTimeWithDate: Boolean;
{$ifend}
begin
  // check exit
  if FWT_Params.bAskToExit then begin
    pPX_state^.aborted_by_user:=TRUE;
    Exit;
  end;

  // for GPX - get only trkpt with extensions
  case pPX_state^.src_fmt of
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  xsf_GPX: begin
    // GPX - switch by tag
    case pPX_data^.gpx_data.current_tag of
      gpx_trkpt: begin
        // trkpt - make point and send to queue
        if (xtd_Close=pPX_state^.tag_disposition) then begin
          // completely
          Sleep(0);

          // calc alloc size
          if (sasx_sats_info in pPX_data^.gpx_data.extensions_data.fAvail_strs) then
            iAllocSize:=sizeof(TFullTrackPointData)
          else
            iAllocSize:=sizeof(TSingleTrackPointData);

          // alloc
          pPacket:=VSAGPS_GetMemZ(iAllocSize);
          pPacket^.full_data_size:=iAllocSize;

          // copy to buffer
          CopyMemory(@(pPacket^.gps_data), @(pPX_data^.gpx_data.wpt_data.fPos), sizeof(pPacket^.gps_data));
          pPacket^.gpx_sats_count:=pPX_data^.gpx_data.wpt_data.fSatFixCount;

          // check params
          if not (wpt_ele in pPX_data^.gpx_data.wpt_data.fAvail_wpt_params) then
            pPacket^.gps_data.Altitude:=cGps_Float32_no_data;
          if not (wpt_course in pPX_data^.gpx_data.wpt_data.fAvail_wpt_params) then
            pPacket^.gps_data.Heading:=cGps_Float32_no_data;
          if not (wpt_speed in pPX_data^.gpx_data.wpt_data.fAvail_wpt_params) then
            pPacket^.gps_data.Speed_KMH:=cGps_Float32_no_data;
          if not (wpt_hdop in pPX_data^.gpx_data.wpt_data.fAvail_wpt_params) then
            pPacket^.gps_data.HDOP:=cGps_Float32_no_data;
          if not (wpt_vdop in pPX_data^.gpx_data.wpt_data.fAvail_wpt_params) then
            pPacket^.gps_data.VDOP:=cGps_Float32_no_data;
          if not (wpt_pdop in pPX_data^.gpx_data.wpt_data.fAvail_wpt_params) then
            pPacket^.gps_data.PDOP:=cGps_Float32_no_data;

          // deserialize satellites params if full data
          if (sizeof(TFullTrackPointData)=iAllocSize) then
            DeserializeSatsInfo(pPX_data^.gpx_data.extensions_data.sasx_strs[sasx_sats_info], PFullTrackPointData(pPacket));

          // the timestamp for the pacing - read before the packet goes to
          // the queue (the queue consumer owns and frees the packet)
          VUTCDateTime:=0;
          VUTCDateTimeWithDate:=FALSE;
          VUTCDateTimeValid:=pPacket^.gps_data.UTCTimeOK;
          if VUTCDateTimeValid then begin
            if (pPacket^.gps_data.UTCDateOK) then begin
              VUTCDateTime:=pPacket^.gps_data.UTCDate+pPacket^.gps_data.UTCTime;
              VUTCDateTimeWithDate:=TRUE;
            end else begin
              VUTCDateTime:=pPacket^.gps_data.UTCTime;
            end;
          end;

          // send
          FExternal_Queue.AppendGPSPacket(pPacket, FUnitIndex);
          SleepAfterTrackPoint(VUTCDateTime, VUTCDateTimeValid, VUTCDateTimeWithDate);
        end;
      end;
      else begin
        // all others - skip unused tags
        if (xtd_BeforeSub=pPX_state^.tag_disposition) and
           (pPX_data^.gpx_data.subitem_tag in [gpx_link, gpx_metadata, gpx_rte, gpx_wpt]) then begin
          pPX_state^.skip_sub:=TRUE;
        end;
      end;
    end;
  end;
{$ifend}

{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
  xsf_KML: begin
    // KML
  end;
{$ifend}

  xsf_XML: begin
    // any XML
  end;
  end;
end;

function Tvsagps_track_reader.ParsePacket(const ABuffer: Pointer): DWORD;
begin
  if Assigned(FALLDeviceParams^.pTrackPointHandler) then
    Result:=FALLDeviceParams^.pTrackPointHandler(InternalGetUserPointer, FUnitIndex, FGPSDeviceType, 0, ABuffer)
  else
    Result:=0;
end;

function Tvsagps_track_reader.SendPacket(const APacketBuffer: Pointer; const APacketSize, AFlags: DWORD): LongBool;
begin
  Result:=FALSE;
end;

function Tvsagps_track_reader.SerializePacket(const APacket: Pointer; out ASerializedSize: DWORD; const AReserved: PDWORD): Pointer;
begin
  Result:=nil;
  ASerializedSize := 0;
end;

procedure Tvsagps_track_reader.SleepAfterTrackPoint(const AUTCDateTime: TDateTime;
                                                    const AUTCDateTimeValid: Boolean;
                                                    const AUTCDateTimeWithDate: Boolean);
var
  nPauseMSec: Int64;
  dwMultiplier: DWORD;
begin
  if AUTCDateTimeValid then begin
    // the real time pacing: the pause is the time delta between the points
    if FLastPointUTCDateTimeValid then
      nPauseMSec:=TrackPoints_Pause_MSec(FLastPointUTCDateTime, FLastPointUTCDateTimeWithDate,
                                         AUTCDateTime, AUTCDateTimeWithDate)
    else
      nPauseMSec:=0;
    // remember for the next point
    FLastPointUTCDateTime:=AUTCDateTime;
    FLastPointUTCDateTimeValid:=TRUE;
    FLastPointUTCDateTimeWithDate:=AUTCDateTimeWithDate;
  end else begin
    // the point has no timestamp - the fixed pause between the points
    nPauseMSec:=GetDeviceWorkerThreadTimeoutMSec(FALLDeviceParams, FThisDeviceParams) div 16;
    // the pause is capped
    if (nPauseMSec>cTrackReader_MaxPause_MSec) then
      nPauseMSec:=cTrackReader_MaxPause_MSec;
  end;

  // the playback speed multiplier scales the pause: the bigger multiplier -
  // the shorter pause (2 - twice faster), 1 and 0 mean the real time
  dwMultiplier:=FALLDeviceParams^.dwSourceFileSpeedMultiplier;
  if (dwMultiplier<1) then
    dwMultiplier:=1;
  nPauseMSec:=nPauseMSec div dwMultiplier;

  SleepWaitSlices(nPauseMSec);
end;

procedure Tvsagps_track_reader.SleepWaitSlices(const APauseMSec: Int64);
const
  // the wait is sliced to notice the stop request in time
  cWaitSliceMSec = 250;
var
  nLeftMSec: Int64;
begin
  nLeftMSec:=APauseMSec;
  while (nLeftMSec>0) and (not FWT_Params.bAskToExit) do begin
    if (nLeftMSec>cWaitSliceMSec) then begin
      Sleep(cWaitSliceMSec);
      Dec(nLeftMSec,cWaitSliceMSec);
    end else begin
      Sleep(nLeftMSec);
      nLeftMSec:=0;
    end;
  end;
end;

procedure Tvsagps_track_reader.ResetTrackPacingState;
begin
  FLastPointUTCDateTime:=0;
  FLastPointUTCDateTimeValid:=FALSE;
  FLastPointUTCDateTimeWithDate:=FALSE;
  FParserUTCDateValid:=FALSE;
  FParserUTCTimeValid:=FALSE;
end;

procedure Tvsagps_track_reader.Do_TrackReader_ApplyUTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
begin
  if NMEA_Time_Valid(ATime) then begin
    FParserUTCTime:=ATime^;
    FParserUTCTimeValid:=TRUE;
  end;
  if (nil<>ADate) and NMEA_Date_Valid(ADate) then begin
    FParserUTCDate:=ADate^;
    FParserUTCDateValid:=TRUE;
  end;
end;

function Tvsagps_track_reader.Get_Captured_NMEA_UTCTimeStamp(out AUTCDateTime: TDateTime;
                                                             out AUTCDateTimeWithDate: Boolean): Boolean;
var
  dtDate, dtTime: TDateTime;
begin
  Result:=FALSE;
  AUTCDateTime:=0;
  AUTCDateTimeWithDate:=FALSE;
  if (not FParserUTCTimeValid) then
    Exit;
  if (not TryEncodeTime(FParserUTCTime.hour, FParserUTCTime.min, FParserUTCTime.sec, FParserUTCTime.msec, dtTime)) then
    Exit;
  // the RMC sentences carry the date, the GGA and GLL carry the time only
  if FParserUTCDateValid then begin
    if (not TryEncodeDate(Convert_TwoDigitYear_to_FourDigitYear(FParserUTCDate.year),
                          FParserUTCDate.month,
                          FParserUTCDate.day,
                          dtDate)) then
      Exit;
    AUTCDateTime:=dtDate+dtTime;
    AUTCDateTimeWithDate:=TRUE;
  end else begin
    AUTCDateTime:=dtTime;
  end;
  Result:=TRUE;
end;

function Tvsagps_track_reader.WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean;
begin
  Result:=FALSE;
  if (0=FGPSDeviceHandle) then
    Exit;

  if InternalSaveToReuse then begin
    // send loaded and internally saved points to EXE
    // TODO: not implemented
  end else begin
    // direct load-parse-send without saving
    if InternalIsLoopPlayback then begin
      // the loop playback replays the sources again and again; the pacing
      // state resets per file (in _BeforeFile), so a new lap starts from
      // the first point at once; the lap ends only by the device stop
      // request (the pacing waits and the parsers check it)
      repeat
        InternalLoadAndParseTracks;
      until FWT_Params.bAskToExit;
    end else begin
      InternalLoadAndParseTracks;
    end;
  end;

  // disconnect
  FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_EOF);
  Result:=TRUE;
end;

function Tvsagps_track_reader.WorkingThread_SendPacket: Boolean;
begin
  Result:=TRUE;
end;

function Tvsagps_track_reader.WorkingThread_StartSession: Boolean;
begin
  Result:=TRUE;
end;

end.