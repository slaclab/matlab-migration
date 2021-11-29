function start_cmos(param)

CMOS_PVs = param.cam_CMOS(:,2);

% Turn acquistion on
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),1);

% Enable Triggers
lcaPutSmart(strcat('EVR:LI20:',param.cmos_ioc,':EVENT',num2str(param.cmos_trig_ctrl_num),'CTRL.OUT0'),1);