function data = profmon_imgFlip(data, getRaw)
%PROFMON_IMGFLIP
%  DATA = PROFMON_IMGFLIP(DATA) flips or rotates the image, ROI offset and
%  screen center depending on the camera orientation and rotation. The
%  ISRAW status is toggled.

% Features: Use to toggle between raw image data and camera orientation
% corrected data.

% Input arguments:
%    DATA: Structure of image data from camera PV
%    GETRAW: Flippes only to return raw image

% Output arguments:
%    DATA: Modified structure

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check GETRAW flag.
if nargin < 2, getRaw=0;end
if getRaw && data.isRaw, return, end

% Change ISRAW status.
data.isRaw=~data.isRaw;

% Rotate if DATA.ORIENTX equals -1.
if isfield(data,'isRot') && data.isRot
    data.img=permute(data.img,[2 1 3:ndims(data.img)]);
    [data.nCol,data.roiX,data.roiXN,data.orientX,data.centerX, ...
     data.nRow,data.roiY,data.roiYN,data.orientY,data.centerY]=deal( ...
     data.nRow,data.roiY,data.roiYN,data.orientY,data.centerY, ...
     data.nCol,data.roiX,data.roiXN,data.orientX,data.centerX);
    data.res=fliplr(data.res);
end

% Flip horizontal if DATA.ORIENTX equals 1.
if data.orientX
    data.img=flipdim(data.img,2);
    data.roiX=data.nCol-data.roiXN-data.roiX;
    data.centerX=data.nCol+1-data.centerX;
end

% Flip vertical if DATA.ORIENTY equals 1.
if data.orientY
    data.img=flipdim(data.img,1);
    data.roiY=data.nRow-data.roiYN-data.roiY;
    data.centerY=data.nRow+1-data.centerY;
end
