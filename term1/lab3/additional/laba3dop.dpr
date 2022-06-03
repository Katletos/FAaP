program laba3dop;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var
  f, x, chsl, slt, slp, znmn: real;
  pr, k: integer;

begin
  pr := 1;
  while pr <= 8 do // А
  begin
    write('Enter X in diapazone from -0.98 to 0.98: ');
    read(x);
    if 0.98 >= abs(x) then // 0.98 из-за сходимости ряда
    begin
      chsl := 1;
      znmn := 1;
      slt := 1;
      f := 1;
      k := 0;
      repeat // В
      begin
        slp := slt;
        k := k + 1;
        chsl := -chsl * (2 * k - 1) * x;
        znmn := znmn * 2 * k;
        slt := chsl / znmn;
        f := f + slt;
      end;
      until abs(abs(slp) - abs(slt)) < 0.0001;         //
      writeln('f(', x:3:2, ') = ', f:5:4);
      pr := pr + 1;
    end
    else
    begin
      writeln('Oops! Bad value! For a given value of x, the series is not convergent!');
    end;
  end;

  writeln('Press ENTER to exit.');
  readln;

end.
