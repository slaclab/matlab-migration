function facet_energy()
% FACET energy feedback.  Controls FACET energy, requires at least 1 Hz to
% EP01
% version 2
% N Lipkowitz, SLAC

%% Startup

mf = strcat(mfilename, '.m');
disp_log(strcat(mf, {' starting, ver 1.20 11/18/2015'}));
debug = 0;

%% Init and start watchdog

pvs.watchdog = {'SIOC:SYS1:ML00:AO051'};  % change this
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

%% Control/Status PVs

pvs.in.rate         = 'EVNT:SYS1:1:SCAVRATE';

pvs.in.enable       = script_setupPV('SIOC:SYS1:ML00:AO052', ...
                        'Global On/Off',        'bool',     0, mf);
pvs.in.delay        = script_setupPV('SIOC:SYS1:ML00:AO053', ...
                        'Wait time',            's',        2, mf);
pvs.in.gain.p       = script_setupPV('SIOC:SYS1:ML00:AO054', ...
                        'Global gain (prop)',   'arb',      3, mf);
pvs.in.min_tmit     = script_setupPV('SIOC:SYS1:ML00:AO055', ...
                        'Minimum TMIT',         '1e9 e-',   3, mf);
pvs.in.restore_acts = script_setupPV('SIOC:SYS1:ML00:AO056', ...
                        'Restore Actuators',    'bool',     0, mf);
pvs.in.update_acts  = script_setupPV('SIOC:SYS1:ML00:AO057', ...
                        'Update Act Refs',      'bool',     0, mf);
pvs.in.setpoint     = script_setupPV('SIOC:SYS1:ML00:AO061', ...
                        'EP01 Energy setpoint', 'MeV',      2, mf);
pvs.in.enable2      = script_setupPV('SIOC:SYS1:ML00:AO060', ...
                        'EP01 Energy enable',   'bool',     0, mf);
pvs.in.act_ref      = script_setupPV('SIOC:SYS1:ML00:AO068', ...
                        'SCAVENGY Act Ref',     'degS',      2, mf);

pvs.out.state(1)    = script_setupPV('SIOC:SYS1:ML00:AO070', ...
                        'EP01 X Pos State',     'mm',       2, mf);
pvs.out.state(2)    = script_setupPV('SIOC:SYS1:ML00:AO071', ...
                        'EP01 X Ang State',     'mrad',     2, mf);
pvs.out.state(3)    = script_setupPV('SIOC:SYS1:ML00:AO072', ...
                        'EP01 Y Pos State',     'mm',       2, mf);
pvs.out.state(4)    = script_setupPV('SIOC:SYS1:ML00:AO073', ...
                        'EP01 Y Ang State',     'mrad',     2, mf);
pvs.out.state(5)    = script_setupPV('SIOC:SYS1:ML00:AO063', ...
                        'EP01 Energy State',    'MeV',      2, mf);
pvs.out.tmit        = script_setupPV('SIOC:SYS1:ML00:AO176', ...
                        'TMIT Average',         '1e9 e-',   3, mf);
pvs.out.command     = script_setupPV('SIOC:SYS1:ML00:AO064', ...
                        'SCAVENGY Command',     'degS',     2, mf);
pvs.out.delta       = script_setupPV('SIOC:SYS1:ML00:AO065', ...
                        'SCAVENGY Delta',       'degS',     2, mf);
pvs.out.val         = script_setupPV('SIOC:SYS1:ML00:AO066', ...
                        'SCAVENGY Value',       'degS',     2, mf);
pvs.out.ampl        = script_setupPV('SIOC:SYS1:ML00:AO067', ...
                        'SCAVENGY E Gain',      'MeV',      2, mf);
pvs.out.acq_time    = script_setupPV('SIOC:SYS1:ML00:AO173', ...
                        'Acquisition Time',     's',        2, mf);
pvs.out.acq_ok      = script_setupPV('SIOC:SYS1:ML00:AO174', ...
                        'Acquisition OK',       'bool',     0, mf);
pvs.out.data_ok     = script_setupPV('SIOC:SYS1:ML00:AO175', ...
                        'Data OK',              'bool',     0, mf);
pvs.out.eend        = script_setupPV('SIOC:SYS1:ML00:AO069', ...
                        'LEMG EEND',            'GeV',      3, mf);
%% Loop Configuration

dgrp = 'ELECEP01';          % DGRP for SCAV beam
loc  = 'BPMS:EP01:175';     % BPMS for fit location
bpms = {                    % BPMS for orbit fitting
    'BPMS:LI19:201'
    'BPMS:LI19:301'
    'BPMS:LI19:401'
    'BPMS:LI19:501'
%     'BPMS:LI19:601'
%     'BPMS:LI19:701'
     'BPMS:EP01:175'
%    'BPMS:EP01:185'
%     'BPMS:EP01:204'
%     'BPMS:EP01:210'
    };
nsamp = 1;
min_tmit = 2e9;             % TMIT threshold, # e-
max_orbit = 10;              % orbit threshold, mm
lim.high = -5;
lim.low  = -175;

%% Load the model etc prep for orbit fit

% model RMATs etc from
model_init('source', 'SLC');
[rmat, z, leff, twiss]= ...
    model_rMatGet(bpms, loc, {'TYPE=DATABASE' 'MODE=1'});

% reference trajectory
[x, y, tmit, pulseId, stat, x0, y0] = deal(zeros([numel(bpms) nsamp]));
[x00, y00] = control_bpmAidaGet(bpms, nsamp, dgrp);
%
% x0 = x00;
% y0 = y00;


%% ********* Main Loop starts here *************

[data, ts] = lcaGetStruct(pvs);

while 1

% clear the sanity-check flag and pause

    ok = 1;
    pause(data.in.delay);

%% Increment watchdog counter and pause

    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog timer error');
        ok = 0;
        continue;
    end

%% Get some fresh data

    % Get the EPICS controls
    olddata = data;  oldts = ts;        % store the old data
    [data, ts] = lcaGetStruct(pvs);     % get some new stuff

    % Clear the flags
    data.out.acq_ok = 1;  data.out.data_ok = 1;

    % Get the AIDA orbit (only if there's rate)
    if data.in.rate > 0
        tic;
        [x, y, tmit, pulseId, stat] = control_bpmAidaGet(bpms, nsamp, dgrp);
        data.out.acq_time = toc;
    else
        data.out.acq_ok = 0;
        data.out.acq_time = 0;
        ok = 0;
    end

    % Get the LI17-LI18 phases
    [phase, gain, total] = get_scavengy();

    % Extract the model energy from LEMG
    lemg = model_energySetPoints;
    energy = lemg(end) * 1e3; % in MeV
    data.out.eend = lemg(end);

%% Save actuators if save pressed
    if data.in.update_acts
        [ref_phase, ref_gain, ref_total] = get_scavengy();
        lcaPutSmart(pvs.in.act_ref, ref_phase);
        disp_log(sprintf('Saving act ref = %.3f', ref_phase));
        lcaPutSmart(pvs.in.update_acts, 0);
        continue;
    end

%% Restore actuators if reset pressed

    if data.in.restore_acts
        current_phase = get_scavengy();
        restore_phase = data.in.act_ref - current_phase;
        out_phase = set_scavengy(restore_phase);
        lcaPutSmart(pvs.in.restore_acts, 0);
        continue;
    end

%% Check orbit data for reasonable-ness

% TODO add messages here?
    badstat = bpms(stat==0);
    if any(any(stat == 0))
        data.out.data_ok = 0;
        ok = 0;
        if data.in.rate > 0
            disp_log(deblank(sprintf('BPMS with bad STAT: %s\n', badstat{:})));
        end
    end

    data.out.tmit = 1e-9 * mean(mean(tmit));
    badtmit = bpms(tmit < data.in.min_tmit);
    if any(any(tmit < data.in.min_tmit))
        data.out.data_ok = 0;
        ok = 0;
        if data.in.rate > 0
            disp_log(deblank(sprintf('BPMS with low TMIT: %s\n', badtmit{:})));
        end
    end

    badorbit = x > max_orbit | y > max_orbit;
    if any(any(x > max_orbit)) || any(any(y > max_orbit))
        data.out.data_ok = 0;
        ok = 0;
        if data.in.rate > 0
            disp_log(deblank(sprintf('BPMS with large orbit: %s\n', badorbit{:})));
        end
    end

%%  Fit the orbit

    % run the orbit fitter
    [xfit, yfit, p, dp, chisq, q, v] = ...
        xy_traj_fit(x', 1, y', 1, x0', y0', ...
        squeeze(rmat(1, [1 2 3 4 6], :))', ...
        squeeze(rmat(3, [1 2 3 4 6], :))');

    % extract fitted energy offset at "loc" BPMS
    data.out.state = p;
    fit_E = p(5) * energy / 1000;
    data.out.state(5) = fit_E;
    err_E = data.in.setpoint - fit_E;

    % old calculation for reference
    eta_EP01_185_X = -280;  % in mm
    energy_EP01_185_X = 20.9 * 1000; % MeV
    old_E = x(1) * energy_EP01_185_X / eta_EP01_185_X;

%     % w.r.t ref orbit x00 y00
%     [xfit, yfit, p, dp, chisq, q, v] = ...
%         xy_traj_fit(x', 1, y', 1, x00', y00', ...
%         squeeze(rmat(1, [1 2 3 4 6], :))', ...
%         squeeze(rmat(3, [1 2 3 4 6], :))');
%     ref_E = energy * p(5) / 1000;
%     lcaPut('SIOC:SYS1:ML00:AO062', ref_E);

%% Feed forward if setpoint change

    d_setpoint = data.in.setpoint - olddata.in.setpoint;
    if d_setpoint ~= 0
        disp_log(sprintf('Setpoint changed from %.3f to %.3f', ...
            olddata.in.setpoint, data.in.setpoint));
        err_E = d_setpoint;
        data.in.gain.p = 1;
    end


%% Calculate new scavengy

    slope = total * -1 * sind(phase) / 90; % local slope MeV/degree
    if debug, disp(sprintf('Phase = %.3f \t Slope = %.3f', phase, slope)); end
    d_phase = (err_E / slope) * data.in.gain.p;
    set_phase = phase + d_phase;
    if debug, disp(sprintf('d=%.3f \tset=%.3f', d_phase, set_phase)); end

    if set_phase > lim.high || set_phase < lim.low
        ok = 0;
    end

    data.out.val = gain;
    data.out.ampl = total;
    data.out.delta = d_phase;
    data.out.command = set_phase;

%% Output loop diagnostic stuff

    lcaPutStruct(pvs.out, data.out);

%% Set the energy knob

    if data.in.enable && data.in.enable2 && ok
        out_phase = set_scavengy(d_phase);
    end


end

function [phase, gain, total] = get_scavengy()

    % figure out how strong 17/18 are
    k17 = strcat({'17-'}, {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'});
    k18 = strcat({'18-'}, {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'});

    p17 = pvaGet('AMPL:EP01:171:VDES');
    p18 = pvaGet('AMPL:EP01:181:VDES');

    phas = control_phaseGet([k17; k18]);
    fphas = [(phas(1:8) + p17); (phas(9:16) + p18)];

    [acts, stat, swrd, d, d, enld] = control_klysStatGet([k17; k18], 10);
    accl = bitget(acts, 1) .* ~bitget(swrd, 4);
    ampl = enld .* accl .* cosd(fphas);

    total = sum(enld .* accl .* cosd(phas));
    phase = mean([-p17; p18]);
    gain = sum(ampl);

function new_phase = set_scavengy(phase)


    try
        d = pvaRequest('MKB:VAL');
        d.with('MKB', 'MKB:SCAVENGY.MKB');
        results = d.set(phase);
        values = toArray(results.get('value'));
        new_phase = values(:);
    catch
        disp_log('AIDA error when setting SCAVENGY');
        new_phase = phase;
    end
