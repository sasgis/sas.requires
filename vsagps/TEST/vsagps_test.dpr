program vsagps_test;

{.$DEFINE REPORT_MEMORY_LEAK}

{.$DEFINE CONSOLE_TESTRUNNER}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  vsagps_com_checker_test in 'vsagps_com_checker_test.pas',
  vsagps_device_com_nmea_test in 'vsagps_device_com_nmea_test.pas',
  vsagps_classes in '..\RUNTIME\vsagps_classes.pas',
  vsagps_com_checker in '..\RUNTIME\vsagps_com_checker.pas',
  vsagps_device_base in '..\RUNTIME\vsagps_device_base.pas',
  vsagps_device_com_nmea in '..\Runtime\vsagps_device_com_nmea.pas',
  vsagps_device_usb_garmin in '..\RUNTIME\vsagps_device_usb_garmin.pas',
  vsagps_ini in '..\RUNTIME\vsagps_ini.pas',
  vsagps_object in '..\RUNTIME\vsagps_object.pas',
  vsagps_parser_nmea in '..\RUNTIME\vsagps_parser_nmea.pas',
  vsagps_queue in '..\RUNTIME\vsagps_queue.pas',
  vsagps_runtime in '..\RUNTIME\vsagps_runtime.pas',
  vsagps_tools in '..\RUNTIME\vsagps_tools.pas',
  vsagps_track_reader in '..\RUNTIME\vsagps_track_reader.pas',
  vsagps_track_saver in '..\RUNTIME\vsagps_track_saver.pas',
  vsagps_track_writer in '..\RUNTIME\vsagps_track_writer.pas',
  vsagps_units in '..\RUNTIME\vsagps_units.pas',
  vsagps_public_base in '..\PUBLIC\vsagps_public_base.pas',
  vsagps_public_classes in '..\PUBLIC\vsagps_public_classes.pas',
  vsagps_public_com_checker in '..\PUBLIC\vsagps_public_com_checker.pas',
  vsagps_public_debugstring in '..\PUBLIC\vsagps_public_debugstring.pas',
  vsagps_public_device in '..\PUBLIC\vsagps_public_device.pas',
  vsagps_public_dll in '..\PUBLIC\vsagps_public_dll.pas',
  vsagps_public_events in '..\PUBLIC\vsagps_public_events.pas',
  vsagps_public_garmin in '..\PUBLIC\vsagps_public_garmin.pas',
  vsagps_public_gpx in '..\PUBLIC\vsagps_public_gpx.pas',
  vsagps_public_kml in '..\PUBLIC\vsagps_public_kml.pas',
  vsagps_public_location_api in '..\PUBLIC\vsagps_public_location_api.pas',
  vsagps_public_memory in '..\PUBLIC\vsagps_public_memory.pas',
  vsagps_public_nmea in '..\PUBLIC\vsagps_public_nmea.pas',
  vsagps_public_parser in '..\PUBLIC\vsagps_public_parser.pas',
  vsagps_public_point in '..\PUBLIC\vsagps_public_point.pas',
  vsagps_public_position in '..\PUBLIC\vsagps_public_position.pas',
  vsagps_public_print in '..\PUBLIC\vsagps_public_print.pas',
  vsagps_public_sats_info in '..\PUBLIC\vsagps_public_sats_info.pas',
  vsagps_public_sysutils in '..\PUBLIC\vsagps_public_sysutils.pas',
  vsagps_public_time in '..\PUBLIC\vsagps_public_time.pas',
  vsagps_public_trackpoint in '..\PUBLIC\vsagps_public_trackpoint.pas',
  vsagps_public_tracks in '..\PUBLIC\vsagps_public_tracks.pas',
  vsagps_public_types in '..\PUBLIC\vsagps_public_types.pas',
  vsagps_public_unicode in '..\PUBLIC\vsagps_public_unicode.pas',
  vsagps_public_unit_info in '..\PUBLIC\vsagps_public_unit_info.pas',
  vsagps_public_version in '..\PUBLIC\vsagps_public_version.pas',
  vsagps_public_xml_dom in '..\PUBLIC\vsagps_public_xml_dom.pas',
  vsagps_public_xml_parser in '..\PUBLIC\vsagps_public_xml_parser.pas';

begin
  {$IFDEF REPORT_MEMORY_LEAK}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  try
    DUnitTestRunner.RunRegisteredTests;
  finally
    {$IFDEF CONSOLE_TESTRUNNER}
    Writeln('Press ENTER to exit...');
    Readln;
    {$ENDIF}
  end;
end.

