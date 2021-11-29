function [yfit,q] = erf_fit(x,y)   

%	[yfit,q,dq,chisq_ndf] = erf_fit(x,y);
%
%	Non-linear fitting routine to fit a gaussian "bell" curve
%	to the data in vectors "x" and "y", where "x" contains the
%	independent variable data and "y" contains the dependent data.
%	The fit form is as follows:
%
%    	  yfit =  q(1) + q(2)*erf( (x-q(3))/q(4) )
%
%	When "y_off" = 0 then q(1) is returned as exactly zero.
%
%    INPUTS:	x:	A vector (row or column) of independent variable
%			data.
%		y:	A vector (row or column) of dependent data.
%
%    OUTPUTS:	
%     yfit: A vector of fitted bell curve data from which the
%			difference to the original data "y" has been
%			minimized.
%		q:	A vector of the 4 scalars which are fitted:
%			q(1) => DC offset in the gaussian data (if "y_off"=0
%				then q(1) = 0).
%			q(2) => Amplitude scaling factor of gaussian curve.
%			q(3) => Horizontal offset (X0).     
%        q(4) => Standard deviation of the gaussian.
%
% Special note for wire scanner groupies:
%              / X
% if Y = A + B*| gauss(x,x0,sigma) dx
%        x=-inf/
% then
%       q(4) = 1.414 * sigma         sigma = q(4) *.707
%       q(3) = x0
%       q(2) = B/2                       B = q(2) * 2
%       q(1) = A + B/2                   A = q(1) - q(2)

% keith jobe, 5/95
%===============================================================================
if length(y) < 5
  error('Need at least 5 data points to fit a gaussian')
end

x = x(:);
y = y(:);

arg1(:,1) = x;
arg1(:,2) = y;

% sort data to find the pedistal (the 5% population level)
% and the peak.  Use this data to identify data points 
% 1/e above pedistal

[tmp,indx]=sort(y);
npnts=length(y);
ymin=y(indx(round(npnts*0.05+1)));  % the 5% point
ymax=y(indx(round(npnts*0.95)));    % the 98% point
delta=ymax-ymin;
 
% Using prior ymin,ymax, find indicies for y>ymin + 1/e (ymax-ymin)

th=find(y > (ymin+.2*delta) & y < (ymax - .2*delta));

q(3)=mean(x(th));

q(4)=2.8*std(x(th));
p = q(3:4);

[p,opt] = fmins('erf_min',p,[0 0.0001],[],arg1,q);
A  = [ones(size(x)) erf((x-p(1))/p(2))];
c  = A\y;
z  = A*c;

q=[c(:); p(:)]';
yfit=z;
