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
unit Misc;

interface

{$IFDEF BPC}
procedure SetLength(var S: String; const NewLength: Byte);
{$ENDIF}
procedure StUpcaseEx(var Dest: String; const Source: String);
procedure TrimEx(var Dest: String; const Source: String);
function Trim(const S: String): String;
procedure StReplaceEx(var S: String; A: String; const B: String);

implementation

{$IFDEF BPC}
procedure SetLength(var S: String; const NewLength: Byte);
begin
  Byte(S[0]) := NewLength;
end;
{$ENDIF}

procedure StUpcaseEx(var Dest: String; const Source: String);
var
  K, L: Longint;

begin
  L := Length(Source);
  for K := 1 to L do
    Dest[K] := Upcase(Source[K]);
  SetLength(Dest, L);
end;

procedure TrimEx(var Dest: String; const Source: String);
var
  K, L: Longint;

begin
  K := 1;
  L := Length(Source);

  while (K <= L) and (Source[K] = ' ') do
    Inc(K);

  while (L <> 0) and (Source[L] = ' ') do
    Dec(L);

  Dec(L, K);
  Inc(L);

  Dest := Copy(Source, K, L);
end;

function Trim(const S: String): String;
{$IFDEF BPC}
var
  Result: String;
{$ENDIF}
begin
  TrimEx(Result, S);
  {$IFDEF BPC}
  Trim := Result;
  {$ENDIF}
end;

procedure StReplaceEx(var S: String; A: String; const B: String);
var
  K, LA, LB, I : Longint;
  S1           : String;

begin
  StUpcaseEx(S1, S);
  StUpcaseEx(A, A);

  K := Pos(A, S1);

  if K = 0 then
    Exit;

  LA := Length(A);
  LB := Length(B);

  I := K;
  Inc(I, LA);
  Dec(I);

  repeat
    Delete(S, K, LA);
    Insert(B, S, K);

    Delete(S1, 1, I);
    I := Pos(A, S1);

    if I <> 0 then
    begin
      Inc(K, LB);
      Inc(K, I);
      Dec(K);

      Inc(I, LA);
      Dec(I);
    end;
  until I = 0;
end;

end.
