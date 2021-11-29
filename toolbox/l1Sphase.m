% l1Sphase.m
% to phase l1S


phase_offset = 25;


min_charge = .02;
phase_range = 20;
phase_steps = 20;
delay = 1; 
maximum_change = 10;
erlim = 1;


bpm_pv = 'BPMS:LI21:233:X';
bpm_status_pv = 'BPMS:LI21:233:STA';
charge_pv = 'BPMS:LI21:233:TMIT';
phase_rb = 'ACCL:LI21:1:L1S_S_PV';
phase_ctrl = 'ACCL:LI21:1:L1S_PDES';
strname = 'L1S';
fignum = 500;


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



