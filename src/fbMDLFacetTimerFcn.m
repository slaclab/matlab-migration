function fbMDLFacetTimerFcn(obj, event)
% --------- function ----------------------------------------------
% --- the timer function for the feedback monitors
%
   
% Get the loop data structures
loop = getappdata(0, 'Loop_structure');

% Check current measurement PV monitors
try
flags = lcaNewMonitorValue(loop.meas.chosenmeasPVs);
catch
   dbstack;
   flags=0;
end
if all(flags)
    calcFeedback;
else
    % Check the status PVs, if any Off then stop the feedback
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
      % Increment the loop counter
      loop.lCnt = loop.lCnt + 1;
      lcaPut(loop.cntPV, loop.lCnt);
      if loop.lCnt >= 99999
         loop.lCnt = 1;
      end
      % Update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
    catch
       dbstack;
       % If monitor fails, then the softIOC is dead, stop the feedback.
       message = 'Feedback soft IOC is not responding';
       fbLogMsg(sprintf('MDLFacet %s',message));
       fbDispMsg(message, loop.feedbackAcro, 2);
       disp(message);
       stop(loop.fbckTimer);
    end
end


function calcFeedback
%-----------START of FEEDBACK CODE --------------------------------
%
% --------- function ----------------------------------------------
%
% This function executes one feedback calculation
%

% Get the loop data structures
loop = getappdata(0, 'Loop_structure');

% Check Feedback status PVs
try
   prevEnable = loop.enable;
   loop.enable = lcaGet(loop.enablePV);
   % Check the state PVs, if Off then stop the feedback
   indState = lcaGet(loop.indStatePV);
   state = lcaGet(loop.states.statePV);
   if (strcmp(indState, 'OFF')>0) || (strcmp(state, 'OFF')>0) 
      stop(loop.fbckTimer);
      return;
   end
   % Increment the loop counter
   loop.lCnt = loop.lCnt + 1;
   lcaPut(loop.cntPV, loop.lCnt);
   if loop.lCnt >= 99999
      loop.lCnt = 1;
   end
   % Get the current setpoints 
   loop.states.SPs = lcaGet(loop.states.chosenspPVs);
catch
   message = 'Feedback soft IOC is not responding';
   fbLogMsg(sprintf('MDLFacet %s',message));
   fbDispMsg(message, loop.feedbackAcro, 2);
   disp(message);
   stop(loop.fbckTimer);
   % Update the loop structure and store it
   setappdata(0,'Loop_structure',loop);
   return;
end


% Get the measurements. Take mean of measurement data.
% If we fail to get measurement data, try to determine cause
%   (PVs not updating, PVs offline, NaN), print message, and return.
% Call checkMeasurements to check measurements against limits. If it returns 
%   bad status or measurements outside limits, print message, and return

loop.meas.data=[];
loop.meas.conn=[];
failed=0; nfailed=0;

% Set lca timeout. This will usually be set to a longer value for SLCCAS PVs, 
% which can update slowly. This loop operates very slowly, so this is not a problem.
lcaSetTimeout(loop.meas.lcaTimeout);

try
    for i=1:loop.meas.nummeasAvg
        try
            lcaNewMonitorWait(loop.meas.chosenmeasPVs);
        catch
            err=lasterror;
            if strfind(err.identifier,'timedOut')
                % If not all measurement PVs are updating,
                % identify those that failed and report PV names to user
                failed=find((lcaNewMonitorValue(loop.meas.chosenmeasPVs)==0));
                nfailed=length(failed);
                disp(sprintf('Not all measurements updated before the %d second timeout.\nThe following PVs failed:',lcaGetRetryCount*lcaGetTimeout));
                for j=1:nfailed
                    disp(sprintf('%s',char(loop.meas.chosenmeasPVs(failed(j)))));
                end
                rethrow(lasterror);
            elseif strfind(err.identifier,'invalidArg')
                % This identifier may indicate some measurement PVs offline
                disp(sprintf('Failed to get measurement data. Some of these PVs may be offline:'));
                for j=1:length(loop.meas.chosenmeasPVs)
                    disp(sprintf('%s\n',char(loop.meas.chosenmeasPVs(j))));
                end
                rethrow(lasterror);
            else
                dbstack;
                rethrow(lasterror);
            end  
        end
        curr_meas=lcaGet(loop.meas.chosenmeasPVs);
        if any(isnan(curr_meas))
            disp('Measurement(s) returned NaN. Data may be invalid.');
            exception = MException('fbMDLFacetTimerFcn:MeasNaN', 'Measurement(s) returned NaN');
            throw(exception);
        end      
%         % If SLCCAS PV, check .STAT for error condition.
%         for j=1:length(loop.meas.chosenmeasPVs)
%     		st = lcaGet([char(loop.meas.chosenmeasPVs(j)) '.STAT']);
%     		if st > 1
%         		disp('Measurement(s) bad status.');
%         		exception = MException('fbMDLFacetTimerFcn:MeasBadStat', 'Measurement(s) bad status');
%         		throw(exception);
%     		end
%         end
        % Store the data
        loop.meas.data = [loop.meas.data, curr_meas];
    end
    curr_meas = mean(loop.meas.data,2); % Take mean of measurements
catch
    message = 'Error getting measurement data';
    fbLogMsg(sprintf('MDLFacet %s',message));
    fbDispMsg(message, loop.feedbackAcro, 2);
    % Update the loop structure and store it
    setappdata(0,'Loop_structure',loop);
    return;
end

% Check the measurement values against limits
[curr_meas,measok,measlim] = checkMeasurements(curr_meas, loop);


% If loop is enabled and data is good, continue
if (strcmp(loop.enable, 'Enable')>0 )
    if measok == 0 && measlim == 0 
        try
            % Get current actuator values
            loop.actData.current = lcaGet(loop.act.chosenactPVs);
        catch
            fbDispMsg('NO change to acts, cannot get act vals', loop.feedbackAcro, 2);
            disp('NO change to actuators, unable to get current actuator values. PVs may be offline.');
            setappdata(0,'Loop_structure',loop);
            return;
        end
        
        % Calculate state values
        [states,statesok] = calcNewStates(loop, curr_meas);
        
        if (statesok == 0) % If successful

            % Calculate actuator settings
            [new_act, newactsok] = calcNewActValues(loop,states(2));

            if (newactsok == 0 ) % If successful

                % Check new actuator settings against limits
                [new_act, actsok, actslim] = checkActValues(new_act, loop);

                if (actsok == 0) % If successful

                    if (actslim == 0) % If actuator settings within limits

                        % Set actuators
                        try
                            put_aida(loop.act.chosenactPVs, new_act);
                            % Rotate out the old calculated actuator values
                            loop.actData.nminus2 = loop.actData.nminus1;
                            loop.actData.nminus1 = loop.actData.current;
                            loop.actData.current = new_act;
                            fbDispMsg(' ', loop.feedbackAcro, 0);
                        catch
                            message = 'No change to acts, cannot set values';
                            fbLogMsg(sprintf('MDLFacet %s',message));
                            fbDispMsg(message, loop.feedbackAcro, 2);
                            disp(message);
                        end
                    else
                        message = 'No change to acts, vals out of range';
                        fbLogMsg(sprintf('MDLFacet %s',message));
                        fbDispMsg(message, loop.feedbackAcro, 2);
                        disp(message);disp(sprintf('% 5.4g',new_act));
                    end
                end
                % Always store the calculated states, the meas values and the act values
                % If the act values are out of tol this storage will cause an alarm
                storePVs = [loop.states.chosenstatePVs; loop.meas.chosenstorePVs; loop.act.chosenstorePVs];
                storeData = [states; curr_meas; new_act];
                try
                    lcaPut(storePVs, storeData);
                catch
                    message = 'Cannot save feedback data to Feedback';
                    fbLogMsg(sprintf('MDLFacet %s',message));
                    fbDispMsg(message, loop.feedbackAcro, 2);
                    disp(message);
                end
            end
        end
    end
end

% Update the loop structure and store it
setappdata(0,'Loop_structure',loop);


% --------- function ----------------------------------------------
% --- Check that measurement data is good
function [new_meas, stat, limok] = checkMeasurements(curr_meas, loop)
%
%   Check measurement values against limits. If any are outside limits, set
%   limok to 1 and return. If any other problems are encountered, set stat
%   to 1 and return.
%
%
%   Arguments:
%
%           curr_meas   Latest values from measurements
%           loop        Global loop data structure
%
%   Return:
%
%           new_meas    The (possibly) corrected measurement matrix
%           stat        Zero if no problems encountered
%           limok       Zero of all measurements within limits
%

% Initialize return variables. Initialize stat, limok to 0.
new_meas = curr_meas;
stat = 0;
limok = 0;

% Check measurement data. Check enabled measurements only.
try
    m = 0;
    lm = length(loop.meas.PVs);
    for i=1:lm
        if (loop.meas.PVs(i)==1)
            m=m+1;
            if (curr_meas(i) < loop.meas.limits.low(i) || curr_meas(i) > loop.meas.limits.high(i))
                message='Measurement(s) out of tol.';
                fbDispMsg(message,loop.feedbackAcro,2);
                fbLogMsg(sprintf('MDLFacet %s',message));
                disp(message);
                limok=1;
                return;
            end
        end
    end
catch
    err=lasterror;
    message='NO change to acts. Error checking meas.';
    message_verbose=sprintf('NO change to acts. Error checking meas. %s',err.identifier);
    fbDispMsg(message,loop.feedbackAcro,2);
    fbLogMsg(sprintf('MDLFacet %s',message_verbose));
    disp(message_verbose);
    stat=1;
end

% --------- function ----------------------------------------------
% --- Calculate new states (signal and command)
function [states, stat] = calcNewStates(loop, meas)
%
%   Arguments:
%
%           loop        Global loop data structure
%           meas        Current measurements
%
%   Return:
%
%           states      State vector; for us: signal and command 
%           stat        Zero if no problems encountered
%
%--------------------------------------------------------------------------
%       Algorithm ported from MDL_COMP_DRVR. These comments are
%       copied from MDL_COMP_DRVR:
%
%       PMDL=(Sector Number-2)*101.6/2956.4 * CMND    stat=1;
%       CONSTANT=101.6/2956.4
%       CORR_COEF=0.038
%
%       Since the PMDL is a better representation for the current
%       status of the feedback loop, CMND_OLD is computed from 
%       the PMDL in LI20 (the last sector used for PEP).
%
%       VDES = CORR_COEF*(CMND - CMND_OLD) + VDES
%
%       CMND_OLD=-PMDL_LI20/((20-2)*CONSTANT)
%       CMND_NEW =  CMND_OLD - GAIN*(SGNL - SETP)
%
%       CMND=CMND_NEW (if CMND_NEW within tolerances)
%       SGNL_P_T   = CMND_OLD + READING_P_T   - SCRA_LIST.OFST_PT_OFST
%
%            READING_P_T  =
%     >         SCRA_LIST.MCCBAROM_COEF * (ADAT_LIST.BARO_MTR - BARO_NORMAL)
%     >       + SCRA_LIST.MDL_PABS_COEF * (ADAT_LIST.MDL_PABS - BARO_NORMAL)
%     >       + SCRA_LIST.MDLTLI07_COEF * (ADAT_LIST.M_D_LINE_LI07 - TEMPER_NORMAL)
%     >       + SCRA_LIST.AIRTLI07_COEF * (ADAT_LIST.ISOPLAN0_LI07 - TEMPER_NORMAL)
%     >       + SCRA_LIST.MDLTLI25_COEF * (ADAT_LIST.M_D_LINE_LI25 - TEMPER_NORMAL)
%
%        REAL*4      BARO_NORMAL             ! Normal barometric pressure
%        PARAMETER  (BARO_NORMAL   = 1013.)
%
%        REAL*4      TEMPER_NORMAL           ! Normal temperature
%        PARAMETER  (TEMPER_NORMAL =   95.)
%--------------------------------------------------------------------------
%
%   Use last reference PMDL setting to calculate last command. Then use last
%   command, latest measurements after subtracting 'normal' values, and the
%   pressure-temperature offset to calculate the signal and new command.
%   (pt_offsetoffset is not really needed for this loop since we only
%   have one setpoint and one means of calculating the signal; consider
%   getting rid of this later.) Check that new command is within limits.
%
%   Not sure how constant and correction coefficient were calculated. 
%   They are hard-coded in fbInitMDLFacetLoop.m.
%
%   We are not perturbing the SBST PMDL settings; we just write the new
%   value, so there is no need to calculate actuator deltas.
%

% Initialize return variables. Set states to latest value. Initialize
% stat to 0.
stat = 0;
try
    sgnl=lcaGet(loop.states.chosenstatePVs(1));
    cmnd=lcaGet(loop.states.chosenstatePVs(2));    
    states=[sgnl;cmnd];
catch
    disp('Failed to get current state PV values.')
end
   
% Perform calculation
try  
    % Reference is PMDL of last sector in list
    ref_pmdl=loop.act.chosenactPVs(loop.act.numactPVs);
    cmnd_old=-lcaGet(ref_pmdl)/((loop.misc.sec_last-loop.misc.sec_zero)*loop.misc.constant);
    meas_diff=meas-loop.meas.chosennormalVals';
    reading=meas_diff'*loop.matrix.chosenf;
    sgnl=cmnd_old + reading - loop.misc.pt_offset;
    p_setp = loop.states.SPs';
    cmnd_new=cmnd_old-loop.states.pGain*(sgnl-p_setp(1));
    if (cmnd_new < loop.states.limits.high(2) && cmnd_new > loop.states.limits.low(2))
        cmnd=cmnd_new; % if within tolerances        
    else
        message='NO change to acts. Cmnd out of tol.';
        fbDispMsg(message,loop.feedbackAcro,2);
        fbLogMsg(sprintf('MDLFacet %s',message));
        disp(message);
        stat=1;
    end
    states=[sgnl;cmnd];
catch
    err=lasterror;
    if strfind(err.identifier,'timedOut')
        % PV get failed
        message='NO change to acts. LI20 PMDL get failed.';
    elseif strfind(err.identifier,'innerdim')
        message='NO change to acts. Matrix needs update?';
    else
        message='NO change to acts. State calc failed.';
        message_verbose=sprintf('NO change to acts. Failed to calculate states. %s',err.identifier);
        fbLogMsg(sprintf('MDLFacet %s',message_verbose));
        disp(message_verbose);
    end
    fbDispMsg(message,loop.feedbackAcro,2);
    fbLogMsg(sprintf('MDLFacet %s',message));
    disp(message);
    stat=1;
end

% --------- function ----------------------------------------------
% --- Calculate new actuator settings and check against limits
function [new_act, stat] = calcNewActValues(loop, cmnd)
%
%   Arguments:
%
%           loop        Global loop data structure
%           cmnd        Calculated command (second element in 'states')
%
%   Return:
%
%           new_act     The modified actuator settings
%           stat        Zero if no problems encountered
%

% Initialize return variables. Set acts to latest value. Initialize
% stat to 0.
stat=0;
new_act=loop.actData.current;

try
    % Calculate new actuator settings
    n=length(loop.act.chosenactPVs);
    new_act=zeros(n,1);
    for k=1:n
        new_act(k) = -(loop.act.sectors(k) - loop.misc.sec_zero)*loop.misc.constant*cmnd;
    end
catch
    err=lasterror;
    message='NO change to acts. Acts calc error.';
    message_verbose=sprintf('NO change to acts. Error while calculating act values. %s',err.identifier);
    fbDispMsg(message,loop.feedbackAcro,2);
    fbLogMsg(sprintf('MDLFacet %s',message_verbose));
    disp(message_verbose);
    stat=1;
end
    
% --------- function ----------------------------------------------
% --- Check that new actuator settings are within operating limits
function [new_act, stat, limok] = checkActValues(curr_act, loop)
%
%   Check setpoint values against limits. If any setpoint value is 
%   outside limits, return limok of 1; actuators will not be changed. If
%   any errors along the way, return stat of 1; actuators will not be
%   changed.
%   
%   Arguments:
%
%           curr_act    Calculated actuator settings
%           loop        Global loop data structure
%
%   Return:
%
%           new_act     Same values as curr_act
%           stat        Zero if no problems encountered
%           limok       Zero of all actuators within limits
%
%   loop.act.PVs is list of flags indicating which act PVs are in use
%   loop.act.limits is array of limits on act values
%

% Initialize return variables. Set acts to latest value. Initialize
% stat to 0.
stat=0;
limok=0;
new_act=curr_act;

try
    % Check new actuator settings against limits. Check enabled acts only.
    m=0;
    la = length(loop.act.PVs);
    for i=1:la
        if (loop.act.PVs(i)==1)
            m=m+1;
            if (new_act(m) < loop.act.limits.low(i) || new_act(m) > loop.act.limits.high(i) )
                limok = 1;
                return
            end
        end
    end
catch
    err=lasterror;
    message='NO change to acts. Error checking acts.';
    message_verbose=sprintf('NO change to acts. Error checking act limits. %s',err.identifier);
    fbDispMsg(message,loop.feedbackAcro,2);
    fbLogMsg(sprintf('MDLFacet %s',message_verbose));
    disp(message_verbose);
    stat=1;
end
