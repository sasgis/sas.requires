(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_track_writer;
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
  vsagps_public_types,
  vsagps_public_tracks,
  vsagps_public_position,
  vsagps_public_unicode,
  vsagps_public_print,
  vsagps_public_trackpoint,
  vsagps_public_sysutils,
  vsagps_track_saver;

type
  Tvsagps_track_writer = class(Tvsagps_track_saver)
  private
    // params
    FVSAGPS_LOG_WRITER_PARAMS: PVSAGPS_LOG_WRITER_PARAMS;
    FState: Tvsagps_track_writer_state;
    procedure InternalStateNotify(const ANewState: Tvsagps_track_writer_state; const AFatal: LongBool);
  protected
    FLogPath: WideString;
    FFileHandle: array [TVSAGPS_TrackType] of THandle;
    FCurrentBaseFileNames: array [TVSAGPS_TrackType] of WideString;
  protected
    // write log buffer to file
    procedure InternalLogBuffer(const ATrackType: TVSAGPS_TrackType;
                                const ABuffer: Pointer;
                                const dwBufferSize: DWORD); override;
    // recreate log files
    procedure InternalRestartTooLongTrack(const ATrackType: TVSAGPS_TrackType); override;



    procedure InternalResetFileHandle(const ATrackType: TVSAGPS_TrackType; const AClose, ADelEmpty: Boolean);

    function InternalCreateTrackFile(const ATrackType: TVSAGPS_TrackType): Boolean;


    function InternalGetNewBaseFileName: WideString;

    function InternalCloseFiles(const ADelEmptyLogOnClose: WordBool; const AFatal: LongBool): LongBool;
    function InternalCreateTracks: LongBool;
  protected
    procedure DoResetFileHandles(const AClose, ADelEmpty: Boolean);
    procedure DoBeforeCloseFile(const ATrackType: TVSAGPS_TrackType);

    // set params externally
    function SetTrackerParams(const AParamType: Byte;
                              const AParamData: Pointer): LongBool; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function Active: LongBool; override;

    function SetALLLoggerParams(const AUserPointer: Pointer;
                                const AVSAGPS_LOG_WRITER_PARAMS: PVSAGPS_LOG_WRITER_PARAMS;
                                const AVSAGPS_GPX_WRITER_PARAMS: PVSAGPS_GPX_WRITER_PARAMS;
                                const ALogPath: PWideChar;
                                const AVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC;
                                const AVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER: PVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER): LongBool;

    property State: Tvsagps_track_writer_state read FState;

    function ExecuteLoggerCommand(const AUnitIndex: Byte;
                                  const ACommand: LongInt;
                                  const APointer: Pointer): LongBool;

    function StartTracksEx(const ATrackTypes: TVSAGPS_TrackTypes;
                           const ASuspended: LongBool;
                           const AReserved: Pointer): LongBool;

    function CloseALL: LongBool; override;

    function RestartTracks: LongBool;

    function SetPaused(const APaused: LongBool): LongBool;
  end;

implementation

uses
  vsagps_public_memory;

{ Tvsagps_track_writer }

function Tvsagps_track_writer.Active: LongBool;
begin
  // do not call inherited
  Result := (twsActive=FState);
end;

function Tvsagps_track_writer.CloseALL: LongBool;
begin
  inherited CloseALL;
  Result:=(FState in [twsActive,twsPaused,twsDestroying]);
  if Result then
    Result:=InternalCloseFiles(FVSAGPS_LOG_WRITER_PARAMS^.DelEmptyFileOnClose, FALSE);
end;

constructor Tvsagps_track_writer.Create;
begin
  inherited;

  FVSAGPS_LOG_WRITER_PARAMS:=nil;

  FState:=twsCreated;
  FActiveTrackTypes:=[];
  FLogPath:='';

  DoResetFileHandles(FALSE,FALSE);
end;

destructor Tvsagps_track_writer.Destroy;
begin
  InternalStateNotify(twsDestroying,FALSE);
  inherited;
end;

procedure Tvsagps_track_writer.DoBeforeCloseFile(const ATrackType: TVSAGPS_TrackType);
begin
  case ATrackType of
    ttGPX: begin
      DoWriteGpxClose(ATrackType);
    end;
  end;
end;

procedure Tvsagps_track_writer.DoResetFileHandles(const AClose, ADelEmpty: Boolean);
var i: TVSAGPS_TrackType;
begin
  for i := Low(TVSAGPS_TrackType) to High(TVSAGPS_TrackType) do begin
    InternalResetFileHandle(i, AClose, ADelEmpty);
  end;
end;

function Tvsagps_track_writer.InternalCloseFiles(const ADelEmptyLogOnClose: WordBool; const AFatal: LongBool): LongBool;
begin
  Result:=TRUE;
  try
    // notify (if not from destructor)
    if (twsDestroying<>FState) then begin
      InternalStateNotify(twsClosing,AFatal);
    end;
    DoResetFileHandles(TRUE, ADelEmptyLogOnClose);
  finally
    // notify (if not from destructor)
    if (twsDestroying<>FState) then begin
      InternalStateNotify(twsClosed,AFatal);
    end;
  end;
end;

function Tvsagps_track_writer.InternalCreateTrackFile(const ATrackType: TVSAGPS_TrackType): Boolean;
var
  h: THandle;
  VFileName: WideString;
begin
  Result := FALSE;

  VFileName:=FCurrentBaseFileNames[ATrackType];
  if (0=Length(VFileName)) then
    Exit;

  VFileName:=VFileName+CVSAGPS_TrackTypeExt[ATrackType]+#0;
  
  if VSAGPS_CreateFileW(@h, PWideChar(VFileName), FALSE) then begin
    Result := TRUE;
    FFileHandle[ATrackType] := h;
  end;
end;

function Tvsagps_track_writer.InternalGetNewBaseFileName: WideString;
begin
  Result := FLogPath + VSAGPS_TimeStampFileNameFormat_FromNow(FALSE);
end;

procedure Tvsagps_track_writer.InternalLogBuffer(const ATrackType: TVSAGPS_TrackType; const ABuffer: Pointer; const dwBufferSize: DWORD);
var dwWritten: Cardinal;
begin
  inherited;
  if (0<>FFileHandle[ATrackType]) and (0<dwBufferSize) and (nil<>ABuffer) then begin
    WriteFile(FFileHandle[ATrackType], ABuffer^, dwBufferSize, dwWritten, nil);
  end;
end;

procedure Tvsagps_track_writer.InternalResetFileHandle(const ATrackType: TVSAGPS_TrackType; const AClose, ADelEmpty: Boolean);
var s: WideString;
begin
  if AClose then
  if (FFileHandle[ATrackType]<>0) then
  try
    DoBeforeCloseFile(ATrackType);
    CloseHandle(FFileHandle[ATrackType]);
    if ADelEmpty then begin
      s:=FCurrentBaseFileNames[ATrackType];
      if (Length(s)>0) then begin
        // del on error
        s:=s+CVSAGPS_TrackTypeExt[ATrackType]+#00;
        if (0=FTTP_AllPointsCounter[ATrackType]) and (0=FTTP_WayPointsCounter[ATrackType]) then
        try
          DeleteFileW(PWideChar(s));
        except
        end;
      end;
    end;
  except
  end;

  FFileHandle[ATrackType]:=0;
  FCurrentBaseFileNames[ATrackType]:='';
  Internal_TTP_Init(ATrackType);
end;

procedure Tvsagps_track_writer.InternalRestartTooLongTrack(const ATrackType: TVSAGPS_TrackType);
var
  bNeedRestart: Boolean;

  procedure _CheckArrays(pCur, pMax: PVSAGPS_arr_TrackType_DWORD);
  var dwCur, dwMax: DWORD;
  begin
    dwMax:=pMax^[ATrackType];
    if (0<dwMax) then begin
      dwCur:=pCur^[ATrackType];
      if (0<dwCur) and (dwCur>=dwMax) then begin
        bNeedRestart:=TRUE;
      end;
    end;
  end;

begin
  bNeedRestart:=FALSE;

  // check by count of points
  _CheckArrays(@(FTTP_AllPointsCounter), @(FVSAGPS_LOG_WRITER_PARAMS^.RestartLogAfterPoints));

  // check by size in bytes
  if (not bNeedRestart) then
    _CheckArrays(@(FTTP_SizeInBytes), @(FVSAGPS_LOG_WRITER_PARAMS^.RestartLogAfterBytes));

  // if restart
  if bNeedRestart then begin
    // close this track
    InternalResetFileHandle(ATrackType, TRUE, FVSAGPS_LOG_WRITER_PARAMS^.DelEmptyFileOnClose);
    try
      // make new filename
      FCurrentBaseFileNames[ATrackType]:=InternalGetNewBaseFileName;
      // open new
      if not InternalCreateTrackFile(ATrackType) then
        Abort;
    except
      // failed
      InternalResetFileHandle(ATrackType, TRUE, TRUE);
    end;
  end;
end;

function Tvsagps_track_writer.InternalCreateTracks: LongBool;
var
  i: TVSAGPS_TrackType;
  VALLBaseFileNames: WideString;
begin
  Result:=FALSE;

  if (FState in [twsActive,twsPaused,twsDestroying]) then
    Exit;

  InternalStateNotify(twsStarting,FALSE);
  
{$if defined(VSAGPS_USE_UNICODE)}
  ForceDirectoriesW(FLogPath);
{$else}
  ForceDirectories(FLogPath);
{$ifend}

  // base name for all files
  VALLBaseFileNames := InternalGetNewBaseFileName;

  try
    // open new
    for i := Low(i) to High(i) do
    if  (i in FActiveTrackTypes) then begin
      // set filename
      FCurrentBaseFileNames[i] := VALLBaseFileNames;
      // try to create file
      if (not InternalCreateTrackFile(i)) then
        Abort;
      Result := TRUE;
    end;

    InternalStateNotify(twsActive,FALSE);
  except
    //Result := FALSE;
    InternalCloseFiles(TRUE, TRUE);
    raise;
  end;
end;

procedure Tvsagps_track_writer.InternalStateNotify(const ANewState: Tvsagps_track_writer_state; const AFatal: LongBool);
begin
  FState:=ANewState;
  if (nil<>FVSAGPS_LOG_WRITER_PARAMS) then
  if Assigned(FVSAGPS_LOG_WRITER_PARAMS^.pLoggerStateChangedProc) then
  try
    FVSAGPS_LOG_WRITER_PARAMS^.pLoggerStateChangedProc(UserPointer, Self, FState, AFatal);
  except
  end;
end;

function Tvsagps_track_writer.ExecuteLoggerCommand(const AUnitIndex: Byte;
                                                   const ACommand: LongInt;
                                                   const APointer: Pointer): LongBool;
begin
  Result:=FALSE;
  
  // set marker to write local time to log
  if (gpsc_LocalTimeChanged=ACommand) and (nil<>VSAGPS_GPX_WRITER_PARAMS) then
    if (0<>VSAGPS_GPX_WRITER_PARAMS^.btUse_Predefined_Extensions[geSASGIS]) then begin
      FWriteSasxLocalTime:=TRUE;
      Result:=TRUE;
    end;

  // save internal file name created in EXE
  if (gpsc_WriteFileLinkToLog=ACommand) and (nil<>APointer) and (nil<>VSAGPS_GPX_WRITER_PARAMS) then
    if (0<>VSAGPS_GPX_WRITER_PARAMS^.btUse_Predefined_Extensions[geSASGIS]) then begin
      FExecuteGPSCmd_WaypointData.sz_sasx_file_name:=VSAGPS_AllocPCharByPChar(PExecuteGPSCmd_WaypointData(APointer)^.sz_sasx_file_name, TRUE);
      Result:=TRUE;
    end;
    
  // close and create new
  if (gpsc_RestartTrackLogs=ACommand) and (nil<>FVSAGPS_LOG_WRITER_PARAMS) then begin
    Result:=RestartTracks;
  end;
end;

function Tvsagps_track_writer.RestartTracks: LongBool;
begin
  LockCS;
  try
    InternalCloseALL;
    Result:=InternalCloseFiles(FVSAGPS_LOG_WRITER_PARAMS^.DelEmptyFileOnClose, FALSE);
    if Result then
      Result:=InternalCreateTracks;
  finally
    UnlockCS;
  end;
end;

function Tvsagps_track_writer.SetALLLoggerParams(
  const AUserPointer: Pointer;
  const AVSAGPS_LOG_WRITER_PARAMS: PVSAGPS_LOG_WRITER_PARAMS;
  const AVSAGPS_GPX_WRITER_PARAMS: PVSAGPS_GPX_WRITER_PARAMS;
  const ALogPath: PWideChar;
  const AVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC;
  const AVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER: PVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER): LongBool;
begin
  Result:=FALSE;
  LockCS;
  try
    if (FState in [twsCreated,twsClosed]) then begin
      // set params
      SetTrackerParams(stp_SetUserPointerParam, AUserPointer);
      SetTrackerParams(stp_SetGPXWriterParam, AVSAGPS_GPX_WRITER_PARAMS);
      SetTrackerParams(stp_SetCallbackFilterParam, AVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER);
      SetTrackerParams(stp_SetCallbackFuncParam, @AVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC);
      SetTrackerParams(stp_SetLogPathWParam, ALogPath);
      SetTrackerParams(stp_SetLogWriterParam, AVSAGPS_LOG_WRITER_PARAMS);
      // notify (proc changed?)
      InternalStateNotify(FState,FALSE);
      Result:=TRUE;
    end;
  finally
    UnlockCS;
  end;
end;

function Tvsagps_track_writer.SetPaused(const APaused: LongBool): LongBool;
begin
  Result:=FALSE;
  LockCS;
  try
    if (APaused and (twsActive=FState)) then begin
      // running->paused
      InternalStateNotify(twsPaused,FALSE);
      Result:=TRUE;
    end else if ((not APaused) and (twsPaused=FState)) then begin
      // paused->running
      InternalStateNotify(twsActive,FALSE);
      Result:=TRUE;
    end else if ((not APaused) and (twsInitialSuspended=FState)) then begin
      // create handles and run
      Result:=InternalCreateTracks;
    end;
  finally
    UnlockCS;
  end;
end;

function Tvsagps_track_writer.SetTrackerParams(const AParamType: Byte;
                                               const AParamData: Pointer): LongBool;
begin
  Result := inherited SetTrackerParams(AParamType, AParamData);

  case AParamType of
    stp_SetLogPathWParam: begin
      FLogPath := SafeSetStringP(PWideChar(AParamData));
    end;
    stp_SetLogWriterParam: begin
      FVSAGPS_LOG_WRITER_PARAMS:=AParamData;
    end;
  end;
end;

function Tvsagps_track_writer.StartTracksEx(const ATrackTypes: TVSAGPS_TrackTypes;
                                            const ASuspended: LongBool;
                                            const AReserved: Pointer): LongBool;
var
  prev_state: Tvsagps_track_writer_state;
begin
  Result := FALSE;

  if (not (FState in [twsCreated,twsClosed])) then
    Exit;
  if ([]=ATrackTypes) then
    Exit;
  if (nil=FVSAGPS_LOG_WRITER_PARAMS) then
    Exit;
  if (nil=VSAGPS_GPX_WRITER_PARAMS) then
    Exit;
  if (0=Length(FLogPath)) then
    Exit;

  LockCS;
  try
    prev_state:=FState;
    
    // close all
    InternalCloseALL;
    InternalCloseFiles(FVSAGPS_LOG_WRITER_PARAMS^.DelEmptyFileOnClose, FALSE);

    FActiveTrackTypes:=ATrackTypes;

    if (twsCreated=prev_state) and ASuspended then begin
      // suspended
      InternalStateNotify(twsInitialSuspended,FALSE);
      Result:=TRUE;
    end else if (not ASuspended) then begin
      // starting
      Result := InternalCreateTracks;
    end;
  finally
    UnlockCS;
  end;
end;

end.
