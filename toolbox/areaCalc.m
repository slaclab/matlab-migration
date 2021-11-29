function area = areaCalc(x,y,hAxis)
%
% area = areaCalc(x,y,hAxis)
%
% returns the area under the curve of the supplied x,y distribution. 
%
% If hAxis is given (optional) it will write the area on the supplied axis.
%

x = x(:); y=y(:);

% sort in increasing x
[x, iX] = sort(x);
y = y(iX);

% Calculate the area
area = trapz(x, y);

% optional plot result
if nargin==3
    if ishandle(hAxis)
        F = get(hAxis,'Parent'); % figure of target axis
        set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        yRange = max(y)-min(y);
        xRange = max(x)-min(x);
        text( min(x)+0.5*xRange, (max(y)-0.45*yRange), ['Area  ' num2str(area)],...
            'HorizontalAlignment','center');
    else % bad call
        display('Bad third input argument --- need axis handle');
        return
    end
end
