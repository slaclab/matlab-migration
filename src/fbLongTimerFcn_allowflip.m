
function fbLongTimerFcn(obj, event)
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
%flags = lcaNewMonitorValue([loop.meas.chosenmeasPVs; 'EVR:XL04:1:PULSEID']);

%the following will check that there are new data for all measurement
%devices.  If not, just inc counter and try again later. This will insure
%that a dead measurement ioc will not crash feedback
try
   flags = lcaNewMonitorValue(loop.meas.chosenmeasPVs);
catch
   dbstack;
   flags = 0;
end
if all(flags) 
       calcFeedback;
else
   % check the status PVs, 
   try
      flags = lcaNewMonitorValue(loop.statusPVs);
      % if any status pvs are Off then stop the feedback
      if any(flags)
        indState = lcaGet(loop.indStatePV);
        state = lcaGet(loop.states.statePV);
        if (strcmp(indState, 'OFF')>0) || (strcmp(state, 'OFF')>0) 
            stop(loop.fbckTimer);
            return;
        end
      end
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
       fbLogMsg([loop.feedbackAcro ' FB00 soft IOC is not responding - may require reboot.']);
       disp([loop.feedbackAcro ' FB00 soft IOC is not responding - may require reboot.']);
        stop(loop.fbckTimer);
       return;
    end
end


function calcFeedback
%  function for feedback calculations
%-----------------------START of FEEDBACK CODE -------------------
%
%
% --------- function ----------------------------------------------
% --- this is the function that will execute one feedback calculation
%
% The functions in this module are specific to the Longitudinal feedback
% where L0B and L1S are actuators, BPM13, BPMS11, and BL11 are measurement
% devices. 

%get the loop data structures
loop = getappdata(0, 'Loop_structure');

try
   % reset status string
   %fbDispMsg(' ', loop.feedbackAcro, 0);
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
   message = 'FB00 soft IOC is not responding.'; 
   fbLogMsg(message);
   fbDispMsg(message, loop.feedbackAcro, 2);
   stop(loop.fbckTimer);
   %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end

% get measurements
try
   [curr_meas, tsMatlab, connected, flags] = lcaUtil_NewMonitorValue (loop.meas.chosenmeasPVs);
   %fix up these return values
   curr_meas = cell2mat(curr_meas);
   connected = cell2mat(connected)';
catch
   message = 'No change to RF, BPMs read invalid';
   fbLogMsg(message);
   fbDispMsg(message, loop.feedbackAcro, 2);
   %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end

%check TMITs to be sure beam is on for this pulse
chkVals = 0;
dsprVals = 0;
mirrorVals = 0;
if (~isempty(loop.check.chkPVs))
   try
      chkVals = lcaGet(loop.check.chkPVs);
   catch
      message = 'No change to RF, TMIT PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
      return;
   end
end
if (~isempty(loop.check.dsprPVs))
   try
      dsprVals = lcaGet(loop.check.dsprPVs);
   catch
      message = 'No change to RF, Dspr. PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
      return;
   end
end
if (~isempty(loop.check.mirrorPVs))
   try
      mirrorVals = lcaGet(loop.check.mirrorPVs);
   catch
      message = 'No change to RF,mirror PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
      return;
   end
end

checkOK = checkCheckPVs(chkVals, dsprVals, mirrorVals, loop);

% if loop is enabled and data is good, continue
if strcmp(loop.enable, 'Enable')>0 
   if checkOK>0
      % get the current setpoints 
      loop.states.SPs = lcaGet(loop.states.chosenspPVs);

      % check the measurement values: connected, flags  - 
      % make adjustments to measurements here, change them to ratio diff from
      % setpoint value
      [corrected_meas, avg_meas, loop] = checkMeasurements(curr_meas, loop, tsMatlab, connected, flags);
      % calc states in real units, not percent
      curr_states = calcStateValues(corrected_meas, loop);
      
      % check that the measurements and states are usable
      if any(isnan(avg_meas)) || any(isnan(curr_states))
         fbDispMsg('No change to RF, bad measurements', ...
                    loop.feedbackAcro, 2);
         %bad measurements - update the loop structure, store it and return
         setappdata(0,'Loop_structure',loop);
         return;
      end
      
      %calc new actuator values, updates loop structure so return that too
      [new_act, loop, r_NaN] = calcNewActValues(corrected_meas, loop);
      if (r_NaN ~= 0)
         %check these new actuator values for validity
         [new_act, loop, rlim, rval] = checkActValues(new_act, loop.act.PVs, loop.act.limits, loop);
         % if actuator values are within limits, apply them
         if (rlim ~= 0) && (rval ~= 0)
            % set actuators 
            try
               lcaPut(loop.act.chosenactPVs, new_act);
               % reset status string
               fbDispMsg(' ', loop.feedbackAcro, 0);
            catch
                fbDispMsg('No change to RF, ca error on put', loop.feedbackAcro, 2);
            end      
         else
            if (rlim==0)
               fbDispMsg(['No change to RF, new vals out of range' sprintf(' %5.4g ',new_act)], ...
                    loop.feedbackAcro, 2);
            else
               fbDispMsg('No change to RF, add or drop a klys', loop.feedbackAcro, 2);
            end
         end
      else
         fbDispMsg('No change to RF, add or drop a klys',loop.feedbackAcro, 2);
      end

      % always store the calculated states, the meas values, and the act values
      % if they are not within range, then the storage will cause an alarm
      storePVs = [loop.states.chosenstatePVs; loop.meas.chosenstorePVs; loop.act.chosenstorePVs];
      storeData = [curr_states; avg_meas; new_act];
      if (r_NaN == 0)
         fbDispMsg('No change to RF, add or drop a klys',loop.feedbackAcro, 2);
      else
         try
            lcaPut(storePVs, storeData);
         catch
            fbDispMsg('Cannot save feedback data, ca error.', ...
                    loop.feedbackAcro, 2);
         end
      end
   else
      disp('NO change to RF, BPM TMITs too low');
   end
end

%update the loop structure and store it
setappdata(0,'Loop_structure',loop);

% --------- function ----------------------------------------------
% --- check the measurement values 
function [newMeas, avgMeas, newLoop] = checkMeasurements(curr_meas, loop, tsMatlab, connected, flags)
%
% newMeas  the corrected (possibly) measurement matrix
% curr_meas  latest values from measurements
% loop       global loop data
% tsMatlab   matlab timestamps of data
% connected  indicates connection status of each meas PVs
% flags      indicates if data returned from each meas PVs

%store this measurement data into running avg. structure
%this changes the loop struct. pass it back out
loop.measData = addToData(loop.measData, curr_meas);

% divide out dispersion effect for BPMs, create dI/I ratio for BLEN
m = 0;
avg_meas = curr_meas;
for i=1:length(loop.meas.allmeasPVs)
   if loop.meas.PVs(i)==1
      m=m+1;
      %is it bunch length?
      if ~isempty(strfind(loop.meas.allmeasPVs{i,1},'BLEN'))
         % use the running average of bunch length signal
         curr_meas(m) = loop.measData.avg(m);
         avg_meas(m) = curr_meas(m);
         %BLEN: create dI/I ratio  using the setpoint value, (meas/sp)-1
         curr_meas(m) = (curr_meas(m)/loop.states.SPs(m))-1;
      else
         % BPM: divide out dispersion value - ref=0, becomes meas/disp
         %curr_meas(m) = (curr_meas(m)-loop.refData.data(m))/loop.meas.dispersion(i);
         % Let us again keep reference orbit and setpoint for BPMs --jw
         % as in the transverse feedback 
         % curr_meas(m) = curr_meas(m)/loop.meas.dispersion(i);
         if i == 1
             curr_meas(m) = (curr_meas(m)/loop.meas.dispersion(i) + ...
                             1 )*(135.0/loop.states.SPs(m)) - 1;
         elseif i == 2
             curr_meas(m) = (curr_meas(m)/loop.meas.dispersion(i) + ...
                             1 )*(250.0/loop.states.SPs(m)) - 1;
         elseif i == 4
             curr_meas(m) = (curr_meas(m)/loop.meas.dispersion(i) + ...
                             1 )*(4300.0/loop.states.SPs(m)) - 1;
         end
         %Notice that in the above, the reference orbit, here is
         %the reference energy is hardcoded as (135, 250, 4300) Mev
         %for (DL1, BC1, BC2). --jw
       end
   end
end

if all(flags) && all(connected)
   %check timestamp info to be sure all from same pulse?
else 
   fbDispMsg('Not complete measurement-dev(s) missing', loop.feedbackAcro, 1);
end
       
newMeas = curr_meas;
avgMeas = avg_meas;
newLoop = loop;

% --------- function ----------------------------------------------
% --- check the measurement values against limits on values
function ok = checkCheckPVs(vals, dvals, mvals, loop)
% check check pvs for 
% the measurement is outside the limits
% newact    the corrected (possibly) setpoint matrix
% curr_act  latest values from setpoints
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

ok = 1;
fbckNum = str2num(loop.feedbackNum);

% check the dispersion pvs
% if this is for Num 2 or 3 going thru BC1, 
if (fbckNum > 1)
   if (dvals(1)<100)
      fbDispMsg('Dispersion in BC1 is too low', loop.feedbackAcro, 2);
      ok=0;
      return;
   end
else
   % check 4-7 going thru BC2
   if (fbckNum > 3)
      if (dvals(2)<100)
         fbDispMsg('Dispersion in BC2 is too low', loop.feedbackAcro, 2);
         ok=0;
         return;
      end
   end
end

% check bunchlength mirrors
% BC1 for feedback 3, 5, 6
if (mvals(1)<1)
   switch (fbckNum)
      case {3, 5, 6}
         fbDispMsg('BL11 Mirror in LI21 is OUT', loop.feedbackAcro, 2);
         ok=0;
         return;
   end
else
   if (fbckNum > 3)
      % BC2 mirror for 6
      if (mvals(2)<1)
         switch (fbckNum)
            case {6}
               fbDispMsg('BL21 Mirror in LI24 is OUT', loop.feedbackAcro, 2);
               ok=0;
               return;
         end
      end
   end
end

%check TMIT values
if (vals(end) < loop.check.low)
   fbDispMsg('BPM2 TMIT is too low', loop.feedbackAcro, 2);
   ok=0;
else
   switch (fbckNum)
      case {0, 1, 2, 3}
         if any(abs(1 - (vals/vals(end))) > loop.check.var)
            fbDispMsg('One or more BPMs TMIT too low', loop.feedbackAcro,  2);
            ok=0;
         end;
      case {4, 5, 6}
         if any(vals < loop.check.low)
            fbDispMsg('One or more BPMs TMIT too low', loop.feedbackAcro,  2);
            ok=0;
         end
   end
end

% --------- function ----------------------------------------------
% --- the calculation for new actuator  values
function [newact, newloop, ok] = calcNewActValues(meas, loop)
% calc new values for actuators
% newact      newly calculated setpoints
% meas        latest values from measurements

ok=1;
err_n = meas;

%this updates the loop structure - pass it back out
loop.errData = addToData(loop.errData, err_n);

%re-calc F matrix if LNG4,5,6 this test assumes 
if str2num(loop.feedbackNum)>3
   setappdata(0, 'tempParams', loop.matrix.params );
   [loop.matrix.f, ok] = fbGetLongFmatrix();
   loop.matrix.mult = loop.matrix.g.*loop.matrix.f;
end

%now do proportional gain
err_p = (loop.matrix.mult*err_n); 
%now do integral 
err_sum = (sum(loop.errData.data,2));
err_i = (loop.matrix.mult*err_sum); 

% calc new actuator values using PI gains 
newact = loop.actData.current - (loop.states.pGain*err_p) - (loop.states.iGain*err_i);
if any(isnan(newact))
   ok=0;
end
newloop = loop;



% --------- function ----------------------------------------------
% --- check the measurement values against limits on values
function [newact, newloop, rlim, rval] = checkActValues(curr_act, actPVs, actLimits, loop)
% check setpoint values against limits and replace with ? if
% the measurement is outside the limits
% newact    the corrected (possibly) setpoint matrix
% newloop   the updated  loop structure, with current values rotated in
% rval      return value =0 if act vals bac, =1 of act vals ok
%
% curr_act  latest values from setpoints
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

rlim = 1;
rval = 1;
%check that actuator vals are within operating limits
m=0;
la = length(actPVs);
for i=1:la
   if (actPVs(i)==1)
      m=m+1;
      if (curr_act(m) < actLimits.low(i) || curr_act(m) > actLimits.high(i) )
         disp('WARNING: actuator value is outside limits');
         rlim = 0;
         newact=curr_act;
         return;
      end
   end
end

% phases must remain between +/-180 for LNG4,5,6
fbckNum=str2num(loop.feedbackNum);
if (fbckNum == 4)
   curr_act(3:4) = mod(curr_act(3:4)+180, 360) - 180;
else
   if (fbckNum > 4)
      curr_act(3:5) = mod(curr_act(3:5)+180, 360) - 180;
   end
end

% find the larger of the two phases 24-1 and 24-2
if str2num(loop.feedbackNum)>3
   len = loop.act.numactPVs;   
   
   last24_1 = loop.actData.current(len-1,1);
   last24_2= loop.actData.current(len,1);
   
   actmax = max(curr_act(len,1),curr_act(len-1,1));
   actmin = min(curr_act(len,1),curr_act(len-1,1));
   
   %if actmax has passed the +180 or actmin passed -180, allow the phases to flip
   %if ( abs(last24_1 - curr_act(len-1,1)) > 350 ) || ( abs(last24_2 - curr_act(len,1)) > 350 )
   %   if loop.actData.Ph24_1_ismax==1
   %      curr_act(len,1) = actmax;
   %      curr_act(len-1,1) = actmin;
   %      loop.actData.Ph24_1_ismax = -1;
   %   else
   %      curr_act(len-1,1) = actmax;
   %      curr_act(len,1) = actmin;
   %      loop.actData.Ph24_1_ismax = 1;
   %   end
   % else
   %   % otherwise, keep phases as they are
   %   if loop.actData.Ph24_1_ismax==1
   %      curr_act(len,1) = actmin;
   %      curr_act(len-1,1) = actmax;
   %   else
   %      curr_act(len-1,1) = actmin;
   %      curr_act(len,1) = actmax;
   %   end
   % end
   
   
   %when phases near +90 & -90  this is ok, but don't apply new actuators
   if (abs(curr_act(len-1,1)-90)<2) && (abs(curr_act(len,1)+90)<2) || ...
      (abs(curr_act(len-1,1)+90)<2) && (abs(curr_act(len,1)-90)<2)   
      curr_act(len-1,1)=loop.actData.current(len-1,1);
      curr_act(len,1) = loop.actData.current(len,1);
   end
   %when phases near 0 & 180 this is ok, but don't apply new actuators
   if abs( curr_act(len,1) - (180 - curr_act(len-1,1)) )<0.25
      curr_act(len-1,1)=loop.actData.current(len-1,1);
      curr_act(len,1) = loop.actData.current(len,1);
   end
   
   %check for phase drifting...when phases both near 0 show error
   if ( (abs(curr_act(len-1,1))<2) && (abs(curr_act(len,1))<2) )
      rval=0;
   end
   %check for phase drifting...when phases both near 180 show error
   if ( (abs(curr_act(len-1,1)-180)<2) && (abs(curr_act(len,1)-180)<2) )
      rval=0;
   end
   %check for phase drifting...when phases are nearly identical show error
   if abs( curr_act(len-1, 1) - curr_act(len,1) )<2 %1e-2
      rval=0;
   end
end

if (rval~=0)
   %rotate out the old calculated actuator values
   % we save 3 previous vals, but only use the one past at this time.
   loop.actData.nminus2 = loop.actData.nminus1;
   loop.actData.nminus1 = loop.actData.current;
   loop.actData.current = curr_act;
   if str2num(loop.feedbackNum)>3
      len = loop.act.numactPVs;   
      loop.actData.curr_actmax = max(loop.actData.current(len,1),loop.actData.current(len-1,1));
      loop.actData.curr_actmin = min(loop.actData.current(len,1),loop.actData.current(len-1,1));
   end;
end

newact = curr_act;
newloop = loop;


% --------- function ----------------------------------------------
function statevals = calcStateValues(measvals, loop)
% calc the State values from  the measurement values 
% This function is specific to longitudinal feedback and assumes the
% states are in a specific order
%
% statevals    the corrected values of the states
% measvals  latest values from measurement devices
% measvals(1) is DL1 Energy, measvals(2) is BC1 Energy
% measvals(3) is for bunchlenght, which will stay as percentage

fbckNum=str2num(loop.feedbackNum);

for i=1:length(measvals)
   statevals(i) = (1 + measvals(i))*loop.states.SPs(i);
end
statevals = statevals';


% --------- function ----------------------------------------------
% --- add latest data to the input  
function data  = addToData(data, x)
% this function will add vector x to the data matrix data.data. if 
% data.data has reached its maximum size, the count is set to one
% and started over. this is a simplified circular buffer, the only
% use for this data is to calc a sum of values, so it doesnt matter what
% the order of data is
%
% data    the data storage structure to be updated
% x       the  matrix to be added in
if data.count < data.max
    data.count = data.count+1;
else
    data.count = 1;
    data.wrap = 1;
end
data.data(:,data.count) =x;
if data.wrap
   data.avg = sum(data.data,2)/data.max;
else
   data.avg = sum(data.data,2)/data.count;
end
