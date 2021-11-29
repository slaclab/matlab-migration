function fwhm = fwhmGeneric(x,y, hAxis)
% return the full width half maximum from an assumed peak-like distribution
% in x, y. 
%
% hAxis is optional handle to axis for plotting. If present it will label
% the plot.

% Sort points by increase x values
[x, IX] = sort(x);
y = y(IX);

% Remove non-distinct points
bad = (diff(y)==0);
y(bad) = '';
x(bad) = '';
bad = (diff(x)==0);
y(bad) = '';
x(bad) = '';

% Find half max
ymin = min(y);
ymax = max(y);
hmY = 0.5*(ymax - ymin);
peakInd = find(y==ymax);

% Return if there is no fwhm
if (y(1)>ymin+hmY) || (y(end)>ymin+hmY)
    fwhm = NaN;
    return
end

% Find index of points just above half max
yGreaterInd = find(y>ymin+hmY);
lowerInd = yGreaterInd(1);
upperInd = yGreaterInd(end);

% Interpolate the half maxima
try
    xL = interp1(y([lowerInd, lowerInd-1]),x([lowerInd, lowerInd-1]),ymin+hmY);
    xH = interp1(y([upperInd, upperInd+1]),x([upperInd, upperInd+1]),ymin+hmY);
    fwhm = xH-xL;
catch
    fwhm = NaN;
    return
end


% optional plot result
cA = gca;
if nargin==3
    if ishandle(hAxis)
        yRange = max(y)-min(y);
        axes(hAxis);
        text( mean(x), (ymin+0.1*yRange),...
            ['FWHM ' num2str(fwhm,4) ],...
        'HorizontalAlignment','center');
        axes(cA);
    else % bad call
        display('Bad third input argument --- need axis handle');
        return
    end
end
