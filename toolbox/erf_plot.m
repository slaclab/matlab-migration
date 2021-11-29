
function [yf,p] = erf_plot(x,y,dy,y_off)

%	gauss_plot(x,y[,dy,y_off])
%
%	Fits and plots gaussian curve data vectors "x" and "y" with optional
%	error bars "dy".  Fit results are summarized on the plot.  The fit
%	form is:
%	
%		
%
%    INPUTS:	x:	The independent variable data vector (column or row)
%		y:	The dependent variable data vector (column or row)
%		dy:	(Optional,DEF=not used) The data vector of error bars
%			on the dependent variable data (column or row).     
%		y_off:  (Optional,DEF=1) If "y_off" .NE. 0, then the gaussian
%			fit includes a "y" offset parameter in the fit.
%			If "y_off" = 0, this forces the fit to include no
%			"y" offset and therefore q(1) is set exactly to zero.
%
%    OUTPUTS:	(none - screen plot & fit results summary)

%===============================================================================

path(path,'/home/physics/decker/matlab/matlab_slcmar2008')
path(path,'/home/physics/decker/matlab/matlab_slcmar2008/toolbox_slc')

x = x(:);
y = y(:);
nx = length(x);
ny = length(y);
if nx ~= ny
  error('X and Y data vectors must be the same length')
end

if ~exist('y_off')
  y_off = 1;
end

minx = min(x);
maxx = max(x);
widx = maxx - minx;
stpx = widx/100;
xx = minx:stpx:maxx;
xx = xx(:);

if ~exist('dy')
  [yf,p] = erf_fit(x,y);  %,chisq
  yyf = p(1)*ones(size(xx)) + p(2)*erf((xx-p(3))/p(4));   %0.4*sqrt(2*pi)
  plot(x,y,'o',xx,yyf,'-')
else
  dy = dy(:);
  ndy = length(dy);
  if ndy == 1
    dy = dy*ones(size(x));
    ndy = length(dy);
  end
  if ndy ~= nx
    error('dY error data vector must be the same length as X and Y')
  end
  [yf,p] = erf_fit(x,y,dy,y_off);
  yyf = p(1)*ones(size(xx)) + p(2)*erf((xx-p(3))/p(4)); 
  plot(x,y,'o',xx,yyf,'-')
  hold on
  plot_bars(x,y,dy,'o')
  hold off
end

title('A + B*erf( (X-C)/D )')

%text(0.00,0.058,sprintf('A = %g',p(1)),'sc')
%text(0.00,0.034,sprintf('B = %g',p(2)),'sc')
%text(0.25,0.058,sprintf('C = %g',p(3)),'sc')
%text(0.25,0.034,sprintf('D = %g',p(4)),'sc') 
%text(0.50,0.058,sprintf('T = %g',p(5)),'sc')


%text(0.70,0.034,sprintf('CHISQ/NDF = %8.3g',chisq),'sc')

%title('A+B*(pi/2/(F^2-1))^.5*erf(Y,F*Y); Y=(X-D)/C/(2*(F^2-1))^.5')

%[xc,yc]=text_locator(6,-3,'T');
%text(xc,yc,sprintf('Fitted Y Cap-Sigma = %6.3g',p(4)))
%[xc,yc]=text_locator(6,-4,'T');
%text(xc,yc,sprintf('Fitted X Cap-Sigma = %6.3g',p(5)))
[xc,yc]=text_locator(3,-2,'T');
text(xc,yc,sprintf('A = %6.0f',p(1)),'fontsize',14)
[xc,yc]=text_locator(3,-3.5,'T');
text(xc,yc,sprintf('B = %6.0f',p(2)),'fontsize',14)
[xc,yc]=text_locator(3,-5,'T');
text(xc,yc,sprintf('C = %6.3f',p(3)),'fontsize',14)
[xc,yc]=text_locator(3,-6.5,'T');
text(xc,yc,sprintf('D = %6.3f',p(4)),'fontsize',14)
%[xc,yc]=text_locator(3,-6,'T');
%text(xc,yc,sprintf('CHISQ/NDF = %8.3g',chisq))
%sigy = p(4);

