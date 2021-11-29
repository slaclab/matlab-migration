function [fit, coefs, E] = LinearPredictor(y,x)
%function [fit, coefs, E] = LinearPredictor(y,x)
% returns:
%   fit,    the best fit prediction of y from the x's in the vector [1 x]
%   coefs,  the coefficients which best predict vector y from the x's
%   E,      the "design matrix"
% Then the fit to y(x) is given by fit=coefs*E
%27Jan09 fixed to fit complex y vector 
%(doesn't work for complex x)
%
y=y(:);
[rows, cols] = size(x);
if cols ~= length(y) x=x'; end

E=[ones(size(y)) x'];
coefs = E\y;
coefs=coefs.';
E=E';
fit=coefs*E;