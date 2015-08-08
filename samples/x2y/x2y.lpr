program x2y;

uses
  uInterception, uInterceptionUtils;

const
  SCANCODE_X   = $2D;
  SCANCODE_Y   = $15;
  SCANCODE_ESC = $01;
var
  context: InterceptionContext;
  device: InterceptionDevice;
  stroke: InterceptionKeyStroke;
begin
  raise_process_priority;
  
  context := interception_create_context;
  interception_set_filter(context, @interception_is_keyboard, INTERCEPTION_FILTER_KEY_DOWN or INTERCEPTION_FILTER_KEY_UP);
  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @stroke, 1) = 0 then 
      Break;
    if (stroke.code = SCANCODE_X) then 
      stroke.code := SCANCODE_Y;
    interception_send(context, device, PInterceptionStroke(@stroke), 1);
    if (stroke.code = SCANCODE_ESC) then 
      Break;
  end;
  interception_destroy_context(context);
end.

