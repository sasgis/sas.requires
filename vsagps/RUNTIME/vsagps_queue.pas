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
  Windows,
  SysUtils,
  vsagps_public_classes;

type
  Tvsagps_stdlist_item = packed record
    p: Pointer;
    u: Pointer;
  end;
  Pvsagps_stdlist_item = ^Tvsagps_stdlist_item;

  // queue for packets
  Tvsagps_queue = class(TList)
  private
    FCS: TRTLCriticalSection;
    FDenyAdd: Boolean;
    function InternalExtractGPSPacket(var x: Pvsagps_stdlist_item): Boolean;
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
  vsagps_public_memory,
  vsagps_public_debugstring;

{ Tvsagps_queue }

procedure Tvsagps_queue.AppendGPSPacket(const p: Pointer; const uindex: Byte);
var
  dw: DWORD;
  x: Pvsagps_stdlist_item;
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
    New(x);
    x^.p:=p;
    x^.u:=Pointer(dw);
    Self.Add(x);
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
  x: Pvsagps_stdlist_item;
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
    Result:=InternalExtractGPSPacket(x);
    if Result then begin
      p:=x^.p;
      uindex:=LoByte(LoWord(DWORD(x^.u)));
      Dispose(x);
    end;
  finally
    LeaveCriticalSection(FCS);
{$if defined(VSAGPS_USE_DEBUG_STRING)}
    VSAGPS_DebugAnsiString('Tvsagps_queue.ExtractGPSPacket: end');
{$ifend}
  end;
end;

procedure Tvsagps_queue.FreeAllPackets;
var x: Pvsagps_stdlist_item;
begin
  if (nil=Self) then
    Exit;
  EnterCriticalSection(FCS);
  try
    while InternalExtractGPSPacket(x) do begin
      VSAGPS_FreeMem(x^.p);
      Dispose(x);
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function Tvsagps_queue.InternalExtractGPSPacket(var x: Pvsagps_stdlist_item): Boolean;
begin
  Result:=FALSE;
  if Self.Count>0 then begin
    x:=Self.Items[0];
    Self.Delete(0);
    Result:=TRUE;
  end;
end;

end.