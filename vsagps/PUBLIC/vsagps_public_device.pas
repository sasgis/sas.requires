(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_device;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_tracks,
  vsagps_public_position;
  
type
  // called when session is started successfully
  TVSAGPS_SESSION_STARTED_HANDLER = procedure (const pUserPointer: Pointer;
                                               const btUnitIndex: Byte;
                                               const dwGPSDevType: DWORD;
                                               const pdwReserved: PDWORD); stdcall;

  // to handle raw packets (should return zero!!!)
  TVSAGPS_LOWLEVEL_PACKET_HANDLER = function(const pUserPointer: Pointer;
                                             const btUnitIndex: Byte;
                                             const dwDeviceType: DWORD;
                                             const pPacket: Pointer): DWORD; stdcall;
                                    
  // usb garmin abstract handler (for dwPacketType see vgpt_ constants)
  TVSAGPS_GARMIN_ABSTRACT_HANDLER = function(const pUserPointer: Pointer;
                                             const btUnitIndex: Byte;
                                             const dwPacketType: DWORD;
                                             const dwData_Size: DWORD;
                                             const pData: Pointer): DWORD; stdcall;
  // usb garmin D800 (PVT) handler
  TVSAGPS_GARMIN_D800_HANDLER = function(const pUserPointer: Pointer;
                                         const btUnitIndex: Byte;
                                         const dwPacketType: DWORD;
                                         const dwData_Size: DWORD;
                                         const pData: PD800_Pvt_Data_Type): DWORD; stdcall;
  // usb garmin measurements handler
  TVSAGPS_GARMIN_MEAS_HANDLER = function(const pUserPointer: Pointer;
                                         const btUnitIndex: Byte;
                                         const dwPacketType: DWORD;
                                         const dwData_Size: DWORD;
                                         const pData: Pcpo_all_sat_data): DWORD; stdcall;
  // nmea abstract handler
  TVSAGPS_NMEA_ABSTRACT_HANDLER = function(const pUserPointer: Pointer;
                                           const btUnitIndex: Byte;
                                           const dwPacketType: DWORD;
                                           const pNmeaData: Pointer): DWORD; stdcall;
  // nmea Echo Sounder handler
  TVSAGPS_ECHOSOUNDER_HANDLER = function(const pUserPointer: Pointer;
                                         const btUnitIndex: Byte;
                                         const dwPacketType: DWORD;
                                         const pSD: PVSAGPS_ECHOSOUNDER_DATA): DWORD; stdcall;

  // nmea GGA handler
  TVSAGPS_NMEA_GGA_HANDLER = function(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const pNmeaData: PNMEA_GGA): DWORD; stdcall;
  // nmea GLL handler
  TVSAGPS_NMEA_GLL_HANDLER = function(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const pNmeaData: PNMEA_GLL): DWORD; stdcall;
  // nmea GSA handler
  TVSAGPS_NMEA_GSA_HANDLER = function(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const pNmeaData: PNMEA_GSA): DWORD; stdcall;
  // nmea GSV handler
  TVSAGPS_NMEA_GSV_HANDLER = function(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const pNmeaData: PNMEA_GSV): DWORD; stdcall;
  // nmea RMC handler
  TVSAGPS_NMEA_RMC_HANDLER = function(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const pNmeaData: PNMEA_RMC): DWORD; stdcall;
{$if defined(USE_NMEA_VTG)}
  // nmea VTG handler
  TVSAGPS_NMEA_VTG_HANDLER = function(const pUserPointer: Pointer;
                                      const btUnitIndex: Byte;
                                      const dwPacketType: DWORD;
                                      const pNmeaData: PNMEA_VTG): DWORD; stdcall;
{$ifend}

  TVSAGPS_TRACKPOINT_HANDLER = function(const pUserPointer: Pointer;
                                        const btUnitIndex: Byte;
                                        const dwDeviceType: DWORD;
                                        const dwPacketType: DWORD;
                                        const pPacket: PSingleTrackPointData): DWORD; stdcall;

  // params for connecting to gps device and transmitting data to user
  TVSAGPS_SINGLE_DEVICE_PARAMS = packed record
    pUserPointer: Pointer;
    iBaudRate: Integer; // -1 - not set
    wWorkerThreadTimeoutMSec: Word; // timeout for worker thread
    wConnectionTimeoutSec: Word; // timeout for connection (in sec)
    btReceiveGPSTimeoutSec: Byte; // timeout for data receiving (in sec)
  end;
  PVSAGPS_SINGLE_DEVICE_PARAMS = ^TVSAGPS_SINGLE_DEVICE_PARAMS;

  TVSAGPS_ALL_DEVICE_PARAMS = packed record
    wSize: SmallInt;
    btAutodetectOnConnect: Byte; // autodetect params
    btReceiveGPSTimeoutSec: Byte; // timeout for data receiving (in sec)
    wConnectionTimeoutSec: Word; // timeout for connection (in sec)
    wWorkerThreadTimeoutMSec: Word; // timeout for worker thread
    dwAutodetectFlags: DWORD;
    dwSourceFileFlagsIn: DWORD; // see dpsffi_* constants
    dwSourceFileFlagsOut: DWORD;
    dwDeviceFlagsIn: DWORD; // see dpdfi_* constants
    dwDeviceFlagsOut: DWORD; // Reserved - must be 0
    iBaudRate: LongInt;
    // handler for start session
    pSessionStartedHandler: TVSAGPS_SESSION_STARTED_HANDLER;
    // low-level packet handler (all gps types) - NIL by default
    pLowLevelHandler: TVSAGPS_LOWLEVEL_PACKET_HANDLER;
    // trackpoint handler (all types) - NIL by default
    pTrackPointHandler: TVSAGPS_TRACKPOINT_HANDLER;
    // location API handler
    pLocationApi_Handler: TVSAGPS_NMEA_ABSTRACT_HANDLER;
    // handlers for garmin packets
    pGARMIN_D800_HANDLER: TVSAGPS_GARMIN_D800_HANDLER; // D800 aka PVT
    pGARMIN_MEAS_HANDLER: TVSAGPS_GARMIN_MEAS_HANDLER; // Measurements
    // handler for echo sounder
    pECHOSOUNDER_HANDLER: TVSAGPS_ECHOSOUNDER_HANDLER;
    // handlers for nmea packets
    pNMEA_GGA_HANDLER: TVSAGPS_NMEA_GGA_HANDLER; // GGA sentences
    pNMEA_GLL_HANDLER: TVSAGPS_NMEA_GLL_HANDLER; // GLL sentences
    pNMEA_GSA_HANDLER: TVSAGPS_NMEA_GSA_HANDLER; // GSA sentences
    pNMEA_GSV_HANDLER: TVSAGPS_NMEA_GSV_HANDLER; // GSV sentences
    pNMEA_RMC_HANDLER: TVSAGPS_NMEA_RMC_HANDLER; // RMC sentences
{$if defined(USE_NMEA_VTG)}
    pNMEA_VTG_HANDLER: TVSAGPS_NMEA_VTG_HANDLER; // VTG sentences
{$ifend}
  end;
  PVSAGPS_ALL_DEVICE_PARAMS = ^TVSAGPS_ALL_DEVICE_PARAMS;

  TVSAGPS_GPSStateChanged_DLL_Proc = procedure (const pUserPointer: Pointer;
                                                const btUnitIndex: Byte;
                                                const dwGPSDevType: DWORD;
                                                const eNewState: Tvsagps_GPSState); stdcall;

  TVSAGPS_GPSTimeout_DLL_Proc = procedure (const pUserPointer: Pointer;
                                           const btUnitIndex: Byte;
                                           const dwGPSDevType: DWORD;
                                           const pdwReserved: PDWORD); stdcall;


function GetReceiveGPSTimeoutSec(const pALLParams: PVSAGPS_ALL_DEVICE_PARAMS;
                                 const pThisParams: PVSAGPS_SINGLE_DEVICE_PARAMS): Byte;

function vssagps_GetConnectionTimeoutSec(const p: PVSAGPS_ALL_DEVICE_PARAMS): DWORD;

function GetDeviceWorkerThreadTimeoutMSec(const pALLParams: PVSAGPS_ALL_DEVICE_PARAMS;
                                          const pThisParams: PVSAGPS_SINGLE_DEVICE_PARAMS): DWORD;

implementation

function GetReceiveGPSTimeoutSec(const pALLParams: PVSAGPS_ALL_DEVICE_PARAMS;
                                 const pThisParams: PVSAGPS_SINGLE_DEVICE_PARAMS): Byte;
begin
  if (nil<>pThisParams) and (0<pThisParams^.btReceiveGPSTimeoutSec) then
    Result:=pThisParams^.btReceiveGPSTimeoutSec
  else if (nil<>pALLParams) and (0<pALLParams^.btReceiveGPSTimeoutSec) then
    Result:=pALLParams^.btReceiveGPSTimeoutSec
  else
    Result:=cWorkingThread_Connection_Timeout_Sec;
end;

function vssagps_GetConnectionTimeoutSec(const p: PVSAGPS_ALL_DEVICE_PARAMS): DWORD;
begin
  try
    if (nil=p) then
      Result:= cWorkingThread_Connection_Timeout_Sec
    else begin
      Result:=p^.wConnectionTimeoutSec;
      if Result<cWorkingThread_Connection_Timeout_Min then
        Result:=cWorkingThread_Connection_Timeout_Min;
    end;
  except
    Result:=cWorkingThread_Connection_Timeout_Sec;
  end;
end;

function GetDeviceWorkerThreadTimeoutMSec(const pALLParams: PVSAGPS_ALL_DEVICE_PARAMS;
                                          const pThisParams: PVSAGPS_SINGLE_DEVICE_PARAMS): DWORD;
begin
  if (nil<>pThisParams) then
    Result:=pThisParams^.wWorkerThreadTimeoutMSec
  else if (nil<>pALLParams) then
    Result:=pALLParams^.wWorkerThreadTimeoutMSec
  else
    Result:=cWorkingThread_Default_Delay_Msec;
end;

end.