object fWindow: TfWindow
  Left = 0
  Top = 0
  Caption = 'Window'
  ClientHeight = 354
  ClientWidth = 751
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PCursor: TPanel
    Left = 0
    Top = 0
    Width = 751
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LCursor: TLabel
      Left = 16
      Top = 5
      Width = 12
      Height = 13
      Caption = '-!-'
    end
  end
  object SGInventary: TStringGrid
    Left = 0
    Top = 25
    Width = 751
    Height = 329
    Align = alClient
    ColCount = 1
    DefaultColWidth = 300
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
    PopupMenu = PMWindow
    TabOrder = 1
    OnDrawCell = SGInventaryDrawCell
    OnMouseDown = SGInventaryMouseDown
  end
  object Trefresh: TTimer
    Enabled = False
    OnTimer = TrefreshTimer
    Left = 31
    Top = 79
  end
  object PMWindow: TPopupMenu
    Left = 120
    Top = 88
    object Inventoryaction1: TMenuItem
      Caption = 'Inventory action'
      OnClick = Inventoryaction1Click
    end
  end
end
