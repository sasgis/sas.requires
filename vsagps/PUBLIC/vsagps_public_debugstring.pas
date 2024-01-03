(*
  VSAGPS Library. Copyright (C) 2012, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_debugstring;
(*
*)

{$I vsagps_defines.inc}

interface

{$IFDEF MSWINDOWS}
uses
  Windows,
  SysUtils;
{$ENDIF}

{$if defined(VSAGPS_USE_DEBUG_STRING)}
// ansi
procedure VSAGPS_DebugPAnsiChar(const ADebugText: PAnsiChar);
procedure VSAGPS_DebugAnsiString(const ADebugText: AnsiString);
{$ifend}

implementation

{$if defined(VSAGPS_USE_DEBUG_STRING)}
procedure VSAGPS_DebugPAnsiChar(const ADebugText: PAnsiChar);
begin
  // write 'as is' because context information provided by another call of VSAGPS_DebugAnsiString
  OutputDebugStringA(ADebugText);
end;
{$ifend}

{$if defined(VSAGPS_USE_DEBUG_STRING)}
procedure VSAGPS_DebugAnsiString(const ADebugText: AnsiString);
var VText: AnsiString;
begin
  VText := '[THR='+AnsiString(IntToStr(GetCurrentThreadId))+']'+ADebugText;
  OutputDebugStringA(PAnsiChar(VText));
end;
{$ifend}

end.