program nmea_server;

uses
  nmea_debug_mm,
  Vcl.Forms,
  Vcl.XPMan,
  nmea_server_main in 'nmea_server_main.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'NMEA Server (TCP/UDP)';
  Application.CreateForm(TfrmNmeaServer, frmNmeaServer);
  Application.Run;
end.
