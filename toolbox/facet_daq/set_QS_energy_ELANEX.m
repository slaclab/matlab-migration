function [BDES, BACT] = set_QS_energy_ELANEX(E)

if E<-20 || E>40
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
%    VAL = (1+E/20.35)*[217.1035 -165.4100]; % Imaging condition for object = E200 IP or plasma exit and image = ELANEX in 2013
VAL = (1+E/20.35)*[210.87 -164.95]; % Imaging condition for object = E200 IP or plasma exit and image = ELANEX in Fall of 2013    
%  VAL = (1+E/20.35)*[263.157, -172.705]; % EA: Imaging from PEXT of long oven to ELANEX, Apr 22 2014
control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
    control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));


