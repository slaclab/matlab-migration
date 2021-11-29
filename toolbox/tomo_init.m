function [frho,iphi,phi,B,xval,yval] = tomo_init(xval0,yval0,profs,yvalf,k0,dk0,l0,type,varargin)
%TOMO_INIT
%  TOMO_INIT(XVAL,YVAL,PROFS,YVALF,K0,DK0,L0,TYPE,...)
%  Interface for various tomographic reconstruction methods. Also rescales
%  profiles and reconstruction domain (still required ... ?).
%
% Features:

% Input arguments:
%    XVAL0: x coordinates of reconstruction domain
%    YVAL0: y coordinates of reconstruction domain
%    PROFS: Array of M measured profiles [N M] with N points in each
%    YVALF: Coordinates of measured profiles, assumed to be on y axis of
%           phase space
%    K0:    Transport matrices [2 2 M]. Profiles assumed to be obtained
%           along 2nd axis, so if measured along 1st axis, provide
%           K0([2 1],:,:) instead
%    DK0:   Obsolete, use []
%    L0:    Obsolete, use []
%    TYPE:  Reconstruction method, can be 'sart', 'sart_sp', 'sart_spn',
%           'cbrt', or 'ment'. Default is 'sart_sp'.
%
% Output arguments:
%    FRHO: Reconstructed density function
%    IPHI: Obsolete
%    PHI:  Obsolete
%    B:    Normalization matrix
%    XVAL: Normalized x coordinates of reconstruction domain
%    YVAL: Normalized y coordinates of reconstruction domain
%
% The reconstruction in the unnormalized coordinates can be obtained by
% F = TOMO_TRANSPHASESPACE(XVAL, YVAL, FRHO, B, XVAL0, YVAL0)

% Compatibility: Version 7 and higher
% Called functions: tomo_normalize, tomo_'TYPE', tomo_sart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check optional parameters.
if nargin < 8, type='sart_sp';end
B=eye(2);

%Normalize phase space.
[yvalf,profs,k0,xval,yval,B]=tomo_normalize(xval0,yval0,profs,yvalf,k0);

% Make everything dimensionless with DX and DY scaled to unity.
dx=xval(2)-xval(1);dy=yval(2)-yval(1);dx=1;dy=1;
x=xval/dx;y=yval/dy;yf=yvalf/dy;profs=profs*dy;
if iscell(k0), [m0,t0]=deal(k0{:});else [m0,t0]=get_m(l0,k0,dk0);end
m=cat(2,m0(:,1,:)*dx,m0(:,2,:)*dy);m=cat(1,m(1,:,:)/dx,m(2,:,:)/dy);

% Find pseudo rotation angle and sort by this angle.
k=m(2,1,:);lk=m(2,2,:);l=m(2,1,:);
[phi,iphi]=sort(atan2(k(:),lk(:)));
disp(sprintf('Range of rotation: %3.0f Degrees',(max(phi)-min(phi))*180/pi));
disp(sprintf('Range of k: %3.1f %3.1f',min(k),max(k)));
disp(sprintf('Range of l: %3.1f %3.1f',min(l),max(l)));
disp(sprintf('Range of 1+l*k: %3.1f %3.1f',min(lk),max(lk)));
profs=profs(:,iphi);m=m(:,:,iphi);t=t0;
if size(yf,1) == size(m,3), yf=yf(iphi,:);end
if ~isempty(t0)
    t=cat(2,t0(:,1,iphi)*dx^2,t0(:,2,iphi)*dy^2);t=cat(1,t(1,:,:)/dx,t(2,:,:)/dy);
end

switch type
    case {'cbrt' 'ment'}
        frho=feval(['tomo_' type],x,y,profs,yf,m,t,varargin{:});
    otherwise
        w=feval(['tomo_' type],x,y,yf,m,t);
        frho=tomo_sart(x,y,profs,w,varargin{:});
end
frho=frho/dx/dy;
