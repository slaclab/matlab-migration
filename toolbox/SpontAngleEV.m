function [] = SpontAngleEV(varargin)
% For a charge making one pass through an undulator, this function produces
% contour plots of the spontaneous energy (joules per solid angle and
% photon energy) emitted in a range of harmonics versus the angle theta
% from the z axis and the photon energy, at an angle phi to the x axis
% specified by the user.
% There are several optional arguments:
%   phiDeg    = angle to x axis (deg), default = 0
%   harmonic  = range of harmonics to compute (start:stop)
%   polarized = x,y polarized = 1,     default = 1
%   GeV       = beam energy (GeV),     default = 13.64
%   charge    = charge in bunch (pC),  default = 250
%   KUnd      = K value of undulator,  default = 3.5
%   lambdaUnd = undulator period (mm), default = 30
%   NUnd      = number of periods,     default = 3729

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant / (2*pi)

p=inputParser;
p.addOptional('phiDeg',0)
p.addOptional('harmonic',[1 1])
p.addOptional('polarized',1)
p.addOptional('GeV',13.64)
p.addOptional('charge',250)
p.addOptional('KUnd',3.5)
p.addOptional('lambdaUnd',30)
p.addOptional('NUnd',113*33)
p.parse(varargin{:})

phiDeg      = p.Results.phiDeg;
phi         = phiDeg*pi/180;
harmonic(1) = min(max(p.Results.harmonic(1),1),          30);
harmonic(2) = min(max(p.Results.harmonic(2),harmonic(1)),30);
polarized   = p.Results.polarized ~= 0;
GeV         = p.Results.GeV;
charge      = p.Results.charge*1e-12;
KUnd        = p.Results.KUnd;
lambdaUnd   = p.Results.lambdaUnd*0.001;
NUnd        = p.Results.NUnd;


% Check optional inputs. If zero, set to defaults. Convert all to MKS.
if KUnd <= 0 || KUnd > 20
    KUnd = 3.5;
end
KUndStar = KUnd/sqrt(1+0.5*KUnd^2);

if GeV <= 0
    GeV = 13.64;
end
gamma = GeV*1e9*qe/(me*c^2);
gammaStar = gamma/sqrt(1+0.5*KUnd^2);

if charge <= 0 || charge > 1e-7
    charge = 250e-12;
end

if lambdaUnd <= 0 || lambdaUnd > 1
    lambdaUnd = 0.03;
end
kUnd=2*pi/lambdaUnd;

if NUnd <= 0 || NUnd > 1e5
    NUnd = 113*33;
end

close all
NHarm    = harmonic(2)-harmonic(1)+1;
NTerms   = 20;
NAngle   = 400;
maxAngle = 2.2/gammaStar;
NeV      = max(400,round(100*sqrt(NHarm)));
eV1axis  = 2*hbar*c*kUnd*gammaStar^2/qe;
eVmax    = (1+2/NUnd+0.01)*eV1axis*harmonic(2);
eVmin    = (1-2/NUnd-0.01)*eV1axis*harmonic(1)/(1+(gammaStar*maxAngle)^2);
if eVmin < 0.1*eVmax
    eVmin = 0;
end
deV      = (eVmax-eVmin)/NeV;
eV       = eVmin + (0:NeV)*deV;
dtheta   = maxAngle/NAngle;
theta    = (0:NAngle)*dtheta;
SDist    = zeros(NAngle+1,NeV+1);
PDist    = zeros(NAngle+1,NeV+1);

for m = 1:NAngle+1
    gammatheta = 1+(gammaStar*theta(m))^2;
    aUnd = 0.25*KUndStar^2/gammatheta;
    bUnd = 2*KUndStar*gammaStar*theta(m)*cos(phi)/gammatheta;
    cUnd = (1+0.5*KUnd^2)^-2*KUndStar^-2*gammatheta^-3;
    eV1  = eV1axis/gammatheta;
    for harm = harmonic(1):harmonic(2)
        % Array of besselj(k,harm*aUnd), for k=-NTerms:NTerms.
        % Negative k values use besselj(-k,z)=besselj(k,z)*(-1)^k
        % Length of array is 2*NTerms+1. Offset to k=0 is Nterms+1.
        bessa((NTerms+1):(2*NTerms+1))...
            = real(besselj(0:NTerms,harm*aUnd));
        for k = 1:NTerms
            bessa(k) = bessa(2*NTerms+2-k)*(-1)^(NTerms+1-k);
        end
        % Array of besselj(k,harm*bUnd), for
        % k=-(2*NTerms+harm+1):(2*NTerms+harm+1).
        % Negative k values use besselj(-k,z)=besselj(k,z)*(-1)^k
        % Array length is 2*(2*NTerms+harm+1)+1.
        % Offset to k=0 is 2*NTerms+harm+2.
        bessb((2*NTerms+harm+2):(4*NTerms+2*harm+3))...
            = real(besselj(0:(2*NTerms+harm+1),harm*bUnd));
        for k = 1:(2*NTerms+1+harm)
            bessb(k) = bessb(4*NTerms+2*harm+4-k)*(-1)^(harm-k);
        end
        % Compute Bessel sums
        bess1 = real(bessa *  bessb((2*harm+2):2:(2*(2*NTerms+harm)+2))');
        bess2 = real(bessa * (bessb((2*harm+3):2:(2*(2*NTerms+harm)+3))...
                       + bessb((2*harm+1):2:(2*(2*NTerms+harm)+1)))');
        FS = cUnd*harm^2*real(2*bess1*gammaStar*theta(m)*cos(phi)...
                              - bess2*KUndStar)^2;
        FP = cUnd*harm^2*real(2*bess1*gammaStar*theta(m)*sin(phi))^2;
        % Photon energy of peak at this angle and harmonic
        j = min(NeV,max(0,round((harm*eV1-eVmin)/deV)))+1;
        SDist(m,j) = FS/eV1;
        PDist(m,j) = FP/eV1;
        if j > 1
            SDist(m,j-1) = SDist(m,j);
            PDist(m,j-1) = PDist(m,j);
        end
        if j <= NeV
            SDist(m,j+1) = SDist(m,j);
            PDist(m,j+1) = PDist(m,j);
        end
    end
end

TDist  = SDist+PDist;
scale  = 1/max(max(TDist));
SDist  = SDist*scale;
PDist  = PDist*scale;
figure
FigWidth  = 1260;
FigHeight = 630;
border    = 80;
colorBarWidth = 70;

if harmonic(2) > harmonic(1)
    FigHarm = ['Harmonics ',num2str(harmonic(1)),...
        ' to ',num2str(harmonic(2))];
else
    FigHarm = ['Harmonic ',num2str(harmonic(1))];
end    

if polarized  % Plot x and y polarizations
    % Figure position = [left, bottom, width, height]
    set(gcf,'Position',[0,100,FigWidth,FigHeight])

    subplot(1,2,1)
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
    colormap jet
    contour(1e6*theta,1e-3*eV,SDist',64)
    colorbar
    title(['Horizontal (\sigma) Polarization at \phi = ',num2str(phiDeg),...
        '\circ, ',FigHarm])
    xlabel('\theta (\murad)')
    ylabel('Photon Energy (keV)')

    subplot(1,2,2)
    set(gca,'Units','pixels','Position',...
        [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
    contour(1e6*theta,1e-3*eV,PDist',64)
    title(['Vertical (\pi) Polarization at \phi = ',num2str(phiDeg),...
        '\circ, ',FigHarm])
    xlabel('\theta (\murad)')
    ylabel('Photon Energy (keV)')
else  % Plot sum of x and y polarization only
    FigWidth = FigWidth/2;
    set(gcf,'Position',[0,100,FigWidth+colorBarWidth,FigHeight])
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth-2*border+colorBarWidth,FigHeight-2*border])
    colormap jet
    contour(1e6*theta,1e-3*eV,TDist',64)
    colorbar
    title(['Unpolarized Emission at \phi = ',num2str(phiDeg),...
        '\circ, ',FigHarm])
    xlabel('\theta (\murad)')
    ylabel('Photon Energy (keV)')
end
end
