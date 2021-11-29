function fbLongStart(varargin)
%      
% fbLongStart is the main program for the longitudinal feedback application
%
% varargin - the filename of the feedback configuration file
%  this file indicates which feedback is to be run

%get the configuration filename
filename = char(varargin);
lcaSetSeverityWarnLevel(14); %so that lcaGets never return NaN

try
   % start the main feedback gui
   startLoop(filename);
catch
   error(lasterror);
   rmappdata(0,'Loop_structure');
   rmappdata(0,'Config_structure');
   exit;
end
end


% --------- function ----------------------------------------------
function startLoop(filename)
% FBCK M-file 
%      startLoop
%
%      start the feedback loop
%
%     

%FIRST - create and initialize the memory structures needed to run the loop

%create a loop structure and save it
loop = [];
setappdata(0, 'Loop_structure', loop);

try
   % get the initial configuration from file
   config = fbReadConfigFile(filename);
catch
   dbstack;
   h = errordlg('Could not read config file');
   waitfor(h);
   rethrow(lasterror);
end
   

% initialize the loop structure with config
initLoopFcn = str2func(config.initloopfcnName);
initLoopFcn();
loop = getappdata(0,'Loop_structure');

%check desired states and machine conditions
loop.states.config = fbCheckMachineConditions(loop);
setappdata(0, 'Loop_structure', loop);

%reconfigure according to desired states and conditions
fbLongReconfigure();
loop = getappdata(0,'Loop_structure');


% Now prepare for starting the loop. Set various state & storage PVs

%set the loop counter to 0;
loop.state = 0; % is loop on (1) or off (0); init to off
loop.lCnt = 0; % loop count; init to 0
lcaPut(loop.cntPV,loop.lCnt);
loop.enable = lcaGet(loop.enablePV);

%test to see if this feedback is already running, stop it if it is
stateON = lcaGet(loop.states.statePV);
if strcmp('ON',stateON)
   lcaPut(loop.states.statePV, '0');
   pause(1); %wait a second while other feedback stops
end

% make sure the loop state=1, on
loop.state = 1;

%store the changed loop structure and data
setappdata(0,'Loop_structure',loop);
   
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
catch
   dbstack;
   fbLogMsg(['Could not reset storage PVs, ' config.feedbackName ' quitting']);
   rethrow(lasterror);
end

% set the feedback overall state to ON, 
% individual state ON, and programatically enabled
try
   %lcaPut(loop.states.statePV, '1');
   lcaPut(loop.indStatePV, '1'); 
   lcaPut(loop.enablePV, '1');
   lcaPut(loop.statusPV, loop.host);
catch
   dbstack;
   fbLogMsg(['Could not set state PVs, ' config.feedbackName ' quitting']);
   rethrow(lasterror);
end

% turn on feedback control PVs, 
%l = length(loop.act.PVs);
%if ~isempty(loop.ctrl.allctrlPVs)
%   for n=1:l
%      if (loop.act.PVs(n)==1)
%         lcaPut(loop.ctrl.allctrlPVs(n), '1');
%      end
%   end
%end

% set the status PV list
loop.statusPVs = {loop.states.statePV; loop.indStatePV };

% a little error checking...
if isempty(loop.act.chosenactPVs)
  fbLogMsg('No actuators defined, cannot run this feedback');
  return;
end
if isempty(loop.meas.chosenmeasPVs)
  fbLogMsg('No measurement devices defined, cannot run this feedback');
  return;
end

% set the measurement PV monitors and status PV monitors
try
  if ~isempty(loop.meas.chosenmeasPVs)
    lcaSetMonitor([loop.meas.chosenmeasPVs; loop.check.chkPVs]); %NEW
    %set FBCK pvs here too
    %fbckPVs = fbGetFbckPVs(loop.meas.chosenmeasPVs);
    %lcaPut(fbckPVs, '1');
  end
  lcaSetMonitor(loop.statusPVs);
catch
  dbstack;
  fbLogMsg(['Could not monitor measurement PVs or statusPVs, ' config.feedbackName ' quitting']);
  rethrow(lasterror);
end

% start the execution loop
loop.running = 1;

%store the changed loop structure and data
setappdata(0,'Loop_structure',loop);

%start the timer
start(loop.fbckTimer);
end


