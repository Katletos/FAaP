unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, Vcl.StdCtrls,
  Vcl.ExtCtrls, VclTee.TeEngine, VclTee.TeeProcs, VclTee.Chart,
  System.Generics.Collections, System.StrUtils, VclTee.Series, Math;

type
  TfrmMain = class(TForm)
    crtMain: TChart;
    pnlMain: TPanel;
    btnCalc: TButton;
    edtExpr: TEdit;
    srMain: TFastLineSeries;
    procedure btnCalcClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TLexemType = (lxUnknown, lxOperator, lxNumber, lxVariable, lxBrClose,
    lxBrOpen, lxFunction);

  TOperator = (opUnknown, opPlus, opMinus, opMul, opDiv, opCap);

  TLexem = record
    case LexemType: TLexemType of
      lxOperator:
        (Oper: TOperator);
      lxVariable, lxNumber:
        (Value: extended);
  end;

  TExpr = class
  public
    LexemList: TList<TLexem>;
    revPolExpr: TList<TLexem>;
    constructor Create(var s: string);
    procedure MakeSomePoland;
    function CalcY(x: extended): extended;
    destructor Destroy;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

constructor TExpr.Create(var s: string);

  procedure DeleteWhiteSpaces;
  const
    WHITE_SPACE = ' ';
  var
    i: integer;
  begin
    i := 1;

    while i <= Length(s) do
    begin
      if s[i] = WHITE_SPACE then
      begin
        Delete(s, i, 1);
        dec(i);
      end;

      inc(i);
    end;
  end;

  function GetCharType(var c: char): TLexemType;
  begin
    case c of
      '0' .. '9':
        begin
          Result := lxNumber;
        end;
      '+', '-', '/', '*', '^':
        begin
          Result := lxOperator;
        end;
      '(':
        begin
          Result := lxBrOpen;
        end;
      ')':
        begin
          Result := lxBrClose;
        end;
      'A' .. 'Z':
        begin
          Result := lxVariable;
        end;
    else
      begin
        Result := lxUnknown;
      end;
    end;
  end;

  function isOperator: TLexem;
  var
    Op: TOperator;
    tmpLexem: TLexem;
  begin
    case s[1] of
      '+':
        begin
          Op := opPlus;
        end;
      '-':
        begin
          Op := opMinus;
        end;
      '/':
        begin
          Op := opDiv;
        end;
      '*':
        begin
          Op := opMul;
        end;
      '^':
        begin
          Op := opCap;
        end;
    end;

    Delete(s, 1, 1);
    tmpLexem.LexemType := lxOperator;
    tmpLexem.Oper := Op;

    Result := tmpLexem;
  end;

  function isNumber: TLexem;
  const
    CH_NUMBERS = ['0' .. '9'];
    CH_DOT = '.';
  var
    DotCounter: integer;
    i: integer;
    bufNumber: string;
    tmpLexem: TLexem;
  begin
    i := 1;
    DotCounter := 0;

    while ((Length(s) >= 1) and (DotCounter < 2) and
      ((s[i] in CH_NUMBERS) or (s[i] = CH_DOT))) do
    begin
      if s[i] = CH_DOT then
      begin
        inc(DotCounter);
      end;

      bufNumber := bufNumber + s[i];
      Delete(s, i, 1);
    end;

    tmpLexem.LexemType := lxNumber;
    tmpLexem.Value := strtofloat(bufNumber);
    Result := tmpLexem;
  end;

  function isLiteral: TLexem;
  var
    sBuffer: string;
  begin
    while Length(s) >= 1 do
    begin
      sBuffer := AnsiLeftStr(s, 3);

      // case sBuffer of
      // 'cos':
      // begin
      //
      // end;
      // 'sin':
      // begin
      //
      // end;
      // 'tan':
      // begin
      //
      // end;
      // 'cot':
      // begin
      //
      // end;
      // end;
    end;
  end;

  function isVariable: TLexem;
  var
    tmpLexem: TLexem;
  begin
    if (s[1] = 'X') then
    begin
      Delete(s, 1, 1);
      tmpLexem.LexemType := lxVariable;

      Result := tmpLexem;
    end;
  end;

  function isBracket: TLexem;
  var
    tmpLexem: TLexem;
    Bracket: TLexemType;
  begin
    case s[1] of
      '(':
        begin
          Bracket := lxBrOpen;
        end;
      ')':
        begin
          Bracket := lxBrClose;
        end;
    end;
    Delete(s, 1, 1);

    tmpLexem.LexemType := Bracket;
    Result := tmpLexem;
  end;

var
  FirstEl: char;
  tmpOperator: TOperator;
  tmpLexem: TLexem;
  tmpNumber: double;
  tmpLexemType: TLexemType;
  i: integer;
begin
  LexemList := TList<TLexem>.Create;
  revPolExpr := TList<TLexem>.Create;
  DeleteWhiteSpaces;
  s := AnsiUpperCase(s);

  while Length(s) > 0 do
  begin
    FirstEl := s[1];

    tmpLexemType := GetCharType(FirstEl);

    case tmpLexemType of
      lxOperator:
        begin
          tmpLexem := isOperator;
        end;
      lxNumber:
        begin
          tmpLexem := isNumber;
        end;
      lxVariable:
        begin
          tmpLexem := isVariable;
        end;
      lxBrOpen:
        begin
          tmpLexem := isBracket;
        end;
      lxBrClose:
        begin
          tmpLexem := isBracket;
        end;
    end;

    LexemList.Add(tmpLexem);
  end;
end;

procedure TExpr.MakeSomePoland;

  function RelPriority(lexem: TLexem): integer;
  begin
    case lexem.LexemType of
      lxOperator:
        begin
          case lexem.Oper of
            opPlus, opMinus:
              RelPriority := 1;
            opMul, opDiv:
              RelPriority := 3;
            opCap:
              RelPriority := 6;
          end;
        end;
      lxVariable, lxNumber:
        begin
          // 'A' .. 'Z':
          RelPriority := 7;
        end;
      lxBrOpen:
        begin
          RelPriority := 9;
        end;
      lxBrClose:
        begin
          RelPriority := 0;
        end;
    else
      RelPriority := -1;
    end;
  end;

  function StackPriority(lexem: TLexem): integer;
  begin
    case lexem.LexemType of
      lxOperator:
        begin
          case lexem.Oper of
            opPlus, opMinus:
              StackPriority := 2;
            opMul, opDiv:
              StackPriority := 4;
            opCap:
              StackPriority := 5;
          end;
        end;
      lxVariable, lxNumber:
        begin
          // A' .. 'Z':
          StackPriority := 8;
        end;
      lxBrOpen:
        begin
          StackPriority := 0;
        end;
      lxBrClose:
        begin
          StackPriority := -1;
        end;
    else
      StackPriority := -1;
    end;
  end;

var
  Stack: TStack<TLexem>;
  i: integer;
  LexemListCount: integer;
begin
  Stack := TStack<TLexem>.Create;

  LexemListCount := LexemList.Count;

  for i := 0 to LexemList.Count - 1 do
  begin
    if (Stack.Count = 0) or
      (RelPriority(LexemList[i]) > StackPriority(Stack.Peek)) then
    begin
      Stack.Push(LexemList[i]);
    end
    else
    begin
      if (LexemList[i].LexemType = lxBrClose) then
      begin
        while (Stack.Peek.LexemType <> lxBrOpen) do
        begin
          revPolExpr.Add(Stack.Pop);
        end;
        Stack.Pop;
      end
      else
      begin
        while (Stack.Count > 0) and
          (RelPriority(LexemList[i]) < StackPriority(Stack.Peek)) do
        begin
          revPolExpr.Add(Stack.Pop);
        end;
        Stack.Push(LexemList[i]);
      end;
    end;
  end;

  // Pop all whats left in stack
  while Stack.Count > 0 do
  begin
    revPolExpr.Add(Stack.Pop);
  end;

  Stack.Free;
end;

function TExpr.CalcY(x: extended): extended;

  function IsInt(x: extended): boolean;
  begin
    Result := frac(x) = 0;
  end;

  function ExtPower(num: extended; deg: extended): extended;
  const
    EPSILON = 0.0000000000000001;
  var
    i: extended;
    temp: extended;
  begin
    if IsInt(deg) then
    begin
      Result := Math.Power(num, deg);
    end
    else
    begin
      if deg + EPSILON < 0 then
      begin
        if (num + EPSILON < 0) then
        begin
          Result := NaN;
        end
        else
        begin
          Result := 1 / exp(deg * ln(abs(num)));
        end;
      end
      else if deg - EPSILON > 0 then
      begin
        if (num + EPSILON < 0) then
        begin
          Result := NaN;
        end
        else
        begin
          Result := exp(deg * ln(abs(num)));
        end;
      end
      else
      begin
        Result := 1;
      end;
    end;
  end;

  function Execute(var Op: TOperator; var first: extended; var second: extended)
    : extended;
  begin
    case Op of
      opPlus:
        begin
          Result := first + second;
        end;
      opMinus:
        begin
          Result := first - second;
        end;
      opMul:
        begin
          Result := first * second;
        end;
      opDiv:
        begin
          Result := first / second;
        end;
      opCap:
        begin
          Result := ExtPower(first, second);
        end;
    end;
  end;

var
  i: integer;
  Stack: TStack<extended>;
  Op: TOperator;
  first: extended;
  second: extended;
begin
  Stack := TStack<extended>.Create;

  for i := 0 to revPolExpr.Count - 1 do
  begin

    if (revPolExpr[i].LexemType = lxVariable) then
    begin
      Stack.Push(x);
    end
    else if (revPolExpr[i].LexemType = lxNumber) then
    begin
      Stack.Push(revPolExpr[i].Value);
    end
    else if (revPolExpr[i].LexemType = lxOperator) then
    begin
      // обратный порядок
      second := Stack.Pop;
      first := Stack.Pop;
      Op := revPolExpr[i].Oper;

      Stack.Push(Execute(Op, first, second));
    end;
  end;

  Result := Stack.Pop;
  Stack.Free;
end;

destructor TExpr.Destroy;
begin
  LexemList.Clear;
  revPolExpr.Clear;
end;

{
  function ExtremaFinder(srMain: TFastLineSeries): TPointSeries;
  var
  i: integer;
  ResultSeries: TPointSeries;
  ExtremaString: string;
  ExtremaPoint: extended;
  ExtremaY: extended;
  begin
  i := 0;

  while (i < srMain.ValuesList.Count - 1) do
  begin

  if ((srMain.YValue[i] > srMain.YValue[i - 1]) and
  (srMain.YValue[i] > srMain.YValue[i + 1])) or
  ((srMain.YValue[i] < srMain.YValue[i - 1]) and
  (srMain.YValue[i] < srMain.YValue[i + 1])) then
  begin
  ExtremaPoint := srMain.XValue[i];
  ExtremaY := srMain.YValue[i];
  ExtremaString := '(' + FloatToStr(ExtremaPoint) + ', ' +
  FloatToStr(ExtremaY) + ')';
  ResultSeries.AddXY(ExtremaPoint, ExtremaY, ExtremaString);
  end;

  inc(i);
  end;

  Result := ResultSeries;
  end;
}
var
  s: string;
  x: extended;
  tmpRes: extended;
  Expr: TExpr;
  tmpAreaSeries: TAreaSeries;
  ExtremaSeries: TPointSeries;

  tmpY: extended;

procedure TfrmMain.btnCalcClick(Sender: TObject);
begin
  s := edtExpr.Text;
  Expr := TExpr.Create(s);
  Expr.MakeSomePoland;

  tmpAreaSeries := TAreaSeries.Create(self);

  With srMain do
  begin
    Clear;
    ParentChart := crtMain;

    x := -100;
    while x < 100 do
    begin
      tmpY := Expr.CalcY(x);
      if (tmpY <> NaN) then
      begin
        AddXY(x, tmpY);
      end;
      x := x + 0.01;
    end;
  end;

  ExtremaSeries := ExtremaFinder(srMain);
end;

end.
