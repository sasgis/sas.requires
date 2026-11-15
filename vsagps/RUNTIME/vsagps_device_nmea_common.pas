(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_device_nmea_common;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_memory,
  vsagps_public_sysutils,
  vsagps_public_debugstring,
  vsagps_parser_nmea;

const
  cNmea_Buffer_Size = 4096; // $00001000 bytes

  // the limit of the accumulated incomplete data (a garbage stream without
  // the nmea tail must not grow the buffer forever)
  cNmea_GlobalBuffer_MaxSize = 65536; // $00010000 bytes

// common packet format for the nmea devices: DWORD size + data
function NmeaPacketCreate(const AData: Pointer; const ASize: DWORD): Pointer; overload;
function NmeaPacketCreate(const AData: AnsiString): Pointer; overload;
function NmeaPacketSize(const APacket: Pointer): DWORD;
function NmeaPacketData(APacket: Pointer): Pointer;

// append the raw packet data to the global buffer and parse all complete
// nmea sentences with the given parser
function Nmea_ParsePacket(var AGlobalNmeaBuffer: AnsiString;
                          const APacket: Pointer;
                          const AParser: Tvsagps_parser_nmea): DWORD;

// the same, but serialized with the device close path: APCSCloseHandle is
// the critical section passed to the device by SetBaseParams (the device
// close resets the accumulated buffer and the parser state under the same
// critical section, see Tvsagps_device_base.InternalCloseDevice)
function Nmea_ParsePacket_Locked(const APCSCloseHandle: PRTLCriticalSection;
                                 var AGlobalNmeaBuffer: AnsiString;
                                 const APacket: Pointer;
                                 const AParser: Tvsagps_parser_nmea): DWORD;

// apply the gps utc date/time to the system time (gpsc_Apply_UTCDateTime);
// both var parameters mirror the same-named fields of the device objects
procedure NMEA_Apply_UTCDateTime(var ARequestGPSCommand_Apply_UTCDateTime: Boolean;
                                 var ASavedUTCDateTime: TNMEA_Date_Time;
                                 const ADate: PNMEA_Date;
                                 const ATime: PNMEA_Time);

implementation

{ common packet format: DWORD size + data }

function NmeaPacketCreate(const AData: Pointer; const ASize: DWORD): Pointer;
var
  P: PByte;
  VCount: Integer;
begin
  Assert((AData <> nil) and (ASize > 0));
  VCount := SizeOf(DWORD);
  Result := VSAGPS_GetMem(DWORD(VCount) + ASize);
  PDWORD(Result)^ := ASize;
  P := Result;
  Inc(P, VCount);
  Move(AData^, P^, ASize);
end;

function NmeaPacketCreate(const AData: AnsiString): Pointer;
begin
  Assert(AData <> '');
  Result := NmeaPacketCreate(@AData[1], Length(AData));
end;

function NmeaPacketSize(const APacket: Pointer): DWORD;
begin
  Assert(APacket <> nil);
  Result := PDWORD(APacket)^;
end;

function NmeaPacketData(APacket: Pointer): Pointer;
var
  P: PByte absolute APacket;
begin
  Assert(APacket <> nil);
  Inc(P, SizeOf(DWORD));
  Result := P;
end;

{ nmea stream framing }

function Nmea_ParsePacket(var AGlobalNmeaBuffer: AnsiString;
                          const APacket: Pointer;
                          const AParser: Tvsagps_parser_nmea): DWORD;

  function _IsText(AHead, ATail: Integer): Boolean;
  var
    I: Integer;
    P: PByte;
  begin
    Assert(ATail > AHead);
    // check for the BINARY data inside the packed
    // (u-blox can send UBX packets interleaved with NMEA sentences)
    // https://www.sasgis.org/mantis/view.php?id=3596
    P := Pointer(AGlobalNmeaBuffer);
    Inc(P, AHead);
    for I := AHead+1 to ATail-1 do begin
      // allowed values: $0D, $0A, $21..$7E
      if (P^ <= $20) or (P^ >= $7F) then begin
        Result := False;
        Exit;
      end;
      Inc(P);
    end;
    Result := True;
  end;

  function _GetNmeaSentence(var ASentence: AnsiString): Boolean;
  var
    I: Integer;
    VHead, VTail: Integer;
  begin
    Result := False;
    // the whole scan is a loop and not a recursive call: a garbage stream
    // (a wrong port) can deliver thousands of short frames per read, and
    // every recursive call would add a stack frame
    repeat
      VHead := PosA(cNmea_Starter, AGlobalNmeaBuffer);
      if VHead = 0 then begin
        AGlobalNmeaBuffer := '';
        Exit;
      end;
      VTail := PosA(cNmea_Tail, AGlobalNmeaBuffer, VHead + 1);
      if VTail = 0 then
        Exit; // no tail yet - wait for the next packet
      repeat
        // check if there any other Heads between Head and Tail
        I := PosA(cNmea_Starter, AGlobalNmeaBuffer, VHead + 1);
        if (I > 0) and (I < VTail) then begin
          // found another Head before Tail
          {$if defined(USE_NMEA_PROPRIETARY_WITHOUT_TAIL)}
          if (AGlobalNmeaBuffer[VHead+1] = cNmea_Proprietary) and _IsText(VHead, I) then begin
            // ok - return sentence without tail and head
            ASentence := System.Copy(AGlobalNmeaBuffer, VHead + 1, I - VHead - 1);
            System.Delete(AGlobalNmeaBuffer, 1, I-1);
            Result := True;
            Exit;
          end else begin
            VHead := I; // move to the new Head
          end;
          {$else}
          VHead := I; // move to the new Head
          {$ifend}
        end else begin
          Break;
        end;
      until False;
      if not _IsText(VHead, VTail) then begin
        // remove raw data from the buffer and search for the next sentence
        System.Delete(AGlobalNmeaBuffer, 1, VTail + 1);
        Continue;
      end;
      // ok - return sentence with tail but without head
      ASentence := System.Copy(AGlobalNmeaBuffer, VHead + 1, VTail - VHead + 1);
      System.Delete(AGlobalNmeaBuffer, 1, VTail + 1);
      Result := (ASentence <> #13#10) and (Length(ASentence) <= (cNmea_SentenceLenMax - 1));
      if Result then
        Exit;
      // the sentence is empty or too long - search for the next one
    until False;
  end;

var
  I: Integer;
  VSentence: AnsiString;
  VSize: DWORD;
  VData: Pointer;
  VBuffer: PByte;
begin
  {$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Nmea_ParsePacket:');
  {$ifend}
  Result := 0; // not used
  if APacket = nil then begin
    Exit;
  end;
  VSize := NmeaPacketSize(APacket);
  {$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Packet Size: ' + IntToStrA(VSize));
  {$ifend}
  if VSize = 0 then begin
    Exit;
  end;
  VData := NmeaPacketData(APacket);

  I := Length(AGlobalNmeaBuffer);
  SetLength(AGlobalNmeaBuffer, DWORD(I) + VSize);

  VBuffer := Pointer(AGlobalNmeaBuffer);
  Inc(VBuffer, I);

  Move(VData^, VBuffer^, VSize);

  while _GetNmeaSentence(VSentence) do begin
    {$if defined(VSAGPS_USE_DEBUG_STRING_NMEA_SENTENCE)}
    VSAGPS_DebugAnsiString(StringReplaceA(VSentence, #13#10, '\r\n', [rfReplaceAll]));
    {$ifend}
    AParser.Parse_Sentence_Without_Starter(VSentence);
  end;

  // limit the accumulated incomplete data: a wrong port or a non-nmea
  // stream without the sentence tail must not grow the buffer forever
  I := Length(AGlobalNmeaBuffer);
  if (I > cNmea_GlobalBuffer_MaxSize) then begin
    {$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Nmea_ParsePacket: buffer truncated');
    {$ifend}
    // drop the head - keep the tail
    System.Delete(AGlobalNmeaBuffer, 1, I - cNmea_GlobalBuffer_MaxSize);
    // align to the first sentence starter of the retained tail (drop the
    // broken prefix of the truncated sentence)
    I := PosA(cNmea_Starter, AGlobalNmeaBuffer);
    if (0 = I) then
      AGlobalNmeaBuffer := ''
    else if (I > 1) then
      System.Delete(AGlobalNmeaBuffer, 1, I - 1);
  end;
end;

function Nmea_ParsePacket_Locked(const APCSCloseHandle: PRTLCriticalSection;
                                 var AGlobalNmeaBuffer: AnsiString;
                                 const APacket: Pointer;
                                 const AParser: Tvsagps_parser_nmea): DWORD;
begin
  // ParsePacket is called from the packet parser thread while the device
  // working thread (or the main thread) may close the device concurrently:
  // InternalCloseDevice resets the parsing state (the accumulated buffer,
  // the parser counters, the saved utc date/time) under the same critical
  // section, so both sides can not run at once. The section is reentrant,
  // so a degenerate usage (the device destroyed from a parsing callback)
  // degrades gracefully instead of locking up.
  if (APCSCloseHandle<>nil) then
    EnterCriticalSection(APCSCloseHandle^);
  try
    Result := Nmea_ParsePacket(AGlobalNmeaBuffer, APacket, AParser);
  finally
    if (APCSCloseHandle<>nil) then
      LeaveCriticalSection(APCSCloseHandle^);
  end;
end;

{ gps utc date/time applying }

procedure NMEA_Apply_UTCDateTime(var ARequestGPSCommand_Apply_UTCDateTime: Boolean;
                                 var ASavedUTCDateTime: TNMEA_Date_Time;
                                 const ADate: PNMEA_Date;
                                 const ATime: PNMEA_Time);

  function InternalSetSysTime: Boolean;
  var
    t: TSystemTime;
  begin
    // date
    if (ADate<>nil) then begin
      t.wYear:=Convert_TwoDigitYear_to_FourDigitYear(ADate^.year);
      t.wMonth:=ADate^.month;
      t.wDay:=ADate^.day;
    end else begin
      t.wYear:=ASavedUTCDateTime.date.year; // 4-Digit!
      t.wMonth:=ASavedUTCDateTime.date.month;
      t.wDay:=ASavedUTCDateTime.date.day;
    end;
    t.wDayOfWeek:=0;
    // time
    t.wHour:=ATime^.hour;
    t.wMinute:=ATime^.min;
    t.wSecond:=ATime^.sec;
    t.wMilliseconds:=ATime^.msec;
    // set
    Result:=(SetSystemTime(t)<>FALSE);

    if (not Result) then begin
      ARequestGPSCommand_Apply_UTCDateTime:=FALSE; // no privileges or other errors (permanent result)
    end;
  end;

begin
  if (not ARequestGPSCommand_Apply_UTCDateTime) then
    Exit;

  // only if date and time are valid (both)
  if (not NMEA_Date_Valid(ADate)) OR (not NMEA_Time_Valid(ATime)) then
    Exit;

  // we should set time on very first sentence with NEW time
  // so we should SAVE datetime on first sentence and wait for next timestamp
  if NMEA_Date_Time_Valid(@ASavedUTCDateTime) then begin
    // check for new time
    if (ASavedUTCDateTime.time.sec<>ATime^.sec) and (ASavedUTCDateTime.time.min=ATime^.min) then begin
      // new seconds (minutes, hours and date remains the same)
      if InternalSetSysTime then begin
        // well done
        ARequestGPSCommand_Apply_UTCDateTime:=FALSE;
        Exit;
      end;
    end;
  end;

  // save current to special field - only if with date
  if (ADate<>nil) then begin
    ASavedUTCDateTime.date:=ADate^;
    ASavedUTCDateTime.time:=ATime^;
    // convert to 4-Digit
    ASavedUTCDateTime.date.year:=Convert_TwoDigitYear_to_FourDigitYear(ASavedUTCDateTime.date.year);
  end;
end;

end.
