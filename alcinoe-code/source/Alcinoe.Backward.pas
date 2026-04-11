unit Alcinoe.Backward;

interface

{$IF CompilerVersion <= 32}
function GrowCollection(OldCapacity, NewCount: NativeInt): NativeInt;
{$ENDIF}

{$IF CompilerVersion < 36.0}
function ListIndexErrorMsg(AIndex, AMaxIndex: NativeInt; const AListObjName: string): string; overload;
function ListIndexErrorMsg(AIndex, AMaxIndex: NativeInt; AListObj: TObject): string; overload;
procedure ListIndexError(AIndex, AMaxIndex: NativeInt; AListObj: TObject);
procedure RangeIndexError(AIndex, AMaxIndex: NativeInt; AListObj: TObject);
{$ENDIF}

implementation

uses
  SysUtils;

{$IF CompilerVersion <= 32}
function GrowCollection(OldCapacity, NewCount: NativeInt): NativeInt;
begin
  Result := OldCapacity;
  repeat
    if Result > 64 then
      Result := (Result * 3) div 2
    else
      if Result > 8 then
        Result := Result + 16
      else
        Result := Result + 4;
    if Result < 0 then
      OutOfMemoryError;
  until Result >= NewCount;
end;
{$ENDIF}

{$IF CompilerVersion < 36.0}
resourcestring
  SListIndexError = 'List index out of bounds (%d)';
  SListIndexErrorRangeReason = '.  %s range is 0..%d';
  SListIndexErrorEmptyReason = '.  %s is empty';

function ListIndexErrorMsg(AIndex, AMaxIndex: NativeInt; const AListObjName: string): string;
begin
  Result := Format(SListIndexError, [AIndex]);
  if AMaxIndex < 0 then
    Result := Result + Format(SListIndexErrorEmptyReason, [AListObjName])
  else
    Result := Result + Format(SListIndexErrorRangeReason, [AListObjName, AMaxIndex]);
end;

function ListIndexErrorMsg(AIndex, AMaxIndex: NativeInt; AListObj: TObject): string;
var
  s: string;
begin
  if AListObj <> nil then
    s := AListObj.ClassName
  else
    s := '<nil>';
  Result := ListIndexErrorMsg(AIndex, AMaxIndex, s);
end;

procedure ListIndexError(AIndex, AMaxIndex: NativeInt; AListObj: TObject);
begin
  raise EListError.Create(ListIndexErrorMsg(AIndex, AMaxIndex, AListObj)) at ReturnAddress;
end;

procedure RangeIndexError(AIndex, AMaxIndex: NativeInt; AListObj: TObject);
begin
  raise ERangeError.Create(ListIndexErrorMsg(AIndex, AMaxIndex, AListObj)) at ReturnAddress;
end;
{$ENDIF}

end.
