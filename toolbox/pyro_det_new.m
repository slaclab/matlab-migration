function ret = pyro_det_new(k, dli, dcr, dau)
%PYRO_DET_NEW
%  [EFF] = PYRO_DET_NEW(K, DLI, DCR, DAU) calculates the absorbance of a
%  pyroelectric detector element consisting of a LiTaO3 crystal of
%  thickness DLI (defaults to 375 um) and Cr (DCR) and Au (DAU) layers of
%  10 and 700 nm  thickness. They are sorted from front to back as [Cr
%  LiTaO3 Cr Au]. The wavenumber K must be given in 1/cm and the
%  thicknesses in cm.

if nargin < 2, dli=375e-6*100;end
if nargin < 3, dcr=20e-9*100;end
if nargin < 4, dau=700e-9*100;end
if dli == 0, ret=k*0+1;return, end

k=k(:);
%plasmacr=121101.;gammacr=3189.31+0.666693e-3/dcr;
nli=n_index(k,'LiTaO3');
ncr=n_index(k,'Cr',dcr);
nau=n_index(k,'Au',dau);

rt=layer(k,[ncr nli ncr nau],[dcr dli dcr dau]);

ret=1-sum(abs(rt).^2,2);
