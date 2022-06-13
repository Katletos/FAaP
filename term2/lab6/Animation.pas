unit Animation;

interface

uses
  Vcl.Graphics, System.Types;
// Vcl.Graphics -> TCanvas
// System.Types -> TPoint

// https://docwiki.embarcadero.com/Libraries/Sydney/en/System.Types.TPoint

type
  TPos = record
    x, y: real;
    constructor Create(x, y: real);
    procedure Interpolate(const First, Second: TPos; t: real);
    class operator Add(const Lhs, Rhs: TPos): TPos;
  end;

  TTransform = record
    pos: TPos;
    rotation: real;
    scale: real;

    constructor Create(const pos: TPos; const rotation, scale: real); overload;
    constructor Create(const pos: TPos); overload;
    procedure Interpolate(const First, Second: TTransform; t: real);
    function ScaleRotate(const Point: TPos): TPos;
  end;

  TAnimObject = class
    Transform: TTransform;
    procedure Interpolate(const First, Second: TAnimObject; t: real);
    procedure Draw(Canvas: TCanvas); virtual;
  end;

  TCircle = class(TAnimObject)
    radius: real;
    constructor Create(x, y, radius: real);
    procedure Interpolate(const First, Second: TCircle; t: real);
    procedure Draw(Canvas: TCanvas); override;
  end;

  TLimb = class
    angle: real;
    len: real;
    dPos: TPos;
    aPos: TPos;
    procedure CalcDPos;
    procedure SetAngle(Iangle: real);
    procedure Interpolate(const First, Second: TLimb; t: real);
    constructor Create(Iangle: real; Ilen: real);
  end;

  THuman = class(TAnimObject)
  private
    Limbs: array [0 .. 9] of TLimb;

  public
    head_size: real;

    property LForearm: TLimb read Limbs[0] write Limbs[0];
    property RForearm: TLimb read Limbs[1] write Limbs[1];
    property LUpperarm: TLimb read Limbs[2] write Limbs[2];
    property RUpperarm: TLimb read Limbs[3] write Limbs[3];
    property LThigh: TLimb read Limbs[4] write Limbs[4];
    property RThigh: TLimb read Limbs[5] write Limbs[5];
    property LShin: TLimb read Limbs[6] write Limbs[6];
    property RShin: TLimb read Limbs[7] write Limbs[7];
    property Torso: TLimb read Limbs[8] write Limbs[8];
    property Neck: TLimb read Limbs[9] write Limbs[9];

    procedure Draw(Canvas: TCanvas);
    procedure Update;
    procedure Interpolate(const First, Second: THuman; t: real);
    Constructor DefaultTPose;
  end;

procedure Circle(Canvas: TCanvas; x, y, r: real);
function Deg2Rad(deg: real): real;

implementation

procedure TAnimObject.Draw(Canvas: TCanvas);
begin

end;

procedure Circle(Canvas: TCanvas; x, y, r: real);
begin
  Canvas.Ellipse(round(x - r), round(y - r), round(x + r), round(y + r));
end;

function Deg2Rad(deg: real): real;
begin
  result := deg * Pi / 180;
end;

// Linear interpolation
function lerp(v0, v1, t: real): real;
begin
  result := v0 + t * (v1 - v0);
end;

procedure RotateScale(var x, y: real; scale, angle: real);
var
  nx, ny: real;
  s, c: real;
begin
  s := sin(angle);
  c := cos(angle);

  nx := x * c - y * s;
  ny := x * s + y * c;
  x := nx * scale;
  y := ny * scale;
end;

constructor TPos.Create(x: real; y: real);
begin
  Self.x := x;
  Self.y := y;
end;

class operator TPos.Add(const Lhs, Rhs: TPos): TPos;
begin
  result.x := Lhs.x + Rhs.x;
  result.y := Lhs.y + Rhs.y;
end;

procedure TPos.Interpolate(const First, Second: TPos; t: real);
begin
  Self.x := lerp(First.x, Second.x, t);
  Self.y := lerp(First.y, Second.y, t);
end;

procedure TAnimObject.Interpolate(const First, Second: TAnimObject; t: real);
begin
  Transform.Interpolate(First.Transform, Second.Transform, t);
end;

constructor TTransform.Create(const pos: TPos; const rotation, scale: real);
begin
  Self.pos := pos;
  Self.rotation := rotation;
  Self.scale := scale;
end;

constructor TTransform.Create(const pos: TPos);
begin
  Self.pos := pos;
  Self.rotation := 0;
  Self.scale := 1;
end;

procedure TTransform.Interpolate(const First, Second: TTransform; t: real);
begin
  pos.Interpolate(First.pos, Second.pos, t);
  scale := lerp(First.scale, Second.scale, t);
  rotation := lerp(First.rotation, Second.rotation, t);
end;

function TTransform.ScaleRotate(const Point: TPos): TPos;
var
  nx, ny: real;
  s, c: real;
begin
  s := sin(rotation);
  c := cos(rotation);

  result.x := (Point.x * c - Point.y * s) * scale;
  result.y := (Point.x * s + Point.y * c) * scale;
end;

constructor TCircle.Create(x, y, radius: real);
begin
  Self.Transform := TTransform.Create(TPos.Create(x, y), 0, 1);
  Self.radius := radius;
end;

procedure TCircle.Draw(Canvas: TCanvas);
var
  r: real;
begin
  r := radius * Transform.scale;
  with Transform.pos do
    Canvas.Ellipse(round(x - r), round(y - r), round(x + r), round(y + r));
end;

procedure TCircle.Interpolate(const First: TCircle;
  const Second: TCircle; t: real);
begin
  inherited Interpolate(First, Second, t);
  radius := lerp(First.radius, Second.radius, t);
end;

constructor TLimb.Create(Iangle: real; Ilen: real);
begin
  angle := Iangle;
  len := Ilen;
  CalcDPos;
end;

procedure TLimb.CalcDPos;
begin
  dPos.x := len * cos(angle);
  dPos.y := len * sin(angle);
end;

procedure TLimb.SetAngle(Iangle: real);
begin
  angle := Iangle;
  CalcDPos;
end;

procedure TLimb.Interpolate(const First: TLimb; const Second: TLimb; t: real);
begin
  Self.len := lerp(First.len, Second.len, t);
  SetAngle(lerp(First.angle, Second.angle, t));
end;

constructor THuman.DefaultTPose;
const
  DEFAULT_X = 400;
  DEFAULT_Y = 300;

  cHEAD_SIZE = 10;

  cNECK_LEN = 20;
  cTORSO_LEN = 50;
  cARMS_LEN = 50;
  cLEGS_LEN = 100;

  angle_UP = -90;
begin
  Transform := TTransform.Create(TPos.Create(DEFAULT_X, DEFAULT_Y));
  head_size := cHEAD_SIZE;

  Torso := TLimb.Create(Deg2Rad(angle_UP), cTORSO_LEN);
  Neck := TLimb.Create(Deg2Rad(angle_UP), cNECK_LEN);

  LUpperarm := TLimb.Create(Deg2Rad(120), cARMS_LEN);
  RUpperarm := TLimb.Create(Deg2Rad(60), cARMS_LEN);
  LForearm := TLimb.Create(Deg2Rad(90), cARMS_LEN);
  RForearm := TLimb.Create(Deg2Rad(90), cARMS_LEN);

  LThigh := TLimb.Create(Deg2Rad(70), cLEGS_LEN);
  LShin := TLimb.Create(Deg2Rad(90), cLEGS_LEN);
  RThigh := TLimb.Create(Deg2Rad(110), cLEGS_LEN);
  RShin := TLimb.Create(Deg2Rad(90), cLEGS_LEN);
end;

procedure THuman.Interpolate(const First, Second: THuman; t: real);
var
  I: Integer;
begin
  inherited Interpolate(First, Second, t);
  head_size := lerp(First.head_size, Second.head_size, t);

  for I := Low(Limbs) to High(Limbs) do
  begin
    Limbs[I].Interpolate(First.Limbs[I], Second.Limbs[I], t);
  end;
end;

procedure THuman.Update;
var
  tp: TPos;
begin
  with Transform do
  begin
    Torso.aPos := Transform.pos + ScaleRotate(Torso.dPos);
    Neck.aPos := Torso.aPos + ScaleRotate(Neck.dPos);

    LUpperarm.aPos := Torso.aPos + ScaleRotate(LUpperarm.dPos);
    RUpperarm.aPos := Torso.aPos + ScaleRotate(RUpperarm.dPos);

    LForearm.aPos := LUpperarm.aPos + ScaleRotate(LForearm.dPos);
    RForearm.aPos := RUpperarm.aPos + ScaleRotate(RForearm.dPos);

    LThigh.aPos := Transform.pos + ScaleRotate(LThigh.dPos);
    RThigh.aPos := Transform.pos + ScaleRotate(RThigh.dPos);

    LShin.aPos := LThigh.aPos + ScaleRotate(LShin.dPos);
    RShin.aPos := RThigh.aPos + ScaleRotate(RShin.dPos);
  end;
end;

procedure THuman.Draw(Canvas: TCanvas);
var
  LastPos: TPoint;
  tp: TPos;
begin
  Self.Update;
  with Canvas do
  begin
    MoveTo(round(Transform.pos.x), round(Transform.pos.y));

    LineTo(round(Torso.aPos.x), round(Torso.aPos.y)); // Torso
    LineTo(round(Neck.aPos.x), round(Neck.aPos.y)); // Neck
    Circle(Canvas, round(Neck.aPos.x), round(Neck.aPos.y),
      round(head_size * Transform.scale)); // Head

    MoveTo(round(Torso.aPos.x), round(Torso.aPos.y)); // Back to shoulders
    LineTo(round(LUpperarm.aPos.x), round(LUpperarm.aPos.y)); // Left arm
    LineTo(round(LForearm.aPos.x), round(LForearm.aPos.y));

    MoveTo(round(Torso.aPos.x), round(Torso.aPos.y)); // Back to shoulders
    LineTo(round(RUpperarm.aPos.x), round(RUpperarm.aPos.y)); // Right arm
    LineTo(round(RForearm.aPos.x), round(RForearm.aPos.y));

    MoveTo(round(Transform.pos.x), round(Transform.pos.y)); // Back to origin
    LineTo(round(LThigh.aPos.x), round(LThigh.aPos.y)); // Left leg
    LineTo(round(LShin.aPos.x), round(LShin.aPos.y));

    MoveTo(round(Transform.pos.x), round(Transform.pos.y)); // Back to origin
    LineTo(round(RThigh.aPos.x), round(RThigh.aPos.y)); // Right leg
    LineTo(round(RShin.aPos.x), round(RShin.aPos.y));
  end;
end;

end.
