program lab5;

// являются ли присвоения опорного элемента перестановкой или сравнением?
uses
  System.SysUtils;

const
  N = 10000;

type
  TArr = array [1 .. N] of integer;

procedure ArrFill(var arr: TArr);
const
  SIZE: integer = N;
var
  i: integer;
begin
  randomize;
  for i := 1 to SIZE do
  begin
    arr[i] := random(100);
  end;
end;

procedure ArrSwap(var arr: TArr; const SIZE: integer);
var
  i, swap, EndPoint: integer;
begin
  EndPoint := SIZE div 2;
  for i := 1 to EndPoint do
  begin
    swap := arr[i];
    arr[i] := arr[SIZE - i + 1];
    arr[SIZE - i + 1] := swap;
  end;
end;

procedure SelectSort(var arr: TArr; const SIZE: integer);
var
  i, j, min, tmp, NumberOfSwap, NumberOfComp: integer;
begin
  NumberOfComp := 0;
  NumberOfSwap := 0;

  for i := 1 to SIZE - 1 do
  begin
    min := i;

    for j := i + 1 to SIZE do
    begin
      NumberOfComp := NumberOfComp + 1;
      if arr[j] < arr[min] then
      begin
        min := j;
      end;
    end;

    tmp := arr[i];
    arr[i] := arr[min];
    arr[min] := tmp;

    NumberOfSwap := NumberOfSwap + 1; //
  end;
  write(NumberOfSwap:11, '|', NumberOfComp:11, '|');
  // for i := 1 to SIZE do
  // begin
  // write(arr[i], ' ');
  // end;
end;

procedure ShellSort(var arr: TArr; const SIZE: integer);
var
  step, NumberOfSwap, NumberOfComp: integer;
  i, tmp: integer; // вспомогательные переменные
  k: boolean; // признак перестановки
begin
  NumberOfComp := 0;
  NumberOfSwap := 0;

  step := SIZE div 2; // шаг сортировки
  while (step > 0) do
  begin
    k := True; // пока есть перестановки
    while k = True do
    begin
      k := False;
      i := 1;
      for i := 1 to SIZE - step do
      begin
        NumberOfComp := NumberOfComp + 1;
        // сравнение элементов на интервале step
        if (arr[i] > arr[i + step]) then
        begin
          tmp := arr[i];
          arr[i] := arr[i + step];
          arr[i + step] := tmp;
          k := True;

          NumberOfSwap := NumberOfSwap + 1;
        end;
      end;
    end;
    { сокращаем шаг сортировки в 2 раза }
    step := step div 2;
  end;

  writeln(NumberOfSwap:11, '|', NumberOfComp:11, '|');
  // for i := 1 to SIZE do
  // begin
  // write(arr[i], ' ');
  // end;
end;

var
  SelectSortArr, ShellSortArr, DefaultArr: TArr;
  SortedArrSize, i: integer;

begin
  writeln('|        Array       |     Selection Sort    |      Shell Sort       |');
  writeln('|        type        |_______________________|_______________________|');
  writeln('|                    |    Swap   |Comparisons|    Swap   |Comparisons|');
  writeln('|____________________|___________|___________|___________|___________|');

  ArrFill(DefaultArr);

  SortedArrSize := 10;

  for i := 1 to 3 do // Cycle H
  begin
    SelectSortArr := DefaultArr;
    ShellSortArr := DefaultArr;

    // Неотсортированныей массивы
    write('|Unsorted, ', SortedArrSize:4, ' memb.|');
    SelectSort(SelectSortArr, SortedArrSize);
    ShellSort(ShellSortArr, SortedArrSize);
    writeln('|____________________|___________|___________|___________|___________|');

    // Отсортированнный массив
    write('|Sorted, ', SortedArrSize:4, ' memb.  |');
    SelectSort(SelectSortArr, SortedArrSize);
    ShellSort(ShellSortArr, SortedArrSize);
    writeln('|____________________|___________|___________|___________|___________|');

    // Инвертированный массив
    ArrSwap(SelectSortArr, SortedArrSize);
    ArrSwap(ShellSortArr, SortedArrSize);

    write('|Inversed, ', SortedArrSize:4, ' memb.|');
    SelectSort(SelectSortArr, SortedArrSize);
    ShellSort(ShellSortArr, SortedArrSize);
    writeln('|____________________|___________|___________|___________|___________|');

    case SortedArrSize of
      10:
        begin
          ArrSwap(SelectSortArr, SortedArrSize);
          ArrSwap(ShellSortArr, SortedArrSize);
          SortedArrSize := 100;
        end;
      100:
        begin
          ArrSwap(SelectSortArr, SortedArrSize);
          ArrSwap(ShellSortArr, SortedArrSize);
          SortedArrSize := 2000;
        end;
    end;
  end;

  readln;

end.
