function [FW,i1,i2] = FWHM(X,NX,f,NXbase);

%	[FW,i1,i2] = FWHM(X,NX[,f,NXbase]);
%
%	Function to calculate Full-Width at Half-Maximum of the binned data in X,NX
%	(see "hist" for generation of "X" and "NX" from a distribution).
%
%	INPUTS:		X:		Vector of horizontal binned data (see "hist") to
%						calculate FWHM
%				NX:		Vector of vertical binned data (see "hist") to
%						calculate FWHM
%				f:		(Optional,DEF=1/2) Scalar used to calculate
%						Full-Width at this fraction of maximum (e.g. FWQM
%						when f = 1/4) [0 < f < 1]
%				NXbase:	(Optional,DEF=0) The baseline of NX
%
%	OUTPUTS:	FW:		The full width at "f" (DEF=1/2) of maximum height.
%				i1:		Pointer to located leading rise of distribution
%						(at NX ~ f*Nmax)
%				i2:		Pointer to located trailing rise of distribution
%						(at NX ~ f*Nmax)
%
%=================================================================================

if ~exist('f')
  f = 0.5;
else
  if (f<=0) | (f>=1)
    error('"f" should be: 0 < f < 1')
  end
end

if ~exist('NXbase')
  NXbase = 0;
end

Nbin = length(X);
if Nbin < 2
  error('Need at least 2 bins in array "X" and "NX"')
end

i1 = 1;
i2 = Nbin;
ok1 = 0;
ok2 = 0;
[Nmax,imax] = max(NX);
%for j = 1:Nbin
%  if (NX(j)-NXbase) >= f*(Nmax-NXbase)
%    i1 = j;
%    ok1 = 1;
%    break
%  end
%end
for j = imax:(-1):1
  if (NX(j)-NXbase) < f*(Nmax-NXbase)
    i1 = j;
    ok1 = 1;
    break
  end
end

%for j = Nbin:(-1):1
%  if (NX(j)-NXbase) >= f*(Nmax-NXbase)
%    i2 = j;
%    ok2 = 1;
%    break
%  end
%end
for j = imax:Nbin
  if (NX(j)-NXbase) < f*(Nmax-NXbase)
    i2 = j;
    ok2 = 1;
    break
  end
end

if ok1*ok2 == 0
  disp(' ')
  disp('WARN: ==> FWHM not found')
  disp(' ')
end
if i1 >= i2
  disp(' ')
  disp('WARN: ==> FWHM not found')
  disp(' ')
end
FW = abs(X(i2) - X(i1));