function [BDES, BACT] = set_QS_energy_PEXT(E)

% ELANEX motor PVs
ELANEX_X = 'XPS:LI20:DWFA:M4';
ELANEX_Y = 'XPS:LI20:DWFA:M5';
% ELANEX_X_VAL = 0; % Before July 1st, 2014.
% ELANEX_Y_VAL = -3 - 55*E/(E+20.35); % Before July 1st, 2014.
% ELANEX_X_VAL = 1; % After July 1st, 2014.
% ELANEX_Y_VAL = 40 - 55*E/(E+20.35); % After July 1st, 2014.
ELANEX_X_VAL = -15; % After Nov 10th, 2014.
ELANEX_Y_VAL = 54 - 55*E/(E+20.35); % After Nov 10th, 2014.


% Move ELANEX to the desired positions
lcaPutSmart(ELANEX_X, ELANEX_X_VAL);
lcaPutSmart(ELANEX_Y, ELANEX_Y_VAL);

%   look-up table for imaging in Y, not in X
%      (this is imaging from PEXT, not from PEXT-12 cm)
% PEXT -> CFAR
% QS setting,   QS1_BDES,     QS2_BDES ,  m12m     m34
 SETTINGS_PEXT_CFAR = [
 9.0  377.23  -242.24  0.06  -0.00
 9.5  383.49  -246.36  0.08  -0.00
 10.0  386.76  -250.26  0.45  0.00
 10.5  386.76  -253.93  1.18  0.00
 11.0  386.76  -257.60  1.89  0.00
 11.5  386.76  -261.26  2.58  0.00
 12.0  386.76  -264.91  3.24  0.00
 12.5  386.76  -268.56  3.89  0.00
 13.0  386.76  -272.20  4.51  0.00
 13.5  386.76  -275.84  5.12  0.00
 14.0  386.76  -279.47  5.71  0.00
 14.5  386.76  -283.10  6.28  0.00
 15.0  386.76  -286.72  6.84  0.00
 15.5  386.76  -290.34  7.38  0.00
 16.0  386.76  -293.95  7.91  0.00
 16.5  386.76  -297.55  8.42  0.00
 17.0  386.76  -301.16  8.92  0.00
 17.5  386.76  -304.75  9.40  0.00
 18.0  386.76  -308.35  9.87  0.00
 18.5  386.76  -311.94  10.33  0.00
 19.0  386.76  -315.52  10.78  0.00
 19.5  386.76  -319.10  11.21  0.00
 20.0  386.76  -322.68  11.64  0.00
 20.5  386.76  -326.25  12.05  0.00
 21.0  386.76  -329.82  12.46  0.00
 21.5  386.76  -333.38  12.85  0.00
 22.0  386.76  -336.95  13.24  0.00
 22.5  386.76  -340.50  13.61  0.00
 23.0  386.76  -344.06  13.98  0.00
 23.5  386.76  -347.61  14.34  0.00
 24.0  386.76  -351.16  14.69  0.00
 24.5  386.76  -354.70  15.03  0.00
 25.0  386.76  -358.24  15.36  0.00
 ];

if E<-20 || E>25
    disp(sprintf('\nError: This value is not permitted.\n'));
elseif E>9.5
% need to use look up table due to QS limits
if( abs(mod(E*2, 1)) < eps )
    VAL = SETTINGS_PEXT_CFAR((E*2-17),2:3)
    control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
 else
    disp(sprintf('\nError: QS values not set..\n'));
    disp(sprintf('\nValues from 10 GeV must be in steps of 0.5 GeV (look-up table).\n'));
stop;
end% if
else
disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
% VAL = (1+E/20.5)*[209.11, -158.71]; % Imaging condition for plasma exit in 2012
% VAL = (1+E/20.35)*[213.07, -156.01]; % Imaging condition for E200 IP or plasma exit in 2013
% VAL = (1+E/20.35)*[179.83, -153.34]; % Imaging condition for WIP #1 in 2013 
% VAL = (1+E/20.35)*[199.86, -156.97]; % Imaging condition for IPOTR1 in 2013
% VAL = (1+E/20.35)*[362.5, -176.40]; % Imaging condition for E201IP in 2013
% VAL = (1+E/20.35)*[209.57, -160.51]; % Imaging condition for E200 IP or plasma exit in Fall of 2013
%VAL = (1+E/20.35)*[261.72, -167.95]; % Imaging condition for E200 IP long plasma exit, Apr. 22 2014
VAL = (1+E/20.35)*[256.63, -167.34]; % Imaging condition for E200 IP long plasma exit - 12 cm ("virtual waist" in ramp), Nov. 13 2014
control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
end




pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));

 
