function facet_li10()
% FACET e+ LBCC energy feedback.
% N Lipkowitz, SLAC
% modify Dec-10-2015 for e-
% revert 3-mar-2016

% AIDA-PVA imports
global pvaRequest;

%% boilerplate
mf = strcat(mfilename, '.m');
disp_log(strcat(mf, {' starting, ver 1.1 12/10/2015'}));
debug = 0;

pvs.watchdog = {'SIOC:SYS1:ML00:AO050'};
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


%% config

bpms = { ...
    'BPMS:LI10:2448' ...   % for e+
%    'BPMS:LI10:3448' ...    % for e-
};

paus = { ...
    'LI09:PHAS:11'; ...    % for e+
    'LI09:PHAS:21'; ...
%   'LI09:PHAS:12'; ...      % for e-
%   'LI09:PHAS:22'; ...
};

klys = { ...
    'LI09:KLYS:11'; ...
    'LI09:KLYS:21'; ...
    };

knob = 'MKB:LI09SPPSENGYP.MKB'; % for e+
%knob = 'MKB:LI09SPPSENGY.MKB';  % for e-

dgrp = 'SDRFACET';     % for e+
%dgrp = 'SCAVSPPS';      % for e-

model_init('source', 'SLC');
% twiss = model_rMatGet(bpms, [], 'TYPE=DESIGN', 'twiss');
% energy = twiss(1);
% etax = twiss(5);
energy = 9;

etax = -.448; % for e+
%etax = +.448;  % for e-

tmit_min = 5e9;
xmax = 15; ymax = 15;
phase_max = 175;
phase_min = 5;

pvs.in.ampl = strcat(klys, ':ENLD');
pvs.in.phas = strcat(paus, ':VDES');
pvs.in.setpoint = script_setupPV('SIOC:SYS1:ML00:AO177', 'LI10 Energy setpoint', 'MeV', 1, mf);
pvs.in.enable = script_setupPV('SIOC:SYS1:ML00:AO185', 'LI10 Energy enable', 'bool', 0, mf);
pvs.in.gain = script_setupPV('SIOC:SYS1:ML00:AO178', 'LI10 Energy FB gain', 'arb', 3, mf);

pvs.in.rate = 'EVNT:SYS1:1:POSITRONRATE';  % for e+
%pvs.in.rate = 'EVNT:SYS1:1:SCAVRATE'; % for e-

pvs.out.eerr = script_setupPV('SIOC:SYS1:ML00:AO179', 'LI10 Energy error', 'MeV', 1, mf);
pvs.out.tmitok = script_setupPV('SIOC:SYS1:ML00:AO186', 'LI10 TMIT OK', 'bool', 0, mf);
pvs.out.bpmok = script_setupPV('SIOC:SYS1:ML00:AO187', 'LI10 BPM OK', 'bool', 0, mf);
pvs.out.actok = script_setupPV('SIOC:SYS1:ML00:AO188', 'LI10 Actuators OK', 'bool', 0, mf);

d = pvaRequest('MKB:VAL');
d.with('MKB', knob);

%% main loop

while 1

    pause(0.1);

    W = watchdog_run(W);
    switch get_watchdog_error(W)
        case 0
            % do nothing, this is OK
        case 1
            disp_log(strcat({'Another '}, mf, {' is running - exiting'}));
            return;
        case 2
            disp_log(strcat({'Error reading/writing '}, pvs.watchdog, {' - continuing anyway'}));
        otherwise
            disp_log(strcat({'Unexpected watchdog error'}));
    end

    data = lcaGetStruct(pvs);
%     if data.in.rate < 1, continue; end

    [x,y,tmit,pid,stat] = control_bpmAidaGet(bpms, 1, dgrp);

    eerr = energy * x / etax; % energy error in MeV
    data.out.eerr = eerr;
    err_E = data.in.setpoint - eerr;

    [phase, gain, total] = get_engy(paus);
    slope = total * -1 * sind(phase) / 90;
    d_phase = (err_E / slope) * data.in.gain;
    set_phase = phase + d_phase;

    ok = 1;
    if ~stat, ok = 0; end
    if isnan(x) || isnan(y) || isnan(tmit), ok = 0; end

    if tmit <= tmit_min
        disp('TMIT too low');
        data.out.tmitok = 0;
        ok = 0;
    else
        data.out.tmitok = 1;
    end

    if abs(x) > xmax || abs(y) > ymax
        disp('BPM value outside limits');
        data.out.bpmok = 0;
        ok = 0;
    else
        data.out.bpmok = 1;
    end


    if -set_phase > phase_max || ...
       -set_phase < phase_min
        disp(sprintf('I am railed, want %.2f', -set_phase));
        ok = 0;
        data.out.actok = 0;
    else
        data.out.actok = 1;
    end

    lcaPutStruct(pvs.out, data.out);

    if ok && data.in.enable
        out_phase = set_engy(d_phase, knob);
        disp(out_phase);
    end

    pause(1);
end

function [phase, gain, total] = get_engy(paus)

klys = {'KLYS:LI09:11'; 'KLYS:LI09:21'};
[m,p,u] = model_nameSplit(paus);
paus = strcat(p, ':', m, ':', u);

p1 = pvaGetM(strcat(paus{1}, ':VDES'));
p2 = pvaGetM(strcat(paus{2}, ':VDES'));

fphas = [p1; p2];

[act, stat, swrd, d, d, enld] = control_klysStatGet(klys);

accl = bitget(act, 1) .* ~bitget(swrd, 4);
ampl = enld .* accl .* cosd(fphas);

total = sum(enld .* accl);
phase = mean([-p1; p2]);
gain = sum(ampl);


function new_phase = set_engy(phase, knob)

    % AIDA-PVA imports
    global pvaRequest;

    persistent d;
    if isempty(d)
        d = pvaRequest('MKB:VAL');
        d.with('MKB', knob);
    end

    try
        answer = ML(d.set(phase));
        values = answer.values.value;
        new_phase = values(:);
    catch
        disp_log(strcat('AIDA error when setting ', knob));
        %new_phase = phase;
    end

