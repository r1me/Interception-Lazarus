program cadstop;

uses
  Classes, SysUtils, uInterception, uInterceptionUtils;

const
  SCANCODE_ESC  = $01;
  SCANCODE_CTRL = $1D;
  SCANCODE_ALT  = $38;
  SCANCODE_DEL  = $53;

var
  ctrl_down: InterceptionKeyStroke = (code: SCANCODE_CTRL;
    state: INTERCEPTION_KEY_DOWN; information: 0);
  alt_down: InterceptionKeyStroke = (code: SCANCODE_ALT;
    state: INTERCEPTION_KEY_DOWN; information: 0);
  del_down: InterceptionKeyStroke = (code: SCANCODE_DEL;
    state: INTERCEPTION_KEY_DOWN or INTERCEPTION_KEY_E0; information: 0);
  ctrl_up: InterceptionKeyStroke = (code: SCANCODE_CTRL;
    state: INTERCEPTION_KEY_UP; information: 0);
  alt_up: InterceptionKeyStroke = (code: SCANCODE_ALT;
    state: INTERCEPTION_KEY_UP; information: 0);
  del_up: InterceptionKeyStroke = (code: SCANCODE_DEL;
    state: INTERCEPTION_KEY_UP or INTERCEPTION_KEY_E0; information: 0);


function KeyStrokesEqual(const first: InterceptionKeyStroke;
  const second: InterceptionKeyStroke): Boolean;
begin
  Result := (first.code = second.code) and (first.state = second.state);
end;

function shall_produce_keystroke(const kstroke: InterceptionKeyStroke): Boolean;
const
  ctrl_is_down: Integer = 0;
  alt_is_down: Integer = 0;
  del_is_down: Integer = 0;
begin
  Result := False;
  if (ctrl_is_down + alt_is_down + del_is_down < 2) then
  begin
    if KeyStrokesEqual(kstroke, ctrl_down) then ctrl_is_down := 1;
    if KeyStrokesEqual(kstroke, ctrl_up) then ctrl_is_down := 0;
    if KeyStrokesEqual(kstroke, alt_down) then alt_is_down := 1;
    if KeyStrokesEqual(kstroke, alt_up) then alt_is_down := 0;
    if KeyStrokesEqual(kstroke, del_down) then del_is_down := 1;
    if KeyStrokesEqual(kstroke, del_up) then del_is_down := 0;
    Result := True;
    Exit;
  end;
  if (ctrl_is_down = 0) and (KeyStrokesEqual(kstroke, ctrl_down) or KeyStrokesEqual(kstroke, ctrl_up)) then
    Exit;

  if (alt_is_down = 0) and (KeyStrokesEqual(kstroke, alt_down) or KeyStrokesEqual(kstroke, alt_up)) then
    Exit;

  if (del_is_down = 0) and (KeyStrokesEqual(kstroke, del_down) or KeyStrokesEqual(kstroke, del_up)) then
    Exit;

  if KeyStrokesEqual(kstroke, ctrl_up) then
    ctrl_is_down := 0
  else
    if KeyStrokesEqual(kstroke, alt_up) then
      alt_is_down := 0
    else
      if KeyStrokesEqual(kstroke, del_up) then
        del_is_down := 0;

  Result := True;
end;

var
  context: InterceptionContext;
  device: InterceptionDevice;
  kstroke: InterceptionKeyStroke;
begin
  raise_process_priority;

  context := interception_create_context;
  interception_set_filter(context, @interception_is_keyboard,
                          INTERCEPTION_FILTER_KEY_ALL);

  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @kstroke, 1) = 0 then
      Break;

    if not shall_produce_keystroke(kstroke) then
    begin
      WriteLn('ctrl-alt-del pressed');
      Continue;
    end;

    interception_send(context, device, PInterceptionStroke(@kstroke), 1);

    if (kstroke.code = SCANCODE_ESC) then Break;
  end;
  interception_destroy_context(context);
end.

