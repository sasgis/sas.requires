(*
  VSAGPS Library. Copyright (C) 2012, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_debugstring;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
// ansi
procedure VSAGPS_DebugPAnsiChar(const ADebugText: PAnsiChar);
procedure VSAGPS_DebugAnsiString(const ADebugText: AnsiString);
{$ifend}

implementation

{$if defined(VSAGPS_DEBUG_TO_STDERR)}

var
  // the stderr handle is shared by all threads of the process
  g_Debug_CS: TRTLCriticalSection;

// write the whole buffer to the unbuffered stderr;
// returns FALSE if there is no stderr (a GUI process)
function Debug_Write_StdErr(const pText: Pointer;
                            const dwLength: DWORD): Boolean;
var
  h: THandle;
  dwWritten: DWORD;
begin
  Result:=FALSE;
  h:=GetStdHandle(STD_ERROR_HANDLE);
  if (0=h) or (INVALID_HANDLE_VALUE=h) then
    Exit;
  dwWritten:=0;
  Result:=WriteFile(h, pText^, dwLength, dwWritten, nil) and (dwWritten=dwLength);
end;

// one line (with the tail) to the unbuffered stderr;
// returns FALSE if there is no stderr (a GUI process)
function Debug_Write_StdErr_Line(const AText: AnsiString): Boolean;
const
  cTail: array [0..1] of AnsiChar = (#13, #10);
begin
  if (0=Length(AText)) then
    Result:=Debug_Write_StdErr(@cTail, sizeof(cTail))
  else
    Result:=Debug_Write_StdErr(Pointer(AText), DWORD(Length(AText))) and
            Debug_Write_StdErr(@cTail, sizeof(cTail));
end;

{$ifend}

{$if defined(VSAGPS_USE_DEBUG_STRING)}
procedure VSAGPS_DebugPAnsiChar(const ADebugText: PAnsiChar);
begin
  // write 'as is' because context information provided by another call of VSAGPS_DebugAnsiString
  {$if defined(VSAGPS_DEBUG_TO_STDERR)}
  if (not Debug_Write_StdErr_Line(PAnsiChar(ADebugText))) then
    OutputDebugStringA(ADebugText);
  {$else}
  OutputDebugStringA(ADebugText);
  {$ifend}
end;
{$ifend}

{$if defined(VSAGPS_USE_DEBUG_STRING)}
procedure VSAGPS_DebugAnsiString(const ADebugText: AnsiString);
var VText: AnsiString;
begin
  VText := '[TICK='+AnsiString(IntToStr(GetTickCount))+'][THR='+AnsiString(IntToStr(GetCurrentThreadId))+']'+ADebugText;
  {$if defined(VSAGPS_DEBUG_TO_STDERR)}
  // the unbuffered stderr keeps all the written lines even after the hard
  // process kill, and interleaves with the console runner output in a log
  if (not Debug_Write_StdErr_Line(VText)) then
    OutputDebugStringA(PAnsiChar(VText));
  {$else}
  OutputDebugStringA(PAnsiChar(VText));
  {$ifend}
end;
{$ifend}

{$if defined(VSAGPS_DEBUG_TO_STDERR)}
initialization
  InitializeCriticalSection(g_Debug_CS);
finalization
  DeleteCriticalSection(g_Debug_CS);
{$ifend}

end.