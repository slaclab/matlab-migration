% the function used to find the "center".  Currently the only option is the
% simple solver, which should be fine while testing.
function handles = find_centers(handles)

% % find the current points.
% if handles.camera_1_finder == 2
%     [temp_x, temp_y] = LRoomFar_Center_Finder(handles.image_1.img);
% end

[temp_x, temp_y] = find_centers_2(handles, 1);
handles.current.x1 = temp_x + handles.image_1.roiX;
handles.current.y1 = temp_y + handles.image_1.roiY;

% if handles.camera_2_finder == 1
%     [temp_x, temp_y] = simple_image_peak_finder(handles.image_2.img);
% end

[temp_x, temp_y] = find_centers_2(handles, 2);
handles.current.x2 = temp_x + handles.image_2.roiX;
handles.current.y2 = temp_y + handles.image_2.roiY;

% now update the edit boxes
initialize_current_point(handles)


% This function determines which method to use when finding centers.  It
% can only be called by find_centers()!

% The pop-up menu returns a number corresponding to the position on the
% list.  So if you added a new method to the pop-up list in the main GUI
% and it is in position 3 you will need to add a 'case 3' below.

function [temp_x, temp_y] = find_centers_2(handles, camera_num)

if camera_num == 1
    method_in = get(handles.camera_1_fit_type,'Value');
    image_in = handles.image_1.img;
end

if camera_num == 2
    method_in = get(handles.camera_2_fit_type,'Value');
    image_in = handles.image_2.img;
end

switch method_in
    case 1
        [temp_x, temp_y] = simple_image_peak_finder(image_in);
    case 2
        [temp_x, temp_y] = LRoomFar_Center_Finder(image_in);
end