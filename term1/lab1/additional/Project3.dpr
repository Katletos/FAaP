program Project1;
{$APPTYPE CONSOLE}

uses
  SysUtils;

var
  x, s, l: extended;
  i: integer;

begin
  x := 0.5;
  while x <= 0.8 + 0.0001 do // цикл А
  begin
    s := exp(1 / 3 * ln(x)) + (x * x * (x - 2)) / sqrt(x);
    for i := 3 to 9 do // цикл В
    begin
      l := exp(1 / (i + 1) * ln(x)) + exp(i * ln(x)) * (x - i) / s;
      s := l;
    end;
    l := exp(10 * ln(x)) * (x - 10) / s;
    writeln(x:12:5, l:12:5);
    x := x + 0.05;
  end;
  writeln('Press "enter" to exit');
  readln;

end.
