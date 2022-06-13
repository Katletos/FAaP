unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ActnList, Vcl.ExtCtrls,
  uLexicalAnalyzer, uSyntaxAnalyzer, uExtremaFinder, uBLFinder,
  VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series,
  VCLTee.TeeFunci, VCLTee.TeeGDIPlus,
  Vcl.ToolWin, Vcl.ComCtrls, System.ImageList, Vcl.ImgList, Vcl.ExtDlgs,
  Vcl.Mask;

const
  FreeStr = '';
  KEYPLUS = 187;
  KEYMINUS = 189;
  MinXValue = -1E6;
  MaxXValue = 1E6;
  MinYValue = -1E6;
  MaxYValue = 1E6;

type
  TSetChangeDirection = function(FirstX, SecondX: double): double of object;

  TGraphPoint = record
    X: double;
    Y: double;
  end;

  TResultPoints = record
    VisiblePoint: TGraphPoint;
    UnvisiblePoint: TGraphPoint;
  end;

  TSheduleForm = class(TForm)
    ActionList: TActionList;
    actCalculate: TAction;
    pnlCalcButton: TPanel;
    btnDoGraph: TButton;
    edFunction: TLabeledEdit;
    chrGraph: TChart;
    TeeGDIPlus1: TTeeGDIPlus;
    serMain: TFastLineSeries;
    cbShowExtrema: TCheckBox;
    serExtremaPoints: TPointSeries;
    odMain: TOpenDialog;
    sdMain: TSaveDialog;
    ilButtonsImages: TImageList;
    actOpenFile: TAction;
    actSaveFile: TAction;
    actSaveFileAs: TAction;
    memLoadedFunction: TMemo;
    actNew: TAction;
    actIncreaseZoom: TAction;
    actDecreaseZoom: TAction;
    actLeftArrowPressed: TAction;
    actRightArrowPressed: TAction;
    actUpArrowPressed: TAction;
    actDownArrowPressed: TAction;
    spdImage: TSavePictureDialog;
    tbNavigationButtons: TToolBar;
    tbtnNew: TToolButton;
    tbtnOpenFile: TToolButton;
    tbtnSaveFileAs: TToolButton;
    tbtnSaveFile: TToolButton;
    tbtnPlus: TToolButton;
    tbtnMinus: TToolButton;
    pnlButtons: TPanel;
    procedure actCalculateExecute(Sender: TObject);
    procedure edFunctionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbShowExtremaClick(Sender: TObject);
    procedure actOpenFileExecute(Sender: TObject);
    procedure actSaveFileAsExecute(Sender: TObject);
    procedure actSaveFileExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actIncreaseZoomExecute(Sender: TObject);
    procedure actDecreaseZoomExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actLeftArrowPressedExecute(Sender: TObject);
    procedure actRightArrowPressedExecute(Sender: TObject);
    procedure actUpArrowPressedExecute(Sender: TObject);
    procedure actDownArrowPressedExecute(Sender: TObject);
    procedure edFunctionClick(Sender: TObject);
  private
    FLexicalAnalyzer: TLexicalAnalyzer;
    FIsGraphBuilded: boolean;
    FIsLoadedFromFile: boolean;
    FIsEnoughPoints: boolean;
    FPointsCount: integer;
    FFuncValue: double;
    FPrevValueIsNull: boolean;
    FElmCount: integer;
    FStartPointsCount: integer;
    FStep: double;
    procedure ChangeInpFields(ExpMessage: string);
    procedure AddFuncValue(CurrXValue: double);
    function FindPointNearestToMinimum(CurrXValue, CompYValue: double;
      SetChangeDir: TSetChangeDirection): TResultPoints;
    function FindPointNearestToMaximum(CurrXValue, CompYValue: double;
      SetChangeDir: TSetChangeDirection): TResultPoints;
    function TryToFindPointNearestToMinimum(CurrXValue, CompYValue: double;
      SetChangeDir: TSetChangeDirection): TResultPoints;
    function TryToFindPointNearestToMaximum(CurrXValue, CompYValue: double;
      SetChangeDir: TSetChangeDirection): TResultPoints;
    function SetMinus(FirstX, SecondX: double): double;
    function SetPlus(FirstX, SecondX: double): double;
  public

  end;

var
  uShedule: TSheduleForm;

implementation

{$R *.dfm}

procedure TSheduleForm.FormCreate(Sender: TObject);
begin
  serMain.Clear;
  serMain.DrawAllPoints := true;
  serExtremaPoints.Visible := false;
  FIsGraphBuilded := false;
  FStartPointsCount := 1000;
end;

procedure TSheduleForm.ChangeInpFields(ExpMessage: String);
begin
  edFunction.Color := clRed;
  edFunction.EditLabel.Caption := ExpMessage;
  btnDoGraph.Enabled := false;
end;

procedure TSheduleForm.actCalculateExecute(Sender: TObject);
var
  InpStr: string;
  X: double;
  I: integer;
  FuncValue: double;
  ExpMessage: string;
  notSyntaxError: boolean;
begin
  Self.KeyPreview := true;
  notSyntaxError := true;
  InpStr := edFunction.Text;
  btnDoGraph.Enabled := false;
  FPointsCount := FStartPointsCount;
  if not FIsGraphBuilded then
  begin
    try
      FLexicalAnalyzer := TLexicalAnalyzer.Create(InpStr);
    except
      on Exptn: ESyntaxError do
      begin
        ChangeInpFields(Exptn.Message);
        notSyntaxError := false;
      end;
    end;
  end;

  if notSyntaxError then
  begin
    I := 0;
    while (I <= FPointsCount) and (notSyntaxError) do
    begin
      serMain.Clear;
      FIsEnoughPoints := true;
      X := chrGraph.Axes.Bottom.Minimum;
      FPrevValueIsNull := false;
      FElmCount := 0;
      FStep := (chrGraph.Axes.Bottom.Maximum - chrGraph.Axes.Bottom.Minimum) /
        FPointsCount;
      while (I <= FPointsCount) and (notSyntaxError) and (FIsEnoughPoints) do
      begin
        try
          AddFuncValue(X);
        except
          on Exptn: ESyntaxError do
          begin
            ChangeInpFields(Exptn.Message);
            FLexicalAnalyzer.Destroy;
            notSyntaxError := false;
          end;
          on Exptn: EMathError do
          begin
            FLexicalAnalyzer.Index := 0;
          end;
        end;
        X := X + FStep;
        inc(I);
      end;
      if notSyntaxError and FIsEnoughPoints then
      begin
        FIsGraphBuilded := true;
        chrGraph.Enabled := true;
        cbShowExtrema.Enabled := true;
        serExtremaPoints.Clear;
        if serMain.ValuesList.ValueList[0].Count >= 3 then
        begin
          GetExtremaPoints(FLexicalAnalyzer, serMain, serExtremaPoints, 1,
            1E-300, FIsEnoughPoints);
        end;
      end;
      if not FIsEnoughPoints then
      begin
        FPointsCount := FPointsCount * 2;
        if FPointsCount < 1.0E6 then
        begin
          I := 0
        end
        else
        begin
          FIsGraphBuilded := false;
          btnDoGraph.Enabled := true;
          ShowMessage('Данная функция не может быть корректно изображена');
          I := FPointsCount;
          notSyntaxError := false;
          serMain.Clear;
          serExtremaPoints.Clear;
          Self.KeyPreview := false;
        end
      end;
    end;
  end;
end;

procedure TSheduleForm.actDecreaseZoomExecute(Sender: TObject);
var
  Range: double;
begin
  Range := (chrGraph.Axes.Left.Maximum - chrGraph.Axes.Left.Minimum) / 20;
  chrGraph.Axes.Left.Maximum := chrGraph.Axes.Left.Maximum - Range;
  chrGraph.Axes.Left.Minimum := chrGraph.Axes.Left.Minimum + Range;

  Range := (chrGraph.Axes.Bottom.Maximum - chrGraph.Axes.Bottom.Minimum) / 20;
  chrGraph.Axes.Bottom.Maximum := chrGraph.Axes.Bottom.Maximum - Range;
  chrGraph.Axes.Bottom.Minimum := chrGraph.Axes.Bottom.Minimum + Range;
  if FIsGraphBuilded then
  begin
    actCalculateExecute(edFunction);
  end;
end;

procedure TSheduleForm.actIncreaseZoomExecute(Sender: TObject);
var
  Range: double;
begin
  Range := (chrGraph.Axes.Left.Maximum - chrGraph.Axes.Left.Minimum) / 20;
  if MaxXValue - chrGraph.Axes.Bottom.Maximum < Range then
    Range := MaxXValue - chrGraph.Axes.Bottom.Maximum;
  if MaxYValue - chrGraph.Axes.Left.Maximum < Range then
    Range := MaxYValue - chrGraph.Axes.Left.Maximum;
  if chrGraph.Axes.Bottom.Minimum - MinXValue < Range then
    Range := chrGraph.Axes.Bottom.Minimum - MinXValue;
  if chrGraph.Axes.Left.Minimum - MinYValue < Range then
    Range := chrGraph.Axes.Left.Minimum - MinYValue;

  chrGraph.Axes.Left.Maximum := chrGraph.Axes.Left.Maximum + Range;
  chrGraph.Axes.Left.Minimum := chrGraph.Axes.Left.Minimum - Range;
  chrGraph.Axes.Bottom.Maximum := chrGraph.Axes.Bottom.Maximum + Range;
  chrGraph.Axes.Bottom.Minimum := chrGraph.Axes.Bottom.Minimum - Range;

  if FIsGraphBuilded then
  begin
    actCalculateExecute(edFunction);
  end;
end;

procedure TSheduleForm.actLeftArrowPressedExecute(Sender: TObject);
var
  Range: double;
begin
  Range := (chrGraph.Axes.Bottom.Maximum - chrGraph.Axes.Bottom.Minimum) / 20;
  if (chrGraph.Axes.Bottom.Minimum - Range) < MinXValue then
  begin
    Range := chrGraph.Axes.Bottom.Minimum - MinXValue;
    chrGraph.Axes.Bottom.Minimum := MinXValue;
    chrGraph.Axes.Bottom.Maximum := chrGraph.Axes.Bottom.Maximum - Range;
  end
  else
  begin
    chrGraph.Axes.Bottom.Maximum := chrGraph.Axes.Bottom.Maximum - Range;
    chrGraph.Axes.Bottom.Minimum := chrGraph.Axes.Bottom.Minimum - Range;
  end;

  if FIsGraphBuilded then
  begin
    actCalculateExecute(edFunction);
  end;
end;

procedure TSheduleForm.actRightArrowPressedExecute(Sender: TObject);
var
  Range: double;
begin
  Range := (chrGraph.Axes.Bottom.Maximum - chrGraph.Axes.Bottom.Minimum) / 20;
  if chrGraph.Axes.Bottom.Maximum + Range > MaxXValue then
  begin
    Range := MaxXValue - chrGraph.Axes.Bottom.Maximum;
    chrGraph.Axes.Bottom.Maximum := MaxXValue;
    chrGraph.Axes.Bottom.Minimum := chrGraph.Axes.Bottom.Minimum + Range;
  end
  else
  begin
    chrGraph.Axes.Bottom.Maximum := chrGraph.Axes.Bottom.Maximum + Range;
    chrGraph.Axes.Bottom.Minimum := chrGraph.Axes.Bottom.Minimum + Range;
  end;

  if FIsGraphBuilded then
  begin
    actCalculateExecute(edFunction);
  end;
end;

procedure TSheduleForm.actUpArrowPressedExecute(Sender: TObject);
var
  Range: double;
begin
  Range := (chrGraph.Axes.Left.Maximum - chrGraph.Axes.Left.Minimum) / 20;
  if chrGraph.Axes.Left.Maximum + Range > MaxYValue then
  begin
    Range := MaxYValue - chrGraph.Axes.Left.Maximum;
    chrGraph.Axes.Left.Maximum := MaxYValue;
    chrGraph.Axes.Left.Minimum := chrGraph.Axes.Left.Minimum + Range;
  end
  else
  begin
    chrGraph.Axes.Left.Maximum := chrGraph.Axes.Left.Maximum + Range;
    chrGraph.Axes.Left.Minimum := chrGraph.Axes.Left.Minimum + Range;
  end;

  if FIsGraphBuilded then
  begin
    actCalculateExecute(edFunction);
  end;
end;

procedure TSheduleForm.actDownArrowPressedExecute(Sender: TObject);
var
  Range: double;
begin
  Range := (chrGraph.Axes.Left.Maximum - chrGraph.Axes.Left.Minimum) / 20;
  if chrGraph.Axes.Left.Minimum - Range < MinYValue then
  begin
    Range := chrGraph.Axes.Left.Minimum - MinXValue;
    chrGraph.Axes.Left.Minimum := MinXValue;
    chrGraph.Axes.Left.Maximum := chrGraph.Axes.Left.Maximum - Range;
  end
  else
  begin
    chrGraph.Axes.Left.Maximum := chrGraph.Axes.Left.Maximum - Range;
    chrGraph.Axes.Left.Minimum := chrGraph.Axes.Left.Minimum - Range;
  end;

  if FIsGraphBuilded then
  begin
    actCalculateExecute(edFunction);
  end;
end;

procedure TSheduleForm.actNewExecute(Sender: TObject);
begin
  odMain.Files.Clear;
  tbtnSaveFile.Enabled := false;
  edFunction.Text := '';
end;

procedure TSheduleForm.actOpenFileExecute(Sender: TObject);
begin
  if odMain.Execute then
  begin
    memLoadedFunction.Lines.LoadFromFile(odMain.Files[0]);
    edFunction.Text := memLoadedFunction.Text;
    tbtnSaveFile.Enabled := true;
    FIsLoadedFromFile := true;
  end;
end;

procedure TSheduleForm.actSaveFileAsExecute(Sender: TObject);
begin
  if sdMain.Execute then
  begin
    memLoadedFunction.Text := edFunction.Text;
    memLoadedFunction.Lines.SaveToFile(sdMain.Files[0]);
    tbtnSaveFile.Enabled := true;
    FIsLoadedFromFile := false;
  end;
end;

procedure TSheduleForm.actSaveFileExecute(Sender: TObject);
begin
  if tbtnSaveFile.Enabled then
  begin
    memLoadedFunction.Text := edFunction.Text;
    if FIsLoadedFromFile then
      memLoadedFunction.Lines.SaveToFile(odMain.Files[0])
    else
      memLoadedFunction.Lines.SaveToFile(sdMain.Files[0]);
  end;
end;

procedure TSheduleForm.AddFuncValue(CurrXValue: double);
var
  ParmStep: double;
  ResultPoints: TResultPoints;
  InmXValue, InmYValue: double;
  isAdditionalPointsCreated: boolean;
  isCorrectValue: boolean;
begin
  FFuncValue := CalcY(FLexicalAnalyzer, CurrXValue);
  try
    if ((FFuncValue > chrGraph.Axes.Left.Maximum) or
      (FFuncValue < chrGraph.Axes.Left.Minimum)) then
    begin
      if (FElmCount > 0) and (not FPrevValueIsNull) and
        (serMain.ValueColor[FElmCount - 1] <> clNone) then
      begin
        if (serMain.YValue[FElmCount - 1] - chrGraph.Axes.Left.Minimum) <
          (chrGraph.Axes.Left.Maximum - serMain.YValue[FElmCount - 1]) then
        begin
          ResultPoints := FindPointNearestToMinimum
            (serMain.XValue[FElmCount - 1],
            serMain.YValue[FElmCount - 1], SetPlus)
        end
        else
        begin
          ResultPoints := FindPointNearestToMaximum
            (serMain.XValue[FElmCount - 1],
            serMain.YValue[FElmCount - 1], SetPlus);
        end;
        if FIsEnoughPoints then
        begin
          serMain.AddXY(ResultPoints.VisiblePoint.X,
            CalcY(FLexicalAnalyzer, ResultPoints.VisiblePoint.X));
          serMain.AddNullXY(ResultPoints.UnvisiblePoint.X,
            ResultPoints.VisiblePoint.Y);
          inc(FElmCount, 2);
          FPrevValueIsNull := true;
        end;
      end
    end
    else
    begin
      if (FElmCount > 0) and (FPrevValueIsNull) then
      begin
        if (FFuncValue - chrGraph.Axes.Left.Minimum) <
          (chrGraph.Axes.Left.Maximum - FFuncValue) then
        begin
          ResultPoints := FindPointNearestToMinimum(CurrXValue, FFuncValue,
            SetMinus);
        end
        else
        begin
          ResultPoints := FindPointNearestToMaximum(CurrXValue, FFuncValue,
            SetMinus);
        end;

        if FIsEnoughPoints then
        begin
          serMain.AddNullXY(ResultPoints.UnvisiblePoint.X,
            ResultPoints.UnvisiblePoint.Y);
          serMain.AddXY(ResultPoints.VisiblePoint.X,
            ResultPoints.VisiblePoint.Y);
          inc(FElmCount, 2);
        end;
      end
      else if (FElmCount = 0) and (CurrXValue > chrGraph.Axes.Bottom.Minimum)
      then
      begin
        if (FFuncValue - chrGraph.Axes.Left.Minimum) <
          (chrGraph.Axes.Left.Maximum - FFuncValue) then
        begin
          TryToFindPointNearestToMinimum(CurrXValue, FFuncValue, SetMinus);
        end
        else
        begin
          TryToFindPointNearestToMaximum(CurrXValue, FFuncValue, SetMinus);
        end;
      end;
      serMain.AddXY(CurrXValue, FFuncValue);
      inc(FElmCount);
      FPrevValueIsNull := false;
    end;
  except
    FIsEnoughPoints := false;
  end;
end;

procedure TSheduleForm.cbShowExtremaClick(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
  begin
    serExtremaPoints.Visible := true;
  end
  else
  begin
    serExtremaPoints.Visible := false;
  end;
end;

procedure TSheduleForm.edFunctionChange(Sender: TObject);
begin
  if FIsGraphBuilded then
  begin
    FIsGraphBuilded := false;
    cbShowExtrema.Enabled := false;
    chrGraph.Enabled := false;
    serMain.Clear;
    serExtremaPoints.Clear;
    FLexicalAnalyzer.Destroy;
  end;

  if edFunction.Text = '' then
  begin
    chrGraph.Enabled := false;
    btnDoGraph.Enabled := false;
  end
  else if not(btnDoGraph.Enabled) then
  begin
    edFunction.Color := clWhite;
    edFunction.EditLabel.Caption := 'Введите формулу:';
    btnDoGraph.Enabled := true;
  end;
end;

procedure TSheduleForm.edFunctionClick(Sender: TObject);
begin
  Self.KeyPreview := false;
end;

function TSheduleForm.FindPointNearestToMaximum(CurrXValue, CompYValue: double;
  SetChangeDir: TSetChangeDirection): TResultPoints;
var
  ParmStep, InmYValue: double;
  isCorrectValue: boolean;
  PrevYValue: double;
  isPrevYValueExists: boolean;
  isFind: boolean;
begin
  ParmStep := FStep / 2;
  isFind := true;
  Result.UnvisiblePoint.X := CurrXValue;
  isCorrectValue := false;
  isPrevYValueExists := false;
  repeat
    try
      InmYValue := CalcY(FLexicalAnalyzer, SetChangeDir(Result.UnvisiblePoint.X,
        ParmStep));
      if InmYValue >= chrGraph.Axes.Left.Maximum then
      begin
        Result.UnvisiblePoint.X := SetChangeDir(Result.UnvisiblePoint.X,
          ParmStep);
        isCorrectValue := true;
      end
      else if (InmYValue <= chrGraph.Axes.Left.Maximum) and
        (InmYValue > CompYValue) then
      begin
        Result.UnvisiblePoint.X := SetChangeDir(Result.UnvisiblePoint.X,
          ParmStep);
        if abs(ParmStep) < 1E-50 then
        begin
          isFind := false;
        end;

        if (isPrevYValueExists) and
          (abs(abs(PrevYValue) - abs(InmYValue)) < 1E-16) then
        begin
          FIsEnoughPoints := false;
        end;

        isPrevYValueExists := true;
        PrevYValue := InmYValue;
      end
      else if abs(ParmStep) < 1E-50 then
      begin
        ParmStep := ParmStep / 2;
      end
      else
      begin
        FIsEnoughPoints := false;
      end;
    except
      ParmStep := ParmStep / 2;
      if abs(ParmStep) < 1E-50 then
      begin
        FIsEnoughPoints := false;
      end;
      FLexicalAnalyzer.Index := 0;
    end;
  until isCorrectValue or not FIsEnoughPoints or not isFind;

  if isFind then
  begin
    if FIsEnoughPoints then
    begin
      Result.UnvisiblePoint.Y := InmYValue;
      Result.VisiblePoint.X := GetBlValue(FLexicalAnalyzer, CurrXValue,
        Result.UnvisiblePoint.X, chrGraph.Axes.Left.Maximum, FIsEnoughPoints);
      Result.VisiblePoint.Y := CalcY(FLexicalAnalyzer, Result.VisiblePoint.X);
      Result.UnvisiblePoint.X := Result.VisiblePoint.X;
      Result.UnvisiblePoint.Y := Result.VisiblePoint.Y + 1;
    end
    else
    begin
      Result.VisiblePoint.X := 42;
      Result.VisiblePoint.Y := 42;
      Result.UnvisiblePoint.X := 42;
      Result.UnvisiblePoint.Y := 42;
    end;
  end
  else
  begin
    Result.VisiblePoint.Y := chrGraph.Axes.Left.Maximum;
    Result.UnvisiblePoint.X := Result.VisiblePoint.X;
    Result.UnvisiblePoint.Y := Result.VisiblePoint.Y + 1;
  end;
end;

function TSheduleForm.FindPointNearestToMinimum(CurrXValue, CompYValue: double;
  SetChangeDir: TSetChangeDirection): TResultPoints;
var
  ParmStep, InmYValue: double;
  PrevYValue: double;
  isPrevYValueExists: boolean;
  isFind: boolean;
  isCorrectValue: boolean;
begin
  ParmStep := FStep / 2;
  isFind := true;
  Result.UnvisiblePoint.X := CurrXValue;
  isCorrectValue := false;
  isPrevYValueExists := false;
  repeat
    try
      InmYValue := CalcY(FLexicalAnalyzer, SetChangeDir(Result.UnvisiblePoint.X,
        ParmStep));
      if InmYValue <= chrGraph.Axes.Left.Minimum then
      begin
        Result.UnvisiblePoint.X := SetChangeDir(Result.UnvisiblePoint.X,
          ParmStep);
        isCorrectValue := true;
      end
      else if (InmYValue >= chrGraph.Axes.Left.Minimum) and
        (InmYValue < CompYValue) then
      begin
        Result.UnvisiblePoint.X := SetChangeDir(Result.UnvisiblePoint.X,
          ParmStep);
        if abs(ParmStep) < 1E-50 then
          isFind := false;
        if (isPrevYValueExists) and
          (abs(abs(PrevYValue) - abs(InmYValue)) < 1E-16) then
          FIsEnoughPoints := false;
        isPrevYValueExists := true;
        PrevYValue := InmYValue;
      end
      else if abs(ParmStep) > 1E-50 then
        ParmStep := ParmStep / 2
      else
        FIsEnoughPoints := false;
    except
      ParmStep := ParmStep / 2;
      if abs(ParmStep) < 1E-50 then
        FIsEnoughPoints := false;
      FLexicalAnalyzer.Index := 0;
    end;
  until isCorrectValue or not FIsEnoughPoints or not isFind;
  if isFind then
    if FIsEnoughPoints then
    begin
      Result.UnvisiblePoint.Y := InmYValue;
      Result.VisiblePoint.X := GetBlValue(FLexicalAnalyzer,
        Result.UnvisiblePoint.X, CurrXValue, chrGraph.Axes.Left.Minimum,
        FIsEnoughPoints);
      Result.VisiblePoint.Y := CalcY(FLexicalAnalyzer, Result.VisiblePoint.X);
      Result.UnvisiblePoint.X := Result.VisiblePoint.X;
      Result.UnvisiblePoint.Y := Result.VisiblePoint.Y - 1;
    end
    else
    begin
      Result.VisiblePoint.X := 42;
      Result.VisiblePoint.Y := 42;
      Result.UnvisiblePoint.X := 42;
      Result.UnvisiblePoint.Y := 42;
    end
  else
  begin
    Result.VisiblePoint.Y := chrGraph.Axes.Left.Minimum;
    Result.UnvisiblePoint.X := Result.VisiblePoint.X;
    Result.UnvisiblePoint.Y := Result.VisiblePoint.Y - 1;
  end;
end;

procedure TSheduleForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    KEYPLUS:
      actDecreaseZoomExecute(tbtnPlus);
    KEYMINUS:
      actIncreaseZoomExecute(tbtnMinus);
    VK_LEFT:
      actLeftArrowPressedExecute(Sender);
    VK_RIGHT:
      actRightArrowPressedExecute(Sender);
    VK_UP:
      actUpArrowPressedExecute(Sender);
    VK_DOWN:
      actDownArrowPressedExecute(Sender);
  end;
end;

function TSheduleForm.SetMinus(FirstX, SecondX: double): double;
begin
  Result := FirstX - SecondX;
end;

function TSheduleForm.SetPlus(FirstX, SecondX: double): double;
begin
  Result := FirstX + SecondX;
end;

function TSheduleForm.TryToFindPointNearestToMaximum(CurrXValue,
  CompYValue: double; SetChangeDir: TSetChangeDirection): TResultPoints;
begin
  Result := FindPointNearestToMaximum(CurrXValue, CompYValue, SetChangeDir);
  if FIsEnoughPoints then
  begin
    try
      serMain.AddNullXY(Result.UnvisiblePoint.X, Result.UnvisiblePoint.Y);
      serMain.AddXY(Result.VisiblePoint.X, Result.VisiblePoint.Y);
      inc(FElmCount, 2);
    except
      on EMathError do
      begin
        FIsEnoughPoints := false;
      end;
    end;
  end
  else
  begin
    FIsEnoughPoints := true;
  end;
end;

function TSheduleForm.TryToFindPointNearestToMinimum(CurrXValue,
  CompYValue: double; SetChangeDir: TSetChangeDirection): TResultPoints;
begin
  Result := FindPointNearestToMinimum(CurrXValue, CompYValue, SetChangeDir);
  if FIsEnoughPoints then
  begin
    try
      serMain.AddNullXY(Result.UnvisiblePoint.X, Result.UnvisiblePoint.Y);
      serMain.AddXY(Result.VisiblePoint.X, Result.VisiblePoint.Y);
      inc(FElmCount, 2);
    except
      on EMathError do
      begin
        FIsEnoughPoints := false;
      end;
    end;
  end
  else
  begin
    FIsEnoughPoints := true;
  end;
end;

end.
