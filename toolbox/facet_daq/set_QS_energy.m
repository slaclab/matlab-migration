function [BDES, BACT] = set_QS_energy(E)

if E<-20 || E>40
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
% VAL = (1+E/20.5)*[209.11, -158.71]; % Imaging condition for plasma exit in 2012
% VAL = (1+E/20.35)*[213.07, -156.01]; % Imaging condition for E200 IP or plasma exit in 2013
% VAL = (1+E/20.35)*[179.83, -153.34]; % Imaging condition for WIP #1 in 2013 
% VAL = (1+E/20.35)*[199.86, -156.97]; % Imaging condition for IPOTR1 in 2013
% VAL = (1+E/20.35)*[362.5, -176.40]; % Imaging condition for E201IP in 2013
VAL = (1+E/20.35)*[209.57, -160.51]; % Imaging condition for E200 IP or plasma exit in Fall of 2013
% VAL = (1+E/20.35)*[261.72, -167.95]; % Imaging condition for E200 IP long plasma exit, Apr. 22 2014
% EA: the above is consistent with the E00_calc_QS function for z_OB = 1994.97 which is defined at PEXT - OK (Apr 22)
control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));

