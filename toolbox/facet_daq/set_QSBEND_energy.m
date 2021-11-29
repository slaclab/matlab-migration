% Function to scan the QS magnets and the spectro bend in concert
%
% Changelog :
% E. Adli, May 9, 2013
%   First version!

function [BDES, BACT] = set_QSBEND_energy(E)

E0 = 20.35;

if E<-20 || E>40
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads and spectrometer BEND to the requested imaged energy.\n'));
% QSVAL = (1+E/20.5)*[209.11, -158.71]; % Imaging condition for plasma exit in 2012
% QSVAL = (1+E/E0)*[213.07, -156.01]; % Imaging condition for E200 IP or plasma exit in 2013
% QSVAL = (1+E/E0)*[179.83, -153.34]; % Imaging condition for WIP #1 in 2013 
% QSVAL = (1+E/E0)*[199.86, -156.97]; % Imaging condition for IPOTR1 in 2013
% QSVAL = (1+E/E0)*[362.5, -176.40]; % Imaging condition for E201IP in 2013
QSVAL = (1+E/20.35)*[209.57, -160.51]; % Imaging condition for E200 IP or plasma exit in Fall of 2013
BEND_VAL = (E0 + E);
VALS = [QSVAL BEND_VAL];
control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311', 'BNDS:LI20:3330'}, VALS,  'action', 'TRIM');
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311', 'BNDS:LI20:3330'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n\nB5D36:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));


 
