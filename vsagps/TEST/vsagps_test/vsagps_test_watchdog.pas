unit vsagps_test_watchdog;
(*
  Test helper: the per-test progress lines and the hard watchdog.

  Every test of the suites inherited from Tvsagps_test_case reports its
  boundaries as "[TEST START] Suite.Method" and "[TEST DONE] Suite.Method
  (N msec)". The unbuffered stderr is used on purpose: all the written
  lines survive the hard process kill and interleave with the library
  debug log (VSAGPS_DEBUG_TO_STDERR) inside the redirected log file.

  The watchdog thread hard-terminates the process (ExitProcess) when a
  single test or the whole suite exceeds its time limit. The destructor
  paths of the library contain potentially unbounded waits (TThread.WaitFor
  of the packet thread, EnterCriticalSection), so waiting for the process
  is not enough to collect the diagnostics - the exit code 3 means the
  watchdog terminated the process, the log shows the last test and the
  last library breadcrumbs before the stall.

  Limits (msec) are overridable via the environment (0 = no limit):
    VSAGPS_TEST_TIMEOUT_TEST  - one test (default 60000)
    VSAGPS_TEST_TIMEOUT_SUITE - the whole suite (default 300000)
*)

interface

uses
  TestFramework;

type
  // the common base of all test suites: reports the test boundaries and
  // arms the watchdog
  Tvsagps_test_case = class(TTestCase)
  public
    procedure RunTest(testResult: TTestResult); override;
  end;

// start the watchdog thread (once, before running the tests)
procedure Vsagps_Test_Watchdog_Start;
// mark the normal end of the suite - the watchdog stops watching
procedure Vsagps_Test_Watchdog_Stop;

// write one line to the unbuffered stderr (the same stream as the library
// debug log); used for the test progress and the watchdog report
procedure Vsagps_Test_Log(const AText: AnsiString);

// drain the queued Synchronize callbacks (until the queue stays empty).
// NOTE: since 2026-11-20 the library threads are owned by the object and
// deliver nothing via Synchronize (the finalization runs at the end of the
// thread Execute, and the owner waits for the real exit), so this helper is
// a no-op for the library and stays only as a belt-and-suspenders pump for
// the test code which used to rely on the delivery
procedure Vsagps_Test_FlushPendingSyncs;

implementation

uses
  Windows,
  SysUtils,
  Classes,
  Winapi.TlHelp32;

const
  cWatchdog_Poll_MSec = 500;
  cWatchdog_Default_Test_Timeout_MSec = 60000;
  cWatchdog_Default_Suite_Timeout_MSec = 300000;
  cWatchdog_Exit_Code = 3;

var
  g_Log_CS: TRTLCriticalSection;
  g_State_CS: TRTLCriticalSection;
  g_TestName: AnsiString;
  g_TestStartTick: DWORD; // 0 = no test running
  g_SuiteStartTick: DWORD;
  g_WatchdogStopped: Boolean;

{ the sync queue drain }

procedure Vsagps_Test_FlushPendingSyncs;
var
  VTicks: DWORD;
  VIdle: Integer;
begin
  // the queue is normally empty (the library does not use Synchronize
  // anymore); the bounded pump is kept so a stale callback of an older test
  // binary can not leak into the next test
  VIdle:=0;
  VTicks:=GetTickCount;
  while (VIdle<10) and (GetTickCount-VTicks<300) do begin
    if CheckSynchronize then
      VIdle:=0
    else
      Inc(VIdle);
    Sleep(10);
  end;
end;

{ the log }

procedure Vsagps_Test_Log(const AText: AnsiString);
const
  cTail: array [0..1] of AnsiChar = (#13, #10);
var
  h: THandle;
  dwWritten: DWORD;
begin
  h:=GetStdHandle(STD_ERROR_HANDLE);
  if (0=h) or (INVALID_HANDLE_VALUE=h) then
    Exit; // no stderr (a GUI process) - nothing to write
  EnterCriticalSection(g_Log_CS);
  try
    if (0<Length(AText)) then begin
      dwWritten:=0;
      WriteFile(h, Pointer(AText)^, DWORD(Length(AText)), dwWritten, nil);
    end;
    dwWritten:=0;
    WriteFile(h, cTail, sizeof(cTail), dwWritten, nil);
  finally
    LeaveCriticalSection(g_Log_CS);
  end;
end;

{ the per-test state }

procedure Vsagps_Test_Notify_Start(const AName: AnsiString);
begin
  EnterCriticalSection(g_State_CS);
  try
    g_TestName:=AName;
    g_TestStartTick:=GetTickCount;
  finally
    LeaveCriticalSection(g_State_CS);
  end;
end;

procedure Vsagps_Test_Notify_End(const AName: AnsiString; const AElapsedMSec: DWORD);
begin
  EnterCriticalSection(g_State_CS);
  try
    g_TestStartTick:=0;
    g_TestName:='';
  finally
    LeaveCriticalSection(g_State_CS);
  end;
  Vsagps_Test_Log('[TEST DONE] '+AName+' ('+
                  AnsiString(IntToStr(AElapsedMSec))+' msec)');
end;

{ the thread snapshot }

function Watchdog_Thread_Snapshot: AnsiString;
var
  hSnap: THandle;
  te: TThreadEntry32;
  VCount: Integer;
  s: AnsiString;
begin
  Result:='';
  hSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, GetCurrentProcessId);
  if (INVALID_HANDLE_VALUE=hSnap) then
    Exit;
  try
    FillChar(te, sizeof(te), 0);
    te.dwSize:=sizeof(te);
    VCount:=0;
    s:='';
    if Thread32First(hSnap, te) then
    repeat
      if (te.th32OwnerProcessID=GetCurrentProcessId) then begin
        Inc(VCount);
        s:=s+' '+AnsiString(IntToStr(te.th32ThreadID));
      end;
    until (not Thread32Next(hSnap, te));
    Result:='[WATCHDOG] threads ('+AnsiString(IntToStr(VCount))+'):'+s;
  finally
    CloseHandle(hSnap);
  end;
end;

{ the watchdog }

function Watchdog_Timeout_From_Env(const AName: string;
                                   const ADefault: DWORD): DWORD;
var
  s: string;
begin
  s:=GetEnvironmentVariable(AName);
  if (0=Length(s)) then
    Result:=ADefault
  else
    Result:=StrToIntDef(s, ADefault);
end;

procedure Watchdog_Terminate(const AScope: AnsiString;
                             const ATestName: AnsiString;
                             const AElapsedMSec: DWORD);
var
  s: AnsiString;
begin
  s:='[WATCHDOG TIMEOUT] '+AScope+' exceeded the limit after '+
     AnsiString(IntToStr(AElapsedMSec))+' msec';
  if (0<Length(ATestName)) then
    s:=s+' (test: '+ATestName+')';
  Vsagps_Test_Log(s);
  Vsagps_Test_Log(Watchdog_Thread_Snapshot);
  Vsagps_Test_Log('the process will be terminated now (exit code '+
                  AnsiString(IntToStr(cWatchdog_Exit_Code))+')');
  ExitProcess(cWatchdog_Exit_Code);
end;

function Watchdog_Thread_Proc(Parameter: Pointer): Integer;
var
  VTestLimit: DWORD;
  VSuiteLimit: DWORD;
  VStart: DWORD;
  VName: AnsiString;
  VNow: DWORD;
  VElapsed: DWORD;
begin
  Result:=0;
  VTestLimit:=Watchdog_Timeout_From_Env('VSAGPS_TEST_TIMEOUT_TEST',
                                        cWatchdog_Default_Test_Timeout_MSec);
  VSuiteLimit:=Watchdog_Timeout_From_Env('VSAGPS_TEST_TIMEOUT_SUITE',
                                         cWatchdog_Default_Suite_Timeout_MSec);

  while (not g_WatchdogStopped) do begin
    Sleep(cWatchdog_Poll_MSec);
    if g_WatchdogStopped then
      Break;
    VNow:=GetTickCount;
    // one test
    if (0<VTestLimit) then begin
      EnterCriticalSection(g_State_CS);
      try
        VStart:=g_TestStartTick;
        VName:=g_TestName;
      finally
        LeaveCriticalSection(g_State_CS);
      end;
      if (0<VStart) then begin
        VElapsed:=VNow-VStart;
        if (VElapsed>VTestLimit) then
          Watchdog_Terminate('test', VName, VElapsed);
      end;
    end;
    // the whole suite
    if (0<VSuiteLimit) and (0<g_SuiteStartTick) then begin
      VElapsed:=VNow-g_SuiteStartTick;
      if (VElapsed>VSuiteLimit) then
        Watchdog_Terminate('suite', '', VElapsed);
    end;
  end;
end;

procedure Vsagps_Test_Watchdog_Start;
var
  tid: Cardinal;
begin
  g_SuiteStartTick:=GetTickCount;
  g_WatchdogStopped:=FALSE;
  BeginThread(nil, 0, @Watchdog_Thread_Proc, nil, 0, tid);
end;

procedure Vsagps_Test_Watchdog_Stop;
begin
  g_WatchdogStopped:=TRUE;
end;

{ Tvsagps_test_case }

procedure Tvsagps_test_case.RunTest(testResult: TTestResult);
var
  VT: DWORD;
  VName: AnsiString;
begin
  VName:=AnsiString(ClassName)+'.'+AnsiString(Name);
  Vsagps_Test_Notify_Start(VName);
  Vsagps_Test_Log('[TEST START] '+VName);
  VT:=GetTickCount;
  try
    inherited RunTest(testResult);
  finally
    Vsagps_Test_Notify_End(VName, GetTickCount-VT);
  end;
end;

initialization
  InitializeCriticalSection(g_Log_CS);
  InitializeCriticalSection(g_State_CS);
finalization
  DeleteCriticalSection(g_Log_CS);
  DeleteCriticalSection(g_State_CS);
end.
