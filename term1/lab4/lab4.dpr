program laba4;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  N = 5;

type
  TArr = array [1 .. N] of byte;

procedure SelectSort(var Arr: TArr; const SIZE: integer);
var
  i, j, min, Temp: integer;
begin
  for i := 1 to SIZE - 1 do
  begin
    min := i;

    for j := i + 1 to SIZE do
    begin
      if Arr[j] < Arr[min] then
      begin
        min := j;
      end;
    end;

    Temp := Arr[i];
    Arr[i] := Arr[min];
    Arr[min] := Temp;

  end;
end;

var
  i, j, p, Element, Counter, c, z: integer;
  a, b: TArr;

Begin
  randomize;

  { ручное заполнение массива }
  // writeln('Enter 5 values: ');
  // for i := 1 to N do
  // begin
  // write('Element №', i, ': ');
  // readln(a[i]);
  // writeln('Element № ', i, ' Value: ', a[i]);
  // end;

  { генерация массива }
  for i := 1 to N do
  begin
    a[i] := random(4) + 1;
    writeln('Element № ', i, ' Value: ', a[i]);
  end;

  { сортировка массива выбором }
  SelectSort(a, N);

  { вывод отсортированного массива }
  writeln;
  writeln('отсортированный массив:');
  for i := 1 to N do
  begin
    writeln('Element № ', i, ' Value: ', a[i]);
  end;

  { поиск одинаковых элементов }
  i := 1;
  Element := 1;
  while i < N do // А
  begin
    j := i + 1;
    while a[i] = a[j] do // B
    begin
      inc(j);
    end;

    Counter := j - i; // счётчик повторений

    if Counter > 1 then
    begin
      b[Element] := a[i];
      b[Element + 1] := Counter;
      inc(Element, 2);
    end;
    i := j;
  end;

  { вывод массива со значениями повторений }
  writeln;
  writeln('массив со значениями повторений:');
  for i := 1 to N do
  begin
    writeln('Element № ', i, ' Value: ', b[i]);
  end;

  { вывод текста из задания }
  writeln;
  writeln('текст случая:');
  if b[2] = 5 then
  begin
    writeln('1) 5 одинаковых элементов');
  end
  else if b[2] = 4 then
  begin
    writeln('2) 4 одинаковых элемента');
  end
  else if ((b[2] = 3) and (b[4] = 2)) or ((b[2] = 2) and (b[4] = 3)) then
  begin
    writeln('3) 3 и 2 одинаковых элемента');
  end
  else if b[2] = 3 then
  begin
    writeln('4) 3 одинаковых элемента');
  end
  else if (b[2] = 2) and (b[4] = 2) then
  begin
    writeln('5) 2 и 2 одинаковых элемента');
  end
  else if b[2] = 2 then
  begin
    writeln('6) 2 одинаковых элемента');
  end
  else
  begin
    writeln('7) другой случай');
  end;

  readln;

End.
