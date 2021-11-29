function gui_statusDisp(handles, str)
%GUI_STATUSDISP
%  GUI_STATUSDISP(HANDLES, STR, TAG) outputs str in cmd line and if exists
%  sets string in GUI text object HANDLES or HANDLES.STATUS_TXT to STR.
%  Function calls drawnow() to update display.
%
% Input arguments:
%    HANDLES: Structure as returned from GUIDATA with field 'status_txt' or
%             handle to text object
%    STR: Message string
%
% Output arguments: none
%
% Compatibility: Version 7 and higher
%
% --------------------------------------------------------------------
% Author: Henrik Loos, SLAC
% Mod:    14-June-2016, Greg White, SLAC
%         log with lprintf  
% --------------------------------------------------------------------

str=cellstr(str);strDisp=[str{:}];

% In production operation, log to the logging service, otherwise log 
% to stdout.
if ~epicsSimul_status 
    disp_log(strDisp);              % Log to logging service (eg cmlog) 
else
    disp(strDisp);                  % Log to STDOUT 
end
if isfield(handles,'status_txt'), handles=handles.status_txt;end
if ishandle(handles)
    set(handles,'String',str);
    drawnow;
end
