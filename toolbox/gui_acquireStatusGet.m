function status = gui_acquireStatusGet(hObject, handles)
%GUI_ACQUIRESTATUSGET
%  STATUS = GUI_ACQUIRESTATUSGET(HOBJECT, HANDLES).

% Features:

% Input arguments:
%    HOBJECT: Handle to GUI object
%    HANDLES: Handles structure of GUI object

% Output arguments: none
%    STATUS:  Present status of GUI (0: Stopped, 1: Acquiring)

% Compatibility: Version 7 and higher
% Called functions: gui_acquireStatusSet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

status=0;
tagList={'acquireStart_btn' 'START'};
for tag=tagList
    if isfield(handles,tag{:})
        status=get(handles.(tag{1}),'Value');
        break
    end
end
