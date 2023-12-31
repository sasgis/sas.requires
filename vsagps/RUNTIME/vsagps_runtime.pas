(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_runtime;
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
  vsagps_public_classes,
  vsagps_tools;

(*
typedef enum _EVENT_TYPE {
	NotificationEvent, // A manual-reset event
	SynchronizationEvent // An auto-reset event
} EVENT_TYPE;
*)
type
  EVENT_TYPE=Byte;
const
  NotificationEvent=0;
  SynchronizationEvent=1;

const
  NtCurrentProcess = DWORD(-1);

  FakeFileHandle = THandle(1);

const
  ntdll_dll='ntdll.dll';

type
  CLIENT_ID=record
    UniqueProcess: DWORD;
    UniqueThread: DWORD;
  end;
  PCLIENT_ID=^CLIENT_ID;

const
  setupapi_dll = 'setupapi.dll';

type
  HDEVINFO = THandle;

  SP_DEVICE_INTERFACE_DETAIL_DATA_A = packed record
    cbSize: DWORD;
    DevicePath: AnsiChar; // A NULL-terminated string that contains the device interface path
  end;
  PSP_DEVICE_INTERFACE_DETAIL_DATA_A = ^SP_DEVICE_INTERFACE_DETAIL_DATA_A;

  SP_DEVINFO_DATA = record
    cbSize: DWORD;
    ClassGuid: TGUID;
    DevInst: DWORD;    // DEVINST handle
    Reserved: DWORD;
  end;
  PSP_DEVINFO_DATA = ^SP_DEVINFO_DATA;

  SP_DEVICE_INTERFACE_DATA = record
    cbSize: DWORD;
    InterfaceClassGuid: TGUID;
    Flags: DWORD;
    Reserved: DWORD;
  end;
  PSP_DEVICE_INTERFACE_DATA = ^SP_DEVICE_INTERFACE_DATA;

(*
USB
#define SPINT_ACTIVE  0x00000001
#define SPINT_DEFAULT 0x00000002
#define SPINT_REMOVED 0x00000004

typedef struct _SP_DEVICE_INTERFACE_DETAIL_DATA_A {
    DWORD  cbSize;
    CHAR   DevicePath[ANYSIZE_ARRAY];
} SP_DEVICE_INTERFACE_DETAIL_DATA_A, *PSP_DEVICE_INTERFACE_DETAIL_DATA_A;

typedef struct _SP_DEVICE_INTERFACE_DETAIL_DATA_W {
    DWORD  cbSize;
    WCHAR  DevicePath[ANYSIZE_ARRAY];
} SP_DEVICE_INTERFACE_DETAIL_DATA_W, *PSP_DEVICE_INTERFACE_DETAIL_DATA_W;

typedef SP_DEVICE_INTERFACE_DETAIL_DATA_A SP_INTERFACE_DEVICE_DETAIL_DATA_A;
typedef PSP_DEVICE_INTERFACE_DETAIL_DATA_A PSP_INTERFACE_DEVICE_DETAIL_DATA_A;
typedef SP_INTERFACE_DEVICE_DETAIL_DATA_A SP_INTERFACE_DEVICE_DETAIL_DATA;
typedef PSP_INTERFACE_DEVICE_DETAIL_DATA_A PSP_INTERFACE_DEVICE_DETAIL_DATA;

// Flags controlling what is included in the device information set built
// by SetupDiGetClassDevs
//
*)

const
  DIGCF_DEFAULT         = $01;  // only valid with DIGCF_DEVICEINTERFACE
  DIGCF_PRESENT         = $02;
  DIGCF_ALLCLASSES      = $04;
  DIGCF_PROFILE         = $08;
  DIGCF_DEVICEINTERFACE = $10;

  // registry props of devices
  SPDRP_DEVICEDESC                  =($00000000)  ;// DeviceDesc (R/W)
  SPDRP_HARDWAREID                  =($00000001)  ;// HardwareID (R/W)
  SPDRP_COMPATIBLEIDS               =($00000002)  ;// CompatibleIDs (R/W)
  SPDRP_NTDEVICEPATHS               =($00000003)  ;// Unsupported, DO NOT USE
  SPDRP_SERVICE                     =($00000004)  ;// Service (R/W)
  SPDRP_CONFIGURATION               =($00000005)  ;// Configuration (R)
  SPDRP_CONFIGURATIONVECTOR         =($00000006)  ;// ConfigurationVector (R)
  SPDRP_CLASS                       =($00000007)  ;// Class (R--tied to ClassGUID)
  SPDRP_CLASSGUID                   =($00000008)  ;// ClassGUID (R/W)
  SPDRP_DRIVER                      =($00000009)  ;// Driver (R/W)
  SPDRP_CONFIGFLAGS                 =($0000000A)  ;// ConfigFlags (R/W)
  SPDRP_MFG                         =($0000000B)  ;// Mfg (R/W)
  SPDRP_FRIENDLYNAME                =($0000000C)  ;// FriendlyName (R/W)
  SPDRP_LOCATION_INFORMATION        =($0000000D)  ;// LocationInformation (R/W)
  SPDRP_PHYSICAL_DEVICE_OBJECT_NAME =($0000000E)  ;// PhysicalDeviceObjectName (R)
  SPDRP_CAPABILITIES                =($0000000F)  ;// Capabilities (R)
  SPDRP_UI_NUMBER                   =($00000010)  ;// UiNumber (R)
  SPDRP_UPPERFILTERS                =($00000011)  ;// UpperFilters (R/W)
  SPDRP_LOWERFILTERS                =($00000012)  ;// LowerFilters (R/W)
  SPDRP_MAXIMUM_PROPERTY            =($00000013)  ;// Upper bound on ordinals
  // _SETUPAPI_VER >= _WIN32_WINNT_LONGHORN
  SPDRP_BUSTYPEGUID                 =($00000013)  ;// BusTypeGUID (R)
  SPDRP_LEGACYBUSTYPE               =($00000014)  ;// LegacyBusType (R)
  SPDRP_BUSNUMBER                   =($00000015)  ;// BusNumber (R)
  SPDRP_ENUMERATOR_NAME             =($00000016)  ;// Enumerator Name (R)
  SPDRP_SECURITY                    =($00000017)  ;// Security (R/W, binary form)
  SPDRP_SECURITY_SDS                =($00000018)  ;// Security (W, SDS form)
  SPDRP_DEVTYPE                     =($00000019)  ;// Device Type (R/W)
  SPDRP_EXCLUSIVE                   =($0000001A)  ;// Device is exclusive-access (R/W)
  SPDRP_CHARACTERISTICS             =($0000001B)  ;// Device Characteristics (R/W)
  SPDRP_ADDRESS                     =($0000001C)  ;// Device Address (R)
  SPDRP_UI_NUMBER_DESC_FORMAT       =($0000001D)  ;// UiNumberDescFormat (R/W)
  SPDRP_DEVICE_POWER_DATA           =($0000001E)  ;// Device Power Data (R)
  SPDRP_REMOVAL_POLICY              =($0000001F)  ;// Removal Policy (R)
  SPDRP_REMOVAL_POLICY_HW_DEFAULT   =($00000020)  ;// Hardware Removal Policy (R)
  SPDRP_REMOVAL_POLICY_OVERRIDE     =($00000021)  ;// Removal Policy Override (RW)
  SPDRP_INSTALL_STATE               =($00000022)  ;// Device Install State (R)
  SPDRP_LOCATION_PATHS              =($00000023)  ;// Device Location Paths (R)
  SPDRP_BASE_CONTAINERID            =($00000024)  ;// Base ContainerID (R)
//  SPDRP_MAXIMUM_PROPERTY            ($00000025)  ;// Upper bound on ordinals


type
// returns handle
  TSetupDiGetClassDevsA = function (ClassGuid: PGUID;
                                    Enumerator: PAnsiChar;
                                    hwndParent: HWND;
                                    Flags: DWORD
                                    ): HDEVINFO; stdcall; // external setupapi_dll;

// kills handle from SetupDiGetClassDevsA
TSetupDiDestroyDeviceInfoList = function (DeviceInfoSet: HDEVINFO): LongBool; stdcall; // external setupapi_dll;

// out DeviceInterfaceData
TSetupDiEnumDeviceInterfaces = function (DeviceInfoSet: HDEVINFO;
                                         DeviceInfoData: PSP_DEVINFO_DATA;
                                         InterfaceClassGuid: PGUID;
                                         MemberIndex: DWORD;
                                         DeviceInterfaceData: PSP_DEVICE_INTERFACE_DATA
                                         ): LongBool; stdcall; // external setupapi_dll;

// out DeviceInterfaceDetailData, RequiredSize, DeviceInfoData
TSetupDiGetDeviceInterfaceDetailA = function (DeviceInfoSet: HDEVINFO;
                                              DeviceInterfaceData: PSP_DEVICE_INTERFACE_DATA;
                                              DeviceInterfaceDetailData: PSP_DEVICE_INTERFACE_DETAIL_DATA_A;
                                              DeviceInterfaceDetailDataSize: DWORD;
                                              RequiredSize: PDWORD;
                                              DeviceInfoData: PSP_DEVINFO_DATA
                                              ): LongBool; stdcall; // external setupapi_dll;

TSetupDiEnumDeviceInfo = function(DeviceInfoSet: HDEVINFO;
                                  MemberIndex: DWORD;
                                  DeviceInfoData: PSP_DEVINFO_DATA // out
                                  ): LongBool; stdcall; // external setupapi_dll;


TSetupDiGetDeviceRegistryPropertyW = function (DeviceInfoSet: HDEVINFO;
                                               DeviceInfoData: PSP_DEVINFO_DATA;
                                               _Property: DWORD;
                                               PropertyRegDataType: PDWORD; // out opt
                                               PropertyBuffer: PBYTE; // out opt
                                               PropertyBufferSize: DWORD;
                                               RequiredSize: PDWORD // out opt
                                               ): LongBool; stdcall; // external setupapi_dll;



type
  NTSTATUS = LongInt;
  PWSTR=PWideChar;
  PIO_APC_ROUTINE=Pointer;
  SIZE_T=ULONG;
  PRTL_CRITICAL_SECTION = ^TRTLCriticalSection;
  PLARGE_INTEGER=^LARGE_INTEGER;
  PTHREAD_START_ROUTINE = function(lpThreadParameter: Pointer): DWORD; stdcall;

  UNICODE_STRING=record
	  Length: WORD;
	  MaximumLength: WORD;
	  Buffer: PWSTR;
  end;
  PUNICODE_STRING=^UNICODE_STRING;

  OBJECT_ATTRIBUTES=record
    Length: ULONG;
    RootDirectory: Pointer;
    ObjectName: PUNICODE_STRING;
    Attributes: ULONG;
    SecurityDescriptor: Pointer;
    SecurityQualityOfService: Pointer;
  end;
  POBJECT_ATTRIBUTES=^OBJECT_ATTRIBUTES;  
  
type
  // internal working thread params
  TVSAGPS_WorkingThread_Params = record
    bAskToExit: LongBool; // flag set by main thread to notify internal working thread to exit
    bSelfExited: LongBool; // flag set by internal working thread when exited
    sClientId: CLIENT_ID; // used to create thread
    dwLastError: DWORD; // getlasterror in thread
    dwFinishReason: DWORD; // internal working thread finish reasons (wtfr_* constants)
    dwRunningOptions: DWORD; // options (wtro_* constants)
  end;
  PVSAGPS_WorkingThread_Params = ^TVSAGPS_WorkingThread_Params;

  // external ntdll_dll;
  TNtClose = function (hObject: THandle): NTSTATUS; stdcall;

  TNtOpenSymbolicLinkObject = function (
    phSymbolicLink: PHANDLE;
    DesiredAccess: ACCESS_MASK;
    ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall;

  TNtQuerySymbolicLinkObject = function (
    hSymbolicLink: THandle;
    TargetName: PUNICODE_STRING;
    ReturnLength: PULONG): NTSTATUS; stdcall;
  
{$if defined(USE_NATIVE_NT_API)}

function NtClose(hObject: THandle): NTSTATUS; stdcall; external ntdll_dll;

function NtCreateEvent(
	EventHandle: PHANDLE;
	DesiredAccess: ACCESS_MASK;
	ObjectAttributes: POBJECT_ATTRIBUTES;
	EventType: EVENT_TYPE;
	InitialState: BOOLEAN): NTSTATUS; stdcall; external ntdll_dll;

function NtDeviceIoControlFile (
	DeviceHandle: THandle;
	Event: THandle;
	UserApcRoutine: PIO_APC_ROUTINE;
	UserApcContext: Pointer;
	IoStatusBlock: PIO_STATUS_BLOCK;
	IoControlCode: ULONG;
	InputBuffer: Pointer;
	InputBufferSize: ULONG;
	OutputBuffer: Pointer;
	OutputBufferSize: ULONG
): NTSTATUS; stdcall; external ntdll_dll;

function NtReadFile (
	FileHandle: THandle;
	Event: THandle;
	UserApcRoutine: PIO_APC_ROUTINE;
	UserApcContext: Pointer;
	IoStatusBlock: PIO_STATUS_BLOCK;
	Buffer: Pointer;
	BufferLength: ULONG;
	ByteOffset: PLARGE_INTEGER;
	Key: PULONG
): NTSTATUS; stdcall; external ntdll_dll;
  
function NtTerminateThread (
	ThreadHandle: THandle;
  ExitStatus: NTSTATUS
): NTSTATUS; stdcall; external ntdll_dll;

function NtWaitForSingleObject (
	hObject: THandle;
	Alertable: BOOLEAN;
	Time: PLARGE_INTEGER
): NTSTATUS; stdcall; external ntdll_dll;

function NtWriteFile (
	FileHandle: THandle;
	Event: THandle;
	ApcRoutine: PIO_APC_ROUTINE;
	ApcContext: Pointer;
	IoStatusBlock: PIO_STATUS_BLOCK;
	Buffer: Pointer;
	Length: ULONG;
	ByteOffset: PLARGE_INTEGER;
	Key: PULONG
): NTSTATUS; stdcall; external ntdll_dll;

function RtlCreateUserThread (
	ProcessHandle: THandle;
	SecurityDescriptor: PSECURITY_DESCRIPTOR;
	CreateSuspended: BOOLEAN;
	StackZeroBits: ULONG;
	StackReserve: SIZE_T;
	StackCommit: SIZE_T;
	StartAddress: PTHREAD_START_ROUTINE;
	Parameter: Pointer;
	ThreadHandle: PHANDLE;
	ClientId: PCLIENT_ID
): NTSTATUS; stdcall; external ntdll_dll;

function RtlExitUserThread(
  ExitStatus: ULONG
): NTSTATUS; stdcall; external ntdll_dll;

(*
function RtlFreeUserThreadStack(
  ProcessHandle: THandle;
  ThreadHandle: THandle
): NTSTATUS; stdcall; external ntdll_dll;
*)
  
{$ifend}

{$if defined(USE_NATIVE_NT_API)}
function VSAGPS_CreateEvent(phEvent: PHandle): NTSTATUS;
{$ifend}

// terminate and close working thread
procedure VSAGPS_WorkingThread_Kill(phThread: PHandle;
                                    pParams: PVSAGPS_WorkingThread_Params;
                                    const AWaitFor: Boolean);
// initialize working thread params
procedure VSAGPS_WorkingThread_InitParams(pParams: PVSAGPS_WorkingThread_Params); inline;
// wait for internal thread to exit
function VSAGPS_WorkingThread_WaitExited(phThread: PHandle;
                                         pParams: PVSAGPS_WorkingThread_Params): LongBool;
// make working thread and run it
function VSAGPS_WorkingThread_Make(phThread: PHandle;
                                   pParams: PVSAGPS_WorkingThread_Params;
                                   pStartAddress: PTHREAD_START_ROUTINE;
                                   pParameter: Pointer): LongBool;
// check to exit (in internal working thread)
function VSAGPS_WorkingThread_NeedToExit(pParams: PVSAGPS_WorkingThread_Params): LongBool;

// autodetect usb and other devices (for garmin searching)
function VSAGPS_Autodetect_Get_SetupDi_Devices(const AClassGuid: PGUID;
                                               pdwLastError: PDWORD;
                                               const AOnlySingleItem: Boolean;
                                               const sl_container: TStrings): DWORD; stdcall;

implementation

uses
  vsagps_public_sysutils,
  vsagps_public_memory;

procedure VSAGPS_WorkingThread_InitParams(pParams: PVSAGPS_WorkingThread_Params);
begin
  ZeroMemory(pParams, sizeof(pParams^));
end;

function VSAGPS_WorkingThread_WaitExited(phThread: PHandle;
                                         pParams: PVSAGPS_WorkingThread_Params): LongBool;
var
  i: Byte;
  ex: DWORD;
begin
  // returns true if internal thread exited by itself
  i:=cWorkingThread_SimpleWait_Count;
  repeat
    Sleep(0);
    try
      // check
      Result:=pParams^.bSelfExited;
      if Result then
        if GetExitCodeThread(phThread^, ex) then
          Result:=(STILL_ACTIVE<>ex);
    except
      Result:=TRUE;
    end;
    if Result or (0=i) then
      Exit;
    Sleep(cWorkingThread_SimpleWait_Msec);
    Dec(i);
  until FALSE;
end;

procedure VSAGPS_WorkingThread_Kill(phThread: PHandle;
                                    pParams: PVSAGPS_WorkingThread_Params;
                                    const AWaitFor: Boolean);
var li: LARGE_INTEGER;
begin
  if (0=phThread^) then
    Exit;

  // notify internal thread to exit
  pParams^.bAskToExit:=TRUE;

  if (not AWaitFor) then
    Exit;

  // check internal working thread exiting, if not - wait it
  if (not VSAGPS_WorkingThread_WaitExited(phThread,
                                          pParams)) then begin
    // wait for thread about 1.2 sec
{$if defined(USE_NATIVE_NT_API)}
    li.QuadPart:=-10000*cWorkingThread_MaxDelay_Msec;
    NtWaitForSingleObject(phThread^, FALSE, @li);
{$else}
    li.LowPart:=cWorkingThread_MaxDelay_Msec;
    WaitForSingleObject(phThread^, li.LowPart);
{$ifend}
  end;

  // kill and close
{$if defined(USE_NATIVE_NT_API)}
  NtTerminateThread(phThread^, 0);
  ////RtlFreeUserThreadStack(NtCurrentProcess, phThread^);
  NtClose(phThread^);
{$else}
  TerminateThread(phThread^, 0);
  CloseHandle(phThread^);
{$ifend}

  phThread^:=0;
  VSAGPS_WorkingThread_InitParams(pParams);
end;

function VSAGPS_WorkingThread_Make(phThread: PHandle;
                                   pParams: PVSAGPS_WorkingThread_Params;
                                   pStartAddress: PTHREAD_START_ROUTINE;
                                   pParameter: Pointer): LongBool;
begin
  // kill thread if exists
  if (0<>phThread^) then
    VSAGPS_WorkingThread_Kill(phThread, pParams, TRUE);
  // create new thread
{$if defined(USE_NATIVE_NT_API)}
  Result:=(STATUS_SUCCESS=RtlCreateUserThread(
                NtCurrentProcess,
                nil,
                FALSE,
                0, 0, 0,
                pStartAddress,
                pParameter,
                phThread,
                @(pParams^.sClientId)));
  if (Result) then
    Result:=(0<>phThread^);
{$else}
  pParams^.sClientId.UniqueProcess:=0; // GetCurrentProcessId;
  phThread^:=CreateThread(
               nil,
               0,
               @pStartAddress,
               pParameter,
               0,
               pParams^.sClientId.UniqueThread);
  Result:=(0<>phThread^);
{$ifend}
end;

function VSAGPS_WorkingThread_NeedToExit(pParams: PVSAGPS_WorkingThread_Params): LongBool;
begin
  Result:=FALSE;
  if (0<>pParams^.dwFinishReason) then
    Result:=TRUE
  else if (pParams^.bAskToExit) then
    Result:=TRUE;
end;

{$if defined(USE_NATIVE_NT_API)}
function VSAGPS_CreateEvent(phEvent: PHandle): NTSTATUS;
begin
  Result:=NtCreateEvent(phEvent, (_DELETE or READ_CONTROL or SYNCHRONIZE or WRITE_DAC or WRITE_OWNER or 3),
                        nil,
                        NotificationEvent,
                        FALSE);
end;
{$ifend}

function VSAGPS_Autodetect_Get_SetupDi_Devices(const AClassGuid: PGUID;
                                               pdwLastError: PDWORD;
                                               const AOnlySingleItem: Boolean;
                                               const sl_container: TStrings): DWORD;

  function _AssertWithLastError(const bError: Boolean): Boolean;
  begin
    Result:=bError;
    if Result then
      if (nil<>pdwLastError) then
        pdwLastError^:=GetLastError;
  end;

var
  hDLL: HMODULE;
  pFunc, pEnum: Pointer;
  bDiResult: LongBool;
  theDevInfo: HDEVINFO;
  dwErr: DWORD;
  theBytesReturned: DWORD;
  theInterfaceData: SP_DEVICE_INTERFACE_DATA;
  theDevDetailData: PSP_DEVICE_INTERFACE_DETAIL_DATA_A;
  theDevInfoData: SP_DEVINFO_DATA;
  str_dev_name: AnsiString;
  VMemberIndex: DWORD;
begin
  Result:=0;
  // guid is mandatory
  if (nil=AClassGuid) then
    Exit;
  hDLL:=LoadLibraryA(setupapi_dll);
  // dll not loaded - failed
  if _AssertWithLastError(0=hDLL) then
    Exit;
  try
    pFunc:=GetProcAddress(hDLL,'SetupDiGetClassDevsA');
    if _AssertWithLastError(nil=pFunc) then
      Exit;
    // If the operation succeeds, SetupDiGetClassDevs returns a handle to a device information set that contains all installed devices that matched the supplied parameters.
    // If the operation fails, the function returns INVALID_HANDLE_VALUE
    theDevInfo:=TSetupDiGetClassDevsA(pFunc)(AClassGuid, nil, 0, (DIGCF_PRESENT or DIGCF_DEVICEINTERFACE));
    if not _AssertWithLastError(INVALID_HANDLE_VALUE=theDevInfo) then
    try
      ZeroMemory(@theInterfaceData,sizeof(theInterfaceData));
      theInterfaceData.cbSize:=sizeof(theInterfaceData);
      // get new functions
      pEnum:=GetProcAddress(hDLL,'SetupDiEnumDeviceInterfaces'); // OR SetupDiEnumDeviceInfo for dev info + SetupDiGetDeviceRegistryProperty
      if _AssertWithLastError(nil=pEnum) then
        Exit;
      pFunc:=GetProcAddress(hDLL,'SetupDiGetDeviceInterfaceDetailA');
      if _AssertWithLastError(nil=pFunc) then
        Exit;
      // enum
      VMemberIndex:=0;
      repeat
        // enum procedure
        bDiResult:=TSetupDiEnumDeviceInterfaces(pEnum)(theDevInfo, nil, AClassGuid, VMemberIndex, @theInterfaceData);
        if (not bDiResult) then begin
          // GetLastError=ERROR_NO_MORE_ITEMS = 259 - enum finished successfully
          dwErr:=GetLastError;
          if (ERROR_NO_MORE_ITEMS<>dwErr) then
            if (nil<>pdwLastError) then
              pdwLastError^:=dwErr;
          break;
        end;

        // device found
        // get interface detail
        // ERROR_NO_MORE_ITEMS = 259
        // just get required buffer size
        // ERROR_INSUFFICIENT_BUFFER = 122
        theBytesReturned:=0;
        bDiResult:=TSetupDiGetDeviceInterfaceDetailA(pFunc)(theDevInfo, @theInterfaceData, nil, 0, @theBytesReturned, nil);
        if (not bDiResult) then
        begin
          dwErr:=GetLastError;
          if (ERROR_INSUFFICIENT_BUFFER<>dwErr) then begin
            if (nil<>pdwLastError) then
              pdwLastError^:=dwErr;
            break;
          end;
        end;
        // required size defined
        if (0<theBytesReturned) then begin
          theDevDetailData := VSAGPS_GetMemZ(theBytesReturned);
          try
            theDevDetailData^.cbSize := sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
            ZeroMemory(@theDevInfoData,sizeof(theDevInfoData));
            theDevInfoData.cbSize:=sizeof(theDevInfoData);

            // ERROR_INVALID_USER_BUFFER = 1784
            bDiResult:=TSetupDiGetDeviceInterfaceDetailA(pFunc)(theDevInfo, @theInterfaceData, theDevDetailData, theBytesReturned, nil, @theDevInfoData);
            if bDiResult then begin
              // save info to list
              dwErr:=StrLenA(PAnsiChar(@(theDevDetailData^.DevicePath)));
              SetString(str_dev_name, PAnsiChar(@(theDevDetailData^.DevicePath)), dwErr);
              //if sl_names.IndexOf(str_dev_name)>=0 then
                //break;
              sl_container.Append(string(str_dev_name));
              if AOnlySingleItem then
                break;
            end else begin
              // save error number
              dwErr:=GetLastError;
              if (nil<>pdwLastError) then
                pdwLastError^:=dwErr;
            end;
          finally
            VSAGPS_FreeMem(theDevDetailData);
          end;
        end;
        Inc(VMemberIndex);
      until FALSE;
    finally
      pFunc:=GetProcAddress(hDLL,'SetupDiDestroyDeviceInfoList');
      if not _AssertWithLastError(nil=pFunc) then
        TSetupDiDestroyDeviceInfoList(pFunc)(theDevInfo);
    end;
  finally
    FreeLibrary(hDLL);
  end;
end;

end.
