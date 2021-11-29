function facet_tcav_fb()
% FACET TCAV phase feedback
% E Tse / N Lipkowitz, SLAC

%% basic initialization
mf = strcat(mfilename, '.m');
disp_log(strcat(mf, {' starting, ver 1.6 3/21/2016'}));
debug = 0;
lcaSetSeverityWarnLevel(14);

% set e-/e+ here
%charge = -1; % e-
charge = +1; % e-


%% start watchdog

pvs.watchdog = {'SIOC:SYS1:ML00:AO100'};
disp_log(strcat({'Starting watchdog on '}, pvs.watchdog));
W = watchdog(char(pvs.watchdog), 1, mf);
switch get_watchdog_error(W)
    case 1
        disp_log(strcat({'Another '}, mf, {' is running - exiting'}));
        return;
    case 2
        disp_log(strcat({'Error reading/writing '}, pvs.watchdog, {' - exiting'}));
        return;
    otherwise
        disp_log(strcat({'Watchdog started on '}, pvs.watchdog));
end

%% define a PV struct for inputs

% EPICS BPMS for position readback
bpms                = {'BPMS:LI20:2445'; 'BPMS:LI20:3156'; 'BPMS:LI20:3265'; 'BPMS:LI20:3315'};

pvs.in.bpms = {};
for ix = 1:numel(bpms)
    pvs.in.bpms     = [pvs.in.bpms; strcat(bpms(ix), ':', {'X' 'Y' 'TMIT'}, '')];
end

pvs.in.calib(1) = script_setupPV('SIOC:SYS1:ML00:AO673',...
         strcat(bpms(1), {' calib @ 35MV'}),      'mm/degX', 3, mf);
pvs.in.calib(2) = script_setupPV('SIOC:SYS1:ML00:AO674',...
         strcat(bpms(2), {' calib @ 35MV'}),      'mm/degX', 3, mf);
pvs.in.calib(3) = script_setupPV('SIOC:SYS1:ML00:AO675',...
         strcat(bpms(3), {' calib @ 35MV'}),      'mm/degX', 3, mf);
pvs.in.calib(4) = script_setupPV('SIOC:SYS1:ML00:AO676',...
         strcat(bpms(4), {' calib @ 35MV'}),      'mm/degX', 3, mf);

% flags for turning BPMS off and on
pvs.in.bpm.enable(1) = script_setupPV('SIOC:SYS1:ML00:AO688',...
    strcat(bpms(1), {' enable'}),      'bool', 0, mf);
pvs.in.bpm.enable(2) = script_setupPV('SIOC:SYS1:ML00:AO689',...
    strcat(bpms(2), {' enable'}),      'bool', 0, mf);
pvs.in.bpm.enable(3) = script_setupPV('SIOC:SYS1:ML00:AO690',...
    strcat(bpms(3), {' enable'}),      'bool', 0, mf);
pvs.in.bpm.enable(4) = script_setupPV('SIOC:SYS1:ML00:AO691',...
    strcat(bpms(4), {' enable'}),      'bool', 0, mf);

% PAD/PAC controls for TCAV status
pvs.in.tcav.ades    =  'TCAV:LI20:2400:ADES';
pvs.in.tcav.ampl    = {'TCAV:LI20:2400:S_AV'};
pvs.in.tcav.pdes    =  'TCAV:LI20:2400:PDES';
pvs.in.tcav.phas    = {'TCAV:LI20:2400:S_PV'};
pvs.in.tcav.fbck    = {'TCAV:LI20:2400:PHAS_FB' 'TCAV:LI20:2400:AMPL_FB' 'TCAV:LI20:2400:SEND'};
pvs.in.tcav.bvlt    = 'LI20:KLYS:41:BVLT';

% Trigger states for PAD/PAC
pvs.in.tcav.tctl    = { ...
    'TCAV:LI20:2400:C_1_TCTL'; % ACCL PAC
    'TCAV:LI20:2400:C_2_TCTL'; % STBY PAC
    'TCAV:LI20:2400:D_TCTL';   % PAD
    'TCAV:LI20:2400:K_TCTL';   % DIAG PAD
    'TCAV:LI20:2400:I_TCTL'};  % INTLK PAD

pvs.in.tcav.trig    = { ...
    'EVR:LI20:RF01:EVENT1CTRL.OUT0' 'EVR:LI20:RF01:EVENT2CTRL.OUT0' 'EVR:LI20:RF01:EVENT3CTRL.OUT0' 'EVR:LI20:RF01:EVENT4CTRL.OUT0' 'EVR:LI20:RF01:EVENT5CTRL.OUT0'; ...
    'EVR:LI20:RF01:EVENT1CTRL.OUT1' 'EVR:LI20:RF01:EVENT2CTRL.OUT1' 'EVR:LI20:RF01:EVENT3CTRL.OUT1' 'EVR:LI20:RF01:EVENT4CTRL.OUT1' 'EVR:LI20:RF01:EVENT5CTRL.OUT1'; ...
    'EVR:LI20:RF01:EVENT1CTRL.OUT2' 'EVR:LI20:RF01:EVENT2CTRL.OUT2' 'EVR:LI20:RF01:EVENT3CTRL.OUT2' 'EVR:LI20:RF01:EVENT4CTRL.OUT2' 'EVR:LI20:RF01:EVENT5CTRL.OUT2'; ...
    'EVR:LI20:RF01:EVENT1CTRL.OUT3' 'EVR:LI20:RF01:EVENT2CTRL.OUT3' 'EVR:LI20:RF01:EVENT3CTRL.OUT3' 'EVR:LI20:RF01:EVENT4CTRL.OUT3' 'EVR:LI20:RF01:EVENT5CTRL.OUT3'; ...
    'EVR:LI20:RF01:EVENT1CTRL.OUT4' 'EVR:LI20:RF01:EVENT2CTRL.OUT4' 'EVR:LI20:RF01:EVENT3CTRL.OUT4' 'EVR:LI20:RF01:EVENT4CTRL.OUT4' 'EVR:LI20:RF01:EVENT5CTRL.OUT4'; ...
};

% Modulator status
pvs.in.tcav.bvlt    = 'KLYS:LI20:K4:2:S_SACTUAL';   % Beam volts from diagnostic PAD
pvs.in.tcav.stat    = 'FCUDKLYS:LI20:4:STATUS';     % KLYS status from klystronCud.m
pvs.in.tcav.tact    = 'FCUDKLYS:LI20:4:ONBEAM10';   % KLYS active from klystronCud.m

% other useful stuff
if charge < 0
    pvs.in.beamrate     = 'EVNT:SYS1:1:BEAMRATE'; % for e-
else
    pvs.in.beamrate     = 'EVNT:SYS1:1:POSITRONRATE'; % for e+
end
pvs.in.bcsperm      = 'LI00:BCS:4:BPERMOUT';

%% define a PV struct for script controls

pvs.in.enable   = script_setupPV('SIOC:SYS1:ML00:AO661',    'TCAV FB Enable',      'bool', 0, mf);
pvs.in.gain     = script_setupPV('SIOC:SYS1:ML00:AO662',    'TCAV FB Gain',        'arb',  3, mf);
pvs.in.delay    = script_setupPV('SIOC:SYS1:ML00:AO663',    'TCAV FB Loop delay',  's',  3, mf);
pvs.in.bpm_tol  = script_setupPV('SIOC:SYS1:ML00:AO664',    'TCAV BPM Max', 'mm',   2, mf);
pvs.in.tmit_cut = script_setupPV('SIOC:SYS1:ML00:AO665',    'TCAV TMIT cut', '1e10 e-', 3, mf);
pvs.in.num_bad  = script_setupPV('SIOC:SYS1:ML00:AO666',    'TCAV Num Bad Pulses', 'arb',  0, mf);

% controls for drive ramp down
pvs.in.ramp.thresh = script_setupPV('SIOC:SYS1:ML00:AO681', 'TCAV Rampdown BVLT Thresh', 'kV',  2, mf);
pvs.in.ramp.enable = script_setupPV('SIOC:SYS1:ML00:AO682', 'TCAV Rampdown Enable', 'bool',  0, mf);

%% define a pv struct for outputs

pvs.stat.bpmok = script_setupPV('SIOC:SYS1:ML00:AO667', 'TCAV FB BPM ok', 'bool',  0, mf);
pvs.stat.rateok = script_setupPV('SIOC:SYS1:ML00:AO668', 'TCAV FB rate ok', 'bool',  0, mf);
pvs.stat.newdata = script_setupPV('SIOC:SYS1:ML00:AO669', 'TCAV FB new data', 'bool',  0, mf);
pvs.stat.good = script_setupPV('SIOC:SYS1:ML00:AO670', 'TCAV everything ok',  'bool',  0, mf);

% output status
pvs.stat.active = script_setupPV('SIOC:SYS1:ML00:AO671', 'TCAV Phase FB working', 'bool', 0, mf);
pvs.stat.poc(1) = script_setupPV('SIOC:SYS1:ML00:AO672', 'TCAV new Ch 0 POC', 'degX', 4, mf);
pvs.stat.poc(2) = script_setupPV('SIOC:SYS1:ML00:AO683', 'TCAV new Ch 1 POC', 'degX', 4, mf);
pvs.stat.perr   = script_setupPV('SIOC:SYS1:ML00:AO687', 'TCAV phase error',  'degX', 3, mf);

% feedback output: actual PAD phase offsets
pvs.out.poc   = {
    'TCAV:LI20:2400:0:POC', ...
    'TCAV:LI20:2400:1:POC', ...
};

% set the POC drive high and drive low limits which get reset on IOC reboot
% for to make phase ramp fancy knob work
drvhpv = strcat(pvs.out.poc', '.DRVH');
hoprpv = strcat(pvs.out.poc', '.HOPR');
drvlpv = strcat(pvs.out.poc', '.DRVL');
loprpv = strcat(pvs.out.poc', '.LOPR');

plim = [360; 360];

lcaPutSmart(drvhpv, plim);
lcaPutSmart(hoprpv, plim);
lcaPutSmart(drvlpv, -plim);
lcaPutSmart(loprpv, -plim);

%% pvs for reference orbit

pvs.ref.bpms(1) = script_setupPV('SIOC:SYS1:ML00:AO677', strcat(bpms(1), {' Y ref'}), 'mm',  4, mf);
pvs.ref.bpms(2) = script_setupPV('SIOC:SYS1:ML00:AO678', strcat(bpms(2), {' Y ref'}), 'mm',  4, mf);
pvs.ref.bpms(3) = script_setupPV('SIOC:SYS1:ML00:AO679', strcat(bpms(3), {' Y ref'}), 'mm',  4, mf);
pvs.ref.bpms(4) = script_setupPV('SIOC:SYS1:ML00:AO680', strcat(bpms(4), {' Y ref'}), 'mm',  4, mf);


%% reserve some unused PVs

%d = script_setupPV('SIOC:SYS1:ML00:AO683', 'TCAV reserved', 'arb',  0, mf);
d = script_setupPV('SIOC:SYS1:ML00:AO684', 'TCAV reserved', 'arb',  0, mf);
d = script_setupPV('SIOC:SYS1:ML00:AO685', 'TCAV reserved', 'arb',  0, mf);
d = script_setupPV('SIOC:SYS1:ML00:AO686', 'TCAV reserved', 'arb',  0, mf);
% d = script_setupPV('SIOC:SYS1:ML00:AO687', 'TCAV reserved', 'arb',  0, mf);

%% start main loop

% set initial state
[data, ts ] = lcaGetStruct(pvs, 0, 'double');
disp_log('Starting main loop.');

%tcavon = 0;
tcavon = data.in.tcav.tctl(1);
reforbit = zeros(size(pvs.in.bpms));
reforbit(:,2) = lcaGetSmart(pvs.ref.bpms);

lcaSetSeverityWarnLevel(5);

lcaSetMonitor(pvs.in.bpms(1));

while 1
     
    % Pause and increment watchdog
    
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog timer error');
        ok = 0;
        continue;
    end
    pause(data.in.delay);
    
%% save data from the last iteration and get new data

    old_data = data;
    old_ts   = ts;
    old_tcavon = tcavon;
    
    turnon = 0;  turnoff = 0;

    [data, ts] = lcaGetStruct(pvs, 0, 'double');
    
    
%% do some sanity checks

    ibpm = logical(data.in.bpm.enable);

    bpmok = all(all(abs(data.in.bpms(ibpm,1:2)) <= data.in.bpm_tol)) && ...
           all(all(data.in.bpms(ibpm,3) >= data.in.tmit_cut * 1e10)) && ...
           all(all(~isnan(data.in.bpms(ibpm,:))));
   
    rateok = data.in.beamrate > 0;
    
    newdata = all( ...
        lca2matlabTime(reshape(ts.in.bpms, 1, [])) > ...
        lca2matlabTime(reshape(old_ts.in.bpms, 1, [])));

    good = bpmok && rateok && newdata;
    
    data.stat.bpmok = bpmok;
    data.stat.rateok = rateok;
    data.stat.newdata = newdata;
    data.stat.good = good;
    
%% determine on/off change

    if ~isnan(data.in.tcav.tctl(1))
        tcavon = data.in.tcav.tctl(1);
        if tcavon && ~old_tcavon
            turnon = 1;  turnoff = 0;
            disp_log('TCAV turned on');
        elseif ~tcavon && old_tcavon
            turnon = 0;  turnoff = 1;
            disp_log('TCAV turned off');
        end
    else
        disp_log('TCAV trigger or something returned NAN');
        %save('~/nate/tcav_fb_data.mat', 'data');
        lcaPutStruct(pvs.stat, data.stat);
        continue;
    end
    
%% if beam volts goes away, lower ADES to prevent feedback from running away
    
    if data.in.ramp.enable
        if data.in.tcav.bvlt <= data.in.ramp.thresh
            % do something
        end
    end
    
    
%% if TCAV goes off -> on, save the last valid BPM data set as a reference

    if turnon
        reforbit = old_data.in.bpms;
        disp_log(sprintf('New BPM reference %.4f %.4f %.4f %.4f', ...
            reforbit(1,2), reforbit(2,2), reforbit(3,2), reforbit(4,2)));
        lcaPutSmart(pvs.ref.bpms, reforbit(:,2));
    continue;
    end


    
%% Find a new phase offset
    
    xorbit = (data.in.bpms(:,1) - reforbit(:,1))';
    yorbit = (data.in.bpms(:,2) - reforbit(:,2))';

    % phase error
    perr = -1 * charge * sign(data.in.tcav.pdes) * mean(yorbit(ibpm) ./ data.in.calib(ibpm));
    data.stat.perr = perr;

    % phase correction
    corr = data.in.gain * perr;
    data.stat.corr = corr;
    
    % new offset
    poc = data.out.poc + corr;
    data.stat.poc = poc;
    data.out.poc = data.stat.poc;
    
%% output status and phase offset if everything looks good
    
    if tcavon && good && data.in.enable
        data.stat.active = 1;
    else
        data.stat.active = 0;
    end
    
    % write out status
    lcaPutStruct(pvs.stat, data.stat);   
    
    % write out phase offset
    if data.stat.active && ~debug
        lcaPutStruct(pvs.out, data.out);
    end
    
end


