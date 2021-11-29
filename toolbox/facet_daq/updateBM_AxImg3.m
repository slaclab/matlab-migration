function updateBM_AxImg3()
numb_of_shots = 10;

x_max = [];
y_max = [];

for i=1:numb_of_shots
    data = profmon_grab('EXPT:LI20:3313');
    figure(1); imagesc(data.img);
    [x_max(end+1),y_max(end+1)] = ginput(1);
    pause(0.01);
end
x = mean(x_max)+data.roiX;
y = mean(y_max)+data.roiY;

lcaPutSmart('SIOC:SYS1:ML03:AO051',x);
lcaPutSmart('SIOC:SYS1:ML03:AO052',y);

% Ax3 beam mark
Ax3_RES = lcaGetSmart('EXPT:LI20:3313:RESOLUTION');
Ax3_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3313:X_RTCL_CTR');
Ax3_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3313:Y_RTCL_CTR');

lcaPutSmart('EXPT:LI20:3313:X_ORIENT', 0);  % <--
lcaPutSmart('EXPT:LI20:3313:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3313:X_BM_CTR', 1e-3*(x-Ax3_X_RTCL_CTR)*Ax3_RES);    
lcaPutSmart('EXPT:LI20:3313:Y_BM_CTR', -1e-3*(y-Ax3_Y_RTCL_CTR)*Ax3_RES);

end



