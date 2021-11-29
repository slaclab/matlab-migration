function [x,y] = scanSmooth(xplot, yplot,smoothingFactor)
%
% [x,y] = scanSmooth(xplot, yplot,smoothingFactor)
%
% return smoothed points suitable for plotting noisy distributions
% smoothFactor determines size of convolution window. smooth Factor = 5
% means the window size is 5% of the range of xplot data. If omitted 10% is
% assumed

% sort the points in case they are disordered
[xplot, IX] = sort(xplot);
yplot = yplot(IX);

% Apply median filter which de-emphasizes outliers
yplot = medfilt1(yplot,3);

% Set default smoothing factor
if nargin==2 || (abs(smoothingFactor) > 50)
    smoothingFactor = 5;
end
if smoothingFactor == 0
    x = xplot; y = yplot;
    return
end
smoothingFactor = abs(smoothingFactor);

% % set filtering resolution and return points
rangeX = max(xplot) - min(xplot);
resolution = 0.01*smoothingFactor*rangeX; 
span = ceil( resolution/ ...
    ( (max(xplot) - min(xplot) ) /length(xplot) )...
    );% number of data points to smooth over
if ~(span < 2*length(xplot)); % span is too small
    span = 1;
end
if (span > 0.5*length(xplot) )
    span = floor(0.5*length(xplot));
end
window = ones(span,1)/span;
y = conv(yplot, window);
x = conv(xplot, window);

% delete edge points
x(1:span) = '';
y(1:span) = '';
x(end-span:end)='';
y(end-span:end)='';
