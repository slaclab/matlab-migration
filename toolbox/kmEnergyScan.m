function [F, correctedEnergy, mainHandles] = kmEnergyScan ( mainHandles)
%
% [F, correctedEnergy, mainHandles] = kmEnergyScan(mainHandles);
%
% Makes one scan of the machine energy over the energy set points and
% returns the "corrected energy",  F, the charge normalized 'flux' signal
% from the selected detector, and possibly modified mainHandles; and
% updates output plot. 
%
% If mainHandles.debug=1, it will take data but not change energy.
%
% Flux is normalized by the TMIT the second dogleg tmit with a factor 1 for
% 0.25 nC of charge.
%
% correctedEnergy is an array of measured energies - one point for each
% signal point.
%
% F is an array of measured "flux" data. The number of points is not fixed
% but depends on whether a BSA signal is chosen or not. The detector that
% supplies the flux data is specified by mainHandles.detector where
% mainHandles is the guidata from the KM main gui figure.
%
% mainHandles must be the handle structure from the main K measurement gui.
%
% The corrected energy and flux data are based on synchronous data at full
% beam rate.
%
% Maximum scan rate is hard coded as one energy step per machine pulse. 
%
% If BSA data is not available for the chosen detector the scan rate is
% limited by turning edef on and as well as the detector. It can be several
% seconds per point.
%
% If mainHandles.angleBumpOn=1  then an angle scan will be performed in
% one segment mode only.

% Basic data and initializations
debug = mainHandles.debug;
etax = .125 ; % [m] design value for dispersion at bpms in dogleg
etay3 = 1.232; %BPMQD
etay4 = 0.708; %BPMDD


qRef = lcaGet(mainHandles.chargePV)*1e-9/ 1.6e-19;% Ref charge for normalization in number of electrons
[bendEnergyGeV,ts] = lcaGetSmart('BEND:DMP1:400:BDES'); %use bdes for consistency
mainHandles.peakCurrentActual = lcaGet('SIOC:SYS0:ML00:AO044');
mainHandles.charge = lcaGet(mainHandles.chargePV); %  nC
correctedEnergy = mainHandles.energySetPoints; % default, change below depending BSA
mainHandles.Fns = zeros( 1, length(mainHandles.energySetPoints) ); %initialize to zero each call
mainHandles.Fbsa = mainHandles.Fns; % initialize 
mainHandles.correctedEnergyNS = mainHandles.Fns; %initialize
bpmxall = zeros(4,0);
xbetaMax = .7;% max beta amp for good data [mm]
bpmTmitLimit = 1e-12/1.6e-19; % ignore point with less than 1 pC

% Check machine conditions and take appropriate actions

    %  warn if MPS is blocking beam
if ~strcmp(mainHandles.detector,'Simulator')  
    TD11status = lcaGet('DUMP:LI21:305:TGT_STS');
    TDUNDstatus = lcaGet('DUMP:LTU1:970:TGT_STS');
    if strcmp(TD11status, 'IN') || strcmp(TDUNDstatus,'IN')
        set (mainHandles.messages, 'String', 'Tune up Dump in Beam')
        display('TD11 is in Beam!');
        pause(2);
    end
end

    % warn if BYKICK is stopping beam
byKickOn = 0; 
byKick = lcaGetSmart('IOC:BSY0:MP01:BYKIK_RATE');% get rate after BYKICK
display(['Rate after BYKICK is ' byKick{1}]);
if strcmp(byKick,'0 Hz') 
    set(mainHandles.messages,'String',[{'NO BEAM!'} {'BYKICK'} ]);
    byKickOn = 1;
end
mainHandles.byKickOn = byKickOn;

     % Obtain rep. rate [Hz]
[sys,accelerator]=getSystem();
rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']); 
if rate == 0
    display('Beam Rate is Zero Hz!');
    set(mainHandles.messages,'String','Beam Rate is Zero Hz!');
    if mainHandles.debug ~=1
        F=0; % to avoid error
        return; % return to kmInitializeNew
    else
        rate = 1;% give some data for debug mode
    end
else
    set(mainHandles.messages,'String',['Rate ' num2str(rate) ' Hz']);
end
waitTime = 1/rate; % pause between energy set points.

%{
% Commented 9/21/2015 H. Loos as 50B1 bend disconnected
    % 50B1/SL2 diversion?
strength = control_magnetGet('B50B1');
if strength>1 % at 13.6 Gev it runs at 7.9 kGm
    display('50B1 is on!');
    set(mainHandles.messages,'String',[{'No Beam in DL2'} {'50B1 is ON!'}] );
    status50B1on = 1;
end
%}

% Prepare BSA variables
pvQ = {'BPMS:IN20:221'};
pvxy(1,1) = {'BPMS:LTU1:250'}; % dog leg
pvxy(2,1) = {'BPMS:LTU1:450'};
pvxy(3,1) = {'BPMS:DMP1:502'}; % dump
pvxy(4,1) = {'BPMS:DMP1:693'};
pvxy(3,1) = {'BPMS:LTU1:250'}; % dogleg (dump is returning NANs)
pvxy(4,1) = {'BPMS:LTU1:450'};
pvs1 = sprintf('%s:XHST%d',pvxy{1,1}, mainHandles.eDefNumber); % dog leg BSA
pvs2 = sprintf('%s:XHST%d',pvxy{2,1}, mainHandles.eDefNumber);
pvs3 = sprintf('%s:YHST%d',pvxy{3,1}, mainHandles.eDefNumber); % dump
pvs4 = sprintf('%s:YHST%d',pvxy{4,1}, mainHandles.eDefNumber);

pvs1tmit = sprintf('%s:TMITHST%d',pvxy{1,1}, mainHandles.eDefNumber);% tmits for dog leg 
pvs2tmit = sprintf('%s:TMITHST%d',pvxy{2,1}, mainHandles.eDefNumber); % for normalizing flux by charge
pvL3FBOnOff(1,1) = {'SIOC:SYS0:ML00:AO296'}; % L3 energy feedback initial state
pvPulseID = sprintf('PATT:SYS0:1:PULSEIDHST%d', mainHandles.eDefNumber); % gives pulseID associated with given eDef

switch mainHandles.detector
    case 'Photodiode'  %'KMON:FEE1:421:ENRC'
        pvBSAdetectorChosen = sprintf([mainHandles.photodiodeChosen 'HST%d'], mainHandles.eDefNumber);
    case 'Gas Detector'
        pvBSAdetectorChosen = sprintf([mainHandles.gasDetectorChosen 'HST%d'], mainHandles.eDefNumber);
    case 'Thermal'
        pvBSAdetectorChosen = sprintf([mainHandles.TEMdataPV 'HST%d'], mainHandles.eDefNumber);
    otherwise
        pvBSAdetectorChosen = sprintf('BPMS:IN20:221:XHST%d', mainHandles.eDefNumber);
end
 
% Deal with feedback
L3FBinitState = lcaGet(pvL3FBOnOff); 
if ~debug
    lcaPut(pvL3FBOnOff,0); % Turn off L3 energy feedback
    pause(.25); % just in case it matters
end

% Get current current L3 energy, average over a few seconds
averageTime = 2; % seconds of time to average Joe's L3 energy number.
averageSamples = ceil(averageTime*rate);
[name, is, PACT, PDES, GOLD, KPHR, AACT, ADES]=control_phaseNames('L3');
pvL3MeV(1,1) =  ADES ;

sumReading = zeros(1,averageSamples);
L3MeVRef = lcaGet(pvL3MeV);
sumReading(1) = L3MeVRef;
if rate~=0
    for q=2:averageSamples
        pause(1/rate);
        sumReading(q) =  lcaGet(pvL3MeV);
    end
end
L3MeVRef = mean(sumReading);

% If simulator selected, return simulated data
if strcmp(mainHandles.detector, 'Simulator')
   set(mainHandles.messages,'String','Scanning Energy');
  [F,correctedEnergy] =... %
    kmDataSimulator(mainHandles.energySetPoints,mainHandles.testSegment,...
    mainHandles.translation(mainHandles.testSegment),mainHandles.method);
  [Etrim, Ftrim] = kmSlopeTrim(correctedEnergy, F);

  [mainHandles.edgeGeV, edgeSlopeF, dFdGeV, Eplot, Fplot] =...
    kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);
  %[edgeSlopeF, mainHandles.edgeGeV, dFdGeV, Fplot,Eplot] = inflectionPoint3( Ftrim, Etrim);

  mainHandles.Fns = F;
  mainHandles.correctedEnergy = correctedEnergy;

  cla(mainHandles.scanAxis);
  plot(mainHandles.scanAxis,...
    correctedEnergy, F,'+',...
    Eplot, Fplot, '-r');
  %plot(mainHandles.scanAxis, correctedEnergy, F,'+');
  ylabel(mainHandles.scanAxis,'Simulated data');
  xlabel(mainHandles.scanAxis,'Measured Energy [GeV]');
  title(mainHandles.scanAxis, ['Spectral edge point at ' num2str(mainHandles.edgeGeV) ' [GeV]' ]);
  
  % angle bump case
  if mainHandles.angleBumpOn
    cla(mainHandles.scanAxis);
    nmax = length(mainHandles.energySetPoints);
    for n=1:nmax
      kmAngleBump(mainHandles.testSegment, mainHandles.angleSetX(n), mainHandles.angleSetY(n),...
        mainHandles.debug);
    end
    mainHandles = angleBumpPlot(mainHandles,n);
  end

  return; % return to kmInitializeNew
end

% Determine if BSA or not BSA data
switch mainHandles.detector
    case 'Simulator'
        BSA = 1;
    case 'YAGXRAY TMIT'
        BSA = 1;
    case 'Photodiode'
        BSA = 1;
    case 'Thermal'
        BSA = 1;
    case 'Gas Detector'
        BSA = 1;
    case 'Dog Leg'
        BSA = 1;
    case 'PR55'
        BSA = 0;
    case 'NFOV'
        BSA = 0;
end


% READ and SCAN
display('Starting to scan energy');
set(mainHandles.messages,'String','Scanning Energy');
eDefOn(mainHandles.eDefNumber); % Start taking orbit data

% Scan energies while continuously updating plots.
pause(6*waitTime); % some time to get eDef started, to avoid eDefCount = 0 cases
for n = 1:length(mainHandles.energySetPoints) % n is the number of energy set pts
    set(mainHandles.scanButton, 'String', [ num2str(mainHandles.energySetPoints(n)) ' GeV' ]);
    L3MeVset = L3MeVRef +... %  L3 energy which will give corrected delta e..Set - e..Ref
        1000*(mainHandles.energySetPoints(n) - bendEnergyGeV);
    if ~debug
        lcaPut(pvL3MeV, L3MeVset);
    end
    if mainHandles.angleBumpOn
        kmAngleBump(mainHandles.testSegment, mainHandles.angleSetX(n), mainHandles.angleSetY(n),...
            mainHandles.debug);
    end
    pause(1*waitTime);
    if  kmAbortCheck(mainHandles.KM_main) == 1
        F = 0*correctedEnergy; % return zeros
        mainHandles.abort = 0; % reset
        % Deal with feedback
        if ~debug
            lcaPut(pvL3FBOnOff,L3FBinitState)
        end
        return
    end

    mainHandles = scanPlotUpdate(n, mainHandles); % Continuously plot data, once per energy set point
end % end of  energy scan, plotting, and data taking loop

eDefOff(mainHandles.eDefNumber); % Stop collecting data

% Reset feedback and buttons
set(mainHandles.messages,'String','Ready');
set(mainHandles.scanButton, 'String', 'Scan Energy');
pause(1); % just in case it matters

if ~debug
    lcaPut(pvL3MeV, L3MeVRef);    
    pause(1); % just in case it matters
    lcaPut(pvL3FBOnOff,L3FBinitState);
end

% Return now if this is a a nonBSA detector
if ~BSA
    F = mainHandles.Fns;
    correctedEnergy =  mainHandles.correctedEnergyNS;
    return
end

% Collect the BSA data
npts = eDefCount(mainHandles.eDefNumber); % number of BSA data points
display(['eDef Got ' num2str(npts) ' BSA data points']);

if npts==0
    display('Returning nonBSA data!'); % if BSA bombs, return with non BSA data
    F = mainHandles.Fns;
    correctedEnergy =  mainHandles.correctedEnergyNS;
    return;
else % read all the bpm relevant data
    BSAdataAll( 7, npts) = 0; % initialize
    try
        BSAdataAll =...
            lcaGetSmart({pvs1; pvs2; pvs3; pvs4; pvs2tmit; pvBSAdetectorChosen; pvPulseID},npts);
    catch
        display('Can not lcaGet the BSA data!')
    end
    % Purge bad points
    BSAdataGood = BSApurge(BSAdataAll);
    if isempty(BSAdataGood)
        display('BSA data all bad, returning nonBSA data!'); % if BSA bombs, return with non BSA data
        F = mainHandles.Fns;
        correctedEnergy =  mainHandles.correctedEnergyNS;
        return;
    end 
end

% Reset the  BSA data to avoid re-reading old dat
eDefResetPV = sprintf('EDEF:SYS0:%d:RESET.PROC', mainHandles.eDefNumber);
lcaPut(eDefResetPV, 1);

% Clean up high betatron, low tmit points

% BSA is good, return normalized flux and corrected energy
F = qRef*BSAdataGood(6,:)./BSAdataGood(5,:);
correctedEnergy = energyCorrectDL2(BSAdataGood(1,:), BSAdataGood(2,:));
mainHandles.correctedEnergy = correctedEnergy;
mainHandles.Fbsa = F;
display('Returning good BSA data');

% Special detector specific changes
switch mainHandles.detector
    case 'Simulator'
        ylabel(mainHandles.scanAxis,'photons/pulse');
    case 'YAGXRAY TMIT'
        ylabel(mainHandles.scanAxis,'YAGXRAY TMIT [counts]');
    case 'Photodiode'
        ylabel(mainHandles.scanAxis,'microJoules/pulse');
    case 'Thermal'
        ylabel(mainHandles.scanAxis,'microJoules/pulse');
    case 'Gas Detector'
        ylabel(mainHandles.scanAxis,'microJoules/pulse');
    case 'Dog Leg'
        ylabel(mainHandles.scanAxis,'Measured Energy [GeV]');
        F = correctedEnergy;
    case 'PR55'
        ylabel(mainHandles.scanAxis,'PR55 TMIT [counts]');
end

% Finally update main gui output plot...
if ~mainHandles.angleBumpOn; % normal energy scan
    if isempty(correctedEnergy)
        xlabel(mainHandles.scanAxis, 'Programmed Energy [GeV]');
        display('Did not get any bpm readings for any energy');
    else
        hold(mainHandles.scanAxis,'off'); % need autoscale
        plot(mainHandles.scanAxis, correctedEnergy, F,'+');
        ylabel(mainHandles.scanAxis,mainHandles.detectorLabel);
        xlabel(mainHandles.scanAxis,'Measured Energy [GeV]');
        title(mainHandles.scanAxis,...
            ['Spectral edge point at ' num2str(mainHandles.edgeGeV) ' [GeV]' ]);
    end
else
    % angle scan plot (NS)
    n = length(mainHandles.Fns);
    mainHandles = angleBumpPlot(mainHandles,n);
end

kmSegmentPlot(mainHandles);


function npts = eDefCount(eDefNumber)
% 
% Get the number of reliable data points. Note cvs version of eDefCount
% is not reliable
%
pv = sprintf('PATT:SYS0:1:PULSEIDHST%d',eDefNumber);
pidVec = lcaGet(pv); % fast
[c, nPIDs] = min(pidVec); % returns first indice with a zero value.
npts = nPIDs -2; % sometimes the bpm data corresponding to the last PID  number is incomplete.


function mainHandles = scanPlotUpdate(n, mainHandles)
% Get nonsynchronous flux data once per energy setpoint and update the main gui
%  plot. n is scan setpoint number.
   
switch mainHandles.detector
    case 'YAGXRAY TMIT' % set ROI using profile monitor GUI
%         imageFull = profmon_measure('YAGS:DMP1:500',1,'bufd',1,'doPlot',0, 'nBG',0,'doProcess',0);
%         % for fast image acq, set bufd 1 and take multiple images
%         imageROI = imageFull.img;
%         imageROI = imageClean(imageROI);  % fix hot pixels (slow if big)
%         mainHandles.Fns(n) = sum(imageROI(:));
%         %dataPulseID(n) = imageFull.pulseId;

    case 'Photodiode'
        pvDetector = mainHandles.photodiodeChosen;
        detectorLabel = 'microJoules/pulse';

    case 'Thermal'
        %mainHandles.Fns(n) = 1000*lcaGet(mainHandles.TEMdataPV); % micronJoules: use channel A or B as chosen in setup
        detectorLabel = 'microJoules/pulse';
        pvDetector = mainHandles.TEMdataPV;

    case 'Gas Detector'
        %mainHandles.Fns(n)  = lcaGet(mainHandles.gasDetectorChosen); % correctedEnergy returned here is overwritten
        %dataPulseID(nmeas)= lcaTs2PulseId(ts);
        detectorLabel = 'microJoules/pulse';
        pvDetector = mainHandles.gasDetectorChosen;
        
    case 'Dog Leg'
        detectorLabel = 'Measured Beam Energy [GeV]';
        pvDetector = 'BPMS:LTU1:250:TMIT'; % just something to read
        
    case 'NFOV'
%         detectorLabel = 'NFOV sum in ROI';
%         imageFull = profmon_measure('DIAG:FEE1:481',1,'bufd',1,'doPlot',0, 'nBG',0,'doProcess',0);
%         imageROI = imageFull.img;
%         mainHandles.Fns(n) = sum(imageROI(:));
        detectorLabel = 'NFOV Raw Max';
        %mainHandles.Fns(n) = lcaGet('DIAG:FEE1:481:RawMax')
        pvDetector = 'DIAG:FEE1:481:RawMax';
end

% Get NS bpm and detector data point
pvs(1,1) = {'BPMS:LTU1:250:X'}; % dog leg
pvs(2,1) = {'BPMS:LTU1:450:X'};
pvs{3,1} = pvDetector;
val = lcaGet(pvs); % simultaneously get the  bpms and detector signal
x250 = val(1);
x450 = val(2);
mainHandles.Fns(n) = val(3);

% Deal with beam loss
retry = 1; maxRetry = 10;
while any(isnan(val))
    pause(.5)
    val = lcaGet(pvs); % keep trying for a while, hope beam comes back
    if retry == maxRetry
        return
    end
    retry = retry + 1;
    if kmAbortCheck(mainHandles.KM_main)
        return
    end
end

mainHandles.correctedEnergyNS(n) = energyCorrectDL2(x250, x450);
[Etrim, Ftrim] = kmSlopeTrim(mainHandles.correctedEnergyNS, mainHandles.Fns);
[mainHandles.edgeGeV, edgeSlopeF, dFdGeV, Eplot, Fplot] =...
    kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);

% Make plots
mainHandles.detectorLabel = detectorLabel; % for plot updates from init gui
hold(mainHandles.scanAxis, 'off');
ylabel(mainHandles.scanAxis,detectorLabel);
if ~mainHandles.angleBumpOn % normal energy scan case
    plot(mainHandles.scanAxis,...
        mainHandles.correctedEnergyNS(1:n), mainHandles.Fns(1:n),'+');
    xlabel(mainHandles.scanAxis, 'Measured Energy [GeV]');
    title(mainHandles.scanAxis, ['Spectral edge point at ' num2str(mainHandles.edgeGeV) ' [GeV]' ]);
    switch mainHandles.detector
        case 'Dog Leg'
            sigmaEnergy = std( mainHandles.correctedEnergyNS(1:n) );
            title(mainHandles.scanAxis, ['Std dev ' num2str(sigmaEnergy) ' [GeV]' ]);
    end
else % make an angle bump plot
    mainHandles = angleBumpPlot(mainHandles,n);
end


function  BSAdataGood = BSApurge(BSAdataAll)
% Remove columns containing bad data: : values = NaN or tmit = 0 or duplicate PIDS

NaNs = isnan(BSAdataAll);  % return  1 wherever NaN
NaNbadCol = (sum(NaNs,1) > 0);

tmitBadCol = (BSAdataAll(5,:)==0 );   % return  1 for each bad data point
PIDbadCol = diff(BSAdataAll(7,:)) == 0; % return 1 for first of two duplicate PIDs
PIDbadCol = [PIDbadCol 0]; % match dimensionality

badCol = (NaNbadCol+ tmitBadCol + PIDbadCol ) > 0; % return 1 for each bad point

BSAdataGood = BSAdataAll;
BSAdataGood(:,badCol) = []; %remove all bad data points

function mainHandles = angleBumpPlot(mainHandles,n)
% update scanAxis with current angle bump data of n points

axes(mainHandles.scanAxis);  % for text command
if any(mainHandles.angleSetX ~= 0) % turn on/off X/Y plot by setting range to 0
    [p,S] = polyfit(mainHandles.angleSetX(1:n), mainHandles.Fns(1:n),2);
    angleFitX = mainHandles.angleSetX(1):.1:mainHandles.angleSetX(n);
    signalFitX = polyval(p,angleFitX);
    plot(mainHandles.scanAxis,...
        mainHandles.angleSetX(1:n), mainHandles.Fns(1:n),'b+',...
        angleFitX, signalFitX,'b-');
    mainHandles.angleBestX = -0.5*p(2)/p(1);
    text(.12, 0.3, ['XangleMax = ' num2str(mainHandles.angleBestX) ],'Units','inches');
    mainHandles.angleFitX = angleFitX; % for result plot
    mainHandles.signalFitX = signalFitX;
else
    [p,S] = polyfit(mainHandles.angleSetY(1:n), mainHandles.Fns(1:n),2);
    angleFitY = mainHandles.angleSetY(1):.1:mainHandles.angleSetY(n);
    signalFitY = polyval(p,angleFitY);
    plot(mainHandles.scanAxis,...
        mainHandles.angleSetY(1:n), mainHandles.Fns(1:n),'gx',...
        angleFitY, signalFitY,'g-');
    mainHandles.angleBestY = -0.5*p(2)/p(1);
    [p,S] = polyfit(mainHandles.angleSetY(1:n), mainHandles.Fns(1:n),2);
    mainHandles.angleBestY = -0.5*p(2)/p(1);
    text(.12, 0.1, ['YangleMax = ' num2str(mainHandles.angleBestY) ], 'Units','inches');
    mainHandles.angleFitY = angleFitY; 
    mainHandles.signalFitY = signalFitY;
end
ylabel(mainHandles.scanAxis, 'Photodiode signal [arb]');
xlabel(mainHandles.scanAxis, 'Beam angle at center of segment [urad]');
title(mainHandles.scanAxis, ['Angle scan, segment: ' num2str(mainHandles.testSegment)]);


