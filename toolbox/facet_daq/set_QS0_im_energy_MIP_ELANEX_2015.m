function [BDES, BACT] = set_QS0_im_energy_MIP_ELANEX_2015(E)

% ELANEX motor PVs
ELANEX_X = 'XPS:LI20:DWFA:M4';
ELANEX_Y = 'XPS:LI20:DWFA:M5';
ELANEX_X_VAL = -15; % After Nov 10th, 2014.
ELANEX_Y_VAL = 44 - 55*E/(E+20.35); % After Nov 10th, 2014.
% Lindstrom [May 9, 15]: changed const y-term to 44 (from 54)

% Move ELANEX to the desired positions
lcaPutSmart(ELANEX_X, ELANEX_X_VAL);
lcaPutSmart(ELANEX_Y, ELANEX_Y_VAL);

if E<(-30-20.35) || E>(30-20.35)
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
    VAL = (1+E/20.35)*[-194.00, 254.64, -160.02]; % QS0 config for 20.35 GeV from MIP to ELANEX, Feb 2015
control_magnetSet({'LGPS:LI20:3204', 'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM')
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3204',  'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));

%disp(sprintf('\nPress the "any" key to continue.\n'));
%pause;
