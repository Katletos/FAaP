program Project1;
{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  EPSILON = 0.00000000001;

var
  Str: string;
  Error: integer;
  Sign: integer;
  i: integer;
  a: extended;
  b: extended;
  h: extended;
  y: extended;
  x: extended;

begin

  // Cycle А

  repeat
    write('Enter а: ');
    readln(Str);
    val(Str, a, Error);
    writeln;
  until Error = 0;

  repeat
    write('Enter b: ');
    readln(Str);
    val(Str, b, Error);
    writeln;
  until Error = 0;

  repeat
    write('Enter step h: ');
    readln(Str);
    val(Str, h, Error);
    writeln;
  until Error = 0;
  {
  if (a < b) and (h > 0) or (a > b) and (h < 0) or (a = b) then
  begin

  end
  else
  begin
    writeln('Incorrect data. Please, try again.');
  end;
           }
  x := a;
  writeln('|  i  |            x             |              y            |');
  writeln('|_____|__________________________|___________________________|');

  i := 0;
  if h > 0 then
  begin
    { }
    while b - x > EPSILON do // Cycle В
    begin
      if x = abs(x) then
        Sign := 1
      else
        Sign := -1;

      if ((x + EPSILON < 0) or (x - EPSILON > 0)) and
        (1.7 * Sign * exp(1 / 3 * ln(abs(x))) + x * Sign *
        exp(1 / 3 * ln(2 / abs(x))) > 0) then
      begin
        i := i + 1;
        y := abs(x - PI) * exp(x / 3) / ln(1.7 * Sign * exp(1 / 3 * ln(abs(x)))
          + x * Sign * exp(1 / 3 * ln(2 / abs(x))));

        writeln('|', i:4, ' | ', x:24:5, ' | ', y:25:5, ' |');
        writeln('|_____|__________________________|___________________________|');

        x := x + h;
      end
      else
      begin
        inc(i);

        writeln('|', i:4, ' | ', x:24:5, ' | ',
          'Definition does not exist', ' |');
        writeln('|_____|__________________________|___________________________|');

        x := x + h;
      end;
    end;

  end
  else
  begin
    while x - b > EPSILON do // Cycle С
    begin
      if x = abs(x) then
        Sign := 1
      else
        Sign := -1;

      if ((x + EPSILON < 0) or (x - EPSILON > 0)) and
        (1.7 * Sign * exp(1 / 3 * ln(abs(x))) + x * Sign *
        exp(1 / 3 * ln(2 / abs(x))) > 0) then
      begin
        inc(i);
        y := abs(x - PI) * exp(x / 3) / ln(1.7 * Sign * exp(1 / 3 * ln(abs(x)))
          + x * Sign * exp(1 / 3 * ln(2 / abs(x))));

        writeln('|', i:4, ' | ', x:24:5, ' | ', y:25:5, ' |');
        writeln('|_____|__________________________|___________________________|');

        x := x + h;
      end
      else
      begin
        inc(i);
        writeln('|', i:4, ' | ', x:24:5, ' | ',
          'Definition does not exist', ' |');
        writeln('|_____|__________________________|___________________________|');

        x := x + h;
      end;
    end;

  end;

  x := b;

  if x = abs(x) then
    Sign := 1
  else
    Sign := -1;

  if ((x + EPSILON < 0) or (x - EPSILON > 0)) and
    (1.7 * Sign * exp(1 / 3 * ln(abs(x))) + x * Sign *
    exp(1 / 3 * ln(2 / abs(x))) > 0) then
  begin
    i := i + 1;
    y := abs(x - PI) * exp(x / 3) / ln(1.7 * Sign * exp(1 / 3 * ln(abs(x))) + x
      * Sign * exp(1 / 3 * ln(2 / abs(x))));

    writeln('|', i:4, ' | ', x:24:5, ' | ', y:25:5, ' |');
    writeln('|_____|__________________________|___________________________|');

    x := x + h;
  end
  else
  begin
    i := i + 1;
    writeln('|', i:4, ' | ', x:24:5, ' | ', 'Definition does not exist', ' |');
    writeln('|_____|__________________________|___________________________|');
  end;

  readln;

end.
