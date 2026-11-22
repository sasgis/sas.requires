(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_tcp_checker;
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
  // what the probed server looked like
  TTcpProbeResult = (
    tpr_Nmea,         // connected - an nmea sentence started ($ ...)
    tpr_Gpsd,         // connected - the gpsd json banner received
    tpr_NoData,       // connected - nothing classified within the data timeout
    tpr_ConnectError, // connection failed or cancelled (see LastError, Cancelled)
    tpr_InvalidParams // the "host:port" name can not be parsed
  );

  TTcpProbeInfo = record
    Kind: TTcpProbeResult;
    LastError: DWORD;   // 0 - no winsock error, otherwise the last error code
    Cancelled: Boolean; // True - the probe was cancelled via AOnSlice
    Sample: AnsiString; // the beginning of the server reply (for the report)
  end;

  // called between the wait slices from the probe caller thread; the caller
  // may pump its message loop here; return True to cancel the probe
  TTcpProbeSliceEvent = function: Boolean of object;

// resolve, connect to and classify a "host:port" nmea/gpsd server
// (the timeouts cover the whole connecting phase - all the resolved
// addresses share it - and the whole data waiting phase respectively)
procedure TcpProbeExecute(const AHostPort: string;
                          const AConnectTimeout_MSec, ADataTimeout_MSec: DWORD;
                          const AOnSlice: TTcpProbeSliceEvent;
                          out AInfo: TTcpProbeInfo);

implementation

const
  // version 2.2 of the WinSock specification
  // (not taken from the winsock unit - the RTL unit does not declare it)
  cProbe_WSA_Version_2_2 = $0202;

  // one select() slice of both the connect wait and the data wait
  cProbe_Slice_MSec = 250;

  // the minimum share of the remaining connection time which a single
  // resolved address may get: a black-holed address (e.g. an unreachable
  // IPv6) must not consume the whole budget, otherwise the IPv4 addresses
  // are never tried
  cProbe_Address_Timeout_Min_MSec = 1000;

  // gpsd announces itself with this json banner right after the connection
  // is accepted (the same string as in Tvsagps_device_tcp_nmea)
  cProbe_Gpsd_Version_Prefix = '{"class":"VERSION"';

  // the reply is collected only for the classification and the report
  cProbe_Sample_MaxSize = 512;

  // ERROR_INVALID_PARAMETER from winerror.h (the Windows unit declares it
  // as ERROR_INVALID_PARAMETER, the short name could clash with other units)
  cProbe_Error_Invalid_Param = 87;

procedure TcpProbeExecute(const AHostPort: string;
                          const AConnectTimeout_MSec, ADataTimeout_MSec: DWORD;
                          const AOnSlice: TTcpProbeSliceEvent;
                          out AInfo: TTcpProbeInfo);
var
  VWSA: TWSAData;
  VWSAOk: Boolean;
  VWSAError: Integer;
  sHost, sPort: AnsiString;
  VHints: TAddrInfoA;
  VAddrList, VAddr, VItem: Paddrinfo;
  VSocket: TSocket;
  VNonBlocking: u_long;
  VSockError, VOptLen: Integer;
  VWriteSet, VExceptSet, VReadSet: TFDSet;
  VTimeout: TTimeVal;
  VSliceMSec, VElapsedMSec, VRemainingMSec: DWORD;
  VAddressStartTick, VAddressTimeoutMSec, VAddrCount: DWORD;
  VDataStartTick: DWORD;
  VSelectResult, VReceived: Integer;
  VRes: Integer;
  VStartTick: DWORD;
  VBuf: array [0..cProbe_Sample_MaxSize-1] of AnsiChar;

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

  // the name has a "host:port" format; the port goes after the last colon
  // (for IPv6 literals the host part must be enclosed in square brackets)
  function ParseHostPort(const AName: AnsiString;
                         out AHost, APort: AnsiString): Boolean;
  var
    iPos: Integer;
  begin
    Result:=FALSE;
    iPos:=Length(AName);
    while (0<iPos) and (':'<>AName[iPos]) do
      Dec(iPos);
    if (iPos<=1) then
      Exit; // no port in the name
    AHost:=TrimA(System.Copy(AName, 1, iPos-1));
    APort:=TrimA(System.Copy(AName, iPos+1, Length(AName)));
    // allow "[::1]:10110" (with brackets) for IPv6 literals
    if (1<Length(AHost)) and ('['=AHost[1]) and (']'=AHost[Length(AHost)]) then
      AHost:=System.Copy(AHost, 2, Length(AHost)-2);
    Result:=(0<Length(AHost)) and (0<Length(APort));
  end;

begin
  AInfo.Kind:=tpr_ConnectError;
  AInfo.LastError:=0;
  AInfo.Cancelled:=FALSE;
  AInfo.Sample:='';

  if (not ParseHostPort(TrimA(AnsiString(Trim(AHostPort))), sHost, sPort)) then begin
    AInfo.Kind:=tpr_InvalidParams;
    AInfo.LastError:=cProbe_Error_Invalid_Param;
    Exit;
  end;

  // winsock for the probe - the reference counter of the provider allows
  // any number of nested WSAStartup/WSACleanup pairs (the device may be
  // connected while the probe runs)
  VWSAOk:=FALSE;
  try
    // WSAStartup returns the real provider error code
    VWSAError:=WSAStartup(cProbe_WSA_Version_2_2, VWSA);
    if (0<>VWSAError) then begin
      AInfo.LastError:=DWORD(VWSAError);
      Exit;
    end;
    VWSAOk:=TRUE;

    // resolve the host name to a list of addresses (IPv4 and IPv6, the
    // order is defined by the system resolver policy, RFC 6724) - getaddrinfo
    // is a synchronous system call, it can not be interrupted and has no
    // timeout of its own
    ZeroMemory(@VHints, sizeof(VHints));
    VHints.ai_family:=AF_UNSPEC;
    VHints.ai_socktype:=SOCK_STREAM;
    VHints.ai_protocol:=IPPROTO_TCP;

    // the RTL getaddrinfo/freeaddrinfo signatures are used here:
    // getaddrinfo(..., const [Ref] hints: addrinfo; out res: Paddrinfo)
    // freeaddrinfo(var ai: addrinfo) - so the first list item is passed.
    // The function returns the error code itself (the EAI_ constants are the
    // WSA codes on Windows), WSAGetLastError is meaningless here
    VRes:=getaddrinfo(PAnsiChar(sHost), PAnsiChar(sPort), VHints, VAddrList);
    if (0<>VRes) then begin
      AInfo.LastError:=DWORD(VRes);
      Exit;
    end;

    VSocket:=INVALID_SOCKET;
    VStartTick:=GetTickCount;
    try
      VAddr:=VAddrList;
      while (INVALID_SOCKET=VSocket) and (nil<>VAddr) do begin
        // the total connecting time is limited - check the deadline before
        // trying the next address
        VElapsedMSec:=GetTickCount-VStartTick;
        if (VElapsedMSec>=AConnectTimeout_MSec) then begin
          AInfo.LastError:=WSAETIMEDOUT;
          Exit;
        end;
        VRemainingMSec:=AConnectTimeout_MSec-VElapsedMSec;

        // every address gets its fair share of the remaining time
        VAddrCount:=0;
        VItem:=VAddr;
        while (nil<>VItem) do begin
          Inc(VAddrCount);
          VItem:=VItem^.ai_next;
        end;
        VAddressTimeoutMSec:=VRemainingMSec div VAddrCount;
        if (VAddressTimeoutMSec<cProbe_Address_Timeout_Min_MSec) then
          VAddressTimeoutMSec:=cProbe_Address_Timeout_Min_MSec;
        if (VAddressTimeoutMSec>VRemainingMSec) then
          VAddressTimeoutMSec:=VRemainingMSec;
        VAddressStartTick:=GetTickCount;

        // create the socket for this address
        VSocket:=socket(VAddr^.ai_family, SOCK_STREAM, IPPROTO_TCP);
        if (INVALID_SOCKET=VSocket) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          VAddr:=VAddr^.ai_next;
          Continue;
        end;

        // switch the socket to the non-blocking mode to be able to limit
        // the connect() call with our own timeout (the socket stays in this
        // mode for the data phase - every recv is preceded by a select)
        VNonBlocking:=1;
        if (0<>ioctlsocket(VSocket, Longint(FIONBIO), VNonBlocking)) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          closesocket(VSocket);
          VSocket:=INVALID_SOCKET;
          VAddr:=VAddr^.ai_next;
          Continue;
        end;

        // start the asynchronous connection
        if (0=Winsock2.connect(VSocket, VAddr^.ai_addr^, Integer(VAddr^.ai_addrlen))) then
          Break; // connected immediately

        VSockError:=WSAGetLastError;
        if (WSAEWOULDBLOCK<>VSockError) then begin
          // immediate connection error
          AInfo.LastError:=DWORD(VSockError);
          closesocket(VSocket);
          VSocket:=INVALID_SOCKET;
          VAddr:=VAddr^.ai_next;
          Continue;
        end;

        // wait for the connection result: on Windows a successful connection
        // is signalled through writefds and a failed one through exceptfds,
        // so both sets are waited for; the wait is split into short slices
        // to let the caller pump its message loop and cancel the probe
        VSockError:=0;
        repeat
          VElapsedMSec:=GetTickCount-VAddressStartTick;
          if (VElapsedMSec>=VAddressTimeoutMSec) then begin
            VSockError:=WSAETIMEDOUT;
            Break;
          end;
          VSliceMSec:=VAddressTimeoutMSec-VElapsedMSec;
          if (VSliceMSec>cProbe_Slice_MSec) then
            VSliceMSec:=cProbe_Slice_MSec;

          FD_ZERO(VWriteSet);
          _FD_SET(VSocket, VWriteSet);
          FD_ZERO(VExceptSet);
          _FD_SET(VSocket, VExceptSet);
          VTimeout.tv_sec:=VSliceMSec div 1000;
          VTimeout.tv_usec:=(VSliceMSec mod 1000)*1000;

          VSelectResult:=select(0, nil, @VWriteSet, @VExceptSet, @VTimeout);
          if (SOCKET_ERROR=Integer(VSelectResult)) then begin
            VSockError:=WSAGetLastError;
            Break;
          end;
          if (0<>VSelectResult) then
            Break; // connected or failed - the result is in SO_ERROR

          // no result within the slice - the caller may cancel
          if CheckCancel then begin
            VSockError:=WSAEINTR;
            Break;
          end;
        until FALSE;

        if (0=VSockError) then begin
          // check the connection result (SO_ERROR also clears the pending error)
          VOptLen:=sizeof(VSockError);
          if (0<>getsockopt(VSocket, SOL_SOCKET, SO_ERROR, @VSockError, VOptLen)) then
            VSockError:=WSAGetLastError;
        end;

        if (0<>VSockError) then begin
          // connection was not established
          AInfo.LastError:=DWORD(VSockError);
          closesocket(VSocket);
          VSocket:=INVALID_SOCKET;
          if WSAEINTR=DWORD(VSockError) then
            Exit; // cancelled by the caller
          VAddr:=VAddr^.ai_next;
          Continue;
        end;
        // connected
      end;

      if (INVALID_SOCKET=VSocket) then
        Exit; // not connected - the error is reported

      // wait for the first bytes of the reply: a regular nmea server streams
      // at once (about 1 Hz), gpsd sends its banner immediately after the
      // connection is accepted, the servers which need a query send nothing
      VDataStartTick:=GetTickCount;
      repeat
        VElapsedMSec:=GetTickCount-VDataStartTick;
        if (VElapsedMSec>=ADataTimeout_MSec) then
          Break; // data timeout - the Sample is classified below (may be empty)

        VSliceMSec:=ADataTimeout_MSec-VElapsedMSec;
        if (VSliceMSec>cProbe_Slice_MSec) then
          VSliceMSec:=cProbe_Slice_MSec;

        FD_ZERO(VReadSet);
        _FD_SET(VSocket, VReadSet);
        VTimeout.tv_sec:=VSliceMSec div 1000;
        VTimeout.tv_usec:=(VSliceMSec mod 1000)*1000;

        VSelectResult:=select(0, @VReadSet, nil, nil, @VTimeout);
        if (SOCKET_ERROR=Integer(VSelectResult)) then begin
          AInfo.LastError:=DWORD(WSAGetLastError);
          AInfo.Kind:=tpr_ConnectError;
          Exit;
        end;

        if (0<VSelectResult) then begin
          VReceived:=recv(VSocket, VBuf[0], sizeof(VBuf), 0);
          if (0<VReceived) then begin
            AInfo.Sample:=AInfo.Sample+SafeSetStringL(PAnsiChar(@VBuf[0]), VReceived);
            if (cProbe_Sample_MaxSize<Length(AInfo.Sample)) then
              SetLength(AInfo.Sample, cProbe_Sample_MaxSize);
            // a complete line or a started nmea sentence - enough to classify
            if (0<PosA(AnsiString(#10), AInfo.Sample)) or
               (0<PosA(AnsiString('$'), AInfo.Sample)) then
              Break;
          end else if (0=VReceived) then
            Break // the peer closed - nothing more will come
          else if (WSAEWOULDBLOCK<>WSAGetLastError) then begin
            AInfo.LastError:=DWORD(WSAGetLastError);
            AInfo.Kind:=tpr_ConnectError;
            Exit;
          end;
        end else begin
          // idle slice - the caller may pump its message loop and cancel
          if CheckCancel then begin
            AInfo.Kind:=tpr_ConnectError;
            Exit;
          end;
        end;
      until FALSE;

      // classify the collected reply
      if (0<PosA(cProbe_Gpsd_Version_Prefix, AInfo.Sample)) then
        AInfo.Kind:=tpr_Gpsd
      else if (0<PosA(AnsiString('$'), AInfo.Sample)) then
        AInfo.Kind:=tpr_Nmea
      else
        AInfo.Kind:=tpr_NoData;
    finally
      if (INVALID_SOCKET<>VSocket) then
        closesocket(VSocket);
      freeaddrinfo(VAddrList^);
    end;
  finally
    if VWSAOk then
      WSACleanup;
  end;
end;

end.
