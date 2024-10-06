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
unit Types;

interface

uses
  Objects;

type
  PMyStringCollection = ^TMyStringCollection;
  TMyStringCollection = object(TStringCollection)
    procedure Insert(Item: Pointer); virtual;
  end;

  PTemplateRec = ^TTemplateRec;
  TTemplateRec = record
    Template, FileName: String;
  end;

  PTemplateCollection = ^TTemplateCollection;
  TTemplateCollection = object(TCollection)
    procedure InsertTemplate(const Template, FileName: String); virtual;
    procedure FreeItem(Item: Pointer); virtual;
  end;

implementation

procedure TMyStringCollection.Insert(Item: Pointer);
var
  I: Integer;
begin
  if not Search(KeyOf(Item), I) or Duplicates then
    AtInsert(I, Item)
  else
    FreeItem(Item);
end;

procedure TTemplateCollection.InsertTemplate(const Template, FileName: String);
var
  P: PTemplateRec;

begin
  if Length(Template) = 0 then
    Exit;

  New(P);
  P^.Template := Template;
  P^.FileName := FileName;

  Insert(P);
end;

procedure TTemplateCollection.FreeItem(Item: Pointer);
begin
  if Item <> nil then
    Dispose(PTemplateRec(Item));
end;

end.
