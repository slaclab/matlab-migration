function fbTransTimerFcn(obj, event)
% timer callback function for feedback monitors
%----------------------- -------------------
%
%
% --------- function ----------------------------------------------
% --- the timer function for the feedback monitors
%

%get the loop data structures
loop = getappdata(0, 'Loop_structure');

% check current measurement PV monitors
try
flags = lcaNewMonitorValue([loop.meas.chosenmeasPVs; loop.check.chkPVs]); %NEW
catch
   dbstack;
   flags=0;
end
if all(flags)
    calcFeedback;
else
    % check the status PVs, if any Off then stop the feedback
    try
      flags = lcaNewMonitorValue(loop.statusPVs);
      if any(flags)
        indState = lcaGet(loop.indStatePV);
        state = lcaGet(loop.states.statePV);
        if (strcmp(indState, 'OFF')>0) || (strcmp(state, 'OFF')>0) 
            stop(loop.fbckTimer);
            return;
        end
      end
      % increment the loop counter
      loop.lCnt = loop.lCnt + 1;
      lcaPut(loop.cntPV, loop.lCnt);
      if loop.lCnt >= 99999
         loop.lCnt = 1;
      end
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
    catch
       dbstack;
       % if monitor fails, then the softIOC is dead, stop the feedback.
       message = 'FB00 soft IOC is not responding';
       fbLogMsg(message);
       fbDispMsg(message, loop.feedbackAcro, 2);
       disp(message);
       stop(loop.fbckTimer);
    end
end


function calcFeedback
%  function for feedback calculations
%-----------------------START of FEEDBACK CODE -------------------
%
%
% --------- function ----------------------------------------------
% --- 
% --- this is the function that will execute one feedback calculation

%get the loop data structures
loop = getappdata(0, 'Loop_structure');

% get the TMIT check vals and measurements  %NEW location
try
   checkOK=0;
   if (~isempty(loop.check.chkPVs))
      chkVals = lcaGet(loop.check.chkPVs);
   end
   [curr_meas, tsMatlab, connected, flags] = lcaUtil_NewMonitorValue (loop.meas.chosenmeasPVs);
   % fix up the data
   curr_meas = cell2mat(curr_meas);
   connected = cell2mat(connected)';
catch
   fbDispMsg('No change, cannot read BPM PVs', loop.feedbackAcro, 2);
   disp('No change, cannot read bpm PVs');
   %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end

%check FB00 status PVs
try
   prevEnable = loop.enable;
   loop.enable = lcaGet(loop.enablePV);
   % check the state PVs, if Off then stop the feedback
   indState = lcaGet(loop.indStatePV);
   state = lcaGet(loop.states.statePV);
   if (strcmp(indState, 'OFF')>0) || (strcmp(state, 'OFF')>0) 
      stop(loop.fbckTimer);
      return;
   end
   % increment the loop counter
   loop.lCnt = loop.lCnt + 1;
   lcaPut(loop.cntPV, loop.lCnt);
   if loop.lCnt >= 99999
      loop.lCnt = 1;
   end
   % get the current setpoints 
   loop.states.SPs = lcaGet(loop.states.chosenspPVs);
catch
   message = 'FB00 soft IOC is not responding';
   fbLogMsg(message);
   fbDispMsg(message, loop.feedbackAcro, 2);
   disp(message);
   stop(loop.fbckTimer);
   %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end

if (~isempty(loop.check.infoPVs))
   try
      infoVals = lcaGet(loop.check.infoPVs);
      % update the lowTMIT value from the PV
      loop.check.low = infoVals(1);
      pulseID =infoVals(2);

   catch
      message = 'No change, loTMIT PV invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
      return;
   end
end


%check TMIT check vals to be sure beam is on for this pulse
checkOK = checkCheckPVs(chkVals,loop);

% check the measurement values against limits,
curr_meas = checkMeasurements(curr_meas, loop, tsMatlab, connected, flags);
if (strcmp(loop.enable, 'Enable')>0 )
   % if we have just been enabled, read the current magnet settings 
   % and start from there
   if (strcmp(prevEnable, 'Enable')<=0)
      loop.actData.current = lcaGet(loop.act.chosenactPVs);
      %if this loop is downstream of L3, get energy values from BY1
      try
         BY1_energy = lcaGet('BEND:LTU0:125:BDES');
         if any(strcmp(loop.feedbackAcro, {'BSY'; 'DL2'; 'LTU'; 'LTL'; 'UND'}) )
            loop.act.energy = ones(size(loop.act.energy))*BY1_energy;
            % if this is the UND launch calc F matrix by energy
            if (strcmp(loop.feedbackAcro, 'UND')>0)
               loop.matrix.f = fbCalcUndMatrix(loop.meas, BY1_energy);
            end
         end
         if any(strcmp(loop.feedbackAcro, {'L28'}) )
            epicsActs = regexprep(loop.act.allactPVs, ':\w*', ':EACT', 3);
            loop.act.energy = lcaGet(epicsActs);
         end
      catch
         fbDispMsg('Cannot get energy at BY1', loop.feedbackAcro, 2);
         disp('Cannot get energy at BY1');
      end
   end
   if checkOK>0
      % calc actuator corrections and return the calculated state values
      [ states, act_delta] = calcNewActValues(loop, curr_meas);

      %update the actuators with the new offset
      new_act = loop.actData.current + act_delta;

      %check these new actuator values for validity
      [new_act, rval] = checkActValues(new_act, loop.act.PVs, loop.act.limits);

      if (rval ~= 0)       
         % set actuators 
         try
           lcaPut(loop.act.chosenactPVs, new_act);            
           %rotate out the old calculated actuator values
           loop.actData.nminus2 = loop.actData.nminus1;
           loop.actData.nminus1 = loop.actData.current;
           loop.actData.current = new_act;
           fbDispMsg(' ', loop.feedbackAcro, 0);
         catch
           fbDisMsg('No change to magnets, cannot set BDES', loop.feedbackAcro, 2);
           disp('No change to magnets, cannot set BDES');
         end

      else
         fbDispMsg(['No change to magnets, vals out of range: ' sprintf('%5.4g',new_act)], ...
                    loop.feedbackAcro, 2);
         disp(['No change to magnets, vals out of range: ' sprintf('%5.4g',new_act)]);
      end
      % always store the calculated states, the meas values and the act values
      % if the act values are out of tol this storage will cause an alarm
      storePVs = [loop.states.chosenstatePVs; loop.meas.chosenstorePVs; loop.act.chosenstorePVs;loop.check.pulseidPV];
      storeData = [states; curr_meas; new_act; pulseID];
      try
         lcaPut(storePVs, storeData);
      catch
         fbDispMsg('Cannot save feedback data to FB00', loop.feedbackAcro, 2);
         disp('Cannot save feedback data to FB00');
      end
   else
      disp('NO change to actuators, TMIT PVs out of tol');
   end
end

%update the loop structure and store it
setappdata(0,'Loop_structure',loop);


% --------- function ----------------------------------------------
% --- check the TMIT values against limits on values
function ok = checkCheckPVs(vals, loop)
% check check pvs for 
% the measurement is outside the limits
% newact    the corrected (possibly) setpoint matrix
% curr_act  latest values from setpoints
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

ok = 1;
if (vals(end) > loop.check.low)
   if any(abs(1 - (vals/vals(end))) > loop.check.var)
      fbDispMsg('One or more BPMs TMIT too low', loop.feedbackAcro,  2);
      ok=0;
      return;
   end
else
   fbDispMsg('BPM2 TMIT is too low', loop.feedbackAcro, 2);
   ok=0;
end

% --------- function ----------------------------------------------
% --- check the measurement values against limits on values
function newMeas = checkMeasurements(curr_meas, loop, tsMatlab, connected, flags)
% check measurement values against limits and replace with previous avg if
% the measurement is outside the limits
% newMeas  the corrected (possibly) measurement matrix
% curr_meas  latest values from measurements
% loop       global loop data structure
% tsMatlab   matlab timestamp on each measurement
% connected  indicates connection status of each meas PVs
% flags      indicates if data returned from each PV

if all(flags) && all(connected)
   
else 
   disp('Not complete measurement, device(s) missing');
end

newMeas = curr_meas;


% --------- function ----------------------------------------------
% --- the calculation for new actuator  values
function [states, act_delta] = calcNewActValues(loop, meas)
% calc new values for actuators
% act_delta      newly calculated actuator changes
% meas        latest values from measurements

% divide meas data into X and Y data
x=0; y=0;
for i=1:loop.meas.nummeasPVs
    if (loop.meas.BPM_Xs(i) ==1)
        x = x+1;
        Xs(x) = meas(i);
    else
        y=y+1;
        Ys(y) = meas(i);
    end
end
dimR = round(loop.meas.nummeasPVs / 2);
% 
% fit trajectory ==> p +- dp
%[Xsf,Ysf,p,dp,chisq,Q] = fbXYTrajFit(Xs,dXs,Ys,dYs,Xs0,Ys0,R1s,R3s);
R1s = loop.matrix.f(1:dimR,1:5);
R3s = loop.matrix.f((dimR+1):loop.meas.nummeasPVs,1:5);
[Xsf,Ysf,p,dp,chisq,Q] = fbXYTrajFit1(Xs, loop.meas.dXs, Ys, loop.meas.dYs,...
                         loop.meas.Xs0, loop.meas.Ys0, R1s, R3s);	

% Convert traj. fit results, p, & set-points, p_setp, into 2x & 2y kick angles, theta
p_setp = loop.states.SPs';
[r,c] = size(p_setp);
[rp,cp] = size(p);
if (c<cp) && (c==2)
   p = [p(1,1) p(1,3)];
else
   p = p(1:4);
end
theta = fbGetCorrectorKicks(loop.matrix.g, p, p_setp); % only theta calc here

% conversion from theta to BDES per corrector...
BDESDelta = zeros(1,loop.act.numactPVs);
for j = 1:loop.act.numactPVs	% for each actuator, calculate BDES from theta
  BDESDelta(j) = theta(j)*33.35640951981520*loop.act.energy(j);
end

% apply an overall gain of 0.1 to the actuator deltas
act_delta = BDESDelta'*loop.states.pGain;

% define the states from p
states = p';

% --------- function ----------------------------------------------
% --- check the measurement values against limits on values
function [newact, rval] = checkActValues(curr_act, actPVs, actLimits)
% check setpoint values against limits and replace with ? if
% the measurement is outside the limits
% newact    the corrected (possibly) setpoint matrix
% curr_act  latest values from setpoints
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

%check that act vals are within operating limits
m=0;
la = length(actPVs);
for i=1:la
   if (actPVs(i)==1)
      m=m+1;
      if (curr_act(m) < actLimits.low(i) || curr_act(m) > actLimits.high(i) )
         disp('WARNING: actuator value is outside limits');
         rval = 0;
         newact=curr_act;
         return;
      end
   end
end
rval = 1;
newact = curr_act;


% --------- function ----------------------------------------------
% --- add latest data to the input  
function data  = addToData(data,x)
% this function will add vector x to the data matrix data.data. if 
% data.data has reached its maximum size, the data.data is cleared
% and started over.
% data    the data storage structure to be updated
% x       the  matrix to be added in
if data.count < data.max
    data.count = data.count+1;
else
    data.count = 1;
end
data.data(data.count,:) =x;
