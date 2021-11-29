function set_BNDS_LI20_3330_BDES(B)

disp(sprintf('\nSetting BNDS_LI20_3330_BDES (spectrometer) to the requested BDES.\n'));
control_magnetSet('BNDS:LI20:3330', B,  'action', 'TRIM');
pause(1);
