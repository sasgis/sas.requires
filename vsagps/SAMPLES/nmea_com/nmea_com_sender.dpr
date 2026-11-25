program nmea_com_sender;
(*
  NMEA0183 COM port sender - a simple GPS receiver emulator for manual tests
  of the COM NMEA device with a virtual serial port pair (com0com).

  The tool emulates a receiver which periodically goes to sleep and switches
  off: it opens the port, sends a short GGA/RMC stream (10 sentences by
  default), pauses, closes the port for several seconds, then opens the same
  port again and repeats the cycle. Closing the port is the "receiver is
  off" part of the emulation, so the application under test can check that it
  detects the missing signal and the signal coming back.

  The paired port is read by nmea_com_receiver.exe (or by the vsagps COM
  device under test). The tool uses only the Win32 API and does not depend on
  the vsagps units - it is the external half of the test link.

  Command line:
    /port=COM3       - the port to write to (default: COM3)
    /baud=4800       - the baud rate (default: 4800)
    /count=10        - sentences per cycle (default: 10)
    /interval=200    - delay between sentences, ms (default: 200)
    /pause=2000      - silent pause before the port is closed, ms (default: 2000)
    /offline=5000    - the port stays closed, ms (default: 5000)
    /cycles=N        - stop after N cycles (0 = endless, default: 0)
    /verbose         - print every transmitted/received sentence
    /help            - this text

  The port is opened as 8N1 with the requested baud rate; incoming data (the
  queries an application under test may send) is drained and, with /verbose,
  printed.
*)

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

const
  cAppName = 'nmea_com_sender';
  cDefaultPort = 'COM3';
  cDefaultBaud = 4800;
  cDefaultCount = 10;
  cDefaultIntervalMs = 200;
  cDefaultPauseMs = 2000;
  cDefaultOfflineMs = 5000;
  // com0com does not implement the documented "return at once" zero read
  // timeout (ReadFile blocks forever), so the input drain waits a few ms
  cDrainReadTimeoutMs = 10;

var
  GStopRequested: Boolean = False;
  GLastOpenError: DWORD = 0;

function ConsoleCtrlHandler(ACtrlType: DWORD): BOOL; stdcall;
begin
  Result := False;
  if (ACtrlType = CTRL_C_EVENT) or (ACtrlType = CTRL_BREAK_EVENT) then begin
    GStopRequested := True;
    Result := True;
  end;
end;

procedure Log(const AText: string);
begin
  Writeln(FormatDateTime('HH:nn:ss.zzz', Now), ' ', AText);
end;

procedure Usage;
begin
  Writeln(cAppName + ' - NMEA0183 COM sender (GPS receiver emulator)');
  Writeln('');
  Writeln('Usage: ' + cAppName + '.exe [options]');
  Writeln('');
  Writeln('  /port=NAME       port to write to (default: ' + cDefaultPort + ')');
  Writeln('  /baud=N          baud rate (default: ' + IntToStr(cDefaultBaud) + ')');
  Writeln('  /count=N         sentences per cycle (default: ' + IntToStr(cDefaultCount) + ')');
  Writeln('  /interval=MS     delay between sentences (default: ' + IntToStr(cDefaultIntervalMs) + ')');
  Writeln('  /pause=MS        silent pause before closing the port (default: ' + IntToStr(cDefaultPauseMs) + ')');
  Writeln('  /offline=MS      time the port stays closed (default: ' + IntToStr(cDefaultOfflineMs) + ')');
  Writeln('  /cycles=N        number of cycles, 0 = endless (default: 0)');
  Writeln('  /verbose         print every sentence');
  Writeln('  /help            this text');
end;

function HasParam(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do begin
    if SameText(ParamStr(I), '/' + AName) or SameText(ParamStr(I), '-' + AName) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function ParamValue(const AName, ADefault: string): string;
var
  I: Integer;
  VParam: string;
begin
  Result := ADefault;
  for I := 1 to ParamCount do begin
    VParam := ParamStr(I);
    if VParam.StartsWith('/' + AName + '=', True) or
       VParam.StartsWith('-' + AName + '=', True) then
      Result := Copy(VParam, Length(AName) + 3, MaxInt);
  end;
end;

procedure WaitMs(AMSec: Integer);
var
  VEnd: UInt64;
  VNow: UInt64;
  VLeft: UInt64;
begin
  if AMSec <= 0 then
    Exit;
  VEnd := GetTickCount64 + UInt64(AMSec);
  while not GStopRequested do begin
    VNow := GetTickCount64;
    if VNow >= VEnd then
      Break;
    VLeft := VEnd - VNow;
    if VLeft > 50 then
      Sleep(50)
    else
      Sleep(Cardinal(VLeft));
  end;
end;

function PadInt(AValue, AWidth: Integer): string;
begin
  Result := IntToStr(AValue);
  while Length(Result) < AWidth do
    Result := '0' + Result;
end;

// degrees and minutes (minutes are in 1/10000) as the NMEA "ddmm.mmmm" form
function CoordStr(ADeg, AMinTenThousandths, ADegWidth: Integer): string;
begin
  Result := PadInt(ADeg, ADegWidth) +
    PadInt(AMinTenThousandths div 10000, 2) + '.' +
    PadInt(AMinTenThousandths mod 10000, 4);
end;

procedure CurrentNmeaTime(out ATime, ADate: string);
var
  VST: TSystemTime;
begin
  GetSystemTime(VST);
  ATime := Format('%.2d%.2d%.2d.%.2d',
    [VST.wHour, VST.wMinute, VST.wSecond, VST.wMilliseconds div 10]);
  ADate := Format('%.2d%.2d%.2d', [VST.wDay, VST.wMonth, VST.wYear mod 100]);
end;

// complete NMEA sentence with the checksum and the CRLF tail (the caller
// encodes it to the ASCII bytes with TEncoding.ASCII.GetBytes)
function NmeaSentenceText(const ABody: string): string;
var
  I: Integer;
  VSum: Byte;
begin
  VSum := 0;
  for I := 1 to Length(ABody) do
    VSum := VSum xor Byte(Ord(ABody[I]) and $FF);
  Result := '$' + ABody + '*' + IntToHex(VSum, 2) + #13#10;
end;

function OpenPort(const APortName: string; ABaud: DWORD; AReadTimeoutMs: DWORD;
  out AHandle: THandle; out AError: string): Boolean;
var
  VName: string;
  VDCB: TDCB;
  VTimeouts: TCommTimeouts;
begin
  Result := False;
  AHandle := INVALID_HANDLE_VALUE;
  AError := '';

  if APortName.StartsWith('\\.\', False) then
    VName := APortName
  else
    VName := '\\.\' + APortName;

  GLastOpenError := 0;

  AHandle := CreateFile(PChar(VName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if AHandle = INVALID_HANDLE_VALUE then begin
    GLastOpenError := GetLastError;
    AError := SysErrorMessage(GLastOpenError);
    Exit;
  end;

  FillChar(VDCB, SizeOf(VDCB), 0);
  VDCB.DCBlength := SizeOf(VDCB);
  if not GetCommState(AHandle, VDCB) then begin
    AError := 'GetCommState: ' + SysErrorMessage(GetLastError);
    CloseHandle(AHandle);
    AHandle := INVALID_HANDLE_VALUE;
    Exit;
  end;
  // 8N1, no software/hardware flow control, DTR and RTS asserted
  if not BuildCommDCB(PChar(Format(
    'baud=%d parity=N data=8 stop=1 xon=off octs=off odsr=off idsr=off dtr=on rts=on',
    [ABaud])), VDCB) then begin
    AError := 'BuildCommDCB: ' + SysErrorMessage(GetLastError);
    CloseHandle(AHandle);
    AHandle := INVALID_HANDLE_VALUE;
    Exit;
  end;
  if not SetCommState(AHandle, VDCB) then begin
    AError := 'SetCommState: ' + SysErrorMessage(GetLastError);
    CloseHandle(AHandle);
    AHandle := INVALID_HANDLE_VALUE;
    Exit;
  end;

  SetupComm(AHandle, 8192, 8192);

  VTimeouts.ReadIntervalTimeout := MAXDWORD;
  VTimeouts.ReadTotalTimeoutMultiplier := MAXDWORD;
  VTimeouts.ReadTotalTimeoutConstant := AReadTimeoutMs;
  VTimeouts.WriteTotalTimeoutMultiplier := 0;
  VTimeouts.WriteTotalTimeoutConstant := 2000;
  if not SetCommTimeouts(AHandle, VTimeouts) then begin
    AError := 'SetCommTimeouts: ' + SysErrorMessage(GetLastError);
    CloseHandle(AHandle);
    AHandle := INVALID_HANDLE_VALUE;
    Exit;
  end;

  EscapeCommFunction(AHandle, SETDTR);
  EscapeCommFunction(AHandle, SETRTS);
  PurgeComm(AHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);

  Result := True;
end;

procedure ClosePort(var AHandle: THandle);
begin
  if AHandle <> INVALID_HANDLE_VALUE then begin
    PurgeComm(AHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
    CloseHandle(AHandle);
    AHandle := INVALID_HANDLE_VALUE;
  end;
end;

function WriteAll(AHandle: THandle; const AData: TBytes; out AError: string): Boolean;
var
  VOffset: Integer;
  VWritten: DWORD;
begin
  Result := False;
  AError := '';
  VOffset := 0;
  while VOffset < Length(AData) do begin
    if not WriteFile(AHandle, AData[VOffset],
      DWORD(Length(AData) - VOffset), VWritten, nil) then begin
      AError := SysErrorMessage(GetLastError);
      Exit;
    end;
    if VWritten = 0 then begin
      // com0com accepts 0 bytes while the peer port is closed; a real port
      // reports a write timeout instead
      AError := 'the port accepted 0 bytes (is the peer port closed?)';
      Exit;
    end;
    Inc(VOffset, Integer(VWritten));
  end;
  FlushFileBuffers(AHandle);
  Result := True;
end;

// short-wait drain of the input buffer (the queries of the application under
// test): the port read timeout is cDrainReadTimeoutMs, so every call costs up
// to that many ms when there is nothing to read
function DrainInput(AHandle: THandle; out AData: TBytes): Boolean;
var
  VBuf: array [0..1023] of Byte;
  VRead: DWORD;
  VOldLen: Integer;
  VGuard: Integer;
begin
  SetLength(AData, 0);
  Result := True;
  VGuard := 0;
  while VGuard < 64 do begin
    Inc(VGuard);
    if not ReadFile(AHandle, VBuf[0], SizeOf(VBuf), VRead, nil) then begin
      Result := False;
      Exit;
    end;
    if VRead = 0 then
      Break;
    VOldLen := Length(AData);
    SetLength(AData, VOldLen + Integer(VRead));
    Move(VBuf[0], AData[VOldLen], Integer(VRead));
  end;
end;

var
  VPort: string;
  VBaud: Integer;
  VCount: Integer;
  VIntervalMs: Integer;
  VPauseMs: Integer;
  VOfflineMs: Integer;
  VCycles: Integer;
  VVerbose: Boolean;
  VHandle: THandle;
  VCycle: Integer;
  VSent: Integer;
  VTotalSent: Integer;
  VErrors: Integer;
  VTime: string;
  VDate: string;
  VSentenceText: string;
  VSentence: TBytes;
  VRx: TBytes;
  VWriteError: string;
  VLatDeg: Integer;
  VLatMin: Integer;
  VLonDeg: Integer;
  VLonMin: Integer;
  VOpen: Boolean;
  VWriteFailed: Boolean;
  VError: string;
  VHint: string;
  I: Integer;

begin
  SetConsoleCtrlHandler(@ConsoleCtrlHandler, True);

  if HasParam('help') or HasParam('?') then begin
    Usage;
    ExitCode := 0;
    Exit;
  end;

  VPort := Trim(ParamValue('port', cDefaultPort));
  if VPort = '' then
    VPort := cDefaultPort;
  VBaud := StrToIntDef(ParamValue('baud', IntToStr(cDefaultBaud)), cDefaultBaud);
  if VBaud <= 0 then
    VBaud := cDefaultBaud;
  VCount := StrToIntDef(ParamValue('count', IntToStr(cDefaultCount)), cDefaultCount);
  if VCount < 1 then
    VCount := 1;
  VIntervalMs := StrToIntDef(ParamValue('interval', IntToStr(cDefaultIntervalMs)), cDefaultIntervalMs);
  if VIntervalMs < 0 then
    VIntervalMs := 0;
  VPauseMs := StrToIntDef(ParamValue('pause', IntToStr(cDefaultPauseMs)), cDefaultPauseMs);
  if VPauseMs < 0 then
    VPauseMs := 0;
  VOfflineMs := StrToIntDef(ParamValue('offline', IntToStr(cDefaultOfflineMs)), cDefaultOfflineMs);
  if VOfflineMs < 0 then
    VOfflineMs := 0;
  VCycles := StrToIntDef(ParamValue('cycles', '0'), 0);
  if VCycles < 0 then
    VCycles := 0;
  VVerbose := HasParam('verbose');

  Writeln(cAppName + ': ' + VPort + ', ' + IntToStr(VBaud) + ' baud, ' +
    IntToStr(VCount) + ' sentences per cycle, interval ' + IntToStr(VIntervalMs) +
    ' ms, pause ' + IntToStr(VPauseMs) + ' ms, offline ' + IntToStr(VOfflineMs) + ' ms');
  if VCycles > 0 then
    Writeln('cycles: ' + IntToStr(VCycles) + ' (then stop)')
  else
    Writeln('cycles: endless (press Ctrl+C to stop)');
  Writeln('');

  VHandle := INVALID_HANDLE_VALUE;
  VCycle := 0;
  VTotalSent := 0;
  VErrors := 0;
  VLatDeg := 55;
  VLatMin := 455000; // 55 45.5000 N
  VLonDeg := 37;
  VLonMin := 375000; // 37 37.5000 E

  while not GStopRequested do begin
    if (VCycles > 0) and (VCycle >= VCycles) then
      Break;
    Inc(VCycle);

    Log(Format('cycle %d: opening %s (%d baud, 8N1)', [VCycle, VPort, VBaud]));
    VOpen := False;
    while not GStopRequested do begin
      if OpenPort(VPort, DWORD(VBaud), cDrainReadTimeoutMs, VHandle, VError) then begin
        VOpen := True;
        Break;
      end;
      VHint := '';
      if GLastOpenError = ERROR_ACCESS_DENIED then
        VHint := ' (the port is held by another process: a second sender ' +
          'instance, or the GPS application''s COM autodetect scan)';
      Log('  cannot open ' + VPort + ': ' + VError + VHint + ' - retrying in 1 s');
      WaitMs(1000);
    end;
    if not VOpen then
      Break;
    Log(Format('cycle %d: port opened (emulated GPS is on)', [VCycle]));

    VSent := 0;
    VWriteFailed := False;
    try
      for I := 1 to VCount do begin
        if GStopRequested then
          Break;

        if (I mod 2) = 1 then begin
          // one coordinate step per GGA/RMC pair
          Inc(VLatMin, 30);
          if VLatMin >= 600000 then begin
            VLatMin := 0;
            Inc(VLatDeg);
            if VLatDeg > 89 then
              VLatDeg := 0;
          end;
          Inc(VLonMin, 30);
          if VLonMin >= 600000 then begin
            VLonMin := 0;
            Inc(VLonDeg);
            if VLonDeg > 179 then
              VLonDeg := 0;
          end;
          CurrentNmeaTime(VTime, VDate);
          VSentenceText := NmeaSentenceText(
            'GPGGA,' + VTime + ',' +
            CoordStr(VLatDeg, VLatMin, 2) + ',N,' +
            CoordStr(VLonDeg, VLonMin, 3) + ',E,1,08,0.9,120.0,M,0.0,M,,');
        end else begin
          VSentenceText := NmeaSentenceText(
            'GPRMC,' + VTime + ',A,' +
            CoordStr(VLatDeg, VLatMin, 2) + ',N,' +
            CoordStr(VLonDeg, VLonMin, 3) + ',E,0.5,45.0,' + VDate + ',,,A');
        end;

        VSentence := TEncoding.ASCII.GetBytes(VSentenceText);

        if not WriteAll(VHandle, VSentence, VWriteError) then begin
          Inc(VErrors);
          VWriteFailed := True;
          Log('  write failed: ' + VWriteError);
          Break;
        end;
        Inc(VSent);
        Inc(VTotalSent);
        if VVerbose then
          Log('  tx ' + Trim(VSentenceText));

        if not DrainInput(VHandle, VRx) then begin
          Inc(VErrors);
          Log('  read failed: ' + SysErrorMessage(GetLastError));
          Break;
        end;
        if (Length(VRx) > 0) and VVerbose then
          Log('  rx ' + Trim(TEncoding.ASCII.GetString(VRx)));

        if I < VCount then
          WaitMs(VIntervalMs);
      end;

      if (not GStopRequested) and (not VWriteFailed) and (VSent > 0) then begin
        Log(Format('cycle %d: sent %d sentences, pause %d ms (port stays open)',
          [VCycle, VSent, VPauseMs]));
        WaitMs(VPauseMs);
      end;
    finally
      ClosePort(VHandle);
    end;

    if GStopRequested then
      Log(Format('cycle %d: port %s closed', [VCycle, VPort]))
    else begin
      Log(Format('cycle %d: port %s closed (emulated GPS is off for %d ms)',
        [VCycle, VPort, VOfflineMs]));
      WaitMs(VOfflineMs);
    end;
  end;

  ClosePort(VHandle);
  Writeln('');
  Log(Format('stopped: %d cycles, %d sentences sent, %d port errors',
    [VCycle, VTotalSent, VErrors]));
  ExitCode := 0;
end.
