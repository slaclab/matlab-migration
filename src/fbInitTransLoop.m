function fbInitTransLoop()
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

% set the gain and count PVs
loop.cntPV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:COUNT'];
loop.enablePV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:ENABLE'];
loop.indStatePV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:STATE'];
lcaPut(loop.cntPV,loop.lCnt);
loop.enable = lcaGet(loop.enablePV);

% get the timer structure
loop.timer = config.timer; 

%initialize the timer
loop.fbckTimer = config.fbckTimer;
loop.fbckTimer.ExecutionMode = 'fixedSpacing'; 
loop.fbckTimer.period = loop.timer.period; 
loop.fbckTimer.TasksToExecute =loop.timer.max; 
set(loop.fbckTimer, 'TimerFcn', config.timer.fcnName);
set(loop.fbckTimer, 'StopFcn', 'fbStopTimer');


% init the ctrl PVs from config
loop.ctrl = config.ctrl;

% init the states
loop.states = config.states;
loop.states.numstatePVs = length(loop.states.chosenstatePVs);

%measurement PVs
loop.meas = config.meas;
loop.meas.nummeasPVs = length(loop.meas.chosenmeasPVs);

%actuator PVs
loop.act = config.act;
loop.act.numactPVs = length(loop.act.chosenactPVs);

%check PVs
loop.check.chkPVs = fbGetTMITPVs(loop.meas.chosenmeasPVs);
loop.check.low = 1e9;  % lowest TMIT value allowed
loop.check.var = 0.3;  % variance around GUN BPM TMIT value (0.3 = 30%)
loop.check.infoPVs = {'SIOC:SYS0:FB00:TMITLOW'; 'PATT:SYS0:1:PULSEIDBR'};
loop.check.pulseidPV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:PULSEID'];

% create map of which chosen BPM PVs are X, which are Y
if loop.meas.nummeasPVs>0
   loop.meas.BPM_Xs = zeros(loop.meas.nummeasPVs, 1);
   loop.meas.BPM_Ys = zeros(loop.meas.nummeasPVs, 1);
   %find the BPM X and BPM Y meas's - this assumes the first PV is a BPM X
   str = loop.meas.chosenmeasPVs(1);
   for i=1:3
      [t, str] = strtok(str,':');
   end
   BPMXs = strfind(loop.meas.chosenmeasPVs,char(str));

   for i=1:loop.meas.nummeasPVs
      if (BPMXs{i,1} > 0)
         loop.meas.BPM_Xs(i,1) = 1;
      else
         loop.meas.BPM_Ys(i,1) = 1;
      end
   end
end

%get the reference orbit data from the chosen BPMS
%do this by deleting columns not chosen
loop.refData = config.refData;
loop.refInit = config.refInit;
i = length(loop.meas.allmeasPVs);
try
   while i>=1
    if loop.meas.PVs(i)~=1
        loop.refData.data(i) = [];
    end
    i=i-1;
   end
catch
   dbstack;
   fbDispMsg('Bad Ref. Orbit, get new one.', loop.feedbackAcro, 2);
   disp('Bad Ref Orbit, use Config/Ref. Orbit to collect a new one');
   rethrow(lasterror);
   disp('Bad Ref Orbit, use Config/Ref. Orbit to collect a new one');
end

%get the reference orbit data for the chosen actuators only
%do this by deleting columns not chosen
i = length(loop.act.allactPVs);
try
   while i>=1
       if loop.act.PVs(i)~=1
           loop.refData.actvals(i) = [];
       end
      i=i-1;
   end
catch
   dbstack;
   disp('Bad Ref Orbit, use Config/Ref. Orbit to collect a new one');
   rethrow(lasterror);
end
   

%if there are resolution PVs, use them
if (~isempty(loop.meas.chosenresPVs))
   %read the BPM measurement resolutions, and references
   %create lists of BPM X and Y PV names
   try
      res = lcaGet(loop.meas.chosenresPVs);
   catch
      dbstack;
      disp('Could not read BPM resolution PVs');
      rethrow(lasterror);
   end
else
   res = zeros(1,length(loop.meas.chosenmeasPVs));
end

% use reference orbit and resolution info here
ref = loop.refData.data;
x=0; y=0;
loop.meas.dXs = [];
loop.meas.dYs = [];
loop.meas.Xs0 = [];
loop.meas.Ys0 = [];
for i=1:loop.meas.nummeasPVs
    if loop.meas.BPM_Xs(i,1)==1
        x=x+1;
        loop.meas.dXs(1,x) = res(i);
        loop.meas.Xs0(1,x) = ref(i);
    elseif loop.meas.BPM_Ys(i,1)==1
        y=y+1;
        loop.meas.dYs(1,y) = res(i);
        loop.meas.Ys0(1,y) = ref(i);
    end
end

% if there is no reference orbit (ie: the zero orbit), or no resolution PVs then don't try error
if (loop.refInit==0)
   loop.meas.Xs0 = 0;
   loop.meas.Ys0 = 0;
end

if (isempty(loop.meas.chosenresPVs))
   loop.meas.dXs = 1;
   loop.meas.dYs = 1;
end

%init the matrices from config
loop.matrix= config.matrix; 
%if this is the undulator launch calc f matrix from polynomials
if (strcmp(loop.feedbackAcro, 'UND')>0)
   BY1_energy = lcaGet('BEND:LTU0:125:BDES');
   loop.matrix.f = fbCalcUndMatrix(loop.meas, BY1_energy);
end
%create and store err data structure, for use in integral gain factor
%the error data is saved on each loop
%the errData.data matrix is #data points(rows) x #states(cols)
errData.count = 0;
errData.max = loop.states.maxerrs;
errData.data = zeros(errData.max, loop.states.numstatePVs); %start with zeros array
errData.avg = 0;
loop.errData = errData; 

%create storage for the original, current, and last 2 actuator values calculated, 
%these are column vectors
actData.original = loop.refData.actvals;
actData.current = zeros(loop.act.numactPVs, 1);
actData.nminus1 = zeros(loop.act.numactPVs, 1);
actData.nminus2 = zeros(loop.act.numactPVs, 1);
loop.actData = actData;

%if this loop is near L3, get energy values from BY1 or magnets for L28
try
   BY1_energy = lcaGet('BEND:LTU0:125:BDES');
   if any(strcmp(loop.feedbackAcro, {'BSY'; 'DL2'; 'LTU'; 'LTL'; 'UND'}) )
      loop.act.energy = ones(size(loop.act.energy))*BY1_energy;
   end
   if any(strcmp(loop.feedbackAcro, {'L28'}) )
      epicsActs = regexprep(loop.act.allactPVs, ':\w*', ':EACT', 3);
      loop.act.energy = lcaGet(epicsActs);
   end
catch
   dbstack;
   disp('Cannot get energy at BY1 or LI28');
   %rethrow(lasterror);
end

fbDispMsg(' ', loop.feedbackAcro, 0);

%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);
