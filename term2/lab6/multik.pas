unit multik;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, mmsystem,
  Animation, Vcl.MPlayer;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TScene = array of TAnimObject;

var
  Form1: TForm1;
  pos1, pos2, pos3: THuman;
  sHuman: THuman;
  t: real;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
const
  FileName = 'swimming.wav';
begin
  //
  pos1 := THuman.DefaultTPose;
  pos2 := THuman.DefaultTPose;
  pos3 := THuman.DefaultTPose;

  pos1.Transform.pos.x := 50;
  pos1.Transform.pos.y := 750;

  pos2.Transform.pos.x := 1000;
  pos2.Transform.pos.y := 850;
  pos2.Transform.scale := 0.5;

  pos3.Transform.pos.x := 1920;
  pos3.Transform.pos.y := 750;
  pos3.Transform.scale := 2;

  // pos1
  pos1.Neck.setangle(0);
  pos1.Torso.setangle(0);

  pos1.RUpperarm.setangle(deg2rad(45));
  pos1.RForearm.setangle(deg2rad(45));

  pos1.LUpperarm.setangle(deg2rad(225)); //
  pos1.LForearm.setangle(deg2rad(170)); //

  pos1.LThigh.setangle(deg2rad(165));
  pos1.LShin.setangle(deg2rad(185));
  pos1.RThigh.setangle(deg2rad(170));
  pos1.RShin.setangle(deg2rad(190));

  // pos2
  pos2.Neck.setangle(0);
  pos2.Torso.setangle(0);

  pos2.RUpperarm.setangle(deg2rad(155));
  pos2.RForearm.setangle(deg2rad(35)); //

  pos2.LUpperarm.setangle(deg2rad(335)); //
  pos2.LForearm.setangle(deg2rad(15)); //

  pos2.LThigh.setangle(deg2rad(170));
  pos2.LShin.setangle(deg2rad(190));
  pos2.RThigh.setangle(deg2rad(165));
  pos2.RShin.setangle(deg2rad(185));

  //
  pos3.Neck.setangle(0);
  pos3.Torso.setangle(0);

  pos3.RUpperarm.setangle(deg2rad(210));
  pos3.RForearm.setangle(deg2rad(-5));

  pos3.LUpperarm.setangle(deg2rad(360 + 40)); //
  pos3.LForearm.setangle(deg2rad(45)); //

  pos3.LThigh.setangle(deg2rad(165));
  pos3.LShin.setangle(deg2rad(185));
  pos3.RThigh.setangle(deg2rad(170));
  pos3.RShin.setangle(deg2rad(190));

  sHuman := THuman.DefaultTPose;
  sndPlaySound(pchar(FileName), { 0, } SND_ASYNC or SND_FILENAME or SND_LOOP);
end;

procedure TForm1.Timer1Timer(Sender: TObject);

var
  i: integer;
begin
  // Update
  if (t <= 0.5) then
  begin
    t := t + 0.01;
    sHuman.Interpolate(pos1, pos2, t * 2);
    PaintBox1.Repaint; // Call Render
  end
  else if (t < 1) and (t > 0.5) then
  begin
    t := t + 0.01;
    sHuman.Interpolate(pos2, pos3, t * 2 - 1);
    PaintBox1.Repaint; // Call Render
  end // invalidate
  else
  begin
    t := 0;
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);

var
  j, i: integer;
begin
  // Render

  // pos1.Draw(canvas);
  // pos2.Draw(canvas);
  // pos3.Draw(canvas);

  // whater
  Canvas.brush.Color := clNavy;
  Canvas.FillRect(rect(0, 542, 1920, 1080));

  // горизонтальные линии плитки
  for i := 0 to 9 do
  begin
    Canvas.MoveTo(0, 60 * i);
    Canvas.LineTo(1920, 60 * i);
  end;

  // вертикальные линии плитки
  for i := 0 to 32 do
  begin
    Canvas.MoveTo(60 * i, 0);
    Canvas.LineTo(60 * i, 540);
  end;

  // olympic rings
  Canvas.brush.Color := clSkyBlue;
  PaintBox1.Canvas.brush.Color := clSkyBlue;
  PaintBox1.Canvas.Pen.Width := 2;
  Canvas.FillRect(rect(780, 120, 1020, 300));
  PaintBox1.Canvas.Pen.Color := clBlue;
  PaintBox1.Canvas.Ellipse(790, 150, 860, 220);
  PaintBox1.Canvas.Pen.Color := clBlack;
  PaintBox1.Canvas.Ellipse(860, 150, 930, 220);
  PaintBox1.Canvas.Pen.Color := clRed;
  PaintBox1.Canvas.Ellipse(930, 150, 1000, 220);
  PaintBox1.Canvas.Pen.Color := clYellow;
  PaintBox1.Canvas.Ellipse(825, 210, 895, 280);
  PaintBox1.Canvas.Pen.Color := clGreen;
  PaintBox1.Canvas.Ellipse(895, 210, 965, 280);

  Canvas.Pen.Width := 1;

  for i := 1 to 140 do
  begin
    PaintBox1.Canvas.brush.Color := clYellow;
    PaintBox1.Canvas.Pen.Color := clBlack;
    PaintBox1.Canvas.Ellipse(15 * (i - 1), 600, 30 + 15 * (i - 1), 650);
  end;

  for i := 1 to 140 do
  begin
    PaintBox1.Canvas.brush.Color := clMoneyGreen;
    PaintBox1.Canvas.Pen.Color := clBlack;
    PaintBox1.Canvas.Ellipse(15 * (i - 1), 950, 30 + 15 * (i - 1), 1000);
  end;

  Canvas.Pen.Width := 3;
  Canvas.brush.Color := clBlack;
  sHuman.Draw(Canvas);
end;

end.
