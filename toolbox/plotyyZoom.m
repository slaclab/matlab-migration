function [axout,h1,h2]=plotyyZoom(varargin)
[axout,h1,h2]=plotyy(varargin{:});

set(axout, 'YLimMode', 'auto');
set(axout, 'YTickMode', 'auto');
set(axout, 'XLim', [1 size(varargin{2},2)]);
set(gcf, 'Resizefcn','');


