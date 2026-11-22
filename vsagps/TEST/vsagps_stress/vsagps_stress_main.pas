unit vsagps_stress_main;
(*
  2026-11-20: a thread which is still above the baseline after the settle is
              re-checked with a longer budget and reported with its thread
              list (a transient asynchronous exit vs. a real leftover).

  2026-11-19: created.

  Console stress tool for the Tvsagps_object runtime-thread lifecycle. It
  targets the race between the object destructor and the runtime threads
  (Tvsagps_Device_Thread / Tvsagps_Packet_Thread): destroying the object
  while a thread is winding down used to delete the critical sections and
  free the object with a callback still queued - the stale handler then
  entered the freed memory (the TestUdpObjectFactorySmoke access violation).
  Since 2026-11-20 the runtime threads are owned by the object: the items
  are finalized in the kill section of the dispatcher thread at the end of
  its Execute and the owner waits for the real thread exit, so no callback
  is delivered through TThread.Synchronize anymore. What is still checked
  here is that the teardown is bounded: a device driver which never returns
  from its close is detached and contained (InternalDetachItem /
  FreeInstance), and the object is leaked on purpose in that case - see
  VSAGPS_EMULATE_HUNG_DEVICE_CLOSE / VSAGPS_EMULATE_HUNG_DEVICE_READ.

  The tool creates and destroys a Tvsagps_object in a loop and tears it down
  in every order: immediately after GPSConnect, right after an asynchronous
  GPSDisconnect, while connected, after the normal done-disconnected state,
  after a local NMEA stream, and after a connect which fails asynchronously
  (the device thread fails its bind and exits by itself). The endpoints are
  self-contained: a free
  127.0.0.1 udp port, an occupied 127.0.0.1 udp port and the TEST-NET-3
  black-hole TCP address.

  The main thread pumps CheckSynchronize between the steps, as a real host
  application does (the library no longer needs the pump - it is kept
  because the tests and the sample hosts still call it). A hung iteration
  (the in-process watchdog), an
  unexpected connect/state and a library thread left behind (the thread
  snapshot vs. the baseline) are reported. A thread still above the baseline
  right after a disconnect is re-checked with a longer budget and is only
  then reported: the OS exit is asynchronous and the done-disconnected
  notification precedes the device destroy (which waits for its working
  thread), so a 3+ s tail is normal. This is a manual/CI stress
  helper - a separate console program in TEST\vsagps_stress, not a part of
  the vsagps_test.dpr DUnit project (that project stays untouched).

  Command line: vsagps_stress.exe [option ...]
    -iterations=N          iterations (default 100)
    -scenario=LIST         connect,disconnect,connected,disconnected,fail,
                           blackhole,traffic,loop (default all)
    -seed=N                random seed (default: tick count xor thread id)
    -delay=MS              max random pause before the teardown (default 50)
    -iteration-timeout=SEC per-iteration watchdog (default 60, 0 = off)
    -total-timeout=SEC     whole-run watchdog (default 3600, 0 = off)
    -trace                 log every iteration (default: every 10th)
    -destroy-worker        free every object on a worker thread instead of
                           the main thread (the destructor then runs on a
                           thread which is not the one the library was used
                           from; a slow teardown there is reported as a note,
                           not a warning)
    -help                  this text

  Exit codes: 0 - passed; 1 - bad command line; 2 - completed with warnings;
  3 - the watchdog terminated a hung iteration; any other - the process
  crashed (an access violation is exactly what the tool looks for; the last
  log line names the iteration and the phase).
*)

{$I vsagps_defines.inc}

interface

// Parse the command line (ParamStr) and run the stress loop. The return
// value is the process exit code (see the unit header).
function StressRun: Integer;

implementation

uses
  Winapi.Windows,
  Winapi.Winsock2,
  Winapi.TlHelp32,
  System.SysUtils,
  System.Classes,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_device,
  vsagps_units,
  vsagps_object;

const
  cStress_Loopback = '127.0.0.1';
  cStress_Blackhole = '203.0.113.1:9';

  cStress_Default_Iterations = 100;
  cStress_Default_Delay_MSec = 50;
  cStress_Default_Iteration_Timeout_MSec = 60000;
  cStress_Default_Total_Timeout_MSec = 3600000;

  // the library device thread polls every cWorkingThread_Devices_Delay_MSec
  // (200 ms), so the waits below are generous on purpose
  cStress_Connect_Wait_MSec = 3000;
  cStress_Disconnect_Wait_MSec = 8000;
  cStress_Thread_Settle_MSec = 3000;

  // the thread exit is asynchronous: the FreeOnTerminate object frees itself
  // and the RTL leaves the thread, which the Toolhelp snapshot may notice a
  // moment later. A thread above the baseline after the settle is re-checked
  // with this extra budget before it is reported as left behind
  cStress_Thread_Extra_Settle_MSec = 8000;

  // a failed udp bind is processed by the device thread in one poll period;
  // the pause is not pumped, so its OnTerminate stays queued until the
  // destructor's WaitForTerminateDelivery drains the queue
  cStress_Fail_Settle_MSec = 700;

  cStress_Blackhole_Timeout_Sec = 3;
  cStress_Blackhole_Delay_MSec = 100;

  cStress_Default_Connection_Timeout_Sec = 5;
  cStress_Default_Receive_Timeout_Sec = 3;

  // the destructor waits up to cUnits_Terminate_Delivery_Timeout_MSec for
  // each runtime thread callback (2000 ms); a teardown noticeably longer
  // than that means the delivery timed out and the object was leaked on
  // purpose (the fallback, not a crash - still worth a warning)
  cStress_Slow_Teardown_MSec = 4500;

  cStress_Nmea_GGA: AnsiString =
    '$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47'#13#10;
  cStress_Nmea_RMC: AnsiString =
    '$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A'#13#10;

type
  TStressScenario = (ssConnect,
                     ssDisconnect,
                     ssConnected,
                     ssDisconnected,
                     ssFail,
                     ssBlackhole,
                     ssTraffic,
                     ssLoop);
  TStressScenarios = set of TStressScenario;

  TStressOptions = record
    Iterations: Integer;
    Scenarios: TStressScenarios;
    Seed: Integer;
    DelayMSec: DWORD;
    IterationTimeoutMSec: DWORD;
    TotalTimeoutMSec: DWORD;
    Trace: Boolean;
    DestroyInWorker: Boolean;
  end;

  TStressParseResult = (spr_Ok, spr_Help, spr_Error);

const
  cStress_All_Scenarios: TStressScenarios =
    [ssConnect, ssDisconnect, ssConnected, ssDisconnected,
     ssFail, ssBlackhole, ssTraffic, ssLoop];

type
  // ntdll!NtQueryInformationThread (not declared by the RTL)
  TStress_NtQueryInformationThread = function (const AThreadHandle: THandle;
                                               const AThreadInformationClass: ULONG;
                                               const AThreadInformation: Pointer;
                                               const AThreadInformationLength: ULONG;
                                               const AReturnLength: PULONG): LongInt; stdcall;

const
  cStress_ThreadQuerySetWin32StartAddress = 9;

  // not declared by the RTL (Winapi.Windows has no OpenThread/GetModuleHandleEx)
  THREAD_QUERY_INFORMATION = $0040;
  GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = $00000004;
  GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT = $00000002;

function StressOpenThread(const ADesiredAccess: DWORD;
                          const AInheritHandle: BOOL;
                          const AThreadID: DWORD): THandle; stdcall;
  external 'kernel32.dll' name 'OpenThread';

function StressGetModuleHandleEx(const AFlags: DWORD;
                                 const AModuleName: Pointer;
                                 var AModule: HMODULE): BOOL; stdcall;
  external 'kernel32.dll' name 'GetModuleHandleExW';

var
  g_Log_CS: TRTLCriticalSection;
  g_Log_CS_Ready: Boolean;

  g_NtQueryInformationThread: TStress_NtQueryInformationThread;

  // the watchdog state (read by the watchdog thread)
  g_IterationStartTick: DWORD; // 0 - no iteration is running
  g_RunStartTick: DWORD;
  g_IterationTimeoutMSec: DWORD;
  g_TotalTimeoutMSec: DWORD;
  g_WatchdogStopped: Boolean;

  // the background library threads are counted against this value
  g_BaselineThreads: Integer;
  // the library TThread objects start in the exe (System.BeginThread), while a
  // winsock provider helper starts in ntdll/ws2_32/mswsock - the provider
  // creates and destroys its helpers at will, so only the exe threads are
  // counted for the leak check
  g_ExeModuleName: string;
  g_BaselineExeThreads: Integer;

  // the udp socket used to feed the local listener
  g_SenderSocket: TSocket;

  // callback counters (the host callbacks run on the library threads)
  g_Packets: Integer;
  g_SessionStarted: Integer;
  g_GGA: Integer;
  g_RMC: Integer;
  g_Timeouts: Integer;
  g_StateChanges: Integer;
  g_StateCount: array [Tvsagps_GPSState] of Integer;
  g_SendErrors: Integer;

  g_Warnings: Integer;

  // the run modes (set from the command line)
  g_DestroyInWorker: Boolean;

{ the log }

procedure StressLog(const AText: string);
begin
  if g_Log_CS_Ready then
    EnterCriticalSection(g_Log_CS);
  try
    Writeln(AText);
    Flush(Output);
  finally
    if g_Log_CS_Ready then
      LeaveCriticalSection(g_Log_CS);
  end;
end;

procedure StressUsage;
begin
  StressLog('vsagps_stress - console stress tool for the Tvsagps_object runtime-thread lifecycle');
  StressLog('');
  StressLog('usage: vsagps_stress.exe [option ...]');
  StressLog('');
  StressLog('  -iterations=N          iterations (default '+IntToStr(cStress_Default_Iterations)+')');
  StressLog('  -scenario=LIST         connect,disconnect,connected,disconnected,fail,');
  StressLog('                         blackhole,traffic,loop (default all)');
  StressLog('  -seed=N                random seed (default: tick count xor thread id)');
  StressLog('  -delay=MS              max random pause before the teardown (default '+
             IntToStr(cStress_Default_Delay_MSec)+')');
  StressLog('  -iteration-timeout=SEC per-iteration watchdog (default '+
             IntToStr(cStress_Default_Iteration_Timeout_MSec div 1000)+', 0 = off)');
  StressLog('  -total-timeout=SEC     whole-run watchdog (default '+
             IntToStr(cStress_Default_Total_Timeout_MSec div 1000)+', 0 = off)');
  StressLog('  -trace                 log every iteration (default: every 10th)');
  StressLog('  -destroy-worker        free every object on a worker thread');
  StressLog('  -help                  this text');
end;

{ the callbacks passed to the library (stdcall, run on the library threads) }

procedure StressSessionStartedCallback(const pUserPointer: Pointer;
                                       const btUnitIndex: Byte;
                                       const dwGPSDevType: DWORD;
                                       const pdwReserved: PDWORD); stdcall;
begin
  InterlockedIncrement(g_SessionStarted);
end;

function StressLowLevelCallback(const pUserPointer: Pointer;
                                const btUnitIndex: Byte;
                                const dwDeviceType: DWORD;
                                const pPacket: Pointer): DWORD; stdcall;
begin
  // the handler must return zero
  InterlockedIncrement(g_Packets);
  Result:=0;
end;

function StressGGACallback(const pUserPointer: Pointer;
                           const btUnitIndex: Byte;
                           const dwPacketType: DWORD;
                           const pNmeaData: PNMEA_GGA): DWORD; stdcall;
begin
  InterlockedIncrement(g_GGA);
  Result:=0;
end;

function StressRMCCallback(const pUserPointer: Pointer;
                           const btUnitIndex: Byte;
                           const dwPacketType: DWORD;
                           const pNmeaData: PNMEA_RMC): DWORD; stdcall;
begin
  InterlockedIncrement(g_RMC);
  Result:=0;
end;

procedure StressTimeoutCallback(const pUserPointer: Pointer;
                                const btUnitIndex: Byte;
                                const dwGPSDevType: DWORD;
                                const pdwReserved: PDWORD); stdcall;
begin
  InterlockedIncrement(g_Timeouts);
end;

procedure StressStateChangedCallback(const pUserPointer: Pointer;
                                     const btUnitIndex: Byte;
                                     const dwGPSDevType: DWORD;
                                     const eNewState: Tvsagps_GPSState); stdcall;
begin
  InterlockedIncrement(g_StateChanges);
  InterlockedIncrement(g_StateCount[eNewState]);
end;

{ the thread helpers }

function StressThreadCount: Integer;
var
  VSnap: THandle;
  VEntry: TThreadEntry32;
begin
  Result:=0;
  VSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, GetCurrentProcessId);
  if (INVALID_HANDLE_VALUE=VSnap) then
    Exit;
  try
    ZeroMemory(@VEntry, SizeOf(VEntry));
    VEntry.dwSize:=SizeOf(VEntry);
    if Thread32First(VSnap, VEntry) then
    repeat
      if (VEntry.th32OwnerProcessID=GetCurrentProcessId) then
        Inc(Result);
    until (not Thread32Next(VSnap, VEntry));
  finally
    CloseHandle(VSnap);
  end;
end;

// the module of the thread start address: a library thread starts in the RTL
// (System.BeginThread / TThread) and a winsock helper thread in ws2_32 or
// mswsock - this distinguishes a real leaked library thread from a provider
// helper in the diagnostics
function StressThreadStartModule(const AThreadID: DWORD): string;
var
  VThread: THandle;
  VAddr: Pointer;
  VLen: ULONG;
  VModule: HMODULE;
  VName: array [0..MAX_PATH] of Char;
begin
  Result:='?';
  if (not Assigned(g_NtQueryInformationThread)) then
    Exit;

  VThread:=StressOpenThread(THREAD_QUERY_INFORMATION, FALSE, AThreadID);
  if (0=VThread) then
    Exit;
  try
    VAddr:=nil;
    VLen:=0;
    if (0<>g_NtQueryInformationThread(VThread,
                                      cStress_ThreadQuerySetWin32StartAddress,
                                      @VAddr,
                                      SizeOf(VAddr),
                                      @VLen)) then
      Exit;
    if (nil=VAddr) then
      Exit;
    VModule:=0;
    if StressGetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS or
                               GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                               VAddr,
                               VModule) then
      if (0<>GetModuleFileName(VModule, VName, MAX_PATH)) then
        Result:=ExtractFileName(VName);
  finally
    CloseHandle(VThread);
  end;
end;

function StressThreadList: string;
var
  VSnap: THandle;
  VEntry: TThreadEntry32;
begin
  Result:='';
  VSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, GetCurrentProcessId);
  if (INVALID_HANDLE_VALUE=VSnap) then
    Exit;
  try
    ZeroMemory(@VEntry, SizeOf(VEntry));
    VEntry.dwSize:=SizeOf(VEntry);
    if Thread32First(VSnap, VEntry) then
    repeat
      if (VEntry.th32OwnerProcessID=GetCurrentProcessId) then
        Result:=Result+' '+IntToStr(VEntry.th32ThreadID)+
                '('+StressThreadStartModule(VEntry.th32ThreadID)+')';
    until (not Thread32Next(VSnap, VEntry));
  finally
    CloseHandle(VSnap);
  end;
end;

// count only the threads which start in this exe (main, watchdog and the
// library TThread objects) - the winsock provider helpers are excluded
function StressExeThreadCount: Integer;
var
  VSnap: THandle;
  VEntry: TThreadEntry32;
begin
  Result:=0;
  if (''=g_ExeModuleName) then
    Exit;
  VSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, GetCurrentProcessId);
  if (INVALID_HANDLE_VALUE=VSnap) then
    Exit;
  try
    ZeroMemory(@VEntry, SizeOf(VEntry));
    VEntry.dwSize:=SizeOf(VEntry);
    if Thread32First(VSnap, VEntry) then
    repeat
      if (VEntry.th32OwnerProcessID=GetCurrentProcessId) and
         SameText(StressThreadStartModule(VEntry.th32ThreadID), g_ExeModuleName) then
        Inc(Result);
    until (not Thread32Next(VSnap, VEntry));
  finally
    CloseHandle(VSnap);
  end;
end;

// resolve ntdll!NtQueryInformationThread for the start-address diagnostics
// (thread names set by NameThreadForDebugging are not visible via Toolhelp,
// so the start module is the best available hint)
procedure StressLoadThreadDiagnostics;
var
  VLib: HMODULE;
begin
  g_NtQueryInformationThread:=nil;
  VLib:=GetModuleHandle('ntdll.dll');
  if (0=VLib) then
    VLib:=LoadLibrary('ntdll.dll');
  if (0=VLib) then
    Exit;
  g_NtQueryInformationThread:=TStress_NtQueryInformationThread(
                                GetProcAddress(VLib, 'NtQueryInformationThread'));
end;

procedure StressPump(const AMSec: DWORD);
var
  VTicks: DWORD;
begin
  VTicks:=GetTickCount;
  repeat
    // the host callbacks of the library threads used to be delivered here
    CheckSynchronize;
    Sleep(1);
  until (DWORD(GetTickCount-VTicks)>=AMSec);
end;

// pump until the library threads are gone (the pump is a leftover of the old
// Synchronize delivery: the threads are owned by the object now and exit by
// themselves, the settle only waits for the asynchronous OS exit)
function StressWaitThreads(const ATimeoutMSec: DWORD): Boolean;
var
  VTicks: DWORD;
begin
  VTicks:=GetTickCount;
  repeat
    CheckSynchronize;
    if (StressExeThreadCount<=g_BaselineExeThreads) then begin
      Result:=TRUE;
      Exit;
    end;
    Sleep(10);
  until (DWORD(GetTickCount-VTicks)>=ATimeoutMSec);
  Result:=FALSE;
end;

function StressWaitState(const AObj: Tvsagps_object;
                         const AState: Tvsagps_GPSState;
                         const ATimeoutMSec: DWORD): Boolean;
var
  VTicks: DWORD;
begin
  VTicks:=GetTickCount;
  repeat
    CheckSynchronize;
    if (AObj.GPSState=AState) then begin
      Result:=TRUE;
      Exit;
    end;
    Sleep(1);
  until (DWORD(GetTickCount-VTicks)>=ATimeoutMSec);
  Result:=FALSE;
end;

{ the watchdog }

function StressWatchdogProc(Parameter: Pointer): Integer;
var
  VNow: DWORD;
begin
  Result:=0;
  while (not g_WatchdogStopped) do begin
    Sleep(250);
    if g_WatchdogStopped then
      Break;
    VNow:=GetTickCount;
    if (0<>g_IterationTimeoutMSec) and (0<>g_IterationStartTick) and
       (DWORD(VNow-g_IterationStartTick)>g_IterationTimeoutMSec) then begin
      StressLog('[WATCHDOG] the iteration exceeded '+
                IntToStr(g_IterationTimeoutMSec)+
                ' ms (a hang in the library teardown?)');
      StressLog('[WATCHDOG] threads:'+StressThreadList);
      ExitProcess(3);
    end;
    if (0<>g_TotalTimeoutMSec) and (0<>g_RunStartTick) and
       (DWORD(VNow-g_RunStartTick)>g_TotalTimeoutMSec) then begin
      StressLog('[WATCHDOG] the whole run exceeded '+
                IntToStr(g_TotalTimeoutMSec)+' ms');
      StressLog('[WATCHDOG] threads:'+StressThreadList);
      ExitProcess(3);
    end;
  end;
end;

{ the command line }

function StressScenarioFromName(const AName: string;
                                out AScenario: TStressScenario): Boolean;
begin
  Result:=TRUE;
  if SameText(AName, 'connect') then
    AScenario:=ssConnect
  else if SameText(AName, 'disconnect') then
    AScenario:=ssDisconnect
  else if SameText(AName, 'connected') then
    AScenario:=ssConnected
  else if SameText(AName, 'disconnected') then
    AScenario:=ssDisconnected
  else if SameText(AName, 'fail') then
    AScenario:=ssFail
  else if SameText(AName, 'blackhole') then
    AScenario:=ssBlackhole
  else if SameText(AName, 'traffic') then
    AScenario:=ssTraffic
  else if SameText(AName, 'loop') then
    AScenario:=ssLoop
  else
    Result:=FALSE;
end;

function StressScenarioName(const AScenario: TStressScenario): string;
begin
  case AScenario of
    ssConnect:      Result:='connect';
    ssDisconnect:   Result:='disconnect';
    ssConnected:    Result:='connected';
    ssDisconnected: Result:='disconnected';
    ssFail:         Result:='fail';
    ssBlackhole:    Result:='blackhole';
    ssTraffic:      Result:='traffic';
    ssLoop:         Result:='loop';
  else
    Result:='?';
  end;
end;

// a thread counted just above the baseline may still be exiting (the RTL
// leaves it after the FreeOnTerminate object has freed itself), so the first
// settle is followed by a longer one; a thread which is still there then is a
// real leftover and the caller reports it (the notes keep the transient cases
// visible without failing the run)
function StressSettleThreads(const AIndex: Integer;
                             const AScenario: TStressScenario;
                             const AFirstMSec, AExtraMSec: DWORD): Boolean;
var
  VTicks: DWORD;
begin
  if StressWaitThreads(AFirstMSec) then begin
    Result:=TRUE;
    Exit;
  end;

  StressLog('[NOTE] iteration '+IntToStr(AIndex)+
            ' ('+StressScenarioName(AScenario)+
            '): still above the baseline after '+IntToStr(AFirstMSec)+
            ' ms (exe threads '+IntToStr(StressExeThreadCount)+
            ', baseline '+IntToStr(g_BaselineExeThreads)+'):'+
            StressThreadList);

  VTicks:=GetTickCount;
  Result:=StressWaitThreads(AExtraMSec);
  if Result then
    StressLog('[NOTE] iteration '+IntToStr(AIndex)+
              ' ('+StressScenarioName(AScenario)+
              '): the thread exited after an additional '+
              IntToStr(DWORD(GetTickCount-VTicks))+' ms')
  else
    StressLog('[NOTE] iteration '+IntToStr(AIndex)+
              ' ('+StressScenarioName(AScenario)+
              '): still above the baseline after an additional '+
              IntToStr(AExtraMSec)+' ms:'+StressThreadList);
end;

function StressStateName(const AState: Tvsagps_GPSState): string;
begin
  case AState of
    gs_DoneDisconnected:    Result:='done-disconnected';
    gs_PendingConnecting:   Result:='pending-connecting';
    gs_ProcessConnecting:   Result:='process-connecting';
    gs_DoneConnected:       Result:='done-connected';
    gs_PendingDisconnecting:Result:='pending-disconnecting';
    gs_ProcessDisconnecting:Result:='process-disconnecting';
  else
    Result:='?';
  end;
end;

function StressParseScenarios(const AValue: string;
                              out AScenarios: TStressScenarios): Boolean;
var
  VRest, VItem: string;
  VPos: Integer;
  VScenario: TStressScenario;
begin
  AScenarios:=[];
  if SameText(Trim(AValue), 'all') then begin
    AScenarios:=cStress_All_Scenarios;
    Result:=TRUE;
    Exit;
  end;

  VRest:=AValue;
  while (0<Length(VRest)) do begin
    VPos:=Pos(',', VRest);
    if (0=VPos) then begin
      VItem:=Trim(VRest);
      VRest:='';
    end else begin
      VItem:=Trim(Copy(VRest, 1, VPos-1));
      VRest:=Copy(VRest, VPos+1, Length(VRest));
    end;
    if (not StressScenarioFromName(VItem, VScenario)) then begin
      Result:=FALSE;
      Exit;
    end;
    Include(AScenarios, VScenario);
  end;

  Result:=(AScenarios<>[]);
end;

function StressSplitOption(const AArg: string;
                           out AName, AValue: string): Boolean;
var
  VText: string;
  VPos: Integer;
begin
  VText:=AArg;
  if (0<Length(VText)) and ((VText[1]='-') or (VText[1]='/')) then
    Delete(VText, 1, 1);
  while (0<Length(VText)) and (VText[1]='-') do
    Delete(VText, 1, 1);

  VPos:=Pos('=', VText);
  if (0=VPos) then
    VPos:=Pos(':', VText);
  if (0=VPos) then begin
    AName:=LowerCase(VText);
    AValue:='';
    Result:=FALSE;
  end else begin
    AName:=LowerCase(Copy(VText, 1, VPos-1));
    AValue:=Copy(VText, VPos+1, Length(VText));
    Result:=TRUE;
  end;
end;

function StressParseCommandLine(out AOpt: TStressOptions): TStressParseResult;
var
  i: Integer;
  VName, VValue: string;
  VHasValue: Boolean;
  VInt: Integer;
begin
  AOpt.Iterations:=cStress_Default_Iterations;
  AOpt.Scenarios:=cStress_All_Scenarios;
  AOpt.Seed:=Integer(GetTickCount xor GetCurrentThreadId);
  AOpt.DelayMSec:=cStress_Default_Delay_MSec;
  AOpt.IterationTimeoutMSec:=cStress_Default_Iteration_Timeout_MSec;
  AOpt.TotalTimeoutMSec:=cStress_Default_Total_Timeout_MSec;
  AOpt.Trace:=FALSE;
  AOpt.DestroyInWorker:=FALSE;

  Result:=spr_Ok;
  for i:=1 to ParamCount do begin
    VHasValue:=StressSplitOption(ParamStr(i), VName, VValue);
    if SameText(VName, 'help') or SameText(VName, 'h') or (VName='?') then begin
      Result:=spr_Help;
      Exit;
    end else if SameText(VName, 'trace') then begin
      AOpt.Trace:=TRUE;
    end else if SameText(VName, 'destroy-worker') then begin
      AOpt.DestroyInWorker:=TRUE;
    end else if SameText(VName, 'iterations') then begin
      VInt:=StrToIntDef(VValue, -1);
      if (0>=VInt) then begin
        StressLog('[ERROR] -iterations needs a positive number: '+ParamStr(i));
        Result:=spr_Error;
        Exit;
      end;
      AOpt.Iterations:=VInt;
    end else if SameText(VName, 'scenario') then begin
      if (not VHasValue) or (not StressParseScenarios(VValue, AOpt.Scenarios)) then begin
        StressLog('[ERROR] bad -scenario list: '+ParamStr(i));
        Result:=spr_Error;
        Exit;
      end;
    end else if SameText(VName, 'seed') then begin
      if (not VHasValue) then begin
        StressLog('[ERROR] -seed needs a number: '+ParamStr(i));
        Result:=spr_Error;
        Exit;
      end;
      AOpt.Seed:=StrToIntDef(VValue, AOpt.Seed);
    end else if SameText(VName, 'delay') then begin
      VInt:=StrToIntDef(VValue, -1);
      if (0>VInt) then begin
        StressLog('[ERROR] -delay needs a non-negative number: '+ParamStr(i));
        Result:=spr_Error;
        Exit;
      end;
      AOpt.DelayMSec:=DWORD(VInt);
    end else if SameText(VName, 'iteration-timeout') then begin
      VInt:=StrToIntDef(VValue, -1);
      if (0>VInt) or (86400<VInt) then begin
        StressLog('[ERROR] -iteration-timeout needs 0..86400: '+ParamStr(i));
        Result:=spr_Error;
        Exit;
      end;
      AOpt.IterationTimeoutMSec:=DWORD(VInt)*1000;
    end else if SameText(VName, 'total-timeout') then begin
      VInt:=StrToIntDef(VValue, -1);
      if (0>VInt) or (86400<VInt) then begin
        StressLog('[ERROR] -total-timeout needs 0..86400: '+ParamStr(i));
        Result:=spr_Error;
        Exit;
      end;
      AOpt.TotalTimeoutMSec:=DWORD(VInt)*1000;
    end else begin
      StressLog('[ERROR] unknown option: '+ParamStr(i));
      Result:=spr_Error;
      Exit;
    end;
  end;
end;

{ the local sockets }

function StressLoopbackAddr: u_long;
begin
  Result:=inet_addr(PAnsiChar(AnsiString(cStress_Loopback)));
end;

function StressBindUdp(var AAddr: TSockAddrIn): TSocket;
begin
  Result:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (INVALID_SOCKET=Result) then
    Exit;
  ZeroMemory(@AAddr, SizeOf(AAddr));
  AAddr.sin_family:=AF_INET;
  AAddr.sin_addr.S_addr:=StressLoopbackAddr;
  AAddr.sin_port:=0;
  if (0<>bind(Result, PSockAddr(@AAddr)^, SizeOf(AAddr))) then begin
    closesocket(Result);
    Result:=INVALID_SOCKET;
  end;
end;

// reserve a free local udp port and return its number (the socket is
// closed, so the library can bind it in a moment)
function StressFindFreeUdpPort: Word;
var
  VAddr: TSockAddrIn;
  VLen: Integer;
  VSocket: TSocket;
begin
  Result:=0;
  VSocket:=StressBindUdp(VAddr);
  if (INVALID_SOCKET=VSocket) then
    Exit;
  try
    VLen:=SizeOf(VAddr);
    if (0<>getsockname(VSocket, PSockAddr(@VAddr)^, VLen)) then
      Exit;
    Result:=ntohs(VAddr.sin_port);
  finally
    closesocket(VSocket);
  end;
end;

// keep the local udp port busy, so the library device fails its bind
function StressHoldUdpPort(out APort: Word): TSocket;
var
  VAddr: TSockAddrIn;
  VLen: Integer;
begin
  APort:=0;
  Result:=StressBindUdp(VAddr);
  if (INVALID_SOCKET=Result) then
    Exit;
  VLen:=SizeOf(VAddr);
  if (0<>getsockname(Result, PSockAddr(@VAddr)^, VLen)) then begin
    closesocket(Result);
    Result:=INVALID_SOCKET;
    Exit;
  end;
  APort:=ntohs(VAddr.sin_port);
end;

procedure StressSendNmea(const APort: Word; const ACount: Integer);
var
  VTarget: TSockAddrIn;
  VData: AnsiString;
  VSent: Integer;
  i: Integer;
begin
  if (INVALID_SOCKET=g_SenderSocket) then
    Exit;

  ZeroMemory(@VTarget, SizeOf(VTarget));
  VTarget.sin_family:=AF_INET;
  VTarget.sin_addr.S_addr:=StressLoopbackAddr;
  VTarget.sin_port:=htons(APort);

  for i:=1 to ACount do begin
    if Odd(i) then
      VData:=cStress_Nmea_GGA
    else
      VData:=cStress_Nmea_RMC;
    VSent:=sendto(g_SenderSocket,
                  PAnsiChar(VData)^,
                  Length(VData),
                  0,
                  PSockAddr(@VTarget),
                  SizeOf(VTarget));
    if (SOCKET_ERROR=VSent) then
      InterlockedIncrement(g_SendErrors);
    // give the device thread a chance to receive and queue the packet
    StressPump(2);
  end;
end;

{ the object helpers }

// the context of the worker thread which frees the library object (the
// -destroy-worker mode): the destructor runs on a thread which is not the one
// the library was used from - the runtime threads are still terminated and
// waited for with a bound, the leak fallback stays the designed outcome for a
// hung device
type
  TStress_Free_Worker_Params = record
    ObjPtr: PPointer;
    DoneEvent: THandle;
    Error: Exception;
  end;
  PStress_Free_Worker_Params = ^TStress_Free_Worker_Params;

function StressFreeWorkerProc(AParameter: Pointer): Integer;
var
  VParams: PStress_Free_Worker_Params;
begin
  Result:=0;
  VParams:=AParameter;
  try
    if (nil<>VParams^.ObjPtr^) then begin
      TObject(VParams^.ObjPtr^).Free;
      VParams^.ObjPtr^:=nil;
    end;
  except
    on E: Exception do
      VParams^.Error:=Exception(AcquireExceptionObject);
  end;
  SetEvent(VParams^.DoneEvent);
end;

procedure StressInitParams(out AParams: TVSAGPS_ALL_DEVICE_PARAMS);
begin
  ZeroMemory(@AParams, SizeOf(AParams));
  AParams.wSize:=SizeOf(AParams);
  AParams.btAutodetectOnConnect:=0;
  AParams.btReceiveGPSTimeoutSec:=cStress_Default_Receive_Timeout_Sec;
  AParams.wConnectionTimeoutSec:=cStress_Default_Connection_Timeout_Sec;
  AParams.wWorkerThreadTimeoutMSec:=20;
  AParams.dwAutodetectFlags:=0;
  AParams.dwSourceFileFlagsIn:=0;
  AParams.dwSourceFileFlagsOut:=0;
  AParams.dwDeviceFlagsIn:=0;
  AParams.dwDeviceFlagsOut:=0;
  AParams.iBaudRate:=-1;
  AParams.pSessionStartedHandler:=StressSessionStartedCallback;
  AParams.pLowLevelHandler:=StressLowLevelCallback;
  AParams.pNMEA_GGA_HANDLER:=StressGGACallback;
  AParams.pNMEA_RMC_HANDLER:=StressRMCCallback;
end;

function StressCreateObject: Tvsagps_object;
begin
  Result:=Tvsagps_object.Create;
  Result.ALLDeviceUserPointer:=nil;
  Result.OnGPSStateChanged:=StressStateChangedCallback;
  Result.OnGPSTimeout:=StressTimeoutCallback;
end;

function StressConnectUdp(const AObj: Tvsagps_object;
                          const AParams: PVSAGPS_ALL_DEVICE_PARAMS;
                          const APort: Word;
                          out AUnitIndex: Byte): Boolean;
begin
  AUnitIndex:=cUnitIndex_ALL;
  Result:=AObj.GPSConnect(gdt_UDP_NMEA0183,
                          AnsiString(cStress_Loopback+':'+IntToStr(APort)),
                          nil,
                          AParams,
                          nil,
                          nil,
                          @AUnitIndex,
                          nil);
end;

function StressConnectTcp(const AObj: Tvsagps_object;
                          const AParams: PVSAGPS_ALL_DEVICE_PARAMS;
                          const AName: string;
                          out AUnitIndex: Byte): Boolean;
begin
  AUnitIndex:=cUnitIndex_ALL;
  Result:=AObj.GPSConnect(gdt_TCP_NMEA0183,
                          AnsiString(AName),
                          nil,
                          AParams,
                          nil,
                          nil,
                          @AUnitIndex,
                          nil);
end;

procedure StressWarn(const AIndex: Integer;
                     const AScenario: TStressScenario;
                     const AText: string);
begin
  InterlockedIncrement(g_Warnings);
  StressLog('[WARN] iteration '+IntToStr(AIndex)+
            ' ('+StressScenarioName(AScenario)+'): '+AText);
end;

// free the object and report a teardown which looks like the delivery
// fallback of the destructor (the object is leaked then)
function StressDestroy(var AObj: Tvsagps_object;
                       const AIndex: Integer;
                       const AScenario: TStressScenario): Boolean;
var
  VTicks: DWORD;
  VElapsed: DWORD;
  VWorkerParams: TStress_Free_Worker_Params;
  VWorker: THandle;
  VWorkerID: Cardinal;
begin
  Result:=FALSE;
  if (nil=AObj) then
    Exit;

  VTicks:=GetTickCount;
  if g_DestroyInWorker then begin
    // the destructor runs on a worker thread (not the one the library was
    // used from) - a timeout and the object leak are the designed fallback
    // for a hung device (the threads themselves are checked by the settle
    // after the iteration)
    ZeroMemory(@VWorkerParams, SizeOf(VWorkerParams));
    VWorkerParams.ObjPtr:=@AObj;
    VWorkerParams.DoneEvent:=CreateEvent(nil, TRUE, FALSE, nil);
    if (0=VWorkerParams.DoneEvent) then begin
      StressWarn(AIndex, AScenario, 'cannot create the worker done event');
      Result:=FALSE;
      Exit;
    end;
    try
      VWorker:=BeginThread(nil, 0, @StressFreeWorkerProc, @VWorkerParams, 0, VWorkerID);
      if (0=VWorker) then begin
        CloseHandle(VWorkerParams.DoneEvent);
        StressWarn(AIndex, AScenario, 'cannot start the free worker thread');
        Result:=FALSE;
        Exit;
      end;
      CloseHandle(VWorker);
      WaitForSingleObject(VWorkerParams.DoneEvent, INFINITE);
    finally
      CloseHandle(VWorkerParams.DoneEvent);
    end;

    if (nil<>VWorkerParams.Error) then begin
      // the destructor failed on the worker - re-raise on this thread, the
      // iteration wrapper reports it as fatal
      raise Exception.Create('the worker free failed: '+
                             VWorkerParams.Error.ClassName+': '+
                             VWorkerParams.Error.Message);
    end;
  end else begin
    FreeAndNil(AObj);
  end;
  VElapsed:=DWORD(GetTickCount-VTicks);

  if (VElapsed>=cStress_Slow_Teardown_MSec) then begin
    if g_DestroyInWorker then begin
      // the worker destructor waited out one of its bounds (the graceful
      // device close, the kill lock, the release of a runtime thread) - the
      // object is leaked on purpose, this is the designed fallback
      StressLog('[NOTE] iteration '+IntToStr(AIndex)+
                ' ('+StressScenarioName(AScenario)+
                '): the worker destructor took '+IntToStr(VElapsed)+
                ' ms (a teardown bound expired - the object is leaked on purpose)');
    end else begin
      Result:=TRUE;
      StressWarn(AIndex, AScenario,
                 'the destructor took '+IntToStr(VElapsed)+
                 ' ms (a teardown bound expired: a device driver which does not '+
                 'return from its close is detached and the object is leaked on purpose)');
    end;
  end;
end;

{ the iterations }

function StressRunIteration(const AScenario: TStressScenario;
                            const AIndex: Integer;
                            const AOpt: TStressOptions): Boolean;
var
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VPort: Word;
  VHolder: TSocket;
  VDelay: DWORD;
  VConnectCount: Integer;
  i: Integer;
begin
  Result:=TRUE;
  VObj:=nil;
  StressInitParams(VParams);

  // the delay is spread over all scenarios, so the teardown lands in every
  // phase of the device-thread loop
  VDelay:=DWORD(Random(Integer(AOpt.DelayMSec)+1));

  case AScenario of
    ssConnect: begin
      // free immediately after the connect request (the runtime threads may
      // not have started yet or may be in their first iteration)
      VPort:=StressFindFreeUdpPort;
      if (0=VPort) then begin
        StressWarn(AIndex, AScenario, 'no free udp port');
        Result:=FALSE;
        Exit;
      end;
      VObj:=StressCreateObject;
      try
        if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
          StressWarn(AIndex, AScenario, 'GPSConnect failed');
          Result:=FALSE;
        end else if (0<VDelay) then
          StressPump(VDelay);
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;

    ssDisconnect: begin
      // the original smoke-test pattern: connect, request the async
      // disconnect and free at once
      VPort:=StressFindFreeUdpPort;
      if (0=VPort) then begin
        StressWarn(AIndex, AScenario, 'no free udp port');
        Result:=FALSE;
        Exit;
      end;
      VObj:=StressCreateObject;
      try
        if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
          StressWarn(AIndex, AScenario, 'GPSConnect failed');
          Result:=FALSE;
        end else begin
          if (0<VDelay) then
            StressPump(VDelay);
          VObj.GPSDisconnect;
          // sometimes let the dispatcher advance one step before the free
          if (0<Random(6)) then
            StressPump(DWORD(Random(5)));
        end;
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;

    ssConnected: begin
      // free a connected object without an explicit disconnect
      VPort:=StressFindFreeUdpPort;
      if (0=VPort) then begin
        StressWarn(AIndex, AScenario, 'no free udp port');
        Result:=FALSE;
        Exit;
      end;
      VObj:=StressCreateObject;
      try
        if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
          StressWarn(AIndex, AScenario, 'GPSConnect failed');
          Result:=FALSE;
        end else begin
          if (not StressWaitState(VObj, gs_DoneConnected, cStress_Connect_Wait_MSec)) then begin
            StressWarn(AIndex, AScenario, 'the connected state is not reached');
            Result:=FALSE;
          end else if (0<VDelay) then
            StressPump(VDelay);
        end;
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;

    ssDisconnected: begin
      // the full normal cycle: connected, async disconnect, done-disconnected,
      // the unit finalized - only then the free
      VPort:=StressFindFreeUdpPort;
      if (0=VPort) then begin
        StressWarn(AIndex, AScenario, 'no free udp port');
        Result:=FALSE;
        Exit;
      end;
      VObj:=StressCreateObject;
      try
        if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
          StressWarn(AIndex, AScenario, 'GPSConnect failed');
          Result:=FALSE;
        end else begin
          if (not StressWaitState(VObj, gs_DoneConnected, cStress_Connect_Wait_MSec)) then begin
            StressWarn(AIndex, AScenario, 'the connected state is not reached');
            Result:=FALSE;
          end else begin
            VObj.GPSDisconnect;
            if (StressWaitState(VObj, gs_DoneDisconnected, cStress_Disconnect_Wait_MSec)) then begin
              if ((VUnitIndex<=cUnitIndex_Max) and
                  (not VObj.GPSUnits[VUnitIndex]^.IsEmpty)) then begin
                StressWarn(AIndex, AScenario, 'the unit is not finalized (a device object leak?)');
                Result:=FALSE;
              end;
            end else begin
              StressWarn(AIndex, AScenario, 'the done-disconnected state is not reached');
              Result:=FALSE;
            end;
          end;
        end;
        if (0<VDelay) then
          StressPump(VDelay);
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;

    ssFail: begin
      // the device thread fails its udp bind and exits by itself while the
      // main thread does not pump - the destructor must still finish the
      // teardown cleanly (the old stale-callback AV path)
      VHolder:=StressHoldUdpPort(VPort);
      if (INVALID_SOCKET=VHolder) then begin
        StressWarn(AIndex, AScenario, 'cannot reserve a local udp port');
        Result:=FALSE;
        Exit;
      end;
      try
        VObj:=StressCreateObject;
        try
          if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
            StressWarn(AIndex, AScenario, 'GPSConnect failed');
            Result:=FALSE;
          end else begin
            // no CheckSynchronize here on purpose
            Sleep(cStress_Fail_Settle_MSec+DWORD(Random(300)));
          end;
        finally
          if StressDestroy(VObj, AIndex, AScenario) then
            Result:=FALSE;
        end;
      finally
        closesocket(VHolder);
      end;
    end;

    ssBlackhole: begin
      // the connecting phase lasts until the destructor interrupts it
      VParams.wConnectionTimeoutSec:=cStress_Blackhole_Timeout_Sec;
      VObj:=StressCreateObject;
      try
        if (not StressConnectTcp(VObj, @VParams, cStress_Blackhole, VUnitIndex)) then begin
          StressWarn(AIndex, AScenario, 'GPSConnect failed');
          Result:=FALSE;
        end else begin
          VDelay:=DWORD(Random(cStress_Blackhole_Delay_MSec+1));
          if (0<VDelay) then
            StressPump(VDelay);
        end;
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;

    ssTraffic: begin
      // real nmea datagrams reach the packet thread (and its handlers) before
      // the teardown
      VPort:=StressFindFreeUdpPort;
      if (0=VPort) then begin
        StressWarn(AIndex, AScenario, 'no free udp port');
        Result:=FALSE;
        Exit;
      end;
      VObj:=StressCreateObject;
      try
        if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
          StressWarn(AIndex, AScenario, 'GPSConnect failed');
          Result:=FALSE;
        end else if (not StressWaitState(VObj, gs_DoneConnected, cStress_Connect_Wait_MSec)) then begin
          StressWarn(AIndex, AScenario, 'the connected state is not reached');
          Result:=FALSE;
        end else begin
          StressSendNmea(VPort, 5+Random(20));
          if (0<VDelay) then
            StressPump(VDelay);
          if (0=Random(2)) then
            VObj.GPSDisconnect;
        end;
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;

    ssLoop: begin
      // one object, several connect/disconnect cycles - the unit index must
      // stay reusable and the runtime thread fields must be cleared before
      // the next connect
      VObj:=StressCreateObject;
      try
        VConnectCount:=2+Random(3);
        for i:=1 to VConnectCount do begin
          VPort:=StressFindFreeUdpPort;
          if (0=VPort) then begin
            StressWarn(AIndex, AScenario, 'no free udp port');
            Result:=FALSE;
            Break;
          end;
          if (not StressConnectUdp(VObj, @VParams, VPort, VUnitIndex)) then begin
            StressWarn(AIndex, AScenario, 'GPSConnect failed on cycle '+IntToStr(i));
            Result:=FALSE;
            Break;
          end;

          if (0<VDelay) then
            StressPump(DWORD(Random(Integer(AOpt.DelayMSec)+1)));
          if (0=Random(2)) then
            StressWaitState(VObj, gs_DoneConnected, cStress_Connect_Wait_MSec);

          VObj.GPSDisconnect;
          if (not StressWaitState(VObj, gs_DoneDisconnected, cStress_Disconnect_Wait_MSec)) then begin
            StressWarn(AIndex, AScenario, 'the done-disconnected state is not reached on cycle '+IntToStr(i));
            Result:=FALSE;
            Break;
          end;

          // the runtime thread callbacks must be delivered before the next
          // connect (a terminated field makes GPSConnect refuse the unit)
          if (not StressSettleThreads(AIndex, AScenario,
                                      cStress_Thread_Settle_MSec,
                                      cStress_Thread_Extra_Settle_MSec)) then begin
            StressWarn(AIndex, AScenario, 'the runtime threads are still alive after the disconnect');
            Result:=FALSE;
            Break;
          end;

          if (not VObj.GPSUnits[VUnitIndex]^.IsEmpty) then begin
            StressWarn(AIndex, AScenario, 'the unit is not finalized on cycle '+IntToStr(i)+' (a device object leak?)');
            Result:=FALSE;
            Break;
          end;
        end;
      finally
        if StressDestroy(VObj, AIndex, AScenario) then
          Result:=FALSE;
      end;
    end;
  end;
end;

{ the run }

procedure StressWarmup;
var
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VPort: Word;
  i: Integer;
begin
  // the winsock provider creates its own helper threads lazily (on the first
  // bind/connect/sendto), so they must exist before the thread-count baseline
  // is taken - otherwise they look like a leaked library thread

  // the udp listener + a datagram (the bind and sendto paths)
  StressInitParams(VParams);
  VPort:=StressFindFreeUdpPort;
  if (0<>VPort) then begin
    VObj:=StressCreateObject;
    try
      if StressConnectUdp(VObj, @VParams, VPort, VUnitIndex) then begin
        StressWaitState(VObj, gs_DoneConnected, cStress_Connect_Wait_MSec);
        StressSendNmea(VPort, 1);
      end;
    finally
      FreeAndNil(VObj);
    end;
  end;

  // the tcp connect path (the TEST-NET-3 connect is interrupted by the free)
  StressInitParams(VParams);
  VParams.wConnectionTimeoutSec:=cStress_Blackhole_Timeout_Sec;
  VObj:=StressCreateObject;
  try
    StressConnectTcp(VObj, @VParams, cStress_Blackhole, VUnitIndex);
    StressPump(50);
  finally
    FreeAndNil(VObj);
  end;

  // let the warm-up library threads and the one-shot provider threads finish
  for i:=1 to 25 do begin
    CheckSynchronize;
    Sleep(20);
  end;
end;

function StressPickScenario(const AScenarios: TStressScenarios): TStressScenario;
var
  VList: array [0..7] of TStressScenario;
  VCount: Integer;
  VScenario: TStressScenario;
  i: Integer;
begin
  VCount:=0;
  for i:=Ord(Low(TStressScenario)) to Ord(High(TStressScenario)) do begin
    VScenario:=TStressScenario(i);
    if (VScenario in AScenarios) then begin
      VList[VCount]:=VScenario;
      Inc(VCount);
    end;
  end;
  if (0=VCount) then
    Result:=ssConnect
  else
    Result:=VList[Random(VCount)];
end;

procedure StressReportSummary;
var
  VState: Tvsagps_GPSState;
begin
  StressLog('');
  StressLog('=== callbacks ===');
  StressLog('  session started: '+IntToStr(g_SessionStarted));
  StressLog('  low-level packets: '+IntToStr(g_Packets));
  StressLog('  GGA: '+IntToStr(g_GGA)+', RMC: '+IntToStr(g_RMC));
  StressLog('  state changes: '+IntToStr(g_StateChanges)+
            ', timeouts: '+IntToStr(g_Timeouts));
  StressLog('  send errors: '+IntToStr(g_SendErrors));
  StressLog('=== all-state counters ===');
  for VState:=Low(Tvsagps_GPSState) to High(Tvsagps_GPSState) do
    StressLog('  '+StressStateName(VState)+': '+IntToStr(g_StateCount[VState]));
end;

function StressRun: Integer;
var
  VOpt: TStressOptions;
  VParse: TStressParseResult;
  VWSA: TWSAData;
  VScenario: TStressScenario;
  VIndex: Integer;
  VTicks: DWORD;
  VElapsed: DWORD;
  VWatchdog: THandle;
  VWatchdogID: Cardinal;
  VAllOk: Boolean;
  VState: Tvsagps_GPSState;
  VEndThreads: Integer;
  VEndExeThreads: Integer;
begin
  g_Log_CS_Ready:=FALSE;
  InitializeCriticalSection(g_Log_CS);
  g_Log_CS_Ready:=TRUE;
  try
    VParse:=StressParseCommandLine(VOpt);
    if (spr_Help=VParse) then begin
      StressUsage;
      Result:=0;
      Exit;
    end;
    if (spr_Error=VParse) then begin
      StressLog('');
      StressUsage;
      Result:=1;
      Exit;
    end;

    g_ExeModuleName:=ExtractFileName(ParamStr(0));
    g_DestroyInWorker:=VOpt.DestroyInWorker;
    StressLog('vsagps_stress: iterations='+IntToStr(VOpt.Iterations)+
              ', delay<='+IntToStr(VOpt.DelayMSec)+' ms'+
              ', seed='+IntToStr(VOpt.Seed)+
              ', destroy-worker='+BoolToStr(g_DestroyInWorker, TRUE));
    StressLog('the endpoints are local (127.0.0.1 udp) and TEST-NET-3 (tcp)');

    if (0<>WSAStartup($0202, VWSA)) then begin
      StressLog('[ERROR] WSAStartup failed');
      Result:=1;
      Exit;
    end;
    try
      g_SenderSocket:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
      if (INVALID_SOCKET=g_SenderSocket) then begin
        StressLog('[ERROR] cannot create the sender socket');
        Result:=1;
        Exit;
      end;
      try
        // the watchdog and the baseline are taken before any library thread
        // exists, so a thread left behind is visible after every iteration
        g_RunStartTick:=GetTickCount;
        g_IterationTimeoutMSec:=VOpt.IterationTimeoutMSec;
        g_TotalTimeoutMSec:=VOpt.TotalTimeoutMSec;
        g_IterationStartTick:=0;
        g_WatchdogStopped:=FALSE;
        VWatchdog:=BeginThread(nil, 0, @StressWatchdogProc, nil, 0, VWatchdogID);
        if (0<>VWatchdog) then
          CloseHandle(VWatchdog);
        Sleep(100);

        // force the lazy winsock helper threads and the library thread
        // startup before the baseline, then reset the callback counters
        StressLoadThreadDiagnostics;
        StressWarmup;
        g_Packets:=0;
        g_SessionStarted:=0;
        g_GGA:=0;
        g_RMC:=0;
        g_Timeouts:=0;
        g_StateChanges:=0;
        g_SendErrors:=0;
        for VState:=Low(Tvsagps_GPSState) to High(Tvsagps_GPSState) do
          g_StateCount[VState]:=0;

        g_BaselineThreads:=StressThreadCount;
        g_BaselineExeThreads:=StressExeThreadCount;
        StressLog('baseline threads: '+IntToStr(g_BaselineThreads)+
                  ' (exe '+IntToStr(g_BaselineExeThreads)+'):'+StressThreadList);

        RandSeed:=VOpt.Seed;
        VAllOk:=TRUE;
        VTicks:=GetTickCount;

        for VIndex:=1 to VOpt.Iterations do begin
          VScenario:=StressPickScenario(VOpt.Scenarios);
          g_IterationStartTick:=GetTickCount;
          try
            if (not StressRunIteration(VScenario, VIndex, VOpt)) then
              VAllOk:=FALSE;
          except
            on E: Exception do begin
              g_IterationStartTick:=0;
              StressLog('[FATAL] iteration '+IntToStr(VIndex)+
                        ' ('+StressScenarioName(VScenario)+'): '+
                        E.ClassName+': '+E.Message);
              raise;
            end;
          end;
          VElapsed:=DWORD(GetTickCount-g_IterationStartTick);
          g_IterationStartTick:=0;

          // the sync callbacks of the library threads are delivered by the
          // successful waits above; this is the final settle and the leak
          // check of the iteration
          if (not StressSettleThreads(VIndex, VScenario,
                                      cStress_Thread_Settle_MSec,
                                      cStress_Thread_Extra_Settle_MSec)) then begin
            StressWarn(VIndex, VScenario,
                       'a library thread is still alive after the teardown (exe threads '+
                       IntToStr(StressExeThreadCount)+', baseline '+
                       IntToStr(g_BaselineExeThreads)+')');
            StressLog('[WARN] threads:'+StressThreadList);
            VAllOk:=FALSE;
          end;

          if VOpt.Trace or ((0=(VIndex mod 10)) and (VIndex<VOpt.Iterations)) then
            StressLog('['+IntToStr(VIndex)+'/'+IntToStr(VOpt.Iterations)+'] '+
                      StressScenarioName(VScenario)+
                      ' ('+IntToStr(VElapsed)+' ms)');
        end;

        VElapsed:=DWORD(GetTickCount-VTicks);

        // the snapshot is taken before the watchdog is stopped, otherwise its
        // own thread may already be gone and the baseline comparison is off
        VEndThreads:=StressThreadCount;
        VEndExeThreads:=StressExeThreadCount;
        g_WatchdogStopped:=TRUE;

        StressReportSummary;
        StressLog('');
        StressLog('iterations: '+IntToStr(VOpt.Iterations)+
                  ', warnings: '+IntToStr(g_Warnings)+
                  ', elapsed: '+IntToStr(VElapsed)+' ms');
        StressLog('threads at the end: '+IntToStr(VEndThreads)+
                  ' (exe '+IntToStr(VEndExeThreads)+
                  ', baseline '+IntToStr(g_BaselineThreads)+
                  '/exe '+IntToStr(g_BaselineExeThreads)+')');

        if VAllOk and (0=g_Warnings) then begin
          StressLog('RESULT: OK');
          Result:=0;
        end else begin
          StressLog('RESULT: WARNINGS');
          Result:=2;
        end;
      finally
        g_WatchdogStopped:=TRUE;
        if (INVALID_SOCKET<>g_SenderSocket) then begin
          closesocket(g_SenderSocket);
          g_SenderSocket:=INVALID_SOCKET;
        end;
      end;
    finally
      WSACleanup;
    end;
  finally
    g_Log_CS_Ready:=FALSE;
    DeleteCriticalSection(g_Log_CS);
  end;
end;

initialization
  g_SenderSocket:=INVALID_SOCKET;

end.
