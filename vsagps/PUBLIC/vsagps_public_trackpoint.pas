(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_trackpoint;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_tracks,
  vsagps_public_position,
  vsagps_public_sysutils;

type
  Tvsagps_TrackPointStrings = packed record
    // kml and gpx
    sz_name: PAnsiChar;
    sz_desc: PAnsiChar;
    // gpx only
    sz_cmt: PAnsiChar;
    sz_src: PAnsiChar;
    sz_link: PAnsiChar;
    sz_sym: PAnsiChar;
    sz_type: PAnsiChar;
    sz_extensions: PAnsiChar;
    // kml only
    sz_Style: PAnsiChar;
    sz_styleUrl: PAnsiChar;
  end;
  Pvsagps_TrackPointStrings = ^Tvsagps_TrackPointStrings;
  
  Tvsagps_AddTrackPoint = packed record
    // fill by caller
    pPos: PSingleGPSData;        // mandatory
    pSatFixAll: PVSAGPS_FIX_ALL; // allow NIL
    szSatsInfo: PAnsiChar; // satellites info
    ptReserved: Pointer; // reserved - must be NIL
    dwReserved: DWORD; // reserved - must be 0
    btUnitIndex: Byte;
    // fill in Tvsagps_track_writer and use by event handler
    eTrackType: TVSAGPS_TrackType;
    eTrackParam: TVSAGPS_TrackParam;
  end;
  Pvsagps_AddTrackPoint = ^Tvsagps_AddTrackPoint;

  TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC = procedure (
    const pUserPointer: Pointer;
    const pLogger: Pointer;
    const pATP: Pvsagps_AddTrackPoint;
    const AParamsOut: PVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS); stdcall;

implementation

end.
