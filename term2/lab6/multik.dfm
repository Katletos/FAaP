object Form1: TForm1
  Left = 490
  Top = 83
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 835
  ClientWidth = 1211
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  TextHeight = 13
  object PaintBox1: TPaintBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1205
    Height = 829
    Align = alClient
    OnPaint = PaintBox1Paint
    ExplicitLeft = 8
    ExplicitTop = 8
  end
  object Timer1: TTimer
    Interval = 41
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
end
