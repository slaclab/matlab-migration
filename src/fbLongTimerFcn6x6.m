function fbLongTimerFcn6x6(obj, event)
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
        if (strcmp(indState, 'OFF')>0)% || (strcmp(state, 'OFF')>0) 
            setappdata(0,'Loop_structure',loop);
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
       setappdata(0,'Loop_structure',loop);
       stop(loop.fbckTimer);
       return;
    end
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
% where L0B and L1S, L2 and L3 are actuators, BPM13, BPMS11, and BL11, 
% BPMS21, BL21, and BPMs in the BSY or LTU area are measurement devices. 

%get the loop data structures
loop = getappdata(0, 'Loop_structure');
%fbckNum = str2double(loop.feedbackNum);

try
   loop.enable = lcaGet(loop.enablePV);

   % check the state PVs, if Off then stop the feedback
   indState = lcaGet(loop.indStatePV);
   state = lcaGet(loop.states.statePV);
   if (strcmp(indState, 'OFF')>0) % || (strcmp(state, 'OFF')>0) 
      setappdata(0,'Loop_structure',loop);
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
   setappdata(0,'Loop_structure',loop);
   stop(loop.fbckTimer);
   return;
end

if (~isempty(loop.check.infoPVs))
   try
      infoVals = lcaGet(loop.check.infoPVs);
      % update the lowTMIT value from the PV
      loop.check.low = infoVals(1);
      pulseID =infoVals(2);

   catch
      message = 'No change, TMIT PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
      return;
   end
end
% get the energy at DL2
if (~isempty(loop.meas.DL2_energy))
   try
     loop.meas.DL2_energy = lcaGet('BEND:LTU0:125:BDES')*1000; %convert GeV to MeV
   catch
    %update the loop structure and store it
     setappdata(0,'Loop_structure',loop);
     return;
   end
end

%check all the conditions
checkOK = 1;
%update the loop structure and store it
setappdata(0,'Loop_structure',loop);

%check desired states and machine conditions
statesConfig = fbCheckMachineConditions(loop);
statesConfig.used = fbCheckBeamConditions(statesConfig, loop);
if ~any(statesConfig.used)
   checkOK=0;
elseif (any(loop.states.config.used~=statesConfig.used) ||...
        (loop.states.config.toBSY~=statesConfig.toBSY) ||...
        (loop.states.config.toSpectDump~=statesConfig.toSpectDump) ||...
        (loop.states.config.yesBYKIK~=statesConfig.yesBYKIK) )
   loop.states.config = statesConfig;
    %update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   fbLongReconfigure();
end

%loop.states.config = statesConfig;
%get the latest loop data structures
loop = getappdata(0, 'Loop_structure');

% if data is good, continue
if (checkOK>0) && (~isempty(loop.meas.chosenmeasPVs))
      
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

   % get the current setpoints 
   loop.states.SPs = lcaGet(loop.states.allspPVs);

   % check the measurement values: connected, flags  - 
   % make adjustments to measurements here, change them to ratio diff from
   % setpoint value
   % reduce the 2 or 3 L3 BPM measurements to a single meas value, so the 
   % length of the corrected_meas vector is less than curr_meas vector
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
   %this returns actuator values with phases for L2, L3
   [temp_act, loop, r_NaN] = calcNewActValues(corrected_meas, loop);
   if (r_NaN ~= 0)
      %check these new actuator phases for validity
      [full_act, put_act, loop, rlim] = checkActValues(temp_act, loop.act.PVs, loop.act.limits, loop);
      % if actuator values are within limits, apply them
      if (rlim == 0)
         try
           % COMMENT OUT FOR TESTING
           %if enabled, use the new act values
           if strcmp(loop.enable, 'Enable')>0 
             lcaPut(loop.act.chosenactPVs, put_act);
             %pause(0.1);
          else
             %not enabled, replace new act values with current setting
             loop.actData.current = lcaGet(loop.act.allactPVs);
             %loop.actData.current_ec = lcaGet(loop.act.EandCPVs);
           end
            % reset status string
            fbDispMsg(' ', loop.feedbackAcro, 0);
            %fbDispMsg(' COMPUTE MODE ', loop.feedbackAcro, 0);
         catch
             fbDispMsg('No change to RF, ca error on put', loop.feedbackAcro, 2);
         end  
      end
      if (rlim == 1)
         fbDispMsg('No change, add or drop a klys',loop.feedbackAcro, 2);
      else
         if (rlim == -1)
            fbDispMsg('No change, add or drop a klys',loop.feedbackAcro, 2);
         end
      end
   end

   % always store the calculated states, the meas values, and the act values
   % if they are not within range, then the storage will cause an alarm
   %storePVs = [loop.states.chosenstatePVs; loop.meas.chosenstorePVs; loop.act.chosenstorePVs; loop.check.pulseIDStorePV];
   %storeData = [curr_states; avg_meas; new_act; pulseID];
   storePVs = [loop.states.allstatePVs; loop.meas.allstorePVs; loop.act.allstorePVs; loop.check.pulseidPV];
   storeData = [curr_states; avg_meas; full_act; pulseID];
   if (r_NaN == 0)
      fbDispMsg('No change to RF, drop a klys(NaN)',loop.feedbackAcro, 2);
   else
      try
         lcaPut(storePVs, storeData);
      catch
         fbDispMsg('Cannot save feedback data, ca error.', ...
                 loop.feedbackAcro, 2);
      end
   end
%else
%   disp('NO change to RF, BPM TMITs too low');

%update the loop structure and store it
setappdata(0,'Loop_structure',loop);
end
end


% --------- function ----------------------------------------------
% --- check the measurement values against limits on values
% --------- function ----------------------------------------------
% --- check the measurement values 
function [newMeas, avgMeas, newLoop] = checkMeasurements(meas, loop, tsMatlab, connected, flags)
%
% newMeas  the corrected (possibly) measurement matrix
% curr_meas  latest values from measurements
% loop       global loop data
% tsMatlab   matlab timestamps of data
% connected  indicates connection status of each meas PVs
% flags      indicates if data returned from each meas PVs

% first copy measured data into full vector of 6 with zeros where no device
% is read
m=0;
curr_meas = zeros(length(loop.meas.allmeasPVs),1);
for i=1:length(loop.meas.allmeasPVs)
   if (loop.meas.PVs(i)>0)
      m=m+1;
      curr_meas(i) = meas(m);
   end
end
   
%store this measurement data into running avg. structure
%this changes the loop struct. pass it back out
loop.measData = addToData(loop.measData, curr_meas);

% divide out dispersion effect for BPMs, create dI/I ratio for BLEN
avg_meas = curr_meas;
%we are calculating up to 6 measurement values
new_meas = zeros(length(loop.states.allstatePVs),1); 
for i=1:length(loop.meas.allmeasPVs)
   if loop.meas.PVs(i)==1
      %is it bunch length?
      if ~isempty(strfind(loop.meas.allmeasPVs{i,1},'BLEN'))
         % use the running average of bunch length signal
         curr_meas(i) = loop.measData.avg(i);
         avg_meas(i) = curr_meas(i);
         %BLEN: create dI/I ratio  using the setpoint value, (meas/sp)-1
         if (i==4)
             sp_abs = abs(loop.states.SPs(3));
            new_meas(3) = sign(loop.states.SPs(3)) *((curr_meas(i) - sp_abs) / sp_abs);
%           new_meas(3) = (curr_meas(i) - loop.states.SPs(3)) / loop.states.SPs(3);
         elseif (i==6)
            sp_abs = abs(loop.states.SPs(5));
            new_meas(5) = sign(loop.states.SPs(5)) *((curr_meas(i) - sp_abs) / sp_abs);
         end
      else
         % BPM: divide out dispersion value - ref=0, becomes meas/disp
         % curr_meas(m) = (curr_meas(m)-loop.refData.data(m))/loop.meas.dispersion(i);
         % Let us again keep reference orbit and setpoint for BPMs --jw
         % as in the transverse feedback 
         % dE/E = (curr_meas(m)/loop.meas.dispersion(i)*ref + ref) - 1;
         if (i == 1) || (i == 2)
%             new_meas(1) = (curr_meas(i)/loop.meas.dispersion(i))*loop.states.SPs(1);
             new_meas(1) = (curr_meas(i)/loop.meas.dispersion(i) + ...
                             1 )*(135.0/loop.states.SPs(1)) - 1;
         elseif i == 3
%             new_meas(2) = (curr_meas(i)/loop.meas.dispersion(i))*loop.states.SPs(2);
             new_meas(2) = (curr_meas(i)/loop.meas.dispersion(i) + ...
                             1 )*(250.0/loop.states.SPs(2)) - 1;
         elseif i == 5
%             new_meas(4) = (curr_meas(i)/loop.meas.dispersion(i))*loop.states.SPs(4);
            new_meas(4) = (curr_meas(i)/loop.meas.dispersion(i) + ...
                             1 )*(4300.0/loop.states.SPs(4)) - 1;
         elseif i > 7
             % if we are working at BSY or LTU, handle the bpms there
             % the function divides out dispersion already
             temp = calcLTU_X(loop, i, curr_meas(i:end,1));
%             new_meas(6) = (temp)*loop.states.SPs(6);
             new_meas(6) = (temp+1)*...
                           (loop.meas.DL2_energy/loop.states.SPs(6)) - 1;
             break;
         end
      end
      %Notice that in the above, 
      %the reference energy is hardcoded as (135, 250, 4300) Mev
      %for (DL1, BC1, BC2). --jw
    end
end


%if all(flags) && all(connected)
   %check timestamp info to be sure all from same pulse?
%else 
%   fbDispMsg('Not complete measurement-dev(s) missing', loop.feedbackAcro, 1);
%end
       
newMeas = new_meas;
avgMeas = avg_meas;
newLoop = loop;
end

% --------- function ----------------------------------------------
% --- calculate an X value at BSY or LTU 
function meas  = calcLTU_X(loop, i, ltu_meas)
% this function will calculate an X measurement value for the group of BPMs 
% at the BSY or LTU end of the the linac, if it is used in the feedback
% ltu_meas - the set of measurement values 
if length(ltu_meas)==2 % we are in DL2 with BPMDL1 and BPMDL3
   % calculate x from DL1 & DL3
   meas = ( (ltu_meas(1)/loop.meas.dispersion(i)) + ...
            (ltu_meas(2)/loop.meas.dispersion(i+1)) )/2;
elseif length(ltu_meas)==4
   % calculate x from fit of three LTU bpms
    meas = ( (ltu_meas(3)/loop.meas.dispersion(3)) );  
%   meas = ( (ltu_meas(3)/loop.meas.dispersion(3)) - ...
%            (ltu_meas(2)/loop.meas.dispersion(3))*loop.meas.DL2K_eCoeffs(2) - ...
%            (ltu_meas(1)/loop.meas.dispersion(3))*loop.meas.DL2K_eCoeffs(1) );
elseif length(ltu_meas)==7
   % calculate x from fit of three BSY bpms
   meas = ( (ltu_meas(3)/loop.meas.dispersion(3)) - ...
            (ltu_meas(2)/loop.meas.dispersion(3))*loop.meas.BSY_eCoeffs(2) - ...
            (ltu_meas(1)/loop.meas.dispersion(3))*loop.meas.BSY_eCoeffs(1) );  
end
end

% --------- function ----------------------------------------------
function statevals = calcStateValues(measvals, loop)
% calc the State values from  the measurement values 
% This function is specific to longitudinal feedback and assumes the
% states are in a specific order
%
% statevals    the corrected values of the states
% measvals  latest values from measurement devices

%fbckNum=str2num(loop.feedbackNum);
vals = zeros(length(measvals),1);
for i=1:length(measvals)
   vals(i) = (1 + measvals(i))*loop.states.SPs(i);
end
statevals = vals;
end

% --------- function ----------------------------------------------
% --- the calculation for new actuator  values
function [newact, newloop, ok] = calcNewActValues(meas, loop)
% calculate new values for actuators. 
%inputs
% meas        the corrected measurement values
% loop        the global loop structure
%outputs
% newact      newly calculated actuator settings, phases at L2 & L3
% newloop     updated loop structure
% ok          indicates the matrix calc was successful

ok=1;
err_n = meas;

%this updates the loop structure - pass it back out
loop.errData = addToData(loop.errData, err_n);
% 
% do proportional gain
err_p = (loop.matrix.mult*err_n); 
% now do integral 
err_sum = (sum(loop.errData.data,2));%/10;
err_i = (loop.matrix.mult*err_sum); 

newact = loop.actData.current - (loop.states.pGain*err_p) - (loop.states.iGain*err_i);

% calc new act deltas using PI gains, L2 and L3 in energy & chirp
%delta_abs = -(loop.states.pGain*err_p) - (loop.states.iGain*err_i);
%delta = delta_abs;
%delta(1) = delta_abs(1)*loop.states.SPs(1)/100; %this /100 is probably not necessary
%delta(2) = delta_abs(2)*loop.states.SPs(2)/100;

% convert L2 L3 amp & phase to energy and chirp
%current = loop.actData.current;
% L2 amp & phase to energy & chirp
%[current(4), current(5)] = fbCalcEnergyChirp6x6(loop.actData.current(4), loop.actData.current(5));
% L3 amp to energy
%[current(6), dummy] = fbCalcEnergyChirp6x6(loop.actData.current(6), 0);
% here's the new energy and chirp values with deltas added
%newact_ec = current + delta;

% finally, convert the new L2 L3 enrgy & chirp to amps & phases
%newact = newact_ec;
%[newact(4), newact(5)] = fbCalcPhaseAmp6x6(newact_ec(4), newact_ec(5));
%[newact(6), dummy] = fbCalcPhaseAmp6x6(newact_ec(6), 0);

if any(isnan(newact))
   ok=0;
end
newloop = loop;
end


% --------- function ----------------------------------------------
% --- check the actuator values against limits on values
function [fullact, putact, newloop, rlim] = checkActValues(temp_act, actPVs, actLimits, loop)
% check setpoint values against limits and replace with ? if
% the measurement is outside the limits
% newact    the corrected act settings vector, with phases for L2, L3
% newloop   the updated  loop structure, with current values rotated in
% rlim      return value =0 if act vals ok, =1 or -1 of act vals too hi, too
%
% temp_act  latest values from actuator setting calcs, 
%           with phases for L2 and L3
% actPVs    the list of flags indicating which act PVs are in use
% actLimits array of limits on act values

%initialize a vector to store the act values we are going to lcaPut

put_act = zeros(length(loop.act.chosenactPVs), 1);

rlim = 0;
m=0;
%check that actuator vals are within operating limits, here in MeV
for i=1:length(actPVs)
   if (actPVs(i)==1)
      m=m+1;
      put_act(m) = temp_act(i);
      if (temp_act(i) < actLimits.low(i) )
         rlim = -1;
      else
         if ( temp_act(i) > actLimits.high(i) )
            rlim = 1;
         end
      end
      if (rlim~=0)
         disp('WARNING: actuator value is outside limits');
         fullact=temp_act;
         putact = put_act;
         newloop = loop;
         return;
      end
   end
end

%rotate out the old calculated actuator values
% we save 3 previous vals, but only use the one past at this time.
loop.actData.nminus2 = loop.actData.nminus1;
loop.actData.nminus1 = loop.actData.current;
loop.actData.current = temp_act;

fullact = temp_act;
putact = put_act;
newloop = loop;
end

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
end

   

