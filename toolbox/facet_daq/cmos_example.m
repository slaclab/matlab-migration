%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run E200 DAQ with CMOS %
%%%%%%%%%%%%%%%%%%%%%%%%%%

par = E200_Param();

par.save_facet = 0;
par.save_E200 = 1;
par.save_back = 1;
par.n_shot = 20;
par.cmos_n_shot = par.n_shot;
par.comt_str = 'CMOS DAQ testing';

par.cmos_file = 'data_step_01';

par.camera_config = 43; % sYAG, CNEAR + CMOS

[epics_data, aida_data, facet_state, E200_state, filenames, param, cam_back] = E200_DAQ_2013(par);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run E200 Gen Scan with CMOS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

par = E200_Param();

par.save_facet = 0;
par.save_E200 = 1;
par.save_back = 1;
par.n_shot = 20;
par.cmos_n_shot = par.n_shot;
par.comt_str = 'Energy calib';

par.camera_config = 47; % sYAG, CNEAR + CMOS

%E200_gen_scan(@set_dummy, 20.35, 20.35, 2, par);
%E200_gen_scan(@set_dummy, 0.35, 36.35, 5, par);
%E200_gen_scan(@set_QSBEND_energy, -12, +12, 7, par);

%E200_gen_scan(@set_B5D36_BDES, 16.35, 24.35, 9, par);

E200_gen_scan(@set_B5D36_BDES, 17.35, 23.35, 5, par);
