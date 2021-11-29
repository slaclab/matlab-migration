function [BDES, BACT] = set_QS_energy(E)

% ELANEX motor PVs
ELANEX_X = 'XPS:LI20:DWFA:M4';
ELANEX_Y = 'XPS:LI20:DWFA:M5';
ELANEX_X_VAL = -15; % After Nov 10th, 2014.
ELANEX_Y_VAL = 54 - 55*E/(E+20.35); % After Nov 10th, 2014.

% Move ELANEX to the desired positions
lcaPutSmart(ELANEX_X, ELANEX_X_VAL);
lcaPutSmart(ELANEX_Y, ELANEX_Y_VAL);

if E<(-29-20.35) || E>(29-20.35)
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
VAL = (1+E/20.35)*[0, 268.37, -173.34]; % Imaging condition for CUBE5 to ELANEX, Feb 2015
VAL(1) = -0.5; % manual override of QS0 strength
control_magnetSet({'LGPS:LI20:3204', 'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM')
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3204',  'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));
