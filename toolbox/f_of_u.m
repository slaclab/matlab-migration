        function [f,df] = f_of_u(u,T,func_str)

%       [f,df] = f_of_u(u,T[,func_str])
%
%       Returns the coefficients ("f") and their errors ("df") from the
%       original fitted coefficients ("u") to the independently measured
%       coordinates (see "eigfit.m" and/or "fit.m")
%
%     INPUTS:   u:              The vector for which "f" is a function of.
%               T:              The covariance matrix from "fit" or "eigfit"
%               func_str:       (Optional) Prompted if not present.
%                               Vector of text which analytically describes
%                               the desired scalar function "f" as a function
%                               of the elemnts of the vector "u".  Example:
%
%                               func_str = '(-u(3)-u(2)+u(1))/u(4)';
%
%                               It must be written this way (with parenthesis
%                               and 'u' for the vector).
%

%===============================================================================

n = length(u);

bad_func = 1;
while bad_func
  if ~exist('func_str')
    fprintf('u has %1.0f elements',n)
    func_str = input('Function of u''s {e.g. u(1)/u(2)}: ','s');
  end
 
  f = eval(func_str);
  if isempty(f)
    disp2('*** The function string could not be evaluated, try again. ***')
    clear func_str
  else
    bad_func = 0;
  end
end

grad_f = grad(func_str,u);              % numerically find gradient of f

df = sqrt(grad_f' * T * grad_f);        % errors of functional coefficients
