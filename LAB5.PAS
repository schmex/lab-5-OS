program lab5;

{$M $1000, 0, 0}
{$R+ $S+}

uses
  Crt, Dos;

const
  Color = Yellow;
  Symbol = '*';
  esc_enter: boolean = False; { = True, если нажата ESC или ENTER }

var
  Scr: Array[1..25, 1..80] of Record
    Symbol: Char;
    Attr: Byte
  end Absolute $B800:$0000;
  OldHandler, OldHandler2: Procedure;
  Speed, t: Word;
  dx, dy: Shortint;
  X, Y: Integer;
  t1, t2: Record
    Symbol: Char;
    Attr: Byte;
  end;

{$F+}
procedure Handler; Interrupt;
begin
  Inc(t);
  if t > 20 div Speed then begin
    t := 0;
    if esc_enter then
      esc_enter := False
    else begin
      Scr[Y, X].Symbol := t1.Symbol;
      Scr[Y, X].Attr := t1.Attr;
      Scr[Y, X + 1].Symbol := t2.Symbol;
      Scr[Y, X + 1].Attr := t2.Attr;
    end;
    while (X + dx > 79) or (X + dx < 1) or (Y + dy > 25) or (Y + dy < 1) do begin
      case Random(4) of
        0: dx := -1;
        1: dx := 1;
        2: dx := 2;
        3: dx := -2;
      end;
      case Random(4) of
        0: dy := -1;
        1: dy := 1;
        2: dy := 2;
        3: dy := -2;
      end;
    end;
    X := X + dx;
    Y := Y + dy;
    t1.Symbol := Scr[Y, X].Symbol;
    t1.Attr := Scr[Y, X].Attr;
    t2.Symbol := Scr[Y, X + 1].Symbol;
    t2.Attr := Scr[Y, X + 1].Attr;
    Scr[Y, X].Symbol := Symbol;
    Scr[Y, X].Attr := Color;
    Scr[Y, X + 1].Symbol := Symbol;
    Scr[Y, X + 1].Attr := Color;
  end;
  Inline($9C);
  OldHandler;
end;
{$F-}

{$F+}
procedure Handler2; Interrupt;
var
  c: Byte;
begin
  c := Port[$60];
  if (c = 1) or (c = $1C) then begin
    Scr[Y, X].Symbol := t1.Symbol;
    Scr[Y, X].Attr := t1.Attr;
    Scr[Y, X + 1].Symbol := t2.Symbol;
    Scr[Y, X + 1].Attr := t2.Attr;
    esc_enter := True;
  end;
  Inline($9C);
  OldHandler2;
end;
{$F-}

var
  i, C1, C2: Integer;
begin
  Val(ParamStr(1), Speed, C1);
  if ParamCount = 0 then
    Speed := 7
  else if (C1 <> 0) or (Speed < 1) or (Speed > 20) then begin
    WriteLn('Неправильно заданы параметры.');
    WriteLn('Должен быть один параметр - скорость движения объекта (1..20)');
    ReadKey;
    Halt;
  end;
  t := 0;
  dx := 0;
  dy := 1;
  X := 30;
  Y := 15;
  t1.Symbol := Scr[Y, X].Symbol;
  t1.Attr := Scr[Y, X].Attr;
  t2.Symbol := Scr[Y, X + 1].Symbol;
  t2.Attr := Scr[Y, X + 1].Attr;
  Randomize;
  GetIntVec($9, @OldHandler2);
  SetIntVec($9, Addr(Handler2));
  GetIntVec($8, @OldHandler);
  SetIntVec($8, Addr(Handler));
  Keep(0);
end.
