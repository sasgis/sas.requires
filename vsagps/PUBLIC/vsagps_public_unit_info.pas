(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_unit_info;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base;

type
  // information (returned by gps unit)
  TVSAGPS_UNIT_INFO_Kind = (
      guik_ClearALL, // generic item

      guik_Product_ID,
      guik_Unique_Unit_Number,
      guik_Chipset_Version,
      guik_Machine_ID, // some nonunique unit number
      guik_Database_ID, // to identify the database in certain aviation units

      guik_Firmware_Version,
      guik_Firmware_SubVersion,
      guik_Firmware_Release,
      guik_Firmware_Build,
      guik_Firmware_Name,

      guik_Software_Version,
      guik_Software_SubVersion,
      guik_Software_Release,
      guik_Software_Build,
      guik_Software_Name,

      guik_Hardware_Version,
      guik_SBAS_Version,

      guik_Model_Description_Full, // full description with version
      guik_Model_Description_Simple, // just description

      guik_Datum_Index, // index of datum in list (different for devices)
      guik_Datum_Name, // common name

      // some tests' results
      // guik_ROM_Checksum_Test,
      // guik_Receiver_Failure_Discrete,
      // guik_Stored_Data_Lost,
      // guik_Real_Time_Clock_Lost,
      // guik_0scillator_Drift_Discrete,
      // guik_Data_Collection_Discrete,
      // guik_Board_Temperature_in_Degrees_C,
      // guik_Board_Configuration_Data,

      guik_Battery_Left_in_Hours, // time left on the GPS battery in hours
      guik_PPS_Mode, // empty if disabled or unknown, frequency value if enabled
      guik_Channels, // number of channels
      guik_BaudRate, // configured value

      guik_SourceFileName,   // name of source file
      guik_DeviceDriverName // real system name of the device connected to
      );

  // for transmitting from DLL to EXE
  TVSAGPS_UNIT_INFO_DLL_Proc = procedure (const pUserPointer: Pointer;
                                          const btUnitIndex: Byte;
                                          const dwGPSDevType: DWORD;
                                          const eKind: TVSAGPS_UNIT_INFO_Kind;
                                          const szValue: Pointer;
                                          const AIsWide: Boolean
                                          ); stdcall;

  // container (never transmit between EXE and DLL!)
  TVSAGPS_UNIT_INFO = array [TVSAGPS_UNIT_INFO_Kind] of string;
  PVSAGPS_UNIT_INFO = ^TVSAGPS_UNIT_INFO;

procedure Clear_TVSAGPS_UNIT_INFO(p: PVSAGPS_UNIT_INFO);

function VSAGPS_Generate_GPSUnitInfo(const p: PVSAGPS_UNIT_INFO): string;

// true if parameter is used in Generate_*
function VSAGPS_ChangedFor_GPSUnitInfo(const eKind: TVSAGPS_UNIT_INFO_Kind): Boolean;

const
  CUNIT_INFO_Kinds: array [TVSAGPS_UNIT_INFO_Kind] of AnsiString = (
      '', // generic item

      'Product_ID',
      'Unique_Unit_Number',
      'Chipset_Version',
      'Machine_ID', // some nonunique unit number
      'Database_ID', // to identify the database in certain aviation units

      'Firmware_Version',
      'Firmware_SubVersion',
      'Firmware_Release',
      'Firmware_Build',
      'Firmware_Name',

      'Software_Version',
      'Software_SubVersion',
      'Software_Release',
      'Software_Build',
      'Software_Name',

      'Hardware_Version',
      'SBAS_Version',

      'Model_Description_Full', // full description with version
      'Model_Description_Simple', // just description

      'Datum_Index', // index of datum in list (different for devices)
      'Datum_Name', // common name

      // some tests' results
      // 'ROM_Checksum_Test',
      // 'Receiver_Failure_Discrete',
      // 'Stored_Data_Lost',
      // 'Real_Time_Clock_Lost',
      // '0scillator_Drift_Discrete',
      // 'Data_Collection_Discrete',
      // 'Board_Temperature_in_Degrees_C',
      // 'Board_Configuration_Data',

      'Battery_Left_in_Hours', // time left on the GPS battery in hours
      'PPS_Mode', // empty if disabled or unknown, frequency value if enabled
      'Channels', // number of channels
      'BaudRate', // configured value

      'SoureFileName', // name of source file 
      'DeviceDriverName' // real system name of the device connected to
  );

implementation

uses
  vsagps_public_sysutils;

procedure Clear_TVSAGPS_UNIT_INFO(p: PVSAGPS_UNIT_INFO);
var i: TVSAGPS_UNIT_INFO_Kind;
begin
  for i := Low(TVSAGPS_UNIT_INFO_Kind) to High(TVSAGPS_UNIT_INFO_Kind) do
    p^[i] := '';
end;

function VSAGPS_Generate_GPSUnitInfo(const p: PVSAGPS_UNIT_INFO): string;

  procedure InternalTryToAdd(const AKind: TVSAGPS_UNIT_INFO_Kind;
                             const APrefix: string='';
                             const ASuffix: string='';
                             const AMaxLen: Integer=0;
                             const ASubstOnMaxLen: string='';
                             const AKind2: TVSAGPS_UNIT_INFO_Kind=guik_ClearALL);
  var
    s: string;
    i: Integer;
  begin
    s := p^[AKind];
    i := Length(s);
    if (0=i) and (guik_ClearALL<>AKind2) then begin
      s := p^[AKind2];
      i := Length(s);
    end;
    if (0<i) then begin
      if (0<AMaxLen) and (AMaxLen<i) then
        s:=ASubstOnMaxLen;
      if (0<Length(Result)) then
        if (not CharInSet(Result[Length(Result)], [#32,#160])) then
          Result:=Result+#32;
      Result:=Result+APrefix+s+ASuffix;
    end;
  end;

  function MakePortInfo: string;
  begin
    Result:=p^[guik_DeviceDriverName];
    if (16<Length(Result)) then begin
      // USB connection
      Result:='USB';
    end else begin
      // COM port name like '\\.\COM31'
      if System.Pos(cNmea_NT_COM_Prefix, Result)=1 then
        System.Delete(Result, 1, Length(cNmea_NT_COM_Prefix));
    end;
    if (0<Length(Result)) then
      Result:=Result+': ';
  end;

  function MakeDeviceName: string;
  begin
    Result:=p^[guik_Model_Description_Full];
    if (0=Length(Result)) then
      Result:=p^[guik_Model_Description_Simple];
    if (0=Length(Result)) then
      Result:=p^[guik_Chipset_Version];
    if (0=Length(Result)) then
      Result:=p^[guik_Firmware_Version];
    if (0=Length(Result)) then
      Result:=p^[guik_Software_Version];
  end;

  function MakeDatum: string;
  begin
    Result:=p^[guik_Datum_Name];
    if (0=Length(Result)) then
      Result:=p^[guik_Datum_Index];
    if (0<Length(Result)) then
      Result:='; Datum:'+Result;
  end;

begin
  Result:='';
  if (nil=p) then
    Exit;

  Result:=p^[guik_SourceFileName];
  if (0<Length(Result)) then begin
    Result:='FILE: '+ExtractFileName(Result);
    Exit;
  end;

  Result:=MakePortInfo+
          MakeDeviceName+
          MakeDatum;
end;

function VSAGPS_ChangedFor_GPSUnitInfo(const eKind: TVSAGPS_UNIT_INFO_Kind): Boolean;
begin
  Result := (eKind in [guik_Datum_Name,
                       guik_Datum_Index,

                       guik_Model_Description_Full,
                       guik_Model_Description_Simple,
                       guik_Chipset_Version,
                       guik_Firmware_Version,
                       guik_Software_Version,

                       guik_SourceFileName,
                       
                       guik_DeviceDriverName]);
end;

end.