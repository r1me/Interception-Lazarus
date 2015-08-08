program axes;

uses
  uInterception, uInterceptionUtils;

const
  SCANCODE_ESC = $01;
var
  context: InterceptionContext;
  device: InterceptionDevice;
  stroke: InterceptionStroke;
  mstroke: PInterceptionMouseStroke;
  kstroke: PInterceptionKeyStroke;
begin
  raise_process_priority;

  context := interception_create_context;
  interception_set_filter(context, @interception_is_keyboard, INTERCEPTION_FILTER_KEY_DOWN or INTERCEPTION_FILTER_KEY_UP);
  interception_set_filter(context, @interception_is_mouse, INTERCEPTION_FILTER_MOUSE_MOVE);
  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @stroke, 1) = 0 then
      Break;

    if interception_is_mouse(device) then
    begin
      mstroke := PInterceptionMouseStroke(@stroke);
      if (mstroke^.flags and INTERCEPTION_MOUSE_MOVE_ABSOLUTE) = 0 then
        mstroke^.y := mstroke^.y * -1;
      interception_send(context, device, @stroke, 1);
    end;

    if interception_is_keyboard(device) then
    begin
      kstroke := PInterceptionKeyStroke(@stroke);
      interception_send(context, device, @stroke, 1);
      if (kstroke^.code = SCANCODE_ESC) then
        Break;
    end;
  end;
  interception_destroy_context(context);
end.

