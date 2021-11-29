function set_XCOR_LI20_3116_BDES(B)

disp(sprintf('\nSetting XCOR_LI20_3116_BDES to the requested BDES.\n'));
control_magnetSet('XCOR:LI20:3116', B,  'action', 'TRIM');
pause(1);
