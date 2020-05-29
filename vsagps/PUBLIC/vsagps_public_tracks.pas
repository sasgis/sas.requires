(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_tracks;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base;

const
  lwpf_SkipNoneFix = $00000001; // do not save points to tracks without fix

type
  TVSAGPS_TrackType = (
    ttPLT,
    ttGPX,
    ttNMEA,
    ttGarmin,
    ttLocationAPI{,
    ttKML}
  );
  TVSAGPS_TrackTypes = set of TVSAGPS_TrackType;

  TVSAGPS_TrackParam = (tpHdrXmlns,
                        tpHdrCreator,
                        tpHdrSchemaLocation,

                        tpMetaName,
                        tpMetaDesc,
                        tpMetaAuthor,
                        tpMetaCopyright,
                        tpMetaLink,
                        tpMetaKeywords,
                        tpMetaBounds,
                        tpMetaExtensions,

                        tpTrkName,
                        tpTrkCmt,
                        tpTrkDesc,
                        tpTrkSrc,
                        tpTrkLink,
                        tpTrkType,
                        tpTrkExtensions,
                        
                        // contiguous!
                        tpTrkptName,
                        // used via tpTrkptName
                        tpTrkptCmt,
                        tpTrkptDesc,
                        tpTrkptSrc,
                        tpTrkptLink,
                        tpTrkptSym,
                        tpTrkptType,
                        tpTrkptExtensions,
                        
                        // contiguous in same order!
                        tpWptName,
                        // used via tpWptName
                        tpWptCmt,
                        tpWptDesc,
                        tpWptSrc,
                        tpWptLink,
                        tpWptSym,
                        tpWptType,
                        tpWptExtensions
                        );
  TVSAGPS_TrackParams = set of TVSAGPS_TrackParam;

  TVSAGPS_GPX_Extension = (geUserDefined,
                           geGarminGpxExtensions,
                           geGarminTrackPointExtension,
                           geSASGIS,
                           geNMEA);

  TVSAGPS_GPX_Extension_Values = array [TVSAGPS_GPX_Extension] of AnsiString;

  TVSAGPS_arr_TrackType_DWORD = array [TVSAGPS_TrackType] of DWORD;
  PVSAGPS_arr_TrackType_DWORD = ^TVSAGPS_arr_TrackType_DWORD;

  //TVSAGPS_Track_WideStringMode = (twsmForceString, twsmForceWideString, twsmKeepValue);

  Tvsagps_track_writer_state = (twsCreated, // created
                                twsInitialSuspended, // no logging after creating (no open handles)
                                twsStarting, // start opening handles
                                twsActive, // running (open handles)
                                twsPaused, // paused (keep handles opened)
                                twsClosing, // start closing handles
                                twsClosed, // stopped (close handles)
                                twsDestroying);


  TVSAGPS_LOGGER_STATECHANGED_PROC = procedure (const pUserPointer: Pointer;
                                                const pLogger: Pointer;
                                                const AState: Tvsagps_track_writer_state;
                                                const AFatal: LongBool); stdcall;

  TVSAGPS_LOGGER_ADD_BUFFER_PROC = procedure (const pUserPointer: Pointer;
                                              const pLogger: Pointer;
                                              const ATrackType: TVSAGPS_TrackType;
                                              const ABuffer: Pointer;
                                              const dwBufferSize: DWORD); stdcall;

  TVSAGPS_GPX_WRITER_PARAMS = packed record
    wSize: SmallInt;
    btStandalone: Byte; // 0 = yes, 1 = no, else = empty (for default=yes)
    btReserved: Byte;
    dwLoggerFlags: DWORD; // see lwpf_* constants
    btWrite_Undocumented_Course: Byte;
    btWrite_Undocumented_Speed: Byte;
    btWrite_Sasx_LocalTime: Byte;
    btWrite_Sasx_SystemTime: Byte;
    btWrite_Sasx_TimeShift: Byte;
    btWrite_Sasx_Sats_Info: Byte;
    btUse_Predefined_Extensions: array [TVSAGPS_GPX_Extension] of Byte;
  end;
  PVSAGPS_GPX_WRITER_PARAMS = ^TVSAGPS_GPX_WRITER_PARAMS;

  TVSAGPS_LOG_WRITER_PARAMS = packed record
    wSize: SmallInt;
    DelEmptyFileOnClose: WordBool;
    pLoggerStateChangedProc: TVSAGPS_LOGGER_STATECHANGED_PROC;
    RestartLogAfterPoints: TVSAGPS_arr_TrackType_DWORD; // max length of track in points
    RestartLogAfterBytes: TVSAGPS_arr_TrackType_DWORD; // max length of track in bytes
  end;
  PVSAGPS_LOG_WRITER_PARAMS = ^TVSAGPS_LOG_WRITER_PARAMS;

  TVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS = packed record
    wSize: SmallInt;
    wReserved: SmallInt;
    AStrResult: PAnsiChar; // allocated by DLL and released by EXE (even if not UseResult)
    WStrResult: PWideChar; // reserved
    UseResult: WordBool;
    UsePredefined: WordBool;
  end;
  PVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS = ^TVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS;

  TVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER = packed record
    seCallCallbackOnParams: TVSAGPS_TrackParams;
  end;
  PVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER = ^TVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER;

const
  // constants for SetTrackerParams
  stp_SetUserPointerParam = $01;
  stp_SetGPXWriterParam = $02;
  stp_SetCallbackFilterParam = $03;
  stp_SetCallbackFuncParam = $04;
  stp_SetLogPathWParam = $05;
  stp_SetLogWriterParam = $06;

const
  CVSAGPS_TrackTypeExt: array [TVSAGPS_TrackType] of WideString = (
    '.plt',
    '.gpx',
    '.nmea',
    '.garmin',
    '.locationapi'{,
    '.kml'}
  );

  C_close_TRK_on_close_TRKSEG = TRUE;

  cPLT_no_Altitude = -777;

  cFootInMeters = 0.3048; // exact
  cFromMetersToFeet = (1/cFootInMeters);

  cGPX_xmlns: TVSAGPS_GPX_Extension_Values = ('',
                                              'xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"',
                                              'xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"',
                                              'xmlns:sasx="http://sasgis.ru/xmlschemas/SasGpxExtensions/v1"',
                                              'xmlns:nmea="http://trekbuddy.net/2009/01/gpx/nmea"');

  cGPX_schemaLocation: TVSAGPS_GPX_Extension_Values = ('',
                                                       'http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd',
                                                       'http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd',
                                                       'http://sasgis.ru/xmlschemas/SasGpxExtensions/v1 http://sasgis.ru/xmlschemas/SasGpxExtensionsv1.xsd',
                                                       '');


function DWORD_to_TVSAGPS_TrackTypes(const ATrackTypes: DWORD): TVSAGPS_TrackTypes; inline;

function Byte_to_TVSAGPS_TrackTypes(const ATrackTypes: Byte): TVSAGPS_TrackTypes; inline;

function Get_TrackType_By_Ext(const wsExt: WideString; out ATrackType: TVSAGPS_TrackType): Boolean;

implementation

function DWORD_to_TVSAGPS_TrackTypes(const ATrackTypes: DWORD): TVSAGPS_TrackTypes;
begin
  Result := TVSAGPS_TrackTypes(LoByte(LoWord(ATrackTypes)));
end;

function Byte_to_TVSAGPS_TrackTypes(const ATrackTypes: Byte): TVSAGPS_TrackTypes;
begin
  Result := TVSAGPS_TrackTypes(ATrackTypes);
end;

function Get_TrackType_By_Ext(const wsExt: WideString; out ATrackType: TVSAGPS_TrackType): Boolean;
var i: TVSAGPS_TrackType;
begin
  for i := Low(i) to High(i) do
  if WideSameText(wsExt, CVSAGPS_TrackTypeExt[i]) then begin
    ATrackType:=i;
    Result:=TRUE;
    Exit;
  end;
  Result:=FALSE;
end;

end.
