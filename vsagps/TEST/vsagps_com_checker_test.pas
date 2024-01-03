unit vsagps_com_checker_test;

interface

uses
  TestFramework,
  Classes,
  SysUtils,
  Forms,
  vsagps_public_base,
  vsagps_com_checker;

type
  Tvsagps_com_checker_test = class(TTestCase)
  private
    procedure OnThreadPending(Sender: TObject; AThread: TObject);
  published
    procedure GetAllComPortsList_Test;
    procedure EnumExecute_Test;
  end;

implementation

uses
  Windows;

{ Tvsagps_com_checker_test }

procedure Tvsagps_com_checker_test.OnThreadPending(Sender, AThread: TObject);
begin
  Application.ProcessMessages;
end;

procedure Tvsagps_com_checker_test.EnumExecute_Test;
const
  CKeepFirstOpenedHandle = False;
var
  VObj: TCOMCheckerObject;
  VIsCancelled: Boolean;
  VDevFlags: DWORD;
  VPort: SmallInt;
begin
  VDevFlags := cCOM_src_All;

  VObj:=TCOMCheckerObject.Create;
  try
    VObj.SetFullConnectionTimeout(30,CKeepFirstOpenedHandle);
    VObj.OnThreadPending := Self.OnThreadPending;
    VPort := VObj.EnumExecute(nil,VIsCancelled,VDevFlags,CKeepFirstOpenedHandle);
    if VPort >= 0 then begin
      OutputDebugString(PChar('Found divice on COM' + IntToStr(VPort)));
    end else begin
      OutputDebugString('No divices found!');
    end;
  finally
    VObj.Free;
  end;
end;

procedure Tvsagps_com_checker_test.GetAllComPortsList_Test;
var
  VList: TStringList;
  VDevFlags: DWORD;
begin
  VDevFlags := cCOM_src_All;

  VList:=TStringList.Create;
  try
    GetAllCOMPortsList(VList, VDevFlags);
    if VList.Count > 0 then begin
      OutputDebugString(PChar('Available ports: ' + VList.CommaText));
    end else begin
      OutputDebugString('No available ports found!');
    end;
  finally
    VList.Free;
  end;
end;

initialization
  RegisterTest(Tvsagps_com_checker_test.Suite);

end.
