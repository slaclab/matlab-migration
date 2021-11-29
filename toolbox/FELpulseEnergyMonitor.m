% This stuffs PVs associated with the FEL pulse energy at girder 9 into
% Matlab PVs for safe keeping.  To be implemented every time we do a BOD
% measurement, for use by the guardian to protect the SXRSS grating.

function FELpulseEnergyMonitor()
disp('FELpulseEnergyMonitor.m, v1.75 05/15/2015');
% 08/30/17 Use ABS tol for BC1 colimators at all times.
% 05/18/17 Double the Laser Heaters, double the fun
% 05/15/15 
% 04/28/15 Use ABS tol for BC1 colls if reading < 2.0
% 12/09/14 Add CQs, matching QUADs (gee thanks Ben)
% 05.09.14 Add BC1 COLLs and slotted foil, change LH tol to abs
% 04/23/14 Add catch and warnings for bunch Q, BC1 and BC2 feedbacks OFF
% 02/26/14 Add UND K values and BOD power est
% 02/16/14 Add laser heater
% 11/19/13 BC1,2 feedbacks should reference setpoint, not stored
% 11/14/13 added ignore everything else if UND 1-8 are out
%
global LI21QS; 
global LI24QS; 
global LTUQS;
%
LI21QS = [201 211 271 278];
LI24QS = [740 860];
LTUQS = [440 460 620 640 660 680];
%
delay = 1.0; % loop rate
watchdog_pv = 'SIOC:SYS0:ML00:AO000';
L = generate_pv_list(); %
ringsize = 10;
lcaSetSeverityWarnLevel(5); % disable almost all warnings
W = watchdog(watchdog_pv, 1, 'FELpulseEnergyMonitor.m');
d  = lcaGetSmart(L.pv, 16000, 'double'); % get data
lcaSetMonitor(L.pv); % set up monitor
D = cell(ringsize,1); % will hold all data
F = cell(ringsize,1); % will hold monitor flags
D{1}= d;  F{1} = zeros(length(d),1);  %just initialize
ctr = 1;  % start at 2, initialize old data
cycle = 0; %
strikes = 0; %
undLocationStat = zeros(8,1);und_Kvalue = zeros(8,1);
stored_undLocationStat = zeros(8,1); stored_undK = zeros(8,1);
CQMQctrlValue = zeros(20,1); stored_CQMQctrlValue = zeros(20,1);
%%
while 1 % Loop forever
    cycle = cycle + 1;
    if ctr > ringsize
        ctr = 1;
    else
        ctr = ctr + 1;
    end
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp('Some sort of watchdog error');
        break;  % Exit program
    end
    try
        flags = lcaNewMonitorValue(L.pv); % look for new data
    catch
        disp(['lca get error', '  ', num2str(cycle)]);
    end
    if sum(flags) % There is some new data to look at
        d = lcaGetSmart(L.pv, 16000, 'double'); % get data
        D{ctr} = d;  % save in structures to analyze later
        F{ctr} = flags;
    else
        continue; % nothing to do here
    end

    stats.saveNewSnapshot   = d(L.saveNewSnapshot_n);
    stats.FEL_pulse_energy  = d(L.BOD_pulse_energy_n);
    stats.BODscan           = d(L.BOD_scan_n);
    stats.bunchq_setpt      = d(L.bunchq_setpt_n);
    stats.bunchq_state      = d(L.bunchq_state_n);
    stats.bunchq_mat_setpt  = d(L.bunchq_mat_setpt_n);
    stats.bunchq_mat_state  = d(L.bunchq_mat_state_n);
    stats.LH1_waveplate      = d(L.LH1_waveplate_n);
    stats.LH1_delay          = d(L.LH1_delay_n);
    stats.LH2_waveplate      = d(L.LH2_waveplate_n);
    stats.LH2_delay          = d(L.LH2_delay_n);
    stats.LH_power          = d(L.LH_power_n);
    stats.BC1_current_setpt = d(L.BC1_current_setpt_n);
    stats.BC1_current_state = d(L.BC1_current_state_n);
    stats.BC1_current_fbkon = d(L.BC1_current_fbck_on_n);
    stats.L1S_phase_setpt   = d(L.L1S_phase_setpt_n);
    stats.BC2_current_setpt = d(L.BC2_current_setpt_n);
    stats.BC2_current_state = d(L.BC2_current_state_n);
    stats.BC2_current_fbkon = d(L.BC2_current_fbck_on_n);
    stats.L2_chirp_setpt    = d(L.L2_chirp_setpt_n);
    stats.dump_bend_bdes    = d(L.dump_bend_bdes_n);
    stats.dump_bend_bact    = d(L.dump_bend_bact_n);
    stats.bunch_chg_fbck    = d(L.bunch_charge_fbck_on_n);
    stats.matlab_chg_fbkon  = d(L.matlab_charge_fbck_on_n);
    for iund = 1:8
        undLocationStat(iund) = d(L.undulators_in_n(iund));
        und_Kvalue(iund)      = d(L.undulator_K_n(iund));
    end
    stats.undulators_in     = undLocationStat;
    stats.undulator_K       = und_Kvalue;
    stats.BC1coll_L_pos     = d(L.BC1coll_L_n);%left is positive
    stats.BC1coll_R_pos     = d(L.BC1coll_R_n);%right is negative
    stats.SlottedFoil_pos   = d(L.SlottedFoil_n);
    % ALL the match and CQ quads
    for iquad = 1:20
        CQMQctrlValue(iquad) = d(L.CQMQctrl_n(iquad));
        CQMQpv.name{(iquad),1}    = L.pv{L.CQMQctrl_n(iquad),1};
    end
    stats.CQMQctrl          = CQMQctrlValue;
    stats.CQMQpv            = CQMQpv.name;
    stats.BC1tols           = d(L.BC1tols_n);
    stats.L1Sphasetols      = d(L.L1Sphasetols_n);
    stats.BC2tols           = d(L.BC2tols_n);
    stats.bunchQtols        = d(L.bunchQtols_n);
    stats.L2chirptols       = d(L.L2chirptols_n);
    stats.LHpowertols       = d(L.LHpowertols_n);
    stats.undK_tols         = d(L.undKtols_n);
    stats.BC1colltols       = d(L.BC1colltols_n);
    stats.SlottedFoiltols   = d(L.SlottedFoiltols_n);
    stats.CQMQctrltols      = d(L.CQMQctrltols_n);
    stats.LHwaveplatetols   = d(L.LHwaveplatetols_n);
    %
    %%
    % This is the snapshot:
    %
    if stats.saveNewSnapshot || cycle == 1 % we want to force-save a snapshot of FEL parameters on startup
        output.pv{1,1} = L.pv{L.FEL_pulseE_store_n, 1}; % place to stash the FEL pulse energy
        output.value(1,1) = stats.FEL_pulse_energy; % use the value determined above
        output.pv{2,1} = L.pv{L.bunchq_setpt_store_n, 1}; % place to stash the bunch charge setpt
        output.value(2,1) = stats.bunchq_setpt; % bunch chg readback... etc
        output.pv{3,1} = L.pv{L.bunchq_state_store_n,1}; % bunch charge fbck state
        output.value(3,1) = stats.bunchq_state;
        output.pv{4,1} = L.pv{L.bunchq_mat_setpt_store_n, 1}; %matlab bunch charge setpoint
        output.value(4,1) = stats.bunchq_mat_setpt;
        output.pv{5,1} = L.pv{L.bunchq_mat_state_store_n, 1}; %matlab bunch charge state
        output.value(5,1) = stats.bunchq_mat_state;
        output.pv{6,1} = L.pv{L.BC1_current_setpt_store_n, 1}; %BC1 current setpoint
        output.value(6,1) = stats.BC1_current_setpt;
        output.pv{7,1} = L.pv{L.BC1_current_state_store_n, 1}; %BC1 current state
        output.value(7,1) = stats.BC1_current_state;
        output.pv{8,1} = L.pv{L.L1S_phase_setpt_store_n, 1}; %L1S phase setpoint
        output.value(8,1) = stats.L1S_phase_setpt;
        output.pv{9,1} = L.pv{L.BC2_current_setpt_store_n, 1}; %BC2 current setpoint
        output.value(9,1) = stats.BC2_current_setpt;
        output.pv{10,1} = L.pv{L.BC2_current_state_store_n, 1}; %BC2 current state
        output.value(10,1) = stats.BC2_current_state;
        output.pv{11,1} = L.pv{L.L2_chirp_setpt_store_n, 1}; % L2 chirp
        output.value(11,1) = stats.L2_chirp_setpt;
        output.pv{12,1} = L.pv{L.dump_bend_bdes_store_n, 1}; % Dump bend 400 BDES
        output.value(12,1) = stats.dump_bend_bdes;
        output.pv{13,1} = L.pv{L.dump_bend_bact_store_n, 1}; % Dump bend 400 BACT
        output.value(13,1) = stats.dump_bend_bact;
        for iund = 1:8
            idx = 13 + iund;
            output.pv{idx,1} = L.pv{L.undulators_in_store_n(iund), 1};
            output.value(idx,1) = stats.undulators_in(iund);
        end
        for iund = 1:8
            idx = 21 + iund;
            output.pv{idx,1} = L.pv{L.undulator_K_store_n(iund), 1};
            output.value(idx,1) = stats.undulator_K(iund);
        end
        output.pv{30,1} = L.pv{L.LH1_waveplate_store_n, 1}; % Laser Heater 1 Waveplate Angle
        output.value(30,1) = stats.LH1_waveplate;
        output.pv{31,1} = L.pv{L.LH1_delay_store_n, 1}; % Laser Heater 1 Delay TACT (ps)
        output.value(31,1) = stats.LH1_delay;
        output.pv{32,1} = L.pv{L.LH2_waveplate_store_n, 1}; % Laser Heater 2 Waveplate Angle
        output.value(32,1) = stats.LH2_waveplate;
        output.pv{33,1} = L.pv{L.LH2_delay_store_n, 1}; % Laser Heater 2 Delay TACT (ps)
        output.value(33,1) = stats.LH2_delay;
        output.pv{34,1} = L.pv{L.LH_power_store_n, 1}; % Laser Heater Power (PMH3 120 Hz)
        output.value(34,1) = stats.LH_power;
        output.pv{35,1} = L.pv{L.BC1coll_L_store_n, 1}; % BC1 collimator left (+) jaw position
        output.value(35,1) = stats.BC1coll_L_pos;
        output.pv{36,1} = L.pv{L.BC1coll_R_store_n, 1}; % BC1 collimator right (-) jaw position
        output.value(36,1) = stats.BC1coll_R_pos;
        output.pv{37,1} = L.pv{L.SlottedFoil_store_n, 1}; % LI24 Slotted Foil position
        output.value(37,1) = stats.SlottedFoil_pos;
        for iquad = 1:20
            idx = 37 + iquad;
            output.pv{idx,1} = L.pv{L.CQMQctrl_store_n(iquad), 1};
            output.value(idx,1) = stats.CQMQctrl(iquad);
        end
        % and then set the "save FEL pulse energy params" bit back to 0
        output.pv{58,1} = L.pv{L.saveNewSnapshot_n, 1};
        output.value(58,1) = 0;
        % and set the Protect the SXRSS Grating PV to 1 (protect)
        output.pv{59,1} = L.pv{L.protectSXRSSgrating_n, 1};
        output.value(59,1) = 1;
        %
        try
            lcaPutSmart(output.pv, output.value);
            disp('Writing FEL parameters to Matlab PVs ML01 872+');
        catch
            disp('failed to save FEL parameters');
        end
        try
            optimizeSTP
        catch %#ok<*CTCH>
            disp('unable to update striptool tols');
        end
    end
%%
%This references those stored values, and issues the trip if required
%
stored.FEL_pulse_energy  = d(L.FEL_pulseE_store_n);
stored.bunchq_setpt      = d(L.bunchq_setpt_store_n);
stored.bunchq_state      = d(L.bunchq_state_store_n);
stored.bunchq_mat_setpt  = d(L.bunchq_mat_setpt_store_n);
stored.bunchq_mat_state  = d(L.bunchq_mat_state_store_n);
stored.BC1_current_setpt = d(L.BC1_current_setpt_store_n);
stored.BC1_current_state = d(L.BC1_current_state_store_n);
stored.L1S_phase_setpt   = d(L.L1S_phase_setpt_store_n);
stored.BC2_current_setpt = d(L.BC2_current_setpt_store_n);
stored.BC2_current_state = d(L.BC2_current_state_store_n);
stored.L2_chirp_setpt    = d(L.L2_chirp_setpt_store_n);
stored.dump_bend_bdes    = d(L.dump_bend_bdes_store_n);
stored.dump_bend_bact    = d(L.dump_bend_bact_store_n);
for iund = 1:8
    stored_undLocationStat(iund)    = d(L.undulators_in_store_n(iund));
    stored_undK(iund)               = d(L.undulator_K_store_n(iund));
end
stored.undulators_in     = stored_undLocationStat;
stored.undulator_K       = stored_undK;
stored.LH1_waveplate      = d(L.LH1_waveplate_store_n);
stored.LH1_delay          = d(L.LH1_delay_store_n);
stored.LH2_waveplate      = d(L.LH2_waveplate_store_n);
stored.LH2_delay          = d(L.LH2_delay_store_n);
stored.LH_power          = d(L.LH_power_store_n);
stored.BC1coll_L_pos     = d(L.BC1coll_L_store_n);
stored.BC1coll_R_pos     = d(L.BC1coll_R_store_n);
stored.SlottedFoil_pos   = d(L.SlottedFoil_store_n);
for iquad = 1:20
    stored_CQMQctrlValue(iquad)    = d(L.CQMQctrl_store_n(iquad));
end
stored.CQMQctrl          = stored_CQMQctrlValue;
%
trip_PV = L.pv{L.trip_PV_n, 1};          % TRIP PV
[trip out] = trip_logic(stored, stats);
if cycle > 1
    if trip
        strikes = strikes + 1;
        lcaPutSmart(trip_PV, 1);         % tell guardian to turn off beam
        if strikes < 2;    % Only write error msg on initial trip
            disp(out.message);
            sty = int8(out.message);
            sty2 = double(sty); % yuck, ugly manipulation to make lcaput work
            lcaPutSmart(L.error_string_pv, sty2);
            disp(['SXRSS FEL parameters trip: ', out.message]);
        end
        %save /home/physics/tonee/FELparm_dump.mat
        pause(1);
    end
    if ~trip
        lcaPutSmart(trip_PV, 0); %tell guardian not to worry
        %disp(out.message);
        sty = int8(out.message);
        sty2 = double(sty); % yuck, ugly manipulation to make lcaput work
        lcaPutSmart(L.error_string_pv, sty2);
        strikes = 0;
        %disp(['SXRSS FEL parameters ok ', out.message]);
    end
end
end
end

%%
function L = generate_pv_list()
global LI21QS;global LI24QS; global LTUQS;  
n = 0;
pvstart = 871; %set up the storage slots = matlab PVs in ML01
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'Save FEL pulse energy params?', '1=yes', 0, 'FELpulseEnergyMonitor.m');
L.saveNewSnapshot_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'FEL pulse energy from from SXRSS GUI?', '1=yes', 0, 'FELpulseEnergyMonitor.m');
L.BOD_scan_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'FEL pulse energy in use by guardian', 'uJ', 3, 'FELpulseEnergyMonitor.m');
L.FEL_pulseE_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge feedback setpoint', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge feedback state ', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge matlab fbck setpt', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_mat_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge matlab fbck state ', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_mat_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'BC1 current setpoint', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC1_current_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'BC1 current state', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC1_current_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'L1S phase setpoint', 'deg', 2, 'FELpulseEnergyMonitor.m');
L.L1S_phase_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'BC2 current setpoint', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC2_current_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'BC2 current state', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC2_current_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'L2 chirp setpoint', 'MeV', 1, 'FELpulseEnergyMonitor.m');
L.L2_chirp_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Dump bend BDES', 'GeV', 3, 'FELpulseEnergyMonitor.m');
L.dump_bend_bdes_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Dump bend BACT', 'GeV', 3, 'FELpulseEnergyMonitor.m');
L.dump_bend_bact_store_n = n;
%Loop over undulator positions
for iund = 1:8
    n = n + 1;
    descStr = ['Undulator ', num2str(iund), ' Position'];
    L.pv{n,1} = setup_pv(pvstart + n  , descStr, '1=OUT', 0, 'FELpulseEnergyMonitor.m');
    L.undulators_in_store_n(iund) = n;
end
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'FEL pulse energy (manual entry)', 'uJ', 3, 'FELpulseEnergyMonitor.m');
L.manual_FELpulseE_n = n;
%
pvstart4 = 960;
n = n + 1;
mm = 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'BC1 left (+) collimator position', 'mm', 3, 'FELpulseEnergyMonitor.m');
L.BC1coll_L_store_n = n;
n = n + 1;
mm = mm + 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'BC1 right (-) collimator position', 'mm', 3, 'FELpulseEnergyMonitor.m');
L.BC1coll_R_store_n = n;
n = n + 1;
mm = mm + 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'LI24 Slotted Foil position', 'mm', 1, 'FELpulseEnergyMonitor.m');
L.SlottedFoil_store_n = n;
n = n + 1;
mm = mm + 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'Laser Heater 2 Waveplate Angle', 'deg', 3, 'FELpulseEnergyMonitor.m');
L.LH2_waveplate_store_n = n;
n = n + 1;
mm = mm + 2; %skip AO965
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'Laser Heater 2 Delay', 'ps', 3, 'FELpulseEnergyMonitor.m');
L.LH2_delay_store_n = n;
%
pvstart2 = 932;
n = n + 1;
m = 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater 1 Waveplate Angle', 'deg', 3, 'FELpulseEnergyMonitor.m');
L.LH1_waveplate_store_n = n;
n = n + 1;
m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater 1 Delay', 'ps', 3, 'FELpulseEnergyMonitor.m');
L.LH1_delay_store_n = n;
n = n + 1;
m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater Power', 'uJ', 1, 'FELpulseEnergyMonitor.m');
L.LH_power_store_n = n;
% control PVs, for tolerances, starting at SIOC:SYS0:ML01:AO936
n = n + 1;
m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'bunch charge feedback tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.bunchQtols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'L1S phase setpoint tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.L1Sphasetols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'BC1 current feedback tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.BC1tols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'BC2 current feedback tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.BC2tols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'L2 chirp tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.L2chirptols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater power tolerance', 'uJ', 3, 'FELpulseEnergyMonitor.m');
L.LHpowertols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Undulator K value tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.undKtols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'BC1 collimator jaws position tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.BC1colltols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Slotted Foil position tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.SlottedFoiltols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser heater Waveplate angle tolerance', 'deg', 1, 'FELpulseEnergyMonitor.m');
L.LHwaveplatetols_n = n;
% and a new batch for the Undulator K values
pvstart3 = 980;
k = 1;
for iund = 1:8
    n = n + 1;
    descStr = ['Undulator ', num2str(iund), ' K value'];
    L.pv{n,1} = setup_pv(pvstart3 + k  , descStr, 'K', 4, 'FELpulseEnergyMonitor.m');
    L.undulator_K_store_n(iund) = n;
    k = k + 1;
end
% and yet another batch for every bloody matching quad and CQ ops like to
% tweak...
pvstart666 = 173;
qq = 1;
for iquad = 1:20
    n = n + 1;
    descStr = ['CQ or Matching Quad ', num2str(iquad), ' BDES value'];
    L.pv{n,1} = setup_pv(pvstart666 + qq  , descStr, 'kG', 4, 'FELpulseEnergyMonitor.m');
    L.CQMQctrl_store_n(iquad) = n;
    qq = qq + 1;
end
n = n + 1;
L.pv{n,1} = setup_pv(pvstart666 + qq  , 'Matching quad/CQ BDES tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.CQMQctrltols_n = n;
n = n + 1; qq = qq + 1;
L.pv{n,1} = setup_pv(pvstart666 + qq  , 'One of the CQs or QMs has moved', '%', 0, 'FELpulseEnergyMonitor.m');
L.CQMQtweak_trip_n = n;
% these are the actual data PVs
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO861'; % pulse energy result from latest BOD scan
L.BOD_pulse_energy_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB02:GN01:S1DES'; % bunch charge setpoint
L.bunchq_setpt_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB02:GN01:S1P1'; % bunch charge state
L.bunchq_state_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:BCI0:1:CHRGSP'; % matlab bunch charge setpoint
L.bunchq_mat_setpt_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:BCI0:1:CHRG_S'; % matlab bunch charge state
L.bunchq_mat_state_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:S3DES'; % BC1 current setpoint
L.BC1_current_setpt_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:S3P1'; % BC1 current state
L.BC1_current_state_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:S3USED'; % BC1 current FBCK ON?
L.BC1_current_fbck_on_n = n;
n = n + 1;
L.pv{n,1} = 'ACCL:LI21:1:L1S_PDES'; % L1S desired phase
L.L1S_phase_setpt_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:S5DES'; % BC2 current setpoint
L.BC2_current_setpt_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:S5P1'; % BC2 current STATE
L.BC2_current_state_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:S5USED'; % BC2 current FBCK ON?
L.BC2_current_fbck_on_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB04:LG01:CHIRPDES'; % L2 chirp setpoint
L.L2_chirp_setpt_n = n;
n = n + 1;
L.pv{n,1} = 'BEND:DMP1:400:BDES'; % Dump Bend BDES
L.dump_bend_bdes_n = n;
n = n + 1;
L.pv{n,1} = 'BEND:DMP1:400:BACT'; % Dump Bend BACT
L.dump_bend_bact_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:FB02:GN01:STATE'; % Non-matlab bunch charge feedback on?
L.bunch_charge_fbck_on_n = n;
n = n + 1;
L.pv{n,1} = 'FBCK:BCI0:1:STATE'; % Matlab bunch charge feedback on?
L.matlab_charge_fbck_on_n = n;
%
% Undulator positions, and Kvalues, first eight undulators
for nund = 1:8
    n = n + 1;
    undOutPVname = strcat('USEG:UND1:', num2str(nund), '50:OUTSTATE');
    L.pv{n,1} = undOutPVname;
    L.undulators_in_n(nund) = n;
    n = n + 1;
    undKPVname = strcat('USEG:UND1:', num2str(nund), '50:KACT');
    L.pv{n,1} = undKPVname;
    L.undulator_K_n(nund) = n;
end
n = n + 1;
L.pv{n,1} = 'WPLT:LR20:220:LHWP_ANGLE'; % Laser heater 1 waveplate angle
L.LH1_waveplate_n = n;
n = n + 1;
L.pv{n,1} = 'LHDL:LR20:260:TACT'; % Laser heater 1 delay, ps
L.LH1_delay_n = n;
n = n + 1;
L.pv{n,1} = 'WPLT:LR20:230:LHWP_ANGLE'; % Laser heater 2 waveplate angle
L.LH2_waveplate_n = n;
n = n + 1;
L.pv{n,1} = 'LHDL:LR20:270:TACT'; % Laser heater 2 delay, ps
L.LH2_delay_n = n;
n = n + 1;
L.pv{n,1} = 'LASR:IN20:475:PWR'; % Laser heater power
L.LH_power_n = n;
n = n + 1;
L.pv{n,1} = 'COLL:LI21:236:LVPOS'; % BC1 left (+) coll position
L.BC1coll_L_n = n;
n = n + 1;
L.pv{n,1} = 'COLL:LI21:235:LVPOS'; % BC1 right (-) coll position
L.BC1coll_R_n = n;
n = n + 1;
L.pv{n,1} = 'FOIL:LI24:804:LVPOS'; % LI24 Slotted Foil position
L.SlottedFoil_n = n;
% QUADS dammit
li21_numQs = length(LI21QS);
li24_numQs = length(LI24QS);
li26_numQs = 8;
ltu_numQs = length(LTUQS);
for iq = 1:li21_numQs
    iquad = iq;
    n = n + 1;
    L.pv{n,1} = ['QUAD:LI21:', num2str(LI21QS(iq)),':BDES'];
    L.CQMQctrl_n(iquad) = n;
end
for iq = 1:li24_numQs
    iquad = li21_numQs + iq;
    n = n + 1;
    L.pv{n,1} = ['QUAD:LI24:', num2str(LI24QS(iq)),':BDES'];
    L.CQMQctrl_n(iquad) = n;
end
for iq = 1:li26_numQs
    iquad = li21_numQs + li24_numQs + iq;
    n = n + 1;
    L.pv{n,1} = ['QUAD:LI26:', num2str(iq + 1),'01:BDES'];
    L.CQMQctrl_n(iquad) = n;
end
for iq = 1:ltu_numQs
    iquad = li21_numQs + li24_numQs + li26_numQs + iq;
    n = n + 1;
    L.pv{n,1} = ['QUAD:LTU1:', num2str(LTUQS(iq)),':BDES'];
    L.CQMQctrl_n(iquad) = n;
end
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO896'; % protect the SXRSS grating
L.protectSXRSSgrating_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(898 , 'Guardian Trip PV', '1=trip', 0, 'FELpulseEnergyMonitor.m');
L.trip_PV_n = n;
L.error_string_pv = 'SIOC:SYS0:ML00:CA898';
end

%%
%herein lies the tripping part
function [trip out] = trip_logic(stored, stats)
%
trip = 0;
out.message = ' All OK ';
out.CQMQtrip = 0;
%Check if any undulators have been inserted
for iund = 1:8
    if stats.undulators_in(iund) < stored.undulators_in(iund)
        trip = 1;
        out.message = ['Undulator ', num2str(iund), ' Not OUT and should be'];
        return;
    end
end
%
%Only check the rest if any undulators are in...
%
if find(stats.undulators_in ~= 1)
    % check that the UND K values haven't changed
    for iund = 1:8
        if stats.undulators_in(iund) == 0
            qq = stats.undulator_K(iund);
            QQ = stored.undulator_K(iund);
            tols = stats.undK_tols * 0.01;
            if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
                trip = 1;
                out.message = ['Undulator ', num2str(iund), ' K value has changed'];
                return;
            end
        end
    end
    %only check the active bunch charge feedback
    if stats.bunch_chg_fbck > 0 % non matlab feedback active
        % Check bunch charge feedback setpoint unchanged
        if stats.bunchq_setpt ~= stored.bunchq_setpt
            trip = 1;
            out.message = 'Bunch charge setpoint changed since last BOD scan';
            return
        end
        %Check bunch charge feedback state within user entered % of stored setpt
        qq = stats.bunchq_state;
        QQ = stored.bunchq_setpt;
        tols = stats.bunchQtols * 0.01;
        if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
            trip = 1;
            out.message = 'Bunch charge feedback state outside stored range';
        end
    elseif stats.matlab_chg_fbkon > 0 %matlab feedback active
        % Check matlab bunch charge feedback setpoint unchanged
        if stats.bunchq_mat_setpt ~= stored.bunchq_mat_setpt
            trip = 1;
            out.message = 'MATLAB Bunch charge setpoint has been changed. Check FEL pulse energy';
            return
        end
        %Check matlab bunch charge feedback state within user entered % of stored
        %setpoint
        qq = stats.bunchq_mat_state;
        QQ = stored.bunchq_mat_setpt;
        tols = stats.bunchQtols * 0.01;
        if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
            trip = 1;
            out.message = 'MATLAB Bunch charge feedback state outside stored range';
        end
    else
        out.message = 'WARNING: Neither bunch charge feedback active!';
    end
    % Check BC1 current feedback setpoint unchanged
    if stats.BC1_current_setpt ~= stored.BC1_current_setpt
        trip = 1;
        out.message = 'BC1 current setpoint has been changed. Check FEL pulse energy';
        return
    end
    %Check BC1 current feedback state within (user entered)% of stored setpoint
    %Only check if BC1 Peak Current Feedback is ON...
    if stats.BC1_current_fbkon > 0
        tols = stats.BC1tols * 0.01;
        qq = stats.BC1_current_state;
        QQ = stored.BC1_current_setpt;
        if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
            trip = 1;
            out.message = 'BC1 current feedback state outside stored range';
        end
    else
        out.message = 'WARNING: BC1 Bunch Current Feedback is OFF';
    end
    %Check L1S phase setpoint within 1% stored state
    tols = stats.L1Sphasetols * 0.01;
    qq = abs(stats.L1S_phase_setpt);
    QQ = abs(stored.L1S_phase_setpt);
    if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
        trip = 1;
        out.message = 'L1S phase setpoint has been changed. Check FEL pulse energy.';
        return
    end
    % Check BC2 current setpoint has not changed
    if stats.BC2_current_setpt ~= stored.BC2_current_setpt
        trip = 1;
        out.message = 'BC2 current setpoint has been changed. Check FEL pulse energy.';
        return
    end
    %Check BC2 current feedback state within (user entered)% of stored setpoint
    %Only check if BC2 Peak Current Feedback is ON...
    if stats.BC2_current_fbkon > 0
        tols = stats.BC2tols * 0.01;
        qq = stats.BC2_current_state;
        QQ = stored.BC2_current_setpt;
 %       if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
        if abs(QQ - qq) > abs(tols*QQ)
            trip = 1;
            out.message = 'BC2 current feedback state outside stored range';
        end
    else
        out.message = 'WARNING: BC2 Bunch Current Feedback is OFF';
    end
    % Check L2 chirp setpoint within user entered % of stored state
    tols = stats.L2chirptols * 0.01;
    qq = abs(stats.L2_chirp_setpt);
    QQ = abs(stored.L2_chirp_setpt);
    if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
        trip = 1;
        out.message = 'L2 chirp setpoint has been changed. Check FEL pulse energy.';
        return
    end
    % Check Laser Heater 1 Waveplate angle unchanged
    tols = stats.LHwaveplatetols;
    qq = stats.LH1_waveplate;
    QQ = stored.LH1_waveplate;
%    if qq > (tols + QQ) || qq < (QQ - tols)
    if abs(QQ - qq) > abs(tols*QQ)
        trip = 1;
        out.message = 'Waveplate (LH1) angle has been changed. Check FEL pulse energy';
        return
    end
    % Check Laser Heater 1 delay unchanged
    if stats.LH1_delay ~= stored.LH1_delay
        trip = 1;
        out.message = 'Laser Heater 1 delay has been changed. Check FEL pulse energy';
        return
    end
    % Check Laser Heater 2 Waveplate angle unchanged
    tols = stats.LHwaveplatetols;
    qq = stats.LH2_waveplate;
    QQ = stored.LH2_waveplate;
%    if qq > (tols + QQ) || qq < (QQ - tols)
    if abs(QQ - qq) > abs(tols*QQ)
        trip = 1;
        out.message = 'Waveplate (LH2) angle has been changed. Check FEL pulse energy';
        return
    end
    % Check Laser Heater 2 delay unchanged
    if stats.LH2_delay ~= stored.LH2_delay
        trip = 1;
        out.message = 'Laser Heater 2 delay has been changed. Check FEL pulse energy';
        return
    end
    % Check Laser heater power is within (n) 1 uJ of stored state
    tols = stats.LHpowertols;
    qq = abs(stats.LH_power);
    QQ = abs(stored.LH_power);
    if qq > (tols + QQ) || qq < (QQ - tols)
        trip = 1;
        out.message = 'Laser heater power has changed. Check FEL pulse energy.';
        return
    end
   % Check BC1 colls are within 0.030 mm (or user entered delta) of stored position
    qql = abs(stats.BC1coll_L_pos);
    qqr = abs(stats.BC1coll_R_pos);
    QQL = abs(stored.BC1coll_L_pos);
    QQR = abs(stored.BC1coll_R_pos);
    tols = stats.BC1colltols;
 %   if tols*QQL > 0.1 || tols*QQR > 0.1
 %       colTolR = tols*QQR;
 %       colTolL = tols*QQL;
 %   else
        colTolR = tols;
        colTolL = tols;
 %   end
    if (qql > (colTolL + QQL) || qql < (QQL - colTolL)) ...
            || (qqr > (colTolR + QQR) || qqr < (QQR - colTolR))
        trip = 1;
        out.message = 'BC1 collimator has changed.  Check FEL pulse energy.';
        return
    end
    % Check Slotted Foil position is within user entered % of stored state
    tols = stats.SlottedFoiltols * 0.01;
    qq = stats.SlottedFoil_pos;
    QQ = stored.SlottedFoil_pos;
%    if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
    if abs(QQ - qq) > abs(tols*QQ)
        trip = 1;
        out.message = 'Slotted Foil has moved. Check FEL pulse energy.';
        return
    end
    % Check Dump Bend BDES has not changed
    if stats.dump_bend_bdes    ~= stored.dump_bend_bdes
        trip = 1;
        out.message = 'Dump/LTU Bend BDES has been changed. Check FEL pulse energy.';
        return
    end
    % Check Dump Bend BACT within 0.5% stored state
    qq = stats.dump_bend_bact;
    QQ = stored.dump_bend_bact;
    tols = 0.005;
%    if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
    if abs(QQ - qq) > abs(tols*QQ)
        trip = 1;
        out.message = 'Dump/LTU bend BACT >0.5% outside stored range';
    end
    % Check that no one's tweaking the matching Quads or CQs (BCTRL change
    % <0.1% )
    for iquad = 1:20
        qq = stats.CQMQctrl(iquad);
        QQ = stored.CQMQctrl(iquad);
        tols = 0.001;
 %       if qq > (tols*QQ + QQ) || qq < (QQ - tols*QQ)
        if abs(QQ - qq) > abs(tols*QQ) 
            trip = 1;
            out.CQMQtrip = 1;
            tweakedQuad = stats.CQMQpv(iquad);
            out.message = ['No tweaking the CQs or matching QUADs! I see you  ', char(tweakedQuad)];
        end
    end
end
end

%%
function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
    numstr = ['00', numtxt];
elseif numlen == 2
    numstr = ['0', numtxt];
else
    numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML01:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end


function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end