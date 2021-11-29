% Switch from one Bunch Length Measurement region to another

global gBunchLength;
global gBunchLengthGUI;

if isfield (gBunchLength,'meas')
    gBunchLength.meas = [];
end

if isfield (gBunchLength,'cal')
    gBunchLength.cal = [];
end

if isfield (gBunchLength,'facility')
    gBunchLength.facility = [];
end

% issue switch message
BunchLengthLogMsg (sprintf('%s Bunch Length Measurement GUI requested.', gBunchLength.tcav.name));

if gBunchLength.gui
    
    % set available screens
    set(gBunchLengthGUI.handles.selScreen,'String',gBunchLength.screen.a);

    % set available calibration bpms
    set(gBunchLengthGUI.handles.selBPM,'String',gBunchLength.bpm.a);

    % change window name to reflect new region
    BunchLengthGUIWindowName(gBunchLengthGUI.handles.BunchLengthGUI);

    % cleanup calibration GUI
    set (gBunchLengthGUI.handles.CALIMGALGSEL,'Visible','off');

    % cleanup meas GUI
    set (gBunchLengthGUI.handles.MEASIMGALGSEL,'Visible','off');
    set (gBunchLengthGUI.handles.SaveToFile,'Visible','off');
    set (gBunchLengthGUI.handles.SmallSaveToFile,'Visible','off');
    set (gBunchLengthGUI.handles.EXPORT,'Visible','off');
    BunchLengthGUIsetCalBtnNames;

    % set the default screen
    set(gBunchLengthGUI.handles.selScreen, 'Value',gBunchLength.screen.i);

    % set the default bpm
    set(gBunchLengthGUI.handles.selBPM, 'Value',gBunchLength.bpm.i);

    % Is the screen movable?
    if gBunchLength.screen.movable
        set (gBunchLengthGUI.handles.ScreenDesc, 'Visible', 'on');
        set (gBunchLengthGUI.handles.ScreenIn,'Visible','on');
        set (gBunchLengthGUI.handles.ScreenOut,'Visible','on');
    else
        set (gBunchLengthGUI.handles.ScreenDesc, 'Visible', 'off');
        set (gBunchLengthGUI.handles.ScreenIn,'Visible','off');
        set (gBunchLengthGUI.handles.ScreenOut,'Visible','off');
    end

end
