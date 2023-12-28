(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_parser_nmea;
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
  vsagps_public_classes,
  vsagps_public_sysutils,
  vsagps_public_nmea,
  vsagps_public_parser,
  vsagps_public_device;

const
  cNmea_Starter     = '$';
  cNmea_Query       = 'Q';
  cNmea_Proprietary = 'P';
  cNmea_Separator   = ',';
  cNmea_Point       = '.';
  cNmea_Finisher    = '*';
  cNmea_Tail        = AnsiString(#13#10);

  cNmea_SentenceLenMax = 82; // Messages have a maximum length of 82 characters,
                             // including the $ or ! starting character and the ending <LF>

type
  TNmeaParserProc = function (const AData, ASubCommand: AnsiString): DWORD of object;

  TNmeaProprietary = record
    ParserProc: TNmeaParserProc;
    SubCode: Word;
    Supported: Boolean;
  end;
  PNmeaProprietary = ^TNmeaProprietary;

  TOnECHOSOUNDERProc = function (const p: PVSAGPS_ECHOSOUNDER_DATA): DWORD of object;
  TOnGGAProc = function (const p: PNMEA_GGA): DWORD of object;
  TOnGLLProc = function (const p: PNMEA_GLL): DWORD of object;
  TOnGSAProc = function (const p: PNMEA_GSA): DWORD of object;
  TOnGSVProc = function (const p: PNMEA_GSV): DWORD of object;
  TOnRMCProc = function (const p: PNMEA_RMC): DWORD of object;
{$if defined(USE_NMEA_VTG)}
  TOnVTGProc = function (const p: PNMEA_VTG): DWORD of object;
{$ifend}

  TOnApplyUTCDateTimeProc = procedure (const ADate: PNMEA_Date; const ATime: PNMEA_Time) of object;

  TStringListNmea = class(TStringListA)
  private
    FFormatSettings: TFormatSettings;
  private
    procedure InitFormatSettings;
  protected
    procedure Parse_NMEA_Float32(const AIndex: Byte; const AFloat32: PFloat32);
  public
    function Get_NMEAPart_By_Index(const AIndex: Byte): AnsiString;
  end;

  Tvsagps_echo_sounder_holder = class(TStringListNmea)
  private
    FECHOSOUNDER_DATA: TVSAGPS_ECHOSOUNDER_DATA;
  public
    constructor Create;
  end;

  Tvsagps_parser_nmea = class(TStringListNmea)
  public
    FOnApplyUTCDateTime: TOnApplyUTCDateTimeProc;
    FGSVNmeaCounterGP: Byte;
    FGSVNmeaCounterGL: Byte;
    FGSVNmeaPrevGSVGP: Byte;
    FGSVNmeaPrevGSVGL: Byte;
    // counter
    FGNGSANmeaCounter: Byte;

    FOnECHOSOUNDER: TOnECHOSOUNDERProc;
    FOnGGA: TOnGGAProc;
    FOnGLL: TOnGLLProc;
    FOnGSA: TOnGSAProc;
    FOnGSV: TOnGSVProc;
    FOnRMC: TOnRMCProc;
{$if defined(USE_NMEA_VTG)}
    FOnVTG: TOnVTGProc;
{$ifend}

    FEchoSounderHolder: Tvsagps_echo_sounder_holder;
    FProprietaries: array [Tgpms_Code] of TNmeaProprietary;
  protected
    function Internal_Parse_NmeaComm_Base_Sentence(
      const ANmeaBaseString: AnsiString;
      const AProprietaryWithoutFinisher: Boolean
    ): DWORD;
    function Internal_Parse_NmeaComm_Talker_Sentence(const ATalkerID, ACommandID, AData: AnsiString): DWORD;
    function Internal_Parse_NmeaComm_Proprietary_Sentence(const ACommandID, AData: AnsiString): DWORD;
    function Internal_Parse_NmeaComm_EchoSounder_Sentence(const ACmdId: TNMEA_SD_CMD_ID; const AData: AnsiString): DWORD;
    function IsEchoSounderCommand(const ACommand: AnsiString; out AEchoSounderCmdId: TNMEA_SD_CMD_ID): Boolean;
  protected
    // helper routines
    procedure Parse_NMEA_Char(const AIndex: Byte; const AChar: PAnsiChar);
    procedure Parse_NMEA_Coord(const AIndexCoord, AIndexSymbol: Byte; const ACoord: PNMEA_Coord);
    procedure Parse_NMEA_Date(const AIndex: Byte; const ADate: PNMEA_Date);
    procedure Parse_NMEA_GSV_INFO(const AIndex: Byte; const AGSV_INFO: PNMEA_GSV_INFO);
    procedure Parse_NMEA_SatID(const AIndex: Byte; const APtrSatID: PVSAGPS_FIX_SAT);
    procedure Parse_NMEA_SInt16(const AIndex: Byte; const ASInt16: PSInt16);
    procedure Parse_NMEA_SInt8(const AIndex: Byte; const ASInt8: PSInt8);
    procedure Parse_NMEA_Time(const AIndex: Byte; const ATime: PNMEA_Time);
    // supported talker sentences
    function Parse_and_Send_GGA_Data(const AData, ATalkerID: AnsiString): DWORD;
    function Parse_and_Send_GLL_Data(const AData, ATalkerID: AnsiString): DWORD;
    function Parse_and_Send_GSA_Data(const AData, ATalkerID: AnsiString): DWORD;
    function Parse_and_Send_GSV_Data(const AData, ATalkerID: AnsiString): DWORD;
    function Parse_and_Send_RMC_Data(const AData, ATalkerID: AnsiString): DWORD;
    function Parse_and_Send_VTG_Data(const AData, ATalkerID: AnsiString): DWORD;
  public
    constructor Create;
    destructor Destroy; override;

    function Parse_Sentence_Without_Starter(const ANmeaFullStringWithoutStarter: AnsiString): DWORD;
    // initialize special counters
    procedure InitSpecialNmeaCounters;
    // enable subcode
    procedure Enable_Proprietaries_SubCode(const ACode: Tgpms_Code; const ASubCode: Word);
    // check subcode enabled
    function Proprietaries_SubCode_Enabled(const ACode: Tgpms_Code; const ASubCode: Word): Boolean;
    function SomeProprietariesSupported: Boolean;
  end;

// calc checksum
function CalcNmeaChecksum(const ANmeaBaseString: AnsiString): Byte;

// calc checksum and add $ and the tail
function MakeNmeaFullString(const ANmeaBaseString: AnsiString): AnsiString;

// create nmea query sentence
function MakeNmeaBaseQuerySentence(
  const ANmeaTalkerIdSrc, ANmeaTalkerIdDst: AnsiString;
  const ANmeaSentenceId: AnsiString
): AnsiString;

// extract nmea data and check checksum (if exists)
function ExtractNmeaBaseString(const ANmeaFullString: AnsiString;
                               const ACheckNmeaStarter: Boolean;
                               var ANmeaBaseString: AnsiString;
                               var AChecksumFound: Boolean;
                               var AChecksumMatched: Boolean;
                               var AProprietaryWithoutFinisher: Boolean): Boolean;

// parse nmea string coordinates (without symbol)
procedure NMEA_Parse_Coord(const ACoordValue: AnsiString; const ACoord: PNMEA_Coord; const fs: TFormatSettings);

implementation

uses
  vsagps_public_print,
  vsagps_public_debugstring;

function CalcNmeaChecksum(const ANmeaBaseString: AnsiString): Byte;
var i: DWORD;
begin
  Result:=0;
  if (0<=Length(ANmeaBaseString)) then
  for i:=1 to Length(ANmeaBaseString) do
  Result:=(Result xor Ord(ANmeaBaseString[i]));
end;

function MakeNmeaFullString(const ANmeaBaseString: AnsiString): AnsiString;
var chksum: Byte;
begin
  chksum := CalcNmeaChecksum(ANmeaBaseString);
  Result := cNmea_Starter + ANmeaBaseString + cNmea_Finisher + IntToHexA(chksum, 2) + cNmea_Tail;
end;

function MakeNmeaBaseQuerySentence(
  const ANmeaTalkerIdSrc, ANmeaTalkerIdDst: AnsiString;
  const ANmeaSentenceId: AnsiString
): AnsiString;
begin
  Result:=ANmeaTalkerIdSrc+ANmeaTalkerIdDst+cNmea_Query+cNmea_Separator+ANmeaSentenceId;
end;

function ExtractNmeaBaseString(const ANmeaFullString: AnsiString;
                               const ACheckNmeaStarter: Boolean;
                               var ANmeaBaseString: AnsiString;
                               var AChecksumFound: Boolean;
                               var AChecksumMatched: Boolean;
                               var AProprietaryWithoutFinisher: Boolean): Boolean;
  function _NoString: Boolean;
  begin
    Result:=(0=Length(ANmeaBaseString))
  end;

  function _SameChecksums(const cs1: AnsiString; const cs2: Byte): Boolean;
  var n,m: Integer;
  begin
    if TryStrToIntA('0x'+cs1, n) then begin
      m:=cs2;
      Result:=(m=n);
    end else
      Result:=FALSE;
  end;

var
  test_str: AnsiString;
  i: Integer;
begin
  Result:=FALSE;
  AChecksumFound:=FALSE;
  AChecksumMatched:=FALSE;
  AProprietaryWithoutFinisher:=FALSE;

  ANmeaBaseString:=ANmeaFullString;
  if (_NoString) then
    Exit;

  // extract nmea starter
  if ACheckNmeaStarter then begin
    i := PosA(cNmea_Starter, ANmeaBaseString);
    if (i>1) then
      System.Delete(ANmeaBaseString,1,i-1);
    test_str:=System.Copy(ANmeaBaseString, 1, Length(cNmea_Starter));
    if (not SameTextA(test_str, cNmea_Starter)) then
      Exit;
    System.Delete(ANmeaBaseString, 1, Length(cNmea_Starter));
    if (_NoString) then
      Exit;
  end;

  // extract nmea tail
  if (0<Length(cNmea_Tail)) then
  while (0<Length(ANmeaBaseString)) do begin
    if (System.Pos(ANmeaBaseString[Length(ANmeaBaseString)], cNmea_Tail)>0) then
      SetLength(ANmeaBaseString, Length(ANmeaBaseString)-1)
    else
      break;
  end;
  if (_NoString) then
    Exit;

  // extract nmea-finisher and checksum
  i := PosA(cNmea_Finisher, ANmeaBaseString);
  if (i>0) then begin
    // nmea-finisher found - try to get checksum
    test_str:=System.Copy(ANmeaBaseString, i+Length(cNmea_Finisher), Length(ANmeaBaseString));
    // note:test_str has only checksum!
    // remove nmea-finisher and checksum - leave only "base" nmea string
    SetLength(ANmeaBaseString, i-1);
    if (_NoString) then
      Exit;
    // check finisher
    if (0=Length(test_str)) then begin
      // no checksum after nmea-finisher
      // allow for dummies
      Result:=TRUE;
    end else begin
      // checksum found
      AChecksumFound:=TRUE;
      // calc new checksum and compare values
      if _SameChecksums(test_str, CalcNmeaChecksum(ANmeaBaseString)) then begin
        // checksum ok
        AChecksumMatched:=TRUE;
        Result:=TRUE;
      end; // else checksum failed
    end;
  end else begin
    // no nmea-finisher (and of course no checksum) - allowed only for proprietary sentences
    if SameTextA(System.Copy(ANmeaBaseString, 1, Length(cNmea_Proprietary)), cNmea_Proprietary) then begin
      AProprietaryWithoutFinisher:=TRUE;
      Result:=TRUE;
    end;
  end;
end;

procedure NMEA_Parse_Coord(const ACoordValue: AnsiString; const ACoord: PNMEA_Coord; const fs: TFormatSettings);
  procedure _SetNoData;
  begin
    ACoord^.deg:=$FF;
  end;
var
  g: AnsiString;
  p: Integer;

  procedure _MinutesToFloat(const s: AnsiString);
  begin
    ACoord^.min := StrToFloatA(s, fs);
  end;
begin
  // 04321.0123
  try
    if (0=Length(ACoordValue)) then begin
      // no data
      _SetNoData;
    end else begin
      // with data
      p := PosA(cNmea_Point, ACoordValue);
      if (p>0) then begin
        // with point
        if (5<=p) then begin
          // 4 o more symbols before point - leave 2 symbols for minutes
          g:=System.Copy(ACoordValue,1,p-3);
          // g='043' s='21.0123'
          _MinutesToFloat(System.Copy(ACoordValue, Length(g)+1, Length(ACoordValue)));
          ACoord^.deg := StrToIntA(g);
        end else begin
          // error
          _SetNoData;
        end;
      end else begin
        // no point - may be only int part
        if (4<=Length(ACoordValue)) then begin
          // simple
          ACoord^.deg := StrToIntA(ACoordValue[Length(ACoordValue)-3]+ACoordValue[Length(ACoordValue)-2]);
          ACoord^.min := StrToIntA(ACoordValue[Length(ACoordValue)-1]+ACoordValue[Length(ACoordValue)]);
        end else begin
          // error
          _SetNoData;
        end;
      end;
    end;
  except
    _SetNoData;
  end;
end;

{ Tvsagps_parser_nmea }

constructor Tvsagps_parser_nmea.Create;
begin
  InitSpecialNmeaCounters;

  FEchoSounderHolder:=nil;
  FOnApplyUTCDateTime:=nil;
  FOnECHOSOUNDER:=nil;
  FOnGGA:=nil;
  FOnGLL:=nil;
  FOnGSA:=nil;
  FOnGSV:=nil;
  FOnRMC:=nil;
{$if defined(USE_NMEA_VTG)}
  FOnVTG:=nil;
{$ifend}  

  InitFormatSettings;
end;

destructor Tvsagps_parser_nmea.Destroy;
begin
  FreeAndNil(FEchoSounderHolder);
  inherited;
end;

procedure Tvsagps_parser_nmea.Enable_Proprietaries_SubCode(const ACode: Tgpms_Code; const ASubCode: Word);
begin
  FProprietaries[ACode].SubCode := (FProprietaries[ACode].SubCode or ASubCode);
end;

procedure Tvsagps_parser_nmea.InitSpecialNmeaCounters;
begin
  FGSVNmeaCounterGP:=0;
  FGSVNmeaCounterGL:=0;
  FGSVNmeaPrevGSVGP:=0;
  FGSVNmeaPrevGSVGL:=0;
  FGNGSANmeaCounter:=0;
end;

function Tvsagps_parser_nmea.Internal_Parse_NmeaComm_Base_Sentence(
  const ANmeaBaseString: AnsiString;
  const AProprietaryWithoutFinisher: Boolean
): DWORD;
var
  pComma: Integer;
  VEchoSounderCmdId: TNMEA_SD_CMD_ID;
  Vcommand, Vdata: AnsiString;
  Vtalkerid: AnsiString;
begin
  pComma := PosA(cNmea_Separator, ANmeaBaseString);
  if (pComma>0) then begin
    // extract command
    Vcommand:=System.Copy(ANmeaBaseString, 1, pComma-1);
    Vdata:=System.Copy(ANmeaBaseString, pComma+1, Length(ANmeaBaseString));

    // check command type
    if (0<Length(Vcommand)) then begin
      // command exists
      if (cNmea_Proprietary=Vcommand[1]) then begin
        // nmea proprietary sentence
        System.Delete(Vcommand, 1, 1); // delete starting 'P'
        Result:=Internal_Parse_NmeaComm_Proprietary_Sentence(Vcommand, Vdata);
      end else if (cNmea_Query=Vcommand[Length(Vcommand)]) then begin
        // nmea query sentence
        Result := 0;
      end else if IsEchoSounderCommand(Vcommand, VEchoSounderCmdId) then begin
        // echo sounder sentence (SD)
        Result:=Internal_Parse_NmeaComm_EchoSounder_Sentence(VEchoSounderCmdId, Vdata)
      end else if (4<Length(Vcommand)) then begin
        // nmea talker sentence
        Vtalkerid:=System.Copy(Vcommand,1,2); // usually 'GP'
        System.Delete(Vcommand,1,2);
        Result:=Internal_Parse_NmeaComm_Talker_Sentence(Vtalkerid, Vcommand, Vdata);
      end else begin
        // invalid nmea talker sentence
        Result := 0;
      end;
    end else begin
      // no command
      Result := 0;
    end;
  end else begin
    // no comma
    Result := 0;
  end;
end;

function Tvsagps_parser_nmea.Internal_Parse_NmeaComm_EchoSounder_Sentence(const ACmdId: TNMEA_SD_CMD_ID; const AData: AnsiString): DWORD;
var
  VFloat32: Float32;
begin
  Result := 0;

  if not Assigned(FOnECHOSOUNDER) then
    Exit;

  if (nil=FEchoSounderHolder) then begin
    FEchoSounderHolder := Tvsagps_echo_sounder_holder.Create;
  end;

  // parse data to stringlist
  parse_string_to_strings(AData, cNmea_Separator, FEchoSounderHolder);

  case ACmdId of
    sdci_SDDBT: begin
      // $SDDBT,47.2,f,14.39,M,7.87,F*00
      FEchoSounderHolder.Parse_NMEA_Float32(2, @VFloat32);
      with FEchoSounderHolder.FECHOSOUNDER_DATA do begin
        depth_meters_changed := depth_meters_changed or Data.set_depth_meters(VFloat32);
      end;
    end;
    sdci_SDDPT: begin
      // $SDDPT,14.39,0.00*68
      FEchoSounderHolder.Parse_NMEA_Float32(0, @VFloat32);
      with FEchoSounderHolder.FECHOSOUNDER_DATA do begin
        depth_meters_changed := depth_meters_changed or Data.set_depth_meters(VFloat32);
      end;
    end;
    sdci_SDMTW: begin
      // $SDMTW,16.2,C*01
      FEchoSounderHolder.Parse_NMEA_Float32(0, @VFloat32);
      with FEchoSounderHolder.FECHOSOUNDER_DATA do begin
        temp_celcius_changed := temp_celcius_changed or Data.set_temp_celcius(VFloat32);
      end;
    end;
  end;

  // call handler
  with FEchoSounderHolder.FECHOSOUNDER_DATA do
  if depth_meters_changed or temp_celcius_changed then begin
    FOnECHOSOUNDER(@(FEchoSounderHolder.FECHOSOUNDER_DATA));
  end;
end;

function Tvsagps_parser_nmea.Internal_Parse_NmeaComm_Proprietary_Sentence(const ACommandID, AData: AnsiString): DWORD;
var
  VMajorCmd, VMinorCmd: AnsiString;
  Vgpms: Tgpms_Code;
begin
  Result:=0;

  // check supported proprietary commands
  VMajorCmd:=System.Copy(ACommandID, 1, 3);
  VMinorCmd:=System.Copy(ACommandID, 4, Length(ACommandID));

  // find handler and params
  Vgpms:=String_to_Gpms_Code(VMajorCmd);

  // also set "unknown"
  FProprietaries[Vgpms].Supported:=TRUE;

  // set marker that some of known proprietaries are supported
  if (gpms_Unknown<>Vgpms) and (gpms_Some<>Vgpms) then
    FProprietaries[gpms_Some].Supported:=TRUE;

  // run handler to parse sentence
  if Assigned(FProprietaries[Vgpms].ParserProc) then begin
    // parse data to stringlist
    parse_string_to_strings(AData, cNmea_Separator, Self);
    // call handler
    FProprietaries[Vgpms].ParserProc(AData, VMinorCmd);
  end;
end;

function Tvsagps_parser_nmea.Internal_Parse_NmeaComm_Talker_Sentence(const ATalkerID, ACommandID, AData: AnsiString): DWORD;
var p: TNmeaParserProc;
begin
  Result:=0;
  p:=nil;

  // check supported commands
  if (nmea_si_RMC=ACommandID) then begin
    // RMC
    if Assigned(FOnRMC) then
      p:=Parse_and_Send_RMC_Data;
  end else if (nmea_si_GSA=ACommandID) then begin
    // GSA
    if Assigned(FOnGSA) then
      p:=Parse_and_Send_GSA_Data;
  end else if (nmea_si_GGA=ACommandID) then begin
    // GGA
    if Assigned(FOnGGA) then
      p:=Parse_and_Send_GGA_Data;
  end else if (nmea_si_GLL=ACommandID) then begin
    // GLL
    if Assigned(FOnGLL) then
      p:=Parse_and_Send_GLL_Data;
  end else if (nmea_si_GSV=ACommandID) then begin
    // GSV
    if Assigned(FOnGSV) then
      p:=Parse_and_Send_GSV_Data;
{$if defined(USE_NMEA_VTG)}
  end else if (nmea_si_VTG=ACommandID) then begin
    // VTG
    if Assigned(FOnVTG) then
      p:=Parse_and_Send_VTG_Data;
{$ifend}
  end else ;

  if Assigned(p) then begin
    // parse data to stringlist
    parse_string_to_strings(AData, cNmea_Separator, Self);
    // call handler
    p(AData, ATalkerID);
  end;
end;

function Tvsagps_parser_nmea.IsEchoSounderCommand(const ACommand: AnsiString; out AEchoSounderCmdId: TNMEA_SD_CMD_ID): Boolean;
begin
  Result := FALSE;
  // check supported items only (see sdsf_* constants)
  if (Length(ACommand)=5) and (ACommand[1]='S') and (ACommand[2]='D') then begin
    if (ACommand[3]='D') and (ACommand[5]='T') then begin
      if (ACommand[4]='B') then begin
        AEchoSounderCmdId := sdci_SDDBT;
        Inc(Result);
      end else if (ACommand[4]='P') then begin
        AEchoSounderCmdId := sdci_SDDPT;
        Inc(Result);
      end;
    end else if (ACommand[3]='M') and (ACommand[4]='T') and (ACommand[5]='W') then begin
      AEchoSounderCmdId := sdci_SDMTW;
      Inc(Result);
    end;
  end;
end;

function Tvsagps_parser_nmea.Parse_and_Send_GGA_Data(const AData, ATalkerID: AnsiString): DWORD;
var h: TNMEA_GGA;
begin
  Result:=0;
  // fill data
  h.dwSize:=sizeof(h);
  Parse_NMEA_TalkerID(ATalkerID, @(h.chTalkerID));

  // 1) Time (UTC) (as 194723.000)
  Parse_NMEA_Time(0, @(h.time));

  // if ask to apply gps time to computer time
  if Assigned(FOnApplyUTCDateTime) then
    FOnApplyUTCDateTime(nil, @(h.time));

  // 2) Latitude
  // 3) N or S (North or South)
  Parse_NMEA_Coord(1, 2, @(h.lat));
  // 4) Longitude
  // 5) E or W (East or West)
  Parse_NMEA_Coord(3, 4, @(h.lon));
  // 6) GPS Quality Indicator
  Parse_NMEA_SInt8(5, @(h.quality));
  // 7) Number of satellites in view, 00 - 12
  Parse_NMEA_SInt8(6, @(h.sats_in_view));
  // 8) Horizontal Dilution of precision
  Parse_NMEA_Float32(7, @(h.hdop));
  // 9) Antenna Altitude above/below mean-sea-level (geoid)
  Parse_NMEA_Float32(8, @(h.alt_from_msl));
  // 10) Units of antenna altitude, meters
  Parse_NMEA_Char(9, @(h.alt_unit));
  // 11) Geoidal separation, the difference between the WGS-84 earth ellipsoid and mean-sea-level (geoid), "-" means mean-sea-level below ellipsoid
  Parse_NMEA_Float32(10, @(h.msl_above_ellipsoid));
  // 12) Units of geoidal separation, meters
  Parse_NMEA_Char(11, @(h.ele_unit));
  // 13) Age of differential GPS data, time in seconds since last SC104 type 1 or 9 update, null field when DGPS is not used
  Parse_NMEA_Float32(12, @(h.dgps_age_second));
  // 14) Differential reference station ID, 0000-1023
  Parse_NMEA_SInt16(13, @(h.dgps_station_id));

  // call handler
  if Assigned(FOnGGA) then
  try
    Result:=FOnGGA(@h);
  except
  end;
end;

function Tvsagps_parser_nmea.Parse_and_Send_GLL_Data(const AData, ATalkerID: AnsiString): DWORD;
var h: TNMEA_GLL;
begin
  Result:=0;
  // fill data
  h.dwSize:=sizeof(h);
  Parse_NMEA_TalkerID(ATalkerID, @(h.chTalkerID));

  // 1) Latitude
  // 2) N or S (North or South)
  Parse_NMEA_Coord(0,1,@(h.lat));
  // 3) Longitude
  // 4) E or W (East or West)
  Parse_NMEA_Coord(2,3,@(h.lon));
  // 5) Time (UTC)
  Parse_NMEA_Time(4, @(h.time));
  // 6) Status A - Data Valid, V - Data Invalid
  Parse_NMEA_Char(5, @(h.status));

  // if ask to apply gps time to computer time
  if ('A'=h.status) then
  if Assigned(FOnApplyUTCDateTime) then
    FOnApplyUTCDateTime(nil, @(h.time));

  // 7) Mode // NMEA version 2.3 (and later)
  Parse_NMEA_Char(6, @(h.nmea23_mode));

  // call handler
  if Assigned(FOnGLL) then
  try
    Result:=FOnGLL(@h);
  except
  end;
end;

function Tvsagps_parser_nmea.Parse_and_Send_GSA_Data(const AData, ATalkerID: AnsiString): DWORD;
var
  h: TNMEA_GSA;
  i,k: Byte;
begin
  Result:=0;

  // fill data
  h.dwSize:=sizeof(h);
  Parse_NMEA_TalkerID(ATalkerID, @(h.chTalkerID));

  // check talker_id for GNSS (mixed)
  if SameTextA(ATalkerID, nmea_ti_GNSS) then begin
    // GNGSA - several constellates (contig. GNGSA sent.)
    Inc(FGNGSANmeaCounter);
    // define corrected talker_id after satellites parser (see bellow)
  end else begin
    // xxGSA - single constellate
    FGNGSANmeaCounter:=0;
    // copy original talker_id
    h.chCorrectedTalkerID:=h.chTalkerID;
  end;

  // 1) Selection mode
  Parse_NMEA_Char(0, @(h.sel_mode));
  // 2) Mode
  Parse_NMEA_SInt8(1, @(h.fix_mode));
  // 3) ID of 1st satellite used for fix
  // 4) ID of 2nd satellite used for fix
  // ...
  // 14) ID of 12th satellite used for fix
  // count of sats in fix may be greater then 12
  k:=Self.Count-5;
  h.sat_fix.all_count:=k;

  if (k<cNmea_min_fix_sat_count) then
    k:=cNmea_min_fix_sat_count
  else if (k>cNmea_max_sat_count) then
    k:=cNmea_max_sat_count;
  h.sat_fix.fix_count:=k;

  for i := 0 to k-1 do begin
    // i=0 - index=2 // i=11 - index=13
    Parse_NMEA_SatID(2+i, @(h.sat_fix.sats[i]));
  end;

  // 15) PDOP in meters
  Parse_NMEA_Float32(Self.Count-3, @(h.pdop));
  // 16) HDOP in meters
  Parse_NMEA_Float32(Self.Count-2, @(h.hdop));
  // 17) VDOP in meters
  Parse_NMEA_Float32(Self.Count-1, @(h.vdop));

  // define corrected talker_id for GNGSA
  if (0<>FGNGSANmeaCounter) then begin
    // check first satellite id
    if (h.sat_fix.sats[0].svid>0) then begin
      // sat_id available
      if (h.sat_fix.sats[0].svid>cVSAGPS_Constellation_GLONASS_SatID) then
        Parse_NMEA_TalkerID(nmea_ti_GLONASS, @(h.chCorrectedTalkerID))
      else
        Parse_NMEA_TalkerID(nmea_ti_GPS, @(h.chCorrectedTalkerID));
    end else begin
      // no sat_id available - check by index (GPS, GLONASS, ...)
      if (1=FGNGSANmeaCounter) then
        Parse_NMEA_TalkerID(nmea_ti_GPS, @(h.chCorrectedTalkerID))
      else if (2=FGNGSANmeaCounter) then
        Parse_NMEA_TalkerID(nmea_ti_GLONASS, @(h.chCorrectedTalkerID))
      else
        Parse_NMEA_TalkerID('', @(h.chCorrectedTalkerID)); // unknown!
    end;
  end;

  // call handler
  if Assigned(FOnGSA) then
  try
    Result:=FOnGSA(@h);
  except
  end;
end;

function Tvsagps_parser_nmea.Parse_and_Send_GSV_Data(const AData, ATalkerID: AnsiString): DWORD;
var
  h: TNMEA_GSV;
  i,j: Byte;
  pCounter, pPrevGSV: PByte;
begin
  Result:=0;

  h.dwSize:=sizeof(h);
  Parse_NMEA_TalkerID(ATalkerID, @(h.chTalkerID));

  if SameTextA(ATalkerID, nmea_ti_GLONASS) then begin
    pCounter:=@FGSVNmeaCounterGL;
    pPrevGSV:=@FGSVNmeaPrevGSVGL;
  end else begin
    pCounter:=@FGSVNmeaCounterGP;
    pPrevGSV:=@FGSVNmeaPrevGSVGP;
  end;

  // 1) total number of messages
  Parse_NMEA_SInt8(0, @(h.msg_total));
  // 2) message number
  Parse_NMEA_SInt8(1, @(h.msg_cur));

  // if device duplicates single line - skip this
  if (0<>pPrevGSV^) and (0<h.msg_total) and (0<h.msg_cur) then
    if (pPrevGSV^ = Byte(h.msg_cur)) then
      Exit;

  // 3) satellites in view
  Parse_NMEA_SInt8(2, @(h.sats_in_view));

  // if first sentence - reset counter
  if (1=h.msg_cur) then begin
    pCounter^:=0;
  end;

  // LOOP
  // 4) satellite number
  // 5) elevation in degrees
  // 6) azimuth in degrees to true
  // 7) SNR in dB
  // more satellite infos like 4)-7)
  i:=0;
  repeat
    j:=3+4*i; // params starting index in list: 0-3, 1-7, 2-11, 3-15, 4-19
    if (j>=Self.Count) then
      break;
    // parse info
    Parse_NMEA_GSV_INFO(j, @(h.info));
    h.global_index:=pCounter^;
    pCounter^:=pCounter^+1;
    // call handler
    if Assigned(FOnGSV) then
    try
      FOnGSV(@h);
    except
    end;
    // next
    Inc(i);
  until FALSE;

  pPrevGSV^ := h.msg_cur;
end;

function Tvsagps_parser_nmea.Parse_and_Send_RMC_Data(const AData, ATalkerID: AnsiString): DWORD;
var h: TNMEA_RMC;
begin
  Result:=0;
  h.dwSize:=sizeof(h);
  Parse_NMEA_TalkerID(ATalkerID, @(h.chTalkerID));

  // 1) Time (UTC)
  Parse_NMEA_Time(0, @(h.time));
  // 2) Status, V = Navigation receiver warning
  Parse_NMEA_Char(1, @(h.status));
  // 3) Latitude
  // 4) N or S
  Parse_NMEA_Coord(2,3,@(h.lat));
  // 5) Longitude // 0xFF - no data
  // 6) E or W // #0 no data
  Parse_NMEA_Coord(4,5,@(h.lon));
  // 7) Speed over ground, knots
  Parse_NMEA_Float32(6, @(h.speed_in_knots));
  // 8) Track made good, degrees true
  Parse_NMEA_Float32(7, @(h.course_in_degrees));
  // 9) Date, ddmmyy
  Parse_NMEA_Date(8, @(h.date));
  // 10) Magnetic Variation, degrees
  Parse_NMEA_Float32(9, @(h.magvar_deg));
  // 11) E or W
  Parse_NMEA_Char(10, @(h.magvar_sym));
  // 12) Mode for NMEA version 2.3 (and later)
  Parse_NMEA_Char(11, @(h.nmea23_mode));

  // if ask to apply gps time to computer time
  if Assigned(FOnApplyUTCDateTime) then
    FOnApplyUTCDateTime(@h.date, @h.time);

  // call handler
  if Assigned(FOnRMC) then
  try
    Result:=FOnRMC(@h);
  except
  end;
end;

function Tvsagps_parser_nmea.Parse_and_Send_VTG_Data(const AData, ATalkerID: AnsiString): DWORD;
{$if defined(USE_NMEA_VTG)}
var h: TNMEA_VTG;
{$ifend}
begin
  Result:=0;
{$if defined(USE_NMEA_VTG)}
  h.dwSize:=sizeof(h);
  Parse_NMEA_TalkerID(ATalkerID, @(h.chTalkerID));

  // 1) Track Degrees
  Parse_NMEA_Float32(0, @(h.trk_deg));
  // 2) T = True
  Parse_NMEA_Char(1, @(h.trk_sym));
  // 3) Track Degrees
  Parse_NMEA_Float32(2, @(h.mag_deg));
  // 4) M = Magnetic
  Parse_NMEA_Char(3, @(h.mag_sym));
  // 5) Speed Knots
  Parse_NMEA_Float32(4, @(h.knots_speed));
  // 6) N = Knots
  Parse_NMEA_Char(5, @(h.knots_sym));
  // 7) Speed Kilometers Per Hour
  Parse_NMEA_Float32(6, @(h.kmph_speed));
  // 8) K = Kilometres Per Hour
  Parse_NMEA_Char(7, @(h.kmph_sym));
  // 9) Mode for NMEA version 2.3 (and later)
  Parse_NMEA_Char(8, @(h.nmea23_mode));

  // call handler
  if Assigned(FOnVTG) then
  try
    Result:=FOnVTG(@h);
  except
  end;
{$ifend}
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_Char(const AIndex: Byte; const AChar: PAnsiChar);
var s: AnsiString;
begin
  s:=Get_NMEAPart_By_Index(AIndex);
  if (0<Length(s)) then
    AChar^:=s[1]
  else
    AChar^:=#0;
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_Coord(const AIndexCoord, AIndexSymbol: Byte; const ACoord: PNMEA_Coord);
begin
  // 5432.1098 or 04321.0123
  // symbol
  Parse_NMEA_Char(AIndexSymbol, @(ACoord^.sym));
  // coord
  NMEA_Parse_Coord(Get_NMEAPart_By_Index(AIndexCoord), ACoord, FFormatSettings);
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_Date(const AIndex: Byte; const ADate: PNMEA_Date);
  procedure _SetNoData;
  begin
    ADate^.day:=0;
  end;
var
  s: AnsiString;
begin
  s:=Get_NMEAPart_By_Index(AIndex);
  if (6=Length(s)) then
  try
    // ok - treat as ddmmyy
    ADate^.day   := StrToIntA(s[1]+s[2]);
    ADate^.month := StrToIntA(s[3]+s[4]);
    ADate^.year  := StrToIntA(s[5]+s[6]);
  except
    _SetNoData;
  end else begin
    // no data or error
    _SetNoData;
  end;
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_GSV_INFO(const AIndex: Byte; const AGSV_INFO: PNMEA_GSV_INFO);
begin
  // 4 = AIndex+0) satellite number
  Parse_NMEA_SatID(AIndex, @(AGSV_INFO^.sat_info));
  // 5 = AIndex+1) elevation in degrees
  Parse_NMEA_SInt16(AIndex+1, @(AGSV_INFO^.sat_ele));
  // 6 = AIndex+2) azimuth in degrees to true
  Parse_NMEA_SInt16(AIndex+2, @(AGSV_INFO^.azimuth));
  // 7 = AIndex+3) SNR in dB
  Parse_NMEA_SInt16(AIndex+3, @(AGSV_INFO^.snr));
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_SatID(const AIndex: Byte; const APtrSatID: PVSAGPS_FIX_SAT);
  procedure _SetNoData;
  begin
    APtrSatID^.svid:=-1;
    APtrSatID^.constellation_flag:=0;
  end;
var
  s: AnsiString;
begin
  s:=Get_NMEAPart_By_Index(AIndex);
  if (0<Length(s)) then
  try
    APtrSatID^ := Prep_TVSAGPS_FIX_SAT(StrToIntA(s));
  except
    _SetNoData;
  end else begin
    // no data
    _SetNoData;
  end;
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_SInt16(const AIndex: Byte; const ASInt16: PSInt16);
  procedure _SetNoData;
  begin
    ASInt16^:=-1;
  end;
var
  s: AnsiString;
begin
  s:=Get_NMEAPart_By_Index(AIndex);
  if (0<Length(s)) then
  try
    ASInt16^ := StrToIntA(s);
  except
    _SetNoData;
  end else begin
    // no data
    _SetNoData;
  end;
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_SInt8(const AIndex: Byte; const ASInt8: PSInt8);
  procedure _SetNoData;
  begin
    ASInt8^:=-1;
  end;
var
  s: AnsiString;
begin
  s:=Get_NMEAPart_By_Index(AIndex);
  if (0<Length(s)) then
  try
    ASInt8^ := StrToIntA(s);
  except
    _SetNoData;
  end else begin
    // no data
    _SetNoData;
  end;
end;

procedure Tvsagps_parser_nmea.Parse_NMEA_Time(const AIndex: Byte; const ATime: PNMEA_Time);
  procedure _SetNoData;
  begin
    //pTime^.msec:=-1;
    Dec(ATime^.msec);
  end;

var
  s: AnsiString;
  p: Integer;

  procedure _SetHHMMSS;
  begin
    ATime^.hour := StrToIntA(s[1]+s[2]);
    ATime^.min  := StrToIntA(s[3]+s[4]);
    ATime^.sec  := StrToIntA(s[5]+s[6]);
  end;
begin
  ATime^.msec:=0;
  try
    // if msec<0 - no data (=194726.000)
    s:=Get_NMEAPart_By_Index(AIndex);
    if (0=Length(s)) then begin
      // no data
      _SetNoData;
    end else begin
      // data
      p:=PosA(cNmea_Point, s);
      if (0<p) then begin
        // has point
        if (7=p) then begin
          // ok
          _SetHHMMSS;
          System.Delete(s,1,p);
          if (0<Length(s)) then begin
            // with msec
            while (Length(s)<3) do
              s:=s+'0';
            ATime^.msec := StrToIntA(s);
          end;
        end else begin
          // error
          _SetNoData;
        end;
      end else begin
        // no point
        if (6<=Length(s)) then begin
          // ok
          _SetHHMMSS;
        end else begin
          // error
          _SetNoData;
        end;
      end;
    end;
  except
    _SetNoData;
  end;
end;

function Tvsagps_parser_nmea.Parse_Sentence_Without_Starter(const ANmeaFullStringWithoutStarter: AnsiString): DWORD;
var
  VNmeaBaseString: AnsiString;
  VChecksumFound: Boolean;
  VChecksumMatched: Boolean;
  AProprietaryWithoutFinisher: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_parser_nmea.Parse_Sentence_Without_Starter: "' + ANmeaFullStringWithoutStarter + '"');
{$ifend}

  Result:=0;
  if (0=Length(ANmeaFullStringWithoutStarter)) then
    Exit;
  if ExtractNmeaBaseString(ANmeaFullStringWithoutStarter,
                           FALSE,
                           VNmeaBaseString,
                           VChecksumFound,
                           VChecksumMatched,
                           AProprietaryWithoutFinisher) then begin
    // right sentence
    Result:=Internal_Parse_NmeaComm_Base_Sentence(VNmeaBaseString, AProprietaryWithoutFinisher);
  end;
end;

function Tvsagps_parser_nmea.Proprietaries_SubCode_Enabled(const ACode: Tgpms_Code; const ASubCode: Word): Boolean;
begin
  Result := ((FProprietaries[ACode].SubCode and ASubCode) <> 0)
end;

function Tvsagps_parser_nmea.SomeProprietariesSupported: Boolean;
begin
  Result:=FProprietaries[gpms_Some].Supported;
  //Result:=FProprietaries[gpms_Unknown].Supported; // same check for supporting unknown (some others) proprietary sentences
end;

{ Tvsagps_echo_sounder_holder }

constructor Tvsagps_echo_sounder_holder.Create;
begin
  inherited Create;
  InitFormatSettings;
  FECHOSOUNDER_DATA.Init;
end;

{ TStringListNmea }

function TStringListNmea.Get_NMEAPart_By_Index(const AIndex: Byte): AnsiString;
begin
  if (AIndex>=Self.Count) then
    Result:=''
  else
    Result:=Self[AIndex];
end;

procedure TStringListNmea.InitFormatSettings;
begin
  VSAGPS_PrepareFormatSettings(FFormatSettings);
  FFormatSettings.DecimalSeparator:=cNmea_Point;
end;

procedure TStringListNmea.Parse_NMEA_Float32(const AIndex: Byte; const AFloat32: PFloat32);
  procedure _SetNoData;
  begin
    AFloat32^:=cGps_Float32_no_data;
  end;
var
  s: AnsiString;
begin
  try
    s:=Get_NMEAPart_By_Index(AIndex);
    if (0=Length(s)) then begin
      _SetNoData;
    end else begin
      // parse string
      AFloat32^ := StrToFloatA(s, FFormatSettings);
    end;
  except
    _SetNoData;
  end;
end;

end.