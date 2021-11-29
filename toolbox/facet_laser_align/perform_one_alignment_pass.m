% This functin performs one total step in the alignment process.  It does
% not calibrate!

function handles = perform_one_alignment_pass(handles)

% make sure the images are up to date.
handles = redraw_images(handles);
% make sure the moments are up to date.
handles = find_centers(handles);
initialize_current_point(handles);
% find the movement solution
handles = find_mirror_solution(handles);
initialize_mirror_motion(handles);
% make the step.
perform_mirror_match(handles)
% refresh the cameras
handles = redraw_images(handles);
% make sure the moments are up to date.
handles = find_centers(handles);
initialize_current_point(handles);