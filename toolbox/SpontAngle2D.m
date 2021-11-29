function [EHarm] = SpontAngle2D(varargin)
% For a charge making one pass through an undulator, this function plots
% the distributions of spontaneous energy (joules per solid angle) emitted
% in a range of harmonics, versus the angle theta from the z axis, at an
% angle phi to the x axis specified by the user. It also outputs the energy
% per solid angle emitted on axis in each of these harmonics.
% There are several optional arguments:
%   phiDeg       = angle to x axis (deg), default = 0
%   harmonic     = range of harmonics to compute, default = [1 1]
%   polarized    = x,y polarized = 1,             default = 1
%   GeV          = beam energy (GeV),             default = 13.64
%   charge       = charge in bunch (pC),          default = 250
%   KUnd         = K value of undulator,          default = 3.5
%   lambdaUnd    = undulator period (mm),         default = 30
%   NUnd         = number of periods,             default = 3729

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant /(2*pi)

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
NHarm       = harmonic(2)-harmonic(1)+1;
polarized   = p.Results.polarized ~= 0;
GeV         = p.Results.GeV;
charge      = p.Results.charge*1e-12;
KUnd        = p.Results.KUnd;
lambdaUnd   = p.Results.lambdaUnd*0.001;
NUnd        = p.Results.NUnd;

% Check optional inputs.
if KUnd <= 0 || KUnd > 20
    KUnd = 3.5;
end
KUndStar = KUnd/sqrt(1+0.5*KUnd^2);

if GeV <= 0
    GeV = 13.64;
end
gamma = GeV*qe*1e9/(me*c^2);
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
NTerms   = 20;
NAngle   = 150;
maxAngle = 2.4/gammaStar;
dtheta   = maxAngle/NAngle;
theta    = (0:NAngle)*dtheta;
EUnd     = charge*qe*NUnd*kUnd*(gamma*gammaStar*KUnd)^2/(2*pi*eps0);

SDist = zeros(NAngle+1,NHarm);
PDist = zeros(NAngle+1,NHarm);
for m = 1:NAngle+1
    gammatheta = 1+(gammaStar*theta(m))^2;
    aUnd = 0.25*KUndStar^2/gammatheta;
    bUnd = 2*KUndStar*gammaStar*theta(m)*cos(phi)/gammatheta;
    cUnd = (1+0.5*KUnd^2)^-2*KUndStar^-2*gammatheta^-3;
    for h = 1:NHarm
        harm = harmonic(1)+h-1;
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
        bess1 = bessa * bessb((2*harm+2):2:(2*(2*NTerms+harm)+2))';
        bess2 = bessa * (bessb((2*harm+3):2:(2*(2*NTerms+harm)+3))...
                      +  bessb((2*harm+1):2:(2*(2*NTerms+harm)+1)))';
        SDist(m,h) = cUnd*harm^2*real(2*bess1*gammaStar*theta(m)*cos(phi)...
                              - bess2*KUndStar)^2;
        PDist(m,h) = cUnd*harm^2*real(2*bess1*gammaStar*theta(m)*sin(phi))^2;
    end
end
SDist = SDist*EUnd;
PDist = PDist*EUnd;
EHarm = SDist(1,:)';
disp('  Harmonic  Energy (nJ/urad^2)')
disp([(harmonic(1):harmonic(2))',1e-3*EHarm])
disp([' Sum    = ', num2str(1e-3*sum(EHarm))])

FigWidth  = 1260;
FigHeight = 630;
border    = 80;
plotHarm  = harmonic(1):harmonic(2);
legnd(plotHarm,1)='h';
legnd(plotHarm,2)='=';
legnd = horzcat(legnd,num2str(plotHarm'));
if harmonic(2) > harmonic(1)
    spontFigName = ['Harmonics ',num2str(harmonic(1)),...
        ' to ',num2str(harmonic(2))];
else
    spontFigName = ['Harmonic ',num2str(harmonic(1))];
end    

if polarized  % Plot x and y polarizations
    % Figure position = [left, bottom, width, height]
    figure('Name',[spontFigName,' vs \theta'],...
        'Position',[0,100,FigWidth,FigHeight])

    subplot(1,2,1)
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border,FigHeight-2*border])
    plot(1e6*theta,SDist*1e-3)
    axs = [0, theta(NAngle+1)*1e6,...
           0, 1.01e-3*max(max(max(SDist)),max(max(PDist)))];
    axis(axs)

    title(['Horizontal (\sigma) Polarization at \phi = ',...
        num2str(phiDeg),'\circ,'])
    xlabel('\theta (\murad)')
    ylabel('Energy per Solid Angle (nJ/\murad^2)')
    legend(legnd,'Location','NorthEast')

    subplot(1,2,2)
    set(gca,'Units','pixels','Position',...
        [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
    plot(1e6*theta,PDist*1e-3)
    axis(axs)
    title(['Vertical (\pi) Polarization at \phi = ',...
        num2str(phiDeg),'\circ,'])
    xlabel('\theta (\murad)')
    ylabel('Energy per Solid Angle (nJ/\murad^2)')
    legend(legnd,'Location','NorthEast')

    figure('Name',[spontFigName,' vs Harmonic'],...
        'Position',[20,80,FigWidth/2,FigHeight])
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border,FigHeight-2*border])

else  % Plot sum of x and y polarization only
    figure('Name',[spontFigName,' vs \theta and Harmonic'],...
        'Position',[0,100,FigWidth,FigHeight])

    subplot(1,2,1)
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border,FigHeight-2*border])
    plot(1e6*theta,(SDist+PDist)*1e-3)
    title(['Unpolarized at \phi = ',num2str(phiDeg),'\circ,'])
    xlabel('\theta (\murad)')
    ylabel('Energy per Solid Angle (nJ/\murad^2)')
    legend(legnd,'Location','NorthEast')

    subplot(1,2,2)
    set(gca,'Units','pixels','Position',...
        [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
end
plot(plotHarm,EHarm*1e-3,'b-o')
% title('Polarizations: Horizontal (red), Vertical (green), Total (blue)')
xlabel('Harmonic Number h')
ylabel('Energy per Solid Angle (nJ/\murad^2)')
title('Energy Emitted on Axis in Harmonics')
end
