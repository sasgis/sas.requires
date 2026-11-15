object frmTcpNmeaClient: TfrmTcpNmeaClient
  Left = 260
  Top = 140
  Caption = 'TCP NMEA Client'
  ClientHeight = 520
  ClientWidth = 720
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 520
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object lblHost: TLabel
    Left = 12
    Top = 16
    Width = 27
    Height = 13
    Caption = 'Host:'
  end
  object lblPort: TLabel
    Left = 186
    Top = 16
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object lblStatus: TLabel
    Left = 240
    Top = 46
    Width = 464
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    Caption = 'disconnected'
  end
  object edHost: TEdit
    Left = 44
    Top = 12
    Width = 130
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edPort: TEdit
    Left = 214
    Top = 12
    Width = 60
    Height = 21
    TabOrder = 1
    Text = '10110'
  end
  object btnConnect: TButton
    Left = 286
    Top = 10
    Width = 80
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btnConnectClick
  end
  object btnDisconnect: TButton
    Left = 372
    Top = 10
    Width = 80
    Height = 25
    Caption = 'Disconnect'
    Enabled = False
    TabOrder = 3
    OnClick = btnDisconnectClick
  end
  object chkGpsdAuto: TCheckBox
    Left = 470
    Top = 14
    Width = 235
    Height = 17
    Caption = 'Auto-detect gpsd (send ?WATCH)'
    Hint =
      'Before connecting: on the {"class":"VERSION"} greeting the client' +
      ' sends ?WATCH={"enable":true,"nmea":true} and the gpsd server star' +
      'ts streaming'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
  end
  object chkAutoReconnect: TCheckBox
    Left = 12
    Top = 46
    Width = 130
    Height = 17
    Caption = 'Auto-reconnect every'
    TabOrder = 4
  end
  object edRetrySec: TEdit
    Left = 146
    Top = 44
    Width = 35
    Height = 21
    TabOrder = 5
    Text = '3'
  end
  object lblRetrySec: TLabel
    Left = 186
    Top = 48
    Width = 40
    Height = 13
    Caption = 'sec'
  end
  object gbLogging: TGroupBox
    Left = 8
    Top = 70
    Width = 704
    Height = 40
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Logging '
    TabOrder = 6
    object chkLogNmea: TCheckBox
      Left = 12
      Top = 17
      Width = 250
      Height = 17
      Caption = 'Save NMEA stream to file (raw)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = LogParamChanged
    end
    object chkLogTcp: TCheckBox
      Left = 270
      Top = 17
      Width = 380
      Height = 17
      Caption = 'Save TCP events to file'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = LogParamChanged
    end
  end
  object gbLog: TGroupBox
    Left = 8
    Top = 116
    Width = 704
    Height = 396
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' TCP events '
    TabOrder = 7
    object mmLog: TMemo
      Left = 8
      Top = 18
      Width = 688
      Height = 370
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object tmrWork: TTimer
    Interval = 100
    OnTimer = tmrWorkTimer
    Left = 680
    Top = 12
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 497
    Width = 720
    Height = 23
    Panels = <
      item
        Text = 'in: 0 b'
        Width = 160
      end
      item
        Text = 'nmea: 0 (err: 0)'
        Width = 180
      end
      item
        Text = 'json: 0'
        Width = 110
      end
      item
        Text = 'tcp err: 0, conn: 0'
        Width = 190
      end>
  end
end
