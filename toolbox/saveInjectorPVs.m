% This stuffs PVs associated with the injector into
% Matlab PVs for safe keeping.  To be implemented every time we do a
% laser swap, or injector charge change, or MD, or if Ago shows up.

function keepers = saveInjectorPVs() %#ok<STOUT>
disp('saveInjectorPVs.m, v1.1, 10/18/2016');
%10/18/16  tonee -- Add current past BC1, BPM attenuations, and MH3+MH2
%
global IN20QS; 
%
IN20QS = [121 122 361 371 425 441 511 525];
numquads = length(IN20QS);
%
watchdog_pv = 'SIOC:SYS0:ML03:AO629';
W = watchdog(watchdog_pv, 5, 'saveInjector.m');
delay = 5; % loop rate
L = generate_pv_list(); %
ringsize = 5;
lcaSetSeverityWarnLevel(5); % disable almost all warnings
d  = lcaGetSmart(L.pv, 16000, 'double'); % get data
lcaSetMonitor(L.pv); % set up monitor
D = cell(ringsize,1); % will hold all data
F = cell(ringsize,1); % will hold monitor flags
D{1}= d;  F{1} = zeros(length(d),1);  %just initialize
ctr = 1;  % start at 2, initialize old data
cycle = 0; %
stats = struct;
CQMQctrlValue = zeros(numquads,1);
%
while 1 % Loop forever
    cycle = cycle + 1;
    if ctr > ringsize
        ctr = 1;
    else
        ctr = ctr + 1;
    end
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp('Some sort of watchdog error');
        break;  % Exit program
    end
    try
        flags = lcaNewMonitorValue(L.pv); % look for new data
    catch %#ok<*CTCH>
        disp(['lca get error', '  ', num2str(cycle)]);
    end
    if sum(flags) % There is some new data to look at
        d = lcaGetSmart(L.pv, 16000, 'double'); % get data
        D{ctr} = d;  % save in structures to analyze later
        F{ctr} = flags;
    else
        continue; % nothing to do here
    end
%
stats.SaveInjector      =  d(L.saveInjector_n);
stats.Vitara1_phSetp    =  d(L.Vitara1_phSetp_n);
stats.Vitara1_phoffS    =  d(L.Vitara1_phoffS_n);
stats.Vitara2_phSetp    =  d(L.Vitara2_phSetp_n);
stats.Vitara2_phoffS    =  d(L.Vitara2_phoffS_n);
stats.UVLaserMode       =  d(L.UVLaserMode_n); %enum numerical
stats.IRLaserMode       =  d(L.IRLaserMode_n); %enum numerical
stats.PMosc1            = d(L.PMosc1_n);
stats.PMosc2            = d(L.PMosc2_n);
stats.LaserFdBk1        = d(L.LaserFdBk1_n);
stats.LaserFdBk2        = d(L.LaserFdBk2_n);
stats.LaserWP2angle      = d(L.LaserWP2angle_n);
stats.ParmShutter       = d(L.ParmShutter_n);
stats.SarmShutter       = d(L.SarmShutter_n);
stats.PulstackDelay     = d(L.PulstackDelay_n);
stats.PulstackWPangle   = d(L.PulstackWPangle_n);
stats.IrisSteerH        = d(L.IrisSteerH_n);
stats.IrisSteerV        = d(L.IrisSteerV_n);
stats.IrisMotorX        = d(L.IrisMotorX_n);
stats.IrisMotorAngle    = d(L.IrisMotorAngle_n);
stats.VCC_WPAngle       = d(L.VCC_WPAngle_n);
stats.VCC_Xpos          = d(L.VCC_Xpos_n);
stats.VCC_Ypos          = d(L.VCC_Ypos_n);
stats.LaserEnergy       = d(L.LaserEnergy_n);
stats.VCC_Xoffset       = d(L.VCC_Xoffset_n);
stats.VCC_Yoffset       = d(L.VCC_Yoffset_n);
stats.VCC_P2P           = d(L.VCC_P2P_n);
stats.CathodeQE         = d(L.CathodeQE_n);
stats.LHfbck            = d(L.LHfbck_n);
stats.LHWPangle         = d(L.LHWPangle_n);
stats.LHWPfbck          = d(L.LHWPfbck_n);
stats.LHdelay           = d(L.LHdelay_n);
stats.LHpower           = d(L.LHpower_n);
stats.LHshutter         = d(L.LHshutter_n);
stats.bunchq_mat_setpt  = d(L.bunchq_mat_setpt_n);
stats.bunchq_mat_state  = d(L.bunchq_mat_state_n);
stats.GunPhase          = d(L.GunPhase_n);
stats.L0Bphase          = d(L.L0Bphase_n);
stats.L1Sphase          = d(L.L1Sphase_n);
stats.BC1peakI          = d(L.BC1peakI_n);
stats.BC1CollLeft       = d(L.BC1CollLeft_n);
stats.BC1CollRight      = d(L.BC1CollRight_n);
stats.Soln1BDES         = d(L.Soln1BDES_n);
stats.Soln1Bklg         = d(L.Soln1Bklg_n);
for iquad = 1:numquads
        CQMQctrlValue(iquad) = d(L.CQMQctrl_n(iquad));
        CQMQpv.name{(iquad),1}    = L.pv{L.CQMQctrl_n(iquad),1};
end
stats.CQMQctrl          = CQMQctrlValue;
stats.CQMQpv            = CQMQpv.name;
stats.LHact_MH3H        = d(L.LHact_MH3H_n);
stats.LHact_MH3V        = d(L.LHact_MH3V_n);
stats.LHact_MH2H        = d(L.LHact_MH2H_n);
stats.LHact_MH2V        = d(L.LHact_MH2V_n);
stats.BC1_TMIT          = d(L.BC1_TMIT_n);
stats.LTU_TMIT          = d(L.LTU_TMIT_n);
stats.BPMatten          = d(L.BPMatten_n);
stats.GuardianTMIT      = d(L.GuardianTMIT_n);
%
%
if stats.SaveInjector  % if the snapshot button is pushed, store a snapshot of the injector
    output.pv{1,1} = L.pv{L.UVLaserMode_store_n, 1}; % place to stash the Drive Laser Mode
    output.value(1,1) = stats.UVLaserMode; % Drive Laser Mode readback
    output.pv{2,1} = L.pv{L.Vitara1_phSetp_store_n, 1}; % place to stash the Vitara#1 Phase Setpoint
    output.value(2,1) = stats.Vitara1_phSetp; % Vitara 1 phase setpoint readback... etc
    output.pv{3,1} = L.pv{L.Vitara1_phoffS_store_n,1}; % Vitara1 phase offset Sband degrees
    output.value(3,1) = stats.Vitara1_phoffS;
    output.pv{4,1} = L.pv{L.Vitara2_phSetp_store_n, 1}; % Vitara 2 Phase Setpoint
    output.value(4,1) = stats.Vitara2_phSetp; 
    output.pv{5,1} = L.pv{L.Vitara2_phoffS_store_n,1}; % Vitara 2 phase offset Sband degrees
    output.value(5,1) = stats.Vitara2_phoffS;
    output.pv{6,1} = L.pv{L.IRLaserMode_store_n, 1}; % Drive Laser Mode
    output.value(6,1) = stats.IRLaserMode; 
    output.pv{7,1} = L.pv{L.PMosc1_store_n, 1}; % PMosc1 Laser Power
    output.value(7,1) = stats.PMosc1;
    output.pv{8,1} = L.pv{L.PMosc2_store_n, 1}; %PMosc2 Laser Power
    output.value(8,1) = stats.PMosc2;
    output.pv{9,1} = L.pv{L.LaserFdBk1_store_n, 1}; %Laser Feedback Loop 1
    output.value(9,1) = stats.LaserFdBk1;
    output.pv{10,1} = L.pv{L.LaserFdBk2_store_n, 1}; %Laser Feedback Loop 2
    output.value(10,1) = stats.LaserFdBk2;
    output.pv{11,1} = L.pv{L.LaserWP2angle_store_n, 1}; % Laser Waveplate Angle WP2
    output.value(11,1) = stats.LaserWP2angle;
    output.pv{12,1} = L.pv{L.ParmShutter_store_n, 1}; % P-Arm Shutter Status
    output.value(12,1) = stats.ParmShutter;
    output.pv{13,1} = L.pv{L.SarmShutter_store_n, 1}; % S-Arm Shutter Status
    output.value(13,1) = stats.SarmShutter;
    output.pv{14,1} = L.pv{L.PulstackDelay_store_n, 1};  % Pulse Stacker Delay
    output.value(14,1) = stats.PulstackDelay;
    output.pv{15,1} = L.pv{L.PulstackWPangle_store_n, 1};  % Pulse Stacker Waveplate Angle
    output.value(15,1) = stats.PulstackWPangle;
    output.pv{16,1} = L.pv{L.IrisSteerH_store_n, 1};  % Iris Steering Horizontal
    output.value(16,1) = stats.IrisSteerH;
    output.pv{17,1} = L.pv{L.IrisSteerV_store_n, 1};  % Iris Steering Vertical
    output.value(17,1) = stats.IrisSteerV;
    output.pv{18,1} = L.pv{L.IrisMotorX_store_n, 1};  % Iris Steering Motor X
    output.value(18,1) = stats.IrisMotorX;
    output.pv{19,1} = L.pv{L.IrisMotorAngle_store_n, 1};  % Iris Steering Motor Angle
    output.value(19,1) = stats.IrisMotorAngle;
    output.pv{20,1} = L.pv{L.VCC_WPAngle_store_n, 1};  % VCC Waveplate Angle
    output.value(20,1) = stats.VCC_WPAngle;
    output.pv{21,1} = L.pv{L.VCC_Xpos_store_n, 1};  % VCC X position
    output.value(21,1) = stats.VCC_Xpos;
    output.pv{22,1} = L.pv{L.VCC_Ypos_store_n, 1};  % VCC Y Position 
    output.value(22,1) = stats.VCC_Ypos;
    output.pv{23,1} = L.pv{L.LaserEnergy_store_n, 1};  % VCC Laser Energy
    output.value(23,1) = stats.LaserEnergy;
    output.pv{24,1} = L.pv{L.VCC_Xoffset_store_n, 1};  % VCC X offset
    output.value(24,1) = stats.VCC_Xoffset;
    output.pv{25,1} = L.pv{L.VCC_Yoffset_store_n, 1};  % VCC Y offset 
    output.value(25,1) = stats.VCC_Yoffset;
    output.pv{26,1} = L.pv{L.CathodeQE_store_n, 1}; % Cathode QE
    output.value(26,1) = stats.CathodeQE;
    output.pv{27,1} = L.pv{L.LHfbck_store_n, 1}; %Laser Heater Loop status
    output.value(27,1) = stats.LHfbck;
    output.pv{28,1} = L.pv{L.LHWPangle_store_n, 1}; %Laser Heater Waveplate Angle
    output.value(28,1) = stats.LHWPangle;
    output.pv{29,1} = L.pv{L.LHWPfbck_store_n, 1}; %Laser Heater Waveplate loop status
    output.value(29,1) = stats.LHWPfbck;
    output.pv{30,1} = L.pv{L.LHdelay_store_n, 1}; %Laser Heater Delay
    output.value(30,1) = stats.LHdelay;
    output.pv{31,1} = L.pv{L.LHpower_store_n, 1}; %Laser Heater Power
    output.value(31,1) = stats.LHpower;
    output.pv{32,1} = L.pv{L.LHshutter_store_n, 1}; %Laser Heater Shutter
    output.value(32,1) = stats.LHshutter;
    output.pv{33,1} = L.pv{L.bunchq_mat_setpt_store_n, 1}; % Bunch Charge MAtlab feedback setpoint
    output.value(33,1) = stats.bunchq_mat_setpt;
    output.pv{34,1} = L.pv{L.bunchq_mat_state_store_n, 1}; % Bunch Charge MAtlab feedback state
    output.value(34,1) = stats.bunchq_mat_state;
    output.pv{35,1} = L.pv{L.VCC_P2P_store_n, 1}; % VCC P2P threshold/pixel
    output.value(35,1) = stats.VCC_P2P;
    output.pv{36,1} = L.pv{L.BC1CollLeft_store_n, 1}; % Bc1 Coll Left Jaw
    output.value(36,1) = stats.BC1CollLeft;
    output.pv{37,1} = L.pv{L.BC1CollRight_store_n, 1}; % Bc1 Coll Left Jaw
    output.value(37,1) = stats.BC1CollRight;
    output.pv{38,1} = L.pv{L.GunPhase_store_n, 1}; % 
    output.value(38,1) = stats.GunPhase;
    output.pv{39,1} = L.pv{L.L0Bphase_store_n, 1}; % 
    output.value(39,1) = stats.L0Bphase;
    output.pv{40,1} = L.pv{L.L1Sphase_store_n, 1}; % 
    output.value(40,1) = stats.L1Sphase;
    output.pv{41,1} = L.pv{L.BC1peakI_store_n, 1}; % 
    output.value(41,1) = stats.BC1peakI;
    output.pv{42,1} = L.pv{L.Soln1BDES_store_n, 1}; %
    output.value(42,1) = stats.Soln1BDES;
    output.pv{43,1} = L.pv{L.Soln1Bklg_store_n, 1}; %
    output.value(43,1) = stats.Soln1Bklg;
    output.pv{44,1} = L.pv{L.LHact_MH3H_store_n, 1}; %
    output.value(44,1) = stats.LHact_MH3H;
    output.pv{45,1} = L.pv{L.LHact_MH3V_store_n, 1}; %
    output.value(45,1) = stats.LHact_MH3V;
    output.pv{46,1} = L.pv{L.LHact_MH2H_store_n, 1}; %
    output.value(46,1) = stats.LHact_MH2H;
    output.pv{47,1} = L.pv{L.LHact_MH2V_store_n, 1}; %
    output.value(47,1) = stats.LHact_MH2V;   
    output.pv{48,1} = L.pv{L.BC1_TMIT_store_n, 1}; %
    output.value(48,1) = stats.BC1_TMIT;     
    output.pv{49,1} = L.pv{L.LTU_TMIT_store_n, 1}; %
    output.value(49,1) = stats.LTU_TMIT;      
    output.pv{50,1} = L.pv{L.BPMatten_store_n, 1}; %
    output.value(50,1) = stats.BPMatten;      
    output.pv{51,1} = L.pv{L.GuardianTMIT_store_n, 1}; %
    output.value(51,1) = stats.GuardianTMIT;  
%
% do the quads last
    for iquad = 1:numquads
            idx = 51 + iquad;
            output.pv{idx,1} = L.pv{L.CQMQctrl_store_n(iquad), 1};
            output.value(idx,1) = stats.CQMQctrl(iquad);
    end
%
% Get the string PVs
%    
    strget.pv{1,1}     = L.pv{L.UVLaserMode_n, 1};% enum text
    strput.pv{1,1}     = pv_to_comment(L.pv{L.UVLaserMode_store_n, 1});
    strget.pv{2,1}     = L.pv{L.IRLaserMode_n, 1};% enum text
    strput.pv{2,1}     = pv_to_comment(L.pv{L.IRLaserMode_store_n, 1});
    strget.pv{3,1}     = L.pv{L.LaserFdBk1_n, 1};% enum text
    strput.pv{3,1}     = pv_to_comment(L.pv{L.LaserFdBk1_store_n, 1});
    strget.pv{4,1}     = L.pv{L.LaserFdBk2_n, 1};% enum text
    strput.pv{4,1}     = pv_to_comment(L.pv{L.LaserFdBk2_store_n, 1});
    strget.pv{5,1}     = L.pv{L.ParmShutter_n, 1};% enum text
    strput.pv{5,1}     = pv_to_comment(L.pv{L.ParmShutter_store_n, 1});
    strget.pv{6,1}     = L.pv{L.SarmShutter_n, 1};% enum text
    strput.pv{6,1}     = pv_to_comment(L.pv{L.SarmShutter_store_n, 1});
    strget.pv{7,1}     = L.pv{L.LHfbck_n, 1};% enum text
    strput.pv{7,1}     = pv_to_comment(L.pv{L.LHfbck_store_n, 1});
    strget.pv{8,1}     = L.pv{L.LHshutter_n, 1};% enum text
    strput.pv{8,1}     = pv_to_comment(L.pv{L.LHshutter_store_n, 1});
%
    strput.enumtxt     = lcaGet(strget.pv);
    lcaPut(strput.pv,strput.enumtxt);
%
% and then set the "Save the Injector" bit back to 0
%
    output.pv{idx+1,1} = L.pv{L.saveInjector_n, 1};
    output.value(idx+1,1) = 0;
    %
    lcaPutSmart(output.pv, output.value);
    disp('Writing Injector parameters to Matlab PVs ML03 605+');
end
end
end
    function L = generate_pv_list()
    global IN20QS;
        n = 0;
        pvstart = 630; % First set up the storage slots = matlab PVs in ML03
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'Shall we save the Injector?', '1=Y', 0, 'saveInjector.m');
        L.saveInjector_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Vitara 1 phase setpoint ', 'degS', 3, 'saveInjector.m');
        L.Vitara1_phSetp_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Vitara 1 phase offset', 'degS', 3, 'saveInjector.m');
        L.Vitara1_phoffS_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Vitara 2 phase setpoint ', 'degS', 3, 'saveInjector.m');
        L.Vitara2_phSetp_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Vitara 2 phase offset', 'degS', 3, 'saveInjector.m');
        L.Vitara2_phoffS_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'UV Laser Mode', ' ', 0, 'saveInjector.m');
        L.UVLaserMode_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'IR Laser Mode', ' ', 0, 'saveInjector.m');
        L.IRLaserMode_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'PMosc1 laser power', 'mW', 0, 'saveInjector.m');
        L.PMosc1_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'PMosc2 laser power', 'mW', 0, 'saveInjector.m');
        L.PMosc2_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Feedback 1 Loop Status', ' ', 0, 'saveInjector.m');
        L.LaserFdBk1_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Feedback 2 Loop Status', ' ', 0, 'saveInjector.m');
        L.LaserFdBk2_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'Laser Waveplate Angle (WP2)', 'deg', 3, 'saveInjector.m');
        L.LaserWP2angle_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'P-Arm Shutter', '1=out', 0, 'saveInjector.m');
        L.ParmShutter_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'S-Arm Shutter', '1=out', 0, 'saveInjector.m');
        L.SarmShutter_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'Pulse Stacker Delay', 'ns', 3, 'saveInjector.m');
        L.PulstackDelay_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Pulse Stacker WP angle', 'deg', 3, 'saveInjector.m');
        L.PulstackWPangle_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Iris Steering H', 'mm', 3, 'saveInjector.m');
        L.IrisSteerH_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n , 'Iris Steering V', 'mm', 3, 'saveInjector.m');
        L.IrisSteerV_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Iris Motor X', 'mm', 3, 'saveInjector.m');
        L.IrisMotorX_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Iris Motor Angle', 'deg', 3, 'saveInjector.m');
        L.IrisMotorAngle_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'VCC waveplate Angle', 'deg', 3, 'saveInjector.m');
        L.VCC_WPAngle_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'VCC X Position', 'mm', 3, 'saveInjector.m');
        L.VCC_Xpos_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'VCC Y Position', 'mm', 3, 'saveInjector.m');
        L.VCC_Ypos_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'VCC Laser Energy', 'mW', 3, 'saveInjector.m');
        L.LaserEnergy_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'VCC X Offset', 'mm', 3, 'saveInjector.m');
        L.VCC_Xoffset_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'VCC Y Offset', 'mm', 3, 'saveInjector.m');
        L.VCC_Yoffset_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Cathode QE', 'e/ph', 8, 'saveInjector.m');
        L.CathodeQE_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater Loop Status', ' ', 0, 'saveInjector.m');
        L.LHfbck_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater Waveplate Angle', 'deg', 3, 'saveInjector.m');
        L.LHWPangle_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater Waveplate Loop Status', ' ', 0, 'saveInjector.m');
        L.LHWPfbck_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater Delay', 'ps', 3,'saveInjector.m');
        L.LHdelay_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater Power', 'uJ', 4,'saveInjector.m');
        L.LHpower_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater Shutter', '1=out', 0,'saveInjector.m');
        L.LHshutter_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Bunch Charge Matlab Feedback Setpoint', ' ', 2,'saveInjector.m');
        L.bunchq_mat_setpt_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Bunch Charge Matlab Feedback State', ' ', 2,'saveInjector.m');
        L.bunchq_mat_state_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'BC1 Coll Left Jaw', 'mm', 4,'saveInjector.m');
        L.BC1CollLeft_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'BC1 Coll Right Jaw', 'mm', 4,'saveInjector.m');
        L.BC1CollRight_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser VCC P2P Threshold', 'th/pxl', 2,'saveInjector.m');
        L.VCC_P2P_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Gun Phase', 'DegS', 3,'saveInjector.m');
        L.GunPhase_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'L0B Phase', 'DegS', 3,'saveInjector.m');
        L.L0Bphase_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'L1S Phase', 'DegS', 3,'saveInjector.m');
        L.L1Sphase_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'BC1 Peak Current', 'A', 1,'saveInjector.m');
        L.BC1peakI_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Gun Solenoid BDES', 'kG', 4,'saveInjector.m');
        L.Soln1BDES_store_n = n;
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Gun Solenoid Backleg BDES', 'kG', 4,'saveInjector.m');
        L.Soln1Bklg_store_n = n; 
%
        numquads  = length(IN20QS);
        for iquad = 1:numquads
            n = n + 1;
            descStr = ['IN20 Quad ', num2str(IN20QS(iquad)), ' BDES value'];
            L.pv{n,1} = setup_pv(pvstart + n  , descStr, 'kG', 4, 'saveInjector.m');
            L.CQMQctrl_store_n(iquad) = n;
        end
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater FBCK ACT MH3H', 'mm', 4,'saveInjector.m');
        L.LHact_MH3H_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater FBCK ACT MH3V', 'mm', 4,'saveInjector.m');
        L.LHact_MH3V_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater FBCK ACT MH2H', 'mm', 4,'saveInjector.m');
        L.LHact_MH2H_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Laser Heater FBCK ACT MH2V', 'mm', 4,'saveInjector.m');
        L.LHact_MH2V_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Charge after BC1', 'pC', 1,'saveInjector.m');
        L.BC1_TMIT_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Charge in LTU', 'pC', 1,'saveInjector.m');
        L.LTU_TMIT_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Global BPM CHarge setting', 'nC', 3,'saveInjector.m');
        L.BPMatten_store_n = n; 
        n = n + 1;
        L.pv{n,1} = setup_pv(pvstart + n  , 'Guardian TMIT fractional loss setp', ' ', 3,'saveInjector.m');
        L.GuardianTMIT_store_n = n; 
 
        %
        % And now the real PVs
        n = n + 1;
        L.pv{n,1} = 'OSC:LR20:20:PDES';
        L.Vitara1_phSetp_n = n;
        n = n + 1;
        L.pv{n,1} = 'OSC:LR20:20:POC';
        L.Vitara1_phoffS_n = n;
        n = n + 1;
        L.pv{n,1} = 'OSC:LR20:10:PDES';
        L.Vitara2_phSetp_n = n;
        n = n + 1;
        L.pv{n,1} = 'OSC:LR20:10:POC';
        L.Vitara2_phoffS_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:LR20:1:UV_LASER_MODE';
        L.UVLaserMode_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:LR20:1:IR_LASER_MODE';
        L.IRLaserMode_n = n;
        n = n + 1;
        L.pv{n,1} = 'PMTR:LR20:20:PWR';
        L.PMosc1_n = n;
        n = n + 1;
        L.pv{n,1} = 'PMTR:LR20:10:PWR';
        L.PMosc2_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:LR20:110:POS_FDBK_STS';
        L.LaserFdBk1_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:IN20:160:POS_FDBK_STS';
        L.LaserFdBk2_n = n;
        n = n + 1;
        L.pv{n,1} = 'WPLT:LR20:116:WP2_ANGLE.RBV';
        L.LaserWP2angle_n = n;
        n = n + 1;
        L.pv{n,1} = 'SHTR:LR20:117:PARM_STS';
        L.ParmShutter_n = n;
        n = n + 1;
        L.pv{n,1} = 'SHTR:LR20:117:SARM_STS';
        L.SarmShutter_n = n;
        n = n + 1;
        L.pv{n,1} = 'PSDL:LR20:117:TACT';
        L.PulstackDelay_n = n;
        n = n + 1;
        L.pv{n,1} = 'WPLT:LR20:117:PSWP_ANGLE.RBV';
        L.PulstackWPangle_n = n;
        n = n + 1;
        L.pv{n,1} = 'MIRR:LR20:117:IRIS_MOTR_H.RBV';
        L.IrisSteerH_n = n;
        n = n + 1;
        L.pv{n,1} = 'MIRR:LR20:117:IRIS_MOTR_V.RBV';
        L.IrisSteerV_n = n;
        n = n + 1;
        L.pv{n,1} = 'IRIS:LR20:118:MOTR_X.RBV ';
        L.IrisMotorX_n = n;
        n = n + 1;
        L.pv{n,1} = 'IRIS:LR20:118:MOTR_ANGLE.RBV';
        L.IrisMotorAngle_n = n;
        n = n + 1;
        L.pv{n,1} = 'WPLT:IN20:181:VCC_ANGLE.RBV';
        L.VCC_WPAngle_n = n;
        n = n + 1;
        L.pv{n,1} = 'VCTD:IN20:186:VCC_POS_X.RBV';
        L.VCC_Xpos_n = n;
        n = n + 1;
        L.pv{n,1} = 'VCTD:IN20:186:VCC_POS_Y.RBV';
        L.VCC_Ypos_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:IN20:196:PWR1H';
        L.LaserEnergy_n = n;
        n = n + 1;
        L.pv{n,1} = 'SIOC:SYS0:ML00:AO328';
        L.VCC_Xoffset_n = n;
        n = n + 1;
        L.pv{n,1} = 'SIOC:SYS0:ML00:AO329';
        L.VCC_Yoffset_n = n;
        n = n + 1;
        L.pv{n,1} = 'CATH:IN20:111:QE';
        L.CathodeQE_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:IN20:400:POS_FDBK_STS';
        L.LHfbck_n = n;
        n = n + 1;
        L.pv{n,1} = 'WPLT:LR20:117:LHWP_ANGLE.RBV';
        L.LHWPangle_n = n;
        n = n + 1;
        L.pv{n,1} = 'SIOC:SYS0:ML03:AO102';
        L.LHWPfbck_n = n;
        n = n + 1;
        L.pv{n,1} = 'LHDL:LR20:117:TACT';
        L.LHdelay_n = n;
        n = n + 1;
        L.pv{n,1} = 'LASR:IN20:475:PWR1H';
        L.LHpower_n = n;
        n = n + 1;
        L.pv{n,1} = 'MPS:IN20:200:LHSHT1_OUT_MPS';
        L.LHshutter_n = n;
        n = n + 1;
        L.pv{n,1} = 'COLL:LI21:235:MOTR.VAL'; % BC1 Coll Left
        L.BC1CollLeft_n = n;
        n = n + 1;
        L.pv{n,1} = 'COLL:LI21:236:MOTR.VAL'; % BC1 Coll Right
        L.BC1CollRight_n = n;
        n = n + 1;
        L.pv{n,1} = 'FBCK:BCI0:1:CHRGSP'; % matlab bunch charge setpoint
        L.bunchq_mat_setpt_n = n;
        n = n + 1;
        L.pv{n,1} = 'FBCK:BCI0:1:STATE'; % matlab bunch charge state
        L.bunchq_mat_state_n = n;
        n = n + 1;
        L.pv{n,1} = 'CAMR:IN20:186:TSHD_P2P'; % VCC P2P threshold
        L.VCC_P2P_n = n;
        n = n + 1;
        L.pv{n,1} = 'GUN:IN20:1:GN1_PDES';
        L.GunPhase_n = n;
        n = n + 1;
        L.pv{n,1} = 'ACCL:IN20:400:L0B_PDES';
        L.L0Bphase_n = n;
        n = n + 1;
        L.pv{n,1} = 'ACCL:LI21:1:L1S_PDES';
        L.L1Sphase_n = n;
        n = n + 1;
        L.pv{n,1} = 'FBCK:FB04:LG01:S3DES';
        L.BC1peakI_n = n;
        n = n + 1;
        L.pv{n,1} = 'SOLN:IN20:121:BDES';
        L.Soln1BDES_n = n;
        n = n + 1;
        L.pv{n,1} = 'SOLN:IN20:111:BDES';
        L.Soln1Bklg_n = n;
        for iquad = 1:numquads
            n = n + 1;
            L.pv{n,1} = ['QUAD:IN20:', num2str(IN20QS(iquad)),':BDES'];
            L.CQMQctrl_n(iquad) = n;
        end
        n = n + 1;
        L.pv{n,1} = 'MIRR:IN20:422:MH3_MOTR_H.RBV';
        L.LHact_MH3H_n = n;
         n = n + 1;
        L.pv{n,1} = 'MIRR:IN20:422:MH3_MOTR_V.RBV';
        L.LHact_MH3V_n = n;
         n = n + 1;
        L.pv{n,1} = 'MIRR:IN20:436:MH2_MOTR_H.RBV';
        L.LHact_MH2H_n = n;
         n = n + 1;
        L.pv{n,1} = 'MIRR:IN20:436:MH2_MOTR_V.RBV';
        L.LHact_MH2V_n = n; 
        n = n + 1;
        L.pv{n,1} = 'SIOC:SYS0:ML00:CALC254';
        L.BC1_TMIT_n = n;
        n = n + 1;
        L.pv{n,1} = 'SIOC:SYS0:ML00:CALC252';
        L.LTU_TMIT_n = n; 
        n = n + 1;
        L.pv{n,1} = 'IOC:IN20:BP01:QANN';
        L.BPMatten_n = n;   
        n = n + 1;
        L.pv{n,1} = 'SIOC:SYS0:ML00:AO455';
        L.GuardianTMIT_n = n;



    end

    function pvname = setup_pv(num, text, egu, prec, comment)
        numtxt = num2str(round(num));
        numlen = length(numtxt);
        if numlen == 1
            numstr = ['00', numtxt];
        elseif numlen == 2
            numstr = ['0', numtxt];
        else
            numstr = numtxt;
        end
        pvname = ['SIOC:SYS0:ML03:AO', numstr];
        lcaPut([pvname, '.DESC'], text);
        lcaPut([pvname, '.EGU'], egu);
        lcaPut([pvname, '.PREC'], prec);
        lcaPut(pv_to_comment(pvname), comment);
    end


    function out = pv_to_comment(pv)
    str1 = pv(1:15);
    str2 = 'SO0';
    str3 = pv(18:20);
    out = [str1, str2, str3];
    return;
    end