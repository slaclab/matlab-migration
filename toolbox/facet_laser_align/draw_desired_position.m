% This function draws the "desired" position in green on the two images.

function draw_desired_position(handles)

% if there is an ROI you need to subtract off those constants to get the
% desried locaiton to plot correctly.

% keyboard

roiX1 = handles.image_1.roiX;
roiY1 = handles.image_1.roiY;
roiX2 = handles.image_2.roiX;
roiY2 = handles.image_2.roiY;

desired_x1 = handles.desired.x1 - roiX1;
desired_y1 = handles.desired.y1 - roiY1;
desired_x2 = handles.desired.x2 - roiX2;
desired_y2 = handles.desired.y2 - roiY2;

axes(handles.image_1_handle);
line([desired_x1 desired_x1], [0 handles.image_1.roiYN],...
    'Color', 'g');
line([0 handles.image_1.roiXN], [desired_y1 desired_y1],...
    'Color', 'g');

axes(handles.image_2_handle);
line([desired_x2 desired_x2], [0 handles.image_2.roiYN],...
    'Color', 'g');
line([0 handles.image_2.roiXN], [desired_y2 desired_y2],...
    'Color', 'g');