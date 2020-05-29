(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_units;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
{$if defined(USE_SIMPLE_CLASSES)}
  vsagps_classes,
{$else}
  Classes,
{$ifend}
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_device,
  vsagps_device_base,
  vsagps_queue;

type
  TVSAGPS_UNIT = packed record
    dwUniqueIndex: DWORD; // increment even on reconnect
    objDevice: Tvsagps_device_base; // device object
    pDevParams: PVSAGPS_SINGLE_DEVICE_PARAMS; // special params (NIL allowed)
    eDevState: Tvsagps_GPSState; // state
    dwStartPendingTicks: DWORD; // start work with tread
    dwLastPacketTicks: DWORD; // timestamp for last packet recv
    // requests
    reqGPSCommand_ResetDGPS: Boolean;
    function AllowGetDevInfo: Boolean;
    function IsEmpty: Boolean;
    function IsRequestingState: Boolean;
  end;
  PVSAGPS_UNIT = ^TVSAGPS_UNIT;

  TVSAGPS_UNITS =  class;

  Tvsagps_Thread = class(TThread)
  protected
    FGPSObject: TVSAGPS_UNITS;
    FGPSRunning: Boolean;
    procedure PrepareToKill;
    procedure KillNow;
    procedure DoTerminateUnSync;
  public
    property GPSObject: TVSAGPS_UNITS read FGPSObject write FGPSObject;
    property GPSRunning: Boolean read FGPSRunning write FGPSRunning;
    property Terminated;
  end;
  Pvsagps_Thread = ^Tvsagps_Thread;

  Tvsagps_Device_Thread = class(Tvsagps_Thread)
  protected
    procedure Execute; override;
  end;

  TVSAGPS_UNITS = class(TObject)
  private
    FNewUniqueIndex: DWORD;
    //FCS_RunTime: TRTLCriticalSection;
    FCS_State: TRTLCriticalSection;
    FItems: array [0..cUnitIndex_Max] of TVSAGPS_UNIT;
    FOnGPSStateChanged: TVSAGPS_GPSStateChanged_DLL_Proc;
    FOnGPSTimeout: TVSAGPS_GPSTimeout_DLL_Proc;
    function GetItems(const AUnitIndex: Byte): PVSAGPS_UNIT;
    function GetGPSState: Tvsagps_GPSState;
    function InternalCalcCurrentState: Tvsagps_GPSState;
  protected
    FALLDeviceUserPointer: Pointer;
    FALLDeviceParams: PVSAGPS_ALL_DEVICE_PARAMS;
    FDeviceThread: Tvsagps_Device_Thread; // single thread: connect and disconnect devices
    FCS_CloseHandle: TRTLCriticalSection;
    FALLState: Tvsagps_GPSState; // generic state
    procedure InternalChangeALLGPSState(const ANewState: Tvsagps_GPSState;
                                        const AUseLock: Boolean);
    procedure DoInternalGPSStateChanged(const AUnitIndex: Byte;
                                        const AGPSDevType: DWORD;
                                        const ANewState: Tvsagps_GPSState);
                                        
    procedure InternalCleanupItem(const AUnitIndex: Byte);
    procedure InternalPrepareItem(const AUnitIndex: Byte);

    procedure InternalExecuteGPSCommand(const AUnitIndex: Byte;
                                        const ACommand: LongInt;
                                        const APointer: Pointer);
                                        
    procedure InternalProcessUnitsRequests(const AThread: Tvsagps_Device_Thread); register;
    procedure InternalDisconnectALLItems(const AWaitFor: Boolean);

    function InternalProcessRequestForUnit(const AUnitIndex: Byte): Boolean;
    function InternalGPSDisconnect(const AInThread, AWaitFor: Boolean): Boolean;
    function InternalGetUserPointer(const AUnitIndex: Byte): Pointer;
    function InternalGetConnectionTimeoutMSec(const AUnitIndex: Byte): DWORD;
    function InternalFindNewUnitIndex: Byte;

    procedure InternalCheckOnLastDisconnected;
    procedure InternalPacketThreadLimitedWait(const APtrThread: Pvsagps_Thread);
    procedure InternalWaitRuntimeThread(const APtrThread: Pvsagps_Thread);
    procedure InternalOnDeviceThreadTerminate(Sender: TObject);
    procedure InternalTerminateRuntimeObjects; virtual;
    procedure InternalCreateRuntimeObjects; virtual;
    procedure InternalWaitRuntimeObjects; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function GPSDisconnect: Boolean;

    procedure Lock_CS_State;
    procedure Unlock_CS_State;

    procedure Lock_CS_Runtime;
    procedure Unlock_CS_Runtime;

    procedure WaitForALLState(const AStates: Tvsagps_GPSStates; const pbAbort: pBoolean);

    procedure Execute_GPSCommand_OnUnit(const AUnitIndex: Byte;
                                        const ACommand: LongInt;
                                        const APointer: Pointer);
    procedure Execute_GPSCommand_OnUnits(const AMaskUnitIndex: DWORD;
                                         const ACommand: LongInt;
                                         const APointer: Pointer);

    function AllocDeviceInfo(const AUnitIndex: Byte; out AIsWide: Boolean): Pointer;
    function AllocSupportedProtocols(const AUnitIndex: Byte; out AIsWide: Boolean): Pointer;
    function AllocUnitInfo(const AUnitIndex: Byte; out AIsWide: Boolean): Pointer;

    property ALLDeviceUserPointer: Pointer read FALLDeviceUserPointer write FALLDeviceUserPointer;

    property GPSState: Tvsagps_GPSState read GetGPSState;

    property GPSUnits[const AUnitIndex: Byte]: PVSAGPS_UNIT read GetItems;

    property OnGPSStateChanged: TVSAGPS_GPSStateChanged_DLL_Proc read FOnGPSStateChanged write FOnGPSStateChanged;
    property OnGPSTimeout: TVSAGPS_GPSTimeout_DLL_Proc read FOnGPSTimeout write FOnGPSTimeout;
  end;

  EVSAGPS_UNITS_Index_Error = class(Exception);

implementation

uses
  vsagps_public_memory,
  vsagps_public_debugstring,
  vsagps_tools;

{ TVSAGPS_UNITS }

function TVSAGPS_UNITS.AllocDeviceInfo(const AUnitIndex: Byte; out AIsWide: Boolean): Pointer;
begin
  Result := nil;
  if (AUnitIndex <= cUnitIndex_Max) then
  if (nil <> FItems[AUnitIndex].objDevice) then begin
    Lock_CS_State;
    try
      if (FItems[AUnitIndex].AllowGetDevInfo) then
      try
        Result := FItems[AUnitIndex].objDevice.AllocDeviceInfo(AIsWide);
      except
        VSAGPS_FreeAndNil_PChar(Result);
        raise;
      end;
    finally
      Unlock_CS_State;
    end;
  end;
end;

function TVSAGPS_UNITS.AllocSupportedProtocols(const AUnitIndex: Byte; out AIsWide: Boolean): Pointer;
begin
  Result := nil;
  if (AUnitIndex <= cUnitIndex_Max) then
  if (nil <> FItems[AUnitIndex].objDevice) then begin
    Lock_CS_State;
    try
      if (FItems[AUnitIndex].AllowGetDevInfo) then
      try
        Result := FItems[AUnitIndex].objDevice.AllocSupportedProtocols(AIsWide);
      except
        VSAGPS_FreeAndNil_PChar(Result);
        raise;
      end;
    finally
      Unlock_CS_State;
    end;
  end;
end;

function TVSAGPS_UNITS.AllocUnitInfo(const AUnitIndex: Byte; out AIsWide: Boolean): Pointer;
begin
  Result := nil;
  if (AUnitIndex <= cUnitIndex_Max) then
  if (nil <> FItems[AUnitIndex].objDevice) then begin
    Lock_CS_State;
    try
      if (FItems[AUnitIndex].AllowGetDevInfo) then
      try
        Result := FItems[AUnitIndex].objDevice.AllocUnitInfo(AIsWide);
      except
        VSAGPS_FreeAndNil_PChar(Result);
        raise;
      end;
    finally
      Unlock_CS_State;
    end;
  end;
end;

constructor TVSAGPS_UNITS.Create;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Create: begin');
{$ifend}

  InitializeCriticalSection(FCS_CloseHandle);
  FNewUniqueIndex:=0;
  FDeviceThread:=nil;
  FALLDeviceUserPointer:=nil;
  FALLDeviceParams:=nil;
  FALLState:=gs_DoneDisconnected;
  ZeroMemory(@FItems, sizeof(FItems));
  InitializeCriticalSection(FCS_State);
  //InitializeCriticalSection(FCS_RunTime);
  FOnGPSStateChanged:=nil;
  FOnGPSTimeout:=nil;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Create: end');
{$ifend}
end;

destructor TVSAGPS_UNITS.Destroy;
var i: Byte;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: begin');
{$ifend}

  FreeAndNil(FDeviceThread);
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: cleanup');
{$ifend}

  // cleanup all items
  for i := 0 to cUnitIndex_Max do
  try
    if Assigned(FItems[i].objDevice) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: kill object');
{$ifend}
      FreeAndNil(FItems[i].objDevice);
    end;
  except
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: delete sections');
{$ifend}

  // kill
  DeleteCriticalSection(FCS_State);
  DeleteCriticalSection(FCS_CloseHandle);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: inherited');
{$ifend}

  inherited;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: delete runtime');
{$ifend}

  //DeleteCriticalSection(FCS_RunTime);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.DoInternalGPSStateChanged(const AUnitIndex: Byte;
                                                  const AGPSDevType: DWORD;
                                                  const ANewState: Tvsagps_GPSState);
var p: Pointer;
begin
  if Assigned(FOnGPSStateChanged) then begin
    // get user pointer
    if (AUnitIndex<=cUnitIndex_Max) and (FItems[AUnitIndex].pDevParams<>nil) then
      p:=FItems[AUnitIndex].pDevParams^.pUserPointer
    else
      p:=FALLDeviceUserPointer;
    // call
    FOnGPSStateChanged(p, AUnitIndex, AGPSDevType, ANewState);
  end;
end;

procedure TVSAGPS_UNITS.Execute_GPSCommand_OnUnit(const AUnitIndex: Byte;
                                                  const ACommand: LongInt;
                                                  const APointer: Pointer);
begin
  Lock_CS_State;
  try
    if (AUnitIndex <= cUnitIndex_Max) then
      InternalExecuteGPSCommand(AUnitIndex, ACommand, APointer);
  finally
    Unlock_CS_State;
  end;
end;

procedure TVSAGPS_UNITS.Execute_GPSCommand_OnUnits(const AMaskUnitIndex: DWORD;
                                                   const ACommand: LongInt;
                                                   const APointer: Pointer);
var
  i: Byte;
  w: Word;
begin
  Lock_CS_State;
  try
    w:=LoWord(AMaskUnitIndex and cMaskUnitIndex_ALL);
    i:=0;
    if (0<>w) then
    repeat
      if (0 <> (w and 1)) then begin
        // do it for this unit
        InternalExecuteGPSCommand(i, ACommand, APointer);
      end;
      // next
      w := (w shr 1);
      Inc(i);
      // done for all units
      if (0=w) or (i>cUnitIndex_Max) then
        break;
    until FALSE;
  finally
    Unlock_CS_State;
  end;
end;

function TVSAGPS_UNITS.GetGPSState: Tvsagps_GPSState;
begin
  EnterCriticalSection(FCS_State);
  try
    Result:=FALLState;
  finally
    LeaveCriticalSection(FCS_State);
  end;
end;

function TVSAGPS_UNITS.GetItems(const AUnitIndex: Byte): PVSAGPS_UNIT;
begin
  if (AUnitIndex<=cUnitIndex_Max) then
    Result:=@(FItems[AUnitIndex])
  else
    raise EVSAGPS_UNITS_Index_Error.Create(IntToStr(AUnitIndex));
end;

function TVSAGPS_UNITS.GPSDisconnect: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.GPSDisconnect: begin');
{$ifend}

  Lock_CS_State;
  try
    Result:=InternalGPSDisconnect(FALSE, FALSE);
  finally
    Unlock_CS_State;
  end;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.GPSDisconnect: end');
{$ifend}
end;

function TVSAGPS_UNITS.InternalCalcCurrentState: Tvsagps_GPSState;
var
  i: Byte;
  has_connecting: Boolean;
  has_disconnecting: Boolean;
begin
  Result:=gs_DoneDisconnected;
  has_connecting:=FALSE;
  has_disconnecting:=FALSE;
  // scan
  for i := 0 to cUnitIndex_Max do begin
    case FItems[i].eDevState of
      gs_DoneConnected: begin
        // connected
        Result:=gs_DoneConnected;
        Exit;
      end;
      gs_PendingConnecting,gs_ProcessConnecting:
        has_connecting:=TRUE;
      gs_PendingDisconnecting,gs_ProcessDisconnecting:
        has_disconnecting:=TRUE;
    end;
  end;
  // no connected - check other states
  if has_connecting then
    Result:=gs_ProcessConnecting
  else if has_disconnecting then
    Result:=gs_ProcessDisconnecting;
end;

procedure TVSAGPS_UNITS.InternalChangeALLGPSState(const ANewState: Tvsagps_GPSState;
                                                  const AUseLock: Boolean);

  procedure _SetAndNotify(const new_value: Tvsagps_GPSState);
  begin
    FALLState := new_value;
    DoInternalGPSStateChanged(cUnitIndex_ALL, 0, new_value);
  end;

  procedure _Recalc;
  var new_value: Tvsagps_GPSState;
  begin
    new_value:=InternalCalcCurrentState;
    if (FALLState <> new_value) then
      _SetAndNotify(new_value);
  end;
  
begin
  if AUseLock then
    Lock_CS_State;
  try
    if (FALLState <> ANewState) then begin
      // if right order
      if GPSStateChangeCorrectly(FALLState, ANewState) then begin
        // no recalc real state
        _SetAndNotify(ANewState);
      end else begin
        // else recalc current state
        _Recalc;
      end;
    end;
  finally
    if AUseLock then
      Unlock_CS_State;
  end;
end;

procedure TVSAGPS_UNITS.InternalCheckOnLastDisconnected;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalCheckOnLastDisconnected: begin');
{$ifend}

  if (gs_DoneDisconnected=InternalCalcCurrentState) then
    InternalGPSDisconnect(TRUE, FALSE);
    
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalCheckOnLastDisconnected: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalCleanupItem(const AUnitIndex: Byte);
begin
  with FItems[AUnitIndex] do begin
    if (nil<>objDevice) then
      objDevice.Free;
    ZeroMemory(@(FItems[AUnitIndex]), sizeof(FItems[AUnitIndex]));
  end;
end;

procedure TVSAGPS_UNITS.InternalCreateRuntimeObjects;
begin
  // thread for devices
  if (nil=FDeviceThread) then begin
    FDeviceThread:=Tvsagps_Device_Thread.Create(TRUE);
    FDeviceThread.GPSObject:=Self;
    FDeviceThread.FGPSRunning:=TRUE;
    FDeviceThread.FreeOnTerminate:=TRUE;
    FDeviceThread.OnTerminate:=InternalOnDeviceThreadTerminate;
    FDeviceThread.{$IF CompilerVersion < 23}Resume{$ELSE}Start{$IFEND};
  end;
end;

procedure TVSAGPS_UNITS.InternalDisconnectALLItems(const AWaitFor: Boolean);
var
  i: Byte;
  dwTicks, dwDisconnectTimeoutMSec: DWORD;
  bNotYet: Boolean;
begin
  // disconnect all available items
  for i := 0 to cUnitIndex_Max do
  if (not (FItems[i].eDevState in [gs_ProcessDisconnecting, gs_DoneDisconnected])) then
  if (nil<>FItems[i].objDevice) then begin
    FItems[i].eDevState:=gs_ProcessDisconnecting;
    DoInternalGPSStateChanged(i, FItems[i].objDevice.GPSDeviceType, gs_ProcessDisconnecting);
    FItems[i].objDevice.Disconnect;
    Sleep(0);
  end;

  if AWaitFor then begin
    dwDisconnectTimeoutMSec:=InternalGetConnectionTimeoutMSec(cUnitIndex_ALL);
    dwTicks:=GetTickCount;
    repeat
      bNotYet:=FALSE;

      // scan devices
      for i := 0 to cUnitIndex_Max do
      if (nil<>FItems[i].objDevice) then begin
        Sleep(0);
        if (0=FItems[i].objDevice.GPSDeviceHandle) then begin
          // found disconnected - notify
          DoInternalGPSStateChanged(i, FItems[i].objDevice.GPSDeviceType, gs_DoneDisconnected);
          // set state=0, destroy device object and cleanup item
          InternalCleanupItem(i);
        end else begin
          // not yet
          if GetTickCount>dwTicks+dwDisconnectTimeoutMSec then begin
            // too long - kill
            if (nil<>FItems[i].objDevice) then begin
              FItems[i].objDevice.KillNow;
              DoInternalGPSStateChanged(i, FItems[i].objDevice.GPSDeviceType, gs_DoneDisconnected);
              InternalCleanupItem(i);
            end;
          end else begin
            // wait some more
            bNotYet:=TRUE;
          end;
        end;
      end;

      // check devices flag
      if bNotYet then
        Sleep(cWorkingThread_SimpleWait_Msec)
      else
        break;
    until FALSE;
  end;
end;

procedure TVSAGPS_UNITS.InternalExecuteGPSCommand(const AUnitIndex: Byte;
                                                  const ACommand: LongInt;
                                                  const APointer: Pointer);
begin
  with FItems[AUnitIndex] do begin
    if (nil <> objDevice) then
    if (0 <> objDevice.GPSDeviceHandle) then begin
      // switch by command
      if (gpsc_Reset_DGPS = ACommand) then begin
        // do it here
        reqGPSCommand_ResetDGPS:=TRUE;
      end else begin
        // do it on device level
        objDevice.ExecuteGPSCommand(ACommand, APointer);
      end;
    end;
  end;
end;

function TVSAGPS_UNITS.InternalFindNewUnitIndex: Byte;
begin
  Result:=0;
  while (Result<=cUnitIndex_Max) do begin
    // check params for empty entry
    if FItems[Result].IsEmpty then
      Exit;
    Inc(Result);
  end;
  // no places available
  Result:=cUnitIndex_ALL;
end;

function TVSAGPS_UNITS.InternalGetConnectionTimeoutMSec(const AUnitIndex: Byte): DWORD;
begin
  // connection timeout
  if (AUnitIndex<=cUnitIndex_Max) and (nil<>FItems[AUnitIndex].pDevParams) then
    Result:=FItems[AUnitIndex].pDevParams^.wConnectionTimeoutSec
  else if (nil<>FALLDeviceParams) then
    Result:=FALLDeviceParams^.wConnectionTimeoutSec
  else
    Result:=cWorkingThread_Connection_Timeout_Sec;
  Result:=Result*1000;
end;

function TVSAGPS_UNITS.InternalGetUserPointer(const AUnitIndex: Byte): Pointer;
begin
  if (AUnitIndex<=cUnitIndex_Max) then
  if (FItems[AUnitIndex].pDevParams<>nil) then begin
    Result:=FItems[AUnitIndex].pDevParams^.pUserPointer;
    Exit;
  end;
  Result:=FALLDeviceUserPointer;
end;

function TVSAGPS_UNITS.InternalGPSDisconnect(const AInThread, AWaitFor: Boolean): Boolean;
var VOldState: Tvsagps_GPSState;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: begin');
{$ifend}

  Result:=FALSE;

  // current state
  VOldState:=FALLState; // cs_state already locked

  // if common call to disconnect and still disconnecting - ignore this (disconnecting in process)
  if (not AWaitFor) and (not AInThread) and (VOldState in [gs_PendingDisconnecting,gs_ProcessDisconnecting]) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: pending');
{$ifend}
    Exit;
  end;

  if (gs_DoneDisconnected <> VOldState) then begin
    // dont send from destructor
    if (not AWaitFor) then begin
      InternalChangeALLGPSState(gs_ProcessDisconnecting, FALSE);
    end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: terminate');
{$ifend}

    // terminate threads
    InternalTerminateRuntimeObjects;

    if AWaitFor then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: waiting');
{$ifend}

      // if any thread is waiting on cs - unlock to finish
      Unlock_CS_State;
      try
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: wait for runtime');
{$ifend}

        InternalWaitRuntimeObjects;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: ok for runtime');
{$ifend}
      finally
        Lock_CS_State;
      end;

      Sleep(0);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: wait for all');
{$ifend}

      // wait for all devices
      InternalDisconnectALLItems(AWaitFor);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: ok for all');
{$ifend}
    end;

    // ok
    Result:=TRUE;
  end;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalGPSDisconnect: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalOnDeviceThreadTerminate(Sender: TObject);
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalOnDeviceThreadTerminate: begin');
{$ifend}

  // ALL Device CLOSED
  FDeviceThread:=nil;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalOnDeviceThreadTerminate: disconnect');
{$ifend}

  InternalChangeALLGPSState(gs_DoneDisconnected, TRUE);
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalOnDeviceThreadTerminate: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalPacketThreadLimitedWait(const APtrThread: Pvsagps_Thread);
var i: Byte;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalPacketThreadLimitedWait: begin');
{$ifend}

  try
    i := 8;
    repeat
      Sleep(0);

      if (i=0) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalPacketThreadLimitedWait: zero');
{$ifend}
        break;
      end;

      // if destroyed - go
      if (nil=APtrThread^) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalPacketThreadLimitedWait: destroyed');
{$ifend}
        Exit;
      end;
        
      Sleep(cWorkingThread_Devices_Delay_MSec);

      Dec(i);
    until FALSE;
  except
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalPacketThreadLimitedWait: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalPrepareItem(const AUnitIndex: Byte);
begin
  with FItems[AUnitIndex] do begin
    dwUniqueIndex:=FNewUniqueIndex;
    Inc(FNewUniqueIndex);
    dwLastPacketTicks:=GetTickCount;
  end;
end;

function TVSAGPS_UNITS.InternalProcessRequestForUnit(const AUnitIndex: Byte): Boolean;
begin
  // cs_state is locked
  Result:=FALSE;

  with FItems[AUnitIndex] do
  if IsRequestingState then
  case eDevState of
    gs_PendingConnecting: begin
      // start connecting process
      if (gs_DoneDisconnected=FALLState) then
        InternalChangeALLGPSState(gs_ProcessConnecting, FALSE);
      dwStartPendingTicks:=GetTickCount;
      eDevState:=gs_ProcessConnecting;
      DoInternalGPSStateChanged(AUnitIndex, objDevice.GPSDeviceType, gs_ProcessConnecting);
      objDevice.Connect;
      Result:=TRUE;
    end;
    gs_PendingDisconnecting: begin
      // start disconnecting process
      if (gs_ProcessDisconnecting<>FALLState) then
        InternalChangeALLGPSState(gs_ProcessDisconnecting, FALSE);
      dwStartPendingTicks:=GetTickCount;
      eDevState:=gs_ProcessDisconnecting;
      DoInternalGPSStateChanged(AUnitIndex, objDevice.GPSDeviceType, gs_ProcessDisconnecting);
      objDevice.Disconnect;
      Result:=TRUE;
    end;
    gs_ProcessConnecting: begin
      // in connecting process - check status (error or connected) and timeout
      // if error
      if (0<>objDevice.FinishReason) then begin
        // start disconnecting
        eDevState:=gs_PendingDisconnecting;
        Result:=TRUE;
      end else if (0<>objDevice.GPSDeviceHandle) then begin
        // success
        eDevState:=gs_DoneConnected;
        dwStartPendingTicks:=0;
        // notify about global state (first connect)
        if (gs_ProcessConnecting=FALLState) then
          InternalChangeALLGPSState(gs_DoneConnected, FALSE);
        // notify about this unit
        DoInternalGPSStateChanged(AUnitIndex, objDevice.GPSDeviceType, gs_DoneConnected);
        Result:=TRUE;
      end else if (GetTickCount > dwStartPendingTicks + InternalGetConnectionTimeoutMSec(AUnitIndex)) then begin
        // too long to connect - start disconnecting
        eDevState:=gs_PendingDisconnecting;
        Result:=TRUE;
      end;
    end;
    gs_ProcessDisconnecting: begin
      // in disconnecting process - check status (disconnected) and timeout
      if (0=objDevice.GPSDeviceHandle) then begin
        // closed
        DoInternalGPSStateChanged(AUnitIndex, objDevice.GPSDeviceType, gs_DoneDisconnected);
        InternalCleanupItem(AUnitIndex); // = set to gs_DoneDisconnected (because gs_DoneDisconnected = 0)
        // global disconnect on last disconnected unit
        InternalCheckOnLastDisconnected;
        Result:=TRUE;
      end else if (GetTickCount > dwStartPendingTicks + InternalGetConnectionTimeoutMSec(AUnitIndex)) then begin
        // too long to disconnect - kill

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessRequestForUnit: kill');
{$ifend}

        try
          objDevice.KillNow;
        except
        end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessRequestForUnit: killed');
{$ifend}

        Sleep(0);

        DoInternalGPSStateChanged(AUnitIndex, objDevice.GPSDeviceType, gs_DoneDisconnected);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessRequestForUnit: free');
{$ifend}

        try
          FreeAndNil(objDevice);
        except
        end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessRequestForUnit: destroyed');
{$ifend}

        InternalCleanupItem(AUnitIndex);

        // global disconnect on last disconnected unit
        InternalCheckOnLastDisconnected;
        Result:=TRUE;
      end;
    end;
  end;
end;

procedure TVSAGPS_UNITS.InternalProcessUnitsRequests(const AThread: Tvsagps_Device_Thread);
var
  i: Byte;
  b_UnSyncDisconnected: Boolean;
  b_WorkDone: Boolean;

  function _CheckTerminated: Boolean;
  begin
    Result := ((nil<>AThread) and (AThread.Terminated))
  end;

begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessUnitsRequests: begin');
{$ifend}

  if (nil<>FALLDeviceParams) then
    b_UnSyncDisconnected := ((FALLDeviceParams^.dwDeviceFlagsIn and dpdfi_UnSyncDisconnected) = dpdfi_UnSyncDisconnected)
  else
    b_UnSyncDisconnected := FALSE;
    
  repeat
  try
    Sleep(0);
    b_WorkDone:=FALSE;

    // check exit
    if _CheckTerminated then
      break;

    // just simple requests
    for i := 0 to cUnitIndex_Max do
    if (FItems[i].IsRequestingState) then begin
      Sleep(0);
      
      // check exit
      if _CheckTerminated then
        break;

      // process request
      Lock_CS_State;
      try
        // check exit
        if _CheckTerminated then
          break;

        if InternalProcessRequestForUnit(i) then
          b_WorkDone:=TRUE; // something happens
      finally
        Unlock_CS_State;
      end;
    end;

    // check exit
    if _CheckTerminated then
      break;

    // nothing happens
    if (not b_WorkDone) then
      Sleep(cWorkingThread_Devices_Delay_MSec);
  except
  end
  until FALSE;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessUnitsRequests: kill');
{$ifend}

  // kill thread
  if (nil<>AThread) then
  try
    AThread.GPSRunning:=FALSE;
    AThread.Terminate;
    InternalDisconnectALLItems(FALSE);
    if b_UnSyncDisconnected then
      AThread.DoTerminateUnSync;
  except
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessUnitsRequests: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalTerminateRuntimeObjects;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalTerminateRuntimeObjects: begin');
{$ifend}

  if (nil<>FDeviceThread) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalTerminateRuntimeObjects: terminate');
{$ifend}
    FDeviceThread.Terminate;
  end;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalTerminateRuntimeObjects: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalWaitRuntimeObjects;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeObjects: begin');
{$ifend}

  InternalWaitRuntimeThread(@FDeviceThread);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeObjects: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalWaitRuntimeThread(const APtrThread: Pvsagps_Thread);
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeThread: begin');
{$ifend}

  try
    repeat
      Sleep(0);
      
      // if destroyed - go
      if (nil=APtrThread^) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeThread: destroyed');
{$ifend}
        Exit;
      end;
        
      Sleep(0);

      // terminate if not
      if (nil<>APtrThread^) and (not APtrThread^.Terminated) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeThread: terminate');
{$ifend}
        APtrThread^.Terminate;
      end;

      Sleep(0);

      // if finished
      if (nil<>APtrThread^) and (not APtrThread^.GPSRunning) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeThread: finished');
{$ifend}
        Exit;
      end;

      Sleep(cWorkingThread_Default_Delay_Msec);
    until FALSE;
  except
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeThread: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.Lock_CS_Runtime;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Lock_CS_Runtime: in');
{$ifend}

  //EnterCriticalSection(FCS_RunTime);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Lock_CS_Runtime: ok');
{$ifend}
end;

procedure TVSAGPS_UNITS.Lock_CS_State;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Lock_CS_State: in');
{$ifend}

  EnterCriticalSection(FCS_State);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Lock_CS_State: ok');
{$ifend}
end;

procedure TVSAGPS_UNITS.Unlock_CS_Runtime;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Unlock_CS_Runtime: in');
{$ifend}

  //LeaveCriticalSection(FCS_RunTime);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Unlock_CS_Runtime: ok');
{$ifend}
end;

procedure TVSAGPS_UNITS.Unlock_CS_State;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Unlock_CS_State: in');
{$ifend}

  LeaveCriticalSection(FCS_State);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Unlock_CS_State: ok');
{$ifend}
end;

procedure TVSAGPS_UNITS.WaitForALLState(const AStates: Tvsagps_GPSStates; const pbAbort: pBoolean);
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.WaitForALLState: begin');
{$ifend}

  repeat
    Sleep(0);
    if (FALLState in AStates) or ((nil<>pbAbort) and (pbAbort^)) then begin
      break;
    end;
    Sleep(cWorkingThread_Devices_Delay_MSec);
  until FALSE;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.WaitForALLState: end');
{$ifend}
end;

{ Tvsagps_Thread }

procedure Tvsagps_Thread.DoTerminateUnSync;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_Thread.DoTerminateUnSync: begin');
{$ifend}

  if Assigned(OnTerminate) then begin
    OnTerminate(Self);
    OnTerminate:=nil;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_Thread.DoTerminateUnSync: end');
{$ifend}
end;

procedure Tvsagps_Thread.KillNow;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_Thread.KillNow: begin');
{$ifend}

  if (0<>Handle) then begin

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_Thread.KillNow: terminate');
{$ifend}

    TerminateThread(Handle,0);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_Thread.KillNow: close');
{$ifend}

    CloseHandle(Handle);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_Thread.KillNow: cleanup');
{$ifend}

    PHandle(@(Handle))^:=0;
    PDWORD(@(ThreadID))^:=0;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_Thread.KillNow: end');
{$ifend}
end;

procedure Tvsagps_Thread.PrepareToKill;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_Thread.PrepareToKill: begin');
{$ifend}

  PDWORD(@(ThreadID))^:=0;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_Thread.PrepareToKill: end');
{$ifend}
end;

{ Tvsagps_Device_Thread }

procedure Tvsagps_Device_Thread.Execute;
begin
  //inherited;
  if (nil<>FGPSObject) then
    FGPSObject.InternalProcessUnitsRequests(Self);
end;

{ TVSAGPS_UNIT }

function TVSAGPS_UNIT.AllowGetDevInfo: Boolean;
begin
  Result:=(eDevState in [gs_ProcessConnecting, gs_DoneConnected]);
end;

function TVSAGPS_UNIT.IsEmpty: Boolean;
begin
  Result := (nil=objDevice) and
            (gs_DoneDisconnected=eDevState) and
            (0=dwStartPendingTicks);
end;

function TVSAGPS_UNIT.IsRequestingState: Boolean;
begin
  if (nil<>objDevice) then
    if (gs_DoneConnected=eDevState) then
      if (0<>objDevice.FinishReason) then
        eDevState:=gs_ProcessDisconnecting;
  Result := (not (eDevState in [gs_DoneConnected, gs_DoneDisconnected]));
end;

end.