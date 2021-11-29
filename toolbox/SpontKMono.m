function [EKMono,harmonicOut] = SpontKMono(varargin)
% For a charge making one pass through an undulator, this function outputs
% the spontaneous energy (microjoules) transmitted through the K
% monochromator at its first harmonic, 8192 eV, and identifies the
% harmonics of the undulator radiation that are passed. It also displays
% the image (in nJ/urad^2) seen on the Direct Imager.
% There are several optional arguments:
%   psiOffset    = vertical angle (angles) (urad)
%                  between axes of FEL and K mono, default = 0
%   GeV          = beam energy (energies) (GeV),   default = 13.64
%   KUnd         = K value of undulator,           default = 'KACT'
%   charge       = charge in bunch (pC),           default = 250
%   girder       = range of undulator girders,     default = [1 1]
%   slit         = [xSlit1,xSlit2,ySlit1,ySlit2,aperture]
%                  FEE slits and the 2-mm-radius
%                  aperture in the gas attenuator
%                  (0 = no slit/aperture)          default = [2,-2,2,-2,2]
%   lambdaUnd    = undulator period (mm),          default = 30
%   EnergySpread = RMS energy spread dE/E (1e-4),  default = 0
%   tableHandle  = handle for table of GUI,        default = 0

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant /(2*pi)

p=inputParser;
p.addOptional('psiOffset',0)
p.addOptional('GeV',13.64)
p.addOptional('charge',250)
p.addOptional('KUnd','KACT')
p.addOptional('girder',[1,1])
p.addOptional('slit',[2,-2,2,-2,1])
p.addOptional('lambdaUnd',30)
p.addOptional('ESpread',0)
p.addOptional('tableHandle',0)
p.parse(varargin{:})

psiOffset = min(max(p.Results.psiOffset*1e-6,-1e-3),1e-3);
GeV       = p.Results.GeV;
KUndIn    = p.Results.KUnd;
charge    = p.Results.charge*1e-12;
girder    = p.Results.girder;
slit      = p.Results.slit*1e-3;
lambdaUnd = p.Results.lambdaUnd*1e-3;
ESpread   = p.Results.ESpread*1e-4;
tHandle   = p.Results.tableHandle;

% Check optional inputs.
Npsi = length(psiOffset);

NGeV = length(GeV);
for nGeV = 1:NGeV
    if GeV(nGeV) <= 0 || GeV(nGeV) > 50 || isnan(GeV(nGeV))
        GeV(nGeV) = 13.64;
    end
end

EKMono = zeros(Npsi,NGeV);

if charge <= 0 || charge > 1e-7
    charge = 250e-12;
end

if lambdaUnd <= 0 || lambdaUnd > 1
    lambdaUnd = 0.03;
end
kUnd=2*pi/lambdaUnd;
eVkUnd = hbar*c*kUnd/qe;

if girder(1) < 1 || girder(1) > 33
    girder(1) = 1;
end
if girder(2) < girder(1) || girder(2) > 33
    girder(2) = girder(1);
end
NGirder = girder(2)-girder(1)+1;
nUnd = 113;	% Periods per girder
LGirder = 3.656; % Effective girder length. Phase shift=nUnd*2*pi at res.

defaultSlit = 0.01;
if slit(1) < slit(2) || slit(1) > defaultSlit
    slit(1) = defaultSlit;
end
if slit(2) > slit(1) || slit(2) < -defaultSlit
    slit(2) = -defaultSlit;
end
if slit(3) < slit(4) || slit(3) > defaultSlit
    slit(3) = defaultSlit;
end
if slit(4) > slit(3) || slit(4) < -defaultSlit
    slit(4) = -defaultSlit;
end
if slit(5) == 0
    slit(5) =  defaultSlit*sqrt(2);
else
    slit(5) =  0.002;
end

% Chop energy-spread distribution into NE slices of equal area.
% For each slice, set dE/E at the point giving half the area.
if (ESpread < 1e-6 && ESpread ~= 0) ||...
        ESpread > 1e-2 || isnan(ESpread)
    ESpread = 0;
end
NE = min(7,max(1,round(ESpread/4e-5)));
dE = sqrt(2)*ESpread*erfinv((2*(1:NE)-NE-1)/NE);
ETweak = 1+dE;

% Z positions (m) of the girder centers and diagnostic devices in the LCLS
% coordinate system called "LTU Linac z (m)".
zDev = [517.059292    % U1 (middle of undulator girder 1)
        520.929292
        524.799292
        529.097292
        532.967292    % U5
        536.837292
        541.135292
        545.005292
        548.875292
        553.173292    % U10
        557.043292
        560.913292
        565.211292
        569.081292
        572.951292    % U15
        577.249292
        581.119292
        584.989292
        589.287292
        593.157292    % U20
        597.027292
        601.325292
        605.195292
        609.065292
        613.363292    % U25
        617.233292
        621.103292
        625.401292
        629.271292
        633.141292    % U30
        637.439292
        641.309292
        645.179292    % U33
        694.5         % 34: ST0
        724.421       % 35: Slits
        733.2         % 36: Last of 12 4-mm-diam aperture in gas attenuator
        734.438       % 37: KMono
        736.496   ];  % 38: Direct Imager

thetaMax = min(sqrt(max(slit(1:2).^2)+max(slit(3:4).^2))...
                  /(zDev(35)-zDev(girder(2))),...
           slit(5)/(zDev(36)-zDev(girder(2))));

% First we find the harmonic and angle thetaK to the axis of the FEL where
% the photon energy matches the transmission of the K mono. We use the FEL
% axis as our reference, and the axis of the monochromator is tilted by an
% offset angle in y relative to this.
% The monochromator transmits over only a narrow energy range and over a
% narrow anglular range about its axis. We first find the angle theta
% (tilt from z axis) matching the energy range, and then integrate over a
% narrow angular range around this value. In the xy plane, the angle phi
% covers 180 degrees, and symmetry is assumed for the other half.

% Properties of the K monochromator:
% The energy transmission has a full width at half maximum of = 1.398e-4,
% which I assume to be Gaussian and for a single crystal. The four
% reflections in the K mono raises this to the 4th power.
% The angular transmission is close to a super-Gaussian--almost a top hat--
% with FWHM of 30.1 urad and a peak of 72.9%. We assume that the FWHM
% remains correct, and find the sigma for a third-order super-Gaussian.
eV0KMono    = 8192;         % Photon energy (eV) at center of transmission.
FWHMeVKMono = 1.398e-4*eV0KMono;                % FWHM (eV)
sigeVKMono  = FWHMeVKMono/(2*(2*log(2))^(1/6)); % Standard dev, 4 bounces

psi0          = 14*pi/180;                        % Angle to grazing
FWHMpsiKMono  = FWHMeVKMono*tan(psi0)/eV0KMono;   % FWHM in angle
sigpsiKMono   = FWHMpsiKMono/(2*(2*log(2))^(1/6));
PeakKMono     = 0.729;        % Transmission at peak
sqrtPeakKMono = sqrt(PeakKMono);

% Read the KACT values from the undulator taper.
KUnd = ones(1,NGirder);
if strncmp(KUndIn,'KACT',4)
    for gird = girder(1):girder(2)
        g = gird-girder(1)+1;
        try
            KUnd(g) = lcaGetSmart(['USEG:UND1:',num2str(gird),'50:KACT']);
            if KUnd(g) <= 0 || isnan(KUnd(g))
                KUnd(g) = 3.5;
            end
        catch
            disp(lasterror)
            KUnd(g) = 3.5;
        end
    end
else
    if min(KUndIn) <= 0 || max(KUndIn) > 20
        KUnd = KUnd*3.5;
    elseif length(KUndIn) >= NGirder
        KUnd = KUndIn(1:NGirder);
    else
        KUnd = KUnd*KUndIn(1);
    end
end
KUndStar = KUnd./sqrt(1+0.5*KUnd.^2);

gamma0   = GeV*qe*1e9/(me*c^2);
gammaStar0  = zeros(NGeV,NGirder);
eV1axis0    = zeros(NGeV,NGirder);
for nGeV = 1:NGeV
    for gird = girder(1):girder(2)
        g = gird-girder(1)+1;
        gammaStar0(nGeV,g) = gamma0(nGeV)/sqrt(1+0.5*KUnd(g)^2);
        eV1axis0(nGeV,g)   = 2*hbar*c*kUnd*gammaStar0(nGeV,g)^2/qe;
    end
end
harmonicOut = ones(1,2);

rMax   = (zDev(38)-zDev(girder(2)))*thetaMax;
Nr     = 100;
dr     = max(rMax/Nr,5e-6);
Nr     = ceil(rMax/dr);
dr     = rMax/Nr;
radius = (1:Nr)*dr;

Nphi   = 120;
dphi   = 2*pi/Nphi;
phi    = (0:Nphi-1)*dphi;

NeV    = 100;
deV    = 2*sigeVKMono/NeV;
eV     = eV0KMono + ((0:NeV)-NeV/2)*deV;
eVarg  = (eV-eV0KMono)/sigeVKMono;

NTerms = 20;
eUnd = sqrtPeakKMono*nUnd*hbar*kUnd/(sqrt(2*pi)*eps0);
fUnd = (2*charge/(hbar*mu0*c))*deV/NE;

blanks = '                      ';
table = char(32*ones(Npsi*NGeV+3,22));
table(1,:) = 'y Tilt    e-    X-Rays';
table(2,:) = '[urad]  [GeV]    [pJ] ';


%-----------------------------------------------------------------
for npsi = 1:Npsi
    for nGeV = 1:NGeV
        % Find the distribution in polar coordinates r and phi
        % on the Direct Imager.
        TDist = zeros(Nr,Nphi);
        for m = 1:Nr
            if tHandle
                s1 = [blanks,num2str(psiOffset(npsi)*1e6,'%6.1f')];
                s1 = s1(length(s1)-5:length(s1));
                s2 = [blanks,num2str(GeV(nGeV),'%7.3f')];
                s2 = s2(length(s2)-6:length(s2));
                s3 = '  Working';
                table((npsi-1)*NGeV+nGeV+2,:) = [s1 s2 s3];
                s3 = ['Radius ',num2str(m),' of ',num2str(Nr),blanks];
                table((npsi-1)*NGeV+nGeV+3,:) =...
                    s3(1:size(table,2));
                set(tHandle,'String',table)
                pause(0.01)
            end
            if mod(m,10) == 0
                disp(['Calculating radius ',num2str(m),' of ',num2str(Nr)])
            end
            for n = 1:Nphi
                for nE = 1:NE
                    Ex = complex(zeros(NeV+1,1,'double'));
                    Ey = Ex;
                    % Sum the electric field emitted by one electron
                    % over all girders and all harmonics.
                    for gird = girder(1):girder(2)
                        thetaG = radius(m)/(zDev(38)-zDev(gird));
                        xi  = thetaG*cos(phi(n));
                        psi = thetaG*sin(phi(n));
                        psiarg = (psi-psiOffset(npsi))/sigpsiKMono;
                        xS = xi *(zDev(35)-zDev(gird));
                        yS = psi*(zDev(35)-zDev(gird));
                        if ~((slit(1) < xS || slit(2) > xS || ...
                              slit(3) < yS || slit(4) > yS || ...
                              slit(5) < thetaG*(zDev(36)-zDev(gird))))
                            g = gird-girder(1)+1;
                            gamtheta = 1+(gamma0*ETweak(nE)*thetaG).^2;
                            % Length of breaks between girders
                            LBreaks = (zDev(gird)-zDev(girder(1)))-(g-1)*LGirder;
                            LBreaksScaled = LBreaks*gamtheta/(gamtheta+KUnd(g)^2/2);
                            gammaStar  = gammaStar0(nGeV,g)*ETweak(nE);
                            eV1axis    =   eV1axis0(nGeV,g)*ETweak(nE)^2;
                            gammatheta = 1+(gammaStar*thetaG)^2;
                            eV1  = eV1axis/gammatheta;
                            aUnd = 0.25*KUndStar(g)^2/gammatheta;
                            bUnd = 2*KUndStar(g)*gammaStar*xi/gammatheta;
                            gUnd = gammatheta^2*...
                                sqrt(radius(m)^2+(zDev(38)-zDev(gird))^2);
                            % Which harmonics get through the K mono?
                            harmonic(1) = max(ceil((eV0KMono-8*sigeVKMono)...
                                *(1+(gammaStar*thetaG)^2)/eV1axis-0.6),1);
                            harmonic(2) =     ceil((eV0KMono+8*sigeVKMono)...
                                *(1+(gammaStar*thetaG)^2)/eV1axis-0.4);
                            harmonicOut(1) = min(harmonicOut(1),harmonic(1));
                            harmonicOut(2) = max(harmonicOut(2),harmonic(2));
                            for harm = harmonic(1):harmonic(2)
                                dUnd = 1i^(harm+1)*harm*eUnd*gammaStar^3;
                                amplFactor = dUnd/(eV1*gUnd);
                                phaseFactor = 2*pi*nUnd*harm*(g-1)+kUnd*LBreaksScaled;
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
                                bess2 = bessa *(bessb((2*harm+3):2:(2*(2*NTerms+harm)+3))...
                                              + bessb((2*harm+1):2:(2*(2*NTerms+harm)+1)))';
                                bessx  = real(2*bess1*gammaStar*xi-bess2*KUndStar(g));
                                bessy  = real(2*bess1*gammaStar*psi);
                                if abs(bessx) > 1e-9 || abs(bessy) > 1e-9
                                    for j = 1:NeV+1
                                        exparg = (eVarg(j)+psiarg)^6 + (eVarg(j)-psiarg)^6;
                                        if exparg <= 20
                                            sincarg = (eV(j)/eV1-harm)*pi*nUnd;
                                            if sincarg ~= 0
                                                sinc = sin(sincarg)/sincarg;
                                            else
                                                sinc = 1;
                                            end
                                            T = sinc*amplFactor*...
                                                exp(-exparg-1i*phaseFactor*eV(j)/eV1);
                                            Ex(j) = Ex(j) + T*bessx;
                                            Ey(j) = Ey(j) + T*bessy;
                                        end
                                    end
                                end
                            end
                        end
                    end
                    TDist(m,n) = TDist(m,n) + sum(abs(Ex).^2) + sum(abs(Ey).^2);
                end
            end
        end
        TDist = TDist*fUnd;
        EKMono(npsi,nGeV) = sum(radius*TDist)*dr*dphi;

        %-----------------------------------------------------------------
        s3 = [blanks,num2str(EKMono(npsi,nGeV)*1e12,'%9.4g')];
        s3 = s3(length(s3)-8:length(s3));
        if tHandle
            table((npsi-1)*NGeV+nGeV+2,:) = [s1 s2 s3];
            table((npsi-1)*NGeV+nGeV+3,:) = blanks;
            set(tHandle,'String',table)
            pause(0.01)
        end
        disp([     'Vertical Tilt=',num2str(psiOffset(npsi)*1e6),...
           ' urad   Beam Energy=',num2str(GeV(nGeV)),...
            ' GeV   Energy through K-Mono=',...
            num2str(EKMono(npsi,nGeV)*1e12,'%10.5g'),' pJ'])
        close all

        xPts = 1e3*radius'*cos(phi);
        yPts = 1e3*radius'*sin(phi);

        FigWidth  = 1260;
        FigHeight = 630;
        border    = 90;
        colorBarWidth = 70;

        % Figure position = [left, bottom, width, height]

        figure('Name','K-Monochromator Transmission to Direct Imager',...
            'Position',[10,150,FigWidth,FigHeight])
        subplot(1,2,1)
        set(gca,'Units','pixels','Position',...
            [border,border,FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
        imgSize = FigHeight-2*border;
        img = zeros(imgSize);
        for nx = 1:imgSize
            for ny = 1:imgSize
                x = ((nx-0.5)*2/imgSize-1)*rMax;
                y = ((ny-0.5)*2/imgSize-1)*rMax;
                rImg   = sqrt(x^2+y^2);
                phiImg = atan2(y,x);
                if phiImg < 0
                    phiImg = phiImg+2*pi;
                end
                m = (Nr-1)*rImg/rMax+1;
                n = Nphi*phiImg/(2*pi)+1;
                if rImg <= rMax
                    m1 = max(floor(m),1);
                    m2 = min(m1+1,Nr);
                    m3 = m2;
                    n1 = floor(n);
                    if n1 == Nphi
                        n2 = 1;
                    else
                        n2 = n1+1;
                    end
                    if TDist(m1,n1) == 0 && mod(n,1) < 0.5
                        n2 = n1;
                    else
                        n1 = n2;
                    end
                    if TDist(m1,n2) == 0 && mod(n,1) > 0.5
                        n1 = n2;
                    else
                        n2 = n1;
                    end
                    if TDist(m2,n1) == 0 && mod(m,1) > 0.5
                        m1 = m2;
                    else
                        m2 = m1;
                    end
                    if TDist(m3,n2) == 0 && mod(m,1) > 0.5
                        m1 = m3;
                    else
                        m3 = m1;
                    end
                    img(ny,nx) = TDist(m1,n1)*(1-m+m1)*(1-n+n1)+...
                                 TDist(m2,n1)*  (m-m1)*(1-n+n1)+...
                                 TDist(m1,n2)*(1-m+m1)*  (n-n1)+...
                                 TDist(m3,n2)*  (m-m1)*  (n-n1);
                end
            end
        end
        imagesc([-radius(Nr) radius(Nr)]*1000,[radius(Nr) -radius(Nr)]*1000,img)
        colorbar
        title([num2str(GeV(nGeV),'%6.3f'),' GeV, ',...
            num2str(psiOffset(npsi)*1e6,'%5.1f'),' \murad: ',...
            num2str(EKMono(npsi,nGeV)*1e12,'%8.3g'),...
            ' pJ (unpol) via K-Mono to Direct Imager'])
        xlabel('Horizontal Position x (mm)')
        ylabel('Vertical Position y (mm)')

        subplot(1,2,2)
        set(gca,'Units','pixels','Position',...
            [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
        plot([ xPts(Nr:-1:1,round(Nphi/2+1));    xPts(:,   1)],...
             [TDist(Nr:-1:1,round(Nphi/2+1));   TDist(:,1)]*1e6,...
             [ yPts(Nr:-1:1,round(3*Nphi/4+1));  yPts(:,   round(Nphi/4+1))],...
             [TDist(Nr:-1:1,round(3*Nphi/4+1)); TDist(:,round(Nphi/4+1))]*1e6)
        title('Intensity on x and y Axes')
        xlabel('x or y Position (mm)')
        ylabel('Energy (\muJ/m^2)')
        legend(['x';'y'],'Location','West')
        pause(2)
    end
end

%-----------------------------------------------------------------
if npsi > 1 || nGeV > 1
    figure('Name','Energy through K-Monochromator',...
        'Position',[20,80,FigWidth/2,FigHeight])
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border,FigHeight-2*border])
    if npsi > 1 && nGeV > 1
        mesh(GeV,psiOffset*1e6,EKMono*1e12)
        xlabel('Electron Energy (GeV)')
        xlim([min(GeV) max(GeV)])
        ylabel('Tilt Angle (\murad)')
        ylim([min(psiOffset) max(psiOffset)]*1e6)
        zlabel('Energy through K Monochromator (pJ)')
        title('Scan of the K Monochromator')
    elseif npsi > 1
        plot(psiOffset*1e6,EKMono(:,1)*1e12)
        xlim([min(psiOffset) max(psiOffset)]*1e6)
        xlabel('Tilt Angle (\murad)')
        ylabel('Energy through K Monochromator (pJ)')
        title('Scan of the K Monochromator')
    elseif nGeV > 1
        plot(GeV,EKMono(1,:)*1e12)
        xlim([min(GeV) max(GeV)])
        xlabel('Electron Energy (GeV)')
        ylabel('Energy through K Monochromator (pJ)')
        title('Scan of the K Monochromator')
    end
end
end