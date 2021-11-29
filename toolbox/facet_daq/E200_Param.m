function par = E200_Param()

%%%%%%%%%% PARAMETER DEFINITION  %%%%%%%%%%

% Define main saving folder and save name prefix
par.experiment = 'E200';

% Profile Monitors
par.camera_config = 1;
par.event_code = 213;

% Enable (1) or disable (0) facet_getMachine
par.save_facet = 1;
% Enable (1) or disable (0) E200_getMachine
par.save_E200 = 1;
% Enable (1) or disable (0) E200_takeBackground for taking camera background
par.save_back = 1;
% Enable (1) or disable (0) the print2elog
par.set_print2elog = 1;

% There is n_sample*n_shots recorded
% Don't set n_shot > 20 if enabling AIDA data acquisition
par.n_sample = 1;                           
par.n_shot = 20;                              

% Enable (1) or disable (0) AIDA data acquisition
par.aida_daq = 0;
par.bpmd = 'NDRFACET';

% Add a print-to-elog comment regarding this data acquisition
par.comt_str = 'Default parameters for E200 DAQ 2013';

% Enable (1) or disable (0) the increment of the save number
par.increment_save_num = 1;

% Enable (1) or disable (0) the wait for the image saving
% If 0, the function E200_DAQ_2013() will return before the image saving is
% terminated, and no filenames are outputed. Only for advanced users.
par.wait = 1;

par.flip_nas = 0;

% CMOS stuff . . .
par.run_cmos = 0;
par.cmos2nas = 1;
par.cmos_n_shot = par.n_shot;
par.cmos_tse_evnt = 203;
par.cmos_trig_evnt = 221;
par.cmos_tse_ctrl_num = 2;
par.cmos_trig_ctrl_num = 1;


end
