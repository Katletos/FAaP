program Project3;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  N = 6;

  Arr: array [1 .. N, 1 .. N] of integer = ((1, 2, 3, 4, 5, 6),
    (1, 2, 3, 4, 5, 6), (1, 2, 3, 4, 5, 6), (1, 2, 3, 4, 5, 6),
    (1, 2, 3, 4, 5, 6), (1, 2, 3, 4, 5, 66));

  {
    Arr: array [1 .. N, 1 .. N] of integer = (
    (-1, 2, 3, -2, 5),
    (1, 5, 9, 4, 7),
    (-8, 2, -3, 6, 5),
    (0, -5, 3, 4, -5),
    (1, 2, 9, 4, -1));
  }

  {
    Arr: array [1 .. N , 1 .. N] of integer = (
    (-1, 2, 3),
    (1, 5, 9),
    (-8, 2, -3));
  }

type
  TArr = array [1 .. N, 1 .. N] of integer;

var
  i, j, k, MaxSum, Sum: integer;
  // Arr: TArr;

BEGIN

  // i - строка, j - столбец
  { заполнение матрицы }
  // for i := 1 to N do
  // for j := 1 to N do
  // begin
  // randomize;
  // Arr[i, j] := Random(10) - 5;
  // end;

  { вывод матрицы }
  for i := 1 to N do
  begin
    for j := 1 to N do
    begin
      write(Arr[i, j]:3);
    end;
    writeln;
  end;

  { k - расстояние от побочной диагонали
    j - номер столбца }
  MaxSum := abs(Arr[1, 1]);
  // writeln('Суммы модулей диагоналей:');
  for k := N - 1 downto -N + 1 do // A
  begin
    Sum := 0;
    for j := 1 to N do // B
    begin
      if (j - k > 0) and (j - k <= N) then
        Sum := Sum + abs(Arr[j - k, N - j + 1]);
    end;
    // writeln(N - k:2, ' = ', Sum);

    if Sum > MaxSum then
      MaxSum := Sum;
  end;
  writeln('Максимальная сумма модулей элементов на диагоналях, параллельных побочной = ',
    MaxSum);

  readln;

END.
