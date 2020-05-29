(*
  VSAGPS Library. Copyright (C) 2013, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_location_api;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
{$IFDEF VSAGPS_USE_LOCATIONAPI_TLB}
  LocationApiLib_TLB,
{$ELSE}
  Winapi.Locationapi,
{$ENDIF}
  vsagps_public_point;

type
  Pvsagps_location_api_packet = ^Tvsagps_location_api_packet;
  Tvsagps_location_api_packet = packed record
  private
    dwSize: Word;
    FAvailable: packed array [0..13] of Boolean;
    // ILatLongReport
    FLatLong: TDoublePoint;
    FErrorRadius: Double;
    FAltitude: Double;
    FAltitudeError: Double;
    // ILocationReport
    FUTCDate: TDateTime;
    FUTCTime: TDateTime;
    // FSensorID: TGUID;
    // TODO: GetValue
  public
    procedure SetReport(const AReport: ILatLongReport);
    // helpers
    property IsPositionOK: Boolean read FAvailable[0];
    property IsHDOPOK: Boolean read FAvailable[1];
    property IsAltitudeOK: Boolean read FAvailable[2];
    property IsVDOPOK: Boolean read FAvailable[3];
    property IsUTCDateOK: Boolean read FAvailable[4];
    property IsUTCTimeOK: Boolean read FAvailable[5];
    // values
    property LatLong: TDoublePoint read FLatLong;
    property ErrorRadius: Double read FErrorRadius;
    property Altitude: Double read FAltitude;
    property AltitudeError: Double read FAltitudeError;
    property UTCDate: TDateTime read FUTCDate;
    property UTCTime: TDateTime read FUTCTime;
  end;

implementation

uses
{$IFNDEF VSAGPS_USE_LOCATIONAPI_TLB}
  Winapi.Sensors,
{$ENDIF}
  SysUtils;

{ Tvsagps_location_api_packet }

procedure Tvsagps_location_api_packet.SetReport(const AReport: ILatLongReport);
var
  VSystemTime: LocationApiLib_TLB._SYSTEMTIME;
{$IFNDEF VSAGPS_USE_LOCATIONAPI_TLB}
  // use original delphi rtl winapi modules
  //VValue: tag_inner_PROPVARIANT;
{$ENDIF}
begin
  FillChar(Self, SizeOf(Self), 0);
  dwSize := SizeOf(Self);

  with AReport do begin
    // ILatLongReport
    FAvailable[0] := Succeeded(GetLatitude(FLatLong.Y)) and
                     Succeeded(GetLongitude(FLatLong.X));
    FAvailable[1] := Succeeded(GetErrorRadius(FErrorRadius));
    FAvailable[2] := Succeeded(GetAltitude(FAltitude));
    FAvailable[3] := Succeeded(GetAltitudeError(FAltitudeError));
    // ILocationReport
    FAvailable[4] := Succeeded(GetTimestamp(VSystemTime));

{$IFNDEF VSAGPS_USE_LOCATIONAPI_TLB}
    // http://msdn.microsoft.com/en-us/library/windows/desktop/dd317624%28v=vs.85%29.aspx
    // TODO: GetValue

    // SENSOR_DATA_TYPE_ALTITUDE_SEALEVEL_METERS
    // Altitude with respect to sea level, in meters.
    // SENSOR_DATA_TYPE_ALTITUDE_ELLIPSOID_METERS
    // Altitude with respect to the reference ellipsoid, in meters.

    // Speed measured in knots.
    //if Succeeded(GetValue(SENSOR_DATA_TYPE_SPEED_KNOTS, VValue)) then begin
    //end;
{$ENDIF}

    // FAvailable[6] := Succeeded(GetSensorID(FSensorID));
  end;

  // date [4] and time [5]
  if FAvailable[4] then
  with VSystemTime do
  try
    FUTCDate := EncodeDate(wYear, wMonth, wDay);
    FUTCTime := EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
    FAvailable[5] := True;
  except
    FAvailable[4] := False;
  end;
end;

end.