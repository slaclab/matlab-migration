function set_laser_transport_BM()

% LRoomFar beam mark
LRoomFar_X_PM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO023');
LRoomFar_Y_PM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO024');
LRoomFar_RES = lcaGetSmart('PROF:LI20:12:RESOLUTION');
LRoomFar_X_RTCL_CTR = lcaGetSmart('PROF:LI20:12:X_RTCL_CTR');
LRoomFar_Y_RTCL_CTR = lcaGetSmart('PROF:LI20:12:Y_RTCL_CTR');

% positive means not flipped = 0 - to be confirmed
% negative means flipped = 1 - to be confirmed
lcaPutSmart('PROF:LI20:12:X_ORIENT', 0);  % <--
lcaPutSmart('PROF:LI20:12:Y_ORIENT', 0);  % <--

lcaPutSmart('PROF:LI20:12:X_BM_CTR', 1e-3*(LRoomFar_X_PM_pix+LRoomFar_X_RTCL_CTR)*LRoomFar_RES);
lcaPutSmart('PROF:LI20:12:Y_BM_CTR', -1e-3*(LRoomFar_Y_PM_pix+LRoomFar_Y_RTCL_CTR)*LRoomFar_RES);

% LRoom Near beam mark

% < place holder >

% B1 beam mark
B1_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO005');
B1_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO006');
B1_RES = lcaGetSmart('PROF:LI20:B200:RESOLUTION');
B1_X_RTCL_CTR = lcaGetSmart('PROF:LI20:B200:X_RTCL_CTR');
B1_Y_RTCL_CTR = lcaGetSmart('PROF:LI20:B200:Y_RTCL_CTR');

lcaPutSmart('PROF:LI20:B200:X_ORIENT', 0);  % <--
lcaPutSmart('PROF:LI20:B200:Y_ORIENT', 0);  % <--

lcaPutSmart('PROF:LI20:B200:X_BM_CTR', 1e-3*(B1_X_BM_pix+B1_X_RTCL_CTR)*B1_RES);
lcaPutSmart('PROF:LI20:B200:Y_BM_CTR', -1e-3*(B1_Y_BM_pix+B1_Y_RTCL_CTR)*B1_RES);


% B2 beam mark
B2_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO007');
B2_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO008');
B2_RES = lcaGetSmart('PROF:LI20:B201:RESOLUTION');
B2_X_RTCL_CTR = lcaGetSmart('PROF:LI20:B201:X_RTCL_CTR');
B2_Y_RTCL_CTR = lcaGetSmart('PROF:LI20:B201:Y_RTCL_CTR');
B2_data = profmon_grab('PROF:LI20:B201');

lcaPutSmart('PROF:LI20:B201:X_ORIENT', 1);  % <--
lcaPutSmart('PROF:LI20:B201:Y_ORIENT', 0);  % <--

lcaPutSmart('PROF:LI20:B201:X_BM_CTR', 1e-3*(B2_X_BM_pix-B2_data.nCol+B2_X_RTCL_CTR-1)*B2_RES);
lcaPutSmart('PROF:LI20:B201:Y_BM_CTR', -1e-3*(B2_Y_BM_pix+B2_Y_RTCL_CTR)*B2_RES);

% B3 beam mark
B3_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO009');
B3_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO010');
B3_RES = lcaGetSmart('PROF:LI20:B202:RESOLUTION');
B3_X_RTCL_CTR = lcaGetSmart('PROF:LI20:B202:X_RTCL_CTR');
B3_Y_RTCL_CTR = lcaGetSmart('PROF:LI20:B202:Y_RTCL_CTR');
B3_data = profmon_grab('PROF:LI20:B202');

lcaPutSmart('PROF:LI20:B202:X_ORIENT', 1);  % <--
lcaPutSmart('PROF:LI20:B202:Y_ORIENT', 1);  % <--

lcaPutSmart('PROF:LI20:B202:X_BM_CTR', 1e-3*(B3_X_BM_pix-B3_data.nCol+B3_X_RTCL_CTR-1)*B3_RES);
lcaPutSmart('PROF:LI20:B202:Y_BM_CTR', -1e-3*(B3_Y_BM_pix-B3_data.nRow+B3_Y_RTCL_CTR-1)*B3_RES);

% B4 beam mark
B4_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO011');
B4_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO012');
B4_RES = lcaGetSmart('PROF:LI20:B203:RESOLUTION');
B4_X_RTCL_CTR = lcaGetSmart('PROF:LI20:B203:X_RTCL_CTR');
B4_Y_RTCL_CTR = lcaGetSmart('PROF:LI20:B203:Y_RTCL_CTR');
B4_data = profmon_grab('PROF:LI20:B203');

lcaPutSmart('PROF:LI20:B203:X_ORIENT', 1);  % <--
lcaPutSmart('PROF:LI20:B203:Y_ORIENT', 1);  % <--

lcaPutSmart('PROF:LI20:B203:X_BM_CTR', 1e-3*(B4_X_BM_pix-B4_data.nCol+B4_X_RTCL_CTR-1)*B4_RES);
lcaPutSmart('PROF:LI20:B203:Y_BM_CTR', -1e-3*(B4_Y_BM_pix-B4_data.nRow+B4_Y_RTCL_CTR-1)*B4_RES);

% B6 beam mark
B6_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO013');
B6_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO014');
B6_RES = lcaGetSmart('PROF:LI20:B204:RESOLUTION');
B6_X_RTCL_CTR = lcaGetSmart('PROF:LI20:B204:X_RTCL_CTR');
B6_Y_RTCL_CTR = lcaGetSmart('PROF:LI20:B204:Y_RTCL_CTR');

lcaPutSmart('PROF:LI20:B204:X_ORIENT', 0);  % <--
lcaPutSmart('PROF:LI20:B204:Y_ORIENT', 0);  % <--

lcaPutSmart('PROF:LI20:B204:X_BM_CTR', 1e-3*(B6_X_BM_pix+B6_X_RTCL_CTR)*B6_RES);
lcaPutSmart('PROF:LI20:B204:Y_BM_CTR', -1e-3*(B6_Y_BM_pix+B6_Y_RTCL_CTR)*B6_RES);

% Probe1_Far beam mark
Probe1_Far_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO015');
Probe1_Far_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO016');
Probe1_Far_RES = lcaGetSmart('EXPT:LI20:3311:RESOLUTION');
Probe1_Far_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3311:X_RTCL_CTR');
Probe1_Far_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3311:Y_RTCL_CTR');
Probe1_Far_data = profmon_grab('EXPT:LI20:3311');

lcaPutSmart('EXPT:LI20:3311:X_ORIENT', 1);  % <--
lcaPutSmart('EXPT:LI20:3311:Y_ORIENT', 1);  % <--

lcaPutSmart('EXPT:LI20:3311:X_BM_CTR', 1e-3*(Probe1_Far_X_BM_pix-Probe1_Far_data.nCol+Probe1_Far_X_RTCL_CTR-1)*Probe1_Far_RES);
lcaPutSmart('EXPT:LI20:3311:Y_BM_CTR', -1e-3*(Probe1_Far_Y_BM_pix-Probe1_Far_data.nRow+Probe1_Far_Y_RTCL_CTR-1)*Probe1_Far_RES);

% Probe2_Near beam mark
Probe2_Near_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO017');
Probe2_Near_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO018');
Probe2_Near_RES = lcaGetSmart('EXPT:LI20:3308:RESOLUTION');
Probe2_Near_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3308:X_RTCL_CTR');
Probe2_Near_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3308:Y_RTCL_CTR');
Probe2_Near_data = profmon_grab('EXPT:LI20:3308');

lcaPutSmart('EXPT:LI20:3308:X_ORIENT', 1);  % <--
lcaPutSmart('EXPT:LI20:3308:Y_ORIENT', 1);  % <--

lcaPutSmart('EXPT:LI20:3308:X_BM_CTR', 1e-3*(Probe2_Near_X_BM_pix-Probe2_Near_data.nCol+Probe2_Near_X_RTCL_CTR-1)*Probe2_Near_RES);
lcaPutSmart('EXPT:LI20:3308:Y_BM_CTR', -1e-3*(Probe2_Near_Y_BM_pix-Probe2_Near_data.nRow+Probe2_Near_Y_RTCL_CTR-1)*Probe2_Near_RES);


% TH_Far beam mark
TH_Far_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO019');
TH_Far_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO020');
TH_Far_RES = lcaGetSmart('EXPT:LI20:3312:RESOLUTION');
TH_Far_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3312:X_RTCL_CTR');
TH_Far_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3312:Y_RTCL_CTR');
TH_Far_data = profmon_grab('EXPT:LI20:3312');

lcaPutSmart('EXPT:LI20:3312:X_ORIENT', 1);  % <--
lcaPutSmart('EXPT:LI20:3312:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3312:X_BM_CTR', 1e-3*(TH_Far_X_BM_pix-TH_Far_data.nCol+TH_Far_X_RTCL_CTR-1)*TH_Far_RES);
lcaPutSmart('EXPT:LI20:3312:Y_BM_CTR', -1e-3*(TH_Far_Y_BM_pix+TH_Far_Y_RTCL_CTR)*TH_Far_RES);


% TH_Near beam mark
TH_Near_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO021');
TH_Near_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO022');
TH_Near_RES = lcaGetSmart('EXPT:LI20:3307:RESOLUTION');
TH_Near_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3307:X_RTCL_CTR');
TH_Near_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3307:Y_RTCL_CTR');

lcaPutSmart('EXPT:LI20:3307:X_ORIENT', 0);  % <--
lcaPutSmart('EXPT:LI20:3307:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3307:X_BM_CTR', 1e-3*(TH_Near_X_BM_pix+TH_Near_X_RTCL_CTR)*TH_Near_RES);
lcaPutSmart('EXPT:LI20:3307:Y_BM_CTR', -1e-3*(TH_Near_Y_BM_pix+TH_Near_Y_RTCL_CTR)*TH_Near_RES);

% IPOTR3 beam mark - ebeam reference on 01/16/2016
% IPOTR3_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO025');
% IPOTR3_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO026');
% IPOTR3_RES = lcaGetSmart('EXPT:LI20:3301:RESOLUTION');
% IPOTR3_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3301:X_RTCL_CTR');
% IPOTR3_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3301:Y_RTCL_CTR');
% IPOTR3_data = profmon_grab('EXPT:LI20:3301');
% 
% lcaPutSmart('EXPT:LI20:3301:X_ORIENT', 1);  % <--
% lcaPutSmart('EXPT:LI20:3301:Y_ORIENT', 0);  % <--
% 
% lcaPutSmart('EXPT:LI20:3301:X_BM_CTR', 1e-3*(IPOTR3_X_BM_pix-IPOTR3_data.nCol+IPOTR3_X_RTCL_CTR-1)*IPOTR3_RES);
% lcaPutSmart('EXPT:LI20:3301:Y_BM_CTR', -1e-3*(IPOTR3_Y_BM_pix+IPOTR3_Y_RTCL_CTR)*IPOTR3_RES);


% E224_1 beam mark - reference on 01/19/2016
E224_1_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO027');
E224_1_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO028');
E224_1_RES = lcaGetSmart('EXPT:LI20:3302:RESOLUTION');
E224_1_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3302:X_RTCL_CTR');
E224_1_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3302:Y_RTCL_CTR');
E224_1_data = profmon_grab('EXPT:LI20:3302');

lcaPutSmart('EXPT:LI20:3302:X_ORIENT', 1);  % <--
lcaPutSmart('EXPT:LI20:3302:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3302:X_BM_CTR', 1e-3*(E224_1_X_BM_pix-E224_1_data.nCol+E224_1_X_RTCL_CTR-1)*E224_1_RES);
lcaPutSmart('EXPT:LI20:3302:Y_BM_CTR', -1e-3*(E224_1_Y_BM_pix+E224_1_Y_RTCL_CTR)*E224_1_RES);

% E224_2 beam mark - reference on 01/19/2016
E224_2_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO029');
E224_2_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO030');
E224_2_RES = lcaGetSmart('EXPT:LI20:3300:RESOLUTION');
E224_2_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3300:X_RTCL_CTR');
E224_2_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3300:Y_RTCL_CTR');
E224_2_data = profmon_grab('EXPT:LI20:3300');

lcaPutSmart('EXPT:LI20:3300:X_ORIENT', 1);  % <--
lcaPutSmart('EXPT:LI20:3300:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3300:X_BM_CTR', 1e-3*(E224_2_X_BM_pix-E224_2_data.nCol+E224_2_X_RTCL_CTR-1)*E224_2_RES);
lcaPutSmart('EXPT:LI20:3300:Y_BM_CTR', -1e-3*(E224_2_Y_BM_pix+E224_2_Y_RTCL_CTR)*E224_2_RES);

% E224_3 beam mark - reference on 01/19/2016
E224_3_X_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO031');
E224_3_Y_BM_pix = lcaGetSmart('SIOC:SYS1:ML03:AO032');
E224_3_RES = lcaGetSmart('EXPT:LI20:3304:RESOLUTION');
E224_3_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3304:X_RTCL_CTR');
E224_3_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3304:Y_RTCL_CTR');
E224_3_data = profmon_grab('EXPT:LI20:3304');

lcaPutSmart('EXPT:LI20:3304:X_ORIENT', 1);  % <--
lcaPutSmart('EXPT:LI20:3304:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3304:X_BM_CTR', 1e-3*(E224_3_X_BM_pix-E224_3_data.nCol+E224_3_X_RTCL_CTR-1)*E224_3_RES);
lcaPutSmart('EXPT:LI20:3304:Y_BM_CTR', -1e-3*(E224_3_Y_BM_pix+E224_3_Y_RTCL_CTR)*E224_3_RES);

% EOF
