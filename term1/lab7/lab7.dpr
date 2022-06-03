program laba7;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  N = 255;

type
  TArr = array [1 .. N] of string;

var
  S: string; { преобразованная строка }
  S1: string; { строка для первого пункта }
  S2: string; { строка для второго пункта }
  DefaultString: string; { исходная строка }

  CurrentWord: string; { текущее слово для проверки }
  Temp: string; { временная переменная для преобразований }
  LowerCase: string; { хранение преведённой к нижнему регмстру переменной Temp }
  letter: string; { для хранения последнего слова }

  SLen: integer; { длина строки }
  WordLen: integer; { длина слова }
  TopWordsArray: integer; { длина массива со словами }
  WordStart: integer; { индекс начала слова }
  i, j: integer; { ну вы поняли }

  IsCorrect: boolean; { для проверки на алфавитную последовательность }

  WordsArray: TArr; { массив подходящих слов }

  LengthS: integer;

Begin
  // abc abПрcd    aads asd as  A qwe qwe qwe a1b234c   AbC   a  a   a  A2b%^@#C1d  d  q  abc
  write('Input string S: ');
  readln(S);
  DefaultString := S;

  SLen := Length(S);
  if SLen > 0 then
  begin

    S := trim(S);

    SLen := Length(S);
    if SLen = 0 then
    begin
      writeln;
      writeln('Default String: ', DefaultString);
      writeln('The string S does not contain words');
      writeln('S1 is empty');
      writeln('S2 is empty');
    end
    else
    begin

      { удаление пробелов }
      i := pos(#32, S); // #32 - space
      while i <= SLen do // A
      begin
        if S[i] = #32 then
        begin
          inc(i);

          while S[i] = #32 do // B
          begin
            delete(S, i, 1);
          end;
        end;
        inc(i);
      end;

      { Создание массива слов }
      TopWordsArray := 0;
      i := 1;
      while i <= SLen do // С
      begin
        WordLen := 0;
        WordStart := i;

        while (i <= SLen) and (S[i] <> #32) do // D
        begin
          inc(WordLen);
          inc(i);
        end;

        inc(TopWordsArray);
        WordsArray[TopWordsArray] := copy(S, WordStart, WordLen);
        inc(i);
      end;

      { Удаление всех слов, похожих на последнее }
      CurrentWord := WordsArray[TopWordsArray];
      for i := 1 to TopWordsArray do // E
      begin
        if WordsArray[i] = CurrentWord then
          WordsArray[i] := #0;
      end;
      dec(TopWordsArray);

      { Удаление похожих слов }
      for i := 1 to TopWordsArray do // F
      begin
        CurrentWord := WordsArray[i];
        for j := i + 1 to TopWordsArray do // G
        begin
          if CurrentWord = WordsArray[j] then
            WordsArray[j] := #0;
        end;
      end;

      { алфавитная последовательность для 1 пункта }
      S1 := #0;
      for i := 1 to TopWordsArray do // H
      begin
        if WordsArray[i] <> #0 then
        begin

          Temp := WordsArray[i];
          WordLen := Length(Temp);
          LowerCase := AnsiLowerCase(Temp);

          if (WordLen > 0) and ((Temp[1] = 'a') or (Temp[1] = 'A')) then
          begin

            j := 1;
            IsCorrect := true;
            While j < WordLen do // I
            begin
              if (((Ord(LowerCase[j + 1]) - Ord(LowerCase[j]) = 1) or
                (not(Ord(LowerCase[j]) in [97 .. 122]))) and
                (AnsiLowerCase(Temp[1]) = 'a')) then
              begin
                IsCorrect := true;
              end
              else
              begin
                IsCorrect := false;
              end;

              inc(j);
            end;

            if IsCorrect then
            begin
              S1 := S1 + Temp + #32;
            end;

          end;
        end;
      end;

      { редактирование слов для второго пункта и сборка S2 }
      S2 := #0;
      for i := 1 to TopWordsArray do // J
      begin
        if WordsArray[i] <> #0 then
        begin
          Temp := WordsArray[i];
          WordLen := Length(Temp);
          letter := Temp[WordLen];
          delete(Temp, WordLen, WordLen);
          insert(letter, Temp, 1);

          S2 := S2 + Temp + #32;
        end;

      end;

      writeln;
      writeln('Default String: ', DefaultString);
      writeln('String S: ', S);

      if S1 <> '' then
        writeln('String S1: ', S1)
      else
        writeln('S1 is empty');

      if S2 <> '' then
        writeln('String S2: ', S2)
      else
        writeln('S2 is empty');

    end;

  end
  else
  begin
    writeln;
    writeln('Default String: ', DefaultString);
    writeln('The string S does not contain words');
    writeln('S1 is empty');
    writeln('S2 is empty');
  end;

  readln;

End.
