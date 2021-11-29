function operatingPointLoop()
% function operatingPointLoop()
% Infinite loop to call checkOperatingPoint for LCLS at startup it will 
% set HIGH and LOW values for PVs in the operating point set.

% William Colocho, March 2009


%% Set High and Low limits for PVs once before starting infinite loop.

global OPctrl
op = checkOperatingPoint;
lcaPutSmart('SIOC:SYS0:ML00:AO821.DESC', 'X Ray Peak Power from measurements');
lcaPutSmart('SIOC:SYS0:ML00:AO821.EGU', 'GW');

notOpPvList = {'OTRS:IN20:571:EMITN_X'; 'OTRS:IN20:571:BMAG_X';'OTRS:IN20:571:EMITN_Y';'OTRS:IN20:571:BMAG_Y' ;...
               'WIRE:LI21:293:EMITN_X';'WIRE:LI21:293:BMAG_X' ; 'WIRE:LI21:293:EMITN_Y';'WIRE:LI21:293:BMAG_Y' ;...
               'WIRE:LI28:144:EMITN_X';'WIRE:LI28:144:BMAG_X' ; 'WIRE:LI28:144:EMITN_Y';'WIRE:LI28:144:BMAG_Y' ;...
               'WIRE:LTUH:735:EMITN_X';'WIRE:LTUH:735:BMAG_X' ; 'WIRE:LTUH:735:EMITN_Y';'WIRE:LTUH:735:BMAG_Y' };
           
           
notOpParamCode={'OTR2_P_EMITN_X'; 'OTR2_P_EMITN_X'; 'OTR2_P_EMITN_Y'; 'OTR2_P_EMITN_Y';...
                'WS12_P_EMITN_X'; 'WS12_P_EMITN_X'; 'WS12_P_EMITN_Y'; 'WS12_P_EMITN_Y';...
                'LI28_P_EMITN_X'; 'LI28_P_EMITN_X'; 'LI28_P_EMITN_Y'; 'LI28_P_EMITN_Y';...
                'LTUH_P_EMITN_X'; 'LTUH_P_EMITN_X'; 'LTUH_P_EMITN_Y' ;'LTUH_P_EMITN_Y'};
try            
    updateEPICSlimits(op, OPctrl, notOpPvList, notOpParamCode); 
catch
    fprintf('%s Errors with updateEPICSlimits(op, OPctrl, notOpPvList, notOpParamCode)',datestr(now))
end


    %try staleHours = lcaGet('SIOC:SYS0:ML00:AO512'); catch fprintf('Failed to get stale hours: SIOC:SYS0:ML00:AO512'); end

%Targe list PVs.  ml01 062


%% Loop updating once every 1 seconds
counter = 0;
tic
while(1)
    try % intermittently failing to write to photon E PV?
        photonEnergyeV('SXR');
        photonEnergyeV('HXR');
    catch
    end
    op = checkOperatingPoint(op); %Updates database with new values.
    calculateParameters;
    gunBeamVoltsTime;
    nowStr = datestr(now);
    if (counter > 50000), counter = 1; end
    lcaPutSmart('SIOC:SYS0:ML00:AO323',counter);
    counter = counter + 1;
    
    
    %Update EPICS limits when requested
    try updateFlag = lcaGet('SIOC:SYS0:ML00:AO511'); catch fprintf('Failed to get update flag\n'); end
    if updateFlag, updateEPICSlimits(op, OPctrl, notOpPvList, notOpParamCode); 
        lcaPut('SIOC:SYS0:ML00:AO511', 0); 
        lcaPut('SIOC:SYS0:ML00:SO0511','Set to 1 to update limits')
    end
    if toc > 119, updateEPICSlimits(op, OPctrl, notOpPvList, notOpParamCode); tic; end %update limits once every two minutes.
% Change PV color if PV value is stale. (Uses 
% LOPR as spare channel since these are soft PVs LOPR is not used by
% others; color rule 91 "emittance" 21-25 for ALARM, 31-35 for NO ALARM, 41-46 "Stale").

    present = now;  
    try staleHours = lcaGet('SIOC:SYS0:ML00:AO512'); catch fprintf('Failed to get stale hours: SIOC:SYS0:ML00:AO512'); end

    for ii = 1:length(notOpPvList)
     timePv = regexprep(notOpPvList{ii},{'EMITN_[A-Z]','BMAG_[A-Z]'},'EMIT_TIME');
     actualTimeStamp = lcaGet(timePv);
     severity = lcaGet([notOpPvList{ii},'.SEVR']);
     if (strcmp('MAJOR',severity)), staleSev = 20; else staleSev = 30; end
     try
     theAge = ceil (((present - datenum(actualTimeStamp)) * 24) / staleHours); %hours normilized to stale hours
     catch
         keyboard
     end
     if theAge > 5, staleSev = 40; end  
     theAge = min(theAge,5); %Stop ageing after 5
     loprVal = staleSev + theAge;
%     fprintf('%s %s %i loprVal %i\n',notOpPvList{ii},severity{:},theAge,loprVal)
     
     try lcaPut([notOpPvList{ii},'.LOPR'], loprVal), catch fprintf('%s Failed to lcaPut to %s\n',datestr(now), notOpPvList{ii}),end
    end    
    pause(0.8);
    
end


end

function updateEPICSlimits(op, OPctrl, notOpPvList, notOpParamCode)
%function updateEPICSlimts
% Update EPICS PV limits when tolls modified. (triggered by user)
    lcaPut('SIOC:SYS0:ML00:SO0511','Updating EPICS Limits')
    
    %Get BSY energy from LEM PV, BC1 and BC2 Ipk from 6x6 feedback
    en = model_energySetPoints;
    bsyEngySetpt = en(5);
%    bsyEngySetpt = lcaGetSmart('SIOC:SYS0:ML00:AO409');
    lcaPut('SIOC:SYS0:ML00:AO122', bsyEngySetpt);
    epicsFbckActive = lcaGet('SIOC:SYS0:ML02:AO126');
    if epicsFbckActive
            bc1IpkSetpt = abs(lcaGetSmart('FBCK:FB04:LG01:S3DES'));    
            bc2IpkSetpt = abs(lcaGetSmart('FBCK:FB04:LG01:S5DES'));
    else
            bc1IpkSetpt = abs(lcaGetSmart('SIOC:SYS0:ML00:AO016'));    
            bc2IpkSetpt = abs(lcaGetSmart('SIOC:SYS0:ML00:AO044'));
    end
    
    lcaPut('SIOC:SYS0:ML00:AO167', bc1IpkSetpt);
    lcaPut('SIOC:SYS0:ML00:AO188', bc2IpkSetpt);
    
    for ii = 1:length(op)
      tol = op{ii}.Tol;
      switch op{ii}.Tolmode
        case '±',
            high = op{ii}.Target + tol;
            low  = op{ii}.Target - tol;
        case '<',
            high = op{ii}.Target;
            low = -inf;
        case '>',
            high = inf;
            low = op{ii}.Target; 
      end

      try
          if ~isnan(high), lcaPut([op{ii}.savActPV, '.HIGH'], high); end
          if ~isnan(low),  lcaPut([op{ii}.savActPV, '.LOW'], low); end
      catch
          fprintf('%s Failed to lcaPut %s HIGH or LOW attribute (%s)\n',datestr(now), op{ii}.savActPV , op{ii}.ParamCode )
      end

          if ~isnan(high), fprintf('%s %s caput %s %.2f\n',op{ii}.Parameter, op{ii}.Tolmode, [op{ii}.savActPV,'.HIGH'], high), end
          if ~isnan(low),  fprintf('%s %s caput %s %.2f\n',op{ii}.Parameter, op{ii}.Tolmode, [op{ii}.savActPV,'.LOW'], low), end
    end

    for ii = 1:2:length(notOpPvList)
        opId = eval(['OPctrl.ID.',notOpParamCode{ii}]);
        high = op{opId}.Target;
        low = -inf;
        try
          if ~isnan(high), lcaPut([notOpPvList{ii}, '.HIGH'], high); end
          if ~isnan(low),  lcaPut([notOpPvList{ii}, '.LOW'], low); end
        catch
          fprintf('%s Failed to lcaPut %s HIGH or LOW attribute (%s)\n',nowStr, notOpPvList{ii}, op{opId}.ParamCode )
        end
    end
      
end

%%
function calculateParameters()
xRayEnergy = lcaGetSmart('PHYS:SYS0:11:CUHXR:ELOSSELENERGY'); % mJ from Eloss scan.
xRayTao = lcaGetSmart('SIOC:SYS0:ML00:AO820'); % fs FWHM bunch length
if xRayTao ~= 0, 
    xRayPeakPower = xRayEnergy * 1e-3 / (xRayTao * 1e-15) / 1e9;
else
    xRayPeakPower = 0; 
end
lcaPutSmart('SIOC:SYS0:ML00:AO821', xRayPeakPower);


xRayEnergy = lcaGetSmart('PHYS:SYS0:11:CUSXR:ELOSSELENERGY'); % mJ from Eloss scan.
xRayTao = lcaGetSmart('SIOC:SYS0:ML00:CALC289'); % fs FWHM bunch length
if xRayTao ~= 0, 
    xRayPeakPower = xRayEnergy * 1e-3 / (xRayTao * 1e-15) / 1e9;
else
    xRayPeakPower = 0; 
end
lcaPutSmart('SIOC:SYS0:ML00:AO814', xRayPeakPower);



end

function gunBeamVoltsTime()
%fit Klystorn Beam Voltage WF and save fit values to Matlab PVs.
    scaleFactor = lcaGetSmart('SIOC:SYS0:ML01:AO138');
    r = 1:512-60; %Remove last 60 pts.
    v = lcaGetSmart('KLYS:LI20:K6:GUN_2_S_R_WF');
    try
        simpleWF = v(r);
        x = (1:length(simpleWF)) * 9.8; %ns
        simpleWF = simpleWF * scaleFactor; % V
    catch
        fprintf('\n%s Failed on simpleWF get. lcaGet or EPICS problem.\n', datestr(now))
    end
    try
        [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_erfFit(x, simpleWF,1);
        AMP = par(1); XM = par(2);  SIG = par(3); BG = par(4);
        lcaPutSmart('SIOC:SYS0:ML01:AO134' , AMP);
        lcaPutSmart('SIOC:SYS0:ML01:AO135' , XM);
        lcaPutSmart('SIOC:SYS0:ML01:AO136' , SIG);
        lcaPutSmart('SIOC:SYS0:ML01:AO137' , BG);
    catch
        fprintf('%s Failed to Fit klys beam voltage at gunBeamVoltsTime()', datestr(now))
    end

%end

end

