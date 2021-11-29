function set_QS2_BDES(B)

disp(sprintf('\nSetting QS2 to the requested BDES.\n'));
control_magnetSet('LGPS:LI20:3311', B,  'action', 'TRIM');
pause(1);
