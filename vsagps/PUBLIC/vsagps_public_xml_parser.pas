(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_xml_parser;
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
  vsagps_public_print,
  vsagps_public_unicode,
  vsagps_public_position,
  vsagps_public_tracks,
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  vsagps_public_gpx,
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
  vsagps_public_kml,
{$ifend}
  vsagps_public_sysutils,
{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
  xmldom,
{$ifend}
  vsagps_public_xml_dom,
  Variants;

const
  cExtKML='.kml'; // import only (do not hide into defines)

type
  // source format
  Tvsagps_XML_source_format = (
    // not XML
    xsf_Unsupported, // not XML
    // predefined:
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
    xsf_GPX, // GPX
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
    xsf_KML, // KML
{$ifend}
    // all others
    xsf_XML  // any XML
    );

  // any xml
  Tvsagps_XML_str = (
    xml_nodeName,
    xml_nodeValue,
    xml_namespaceURI,
    xml_prefix,
    xml_localName
  );
  Tvsagps_XML_strs = set of Tvsagps_XML_str;

  Tvsagps_XML_ParserData_Abstract = packed record
    xml_strs: array [Tvsagps_XML_str] of PWideChar;
{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
    xml_node_type: DOMNodeType;
{$ifend}
    xml_has_child_nodes: WordBool;
  end;
  Pvsagps_XML_ParserData_Abstract = ^Tvsagps_XML_ParserData_Abstract;

  // tags call disposition
  Tvsagps_XML_tag_disposition = (xtd_Open, xtd_ReadAttributes, xtd_BeforeSub, xtd_AfterSub, xtd_Close);

  Pvsagps_XML_ParserResult = ^Tvsagps_XML_ParserResult;
  Tvsagps_XML_ParserResult = packed record
    // common
    prev_data: Pvsagps_XML_ParserResult;
    item_user_pointer: Pointer; // set by caller in callback routine - never use by parser
    recursive_level: Integer; // starting from 0 because of ZeroMemory
    // type-specific
    case Tvsagps_XML_source_format of
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
    xsf_GPX: (gpx_data: Tvsagps_GPX_ParserData);
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
    xsf_KML: (kml_data: Tvsagps_KML_ParserData);
{$ifend}
    xsf_XML: (xml_data: Tvsagps_XML_ParserData_Abstract);
  end;

  Tvsagps_XML_ParserState = packed record
    // link to source file
    wszFileName: PWideChar;
    // stream with xml
    objStream: Pointer;
    // set by user to abort
    aborted_by_user: WordBool;
    // skip parsing current tag - jump to close and call close handler
    skip_current: WordBool;
    // skip diving in specified subtag
    skip_sub: WordBool;
    // current index of root element (xml or gpx or kml tag) in xml file
    root_tag_index: DWORD;
    // type of event ( on open tag, on close tag,...)
    tag_disposition: Tvsagps_XML_tag_disposition;
    // source format
    src_fmt: Tvsagps_XML_source_format;
  end;
  Pvsagps_XML_ParserState = ^Tvsagps_XML_ParserState;

  // internal buffers for any xml
  Tvsagps_XML_params_WideStrings = record
    xml_buffers: array [Tvsagps_XML_str] of WideString;
  end;
  Pvsagps_XML_params_WideStrings = ^Tvsagps_XML_params_WideStrings;


  // all internal buffers (helpers)
  Tvsagps_XML_WideStrings = record
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
    p_gpx_trk_str: Pvsagps_GPX_trk_WideStrings;
    p_gpx_trk_ext_str: Pvsagps_GPX_trk_ext_WideStrings;
    p_gpx_wpt_str: Pvsagps_GPX_wpt_WideStrings;
    p_gpx_wpt_ext_str: Pvsagps_GPX_wpt_ext_WideStrings;
    p_gpx_ext_str: Pvsagps_GPX_ext_WideStrings;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
    p_kml_params_str: Pvsagps_KML_params_WideStrings;
    p_kml_attrib_str: Pvsagps_KML_attrib_WideStrings;
{$ifend}
    p_xml_all_str: Pvsagps_XML_params_WideStrings;
  end;
  Pvsagps_XML_WideStrings = ^Tvsagps_XML_WideStrings;

  // parser options and callbacks
  Pvsagps_XML_ParserOptions = ^Tvsagps_XML_ParserOptions;

  TVSAGPS_ParseXML_UnsupportedFileProc = procedure(const pUserObjPointer: Pointer;
                                                   const pUserAuxPointer: Pointer;
                                                   const pPX_Options: Pvsagps_XML_ParserOptions;
                                                   const pPX_state: Pvsagps_XML_ParserState); stdcall;

  Tvsagps_XML_ParserOptions = packed record
    // for both!
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
    gpx_options: Tvsagps_GPX_ParserOptions;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
    kml_options: Tvsagps_KML_ParserOptions;
{$ifend}
    pUnsupportedFileProc: TVSAGPS_ParseXML_UnsupportedFileProc;
  end;

  TVSAGPS_ParseXML_UserProc = procedure(const pUserObjPointer: Pointer;
                                        const pUserAuxPointer: Pointer;
                                        const pPX_Options: Pvsagps_XML_ParserOptions;
                                        const pPX_Result: Pvsagps_XML_ParserResult;
                                        const pPX_State: Pvsagps_XML_ParserState); stdcall;

// check supported xml filetypes
function Get_ParseXML_FileExtType(const wczSourceFilenameExt: WideString): Tvsagps_XML_source_format;
function Get_ParseXML_FileType(const wczSourceFilename: WideString): Tvsagps_XML_source_format;

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_XML_DOMNodeValue(
  const ADOMNode: IDOMNode;
  const DenyUseTextFunc: Boolean = FALSE): WideString;
{$ifend}

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_LoadAndParseXML(const pUserObjPointer: Pointer;
                                const pUserAuxPointer: Pointer;
                                const wczSourceFilename: WideString;
                                const AStream: Pointer;
                                const bInitUninit: Boolean;
                                const pPX_Options: Pvsagps_XML_ParserOptions;
                                const pPX_Func: TVSAGPS_ParseXML_UserProc;
                                const AFS: TFormatSettings): Boolean;
{$ifend}

procedure VSAGPS_KML_ShiftParam(
  const pPX_Result: Pvsagps_XML_ParserResult;
  const AParam: Tvsagps_KML_param
);

implementation

uses
{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
  Classes, // for Streams
  ActiveX,
{$ifend}
  DateUtils;

procedure VSAGPS_KML_ShiftParam(
  const pPX_Result: Pvsagps_XML_ParserResult;
  const AParam: Tvsagps_KML_param
);
var
  VPrev: Pvsagps_XML_ParserResult;
begin
  // check if available
  if (not (AParam in pPX_Result^.kml_data.fAvail_params)) then
    Exit;

  // check if has parent
  VPrev := pPX_Result^.prev_data;
  Assert(VPrev <> nil);

  // copy value and set available flag
  case AParam of
    kml_bgColor: begin
      VPrev^.kml_data.fValues.bgColor := pPX_Result^.kml_data.fValues.bgColor;
    end;
    kml_color: begin
      VPrev^.kml_data.fValues.color := pPX_Result^.kml_data.fValues.color;
    end;
    kml_fill: begin
      VPrev^.kml_data.fValues.fill := pPX_Result^.kml_data.fValues.fill;
    end;
    kml_scale_: begin
      VPrev^.kml_data.fValues.scale := pPX_Result^.kml_data.fValues.scale;
    end;
    kml_textColor: begin
      VPrev^.kml_data.fValues.textColor := pPX_Result^.kml_data.fValues.textColor;
    end;
    kml_tileSize: begin
      VPrev^.kml_data.fValues.tileSize := pPX_Result^.kml_data.fValues.tileSize;
    end;
    kml_width: begin
      VPrev^.kml_data.fValues.width := pPX_Result^.kml_data.fValues.width;
    end;
  end;
  Include(VPrev^.kml_data.fAvail_params, AParam);
end;

function VSAGPS_Parse_Fix(const src: WideString;
                          const p: PSingleDGPSData): Boolean;
begin
  if WideSameText(src,'none') then begin
    //p^.Nmea23_Mode:=#0;
    //p^.Dimentions:=0;
    Result:=TRUE;
  end else if WideSameText(src,'2d') then begin
    p^.Nmea23_Mode:='A';
    p^.Dimentions:=2;
    Result:=TRUE;
  end else if WideSameText(src,'3d') then begin
    p^.Nmea23_Mode:='A';
    p^.Dimentions:=3;
    Result:=TRUE;
  end else if WideSameText(src,'dgps') then begin
    p^.Nmea23_Mode:='D';
    p^.Dimentions:=3;
    Result:=TRUE;
  end else if WideSameText(src,'pps') then begin
    p^.Nmea23_Mode:='P';
    p^.Dimentions:=3;
    Result:=TRUE;
  end else begin
    Result:=FALSE;
  end;
end;

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_XML_DOMNodeValue(
  const ADOMNode: IDOMNode;
  const DenyUseTextFunc: Boolean = FALSE): WideString;
var
  v_child: IDOMNode;
  bOK: Boolean;
  res_val: OleVariant;
begin
  bOK:=FALSE;
  Result:='';

  // fast
  v_child:=ADOMNode.firstChild;

  if Assigned(v_child) then
  try
    res_val:=v_child.nodeValue;
    if VarIsEmpty(res_val) or VarIsNull(res_val) then
      Result:=''
    else
      Result:=res_val;
    bOK:=TRUE;
  except
  end;

  if (not bOK) and (not DenyUseTextFunc) then begin
    // slow
    Result:=ADOMNode.nodeValue;
  end;
end;
{$ifend}

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_Parse_Attrib_Double(
  const ADOMNode: IDOMNode;
  const AName: WideString;
  var dbl: Double;
  const fs: TFormatSettings
): Boolean;
var
  nm: IDOMNamedNodeMap;
  mm: IDOMNode;
  ws: WideString;
begin
  Result:=FALSE;

  nm:=ADOMNode.attributes;
  if (not Assigned(nm)) then
    Exit;
  // lat or lon
  mm:=nm.getNamedItem(AName);
  if (not Assigned(mm)) then
    Exit;
  ws:=VSAGPS_XML_DOMNodeValue(mm);

  // to double
  Result:=VSAGPS_WideString_to_Double(ws, dbl, fs);
end;
{$ifend}

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_Parse_Double(
  const ADOMNode: IDOMNode;
  var AValue: Double;
  const fs: TFormatSettings
): Boolean;
var
  VValue: WideString;
  VResult: Double;
begin
  Result := False;
  VValue := VSAGPS_XML_DOMNodeValue(ADOMNode);
  if (0 = Length(VValue)) then
    Exit;
  if VSAGPS_WideString_to_Double(VValue, VResult, fs) then begin
    Inc(Result);
    AValue := VResult;
  end;
end;

function VSAGPS_Parse_Hex_DWORD(
  const ADOMNode: IDOMNode;
  const ABuffer: PDWORD
): Boolean;
var
  VValue: WideString;
  VText: string;
  VResult: Integer;
begin
  Result := False;
  VValue := VSAGPS_XML_DOMNodeValue(ADOMNode);
  if (0 = Length(VValue)) then
    Exit;
  VText := '0x' + string(VValue);
  if TryStrToInt(VText, VResult) then begin
    Inc(Result);
    if (ABuffer <> nil) then begin
      ABuffer^ := DWORD(VResult);
    end;
  end;
end;

function VSAGPS_Parse_BYTE(
  const ADOMNode: IDOMNode;
  const ABuffer: PByte
): Boolean;
var
  VValue: WideString;
  VText: string;
  VResult: Integer;
begin
  Result := False;
  VValue := VSAGPS_XML_DOMNodeValue(ADOMNode);
  if (0 = Length(VValue)) then
    Exit;
  VText := string(VValue);
  if TryStrToInt(VText, VResult) then
  if (VResult >= 0) and (VResult <= $FF) then begin
    Inc(Result);
    if (ABuffer <> nil) then begin
      ABuffer^ := LoByte(VResult);
    end;
  end;
end;
{$ifend}

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_Parse_LabelScale(
  const ADOMNode: IDOMNode;
  const ABuffer: PDWORD;
  const fs: TFormatSettings 
): Boolean;
var
  VValue: WideString;
  VResult: Double;
begin
  Result := False;
  VValue := VSAGPS_XML_DOMNodeValue(ADOMNode);
  if (0 = Length(VValue)) then
    Exit;
  if VSAGPS_WideString_to_Double(VValue, VResult, fs) then begin
    Inc(Result);
    if (ABuffer <> nil) then begin      
      // http://www.sasgis.org/mantis/view.php?id=3779
      // TODO: return scale as absolute Double value 
      ABuffer^ := Round(VResult*11);
    end;
  end;
end;
{$ifend}

function Get_ParseXML_FileExtType(const wczSourceFilenameExt: WideString): Tvsagps_XML_source_format;
begin
  // define type by extension
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  if WideSameText(wczSourceFilenameExt, CVSAGPS_TrackTypeExt[ttGPX]) then
    Result:=xsf_GPX
  else
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
  if WideSameText(wczSourceFilenameExt, cExtKML) then
    Result:=xsf_KML
  else
{$ifend}
    Result:=xsf_Unsupported;
end;

function Get_ParseXML_FileType(const wczSourceFilename: WideString): Tvsagps_XML_source_format;
begin
  // check extension
  Result:=Get_ParseXML_FileExtType(ExtractFileExtW(wczSourceFilename));
end;

{$if defined(VSAGPS_USE_SOME_KIND_OF_XML_IMPORT)}
function VSAGPS_LoadAndParseXML(const pUserObjPointer: Pointer;
                                const pUserAuxPointer: Pointer;
                                const wczSourceFilename: WideString;
                                const AStream: Pointer;
                                const bInitUninit: Boolean;
                                const pPX_Options: Pvsagps_XML_ParserOptions;
                                const pPX_Func: TVSAGPS_ParseXML_UserProc;
                                const AFS: TFormatSettings): Boolean;
var
  res: HResult;
  bOK: Boolean;
  V_px_state: Tvsagps_XML_ParserState;

  function _CheckAborted: Boolean;
  begin
    Result:=(V_px_state.aborted_by_user<>FALSE);
  end;

  procedure _CallUser(const pPX_Data: Pvsagps_XML_ParserResult;
                      const a_tag_disp: Tvsagps_XML_tag_disposition);
  begin
    V_px_state.tag_disposition:=a_tag_disp;
    pPX_Func(pUserObjPointer, pUserAuxPointer, pPX_Options, pPX_Data, @V_px_state);
  end;

  procedure _CheckRootNodeType(const ADOMNode: IDOMNode);
  var rnn: WideString;
  begin
    if (xsf_Unsupported<>V_px_state.src_fmt) then
      Exit;
    // name of node
    rnn:=ADOMNode.nodeName;
    // aux nodes
    if Copy(rnn,1,1)='#' then
      Exit;
    // skip very root node xml ('#xmldecl')
    if WideSameText(rnn,'xml') then
      Exit;
    // switch by name
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
    if WideSameText(rnn,'gpx') then
      V_px_state.src_fmt:=xsf_GPX
    else
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
    if WideSameText(rnn,'kml') then
      V_px_state.src_fmt:=xsf_KML
    else
{$ifend}
      V_px_state.src_fmt:=xsf_XML;
  end;

  procedure _Parse_kml_when_gx_to_Value(
    const ANode: IDOMNode;
    const pData: Pvsagps_XML_ParserResult
  );
  var
    VTextValue: WideString;
  begin
    // <when>2022-02-12T06:13:07.72Z</when>
    VTextValue := VSAGPS_XML_DOMNodeValue(ANode);

    if Length(VTextValue)>0 then
    if VSAGPS_WideString_to_ISO8601_Time(VTextValue, @(pData^.kml_data.fValues.when)) then begin
      Include(pData^.kml_data.fAvail_params,kml_when);
    end;
  end;

  procedure _Parse_gx_coord_to_Values(
    const ANode: IDOMNode;
    const pData: Pvsagps_XML_ParserResult
  );
  var
    VTextValue, VLongitude, VLatitude, VAltitude: WideString;
  begin
    // <gx:coord>60.798387 56.748476 230.85376</gx:coord>
    // fetch values into longitude, latitude, and altitude fields
    VTextValue := VSAGPS_XML_DOMNodeValue(ANode);

    VLongitude := ExtractBeforeSpaceDelimiter(VTextValue);
    VLatitude := ExtractBeforeSpaceDelimiter(VTextValue);
    VAltitude := Trim(VTextValue);

    // convert
    if (Length(VLongitude)>0) and (Length(VLatitude)>0) then
    if VSAGPS_WideString_to_Double(VLongitude, pData^.kml_data.fValues.longitude, AFS) then
    if VSAGPS_WideString_to_Double(VLatitude, pData^.kml_data.fValues.latitude, AFS) then begin
      // ok - set flags
      Include(pData^.kml_data.fAvail_params,kml_latitude);
      Include(pData^.kml_data.fAvail_params,kml_longitude);

      if Length(VAltitude)>0 then
      if VSAGPS_WideString_to_Double(VAltitude, pData^.kml_data.fValues.altitude, AFS) then begin
        Include(pData^.kml_data.fAvail_params,kml_altitude);
      end;
    end;
  end;

  procedure _Parse_Attributes(
    const ANode: IDOMNode;
    const pData: Pvsagps_XML_ParserResult;
    const piWideStrings: Pvsagps_XML_WideStrings);
  begin
    case V_px_state.src_fmt of
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
      xsf_GPX: begin
        if (pData^.gpx_data.current_tag in [gpx_rtept,gpx_trkpt,gpx_wpt]) then begin
          // get lon lat for point
          if VSAGPS_Parse_Attrib_Double(ANode, 'lat', pData^.gpx_data.wpt_data.fPos.PositionLat, AFS) then
          if VSAGPS_Parse_Attrib_Double(ANode, 'lon', pData^.gpx_data.wpt_data.fPos.PositionLon, AFS) then begin
            pData^.gpx_data.wpt_data.fPos.PositionOK:=TRUE;
            Include(pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_latlon);
          end;
        end;
      end;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
      xsf_KML: begin
        // <Style id="transPurpleLineGreenPoly">
        // <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>
        // <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        // <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        // <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        // <size x="0" y="0" xunits="fraction" yunits="fraction"/>
        // <SchemaData schemaUrl="#TrailHeadTypeId">
        // <SimpleData name="TrailHeadName">Pi in the sky</SimpleData>

        if (pData^.kml_data.current_tag in [kml_gx_coord]) then begin
          _Parse_gx_coord_to_Values(ANode, pData);
        end else
        if (pData^.kml_data.current_tag in [kml_when_gx]) then begin
          _Parse_kml_when_gx_to_Value(ANode, pData);
        end;
      end;
{$ifend}
      xsf_XML: begin
        // TODO: some attributes
      end;
    end;
  end;

{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  procedure VSAGPS_ParseGPX_wpt_double(
    const AStrValue: WideString;
    var dblValue: Double;
    var ee_Params: Tvsagps_GPX_wpt_params;
    const e_Param: Tvsagps_GPX_wpt_param);
  var dbl: Double;
  begin
    if VSAGPS_WideString_To_Double(AStrValue, dbl, AFS) then begin
      dblValue:=dbl;
      Include(ee_Params, e_Param);
    end;
  end;
{$ifend}


  function _Get_CurrentTag_by_Name(
    const ADOMNode: IDOMNode;
    const pData: Pvsagps_XML_ParserResult): Boolean;
  begin
    case V_px_state.src_fmt of
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
      xsf_GPX: begin
        Result:=GPX_get_main_tag_type(ADOMNode.nodeName, pData^.gpx_data.current_tag);
      end;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
      xsf_KML: begin
        Result:=KML_get_main_tag_type(ADOMNode.nodeName, pData^.kml_data.current_tag);
      end;
{$ifend}
      xsf_XML: begin
        Result:=TRUE; // always parse ALL tags
      end;
      else begin
        Result:=FALSE;
      end;
    end;
  end;

  function _Get_SubTag_by_Name(
    const ASubDOMNode: IDOMNode;
    const pData: Pvsagps_XML_ParserResult
  ): Boolean;
  begin
    case V_px_state.src_fmt of
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
      xsf_GPX: begin
        Result:=GPX_get_main_tag_type(ASubDOMNode.nodeName, pData^.gpx_data.subitem_tag);
      end;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
      xsf_KML: begin
        Result:=KML_get_main_tag_type(ASubDOMNode.nodeName, pData^.kml_data.subitem_tag);
        if Result and (pData^.kml_data.subitem_tag = kml_when_gx) then begin
          Result := pData^.kml_data.current_tag = kml_gx_Track;
        end;
      end;
{$ifend}
      xsf_XML: begin
        Result:=TRUE; // always parse ALL tags
      end;
      else begin
        Result:=FALSE;
      end;
    end;
  end;

  procedure _Inc_Counter(const pData: Pvsagps_XML_ParserResult);
  begin
    // TODO
  end;

  procedure _Parse_GPX_metadata(const ADOMNode: IDOMNode);
  begin
    // nothing
  end;

{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  procedure _Parse_GPX_WPT_SASX(
    const AExtDOMNode: IDOMNode;
    const pExtData: Pvsagps_GPX_ext_sasx_data;
    const pParentData: Pvsagps_XML_ParserResult;
    const piWideStrings: Pvsagps_XML_WideStrings);
  var
    V_sub: IDOMNode;
    V_extName, V_extValue: WideString;
    bForPoint: Boolean;
    tt_sasx: Tvsagps_GPX_ext_sasx_str;
  begin
    if (nil=pParentData) then
      Exit;

    bForPoint:=(pParentData^.gpx_data.current_tag in [gpx_rtept,gpx_trkpt,gpx_wpt]);

    // list of subtags
    V_sub:=AExtDOMNode.firstChild;

    // for each
    while Assigned(V_sub) do begin
      // check exit
      if _CheckAborted then
        Exit;

      // get
      V_extName:=V_sub.nodeName;
      V_extValue:=VSAGPS_XML_DOMNodeValue(V_sub);

      // parse tag - switch for sasx
      if WideSameText(System.Copy(V_extName,1,5), 'sasx:') then begin
        System.Delete(V_extName,1,5);
        if WideSameText(V_extName, 'timeshift') then begin
          // sasx:timeshift
          if VSAGPS_WideString_To_Double(V_extValue, pExtData^.sasx_timeshift, AFS) then
            Include(pExtData^.fAvail_params, sasx_timeshift);
          // end of sasx:timeshift
        end else if WideSameText(V_extName, 'systemtime') then begin
          // sasx:systemtime
          if VSAGPS_WideString_to_ISO8601_Time(V_extValue, @(pExtData^.sasx_systemtime)) then
            Include(pExtData^.fAvail_params, sasx_systemtime);
          // end of sasx:systemtime
        end else if WideSameText(V_extName, 'localtime') then begin
          // sasx:localtime
          if VSAGPS_WideString_to_ISO8601_Time(V_extValue, @(pExtData^.sasx_localtime)) then
            Include(pExtData^.fAvail_params, sasx_localtime);
          // end of sasx:localtime
        end else if WideSameText(V_extName, 'course') then begin
          // sasx:course
          if bForPoint then
            VSAGPS_ParseGPX_wpt_double(V_extValue, pParentData^.gpx_data.wpt_data.fPos.Heading, pParentData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_course);
          // nothing for trk
          // end of sasx:course
        end else if WideSameText(V_extName, 'speed_kmh') then begin
          // sasx:speed_kmh
          if bForPoint then
            VSAGPS_ParseGPX_wpt_double(V_extValue, pParentData^.gpx_data.wpt_data.fPos.Speed_KMH, pParentData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_speed);
          // nothing for trk
          // end of sasx:speed_kmh
        end else if WideSameText(V_extName, 'vspeed_ms') then begin
          // sasx:vspeed_ms
          if bForPoint then begin
            VSAGPS_ParseGPX_wpt_double(V_extValue, pParentData^.gpx_data.wpt_data.fPos.VSpeed_MS, pParentData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_vspeed_ms);
            if (wpt_vspeed_ms in pParentData^.gpx_data.wpt_data.fAvail_wpt_params) then
              pParentData^.gpx_data.wpt_data.fPos.VSpeedOK:=TRUE;
          end;
          // nothing for trk
          // end of sasx:vspeed_ms
        end else if GPX_sasx_str_subtag(V_extName, tt_sasx) then begin
          // sasx:src or sasx:file_name
          if (nil=piWideStrings^.p_gpx_ext_str) then
            New(piWideStrings^.p_gpx_ext_str);
          piWideStrings^.p_gpx_ext_str^.sasx_buffers[tt_sasx]:=V_extValue;
          pExtData^.sasx_strs[tt_sasx]:=PWideChar(piWideStrings^.p_gpx_ext_str^.sasx_buffers[tt_sasx]);
          Include(pExtData^.fAvail_strs, tt_sasx);
        end;
      end;

      // next
      V_sub:=V_sub.nextSibling;
    end;
  end;
{$ifend}

{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  procedure _Parse_gpxx_TrackExtension(
    const AExtDOMNode: IDOMNode;
    const pTrkData: Pvsagps_GPX_trk_data;
    const pData: Pvsagps_XML_ParserResult;
    const piWideStrings: Pvsagps_XML_WideStrings);
  var
    V_sub: IDOMNode;
    V_extName: WideString;
    //V_extValue: WideString;
  begin
    if (nil = pData) then
      Exit;

    // list of subtags
    V_sub := AExtDOMNode.firstChild;

    // for each
    while Assigned(V_sub) do begin
      // check exit
      if _CheckAborted then
        Exit;

      // get
      V_extName := V_sub.nodeName;

      // parse tag - switch for gpxx:TrackExtension subnodes
      if WideSameText(V_extName, c_GPX_trk_ext_subtag[gpxx_DisplayColor]) then begin
        // NOTE: single tag only
        if (nil=piWideStrings^.p_gpx_trk_ext_str) then
          New(piWideStrings^.p_gpx_trk_ext_str);

        piWideStrings^.p_gpx_trk_ext_str^.trk_ext_buffers[gpxx_DisplayColor] := VSAGPS_XML_DOMNodeValue(V_sub);
        pData^.gpx_data.trk_data.fExts[gpxx_DisplayColor] := PWideChar(piWideStrings^.p_gpx_trk_ext_str^.trk_ext_buffers[gpxx_DisplayColor]);
        Include(pData^.gpx_data.trk_data.fAvail_trk_exts, gpxx_DisplayColor);
      end;

      // next
      V_sub := V_sub.nextSibling;
    end;
  end;
{$ifend}

{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
  procedure _Parse_GPX_TRK_extensions(
    const AExtDOMNode: IDOMNode;
    const pTrkData: Pvsagps_GPX_trk_data;
    const pData: Pvsagps_XML_ParserResult;
    const piWideStrings: Pvsagps_XML_WideStrings);
  var
    V_sub: IDOMNode;
    V_extName: WideString;
    //V_extValue: WideString;
  begin
    if (nil = pData) then
      Exit;

    // list of subtags
    V_sub := AExtDOMNode.firstChild;

    // for each
    while Assigned(V_sub) do begin
      // check exit
      if _CheckAborted then
        Exit;

      // get
      V_extName := V_sub.nodeName;
      //V_extValue := VSAGPS_XML_DOMNodeValue(V_sub);

      // parse tag - switch for extensions subnodes
      if WideSameText(V_extName, 'gpxx:TrackExtension') then begin
        if pPX_Options^.gpx_options.bParse_gpxx_appearance then begin
          _Parse_gpxx_TrackExtension(
            V_sub,
            pTrkData,
            pData,
            piWideStrings
          );
        end;
      end;

      // next
      V_sub := V_sub.nextSibling;
    end;
  end;
{$ifend}

  procedure _Parse_SubTag(
    const ASubNode: IDOMNode;
    const pData: Pvsagps_XML_ParserResult;
    const piWideStrings: Pvsagps_XML_WideStrings);
  var
    V_sub_Name: WideString;
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
    V_sub_Value: WideString;
    dbl: Double;
    V_gpx_trk_str: Tvsagps_GPX_trk_str;
    V_gpx_wpt_str: Tvsagps_GPX_wpt_str;
    V_gpx_wpt_param: Tvsagps_GPX_wpt_param;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
    V_kml_str: Tvsagps_KML_str;
{$ifend}
  begin
    V_sub_Name:=ASubNode.nodeName;

    case V_px_state.src_fmt of
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
      xsf_GPX: begin
        // parse gpx tags
        case pData^.gpx_data.current_tag of
        gpx_rte,gpx_trk: begin
          // headers - trk and rte here - strings only
          if GPX_trk_str_subtag(V_sub_Name, V_gpx_trk_str) then begin
            // strings
            if (nil=piWideStrings^.p_gpx_trk_str) then
              New(piWideStrings^.p_gpx_trk_str);
            piWideStrings^.p_gpx_trk_str^.trk_buffers[V_gpx_trk_str]:=VSAGPS_XML_DOMNodeValue(ASubNode);
            pData^.gpx_data.trk_data.fStrs[V_gpx_trk_str]:=PWideChar(piWideStrings^.p_gpx_trk_str^.trk_buffers[V_gpx_trk_str]);
            Include(pData^.gpx_data.trk_data.fAvail_trk_strs, V_gpx_trk_str);
          end else if WideSameText(V_sub_Name, c_extensions) then begin
            // extensions
            if pPX_Options^.gpx_options.bParse_trk_extensions then begin
              _Parse_GPX_TRK_extensions(
                ASubNode,
                @(pData^.gpx_data.trk_data),
                pData, //^.prev_data,
                piWideStrings
              );
            end;
          end else begin
            // others (params) - empty
          end;
        end;

        gpx_rtept,gpx_trkpt,gpx_wpt: begin
          // points - trkpt and rtept and wpt here
          if GPX_wpt_param_subtag(V_sub_Name, V_gpx_wpt_param) then begin
            // simple subtags and extensions
            if (wpt_extensions=V_gpx_wpt_param) then begin
              // extensions
              _Parse_GPX_WPT_SASX(ASubNode,
                                  @(pData^.gpx_data.extensions_data),
                                  // add some values to parent (for points)
                                  pData, //^.prev_data,
                                  piWideStrings);
            end else begin
              // simple tags
              V_sub_Value:=VSAGPS_XML_DOMNodeValue(ASubNode);
              case V_gpx_wpt_param of
                wpt_ele: begin
                  // ele
                  VSAGPS_ParseGPX_wpt_double(V_sub_Value, pData^.gpx_data.wpt_data.fPos.Altitude, pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_ele);
                end;
                wpt_time: begin
                  // time
                  if VSAGPS_WideString_to_ISO8601_Time(V_sub_Value, @(pData^.gpx_data.wpt_data.fPos.UTCTime)) then
                  with pData^.gpx_data.wpt_data do begin
                    // normalize
                    fPos.UTCDate:=DateOf(fPos.UTCTime);
                    fPos.UTCTime:=TimeOf(fPos.UTCTime);
                    fPos.UTCDateOK:=TRUE;
                    fPos.UTCTimeOK:=TRUE;
                    Include(fAvail_wpt_params, wpt_time);
                  end;
                end;
                wpt_magvar: begin
                  // magvar
                  with pData^.gpx_data.wpt_data do
                  if VSAGPS_WideString_To_Double(V_sub_Value, dbl, AFS) then begin
                    fPos.MagVar.variation_degree:=dbl;
                    fPos.MagVar.variation_symbol:='N';
                    Include(fAvail_wpt_params, wpt_magvar);
                  end;
                end;
                wpt_geoidheight: begin
                  // geoidheight
                  VSAGPS_ParseGPX_wpt_double(V_sub_Value, pData^.gpx_data.wpt_data.fPos.GeoidHeight, pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_geoidheight);
                end;
                wpt_fix: begin
                  // fix
                  if VSAGPS_Parse_Fix(V_sub_Value, @(pData^.gpx_data.wpt_data.fPos.DGPS)) then
                    Include(pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_fix);
                end;
                wpt_sat: begin
                  // sat
                  if VSAGPS_WideString_To_Byte(V_sub_Value, pData^.gpx_data.wpt_data.fSatFixCount) then
                    Include(pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_sat);
                end;
                wpt_hdop: begin
                  // hdop
                  VSAGPS_ParseGPX_wpt_double(V_sub_Value, pData^.gpx_data.wpt_data.fPos.HDOP, pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_hdop);
                end;
                wpt_vdop: begin
                  // vdop
                  VSAGPS_ParseGPX_wpt_double(V_sub_Value, pData^.gpx_data.wpt_data.fPos.VDOP, pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_vdop);
                end;
                wpt_pdop: begin
                  // pdop
                  VSAGPS_ParseGPX_wpt_double(V_sub_Value, pData^.gpx_data.wpt_data.fPos.PDOP, pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_pdop);
                end;
                wpt_speed: begin
                  // speed - undocumented
                  if VSAGPS_WideString_To_Double(V_sub_Value, dbl, AFS) then begin
                    pData^.gpx_data.wpt_data.fPos.Speed_KMH:=dbl*3.6;
                    Include(pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_speed);
                  end;
                end;
                wpt_course: begin
                  // course - undocumented
                  VSAGPS_ParseGPX_wpt_double(V_sub_Value, pData^.gpx_data.wpt_data.fPos.Heading, pData^.gpx_data.wpt_data.fAvail_wpt_params, wpt_course);
                end;

              end;
            end;
          end else begin
            // strings and complex tags (link)
            if GPX_wpt_str_subtag(V_sub_Name, V_gpx_wpt_str) then begin
              // strings
              if (nil=piWideStrings^.p_gpx_wpt_str) then
                New(piWideStrings^.p_gpx_wpt_str);
              V_sub_Value:=VSAGPS_XML_DOMNodeValue(ASubNode);
              piWideStrings^.p_gpx_wpt_str^.wpt_buffers[V_gpx_wpt_str]:=V_sub_Value;
              pData^.gpx_data.wpt_data.fStrs[V_gpx_wpt_str]:=PWideChar(piWideStrings^.p_gpx_wpt_str^.wpt_buffers[V_gpx_wpt_str]);
              Include(pData^.gpx_data.wpt_data.fAvail_wpt_strs, V_gpx_wpt_str);
            end else begin
              // complex tags (link)
            end;
          end;
          // end of params
        end;

        gpx_metadata: begin
          // metadata - string params
        end;
        
        gpx_link: begin
          // link - list of links
        end;

        end;
      end;
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
      xsf_KML: begin
        // parse kml tags
(*
<Folder id="FeatureLayer0">
<name>World Imagery</name>
<description><![CDATA[This map presents low-resolution imagery for the world and high-resolution imagery for the United States and other areas around the world. The map includes NASA Blue Marble: Next Generation 500m resolution imagery at small scales (above 1:1,000,000), i-cubed 15m eSAT imagery at medium-to-large scales (down to 1:70,000) for the world, and USGS 15m Landsat imagery for Antarctica.  The map features i-cubed Nationwide Prime 1m or better resolution imagery for the contiguous United States, Getmapping 1m resolution imagery for Great Britain, AeroGRID 1m to 2m resolution imagery for several countries in Europe, IGN 1m resolution imagery for Spain, IGP 1m resolution imagery for Portugal, and GeoEye IKONOS 1m resolution imagery for Hawaii, parts of Alaska, and several hundred metropolitan areas around the world.  Additionally, imagery contributed by the GIS User Community has been added in Alaska, New York and Virginia.
i-cubed Nationwide Prime is a seamless, color  mosaic of various commercial and government imagery sources, including Aerials Express 0.3 to 0.6m resolution imagery for metropolitan areas and the best  available United States Department of Agriculture (USDA) National Agriculture Imagery Program (NAIP) imagery and enhanced versions of United States Geological Survey (USGS) Digital Ortho Quarter Quad (DOQQ) imagery for other areas.
For more information on this map, visit us online at http://goto.arcgisonline.com/maps/World_Imagery]]>
</description>

<Placemark id="ID_00000">
<name>Bucharest 20000211</name>
<description><![CDATA[<html><body><table border="1"><tr><th>Field Name</th><th>Field Value</th></tr><tr><td>SRC_DATE</td><td>20000211</td></tr><tr><td>SRC_RES</td><td>1</td></tr><tr><td>SRC_ACC</td><td>25.3999996185</td></tr><tr><td>SRC_DESC</td><td>Ikonos</td></tr><tr><td>NICE_NAME</td><td>Bucharest</td></tr><tr><td>NICE_DESC</td><td>GeoEye</td></tr></table></body></html>]]>
</description>
<styleUrl>#PolyStyle00</styleUrl>


<Style>
<LineStyle>
<color>A6000080</color>
<width>2</width>
</LineStyle>
<PolyStyle>
<color>33FFFFFF</color>
<fill>1</fill>
</PolyStyle>
</Style>

*)
        //case pData^.kml_data.current_tag of
        //kml_Folder,kml_Placemark: begin
          // headers - Folder and Placemark here - strings only
          if KML_subtag_str_type(V_sub_Name, V_kml_str) then begin
            // strings
            if (nil=piWideStrings^.p_kml_params_str) then
              New(piWideStrings^.p_kml_params_str);
            piWideStrings^.p_kml_params_str^.kml_params_buffers[V_kml_str]:=VSAGPS_XML_DOMNodeValue(ASubNode);
            pData^.kml_data.fParamsStrs[V_kml_str]:=PWideChar(piWideStrings^.p_kml_params_str^.kml_params_buffers[V_kml_str]);
            Include(pData^.kml_data.fAvail_strs, V_kml_str);
          end else if WideSameText(V_sub_Name, 'color') then begin
            // color
            if (pData^.kml_data.current_tag = kml_PolyStyle) then begin
              // background color for polygon
              if VSAGPS_Parse_Hex_DWORD(ASubNode, @(pData^.kml_data.fValues.bgColor)) then begin
                Include(pData^.kml_data.fAvail_params, kml_bgColor);
              end;
            end else if (pData^.kml_data.current_tag = kml_LabelStyle) then begin
              // text color for POI
              if VSAGPS_Parse_Hex_DWORD(ASubNode, @(pData^.kml_data.fValues.textColor)) then begin
                Include(pData^.kml_data.fAvail_params, kml_textColor);
              end;
            end else begin
              // line color
              if VSAGPS_Parse_Hex_DWORD(ASubNode, @(pData^.kml_data.fValues.color)) then begin
                Include(pData^.kml_data.fAvail_params, kml_color);
              end;
            end;
          end else if WideSameText(V_sub_Name, 'bgColor') then begin
            // bgColor
            if VSAGPS_Parse_Hex_DWORD(ASubNode, @(pData^.kml_data.fValues.bgColor)) then begin
              Include(pData^.kml_data.fAvail_params, kml_bgColor);
            end;
          end else if WideSameText(V_sub_Name, 'textColor') then begin
            // textColor
            if VSAGPS_Parse_Hex_DWORD(ASubNode, @(pData^.kml_data.fValues.textColor)) then begin
              Include(pData^.kml_data.fAvail_params, kml_textColor);
            end;
          end else if WideSameText(V_sub_Name, 'width') then begin
            // width
            if VSAGPS_Parse_BYTE(ASubNode, @(pData^.kml_data.fValues.width)) then begin
              Include(pData^.kml_data.fAvail_params, kml_width);
            end;
          end else if WideSameText(V_sub_Name, 'when') then begin
            // when
            V_sub_Value:=VSAGPS_XML_DOMNodeValue(ASubNode);
            if VSAGPS_WideString_to_ISO8601_Time(V_sub_Value, @(pData^.kml_data.fValues.when)) then begin
              Include(pData^.kml_data.fAvail_params, kml_when);
            end;
          end else if WideSameText(V_sub_Name, 'fill') then begin
            // fill
            if VSAGPS_Parse_BYTE(ASubNode, @(pData^.kml_data.fValues.fill)) then begin
              Include(pData^.kml_data.fAvail_params, kml_fill);
            end;
          end else if WideSameText(V_sub_Name, 'scale') then begin
            // scale
            if (pData^.kml_data.current_tag = kml_LabelStyle) then begin
              if VSAGPS_Parse_LabelScale(ASubNode, @(pData^.kml_data.fValues.tileSize), AFS) then begin
                Include(pData^.kml_data.fAvail_params, kml_tileSize);
              end;
            end else begin
              if VSAGPS_Parse_Double(ASubNode, pData^.kml_data.fValues.scale, AFS) then begin
                Include(pData^.kml_data.fAvail_params, kml_scale_);
              end;
            end;
          end else begin
            // others (params) - empty
          end;
        //end;

        //end;
      end;
{$ifend}

      xsf_XML: begin
        // parse all tags - EMPTY
      end;  
    end;
  end;

  procedure _Parse_Abstract_XML_Tag(const ADOMNode: IDOMNode;
                                    const pXmlData: Pvsagps_XML_ParserData_Abstract;
                                    const piWideStrings: Pvsagps_XML_WideStrings);
  var nws: WideString;

    procedure _SetFor(const ttt: Tvsagps_XML_str);
    begin
      if (0<Length(nws)) then begin
        piWideStrings^.p_xml_all_str^.xml_buffers[ttt] := nws;
        pXmlData^.xml_strs[ttt] := PWideChar(piWideStrings^.p_xml_all_str^.xml_buffers[ttt]);
      end;
    end;

  begin
    if (nil=piWideStrings^.p_xml_all_str) then
      New(piWideStrings^.p_xml_all_str);

    // nodeName
    nws:=ADOMNode.nodeName;
    _SetFor(xml_nodeName);

    // nodeValue
    nws:=ADOMNode.nodeValue;
    _SetFor(xml_nodeValue);

    // type
    pXmlData^.xml_node_type := ADOMNode.nodeType;
    pXmlData^.xml_has_child_nodes := (ADOMNode.hasChildNodes<>FALSE);

    // namespaceURI
    nws:=ADOMNode.namespaceURI;
    _SetFor(xml_namespaceURI);

    // prefix
    nws:=ADOMNode.prefix;
    _SetFor(xml_prefix);

    // localName
    nws:=ADOMNode.localName;
    _SetFor(xml_localName);
  end;

  procedure _ParseDOMNode(const ADOMNode: IDOMNode;
                          const APrevData: Pvsagps_XML_ParserResult);
  var
    V_px_data: Tvsagps_XML_ParserResult;
    V_ws: Tvsagps_XML_WideStrings;
    Vfch: IDOMNode;
  begin
    // root node - check type of xml
    if (nil=APrevData) then
      _CheckRootNodeType(ADOMNode);
      
    // init
    ZeroMemory(@V_ws, sizeof(V_ws));
    ZeroMemory(@V_px_data, sizeof(V_px_data));
    if (nil<>APrevData) then begin
      V_px_data.prev_data:=APrevData;
      V_px_data.recursive_level:=APrevData^.recursive_level+1;
    end;

    try
      // check unparsed tags
      if (not _Get_CurrentTag_by_Name(ADOMNode, @V_px_data)) then begin
        Exit;
      end;

      // any xml
      if (xsf_XML=V_px_state.src_fmt) then
        _Parse_Abstract_XML_Tag(ADOMNode, @(V_px_data.xml_data),  @V_ws);

      // increment counter for current tag
      _Inc_Counter(@V_px_data);

      // call start tag
      _CallUser(@V_px_data, xtd_Open);
      try
        if (not V_px_state.skip_current) then begin
          // read tag attributes
          _Parse_Attributes(ADOMNode, @V_px_data, @V_ws);

          // call after
          _CallUser(@V_px_data, xtd_ReadAttributes);

          // run for subtags
          if (not V_px_state.skip_current) then begin
            // work with subtags
            Vfch:=ADOMNode.firstChild;
            while Assigned(Vfch) do begin
              // check exit
              if _CheckAborted then
                break;

              // check skip to close
              if V_px_state.skip_current then
                break;

              // work with subtag
              if (_Get_SubTag_by_Name(Vfch, @V_px_data)) then begin
                // main tag - full implementation
                // call user
                _CallUser(@V_px_data, xtd_BeforeSub);
                try
                  // run parser for sub node
                  if (not V_px_state.skip_sub) then
                    _ParseDOMNode(Vfch, @V_px_data);
                finally
                  // call after sub
                  _CallUser(@V_px_data, xtd_AfterSub);
                  if V_px_state.skip_sub then
                    V_px_state.skip_sub:=FALSE;
                end;
                // end of subtag user calls
              end else begin
                // some special (sub)tags - just fetch values to buffers
                _Parse_SubTag(Vfch, @V_px_data, @V_ws);
              end;

              // next
              Vfch:=Vfch.nextSibling;
            end;
          end;
        end;
      finally
        // call finish tag
        _CallUser(@V_px_data, xtd_Close);
        if V_px_state.skip_current then
          V_px_state.skip_current:=FALSE;
        if V_px_state.skip_sub then
          V_px_state.skip_sub:=FALSE;
      end;
    finally
{$if defined(VSAGPS_ALLOW_IMPORT_GPX)}
      if (nil<>V_ws.p_gpx_ext_str) then
        Dispose(V_ws.p_gpx_ext_str);
      if (nil<>V_ws.p_gpx_trk_str) then
        Dispose(V_ws.p_gpx_trk_str);
      if (nil<>V_ws.p_gpx_trk_ext_str) then
        Dispose(V_ws.p_gpx_trk_ext_str);
      if (nil<>V_ws.p_gpx_wpt_str) then
        Dispose(V_ws.p_gpx_wpt_str);
      if (nil<>V_ws.p_gpx_wpt_ext_str) then
        Dispose(V_ws.p_gpx_wpt_ext_str);
{$ifend}
{$if defined(VSAGPS_ALLOW_IMPORT_KML)}
      if (nil<>V_ws.p_kml_params_str) then
        Dispose(V_ws.p_kml_params_str);
      if (nil<>V_ws.p_kml_attrib_str) then
        Dispose(V_ws.p_kml_attrib_str);
{$ifend}
      if (nil<>V_ws.p_xml_all_str) then
        Dispose(V_ws.p_xml_all_str);
    end;
  end;

var
  VDOMDocument: IDOMDocument;

  function _LoadFromFile: Boolean;
  var ms: TMemoryStream;
  begin
    ms:=TMemoryStream.Create;
    try
      ms.LoadFromFile(wczSourceFilename);
      Result:=VSAGPS_Load_DOMDocument_FromStream(VDOMDocument, ms, TRUE);
    finally
      ms.Free;
    end;
  end;

  function _LoadDoc: Boolean;
  begin
    Result:=FALSE;
    if (nil<>V_px_state.objStream) then begin
      if VSAGPS_Load_DOMDocument_FromStream(VDOMDocument, TStream(V_px_state.objStream), TRUE) then
        Inc(Result);
    end else begin
      if _LoadFromFile then
        Inc(Result);
    end;
  end;

  procedure _ParseDoc;
  var Vfch: IDOMNode;
  begin
    V_px_state.root_tag_index:=0;
    // list of main tags: xml and (gpx or kml)
    Vfch:=VDOMDocument.firstChild;
    // for each
    while Assigned(Vfch) do begin
      // check exit
      if _CheckAborted then
        Exit;
      // parse node
      Inc(V_px_state.root_tag_index);
      _ParseDOMNode(Vfch, nil);
      // next node
      Vfch:=Vfch.nextSibling;
    end;
  end;

begin
  bOK:=FALSE;
  Result:=FALSE;
  ZeroMemory(@(V_px_state), sizeof(V_px_state));

  // save params to struct
  V_px_state.wszFileName := PWideChar(wczSourceFilename);
  V_px_state.objStream := AStream;

  if (nil=V_px_state.objStream) then begin
    // load from file
    V_px_state.src_fmt:=Get_ParseXML_FileType(wczSourceFilename);
    if (xsf_Unsupported=V_px_state.src_fmt) then begin
      // unsupported file - allow to subst supported stream
      if Assigned(pPX_Options^.pUnsupportedFileProc) then
        pPX_Options^.pUnsupportedFileProc(pUserObjPointer, pUserAuxPointer, pPX_Options, @V_px_state);
      // if stream not defined - exit
      if (nil=V_px_state.objStream) then
        Exit;
    end;
  end else begin
    // will load from stream
  end;

  if bInitUninit then
    res:=CoInitializeEx(nil, COINIT_MULTITHREADED)
  else
    res:=RPC_E_CHANGED_MODE;

  VDOMDocument:=nil;
  try
    // create doc using available factories (raise error if no xml vendors)
    if VSAGPS_Create_DOMDocument(VDOMDocument, TRUE, 1) then
    try
      // load from stream or from file and then parse doc
      if _LoadDoc then
        if (not _CheckAborted) then
          _ParseDoc;
    finally
      VDOMDocument:=nil;
    end;
  finally
    if bInitUninit then
    if (S_OK=res) or (S_FALSE=res) or Succeeded(res) then
    CoUninitialize;

    if bOK and (not V_px_state.aborted_by_user) then
      Result:=TRUE;
  end;
end;
{$ifend}

end.