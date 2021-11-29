% This file finds the C matrix elements, in order to perform the the
% alignment.

function handles = C_matrix_builder(handles)

% copy some values over to make the code a little cleaner later.

motor_M1X = handles.mirror_motors.M1X;
motor_M2X = handles.mirror_motors.M2X;
motor_M1Y = handles.mirror_motors.M1Y;
motor_M2Y = handles.mirror_motors.M2Y;

current_x1 = handles.current.x1;
current_x2 = handles.current.x2;

step_size = handles.calibration.step_size;

% This is one step :(
%--------------------------------------------------------------------------
% Perform a step
motor_perform_step(motor_M1X,step_size)
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

% grabt the values of interest
calibration_x1 = handles.current.x1;
calibration_x2 = handles.current.x2;

% go back
motor_perform_step(motor_M1X,-step_size)
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

% calc the values to use.
C11_temp = (current_x1 - calibration_x1)/step_size;
C21_temp = (current_x2 - calibration_x2)/step_size;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Make sure the positions you are using are current.
current_x1 = handles.current.x1;
current_x2 = handles.current.x2;


motor_perform_step(motor_M2X,step_size)
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

calibration_x1 = handles.current.x1;
calibration_x2 = handles.current.x2;


motor_perform_step(motor_M2X,-step_size) % now go back!
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

C12_temp = (current_x1 - calibration_x1)/step_size;
C22_temp = (current_x2 - calibration_x2)/step_size;
%--------------------------------------------------------------------------

% Now update the calibration matrices.

handles.calib.xC11 = C11_temp;
handles.calib.xC12 = C12_temp;
handles.calib.xC21 = C21_temp;
handles.calib.xC22 = C22_temp;

%--------------------------------------------------------------------------
% Make sure the positions you are using are current.
current_y1 = handles.current.y1;
current_y2 = handles.current.y2;

motor_perform_step(motor_M1Y,step_size)
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

calibration_y1 = handles.current.y1;
calibration_y2 = handles.current.y2;


motor_perform_step(motor_M1Y,-step_size) % now go back!
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

C11_temp = (current_y1 - calibration_y1)/step_size;
C12_temp = (current_y2 - calibration_y2)/step_size;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Make sure the positions you are using are current.
current_y1 = handles.current.y1;
current_y2 = handles.current.y2;

motor_perform_step(motor_M2Y,step_size)
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

calibration_y1 = handles.current.y1;
calibration_y2 = handles.current.y2;


motor_perform_step(motor_M2Y,-step_size) % now go back!
% redraw everything
handles = redraw_images(handles);
handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

C21_temp = (current_y1 - calibration_y1)/step_size;
C22_temp = (current_y2 - calibration_y2)/step_size;
%--------------------------------------------------------------------------

% Now update the calibration matrices.

handles.calib.yC11 = C11_temp;
handles.calib.yC12 = C12_temp;
handles.calib.yC21 = C21_temp;
handles.calib.yC22 = C22_temp;