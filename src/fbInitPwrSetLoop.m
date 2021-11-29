function fbInitPwrSetLoop()
% this routine is called when the laser power set feedback loop is started.
% It reads the latest config values and places them in the loop structure 
% to be used during the feedback operation.  
%
% The functions in this module are specific to the Bunch Charge feedback
% where a softIOC PV LASR:IN20:1:PCTRL is the actuator.  This function
% initializes the laser power set 
% reads the softIOC PV LASR:IN20:1:PCTRL, and moves the laser waveplate
% to adjust the power as requested.  The camera waveplate is also moved
% in order to protect the camera. See Joe Frisch for questions on this 
% init function


% get the config and loop structures
config = getappdata(0,'Config_structure');
loop = getappdata(0,'Loop_structure');

% init feedback loop parameters
loop.feedbackAcro = config.feedbackAcro;
loop.states = config.states;
loop.act = config.act;
loop.act.chosenactPVs = loop.act.allactPVs;
loop.meas = config.meas;
loop.ctrl = config.ctrl;
%debug for now, this PV is not in FB00
loop.ctrl.allctrlPVs = [];

loop.state = 0; % is loop on (1) or off (0); init to off
loop.lCnt = 0; % loop count; init to 0

% set the count and enable PVs
loop.cntPV = ['FBCK:LPS' config.feedbackNum ':1:COUNT'];
loop.enablePV = ['FBCK:LPS' config.feedbackNum ':1:ENABLE'];
loop.indStatePV = ['FBCK:LPS' config.feedbackNum ':1:STATE'];
lcaPut(loop.cntPV,loop.lCnt);
loop.enable = lcaGet(loop.enablePV);
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

% set up PVs for moving waveplate and camera
loop.laser_pwr_pv = 'LASR:BCIS:1:PCTRL';
loop.camera_pwr_pv = 'LASR:BCIS:1:CCTRL';
loop.wp_pv = 'WPLT:LR20:116:WP2_ANGLE.VAL';
loop.camera_pv = 'WPLT:IN20:181:VCC_ANGLE.VAL';
loop.wp_dmov = 'WPLT:LR20:116:WP2_ANGLE.DMOV';
loop.wp_movn = 'WPLT:LR20:116:WP2_ANGLE.MOVN';
loop.wp_spmg = 'WPLT:LR20:116:WP2_ANGLE.SPMG';
loop.camera_dmov = 'WPLT:IN20:181:VCC_ANGLE.DMOV';
loop.camera_movn = 'WPLT:IN20:181:VCC_ANGLE.MOVN';
loop.camera_spmg = 'WPLT:IN20:181:VCC_ANGLE.SPMG';

loop.wp_readback = 'WPLT:LR20:116:WP2_ANGLE.RBV';
loop.camera_rb = 'WPLT:IN20:181:VCC_ANGLE.RBV';

lcaSetTimeout(0.2);

loop.delay = 2.0; % overall delay time

% look at old data to get curve
%angle = dat(1:23,1);
%pwr = dat(1:23,2);
%pwr_norm = pwr ./ max(pwr); %normalized power
%loop.angle_offset = 133;
%an = angle - loop.angle_offset;
%loop.P = polyfit(an, pwr_norm, 4);
%loop.P2 = polyfit(pwr_norm, an, 4);
%afit = polyval(loop.P2, pwr_norm);
%err_a = std(afit - an);

% get the maximum angle for the camera
%These values should be calibrated and set in a PV, 
loop.pw_maxAnglePV = 'WPLT:LR20:116:ANG_MAX';
loop.cam_maxAnglePV = 'WPLT:IN20:181:ANG_MAX';
loop.power_max_angle = lcaGet(loop.pw_maxAnglePV);
loop.camera_max_angle = lcaGet(loop.cam_maxAnglePV);
%loop.power_max_angle = 77; % SET THIS  - can we read a PV set by sheng????
%loop.camera_max_angle = 165; % SET THIS - can we read a PV set by sheng???

%lcaPut([loop.laser_pwr_pv, '.DESC'], 'Laser power ');
%lcaPut([loop.camera_pwr_pv, '.DESC'], 'Camera intensity ');
%lcaPut([loop.laser_pwr_pv, '.EGU'], '%');
%lcaPut([loop.camera_pwr_pv,'.EGU'], '%');
%
% initial calculation of power percentage based on current and max angles
power_wp_angle = lcaGet(loop.wp_pv);
current_power = 100*(cos((pi/90)*(power_wp_angle - loop.power_max_angle))^2);
lcaPut(loop.laser_pwr_pv, current_power);
%
lcaSetMonitor(loop.laser_pwr_pv); % look for changes
lcaSetMonitor(loop.camera_pwr_pv); % look for changes

% clear message 
fbDispMsg(' ', loop.feedbackAcro, 0);

%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);
