(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_com_checker;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  vsagps_public_base,
  vsagps_public_events,
  vsagps_public_dll;

type
  TCOMCheckerObject = class(TObject)
  private
    FConnectTimeoutSec: DWORD;
    FForKeepFirstOpenedHandle: LongBool;
    FOnThreadFinished: TCOMCheckerThreadEvent;
    FOnThreadPending: TCOMCheckerThreadEvent;
  public
    procedure SetFullConnectionTimeout(const AConnectTimeoutSec: DWORD;
                                       const AForKeepFirstOpenedHandle: LongBool);

    // AFoundPorts must be NIL and AKeepFirstOpenedHandle FALSE
    function EnumExecute(const ARezervedNIL: Pointer;
                         var ACancelled: Boolean;
                         const ADevFlags: DWORD;
                         const ARezervedFALSE: Boolean): SmallInt;

    property OnThreadFinished: TCOMCheckerThreadEvent read FOnThreadFinished write FOnThreadFinished;
    property OnThreadPending: TCOMCheckerThreadEvent read FOnThreadPending write FOnThreadPending;
  end;


implementation

procedure rOnThreadPending(pUserPointer: Pointer; pRezerved: Pointer); stdcall;
begin
  if (pUserPointer<>nil) then
    if Assigned(TCOMCheckerObject(pUserPointer).FOnThreadPending) then
      TCOMCheckerObject(pUserPointer).FOnThreadPending(pUserPointer, pRezerved);
end;

procedure rOnThreadFinished(pUserPointer: Pointer; pRezerved: Pointer); stdcall;
begin
  if (pUserPointer<>nil) then
    if Assigned(TCOMCheckerObject(pUserPointer).FOnThreadFinished) then
      TCOMCheckerObject(pUserPointer).FOnThreadFinished(pUserPointer, pRezerved);
end;

{ TCOMCheckerObject }

function TCOMCheckerObject.EnumExecute(const ARezervedNIL: Pointer;
                                       var ACancelled: Boolean;
                                       const ADevFlags: DWORD;
                                       const ARezervedFALSE: Boolean): SmallInt;
begin
  ACancelled:=FALSE;
  // check params
  if (ARezervedNIL<>nil) or (ARezervedFALSE) then begin
    Result:=-1;
    Exit;
  end;
  // call
  Result:=VSAGPS_AutodetectCOM(ADevFlags,
                               Self,
                               FConnectTimeoutSec,
                               FForKeepFirstOpenedHandle,
                               rOnThreadPending,
                               rOnThreadFinished,
                               nil);
end;

procedure TCOMCheckerObject.SetFullConnectionTimeout(const AConnectTimeoutSec: DWORD;
                                                     const AForKeepFirstOpenedHandle: LongBool);
begin
  FConnectTimeoutSec := AConnectTimeoutSec;
  FForKeepFirstOpenedHandle := AForKeepFirstOpenedHandle;
end;

end.