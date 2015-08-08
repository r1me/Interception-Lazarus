unit uInterceptionUtils;
  
interface

uses
  Windows;
  
procedure raise_process_priority;
procedure lower_process_priority;

implementation

procedure raise_process_priority;
begin
  SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
end;

procedure lower_process_priority;
begin
  SetPriorityClass(GetCurrentProcess(), NORMAL_PRIORITY_CLASS);
end;

end.
