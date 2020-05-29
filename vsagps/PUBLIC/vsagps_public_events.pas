(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_events;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  vsagps_public_base,
  vsagps_public_unit_info;

type
  TExecuteGPSCommandEvent = function (Sender: TObject;
                                      const AUnitIndex: Byte;
                                      const ACommand: LongInt;
                                      const APointer: Pointer): AnsiString of object;

  TVSAGPS_UNIT_INFO_Changed_Event = procedure (Sender: TObject;
                                               const AUnitIndex: Byte;
                                               const AKind: TVSAGPS_UNIT_INFO_Kind) of object;

  TVSAGPS_GPSState_Event = procedure (Sender: TObject;
                                      const AUnitIndex: Byte;
                                      const ANewState: Tvsagps_GPSState) of object;

  TCOMCheckerThreadEvent = procedure (Sender: TObject;
                                      AThread: TObject) of object;

  TCOMAutodetect_DLL_Proc = procedure(pUserPointer: Pointer; pRezerved: Pointer); stdcall;

  TCOMCheckerReadEvent = procedure(Sender: TObject;
                                   const ABuffer: PAnsiChar;
                                   const ALength: DWORD;
                                   pBufferOK: PLongBool) of object;

  TCOMCheckerRead_DLL_Proc = procedure(pUserPointer: Pointer;
                                       const ABuffer: PAnsiChar;
                                       const ALength: DWORD;
                                       pBufferOK: PLongBool); stdcall;
                                   
implementation

end.