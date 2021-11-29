%aline_feedback.m
n = 0;
n = n + 1;
pvs = cell(1,1);

pvs{n,1} = 'AB01:BPMS:1790:TMIT';
bpm_t_n = n;
n = n + 1;
pvs{n,1} = 'AB01:BPMS:1790:X';
bpm_x_n = n;
n = n + 1;
pvs{n,1} = 'AB01:BPMS:1790:Y';
bpm_y_n = n;
n = n + 1;
[name, is, PACT, PDES, GOLD, KPHR, AACT, ADES, FDBK, SEND, POFF]=control_phaseNames('L3');
pvs{n,1} = PDES;
L3_phase_n = n;
n = n + 1;
pvs{n,1} = ADES;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO082';
gain_n = n;
n = n + 1;
pvs{n,1} = 'BPMS:IN20:221:TMIT';
inj_tmit_n = n;
n = n + 1;
pvs{n,1} = 'SIOC:SYS0:ML00:AO100';
bpm_offset_n = n;

tmit_cut = 5e8; % cut tmit

lcaPut('SIOC:SYS0:ML00:AO082.DESC', 'Aline_feedback_gain');
lcaPut('SIOC:SYS0:ML00:AO082.PREC', 4);
lcaPut('SIOC:SYS0:ML00:AO100.DESC', 'Aline_feedback_offset');
lcaPut('SIOC:SYS0:ML00:AO100.PREC', 4);

dispersion = 5000; % mm

% get BC2 energy - added 11/17/10 nate
energy_setpoints = model_energySetPoints();
E_BC2 = energy_setpoints(4);

% changed 11/17/10 nate
beam_energy = E_BC2 * 1000;

delay = .25;

bpm_t_last = 0; % previous tmit
while 1
  pause(delay);
  d = lcaGet(pvs);  % input pvs
  bpm_t = d(bpm_t_n);
  bpm_x = d(bpm_x_n);
  L3_amplitude = d(L3_amplitude_n);
  L3_phase = d(L3_phase_n);
  inj_tmit = d(inj_tmit_n);
  bpm_offset = d(bpm_offset_n);
  gain = d(gain_n);
  if bpm_t < tmit_cut
    disp('charge too low');
    continue   % charge too low to run
  end
  if bpm_t == bpm_t_last
    disp('no change in tmit');
    continue
  end
%  if ((bpm_t / inj_tmit) < 0.75 || (bpm_t / inj_tmit) > 1.25)
%    disp('tmit loss from injector');
%   continue;
%  end
  if abs(bpm_x) > 60
    disp('x too large');
    continue;
  end
  energy_error = (bpm_x - bpm_offset) / dispersion * beam_energy;
  delta_phase = gain * sign(L3_phase_n) * energy_error / L3_amplitude * 180/pi;  % phase change in degrees
  phase = L3_phase + delta_phase;
  if (abs(L3_phase) > 100) || (abs(L3_phase) < 80)
    disp(' phase out of range');
    continue
  end
  if gain > 0
    lcaPut(pvs{L3_phase_n,1}, phase);
    disp(phase);
  end
end
