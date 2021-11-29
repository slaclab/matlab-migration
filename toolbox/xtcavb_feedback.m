%xtcav_feedback.m
% magicCal     = 682;          % magic xtcav calibration number
% S(mm/deg) = magicCal * MV / GeV
% controls tcav phase to hold bunch fixed on bpms.
function xtcavb_feedback()

appName='xtcavb_feedback.m';

%{
% Disabled special eDef for XTCAV as it's the same as BR
eDefNum = eDefReserve('xtcav_feedback');
if ~ eDefNum
    disp(' could not reserve edef for tcav');
    return;
end
navg = 1; % no averages
npos = -1; % only 1 data apoint
eDefParams(eDefNum, navg, npos, {''}, {''}, {''}, {''});
eDefOn(eDefNum);
exten = num2str(eDefNum);
%}
exten = 'CUSBR';

disp('XTCAVB feedback 11/24/20 version 1.0');
lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.

% For magic phase flip
magicCal = 0.855*.43; % mm*GeV/(degX*MV) 
% magicCal was measured as 0.905634 for BPMDD
% It is 40% smaller on BPMQD which we use now
% [scale this w/ E and V]
% The factor of 0.4 is to scale the number for BPM 693 to the weaker
% response on BPM 502 in DMPH.


scale = -1/magicCal; % convert bpm reading to tcav phase, [MV deg/mm/GeV]
delay = 0.1; % Feedback loop delay [s]
max_phase_error = 2; % [deg]
max_amplitude_error = 1; % in abs units [MV]
%max_amplitude = 85; % [MV]
max_bpm = 8; % Orbit amplitude difference for warning [mm]
%standby_amplitude = 85; % [MV]
min_amplitude = 5; % minimum RF [MV]
min_amp_multi = 3; % amplitude if beam bad = min_amplitude * min_amp_multi
amplitude_step = .2; % maximum step in amplitude each cycle [MV]
min_charge = 31250000; % Minimum charge upstream of tcav [Nel]
min_charge_ratio = 0.75; % minimum transmission through tcav to continue running
max_tcav_bad_pulses = 5000; % number of bad tcav pulses before ramping down
tcav_last_gui_on = 0; % assumes originally off
off_axis_amp_min = 20; % Only go off axis when the amplitude is > than this
a = 0;
pv = cell(7,1);
a = a + 1;
front_bpm_x_num = a;
pv{a,1} = ['BPMS:DMPS:325:X', exten];
a = a + 1;
front_bpm_y_num = a;
pv{a,1} = ['BPMS:DMPS:325:Y', exten];
a = a + 1;
front_bpm_t_num = a;
pv{a,1} = ['BPMS:DMPS:325:TMIT',exten];
a = a + 1;
tcav_bpm_x_num = a;
pv{a,1} = ['BPMS:DMPS:502:X', exten];
a = a + 1;
tcav_bpm_y_num = a;
pv{a,1} = ['BPMS:DMPS:502:Y', exten];
a = a + 1;
tcav_bpm_t_num = a;
pv{a,1} = ['BPMS:DMPS:502:TMIT', exten];
a = a + 1;
tcav_phase_num = a;
pv{a,1} = 'TCAV:DMPS:360:PDES';
a = a + 1;
tcav_phase_rb_num = a;
pv{a,1} = 'TCAV:DMPS:360:S_PV';
a = a + 1;
tcav_amplitude_num = a;
pv{a,1}  = 'TCAV:DMPS:360:ADES';
a = a + 1;
tcav_amplitude_rb_num = a;
pv{a,1}  = 'TCAV:DMPS:360:S_AV';
a = a + 1;
tcav_status_num = a;
%pv{a,1} = 'LI24:KLYS:81:SWRD';
pv{a,1} = 'KLYS:DMPH:1:MOD';
%pv{a,1} = 'TCAV:DMPH:360:TCA_SBY_TDES';
a = a + 1;
tcav_mod_power_num = a;
pv{a,1}  = 'KLYS:DMPH:1:RF_DRV';
a = a + 1;
dump_bend_energy_num = a;
pv{a,1}  = 'REFS:DMPS:400:EDES';
a = a + 1;
bpm_setpoint_num = a;
n0 = 162;
pv{a,1} = setup_pv(n0+1, 'XTCAV off axis bpm offset', 'mm', 3, appName);
a = a + 1;
bpm_typical_num = a;
pv{a,1} = setup_pv(n0+2, 'XTCAV on axis bpm set', 'mm', 3, appName);
a = a + 1;
tcav_gain_num = a;
pv{a,1} = setup_pv(n0+3, 'tcav gain', ' ', 2, appName);
a = a + 1;
beam_bad_num = a;
pv{a,1} = setup_pv(n0+4, 'tcav beam bad', ' ',0, appName);
a = a + 1;
tcav_bad_num = a;
pv{a,1} = setup_pv(n0+5, 'tcav rf bad', ' ',0, appName);
a = a + 1;
tcav_amplitude_target_num = a;
pv{a,1} = setup_pv(n0+6, 'tcav amplitude target', ' ',2, appName);
a = a + 1;
tcav_amplitude_ramp_num = a;
pv{a,1} = setup_pv(n0+7, 'tcav ramp amplitude', ' ',2, appName);
a = a + 1;
phase_sign_num = a;
pv{a,1} = setup_pv(n0+8, 'tcav sign', ' ',0, appName);
a = a + 1;
all_ok_num = a;
pv{a,1} = setup_pv(n0+9, 'tcav all OK', ' ',0, appName);
a = a + 1;
tcav_on_num = a;
pv{a,1} = setup_pv(n0+10, 'tcav ON', ' ',0, appName);
a = a + 1;
tcav_max_amp = a;
pv{a,1} = setup_pv(n0+11, 'tcav max amp', ' ',2, appName);
a = a + 1;
%tcav_gui_on_num = a;
%pv{a,1} = 'SIOC:SYS0:ML00:AO603'; % need to look at in detail (found on 06/20/2016...)
stby_amp_req_num = a;
pv{a,1} = 'SIOC:SYS0:ML05:AO174'; % ...about that.
a = a + 1;
tcav_rate_num = a;
%pv{a,1} = 'EVNT:SYS0:1:LCLSTCV3RATE';
%pv{a,1} = 'EVNT:SYS0:1:LCLSBURSRATE'; % No special XTCAV rate, use beam rate for now
pv{a,1} = 'EVNT:SYS0:1:LCACC_10RATE'; % No special XTCAV rate, use 10 Hz beam rate for now

setup_pv(n0, 'xtcavb feedback counter', ' ', 0, appName);
W = watchdog('SIOC:SYS0:ML05:AO162', 1, 'tcav feedback counter' );
if get_watchdog_error(W)
    disp('Another XTCAVB feedback is running, exiting');
    return
end
% -- added 06/20/2016
a = a+1;
stby_timeout_min_num = a;
pv{a,1} = 'SIOC:SYS0:ML05:AO175';
a = a+1;
stby_countdown_min_num = a;
pv{a,1} = 'SIOC:SYS0:ML05:AO176';
a = a+1;
off_axis_enable_num = a;
pv{a,1} = 'SIOC:SYS0:ML05:AO177';
s = pv([stby_amp_req_num,...
    stby_timeout_min_num,...
    stby_countdown_min_num,...
    off_axis_enable_num]);
lcaPutSmart(strcat(s, '.DESC'),...
    {'Stby watcher enable';...
    'Stby timer duration';...
    'Stby timer countdown';...
    'XTCAVB off axis enable'});
lcaPutSmart(strcat(s, '.EGU'),{'';'min';'min'});
lcaPutSmart(strcat(s, '.PREC'),[0;0;0]);
lcaPutSmart(s{4},0);
for k = 1:length(s)
    lcaPutSmart(pv_to_comment(s{k}),appName);
end
stby_last_accl = now;
stby_do_ramp = 0;
off_axis_enable = 0; % User wants to be off axis
off_axis = 0;        % Current off axis setting 
off_axis_last = false;   % Off axis setting on last iteration
tcav_last_on = 0;
% --
tcav_bad_count = 0; % number of bad tcav pulses

count = 0;
ramp_target = min_amplitude; % this is the moving ramp with beam loss
while 1
    W = watchdog_run(W); % run watchdogcounter
    if get_watchdog_error(W) % some error
        disp('Some sort of watchdog timer error'); % Just drop for now
        pause(1);
        continue;
    end
    beam_bad = 0;
    tcav_bad = 0;
    beam_lost = 0;
    tcav_on = 0;
    all_ok = 0;
    comp = 0;
    count = count + 1;
    pause(delay);
    try
        data = lcaGetSmart(pv,0,'double'); % XTCAV MOD PV native is enum
    catch
        disp('error on lcaGet');
        pause(1);
        continue
    end
    bpm = data(tcav_bpm_x_num);
    %disp(bpm);
    amplitude = data(tcav_amplitude_num);
    amplitude_rb = data(tcav_amplitude_rb_num);
    amplitude_target = data(tcav_amplitude_target_num);
    gain = data(tcav_gain_num);
    phase = data(tcav_phase_num);
    phase_rb = data(tcav_phase_rb_num);
    phase_sign = data(phase_sign_num);
    sgn = sign(phase);
    input_charge = data(front_bpm_t_num);
    output_charge = data(tcav_bpm_t_num);
    bpm_off_axis = data(bpm_setpoint_num);
    %tcav_gui_on = data(tcav_gui_on_num);
    rate = data(tcav_rate_num);
    energy = data(dump_bend_energy_num);
    stby_timeout_min = data(stby_timeout_min_num);
    stby_amp_req = data(stby_amp_req_num);
    max_amplitude = data(tcav_max_amp);
    off_axis_enable_req = logical(data(off_axis_enable_num));
    
    % Let's decide on/off axis phase jumps first.
    if ~off_axis_last && off_axis_enable_req && ... % 
            (amplitude >= off_axis_amp_min) % Was off axis but user requests to go off axis and amplitude allows it
        % Then we jump off axis
        dphi = bpm_off_axis / (magicCal*amplitude/energy);
        phase = phase + (dphi) * sign(phase_sign);
        off_axis = 1;
    elseif ((off_axis_last) && (amplitude < off_axis_amp_min)) || ... % it was off axis but amplitude is now too low or...
        (off_axis_last && ~off_axis_enable_req) % it was off axis and now user requests it not to be
        % Then we jump back on axis
        dphi = bpm_off_axis / (magicCal*amplitude/energy);
        phase = phase - (dphi) * sign(phase_sign);
        off_axis = 0;
    end
    if off_axis ~= off_axis_last % Axis change
        lcaPut(pv{tcav_phase_num,1},phase); % Jump now and continue
        off_axis_last = off_axis;
        pause(.1)
        continue 
        % We don't want to confuse the axis jump with phase feedback with
        % gain or a phase flip later. Probably we need to do this right
        % below, if the FB drops amplitude to immediately do a phase jump
        % at the same time the amplitude is dropped.
    end
    % Otherwise, bpm set point determined by whether or not to be off axis
    bpm_setpoint = bpm_off_axis*off_axis + data(bpm_typical_num);
    
    if count == 1
        last_bpm = bpm;
        continue
    end
    amplitude = max(amplitude, min_amplitude);
    if amplitude_rb < min_amplitude
        tcav_bad = 1;
    end
    if abs(amplitude - amplitude_rb) > max_amplitude_error
        tcav_bad = 1;
    end
    if abs(phase - phase_rb) > max_phase_error * max_amplitude / amplitude
        tcav_bad = 1;
    end
    if (rate <= 0)          % limit loop speed when tcav is off
        pause(1);
    end
    if gain <= 0
        pause(.1);
        comp = 1; % Set compute mode
%        continue;
    end
    if bpm == last_bpm || isnan(bpm) % repeated measurement or no beam
        comp = 1;
%        continue;
    end
%    if bitand(data(tcav_status_num), 2^15)
    if data(tcav_status_num) ~= 1 %|| ~(data(tcav_mod_power_num) > 0) %comment: just means we're in stby
%    if data(tcav_status_num) > -30000 || ~(data(tcav_mod_power_num) > 0)
        tcav_bad = 1;
        if ~comp
            tcav_bad_count = tcav_bad_count + 1;
        end
%        if tcav_bad_count > max_tcav_bad_pulses % too many bad pulses, start recovery
%            beam_lost = 1; % no tcav, initiate recovery % how does stby for many pulses mean beam lost?
%        end
    else
        tcav_on = 1;
        tcav_bad_count = 0;
    end

    %if bpm == 0;
    %    beam_bad = 1;
    %end
    if bpm < -15 || bpm > 16
        beam_bad = 1;
        beam_lost = 1;
    end
    if abs(bpm - bpm_setpoint) > max_bpm
        big_orbit = 1;
    else
        big_orbit = 0;
    end
    if input_charge < min_charge % no beam do nothing
        comp = 1;
%        continue;
    end
    if output_charge / input_charge < min_charge_ratio  % beam loss
        beam_bad= 1;
        beam_lost = 1;
    end

    try
        lcaPut(pv([tcav_bad_num tcav_on_num beam_bad_num]), ...
            [tcav_bad;tcav_on;beam_bad]);
    catch
        disp('some lca error');
    end
    
    if comp
        try
            lcaPut(pv(all_ok_num),all_ok);
        catch
            disp('some lca error');
        end
        continue
    end
    
    % Calculate any 180 deg phase flip
     phase_flip = 0;
    if ((phase_sign > 0) && (phase < 0)  && (phase_rb < 0)) || ...% switch phase
            ((phase_sign < 0) && (phase > 0)  && (phase_rb > 0))
        %beam_lost = 1;
        dphi = 2*bpm_off_axis / (magicCal*amplitude/energy) * off_axis; % only include if off axis
        phase = phase + (180 + dphi) * sign(phase_sign);
        phase_flip = 1;
    end
    % Calculate feedback
    last_bpm = bpm;
    if ~beam_lost && ~(beam_bad || tcav_bad)
        deltaphase = sgn * scale * gain * energy * (bpm-bpm_setpoint) / amplitude;
        if abs(deltaphase) > 0.5 * max_amplitude / amplitude % limit to 0.5 deg
            deltaphase = .5 * sign(deltaphase);
        end
        if ~phase_flip
            phase = phase + deltaphase;
        end
    end
    
    
    if (~tcav_on && tcav_last_on) || ...
            ((amplitude == max_amplitude) && ~tcav_last_on)
        stby_last_accl = now;
    end; %just turned off or was already okay (at max amp)
    if ~tcav_on && stby_amp_req
        if amplitude ~= max_amplitude
            stby_countdown_min = stby_timeout_min - (now - stby_last_accl)*1440;    
            if stby_do_ramp
                ramp_target = max_amplitude;
                stby_countdown_min = stby_timeout_min;
            elseif stby_countdown_min <= 0
                ramp_target = max_amplitude;
                % reset the countdown timer
                stby_countdown_min = stby_timeout_min;
                stby_last_accl = now;
                stby_do_ramp = 1;
            end
            try
                lcaPutSmart(pv(stby_countdown_min_num),stby_countdown_min);
            catch
                disp('some lca error')
            end
        else
            stby_do_ramp = 0;
        end
    end
    if tcav_on && ~tcav_last_on
        stby_countdown_min = stby_timeout_min;
        stby_do_ramp = 0;
        try
            lcaPutSmart(pv(stby_countdown_min_num),stby_countdown_min);
        catch
            disp('some lca error')
        end
    end
    tcav_last_on = tcav_on;
    
    amplitude_target = min(amplitude_target, max_amplitude);
    amplitude_target = max(amplitude_target, min_amplitude);
    if ~beam_bad || stby_do_ramp
        if ramp_target > amplitude
            amplitude = amplitude + amplitude_step;
            amplitude = min(amplitude, ramp_target);
        elseif ramp_target < amplitude
            amplitude = amplitude - amplitude_step;
            amplitude = max(amplitude, ramp_target);
        end
    end
%    try
%        if tcav_gui_on ~= tcav_last_gui_on  % state change
%            if tcav_gui_on
%                lcaPut(pv{tcav_amplitude_num,1}, min_amplitude);
%            else
%                lcaPut(pv{tcav_amplitude_num,1}, standby_amplitude);
%            end
%        end
%    catch
%        disp('problem setting up standby operation');
%    end
%    tcav_last_gui_on = tcav_gui_on; 

% now check phase sign

    if beam_lost || (stby_do_ramp && stby_amp_req)% Beam didn't make it, ramp down. Or stby ramp, go up!
        if tcav_on %tcav_gui_on
            if min_amplitude * min_amp_multi < amplitude_target
                d = min_amplitude * min_amp_multi;
            else
                d = min_amplitude;
            end
            ramp_target = d;
            amplitude = d;
%        else
%            ramp_target = data(tcav_max_amp);%max_amplitude;
%            amplitude = data(tcav_max_amp);%max_amplitude;
        end
        try
            lcaPut({pv{tcav_amplitude_ramp_num,1};...
            pv{tcav_amplitude_num,1}; pv{all_ok_num}},...
            [ramp_target; amplitude; all_ok]);
        catch
            disp('another lca error');
        end
        pause(2) % recovery from lost beam
    end

    if ~beam_lost && (beam_bad || tcav_bad)
        try
            lcaPut({pv{tcav_amplitude_ramp_num,1}; pv{all_ok_num, 1}},...
            [ramp_target; all_ok]);
        catch
            disp('some lca error');
        end
    end

    if ~beam_lost && ~(beam_bad || tcav_bad)
        ramp_target = amplitude_target;  % good beam, run ramp up to full.
        if (amplitude == amplitude_target) && ~big_orbit
            all_ok = 1;
        end
%         if phase_flip
%             lcaPut('KLYS:DMPH:1:MOD_SET',2); % Turn off for phase flip
%             pause(2);
%         end
        try
            lcaPut({pv{tcav_phase_num,1}; pv{tcav_amplitude_num,1};...
            pv{tcav_amplitude_ramp_num,1}; pv{all_ok_num}},...
            [phase; amplitude; ramp_target; all_ok]);
        catch
            disp('error in lca put');
        end
%         if phase_flip
%             pause(2); % Wait for phase flipping
%             lcaPut('KLYS:DMPH:1:MOD_SET',1); % Turn on for phase flip
%             pause(2);
%         end
    end

end


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
pvname = ['SIOC:SYS0:ML05:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);


function out = pv_to_comment(pv)

str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
