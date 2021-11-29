% Initialize the calibration matrices.
function initialize_calibration_matrices(handles)
set(handles.xC11,'String',num2str(handles.calib.xC11))
set(handles.xC12,'String',num2str(handles.calib.xC12))
set(handles.xC21,'String',num2str(handles.calib.xC21))
set(handles.xC22,'String',num2str(handles.calib.xC22))

set(handles.yC11,'String',num2str(handles.calib.yC11))
set(handles.yC12,'String',num2str(handles.calib.yC12))
set(handles.yC21,'String',num2str(handles.calib.yC21))
set(handles.yC22,'String',num2str(handles.calib.yC22))