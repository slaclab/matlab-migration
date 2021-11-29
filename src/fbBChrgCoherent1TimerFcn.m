function fbBChrgTimerFcn(obj, event)
% timer callback function for feedback monitors
%----------------------- -------------------
%
%
% --------- function ----------------------------------------------
% --- the timer function for the feedback monitors
%
% check current measurement PV monitors
%get the loop data structures

loop = getappdata(0, 'Loop_structure');
% read the MOVN and DMOV pvs and be sure the waveplates are ready to move
wpVals = lcaGet(loop.check.wpPVs);
if (((wpVals(1) ==0) && (wpVals(2)==1)) && ((wpVals(3) ==0) && (wpVals(4)==1)))
      % both waveplates stopped and ready for another command
      calcFeedback;
else
   if (((wpVals(1) ==0) && (wpVals(2)==0)) || ((wpVals(3) ==0) && (wpVals(4)==0)))
      % a waveplate is in an error state
      fbDispMsg('No change,laser or VCC waveplate error',loop.feedbackAcro, 2);
   end;
end;
      
end

function calcFeedback
%  function for feedback calculations
%-----------------------START of FEEDBACK CODE -------------------
%
%
% --------- function ----------------------------------------------
% --- this is the function that will execute one feedback calculation
%
% The functions in this module are specific to the Bunch Charge feedback
% where a softIOC PV LASR:IN20:1:PCTRL is the actuator, and 
% BPM221 is the measurement device.
% this loop averages samples of the BPM221 TMIT and uses the average meas.

% turn off eDef messages
global eDefQuiet;

%get the loop data structures
loop = getappdata(0, 'Loop_structure');
try
   % clear out message string
   %fbDispMsg(' ', loop.feedbackAcro, 0);
   loop.prev_enable=loop.enable;
   loop.enable = lcaGet(loop.enablePV);

   % check the state PVs, if Off then stop the feedback
   indState = lcaGet(loop.indStatePV);
   state = lcaGet(loop.states.statePV);
   if (strcmp(indState, 'OFF')>0) || (strcmp(state, 'OFF')>0) 
      stop(loop.fbckTimer);
      return;
   end
   % increment the loop counter, and check the enable PV.
   % the enable PV is used to allow users/programs to temporarily disable the
   % feedback.  The user or program is responsible for enabling feedback again
   % via this PV, when done.
   loop.lCnt = loop.lCnt + 1;
   lcaPut(loop.cntPV, loop.lCnt);
   if loop.lCnt >= 99999
      loop.lCnt = 1;
   end
catch
   message='FB00 soft IOC is not responding.';
   fbLogMsg(message);
   fbDispMsg(message, loop.feedbackAcro, 2); %error
   disp(message);
   stop(loop.fbckTimer);
   return;
end
try
   infoVals = lcaGet(loop.check.infoPVs);
   % update the lowTMIT value from the PV
   loop.check.low = infoVals(1);
   % replace the BPM 2 low limit with the lowTMIT value
   lcaPut('BPMS:IN20:221:TMITBCI0LTOL',infoVals(1));
   lcaPut('EDEF:SYS0:19:NAME', 'bunch-charge-feedback');
   eDefParams(loop.eDefNumber, 1, loop.samples, {''}, {''},  {''}, {''});    
   loop.meas.limits.low(1) = infoVals(1);   
      % save this pulseid
   pulseID = infoVals(2);
catch
   fbDispMsg('No change to power, TMIT low or ca err',loop.feedbackAcro, 2);
   disp('No change power,TMIT low or ca err' );
   %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end
   
% get measurements
try
   result.acqTime = eDefAcq(loop.eDefNumber, 20);
   curr_meas = lcaGet(loop.meas.chosenmeasPVs);
   checkOK = 1;
catch
   fbDispMsg('No change to power, TMIT low or ca err',loop.feedbackAcro, 2);
   disp('No change power,TMIT low or ca err' );
   %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end

% check the measurement values: connected, flags  - 
% make adjustments to measurements here
avg_meas = checkMeasurements(curr_meas, loop);

% check validity of measurements
if avg_meas<=0
   checkOK = 0;
end

% if loop is enabled and data is good, continue
if strcmp(loop.enable, 'Enable')>0 
   if checkOK>0
      % get current act value - some thing might have changed it, or it
      % might have maxed out
      loop.actData.current = lcaGet(loop.act.chosenactPVs);

      %calc new actuator values, updates loop structure so return that too
      [new_act, loop] = calcNewActValues(avg_meas, loop);
      %check these new actuator values for validity
      [new_act, rval] = checkActValues(new_act, loop.actData.current, loop.act.PVs, loop.act.limits);
      % calc states in real units, not percent
      curr_states = calcStateValues(avg_meas);
      
      % if actuator values are within limits, apply them
      if (rval ~= 0) 

         if (~isempty(loop.check.chkPVs))
            chkVals = lcaGet(loop.check.chkPVs);
            checkOK = checkCheckPVs(chkVals,loop.check, loop);
         end
         if checkOK>0
            %rotate out the old calculated actuator values
            % we save 2 previous vals, but only use the one past at this time.
            loop.actData.nminus1 = loop.actData.current;
            loop.actData.current = new_act;

            % set actuators 
            lcaPut(loop.act.chosenactPVs, new_act);
            % clear out message string
            fbDispMsg(' ', loop.feedbackAcro, 0);
         end
         % store the calculated states, the meas values, and the act values
      else
         fbDispMsg('No change to power,new val out of range',loop.feedbackAcro, 2);
         disp(['No change to power, new val out of range: ' sprintf(' %5.4g ',new_act)]);
      end
      % always store the calculated states, the meas values and the act values
      % if the act values are out of tol this storage will cause an alarm
      storePVs = [loop.states.chosenstatePVs; loop.meas.chosenstorePVs; loop.act.chosenstorePVs; loop.check.pulseidPV];
      storeData = [curr_states; avg_meas; new_act; pulseID];
      lcaPut(storePVs, storeData);
   else
      fbDispMsg('NO change to power, BPM2 TMIT low/stuck', loop.feedbackAcro, 2);
      disp('NO change to power, BPM2 TMIT too low or stuck');
   end
end

%update the loop structure and store it
setappdata(0,'Loop_structure',loop);
end

% --------- function ----------------------------------------------
% --- check the TMIT values against limits on values
function ok = checkCheckPVs(vals, check, loop)
% check check pvs for 
% the measurement is outside the limits
% newact    the corrected (possibly) setpoint matrix
% curr_act  latest values from setpoints
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

   ok = 1;
   if (vals(end) < check.low)
      fbDispMsg('BCI: BPM2 TMIT value is too low', loop.feedbackAcro, 2);
      ok=0;
   end
end

% --------- function ----------------------------------------------
% --- check the measurement values 
function newMeas = checkMeasurements(curr_meas, loop)
%
% compare measurements with limits, average samples, the measurements
% are in units of number of electrons Nel
%
% newMeas  the average measurement matrix
% curr_meas  latest values from measurements
% loop       global loop data
%

Nel = zeros(loop.meas.nummeasPVs);
cnt = zeros(loop.meas.nummeasPVs);
m=0;
prev_el = -1;
stuck = 0;
la = length(loop.meas.PVs);
for i=1:la
   if (loop.meas.PVs(i)==1)
      m=m+1;
      for s=1:loop.samples
         n_el = curr_meas(m,s); 
         %check that n_el is within limits
         if (n_el>=loop.meas.limits.low(i) && n_el<=loop.meas.limits.high(i) )
            Nel(m) = Nel(m) + n_el;
            cnt(m) = cnt(m) + 1;
         end
         %check that n_el is not stuck
         if n_el==prev_el
            stuck = stuck+1;
         else
            stuck = 0;
            prev_el = n_el;
         end
      end
      % if we have at least one good meas return it
      if cnt(m)>0 
         Nel(m) = Nel(m)/cnt(m);
      else
         Nel(m)=0;
      end
      % if more than 2 measurements in a row were identical, we have a
      % stuck BPM
      if stuck>2
         Nel(m) = 0;
      end
   end
end
      
newMeas = Nel;

end


% --------- function ----------------------------------------------
% --- the calculation for new actuator  values
function [newact, newloop] = calcNewActValues(meas, loop)
% calc new values for actuators
% newact      newly calculated setpoints
% meas        latest values from measurements

% get the current setpoints 
SPs = lcaGet(loop.states.chosenspPVs); %SPs in nC
%correct Nel meas to nC so that units match with setpoints
meas_nC = meas*1.602e-10; % nC=1.602e-10 elect.

%first get the error from setpoint, make it a ratio
if all(SPs)
  err_n = (meas_nC - SPs)/meas_nC;
else
  err_n = (meas_nC - SPs);
end

correction = loop.states.pGain*err_n;
if correction>1
   correction = correction*SPs;
end
% calc new actuator values using proportional gain, mult by 100 for percent 
newact = loop.actData.current*(1 - correction);
newloop = loop;
end

% --------- function ----------------------------------------------
% --- check the measurement values against limits on values
function [newact, rval] = checkActValues(new_act, curr_act, actPVs, actLimits)
% check act values against limits and return false if
% the measurement is outside the limits
% newact    the corrected (possibly) setpoint matrix
% rval      return value =0 if act vals bac, =1 of act vals ok
%
% curr_act  latest values from setpoints
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

m=0;
la = length(actPVs);
for i=1:la
   if (actPVs(i)==1)
      m=m+1;
      if (new_act(m) < actLimits.low(i) || new_act(m) > actLimits.high(i) )
         if (new_act(m) < actLimits.low(i))
            if (curr_act(m)==actLimits.low(i))
               rval = 0;
               newact=new_act;
               return;
            else
               new_act(m)=actLimits.low(i);
            end
         else
            if (curr_act(m)==actLimits.high(i))
               rval=0;
               newact=new_act;
               return;
            else
               new_act(m)=actLimits.high(i);
            end
         end
      end
   end
end
rval = 1;
newact = new_act;
end

% --------- function ----------------------------------------------
function statevals = calcStateValues(measvals)
% calc the State values from  the measurement values 
% This function is specific to bunch charge feedback
% convert Nel for BPM measumements, to nC for charge State
%
% statevals    the corrected values of the states
% measvals  latest values from measurement devices

statevals = measvals*1.602e-10;
end
