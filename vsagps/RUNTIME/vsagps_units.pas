(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_units;
(*
  2026-11-20: the runtime threads are owned by the object instead of freeing
              themselves (the old FreeOnTerminate + OnTerminate via
              Synchronize scheme): FreeOnTerminate is off, no OnTerminate
              handlers are used, and the finalization (the item cleanup, the
              final done-disconnected notification) runs at the very end of
              the dispatcher Execute under the state lock. The owner
              terminates the thread, then waits for its real exit (WaitFor)
              and frees it - after the wait the thread is guaranteed gone,
              so no stale callback can reach the freed object and the whole
              delivery machinery (the Synchronize pumps, the leak fallback
              of the destructor) is not needed. The terminated thread is
              released lazily: at the next connect (the wait is bounded, the
              connect is refused when the previous teardown is still running
              after the bound - as the old scheme did) or at the destroy (no
              bound there - the destructor cannot refuse). A
              device thread terminated before its first Execute call also
              just exits (the RTL skips Execute for a terminated thread),
              so the old GPSRunning-flag wait is not needed either. A device
              whose raw working thread could not be killed safely is still
              detached and contained (see InternalDetachItem and
              FreeInstance) - that thread is not a TThread and cannot be
              waited for with a bound
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
  Classes,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_device,
  vsagps_device_base,
  vsagps_queue;

const
  // how long the all-items wait may wait for the graceful device close
  // before the bounded KillNow fallback (see InternalDisconnectALLItems):
  // the wait runs with the state lock held (the kill section of the
  // dispatcher or the owner thread of the destructor path), so it must not
  // inherit the user-configured connection timeout (up to $FFFF seconds) -
  // a healthy device finishes its close way below this bound, a device
  // which has not closed within it is hung and the KillNow fallback is the
  // right answer anyway
  cUnits_Device_Close_Wait_Timeout_MSec = 5000;
  // reserve for the poll granularity and the host callbacks inside the
  // kill section of the dispatcher thread (the main loop poll period is
  // cWorkingThread_Devices_Delay_MSec, the state change notifications are
  // delivered by the same thread)
  cUnits_Release_Margin_MSec = 2000;
  // how long a releaser may wait for the exit of a runtime thread (the
  // connect path refuses after this bound, the destructor paths fall back
  // to the leak containment): must exceed the worst case of the kill
  // section of the thread (the poll period + the graceful close wait + the
  // bounded KillNow lock wait), otherwise a correctly working teardown of
  // a slow or hung device ends up as a false timeout and the leak of the
  // object. The single-device worst case is derived here; many devices
  // hung inside their close paths add one KillNow lock wait each and may
  // still exceed the bound - the leak containment is the designed fallback
  // for that
  cUnits_Release_Timeout_MSec = cUnits_Device_Close_Wait_Timeout_MSec +
                                cKillNow_CloseLock_Timeout_MSec +
                                cUnits_Release_Margin_MSec; // 8000

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
  end;
  PVSAGPS_UNIT = ^TVSAGPS_UNIT;

  TVSAGPS_UNITS =  class;

  // the base of the runtime threads of the object: the threads are owned by
  // the object (FreeOnTerminate is off, no OnTerminate handlers) - the owner
  // terminates them, waits for the real exit and frees them (see
  // InternalReleaseTerminatedThread)
  Tvsagps_Thread = class(TThread)
  protected
    FGPSObject: TVSAGPS_UNITS;
  public
    property GPSObject: TVSAGPS_UNITS read FGPSObject write FGPSObject;
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
    // at least one device was detached with a possibly still alive working
    // thread (see InternalDetachItem): that thread keeps references to the
    // shared close section, to the packet queue and to the host parameter
    // block, so the object memory is leaked on purpose (see FreeInstance)
    // and the destructor keeps the referenced resources valid
    FLeakedDevicePresent: Boolean;
    // TRUE - some caller is releasing the device thread (waiting for its
    // exit and freeing it): the claim serializes the concurrent releasers
    FReleasingDeviceThread: Boolean;
    procedure InternalChangeALLGPSState(const ANewState: Tvsagps_GPSState;
                                        const AUseLock: Boolean);
    procedure DoInternalGPSStateChanged(const AUnitIndex: Byte;
                                        const AGPSDevType: DWORD;
                                        const ANewState: Tvsagps_GPSState);

    procedure InternalCleanupItem(const AUnitIndex: Byte);
    procedure InternalDetachItem(const AUnitIndex: Byte);
    procedure InternalCleanupAllItems;
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
    // release a terminated runtime thread: claim the field under the state
    // lock, wait for the real exit outside the lock (the kill section of the
    // thread takes the same lock) and free the object; the caller passes the
    // field and the claim flag of the thread it owns. The wait is bounded by
    // ATimeoutMSec (0 - without a bound): on a timeout the thread stays
    // terminating, the claim is dropped and the field stays non-nil, so a
    // connect can refuse it and a later release can retry. The result is
    // FALSE only when the thread is still terminating (TRUE - nothing to
    // release or released completely)
    function InternalReleaseTerminatedThread(const APtrThreadField: Pvsagps_Thread;
                                             const APtrReleasingFlag: pBoolean;
                                             const ATimeoutMSec: DWORD): Boolean;
    // release all the terminated runtime threads of the object (the derived
    // classes add their own threads); must be called without the state lock;
    // FALSE - some thread is still terminating after the bound
    function InternalReleaseTerminatedRuntimeThreads(const ATimeoutMSec: DWORD): Boolean; virtual;
    procedure InternalTerminateRuntimeObjects; virtual;
    procedure InternalCreateRuntimeObjects; virtual;
    // release the runtime threads with the library bound (see
    // cUnits_Release_Timeout_MSec) and mark the leaked-object containment on
    // a timeout: a runtime thread may be stuck forever on the shared
    // close-handle section held by a hung device (the packet parser takes
    // the section for every packet), so the destructor paths must not wait
    // without a bound behind it; must be called without the state lock
    function InternalWaitRuntimeObjects: Boolean; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    // a detached device working thread (see InternalDetachItem) references
    // the memory of this object (the critical sections, the packet queue) -
    // when such a device exists, the object memory is leaked on purpose and
    // the thread runs on the valid object instead
    procedure FreeInstance; override;

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
  FLeakedDevicePresent:=FALSE;
  FReleasingDeviceThread:=FALSE;
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
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: begin');
{$ifend}

  // the dispatcher thread is owned by the object: terminate it (idempotent)
  // and release it (the wait for the real exit and the free) - after the
  // release the thread is gone and its kill section (the item finalization
  // and the final done-disconnected notification) is complete; the wait runs
  // without the state lock (the kill section takes the same lock) and is
  // bounded: a thread may be stuck forever on the shared close-handle
  // section held by a hung device, so on a timeout the thread is left
  // terminating and the object is leaked on purpose instead (the containment
  // below - see FLeakedDevicePresent and InternalWaitRuntimeObjects)
  InternalTerminateRuntimeObjects;
  InternalWaitRuntimeObjects;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: cleanup');
{$ifend}

  // safety net: finalize the items the threads left behind (empty when the
  // kill section has run; the device guard inside kills or detaches a
  // working thread which has not released the close section)
  InternalCleanupAllItems;

  if FLeakedDevicePresent then begin
    // a detached device working thread or a stuck runtime thread still
    // references the critical sections - keep them valid (the object memory
    // is leaked on purpose, see FreeInstance). The host callback and
    // parameter fields are nil-ed so the object's own code paths skip the
    // host calls and the user pointer dereferences behind them when they
    // run after this destructor (a stuck dispatcher resuming after a slow
    // callback). The nil-ing cannot reach the threads which hold their own
    // copy of the host parameter block (the device workers read their own
    // field) - protecting those is out of scope of this containment, that
    // is the documented boundary here
    FOnGPSStateChanged:=nil;
    FOnGPSTimeout:=nil;
    FALLDeviceParams:=nil;
    FALLDeviceUserPointer:=nil;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.Destroy: delete sections');
{$ifend}

  // kill
  if (not FLeakedDevicePresent) then begin
    DeleteCriticalSection(FCS_State);
    DeleteCriticalSection(FCS_CloseHandle);
  end;

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

procedure TVSAGPS_UNITS.FreeInstance;
begin
  // a detached device working thread (see InternalDetachItem) references the
  // memory of this object - the object memory is leaked on purpose, so the
  // thread runs on the valid object instead
  if (not FLeakedDevicePresent) then
    inherited;
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
    if (nil<>objDevice) then begin
      // the device destructor terminates the working thread without any
      // lock (see VSAGPS_WorkingThread_Kill) - a thread caught inside the
      // close path would orphan the shared close section, so the thread
      // must be past its close path before the object is freed. A thread
      // which has signalled its own exit is safe; the others are killed
      // first (the kill is bounded), and the devices which could not be
      // killed safely are detached and leaked (see InternalDetachItem)
      if (not objDevice.WorkingThreadExited) then begin
        if (not objDevice.KillNow) then begin
          InternalDetachItem(AUnitIndex);
          Exit;
        end;
      end;
      objDevice.Free;
    end;
    ZeroMemory(@(FItems[AUnitIndex]), sizeof(FItems[AUnitIndex]));
  end;
end;

procedure TVSAGPS_UNITS.InternalDetachItem(const AUnitIndex: Byte);
begin
  // the device could not be killed safely (its working thread did not
  // release the close section, see Tvsagps_device_base.KillNow): the device
  // object is leaked on purpose together with its working thread, and the
  // owner is marked - the destructor must keep the resources that thread
  // references (the shared close section, the packet queue) valid and must
  // not call the host anymore (see FreeInstance). The item reference is
  // cleared without freeing the device and the slot is poisoned, so no later
  // cleanup frees the device again and no new connection reuses the unit
  // index while the old working thread may still write packets with it (the
  // slot is lost for the object lifetime - the leak path is exceptional and
  // the trade-off is intentional)
  // the caller holds FCS_State
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalDetachItem: begin');
{$ifend}

  FLeakedDevicePresent:=TRUE;

  // nothing else can stop the leaked working thread - ask it to exit on its
  // own (it finishes the close path it is inside and leaves at the next exit
  // check; without the ask the parsing thread would run until the queue
  // pushes stop it)
  FItems[AUnitIndex].objDevice.Disconnect;

  with FItems[AUnitIndex] do begin
    objDevice:=nil;
    pDevParams:=nil;
    eDevState:=gs_DoneDisconnected;
    dwLastPacketTicks:=0;
    reqGPSCommand_ResetDGPS:=FALSE;
    // the poison: a non-zero value keeps IsEmpty FALSE, so the slot is never
    // returned by InternalFindNewUnitIndex (dwUniqueIndex is left as is)
    dwStartPendingTicks:=1;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalDetachItem: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalCleanupAllItems;
var i: Byte;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalCleanupAllItems: begin');
{$ifend}

  // the dispatcher thread is gone - finalize the items it left behind: the
  // per-unit finalization (the done notification and the device object
  // freeing) is normally performed by the live threads (the state machine
  // and the kill section of the dispatcher), but a thread which never
  // entered its loop (terminated before the first Execute call) leaves the
  // items behind
  Lock_CS_State;
  try
    for i := 0 to cUnitIndex_Max do
    if (nil<>FItems[i].objDevice) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalCleanupAllItems: finalize');
{$ifend}
      // the same order as the normal per-unit finalization: notify first
      DoInternalGPSStateChanged(i, FItems[i].objDevice.GPSDeviceType, gs_DoneDisconnected);
      InternalCleanupItem(i);
    end;
  finally
    Unlock_CS_State;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalCleanupAllItems: end');
{$ifend}
end;

procedure TVSAGPS_UNITS.InternalCreateRuntimeObjects;
begin
  // thread for devices - owned by the object: no self-freeing and no
  // OnTerminate handlers, the owner releases it after the termination
  if (nil=FDeviceThread) then begin
    FDeviceThread:=Tvsagps_Device_Thread.Create(TRUE);
    FDeviceThread.GPSObject:=Self;
    FDeviceThread.FreeOnTerminate:=FALSE;
    FDeviceThread.{$IF CompilerVersion < 23}Resume{$ELSE}Start{$IFEND};
  end;
end;

procedure TVSAGPS_UNITS.InternalDisconnectALLItems(const AWaitFor: Boolean);
var
  i: Byte;
  dwTicks, dwDisconnectTimeoutMSec: DWORD;
  bNotYet: Boolean;
  bKilled: Boolean;
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
    // the graceful close wait is capped (see cUnits_Device_Close_Wait_Timeout_MSec):
    // the wait runs with the state lock held and must not freeze the state
    // readers for the whole user-configured connection timeout when the
    // device driver is hung - a device which did not close within the cap
    // gets the bounded KillNow fallback below
    dwDisconnectTimeoutMSec:=InternalGetConnectionTimeoutMSec(cUnitIndex_ALL);
    if (dwDisconnectTimeoutMSec>cUnits_Device_Close_Wait_Timeout_MSec) then
      dwDisconnectTimeoutMSec:=cUnits_Device_Close_Wait_Timeout_MSec;
    dwTicks:=GetTickCount;
    repeat
      bNotYet:=FALSE;

      // scan devices
      for i := 0 to cUnitIndex_Max do
      if (nil<>FItems[i].objDevice) then begin
        Sleep(0);
        if (FItems[i].objDevice.WorkingThreadExited) then begin
          // the working thread has passed its close path (the device handle
          // is closed then) - notify and finalize. The device handle alone
          // is not a completion signal here: a device which is still
          // connecting has no handle yet, and killing its thread inside the
          // connect call would leave the winsock locks abandoned
          DoInternalGPSStateChanged(i, FItems[i].objDevice.GPSDeviceType, gs_DoneDisconnected);
          // set state=0, destroy device object and cleanup item
          InternalCleanupItem(i);
        end else begin
          // not yet
          if GetTickCount>dwTicks+dwDisconnectTimeoutMSec then begin
            // too long - kill (the kill is bounded: it may skip the
            // termination when the close section is not released in time -
            // the device is detached and leaked then, see InternalDetachItem)
            if (nil<>FItems[i].objDevice) then begin
              bKilled:=FItems[i].objDevice.KillNow;
              DoInternalGPSStateChanged(i, FItems[i].objDevice.GPSDeviceType, gs_DoneDisconnected);
              if bKilled then begin
                // set state=0, destroy device object and cleanup item
                InternalCleanupItem(i);
              end else begin
                // the close section was not released - the device is leaked
                InternalDetachItem(i);
              end;
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

procedure TVSAGPS_UNITS.InternalPrepareItem(const AUnitIndex: Byte);
begin
  with FItems[AUnitIndex] do begin
    dwUniqueIndex:=FNewUniqueIndex;
    Inc(FNewUniqueIndex);
    dwLastPacketTicks:=GetTickCount;
  end;
end;

function TVSAGPS_UNITS.InternalProcessRequestForUnit(const AUnitIndex: Byte): Boolean;
var
  VKilled: Boolean;
begin
  // cs_state is locked
  Result:=FALSE;

  with FItems[AUnitIndex] do begin
    // the device-initiated disconnect (the communication failure): the
    // disconnect start must be stamped here - the connect success has zeroed
    // the ticks, and the disconnecting state machine below would kill the
    // device at once instead of waiting for its graceful disconnect (the
    // device thread would be terminated inside its close path, which
    // orphans the shared close critical section and deadlocks the device
    // thread dispatcher). The whole state machine runs under the state lock
    if (gs_DoneConnected=eDevState) then
      if (nil<>objDevice) then
        if (0<>objDevice.FinishReason) then begin
          eDevState:=gs_ProcessDisconnecting;
          dwStartPendingTicks:=GetTickCount;
        end;

    if (not (eDevState in [gs_DoneConnected, gs_DoneDisconnected])) then
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

        VKilled:=FALSE;
        try
          VKilled:=objDevice.KillNow;
        except
        end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessRequestForUnit: killed');
{$ifend}

        Sleep(0);

        DoInternalGPSStateChanged(AUnitIndex, objDevice.GPSDeviceType, gs_DoneDisconnected);

        if VKilled then begin
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
        end else begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
          VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessRequestForUnit: leak');
{$ifend}

          // the close section was not released - the device is leaked on
          // purpose (see Tvsagps_device_base.KillNow)
          InternalDetachItem(AUnitIndex);
        end;

        // global disconnect on last disconnected unit
        InternalCheckOnLastDisconnected;
        Result:=TRUE;
      end;
    end;
    end;
  end;
end;

procedure TVSAGPS_UNITS.InternalProcessUnitsRequests(const AThread: Tvsagps_Device_Thread);
var
  i: Byte;
  b_WorkDone: Boolean;

  function _CheckTerminated: Boolean;
  begin
    Result := ((nil<>AThread) and (AThread.Terminated))
  end;

begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalProcessUnitsRequests: begin');
{$ifend}

  repeat
  try
    Sleep(0);
    b_WorkDone:=FALSE;

    // check exit
    if _CheckTerminated then
      break;

    // the state machine of every unit, always under the state lock
    for i := 0 to cUnitIndex_Max do begin
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

  // the thread is owned by the object and was terminated by the owner (or by
  // itself when the last unit has disconnected): the finalization runs here,
  // at the very end of Execute, under the state lock - this replaces the
  // Synchronize-delivered OnTerminate handler of the old scheme, so no
  // callback of this thread can ever reach the freed owner (the owner
  // releases the thread only after the real exit)
  // NOTE: the wait for the graceful device close inside runs with the state
  // lock held (the same way as the owner path of the destructor does); the
  // holders of the close section never take the state lock, so the wait is
  // bounded and cannot deadlock; the bound is capped by
  // cUnits_Device_Close_Wait_Timeout_MSec (not the user-configured
  // connection timeout) - the state readers must not freeze for the whole
  // user timeout when a device driver is hung
  Lock_CS_State;
  try
    // ask the devices to disconnect and wait for the graceful close (capped,
    // see cUnits_Device_Close_Wait_Timeout_MSec), then finalize the leftovers
    InternalDisconnectALLItems(TRUE);

    // ALL Device CLOSED - the final notification
    InternalChangeALLGPSState(gs_DoneDisconnected, TRUE);
  finally
    Unlock_CS_State;
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

  // the thread field is read under FCS_State (the same lock protects the
  // reads of the field by the owner)
  Lock_CS_State;
  try
    if (nil<>FDeviceThread) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalTerminateRuntimeObjects: terminate');
{$ifend}
      FDeviceThread.Terminate;
    end;
  finally
    Unlock_CS_State;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalTerminateRuntimeObjects: end');
{$ifend}
end;

function TVSAGPS_UNITS.InternalWaitRuntimeObjects: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeObjects: begin');
{$ifend}

  // the wait of the old scheme is replaced by the release: the threads are
  // owned, so waiting for the real exit also frees them; the call must run
  // without the state lock (the kill sections of the threads take it). The
  // wait is bounded: a runtime thread may be stuck forever on the shared
  // close-handle section held by a hung device (the packet parser takes
  // that section for every parsed packet) - the destructor must not freeze
  // the caller behind it, so on a timeout the thread is left terminating
  // and the object is leaked on purpose instead (the same containment as
  // for the detached devices - see FLeakedDevicePresent)
  Result:=InternalReleaseTerminatedRuntimeThreads(cUnits_Release_Timeout_MSec);
  if (not Result) then
    FLeakedDevicePresent:=TRUE;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalWaitRuntimeObjects: end');
{$ifend}
end;

function TVSAGPS_UNITS.InternalReleaseTerminatedThread(const APtrThreadField: Pvsagps_Thread;
                                                        const APtrReleasingFlag: pBoolean;
                                                        const ATimeoutMSec: DWORD): Boolean;
var
  VThread: Tvsagps_Thread;
  VWaitResult: DWORD;
begin
  // the thread is owned by the object (FreeOnTerminate is off, no
  // OnTerminate handlers): terminate it (idempotent), wait for the real
  // exit and free the object - after the wait no code of the thread can
  // run anymore. The claim under the state lock serializes the concurrent
  // releasers; the wait itself must run without the state lock - the kill
  // section of the thread takes the same lock before the thread exits
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalReleaseTerminatedThread: begin');
{$ifend}

  VThread:=nil;
  Lock_CS_State;
  try
    if (nil<>APtrThreadField^) and (not APtrReleasingFlag^) then begin
      // terminate under the lock: the field must be stable while it is read
      if (not APtrThreadField^.Terminated) then
        APtrThreadField^.Terminate;
      if (APtrThreadField^.Terminated) then begin
        APtrReleasingFlag^:=TRUE;
        VThread:=APtrThreadField^;
      end;
    end;
  finally
    Unlock_CS_State;
  end;

  if (nil=VThread) then begin
    // nothing to release: no thread or another releaser holds the claim
    Result:=TRUE;
    Exit;
  end;

  // the real exit of the thread: the kill section is complete when this
  // returns (it runs inside Execute). The library bounds the exit path
  // itself (the poll period, the graceful device close capped by
  // cUnits_Device_Close_Wait_Timeout_MSec, the bounded device kills), the
  // host callback duration is the only host-controlled part - the callers
  // pass the bound and handle the timeout (the connect refuses, the
  // destructor leaks)
  if (0=ATimeoutMSec) then begin
    VThread.WaitFor;
    VWaitResult:=WAIT_OBJECT_0;
  end else
    VWaitResult:=WaitForSingleObject(VThread.Handle, ATimeoutMSec);

  if (WAIT_OBJECT_0<>VWaitResult) then begin
    // not exited within the bound: drop the claim and leave the thread
    // terminating - the field stays non-nil, so the connect refuses it (as
    // the old scheme did) and a later release retries
    Lock_CS_State;
    try
      APtrReleasingFlag^:=FALSE;
    finally
      Unlock_CS_State;
    end;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalReleaseTerminatedThread: timeout');
{$ifend}
    Result:=FALSE;
    Exit;
  end;

  Lock_CS_State;
  try
    APtrReleasingFlag^:=FALSE;
    if (APtrThreadField^=VThread) then
      APtrThreadField^:=nil;
  finally
    Unlock_CS_State;
  end;
  VThread.Free;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('TVSAGPS_UNITS.InternalReleaseTerminatedThread: end');
{$ifend}

  Result:=TRUE;
end;

function TVSAGPS_UNITS.InternalReleaseTerminatedRuntimeThreads(const ATimeoutMSec: DWORD): Boolean;
begin
  // the device thread of this class; the derived classes release their own
  // threads too (see the override in vsagps_object)
  Result:=InternalReleaseTerminatedThread(@FDeviceThread, @FReleasingDeviceThread, ATimeoutMSec);
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

end.