(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_point;
(*
*)

{$I vsagps_defines.inc}

interface

type
  TDoublePoint = packed record
    X, Y: Double;
  end;
  PDoublePoint = ^TDoublePoint;

  TArrayOfDoublePoint = array of TDoublePoint;
  PArrayOfDoublePoint = ^TArrayOfDoublePoint;

implementation

end.