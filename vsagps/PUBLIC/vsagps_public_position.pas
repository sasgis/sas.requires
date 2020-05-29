(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_position;
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

type
  // packed params with size of Double(=Float64) for working with sensors
  TSingleDGPSData = packed record
    Nmea23_Mode: AnsiChar; // E for Dead Reckoning Mode, D for DGPS Mode, A for Autonomous P for PPS (+N+R)
    Dimentions: Byte; // 2 or 3 (if ok)
    DGPS_Station_ID: SmallInt; // from 0000 to 1023
    DGPS_Age_Second: Single;
  end;
  PSingleDGPSData = ^TSingleDGPSData;

  // packed params with size of Double(=Float64) for working with sensors
  TSingleMagneticData = packed record
    variation_degree: Single;
    variation_symbol: AnsiChar; // E or W
    rezerved1: Byte;
    rezerved2: Word;
  end;
  PSingleMagneticData = ^TSingleMagneticData;

  TSingleGPSData = packed record
    PositionLon: Double; // X
    PositionLat: Double; // Y
    Altitude: Double;
    GeoidHeight: Double;
    Speed_KMH: Double;   // in km/h
    VSpeed_MS: Double;   // in m/s
    Heading: Double;     // true
    UTCDate: TDateTime;
    UTCTime: TDateTime;
    HDOP: Double;
    VDOP: Double;
    PDOP: Double;
    DGPS: TSingleDGPSData;
    MagVar: TSingleMagneticData;
    FixStatus: Byte; // 0 - 1 - 2
    NavMode: AnsiChar; // A or V (or #0 if no data)
    PositionOK: Boolean;
    UTCDateOK: Boolean;
    UTCTimeOK: Boolean;
    VSpeedOK: Boolean;
    AllowCalcStats: Boolean; // do not update statistics in fly-on-track mode
  public
    procedure Init;
    function NotEmpty: Boolean;
    function GetKMLCoordinate(const fs: TFormatSettings): AnsiString;
  end;
  PSingleGPSData = ^TSingleGPSData;

  TSingleSatsInfoEntry = packed record
    single_fix: TSingleSatFixibilityData;
    single_sky: TSingleSatSkyData;
  end;
  PSingleSatsInfoEntry = ^TSingleSatsInfoEntry;

  TSingleSatsInfoData = packed record
    entries: packed array [0..cNmea_max_sat_count-1] of TSingleSatsInfoEntry;
  end;
  PSingleSatsInfoData = ^TSingleSatsInfoData;

  TFullSatsInfoData = packed record
    gp: TSingleSatsInfoData; // gps
    gl: TSingleSatsInfoData; // glonass
  end;
  PFullSatsInfoData = ^TFullSatsInfoData;

  TSingleTrackPointData = packed record
   gps_data: TSingleGPSData;
   gpx_sats_count: Byte;
   // aligned to 8
   full_data_size: SmallInt;
   w_reserved: Word;
  end;
  PSingleTrackPointData = ^TSingleTrackPointData;

  TFullTrackPointData = packed record
    single_item: TSingleTrackPointData;
    fix_all: TVSAGPS_FIX_ALL;
    sky_fix: TFullSatsInfoData;
  end;
  PFullTrackPointData = ^TFullTrackPointData;

  TExecuteGPSCmd_WaypointData = packed record
    sz_sasx_file_name: PAnsiChar;
    sz_cmt: PAnsiChar;
    sz_desc: PAnsiChar;
    sz_sym: PAnsiChar;
  end;
  PExecuteGPSCmd_WaypointData = ^TExecuteGPSCmd_WaypointData;

implementation

uses
  vsagps_public_sysutils,
  Math;

{ TSingleGPSData }

function TSingleGPSData.GetKMLCoordinate(const fs: TFormatSettings): AnsiString;
begin
  if Self.PositionOK then begin
    Result:=FloatToStrFixedA(Self.PositionLon, 18, 14, fs)+','+FloatToStrFixedA(Self.PositionLat, 18, 14, fs);
    // altitude
    if not NoData_Float64(Self.Altitude) then begin
      Result:=Result+','+FloatToStrFixedA(Self.Altitude, 18, 10, fs);
    end;
  end else begin
    Result:='';
  end;
end;

procedure TSingleGPSData.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

function TSingleGPSData.NotEmpty: Boolean;
var
  b: PAnsiChar;
  w: SmallInt;
begin
  b := Pointer(@Self);
  w := sizeof(Self);
  while (0<w) do
  begin
    if (#0<>b^) then
    begin
      Result := TRUE;
      Exit;
    end;
    Inc(b);
    Dec(w);
  end;
  Result := FALSE;
end;

end.
