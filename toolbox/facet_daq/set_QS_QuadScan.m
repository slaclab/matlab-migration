function [BDES1, BDES2] = set_QS_QuadScan(m12_req)

z_ob = lcaGetSmart('SIOC:SYS1:ML03:AO001');
z_im = lcaGetSmart('SIOC:SYS1:ML03:AO002');
QS = lcaGetSmart('SIOC:SYS1:ML03:AO003');

[isok, BDES1, BDES2] = E200_calc_QS_2(z_ob, z_im, QS, m12_req);
    
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









