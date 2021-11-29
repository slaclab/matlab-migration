% energy_feedback_bc2


function energy_feedback_new()

delay = .2; % sets loop speed
% Generate watchdog conter, 1Hz update,

W = watchdog('SIOC:SYS0:ML00:AO047',ceil(1/delay), 'energy_feedback_new' );
if get_watchdog_error(W)
  messagedisp('Another energy feedback is running, exiting');
  return
end

messagedisp('energy_feedback_new.m 07/25/12 v15.0 started'); % Add PV for allowed loss

% set up event definitions

eDef4 = eDefReserve('Feedback TS4 & 30Hz');
if eDef4 == 0
    messagedisp('Did not get an eDef!');
else
    messagedisp(['Acquired TS4 eDef number ' num2str(eDef4)]);
    
    % set up the event definition to get 1 data point at a time, go
    % forever, and only work at ONE_HERTZ
    try
        
    eDefParams(eDef4, 1, -1, {'TS4'; 'RATE_30HZ'}, {}, {'TS1'}, {});  % incl TS4 & 30Hz, excl other TS
    eDefOn(eDef4);
    catch
        messagedisp(['Problem activating eDef ' num2str(eDef4) ' - exiting']);
        return
    end
    messagedisp(['eDef number ' num2str(eDef4) ' is on!']);
end

eDef1 = eDefReserve('Feedback TS1 & 30Hz');
if eDef1 == 0
    messagedisp('Did not get an eDef!');
else
    messagedisp(['Acquired TS1 eDef number ' num2str(eDef1)]);
    
    % set up the event definition to get 1 data point at a time, go
    % forever, and only work at ONE_HERTZ
    try
        
    eDefParams(eDef1, 1, -1, {'TS1'; 'RATE_30HZ'}, {}, {'TS4'}, {});  % incl TS1 & 30Hz, excl other TS
    eDefOn(eDef1);
    catch
        messagedisp(['Problem activating eDef ' num2str(eDef1) ' - exiting']);
        return
    end
    messagedisp(['eDef number ' num2str(eDef1) ' is on!']);
end

eDef4n = eDefReserve('Feedback TS4 & ~30Hz');
if eDef4n == 0
    messagedisp('Did not get an eDef!');
else
    messagedisp(['Acquired TS4 eDef number ' num2str(eDef4n)]);
    
    % set up the event definition to get 1 data point at a time, go
    % forever, and only work at ONE_HERTZ
    try
        
    eDefParams(eDef4n, 1, -1, {'TS4'}, {}, {'TS1'; 'RATE_30HZ'}, {});  % incl TS4, excl 30Hz, excl other TS
    eDefOn(eDef4n);
    catch
        messagedisp(['Problem activating eDef ' num2str(eDef4n) ' - exiting']);
        return
    end
    messagedisp(['eDef number ' num2str(eDef4n) ' is on!']);
end

eDef1n = eDefReserve('Feedback TS1 & ~30Hz');
if eDef1n == 0
    messagedisp('Did not get an eDef!');
else
    messagedisp(['Acquired TS1 eDef number ' num2str(eDef1n)]);
    
    % set up the event definition to get 1 data point at a time, go
    % forever, and only work at ONE_HERTZ
    try
        
    eDefParams(eDef1n, 1, -1, {'TS1'}, {}, {'TS4'; 'RATE_30HZ'}, {});  % incl TS1, excl 30Hz, excl other TS
    eDefOn(eDef1n);
    catch
        messagedisp(['Problem activating eDef ' num2str(eDef1n) ' - exiting']);
        return
    end
    messagedisp(['eDef number ' num2str(eDef1n) ' is on!']);
end

ts4_30_edef_pv  = script_setupPV(867, '6x6 eDef TS4 & 30Hz',  'num', 0, 'energy_feedback_new');
ts1_30_edef_pv  = script_setupPV(868, '6x6 eDef TS1 & 30Hz',  'num', 0, 'energy_feedback_new');
ts4_n30_edef_pv = script_setupPV(869, '6x6 eDef TS4 & ~30Hz', 'num', 0, 'energy_feedback_new');
ts1_n30_edef_pv = script_setupPV(870, '6x6 eDef TS1 & ~30Hz', 'num', 0, 'energy_feedback_new');

lcaPutSmart(ts4_30_edef_pv,  eDef4);
lcaPutSmart(ts1_30_edef_pv,  eDef1);
lcaPutSmart(ts4_n30_edef_pv, eDef4n);
lcaPutSmart(ts1_n30_edef_pv, eDef1n);

str4 = num2str(eDef4);
str1 = num2str(eDef1);

% input PVs
[name, is, PACT, PDES, GOLD, KPHR, AACT, ADES]=control_phaseNames({'L2' 'L3'}); %for L2, L3 PDES and ADES
pvs = cell(1,1);  % will expand this later
n = 1;
pvs{n,1} = PDES{1}; % L2 phase control pv (in degrees)
L2_phase_control_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO023'; % Overall feedback gain pv
overall_gain_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO029'; % Gain for bunch length
current_gain_num = n;

% two sets of BSA PVs, for two timeslots
n = n + 1;
pvs{n,1} = ['BLEN:LI24:886:BIMAX' str4]; % peak current pv (beam synchronous)
BC2_peak_current_n = n;
n = n + 1;
pvs{n,1} = ['BLEN:LI21:265:AIMAX' str4]; % peak current BC1 (beam synchronous)
BC1_peak_current_n = n;

n = n + 1;
pvs{n,1} = ['BLEN:LI24:886:BIMAX' str1]; % peak current pv (beam synchronous)
BC2_peak_current_n_1 = n;
n = n + 1;
pvs{n,1} = ['BLEN:LI21:265:AIMAX' str1]; % peak current BC1 (beam synchronous)
BC1_peak_current_n_1 = n;


n = n + 1;
pvs{n,1} = ADES{1}; % L2 amplitude control pv (in MeV)
L2_amplitude_control_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI22:1:FANCY_PH_CTRL'; %enable fancy phase control
fancy_phase_control_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO044'; % bc2 peak current set point
BC2_current_setpoint_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO016'; % bc1 current_setpoint
BC1_current_setpoint_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO066'; % phase control busy
busy_num = n;
n = n + 1;

pvs{n,1} = 'SIOC:SYS0:ML00:AO626'; % undulator k
undulator_k_n = n;

n = n + 1;
pvs{n,1} = ['BPMS:IN20:221:TMIT' str4]; % gun tmit
gun_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:IN20:731:TMIT' str4]; % DL1 timt
DL1_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:IN20:731:X' str4]; % DL1 X
DL1_x_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI21:233:TMIT' str4]; % BC1 tmit
BC1_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI21:233:X' str4]; % BC1 X
BC1_x_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI24:801:X' str4]; % BC2 X
BC2_x_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI24:801:TMIT' str4]; % BC2 tmit
BC2_tmit_n = n;


n = n + 1;
pvs{n,1} = ['BPMS:IN20:221:TMIT' str1]; % gun tmit
gun_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:IN20:731:TMIT' str1]; % DL1 timt
DL1_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:IN20:731:X' str1]; % DL1 X
DL1_x_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI21:233:TMIT' str1]; % BC1 tmit
BC1_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI21:233:X' str1]; % BC1 X
BC1_x_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI24:801:X' str1]; % BC2 X
BC2_x_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LI24:801:TMIT' str1]; % BC2 tmit
BC2_tmit_n_1 = n;

n = n + 1;
pvs{n,1} = 'ACCL:IN20:400:L0B_ADES'; % L0B voltage (control, non sync)
L0B_voltage_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI21:1:L1S_ADES'; % L1S amplitude (control, non sync)
L1S_amplitude_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI21:1:L1S_PDES'; % L1S phase (control, non sync)
L1S_phase_n = n;

n = n + 1;
pvs{n,1} = ['BPMS:BSY0:52:TMIT' str4]; % BSY BPM 52 tmit
BSY_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:BSY0:52:X' str4];  % BSY BPM 52 X
BSY_x_n = n;

n = n + 1;
pvs{n,1} = ['BPMS:BSY0:52:TMIT' str1]; % BSY BPM 52 tmit
BSY_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:BSY0:52:X' str1];  % BSY BPM 52 X
BSY_x_n_1 = n;

n = n + 1;
pvs{n,1} = ADES{2}; % L3 amplitude control
L3_amplitude_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO017'; % Phase scans set this to 1. %%% add to display
phase_scan_running_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI22:1:A_NOFS'; % L2 no feedback, flat, total amplitude
L2_nofb_amplitude_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI25:1:A_NOFS'; % L3 no feedback, flat total amplitude
L3_nofb_amplitude_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI29:0:A_SUM'; % Sector 29 total amplitude
S29_nofb_amplitude_n = n;
n = n + 1;
pvs{n,1} = 'ACCL:LI30:0:A_SUM'; % Sector 30 total amplitude
S30_nofb_amplitude_n = n;

n = n + 1;
pvs{n,1} = ['BPMS:LTU0:170:TMIT' str4]; % LTU Y bpm TMIT
LTU_0_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU0:170:Y' str4];  % LTU Y BPM Y
LTU_0_x_n = n;

n = n + 1;
pvs{n,1} = ['BPMS:LTU1:250:TMIT' str4]; % First LTU bpm tmit
LTU_1_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU1:250:X' str4];  % first LTU bpm X
LTU_1_x_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU1:450:TMIT' str4]; % Second LTU bpm tmit
LTU_2_tmit_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU1:450:X' str4]; % Second LTU bpm x
LTU_2_x_n = n;
n = n + 1;
pvs{n,1} = ['BPMS:DMP1:693:TMIT' str4]; % Dump bpm tmit
DMP_tmit_n = n; 
n = n + 1;
pvs{n,1} = ['BPMS:DMP1:693:Y' str4]; % Dump bpm Y
DMP_y_n = n;


n = n + 1;
pvs{n,1} = ['BPMS:LTU0:170:TMIT' str1]; % LTU Y bpm tmit
LTU_0_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU0:170:Y' str1];  % LTU Y bpm Y
LTU_0_x_n_1 = n;

n = n + 1;
pvs{n,1} = ['BPMS:LTU1:250:TMIT' str1]; % First LTU bpm tmit
LTU_1_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU1:250:X' str1];  % first LTU bpm X
LTU_1_x_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU1:450:TMIT' str1]; % Second LTU bpm tmit
LTU_2_tmit_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:LTU1:450:X' str1]; % Second LTU bpm x
LTU_2_x_n_1 = n;
n = n + 1;
pvs{n,1} = ['BPMS:DMP1:693:TMIT' str1]; % Dump bpm tmit
DMP_tmit_n_1 = n; 
n = n + 1;
pvs{n,1} = ['BPMS:DMP1:693:Y' str1]; % Dump bpm Y
DMP_y_n_1 = n;


n = n + 1;
pvs{n,1} = 'IOC:IN20:BP01:QANN'; % BPM nominal charge
beam_charge_n = n;
n = n + 1;
%pvs{n,1} = 'SIOC:SYS0:ML00:AO286'; % Energy based on magnet setting
pvs{n,1} = 'REFS:LI24:790:EDES'; % Energy setpoint from LEM server
BC2_nominal_energy_n = n;
n = n + 1;
%pvs{n,1} = 'SIOC:SYS0:ML00:AO287'; % Energy based on magnet setting
pvs{n,1} = 'REFS:DMP1:400:EDES'; % Energy setpoint from LEM server
PR55_nominal_energy_n = n;
n = n + 1;
%pvs{n,1} = 'SIOC:SYS0:ML00:AO288'; % Energy based on magnet setting
pvs{n,1} = 'REFS:DMP1:400:EDES'; % Energy setpoint from LEM server
LTU_nominal_energy_n = n;
n = n + 1;
pvs{n,1} = PDES{2}; % Phase of L3

L3_phase_n = n;
n = n + 1;
pvs{n,1} = setup_pv(289, 'L3 energy dither', 'MeV', 3, 'energy_feedback_new');
L3_energy_dither_n = n;

n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO285'; % L3 actuator strength
L3_actuator_strength_n = n;


% Now feedback control pvs
xn = 290-1; % Initial pv is 290
n = n + 1;
pvs{n,1} = setup_pv(xn+1, 'DL1 Feedback', 'on/off', 0, '1 to enable');
DL1_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+2, 'BXS Feedback', 'on/off', 0, 'NOT IMPLEMENTED');
BXS_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+3, 'BC1 energy Feedback', 'on/off', 0, '1 to enable');
BC1_energy_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+4, 'BC1 current Feedback', 'on/off', 0, '1 to enable');
BC1_current_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+5, 'BC2 energy Feedback', 'on/off', 0, '1 to enable');
BC2_energy_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+6, 'BC2 current Feedback', 'on/off', 0, '1 to enable');
BC2_current_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+7, 'BSY/LTU energy feedback', 'on/off', 0, '1 to enable');
final_energy_enable_n = n;
n = n + 1;
pvs{n,1} = setup_pv(xn+10, 'Enable hard limits', '.', 0, 'energy_feedback_new'); % limit output based on lem and expected beam energy
hard_limit_n = n;
n = n + 1;
pvs{n,1} = setup_pv(267, 'L2 chirp voltage', 'MeV', 0, 'energy_feedback_new'); % L2 chirp control
chirp_voltage_n = n;
n = n + 1;
pvs{n,1} = setup_pv(690, 'L2 phase-min', 'deg', 1, 'energy_feedback_new'); % L2 chirp control
L2_phase_min_n = n;
n = n + 1;
pvs{n,1} = setup_pv(691, 'L2 phase-max', 'deg', 1, 'energy_feedback_new'); % L2 chirp control
L2_phase_max_n = n;
n = n + 1;
pvs{n,1} = setup_pv(692, 'L2 phase-min - overcompressed', 'deg', 1, 'energy_feedback_new'); % L2 chirp control
L2_phase_min_OC_n = n;
n = n + 1;
pvs{n,1} = setup_pv(693, 'L2 phase-max - overcompressed', 'deg', 1, 'energy_feedback_new'); % L2 chirp control
L2_phase_max_OC_n = n;
n = n + 1;
pvs{n,1} = setup_pv(694, 'L2 TD11 substitute enable', '0,1', 1, 'energy_feedback_new'); % use l2 phase reverse as stopper
L2_TD11_substitute_n =  n;

n = n + 1;
pvs{n,1} = setup_pv(300, 'Minimum xmission for FB', 'ratio', 2, 'energy_feedback_new'); % use l2 phase reverse as stopper
min_transmission_n =  n;

n = n + 1;
pvs{n,1} = 'ACCL:LI22:1:ABSTR_ACTIVATE'; % L23 abstraction layer on/off
L23_abstraction_enable_n =  n;

n = n + 1;
pvs{n,1} = setup_pv(198, '6x6 enable', 'on/off', 0, 'energy_feedback_new');
global_fb_compute_n = n;



lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.
pv_run = cell(8,1);  % Will hold output PVs
ctrl_run = zeros(8,1); % will hold output output data.

% PVs for the program outputs.
pvout = cell(10,1);
pvout{1,1} = pvs{L2_phase_control_n,1};
pvout{2,1} = pvs{L2_amplitude_control_n,1};
pvout{3,1} = pvs{L0B_voltage_n,1};
pvout{4,1} = pvs{L1S_amplitude_n,1};
pvout{5,1} = pvs{L1S_phase_n,1};
pvout{6,1} = pvs{L3_amplitude_n};
pvout{7,1} = setup_pv(xn+8, 'L2_FB_percent', '.', 3, '-1 to 1'); %L2 soft limit range
pvout{8,1} = setup_pv(xn+9, 'L3_FB_percent', '.', 3, '-1 to 1'); % L3 soft limit range
pvout{9,1} = pvs{chirp_voltage_n,1}; % This pv used for input and output
pvout{10,1} = setup_pv(625, 'X-ray energy', 'eV', 1, 'energy_feedback_new');

% PVs for showing time slot difference

pvdiff = cell(6, 1);
pvdiff{1} = setup_pv(331, 'TS diff DL1 energy', 'MeV', 4, 'energy_feedback_new');
pvdiff{2} = setup_pv(332, 'TS diff BC1 energy', 'MeV', 4, 'energy_feedback_new');
pvdiff{3} = setup_pv(333, 'TS diff BC1 pk current', 'A', 1, 'energy_feedback_new');
pvdiff{4} = setup_pv(334, 'TS diff BC2 energy', 'MeV', 4, 'energy_feedback_new');
pvdiff{5} = setup_pv(335, 'TS diff BC2 pk current', 'A', 1, 'energy_feedback_new');
pvdiff{6} = setup_pv(336, 'TS diff DL2 energy', 'MeV', 4, 'energy_feedback_new');
diffs = zeros(6, 1);

try
  dataoutold = lcaGetSmart(pvout, 1, 'double');
  data = lcaGetSmart(pvs, 1, 'double');
catch
  messagedisp('Could not read initial PVs, exiting');
  exit;
end
%Can't do because lcaGet can return NaN on PVs with alarm status.
%{
if any(isnan([dataoutold;data]))
  messagedisp('Could not read initial PVs, exiting');
  exit;
end
%}
dataout = dataoutold;
dataold = data;
pause(1);

% Set up various program linits
%max_tmit_error = .15; % maximum 20% error
max_tmit_error = 1-data(min_transmission_n); % set allowed error
min_tmit_base = 2e7; % don't feedback below this (16pC, ok for 20pC
                     % operation) CHANGE CHANGE
max_tmit_base = 9e9; % 1.4nC OK for 1nC operation)
min_BC1_current = 50; % Amps
max_BC1_current = 500; % Amps
min_BC2_current = 200; % Amps
max_BC2_current = 1000000; % Amps was 15000 % 

wake_loss_scale = .5; %  percent of wake loss near dl2 second bend

DL1_scale = -135/263; % MeV/mm
BC1_scale = -250/231; % MeV/mm
BC2_scale = -data(BC2_nominal_energy_n)/362;
BC1_current_scale = 3;
BC2_current_scale = 20;
final_energy_scale = -data(PR55_nominal_energy_n)/120-.00001; % offset by .001 to prevend div0
DL2_energy_scale = data(LTU_nominal_energy_n)/120.7+.00001;
DL2_Y_energy_scale = -data(LTU_nominal_energy_n)/18.74+.00001;

injector_energy = 250;
dump_energy_scale = data(LTU_nominal_energy_n)/708 + .00001;

%Control parameters  for feedabck
max_energy_error = .05; % 4% energy error allowed.
%L2_nominal_fudge = .97; % for now just enter, don't want read live
L2_nominal_fudge = 1;
%LTU_nominal_fudge = 0.96;
LTU_nominal_fudge = 1;

PR55_nominal_fudge = 1.0;
LTU_magnet_scale = 1;
PR55_magnet_scale = 1.04;
BC2_max_energy_change = 20; % Maximum MeV per cycle
BSY_max_energy_change = 40;  % Maximum MeV per cycle
gain_scale = .5; % kludge to keep gain from being set too high by phase scan
use_saved = 1; % Use the internally saved actuator values, don't re-read
PR55_step_multiplier = 1.25; % multplies energy step
LTU_step_multiplier = .95; % multiples energy step


undulator_nominal_k = 3.50;
xray_energy_scale = 8333/(13720^2);

% now set up "previous" values of actuators (do not rely on reading back
% from lca
previous_L0B_voltage = data(L0B_voltage_n);
previous_BC1_energy = data(L1S_amplitude_n) * cosd(data(L1S_phase_n));
previous_BC1_compression = data(L1S_amplitude_n) * sind(data(L1S_phase_n));
previous_BC2_energy = data(L2_amplitude_control_n) * cosd(data(L2_phase_control_n));
previous_BC2_compression = data(L2_amplitude_control_n) * sind(data(L2_phase_control_n));
previous_L3_energy = data(L3_amplitude_n);
fel_beam_energy = data(LTU_nominal_energy_n);
lcaSetMonitor(pvs); %So we only need to read on change
out_lim = zeros(6,2); % holds 'soft' output limits

BC2_original_enable = 0;
BC2_original_current_enable = 0;
TD11_stopped = 0; % not stopped at TD11
L2_TD11_recover_phase = -36;  % just for now

n = 0;  % count between active writes
m = 0; % count for 1000 cycles
speedcount = zeros(6,1);
tic;
while 1
  m = m + 1;
  if m == 100
    tm = toc;
    messagedisp([num2str(n), ' writes in ', num2str(m), ' loops, time is ', num2str(tm)]);
    disp(speedcount');
    n = 0;
    m = 0;
    tic;
    speedcount = zeros(6,1);
  end
  max_tmit_error = 1-data(min_transmission_n); % set allowed error
  %over_compress_L2_lim(1,1) = -45;
  %over_compress_L2_lim(1,2) = -31.5; % was -38 KLUDGE KLUDGE KLUDGE
  %out_lim(1,1) = -38.5; % L2 minimum phase
  %out_lim(1,2) = -30; % L2 maximum phase
  out_lim(2,1) = data(L2_nofb_amplitude_n) -600; %min L2 energy
  out_lim(2,2) = data(L2_nofb_amplitude_n) + 600; % max L2 energy
  out_lim(3,1) = 65; % L0B minimum amplitude
  out_lim(3,2) = 75; % L0B maximum amplitude
  out_lim(4,1) = 100; % L1S minimum amplitude % WAS 139, L1S unsleded
  out_lim(4,2) = 148; % L1S maximum amplitude % WAS 146, kludge
  out_lim(5,1) = -35; % L1S minimum phase was -23
  out_lim(5,2) = -17; % L1S Maximum phase
  %Minimum and maximum energy for L3
  out_lim(6,1) = data(L3_nofb_amplitude_n) - (data(S29_nofb_amplitude_n) + data(S30_nofb_amplitude_n)) ; % min output
  out_lim(6,2) = data(L3_nofb_amplitude_n) + (data(S29_nofb_amplitude_n) + data(S30_nofb_amplitude_n)); % max output
  
  soft_lim = out_lim; % just initialize for now
  % Limit TMIT to 1/4 to 1.5x "beam charge" pv
  min_tmit = max(min_tmit_base, 1e-9 *data(beam_charge_n) / 1.602e-19 / 2);
  max_tmit = min(max_tmit_base, 1e-9 * data(beam_charge_n) / 1.602e-19 * 1.5);

  
  over_compress_L2_lim(1,1) = data(L2_phase_min_OC_n);
  over_compress_L2_lim(1,2) = data(L2_phase_max_OC_n); % was -38 KLUDGE KLUDGE KLUDGE
  out_lim(1,1) = data(L2_phase_min_n); % L2 minimum phase
  out_lim(1,2) = data(L2_phase_max_n); % L2 maximum phase
  out_lim_hard = out_lim; % hard actuator limits
  
  
  final_energy_scale = -data(PR55_nominal_energy_n)/120-.00001; % offset by .001 to prevend div0
  DL2_energy_scale = data(LTU_nominal_energy_n)/120.7+.00001;
  dump_energy_scale = data(LTU_nominal_energy_n)/708 + .00001;
  
  % calculate on-energy for L2 and L3 actuators.
  L2_energy_nominal = (data(BC2_nominal_energy_n) - injector_energy)/cosd(data(L2_phase_control_n)) / L2_nominal_fudge;
  %L3_en = max(data(PR55_nominal_energy_n) / PR55_nominal_fudge, data(LTU_nominal_energy_n) / LTU_nominal_fudge);
  L3_en = max(data(PR55_nominal_energy_n) * PR55_magnet_scale, data(LTU_nominal_energy_n) * LTU_magnet_scale);
  if data(PR55_nominal_energy_n) > data(LTU_nominal_energy_n)
    fudge = PR55_nominal_fudge;
  else
    fudge = LTU_nominal_fudge;
  end
  L3_amplitude_nominal = (L3_en - data(BC2_nominal_energy_n))/cosd(data(L3_phase_n))/ fudge;


  if isfinite(data(LTU_2_x_n) + data(DMP_y_n))
    fel_beam_energy = data(LTU_nominal_energy_n) - (data(LTU_2_x_n) * DL2_energy_scale) * wake_loss_scale + ...
      (data(DMP_y_n) * dump_energy_scale) * (1-wake_loss_scale);
  else
    fel_beam_energy = data(LTU_nominal_energy_n);
  end

  x_ray_energy = xray_energy_scale * fel_beam_energy^2 * (1+undulator_nominal_k^2)/(1+data(undulator_k_n)^2);

    if data(hard_limit_n) == 0 % don't use hard limits.
      for nx = 1:6
        out_lim(nx,1) = -Inf;
        out_lim(nx,2) = Inf;
      end
    else
      out_lim = out_lim_hard;
    end
  W = watchdog_run(W); % run watchdogcounter
  if get_watchdog_error(W) % some error
    messagedisp('Some sort of watchdog timer error'); % Just drop for now
    pause(1);
    continue;
  end
  if data(busy_num) == 0 && dataold(busy_num) == 1 % just finished a phase scan
    disp_log('pausing after previous phase scan');
    pause(2);
  end
  
  if data(L2_TD11_substitute_n) == 1   % NEW test code
    data(BC2_energy_enable_n) = 1;
  end

  
  if data(fancy_phase_control_n) == 1 && ...
          data(L23_abstraction_enable_n) == 1 %only do this if control is enabled in phase_control
    dataout(7) = 2*(dataout(2) - soft_lim(2,1)) / (soft_lim(2,2) - soft_lim(2,1)) -1; %output relative to soft limits
    dataout(8) = 2*(dataout(6) - soft_lim(6,1)) / (soft_lim(6,2) - soft_lim(6,1)) -1;
    try
      if data(overall_gain_n) > 0 % if gain <= 0, let go of actuators. if phase scans running, all changes diasbled
        run_n = 0;
        if data(global_fb_compute_n) % enables all feedback selections
        if data(DL1_enable_n) % DL1 control enabled
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{3,1}; % L0B voltage
          ctrl_run(run_n,1) = dataout(3,1); % Control for voltage
          speedcount(1) = speedcount(1) +1;
        end
        if data(BXS_enable_n)
          % Do nothing for now
        end
        if data(BC1_energy_enable_n) || data(BC1_current_enable_n) % enable both controls if either is OK
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{4,1};  % L1S voltage
          ctrl_run(run_n,1) = dataout(4,1);
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{5,1};  % L1S Phase
          ctrl_run(run_n,1) = dataout(5,1);
          speedcount(2) = speedcount(2) +1;
        end
        if data(BC2_energy_enable_n) || data(BC2_current_enable_n)
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{1,1};
          ctrl_run(run_n,1) = dataout(1,1); % Phase for L2
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{2,1};
          ctrl_run(run_n,1) = dataout(2,1); % amplitude for L2
          speedcount(3) = speedcount(3) +1;
        end
        if data(final_energy_enable_n)
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{6,1};  % Amplitude for L3
          ctrl_run(run_n,1) = dataout(6,1);
          speedcount(4) = speedcount(4) +1;
        end
        end
        if ~(BC2_original_enable && ~BC2_original_current_enable)  %
          %do not do if energy fb on, AND external chirp contro
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{9,1};
          ctrl_run(run_n,1) = dataout(9,1);
        end
        if run_n && ~data(busy_num)
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{7,1};
          ctrl_run(run_n,1) = dataout(7,1);  % L2 soft limit
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{8,1};
          ctrl_run(run_n,1) = dataout(8,1);  % L3 soft limit
          %if (data(BC2_current_enable_n) && data(BC2_energy_enable))  % update chirp value
          run_n = run_n + 1;
          pv_run{run_n,1} = pvout{10,1};
          ctrl_run(run_n,1) = x_ray_energy;
          num_outputs = run_n;
          if sum(isnan(ctrl_run(1:num_outputs)))
            messagedisp('Error, tried to write NAN to pv');
          else
            lcaPut(pv_run(1:num_outputs), ctrl_run(1:num_outputs));
            n = n + 1;
          end
        else
        end
      end
    catch
      messagedisp('lcaPut error');
      pause(1);
    end
  else                    % else of fancy phase control block
    messagedisp('Fancy phase control not active ');
    pause(1);
  end                     % end of fancy phase control block
  
  try
      lcaPutSmart(pvdiff, diffs);
  catch
      messagedisp('Error writing to Matlab PVs');
  end
  
  pause(delay)  % This sets loop speed
  if data(phase_scan_running_n) == 1 % we did phase scans last time
    messagedisp('phase scans runnning');
    pause(5);
  end
  good = 1;
  try
    flags = lcaNewMonitorValue(pvs);    
    if sum(flags)        %   sum(flags) > 0    % Have new data
      dataold = data;
      speedcount(5) = speedcount(5) + 1;
      [data, timestamps] = lcaGetSmart(pvs, 1, 'double'); % get new data
%{
      if any(isnan(data))
        good = 0; % Some PVs not connected
        messagedisp('Some PVs not connected');
      end
%}
    else
      messagedisp('No new data, waiting');
      good = 0; % no new good data
    end
  catch
    good = 0; % Something went wrong with lcaGet
    messagedisp('error on lcaNewMonitorValue or lcaGet');
  end
  if data(phase_scan_running_n) == 1
    messagedisp('Phase Scans running, Wait')
    good = 0;
  end
  if data(busy_num) == 1
    messagedisp('phase control busy, continue');
  end
  if ~good   % Could not  get data, wait a second, try again.
    data(DL1_enable_n:final_energy_enable_n) = 0; % disable all control
    continue
  end
  % Original values to use based on values from lcaGet
  dataout(1) = data(L2_phase_control_n);
  dataout(2) = data(L2_amplitude_control_n);
  dataout(3) = data(L0B_voltage_n);
  dataout(4) = data(L1S_amplitude_n);
  dataout(5) = data(L1S_phase_n);
  dataout(6) = data(L3_amplitude_n);
  % Check tmit from gun.
  %update this even if no beam.
  
  
  
  
dataout(9) = data(L2_amplitude_control_n) * sind(data(L2_phase_control_n));
   

  
  if data(L2_TD11_substitute_n) == 1
    if ~TD11_stopped % not stopped last time
      L2_TD11_recover_phase = data(L2_phase_control_n);
      TD11_stopped = 1; 
    end
    dataout(1) = -178; % Reverse phase of L2 
    data(BC2_energy_enable_n) = 1; % force on to allow write
 %   continue;  %%%%%%%%%%%%%%%%%%%%%%%%% CHECK
  else %not stopped
    if TD11_stopped  %recovering phase
      dataout(1) = L2_TD11_recover_phase;
      data(L2_phase_control_n) = L2_TD11_recover_phase;
      data(BC2_energy_enable_n) = 1; % force on for now
    end
    
  end
  
  
  if ~check_variable(data(gun_tmit_n), dataold(gun_tmit_n), min_tmit, max_tmit)
    data(DL1_enable_n:final_energy_enable_n) = 0; % disable all control
    pause(.5); % beam off
    messagedisp('beam off');
    continue
  end
   speedcount(6) = speedcount(6) + 1;
  % DL1 feedback section
  if ~check_variable(data(DL1_tmit_n), dataold(DL1_tmit_n), min_tmit, max_tmit) % check tmit
    data(DL1_enable_n:final_energy_enable_n) = 0; % Disable DL1 feedback
    messagedisp('no beam on DL1');
    continue
  end
 
  if abs((data(DL1_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error  % check loss
    messagedisp('beam loss to DL1');
    data(DL1_enable_n:final_energy_enable_n) = 0; % Disable DL1 feedback
    continue
  end
  if ~check_variable(data(DL1_x_n), dataold(DL1_x_n), -5, 5);
    data(DL1_enable_n:final_energy_enable_n) = 0; % Disable DL1 feedback
    continue
  end
  DL1_energy_change = -data(DL1_x_n) * DL1_scale * gain_scale * data(overall_gain_n); % in mev
  if ~(use_saved && data(DL1_enable_n) == 1)
    previous_L0B_voltage = data(L0B_voltage_n); % read new voltage, ignore old
  end
  dataout(3) = limitmove(previous_L0B_voltage, DL1_energy_change, out_lim(3,:)); % limits output move
  previous_L0B_voltage = dataout(3);

  % if TS1 data is less than one second older than TS4 data,
  if (lca2matlabTime(timestamps(DL1_x_n)) - lca2matlabTime(timestamps(DL1_x_n_1))) < datenum(0, 0, 0, 0, 0, 1)
      % update the time slot difference PVs
      diffs(1) = (data(DL1_x_n) - data(DL1_x_n_1)) * DL1_scale;
  end
  
  % DL1 feedback section end
  
  % Start BC1 energy feedback
  BC1_original_enable = data(BC1_energy_enable_n);
  if ~check_variable(data(BC1_tmit_n), dataold(BC1_tmit_n), min_tmit, max_tmit)
    data(BC1_energy_enable_n:final_energy_enable_n) = 0;
    messagedisp('no beam at BC1');
    continue
  end
  if abs((data(BC1_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error
    data(BC1_energy_enable_n : final_energy_enable_n) = 0;
    messagedisp('beam loss to BC1');
    continue
  end
  if ~check_variable(data(BC1_x_n), dataold(BC1_x_n), -12, 12);
    data(BC1_energy_enable_n : final_energy_enable_n) = 0;
    continue
  end
  BC1_energy_change = -data(BC1_x_n) * BC1_scale * gain_scale * data(overall_gain_n); % in MeV
  
  % if TS1 data is less than one second older than TS4 data,
  if (lca2matlabTime(timestamps(BC1_x_n)) - lca2matlabTime(timestamps(BC1_x_n_1))) < datenum(0, 0, 0, 0, 0, 1)
      % update the time slot difference PVs
      diffs(2) = (data(BC1_x_n) - data(BC1_x_n_1)) * BC1_scale;
  end
  
  
  % end BC1 energy feedback

  % Start BC1 current feedback
  if ~check_variable(data(BC1_peak_current_n), dataold(BC1_peak_current_n), min_BC1_current, max_BC1_current)...
      || ~data(BC1_current_enable_n);
    BC1_compression_change = 0;
    data(BC1_current_enable_n) = 0;
  else
    BC1_compression_change = (data(BC1_peak_current_n)-data(BC1_current_setpoint_n)) / data(BC1_current_setpoint_n)...
      * BC1_current_scale * data(overall_gain_n) * data(current_gain_num) * gain_scale;
    if BC1_compression_change > BC1_current_scale
      BC1_compression_change = BC1_current_scale;  % limit slew rate for current
    elseif BC1_compression_change < -BC1_current_scale
      BC1_compression_change = - BC1_current_scale;
    end
  end
  
    % if TS1 data is less than one second older than TS4 data,
  if (lca2matlabTime(timestamps(BC1_peak_current_n)) - ...
          lca2matlabTime(timestamps(BC1_peak_current_n_1))) < datenum(0, 0, 0, 0, 0, 1)
      % update the time slot difference PVs
      diffs(3) = (data(BC1_peak_current_n) - data(BC1_peak_current_n_1));
  end
  
  % End BC1 current calculation
  % Calculate changes to BC1 actuators.

  if ~(use_saved && BC1_original_enable)
    previous_BC1_energy = data(L1S_amplitude_n) * cosd(data(L1S_phase_n));
    previous_BC1_compression =  data(L1S_amplitude_n) * sind(data(L1S_phase_n));
  end

  %Now limit (complicated due to phase and amplitude)
  old_BC1_amplitude = sqrt(previous_BC1_energy^2 + previous_BC1_compression^2);
  old_BC1_phase = 180/pi*atan2(previous_BC1_compression, previous_BC1_energy);
  %temporarially calculate new values
  new_BC1_energy = previous_BC1_energy + BC1_energy_change;
  new_BC1_compression = previous_BC1_compression + BC1_compression_change;
  temp_BC1_amplitude = sqrt(new_BC1_energy^2 + new_BC1_compression^2);
  temp_BC1_phase = 180/pi*atan2(new_BC1_compression, new_BC1_energy);
  %calculate changes
  delta_BC1_amplitude = temp_BC1_amplitude - old_BC1_amplitude;
  delta_BC1_phase = temp_BC1_phase - old_BC1_phase;
  % limit changes
  new_BC1_amplitude = limitmove(old_BC1_amplitude, delta_BC1_amplitude, out_lim(4,:));
  new_BC1_phase = limitmove(old_BC1_phase, delta_BC1_phase, out_lim(5,:));
  % set up last values
  previous_BC1_energy = new_BC1_amplitude * cosd(new_BC1_phase);

  if data(BC1_current_enable_n) == 1% only if enabled
    previous_BC1_compression = new_BC1_amplitude *sind(new_BC1_phase);
    dataout(5) = new_BC1_phase;
  end
  dataout(4) = new_BC1_amplitude;
%  dataout(5) = new_BC1_phase;    % nate 11-17-10 move this so it only
%  touches phase if the peak current term is enabled
  % end of BC1 feedback

  % Start BC2 feedback
  % Check for bad data
  
  
  if data(L2_TD11_substitute_n) == 1
    dataout(1) = -178; % Reverse phase of L2 
    messagedisp('Backphased L2');
    continue;
  else
    if TD11_stopped % need to recover
      TD11_stopped = 0;
      continue
    end
  end
  
  if TD11_stopped
    continue; % Dont do BC2 stuff
  end
  
  BC2_original_enable = data(BC2_energy_enable_n);
  if ~check_variable(data(BC2_tmit_n), dataold(BC2_tmit_n), min_tmit, max_tmit)
    data(BC2_energy_enable_n: final_energy_enable_n) = 0;
    messagedisp('no beam at BC2');
    continue
  end
  if abs((data(BC2_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error
    data(BC2_energy_enable_n : final_energy_enable_n) = 0;
    messagedisp('beam loss to BC2');    
    continue
  end
  if ~check_variable(data(BC2_x_n), dataold(BC2_x_n), -15, 15)
    data(BC2_energy_enable_n : final_energy_enable_n) = 0;
    continue
  end

  %  start of BC2 feedback
  
  if data(BC2_current_setpoint_n) < 0 % overcompressed
    out_lim(1,:) = over_compress_L2_lim(1,:);
  end
  
  BC2_original_current_enable  = data(BC2_current_enable_n);
  BC2_energy_change = -data(BC2_x_n) * BC2_scale * gain_scale * data(overall_gain_n); % in MeV
  if abs(BC2_energy_change) > BC2_max_energy_change   % limit slew rate
    BC2_energy_change = BC2_max_energy_change * sign(BC2_energy_change);
  end

  % if TS1 data is less than one second older than TS4 data,
  if (lca2matlabTime(timestamps(BC2_x_n)) - lca2matlabTime(timestamps(BC2_x_n_1))) < datenum(0, 0, 0, 0, 0, 1)
      % update the time slot difference PVs
      diffs(4) = (data(BC2_x_n) - data(BC2_x_n_1)) * BC2_scale;
  end

  if ~check_variable(data(BC2_peak_current_n), dataold(BC2_peak_current_n), min_BC2_current,...
      max_BC2_current) || ~data(BC2_current_enable_n)
    BC2_compression_change = 0;
    data(BC2_current_enable_n) = 0;
  else
  %  BC2_compression_change = (data(BC2_peak_current_n) - abs(data(BC2_current_setpoint_n))) / data(BC2_current_setpoint_n)...
  %    * BC2_current_scale * data(overall_gain_n) * data(current_gain_num) * gain_scale;
     
     BC2_compression_change = sign(data(BC2_current_setpoint_n))* (data(BC2_peak_current_n) - abs(data(BC2_current_setpoint_n))) / data(BC2_peak_current_n)...
      * BC2_current_scale * data(overall_gain_n) * data(current_gain_num) * gain_scale;
    if BC2_compression_change > BC2_current_scale/2
      BC2_compression_change = BC2_current_scale/2;
    elseif BC2_compression_change < -BC2_current_scale/2
      BC2_compression_change = - BC2_current_scale/2;
    end
  end
  
  % if TS1 data is less than one second older than TS4 data,
  if (lca2matlabTime(timestamps(BC2_peak_current_n)) - ...
          lca2matlabTime(timestamps(BC2_peak_current_n_1))) < datenum(0, 0, 0, 0, 0, 1)
      % update the time slot difference PVs
      diffs(5) = (data(BC2_peak_current_n) - data(BC2_peak_current_n_1));
  end
  
  if ~(use_saved && BC2_original_enable)
    previous_BC2_energy = data(L2_amplitude_control_n) * cosd(data(L2_phase_control_n));
    previous_BC2_compression = data(L2_amplitude_control_n) * sind(data(L2_phase_control_n));
  end

  %Now limit (complicated due to phase and amplitude)
  old_BC2_amplitude = sqrt(previous_BC2_energy^2 + previous_BC2_compression^2);
  old_BC2_phase = 180/pi*atan2(previous_BC2_compression, previous_BC2_energy);
  new_BC2_energy = previous_BC2_energy + BC2_energy_change;
  new_BC2_compression = previous_BC2_compression + BC2_compression_change;
  % disp(BC2_compression_change);
  
  
  
  if data(BC2_current_enable_n) == 0 % not enabled, but if we got here BPM is OK
    new_BC2_compression = data(chirp_voltage_n);  % use manual control
    previous_BC2_compression = new_BC2_compression;
  end
  

  
  temp_BC2_amplitude = sqrt(new_BC2_energy^2 + new_BC2_compression^2);
  temp_BC2_phase = 180/pi*atan2(new_BC2_compression, new_BC2_energy);
  %calculate changes
  delta_BC2_amplitude = temp_BC2_amplitude - old_BC2_amplitude;
  delta_BC2_phase = temp_BC2_phase - old_BC2_phase;
  % limit changes
  new_BC2_amplitude = limitmove(old_BC2_amplitude, delta_BC2_amplitude, out_lim(2,:));
  if data(BC2_current_enable_n) == 1
    new_BC2_phase = limitmove(old_BC2_phase, delta_BC2_phase, out_lim(1,:)); % limit in feedback 
  else
    new_BC2_phase = old_BC2_phase + delta_BC2_phase;
  end
  % set up last values
  previous_BC2_energy = new_BC2_amplitude * cosd(new_BC2_phase);
%  if data(BC2_current_enable_n) % only if enabled
    previous_BC2_compression = new_BC2_amplitude * sind(new_BC2_phase);
    dataout(9) = previous_BC2_compression;  % write to the compression control pv
%  end
  dataout(2) = new_BC2_amplitude;
  dataout(1) = new_BC2_phase;
  % end BC2 feedback

  % Start DL2 feedback
  % Look at fast dither input
 
  DL2_0_valid = check_variable(data(LTU_0_tmit_n), dataold(LTU_0_tmit_n), min_tmit, max_tmit) && ...
    check_variable(data(LTU_0_x_n), dataold(LTU_0_x_n), -5, 5);
  
  DL2_1_valid = check_variable(data(LTU_1_tmit_n), dataold(LTU_1_tmit_n), min_tmit, max_tmit) && ...
    check_variable(data(LTU_1_x_n), dataold(LTU_1_x_n), -5, 5);

  DL2_2_valid = check_variable(data(LTU_2_tmit_n), dataold(LTU_2_tmit_n), min_tmit, max_tmit) && ...
    check_variable(data(LTU_2_x_n), dataold(LTU_2_x_n), -5, 5);

  BSY_valid = check_variable(data(BSY_tmit_n), dataold(BSY_tmit_n), min_tmit, max_tmit) && ...
    check_variable(data(BSY_x_n), dataold(BSY_x_n), -5, 5);

  % New checks for beam loss, or gain (spray)
  if abs((data(LTU_0_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error
    data(DL2_0_valid) = 0;
  end
  
  if abs((data(LTU_1_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error
    data(DL2_1_valid) = 0;
  end

  if abs((data(LTU_2_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error
    data(DL2_2_valid) = 0;
  end

  if abs((data(BSY_tmit_n) - data(gun_tmit_n)) / data(gun_tmit_n)) > max_tmit_error
    data(BSY_valid) = 0;
  end


  % if TS1 data is less than one second older than TS4 data,
  if (lca2matlabTime(timestamps(LTU_1_x_n)) - lca2matlabTime(timestamps(LTU_1_x_n_1))) < datenum(0, 0, 0, 0, 0, 1)
      % update the time slot difference PVs
      diffs(6) = (data(LTU_1_x_n) - data(LTU_1_x_n_1)) * DL2_energy_scale;
  end

  
  bsy_original_enable = data(final_energy_enable_n);
  if DL2_1_valid && DL2_2_valid  % Use both BPMs
    final_energy_error = (data(LTU_1_x_n) - data(LTU_2_x_n)) * DL2_energy_scale /2;
  elseif DL2_1_valid
    final_energy_error = data(LTU_1_x_n) * DL2_energy_scale;
  elseif DL2_0_valid
      final_energy_error = data(LTU_0_x_n) * DL2_Y_energy_scale;
  elseif BSY_valid
    final_energy_error = data(BSY_x_n) * final_energy_scale; % in mev
  else
    data(final_energy_enable_n) = 0; % no valid BSY energy feedback
    messagedisp('No beam or beam loss in DL2');
    continue
  end

  final_energy_error = final_energy_error - data(L3_energy_dither_n);
  
  final_energy_change = -final_energy_error * data(overall_gain_n) * gain_scale;
  if abs(final_energy_change) > BSY_max_energy_change
    final_energy_change = BSY_max_energy_change * sign(final_energy_change);
  end

  if ~(use_saved && bsy_original_enable)
    previous_L3_energy = data(L3_amplitude_n);
  end
  if BSY_valid
    step_multiplier = PR55_step_multiplier;
  else
    step_multiplier = LTU_step_multiplier;
  end
  % check for actuator at limit
  if data(L3_actuator_strength_n) > .99
    final_energy_change = min(final_energy_change, 0);
  elseif data(L3_actuator_strength_n) < -.99
    final_energy_change = max(final_energy_change, 0);
  end
  
  dataout(6) = limitmove(previous_L3_energy, final_energy_change, out_lim(6,:))...
    + (data(L3_energy_dither_n) - dataold(L3_energy_dither_n)) * step_multiplier;
  previous_L3_energy  = dataout(6);
  %end of BSY feedback
end
end

function ok = check_variable(val, val_old, min, max)
if ~isfinite(val) || (val > max) || ( val < min) || (val == 0) || (val == val_old)
  ok = 0;
  return
end
if ~isfinite(val_old) || (val_old > max) || ( val_old < min) || (val_old == 0)
  ok = 0;
else
  ok = 1;
end
end

function out = limitmove(initial, change, lim)
if (~isfinite(change)) || (~isreal(change));
  out = initial;
elseif (initial + change) > lim(1,2)  % too large
  out = lim(1,2);
elseif (initial + change) < lim(1,1) % too small
  out = lim(1,1);
else
  out = initial + change;  % normal condition
end
end


% Just some useful functions.

function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
  numstr = ['00', numtxt];
elseif numlen == 2
  numstr = ['0', numtxt];
else
  numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML00:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end

function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end

function messagedisp(msg)

% initialize the timestamp of the last msg
persistent lastmsg;

if isempty(lastmsg)
    disp('init');
    lastmsg = '';
end

% write the msg out to the string PV
lcaPut('SIOC:SYS0:ML00:CA013', double(int8(msg)))

if ~strcmp(lastmsg, msg)
    disp_log(msg);
    lastmsg = msg;
end
end