% This function is the wrapper for the mirror motion solver.  It translates
% the struct from the GUI into something more easily understood by the user
% and the solver.
function handles = find_mirror_solution(handles)

current_to_pass.x1 = handles.current.x1;
current_to_pass.y1 = handles.current.y1;
current_to_pass.x2 = handles.current.x2;
current_to_pass.y2 = handles.current.y2;

desired_to_pass.x1 = handles.desired.x1;
desired_to_pass.y1 = handles.desired.y1;
desired_to_pass.x2 = handles.desired.x2;
desired_to_pass.y2 = handles.desired.y2;

calib.xC11 = handles.calib.xC11;
calib.xC12 = handles.calib.xC12;
calib.xC21 = handles.calib.xC21;
calib.xC22 = handles.calib.xC22;

calib.yC11 = handles.calib.yC11;
calib.yC12 = handles.calib.yC12;
calib.yC21 = handles.calib.yC21;
calib.yC22 = handles.calib.yC22;

[M_out] = mirror_motion_solver(current_to_pass,desired_to_pass,calib);



handles.mirrormotion.M1X = M_out(1,1);
handles.mirrormotion.M2X = M_out(2,1);
handles.mirrormotion.M1Y = M_out(1,2);
handles.mirrormotion.M2Y = M_out(2,2);
