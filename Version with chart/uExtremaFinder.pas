unit uExtremaFinder;

interface

uses
  System.SysUtils, Vcl.Graphics, VCLTee.Series, uLexicalAnalyzer,
  uSyntaxAnalyzer, Math;

procedure GetExtremaPoints(var LexicalAnalyzer: TLexicalAnalyzer;
  var GettedSeries: TFastLineSeries; var ResultSeries: TPointSeries;
  StartInd: integer; Accuracy: double; var isEnoughPoints: boolean);

implementation

type
  TCompareFuncValues = function(LeftYValue, RightYValue: double): boolean;

const
  XList = 0;
  YList = 1;

function CompForTheMaximum(LeftYValue, RightYValue: double): boolean;
begin
  if LeftYValue > RightYValue then
  begin
    Result := true
  end
  else
  begin
    Result := false;
  end;
end;

function CompForTheMinimum(LeftYValue, RightYValue: double): boolean;
begin
  if LeftYValue < RightYValue then
  begin
    Result := true
  end
  else
  begin
    Result := false;
  end;
end;

function FindExtrema(LexicalAnalyzer: TLexicalAnalyzer;
  CompareFuncValue: TCompareFuncValues; LeftXValue, RightXValue: double;
  Accuracy: double; var isEnoughPoints: boolean): double;
var
  PrevLeftXValue, PrevRightXValue: double;
  LeftYValue, RightYValue: double;
  GoldenRatio: double;
begin
  GoldenRatio := (-1 + sqrt(5)) / 2;
  PrevLeftXValue := LeftXValue;
  PrevRightXValue := RightXValue;
  while Abs(RightXValue - LeftXValue) > Accuracy do
  begin
    try
      LeftXValue := GoldenRatio * PrevLeftXValue + (1 - GoldenRatio) *
        PrevRightXValue;
      RightXValue := (1 - GoldenRatio) * PrevLeftXValue + GoldenRatio *
        PrevRightXValue;
      LeftYValue := CalcY(LexicalAnalyzer, LeftXValue);
      RightYValue := CalcY(LexicalAnalyzer, RightXValue);
      if CompareFuncValue(LeftYValue, RightYValue) then
      begin
        PrevRightXValue := RightXValue;
        RightXValue := LeftXValue;
        RightYValue := LeftYValue;
        LeftXValue := GoldenRatio * PrevLeftXValue + (1 - GoldenRatio) *
          PrevRightXValue;
        LeftYValue := CalcY(LexicalAnalyzer, LeftXValue);
      end
      else
      begin
        PrevLeftXValue := LeftXValue;
        LeftXValue := RightXValue;
        LeftYValue := RightYValue;
        RightXValue := (1 - GoldenRatio) * PrevLeftXValue + GoldenRatio *
          PrevRightXValue;
        RightYValue := CalcY(LexicalAnalyzer, RightXValue);
      end;
    except
      on EMathError do
      begin
        isEnoughPoints := false;
        LexicalAnalyzer.Index := 0;
      end;
    end;
  end;
  Result := (RightXValue + LeftXValue) / 2;
end;

procedure GetExtremaPoints(var LexicalAnalyzer: TLexicalAnalyzer;
  var GettedSeries: TFastLineSeries; var ResultSeries: TPointSeries;
  StartInd: integer; Accuracy: double; var isEnoughPoints: boolean);
var
  i, j, AddedPointsCount, ResCount, AddedInd: integer;
  AdditionalPointsCount: integer;
  ExtremaPoint, ExtremaY: double;
  ExtremaValue: string;
  isExtrema: boolean;
begin
  i := StartInd;
  isEnoughPoints := true;
  while (i < GettedSeries.ValuesList.ValueList[YList].Count - 1) and
    (isEnoughPoints) do
  begin
    isExtrema := false;
    if (GettedSeries.ValueColor[i] <> clNone) then
    begin
      if ((GettedSeries.YValue[i] > GettedSeries.YValue[i - 1]) and
        (GettedSeries.YValue[i] > GettedSeries.YValue[i + 1])) then
      begin
        ExtremaPoint := FindExtrema(LexicalAnalyzer, CompForTheMaximum,
          GettedSeries.XValue[i - 1], GettedSeries.XValue[i + 1], Accuracy,
          isEnoughPoints);
        isExtrema := true;
      end
      else if ((GettedSeries.YValue[i] < GettedSeries.YValue[i - 1]) and
        (GettedSeries.YValue[i] < GettedSeries.YValue[i + 1])) then
      begin
        ExtremaPoint := FindExtrema(LexicalAnalyzer, CompForTheMinimum,
          GettedSeries.XValue[i - 1], GettedSeries.XValue[i + 1], Accuracy,
          isEnoughPoints);
        isExtrema := true;
      end;

      if isExtrema and isEnoughPoints then
      begin
        ExtremaY := CalcY(LexicalAnalyzer, ExtremaPoint);
        ExtremaValue := '(' + FloatToStr(ExtremaPoint) + ', ' +
          FloatToStr(ExtremaY) + ')';
        ResultSeries.AddXY(ExtremaPoint, ExtremaY, ExtremaValue);
        inc(i);
      end;
    end;
    inc(i);
  end;

  if not isEnoughPoints then
  begin
    ResultSeries.Clear;
  end;
end;

end.
