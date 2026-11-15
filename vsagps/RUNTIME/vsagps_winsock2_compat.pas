(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_winsock2_compat;
(*
  15.11.2026 - Added the compatibility layer for the WinSock2 addrinfo
               family. The Winapi.Winsock2 unit of the older RTL versions
               (before Delphi 11) declares no addrinfo record and no
               getaddrinfo/freeaddrinfo functions at all, while the TCP NMEA
               device and the probe rely on them. The declarations below
               repeat the newer RTL ones verbatim (the same names, the same
               layout, the same signatures, bound to the same ws2_32 exports)
               and are compiled only when the RTL lacks them
               ({DECLARED(TAddrInfoA)}), so on the newer RTL versions
               everything is still provided by Winapi.Winsock2 itself.
*)

{$I vsagps_defines.inc}

// the flag is defined here and not re-checked in the implementation: inside
// the implementation of this unit the TAddrInfoA of the interface is already
// in scope, so a second {$IF NOT DECLARED(TAddrInfoA)} is always false there
{$IF NOT DECLARED(TAddrInfoA)}
{$DEFINE VSAGPS_COMPAT_ADDRINFO}
{$IFEND}

interface

uses
  Winsock2;

{$IFDEF VSAGPS_COMPAT_ADDRINFO}
type
  // Structure used in getaddrinfo() call - the WinSock2 spec; the layout
  // matches the newer Winapi.Winsock2 declarations on both Win32 and Win64
  Paddrinfo = ^addrinfo;
  addrinfo = record
    ai_flags: Integer;       // AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST
    ai_family: Integer;      // PF_xxx
    ai_socktype: Integer;    // SOCK_xxx
    ai_protocol: Integer;    // 0 or IPPROTO_xxx for IPv4 and IPv6
    ai_addrlen: NativeUInt;  // Length of ai_addr (SIZE_T in the spec)
    ai_canonname: PAnsiChar; // Canonical name for nodename
    ai_addr: PSockAddr;      // Binary address
    ai_next: Paddrinfo;      // Next structure in linked list
  end;
  TAddrInfoA = addrinfo;

function getaddrinfo(hostname, servname: PAnsiChar; const [Ref] hints: addrinfo; out res: Paddrinfo): Integer; stdcall;
procedure freeaddrinfo(var ai: addrinfo); stdcall;
{$ENDIF}

implementation

{$IFDEF VSAGPS_COMPAT_ADDRINFO}
function getaddrinfo; external 'ws2_32.dll' name 'getaddrinfo';
procedure freeaddrinfo; external 'ws2_32.dll' name 'freeaddrinfo';
{$ENDIF}

end.
