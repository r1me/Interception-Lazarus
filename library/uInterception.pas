unit uInterception;

interface

const
  INTERCEPTION_MAX_KEYBOARD = 10;
  INTERCEPTION_MAX_MOUSE = 10;
  INTERCEPTION_MAX_DEVICE = ((INTERCEPTION_MAX_KEYBOARD) + (INTERCEPTION_MAX_MOUSE));
  
function INTERCEPTION_KEYBOARD(index: Integer): Integer;
function INTERCEPTION_MOUSE(index: Integer): Integer;

type
  InterceptionContext = Pointer;
  InterceptionDevice = Integer;
  InterceptionPrecedence = Integer;
  InterceptionFilter = Word;

type
  InterceptionPredicate = function(device: InterceptionDevice): LongBool; cdecl;

const
  { InterceptionKeyState }
  INTERCEPTION_KEY_DOWN             = $00;
  INTERCEPTION_KEY_UP               = $01;
  INTERCEPTION_KEY_E0               = $02;
  INTERCEPTION_KEY_E1               = $04;
  INTERCEPTION_KEY_TERMSRV_SET_LED  = $08;
  INTERCEPTION_KEY_TERMSRV_SHADOW   = $10;
  INTERCEPTION_KEY_TERMSRV_VKPACKET = $20;

const
  { InterceptionFilterKeyState }
  INTERCEPTION_FILTER_KEY_NONE             = $0000;
  INTERCEPTION_FILTER_KEY_ALL              = $FFFF;
  INTERCEPTION_FILTER_KEY_DOWN             = INTERCEPTION_KEY_UP;
  INTERCEPTION_FILTER_KEY_UP               = INTERCEPTION_KEY_UP shl 1;
  INTERCEPTION_FILTER_KEY_E0               = INTERCEPTION_KEY_E0 shl 1;
  INTERCEPTION_FILTER_KEY_E1               = INTERCEPTION_KEY_E1 shl 1;
  INTERCEPTION_FILTER_KEY_TERMSRV_SET_LED  = INTERCEPTION_KEY_TERMSRV_SET_LED shl 1;
  INTERCEPTION_FILTER_KEY_TERMSRV_SHADOW   = INTERCEPTION_KEY_TERMSRV_SHADOW shl 1;
  INTERCEPTION_FILTER_KEY_TERMSRV_VKPACKET = INTERCEPTION_KEY_TERMSRV_VKPACKET shl 1;

const
  { InterceptionMouseState }
  INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN   = $001;
  INTERCEPTION_MOUSE_LEFT_BUTTON_UP     = $002;
  INTERCEPTION_MOUSE_RIGHT_BUTTON_DOWN  = $004;
  INTERCEPTION_MOUSE_RIGHT_BUTTON_UP    = $008;
  INTERCEPTION_MOUSE_MIDDLE_BUTTON_DOWN = $010;
  INTERCEPTION_MOUSE_MIDDLE_BUTTON_UP   = $020;

  INTERCEPTION_MOUSE_BUTTON_1_DOWN      = INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN;
  INTERCEPTION_MOUSE_BUTTON_1_UP        = INTERCEPTION_MOUSE_LEFT_BUTTON_UP;
  INTERCEPTION_MOUSE_BUTTON_2_DOWN      = INTERCEPTION_MOUSE_RIGHT_BUTTON_DOWN;
  INTERCEPTION_MOUSE_BUTTON_2_UP        = INTERCEPTION_MOUSE_RIGHT_BUTTON_UP;
  INTERCEPTION_MOUSE_BUTTON_3_DOWN      = INTERCEPTION_MOUSE_MIDDLE_BUTTON_DOWN;
  INTERCEPTION_MOUSE_BUTTON_3_UP        = INTERCEPTION_MOUSE_MIDDLE_BUTTON_UP;

  INTERCEPTION_MOUSE_BUTTON_4_DOWN      = $040;
  INTERCEPTION_MOUSE_BUTTON_4_UP        = $080;
  INTERCEPTION_MOUSE_BUTTON_5_DOWN      = $100;
  INTERCEPTION_MOUSE_BUTTON_5_UP        = $200;

  INTERCEPTION_MOUSE_WHEEL              = $400;
  INTERCEPTION_MOUSE_HWHEEL             = $800;

const
  { InterceptionFilterMouseState }
  INTERCEPTION_FILTER_MOUSE_NONE               = $0000;
  INTERCEPTION_FILTER_MOUSE_ALL                = $FFFF;

  INTERCEPTION_FILTER_MOUSE_LEFT_BUTTON_DOWN   = INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN;
  INTERCEPTION_FILTER_MOUSE_LEFT_BUTTON_UP     = INTERCEPTION_MOUSE_LEFT_BUTTON_UP;
  INTERCEPTION_FILTER_MOUSE_RIGHT_BUTTON_DOWN  = INTERCEPTION_MOUSE_RIGHT_BUTTON_DOWN;
  INTERCEPTION_FILTER_MOUSE_RIGHT_BUTTON_UP    = INTERCEPTION_MOUSE_RIGHT_BUTTON_UP;
  INTERCEPTION_FILTER_MOUSE_MIDDLE_BUTTON_DOWN = INTERCEPTION_MOUSE_MIDDLE_BUTTON_DOWN;
  INTERCEPTION_FILTER_MOUSE_MIDDLE_BUTTON_UP   = INTERCEPTION_MOUSE_MIDDLE_BUTTON_UP;

  INTERCEPTION_FILTER_MOUSE_BUTTON_1_DOWN      = INTERCEPTION_MOUSE_BUTTON_1_DOWN;
  INTERCEPTION_FILTER_MOUSE_BUTTON_1_UP        = INTERCEPTION_MOUSE_BUTTON_1_UP;
  INTERCEPTION_FILTER_MOUSE_BUTTON_2_DOWN      = INTERCEPTION_MOUSE_BUTTON_2_DOWN;
  INTERCEPTION_FILTER_MOUSE_BUTTON_2_UP        = INTERCEPTION_MOUSE_BUTTON_2_UP;
  INTERCEPTION_FILTER_MOUSE_BUTTON_3_DOWN      = INTERCEPTION_MOUSE_BUTTON_3_DOWN;
  INTERCEPTION_FILTER_MOUSE_BUTTON_3_UP        = INTERCEPTION_MOUSE_BUTTON_3_UP;

  INTERCEPTION_FILTER_MOUSE_BUTTON_4_DOWN      = INTERCEPTION_MOUSE_BUTTON_4_DOWN;
  INTERCEPTION_FILTER_MOUSE_BUTTON_4_UP        = INTERCEPTION_MOUSE_BUTTON_4_UP;
  INTERCEPTION_FILTER_MOUSE_BUTTON_5_DOWN      = INTERCEPTION_MOUSE_BUTTON_5_DOWN;
  INTERCEPTION_FILTER_MOUSE_BUTTON_5_UP        = INTERCEPTION_MOUSE_BUTTON_5_UP;

  INTERCEPTION_FILTER_MOUSE_WHEEL              = INTERCEPTION_MOUSE_WHEEL;
  INTERCEPTION_FILTER_MOUSE_HWHEEL             = INTERCEPTION_MOUSE_HWHEEL;

  INTERCEPTION_FILTER_MOUSE_MOVE               = $1000;

const
  { InterceptionMouseFlag }
  INTERCEPTION_MOUSE_MOVE_RELATIVE      = $000;
  INTERCEPTION_MOUSE_MOVE_ABSOLUTE      = $001;
  INTERCEPTION_MOUSE_VIRTUAL_DESKTOP    = $002;
  INTERCEPTION_MOUSE_ATTRIBUTES_CHANGED = $004;
  INTERCEPTION_MOUSE_MOVE_NOCOALESCE    = $008;
  INTERCEPTION_MOUSE_TERMSRV_SRC_SHADOW = $100;

type
  TInterceptionMouseStroke = record
    state: Word;
    flags: Word;
    rolling: SmallInt;
    x: Integer;
    y: Integer;
    information: Cardinal;
  end;
  InterceptionMouseStroke = TInterceptionMouseStroke;
  PInterceptionMouseStroke = ^InterceptionMouseStroke;

type
  TInterceptionKeyStroke = record
    code: Word;
    state: Word;
    information: Cardinal;
  end;
  InterceptionKeyStroke = TInterceptionKeyStroke;
  PInterceptionKeyStroke = ^InterceptionKeyStroke;

  InterceptionStroke = InterceptionMouseStroke;
  PInterceptionStroke = ^InterceptionStroke;

function interception_create_context: InterceptionContext; cdecl; external 'interception.dll';
procedure interception_destroy_context(context: InterceptionContext); cdecl; external 'interception.dll';
function interception_get_precedence(context: InterceptionContext; device: InterceptionDevice): InterceptionPrecedence; cdecl; external 'interception.dll';
procedure interception_set_precedence(context: InterceptionContext; device: InterceptionDevice; precedence: InterceptionPrecedence); cdecl; external 'interception.dll';
function interception_get_filter(context: InterceptionContext; device: InterceptionDevice): InterceptionFilter; cdecl; external 'interception.dll';
procedure interception_set_filter(context: InterceptionContext; predicate: InterceptionPredicate; filter: InterceptionFilter); cdecl; external 'interception.dll';
function interception_wait(context: InterceptionContext): InterceptionDevice; cdecl; external 'interception.dll';
function interception_wait_with_timeout(context: InterceptionContext; milliseconds: NativeUInt): InterceptionDevice; cdecl; external 'interception.dll';
function interception_send(context: InterceptionContext; device: InterceptionDevice; const stroke: PInterceptionStroke; nstroke: Cardinal): Integer; cdecl; external 'interception.dll';
function interception_receive(context: InterceptionContext; device: InterceptionDevice; stroke: PInterceptionStroke; nstroke: Cardinal): Integer; cdecl; external 'interception.dll';
function interception_get_hardware_id(context: InterceptionContext; device: InterceptionDevice; hardware_id_buffer: Pointer; buffer_size: SizeInt): Cardinal; cdecl; external 'interception.dll';
function interception_is_invalid(device: InterceptionDevice): LongBool; cdecl; external 'interception.dll';
function interception_is_keyboard(device: InterceptionDevice): LongBool; cdecl; external 'interception.dll';
function interception_is_mouse(device: InterceptionDevice): LongBool; cdecl; external 'interception.dll';

implementation

function INTERCEPTION_KEYBOARD(index: Integer): Integer;
begin
  Result := index + 1;
end;

function INTERCEPTION_MOUSE(index: Integer): Integer;
begin
  Result := INTERCEPTION_MAX_KEYBOARD + index + 1
end;

end.
