program laba3;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

var
  x, f1, f2, E, sinus, slt, slp, z, squareSin: real;
  k, i: integer;

begin
  writeln('|     x     |   f1(x)   |       E = 0.01        |       E = 0.001       |       E = 0.0001      |');
  writeln('|           |           |_______________________|_______________________|_______________________|');
  writeln('|           |           |   f2(x)   |     N     |   f2(x)   |     N     |   f2(x)   |     N     |');
  writeln('|___________|___________|___________|___________|___________|___________|___________|___________|');

  x := 0.04;

  for i := 1 to 20 do // A
  begin
    sinus := sin(x);
    squareSin := sinus * sinus;
    z := 2 * x;

    // вычисление f1 (значение для первого столбца)
    f1 := cos(z) - (PI / 2 - x) * sin(z) + squareSin * ln(4 * squareSin);

    write('|   ', x:5:2, '   |');
    write(' ', f1:8:5, '  |');

    slt := 0;
    k := 0;
    f2 := 0;
    E := 0.01;

    while (E > 0.0001) do // В
    begin
      repeat // С
        k := k + 1;
        slp := slt;
        // вычисление текущего слогаемого
        slt := cos(z * (k + 1)) / (k * (k + 1));
        f2 := f2 + slt; // вычисление f2

      until abs(slp - slt)  < E;

      write(' ', f2:8:5, '  |');
      write('    ', k:2, '     |');

      E := E / 10; // изменение точности
    end;

    writeln;
    writeln('|___________|___________|___________|___________|___________|___________|___________|___________|');

    x := x + 0.04;
  end;

  readln;

end.
