program _10; 
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows;

const
  N = 10;

type
  TMn = set of 1..100;

var
  X1, X2, X3, Y: TMn;

procedure My_Input(var Mn: TMn; const n: integer; const Name: String);
  var A, i:Integer;
begin
  Mn := [];
  i:=1;
  Writeln('Введите ', n, ' различных элементов множества ', Name, ' (элементы от 1 до 100)');
  Repeat
    Read (A);
    if not ([A] <= Mn) and (A>=1) and (A<=100)  then
    begin
      Mn := Mn + [A];
      inc(i);
    end;
  Until i > n;
  Readln;
end;

procedure My_Output(const Mn: TMn; const Name: String);
var A: Integer;
begin
  Writeln('Множество ', Name, ':');
  for A:= 1 to 100 do
    if A In Mn then
      write(A:5);
  Writeln;
end;

procedure My_Belong (const Mn: TMn; const M:Integer; const Name: String );
begin
  if [M] <= Mn then
    Writeln (M, ' принадлежит множеству ', Name)
  else
    Writeln (M, ' не принадлежит множеству ', Name);
end;

procedure My_Include (const Mn, X: TMn; const NameMn, NameX: String);
begin
  if X <= Mn then
    Writeln ('Множество ',NameX,' входит в множество ', NameMn)
  else
    Writeln ('Множество ',NameX,' не входит в множество ', NameMn);
end;


begin
  SetConsoleCP(1251);
  SetConsoleOutPutCP(1251);

  My_Input(X1, N, 'X1');
  My_Input(X2, N, 'X2');
  My_Input(X3, N, 'X3');

  Y := (X1 * X2) + (X2 * X3);

  My_Output(X1, 'X1');
  My_Output(X2, 'X2');
  My_Output(X3, 'X3');
  My_Output(Y, 'Y');

  My_Belong(Y, 10, 'Y');
  My_Include(Y, X3, 'Y', 'X3');
  
  Readln;
end.
