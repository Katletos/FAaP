program lab1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  N = 1000;
  PREFIX = 'my_test_';
  MaxRandomValue = 200;
  LenTestValues = 10;

type

  TRecord = record
    NumField: integer;
    StrField: string[12];
    BoolField: boolean;
  end;

  TArr = array [1 .. N] of TRecord;
  TStrValues = array [1 .. LenTestValues] of String;
  TNumValues = array [1 .. LenTestValues] of integer;

  TCompareResult = (Less, Equal, More);
  TCompareValue = function(const Rec1, Rec2: TRecord): TCompareResult;
  TCompareValueAndRec = function(const Rec: TRecord; const Value: Variant)
    : TCompareResult;

procedure GenerateArr(var Arr: TArr);
{ Генерирует массив записей с полями NumField, StrField, BoolField }
var
  i, k: integer;
begin
  randomize;

  for i := Low(Arr) to High(Arr) do
  begin
    with Arr[i] do
    begin
      NumField := random(MaxRandomValue);
      StrField := PREFIX + intToStr(i);
      BoolField := False;
    end;
  end;

end;

procedure WriteRecord(const Rec: TRecord);
{ Выводит запись в виде строки таблицы }
begin
  with Rec do
  begin
    Write('|');
    Write(NumField:5);
    Write('     | ');
    Write(StrField:12);
    Write(' |   ');
    Write(BoolField:5);
    Writeln('   |');
  end;
end;

procedure WriteArray(var Arr: TArr);
{ Выводит все элементы массива записей TRecord
  от элемента FromEl до ToEl }
const
  TableHead = '     | NumField |   StrField   | BoolField |';
var
  i: Word;

begin
  Writeln(TableHead);

  for i := low(Arr) to High(Arr) do
  begin
    Write(i:5);
    WriteRecord(Arr[i]);
  end;

  Writeln;
end;

function CompareStrValue(const Rec1, Rec2: TRecord): TCompareResult;
{ Сравнивает две записи по строковым полям.

  Аргументы
  Rec1, Rec2-- записи.

  Возращает значение перечислимого типа TCompareResult
  Less -- Rec1.StrField < Rec2.StrField
  More -- Rec1.StrField > Rec2.StrField
  Equal -- Rec1.StrField = Rec2.StrField
}
begin
  if Rec1.StrField < Rec2.StrField then
  begin
    Result := Less
  end
  else if Rec1.StrField > Rec2.StrField then
  begin
    Result := More
  end
  else
  begin
    Result := Equal;
  end;
end;

function CompareNumValue(const Rec1, Rec2: TRecord): TCompareResult;
{ Сравнивает две записи по числовым полям.

  Аргументы
  Rec1, Rec2-- записи.

  Возращает значение перечислимого типа TCompareResult:
  Less -- Rec1.NumField < Rec2.NumField
  More -- Rec1.NumField > Rec2.NumField
  Equal -- Rec1.NumField = Rec2.NumField
}
begin
  if Rec1.NumField < Rec2.NumField then
  begin
    Result := Less
  end
  else if Rec1.NumField > Rec2.NumField then
  begin
    Result := More
  end
  else
  begin
    Result := Equal;
  end;
end;

function CompareStrValueAndRec(const Rec: TRecord; const StrValue: Variant)
  : TCompareResult;
{ Сравнивает строковое поле записи и
  заданную строку.

  Аргументы
  Rec -- запись.
  Strvalue -- строка, с которым сравнивают


  Возращает значение перечислимого типа TCompareResult
  Less -- Rec.StrField < Rec2.StrField
  More -- Rec.StrField > Rec2.StrField
  Equal -- Rec.StrField = Rec2.StrField
}
begin
  if Rec.StrField < string(StrValue) then
  begin
    Result := Less
  end
  else if Rec.StrField > string(StrValue) then
  begin
    Result := More
  end
  else
  begin
    Result := Equal;
  end;
end;

function CompareNumValueAndRec(const Rec: TRecord; const NumValue: Variant)
  : TCompareResult;
{ Сравнивает числовое поле записи и
  заданное число.

  Аргументы
  Rec -- запись.
  NumValue -- число, с которым идет сравнение.

  Возращает значение перечислимого типа TCompareResult
  Less -- Rec.NumField < NumValue
  More -- Rec.NumField > NumValue
  Equal -- Rec.NumField = NumValue
}
begin
  if Rec.NumField < (NumValue) then
  begin
    Result := Less
  end
  else if Rec.NumField > (NumValue) then
  begin
    Result := More
  end
  else
  begin
    Result := Equal;
  end;
end;

procedure SortArray(var Arr: TArr; const CompareValue: TCompareValue);
{ Сортирует массив записей вставками.

  Аргументы:
  Arr -- массив записей.
  CompareValue -- функция для сравнения двух записей.
}
var
  TempRecord: TRecord;
  CompareResult: TCompareResult;

  i, j: integer;
begin

  for i := 2 to Length(Arr) do
  begin
    TempRecord := Arr[i];
    j := i - 1;
    CompareResult := CompareValue(TempRecord, Arr[j]);

    while (j > 0) and (CompareResult = Less) do
    begin
      Arr[j + 1] := Arr[j];
      Dec(j);
      CompareResult := CompareValue(TempRecord, Arr[j]);
    end;

    Inc(j);
    Arr[j] := TempRecord;
  end;

end;

function CalcFieldTrue(var Arr: TArr): Word;
{ Считает сколько записей в массиве имеют
  в 3 поле значение TRUE.

  Аргументы:
  Arr -- массив записей.
}
var
  i: Word;

begin
  Result := 0;
  for i := 1 to Length(Arr) do
  begin
    if Arr[i].BoolField then
    begin
      Inc(Result);
    end;
  end;
end;

function BlockSearch(var Arr: TArr; const SearchValue: Variant;
  const CompareValueAndRec: TCompareValueAndRec): Word;
{ Находит элемент через блочный поиск. Каждый
  раз, когда происходит сравнение значения
  поля с веденным значением, то полю 3
  присваивается значение True.

  Аргументы:
  Arr -- массив записей.
  SearchValue -- искомое значение, должен быть или
  String, или Word.
  CompareValueAndRec -- функция, которая будет сравнивать
  SearchValue и поле записи, у которого
  тип совпадает с искомым значение,
  из массива Arr.

  Возращает индекс записи в Arr. Если элемента
  не существует, то возращает 0.
}
var
  step: Word;
  CompareResult: TCompareResult;

  Left: Word;
  Right: Word;
  Current: Word;

  CurrentString: String;

begin
  Result := 0;

  Left := 0;
  Right := Length(Arr);
  step := Trunc(Sqrt(Right));

  repeat
    Current := Left + step;
    if (Current > Right) then
    begin
      Current := Right;
      step := Right - Left;
    end;

    CurrentString := Arr[Current].StrField;
    Arr[Current].BoolField := True;
    CompareResult := CompareValueAndRec(Arr[Current], SearchValue);

    if CompareResult = Equal then
    begin
      Result := Current;
      Left := Right + 1;
    end
    else if CompareResult = More then
    begin
      Left := Current - step;
      Right := Current - 1;
      step := Trunc(Sqrt(step - 1));
    end
    else // CompareResult = Less
    begin
      Left := Current;
    end;

  until Right <= Left;

end;

function BinSearch(var Arr: TArr; const SearchValue: Variant;
  const CompareValueAndRec: TCompareValueAndRec): Word;
{ Находит элемент через бинарный поиск.
  Каждый раз, когда происходит сравнение
  значения поля с веденным значением, то
  полю 3 присваивается значение True.

  Аргументы:
  Arr -- массив записей.
  SearchValue -- искомое значение, должен быть или
  String, или Word.
  CompareValueAndRec -- функция, которая будет сравнивать
  SearchValue и поле записи, у которого
  тип совпадает с искомым значение,
  из массива Arr.

  Возращает индекс записи в Arr.
}
var
  LeftBoardIndex: Word;
  RightBoardIndex: Word;
  MiddleIndex: Word;
  CompareResult: TCompareResult;

begin
  Result := 0;
  LeftBoardIndex := 1;
  RightBoardIndex := Length(Arr);

  repeat
    MiddleIndex := (LeftBoardIndex + RightBoardIndex) div 2;
    CompareResult := CompareValueAndRec(Arr[MiddleIndex], SearchValue);

    if (CompareResult = Equal) then
    begin
      LeftBoardIndex := RightBoardIndex + 1;
      Result := MiddleIndex;
    end
    else if (CompareResult = More) then
    begin
      RightBoardIndex := MiddleIndex - 1;
    end
    else // CompareResult = Less
    begin
      LeftBoardIndex := MiddleIndex + 1;
    end;
    Arr[MiddleIndex].BoolField := True;
  until RightBoardIndex < LeftBoardIndex;

  CompareResult := CompareValueAndRec(Arr[RightBoardIndex], SearchValue);
  if (CompareResult = Equal) then
  begin
    Result := RightBoardIndex;
    Arr[RightBoardIndex].BoolField := True;
  end;

end;

function FindSameLeftEl(var Arr: TArr; const FindedIndex: Word): Word;
{ Находит все элементы в массиве, которые
  имеют такое же числовое поле, как и у
  записи Arr[Index], но при этом расположены
  левее.

  Аргументы:
  Arr -- исходный массив.
  Index -- индекс исходного элемента.

  Возращает номер самого левого элемента.
}
var
  ValueIndexEl: Word;
  i: SmallInt;

begin
  ValueIndexEl := Arr[FindedIndex].NumField;

  if FindedIndex = Low(Arr) then
  begin
    i := FindedIndex;
    Arr[i].BoolField := True;
  end
  else
  begin
    i := FindedIndex - 1;
    Arr[i].BoolField := True;
  end;

  while (i > Low(Arr)) and (Arr[i].NumField = ValueIndexEl) do
  begin
    Dec(i);
    Arr[i].BoolField := True;
  end;

  if (i = Low(Arr)) and (Arr[i].NumField = ValueIndexEl) then
  begin
    Arr[i].BoolField := True;
    Result := i;
  end
  else
  begin
    Result := i + 1;
  end;
end;

function FindSameRightEl(var Arr: TArr; const FindedIndex: Word): Word;
{ Находит все элементы в массиве, которые
  имеют такое же числовое поле, как и у
  записи Arr[Index], но при этом расположены
  правее.

  Аргументы:
  Arr -- исходный массив.
  Index -- индекс исходного элемента.

  Возращает номер самого левого элемента.
}
var
  ValueIndexEl: Byte;
  i: SmallInt;

begin
  ValueIndexEl := Arr[FindedIndex].NumField;

  if FindedIndex = High(Arr) then
  begin
    i := FindedIndex;
    Arr[i].BoolField := True;
  end
  else
  begin
    i := FindedIndex + 1;
    Arr[i].BoolField := True;
  end;

  while (i < High(Arr)) and (Arr[i].NumField = ValueIndexEl) do
  begin
    Inc(i);
    Arr[i].BoolField := True;
  end;

  if (i = High(Arr)) and (Arr[i].NumField = ValueIndexEl) then
  begin
    Arr[i].BoolField := True;
    Result := i;
  end
  else
  begin
    Result := i - 1;
  end;
end;

procedure WritelnResultSearch(const Arr: TArr; const FromEl, ToEl: Word;
  const SearchWord: Variant);
{ Выводит все найденные записи от FromEl
  до ToEl. Если FromEl = 0, то выводит
  сообщение о том, что элемент не найден.

  Аргументы:
  Arr -- массив, где хранится запись.
  Index -- индекс элемента (0 если аргументы нет).
  SearchWord -- искомое слово. Должно принимать значение
  типов String или word.
}
const
  HeadName = '| NumField |   StrField   | BoolField |';
var
  HeadNameLen: Byte;
  i: Word;

begin
  if FromEl <> 0 then
  begin
    Writeln('[SUCCESS] ''', SearchWord, ''' founded');

    Writeln(HeadName);
    for i := FromEl to ToEl do
    begin
      WriteRecord(Arr[i]);
    end;
  end
  else
  begin
    Writeln('[FAIL] ''', SearchWord, ''' doesn''t found');
  end;
end;

procedure CompareSearches(const SearchedValue: Variant;
  const BinResult, BlockResult: Word);
{ Выводит на экран в виде таблицы скорость
  работы бинарного и блочного поисков.

  Аргументы:
  SearchedValue -- искомое значение, по которому сравнивают.
  Должен передаваться или String, или Word.
  BinResult -- скорость бинарного поиска.
  Blockresult -- скорость блочного поиска.
}
var
  i: Byte;
begin
  Writeln('| Searched value | Binary | Block |');

  Write('| ');
  Write(SearchedValue:14);
  Write(' | ');
  Write(BinResult:6);
  Write(' | ');
  Write(BlockResult:5);
  Writeln(' |');
end;

procedure ClearBoolField(var Arr: TArr);
var
  i: integer;
begin
  for i := Low(Arr) to High(Arr) do
  begin
    Arr[i].BoolField := False;
  end;
end;

procedure FillStrValues(const Arr: TArr; var StrValues: TStrValues);
{ Заполнение тестового массива строк }
begin
  StrValues[1] := Arr[1].StrField;
  StrValues[2] := Arr[2].StrField;
  StrValues[3] := Arr[90].StrField;
  StrValues[4] := Arr[96].StrField;
  StrValues[5] := Arr[986].StrField;
  StrValues[6] := 'my_test_9898';
  StrValues[7] := '';
  StrValues[8] := '   1';
  StrValues[9] := 'MY_TEST_1';
  StrValues[10] := 'z!@#$';
end;

procedure FillNumValues(const Arr: TArr; var NumValues: TNumValues);
{ Заполнение тестового массива чисел }
begin
  NumValues[1] := Arr[1].NumField;
  NumValues[2] := Arr[2].NumField;
  NumValues[3] := Arr[90].NumField;
  NumValues[4] := Arr[96].NumField;
  NumValues[5] := Arr[986].NumField;
  NumValues[6] := 1000;
  NumValues[7] := 1425;
  NumValues[8] := 201;
  NumValues[9] := 202;
  NumValues[10] := -210;
end;

var
  Arr: TArr;
  TrueArr: TArr;
  SearchWord: string;
  SearchNumberBuffer: string;
  SearchNumber: integer;

  FuncCompareStrValue: TCompareValue;
  FuncCompareNumValue: TCompareValue;
  FuncCompareStrValueAndRec: TCompareValueAndRec;
  FuncCompareNumValueAndRec: TCompareValueAndRec;

  BinSearchSteps: Word;
  BlockSearchSteps: Word;

  FindedIndex: Word;
  LeftEl: Word;
  RightEl: Word;

  i: integer;
  StrValues: TStrValues;
  NumValues: TNumValues;

  ErrorCode: integer;

begin
  { Инициализация функций }
  FuncCompareStrValue := CompareStrValue;
  FuncCompareNumValue := CompareNumValue;
  FuncCompareStrValueAndRec := CompareStrValueAndRec;
  FuncCompareNumValueAndRec := CompareNumValueAndRec;

  { Генерация и вывод массива }
  GenerateArr(Arr);
  WriteArray(Arr);

  { -------------------------------------------------------------------------- }

  { Сортировка и вывод массива }
  SortArray(Arr, FuncCompareStrValue);
  WriteArray(Arr);

  { Ввод значения поиска }
  Write('Enter string: ');
  Readln(SearchWord);

  { Бинарный поиск }
  Writeln('Binary search');
  FindedIndex := BinSearch(Arr, SearchWord, FuncCompareStrValueAndRec);
  BinSearchSteps := CalcFieldTrue(Arr);
  WriteArray(Arr);

  Writeln('Bin search result:');
  WritelnResultSearch(Arr, FindedIndex, FindedIndex, SearchWord);

  ClearBoolField(Arr);

  Writeln('Press Enter to continue.');
  Readln;

  { Блочный поиск }
  Writeln('Block search');
  FindedIndex := BlockSearch(Arr, SearchWord, FuncCompareStrValueAndRec);
  BlockSearchSteps := CalcFieldTrue(Arr);
  WriteArray(Arr);

  Writeln('Block search result:');
  WritelnResultSearch(Arr, FindedIndex, FindedIndex, SearchWord);

  ClearBoolField(Arr);

  { Сравнение бинарного и блочного поисков }
  CompareSearches(SearchWord, BinSearchSteps, BlockSearchSteps);
  Writeln('Press Enter to continue.');
  Readln;

  { -------------------------------------------------------------------------- }

  { Сортировка и вывод массива }
  SortArray(Arr, FuncCompareNumValue);
  WriteArray(Arr);

  { Ввод значения поиска }
  repeat
    Write('Enter number: ');
    Readln(SearchNumberBuffer);
    val(SearchNumberBuffer, SearchNumber, ErrorCode);
  until ErrorCode = 0;

  { Бинарный поиск }
  Writeln('Binary search');
  FindedIndex := BinSearch(Arr, SearchNumber, FuncCompareNumValueAndRec);
  LeftEl := FindSameLeftEl(Arr, FindedIndex);
  RightEl := FindSameRightEl(Arr, FindedIndex);
  BinSearchSteps := CalcFieldTrue(Arr);
  WriteArray(Arr);

  Writeln('Bin search result:');
  WritelnResultSearch(Arr, LeftEl, RightEl, SearchNumber);

  ClearBoolField(Arr);

  Writeln('Press Enter to continue.');
  Readln;

  { Блочный поиск }
  FindedIndex := BlockSearch(Arr, SearchNumber, FuncCompareNumValueAndRec);
  LeftEl := FindSameLeftEl(Arr, FindedIndex);
  RightEl := FindSameRightEl(Arr, FindedIndex);
  BlockSearchSteps := CalcFieldTrue(Arr);
  WriteArray(Arr);

  Writeln('Block search result:');
  WritelnResultSearch(Arr, LeftEl, RightEl, SearchNumber);

  ClearBoolField(Arr);

  { Сравнение бинарного и блочного поисков }
  CompareSearches(SearchNumber, BinSearchSteps, BlockSearchSteps);
  Writeln('Press Enter to continue.');
  Readln;

  { -------------------------------------------------------------------------- }

  FillStrValues(Arr, StrValues);
  FillNumValues(Arr, NumValues);

  Writeln('[TEST]');

  for i := 1 to High(StrValues) do
  begin
    SortArray(Arr, FuncCompareStrValue);

    SearchWord := StrValues[i];

    FindedIndex := BinSearch(Arr, SearchWord, FuncCompareStrValueAndRec);
    BinSearchSteps := CalcFieldTrue(Arr);

    ClearBoolField(Arr);

    FindedIndex := BlockSearch(Arr, SearchWord, FuncCompareStrValueAndRec);
    BlockSearchSteps := CalcFieldTrue(Arr);

    CompareSearches(SearchWord, BinSearchSteps, BlockSearchSteps);
  end;

  for i := 1 to High(NumValues) do
  begin
    ClearBoolField(Arr);
    SortArray(Arr, FuncCompareNumValue);
    SearchNumber := NumValues[i];

    FindedIndex := BinSearch(Arr, SearchNumber, FuncCompareNumValueAndRec);
    LeftEl := FindSameLeftEl(Arr, FindedIndex);
    RightEl := FindSameRightEl(Arr, FindedIndex);
    BinSearchSteps := CalcFieldTrue(Arr);

    ClearBoolField(Arr);

    FindedIndex := BlockSearch(Arr, SearchNumber, FuncCompareNumValueAndRec);
    LeftEl := FindSameLeftEl(Arr, FindedIndex);
    RightEl := FindSameRightEl(Arr, FindedIndex);
    BlockSearchSteps := CalcFieldTrue(Arr);

    CompareSearches(SearchNumber, BinSearchSteps, BlockSearchSteps);
  end;

  Readln;

end.
