model_init('source','MATLAB','online',0);  % use Matlab model with instantaneous calculation

R = model_rMatGet('OTR2','YC06');
RTCAV = model_rMatGet('YC06','BPM10');

requestBuilder = pvaRequest('KLYS:LI20:71:TACT');
requestBuilder.returning(AIDA_STRING);
requestBuilder.with('BEAM',1);
actstr = requestBuilder.get(); % see if L0a is activated
if actstr(1)=='a'
  L0a_ON = 1;
else
  L0a_ON = 0;
end
requestBuilder = pvaRequest('KLYS:LI20:81:TACT');
requestBuilder.returning(AIDA_STRING);
requestBuilder.with('BEAM',1);
actstr = requestBuilder.get(); % see if L0b is activated
if actstr(1)=='a'
  L0b_ON = 1;
else
  L0b_ON = 0;
end

gun_volts  = lcaGetSmart('GUN:IN20:1:GN1_ADES');
L0a_volts  = lcaGetSmart('ACCL:IN20:300:L0A_ADES');
L0b_volts  = lcaGetSmart('ACCL:IN20:400:L0B_ADES');
gun_phase  = lcaGetSmart('GUN:IN20:1:GN1_PDES');
L0a_phase  = lcaGetSmart('ACCL:IN20:300:L0A_PDES');
L0b_phase  = lcaGetSmart('ACCL:IN20:400:L0B_PDES');
TCAV_volts = lcaGetSmart('TCAV:IN20:490:TC0_ADES');

energy = gun_volts*cosd(gun_phase) + L0a_volts*cosd(L0a_phase)*L0a_ON + L0b_volts*cosd(L0b_phase)*L0b_ON;

betaY  = lcaGetSmart('OTRS:IN20:571:BETA_Y');
alphaY = lcaGetSmart('OTRS:IN20:571:ALPHA_Y');
emitY  = lcaGetSmart('OTRS:IN20:571:EMITN_Y');

S_OTR2 = [betaY -alphaY; -alphaY (1+alphaY^2)/betaY];

S_YC06 = R(3:4,3:4)*S_OTR2*R(3:4,3:4)';

sigY = sqrt(S_YC06(1,1)*emitY*1E-6/(energy/511E-3));

disp(sprintf('Sigma_Y at TCAV0 center is presently: %4.0f microns rms at %5.1f MeV',sigY*1E6,energy))
disp(sprintf('Slope of BPM10 vs TCAV0 phase should be: %6.3f mm/deg at %5.1f MeV',180/pi*RTCAV(3,4)*TCAV_volts/energy,energy))
