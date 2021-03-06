function newY = imgProcessing_panel(mainFig, x, y)
MARGIN_SIZE = 5;

%%%%%
%   WIDGETS
%%%%%
%checkbox
autoCropCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Auto',...
'style', 'checkbox',...
'tag', 'autoCropCheckbox'...
);%all other properties are default
customCropCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Custom',...
'style', 'checkbox',...
'tag', 'customCropCheckbox'...
);%all other properties are default
medianFilterCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Median',...
'style', 'checkbox',...
'tag', 'medianFilterCheckbox'...
);%all other properties are default
floorFilterCheckbox = uicontrol...
(...
mainFig,...%parent
'enable', 'off',...
'string', 'Floor',...
'style', 'checkbox',...
'tag', 'floorFilterCheckbox'...
);%all other properties are default
subtractAcquiredBgCheckbox = uicontrol...
(...
mainFig,...%parent
'max', 1,...
'min', 0,...
'string', 'Acquired',...
'style', 'checkbox',...
'tag', 'subtractAcquiredBgCheckbox',...
'value', 0 ...
);%all other properties are default
subtractCalculatedBgCheckbox = uicontrol...
(...
mainFig,...%parent
'max', 1,...
'min', 0,...
'string', 'Calculated',...
'style', 'checkbox',...
'tag', 'subtractCalculatedBgCheckbox',...
'value', 0 ...
);%all other properties are default
sliceXCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'X',...
'style', 'checkbox',...
'tag', 'sliceXCheckbox'...
);%all other properties are default
sliceYCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Y',...
'style', 'checkbox',...
'tag', 'sliceYCheckbox'...
);%all other properties are default
currentCentroidCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Current',...
'style', 'checkbox',...
'tag', 'currentCentroidCheckbox'...
);%all other properties are default
autoBppCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Auto',...
'style', 'checkbox',...
'tag', 'autoBppCheckbox'...
);%all other properties are default
autoApplyCheckbox = uicontrol...
(...
mainFig,...%parent
'string', 'Instant',...
'style', 'checkbox',...
'tag', 'autoApplyCheckbox'...
);%all other properties are default

%text
subtractBgText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Subtract background',...
'style', 'text',...
'tag', 'subtractBgText'...
);%all other properties are default
filterText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Use filter(s)',...
'style', 'text',...
'tag', 'filterText'...
);%all other properties are default
cropText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Crop',...
'style', 'text',...
'tag', 'cropText'...
);%all other properties are default
nrSlicesText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'right',...
'string', '# Slices',...
'style', 'text',...
'tag', 'nrSlicesText'...
);%all other properties are default
sliceIndexText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'right',...
'string', 'Slice #',...
'style', 'text',...
'tag', 'sliceIndexText'...
);%all other properties are default
slicePlaneText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Slice plane',...
'style', 'text',...
'tag', 'slicePlaneText'...
);%all other properties are default
colormapText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Color map',...
'style', 'text',...
'tag', 'colormapText'...
);%all other properties are default
bppText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', '12 bpp',...
'style', 'text',...
'tag', 'bppText'...
);%all other properties are default
showCentroidText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Show centroid',...
'style', 'text',...
'tag', 'showCentroidText'...
);%all other properties are default
beamSizeUnitsText = uicontrol...
(...
mainFig,...%parent
'horizontalAlignment', 'left',...
'string', 'Beam size units',...
'style', 'text',...
'tag', 'beamSizeUnitsText'...
);%all other properties are default

%edit
nrSlicesEdit = uicontrol...
(...
mainFig,...%parent
'string', '7',...
'style', 'edit',...
'tag', 'nrSlicesEdit'...
);%all other properties are default

%popupmenu
slicePopupmenu = uicontrol...
(...
mainFig,...%parent
'string', '17',...
'style', 'popupmenu',...
'tag', 'slicePopupmenu'...
);%all other properties are default
algPopupmenu = uicontrol...
(...
mainFig,...%parent
'string', '17',...
'style', 'popupmenu',...
'tag', 'algPopupmenu',...
'tooltipString', 'Algorithm'...
);%all other properties are default
colormapFcnPopupmenu = uicontrol...
(...
mainFig,...%parent
'string', {'gray'; 'hot'; 'jet'},...
'style', 'popupmenu',...
'tag', 'colormapFcnPopupmenu'...
);%all other properties are default
beamSizeUnitsPopupmenu = uicontrol...
(...
mainFig,...%parent
'string', {'pix';'um'},...
'style', 'popupmenu',...
'tag', 'beamSizeUnitsPopupmenu'...
);%all other properties are default

%slider
bppSlider = uicontrol...
(...
mainFig,...%parent
'max', 2,...%to be configured
'min', 1,...
'style', 'slider',...
'tag', 'bppSlider',...
'tooltipString', 'Bits per pixel',...
'value', 1);
%all other properties are default

%pushbutton
applyButton = uicontrol...
(...
mainFig,...
'busyAction', 'cancel',...
'string', 'Apply',...
'style', 'pushbutton',...
'tag', 'applyButton'...
);%all other properties are default

%change widget size (widget, width, height)
A_COLUMN_WIDTH = 120;
B_COLUMN_WIDTH = 90;
C_COLUMN_WIDTH = 90;

%layout: A B C A B C

%exception for slicing
imgUtil_setWidgetSize(slicePlaneText, 60, -1);
imgUtil_setWidgetSize(sliceXCheckbox, 30, -1);
imgUtil_setWidgetSize(sliceYCheckbox, 30, -1);
imgUtil_setWidgetSize(nrSlicesText, 40, -1);
imgUtil_setWidgetSize(nrSlicesEdit, 28, -1);
imgUtil_setWidgetSize(sliceIndexText, 40, -1);
imgUtil_setWidgetSize(slicePopupmenu, 40, -1);
%

imgUtil_setWidgetSize(colormapText, 60, -1);
imgUtil_setWidgetSize(colormapFcnPopupmenu, A_COLUMN_WIDTH - 60 - MARGIN_SIZE, -1);
imgUtil_setWidgetSize(bppSlider, 85, 18);
imgUtil_setWidgetSize(bppText, 40, -1);
imgUtil_setWidgetSize(autoBppCheckbox, B_COLUMN_WIDTH + C_COLUMN_WIDTH - 125 - 2 * MARGIN_SIZE, -1);

imgUtil_setWidgetSize(algPopupmenu, B_COLUMN_WIDTH + C_COLUMN_WIDTH, -1);

imgUtil_setWidgetSize(subtractBgText, A_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(subtractAcquiredBgCheckbox, B_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(subtractCalculatedBgCheckbox, C_COLUMN_WIDTH, -1);

imgUtil_setWidgetSize(filterText, A_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(floorFilterCheckbox, B_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(medianFilterCheckbox, C_COLUMN_WIDTH, -1);

imgUtil_setWidgetSize(cropText, A_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(autoCropCheckbox, B_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(customCropCheckbox, C_COLUMN_WIDTH, -1);

imgUtil_setWidgetSize(showCentroidText, A_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(currentCentroidCheckbox,  B_COLUMN_WIDTH + 2, -1)

imgUtil_setWidgetSize(beamSizeUnitsText, A_COLUMN_WIDTH, -1);
imgUtil_setWidgetSize(beamSizeUnitsPopupmenu, 40, -1);

imgUtil_setWidgetSize(autoApplyCheckbox, 60, -1);
imgUtil_setWidgetSize(applyButton, 40, -1);
%%%%%
%   MISC
%%%%%
%defaultBgColor = get(colormapText, 'backgroundColor');

%debug
% set(subtractBgText, 'backgroundColor', [1 0 0]);
% set(filtersText, 'backgroundColor', [1 0 0]);
% set(floorFilterCheckbox, 'backgroundColor', [1 0 0]);
% set(colormapText, 'backgroundColor', [1 1 1]); %white

%%%%%
%   LAYOUT (from top)
%%%%%

rowLeft1 = x;
rowLeft2 = rowLeft1 + A_COLUMN_WIDTH + B_COLUMN_WIDTH + ...
    C_COLUMN_WIDTH + 3 * MARGIN_SIZE;
rowBottom = y;

%
rowBottom = rowBottom - 4 *MARGIN_SIZE;
imgUtil_rowLayout(...
    [slicePlaneText, sliceXCheckbox, sliceYCheckbox,...
    nrSlicesText, nrSlicesEdit,...
    sliceIndexText, slicePopupmenu],...
    [-4, 0, 0,...
    -4, 0,...
    -4, 0],...
    rowLeft1, rowBottom, MARGIN_SIZE);
imgUtil_rowLayout(...
    [subtractBgText, subtractAcquiredBgCheckbox, subtractCalculatedBgCheckbox],...
    [-4, 0, 0],...
    rowLeft2, rowBottom, MARGIN_SIZE);

%
rowBottom = rowBottom - 5 * MARGIN_SIZE;
imgUtil_rowLayout(...
    [filterText, floorFilterCheckbox, medianFilterCheckbox],...
    [-4, 0, 0],...
    rowLeft1, rowBottom, MARGIN_SIZE); 

imgUtil_rowLayout(...
    [cropText, autoCropCheckbox, customCropCheckbox],...
    [-4, 0, 0],...
    rowLeft2, rowBottom, MARGIN_SIZE); 

%
rowBottom = rowBottom - 5 * MARGIN_SIZE;
imgUtil_rowLayout(...
    [showCentroidText, currentCentroidCheckbox],...
    [-4, 0],...
    rowLeft1,...
    rowBottom, MARGIN_SIZE); 
imgUtil_rowLayout(...
    [colormapText, colormapFcnPopupmenu,  bppSlider, bppText, autoBppCheckbox],...
    [-4, 0, 0, -4, 0],...
    rowLeft2, rowBottom, MARGIN_SIZE + 1);

imgUtil_rowLayout(...
    [beamSizeUnitsText, beamSizeUnitsPopupmenu],...
    [-4, 0],...
    rowLeft2,...
    rowBottom, MARGIN_SIZE + 3); 

%
imgUtil_rowLayout(...
    [algPopupmenu],...
    [0],...
    rowLeft2 + A_COLUMN_WIDTH + 3 + MARGIN_SIZE,...
    rowBottom, MARGIN_SIZE);

imgUtil_rowLayout(...
    [autoApplyCheckbox, applyButton],...
    [0, 0],...
    rowLeft2 + ...
    A_COLUMN_WIDTH + B_COLUMN_WIDTH + C_COLUMN_WIDTH - 45,...
    rowBottom, MARGIN_SIZE); 

newY = y - 115;