(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_queue;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_classes;

type
{$if not defined(USE_SIMPLE_CLASSES)}
  Tvsagps_stdlist_item = packed record
    p: Pointer;
    u: Pointer;
  end;
  Pvsagps_stdlist_item = ^Tvsagps_stdlist_item;
{$ifend}

  // queue for packets
  Tvsagps_queue = class(TList)
  private
    FCS: TRTLCriticalSection;
    FDenyAdd: Boolean;
{$if not defined(USE_SIMPLE_CLASSES)}
    // if defined - use routine from base class
    function InternalExtractGPSPacket(var x: Pvsagps_stdlist_item): Boolean;
{$ifend}
  public
    constructor Create;
    destructor Destroy; override;
    // empty queue (before free)
    procedure FreeAllPackets;
    // insert data
    procedure AppendGPSPacket(const p: Pointer; const uindex: Byte);
    // pull data
    function ExtractGPSPacket(var p: Pointer; var uindex: Byte): Boolean;
  end;

implementation

uses
{$if not defined(USE_SIMPLE_CLASSES)}
  vsagps_public_memory,
{$ifend}
  vsagps_public_debugstring;

{ Tvsagps_queue }

procedure Tvsagps_queue.AppendGPSPacket(const p: Pointer; const uindex: Byte);
var
  dw: DWORD;
{$if not defined(USE_SIMPLE_CLASSES)}
  x: Pvsagps_stdlist_item;
{$ifend}
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_queue.AppendGPSPacket: begin');
{$ifend}

  if FDenyAdd then begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_queue.AppendGPSPacket: exit');
{$ifend}
    Exit;
  end;

  dw:=uindex;
  EnterCriticalSection(FCS);
  try
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_queue.AppendGPSPacket: add');
{$ifend}
{$if defined(USE_SIMPLE_CLASSES)}
    InternalAppendItem(p, Pointer(dw));
{$else}
    New(x);
    x^.p:=p;
    x^.u:=Pointer(dw);
    Self.Add(x);
{$ifend}
  finally
    LeaveCriticalSection(FCS);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_queue.AppendGPSPacket: end');
{$ifend}
  end;
end;

constructor Tvsagps_queue.Create;
begin
  inherited Create;
  FDenyAdd:=FALSE;
  InitializeCriticalSection(FCS);
end;

destructor Tvsagps_queue.Destroy;
begin
  FDenyAdd:=TRUE;
  FreeAllPackets;
  DeleteCriticalSection(FCS);
  inherited;
end;

function Tvsagps_queue.ExtractGPSPacket(var p: Pointer; var uindex: Byte): Boolean;
var
{$if defined(USE_SIMPLE_CLASSES)}
  u: Pointer;
{$else}
  x: Pvsagps_stdlist_item;
{$ifend}
begin
{$if defined(VSAGPS_USE_DEBUG_STRING)}
  VSAGPS_DebugAnsiString('Tvsagps_queue.ExtractGPSPacket: begin');
{$ifend}

  Result:=FALSE;
  p:=nil;
  if (nil=Self) then
    Exit;

  EnterCriticalSection(FCS);
  try
{$if defined(USE_SIMPLE_CLASSES)}
    Result:=InternalExtractItem(p, u);
    uindex:=LoByte(LoWord(DWORD(u)));
{$else}
    Result:=InternalExtractGPSPacket(x);
    if Result then begin
      p:=x^.p;
      uindex:=LoByte(LoWord(DWORD(x^.u)));
      Dispose(x);
    end;
{$ifend}
  finally
    LeaveCriticalSection(FCS);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_queue.ExtractGPSPacket: end');
{$ifend}
  end;
end;

procedure Tvsagps_queue.FreeAllPackets;
{$if not defined(USE_SIMPLE_CLASSES)}
var x: Pvsagps_stdlist_item;
{$ifend}
begin
  if (nil=Self) then
    Exit;
  EnterCriticalSection(FCS);
  try
{$if defined(USE_SIMPLE_CLASSES)}
    InternalFreeAllItems;
{$else}
    while InternalExtractGPSPacket(x) do begin
      VSAGPS_FreeMem(x^.p);
      Dispose(x);
    end;
{$ifend}
  finally
    LeaveCriticalSection(FCS);
  end;
end;

{$if not defined(USE_SIMPLE_CLASSES)}
function Tvsagps_queue.InternalExtractGPSPacket(var x: Pvsagps_stdlist_item): Boolean;
begin
  Result:=FALSE;
  if Self.Count>0 then begin
    x:=Self.Items[0];
    Self.Delete(0);
    Result:=TRUE;
  end;
end;
{$ifend}

end.