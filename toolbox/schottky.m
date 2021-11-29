%schottky.m
%does schottky scan of laser phase

phase_offset = 30; % how far to operate from schottky edge
max_phase_change = 10; % maximum  phase change each time


min_initial_charge = 0.015; % at least this much charge to start
phase_step_big = 5; % degrees S band
phase_steps = 10; % big phase steps
phase_steps2 = 30; % small phase steps
phase_step_small = 0.5; % degrees S band
delay1 = 2; % time delay between big steps
delay2 = 1; % time delay between small steps
min_charge_ratio = 0.001; % when we stop scanning big steps
initial_phase_shift = 15;  %degrees to shift phase for first step


bpm_pv = 'BPMS:IN20:221:TMIT';
phase_pv = 'SIOC:SYS0:AO901.VAL';
screen_pv = 'YAGS:IN20:241:PNEUMATIC';


valid_phase = 0;
valid_phase = 0;
zero_cross = 0;


tmp = lcaGet(bpm_pv);
%disp(tmp);
pause(0.25);
tmp = lcaGet(bpm_pv);
%disp(tmp);
pause(0.25);


charge = lcaGet(bpm_pv);
disp(['initial charge = ', num2str(charge)]);
if charge < min_initial_charge
    disp('charge too low, aborting');
    return;
end

initial_screen = lcaGet(screen_pv);
initial_phase = lcaGet(phase_pv);


if strcmp('OUT', initial_screen) % screen was out
        lcaPut(screen_pv, 'IN');
        pause(2);
end


phase = zeros(phase_steps,1);
c = zeros(phase_steps,1);
disp('big steps');
for j = 1:phase_steps
    phase(j) = initial_phase + j * phase_step_big + initial_phase_shift; % new phase
    lcaPut(phase_pv, phase(j)); % set new phase
    pause(delay1);
    c(j) = lcaGet(bpm_pv); % measure charge  
    %disp(['phase = ', num2str(phase(j)), ' current = ', num2str(c(j))]);
    if c(j) <= 0;
        break
    end
end

jlast = j;
if jlast <=1
   disp('missed on first step');
   if strcmp('OUT', initial_screen) % screen was out
        lcaPut(screen_pv, initial_screen);
        lcaPut(phase_pv, initial_phase);
   end
   return
end


start_scan = phase(j-1) - phase_step_small; % where to start fine scan

ph2 = zeros(phase_steps2, 1);
ch2 = zeros(phase_steps2, 1);
k = 0;
disp('small steps');
for j = 1:phase_steps2
    ph2(j) = start_scan + (j-1) * phase_step_small;
    lcaPut(phase_pv, ph2(j));
    pause(delay2);
    ch2(j) = lcaGet(bpm_pv); % measure charge
    %disp(['phase = ', num2str(ph2(j)), ' current = ', num2str(ch2(j))]);
    if ch2(j) < charge * min_charge_ratio;
        break
    end
end
clear pfit;
clear cfit;

figure(200);
plot(ph2(1:j), ch2(1:j), '*');
hold on;
plot(phase(1:jlast-1), c(1:jlast-1), '+');
hold off;


if j <=1
   result_phase = initial_phase;
   lcaPut(phase_pv, result_phase);
   pause(delay1);
   disp('not enough steps');
   if strcmp('OUT', initial_screen) % screen was out
   lcaPut(screen_pv, 'IN');
   end
   valid_phase = 0;
   zero_phase = 0;
   return;
end


for k = 1:(j-1); % scan over valid states
    pfit(k) = ph2(k);
    cfit(k) = ch2(k);
end



zero_current = pfit(k); % last point with current
new_phase = zero_current - phase_offset;
if abs(new_phase - initial_phase) < max_phase_change
    valid_phase = 1;
else
    valid_phase = 0;
end



if valid_phase
   result_phase = new_phase;
   disp('phase is valid - setting');
else
   result_phase = initial_phase; % kludge for now
   disp('phase invalid - no change');
end


txt = [datestr(now), ' Laser, old = ', num2str(initial_phase), '  calculated = ', ...
   num2str(new_phase), '  setting = ', num2str(result_phase)];
title(txt);
hold off

lcaPut(phase_pv, result_phase);

pause(delay1); % time for phase to recover
disp(['new phase = ', num2str(new_phase)]);
if strcmp('OUT', initial_screen) % screen was out
     lcaPut(screen_pv, 'OUT'); % return screen to out
end



