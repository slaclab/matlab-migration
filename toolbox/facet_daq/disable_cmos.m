function disable_cmos(param)

CMOS_PVs = param.cam_CMOS(:,2);

% Make sure acquisition is off
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),0);
pause(0.5);

% Make sure triggers are disabled
lcaPutSmart(strcat('EVR:LI20:',param.cmos_ioc,':EVENT',num2str(param.cmos_trig_ctrl_num),'CTRL.OUT0'),0);

% Set acquistion mode to 'continuous' and set number of images
lcaPutSmart(strcat(CMOS_PVs,':ImageMode'),2);
lcaPutSmart(strcat(CMOS_PVs,':NumImages'),1);

% This turns the image saving plugin on and off
lcaPutSmart(strcat(CMOS_PVs,':TIFF:EnableCallbacks'),0);
pause(1.0);

% Turn acquistion and trigger back on
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),1);
pause(0.5);

% Enable Triggers
lcaPutSmart(strcat('EVR:LI20:',param.cmos_ioc,':EVENT',num2str(param.cmos_trig_ctrl_num),'CTRL.OUT0'),1);