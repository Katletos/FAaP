program Project4;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UI;

const
  PRODUCT_FILE_NAME = 'Product.lst';
  INFORMATION_TYPE_FILE_NAME = 'InfType.lst';

  PRODUCT_TXT = 'Product.txt';
  INFORMATION_TYPE_TXT = 'InfType.txt';
  // MAX_INDEX_PRODUCT = '.indx';

  ProductHeader =
    '| ID | Inf ID |         NAME         |        AUTHOR        |   PRICE    |       PARAM 1        |       PARAM 2        |         NOTE         |';
  InfTypeHeader =
    '| Inf ID |         NAME         |       PARAM 1        |       PARAM 2        |';

type

  pInfTypeElement = ^TInfTypeElement;

  TInfType = record
    ID_INFO: integer;
    NAME: string[20];
    PARAM_NAME_1: string[20];
    PARAM_NAME_2: string[20];
  end;

  TInfTypeElement = record
    Data: TInfType;
    Next: pInfTypeElement;
  end;

  { --------------------------------- }

  pProductElement = ^TProductElement;

  TProduct = record
    ID_PRODUCT: integer;
    ID_INF_TYPE: integer;
    NAME: string[20];
    AUTHOR: string[20];
    PRICE: integer;
    PARAM_VALUE_1: string[20];
    PARAM_VALUE_2: string[20];
    NOTE: string[20];
  end;

  TProductElement = record
    Data: TProduct;
    Next: pProductElement;
  end;

  { --------------------------------- }
  TProductFile = file of TProduct;
  TInfTypeFile = file of TInfType;

  TProductTxt = TextFile;
  TInfTypeTxt = TextFile;

  TcompProduct = function(a, b: pProductElement): boolean;
  TcompInfType = function(a, b: pInfTypeElement): boolean;
  TequalProduct = function(a: pProductElement; b: string): boolean;
  { --------------------------------- }

function InputString(): string;
var
  Str: string;
  isCorrect: boolean;
begin
  repeat
    ReadLn(Str);

    isCorrect := (Str.Length < 20) and (Str.Length > 0);

    if isCorrect then
    begin
      Result := AnsiLowerCase(Str);
    end
    else
    begin
      WriteLn('[Error] Incorrect input, try again');
    end;
  until isCorrect;
end;

function InputNumber(): integer;
var
  e: integer;
  Number: integer;
  Str: string;
begin
  repeat
    ReadLn(Str);
    Val(Str, Number, e);

    if (e <> 0) and (Str.Length = 0) and (Number > 0) then
    begin
      WriteLn('[Error] Incorrect input, try again');
    end
    else
    begin
      Result := Number;
    end;
  until (e = 0) and (Str.Length <> 0) and (Number > 0);
end;

procedure PrintIsFound(var Found: boolean); inline;
begin
  if Found then
  begin
    WriteLn('[Sucsess] record found');
  end
  else
  begin
    WriteLn('[Error] record don''t found');
  end;
end;

procedure PrintProduct(const Temp: pProductElement); inline;
begin
  with Temp^.Data do
  begin
    Write('| ');
    Write(ID_PRODUCT:2);
    Write(' | ');
    Write(ID_INF_TYPE:6);
    Write(' | ');
    Write(Name:20);
    Write(' | ');
    Write(AUTHOR:20);
    Write(' | ');
    Write(PRICE:10);
    Write(' | ');
    Write(PARAM_VALUE_1:20);
    Write(' | ');
    Write(PARAM_VALUE_2:20);
    Write(' | ');
    Write(NOTE:20);
    Write(' | ');
    WriteLn;
  end;
end;

procedure PrintInfType(const Temp: pInfTypeElement); inline;
begin
  with Temp^.Data do
  begin
    Write('| ');
    Write(ID_INFO:6);
    Write(' | ');
    Write(Name:20);
    Write(' | ');
    Write(PARAM_NAME_1:20);
    Write(' | ');
    Write(PARAM_NAME_2:20);
    Write(' |');
    WriteLn;
  end;
end;

procedure EditProduct(var El: pProductElement; const ID: integer);
begin
  with El^.Data do
  begin
    ID_INF_TYPE := ID;

    Write('Enter Name: ');
    Name := InputString();

    Write('Enter Author: ');
    AUTHOR := InputString();;

    Write('Enter Price: ');
    PRICE := InputNumber();;

    Write('Enter param value 1: ');
    PARAM_VALUE_1 := InputString();

    Write('Enter param value 2: ');
    PARAM_VALUE_2 := InputString();

    Write('Enter Note: ');
    ReadLn(NOTE);
  end;
end;

procedure EditInfType(var El: pInfTypeElement);
begin
  with El^.Data do
  begin
    Write('Enter NAME: ');
    Name := InputString();
    Write('Enter PARAM_NAME_1: ');
    PARAM_NAME_1 := InputString();
    Write('Enter PARAM_NAME_2: ');
    PARAM_NAME_2 := InputString();
  end;
end;

function isProductInList(const Head: pProductElement; var SearchWord: string;
  var ID: integer): boolean;

var
  Temp: pProductElement;

begin
  Temp := Head;
  Result := false;

  while (Temp^.Next <> nil) do
  begin
    if (Temp^.Next.Data.NAME = SearchWord) and (Temp^.Next.Data.ID_PRODUCT = ID)
    then
    begin
      Result := true;

      PrintProduct(Temp^.Next);
    end;

    Temp := Temp^.Next;
  end;
end;

function isInfTypeInList(const Head: pInfTypeElement; var SearchWord: string;
  var ID: integer): boolean;
var
  Temp: pInfTypeElement;
begin
  Temp := Head;
  Result := false;

  while (Temp^.Next <> nil) do
  begin
    if (Temp^.Next.Data.NAME = SearchWord) and (Temp^.Next.Data.ID_INFO = ID)
    then
    begin
      Result := true;

      PrintInfType(Temp^.Next);
    end;

    Temp := Temp^.Next;
  end;
end;

procedure InitLists(var HeadProduct: pProductElement;
  var HeadInfType: pInfTypeElement);
var
  TempProduct: pProductElement;
  TempInfType: pInfTypeElement;
begin
  New(TempProduct);
  HeadProduct := TempProduct;
  TempProduct^.Next := nil;

  New(TempInfType);
  HeadInfType := TempInfType;
  TempInfType^.Next := nil;
end;

procedure ReadProduct(var Head: pProductElement; var ProductFile: TProductFile;
  var MaxProductID: integer);
var
  Temp: pProductElement;
begin
  if FileExists(PRODUCT_FILE_NAME) then
  begin
    AssignFile(ProductFile, PRODUCT_FILE_NAME);
    Reset(ProductFile);

    Temp := Head;

    while not EOF(ProductFile) do
    begin
      New(Temp^.Next);
      Temp := Temp^.Next;
      Read(ProductFile, Temp^.Data);

      while MaxProductID < Temp^.Data.ID_PRODUCT do
      begin
        inc(MaxProductID);
      end;
    end;

    Temp^.Next := nil;
    CloseFile(ProductFile);
  end;
end;

procedure ReadInfType(var Head: pInfTypeElement; var InfTypeFile: TInfTypeFile;
  var MaxInfTypeID: integer);
var
  Temp: pInfTypeElement;
begin
  if FileExists(INFORMATION_TYPE_FILE_NAME) then
  begin
    AssignFile(InfTypeFile, INFORMATION_TYPE_FILE_NAME);
    Reset(InfTypeFile);

    Temp := Head;

    while not EOF(InfTypeFile) do
    begin
      New(Temp^.Next);
      Temp := Temp^.Next;
      Read(InfTypeFile, Temp^.Data);

      while MaxInfTypeID < Temp^.Data.ID_INFO do
      begin
        inc(MaxInfTypeID);
      end;
    end;

    Temp^.Next := nil;
    CloseFile(InfTypeFile);
  end;
end;

procedure WriteProduct(const Head: pProductElement;
  var ProductFile: TProductFile);
var
  Temp: pProductElement;
begin
  AssignFile(ProductFile, PRODUCT_FILE_NAME);
  ReWrite(ProductFile);

  Temp := Head^.Next;

  while Temp <> nil do
  begin
    write(ProductFile, Temp^.Data);
    Temp := Temp^.Next;
  end;

  CloseFile(ProductFile);
end;

procedure WriteInfType(const Head: pInfTypeElement;
  var InfTypeFile: TInfTypeFile);
var
  Temp: pInfTypeElement;
begin
  AssignFile(InfTypeFile, INFORMATION_TYPE_FILE_NAME);
  ReWrite(InfTypeFile);

  Temp := Head^.Next;

  while Temp <> nil do
  begin
    write(InfTypeFile, Temp^.Data);
    Temp := Temp^.Next;
  end;

  CloseFile(InfTypeFile);
end;

procedure WriteProductTxt(const Head: pProductElement;
  var ProductTxt: TextFile);
var
  Temp: pProductElement;
begin
  AssignFile(ProductTxt, PRODUCT_TXT);
  ReWrite(ProductTxt);

  Temp := Head^.Next;

  WriteLn(ProductTxt, ProductHeader);

  while Temp <> nil do
  begin
    with Temp^.Data do
    begin
      Write(ProductTxt, '| ');
      Write(ProductTxt, ID_PRODUCT:2);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, ID_INF_TYPE:6);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, Name:20);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, AUTHOR:20);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, PRICE:10);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, PARAM_VALUE_1:20);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, PARAM_VALUE_2:20);
      Write(ProductTxt, ' | ');
      Write(ProductTxt, NOTE:20);
      Write(ProductTxt, ' | ');
      WriteLn(ProductTxt);
    end;

    Temp := Temp^.Next;
  end;

  CloseFile(ProductTxt);
end;

procedure WriteInfTypeTxt(const Head: pInfTypeElement;
  var InfTypeTxt: TextFile);
var
  Temp: pInfTypeElement;
begin
  AssignFile(InfTypeTxt, INFORMATION_TYPE_TXT);
  ReWrite(InfTypeTxt);

  Temp := Head^.Next;

  WriteLn(InfTypeTxt, InfTypeHeader);

  while Temp <> nil do
  begin
    with Temp^.Data do
    begin
      Write(InfTypeTxt, '| ');
      Write(InfTypeTxt, ID_INFO:6);
      Write(InfTypeTxt, ' | ');
      Write(InfTypeTxt, Name:20);
      Write(InfTypeTxt, ' | ');
      Write(InfTypeTxt, PARAM_NAME_1:20);
      Write(InfTypeTxt, ' | ');
      Write(InfTypeTxt, PARAM_NAME_2:20);
      Write(InfTypeTxt, ' | ');
      WriteLn(InfTypeTxt);
    end;

    Temp := Temp^.Next;
  end;

  CloseFile(InfTypeTxt);
end;

procedure PrintProductList(const Head: pProductElement);
var
  Temp: pProductElement;
begin
  Temp := Head^.Next;
  WriteLn(ProductHeader);

  while Temp <> nil do
  begin
    PrintProduct(Temp);

    Temp := Temp^.Next;
  end;

end;

procedure PrintInfTypeList(const Head: pInfTypeElement);
var
  Temp: pInfTypeElement;
begin
  Temp := Head^.Next;
  WriteLn(InfTypeHeader);

  while Temp <> nil do
  begin
    PrintInfType(Temp);

    Temp := Temp^.Next;
  end;
end;

procedure swapProduct(a, b: pProductElement); inline;
var
  Temp: pProductElement;
begin
  Temp := a^.Next;
  a^.Next := b^.Next;
  b^.Next := Temp;

  Temp := a^.Next^.Next;
  a^.Next^.Next := b^.Next^.Next;
  b^.Next^.Next := Temp;
end;

procedure swapInfType(a, b: pInfTypeElement); inline;
var
  Temp: pInfTypeElement;
begin
  Temp := a^.Next;
  a^.Next := b^.Next;
  b^.Next := Temp;

  Temp := a^.Next^.Next;
  a^.Next^.Next := b^.Next^.Next;
  b^.Next^.Next := Temp;
end;

function cmpInfTypeName(a, b: pInfTypeElement): boolean;
begin
  Result := a^.Data.NAME < b^.Data.NAME;
end;

function cmpProductName(a, b: pProductElement): boolean;
begin
  Result := a^.Data.NAME < b^.Data.NAME;
end;

function cmpProductAuthor(a, b: pProductElement): boolean;
begin
  Result := a^.Data.AUTHOR < b^.Data.AUTHOR;
end;

function cmpProductIDName(a, b: pProductElement): boolean;
begin
  if a^.Data.ID_INF_TYPE = b^.Data.ID_INF_TYPE then
  begin
    Result := a^.Data.NAME < b^.Data.NAME;
  end
  else
  begin
    Result := a^.Data.ID_INF_TYPE < b^.Data.ID_INF_TYPE;
  end;
end;

function cmpProductIDAuthor(a, b: pProductElement): boolean;
begin
  if a^.Data.ID_INF_TYPE = b^.Data.ID_INF_TYPE then
  begin
    Result := a^.Data.AUTHOR < b^.Data.AUTHOR;
  end
  else
  begin
    Result := a^.Data.ID_INF_TYPE < b^.Data.ID_INF_TYPE;
  end;
end;

procedure sortProduct(Head: pProductElement; const Comp: TcompProduct);
var
  Temp, min: pProductElement;
begin

  while (Head^.Next^.Next <> nil) do
  begin
    min := Head;
    Temp := Head^.Next;

    while (Temp^.Next <> nil) do
    begin
      if Comp(Temp^.Next, min^.Next) then
      begin
        min := Temp;
      end;

      Temp := Temp^.Next;
    end;

    swapProduct(Head, min);
    Head := Head^.Next;
  end;
end;

procedure sortInfType(Head: pInfTypeElement; const Comp: TcompInfType);
var
  Temp, min: pInfTypeElement;
begin

  while (Head^.Next^.Next <> nil) do
  begin
    min := Head;
    Temp := Head^.Next;

    while (Temp^.Next <> nil) do
    begin
      if Comp(Temp^.Next, min^.Next) then
      begin
        min := Temp;
      end;

      Temp := Temp^.Next;
    end;

    swapInfType(Head, min);
    Head := Head^.Next;
  end;
end;

function equalProductName(a: pProductElement; b: string): boolean;
begin
  Result := a^.Data.NAME = b;
end;

function equalProductAuthor(a: pProductElement; b: string): boolean;
begin
  Result := a^.Data.AUTHOR = b;
end;

procedure SearchProduct(const Head: pProductElement; Comp: TequalProduct;
  const SearchWord: string; var Found: boolean);

var
  Temp: pProductElement;

  TempHead: pProductElement;
  TempS: pProductElement;
begin
  Found := false;
  Temp := Head;

  { New(TempHead);
    TempS := TempHead;
    TempS^.Next := nil; }

  while (Temp^.Next <> nil) do
  begin
    if Comp(Temp^.Next, SearchWord) then
    begin
      Found := true;
      PrintProduct(Temp^.Next);

      { New(TempS^.Next);
        TempS := TempS^.Next;
        TempS^.Data := Temp^.Data;
        TempS^.Next := nil; }
    end;

    Temp := Temp^.Next;
  end;

  // PrintProductList(TempHead);
end;

procedure SearchProductByID(const Head: pProductElement; const ID: integer;
  var Found: boolean);
var
  Temp: pProductElement;
begin
  Temp := Head;
  Found := false;

  while (Temp^.Next <> nil) do
  begin

    if Temp^.Next.Data.ID_PRODUCT = ID then
    begin
      Found := true;

      PrintProduct(Temp^.Next);
    end;

    Temp := Temp^.Next;
  end;
end;

procedure SearchProductByInfID(const Head: pProductElement; const ID: integer;
  var Found: boolean);
var
  Temp: pProductElement;
begin
  Temp := Head;
  Found := false;

  while (Temp^.Next <> nil) do
  begin

    if Temp^.Next.Data.ID_INF_TYPE = ID then
    begin
      Found := true;

      PrintProduct(Temp^.Next);
    end;

    Temp := Temp^.Next;
  end;
end;

procedure SearchInfTypeByName(const Head: pInfTypeElement;
  const SearchWord: string; var Found: boolean);
var
  Temp: pInfTypeElement;
begin
  WriteLn(InfTypeHeader);
  Temp := Head;
  Found := false;

  while (Temp^.Next <> nil) do
  begin
    if Temp^.Next.Data.NAME = SearchWord then
    begin
      Found := true;

      PrintInfType(Temp^.Next);
    end;

    Temp := Temp^.Next;
  end;

end;

procedure SearchInfTypeByID(const Head: pInfTypeElement; const ID: integer;
  var Found: boolean);
var
  Temp: pInfTypeElement;
begin
  WriteLn(InfTypeHeader);

  Temp := Head;
  Found := false;

  while (Temp^.Next <> nil) do
  begin

    if Temp^.Next.Data.ID_INFO = ID then
    begin
      Found := true;

      PrintInfType(Temp^.Next);
    end;

    Temp := Temp^.Next;
  end;
end;

function GetProduct(const Head: pProductElement; const ID: integer)
  : pProductElement;
var
  Temp: pProductElement;
  Found: boolean;
begin
  Found := false;
  Temp := Head;

  while (Temp^.Next <> nil) and not(Found) do
  begin

    if Temp^.Next.Data.ID_PRODUCT = ID then
    begin
      Result := Temp^.Next;
      Found := true;
    end;

    Temp := Temp^.Next;
  end;
end;

function GetInfType(const Head: pInfTypeElement; const ID: integer)
  : pInfTypeElement;
var
  Temp: pInfTypeElement;
  Found: boolean;
begin
  Found := false;
  Temp := Head;

  while (Temp^.Next <> nil) and not(Found) do
  begin

    if Temp^.Next.Data.ID_INFO = ID then
    begin
      Result := Temp^.Next;
      Found := true;
    end;

    Temp := Temp^.Next;
  end;
end;

procedure AddProduct(const HeadProduct: pProductElement; const ID: integer;
  var MaxProductID: integer);
var
  HeadNext: pProductElement;
  Found: boolean;
begin

  HeadNext := HeadProduct^.Next;
  New(HeadProduct^.Next);
  with HeadProduct^.Next.Data do
  begin
    inc(MaxProductID);
    ID_PRODUCT := MaxProductID;

    ID_INF_TYPE := ID;

    Write('Enter Name: ');
    Name := InputString();

    Write('Enter Author: ');
    AUTHOR := InputString();

    Write('Enter Price: ');
    PRICE := InputNumber();

    Write('Enter param value 1: ');
    PARAM_VALUE_1 := InputString();

    Write('Enter param value 2: ');
    PARAM_VALUE_2 := InputString();

    Write('Enter Note: ');
    ReadLn(NOTE);
  end;

  HeadProduct^.Next^.Next := HeadNext;
end;

procedure AddInfType(const Head: pInfTypeElement; var MaxInfType: integer);
var
  HeadNext: pInfTypeElement;
  Input: integer;
begin

  HeadNext := Head^.Next;
  New(Head^.Next);

  with Head^.Next.Data do
  begin
    inc(MaxInfType);
    ID_INFO := MaxInfType;

    Write('Enter NAME: ');
    NAME := InputString();
    Write('Enter PARAM_NAME_1: ');
    PARAM_NAME_1 := InputString();
    Write('Enter PARAM_NAME_2: ');
    PARAM_NAME_2 := InputString();
  end;

  Head^.Next^.Next := HeadNext;
end;

procedure DeleteProduct(const Head: pProductElement; const ID: Cardinal);
var
  Temp: pProductElement;
  PrevEl: pProductElement;
begin
  PrevEl := Head;
  Temp := PrevEl^.Next;

  while (Temp^.Next <> nil) and (Temp^.Data.ID_PRODUCT <> ID) do
  begin
    PrevEl := Temp;
    Temp := Temp^.Next;
  end;

  PrevEl^.Next := Temp^.Next;
  Dispose(Temp);
end;

procedure DeleteInfType(const Head: pInfTypeElement; const ID: Cardinal);
var
  Temp: pInfTypeElement;
  PrevEl: pInfTypeElement;
begin
  PrevEl := Head;
  Temp := PrevEl^.Next;

  while (Temp^.Next <> nil) and (Temp^.Data.ID_INFO <> ID) do
  begin
    PrevEl := Temp;
    Temp := Temp^.Next;
  end;

  PrevEl^.Next := Temp^.Next;
  Dispose(Temp);
end;

procedure KillProduct(var Head: pProductElement);
var
  Temp: pProductElement;
  Buffer: pProductElement;
begin
  Temp := Head;
  while Temp <> nil do
  begin
    Buffer := Temp^.Next;
    Dispose(Temp);
    Temp := Buffer;
  end;
end;

procedure KillInfType(var Head: pInfTypeElement);
var
  Temp: pInfTypeElement;
  Buffer: pInfTypeElement;
begin
  Temp := Head;
  while Temp <> nil do
  begin
    Buffer := Temp^.Next;
    Dispose(Temp);
    Temp := Buffer;
  end;
end;

var
  Option: Cardinal;

  HeadInfType: pInfTypeElement;
  HeadProduct: pProductElement;

  ProductFile: TProductFile;
  InfTypeFile: TInfTypeFile;

  ProductTxt: TProductTxt;
  InfTypeTxt: TInfTypeTxt;

  SearchWord: string;
  ID: integer;
  Found: boolean;

  MaxInfTypeID: integer;
  MaxProductID: integer;

  Product: pProductElement;
  Inftype: pInfTypeElement;

Begin
  MaxInfTypeID := 0;
  MaxProductID := 0;
  InitLists(HeadProduct, HeadInfType);

  repeat
    ClearConsole;
    Option := GetOption([1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      ['Read data from file', 'Show lists', 'Sort list', 'Search', 'Add',
      'Delete', 'Edit', 'Export to the txt file', 'Exit without save',
      'Exit with save']);

    case Option of
      1:
        begin
          ReadProduct(HeadProduct, ProductFile, MaxProductID);
          ReadInfType(HeadInfType, InfTypeFile, MaxInfTypeID);
          ClearConsole;
          WriteLn('[SUCSESS] data read successfully');
          PressEnter;
        end;
      2:
        begin
          ClearConsole;
          Option := GetOption([1, 2],
            ['Show products', 'Show information type']);

          case Option of
            1:
              begin
                ClearConsole;
                PrintProductList(HeadProduct);
                PressEnter;
              end;
            2:
              begin
                ClearConsole;
                PrintInfTypeList(HeadInfType);
                PressEnter;
              end;
          end;
        end;
      3:
        begin
          ClearConsole;
          Option := GetOption([1, 2, 3, 4, 5], ['Sort products by name',
            'Sort products by author', 'Sort products within each type by name',
            'Sort products within each type by author', 'Sort info by name']);

          case Option of
            1:
              begin
                ClearConsole;
                sortProduct(HeadProduct, cmpProductName);
              end;
            2:
              begin
                ClearConsole;
                sortProduct(HeadProduct, cmpProductAuthor);
              end;
            3:
              begin
                ClearConsole;
                sortProduct(HeadProduct, cmpProductIDName);
              end;
            4:
              begin
                ClearConsole;
                sortProduct(HeadProduct, cmpProductIDAuthor);
              end;
            5:
              begin
                ClearConsole;
                sortInfType(HeadInfType, cmpInfTypeName);
              end;
          end;
        end;
      4:
        begin
          ClearConsole;
          Option := GetOption([1, 2, 3], ['Search products by name',
            'Search products by author', 'Search inf type by name']);
          case Option of
            1:
              begin
                ClearConsole;
                write('Enter product name: ');
                SearchWord := InputString();

                ClearConsole;
                SearchProduct(HeadProduct, equalProductName, SearchWord, Found);
                PrintIsFound(Found);
                PressEnter;
              end;
            2:
              begin
                ClearConsole;
                write('Enter product author: ');
                SearchWord := InputString();

                ClearConsole;
                SearchProduct(HeadProduct, equalProductAuthor,
                  SearchWord, Found);
                PrintIsFound(Found);
                PressEnter;
              end;
            3:
              begin
                ClearConsole;
                write('Enter inf type name: ');
                SearchWord := InputString();

                ClearConsole;
                SearchInfTypeByName(HeadInfType, SearchWord, Found);
                PrintIsFound(Found);
                PressEnter;
              end;
          end;
        end;
      5:
        begin
          ClearConsole;
          Option := GetOption([1, 2], ['Add product', 'Add information type']);

          case Option of
            1:
              begin
                ClearConsole;
                Write('Enter ID inf: ');
                ID := InputNumber();

                SearchInfTypeByID(HeadInfType, ID, Found);
                if Found then
                begin
                  AddProduct(HeadProduct, ID, MaxProductID);
                  WriteLn('[SUCSESS] record add');
                end
                else
                begin
                  WriteLn('Add information type first');
                end;
                PressEnter;
              end;
            2:
              begin
                ClearConsole;
                AddInfType(HeadInfType, MaxInfTypeID);
                WriteLn('[SUCSESS] record add');
                PressEnter;
              end;
          end;
        end;
      6:
        begin
          ClearConsole;
          Option := GetOption([1, 2], ['Delete products', 'Delete inf type']);
          case Option of
            1:
              begin
                ClearConsole;
                PrintProductList(HeadProduct);

                write('Enter product name: ');
                SearchWord := InputString();

                ClearConsole;
                SearchProduct(HeadProduct, equalProductName, SearchWord, Found);

                if Found then
                begin
                  Write('Enter ID to delete: ');
                  ID := InputNumber();

                  if isProductInList(HeadProduct, SearchWord, ID) then
                  begin
                    DeleteProduct(HeadProduct, ID);
                    WriteLn('[Sucsess] record delete');
                    PressEnter;
                  end
                  else
                  begin
                    WriteLn('[Error] recor not in search list');
                    PressEnter;
                  end;
                end
                else
                begin
                  WriteLn('[Error] recor not in search list');
                  PressEnter;
                end;
              end;
            2:
              begin
                ClearConsole;

                PrintInfTypeList(HeadInfType);
                write('Enter inf type name: ');
                SearchWord := InputString();

                ClearConsole;
                SearchInfTypeByName(HeadInfType, SearchWord, Found);

                if Found then
                begin
                  Write('Enter ID to delete: ');
                  ID := InputNumber();
                  SearchProductByInfID(HeadProduct, ID, Found);

                  if Found then
                  begin
                    WriteLn('[ERROR] delete products before inf type');
                    PressEnter;
                  end
                  else
                  begin
                    if isInfTypeInList(HeadInfType, SearchWord, ID) then
                    begin
                      DeleteInfType(HeadInfType, ID);
                      WriteLn('[Sucsess] record delete');
                      PressEnter;
                    end
                    else
                    begin
                      WriteLn('[Error] recor not in search list');
                      PressEnter;
                    end;
                  end;
                end
                else
                begin
                  WriteLn('[Error] recor not in search list');
                  PressEnter;
                end;
              end;
          end;
        end;
      7:
        begin
          ClearConsole;
          Option := GetOption([1, 2], ['Edit products', 'Edit inf type']);
          case Option of
            1:
              begin
                ClearConsole;
                PrintProductList(HeadProduct);

                write('Enter product name: ');
                SearchWord := InputString();

                ClearConsole;
                SearchProduct(HeadProduct, equalProductName, SearchWord, Found);

                if Found then
                begin
                  Write('Enter ID to edit: ');
                  ID := InputNumber();

                  if isProductInList(HeadProduct, SearchWord, ID) then
                  begin
                    ClearConsole;

                    Product := GetProduct(HeadProduct, ID);
                    PrintProduct(Product);

                    Write('Enter Inf type ID: ');
                    ID := InputNumber();
                    SearchInfTypeByID(HeadInfType, ID, Found);

                    if Found then
                    begin
                      EditProduct(Product, ID);
                      WriteLn('[Sucsess] record edit');
                      PressEnter;
                    end
                    else
                    begin
                      WriteLn('[ERROR] incorrect ID');
                      PressEnter;
                    end;
                  end
                  else
                  begin
                    WriteLn('[Error] recor not in search list');
                    PressEnter;
                  end;
                end
                else
                begin
                  WriteLn('[Error] recor is not in search list');
                  PressEnter;
                end;
              end;
            2:
              begin
                ClearConsole;
                PrintInfTypeList(HeadInfType);
                write('Enter inf type name: ');
                SearchWord := InputString();

                ClearConsole;
                SearchInfTypeByName(HeadInfType, SearchWord, Found);
                if Found then
                begin
                  Write('Enter ID to edit: ');
                  ID := InputNumber();

                  if isInfTypeInList(HeadInfType, SearchWord, ID) then
                  begin
                    ClearConsole;

                    Inftype := GetInfType(HeadInfType, ID);
                    PrintInfType(Inftype);

                    EditInfType(Inftype);
                    WriteLn('[Sucsess] record edited');
                    PressEnter;
                  end
                  else
                  begin
                    WriteLn('[ERROR] recor is not in search list');
                    PressEnter;
                  end;
                end
                else
                begin
                  WriteLn('[Error] recor is not in search list');
                  PressEnter;
                end;
              end;
          end;
        end;
      8:
        begin
          ClearConsole;
          sortInfType(HeadInfType, cmpInfTypeName);
          sortProduct(HeadProduct, cmpProductIDAuthor);

          WriteProductTxt(HeadProduct, ProductTxt);
          WriteInfTypeTxt(HeadInfType, InfTypeTxt);

          WriteLn('[SUCSESS] Export lists to txt files');
          PressEnter;
        end;
      9:
        begin
          KillProduct(HeadProduct);
          KillInfType(HeadInfType);
        end;
      10:
        begin
          WriteProduct(HeadProduct, ProductFile);
          WriteInfType(HeadInfType, InfTypeFile);

          KillProduct(HeadProduct);
          KillInfType(HeadInfType);
        end;
    end;

  until (Option = 9) or (Option = 10);

End.
