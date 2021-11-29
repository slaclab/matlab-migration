function axDest = util_copyAxes(ax, axDest)
%UTIL_COPYAXES
% AXDEST = UTIL_COPYAXES(AX, AXDEST) Copies the content of AX to AXDEST
% including labels and title.  AXDEST defaults to GCA.

% Features:

% Input arguments:
%    AX:     Axes object to copy from
%    AXDEST: Destination axes

% Output arguments:
%    AXDEST: Destination axes, might be new object if not given as input

% Compatibility: Version 7 and higher
% Called functions: 

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
if nargin < 2, axDest=gca;end

set(axDest,'box','on');
copyobj(get(ax,'Children'),axDest);
tag={'XLabel' 'YLabel' 'Title'};
h=copyobj(cell2mat(get(ax,tag)),axDest);
set(axDest,tag,num2cell(h'));
tag={'XLim' 'YLim'};
set(axDest,tag,get(ax,tag));
