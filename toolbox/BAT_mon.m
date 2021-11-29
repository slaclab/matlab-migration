function BAT_mon()

disp_log('BAT_mon.m  Version 10.5 11/9/17');

%% initialization
static = BAT_init();
sname = 'BAT_mon.m';
stat_size = 100;            % size of statistics buffer

%% start watchdog
W = watchdog(static.pv.watchdog, 5, 'BAT_mon.m');
if get_watchdog_error(W)
    disp_log('BAT_mon is already running - exiting!');
    return
end

%% setup matlab PVs for input/output

% set which set of matlab PVs to use here
sysx = 'SYS0';
mlxx = 'ML00';

% call script_setupPV, which puts the description, units, precision and
% comment to the PVs passed

% script inputs
script_setupPV(static.pv.in.charge_max,     'Full signal charge',   'pC',       2,   sname,   sysx,   mlxx);
script_setupPV(static.pv.in.time_ctrl,      'Time control',         'ps',       3,   sname,   sysx,   mlxx);
script_setupPV(static.pv.in.amp_threshold,  'Amplifier charge threshold', 'pC',      1,   sname,   sysx,   mlxx);
script_setupPV(static.pv.in.dac_scale,      'DAC scale',            'V',        2,   sname,   sysx,   mlxx);
script_setupPV(static.pv.in.phase_jump_tol, 'Phase jump tolerance', 'ps',       2,   sname,   sysx,   mlxx);

% script outputs
script_setupPV(static.pv.out.phase_shifter(1), 'Phase control NEH',        'rad476',   3,   sname,   sysx,   mlxx);
script_setupPV(static.pv.out.phase_shifter(2), 'Phase control FEH',        'rad476',   3,   sname,   sysx,   mlxx);
%script_setupPV(static.pv.out.mon_119,       '119 MHz monitor',      'rad119',   4,   sname,   sysx,   mlxx);
script_setupPV(static.pv.out.phase_shift_ps(1),'Phase shift NEH',          'ps',       3,   sname,   sysx,   mlxx);
script_setupPV(static.pv.out.phase_shift_ps(2),'Phase shift FEH',          'ps',       3,   sname,   sysx,   mlxx);
script_setupPV(static.pv.out.diff_noise,    '(Cav1 - Cav2) noise',  'ps',       4,   sname,   sysx,   mlxx);
script_setupPV(static.pv.out.diffs,         'Difference signals',   'ps',       3,   sname,   sysx,   mlxx);

% per-cavity controls
cnames = cellstr(num2str(linspace(1, static.num.cavities, static.num.cavities)')); % cellstr array of cavity numbers

script_setupPV(static.pv.in.cav.scale,      strcat('Cav', cnames, ' scale (in)'),           'arb',  2, sname, sysx, mlxx);
script_setupPV(static.pv.in.cav.offset,     strcat('Cav', cnames, ' phase offset (in)'),    'ps',   3, sname, sysx, mlxx);
script_setupPV(static.pv.in.cav.gain,       strcat('Cav', cnames, ' attenuator (in)'),      '1:15', 0, sname, sysx, mlxx);
script_setupPV(static.pv.in.cav.fbgain,     strcat('Cav', cnames, ' feedback gain (in)'),   'arb',  4, sname, sysx, mlxx);
script_setupPV(static.pv.in.cav.starttime,  strcat('Cav', cnames, ' start time (in)'),      'ps',   3, sname, sysx, mlxx);

script_setupPV(static.pv.out.cav.charge,    strcat('Cav', cnames, ' charge (out)'),         'pC',   2, sname, sysx, mlxx);
script_setupPV(static.pv.out.cav.time,      strcat('Cav', cnames, ' time (out)'),           'ps',   3, sname, sysx, mlxx);
script_setupPV(static.pv.out.cav.freq,      strcat('Cav', cnames, ' frequency-2805 (out)'), 'MHz',  4, sname, sysx, mlxx);
script_setupPV(static.pv.out.cav.maxcounts, strcat('Cav', cnames, ' max dig counts (out)'), 'cts',  0, sname, sysx, mlxx);
script_setupPV(static.pv.out.cav.std,       strcat('Cav', cnames, ' std deviation (out)'),  'ps',   3, sname, sysx, mlxx);
script_setupPV(static.pv.out.cav.diff,      strcat('Cav', cnames, ' diff to Cav 1 (out)'),  'ps',   3, sname, sysx, mlxx);
script_setupPV(static.pv.out.cav.q,         strcat('Cav', cnames, ' Q (out)'),              'arb',  1, sname, sysx, mlxx);

%% get initial data

[new, new_ts, new_isPV] = BAT_collect(static);
counter = 0;
good = 1;

%% main loop

while 1

%% save data struct from last iteration, if it was good

    if good
        old         = new;
        old_ts      = new_ts;
        old_isPV    = new_isPV;
    end

%% loop wait and watchdog here

    pause(static.fbck.delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog error');
        break;  % Exit program
    end
    
    
%% collect data

    [new, new_ts, new_isPV] = BAT_collect(static);
    out = new.out;
    ctrl = new.ctrl;
    
%% reset "valid" flag

    good = 1;

%% check for valid attenuator & amplifier controls

    attengood = ...
        ~any(any(isnan(new.charge))) && ...             % BPM global attenuation
        ~any(any(isnan(new.in.charge_max))) && ...      % Max charge threshold
        ~any(any(isnan(new.ctrl.atten))) && ...         % Attenuator controls
        ~any(any(isnan(new.ctrl.amp)));                 % High gain amplifier switch

    good = good && attengood;
    
%% set correct amp and attenuator settings

    if attengood
        charge_ratio = 1e3 * new.charge / new.in.charge_max;
        % for now, just use attenuator #1
        attenuator = find(charge_ratio * static.atten.gain >= 1, 1, 'first');
        if isempty(attenuator)
            attenuator = 15;
        end
        amplifier = (1e3 * new.charge) < new.in.amp_threshold;
        if any(new.ctrl.amp ~= amplifier)
            disp_log(strcat({'Switching high gain amplifier to '}, num2str(amplifier)));
            isPV = lcaPutSmart(static.pv.ctrl.amp', repmat(double(amplifier), size(static.pv.ctrl.amp')));
            if ~all(isPV)
                disp_log('Problem switching amplifier');
            end
            continue;
        end
        if any(new.ctrl.atten ~= attenuator)
            disp_log(strcat({'Switching to attenuator number '}, num2str(attenuator)));
            isPV = lcaPutSmart(static.pv.ctrl.atten', attenuator);
            if ~all(isPV)
                disp_log('Problem switching attenuator');
            end
            continue;
        end
    end

%% check for valid trigger controls

    triggood = ...
        ~any(any(isnan(new.trig.enable))) && ...            % Trigger enable bits
        ~any(any(isnan(new.trig.eventcode))) && ...         % Event codes
        ~any(any(isnan(new.trig.eventcode_enable))) && ...  % Event code enable bits
        ~any(any(isnan(new.trig.delay)));                   % Trigger delay

    good = good && triggood;
    
%% set up triggering properly
    
    if triggood        
        % default delay is the old delay
        delay = new.trig.delay;
        % see which event slots are enabled
        enabled_events = new.trig.enable & new.trig.eventcode_enable;
        if sum(enabled_events) < 1
            disp_log('Phase cavity DAQ trigger not active on any event code - leaving timing alone');
        elseif sum(enabled_events) > 1
            disp_log('Phase cavity DAQ trigger active on multiple event codes - leaving timing alone');
        else
            % find the current active event code
            active_eventcode = new.trig.eventcode(find(enabled_events));
            % look up the corresponding delay in static.trig.delay
            row = find(static.trig.delay(1,:) == active_eventcode);
            if isempty(row)
                disp_log(['Unknown delay for event code ' num2str(active_eventcode)]);
                delay = new.trig.delay;
            elseif numel(row) > 1
                disp_log('Multiple event codes active');
                delay = new.trig.delay;
            else
                delay = static.trig.delay(2, row);
            end
        end
        % if the new delay is different, update it
        if (new.trig.delay - delay) ~= 0
            disp_log(['Changing phase cavity trigger ' static.pv.dig.trigger ' from ' ...
                num2str(new.dig.trigger) ' to ' num2str(delay)]);
            lcaPutSmart(static.pv.dig.trigger, delay);
            continue;
        end
    end
    
    
%% check BAT chassis status bits

    % only worry about chassis 1 and 2
    % 0 is OK, 1 is error
    statgood = ~any(new.status(1:2));
    if ~statgood
        disp_log(strcat({'Interrupt fault: '}, num2str(new.status)));
    end
    good = good && statgood;
    

%% check for fresh waveform

    longpause = 10; % reduce frequency of error messages to 0.1 Hz if no new data
    newdata = (lca2matlabTime(old.ts) < lca2matlabTime(new.ts));
    if ~newdata
        if new.rate > 0
            disp_log(['Digitizer data is stale, timestamp is ' datestr(lca2matlabTime(new.ts))]);
            pause(longpause);
        end
    end
    good = good && newdata;
    
%% check for communication OK with phase shifter controls

    if any(isnan(new.ctrl.dac))
        disp_log('Read failure from phase shifter controls');
        good = 0;
    end

%% check for other valid PVs
    
    % check for valid data - lcaGetStruct returns nan's for invalids
    good = good && ...
            ~any(any(isnan(new.raw)));    % TODO add more
    
%% bail out if something's wrong
        
    if ~good
        continue;
    end
    
%% if we made it here, all the acquisition was OK
    
    % do analysis
    calc = BAT_calc(static, new);
    
%% check for reasonable results
    if ~all([(calc.fit.charge > 0); ...
             (calc.fit.maxcounts > 0); ...
            % add more here
            ])
        good = 0;
        disp('Some results are non-physical.');
        continue
    end

%% check signal is above threshold

    signalgood = (max(calc.fit.maxcounts) > static.fbck.dig_threshold);
    if ~signalgood
        % disp_log(['Max signal (' num2str(max(calc.fit.maxcounts)) ...
        %          ') below threshold (' num2str(static.fbck.dig_threshold) ').']);
        continue;
    end
    good = good && signalgood;
    
%% resync if necessary

    resync = 0;
    if (abs(calc.fit.time(2)) > new.in.phase_jump_tol) && ...
       (calc.fit.charge(2) > static.fbck.q_threshold) && ...
       isfinite(calc.fit.charge(2))
        % phase jump detected, fix it
        disp_log(['Phase jump (' num2str(calc.fit.time(2)) 'ps) detected - trying resync']);
        % toggle resync bit
        lcaPutSmart(static.pv.resync, 1);
        pause(0.2);
        lcaPutSmart(static.pv.resync, 0);
        % toggle digitizer trigger to disarm and then back to arm-auto
        pause(0.2);
        lcaPutSmart(static.pv.dig.arm, 0);
        pause(0.2);
        lcaPutSmart(static.pv.dig.arm, 2);
        resync = 1;
    end
    
    good = good && ~resync;
    

%% calculate delta phase

    % see which bat chassis have gain
    ison = new.in.cav.fbgain > 0;
    % calculate desired phase change for each chassis
    des_phases = static.fbck.gain_multiplier * (new.in.cav.fbgain .* calc.fit.time);

    % average those cavities that are on
    % map BAT chassis 1 and 4 to phase shifter 1 (NEH)
    % map BAT chassis 2 and 3 to phase shifter 2 (FEH)
    if sum(ison([2 3])), d_phases(1) = sum(des_phases([2 3])) / sum(ison([2 3])); else d_phases(1) = 0; end
    if sum(ison([1 4])), d_phases(2) = sum(des_phases([1 4])) / sum(ison([1 4])); else d_phases(2) = 0; end
    
    old_phases = new.out.phase_shifter;
    
%     d_phase = mean(static.fbck.gain_multiplier * new.in.cav.fbgain * calc.fit.time');
%     old_phase = new.out.phase_shifter;
    
%% calculate new phase controls (this is upstream phase shifter)

    new_phases = old_phases;
    for jx = 1:numel(new_phases)
        if (calc.fit.charge(jx) > static.fbck.q_threshold) && good
            new_phases(jx) = old_phases(jx) + d_phases(jx);
        end
    end
    
    phase_shift_ps = new_phases / (2 * pi * 476e6) * 1e12;

%% calculate new "time" controls (this is downstream phase shifter)
    
    if abs(old.in.time_ctrl - new.in.time_ctrl) < static.fbck.maxstep
        last_time_ctrl = new.in.time_ctrl;
    else
        last_time_ctrl = old.in.time_ctrl + sign(new.in.time_ctrl - old.in.time_ctrl) * static.fbck.maxstep;
    end
    
    time_radians = last_time_ctrl * 1e-12 * 2 * pi * 476e6;
    
%% update statistics buffer

        % update circular buffer
        ix = mod(counter, stat_size) + 1;
        counter = counter + 1;
        
        
        % store results in buffer
        hist.charge(ix, :) =    calc.fit.charge;
        hist.time(ix, :) =      calc.fit.time;
        hist.freq(ix, :) =      calc.fit.freq;
        hist.maxcounts(ix, :) = calc.fit.maxcounts;
        hist.diffs(ix, :) =     calc.fit.diffs;
        hist.q(ix, :) =         calc.fit.q;

        % calculate stats
        stats.mean = structfun(@(v) mean(v, 1), hist, 'UniformOutput', 0);
        stats.std = structfun(@(v) std(v, 0, 1), hist, 'UniformOutput', 0);
    
%% prepare output structure

    % copy values over from input
    output.out = new.out;
    output.ctrl = new.ctrl;
    output.bld = new.bld;

    % copy PV names from static
    outnames.out = static.pv.out;
    outnames.ctrl = static.pv.ctrl;
    outnames.bld = static.pv.bld;
    
%% write data to output structure

    % phase shifter controls go here
    output.ctrl.dac = phase_shift_ps;
    %output.ctrl.dac(1) = new.in.dac_scale * cos(new_phase);
    %output.ctrl.dac(2) = new.in.dac_scale * sin(new_phase);
    
    output.ctrl.time(1) = new.in.dac_scale * sin(time_radians);
    output.ctrl.time(2) = new.in.dac_scale * cos(time_radians);

    % diagnostic output PVs go here
    output.out.cav.charge = calc.fit.charge;
    output.out.cav.time = calc.fit.time;
    output.out.cav.freq = calc.fit.freq - static.freq.cav/1e6;
    output.out.cav.maxcounts = calc.fit.maxcounts;
    output.out.cav.diff = calc.fit.diffs(1:static.num.cavities);
    output.out.cav.q = calc.fit.q;
    output.out.cav.std = stats.std.time;
    
    output.out.diff_noise = stats.std.diffs(2); % this is cav1 - cav2
    output.out.phase_shifter = new_phases;
    output.out.phase_shift_ps = phase_shift_ps;
    output.out.diffs = stats.std.diffs';
    
    % BLD PVs go here
    output.bld.phase_rotation = calc.rotation(1:2);
    output.bld.charge_scale = calc.chargescale(1:2);
    output.bld.cav_freq = static.freq.cav(1:2);
    output.bld.prec_start = static.prec.time(1,:);


%% actually write the output

    status = lcaPutStruct(outnames, output);    
    
    if ~any(status.ctrl.dac)
        disp_log('Write failure to phase shifter controls');
    end
        
end