function xEdge = edgeCalc(x,y,hAxis)
% xEdge = edgeCalc(x,y, axisHandle)
%
% For a distribution y(x), return the "edge" defined as the smallest interpolated
% value xedge such that y(xedge) = is halfway between the min and max of y.
% Generally this is the lower edge for normally shaped distribution
%
% axisHandles is an optional handle to a plot axis. If present, this
% function will add the edge to the plot.

%
%  GeVMidSlope = kmGeVMidSlope(x, y)
%
% Find midpoint of rising edge of scan, return midpoint energy [GeV]
% Returns mean(x) if a solution cannot be found
%
% Expects y to be more or less monotonically increasing as a function of 
% corrected energy points.
% 

% Check input
x = x(:); y=y(:);
if  (length(y)<3) ||...
    (length(x)<3) ||...
    (length(y) ~= length(x) ) ||...
    any( any(diff([ x])==0) )  %     any( any(diff([x y])==0) )
    xEdge = 0; % no solution found
    return
end

% Remove non-distinct points
bad = (diff(y)==0);
y(bad) = '';
x(bad) = '';
bad = (diff(x)==0);
y(bad) = '';
x(bad) = '';

% Sort points by increasing x values
[x, IX] = sort(x);
y = y(IX);

% Find half max
ymin = min(y);
ymax = max(y);
hmY = 0.5*(ymax + ymin);

% Find index of point just above half max
yGreaterInd = find(y>hmY);
lowerInd = yGreaterInd(1);

% Interpolate the half maxima
try
    xEdge = interp1(y([lowerInd, lowerInd-1]),x([lowerInd, lowerInd-1]),hmY);

catch
    xEdge = mean(x); 
    display('Interpolation failed. Returning mean x value')
    return
end

        
% optional plot result
if nargin==3
    if ishandle(hAxis)
        F = get(hAxis,'Parent'); % figure of target axis, maybe
        try
            set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        catch % look one level higher for Figure
            F = get(F,'Parent'); % figure of target axis, hopefully
            set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        end
        yRange = max(y)-min(y);
        line( xEdge*[1,1], [(min(y) +.3*yRange), (max(y)-0.3*yRange)],...
            'LineStyle', '-', 'Color', [1 0 0 ]);
        text( xEdge, (max(y)-0.5*yRange), ['Edge  ' num2str(xEdge) ' '],...
            'HorizontalAlignment','right');
    else % bad call
        display('Bad third input argument --- need axis handle');
        return
    end
end