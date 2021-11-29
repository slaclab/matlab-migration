function plot_ellipse(X,no_grid,mrk)

%       plot_ellipse(X[,no_grid,mrk])
%
%	Plots the ellipse described by the 2X2 symmetric matrix "X".
%
%    INPUTS:	X:	        A 2X2 symmetric matrix which describes
%                               the ellipse follows:
%
%			            [x y]*X*[x y]' = 1,
%				    	  	or, with X = [a b]
%                                                            [b c],
%			              2     	  2		
%			            ax + 2bxy + cy  = 1
%               no_grid:        (Optional,DEF=1) no_grid=0: a grid is plotted
%                                                no_grid=1: no grid is plotted
%               mrk:            (Optional,DEF='b-') Plot symbol (see plot)

%===============================================================================

[r,c] = size(X);
if r~=2 | c~=2
  error('X must be 2X2 matrix')
end
if abs(X(1,2)) > 10*eps
  if abs(X(1,2)-X(2,1)) > (abs(.001*X(1,2)) + eps)
    error('X must be a symmetric matrix')
  end
else
  if abs(X(2,1)) > 10*eps
    error('X must be a symmetric matrix')
  end
end

if ~exist('no_grid')
  no_grid = 1;
end

if ~exist('mrk')
  mrk = 'b-';
end

a = X(1,1);
b = X(1,2);
c = X(2,2);

theta = 0:0.01:pi;
C = cos(theta);
S = sin(theta);

r = sqrt( (a*(C.^2) + 2*b*(C.*S) + c*(S.^2)).^(-1) );
r = [r r];
C = [C -C];
S = [S -S];

x = r.*C;
y = r.*S;

plot(x,y,mrk)
if no_grid==0
  hor_line(0)
  ver_line(0)
end
