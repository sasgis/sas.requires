(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_kml;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_sysutils;

type
  Tvsagps_KML_main_tag = (
    // keep first
    kml_kml,
    // abc order
    kml_AddressDetails,
    kml_Alias,
    kml_BalloonStyle,
    kml_Camera,
    kml_Country,
    kml_Document,
    kml_ExtendedData,
    kml_Folder,
    kml_GroundOverlay,
    kml_gx_coord,
    kml_gx_MultiTrack,
    kml_gx_Track,
    kml_hotSpot,
    kml_Icon,
    kml_IconStyle,
    kml_ImagePyramid,
    kml_innerBoundaryIs,
    kml_LabelStyle,
    kml_LatLonAltBox,
    kml_LatLonBox,
    kml_LinearRing,
    kml_LineString,
    kml_LineStyle,
    kml_Link,
    kml_ListStyle,
    kml_Location,
    kml_Lod,
    kml_LookAt,
    kml_Model,
    kml_MultiGeometry,
    kml_NetworkLink,
    kml_NetworkLinkControl,
    kml_Orientation,
    kml_outerBoundaryIs,
    kml_Pair,
    kml_PhotoOverlay,
    kml_Placemark,
    kml_Point,
    kml_Polygon,
    kml_PolyStyle,
    kml_Region,
    kml_ResourceMap,
    kml_Response,
    kml_Scale,
    kml_Schema,
    kml_ScreenOverlay,
    kml_SimpleField,
    kml_Status,
    kml_Style,
    kml_StyleMap,
    kml_TimeSpan,
    kml_ViewVolume
  );

  Tvsagps_KML_attrib_param = (
    kml_a_p_x,
    kml_a_p_xunits,
    kml_a_p_y,
    kml_a_p_yunits
  );
  Tvsagps_KML_attrib_params = set of Tvsagps_KML_attrib_param;

  Tvsagps_KML_attrib_str = (
    kml_a_s_id,
    kml_a_s_name,
    kml_a_s_schemaUrl
  );
  Tvsagps_KML_attrib_strs = set of Tvsagps_KML_attrib_str;

  Tvsagps_KML_str = (
    kml_address,
    kml_begin, // for TimeSpan
    kml_coordinates,
    kml_description,
    kml_end, // for TimeSpan
    kml_href,
    kml_key,
    kml_name,
    kml_phoneNumber,
    kml_sourceHref,
    kml_styleUrl,
    kml_targetHref,
    kml_text
  );
  Tvsagps_KML_strs = set of Tvsagps_KML_str;

  Tvsagps_KML_param = (
    kml_altitude,
    kml_altitudeMode,
    kml_bgColor,
    //kml_bottomFov,
    kml_color,
    kml_colorMode,
    //kml_displayMode,
    //kml_east,
    kml_extrude,
    kml_fill,
    //kml_flyToView,
    //kml_gridOrigin,
    kml_heading,
    kml_latitude,
    //kml_leftFov,
    //kml_listItemType,
    kml_longitude,
    //kml_maxAltitude,
    //kml_maxFadeExtent,
    //kml_maxHeight,
    //kml_maxLodPixels,
    //kml_maxWidth,
    //kml_minAltitude,
    //kml_minFadeExtent,
    //kml_minLodPixels,
    //kml_near,
    //kml_north,
    kml_open,
    kml_outline,
    //kml_range,
    //kml_rightFov,
    //kml_roll,
    //kml_rotation,
    kml_scale_,
    //kml_south,
    kml_tessellate,
    kml_textColor,
    kml_tileSize,
    //kml_tilt,
    //kml_topFov,
    kml_visibility,
    //kml_west,
    kml_when,
    kml_width
    //kml_x,
    //kml_y,
    //kml_z
  );
  Tvsagps_KML_params = set of Tvsagps_KML_param;

  Tvsagps_KML_values = packed record
    altitude: Double;
    altitudeMode: Byte; // 0=clampToGround (default!), 1=relativeToGround, 2=absolute
    bgColor: DWORD; // ff7f1020 for BalloonStyle // for <PolyStyle><color>
    //bottomFov: Double; // for ViewVolume
    color: DWORD; // 7fff00ff
    colorMode: Byte; // 0=normal, 1=random for IconStyle,LabelStyle
    //displayMode: Byte; // 0=default, 1=hide for BalloonStyle
    //east: Double; // 15.35832653742206 for LatLonBox
    extrude: Byte; // 0 or 1
    fill: Byte; // 0 or 1
    //flyToView: Byte; // 0 or 1
    //gridOrigin: Byte; // lowerLeft for ImagePyramid
    heading: Double; // -27.70337734057933
    latitude: Double; // 40.01000594412381
    //leftFov: Double; // for ViewVolume
    //listItemType: Byte; // 0=check (default!), 1=radioFolder, 2=checkOffOnly, 3=checkHideChildren
    longitude: Double; // -105.2727379358738
    //maxAltitude: Double;
    //maxFadeExtent: DWORD;
    //maxHeight: DWORD; // for ImagePyramid
    //maxLodPixels: DWORD;
    //maxWidth: DWORD; // for ImagePyramid
    //minAltitude: Double;
    //minFadeExtent: DWORD;
    //minLodPixels: DWORD; // -1 = default value
    //near_: Double; // for ViewVolume
    //north: Double; // 37.91904192681665 for LatLonBox
    open: Byte; // 0 or 1
    outline: Byte; // 0 or 1
    //range: Double; // 127.2393107680517
    //rightFov: Double; // for ViewVolume
    //roll: Double;
    //rotation: Double; // -0.1556640799496235 for LatLonBox
    scale: Double; // 1.1  // for <IconStyle><scale> // NOT for <LabelStyle><scale> (see tileSize)
    //south: Double; // 37.46543388598137 for LatLonBox
    tessellate: Byte; // 0 or 1
    textColor: DWORD; // ff000000 for BalloonStyle // for <LabelStyle><color>
    tileSize: DWORD; // for ImagePyramid  // for <LabelStyle><scale> (double*11)
    //tilt: Double; // 65.74454495876547
    //topFov: Double; // for ViewVolume
    visibility: Byte; // 0 or 1
    //west: Double; // 14.60128369746704 for LatLonBox
    when: TDateTime; // 2007-01-01T00:00:00Z
    width: Byte; // 4
    //x: Double; // for Scale
    //y: Double; // for Scale
    //z: Double; // for Scale
  end;
  Pvsagps_KML_values = ^Tvsagps_KML_values;

  Tvsagps_KML_attributes = packed record
    x: SmallInt; // 32 for hotSpot
    xunits: Byte; // pixels,fraction,insetPixels for hotSpot
    y: SmallInt; // 1 for hotSpot
    yunits: Byte; // pixels,fraction,insetPixels for hotSpot
  end;
  Pvsagps_KML_attributes = ^Tvsagps_KML_attributes;

  Tvsagps_KML_ParserOptions = packed record
  end;
  Pvsagps_KML_ParserOptions = ^Tvsagps_KML_ParserOptions;

  Tvsagps_KML_ParserData = packed record
    // base
    fValues: Tvsagps_KML_values;
    fAttribs: Tvsagps_KML_attributes;
    fParamsStrs: array [Tvsagps_KML_str] of PWideChar;
    fAttribStrs: array [Tvsagps_KML_attrib_str] of PWideChar;
    fAvail_params: Tvsagps_KML_params;
    fAvail_strs: Tvsagps_KML_strs;
    fAvail_attrib_params: Tvsagps_KML_attrib_params;
    fAvail_attrib_strs: Tvsagps_KML_attrib_strs;
    // aux
    current_tag: Tvsagps_KML_main_tag;
    subitem_tag: Tvsagps_KML_main_tag;
  end;
  Pvsagps_KML_ParserData = ^Tvsagps_KML_ParserData;

  Tvsagps_KML_ParserState = packed record
  end;
  Pvsagps_KML_ParserState = ^Tvsagps_KML_ParserState;

  // internal buffers

  Tvsagps_KML_attrib_WideStrings = packed record
    kml_attrib_buffers: array [Tvsagps_KML_attrib_str] of WideString;
  end;
  Pvsagps_KML_attrib_WideStrings = ^Tvsagps_KML_attrib_WideStrings;

  Tvsagps_KML_params_WideStrings = packed record
    kml_params_buffers: array [Tvsagps_KML_str] of WideString;
  end;
  Pvsagps_KML_params_WideStrings = ^Tvsagps_KML_params_WideStrings;
  

const
  c_KML_main_tag: array [Tvsagps_KML_main_tag] of WideString = (
    // keep first
    'kml',
    // abc order
    'AddressDetails',
    'Alias',
    'BalloonStyle',
    'Camera',
    'Country',
    'Document',
    'ExtendedData',
    'Folder',
    'GroundOverlay',
    'gx:coord',
    'gx:MultiTrack',
    'gx:Track',
    'hotSpot',
    'Icon',
    'IconStyle',
    'ImagePyramid',
    'innerBoundaryIs',
    'LabelStyle',
    'LatLonAltBox',
    'LatLonBox',
    'LinearRing',
    'LineString',
    'LineStyle',
    'Link',
    'ListStyle',
    'Location',
    'Lod',
    'LookAt',
    'Model',
    'MultiGeometry',
    'NetworkLink',
    'NetworkLinkControl',
    'Orientation',
    'outerBoundaryIs',
    'Pair',
    'PhotoOverlay',
    'Placemark',
    'Point',
    'Polygon',
    'PolyStyle',
    'Region',
    'ResourceMap',
    'Response', // used for google geocode
    'Scale',
    'Schema',
    'ScreenOverlay',
    'SimpleField',
    'Status',
    'Style',
    'StyleMap',
    'TimeSpan',
    'ViewVolume'
  );

  c_KML_str: array [Tvsagps_KML_str] of WideString = (
    'address',
    'begin', // for TimeSpan
    'coordinates',
    'description',
    'end', // for TimeSpan
    'href',
    'key',
    'name',
    'phoneNumber',
    'sourceHref',
    'styleUrl',
    'targetHref',
    'text'
  );

function KML_get_main_tag_type(const ATagName: WideString; var t: Tvsagps_KML_main_tag): Boolean;

function KML_subtag_str_type(const ATagName: WideString; var t: Tvsagps_KML_str): Boolean;

implementation

function KML_get_main_tag_type(const ATagName: WideString; var t: Tvsagps_KML_main_tag): Boolean;
var i: Tvsagps_KML_main_tag;
begin
  for i := Low(Tvsagps_KML_main_tag) to High(Tvsagps_KML_main_tag) do
  if WideSameText(ATagName, c_KML_main_tag[i]) then begin
    if (i in [kml_Scale]) then begin
      if (ATagName = c_KML_main_tag[i]) then begin
        t := i;
        Result := True;
        Exit;
      end;
    end else begin
      t := i;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function KML_subtag_str_type(const ATagName: WideString; var t: Tvsagps_KML_str): Boolean;
var i: Tvsagps_KML_str;
begin
  for i := Low(Tvsagps_KML_str) to High(Tvsagps_KML_str) do
  if WideSameText(ATagName, c_KML_str[i]) then begin
    t:=i;
    Result:=TRUE;
    Exit;
  end;
  Result:=FALSE;
end;

end.