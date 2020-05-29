(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_sats_info;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base,
  vsagps_public_sysutils,
  vsagps_public_position;

// convert satellite state info to string
function SerializeSingleSatInfo(const bsp: PSingleSatFixibilityData; const ssp: PSingleSatSkyData): AnsiString;

// make all sats state info from string
function DeserializeSatsInfo(const pInfo: PWideChar; pFTP: PFullTrackPointData): Boolean;

implementation

function SerializeSingleSatInfo(const bsp: PSingleSatFixibilityData; const ssp: PSingleSatSkyData): AnsiString;
begin
  Result := IntToHexA(Byte(bsp^.sat_info.svid),2)+
            IntToHexA(Byte(bsp^.sat_info.constellation_flag),2)+
            IntToHexA(Word(bsp^.snr),4)+
            IntToHexA(Byte(bsp^.status),2)+
            IntToHexA(Byte(bsp^.flags),2)+
            IntToHexA(Word(ssp^.elevation),4)+
            IntToHexA(Word(ssp^.azimuth),4);
end;

function DeserializeSatsInfo(const pInfo: PWideChar; pFTP: PFullTrackPointData): Boolean;
var
  cur: PWideChar;
  pfix: PVSAGPS_FIX_SATS;
  psky: PSingleSatsInfoData;
  item: WideString;
  with_comma: Boolean;

  function _FetchItem: Boolean;
  begin
    Result:=FALSE;
    item:='';
    with_comma:=FALSE;
    while (nil<>cur) do begin
      if (#0=cur^) then begin
        // end of info
        Exit;
      end else if (','=cur^) then begin
        // end of item
        Inc(cur);
        with_comma:=TRUE;
        Result:=TRUE;
        Exit;
      end else begin
        // common chars
        item:=item+cur^;
        Inc(cur);
        Result:=TRUE;
      end;
    end;
  end;

  procedure _HexToByte(const ASrc: WideString; const AStartFromPos: Byte; var AResult: Byte);
  var i: Integer;
  begin
    i:=StrToInt('0x'+System.Copy(ASrc,AStartFromPos,2));
    if (i>=0) and (i<=$FF) then
      AResult:=LOBYTE(i);
  end;

  procedure _HexToWord(const ASrc: WideString; const AStartFromPos: Byte; var AResult: Word);
  var i: Integer;
  begin
    i:=StrToInt('0x'+System.Copy(ASrc,AStartFromPos,4));
    if (i>=0) and (i<=$FFFF) then
      AResult:=LOWORD(i);
  end;

  procedure _ParseItem;
  begin
    // set current item
    _HexToByte(item,  1, Byte(pfix^.sats[pfix^.fix_count].svid));
    _HexToByte(item,  3, pfix^.sats[pfix^.fix_count].constellation_flag);
    _HexToWord(item,  5, Word(psky^.entries[pfix^.fix_count].single_fix.snr));
    _HexToByte(item,  9, psky^.entries[pfix^.fix_count].single_fix.status);
    _HexToByte(item, 11, psky^.entries[pfix^.fix_count].single_fix.flags);
    _HexToWord(item, 13, Word(psky^.entries[pfix^.fix_count].single_sky.elevation));
    _HexToWord(item, 17, Word(psky^.entries[pfix^.fix_count].single_sky.azimuth));
    psky^.entries[pfix^.fix_count].single_fix.sat_info:=pfix^.sats[pfix^.fix_count];
    // inc
    Inc(pfix^.fix_count);
    Inc(pfix^.all_count);
  end;
  
begin
  Result:=FALSE;
  pfix:=nil;
  psky:=nil;
  
  if (nil<>pInfo) then
  try
    cur:=pInfo;
    while _FetchItem do begin
      // parse
      if (not with_comma) then begin
        // last special flag
        try
          _HexToByte(item, 1, Byte(pFTP^.single_item.gps_data.DGPS.Nmea23_Mode));
        except
        end;
      end else if WideSameText(item, nmea_ti_GPS) then begin
        // switch to GPS satellites
        pfix:=@(pFTP^.fix_all.gp);
        psky:=@(pFTP^.sky_fix.gp);
      end else if WideSameText(item, nmea_ti_GLONASS) then begin
        // switch to GLONASS satellites
        pfix:=@(pFTP^.fix_all.gl);
        psky:=@(pFTP^.sky_fix.gl);
      end else begin
        // common items
        if (nil<>pfix) and (nil<>psky) then
        try
          _ParseItem;
        except
        end;
      end;
    end;
  except
    // set no data here
    pFTP^.fix_all.gp.fix_count:=0;
    pFTP^.fix_all.gl.fix_count:=0;
    // do not raise from here
  end;
end;

end.