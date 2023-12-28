unit vsagps_device_com_nmea_test;

interface

uses
  TestFramework,
  vsagps_public_device,
  vsagps_public_memory,
  vsagps_device_com_nmea;

type
  Tvsagps_device_com_nmea_test = class(TTestCase)
  published
    procedure TestNmeaParsePacket;
  end;

implementation

uses
  Windows;

const
  CData: array [0..594] of Byte = (
    // NMEA: $GNGBS,114734.00,8.0,8.1,17.2,,,,*6E
    $24, $47, $4E, $47, $42, $53, $2C, $31, $31, $34, $37, $33, $34, $2E, $30, $30,
    $2C, $38, $2E, $30, $2C, $38, $2E, $31, $2C, $31, $37, $2E, $32, $2C, $2C, $2C,
    $2C, $2A, $36, $45, $0D, $0A,

    // UBX binary packet
    $B5, $62, $0A, $04, $FA, $00, $45, $58, $54, $20, $43, $4F, $52, $45, $20, $33,
    $2E, $30, $31, $20, $28, $31, $31, $31, $31, $34, $31, $29, $00, $00, $00, $00,
    $00, $00, $00, $00, $30, $30, $30, $38, $30, $30, $30, $30, $00, $00, $52, $4F,
    $4D, $20, $42, $41, $53, $45, $20, $32, $2E, $30, $31, $20, $28, $37, $35, $33,
    $33, $31, $29, $00, $00, $00, $00, $00, $00, $00, $00, $00, $46, $57, $56, $45,
    $52, $3D, $54, $49, $4D, $20, $31, $2E, $31, $30, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $52, $4F, $54, $56, $45,
    $52, $3D, $32, $32, $2E, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $4D, $4F, $44, $3D, $4E, $45, $4F, $2D,
    $4D, $38, $54, $2D, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $46, $49, $53, $3D, $30, $78, $43, $32, $32, $35,
    $33, $36, $20, $28, $31, $30, $30, $31, $31, $31, $29, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $47, $50, $53, $3B, $47, $4C, $4F, $3B, $47, $41, $4C, $3B,
    $42, $44, $53, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $53, $42, $41, $53, $3B, $49, $4D, $45, $53, $3B, $51, $5A, $53, $53,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $01, $1D,

    // UBX binary packet
    $B5, $62, $01, $30, $A4, $00, $28, $16, $88, $02, $0D, $04, $00, $00, $02, $02,
    $0D, $04, $10, $20, $36, $01, $45, $02, $00, $00, $08, $03, $0D, $04, $09, $1A,
    $62, $00, $49, $04, $00, $00, $06, $04, $14, $01, $00, $56, $08, $00, $00, $00,
    $00, $00, $00, $06, $0D, $04, $17, $43, $0A, $01, $A6, $FD, $FF, $FF, $05, $07,
    $0D, $07, $1B, $22, $A3, $00, $5C, $01, $00, $00, $04, $09, $0D, $04, $10, $53,
    $15, $00, $13, $FB, $FF, $FF, $09, $10, $04, $01, $00, $00, $45, $00, $00, $00,
    $00, $00, $03, $11, $0D, $04, $0A, $09, $D8, $00, $FE, $08, $00, $00, $07, $13,
    $0D, $04, $14, $12, $E7, $00, $D0, $02, $00, $00, $0A, $16, $04, $01, $00, $08,
    $6A, $00, $00, $00, $00, $00, $01, $17, $0D, $07, $24, $34, $36, $00, $BF, $FF,
    $FF, $FF, $0C, $1A, $04, $01, $00, $02, $2D, $00, $00, $00, $00, $00, $0B, $1E,
    $0D, $07, $1C, $08, $BA, $00, $90, $FE, $FF, $FF, $89, $A8,

    // UBX binary packet
    $B5, $62, $01, $03, $10, $00, $28, $16, $88, $02, $03, $DD, $00, $08, $0A, $3F,
    $0B, $00, $53, $A3, $22, $00, $30, $70,

    // NMEA: $GNRMC,114735.00,A,4328.35314,N,00120.69232,E,0.005,,171119,,,A*62
    $24, $47, $4E, $52, $4D, $43, $2C, $31, $31, $34, $37, $33, $35, $2E, $30, $30,
    $2C, $41, $2C, $34, $33, $32, $38, $2E, $33, $35, $33, $31, $34, $2C, $4E, $2C,
    $30, $30, $31, $32, $30, $2E, $36, $39, $32, $33, $32, $2C, $45, $2C, $30, $2E,
    $30, $30, $35, $2C, $2C, $31, $37, $31, $31, $31, $39, $2C, $2C, $2C, $41, $2A,
    $36, $32, $0D, $0A,

    // NMEA: $GNVTG,,T,,M,0.005,N,0.009,K,A*31
    $24, $47, $4E, $56, $54, $47, $2C, $2C, $54, $2C, $2C, $4D, $2C, $30, $2E, $30,
    $30, $35, $2C, $4E, $2C, $30, $2E, $30, $30, $39, $2C, $4B, $2C, $41, $2A, $33,
    $31, $0D, $0A
  );

{ Tvsagps_device_com_nmea_test }

procedure Tvsagps_device_com_nmea_test.TestNmeaParsePacket;
var
  VSize: Integer;
  VPos: Integer;
  VObj: Tvsagps_device_com_nmea;
  VPacket: Pointer;
  VParams: TVSAGPS_ALL_DEVICE_PARAMS;
begin
  ZeroMemory(@VParams, sizeof(VParams));

  with VParams do begin
    wSize:=sizeof(VParams);
    btAutodetectOnConnect:=0;
    btReceiveGPSTimeoutSec:=10;
    wConnectionTimeoutSec:=10;
    wWorkerThreadTimeoutMSec:=100;
    dwAutodetectFlags:=0;
    dwDeviceFlagsOut:=0;
    iBaudRate:=4800;
  end;

  VObj := Tvsagps_device_com_nmea.Create;
  try
    VObj.SetBaseParams(0,0,nil,'',@VParams,nil,nil,nil,nil);

    VPos := 0;
    VSize := 10;
    while VPos + VSize < Length(CData) do begin
      VPacket := NmeaPacketCreate(@CData[VPos], VSize);
      VObj.ParsePacket(VPacket);
      Inc(VPos, VSize);
    end;

    VPacket := NmeaPacketCreate(@CData[VPos], Length(CData) - VPos);
    VObj.ParsePacket(VPacket);

    VPacket := NmeaPacketCreate(
      '$' + #01#02 + #13#10 + '$' + #03 + // binary data
      '$123456$' + #13#10 + #13#10 + '$' + #13#10 + // tail before head + empty message
      '$PGRMZ,2282,f,3' + // proprietary without tail
      '$PGRMZ,2282,f,3*21' + #13#10
    );
    VObj.ParsePacket(VPacket);
  finally
    VObj.Free;
  end;
end;

initialization
  RegisterTest(Tvsagps_device_com_nmea_test.Suite);

end.
