function fwhm = fwhmGeneral(x,y, hAxis,fraction)
% 
%  fwhm = fwhmGeneral(x,y, hAxis,fraction)
%
% return the full width at an arbitrary fraction of maximum of y from an
% assumed peak-like distribution in x, y. If such full width doesn't exist
% the function simply returns without labeling anything.
%
% Either or both hAxis and fraction can omitted. Their order in the
% function call is also not important. hAxis is an optional handle to an
% axis for plotting. If present it will label the plot. Fraction is the
% fraction of the maximum of ymax-ymin at which to determine the full
% width. If faction is omitted, 0.5 is assumed (half maximum).

% Figure out if fraction is specificed
if nargin == 4
    if ~ishandle(hAxis) % interchange inputs if in wrong order
        temp = fraction;
        fraction = hAxis;
        hAxis = temp;
    end
end
if nargin == 3 % third input is either handle or fraction
    if ~ishandle(hAxis)
        fraction = hAxis;
    else
        fraction = 0.5; % default
    end

end
if nargin == 2
    fraction = 0.5;
end

% Sort points by increasing x values
[x, IX] = sort(x);
y = y(IX);

% Remove non-distinct points
bad = (diff(y)==0);
y(bad) = '';
x(bad) = '';
bad = (diff(x)==0);
y(bad) = '';
x(bad) = '';

% Remove NaN
bad = isnan(y);
y(bad) = '';
x(bad) = '';

% Find half max
ymin = min(y);
ymax = max(y);
hmY = fraction*(ymax - ymin);

% Return if there is no fwhm
if isempty(y)
    fwhm = NaN;
    return
end
if (y(1)>ymin+hmY) || (y(end)>ymin+hmY)
    fwhm = NaN;
    return
end

% Find index of points just above half max
try
    yGreaterInd = find(y>ymin+hmY);
    lowerInd = yGreaterInd(1);
    upperInd = yGreaterInd(end);

    % Interpolate the half maxima
    xL = interp1(y([lowerInd, lowerInd-1]),x([lowerInd, lowerInd-1]),ymin+hmY);
    xH = interp1(y([upperInd, upperInd+1]),x([upperInd, upperInd+1]),ymin+hmY);
    fwhm = xH-xL;
catch
    fwhm = NaN;
    return
end

% optional plot result
if nargin>=3
    if ishandle(hAxis)
        yRange = max(y)-min(y);
        xRange = max(x)-min(x);
        F = get(hAxis,'Parent'); % figure of target axis
        set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        if fraction == 0.5
            fwLabel = ['FWHM ' num2str(fwhm,4) ];
        else
            fwLabel = ['FW@' num2str(fraction,2) ' Max ' num2str(fwhm,4) ];
        end
        text( (mean(x)+0.15*xRange), (ymin+0.6*yRange),...
            fwLabel,...
        'HorizontalAlignment','center');
    else % bad call
        %display('Bad third input argument --- need axis handle');
        return
    end
end
