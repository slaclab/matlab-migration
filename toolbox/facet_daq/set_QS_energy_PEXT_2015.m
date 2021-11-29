function [BDES, BACT] = set_QS_energy(E)

if E<-20 || E>40
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
% NB: value is from PEXT2014, cannot image with nominal from PEXT2015 due to QS1 limits
VAL = (1+E/20.35)*[0, 261.52, -168.17]; % Imaging condition for PEXT 2014 to CHER, Feb 2015

control_magnetSet({'LGPS:LI20:3204', 'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM')
end

pause(1);


[BACT, BDES] = control_magnetGet({'LGPS:LI20:3204',  'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));
