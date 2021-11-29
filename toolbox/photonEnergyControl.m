function photonEnergyControl()
%function photonEnergyControl()
% Read measured photon energy and calculate
% desired electron energy.  Provides PV for Users to
% enter photon energy within specified limits.

% William Colocho (Feb. 2010)

% for ii = 1:10
%   pvN = sprintf('SIOC:SYS0:ML00:AO%i.DESC', 854+ii);
%   lcaPut(pvN,'Photon Energy Slow FBCK');
% end

% edm -eolc -x /home/physics/colocho/photonEnergy.edl

pv = struct('state','SIOC:SYS0:ML00:AO855');
pv.photonEnergyDes = 'SIOC:SYS0:ML00:AO856';
                                                                                                                                    testing = 0;
if testing
  pv.photonEnergyAct = 'SIOC:SYS0:ML00:AO859';
  pv.l3EnergyVernier = 'SIOC:SYS0:ML00:AO860';
else
  pv.photonEnergyAct = 'SIOC:SYS0:ML00:AO627'; 
  pv.l3EnergyVernier = 'SIOC:SYS0:ML00:AO289';
end
pv.lemEnergy = 'REFS:DMP1:400:EDES';
%pv.lemEnergy = 'SIOC:SYS0:ML00:AO409';
pv.userLimit = 'SIOC:SYS0:ML00:AO857';
pv.gain = 'SIOC:SYS0:ML00:AO861';

pvStateStr = 'SIOC:SYS0:ML00:SO0855';
pvStr = struct('engyDes','SIOC:SYS0:ML00:SO0856');
 

outPvCtrl.l3EnergyVernier = pv.l3EnergyVernier;
outPvCmpt.photonEnergyHigh = [pv.photonEnergyDes, '.HIGH'];
outPvCmpt.photonEnergyLow = [pv.photonEnergyDes, '.LOW'];
outPvCmpt.photonEnergyHighPr = [pv.photonEnergyDes, '.HOPR'];
outPvCmpt.photonEnergyLowPr = [pv.photonEnergyDes, '.LOPR'];

stateStr = {'OFF';'COMPUTE'; 'FEEDBACK'; 'Undefined'};
oldState = -1;
go = 1;
while(go) %loop forever
    
  [feedbackState ts ispv] = lcaGetSmart(pv.state);
  if ~ispv, errorMessage(pv.state,feedbackState,'Cannot get feedbackState'); continue, end
  
  
  isTransition = (oldState ~= feedbackState);
  oldState = feedbackState;
  if (isTransition), %When state is changed: Act to Des Photon Energy Setpoint
      errorMessage('','',['State is ', stateStr{feedbackState}]),
      lcaPutSmart(pvStateStr, stateStr{feedbackState});
      if feedbackState == 3, %Act to Des during transition to Feedback
          [photonEnergyActual ts ispv] = lcaGetSmart(pv.photonEnergyAct);
          if ~ispv, errorMessage(pv.photonEnergyAct, photonEnergyActual,'In transition test: failed to get value'); end
          lcaPutSmart(pv.photonEnergyDes, photonEnergyActual); 
      end
      compute(pv,outPvCmpt, pvStr);
  end

  if testing
    %isBeamOn = 1 so continue
  else
    [beamTmit ts ispv] = lcaGetSmart('BPMS:DMP1:693:TMITBR');
    isBeamOn = beamTmit > 9.3e7;
    if ~ispv || (isBeamOn == 0) || isnan(beamTmit), errorMessage('','','Beam Off or BPM not read'), 
        go = go + 1;
        if go == intmax, go  = 1; end
        lcaPutSmart('SIOC:SYS0:ML00:AO858', go);
        pause(0.5);
        continue, 
    end
    
  end
  
  switch feedbackState
      case 1,%'OFF', % Do nothing
      case 2,%'COMPUTE', %Read and Compute
          compute(pv,outPvCmpt,pvStr);
      case 3,%'FEEDBACK', %Read, compute and write
          [outCtrl  ispv] = compute(pv,outPvCmpt, pvStr);
          if ispv, write(outPvCtrl,outCtrl);  end
      otherwise
          feedbackState = 4;
  end %switch feedbackState
  go = go + 1;
  if go == intmax, go  = 1; end
  lcaPutSmart('SIOC:SYS0:ML00:AO858', go);
  
  

  pause(0.5)
end %while (1)
end

function [outCtrl ispv] = compute(pv, outPvCmpt, pvStr)
%compute Energy Vernier and Photon Energy limits
%return NAN if lcaGet fails.
persistent oldPhotonEnergyDes;
pvs = struct2cell(pv);
[d ts ispv] = lcaGetSmart(pvs);
pvNames = fieldnames(pv);
out = struct('l3EnergyVernier',nan);
outCmpt =struct ( 'photonEnergyHigh', nan, 'photonEnergyLow', nan, 'photonEnergyHighPr', nan, 'photonEnergyLowPr', nan);
for ii = 1:length(pvNames), 
  data.(pvNames{ii}) = d(ii); 
end

if (ispv)
    if isempty( oldPhotonEnergyDes), 
        deltaPhotonEnergyDes = 0; %During 1st pass of loop.
    else
        deltaPhotonEnergyDes = (oldPhotonEnergyDes - data.photonEnergyDes) /data.photonEnergyDes ;
    end 

    % if deltaPhotonEnergyDes ~= 0, keyboard; end
    deltaPhotonEnergy = (data.photonEnergyAct - data.photonEnergyDes - deltaPhotonEnergyDes)/ (data.photonEnergyDes - deltaPhotonEnergyDes); % in %

    deltaElectronEnergy = deltaPhotonEnergy  * ( 1000 * data.lemEnergy + data.l3EnergyVernier) / 2; %Aproximate for small deltas (quadratic dependence)
    deltaElectronEnergyFromDeltaDes = deltaPhotonEnergyDes * (1000 * data.lemEnergy + data.l3EnergyVernier) / 2;
    lcaPutSmart('SIOC:SYS0:ML00:AO864',deltaElectronEnergyFromDeltaDes); %just for diagnostics?
    newEnergyVernier = data.l3EnergyVernier - ( data.gain *  deltaElectronEnergy + deltaElectronEnergyFromDeltaDes);
  
    if newEnergyVernier >= 0,
        outCtrl.l3EnergyVernier =  min( newEnergyVernier, 1e3*data.lemEnergy* data.userLimit/100); %MeV
    else
        outCtrl.l3EnergyVernier =  max(newEnergyVernier, -1e3*data.lemEnergy* data.userLimit/100); %MeV
    end
  
    energyDesLimit = abs(electron2photonEngy(data.lemEnergy) - electron2photonEngy(data.lemEnergy * (1+data.userLimit/100)));% percent of LEM energy (as photon energy)

    outCmpt.photonEnergyHigh =   electron2photonEngy(data.lemEnergy) + energyDesLimit;
    outCmpt.photonEnergyLow =    electron2photonEngy(data.lemEnergy) - energyDesLimit;
    outCmpt.photonEnergyHighPr = outCmpt.photonEnergyHigh;
    outCmpt.photonEnergyLowPr = outCmpt.photonEnergyLow;
    
    if ( data.photonEnergyDes > outCmpt.photonEnergyHigh || data.photonEnergyDes < outCmpt.photonEnergyLow)
        outStr.engyDes = 'Requested Energy Outside Limits';
    else
        outStr.engyDes = ' ';
    end
    
    oldPhotonEnergyDes = data.photonEnergyDes;
    write(pvStr, outStr);
    write(outPvCmpt, outCmpt); 
else
    errorMessage(pv,data,'Failed to get value');
end%if ispv
end

function write(outPv,out)
%output to control pv
%outPv is structure of PV names,  out is structure of values; isString is
%logical for string structures.
fieldName = fieldnames(out);
isNumeric = isnumeric(out.(fieldName{1})); 
if (isNumeric)
    outPvs = struct2cell(outPv);
    outVals = cell2mat(struct2cell(out));

    ispv = lcaPutSmart(outPvs, outVals);
    if ~ispv, errorMessage(outPvs,out,'Cannot Write'); end
else  
    for ii = 1:length(fieldName), lcaPutSmart(outPv.(fieldName{ii}), out.(fieldName{ii})); end
end
end

function errorMessage(pv,data,messageStr)
%Output messageStr to PV and errlog.
%
persistent oldMessageStr;
if ~strcmp(oldMessageStr,messageStr)
    if isempty(pv),
        fprintf('%s Photon Energy Control: %s\n',datestr(now),messageStr);
    else
        fprintf('\n%s Photon Energy Control : %s\n',datestr(now),messageStr);
        disp(pv)
        disp(data)
    end
end
oldMessageStr = messageStr;

end
  
function photonEnergy = electron2photonEngy(electronEnergy)
%electronEnergy in GeV -> photonEnergy in eV
A = 0.03; %lambdaUnd
B = 0.000511; %electronRestE
C = electronEnergy;
D = 3.5; %undulatorK
E = 1239.84; %hc

photonEnergy = E/(1e9*((A*(B^2))/(2*(C^2)))*(1+((D^2)/2)));
end


