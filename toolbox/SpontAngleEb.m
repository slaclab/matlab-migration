function [] = SpontAngleEb(varargin)
% For a charge making one pass through an undulator, this function plots
% the emitted photon energy for a range of harmonics against the angle
% theta from the z axis and the beam energy.
% There are several optional arguments:
%   harmonic     = range of harmonics to compute, default = [1 1]
%   GeVmax       = maximum beam energy (GeV),     default = 13.64
%   KUnd         = K value of undulator,          default = 3.5
%   lambdaUnd    = undulator period (mm),         default = 30

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant /(2*pi)

p=inputParser;
p.addOptional('harmonic',[1 1])
p.addOptional('GeVmax',13.64)
p.addOptional('KUnd',3.5)
p.addOptional('lambdaUnd',30)
p.parse(varargin{:})

harmonic(1)     = min(max(p.Results.harmonic(1),    1),              30);
harmonic(2)     = min(max(p.Results.harmonic(2),    harmonic(1)),    30);
NHarm           = harmonic(2)-harmonic(1)+1;
GeVmax          = p.Results.GeVmax;
KUnd            = p.Results.KUnd;
lambdaUnd       = p.Results.lambdaUnd*0.001;

% Check optional inputs.
if KUnd <= 0 || KUnd > 20
    KUnd = 3.5;
end
KUndStar = KUnd/sqrt(1+0.5*KUnd^2);

if lambdaUnd <= 0 || lambdaUnd > 1
    lambdaUnd = 0.03;
end
kUnd=2*pi/lambdaUnd;

close all
NGeV      = 100;
GeV       = (0:NGeV)*GeVmax/NGeV;
gamma     = GeV*qe*1e9/(me*c^2);
gammaStar = gamma/sqrt(1+0.5*KUnd^2);
NAngle    = 150;
maxAngle  = 2.2/gammaStar(NGeV+1);
dtheta    = maxAngle/NAngle;
theta     = (0:NAngle)*dtheta;
Dist      = zeros(NAngle+1,NGeV+1,NHarm);

for m = 1:NAngle+1
    for j = 1:NGeV+1
        gammatheta = 1+(gammaStar(j)*theta(m))^2;
        for h = 1:NHarm
            harm = harmonic(1)+h-1;
            Dist(m,j,h) = 2*hbar*c*kUnd*harm*(gammaStar(j))^2/(gammatheta*qe);
        end
    end
end

FigWidth  = 1260;
FigHeight = 630;
border    = 80;
if harmonic(2) > harmonic(1)
    spontFigName = ['Photon Energy (keV) in Harmonics ',...
        num2str(harmonic(1)),' to ',num2str(harmonic(2))];
else
    spontFigName = ['Photon Energy (keV) in Harmonic ',...
        num2str(harmonic(1))];
end    

for h = 1:2:NHarm
    harm = harmonic(1)+h-1;
    % Figure position = [left, bottom, width, height]
    if harm < harmonic(2)
        figure('Name',['Harmonics ',num2str(harm),...
            ' and ',num2str(harm+1)])
    else
        figure('Name',['Harmonic ',num2str(harm),...
            ' and ',spontFigName])
    end
    offset = (h-1)*10;
    set(gcf,'Position',[offset,100-offset,FigWidth,FigHeight])
    
    subplot(1,2,1)
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border,FigHeight-2*border])
    mesh(GeV,theta*1e6,Dist(:,:,h)*1e-3)
    title(['Harmonic ',num2str(harm)])
    xlabel('Beam Energy (GeV)')
    ylabel('\theta (\murad)')
    zlabel('Photon Energy (keV)')
    
    subplot(1,2,2)
    set(gca,'Units','pixels','Position',...
        [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
    if harm < harmonic(2)
        mesh(GeV,theta*1e6,Dist(:,:,h+1)*1e-3)
        title(['Photon Energy (keV) in Harmonic ',num2str(harm+1)])
        xlabel('Beam Energy (GeV)')
        ylabel('\theta (\murad)')
        zlabel('Photon Energy (keV)')
        if harm == harmonic(2)-1
            figure('Name',spontFigName,...
                'Position',[offset+20,80-offset,FigWidth/2,FigHeight])
            set(gca,'Units','pixels','Position',...
                [border,border,FigWidth/2-2*border,FigHeight-2*border])
        end
    end
    drawnow
    pause(0.5)
end
AxisDist = zeros(NGeV+1,NHarm);
for j=1:NGeV+1
    for h = 1:NHarm
        AxisDist(j,h) = Dist(1,j,h);
    end
end
plot(GeV,AxisDist*1e-3)
title('Photon Energy vs Beam Energy at \theta = 0')
xlabel('Beam Energy (GeV)')
ylabel('Photon Energy (keV)')
harm = harmonic(1):harmonic(2);
legnd(harm-harmonic(1)+1,1)='h';
legnd(harm-harmonic(1)+1,2)='=';
legnd = horzcat(legnd,num2str(harm'));
legend(legnd,'Location','NorthWest')
drawnow
pause(0.5)
end
