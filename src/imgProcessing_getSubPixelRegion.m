function [xsub, ysub] = imgProcessing_getSubPixelRegion(img, roi)
% The returned coordinates may be used directly to extract a subregion from
% the specified image.
% roi = [xmin ymin width height] in Spatial Coordinates
% see Coordinate Systems in Matlab help
xsub = [];
ysub = [];
if nargin < 2
    return;
end

[imgHeight, imgWidth] = size(img);

% Taken from imcrop.m, pixelWidth == pixelHeight == 1
col1 = roi(1);
row1 = roi(2);
pixelWidth = roi(3);
pixelHeight = roi(4);

%Use row1, col1 before rounding etc.
row2 = min(imgHeight, round(row1 + pixelHeight));
col2 = min(imgWidth, round(col1 + pixelWidth));
row1 = max(1, round(row1));
col1 = max(1, round(col1));

xsub = col1:col2;
ysub = row1:row2;
