program _37;
{$APPTYPE CONSOLE}

uses
  SysUtils, Windows;
  
type
  TMn = set of 'a'..'z';

var
  Text:string;

procedure My_Edited_Text (var Text: string);
  const
  BigWords:set of 'A'..'Z' = ['A'..'Z'];
  LittleWords:set of 'a'..'z' = ['a'..'z'];
  var
  x, i: Integer;
  list: TMn;
  begin
    list:=[];
    for i:=1 to Length(Text) do
    begin
      if (not([Text[i]] <= BigWords)) and (not([Text[i]] <= LittleWords)) then
        Text[i]:='?'
      else
      begin
        if [Text[i]] <= BigWords then
        begin
          x:=ord(Text[i]);
          Text[i]:= Chr(x+32);
        end;
        if [Text[i]] <= list then
          Text[i]:='*'
        else
          list:= list + [Text[i]];
      end;
    end;
  end;

begin
  SetConsoleCP(1251);
  SetConsoleOutPutCP(1251);

  Writeln('¬ведите исходный текст:');
  Readln(Text);
  if Text = '' then
    Writeln('¬ведена пуста€ строка')
  else
  begin
    My_Edited_Text(Text);

    Writeln('—корректированный текст:');
    Writeln(Text);
  end;
  Readln;
end.
