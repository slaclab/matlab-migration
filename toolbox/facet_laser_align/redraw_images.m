% This function is used to redraw the two images when a change is made.

function handles = redraw_images(handles)

% get a new image.
image_1_temp = profmon_grab(handles.camera1);
image_2_temp = profmon_grab(handles.camera2);

% If there is an ROI on the image then you need to offset the "desired" to
% make sure it is on the screen.  You're going to need this data.
handles.image_1.roiX = image_1_temp.roiX;
handles.image_1.roiY = image_1_temp.roiY;
handles.image_1.roiXN = image_1_temp.roiXN;
handles.image_1.roiYN = image_1_temp.roiYN;

handles.image_2.roiX = image_2_temp.roiX;
handles.image_2.roiY = image_2_temp.roiY;
handles.image_2.roiXN = image_2_temp.roiXN;
handles.image_2.roiYN = image_2_temp.roiYN;

handles.image_1.img = image_1_temp.img;
handles.image_2.img = image_2_temp.img;

axes(handles.image_1_handle);
imagesc(handles.image_1.img)
xlabel('X','FontSize',16,'FontWeight','Bold')
ylabel('Y','FontSize',16,'FontWeight','Bold')
% get the tick labels right.
xticks_temp = get(gca,'XTick');
xticks_temp = xticks_temp + handles.image_1.roiX;
set(gca,'XTickLabel',xticks_temp);
xticks_temp = get(gca,'YTick');
xticks_temp = xticks_temp + handles.image_1.roiY;
set(gca,'YTickLabel',xticks_temp);

axes(handles.image_2_handle);
imagesc(handles.image_2.img)
xlabel('X','FontSize',16,'FontWeight','Bold')
ylabel('Y','FontSize',16,'FontWeight','Bold')
% get the tick labels right.
xticks_temp = get(gca,'XTick');
xticks_temp = xticks_temp + handles.image_2.roiX;
set(gca,'XTickLabel',xticks_temp);
xticks_temp = get(gca,'YTick');
xticks_temp = xticks_temp + handles.image_2.roiY;
set(gca,'YTickLabel',xticks_temp);

handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);
