function [BDES, BACT] = set_QS_energy(E)

if E<(-27.9-20.35) || E>(27.9-20.35)
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
VAL = (1+E/20.35)*[-260.16, 281.12, -105.54]; % QS0 maxed spectrometer condition for CUBE5 to ELANEX, Feb 2015
control_magnetSet({'LGPS:LI20:3204', 'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM')
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3204',  'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));
