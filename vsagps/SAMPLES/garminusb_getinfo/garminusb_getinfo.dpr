(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
program garminusb_getinfo;
(*
*)

{$APPTYPE CONSOLE}

{$I vsagps_defines.inc}

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_classes,
  vsagps_public_device,
  vsagps_public_memory,
  vsagps_tools,
  vsagps_object,
  vsagps_public_events,
  vsagps_public_unit_info,
  vsagps_public_print,
  vsagps_public_sysutils,
  vsagps_public_version,
{$if defined(USE_SIMPLE_CLASSES)}
  vsagps_classes,
{$else}
  Classes,
{$ifend}
  DateUtils,
  Math;

const
  maxPVT_Counter = 3;

var
  gg_FS: TFormatSettings;

type
  TGarminInfoObject = class(Tvsagps_object)
  protected
    FDevParams: TVSAGPS_ALL_DEVICE_PARAMS;
    FUnitIndex: Byte;
    FPVT_Counter: Byte;
    FStateFromEvent: Tvsagps_GPSState;
    procedure CheckPVTCounter;
  end;

function STtoString(const st: Tvsagps_GPSState): AnsiString;
begin
  case st of
    gs_ProcessConnecting: Result:='Connecting';
    gs_DoneConnected: Result:='Connected';
    gs_ProcessDisconnecting: Result:='Disconnecting';
    gs_DoneDisconnected: Result:='Disconnected';
  else
    Result:='Tvsagps_GPSState('+IntToStrA(Ord(st))+')';
  end;
end;
  
procedure StrW(var result_str: string; const wid: Integer; const ch: Char);
begin
  while Length(result_str) < wid do
    result_str := ch + result_str;
end;

function ByteToBinW(bt: Byte; const wid: Integer): string;
begin
  Result := '';
  while (bt <> 0) do begin
    Result := Char(Ord('0')+(bt and 1)) + Result;
    bt := bt shr 1;
  end;
  if (0 = Length(Result)) then
    Result := '0';
  StrW(Result, wid, '0');
end;

function IntToStrW(i: Integer; const wid: Integer): string;
begin
  Result := IntToStr(i);
  StrW(Result, wid, ' ');
end;

procedure PrintAndKill(
  const ABuffer: Pointer;
  const AIsWide: Boolean;
  const AIsUnitInfo: Boolean
);
var
  k: Integer;
  i: TVSAGPS_UNIT_INFO_Kind;
  VList: TStringListA;
  VLine: AnsiString;
begin
  if (nil = ABuffer) then
    Exit;
  try
    if AIsUnitInfo then begin
      // lines with tags
      VList := TStringListA.Create;
      try
        if AIsWide then begin
          VList.SetFileContentW(WideString(PWideChar(ABuffer)));
        end else begin
          VList.SetFileContentA(AnsiString(PAnsiChar(ABuffer)));
        end;

        k := VList.Count;
        for i := Low(TVSAGPS_UNIT_INFO_Kind) to High(TVSAGPS_UNIT_INFO_Kind) do begin
          if (Ord(i)>=k) then
            break;
          if (0<Length(CUNIT_INFO_Kinds[i])) then begin
            VLine := VList[Ord(i)];
            if (0 < Length(VLine)) then begin
              VLine := CUNIT_INFO_Kinds[i] + ': ' + VLine;
              Writeln(VLine);
            end;
          end;
        end;
      finally
        VList.Free;
      end;
    end else begin
      // simple text
      if AIsWide then begin
        Writeln(SafeSetStringP(PWideChar(ABuffer)));
      end else begin
        Writeln(SafeSetStringP(PAnsiChar(ABuffer)));
      end;
    end;
  finally
    VSAGPS_FreeMem(ABuffer);
  end;
end;

procedure rTVSAGPS_SESSION_STARTED_HANDLER(const pUserPointer: Pointer;
                                           const btUnitIndex: Byte;
                                           const dwGPSDevType: DWORD;
                                           const pdwReserved: PDWORD); stdcall;
var
  VBuffer: Pointer;
  VIsWide: Boolean;
begin
  if (nil=pUserPointer) then
    Exit;
  // disconnect on timeout
  Writeln('Session started');

  // write info and protocols
  Writeln('');
  Writeln('PROTOCOLS:');
  with TGarminInfoObject(pUserPointer) do begin
    VBuffer := AllocSupportedProtocols(FUnitIndex, VIsWide);
    PrintAndKill(VBuffer, VIsWide, False);
  end;

  Writeln('');
  Writeln('DEVICEINFO:');
  with TGarminInfoObject(pUserPointer) do begin
    VBuffer := AllocDeviceInfo(FUnitIndex, VIsWide);
    PrintAndKill(VBuffer, VIsWide, False);
  end;

  Writeln('');
  Writeln('UNITINFO:');
  with TGarminInfoObject(pUserPointer) do begin
    VBuffer := AllocUnitInfo(FUnitIndex, VIsWide);
    PrintAndKill(VBuffer, VIsWide, True);
  end;
end;

function rTVSAGPS_GARMIN_D800_HANDLER(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const dwData_Size: DWORD;
                                      const pData: PD800_Pvt_Data_Type): DWORD; stdcall;
var vUTCTime: TDateTime;
begin
  Result:=0;
  if (nil=pUserPointer) then
    Exit;
  if (nil=pData) then
    Exit;

  // print packet
  Writeln('');
  Writeln('D800: size='+IntToStr(dwData_Size));
  vUTCTime:=Get_UTCDateTime_From_D800(pData);
  Writeln('UTC: '+FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',vUTCTime));
  Writeln('lat='+Round_Float64_to_String(pData^.posn.lat*180/PI, gg_FS, round_posn)+
          ', lon='+Round_Float64_to_String(pData^.posn.lon*180/PI, gg_FS, round_posn));
  Writeln('fix='+IntToStr(pData^.fix)+
          ', hdop='+Round_Float32_to_String(pData^.eph/2, gg_FS, round_hdop)+
          ', vdop='+Round_Float32_to_String(pData^.epv/2, gg_FS, round_vdop)+
          ', pdop='+Round_Float32_to_String(pData^.epe/2, gg_FS, round_pdop));
  Writeln('alt='+Round_Float32_to_String((pData^.alt+pData^.msl_hght), gg_FS, round_ele)+
          ', geoidheight='+Round_Float32_to_String(-pData^.msl_hght, gg_FS, round_ele));
  Writeln('full_speed='+Round_Float64_to_String((sqrt(pData^.east*pData^.east+pData^.north*pData^.north+pData^.up*pData^.up)*3.6), gg_FS, round_hspeed)+
          ' km/h, v_speed='+Round_Float32_to_String(pData^.up, gg_FS, round_vspeed)+
          ' m/s, heading='+Round_Float64_to_String((ArcTan2(pData^.north,pData^.east)*180/PI), gg_FS, round_heading));

  // check exit
  TGarminInfoObject(pUserPointer).CheckPVTCounter;
end;

function rTVSAGPS_GARMIN_MEAS_HANDLER(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const dwData_Size: DWORD;
                                      const pData: Pcpo_all_sat_data): DWORD; stdcall;
var i: Byte;
begin
  Result:=0;
  if (nil=pUserPointer) then
    Exit;
  if (nil=pData) then
    Exit;

  // print packet
  Writeln('');
  Writeln('MEAS: size='+IntToStr(dwData_Size));

  for I := 0 to cpo_all_sat_data_count-1 do begin
    Writeln('svid='+IntToStrW(pData^.sv[i].svid,3)+
            ', snr='+IntToStrW(pData^.sv[i].snr,5)+
            ', elev='+IntToStrW(pData^.sv[i].elev,3)+
            ', azmth='+IntToStrW(pData^.sv[i].azmth,4)+
            ', binary_status='+ByteToBinW(pData^.sv[i].status,8));
  end;
end;

procedure rTVSAGPS_GPSStateChanged_DLL_Proc(const pUserPointer: Pointer;
                                            const btUnitIndex: Byte;
                                            const dwGPSDevType: DWORD;
                                            const eNewState: Tvsagps_GPSState); stdcall;
begin
  if (nil=pUserPointer) then
    Exit;
  if (cUnitIndex_ALL<>btUnitIndex) then
    Exit;
  TGarminInfoObject(pUserPointer).FStateFromEvent:=eNewState;
  Writeln(STtoString(eNewState));
end;

procedure rTVSAGPS_GPSTimeout_DLL_Proc(const pUserPointer: Pointer;
                                       const btUnitIndex: Byte;
                                       const dwGPSDevType: DWORD;
                                       const pdwReserved: PDWORD); stdcall;
begin
  if (nil=pUserPointer) then
    Exit;
  // disconnect on timeout
  Writeln('Timeout');
  TGarminInfoObject(pUserPointer).GPSDisconnect;
end;

{ TGarminInfoObject }

procedure TGarminInfoObject.CheckPVTCounter;
begin
  Inc(FPVT_Counter);
  if (FPVT_Counter>=maxPVT_Counter) then
    GPSDisconnect;
end;

var
  obj: TGarminInfoObject;
  
begin
  VSAGPS_PrepareFormatSettings(gg_FS);
  Writeln('Starting');
  try
    obj:=TGarminInfoObject.Create;
    try
      // initialize
      obj.ALLDeviceUserPointer:=obj;
      obj.OnGPSStateChanged:=rTVSAGPS_GPSStateChanged_DLL_Proc;
      obj.OnGPSTimeout:=rTVSAGPS_GPSTimeout_DLL_Proc;
      obj.FPVT_Counter:=0;
      obj.FUnitIndex:=0;
      obj.FStateFromEvent:=gs_DoneDisconnected;

      ZeroMemory(@(obj.FDevParams), sizeof(obj.FDevParams));

      obj.FDevParams.wSize:=sizeof(obj.FDevParams);
      obj.FDevParams.btAutodetectOnConnect:=0;
      obj.FDevParams.btReceiveGPSTimeoutSec:=10;
      obj.FDevParams.wConnectionTimeoutSec:=10;
      obj.FDevParams.wWorkerThreadTimeoutMSec:=100;
      obj.FDevParams.dwAutodetectFlags:=0;
      obj.FDevParams.dwDeviceFlagsIn:=(dpdfi_SyncUnitInfo or // for VSAGPS_GetUnitInfo
                                       dpdfi_UnSyncDisconnected or
                                       dpdfi_ConnectingFromConnect);
      obj.FDevParams.dwDeviceFlagsOut:=0;
      obj.FDevParams.iBaudRate:=0;
      obj.FDevParams.pSessionStartedHandler:=rTVSAGPS_SESSION_STARTED_HANDLER;
      obj.FDevParams.pGARMIN_D800_HANDLER:=rTVSAGPS_GARMIN_D800_HANDLER;
      obj.FDevParams.pGARMIN_MEAS_HANDLER:=rTVSAGPS_GARMIN_MEAS_HANDLER;

      Writeln('Created');

      // connect
      if (not obj.GPSConnect(gdt_USB_Garmin,
                             '',
                             nil,
                             @(obj.FDevParams),
                             nil,
                             nil,
                             @(obj.FUnitIndex),
                             nil)) then begin
        // not connected
        raise Exception.Create('NOT CONNECTED');
      end;

      try
        // wait disconnected
        obj.WaitForALLState([gs_DoneDisconnected], nil);
      finally
        obj.GPSDisconnect;
      end;

    finally
      FreeAndNil(obj);
    end;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  // show results
  Writeln('Press ENTER to close');
  Readln;
end.
