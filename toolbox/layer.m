function rtr = layer(k, n, d, theta, varargin)
%LAYER
%  [RT] = LAYER(K, N, D, THETA) calculates the complex reflexion and
%  transmission coefficients for a layered structure of materials. The
%  wavenumber K is the inverse wavelength. N is an array of refractive
%  indices [I,J] with wavenumber index I and material index J. D is a vector
%  containing the layer thicknesses. K and D must have the same length unit.
%  The layered structure is assumed to be surrounded by vacuum on both
%  sides and can contain any number of layers, even zero. The return value
%  RT is an array with two columns for reflexion and transmission. If THETA
%  is provided, p- and s-polarization are calculated for an incident angle
%  of theta given in radians. RT then has a third index for the two
%  polarizations.

k=k(:);d=d(:)';
if size(n,1) ~= length(k), n=n.';end
if nargin < 4, theta=0;end
if nargin < 5
    theta=sin(theta);
    n=[k*0+1 n k*0+1];
    d=[0,d,0];
end

n0=n(:,1);
n1=n(:,2);
thetap=theta.*n0./n1;
cosa=sqrt(1-theta.^2);
cosb=sqrt(1-thetap.^2);
z0=[1./n0.*cosa 1./n0./cosa];
z1=[1./n1.*cosb 1./n1./cosb];

rt=cat(3,(z0-z1)./(z0+z1),2*z1./(z0+z1));
rt=permute(rt,[1 3 2]);

if sum(theta) == 0, rt=rt(:,:,1);end
if size(n,2) == 2, rtr=rt;return, end

ph=exp(2*pi*abs(k).*d(2).*complex(0,1).*n1.*cosb);
rtm=layer(k,n(:,2:end),d(2:end),thetap,1);
rtr=multlayer(rt(:,:,1),rtm(:,:,1),ph);
if sum(theta) ~= 0, rtr=cat(3,rtr, ...
    multlayer(rt(:,:,2),rtm(:,:,2),ph));end


function rt = multlayer(rt1, rt2, ph)

denom=(1+rt1(:,1).*rt2(:,1).*ph.^2);
rt=[(rt1(:,1)+rt2(:,1).*ph.^2)./denom rt1(:,2).*rt2(:,2).*ph./denom];
