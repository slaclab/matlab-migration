%tcav_feedback.m

% controls tcav phase to hold bunch fixed on bpms.
function tcav_feedback()

appName='tcav_feedback.m';
eDefNum = eDefReserve('tcav_feedback');
if ~ eDefNum
  disp(' could not reserve edef for tcav');
  return;
end
navg = 1; % no averages
npos = -1; % only 1 data apoint
timeout = 10; % seconds timeout
eDefParams(eDefNum, navg, npos, {'TCAV3'}, {''}, {''}, {''});
eDefOn(eDefNum);

exten = num2str(eDefNum);

disp('TCAV3 feedback 11/12/09 version 4.0');
lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.
scale = -2; % convert bpm reading to tcav
delay = 0.05;
max_phase_error = 2; % in degrees
max_amplitude_error = 1; % in abs units
max_amplitude = 15;
max_bpm = .5;
standby_amplitude = 15;
min_amplitude = .25; % minimum RF
amplitude_step = .05; % maximum step in amplitude each cycle.
min_charge = 1e8;
min_charge_ratio = 0.75; % minimum transmission to continue running
max_tcav_bad_pulses = 5000; % number of bad tcav pulses before ramping down
tcav_last_gui_on = 0; % assumes originally off
a = 0;
pv = cell(7,1);
a = a + 1;
front_bpm_x_num = a;
pv{a,1} = ['BPMS:LI25:201:X', exten];
a = a + 1;
front_bpm_y_num = a;
pv{a,1} = ['BPMS:LI25:201:Y', exten];
a = a + 1;
front_bpm_t_num = a;
pv{a,1} = ['BPMS:LI25:201:TMIT',exten];
a = a + 1;
tcav_bpm_x_num = a;
pv{a,1} = ['BPMS:LI25:601:X', exten];
a = a + 1;
tcav_bpm_y_num = a;
pv{a,1} = ['BPMS:LI25:601:Y', exten];
a = a + 1;
tcav_bpm_t_num = a;
pv{a,1} = ['BPMS:LI25:601:TMIT', exten];
a = a + 1;
tcav_phase_num = a;
pv{a,1} = 'TCAV:LI24:800:TC3_PDES';
a = a + 1;
tcav_phase_rb_num = a;
pv{a,1} = 'TCAV:LI24:800:TC3_S_PV';
a = a + 1;
tcav_amplitude_num = a;
pv{a,1}  = 'TCAV:LI24:800:TC3_ADES';
a = a + 1;
tcav_amplitude_rb_num = a;
pv{a,1}  = 'TCAV:LI24:800:TC3_S_AV';
a = a + 1;
tcav_status_num = a;
pv{a,1} = 'LI24:KLYS:81:SWRD';
a = a + 1;
bpm_setpoint_num = a;
pv{a,1} = setup_pv(398, 'tcav fb bpm offset', 'mm', 3, appName);
a = a + 1;
bpm_typical_num = a;
pv{a,1} = setup_pv(386, 'typical bpm', 'mm', 3, appName);
a = a + 1;
tcav_gain_num = a;
pv{a,1} = setup_pv(38, 'tcav gain', ' ', 2, appName);
a = a + 1;
beam_bad_num = a;
pv{a,1} = setup_pv(390, 'tcav beam bad', ' ',0, appName);
a = a + 1;
tcav_bad_num = a;
pv{a,1} = setup_pv(389, 'tcav rf bad', ' ',0, appName);
a = a + 1;
tcav_amplitude_target_num = a;
pv{a,1} = setup_pv(396, 'tcav amplitude target', ' ',2, appName);
a = a + 1;
tcav_amplitude_ramp_num = a;
pv{a,1} = setup_pv(388, 'tcav ramp amplitude', ' ',2, appName);
a = a + 1;
phase_sign_num = a;
pv{a,1} = setup_pv(387, 'tcav sign', ' ',0, appName);
a = a + 1;
all_ok_num = a;
pv{a,1} = setup_pv(385, 'tcav all OK', ' ',0, appName);
a = a + 1;
tcav_on_num = a;
pv{a,1} = setup_pv(384, 'tcav ON', ' ',0, appName);
a = a + 1;
tcav_max_amp = a;
pv{a,1} = setup_pv(420, 'tcav max amp', ' ',2, appName);
a = a + 1;
tcav_gui_on_num = a;
pv{a,1} = 'SIOC:SYS0:ML00:AO603';
a = a + 1;
tcav_rate_num = a;
pv{a,1} = 'EVNT:SYS0:1:LCLSTCV3RATE';


setup_pv(397, 'tcav feedback counter', ' ', 0, appName);
W = watchdog('SIOC:SYS0:ML00:AO397', 1, 'tcav feedback counter' );
if get_watchdog_error(W)
  disp('Another TCAV feedback is running, exiting');
  return
end

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
  %sample_time = eDefAcq(eDefNum, timeout);
 % display(sample_time);
  beam_bad = 0;
  tcav_bad = 0;
  beam_lost = 0;
  tcav_on = 0;
  all_ok = 0;
  count = count + 1;
  pause(delay);
  try
    data = lcaGet(pv);
  catch
    disp('error on lcaGet');
    pause(1);
    continue
  end
  bpm = data(tcav_bpm_y_num);
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
  bpm_setpoint = data(bpm_setpoint_num) + data(bpm_typical_num);
  tcav_gui_on = data(tcav_gui_on_num);
  rate = data(tcav_rate_num);
  if count == 1
    last_bpm = bpm;
    continue
  end
  amplitude = max(amplitude, min_amplitude);
  if amplitude_rb < min_amplitude /2;
    tcav_bad = 1;
  end
  if abs(amplitude - amplitude_rb) > max_amplitude_error
    tcav_bad = 1;
  end
  if abs(phase - phase_rb) > max_phase_error * max_amplitude / amplitude;
    tcav_bad = 1;
  end
  if (rate <= 0)          % limit loop speed when tcav is off
      pause(1);
  end
  if gain <= 0
    pause(.1);
    continue;
  end
  if bpm == last_bpm  % repeated measurement
    continue;
  end
  if bitand(data(tcav_status_num), 2^15)
    tcav_bad_count = tcav_bad_count + 1;
    tcav_bad = 1;
    if tcav_bad_count > max_tcav_bad_pulses % too many bad pulses, start recovery
      beam_lost = 1; % no tcav, initiate recovery
      tcav_on = 0;
    end
  else
    tcav_on = 1;
    tcav_bad_count = 0;
  end

  %if bpm == 0;
  %  beam_bad = 1;
  %end
  if abs(bpm) > 5
    beam_bad = 1;
    beam_lost = 1;
  end
  if abs(bpm - bpm_setpoint) > max_bpm
    big_orbit = 1;
  else
    big_orbit = 0;
  end
  if input_charge < min_charge % no beam do nothing
    continue;
  end
  if output_charge / input_charge < min_charge_ratio  % beam loss
    beam_lost = 1;
    beam_bad= 1;
  end
  phase_switch = 0;
  if (phase_sign > 0) && (phase < 0)  && (phase_rb < 0)% switch phase
    %beam_lost = 1;
    if phase < 0 % wrong phase sign
      %phase = 90;
      phase = phase + 180;
      %phase_switch = 1;
    end
  elseif (phase_sign < 0) && (phase > 0)  && (phase_rb > 0)% switch phase
    %beam_lost = 1;
    if phase > 0; % Wrong phase sign
      %phase = -90;
      phase = phase - 180;
      %phase_switch = 1;
    end
  else% OK signs agree, do nothing
  end


  last_bpm = bpm;
  if (~beam_bad) && (~tcav_bad) && (~beam_lost)
    deltaphase = sgn * scale * gain * (bpm-bpm_setpoint) / amplitude;
    if abs(deltaphase) > 0.2 * 14 / amplitude;
      deltaphase = .2 * sign(deltaphase);
    end
    phase = phase + deltaphase;
  end

  amplitude_target = min(amplitude_target, max_amplitude);
  amplitude_target = max(amplitude_target, min_amplitude);
  if (ramp_target > amplitude) && ~beam_bad
    amplitude = amplitude + amplitude_step;
    amplitude = min(amplitude, ramp_target);
  elseif (ramp_target < amplitude) && ~beam_bad
    amplitude = amplitude - amplitude_step;
    amplitude = max(amplitude, ramp_target);
  else
  end
  try
    if tcav_gui_on ~= tcav_last_gui_on  % state change
      if tcav_gui_on
        lcaPut(pv{tcav_amplitude_num,1}, min_amplitude);
      else
        lcaPut(pv{tcav_amplitude_num,1}, standby_amplitude);
      end
    end
  catch
    disp('problem setting up standby operation');
  end
  tcav_last_gui_on = tcav_gui_on; 
  % now check phase sign


  if (beam_bad || tcav_bad) && (~beam_lost)
    try
      lcaPut({pv{beam_bad_num,1}; pv{tcav_bad_num,1}; pv{tcav_amplitude_ramp_num,1}; pv{all_ok_num, 1}; pv{tcav_on_num}},...
        [beam_bad; tcav_bad; ramp_target; all_ok; tcav_on]);
    catch
      disp('some lca error');
    end
  end
  if beam_lost  % Beam didn't make it, ramp down.
    if tcav_gui_on
      ramp_target = min_amplitude;
      amplitude = min_amplitude;
    else
      ramp_target = data(tcav_max_amp);%max_amplitude;
      amplitude = data(tcav_max_amp);%max_amplitude;
    end
    try
      lcaPut({pv{beam_bad_num,1}; pv{tcav_bad_num,1}; pv{tcav_amplitude_ramp_num,1};...
        pv{tcav_amplitude_num,1}; pv{all_ok_num}; pv{tcav_on_num}},...
        [beam_bad; tcav_bad; ramp_target; amplitude; all_ok; tcav_on]);
    catch
      disp('another lca error');
    end
    pause(2) % recovery from lost beam
    if phase_switch
      lcaPut(pv{tcav_phase_num,1}, phase);
      pause(2); % another pause
      disp('phase switch, spinning phase');
    end
  end
  if (~beam_bad) && (~tcav_bad) && (~beam_lost)
    ramp_target = amplitude_target;  % good beam, run ramp up to full.
    if (amplitude == amplitude_target) && ~big_orbit
      all_ok = 1;
    else
      all_ok = 0;
    end
    try
      lcaPut({pv{tcav_phase_num,1}; pv{tcav_amplitude_num,1};...
        pv{beam_bad_num,1}; pv{tcav_bad_num,1}; pv{tcav_amplitude_ramp_num,1}; pv{all_ok_num}; pv{tcav_on_num,1}},...
        [phase; amplitude; beam_bad; tcav_bad; ramp_target; all_ok; tcav_on]);
    catch
      disp('error in lca put');
      pause(1);
    end
  end
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
