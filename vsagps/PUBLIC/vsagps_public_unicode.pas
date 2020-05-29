(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_unicode;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_sysutils;


function IsPathDelimiterW(const APath: WideString; Index: Integer): Boolean;

function StrScanW(const Src: PWideChar; Chr: WideChar): PWideChar;

function LastDelimiterW(const ADelimiters, ASource: WideString): Integer;

function ExcludeTrailingPathDelimiterW(const APath: WideString): WideString;
  
function DirectoryExistsW(const ADirectory: WideString): Boolean;

function ExtractFilePathW(const AFileName: WideString): WideString;

function CreateDirW(const ADir: WideString): Boolean;

function ForceDirectoriesW(const ADir: WideString): Boolean;

function ExtractFileExtW(const AFileName: WideString): WideString;

function ExtractFileNameW(const AFileName: WideString): WideString;

implementation

function IsPathDelimiterW(const APath: WideString; Index: Integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(APath)) and (APath[Index] = PathDelim);
end;

function StrScanW(const Src: PWideChar; Chr: WideChar): PWideChar;
begin
  Result := Src;
  while (Result^ <> Chr) do begin
    if Result^ = #0 then
    begin
      Result := nil;
      Exit;
    end;
    Inc(Result);
  end;
end;

function LastDelimiterW(const ADelimiters, ASource: WideString): Integer;
var p: PWideChar;
begin
  Result := Length(ASource);
  p := PWideChar(ADelimiters);
  while Result > 0 do
  begin
    if (ASource[Result] <> #0) and (StrScanW(p, ASource[Result]) <> nil) then
      Exit;
    Dec(Result);
  end;
end;

function ExcludeTrailingPathDelimiterW(const APath: WideString): WideString;
begin
  Result := APath;
  if IsPathDelimiterW(Result, Length(Result)) then
    SetLength(Result, Length(Result)-1);
end;

function DirectoryExistsW(const ADirectory: WideString): Boolean;
var res: LongInt;
begin
  res := GetFileAttributesW(PWideChar(ADirectory));
  Result := (res <> -1) and (FILE_ATTRIBUTE_DIRECTORY and res <> 0);
end;

function ExtractFilePathW(const AFileName: WideString): WideString;
var i: Integer;
begin
  i := LastDelimiterW(PathDelim + DriveDelim, AFileName);
  Result := Copy(AFileName, 1, i);
end;

function CreateDirW(const ADir: WideString): Boolean;
begin
  Result := CreateDirectoryW(PWideChar(ADir), nil);
end;

function ForceDirectoriesW(const ADir: WideString): Boolean;
var VDir, VExtDir: WideString;
begin
  Result := TRUE;
  VDir := ExcludeTrailingPathDelimiterW(ADir);
  if (Length(VDir) < 3) or DirectoryExistsW(VDir) then
    Exit;
  VExtDir := ExtractFilePathW(VDir);
  if (VExtDir = VDir) then
    Exit;
  Result := ForceDirectoriesW(VExtDir);
  if Result then
    Result := CreateDirW(VDir);
end;

function ExtractFileExtW(const AFileName: WideString): WideString;
var i: Integer;
begin
  i := LastDelimiterW('.' + PathDelim + DriveDelim, AFileName);
  if (i>0) and ('.'=AFileName[i]) then
    Result:=Copy(AFileName, i, MaxInt)
  else
    Result:='';
end;

function ExtractFileNameW(const AFileName: WideString): WideString;
var i: Integer;
begin
  i := LastDelimiterW(PathDelim + DriveDelim, AFileName);
  Result := Copy(AFileName, i+1, MaxInt);
end;


end.