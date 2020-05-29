(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_version;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils;

type
  TVSAGPS_VERSION = packed record
    wSize: SmallInt;

    // enums
    High_TVSAGPS_UNIT_INFO_Kind: SmallInt;
    High_Tvsagps_GPSState: SmallInt;
    High_Tgpms_Code: SmallInt;
    High_TVSAGPS_TrackType: SmallInt;
    High_TVSAGPS_TrackParam: SmallInt;
    High_TVSAGPS_GPX_Extension: SmallInt;

    // types
    Sizeof_Pointer: SmallInt;
    Sizeof_TCOMAutodetectOptions: SmallInt;
    Sizeof_D800_Pvt_Data_Type: SmallInt;
    Sizeof_cpo_all_sat_data: SmallInt;
    Sizeof_TNMEA_GGA: SmallInt;
    Sizeof_TNMEA_GLL: SmallInt;
    Sizeof_TNMEA_GSA: SmallInt;
    Sizeof_TNMEA_GSV: SmallInt;
    Sizeof_TNMEA_RMC: SmallInt;
    Sizeof_TNMEA_VTG: SmallInt;
    Sizeof_TVSAGPS_FIX_SATS: SmallInt;
    Sizeof_TVSAGPS_FIX_ALL: SmallInt;
    Sizeof_TVSAGPS_ALL_DEVICE_PARAMS: SmallInt;
    Sizeof_TVSAGPS_SINGLE_DEVICE_PARAMS: SmallInt;
    Sizeof_TSingleGPSData: SmallInt;
    Sizeof_TVSAGPS_GPX_WRITER_PARAMS: SmallInt;
    Sizeof_TVSAGPS_LOG_WRITER_PARAMS: SmallInt;
    Sizeof_TVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS: SmallInt;
    Sizeof_TVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER: SmallInt;
    Sizeof_Tvsagps_AddTrackPoint: SmallInt;
    Sizeof_TSingleTrackPointData: SmallInt;

    // generic types
    Sizeof_TGeneric_Trk_Point_Type: SmallInt;
    Sizeof_TGeneric_Trk_Hdr_Type: SmallInt;
    Sizeof_TGeneric_Wpt_Type: SmallInt;
    Sizeof_TGeneric_Rte_Hdr_Type: SmallInt;
    Sizeof_TGeneric_Almanac_Type: SmallInt;
  end;
  PVSAGPS_VERSION = ^TVSAGPS_VERSION;

procedure VSAGPS_Fill_Version(p: PVSAGPS_VERSION);

implementation

uses
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_unit_info,
  vsagps_public_nmea,
  vsagps_public_garmin,
  vsagps_public_position,
  vsagps_public_tracks,
  vsagps_public_trackpoint,
  vsagps_public_device;

procedure VSAGPS_Fill_Version(p: PVSAGPS_VERSION);
begin
  ZeroMemory(p, sizeof(p^));
  p^.wSize:=sizeof(p^);

  // enums
  p^.High_TVSAGPS_UNIT_INFO_Kind:=Ord(High(TVSAGPS_UNIT_INFO_Kind));
  p^.High_Tvsagps_GPSState:=Ord(High(Tvsagps_GPSState));
  p^.High_Tgpms_Code:=Ord(High(Tgpms_Code));
  p^.High_TVSAGPS_TrackType:=Ord(High(TVSAGPS_TrackType));
  p^.High_TVSAGPS_TrackParam:=Ord(High(TVSAGPS_TrackParam));
  p^.High_TVSAGPS_GPX_Extension:=Ord(High(TVSAGPS_GPX_Extension));

  // types
  p^.Sizeof_Pointer:=sizeof(Pointer);
  p^.Sizeof_TCOMAutodetectOptions:=sizeof(TCOMAutodetectOptions);
  p^.Sizeof_D800_Pvt_Data_Type:=sizeof(D800_Pvt_Data_Type);
  p^.Sizeof_cpo_all_sat_data:=sizeof(cpo_all_sat_data);
  p^.Sizeof_TNMEA_GGA:=sizeof(TNMEA_GGA);
  p^.Sizeof_TNMEA_GLL:=sizeof(TNMEA_GLL);
  p^.Sizeof_TNMEA_GSA:=sizeof(TNMEA_GSA);
  p^.Sizeof_TNMEA_GSV:=sizeof(TNMEA_GSV);
  p^.Sizeof_TNMEA_RMC:=sizeof(TNMEA_RMC);
{$if defined(USE_NMEA_VTG)}
  p^.Sizeof_TNMEA_VTG:=sizeof(TNMEA_VTG);
{$else}
  p^.Sizeof_TNMEA_VTG:=0;
{$ifend}
  p^.Sizeof_TVSAGPS_FIX_SATS:=sizeof(TVSAGPS_FIX_SATS);
  p^.Sizeof_TVSAGPS_FIX_ALL:=sizeof(TVSAGPS_FIX_ALL);
  p^.Sizeof_TVSAGPS_ALL_DEVICE_PARAMS:=sizeof(TVSAGPS_ALL_DEVICE_PARAMS);
  p^.Sizeof_TVSAGPS_SINGLE_DEVICE_PARAMS:=sizeof(TVSAGPS_SINGLE_DEVICE_PARAMS);
  p^.Sizeof_TSingleGPSData:=sizeof(TSingleGPSData);
  p^.Sizeof_TVSAGPS_GPX_WRITER_PARAMS:=sizeof(TVSAGPS_GPX_WRITER_PARAMS);
  p^.Sizeof_TVSAGPS_LOG_WRITER_PARAMS:=sizeof(TVSAGPS_LOG_WRITER_PARAMS);
  p^.Sizeof_TVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS:=sizeof(TVSAGPS_LOGGER_GETVALUES_CALLBACK_PARAMS);
  p^.Sizeof_TVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER:=sizeof(TVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER);
  p^.Sizeof_Tvsagps_AddTrackPoint:=sizeof(Tvsagps_AddTrackPoint);
  p^.Sizeof_TSingleTrackPointData:=sizeof(TSingleTrackPointData);

  // generic types
  p^.Sizeof_TGeneric_Trk_Point_Type:=sizeof(TGeneric_Trk_Point_Type);
  p^.Sizeof_TGeneric_Trk_Hdr_Type:=sizeof(TGeneric_Trk_Hdr_Type);
  p^.Sizeof_TGeneric_Wpt_Type:=sizeof(TGeneric_Wpt_Type);
  p^.Sizeof_TGeneric_Rte_Hdr_Type:=sizeof(TGeneric_Rte_Hdr_Type);
  p^.Sizeof_TGeneric_Almanac_Type:=sizeof(TGeneric_Almanac_Type);

end;

end.
