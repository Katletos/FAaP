unit uBLFinder;

interface

uses
  System.SysUtils, VCLTee.Series, uLexicalAnalyzer, uSyntaxAnalyzer,
  Vcl.Dialogs, Math;

function GetBLValue(var LexicalAnalyzer: TLexicalAnalyzer;
  LeftXValue, RightXValue: double; const BLYValue: double;
  var isEnoughPoints: boolean): double;

implementation

function GetBLValue(var LexicalAnalyzer: TLexicalAnalyzer;
  LeftXValue, RightXValue: double; const BLYValue: double;
  var isEnoughPoints: boolean): double;
const
  ArrSize = 10;
var
  MiddleXValue, MiddleYValue: double;
  PrevChange, CurrChange: double;
  YValuesChange: array [1 .. ArrSize] of double;
  i: integer;
begin
  isEnoughPoints := true;
  try
    for i := 1 to ArrSize do
    begin
      MiddleXValue := (RightXValue + LeftXValue) / 2;
      MiddleYValue := CalcY(LexicalAnalyzer, MiddleXValue);
      if MiddleYValue > BLYValue then
      begin
        RightXValue := MiddleXValue
      end
      else
      begin
        LeftXValue := MiddleXValue;
      end;
      YValuesChange[i] := Abs(Abs(MiddleYValue) - Abs(BLYValue));
    end;

    if YValuesChange[ArrSize] > YValuesChange[1] then
    begin
      isEnoughPoints := false;
    end;

    if isEnoughPoints then
    begin
      CurrChange := YValuesChange[ArrSize];
      repeat
        MiddleXValue := (RightXValue + LeftXValue) / 2;
        MiddleYValue := CalcY(LexicalAnalyzer, MiddleXValue);
        if MiddleYValue > BLYValue then
        begin
          RightXValue := MiddleXValue
        end
        else
        begin
          LeftXValue := MiddleXValue;
        end;
        CurrChange := Abs(Abs(MiddleYValue) - Abs(BLYValue));
        if CurrChange > YValuesChange[1] then
        begin
          isEnoughPoints := false;
        end;
      until (not isEnoughPoints) or ((RightXValue - LeftXValue) < 1E-10);
    end;
  except
    on EMathError do
    begin
      isEnoughPoints := false;
      LexicalAnalyzer.Index := 0;
    end;
  end;

  if isEnoughPoints then
  begin
    Result := MiddleXValue
  end
  else
  begin
    Result := 42;
  end;
end;

end.
