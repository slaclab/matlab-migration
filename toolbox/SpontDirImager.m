function [EHarm,eV,TDist,spectrum] = SpontDirImager(varargin)
% For a charge making one pass through an undulator, this function outputs
% the spontaneous energy (microjoules) transported to the Direct Imager
% for the selected harmonics of the undulator radiation. It also displays
% the image (in nJ/urad^2) seen on the Direct Imager.
% There are several optional arguments:
%   harmonic     = range of harmonics to compute,  default = [1 1]
%   GeV          = beam energy (energies) (GeV),   default = 13.64
%   charge       = charge in bunch (pC),           default = 250
%   KUnd         = K value of undulator,           default = 'KACT'
%   girder       = range of undulator girders,     default = [1 1]
%   slit         = [xSlit1,xSlit2,ySlit1,ySlit2,aperture]
%                  FEE slits and the 2-mm-radius
%                  aperture in the gas attenuator
%                  (0 = no slit/aperture)          default = [2,-2,2,-2,2]
%   lambdaUnd    = undulator period (mm),          default = 30
%   EnergySpread = RMS energy spread dE/E (1e-4),  default = 0
%   yag          = thickness of YAG screen (um),   default = 0 (ignore)
%   tableHandle  = handle for table of GUI,        default = 0
% Three more optional arguments provide the distributions calculated in a
% previous call, so that new plots can be made without the need for a
% (slow) recalculation. Their defaults are zero.
%   EHarm        = energy (J) in each of the range of harmonics
%   eV           = cell array of energy points used for each harmonic
%   TDist        = energy into dr and dphi in each harmonic, unpolarized
%   spectrum     = cell array of energy per eV in each harmonic, unpolarized

% Physical constants
c    = 2.99792458e8;  % speed of light (m/s)
mu0  = 4e-7*pi;       % permeability of free space (H/m)
eps0 = 1/(mu0*c^2);   % permittivity of free space (F/m)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant /(2*pi)

p=inputParser;
p.addOptional('harmonic',[1 1])
p.addOptional('GeV',13.64)
p.addOptional('charge',250)
p.addOptional('KUnd','KACT')
p.addOptional('girder',[1,1])
p.addOptional('slit',[2,-2,2,-2,1])
p.addOptional('lambdaUnd',30)
p.addOptional('ESpread',0)
p.addOptional('yag',0)
p.addOptional('tableHandle',0)
p.addOptional('EHarm',0)
p.addOptional('eV',0)
p.addOptional('TDist',0)
p.addOptional('spectrum',cell(0))
p.parse(varargin{:})

harmonic(1) = min(max(p.Results.harmonic(1),          1),30);
harmonic(2) = min(max(p.Results.harmonic(2),harmonic(1)),30);
NHarm       = harmonic(2)-harmonic(1)+1;
GeV         = p.Results.GeV;
KUndIn      = p.Results.KUnd;
charge      = p.Results.charge*1e-12;
girder      = p.Results.girder;
slit        = p.Results.slit*1e-3;
lambdaUnd   = p.Results.lambdaUnd*1e-3;
ESpread     = p.Results.ESpread*1e-4;
yag         = p.Results.yag;
tHandle     = p.Results.tableHandle;
EHarm       = p.Results.EHarm;
eV          = p.Results.eV;
TDist       = p.Results.TDist;
spectrum    = p.Results.spectrum;

% Check optional inputs.
GeV = GeV(1);
if GeV <= 0 || GeV > 50 || isnan(GeV)
    GeV = 13.64;
end

if charge <= 0 || charge > 1e-7
    charge = 250e-12;
end

if lambdaUnd <= 0 || lambdaUnd > 1
    lambdaUnd = 0.03;
end
kUnd=2*pi/lambdaUnd;

if girder(1) < 1 || girder(1) > 33
    girder(1) = 1;
end
if girder(2) < girder(1) || girder(2) > 33
    girder(2) = girder(1);
end
NGirder = girder(2)-girder(1)+1;
nUnd = 113;	     % Periods per girder
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

thetaMaxG = zeros(1,NGirder);
for gird = girder(1):girder(2)
    g = gird-girder(1)+1;
    thetaMaxG(g) = min(sqrt(max(slit(1:2).^2)+max(slit(3:4).^2))...
                  /(zDev(35)-zDev(gird)),...
           slit(5)/(zDev(36)-zDev(gird)));
end

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

% If there's a YAG screen, read the YAG attenuation length (in a table
% giving log10(eV)vs log10(um))
if yag > 0
    absorb = load('YagAbsorptionLength.txt','-ascii');
    yagConversion = 0.008/qe;  % 550-nm photons per joule lost (8 per keV)
end

gamma0     = GeV*qe*1e9/(me*c^2);
gammaStar0 = zeros(1,NGirder);
eV1axis0   = zeros(1,NGirder);
for gird = girder(1):girder(2)
    g = gird-girder(1)+1;
    gammaStar0(g) = gamma0/sqrt(1+0.5*KUnd(g)^2);
    eV1axis0(g)   = 2*hbar*c*kUnd*gammaStar0(g)^2/qe;
end

close all

rMax   = (zDev(38)-zDev(girder(2)))*thetaMaxG(NGirder);
Nr     = 100;
dr     = min(20e-6,max(1e-6,rMax/Nr));
Nr     = ceil(rMax/dr);
dr     = rMax/Nr;
radius = (1:Nr)*dr;

Nphi   = 120;
dphi   = 2*pi/Nphi;
phi    = (0:Nphi-1)*dphi;

NeV     = 1000;
eV1mean = mean(eV1axis0);
eVWidth = 15/nUnd;
eV1min  = (1-eVWidth)*min(eV1axis0./(1+(gammaStar0.*thetaMaxG).^2));
eV1max  = (1+eVWidth)*max(eV1axis0);
deV     = (eV1max-eV1min)/NeV;
NeVUp   = ceil((eV1max-eV1mean)/deV);
NeVDown = ceil((eV1mean-eV1min)/deV);
eV1min  = eV1mean-deV*NeVDown;
NeV     = NeVUp + NeVDown + 1;

NTerms = 20;
eUnd = nUnd*hbar*kUnd/(sqrt(2*pi)*eps0);
fUnd = (2*charge/(hbar*mu0*c))*deV/NE;

FigWidth   = 1260;
FigHeight  = 630;
border     = 90;
offsetStep = 15;
offsetX = 10;
offsetY = 150;
offsetXs = 150;
offsetYs = 250;
colorBarWidth = 70;
imgSize = FigHeight-2*border;
xPts = 1e3*radius'*cos(phi);
yPts = 1e3*radius'*sin(phi);

blanks = '                    ';
str1  = char(32*ones(harmonic(2)-harmonic(1)+1, 8));
table = char(32*ones(harmonic(2)-harmonic(1)+4,20));
table(1,:) = 'Harmonic        nJ  ';
table(2,:) = 'Both Polarizations  ';
for harm = harmonic(1):harmonic(2)
    h = harm-harmonic(1)+1;
    s1 = [blanks,num2str(harm)];
    str1(h,:) = s1(length(s1)-7:length(s1));
end

if sum(EHarm) == 0
    EHarm = zeros(1,NHarm);
    TDist = zeros(Nr,Nphi,NHarm);
    spectRMS = zeros(1,NHarm);
    eV    = zeros(NHarm,NeV);
    if yag <= 0
        spectrum = zeros(NHarm,NeV);
    end
end

%-----------------------------------------------------------------
for harm = harmonic(1):harmonic(2)
    h = harm-harmonic(1)+1;
    if EHarm(h) == 0
        disp(['Harmonic ',num2str(harm)])
        eV(h,:) = eV1min*harm+(0:deV*harm:(NeV-1)*deV*harm);
        if yag > 0
            attn = 10.^interp1(absorb(:,1),absorb(:,2),log10(eV(h,:)),'spline');
            loss = (1-exp(-yag./attn))*yagConversion;
        end
        s2 = 'Calculating';
        table(h+2,:) = [str1(h,:),' ',s2];
       
        % Find the distribution in polar coordinates r and phi
        % on the Direct Imager.
        for m = 1:Nr
            if tHandle
                s2 = ['Radius ',num2str(m),' of ',num2str(Nr),blanks];
                table(h+3,:) = s2(1:size(table,2));
                set(tHandle,'String',table)
                pause(0.01)
            end
            if mod(m,10) == 0
                disp(['Calculating radius ',num2str(m),' of ',num2str(Nr)])
            end
            for n = 1:Nphi
                for nE = 1:NE
                    Ex = complex(zeros(NeV,1,'double'));
                    Ey = Ex;
                    % Sum the electric field emitted by one electron
                    % over all girders.
                    for gird = girder(1):girder(2)
                        thetaG = radius(m)/(zDev(38)-zDev(gird));
                        xi  = thetaG*cos(phi(n));
                        psi = thetaG*sin(phi(n));
                        xS = xi *(zDev(35)-zDev(gird));
                        yS = psi*(zDev(35)-zDev(gird));
                        if ~((slit(1) < xS || slit(2) > xS || ...
                              slit(3) < yS || slit(4) > yS || ...
                              slit(5) < thetaG*(zDev(36)-zDev(gird))))
                            g = gird-girder(1)+1;
                            gamtheta = 1+(gamma0*ETweak(nE)*thetaG)^2;
                            % Length of breaks between girders
                            LBreaks = (zDev(gird)-zDev(girder(1)))-(g-1)*LGirder;
                            LBreaksScaled = LBreaks*gamtheta/(gamtheta+KUnd(g)^2/2);
                            phaseFactor = 2*pi*nUnd*harm*(g-1)+kUnd*LBreaksScaled;
                            gammaStar  = gammaStar0(g)*ETweak(nE);
                            eV1axis    =   eV1axis0(g)*ETweak(nE)^2;
                            gammatheta = 1+(gammaStar*thetaG)^2;
                            eV1  = eV1axis/gammatheta;
                            aUnd = 0.25*KUndStar(g)^2/gammatheta;
                            bUnd = 2*KUndStar(g)*gammaStar*xi/gammatheta;
                            gUnd = gammatheta^2*...
                                sqrt(radius(m)^2+(zDev(38)-zDev(gird))^2);
                            dUnd = 1i^(harm+1)*harm*eUnd*gammaStar^3;
                            amplFactor = dUnd/(eV1*gUnd);
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
                            bessx = real(2*bess1*gammaStar*xi-bess2*KUndStar(g));
                            bessy = real(2*bess1*gammaStar*psi);
                            if abs(bessx) > 1e-9 || abs(bessy) > 1e-9
                                j1 = min(NeV,max(1,...
                                     floor((eV1*(1-eVWidth)-eV1min)/deV+1)));
                                j2 = min(NeV,max(1,...
                                      ceil((eV1*(1+eVWidth)-eV1min)/deV+1)));
                                for j = j1:j2
                                    sincarg = (eV(h,j)/eV1-harm)*pi*nUnd;
                                    if sincarg ~= 0
                                        sinc = sin(sincarg)/sincarg;
                                    else
                                        sinc = 1;
                                    end
                                    T = sinc*amplFactor*exp(-1i*phaseFactor*eV(h,j)/eV1);
                                    Ex(j) = Ex(j) + T*bessx;
                                    Ey(j) = Ey(j) + T*bessy;
                                end
                            end
                        end
                    end
                    if yag <= 0
                        TDist(m,n,h) = TDist(m,n,h) + sum(abs(Ex).^2+abs(Ey).^2);
                        spectrum(h,:) = spectrum(h,:) + radius(m)*(abs(Ex).^2+abs(Ey).^2)';
                    else
                        TDist(m,n,h) = TDist(m,n,h) + loss*(abs(Ex).^2+abs(Ey).^2);
                    end
                end
            end
        end
        TDist(:,:,h) = TDist(:,:,h)*fUnd*harm;
        if yag <= 0
            EHarm(h) = sum(radius*TDist(:,:,h))*dr*dphi;
            spectrum(h,:) = spectrum(h,:)*dr*dphi*fUnd/(deV*harm);
        end
    end

    if yag <= 0
        spectRMS(h) = sqrt(eV(h,:).^2*spectrum(h,:)'/sum(spectrum(h,:))...
                        - (eV(h,:)*spectrum(h,:)'/sum(spectrum(h,:)))^2);
        s2 = [blanks,num2str(EHarm(h)*1e9,'%10.5g')];
        s2 = s2(length(s2)-10:length(s2));
        if tHandle
            table(h+2,:) = [str1(h,:),' ',s2];
            table(h+3,:) = blanks;
            set(tHandle,'String',table)
            pause(0.01)
        end

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
                    if TDist(m1,n1,h) == 0 && mod(n,1) < 0.5
                        n2 = n1;
                    else
                        n1 = n2;
                    end
                    if TDist(m1,n2,h) == 0 && mod(n,1) > 0.5
                        n1 = n2;
                    else
                        n2 = n1;
                    end
                    if TDist(m2,n1,h) == 0 && mod(m,1) > 0.5
                        m1 = m2;
                    else
                        m2 = m1;
                    end
                    if TDist(m3,n2,h) == 0 && mod(m,1) > 0.5
                        m1 = m3;
                    else
                        m3 = m1;
                    end
                    img(ny,nx) = TDist(m1,n1,h)*(1-m+m1)*(1-n+n1)+...
                                 TDist(m2,n1,h)*  (m-m1)*(1-n+n1)+...
                                 TDist(m1,n2,h)*(1-m+m1)*  (n-n1)+...
                                 TDist(m3,n2,h)*  (m-m1)*  (n-n1);
                end
            end
        end

        % Figure position = [left, bottom, width, height]
        figure('Name',['Intensity on Direct Imager for Harmonic ',...
            num2str(harm)],'Position',[offsetX,offsetY,FigWidth,FigHeight])
        offsetX = offsetX + offsetStep;
        offsetY = offsetY - offsetStep;
        subplot(1,2,1)
        set(gca,'Units','pixels','Position',...
            [border,border,FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
        imagesc([-radius(Nr) radius(Nr)]*1000,[radius(Nr) -radius(Nr)]*1000,img)
        colorbar
        title([num2str(EHarm(h)*1e6,'%8.3g'),...
            ' \muJ (unpolarized) on Direct Imager in Harmonic ',num2str(harm)])
        xlabel('Horizontal Position x (mm)')
        ylabel('Vertical Position y (mm)')

        subplot(1,2,2)
        set(gca,'Units','pixels','Position',...
            [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
        plot([ xPts(Nr:-1:1,round(Nphi/2+1));     xPts(:,   1)],...
             [TDist(Nr:-1:1,round(Nphi/2+1),h);  TDist(:,1,h)]*1e3,...
             [ yPts(Nr:-1:1,round(3*Nphi/4+1));   yPts(:,   round(Nphi/4+1))],...
             [TDist(Nr:-1:1,round(3*Nphi/4+1),h);TDist(:,round(Nphi/4+1),h)]*1e3)
        title('Intensity on x and y Axes')
        xlabel('x or y Position (mm)')
        ylabel('Energy (nJ/mm^2)')
        legend(['x';'y'],'Location','West')
        drawnow
        
        figure('Name',['Spectrum on Direct Imager for Harmonic ',...
            num2str(harm)],'Position',[offsetXs,offsetYs,FigWidth/2,FigHeight])
        offsetXs = offsetXs + offsetStep;
        offsetYs = offsetYs - offsetStep;
        set(gca,'Units','pixels','Position',...
            [border,border,FigWidth/2-2*border,FigHeight-2*border])
        plot(eV(h,:),spectrum(h,:)*1e9)
        xlabel('Photon Energy (eV)')
        ylabel('Spectral Intensity (nJ/eV)')
        title(['RMS Spectral Width = ',num2str(spectRMS(h),'%9.4g'),' eV'])
        drawnow
    
    else
        s2 = 'Done       ';
        if tHandle
            table(h+2,:) = [str1(h,:),' ',s2];
            table(h+3,:) = blanks;
            set(tHandle,'String',table)
            pause(0.01)
        end
    end
end
%-----------------------------------------------------------------

if yag <= 0
    s2 = [blanks,num2str(sum(EHarm*1e9),'%10.5g')];
    s2 = s2(length(s2)-10:length(s2));
    if tHandle
        table(h+3,:) = ['   Total',' ',s2];
        set(tHandle,'String',table)
        pause(0.01)
    end
    disp('Harmonic  Energy   Spectrum')
    disp('           (uJ)    RMS (eV)')
    disp(num2str([harmonic(1):harmonic(2); EHarm*1e6; spectRMS]'))
    if harmonic(2) > harmonic(1)
        disp(['Sum   ',num2str(sum(EHarm)*1e6)])
        figure('Name',['Spontaneous on Direct Imager in Harmonics ',...
            num2str(harmonic(1)),' to ',num2str(harmonic(2))],...
            'Position',[offsetX,offsetY,FigWidth/2,FigHeight])
        set(gca,'Units','pixels','Position',...
            [border,border,FigWidth/2-2*border,FigHeight-2*border])
        plot(harmonic(1):harmonic(2),EHarm(1,:)*1e6)
        xlabel('Harmonic Number h')
        ylabel('Energy in Harmonic (\muJ)')
        drawnow
    end
    
else
    % Plot YAG image combining all harmonics that were calculated
    CDist = sum(TDist,3);
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
                if CDist(m1,n1) == 0 && mod(n,1) < 0.5
                    n2 = n1;
                else
                    n1 = n2;
                end
                if CDist(m1,n2) == 0 && mod(n,1) > 0.5
                    n1 = n2;
                else
                    n2 = n1;
                end
                if CDist(m2,n1) == 0 && mod(m,1) > 0.5
                    m1 = m2;
                else
                    m2 = m1;
                end
                if CDist(m3,n2) == 0 && mod(m,1) > 0.5
                    m1 = m3;
                else
                    m3 = m1;
                end
                img(ny,nx) = CDist(m1,n1)*(1-m+m1)*(1-n+n1)+...
                             CDist(m2,n1)*  (m-m1)*(1-n+n1)+...
                             CDist(m1,n2)*(1-m+m1)*  (n-n1)+...
                             CDist(m3,n2)*  (m-m1)*  (n-n1);
            end
        end
    end

    % Figure position = [left, bottom, width, height]
    figure('Name',[num2str(yag),'-um YAG in Direct Imager for Harmonics ',...
        num2str(harmonic(1)),' to ',num2str(harmonic(2))],...
        'Position',[offsetX,offsetY,FigWidth,FigHeight])
    subplot(1,2,1)
    set(gca,'Units','pixels','Position',...
        [border,border,FigWidth/2-2*border+colorBarWidth,FigHeight-2*border])
    imagesc([-radius(Nr) radius(Nr)]*1000,[radius(Nr) -radius(Nr)]*1000,img)
    colorbar
    title([num2str(yag),'-um YAG image for Harmonics ', num2str(harmonic(1)),...
        ' to ',num2str(harmonic(2))])
    xlabel('Horizontal Position x (mm)')
    ylabel('Vertical Position y (mm)')

    subplot(1,2,2)
    set(gca,'Units','pixels','Position',...
        [FigWidth/2+border,border,FigWidth/2-2*border,FigHeight-2*border])
    plot([ xPts(Nr:-1:1,round(Nphi/2+1));     xPts(:,   1)],...
         [CDist(Nr:-1:1,round(Nphi/2+1));  CDist(:,1)]*1e-6,...
         [ yPts(Nr:-1:1,round(3*Nphi/4+1));   yPts(:,   round(Nphi/4+1))],...
         [CDist(Nr:-1:1,round(3*Nphi/4+1));CDist(:,round(Nphi/4+1))]*1e-6)
    title('Intensity on x and y Axes')
    xlabel('x or y Position (mm)')
    ylabel('Scintillator Photons per mm^2')
    legend(['x';'y'],'Location','West')
    drawnow
end
end