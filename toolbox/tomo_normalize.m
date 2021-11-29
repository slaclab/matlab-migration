function [tn, pn, r, x ,y, B] = tomo_normalize(xval, yval, profs, yvalf, k0)
%TOMO_NORMALIZE
%  TOMO_NORMALIZE(XVAL,YVAL,PROFS,YVALF,K0)
%  Normalize phase space.
%
% Features:

% Input arguments:
%    XVAL:  x coordinates of reconstruction domain
%    YVAL:  y coordinates of reconstruction domain
%    PROFS: Array of M measured profiles [N M] with N points in each
%    YVALF: Coordinates of measured profiles, assumed to be on y axis of
%           phase space
%    K0:    Transport matrices [2 2 M]. Profiles assumed to be obtained
%           along 2nd axis, so if measured along 1st axis, provide
%           K0([2 1],:,:) instead
%
% Output arguments:
%    TN: 
%    PN: 
%    R:  Normalized transport matrices
%    X:  Normalized x coordinates of reconstruction domain
%    Y:  Normalized y coordinates of reconstruction domain
%    B:  Normalization matrix

% Compatibility: Version 7 and higher
% Called functions: util_moments, beamAnalysis_sigmaFit, model_sigma2Twiss

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check optional parameters.
if iscell(k0), m0=k0{1};else m0=k0;end

% Determine Twiss.
nP=size(profs,2);
bSize=zeros(nP,1);
for j=1:nP
    [a,b,bSize(j)]=util_moments(yvalf,profs(:,j));
end
m0=m0([2 1],:,:);
sigma=beamAnalysis_sigmaFit([],m0,bSize);
twiss=model_sigma2Twiss(sigma);
% Compute B matrix times root emit to get dimensionless phase space.
B=[twiss(2) 0;-twiss(3) 1]/sqrt(twiss(2))*sqrt(twiss(1));
Bi=inv(B);
B2=repmat(B,[1 1 nP]);
r=m0*0;tn=repmat(yvalf(:)',nP,1)*0;pn=tn';
for j=1:nP
    t2=model_twissTrans(twiss,m0(:,:,j));
    B2(:,:,j)=[t2(2) 0;-t2(3) 1]/sqrt(t2(2))*sqrt(t2(1));
    B2i=inv(B2(:,:,j));
    tn(j,:)=B2i(1)*yvalf(:)';
    pn(:,j)=profs(:,j)/B2i(1);
    r(:,:,j)=B2i*m0(:,:,j)*B;
end

ext=[min(xval) max(xval) max(xval) min(xval);min(yval) min(yval) max(yval) max(yval)];
extn=Bi*ext;
x=linspace(min(extn(1,:)),max(extn(1,:)),numel(xval));
y=linspace(min(extn(2,:)),max(extn(2,:)),numel(yval))';
x=linspace(-5,5,numel(xval));
y=linspace(-5,5,numel(yval))';

r={r([2 1],:,:) []};
