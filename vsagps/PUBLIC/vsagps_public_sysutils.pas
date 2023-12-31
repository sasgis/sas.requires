(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_sysutils;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
{$IFDEF HAS_ANSISTRINGS_UNIT}
  AnsiStrings;
{$ELSE}
  StrUtils;
{$ENDIF}

const
{$IFDEF UNICODE}
  CIsWide = True;
{$ELSE}
  CIsWide = False;
{$ENDIF}

type
  TVSAGPS_DivideStringToLinesA_Proc = procedure (
    const ALine: AnsiString;
    const AUserPtr: Pointer
  ) of object;
  TVSAGPS_DivideStringToLinesW_Proc = procedure (
    const ALine: WideString;
    const AUserPtr: Pointer
  ) of object;
  TVSAGPS_DivideStringToLinesS_Proc = procedure (
    const ALine: string;
    const AUserPtr: Pointer
  ) of object;

function SameTextA(const S1, S2: AnsiString): Boolean;

function TrimA(const S: AnsiString): AnsiString;

{$IFNDEF UNICODE}
function CharInSet(const AChar: AnsiChar; const ASet: TSysCharSet): Boolean; inline;
{$ENDIF}

procedure DelCharInSetA(var S: AnsiString; const ASet: TSysCharSet);

function IntToStrA(const AValue: Integer): AnsiString;
function IntToHexA(const Value: Integer; const Digits: Integer): AnsiString;

function PosA(const ASubStr, ABigStr: AnsiString): Integer; inline; overload;
function PosA(const ASubStr, ABigStr: AnsiString; AOffset: Integer): Integer; inline; overload;

function FloatToStrFixedA(
  const Value: Extended;
  //Format: TFloatFormat;
  const Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings
): AnsiString;

function FloatToStrA(
  const Value: Extended;
  const AFormatSettings: TFormatSettings
): AnsiString;

function DateToStrA(
  const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings
): AnsiString;

function TimeToStrA(
  const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings
): AnsiString;

function StrToFloatA(
  const S: AnsiString;
  const AFormatSettings: TFormatSettings
): Extended;

function TryStrToFloatA(
  const S: AnsiString;
  out AValue: Extended;
  const AFormatSettings: TFormatSettings
): Boolean; overload;

function TryStrToFloatA(
  const S: AnsiString;
  out AValue: Double;
  const AFormatSettings: TFormatSettings
): Boolean; overload;

function StrToIntA(const S: AnsiString): Integer;

function TryStrToIntA(const S: AnsiString; out AValue: Integer): Boolean;

function AnsiLowerCaseA(const S: AnsiString): AnsiString; deprecated;
function AnsiUpperCaseA(const S: AnsiString): AnsiString;

function AnsiStrLICompA(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer; inline;

function StringReplaceA(
  const S, OldPattern, NewPattern: AnsiString;
  Flags: TReplaceFlags
): AnsiString; deprecated;

procedure StringReplaceSingleCharA(var S: AnsiString; const AOld, ANew: AnsiChar);

function StrLenA(const Str: PAnsiChar): Cardinal; inline;
function StrLenW(Src: PWideChar): DWORD;

function VSAGPS_CreateFileW(
  const phFile: PHandle;
  const pSrcFileName: PWideChar;
  const bOpenExisting: Boolean
): Boolean;

function VSAGPS_GetFileSize(const hFile: THandle; var iSize: Int64): Boolean;

function VSAGPS_ReadFileContent(const ASrcFileName: WideString): AnsiString;

function SafeSetStringP(const ABuffer: PAnsiChar): AnsiString; overload;
function SafeSetStringP(const ABuffer: PWideChar): WideString; overload;

function SafeSetStringL(const ABuffer: PAnsiChar; const ALength: Integer): AnsiString; overload;
function SafeSetStringL(const ABuffer: PWideChar; const ALength: Integer): WideString; overload;

procedure VSAGPS_DividePCharToLines(
  const ASource: PAnsiChar;
  const AProc: TVSAGPS_DivideStringToLinesA_Proc;
  const AUserPtr: Pointer;
  const ADivOnSpacesToo: Boolean;
  const ApExitIfSet: PBoolean
); overload;

procedure VSAGPS_DividePCharToLines(
  const ASource: PWideChar;
  const AProc: TVSAGPS_DivideStringToLinesW_Proc;
  const AUserPtr: Pointer;
  const ADivOnSpacesToo: Boolean;
  const ApExitIfSet: PBoolean
); overload;

(*
procedure VSAGPS_DividePCharToLines(
  const ASource: PChar;
  const AProc: TVSAGPS_DivideStringToLinesS_Proc;
  const AUserPtr: Pointer;
  const ADivOnSpacesToo: Boolean;
  const ApExitIfSet: PBoolean
); overload; inline;
*)

function VSAGPS_WideString_To_Double(const src: WideString;
                                     var dbl: Double;
                                     const fs: TFormatSettings): Boolean;

function VSAGPS_WideString_To_Byte(const src: WideString;
                                   var v: Byte): Boolean;

function VSAGPS_WideString_to_ISO8601_Time(const src: WideString;
                                           const pdt: PDateTime): Boolean;

function ExtractBeforeSpaceDelimiter(var ASourceString: WideString): WideString;

implementation

uses
  SysConst;

function AnsiStrLICompA(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer;
begin
  Result := {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}AnsiStrLIComp(S1, S2, MaxLen);
end;

function SameTextA(const S1, S2: AnsiString): Boolean;
begin
  if Pointer(S1) = Pointer(S2) then
    Result := True
  else if Length(S1) <> Length(S2) then
    Result := False
  else if (Pointer(S1) = nil) or (Pointer(S2) = nil) then
    Result := False
  else
    Result := (0 = AnsiStrLICompA(PAnsiChar(@S1[1]), PAnsiChar(@S2[1]), Length(S1)));
end;

function IsTrimmableA(const ALetter: AnsiChar): Boolean;
begin
  Result := (ALetter <= #32) or (ALetter = #160);
end;

function TrimA(const S: AnsiString): AnsiString;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;

  if (L > 0) and (not IsTrimmableA(S[I])) and (not IsTrimmableA(S[L])) then begin
    Result := S;
    Exit;
  end;

  while (I <= L) and (IsTrimmableA(S[I])) do
    Inc(I);

  if I > L then begin
    Result := '';
    Exit;
  end;

  while IsTrimmableA(S[L]) do
    Dec(L);

  Result := Copy(S, I, L - I + 1);
end;

{$IFNDEF UNICODE}
function CharInSet(const AChar: AnsiChar; const ASet: TSysCharSet): Boolean; inline;
begin
  Result := (AChar in ASet);
end;
{$ENDIF}

procedure DelCharInSetA(var S: AnsiString; const ASet: TSysCharSet);
var
  i: Integer;
begin
  i := Length(S);
  while (i > 0) do begin
    if CharInSet(S[i], ASet) then begin
      Delete(S, i, 1);
    end;
    Dec(i);
  end;
end;

function IntToStrA(const AValue: Integer): AnsiString;
const
  cFormat = AnsiString('%d');
var
  VBuffer: array [0..15] of AnsiChar;
  VLen: Cardinal;
begin
  VLen := {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}
    FormatBuf(
      VBuffer,
      SizeOf(VBuffer),
      cFormat,
      StrLenA(cFormat),
      [AValue]
    );
  if (VLen > 0) then begin
    SetString(Result, PAnsiChar(@VBuffer), VLen);
  end else begin
    Result := '';
  end;
end;

function IntToHexA(const Value: Integer; const Digits: Integer): AnsiString;
begin
  Result := AnsiString(IntToHex(Value, Digits));
end;

function PosA(const ASubStr, ABigStr: AnsiString): Integer;
begin
{$IF CompilerVersion < 23}
  Result := System.Pos(ASubStr, ABigStr);
{$ELSE}
  Result := System.Pos(RawByteString(ASubStr), RawByteString(ABigStr));
{$IFEND}
end;

function PosA(const ASubStr, ABigStr: AnsiString; AOffset: Integer): Integer;
begin
{$IFDEF HAS_ANSISTRINGS_UNIT}
  Result := AnsiStrings.PosEx(ASubStr, ABigStr, AOffset);
{$ELSE}
  Result := StrUtils.PosEx(ASubStr, ABigStr, AOffset);
{$ENDIF}
end;

function FloatToStrFixedA(
  const Value: Extended;
  //Format: TFloatFormat;
  const Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings
): AnsiString;
var
  VBuffer: array [0..63] of AnsiChar;
begin
  SetString(
    Result,
    VBuffer,
    {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}FloatToText(
      VBuffer,
      Value,
      fvExtended,
      ffFixed, //Format,
      Precision,
      Digits,
      AFormatSettings
    )
  );
end;

function FloatToStrA(
  const Value: Extended;
  const AFormatSettings: TFormatSettings
): AnsiString;
var
  VBuffer: array [0..63] of AnsiChar;
begin
  SetString(
    Result,
    VBuffer,
    {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}FloatToText(
      VBuffer,
      Value,
      fvExtended,
      ffGeneral, //Format,
      15,
      0,
      AFormatSettings
    )
  );
end;

function DateToStrA(
  const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings
): AnsiString;
var
  VResult: string;
begin
  DateTimeToString(VResult, AFormatSettings.ShortDateFormat, DateTime, AFormatSettings);
  Result := AnsiString(VResult);
end;

function TimeToStrA(
  const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings
): AnsiString;
var
  VResult: string;
begin
  DateTimeToString(VResult, AFormatSettings.LongTimeFormat, DateTime, AFormatSettings);
  Result := AnsiString(VResult);
end;

function StrToFloatA(
  const S: AnsiString;
  const AFormatSettings: TFormatSettings
): Extended;
begin
  if not {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}TextToFloat(PAnsiChar(S), Result, fvExtended, AFormatSettings) then
    raise EConvertError.CreateResFmt(@SInvalidFloat, [string(S)]);
end;

function TryStrToFloatA(
  const S: AnsiString;
  out AValue: Extended;
  const AFormatSettings: TFormatSettings
): Boolean;
begin
  Result := {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}
    TextToFloat(PAnsiChar(S), AValue, fvExtended, AFormatSettings);
end;

function TryStrToFloatA(
  const S: AnsiString;
  out AValue: Double;
  const AFormatSettings: TFormatSettings
): Boolean;
const
  MaxDouble   =  1.7e+308;
var
  VValue: Extended;
begin
  Result := {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}
    TextToFloat(PAnsiChar(S), VValue, fvExtended, AFormatSettings);
  if Result then
    if (VValue < -MaxDouble) or (VValue > MaxDouble) then
      Result := False;
  if Result then
    AValue := VValue;
end;

function StrToIntA(const S: AnsiString): Integer;
begin
  // TODO: val
  Result := StrToInt(string(S));
end;

function TryStrToIntA(const S: AnsiString; out AValue: Integer): Boolean;
//var E: Integer;
begin
  //Val(string(S), AValue, E);
  //Result := (0 = E);
  Result := TryStrToInt(string(S), AValue);
end;

function AnsiLowerCaseA(const S: AnsiString): AnsiString;
var
  VLen: Cardinal;
begin
  VLen := Length(S);
  SetString(Result, PAnsiChar(@S[1]), VLen);
  AnsiLowerBuff(PAnsiChar(@Result[1]), VLen);
end;

function AnsiUpperCaseA(const S: AnsiString): AnsiString;
var
  VLen: Cardinal;
begin
  VLen := Length(S);
  SetString(Result, PAnsiChar(@S[1]), VLen);
  AnsiUpperBuff(PAnsiChar(@Result[1]), VLen);
end;

function StringReplaceA(
  const S, OldPattern, NewPattern: AnsiString;
  Flags: TReplaceFlags
): AnsiString;
begin
{$IFDEF HAS_ANSISTRINGS_UNIT}
  Result := AnsiStrings.StringReplace(S, OldPattern, NewPattern, Flags);
{$ELSE}
  Result := AnsiString(
    StringReplace(
      string(S),
      string(OldPattern),
      string(NewPattern),
      Flags
    )
  );
{$ENDIF}
end;

procedure StringReplaceSingleCharA(var S: AnsiString; const AOld, ANew: AnsiChar);
var i: Integer;
begin
  for i := 1 to Length(S) do
  if (AOld = S[i]) then
    S[i] := ANew;
end;

function StrLenA(const Str: PAnsiChar): Cardinal;
begin
{$IFDEF HAS_ANSISTRINGS_UNIT}
  Result := AnsiStrings.StrLen(Str);
{$ELSE}
  Result := StrLen(Str);
{$ENDIF}
end;

function StrLenW(Src: PWideChar): DWORD;
begin
  Result:=0;
  if (nil<>Src) then
  while (Src^<>#0) do begin
    Inc(Result);
    Inc(Src);
  end;
end;

function VSAGPS_CreateFileW(
  const phFile: PHandle;
  const pSrcFileName: PWideChar;
  const bOpenExisting: Boolean
): Boolean;
var
  dwDesiredAccess, dwShareMode, dwCreationDisposition: DWORD;
begin
  if bOpenExisting then begin
    // open existing file
    dwDesiredAccess := GENERIC_READ;
    dwShareMode := (FILE_SHARE_READ or FILE_SHARE_WRITE);
    dwCreationDisposition := OPEN_EXISTING;
  end else begin
    // create new file
    dwDesiredAccess := (GENERIC_READ or GENERIC_WRITE);
    dwShareMode := FILE_SHARE_READ;
    dwCreationDisposition := CREATE_ALWAYS;
  end;

  phFile^ := CreateFileW(
    pSrcFileName,
    dwDesiredAccess,
    dwShareMode,
    nil,
    dwCreationDisposition,
    FILE_ATTRIBUTE_NORMAL,
    0
  );

  if (INVALID_HANDLE_VALUE = phFile^) then
    phFile^ := 0;

  Result := (0 <> phFile^);
end;

function VSAGPS_GetFileSize(const hFile: THandle; var iSize: Int64): Boolean;
var dwLO, dwHI: DWORD;
begin
  Result:=FALSE;
  dwLO:=GetFileSize(hFile, @dwHI);
  if (INVALID_FILE_SIZE<>dwLO) or ((INVALID_FILE_SIZE=dwLO) and (NO_ERROR=GetLastError)) then begin
    Result:=TRUE;
    with Int64Rec(iSize) do begin
      Lo:=dwLO;
      Hi:=dwHI;
    end;
  end;
end;

function VSAGPS_ReadFileContent(const ASrcFileName: WideString): AnsiString;
var
  h: THandle;
  iSize: Int64;
  dwRead: DWORD;
begin
  Result := '';
  if VSAGPS_CreateFileW(@h, PWideChar(ASrcFileName), True) then
  try
    if VSAGPS_GetFileSize(h, iSize) then
    if (0 = Int64Rec(iSize).Hi) then begin // do not open huge files
      SetLength(Result, Int64Rec(iSize).Lo);
      // TODO: check read length
      if not ReadFile(h, PAnsiChar(Result)^, Int64Rec(iSize).Lo, dwRead, nil) then
        Result := '';
    end;
  finally
    CloseHandle(h);
  end;
end;

function SafeSetStringP(const ABuffer: PAnsiChar): AnsiString;
var L: Integer;
begin
  if (nil = ABuffer) then
    Result := ''
  else begin
    L := StrLenA(ABuffer);
    if (0 = L) then
      Result := ''
    else
      SetString(Result, ABuffer, L);
  end;
end;

function SafeSetStringP(const ABuffer: PWideChar): WideString;
var L: Integer;
begin
  if (nil = ABuffer) then
    Result := ''
  else begin
    L := StrLenW(ABuffer);
    if (0 = L) then
      Result := ''
    else
      SetString(Result, ABuffer, L);
  end;
end;

function SafeSetStringL(const ABuffer: PAnsiChar; const ALength: Integer): AnsiString;
begin
  if (nil = ABuffer) or (0 = ALength) then
    Result := ''
  else
    SetString(Result, ABuffer, ALength);
end;

function SafeSetStringL(const ABuffer: PWideChar; const ALength: Integer): WideString;
begin
  if (nil = ABuffer) or (0 = ALength) then
    Result := ''
  else
    SetString(Result, ABuffer, ALength);
end;

procedure VSAGPS_DividePCharToLines(
  const ASource: PAnsiChar;
  const AProc: TVSAGPS_DivideStringToLinesA_Proc;
  const AUserPtr: Pointer;
  const ADivOnSpacesToo: Boolean;
  const ApExitIfSet: PBoolean
);
var
  p,pStart: PAnsiChar;
  str_line: AnsiString;
begin
  if (nil=ASource) then
    Exit;
  p:=ASource;
  // find lines
  while (#0<>p^) do begin
    // check if aborted by user
    if (nil<>ApExitIfSet) then
      if (ApExitIfSet^) then
        break;
    // work
    pStart:=p;
    while TRUE do begin
      if (p^ in [#0, #10, #13]) then
        break;
      if ADivOnSpacesToo and (p^ in [#32, #160]) then
        break;
      Inc(p);
    end;
    str_line := SafeSetStringL(pStart, p-pStart);
    AProc(str_line, AUserPtr);
    if (#13=p^) then
      Inc(p);
    if (#10=p^) then
      Inc(p);
    if ADivOnSpacesToo and (p^ in [#32, #160]) then
      Inc(p);
  end;
end;

procedure VSAGPS_DividePCharToLines(
  const ASource: PWideChar;
  const AProc: TVSAGPS_DivideStringToLinesW_Proc;
  const AUserPtr: Pointer;
  const ADivOnSpacesToo: Boolean;
  const ApExitIfSet: PBoolean
);
var
  p,pStart: PWideChar;
  str_line: WideString;
begin
  if (nil=ASource) then
    Exit;
  p:=ASource;
  // find lines
  while (#0<>p^) do begin
    // check if aborted by user
    if (nil<>ApExitIfSet) then
      if (ApExitIfSet^) then
        break;
    // work
    pStart:=p;
    while TRUE do begin
      if (#0=p^) or (#10=p^) or (#13=p^) then
        break;
      if ADivOnSpacesToo and ((#32=p^) or (#160=p^)) then
        break;
      Inc(p);
    end;
    str_line := SafeSetStringL(pStart, p-pStart);
    AProc(str_line, AUserPtr);
    if (#13=p^) then
      Inc(p);
    if (#10=p^) then
      Inc(p);
    if ADivOnSpacesToo and ((#32=p^) or (#160=p^)) then
      Inc(p);
  end;
end;

(*
procedure VSAGPS_DividePCharToLines(
  const ASource: PChar;
  const AProc: TVSAGPS_DivideStringToLinesS_Proc;
  const AUserPtr: Pointer;
  const ADivOnSpacesToo: Boolean;
  const ApExitIfSet: PBoolean
);
begin
{$IFDEF UNICODE}
  VSAGPS_DividePCharToLines(PWideChar(ASource), TVSAGPS_DivideStringToLinesW_Proc(AProc), AUserPtr, ADivOnSpacesToo, ApExitIfSet);
{$ELSE}
  VSAGPS_DividePCharToLines(PAnsiChar(ASource), TVSAGPS_DivideStringToLinesA_Proc(AProc), AUserPtr, ADivOnSpacesToo, ApExitIfSet);
{$ENDIF}
end;
*)

function VSAGPS_WideString_To_Double(const src: WideString;
                                     var dbl: Double;
                                     const fs: TFormatSettings): Boolean;
begin
  try
    Result:=TryStrToFloat(src, dbl, fs);
  except
    Result:=FALSE;
  end;
end;

function VSAGPS_WideString_To_Byte(const src: WideString;
                                   var v: Byte): Boolean;
var i: Integer;
begin
  Result:=TryStrToInt(string(src), i) and (i>0) and (i<=$FF);
  if Result then
    v:=LoByte(LoWord(i));
end;

function VSAGPS_Digit(const wc: WideChar): Boolean;
begin
  Result:=('0'=wc) or (('1'<=wc) and ('9'>=wc));
end;

function VSAGPS_ExtractNum(const src: WideString;
                           var i, V: Integer;
                           const check_minmax: Boolean;
                           const minvalue,maxvalue: SmallInt;
                           const check_len: Boolean;
                           const lenvalue: Byte): Boolean;
var
  cnt: Byte;
  L: Integer;
begin
  Result:=FALSE;
  V:=0;
  cnt:=0;
  L:=Length(src);

  while (i<=L) and VSAGPS_Digit(src[i]) do begin
    V:=V*10+StrToInt(src[i]);
    Inc(cnt);
    // check break
    if (check_minmax) and (maxvalue<V) then
      Exit;
    if (check_len) and (lenvalue<cnt) then
      Exit;
    // next
    Inc(i);
  end;

  if check_len then begin
    // expand
    while (lenvalue>cnt) do begin
      V:=V*10;
      Inc(cnt);
    end;
    Result:=TRUE;
  end;

  if check_minmax then
    Result:=((maxvalue>=V) and (minvalue<=V));
end;

function VSAGPS_WideString_to_ISO8601_Time(const src: WideString;
                                           const pdt: PDateTime): Boolean;
const
  parser_maxyear = 2048;
var
  i,L,V: Integer;
  st: TSystemTime;
  //dt: TDateTime;
  sep: WideChar;

  function _ExtractFirstInt(const minvalue,maxvalue: SmallInt): Boolean;
  begin
    Result:=VSAGPS_ExtractNum(src,i,V,TRUE,minvalue,maxvalue,FALSE,0);
  end;

  function _ExtractFrac(const numlen: Byte): Boolean;
  begin
    Result:=VSAGPS_ExtractNum(src,i,V,FALSE,0,0,TRUE,numlen);
  end;

  function _CheckSeparator: Boolean;
  begin
    if (i>L) then
      Result:=FALSE
    else if (#0=sep) then begin
      // save (except T and Z and points)
      sep:=src[i];
      Result:=(('T'<>sep) and ('Z'<>sep) and ('.'<>sep) and (','<>sep));
    end else begin
      // check
      Result:=(sep=src[i]);
    end;
    if Result then
      Inc(i);
  end;

  function _CheckWChar(const wc1, wc2: WideChar): Boolean;
  begin
    if (i>L) then
      Result:=FALSE
    else
      Result:=(wc1=src[i]) or (wc2=src[i]);
    if Result then begin
      sep:=#0;
      Inc(i);
    end;
  end;
begin
  // 2011-11-30T21:13:05.973Z (ISO 8601 - not fully implemented)
  // 2011-12-08T11:23:57+04:00Z
  Result:=FALSE;
  sep:=#0;
  Zeromemory(@st, sizeof(st));

  L:=Length(src);
  i:=1;

  // Year
  if _ExtractFirstInt(0, parser_maxyear) then
    st.wYear:=V
  else
    Exit;
  // separator
  if not _CheckSeparator then
    Exit;
  // Month
  if _ExtractFirstInt(1,12) then
    st.wMonth:=V
  else
    Exit;
  // separator
  if not _CheckSeparator then
    Exit;
  // Day
  if _ExtractFirstInt(1,31) then
    st.wDay:=V
  else
    Exit;
  // T (reset separator)
  if not _CheckWChar('T',#0) then
    Exit;
  // Hour
  if _ExtractFirstInt(0,23) then
    st.wHour:=V
  else
    Exit;
  // separator
  if not _CheckSeparator then
    Exit;
  // Minute
  if _ExtractFirstInt(0,59) then
    st.wMinute:=V
  else
    Exit;
  // separator
  if not _CheckSeparator then
    Exit;
  // Second
  if _ExtractFirstInt(0,59) then
    st.wSecond:=V
  else
    Exit;
  // Z or ., or +- for timeshift
  if _CheckWChar('.',',') then begin
    // Milliseconds
    if _ExtractFrac(3) then
      st.wMilliseconds:=V
    else
      Exit;
  end;
  // convert to p
  try
    pdt^:=SystemTimeToDateTime(st);
  except
    Exit;
  end;
  // ok
  Result:=TRUE;
end;

function ExtractBeforeSpaceDelimiter(var ASourceString: WideString): WideString;
begin
  Result := '';

  // remove starting delimiters
  while Length(ASourceString)>0 do begin
    case ASourceString[1] of
      #10,#13,#0,#32,#160:
        System.Delete(ASourceString,1,1);
      else
        break;
    end;
  end;

  // get before
  while Length(ASourceString)>0 do begin
    case ASourceString[1] of
      #10,#13,#0,#32,#160:
        break;
      else begin
        Result := Result + ASourceString[1];
        System.Delete(ASourceString,1,1);
      end;
    end;
  end;
end;

end.