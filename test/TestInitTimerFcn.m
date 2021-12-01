function fbInitLongLoop()
% this routine is called when the feedback program is started, and
% whenever the transverse feedback loop is started. It reads the latest 
%config values and places them in the loop structure to be used during 
% the feedback operation.  

% get the config and loop structures
config = getappdata(0,'Config_structure');
loop = getappdata(0,'Loop_structure');

% init feedback loop parameters
loop.state = 0; % is loop on (1) or off (0); init to off
loop.lCnt = 0; % loop count; init to 0
loop.feedbackAcro = config.feedbackAcro;
loop.feedbackNum = config.feedbackNum;

% set the count and enable PVs
loop.cntPV = ['FBCK:LNG' config.feedbackNum ':1:COUNT'];
loop.enablePV = ['FBCK:LNG' config.feedbackNum ':1:ENABLE'];
loop.indStatePV = ['FBCK:LNG' config.feedbackNum ':1:STATE'];
lcaPut(loop.cntPV,loop.lCnt);
loop.enable = lcaGet(loop.enablePV);

% get the timer structure
loop.timer = config.timer; % 

%initialize the fbck timer
loop.fbckTimer = config.fbckTimer;
loop.fbckTimer.ExecutionMode = 'fixedSpacing'; 
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

%get the reference orbit data for the chosen BPMS only
%do this by deleting columns not chosen
loop.refData = config.refData;
loop.refInit = config.refInit;
i = length(loop.meas.allmeasPVs);
while i>=1
    if loop.meas.PVs(i)~=1
        loop.refData.data(i) = [];
    end
    i=i-1;
end

%get the reference orbit data for the chosen actuators only
%do this by deleting columns not chosen
i = length(loop.act.allactPVs);
while i>=1
    if loop.act.PVs(i)~=1
        loop.refData.actvals(i) = [];
    end
    i=i-1;
end

% check PVs tolerances defaults
loop.check.low = 1e9;  % lowest TMIT value allowed
loop.check.var = 0.3;  % variance around GUN BPM TMIT value (0.3 = 30%)

%check PVs (we do not want the energy BPMS, use BPMS nearby)
if (str2num(loop.feedbackNum)==0)
   loop.check.chkPVs = {'BPMS:IN20:651:TMIT'; 'BPMS:IN20:221:TMIT'};  
   loop.check.dsprPVs = {};
   loop.check.mirrorPVs = {};
else
   if (str2num(loop.feedbackNum)==1)
      loop.check.chkPVs = {'BPMS:IN20:781:TMIT'; 'BPMS:IN20:221:TMIT'};
      loop.check.dsprPVs = {};
      loop.check.mirrorPVs = {};
   else
      if (str2num(loop.feedbackNum)<=3)
         loop.check.chkPVs = {'BPMS:IN20:781:TMIT'; 'BPMS:LI21:301:TMIT'; 'BPMS:IN20:221:TMIT'};
         loop.check.dsprPVs = {'BMLN:LI21:235:LVPOS'};
         loop.check.mirrorPVs = {'BLEN:LI21:265:BL11_PNEU.RVAL'};
      else 
         %lower limit because the dspr BPMs still have good
         loop.check.low = 1e8; %X readings when TMIT is quite low 
         loop.check.chkPVs = {'BPMS:IN20:781:TMIT'; 'BPMS:LI21:301:TMIT'; 'BPMS:LI24:801:TMIT'; 'BPMS:IN20:221:TMIT'};
         loop.check.dsprPVs = {'BMLN:LI21:235:LVPOS'; 'BMLN:LI24:805:LVPOS'};
         loop.check.mirrorPVs = {'BLEN:LI21:265:BL11_PNEU.RVAL'; 'BLEN:LI24:886:BL21_PNEU.RVAL'};
      end
   end
end

%init the matrices from config
loop.matrix = config.matrix; % 
%calculate the multiplier matrix once here; 
% G.*F will perform element-wise multiply
loop.matrix.mult = loop.matrix.g.*loop.matrix.f;
loop.states.pGains = [loop.states.pGain loop.states.pGain 0.002];
loop.states.iGains = [loop.states.iGain loop.states.iGain 0.002];

%create and store state error data structure,
%the state error data is saved on each loop up to the required number for
%integral calculation
%the errData.data matrix is #data points(rows) x #states(cols)
errData.count = 0;
errData.wrap = 0;
errData.avg = 0;
errData.max = loop.states.maxerrs;
errData.data = zeros(loop.states.numstatePVs,errData.max); %start with zeros array
loop.errData = errData; 

%create storage for the original, current, and last 2 actuator values calculated, 
%these are column vectors
actData.original = loop.refData.actvals;
actData.current = lcaGet(loop.act.chosenactPVs);
actData.nminus1 = zeros(loop.act.numactPVs, 1);
actData.nminus2 = zeros(loop.act.numactPVs, 1);
actData.Ph24_1_ismax=1; % record that 24-1 is the larger to begin
% if we are running fbnum>3 we need to init the 24-1 and 24-2 values
if (str2num(loop.feedbackNum)>3)
   len = loop.act.numactPVs;
   if (actData.current(len-1,1)<actData.current(len,1))
      actData.Ph24_1_ismax = -1;
   end
end   
loop.actData = actData;

% create the measData running average structure
measData.count = 0;
measData.wrap = 0;
measData.avg = 0;
measData.max = 10; %loop.meas.maxsamples;
measData.data = zeros(loop.meas.nummeasPVs,measData.max);
loop.measData = measData;

% reset status string
fbDispMsg(' ', loop.feedbackAcro, 0);

%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);
