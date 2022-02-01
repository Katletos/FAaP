program Project2;
{$APPTYPE CONSOLE}
{$R *.res}

const
  EPSILON = 0.000001;

var
  n: integer;
  x: real;
  f: real;
  s: real;

begin
  f := 0;
  x := 0.6;
  repeat // Cycle A
  begin
    s := 0;
    for n := 1 to 15 do // Cycle B
    begin
      s := s + (ln(abs(x)) / (2 - 1 / n)); // Ñalculation s
      if n >= 10 then
      begin
        // Ñalculation f using n(10+) and formula
        f := (n * sqrt(n * x) * exp(1 / 3 * ln(x * x))) + s;
        writeln('| n = ', n, ' | x = ', x:3:2, ' | f = ', f:8:5, ' |');
      end;
    end;
    x := x + 0.25;
  end;
  until x > 1.1 + EPSILON;

  readln;

end.
