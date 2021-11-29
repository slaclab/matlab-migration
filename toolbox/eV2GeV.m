function BYDGeV = eV2GeV(photon_eV, enter_parameters, display_output, use_current_bend_des)

%
%   BYDGeV = eV2GeV(photon_eV, enter_parameters, display_output, use_current_bend_des)
%
% Returns an accurate BYD bend energy [GeV] needed to obtain the FEL photon
% energy  "photon_eV" [eV], assuming  undulator Ks, vernier
% setting, and correctors in DL2 will stay at the values in the machine at
% the time this function is called.
%
% Uses buffered BSA data from DL2. Make sure it is not stale.
%
%  photon_eV: Desired Photon Energy (eV)
%  enter_parameters: flag to let user enter some machine parameters, else
%                             get them from live machine.
% display_output: 0 or 1 flag to display calculation details.  
%                        (Default to 1, for display)
% user_current_bedn_des: flag to choose use of current BEND BDES or estimated from
%                         simple eV to GeV formula for self consistency calculation
%                                      

%Original Code by J. Welch, Modified by W. Colocho for user inputs and EDM
%use
if nargin <2, enter_parameters = 0; end
if ~exist('photon_eV','var'), 
    photon_eV = lcaGetSmart('SIOC:SYS0:ML01:AO093'); 
    enter_parameters = 1;
end

if nargin <3, display_output = 1;  end%   set to 1 to do displays, 0 for no display
if nargin <4, use_current_bend_des = 1; end %Default to using BEND value estimated from photon_eV 

% Set empirical offset based on calibration
xStatic = -1.75; % match 7/12/10 19:05 778.1 SXR quotation: user measured R12
xStatic = -2.25; % match 10/5/10 22:11 sxr Ni L edge data; uses measured R12
xStatic = -2.0; % match 1/21/11 7:23 7910 xpp quotation; uses measured R12
xStatic = -1.97; %  match 1/31/11 11:49 7908 xpp quotation: uses measured R12
xStatic = -2.04; % match 2/10/11 16:18 and 16:27 sxr quotation (calc 0.28% too high)
xStatic = -1.7;  % readjust for new LTU loss estimate, (centroid vs Ipeak based on spectral measurements 9/8/10)



% Set the number of buffered BSA readings to average
npts = 500; % shots to average, max 2796

% Get the average bpm readings for DL2
[xltu250, xltu450 ] = bpmDoglegRead(npts, display_output);

% Get the present peak current [A]
 peakCurrent  = peakCurrentRead(npts); 

% Get present charge in pC
charge = 1000*lcaGet('FBCK:BCI0:1:CHRGSP'); 
% Get present  DMP1 Bend BDES
estimatedBendEnergyGeV = 0.14998*sqrt(photon_eV);
bendEnergyGeV = lcaGetSmart('BEND:DMP1:400:BDES');%use bdes for consistency

if enter_parameters
    inptStr = sprintf('Bend Energy\nCurrent: %.3f (GeV)\nEstimated:%.3f (GeV)', bendEnergyGeV, estimatedBendEnergyGeV);
    anwser = inputdlg({'Peak Current (A)', 'Charge (pC)', inptStr}, 'eV2GeV', 3, ...
                  {sprintf('%.0f', peakCurrent), sprintf('%.0f', charge), sprintf('%.3f', estimatedBendEnergyGeV)});
     [peakCurrent, charge, bendEnergyGeV] =  deal(anwser{:});
     peakCurrent = str2double(peakCurrent);
     charge = str2double(charge);
     bendEnergyGeV = str2double(bendEnergyGeV);
else
    if ~use_current_bend_des, bendEnergyGeV = estimatedBendEnergyGeV; end
end
% Calculate the desired beam energy in the first active undulator:
% GeVund
taper = segmentTranslate;
activeSegments = find(taper < 11); % these are active
for q=1:33
    pvKACT{q,1} = sprintf('USEG:UND1:%d50:KACT',q);
end
Kprofile = lcaGetSmart(pvKACT);
GeVund = 13.64 * sqrt(   ( photon_eV/8265.9 ) * ...
    ( (1 + Kprofile( activeSegments(1) )^2 / 2 ) / (1 + 3.5^2/2) )   );

% Calculate the desired beam energy at DL2 given LTU energy loss
LTUwakeLossMeV = LTUwakeLoss(peakCurrent, charge, display_output); % MeV
GeVDL2 =  GeVund + LTUwakeLossMeV/1000; % desired energy at DL2

% Calculate the desired bend energy taking into account static and corrector offsets
xcor_kGm = xcorRead();
xcor = xcorDL2correction(xcor_kGm, bendEnergyGeV); % get present betatron orbit due to correctors btw bpms
DL2energyGeV = energyCorrectDL2(xltu250, xltu450 -xcor -xStatic, bendEnergyGeV); %present real energy at DL2
BYDGeV = GeVDL2 + (bendEnergyGeV - DL2energyGeV); % desired set point for bend magnet

lcaPutSmart('SIOC:SYS0:ML01:AO094',BYDGeV)
if display_output
    display(['Desired Bend energy          ' num2str(BYDGeV)        ' GeV']);
    display(['Desired photon energy        ' num2str(photon_eV)     '  eV']);

    display('  ');
    display(['Present Bend energy          ' num2str(bendEnergyGeV) ' GeV']);
    display(['Present photon energy        ' num2str(photonEnergyeV()) '  eV']);

    display('  ');
    display(['Present DL2 beam energy      ' num2str(DL2energyGeV)  ' GeV']);
    display(['Present LTU wake loss        ' num2str(LTUwakeLossMeV/1000,2)   ' GeV']);
    display('  ');
    display(['  XCOR BPM correction  ' num2str(xcor,    '%5.2f')       ' mm' ]);
    display(['  xStatic correction   ' num2str(xStatic, '%5.2f')       ' mm' ] );
    display(['  250:X BPM Reading    ' num2str(xltu250, '%5.2f')       ' mm' ] );
    display(['  450:X BPM Reading    ' num2str(xltu450, '%5.2f')       ' mm' ] );
    display('  ');

    display('  ');
end




function wakeLossPerSegment = wakefield(peakCurrent, charge, display_output)
% return the wake field induced energy loss per electron per undulator segment

% Use Nuhn calculation for undulator
segmentLength = mean(diff(segmentCenters));% segmentCenters is a CVS'd function
compressState = peakCurrent>0;
if peakCurrent < 500 % Nuhn program gives NaN when current is much below 500 A
    peakCurrent = 500; % Nuhn program also gives wrong sign
end
wakeLossPerSegment = segmentLength * 0.001 *...
    (-1)*util_UndulatorWakeAmplitude(abs(peakCurrent)/1000, charge, compressState);
if display_output
    display([ 'Wake loss/segment    ' num2str(wakeLossPerSegment,2) '    MeV']);
    if isnan(wakeLossPerSegment)
        display([ 'Peak current   ' num2str(peakCurrent) ] );
    end
end

function LTUwakeLossMeV = LTUwakeLoss(peakCurrent, charge, display_output)
% Return the MeV per electron lost to wakes in the LTU.

% peakCurrent is in A

% Add LTU loss per Novohatsky
% LTUfactor = 7.8; % MeV loss for 20 pC 0.5 micron rms bunch length
% peakCurrentRef = 20e-12 * 3e8/0.5e-6/sqrt(2*pi); % Amps of peak current for LTUfactor
% LTUwakeLossMeV = LTUfactor * (peakCurrent/peakCurrentRef);% scale with peak current^2/Q

% Use measured FEL centroid data from 9/8/10 to estimate LTU loss
coef_uc = -.00074; % - relative shift in photon energy in ppt per A of peak current at 13.6 GeV
coef_oc = +0.00221;% 
energyCalibration  = 13.600; % Machine energy GeV when the calibration data was taken.
if peakCurrent > 0 
    LTUwakeLossMeV = -energyCalibration * 0.5 * (coef_uc * peakCurrent); % MeV of loss
else
    LTUwakeLossMeV = -energyCalibration * 0.5 * (coef_oc * peakCurrent);
end


function SRlossPerSegment = SRloss(electronEnergy, display_output)
% returns energy loss per segment [MeV] from spontaneous radiation in MeV
SRlossPerSegment = 0.63 * (electronEnergy/13.64)^2;
if display_output
    display(['SR loss/segment      ', num2str(SRlossPerSegment,2) '    MeV']);
end


function [xltu250Ave, xltu450Ave ] = bpmDoglegRead(npts, display_output)
% Return the present averaged dogleg2 bpm x readings from buffered data

pvBPM = {'BPMS:LTU1:250:XHSTBR'; 'BPMS:LTU1:450:XHSTBR'};
bpms = lcaGet(pvBPM); % gets entire buffer

xltu250 = bpms(1,end - npts-1:end); % the most recent data is at the end of buffer
xltu450 = bpms(2,end - npts-1:end);

% delete missing shots
xltu250 (xltu250 == 0) = [];
xltu450 (xltu450 == 0 ) =[];
xltu250 (isnan(xltu250)) = [];
xltu450 (isnan(xltu450)) = [];
if isempty (xltu250)
    xltu250 = 0;
end
if isempty (xltu450)
    xltu450 = 0;
end

% Return average
xltu250Ave = mean(xltu250);
xltu450Ave = mean(xltu450);


function [peakCurrentAve] = peakCurrentRead(npts)
% Return the present averaged peak current  from buffered data

pvPkI = 'BLEN:LI24:886:BIMAXHSTBR';
buffer = lcaGet(pvPkI);  % gets entire buffer
currents = buffer(1,end - npts-1:end); % the most recent data is at the end of buffer

% delete missing shots
currents (currents == 0) = [];
currents (isnan(currents)) = [];

if isempty (currents)
    currents = 0;
end

% Return average
peakCurrentAve = mean(currents);

function xcor_kGm = xcorRead()
% Get R12s
xcorPV = {     'XCOR:LTU1:288'
                'XCOR:LTU1:348'
                'XCOR:LTU1:388'
                'XCOR:LTU1:448'};

% Get corrector strengths
xcorPVbact = strcat(xcorPV,':BACT');
xcor_kGm = lcaGet(xcorPVbact);
