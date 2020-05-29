(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_classes;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base,
  vsagps_public_sysutils;

type
(*
  THandleStream = class(TObject)
  protected
    FHandle: THandle;
  public
    constructor Create(const AHandle: THandle); virtual;
    function Read(var ABuffer; const ACount: LongWord): Longint;
    function Size: Int64; virtual; abstract;
  end;

  TFileStream = class(THandleStream)
  private
    procedure InternalCloseFile;
  public
    constructor Create(const AFileName: string; const Mode: Word); reintroduce;
    destructor Destroy; override;
    function Size: Int64; override;
  end;
*)

  EFOpenError = class(Exception);
  EThread = class(Exception);

  TNotifyEvent = procedure(Sender: TObject) of object;

  TThread = class(TObject)
  private
    FHandle: THandle;
    FThreadID: DWORD;
    FTerminated: Boolean;
    FFinished: Boolean;
    FFreeOnTerminate: Boolean;
    FOnTerminate: TNotifyEvent;
  protected
    procedure InternalCloseHandle;
    procedure Execute; virtual; abstract;
    procedure DoTerminate; //virtual;
    property Terminated: Boolean read FTerminated;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Resume;
    procedure Terminate;
    function WaitFor: LongWord;

    property FreeOnTerminate: Boolean read FFreeOnTerminate write FFreeOnTerminate;
    property Handle: THandle read FHandle;
    property ThreadID: DWORD read FThreadID;
    property OnTerminate: TNotifyEvent read FOnTerminate write FOnTerminate;
  end;

implementation

uses
  RTLConsts,
  vsagps_public_memory;

function ALLThreadProc(lpParameter: Pointer): DWORD; stdcall;
begin
  Result:=0;
  if (nil=lpParameter) then
    Exit;

  try
    if not TThread(lpParameter).Terminated then
    try
      TThread(lpParameter).Execute;
    except
    end;
  finally
    TThread(lpParameter).Terminate;
    TThread(lpParameter).DoTerminate;
    TThread(lpParameter).FFinished:=TRUE;
    if TThread(lpParameter).FFreeOnTerminate then
      TThread(lpParameter).Free;
    ExitThread(Result);
  end;
end;  

{ TFileStream }

(*
constructor TFileStream.Create(const AFileName: string; const Mode: Word);
var F: Integer;
begin
  F:=FileOpen(AFileName, Mode);
  if (F<0) then
    raise EFOpenError.CreateResFmt(Integer(@SFOpenErrorEx), [ExpandFileName(AFileName), SysErrorMessage(GetLastError)]);
  inherited Create(F);
end;

destructor TFileStream.Destroy;
begin
  InternalCloseFile;
  inherited;
end;

procedure TFileStream.InternalCloseFile;
begin
  if (0<>FHandle) then begin
    FileClose(FHandle);
    FHandle:=0;
  end;
end;

function TFileStream.Size: Int64;
begin
  if not VSAGPS_GetFileSize(FHandle, Result) then
    Result:=0;
end;

*)

{ THandleStream }

(*
constructor THandleStream.Create(const AHandle: THandle);
begin
  FHandle:=AHandle;
end;

function THandleStream.Read(var ABuffer; const ACount: LongWord): Longint;
begin
  Result := FileRead(FHandle, ABuffer, ACount);
  if Result < 0 then
    Result := 0;
end;

*)

{ TThread }

constructor TThread.Create(CreateSuspended: Boolean);
begin
  Assert(CreateSuspended, 'TThread.Create not CreateSuspended');
  FHandle:=0;
  FThreadID:=0;
  FFinished:=FALSE;
  FTerminated:=FALSE;
  FFreeOnTerminate:=FALSE;
  FOnTerminate:=nil;
end;

destructor TThread.Destroy;
begin
  if (0<>FThreadID) and (not FFinished) then
  begin
    Terminate;
    WaitFor;
  end;
  InternalCloseHandle;
  inherited;
end;

procedure TThread.DoTerminate;
begin
  if Assigned(FOnTerminate) then
    FOnTerminate(Self);
end;

procedure TThread.InternalCloseHandle;
begin
  if (0<>FHandle) then begin
    CloseHandle(FHandle);
    FHandle:=0;
  end;
end;

procedure TThread.Resume;
begin
  if (0=FHandle) then begin
    // create thread
    FHandle := CreateThread(nil, 0, @ALLThreadProc, Pointer(Self), CREATE_SUSPENDED, FThreadID);
    if (0=FHandle) then
      raise EThread.CreateResFmt(Integer(@SThreadCreateError), [SysErrorMessage(GetLastError)]);
  end;
  ResumeThread(FHandle);
end;

procedure TThread.Terminate;
begin
  FTerminated:=TRUE;
end;

function TThread.WaitFor: LongWord;
var dwTicks: DWORD;
begin
  if (0<>FHandle) then
  repeat
    Terminate;
    dwTicks:=GetTickCount;
    if (0=FHandle) then begin
      // killed
      Result:=0;
      Exit;
    end else if GetExitCodeThread(FHandle, Result) then begin
      if (STILL_ACTIVE=Result) then begin
        // running
        Sleep(100);
        Sleep(0);
        // check
        if GetTickCount>(dwTicks+$2000) then // 8192
          if (FHandle<>0) then begin
            TerminateThread(FHandle, 0);
            Exit;
          end;
      end else begin
        // finished
        Exit;
      end;
    end else begin
      // error
      Result:=0;
      Exit;
    end;
  until FALSE;
end;

end.
