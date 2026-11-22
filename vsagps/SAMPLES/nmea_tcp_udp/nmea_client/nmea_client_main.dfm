object frmNmeaClient: TfrmNmeaClient
  Left = 260
  Top = 140
  Caption = 'NMEA Client (TCP/UDP)'
  ClientHeight = 520
  ClientWidth = 702
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
  DesignSize = (
    702
    520)
  TextHeight = 13
  object lblHost: TLabel
    Left = 108
    Top = 15
    Width = 26
    Height = 13
    Caption = 'Host:'
  end
  object lblPort: TLabel
    Left = 282
    Top = 15
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object lblStatus: TLabel
    Left = 278
    Top = 48
    Width = 45
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    Caption = 'disconnected'
    ExplicitWidth = 63
  end
  object lblRetrySec: TLabel
    Left = 186
    Top = 48
    Width = 16
    Height = 13
    Caption = 'sec'
  end
  object edHost: TEdit
    Left = 140
    Top = 11
    Width = 130
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edPort: TEdit
    Left = 310
    Top = 11
    Width = 60
    Height = 21
    TabOrder = 1
    Text = '10110'
  end
  object btnConnect: TButton
    Left = 382
    Top = 9
    Width = 80
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btnConnectClick
  end
  object btnDisconnect: TButton
    Left = 468
    Top = 9
    Width = 80
    Height = 25
    Caption = 'Disconnect'
    Enabled = False
    TabOrder = 3
    OnClick = btnDisconnectClick
  end
  object rgTransport: TRadioGroup
    Left = 0
    Top = 0
    Width = 103
    Height = 34
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'TCP'
      'UDP')
    ShowFrame = False
    TabOrder = 9
    OnClick = TransportChanged
  end
  object chkGpsdAuto: TCheckBox
    Left = 583
    Top = 12
    Width = 121
    Height = 19
    Hint = 
      'Before connecting: on the {"class":"VERSION"} greeting the clien' +
      't sends ?WATCH={"enable":true,"nmea":true} and the gpsd server s' +
      'tarts streaming'
    Caption = 'Auto-detect GPSD'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 8
  end
  object chkAutoReconnect: TCheckBox
    Left = 12
    Top = 46
    Width = 130
    Height = 17
    Caption = 'Auto-reconnect every'
    Checked = True
    State = cbChecked
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
  object gbLogging: TGroupBox
    Left = 8
    Top = 70
    Width = 686
    Height = 40
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Logging '
    TabOrder = 6
    ExplicitWidth = 704
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
    object chkLogEvents: TCheckBox
      Left = 270
      Top = 17
      Width = 380
      Height = 17
      Caption = 'Save events to file'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = LogParamChanged
    end
  end
  object gbLog: TGroupBox
    Left = 8
    Top = 116
    Width = 686
    Height = 396
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Events '
    TabOrder = 7
    ExplicitWidth = 704
    DesignSize = (
      686
      396)
    object mmLog: TMemo
      Left = 8
      Top = 18
      Width = 670
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
      ExplicitWidth = 688
    end
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 497
    Width = 702
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
    ExplicitWidth = 720
  end
  object tmrWork: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrWorkTimer
    Left = 632
    Top = 164
  end
end
