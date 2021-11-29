function [BDES1, BDES2] = set_QS_trim()

z_ob = lcaGetSmart('SIOC:SYS1:ML03:AO001');
z_im = lcaGetSmart('SIOC:SYS1:ML03:AO002');
QS = lcaGetSmart('SIOC:SYS1:ML03:AO003');

% ELANEX motor PVs
ELANEX_X = 'XPS:LI20:DWFA:M4';
ELANEX_Y = 'XPS:LI20:DWFA:M5';
ELANEX_X_VAL = -3; % After Dec, 13th 2015.
ELANEX_Y_VAL = 42 - 55*QS/(QS+20.35); % After Dec, 13th 2015.

% Move ELANEX to the desired positions, commented out for E210, uncomment
% to allow ELANEX to move with QS
if lcaGetSmart('SIOC:SYS1:ML03:AO004')
    lcaPutSmart(ELANEX_X, ELANEX_X_VAL);
    lcaPutSmart(ELANEX_Y, ELANEX_Y_VAL);
end

[isok, BDES1, BDES2] = E200_calc_QS_2(z_ob, z_im, QS);
    
if isok
    disp(sprintf('\nSetting QS quads to the requested object plane, image plane and energy set point.\n'));
    control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, [BDES1, BDES2],  'action', 'TRIM')
else
    disp(sprintf('\nCould not set QS to desired value.\n'));
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));

end
