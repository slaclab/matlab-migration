function facet_sdr_fb()
% FACET SDR charge feedback


%% basic initialization
mf = strcat(mfilename, '.m');
disp_log(strcat(mf, {' starting, ver 1.0 3/28/2016'}));
debug = 0;
lcaSetSeverityWarnLevel(14);

%% start watchdog

pvs.watchdog = {'SIOC:SYS1:ML00:AO612'};
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

%% define some parameters

% runtime options
debug = 0; % display debug messages
delay = 1; % delay in seconds between iterations

% toroids into and out of SDR
toro_in  = 'TORO:DR01:1481';
toro_out = 'TORO:DR03:71';

% SLTR energy compressor
klys     = 'KLYS:DR01:1';

% SLTR energy compressor phase knob
multiknob = 'MKB:DR01_KLYS_PHASE.MKB';

%% define a PV struct for inputs

pvs.in.enable       = script_setupPV('SIOC:SYS1:ML00:AO403', ...
                    'SDR feedback enable',       'bool', 0, mf);
pvs.in.gain         = script_setupPV('SIOC:SYS1:ML00:AO404', ...
                    'SDR feedback gain',        'arb',  3, mf);
pvs.in.setpoint     = script_setupPV('SIOC:SYS1:ML00:AO405', ...
                    'SDR feedback setpoint',    'n e+', 3, mf);
pvs.in.q_min        = script_setupPV('SIOC:SYS1:ML00:AO406', ...
                    'SLTR charge min',          'n e-', 3, mf);
pvs.in.phas_max     = script_setupPV('SIOC:SYS1:ML00:AO407', ...
                    [klys ' phase max'],        'arb', 2, mf);
pvs.in.phas_min     = script_setupPV('SIOC:SYS1:ML00:AO408', ...
                    [klys ' phase min'],        'arb', 2, mf);
pvs.in.slope        = script_setupPV('SIOC:SYS1:ML00:AO409', ...
                    'SDR feedback slope',     '1e8 / degS', 2, mf);
pvs.in.spare        = script_setupPV('SIOC:SYS1:ML00:AO410', ...
                    'spare',     'egu', 0, mf);
pvs.in.spare        = script_setupPV('SIOC:SYS1:ML00:AO411', ...
                    'spare',     'egu', 0, mf);
pvs.in.spare        = script_setupPV('SIOC:SYS1:ML00:AO412', ...
                    'spare',     'egu', 0, mf);
pvs.in.spare        = script_setupPV('SIOC:SYS1:ML00:AO413', ...
                    'spare',     'egu', 0, mf);
pvs.in.spare        = script_setupPV('SIOC:SYS1:ML00:AO414', ...
                    'spare',     'egu', 0, mf);

pvs.rate.beam = 'EVNT:SYS1:1:BEAMRATE';
pvs.rate.scav = 'EVNT:SYS1:1:SCAVRATE';
pvs.rate.posi = 'EVNT:SYS1:1:POSITRONRATE';

pvs.temp      = 'MC00:ASTS:OUTSIDET';

pvs.toro.in  = 'DR01:TORO:1481:DATA';
pvs.toro.out = 'DR03:TORO:71:DATA';

klyroot = 'DR01:KLYS:1';
pvs.klys.ampl     = [klyroot ':AMPL'];
pvs.klys.phas     = [klyroot ':PHAS'];
pvs.klys.pdes     = [klyroot ':PDES'];


%% define a struct for ouputs

pvs.out.phase       = script_setupPV('SIOC:SYS1:ML00:AO415', ...
                    'Desired phase change', 'degS', 2, mf);
pvs.out.total       = script_setupPV('SIOC:SYS1:ML00:AO416', ...
                    'Cumulative phase change', 'degS', 2, mf);
pvs.out.tslope      = script_setupPV('SIOC:SYS1:ML00:AO417', ...
                    'OutsideT slope',       'degF', 3, mf);
pvs.out.enable      = script_setupPV('SIOC:SYS1:ML00:AO418', ...
                    'Feedback active',      'bool', 0, mf);
pvs.msgstring       = 'SIOC:SYS1:ML00:CA003';  lcaPutSmart(strcat(pvs.msgstring, '.DESC'), mf);

%% set up compressor knob

mkbPV = 'MKB:VAL';
mkbRequestBuilder = pvaRequest(mkbPV);
mkbRequestBuilder.with('MKB', multiknob);

%
% mkbPV = AssignMultiknob(multiknob);
% global mkbRequestBuilder;

%% first iteration stuff

[data, ts] = lcaGetStruct(pvs);
tmit = [0, 0];
total = 0;

%% main loop starts here

disp_log('Main loop starting.');
while 1

    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog error - exiting');
        break;  % Exit program
    end

%% get some fresh data

    old = data;  oldts = ts;  oldtmit = tmit;

    [data, ts] = lcaGetStruct(pvs);
    tmit(1) = data.toro.in;
    tmit(2) = data.toro.out;
    % use below instead for buffered acquisition
    %     tmit(1) = control_bpmAidaGet('TORO:DR01:1481', 1, 'SCAVPOSI');
    %     tmit(2) = control_bpmAidaGet('TORO:DR03:71', 1, 'SCAVPOSI');

%% check for communication broken and bail out if found

    good = 1;
    if any(structfun(@isnan, data.klys))
        disp_log(strcat({'Error getting data from '}, klys));
        good = good && 0;
    end
    if any([structfun(@isnan, data.in); structfun(@isnan, data.out)])
        disp_log('Error getting SIOC:SYS1:ML00 PVs');
        good = good && 0;
    end
    if any(isnan(tmit))
        disp_log('Error getting TORO data');
        good = good && 0;
    end
    if ~good
        lcaPutSmart(pvs.out.enable, 0);
        continue;
    end

%% only actuate if new tmit data

    if oldtmit(2) - tmit(2) == 0
        lcaPutSmart(pvs.out.enable, 0);
        continue;
    else
        disp_log(sprintf('Got some new data:  %.3g\t%.3g\n', tmit(1), tmit(2)));
    end

%% check everything is within limits

    msg = [];

    % feedback disabled
    if ~data.in.enable
        good = good && 0; msg = [msg, sprintf('Disabled by user\n')];
    end

    % beam charge below limit
    if (tmit(2) < data.in.q_min)
        good = good && 0; msg = [msg, sprintf('%s below limit of %.3g\n', pvs.toro.out, data.in.q_min)];
    end

    % phase readback out of limit
    if (data.klys.phas > data.in.phas_max)
        good = good && 0; msg = [msg, sprintf('%s above limit of %.2f\n', pvs.klys.phas, data.in.phas_max)];
    end
    if (data.klys.phas < data.in.phas_min)
        good = good && 0; msg = [msg, sprintf('%s below limit of %.2f\n', pvs.klys.phas, data.in.phas_min)];
    end

    if good, msg = 'Running, all OK'; end


%% calculate knob set

    pdes = (data.in.setpoint - tmit(2) ) / data.in.slope;
    knob_set = data.in.gain * pdes;

%% write PVs out

    out = data.out;
    out.phase = pdes;
    out.total = total;
    out.tslope = 0;
    out.enable = good;
    lcaPutStruct(pvs.out, out);
    disp_msg(pvs.msgstring, msg);

%% actually write the knob output

    if ~debug && good
        total = total + knob_set;
        disp_log(sprintf('Writing %.3f to knob', knob_set));
        mkbRequestBuilder.set(knob_set);
    end

end

function disp_msg(strpv, msg)
    marray = zeros(1000,1);
    marray(1:numel(char(msg))) = double(char(msg));
    lcaPutSmart(strpv, double(msg));
