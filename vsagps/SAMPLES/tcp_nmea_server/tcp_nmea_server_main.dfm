object frmTcpNmeaServer: TfrmTcpNmeaServer
  Left = 200
  Top = 100
  Caption = 'TCP NMEA Server'
  ClientHeight = 552
  ClientWidth = 604
  Color = clBtnFace
  Constraints.MinHeight = 470
  Constraints.MinWidth = 620
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object spl1: TSplitter
    Left = 220
    Top = 246
    Width = 6
    Height = 306
    AutoSnap = False
    MinSize = 120
    ExplicitHeight = 414
  end
  object gbClients: TGroupBox
    Left = 0
    Top = 246
    Width = 220
    Height = 306
    Align = alLeft
    Caption = ' Clients '
    TabOrder = 0
    ExplicitHeight = 414
    DesignSize = (
      220
      306)
    object lbClients: TListBox
      Left = 8
      Top = 18
      Width = 204
      Height = 280
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      ExplicitHeight = 388
    end
  end
  object gbTcp: TGroupBox
    Left = 226
    Top = 246
    Width = 378
    Height = 306
    Align = alClient
    Caption = ' TCP events '
    TabOrder = 1
    ExplicitWidth = 674
    ExplicitHeight = 414
    DesignSize = (
      378
      306)
    object mmTcp: TMemo
      Left = 8
      Top = 18
      Width = 362
      Height = 280
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
      ExplicitWidth = 658
      ExplicitHeight = 388
    end
  end
  object panTop: TPanel
    Left = 0
    Top = 0
    Width = 604
    Height = 274
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 900
    DesignSize = (
      604
      274)
    object lblPort: TLabel
      Left = 12
      Top = 16
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object lblServerState: TLabel
      Left = 330
      Top = 16
      Width = 263
      Height = 13
      Caption = 'server stopped'
    end
    object edPort: TEdit
      Left = 44
      Top = 12
      Width = 60
      Height = 21
      TabOrder = 0
      Text = '10110'
    end
    object btnStartServer: TButton
      Left = 116
      Top = 10
      Width = 100
      Height = 25
      Caption = 'Start server'
      TabOrder = 1
      OnClick = btnStartServerClick
    end
    object btnStopServer: TButton
      Left = 224
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Stop server'
      Enabled = False
      TabOrder = 2
      OnClick = btnStopServerClick
    end
    object gbTrack: TGroupBox
      Left = 8
      Top = 44
      Width = 588
      Height = 84
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Track playback '
      TabOrder = 3
      ExplicitWidth = 884
      object lblTrack: TLabel
        Left = 124
        Top = 26
        Width = 74
        Height = 13
        Caption = 'no track loaded'
      end
      object lblSpeed: TLabel
        Left = 124
        Top = 56
        Width = 43
        Height = 13
        Caption = 'Speed x:'
      end
      object lblPlayState: TLabel
        Left = 458
        Top = 56
        Width = 127
        Height = 13
      end
      object btnOpenGpx: TButton
        Left = 12
        Top = 22
        Width = 100
        Height = 25
        Caption = 'Open GPX...'
        TabOrder = 0
        OnClick = btnOpenGpxClick
      end
      object chkLoop: TCheckBox
        Left = 12
        Top = 53
        Width = 60
        Height = 17
        Caption = 'Loop'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object edSpeed: TEdit
        Left = 173
        Top = 52
        Width = 50
        Height = 21
        TabOrder = 2
        Text = '1'
      end
      object btnPlay: TButton
        Left = 242
        Top = 48
        Width = 100
        Height = 25
        Caption = 'Start playback'
        Enabled = False
        TabOrder = 3
        OnClick = btnPlayClick
      end
      object btnStopPlay: TButton
        Left = 352
        Top = 48
        Width = 100
        Height = 25
        Caption = 'Stop playback'
        Enabled = False
        TabOrder = 4
        OnClick = btnStopPlayClick
      end
    end
    object gbEmulation: TGroupBox
      Left = 8
      Top = 136
      Width = 588
      Height = 88
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Emulation '
      TabOrder = 4
      ExplicitWidth = 884
      object lblStallFor: TLabel
        Left = 440
        Top = 28
        Width = 42
        Height = 13
        Caption = 'for (ms):'
      end
      object chkDrop: TCheckBox
        Left = 12
        Top = 26
        Width = 150
        Height = 17
        Caption = 'Drop all clients every (sec):'
        TabOrder = 0
        OnClick = EmulParamChanged
      end
      object edDropSec: TEdit
        Left = 168
        Top = 24
        Width = 40
        Height = 21
        TabOrder = 1
        Text = '10'
      end
      object chkStall: TCheckBox
        Left = 226
        Top = 26
        Width = 150
        Height = 17
        Caption = 'Stall (pause) every (sec):'
        TabOrder = 2
        OnClick = EmulParamChanged
      end
      object edStallSec: TEdit
        Left = 381
        Top = 24
        Width = 40
        Height = 21
        TabOrder = 3
        Text = '30'
      end
      object edStallMs: TEdit
        Left = 492
        Top = 24
        Width = 60
        Height = 21
        TabOrder = 4
        Text = '2000'
      end
      object chkGpsd: TCheckBox
        Left = 12
        Top = 56
        Width = 560
        Height = 17
        Caption =
          'gpsd server mode: VERSION banner + ?WATCH required before the s' +
          'tream, JSON reports interleaved (set before starting the server)'
        TabOrder = 5
      end
    end
    object gbLogging: TGroupBox
      Left = 8
      Top = 230
      Width = 588
      Height = 40
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Logging '
      TabOrder = 5
      ExplicitWidth = 884
      DesignSize = (
        588
        40)
      object lblLogFiles: TLabel
        Left = 500
        Top = 19
        Width = -293
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        ShowHint = True
        ExplicitWidth = 3
      end
      object chkLogNmea: TCheckBox
        Left = 12
        Top = 17
        Width = 200
        Height = 20
        Caption = 'Save NMEA stream to file (raw)'
        TabOrder = 0
        OnClick = LogParamChanged
      end
      object chkLogTcp: TCheckBox
        Left = 226
        Top = 17
        Width = 200
        Height = 17
        Caption = 'Save TCP events to file'
        TabOrder = 1
        OnClick = LogParamChanged
      end
    end
  end
  object tmrWork: TTimer
    Interval = 100
    OnTimer = tmrWorkTimer
    Left = 420
    Top = 12
  end
  object dlgOpen: TOpenDialog
    Filter = 'GPX tracks (*.gpx)|*.gpx|All files (*.*)|*.*'
    Left = 460
    Top = 12
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 529
    Width = 604
    Height = 23
    Panels = <
      item
        Text = 'clients: 0'
        Width = 110
      end
      item
        Text = 'out: 0 b / 0 nmea'
        Width = 230
      end
      item
        Text = 'in: 0 b'
        Width = 120
      end
      item
        Text = 'tcp err: 0'
        Width = 140
      end>
  end
end
