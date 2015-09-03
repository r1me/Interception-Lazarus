program caps2esc;

{/* Windows version of caps2esc: https://github.com/alexandre/caps2esc.
 *
 * As it doesn't create any windows, you should check it's
 * executing from task manager, and if so, terminate it from there.
 *
 * This sample may not behave well from inside a VM since VM software sometimes
 * mess with generated keystrokes, specially the CTRL key.
 */}

uses
  Classes, SysUtils, uInterception, uInterceptionUtils;

type
  TInterceptionKeyStrokes = class
  public
    Items: array of InterceptionKeyStroke;
    procedure pop_front;
    procedure push_back(Item: InterceptionKeyStroke);
  end;

{ TInterceptionKeyStrokes }

procedure TInterceptionKeyStrokes.pop_front;
var
  i: Integer;
  len: Integer;
begin
  len := Length(Items);
  for i := 1 to len - 1 do
    Items[i - 1] := Items[i];
  SetLength(Items, len - 1);
end;

procedure TInterceptionKeyStrokes.push_back(Item: InterceptionKeyStroke);
begin
  SetLength(Items, Length(Items) + 1);
  Items[High(Items)] := Item;
end;

const
  SCANCODE_ESC       = $01;
  SCANCODE_CTRL      = $1D;
  SCANCODE_CAPSLOCK  = $3A;

var
  esc_down: InterceptionKeyStroke = (code: SCANCODE_ESC; state: INTERCEPTION_KEY_DOWN; information: 0);
  ctrl_down: InterceptionKeyStroke = (code: SCANCODE_CTRL; state: INTERCEPTION_KEY_DOWN; information: 0);
  capslock_down: InterceptionKeyStroke = (code: SCANCODE_CAPSLOCK; state: INTERCEPTION_KEY_DOWN; information: 0);
  esc_up: InterceptionKeyStroke = (code: SCANCODE_ESC; state: INTERCEPTION_KEY_UP; information: 0);
  ctrl_up: InterceptionKeyStroke = (code: SCANCODE_CTRL; state: INTERCEPTION_KEY_UP; information: 0);
  capslock_up: InterceptionKeyStroke = (code: SCANCODE_CAPSLOCK; state: INTERCEPTION_KEY_UP; information: 0);

function KeyStrokesEqual(const first: InterceptionKeyStroke;
  const second: InterceptionKeyStroke): Boolean;
begin
  Result := (first.code = second.code) and (first.state = second.state);
end;

function caps2esc(const kstroke: InterceptionKeyStroke): TInterceptionKeyStrokes;
const
  capslock_is_down: Boolean = False;
  esc_give_up: Boolean = False;
begin
  Result := TInterceptionKeyStrokes.Create;

  if (capslock_is_down) then
  begin
    if KeyStrokesEqual(kstroke, capslock_down) or
       (kstroke.code = SCANCODE_CTRL) then
      Exit;

    if KeyStrokesEqual(kstroke, capslock_up) then
    begin
      if (esc_give_up) then
      begin
        esc_give_up := False;
        Result.push_back(ctrl_up);
      end else
      begin
        Result.push_back(esc_down);
        Result.push_back(esc_up);
      end;
      capslock_is_down := False;
      Exit;
    end;
    if (not esc_give_up) then
    begin
      esc_give_up := True;
      Result.push_back(ctrl_down);
    end;

    if KeyStrokesEqual(kstroke, esc_down) then
      Result.push_back(capslock_down)
    else
      if KeyStrokesEqual(kstroke, esc_up) then
        Result.push_back(capslock_up)
      else
        Result.push_back(kstroke);

    Exit;
  end;

  if KeyStrokesEqual(kstroke, capslock_down) then
  begin
    capslock_is_down := True;
    Exit;
  end;

  if KeyStrokesEqual(kstroke, esc_down) then
    Result.push_back(capslock_down)
  else
    if KeyStrokesEqual(kstroke, esc_up) then
      Result.push_back(capslock_up)
    else
      Result.push_back(kstroke);
end;

var
  context: InterceptionContext;
  device: InterceptionDevice;
  kstroke: InterceptionKeyStroke;
  kstrokes: TInterceptionKeyStrokes;
begin
  raise_process_priority;

  context := interception_create_context;

  interception_set_filter(context, @interception_is_keyboard,
                          INTERCEPTION_FILTER_KEY_DOWN or
                          INTERCEPTION_FILTER_KEY_UP);

  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @kstroke, 1) = 0 then
      Break;

    kstrokes := caps2esc(kstroke);
    try
      if Length(kstrokes.Items) > 0 then
        interception_send(context, device,
                          PInterceptionStroke(@kstrokes.Items[0]),
                          Length(kstrokes.Items));
    finally
      kstrokes.Free;
    end;
  end;

  interception_destroy_context(context);
end.

