program Laba3;
{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  e1 = 0.01;
  e2 = 0.001;

type
  TInt = function(const x: real): real;

function Int_1(const x: real): real;
begin
  Result := sqrt(0.5 * x + 2) / (sqrt(2 * x * x + 1) + 0.8);
end;

function Int_2(const x: real): real;
begin
  Result := cos(0.8 * x + 1.2) / (1.5 + sin(x * x + 0.6));
end;

function Int_3(const x: real): real;
begin
  Result := 1 / sqrt(x * x + 3.2);
end;

function Int_4(const x: real): real;
begin
  Result := (x + 1) * sin(x);
end;

Function RightRectangle(Integ: TInt; a, b, e: real; var n: integer): real;
var
  Integral, h, x, Prev: real;
  I: integer;
begin
  n := 0;
  Integral := Integ(a) * (b - a);
  repeat
    inc(n, 5);
    h := (b - a) / n;

    Prev := Integral;
    Integral := 0;
    x := a;

    for I := 1 to n do
    begin
      x := x + h;
      Integral := Integral + Integ(x);
    end;

    Integral := Integral * h;
  until abs(abs(Integral) - abs(Prev)) < e;
  Result := Integral;
end;

Function CenterRectangle(Integ: TInt; a, b, e: real; var n: integer): real;
var
  Integral, h, x, Prev: real;
  I: integer;
begin
  n := 0;
  Integral := Integ(a) * (b - a);
  repeat
    inc(n, 5);
    h := (b - a) / n;

    Prev := Integral;
    Integral := 0;
    x := a + h / 2;

    for I := 0 to n - 1 do
    begin
      x := x + h;
      Integral := Integral + Integ(x);
    end;

    Integral := Integral * h;
  until abs(abs(Integral) - abs(Prev)) < e;
  Result := Integral;
end;

var
  n: integer;

Begin
  Writeln('|               |               1 - method               |                 2 - method              |');
  Writeln('|               |----------------------------------------------------------------------------------|');
  Writeln('|               |     e=10^(-2)     |      e=10^(-3)     |     e=10^(-2)      |     e=10^(-3)      |');
  Writeln('|               |----------------------------------------------------------------------------------|');
  Writeln('|               |    value    |  N  |     value    |  N  |     value    |  N  |     value    |  N  |');
  Writeln('|--------------------------------------------------------------------------------------------------|');

  Writeln('| 1st integral  |', RightRectangle(Int_1, 0.4, 1.2, e1, n):12:8,
    ' | ', n:3, ' | ', RightRectangle(Int_1, 0.4, 1.2, e2, n):12:8, ' | ', n:3,
    ' | ', CenterRectangle(Int_1, 0.4, 1.2, e1, n):12:8, ' | ', n:3, ' | ',
    CenterRectangle(Int_1, 0.4, 1.2, e2, n):12:8, ' | ', n:3, ' |');
  Writeln('|--------------------------------------------------------------------------------------------------|');

  Writeln('| 2nd integral  |', RightRectangle(Int_2, 0.3, 0.9, e1, n):12:8,
    ' | ', n:3, ' | ', RightRectangle(Int_2, 0.3, 0.9, e2, n):12:8, ' | ', n:3,
    ' | ', CenterRectangle(Int_2, 0.3, 0.9, e1, n):12:8, ' | ', n:3, ' | ',
    CenterRectangle(Int_2, 0.3, 0.9, e2, n):12:8, ' | ', n:3, ' |');
  Writeln('|--------------------------------------------------------------------------------------------------|');

  Writeln('| 3rd integral  |', RightRectangle(Int_3, 1.2, 2.7, e1, n):12:8,
    ' | ', n:3, ' | ', RightRectangle(Int_3, 1.2, 2.7, e2, n):12:8, ' | ', n:3,
    ' | ', CenterRectangle(Int_3, 1.2, 2.7, e1, n):12:8, ' | ', n:3, ' | ',
    CenterRectangle(Int_3, 1.2, 2.7, e2, n):12:8, ' | ', n:3, ' |');
  Writeln('|--------------------------------------------------------------------------------------------------|');

  Writeln('| 4th integral  |', RightRectangle(Int_4, 1.6, 2.4, e1, n):12:8,
    ' | ', n:3, ' | ', RightRectangle(Int_4, 1.6, 2.4, e2, n):12:8, ' | ', n:3,
    ' | ', CenterRectangle(Int_4, 1.6, 2.4, e1, n):12:8, ' | ', n:3, ' | ',
    CenterRectangle(Int_4, 1.6, 2.4, e2, n):12:8, ' | ', n:3, ' |');
  Writeln('|--------------------------------------------------------------------------------------------------|');
  readln;

End.
