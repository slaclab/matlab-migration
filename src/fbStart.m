function fbStart(varargin)
%      fbStart is the main program for the feedback runtime application
%
% varargin: the filename of the feedback configuration file
%  this file indicates which feedback is to be run


% initialize the feedback loop structures
filename = char(varargin);
try
   fbInitFbckStructures(filename);

   % start the main feedback gui
   startLoop();
catch
   error(lasterror);
   rmappdata(0,'Loop_structure');
   rmappdata(0,'Config_structure');
   exit;
end


% --------- function ----------------------------------------------
function startLoop
% FBCK M-file 
%      startLoop
%
%      start the feedback loop
%
%     

config = getappdata(0,'Config_structure');

% init the loop structure with latest config
initLoopFcn = str2func(config.initloopfcnName);
initLoopFcn();
loop = getappdata(0,'Loop_structure');

if ~strcmp(loop.feedbackAcro, 'LPS')
   %check matrix to be sure there are at least as many meas devices as
   %actuators
   if ~(length(loop.act.chosenactPVs)>3)
      if ( (length(loop.act.chosenactPVs) > length(loop.meas.chosenmeasPVs) )  || ...
         (length(loop.act.chosenactPVs) ~= length(loop.states.chosenstatePVs) )  )
         fbLogMsg(['Actuator count, measurement count, and / or state count do not match']);
         return;
      end
   end
   if isempty(loop.act.chosenactPVs)
    fbLogMsg(['No actuators defined, cannot run this feedback']);
    return;
   end
   if isempty(loop.meas.chosenmeasPVs)
    fbLogMsg(['No measurement devices defined, cannot run this feedback']);
    return;
   end
end


%test to see if this feedback is allowed to run
stateDisvPV = {loop.states.statePV};
stateDisvPV = fbAddToPVNames(stateDisvPV, '.DISV');
stateDisabled = lcaGet(stateDisvPV);
if (stateDisabled == 0)
   %this feedback is disabled - don't run it
   fbLogMsg(['This feedback is disabled - , ' config.feedbackName ' quitting']);
   return;
end


%test to see if this feedback is already running
stateON = lcaGet(loop.states.statePV);
if strcmp('ON',stateON)
   lcaPut(loop.states.statePV, '0');
   pause(1); %wait a second while other feedback stops
end

% make sure the loop state=1, on
loop.state = 1;

%store the changed loop structure and data
setappdata(0,'Loop_structure',loop);

% for non-longitudinal feedbacks, set up the actuators
if ~strcmp(loop.feedbackAcro, 'LNG')
  try
   % read actuator values for starting point
   curr_act = lcaGet(loop.act.chosenactPVs);
   loop.actData.current = curr_act;
   % default - load the actvals from the reference orbit as 'original'
   loop.actData.original = config.refData.actvals;
   % write the original values to the restore storage place
   %rstrNames = fbAddToPVNames(loop.act.allstorePVs, 'RSTR');
   %lcaPut(rstrNames, config.refData.actvals);
  catch
   dbstack;
   fbLogMsg(['Could not read actuator PVs, ' config.feedbackName ' quitting']);
   % 7/5/17 Sonya - Added this MDL-specific error reporting
   % to avoid affecting other MDL feedbacks, but perhaps this should
   % be propagated to all?
   if strcmp(loop.feedbackAcro, 'MDL')
       message = 'Could not read actuator PVs';
       fbDispMsg(message, loop.feedbackAcro, 2);
   end
   rethrow(lasterror);
  end
end

% reset all the storage compress records
% actuators
try
   if ~isempty(loop.act.allstorePVs)
    resetNames = fbAddToPVNames(loop.act.allstorePVs, 'DISP.RES');
    lcaPut(resetNames,'1');
   end
   % measurements
   if ~isempty(loop.meas.allstorePVs)
    resetNames = fbAddToPVNames(loop.meas.allstorePVs, 'DISP.RES');
    lcaPut(resetNames,'1');
   end
   % states
   if ~isempty(loop.states.allstatePVs)
    resetNames = fbAddToPVNames(loop.states.allstatePVs, 'DISP.RES');
    lcaPut(resetNames,'1');
   end
   if ~isempty(loop.states.allspPVs)
    resetNames = fbAddToPVNames(loop.states.allspPVs, 'DISP.RES');
    lcaPut(resetNames,'1');
   end
catch
   dbstack;
   fbLogMsg(['Could not reset storage PVs, ' config.feedbackName ' quitting']);
   % 7/5/17 Sonya - Added this MDL-specific error reporting
   % to avoid affecting other MDL feedbacks, but perhaps this should
   % be propagated to all?
   if strcmp(loop.feedbackAcro, 'MDL')
       message = 'Could not reset storage PVs';
       fbDispMsg(message, loop.feedbackAcro, 2);
   end
   rethrow(lasterror);
end

%create the feedback status pv name and set the hostname
loop.statusPV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:STATUS.DESC'];
[a,host]=unix('hostname');
host = regexprep(host, '.slac.stanford.edu', '');

% set the feedback overall state to ON, 
% individual state ON, and programatically enabled
try
   lcaPut(loop.states.statePV, '1');
   lcaPut(loop.indStatePV, '1'); 
   lcaPut(loop.enablePV, '1');
   lcaPut(loop.statusPV, host);
catch
   dbstack;
   h = errordlg('Could not set state PVs to ON');
   waitfor(h);
   fbLogMsg(['Could not set state PVs, ' config.feedbackName ' quitting']);
   % 7/5/17 Sonya - Added this MDL-specific error reporting
   % to avoid affecting other MDL feedbacks, but perhaps this should
   % be propagated to all?
   if strcmp(loop.feedbackAcro, 'MDL')
       message = 'Could not set state PVs';
       fbDispMsg(message, loop.feedbackAcro, 2);
   end
   rethrow(lasterror);
end
% set the status PV list
loop.statusPVs = {loop.states.statePV; loop.indStatePV };

% if using F2 EDEF, set name and TCAV exclusion bit
%if (any(cell2mat(strfind(loop.meas.allmeasPVs,'F2'))))
%   try
%      lcaPut('EDEF:SYS0:20:NAME', 'beam rate feedback');
%      eDefParams(20, 1, -1, {''}, {''},  {'TCAV3'}, {''});    
%   catch
%      dbstack;
%      fbLogMsg(['Could not set F2 EDEF, ' config.feedbackName]);
%      rethrow(lasterror);
%   end
%end

% set the measurement PV monitors
try
   if ~isempty(loop.meas.chosenmeasPVs)
    lcaSetMonitor([loop.meas.chosenmeasPVs; loop.check.chkPVs]); %NEW
    % set the measurement FBCK pvs
    fbckPVs = fbGetFbckPVs(loop.meas.chosenmeasPVs);
    if ~isempty(fbckPVs)
        lcaPut(fbckPVs, '1');
    end
   end
   lcaSetMonitor(loop.statusPVs);
catch
   dbstack;
   fbLogMsg(['Could not monitor measurement PVs or statusPVs, ' config.feedbackName ' quitting']);
   % 7/5/17 Sonya - Added this MDL-specific error reporting
   % to avoid affecting other MDL feedbacks, but perhaps this should
   % be propagated to all?
   if strcmp(loop.feedbackAcro, 'MDL')
       message = 'Could not monitor meas or status PVs';
       fbDispMsg(message, loop.feedbackAcro, 2);
   end
   rethrow(lasterror);
end

%initialize the timer with the latest values
loop.fbckTimer.period = loop.timer.period;
loop.fbckTimer.TasksToExecute = loop.timer.max;

% set the feedback control PVs
l = length(loop.act.PVs);
%if the feedback control is requested, set the PV ON,
if ~isempty(loop.ctrl.allctrlPVs)
   for n=1:l
      if (loop.act.PVs(n)==1)
         lcaPut(loop.ctrl.allctrlPVs(n), '1');
      end
   end
end

%store the changed loop structure and data
setappdata(0,'Loop_structure',loop);
   
%start the timer
start(loop.fbckTimer);
