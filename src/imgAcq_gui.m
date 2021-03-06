%This is the GUI for the Image Acquisition application
function mainFig = imgAcq_gui

MARGIN_SIZE = 5;
IMG_SPACE_WIDTH = 830;
IMG_SPACE_HEIGHT = 455;%9 * IMG_SPACE_WIDTH/16; 
LIVE_IMG_PANEL_HEIGHT = 635; %in sync with imgAcq_gui_update.m

%WINDOW SIZE AND POSITION
winWidth = IMG_SPACE_WIDTH + MARGIN_SIZE * 2;
winHeight = IMG_SPACE_HEIGHT + 315;
screenSize = get(0, 'screensize'); %[left, bottom, width, height]
screenWidth = screenSize(3);
screenHeight = screenSize(4);

%centre of the screen
winPosition =...
[...
    0.5 * (screenWidth - winWidth),...
    0.5 * (screenHeight - winHeight),...
    winWidth,...
    winHeight...
]; %[left, bottom, width, height]
mainFig = figure...
(...
'handleVisibility', 'callback',...
'invertHardcopy','off',...
'menubar', 'none',...
'name', 'Image Acquisition',...
'numberTitle', 'off',...
'paperOrientation', 'landscape',...
'paperPositionMode', 'auto',...
'position', winPosition,...
'toolbar', 'none',...
'windowstyle', 'normal',...
'visible', 'off'... %hide, while the GUI is being constructed
);%all other properties are default

%panels
controlPanel = uipanel(...
'borderType', 'none',...
'parent', mainFig,...
'tag', 'controlPanel',...
'title', '',...
'units', 'pixels'...
);
liveImgPanel = uipanel(...
'borderType', 'none',...
'parent', mainFig,...
'tag', 'liveImgPanel',...
'title', '',...
'units', 'pixels'...
);

%%%%%
%   WIDGETS
%%%%%

%pushbutton
measureButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'enable', 'off',...
'string', 'Measure',...
'style', 'pushbutton',...
'tag', 'measureButton'...
);%all other properties are default
cancelButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Cancel',...
'style', 'pushbutton',...
'tag', 'cancelButton'...
);%all other properties are default
browseButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Browse...',...
'style', 'pushbutton',...
'tag', 'browseButton'...
);%all other properties are default
saveButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Save...',...
'style', 'pushbutton',...
'tag', 'saveButton'...
);%all other properties are default
loadButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Load...',...
'style', 'pushbutton',...
'tag', 'loadButton'...
);%all other properties are default
logBookButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', '-> Log Book',...
'style', 'pushbutton',...
'tag', 'logBookButton'...
);%all other properties are default
helpButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Help',...
'style', 'pushbutton',...
'tag', 'helpButton'...
);%all other properties are default
exitButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Exit Matlab',...
'style', 'pushbutton',...
'tag', 'exitButton'...
);%all other properties are default
inButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'In',...
'style', 'pushbutton',...
'tag', 'inButton'...
);%all other properties are default
outButton = uicontrol...
(...
controlPanel,...%parent
'busyAction', 'cancel',...
'string', 'Out',...
'style', 'pushbutton',...
'tag', 'outButton'...
);%all other properties are default
undockButton = uicontrol...
(...
liveImgPanel,...%parent
'busyAction', 'cancel',...
'string', '',...
'style', 'pushbutton',...
'tag', 'undockButton',...
'tooltipString', 'Undock'...
);%all other properties are default
captureButton = uicontrol...
(...
liveImgPanel,...%parent
'busyAction', 'cancel',...
'string', 'Capture...',...
'style', 'pushbutton',...
'tag', 'captureButton'...
);%all other properties are default
saveCurrentCentroidButton = uicontrol...
(...
liveImgPanel,...
'busyAction', 'cancel',...
'string', 'Save...',...
'style', 'pushbutton',...
'tag', 'saveCurrentCentroidButton',...
'tooltipString', 'Save Current Centroid...'...
);%all other properties are default

%axes
imgAxes = axes...
(...
'color', 'none',...
'parent', liveImgPanel,...
'tag', 'imgAxes',...
'units', 'pixels'...%position
);%all other properties are default

%text
screenText = uicontrol...
(...
controlPanel,...%parent
'horizontalAlignment', 'left',...
'string', 'Screen is',...
'style', 'text',...
'tag', 'screenText'...
);%all other properties are default
screenStatusText = uicontrol...
(...
controlPanel,...%parent
'horizontalAlignment', 'left',...
'string', 'OUT',...
'style', 'text',...
'tag', 'screenStatusText'...
);%all other properties are default
nrBgImgsText = uicontrol...
(...
controlPanel,...%parent
'horizontalAlignment', 'left',...
'string', 'Background images',...
'style', 'text',...
'tag', 'nrBgImgsText'...
);%all other properties are default
nrBeamImgsText = uicontrol...
(...
controlPanel,...%parent
'horizontalAlignment', 'left',...
'string', 'Beam images',...
'style', 'text',...
'tag', 'nrBeamImgsText'...
);%all other properties are default
liveImgTsText = uicontrol...
(...
liveImgPanel,...%parent
'horizontalAlignment', 'right',...
'string', '10-10-2006 18:00:05.747',...
'style', 'text',...
'tag', 'liveImgTsText'...
);%all other properties are default
datasetsText = uicontrol...
(...
controlPanel,...%parent
'horizontalAlignment', 'right',...
'string', '0 datasets in memory (0 saved)',...
'style', 'text',...
'tag', 'datasetsText'...
);%all other properties are default
savedBgImgTsText = uicontrol...
(...
controlPanel,...%parent
'horizontalAlignment', 'right',...
'string', 'Background image from 10-10-2006 18:00:05.546',...
'style', 'text',...
'tag', 'savedBgImgTsText'...
);%all other properties are default
showSavedCentroidsText = uicontrol...
(...
liveImgPanel,...%parent
'horizontalAlignment', 'left',...
'string', 'Show centroid(s)',...
'style', 'text',...
'tag', 'showSavedCentroidsText'...
);%all other properties are default
fitResultsText = uicontrol...
(...
liveImgPanel,...%parent
'horizontalAlignment', 'left',...
'string', {'dx = 0.1mm', '{\itAe}^{-\alpha\itt}sin\beta{\itt} \alpha<<\beta', 'dy = 0.2mm'},...%test values
'style', 'text',...
'tag', 'fitResultsText'...
);%all other properties are default

%popupmenu
cameraPopupmenu = uicontrol...
(...
controlPanel,...%parent
'string', 'dummy',...
'style', 'popupmenu',...
'tag', 'cameraPopupmenu',...
'tooltipString', 'Camera'...
);%all other properties are default

%edit
nrBgImgsEdit = uicontrol...
(...
controlPanel,...%parent
'string', '3',...
'style', 'edit',...
'tag', 'nrBgImgsEdit'...
);%all other properties are default
nrBeamImgsEdit = uicontrol...
(...
controlPanel,...%parent
'string', '12',...
'style', 'edit',...
'tag', 'nrBeamImgsEdit'...
);%all other properties are default
dsLabelEdit = uicontrol...
(...
controlPanel,...%parent
'string', 'Dataset #x (Camera)',...
'style', 'edit',...
'tag', 'dsLabelEdit',...
'tooltipString', 'Dataset label'...
);%all other properties are default

%checkbox
goldenOrbitCentroidCheckbox = uicontrol...
(...
liveImgPanel,...%parent
'string', 'Golden orbit',...
'style', 'checkbox',...
'tag', 'goldenOrbitCentroidCheckbox'...
);%all other properties are default
laserBeamCentroidCheckbox = uicontrol...
(...
liveImgPanel,...%parent
'string', 'Laser beam',...
'style', 'checkbox',...
'tag', 'laserBeamCentroidCheckbox'...
);%all other properties are default
showLiveImgCheckbox = uicontrol...
(...
controlPanel,...%parent
'string', 'Show live image',...
'style', 'checkbox',...
'tag', 'showLiveImgCheckbox'...
);%all other properties are default
processLiveImgCheckbox = uicontrol...
(...
liveImgPanel,...%parent
'string', 'Process image',...
'style', 'checkbox',...
'tag', 'processLiveImgCheckbox'...
);%all other properties are default

CONTROL_PANEL_HEIGHT = winHeight - LIVE_IMG_PANEL_HEIGHT;
imgUtil_setWidgetSize(controlPanel, winWidth, CONTROL_PANEL_HEIGHT);
imgUtil_setWidgetSize(liveImgPanel, winWidth, LIVE_IMG_PANEL_HEIGHT);

imgUtil_setWidgetSize(logBookButton, 80, -1);
imgUtil_setWidgetSize(exitButton, 70, -1);

imgUtil_setWidgetSize(screenText, 55, -1);
imgUtil_setWidgetSize(screenStatusText, 45, -1);
imgUtil_setWidgetSize(cameraPopupmenu, 145, -1);

imgUtil_setWidgetSize(nrBgImgsText, 110, -1);
imgUtil_setWidgetSize(nrBeamImgsText, 70, -1);

imgUtil_setWidgetSize(nrBgImgsEdit, 25, -1);
imgUtil_setWidgetSize(nrBeamImgsEdit, 25, -1);
imgUtil_setWidgetSize(dsLabelEdit, 200, -1);

imgUtil_setWidgetSize(datasetsText, 200, -1);

imgUtil_setWidgetSize(savedBgImgTsText, 300, -1);
imgUtil_setWidgetSize(showLiveImgCheckbox, 103, -1); 

imgUtil_setWidgetSize(showSavedCentroidsText, 100, -1);
imgUtil_setWidgetSize(goldenOrbitCentroidCheckbox,  90, -1);
imgUtil_setWidgetSize(laserBeamCentroidCheckbox,  90 , -1);

imgUtil_setWidgetSize(undockButton, 12, 12);

imgUtil_setWidgetSize(imgAxes, IMG_SPACE_WIDTH - 42, IMG_SPACE_HEIGHT - 78);

imgUtil_setWidgetSize(processLiveImgCheckbox, 100, -1);

imgUtil_setWidgetSize(captureButton, 60, -1);
imgUtil_setWidgetSize(liveImgTsText, 250 - MARGIN_SIZE, -1);

imgUtil_setWidgetSize(saveCurrentCentroidButton, 50, -1);

imgUtil_setWidgetSize(fitResultsText, 205, 85);%width was determined empirically
%%%%%
%   MISC
%%%%%
%set window bg color to widget bg color
defaultBgColor = get(screenText, 'backgroundColor');
set(mainFig, 'color', defaultBgColor);
set(nrBgImgsEdit, 'backgroundColor', [1 1 1]); %white
set(nrBeamImgsEdit, 'backgroundColor', [1 1 1]); %white
set(dsLabelEdit, 'backgroundColor', [1 1 1]); %white

% %for debugging
% set(nrBgImgsText, 'backgroundColor', [1 1 1]);
% set(nrBeamImgsText, 'backgroundColor', [1 1 1]);
% set(savedBgImgTsText, 'backgroundColor', [1 1 0]);
% set(showLiveImgCheckbox, 'backgroundColor', [1 1 0]);
% set(controlPanel, 'backgroundColor', [0 1 1]);
% set(liveImgPanel, 'backgroundColor', [0.1 0.4 0.7]);
% set(fitResultsText, 'backgroundColor', [0.1 0.4 0.7]);

%icon
try
    icon = imread('icon_undock.png', 'png', 'BackgroundColor', defaultBgColor);
    set(undockButton, 'CData', icon);
catch
    %do nothing
end
%%%%%
%   LAYOUT (from top)
%%%%%

%panels
imgUtil_rowLayout(...
    [controlPanel],...
    [0],...
    0, winHeight - CONTROL_PANEL_HEIGHT, MARGIN_SIZE); 
imgUtil_rowLayout(...
    [liveImgPanel],...
    [0],...
    0, 0, MARGIN_SIZE); 

%uicontrols
%%%%%%control panel
rowBottom = CONTROL_PANEL_HEIGHT - 20;
rowLeft = MARGIN_SIZE;
imgUtil_rowLayout(...
    [cameraPopupmenu, measureButton, cancelButton, saveButton,...
    loadButton, browseButton, logBookButton, helpButton],...
    [0, 0, 0, 0,...
    0, 0, 0, 0],...
    rowLeft, rowBottom, MARGIN_SIZE); 

imgUtil_rowLayout(...
    [exitButton],...
    0,...
    winWidth - MARGIN_SIZE - 68, rowBottom, MARGIN_SIZE); 

rowBottom = rowBottom - 6 *MARGIN_SIZE;
imgUtil_rowLayout(...
    [nrBgImgsEdit, nrBgImgsText],...
    [0, -4],...
    rowLeft, rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [nrBeamImgsEdit, nrBeamImgsText],...
    [0, -4],...
    rowLeft + 160, rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [dsLabelEdit],...
    [0, -4],...
    rowLeft + 355, rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [datasetsText],...
    [-4],...
    rowLeft + IMG_SPACE_WIDTH - 200, rowBottom, MARGIN_SIZE);

%
rowBottom = rowBottom - 7 * MARGIN_SIZE;
imgUtil_rowLayout(...
    [screenText, screenStatusText, inButton, outButton],...
    [-4, -4, 0, 0],...
    rowLeft, rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [savedBgImgTsText],...
    [0],...
    winWidth -300 - MARGIN_SIZE, rowBottom, MARGIN_SIZE);

%progress panel
rowBottom = progress_panel(controlPanel, rowLeft, rowBottom, winWidth - 120 - MARGIN_SIZE);
handles = guihandles(mainFig);
imgUtil_setWidgetSize(handles.progressAxes, winWidth - 132 - 4*MARGIN_SIZE, -1);

%
rowBottom = rowBottom + 3 * MARGIN_SIZE;
imgUtil_rowLayout(...
    [showLiveImgCheckbox],...
    [0],...
    winWidth - MARGIN_SIZE - 103, rowBottom - 1, MARGIN_SIZE);

%%%%%%%%%live img panel
%
rowBottom = winHeight - CONTROL_PANEL_HEIGHT - 45;
imgUtil_rowLayout(...
    [undockButton],...
    [-2],...
    winWidth - 12 - MARGIN_SIZE, rowBottom, MARGIN_SIZE);

% image axes
rowBottom = rowBottom - IMG_SPACE_HEIGHT;
imgUtil_rowLayout(...
    [imgAxes],...
    [0],...
    rowLeft + 40, rowBottom + 45, MARGIN_SIZE);

% additional image functionality panel
rowBottom = rowBottom - 9* MARGIN_SIZE;
imgUtil_rowLayout(...
    processLiveImgCheckbox,...
    0,...
    rowLeft, rowBottom, MARGIN_SIZE);
imgUtil_rowLayout(...
    [liveImgTsText, captureButton],...
    [-4, 0],...
    rowLeft + 520, rowBottom, MARGIN_SIZE);

rowBottom = rowBottom - MARGIN_SIZE;
%%%% image processing panel
imgProcessing_panel(liveImgPanel, rowLeft, rowBottom);
handles = guihandles(mainFig);
set(handles.subtractAcquiredBgCheckbox, 'string', 'Saved');
set(handles.customCropCheckbox, 'enable', 'off');
set(handles.autoApplyCheckbox, 'visible', 'off');
set(handles.autoBppCheckbox, 'enable', 'on');
set(handles.applyButton, 'visible', 'off');
imgUtil_setWidgetSize(handles.beamSizeUnitsText, 90, -1);

rowBottom = LIVE_IMG_PANEL_HEIGHT - 30;
imgUtil_rowLayout(...
    [handles.beamSizeUnitsText, handles.beamSizeUnitsPopupmenu],...
    [-4, 0],...
    rowLeft, rowBottom, MARGIN_SIZE);
imgUtil_rowLayout(...
    [handles.colormapText, handles.colormapFcnPopupmenu, handles.bppSlider,...
    handles.bppText, handles.autoBppCheckbox],...
    [-4, 0, 0, -4, 0],...
    rowLeft + 190, rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [showSavedCentroidsText, goldenOrbitCentroidCheckbox, laserBeamCentroidCheckbox],...
    [-4, 0, 0],...
    rowLeft + 550, rowBottom, MARGIN_SIZE);

rowBottom = 10;
imgUtil_rowLayout(...
    [handles.showCentroidText, handles.currentCentroidCheckbox, handles.saveCurrentCentroidButton],...
    [0, 4, 4],...
    rowLeft, rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [handles.algPopupmenu],...
    [0],...
    rowLeft + 440, rowBottom + 5, MARGIN_SIZE);

%%%
% annotations
imgUtil_rowLayout(...
    [fitResultsText],...
    [0],...
    650, 0, MARGIN_SIZE);

%make GUI visible
set(mainFig, 'visible', 'on');
