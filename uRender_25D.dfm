object Render_25D: TRender_25D
  Left = 0
  Top = 0
  Width = 624
  Height = 261
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object PBDraw: TPaintBox
    Left = 0
    Top = 25
    Width = 624
    Height = 236
    Align = alClient
    PopupMenu = pmMap
    OnMouseDown = PBDrawMouseDown
    OnMouseLeave = PBDrawMouseLeave
    OnMouseMove = PBDrawMouseMove
    ExplicitLeft = 216
    ExplicitTop = 152
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object PMapCtrl: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object SBMapUpdate: TSpeedButton
      Left = 3
      Top = 1
      Width = 23
      Height = 22
      Caption = 'O'
    end
    object LMY: TLabel
      Left = 32
      Top = 4
      Width = 6
      Height = 13
      Caption = 'Y'
    end
    object LMX: TLabel
      Left = 97
      Top = 4
      Width = 6
      Height = 13
      Caption = 'X'
    end
    object LMZ: TLabel
      Left = 169
      Top = 4
      Width = 6
      Height = 13
      Caption = 'Z'
    end
    object SBPosFill: TSpeedButton
      Left = 384
      Top = 1
      Width = 17
      Height = 22
      Caption = '.'
      OnClick = SBPosFillClick
    end
    object SBDirectionLeft: TSpeedButton
      Left = 260
      Top = 1
      Width = 23
      Height = 22
      Caption = ')'
      OnClick = SBDirectionLeftClick
    end
    object SBDirectionRight: TSpeedButton
      Left = 236
      Top = 1
      Width = 23
      Height = 22
      Caption = '('
      OnClick = SBDirectionLeftClick
    end
    object SEMY: TSpinEdit
      Left = 42
      Top = 1
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object SEMX: TSpinEdit
      Left = 109
      Top = 1
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object SEMZ: TSpinEdit
      Left = 181
      Top = 1
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
    object SEMBS: TSpinEdit
      Left = 325
      Top = 1
      Width = 53
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 20
    end
    object CBUpdate: TCheckBox
      Left = 407
      Top = 3
      Width = 58
      Height = 17
      Caption = 'Update'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = CBUpdateClick
    end
    object CMCamCenter: TCheckBox
      Left = 471
      Top = 3
      Width = 82
      Height = 17
      Caption = 'Cam. center'
      TabOrder = 5
    end
  end
  object RefreshMap: TTimer
    OnTimer = RefreshMapTimer
    Left = 24
    Top = 48
  end
  object pmMap: TPopupMenu
    OnPopup = pmMapPopup
    Left = 90
    Top = 48
    object MOpen: TMenuItem
      Caption = 'Left'
      OnClick = MOpenClick
    end
    object Right1: TMenuItem
      Caption = 'Right'
      OnClick = Right1Click
    end
    object Eat1: TMenuItem
      Tag = 5
      Caption = 'Eat'
      OnClick = Eat1Click
    end
    object NPoint: TMenuItem
      Caption = 'Set point'
      OnClick = NPointClick
    end
  end
end
