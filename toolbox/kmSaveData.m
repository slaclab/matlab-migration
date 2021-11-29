function kmSaveData(handles)
%
% Save all guidata from main K measurement window to file
%
% handles.KM_main must be the handle to the main K measurement figure

% copy all main gui handles struture
mainHandles = guidata(handles.KM_main);

% save to data file
path_name=([getenv('MATLABDATAFILES') '/undulator/km/K']);
filename = datestr(now,30);
filename = [path_name '/K' filename];
save(filename, 'mainHandles');
display(['All gui data written to file ' filename]);