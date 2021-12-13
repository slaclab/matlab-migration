function L23_set_phase()
% L23_set_phase.m

delay = 1; % delay per loop

W = watchdog('SIOC:SYS0:ML00:AO076', 1, 'phase_control');
if get_watchdog_error(W)
  disp('L23_set_phase is already running');
  return
end

disp_log('Starting L23_set_phase.m 2/19/2011 v3.3');

% set up some matlab PVs - these are for output

out = pl_create();
out = pl_add_ML00(out, 270, 'L2 energy',                    'MeV',  1);
out = pl_add_ML00(out, 271, 'L3 flat energy',               'MeV',  1);
out = pl_add_ML00(out, 272, 'L2 fudge',                     '',     4);
out = pl_add_ML00(out, 273, 'L3 flat fudge',                '',     4);
out = pl_add_ML00(out, 274, 'L2 effective phase',           'degS', 1);
out = pl_add_ML00(out, 275, 'L2 total energy',              'MeV',  1);
out = pl_add_ML00(out, 276, 'L2 flat energy',               'MeV',  1);
out = pl_add_ML00(out, 277, 'L2 flat fudge',                '',     4);
out = pl_add_ML00(out, 278, 'L2 nofb flat total energy',    'MeV',  1);
out = pl_add_ML00(out, 279, 'L3 nofb flat total energy',    'MeV',  1);
out = pl_add_ML00(out, 280, 'S29 flat energy',              'MeV',  1);
out = pl_add_ML00(out, 281, 'S30 flat energy',              'MeV',  1);
out = pl_add_ML00(out, 282, 'L2 stations on',               '',     0);
out = pl_add_ML00(out, 283, 'L3 stations on',               '',     0);
out = pl_add_ML00(out, 284, 'L2 feedback strength',         'ratio',4);
out = pl_add_ML00(out, 285, 'L3 feedback strength',         'ratio',4);
out = pl_add_ML00(out, 286, 'BC2 nominal energy',           'MeV',  1);
out = pl_add_ML00(out, 287, 'PR55 nominal energy',          'MeV',  1);
out = pl_add_ML00(out, 288, 'LTU nominal energy',           'MeV',  1);

out = pl_add_ML00(out, 268, 'SCP vs EPICS max phase error', 'degS', 1);
out = pl_add_ML00(out, 266, 'BC2 estimated energy',         'MeV',  1);
out = pl_add_ML00(out, 265, 'LTU estimated energy',         'MeV',  1);
out = pl_add_ML00(out, 264, 'Required L3 energy',           'MeV',  1);
out = pl_add_ML00(out, 263, 'Required L2 amplitude',        'MeV',  1);


% set up some more PVs - these are for input
% does this ever actually get used?

in = pl_create();
in = pl_add(in, 'SIOC:SYS0:ML00:AO061', 'L2 phase');
in = pl_add(in, 'SIOC:SYS0:ML00:AO096', '24-1 phase');
in = pl_add(in, 'SIOC:SYS0:ML00:AO097', '24-2 phase');
in = pl_add(in, 'SIOC:SYS0:ML00:AO064', 'L3 phase');
in = pl_add(in, 'SIOC:SYS0:ML00:AO094', 'S29 phase');
in = pl_add(in, 'SIOC:SYS0:ML00:AO095', 'S30 phase');
in = pl_add(in, 'SIOC:SYS0:ML00:AO067', 'L2 fudge');
in = pl_add(in, 'SIOC:SYS0:ML00:AO079', 'L3 fudge');
in = pl_add(in, 'SIOC:SYS0:ML00:AO061', 'L2 phase input'); % this is duplicated?
in = pl_add_ML00(in, 269, 'Fix SLC phases', '0 or 1', 1);
for index = 21:30
    in = pl_add(in, ['LI' num2str(index) ':SBST:1:PDES'], ['S' num2str(index) ' phase']);
end

E = get_energy_new(1); % get starting energy

% fb1pv = 'KLYS:LI24:11//PDES'; % aida phase for feedback klystron
% fb2pv = 'KLYS:LI24:21//PDES';

while 1
    pause(delay);
  W = watchdog_run(W); % this keeps the watchdog counter running
  if get_watchdog_error(W)
    disp('some watchdog error, ignoring for now');
    pause(1);
  end

    try
        in = pl_read(in);
        newE = get_energy_new(1);
    catch
        disp_log('Error on PV list read');
        continue
    end

    if isempty(newE)
        % errors in get_energy_new return []
        continue
    end

    Eold = E;
    E = newE;

    % update the "out" pvlist with info from get_energy()
    out = pl_set(out, 'L2 energy',              E.L2_energy);
    out = pl_set(out, 'L3 flat energy',         E.L3_flat_energy);
    out = pl_set(out, 'L2 fudge',               E.L2_fudge);
    out = pl_set(out, 'L3 flat fudge',          E.L3_flat_fudge);
    out = pl_set(out, 'L2 effective phase',     E.L2_effective_phase);
    out = pl_set(out, 'L2 total energy',        E.L2_total_energy);
    out = pl_set(out, 'L2 flat energy',         E.L2_flat_energy);
    out = pl_set(out, 'L2 flat fudge',          E.L2_flat_fudge);
    out = pl_set(out, 'L2 nofb flat total energy',  E.L2_nofb_flat_total_energy);
    out = pl_set(out, 'L3 nofb flat total energy',  E.L3_nofb_flat_total_energy);
    out = pl_set(out, 'S29 flat energy',        E.S29_flat_energy);
    out = pl_set(out, 'S30 flat energy',        E.S30_flat_energy);
    out = pl_set(out, 'L2 stations on',         E.num_klystrons.L2);
    out = pl_set(out, 'L3 stations on',         E.num_klystrons.L3);
    out = pl_set(out, 'L2 feedback strength',   E.L2_feedback_strength);
    out = pl_set(out, 'L3 feedback strength',   E.L3_feedback_strength);
    out = pl_set(out, 'BC2 nominal energy',     E.beam_energy_bc2);
    out = pl_set(out, 'PR55 nominal energy',    E.beam_energy_PR55);
    out = pl_set(out, 'LTU nominal energy',     E.beam_energy_LTU);

    % calculate the max phase error
    % TODO put this in get_energy()
    L2_error          = abs(E.L2_phase - E.sbst.phas(21:24));
    L3_error          = abs(E.L3_phase - E.sbst.phas(25:28));
    S29_error         = abs(E.S29_phase - E.sbst.phas(29));
    S30_error         = abs(E.S30_phase - E.sbst.phas(30));
    max_phase_error   = max([L2_error; L3_error; S29_error; S30_error]);
    out = pl_set(out, 'SCP vs EPICS max phase error', max_phase_error);

    % calculate the estimated actual energy from the RF stations
    % put this in get_energy too?

    BC2_estimated_energy  = (E.L2_flat_energy * E.L2_fudge) + E.L0_energy + E.L1_energy;
    LTU_estimated_energy  = BC2_estimated_energy + (E.L3_flat_energy * E.L3_fudge);
    Required_L3_energy    = E.energy_setpoints(5) - E.energy_setpoints(4);
    Required_L2_amplitude = (E.energy_setpoints(4) - E.energy_setpoints(3)) / cosd(E.L2_phase);

    out = pl_set(out, 'BC2 estimated energy',   BC2_estimated_energy);
    out = pl_set(out, 'LTU estimated energy',   LTU_estimated_energy);
    out = pl_set(out, 'Required L3 energy',     Required_L3_energy);
    out = pl_set(out, 'Required L2 amplitude',  Required_L2_amplitude);

    % flag if klystron complement changed
    klys_changes = E.klystrons.station_on - Eold.klystrons.station_on;

    if any(any(klys_changes))
        %klys_change_namelist = [];
        % TODO make a list of which stations changed
        disp_log('Klystron complement changed');
        pause(3);
    else
        out = pl_write(out);
    end

end
