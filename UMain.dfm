object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 542
  ClientWidth = 847
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PControl: TPanel
    Left = 0
    Top = 0
    Width = 847
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object BConnect: TButton
      Left = 8
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 0
      OnClick = BConnectClick
    end
    object CbScroll: TCheckBox
      Left = 144
      Top = 8
      Width = 97
      Height = 17
      Caption = 'log'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object PConrol: TPanel
    Left = 0
    Top = 452
    Width = 847
    Height = 90
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object SBUp: TSpeedButton
      Left = 478
      Top = 20
      Width = 23
      Height = 22
      OnClick = SBMoveClick
    end
    object SBLeft: TSpeedButton
      Tag = 2
      Left = 457
      Top = 40
      Width = 23
      Height = 22
      OnClick = SBMoveClick
    end
    object SBRight: TSpeedButton
      Tag = 3
      Left = 499
      Top = 40
      Width = 23
      Height = 22
      OnClick = SBMoveClick
    end
    object SBDown: TSpeedButton
      Tag = 1
      Left = 478
      Top = 60
      Width = 23
      Height = 22
      OnClick = SBMoveClick
    end
    object SBCHangeShield: TSpeedButton
      Left = 625
      Top = 6
      Width = 23
      Height = 22
      Caption = 'Slot'
      OnClick = SBCHangeShieldClick
    end
    object btnUp: TSpeedButton
      Tag = 4
      Left = 528
      Top = 20
      Width = 23
      Height = 22
      OnClick = SBMoveClick
    end
    object btnDown: TSpeedButton
      Tag = 5
      Left = 528
      Top = 60
      Width = 23
      Height = 22
      OnClick = SBMoveClick
    end
    object EText: TEdit
      Left = 8
      Top = 6
      Width = 297
      Height = 21
      TabOrder = 0
      OnKeyDown = ETextKeyDown
    end
    object BDo: TButton
      Left = 311
      Top = 6
      Width = 75
      Height = 25
      Caption = '-'
      TabOrder = 1
      OnClick = BDoClick
    end
    object CbJamp: TCheckBox
      Left = 156
      Top = 62
      Width = 50
      Height = 17
      Caption = 'Jamp'
      TabOrder = 16
    end
    object EYaw: TEdit
      Left = 12
      Top = 60
      Width = 65
      Height = 21
      Hint = 'Yaw'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 14
      Text = '0,0'
    end
    object EPitch: TEdit
      Left = 83
      Top = 60
      Width = 65
      Height = 21
      Hint = 'Pitch'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 15
      Text = '0,0'
    end
    object EX: TEdit
      Left = 83
      Top = 33
      Width = 65
      Height = 21
      Hint = 'X'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = '0,0'
    end
    object EY: TEdit
      Left = 9
      Top = 33
      Width = 49
      Height = 21
      Hint = 'Y'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Text = '0,0'
    end
    object EZ: TEdit
      Left = 152
      Top = 33
      Width = 65
      Height = 21
      Hint = 'Z'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      Text = '0,0'
    end
    object EStance: TEdit
      Left = 223
      Top = 33
      Width = 65
      Height = 21
      Hint = 'Stance'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      Text = '0,0'
    end
    object BBGet: TBitBtn
      Left = 294
      Top = 33
      Width = 11
      Height = 25
      Caption = '.'
      TabOrder = 10
      OnClick = BBGetClick
    end
    object BPosLook: TButton
      Tag = 3
      Left = 311
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Pos && Look'
      TabOrder = 4
      OnClick = BMoveClick
    end
    object BLookAt: TButton
      Left = 311
      Top = 56
      Width = 75
      Height = 25
      Caption = 'Look at'
      TabOrder = 13
      OnClick = BLookAtClick
    end
    object SBY: TSpinButton
      Left = 57
      Top = 33
      Width = 20
      Height = 25
      DownGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000008080000080800000808000000000000080800000808000008080000080
        8000008080000080800000808000000000000000000000000000008080000080
        8000008080000080800000808000000000000000000000000000000000000000
        0000008080000080800000808000000000000000000000000000000000000000
        0000000000000000000000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      FocusControl = EY
      TabOrder = 6
      UpGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000000000000000000000000000000000000000000000000000000000000080
        8000008080000080800000000000000000000000000000000000000000000080
        8000008080000080800000808000008080000000000000000000000000000080
        8000008080000080800000808000008080000080800000808000000000000080
        8000008080000080800000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      OnDownClick = SBYDownClick
      OnUpClick = SBYUpClick
    end
    object EActiveSlot: TEdit
      Left = 584
      Top = 6
      Width = 41
      Height = 21
      TabOrder = 2
      Text = '0'
    end
    object btnBGoto: TButton
      Left = 593
      Top = 37
      Width = 75
      Height = 25
      Caption = 'Goto'
      TabOrder = 11
      OnClick = btnBGotoClick
    end
    object BInventory: TButton
      Left = 593
      Top = 64
      Width = 75
      Height = 23
      Caption = 'Inventory'
      TabOrder = 17
      OnClick = BInventoryClick
    end
    object BAnimation: TButton
      Left = 674
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Animation'
      TabOrder = 12
      OnClick = BAnimationClick
    end
    object EAnimation: TEdit
      Left = 672
      Top = 8
      Width = 77
      Height = 21
      TabOrder = 3
      Text = '0'
    end
  end
  object Panel2: TPanel
    Left = 636
    Top = 33
    Width = 211
    Height = 419
    Align = alRight
    Caption = 'Panel2'
    TabOrder = 2
    object MState: TMemo
      Left = 1
      Top = 216
      Width = 209
      Height = 202
      Align = alBottom
      TabOrder = 1
    end
    object LVUsers: TListView
      Left = 1
      Top = 1
      Width = 209
      Height = 215
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Name'
        end
        item
          Caption = 'ID'
          Width = 70
        end
        item
          Caption = 'Ping'
        end>
      ColumnClick = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object PCMain: TPageControl
    Left = 0
    Top = 33
    Width = 636
    Height = 419
    ActivePage = TSLog
    Align = alClient
    TabOrder = 1
    object TSLog: TTabSheet
      Caption = 'Log'
      object Mlines: TMemo
        Left = 0
        Top = 33
        Width = 628
        Height = 358
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object PLogCtrl: TPanel
        Left = 0
        Top = 0
        Width = 628
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object BRespawn: TButton
          Left = 344
          Top = 2
          Width = 75
          Height = 25
          Caption = 'Respawn'
          TabOrder = 0
          OnClick = BRespawnClick
        end
      end
    end
    object TSMap: TTabSheet
      Caption = 'MAP'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tsTSTasks: TTabSheet
      Caption = 'Tasks'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lvTVTasks: TListView
        Left = 0
        Top = 26
        Width = 628
        Height = 365
        Align = alClient
        Columns = <
          item
            Caption = 'Name'
            Width = 150
          end
          item
            AutoSize = True
            Caption = 'State'
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 628
        Height = 26
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object BSendEvent: TButton
          Left = 2
          Top = 0
          Width = 75
          Height = 25
          Caption = 'Send event'
          TabOrder = 0
          OnClick = BSendEventClick
        end
        object BFeller: TButton
          Left = 120
          Top = 0
          Width = 75
          Height = 25
          Caption = 'Feller'
          TabOrder = 1
          OnClick = BFellerClick
        end
      end
    end
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 216
    Top = 9
  end
end
