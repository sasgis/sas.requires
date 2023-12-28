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
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
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
    procedure SleepInXMLParser;
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

    function SerializePacket(const APacket: Pointer; const AReserved: PDWORD): PAnsiChar; override;
    function ParsePacket(const ABuffer: Pointer): DWORD; override;

    function SendPacket(const APacketBuffer: Pointer;
                        const APacketSize: DWORD;
                        const AFlags: DWORD): LongBool; override;
  end;

implementation

uses
  vsagps_public_sats_info,
  vsagps_public_location_api,
  vsagps_public_memory,
  DateUtils;

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
      // wait
      SleepInXMLParser;
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
    SleepInXMLParser;
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
    SleepInXMLParser;
  finally
    VSAGPS_FreeMem(buf_ptr);
  end;
end;

procedure Tvsagps_track_reader.InternalLineParser_NMEA(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
var S: AnsiString;
begin
  InternalCreateNmeaParser;
  // del starter and call parser
  S:=ALine;
  if (0<Length(S)) then begin
    if (cNmea_Starter=S[1]) then
      System.Delete(S,1,1);
    Sleep(0);
    Fparser_nmea.Parse_Sentence_Without_Starter(S);
    SleepInXMLParser;
  end;
end;

procedure Tvsagps_track_reader.InternalLineParser_PLT(const ALine: AnsiString; const ASelfAuxPtr: Pointer);
var
  pPacket: PSingleTrackPointData;
  tData: TCoordLineData;
begin
  try
    InternalCreateNmeaParser;
    if parse_plt_line(ALine, @tData, Fparser_nmea, FFormatSettings) then begin
      Sleep(0);
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
        SleepInXMLParser;
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

          // send
          FExternal_Queue.AppendGPSPacket(pPacket, FUnitIndex);
          SleepInXMLParser;
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

function Tvsagps_track_reader.SerializePacket(const APacket: Pointer; const AReserved: PDWORD): PAnsiChar;
begin
  Result:=nil;
end;

procedure Tvsagps_track_reader.SleepInXMLParser;
begin
  Sleep(GetDeviceWorkerThreadTimeoutMSec(FALLDeviceParams, FThisDeviceParams) div 16);
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
    InternalLoadAndParseTracks;
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