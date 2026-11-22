(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_udp_checker;
(*
*)

{$I vsagps_defines.inc}

interface

uses
  Windows,
  SysUtils,
  Winsock2,
  vsagps_winsock2_compat,
  vsagps_public_sysutils;

type
  // what the probed listener looked like
  TUdpProbeResult = (
    upr_Nmea,         // bound - an nmea sentence started ($ ... in the sample)
    upr_NoData,       // bound - nothing (or a non-nmea data) within the data timeout
    upr_BindError,    // the bind or the join failed or cancelled (see LastError, Cancelled)
    upr_InvalidParams // the name can not be parsed
  );

  TUdpProbeInfo = record
    Kind: TUdpProbeResult;
    LastError: DWORD;   // 0 - no winsock error, otherwise the last error code
    Cancelled: Boolean; // True - the probe was cancelled via AOnSlice
    Sample: AnsiString; // the beginning of the received data (for the report)
  end;

  // called between the wait slices from the probe caller thread; the caller
  // may pump its message loop here; return True to cancel the probe
  TUdpProbeSliceEvent = function: Boolean of object;

// resolve, bind and check a local udp nmea listener address
// ("port", "address:port", a multicast group "group:port[@interface-ipv4]",
// any of them + ";from=ip[,ip...]") for the incoming datagrams
procedure UdpProbeExecute(const AAddressPort: string;
                          const ADataTimeout_MSec: DWORD;
                          const AOnSlice: TUdpProbeSliceEvent;
                          out AInfo: TUdpProbeInfo);

implementation

const
  // version 2.2 of the WinSock specification
  // (not taken from the winsock unit - the RTL unit does not declare it)
  cUProbe_WSA_Version_2_2 = $0202;

  // one select() slice of the data wait
  cUProbe_Slice_MSec = 250;

  // one datagram is received into this buffer (the device limit; a bigger
  // datagram is not delivered at all - WSAEMSGSIZE, see the device)
  cUProbe_ReadBuf_MaxSize = 4096;

  // the received data is collected only for the classification and the report
  cUProbe_Sample_MaxSize = 512;

  // ERROR_INVALID_PARAMETER from winerror.h (the Windows unit declares it
  // as ERROR_INVALID_PARAMETER, the short name could clash with other units)
  cUProbe_Error_Invalid_Param = 87;

  // WSAEOPNOTSUPP from winerror.h - reported for an IPv6 multicast group
  // (only the IPv4 groups are supported in this version, see the device)
  cUProbe_Error_Not_Supported = 10045;

  // IP_ADD_MEMBERSHIP from ws2ipdef.h - the current Windows SDK value (the
  // RTL Winapi.WinSock declares the obsolete 5, a real join fails with it)
  cUProbe_IP_Add_Membership = 12;

  // the sender filter list limit (";from=ip,ip,..."), the device limit
  cUProbe_AllowedSources_Max = 8;

  // AF_INET6 and the sockaddr_in6 address offset: only the recognition of
  // a multicast group (ff00::/8) is needed, the RTL types are not used
  cUProbe_AF_INET6 = 23;
  cUProbe_SockAddrIn6_AddrOffset = 8;
  cUProbe_SockAddrIn6_MinLen = 24;

type
  // ip_mreq from ws2tcpip.h - not declared in the RTL Winsock units
  Tip_mreq_probe = record
    imr_multiaddr: in_addr;
    imr_interface: in_addr;
  end;

  // the allowed sender addresses (network byte order)
  UProbeTAllowed = array [0..cUProbe_AllowedSources_Max-1] of DWORD;

{ helpers }

// the time elapsed since AStartTick (GetTickCount value); the 32-bit wrap is
// handled in Int64, so it works with the overflow/range checks turned on
function UProbe_ElapsedMSec(const AStartTick: DWORD): DWORD;
begin
  Result:=DWORD((Int64(GetTickCount)-Int64(AStartTick)) and $FFFFFFFF);
end;

// ASCII only
function UProbe_LowerA(const AStr: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result:=AStr;
  for i:=1 to Length(Result) do begin
    if (Result[i] in ['A'..'Z']) then
      Result[i]:=AnsiChar(Ord(Result[i])+32);
  end;
end;

// the first position of AChar, 0 when there is none
function UProbe_FindCharA(const AStr: AnsiString; const AChar: AnsiChar): Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=1 to Length(AStr) do begin
    if (AChar=AStr[i]) then begin
      Result:=i;
      Exit;
    end;
  end;
end;

// the last position of AChar, 0 when there is none
function UProbe_FindCharLastA(const AStr: AnsiString; const AChar: AnsiChar): Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=Length(AStr) downto 1 do begin
    if (AChar=AStr[i]) then begin
      Result:=i;
      Exit;
    end;
  end;
end;

// a strict dotted IPv4 address ("a.b.c.d", 4 decimal octets) -> network byte
// order; the same parser as in Tvsagps_device_udp_nmea (inet_addr accepts
// short, octal and hex forms and reports a bad string as the broadcast one)
function UProbe_ParseIPv4(const AStr: AnsiString; out AAddr: DWORD): Boolean;
var
  i, VOctet, VDigits, VValue: Integer;
begin
  AAddr:=0;
  VOctet:=0;
  VDigits:=0;
  VValue:=0;
  for i:=1 to Length(AStr) do begin
    if (AStr[i] in ['0'..'9']) then begin
      Inc(VDigits);
      if (3<VDigits) then begin
        Result:=FALSE;
        Exit;
      end;
      VValue:=VValue*10+Ord(AStr[i])-Ord('0');
      if (255<VValue) then begin
        Result:=FALSE;
        Exit;
      end;
    end else if ('.'=AStr[i]) then begin
      if (0=VDigits) or (3<=VOctet) then begin
        Result:=FALSE;
        Exit;
      end;
      AAddr:=AAddr or (DWORD(VValue) shl (8*VOctet));
      Inc(VOctet);
      VValue:=0;
      VDigits:=0;
    end else begin
      Result:=FALSE;
      Exit;
    end;
  end;
  // exactly 4 octets: three dots and the last octet
  Result:=(3=VOctet) and (0<VDigits);
  if Result then
    AAddr:=AAddr or (DWORD(VValue) shl 24);
end;

// "ip[,ip...]" -> the allowed sender list; any bad item rejects the whole
// list (a typo must not silently open the filter)
function UProbe_ParseSourceFilter(const AList: AnsiString;
                                  out ACount: Integer;
                                  out AAddrs: UProbeTAllowed): Boolean;
var
  i, iStart: Integer;
  sItem: AnsiString;
  VAddr: DWORD;
begin
  Result:=FALSE;
  ACount:=0;
  if (0=Length(AList)) then
    Exit;
  iStart:=1;
  for i:=1 to (Length(AList)+1) do begin
    if (i>Length(AList)) or (','=AList[i]) then begin
      sItem:=TrimA(System.Copy(AList, iStart, i-iStart));
      iStart:=i+1;
      if (not UProbe_ParseIPv4(sItem, VAddr)) or
         (cUProbe_AllowedSources_Max<=ACount) then begin
        ACount:=0;
        Exit;
      end;
      AAddrs[ACount]:=VAddr;
      Inc(ACount);
    end;
  end;
  Result:=(0<ACount);
end;

procedure UdpProbeExecute(const AAddressPort: string;
                          const ADataTimeout_MSec: DWORD;
                          const AOnSlice: TUdpProbeSliceEvent;
                          out AInfo: TUdpProbeInfo);
var
  VWSA: TWSAData;
  VWSAOk: Boolean;
  VWSAError: Integer;
  sName, sOptions, sIface, sHost, sPort: AnsiString;
  iPos: Integer;
  VHints: TAddrInfoA;
  VAddrList, VAddr: Paddrinfo;
  VSocket: TSocket;
  VSin: PSockAddrIn;
  VBindSin: TSockAddrIn;
  VMReq: Tip_mreq_probe;
  VOptName, VOptValue, VPort, VRes: Integer;
  VIsMulticast, VIsBracketed, VHasIface: Boolean;
  VIfaceAddr: DWORD;
  VAddrByte: PByte;
  VFrom: array [0..127] of Byte; // sockaddr_storage: IPv4 and IPv6 senders
  VFromLen: Integer;
  VFromAddr: DWORD;
  VAllowed: Boolean;
  VAllowedSources: UProbeTAllowed;
  VAllowedSourcesCount: Integer;
  VReadSet: TFDSet;
  VTimeout: TTimeVal;
  VSliceMSec, VElapsedMSec: DWORD;
  VDataStartTick: DWORD;
  VSelectResult, VReceived, i: Integer;
  VBuf: array [0..cUProbe_ReadBuf_MaxSize-1] of AnsiChar;

  // pump the caller between the slices and check for the cancellation
  function CheckCancel: Boolean;
  begin
    Result:=FALSE;
    if Assigned(AOnSlice) then
      Result:=AOnSlice();
    if Result then begin
      AInfo.Cancelled:=TRUE;
      AInfo.LastError:=WSAEINTR;
    end;
  end;

begin
  AInfo.Kind:=upr_BindError;
  AInfo.LastError:=0;
  AInfo.Cancelled:=FALSE;
  AInfo.Sample:='';

  VAllowedSourcesCount:=0;
  VIsBracketed:=FALSE;
  VHasIface:=FALSE;
  VIfaceAddr:=0;

  // the same parsing as in Tvsagps_device_udp_nmea

  // the optional sender filter: "<name>;from=ip[,ip...]"
  sName:=TrimA(AnsiString(Trim(AAddressPort)));
  iPos:=UProbe_FindCharA(sName, ';');
  if (0<iPos) then begin
    sOptions:=TrimA(System.Copy(sName, iPos+1, Length(sName)));
    sName:=TrimA(System.Copy(sName, 1, iPos-1));
    if (0<Length(sOptions)) then begin
      if ('from='<>System.Copy(UProbe_LowerA(sOptions), 1, 5)) or
         (not UProbe_ParseSourceFilter(System.Copy(sOptions, 6, Length(sOptions)),
                                       VAllowedSourcesCount,
                                       VAllowedSources)) then begin
        AInfo.Kind:=upr_InvalidParams;
        AInfo.LastError:=cUProbe_Error_Invalid_Param;
        Exit;
      end;
    end;
  end;

  // the optional multicast interface: "<group>:<port>@<ipv4>" (the last '@'
  // is the separator - a host name or an IPv6 literal has none)
  iPos:=UProbe_FindCharLastA(sName, '@');
  if (0<iPos) then begin
    sIface:=TrimA(System.Copy(sName, iPos+1, Length(sName)));
    sName:=TrimA(System.Copy(sName, 1, iPos-1));
    if (not UProbe_ParseIPv4(sIface, VIfaceAddr)) then begin
      AInfo.Kind:=upr_InvalidParams;
      AInfo.LastError:=cUProbe_Error_Invalid_Param;
      Exit;
    end;
    VHasIface:=TRUE;
  end;

  // the name has a "host:port" format or a bare "port" (bind the wildcard);
  // the port goes after the last colon (for IPv6 literals the host part
  // must be enclosed in square brackets)
  iPos:=Length(sName);
  while (0<iPos) and (':'<>sName[iPos]) do
    Dec(iPos);
  if (0=iPos) then begin
    // a bare port - bind the IPv4 wildcard (all interfaces)
    sHost:='0.0.0.0';
    sPort:=TrimA(sName);
  end else if (1=iPos) then begin
    // ":port" - ditto
    sHost:='0.0.0.0';
    sPort:=TrimA(System.Copy(sName, 2, Length(sName)));
  end else begin
    sHost:=TrimA(System.Copy(sName, 1, iPos-1));
    sPort:=TrimA(System.Copy(sName, iPos+1, Length(sName)));
    // allow "[::1]:10110" (with brackets) for IPv6 literals
    if (1<Length(sHost)) and ('['=sHost[1]) and (']'=sHost[Length(sHost)]) then begin
      sHost:=System.Copy(sHost, 2, Length(sHost)-2);
      VIsBracketed:=TRUE;
    end;
  end;
  if (0=Length(sHost)) or (0=Length(sPort)) then begin
    AInfo.Kind:=upr_InvalidParams;
    AInfo.LastError:=cUProbe_Error_Invalid_Param;
    Exit;
  end;
  if (not TryStrToIntA(sPort, VPort)) or (VPort<1) or (65535<VPort) then begin
    AInfo.Kind:=upr_InvalidParams;
    AInfo.LastError:=cUProbe_Error_Invalid_Param;
    Exit;
  end;

  // winsock for the probe - the reference counter of the provider allows
  // any number of nested WSAStartup/WSACleanup pairs (the device may be
  // bound while the probe runs)
  VWSAOk:=FALSE;
  try
    // WSAStartup returns the real provider error code
    VWSAError:=WSAStartup(cUProbe_WSA_Version_2_2, VWSA);
    if (0<>VWSAError) then begin
      AInfo.LastError:=DWORD(VWSAError);
      Exit;
    end;
    VWSAOk:=TRUE;

    // resolve the address: the wildcard above is resolved to itself, a
    // hostname to its addresses. IPv4 goes first for everything but a
    // bracketed literal ("localhost" resolves to ::1 before 127.0.0.1 on
    // Windows); the first resolved address is used - exactly as the device
    // does. getaddrinfo is a synchronous system call, it can not be
    // interrupted and has no timeout of its own
    ZeroMemory(@VHints, sizeof(VHints));
    if VIsBracketed then
      VHints.ai_family:=AF_UNSPEC
    else
      VHints.ai_family:=AF_INET;
    VHints.ai_socktype:=SOCK_DGRAM;
    VHints.ai_protocol:=IPPROTO_UDP;

    // the RTL getaddrinfo/freeaddrinfo signatures are used here:
    // getaddrinfo(..., const [Ref] hints: addrinfo; out res: Paddrinfo)
    // freeaddrinfo(var ai: addrinfo) - so the first list item is passed.
    // The function returns the error code itself (the EAI_ constants are
    // the WSA codes on Windows), WSAGetLastError is meaningless here
    VAddrList:=nil;
    VRes:=getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList);
    if (0<>VRes) and (not VIsBracketed) then begin
      // no IPv4 address for the name - let the resolver offer any family
      VAddrList:=nil;
      VHints.ai_family:=AF_UNSPEC;
      VRes:=getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList);
    end;
    if (0<>VRes) then begin
      AInfo.LastError:=DWORD(VRes);
      Exit;
    end;

    VSocket:=INVALID_SOCKET;
    try
      VAddr:=VAddrList;
      if (nil=VAddr) then begin
        AInfo.LastError:=cUProbe_Error_Invalid_Param;
        Exit;
      end;

      // address classes (the same as in Tvsagps_device_udp_nmea):
      // - an IPv4 class D address (224.0.0.0/4) is a multicast group - the
      //   socket is bound to the wildcard port and the group is joined below;
      // - an IPv6 multicast group (ff00::/8) is not supported in this
      //   version and is reported at once
      VIsMulticast:=FALSE;
      if (AF_INET=VAddr^.ai_family) then begin
        VSin:=PSockAddrIn(VAddr^.ai_addr);
        VIsMulticast:=($E=(ntohl(VSin^.sin_addr.S_addr) shr 28));
      end else if (cUProbe_AF_INET6=VAddr^.ai_family) then begin
        if (cUProbe_SockAddrIn6_MinLen<=VAddr^.ai_addrlen) then begin
          VAddrByte:=PByte(PAnsiChar(VAddr^.ai_addr)+cUProbe_SockAddrIn6_AddrOffset);
          if ($FF=VAddrByte^) then begin
            AInfo.LastError:=cUProbe_Error_Not_Supported;
            Exit;
          end;
        end;
      end;

      // the options which have no meaning for the resolved address are
      // errors, not something to ignore silently
      if VHasIface and (not VIsMulticast) then begin
        AInfo.Kind:=upr_InvalidParams;
        AInfo.LastError:=cUProbe_Error_Invalid_Param;
        Exit;
      end;
      if (0<VAllowedSourcesCount) and (AF_INET<>VAddr^.ai_family) then begin
        AInfo.Kind:=upr_InvalidParams;
        AInfo.LastError:=cUProbe_Error_Invalid_Param;
        Exit;
      end;

      // create the socket
      VSocket:=socket(VAddr^.ai_family, SOCK_DGRAM, IPPROTO_UDP);
      if (INVALID_SOCKET=VSocket) then begin
        AInfo.LastError:=DWORD(WSAGetLastError);
        Exit;
      end;

      // the socket options must be set before the bind - the same choice as
      // in Tvsagps_device_udp_nmea: SO_REUSEADDR for a multicast listener
      // (the port is shared with the other group listeners),
      // SO_EXCLUSIVEADDRUSE for a unicast one (an occupied port is reported
      // instead of a silent address hijacking)
      if VIsMulticast then begin
        VOptName:=SO_REUSEADDR;
        VOptValue:=1;
      end else begin
        VOptName:=Integer(SO_EXCLUSIVEADDRUSE);
        VOptValue:=1;
      end;
      if (0<>setsockopt(VSocket, SOL_SOCKET, VOptName, @VOptValue, sizeof(VOptValue))) then begin
        AInfo.LastError:=DWORD(WSAGetLastError);
        Exit;
      end;

      // bind the local address (the wildcard for the multicast)
      if VIsMulticast then begin
        ZeroMemory(@VBindSin, sizeof(VBindSin));
        VBindSin.sin_family:=AF_INET;
        VBindSin.sin_port:=PSockAddrIn(VAddr^.ai_addr)^.sin_port;
        VBindSin.sin_addr.S_addr:=INADDR_ANY;
        if (0<>bind(VSocket, PSockAddr(@VBindSin)^, sizeof(VBindSin))) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          Exit;
        end;
      end else begin
        if (0<>bind(VSocket, VAddr^.ai_addr^, Integer(VAddr^.ai_addrlen))) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          Exit;
        end;
      end;

      // join the multicast group on the requested interface (@ipv4) or on
      // the default multicast interface
      if VIsMulticast then begin
        ZeroMemory(@VMReq, sizeof(VMReq));
        VMReq.imr_multiaddr:=PSockAddrIn(VAddr^.ai_addr)^.sin_addr;
        if VHasIface then
          VMReq.imr_interface.S_addr:=VIfaceAddr
        else
          VMReq.imr_interface.S_addr:=INADDR_ANY;
        if (0<>setsockopt(VSocket, IPPROTO_IP, cUProbe_IP_Add_Membership, @VMReq, sizeof(VMReq))) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          Exit;
        end;
      end;

      // the port is bound - wait for any incoming datagram: a nmea source
      // streams at once (about 1 Hz), an empty port stays silent
      VDataStartTick:=GetTickCount;
      repeat
        VElapsedMSec:=UProbe_ElapsedMSec(VDataStartTick);
        if (VElapsedMSec>=ADataTimeout_MSec) then
          Break; // data timeout - the Sample is classified below (may be empty)

        VSliceMSec:=ADataTimeout_MSec-VElapsedMSec;
        if (VSliceMSec>cUProbe_Slice_MSec) then
          VSliceMSec:=cUProbe_Slice_MSec;

        FD_ZERO(VReadSet);
        _FD_SET(VSocket, VReadSet);
        VTimeout.tv_sec:=VSliceMSec div 1000;
        VTimeout.tv_usec:=(VSliceMSec mod 1000)*1000;

        VSelectResult:=select(0, @VReadSet, nil, nil, @VTimeout);
        if (SOCKET_ERROR=Integer(VSelectResult)) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          AInfo.Kind:=upr_BindError;
          Exit;
        end;

        if (0<VSelectResult) then begin
          // recvfrom and not recv: the sender address is needed by the filter
          VFromLen:=SizeOf(VFrom);
          VReceived:=recvfrom(VSocket, VBuf[0], sizeof(VBuf), 0, PSockAddr(@VFrom)^, VFromLen);
          if (0<VReceived) then begin
            // the sender filter - exactly as in Tvsagps_device_udp_nmea:
            // the device drops a stranger's datagram, so the probe must not
            // count it as the received data either
            VAllowed:=TRUE;
            if (0<VAllowedSourcesCount) then begin
              VAllowed:=FALSE;
              if (AF_INET=PSockAddrIn(@VFrom)^.sin_family) then begin
                VFromAddr:=PSockAddrIn(@VFrom)^.sin_addr.S_addr;
                for i:=0 to (VAllowedSourcesCount-1) do begin
                  if (VAllowedSources[i]=VFromAddr) then begin
                    VAllowed:=TRUE;
                    Break;
                  end;
                end;
              end;
            end;

            if VAllowed then begin
              AInfo.Sample:=AInfo.Sample+SafeSetStringL(PAnsiChar(@VBuf[0]), VReceived);
              if (cUProbe_Sample_MaxSize<Length(AInfo.Sample)) then
                SetLength(AInfo.Sample, cUProbe_Sample_MaxSize);
              // a started nmea sentence - enough to classify
              if (0<PosA(AnsiString('$'), AInfo.Sample)) then
                Break;
            end;
          end;
          // recv=0 is just an empty datagram here (udp has no connections),
          // a recv error is ignored - the next slice reports the real state
        end else begin
          // idle slice - the caller may pump its message loop and cancel
          if CheckCancel then begin
            AInfo.Kind:=upr_BindError;
            Exit;
          end;
        end;
      until FALSE;

      // classify the collected data
      if (0<PosA(AnsiString('$'), AInfo.Sample)) then
        AInfo.Kind:=upr_Nmea
      else
        AInfo.Kind:=upr_NoData;
    finally
      if (INVALID_SOCKET<>VSocket) then
        closesocket(VSocket);
      if Assigned(VAddrList) then
        freeaddrinfo(VAddrList^);
    end;
  finally
    if VWSAOk then
      WSACleanup;
  end;
end;

end.
