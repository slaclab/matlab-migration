function set_B5D36_BDES(B)

disp(sprintf('\nSetting B5D36 (spectrometer) to the requested BDES.\n'));
control_magnetSet('BNDS:LI20:3330', B,  'action', 'TRIM');
pause(1);
