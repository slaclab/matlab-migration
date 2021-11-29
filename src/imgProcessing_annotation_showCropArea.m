function imgProcessing_annotation_showCropArea(imgAxes, cropArea)
%[left top width height]
left = round(cropArea(1));
top = round(cropArea(2));
width = round(cropArea(3));
height = round(cropArea(4));
right = left + width;
bottom = top + height;%yup, see imcrop.m

leftEdgeXData = left * ones(1, height);
leftEdgeYData = top:bottom;

upperEdgeXData = left:right;
upperEdgeYData = top * ones(1, width);

rightEdgeXData = right * ones(1, height);
rightEdgeYData = leftEdgeYData;

lowerEdgeXData = upperEdgeXData;
lowerEdgeYData = bottom * ones(1, width);

xData = [leftEdgeXData upperEdgeXData rightEdgeXData lowerEdgeXData];
yData = [leftEdgeYData upperEdgeYData rightEdgeYData lowerEdgeYData];

f = imgUtil_getParentFig(imgAxes);
line(...
    'color', get(f, 'color'),...
    'lineWidth', 2,...
    'parent', imgAxes,...
    'xData', xData,...
    'yData', yData...
    );