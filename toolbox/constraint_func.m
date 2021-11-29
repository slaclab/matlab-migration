function chisq = constraint_func(x,xmin,xmax,n)

%	chisq = constraint_func(x,xmin,xmax[,n]);
%
%	Function to add fairly hard, but smooth constraint on a parameter for use in 'fmins', etc.
%	The variable "x" is constrained to approximately "xmin >= x >= xmax".
%
%    INPUTS:	x:	The variable you want to constrain
%		xmin:	The approximate minimum value allowed
%		xmax:	The approximate maximum value allowed
%		n:	(Optional,DEF=5) The sensitivity exponent/2
%			(>5 harder edge constraint; must have n > 0)
%    OUTPUTS:	chisq:	The penalty function (<~ 1)

%==================================================================================================

%if ~exist('n')
%  n = 5;
%end
%if n < 1
%  error('Must have n >= 1')
%end
%if xmin >= xmax
%  error('Must have xmin < xmax')
%end

hw    = (xmax - xmin)/2;
x0    = xmin + hw;
chisq = ((x - x0)./hw).^5;
