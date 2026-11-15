program tcp_nmea_client;

uses
  Vcl.Forms,
  Vcl.XPMan,
  tcp_nmea_client_main in 'tcp_nmea_client_main.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'TCP NMEA Client';
  Application.CreateForm(TfrmTcpNmeaClient, frmTcpNmeaClient);
  Application.Run;
end.
