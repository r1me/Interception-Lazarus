unit uInterceptionUtils;
  
interface

uses
  Windows, SysUtils, DateUtils;
  
procedure raise_process_priority;
procedure lower_process_priority;
function get_screen_width: Integer;
function get_screen_height: Integer;
procedure busy_wait(count: Cardinal);
function calculate_busy_wait_millisecond: Cardinal;
function try_open_single_program(const name: AnsiString): PHandle;
procedure close_single_program(program_instance: PHandle);

implementation

procedure raise_process_priority;
begin
  SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
end;

procedure lower_process_priority;
begin
  SetPriorityClass(GetCurrentProcess(), NORMAL_PRIORITY_CLASS);
end;

function get_screen_width: Integer;
begin
  Result := GetSystemMetrics(SM_CXSCREEN);
end;

function get_screen_height: Integer;
begin
  Result := GetSystemMetrics(SM_CYSCREEN);
end;

{$OPTIMIZATION OFF}

procedure busy_wait(count: Cardinal);
begin
  repeat
    Dec(count);
  until count = 0;
end;

function calculate_busy_wait_millisecond: Cardinal;
var
  count: Cardinal;
  start, endtime: TTime;
begin
  count := 2000000000;
  start := Now;
  repeat
    Dec(count);
  until count = 0;
  endtime := Now;
  Result := Cardinal(Round(2000000 / (MilliSecondsBetween(start, endtime) / 1000)));
end;

{$OPTIMIZATION ON}

function try_open_single_program(const name: AnsiString): PHandle;
var
  full_name: AnsiString;
  program_instance: THandle;
begin
  full_name := 'Global\{' + name + '}';
  program_instance := CreateMutexA(nil, False, PAnsiChar(full_name));
  if (GetLastError = ERROR_ALREADY_EXISTS) or (program_instance = 0) then
    Result := nil
  else
    Result := PHandle(program_instance);
end;

procedure close_single_program(program_instance: PHandle);
begin
  CloseHandle(THandle(program_instance));
end;

end.
