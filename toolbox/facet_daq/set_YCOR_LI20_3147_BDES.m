function set_YCOR_LI20_3147_BDES(B)

disp(sprintf('\nSetting YCOR_LI20_3147_BDES to the requested BDES.\n'));
control_magnetSet('YCOR:LI20:3147', B,  'action', 'TRIM');
pause(1);
