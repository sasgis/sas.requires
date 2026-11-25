program nmea_com_receiver;
(*
  NMEA0183 COM port receiver - a simple signal monitor for manual tests of
  the COM NMEA device with a virtual serial port pair (com0com).

  The tool is the counterpart of nmea_com_sender.exe: it opens the paired
  port, reads the NMEA stream, validates the sentence checksums and reports
  the signal state:
    - "SIGNAL ACQUIRED" on the first received data;
    - "SIGNAL LOST" when no data arrives for the timeout;
    - "SIGNAL RESTORED after N ms of silence" when the data comes back.

  The virtual null-modem pair does not report the closing of the peer port,
  so the absence of data (the same idle watchdog the vsagps COM device uses)
  is the loss detector. The tool uses only the Win32 API and does not depend
  on the vsagps units.

  Command line:
    /port=COM4       - the port to read (default: COM4)
    /baud=4800       - the baud rate (default: 4800)
    /timeout=3000    - signal loss timeout, ms (default: 3000)
    /cycles=N        - stop after N signal acquisitions (0 = endless, default: 0)
    /verbose         - print every received sentence
    /help            - this text
*)

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

const
  cAppName = 'nmea_com_receiver';
  cDefaultPort = 'COM4';
  cDefaultBaud = 4800;
  cDefaultTimeoutMs = 3000;
  cReadTimeoutMs = 250;
  cStatusIntervalMs = 1000;

type
  TReceiverStats = record
    Bytes: Int64;
    Sentences: Int64;
    Gga: Int64;
    Rmc: Int64;
    Other: Int64;
    BadChecksum: Int64;
    GarbageLines: Int64;
    RxErrors: Int64;
    Acquisitions: Int64;
    Losses: Int64;
    LongestSilenceMs: UInt64;
    LastType: string;
  end;

var
  GStopRequested: Boolean = False;

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
  Writeln(cAppName + ' - NMEA0183 COM receiver (signal monitor)');
  Writeln('');
  Writeln('Usage: ' + cAppName + '.exe [options]');
  Writeln('');
  Writeln('  /port=NAME       port to read (default: ' + cDefaultPort + ')');
  Writeln('  /baud=N          baud rate (default: ' + IntToStr(cDefaultBaud) + ')');
  Writeln('  /timeout=MS      signal loss timeout (default: ' + IntToStr(cDefaultTimeoutMs) + ')');
  Writeln('  /cycles=N        stop after N signal acquisitions (0 = endless, default: 0)');
  Writeln('  /verbose         print every received sentence');
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

  AHandle := CreateFile(PChar(VName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if AHandle = INVALID_HANDLE_VALUE then begin
    AError := SysErrorMessage(GetLastError);
    Exit;
  end;

  FillChar(VDCB, SizeOf(VDCB), 0);
  VDCB.DCBlength := SizeOf(VDCB);
  if not BuildCommDCB(PChar(Format('baud=%d parity=N data=8 stop=1', [ABaud])), VDCB) then begin
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

  // the read returns immediately with the buffered bytes or waits up to
  // AReadTimeoutMs for the first byte - the main loop stays responsive
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

function OpenPortWait(const APortName: string; ABaud: DWORD; AReadTimeoutMs: DWORD;
  out AHandle: THandle): Boolean;
var
  VError: string;
begin
  AHandle := INVALID_HANDLE_VALUE;
  Result := False;
  while not GStopRequested do begin
    if OpenPort(APortName, ABaud, AReadTimeoutMs, AHandle, VError) then begin
      Result := True;
      Exit;
    end;
    Log('cannot open ' + APortName + ': ' + VError + ' - retrying in 1 s');
    WaitMs(1000);
  end;
end;

function ExtractLine(var ABuffer: string; out ALine: string): Boolean;
var
  I, L: Integer;
begin
  Result := False;
  L := Length(ABuffer);
  for I := 1 to L do begin
    if ABuffer[I] = #10 then begin
      ALine := Copy(ABuffer, 1, I - 1);
      Delete(ABuffer, 1, I);
      Result := True;
      Exit;
    end;
  end;
end;

// checksum of the sentence body: XOR of all bytes between '$' and '*'
function ParseNmea(const ALine: string; out AType: string; out AChecksumOk: Boolean): Boolean;
var
  VStar, I, VComma: Integer;
  VSum: Byte;
  VBody: string;
begin
  Result := False;
  AType := '';
  AChecksumOk := False;
  if (Length(ALine) < 7) or (ALine[1] <> '$') then
    Exit;

  VStar := Pos('*', ALine);
  if VStar < 2 then
    Exit;

  VSum := 0;
  for I := 2 to VStar - 1 do
    VSum := VSum xor Byte(Ord(ALine[I]) and $FF);
  AChecksumOk := SameText(Copy(ALine, VStar + 1, 2), IntToHex(VSum, 2));

  VBody := Copy(ALine, 2, VStar - 2);
  VComma := Pos(',', VBody);
  if VComma > 0 then
    AType := Copy(VBody, 1, VComma - 1)
  else
    AType := VBody;

  Result := True;
end;

procedure ProcessLines(var ABuffer: string; var AStats: TReceiverStats;
  AVerbose: Boolean);
var
  VLine: string;
  VText, VType: string;
  VChecksumOk: Boolean;
begin
  while ExtractLine(ABuffer, VLine) do begin
    VText := Trim(VLine);
    if VText = '' then
      Continue;

    if VText[1] = '$' then begin
      if ParseNmea(VText, VType, VChecksumOk) then begin
        Inc(AStats.Sentences);
        if VChecksumOk then begin
          if (Length(VType) >= 3) and
             SameText(Copy(VType, Length(VType) - 2, 3), 'GGA') then
            Inc(AStats.Gga)
          else if (Length(VType) >= 3) and
                  SameText(Copy(VType, Length(VType) - 2, 3), 'RMC') then
            Inc(AStats.Rmc)
          else
            Inc(AStats.Other);
          AStats.LastType := VType;
          if AVerbose then
            Log('  rx ' + VText);
        end else begin
          Inc(AStats.BadChecksum);
          Log('*** bad checksum: ' + VText + ' ***');
        end;
      end else begin
        Inc(AStats.GarbageLines);
        if AStats.GarbageLines <= 5 then
          Log('*** malformed sentence: ' + VText + ' ***');
      end;
    end else begin
      Inc(AStats.GarbageLines);
      if AStats.GarbageLines <= 5 then
        Log('*** garbage: ' + VText + ' ***');
    end;
  end;

  // a broken stream without the line ends must not grow the buffer forever
  if Length(ABuffer) > 65536 then begin
    Inc(AStats.GarbageLines);
    ABuffer := '';
  end;
end;

var
  VPort: string;
  VBaud: Integer;
  VTimeoutMs: Cardinal;
  VCycles: Integer;
  VVerbose: Boolean;
  VHandle: THandle;
  VBuf: TBytes;
  VRead: DWORD;
  VBuffer: string;
  VStats: TReceiverStats;
  VSignalOn: Boolean;
  VLastDataTick: UInt64;
  VSignalLostTick: UInt64;
  VLastStatusTick: UInt64;
  VStartTick: UInt64;
  VNow: UInt64;
  VSilenceMs: UInt64;
  VOpen: Boolean;

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
  VTimeoutMs := Cardinal(StrToIntDef(ParamValue('timeout', IntToStr(cDefaultTimeoutMs)),
    cDefaultTimeoutMs));
  if VTimeoutMs < 1 then
    VTimeoutMs := 1;
  VCycles := StrToIntDef(ParamValue('cycles', '0'), 0);
  if VCycles < 0 then
    VCycles := 0;
  VVerbose := HasParam('verbose');

  Writeln(cAppName + ': ' + VPort + ', ' + IntToStr(VBaud) + ' baud, 8N1, signal timeout ' +
    IntToStr(VTimeoutMs) + ' ms');
  if VCycles > 0 then
    Writeln('stop after ' + IntToStr(VCycles) + ' signal acquisitions')
  else
    Writeln('Press Ctrl+C to stop.');
  Writeln('');

  FillChar(VStats, SizeOf(VStats), 0);
  VBuffer := '';
  SetLength(VBuf, 1024);
  VSignalOn := False;
  VLastDataTick := 0;
  VSignalLostTick := 0;
  VLastStatusTick := 0;

  VHandle := INVALID_HANDLE_VALUE;
  VOpen := OpenPortWait(VPort, DWORD(VBaud), cReadTimeoutMs, VHandle);
  if VOpen then
    Log('port ' + VPort + ' opened, waiting for the NMEA stream');

  while VOpen and (not GStopRequested) do begin
    VStartTick := GetTickCount64;
    if not ReadFile(VHandle, VBuf[0], DWORD(Length(VBuf)), VRead, nil) then begin
      Inc(VStats.RxErrors);
      Log('*** read failed: ' + SysErrorMessage(GetLastError) + ' - reopening the port ***');
      if VSignalOn then begin
        VSignalOn := False;
        Inc(VStats.Losses);
        VSignalLostTick := VLastDataTick;
      end;
      ClosePort(VHandle);
      WaitMs(500);
      if not OpenPortWait(VPort, DWORD(VBaud), cReadTimeoutMs, VHandle) then
        Break;
      Log('port ' + VPort + ' reopened');
      Continue;
    end;

    VNow := GetTickCount64;

    if VRead > 0 then begin
      VLastDataTick := VNow;
      VStats.Bytes := VStats.Bytes + VRead;

      if not VSignalOn then begin
        VSignalOn := True;
        Inc(VStats.Acquisitions);
        if (VCycles > 0) and (VStats.Acquisitions >= VCycles) then
          GStopRequested := True;
        if VSignalLostTick <> 0 then begin
          VSilenceMs := VNow - VSignalLostTick;
          if VSilenceMs > VStats.LongestSilenceMs then
            VStats.LongestSilenceMs := VSilenceMs;
          Log(Format('*** SIGNAL RESTORED after %d ms of silence ***', [VSilenceMs]));
        end else
          Log('*** SIGNAL ACQUIRED ***');
        VSignalLostTick := 0;
      end;

      VBuffer := VBuffer + TEncoding.ASCII.GetString(VBuf, 0, Integer(VRead));
      ProcessLines(VBuffer, VStats, VVerbose);
    end else begin
      // the read timeout expired - no data in the port
      if VSignalOn and ((VNow - VLastDataTick) >= VTimeoutMs) then begin
        VSignalOn := False;
        Inc(VStats.Losses);
        VSignalLostTick := VLastDataTick;
        Log(Format('*** SIGNAL LOST: no data for %d ms ***', [VTimeoutMs]));
      end;

      // a port which reports 0 bytes at once must not turn into a busy loop
      if (VNow - VStartTick) < 10 then
        Sleep(10);
    end;

    if VSignalOn and ((VNow - VLastStatusTick) >= cStatusIntervalMs) then begin
      VLastStatusTick := VNow;
      Log(Format('signal ON: sentences=%d (GGA=%d RMC=%d other=%d) bad=%d bytes=%d last=%s',
        [VStats.Sentences, VStats.Gga, VStats.Rmc, VStats.Other,
         VStats.BadChecksum, VStats.Bytes, VStats.LastType]));
    end;
  end;

  ClosePort(VHandle);

  Writeln('');
  Log(Format('stopped: acquisitions=%d losses=%d sentences=%d (GGA=%d RMC=%d other=%d) ' +
    'bad checksums=%d garbage=%d read errors=%d bytes=%d longest silence=%d ms',
    [VStats.Acquisitions, VStats.Losses, VStats.Sentences, VStats.Gga, VStats.Rmc,
     VStats.Other, VStats.BadChecksum, VStats.GarbageLines, VStats.RxErrors,
     VStats.Bytes, VStats.LongestSilenceMs]));
  ExitCode := 0;
end.
