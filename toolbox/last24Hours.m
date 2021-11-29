function last24Hours()
%function last24Hours()
%This function calculates vector PVs to be used by last24Hours.edl

% William Colocho, May 2008

%Trace properties: PB60:DAILY:TMOD24   PB60:DAILY:LUM
%                  PB60:DAILY:TMOD24  PB60:DAILY:TMARK
%Bunch length: SIOC:SYS0:FB00:BC1_BLEN_IPK  SIOC:SYS0:FB00:BC2_BLEN_IPK
gasDetFloor = lcaGetSmart('SIOC:SYS0:ML00:SO0320'); %Noise floor of GD signal
gasDetFloor = str2num(strtok(gasDetFloor{:}));
debugFlag = 0;
lcaSetSeverityWarnLevel(4) %Don't warn about INVALID severity for BPMS
lPut('SIOC:SYS0:ML00:FWF15.DESC','bunchInjVector'); 
lPut('SIOC:SYS0:ML00:FWF22.DESC','bunchDmpVector'); 
lPut('SIOC:SYS0:ML00:FWF14.DESC','bc2IpkVector');  
lPut('SIOC:SYS0:ML00:FWF16.DESC','photonEnergy');  
lPut('SIOC:SYS0:ML00:FWF12.DESC','photonEnergy');
lPut('SIOC:SYS0:ML00:FWF21.DESC','photonEnergyGasMeas');
lPut('SIOC:SYS0:ML00:FWF11.DESC','timeOfDayVec');
lPut('SIOC:SYS0:ML00:FWF17.DESC','BC2 Bunch Length ');

web.chargeNormalization = lGet('SIOC:SYS0:ML00:AO325');
web.n3Min = 60*24/3;
web.time3Min = 0.0166:24/web.n3Min:24;
web.i3 = fix(10000 * web.time3Min/web.time3Min(end));

web.wave3List = {'CUD:MCC0:TRMIN:WAVEFORM1';'CUD:MCC0:TRMIN:WAVEFORM2';'CUD:MCC0:TRMIN:WAVEFORM3';'CUD:MCC0:TRMIN:WAVEFORM4'; ...
                'CUD:MCC0:TRMIN:WAVEFORM5';'CUD:MCC0:TRMIN:WAVEFORM6';'CUD:MCC0:TRMIN:WAVEFORM7'; 'CUD:MCC0:TRMIN:WAVEFORM8'; ...
                'CUD:MCC0:TRMIN:WAVEFORM9'};
web.matWaveFrms={'SIOC:SYS0:ML00:FWF15'; 'SIOC:SYS0:ML00:FWF22'; 'SIOC:SYS0:ML00:FWF21'; 'SIOC:SYS0:ML00:FWF11' ; ...
                 'SIOC:SYS0:ML00:FWF16';'SIOC:SYS0:ML00:FWF12';'SIOC:SYS0:ML00:FWF13'; 'SIOC:SYS0:ML00:FWF11'; ...
                 'SIOC:SYS0:ML00:FWF17'};     
web.pvDesc = {'Injector Bunch Current'; 'Dump Bunch Current'; 'X-Ray Energy (Gas Detector)'; 'Time of Day';...
              'X-Ray Energy (E-loss)'; 'X-Ray Energy (6x6 FBCK)'; 'X axis 0 to 24'; 'Time of Day'; ...
              'BC2 Bunch Length'};      
web.egus =    {'pC'; 'pC'; 'mJ';   'Hr'; 'mJ';  'eV';  'Hr'; 'Hr'; 'fs'};
web.rescale = {'10'; '10'; '1000'; '1'; '1000'; '1'; '1';  '1';  '10'}; 

for ii = 1:length(web.wave3List)
  lcaPut([web.wave3List{ii},'.DESC'], web.pvDesc{ii}); %only needed after soft IOC reboot.
  lcaPut([web.wave3List{ii},'.EGU'], [web.egus{ii}, ' x ', web.rescale{ii}]) % Done once at program start up...
end
pvLen = 10000;
felUp.PV = {'BPMS:IN20:221:TMIT1H'; 'BPMS:IN20:221:X1H'; ...
            'BPMS:DMP1:693:TMIT1H' ; 'BPMS:DMP1:693:Y1H'};
        felUp.PV = {'BPMS:IN20:221:TMITHSTBR'; 'BPMS:IN20:221:XHSTBR'; ...
            'BPMS:DMP1:693:TMITHSTBR' ; 'BPMS:DMP1:693:YHSTBR'};
              
 felUp.Str = {'INJ Q'; 'DMP Q'};
 strAdd = {'Limit'; 'Limit'};
 strEgu = {'1e9 Nel'; '1e9'};
 str1 = {'Mean';'Mean'};
 kk =0;
 for jj = 1:2
   for ii = 1:length(felUp.Str)
     kk = kk + 1;
     if(kk<10), kkStr = ['0', num2str(kk)]; else kkStr = num2str(kk); end
     lPut(['SIOC:SYS0:ML00:AO3', kkStr, '.DESC'],[felUp.Str{ii}, ' ', strAdd{ii}]);
     lPut(['SIOC:SYS0:ML00:AO3', kkStr, '.EGU'],  strEgu{ii});
     lPut(['SIOC:SYS0:ML00:SO03', kkStr], '24 HR CUD');
     pvList(kk) = {['SIOC:SYS0:ML00:AO3', kkStr]};
   end
 end
 pvList = pvList'; 
 nPvs = length(pvList);
 
 Xmean =   lGet(pvList(1:nPvs/2)); 
 deltaLim =  lGet(pvList(nPvs/2 + 1:end)); 
 
 felUp.Min(1:2:nPvs) = (Xmean(1) - deltaLim(1)) *1e9 ;
 felUp.Min(2:2:nPvs) = Xmean - deltaLim;
 felUp.Max(1:2:nPvs) = (Xmean(1) + deltaLim(1)) *1e9 ;
 felUp.Max(2:2:nPvs) = Xmean + deltaLim;
 pvListOne = {'SIOC:SYS0:ML00:SO1013';'SIOC:SYS0:ML00:SO1014';...
           'SIOC:SYS0:ML00:SO1015'};
 %useMask = 1:length(felUp);
 
 
 lPut(pvListOne,'In Use')
 
 
 tMod24 = 0:24/pvLen:24; tMod24 = tMod24(1:end-1);
 tMod24A = 0:24/480:24; tMod24A = tMod24A(1:end-1);
 lPut('SIOC:SYS0:ML00:FWF13',tMod24);
 lPut('CUD:MCC0:TRMIN:WAVEFORM10', tMod24A); %directors display
 dayIndx = (tMod24 > 8 & tMod24 <= 16); dayIndx = tMod24(dayIndx);
 swingIndx = (tMod24 > 16);             swingIndx = tMod24(swingIndx);
 owlIndx = (tMod24 <= 8);               owlIndx = tMod24(owlIndx);
 hoursPerIndex = 24/pvLen;
 
 upHoursPvs = {'SIOC:SYS0:ML00:AO311'; 'SIOC:SYS0:ML00:AO312'; 'SIOC:SYS0:ML00:AO313'};
 bc2IpkVector = lGet('SIOC:SYS0:ML00:FWF14'); % A 
 bc2BunchLength = lGet('SIOC:SYS0:ML00:FWF17'); %fs
 bunchInjVector = lGet('SIOC:SYS0:ML00:FWF15'); % currentVector = zeros(1,pvLen);
 bunchDmpVector = lGet('SIOC:SYS0:ML00:FWF22');
 photonEnergy = lGet('SIOC:SYS0:ML00:FWF16'); % single Photon energy From e-loss scan
 photonEnergyeV = lGet('SIOC:SYS0:ML00:FWF12'); 
 photonEnergyGasMeas = lGet('SIOC:SYS0:ML00:FWF21'); % mJ 
 
 timeOfDayVec = lGet('SIOC:SYS0:ML00:FWF11');
 t1 = now; 
 upTime = [0 0 0];
 fprintf('\n\nLast24Hours program successfully started on %s\n', datestr(now));
 counter = 0;
 tic
 webWaveforms(web); 
 lastBeamOn = 2; %Any number so that S_tminus1 gets initiated at start of loop.
  ignorePastFlag = 0;
  initFlag = 1;
  
  %update eloss history once per day in the morning.
  timerEloss =  timer('TimerFcn','elossHist', 'Period',60*60*24,...
      'ExecutionMode','FixedRate');
  startTime = fix(now) + 1 + 7/24;
  %startat(timerEloss,datestr(now+0.01/24)) for debuging
  startat(timerEloss,startTime);
 
  
 while(1)
%    if toc > 170, tic; 
%        webWaveforms(web);  %Don't update this for now 6/2011
%    end
   undulatorWaveforms;

   %Get Mean and Limits from EPICS
   Xmean =   lGet(pvList(1:nPvs/2)); 
   deltaLim =  lGet(pvList(nPvs/2 + 1:end)); 
 
   felUp.Min(1:2:nPvs) = (Xmean(1) - deltaLim(1)) * 1e9 ;
   felUp.Min(2:2:nPvs) = Xmean - deltaLim ;
   felUp.Max(1:2:nPvs) = (Xmean(1) + deltaLim(1)) * 1e9 ;
   felUp.Max(2:2:nPvs) = Xmean + deltaLim;
   %Update Mask for cuts to use and show Mask to EPICS display
   %readMask = lGet('SIOC:SYS0:ML00:FWF14.EGU');
   %useMask = 1:str2double(readMask{:}) * 2;  %Don't use mask anymore.
   useMask = 1:4; 
   putStr = ['Use: ', sprintf('%s, ',felUp.Str{useMask(1:end/2)}) ]; putStr = putStr(1:end-2);
   lPut('SIOC:SYS0:ML00:FWF14.DESC', {putStr});
   
   %%useMask(find(useMask == 2) ) = []; %remove X test from IN20 221 BPM
   %Get value for ~10 sec.
   %iiVal = [];
   %for ii = 1:10,iiVal(ii,:) = lGet(felUp.PV(useMask))'; pause(1); end
   %value = mean(iiVal);
   theBsaData = lcaGetSmart(felUp.PV(useMask));  
   try
       value = mean(theBsaData(:,end-10:end),2);
   catch
       value = [0 0 0 0];
   end
   
   %Figure out index range
   t2 = now; %datestr(t2-t1,13) %To view elapsed times
   tRange = [t1 t2]; tRange = 24 *(tRange - floor(tRange) ); t1 = t2; 
   indx = find(tMod24 > tRange(1) & tMod24 < tRange(2));
   if isempty(indx), pause(1), continue, end
   
   %Update 24 hour buffer vectors
%   updateEmitBmag; 
   timeOfDayVec = zeros(1,pvLen) - 0.1;
   timeOfDayVec(indx(end)) = lGet('SIOC:SYS0:ML00:AO326');

   bunchChargeInj = value(1) * 1.60217646e-7; % pC;
   bunchChargeDump = value(3) * 1.60217646e-7;% pC;
   if bunchChargeDump > 0.1, beamOn = 1; else beamOn = 0; end %Beam off if less than 0.1 
   chargeNormalization = lGet('SIOC:SYS0:ML00:AO325');
   bunchChargeInj = bunchChargeInj * chargeNormalization ; %in pC x chargeNormalizatio
   bunchChargeDump = bunchChargeDump * chargeNormalization ; 
   if(isnan(bunchChargeInj)), bunchChargeInj = 0; end
   if(isnan(bunchChargeDump)), bunchChargeDump = 0; end

   bc2IpkVector(indx) = lGet('SIOC:SYS0:ML00:AO195') / 1000; %KA
   bc2BunchLength(indx) = lGet('SIOC:SYS0:ML00:AO820'); %fs
   bunchInjVector(indx) = bunchChargeInj;
   bunchDmpVector(indx) = bunchChargeDump;
   photonEnergy(indx) = lGet('PHYS:SYS0:1:ELOSSENERGY') * beamOn;  %  photon energy from E-Loss scan.
   %%lPut('SIOC:SYS0:ML00:AO314', photonEnergy(indx(end)) );
   
%   photonEnergyeV(indx) = lGet('SIOC:SYS0:ML00:AO541'); %Calculated
   if beamOn ~= lastBeamOn %On Beam on/off transitions reset the averaging sum.
      S_tminus1 = lcaGetSmart('SIOC:SYS0:ML00:AO627') * beamOn; 
   end
   lastBeamOn = beamOn;
       
   Y_tminus1 = lcaGetSmart('SIOC:SYS0:ML00:AO627') * beamOn;
   S = 0.1 * Y_tminus1 + (1 - 0.1) * S_tminus1; % Exponential moving average 0.1 smooth factor
   S_tminus1 = S * beamOn;
   photonEnergyeV(indx) = S;
   beamRate = lcaGetSmart('EVNT:SYS0:1:LCLSBEAMRATE');
   try       
       gas1Meas = lcaGetSmart('GDET:FEE1:241:ENRCHSTBR');
       gas2Meas = lcaGetSmart('GDET:FEE1:242:ENRCHSTBR');
       dl2BYK = lcaGetSmart('BPMS:LTU1:350:YHSTBR');
       dumpBYKIndx = find(dl2BYK < -3.6); %Beam is past BYKICK if Y position > -3.6 mm
       gas1Meas(dumpBYKIndx) = nan;
       gas2Meas(dumpBYKIndx)=  nan;
       
   catch
       fprintf('%s - Failed to get vectors from Gas detectors\n', datestr(now))
       lasterr
   end
   
   gasMeas = 0;
 
   if(beamRate > 0)
        numPts = fix(8 * beamRate); %last 8 seconds of Gas detector data
        try
            gas1Meas = gas1Meas(end-numPts+1:end);
            gas2Meas = gas2Meas(end-numPts+1:end);
            gas1Meas(isnan(gas1Meas)) = [];
            gas2Meas(isnan(gas2Meas)) = [];
        catch
             fprintf('%s - Failed to get vectors from Gas detectors\n', datestr(now))
             lasterr
        end
        if ~(isempty(gas1Meas) || isempty(gas1Meas) )
            gasMeas = max(0,mean([gas1Meas gas2Meas])); % mean of both detectors.
        end
   end
   
   photonEnergyGasMeas(indx) = gasMeas; 
   
  if ~debugFlag
     lPut('SIOC:SYS0:ML00:FWF15',bunchInjVector); 
     lPut('SIOC:SYS0:ML00:FWF22',bunchDmpVector); 
     lPut('SIOC:SYS0:ML00:FWF14',bc2IpkVector);  
     lPut('SIOC:SYS0:ML00:FWF16',photonEnergy);  
     lPut('SIOC:SYS0:ML00:FWF12',photonEnergyeV);
     lPut('SIOC:SYS0:ML00:FWF21',photonEnergyGasMeas);
     lPut('SIOC:SYS0:ML00:FWF11',timeOfDayVec);
     lPut('SIOC:SYS0:ML00:FWF17',bc2BunchLength);
 
  else
     plot([indx-100:indx+100],photonEnergyeV(indx-100:indx+100),'o-',indx, 1400,'*')
  end
   if(0) %To zero wavefroms during downtime
       Z = zeros(1,length(bunchInjVector));
       lPut('SIOC:SYS0:ML00:FWF15',Z); 
     lPut('SIOC:SYS0:ML00:FWF22',Z); 
     lPut('SIOC:SYS0:ML00:FWF14',Z);  
     lPut('SIOC:SYS0:ML00:FWF16',Z);  
     lPut('SIOC:SYS0:ML00:FWF12',Z);
     lPut('SIOC:SYS0:ML00:FWF21',Z);
     lPut('SIOC:SYS0:ML00:FWF17',Z);
   end
  
 %Calculate uptime
 hourOfDay = str2double(datestr(now,'HH'));
 shift = 1 +  fix((hourOfDay)/8); % 1 for owl, 2 for day, 3 for swing
 
 switch num2str(shift)
   case '1'
      upIndx = find(owlIndx < tMod24(indx(end)) );
      offset = 0;
   case '2'
      upIndx = find(dayIndx < tMod24(indx(end)));
      offset = length(owlIndx);
   case '3'
      upIndx = find(swingIndx < tMod24(indx(end))); 
      offset = length(owlIndx) + length(dayIndx);
 end
   upTime(shift) = sum(bc2IpkVector(upIndx + offset)) * hoursPerIndex;
   
   lPut('SIOC:SYS0:ML00:AO318',upTime(shift));
   if(~exist('oldShift','var')), oldShift = shift; end
   if(oldShift ~= shift),lPut(upHoursPvs{oldShift},upTime(oldShift)); end
   oldShift = shift;
   pause(5)
   counter = counter + 1;
   if(counter > 50000), counter = 1; end
   lPut('SIOC:SYS0:ML00:AO322',counter);
   
   
  %Calculate 24 hour uptime for Director's Display
  beamOnDump = find(bunchDmpVector > 50); %5 pC
  if isempty(beamOnDump), beamOnDump = 0; end
  lcaPut('SIOC:SYS0:ML00:AO319', 100 *length(beamOnDump)  / pvLen); %Avialabile Time with e- to dump in last 24 hours.
  
  %On first day of Director Display start looking at 09:00
  if strcmp(datestr(now,'HH:MM:SS'), '09:00:00') || initFlag == 1
      initFlag = 0;
      listOfUserStarts = char(lcaGetSmart('SIOC:SYS0:ML00:CA018'));
      isFirstDay = strmatch( num2str(datenum(datestr(now,1))), listOfUserStarts); 
      if ~isempty(isFirstDay)
          ignorePastFlag = 1;
      else
          ignorePastFlag = 0;
      end
  end
  
  if (ignorePastFlag)
      ignoreIndx1 = find(tMod24==9);
      ignoreIndx2 = find(tMod24>datenum(datevec(now) .* [0 0 0 1 1 1]) * 24);
      ignoreIndx2 = ignoreIndx2(1);
  else
      ignoreIndx1 = 1;
      ignoreIndx2 = pvLen;
  end
  rangeForCalc = ignoreIndx1:ignoreIndx2;
  photonOnDump = find( photonEnergyGasMeas(rangeForCalc) > gasDetFloor );
  if isempty(photonOnDump),  photonOnDump= 0; end
  lcaPutSmart('SIOC:SYS0:ML00:AO320', 100 *length(photonOnDump)  / (pvLen-ignoreIndx1) ); 
     
  directorDisplayUpdate;
  calcHXRSS  %use deg2eV to try to predict HXRSS energy from cristal_angle
  
  %undulatorStatus;
 
 end %while(1)
end %function
   
   
function value = lGet(pv) 
try value = lcaGetSmart(pv); catch value = zeros(1,length(pv)); end
end

function lPut(pv, putVal)
try lcaPut(pv, putVal), catch fprintf('lcaPut failed to write PV'); end
end
 
function updateEmitBmag()
%updateEmitBmag updates emit*bmag for LI28 measurements
li28EmitX = lGet('WIRE:LI28:144:EMITN_X');
li28EmitY = lGet('WIRE:LI28:144:EMITN_Y');
li28BmagX = lGet('WIRE:LI28:144:BMAG_X');
li28BmagY = lGet('WIRE:LI28:144:BMAG_X');
if(sum(isnan([li28EmitX, li28EmitY, li28BmagX ,li28BmagY]))), return, end
lPut('SIOC:SYS0:ML00:AO316',li28EmitX * li28BmagX  );
lPut('SIOC:SYS0:ML00:AO317',li28EmitY * li28BmagY  );
end

function webWaveforms(web)

%pvList = {'PHYS:SYS0:1:ELOSSENERGY'; 'SIOC:SYS0:ML00:AO541'; 'BPMS:IN20:221:TMIT1H';  'BPMS:DMP1:693:TMIT1H'};
for ii = 1:length(web.matWaveFrms);
    val = lcaGetSmart(web.matWaveFrms{ii});

    switch ii
        case {1,2} % Scale bunch currents;
            val = medfilt1(val,13);
            val3 = val(web.i3) / web.chargeNormalization * str2num(web.rescale{ii});
        case 4 %time scale manipulations
            maxIndx = find(val > 0); 
            maxIndx = maxIndx(end); %in case there is more than one.
            val3 = val(web.i3);
            val3(ceil(maxIndx * 480 / 10000)) = val(maxIndx) *20;
        case 8 %time scale manipulations
            maxIndx = find(val > 0); 
            maxIndx = maxIndx(end); %in case there is more than one.
            val3 = val(web.i3);
            val3(ceil(maxIndx * 480 / 10000)) = val(maxIndx) * 3000;
        otherwise
            val = medfilt1(val,13);
            val3 = val(web.i3) * str2num(web.rescale{ii});
    end
    lcaPutSmart(web.wave3List{ii}, val3);

%    

end
   

end

function undulatorWaveforms()
%function undulatorWaveforms
%function to generate waveforms for undulator pointing.

wavePvsH = {'BPMS:UNDH:ALL:COUNT'; 'BPMS:UNDH:ALL:XOFF'; 'BPMS:UNDH:ALL:YOFF'};
wavePvsS = {'BPMS:UNDS:ALL:COUNT'; 'BPMS:UNDS:ALL:XOFF'; 'BPMS:UNDS:ALL:YOFF'};

xPointPvsHXR = strcat(model_nameRegion('BPMS','UNDH'),':XOFF.D');
xPointPvsHXR = [{'BPMS:LTUH:910:XOFF.D'; 'BPMS:LTUH:960:XOFF.D'; 'BPMS:UNDH:1305:XOFF.D' }; xPointPvsHXR]';
yPointPvsHXR = strcat(model_nameRegion('BPMS','UNDH'),':YOFF.D');
yPointPvsHXR = [{'BPMS:LTUH:910:YOFF.D'; 'BPMS:LTUH:960:YOFF.D'; 'BPMS:UNDH:1305:YOFF.D' }; yPointPvsHXR]';
keqPvsHXR = strcat(model_nameRegion('USEG','UNDH'),':KAct');

xPointPvsSXR = strcat(model_nameRegion('BPMS','UNDS'),':XOFF.D');
yPointPvsSXR = strcat(model_nameRegion('BPMS','UNDS'),':YOFF.D');
keqPvsSXR = strcat(model_nameRegion('USEG','UNDS'),':KAct');


numberOfUndH = length(keqPvsHXR); %number installed so far
xVals = lcaGetSmart(xPointPvsHXR)';
yVals = lcaGetSmart(yPointPvsHXR)';
kVals = nan(1,36); 
kVals(end-numberOfUndH+1:end) = lcaGetSmart(keqPvsHXR')';
lcaPutSmart(wavePvsH, [1:39; xVals; yVals]);
lcaPutSmart( 'USEG:UNDH:ALL:KEQ',  kVals);

xVals = lcaGetSmart(xPointPvsSXR')';
yVals = lcaGetSmart(yPointPvsSXR')';
kVals = lcaGetSmart(keqPvsSXR')';
lcaPutSmart(wavePvsS(1:3), [1:28; xVals; yVals]);
lcaPutSmart('USEG:UNDS:ALL:KEQ',  kVals);

end
    
function directorDisplayUpdate
persistent experiment shiftTimes needUpdate%#ok<USENS>
if isempty(experiment), load /u1/lcls/matlab/config/programSchedule.mat; end
if isempty(needUpdate), needUpdate = 1; end
% % lcaPutSmart('CUD:MCC0:TRMIN:WAVEFORM10', (1:480) * 24/480);

maxPulseEnergy= lcaGetSmart('SIOC:SYS0:ML01:AO080');
lcaPutSmart('CUD:MCC0:TRMIN:WAVEFORM11',ones(1,480) * maxPulseEnergy);

meanPulseEnergy = lcaGetSmart('SIOC:SYS0:ML01:AO081');
lcaPutSmart('CUD:MCC0:TRMIN:WAVEFORM12', ones(1,480) * meanPulseEnergy);

% Yet another beam destination...
destVal = lcaGetSmart('XRAY_DESTINATIONS');
% LSB -- FEE
% B2   -- AMO
% B3   -- SXR
% B4   -- XPP
% B5   -- XRT
% B6   -- XCS
% B7   -- CXI
% B8   -- MEC
destinations = {'FEE', 'AMO', 'SXR', 'XPP', 'XRT', 'XCS', 'CXI','MEC'};
if isnan(destVal), destVal = 0; end
dest = fliplr(dec2bin(destVal,8));
destIndx = findstr('1',dest);
destStr = sprintf('  %s  ', destinations{destIndx});
if length(destStr) < 3, destStr = 'NONE'; end
lcaPutSmart('SIOC:SYS0:ML01:SO0082', destStr);

% Update once a day only.
% if (rem(now,1) > 8/24) && rem(now,1) < 8/24 + 1/(60*24)  && needUpdate
%     userAvailabilty = photonAvailability();
%     lcaPutSmart('SIOC:SYS0:ML01:AO086', userAvailabilty);
%     needUpdate = 0;
% end

if (rem(now,1) > 12/24) && rem(now,1) < 12/24 + 1/(60*24), needUpdate = 1; end %needUpdate true at noon.



%Scheduled Program drives request table.
nowDateNum = datenum(now);
nowIndx = find((shiftTimes - nowDateNum + 6/24) > 0);
if isempty(nowIndx), nowIndx = 1; end
nowIndx = nowIndx(1);
scheduledProgram = experiment(nowIndx);
outIndx = strmatch(deblank(scheduledProgram),{ 'AMO'; 'SXR'; 'XPP'; 'XCS'; 'CXI'; 'MEC'; 'MD'} );
if isempty(outIndx), outIndx = 8; end
lcaPutSmart('SIOC:SYS0:ML01:SO0085',scheduledProgram); 
lcaPutSmart('SIOC:SYS0:ML01:AO085', outIndx); %when empty will not change request table (!)

%Update desired bunch length for current destination
% desBunLenPvs = {'SIOC:SYS0:ML01:AO008';'SIOC:SYS0:ML01:AO009';'SIOC:SYS0:ML01:AO010';...
%     'SIOC:SYS0:ML01:AO012';'SIOC:SYS0:ML01:AO011';'SIOC:SYS0:ML01:AO013'; 'NONE'};
% desBlen = lcaGetSmart('SIOC:SYS0:ML00:CALC037'; ); %fs
% lcaPutSmart(desBunLenPvs{outIndx}, desBlen );
try
    felOperPoint(1)
catch
    %fprintf('%s Failed on felOperPoint(1)\n', datestr(now)) 
end

end
function calcHXRSS
theta = lcaGetSmart('XTAL:UND1:1653:ACT');
eV004 = deg2eV(theta,[0 0 4]);
eV220 = deg2eV(90-theta,[2 2 0]);
lcaPutSmart({'SIOC:SYS0:ML01:AO916'; 'SIOC:SYS0:ML01:AO917'}, [eV004; eV220]);
end
function undulatorStatus
% Calculate taper linearlity and number of SHABs or STANDARD undulators in

locationsPvs = aidalist('USEG:UND1:%:LOCATIONSTAT');
typePvs = aidalist('USEG:UND1:%:TYPE');

undulatorLocation = lcaGetSmart(locationsPvs);
undulatorType = lcaGetSmart(typePvs);

standardIndx = strmatch('STANDARD',undulatorType);
shabIndx = strmatch('2NDHARMONIC',undulatorType);

standardCount = length(strmatch('ACTIVE-RANGE',undulatorLocation(standardIndx))) + ...
    length( strmatch('AT-XIN',undulatorLocation(standardIndx)));

shabCount = length(strmatch('ACTIVE-RANGE',undulatorLocation(shabIndx))) + ...
    length( strmatch('AT-XIN',undulatorLocation(shabIndx)));

lcaPutSmart('SIOC:SYS0:ML01:AO083', standardCount);
lcaPutSmart('SIOC:SYS0:ML01:AO084', shabCount);

%lightStates = lcaGetSmart({'LGHT:FEE1:1971:STATE', 'LGHT:FEE1:1971:STATE', 'LGHT:FEE1:913:STATE'});
%stopperStates = lcaGetSmart({'PPS:FEH1:4:S4STPRSUM', 'PPS:FEH1:5:S5BSTPRSUM', 'PPS:FEH1:6:S6STPRSUM'});

end

