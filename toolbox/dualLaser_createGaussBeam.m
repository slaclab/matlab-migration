function [ideal, sigma] = dualLaser_createGaussBeam(handles, varargin)

%	createBeam generates a Gaussian beam cut by an iris. Taken from ZerinkeTest.m 
%The optional arguments are:
%   order	Number n of Zernike orders (pyramid rows) used
%                                                       Default = 8
%   dIdeal  Diameter (mm to exp(-2)) of the ideal Gaussian beam,
%           before cutting by the iris                  Default = 2
%   dHole   Diameter (um) of the pinhole of an optional spatial filter
%           (set to 0 if not used)                      Default = 150
%	dIris   Diameter (mm) of the iris                   Default = 2
%   focus   Focal length (mm) of the pair of lenses     Default = 1000
%   lambda  Wavelength (nm) of the laser light          Default = 253
%
%   The laser diameter follows the usual convention for intensity:
%       Electric field:	exp(-(r/omega)^2)
%       Intensity:      exp(-2*(r/omega)^2) = exp(-8*(r/width)^2)
%
%   The optional spatial filter has two lenses of equal focal length
%   "focus", separated by 2*focus, with a pinhole at the midpoint.
%   After the spatial filter, the beam is cut by a second iris of the same
%   size in order to remove diffraction rings from the filter.
%
%   The calculations are then normalized to the iris radius.
%
%	The input  "Laser" must be a double-precision square matrix
%	containing a circular image that fills the square (diameter equal to
%   the side of the square). Load the image with imread, and then extract
%   the circle from the larger rectangular image by calling CircularImage.

p=inputParser;

p.addOptional('dIdeal',0.3)   % Diameter (mm, to exp(-2)) of ideal beam
p.addOptional('dIris',1.2)   % Diameter (mm) of iris
p.addOptional('nPix', 109) %(pixels)
p.addOptional('mode', 'polar');
p.addOptional('fwhm', 1); %(pixels)
p.parse(varargin{:})

rIris  = p.Results.dIris*0.5e-3;        % Iris radius (m)
dIdeal = p.Results.dIdeal*1e-3;         % Diameter of ideal beam (m)
nPix   = p.Results.nPix; 
mode   = p.Results.mode;
fw     = p.Results.fwhm;

sigma  = dIdeal/(4*rIris);              % ideal beam sigma, scaled to rIris
[x,y] = meshgrid(linspace(-1,1,nPix));

filteredImg = util_medFilt(handles.data.img);
A=double(max(filteredImg(:)));
%polar coordinates
if strcmp(mode, 'polar')
    x = x(:);
    y = y(:);
    [~,r] = cart2pol(x,y);
    inside = r<=1;
    
    % Define the ideal beam
    ideal = zeros(nPix);
    ideal(inside) = exp(-0.5*(r(inside)/sigma).^2);
else
    x0 = handles.x*1e-3; %mm
    y0 = handles.y*1e-3; %mm
%     sigx= 0.8493218*fw;
%     sigy=sigx;
%
sigx = handles.xrms*1e-3*1.84; %mm
sigy = handles.yrms*1e-3*1.84; %mm


%     x0=0;y0=0; sigx=1;sigy=1;
%      x=x-x0;y=y-y0;
[~,r] = cart2pol(x,y);
[~,rsig] = cart2pol(sigx,sigy);

inside = r<=1;
    % Define the ideal beam
    ideal = zeros(nPix);
    ideal(inside) = A*exp(-0.5*(r(inside)/(rsig)).^2);
    
end


% Like the Zernickes, normalize for an integral of 1 over the unit circle.
% ideal = ideal/(sqrt(sum(sum(ideal.^2)))*2/nPix);


