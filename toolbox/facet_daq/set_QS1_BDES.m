function set_QS1_BDES(B)

disp(sprintf('\nSetting QS1 to the requested BDES.\n'));
control_magnetSet('LGPS:LI20:3261', B,  'action', 'TRIM');
pause(1);
