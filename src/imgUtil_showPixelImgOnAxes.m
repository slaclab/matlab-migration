function imgUtil_showPixelImgOnAxes(img, imgAxes, xOffset, yOffset)

if nargin < 3
    xOffset = [];
end
if nargin < 4
    yOffset = [];
end

if isempty(img)
    return;
end 

if isempty(xOffset) 
    xOffset = 0;
end

if isempty(yOffset) 
    yOffset = 0;
end

imgHandle = image('parent', imgAxes);

isRgb = isequal(3, size(img, 3));
if isRgb
    [imgHeight, imgWidth, c] = size(img);
else
    [imgHeight, imgWidth] = size(img);
end
   

%See under "Coordinate Systems" in Matlab help, e.g
% imgHeight=3, imgWidth=6, offset.x = 3, offset.y = 3
% 
% (3, 3)            (9, 9)
% ----------------------
% 4 | 5 | 6 | 7 | 8 | 9| Center of pixel 9 => (8.5, 8.5)
% ---------------------|
% 5 |                  |
% ---------------------|
% 6 |                  |
% ---------------------|

xLim(1) = round(xOffset);
yLim(1) = round(yOffset);
%keep aspect ratio
imgAxesPos = get(imgAxes, 'position');
imgAxesWidth = imgAxesPos(3);
imgAxesHeight = imgAxesPos(4);

if strcmpi(get(imgAxes, 'units'), 'normalized')
    figPos = get(imgUtil_getParentFig(imgAxes), 'position');
    imgAxesWidth = imgAxesWidth * figPos(3);
    imgAxesHeight = imgAxesHeight * figPos(4);
end

imgAspectRatio = imgWidth/imgHeight;
axesAspectRatio = imgAxesWidth/imgAxesHeight;
if imgAspectRatio > axesAspectRatio
    xLim(2) = round(xOffset + imgWidth);
    yLim(2) = round(yOffset + imgHeight * imgAspectRatio/axesAspectRatio);
else
    xLim(2) = round(xOffset + imgWidth * axesAspectRatio/imgAspectRatio);
    yLim(2) = round(yOffset + imgHeight);
end

set(imgAxes, 'xLimMode', 'manual', 'XLim', xLim);
set(imgAxes, 'yLimMode', 'manual', 'YLim', yLim);

%center of the pixel
xData(1) = xOffset + 0.5;
xData(2) = xData(1) + imgWidth - 1;
yData(1) = yOffset + 0.5;
yData(2) = yData(1) + imgHeight - 1;
set(imgHandle, 'CData', img, 'XData', xData, 'YData', yData);
