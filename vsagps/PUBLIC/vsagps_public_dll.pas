(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_dll;
(*
*)

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  vsagps_public_base,
  vsagps_public_types,
  vsagps_public_events,
  vsagps_public_unit_info,
  vsagps_public_position,
  vsagps_public_device,
  vsagps_public_tracks,
  vsagps_public_trackpoint,
  vsagps_public_version;

const
  vsagps_dll='VSAGPS.dll';

function VSAGPS_GetMem(const dwBytes: DWORD): Pointer; stdcall; external vsagps_dll;

procedure VSAGPS_FreeMem(p: Pointer); stdcall; external vsagps_dll;

function VSAGPS_Create(const AUserPointer: Pointer;
                       const AGPSStateProc: TVSAGPS_GPSStateChanged_DLL_Proc;
                       const AGPSTimeoutProc: TVSAGPS_GPSTimeout_DLL_Proc
                       ): TVSAGPS_HANDLE; stdcall; external vsagps_dll;

procedure VSAGPS_Destroy(AVSAGPS_HANDLE: TVSAGPS_HANDLE); stdcall; external vsagps_dll;

function VSAGPS_Connect(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                        const AGPSDevType: DWORD;
                        const AGPSDevName: PAnsiChar;
                        const AFileSource: PWideChar;
                        const AALLDevParams: PVSAGPS_ALL_DEVICE_PARAMS;
                        const ANewDevParams: PVSAGPS_SINGLE_DEVICE_PARAMS;
                        const AUNIT_INFO_Changed: TVSAGPS_UNIT_INFO_DLL_Proc;
                        const AUnitIndexOut: PByte;
                        const AReserved: PDWORD): LongBool; stdcall; external vsagps_dll;

function VSAGPS_Disconnect(const AVSAGPS_HANDLE: TVSAGPS_HANDLE): LongBool; stdcall; external vsagps_dll;

procedure VSAGPS_ExecuteGPSCommand_OnUnits(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                           const AMaskUnitIndex: DWORD;
                                           const ACommand: LongInt;
                                           const APointer: Pointer); stdcall; external vsagps_dll;

procedure VSAGPS_ExecuteGPSCommand_OnUnit(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                          const AUnitIndex: Byte;
                                          const ACommand: LongInt;
                                          const APointer: Pointer); stdcall; external vsagps_dll;


function VSAGPS_GPSState(const AVSAGPS_HANDLE: TVSAGPS_HANDLE): Tvsagps_GPSState; stdcall; external vsagps_dll;

function VSAGPS_SerializePacket(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                const AUnitIndex: Byte;
                                const APacket: Pointer;
                                const AReserved: PDWORD): PAnsiChar; stdcall; external vsagps_dll; // result must be deallocated using VSAGPS_FreeMem

function VSAGPS_AutodetectCOM(const ADevFlags: DWORD;
                              const AUserPointer: Pointer;
                              const AConnectTimeoutSec: DWORD;
                              const AForKeepFirstOpenedHandle: LongBool;
                              const APendingProc: TCOMAutodetect_DLL_Proc;
                              const AFinishedProc: TCOMAutodetect_DLL_Proc;
                              const ABufferReadProc: TCOMCheckerRead_DLL_Proc): SmallInt; stdcall; external vsagps_dll;

function VSAGPS_GetSupportedProtocols(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                      const AUnitIndex: Byte;
                                      const AReserved: PDWORD): PAnsiChar; stdcall; external vsagps_dll; // result must be deallocated using VSAGPS_FreeMem

function VSAGPS_GetDeviceInfo(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                              const AUnitIndex: Byte;
                              const AReserved: PDWORD): PAnsiChar; stdcall; external vsagps_dll; // result must be deallocated using VSAGPS_FreeMem

function VSAGPS_GetUnitInfo(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                            const AUnitIndex: Byte;
                            const AReserved: PDWORD): PAnsiChar; stdcall; external vsagps_dll; // result must be deallocated using VSAGPS_FreeMem

function VSAGPS_Check_Version(const p: PVSAGPS_VERSION): LongBool; stdcall; external vsagps_dll;

function VSAGPS_SendPacket_ToUnit(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                  const AUnitIndex: Byte;
                                  const APacketBuffer: Pointer;
                                  const APacketSize: DWORD;
                                  const AFlags: DWORD;
                                  const AReserved: PDWORD): LongBool; stdcall; external vsagps_dll;

function VSAGPS_GetDeviceStatus(const AVSAGPS_HANDLE: TVSAGPS_HANDLE;
                                const AUnitIndex: Byte;
                                const AGPSDevTypePtr: PDWORD;
                                const AStatePtr: Pvsagps_GPSState): LongBool; stdcall; external vsagps_dll;

// track logger
function VSAGPS_MakeLogger(const AUserPointer: Pointer;
                           const AVSAGPS_LOG_WRITER_PARAMS: PVSAGPS_LOG_WRITER_PARAMS;
                           const AVSAGPS_GPX_WRITER_PARAMS: PVSAGPS_GPX_WRITER_PARAMS;
                           const ALogPath: PWideChar;
                           const AVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC: TVSAGPS_LOGGER_GETVALUES_CALLBACK_PROC;
                           const AVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER: PVSAGPS_LOGGER_GETVALUES_CALLBACK_FILTER): TVSAGPS_HANDLE; stdcall; external vsagps_dll;

function VSAGPS_StartLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                            const ATrackTypes: DWORD;
                            const ASuspended: LongBool;
                            const pReserved: Pointer): LongBool; stdcall; external vsagps_dll;

function VSAGPS_ActiveLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE): LongBool; stdcall; external vsagps_dll;

function VSAGPS_CloseLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE): LongBool; stdcall; external vsagps_dll;

function VSAGPS_AddLoggerTrackPoint(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                    const pATP: Pvsagps_AddTrackPoint): LongBool; stdcall; external vsagps_dll;

function VSAGPS_AddLoggerWayPoint(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                  const pATP: Pvsagps_AddTrackPoint): LongBool; stdcall; external vsagps_dll;

function VSAGPS_AddLoggerPacket(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                const ABuffer: PAnsiChar;
                                const ABufferLen: DWORD;
                                const pReserved: PDWORD): LongBool; stdcall; external vsagps_dll;

function VSAGPS_ExecuteLoggerCommand(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                     const AUnitIndex: Byte;
                                     const ACommand: LongInt;
                                     const APointer: Pointer): LongBool; stdcall; external vsagps_dll;

function VSAGPS_SetPausedLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE;
                                const APaused: LongBool): LongBool; stdcall; external vsagps_dll;

function VSAGPS_RestartLogger(const AVSAGPS_LOGGER: TVSAGPS_HANDLE): LongBool; stdcall; external vsagps_dll;

// not imported

function VSAGPS_AllocPCharByString(const s: AnsiString; const aNILforEmpty: Boolean): PAnsiChar;

procedure VSAGPS_FreeAndNil_PChar(var p: PAnsiChar);

implementation

function VSAGPS_AllocPCharByString(const s: AnsiString; const aNILforEmpty: Boolean): PAnsiChar;
var d: Integer;
begin
  Result:=nil;
  d:=Length(s);

  if aNILforEmpty and (0=d) then
    Exit;

  Result:=VSAGPS_GetMem(d+1);
  if (0<d) then
    CopyMemory(Result, PAnsiChar(s), d);
  Result[d]:=#0;
end;

procedure VSAGPS_FreeAndNil_PChar(var p: PAnsiChar);
begin
  if (nil<>p) then begin
    VSAGPS_FreeMem(p);
    p:=nil;
  end;
end;

end.