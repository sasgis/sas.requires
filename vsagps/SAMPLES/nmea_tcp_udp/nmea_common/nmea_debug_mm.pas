unit nmea_debug_mm;

interface

// The first unit of the uses clause of the sample projects. The dpr unit
// list must not contain conditional compilation, so the ifdef lives here:
// when MADEXECT is defined (by the build script or the IDE settings), the
// madExcept units are compiled in and initialized before every other unit
// of the project. Without the define this unit is empty and the build needs
// no madCollection installation. The madCollection search paths are passed
// by the build script or the IDE settings as well (they are not stored in
// the dproj files).

{$IFDEF MADEXECT}
uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules;
{$ENDIF}

implementation

// Make extended configuration madExcept here //

end.
