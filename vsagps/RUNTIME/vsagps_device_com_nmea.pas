(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_device_com_nmea;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_classes,
  vsagps_public_sysutils,
  vsagps_public_device,
  vsagps_public_nmea,
  vsagps_tools,
  vsagps_device_base,
  vsagps_parser_nmea,
  vsagps_runtime;

const
  cNmea_Buffer_Size = 4096; // $00001000 bytes

type
  Tvsagps_device_com_nmea = class(Tvsagps_device_with_nmea)
  private
    FParser: Tvsagps_parser_nmea;
    FNMEABuffer: array [0..cNmea_Buffer_Size-1] of AnsiChar;
    FGlobalNmeaBuffer: AnsiString;
    FDCB_Str_Info_A: AnsiString;
    FSavedUTCDateTime: TNMEA_Date_Time;
  private
    procedure Internal_Query_GPSDeviceName;
    procedure InternalMakeAutodetectObject;
    procedure InternalResetProprietaries;
  private
    procedure Do_RequestGPSCommand_Apply_UTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
  protected
    FUserIni: TStringListA;
    FIniReadOnly: Boolean;
    procedure InternalLoadUserIni;
    procedure InternalSendUserPackets;
  protected
    // parsers for proprietary sentences
    function Parse_Proprietary_CSI_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_DME_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_EMT_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_GRM_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_MGN_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_MTK_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_RWI_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_SLI_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_SRF_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_STI_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_TNL_Data(const AData, ASubCommand: AnsiString): DWORD;
    function Parse_Proprietary_XEM_Data(const AData, ASubCommand: AnsiString): DWORD;
    // nmea parsers
    function Internal_Parse_NmeaComm_Packets(const pPacket: PAnsiChar): DWORD;
  protected
    procedure InternalResetDeviceConnectionParams; override;
    procedure Internal_Before_Open_Device; override;
    procedure Internal_Before_Close_Device; override;
    // start session - operations to establish connection
    function WorkingThread_StartSession: Boolean; override;
    // send query packet to gps
    function WorkingThread_SendPacket: Boolean; override;
    // receive packets from device to queue
    function WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean; override;
    // complete and send nmea packet
    function Send_NmeaComm_Packet(const AFullPacket: AnsiString): Boolean;

    function Make_and_Send_NmeaComm_Packet(const AIncompletePacket: AnsiString): Boolean;

    function Make_and_Send_NmeaComm_Packets(const sl_sent: TStringsA): Integer;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ExecuteGPSCommand(const ACommand: LongInt;
                                const APointer: Pointer); override;
    function SerializePacket(const APacket: Pointer): PAnsiChar; override;
    function ParsePacket(const ABuffer: Pointer): DWORD; override;

    function SendPacket(const APacketBuffer: Pointer;
                        const APacketSize: DWORD;
                        const AFlags: DWORD): LongBool; override;
  end;

implementation

uses
  vsagps_public_unit_info,
  vsagps_public_memory,
  vsagps_public_debugstring,
  vsagps_com_checker,
  vsagps_ini;

{ Tvsagps_device_com_nmea }

constructor Tvsagps_device_com_nmea.Create;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Create: begin');
{$ifend}

  FParser:=Tvsagps_parser_nmea.Create;

  inherited;

  FParser.FOnApplyUTCDateTime:=Do_RequestGPSCommand_Apply_UTCDateTime;
  FParser.FOnECHOSOUNDER:=FParser_FOnECHOSOUNDER;
  FParser.FOnGGA:=FParser_FOnGGA;
  FParser.FOnGLL:=FParser_FOnGLL;
  FParser.FOnGSA:=FParser_FOnGSA;
  FParser.FOnGSV:=FParser_FOnGSV;
  FParser.FOnRMC:=FParser_FOnRMC;
{$if defined(USE_NMEA_VTG)}
  FParser.FOnVTG:=FParser_FOnVTG;
{$ifend}

  FDCB_Str_Info_A:='';
  FGlobalNmeaBuffer:='';
  FUserIni:=nil;
  FIniReadOnly:=FALSE;
  InternalLoadUserIni;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Create: end');
{$ifend}
end;

destructor Tvsagps_device_com_nmea.Destroy;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Destroy: begin');
{$ifend}
  inherited;
  FreeAndNil(FUserIni);
  FreeAndNil(FParser);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Destroy: end');
{$ifend}
end;

procedure Tvsagps_device_com_nmea.Do_RequestGPSCommand_Apply_UTCDateTime(const ADate: PNMEA_Date; const ATime: PNMEA_Time);
  function InternalSetSysTime: Boolean;
  var
    t: TSystemTime;
    //dwError: DWORD;
  begin
    // date
    if (ADate<>nil) then begin
      t.wYear:=Convert_TwoDigitYear_to_FourDigitYear(ADate^.year);
      t.wMonth:=ADate^.month;
      t.wDay:=ADate^.day;
    end else begin
      t.wYear:=FSavedUTCDateTime.date.year; // 4-Digit!
      t.wMonth:=FSavedUTCDateTime.date.month;
      t.wDay:=FSavedUTCDateTime.date.day;
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
      //dwError:=GetLastError;
      //if (ERROR_INVALID_PARAMETER=dwError) then ;
      FRequestGPSCommand_Apply_UTCDateTime:=FALSE; // no privileges or other errors (permanent result)
    end;
  end;
begin
  if (not FRequestGPSCommand_Apply_UTCDateTime) then
    Exit;
    
  // only if date and time are valid (both)
  if (not NMEA_Date_Valid(ADate)) OR (not NMEA_Time_Valid(ATime)) then
    Exit;

  // we should set time on very first sentence with NEW time
  // so we should SAVE datetime on first sentence and wait for next timestamp
  if NMEA_Date_Time_Valid(@FSavedUTCDateTime) then begin
    // check for new time
    if (FSavedUTCDateTime.time.sec<>ATime^.sec) and (FSavedUTCDateTime.time.min=ATime^.min) then begin
      // new seconds (minutes, hours and date remains the same)
      if InternalSetSysTime then begin
        // well done
        FRequestGPSCommand_Apply_UTCDateTime:=FALSE;
        Exit;
      end;
    end;
  end;

  // save current to special field - only if with date
  if (ADate<>nil) then begin
    FSavedUTCDateTime.date:=ADate^;
    FSavedUTCDateTime.time:=ATime^;
    // convert to 4-Digit
    FSavedUTCDateTime.date.year:=Convert_TwoDigitYear_to_FourDigitYear(FSavedUTCDateTime.date.year);
  end;
end;

procedure Tvsagps_device_com_nmea.ExecuteGPSCommand(const ACommand: LongInt;
                                                    const APointer: Pointer);
var
  sl_sent, sl_prop: TStringListA;
  strParamName: AnsiString;

  procedure MakeProps;
  var i: Tgpms_Code;
  begin
    if FParser.SomeProprietariesSupported then
    for i := Low(Tgpms_Code) to High(Tgpms_Code) do
    if (gpms_Unknown<>i) and (gpms_Some<>i) then
    if FParser.FProprietaries[i].Supported then begin
      if (FParser.FProprietaries[i].SubCode<>0) then begin
        // with subcodes
        Append_Gpms_Subcodes(i, FParser.FProprietaries[i].SubCode, sl_prop);
      end else begin
        // no subcodes
        sl_prop.Append(Gpms_Code_to_String(i));
      end;
    end;
  end;

begin
  inherited;

  // set DCB info as AnsiString
  if (gpsc_Set_DCB_Str_Info_A = ACommand) then
  if (nil<>APointer) then begin
    SetString(FDCB_Str_Info_A, PAnsiChar(APointer), StrLen(PAnsiChar(APointer)));
    FDCB_Str_Info_A:=TrimA(FDCB_Str_Info_A);
    Exit;
  end;

  // for some predefined commands and for all user commands check ini for packets
  if (gpsc_Reset_DGPS = ACommand) then
    strParamName:=vsagps_ini_resetdgps
  else if (gpsc_User_Base_Number <= ACommand) then
    strParamName:=IntToStrA(ACommand)
  else
    strParamName:='';

  if (0<Length(strParamName)) then begin
    // different commands for different devices (by chipset)
    sl_sent:=TStringListA.Create;
    sl_prop:=TStringListA.Create;
    try
      // make proprietaries
      MakeProps;
      // get sentences
      VSAGPS_ini_GetSent_ForGPSCommand(FUserIni, sl_sent, sl_prop, strParamName);
      // send
      Make_and_Send_NmeaComm_Packets(sl_sent);
    finally
      sl_sent.Free;
      sl_prop.Free;
    end;
  end;
end;

procedure Tvsagps_device_com_nmea.InternalMakeAutodetectObject;
begin
  if (nil=FAutodetectObject) then begin
    // make object
    FAutodetectObject:=TCOMCheckerObject.Create;
  end;
end;

procedure Tvsagps_device_com_nmea.InternalResetDeviceConnectionParams;
begin
  inherited;
  if (nil<>FParser) then begin
    FParser.InitSpecialNmeaCounters;
  end;
  FRequestGPSCommand_Apply_UTCDateTime:=FALSE;
  ZeroMemory(@FSavedUTCDateTime, sizeof(FSavedUTCDateTime));
  InternalResetProprietaries;
end;

procedure Tvsagps_device_com_nmea.InternalResetProprietaries;
begin
  if (nil=FParser) then
    Exit;
  ZeroMemory(@(FParser.FProprietaries), sizeof(FParser.FProprietaries));
  // set handlers
  with FParser do begin
    FProprietaries[gpms_CSI].ParserProc:=Parse_Proprietary_CSI_Data;
    FProprietaries[gpms_DME].ParserProc:=Parse_Proprietary_DME_Data;
    FProprietaries[gpms_EMT].ParserProc:=Parse_Proprietary_EMT_Data;
    FProprietaries[gpms_GRM].ParserProc:=Parse_Proprietary_GRM_Data;
    FProprietaries[gpms_MGN].ParserProc:=Parse_Proprietary_MGN_Data;
    FProprietaries[gpms_MTK].ParserProc:=Parse_Proprietary_MTK_Data;
    FProprietaries[gpms_RWI].ParserProc:=Parse_Proprietary_RWI_Data;
    FProprietaries[gpms_SLI].ParserProc:=Parse_Proprietary_SLI_Data;
    FProprietaries[gpms_SRF].ParserProc:=Parse_Proprietary_SRF_Data;
    FProprietaries[gpms_STI].ParserProc:=Parse_Proprietary_STI_Data;
    FProprietaries[gpms_TNL].ParserProc:=Parse_Proprietary_TNL_Data;
    FProprietaries[gpms_XEM].ParserProc:=Parse_Proprietary_XEM_Data;
  end;
end;

procedure Tvsagps_device_com_nmea.InternalSendUserPackets;
var
  sl_sent: TStringListA;
begin
  // send user defined packets on connection
  if (not FIniReadOnly) then
  if (FUserIni<>nil) then begin
    sl_sent := TStringListA.Create;
    try
      // get nmea packets
      VSAGPS_ini_GetStartSent(FUserIni, sl_sent);
      // send nmea packets
      Make_and_Send_NmeaComm_Packets(sl_sent);
    finally
      sl_sent.Free;
    end;
  end;
end;

procedure Tvsagps_device_com_nmea.Internal_Before_Close_Device;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Close_Device: begin');
{$ifend}
  inherited;
  if (0<>FGPSDeviceSessionStarted) and (0<>FGPSDeviceHandle) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Close_Device: PurgeComm');
{$ifend}
    PurgeComm(FGPSDeviceHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
  end;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Close_Device: end');
{$ifend}
end;

procedure Tvsagps_device_com_nmea.Internal_Before_Open_Device;
var
  sNTname: AnsiString;
  VAutodetectResult: SmallInt;
  VAutodetectCancelled: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Open_Device: begin');
{$ifend}

  inherited;

  // connect to user defined COMx
  sNTname:=FDeviceNameByUser;

  if (FALLDeviceParams^.btAutodetectOnConnect<>0) then begin
    // autodetect
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Open_Device: autodetect');
{$ifend}

    InternalMakeAutodetectObject;
    with TCOMCheckerObject(FAutodetectObject) do
    try
      SetFullConnectionTimeout(FALLDeviceParams^.wConnectionTimeoutSec, TRUE);
      VAutodetectResult:=EnumExecute(nil, VAutodetectCancelled, FALLDeviceParams^.dwAutodetectFlags, TRUE);
      FGPSDeviceHandle:=ExtractFirstOpenedHandle;
      if (0<=VAutodetectResult) then begin
        // make com name
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Open_Device: make com name');
{$ifend}
        sNTname:='COM'+IntToStrA(VAutodetectResult);
        Sleep(0);
      end;
    finally
      InternalKillAutodetectObject;
    end;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Open_Device: prefix');
{$ifend}

  // To specify a COM port number greater than 9, use the following syntax: "\\.\COM10".
  if (not (PosA(cNmea_NT_COM_Prefix, sNTname)>0)) then
    sNTname := cNmea_NT_COM_Prefix + sNTname;
      
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Open_Device: cleanup');
{$ifend}

  // make and fill buffer
  VSAGPS_FreeAndNil_PAnsiChar(FGPSDeviceInfo_NameToConnectInternalA);
  FGPSDeviceInfo_NameToConnectInternalA:=VSAGPS_AllocPCharByString(sNTname, TRUE);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Before_Open_Device: end');
{$ifend}
end;

function Tvsagps_device_com_nmea.Internal_Parse_NmeaComm_Packets(const pPacket: PAnsiChar): DWORD;

  function _RunWithoutStarter(const s: AnsiString): DWORD;
  begin
    Result:=FParser.Parse_Sentence_Without_Starter(s);
  end;

  procedure _CutNmeaByTail(k: Integer);
  var str_nmea_packet: AnsiString;
  begin
    str_nmea_packet:=System.Copy(FGlobalNmeaBuffer, 1, k);
    System.Delete(FGlobalNmeaBuffer, 1, k);
    Result:=_RunWithoutStarter(str_nmea_packet);
  end;

var
  pNmea_Tail, pNmea_Aux: Integer;
  i: Byte;
  new_part: AnsiString;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Internal_Parse_NmeaComm_Packets:');
  VSAGPS_DebugPAnsiChar(pPacket);
{$ifend}
  Result:=0;
  new_part := SafeSetStringP(pPacket);
  FGlobalNmeaBuffer:=FGlobalNmeaBuffer+new_part;
  repeat
    if (0=Length(FGlobalNmeaBuffer)) then
      Exit;

    // get part before
    // allowed delimiters for packets ARE: cNmea_Starter (from next packet) and chars from cNmea_Tail (from this packet)
    // allow proprietary packets without finisher and checksum
    // delete up to first cNmea_Starter
    //if Sametext(System.Copy(FGlobalNmeaBuffer, 1, Length(cNmea_Starter)), cNmea_Starter) then
      //System.Delete(FGlobalNmeaBuffer, 1, Length(cNmea_Starter));
    pNmea_Aux := PosA(cNmea_Starter, FGlobalNmeaBuffer);
    if (1=pNmea_Aux) then
      System.Delete(FGlobalNmeaBuffer, 1, Length(cNmea_Starter))
    else if (1<pNmea_Aux) then begin
      _RunWithoutStarter(System.Copy(FGlobalNmeaBuffer, 1, pNmea_Aux-1));
      System.Delete(FGlobalNmeaBuffer, 1, pNmea_Aux+Length(cNmea_Starter)-1);
    end;

    // check finish of sentence
    pNmea_Tail:=0;
    for i := 1 to Length(cNmea_Tail) do begin
      pNmea_Aux := PosA(cNmea_Tail[i], FGlobalNmeaBuffer);
      if (pNmea_Aux>0) then
        if (pNmea_Aux>pNmea_Tail) then
          pNmea_Tail:=pNmea_Aux;
    end;

    if (pNmea_Tail>0) then begin
      // packet ends by cNmea_Tail
      _CutNmeaByTail(pNmea_Tail);
    end else begin
      // no packet tail - check finisher or next starter
      pNmea_Tail := PosA(cNmea_Starter, FGlobalNmeaBuffer);
      pNmea_Aux := PosA(cNmea_Finisher, FGlobalNmeaBuffer);
      if (0<pNmea_Tail) and (0<pNmea_Aux) and (pNmea_Aux<pNmea_Tail) then begin
        // next packet starter found and before it current finisher found
        _CutNmeaByTail(pNmea_Tail-1);
      end else begin
        // no packets
        Exit;
      end;
    end;
  until FALSE;
end;

procedure Tvsagps_device_com_nmea.Internal_Query_GPSDeviceName;
begin
  // not implemented yet
end;

function Tvsagps_device_com_nmea.Make_and_Send_NmeaComm_Packet(const AIncompletePacket: AnsiString): Boolean;
var s: AnsiString;
begin
  s:=MakeNmeaFullString(AIncompletePacket);
  Result:=Send_NmeaComm_Packet(s);
end;

function Tvsagps_device_com_nmea.Make_and_Send_NmeaComm_Packets(const sl_sent: TStringsA): Integer;
var
  i: Integer;
  b: Boolean;
begin
  Result:=0;
  if FIniReadOnly then
    Exit;
  if (0 < sl_sent.Count) then
  for i := 0 to sl_sent.Count - 1 do begin
    if (0<i) then
      Sleep(100);
    b:=Make_and_Send_NmeaComm_Packet(sl_sent[i]);
    if b then
      Inc(Result);
  end;
end;

procedure Tvsagps_device_com_nmea.InternalLoadUserIni;
begin
  try
    if (nil = FUserIni) then
      FUserIni := TStringListA.Create;
    FUserIni.LoadFromFile(vsagps_nmea_ini_filename);
    if (0 = FUserIni.Count) then
      FreeAndNil(FUserIni);
  except
    FreeAndNil(FUserIni);
  end;

  FIniReadOnly := VSAGPS_ini_IsReadOnly(FUserIni);
end;

function Tvsagps_device_com_nmea.ParsePacket(const ABuffer: Pointer): DWORD;
begin
  // inherited;
  Result:=Internal_Parse_NmeaComm_Packets(ABuffer)
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_CSI_Data(const AData, ASubCommand: AnsiString): DWORD;
var sType: AnsiString;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    sType:=FParser.Get_NMEAPart_By_Index(0);
    if SametextA(sType, 'CS0') then begin
      // $PCSI,CS0,PXXX-Y.YYY,SN,fff.f,M,ddd,R,SS,SNR,MTP,Q,ID,H,T
      // 1) CS0 Channel 0
      // 2) PXXX - Y.YYY Resident SBX-3 firmware version
      InternalSetUnitInfoA(guik_Firmware_Version, FParser.Get_NMEAPart_By_Index(1));
      // 3) S/N SBX-3 receiver serial number
      InternalSetUnitInfoA(guik_Unique_Unit_Number, FParser.Get_NMEAPart_By_Index(2));
      // 4) fff.f Channel 0 current frequency
      // 5) M Frequency Mode (‘A’ – Auto or ‘M’ – Manual)
      // 6) ddd MSK bit rate
      // 7) R RTCM rate
      // 8) SS Signal strength
      // 9) SNR Signal to noise ratio
      // 10) MTP Message throughput
      // 11) Q Quality number {0-25} – number of successive good 30 bit RTCM words received
      // 12) ID Beacon ID to which the receiver’s primary channel is tuned
      // 13) vH Health of the tuned beacon [0-7]
      // 14) T $PCSI,1 status output period {0-99}
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_DME_Data(const AData, ASubCommand: AnsiString): DWORD;
var sType, sSubType, sValue: AnsiString;
begin
  Result := 0;
  if (0 < FParser.Count) then
  try
    sType:=FParser.Get_NMEAPart_By_Index(0);
    if ('4'=sType) then begin
      // $PDME,4,3, GPS_LIBRARY_VERSION GPSLIB_5.4.1.5 GNU – Jun 11 2007 10:05:32
      sSubType := FParser.Get_NMEAPart_By_Index(1);
      sValue := FParser.Get_NMEAPart_By_Index(2);
      if ('1'=sSubType) then begin
        // DeLorme firmware revision
        InternalSetUnitInfoA(guik_Firmware_Version, sValue);
      end else if ('2'=sSubType) then begin
        // DeLorme hardware revision
        InternalSetUnitInfoA(guik_Hardware_Version, sValue);
      end else if ('3'=sSubType) then begin
        // GPS library revision
        InternalSetUnitInfoA(guik_Software_Version, sValue);
      end else if ('4'=sSubType) then begin
        // SBAS/WAAS library revision
        InternalSetUnitInfoA(guik_SBAS_Version, sValue);
      end;
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_EMT_Data(const AData, ASubCommand: AnsiString): DWORD;
var sType: AnsiString;
begin
  // $PEMT,100,05.03A,240701,082,15,1,08,06,04,0,0,2,1*7E
  Result:=0;
  if (0<FParser.Count) then
  try
    sType:=FParser.Get_NMEAPart_By_Index(0); // 1 Message ID = 100 (in sample)
    if (sType = '100') then begin
      // PEMT 100 – Receiver ID
      // 2 Firmware Version  = 05.03A
      InternalSetUnitInfoA(guik_Firmware_Version, FParser.Get_NMEAPart_By_Index(1));
      // 3 Firmware Release Date 240701 ddmmyy
      InternalSetUnitInfoA(guik_Firmware_Release, FParser.Get_NMEAPart_By_Index(2));
      // 4 Default Datum ID 082 xxx // 0 ~ 219, see Appendix – A
      InternalSetUnitInfoA(guik_Datum_Index, FParser.Get_NMEAPart_By_Index(3));
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_GRM_Data(const AData, ASubCommand: AnsiString): DWORD;
  function Internal_PPS_Mode(const AValue: AnsiString): AnsiString;
  begin
    if ('2'=AValue) then
      Result:='1 Hz'
    else
      Result:='';
  end;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    if ('M'=ASubCommand) then begin
      // PGRMM
      // 1) Currently active horizontal datum (WGS-84, NAD27 Canada, ED50, a.s.o)
      InternalSetUnitInfoA(guik_Datum_Name, TrimA(AData));
    end else if ('T'=ASubCommand) then begin
      // PGRMT
      // 1) Product, model and software version (e.g. "GPS25VEE] 1.10")
      InternalSetUnitInfoA(guik_Model_Description_Full, TrimA(FParser.Get_NMEAPart_By_Index(0)));
      // 2) Rom checksum test: P = pass, F = fail
      //InternalSetUnitInfoA(guik_ROM_Checksum_Test, Get_NMEAPart_By_Index(1));
      // 3) Receiver failure discrete: P = pass, F = fail
      //InternalSetUnitInfoA(guik_Receiver_Failure_Discrete, Get_NMEAPart_By_Index(2));
      // 4) Stored data lost: R = retained, L = lost
      //InternalSetUnitInfoA(guik_Stored_Data_Lost, Get_NMEAPart_By_Index(3));
      // 5) Real time clock lost, R = retained, L = lost
      //InternalSetUnitInfoA(guik_Real_Time_Clock_Lost, Get_NMEAPart_By_Index(4));
      // 6) 0scillator drift discrete: P = pass, F = excessive drift detected
      //InternalSetUnitInfoA(guik_0scillator_Drift_Discrete, Get_NMEAPart_By_Index(5));
      // 7) Data collection discrete: C = collecting, null if not collecting
      //InternalSetUnitInfoA(guik_Data_Collection_Discrete, Get_NMEAPart_By_Index(6));
      // 8) Board temperature in degrees C
      //InternalSetUnitInfoA(guik_Board_Temperature_in_Degrees_C, Get_NMEAPart_By_Index(7));
      // 9) Board configuration data: R = retained, L = lost
      //InternalSetUnitInfoA(guik_Board_Configuration_Data, Get_NMEAPart_By_Index(8));
    end else if ('C'=ASubCommand) then begin
      // PGRMC
      // 1) Fix mode, A=automatic (only option)
      // 2) Altitude above/below mean sea level, -1500.0 to 18000.0 meters

      // 3) Earth datum index. If the user datum index (96) is specified, fields 5-8 must contain valid values. Otherwise, fields 4-8 must be null.
      InternalSetUnitInfoA(guik_Datum_Index, FParser.Get_NMEAPart_By_Index(2));
      // 4) User earth datum semi-major axis, 6360000.0 to 6380000.0 meters (.001 meters resolution)
      // 5) User earth datum inverse flattening factor, 285.0 to 310.0 (10-9 resolution)
      // 6) User earth datum delta x earth centered coordinate, -5000.0 to 5000.0 meters (1 meter resolution)
      // 7) User earth datum delta y earth centered coordinate, -5000.0 to 5000.0 meters (1 meter resolution)
      // 8) User earth datum delta z earth centered coordinate, -5000.0 to 5000.0 meters (1 meter resolution)

      // 9) Differential mode, A = automatic (output DGPS data when available, non-DGPs otherwise), D = differential exclusively (output only differential fixes)
      // 10) NMEA Baud rate, 1 = 1200, 2 = 2400, 3 = 4800, 4 = 9600
      InternalSetUnitInfoA(guik_BaudRate, FParser.Get_NMEAPart_By_Index(9));
      // 11) Filter mode, 2 = no filtering (only option)
      // 12) PPS mode, 1 = No PPS, 2 = 1 Hz
      InternalSetUnitInfoA(guik_PPS_Mode, Internal_PPS_Mode(FParser.Get_NMEAPart_By_Index(11)));
      // 13) Checksum
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_MGN_Data(const AData, ASubCommand: AnsiString): DWORD;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    if ('ST'=ASubCommand) then begin
      // PMGNST
      //$PMGNST,xx.xx,m,t,nnn,xx.xx,nnn,nn,c
      // 1) Firmware version number?
      InternalSetUnitInfoA(guik_Firmware_Version, TrimA(FParser.Get_NMEAPart_By_Index(0)));
      // 2) Mode (1 = no fix, 2 = 2D fix, 3 = 3D fix)
      // 3) T if we have a fix
      // 4) numbers change - unknown
      // 5) time left on the GPS battery in hours
      InternalSetUnitInfoA(guik_Battery_Left_in_Hours, TrimA(FParser.Get_NMEAPart_By_Index(4)));
      // 6) numbers change (freq. compensation?)
      // 7) PRN number receiving current focus
      // 8) nmea_checksum
    end else if ('VER'=ASubCommand) then begin
      // $PMGNVER,PID,SID,c---c,DBID*hh<CR><LF>
      // This message is used to send the model number of the GPS unit and its software version number.
      // sample: $PMGNVER,015,4.01,GPS3000XL*05
      // PID is a unique numerical product ID specifying the unit’s model.
      InternalSetUnitInfoA(guik_Product_ID, FParser.Get_NMEAPart_By_Index(0));
      // SID is the software version number.
      InternalSetUnitInfoA(guik_Software_Version, FParser.Get_NMEAPart_By_Index(1));
      // Model - The character field contains a text representation of the unit’s model name.
      InternalSetUnitInfoA(guik_Model_Description_Simple, FParser.Get_NMEAPart_By_Index(2));
      // DBID is a set of three strings used to identify the database in certain aviation units.
      InternalSetUnitInfoA(guik_Database_ID, FParser.Get_NMEAPart_By_Index(3));
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_MTK_Data(const AData, ASubCommand: AnsiString): DWORD;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    if ('530'=ASubCommand) then begin
      // PMTK_DT_DATUM - Current datum used
      InternalSetUnitInfoA(guik_Datum_Index, FParser.Get_NMEAPart_By_Index(0));
    end else if ('704'=ASubCommand) then begin
      // PMTK_DT_VERSION - Version information of FW - max 3 lines
      InternalSetUnitInfoA(guik_Firmware_Version, FParser.Get_NMEAPart_By_Index(0));
      InternalSetUnitInfoA(guik_Firmware_Build, FParser.Get_NMEAPart_By_Index(1));
      InternalSetUnitInfoA(guik_Firmware_Release, FParser.Get_NMEAPart_By_Index(2));
    end else if ('705'=ASubCommand) then begin
      // $PMTK705,AXN_1.30,0000,20090609,*20<CR><LF>
      InternalSetUnitInfoA(guik_Firmware_Version, FParser.Get_NMEAPart_By_Index(0));
      InternalSetUnitInfoA(guik_Firmware_Build, FParser.Get_NMEAPart_By_Index(1));
      InternalSetUnitInfoA(guik_Firmware_Release, FParser.Get_NMEAPart_By_Index(2));
    end else if ('CHN'=ASubCommand) then begin
      // PMTKCHN,23282,04292,20182,25182,27262,11142,31262,00000,....
      // GPS channel status (32 items):
      // 1-2 Satellite number
      // 3-4 SNR in dB
      // 5 Channel status: 0 - Idle, 1 - Searching, 2 - Tracking
    end else if ('DBG'=ASubCommand) then begin
      // PMTKDBG
      // MTK debug information
    end;
    // PMTKDGP - GPS differential correction information
    // PMTKALM - GPS almanac information
    // PMTKEPH - GPS ephemeris information
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_RWI_Data(const AData, ASubCommand: AnsiString): DWORD;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    if ('RID'=ASubCommand) then begin
      // $PRWIRID,12,00.90,12/25/95,0003,*40
      // 1 NUM_CHN Number of Channels xx = 12
      InternalSetUnitInfoA(guik_Channels, FParser.Get_NMEAPart_By_Index(0));
      // 2 SW_VER Software Version x.x = 00.90
      InternalSetUnitInfoA(guik_Software_Version, FParser.Get_NMEAPart_By_Index(1));
      // 3 SW_DATE Software Date cccccccc = 12/25/95
      InternalSetUnitInfoA(guik_Software_Release, FParser.Get_NMEAPart_By_Index(2));
      // 4 OPT_LST Options List (Note 1) hhhh = 0003 // bit 0 minimize ROM usage // bit 1 minimize RAM usage // bits 2-15 reserved
      // 5 RES Reserved
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_SLI_Data(const AData, ASubCommand: AnsiString): DWORD;
begin
  Result:=0;
(*
$PSLIB
Proprietry Garman (Differential Control) 

Proprietary sentences to control a Starlink differential beacon receiver. (I assume Garmin's DBR is made by Starlink) 

eg1.    $PSLIB,,,J*22
eg2.    $PSLIB,,,K*23
           These two sentences are normally sent together in each group
           of sentences from the GPS.
           The three fields are: Frequency, bit Rate, Request Type.  The
           value in the third field may be:
                J = status request
                K = configuration request
                blank = tuning message

           When the GPS receiver is set to change the DBR frequency or
           baud rate, the "J" sentence is replaced (just once) by (for
           example): $PSLIB,320.0,200*59 to set the DBR to 320 KHz, 200
           baud.
*)
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_SRF_Data(const AData, ASubCommand: AnsiString): DWORD;
var
  i: Byte;
  s,t: AnsiString;
  p: Integer;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    if ('TXT'=ASubCommand) then begin
      // PSRFTXT
      FParser.Enable_Proprietaries_SubCode(gpms_SRF, gpms_SRF_sub_GlobalSat);
      for i := 0 to FParser.Count-1 do begin
        // Version:GSW3.2.4_3.1.00.12-SDK003P1.00a - this is Sirf Version
        // Version2:F-GPS-03-0702019 - this is FW Version
        // CHNL: 12
        // Baud rate: 38400
        s := FParser.Get_NMEAPart_By_Index(i);
        p := PosA(':', s);
        if (p > 0) then begin
          t := System.Copy(s, 1, p-1);
          System.Delete(s, 1, p);
          if SameTextA(t, 'Version2') then
            InternalSetUnitInfoA(guik_Firmware_Version, TrimA(s))
          else if SameTextA(t, 'Version') then
            InternalSetUnitInfoA(guik_Chipset_Version, TrimA(s))
          else if SameTextA(t, 'Baud rate') then
            InternalSetUnitInfoA(guik_BaudRate, TrimA(s))
          else if SameTextA(t, 'CHNL') then
            InternalSetUnitInfoA(guik_Channels, TrimA(s));
        end;
      end;
    end else if ('140'=ASubCommand) then begin
      // PSRF140 - Extended Ephemeris
      FParser.Enable_Proprietaries_SubCode(gpms_SRF, gpms_SRF_sub_GlobalSat);
      // UNDOCUMENTED
    end else if ('151'=ASubCommand) then begin
      // PSRF151 - GPS Data and Extended Ephemeris Mask
      FParser.Enable_Proprietaries_SubCode(gpms_SRF, gpms_SRF_sub_GlobalSat);
      // like a $PSRF151,3,1485,147236.3,0x43002732*4A
      (*
      3 = GPS_TIME_VALID_FLAG // Bit 0 = 1, GPS week is valid
      1485 = GPS Week // Extended week number
      147236.3 = GPS Time of Week (seconds) // GPS Time Of Week
      0x43002732 = EPH_REQ_MASK // Mask to indicate the satellites for which new ephemeris is needed.
      // Eight characters preceded by the following characters, “0x”, are used to show this 32-bit mask (in hex).
      // The MSB is for satellite PRN 32, and the LSB is for satellite PRN 1.
      *)
    end else if ('161'=ASubCommand) then begin
      // NMEA Output message 161, Hardware Status (u-blox)
      // $PSRF161,01,63*6E<CR><LF>
      // Antenna status - numeric - from 0 to 4
      // AGC - numeric - Range: 0…63
      FParser.Enable_Proprietaries_SubCode(gpms_SRF, gpms_SRF_sub_U_Blox);
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_STI_Data(const AData, ASubCommand: AnsiString): DWORD;
begin
  Result:=0;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_TNL_Data(const AData, ASubCommand: AnsiString): DWORD;
begin
  Result:=0;
  if (0<FParser.Count) then
  try
    if ('ID'=ASubCommand) then begin
      // $PTNLID,097,01,XXX,XXX,DDMMYY*XX - ORIGINAL TRIMBLE
      // 1 Machine ID
      InternalSetUnitInfoA(guik_Machine_ID, FParser.Get_NMEAPart_By_Index(0)); // nonunique
      // 2 Product ID
      InternalSetUnitInfoA(guik_Product_ID, FParser.Get_NMEAPart_By_Index(1));
      // 3 Major firmware release number
      InternalSetUnitInfoA(guik_Firmware_Version, FParser.Get_NMEAPart_By_Index(2));
      // 4 Minor firmware release number
      InternalSetUnitInfoA(guik_Firmware_SubVersion, FParser.Get_NMEAPart_By_Index(3));
      // 5 Firmware release date, in DD/MM/YY format
      InternalSetUnitInfoA(guik_Firmware_Release, FParser.Get_NMEAPart_By_Index(4));
    end else if ('RVR'=ASubCommand) then begin
      // $PTNLRVR,b,c..c,xx.xx.xx,xx,xx,xxxx*hh<CR><LF> - COPERNICUS
      // 1) b Reserved
      // Get_NMEAPart_By_Index(0)
      // 2) c..c Receiver Name
      InternalSetUnitInfoA(guik_Model_Description_Simple, FParser.Get_NMEAPart_By_Index(1));
      // 3) xx Major version
      InternalSetUnitInfoA(guik_Firmware_Version, FParser.Get_NMEAPart_By_Index(2));
      // 4) xx Minor version
      InternalSetUnitInfoA(guik_Firmware_SubVersion, FParser.Get_NMEAPart_By_Index(3));
      // 5) xx Build version
      InternalSetUnitInfoA(guik_Firmware_Build, FParser.Get_NMEAPart_By_Index(4));
      // 6) xx Month
      // 7) xx Day
      // 8) xxxx Year
      InternalSetUnitInfoA(guik_Firmware_Release, FParser.Get_NMEAPart_By_Index(7)+'/'+FParser.Get_NMEAPart_By_Index(6)+'/'+FParser.Get_NMEAPart_By_Index(5));
    end else if ('RDM'=ASubCommand) then begin
      // $PTNLRDM,x..x,x.x,x.x,x.x,x.x,x.x*hh<CR><LF> - COPERNICUS
      // x..x Datum index from table or -9 for custom datum
      InternalSetUnitInfoA(guik_Datum_Index, FParser.Get_NMEAPart_By_Index(0));
      // x.x Dx
      // x.x Dy
      // x.x Dz
      // x.x Axis
      // x.x Eccentricity Squared
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.Parse_Proprietary_XEM_Data(const AData, ASubCommand: AnsiString): DWORD;

  procedure SetForItems(const guik_A_Name, guik_A_Version, guik_A_SubVersion,
                        guik_A_Build, guik_A_Release: TVSAGPS_UNIT_INFO_Kind);
  begin
    // Name - Variable length field; may be up to 17 characters long
    InternalSetUnitInfoA(guik_A_Name, FParser.Get_NMEAPart_By_Index(1));
    // Maj version - Major version number (00 to 99)
    InternalSetUnitInfoA(guik_A_Version, FParser.Get_NMEAPart_By_Index(2));
    // Min version - Minor version number (00 to 99)
    InternalSetUnitInfoA(guik_A_SubVersion, FParser.Get_NMEAPart_By_Index(3));
    // Beta version - Beta version number (00 to 99)
    InternalSetUnitInfoA(guik_A_Build, FParser.Get_NMEAPart_By_Index(4));
    // Month - Month of the release (01 to 12)
    // Day - Day of the release (01 to 31)
    // Year - Year of the release
    InternalSetUnitInfoA(guik_A_Release, FParser.Get_NMEAPart_By_Index(7)+'/'+FParser.Get_NMEAPart_By_Index(6)+'/'+FParser.Get_NMEAPart_By_Index(5));
  end;

var
  sVR,sType: AnsiString;
begin
  Result:=0;
  if (0 < FParser.Count) then
  try
    sVR := System.Copy(ASubCommand, 2, Length(ASubCommand));
    if SameTextA(sVR, 'VR') then begin
      // VERSIONS - $PXEMaVR,R,nucleus,04,03,10,27,2000*6E
      sType := FParser.Get_NMEAPart_By_Index(0);
      if SameTextA(sType, 'M') then begin
        // M = measurement platform (MPM) firmware
        SetForItems(guik_Firmware_Name, guik_Firmware_Version, guik_Firmware_SubVersion,
                    guik_Firmware_Build, guik_Firmware_Release);
      end else if SameTextA(sType, 'N') then begin
        // N = FirstGPS Library
        SetForItems(guik_Software_Name, guik_Software_Version, guik_Software_SubVersion,
                    guik_Software_Build, guik_Software_Release);
      end else if SameTextA(sType, 'U') then begin
        // U = native processor (CPU)
      end else if SameTextA(sType, 'A') then begin
        // A = FirstGPS API
      end else if SameTextA(sType, 'R') then begin
        // R = native RTOS
      end;
    end;
  except
  end;
end;

function Tvsagps_device_com_nmea.SendPacket(const APacketBuffer: Pointer;
                                            const APacketSize: DWORD;
                                            const AFlags: DWORD): LongBool;
var s: AnsiString;
begin
  s := SafeSetStringL(PAnsiChar(APacketBuffer), APacketSize);
  // full packet or data only?
  if (gspf_FullPacket = (AFlags and gspf_FullPacket)) then begin
    // full packet
    Result:=Send_NmeaComm_Packet(s);
  end else begin
    // make full packet and send it
    Result:=Make_and_Send_NmeaComm_Packet(s);
  end;
end;

function Tvsagps_device_com_nmea.Send_NmeaComm_Packet(const AFullPacket: AnsiString): Boolean;
var dwWriten: DWORD;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Send_NmeaComm_Packet: "' + AFullPacket + '"');
{$ifend}

  if FIniReadOnly then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Send_NmeaComm_Packet: read-only');
{$ifend}
    Result := TRUE;
    Exit;
  end;

  dwWriten:=0;
  Result:=(WriteFile(FGPSDeviceHandle, PAnsiChar(AFullPacket)^, Length(AFullPacket), dwWriten, nil)<>FALSE);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.Send_NmeaComm_Packet: ok (' + IntToStr(Ord(Result))+ ') (' + IntToStr(dwWriten) + ')');
{$ifend}
end;

function Tvsagps_device_com_nmea.SerializePacket(const APacket: Pointer): PAnsiChar;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.SerializePacket:');
  VSAGPS_DebugPAnsiChar(PAnsiChar(APacket));
{$ifend}

  if (APacket<>nil) then
    Result:=VSAGPS_AllocPCharByPChar(PAnsiChar(APacket), TRUE)
  else
    Result:=nil;
end;

function Tvsagps_device_com_nmea.WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean;
var
  bRead: Boolean;
  dwBytes: DWORD;
  queued_pointer: PAnsiChar;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_Receive_Packets: begin');
{$ifend}

  Result:=FALSE;
  if (0=FGPSDeviceHandle) then
    Exit;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_Receive_Packets: ReadFile');
{$ifend}

  //ClearCommError(FGPSDeviceHandle)
  // read data from comm
  dwBytes:=0;
  bRead:=ReadFile(FGPSDeviceHandle, FNMEABuffer, cNmea_Buffer_Size, dwBytes, nil);
  if bRead and (dwBytes>0) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_Receive_Packets: ok');
{$ifend}
    // packet received - make a buffer and put it into queue
    queued_pointer:=VSAGPS_GetMem(dwBytes+1);
    CopyMemory(queued_pointer, @(FNMEABuffer[0]), dwBytes);
    queued_pointer[dwBytes]:=#0;

    // add packet to queue
    FExternal_Queue.AppendGPSPacket(queued_pointer, FUnitIndex);

    // check exit after any packet
    if (wtfp_AnyPacket=(AWorkingThreadPacketFilter and wtfp_AnyPacket)) then
      Result:=TRUE;
  end else begin
    // error or no data received (timeout)
    dwBytes:=GetLastError;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_Receive_Packets: failed '+IntToStr(dwBytes));
{$ifend}
    if (ERROR_TIMEOUT<>dwBytes) then begin
      // error
      FWT_Params.dwLastError:=dwBytes;
      FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Communication_Failure);
    end;
  end;
end;

function Tvsagps_device_com_nmea.WorkingThread_SendPacket: Boolean;
var
  s: AnsiString;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_SendPacket: begin');
{$ifend}

  if FIniReadOnly then begin
    // read-only mode - do not send to device at all
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_SendPacket: read-only');
{$ifend}
    Result := TRUE;
    Exit;
  end;

  // send some starter packets for some different types of devices
  // unsupported sentences will be ignored
  try
    InternalSendUserPackets;
  except
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_SendPacket: make');
{$ifend}

  // DEFAULT NMEA STARTER - send query RMC sentence
  s:=MakeNmeaBaseQuerySentence(nmea_ti_CC, nmea_ti_GPS, nmea_si_RMC);
  Result:=Make_and_Send_NmeaComm_Packet(s);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_SendPacket: end');
{$ifend}
end;

function Tvsagps_device_com_nmea.WorkingThread_StartSession: Boolean;
var
  d: TDCB;
  t: TCommTimeouts;
  VModifyParams: Boolean;
  VModifyTimeout: Boolean;

  function _GetCommParams: Boolean;
  begin
    // Build DCB from FDCB_Str_Info or
    d.DCBlength:=sizeof(d);
    if (0<Length(FDCB_Str_Info_A)) then begin
      // build DCB from FDCB_Str_Info
      Result:=(BuildCommDCBA(PAnsiChar(FDCB_Str_Info_A), d)<>FALSE);
      // always set
      VModifyParams:=TRUE;
    end else begin
      // get it from device
      Result:=(GetCommState(FGPSDeviceHandle, d)<>FALSE);
    end;
  end;

  procedure _FillCommParams;
  begin
    // BaudRate
    if (nil<>FThisDeviceParams) and (0<FThisDeviceParams^.iBaudRate) then begin
      if (d.BaudRate<>DWORD(FThisDeviceParams^.iBaudRate)) then begin
        d.BaudRate:=FThisDeviceParams^.iBaudRate;
        VModifyParams:=TRUE;
      end;
    end else if (nil<>FALLDeviceParams) and (0<FALLDeviceParams^.iBaudRate) then begin
      if (d.BaudRate<>DWORD(FALLDeviceParams^.iBaudRate)) then begin
        d.BaudRate:=FALLDeviceParams^.iBaudRate;
        VModifyParams:=TRUE;
      end;
    end;

    // do not abort on errors - mask $4000 in flags (fAbortOnError=FALSE)
    if (d.Flags and $4000) <> 0 then begin
      d.Flags := d.Flags - $4000;
      VModifyParams:=TRUE;
    end;
  end;

  procedure _FillCommTimeouts;
  begin
    VModifyTimeout:=TRUE; // always set
    // in milliseconds
    t.ReadIntervalTimeout:=MAXDWORD;
    t.ReadTotalTimeoutMultiplier:=MAXDWORD;

    t.ReadTotalTimeoutConstant:=GetReceiveGPSTimeoutSec(FALLDeviceParams, FThisDeviceParams);
    t.ReadTotalTimeoutConstant:=t.ReadTotalTimeoutConstant*1000;

    t.WriteTotalTimeoutMultiplier:=MAXDWORD;
    t.WriteTotalTimeoutConstant:=MAXDWORD;
    (*
    If there are any bytes in the input buffer, ReadFile returns immediately with the bytes in the buffer.
    If there are no bytes in the input buffer, ReadFile waits until a byte arrives and then returns immediately.
    If no bytes arrive within the time specified by ReadTotalTimeoutConstant, ReadFile times out.
    *)
  end;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: begin');
{$ifend}

  Result := FALSE;
  if (0=FGPSDeviceHandle) then
    Exit;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: query');
{$ifend}

  // try to obtain user-frendly device name
  Internal_Query_GPSDeviceName;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: SetupComm');
{$ifend}

  // set buffers
  Result:=SetupComm(FGPSDeviceHandle, cNmea_Buffer_Size, cNmea_Buffer_Size);
  if (not Result) then begin
    FWT_Params.dwFinishReason:= (FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: exit 1');
{$ifend}
    Exit;
  end;

  // set params
  VModifyParams:=FALSE;
  VModifyTimeout:=FALSE;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: GetCommParams');
{$ifend}

  // get-modify-set comm params
  Result:=_GetCommParams;
  if (not Result) then begin
    FWT_Params.dwFinishReason:= (FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: exit 2');
{$ifend}
    Exit;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: FillCommParams');
{$ifend}

  _FillCommParams;

  if VModifyParams then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: SetCommState');
{$ifend}

    Result:=SetCommState(FGPSDeviceHandle, d);
    if (not Result) then begin
      FWT_Params.dwFinishReason:= (FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: exit 3');
{$ifend}
      Exit;
    end;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: GetCommTimeouts');
{$ifend}

  // get-modify-set timeouts
  Result:=GetCommTimeouts(FGPSDeviceHandle, t);
  if (not Result) then begin
    FWT_Params.dwFinishReason:= (FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: exit 4');
{$ifend}
    Exit;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: FillCommTimeouts');
{$ifend}

  _FillCommTimeouts;

  if VModifyTimeout then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: SetCommTimeouts');
{$ifend}

    Result:=SetCommTimeouts(FGPSDeviceHandle, t);
    if (not Result) then begin
      FWT_Params.dwFinishReason:= (FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: exit 5');
{$ifend}
      Exit;
    end;
  end;
  
  // set Communicating flag
  if (0=FGPSDeviceSessionStarted) then
    FGPSDeviceSessionStarted:=1;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_com_nmea.WorkingThread_StartSession: Done');
{$ifend}

  Result:=TRUE;
end;

end.