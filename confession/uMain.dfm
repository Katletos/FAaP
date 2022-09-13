object frmMain: TfrmMain
  Left = 490
  Top = 228
  Caption = 'Form1'
  ClientHeight = 601
  ClientWidth = 948
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  TextHeight = 15
  object crtMain: TChart
    Left = 0
    Top = 0
    Width = 948
    Height = 522
    Title.Text.Strings = (
      'TChart')
    Shadow.Visible = False
    View3D = False
    View3DOptions.Orthogonal = False
    Align = alClient
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      25
      15
      25)
    ColorPaletteIndex = 13
    object srMain: TFastLineSeries
      HoverElement = []
      LinePen.Color = clRed
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {0000000000}
      Detail = {0000000000}
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 522
    Width = 948
    Height = 79
    Align = alBottom
    Caption = 'Panel1'
    TabOrder = 1
    object btnCalc: TButton
      AlignWithMargins = True
      Left = 869
      Top = 4
      Width = 75
      Height = 71
      Align = alRight
      Caption = 'Build'
      TabOrder = 0
      OnClick = btnCalcClick
    end
    object edtExpr: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 859
      Height = 71
      Align = alClient
      TabOrder = 1
      ExplicitHeight = 23
    end
  end
end
