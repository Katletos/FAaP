Unit UI;

Interface

procedure ClearConsole;
procedure PressEnter;
procedure ShowSplash;
function ReadOption: Word;
function GetOption(const numbers: array of Word;
  const Options: array of String): Word;

Implementation

uses
  Windows;

procedure ClearConsole;
var
  hConsole: Thandle;
  ConsoleInfo: TConsoleScreenBufferInfo;
  Coord: TCoord;
  WrittenChars: LongWord;
begin
  FillChar(ConsoleInfo, SizeOf(ConsoleInfo), 0);
  FillChar(Coord, SizeOf(Coord), 0);
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(hConsole, ConsoleInfo);
  FillConsoleOutputCharacter(hConsole, ' ', ConsoleInfo.dwSize.X *
    ConsoleInfo.dwSize.Y, Coord, WrittenChars);
  SetConsoleCursorPosition(hConsole, Coord);
end;

procedure ShowSplash;
begin
  ClearConsole;
  WriteLn('########################################################');
  WriteLn('#                 Учёт товара магазина                 #');
  WriteLn('########################################################');
  WriteLn;
end;

procedure PressEnter; inline;
const
  ShowingMessage = 'Press enter to continue.';
begin
  WriteLn(ShowingMessage);
  ReadLn;
end;

function ReadOption: Word;
var
  Error: Boolean;
begin
  Error := True;

  repeat
    try
      begin
        ReadLn(Result);
        Error := False;
      end;
    except
      begin
        WriteLn('[Error] Please reenter!');
        Error := True;
      end;
    end;

  until not Error;
end;

function GetOption(const numbers: array of Word;
  const Options: array of String): Word;
var
  i: Word;
  Found: Boolean;
begin
  for i := Low(numbers) to High(numbers) do
  begin
    WriteLn(numbers[i]:4, ':', Options[i]);
  end;

  Found := False;
  repeat
    Write('Enter correct option: ');
    Result := ReadOption();
    i := Low(numbers);
    while (i <= High(numbers)) and not(Found) do
    begin
      if Result = numbers[i] then
      begin
        Found := True;
      end;
      Inc(i);
    end;
  until Found;
end;

Begin

End.
