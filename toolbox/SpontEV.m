function EHarm = SpontEV(varargin)
% For a charge making one pass through an undulator, this function produces
% plots of the spontaneous energy (joules per solid angle and per photon
% energy) emitted in a range of harmonics versus the photon energy, at
% user-specified angles theta to the z axis and phi to the x axis
% (spherical coordinates).
% There are several optional arguments:
%   theta     = angle to z axis (urad), default = 0
%   phiDeg    = angle to x axis (deg),  default = 0
%   harmonic  = range of harmonics to compute (start:stop)
%   polarized = x,y polarized = 1,      default = 1
%   GeV       = beam energy (GeV),      default = 13.64
%   charge    = charge in bunch (pC),   default = 250
%   KUnd      = K value of undulator,   default = 3.5
%   lambdaUnd = undulator period (mm),  default = 30
%   NUnd      = number of periods,      default = 3729

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant / (2*pi)

p=inputParser;
p.addOptional('theta',0)
p.addOptional('phiDeg',0)
p.addOptional('harmonic',[1 1])
p.addOptional('polarized',1)
p.addOptional('GeV',13.64)
p.addOptional('charge',250)
p.addOptional('KUnd',3.5)
p.addOptional('lambdaUnd',30)
p.addOptional('NUnd',113*33)
p.parse(varargin{:})

theta       = min(max(p.Results.theta*1e-6, 0),          0.005);
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
NHarm      = harmonic(2)-harmonic(1)+1;
NTerms     = 20;
NeV        = min(10000,round(1000*NHarm));
gammatheta = 1+(gammaStar*theta)^2;
eV1        = 2*hbar*c*kUnd*gammaStar^2/(qe*gammatheta);
if harmonic(2) > harmonic(1)
    NeV1  = ceil(NeV/harmonic(2));
    deV   = eV1/NeV1;
    NeV   = NeV1*harmonic(2)+ceil((2/NUnd+0.01)*eV1/deV)+10;
    eVmax = NeV*deV;
    eVmin = 0;
else
    eVmax = (1+2/NUnd+0.01)*eV1*harmonic(2);
    eVmin = (1-2/NUnd-0.01)*eV1*harmonic(1);
    deV   = (eVmax - eVmin)/NeV;
end
eV    = eVmin + (0:NeV)*deV;
SDist = zeros(NeV+1,1);
PDist = zeros(NeV+1,1);

aUnd = 0.25*KUndStar^2/gammatheta;
bUnd = 2*KUndStar*gammaStar*theta*cos(phi)/gammatheta;
cUnd = (1+0.5*KUnd^2)^-2*KUndStar^-2*gammatheta^-3;
EUnd = charge*qe*NUnd*kUnd*(gamma*gammaStar*KUnd)^2/(2*pi*eps0);
jmid = round((eV1*(harmonic(1):harmonic(2))-eVmin)/deV)+1;
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
    FS = harm^2*real(2*bess1*gammaStar*theta*cos(phi)...
                          - bess2*KUndStar)^2;
    FP = harm^2*real(2*bess1*gammaStar*theta*sin(phi))^2;
    % Photon energy of peak at this angle and harmonic
    jdif = round(eV1*20/(NUnd*deV));
    j1 = max(jmid(harm-harmonic(1)+1)-jdif,1);
    j2 = min(jmid(harm-harmonic(1)+1)+jdif,NeV+1);
    for j=j1:j2
        sincarg = (eV(j)-harm*eV1)*pi*NUnd/eV1;
        if sincarg ~= 0
            sinc2 = (sin(sincarg)/sincarg)^2;
        else
            sinc2 = 1;
        end
        SDist(j) = SDist(j) + FS*sinc2;
        PDist(j) = PDist(j) + FP*sinc2;
    end
end

SDist = SDist*cUnd*EUnd*NUnd/eV1;
PDist = PDist*cUnd*EUnd*NUnd/eV1;
EHarm(3,:) = PDist(jmid);
EHarm(2,:) = SDist(jmid);
EHarm(1,:) = EHarm(2,:) + EHarm(3,:);

figure
FigWidth  = 1260;
FigHeight = 630;
border    = 80;
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
        [border,border,FigWidth/2-2*border,FigHeight-2*border])
    plot(eV*1e-3,SDist)
    axs = [eVmin*1e-3, eVmax*1e-3, 0, 1.01*max(max(SDist),max(PDist))];
    axis(axs)
    title(['Horizontal (\sigma) Polarization at ',...
        '\theta = ',num2str(theta*1e6),' \murad, ',...
        '\phi = '  ,num2str(phiDeg),   '\circ, ',FigHarm])
    xlabel('Photon Energy (keV)')
    ylabel('Energy per Solid Angle per eV (J/(rad^2eV))')

    subplot(1,2,2)
    set(gca,'Units','pixels','Position',...
        [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
    plot(eV*1e-3,PDist)
    axis(axs)
    title(['Vertical (\pi) Polarization at ',...
        '\theta = ',num2str(theta*1e6),' \murad, ',...
        '\phi = '  ,num2str(phiDeg),   '\circ, ',FigHarm])
    xlabel('Photon Energy (keV)')
    ylabel('Energy per Solid Angle per eV (J/(rad^2eV))')
else  % Plot sum of x and y polarization only
    FigWidth = FigWidth/2;
    set(gcf,'Position',[0,100,FigWidth,FigHeight])
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth-2*border,FigHeight-2*border])
    plot(eV*1e-3,SDist+PDist)
    title(['Unpolarized Emission at ',...
        '\theta = ',num2str(theta*1e6),' \murad, ',...
        '\phi = '  ,num2str(phiDeg),   '\circ, ',FigHarm])
    xlabel('Photon Energy (keV)')
    ylabel('Energy per Solid Angle per eV (J/(rad^2eV))')
end
end
