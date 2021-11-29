clear par

par.event_code = 233;
par.cams = {'PROF:LI20:B101'; ...
    'PROF:LI20:2432'; ...
    'PROF:LI20:3158'; ...
    'PROF:LI20:3202'; ...
    'EXPT:LI20:3301'; ...
    'EXPT:LI20:3303'; ...
    'EXPT:LI20:3304'; ...
    };
par.save_E200=true;
par.save_back=true;
par.experiment = 'E200';
par.increment_save_num = 1;
par.n_shot = 30;
par.fcnHandle = @set_axicon_vertical;
par.Control_PV_start=-0.4;
par.Control_PV_end=0.8;
par.n_step=6;
par.set_print2elog = 1;
par.comt_str = '2D Kinoform raster scan. Laser 1/2 Hz. External laser control at 0.1 Hz.';
par.event_code = 233;
par.fcnHandle2 = @set_axicon_horizontal;
par.Control_PV_start2=-1.4;
par.Control_PV_end2=-0.2;
par.n_step2=6;

data = FACET_DAQ_2014(par);