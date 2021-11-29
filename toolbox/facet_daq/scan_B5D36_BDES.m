% get init values           
[BACT_init, BDES_init] = control_magnetGet({'BNDS:LI20:3330'}); 
control_magnetSet('BNDS:LI20:3330', 15.35); 
E200_gen_scan(@set_B5D36_BDES, 11.35, 34.35, 24, 14, 20);
% re-set init values           
% control_magnetSet({'BNDS:LI20:3330'}, BDES_init,  'action', 'TRIM'); 


%control_magnetSet('BNDS:LI20:3330', 15.35); 



%E200_gen_scan_15D(@set_XCOR_LI20_3086_BDES, -0.375, +0.25, 6, @set_B5D36_BDES, 20.35, par); 
