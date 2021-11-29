% lB0phase.m
% to phase l0b


min_charge = .02;
phase_range = 20;
phase_steps = 20;
delay = 1; 
maximum_change = 10;
erlim = 1;

bpm_pv = 'BPMS:IN20:731:X';
bpm_status_pv = 'BPMS:IN20:731:STA';
charge_pv = 'BPMS:IN20:731:TMIT';
phase_rb = 'ACCL:IN20:400:L0B_S_PV';
phase_ctrl = 'ACCL:IN20:400:L0B_PDES';
strname = 'L0B';
fignum = 400;



initial_phase = lcaGet(phase_ctrl);

ph = zeros(phase_steps,1);
valid = zeros(phase_steps,1);
bpm_x = zeros(phase_steps,1);

for j = 1:phase_steps
   phase = initial_phase + ((j-1)/(phase_steps-1)-0.5)*phase_range;
   lcaPut(phase_ctrl, phase); % sweep phase
   if j == 1
      pause(3);
   end
   pause(1);
   ph(j) = lcaGet(phase_rb); % read back phase
   stat = lcaGet(bpm_status_pv);
   if stat ~= 0
       continue;
   end
   bpm_x(j) = lcaGet(bpm_pv); % x position
end





P = polyfit(ph, bpm_x, 2); % do fit
ft = polyval(P, ph);


er = sqrt(sum((ft - bpm_x).^2))/sqrt(phase_steps);
disp(['fit error = ', num2str(er)]);
disp(['old phase = ', num2str(initial_phase)]);

z = -P(2)/(2*P(1));

if P(1) <= 0 || (er > erlim)
   disp(['bad fit ', num2str(z)]);
   result_phase = initial_phase;
elseif abs(z-initial_phase) < maximum_change
   disp(['changing phase to ', num2str(z)]);
   result_phase = z;
else
   disp(['L0A phase change too large ', num2str(z)]);
   result_phase = initial_phase; 
end

lcaPut(phase_ctrl, result_phase);




figure(fignum);
plot(ph, bpm_x, 'b+');
hold on
plot(ph, ft, 'r-');

txt = [datestr(now) '  ', strname, ' old = ', num2str(initial_phase), '  calculated = ', num2str(z), ...
   '  setting  ', num2str(result_phase)];
hold off
title(txt);



