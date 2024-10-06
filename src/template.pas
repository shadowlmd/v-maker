{$IFDEF VER70}
{$DEFINE BPC}
{$ENDIF}

{$IFDEF BPC}
{$F+}
{$ENDIF}

{$IFDEF VirtualPascal}
{&Delphi+,Use32+}
{$ENDIF}

{$IFDEF FPC}
{$IFNDEF NO_SMART_LINK}
{$SMARTLINK ON}
{$ENDIF}
{$MODE objfpc}
{$ENDIF}

{$I-}
unit Template;

interface

function ProcessDate(const Source: String; const CYear, CMonth, CDay,
  CHour: Longint): Boolean;
function ProcessPeriod(const Source: String; const CYear, CMonth, CDay,
  CHour: Longint): Boolean;
procedure InitTemplates;
procedure SaveTemplates;
procedure DoneTemplates;

implementation

uses
  Objects,
  Strings,
  Types,
  Dates,
  Misc;

var
  Templates: PTemplateCollection;
  FileNames: PMyStringCollection;

procedure InitTemplates;
begin
  New(Templates, Init(10, 10));
  New(FileNames, Init(10, 10));
  FileNames^.Duplicates := False;
end;

procedure SaveTemplates;

  procedure SaveTemplate(FN: Pointer);
  var
    F: Text;

    procedure SaveIfMatched(TplRec: Pointer);
    begin
      if PTemplateRec(TplRec)^.FileName = PString(FN)^ then
        WriteLn(F, PTemplateRec(TplRec)^.Template);
    end;

  begin
    Assign(F, PString(FN)^);
    Rewrite(F);

    if IOResult <> 0 then
    begin
      WriteLn('Error: Can''t write to ', PString(FN)^, '.');
      Exit;
    end;

    Templates^.ForEach(@SaveIfMatched);

    Close(F);
  end;

begin
  FileNames^.ForEach(@SaveTemplate);
end;

procedure DoneTemplates;
begin
  Dispose(Templates, Done);
  Dispose(FileNames, Done);
end;

function Tokenize(const S, Var1, Var2, Var3: String): String;
var
  I: Longint;

begin
  I := Length(S);
  if (I >= 2) and (S[I-1] = '1') then
    Tokenize := Var3
  else
    case S[I] of
      '1'      : Tokenize := Var1;
      '2'..'4' : Tokenize := Var2;
    else
      Tokenize := Var3;
    end;
end;

function ProcessDate(const Source: String; const CYear, CMonth, CDay,
  CHour: Longint): Boolean;
var
  S, Template, FileName: String;
  I, Year, Month, Day, DaysCount: Longint;

begin
  ProcessDate := False;

  TrimEx(FileName, Source);

  { template }
  Delete(FileName, 1, 1);
  I := Pos('"', FileName);
  if I = 0 then
    Exit;
  Template := Copy(FileName, 1, I-1);
  Delete(FileName, 1, I);

  { date }
  I := Pos(',', FileName);
  if I = 0 then
    Exit;
  Delete(FileName, 1, I);
  I := Pos(',', FileName);
  if I = 0 then
    Exit;
  if not ParseDate(Copy(FileName, 1, I-1), Year, Month, Day) then
    Exit;
  Delete(FileName, 1, I);

  { filename }
  TrimEx(FileName, FileName);

  DaysCount := JulianDay(CYear, CMonth, CDay) - JulianDay(Year,
    Month, Day);

  StUpcaseEx(S, Template);

  if (DaysCount > 0) and ((Pos('%DREMAIN', S) <> 0) or (Pos('%MREMAIN',
    S) <> 0) or (Pos('%HREMAIN', S) <> 0))
  then
    Exit;

  if (DaysCount < 0) and ((Pos('%DPAST', S) <> 0) or (Pos('%MPAST',
    S) <> 0) or (Pos('%HPAST', S) <> 0))
  then
    Exit;

  Str(DaysCount, S);
  StReplaceEx(Template, '%DPAST', S);

  Str(-DaysCount, S);
  StReplaceEx(Template, '%DREMAIN', S);

  StReplaceEx(Template, '%DTOKEN', Tokenize(S, 'день', 'дня', 'дней'));

  I := DaysCount * 24;
  Inc(I, CHour);
  Str(I, S);
  StReplaceEx(Template, '%HPAST', S);

  Str(-I, S);
  StReplaceEx(Template, '%HREMAIN', S);

  StReplaceEx(Template, '%HTOKEN', Tokenize(S, 'час', 'часа', 'часов'));

  I := DaysCount div 31;
  Str(I, S);
  StReplaceEx(Template, '%MPAST', S);

  Str(-I, S);
  StReplaceEx(Template, '%MREMAIN', S);

  StReplaceEx(Template, '%MTOKEN', Tokenize(S, 'месяц', 'месяца', 'месяцев'));

  StReplaceEx(Template, '%QUOTE', '"');

  Templates^.InsertTemplate(Template, FileName);
  FileNames^.Insert(NewStr(FileName));

  ProcessDate := True;
end;

function ProcessPeriod(const Source: String; const CYear, CMonth, CDay,
  CHour: Longint): Boolean;

  function DrawLine(cFill, cDraw: Char; L, I: Longint; Filled: Boolean): String;
  var
    P: PChar;
  begin
    GetMem(P, L+1);
    if I < 1 then
      I := 1;
    if I > L then
      I := L;
    FillChar(P^, L, cFill);
    if Filled then
      FillChar(P^, I, cDraw)
    else
      P[I-1] := cDraw;
    P[L] := #0;
    DrawLine := StrPas(P);
    FreeMem(P, L+1);
  end;

var
  S, S1, Template, FileName: String;
  Year1, Month1, Day1, I, SLen,
  Year2, Month2, Day2, PDays, CDays: Longint;
  N: Integer;
  cFill, cDraw: Char;
  Percents: Real;

begin
  ProcessPeriod := False;

  TrimEx(FileName, Source);

  { template }
  Delete(FileName, 1, 1);
  I := Pos('"', FileName);
  if I = 0 then
    Exit;
  Template := Copy(FileName, 1, I-1);
  Delete(FileName, 1, I);

  { chars }
  I := Pos('"', FileName);
  if I = 0 then
    Exit;
  Inc(I);
  cFill := FileName[I];
  Inc(I);
  cDraw := FileName[I];
  Inc(I);
  Delete(FileName, 1, I);

  { length }
  I := Pos(',', FileName);
  if I = 0 then
    Exit;
  Delete(FileName, 1, I);
  I := Pos(',', FileName);
  if I = 0 then
    Exit;
  Val(Trim(Copy(FileName, 1, I-1)), SLen, N);
  if N <> 0 then
    Exit;
  Delete(FileName, 1, I);

  { start date }
  I := Pos(',', FileName);
  if I = 0 then
    Exit;
  if not ParseDate(Copy(FileName, 1, I-1), Year1, Month1, Day1) then
    Exit;
  Delete(FileName, 1, I);

  { end date }
  I := Pos(',', FileName);
  if I = 0 then
    Exit;
  if not ParseDate(Copy(FileName, 1, I-1), Year2, Month2, Day2) then
    Exit;
  Delete(FileName, 1, I);

  { filename }
  TrimEx(FileName, FileName);

  { dates magic }
  if Year1 = 0 then
    Year1 := CYear;

  if Year2 = 0 then
  begin
    Year2 := CYear;

    if Year1 < 0 then
    begin
      if
        ((CMonth > Month1) and (Month1 >= 0))
        or
        ((CMonth = Month1) and (CDay > Day1) and (Day1 > 0))
      then
      begin
        Inc(Year1);
        Inc(Year2);
      end;
      Inc(Year1, CYear);
    end;
  end;

  if Month1 = 0 then
    Month1 := CMonth;

  if Month2 = 0 then
  begin
    Month2 := CMonth;

    if Month1 < 0 then
    begin
      if (CDay > Day1) and (Day1 > 0) then
      begin
        Inc(Month1);
        Inc(Month2);
        if Month2 > 12 then
        begin
          Month2 := 1;
          Inc(Year2);
        end;
      end;
      Inc(Month1, CMonth);
      while Month1 <= 0 do
      begin
        Inc(Month1, 12);
        Dec(Year1);
      end;
    end;
  end;

  if Day1 > 31 then
  begin
    Day1 := MonthDays[Month1];
    if (Month1 = 2) and IsLeapYear(Year1) then
      Inc(Day1);
  end else
  if Day1 = 0 then
    Day1 := CDay;

  if Day2 > 31 then
  begin
    Day2 := MonthDays[Month2];
    if (Month2 = 2) and IsLeapYear(Year2) then
      Inc(Day2);
  end else
  if Day2 = 0 then
  begin
    Day2 := CDay;

    if Day1 < 0 then
    begin
      Inc(Day1, MonthDays[Month1]);
      while Day1 <= 0 do
      begin
        Dec(Month1);
        if Month1 = 0 then
        begin
          Inc(Month1, 12);
          Dec(Year1);
        end;
        Inc(Day1, MonthDays[Month1]);
        if (Month1 = 2) and IsLeapYear(Year1) then
          Inc(Day1);
      end;
    end;
  end;

  { calculations }
  I := JulianDay(Year1, Month1, Day1);

  PDays := JulianDay(Year2, Month2, Day2) - I;
  Inc(PDays);

  CDays := JulianDay(CYear, CMonth, CDay) - I;
  Inc(CDays);

  if (PDays <= 0) or (CDays <= 0) or (CDays > PDays) then
  begin
    ProcessPeriod := True;
    Exit;
  end;

  Percents := CDays / PDays * 100;
  I := Round(SLen / 100 * Percents);

  Str(Percents:0:2, S);
  StReplaceEx(Template, '%PERCENTS', S);

  Dec(PDays, CDays);
  Dec(CDays);

  StUpcaseEx(S1, Template);

  if Pos('%PROGRESS1', S1) <> 0 then
    StReplaceEx(Template, '%PROGRESS1', DrawLine(cFill, cDraw, SLen, I, True));

  if Pos('%PROGRESS2', S1) <> 0 then
    StReplaceEx(Template, '%PROGRESS2', DrawLine(cFill, cDraw, SLen, I, False));

  if Pos('%HPAST', S1) <> 0 then
  begin
    I := CDays * 24;
    Inc(I, CHour);
    Str(I, S);
    StReplaceEx(Template, '%HPAST', S);
    StReplaceEx(Template, '%HPTOKEN', Tokenize(S, 'час', 'часа', 'часов'));
  end;

  if Pos('%HREMAIN', S1) <> 0 then
  begin
    if PDays <> 0 then
    begin
      I := PDays * 24;
      Dec(I, CHour);
    end else
      I := 0;
    Str(I, S);
    StReplaceEx(Template, '%HREMAIN', S);
    StReplaceEx(Template, '%HRTOKEN', Tokenize(S, 'час', 'часа', 'часов'));
  end;

  if Pos('%DPAST', S1) <> 0 then
  begin
    Str(CDays, S);
    StReplaceEx(Template, '%DPAST', S);
    StReplaceEx(Template, '%DPTOKEN', Tokenize(S, 'день', 'дня', 'дней'));
  end;

  if Pos('%DREMAIN', S1) <> 0 then
  begin
    Str(PDays, S);
    StReplaceEx(Template, '%DREMAIN', S);
    StReplaceEx(Template, '%DRTOKEN', Tokenize(S, 'день', 'дня', 'дней'));
  end;

  if Pos('%MPAST', S1) <> 0 then
  begin
    Str(CDays div 31, S);
    StReplaceEx(Template, '%MPAST', S);
    StReplaceEx(Template, '%MPTOKEN', Tokenize(S, 'месяц', 'месяца', 'месяцев'));
  end;

  if Pos('%MREMAIN', S1) <> 0 then
  begin
    Str(PDays div 31, S);
    StReplaceEx(Template, '%MREMAIN', S);
    StReplaceEx(Template, '%MRTOKEN', Tokenize(S, 'месяц', 'месяца', 'месяцев'));
  end;

  StReplaceEx(Template, '%QUOTE', '"');

  Templates^.InsertTemplate(Template, FileName);
  FileNames^.Insert(NewStr(FileName));

  ProcessPeriod := True;
end;

end.
