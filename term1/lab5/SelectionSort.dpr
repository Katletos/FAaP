program SelectionSort;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  N = 10;

type
  mas = array [1 .. N] of integer;

var
  A: mas;
  i, j, min, tmp: integer;

begin
  writeln('Enter 10 values: ');
  for i := 1 to N do
  begin
    write('Element №', i, ': ');
    readln(A[i]);
  end;

  for i := 1 to N - 1 do
  begin
    min := i;

    for j := i + 1 to N do
      if A[j] < A[min] then
        min := j;

    tmp := A[i];
    A[i] := A[min];
    A[min] := tmp;
  end;

  for i := 1 to N do
  begin
    writeln('Element № ', i, ' Value: ', A[i]);
  end;

  readln;

end.
