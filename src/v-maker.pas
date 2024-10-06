{$IFDEF VER70}
{$DEFINE BPC}
{$ENDIF}

{$IFDEF VirtualPascal}
{&Delphi+,Use32+}
{$ENDIF}

{$IFDEF FPC}
{$SMARTLINK ON}
{$MODE objfpc}
{$ENDIF}

{$I-}
program v_maker_remake;

uses
  Dos,
  Template;

const
  DatesFileName   = 'dates.ctl';
  PeriodsFileName = 'periods.ctl';

  ErrCode : Byte = 0;

  eDateError        = $02; {00000010}
  ePeriodError      = $04; {00000100}
  eDatesOpenError   = $08; {00001000}
  ePeriodsOpenError = $10; {00010000}

var
  F: Text;
  S: String;
  I, CYear, CMonth, CDay, CHour: Word;

begin
  WriteLn('V-Maker v0.34 (C) 2024 Alexey Fayans, 2:5030/1997@fidonet');
  WriteLn;

  if ParamCount <> 0 then
  begin
    WriteLn('No command line parameters needed. See configuration.');
    Halt(1);
  end;

  GetDate(CYear, CMonth, CDay, I);
  GetTime(CHour, I, I, I);

  InitTemplates;

  Assign(F, DatesFileName);
  Reset(F);
  if IOResult = 0 then
  begin
    I := 0;
    while not Eof(F) do
    begin
      ReadLn(F, S);
      Inc(I);

      if (S[1] = ';') or (Length(S) = 0) then
        Continue;

      if not ProcessDate(S, CYear, CMonth, CDay, CHour) then
      begin
        WriteLn('Wrong format or date at line ', I, ' in ', DatesFileName, '.');
        ErrCode := ErrCode or eDateError;
      end;
    end;

    Close(F);
  end else
  begin
    WriteLn('Can''t open ', DatesFileName, '.');
    Inc(ErrCode, eDatesOpenError);
  end;

  Assign(F, PeriodsFileName);
  Reset(F);
  if IOResult = 0 then
  begin
    I := 0;
    while not Eof(F) do
    begin
      ReadLn(F, S);
      Inc(I);

      if (S[1] = ';') or (Length(S) = 0) then
        Continue;

      if not ProcessPeriod(S, CYear, CMonth, CDay, CHour) then
      begin
        WriteLn('Wrong format or period at line ', I, ' in ', PeriodsFileName, '.');
        ErrCode := ErrCode or ePeriodError;
      end;
    end;

    Close(F);
  end else
  begin
    WriteLn('Can''t open ', PeriodsFileName, '.');
    Inc(ErrCode, ePeriodsOpenError);
  end;

  SaveTemplates;
  DoneTemplates;

  if ErrCode <> 0 then
    Halt(ErrCode);
end.
