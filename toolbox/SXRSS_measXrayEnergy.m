function [] = SXRSS_measXrayEnergy()

%bykikPV='IOC:BSY0:MP01:BYKIKCTL';
%feePV='DIAG:FEE1:202:241:Data';
gasPV='GDET:FEE1:241:ENRCHSTBR';
%data=[];


str=questdlg('Retract optics using main SXRSS GUI');
lcaPutSmart(bykikPV, 0); % Disable beam

% Check undulator 1-8 x-ray pulse energy:
rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE'); % Get beam rate
pause(120/rate);
gasData=lcaGet(gasPV);
gasData(1:end-120)=[];
stdError=std(gasData)/sqrt(120);
meanGasBG=mean(gasData);


if stdError > 1e-3
    warndlg('More than 1uJ noise. Aborting')
    lcaPutSmart(bykikPV, 1); % Permit Beam
    return
end


str=questdlg('About to retract Undulator Segments 10-33. Proceed?');

if ~strcmp('Yes', str)
    lcaPutSmart(bykikPV, 1); % Permit Beam
    return
end

segmentMoveInOut([10:15 17:33],0); %Retract undulators 10-3
rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE'); % Get beam rate
pause(120/rate);
gasData=lcaGet(gasPV);
gasData(1:end-120)=[];
meanGas=mean(gasData);
disp(meanGas-meanGasBG);


% % (2) Measure noise level (std. error = std / # of shot (~100)
% % ** Get 100 DIAG:FEE1:202:241:Data waveforms, 
% for i=1:5
%     data(end,i)=lcaGetSmart(feePV)
% end
% 
% size(data)


% (3a) if std. error > 1uJ - warning box: increase gain & recalibrate 
% (3b) if std. eror < 1uJ  proceed
% (4) warning box: Ask operator to remove all undulators (10 - 33), omit und 16
% ** Leave undulator segments 1-8 unchanged
%segmentMoveInOut(10:33,1); %Insert undulators 10-33

% ** Check gas detector saturation
% ** Get 100 DIAG:FEE1:202:241:Data waveforms, get minimum value (signal inverted) of each, 
% ** get mean and std of minimums, check if mean - 2*std > -2^15.
% ** If not, remind user to lower gas pressure or PMT voltages.

% ** Do E-loss scan; calibrate gas detectors
% segmentMoveInOut([10:15 17:33],0); %Retract undulators 10-33
% ** Up to this needs to be done only once if electron beam energy stays the same.

% Check undulator 1-8 x-ray pulse energy:
%rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE'); % Get beam rate


% Block beam at BYKIK
% wait for 120 shots
% Get BSA beam rate data for gas detector, take last 120 shots, this is background
% Unblock beam at BYKIK
% wait for 120 shots
% Get BSA beam rate data for gas detector, take last 120 shots, this is signal
% Post difference to user as FEL pulse energy
% Update Guardian with new pulse energy and machine settings.
% (8a) Msg Box - Power OK
% (8b) Msg Box - Power Not Ok



