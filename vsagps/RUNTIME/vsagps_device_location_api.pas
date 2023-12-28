(*
  VSAGPS Library. Copyright (C) 2013, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_device_location_api;
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
{$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
  LocationApiLib_TLB,
{$ELSE}
  Winapi.Locationapi,
{$ENDIF}
  vsagps_device_base;

type
  Tvsagps_device_location_api = class(Tvsagps_device_base)
  private
    FLocation: ILocation;
    FReportType: TGUID; // array
    FReportStatus: LOCATION_REPORT_STATUS;
    FLocationEvents: ILocationEvents;
    FComInitRes: HResult;
  protected
    procedure InternalResetDeviceConnectionParams; override;
    procedure Internal_Before_Open_Device; override;
    // start session - operations to establish connection
    function WorkingThread_StartSession: Boolean; override;
    // send query packet to gps
    function WorkingThread_SendPacket: Boolean; override;
    // receive packets from device to queue
    function WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ExecuteGPSCommand(const ACommand: LongInt;
                                const APointer: Pointer); override;
    function SerializePacket(const APacket: Pointer; const AReserved: PDWORD): PAnsiChar; override;
    function ParsePacket(const ABuffer: Pointer): DWORD; override;

    function SendPacket(const APacketBuffer: Pointer;
                        const APacketSize: DWORD;
                        const AFlags: DWORD): LongBool; override;
  end;


implementation

uses
  ComObj,
  ActiveX,
  vsagps_runtime,
  vsagps_public_location_api,
  vsagps_public_memory,
  vsagps_public_unit_info;

type
  TLocationEvents = class(TInterfacedObject, ILocationEvents)
  private
    {$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
    function OnLocationChanged(var reportType: TGUID; const pLocationReport: ILocationReport): HResult; stdcall;
    function OnStatusChanged(var reportType: TGUID; newStatus: LOCATION_REPORT_STATUS): HResult; stdcall;
    {$ELSE}
    function OnLocationChanged(const reportType: TIID; const pLocationReport: ILocationReport): HRESULT; stdcall;
    function OnStatusChanged(const reportType: TIID; newStatus: LOCATION_REPORT_STATUS): HRESULT; stdcall;
    {$ENDIF}
  end;

{ TLocationEvents }

function TLocationEvents.OnLocationChanged(
  {$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
  var reportType: TGUID;
  {$ELSE}
  const reportType: TGUID;
  {$ENDIF}
  const pLocationReport: ILocationReport
): HResult;
begin
  Result := S_OK;
end;

function TLocationEvents.OnStatusChanged(
  {$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
  var reportType: TGUID;
  {$ELSE}
  const reportType: TGUID;
  {$ENDIF}
  newStatus: LOCATION_REPORT_STATUS
): HResult;
begin
  Result := S_OK;
end;

{ Tvsagps_device_location_api }

constructor Tvsagps_device_location_api.Create;
begin
  inherited;
  FLocation := nil;
  FComInitRes := E_FAIL;
  FReportType := IID_ILatLongReport;
  FReportStatus := REPORT_NOT_SUPPORTED;
  FLocationEvents := TLocationEvents.Create;
end;

destructor Tvsagps_device_location_api.Destroy;
begin
  if (FLocation <> nil) then begin
    FLocation.UnregisterForReport(FReportType);
    FLocation := nil;
  end;
  inherited;
end;

procedure Tvsagps_device_location_api.ExecuteGPSCommand(const ACommand: LongInt;
                                                      const APointer: Pointer);
begin
  inherited;
  // gpsc_Refresh_DGPS - not supported
end;

procedure Tvsagps_device_location_api.InternalResetDeviceConnectionParams;
begin
  inherited;
  if (FLocation <> nil) then begin
    FLocation.UnregisterForReport(FReportType);
    FLocation := nil;
  end;
  if Succeeded(FComInitRes) then begin
    CoUninitialize;
    FComInitRes := E_FAIL;
  end;
end;

procedure Tvsagps_device_location_api.Internal_Before_Open_Device;
begin
  inherited;
  FGPSDeviceHandle := FakeFileHandle;
end;

function Tvsagps_device_location_api.ParsePacket(const ABuffer: Pointer): DWORD;
begin
  Result := Parse_LocationAPI_Packets(ABuffer, FDefaultPacketType);
end;

function Tvsagps_device_location_api.SendPacket(
  const APacketBuffer: Pointer;
  const APacketSize: DWORD;
  const AFlags: DWORD
): LongBool;
begin
  Assert(False);
  Result := False;
end;

function Tvsagps_device_location_api.SerializePacket(const APacket: Pointer; const AReserved: PDWORD): PAnsiChar;
begin
  Result := VSAGPS_AllocPCharByPByte(APacket, SizeOf(Tvsagps_location_api_packet));
end;

function Tvsagps_device_location_api.WorkingThread_Receive_Packets(const AWorkingThreadPacketFilter: DWORD): Boolean;
var
  VResult: HResult;
  VLocationReport: ILocationReport;
  VLatLongReport: ILatLongReport;
  VPacket: Pvsagps_location_api_packet;
begin
  Result := False;
  if (0 = FGPSDeviceHandle) or (nil = FLocation) then begin
    Inc(Result);
    Exit;
  end;

  // get status
  VResult := FLocation.GetReportStatus(FReportType, FReportStatus);
  if Failed(VResult) then
    Exit;

  // get report
  VResult := FLocation.GetReport(FReportType, VLocationReport);
  if Failed(VResult) then
    Exit;

  if not Supports(VLocationReport, ILatLongReport, VLatLongReport) then
    Exit;

  // add to queue
  VPacket := VSAGPS_GetMem(SizeOf(VPacket^));
  try
    VPacket^.SetReport(VLatLongReport);
    FExternal_Queue.AppendGPSPacket(VPacket, FUnitIndex);
    VPacket := nil;
  finally
    VSAGPS_FreeMem(VPacket);
  end;
end;

function Tvsagps_device_location_api.WorkingThread_SendPacket: Boolean;
begin
  Result := True;
end;

function Tvsagps_device_location_api.WorkingThread_StartSession: Boolean;
var
  VResult: HResult;
begin
  if (FLocation <> nil) then begin
    FLocation.UnregisterForReport(FReportType);
    FLocation := nil;
  end;

  if (E_FAIL = FComInitRes) then begin
    FComInitRes := CoInitializeEx(nil, COINIT_MULTITHREADED);
  end;

  FLocation := CreateComObject(
    {$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
    CLASS_Location
    {$ELSE}
    CLSID_Location
    {$ENDIF}
  ) as ILocation;

  Result := (FLocation <> nil);

  if Result then begin
    VResult := FLocation.RequestPermissions(
      {$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
      _RemotableHandle(nil^),
      FReportType,
      1,
      1 // 0 for asynchronous calls
      {$ELSE}
      0, @FReportType, 1, True
      {$ENDIF}
    );
    // -2147417842 = $8001010E = RPC_E_WRONG_THREAD
    // 1 = S_FALSE
    Result := SUCCEEDED(VResult);
    if Result then begin
      FLocation.RegisterForReport(FLocationEvents, FReportType, 1);
    end;
  end;
end;

end.

