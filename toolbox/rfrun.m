% rfrun.m
% controls RF amplitudes and phases

delay =.25; % delay time between loops


refpv = 'SIOC:SYS0:ML00:AO941';

% check to be sure another copy isn't running
startnum = lcaGet(refpv);
pause(5);
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end

lcaPut([refpv, '.DESC'], 'rfrun_running');
lcaPut ([refpv, '.EGU'], ' ');





rfstruct = struct;
numrf = 7;

k = 0;
j = 1;
rfstruct(j).basename = 'laser';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU']; %PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU'];% PV for units
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).I_pv = 'LASR:IN20:1:LSR_I_ADJUST';
rfstruct(j).Q_pv = 'LASR:IN20:1:LSR_Q_ADJUST';
rfstruct(j).subharm = 6; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change % was 1
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = '';
rfstruct(j).fb_ades = '';

j = j + 1;
rfstruct(j).basename = 'gun';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU'];% PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU'];% PV for units
rfstruct(j).I_pv = 'GUN:IN20:1:GUN_I_ADJUST';
rfstruct(j).Q_pv = 'GUN:IN20:1:GUN_Q_ADJUST';
rfstruct(j).subharm = 1; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = 'GUN:IN20:1:GN1_PDES';
rfstruct(j).fb_ades = 'GUN:IN20:1:GN1_ADES';

j = j + 1;
rfstruct(j).basename = 'L0a';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU']; %PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU']; %PV for units
rfstruct(j).I_pv = 'ACCL:IN20:300:L0A_I_ADJUST';
rfstruct(j).Q_pv = 'ACCL:IN20:300:L0A_Q_ADJUST';
rfstruct(j).subharm = 1; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = '';
rfstruct(j).fb_ades = '';

j = j+ 1;
rfstruct(j).basename = 'L0b';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU']; %PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU']; %PV for units
rfstruct(j).I_pv = 'ACCL:IN20:400:L0B_I_ADJUST';
rfstruct(j).Q_pv = 'ACCL:IN20:400:L0B_Q_ADJUST';
rfstruct(j).subharm = 1; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = '';
rfstruct(j).fb_ades = '';

j = j+ 1;
rfstruct(j).basename = 'L1s';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO90',num2str(k),'.EGU']; %PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.EGU']; %PV for units
rfstruct(j).I_pv = 'ACCL:LI21:1:L1S_I_ADJUST';
rfstruct(j).Q_pv = 'ACCL:LI21:1:L1S_Q_ADJUST';
rfstruct(j).subharm = 1; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = '';
rfstruct(j).fb_ades = '';



j = j+ 1;
rfstruct(j).basename = 'Tcav';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.EGU']; %PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.EGU']; %PV for units
rfstruct(j).I_pv = 'TCAV:IN20:490:TC0_I_ADJUST';
rfstruct(j).Q_pv = 'TCAV:IN20:490:TC0_Q_ADJUST';
rfstruct(j).subharm = 1; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = '';
rfstruct(j).fb_ades = '';



j = j+ 1;
rfstruct(j).basename = 'XBAND';
k = k + 1;
rfstruct(j).phase_desc_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.DESC']; % PV for description string
rfstruct(j).phase_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.VAL']; % PV for phase value
rfstruct(j).phase_egu_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.EGU']; %PV for units
k = k + 1;
rfstruct(j).amp_desc_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.DESC']; % PV for description string
rfstruct(j).amp_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.VAL']; % PV for amplitude value
rfstruct(j).amp_egu_pv = ['SIOC:SYS0:ML00:AO9',num2str(k),'.EGU']; %PV for units
rfstruct(j).I_pv = 'ACCL:LI21:180:L1X_I_ADJUST';
rfstruct(j).Q_pv = 'ACCL:LI21:180:L1X_Q_ADJUST';
rfstruct(j).subharm = 1; % subharmonic of S-band
rfstruct(j).maxchange = 10; % maximum phase change
rfstruct(j).use_rf_fb = 0;
rfstruct(j).fb_pdes = '';
rfstruct(j).fb_ades = '';












n = 0;
m = 0;
while 1
    m = m + 1;
    if m > 999
        m = 1;
    end
    if mod(m,5)
        lcaPut(refpv, num2str(m/5));
    end
    n = n + 1;
    for j = 1:numrf
        set_p_a(rfstruct(j), n, j);
    end
    pause(delay);
end
lcaClear; % clears all monitors
