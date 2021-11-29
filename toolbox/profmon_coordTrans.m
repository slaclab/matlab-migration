function pos = profmon_coordTrans(pos, data, units)
%PROFMON_COORDTRANS
%  POS = PROFMON_COORDTRANS(POS, DATA, UNITS) converts position coordinates
%  in data struct POS to different units based on profmon image metadata in
%  DATA.  POS has fields X, Y, UNITS, and ISRAW determining coordinates and
%  processing level.

% Features:

% Input arguments:
%    POS:   Struct with coordinates info
%           X:     Array of horizontal position of points
%           Y:     Array of vertical position of points
%           UNITS: Units represented in coordinates, pixel, mm, or um
%           ISRAW: Flag indicating if coordinates are based on raw image
%    DATA:  Structure as returned from profmon_grab()
%    UNITS: Desired output units for POS

% Output arguments:
%    POS: Structure with same fields as input

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 3, units='um';end
units=lower(units);
if ~isfield(pos,'units') && strcmp(units,'pixel'), pos.units='um';end
if ~isfield(pos,'units'), pos.units='pixel';end
if ~isfield(pos,'isRaw'), pos.isRaw=data.isRaw;end
pos.units=lower(pos.units);
if pos.isRaw ~= data.isRaw, pos=flip(pos,data);end
if ~all(data.res), data.res(:)=1;end

% mm -> um
if strcmp(pos.units,'mm')
    pos.x=pos.x/1e-3;
    pos.y=pos.y/1e-3;
    pos.units='um';
end

% um or mm -> pixel
if strcmp(pos.units,'um') && strcmp(units,'pixel')
    pos.y=-pos.y;
    pos.x=data.centerX+pos.x/data.res(1);
    pos.y=data.centerY+pos.y/data.res(end);
    pos.units='pixel';
end

% pixel -> um or mm
if strcmp(pos.units,'pixel') && ismember(units,{'um' 'mm'})
    pos.x=(pos.x-data.centerX)*data.res(1);
    pos.y=(pos.y-data.centerY)*data.res(end);
    pos.y=-pos.y;
    pos.units='um';
end

% mm -> um
if strcmp(pos.units,'um') && strcmp(units,'mm')
    pos.x=pos.x*1e-3;
    pos.y=pos.y*1e-3;
    pos.units='mm';
end


function pos = flip(pos, data)

if ~strcmp(pos.units,'pixel')
    data.nCol=-1;data.nRow=-1;
end
if isfield(data,'isRot') && data.isRot
    [pos.x,pos.y]=deal(pos.y,pos.x);
    if ~strcmp(pos.units,'pixel')
        pos.x=-pos.x;pos.y=-pos.y;
    end
end
if data.orientX
    pos.x=data.nCol+1-pos.x;
end
if data.orientY
    pos.y=data.nRow+1-pos.y;
end
pos.isRaw=~pos.isRaw;
