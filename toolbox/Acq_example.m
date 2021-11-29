%S. Corde and S. Gessner
%6/3/12

pause on;
clear all;



%%%%%%%%%%  SCAN PARAMETERS DEFINITION  %%%%%%%%%%

% Auto-increment of the file name number by using a PV
n_saves = lcaGet('SIOC:SYS1:ML02:AO001');
n_saves = n_saves + 1;
lcaPut('SIOC:SYS1:ML02:AO001',n_saves);

% Define the saved file name
save_name = 'MR_TCAV_test';

% Add a comment regarding this data acquisition
Comment = sprintf(['Scan over TCAV amplitude, range from 0 to 4000 by step of 500, 5 shots per step.\n'...
    'Recorded cameras are YAG, USTHz, USOTR and IPOTR.\n'...
    'Pyro peaked, large YAG shot to shot fluctuations.\n'...
    'File name is ' save_name num2str(n_saves) '.mat']);

% Select or add profile monitors to acquire
prof_list = cell(0,1);
prof_list{end+1,1} = 'YAGS:LI20:2432';  % YAG camera
prof_list{end+1,1} = 'OTRS:LI20:3070';  % Upstream THz
prof_list{end+1,1} = 'OTRS:LI20:3158';  % Upstream OTR
% prof_list{end+1,1} = 'OTRS:LI20:3180';  % IPOTR
% prof_list{end+1,1} = 'OTRS:LI20:3206';  % Downstream OTR
prof_list{end+1,1} = 'PROF:LI20:3483';  % Cher_Near
prof_list{end+1,1} = 'PROF:LI20:3485';  % Cher_Far
% prof_list{end+1,1} = 'EXPT:LI20:3208';  % Breakdown

% Select or add BSA and non BSA EPICS PVs to acquire
pv_list = cell(0,1);
pv_list{end+1,1} = 'PATT:SYS1:1:PULSEID';      % BSA PulseID PV
pv_list{end+1,1} = 'PATT:SYS1:1:PULSEIDBR';    % Non BSA PulseID PV
pv_list{end+1,1} = 'BLEN:LI20:3158:BRAW';      % BSA Pyro
pv_list{end+1,1} = 'SIOC:SYS1:ML00:AO007';     % Non BSA Pyro
pv_list{end+1,1} = 'SIOC:SYS1:ML00:AO028';     % Non BSA Pyro updating with spyro.m at 1 Hz
pv_list{end+1,1} = 'DR12:PHAS:61:VDES';        % 
pv_list{end+1,1} = 'DR12:PHAS:61:VACT';        % 
pv_list{end+1,1} = 'LI20:LGPS:3011:BDES';      % QFF 1
pv_list{end+1,1} = 'LI20:LGPS:3031:BDES';      % QFF 2
pv_list{end+1,1} = 'LI20:LGPS:3091:BDES';      % QFF 4
pv_list{end+1,1} = 'LI20:LGPS:3141:BDES';      % QFF 5
pv_list{end+1,1} = 'LI20:LGPS:3151:BDES';      % QFF 6
pv_list{end+1,1} = 'LI20:LGPS:3261:BDES';      % QS 1
pv_list{end+1,1} = 'LI20:LGPS:3311:BDES';      % QS 2
pv_list{end+1,1} = 'LI20:LGPS:3330:BDES';      % B5D36-PS Spectromter dipole magnet
pv_list{end+1,1} = 'TCAV:LI20:2400:Q_ADJUST';  % TCAV 0 degree amplitude
pv_list{end+1,1} = 'TCAV:LI20:2400:I_ADJUST';  % TCAV 90 degree amplitude
pv_list{end+1,1} = 'DR13:TORO:40:DATA';
pv_list{end+1,1} = 'LI20:TORO:2452:DATA';
pv_list{end+1,1} = 'LI20:TORO:3163:DATA';
pv_list{end+1,1} = 'LI20:TORO:3255:DATA';
pv_list{end+1,1} = 'SIOC:SYS1:ML00:AO074';
pv_list{end+1,1} = 'SIOC:SYS1:ML00:AO079';
pv_list{end+1,1} = 'SIOC:SYS1:ML00:AO079';

% Control PV over which the scan is performed
ctrl_pv = 'TCAV:LI20:2400:Q_ADJUST';
ctrl_pv_name = regexprep(ctrl_pv, ':', '_');
% Contro PV start value
pv_val_start = 0;
% Control PV end value
pv_val_end = 1000;
% Control PV step
pv_step = 500;
% Settle time between control PV setting and data acquisition
settle_time = 0.5;
% Number of shots per step
n_shot = 5;




%%%%%%%%%%  RUNNING SCAN  %%%%%%%%%%

% Record the current state of the facet machine
% state = facet_getMachine();
state = 0;

% Reading the initial value of the Control PV
pv_val_init = lcaGet(ctrl_pv);

step_number = 0;
for i=pv_val_start:pv_step:pv_val_end
    step_number = step_number+1;
    % Print to screen step number and the corresponding PV value
    fprintf(1, '\nStep # %d, Control PV %s = %d\n\n', step_number, ctrl_pv, i);
    % Set the control PV
    % lcaPut(ctrl_pv, i);
    % Wait for settle time
    pause(settle_time);
    % Acquire BSA and non BSA EPICS PVs and IMAGE
    % data = Acq_epics_pv_image(pv_list, prof_list, n_shot);
    final_data.(['Step_' num2str(step_number, '%.2d')]) = Acq_epics_pv_image(pv_list, prof_list, n_shot);
    % Add the control PV value to the data structure
    % [data.(char(ctrl_pv_name))] = deal(i);
    [final_data.(char(['Step_' num2str(step_number, '%.2d')])).Control_PV] = deal(i);
    % Concatenate data at the end of final data
%     if step_number==1 
%         final_data = data;
%     else
%         final_data = vertcat(final_data, data);
%     end
    % clear data;
end

% Set the Control PV back to initial value
% lcaPut(ctrl_pv, pv_val_init);


timestamp = clock;
year = num2str(timestamp(1), '%.4d');
month = num2str(timestamp(2), '%.2d');
day = num2str(timestamp(3), '%.2d');
hour = num2str(timestamp(4), '%.2d');
min = num2str(timestamp(5), '%.2d');
sec = num2str(floor(timestamp(6)), '%.2d');

% Test if the saving directory exists, if not make directory
if(~exist(['/u1/facet/matlab/data/' year '/' year '-' month '/' year '-' month '-' day], 'dir'))
    mkdir(['/u1/facet/matlab/data/' year '/' year '-' month '/' year '-' month '-' day]);
end
% Merge Comment into final_data
[final_data(:).Comment] = deal(Comment);
% Save both final data and the state of the facet machine
fprintf(1, '\nSaving data\n\n');
tic;
save(['/u1/facet/matlab/data/' year '/' year '-' month '/' year '-' month '-' day '/' save_name num2str(n_saves)],...
    'final_data', 'state');
fprintf(1, 'End of saving\nSaving time: %.4f s\n\n', toc);






% Next steps:
% Fix memomry issues
% Data not assigned when no beam, lead to crashing the program
% Align camera pid in data and be compatible with vertcat in the script
% Comment files
% Tracking ROI change and abort if needed
% Print display to file
% BSA SLC acquisition

% Ask to Henrik: how PVs are acquired, BSA or not?
% What's the sampling doing?
% Print-to-elog button print the full window with timestamp
% An option for saving-only, no scan
% An option for facet_getMachine() before starting a scan



