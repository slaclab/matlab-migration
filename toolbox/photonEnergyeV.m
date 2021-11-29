function  eV = photonEnergyeV(beamline,~, time)
%
% Examples:
% eV = photonEnergyeV()
% eV = photonEnergyeV('SXR')
% eV = photonEnergyeV('HXR')
% eV = photonEnergyeV('SXR' or 'HXR', 1 )
% eV = photonEnergyeV('SXR' or 'HXR', 1, '02-Oct-2020 22:00:00')
%
% If no input arguments are given it will get input from the current
% machine and return an estimate of the fundamental HXR SASE photon energy
% in eV. It will write that value in 'SIOC:SYS0:ML00:AO627'.
%
% If exactly one argument is given and is 'SXR' it will return photon
% energy for the SXR line. % It will write that value in
% 'SIOC:SYS0:ML00:AO628'.
%
% If the one argument is given and is anything but 'SXR', it
% defaults back to the HXR line.
%
% If there are exactly two arguments, various corrections and intermediate
% energies for the selected beamline are displayed in the command window.
% The second argument could be anything. 1 works.
%
% If there are exactly three arguments, the third must be a time in the
% datestr format e.g. time = '03-Oct-2020 23:00'. The program will attempt
% look up the historical values for various machine functions and calculate
% and display the photon energy that it would predict for the machine at
% that time using the current (not historical) values for xStatic
% variables. This option is especially useful for calibration purposes.
%
% Partially updated for LCLS2. Only handles Cu beams. 8/1/2020
%
%
% As of 7/22/20 it needs to be calibrated as there is a new undulator
%
% The photon energy returned is the peak of the SASE spectrum. It is
% assumed to be determined by the K and beam energy of the first active
% undulator. The beam energy is determined from dump bend magnets and a
% number of corrections...
% First the beam energy at DL2 is estimated based on the bend magnets,
% horizontal orbit, correctors settings, and known static offsets. Then the
% energy loss going from DL2 to the first active segment due to wakefields
% and spontaneous radation is calculated and subtracted from the DL2
% corrected energy to get the energy at the first active segment.
%
% Fluctuation about this photon energy can be computed from an approximate
% value of the dispersion in DL2 and the BPM readings in DL2.

if nargin==0
    beamline = 'HXR';
end
if nargin==1
    if ~strcmp(beamline,'SXR')
        beamline = 'HXR'; % default back to HXR
    end
end

if nargin>=2
    display_output = 1;
else
    display_output=0; % default
end

if nargin==3
    display('Using historical data')
    config = configRecall(time);
end

if nargin~=3 % Get current machine data
    
    % Set the number of points to average
    npts = 500; % shots to average, max 2796
    
    % Read good synchronous data
    dataSynch = dataRead(npts, beamline);
    
    % Get the present peak current [A]
    peakCurrent = dataSynch(1,:);
    
    % Get present charge in pC
    if nargin~=3
        chargenC = lcaGet('BPMS:SYS0:2:QANN'); % expected charge after BC1 charge cutting
    else
        chargenC = config.electron.chargeBC1_nC;
    end
    charge = chargenC*1000; % charge in pC 2/17/12
    
    % Get mean present beam position in DL2 and write to epics PVs
    
    if strcmp(beamline,'SXR')
        xltu1 = mean(dataSynch(2,:) ); % 235
        xltu2 = mean(dataSynch(3,:) ) ; % 370
        lcaPut({'SIOC:SYS0:ML02:AO170'; 'SIOC:SYS0:ML02:AO171'},[ xltu1; xltu2]);
    else
        xltu1 = mean(dataSynch(2,:) ); % 250
        xltu2 = mean(dataSynch(3,:) ) ; % 450
        lcaPut({'SIOC:SYS0:ML02:AO040'; 'SIOC:SYS0:ML02:AO041'},[ xltu1; xltu2] );
    end
    
    % Get the bend energy
    if strcmp(beamline, 'SXR')
        bendEnergyGeV = lcaGetSmart('BEND:DMPS:400:BDES'); % use dump bend setting
    else
        bendEnergyGeV = lcaGetSmart('BEND:DMPH:400:BDES'); % use dump bend setting
    end
    
    
    % Get the orbit in the dogleg due to horizontal correctors
    xcor = xcorDL2correction( beamline);
    
    % Get undulator  K values  
    if strcmp(beamline, 'SXR')
        Kpv = meme_names('name', 'USEG:UNDS%:KAct');
    else
        Kpv = meme_names('name', 'USEG:UNDH%:KAct');
    end
    Kprofile = lcaGetSmart(Kpv);
     
else % use historical data
    peakCurrent = config.electron.BC2peakCurrentSetpoint;
    charge = 1000*config.electron.chargeBC1_nC;
    if strcmp(beamline,'SXR')
        bendEnergyGeV = config.electron.beamEnergyS;
        xcor = xcorDL2correction(beamline, config.xcorDL2SXR.BACT, bendEnergyGeV );
        xltu1 = config.electron.xltu235;
        xltu2 = config.electron.xltu370;
        Kprofile = config.undulator.KSprofile;
    else
        bendEnergyGeV = config.electron.beamEnergyH;
        xcor = xcorDL2correction(beamline, config.xcorDL2HXR.BACT, bendEnergyGeV );
        xltu1 = config.electron.xltu250;
        xltu2 = config.electron.xltu450;
        Kprofile = config.undulator.KHprofile;
    end
    
end

% Get the static corrections for static magnetic fields, bpm offsets etc.
xStatic = xOffsetScaling(bendEnergyGeV, beamline);

% Calculate the corrected beam energy in DL2
if strcmp(beamline,'HXR')
    DL2energyGeV = energyCorrectDL2(beamline, xltu1, xltu2 -xcor -xStatic, bendEnergyGeV);
else
    DL2energyGeV = energyCorrectDL2(beamline, xltu1, xltu2 -xcor -xStatic, bendEnergyGeV);
end

if display_output
    display('  ');
    display(['Beam at Dogleg         ' num2str(DL2energyGeV,5)  ' GeV' ]);
    display('  ');
    if strcmp(beamline,'HXR')
        display(['BYD1 bend energy        ' num2str(bendEnergyGeV,4) ' GeV']);
    end
    if strcmp(beamline,'SXR')
        display(['BYD1B bend energy        ' num2str(bendEnergyGeV,4) ' GeV']);
    end
    display('  ');
    display(['  XCOR BPM correction  ' num2str(xcor, '%5.2f')          ' mm' ]);
    display(['  xStatic correction   ' num2str(xStatic, '%5.2f')       ' mm' ] );
    display(['  First BPM Reading    ' num2str(xltu1, '%5.2f')       ' mm' ] );
    display(['  Second BPM Reading   ' num2str(xltu2, '%5.2f')       ' mm' ] );
    display('  ');
end




% Beam energy at start of undulator chambers
GeVundStart = DL2energyGeV - LTUwakeLoss(mean(peakCurrent), display_output)/1000;

% Wakefield loss from undulator chambers without undulator magnets
if strcmp(beamline, 'HXR')
    nChambersNoMagnet = 10; % confirmed with H-D Nuhn 8/20/20. 10 chambers installed without undulators
end
if strcmp(beamline, 'SXR')
    nChambersNoMagnet = 0; % need to verify
end
eLossSegmentWakefield =  wakefield(beamline, mean(peakCurrent), charge, display_output);
eLossUndNoMagnet = nChambersNoMagnet * eLossSegmentWakefield; % total wake loss from unused chambers MeV

% SR Energy loss in each installed segment
eLossSegmentSR = SRloss(beamline, DL2energyGeV, Kprofile, display_output);

% Combined energy loss in each segment, SR + wake
energyLossSegment = eLossSegmentWakefield + eLossSegmentSR;

% Net energy profile
energyLossSegment(end) = [];% trim for cumsum
energyProfile(1) = GeVundStart - eLossUndNoMagnet/1000 ; % GeV
energyProfile(2:(length(Kprofile))) =  energyProfile(1) - cumsum(energyLossSegment)/1000;

% Option display
nChambers = nChambersNoMagnet + length(Kprofile);
eLossUndulatorWakeTotal = nChambers * mean(eLossSegmentWakefield);
eLossUndulatorTotal = eLossUndulatorWakeTotal + sum(eLossSegmentSR);
if display_output
    display([ '  Wake total           ' num2str(eLossUndulatorWakeTotal,3) '     MeV']);
    display([ '  Undulator total      ' num2str( eLossUndulatorTotal,2 ) '    MeV']);
end


%
% Calculate the SASE photon energy of the first active segment.
%
% Assume SASE photon energy is determined by the K and beam energy at first segment that is
% active.
if strcmp(beamline,'HXR')
    lambdaUndulator = 0.026; % 26 mm period length HXR; LCLSII-3.2-PR-0038-R2
end
if strcmp(beamline,'SXR')
    lambdaUndulator = 0.039; % 26 mm period length SXR; LCLSII-3.2-PR-0038-R2
end

activeSegments = find(Kprofile > 0.1 ); % index to active segments
if isempty(activeSegments) % all have wide open gaps
    eV = 0;
    firstSegment = 1; % for energy profile
else
    firstSegment = activeSegments(1);
    gamma = (energyProfile*1000/0.510990);
    lambdaSASE = (lambdaUndulator ./ ( 2* gamma(firstSegment)^2 ) *...
        (1 + 0.5*Kprofile(firstSegment).^2));
    eV = nm2eV(1e9*lambdaSASE);
end

if display_output  % mainly for debugging,
    display(' ')
    display(['Beam at first segment ', num2str(energyProfile(firstSegment(1))), '  GeV'] );
    display(' ');
    display(['1st harmonic photon energy: ', num2str(eV,6) ' eV']);
    if nargin==3 % Display the archive value
        if strcmp(beamline,'HXR')
            photonEnergy = config.photon.photonEnergyH;
        else
            photonEnergy = config.photon.photonEnergyS;
        end
        display(['Archived photon energy: ', num2str(photonEnergy,6) ' eV']);
    end
else % normal monitoring case
    if strcmp(beamline,'SXR')
        lcaPut('SIOC:SYS0:ML00:AO628', eV); % Use ...AO628 for SXR
    else % HXR
        lcaPut('SIOC:SYS0:ML00:AO627', eV); % Use ...AO627 for HXR
    end
end


function wakeLossPerSegment = wakefield(beamline, peakCurrent, charge, display_output)
% return the wake field induced energy loss per electron per undulator
% segment induced by the undulator vacuum chamber

% Use Nuhn calculation for undulator

if strcmp(beamline, 'HXR')
    segmentLength = 4.012667;% PRD value
end
if strcmp(beamline, 'SXR')
    segmentLength = 4.4;% PRD value
end

compressState = peakCurrent>0;
peakCurrent(peakCurrent< 500) = 500; % Nuhn program gives NaN when current is much below 500 A
peakCurrent(peakCurrent>10000) = 10000;% Nuhn program returns NaN when current is >10000 A
wakeLossPerSegment = segmentLength * 0.001 *...  % Nuhn program also gives wrong sign
    (-1)*util_UndulatorWakeAmplitude(abs(peakCurrent)/1000, charge, compressState);
if display_output
    display( 'Undulator losses    ' );
    if ~isnan(wakeLossPerSegment)
        display([ '  Peak current         ' num2str(mean(peakCurrent),4) '    A'] );
    end
    display([ '  Wake loss/segment    ' num2str(mean(wakeLossPerSegment),2) '    MeV']);
    
end

function LTUwakeLoss = LTUwakeLoss(peakCurrent, display_output)
% Return the MeV per electron lost to wakes in the LTU.

% peakCurrent is in A
% MeV loss is based on quadratic fit of measured data
% undercompressed (uc) or overcompressed both ok

% Historical calibrations ...
% % Use measured FEL centroid data from 9/8/10 to estimate LTU MeV loss
% coef_uc = -.00074; % - relative shift in photon energy in ppt per A of peak current at 13.6 GeV
% coef_oc = +0.00221;%
% % Data taken 10/29/13 using HXSSS
% %coef_uc = -1000*0.00639/8300; % - relative shift in photon energy in ppt per A of peak current at 13.6 GeV
% coef_oc = -1000*0.0274/8300;%
% p_uc = [-1.3985e-09 -2.5802e-06 -0.0051 12.3337];% undercompressed polynomial, Data taken 10-29-13 22:00

% Calibration in use
p_oc =     [-0.0230 -23.8835]; % overcompressed, Data taken 10-29-13 22:00
p_uc =     [4.727e-6 -0.008918 0.07257];% Data taken Oct 29, 2018. see calibrationOct2018.m.
% currentRef = 3500;% used for fitting  oc cases
currentRef = 0;% used for fitting both oc and uc cases
% eV_ref = 8200;% Real photon energy when calibration was taken.
eV_ref = 9566;% Real photon energy when calibration was taken. Oct 29, 2018
% energyCalibration  = 13.600; % Machine energy GeV when the calibration data was taken.
energyCalibration  = 14.646; % Machine energy GeV when the calibration data was taken. Oct 29, 2018

if abs(peakCurrent) > 12e3
    peakCurrent = 3e3*sign(peakCurrent);
end
if peakCurrent > 0 % uc case
    delta_eV = polyval(p_uc, peakCurrent);
else % oc case
    delta_eV = polyval(p_oc, peakCurrent-currentRef);
end
LTUwakeLoss = 0.5 * 1000* energyCalibration * delta_eV/eV_ref;

if display_output
    display(['LTU wake loss total    ', num2str(LTUwakeLoss,2) '     MeV']);
    display('  ');
end

function SRlossMeV = SRloss(beamline, electronEnergyGeV, Kprofile, display_output)
%
% returns energy loss in MeV for each segment from spontaneous radiation
%

% Reference calculation used in XOP2.11 (xurgent)
KrefHXR = 2.44;
GeVrefHXR = 4; % GeV
Iref =  0.3e-9*100000; % [A]
Pref = 33.35; % Power emitted in calculation [W]
periodsRef  = 4185;% Periods in calculation
lambdaRef = .030; % undulator period [m]

if strcmp(beamline,'HXR')
    periodsPerSegment = 130; % LCLSII-3.2-PR-0038-R2
    lambda = 0.026;
end
if strcmp(beamline, 'SXR')
    periodsPerSegment = 87; % LCLSII-3.2-PR-0038-R2
    lambda = 0.039;
end
nSegments = length(Kprofile); % for totaling up SR losses

% get loss by scaling from reference calculation
% see https://xdb.lbl.gov/Section2/Sec_2-1.html K.Kim formula
SRlossMeV = 1e-6 * (periodsPerSegment/periodsRef) * (Pref/Iref) *...
    (Kprofile./KrefHXR).^2 * (electronEnergyGeV/GeVrefHXR)^2 * lambdaRef/lambda;

SRlossMeVaverage = mean(SRlossMeV);
if display_output
    display(['  SR loss/segment      ', num2str(SRlossMeVaverage,2) '    MeV']);
    display(['  SR total             ', num2str(nSegments *SRlossMeVaverage,3) '    MeV']);
end


function [dataSynchGood pvList] = dataRead(npts, beamline)
% Gets all synchronous data,  cleans up for missing stuff, selects last
% npts

if strcmp(beamline,'SXR')
    pvList = {'BLEN:LI24:886:BIMAXHSTBR';
        'BPMS:LTUS:235:XHSTBR'; 'BPMS:LTUS:370:XHSTBR'}; %  235=BPMDL13, 370=BPMDL17
else
    pvList = {'BLEN:LI24:886:BIMAXHSTBR';
        'BPMS:LTUH:250:XHSTBR'; 'BPMS:LTUH:450:XHSTBR'};%  250=BPMDL1, 450=BPMDL3
end
buffer = lcaGet(pvList); % get all data

% If bykick was on, fake bpm450x data by making it equal to bpm250x
BYKickOnPts = (buffer(3,:) == 0 ) & (buffer(2,:) ~= 0);
buffer(3,BYKickOnPts) = buffer(2,BYKickOnPts);

% remove bad data: zero or negative signals, very large currents, NaNs
for q = 1:length(pvList)
    bad = (buffer(q,:) == 0) | buffer(1,:) > 2e4 | buffer(1,:) < 0 | isnan(buffer(q,:));
    goodBuffer=buffer;
    goodBuffer(:,bad) = [];
    if isempty(goodBuffer)
        break
    end
end
if isempty(goodBuffer) % there are no good points so return best guess
    iFeedback = lcaGet('FBCK:FB04:LG01:S5DES');  % peak current set-point
    peakCurrentLimit = 4000; %  Sometimes feedback is set arbitrarily high (150000A)!) 4000 is best WAG
    iPeakBestGuess = min(iFeedback, peakCurrentLimit);
    dataSynch = [iPeakBestGuess;0;0];
else
    dataSynch = goodBuffer;
end
if size(dataSynch)<npts % no or too little data
    npts = size(dataSynch);
    npts = npts(2);
end

% Return the most recent averaged dogleg2 bpm x readings from buffered data
dataSynchGood =dataSynch(1:length(pvList), end - npts+1:end);

function xStatic = xOffsetScaling(GeV, beamline)
% Return the static offset that scales with energy GeV as xStatic =  a + b energyHard/GeV

% Update these numbers when good photon energy calibrations are available.
% While running at a known photon energy, edit this document and
% find the xStatic value needed so this function generates the correct
% photon energy. Do this for two different beam energies to obtain the
% xStaticHard and xStaticSoft value to use to calculate a and b.

% GeV is the energy of the beam in DL2 and should include Vernier effect.
% Note Ni edge is at 8332.8 eV
% Kmono passband max at 8193.6 eV, (Bionta monochrometer on primary set)

if strcmp(beamline,'HXR')
    %     xStatic = -1.75; % match 7/12/10 19:05 778.1 SXR quotation: user measured R12
    %     xStatic = -2.25; % match 10/5/10 22:11 sxr Ni L edge data; uses measured R12
    %     xStatic = -2.0;  % match 1/21/11 7:23 7910 xpp quotation; uses measured R12
    %     xStatic = -1.97; %  match 1/31/11 11:49 7908 xpp quotation: uses measured R12
    %     xStatic = -2.04; % match 2/10/11 16:18 and 16:27 sxr quotation (calc 0.28% too high)
    %     xStatic = -1.87; % match 10-29-13 22:10 Ni edge scan data. see photonEnergyeVCalibrate.m
    
    % Energy dependent constants JJW 2/25/14
    %     xStaticHard = -1.5; % 2-25-14 17:20:13 based on Ni edge 8333.
    %     energyHard = 13.514; % 2-25-14 based on Ni edge 8333.
    %
    %     xStaticHard = 0.38; % 10-20-14 based on Diling monochromator at XPP
    %     energyHard = 14.464; % 10-20-14 bend energy at 9.5 keV
    %
    %     xStaticHard = 0.1; % 10-21-14 based on Diling Fe edge.
    %     energyHard = 12.56; % 10-21-14 bend energy
    %
    %     xStaticSoft = -2.6; % gadolinium M5 edge 867.1 eV 2/26/14 21:55, Krzywinski et. al.
    %     energySoft = 5.125;  % gadolinium M5 edge 2/26/14 21:55, Krzywinski et. al.
    
    xStaticSoft = -0.9; % O2 reasonance 531 eV, SXR experiment 12/8/14
    energySoft = 3.40; % peak SASE 2 eV below 531 eV
    
    %     xStaticHard = 0.76; % Nov 4, 2018 based on HXS looking at Ni edge (high bunch current)
    %     energyHard = 13.5318; % 11-04-18 bend energy, new uc polynomial
    
%     xStaticHard = -0.4; % Aug 20, 23:00 XPP unqualified report 8.269 keV while PV said 8.3392
%     energyHard = 8.9825; % first measurement after new HXR and SXR lines
    
    xStaticHard = 1.6; % Diling Zhu reports they measured 9.831 keV during weekend of 10/3/20
    energyHard = 10.679; % GeV during weekend
    
end

if strcmp(beamline,'SXR')
    
    % Energy dependent constants
    xStaticHard = 0.76; % no data as of 8/18/20. Set equal to HXR value
    energyHard = 13.5318;
    
    xStaticSoft = -0.9; % no data as of 8/18/20. Set equal to HXR value
    energySoft = 3.40;
end

% Apply scaling
b = ( xStaticHard - xStaticSoft) / ( 1 - energyHard/energySoft);
a = xStaticHard - b;

xStatic = a + b * ( energyHard/GeV);
%xStatic = -0.9 % for finding and changing calibrations




