program Project3;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TArr = array [1 .. 24] of byte;

procedure Randompoints(var ListOfPoints: TArr);
var
  i, j, Temp, n: integer;
begin
  randomize;
  n := Length(ListOfPoints);
  for i := 1 to n - 1 do
  begin
    j := Random(i) + 1;
    Temp := ListOfPoints[i];
    ListOfPoints[i] := ListOfPoints[j];
    ListOfPoints[j] := Temp;
  end;
end;

procedure RePrint(var ListOfCards: TArr; var Score1, Score2: byte);
var
  i: integer;
begin
  for i := 1 to 40 do
  begin
    writeln;
  end;

  for i := 1 to 24 do
  begin
    if ListOfCards[i] = 0 then
    begin
      write('    |');
    end
    else
    begin
      write(ListOfCards[i]:3, ' |');
    end;

  end;
  writeln;
  writeln;
  writeln('1 player score:', Score1);
  writeln('2 player score:', Score2);
end;

procedure Input(var value: byte; var ListOfCards: TArr);
var
  Str: string;
  e: integer;
begin
  repeat
    readln(Str);
    val(Str, value, e);
  until (e = 0) and (value in [1 .. 24]) and (ListOfCards[value] <> 0);

end;

procedure CalcScore1(var value, Score1: byte;
  var ListOfPoints, ListOfCards: TArr);
begin

  Score1 := Score1 + ListOfPoints[value];
  ListOfCards[value] := 0;
  ListOfPoints[value] := 0;

end;

procedure CalcScore2(var value, Score2: byte;
  var ListOfPoints, ListOfCards: TArr);
begin

  Score2 := Score2 + ListOfPoints[value];
  ListOfCards[value] := 0;
  ListOfPoints[value] := 0;

end;

var
  ListOfCards: TArr;
  ListOfPoints: TArr = (1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6,
    6, 7, 7, 8, 8);

  i: byte;
  j: byte;
  Score1: byte;
  Score2: byte;
  value: byte;

begin
  { заполнение массива карт и очков }
  for i := 1 to 24 do
  begin
    ListOfCards[i] := i;
    write(ListOfCards[i]:3, ' |');
  end;

  Randompoints(ListOfPoints);
  writeln;

  for i := 1 to 24 do
  begin
    write(ListOfPoints[i]:3, ' |');
  end;

  readln;

  while (Score1 < 21) and (Score2 < 21) do
  begin

    RePrint(ListOfCards, Score1, Score2);

    writeln('1st player: ');
    Input(value, ListOfCards);
    CalcScore1(value, Score1, ListOfPoints, ListOfCards);

    RePrint(ListOfCards, Score1, Score2);

    if Score1 < 21 then
    begin
      writeln('2nd player: ');
      Input(value, ListOfCards);

      CalcScore2(value, Score2, ListOfPoints, ListOfCards);
    end;

  end;

  writeln;
  writeln('1 player score:', Score1);
  writeln('2 player score:', Score2);
  if (Score1 = 21) or (Score2 > 21) then
    writeln(' 1st player wins!');
  if (Score2 = 21) or (Score1 > 21) then
    writeln(' 2nd player wins!');

  readln;

end.
