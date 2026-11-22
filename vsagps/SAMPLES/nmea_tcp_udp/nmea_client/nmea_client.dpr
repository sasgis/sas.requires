program nmea_client;

uses
  nmea_debug_mm,
  Vcl.Forms,
  Vcl.XPMan,
  nmea_client_main in 'nmea_client_main.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'NMEA Client (TCP/UDP)';
  Application.CreateForm(TfrmNmeaClient, frmNmeaClient);
  Application.Run;
end.
