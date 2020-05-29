(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_com_checker;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
{$if defined(USE_SIMPLE_CLASSES)}
  vsagps_classes,
{$else}
  Classes,
{$ifend}
  //vsagps_public_com_checker, // do not use!
  vsagps_public_base,
  vsagps_public_classes,
  vsagps_public_sysutils,
  vsagps_public_events;

const
  cCOM_read_bytes = 512; // buffer to read - 512 will be enough for any nmea sentences in second

type
  TCOMCheckerThread = class(TThread)
  private
    FCOMName: string;
    FCOMHandle: THandle;
    FCOMFinished: Boolean;
    FCOMOpened: Boolean;
    FCOMClosed: Boolean;
    FCOMReadOK: LongBool;
    FCOMKeepHandle: Boolean;
    FCOMReadCount: DWORD;
    FCOMError: DWORD;
    //FCOMTimeA: DWORD;
    //FCOMTimeB: DWORD;
    FCOMReadTimeout: DWORD;
    FCOMReadEvent: TCOMCheckerReadEvent;
  private
    procedure InternalKillThread;
    procedure InternalCloseCOM;
  protected
    procedure Execute; override;
  public
    destructor Destroy; override;
    property COMName: string read FCOMName;
  end;

  TCOMCheckerObject = class(TObject)
  private
    FCOMs: TStringList;
    FFirstOpenedHandle: THandle;
    FOnThreadFinished: TCOMCheckerThreadEvent;
    FOnThreadPending: TCOMCheckerThreadEvent;
    FOnCOMReadBuffer: TCOMCheckerReadEvent;
    FTimeout_Read_Msec: DWORD;
    FTimeout_Wait_Msec: DWORD;
    FEnumExecuting: Boolean;
    FEnumCancelling: Boolean;
    procedure ReadCOMs(const ADevFlags: DWORD);
    procedure MakeCOMs;
    procedure InternalMakeThreads(const AKeepFirstOpenedHandle: Boolean);
    procedure InternalCleanupThreads;
    procedure InternalCleanupThread(const AIndex: Integer; AThread: TCOMCheckerThread);
    procedure InternalPendingThread(AThread: TCOMCheckerThread);
    procedure InternalCloseFirstOpenedHandle;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetFullConnectionTimeout(const AConnectTimeoutSec: DWORD;
                                       const AForKeepFirstOpenedHandle: LongBool);

    // to enumerate end make outlist with names of COMx (with optional flags cCOM_src_*)
    // if AOutList=nil - just returns first COM-port found index (3 for COM3)
    // if AOutList<>nil - returns count of ports found
    // no ports - returns -1
    function EnumExecute(AFoundPorts: TStrings;
                         var ACancelled: Boolean;
                         const ADevFlags: DWORD;
                         const AKeepFirstOpenedHandle: Boolean): SmallInt;
    // to cancel enum and wait
    function EnumCancel(const AWait: Boolean): Boolean;

    // extract saved handle
    function ExtractFirstOpenedHandle: THandle;

    property EnumExecuting: Boolean read FEnumExecuting;
    property Timeout_Read_Msec: DWORD read FTimeout_Read_Msec write FTimeout_Read_Msec;
    property Timeout_Wait_Msec: DWORD read FTimeout_Wait_Msec write FTimeout_Wait_Msec;

    property OnCOMReadBuffer: TCOMCheckerReadEvent read FOnCOMReadBuffer write FOnCOMReadBuffer;
    property OnThreadFinished: TCOMCheckerThreadEvent read FOnThreadFinished write FOnThreadFinished;
    property OnThreadPending: TCOMCheckerThreadEvent read FOnThreadPending write FOnThreadPending;
  end;


// retrieve all com ports to list (with flags)
procedure GetAllCOMPortsList(AList: TStrings; const ADevFlags: DWORD);

(*
// testing routine
procedure EnumSerialPrint(const ADevFlags: DWORD);
*)

implementation

(*
procedure EnumSerialPrint(const ADevFlags: DWORD);
var
  obj: TCOMCheckerObject;
  sl: TStringList;
  ACancelled: Boolean;
begin
  obj:=TCOMCheckerObject.Create;
  sl:=TStringList.Create;
  try
    obj.SetFullConnectionTimeout(10,FALSE);
    if obj.EnumExecute(sl,ACancelled,ADevFlags,FALSE)>0 then
      Writeln(sl.Text)
    else
      Writeln('No ports found');
  finally
    obj.Free;
    sl.Free;
  end;
end;
*)

function GetCOMDeviceFlags(const ADevNameUpperCased: AnsiString): DWORD;
begin
  // common
  // \Device\BthModem0 - bluetooth ports
  // \Device\VCom17 - virtual ports
  // \Device\Serial1 - serial ports
  // \Device\USBSER001 - nokia OVI and PCSuite - common USB serial
  // auxillary
  // Winachsf0  - fax/modem ports
  // \Device\QCUSB_COM4_1 or \Device\QCUSB_COM7_2 - sprint ports

  if (0 < PosA('BTHMODEM', ADevNameUpperCased)) then
    Result:=cCOM_src_BthModem
  else if (0 < PosA('SERIAL', ADevNameUpperCased)) then
    Result:=cCOM_src_Serial
  else if (0 < PosA('VCOM', ADevNameUpperCased)) then
    Result:=cCOM_src_VCom
  //else if (0 < PosA('WINACHSF', ADevNameUpperCased)) then
    //Result:=cCOM_src_Winachsf
  //else if (0 < PosA('QCUSB_COM', ADevNameUpperCased)) then
    //Result:=cCOM_src_QCUSB_COM
  else
    Result:=cCOM_src_Others;
end;

procedure GetAllCOMPortsList(AList: TStrings; const ADevFlags: DWORD);
var
  reg: TRegistryA;
  sl_names: TStringListA;
  
  procedure InternalAddFromKey(const AKeyName: AnsiString);
  var
    sName, sValue: AnsiString;
    p: Integer;
    f: DWORD;
    i: Integer;
    VExtValue: string;
  begin
    if reg.OpenKeyReadOnly(AKeyName) then begin
      // get all names
      reg.GetValueNames(sl_names);

      // enum values
      if (0<sl_names.Count) then begin
        // copy items to port list with options
        for i := 0 to sl_names.Count - 1 do begin
          sName:=sl_names[i];
          try
            sValue:=reg.ReadString(sName);
          except
            sValue:='';
          end;

          if (0<Length(sValue)) then begin
            // port found - existing or new?
            f:=GetCOMDeviceFlags(AnsiUpperCaseA(sName));
            if (0=ADevFlags) or (0<>(f and ADevFlags)) then begin
              VExtValue := string(sValue);
              p:=AList.IndexOf(VExtValue);
              if (p<0) then begin
                // new port - add to list
                AList.AddObject(VExtValue, TObject(Pointer(DWORD(f))));
              end else begin
                // existing port - modify flag
                AList.Objects[p]:=TObject(Pointer(DWORD( DWORD(f) or DWORD(Pointer(AList.Objects[p])) )));
              end;
            end;
          end;
        end;
      end;
    end;
  end;
begin
  reg := TRegistryA.Create;
  sl_names := TStringListA.Create;
  try
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    // make com list (with flags)
    // HARDWARE\DEVICEMAP\SERIALCOMM:
    // items like "\Device\BthModem0" = "COM3" + "\Device\VCom17"="COM17" + "Winachsf0"="COM3"
    InternalAddFromKey('HARDWARE\DEVICEMAP\SERIALCOMM');
    //reg.CloseKey;
  finally
    reg.Free;
    sl_names.Free;
  end;
end;

{ TCOMCheckerThread }

destructor TCOMCheckerThread.Destroy;
begin
  InternalCloseCOM;
  inherited;
end;

procedure TCOMCheckerThread.Execute;
var
  tm: TCommTimeouts;
  dwRead: DWORD;
  dwTimeout: DWORD;
  buf: array [0..cCOM_read_bytes-1] of AnsiChar;
begin
  //inherited;
  Terminate;
  FCOMError:=0;
  FCOMReadCount:=0;
  FCOMReadOK:=FALSE;
  FCOMFinished:=FALSE;
  FCOMOpened:=FALSE;
  FCOMClosed:=FALSE;
  //FCOMTimeA:=GetTickCount;
  //FCOMTimeB:=0;

  // calc min of timeouts
  dwTimeout:=(10000); // in milliseconds
  if dwTimeout>FCOMReadTimeout then
    dwTimeout:=FCOMReadTimeout;

  FCOMHandle:=CreateFile(PChar(FCOMName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);

  if (0<>FCOMHandle) and (INVALID_HANDLE_VALUE<>FCOMHandle) then
  try
    FCOMOpened:=TRUE;

    tm.ReadIntervalTimeout:=MAXDWORD;
    tm.ReadTotalTimeoutMultiplier:=MAXDWORD;
    tm.ReadTotalTimeoutConstant:=dwTimeout;
    tm.WriteTotalTimeoutMultiplier:=MAXDWORD;
    tm.WriteTotalTimeoutConstant:=MAXDWORD;

    if SetCommTimeouts(FCOMHandle, tm) then begin
      // reading
      dwRead:=0;
      if ReadFile(FCOMHandle, buf, cCOM_read_bytes, dwRead, nil) then begin
        FCOMReadOK:=TRUE;
        FCOMReadCount:=dwRead;

        if Assigned(FCOMReadEvent) then
          FCOMReadEvent(Self, @buf, dwRead, @FCOMReadOK);
      end;
    end else begin
      // failed
      FCOMError:=GetLastError;
    end;
  finally
    if (not FCOMKeepHandle) then
      InternalCloseCOM;
  end else begin
    FCOMError:=GetLastError;
  end;
  FCOMFinished:=TRUE;
  //FCOMTimeB:=GetTickCount;
end;

procedure TCOMCheckerThread.InternalCloseCOM;
begin
  if (FCOMOpened) and (not FCOMClosed) then begin
    PurgeComm(FCOMHandle, (PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR));
    FCOMClosed:=TRUE;
    CloseHandle(FCOMHandle);
    FCOMHandle:=0;
  end;
end;

procedure TCOMCheckerThread.InternalKillThread;
begin
  if (0<>Handle) then
  try
    PDWORD(@(ThreadID))^:=0;
    TerminateThread(Handle, 0);
  finally
    CloseHandle(Handle);
    PHandle(@(Handle))^:=0;
  end;
end;

{ TCOMCheckerObject }

constructor TCOMCheckerObject.Create;
begin
  FCOMs:=nil;
  FFirstOpenedHandle:=0;
  FOnCOMReadBuffer:=nil;
  FOnThreadPending:=nil;
  FOnThreadFinished:=nil;
  FTimeout_Read_Msec:=2000;
  FTimeout_Wait_Msec:=3000;
  FEnumCancelling:=FALSE;
  FEnumExecuting:=FALSE;
end;

destructor TCOMCheckerObject.Destroy;
begin
  InternalCloseFirstOpenedHandle;
  repeat
    if (not FEnumExecuting) then
      Break;
    Sleep(0);
    if (not FEnumExecuting) then
      Break;
    Sleep(100);
  until FALSE;
  FreeAndNil(FCOMs);
  inherited;
end;

function TCOMCheckerObject.EnumCancel(const AWait: Boolean): Boolean;
begin
  if (FEnumCancelling) then
    Result:=FALSE // already
  else begin
    FEnumCancelling:=TRUE;
    Result:=TRUE;
  end;

  if AWait then
  repeat
    Sleep(0);
    if (not FEnumExecuting) then
      Break;
    Sleep(200);
  until FALSE;
end;

function TCOMCheckerObject.EnumExecute(AFoundPorts: TStrings;
                                       var ACancelled: Boolean;
                                       const ADevFlags: DWORD;
                                       const AKeepFirstOpenedHandle: Boolean): SmallInt;
  function _CheckCancelling: Boolean;
  begin
    Result:=FALSE;
    if FEnumCancelling then begin
      ACancelled:=TRUE;
      Result:=TRUE;
    end;
  end;
var
  dwTicks_Start: DWORD;
  i: SmallInt;
  t: TCOMCheckerThread;
begin
  ACancelled:=FALSE;

  if (nil<>AFoundPorts) then
    Result:=0
  else
    Result:=-1;

  if FEnumExecuting then
    Exit;

  FEnumExecuting:=TRUE;
  try
    //APortsOut.Clear; - allow to append ports into existing list
    InternalCloseFirstOpenedHandle;

    InternalPendingThread(nil);

    // read list of ports wiith flags
    ReadCOMs(ADevFlags);

    InternalPendingThread(nil);

    if _CheckCancelling then
      Exit;

    // if no ports - exit
    if (nil=FCOMs) or (0=FCOMs.Count) then
      Exit;

    try
      InternalMakeThreads(AKeepFirstOpenedHandle);

      if _CheckCancelling then
        Exit;

      dwTicks_Start:=GetTickCount;
      repeat
        // work
        i:=0;
        while (i<FCOMs.Count) do begin
          Sleep(0);

          if _CheckCancelling then
            break;

          Sleep(0);

          t:=TCOMCheckerThread(FCOMs.Objects[i]);
          if Assigned(t) then begin
            // pending
            InternalPendingThread(t);

            // check finished
            if t.FCOMFinished then begin
              // thread finished
              if t.FCOMOpened and t.FCOMReadOK and (0<t.FCOMReadCount) then begin
                // good port
                if (nil<>AFoundPorts) then begin
                  // with list
                  AFoundPorts.Append(FCOMs[i]);
                  Inc(Result);
                end else begin
                  // no list - just return first port number
                  Result:=GetCOMPortNumber(FCOMs[i]);
                  if AKeepFirstOpenedHandle then begin
                    // extract this handle for connection
                    FFirstOpenedHandle:=t.FCOMHandle;
                    t.FCOMHandle:=0;
                  end;
                  Exit;
                end;
              end else begin
                // failed
              end;

              // delete
              InternalCleanupThread(i,t);
              FCOMs.Delete(i);
            end else begin
              // still working
              if (GetTickCount>dwTicks_Start+FTimeout_Wait_Msec) then begin
                // kill
                InternalCleanupThread(i,t);
                FCOMs.Delete(i);
              end else begin
                // wait a little
                Inc(i);
              end;
            end;
          end else begin
            // empty item
            FCOMs.Delete(i);
          end;
        end;

        Sleep(100);

        // check exit
        if (0=FCOMs.Count) then
          break;
        if _CheckCancelling then
          break;
      until FALSE;
    finally
      InternalCleanupThreads;
    end;
  finally
    FEnumExecuting:=FALSE;
  end;
end;

function TCOMCheckerObject.ExtractFirstOpenedHandle: THandle;
begin
  Result:=FFirstOpenedHandle;
  FFirstOpenedHandle:=0;
end;

procedure TCOMCheckerObject.InternalCleanupThread(const AIndex: Integer; AThread: TCOMCheckerThread);
begin
  try
    // user handler
    if Assigned(FOnThreadFinished) then
    try
      FOnThreadFinished(Self, AThread);
    except
    end;

    // check
    if (nil=AThread) then
      Exit;

    Sleep(0);

    // kill
    try
      if (not AThread.FCOMFinished) then
        AThread.InternalKillThread;
    except
    end;

    Sleep(0);

    // close com handle
    try
      AThread.InternalCloseCOM;
    except
    end;

    Sleep(0);

    // free
    try
      AThread.Free;
    except
    end;
  finally
    FCOMs.Objects[AIndex]:=nil;
  end;
end;

procedure TCOMCheckerObject.InternalCleanupThreads;
var
  i: Integer;
  t: TCOMCheckerThread;
begin
  if (0<FCOMs.Count) then
  for i := 0 to FCOMs.Count - 1 do begin
    t:=TCOMCheckerThread(FCOMs.Objects[i]);
    if (Assigned(t)) then begin
      // cleanup
      InternalCleanupThread(i,t);
    end;
  end;
end;

procedure TCOMCheckerObject.InternalCloseFirstOpenedHandle;
begin
  if (0<>FFirstOpenedHandle) then begin
    CloseHandle(FFirstOpenedHandle);
    FFirstOpenedHandle:=0;
  end;
end;

procedure TCOMCheckerObject.InternalMakeThreads(const AKeepFirstOpenedHandle: Boolean);
var
  i: Integer;
  t: TCOMCheckerThread;
begin
  if (0<FCOMs.Count) then
  for i := 0 to FCOMs.Count-1 do begin
    if FEnumCancelling then
      Exit;

    //if FPrintDebug then
      //Writeln('Creating thread '+IntToStr(i));

    t:=TCOMCheckerThread.Create(TRUE);
    t.FreeOnTerminate:=FALSE;
    t.FCOMName:=cNmea_NT_COM_Prefix+FCOMs[i]+#0;
    
    t.FCOMReadTimeout:=Self.FTimeout_Read_Msec;
    t.FCOMReadEvent:=Self.FOnCOMReadBuffer;
    t.FCOMKeepHandle:=AKeepFirstOpenedHandle;

    FCOMs.Objects[i]:=t;

    //if FPrintDebug then
      //Writeln('Thread '+IntToStr(i)+' created');

    t.{$IF CompilerVersion < 23}Resume{$ELSE}Start{$IFEND};

    InternalPendingThread(t);

    //if FPrintDebug then
      //Writeln('Thread '+IntToStr(i)+' resumed');
  end;
end;

procedure TCOMCheckerObject.InternalPendingThread(AThread: TCOMCheckerThread);
begin
  if Assigned(FOnThreadPending) then
    FOnThreadPending(Self, AThread);
end;

procedure TCOMCheckerObject.MakeCOMs;
begin
  if (nil=FCOMs) then begin
    FCOMs:=TStringList.Create;
  end;
end;

procedure TCOMCheckerObject.ReadCOMs(const ADevFlags: DWORD);
begin
  // safe make container
  MakeCOMs;
  // read to container
  GetAllCOMPortsList(FCOMs, ADevFlags);
end;

procedure TCOMCheckerObject.SetFullConnectionTimeout(const AConnectTimeoutSec: DWORD;
                                                     const AForKeepFirstOpenedHandle: LongBool);
begin
  if AForKeepFirstOpenedHandle then begin
    // without reconnect - almost full time allowed for autodetect
    FTimeout_Wait_Msec := (AConnectTimeoutSec * 1000) - 500;
  end else begin;
    // with reconnect - 1/2 for autodetect and 1/2 for "read" connection
    FTimeout_Wait_Msec := (AConnectTimeoutSec * 500) - 100;
  end;

  //  read timeout should be less then full autodetect timeout
  if FTimeout_Wait_Msec > 2000 then
    FTimeout_Read_Msec := FTimeout_Wait_Msec - 1000
  else
    FTimeout_Read_Msec := 1000;
end;

end.
