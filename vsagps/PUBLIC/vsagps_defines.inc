(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
(*
*)

{.$define VSAGPS_USE_DEBUG_STRING}
{.$define VSAGPS_USE_DEBUG_STRING_NMEA_SENTENCE}

{.$define USE_NMEA_VTG}
{.$define USE_NMEA_PROPRIETARY_WITHOUT_TAIL}

{.$define USE_SIMPLE_CLASSES}

{.$define USE_NATIVE_NT_API}

{$IF CompilerVersion >= 23}
{.$define VSAGPS_USE_UNICODE}
{$define HAS_ANSISTRINGS_UNIT}
{$IFEND}

{$IF CompilerVersion < 25}
  {$define VSAGPS_USE_LOCATIONAPI_TLB}
{$IFEND}

{$IF CompilerVersion >= 22} // Delphi XE and UP
  {$define VSAGPS_XERCES_XML_IMPORT_FORBIDDEN}
{$IFEND}

{$if not defined(VSAGPS_XERCES_XML_IMPORT_FORBIDDEN)}
{$define VSAGPS_USE_XERCES_XML_IMPORT}
{$ifend}

{$if not defined(VSAGPS_MSXML_IMPORT_FORBIDDEN)}
{$define VSAGPS_USE_MSXML_IMPORT}
{$ifend}

{$if defined(VSAGPS_USE_XERCES_XML_IMPORT) or defined(VSAGPS_USE_MSXML_IMPORT)}

{$define VSAGPS_USE_SOME_KIND_OF_XML_IMPORT}

{$if not defined(VSAGPS_IMPORT_GPX_FORBIDDEN)}
{$define VSAGPS_ALLOW_IMPORT_GPX}
{$ifend}

{$if not defined(VSAGPS_IMPORT_KML_FORBIDDEN)}
{$define VSAGPS_ALLOW_IMPORT_KML}
{$ifend}

{$ifend}
