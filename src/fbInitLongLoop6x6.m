function fbInitLongLoop6x6()
% this routine is called whenever the longitudinal feedback loop is 
% started. It reads the latest config values and places them in the 
% loop structure to be used during the feedback operation.  
%
% Each Fast Feedback loop controller should be able to get all config 
% data from it's own PVs
%
% get the config and loop structures
config = getappdata(0,'Config_structure');
loop = getappdata(0,'Loop_structure');

% further config changes, read the tolerances and setpoints from softIOC
try
   config.states = fbSoftIOCFcn('GetStatesInfo',config.states);
   config.act = fbSoftIOCFcn('GetActInfo',config.act);
   config.meas = fbSoftIOCFcn('GetMeasInfo',config.meas);
catch
   dbstack;
   h = errordlg('Could not read FB00 PVs');
   waitfor(h);
   rethrow(lasterror);
end

% save the new configuration now, so that the following functions work
setappdata(0, 'Config_structure', config);

% calc matrices if necessary
if isempty(config.matrix.f)
    if ~strcmp(config.matrix.fFcnName,'0')
        calcFmatrix = str2func(config.matrix.fFcnName);
        config.matrix.f = calcFmatrix();
        config.configchanged=1;
    end
end
%do our best to get a g matrix
if isempty(config.matrix.g)
    if ~strcmp(config.matrix.gFcnName,'0')
        calcGmatrix = str2func(config.matrix.gFcnName);
        config.matrix.g = calcGmatrix();
        config.configchanged=1;
    end
end

%get dispersion values for specific BPMs and record them in the softIOC
% these are save-restored, but originally from Model DB, do we always
% replace with data from DB???
dispersion = config.meas.dispersion;
if (~isempty(dispersion))
   try
      config.meas.dispersion = fbGet_MeasDspr(config.meas);
      % now update the soft IOC
      dsprNames = fbAddToPVNames(config.meas.allstorePVs, 'DSPR');
      lcaPut(dsprNames, config.meas.dispersion);
   catch
      dbstack;
      config.meas.dispersion = dispersion;
      disp([config.feedbackAcro ' could not read dispersion values; using defaults.']);
      fbLogMsg([config.feedbackAcro ' could not read dispersion values; using defaults.']);
   end
end

%save this config structure
setappdata(0, 'Config_structure', config);

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

%create the feedback status pv name and set the hostname
loop.statusPV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:STATUS.DESC'];
[a,host]=unix('hostname');
loop.host = regexprep(host, '.slac.stanford.edu', '');

% get the timer structure
loop.timer = config.timer; % 

%initialize the fbck timer structure
loop.fbckTimer = config.fbckTimer;
loop.fbckTimer.ExecutionMode = 'fixedSpacing'; 
loop.fbckTimer.period = loop.timer.period; 
loop.fbckTimer.TasksToExecute =loop.timer.max; 
set(loop.fbckTimer, 'TimerFcn', config.timer.fcnName);
set(loop.fbckTimer, 'StopFcn', 'fbStopTimer'); %use the full-stop timer

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

%init the matrices from config
loop.matrix = config.matrix; % 

% get the desired states PV names and initialize indicators
loop.states.alldesPVs = fbAddToPVNames(loop.states.allstatePVs, 'UDES.RVAL');
loop.states.desStates= lcaGet(loop.states.alldesPVs);
loop.conditions = 0; %for now

% check PVs tolerances defaults
loop.check.low = 1e9;  % lowest TMIT value allowed
loop.check.var = 0.3;  % variance around GUN BPM TMIT value (0.3 = 30%)
loop.check.infoPVs = {'SIOC:SYS0:FB00:TMITLOW'; 'PATT:SYS0:1:PULSEIDBR'};
loop.check.pulseidPV = ['FBCK:' config.feedbackAcro config.feedbackNum ':1:PULSEID'];
loop.check.msgPVs = {'SIOC:SYS0:FB00:L2_STATMSG'; 'SIOC:SYS0:FB00:L2_STATMSG.RVAL';...
   'SIOC:SYS0:FB00:L3_STATMSG'; 'SIOC:SYS0:FB00:L3_STATMSG.RVAL'};

% L2 energy and L3 energy contribution PVs
%loop.act.L3_vPVs = {'SIOC:SYS0:ML00:AO280'; 'SIOC:SYS0:ML00:AO281'}; %joe's matlab PVs
%loop.act.L3_v = [1880;1880];
%loop.act.L2_v = [250; 250];
% L2 and L3 amp and phase PVs
%loop.act.EandCPVs = {'SIOC:SYS0:ML00:AO059';'SIOC:SYS0:ML00:AO061';... % L2 amp & phase
%                     'SIOC:SYS0:ML00:AO075';'SIOC:SYS0:ML00:AO064' }; % L3 amp & phase

%lower limit because the dspr BPMs still have good
loop.check.low = 1e8; %X readings when TMIT is quite low 
loop.check.chkPVs = { 'BPMS:IN20:781:TMIT'; 'BPMS:LI21:301:TMIT'; 'BPMS:LI24:801:TMIT'; 'BPMS:BSY0:52:TMIT';'BPMS:BSY0:92:TMIT';'BPMS:IN20:221:TMIT'};
%loop.check.destPVs = {'BPMS:IN20:981:TMIT';'BPMS:BSY0:52:TMIT'; 'BPMS:LTU1:550:TMIT'};
loop.check.dsprPVs = {'BMLN:LI21:235:LVPOS'; 'BMLN:LI24:805:LVPOS'};
loop.check.mirrorPVs = {'BLEN:LI21:265:BL11_PNEU.RVAL'; 'BLEN:LI24:886:BL21_PNEU.RVAL'};
loop.check.dumpPVs = {'DUMP:LI21:305:TD11_IN.RVAL'; 'STPR:BSYH:847:IN.RVAL'; 'DUMP:LTU1:970:TDUND_IN.RVAL'};
loop.check.mgntPVs = {'BEND:IN20:751:BACT'; 'CA11:LGPS:41:STRG'; 'IOC:BSY0:MP01:BYKIKCTL.RVAL'};
%get the coeffs for calculating at DL2 or BSY , used at start/stop only
try
  loop.meas.DL2K_eCoeffs = lcaGet({'SIOC:SYS0:FB00:DL2K_COEFF1';'SIOC:SYS0:FB00:DL2K_COEFF2'});
  loop.meas.BSY_eCoeffs = lcaGet({'SIOC:SYS0:FB00:BSY_COEFF1';'SIOC:SYS0:FB00:BSY_COEFF2'});
  loop.meas.DL2_energy = lcaGet('BEND:LTU0:125:BDES')*1000; %convert to MeV from GeV
catch
  dbstack;
  loop.meas.DL2K_eCoeffs = [0;0];
  loop.meas.BSY_eCoeffs = [0;0];
  loop.meas.DL2_energy = 13640;
  disp([config.feedbackAcro ' could not read coeffs. for energy calc; using defaults.']);
  fbLogMsg([config.feedbackAcro ' could not read coeffs. for energy calc; using defaults.']);
end

%create or reset the state error data structure,
%the state error data is saved on each loop up to the required number for
%integral calculation
%the errData.data matrix is #data points(rows) x #states(cols)
errData.count = 0;
errData.wrap = 0;
errData.avg = 0;
errData.max = loop.states.maxerrs;
errData.data = zeros(length(loop.states.allstatePVs),errData.max); %start with zeros array
loop.errData = errData; 

%create storage for the original, current, and last 2 actuator values calculated, 
%these are column vectors
% longitudinal feedbacks do not use a reference orbit, so the
% original=current actuator values
try
   %read the current energy and chirp values
   %actData.current_ec = lcaGet(loop.act.EandCPVs);
   %read the current phase and amp/ phase and phase settings
   actData.current = lcaGet(loop.act.allrbPVs);
   actData.original = actData.current;
   actData.nminus1 = zeros(length(loop.act.allactPVs), 1);
   actData.nminus2 = zeros(length(loop.act.allactPVs), 1);
   loop.actData = actData;
   % write the original values to the restore storage place
   %rstrNames = fbAddToPVNames(loop.act.chosenstorePVs, 'RSTR');
   %lcaPut(rstrNames, actData.original);
catch
   dbstack;
   fbLogMsg(['Could not read actuator PVs, ' config.feedbackName ' quitting']);
   rethrow(lasterror);
end

% create the measData running average structure
measData.count = 0;
measData.wrap = 0;
measData.avg = 0;
measData.max = 10; %loop.meas.maxsamples;
measData.data = zeros(length(loop.meas.allmeasPVs),measData.max);
loop.measData = measData;


%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);
end
