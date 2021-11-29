function par = gaussCalc(x,y,hAxis)
%
% par = gaussCalc(x,y,hAxis)
%
% returns the parameters of the gaussian fit to the x,y distribution. 
 % par:  fitted parameters [AMP, XM, SIG]
%         Y=AMP EXP(-(X-XM)^2/2/SIG^2)
%
% If hAxis is given (optional) it will plot the fitted curve and put the
% fit parameters on the axis as well.
%
% This is a a reduced version of util_gaussFit.m which has much more
% capability

x = x(:); y=y(:);
[par, yfit, bg] = util_gaussFit(x,y,1);
amplitude = par(1);
center  = par(2);
sigma = par(3);
bg = par(4);
area = amplitude*sqrt(2*pi)*sigma;

% optional plot result

if nargin==3
    if ishandle(hAxis)
                F = get(hAxis,'Parent'); % figure of target axis
        set(F,'CurrentAxes',hAxis); % makes hAxes current without drawing focus
        yRange = max(y)-min(y);
        xRange = max(x)-min(x);
        line( x, yfit, 'Color',[1,0,0])
        text( min(x)+.05*xRange, max(yfit), ['Amp  ' num2str(amplitude)],...
            'HorizontalAlignment','left');
        text(  min(x)+.05*xRange, max(yfit)-.05*yRange, ['Center  ' num2str(center)],...
            'HorizontalAlignment','left');
        text(  min(x)+.05*xRange, max(yfit)-0.1*yRange, ['Sigma  ' num2str(sigma)],...
            'HorizontalAlignment','left');
        text(  min(x)+.05*xRange, max(yfit)-0.15*yRange, ['Offset  ' num2str(bg)],...
            'HorizontalAlignment','left');
        text(  min(x)+.05*xRange, max(yfit)-0.20*yRange, ['Area  ' num2str(area)],...
            'HorizontalAlignment','left');
    else % bad call
        display('Bad third input argument --- need axis handle');
        return
    end
end
