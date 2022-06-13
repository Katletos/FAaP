program _30;
{$APPTYPE CONSOLE}

uses
  SysUtils, Windows;

type
  TMnDigit = set of 0..9;

procedure My_Rebus;
var
  M, Y, X, A, C, L, O, N, Call, quantity: Integer;
  FCarry: Boolean;
  Digit: TMnDigit;
procedure My_Find(var CurrTerm, CurrSum, NextTerm, NextSum, XTerm, XSum, YTerm, YSum: integer);
var
  i, DigEnd, DigBeg: Integer;
  FSave: Boolean;
begin
  If Call = 5 then
  begin
    Writeln('Решение ',quantity,':');
    Writeln( YTerm:3, XTerm:3, NextTerm:3, CurrTerm:3);
    Writeln ('+');
    Writeln( YTerm:3, XTerm:3, NextTerm:3, CurrTerm:3);
    Writeln('  ----------');
    Writeln(YSum:3, XSum:3, NextSum:3, CurrSum:3);
    Writeln;
    inc(quantity);
  end
  else
  begin
    FSave:= FCarry;

    if Call <> 4 then
    begin
      DigEnd:= 9;
      //DigBeg:=0;
    end
    else
    begin
     DigEnd:=4;
     //DigBeg:=1;
    end;

    for i:= 0 to DigEnd do
    begin
      CurrTerm:= i;
      if not([CurrTerm] <= Digit) then
      begin
        Digit:= Digit + [CurrTerm];
        CurrSum:= 2*CurrTerm mod 10;

        if (FCarry) then
        begin
          Inc(CurrSum);
          FCarry:= False;
        end;

        if CurrTerm >=5 then FCarry:= True;

        if [CurrSum] <= Digit then
          Digit:=Digit - [CurrTerm]
        else
        begin
          Digit:= Digit + [CurrSum];
          inc(Call);
          My_Find( NextTerm, NextSum, XTerm, XSum, YTerm, YSum, CurrTerm, CurrSum);
          Digit:=(Digit - [CurrTerm])-[CurrSum];
        end;
        FCarry:=FSave;
      end;
    end;
  end;
  Dec(Call);
end;
begin
  Digit := [];
  FCarry:= False;
  Call:=1;
  quantity:=1;
  My_Find(A, N, X, O, Y, L, M, C);
end;

begin
  SetConsoleCP(1251);
  SetConsoleOutPutCP(1251);

  Writeln('  М  У  Х  А');
  Writeln('+');
  Writeln('  М  У  Х  А');
  Writeln(' ------------');
  Writeln('  С  Л  О  Н');
  Writeln;
  Writeln('Нажмите Enter для получения всех возможных решений ребуса.');
  Readln;

  My_Rebus;
  Writeln('Нажмите Enter для завершения программы.');
  Readln;
end.
