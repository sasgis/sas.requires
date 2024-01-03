(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_classes;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
{$if not defined(USE_SIMPLE_CLASSES)}
  Classes,
{$ifend}
{$IFDEF HAS_ANSISTRINGS_UNIT}
  AnsiStrings,
{$ENDIF}
  vsagps_public_sysutils;

type
  Pvsagps_list_item = ^Tvsagps_list_item;
  Tvsagps_list_item = record
    next: Pvsagps_list_item;
    data: Pointer;
    uptr: Pointer;
  end;

  Tvsagps_List = class(TObject)
  private
    pData: Pvsagps_list_item;
    pLast: Pvsagps_list_item;
  protected
    procedure InternalFreeAllItems;
    procedure InternalAppendItem(const p, u: Pointer);
    function InternalExtractItem(var p, u: Pointer): Boolean;
  public
    function EnumItems(var AEnumPtr: Pvsagps_list_item; var AEnumData: Pointer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$if defined(USE_SIMPLE_CLASSES)}
  TList = Tvsagps_List;
{$else}
  TList = Classes.TList;
{$ifend}

  Tvsagps_Indexed_List = class(Tvsagps_List)
  private
    // cache for index operations
    FCachedItem: Pvsagps_list_item;
    FCachedIndex: Integer;
  protected
    function GetListObjects(const AIndex: Integer): Pointer;
    procedure SetListObjects(const AIndex: Integer; const Value: Pointer);
    function InternalLocateItem(const AIndex: Integer; out pItem: Pvsagps_list_item): Boolean;
  public
    constructor Create;
    function Count: Integer;
    procedure Delete(const AIndex: Integer);
    property Objects[const AIndex: Integer]: Pointer read GetListObjects write SetListObjects;
  end;

  TCustomStrings = class(Tvsagps_Indexed_List)
  public
    procedure SetFileContentA(const AText: AnsiString); virtual; abstract;
    procedure SetFileContentW(const AText: WideString); virtual; abstract;
  public
    procedure Clear;
    procedure LoadFromFile(const AFilename: WideString);
  end;

  TStringsA = class(TCustomStrings)
  private
    function GetListItem(const AIndex: Integer): AnsiString;
    function GetTextStr: AnsiString;
    procedure SetTextStr(const S: AnsiString);
  public
    procedure SetFileContentA(const AText: AnsiString); override;
    procedure SetFileContentW(const AText: WideString); override;
  public
    procedure AppendWithPtr(const ALine: AnsiString; const AUserPtr: Pointer);
    procedure Append(const S: AnsiString);
    procedure AppendPChar(const S: PAnsiChar);
    function AddObject(const S: AnsiString; AObject: TObject): Integer;
    procedure Assign(src: TStringsA);
    //procedure LoadFromStream(AStream: THandleStream);
    function IndexOf(const S: AnsiString): Integer;
    property Items[const AIndex: Integer]: AnsiString read GetListItem; default;
    property Text: AnsiString read GetTextStr write SetTextStr;
  end;
  TStringListA = TStringsA;

  TStringsW = class(TCustomStrings)
  private
    function GetListItem(const AIndex: Integer): WideString;
    function GetTextStr: WideString;
    procedure SetTextStr(const S: WideString);
  public
    procedure SetFileContentA(const AText: AnsiString); override;
    procedure SetFileContentW(const AText: WideString); override;
  public
    procedure AppendWithPtr(const ALine: WideString; const AUserPtr: Pointer);
    procedure Append(const S: WideString);
    procedure AppendPChar(const S: PWideChar);
    function AddObject(const S: WideString; AObject: TObject): Integer;
    procedure Assign(src: TStringsW);
    //procedure LoadFromStream(AStream: THandleStream);
    function IndexOf(const S: WideString): Integer;
    property Items[const AIndex: Integer]: WideString read GetListItem; default;
    property Text: WideString read GetTextStr write SetTextStr;
  end;

  TStringListW = TStringsW;

{$if defined(USE_SIMPLE_CLASSES)}
{$IFDEF UNICODE}
  TStrings = TStringsW;
{$ELSE}
  TStrings = TStringsA;
{$ENDIF}
  TStringList = TStrings;
{$else}
  TStrings = Classes.TStrings;
  TStringList = Classes.TStringList;
{$ifend}

  TRegistryA = class(TObject)
  private
    FRootKey: HKEY;
    FCurrentKey: HKEY;
    procedure SetRootKey(const Value: HKEY);
  protected
    function InternalRegOpenKeyEx(const AKey: AnsiString; const AAccess: DWORD): Boolean;
    procedure InternalCloseCurrentKey;
  public
    constructor Create;
    destructor Destroy; override;

    function OpenKeyReadOnly(const AKey: AnsiString): Boolean;
    procedure GetValueNames(AStrings: TStringsA);
    function ReadString(const AName: AnsiString): AnsiString;

    property RootKey: HKEY read FRootKey write SetRootKey;
  end;

implementation

uses
  vsagps_public_memory;

{ Tvsagps_List }

constructor Tvsagps_List.Create;
begin
  inherited Create;
  pData := nil;
  pLast := nil;
end;

destructor Tvsagps_List.Destroy;
begin
  InternalFreeAllItems;
  inherited;
end;

function Tvsagps_List.EnumItems(
  var AEnumPtr: Pvsagps_list_item;
  var AEnumData: Pointer
): Boolean;
begin
  if (nil = AEnumPtr) then begin
    // first run
    AEnumPtr := pData;
    Result := (nil <> pData);
    if Result then
      AEnumData := pData.data
    else
      AEnumData := nil;
  end else begin
    // others
    Result := (nil <> Pvsagps_list_item(AEnumPtr).next);
    if Result then begin
      AEnumPtr := AEnumPtr.next;
      AEnumData := AEnumPtr.data;
    end;
  end;
end;

procedure Tvsagps_List.InternalAppendItem(const p, u: Pointer);
begin
  if (nil = pData) then begin
    // very first packet
    New(pData);
    pData.next := nil;
    pData.data := p;
    pData.uptr := u;
    pLast := pData;
  end else begin
    // add to tail
    New(pLast.next);
    pLast := pLast.next;
    pLast.next := nil;
    pLast.data := p;
    pLast.uptr := u;
  end;
end;

function Tvsagps_List.InternalExtractItem(var p, u: Pointer): Boolean;
var q: Pvsagps_list_item;
begin
  Result := False;
  if (nil <> pData) then begin
    q := pData;
    pData := pData.next;
    p := q.data;
    u := q.uptr;
    Dispose(q);
    if (nil = pData) then
      pLast := nil;
    Result := True;
  end;
end;

procedure Tvsagps_List.InternalFreeAllItems;
var p, u: Pointer;
begin
  if (nil = Self) then
    Exit;
  while InternalExtractItem(p, u) do
    VSAGPS_FreeMem(p);
end;

{ Tvsagps_Indexed_List }

function Tvsagps_Indexed_List.Count: Integer;
var
  VEnumPtr: Pvsagps_list_item;
  VDummy: Pointer;
begin
  Result := 0;
  VEnumPtr := nil;
  while EnumItems(VEnumPtr, VDummy) do begin
    Inc(Result);
  end;
end;

constructor Tvsagps_Indexed_List.Create;
begin
  inherited;
  FCachedItem := nil;
  FCachedIndex := 0;
end;

procedure Tvsagps_Indexed_List.Delete(const AIndex: Integer);
var
  p, u: Pointer;
  pPrev, pNext: Pvsagps_list_item;
begin
  if (0 > AIndex) then
    Exit;

  if (0 = AIndex) then begin
    // extract and kill very first item
    if InternalExtractItem(p, u) then
      VSAGPS_FreeMem(p);
  end else if InternalLocateItem(AIndex-1, pPrev) then begin
    // got prev item
    if (pPrev^.next <> nil) then begin
      // next item exists - free it
      pNext := pPrev^.next;
      pPrev^.next := pNext^.next;
      if (pNext = pLast) then
        pLast := pPrev;
      if (pNext^.data <> nil) then
        VSAGPS_FreeMem(pNext^.data);
      Dispose(pNext);
    end;
  end;
end;

function Tvsagps_Indexed_List.GetListObjects(const AIndex: Integer): Pointer;
var p: Pvsagps_list_item;
begin
  if InternalLocateItem(AIndex, p) then
    Result := p^.uptr
  else
    Result := nil;
end;

function Tvsagps_Indexed_List.InternalLocateItem(
  const AIndex: Integer;
  out pItem: Pvsagps_list_item
): Boolean;
var p: Pointer;
begin
  Result := False;
  pItem := nil;

  // check
  if (AIndex < 0) or (nil = pData) then begin
    // failed
    Exit;
  end;

  // if after cached item - lookup from cached item
  // if before - start from the very beginning
  if (nil = FCachedItem) or (AIndex < FCachedIndex) then begin
    // set at start
    FCachedItem := pData;
    FCachedIndex := 0;
  end;

  repeat
    // cached item
    if (AIndex = FCachedIndex) and (nil <> FCachedItem) then begin
      pItem := FCachedItem;
      Result := True;
      Exit;
    end;

    // get next
    if EnumItems(FCachedItem, p) then begin
      // fetched successfully
      Inc(FCachedIndex);
    end else begin
      // end of list - reset cache
      FCachedItem := nil;
      // do not reset FCachedIndex!!!
      Exit;
    end;
  until False;
end;

procedure Tvsagps_Indexed_List.SetListObjects(
  const AIndex: Integer;
  const Value: Pointer
);
var p: Pvsagps_list_item;
begin
  if InternalLocateItem(AIndex, p) then
    p^.uptr := Value;
end;

{ TCustomStrings }

procedure TCustomStrings.Clear;
begin
  InternalFreeAllItems;
end;

procedure TCustomStrings.LoadFromFile(const AFilename: WideString);
var
  VContent: AnsiString;
  VLen: Cardinal;
  VBuffer: Pointer;
  VText: WideString;
begin
  VContent := VSAGPS_ReadFileContent(AFilename);
  if (0 = Length(VContent)) then begin
    Clear;
  end else begin
    VLen := Length(VContent);
    VBuffer := PAnsiChar(@VContent[1]);
    if IsTextUnicode(VBuffer, VLen, nil) then begin
      // unicode
      SetString(VText, PWideChar(VBuffer), (VLen div SizeOf(WideChar)));
      SetFileContentW(VText);
    end else begin
      // ansi
      SetFileContentA(VContent);
    end;
  end;
end;

{ TStringsA }

function TStringsA.AddObject(const S: AnsiString; AObject: TObject): Integer;
begin
  InternalAppendItem(VSAGPS_AllocPCharByString(S, False), Pointer(AObject));
  Result := 0;
end;

procedure TStringsA.Append(const S: AnsiString);
begin
  AppendWithPtr(S, nil);
end;

procedure TStringsA.AppendPChar(const S: PAnsiChar);
begin
  InternalAppendItem(VSAGPS_AllocPCharByPChar(S, False), nil);
end;

procedure TStringsA.AppendWithPtr(const ALine: AnsiString; const AUserPtr: Pointer);
begin
  InternalAppendItem(VSAGPS_AllocPCharByString(ALine, False), AUserPtr);
end;

procedure TStringsA.Assign(src: TStringsA);
var
  VEnumPtr: Pvsagps_list_item;
  VPayloadPtr: Pointer;
  S: AnsiString;
begin
  Clear;
  if (nil = src) then
    Exit;
  VEnumPtr := nil;
  while src.EnumItems(VEnumPtr, VPayloadPtr) do begin
    S := SafeSetStringP(PAnsiChar(VPayloadPtr));
    Append(S);
  end;
end;

function TStringsA.GetListItem(const AIndex: Integer): AnsiString;
var
  VItem: Pvsagps_list_item;
begin
  if InternalLocateItem(AIndex, VItem) then begin
    if (VItem <> nil) and (VItem^.data <> nil) then
      SetString(Result, PAnsiChar(VItem^.data), StrLenA(PAnsiChar(VItem^.data)))
    else
      Result := '';
  end else
    Result := '';
end;

function TStringsA.GetTextStr: AnsiString;
var
  VEnumPtr: Pvsagps_list_item;
  VPayloadPtr: Pointer;
  VLineCounter: Cardinal;
  S: AnsiString;
begin
  Result := '';
  VLineCounter := 0;
  VEnumPtr := nil;
  while EnumItems(VEnumPtr, VPayloadPtr) do begin
    S := SafeSetStringP(PAnsiChar(VPayloadPtr));
    if (0 < VLineCounter) then
      Result := Result + System.sLineBreak;
    Result := Result + S;
    Inc(VLineCounter);
  end;
end;

function TStringsA.IndexOf(const S: AnsiString): Integer;
var
  VEnumPtr: Pvsagps_list_item;
  VPayloadPtr: Pointer;
  VLen: Cardinal;
begin
  Result := 0;
  VEnumPtr := nil;
  VLen := Length(S);
  while EnumItems(VEnumPtr, VPayloadPtr) do begin
    if (StrLenA(PAnsiChar(VPayloadPtr)) = VLen) then
    if (0 = AnsiStrLICompA(PAnsiChar(VPayloadPtr), PAnsiChar(@S[1]), VLen)) then
      Exit;
    Inc(Result);
  end;
  Result := -1;
end;

procedure TStringsA.SetFileContentA(const AText: AnsiString);
begin
  SetTextStr(AText);
end;

procedure TStringsA.SetFileContentW(const AText: WideString);
begin
  // TODO: maybe convert?
  SetTextStr(AnsiString(AText));
end;

procedure TStringsA.SetTextStr(const S: AnsiString);
begin
  Clear;
  VSAGPS_DividePCharToLines(PAnsiChar(S), Self.AppendWithPtr, nil, False, nil);
end;

{ TStringsW }

function TStringsW.AddObject(const S: WideString; AObject: TObject): Integer;
begin
  InternalAppendItem(VSAGPS_AllocPCharByString(S, False), Pointer(AObject));
  Result := 0;
end;

procedure TStringsW.Append(const S: WideString);
begin
  AppendWithPtr(S, nil);
end;

procedure TStringsW.AppendPChar(const S: PWideChar);
begin
  InternalAppendItem(VSAGPS_AllocPCharByPChar(S, False), nil);
end;

procedure TStringsW.AppendWithPtr(const ALine: WideString; const AUserPtr: Pointer);
begin
  InternalAppendItem(VSAGPS_AllocPCharByString(ALine, False), AUserPtr);
end;

procedure TStringsW.Assign(src: TStringsW);
var
  VEnumPtr: Pvsagps_list_item;
  VPayloadPtr: Pointer;
  S: WideString;
begin
  Clear;
  if (nil = src) then
    Exit;
  VEnumPtr := nil;
  while src.EnumItems(VEnumPtr, VPayloadPtr) do begin
    S := SafeSetStringP(PWideChar(VPayloadPtr));
    Append(S);
  end;
end;

function TStringsW.GetListItem(const AIndex: Integer): WideString;
var
  VItem: Pvsagps_list_item;
begin
  if InternalLocateItem(AIndex, VItem) then begin
    if (VItem <> nil) and (VItem^.data <> nil) then
      SetString(Result, PWideChar(VItem^.data), StrLenW(PWideChar(VItem^.data)))
    else
      Result := '';
  end else
    Result := '';
end;

function TStringsW.GetTextStr: WideString;
var
  VEnumPtr: Pvsagps_list_item;
  VPayloadPtr: Pointer;
  VLineCounter: Cardinal;
  S: WideString;
begin
  Result:='';
  VLineCounter := 0;
  VEnumPtr := nil;
  while EnumItems(VEnumPtr, VPayloadPtr) do begin
    S := SafeSetStringP(PWideChar(VPayloadPtr));
    if (0 < VLineCounter) then
      Result := Result + System.sLineBreak;
    Result := Result + S;
    Inc(VLineCounter);
  end;
end;

function TStringsW.IndexOf(const S: WideString): Integer;
var
  VEnumPtr: Pvsagps_list_item;
  VPayloadPtr: Pointer;
  VLen: Cardinal;
begin
  Result := 0;
  VEnumPtr := nil;
  VLen := Length(S);
  while EnumItems(VEnumPtr, VPayloadPtr) do begin
    if (StrLenW(PWideChar(VPayloadPtr)) = VLen) then begin
{$IFDEF UNICODE}
      if (0 = AnsiStrLIComp(PWideChar(VPayloadPtr), PWideChar(@S[1]), VLen)) then
        Exit;
{$ELSE}
      if (0 = WideCompareText(WideString(PWideChar(VPayloadPtr)), S)) then
        Exit;
{$ENDIF}
    end;
    Inc(Result);
  end;
  Result := -1;
end;

procedure TStringsW.SetFileContentA(const AText: AnsiString);
begin
  // TODO: maybe convert?
  SetTextStr(WideString(AText));
end;

procedure TStringsW.SetFileContentW(const AText: WideString);
begin
  SetTextStr(AText);
end;

procedure TStringsW.SetTextStr(const S: WideString);
begin
  Clear;
  VSAGPS_DividePCharToLines(PWideChar(S), Self.AppendWithPtr, nil, FALSE, nil);
end;

{ TRegistryA }

constructor TRegistryA.Create;
begin
  inherited;
  FRootKey := HKEY_CURRENT_USER;
end;

destructor TRegistryA.Destroy;
begin
  InternalCloseCurrentKey;
  inherited;
end;

procedure TRegistryA.GetValueNames(AStrings: TStringsA);
var
  VRes: Longint;
  dwIndex, dwLen, dwSize: DWORD;
  S: AnsiString;
begin
  AStrings.Clear;
  dwIndex := 0;
  dwLen := 256;
  SetLength(S, dwLen);
  repeat
    dwSize := dwLen;
    VRes := RegEnumValueA(FCurrentKey, dwIndex, PAnsiChar(S), dwSize, nil, nil, nil, nil);
    case VRes of
      ERROR_SUCCESS: begin
        // ok
        AStrings.AppendPChar(PAnsiChar(S));
        Inc(dwIndex);
      end;
      ERROR_NO_MORE_ITEMS: begin
        // finished
        Exit;
      end;
      ERROR_MORE_DATA: begin
        // buffer too small
        dwLen := dwLen * 2;
        SetLength(S, dwLen);
      end;
      else begin
        // error
        Exit;
      end;
    end;
  until False;
end;

procedure TRegistryA.InternalCloseCurrentKey;
begin
  if (0 <> FCurrentKey) then begin
    RegCloseKey(FCurrentKey);
    FCurrentKey := 0;
  end;
end;

function TRegistryA.InternalRegOpenKeyEx(
  const AKey: AnsiString;
  const AAccess: DWORD
): Boolean;
var
  hTempKey: HKEY;
begin
  Result := (RegOpenKeyExA(FRootKey, PAnsiChar(AKey), 0, AAccess, hTempKey) = ERROR_SUCCESS);
  if Result then
    FCurrentKey := hTempKey;
end;

function TRegistryA.OpenKeyReadOnly(const AKey: AnsiString): Boolean;
begin
  Result := InternalRegOpenKeyEx(AKey, KEY_READ);
  if (not Result) then
    Result := InternalRegOpenKeyEx(AKey, (STANDARD_RIGHTS_READ or KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS));
  if (not Result) then
    Result := InternalRegOpenKeyEx(AKey, KEY_QUERY_VALUE);
end;

function TRegistryA.ReadString(const AName: AnsiString): AnsiString;
var
  VRes: LongInt;
  VBuf: PAnsiChar;
  dwType, dwSize, dwLen: DWORD;
begin
  Result := '';
  dwLen := 256;
  VBuf := VSAGPS_GetMemZ(dwLen);
  try
    repeat
      dwType := REG_NONE;
      dwSize := dwLen;
      VRes := RegQueryValueExA(FCurrentKey, PAnsiChar(AName), nil, @dwType, PByte(VBuf), @dwSize);
      case VRes of
        ERROR_SUCCESS: begin
          // ok
          Result := SafeSetStringL(VBuf, dwSize-1);
          Exit;
        end;
        ERROR_MORE_DATA: begin
          // buffer too small
          dwLen := dwLen * 2;
          VSAGPS_FreeMem(VBuf);
          VBuf := VSAGPS_GetMemZ(dwLen);
        end;
      else
        // error
        // raise ERegistryException.CreateResFmt(@SRegGetDataFailed, [AName]);
        Exit;
      end;
    until False;
  finally
    VSAGPS_FreeMem(VBuf);
  end;
end;

procedure TRegistryA.SetRootKey(const Value: HKEY);
begin
  if (FRootKey <> Value) then begin
    InternalCloseCurrentKey;
    FRootKey := Value;
  end;
end;

(*
procedure TStringsA.LoadFromStream(AStream: THandleStream);
var
  L: Integer;
  s: AnsiString;
begin
  L:=AStream.Size;
  SetLength(s, L);
  L := AStream.Read(Pointer(s)^, L);
  // TODO: check unicode text in stream (file)
  if (SizeOf(Char) = SizeOf(WideChar)) then begin
  end else begin
  end;
  SetLength(s, L);
  SetTextStr(s);
end;

procedure TStrings.LoadFromStream(AStream: THandleStream);
var
  L: Integer;
  s: string;
begin
  L:=AStream.Size;
  SetLength(s, L);
  L := AStream.Read(Pointer(s)^, L);
  // TODO: check unicode text in stream (file)
  if (SizeOf(Char) = SizeOf(WideChar)) then begin
  end else begin
  end;
  SetLength(s, L);
  SetTextStr(s);
end;
*)

end.
