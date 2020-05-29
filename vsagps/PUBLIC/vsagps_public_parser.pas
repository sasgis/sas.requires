(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_parser;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_sysutils,
  vsagps_public_classes,
  vsagps_public_tracks;

type
  TCoordLineData = packed record
    lat0: Double;
    lon1: Double;
    ele: Double;
    dt: TDateTime;
    new_seg: Boolean;
    latlon_ok: Boolean;
    ele_ok: Boolean;
    dt_ok: Boolean;
  end;
  PCoordLineData = ^TCoordLineData;

function parse_string_to_strings(const ASource: AnsiString;
                                 const ASeparator: AnsiChar;
                                 AStrings: TStringsA;
                                 const AExitAfterParsedCount: Integer=0): LongInt;

// parse single plt line
function parse_plt_line(
  const ASource: AnsiString;
  const AData: PCoordLineData;
  const AStrings: TStringsA;
  const AFormatSettings: TFormatSettings
): Boolean;

// parse single kml coordinate
function parse_kml_coordinate(const ASource: WideString;
                              const AData: PCoordLineData;
                              const AFormatSettings: TFormatSettings): Boolean;

implementation

function parse_string_to_strings(const ASource: AnsiString;
                                 const ASeparator: AnsiChar;
                                 AStrings: TStringsA;
                                 const AExitAfterParsedCount: Integer): LongInt;
var
  p: Integer;
  s: AnsiString;
begin
  AStrings.Clear;
  s:=ASource;
  repeat
    if (0=Length(s)) then
      break;
    p:=System.Pos(ASeparator,s);
    if (p>0) then begin
      // separator found - get text before and leave text after
      AStrings.Append(System.Copy(s,1,p-1));
      System.Delete(s,1,p);
    end else begin
      // no separator - take all text
      AStrings.Append(s);
      break;
    end;
    // if interested in only some parts of sentence
    if (0<AExitAfterParsedCount) then
      if (AExitAfterParsedCount<=AStrings.Count) then
        break;
  until FALSE;
  Result:=AStrings.Count;
end;

function parse_plt_line(
  const ASource: AnsiString;
  const AData: PCoordLineData;
  const AStrings: TStringsA;
  const AFormatSettings: TFormatSettings
): Boolean;
var
  s: AnsiString;
begin
  // 23.8322052,32.6251352,1,590.9684,40879.2871064815,02.12.2011,06:53:26
  //   63.732910,  54.337920,0,  588.7,39817.5987616, 04-џэт-09, 14:22:13
  //   66.229320,  44.224280,1,  549.2,40384.0767940, 25-шўы-10, 1:50:35
  Result:=FALSE;
  if (0=Length(ASource)) then
    Exit;
  ZeroMemory(AData, sizeof(AData^));

  // parse line
  parse_string_to_strings(ASource, ',', AStrings, 7);
  if (7=AStrings.Count) then begin
    // coordinates
    try
      AData^.lat0 := StrToFloatA(TrimA(AStrings[0]), AFormatSettings);
      AData^.lon1 := StrToFloatA(TrimA(AStrings[1]), AFormatSettings);
      AData^.latlon_ok := TRUE;
    except
    end;

    // new_segment - only 0 or 1
    AData^.new_seg := ('1' = TrimA(AStrings[2]));
      
    // elevation
    s := TrimA(AStrings[3]);
    if (IntToStrA(cPLT_no_Altitude) <> s) then
      AData^.ele_ok := TryStrToFloatA(s, AData^.ele, AFormatSettings);

    // datetime
    AData^.dt_ok := TryStrToFloatA(TrimA(AStrings[4]), Double(AData^.dt), AFormatSettings);

    Result := TRUE;
  end;
end;

function parse_kml_coordinate(const ASource: WideString;
                              const AData: PCoordLineData;
                              const AFormatSettings: TFormatSettings): Boolean;
var
  ws_lon, ws_lat, ws_alt: WideString;
begin
  Result:=FALSE;
  if (0=Length(ASource)) then
    Exit;
  ZeroMemory(AData, sizeof(AData^));

  // lon,lat[,alt]
  ws_alt:=ASource;
  ws_lat:='';
  ws_lon:='';

  while (Length(ws_alt)>0) and IsDelimiter(' '#9#10#13#160, ws_alt, 1) do begin
    System.Delete(ws_alt,1,1);
  end;

  // extract lon
  while (0<Length(ws_alt)) and (','<>ws_alt[1]) do begin
    ws_lon:=ws_lon+ws_alt[1];
    System.Delete(ws_alt,1,1);
  end;

  // separator
  if (0<Length(ws_alt)) and (','=ws_alt[1]) then
    System.Delete(ws_alt,1,1);

  // extract lat
  while (0<Length(ws_alt)) and (','<>ws_alt[1]) do begin
    ws_lat:=ws_lat+ws_alt[1];
    System.Delete(ws_alt,1,1);
  end;

  // separator
  if (0<Length(ws_alt)) and (','=ws_alt[1]) then
    System.Delete(ws_alt,1,1);

  // parse values

  // lon/lat
  if VSAGPS_WideString_To_Double(ws_lon, AData^.lon1, AFormatSettings) then
  if VSAGPS_WideString_To_Double(ws_lat, AData^.lat0, AFormatSettings) then begin
    AData^.latlon_ok:=TRUE;
    Result:=TRUE;
  end;

  // alt
  if (0<Length(ws_alt)) then
  if VSAGPS_WideString_To_Double(ws_alt, AData^.ele, AFormatSettings) then
    AData^.ele_ok:=TRUE;
end;

end.