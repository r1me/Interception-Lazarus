program mathpointer;

uses
  uInterception, uInterceptionUtils, Math, Types;

type
  point = object
    x: double;
    y: double;
    class function Create(const Ax, Ay: Double): point; static;
  end;

{ point }

class function point.Create(const Ax, Ay: Double): point;
begin
  Result.x := Ax;
  Result.y := Ay;
end;

type
  curve = function(t: double): point;

const
  SCANCODE_ESC   = $01;
  SCANCODE_NUM_0 = $0B;
  SCANCODE_NUM_1 = $02;
  SCANCODE_NUM_2 = $03;
  SCANCODE_NUM_3 = $04;
  SCANCODE_NUM_4 = $05;
  SCANCODE_NUM_5 = $06;
  SCANCODE_NUM_6 = $07;
  SCANCODE_NUM_7 = $08;
  SCANCODE_NUM_8 = $09;
  SCANCODE_NUM_9 = $0A;

const
  scale: Double = 15.0;

var
  screen_width: Integer;
  screen_height: Integer;
  milliseconds: Cardinal;

function circle(t: double): point;
const
  f: double = 10.0;
begin
  Result := point.Create(scale * f * cos(t), scale * f * sin(t));
end;

function mirabilis(t: double): point;
const
  f: double = 1.0 / 2.0;
  k: double = 1.0 / (2.0 * pi);
begin
  Result := point.Create(scale * f * (exp(k * t) * cos(t)),
                         scale * f * (exp(k * t) * sin(t)));
end;

function epitrochoid(t: double): point;
const
  f: double = 1;
  R: double = 6;
  rr: double = 2;
  d: double = 1;
var
  c: double;
begin
  c := R + rr;
  Result := point.Create(scale * f * (c * cos(t) - d * cos((c * t) / rr)),
                         scale * f * (c * sin(t) - d * sin((c * t) / rr)));
end;

function hypotrochoid(t: double): point;
const
  f: double = 10.0 / 7.0;
  R: double = 5;
  rr: double = 3;
  d: double = 5;
var
  c: double;
begin
  c := R - rr;
  Result := point.Create(scale * f * (c * cos(t) + d * cos((c * t) / rr)),
                         scale * f * (c * sin(t) - d * sin((c * t) / rr)));
end;

function hypocycloid(t: double): point;
const
  f: double = 10.0 / 3.0;
  R: double = 3;
  rr: double = 1;
var
  c: double;
begin
  c := R - rr;
  Result := point.Create(scale * f * (c * cos(t) + rr * cos((c * t) / rr)),
                         scale * f * (c * sin(t) - rr * sin((c * t) / rr)));
end;

function bean(t: double): point;
const
  f: double = 10;
var
  c, s: double;
begin
  c := cos(t);
  s := sin(t);
  Result := point.Create(scale * f * ((power(c, 3) + power(s, 3)) * c),
                         scale * f * ((power(c, 3) + power(s, 3)) * s));
end;

function Lissajous(t: double): point;
const
  f: double = 10;
  a: double = 2;
  b: double = 3;
begin
  Result := point.Create(scale * f * (sin(a * t)), scale * f * (sin(b * t)));
end;

function epicycloid(t: double): point;
const
  f: double = 10.0 / 42.0;
  R: double = 21;
  rr: double = 10;
var
  c: double;
begin
  c := R + rr;
  Result := point.Create(scale * f * (c * cos(t) - rr * cos((c * t) / rr)),
                         scale * f * (c * sin(t) - rr * sin((c * t) / rr)));
end;

function rose(t: double): point;
const
  f: double = 10.0;
  R: double = 1;
  k: double = 2.0 / 7.0;
begin
  Result := point.Create(scale * f * (R * cos(k * t) * cos(t)),
                         scale * f * (R * cos(k * t) * sin(t)));
end;

function butterfly(t: double): point;
const
  f: double = 10.0 / 4.0;
var
  c: double;
begin
  c := exp(cos(t)) - 2 * cos(4 * t) + power(sin(t / 12), 5);
  Result := point.Create(scale * f * (sin(t) * c), scale * f * (cos(t) * c));
end;

procedure math_track(context: InterceptionContext; mouse: InterceptionDevice;
  fcurve: curve; center: point; t1, t2: double; partitioning: Cardinal);
var
  mstroke: InterceptionMouseStroke;
  delta: double;
  position: point;
  i, j: Cardinal;
begin
  lower_process_priority();

  delta := t2 - t1;
  position := fcurve(t1);

  mstroke.flags := INTERCEPTION_MOUSE_MOVE_ABSOLUTE;

  mstroke.state := INTERCEPTION_MOUSE_LEFT_BUTTON_UP;
  mstroke.x := Round(($FFFF * center.x) / screen_width);
  mstroke.y := Round(($FFFF * center.y) / screen_height);
  interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

  mstroke.state := 0;
  mstroke.x := Round(($FFFF * (center.x + position.x)) / screen_width);
  mstroke.y := Round(($FFFF * (center.y - position.y)) / screen_height);
  interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

  i := 0;
  j := 0;
  while i <= partitioning + 2 do
  begin
    if (j mod 250 = 0) then
    begin
      busy_wait(25 * milliseconds);
      mstroke.state := INTERCEPTION_MOUSE_LEFT_BUTTON_UP;
      interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

      busy_wait(25 * milliseconds);
      mstroke.state := INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN;
      interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);
      mstroke.state := 0;

      if (i > 0) then
        i := Cardinal(i - 2);
    end;

    position := fcurve(t1 + (i * delta) / partitioning);
    mstroke.x := Round(($FFFF * (center.x + position.x)) / screen_width);
    mstroke.y := Round(($FFFF * (center.y - position.y)) / screen_height);
    interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

    busy_wait(3 * milliseconds);

    Inc(i);
    Inc(j);
  end;

  busy_wait(25 * milliseconds);
  mstroke.state := INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN;
  interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

  busy_wait(25 * milliseconds);
  mstroke.state := INTERCEPTION_MOUSE_LEFT_BUTTON_UP;
  interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

  busy_wait(25 * milliseconds);
  mstroke.state := 0;
  mstroke.x := Round(($FFFF * center.x) / screen_width);
  mstroke.y := Round(($FFFF * center.y) / screen_height);
  interception_send(context, mouse, PInterceptionStroke(@mstroke), 1);

  raise_process_priority();
end;

var
  context: InterceptionContext;
  device, mouse: InterceptionDevice;
  stroke: InterceptionStroke;
  mstroke: PInterceptionMouseStroke;
  kstroke: PInterceptionKeyStroke;
  position: point;
begin
  screen_width := get_screen_width;
  screen_height := get_screen_height;

  milliseconds := calculate_busy_wait_millisecond;

  device := 0;
  mouse := 0;

  position.x := screen_width / 2;
  position.y := screen_height / 2;

  raise_process_priority;
  
  context := interception_create_context;
  interception_set_filter(context, @interception_is_keyboard,
                          INTERCEPTION_FILTER_KEY_DOWN or INTERCEPTION_FILTER_KEY_UP);
  interception_set_filter(context, @interception_is_mouse,
                          INTERCEPTION_FILTER_MOUSE_MOVE);

  WriteLn('NOTICE: This example works on real machines.');
  WriteLn('        Virtual machines generally work with absolute mouse');
  WriteLn('        positioning over the screen, which this samples isn''t');
  WriteLn('        prepared to handle.');
  WriteLn('');

  WriteLn('Now please, first move the mouse that''s going to be impersonated.');

  while True do
  begin
    device := interception_wait(context);
    if interception_receive(context, device, @stroke, 1) = 0 then 
      Break;

    if interception_is_mouse(device) then
    begin
      if mouse = 0 then
      begin
        mouse := device;
        WriteLn('Impersonating mouse ', device - INTERCEPTION_MOUSE(0), '.');
        WriteLn('');

        WriteLn('Now:');
        WriteLn('  - Go to Paint (or whatever place you want to draw)');
        WriteLn('  - Select your pencil');
        WriteLn('  - Position your mouse in the drawing board');
        WriteLn('  - Press any digit (not numpad) on your keyboard to draw an equation');
        WriteLn('  - Press ESC to exit.');
      end;

      mstroke := PInterceptionMouseStroke(@stroke);

      position.x := position.x + mstroke^.x;
      position.y := position.y + mstroke^.y;

      if (position.x < 0) then
          position.x := 0;
      if (position.x > screen_width - 1) then
          position.x := screen_width - 1;
      if (position.y < 0) then
          position.y := 0;
      if (position.y > screen_height - 1) then
          position.y := screen_height - 1;

      mstroke^.flags := INTERCEPTION_MOUSE_MOVE_ABSOLUTE;
      mstroke^.x := Round(($FFFF * position.x) / screen_width);
      mstroke^.y := Round(($FFFF * position.y) / screen_height);

      interception_send(context, device, @stroke, 1);
    end;

    if (mouse <> 0) and interception_is_keyboard(device) then
    begin
      kstroke := PInterceptionKeyStroke(@stroke);
      case kstroke^.state of
        INTERCEPTION_KEY_DOWN :
        begin
          case kstroke^.code of
            SCANCODE_NUM_0 :
              math_track(context, mouse, @circle, position, 0, 2 * pi, 200);
            SCANCODE_NUM_1 :
              math_track(context, mouse, @mirabilis, position, -(6 * pi), 6 * pi, 200);
            SCANCODE_NUM_2 :
              math_track(context, mouse, @epitrochoid, position, 0, 2 * pi, 200);
            SCANCODE_NUM_3 :
              math_track(context, mouse, @hypotrochoid, position, 0, 6 * pi, 200);
            SCANCODE_NUM_4 :
              math_track(context, mouse, @hypocycloid, position, 0, 2 * pi, 200);
            SCANCODE_NUM_5 :
              math_track(context, mouse, @bean, position, 0, pi, 200);
            SCANCODE_NUM_6 :
              math_track(context, mouse, @Lissajous, position, 0, 2 * pi, 200);
            SCANCODE_NUM_7 :
              math_track(context, mouse, @epicycloid, position, 0, 20 * pi, 1000);
            SCANCODE_NUM_8 :
              math_track(context, mouse, @rose, position, 0, 14 * pi, 500);
            SCANCODE_NUM_9 :
              math_track(context, mouse, @butterfly, position, 0, 21 * pi, 2000);
            else
              interception_send(context, device, @stroke, 1);
          end;
        end;
        INTERCEPTION_KEY_UP :
        begin
          case kstroke^.code of
            SCANCODE_NUM_0,
            SCANCODE_NUM_1,
            SCANCODE_NUM_2,
            SCANCODE_NUM_3,
            SCANCODE_NUM_4,
            SCANCODE_NUM_5,
            SCANCODE_NUM_6,
            SCANCODE_NUM_7,
            SCANCODE_NUM_8,
            SCANCODE_NUM_9 : ;
            else
              interception_send(context, device, @stroke, 1);
          end;
        end;
        else
          interception_send(context, device, @stroke, 1);
      end;

      if (kstroke^.code = SCANCODE_ESC) then
        Break;
    end;
  end;

  interception_destroy_context(context);
end.

