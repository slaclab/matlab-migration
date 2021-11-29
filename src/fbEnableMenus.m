% --------- function ----------------------------------------------
% --- enable menu items outside feedback operation
% this function depends on the calling function to maintain handles
function fbEnableMenus(handles)
% handles - graphics components handles
set(handles.timerMenu, 'Enable', 'on');
set(handles.matrixMenu, 'Enable', 'on');
set(handles.actMenu, 'Enable', 'on');
set(handles.measMenu, 'Enable', 'on');
set(handles.fbckMenu, 'Enable', 'on');
set(handles.stateMenu, 'Enable', 'on');
set(handles.loadrefMenu, 'Enable', 'on');
set(handles.restoreActBtn, 'Enable', 'on');
set(handles.refOrbitBtn, 'Enable', 'on');
