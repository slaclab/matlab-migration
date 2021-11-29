function [BDES, BACT] = set_QS_EPICS_Z_ELANEX(E)

Z_OB = lcaGet('SIOC:SYS1:ML03:AO001');
Z_ELANEX = 2015.22;


if E<(-37.35-20.35) || E>(37.35-20.35)
    disp(sprintf('\nThis value is not permitted.\n'));
end

[isok, BDESQS1, BDESQS2] = E200_calc_QS(Z_OB, Z_ELANEX, E, 20.35)
    
if isok
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
    control_magnetSet({'LGPS:LI20:3204', 'LGPS:LI20:3261', 'LGPS:LI20:3311'}, [-0, BDESQS1, BDESQS2],  'action', 'TRIM')
else
    disp(sprintf('\nCould not set QS to desired value.\n'));
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3204',  'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));
