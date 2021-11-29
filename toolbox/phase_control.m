%phase_control.m
% controls injector, L2, L3 phases
% To fix:
% replace manual stuff with watcher class (cleanup).
% to change SLC phase readout by A.
% Sub booster pdes = pdes + A
% Sub booster sgold = sgold - A
% Klystron kgold = kgold - A


function phase_control()
disp('phase_control.m 1/24/09v2.1 ');
initial = struct; % will old initial state at program start

delay =0.01; % delay per loop
W = watchdog('SIOC:SYS0:ML00:AO057', ceil(1/delay), 'phase_control');
if get_watchdog_error(W)
    disp('Phase control is already running');
    return
end
num_pvs = 49;
pvs = cell(num_pvs, 1);
startpvnum = 57;
pvs{1,1} = setup_pv(startpvnum+1, 'Enable fancy phase control', 'ON/OFF', 4, 'USE WITH CARE');
pvs{2,1} = setup_pv(startpvnum+2, 'L2 Energy', 'MeV', 2, 'phase_control.m');
pvs{3,1} = setup_pv(startpvnum+3, 'BC1 phase delay', 'degS', 4, 'phase_control.m');
pvs{4,1} = setup_pv(startpvnum+4, 'L2 Phase control', 'degS', 4, 'phase_control.m');
pvs{5,1} = setup_pv(startpvnum+5, 'L2 Phase offset', 'degS', 4, 'Use to gold L2');
pvs{6,1} = setup_pv(startpvnum+6, 'BC2 phase delay', 'degS', 4, 'phase_control.m');
pvs{7,1} = setup_pv(startpvnum+7, 'L3 Phase control', 'degS', 4, 'phase_control.m');
pvs{8,1} = setup_pv(startpvnum+8, 'L3 phase offset', 'degS', 4, 'phase_control.m');
pvs{9,1} = 'LLRF:IN20:RH:REF_2_PDES'; % controls injector (mdl) phase shifter
pvs{10,1} ='LLRF:IN20:RH:L2_PDES';  % L2 phase shifter.
pvs{11,1} ='ACCL:LI24:100:KLY_POC'; % phase offset for feedback klystrons
pvs{12,1} ='ACCL:LI24:200:KLY_POC'; % 24-2 offset
pvs{13,1} ='ACCL:LI24:300:KLY_POC'; % 24-3 offset
pvs{14,1} = 'TCAV:LI24:800:TC3_PDES'; %Tcav phase (so far not needed)
pvs{15,1} = 'TCAV:LI24:800:TC3_0_POC'; % TCAV3 offset in
pvs{16,1} = 'TCAV:LI24:800:TC3_1_POC'; % TCAV3 offset out
pvs{17,1} = 'LLRF:IN20:RH:REF_1_S_PA.HIHI'; %
pvs{18,1} = 'LLRF:IN20:RH:REF_1_S_PA.HIGH';
pvs{19,1} = 'LLRF:IN20:RH:REF_1_S_PA.LOW';
pvs{20,1} = 'LLRF:IN20:RH:REF_1_S_PA.LOLO';
pvs{21,1} = setup_pv(startpvnum+9, 'Phase control BUSY', '.', 4, '1 means busy');
pvs{22,1} = 'SIOC:SYS0:ML00:AO278'; % L2 total energy from L23_set_phase
pvs{23,1} = setup_pv(startpvnum+10, 'L2 Fudge input', '.', 4, 'phase_control.m');
pvs{24,1} = setup_pv(80, 'BCH phase','degS', 4, 'phase_control.m'); % need to manually enter offset here
pvs{25,1} = 'LASR:IN20:1:LSR_0_POC'; % Laser phase offset
pvs{26,1} = 'GUN:IN20:1:GN1_0_POC'; % Gun Cell 1A offset
pvs{27,1} = 'GUN:IN20:1:GN1_1_POC'; % gun Cell 1B offset
pvs{28,1} = 'GUN:IN20:1:GN1_2_POC'; % gun Cell 1B offset
pvs{29,1} = 'GUN:IN20:1:GN1_3_POC'; % gun Cell 1B offset
pvs{30,1} = 'ACCL:IN20:300:L0A_0_POC'; % L-0-A in offset
pvs{31,1} = 'ACCL:IN20:300:L0A_1_POC'; % L-0-A out offset
pvs{32,1} = 'ACCL:IN20:400:L0B_2_POC'; % L-0-B in offset
pvs{33,1} = 'ACCL:IN20:400:L0B_3_POC'; % L-0-B out offset
pvs{34,1} = setup_pv(75, 'L3 Energy', 'MeV', 4, 'phase_control.m');
pvs{35,1} = setup_pv(79, 'L3 fudge input', ' ', 4, 'phase_control.m');
pvs{36,1} = 'SIOC:SYS0:ML00:AO279'; % L3 no feedback energy from L23_set_phse
pvs{37,1} = 'SIOC:SYS0:ML00:AO280'; % S29 flat energy
pvs{38,1} = 'SIOC:SYS0:ML00:AO281'; % S30 flat energy
pvs{39,1} = 'ACCL:LI29:0:KLY_POC' ; % phase offset for S29 pac
pvs{40,1} = 'ACCL:LI30:0:KLY_POC' ; % phase offset for S30 pac
pvs{41,1} = 'ACCL:LI29:0:KLY_PDES'; % phase for 29
pvs{42,1} = 'ACCL:LI30:0:KLY_PDES'; %phase for 30
pvs{43,1} = 'SIOC:SYS0:ML00:AO017'; % phase scans running.
pvs{44,1} = setup_pv(92, 'reserved', ' ', 4, 'phase_control.m');
pvs{45,1} = setup_pv(93, 'reserved', ' ', 4, 'phase_control.m');
pvs{46,1} = setup_pv(94, 'S29 phase', 'degS', 4, 'phase_control.m');
pvs{47,1} = setup_pv(95, 'S30 phase', 'degS', 4, 'phase_control.m');
pvs{48,1} = setup_pv(96, '24-1 phase', 'degS', 4, 'phase_control.m');
pvs{49,1} = setup_pv(97, '24-2 phase', 'degS', 4, 'phase_control.m');

lcaSetMonitor(pvs); % setup monitor
lcaNewMonitorValue(pvs); % check for new data
data = lcaGet(pvs);
initial.data = data; % data at start of program run

while 1  % Main LOOP
    W = watchdog_run(W); % this keeps the watchdog counter running
    if get_watchdog_error(W)
        disp('ome watchgod error, ignoring for now');
        pause(1);
    end
    try
        pause(delay);
        flags = lcaNewMonitorValue(pvs); % check for new data
        if sum(flags) > 0
            olddata = data; % save old value
            data = lcaGet(pvs); % get new data
            drive_phases(pvs, flags, data, olddata); % moves phases;
        end
    catch
        disp('Some sort of error'); % nothing else to do here
    end
end
end

% Move epics phases. Move SLC phases if we are really changing phase
function result = drive_phases(pvs, flags, data, olddata)
S29_pv = 'ACCL:LI29:0:KLY_PDES';  % PVs to use for phases, sector 29
S30_pv = 'ACCL:LI30:0:KLY_PDES'; % sector 30
klys1pv = 'ACCL:LI24:100:KLY_PDES';  % 24-1
klys2pv = 'ACCL:LI24:200:KLY_PDES';  % 24-2
result = 0; % unused for now
mdl_scale = -1/6; % scaling relative to s-band moving mdl.
l2_scale = -1; % minus sign in phase shifter
tcav3_scale = 1;  %  Not checked yet
fb_station_scale = 1; % For 24-1,2,3
S2930_station_scale = -1; %
injector_scale = 1;
station_energy = 240; % energy for single klystron (enlds are 168 and 228)??
s21_2856_scale = -1;
% L2 amplitude change, (also L2 fudge, and various enables).
if flags(1) || flags(2) || flags(22) || flags(23) || flags(43) % request new L2 FB energy
    requested_fb = data(2) - data(22) * data(23);
    if data(1) && ~data(43); % only do something if enabled
        [ph24_1_u ph24_2_u] = set_feedback_klystrons(data(4), requested_fb, station_energy); % l2phase, egain
        ph24_1 =ph24_1_u * fb_station_scale;  % correct for sign change
        ph24_2 =ph24_2_u * fb_station_scale;
        lcaPut({klys1pv; klys2pv; pvs{48,1}; pvs{49,1}}, [ph24_1; ph24_2; ph24_1_u; ph24_2_u]);  % Set phases of feedback klystrons.
    end
end

% BC1 Phase Delay
if flags(3) % move MDL, and L2 phase shifters, fix tcav3 phase
    change = -(data(3) - olddata(3)); % phase change in delay line
    new_phase = data(9) - change * mdl_scale; % change in MDL
    new_l2_phase = data(10) + change * l2_scale; % change in L2
    new_tcav3_phase_in = data(15) + change * tcav3_scale; % tcav phase
    new_tcav3_phase_out = data(16) + change * tcav3_scale; % we move the phase offsets
    s21HH = data(17) + change * s21_2856_scale; % set limits to keep S21 phase from alarming
    s21H = data(18) + change * s21_2856_scale;
    s21L = data(19) + change * s21_2856_scale;
    s21LL = data(20) + change * s21_2856_scale;
    lcaPut({pvs{9,1}; pvs{10,1}; pvs{15,1}; pvs{16,1}; pvs{17,1}; pvs{18,1}; pvs{19,1}; pvs{20,1}},  [new_phase;...
        new_l2_phase; new_tcav3_phase_in; new_tcav3_phase_out; s21HH; s21H; s21L; s21LL]); % write new phase to MDL.
end
% L2 phase or phase offset change
if flags(4) || flags(5)
    % move L2 phase shifter
    pchange = data(4) - olddata(4); % phase change
    ofchange = data(5) - olddata(5); % offset change
    change = pchange + ofchange;
    new_phase = data(10) + change * l2_scale; % change in L2 phase control
    s21HH = data(17) + change * s21_2856_scale;
    s21H = data(18) + change * s21_2856_scale;
    s21L = data(19) + change * s21_2856_scale;
    s21LL = data(20) + change * s21_2856_scale;
    % Now need to move 24-1,2,3 phase offset.
    fb_off(1) = data(11) - change * fb_station_scale;
    fb_off(2) = data(12) - change * fb_station_scale;
    fb_off(3) = data(13) - change * fb_station_scale;
    if (pchange ~= 0) && data(1) && ~data(43)  %if phase is changed, don't need if only offset has changed
        requested_fb = data(2) - data(22) * data(23);
        [ph24_1_u ph24_2_u] = set_feedback_klystrons(data(4), requested_fb, station_energy); % control feedback klystrons
        ph24_1 = ph24_1_u * fb_station_scale;
        ph24_2 = ph24_2_u * fb_station_scale;
        lcaPut({pvs{10,1}; pvs{11,1}; pvs{12,1}; pvs{13,1}; pvs{17,1}; pvs{18,1}; pvs{19,1};...
            pvs{20,1}; klys1pv; klys2pv; pvs{48,1}; pvs{49,1}},...
            [new_phase; fb_off(1); fb_off(2); fb_off(3); s21HH; s21H; s21L; s21LL; ph24_1; ph24_2;...
            ph24_1_u; ph24_2_u]); % write new phases
    else % don't need to change fb stations
        lcaPut({pvs{10,1}; pvs{11,1}; pvs{12,1}; pvs{13,1}; pvs{17,1}; pvs{18,1}; pvs{19,1}; pvs{20,1}},...
            [new_phase; fb_off(1); fb_off(2); fb_off(3); s21HH; s21H; s21L; s21LL]); % write new phases
    end
end
if flags(6)  %Change BC2 phase delay
    disp('BC2 phase delay change, moving MDL and TCAV3');
    change = -(data(6) - olddata(6)); % how much the BC2 phase moved
    new_phase = data(9) - change * mdl_scale; % change in MDL
    new_tcav3_phase_in = data(15) + change * tcav3_scale; % tcav phase
    new_tcav3_phase_out = data(16) + change * tcav3_scale;
    lcaPut({pvs{9,1}; pvs{15,1}; pvs{16,1}}, [new_phase; new_tcav3_phase_in;...
        new_tcav3_phase_out]); % write new phase to MDL, etc.
end
if flags(7) || flags(8) % L3 phase or offset change.
    pchange = data(7) - olddata(7);
    ofchange = data(8) - olddata(8);
    change = pchange + ofchange;
    new_phase = data(9) - change * mdl_scale; % change MDL phase
    S29_new = data(39) - change * S2930_station_scale; % move phase offsets
    S30_new = data(40) - change * S2930_station_scale;
    if (pchange ~= 0) && data(1) && ~data(43)
        requested_fb3 = data(34) - data(35) * data(36); % request - L3enegy*fudge
        [S29_u S30_u] = set_feedback_stations(data(7), requested_fb3, data(37), data(38)); % Feedback Sectors
        S29 = S29_u * S2930_station_scale;  % phases for fb stations
        S30 = S30_u * S2930_station_scale;
        lcaPut({pvs{9,1}; pvs{39,1}; pvs{40,1}; S29_pv; S30_pv; pvs{46,1}; pvs{47,1}},...
            [new_phase; S29_new; S30_new; S29; S30; S29_u; S30_u]);
    else
        lcaPut({pvs{9,1}; pvs{39,1}; pvs{40,1}}, [new_phase; S29_new; S30_new]); % correct feedback stations
    end
end
if flags(24) % Laser Heater chicain phase change.
  change = data(24) - olddata(24);
  newphase = zeros(9,1);
  newpv = cell(9,1);
  for j = 25:33 %the injector phases to change
    newphase(j-24) = data(j) + change * injector_scale; % these are the gun, L0A etc, phase offsets
    newpv{j-24,1} = pvs{j,1};
  end
  lcaPut(newpv, newphase);
end
if flags(1) || flags(34) || flags(35) || flags(36) || flags(37) || flags(38) || flags(43)
  % Change in L3 energy, or things that contribute to L3 energy.
  requested_fb3 = data(34) - data(35) * data(36); % request - L3enegy*fudg
  [S29_u S30_u] = set_feedback_stations(data(7), requested_fb3, data(37), data(38));
  S29 = S29_u * S2930_station_scale;
  S30 = S30_u * S2930_station_scale;
  lcaPut({S29_pv; S30_pv; pvs{46,1}; pvs{47,1}}, [S29; S30; S29_u; S30_u]); % move feedback stations
end
end

function [klys1ph klys2ph] = set_feedback_klystrons(l2phase, egain, station_energy)
if abs(egain) > 2*station_energy
  egain = 2*station_energy * sign(egain); % fix if out of range
end
ex = egain / station_energy / 2; % energy change per station
ph = 180/pi*acos(ex); % phase offset required
klys1ph = l2phase + ph; % minus sign for consistancy with old setup
klys2ph = l2phase - ph;
end

function [S29ph S30ph] = set_feedback_stations(l3phase, egain, station_energy1,...
  station_energy2)
if abs(egain) > (station_energy1 + station_energy1) % this is both control devices.
    egain = sign(egain) * (station_energy1 + station_energy2);
end
ex = egain / (station_energy1 + station_energy2);
ph = (180/pi)*acos(ex);
S29ph = l3phase - ph; % minus sign for consistancy with old setup
S30ph = l3phase + ph;
end


% This routine generates pv names, initializes diasplays
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


%function to find comment field name from pv
% Just a stupid function to save time since we do this a lot.
function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end


