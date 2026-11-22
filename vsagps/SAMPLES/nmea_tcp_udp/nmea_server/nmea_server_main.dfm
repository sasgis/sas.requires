object frmNmeaServer: TfrmNmeaServer
  Left = 200
  Top = 100
  Caption = 'NMEA Server (TCP/UDP)'
  ClientHeight = 609
  ClientWidth = 760
  Color = clBtnFace
  Constraints.MinHeight = 510
  Constraints.MinWidth = 700
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
    Left = 212
    Top = 273
    Width = 6
    Height = 313
    AutoSnap = False
    MinSize = 120
    ExplicitLeft = 220
    ExplicitTop = 314
    ExplicitHeight = 278
  end
  object gbClients: TGroupBox
    Left = 0
    Top = 273
    Width = 212
    Height = 313
    Align = alLeft
    Caption = ' Clients '
    TabOrder = 0
    ExplicitLeft = 8
    DesignSize = (
      212
      313)
    object lbClients: TListBox
      Left = 8
      Top = 18
      Width = 196
      Height = 310
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      ExplicitWidth = 204
      ExplicitHeight = 252
    end
  end
  object gbLog: TGroupBox
    Left = 218
    Top = 273
    Width = 542
    Height = 313
    Align = alClient
    Caption = ' Events '
    TabOrder = 1
    ExplicitLeft = 226
    ExplicitTop = 314
    ExplicitWidth = 534
    ExplicitHeight = 255
    DesignSize = (
      542
      313)
    object mmLog: TMemo
      Left = 8
      Top = 18
      Width = 526
      Height = 310
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
      ExplicitWidth = 518
      ExplicitHeight = 252
    end
  end
  object panTop: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 273
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      760
      273)
    object lblPort: TLabel
      Left = 100
      Top = 16
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object lblTarget: TLabel
      Left = 400
      Top = 16
      Width = 57
      Height = 13
      Caption = 'UDP target:'
    end
    object lblServerState: TLabel
      Left = 8
      Top = 50
      Width = 73
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'server stopped'
    end
    object rgTransport: TRadioGroup
      Left = 0
      Top = -2
      Width = 94
      Height = 39
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'TCP'
        'UDP')
      ShowFrame = False
      TabOrder = 0
      OnClick = TransportChanged
    end
    object edPort: TEdit
      Left = 134
      Top = 12
      Width = 56
      Height = 21
      TabOrder = 1
      Text = '10110'
    end
    object btnStartServer: TButton
      Left = 196
      Top = 10
      Width = 100
      Height = 25
      Caption = 'Start server'
      TabOrder = 2
      OnClick = btnStartServerClick
    end
    object btnStopServer: TButton
      Left = 302
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Stop server'
      Enabled = False
      TabOrder = 3
      OnClick = btnStopServerClick
    end
    object edTarget: TEdit
      Left = 466
      Top = 12
      Width = 160
      Height = 21
      Hint = 
        'The datagrams are sent to this "addr:port" (an unicast address, ' +
        'a subnet broadcast address or a multicast group) in addition to ' +
        'the learned subscribers; empty = the subscribers only'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object gbTrack: TGroupBox
      Left = 8
      Top = 70
      Width = 744
      Height = 84
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Track playback '
      TabOrder = 5
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
        Width = 3
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
      Top = 162
      Width = 744
      Height = 63
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Emulation '
      TabOrder = 6
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
        Left = 576
        Top = 26
        Width = 144
        Height = 17
        Caption = 'GPSD server mode'
        TabOrder = 5
      end
    end
    object gbLogging: TGroupBox
      Left = 8
      Top = 231
      Width = 744
      Height = 40
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Logging '
      TabOrder = 7
      object chkLogNmea: TCheckBox
        Left = 12
        Top = 17
        Width = 200
        Height = 20
        Caption = 'Save NMEA stream to file (raw)'
        TabOrder = 0
        OnClick = LogParamChanged
      end
      object chkLogEvents: TCheckBox
        Left = 226
        Top = 17
        Width = 200
        Height = 17
        Caption = 'Save events to file'
        TabOrder = 1
        OnClick = LogParamChanged
      end
    end
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 586
    Width = 760
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
        Text = 'net err: 0'
        Width = 140
      end>
    ExplicitTop = 569
  end
  object tmrWork: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrWorkTimer
    Left = 508
    Top = 100
  end
  object dlgOpen: TOpenDialog
    Filter = 'GPX tracks (*.gpx)|*.gpx|All files (*.*)|*.*'
    Left = 556
    Top = 100
  end
end
