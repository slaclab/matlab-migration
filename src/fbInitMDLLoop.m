function fbInitMDLLoop()

% This routine is called when the Main Drive Line feedback loop is started.
% The MDL loop is used to compensate for changes in the electrical length
% of the Main Drive Line (Linac timing distribution line) by adjusting
% Linac Sector Subbooster phases (and maybe other RF system offsets?). The
% required compensation is calculated from temperature and pressure
% measurements. This loop is more of a feedforward than a feedback, in that
% on each iteration it re-calculates the 'last' value from actuator(s), and
% uses that to determine the next adjustment. The two states are signal and
% command. Signal has a setpoint which is used to calculate the next
% adjustment. Command does not but is used to calculate the signal. Keeping
% it as a state for now in order to use the feedback infrastucture: PVs,
% history, etc.
%
% Tasks: 
%
% Read the latest config values and place them in the loop structure 
%   to be used during the feedback operation.  
% Initialize some parameters and store them in the loop structure. 
% Initialize the feedback timer. 
% Call luGetCamacState to get the status of the Linac Upgrade CAMAC. Store the
%   results for use later when writing to actuators. This is only done at 
%   feedback init, so if CAMAC state changes hands, feedback must be restarted.
% Define some MDL-loop-specific parameters. 
% For now, hard-code some MDL-loop-specific constants. Need to change this 
%    before we allow users to use the configuration tool to change the measurements.
%


% Both sgnl and cmdn must be selected (chosen states). They are both
% required for new act value calculations.

% get the config and loop structures
config = getappdata(0,'Config_structure');
loop = getappdata(0,'Loop_structure');

% init feedback loop parameters
loop.feedbackAcro = config.feedbackAcro;
loop.state = 0; % is loop on (1) or off (0); init to off
loop.lCnt = 0; % loop count; init to 0

%debug for now, this PV is not in FB00
loop.ctrl.allctrlPVs = [];

% set the count and enable PVs
loop.cntPV = ['FBCK:MDL' config.feedbackNum ':1:COUNT'];
loop.enablePV = ['FBCK:MDL' config.feedbackNum ':1:ENABLE'];
loop.indStatePV = ['FBCK:MDL' config.feedbackNum ':1:STATE'];
lcaPut(loop.cntPV,loop.lCnt);
loop.enable = lcaGet(loop.enablePV);
loop.logmsg = 1; % log any error messages

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

% No longer use micros to control LCLS LINAC CAMAC,
% so define sectors and m here instead of calling luGetCamacState
sectors = {'LI20'; 'LI21'; 'LI22'; 'LI23'; 'LI24'; 'LI25'; 'LI26'; 'LI27'; 'LI28'; 'LI29'; 'LI30'};
m = ones( length( sectors ), 1);

% Just comment out in case we use Linac Upgrade in future
% try
%     [sectors,m]=luGetCamacState;
% catch
%     err = lasterror;
%     if strfind(err.identifier,'CAMACunknown')
%         message = 'Unable to initialize MDL loop. Exiting.';
%         message_verbose = sprintf('%s.\n%s\n',err.message,message);
%         fbLogMsg(sprintf('MDL: %s',message_verbose));
%         fbDispMsg(message, loop.feedbackAcro, 2);
%         disp(message_verbose);
%     else
%         dbstack;
%     end
%     rethrow(lasterror);
% end

% Store sector names and CAMAC states in loop structure
% for use when writing to actuators - do we need this?
loop.act.sectors = sectors;
loop.act.camac = m;

% get the matrix
loop.matrix = config.matrix;

% We're not using the check PV, but fbStart requires it
loop.check = config.check;
loop.check.pulseidPV = {'FBCK:MDL0:1:PULSEID'}; 
loop.check.infoPVs = {'PATT:SYS0:1:PULSEIDBR'};

% Hardcode timeout and number of measurements to average. Timeout can be
% removed after Linac Upgrade complete.
loop.meas.nummeasAvg = 1; %10; 
loop.meas.lcaTimeout = 1.0;

%lcaSetTimeout(0.2);

%create storage for the current, and last actuator values calculated, 
%these are column vectors
actData.current = zeros(loop.act.numactPVs, 1);
actData.nminus1 = zeros(loop.act.numactPVs, 1);
loop.actData = actData;

% Hard-code "normal" temperature and barometic pressure, used in calculation 
% in fbMDLTimerFcn.m (pressure normal val set to 1013/0.99--1013 was SLC
% loop value, (LI07 MDL P)/(MCC OUTSIDE P)=0.99. 
%   Search chosen measurement PV strings for 'TEMP' and 'PRES' to determine 
%   which it is, then select appropriate "normal" value. If PV name doesn't 
%   contain one of those strings, throw exception.
% Select chosen f-matrix elements based on chosen measurements.
normalValTemp=95; normalValPres=1023.2;
for i=1:length(loop.meas.chosenmeasPVs)
    if strfind(char(loop.meas.chosenmeasPVs(i)),'TEMP')
        loop.meas.chosennormalVals(i)=normalValTemp;
    elseif strfind(char(loop.meas.chosenmeasPVs(i)),'PRES')
        loop.meas.chosennormalVals(i)=normalValPres;
    else
        message = 'Unable to initialize MDL loop. Exiting.';
        message_verbose = sprintf('Failed to set normal meas vals.\n%s is neither pressure nor temperature?\n%s\n',char(loop.meas.chosenmeasPVs(i)),message);
        fbLogMsg(sprintf('MDL: %s',message));
        fbDispMsg(message, loop.feedbackAcro, 2);
        disp(message_verbose);
        exception = MException('fbInitMDLLoop:MeasDevType', 'Measurement(s) not temp or pres');
        throw(exception);
    end
end
loop.matrix.chosenf = cell2mat(fbGetPVNames(loop.meas.PVs,num2cell(loop.matrix.f)));

% Define constants used for state calculations
% These constants have been copied from MDL_COMP_DRVR, the SLC MDL loop
% code.
loop.misc.constant=101.6/2956.4;
loop.misc.corr_coef=0.038; 
loop.misc.pt_offset=185.3;

% Define first and last sector numbers, which are used in command calculation 
% Last sector is sector of last chosen actuator
% First sector is 21 and has zero compensation (hence name)
loop.misc.sec_last=str2double(fbGetPvSectorNumber(loop.act.chosenactPVs(loop.act.numactPVs)));
loop.misc.sec_zero=21;

% clear message 
fbDispMsg(' ', loop.feedbackAcro, 0);

%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);

