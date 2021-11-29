function isOn = gui_acquireStatusSet(hObject, handles, val)
%GUI_ACQUIRESTATUSSET
%  GUI_ACQUIRESTATUSSET(HOBJECT, HANDLES, VAL).

% Features:

% Input arguments:
%    HOBJECT: Handle to GUI object
%    HANDLES: Handles structure of GUI object
%    VAL:     Set status of GUI (0: Stop, 1: Acquire)

% Output arguments: none
%    ISON:    Initial status of GUI (0: Stopped, 1: Acquiring)

% Compatibility: Version 7 and higher
% Called functions: gui_acquireStatusSet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

persistent STDOUT;
STDOUT=1;

isOn=gui_acquireStatusGet(hObject,handles);
str={'Start Scan' 'Scanning ...'};
str3={'stopped' 'aborted'};
str2={[' acquisition ' str3{strcmp(get(gcbo,'tag'),'acquireAbort_btn')+1} ' after '] ' aquisition started '};
[pname,file]=fileparts(get(handles.output,'FileName'));

tagList={'acquireStart_btn' 'START'};
for tag=tagList
    if isfield(handles,tag{:})
        set(handles.(tag{:}),'Value',val,'String',str{val+1});
        t=datestr(now);if ~val, t=datestr(now-get(handles.(tag{:}),'userdata'),'HH:MM:SS');end
        if val ~= isOn
            gui_statusDisp([],[file str2{val+1} t]);
            lprintf(STDOUT, [file str2{val+1} t]);
        end
        set(handles.(tag{:}),'userdata',now);
        break
    end
end
