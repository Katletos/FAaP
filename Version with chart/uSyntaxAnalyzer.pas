unit uSyntaxAnalyzer;

interface

Uses
  Math, System.SysUtils, uLexicalAnalyzer;

function CalcY(var LexicalAnalyzer: TLexicalAnalyzer; VarValue: double): double;

implementation

function MathExpr(LexicalAnalyzer: TLexicalAnalyzer): double; forward;

function Func(LexicalAnalyzer: TLexicalAnalyzer): double;
var
  FuncName: TLexemeType;
  Arg: Extended;
begin
  FuncName := LexicalAnalyzer.Lexeme.LexemeType;
  LexicalAnalyzer.Next;
  if LexicalAnalyzer.Lexeme.LexemeType <> ltLeftBracket then
    raise ESyntaxError.Create('Ожидается "(" в позиции ' +
      IntToStr(LexicalAnalyzer.Lexeme.Position));
  LexicalAnalyzer.Next;
  Arg := MathExpr(LexicalAnalyzer);
  if LexicalAnalyzer.Lexeme.LexemeType <> ltRightBracket then
    raise ESyntaxError.Create('Ожидается ")" в позиции ' +
      IntToStr(LexicalAnalyzer.Lexeme.Position));
  LexicalAnalyzer.Next;
  case FuncName of
    ltSin:
      Result := Sin(Arg);
    ltCos:
      Result := Cos(Arg);
    ltLn:
      Result := Ln(Arg);
    ltTan:
      Result := Tan(Arg);
    ltCot:
      Result := Cot(Arg);
    ltAbs:
      Result := Abs(Arg);
    ltSinh:
      Result := Sinh(Arg);
    ltCosh:
      Result := Cosh(Arg);
    ltTanh:
      Result := Tanh(Arg);
    ltCoth:
      Result := Coth(Arg);
    ltExp:
      Result := Exp(Arg);
  else
    raise ESyntaxError.Create('Внутренняя ошибка в функции Func')
  end;
end;

function Base(LexicalAnalyzer: TLexicalAnalyzer): double;
begin
  case LexicalAnalyzer.Lexeme.LexemeType of
    ltLeftBracket:
      begin
        LexicalAnalyzer.Next;
        Result := MathExpr(LexicalAnalyzer);
        if LexicalAnalyzer.Lexeme.LexemeType <> ltRightBracket then
          raise ESyntaxError.Create('Ожидается ")" в позиции ' +
            IntToStr(LexicalAnalyzer.Lexeme.Position));
        LexicalAnalyzer.Next;
      end;

    // Добавление функций
    ltSin, ltCos, ltLn, ltTan, ltCot, ltAbs, ltSinh, ltCosh, ltTanh,
      ltCoth, ltExp:
      Result := Func(LexicalAnalyzer);

    // Идентификатор
    ltIdentifier:
      begin
        Result := LexicalAnalyzer.VarValue;
        LexicalAnalyzer.Next;
      end;

    ltPi:
      begin
        Result := pi;
        LexicalAnalyzer.Next;
      end;

    ltNumber:
      begin
        Result := StrToFloat(LexicalAnalyzer.Lexeme.Lexeme);
        LexicalAnalyzer.Next;
      end
  else
    begin
      raise ESyntaxError.Create('Некорректный символ в позиции ' +
        IntToStr(LexicalAnalyzer.Lexeme.Position))
    end;
  end
end;

function Factor(LexicalAnalyzer: TLexicalAnalyzer): double;
begin
  case LexicalAnalyzer.Lexeme.LexemeType of
    ltPlus:
      begin
        LexicalAnalyzer.Next;
        Result := Factor(LexicalAnalyzer)
      end;
    ltMinus:
      begin
        LexicalAnalyzer.Next;
        Result := -Factor(LexicalAnalyzer)
      end
  else
    begin
      Result := Base(LexicalAnalyzer);
      if LexicalAnalyzer.Lexeme.LexemeType = ltCap then
      begin
        LexicalAnalyzer.Next;
        Result := Power(Result, Factor(LexicalAnalyzer))
      end
    end
  end
end;

function Term(LexicalAnalyzer: TLexicalAnalyzer): double;
var
  Oper: TLexemeType;
begin
  Result := Factor(LexicalAnalyzer);
  while LexicalAnalyzer.Lexeme.LexemeType in Operator2 do
  begin
    Oper := LexicalAnalyzer.Lexeme.LexemeType;
    LexicalAnalyzer.Next;
    if Oper = LtAsterisk then
    begin
      Result := Result * Factor(LexicalAnalyzer);
    end
    else
    begin
      Result := Result / Factor(LexicalAnalyzer);
    end;
  end
end;

function MathExpr(LexicalAnalyzer: TLexicalAnalyzer): double;
var
  Oper: TLexemeType;
begin
  Result := Term(LexicalAnalyzer);
  while LexicalAnalyzer.Lexeme.LexemeType in Operator1 do
  begin
    Oper := LexicalAnalyzer.Lexeme.LexemeType;
    LexicalAnalyzer.Next;
    if Oper = ltPlus then
    begin
      Result := Result + Term(LexicalAnalyzer);
    end
    else
    begin
      Result := Result - Term(LexicalAnalyzer);
    end;
  end
end;

function CalcY(var LexicalAnalyzer: TLexicalAnalyzer; VarValue: double): double;
begin
  LexicalAnalyzer.VarValue := VarValue;
  Result := MathExpr(LexicalAnalyzer);
  if LexicalAnalyzer.Lexeme.LexemeType <> ltEnd then
    raise ESyntaxError.Create('Недопустимая лексема в позиции ' +
      IntToStr(LexicalAnalyzer.Lexeme.Position));
  LexicalAnalyzer.Index := 0;
end;

end.
