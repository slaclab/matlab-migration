function iimgProcessing_annotation_showSlice(imgAxes, sliceParam, lineWidth)
%Frames the specified slice with white color
if sliceParam.total == 1
    return;
end

% x plane
% x1, y1        --------------------------------------  x2, y1
%               |                                    |
%               |                                    |
% x1, startCoord|------------------------------------|  x2, startCoord
%               |                                    |
% x1, endCoord  |                                    |  x2, endCoord
%               |------------------------------------|
%               |                                    |
%               |                                    |
% x1, y1        --------------------------------------  x2,y2
%
%
% y plane
% x1, y1        startCoord, y1    endCoord, y1        x2, y1
% -----------------------------------------------------------
% |                   |               |                     |
% |                   |               |                     |
% |                   |               |                     |
% -----------------------------------------------------------
% x1, y2        startCoord, y2     endCoord, y2        x2, y2

f = imgUtil_getParentFig(imgAxes);
frame = line(...
    'color', get(f, 'color'),...
    'lineWidth', lineWidth,...
    'parent', imgAxes...
    );

xLim = get(imgAxes, 'xLim');
yLim = get(imgAxes, 'yLim');
%See under "Coordinate Systems" in Matlab help
isSlicePlaneX = strcmpi(sliceParam.plane, 'x');

width = round(xLim(2) - xLim(1)) + 1;
height = round(yLim(2) - yLim(1)) + 1;
if isSlicePlaneX
    %incl.
    [startIndex, endIndex] = imgUtil_getArraySliceBounds(height, sliceParam.index, sliceParam.total);
    startCoord = startIndex + yLim(1) - 1;
    endCoord = endIndex + yLim(1);
    sliceSize = round(endCoord - startCoord) + 1;

    leftEdgeXData = xLim(1)* ones(1, sliceSize);
    leftEdgeYData = startCoord:endCoord;

    upperEdgeXData = xLim(1):xLim(2);
    upperEdgeYData = startCoord * ones(1, width);

    rightEdgeXData = xLim(2)* ones(1, sliceSize);
    rightEdgeYData = leftEdgeYData;

    lowerEdgeXData = upperEdgeXData;
    lowerEdgeYData = endCoord * ones(1, width);
else
    width = round(xLim(2) - xLim(1));
    %incl.
    [startIndex, endIndex] = imgUtil_getArraySliceBounds(width, sliceParam.index, sliceParam.total);
    startCoord = startIndex + xLim(1) - 1;
    endCoord = endIndex + xLim(1);    
    sliceSize = round(endCoord - startCoord) + 1;

    leftEdgeXData = startCoord* ones(1, height);
    leftEdgeYData = yLim(1):yLim(2);

    upperEdgeXData = startCoord:endCoord;
    upperEdgeYData = yLim(1) * ones(1, sliceSize);

    rightEdgeXData = endCoord * ones(1, height);
    rightEdgeYData = leftEdgeYData;

    lowerEdgeXData = upperEdgeXData;
    lowerEdgeYData = yLim(2) * ones(1, sliceSize);
end

xData = [leftEdgeXData upperEdgeXData rightEdgeXData lowerEdgeXData];
yData = [leftEdgeYData upperEdgeYData rightEdgeYData lowerEdgeYData];

set(frame, 'XData', xData, 'yData', yData);