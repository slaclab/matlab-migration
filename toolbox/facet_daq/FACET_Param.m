function par = FACET_Param()

%%%%%%%%%% PARAMETER DEFINITION  %%%%%%%%%%

% Define main saving folder and save name prefix
par.experiment = 'E200';

% Profile Monitors
par.cams = {'PROF:LI20:2432';};

% Enable (1) or disable (0) E200_getMachine
par.save_E200 = true;
% Enable (1) or disable (0) E200_takeBackground for taking camera background
par.save_back = true;
% Enable (1) or disable (0) the print2elog
par.set_print2elog = 1;

% There is n_step*n_shots recorded
par.n_step = 1;                           
par.n_shot = 20;                              

% Add a print-to-elog comment regarding this data acquisition
par.comt_str = 'Default parameters for FACET DAQ 2014';

% Enable (1) or disable (0) the increment of the save number
par.increment_save_num = 1;