%% These are the cameras you can use

available_profmon = {'CMOS:LI20:3490';...
    'CMOS:LI20:3491';...
    'CMOS:LI20:3492';...
    'PROF:LI20:10'; ...
    'PROF:LI20:12'; ...
    'PROF:LI20:B100'; ...
    'PROF:LI20:B101'; ...
    'PROF:LI20:B102'; ...
    'PROF:LI20:B103'; ...
    'PROF:LI20:B104';...
    'PROF:LI20:2432'; ...
    'PROF:LI20:3300'; ...
    'PROF:LI20:3301'; ...
    'PROF:LI20:3302'; ...
    'PROF:LI20:3303'; ...
    'PROF:LI20:3500'};

%% Test DAQ (single data acquisition)

clear par

par.cams = {'PROF:LI20:3300'; 'PROF:LI20:3301';};
par.save_E200=true;
par.save_back=true;
par.experiment = 'E200';
par.increment_save_num = 1;
par.n_shot = 20;
par.set_print2elog = 1;
par.comt_str = 'Test DAQ';

data = FACET_DAQ_2014(par);

%% Test Scan (multiple data acquisition for a scan param

clear par

par.cams = {'PROF:LI20:3300'; 'PROF:LI20:3301';};
par.save_E200=true;
par.save_back=true;
par.experiment = 'E200';
par.increment_save_num = 1;
par.n_shot = 20;
par.fcnHandle = @set_dummy;
par.Control_PV_start=0;
par.Control_PV_end=1;
par.n_step=2;
par.set_print2elog = 1;
par.comt_str = 'Test Scan';

data = FACET_DAQ_2014(par);