(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
library VSAGPS;
(*
*)

{$I vsagps_defines.inc}

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  // vsagps_public_dll,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_events,
  vsagps_public_position,
  vsagps_public_device,
  vsagps_public_tracks,
  vsagps_public_trackpoint,
  vsagps_public_unit_info,
  vsagps_public_sysutils,
  vsagps_public_version,
  vsagps_public_memory,
  vsagps_object,
  vsagps_track_writer,
  vsagps_track_saver,
  vsagps_com_checker;

{$R *.res}

function VSAGPS_Create(const AUserPointer: Pointer;
                       const AGPSStateProc: TVSAGPS_GPSStateChanged_DLL_Proc;
                       const AGPSTimeoutProc: TVSAGPS_GPSTimeout_DLL_Proc
                       ): TVSAGPS_HANDLE; stdcall;
var
  obj: Tvsagps_object;
begin
  obj:=nil;
  try
    obj:=Tvsagps_object.Create;
    obj.ALLDeviceUserPointer:=AUserPointer;
    obj.OnGPSStateChanged:=AGPSStateProc;
    obj.OnGPSTimeout:=AGPSTimeoutProc;
    Result:=TVSAGPS_HANDLE(Pointer(obj));
  except
    if (nil<>obj) then
    try
      obj.Free;
    except
    end;
    Result:=nil;
  end;
end;

procedure VSAGPS_Destroy(AVSAGPS_HANDLE: TVSAGPS_HANDLE); stdcall;
begin
  try
    if (nil<>AVSAGPS_HANDLE) then
      TObject(Pointer(AVSAGPS_HANDLE)).Free;
  except
  end;
end;

function VSAGPS_Connect(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                        const AGPSDevType: DWORD;
                        const AGPSDevName: PAnsiChar;
                        const AFileSource: PWideChar;
                        const AALLDevParams: PVSAGPS_ALL_DEVICE_PARAMS;
                        const ANewDevParams: PVSAGPS_SINGLE_DEVICE_PARAMS;
                        const AUNIT_INFO_Changed: TVSAGPS_UNIT_INFO_DLL_Proc;
                        const AUnitIndexOut: PByte;
                        const AReserved: PDWORD): LongBool; stdcall;
var sDevName: AnsiString;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      sDevName := SafeSetStringP(AGPSDevName);
      Result:=(Tvsagps_object(Pointer(AVSAGPS_HANDLE)).GPSConnect(AGPSDevType,
                                                                  sDevName,
                                                                  AFileSource,
                                                                  AALLDevParams,
                                                                  ANewDevParams,
                                                                  AUNIT_INFO_Changed,
                                                                  AUnitIndexOut,
                                                                  AReserved)<>FALSE);
    end;
  except
  end;
end;

function VSAGPS_Disconnect(const AVSAGPS_HANDLE: TVSAGPS_HANDLE): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=(Tvsagps_object(Pointer(AVSAGPS_HANDLE)).GPSDisconnect<>FALSE);
    end;
  except
  end;
end;

procedure VSAGPS_ExecuteGPSCommand_OnUnits(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                           const AMaskUnitIndex: DWORD;
                                           const ACommand: LongInt;
                                           const APointer: Pointer); stdcall;
begin
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Tvsagps_object(Pointer(AVSAGPS_HANDLE)).Execute_GPSCommand_OnUnits(AMaskUnitIndex, ACommand, APointer);
    end;
  except
  end;
end;

procedure VSAGPS_ExecuteGPSCommand_OnUnit(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                          const AUnitIndex: Byte;
                                          const ACommand: LongInt;
                                          const APointer: Pointer); stdcall;
begin
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Tvsagps_object(Pointer(AVSAGPS_HANDLE)).Execute_GPSCommand_OnUnit(AUnitIndex, ACommand, APointer);
    end;
  except
  end;
end;

function VSAGPS_GPSState(const AVSAGPS_HANDLE: TVSAGPS_HANDLE): Tvsagps_GPSState; stdcall;
begin
  Result:=gs_DoneDisconnected;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).GPSState;
    end;
  except
  end;
end;

function VSAGPS_SerializePacket(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                const AUnitIndex: Byte;
                                const APacket: Pointer;
                                out ASerializedSize: DWORD;
                                const AReserved: PDWORD): Pointer; stdcall;
begin
  Result:=nil;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).SerializePacket(AUnitIndex, APacket, ASerializedSize, AReserved);
    end;
  except
  end;
end;

type
  TCOMCheckerObjectStub = class(TCOMCheckerObject)
  private
    FUserPointer: Pointer;
    FPendingProc: TCOMAutodetect_DLL_Proc;
    FFinishedProc: TCOMAutodetect_DLL_Proc;
    FBufferReadProc: TCOMCheckerRead_DLL_Proc;
  protected
    procedure SelfOnThreadPending(Sender: TObject; AThread: TObject);
    procedure SelfOnThreadFinished(Sender: TObject; AThread: TObject);
    procedure SelfOnCOMReadBuffer(Sender: TObject;
                                  const ABuffer: PAnsiChar;
                                  const ALength: DWORD;
                                  pBufferOK: PLongBool);
  end;

{ TCOMCheckerObjectStub }

procedure TCOMCheckerObjectStub.SelfOnCOMReadBuffer(Sender: TObject;
                                                    const ABuffer: PAnsiChar;
                                                    const ALength: DWORD;
                                                    pBufferOK: PLongBool);
begin
  if Assigned(FBufferReadProc) then
    FBufferReadProc(FUserPointer, ABuffer, ALength, pBufferOK);
end;

procedure TCOMCheckerObjectStub.SelfOnThreadFinished(Sender, AThread: TObject);
begin
  if Assigned(FFinishedProc) then
    FFinishedProc(FUserPointer, AThread);
end;

procedure TCOMCheckerObjectStub.SelfOnThreadPending(Sender, AThread: TObject);
begin
  if Assigned(FPendingProc) then
    FPendingProc(FUserPointer, AThread);
end;

function VSAGPS_AutodetectCOM(const ADevFlags: DWORD;
                              const AUserPointer: Pointer;
                              const AConnectTimeoutSec: DWORD;
                              const AForKeepFirstOpenedHandle: LongBool;
                              const APendingProc: TCOMAutodetect_DLL_Proc;
                              const AFinishedProc: TCOMAutodetect_DLL_Proc;
                              const ABufferReadProc: TCOMCheckerRead_DLL_Proc): SmallInt; stdcall;
var
  obj: TCOMCheckerObjectStub;
  bCancelled: Boolean;
begin
  try
    obj:=TCOMCheckerObjectStub.Create;
    try
      obj.FUserPointer:=AUserPointer;

      obj.SetFullConnectionTimeout(AConnectTimeoutSec, AForKeepFirstOpenedHandle);

      obj.FPendingProc:=APendingProc;
      obj.OnThreadPending:=obj.SelfOnThreadPending;

      obj.FFinishedProc:=AFinishedProc;
      obj.OnThreadFinished:=obj.SelfOnThreadFinished;

      obj.FBufferReadProc:=ABufferReadProc;
      obj.OnCOMReadBuffer:=obj.SelfOnCOMReadBuffer;

      Result:=obj.EnumExecute(nil, bCancelled, ADevFlags, FALSE);
    finally
      obj.Free;
    end;
  except
    Result:=-1;
  end;
end;

function VSAGPS_GetSupportedProtocols(
  const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
  const AUnitIndex: Byte;
  const AReserved: PDWORD;
  out AIsWide: Boolean
): PAnsiChar; stdcall;
begin
  Result:=nil;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).AllocSupportedProtocols(AUnitIndex, AIsWide);
    end;
  except
  end;
end;

function VSAGPS_GetDeviceInfo(
  const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
  const AUnitIndex: Byte;
  const AReserved: PDWORD;
  out AIsWide: Boolean
): PAnsiChar; stdcall;
begin
  Result:=nil;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).AllocDeviceInfo(AUnitIndex, AIsWide);
    end;
  except
  end;
end;

function VSAGPS_GetUnitInfo(
  const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
  const AUnitIndex: Byte;
  const AReserved: PDWORD;
  out AIsWide: Boolean
): PAnsiChar; stdcall;
begin
  Result:=nil;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).AllocUnitInfo(AUnitIndex, AIsWide);
    end;
  except
  end;
end;

function VSAGPS_Check_Version(const p: PVSAGPS_VERSION): LongBool; stdcall;
var t: TVSAGPS_VERSION;
begin
  if (nil=p) or (sizeof(t)<>p^.wSize) then
    Result:=FALSE
  else begin
    VSAGPS_Fill_Version(@t);
    Result:=(CompareMem(p, @t, sizeof(t))<>FALSE);
  end;
end;

function VSAGPS_SendPacket_ToUnit(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                  const AUnitIndex: Byte;
                                  const APacketBuffer: Pointer;
                                  const APacketSize: DWORD;
                                  const AFlags: DWORD;
                                  const AReserved: PDWORD): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).SendPacket_ToUnit(AUnitIndex,
                                                                        APacketBuffer,
                                                                        APacketSize,
                                                                        AFlags,
                                                                        AReserved);
    end;
  except
  end;
end;

function VSAGPS_GetDeviceStatus(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                const AUnitIndex: Byte;
                                const AGPSDevTypePtr: PDWORD;
                                const AStatePtr: Pvsagps_GPSState): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_HANDLE) then begin
      Result:=Tvsagps_object(Pointer(AVSAGPS_HANDLE)).GetDeviceStatus_ForUnit(AUnitIndex, AGPSDevTypePtr, AStatePtr);
    end;
  except
  end;
end;

function VSAGPS_MakeLogger(const AUserPointer: Pointer;
                           const AVSAGPS_LOG_WRITER_PARAMS: PVSAGPS_LOG_WRITER_PARAMS;
                           const AVSAGPS_GPX_WRITER_PARAMS: PVSAGPS_GPX_WRITER_PARAMS;
                           const ALogPath: PWideChar;
                           const AVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC;
                           const AVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER: PVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER): TVSAGPS_HANDLE; stdcall;
var obj: Tvsagps_track_writer;
begin
  obj:=nil;
  try
    obj:=Tvsagps_track_writer.Create;
    obj.SetALLLoggerParams(AUserPointer,
                           AVSAGPS_LOG_WRITER_PARAMS,
                           AVSAGPS_GPX_WRITER_PARAMS,
                           ALogPath,
                           AVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC,
                           AVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER);
    Result:=TVSAGPS_HANDLE(Pointer(obj));
  except
    if (nil<>obj) then
    try
      obj.Free;
    except
    end;
    Result:=nil;
  end;
end;

function VSAGPS_StartLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                            const ATrackTypes: DWORD;
                            const ASuspended: LongBool;
                            const pReserved: Pointer): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Result:=Tvsagps_track_writer(Pointer(AVSAGPS_LOGGER)).StartTracksEx(DWORD_to_TVSAGPS_TrackTypes(ATrackTypes), ASuspended, pReserved);
    end;
  except
  end;
end;

function VSAGPS_ActiveLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Result:=Tvsagps_track_saver(Pointer(AVSAGPS_LOGGER)).Active;
    end;
  except
  end;
end;

function VSAGPS_CloseLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Result:=Tvsagps_track_saver(Pointer(AVSAGPS_LOGGER)).CloseALL;
    end;
  except
  end;
end;

function VSAGPS_AddLoggerTrackPoint(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                    const pATP: Pvsagps_AddTrackPoint): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Tvsagps_track_saver(Pointer(AVSAGPS_LOGGER)).AddTrackPoint(pATP);
      Result:=TRUE;
    end;
  except
  end;
end;

function VSAGPS_AddLoggerWayPoint(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                  const pATP: Pvsagps_AddTrackPoint): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Tvsagps_track_saver(Pointer(AVSAGPS_LOGGER)).AddWayPoint(pATP);
      Result:=TRUE;
    end;
  except
  end;
end;

function VSAGPS_AddLoggerPacket(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                const ABuffer: PAnsiChar;
                                const ABufferLen: DWORD;
                                const pReserved: PDWORD): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Tvsagps_track_saver(Pointer(AVSAGPS_LOGGER)).AddPacket(ABuffer, ABufferLen, pReserved);
      Result:=TRUE;
    end;
  except
  end;
end;

function VSAGPS_ExecuteLoggerCommand(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                     const AUnitIndex: Byte;
                                     const ACommand: LongInt;
                                     const APointer: Pointer): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Result:=Tvsagps_track_writer(Pointer(AVSAGPS_LOGGER)).ExecuteLoggerCommand(AUnitIndex, ACommand, APointer);
    end;
  except
  end;
end;

function VSAGPS_SetPausedLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                const APaused: LongBool): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Result:=Tvsagps_track_writer(Pointer(AVSAGPS_LOGGER)).SetPaused(APaused);
    end;
  except
  end;
end;

function VSAGPS_RestartLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE): LongBool; stdcall;
begin
  Result:=FALSE;
  try
    if (nil<>AVSAGPS_LOGGER) then begin
      Result:=Tvsagps_track_writer(Pointer(AVSAGPS_LOGGER)).RestartTracks;
    end;
  except
  end;
end;

exports
  VSAGPS_GetMem,
  VSAGPS_FreeMem,

  VSAGPS_Create,
  VSAGPS_Destroy,

  VSAGPS_Connect,
  VSAGPS_Disconnect,

  VSAGPS_ExecuteGPSCommand_OnUnits,
  VSAGPS_ExecuteGPSCommand_OnUnit,

  VSAGPS_GPSState,

  VSAGPS_SerializePacket,

  VSAGPS_AutodetectCOM,

  VSAGPS_GetSupportedProtocols,
  VSAGPS_GetDeviceInfo,
  VSAGPS_GetUnitInfo,

  VSAGPS_Check_Version,

  VSAGPS_SendPacket_ToUnit,

  VSAGPS_GetDeviceStatus,

  VSAGPS_MakeLogger,
  VSAGPS_StartLogger,
  VSAGPS_ActiveLogger,
  VSAGPS_CloseLogger,

  VSAGPS_AddLoggerTrackPoint,
  VSAGPS_AddLoggerWayPoint,
  VSAGPS_AddLoggerPacket,

  VSAGPS_ExecuteLoggerCommand,

  VSAGPS_SetPausedLogger,
  VSAGPS_RestartLogger;
  
begin
end.
