(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_print;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  Math,
  vsagps_public_base;

const
  // print if no data
  nodata_to_string='#';
  // how to round on print - recommended values
  round_ele = -4;
  round_hdop = -2;
  round_vdop = -2;
  round_pdop = -2;
  round_heading = -2; // "head direction" (gradus)
  round_posn = -8;
  round_vspeed = -2;
  round_hspeed = -2;
  round_dpth = -2; // depth
  round_temp = -2; // temperature
  round_dst = -2; // distance
  round_age_second = -2; // age in seconds
  round_timeshift = -4;

function Round_Float32_to_String(const f: Float32;
                                 const fs: TFormatSettings;
                                 const dec_round: ShortInt=Low(TRoundToRange)): string;
function Round_Float64_to_String(const f: Float64;
                                 const fs: TFormatSettings;
                                 const dec_round: ShortInt=Low(TRoundToRange)): string;

function Round_Float32_to_StringA(
  const f: Float32;
  const fs: TFormatSettings;
  const dec_round: ShortInt
): AnsiString;

function Round_Float64_to_StringA(
  const f: Float64;
  const fs: TFormatSettings;
  const dec_round: ShortInt
): AnsiString;


procedure VSAGPS_PrepareFormatSettings(var AFormatSettings: TFormatSettings);

implementation

procedure do_after_to_str(var str_res: string; const fs: TFormatSettings);

  function _DS(const aChr: Char): Boolean;
  begin
    Result := (
      (aChr = {$IF CompilerVersion >= 23}FormatSettings.{$ifend}DecimalSeparator)
      or
      (aChr = fs.DecimalSeparator)
    );
  end;

begin
  // del leading 0
  while (Length(str_res)>0) and (str_res[1]='0') do
    System.Delete(str_res,1,1);
  // del trailing 0
  while (Length(str_res)>0) and (str_res[Length(str_res)]='0') do
    SetLength(str_res,Length(str_res)-1);
  // del trailing period
  if (Length(str_res)>0) then
    if _DS(str_res[Length(str_res)]) then
      SetLength(str_res,Length(str_res)-1);
  // if empty or leading period - add 0
  if (Length(str_res)=0) or _DS(str_res[1]) then
    str_res:='0'+str_res;
end;

function Round_Float32_to_String(const f: Float32;
                                 const fs: TFormatSettings;
                                 const dec_round: ShortInt): string;
var j: Double;
begin
  if NoData_Float32(f) then
    Result:=nodata_to_string
  else begin
    // correct value
    if dec_round=0 then begin
      // round to int
      Result:=IntToStr(Round(SimpleRoundTo(f,0)));
    end else begin
      if (dec_round<>Low(TRoundToRange)) then
        j:=SimpleRoundTo(f,dec_round)
      else
        j:=f;
      Result:=FloatToStrF(j,ffFixed,18,8,fs);
      do_after_to_str(Result,fs);
    end;
  end;
end;

function Round_Float64_to_String(const f: Float64;
                                 const fs: TFormatSettings;
                                 const dec_round: ShortInt): string;
var j: Double;
begin
  if NoData_Float64(f) then
    Result:=nodata_to_string
  else begin
    // correct value
    if dec_round=0 then begin
      // round to int
      Result:=IntToStr(Round(SimpleRoundTo(f,0)));
    end else begin
      if (dec_round<>Low(TRoundToRange)) then
        j:=SimpleRoundTo(f,dec_round)
      else
        j:=f;
      Result:=FloatToStrF(j,ffFixed,18,10,fs);
      do_after_to_str(Result,fs);
    end;
  end;
end;

function Round_Float32_to_StringA(
  const f: Float32;
  const fs: TFormatSettings;
  const dec_round: ShortInt
): AnsiString;
begin
  Result := AnsiString(Round_Float32_to_String(f, fs, dec_round));
end;

function Round_Float64_to_StringA(
  const f: Float64;
  const fs: TFormatSettings;
  const dec_round: ShortInt
): AnsiString;
begin
  Result := AnsiString(Round_Float64_to_String(f, fs, dec_round));
end;

procedure VSAGPS_PrepareFormatSettings(var AFormatSettings: TFormatSettings);
begin
{$WARN SYMBOL_PLATFORM OFF}
{$IF CompilerVersion < 23}
  GetLocaleFormatSettings(GetThreadLocale, AFormatSettings);
{$ELSE}
  AFormatSettings := TFormatSettings.Create(GetThreadLocale);
{$IFEND}
{$WARN SYMBOL_PLATFORM ON}
  AFormatSettings.DecimalSeparator:='.';
end;

end.
