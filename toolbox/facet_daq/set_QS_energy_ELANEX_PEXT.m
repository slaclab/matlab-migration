function [BDES, BACT] = set_QS_energy_ELANEX_PEXT(E)

% ELANEX motor PVs
ELANEX_X = 'XPS:LI20:DWFA:M4';
ELANEX_Y = 'XPS:LI20:DWFA:M5';
ELANEX_X_VAL = -15; % After Nov 10th, 2014.
ELANEX_Y_VAL = 54 - 55*E/(E+20.35); % After Nov 10th, 2014.

% Move ELANEX to the desired positions
lcaPutSmart(ELANEX_X, ELANEX_X_VAL);
lcaPutSmart(ELANEX_Y, ELANEX_Y_VAL);

% PEXT -> ELANEX
% QS setting,   QS1_BDES,     QS2_BDES ,  m12m     m34
 SETTINGS_PEXT_ELANEX = [
9.0  378.99  -249.05  0.09  -0.00
 9.5  385.74  -253.31  0.05  -0.00
 10.0  386.76  -257.17  0.66  0.00
 10.5  386.76  -260.96  1.36  0.00
 11.0  386.76  -264.74  2.04  0.00
 11.5  386.76  -268.51  2.69  0.00
 12.0  386.76  -272.28  3.33  0.00
 12.5  386.76  -276.04  3.95  0.00
 13.0  386.76  -279.79  4.54  0.00
 13.5  386.76  -283.54  5.12  0.00
 14.0  386.76  -287.29  5.69  0.00
 14.5  386.76  -291.03  6.23  0.00
 15.0  386.76  -294.76  6.77  0.00
 15.5  386.76  -298.49  7.28  0.00
 16.0  386.76  -302.21  7.78  0.00
 16.5  386.76  -305.93  8.27  0.00
 17.0  386.76  -309.65  8.75  0.00
 17.5  386.76  -313.36  9.21  0.00
 18.0  386.76  -317.07  9.66  0.00
 18.5  386.76  -320.77  10.10  0.00
 19.0  386.76  -324.46  10.53  0.00
 19.5  386.76  -328.16  10.94  0.00
 20.0  386.76  -331.85  11.35  0.00
 20.5  386.76  -335.53  11.74  0.00
 21.0  386.76  -339.21  12.13  0.00
 21.5  386.76  -342.89  12.51  0.00
 22.0  386.76  -346.57  12.87  0.00
 22.5  386.76  -350.24  13.23  0.00
 23.0  386.76  -353.90  13.58  0.00
 23.5  386.76  -357.57  13.93  0.00
 24.0  386.76  -361.23  14.26  0.00
 24.5  386.76  -364.88  14.59  0.00
 25.0  386.76  -368.54  14.91  0.00
];



if E<-20 || E>25
    disp(sprintf('\nError: This value is not permitted.\n'));
elseif E>9.5
    % need to use look up table due to QS limits
    if( abs(mod(E*2, 1)) < eps )
        VAL = SETTINGS_PEXT_ELANEX((E*2-17),2:3)
        control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
    else
        disp(sprintf('\nError: QS values not set..\n'));
        disp(sprintf('\nValues from 10 GeV must be in steps of 0.5 GeV (look-up table).\n'));
        stop;
    end% if
else
    disp(sprintf('\nSetting QS quads to the requested imaged energy.\n'));
    %    VAL = (1+E/20.35)*[217.1035 -165.4100]; % Imaging condition for object = E200 IP or plasma exit and image = ELANEX in 2013
    %    VAL = (1+E/20.35)*[210.87 -164.95]; % Imaging condition for object = E200 IP or plasma exit and image = ELANEX in Fall of 2013
    %    VAL = (1+E/20.35)*[263.157, -172.705]; % EA: Imaging from PEXT of long oven to ELANEX, Apr 22 2014
    VAL = (1+E/20.35)*[258.03, -172.06]; % SC: Imaging from PEXT - 0.12 m (z_object = 1997.85 m) to ELANEX (z_image = 2015.22 m), Nov 10 2014
    control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));


 
