function [coefs, psym, pasym, ptot] = beamAnalysis_Zernike(Laser,varargin)

Laser=cropImage(Laser);   
p=inputParser;
p.addOptional('order', 19) 	% Maximum order n of Zernike corrections
p.addOptional('dIdeal',2)   % Diameter (mm, to exp(-2)) of ideal beam
p.addOptional('dHole', 0) % Pinhole diameter (um)
p.addOptional('dIris', 2)   % Diameter (mm) of iris
p.addOptional('focus', 250) % Focal length (mm) of lens pair
p.addOptional('lambda',253) % Wavelength (nm)
p.addOptional('reconstruction', 0) %This flag determines if we compute/print the reconstructed image
p.addOptional('printResults', 0)  %This flag determines if we print the coeffcients and power
p.parse(varargin{:})

order  = p.Results.order;
rIris  = p.Results.dIris*0.5e-3;        % Iris radius (m)
recon  = p.Results.reconstruction;
printResults = p.Results.printResults;

NPix = size(Laser,1);
if size(Laser,2) ~= NPix
    disp('Input matrix must be square.')
    return
end

% List all points inside the circle in polar coordinates.
[x,y] = meshgrid(linspace(-1,1,NPix));
x = x(:);
y = y(:);
[theta,r] = cart2pol(x,y); 
inside = r<=1;

% There are m Zernike polynomials of order n:
%	m = [-n, -n+2, -n+4, ... n-4, n-2, n]
% There are (N+1)*(N+2)/2 Zernike polynomials from orders 0 through N.
% The orders (n,m) of all the polymonials up to order "order" are listed
% in two column vectors, N and M.
N = zeros(1,(order+1)*(order+2)/2);
M = N;
j = 0;
for k = 0:order
    N(j+(1:k+1)) = k*ones(1,k+1);
    M(j+(1:k+1)) = -k:2:k;
    j = j+k+1;
end
% We normalize each polynomial so that its integral over the unit circle
% is equal to 1. Correct this normalization for pixelation error.
Z = ZernFun(N,M,r(inside),theta(inside),'norm');
%disp('Normalization of Zernikes before fix for pixelation')
%disp(sum(Z.^2)*(2/NPix)^2)
Z = Z./repmat(sqrt(sum(Z.^2))*2/NPix,length(r(inside)),1);

Laser(~inside) = 0;

% Find the vector of Zernike coefficients for the (filtered) laser.
% Like the Zernickes, normalize for an integral of 1 over the unit circle.
Laser = Laser/(sqrt(sum(sum(Laser.^2)))*2/NPix);
laser = Z\Laser(inside);
coefs=laser;

if printResults
    disp('[mode # Coefficients^2 for output beam]')
    list=round(1:length(laser));
    disp([list' laser.^2]);
    disp('Sum of power in all modes used.')
    disp(sum(sum(Z.^2).*laser'.^2)*(2/NPix)^2)
    disp('Total # of modes')
    disp(length(laser))
end


% For each Zernike order n, we use all the coefficients up to n to plot the
% reconstructed ideal beam, the reconstructed real beam, and the real beam
% which is corrected up to order n.
if recon
  % Plot the ideal beam and the real beam.

close all  

figure 
B = zeros(NPix);
for n = 0:order
    coef = (n+1)*(n+2)/2;
   
    B(inside) = Z(:,1:coef)*laser(1:coef);
    imagesc([-1 1]*rIris*1e3,[-1 1]*rIris*1e3,B)

    axis image
    title(['Laser:  Components to Zernike Order ',num2str(n)])
    xlabel('X Coordinate on Iris (mm)')
    ylabel('Y Coordinate on Iris (mm)')
    pause(0.5)
end
end

sym =coefs(5) + coefs(13) + coefs(25) + coefs(41) + coefs(61) + coefs(85) + coefs(113) + coefs(145)+ coefs(181);
asym=coefs;
center=[1, 5,13,25,41,61,85,113, 145,181];
asym(center)=0;
psym=sum(sym);
pasym=sum(asym);
ptot=sum(coefs);





function [imgC] = cropImage(img)
%function crops the image
img=sqrt(double(img));

b=max(img(:))/4;
im2=min(img,b);
px=sum(im2,1);   
py=sum(im2,2)';

c=max(px)/3;
usex=find(px > max(px)/3);
zx=length(usex);
par=polyfit(usex,px(usex).^2,2);
x0=-par(2)/par(1)/2;
dx=sqrt((par(2)/par(1))^2-4*par(3)/par(1));
usey=find(py > max(py)/3);
zy=length(usey);
par=polyfit(usey,py(usey).^2,2);
y0=-par(2)/par(1)/2;
dy=sqrt((par(2)/par(1))^2-4*par(3)/par(1));
c=round([x0 y0]);
d=round(mean([dx dy]));
usex=round(x0+(-d/2:d/2));
usey=round(y0+(-d/2:d/2));

%perform checks
maxx=max(usex);
maxy=max(usey);
[sx,sy]=size(img);

ch1=zeros(2,length(usex));
ch1=[usex<0 usey<0];
ch2=[maxx>sx maxy>sy];
check=sum(ch1(:))+sum(ch2(:));


if check > 0
    c_norm=zeros(1,nCoeff);
    imgC=zeros(size(img));
    imgZ=zeros(size(img));
    resp=zeros(1,4);
    
else


imgC=double(img(usey,usex));
end 