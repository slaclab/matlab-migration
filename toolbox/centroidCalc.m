function centroid = centroidCalc(x,y,hAxis)
%
% centroid = centroidCalc(x,y,hAxis)
%
% returns the centroid of the distribution. That is the point on the x axis
% where the distribution y would balance.
%
% hAxis is the optional handle to a plot axis. If present, centroidCalc
% will Plot  the centroid on the plot on hAxis. 
%
% y should be non-negative for the centroid to make sense.

x = x(:); y=y(:);
centroid = sum(y.*x)/sum(y);

% optional plot result

if nargin==3
    if ishandle(hAxis)
        F = get(hAxis,'Parent'); % figure of target axis
        set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        yRange = max(y)-min(y);
        line(  centroid*[1,1], [(min(y) +.2*yRange), (max(y)-0.2*yRange)],...
            'LineStyle', '-', 'Color', [1 0 0 ]  );
        text( centroid, (max(y)-0.15*yRange), ['Centroid  ' num2str(centroid)],...
            'HorizontalAlignment','center');
    else % bad call
        display('Bad third input argument --- need axis handle');
        return
    end
end
