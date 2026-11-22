unit vsagps_track_reader_test;
(*
  The real time pacing of the replay (fly-on-track) device.

  The device replays the track points at their own pace: the pause between
  the points is the time delta of the point timestamps scaled by the
  playback speed multiplier (1 = the real time, the bigger multiplier -
  the shorter pause). The points without the timestamp fall back to the
  fixed pause between the points.

  Before the rework the pacing was a fixed pause (the worker thread timeout
  divided by 16, about 60 msec with the default settings) scaled by the
  "percent" of that base - the timestamps of the track were ignored, so the
  whole track flew by at about 16 points per second regardless of how long
  it was recorded.
*)

interface

uses
  TestFramework,
  vsagps_test_watchdog;

type
  Tvsagps_track_reader_test = class(Tvsagps_test_case)
  published
    // the pause calc between the points: forward, backward time, midnight
    // wrap on the time only timestamps, the mixed date flags
    procedure TestTrackPointsPauseMSec;
    // the replay device must deliver all the points of the gpx track and
    // pace the delivery by the point timestamps scaled by the multiplier
    procedure TestReplayDeviceRealtimePacing;
    // the loop playback must repeat the track laps until the device stop
    // and the stop inside a lap must complete cleanly
    procedure TestReplayDeviceLoopPlayback;
  end;

implementation

uses
  Windows,
  SysUtils,
  Classes,
  DateUtils,
  vsagps_public_base, // gs_DoneDisconnected
  vsagps_public_types,
  vsagps_public_position,
  vsagps_public_device,
  vsagps_track_reader, // TrackPoints_Pause_MSec
  vsagps_object; // Tvsagps_object (the replay device as the vsagps unit)

const
  // the test track: N points with the fixed time gap between them
  cTestTrack_PointCount = 4;
  cTestTrack_GapSec = 2;
  // the playback multiplier for the integration test
  cTestTrack_Multiplier = 10;

var
  // the stats of the replay handler - the packets are delivered on the
  // packet thread only, so the plain counters are enough
  GReplayTest_Count: Integer;
  GReplayTest_FirstTicks: DWORD;
  GReplayTest_LastTicks: DWORD;

// the trackpoint handler of the replay test - counts the points and
// notes the delivery ticks of the first and the last one
function ReplayTest_TrackPointHandler(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwDeviceType: DWORD;
                                      const dwPacketType: DWORD;
                                      const pPacket: PSingleTrackPointData): DWORD; stdcall;
begin
  Result:=0;
  if (nil=pPacket) then
    Exit;
  Inc(GReplayTest_Count);
  if (1=GReplayTest_Count) then
    GReplayTest_FirstTicks:=GetTickCount;
  GReplayTest_LastTicks:=GetTickCount;
end;

// write the simple gpx track with the fixed time gaps into the temp folder
procedure ReplayTest_MakeGpxTrack(const AFileName: WideString; const APointCount, AGapSec: Integer);
var
  sl: TStringList;
  i: Integer;
  dtBase: TDateTime;
begin
  dtBase:=EncodeDateTime(2026, 1, 1, 10, 0, 0, 0);
  sl:=TStringList.Create;
  try
    sl.Add('<?xml version="1.0" encoding="UTF-8"?>');
    sl.Add('<gpx version="1.1" creator="vsagps_test" xmlns="http://www.topografix.com/GPX/1/1">');
    sl.Add('<trk><name>replay test</name><trkseg>');
    for i := 0 to APointCount-1 do begin
      sl.Add(Format('<trkpt lat="55.750000" lon="37.620000"><time>%s</time></trkpt>',
                    [FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"Z"', dtBase+i*AGapSec/SecsPerDay)]));
    end;
    sl.Add('</trkseg></trk>');
    sl.Add('</gpx>');
    sl.SaveToFile(AFileName);
  finally
    sl.Free;
  end;
end;

// wait until the object state comes back to "done disconnected" (the same
// pattern as in the disconnect test)
function WaitObjectStateDoneDisconnected(const AObj: Tvsagps_object;
                                         const ATimeoutMSec: DWORD): Boolean;
var
  VT: DWORD;
begin
  VT:=GetTickCount;
  while (gs_DoneDisconnected<>AObj.GPSState) and (GetTickCount-VT<ATimeoutMSec) do
    Sleep(10);
  Result:=(gs_DoneDisconnected=AObj.GPSState);
end;

{ Tvsagps_track_reader_test }

procedure Tvsagps_track_reader_test.TestTrackPointsPauseMSec;
var
  dtPrev, dtCur: TDateTime;
begin
  // the full datetime points
  dtPrev:=EncodeDateTime(2026, 1, 1, 10, 0, 0, 0);

  // the same timestamp - no pause
  dtCur:=dtPrev;
  Check(0=TrackPoints_Pause_MSec(dtPrev, TRUE, dtCur, TRUE),
        'the same timestamp must give no pause');

  // the usual forward move - the real time delta
  dtCur:=IncSecond(dtPrev, 2);
  Check(2000=TrackPoints_Pause_MSec(dtPrev, TRUE, dtCur, TRUE),
        'the forward delta must give the full pause');

  // the big gap - the full pause (no cap in the real time mode)
  dtCur:=IncHour(dtPrev, 1);
  Check(MSecsPerDay div 24=TrackPoints_Pause_MSec(dtPrev, TRUE, dtCur, TRUE),
        'the hour gap must give the hour pause');

  // the backward time (the full datetime) - the pacing restarts
  dtCur:=IncSecond(dtPrev, -2);
  Check(0=TrackPoints_Pause_MSec(dtPrev, TRUE, dtCur, TRUE),
        'the backward time must restart the pacing');

  // the time only points - the midnight wrap is handled
  dtPrev:=EncodeTime(23, 59, 58, 0);
  dtCur:=EncodeTime(0, 0, 2, 0);
  Check(4000=TrackPoints_Pause_MSec(dtPrev, FALSE, dtCur, FALSE),
        'the midnight wrap must give the wrapped pause');

  // the time only points - the backward time inside the day
  dtPrev:=EncodeTime(10, 0, 2, 0);
  dtCur:=EncodeTime(10, 0, 0, 0);
  Check(0=TrackPoints_Pause_MSec(dtPrev, FALSE, dtCur, FALSE),
        'the backward time only must restart the pacing');

  // the mixed date flags (the date disappears) - the pacing restarts
  dtPrev:=EncodeDateTime(2026, 1, 1, 10, 0, 0, 0);
  dtCur:=IncSecond(dtPrev, 2);
  Check(0=TrackPoints_Pause_MSec(dtPrev, TRUE, TimeOf(dtCur), FALSE),
        'the mixed date flags must restart the pacing');
end;

procedure Tvsagps_track_reader_test.TestReplayDeviceRealtimePacing;
var
  VGpxPath: WideString;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VTicks: DWORD;
  VElapsedMSec: DWORD;
  VExpectedMSec: Int64;
begin
  VGpxPath:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP'))+'vsagps_replay_test.gpx';
  ReplayTest_MakeGpxTrack(VGpxPath, cTestTrack_PointCount, cTestTrack_GapSec);
  try
    GReplayTest_Count:=0;
    GReplayTest_FirstTicks:=0;
    GReplayTest_LastTicks:=0;

    ZeroMemory(@VParams, sizeof(VParams));
    VParams.wSize:=sizeof(VParams);
    VParams.btReceiveGPSTimeoutSec:=10;
    VParams.wConnectionTimeoutSec:=30;
    VParams.wWorkerThreadTimeoutMSec:=50;
    VParams.dwSourceFileSpeedMultiplier:=cTestTrack_Multiplier;
    VParams.pTrackPointHandler:=ReplayTest_TrackPointHandler;

    VObj:=Tvsagps_object.Create;
    try
      Check(VObj.GPSConnect(gdt_FILE_Track,
                            AnsiString('replay-test'),
                            PWideChar(VGpxPath),
                            @VParams,
                            nil,
                            nil,
                            @VUnitIndex,
                            nil),
            'GPSConnect failed');

      // wait for all the points to be delivered (the packet thread drains
      // the queue after the device thread paced them out)
      VTicks:=GetTickCount;
      while (GReplayTest_Count<cTestTrack_PointCount) and (GetTickCount-VTicks<15000) do
        Sleep(10);

      // the device must finish the track itself (the EOF disconnects it)
      VTicks:=GetTickCount;
      while (gs_DoneDisconnected<>VObj.GPSState) and (GetTickCount-VTicks<15000) do
        Sleep(10);
      Check(gs_DoneDisconnected=VObj.GPSState, 'the replay device did not finish the track');

      Vsagps_Test_Log(AnsiString(Format('replay test: %d points in %d msec',
                                        [GReplayTest_Count,
                                         GReplayTest_LastTicks-GReplayTest_FirstTicks])));
    finally
      VObj.Free;
    end;

    // all the points must be delivered
    Check(cTestTrack_PointCount=GReplayTest_Count,
          Format('the point count %d <> %d', [GReplayTest_Count, cTestTrack_PointCount]));

    // the delivery must be paced by the timestamps scaled by the multiplier
    VExpectedMSec:=((cTestTrack_PointCount-1)*cTestTrack_GapSec*1000) div cTestTrack_Multiplier;
    VElapsedMSec:=GReplayTest_LastTicks-GReplayTest_FirstTicks;
    Check(VElapsedMSec>=VExpectedMSec div 2,
          Format('the replay is too fast (%d msec < %d msec) - the pacing does not work',
                 [VElapsedMSec, VExpectedMSec div 2]));
    Check(VElapsedMSec<=VExpectedMSec*4,
          Format('the replay is too slow (%d msec > %d msec) - the multiplier does not work',
                 [VElapsedMSec, VExpectedMSec*4]));
  finally
    SysUtils.DeleteFile(VGpxPath);
  end;
end;

procedure Tvsagps_track_reader_test.TestReplayDeviceLoopPlayback;
const
  // the loop track: the small lap repeated until the stop
  cLoopTrack_PointCount = 3;
  cLoopTrack_GapSec = 1;
  cLoopTrack_Multiplier = 10;
  cLapCountMin = 3;
var
  VGpxPath: WideString;
  VObj: Tvsagps_object;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
  VUnitIndex: Byte;
  VTicks: DWORD;
begin
  VGpxPath:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP'))+'vsagps_replay_loop_test.gpx';
  ReplayTest_MakeGpxTrack(VGpxPath, cLoopTrack_PointCount, cLoopTrack_GapSec);
  try
    GReplayTest_Count:=0;
    GReplayTest_FirstTicks:=0;
    GReplayTest_LastTicks:=0;

    ZeroMemory(@VParams, sizeof(VParams));
    VParams.wSize:=sizeof(VParams);
    VParams.btReceiveGPSTimeoutSec:=10;
    VParams.wConnectionTimeoutSec:=30;
    VParams.wWorkerThreadTimeoutMSec:=50;
    VParams.dwSourceFileSpeedMultiplier:=cLoopTrack_Multiplier;
    VParams.dwSourceFileFlagsIn:=dpsffi_LoopPlayback;
    VParams.pTrackPointHandler:=ReplayTest_TrackPointHandler;

    VObj:=Tvsagps_object.Create;
    try
      Check(VObj.GPSConnect(gdt_FILE_Track,
                            AnsiString('replay-loop-test'),
                            PWideChar(VGpxPath),
                            @VParams,
                            nil,
                            nil,
                            @VUnitIndex,
                            nil),
            'GPSConnect failed');

      // the device must keep replaying the laps: wait for several laps
      // (the device does not finish by itself anymore)
      VTicks:=GetTickCount;
      while (GReplayTest_Count<cLapCountMin*cLoopTrack_PointCount) and (GetTickCount-VTicks<15000) do
        Sleep(10);

      // the stop inside a lap (the pacing waits and the parsers must see
      // the stop request and unwind promptly)
      VObj.GPSDisconnect;
      Check(WaitObjectStateDoneDisconnected(VObj, 15000),
            'the looping device is not disconnected after the stop');

      Vsagps_Test_Log(AnsiString(Format('replay loop test: %d points delivered before the stop',
                                        [GReplayTest_Count])));
    finally
      VObj.Free;
    end;

    // the laps must repeat: at least the requested lap count is delivered
    Check(GReplayTest_Count>=cLapCountMin*cLoopTrack_PointCount,
          Format('the loop playback delivered only %d points (expected at least %d)',
                 [GReplayTest_Count, cLapCountMin*cLoopTrack_PointCount]));
  finally
    SysUtils.DeleteFile(VGpxPath);
  end;
end;

initialization
  RegisterTest(Tvsagps_track_reader_test.Suite);

end.
