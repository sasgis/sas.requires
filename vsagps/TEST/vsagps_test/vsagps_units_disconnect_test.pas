unit vsagps_units_disconnect_test;
(*
  The disconnect requested during the connecting phase.

  The async GPSDisconnect terminates the device thread, and the per-unit
  finalization (the done notification, the device object freeing) lives in
  the state machine of that thread. When the disconnect lands while a unit
  is still connecting, the thread dies with the unit finalized only by the
  tail of its loop: the unit stays in the disconnecting state with the
  device object allocated, nobody ever advances it, and the ALL state is
  recalculated from that stale state into "disconnecting" forever (the
  caller hangs on the status). The dispatcher kill section now finalizes the
  leftovers at the end of Execute under the state lock (see
  Tvsagps_units.InternalProcessUnitsRequests), and
  the connecting->disconnecting ALL state transition is legal (see
  GPSStateChangeCorrectly), so the disconnect completes and the unit index
  stays reusable.
*)

interface

uses
  TestFramework,
  Winapi.Winsock2,
  vsagps_test_watchdog,
  vsagps_public_base,
  vsagps_object;

type
  Tvsagps_units_disconnect_test = class(Tvsagps_test_case)
  published
    // the state machine must accept the disconnect request as the next
    // state of the connecting phase (the user aborts the connect)
    procedure TestGPSStateChangeCorrectly;
    // the async disconnect during the connecting phase must finalize the
    // unit: the ALL state must come back to done-disconnected and the
    // device object must be freed (the unit index must stay reusable)
    procedure TestDisconnectDuringConnecting;
  end;

implementation

uses
  Windows,
  SysUtils,
  Classes,
  vsagps_public_types,
  vsagps_public_device,
  vsagps_units; // PVSAGPS_UNIT (unit state access in the assertions)

const
  // waiting limits for the background threads (the connect of the test
  // device runs up to the whole connection timeout, the disconnect must
  // interrupt it way earlier)
  cConnect_Wait_Timeout_MSec = 15000;
  cDisconnect_Wait_Timeout_MSec = 15000;

// wait until the object state comes back to "done disconnected" (the
// "all disconnected" state is reported by the dispatcher kill section at the
// end of Execute; the manual CheckSynchronize calls are no-ops in the
// ownership model and kept as a pump safety)
function WaitObjectStateDoneDisconnected(const AObj: Tvsagps_object;
                                         const ATimeoutMSec: DWORD): Boolean;
var
  VT: DWORD;
begin
  VT:=GetTickCount;
  while (gs_DoneDisconnected<>AObj.GPSState) and (GetTickCount-VT<ATimeoutMSec) do begin
    Sleep(10);
    CheckSynchronize;
  end;
  Result:=(gs_DoneDisconnected=AObj.GPSState);
end;

{ Tvsagps_units_disconnect_test }

procedure Tvsagps_units_disconnect_test.TestGPSStateChangeCorrectly;
begin
  // the base legal chain
  Check(GPSStateChangeCorrectly(gs_DoneDisconnected, gs_ProcessConnecting),
        'disconnected -> connecting must be legal');
  Check(GPSStateChangeCorrectly(gs_ProcessConnecting, gs_DoneConnected),
        'connecting -> connected must be legal');
  Check(GPSStateChangeCorrectly(gs_DoneConnected, gs_ProcessDisconnecting),
        'connected -> disconnecting must be legal');
  Check(GPSStateChangeCorrectly(gs_ProcessDisconnecting, gs_DoneDisconnected),
        'disconnecting -> disconnected must be legal');

  // the user abort of the connecting phase (before the fix this transition
  // was rejected, and the ALL state was recalculated from the stale unit
  // states instead of being set directly)
  Check(GPSStateChangeCorrectly(gs_ProcessConnecting, gs_ProcessDisconnecting),
        'connecting -> disconnecting (the user abort) must be legal');

  // skipping the disconnecting phase is still illegal
  Check(not GPSStateChangeCorrectly(gs_ProcessConnecting, gs_DoneDisconnected),
        'connecting -> disconnected must stay illegal');
  Check(not GPSStateChangeCorrectly(gs_DoneConnected, gs_ProcessConnecting),
        'connected -> connecting must stay illegal');
end;

procedure Tvsagps_units_disconnect_test.TestDisconnectDuringConnecting;
var
  VWSA: TWSAData;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VConnectingSeen: Boolean;
  VTicks: DWORD;
begin
  Check(WSAStartup($0202, VWSA)=0, 'WSAStartup failed');
  try
    ZeroMemory(@VParams, sizeof(VParams));
    with VParams do begin
      wSize:=sizeof(VParams);
      btAutodetectOnConnect:=0;
      btReceiveGPSTimeoutSec:=10;
      wConnectionTimeoutSec:=30; // long enough to observe the connecting phase
      wWorkerThreadTimeoutMSec:=50;
      dwAutodetectFlags:=0;
      dwDeviceFlagsOut:=0;
      iBaudRate:=-1;
    end;

    VObj:=Tvsagps_object.Create;
    try
      // TEST-NET-3 - on most networks the SYN packets for this address are
      // silently dropped (a black hole), so the connecting phase lasts the
      // whole connection timeout; on a network which refuses it at once
      // this test just checks less (the same assumption as in the tcp
      // device test)
      Check(VObj.GPSConnect(gdt_TCP_NMEA0183,
                            AnsiString('203.0.113.1:9'),
                            nil,
                            @VParams,
                            nil,
                            nil,
                            @VUnitIndex,
                            nil),
            'GPSConnect failed');

      // wait until the connecting state is observed
      VTicks:=GetTickCount;
      VConnectingSeen:=FALSE;
      while (GetTickCount-VTicks<cConnect_Wait_Timeout_MSec) do begin
        if (gs_ProcessConnecting=VObj.GPSState) then begin
          VConnectingSeen:=TRUE;
          Break;
        end;
        Sleep(10);
        CheckSynchronize;
      end;

      // the device object is allocated while the connecting phase runs
      if VConnectingSeen then begin
        Check(nil<>VObj.GPSUnits[VUnitIndex]^.objDevice,
              'the device object is not allocated while connecting');

        // the async disconnect during the connecting phase (the user
        // aborts the connect): before the fix the device thread was
        // terminated with the unit left in the disconnecting state
        // forever - the ALL state was recalculated from that stale state
        // and the device object leaked (the next connect allocated the
        // next unit index)
        VObj.GPSDisconnect;
      end;

      // the disconnect must complete (the dispatcher finalizes the items in
      // its kill section at the end of Execute, and the owner waits for the
      // real thread exit)
      Check(WaitObjectStateDoneDisconnected(VObj, cDisconnect_Wait_Timeout_MSec),
            'the object is not disconnected after the disconnect during the connecting phase');

      // the unit must be finalized: the device object is freed and the
      // unit index is reusable for the next connect
      Check(VObj.GPSUnits[VUnitIndex]^.IsEmpty,
            'the unit is not finalized after the disconnect (the device object leaks?)');
      Check(gs_DoneDisconnected=VObj.GPSUnits[VUnitIndex]^.eDevState,
            'the unit state is not the done-disconnected one');
      Vsagps_Test_Log('test: checks done');
    finally
      VObj.Free;
      Vsagps_Test_Log('test: object freed');
    end;
    Vsagps_Test_Log('test: before wsacleanup');
  finally
    WSACleanup;
    Vsagps_Test_Log('test: wsacleanup done');
  end;
  Vsagps_Test_Log('test: done');
end;

initialization
  RegisterTest(Tvsagps_units_disconnect_test.Suite);

end.
