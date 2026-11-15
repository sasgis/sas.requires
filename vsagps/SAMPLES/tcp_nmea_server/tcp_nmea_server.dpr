program tcp_nmea_server;

uses
  Vcl.Forms,
  Vcl.XPMan,
  tcp_nmea_server_main in 'tcp_nmea_server_main.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'TCP NMEA Server';
  Application.CreateForm(TfrmTcpNmeaServer, frmTcpNmeaServer);
  Application.Run;
end.
