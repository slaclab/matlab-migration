function [coeffs, fitresult] = err_fit_data(ydata,xdata,varargin)
% function err_fit_data
%
% Jim Turner (initially from code by Matt Gibbs) 10-11-2010
% for fitting an error function (from a knife edge scan) and giving back sigma
% input:
%        ydata = integral of bin (intensity for example)
%        xdata = bin designator (collimator position for example)
%        varargin = estimates for seeding your fit (only use if the fit
%                   breaks - see fminsearch)
% output:
%        for the function: A/2.*erf(sqrt(2)*(Input - x0)/B) + y0
%        coeffs(1) = A
%        coeffs(2) = B       sigma = coeff(2) / 2
%        coeffs(3) = x0
%        coeffs(4) = y0
%        
%        fitresult = fitted curve the length of xdata
%
  if size(varargin)~=4
    Estimates = [1, 1, 0, 0];
  else
    Estimates = [varargin{1},varargin{2},varargin{3},varargin{4}];
  end
  options = optimset('Display','final','TolX',1e-7,'TolFun',1e-7,'MaxFunEvals',1000);
  coeffs = fminsearch(@erffit,Estimates,options,xdata,ydata);
  fitresult = coeffs(1)/2 * (erf(sqrt(2).*(xdata - coeffs(3))/coeffs(2)))+coeffs(4);

  function sse = erffit(params,Input,Actual_Output)
  A = params(1);
  B = params(2);
  x0 = params(3);
  y0 = params(4);
  Fitted_Curve = A/2.*erf(sqrt(2)*(Input - x0)/B) + y0;
  Error_Vector = Fitted_Curve - Actual_Output;
  sse = sum(Error_Vector.^2);
