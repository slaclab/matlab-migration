function [EHarm,SDist,PDist] = SpontAngle3D(varargin)
% For a charge making one pass through an undulator, this function outputs
% the spontaneous energy emitted in a range of harmonics, and plots the
% distributions in joules per solid angle for the harmonics as 3D plots
% versus angles xi (x') and psi (y').
% There are several optional arguments:
%   harmonic     = range of harmonics to compute, default = [1 1]
%   polarized    = x,y polarized = 1,             default = 1
%   GeV          = beam energy (GeV),             default = 13.64
%   charge       = charge in bunch (pC),          default = 250
%   KUnd         = K value of undulator,          default = 3.5
%   lambdaUnd    = undulator period (mm),         default = 30
%   NUnd         = number of periods,             default = 3729
%   tableHandle  = handle for table of GUI,        default = 0
% Three more optional arguments provide the distributions calculated in a
% previous call, so that new plots can be made without the need for a
% (slow) recalculation. Their defaults are zero.
%   EHarm        = energy (J) in each of the range of harmonics
%   SDist        = energy per solid angle in each harmonic, S polarization
%   PDist        = energy per solid angle in each harmonic, P polarization

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant /(2*pi)

p=inputParser;
p.addOptional('harmonic',[1 1])
p.addOptional('polarized',1)
p.addOptional('GeV',13.64)
p.addOptional('charge',250)
p.addOptional('KUnd',3.5)
p.addOptional('lambdaUnd',30)
p.addOptional('NUnd',113*33)
p.addOptional('tableHandle',0)
p.addOptional('EHarm',0)
p.addOptional('SDist',0)
p.addOptional('PDist',0)
p.parse(varargin{:})

harmonic(1) = min(max(p.Results.harmonic(1),          1),30);
harmonic(2) = min(max(p.Results.harmonic(2),harmonic(1)),30);
NHarm       = harmonic(2)-harmonic(1)+1;
polarized   = p.Results.polarized ~= 0;
GeV         = p.Results.GeV;
charge      = p.Results.charge*1e-12;
KUnd        = p.Results.KUnd;
lambdaUnd   = p.Results.lambdaUnd*0.001;
NUnd        = p.Results.NUnd;
tHandle     = p.Results.tableHandle;
EHarm       = p.Results.EHarm;
SDist       = p.Results.SDist;
PDist       = p.Results.PDist;

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
maxAngle = 2.2/gammaStar;
dxi      = maxAngle/NAngle;
xi       = (0:NAngle)*dxi;
dpsi     = dxi;
psi      = (0:NAngle)*dpsi;
EUnd     = charge*qe*NUnd*kUnd*(gamma*gammaStar*KUnd)^2/(2*pi*eps0);

%-----------------------------------------------------------------
if sum(sum(EHarm)) == 0
    SDist = zeros(NAngle+1,NAngle+1,NHarm);
    PDist = zeros(NAngle+1,NAngle+1,NHarm);
    for m = 1:NAngle+1
        if tHandle
            table = [num2str(100*(m-1)/NAngle,' %5.1f'),'% complete'];
            set(tHandle,'String',table)
            pause(0.01)
        end
        for n = 1:NAngle+1
            gammatheta = 1+gammaStar^2*(xi(m)^2+psi(n)^2);
            aUnd = 0.25*KUndStar^2/gammatheta;
            bUnd = 2*KUndStar*gammaStar*xi(m)/gammatheta;
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
                SDist(m,n,h) = cUnd*harm^2*real(2*bess1*gammaStar*xi(m)...
                              -  bess2*KUndStar)^2;
                PDist(m,n,h) = cUnd*harm^2*real(2*bess1*gammaStar*psi(n))^2;
            end
        end
    end
    SDist  = SDist*EUnd;
    PDist  = PDist*EUnd;
    EHarm  = zeros(3,NHarm);
    for harm = 1:NHarm
        EHarm(2,harm) = 4*sum(sum(SDist(:,:,harm)))*dxi*dpsi; % Horiz
        EHarm(3,harm) = 4*sum(sum(PDist(:,:,harm)))*dxi*dpsi; % Vert
        EHarm(1,harm) = EHarm(2,harm) + EHarm(3,harm);        % Both
    end
end
disp(EHarm)
disp('  Harmonic  Energy (uJ)')
disp([(harmonic(1):harmonic(2));EHarm(1,:)*1e6]')
disp([' Sum (uJ) = ', num2str(sum(EHarm(1,:))*1e6)])

%-----------------------------------------------------------------
FigWidth  = 1260;
FigHeight = 630;
border    = 90;
offsetStep = 16;
offsetX = 10;
offsetY = 150;
colorBarWidth = 70;
imgSize = FigHeight-2*border;
img1 = zeros(imgSize);
img2 = zeros(imgSize);
if harmonic(2) > harmonic(1)
    spontFigName = ['Spontaneous Emission in Harmonics ',...
        num2str(harmonic(1)),' to ',num2str(harmonic(2))];
else
    spontFigName = ['Spontaneous Emission in Harmonic ',...
        num2str(harmonic(1))];
end

% Use symmetry to spread results over 4 quadrants, and plot
xi4Q  = [ -xi(NAngle+1:-1:2)';xi'];
psi4Q = [-psi(NAngle+1:-1:2)';psi'];

if polarized  % Plot x and y polarizations
    for h = 1:NHarm
        harm = harmonic(1)+h-1;
        for m = 1:NAngle+1
            for n = 1:NAngle+1
                SDist4Q(NAngle+n,NAngle+m)=SDist(m,n,h);
                SDist4Q(NAngle+2-n,NAngle+m)=SDist(m,n,h);
                SDist4Q(NAngle+n,NAngle+2-m)=SDist(m,n,h);
                SDist4Q(NAngle+2-n,NAngle+2-m)=SDist(m,n,h);
                PDist4Q(NAngle+n,NAngle+m)=PDist(m,n,h);
                PDist4Q(NAngle+2-n,NAngle+m)=PDist(m,n,h);
                PDist4Q(NAngle+n,NAngle+2-m)=PDist(m,n,h);
                PDist4Q(NAngle+2-n,NAngle+2-m)=PDist(m,n,h);
            end
        end
        for nx = 1:imgSize
            for ny = 1:imgSize
                x = ((nx-0.5)*2/imgSize-1)*NAngle*dxi;
                y = ((ny-0.5)*2/imgSize-1)*NAngle*dpsi;
                m = 2*NAngle*(nx-1)/(imgSize-1)+1;
                m1 = max(floor(m),1);
                m2 = min(m1+1,2*NAngle+1);
                n = 2*NAngle*(ny-1)/(imgSize-1)+1;
                n1 = max(floor(n),1);
                n2 = min(n1+1,2*NAngle+1);
                img1(ny,nx) = SDist4Q(n1,m1)*(1-m+m1)*(1-n+n1)+...
                              SDist4Q(n1,m2)*  (m-m1)*(1-n+n1)+...
                              SDist4Q(n2,m1)*(1-m+m1)*  (n-n1)+...
                              SDist4Q(n2,m2)*  (m-m1)*  (n-n1);
                img2(ny,nx) = PDist4Q(n1,m1)*(1-m+m1)*(1-n+n1)+...
                              PDist4Q(n1,m2)*  (m-m1)*(1-n+n1)+...
                              PDist4Q(n2,m1)*(1-m+m1)*  (n-n1)+...
                              PDist4Q(n2,m2)*  (m-m1)*  (n-n1);
            end
        end
        % Figure position = [left, bottom, width, height]
        figure('Name',['Harmonic ',num2str(harm)],...
            'Position',[offsetX,offsetY,FigWidth,FigHeight])
        offsetX = offsetX + offsetStep;
        offsetY = offsetY - offsetStep;

        subplot(1,2,1)
        set(gca,'Units','pixels','Position',[border,border,...
            FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
        imagesc([-1 1]*NAngle*dxi*1e6,[1 -1]*NAngle*dpsi*1e6,img1)
        colorbar
%         mesh(1e6*xi4Q,1e6*psi4Q,SDist4Q*1e-3)
        title([num2str(EHarm(2,h)*1e6,'%8.3g'),' \muJ Total, ',...
               num2str(max(max(SDist(:,:,h))),'%8.3g'),' pJ/\murad^2 Peak, ',...
               'Horizontal (\sigma) Polarization, Harmonic ',num2str(harm)])
        xlabel('Horizontal Angle x'' (\murad)')
        ylabel('Vertical Angle y'' (\murad)')
%         zlabel('Energy per Solid Angle (nJ/\murad^2)')

        subplot(1,2,2)
        set(gca,'Units','pixels','Position',[FigWidth/2+border,border,...
            FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
        imagesc([-1 1]*NAngle*dxi*1e6,[1 -1]*NAngle*dpsi*1e6,img2)
        colorbar
%         mesh(1e6*xi4Q,1e6*psi4Q,PDist4Q*1e-3)
        title([num2str(EHarm(3,h)*1e6,'%8.3g'),' \muJ Total, ',...
               num2str(max(max(PDist(:,:,h))),'%8.3g'),' pJ/\murad^2 Peak, ',...
               'Vertical (\pi) Polarization, Harmonic ',num2str(harm)])
        xlabel('Horizontal Angle x'' (\murad)')
        ylabel('Vertical Angle y'' (\murad)')
%         zlabel('Energy per Solid Angle (nJ/\murad^2)')
    end
    if NHarm > 1
        figure('Name',spontFigName,...
            'Position',[offsetX,offsetY,FigWidth/2,FigHeight])
        set(gca,'Units','pixels','Position',...
            [border,border,FigWidth/2-2*border,FigHeight-2*border])
    end

else  % Plot sum of x and y polarization only
    for h = 1:2:NHarm
        harm = harmonic(1)+h-1;
        for m = 1:NAngle+1
            for n = 1:NAngle+1
                T0Dist4Q(NAngle+n,NAngle+m)    = SDist(m,n,h)+PDist(m,n,h);
                T0Dist4Q(NAngle+2-n,NAngle+m)  = SDist(m,n,h)+PDist(m,n,h);
                T0Dist4Q(NAngle+n,NAngle+2-m)  = SDist(m,n,h)+PDist(m,n,h);
                T0Dist4Q(NAngle+2-n,NAngle+2-m)= SDist(m,n,h)+PDist(m,n,h);
            end
        end
        for nx = 1:imgSize
            for ny = 1:imgSize
                x = ((nx-0.5)*2/imgSize-1)*NAngle*dxi;
                y = ((ny-0.5)*2/imgSize-1)*NAngle*dpsi;
                m = 2*NAngle*(nx-1)/(imgSize-1)+1;
                m1 = max(floor(m),1);
                m2 = min(m1+1,2*NAngle+1);
                n = 2*NAngle*(ny-1)/(imgSize-1)+1;
                n1 = max(floor(n),1);
                n2 = min(n1+1,2*NAngle+1);
                img1(ny,nx) = T0Dist4Q(n1,m1)*(1-m+m1)*(1-n+n1)+...
                              T0Dist4Q(n1,m2)*  (m-m1)*(1-n+n1)+...
                              T0Dist4Q(n2,m1)*(1-m+m1)*  (n-n1)+...
                              T0Dist4Q(n2,m2)*  (m-m1)*  (n-n1);
            end
        end
        if harm == harmonic(2)
            figure('Name',['Harmonic ',num2str(harm),...
                ' and ',spontFigName])
        else
            figure('Name',['Harmonics ',num2str(harm),...
                ' and ',num2str(harm+1)])
            for m = 1:NAngle+1
                for n = 1:NAngle+1
                    T1Dist4Q(NAngle+n,NAngle+m)    = SDist(m,n,h+1)+PDist(m,n,h+1);
                    T1Dist4Q(NAngle+2-n,NAngle+m)  = SDist(m,n,h+1)+PDist(m,n,h+1);
                    T1Dist4Q(NAngle+n,NAngle+2-m)  = SDist(m,n,h+1)+PDist(m,n,h+1);
                    T1Dist4Q(NAngle+2-n,NAngle+2-m)= SDist(m,n,h+1)+PDist(m,n,h+1);
                end
            end
            for nx = 1:imgSize
                for ny = 1:imgSize
                    x = ((nx-0.5)*2/imgSize-1)*NAngle*dxi;
                    y = ((ny-0.5)*2/imgSize-1)*NAngle*dpsi;
                    m = 2*NAngle*(nx-1)/(imgSize-1)+1;
                    m1 = max(floor(m),1);
                    m2 = min(m1+1,2*NAngle+1);
                    n = 2*NAngle*(ny-1)/(imgSize-1)+1;
                    n1 = max(floor(n),1);
                    n2 = min(n1+1,2*NAngle+1);
                    img2(ny,nx) = T1Dist4Q(n1,m1)*(1-m+m1)*(1-n+n1)+...
                                  T1Dist4Q(n1,m2)*  (m-m1)*(1-n+n1)+...
                                  T1Dist4Q(n2,m1)*(1-m+m1)*  (n-n1)+...
                                  T1Dist4Q(n2,m2)*  (m-m1)*  (n-n1);
                end
            end
        end
        % Figure position = [left, bottom, width, height]
        if NHarm == 1
            set(gcf,'Position',[offsetX,offsetY,FigWidth/2,FigHeight])
        else
            set(gcf,'Position',[offsetX,offsetY,FigWidth,FigHeight])
            offsetX = offsetX + offsetStep;
            offsetY = offsetY - offsetStep;
            subplot(1,2,1)
        end
        set(gca,'Units','pixels','Position',[border,border,...
            FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
        imagesc([-1 1]*NAngle*dxi*1e6,[1 -1]*NAngle*dpsi*1e6,img1)
        colorbar
%         mesh(1e6*xi4Q,1e6*psi4Q,T0Dist4Q*1e-3)
        title([num2str(EHarm(1,h)*1e6,'%8.3g'),' \muJ Total, ',...
               num2str(max(max(SDist(:,:,h)+PDist(:,:,h))),'%8.3g'),...
               ' pJ/\murad^2 Peak, Unpolarized, Harmonic ',num2str(harm)])
        xlabel('Horizontal Angle x'' (\murad)')
        ylabel('Vertical Angle y'' (\murad)')
%         zlabel('Energy per Solid Angle (nJ/\murad^2)')

        if NHarm > 1
            subplot(1,2,2)
            set(gca,'Units','pixels','Position',[FigWidth/2+border,border,...
                FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
            if harm < harmonic(2)
                imagesc([-1 1]*NAngle*dxi*1e6,[1 -1]*NAngle*dpsi*1e6,img2)
                colorbar
%                 mesh(1e6*xi4Q,1e6*psi4Q,T1Dist4Q*1e-3)
                title([num2str(EHarm(1,h+1)*1e6,'%8.3g'),' \muJ Total, ',...
                   num2str(max(max(SDist(:,:,h+1)+PDist(:,:,h+1))),'%8.3g'),...
                   ' pJ/\murad^2 Peak, Unpolarized, Harmonic ',num2str(harm+1)])
                xlabel('Horizontal Angle x'' (\murad)')
                ylabel('Vertical Angle y'' (\murad)')
%                 zlabel('Energy per Solid Angle (nJ/\murad^2)')
                if harm == harmonic(2)-1
                    figure('Name',spontFigName,...
                        'Position',[offsetX,offsetY,FigWidth/2,FigHeight])
                    set(gca,'Units','pixels','Position',...
                        [border,border,FigWidth/2-2*border,FigHeight-2*border])
                end
            end
        end
    end
end
if NHarm > 1
    plot(harmonic(1):harmonic(2),EHarm(1,:)*1e6,'r-o',...
         harmonic(1):harmonic(2),EHarm(2,:)*1e6,'g-o',...
         harmonic(1):harmonic(2),EHarm(3,:)*1e6,'b-o')
    title('Polarizations: Total (red), Horizontal (green), Vertical (blue)')
    xlabel('Harmonic Number h')
    ylabel('Energy in Harmonic (\muJ)')
end
end
