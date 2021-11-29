function [F,CorrectedEnergy] =  kmDataSimulator(EnergySetPoints,Segment,Position,method)
%
% [F,CorrectedEnergy] =  kmDataSimulator(EnergySetPoints,Segment,Position,method)
%
% Simulates xray signal produced by one or two segments
%
% EnergySetPoints is  beam energy setting in GeV at each data point
% Position is horizontal positon(s) of the segment(s) in mm
% Segment is the segment number. Use two numbers for two segments.
% 'method' is either 'One Segment' or 'Two Segment' or 'Energy Calibration'

% Machine Settings
charge = 0.25e-9; %Coulomb
ElectronEnergyJitter = 0.3e-3; %sigma of energy fluctuations
eEnergyRes = 3e-5; %rms uncertainty in energy correction due to bpm res.
RepRate = 30; %Hz

% K Mono settings
MCEnergy = 8193; %transmission energy of monochromator [eV]
BW=0.1; %relative tranmission bandwidth [units of 0.1%] of MC
DetectorDistance = 80; % meters from segment to detector
DetCountsPerPhoton = .01; %of photons actually hitting area of detector
xsize=.00075; %full effective xsize of detector, meters
ysize=.00075; %full effective ysize of detector
% at npts = 25 the flux is 20 percent too high but it runs very fast.
nxpts = 25; %no. integration points
nypts = 25; %no. integration points

% Segment settings
KNominal = 3.4927;
Kerror = 0*KNominal;% Kerror for two segment method. One segment error =0
KTaper = -2.7e-3;% delta K per mm of position change. check 7/23/09
KTest = KNominal+Kerror+KTaper*Position; %for one segment analysis
KTest1 = KNominal; %for two segment analysis (reference seg)
KTest2 = KNominal + Kerror + KTaper*Position; %for two segment analysis (test seg)

segmentGap =.4285; %effective z distance between segments: tune carefully!0.4285;
Periods = 112; %periods in segment
UndPeriod = .03; %meters
NH = 1; %harmonic number

% physical constants
massElectron = 0.511e-3; % GeV
electronCharge = 1.6e-19; %Coulombs
ImpedanceFreeSpace = 377; %ohms
cLight = 2.998e8; %m/s
eV2Wavelength = 1.23984e-6; %meters per eV

%Derived data
AverageCurrent = charge * RepRate;

N = Periods;
I = AverageCurrent;
uMC = MCEnergy;

% Energy calculation
dEnergy = EnergySetPoints*ElectronEnergyJitter.*randn(size(EnergySetPoints));
eEnergy = EnergySetPoints + dEnergy; %true energy
GeV = eEnergy;
gamma = GeV/massElectron;
CorrectedEnergy = eEnergy + EnergySetPoints*eEnergyRes*randn; %corrected (w error) energy
ResonantPhotonEnergy0 = 0.01* 950* eEnergy.^2/((1 +KTest^2/2)*UndPeriod);%on-axis eV
ResonantPhotonWavelength0 = 0.5*(1+0.5*KTest^2)*UndPeriod./gamma.^2;

%Spectrum 
z  = DetectorDistance;
dx = xsize/(nxpts);
dy = xsize/(nypts);
x  = -(xsize-dx)/2; %starting point for integration
y  = -(ysize-dy)/2; %starting point for integration

%integrate over detector area
SF=0;
area=0;
%tic
for ix=1:nxpts 
    for iy=1:nypts 
        switch method
            case 'One Segment'
                dSF = SFD(x,y,z)*1e6*dx*dy/DetectorDistance^2;
            case 'Two Segment'
                dSF = SFD2(x,y,z)*1e6*dx*dy/DetectorDistance^2;
            case 'Energy Calibration'
                dSF = SFD(x,y,z)*1e6*dx*dy/DetectorDistance^2;% use one segment
        end
        
        SF = SF + dSF;
        y = y + dy;
        area = area + dx*dy;
    end
    y = 0;
    x = x + dx;
end

%toc

Fave = SF*BW; %This is average number of photons getting to the detector per s
F = Fave/RepRate; %Photons per bunch at detector
display(max(F));

    function SFD = SFD(x,y,z) %nested function
        % [ph/s/mr^2/0.1%BW] at distance z from one segment with offset from central ray of x,y.

        theta = sqrt(x^2+y^2)/z; %axial angle of observation rel to beam

        %shorthand
        u1_0 = ResonantPhotonEnergy0*(1+0.5*KTest^2)./...
            (1+0.5*KTest^2+(gamma*theta).^2); %off-axis resonant energy

        KFactor = KTest*NH/(1 + KTest^2/2);
        KTerm = 0.25 * NH*KTest^2 /(1 + KTest^2/2);
        BesselFactor = besselj( 0.5*(NH-1), KTerm) - besselj(0.5*(NH+1), KTerm);
        FnK = KFactor^2 * BesselFactor^2;

        %phenomenological expression
        A0 = 1.744e17*N^2*GeV.^2*I*FnK./u1_0;%multiplicative constant
        du_arg = pi * N * (uMC - u1_0)./u1_0;
       
        if (du_arg~=0)
            SFD = A0 .* (sin(du_arg)./du_arg).^2; %SFD pht/s/mr^2/eV
        else
            SFD = A0;
        end
        
    end

    function SFD2 = SFD2(x,y,z) %nested function
        % [ph/s/mr^2/0.1%BW] at distance z from two segments with offset x,y
        %follow ZRH analysis

        ResonantPhotonEnergy1 = 0.01* 950* CorrectedEnergy.^2/((1 +KTest1^2/2)*UndPeriod);%[eV]
        ResonantPhotonEnergy2 = 0.01* 950* CorrectedEnergy.^2/((1 +KTest2^2/2)*UndPeriod);%[eV]
        theta = sqrt(x^2+y^2)/z; %axial angle of observation rel to beam
        u1_0 = ResonantPhotonEnergy1*(1+0.5*KTest1^2)./...
            (1+0.5*KTest1^2+(gamma*theta).^2); %off-axis resonant energy,seg1,[eV]
        u2_0 = ResonantPhotonEnergy2*(1+0.5*KTest2^2)./...
            (1+0.5*KTest2^2+(gamma*theta).^2); %off-axis resonant energy,seg2,[eV]
        xi = 0.5* pi * N * theta^2*UndPeriod*uMC/1.2398e-6;

        phi = (u1_0/1.2398e-6)*pi*segmentGap./gamma.^2;% xray phase change between gaps
        nu1 = pi*N*(uMC - u1_0)./u1_0;
        nu2 = pi*N*(uMC - u2_0)./u2_0;
        term1 = exp(i*(nu1+xi)).*sin(nu1+xi)./(nu1+xi);
        term2 = exp(-i*(nu2+xi) - i.*phi).*sin(nu2+xi)./(nu2+xi);% -1 factor missing, fixed 2009
        FN = abs(term1 + term2).^2;
        SFD2 = FN*7.7223e+03/2.8709e-07; %this is fudge, need to figure out the scale factor

    end



%dFnKdOmega =    1.744e14*Periods^2*GeV.^2*AverageCurrent*FnK;%ph/s/mr^2/0.1%BW
SigmaAngle = (1./gamma)*sqrt((1+KTest^2)/(2*NH*UndPeriod));
ConeDiameter = 2*SigmaAngle*DetectorDistance; %meters

%signal strength
TotalRadiatedPower =(Periods/6)*ImpedanceFreeSpace *AverageCurrent*...
    electronCharge*(2*pi*cLight/UndPeriod)*gamma.^2*KTest^2; %watts
RadiatedEnergyPerBunch = TotalRadiatedPower/RepRate; %J/bunch
TotalPhotonsPerBunch = RadiatedEnergyPerBunch/(electronCharge*...
    ResonantPhotonEnergy0); %assume all at resonant energy
B0 = KTest/(0.934* 100*Periods); %Peak field in Tesla
dPdOmega = 10.84 * B0 * GeV.^4 * AverageCurrent * Periods;%W/mr^2
dPhPerBunchdOmega = (1/RepRate)* dPdOmega / (electronCharge*...
    ResonantPhotonEnergy0); %ph/s/mr^2



end %end of main function
