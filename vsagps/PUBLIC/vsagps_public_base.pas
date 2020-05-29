(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_base;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils;

type
  Float32 = Single;
  PFloat32 =^Float32;
  Float64 = Double;
  SInt8 = ShortInt;
  PSInt8 = ^SInt8;
  SInt16 = SmallInt;
  PSInt16 = ^SInt16;
  SInt32 = LongInt;
  UInt8  = Byte;
  UInt16 = Word;
  UInt32 = DWORD;
  PCWSTR = PWideChar;
  PCSZ = PAnsiChar;
  LPBYTE = PByte;
  PLongBool = ^LongBool;
  TVSAGPS_HANDLE = Pointer;

  // The time_type is used in some data structures to indicate an absolute time.
  // It is an unsigned 32 bit integer and its value is the number of seconds
  // since 12:00 am December 31, 1989 UTC.
  time_type = DWORD;

  IO_STATUS_BLOCK=record
    Status: DWORD;
    Information: ULONG;
  end;
  PIO_STATUS_BLOCK=^IO_STATUS_BLOCK;

const
  cGps_Float32_no_data = 1E25;
  cGps_Float32_bound   = 1E24;

  cGPS_Invalid_SatNumber = -1;

  // talker identifiers (always in uppercase!)
  nmea_ti_CC          = 'CC'; // for COMPUTER
  nmea_ti_GPS         = 'GP'; // for US NavStar GPS
  nmea_ti_GLONASS     = 'GL'; // for Russian GLONASS
  nmea_ti_QZSS        = 'QZ'; // for Japanese QZSS
  nmea_ti_GNSS        = 'GN'; // MIXED: GPS + GLONASS ( + QZSS) simultaneously
  nmea_ti_MagComp     = 'HC'; // Heading – Magnetic Compass
  nmea_ti_EchoSounder = 'SD'; // for Echo Sounder (water data)

  // glonass satellites from 65 and above
  cVSAGPS_Constellation_GLONASS_SatID = 64;
  // The SBAS system includes WAAS, EGNOS, and MTSAT satellites.
  // The SBAS system PRN numbers are 120-138
  // 120-138 should be unmapped
  // 33-64 should be unmapped to 1-32  // SBAS (Satellite Based Augmentation System) satellites
  // for GLONASS 65-96

  cNmea_knot_to_kmph = 1.852;
  cNmea_min_fix_sat_count=12;
  cNmea_max_sat_count=32;

  cNmea_Autonomous_Mode     = 1;
  cNmea_DGPS_SPS_Mode       = 2;
  cNmea_PPS_Mode            = 3;
  cNmea_Dead_Reckoning_Mode = 6;
(*
0 = invalid
1 = GPS fix (SPS)
2 = DGPS fix
3 = PPS fix
4 = Real Time Kinematic
5 = Float RTK
6 = estimated (dead reckoning) (2.3 feature)
7 = Manual input mode
8 = Simulation mode
*)

  cGarmin_Flag_HasEphemeris = 1; // binary 001
  cGarmin_Flag_Differential = 2; // binary 010
  cGarmin_Flag_InSolution   = 4; // binary 100
  cGarmin_Flag_Fixed_Mask   = (cGarmin_Flag_InSolution or cGarmin_Flag_HasEphemeris); // binary 101
  cGarmin_Flag_Mask         = 7; // binary 111

  cSat_Status_Unavailable = 0;
  cSat_Status_Visible     = 1;
  cSat_Status_Fixed       = 2;

  cUnitIndex_Reserved = 0; // use if no unit index
  
  cNmea_NT_COM_Prefix = '\\.\';

  cWorkingThread_MaxDelay_Msec  = (512+256+128);

  // constants for ExecuteGPSCommand (LongInt)
  gpsc_Reset_DGPS          = $00000001; // from DGPS panel
  gpsc_Apply_UTCDateTime   = $00000002; // apply time from gps to system
  gpsc_Refresh_GPSUnitInfo = $00000004; // recreate unit info
  gpsc_Set_DCB_Str_Info_A  = $00000008; // set DCB info for comm (ansi only)
  gpsc_LocalTimeChanged    = $00001001; // Notify GPS that Local time is changed
  gpsc_RestartTrackLogs    = $00001002; // Close current and open new files for all recording tracks
  gpsc_WriteFileLinkToLog  = $00001004; // Write specified filename to tracklog
  gpsc_CreateStandaloneWpt = $00001008; // Create gpx waypoint as single file (not in track)
  gpsc_User_Base_Number    = $10000000; // user commands starts from this value - always send to device level

  // working thread finish reasons
  wtfr_No_Device_Name        = $00000001;
  wtfr_Abort_By_Device       = $00000002;
  wtfr_Communication_Failure = $00000004;
  wtfr_EOF                   = $00000008; // used for fly-on-track mode

  // for SendPacket routines
  gspf_FullPacket  = $00000001; // if not set - only data in packet (so driver object makes full packet)

  // results for LowLevel and other handlers
  //gdwhr_OK             = $00000000;
  //gdwhr_DisconnectALL  = $00000001;
  //gdwhr_DisconnectUnit = $00000002;

  // dwUnitIndex - bit mask, high word is reserved (from 0 to 15 - units' bits, 0th unit = 1)
  cMaskUnitIndex_ALL = $FFFF;
  cUnitIndex_ALL = Byte(-1);
  cUnitIndex_Max = $F;

  cVSAGPS_TimeStampFileNameFormat = 'yyyy.mm.dd_hh-nn-ss';

type
  TNMEA_TalkerID = array [0..1] of AnsiChar;
  PNMEA_TalkerID = ^TNMEA_TalkerID;

  TVSAGPS_FIX_SAT = packed record {size=2}
    svid: SInt8; // space vehicle identification (1-32)  // "<0" means "no data"
    constellation_flag: Byte; // constellation mapping index - reserved
  end;
  PVSAGPS_FIX_SAT = ^TVSAGPS_FIX_SAT;

  TVSAGPS_FIX_SATS = packed record
    fix_count: Byte; // just hint (fixed <= this value)
    all_count: Byte; // actual count of valid records in sats
    sats: packed array [0..cNmea_max_sat_count-1] of TVSAGPS_FIX_SAT; // cNmea_max_fix_count
  end;
  PVSAGPS_FIX_SATS = ^TVSAGPS_FIX_SATS;

  TVSAGPS_FIX_ALL = packed record
    gp: TVSAGPS_FIX_SATS; // gps
    gl: TVSAGPS_FIX_SATS; // glonass
  end;
  PVSAGPS_FIX_ALL = ^TVSAGPS_FIX_ALL;

  TSingleSatFixibilityData = packed record {size=6}
    sat_info: TVSAGPS_FIX_SAT; // sat number info
    snr: SInt16; // signal-to-noise ratio (0-100)
    status: Byte; // 0-2 - see cSat_Status_* constants
    flags: Byte; // original satellite flags for garmin and 0 for nmea
  end;
  PSingleSatFixibilityData = ^TSingleSatFixibilityData;

  TSingleSatSkyData = packed record {size=4}
    elevation: SInt16;
    azimuth: SInt16;
  end;
  PSingleSatSkyData = ^TSingleSatSkyData;

  Tvsagps_GPSState = (gs_DoneDisconnected,
                      gs_PendingConnecting,
                      gs_ProcessConnecting,
                      gs_DoneConnected,
                      gs_PendingDisconnecting,
                      gs_ProcessDisconnecting);
  Pvsagps_GPSState = ^Tvsagps_GPSState;
  Tvsagps_GPSStates = set of Tvsagps_GPSState;

  TCOMAutodetectOptions = packed record
    CheckSerial: WordBool;
    CheckVirtual: WordBool;
    CheckBthModem: WordBool;
    CheckUSBSer: WordBool;
    CheckOthers: WordBool;
  end;
  PCOMAutodetectOptions = ^TCOMAutodetectOptions;

const
  // all
  cCOM_src_All       = $00000000;
  // others
  cCOM_src_Others    = $00000001;
  // common
  cCOM_src_Serial    = $00000002;
  cCOM_src_BthModem  = $00000004;
  cCOM_src_VCom      = $00000008;
  cCOM_src_USBSer    = $00000010;
  // special (see bellow)
  //cCOM_src_Winachsf  = $00010000;
  //cCOM_src_QCUSB_COM = $00020000;    

// check if no data in field
function NoData_Float32(const AValue: Float32): Boolean;
function NoData_Float64(const AValue: Float64): Boolean;

// sat to be shown
function SatAvailableForShow(const ASatelliteID: SInt8;
                             const ASignalToNoiseRatio: SInt16;
                             const AStatus: Byte): Boolean;

// search sat_id in list of fixed sats
function GetSatNumberIndexEx(p: PVSAGPS_FIX_SATS; const pSatInfo: PVSAGPS_FIX_SAT; var result_index: ShortInt): Boolean;

// get talker_id for GNxxx
function Get_TalkerID_By_SatList(p: PVSAGPS_FIX_SATS): AnsiString;

// for functions calls
function Make_TVSAGPS_FIX_SAT(const ASatelliteID: SInt8; const AConstellationFlag: Byte): TVSAGPS_FIX_SAT;
function Prep_TVSAGPS_FIX_SAT(const ASatIDFromDevice: Integer): TVSAGPS_FIX_SAT;

// ansistring to talker_id
procedure Parse_NMEA_TalkerID(const ATalkerID: AnsiString; p: PNMEA_TalkerID);

// talker_id to ansistring
function NMEA_TalkerID_to_String(const p: PNMEA_TalkerID): AnsiString;

// get ptr to working data (depends on talker_id)
function Select_PVSAGPS_FIX_SATS_from_ALL(const p: PVSAGPS_FIX_ALL; const ATalkerID: AnsiString): PVSAGPS_FIX_SATS;

// get count of fixed sats
function Get_PVSAGPS_FIX_SATS_FixCount(const p: PVSAGPS_FIX_SATS): Byte;
function Get_PVSAGPS_FIX_ALL_FixCount(const p: PVSAGPS_FIX_ALL; const bMaxInsteadofSum: Boolean): Byte;

// encode and decode flags to booleans
procedure DecodeCOMDeviceFlags(const AFlags: DWORD; AOptions: PCOMAutodetectOptions);
procedure EncodeCOMDeviceFlags(const AOptions: PCOMAutodetectOptions; out AFlags: DWORD);

// returns number of com port by name (3 for 'COM3')
function GetCOMPortNumber(const ACOMPortName: string): SmallInt;

function GPSStateChangeCorrectly(const old_state, new_state: Tvsagps_GPSState): Boolean;

function DateTime_To_ISO8601(const ADateTime: TDateTime; const AWithMilliseconds: Boolean): string;
function DateTime_To_ISO8601A(const ADateTime: TDateTime; const AWithMilliseconds: Boolean): AnsiString;

function VSAGPS_TimeStampFileNameFormat_FromNow(const bWithMSec: Boolean): string;

implementation

uses
  vsagps_public_sysutils;

function NoData_Float32(const AValue: Float32): Boolean;
begin
  Result:=(AValue > cGps_Float32_bound) or (AValue < -cGps_Float32_bound);
end;

function NoData_Float64(const AValue: Float64): Boolean;
begin
  Result:=(AValue > cGps_Float32_bound) or (AValue < -cGps_Float32_bound);
end;

function SatAvailableForShow(const ASatelliteID: SInt8;
                             const ASignalToNoiseRatio: SInt16;
                             const AStatus: Byte): Boolean;
begin
  Result := ((ASatelliteID>0) or (ASignalToNoiseRatio>0) or (AStatus>0));
end;

function GetSatNumberIndexEx(p: PVSAGPS_FIX_SATS; const pSatInfo: PVSAGPS_FIX_SAT; var result_index: ShortInt): Boolean;
var i: Byte;
begin
  if (nil<>p) then
  for i:= 0 to p^.fix_count - 1 do
  if (pSatInfo^.svid = p^.sats[i].svid) then begin
    result_index:=i;
    Result:=TRUE;
    Exit;
  end;
  Result:=FALSE;
end;

function Get_TalkerID_By_SatList(p: PVSAGPS_FIX_SATS): AnsiString;
begin
  if (nil<>p) then
  if (0<p.all_count) then begin
    // check only first sat
    if (p.sats[0].svid>cVSAGPS_Constellation_GLONASS_SatID) then
      Result := nmea_ti_GLONASS
    else
      Result := nmea_ti_GPS;
    Exit;
  end;
  Result:='';
end;

function Make_TVSAGPS_FIX_SAT(const ASatelliteID: SInt8; const AConstellationFlag: Byte): TVSAGPS_FIX_SAT;
begin
  Result.svid:=ASatelliteID;
  Result.constellation_flag:=AConstellationFlag;
end;

function Prep_TVSAGPS_FIX_SAT(const ASatIDFromDevice: Integer): TVSAGPS_FIX_SAT;
begin
  Result.svid:=SInt8(LOBYTE(ASatIDFromDevice));
  Result.constellation_flag:=0;
end;

procedure Parse_NMEA_TalkerID(const ATalkerID: AnsiString; p: PNMEA_TalkerID);
begin
  if Length(ATalkerID)>1 then begin
    p^[0]:=ATalkerID[1];
    p^[1]:=ATalkerID[2];
  end else begin
    p^[0]:=#0;
    p^[1]:=#0;
  end;
end;

function NMEA_TalkerID_to_String(const p: PNMEA_TalkerID): AnsiString;
begin
  if (#0=p^[0]) then
    Result:=''
  else
    Result:=p^[0]+p^[1];
end;

function Select_PVSAGPS_FIX_SATS_from_ALL(const p: PVSAGPS_FIX_ALL; const ATalkerID: AnsiString): PVSAGPS_FIX_SATS;
begin
  if SameTextA(ATalkerID, nmea_ti_GLONASS) then
    Result := @(p^.gl)
  else
    Result := @(p^.gp);
end;

function Get_PVSAGPS_FIX_SATS_FixCount(const p: PVSAGPS_FIX_SATS): Byte;
var i: Byte;
begin
  Result:=0;
  if (nil<>p) then
  for i := 0 to cNmea_max_sat_count-1 do begin
    if (i>=p^.fix_count) then
      break;
    if (0<p^.sats[i].svid) then
      Inc(Result);
  end;
end;

function Get_PVSAGPS_FIX_ALL_FixCount(const p: PVSAGPS_FIX_ALL; const bMaxInsteadofSum: Boolean): Byte;
var gl_count: Byte;
begin
  if (nil=p) then begin
    Result:=0;
    Exit;
  end;
  Result:=Get_PVSAGPS_FIX_SATS_FixCount(@(p^.gp));
  gl_count:=Get_PVSAGPS_FIX_SATS_FixCount(@(p^.gl));
  if bMaxInsteadofSum then begin
    // max
    if (gl_count>Result) then
      Result:=gl_count;
  end else begin
    // sum
    Result:=Result+gl_count;
  end;
end;

procedure DecodeCOMDeviceFlags(const AFlags: DWORD; AOptions: PCOMAutodetectOptions);
begin
  AOptions^.CheckSerial:=(cCOM_src_Serial = (AFlags and cCOM_src_Serial));
  AOptions^.CheckVirtual:=(cCOM_src_VCom = (AFlags and cCOM_src_VCom));
  AOptions^.CheckBthModem:=(cCOM_src_BthModem = (AFlags and cCOM_src_BthModem));
  AOptions^.CheckUSBSer:=(cCOM_src_USBSer = (AFlags and cCOM_src_USBSer));
  AOptions^.CheckOthers:=(cCOM_src_Others = (AFlags and cCOM_src_Others));
end;

procedure EncodeCOMDeviceFlags(const AOptions: PCOMAutodetectOptions; out AFlags: DWORD);
begin
  AFlags:=0; // Note 0 = cCOM_src_All !
  if AOptions^.CheckSerial then
    AFlags := (AFlags or cCOM_src_Serial);
  if AOptions^.CheckVirtual then
    AFlags := (AFlags or cCOM_src_VCom);
  if AOptions^.CheckBthModem then
    AFlags := (AFlags or cCOM_src_BthModem);
  if AOptions^.CheckUSBSer then
    AFlags := (AFlags or cCOM_src_USBSer);
  if AOptions^.CheckOthers then
    AFlags := (AFlags or cCOM_src_Others);
end;

function GetCOMPortNumber(const ACOMPortName: string): SmallInt;
var
  S: string;
  p: Integer;
begin
  S:=ACOMPortName;
  while (0<Length(S)) and (not CharInSet(S[1], ['0','1'..'9'])) do begin
    System.Delete(S,1,1);
  end;

  p:=System.Pos(' ',S);
  if (p>0) then
    SetLength(S, p-1);

  if TryStrToInt(S, p) then
    Result:=p
  else
    Result:=-1;
end;

function GPSStateChangeCorrectly(const old_state, new_state: Tvsagps_GPSState): Boolean;
begin
  case old_state of
  gs_DoneDisconnected:
    Result:=(gs_ProcessConnecting=new_state);
  gs_ProcessConnecting:
    Result:=(gs_DoneConnected=new_state);
  gs_DoneConnected:
    Result:=(gs_ProcessDisconnecting=new_state);
  gs_ProcessDisconnecting:
    Result:=(gs_DoneDisconnected=new_state);
  else
    Result:=FALSE;
  end;
end;

function DateTime_To_ISO8601(const ADateTime: TDateTime; const AWithMilliseconds: Boolean): string;
const
  ISO8601_Decimal_Separator = '.';
var
  ms: string;
begin
  // 2001-11-16T23:03:38Z
  Result:=FormatDateTime('yyyy-mm-dd',ADateTime)+'T'+FormatDateTime('hh:nn:ss',ADateTime);
  if AWithMilliseconds then begin
    // add msecs without trailing zeroes
    ms:=FormatDateTime('zzz',ADateTime);
    while (0<Length(ms)) and ('0'=ms[Length(ms)]) do
      SetLength(ms,(Length(ms)-1));
    if (0<Length(ms)) then
      Result:=Result+ISO8601_Decimal_Separator+ms;
  end;
  Result:=Result+'Z';
end;

function DateTime_To_ISO8601A(const ADateTime: TDateTime; const AWithMilliseconds: Boolean): AnsiString;
begin
  Result := AnsiString(DateTime_To_ISO8601(ADateTime, AWithMilliseconds));
end;

function VSAGPS_TimeStampFileNameFormat_FromNow(const bWithMSec: Boolean): string;
var FFormat: string;
begin
  FFormat:=cVSAGPS_TimeStampFileNameFormat;
  if bWithMSec then
    FFormat:=FFormat+'.zzz';
  Result:=FormatDateTime(FFormat, Now);
end;

end.
