% Original version by N. Lipkowitz March 2012
%
% Version 2:
% File updated for FACET-II. Main change is to the config file. Also, force
% beam = 2 (NDRFACET, 57)
% S. Gessner June 20, 2020
%
% Major revision. Only keep FACET-II BGRP/MEASDEF
% S. Gessner June 23, 2020

function facet_BPM_repeater()

% determine script name
scr = strcat(mfilename, {'.m'});

% set loop speed (1/rate)
loopdelay = 0;

% log startup
disp_log(strcat(scr, {', ver. 2.1 6/20/21'}));

% start watchdog
watchdog_pv = 'PHYS:SYS1:1:BPMRPTR';
W = watchdog(watchdog_pv, 1, scr);
switch get_watchdog_error(W)
    case 1
        disp_log(strcat({'Another '}, scr, {' is running - exiting'}));
        return;
    case 2
        disp_log(strcat({'Error reading/writing '}, watchdog_pv, {' - exiting'}));
        return;
    otherwise
        disp_log(strcat({'Watchdog started on '}, watchdog_pv));
end

% define some beams
bpmd = '57';
dgrp = 'FACET-II';

% set up AIDA acquisition

da.setParam('BPMD',char(bpmd));


% control PV definitions
pvs.in = {...
    'EVNT:SYS1:1:SCAVRATE'; ...    % ELECEP01 beam rate
    'EVNT:SYS1:1:BEAMRATE'; ...    % NDRFACET beam rate
    char(script_setupPV('SIOC:SYS1:ML00:AO102', 'Enable/disable BPM repeater', 'on/off', 1, scr)); ...     % enable/disable
    char(script_setupPV('SIOC:SYS1:ML00:AO103', 'Loop delay', 'sec', 2, scr)); ...
    char(script_setupPV('SIOC:SYS1:ML00:AO104', 'Preferred beam (8 or 57)', 'num', 0, scr));
    char(script_setupPV('SIOC:SYS1:ML00:AO105', 'Beam rate threshold', 'Hz', 0, scr));
    };

pvs.out = {
    char(script_setupPV('SIOC:SYS1:ML00:AO106', 'Actual acquisition time', 'sec', 2, scr));
    char(script_setupPV('SIOC:SYS1:ML00:AO107', 'Acquisition ok', 'bool', 0, scr));
    char(script_setupPV('SIOC:SYS1:ML00:AO108', 'Last acquisition (8 or 57)', 'num', 0, scr));
    char(script_setupPV('SIOC:SYS1:ML00:AO109', 'Rate high enough', 'bool', 0, scr));
    };

% set up bpm PV list
bpms = util_configLoad(mfilename, 0);
bpm_list = bpms.roots2; % roots2 is list of FACET-II BPMs
nbpms = numel(bpm_list);

attribs = {'X', 'Y', 'TMIT', 'HSTA', 'STAT'}; % everything except Z

disp_log('Initializing PV list...');

pvs.bpms = [];
for attrib = attribs
    pvs.bpms = [pvs.bpms; strcat(bpm_list,{':'},attrib, bpmd)];
end


disp_log('Script running!');

%main loop
while 1

    %increment watchdog counter
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Watchdog error - exiting');
        break;  % Exit program
    end

    pause(loopdelay);


    % get controls
    try
        [ctrl.val, ctrl.ts] = lcaGetSmart(pvs.in, 0, 'double');
        [stat.val, stat.ts] = lcaGetSmart(pvs.out, 0, 'double');
    catch
        disp_log('lcaGet of control PVs failed.  :(');
        pause(3);
        continue;
    end

    if any(isnan(ctrl.val))
        disp_log(strcat({'Cannot connect to '}, pvs.in(isnan(ctrl.val))));
        pause(3);
        continue;
    end


    % update controls
    enable = ctrl.val(3);
    loopdelay = ctrl.val(4);
    preferred = ctrl.val(5);
    min_rate = ctrl.val(6);

    % do nothing if disabled
    if ~enable
        continue
    end

    % zero all readback if not enough rate
    fast_enough = ctrl.val(1:2) >= min_rate;
    if ~any(fast_enough)
        lcaPutSmart(pvs.bpms, zeros(nbpms * numel(attribs), 1));
        stat.val(4) = 0;
        lcaPutSmart(pvs.out(4), stat.val(4));
        continue
    end



    % zero out all output data
    outvals = zeros(nbpms * numel(attribs), 1);


    % get BPM data from AIDA
    t0 = datevec(now);
    try
        acq_ok = 1;
        data = pvaGet(char(strcat(dgrp, {':BPMS'})));
    catch
        % zero everything
        acq_ok = 0;
    end
    acq_time = etime(datevec(now), t0);


    % output 'last acquisition' stuff
    stat.val(1) = acq_time;
    stat.val(2) = acq_ok;
    stat.val(3) = str2int(char(bpmd));
    try
        lcaPut(pvs.out, stat.val);
    catch
        disp_log('lcaPut of status PVs failed.  :(');
        pause(3);
        continue
    end


    % extract BPM data from java into matlab

    if acq_ok
        outvals((nbpms * 0) + (1:nbpms)) = toArray(data.get('x'));
        outvals((nbpms * 1) + (1:nbpms)) = toArray(data.get('y'));
        outvals((nbpms * 2) + (1:nbpms)) = toArray(data.get('tmits'));
        outvals((nbpms * 3) + (1:nbpms)) = toArray(data.get('hsta'));
        outvals((nbpms * 4) + (1:nbpms)) = toArray(data.get('stat'));
    end

    try
        lcaPut(pvs.bpms, outvals);
    catch
        disp_log('lcaPut of BPM PVs failed.  :(');
        pause(3);
        continue
    end


end
