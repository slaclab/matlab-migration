function [peakLocation, peakValue]  = peakCalc(x,y,hAxis)
%
% [peakLocation, peakValue]  = peakCalc(x,y,hAxis)
%
% returns the peak value and coordinate of the x,y distribution. No
% interpolation is done. 
%
% hAxis is the optional handle to a plot axis. If present, peakCalc
% will Plot  the peak on the plot on hAxis. 
%


x = x(:); y=y(:);
peakValue = max(y);
peakLocations = x(y==peakValue);
peakLocation = peakLocations(1); % if multiple identical peaks

% optional plot result
if nargin==3
    if ishandle(hAxis)
        F = get(hAxis,'Parent'); % figure of target axis
        set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        yRange = max(y)-min(y);
        text ( peakLocation, peakValue,'\color{red}+',...
            'HorizontalAlignment','center',...
            'VerticalAlignment','middle');
        text( peakLocation, (peakValue+0.02*yRange),...
            ['Peak ' num2str(peakValue,4) ' @ ' num2str(peakLocation,5) ],...
            'HorizontalAlignment','center');
        %axes(cA)
    else % bad call
        display('Bad third input argument --- need axis handle');
        return
    end
end
