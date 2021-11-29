function fbInitBChrgCoherent1Loop()
% this routine is called when the feedback program is started, and
% whenever the transverse feedback loop is started. It reads the latest 
%config values and places them in the loop structure to be used during 
% the feedback operation.  
%
% The functions in this module are specific to the Bunch Charge feedback
% where a softIOC PV LASR:IN20:1:PCTRL is the actuator, and 
% BPM221 is the measurement device.
% this feedback averages samples of the BPM221 TMIT and uses the average meas.
% It uses an edef to take the samples and averages them


% get the config and loop structures
config = getappdata(0,'Config_structure');
loop = getappdata(0,'Loop_structure');

% init feedback loop parameters
loop.state = 0; % is loop on (1) or off (0); init to off
loop.lCnt = 0; % loop count; init to 0
loop.feedbackAcro = config.feedbackAcro;

% set the count and enable PVs
loop.cntPV = ['FBCK:BCI' config.feedbackNum ':1:COUNT'];
loop.enablePV = ['FBCK:BCI' config.feedbackNum ':1:ENABLE'];
loop.indStatePV = ['FBCK:BCI' config.feedbackNum ':1:STATE'];
lcaPut(loop.cntPV,loop.lCnt);
loop.enable = lcaGet(loop.enablePV);
loop.prev_enable = loop.enable; %for comparing previous to current enable status
%loop.logmsg = 1; % log any error messages

% get the timer structure
loop.timer = config.timer; % 

%initialize the fbck timer
loop.fbckTimer = config.fbckTimer;
loop.fbckTimer.ExecutionMode = 'fixedSpacing'; % dont start another till first finishes
loop.fbckTimer.period = loop.timer.period; 
loop.fbckTimer.TasksToExecute =loop.timer.max; 
set(loop.fbckTimer, 'TimerFcn', config.timer.fcnName);
set(loop.fbckTimer, 'StopFcn', 'fbStopTimer');

% init the ctrl PVs from config
loop.ctrl = config.ctrl;

% get the states
loop.states = config.states;
loop.states.numstatePVs = length(loop.states.chosenstatePVs);

%measurement PVs
loop.meas = config.meas;
loop.meas.nummeasPVs = length(loop.meas.chosenmeasPVs);

%actuator PVs
loop.act = config.act;
loop.act.numactPVs = length(loop.act.chosenactPVs);

%check PVs - for BChrg loop it is simply the measurement PV
loop.check.chkPVs = loop.meas.chosenmeasPVs;
loop.check.low = 1e9;  % lowest TMIT value allowed
loop.check.var = 0.3;  % variance around GUN BPM TMIT value (0.3 = 30%)
loop.check.infoPVs = {'SIOC:SYS0:FB00:TMITLOW'; 'PATT:SYS0:1:PULSEIDBR'};
loop.check.pulseidPV = {'FBCK:BCI0:1:PULSEID'};

% waveplate PVs to check status of the laser and camera waveplates
% MOVN - indicates if motor is moving (=1)
% DMOV - indicates if last move was successful (=1)
loop.check.wpPVs = {'WPLT:LR20:80:WP1_ANGLE.MOVN'; 'WPLT:LR20:80:WP1_ANGLE.DMOV';...
                    'WPLT:IN20:181:VCC_ANGLE.MOVN'; 'WPLT:IN20:181:VCC_ANGLE.DMOV'};
                 
%create storage for the original, current, and last actuator values calculated, 
%these are column vectors
actData.original = zeros(loop.act.numactPVs, 1);
actData.current = zeros(loop.act.numactPVs, 1);
actData.nminus1 = zeros(loop.act.numactPVs, 1);
loop.actData = actData;

% create the prevMeas used here to check BPM
% values to be sure it doesnt get stuck
loop.prevMeas = 0;

% set up the eDef for the bunch charge measurements
loop.eDefNumber = 19;
%loop.eDefNumber = eDefReserve('bunch_charge_feedback');
loop.samples = 10;
eDefParams(loop.eDefNumber, 1, loop.samples, {''}, {''},  {''}, {''}); 

% add the edef number to the measurement name strings
%loop.meas.chosenmeasPVs = fbAddToPVNames(loop.meas.chosenmeasPVs, ['HST', num2str(loop.eDefNumber)]);
loop.meas.chosenmeasPVs = fbAddToPVNames(loop.meas.chosenmeasPVs,'HSTF1');
% reset status string
fbDispMsg(' ', loop.feedbackAcro, 0);

%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);
