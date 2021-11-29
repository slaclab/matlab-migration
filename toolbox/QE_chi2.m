function [sse,Fittedcurve] = QE_chi2(Rsigtry,p1,E0,Lphase,xdata,ydata,rscl,Qobs,Qscl)

sse = 0.;
epsln0 = 8.854187817620391e-12;

Qscl(E0,epsln0,Lphase,Rsigtry)*1E9/p1;
nn = length(xdata);
rsclF = zeros(nn,1);
Fittedcurve = zeros(nn,1);
ErrorVector = zeros(nn,1);
for ia=1:nn
  rsclF(ia) = rscl(E0,xdata(ia)*p1*1E-9,epsln0,Lphase,Rsigtry );
  Fittedcurve(ia) = Qobs(p1*xdata(ia)*1E-9,rsclF(ia),Rsigtry )*1E9;
  ErrorVector(ia) = (Fittedcurve(ia) - ydata(ia))/(0.10*ydata(ia));
  sse = sse + ErrorVector (ia)^2;
end
return
