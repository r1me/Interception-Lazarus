program hardwareid;

uses
  uInterception, uInterceptionUtils;

const
  SCANCODE_ESC = $01;
var
  context: InterceptionContext;
  device: InterceptionDevice;
  stroke: InterceptionStroke;
  keystroke: PInterceptionKeyStroke;
  hardware_id: array[1..500] of WideChar;
  len: Integer;
begin
  raise_process_priority;

  context := interception_create_context;
  interception_set_filter(context, @interception_is_keyboard, INTERCEPTION_FILTER_KEY_DOWN or INTERCEPTION_FILTER_KEY_UP);
  interception_set_filter(context, @interception_is_mouse, INTERCEPTION_FILTER_MOUSE_LEFT_BUTTON_DOWN);
  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @stroke, 1) = 0 then Break;

    if interception_is_keyboard(device) then
    begin
      keystroke := PInterceptionKeyStroke(@stroke);
      if (keystroke^.code = SCANCODE_ESC) then Break;
    end;

    len := interception_get_hardware_id(context, device, @hardware_id[1], Length(hardware_id));
    if (len > 0) and (len < Length(hardware_id)) then
      WriteLn(String(PWideChar(@hardware_id[1])));

    interception_send(context, device, @stroke, 1);
  end;
  interception_destroy_context(context);
end.

