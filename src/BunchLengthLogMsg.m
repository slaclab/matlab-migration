% log a message for Bunch Length Measurement
% Mike Zelazny - zelazny@stanford.edu

function BunchLengthLogMsg (message)

global gBunchLength;
global gBunchLengthGUI;
global gErrInstance;

if gBunchLength.gui
    set (gBunchLengthGUI.handles.Message, 'String', message);
    if isfield(gBunchLength,'gui_pause_time')
        pause(gBunchLength.gui_pause_time); % give GUI time to update
    end
end

setFacility = 0;
if isfield(gBunchLength,'facility')
    if isempty(gBunchLength.facility)
        setFacility = 1;
    end
else
    setFacility = 1;
end

if setFacility
    gBunchLength.facility = sprintf ('%s Bunch Length', gBunchLength.tcav.name);
    gErrInstance = getLogger(gBunchLength.facility);
end

put2log(message);
