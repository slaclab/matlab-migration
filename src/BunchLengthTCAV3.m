% setup for Bunch Length Measurement for TCAV3
% Mike Zelazny - zelazny@stanford.edu

global gBunchLength;

gBunchLength.debug = 0;

if ~isfield(gBunchLength,'gui')
    gBunchLength.gui = 0;
end

gBunchLength.sector = 'LI24';
gBunchLength.fileName = 'Untitled.mat';
gBunchLength.cancel = 0;
gBunchLength.blen = [];
gBunchLength.blen.pv.format = sprintf('BLEN:%s:1:%s', gBunchLength.sector,'%s');

% "Mode" (i.e. PROD vs DEV)
try
    gBunchLength.mode = lcaGet('IOC:SYS0:AL00:MODE');
catch
    gBunchLength.mode{1} = 'Unknown';
end

gBunchLength.gui_ts.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'GUI_TS');

% Available screens
gBunchLength.screen = [];
gBunchLength.screen.a = {'OTRTCAV','OTR22','PR55'};

gBunchLength.screen.i = 1; % defaults to OTRTCAV
gBunchLength.screen.desc = gBunchLength.screen.a{gBunchLength.screen.i};

gBunchLength.screen.ts = cell(1);
gBunchLength.screen.value = cell(1);
gBunchLength.screen.movable = 1;

gBunchLength.screen.pv.format = {'OTRS:LI25:920:%s', ... % OTRTCAV
                                 'OTRS:LI25:342:%s', ... % OTR22
                                 'LOLA:LI30:555:%s' };   % PR55

gBunchLength.screen.pv.a = cell(0);
gBunchLength.screen.rb_pv.a = cell(0);
gBunchLength.screen.blen_phase_pv.a = cell(0);
gBunchLength.screen.blen_phase.desc_pv.a = cell(0);
gBunchLength.screen.blen_phase.egu_pv.a = cell(0);
gBunchLength.screen.blen_phase.std_pv.a = cell(0);
gBunchLength.screen.blen_phase.alg_pv.a = cell(0);
gBunchLength.screen.blen_phase.timestamp_pv.a = cell(0);
gBunchLength.screen.blen_phase.tcav_power_pv.a = cell(0);
gBunchLength.screen.maxImgs_pv.a = cell(0);
gBunchLength.screen.image.resolution_pv.a = cell(0);

for i = 1:size(gBunchLength.screen.pv.format,2)
    gBunchLength.screen.pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'PNEUMATIC'); % screen IN/OUT
    gBunchLength.screen.rb_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'POSITION'); % screen IN/OUT readback
    gBunchLength.screen.blen_phase_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'BLEN_P');
    gBunchLength.screen.blen_phase.desc_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'BLEN_P.DESC');
    gBunchLength.screen.blen_phase.egu_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'BLEN_P.EGU');
    gBunchLength.screen.blen_phase.std_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'BLEN_PSTD');
    gBunchLength.screen.blen_phase.alg_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'CALALG');
    gBunchLength.screen.blen_phase.timestamp_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'BLEN_PTS');
    gBunchLength.screen.blen_phase.tcav_power_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'BLEN_A');
    gBunchLength.screen.maxImgs_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'IMG_BUF_IDX.LOPR');
    gBunchLength.screen.image.resolution_pv.a{end+1} = sprintf(gBunchLength.screen.pv.format{i}, 'RESOLUTION');
end

gBunchLength.screen.pv.a{3} = 'NONE'; % NO screen IN/OUT for PR55

gBunchLength.screen.pv.name = {gBunchLength.screen.pv.a{gBunchLength.screen.i}};
gBunchLength.screen.pv.connected = 0;
gBunchLength.screen.pv.force = {1};

gBunchLength.screen.rb_ts = cell(1);
gBunchLength.screen.rb_value = cell(1);
gBunchLength.screen.rb_pv.name = {gBunchLength.screen.rb_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.rb_pv.connected = 0;
gBunchLength.screen.rb_pv.force = {1};

gBunchLength.screen.blen_phase.ts = cell(1);

gBunchLength.screen.blen_phase.value = cell(1);
gBunchLength.screen.blen_phase_pv.name = {gBunchLength.screen.blen_phase_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase_pv.connected = 0;
gBunchLength.screen.blen_phase_pv.force = {1};

try
    gBunchLength.screen.blen_phase.value{1} = lcaGet(gBunchLength.screen.blen_phase_pv.name);
catch
end
    
gBunchLength.screen.blen_phase.desc = cell(1);
gBunchLength.screen.blen_phase.desc_pv.name = {gBunchLength.screen.blen_phase.desc_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.desc_pv.connected = 0;
gBunchLength.screen.blen_phase.desc_pv.force = {1};

gBunchLength.screen.blen_phase.egu = cell(1);
gBunchLength.screen.blen_phase.egu_pv.name = {gBunchLength.screen.blen_phase.egu_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.egu_pv.connected = 0;
gBunchLength.screen.blen_phase.egu_pv.force = {1};

gBunchLength.screen.blen_phase.std = cell(1);
gBunchLength.screen.blen_phase.std_pv.name = {gBunchLength.screen.blen_phase.std_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.std_pv.connected = 0;
gBunchLength.screen.blen_phase.std_pv.force = {1};

try
    gBunchLength.screen.blen_phase.std{1} = lcaGet(gBunchLength.screen.blen_phase.std_pv.name);
catch
end

gBunchLength.screen.blen_phase.alg = cell(1);
gBunchLength.screen.blen_phase.alg_pv.name = {gBunchLength.screen.blen_phase.alg_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.alg_pv.connected = 0;
gBunchLength.screen.blen_phase.alg_pv.force = {1};

try
    gBunchLength.screen.blen_phase.alg{1} = lcaGet(gBunchLength.screen.blen_phase.alg_pv.name);
catch
end

gBunchLength.screen.blen_phase.timestamp = cell(1);
gBunchLength.screen.blen_phase.timestamp_pv.name = {gBunchLength.screen.blen_phase.timestamp_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.timestamp_pv.connected = 0;
gBunchLength.screen.blen_phase.timestamp_pv.force = {1};

try
    gBunchLength.screen.blen_phase.timestamp{1} = lcaGet(gBunchLength.screen.blen_phase.timestamp_pv.name);
catch
end

gBunchLength.screen.blen_phase.tcav_power = cell(1);
gBunchLength.screen.blen_phase.tcav_power_pv.name = {gBunchLength.screen.blen_phase.tcav_power_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.tcav_power_pv.connected = 0;
gBunchLength.screen.blen_phase.tcav_power_pv.force = {1};

try
    gBunchLength.screen.blen_phase.tcav_power{1} = lcaGet(gBunchLength.screen.blen_phase.tcav_power_pv.name);
catch
end

gBunchLength.screen.maxImgs.value = cell(1);
gBunchLength.screen.maxImgs_pv.name = {gBunchLength.screen.maxImgs_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.maxImgs_pv.connected = 0;
gBunchLength.screen.maxImgs_pv.force = {1};
 
gBunchLength.screen.image.resolution = cell(1);
gBunchLength.screen.image.resolution_pv.name = {gBunchLength.screen.image.resolution_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.image.resolution_pv.connected = 0;
gBunchLength.screen.image.resolution_pv.force = {1};

% Beam rate
gBunchLength.rate = [];
gBunchLength.rate.ts = cell(1);

gBunchLength.rate.value = cell(1);
gBunchLength.rate.pv.format = 'IOC:IN20:MC01:LCLSBEAMRATE%s';
gBunchLength.rate.pv.name{1} = sprintf(gBunchLength.rate.pv.format, '');
gBunchLength.rate.pv.connected = 0;
gBunchLength.rate.pv.force = {1};

gBunchLength.rate.desc = cell(1);
gBunchLength.rate.desc_pv.name{1} = sprintf(gBunchLength.rate.pv.format, '.DESC');
gBunchLength.rate.desc_pv.connected = 0;
gBunchLength.rate.desc_pv.force = {1};

gBunchLength.rate.egu = cell(1);
gBunchLength.rate.egu_pv.name{1} = sprintf(gBunchLength.rate.pv.format, '.EGU');
gBunchLength.rate.egu_pv.connected = 0;
gBunchLength.rate.egu_pv.force = {1};

% TCAV
gBunchLength.tcav = [];
gBunchLength.tcav.name = 'TCAV3';
gBunchLength.tcav.bgrp_variable = 'T_CAV3';
gBunchLength.tcav.aida = 'KLYS:LI24:81//TACT';
gBunchLength.tcav.pv.format = 'TCAV:LI24:800:%s';

gBunchLength.tcav.pdes.ts = cell(1);

gBunchLength.tcav.pdes.value = cell(1);
gBunchLength.tcav.pdes_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_PDES');
gBunchLength.tcav.pdes_pv.connected = 0;
gBunchLength.tcav.pdes_pv.force = {1};

gBunchLength.tcav.pdes.desc = cell(1);
gBunchLength.tcav.pdes.desc_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_PDES.DESC' );
gBunchLength.tcav.pdes.desc_pv.connected = 0;
gBunchLength.tcav.pdes.desc_pv.force = {1};

gBunchLength.tcav.pdes.egu = cell(1);
gBunchLength.tcav.pdes.egu_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_PDES.EGU' );
gBunchLength.tcav.pdes.egu_pv.connected = 0;
gBunchLength.tcav.pdes.egu_pv.force = {1};

gBunchLength.tcav.pact.ts = cell(1);

gBunchLength.tcav.pact.value = cell(1);
gBunchLength.tcav.pact_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_S_PV' );
gBunchLength.tcav.pact_pv.connected = 0;
gBunchLength.tcav.pact_pv.force = {1};

gBunchLength.tcav.pact.desc = cell(1);
gBunchLength.tcav.pact.desc_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_S_PV.DESC' );
gBunchLength.tcav.pact.desc_pv.connected = 0;
gBunchLength.tcav.pact.desc_pv.force = {1};

gBunchLength.tcav.pact.egu = cell(1);
gBunchLength.tcav.pact.egu_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_S_PV.EGU' );
gBunchLength.tcav.pact.egu_pv.connected = 0;
gBunchLength.tcav.pact.egu_pv.force = {1};

gBunchLength.tcav.aact.ts = cell(1);

gBunchLength.tcav.aact.value = cell(1);
gBunchLength.tcav.aact_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_S_AV' );
gBunchLength.tcav.aact_pv.connected = 0;
gBunchLength.tcav.aact_pv.force = {1};

gBunchLength.tcav.aact.desc = cell(1);
gBunchLength.tcav.aact.desc_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_S_AV.DESC' );
gBunchLength.tcav.aact.desc_pv.connected = 0;
gBunchLength.tcav.aact.desc_pv.force = {1};

gBunchLength.tcav.aact.egu = cell(1);
gBunchLength.tcav.aact.egu_pv.name{1} = sprintf(gBunchLength.tcav.pv.format, 'TC3_S_AV.EGU' );
gBunchLength.tcav.aact.egu_pv.connected = 0;
gBunchLength.tcav.aact.egu_pv.force = {1};

gBunchLength.tcav.cal.start_phase.ts = cell(1);
gBunchLength.tcav.cal.start_phase.value = cell(1);
gBunchLength.tcav.cal.start_phase.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_CSP'); 
gBunchLength.tcav.cal.start_phase.pv.connected = 0;
gBunchLength.tcav.cal.start_phase.pv.force = {1};
try
    gBunchLength.tcav.cal.start_phase.value{1} = lcaGet(gBunchLength.tcav.cal.start_phase.pv.name);
catch
end

gBunchLength.tcav.cal.end_phase.ts = cell(1);
gBunchLength.tcav.cal.end_phase.value = cell(1);
gBunchLength.tcav.cal.end_phase.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_CEP'); 
gBunchLength.tcav.cal.end_phase.pv.connected = 0;
gBunchLength.tcav.cal.end_phase.pv.force = {1};
try
    gBunchLength.tcav.cal.end_phase.value{1} = lcaGet(gBunchLength.tcav.cal.end_phase.pv.name);
catch
end

gBunchLength.tcav.cal.num_phase.ts = cell(1);
gBunchLength.tcav.cal.num_phase.value = cell(1);
gBunchLength.tcav.cal.num_phase.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_CN'); 
gBunchLength.tcav.cal.num_phase.pv.connected = 0;
gBunchLength.tcav.cal.num_phase.pv.force = {1};
try
    gBunchLength.tcav.cal.num_phase.value{1} = lcaGet(gBunchLength.tcav.cal.num_phase.pv.name);
catch
end

gBunchLength.tcav.cal.num_phase.desc = cell(1);
gBunchLength.tcav.cal.num_phase.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_CN.DESC'); 
gBunchLength.tcav.cal.num_phase.desc_pv.connected = 0;
gBunchLength.tcav.cal.num_phase.desc_pv.force = {1};

gBunchLength.tcav.settle_time.ts = cell(1);
gBunchLength.tcav.settle_time.value = cell(1);
gBunchLength.tcav.settle_time.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_ST'); 
gBunchLength.tcav.settle_time.pv.connected = 0;
gBunchLength.tcav.settle_time.pv.force = {1};

gBunchLength.tcav.settle_time.egu = cell(1);
gBunchLength.tcav.settle_time.egu_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_ST.EGU'); 
gBunchLength.tcav.settle_time.egu_pv.connected = 0;
gBunchLength.tcav.settle_time.egu_pv.force = {1};

gBunchLength.tcav.settle_time.desc = cell(1);
gBunchLength.tcav.settle_time.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TCAV_ST.DESC'); 
gBunchLength.tcav.settle_time.desc_pv.connected = 0;
gBunchLength.tcav.settle_time.desc_pv.force = {1};

% Toroid
gBunchLength.toro.ts = cell(1);
gBunchLength.toro.desc = 'IMBC20';
gBunchLength.toro.pv.format = 'TORO:LI25:235:%s';
gBunchLength.toro.desc = 'BPM9';
gBunchLength.toro.pv.format = 'BPMS:IN20:525:%s';
gBunchLength.toro.pv.name{1} = sprintf(gBunchLength.toro.pv.format, 'TMIT');

gBunchLength.toro.tmit.egu = cell(1);
gBunchLength.toro.tmit.egu_pv.name{1} = sprintf(gBunchLength.toro.pv.format, 'TMIT.EGU');
gBunchLength.toro.tmit.egu_pv.connected = 0;
gBunchLength.toro.tmit.egu_pv.force = {1};

% Availabe feedback BPMS
gBunchLength.bpm = [];
gBunchLength.bpm.slc = 1; % All CAMAC controlled BPMS
gBunchLength.bpm.a = {'BPM25-301','BPM25-401','BPM25-501','BPM25-901'};
gBunchLength.bpm.i = 2; % default to BPM25-401
gBunchLength.bpm.pv.format = {'BPMS:LI25:301:%s', ...
                              'BPMS:LI25:401:%s', ...
                              'BPMS:LI25:501:%s', ...
                              'BPMS:LI25:901:%s'};
gBunchLength.bpm.pv.fmtslc = {'LI25:BPMS:301:%s', ...
                              'LI25:BPMS:401:%s', ...
                              'LI25:BPMS:501:%s', ...
                              'LI25:BPMS:901:%s'};
                              
gBunchLength.bpm.desc = gBunchLength.bpm.a{gBunchLength.bpm.i};

gBunchLength.bpm.x.egu_pv.a = cell(0);
gBunchLength.bpm.tmit.egu_pv.a = cell(0);
gBunchLength.bpm.blen_phase_pv.a = cell(0);
gBunchLength.bpm.blen_phase.desc_pv.a = cell(0);
gBunchLength.bpm.blen_phase.egu_pv.a = cell(0);
gBunchLength.bpm.blen_phase.timestamp_pv.a = cell(0);
gBunchLength.bpm.blen_phase.tcav_power_pv.a = cell(0);
gBunchLength.bpm.blen_phase.tcav_phase_pv.a = cell(0);
gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.a = cell(0);
gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.a = cell(0);
gBunchLength.bpm.blen_phase.apply_pv.a = cell(0);
gBunchLength.bpm.blen_phase.apply.desc_pv.a = cell(0);
gBunchLength.bpm.blen_phase.gain_factor_pv.a = cell(0);
gBunchLength.bpm.blen_phase.gain_factor.desc_pv.a = cell(0);
gBunchLength.bpm.blen_phase.y_ref_pv.a = cell(0);
gBunchLength.bpm.blen_phase.y_ref.desc_pv.a = cell(0);
gBunchLength.bpm.blen_phase.y_ref.egu_pv.a = cell(0);
gBunchLength.bpm.blen_phase.y_tol_pv.a = cell(0);
gBunchLength.bpm.blen_phase.y_tol.desc_pv.a = cell(0);
gBunchLength.bpm.blen_phase.y_tol.egu_pv.a = cell(0);

for i = 1:size(gBunchLength.bpm.pv.format,2)
    gBunchLength.bpm.x.egu_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'X.EGU');
    gBunchLength.bpm.tmit.egu_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'TMIT.EGU');
    gBunchLength.bpm.blen_phase_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_P');
    gBunchLength.bpm.blen_phase.desc_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_P.DESC');
    gBunchLength.bpm.blen_phase.egu_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_P.EGU');
    gBunchLength.bpm.blen_phase.timestamp_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_PTS');
    gBunchLength.bpm.blen_phase.tcav_power_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_A');
    gBunchLength.bpm.blen_phase.tcav_phase_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_TPBZ');
    gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_TPBZ.EGU');
    gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_TPBZ.DESC');
    gBunchLength.bpm.blen_phase.apply_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_CF');
    gBunchLength.bpm.blen_phase.apply.desc_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_CF.DESC');
    gBunchLength.bpm.blen_phase.gain_factor_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_GF');
    gBunchLength.bpm.blen_phase.gain_factor.desc_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_GF.DESC');
    gBunchLength.bpm.blen_phase.y_ref_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_Y');
    gBunchLength.bpm.blen_phase.y_ref.desc_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_Y.DESC');
    gBunchLength.bpm.blen_phase.y_ref.egu_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'X.EGU');
    gBunchLength.bpm.blen_phase.y_tol_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_YT');
    gBunchLength.bpm.blen_phase.y_tol.desc_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'BLEN_YT.DESC');
    gBunchLength.bpm.blen_phase.y_tol.egu_pv.a{end+1} = sprintf(gBunchLength.bpm.pv.format{i}, 'Y.EGU');
end

gBunchLength.bpm.ts = cell(1);

gBunchLength.bpm.x.egu = cell(1); % BPM X&Y EGU
gBunchLength.bpm.x.egu_pv.name = {gBunchLength.bpm.x.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.x.egu_pv.connected = 0;
gBunchLength.bpm.x.egu_pv.force = {1};

gBunchLength.bpm.tmit.egu = cell(1); % BPM TMIT EGU
gBunchLength.bpm.tmit.egu_pv.name = {gBunchLength.bpm.tmit.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.tmit.egu_pv.connected = 0;
gBunchLength.bpm.tmit.egu_pv.force = {1};

% Special for CAMAC controlled BPMS
gBunchLength.bpm.x.egu = {'mm'}; % BPM X&Y EGU 
gBunchLength.bpm.x.egu_pv.connected = {1}; 
gBunchLength.bpm.x.egu_slc = 1; 
gBunchLength.bpm.tmit.egu = {'Nel'}; % BPM TMIT EGU 
gBunchLength.bpm.tmit.egu_pv.connected = {1}; 
gBunchLength.bpm.tmit.egu_slc = 1;

gBunchLength.bpm.blen_phase.ts = cell(1);

gBunchLength.bpm.blen_phase.egu = cell(1); % TCAV phase to BPM calibration constant EGU
gBunchLength.bpm.blen_phase.egu_pv.name = {gBunchLength.bpm.blen_phase.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.egu_pv.connected = 0;
gBunchLength.bpm.blen_phase.egu_pv.force = {1};

gBunchLength.bpm.blen_phase.value = cell(1); % TCAV phase to BPM calibration constant
gBunchLength.bpm.blen_phase_pv.name = {gBunchLength.bpm.blen_phase_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase_pv.connected = 0;
gBunchLength.bpm.blen_phase_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.value{1} = lcaGet(gBunchLength.bpm.blen_phase_pv.name);
catch
end

gBunchLength.bpm.blen_phase.desc = cell(1); % TCAV phase to BPM calibration constant
gBunchLength.bpm.blen_phase.desc_pv.name = {gBunchLength.bpm.blen_phase.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.desc_pv.connected = 0;
gBunchLength.bpm.blen_phase.desc_pv.force = {1};

gBunchLength.bpm.blen_phase.egu = cell(1); % TCAV phase to BPM calibration constant EGU
gBunchLength.bpm.blen_phase.egu_pv.name = {gBunchLength.bpm.blen_phase.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.egu_pv.connected = 0;
gBunchLength.bpm.blen_phase.egu_pv.force = {1};

gBunchLength.bpm.blen_phase.timestamp = cell(1); % time stamp forTCAV phase to BPM calibration constant
gBunchLength.bpm.blen_phase.timestamp_pv.name = {gBunchLength.bpm.blen_phase.timestamp_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.timestamp_pv.connected = 0;
gBunchLength.bpm.blen_phase.timestamp_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.timestamp{1} = lcaGet(gBunchLength.bpm.blen_phase.timestamp_pv.name);
catch
end

gBunchLength.bpm.blen_phase.tcav_power = cell(1); % TCAV power at TCAV phase to BPM calibration constant
gBunchLength.bpm.blen_phase.tcav_power_pv.name = {gBunchLength.bpm.blen_phase.tcav_power_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_power_pv.connected = 0;
gBunchLength.bpm.blen_phase.tcav_power_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.tcav_power{1} = lcaGet(gBunchLength.bpm.blen_phase.tcav_power_pv.name);
catch
end

gBunchLength.bpm.blen_phase.tcav_phase.value = cell(1); % TCAV phase when BPM y reads zero
gBunchLength.bpm.blen_phase.tcav_phase_pv.name = {gBunchLength.bpm.blen_phase.tcav_phase_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_phase_pv.connected = 0;
gBunchLength.bpm.blen_phase.tcav_phase_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.tcav_phase.value{1} = lcaGet(gBunchLength.bpm.blen_phase.tcav_phase_pv.name);
catch
end

gBunchLength.bpm.blen_phase.tcav_phase.egu = cell(1); % TCAV phase when BPM y reads zero EGU
gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.name = {gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.connected = 0;
gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.force = {1};

gBunchLength.bpm.blen_phase.tcav_phase.desc = cell(1); % TCAV phase when BPM y reads zero DESC
gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.name = {gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.connected = 0;
gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.force = {1};

gBunchLength.bpm.blen_phase.apply.value = cell(1); % Apply Correction Function? Yes or No
gBunchLength.bpm.blen_phase.apply_pv.name = {gBunchLength.bpm.blen_phase.apply_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.apply_pv.connected = 0;
gBunchLength.bpm.blen_phase.apply_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.apply.value{1} = lcaGet(gBunchLength.bpm.blen_phase.apply_pv.name);
catch
end

gBunchLength.bpm.blen_phase.apply.desc = cell(1); % "Apply Correction Function?" description
gBunchLength.bpm.blen_phase.apply.desc_pv.name = {gBunchLength.bpm.blen_phase.apply.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.apply.desc_pv.connected = 0;
gBunchLength.bpm.blen_phase.apply.desc_pv.force = {1};

gBunchLength.bpm.blen_phase.gain_factor.value = cell(1); % Feedback gain factor
gBunchLength.bpm.blen_phase.gain_factor_pv.name = {gBunchLength.bpm.blen_phase.gain_factor_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.gain_factor_pv.connected = 0;
gBunchLength.bpm.blen_phase.gain_factor_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.gain_factor.value{1} = lcaGet(gBunchLength.bpm.blen_phase.gain_factor_pv.name);
catch
end

gBunchLength.bpm.blen_phase.gain_factor.desc = cell(1); % Feedback gain factor description
gBunchLength.bpm.blen_phase.gain_factor.desc_pv.name = {gBunchLength.bpm.blen_phase.gain_factor.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.gain_factor.desc_pv.connected = 0;
gBunchLength.bpm.blen_phase.gain_factor.desc_pv.force = {1};

gBunchLength.bpm.blen_phase.y_ref.value = cell(1); % BPM y reference reading
gBunchLength.bpm.blen_phase.y_ref_pv.name = {gBunchLength.bpm.blen_phase.y_ref_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_ref_pv.connected = 0;
gBunchLength.bpm.blen_phase.y_ref_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.y_ref.value{1} = lcaGet(gBunchLength.bpm.blen_phase.y_ref_pv.name);
catch
end

gBunchLength.bpm.blen_phase.y_ref.desc = cell(1); % BPM y reference reading description
gBunchLength.bpm.blen_phase.y_ref.desc_pv.name = {gBunchLength.bpm.blen_phase.y_ref.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_ref.desc_pv.connected = 0;
gBunchLength.bpm.blen_phase.y_ref.desc_pv.force = {1};

gBunchLength.bpm.blen_phase.y_ref.egu = cell(1); % BPM y reference reading engineering units
gBunchLength.bpm.blen_phase.y_ref.egu_pv.name = {gBunchLength.bpm.blen_phase.y_ref.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_ref.egu_pv.connected = 0;
gBunchLength.bpm.blen_phase.y_ref.egu_pv.force = {1};

% Special for CAMAC controlled BPMS
gBunchLength.bpm.blen_phase.y_ref.egu = {'mm'}; % BPM y reference reading engineering units 
gBunchLength.bpm.blen_phase.y_ref.egu_pv.connected = {1}; 
gBunchLength.bpm.blen_phase.y_ref.egu_slc = 1;

gBunchLength.bpm.blen_phase.y_tol.value = cell(1); % BPM y reference reading tolerance
gBunchLength.bpm.blen_phase.y_tol_pv.name = {gBunchLength.bpm.blen_phase.y_tol_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_tol_pv.connected = 0;
gBunchLength.bpm.blen_phase.y_tol_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.y_tol.value{1} = lcaGet(gBunchLength.bpm.blen_phase.y_tol_pv.name);
catch
end

gBunchLength.bpm.blen_phase.y_tol.desc = cell(1); % BPM y reference reading tolerance description
gBunchLength.bpm.blen_phase.y_tol.desc_pv.name = {gBunchLength.bpm.blen_phase.y_tol.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_tol.desc_pv.connected = 0;
gBunchLength.bpm.blen_phase.y_tol.desc_pv.force = {1};

gBunchLength.bpm.blen_phase.y_tol.egu = cell(1); % BPM y reference reading tolerance engineering units
gBunchLength.bpm.blen_phase.y_tol.egu_pv.name = {gBunchLength.bpm.blen_phase.y_tol.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_tol.egu_pv.connected = 0;
gBunchLength.bpm.blen_phase.y_tol.egu_pv.force = {1};

% Special for CAMAC controlled BPMS
gBunchLength.bpm.blen_phase.y_tol.egu = {'mm'}; % BPM y reference reading tolerance engineering units 
gBunchLength.bpm.blen_phase.y_tol.egu_pv.connected = {1}; 
gBunchLength.bpm.blen_phase.y_tol.egu_slc = 1;
                                 
% The Number of background images per TCAV phase step
gBunchLength.blen.num_bkg.ts = cell(1);

gBunchLength.blen.num_bkg.value = cell(1);
gBunchLength.blen.num_bkg.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NBI');
gBunchLength.blen.num_bkg.pv.connected = 0;
gBunchLength.blen.num_bkg.pv.force = {1};
try
    gBunchLength.blen.num_bkg.value{1} = lcaGet (gBunchLength.blen.num_bkg.pv.name);
catch
end

gBunchLength.blen.num_bkg.desc = cell(1);
gBunchLength.blen.num_bkg.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NBI.DESC');
gBunchLength.blen.num_bkg.desc_pv.connected = 0;
gBunchLength.blen.num_bkg.desc_pv.force = {1};

% The Number of foreground images per TCAV phase step
gBunchLength.blen.num_img.ts = cell(1);

gBunchLength.blen.num_img.value = cell(1);
gBunchLength.blen.num_img.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NI');
gBunchLength.blen.num_img.pv.connected = 0;
gBunchLength.blen.num_img.pv.force = {1};
try
    gBunchLength.blen.num_img.value{1} = lcaGet (gBunchLength.blen.num_img.pv.name);
catch
end

gBunchLength.blen.num_img.desc = cell(1);
gBunchLength.blen.num_img.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NI.DESC');
gBunchLength.blen.num_img.desc_pv.connected = 0;
gBunchLength.blen.num_img.desc_pv.force = {1};

% The average TORO TMIT reading during the measurement procedure
gBunchLength.blen.nel.ts = cell(1);

gBunchLength.blen.nel.value = cell(1);
gBunchLength.blen.nel.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NEL');
gBunchLength.blen.nel.pv.connected = 0;
gBunchLength.blen.nel.pv.force = {1};
try
    gBunchLength.blen.nel.value{1} = lcaGet (gBunchLength.blen.nel.pv.name);
catch
end

gBunchLength.blen.nel.desc = cell(1);
gBunchLength.blen.nel.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NEL.DESC');
gBunchLength.blen.nel.desc_pv.connected = 0;
gBunchLength.blen.nel.desc_pv.force = {1};

gBunchLength.blen.nel.egu = cell(1);
gBunchLength.blen.nel.egu_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'NEL.EGU');
gBunchLength.blen.nel.egu_pv.connected = 0;
gBunchLength.blen.nel.egu_pv.force = {1};

% The name of the image processing algorithm used for measurement procedure
gBunchLength.blen.meas_img_alg.ts = cell(1);

gBunchLength.blen.meas_img_alg.value = cell(1);
gBunchLength.blen.meas_img_alg.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'MEASIMGALG');
gBunchLength.blen.meas_img_alg.pv.connected = 0;
gBunchLength.blen.meas_img_alg.pv.force = {1};
try
    gBunchLength.blen.meas_img_alg.value{1} = lcaGet (gBunchLength.blen.meas_img_alg.pv.name);
catch
end

% The name of the image processing algorithm used for calibration procedure
gBunchLength.blen.cal_img_alg.ts = cell(1);

gBunchLength.blen.cal_img_alg.value = cell(1);
gBunchLength.blen.cal_img_alg.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'CALIMGALG');
gBunchLength.blen.cal_img_alg.pv.connected = 0;
gBunchLength.blen.cal_img_alg.pv.force = {1};
try
    gBunchLength.blen.cal_img_alg.value{1} = lcaGet (gBunchLength.blen.cal_img_alg.pv.name);
catch
end

% The TCAV PDES for the first measurement
gBunchLength.blen.first_phase.ts = cell(1);

gBunchLength.blen.first_phase.value = cell(1);
gBunchLength.blen.first_phase.pv.name{1} = sprintf (gBunchLength.blen.pv.format, '1PDES');
gBunchLength.blen.first_phase.pv.connected = 0;
gBunchLength.blen.first_phase.pv.force = {1};
try
    gBunchLength.blen.first_phase.value{1} = lcaGet (gBunchLength.blen.first_phase.pv.name);
catch
end

% The TCAV PDES for the third measurement
gBunchLength.blen.third_phase.ts = cell(1);

gBunchLength.blen.third_phase.value = cell(1);
gBunchLength.blen.third_phase.pv.name{1} = sprintf (gBunchLength.blen.pv.format, '3PDES');
gBunchLength.blen.third_phase.pv.connected = 0;
gBunchLength.blen.third_phase.pv.force = {1};
try
    gBunchLength.blen.third_phase.value{1} = lcaGet (gBunchLength.blen.third_phase.pv.name);
catch
end

% The TORO TMIT tolerance
gBunchLength.blen.tmit_tol.ts = cell(1);

gBunchLength.blen.tmit_tol.value = cell(1);
gBunchLength.blen.tmit_tol.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TMIT_LMT');
gBunchLength.blen.tmit_tol.pv.connected = 0;
gBunchLength.blen.tmit_tol.pv.force = {1};
try
    gBunchLength.blen.tmit_tol.value{1} = lcaGet (gBunchLength.blen.tmit_tol.pv.name);
catch
    gBunchLength.blen.tmit_tol.value{1} = {10};
end

gBunchLength.blen.tmit_tol.desc = cell(1);
gBunchLength.blen.tmit_tol.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TMIT_LMT.DESC');
gBunchLength.blen.tmit_tol.desc_pv.connected = 0;
gBunchLength.blen.tmit_tol.desc_pv.force = {1};

gBunchLength.blen.tmit_tol.egu = cell(1);
gBunchLength.blen.tmit_tol.egu_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'TMIT_LMT.EGU');
gBunchLength.blen.tmit_tol.egu_pv.connected = 0;
gBunchLength.blen.tmit_tol.egu_pv.force = {1};

% The maximum number of pulses the correction function is allowed to use
gBunchLength.blen.cf_np.ts = cell(1);

gBunchLength.blen.cf_np.value = cell(1);
gBunchLength.blen.cf_np.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'CF_NP');
gBunchLength.blen.cf_np.pv.connected = 0;
gBunchLength.blen.cf_np.pv.force = {1};
try
    gBunchLength.blen.cf_np.value{1} = lcaGet (gBunchLength.blen.cf_np.pv.name);
catch
    gBunchLength.blen.cf_np.value{1} = {10};
end

gBunchLength.blen.cf_np.desc = cell(1);
gBunchLength.blen.cf_np.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'CF_NP.DESC');
gBunchLength.blen.cf_np.desc_pv.connected = 0;
gBunchLength.blen.cf_np.desc_pv.force = {1};

% The last Bunch Length saved
gBunchLength.blen.sigx.ts = cell(1);
gBunchLength.blen.sigx.value = cell(1);
gBunchLength.blen.sigx.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGX');
gBunchLength.blen.sigx.pv.connected = 0;
gBunchLength.blen.sigx.pv.force = {1};

gBunchLength.blen.sigx.std = cell(1);
gBunchLength.blen.sigx.std_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGXSTD');
gBunchLength.blen.sigx.std_pv.connected = 0;
gBunchLength.blen.sigx.std_pv.force = {1};

try
    gBunchLength.blen.sigx.value{1} = lcaGet (gBunchLength.blen.sigx.pv.name);
    gBunchLength.blen.sigx.std{1} = lcaGet (gBunchLength.blen.sigx.std_pv.name);
catch
end

gBunchLength.blen.sigx.desc = cell(1);
gBunchLength.blen.sigx.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGX.DESC');
gBunchLength.blen.sigx.desc_pv.connected = 0;
gBunchLength.blen.sigx.desc_pv.force = {1};

gBunchLength.blen.sigx.egu = cell(1);
gBunchLength.blen.sigx.egu_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGX.EGU');
gBunchLength.blen.sigx.egu_pv.connected = 0;
gBunchLength.blen.sigx.egu_pv.force = {1};

gBunchLength.blen.mm.ts = cell(1);
gBunchLength.blen.mm.value = cell(1);
gBunchLength.blen.mm.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'MM');
gBunchLength.blen.mm.pv.connected = 0;
gBunchLength.blen.mm.pv.force = {1};

gBunchLength.blen.mm.std = cell(1);
gBunchLength.blen.mm.std_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'MMSTD');
gBunchLength.blen.mm.std_pv.connected = 0;
gBunchLength.blen.mm.std_pv.force = {1};

try
    gBunchLength.blen.mm.value{1} = lcaGet (gBunchLength.blen.mm.pv.name);
    gBunchLength.blen.mm.std{1} = lcaGet (gBunchLength.blen.mm.std_pv.name);
catch
end

gBunchLength.blen.mm.desc = cell(1);
gBunchLength.blen.mm.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'MM.DESC');
gBunchLength.blen.mm.desc_pv.connected = 0;
gBunchLength.blen.mm.desc_pv.force = {1};

gBunchLength.blen.mm.egu = cell(1);
gBunchLength.blen.mm.egu_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'MM.EGU');
gBunchLength.blen.mm.egu_pv.connected = 0;
gBunchLength.blen.mm.egu_pv.force = {1};

gBunchLength.blen.sigt.ts = cell(1);
gBunchLength.blen.sigt.value = cell(1);
gBunchLength.blen.sigt.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGT');
gBunchLength.blen.sigt.pv.connected = 0;
gBunchLength.blen.sigt.pv.force = {1};

gBunchLength.blen.sigt.std = cell(1);
gBunchLength.blen.sigt.std_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGTSTD');
gBunchLength.blen.sigt.std_pv.connected = 0;
gBunchLength.blen.sigt.std_pv.force = {1};

try
    gBunchLength.blen.sigt.value{1} = lcaGet (gBunchLength.blen.sigt.pv.name);
    gBunchLength.blen.sigt.std{1} = lcaGet (gBunchLength.blen.sigt.std_pv.name);
catch
end

gBunchLength.blen.sigt.desc = cell(1);
gBunchLength.blen.sigt.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGT.DESC');
gBunchLength.blen.sigt.desc_pv.connected = 0;
gBunchLength.blen.sigt.desc_pv.force = {1};

gBunchLength.blen.sigt.egu = cell(1);
gBunchLength.blen.sigt.egu_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'SIGT.EGU');
gBunchLength.blen.sigt.egu_pv.connected = 0;
gBunchLength.blen.sigt.egu_pv.force = {1};

gBunchLength.blen.r35.ts = cell(1);
gBunchLength.blen.r35.value = cell(1);
gBunchLength.blen.r35.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'R35');
gBunchLength.blen.r35.pv.connected = 0;
gBunchLength.blen.r35.pv.force = {1};

gBunchLength.blen.r35.std = cell(1);
gBunchLength.blen.r35.std_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'R35STD');
gBunchLength.blen.r35.std_pv.connected = 0;
gBunchLength.blen.r35.std_pv.force = {1};

gBunchLength.blen.r35.desc = cell(1);
gBunchLength.blen.r35.desc_pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'R35.DESC');
gBunchLength.blen.r35.desc_pv.connected = 0;
gBunchLength.blen.r35.desc_pv.force = {1};

try
    gBunchLength.blen.r35.value{1} = lcaGet (gBunchLength.blen.r35.pv.name);
    gBunchLength.blen.r35.std{1} = lcaGet (gBunchLength.blen.r35.std_pv.name);
catch
end

gBunchLength.blen.meas_ts.ts = cell(1);
gBunchLength.blen.meas_ts.value = cell(1);
gBunchLength.blen.meas_ts.pv.name{1} = sprintf (gBunchLength.blen.pv.format, 'MEAS_TS');
gBunchLength.blen.meas_ts.pv.connected = 0;
gBunchLength.blenmeas_ts.pv.force = {1};

try
    gBunchLength.blen.meas_ts.value{1} = lcaGet (gBunchLength.blen.meas_ts.pv.name);
catch
end

% Image Acquisition Available?
gBunchLength.imgAcq.avail.ts = cell(1);
gBunchLength.imgAcq.avail.value = cell(1);
gBunchLength.imgAcq.avail.pv.name = {'PROF:PM00:1:CTRL'};
gBunchLength.imgAcq.avail.pv.connected = 0;
gBunchLength.imgAcq.avail.pv.force = {1};

% Matlab based feedbacks
gBunchLength.fb = [];
gBunchLength.fb(1).ts = cell(1);
gBunchLength.fb(1).value = cell(1);
gBunchLength.fb(1).pv.name{1} = 'FBCK:LNG4:1:ENABLE';
gBunchLength.fb(1).pv.connected = 0;
gBunchLength.fb(1).pv.force = {1};

gBunchLength.fb(2).ts = cell(1);
gBunchLength.fb(2).value = cell(1);
gBunchLength.fb(2).pv.name{1} = 'FBCK:LNG5:1:ENABLE';
gBunchLength.fb(2).pv.connected = 0;
gBunchLength.fb(2).pv.force = {1};

gBunchLength.fb(3).ts = cell(1);
gBunchLength.fb(3).value = cell(1);
gBunchLength.fb(3).pv.name{1} = 'FBCK:LNG6:1:ENABLE';
gBunchLength.fb(3).pv.connected = 0;
gBunchLength.fb(3).pv.force = {1};

if usejava('desktop')
else
    try
        cd (sprintf ('%s/BunchLength/data/%s', getenv('MATLABDATAFILES'), gBunchLength.tcav.name));
    catch
    end
end

