(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_time;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils;

// NOTE: do not use this file in vsagps.dll

function SystemTimeToLocalTime(const ASysTime: TDateTime): TDateTime;

procedure SystemTimeChanged;

implementation

var
  GLocalTimeShift: Double;

function SystemTimeToLocalTime(const ASysTime: TDateTime): TDateTime;
begin
  if (0=ASysTime) then
    Result:=0
  else
    Result:=ASysTime+GLocalTimeShift;
end;

procedure SystemTimeChanged;
var
  st, lt: TSystemTime;
begin
  GLocalTimeShift:=0;
  GetSystemTime(st);
  if SystemTimeToTzSpecificLocalTime(nil, st, lt) then
    GLocalTimeShift:=(SystemTimeToDateTime(lt)-SystemTimeToDateTime(st));
end;

end.