program vsagps_stress;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  vsagps_stress_main in 'vsagps_stress_main.pas';

begin
  Halt(StressRun);
end.
