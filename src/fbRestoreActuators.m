function fbRestoreActuators(varargin)
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
   rmappdata(0,'Loop_structure');
   rmappdata(0,'Config_structure');
   exitApp;
end


config = getappdata(0,'Config_structure');
rstrNames = fbAddToPVNames(config.act.allstorePVs, 'RSTR');
try
   curr_act = lcaGet(config.act.allactPVs);
catch
   dbstack;
   h = errordlg('Could not read actuator PVs for current values');
   waitfor(h);
   fbLogMsg('Could not read actuator PVs for current values, actuator settings were not restored.');
   exitApp;
end

try
   rstr_act = lcaGet(rstrNames);
catch
   dbstack;
   h = errordlg('Could not read PVs for stored actuator values');
   waitfor(h);
   fbLogMsg('Could not read PVs for stored actuator values, actuator settings were not restored.');
   exitApp;
end


strs{1} = 'Change actuator values from current back to original?';
% create the actuator strings
for i=1:length(config.act.allactPVs)
   strs{i+1} = strcat(char(config.act.allactPVs(i)), ...
         '  current value:  ', num2str(curr_act(i)), ...
         '  original value:  ', num2str(rstr_act(i)) );
end
         
rsp = questdlg(strs, 'Actuator change verify', 'Yes', 'No', 'No');
if strcmp(rsp,'Yes')==1
   try
      lcaPut(config.act.allactPVs, rstr_act);
   catch
      dbstack;
      h = errordlg('Could not write to actuator PVs');
      waitfor(h);
      fbLogMsg('Could not write to actuator PVs, actuator settings were not restored.');
      exitApp;
   end
end
exitApp;

% --------- function ----------------------------------------------
function exitApp
% clean up memory and exit this application
%
% 
rmappdata(0,'Loop_structure');
rmappdata(0,'Config_structure');
exit;

