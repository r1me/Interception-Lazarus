program identify;

uses
  uInterception, uInterceptionUtils;

const
  SCANCODE_ESC = $01;
var
  context: InterceptionContext;
  device: InterceptionDevice;
  stroke: InterceptionStroke;
  keystroke: PInterceptionKeyStroke;
begin
  raise_process_priority;

  context := interception_create_context;
  interception_set_filter(context, @interception_is_keyboard, INTERCEPTION_FILTER_KEY_DOWN or INTERCEPTION_FILTER_KEY_UP);
  interception_set_filter(context, @interception_is_mouse, INTERCEPTION_FILTER_MOUSE_LEFT_BUTTON_DOWN);
  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @stroke, 1) = 0 then
      Break;

    if interception_is_keyboard(device) then
    begin
      keystroke := PInterceptionKeyStroke(@stroke);
      WriteLn('INTERCEPTION_KEYBOARD(', device - INTERCEPTION_KEYBOARD(0), ')');
      if (keystroke^.code = SCANCODE_ESC) then
        Break;
    end else
	begin
      if interception_is_mouse(device) then
        WriteLn('INTERCEPTION_MOUSE(', device - INTERCEPTION_MOUSE(0), ')')
	  else
	    WriteLn('UNRECOGNIZED(', device, ')');
	end;

    interception_send(context, device, @stroke, 1);
  end;
  interception_destroy_context(context);
end.

