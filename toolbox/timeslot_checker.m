function timeslot_checker()

%% startup business

% determine script name
scr = strcat(mfilename, {'.m'});

% set loop speed (1/rate)
loopdelay = 0.1;

% log startup
disp_log(strcat(scr, {', ver. 1.14 11/08/11'}));

% start watchdog
watchdog_pv = 'SIOC:SYS0:ML01:AO250';
W = watchdog(watchdog_pv, ceil(1/loopdelay), scr);
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

% write hostname into watchdog comment
d = {':'};
[prim micr unit secn] = model_nameSplit(watchdog_pv);
watchdog_comment = strcat(prim, d, micr, d, unit, d, strrep(secn, 'AO', 'SO0'));
lcaPutSmart(watchdog_comment, getenv('HOSTNAME'));

% suppress severity warnings
lcaSetSeverityWarnLevel(5);

  
%% constants and PV definitions

% # of values to average over
n_avg = 100;

% feedback gain
gain = 0.05;

% compression scale (A/degS) roughly
chirp_scale.BC1 = -50;
chirp_scale.BC2 = -1000;

% tmit cut
tmitcut = 3e7;

edef_pvs = {'SIOC:SYS0:ML00:AO867'; ...
            'SIOC:SYS0:ML00:AO868'; ...
            'SIOC:SYS0:ML00:AO869'; ...
            'SIOC:SYS0:ML00:AO870'};

%% setup feedback control PVs

ctrlpvs = {
    script_setupPV(281, 'Feedback enable', 'on/off', 0, scr, 'SYS0', 'ML01'); ...
    script_setupPV(282, 'Feedback gain', ' ', 3, scr, 'SYS0', 'ML01'); ...
    script_setupPV(283, 'Feedback rate', 'Hz', 3, scr, 'SYS0', 'ML01'); ...
    'SIOC:SYS0:ML00:AO044'; ...         % BC2 peak current setpoint
    'SIOC:SYS0:ML00:AO290'; ...         % DL1 energy enable
    'SIOC:SYS0:ML00:AO292'; ...         % BC1 energy enable
    'SIOC:SYS0:ML00:AO293'; ...         % BC1 current enable
    'SIOC:SYS0:ML00:AO294'; ...         % BC2 energy enable
    'SIOC:SYS0:ML00:AO295'; ...         % BC2 current enable
    'SIOC:SYS0:ML00:AO296'; ...         % DL2 energy enable
    'ACCL:LI22:1:A_NOFS'; ...           % L2 total amplitude
    };

%% setup measurement PVs

% these EDEF numbers should be exclusion/inclusion masked identically to DS0, DS1, DS2 and
% DS3 respectively
edefs = reshape(cellstr(num2str(lcaGetSmart(edef_pvs),'%-2d')), 1, []);
%edefs = {'4', '5', '14', '15'};

% make sure they're turned on, bail out if not
% TODO possibly should check for proper masking here too
edefon = lcaGetSmart(strcat({'EDEF:SYS0:'}, edefs', {':CTRL'}), 0, 'double');
if ~all(edefon)
    not_on = edefs(find(~edefon));
    disp_log(strcat({'EDEF '}, not_on, ' is not on - check EDEF setup - exiting'));
    return;
end

% set up PV names for actuators
baseacts = {
    'ACCL:IN20:400:L0B_ADES';
    'ACCL:LI21:1:L1S_ADES';
    'ACCL:LI21:1:L1S_PDES';
    'ACCL:LI22:1:ADES';
    'ACCL:LI22:1:PDES';
    'ACCL:LI25:1:ADES';
    };

actpvs.ds1 = strcat(baseacts, {':OFFSET_1'});
actpvs.ds2 = strcat(baseacts, {':OFFSET_2'});
actpvs.ds3 = strcat(baseacts, {':OFFSET_3'});

actpvs = [actpvs.ds1; actpvs.ds2; actpvs.ds3];

% input PVs to compare go here
basepvs = {
    'BPMS:IN20:731:X';      % DL1 energy
    'BPMS:LI21:233:X';      % BC1 energy
    'BLEN:LI21:265:AIMAX';  % BC1 current
    'BPMS:LI24:801:X';      % BC2 energy
    'BLEN:LI24:886:BIMAX';  % BC2 current
    'BPMS:LTU1:250:X';      % DL2 energy
 %   'BPMS:IN20:221:TMIT';   % charge
 %   'ACCL:LI21:1:L1S_P'     % L1S phase
    % add more here
    };

basetmitpvs = {
    'BPMS:IN20:731:TMIT';      % DL1 energy
    'BPMS:LI21:233:TMIT';      % BC1 energy
    'BPMS:LI24:801:TMIT';      % BC2 energy
    'BPMS:LTU1:250:TMIT';      % DL2 energy
    };

inpvs = [];
tmitpvs = [];
% construct BSA PV names = base PV + edef
for edef = edefs
    inpvs = [inpvs; strcat(basepvs, edef)];
    tmitpvs = [tmitpvs; strcat(basetmitpvs, edef)];
end

allpvs = [inpvs; tmitpvs];

%% setup output PVs
outpvs.ds1 = { ...
    script_setupPV(251, 'DL1 energy  (DS0 - DS1)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(252, 'BC1 energy  (DS0 - DS1)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(253, 'BC1 current (DS0 - DS1)', 'A',   2, scr, 'SYS0', 'ML01');
    script_setupPV(254, 'BC2 energy  (DS0 - DS1)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(255, 'BC2 current (DS0 - DS1)', 'A',   2, scr, 'SYS0', 'ML01');
    script_setupPV(256, 'DL2 energy  (DS0 - DS1)', 'MeV', 2, scr, 'SYS0', 'ML01'); 
 %   script_setupPV(257, 'TMIT (DS0 - DS1)',        'n_el', 2, scr, 'SYS0', 'ML01');
 %   script_setupPV(258, 'L1S phase (DS0 - DS1)',   'degS', 2, scr, 'SYS0', 'ML01')
    % add more here
    };

outpvs.ds2 = { ...
    script_setupPV(261, 'DL1 energy  (DS0 - DS2)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(262, 'BC1 energy  (DS0 - DS2)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(263, 'BC1 current (DS0 - DS2)', 'A',   2, scr, 'SYS0', 'ML01');
    script_setupPV(264, 'BC2 energy  (DS0 - DS2)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(265, 'BC2 current (DS0 - DS2)', 'A',   2, scr, 'SYS0', 'ML01');
    script_setupPV(266, 'DL2 energy  (DS0 - DS2)', 'MeV', 2, scr, 'SYS0', 'ML01');
%    script_setupPV(267, 'TMIT (DS0 - DS2)',        'n_el', 2, scr, 'SYS0', 'ML01');
%    script_setupPV(268, 'L1S phase (DS0 - DS2)',   'degS', 2, scr, 'SYS0', 'ML01')
    % add more here
    };

outpvs.ds3 = { ...
    script_setupPV(271, 'DL1 energy  (DS0 - DS3)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(272, 'BC1 energy  (DS0 - DS3)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(273, 'BC1 current (DS0 - DS3)', 'A',   2, scr, 'SYS0', 'ML01');
    script_setupPV(274, 'BC2 energy  (DS0 - DS3)', 'MeV', 2, scr, 'SYS0', 'ML01');
    script_setupPV(275, 'BC2 current (DS0 - DS3)', 'A',   2, scr, 'SYS0', 'ML01');
    script_setupPV(276, 'DL2 energy  (DS0 - DS3)', 'MeV', 2, scr, 'SYS0', 'ML01');
%    script_setupPV(277, 'TMIT (DS0 - DS3)',        'n_el', 2, scr, 'SYS0', 'ML01') 
%    script_setupPV(278, 'L1S phase (DS0 - DS3)',   'degS', 2, scr, 'SYS0', 'ML01')
    % add more here
    };

%% set up empty circular buffer
buffer = zeros(numel(basepvs), numel(edefs) - 1, n_avg);

%% initial data collection

% get all BSA PVs
[rawdata, ts] = lcaGetSmart(allpvs, 0, 'double');
data = reshape(rawdata(1:numel(inpvs)), numel(basepvs), numel(edefs));
tmit = reshape(rawdata((numel(inpvs) + 1):(numel(inpvs) + numel(tmitpvs))), numel(basetmitpvs), numel(edefs));
ts = lca2matlabTime(ts);
data_ts = reshape(ts(1:numel(inpvs)), numel(basepvs), numel(edefs));
tmit_ts = reshape(ts((numel(inpvs) + 1):(numel(inpvs) + numel(tmitpvs))), numel(basetmitpvs), numel(edefs));

pause(0.2);
count = 0;

%% main loop here

while 1
    % reset bad data flag
    bad_data = 0;
    
    % refresh energies for proper scaling
    ref_energies = model_energySetPoints();
    
    % recalculate energy scaling (MeV/mm)
    eta.DL1 = -135/263;
    eta.BC1 = -250/231;
    eta.BC2 = -ref_energies(4)*1000/362;
    eta.DL2 = ref_energies(5)*1000/120.7;
    
    % refresh control PVs
    ctrls = lcaGetSmart(ctrlpvs, 0, 'double');

    if ~any(isnan(ctrls))
        enable  = ctrls(1) == 1;
        enables = ctrls(5:10) == 1;
        gain    = ctrls(2);
        L2ampl  = ctrls(11);
        if loopdelay  % prevent divide by zero
            loopdelay = 1/ctrls(3);
        else
            loopdelay = 1;
        end
    end
    
    % loop wait
    pause(loopdelay);

    % increment watchdog counter
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Watchdog error - exiting');
        break;  % Exit program
    end
    
    % increment circular buffer counter
    count = mod(count, n_avg) + 1;
    
    % store previous PVs
    olddata = data;
    oldtmit = tmit;
    oldts = ts;
    olddata_ts = data_ts;
    oldtmit_ts = tmit_ts;

    % get all BSA PVs
    [rawdata, ts] = lcaGetSmart(allpvs, 0, 'double');
    data = reshape(rawdata(1:numel(inpvs)), numel(basepvs), numel(edefs));
    tmit = reshape(rawdata((numel(inpvs) + 1):(numel(inpvs) + numel(tmitpvs))), numel(basetmitpvs), numel(edefs));
    ts = lca2matlabTime(ts);
    data_ts = reshape(ts(1:numel(inpvs)), numel(basepvs), numel(edefs));
    tmit_ts = reshape(ts((numel(inpvs) + 1):(numel(inpvs) + numel(tmitpvs))), numel(basetmitpvs), numel(edefs));
    
    % flag to check for bad data
    if any(any(isnan(data)))
        bad = find(any(isnan(data), 2));
        good = find(~any(isnan(data), 2));
        bad_input = basepvs(bad);
        %disp_log(strcat({'Unable to connect to '}, bad_input));
    end
    
    % flag to update only if 120 Hz
    newflags = data_ts > olddata_ts;
    newdiffs = zeros(numel(basepvs),numel(edefs) - 1);
    for ix = 1:3
        newdiffs(:,ix) = newflags(:,1) & newflags(:,ix+1);
    end
    
    isnew = all(all(data_ts > olddata_ts));
    
    % apply scale factors
    data(1,:) = data(1,:) * eta.DL1;
    data(2,:) = data(2,:) * eta.BC1;
    data(4,:) = data(4,:) * eta.BC2;
    data(6,:) = data(6,:) * eta.DL2;

    % overwrite measurements with NaN if BPMs see no beam
    no_tmit = any((tmit < tmitcut), 2);
    if no_tmit(1), data(1,:)   = NaN; end
    if no_tmit(2), data(2:3,:) = NaN; end
    if no_tmit(3), data(4:5,:) = NaN; end
    if no_tmit(4), data(6,:)   = NaN; end
         
    % calculate data slot diffs here
    diffs(:, 1:3) = repmat(data(:, 1), 1, 3) - data(:, 2:4);
        
    if isnew
        % store in rolling average buffer
        buffer(:, :, count) = diffs;
    end
    
    buffavg = mean(buffer, 3);
    good_data = any(isnan(buffavg), 2);
    
    % output statistics
    lcaPutSmart(outpvs.ds1, buffavg(:,1));
    lcaPutSmart(outpvs.ds2, buffavg(:,2));
    lcaPutSmart(outpvs.ds3, buffavg(:,3));
    
    % feedback actuation here - only after refilling buffer and only if 120
    % Hz
    
    if enable && (count == n_avg) && isnew
        
        oldacts = lcaGetSmart(actpvs);
        oldacts = reshape(oldacts, numel(baseacts), []);

        % calculate changes to offsets
        
        deltas(1,:) = buffavg(1,:) * gain;
        deltas(2,:) = buffavg(2,:) * gain;
        deltas(3,:) = buffavg(3,:) * gain / chirp_scale.BC1;
        deltas(4,:) = buffavg(4,:) * gain;
        deltas(5,:) = buffavg(5,:) * gain / chirp_scale.BC2 * sign(ctrls(4));
        deltas(6,:) = buffavg(6,:) * gain;

        
        
        % add changes to old offsets
        newacts = oldacts + (deltas .* repmat(enables, 1, 3));
        newacts = reshape(newacts, [], 1);
        
        % only output things that are ~NaN
        notnans = find(~isnan(newacts));
        
        % output new offsets
        lcaPutSmart(actpvs(notnans), newacts(notnans));
    end
    
end % end main loop

end