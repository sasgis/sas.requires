(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_types;
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
  // gps device type
  gdt_USB_Garmin      = $00000001; // usb device by garmin - binary protocol
  gdt_COM_NMEA0183    = $00000002; // COM port - transmitting using NMEA0183
  gdt_FILE_Track      = $00000004; // fly-on-track mode (read track from file)
  gdt_LocationAPI     = $00000008; // location sensor API

  vgpt_Allow_Stats    = $00000001; // allow calc stats with this packet
  vgpt_Auxillary      = $00000002; // auxillary packed (undocumented with same structure)

  dpdfi_SyncUnitInfo          = $00000001; // synchronize access to unit_info (required if use VSAGPS_GetUnitInfo or Tvsagps_device_base.AllocUnitInfo)
  dpdfi_UnSyncDisconnected    = $00000002; // disconnected event (WorkerThread.OnTerminate) without Synchronize
  dpdfi_ConnectingFromConnect = $00000004; // raise ProcessConnecting event from GPSConnect (not from thread)

  dpsffi_SaveToReuse  = $00000001; // load, parse and save file internally - COMPLETELY - before sending trackpoints to EXE (if not - just-in-time parse and send trackpoints)
  dpsffi_OnlyPosition = $00000002; // parse only position - for speed and low memory usage

  cWorkingThread_Connection_Timeout_Sec = 30;
  cWorkingThread_Connection_Timeout_Min = 3;
  cWorkingThread_Default_Delay_Msec = 100;
  cWorkingThread_Devices_Delay_MSec = 200;

  // sizeof TGarminUSB_Custom_Packet without Data
  GarminUSB_Custom_Packet_Base_Size = 12;
  
type
  TGarminUSB_Custom_Packet = packed record
    Packet_Type: Byte; // 0 Packet Type USB Protocol Layer = 0, Application Layer = 20
    btRezerved1: Byte; // 1-3 Reserved Must be set to 0
    wRezerved2: Word;  // Reserved Must be set to 0
    Packet_ID: Word;   // 4-5 Packet ID
    wRezerved3: Word;  // 6-7 Reserved Must be set to 0
    Data_Size: DWORD;  // 8-11 Data Size
    Data: packed array[0..3] of Byte; // 12+ Data
  end;
  PGarminUSB_Custom_Packet = ^TGarminUSB_Custom_Packet;

  radian_position_type = packed record
    lat: float64; // latitude in radians (with sign)
    lon: float64; // longitude in radians (with sign)
  end;
  Pradian_position_type = ^radian_position_type;
  
  D800_Pvt_Data_Type = packed record
    alt: float32; // altitude above WGS 84 ellipsoid (meters)
    epe: float32; // estimated position error, 2 sigma (meters)
    eph: float32; // epe, but horizontal only (meters)
    epv: float32; // epe, but vertical only (meters)
    fix: Word;    // type of position fix
    tow: float64; // time of week (seconds)
    posn: radian_position_type; // latitude and longitude (radians)
    east: float32; // velocity east (meters/second)
    north: float32; // velocity north (meters/second)
    up: float32; // velocity up (meters/second)
    msl_hght: float32; // height of WGS84 ellipsoid above MSL(meters)
    leap_scnds: SmallInt; // difference between GPS and UTC (seconds)
    wn_days: DWORD; // week number days
  end;
  PD800_Pvt_Data_Type = ^D800_Pvt_Data_Type;

(*
http://www8.garmin.com/manuals/425_TechnicalSpecification.pdf
status bit-field:
0 - The unit has ephemeris data for the specified satellite
1 - The unit has a differential correction for the specified satellite
2 - The unit is using this satellite in the solution
vsa:
4 - WAAS/EGNOS enabled (20 = 10100, 21 = 10101, 23 = 10111)
*)

const
  // D800_Pvt_Data_Type.fix
  Type1_fix_unusable = 0; // failed integrity check
  Type1_fix_invalid  = 1; // invalid or unavailable
  Type1_fix_2D       = 2; // two dimensional
  Type1_fix_3D       = 3; // three dimensional
  Type1_fix_2D_diff  = 4; // two dimensional differential
  Type1_fix_3D_diff  = 5; // three dimensional differential
(*
Older software versions in certain devices use slightly different enumerated values for fix. The list of devices and the
last version of software in which these different values are used is: Device - Last SW Version
eMap - 2.64     GPSMAP 162 - 2.62     GPSMAP 295 - 2.19     eTrex - 2.10      eTrex Summit - 2.07     StreetPilot III - 2.10
eTrex Japanese - 2.10     eTrex Venture/Mariner - 2.20      eTrex Europe - 2.03     GPS 152 - 2.01      eTrex Chinese - 2.01
eTrex Vista - 2.12      eTrex Summit Japanese - 2.01      eTrex Summit - 2.24     eTrex GolfLogix -2.49
The enumerated values for these device software versions is one more than the default:  fix_2_* = fix_1_* + 1
*)
  Type2_fix_unusable = 1; // failed integrity check
  Type2_fix_invalid = 2; // invalid or unavailable
  Type2_fix_2D = 3; // two dimensional
  Type2_fix_3D = 4; // three dimensional
  Type2_fix_2D_diff = 5; // two dimensional differential
  Type2_fix_3D_diff = 6; // three dimensional differential

const
  cpo_all_sat_data_count = 12;

  snr_to_procents_divider = 64;  // if (snr div (this_value)) > 100% - truncated to 100%

type
  cpo_sat_data = packed record
    svid: SInt8; // space vehicle identification (vsa: 01-32 or 33-64 for WAAS or 65-96 for GLONASS)
		snr: SInt16;	// signal-to-noise ratio (vsa: max >= 5090)
	  elev: Byte;	// satellite elevation in degrees
		azmth: Word;	// satellite azimuth in degrees
    status: Byte; // status bit-field (vsa: 0, 1, 5=101(2), 16=10000(2), 17=10001(2))
  end;
  Pcpo_sat_data=^cpo_sat_data;
    
  cpo_all_sat_data=record
    sv: packed array [0..cpo_all_sat_data_count-1] of cpo_sat_data;
  end;
  Pcpo_all_sat_data=^cpo_all_sat_data;

type
  // nmea ansichar = #0 means no nmea data!
  // for float32 used 1E25
  // others - see in-place info

  TNMEA_Time = packed record
    hour: Byte;
    min: Byte;
    sec: Byte;
    msec: SInt16; // if msec<0 - no nmea data
  end;
  PNMEA_Time = ^TNMEA_Time;

  TNMEA_Date = packed record
    day: Byte;  // if 0 - no nmea data
    month: Byte;
    year: Word; // as YY in NMEA sentences
  end;
  PNMEA_Date = ^TNMEA_Date;

  TNMEA_Date_Time = packed record
    date: TNMEA_Date;
    time: TNMEA_Time;
  end;
  PNMEA_Date_Time = ^TNMEA_Date_Time;

  TNMEA_Coord = packed record
    deg: Byte; // 0xFF - no data
    min: Float64;
    sym: AnsiChar; // #0 no data
  end;
  PNMEA_Coord = ^TNMEA_Coord;

  TNMEA_GGA = packed record
    dwSize: Word;
    chTalkerID: TNMEA_TalkerID;
    // 1) Time (UTC)
    time: TNMEA_Time;
    // 2) Latitude
    // 3) N or S (North or South)
    lat: TNMEA_Coord;
    // 4) Longitude
    // 5) E or W (East or West)
    lon: TNMEA_Coord;
    // 6) GPS Quality Indicator, 0 - fix not available, 1 - GPS fix, 2 - Differential GPS fix, .... // <0 no data
    quality: SInt8;
    // 7) Number of satellites in view, 00 - 12 // <0 no data
    sats_in_view: SInt8;
    // 8) Horizontal Dilution of precision
    hdop: Float32;
    // 9) Antenna Altitude above/below mean-sea-level (geoid)
    alt_from_msl: Float32;
    // 10) Units of antenna altitude, meters // #0 no data
    alt_unit: AnsiChar;
    // 11) Geoidal separation, the difference between the WGS-84 earth ellipsoid and mean-sea-level (geoid), "-" means mean-sea-level below ellipsoid
    msl_above_ellipsoid: Float32; // for GPX.geoidheight
    // 12) Units of geoidal separation, meters // #0 no data
    ele_unit: AnsiChar;
    // 13) Age of differential GPS data, time in seconds since last SC104 type 1 or 9 update, null field when DGPS is not used // <0 no data
    dgps_age_second: Float32;
    // 14) Differential reference station ID, 0000-1023 // <0 no data
    dgps_station_id: SInt16;
  end;
  PNMEA_GGA = ^TNMEA_GGA;

  TNMEA_GLL = packed record
    dwSize: Word;
    chTalkerID: TNMEA_TalkerID;
    // 1) Latitude
    // 2) N or S (North or South)
    lat: TNMEA_Coord;
    // 3) Longitude
    // 4) E or W (East or West)
    lon: TNMEA_Coord;
    // 5) Time (UTC)
    time: TNMEA_Time;
    // 6) Status A - Data Valid, V - Data Invalid
    status: AnsiChar;
    // 7) Mode A=Autonomous, D=DGPS, E=DR, N = Output Data Not Valid, R = Coarse Position // NMEA version 2.3 (and later)
    nmea23_mode: AnsiChar;
  end;
  PNMEA_GLL = ^TNMEA_GLL;

  TNMEA_GSA = packed record
    dwSize: Word;
    chTalkerID: TNMEA_TalkerID;
    chCorrectedTalkerID: TNMEA_TalkerID; // for GNSS - defined by actual sat_id or index of record if no sat_id (first for GPS, second for GLONASS)
    // 1) Selection mode // #0 no data
    sel_mode: AnsiChar; // M - Manual – Forced to operate in 2D or 3D mode, A - 2D Automatic – Allowed to automatically switch 2D/3D
    // 2) Mode // <0 no data
    fix_mode: SInt8; // 1 - Fix not available, 2 - 2D (<4 SVs used), 3 - 3D (>3 SVs used)
    // 3) ID of 1st satellite used for fix
    // 4) ID of 2nd satellite used for fix
    // ...
    // 14) ID of 12th satellite used for fix
    sat_fix: TVSAGPS_FIX_SATS;
    // 15) PDOP in meters
    pdop: Float32;
    // 16) HDOP in meters
    hdop: Float32;
    // 17) VDOP in meters
    vdop: Float32;
  end;
  PNMEA_GSA = ^TNMEA_GSA;

  TNMEA_GSV_INFO = packed record
    // 4) satellite number // <0 no data
    sat_info: TVSAGPS_FIX_SAT;
    // 5) elevation in degrees // <0 no data
    sat_ele: SInt16;
    // 6) azimuth in degrees to true // <0 no data
    azimuth: SInt16;
    // 7) SNR in dB // <0 no data
    snr: SInt16;
  end;
  PNMEA_GSV_INFO = ^TNMEA_GSV_INFO;

  TNMEA_GSV = packed record
    dwSize: Word;
    chTalkerID: TNMEA_TalkerID;
    // 1) total number of messages // <0 no data
    msg_total: SInt8;
    // 2) message number // <0 no data
    msg_cur: SInt8;
    // 3) satellites in view // <0 no data
    sats_in_view: SInt8;
    // more satellite infos like 4)-7) (handler will be called multiple times for one sentence)
    global_index: Byte; // index of sat in all GSV sentences of single talker_id
    info: TNMEA_GSV_INFO;
  end;
  PNMEA_GSV = ^TNMEA_GSV;

  TNMEA_RMC = packed record
    dwSize: Word;
    chTalkerID: TNMEA_TalkerID;
    // 1) Time (UTC)
    time: TNMEA_Time;
    // 2) Status, V = Navigation receiver warning
    status: AnsiChar; // A or V
    // 3) Latitude
    // 4) N or S
    lat: TNMEA_Coord;
    // 5) Longitude
    // 6) E or W
    lon: TNMEA_Coord;
    // 7) Speed over ground, knots
    speed_in_knots: Float32;
    // 8) Track made good, degrees true
    course_in_degrees: Float32;
    // 9) Date, ddmmyy
    date: TNMEA_Date;
    // 10) Magnetic Variation, degrees
    magvar_deg: Float32;
    // 11) E or W
    magvar_sym: AnsiChar;
    // 12) Mode - see above - NMEA version 2.3 (and later)
    nmea23_mode: AnsiChar;
  end;
  PNMEA_RMC = ^TNMEA_RMC;

{$if defined(USE_NMEA_VTG)}
  TNMEA_VTG = packed record
    dwSize: Word;
    chTalkerID: TNMEA_TalkerID;
    // 1) Track Degrees
    trk_deg: Float32;
    // 2) T = True
    trk_sym: AnsiChar;
    // 3) Track Degrees
    mag_deg: Float32;
    // 4) M = Magnetic
    mag_sym: AnsiChar;
    // 5) Speed Knots
    knots_speed: Float32;
    // 6) N = Knots
    knots_sym: AnsiChar;
    // 7) Speed Kilometers Per Hour
    kmph_speed: Float32;
    // 8) K = Kilometres Per Hour
    kmph_sym: AnsiChar;
    // 9) Mode - see above - NMEA version 2.3 (and later)
    nmea23_mode: AnsiChar;    
  end;
  PNMEA_VTG = ^TNMEA_VTG;
{$ifend}

  // for echo sounder (SD) sentences

  // echo sounder sentences enum
  TNMEA_SD_CMD_ID = (
    sdci_SDDBT,
    sdci_SDDPT,
    sdci_SDMTW
  );

  // SDVHW // Heading
  // SDVLW // Distance
  // SDWPL // Waypoint

  TNMEA_SDDBT = packed record
    // Depth Below Transducer
    depth_feet_val: Float32;
    depth_feet_sym: AnsiChar;
    depth_meters_val: Float32;
    depth_meters_sym: AnsiChar;
    depth_fathoms_val: Float32;
    depth_fathoms_sym: AnsiChar;
  end;
  PNMEA_SDDBT = ^TNMEA_SDDBT;

  TNMEA_SDDPT = packed record
    // Depth, in meters (+Offset from transducer)
    depth_meters: Float32;
    trans_offset: Float32;
  end;
  PNMEA_SDDPT = ^TNMEA_SDDPT;

  TNMEA_SDMTW = packed record
    // Water Temperature, in degrees Celcius
    water_temp_val: Float32;
    water_temp_sym: AnsiChar;
  end;
  PNMEA_SDMTW = ^TNMEA_SDMTW;

  (*
  TSingleEchoSounderField = packed record {size=6}
    sd_val: Single;
    sd_sym: AnsiChar;
    chnged: Boolean;
  end;
  *)

  TSingleEchoSounderData = packed record {size=8}
    water_depth_meters: Single;
    water_temp_celcius: Single;
  public
    procedure Init;
    function assign_from(const AValue: TSingleEchoSounderData): Boolean;
    function set_depth_meters(const ANewValue: Single): Boolean;
    function set_temp_celcius(const ANewValue: Single): Boolean;
  end;
  PSingleEchoSounderData = ^TSingleEchoSounderData;  

  TVSAGPS_ECHOSOUNDER_DATA = packed record
    dwSize: Word;
    // convert 2 next bytes to flags for extra data fields
    depth_meters_changed: Boolean;
    temp_celcius_changed: Boolean;
    Data: TSingleEchoSounderData;
  public
    procedure Init;
  end;
  PVSAGPS_ECHOSOUNDER_DATA = ^TVSAGPS_ECHOSOUNDER_DATA;

  // list of null-terminated strings
  TVSAGPS_PCHAR_LIST = record
    dwCount: DWORD; // number of items
    szItems: array [0..0] of PAnsiChar; // never free this pointers!!!
  end;
  PVSAGPS_PCHAR_LIST = ^TVSAGPS_PCHAR_LIST;

function Get_UTCDateTime_From_D800(pData: PD800_Pvt_Data_Type): TDateTime;

function NMEA_Time_Valid(const ANMEA_Time: PNMEA_Time): Boolean;
function NMEA_Date_Valid(const ANMEA_Date: PNMEA_Date): Boolean;
function NMEA_Date_Time_Valid(const ANMEA_Date_Time: PNMEA_Date_Time): Boolean;

function Nmea_Coord_To_Double(const ACoord: PNMEA_Coord; var AValue: Double): Boolean;
function Nmea_Date_To_DateTime(const ANmeaDate: PNMEA_Date; var ADate: TDateTime): Boolean;
function Nmea_Time_To_DateTime(const ANmeaTime: PNMEA_Time; var ATime: TDateTime): Boolean;


function Convert_TwoDigitYear_to_FourDigitYear(const ATwoDigitYear: Word): Word;

procedure InitializeUSBGarminPacket(pPacket: PGarminUSB_Custom_Packet;
                                    const APacket_Type: Byte;
                                    const APacket_ID: Word;
                                    const AData_Size: DWORD=0);

implementation

function Get_UTCDateTime_From_D800(pData: PD800_Pvt_Data_Type): TDateTime;
begin
  Result:=32508+{since 19891231}
          365+
          pData^.wn_days+
          ((pData^.tow-pData^.leap_scnds)/24/60/60);
end;

function NMEA_Time_Valid(const ANMEA_Time: PNMEA_Time): Boolean;
begin
  Result := (ANMEA_Time<>nil) and (ANMEA_Time^.msec>=0)
end;

function NMEA_Date_Valid(const ANMEA_Date: PNMEA_Date): Boolean;
begin
  Result := (nil=ANMEA_Date) or (ANMEA_Date^.day>0) // allow without date
end;

function NMEA_Date_Time_Valid(const ANMEA_Date_Time: PNMEA_Date_Time): Boolean;
begin
  Result := NMEA_Date_Valid(@(ANMEA_Date_Time^.date)) and NMEA_Time_Valid(@(ANMEA_Date_Time^.time))
end;

function Nmea_Coord_To_Double(const ACoord: PNMEA_Coord; var AValue: Double): Boolean;
begin
  if ($FF=ACoord^.deg) then begin
    // no data
    AValue:=0;
    Result:=FALSE;
  end else begin
    // with data
    AValue:=ACoord^.deg+(ACoord^.min/60.000000);
    if (ACoord^.sym in ['W','S']) then
      AValue:=-AValue;
    Result:=TRUE;
  end;
end;

function Nmea_Date_To_DateTime(const ANmeaDate: PNMEA_Date; var ADate: TDateTime): Boolean;
var Y: Word;
begin
  if (0=ANmeaDate^.day) then begin
    // no data
    ADate:=0;
    Result:=FALSE;
  end else begin
    // with data (year is two-digit!)
    Y:=Convert_TwoDigitYear_to_FourDigitYear(ANmeaDate^.year);
    ADate:=EncodeDate(Y{ANmeaDate^.year}, ANmeaDate^.month, ANmeaDate^.day);
    Result:=TRUE;
  end;
end;

function Nmea_Time_To_DateTime(const ANmeaTime: PNMEA_Time; var ATime: TDateTime): Boolean;
begin
  if (ANmeaTime^.msec<0) then begin
    // no data
    ATime:=0;
    Result:=FALSE;
  end else begin
    // with data
    ATime:=EncodeTime(ANmeaTime^.hour, ANmeaTime^.min, ANmeaTime^.sec, ANmeaTime^.msec);
    Result:=TRUE;
  end;
end;

function Convert_TwoDigitYear_to_FourDigitYear(const ATwoDigitYear: Word): Word;
var
  VTwoDigWnd: Word;
  VCenturyBase: Integer;
begin
  // see SysUtils.ScanDate
{$IF CompilerVersion < 23}
  VTwoDigWnd := TwoDigitYearCenturyWindow;
{$ELSE}
  VTwoDigWnd := FormatSettings.TwoDigitYearCenturyWindow;
{$IFEND}
  Result:=ATwoDigitYear;
  VCenturyBase := CurrentYear - VTwoDigWnd;
  Inc(Result, VCenturyBase div 100 * 100);
  if (VTwoDigWnd > 0) and (Result < VCenturyBase) then
    Inc(Result, 100);
end;

procedure InitializeUSBGarminPacket(pPacket: PGarminUSB_Custom_Packet;
                                    const APacket_Type: Byte;
                                    const APacket_ID: Word;
                                    const AData_Size: DWORD=0);
begin
  ZeroMemory(pPacket, GarminUSB_Custom_Packet_Base_Size+AData_Size);
  pPacket^.Packet_Type := APacket_Type;
  pPacket^.Packet_ID := APacket_ID;
  pPacket^.Data_Size := AData_Size;
end;

{ TSingleEchoSounderData }

function TSingleEchoSounderData.assign_from(const AValue: TSingleEchoSounderData): Boolean;
begin
  Result := set_depth_meters(AValue.water_depth_meters) or
            set_temp_celcius(AValue.water_temp_celcius);
end;

procedure TSingleEchoSounderData.Init;
begin
  water_depth_meters := cGps_Float32_no_data;
  water_temp_celcius := cGps_Float32_no_data;
end;

function TSingleEchoSounderData.set_depth_meters(
  const ANewValue: Single): Boolean;
begin
  Result := (PLongWord(@Self.water_depth_meters)^ <> PLongWord(@ANewValue)^);
  if Result then
    PLongWord(@Self.water_depth_meters)^ := PLongWord(@ANewValue)^;
end;

function TSingleEchoSounderData.set_temp_celcius(
  const ANewValue: Single): Boolean;
begin
  Result := (PLongWord(@Self.water_temp_celcius)^ <> PLongWord(@ANewValue)^);
  if Result then
    PLongWord(@Self.water_temp_celcius)^ := PLongWord(@ANewValue)^;
end;

{ TVSAGPS_ECHOSOUNDER_DATA }

procedure TVSAGPS_ECHOSOUNDER_DATA.Init;
begin
  dwSize := SizeOf(Self);
  depth_meters_changed := FALSE;
  temp_celcius_changed := FALSE;
  Data.Init;
end;

end.


