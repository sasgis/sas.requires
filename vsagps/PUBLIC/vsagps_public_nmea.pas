(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_nmea;
(*
*)

{$I vsagps_defines.inc}

interface

const
  // sentence identifiers (always in uppercase!) - in alphabetical order
  // flags
  nmea_si_AAM = 'AAM'; // Waypoint Arrival Alarm
  nmea_si_BWC = 'BWC'; // Bearing and Distance to Waypoint – Latitude, N/S, Longitude, E/W, UTC, Status
  nmea_si_GGA = 'GGA'; // + Global Positioning System Fix Data. Time, Position and fix related data for a GPS receiver
  nmea_si_GLL = 'GLL'; // Geographic Position – Latitude/Longitude
  nmea_si_GSA = 'GSA'; // + GPS DOP and active satellites
  nmea_si_GSV = 'GSV'; // + Satellites in view
  nmea_si_MSS = 'MSS'; // MSK Receiver Signal Status
  nmea_si_RMB = 'RMB'; // Recommended Minimum Navigation Information (to point)
  nmea_si_RMC = 'RMC'; // + Recommended Minimum Navigation Information
  nmea_si_RTE = 'RTE'; // Routes
  nmea_si_VTG = 'VTG'; // Track Made Good and Ground Speed
  nmea_si_WPL = 'WPL'; // Waypoint Location
  nmea_si_XTE = 'XTE'; // Cross-Track Error – Measured
  nmea_si_ZDA = 'ZDA'; // Time & Date – UTC, Day, Month, Year and Local Time Zone

(*
$HCHDG,101.1,,,7.1,W*3C   - electronic compass (magnetic deviation and variation)
$PSLIB Differental GPS Beacon Receiver Control
************************** RoyalTek
$RTRDS
$RTTMC
************************** Motorola
$PMOTG,xxx,yyyy
*)

type
  // proprietary manufacture support flags (Add new values to the end of list!)
  Tgpms_Code = (gpms_Unknown, // Unknown proprietary
                gpms_SRF, // SIRF
                gpms_GRM, // Garmin Corporation
                gpms_MGN, // Magellan Corporation
                gpms_EMT, // Evermore
                gpms_MTK, // Martech, Inc.
                gpms_SLI, // Starlink, Inc. proprietary sentence PSLIB, used by Garmin and others
                gpms_ASH, // Ashtech (includes Thales)
                gpms_NCT, // NAVCOM
                gpms_TNL, // Trimble Navigation
                gpms_LWR, // Lowrance Electronics Corportation
                gpms_FST, // Fastrax
                gpms_UBX, // U-Blox
                gpms_CSI, // Crescent
                gpms_RWI, // Rockwell International mnemonic
                gpms_NMR, // NemeriX / Newmar
                gpms_FUG, // FUGAWI
                gpms_STI, // Sea-Temp Instrument Corporation
                gpms_DME, // Digital Marine Electronics Corp.
                gpms_LRD, // Lorad
                gpms_PRK, // Perko, Inc.
                gpms_SNY, // Sony
                gpms_MOT, // Motorola
                gpms_MVX, // Magnavox (was acquired by Leica Geosystems in 1994)
                gpms_RAY, // Raymarine Raystar
                gpms_LEI, // Leica Geosystems
                gpms_GLO, // GlobalLocate
                gpms_XEM, // Rikaline
                gpms_TSI, // Transystem Inc.
                gpms_UNV, // u-Nav
                gpms_Some // Some field(s) Defined - for internal use only
               );

const
  // sub codes for different extensions (Word)
  gpms_SRF_sub_U_Blox    = $0001; // output $PSRF161,01,63*6E<CR><LF>
  gpms_SRF_sub_GlobalSat = $0002; //

  // Leadtek
  // Siemens
  // RoyalTek

function Gpms_Code_to_String(const ACode: Tgpms_Code): AnsiString;

function String_to_Gpms_Code(const ACode: AnsiString): Tgpms_Code;
  
implementation

const
  g_gpms_Codes: array [Tgpms_Code] of AnsiString = (
  '',
  'SRF',
  'GRM',
  'MGN',
  'EMT',
  'MTK',
  'SLI',
  'ASH',
  'NCT',
  'TNL',
  'LWR',
  'FST',
  'UBX',
  'CSI',
  'RWI',
  'NMR',
  'FUG',
  'STI',
  'DME',
  'LRD',
  'PRK',
  'SNY',
  'MOT',
  'MVX',
  'RAY',
  'LEI',
  'GLO',
  'XEM',
  'TSI',
  'UNV',
  ''
  );

function Gpms_Code_to_String(const ACode: Tgpms_Code): AnsiString;
begin
  Result := g_gpms_Codes[ACode];
end;

function String_To_Gpms_Code(const ACode: AnsiString): Tgpms_Code;
begin
  Result := gpms_Some;
  repeat
    Dec(Result);
    if (gpms_Unknown = Result) then
      Exit;
    if (ACode = g_gpms_Codes[Result]) then
      Exit;
  until FALSE;
end;

end.
