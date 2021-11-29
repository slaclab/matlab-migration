function fbRegold(varargin)
% hObject    handle to restoreActBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of restoreActBtn
% initialize the feedback loop structures
filename = char(varargin);
try
   fbInitFbckStructures(filename);
catch
   error(lasterror);
   exitApp;
end


h= fbRegoldGUI();
waitfor(h);

exitApp;

% --------- function ----------------------------------------------
function exitApp
% clean up memory and exit this application
%
% 
config = getappdata(0,'Config_structure');
if config.configchanged==1
    rsp = questdlg('Zero state setpoints and save configuration?', 'Save configuration', 'Yes', 'No','Yes');
    if strcmpi(rsp,'Yes')
       %set state setpoint to 0
       lcaPut(config.states.allspPVs, 0);
       % just save the file, no name changes here
       fbWriteConfigFile();
       %saveMenu_Callback(hObject, eventdata, handles); 
       %this may save a changed config, get it again
       config = getappdata(0,'Config_structure');
       indStatePV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:STATE'];
       lcaPut(indStatePV, '0');
    end
    delete(config.fbckTimer);
    rmappdata(0,'Config_structure');
else
    delete(config.fbckTimer);
    rmappdata(0,'Config_structure');
end
%if not running the desktop, exit from matlab
if usejava('desktop')
    % dont exit
else
    exit
end

