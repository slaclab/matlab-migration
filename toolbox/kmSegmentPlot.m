function kmSegmentPlot(mainHandles)
%
% update plot of segment translations  in main KM gui
%
% mainHandles is the handles structure for the main k measurement gui.
%

set(mainHandles.KM_main,'CurrentAxes',mainHandles.segmentStatus); % make axis current w/o changing state
cla(mainHandles.segmentStatus);
mainHandles.translationActual = segmentTranslate;

plot(mainHandles.segmentStatus,...
    [1:33], mainHandles.translationActual,'rs',...
    [0 35], [0 0],'-.');
set(mainHandles.segmentStatus,'YLim',  [-10, 100]);
% set(mainHandles.segmentStatus,     'MarkerFaceColor','r',...
%     'MarkerSize',5,...
%     'LineWidth',2);

xlabel(mainHandles.segmentStatus,'Segment number')
ylabel(mainHandles.segmentStatus,'\Delta x [mm]');
%plot( [0 35], [0 0], '-.', 'LineWidth',2);


% cla(handles.segmentStatus); %segmentStatus is the axis for segment plots
% hold(handles.segmentStatus, 'on');
% plot(handles.segmentStatus, [1:33], handles.translation,...
% '  rs','MarkerFaceColor','r','MarkerSize',5)
% xlabel(handles.segmentStatus,'Segment number');
% ylabel(handles.segmentStatus,'\Delta x [mm]');
% 
% plot(handles.segmentStatus, [0 35], [0 0], '-.', 'LineWidth',2);
