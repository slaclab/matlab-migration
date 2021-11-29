function [xout,yout] = util_scanSmooth(xplot, yplot,smoothingFactor) 
% % [xout,yout] = scanSmooth(xplot, yplot,smoothingFactor) 
% % return smoothed points suitable for plotting noisy distributions 
% smoothFactor determines size of convolution window. smooth Factor = 5 
% means the window size is 5% of the range of xplot data. If omitted 5% is 
% assumed
% Author: Jim Welch, SLAC

% sort the points in case they are disordered 
yout=[];
for j=1:size(yplot,1)
    yp=yplot(j,:);
    if (j==1)
        [xplot, IX] = sort(xplot); %sort list first time
    end
    
    yp = yp(IX);


    if nargin==2 || (abs(smoothingFactor) > 50)
        smoothingFactor = 5;
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
    y = conv(yp, window);
    x = conv(xplot, window);

    % delete edge points
    x(1:span) = '';
    y(1:span) = '';
    x(end-span:end)='';
    y(end-span:end)='';
    xout=x;
    yout=[yout; y];
end