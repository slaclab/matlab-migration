% Function to scan the QS magnets and the spectro bend in concert and have
% the image plane at ELANEX
%
% Changelog :
% S. Corde, June 29, 2013
%   First version!

function [BDES, BACT] = set_QSBEND_energy_ELANEX(E)

E0 = 20.35;

if E<-20 || E>40
    disp(sprintf('\nThis value is not permitted.\n'));
else
    disp(sprintf('\nSetting QS quads and spectrometer BEND to the requested imaged energy.\n'));
%     QSVAL = (1+E/E0)*[217.1035 -165.4100]; % Imaging condition for object = E200 IP or plasma exit and image = ELANEX in 2013
    QSVAL = (1+E/20.35)*[210.87 -164.95]; % Imaging condition for object = E200 IP or plasma exit and image = ELANEX in Fall of 2013    control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');
    BEND_VAL = (E0 + E);
    VALS = [QSVAL BEND_VAL];
    control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311', 'BNDS:LI20:3330'}, VALS,  'action', 'TRIM');
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311', 'BNDS:LI20:3330'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n\nB5D36:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));


 
