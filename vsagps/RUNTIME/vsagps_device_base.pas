(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_device_base;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
{$IFDEF HAS_ANSISTRINGS_UNIT}
  AnsiStrings,
{$ENDIF}
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_classes,
  vsagps_public_device,
  vsagps_public_unit_info,
  vsagps_public_unicode,
  vsagps_public_sysutils,
  vsagps_tools,
  vsagps_queue,
  vsagps_runtime;

type
  Tvsagps_device_base = class(TObject)
  protected
    FGPSDeviceHandle: THandle; // device handle
    FGPSDeviceType: DWORD; // gdt_* constants
    // all device params (link)
    FALLDeviceUserPointer: Pointer;
    FALLDeviceParams: PVSAGPS_ALL_DEVICE_PARAMS;
    // this device params
    FThisDeviceParams: PVSAGPS_SINGLE_DEVICE_PARAMS;
    // sync
    FPtrCS_CloseHandle: PRTLCriticalSection;
    // Device info
    FUnitIndex: Byte;
    FDeviceInfo: TStringListA;
    FSupportedProtocols: TStringListA;
    FUNIT_INFO: TVSAGPS_UNIT_INFO;
    FUNIT_INFO_Changed: TVSAGPS_UNIT_INFO_DLL_Proc;
    FUNIT_INFO_CS: PRTLCriticalSection;
    // working thread
    FWT_Handle: THandle;
    FWT_Params: TVSAGPS_WorkingThread_Params;
    // device name by user (from request for connect, may be empty)
    FDeviceNameByUser: AnsiString;
    // Autodetect object
    FAutodetectObject: TObject;
    // Request commands
    FRequestGPSCommand_Apply_UTCDateTime: Boolean;
    // Used packet type
    FDefaultPacketType: DWORD;
    // check timeout or don't check
    FForceInfiniteTimeout: Boolean;
  private
    // connect to gps device
    function WorkingThread_ConnectToDevice: Boolean;
    // internal working thread routine
    procedure WorkingThread_Internal_Routine;
    // close internal working thread
    procedure WorkingThread_Internal_Close(const AWaitFor: Boolean);
  protected
    // real name of the gps device to connect (autodetect!)
    FGPSDeviceInfo_NameToConnectInternalA: PAnsiChar;
{$if defined(VSAGPS_USE_UNICODE)}
    FGPSDeviceInfo_NameToConnectInternalW: PWideChar;
{$ifend}
    FGPSDeviceSessionStarted: Byte;
    // queue
    FExternal_Queue: Tvsagps_queue;
    // process packets from device
    procedure WorkingThread_Process_Packets(const AWorkingThreadPacketFilter: DWORD);
    // parse garmin packets - very simple
    function Parse_GarminPVT_Packets(const pPacket: PGarminUSB_Custom_Packet; const BaseAuxPacketFlags: DWORD): DWORD;
    function Parse_LocationAPI_Packets(const ABuffer: Pointer; const BaseAuxPacketFlags: DWORD): DWORD;
  protected
    procedure InternalMakeUnitInfoCS;
    procedure InternalKillUnitInfoCS;
    procedure InternalWipeUnitInfoCS;
    procedure InternalSetUnitInfo(const AKind: TVSAGPS_UNIT_INFO_Kind; const ANewValue: string);
    procedure InternalSetUnitInfoA(const AKind: TVSAGPS_UNIT_INFO_Kind; const ANewValue: AnsiString);
    procedure InternalLockUnitInfoCS;
    procedure InternalUnlockUnitInfoCS;

    procedure InternalResetRequestGPSCommand;
    procedure InternalResetDeviceConnectionParams; virtual;
    procedure InternalKillAutodetectObject;
    procedure InternalCloseDevice;
    procedure Internal_Before_Open_Device; virtual;
    procedure Internal_Before_Close_Device; virtual;
    function Internal_Do_Open_Device: Boolean;
    function InternalGetUserPointer: Pointer;

    procedure InternalLockCloseHandle;
    procedure InternalUnlockCloseHandle;
  protected
    // start session - operations to establish connection
    function WorkingThread_StartSession: Boolean; virtual;
    // send query packet to gps
    function WorkingThread_SendPacket: Boolean; virtual;
    // receive packets from device to queue
    function WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetBaseParams(const AUnitIndex: Byte;
                            const AGPSDeviceType: DWORD;
                            const AExternal_Queue: Tvsagps_queue;
                            const ADeviceNameByUser: AnsiString;
                            const AAllDevParams: PVSAGPS_ALL_DEVICE_PARAMS;
                            const AThisDevParams: PVSAGPS_SINGLE_DEVICE_PARAMS;
                            const AALLDeviceUserPointer: Pointer;
                            const AUNIT_INFO_Changed: TVSAGPS_UNIT_INFO_DLL_Proc;
                            const APtrCS_CloseHandle: PRTLCriticalSection);

    procedure Connect;
    procedure Disconnect;

    procedure KillNow;

    procedure ExecuteGPSCommand(const ACommand: LongInt;
                                const APointer: Pointer); virtual;

    function SerializePacket(const APacket: Pointer;
                             out ASerializedSize: DWORD;
                             const AReserved: PDWORD): Pointer; virtual; abstract;

    function ParsePacket(const ABuffer: Pointer): DWORD; virtual; abstract;

    function SendPacket(const APacketBuffer: Pointer;
                        const APacketSize: DWORD;
                        const AFlags: DWORD): LongBool; virtual; abstract;

    function AllocSupportedProtocols(out AIsWide: Boolean): Pointer;
    function AllocDeviceInfo(out AIsWide: Boolean): Pointer;
    function AllocUnitInfo(out AIsWide: Boolean): Pointer;

    property GPSDeviceHandle: THandle read FGPSDeviceHandle;
    property GPSDeviceType: DWORD read FGPSDeviceType;
    property FinishReason: DWORD read FWT_Params.dwFinishReason;

    property ForceInfiniteTimeout: Boolean read FForceInfiniteTimeout;

    property DefaultPacketType: DWORD read FDefaultPacketType write FDefaultPacketType;
  end;

{$if not defined(USE_NMEA_VTG)}
  PNMEA_VTG=Pointer;
{$ifend}

  Tvsagps_device_with_nmea = class(Tvsagps_device_base)
  protected
    // nmea callback routines (set to parser)
    function FParser_FOnECHOSOUNDER(const p: PVSAGPS_ECHOSOUNDER_DATA): DWORD;
    function FParser_FOnGGA(const p: PNMEA_GGA): DWORD;
    function FParser_FOnGLL(const p: PNMEA_GLL): DWORD;
    function FParser_FOnGSA(const p: PNMEA_GSA): DWORD;
    function FParser_FOnGSV(const p: PNMEA_GSV): DWORD;
    function FParser_FOnRMC(const p: PNMEA_RMC): DWORD;
    function FParser_FOnVTG(const p: PNMEA_VTG): DWORD;
  end;

function Is_Pid_RecMeasData_Type_Packet(const pPacket: PGarminUSB_Custom_Packet; const pdwAuxPacket: PDWORD): LongBool;
function Is_Pid_D800_Pvt_Type_Packet(const pPacket: PGarminUSB_Custom_Packet; const pdwAuxPacket: PDWORD): LongBool;

procedure InternalSetUTCDateTimeFromGarmin(const pData: PD800_Pvt_Data_Type);

implementation

uses
  vsagps_public_garmin,
  vsagps_public_debugstring,
  vsagps_public_memory;

function Is_Pid_RecMeasData_Type_Packet(const pPacket: PGarminUSB_Custom_Packet; const pdwAuxPacket: PDWORD): LongBool;
begin
  if (PT_Application_Layer=pPacket^.Packet_Type) and (L001_Pid_RecMeasData=pPacket^.Packet_ID) then
    Result:=TRUE
  else if (sizeof(cpo_all_sat_data)<>pPacket^.Data_Size) then
    Result:=FALSE
  else if ((PT_Unknown200_Layer=pPacket^.Packet_Type) or
           (PT_Unknown72_Layer=pPacket^.Packet_Type))
          and
          ((Pid_Unknown30664_Pvt=pPacket^.Packet_ID) or
           (Pid_Unknown34760_Pvt=pPacket^.Packet_ID) or
           (Pid_Unknown35400_Pvt=pPacket^.Packet_ID)) then begin
    Result:=TRUE;
    pdwAuxPacket^:=(pdwAuxPacket^ or vgpt_Auxillary);
  end else
    Result:=FALSE;
end;

function Is_Pid_D800_Pvt_Type_Packet(const pPacket: PGarminUSB_Custom_Packet; const pdwAuxPacket: PDWORD): LongBool;
begin
  if (PT_Application_Layer=pPacket^.Packet_Type) and (L001_Pid_Pvt_Data=pPacket^.Packet_ID) then
    Result:=TRUE
  else if (sizeof(D800_Pvt_Data_Type)<>pPacket^.Data_Size) then
    Result:=FALSE
  else if ((PT_Unknown200_Layer=pPacket^.Packet_Type) or
           (PT_Unknown72_Layer=pPacket^.Packet_Type))
          and
          ((Pid_Unknown35016_Pvt=pPacket^.Packet_ID) or
           (Pid_Unknown35144_Pvt=pPacket^.Packet_ID) or
           (Pid_Unknown34888_Pvt=pPacket^.Packet_ID) or
           (Pid_Unknown47048_Pvt=pPacket^.Packet_ID)) then begin
    Result:=TRUE;
    pdwAuxPacket^:=(pdwAuxPacket^ or vgpt_Auxillary);
  end else
    Result:=FALSE;
end;

procedure InternalSetUTCDateTimeFromGarmin(const pData: PD800_Pvt_Data_Type);
var st: TSystemTime;
begin
  DateTimeToSystemTime(Get_UTCDateTime_From_D800(pData), st);
  SetSystemTime(st);
end;

function Internal_WorkingThread_System_Routine(lpParameter: Pointer): DWORD; stdcall;
begin
  Result:=0;
  try
    if (nil<>lpParameter) then
      Tvsagps_device_base(lpParameter).WorkingThread_Internal_Routine;
  except
  end;
  try
    // set exiting flag
    if (nil<>lpParameter) then
      Tvsagps_device_base(lpParameter).FWT_Params.bSelfExited:=TRUE;
  except
  end;
end;

{ Tvsagps_device_base }

procedure Tvsagps_device_base.Connect;
begin
  InternalMakeUnitInfoCS;
  // start internal working thread
  VSAGPS_WorkingThread_Make(@FWT_Handle,
                            @FWT_Params,
                            Internal_WorkingThread_System_Routine,
                            Pointer(Self));
end;

constructor Tvsagps_device_base.Create;
begin
  //inherited Create;
  FForceInfiniteTimeout:=FALSE;
  FDefaultPacketType:=vgpt_Allow_Stats;
  FUNIT_INFO_CS:=nil;
  InternalResetRequestGPSCommand;
  SetBaseParams(0,0,nil,'',nil,nil,nil,nil,nil);
  FGPSDeviceSessionStarted:=0;
  FWT_Handle:=0;
  VSAGPS_WorkingThread_InitParams(@FWT_Params);
  FGPSDeviceHandle:=0;
  FGPSDeviceInfo_NameToConnectInternalA:=nil;
{$if defined(VSAGPS_USE_UNICODE)}
  FGPSDeviceInfo_NameToConnectInternalW:=nil;
{$ifend}
  FAutodetectObject:=nil;
  FDeviceInfo := TStringListA.Create;
  FSupportedProtocols := TStringListA.Create;
  InternalResetDeviceConnectionParams;
  InternalWipeUnitInfoCS;
end;

destructor Tvsagps_device_base.Destroy;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Destroy: begin');
{$ifend}

  WorkingThread_Internal_Close(TRUE);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Destroy: closed');
{$ifend}

  VSAGPS_FreeAndNil_PAnsiChar(FGPSDeviceInfo_NameToConnectInternalA);
{$if defined(VSAGPS_USE_UNICODE)}
  VSAGPS_FreeAndNil_PWideChar(FGPSDeviceInfo_NameToConnectInternalW);
{$ifend}

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Destroy: cleanup');
{$ifend}

  FExternal_Queue:=nil;
  InternalCloseDevice;
  InternalKillAutodetectObject;
  FreeAndNil(FDeviceInfo);
  FreeAndNil(FSupportedProtocols);
  InternalWipeUnitInfoCS;
  InternalKillUnitInfoCS;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Destroy: done');
{$ifend}

  inherited;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Destroy: end');
{$ifend}
end;

procedure Tvsagps_device_base.Disconnect;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Disconnect: begin');
{$ifend}

  WorkingThread_Internal_Close(FALSE);
  //InternalCloseDevice; // async disconnect - allow pending

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Disconnect: end');
{$ifend}
end;

procedure Tvsagps_device_base.ExecuteGPSCommand(const ACommand: LongInt;
                                                const APointer: Pointer);
begin
  if (gpsc_Apply_UTCDateTime = ACommand) then
    if (0 = (FGPSDeviceType and gdt_FILE_Track)) then // do not apply time from tracks
      FRequestGPSCommand_Apply_UTCDateTime:=TRUE;
end;

function Tvsagps_device_base.AllocDeviceInfo(out AIsWide: Boolean): Pointer;
begin
  AIsWide := CIsWide;
  if (nil=FDeviceInfo) or (0=FDeviceInfo.Count) then
    Result:=nil
  else
    Result:=VSAGPS_AllocPCharByString(FDeviceInfo.Text, TRUE);
end;

function Tvsagps_device_base.AllocSupportedProtocols(out AIsWide: Boolean): Pointer;
begin
  AIsWide := CIsWide;
  if (nil=FSupportedProtocols) or (0=FSupportedProtocols.Count) then
    Result:=nil
  else
    Result:=VSAGPS_AllocPCharByString(FSupportedProtocols.Text, TRUE);
end;

function Tvsagps_device_base.AllocUnitInfo(out AIsWide: Boolean): Pointer;
var
  i: TVSAGPS_UNIT_INFO_Kind;
  sl: TStringList;
begin
  AIsWide := CIsWide;
  sl:=TStringList.Create;
  try
    // to list
    for i := Low(TVSAGPS_UNIT_INFO_Kind) to High(TVSAGPS_UNIT_INFO_Kind) do begin
      sl.Append(FUNIT_INFO[i]);
    end;
    // to result
    Result:=VSAGPS_AllocPCharByString(sl.Text, TRUE);
  finally
    sl.Free;
  end;
end;

procedure Tvsagps_device_base.WorkingThread_Internal_Close(const AWaitFor: Boolean);
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Close: begin');
{$ifend}

  VSAGPS_WorkingThread_Kill(@FWT_Handle, @FWT_Params, AWaitFor);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Close: end');
{$ifend}
end;

procedure Tvsagps_device_base.WorkingThread_Internal_Routine;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: begin');
{$ifend}
  try
    //inherited;
    // connect to device
    if not WorkingThread_ConnectToDevice then
      Exit;
      
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: connected');
{$ifend}

    // start session (wait for communication established)
    if not WorkingThread_StartSession then
      Exit;
      
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: started');
{$ifend}

    // send first qwery packet (start data comunicating)
    if not WorkingThread_SendPacket then
      Exit;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: established');
{$ifend}

    // user callback
    try
      if Assigned(FALLDeviceParams.pSessionStartedHandler) then
        FALLDeviceParams.pSessionStartedHandler(InternalGetUserPointer, FUnitIndex, FGPSDeviceType, nil);
    except
    end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: run');
{$ifend}

    // loop reading received packets
    WorkingThread_Process_Packets(0);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: finish');
{$ifend}
  finally
    InternalCloseDevice;
  end;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Internal_Routine: end');
{$ifend}
end;

procedure Tvsagps_device_base.InternalCloseDevice;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalCloseDevice: begin');
{$ifend}

  InternalLockCloseHandle;
  try
    if (0<>FGPSDeviceHandle) then begin
      Internal_Before_Close_Device;

      if (FakeFileHandle<>FGPSDeviceHandle) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalCloseDevice: CloseHandle');
{$ifend}

        CloseHandle(FGPSDeviceHandle);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
        VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalCloseDevice: closed');
{$ifend}
      end;

      FGPSDeviceHandle:=0;
      InternalResetDeviceConnectionParams;
    end;

  finally
    InternalUnlockCloseHandle;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalCloseDevice: end');
{$ifend}
end;

function Tvsagps_device_base.InternalGetUserPointer: Pointer;
begin
  if (nil<>FThisDeviceParams) then
    Result:=FThisDeviceParams^.pUserPointer
  else
    Result:=FALLDeviceUserPointer;
end;

procedure Tvsagps_device_base.InternalKillAutodetectObject;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillAutodetectObject: begin');
{$ifend}

  if (nil<>FAutodetectObject) then
    FreeAndNil(FAutodetectObject);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillAutodetectObject: end');
{$ifend}
end;

procedure Tvsagps_device_base.InternalKillUnitInfoCS;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillUnitInfoCS: begin');
{$ifend}

  if (nil<>FUNIT_INFO_CS) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillUnitInfoCS: delete');
{$ifend}
    DeleteCriticalSection(FUNIT_INFO_CS^);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillUnitInfoCS: dispose');
{$ifend}

    Dispose(FUNIT_INFO_CS);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillUnitInfoCS: cleanup');
{$ifend}

    FUNIT_INFO_CS:=nil;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalKillUnitInfoCS: end');
{$ifend}
end;

procedure Tvsagps_device_base.InternalLockCloseHandle;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalLockCloseHandle: in');
{$ifend}

  if FPtrCS_CloseHandle<>nil then
    EnterCriticalSection(FPtrCS_CloseHandle^);
    
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalLockCloseHandle: ok');
{$ifend}
end;

procedure Tvsagps_device_base.InternalLockUnitInfoCS;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalLockUnitInfoCS: in');
{$ifend}

  if (nil<>FUNIT_INFO_CS) then
    EnterCriticalSection(FUNIT_INFO_CS^);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalLockUnitInfoCS: ok');
{$ifend}
end;

procedure Tvsagps_device_base.InternalMakeUnitInfoCS;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalMakeUnitInfoCS: begin');
{$ifend}

  if (dpdfi_SyncUnitInfo = (FALLDeviceParams^.dwDeviceFlagsIn and dpdfi_SyncUnitInfo)) then begin
    // need sync
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalMakeUnitInfoCS: make');
{$ifend}
    if (nil=FUNIT_INFO_CS) then begin
      New(FUNIT_INFO_CS);
      //ZeroMemory();
      InitializeCriticalSection(FUNIT_INFO_CS^);
    end;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalMakeUnitInfoCS: done');
{$ifend}
  end else begin
    // no sync
    InternalKillUnitInfoCS;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalMakeUnitInfoCS: end');
{$ifend}
end;

procedure Tvsagps_device_base.InternalResetDeviceConnectionParams;
begin
  FGPSDeviceSessionStarted:=0;
end;

procedure Tvsagps_device_base.InternalResetRequestGPSCommand;
begin
  FRequestGPSCommand_Apply_UTCDateTime:=FALSE;
end;

procedure Tvsagps_device_base.InternalSetUnitInfo(const AKind: TVSAGPS_UNIT_INFO_Kind; const ANewValue: string);
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalSetUnitInfo: begin');
{$ifend}

  InternalLockUnitInfoCS;
  try
    if not SameText(FUNIT_INFO[AKind], ANewValue) then begin
      // change
      FUNIT_INFO[AKind] := ANewValue;
      // notify
      if Assigned(FUNIT_INFO_Changed) then
        FUNIT_INFO_Changed(
          InternalGetUserPointer,
          FUnitIndex,
          FGPSDeviceType,
          AKind,
          PChar(ANewValue),
          (SizeOf(Char) = SizeOf(WideChar))
        );
    end;
  finally
    InternalUnlockUnitInfoCS;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalSetUnitInfo: end');
{$ifend}
end;

procedure Tvsagps_device_base.InternalSetUnitInfoA(
  const AKind: TVSAGPS_UNIT_INFO_Kind;
  const ANewValue: AnsiString
);
begin
  InternalSetUnitInfo(AKind, string(ANewValue));
end;

procedure Tvsagps_device_base.InternalUnlockCloseHandle;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalUnlockCloseHandle: in');
{$ifend}

  if FPtrCS_CloseHandle<>nil then
    LeaveCriticalSection(FPtrCS_CloseHandle^);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalUnlockCloseHandle: ok');
{$ifend}
end;

procedure Tvsagps_device_base.InternalUnlockUnitInfoCS;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalUnlockUnitInfoCS: in');
{$ifend}

  if (nil<>FUNIT_INFO_CS) then
    LeaveCriticalSection(FUNIT_INFO_CS^);

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalUnlockUnitInfoCS: ok');
{$ifend}
end;

procedure Tvsagps_device_base.InternalWipeUnitInfoCS;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalWipeUnitInfoCS: begin');
{$ifend}

  InternalLockUnitInfoCS;
  try
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalWipeUnitInfoCS: clear');
{$ifend}

    Clear_TVSAGPS_UNIT_INFO(@FUNIT_INFO);
  finally
    InternalUnlockUnitInfoCS;
  end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.InternalWipeUnitInfoCS: end');
{$ifend}
end;

procedure Tvsagps_device_base.Internal_Before_Close_Device;
begin
// nothing
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Before_Close_Device');
{$ifend}
end;

procedure Tvsagps_device_base.Internal_Before_Open_Device;
begin
  // always redefined by name from user
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Before_Open_Device');
{$ifend}
  VSAGPS_FreeAndNil_PAnsiChar(FGPSDeviceInfo_NameToConnectInternalA);
{$if defined(VSAGPS_USE_UNICODE)}
  VSAGPS_FreeAndNil_PWideChar(FGPSDeviceInfo_NameToConnectInternalW);
{$ifend}
end;

function Tvsagps_device_base.Internal_Do_Open_Device: Boolean;
var
  hFile: THandle;
  dwDevNameLen: DWORD;
  
  procedure InternalSetEmpty;
  begin
    InternalSetUnitInfo(guik_DeviceDriverName, '');
  end;

  procedure InternalSetNameA;
  var sDevDriverName: AnsiString;
  begin
    sDevDriverName := SafeSetStringL(FGPSDeviceInfo_NameToConnectInternalA, dwDevNameLen);
    InternalSetUnitInfo(guik_DeviceDriverName, string(sDevDriverName));
  end;

  procedure InternalSetNameW;
{$if defined(VSAGPS_USE_UNICODE)}
  var sDevDriverNameW: WideString;
{$ifend}
  begin
{$if defined(VSAGPS_USE_UNICODE)}
    if (nil<>FGPSDeviceInfo_NameToConnectInternalW) then begin
      SetString(sDevDriverNameW, FGPSDeviceInfo_NameToConnectInternalW, StrLenW(FGPSDeviceInfo_NameToConnectInternalW));
      InternalSetUnitInfo(guik_DeviceDriverName, sDevDriverNameW);
    end;
{$ifend}
  end;

  procedure InternalSetNameAW;
  begin
{$if defined(VSAGPS_USE_UNICODE)}
    if (nil<>FGPSDeviceInfo_NameToConnectInternalW) then
      InternalSetNameW
    else
{$ifend}
    if (nil<>FGPSDeviceInfo_NameToConnectInternalA) then
      InternalSetNameA;
  end;
  
begin
  Result:=FALSE;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: begin');
{$ifend}

  if (FakeFileHandle=FGPSDeviceHandle) then begin
    // open files internally (without handle)
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: fake');
{$ifend}
    Result:=TRUE;
    InternalSetNameAW;
    Exit;
  end;

{$if defined(VSAGPS_USE_UNICODE)}
  if (nil<>FGPSDeviceInfo_NameToConnectInternalW) then begin
    // open file or device
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: CreateFileW');
{$ifend}
    hFile:=CreateFileW(FGPSDeviceInfo_NameToConnectInternalW,
                       GENERIC_READ,
                       (FILE_SHARE_READ or FILE_SHARE_WRITE),
                       nil,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL,
                       0);
  end else
{$ifend}
  begin
    // device
    if (nil=FGPSDeviceInfo_NameToConnectInternalA) then
      dwDevNameLen:=0
    else
      dwDevNameLen:=StrLenA(FGPSDeviceInfo_NameToConnectInternalA);

    if (0=dwDevNameLen) then begin
      // no device name
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: no device name');
{$ifend}
      InternalSetEmpty;
      FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_No_Device_Name);
      Exit;
    end;

    if (FALLDeviceParams^.btAutodetectOnConnect<>0) and (FGPSDeviceHandle<>0) then begin
      // already connected !!!
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: already connected');
{$ifend}
      InternalSetNameA;
      Result:=TRUE;
      Exit;
    end;

{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: CreateFileA');
{$ifend}

    // com+usb
    hFile:=CreateFileA(FGPSDeviceInfo_NameToConnectInternalA,
                       (GENERIC_READ or GENERIC_WRITE),
                       0,
                       nil,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL,
                       0);
  end;


  if (0=hFile) or (INVALID_HANDLE_VALUE=hFile) then begin
    // failed
    FWT_Params.dwLastError:=GetLastError;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: failed '+IntToStrA(FWT_Params.dwLastError));
{$ifend}
    FWT_Params.dwFinishReason:=(FWT_Params.dwFinishReason or wtfr_Abort_By_Device);
    InternalSetEmpty;
  end else begin
    // ok
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.Internal_Do_Open_Device: ok');
{$ifend}
    FGPSDeviceHandle:=hFile;
    Result:=TRUE;
    InternalSetNameAW;
  end;
end;

procedure Tvsagps_device_base.KillNow;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.KillNow: begin');
{$ifend}
  if (0<>FWT_Handle) then begin
    TerminateThread(FWT_Handle,0);
    Closehandle(FWT_Handle);
    FWT_Handle:=0;
  end;
  FGPSDeviceSessionStarted:=0;
  InternalCloseDevice;
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.KillNow: end');
{$ifend}
end;

function Tvsagps_device_base.Parse_GarminPVT_Packets(const pPacket: PGarminUSB_Custom_Packet; const BaseAuxPacketFlags: DWORD): DWORD;
var
  dwAuxPacket: DWORD;
  pFunc: TVSAGPS_GARMIN_ABSTRACT_HANDLER;
begin
  Result:=0;
  if (nil=pPacket) then
    Exit;
  dwAuxPacket:=BaseAuxPacketFlags;
  // check packet type
  if Is_Pid_D800_Pvt_Type_Packet(pPacket, @dwAuxPacket) then begin
    // if ask to apply gps time to computer time - for garmin - do it from PVT-handler
    if FRequestGPSCommand_Apply_UTCDateTime then begin
      FRequestGPSCommand_Apply_UTCDateTime:=FALSE;
      InternalSetUTCDateTimeFromGarmin(Pointer(@(pPacket^.Data)));
    end;
    // PVT data packets
    pFunc:=TVSAGPS_GARMIN_ABSTRACT_HANDLER(FALLDeviceParams^.pGARMIN_D800_HANDLER);
    if Assigned(pFunc) then begin
      Result:=pFunc(InternalGetUserPointer, FUnitIndex, dwAuxPacket, pPacket^.Data_Size, Pointer(@(pPacket^.Data)));
    end;
  end else if Is_Pid_RecMeasData_Type_Packet(pPacket, @dwAuxPacket) then begin
    // RecMeasData
    pFunc:=TVSAGPS_GARMIN_ABSTRACT_HANDLER(FALLDeviceParams^.pGARMIN_MEAS_HANDLER);
    if Assigned(pFunc) then begin
      Result:=pFunc(InternalGetUserPointer, FUnitIndex, dwAuxPacket, pPacket^.Data_Size, Pointer(@(pPacket^.Data)));
    end;
  end;
end;

function Tvsagps_device_base.Parse_LocationAPI_Packets(const ABuffer: Pointer; const BaseAuxPacketFlags: DWORD): DWORD;
var
  VFunc: TVSAGPS_NMEA_ABSTRACT_HANDLER;
begin
  Result := 0;
  if (nil = ABuffer) then
    Exit;

  VFunc := FALLDeviceParams^.pLocationApi_Handler;
  if Assigned(VFunc) then begin
    Result := VFunc(InternalGetUserPointer, FUnitIndex, BaseAuxPacketFlags, ABuffer);
  end;
end;

procedure Tvsagps_device_base.SetBaseParams(
  const AUnitIndex: Byte;
  const AGPSDeviceType: DWORD;
  const AExternal_Queue: Tvsagps_queue;
  const ADeviceNameByUser: AnsiString;
  const AAllDevParams: PVSAGPS_ALL_DEVICE_PARAMS;
  const AThisDevParams: PVSAGPS_SINGLE_DEVICE_PARAMS;
  const AALLDeviceUserPointer: Pointer;
  const AUNIT_INFO_Changed: TVSAGPS_UNIT_INFO_DLL_Proc;
  const APtrCS_CloseHandle: PRTLCriticalSection);
begin
  FUnitIndex:=AUnitIndex;
  FGPSDeviceType:=AGPSDeviceType;
  FExternal_Queue:=AExternal_Queue;
  FDeviceNameByUser:=ADeviceNameByUser;
  FALLDeviceParams:=AAllDevParams;
  FThisDeviceParams:=AThisDevParams;
  FALLDeviceUserPointer:=AALLDeviceUserPointer;
  FUNIT_INFO_Changed:=AUNIT_INFO_Changed;
  FPtrCS_CloseHandle:=APtrCS_CloseHandle;
end;

function Tvsagps_device_base.WorkingThread_ConnectToDevice: Boolean;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_ConnectToDevice: begin');
{$ifend}

  Internal_Before_Open_Device;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_ConnectToDevice: open');
{$ifend}

  Result:=Internal_Do_Open_Device;
  
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_ConnectToDevice: end');
{$ifend}
end;

procedure Tvsagps_device_base.WorkingThread_Process_Packets(const AWorkingThreadPacketFilter: DWORD);
var dwDelay: DWORD;
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Process_Packets: begin');
{$ifend}

  dwDelay := GetDeviceWorkerThreadTimeoutMSec(FALLDeviceParams, FThisDeviceParams);

  // process reading packets from device to queue
  repeat
    if (0=FGPSDeviceHandle) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Process_Packets: exit no device');
{$ifend}
      Exit;
    end;

    // read packets from device
    if WorkingThread_Receive_Packets(AWorkingThreadPacketFilter) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Process_Packets: exit by packet');
{$ifend}
      Exit;
    end;

    Sleep(0);

    if VSAGPS_WorkingThread_NeedToExit(@FWT_Params) then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
      VSAGPS_DebugAnsiString('Tvsagps_device_base.WorkingThread_Process_Packets: need to exit');
{$ifend}
      Exit;
    end;

    // Sleep
    Sleep(dwDelay);
  until FALSE;
end;

function Tvsagps_device_base.WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean;
begin
  Result := False; // to end outer loop just return True
end;

function Tvsagps_device_base.WorkingThread_SendPacket: Boolean;
begin
  Result:=FALSE; // to cancel just return FALSE
end;

function Tvsagps_device_base.WorkingThread_StartSession: Boolean;
begin
  Result:=FALSE; // to cancel just return FALSE
end;

{ Tvsagps_device_with_nmea }

function Tvsagps_device_with_nmea.FParser_FOnECHOSOUNDER(const p: PVSAGPS_ECHOSOUNDER_DATA): DWORD;
begin
  if Assigned(FALLDeviceParams^.pECHOSOUNDER_HANDLER) then
    Result:=FALLDeviceParams^.pECHOSOUNDER_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
    Result:=0;
end;

function Tvsagps_device_with_nmea.FParser_FOnGGA(const p: PNMEA_GGA): DWORD;
begin
  if Assigned(FALLDeviceParams^.pNMEA_GGA_HANDLER) then
    Result:=FALLDeviceParams^.pNMEA_GGA_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
    Result:=0;
end;

function Tvsagps_device_with_nmea.FParser_FOnGLL(const p: PNMEA_GLL): DWORD;
begin
  if Assigned(FALLDeviceParams^.pNMEA_GLL_HANDLER) then
    Result:=FALLDeviceParams^.pNMEA_GLL_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
    Result:=0;
end;

function Tvsagps_device_with_nmea.FParser_FOnGSA(const p: PNMEA_GSA): DWORD;
begin
  if Assigned(FALLDeviceParams^.pNMEA_GSA_HANDLER) then
    Result:=FALLDeviceParams^.pNMEA_GSA_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
    Result:=0;
end;

function Tvsagps_device_with_nmea.FParser_FOnGSV(const p: PNMEA_GSV): DWORD;
begin
  if Assigned(FALLDeviceParams^.pNMEA_GSV_HANDLER) then
    Result:=FALLDeviceParams^.pNMEA_GSV_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
    Result:=0;
end;

function Tvsagps_device_with_nmea.FParser_FOnRMC(const p: PNMEA_RMC): DWORD;
begin
  if Assigned(FALLDeviceParams^.pNMEA_RMC_HANDLER) then
    Result:=FALLDeviceParams^.pNMEA_RMC_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
    Result:=0;
end;

function Tvsagps_device_with_nmea.FParser_FOnVTG(const p: PNMEA_VTG): DWORD;
begin
{$if defined(USE_NMEA_VTG)}
  if Assign(FALLDeviceParams^.pNMEA_VTG_HANDLER) then
    Result:=FALLDeviceParams^.pNMEA_VTG_HANDLER(InternalGetUserPointer, FUnitIndex, FDefaultPacketType, p)
  else
{$ifend}
    Result:=0;
end;

end.



