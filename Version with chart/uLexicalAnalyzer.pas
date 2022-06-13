unit uLexicalAnalyzer;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, Vcl.Graphics, Math;

type
  TLexemeType = (ltPlus, ltMinus, ltAsterisk, ltSlash, ltCap, ltLeftBracket,
    ltRightBracket, ltSin, ltCos, ltLn, ltTan, ltCot, ltAbs, ltSinh, ltCosh,
    ltTanh, ltCoth, ltExp, ltIdentifier, ltNumber, ltPi,  ltEnd);

  PLexeme = ^TLexeme;

  TLexeme = record
    LexemeType: TLexemeType;
    Position: Integer;
    Lexeme: string end;

    TLexicalAnalyzer = class private FVarValue: double;
    FLexemeList: TList;
    FIndex: Integer;
    function GetLexeme: PLexeme;
    function GetVarValue: double;
    procedure SetVarValue(const Value: double);
    function GetIndex: Integer;
    procedure SetIndex(const Value: Integer);
    procedure ExtractLexeme(const S: string; var P: Integer);
    procedure SkipWhiteSpace(const S: String; var P: Integer);
    procedure PutLexeme(LexemeType: TLexemeType; Position: Integer;
      Lexeme: string);
    procedure Number(const S: string; var P: Integer);
    procedure Word(const S: string; var P: Integer);
  public
    constructor Create(const Expr: string);
    destructor Destroy; override;
    procedure Next;
    property Lexeme: PLexeme read GetLexeme;
    property VarValue: double read GetVarValue write SetVarValue;
    property Index: Integer read GetIndex write SetIndex;
  end;

  ESyntaxError = class(Exception);

const
  Operator1 = [ltPlus, ltMinus];
  Operator2 = [ltAsterisk, ltSlash];

implementation

{ TLexicalAnalyzer }

constructor TLexicalAnalyzer.Create(const Expr: string);
var
  P: Integer;
begin
  inherited Create;
  FLexemeList := TList.Create;
  P := 1;
  while P <= Length(Expr) do
  begin
    SkipWhiteSpace(Expr, P);
    ExtractLexeme(Expr, P)
  end;
  PutLexeme(ltEnd, P, '');
  FIndex := 0
end;

destructor TLexicalAnalyzer.Destroy;
var
  I: Integer;
begin
  for I := 0 to FLexemeList.Count - 1 do
    Dispose(PLexeme(FLexemeList[I]));
  FLexemeList.Free;
  inherited Destroy
end;

function TLexicalAnalyzer.GetVarValue: double;
begin
  Result := FVarValue;
end;

procedure TLexicalAnalyzer.SetVarValue(const Value: double);
begin
  FVarValue := Value;
end;

function TLexicalAnalyzer.GetIndex: Integer;
begin
  Result := Self.FIndex;
end;

procedure TLexicalAnalyzer.SetIndex(const Value: Integer);
begin
  Self.FIndex := Value;
end;

function TLexicalAnalyzer.GetLexeme: PLexeme;
begin
  Result := FLexemeList[FIndex]
end;

procedure TLexicalAnalyzer.Next;
begin
  if FIndex < FLexemeList.Count - 1 then
    Inc(FIndex)
end;

procedure TLexicalAnalyzer.PutLexeme(LexemeType: TLexemeType; Position: Integer;
  Lexeme: string);
var
  NewLexeme: PLexeme;
begin
  New(NewLexeme);
  NewLexeme^.LexemeType := LexemeType;
  NewLexeme^.Position := Position;
  NewLexeme^.Lexeme := Lexeme;
  FLexemeList.Add(NewLexeme)
end;

procedure TLexicalAnalyzer.SkipWhiteSpace(const S: string; var P: Integer);
begin
  while (P <= Length(S)) and (S[P] in [' ', #9, #13, #10]) do
  begin
    Inc(P)
  end;
end;

procedure TLexicalAnalyzer.ExtractLexeme(const S: string; var P: Integer);
begin
  if P > Length(S) then
    Exit;
  case S[P] of
    '(':
      begin
        PutLexeme(ltLeftBracket, P, '');
        Inc(P)
      end;
    ')':
      begin
        PutLexeme(ltRightBracket, P, '');
        Inc(P)
      end;
    '*':
      begin
        PutLexeme(ltAsterisk, P, '');
        Inc(P)
      end;
    '+':
      begin
        PutLexeme(ltPlus, P, '');
        Inc(P)
      end;
    '-':
      begin
        PutLexeme(ltMinus, P, '');
        Inc(P)
      end;
    '/':
      begin
        PutLexeme(ltSlash, P, '');
        Inc(P)
      end;
    '0' .. '9':
      Number(S, P);
    'A' .. 'Z', 'a' .. 'z':
      Word(S, P);
    '^':
      begin
        PutLexeme(ltCap, P, '');
        Inc(P)
      end
  else
    raise ESyntaxError.Create('Incorrect symbol in position: ' + IntToStr(P))
  end
end;

procedure TLexicalAnalyzer.Number(const S: string; var P: Integer);

  function IsDigit(Ch: Char): Boolean;
  begin
    Result := Ch in ['0' .. '9']
  end;

var
  InitPos, RollbackPos: Integer;
begin
  InitPos := P;
  repeat
    Inc(P)
  until (P > Length(S)) or not IsDigit(S[P]);
  if (P <= Length(S)) and (S[P] = FormatSettings.DecimalSeparator) then
  begin
    Inc(P);
    if (P > Length(S)) or not IsDigit(S[P]) then
    begin
      Dec(P)
    end
    else
    begin
      repeat
        Inc(P)
      until (P > Length(S)) or not IsDigit(S[P]);
    end;
  end;

  if (P <= Length(S)) and (UpCase(S[P]) = 'E') then
  begin
    RollbackPos := P;
    Inc(P);
    if P > Length(S) then
    begin
      P := RollbackPos
    end
    else
    begin
      if S[P] in ['+', '-'] then
      begin
        Inc(P);
      end;

      if (P > Length(S)) or not IsDigit(S[P]) then
      begin
        P := RollbackPos
      end
      else
      begin
        repeat
          Inc(P)
        until (P > Length(S)) or not IsDigit(S[P]);
      end;
    end;
  end;
  PutLexeme(ltNumber, InitPos, Copy(S, InitPos, P - InitPos))
end;

procedure TLexicalAnalyzer.Word(const S: string; var P: Integer);
var
  InitPos: Integer;
  ID: string;
begin
  InitPos := P;
  Inc(P);
  while (P <= Length(S)) and (S[P] in ['A' .. 'Z', 'a' .. 'z']) do
    Inc(P);
  ID := Copy(S, InitPos, P - InitPos);
  if AnsiCompareText(ID, 'sin') = 0 then
    PutLexeme(ltSin, InitPos, '')
  else if AnsiCompareText(ID, 'cos') = 0 then
    PutLexeme(ltCos, InitPos, '')
  else if AnsiCompareText(ID, 'ln') = 0 then
    PutLexeme(ltLn, InitPos, '')
  else if (AnsiCompareText(ID, 'tan') = 0) or (AnsiCompareText(ID, 'tg') = 0)
  then
    PutLexeme(ltTan, InitPos, '')
  else if (AnsiCompareText(ID, 'cot') = 0) or (AnsiCompareText(ID, 'ctg') = 0)
  then
    PutLexeme(ltCot, InitPos, '')
  else if AnsiCompareText(ID, 'x') = 0 then
    PutLexeme(ltIdentifier, InitPos, ID)
  else if AnsiCompareText(ID, 'abs') = 0 then
    PutLexeme(ltAbs, InitPos, ID)
  else if (AnsiCompareText(ID, 'sh') = 0) or (AnsiCompareText(ID, 'sinh') = 0)
  then
    PutLexeme(ltSinh, InitPos, ID)
  else if (AnsiCompareText(ID, 'ch') = 0) or (AnsiCompareText(ID, 'cosh') = 0)
  then
    PutLexeme(ltCosh, InitPos, ID)
  else if (AnsiCompareText(ID, 'th') = 0) or (AnsiCompareText(ID, 'tanh') = 0)
  then
    PutLexeme(ltTanh, InitPos, ID)
  else if (AnsiCompareText(ID, 'cth') = 0) or (AnsiCompareText(ID, 'coth') = 0)
  then
    PutLexeme(ltCoth, InitPos, ID)
  else if (AnsiCompareText(ID, 'exp') = 0) then
    PutLexeme(ltExp, InitPos, ID)
  else if (AnsiCompareText(ID, 'pi') = 0) then
    PutLexeme(ltPi, InitPos, ID)
  else
    raise ESyntaxError.Create('Неизвестный идентификатор в позиции:' +
      IntToStr(InitPos));
end;

end.
