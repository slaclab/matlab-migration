function data = profmon_imgCrop(data, pos)
%PROFMON_IMGCROP
%  PROFMON_IMGCROP(DATA, POS) Crops the image in data to the area specified
%  in POS as [X1 X2 Y2 Y2]. The endpoints are included. Alternatively, the
%  crop area may be specified as a structure with fields POS.X=[X1 X2] and
%  POS.Y=[Y1 Y2] and units in POS.UNITS. The coordinates are in pixels or
%  POS.UNITS and relative to the full, not to a previously cropped image.

% Features:

% Input arguments:
%    DATA: Image data structure as returned from profmon_grab or related
%          functions

% Output arguments:
%    DATA: Data structure containing cropped image and updated position
%          fields

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if ~isstruct(pos), pos=struct('x',pos(1:2),'y',pos(3:4),'units','pixel');end
pos=profmon_coordTrans(pos,data,'pixel');
pos.x=round(sort(pos.x));pos.y=round(sort(pos.y));
bin=[data.roiYN data.roiXN]./size(data.img);
x=ceil((pos.x-data.roiX)/bin(2));y=ceil((pos.y-data.roiY)./bin(1));
data.img=data.img(max(1,y(1)):min(y(2),end),max(1,x(1)):min(x(2),end));
data.roiX=pos.x(1)-1;
data.roiY=pos.y(1)-1;
data.roiXN=diff(pos.x)+1;
data.roiYN=diff(pos.y)+1;
if isfield(data,'back') && numel(data.back) > 1
    data.back=data.back(max(1,y(1)):min(y(2),end),max(1,x(1)):min(x(2),end));
end
