% This function draws the location of the two found "centers" in red on the
% images.


function draw_current_position(handles)

roiX1 = handles.image_1.roiX;
roiY1 = handles.image_1.roiY;
roiX2 = handles.image_2.roiX;
roiY2 = handles.image_2.roiY;

current_x1 = handles.current.x1 - roiX1;
current_y1 = handles.current.y1 - roiY1;
current_x2 = handles.current.x2 - roiX2;
current_y2 = handles.current.y2 - roiY2;

axes(handles.image_1_handle);
line([current_x1 current_x1], [0 handles.image_1.roiYN],...
    'Color', 'r');
line([0 handles.image_1.roiXN], [current_y1 current_y1],...
    'Color', 'r');

axes(handles.image_2_handle);
line([current_x2 current_x2], [0 handles.image_2.roiYN],...
    'Color', 'r');
line([0 handles.image_2.roiXN], [current_y2 current_y2],...
    'Color', 'r');