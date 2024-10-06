{$IFDEF VER70}
{$DEFINE BPC}
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
unit Dates;

interface

const
  MonthDays: array[1..12] of Byte =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

function JulianDay(Year, Month, Day: Longint): Longint;
function IsLeapYear(Year: Longint): Boolean;
function ParseDate(const Source: String; var Year, Month, Day: Longint): Boolean;

implementation

uses
  Misc;

const
  D0 = 1461;
  D1 = 146097;
  D2 = 1721119;

function JulianDay(Year, Month, Day: Longint): Longint;
var
  Century, XYear: Longint;
begin
  if Month <= 2 then
  begin
    Dec(Year);
    Inc(Month, 12);
  end;

  Dec(Month, 3);
  Century := Year div 100;
  XYear := Year mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  JulianDay := ((((Month * 153) + 2) div 5) + Day) + D2 + XYear + Century;
end;

function IsLeapYear(Year: Longint): Boolean;
begin
  Result := ((Year mod 4 = 0) and (Year mod 100 <> 0)) or (Year mod 400 = 0);
end;

function ParseDate(const Source: String; var Year, Month,
  Day: Longint): Boolean;
var
  S    : String;
  I, N : Integer;

begin
  ParseDate := False;

  TrimEx(S, Source);

  I := Pos('/', S);
  if I = 0 then
    Exit;
  Val(Copy(S, 1, I-1), Day, N);
  if N <> 0 then
    Exit;
  Delete(S, 1, I);

  I := Pos('/', S);
  if I = 0 then
    Exit;
  Val(Copy(S, 1, I-1), Month, N);
  if N <> 0 then
    Exit;
  Delete(S, 1, I);

  Val(S, Year, N);
  if N <> 0 then
    Exit;

  ParseDate := True;
end;

end.
