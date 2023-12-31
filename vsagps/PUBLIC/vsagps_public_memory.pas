(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_memory;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils
{$IFDEF HAS_ANSISTRINGS_UNIT}
  ,AnsiStrings
{$ENDIF}
  ;

function VSAGPS_GetMem(const dwBytes: DWORD): Pointer; stdcall;

function VSAGPS_GetMemZ(const dwBytes: DWORD): Pointer;

procedure VSAGPS_FreeMem(p: Pointer); stdcall;

procedure VSAGPS_FreeAndNil_PAnsiChar(var p: PAnsiChar);
procedure VSAGPS_FreeAndNil_PWideChar(var p: PWideChar);
procedure VSAGPS_FreeAndNil_PChar(var p: Pointer);

function VSAGPS_AllocPCharByString(const s: AnsiString; const aNILforEmpty: Boolean): PAnsiChar; overload;
function VSAGPS_AllocPCharByString(const s: WideString; const aNILforEmpty: Boolean): PWideChar; overload;

function VSAGPS_AllocPCharByPChar(const pSrc: PAnsiChar; const aNILforEmpty: Boolean): PAnsiChar; overload;
function VSAGPS_AllocPCharByPChar(const pSrc: PWideChar; const aNILforEmpty: Boolean): PWideChar; overload;

// deserialize packet from ansistring
function VSAGPS_AllocPByteByString(const s: AnsiString; const dwMinSize: DWORD): PByte;
// serialize packet to ansistring and allocate pansichar
function VSAGPS_AllocPCharByPByte(const pSrc: PByte; const dwLen: DWORD): PAnsiChar;

implementation

uses
  vsagps_public_sysutils;

function VSAGPS_GetMem(const dwBytes: DWORD): Pointer;
begin
  Result:=HeapAlloc(GetProcessHeap, HEAP_GENERATE_EXCEPTIONS, dwBytes);
end;

function VSAGPS_GetMemZ(const dwBytes: DWORD): Pointer;
begin
  Result:=HeapAlloc(GetProcessHeap, (HEAP_GENERATE_EXCEPTIONS or HEAP_ZERO_MEMORY), dwBytes);
end;

procedure VSAGPS_FreeMem(p: Pointer);
begin
  if (nil<>p) then
    HeapFree(GetProcessHeap, 0, p);
end;

procedure VSAGPS_FreeAndNil_PAnsiChar(var p: PAnsiChar);
begin
  if (nil<>p) then begin
    VSAGPS_FreeMem(p);
    p:=nil;
  end;
end;

procedure VSAGPS_FreeAndNil_PWideChar(var p: PWideChar);
begin
  if (nil<>p) then begin
    VSAGPS_FreeMem(p);
    p:=nil;
  end;
end;

procedure VSAGPS_FreeAndNil_PChar(var p: Pointer);
begin
  if (nil<>p) then begin
    VSAGPS_FreeMem(p);
    p:=nil;
  end;
end;

function VSAGPS_AllocPCharByString(const s: AnsiString; const aNILforEmpty: Boolean): PAnsiChar;
var d: Integer;
begin
  Result:=nil;
  d:=Length(s);

  if aNILforEmpty and (0=d) then
    Exit;

  Result:=VSAGPS_GetMem(d+1);
  if (0<d) then
    CopyMemory(Result, PAnsiChar(s), d);
  Result[d]:=#0;
end;

function VSAGPS_AllocPCharByString(const s: WideString; const aNILforEmpty: Boolean): PWideChar;
var d: Integer;
begin
  Result:=nil;
  d:=Length(s);

  if aNILforEmpty and (0=d) then
    Exit;

  Result:=VSAGPS_GetMem((d+1)*SizeOf(s[1]));
  if (0<d) then
    CopyMemory(Result, PWideChar(s), d*SizeOf(s[1]));
  Result[d]:=#0;
end;

function VSAGPS_AllocPCharByPChar(const pSrc: PAnsiChar; const aNILforEmpty: Boolean): PAnsiChar;
var d: Integer;
begin
  Result:=nil;

  if (nil=pSrc) then
    Exit;

  d:=StrLenA(pSrc);

  if aNILforEmpty and (0=d) then
    Exit;

  Inc(d);
  Result:=VSAGPS_GetMem(d);
  CopyMemory(Result, pSrc, d);
end;

function VSAGPS_AllocPCharByPChar(const pSrc: PWideChar; const aNILforEmpty: Boolean): PWideChar;
var d: Integer;
begin
  Result:=nil;

  if (nil=pSrc) then
    Exit;

  d:=StrLenW(pSrc);

  if aNILforEmpty and (0=d) then
    Exit;

  d := (d+1) * SizeOf(WideChar);
  Result:=VSAGPS_GetMem(d);
  CopyMemory(Result, pSrc, d);
end;

function VSAGPS_AllocPByteByString(const s: AnsiString; const dwMinSize: DWORD): PByte;
var
  v: Integer;
  cur: PByte;
  i,siz,buf_len: DWORD;
begin
  Result:=nil;
  siz := (Length(s) div 2);
  if (0<siz) and (siz * 2 = DWORD(Length(s))) then begin
    buf_len:=siz;
    if (0<dwMinSize) and (siz<dwMinSize) then
      siz:=dwMinSize;
    Result:=VSAGPS_GetMem(siz);
    try
      cur:=Result;
      for i := 0 to siz-1 do begin
        if (i<buf_len) then begin
          v:=StrToint('0x'+string(s[2*i+1]+s[2*i+2]));
          cur^:=LoByte(LoWord(v));
        end else begin
          cur^:=0;
        end;
        Inc(cur);
      end;
    except
      VSAGPS_FreeMem(Result);
      Result:=nil;
    end;
  end;
end;

function VSAGPS_AllocPCharByPByte(const pSrc: PByte; const dwLen: DWORD): PAnsiChar;
var
  i: DWORD;
  cur: PByte;
  s: AnsiString;
begin
  Result:=nil;
  if (nil<>pSrc) and (0<dwLen) then
  try
    s:='';
    cur:=pSrc;
    for i := 0 to dwLen-1 do begin
      s := s + AnsiString(IntToHex(cur^, 2));
      Inc(cur);
    end;
    s:=s+#13#10;
    Result:=VSAGPS_AllocPCharByString(s, TRUE);
  except
    VSAGPS_FreeAndNil_PAnsiChar(Result);
  end;
end;

end.