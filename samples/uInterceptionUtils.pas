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

end.
