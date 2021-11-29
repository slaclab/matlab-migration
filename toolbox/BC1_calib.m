motor_setting_PV  = 'BMLN:LI21:235:MOTR.VAL';
motor_readback_PV = 'BMLN:LI21:235:MOTR.RBV';
LVDT_readback_PV  = 'BMLN:LI21:235:LVPOS';

xsteps = 20;            % BC1 step size (mm)
xmin   = 0;             % minimum BC1 position setting for this scan (mm)
xmax   = 300;           % maximum BC1 position setting for this scan (mm)

x = xmin:xsteps:xmax;   % BC1 position steps array (mm)

x0 = lcaGet(motor_setting_PV);    % read the initial motor position (mm)
disp(sprintf('Moving BC1 to starting position of scan: %3.0f mm',x(1)))
%lcaPut(motor_setting_PV,x(1));                  % start motor at intial x - waits for full motion?
pause(5)

n = length(x);
xmotor = zeros(n,1);
xLVDT  = zeros(n,1);
for j = 1:n
  disp(sprintf('Moving BC1 to %3.0f mm',x(j)))
%  lcaPut(motor_setting_PV,x(j));            % step motor - waits for full motion?
  pause(1*xsteps/5)                         % pause an extra 1 sec per 5-mm step
  xLVDT(j)  = lcaGet(LVDT_readback_PV);     % read the LVDT position
  xmotor(j) = lcaGet(motor_readback_PV);    % read the motor position
end
disp(sprintf('Restoring BC1 to %5.1f mm',x0))
%lcaPut(motor_setting_PV,x0);                % restore motor - waits for full motion?

plot_polyfit(xmotor,xLVDT,1,3,'BC1 motor position','LVDT position','mm','mm')
enhance_plot