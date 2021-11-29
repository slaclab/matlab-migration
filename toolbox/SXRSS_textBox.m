function [] =SXRSS_textBox(pvHandle, textHandle,actHandle,logText,logHandle)

% [] =SXRSS_textBox(pvHandle, textHandle,actHandle,logText,logHandle)
%
% Function to handle I/O of text boxes for SXRSS_gui
%
%   INPUTS:     pvHandle:       motion control pv e.g.'GRAT:UND1:934:X'
%               textHandle:     tag from GUIDE for textbox
%               actHandle:      handle to active checkbox
%               logText:        string name assoc. w/ motion ctrl pv
%               logHandle:      handle message box for printing
%
%   OUTPUTS:    N/A
%
%   AUTHOR:     Dorian K. Bohler 11/19/13
% ========================================================================
new = str2double(get(textHandle,'String'));
act=get(actHandle, 'Value');


if strcmp(pvHandle(1:4), 'SIOC')
    lcaPutSmart(pvHandle, new(1));
    currentValue = lcaGetSmart(pvHandle);
else
    lcaPutSmart([pvHandle ':DES'], new(1));
    lcaPutSmart([pvHandle ':TRIM.PROC'], 1);
    currentValue = lcaGetSmart([pvHandle ':ACT']);
end

texts=[logText ' moved from ' num2str(currentValue)   ' to ' num2str(new(1))];

SXRSS_log(logHandle, texts, act)

if epicsSimul_status
    if strcmp(pvHandle(1:4), 'SIOC')
        lcaPutSmart(pvHandle, new(1));
    else
        lcaPutSmart([pvHandle ':ACT'], new);
    end
end



