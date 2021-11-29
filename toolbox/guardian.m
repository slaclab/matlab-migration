%guardian.m

function out = guardian()
disp('guardian.m 03/12/2018 v16.13');
% 10/19/18 - Change pause after resetting phase before enabling feedbacks
%            from 1 second to 5 seconds.  This is based on empirical testing
%            of BC2 longitudinal feedback response to guardian trip resets.
% 03/12/18 - Update long string error message when clearing a strike.
% 03/09/18 - Increase timestamp sens to msec, write outputs regardless of
%           beam_on state (for troubleshooting), add more explicit "Don't
%           trip if beam is not on"
% 03/09/18 - Clean up error messages, add timestamps 
% 10/25/17 - Remove JJ Slits, FEE Spectrometer, GATT for SATTs, lowE tmit
% 10/02/17 - Remove XLEAP TMIT loss and HXRSS XTAL minE
% 06/02/17 - Add Hard Xray pop-ins P2H, P3H (FEE), P4H and P5 (NEH), plus
%             SH1 status to bypass P4H and P5
% 05/19/17 - Add BPM TMIT loss check for XLEAP, remove B4C, THz, old
%             spectrometer, unbypass CX31L
% 05/09/16 - temp bypass LTU collimator CX31L -- LVDT broke
% 11/17/15 - Just remove SATT(4) conpletely
% 06/26/15 - Fixed pop-in order so Bypass P2S bypasses the right guy (!)
% 05/14/15 - put reality check on Jim Welch photon Energy value
% 04/09/15 - only rely on TDKLUDGE to execute trip if old6x6 is running
% 01/14/15 - add conditions for running HXRSS and FEE spectrometer below MPS
%           threshold energy
% 12/11/14 - remove FEE spect (in MPS now), unbypass P2S, allow active
%            bypass of P2S just in case
% 12/05/14 - temp bypass P2S again, still causing faults (dbs)
% 12/05/14 - new FEE Spectrometer trip setting, > M1S limit
% 11/11/14 - unbypass P2S
% 11/08/14 - temp bypass PS2 pending better logic/PS2 fix
% 10/11/14 - changed name of NEH S1 and S2 to avoid confusion (was FEE)
% 10/08/14 - remove M1s lowE and not SOMS position trip, now in MPS
% 09/30/14 - add new FEE spectro, remove TDUND paranoia
% 09/24/14 - remove HXRSS (in MPS), clean up Bypass modes, temp remove FEE spectr -tjs
% 09/23/14 - shrinking Bypass FEE to just Bypass NEH
% 09/15/14 - remove OTRs, non-M1S mirrors, B4C now in MPS -tjs
% 07/01/14 - FEE Prof PVs are not MPS PVs, fixing that. -tjs
% 05/30/14 - Restore feedbacks to prior state, not all on. -tjs
% 04/03/14 - Fix MPS NaNs, correct Kmono logic -tjs
% 01/09/14 - Remove PLIC fibers (in MPS now), -tjs
% 11/19/13 - Adding ability to bypass SXRSS, fixing error message
% 11/12/13 - adding SXRSS tie-in to pulse energy monitoring
% 10/31/13 - removing obsolete fiber array processing, mirror position saves,
%           special SOMS case, and FEE TMIT trips for Kmono, mirror moves, abs TMIT.
%           Removing M1S (now in MPS). -tjs
% 10/11/13 - hardcode some thresholds, ML00 PVs getting stomped on. -tjs
% 5/19/13 - Replace BAT gateway PVs with Matlab mirrors -tjs
% 04/08/13-catch FEE spectrometer NaN crashes -tjs
% 01/30/13-make q and E inputtable in previous -tjs
% 01/22/13-Trip if bunch q > 150pC and photon E < 400 eV; cleanup -tjs
% 12/13/12-bypass BAT amp checks if BAT_mon not changing gain -tjs
% 11/9/12 -Allow SATT insertion with suficient GATT
%         -Remove SH1 and UND low energy faults (now in MPS) -tjs
% 10/23/12-Add SH1 fault at low energy, protect UND from <2.3GeV e-  -tjs
% 10/17/12-Fix YAG_in, XTAL_in confusing names, point B4C_in to IN_lim
%         - remove obs. ref to St0, add NEH S2 trip at low E -tjs
% 10/16/12-Added trip if <1.8 keV and any SATTs in; fixed pop-in stats -tjs
% 10/2/12 -Restored BAT system checks, these should remain active -tjs
% 9/28/12 -Updated to use the new DMP BPMS (301 and 381),
%         -Updated NEH stopper S1 status PV
%         -Updated B4C PV (name changed in IOC 9/20/2012)
%         -Bypassed all Bunch Arrival Time system checks (M Gibbs)
% disable L0A trips
% 7/17/12 add special SOMS protection for 2160 eV run -tjs
% 6/21/12 replace broken matlab CALC PVs with math -tjs
% 5/22/12 add FEE spectrometer protection -tjs for jlt
% 4/5/12  add disable to slit protection
% 3/29/11 remove LH OTR from list (stuck)
% 8/30/10 removed ltu otr 745 from list
% replace SATT and GATT ETOA.E PVs with dummy PVs -tjs
% define bpms to use Remove (or add) numbers to inclued other  bpms
% in the injector, ltu, undulator, or dump.
%
global INJNUMS; global LTUNUMS; global UNDNUMS; global DMPNUMS; global LI21NUMS
%global XLEAPNUMS;
global DISABLE_TRIP; 
% Bypass FEE and NEH options only take effect on startup, allow guardian to
% initialize and run with the gateway down or photon IOCs disconnected.
% Enter one in either of these PVs and restart guardian to bypass:
global BYPASS_FEE;
BYPASS_FEE = lcaGetSmart('SIOC:SYS0:ML00:AO801',16000,'double')%#ok
global BYPASS_NEH;
BYPASS_NEH = lcaGetSmart('SIOC:SYS0:ML00:AO802',16000,'double')%#ok
Ni_K_edge = 8333.3;
Ni_K_energy = 13.72;
%
DISABLE_TRIP = 0;  %%%%%%%%% Should be 0 for normal opearation
INJNUMS = [221 235 371 425 511 525 581 631 651]; % do not use dispersive bpms
LI21NUMS = [131 161 201 278 301 315 401 501 601 701 801 901];
LTUNUMS = [550 590 620 640 660 680 720 730 740 ...
    750 760 770 820 840 860 880];
%XLEAPNUMS = [860 880];
UNDNUMS = [100 190 290 390 590 690 790 890 990 1090 1190 1290 1390 ...
    1490 1590 1690 1790 1890 1990 2090 2190 2290 2390 2490 2590 2690 2790 ...
    2890 2990 3090 3190 3290 3390];
%
DMPNUMS = [299 381]; % do notuse 398 502 or 693 in dump line
delay = 0.1; % loop rate
watchdog_pv = 'SIOC:SYS0:ML00:AO451';

L = generate_pv_list(); % 
ringsize = 100;  % length of ring buffer
lcaSetSeverityWarnLevel(5); % disables almost all warnings
W = watchdog(watchdog_pv, 5, 'guardian.m');
d  = lcaGetSmart(L.pv, 16000, 'double'); % once through to get initial data
lcaSetMonitor(L.pv); % set up monitor
D = cell(ringsize,1); % will hold all data
F = cell(ringsize,1); % will hold all the flags
D{1}= d; F{1} = zeros(length(d),1);  %just initialize
ctr = 1;  % start at 2, initialize old data
stats = struct;
max_strikes = 2;
strikes = 0;
cycle = 0;
startup_msg_str = ['Starting Guardian  ', datestr(now)];
sty = double(int8(startup_msg_str));
lcaPutSmart(L.error_string_pv, sty);
while 1 % Loop forever
    cycle = cycle + 1;
    if ctr > ringsize
        ctr = 1;
        ctrlast = ringsize;
    else
        ctr = ctr + 1;
        ctrlast = ctr - 1;
    end
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp(['Some sort of watchdog error  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        break;  % Exit program
    end
    try
        flags = lcaNewMonitorValue(L.pv); % look for new data
    catch %#ok<*CTCH>
        disp(['lca get error', '  ', num2str(cycle), '  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
    end
    if sum(flags) % There is some new data to look at
        d = lcaGetSmart(L.pv, 16000, 'double'); % get data
        D{ctr} = d;  % save in structures to analyze later
        F{ctr} = flags;
    else
        continue; % nothing to do here
    end
    %
    tmp = d(L.tdund_in_n);
    if isfinite(tmp)
        stats.tdund_in = tmp;
    else
        stats.tdund_in = 0; % assume tdund out if no status
    end
    
    stats.inj = get_bpm_stats(L.injbpm, flags, D{ctr}, D{ctrlast}); % extract stats for injector bpms
    stats.li21 = get_bpm_stats(L.li21bpm, flags, D{ctr}, D{ctrlast});
    stats.ltu = get_bpm_stats(L.ltubpm, flags, D{ctr}, D{ctrlast});
%    stats.xleap = get_bpm_stats(L.xleapbpm, flags, D{ctr}, D{ctrlast});
    stats.und = get_bpm_stats(L.undbpm, flags, D{ctr}, D{ctrlast});
    stats.dmp = get_bpm_stats(L.dmpbpm, flags, D{ctr}, D{ctrlast});
    stats.bend_energy = d(L.bend_energy_n);
    stats.feedback_offset_energy = d(L.feedback_offset_energy_n);
    stats.xray_energy = Ni_K_edge * ((stats.bend_energy + stats.feedback_offset_energy/1000) / Ni_K_energy) ^2;
    stats.JW_photon_energy_eV = d(L.JW_photon_energy_eV_n);
    stats.YAG_out = d(L.YAG_out_limsw_n);    %YAGXRAY
    stats.SSGRAT_out = d(L.SSGRAT_out_limsw_n);     % SXRSS grating
    stats.felEmon_running = d(L.felEmon_running_n); % SXRSS FELpulseEnergyMonitor running
    stats.felEmon_alarm = d(L.felEmon_alarm_n);     % SXRSS FELpulseEnergyMonitor says trip
    stats.felEmon_energy = d(L.felEmon_energy_n);   % SXRSS FEL pulse energy
    stats.felEmon_errstr  = d(L.felEmon_errstr_n);  % SXRSS pass error message from FELpulseEnergyMonitor.m
    stats.ltu_colls = d(L.ltu_coll_n(:));
%   stats.ltu_Ecolls = d(L.ltu_Ecoll_n(:));
    stats.NEH_S1 = d(L.NEH_S1_n); % These are NEH PPS stoppers, status PVs are on e- side
    stats.NEH_S2 = d(L.NEH_S2_n);
    stats.NEH_SH1 = d(L.NEH_SH1_n);
%    stats.HXRSS_out = d(L.XTAL_out_limsw_n);
%    for iund = 1:3     %require first 3 UNDs OUT for HXRSS IN < 7keV
%        undLocationStat(iund) = d(L.undulators_out_n(iund));%#okgrow
%    end
%    stats.undulators_out     = undLocationStat;
    %
    %
    if BYPASS_FEE < 1
        for nb = 1:length(L.bat_amplifier_n)
            stats.bat_amplifier(nb) = d(L.bat_amplifier_n(nb));
        end
        stats.FEE_attenuator_thickness = d(L.FEE_attenuator_thickness_n);
        stats.gatt_transmission = d(L.gas_atten_transmission_n);
        stats.FEE_transmission = d(L.gas_atten_transmission_n) * d(L.solid_atten_transmission_n); % transmission
        for np = 1:length(L.popin_n)
            stats.pop_in(np) = d(L.popin_n(np));
        end
        stats.kmono_out = d(L.kmono_crystal_out_n);
        stats.kmono_diode_out = d(L.kmono_diode_out_n);
        %stats.M1Spos = d(L.M1Spos_n); %M1S X is the only one we care about
        % stats.jj_slits = d(L.jj_slit_n(:));
        %stats.satts = d(L.satt_n(:));
        % stats.slit_protect = d(L.slit_protect_n);
        % FEE spectrometer position temporarily removed 9/24/14 tjs
        % stats.fee_spectrometer_position = d(L.fee_spectrometer_position_n);
        % stats.fee_spectrometer_out = d(L.fee_spectrometer_out_n);
        stats.bat_threshold_active = d(L.bat_threshold_active_n);
    else
        stats.FEE_transmission = 1000; % bogus number for preserving output PV
    end
    %
    %
    ctrl.mintmit = d(L.mintmit_n);
    ctrl.maxtmit = d(L.maxtmit_n); 
    ctrl.min_YAG_energy = d(L.min_YAG_energy_n);
    ctrl.maxFELonSXRSS = d(L.maxFELonSXRSS_n);
    ctrl.maxtmitvariation = d(L.maxtmitvariation_n);
    %ctrl.maxxleaptmitloss = d(L.maxxleaptmitloss_n);
    ctrl.max_ltu_position = d(L.max_ltu_position_n);
    ctrl.max_und_position = d(L.max_und_position_n);
    ctrl.min_bend_energy = d(L.min_bend_energy_n);
    ctrl.max_insertion_transmission = d(L.max_insertion_transmission_n);
    %ctrl.hard_xray_threshold = d(L.hard_xray_threshold_n);
    %ctrl.hard_xray_threshold = 2050; %hard code for now
    ctrl.bat_threshold = d(L.bat_threshold_n);
    ctrl.ltu_coll_threshold = d(L.ltu_coll_threshold_n);
    %ctrl.satt_threshold = d(L.satt_threshold_n);
    % ctrl.fee_spectrometer_threshold = d(L.fee_spectrometer_threshold_n);
    % ctrl.fee_spectrometer_tmit = d(L.fee_spectrometer_tmit_n);
    %ctrl.max_lowE_tmit = d(L.max_lowE_tmit_n); %TMIT threshold for soft Xrays
    %ctrl.lowE_threshold = d(L.lowE_threshold_n); %define lowE
    %ctrl.gatt_threshold = d(L.gatt_threshold_n);
    ctrl.SXRSS_protect_bypass = d(L.SXRSS_bypass_n); % don't ever do this
    ctrl.P2S_protect_bypass = d(L.P2S_bypass_n); % we hate P2S
    ctrl.force_FEE_tmit_limit = d(L.force_FEE_tmit_limit_n); %fake insertion device
%    ctrl.HXRSS_min_E = d(L.min_XTAL_energy_n);
    % Set up output diagnostics pvs
    
    [trip out] = trip_logic(ctrl, stats);  %%%%%% MAIN TRIP LOGIC IS HERE
    
%    if out.beam_on
% don't just update these if beam is on, do it all the time...
        output.pv{1,1} = L.pv{L.mintmit_rb_n, 1}; % minimum tmit pv output
        output.value(1,1) = stats.und.mintmit;
        output.pv{2,1} = L.pv{L.maxtmit_rb_n, 1}; % maximum tmit pv output
        output.value(2,1) = stats.und.maxtmit;
        output.pv{3,1} = L.pv{L.maxtmitvariation_rb_n,1};
        output.value(3,1) = out.ltu_undulator_charge_loss;
        output.pv{4,1} = L.pv{L.max_ltu_position_rb_n,1};
        output.value(4,1) = out.ltu_max_position;
        output.pv{5,1} = L.pv{L.max_und_position_rb_n,1};
        output.value(5,1) = out.und_max_position;
        output.pv{6,1} = L.pv{L.beam_energy_rb_n,1};
        output.value(6,1) = out.bend_energy;
        output.pv{7,1} = L.pv{L.FEE_transmission_rb_n,1};
        output.value(7,1) = out.FEE_transmission;
        output.pv{8,1} = L.pv{L.xray_energy_rb_n,1};
        output.value(8,1) = out.xray_energy;
        output.pv{9,1} = L.pv{L.ltu_max_coll_n,1};
        output.value(9,1) = out.ltu_max_coll;
%        output.pv{10,1} = L.pv{L.maxxleaptmitloss_rb_n,1};
%        output.value(10,1) = out.ltu_xleap_charge_loss;
        
        lcaPutSmart(output.pv, output.value);
%    end
    
    if trip
        strikes = strikes + 1;
        if strikes >= max_strikes % really trip
            beam_control(0, L); % turns off beam
            disp([out.message, '  ', datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF')]);
            sty = double(int8(out.message));
            lcaPutSmart(L.error_string_pv, sty);
            disp(['Second strike, beam off  ', out.message, '  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
            %save /home/physics/tonee/guardiandump.mat
            pause(1);
        else
            disp(['First strike   ', out.message, '  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        end
    elseif out.beam_on  % not tripped, good beam
        if strikes
            disp(['Strike cleared  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
            msg_str = ['Clearing single strike...  ', out.message, datestr(now)];
            sty = double(int8(msg_str));
            lcaPutSmart(L.error_string_pv, sty);
        end
        strikes = 0;
%        out.message = 'All OK, beam on'; %trying to solve the default text = TDUND in
    end
    if ~trip && d(L.trip_reset_n)  % reset trip
        disp(['Resetting trip  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        lcaPutSmart(L.pv{L.trip_reset_n,1}, 0); % reset trip
        sty = double(int8(out.message));
        lcaPutSmart(L.error_string_pv, sty); %
        pause(1);
        beam_control(1, L); % turn on beam
    end
end
out.pvlist = L; % temporary
out.data = D;
out.flags = F; %
out.ctr = ctr;
out.stats = stats;
lcaClear; % clear all monitors
end

%%
% generates list of all PVs
% S.p{n,1} is pv name
function L = generate_pv_list()
global INJNUMS; global LI21NUMS; global LTUNUMS; %global XLEAPNUMS; 
global UNDNUMS; global DMPNUMS;
global BYPASS_FEE; global BYPASS_NEH;
bpmbc = 'BR';
n = 0;
uu = 0; % counter for unused MLxx PVs we want reserved for now
pvstart = 451;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Trip reset', ' ', 0, 'guardian.m');
L.trip_reset_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'minimum tmit ', 'nC', 3, 'guardian.m');
L.mintmit_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'maximum tmit ', 'nC', 3, 'guardian.m');
L.maxtmit_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'max tmit fractional loss', 'ratio', 3, 'guardian.m');
L.maxtmitvariation_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'max  LTU position', 'mm', 3, 'guardian.m');
L.max_ltu_position_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'max undulator position', 'mm', 3, 'guardian.m');
L.max_und_position_n = n;
%n = n + 1;
%L.pv{n,1} = setup_pv(pvstart + n  , ' max tmit loss through XLEAP ', ' ratio ', 3, 'guardian.m');
%L.maxxleaptmitloss_n = n;
%n = n + 1; 
%L.pv{n,1} = setup_pv(pvstart + n  , ' Fractional TMIT loss through XLEAP ', ' ratio ', 0, 'guardian.m');
%L.maxxleaptmitloss_rb_n = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'LTU bend setting defining low energy', 'GeV', 2, 'guardian.m');
L.min_bend_energy_n = n;
%
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Trip Status', ' ', 0, 'guardian.m');
L.trip_status_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(651, 'Minimum Energy for YAGXRAY', 'GeV', 2, 'guardian.m');
L.min_YAG_energy_n = n;
%n = n + 1;
%L.pv{n,1} = setup_pv(567, 'Min Energy for HXRSS XTAL', 'eV', 2, 'guardian.m');
%L.min_XTAL_energy_n = n; 
n = n + 1;
L.pv{n,1} = setup_pv(652, 'Max Trans for insertion devices', 'Ratio', 4, 'guardian.m');
L.max_insertion_transmission_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(699, 'Fake FEE pop-in to force tmit limit', '1=IN', 0, 'guardian.m');
L.force_FEE_tmit_limit_n = n;
%
pvstart2 = 530-n-2;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'minimum tmit readback', 'nC', 3, 'guardian.m');
L.mintmit_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'maximum tmit readback', 'nC', 3, 'guardian.m');
L.maxtmit_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'max tmit fractional variation readback', 'ratio', 3, 'guardian.m');
L.maxtmitvariation_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'max  LTU position readback', 'mm', 3, 'guardian.m');
L.max_ltu_position_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'max undulator position readback', 'mm', 3, 'guardian.m');
L.max_und_position_rb_n = n;
% Just to preserve these PVs and keep the count right, consider replacing 
% with n = n + 5;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
%
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'Beam Energy', 'GeV', 2, 'guardian.m');
L.beam_energy_rb_n = n;
n = n + 1; %uu = uu + 1;
%L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
%L.unused_n(uu) = n;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'FEE Attenuator transmission', 'Ratio ', 4, 'guardian.m');
L.FEE_transmission_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , 'Xray Energy', 'eV', 1, 'guardian.m');
L.xray_energy_rb_n = n;
% see nota above, also consider replacing with n = n + 2; Or just deleting;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
%n = n + 1;
%L.pv{n,1} = setup_pv(pvstart2 + n  , 'FEE JJ Slit protection active', 'on/off', 0, 'guardian.m');
%L.slit_protect_n = n;
n = n + 1; uu = uu + 1;
L.pv{n,1} = setup_pv(pvstart2 + n  , ' unused but reserved ', '  ', 0, 'guardian.m');
L.unused_n(uu) = n;
%
%
L.error_string_pv = 'SIOC:SYS0:ML00:CA002';
%
n = n + 1;
L.pv{n,1} = 'DUMP:LTU1:970:TDUND_IN'; % is tune-up dump in?
L.tdund_in_n = n;
L.desc{n} = 'Is tune up dump in';
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML00:AO627';
L.JW_photon_energy_eV_n = n;
L.desc{n} = 'Jim Welch Photon Energy, eV';
n = n + 1;
L.pv{n,1} = 'BEND:DMP1:400:BACT';
L.bend_energy_n = n;
L.desc{n} = 'Energy, GeV';
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML00:AO289';
L.feedback_offset_energy_n = n;
L.desc{n} = 'feedback offset energy MeV';
n = n + 1;
L.pv{n,1} = 'YAGS:DMP1:500:OUT_LMTSW'; % Yag screen retracted
L.YAG_out_limsw_n = n;
%n = n + 1;
%L.pv{n,1} = 'XTAL:UND1:1650:OUT_LMTSW_MPS'; % HXRSS crystal retracted
%L.XTAL_out_limsw_n = n;
n = n + 1;
L.pv{n,1} = 'GRAT:UND1:934:OUT_LIMIT_MPS'; % SXRSS grating retracted
L.SSGRAT_out_limsw_n = n;
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO896'; %bypass SXRSS protection
L.SXRSS_bypass_n = n;
L.desc{n} = 'Protect the SXRSS grating? (1=Y, 0=N): ';
n = n + 1;
L.pv{n,1} = 'ALRM:SYS0:FEL_PLS_EM:ALHBERR'; % watcher for FELpulseEnergyMonitor.m
L.felEmon_running_n = n;
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO898'; %trip request from FELpulseEnergyMonitor.m
L.felEmon_alarm_n = n;
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO874'; % pulse energy as reported by/to FELpulseEnergyMonitor.m
L.felEmon_energy_n = n;
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO897'; % max FEL pulse energy allowed for SXRSS grating
L.maxFELonSXRSS_n = n;
L.desc{n} = 'maximum allowed FEL pulse energy';
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML00:CA898'; % FELpulseEnergyMonitor.m output error message
L.felEmon_errstr_n = n;
n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML01:AO158'; % bypass P2S protection
L.P2S_bypass_n = n;
%for nund = 1:3
%    n = n + 1;
%    undOutPVname = strcat('USEG:UND1:', num2str(nund), '50:OUTSTATE');
%    L.pv{n,1} = undOutPVname;
%    L.undulators_out_n(nund) = n;
%end
%BPMs
inj_num_bpms = length(INJNUMS);
li21_num_bpms = length(LI21NUMS);
ltu_num_bpms = length (LTUNUMS);
%xleap_num_bpms = length(XLEAPNUMS);
und_num_bpms = length(UNDNUMS);
dmp_num_bpms = length(DMPNUMS);
extstr{1} = {'X'};
extstr{2} = {'Y'};
extstr{3} = {'TMIT'};
for m = 1:inj_num_bpms
    L.injbpm(m).bpmnum = INJNUMS(m);
    for k = 1:3
        n = n + 1;
        L.pv{n,1} = ['BPMS:IN20:', num2str(INJNUMS(m)), ':', char(extstr{k}), bpmbc];
        eval(['L.injbpm(m).', char(extstr{k}), '_n = n;']);
    end
end
for m = 1:li21_num_bpms
    L.li21bpm(m).bpmnum = LI21NUMS(m);
    for k = 1:3
        n = n + 1;
        L.pv{n,1} = ['BPMS:LI21:', num2str(LI21NUMS(m)), ':', char(extstr{k}), bpmbc];
        eval(['L.li21bpm(m).', char(extstr{k}), '_n = n;']);
    end
end
for m = 1:ltu_num_bpms
    L.ltubpm(m).bpmnum = LTUNUMS(m);
    for k = 1:3
        n = n + 1;
        L.pv{n,1} = ['BPMS:LTU1:', num2str(LTUNUMS(m)), ':', char(extstr{k}), bpmbc];
        eval(['L.ltubpm(m).', char(extstr{k}), '_n = n;']);
    end
end
%for m = 1:xleap_num_bpms
%    L.xleapbpm(m).bpmnum = XLEAPNUMS(m);
%    for k = 1:3
%        n = n + 1;
%        L.pv{n,1} = ['BPMS:LTU1:', num2str(XLEAPNUMS(m)), ':', char(extstr{k}), bpmbc];
%        eval(['L.xleapbpm(m).', char(extstr{k}), '_n = n;']);
%    end
%end
for m = 1:und_num_bpms
    L.undbpm(m).bpmnum = UNDNUMS(m);
    for k = 1:3
        n = n + 1;
        L.pv{n,1} = ['BPMS:UND1:', num2str(UNDNUMS(m)), ':', char(extstr{k}), bpmbc];
        eval(['L.undbpm(m).', char(extstr{k}), '_n = n;']);
    end
end
for m = 1:dmp_num_bpms
    L.dmpbpm(m).bpmnum = DMPNUMS(m);
    for k = 1:3
        n = n + 1;
        L.pv{n,1} = ['BPMS:DMP1:', num2str(DMPNUMS(m)), ':', char(extstr{k}), bpmbc];
        eval(['L.dmpbpm(m).', char(extstr{k}), '_n = n;']);
    end
end

%n = n + 1;
%L.pv{n,1} = setup_pv(551, 'Below this E, M1S must be set for SOMS', 'eV', 0, 'guardian.m');
%L.hard_xray_threshold_n = n;

n = n + 1;
L.pv{n,1} = setup_pv(553, 'BAT amplifier charge limit', 'nC', 3, 'guardian.m');
L.bat_threshold_n = n;

n = n + 1;
L.pv{n,1} = 'SIOC:SYS0:ML00:AO745'; %BAT_mon PV that enables RF amp gain switching
L.bat_threshold_active_n = n;

% add LTU transverse collimator jaw LVDTs

LTUcolls = {...
    'COLL:LTU1:722:LVPOS';
    'COLL:LTU1:723:LVPOS';
    'COLL:LTU1:762:LVPOS';
    'COLL:LTU1:763:LVPOS';
    'COLL:LTU1:732:LVPOS';
    'COLL:LTU1:733:LVPOS';
    'COLL:LTU1:772:LVPOS';
    'COLL:LTU1:773:LVPOS'};

for m = 1:length(LTUcolls)
    n = n + 1;
    L.pv{n,1} = LTUcolls{m};
    L.ltu_coll_n(m) = n;
end

n = n + 1;
L.pv{n,1} = setup_pv(554, 'LTU collimator gap limit', 'mm', 2, 'guardian.m');
L.ltu_coll_threshold_n = n;

n = n + 1;
L.pv{n,1} = setup_pv(555, 'LTU colls max diff from nominal', 'mm', 3, 'guardian.m');
L.ltu_max_coll_n = n;

% add LTU energy collimator jaw LVDTs
%
%LTU_Ecolls = {...
%    'COLL:LTU1:252:MOTR.RBV';
%    'COLL:LTU1:452:MOTR.RBV';
%    'COLL:LTU1:453:MOTR.RBV'};
%
%for m = 1:length(LTU_Ecolls)
%    n = n + 1;
%    L.pv{n,1} = LTU_Ecolls{m};
%    L.ltu_Ecoll_n(m) = n;
%end

% add protection for FEE solid attenuators (all)
%n = n + 1;
%L.pv{n,1} = setup_pv(629, 'Max GATT transmission for SATTs', 'ratio', 6, 'guardian.m');
%L.gatt_threshold_n = n;
%
%n = n + 1;
%L.pv{n,1} = setup_pv(636, 'Min xray energy for SATTs', 'eV', 0, 'guardian.m');
%L.satt_threshold_n = n;
%
% add inputtable settings to define very low energy and tmit threshold at
% very low Energy
%n = n + 1;
%L.pv{n,1} = setup_pv(999, 'LTU Bend energy for lowE photons', 'GeV', 2, 'guardian.m');
%L.lowE_threshold_n = n; %nominal setting 3.0GeV bendE
%
%n = n + 1;
%L.pv{n,1} = setup_pv(638, 'Max Und tmit for lowE photons', 'nC', 3, 'guardian.m');
%L.max_lowE_tmit_n = n; %nominal setting 0.150 nC
%
% FEE spectrometer setpoint PVs
%n = n + 1;
%L.pv{n,1} = 'SIOC:SYS0:ML01:AO622';
%L.fee_spectrometer_threshold_n = n;
%n = n + 1;
%L.pv{n,1} = 'SIOC:SYS0:ML01:AO619';
%L.fee_spectrometer_tmit_n = n;

% the NEH stoppers -- look at IN status, if = 1 bypass downstream
n = n + 1;
L.pv{n,1} = 'PPS:NEH1:1:S1INSUM';
L.NEH_S1_n = n;
n = n + 1;
L.pv{n,1} = 'PPS:NEH1:1:S2INSUM';
L.NEH_S2_n = n;
n = n + 1;
L.pv{n,1} = 'PPS:NEH1:1:SH1INSUM';
L.NEH_SH1_n = n;

% if we are bypassing FEE and/or NEH PVs, these are the ones to ignore
%
if BYPASS_FEE < 1

    % BAT amplifier switch position, for all 4 amps, mirrored in CALC PVs
    n = n + 1;
    %L.pv{n,1} = 'UND:R02:IOC:16:BTAM1:RF:Switch';
    L.pv{n,1} = 'SIOC:SYS0:ML01:CALC501';
    L.bat_amplifier_n(1) = n;
    
    n = n + 1;
    %L.pv{n,1} = 'UND:R02:IOC:16:BTAM2:RF:Switch';
    L.pv{n,1} = 'SIOC:SYS0:ML01:CALC502';
    L.bat_amplifier_n(2) = n;
    
    n = n + 1;
    %L.pv{n,1} = 'UND:R02:IOC:16:BTAM3:RF:Switch';
    L.pv{n,1} = 'SIOC:SYS0:ML01:CALC503';
    L.bat_amplifier_n(3) = n;
    
    n = n + 1;
    %L.pv{n,1} = 'UND:R02:IOC:16:BTAM4:RF:Switch';
    L.pv{n,1} = 'SIOC:SYS0:ML01:CALC504';
    L.bat_amplifier_n(4) = n;
    
    % FEE "JJ" slit protection
%    for m = 1:8
%        n = n + 1;
%        jj_slit_pv = strcat('STEP:FEE1:45', num2str(m), ':MOTR.RBV');
%        L.pv{n, 1} = jj_slit_pv;
%        L.jj_slit_n(m) = n;
%    end
    
    n = n + 1;
    L.pv{n,1} = 'SATT:FEE1:320:TACT'; % FEE Attenuator thickness
    L.FEE_attenuator_thickness_n = n;
    
%    for m = 1:3
%        n = n + 1;
%        satt_pv = strcat('SATT:FEE1:32', num2str(m), ':STATE');
%        L.pv{n, 1} = satt_pv;
%        L.satt_n(m) = n;
%    end
%     for mm = 1:5
%         m = mm + 4;
%         om = m - 1;
%        n = n + 1;
%        satt_pv = strcat('SATT:FEE1:32', num2str(m), ':STATE');
%        L.pv{n, 1} = satt_pv;
%        L.satt_n(om) = n;
%    end
    
    n = n + 1;
    L.pv{n,1} = 'GATT:FEE1:310:R_ACT'; % gas attenuator transmission
    L.gas_atten_transmission_n = n;
    n = n + 1;
    L.pv{n,1} = 'SATT:FEE1:320:RACT'; % solid attenuator transmission
    L.solid_atten_transmission_n = n;
    
    %Soft and common-line pop-ins, these are the MPS OUT PVs.  For the Hard-line 
    % pop-ins P2H and P3H it's the limit switches from the motor
    n = n + 1;
    np = 1; % number of popin
    L.pv{n,1} = 'CAMR:FEE1:1953:OUT'; %P3S1
    L.popin_n(np) = n;
    n = n + 1; np =  np + 1;
    L.pv{n,1} = 'CAMR:FEE1:2953:OUT'; %P3S2
    L.popin_n(np) = n;
    n = n + 1; np =  np + 1;
    L.pv{n,1} = 'CAMR:FEE1:852:MOTR.HLS'; %P2H
    L.popin_n(np) = n;
    n = n + 1; np =  np + 1;
    L.pv{n,1} = 'CAMR:FEE1:913:MOTR.HLS'; %P3H
    L.popin_n(np) = n;
    n = n + 1; np =  np + 1;	 
    L.pv{n,1} = 'CAMR:FEE1:1692:OUT'; %P2S	 
    L.popin_n(np) = n;
    if BYPASS_NEH < 1
        n = n + 1; np =  np + 1;
        L.pv{n,1} = 'CAMR:NEH1:1124:OUT'; %P4S1
        L.popin_n(np) = n;
        n = n + 1; np =  np + 1;
        L.pv{n,1} = 'CAMR:NEH1:2124:OUT'; %P4S2
        L.popin_n(np) = n;
        n = n + 1; np =  np + 1;
        L.pv{n,1} = 'CAMR:NEH1:124:OUT'; %P4H
        L.popin_n(np) = n;
        n = n + 1; np =  np + 1;
        L.pv{n,1} = 'CAMR:NEH1:195:OUT'; %P5
        L.popin_n(np) = n;
    end
    
    % Kmono crystal and diode
    n = n + 1;
    L.pv{n,1} = 'XTAL:FEE1:022:POSITION';
    L.kmono_crystal_out_n = n;
    n = n + 1;
    L.pv{n,1} = 'DIOD:FEE1:026:POSITION'; % 1 = out
    L.kmono_diode_out_n = n;
    
    % mirrors -  M1S only
    %nm = 0;
%    n = n + 1;
    %nm = nm + 1;
%    L.pv{n,1} = 'STEP:FEE1:1561:MOTR.RBV';
%    L.M1Spos_n = n;
   
    % FEE Spectrometer - limSwitch only 9/30/14
%    n = n + 1;
%    L.pv{n,1} = 'STEP:FEE1:441:MOTR.LLS';
%    L.fee_spectrometer_out_n = n;

end
end

%%
% bpm is a structure array
function stats = get_bpm_stats(bpm, flags, d, dold) %
% convert Nel to TMIT
len = length(bpm);
tmit = zeros(len,1);
x = zeros(len,1);
y = zeros(len,1);
valid = ones(len,1);
m = 0; % number of good data
for k = 1:len
    tmit_n = bpm(k).TMIT_n;
    x_n = bpm(k).X_n;
    y_n = bpm(k).Y_n;
    if ~(flags(tmit_n) || flags(x_n) || flags(y_n)); % no new data, not valid
        valid(k) = 0;
        continue;
    end
    if ~isfinite(d(tmit_n) + d(x_n) + d(y_n))
        valid(k) = 0; % non finite means bad data
        continue;
    end
    if d(tmit_n) == dold(tmit_n)
        valid(k) = 0; % no change, data invalid
        continue;
    end
    m = m + 1;
    tmit(m) =  d(tmit_n)  * 1.602e-19 * 1e9; % convert to NC
    x(m) = d(x_n);
    y(m) = d(y_n);
end
if m > 1        % Shorten arrays so min, max, etc work
    x = x(1:m,1);
    y = y(1:m,1);
    tmit = tmit(1:m,1);
else
    x = 0; y = 0; tmit = 0;
end
stats.num = len; % total number of bpms
stats.num_valid = m;
stats.meantmit = mean(tmit);
stats.maxtmit = max(tmit);
stats.mintmit = min(tmit);
stats.mediantmit = median(tmit);
stats.maxpos = max(max(abs(x)), max(abs(y)));
% Added by bripman on 6/21/15 to address BYKIK synchronization problem
nonzerotmit = tmit(tmit > 0.001);
if isempty(nonzerotmit)
    stats.minnonzerotmit = 0;
else
    stats.minnonzerotmit = min(nonzerotmit);
end
end

%%
% This is where the beam trip decision is made
function [trip out] = trip_logic(ctrl, stats)
global BYPASS_FEE;
global BYPASS_NEH;

Si_edge_high = 2500;
trip = 0;
out.message = 'All OK ';
if stats.ltu.mintmit >= ctrl.mintmit % Beam in LTU
    out.beam_on = 1;
else
    out.beam_on = 0;
end
%Check charge loss though XLEAP
%if isfinite(stats.ltu.mediantmit) && (stats.ltu.mediantmit > 0) && (stats.xleap.maxtmit > 0) && isfinite(stats.xleap.maxtmit) ...
%        && stats.xleap.minnonzerotmit > 0
%    out.ltu_xleap_charge_loss = (stats.ltu.mediantmit - stats.xleap.minnonzerotmit) ...
%        /stats.ltu.mediantmit; % just to avoid div0
%else
%    out.ltu_xleap_charge_loss = 0;
%end
%Check charge loss in undulator
if isfinite(stats.ltu.mediantmit) && (stats.ltu.mediantmit > 0) && (stats.und.maxtmit > 0) && isfinite(stats.und.maxtmit) ...
        && stats.und.minnonzerotmit > 0
    out.ltu_undulator_charge_loss = (stats.ltu.mediantmit - stats.und.minnonzerotmit) ...
        /stats.ltu.mediantmit; % just to avoid div0
else
    out.ltu_undulator_charge_loss = 0;
end
out.ltu_max_position = stats.ltu.maxpos; % max position in ltu
out.und_max_position = stats.und.maxpos; % max position in undulator
out.bend_energy = stats.bend_energy;
%reality check on Jim Welch beam energy number
if abs(stats.JW_photon_energy_eV - stats.xray_energy) < (0.2 * stats.xray_energy) 
    out.xray_energy = stats.JW_photon_energy_eV;
else
    out.xray_energy = stats.xray_energy;
%    disp('Jim Welch photon energy number is Crazy! Using dumber number.');
end
%       
out.ltu_max_coll = max(abs(stats.ltu_colls));
out.FEE_transmission = stats.FEE_transmission;
%
beam_past_tdund = 0; % inital before check
if stats.und.num_valid
   if stats.und.maxtmit > ctrl.mintmit
       beam_past_tdund = 1; % valid undulator bpms and tmit above min
   end
elseif stats.dmp.num_valid
   if stats.und.maxtmit > ctrl.mintmit
       beam_past_tdund = 1; % valid dump bpms and tmit above min
   end
end

if stats.tdund_in
    trip = 0;  % tdund is in, no beam past, no need to trip
    out.message = 'TDUND in, system OK';
    return;
end
if ~out.beam_on
    trip = 0;  %  no beam, no need to trip
    out.message = 'Beam is not on, no tripping';
    return;
end
if beam_past_tdund
    if stats.ltu.maxtmit > ctrl.mintmit % beam in LTU after BYKIK
%        if out.ltu_xleap_charge_loss >= ctrl.maxxleaptmitloss
%            trip = 1;
%            out.message = 'Too much loss at the XLEAP location!';
%            return;
%        end
        if out.ltu_undulator_charge_loss >= ctrl.maxtmitvariation
            trip = 1;
            out.message = 'Minimum charge in undulator less than in LTU';
            return;
        end
        if out.ltu_max_position >= ctrl.max_ltu_position
            trip = 1;
            out.message = 'Orbit too big in LTU and TDUND is out';
            return;
        end
    end
    if stats.und.mintmit > ctrl.mintmit % beam in undulator
        if out.und_max_position >= ctrl.max_und_position
            trip = 1;
            out.message = 'Orbit too big in undulator';
            return;
        end
    end
end

if(~(stats.YAG_out == 1) && (stats.bend_energy < ctrl.min_YAG_energy))
    trip = 1;
    out.message = 'Energy too low for YAGXRAY to be inserted';
    return;
end

% Trip if SXRSS grating is not protected but should be
if ~(stats.SSGRAT_out == 1) && (ctrl.SXRSS_protect_bypass > 0) % bypassed if 0 or -1
    if stats.felEmon_running > 0 % Alarm handler returns '0' if running
        trip = 1;
        out.message = 'SXRSS Guardian process needs to be running while SXRSS grating is IN';
        return;
    elseif (stats.felEmon_energy > ctrl.maxFELonSXRSS)
        trip = 1;
        out.message = 'FEL pulse energy too high for SXRSS grating to be inserted';
    elseif stats.felEmon_alarm
        trip = 1;
        out.message = 'SXRSS Guardian trip, check SXRSS Guardian (FELpulseEnergyMonitor.m)';
%        out.message = char(stats.felEmon_errstr);
        return;
    end
end

%Trip if HXRSS grating is Not OUT and energy below [7keV] and UNDs 1-3 are
%Not OUT
%if ~(stats.HXRSS_out) && (out.xray_energy < ctrl.HXRSS_min_E) 
%        if ~all(stats.undulators_out)
%            trip = 1;
%            out.message = ['UNDs 1-3 must be out if HXRSS crystal is IN < ' num2str(ctrl.HXRSS_min_E)];
%            return;
%        end
%end

%Add trip if bunch charge is above threshold at low energy, possibly
%obsolete
%if (stats.und.maxtmit > ctrl.max_lowE_tmit) && (stats.bend_energy < ctrl.lowE_threshold)
%    trip = 1;
%    out.message = ['>', num2str(ctrl.max_lowE_tmit), 'nC not allowed below', ...
%        num2str(ctrl.lowE_threshold) ' eV'];
%    return;
%end

% add 4/21 trip if LTU collimators too far open
out.ltu_max_coll = max(abs(stats.ltu_colls));
if ctrl.ltu_coll_threshold > 0 % -1 to bypass
    if out.ltu_max_coll > ctrl.ltu_coll_threshold
        trip = 1;
        out.message = 'LTU XY collimators too far open';
        return;
    end
end

% collect all the gateway-PV logic here...

if BYPASS_FEE < 1

   
insertions = 0;
% The FEE pop_in status is from the OUT switches, so if OUT ~= 1 we need to
% protect it...
try
    for np = 1:4
        if stats.pop_in(np) ~= 1
            insertions = 1;
        end
    end
    % Check P2S if it's not bypassed
    if ctrl.P2S_protect_bypass < 1
        if stats.pop_in(5) ~= 1
            insertions = 1;
        end
    end
    % The NEH pop-ins are bypassed by their respective stoppers, which look
    % at the IN status, 1 = IN
    if BYPASS_NEH < 1
        if ~(stats.NEH_S1 == 1)
            if stats.pop_in(6) ~= 1
                insertions = 1;
            end
        end
        if ~(stats.NEH_S2 == 1)
            if stats.pop_in(7) ~= 1
                insertions = 1;
            end
        end
        if ~(stats.NEH_SH1 == 1)
            if stats.pop_in(8) ~= 1 || stats.pop_in(9) ~= 1
                insertions = 1;
            end
        end
    end
catch
    disp(['pop in NAN error  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
end
if ctrl.force_FEE_tmit_limit > 0
    insertions = 1;
end
if (out.FEE_transmission > ctrl.max_insertion_transmission) && insertions
    trip = 1;
    out.message = 'FEE device in beam (pop in) with too much transmission';
    return;
end


if (out.xray_energy < Si_edge_high) && ~(stats.kmono_out == 1)
    trip = 1;
    out.message = 'K-mono inserted, energy too low for K-mono';
    return;
end

if ~(stats.kmono_diode_out == 1) && (stats.kmono_out == 1)
    trip = 1;
    out.message = 'K-mono diode inserted without K-mono crystal';
    return;
end


% trip if soft x-rays AND M1S is NOT set up for SOMS
%if (out.xray_energy < ctrl.hard_xray_threshold) && (abs(stats.M1Spos) > 1000)    % M1S X motor
%    trip = 1;
%    out.message = ['Photon energy below ' num2str(ctrl.hard_xray_threshold) ' and M1S not set for SOMS'];
%    return;
%end

% FEE Spectrometer now in real MPS. Tonee 12/11/2014
%   HOWEVER!!!
%     This chunk of logic included for when MPS is bypassed because we want
%     to use the spectrometer below 7keV.  Requires SATT TMIT below 25%.
%     (1/14/15 -Tonee)
%   And now even that is superceded by real MPS! fixed forever! 10/25/17
%
% trip if FEE spectrometer status unavailable, suggest gateway problems
% as possible source of error (NaNs)
%     if any(isnan([stats.fee_spectrometer_out, stats.fee_spectrometer_position]))
%if isnan(stats.fee_spectrometer_out)
%    trip = 1;
%    out.message = 'Cannot connect to FEE Spectrometer PVs - gateway down?';
%    return;
%else   %if FEE status is available...
%    %
%    % trip if FEE spectrometer is not OUT, photon energy too low, and there's not enough attenuation
%    if ctrl.fee_spectrometer_threshold > 0 % bypassed if threshold negative
%        if ~(stats.fee_spectrometer_out == 1)      
%        if (out.xray_energy < ctrl.fee_spectrometer_threshold) && (out.FEE_transmission > ctrl.fee_spectrometer_tmit)
%            trip = 1;
%            out.message = ['Photon energy below ' num2str(ctrl.fee_spectrometer_threshold) ' and TMIT too high for HXSpectrometer'];
%            return;
%        end
%        end
%    end
%end
% trip if phase cavity BAT amplifier switch is in high gain mode
% and the beam charge is above threshold.  This is
% only active if BAT_mon is able to switch the amp gain. -tjs 12/13/12

if stats.bat_threshold_active > 0 % bypassed if BAT_mon won't change the amp gain
    if ctrl.bat_threshold > 0 % bypass if guardian threshold negative
        if any(isnan(stats.bat_amplifier))
            trip = 1;
            out.message = 'Cannot connect to BAT phase cavity amplifier PVs - gateway?';
            return;
        end
        for bb = 1:4
            if (stats.dmp.maxtmit >= ctrl.bat_threshold) && stats.bat_amplifier(bb)
                trip = 1;
                out.message = ['BAT amplifier' num2str(bb) 'high gain active, charge (' num2str(stats.dmp.maxtmit) ...
                    ') > threshold (' num2str(ctrl.bat_threshold) ').'];
                return;
            end
        end
    end
end

% trip if new FEE JJ slits are not properly set up
% proper means eacb Si/N slit shadowed by corresponding TaW slit.
% "RIGHT" is +X, "TOP" is +Y
%
% PV                 Blade   Slit     Matl??
% =================  ======  ======== ====
% STEP:FEE1:451.RBV   RIGHT  UPSTREAM Si/N
% STEP:FEE1:452.RBV    LEFT  UPSTREAM Si/N
% STEP:FEE1:453.RBV     TOP  UPSTREAM Si/N
% STEP:FEE1:454.RBV  BOTTOM  UPSTREAM Si/N
% STEP:FEE1:455.RBV   RIGHT  DNSTREAM Ta/W
% STEP:FEE1:456.RBV    LEFT  DNSTREAM Ta/W
% STEP:FEE1:457.RBV     TOP  DNSTREAM Ta/W
% STEP:FEE1:458.RBV  BOTTOM  DNSTREAM Ta/W
%


%if stats.slit_protect > 0  % added 4/5/12 allow disable of slits
%    if ((abs(stats.jj_slits(5)) < abs(stats.jj_slits(1))) || ...
%            (abs(stats.jj_slits(6)) < abs(stats.jj_slits(2))) || ...
%            (abs(stats.jj_slits(7)) < abs(stats.jj_slits(3))) || ...
%            (abs(stats.jj_slits(8)) < abs(stats.jj_slits(4))))
%        trip = 1;
%        out.message = 'FEE JJ TaW slits not shielded';
%        return;
%    end
%end

%if ctrl.satt_threshold > 0       % bypassed if threshold negative
%    if (out.xray_energy < ctrl.satt_threshold)  && (stats.gatt_transmission > ctrl.gatt_threshold)
%        if any(stats.satts(1:8) ~= 2)       % 2 is OUT
%            attens_in = strcat(num2str((find(stats.satts(1:8) ~=2)')));
%            %            if ~any(stats.satts(3:6) == 1)   % 1 is IN
%            trip = 1;
%            out.message = ['FEE Solid attenuator(s) ' attens_in ' in, and ' ...
%                'x-ray energy below ' num2str(ctrl.satt_threshold) ...
%                ' without enough gas attenuation'];
%            return;
%            %            end
%        end
%    end
%end
end
%
end

%%
% 1 turns on beam
% 0 turn off beam
function beam_control(x, L)
global DISABLE_TRIP

tripped = lcaGetSmart(L.pv{L.trip_status_n,1});
newfbstate = lcaGetSmart('FBCK:FB04:LG01:STATE', 0, 'double');
newfbenable = {'FBCK:FB04:LG01:S4USED'; 'FBCK:FB04:LG01:S5USED'; 'FBCK:FB04:LG01:S6USED'};
old6x6state = lcaGetSmart('SIOC:SYS0:ML00:AO198', 0, 'double');
L2phasepv = {'ACCL:LI22:1:PDES'};
tdkludgepv = 'SIOC:SYS0:ML00:AO694'; % TDKLDGE

persistent pI; % holds old L0A I and Q
persistent pL2phase;
persistent newfbOnOffstats; %holds On/Off status for longitudinal feedbacks

if isempty(pI) % just put in default values
    pI = -6000;
end

if isempty(pL2phase)
    pL2phase = -36;
end

if isempty(newfbOnOffstats)
    newfbOnOffstats = [1; 1; 1]; %default = all ON
end

if x == 1  % Turn on beam
    if ~DISABLE_TRIP
        if old6x6state && ~newfbstate  %only use tdkludge if old6x6is on
            lcaPutSmart(tdkludgepv, 0);
        else
            lcaPutSmart(L2phasepv, pL2phase);           % unbackphase L2
            pause(5);
            %            lcaPut(newfbenable, [1; 1; 1]);            % re-enable new 6x6
            lcaPutSmart(newfbenable, newfbOnOffstats);  % restore feedbacks to saved states
        end
    end
    lcaPutSmart(L.pv{L.trip_status_n,1}, 0); % untrip
elseif x == 0 % Turn off beam
    if ~DISABLE_TRIP
        if old6x6state && ~newfbstate
            lcaPutSmart(tdkludgepv, 1);  %only use tdkludge if old6x6is on
        else
            if ~tripped
                pL2phase = lcaGetSmart('ACCL:LI22:1:PDES', 0, 'double');    % store old L2 phase
                newfbOnOffstats = lcaGetSmart(newfbenable,0,'double'); %store new fb stats
            end
            lcaPutSmart(newfbenable, [0; 0; 0]);       % disable new 6x6
            lcaPutSmart(L2phasepv, -178);              % backphase L2
        end
    end
    lcaPutSmart(L.pv{L.trip_status_n,1}, 1); % trip
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
pvname = ['SIOC:SYS0:ML00:AO', numstr];
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
