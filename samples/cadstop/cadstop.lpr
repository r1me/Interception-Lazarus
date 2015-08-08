program cadstop;

uses
  Classes, SysUtils, uInterception, uInterceptionUtils;

type
  TStrokeSequence = class
  private
    FItems: array of InterceptionKeyStroke;
    function Get(Index: Integer): InterceptionKeyStroke;
  public
    property Items[Index: Integer]: InterceptionKeyStroke read Get; default;
    procedure pop_front;
    procedure push_back(Item: InterceptionKeyStroke);
  end;

{ TStrokeSequence }

function TStrokeSequence.Get(Index: Integer): InterceptionKeyStroke;
begin
  Result := FItems[Index];
end;

procedure TStrokeSequence.pop_front;
var
  i: Integer;
  len: Integer;
begin
  len := Length(FItems);
  for i := 1 to len - 1 do
    FItems[i - 1] := FItems[i];
  SetLength(FItems, len - 1);
end;

procedure TStrokeSequence.push_back(Item: InterceptionKeyStroke);
begin
  SetLength(FItems, Length(FItems) + 1);
  FItems[High(FItems)] := Item;
end;

const
  SCANCODE_ESC = $01;

var
  nothing: InterceptionKeyStroke = (code: 0; state: 0; information: 0);
  ctrl_down: InterceptionKeyStroke = (code: 29; state: INTERCEPTION_KEY_DOWN; information: 0);
  alt_down: InterceptionKeyStroke = (code: 56; state: INTERCEPTION_KEY_DOWN; information: 0);
  del_down: InterceptionKeyStroke = (code: 83; state: INTERCEPTION_KEY_DOWN or INTERCEPTION_KEY_E0; information: 0);

function KeyStrokesEqual(const first: InterceptionKeyStroke; const second: InterceptionKeyStroke): Boolean;
begin
  Result := (first.code = second.code) and (first.state = second.state);
end;

function KeyStrokesNotEqual(const first: InterceptionKeyStroke; const second: InterceptionKeyStroke): Boolean;
begin
  Result := not ( (first.code = second.code) and
                  (first.state = second.state) );
end;

var
  context: InterceptionContext;
  device: InterceptionDevice;
  new_stroke, last_stroke: InterceptionKeyStroke;
  stroke_sequence: TStrokeSequence;

begin
  stroke_sequence := TStrokeSequence.Create;
  try
    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);

    raise_process_priority;

    context := interception_create_context;
    interception_set_filter(context, @interception_is_keyboard, INTERCEPTION_FILTER_KEY_ALL);
    last_stroke := nothing;
    while True do
    begin
      device := interception_wait(context);
      if interception_receive(context, device, @new_stroke, 1) = 0 then
        Break;

      if KeyStrokesNotEqual(new_stroke, last_stroke) then
      begin
        stroke_sequence.pop_front;
        stroke_sequence.push_back(new_stroke);
      end;

      if ( KeyStrokesEqual(stroke_sequence[0], ctrl_down) and
           KeyStrokesEqual(stroke_sequence[1], alt_down) and
           KeyStrokesEqual(stroke_sequence[2], del_down) ) then
        WriteLn('ctrl-alt-del pressed')
      else
        if ( KeyStrokesEqual(stroke_sequence[0], alt_down) and
             KeyStrokesEqual(stroke_sequence[1], ctrl_down) and
             KeyStrokesEqual(stroke_sequence[2], del_down) ) then
          WriteLn('alt-ctrl-del pressed')
        else
          interception_send(context, device, PInterceptionStroke(@new_stroke), 1);

      if (new_stroke.code = SCANCODE_ESC) then Break;
      last_stroke := new_stroke;
    end;
    interception_destroy_context(context);
  finally
    stroke_sequence.Free;
  end;
end.

