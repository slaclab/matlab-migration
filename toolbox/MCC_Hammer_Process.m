function MCC_Hammer_Process()
% MCC_Hammer attempts to mimic the fault-unlatching behavior of operators.
% Unlatches most MPS faults immediately. If too many faults are
% unlatched in rapid succession, retreats to BYKIK and tries to stabilize
% the beam there. Will pause while the Guardian or the BCS is faulted. Will
% not unlatch certain "blacklisted" faults unless the associated signals
% are bypassed.
%
% It is dope on the floor and magic on the mic. It is also fairly janky. I
% make no excuses.
%
% Author: Benjamin Ripman

clear

lcaSetMonitor({'BCS:IN20:1:BEAMPERM'; ...
    'BCS:IN20:1:LSSPERM'; ...
    'BCS:IN20:1:SBIPERM'; ...
    'BCS:IN20:1:TIUPERM'; ...
    'BCS:MCC0:1:SBIPERMIT'; ...
    'BEND:IN20:751:STATE'; ...
    'BEND:IN20:751:STATE_OFF_MPSC'; ...
    'BEND:IN20:751:STATE_OFF_BYPC'; ...
    'BEND:IN20:751:STATE_ON_MPSC'; ...
    'BEND:IN20:751:STATE_ON_BYPC'; ...
    'DUMP:LI21:305:TD11_IN'; ...
    'DUMP:LI21:305:TD11_OUT'; ...
    'DUMP:LTU1:970:TDUND_IN'; ...
    'DUMP:LTU1:970:TDUND_OUT'; ...
    'FLTR:IN20:130:FLT1_STS'; ...
    'IOC:BSY0:MP01:BYKIK_RATE'; ...
    'IOC:BSY0:MP01:BYKIKCTL'; ...
    'IOC:BSY0:MP01:MS_RATE'; ...
    'IOC:BSY0:MP01:MSHUTCTL'; ...
    'IOC:BSY0:MP01:PC_RATE'; ...
    'IOC:BSY0:MP01:PCELLCTL'; ...
    'MPS:UND1:950:SXRSS_MODE'; ...
    'MPS:UND1:1650:HXRSS_MODE'; ...
    'OTRS:IN20:465:IN_LMTSW'; ...
    'OTRS:IN20:465:OUT_LMTSW'; ...
    'OTRS:IN20:471:IN_LMTSW'; ...
    'OTRS:IN20:471:IN_LMTSW_BYPC'; ...
    'OTRS:IN20:471:OUT_LMTSW'; ...
    'OTRS:IN20:471:OUT_LMTSW_BYPC'; ...
    'OTRS:IN20:541:IN_LMTSW'; ...
    'OTRS:IN20:541:OUT_LMTSW'; ...
    'OTRS:IN20:571:IN_LMTSW'; ...
    'OTRS:IN20:571:OUT_LMTSW'; ...
    'OTRS:IN20:621:IN_LMTSW'; ...
    'OTRS:IN20:621:OUT_LMTSW'; ...
    'OTRS:IN20:711:IN_LMTSW'; ...
    'OTRS:IN20:711:OUT_LMTSW'; ...
    'OTRS:LI21:237:IN_LMTSW'; ...
    'OTRS:LI21:237:OUT_LMTSW'; ...
    'OTRS:LI21:291:IN_LMTSW'; ...
    'OTRS:LI21:291:OUT_LMTSW'; ...
    'OTRS:LI24:807:IN_LMTSW'; ...
    'OTRS:LI24:807:OUT_LMTSW'; ...
    'OTRS:LTU1:449:IN_LMTSW'; ...
    'OTRS:LTU1:449:OUT_LMTSW'; ...
    'OTRS:LTU1:745:IN_LMTSW_MPS'; ...
    'OTRS:LTU1:745:OUT_LMTSW_MPS'; ...
    'STPR:BSYH:847:OUT'; ...
    'PPS:FEH1:5:S5BSTPRSUM'; ...
    'PPS:FEH1:5:S5STPRSUM'; ...
    'PPS:NEH1:1:S1STPRSUM'; ...
    'PPS:NEH1:2:S2STPRSUM'; ...
    'PPS:NEH1:3:S2BSTPRSUM'; ...
    'PPS:NEH1:3:SH1STPRSUM'; ...
    'SIOC:SYS0:ML00:AO466'; ...
    'SIOC:SYS0:ML00:AO866'; ...`
    'SIOC:SYS0:ML02:AO005'; ...
    'SIOC:SYS0:ML02:AO006'; ...
    'SIOC:SYS0:ML02:AO007'; ...
    'SIOC:SYS0:ML02:AO008'; ...
    'SIOC:SYS0:ML02:AO009'; ...
    'SIOC:SYS0:ML02:AO010'; ...
    'SIOC:SYS0:ML02:AO011'; ... 
    'SIOC:SYS0:ML02:AO012'; ...
    'SIOC:SYS0:ML02:AO013'; ...
    'SIOC:SYS0:ML02:AO014'; ... 
    'SIOC:SYS0:ML02:AO015'; ...
    'SIOC:SYS0:ML02:AO016'; ...
    'SIOC:SYS0:ML02:AO017'; ...
    'SIOC:SYS0:ML02:AO018'; ...
    'SIOC:SYS0:ML02:AO019'; ...
    'SIOC:SYS0:ML02:AO020'; ...
    'SIOC:SYS0:ML02:AO021'; ...
    'SIOC:SYS0:ML02:AO022'; ...
    'SIOC:SYS0:ML02:SO0009'; ...
    'SIOC:SYS0:ML02:SO0010'; ...
    'SIOC:SYS0:ML02:SO0011'; ...
    'SIOC:SYS0:ML02:SO0012'; ...
    'SIOC:SYS0:ML02:SO0013'; ...
    'SIOC:SYS0:ML02:SO0014'; ...
    'SIOC:SYS0:ML02:SO0015'; ...
    'SIOC:SYS0:ML02:SO0016'; ...
    'SIOC:SYS0:ML02:SO0017'; ...
    'SIOC:SYS0:ML02:SO0018'; ...
    'SIOC:SYS0:ML02:SO0019'; ...
    'SIOC:SYS0:ML02:SO0020'; ...
    'SIOC:SYS0:ML02:SO0021'; ...
    'SIOC:SYS0:ML02:SO0022'; ...
    'STEP:FEE1:1561:ERROR.L'; ...
    'STPR:XRT1:1:SH2_PPSSUM'; ...
    'TORO:B921:198:CHASIMUND_BYPS'; ...
    'TORO:B921:198:CHASIMUND_MPS'; ...
    'TORO:DMP1:198:IMUNDO_L1_BYPS'; ...
    'TORO:DMP1:198:IMUNDO_L2_BYPS'; ...
    'TORO:DMP1:198:IMUNDO_L1_MPS'; ...
    'TORO:DMP1:198:IMUNDO_L2_MPS'; ...
    'TORO:IN20:203:TC203L1_BYPS'; ...
    'TORO:IN20:203:TC203L1_MPS'; ...
    'TORO:IN20:203:TC203L2_BYPS'; ...
    'TORO:IN20:203:TC203L2_MPS'; ...
    'TORO:IN20:215:CHASIM11_BYPS'; ...
    'TORO:IN20:215:CHASIM11_MPS'; ...
    'TORO:IN20:431:CHASIM12_BYPS'; ...
    'TORO:IN20:431:CHASIM12_MPS'; ...
    'TORO:IN20:971:TC2S1L1_BYPS'; ...
    'TORO:IN20:971:TC2S1L1_MPS'; ...
    'TORO:IN20:971:TC2S1L2_BYPS'; ...
    'TORO:IN20:971:TC2S1L2_MPS'; ...
    'TORO:IN20:BL215:MPS_STATE_BYPS'; ...
    'TORO:IN20:BL215:MPS_STATE_MPS'; ...
    'TORO:LI21:205:TCBC1L1_BYPS'; ...
    'TORO:LI21:205:TCBC1L1_MPS'; ...
    'TORO:LI21:205:TCBC1L2_BYPS'; ...
    'TORO:LI21:205:TCBC1L2_MPS'; ...
    'TORO:LI24:1:CHASIMB2_BYPS'; ...
    'TORO:LI24:1:CHASIMB2_MPS'; ...
    'TORO:LI24:707:TCBC2L1_BYPS'; ...
    'TORO:LI24:707:TCBC2L1_MPS'; ...
    'TORO:LI24:707:TCBC2L2_BYPS'; ...
    'TORO:LI24:707:TCBC2L2_MPS'; ...
    'TORO:LTU1:920:IMUNDI_L1_BYPS'; ...
    'TORO:LTU1:920:IMUNDI_L2_BYPS'; ...
    'TORO:LTU1:920:IMUNDI_L1_MPS'; ...
    'TORO:LTU1:920:IMUNDI_L2_MPS'; ...
    'XPP:DET:01:MPSFAULT_BYPS'; ...
    'XPP:DET:01:MPSFAULT_MPS'})

BYKIK_NUMFAULTS = 5;
% Number of times faults must occur in rapid succession before engaging BYKIK;
% decrease to use BYKIK more liberally, increase for opposite effect.

UNLATCH_INTERVAL = 1.5;
% Maximum time interval between unlatches considered to be in rapid succession;
% increase to use BYKIK more liberally, decrease for opposite effect.

RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
% Stores the most recent time intervals between unlatches. Used to decide
% when it's time to apply BYKIK.

N_UNLATCHES = 0;
CYCLE = 0;
START_MSG_NEEDED = 1;
STOP_MSG_NEEDED = 0;

tic

while Killswitch_Okay()
    % Main loop
    pause(0.02);
    CYCLE = CYCLE + 1;
    if mod(CYCLE, 50) == 0
        % Update heartbeat counter
        lcaPutSmart('SIOC:SYS0:ML02:AO005', lcaGetSmart('SIOC:SYS0:ML02:AO005') + 1);
    end
    if Permit_Okay()
        STOP_MSG_NEEDED = 1;
        if START_MSG_NEEDED
            Display(4,1);
            START_MSG_NEEDED = 0;
        end
        if Guardian_Is_Faulted() && Permit_Okay()
            Respond_To_Guardian()
        end
        if BCS_Is_Faulted() && Permit_Okay()
            Respond_To_BCS()
        end
        if MPS_Is_Faulted() && Permit_Okay()
            Respond_To_MPS()
        end
    else
        START_MSG_NEEDED = 1;
        if STOP_MSG_NEEDED
            Display(8,1);
            Display(9,1);
            STOP_MSG_NEEDED = 0;
        end
        % Reset array of intervals to avoid spurious use of BYKIK later on
        RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
    end
end

if STOP_MSG_NEEDED
    Display(8,1);
    Display(9,1);
end
disp('Killswitch thrown, exiting MCC Hammer.');

function killswitch = Killswitch_Okay()
    killswitch = lcaGetSmart('SIOC:SYS0:ML02:AO008');
end

function permit = Permit_Okay()
    permit = lcaGetSmart('SIOC:SYS0:ML00:AO866');
end

function g_faulted = Guardian_Is_Faulted()
    g_faulted = lcaGetSmart('SIOC:SYS0:ML00:AO466');
end

function b_faulted = BCS_Is_Faulted()
    b_faulted = strcmpi(lcaGetSmart('BCS:IN20:1:BEAMPERM'), 'FAULT') || ...
        strcmpi(lcaGetSmart('BCS:IN20:1:SBIPERM'), 'FAULT') || ...
        strcmpi(lcaGetSmart('BCS:MCC0:1:SBIPERMIT'), 'FAULT') || ...
        strcmpi(lcaGetSmart('BCS:IN20:1:TIUPERM'), 'FAULT') || ...
        strcmpi(lcaGetSmart('BCS:IN20:1:LSSPERM'), 'FAULT');
end

function m_faulted = MPS_Is_Faulted()
    m_faulted = (strcmpi(lcaGetSmart('IOC:BSY0:MP01:PC_RATE'), '0 Hz') && ...
        strcmpi(lcaGetSmart('IOC:BSY0:MP01:PCELLCTL'), 'Yes')) || ...
        (strcmpi(lcaGetSmart('IOC:BSY0:MP01:MS_RATE'), '0 Hz') && ...
        strcmpi(lcaGetSmart('IOC:BSY0:MP01:MSHUTCTL'), 'Yes')) || ...
        (strcmpi(lcaGetSmart('IOC:BSY0:MP01:BYKIK_RATE'), '0 Hz') && ...
        strcmpi(lcaGetSmart('IOC:BSY0:MP01:BYKIKCTL'), 'Yes'));
end

function mps_unlatch = MPS_Unlatch_Okay()
% Returns 1 if we are in a configuration where we can safely unlatch MPS faults.
% Returns 0 if Guardian or BCS is currently faulted.
% Returns 0 if any stoppers or OTR screens are in motion.
% Returns 0 if there's a toroid fault, which we shouldn't unlatch willy-nilly.
% Returns 0 if any of the hutches are in a configuration where we shouldn't unlatch faults.

% Check for blacklisted faults. Doing this here ensures the error
% messages don't get bypassed by logical short-circuiting.
stoppers_good = Stoppers_Okay();
OTRs_good = OTRs_Okay();
toroids_good = Toroids_Okay();
undulator_good = Undulator_Okay();
AMO_good = AMO_Okay();
SXR_good = SXR_Okay();
XPP_good = XPP_Okay();
XCS_good = XCS_Okay();
CXI_good = CXI_Okay();
MEC_good = MEC_Okay();

if (~stoppers_good)
    Display(16,1);
    disp('Blacklisted MPS fault detected -- stoppers.');
end

if (~OTRs_good)
    Display(17,1);
    disp('Blacklisted MPS fault detected -- OTR screens.');
end

if (~toroids_good)
    Display(18,1);
    disp('Blacklisted MPS fault detected -- toroids.');
end

if (~undulator_good)
    Display(19,1);
    disp('Cannot unlatch faults while SXRSS or HXRSS not in SASE mode.');
end

if (~AMO_good)
    Display(20,1);
    disp('Blacklisted MPS fault detected -- AMO.');
end

if (~SXR_good)
    Display(21,1);
    disp('Blacklisted MPS fault detected -- SXR.');
end

if (~XPP_good)
    Display(22,1);
    disp('Blacklisted MPS fault detected -- XPP.');
end

if (~XCS_good)
    Display(23,1);
    disp('Blacklisted MPS fault detected -- XCS.');
end

if (~CXI_good)
    Display(24,1);
    disp('Blacklisted MPS fault detected -- CXI.');
end

if (~MEC_good)
    Display(25,1);
    disp('Blacklisted MPS fault detected -- MEC.');
end

mps_unlatch = ~Guardian_Is_Faulted() && ~BCS_Is_Faulted() && ...
    stoppers_good && OTRs_good && toroids_good && undulator_good && ...
    AMO_good && SXR_good && XPP_good && ...
    XCS_good && CXI_good && MEC_good;

end

function stoppers_unlatch_okay = Stoppers_Okay()
% Returns 1 if stoppers / bends are in a configuration where we can safely unlatch MPS faults.
% Returns 1 if TD11 and TDUND are not moving and no bends are broken.
% Returns 0 if TD11 or TDUND is moving or there are bends reporting broken
% status.

stoppers_unlatch_okay =  ~strcmpi(lcaGetSmart('DUMP:LI21:305:TD11_OUT'), lcaGetSmart('DUMP:LI21:305:TD11_IN')) && ...
    ~strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_OUT'), lcaGetSmart('DUMP:LTU1:970:TDUND_IN')) && ...
    ((lcaGetSmart('BEND:IN20:751:STATE_ON_MPSC', 0, 'float') ~= lcaGetSmart('BEND:IN20:751:STATE_OFF_MPSC', 0, 'float')) || ...
    (lcaGetSmart('BEND:IN20:751:STATE_ON_BYPC') && lcaGetSmart('BEND:IN20:751:STATE_OFF_BYPC')));

end

function otrs_unlatch_okay = OTRs_Okay()
% Returns 1 if OTR screens are in a configuration where we can safely unlatch MPS faults.
% Returns 1 if no OTR screens are moving and OTRH1/H2 are not in
% with the LH attenuator out or TDUND out.
% Returns 0 if any OTR screens are moving or if OTRH1/H2 are in
% with the LH attenuator out or TDUND out.

otrs_unlatch_okay = ~strcmpi(lcaGetSmart('OTRS:LI21:237:OUT_LMTSW'), lcaGetSmart('OTRS:LI21:237:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:LI21:291:OUT_LMTSW'), lcaGetSmart('OTRS:LI21:291:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:IN20:541:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:541:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:IN20:571:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:571:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:IN20:621:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:621:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:IN20:711:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:711:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:LI24:807:OUT_LMTSW'), lcaGetSmart('OTRS:LI24:807:IN_LMTSW')) && ...
    ~strcmpi(lcaGetSmart('OTRS:LTU1:745:OUT_LMTSW_MPS'), lcaGetSmart('OTRS:LTU1:745:IN_LMTSW_MPS')) && ...
    ~strcmpi(lcaGetSmart('OTRS:IN20:465:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:465:IN_LMTSW')) && ...
    (strcmpi(lcaGetSmart('OTRS:IN20:465:OUT_LMTSW'), 'Active') || (strcmpi(lcaGetSmart('FLTR:IN20:130:FLT1_STS'), 'IN')) && ...
    (strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_IN'), 'Active'))) && ...
    ~strcmpi(lcaGetSmart('OTRS:IN20:471:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:471:IN_LMTSW')) && ...
    (strcmpi(lcaGetSmart('OTRS:IN20:471:OUT_LMTSW'), 'Active') || (strcmpi(lcaGetSmart('FLTR:IN20:130:FLT1_STS'), 'IN')) && ...
    (strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_IN'), 'Active')));
%~strcmpi(lcaGetSmart('OTRS:LTU1:449:OUT_LMTSW'),lcaGetSmart('OTRS:LTU1:449:IN_LMTSW')) && ...%Temporarily removed 3/21/2018

end

function toroids_unlatch_okay = Toroids_Okay()
% Returns 1 if toroids are not faulted (or are faulted & bypassed).

toroids_unlatch_okay = (strcmpi(lcaGetSmart('TORO:IN20:215:CHASIM11_MPS'), 'OK') || strcmpi(lcaGetSmart('TORO:IN20:215:CHASIM11_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:IN20:431:CHASIM12_MPS'), 'OK') || strcmpi(lcaGetSmart('TORO:IN20:431:CHASIM12_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:LI24:1:CHASIMB2_MPS'), 'OK') || strcmpi(lcaGetSmart('TORO:LI24:1:CHASIMB2_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:LTU1:920:IMUNDI_L1_MPS'), 'LEVEL1') || strcmpi(lcaGetSmart('TORO:LTU1:920:IMUNDI_L1_BYPS'), 'Bypassed') || ...
    strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_PNEU'), 'IN')) && ...
    (strcmpi(lcaGetSmart('TORO:LTU1:920:IMUNDI_L2_MPS'), 'LEVEL2') || strcmpi(lcaGetSmart('TORO:LTU1:920:IMUNDI_L2_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:DMP1:198:IMUNDO_L1_MPS'), 'LEVEL1') || strcmpi(lcaGetSmart('TORO:DMP1:198:IMUNDO_L1_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:DMP1:198:IMUNDO_L2_MPS'), 'LEVEL2') || strcmpi(lcaGetSmart('TORO:DMP1:198:IMUNDO_L2_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:IN20:203:TC203L1_MPS'), 'LEVEL_1') || strcmpi(lcaGetSmart('TORO:IN20:203:TC203L1_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:IN20:203:TC203L2_MPS'), 'LEVEL_2') || strcmpi(lcaGetSmart('TORO:IN20:203:TC203L2_BYPS'), 'Bypassed')) && ...
    (((strcmpi(lcaGetSmart('TORO:IN20:971:TC2S1L1_MPS'), 'LEVEL_1') || strcmpi(lcaGetSmart('TORO:IN20:971:TC2S1L1_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:IN20:971:TC2S1L2_MPS'), 'LEVEL_2') || strcmpi(lcaGetSmart('TORO:IN20:971:TC2S1L2_BYPS'), 'Bypassed'))) || ...
    strcmpi(lcaGetSmart('BEND:IN20:751:STATE'), 'ON')) && ...
    (strcmpi(lcaGetSmart('TORO:LI21:205:TCBC1L1_MPS'), 'LEVEL_1') || strcmpi(lcaGetSmart('TORO:LI21:205:TCBC1L1_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:LI21:205:TCBC1L2_MPS'), 'LEVEL_2') || strcmpi(lcaGetSmart('TORO:LI21:205:TCBC1L2_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:LI24:707:TCBC2L1_MPS'), 'OK') || strcmpi(lcaGetSmart('TORO:LI24:707:TCBC2L1_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:LI24:707:TCBC2L2_MPS'), 'OK') || strcmpi(lcaGetSmart('TORO:LI24:707:TCBC2L2_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:B921:198:CHASIMUND_MPS'), 'IS_ON') || strcmpi(lcaGetSmart('TORO:B921:198:CHASIMUND_BYPS'), 'Bypassed')) && ...
    (strcmpi(lcaGetSmart('TORO:IN20:BL215:MPS_STATE_MPS'), 'OUT') || strcmpi(lcaGetSmart('TORO:IN20:BL215:MPS_STATE_BYPS'), 'Bypassed'));

end

function undulator_unlatch_okay = Undulator_Okay()
% Returns 1 if the Undulator Hall is in a configuration where we can safely unlatch MPS faults.
% For the time being, this has been defined as the HXRSS and SXRSS both being in
% SASE mode.

undulator_unlatch_okay = strcmpi(lcaGetSmart('MPS:UND1:950:SXRSS_MODE'), 'SASE Mode') && ... % The SXRSS is in SASE mode AND
    (strcmpi(lcaGetSmart('MPS:UND1:1650:HXRSS_MODE'), 'SASE Mode') || ...
    (strcmpi(lcaGetSmart('MPS:UND1:1650:HXRSS_MODE'), 'Phase Shift Mode'))); % The HXRSS is in SASE mode or Phase Shifter mode.

end

function amo_unlatch_okay = AMO_Okay()
% Returns 1 if AMO is in a configuration where we can safely unlatch MPS faults.
% Returns 1 if we're on the hard x-ray line or if shutter S1 is not moving.

amo_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') < -3000 || ... % We're on the hard x-ray line OR
    ~strcmpi(lcaGetSmart('PPS:NEH1:1:S1STPRSUM'),'INCONSISTENT'); % Shutter S1 is not moving.

end

function sxr_unlatch_okay = SXR_Okay()
% Returns 1 if SXR is in a configuration where we can safely unlatch MPS faults.
% Returns 1 if we're on the hard x-ray line or S2 is IN or (OUT and
% S2B is not moving). Returns 0 otherwise.

sxr_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') < -3000 || ... % We're on the hard x-ray line OR
    strcmpi(lcaGetSmart('PPS:NEH1:2:S2STPRSUM'),'IN') || ... Shutter S2 is IN OR
    (strcmpi(lcaGetSmart('PPS:NEH1:2:S2STPRSUM'),'OUT') && ... Shutter S2 is OUT AND
    ~strcmpi(lcaGetSmart('PPS:NEH1:3:S2BSTPRSUM'),'INCONSISTENT')); % Shutter S2B is not moving.

end

function xpp_unlatch_okay = XPP_Okay()
% Returns 1 if XPP is in a configuration where we can safely unlatch MPS faults.
% Returns 1 if we're on the soft x-ray line or SH1 is IN or (SH1 is
% OUT and there are no un-bypassed PAD detector damage faults).
% Returns 0 otherwise.

% Detector damage faults apparently no longer a thing as of 2/4/16
% xpp_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
%     strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... % Shutter SH1 is IN OR
%     (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... % Shutter SH1 is OUT AND
%     (strcmpi(lcaGetSmart('XPP:DET:01:MPSFAULT_MPS'),'IS_OK') || ... % No un-bypassed detector damage faults
%     strcmpi(lcaGetSmart('XPP:DET:01:MPSFAULT_BYPS'), 'BYPASSED')));

xpp_unlatch_okay = 1;

end

function xcs_unlatch_okay = XCS_Okay()
% Returns 1 if XCS is in a configuration where we can safely unlatch MPS faults.
% Returns 1 if we're on the soft x-ray line or SH1 is IN or (SH1 is
% OUT and SH2 is IN or (SH2 is OUT and S4 is not moving)). Returns
% 0 otherwise.

xcs_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
    strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... % Shutter SH1 is IN OR
    (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... % Shutter SH1 is OUT AND
    (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'IN') || ... % Shutter SH2 is IN OR
    (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'OUT') && ... % SH2 is OUT AND
    ~strcmpi(lcaGetSmart('PPS:FEH1:4:S4STPRSUM'),'INCONSISTENT')))); % Shutter S4 is not moving.

end

function cxi_unlatch_okay = CXI_Okay()
% Returns 1 if CXI is in a configuration where we can safely unlatch MPS faults.
% Returns 1 if we're on the soft x-ray line or SH1 is IN or (OUT and SH2 is IN
% or (OUT and S5 is IN or (OUT and S5B is IN or (OUT and there are no un-bypassed
% MPS faults in the hutch)))). Returns 0 otherwise. There are currently no
% blacklisted CXI MPS faults.

cxi_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
    strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... Shutter SH1 is IN OR
    (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... Shutter SH1 is OUT AND
    (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'IN') || ... % Shutter SH2 is IN OR
    (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'OUT') && ... % Shutter SH2 is OUT AND
    (strcmpi(lcaGetSmart('PPS:FEH1:5:S5STPRSUM'),'IN') || ... % Shutter S5 is IN OR
    (strcmpi(lcaGetSmart('PPS:FEH1:5:S5STPRSUM'),'OUT') && ... % Shutter S5 is OUT AND
    (strcmpi(lcaGetSmart('PPS:FEH1:5:S5BSTPRSUM'),'IN') || ... % Shutter S5B is IN OR
    (strcmpi(lcaGetSmart('PPS:FEH1:5:S5BSTPRSUM'),'OUT') ... % Shutter S5B is OUT
    )))))));

end

function mec_unlatch_okay = MEC_Okay()
% Returns 1 if MEC is in a configuration where we can safely unlatch MPS faults.
% Returns 1 if we're on the soft x-ray line or SH1 is IN or (SH1 is
% OUT and SH2 is IN or (SH2 is OUT and S6 is not moving)). Returns
% 0 otherwise.

mec_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
    strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... % Shutter SH1 is IN OR
    (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... % Shutter SH1 is OUT AND
    (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'IN') || ... % Shutter SH2 is IN OR
    (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'OUT') && ... % SH2 is OUT AND
    ~strcmpi(lcaGetSmart('PPS:FEH1:6:S6STPRSUM'),'INCONSISTENT')))); % Shutter S6 is not moving.

end

function faultedVVS = VVS_Faulted()
% Returns an array with the names of LCLS VVSs w/open breakers.
% Returns an empty array if all VVS breakers are closed.
% Not currently used in MCC_Hammer.

faultedVVS = {};
numfaulted = 0;
statuses = { ...
    char(lcaGetSmart('VVS:LI20:1:BREAKER_MPSC')) 'VVS 10'; ...
    char(lcaGetSmart('VVS:LI22:1:BREAKER_MPSC')) 'VVS 11'; ...
    char(lcaGetSmart('VVS:LI24:1:BREAKER_MPSC')) 'VVS 12'; ...
    char(lcaGetSmart('VVS:LI26:1:BREAKER_MPSC')) 'VVS 13'; ...
    char(lcaGetSmart('VVS:LI28:1:BREAKER_MPSC')) 'VVS 14'; ...
    char(lcaGetSmart('VVS:LI30:1:BREAKER_MPSC')) 'VVS 15'; ...
    };
% Add faulted VVSs to the faultedVVS array
i = 1;
while i < 7 && Permit_Okay()
    if ~any(strcmp(statuses(i,1), {'READY' 'OK'}))
        numfaulted = numfaulted + 1;
        faultedVVS(numfaulted,1) = statuses(i,2);
    end
    i = i + 1;
end

end

function faultedKLYS = KLYS_Faulted()
% Returns an array with the names of LCLS klystrons currently on
% the beam w/mod faults. Returns an empty array if no klystrons
% on the beam are mod faulted.
% Update: This function is now taking 15.3 seconds to execute. Why?
% The line with [act, ...] is responsible for 15.1 secs of delay.
% Not currently used in MCC_Hammer.

faultedKLYS = {};
numfaulted = 0;

% Get current complement and associated statuses. Note - doesn't
% get L0 and L1 properly yet. Henrik knows why, ask him when I'm
% ready to fix this.
names = model_nameConvert(model_nameRegion({'GUN' 'ACCL' 'KLYS'}, {'L0' 'L1' 'L2' 'L3'}), 'MAD');
[act, stat, swrd, hdsc, dsta, enld] = control_klysStatGet(names);

% Find stations that are on the beam (act bit 1 = true) and have
% mod faults (swrd bit 4 = true)
badstations = (bitget(act, 1) .* bitget(swrd,4));

% Add faulted stations to the faultedKLYS array
numstations = size(names);
i = 1;
while i <= numstations(1,1) && Permit_Okay()
    if badstations(i,1)
        numfaulted = numfaulted + 1;
        faultedKLYS(numfaulted,1) = names(i,1);
    end
    i = i + 1;
end

end

function Display(messages, append)
% Updates the PVs that store messages codes & timestamps. HammerGUI parses
% the codes into verbiage, but I've included a cheat sheet here for
% convenience's sake. 
%
% ----------- Cheat Sheet -----------
%
% 1 = no message
% 2 = 'Every time you see me, that Hammer''s just so hype'
% 3 = 'I''m dope on the floor and I''m magic on the mic.'
% 4 = 'Yo, let me bust the funky lyrics!'
% 5 = 'You can''t touch this'
% 6 = 'STOP!'
% 7 = 'Hammer time!'
% 8 = 'Now why would I ever stop doing this'
% 9 = 'With others making records that just don''t hit?'
% 10 = '***************** GUARDIAN FAULT *****************'
% 11 = '******************** BCS FAULT ********************'
% 12 = 'Yo, sound the bell - school is in, suckah!'
% 13 = 'Beam won''t run to BYKIK - stopping MCC_Hammer!'
% 14 = 'Beam won''t run to dump - stopping MCC_Hammer!'
% 15 = 'Something went wrong. Please email bripman.'
% 16 = 'Blacklisted MPS fault detected -- stoppers.'
% 17 = 'Blacklisted MPS fault detected -- OTR screens.'
% 18 = 'Blacklisted MPS fault detected -- toroids.'
% 19 = 'Blacklisted MPS fault detected -- AMO.'
% 20 = 'Blacklisted MPS fault detected -- SXR.'
% 21 = 'Blacklisted MPS fault detected -- XPP.'
% 22 = 'Blacklisted MPS fault detected -- XCS.'
% 23 = 'Blacklisted MPS fault detected -- CXI.'
% 24 = 'Blacklisted MPS fault detected -- MEC.'

message_PVs = ({'SIOC:SYS0:ML02:AO009'; ...
    'SIOC:SYS0:ML02:AO010'; ...
    'SIOC:SYS0:ML02:AO011'; ...
    'SIOC:SYS0:ML02:AO012'; ...
    'SIOC:SYS0:ML02:AO013'; ...
    'SIOC:SYS0:ML02:AO014'; ...
    'SIOC:SYS0:ML02:AO015'; ...
    'SIOC:SYS0:ML02:AO016'; ...
    'SIOC:SYS0:ML02:AO017'; ...
    'SIOC:SYS0:ML02:AO018'; ...
    'SIOC:SYS0:ML02:AO019'; ...
    'SIOC:SYS0:ML02:AO020'; ...
    'SIOC:SYS0:ML02:AO021'; ...
    'SIOC:SYS0:ML02:AO022'});

timestamp_PVs = ({'SIOC:SYS0:ML02:SO0009'; ...
    'SIOC:SYS0:ML02:SO0010'; ...
    'SIOC:SYS0:ML02:SO0011'; ...
    'SIOC:SYS0:ML02:SO0012'; ...
    'SIOC:SYS0:ML02:SO0013'; ...
    'SIOC:SYS0:ML02:SO0014'; ...
    'SIOC:SYS0:ML02:SO0015'; ...
    'SIOC:SYS0:ML02:SO0016'; ...
    'SIOC:SYS0:ML02:SO0017'; ...
    'SIOC:SYS0:ML02:SO0018'; ...
    'SIOC:SYS0:ML02:SO0019'; ...
    'SIOC:SYS0:ML02:SO0020'; ...
    'SIOC:SYS0:ML02:SO0021'; ...
    'SIOC:SYS0:ML02:SO0022'});

if ~append
   % Wipe the slate clean before we do anything else
   lcaPutSmart(message_PVs, 1);
   lcaPutSmart(timestamp_PVs, ' ');
end
i = 1;
while i <= length(messages)
    current_messages = lcaGetSmart(message_PVs);
    current_timestamps = lcaGetSmart(timestamp_PVs);
    if min(current_messages) == 1
        % Message buffer not yet full since there is at least one empty
        % message slot; append the new message at the bottom.
        
        % Find the position of the first empty slot
        empty_slot = 1;
        j = length(current_messages);
        while j > 0
            if current_messages(j) == 1
                empty_slot = j;
            end
            j = j - 1;
        end
        % Put the new message & timestamp in the first empty slot
        lcaPutSmart(message_PVs(empty_slot), messages(i));
        lcaPutSmart(timestamp_PVs(empty_slot), datestr(clock, 13));
    else
        % Message buffer is full, need to bump messages up before appending
        % this message to the bottom
        
        % Bump every message / timestamp up by one slot
        j = 1;
        while j < length(current_messages)
            lcaPutSmart(message_PVs(j), lcaGetSmart(message_PVs(j+1)));
            lcaPutSmart(timestamp_PVs(j), lcaGetSmart(timestamp_PVs(j+1)));
            j = j + 1;
        end
        % Put the new message & timestamp in the bottom slot
        lcaPutSmart(message_PVs(length(message_PVs)), messages(i));
        lcaPutSmart(timestamp_PVs(length(timestamp_PVs)), datestr(clock, 13));
    end
    i = i + 1;
end

end

function Respond_To_Guardian()
% Warns the user of the Guardian fault and waits for it to clear.
% Stops immediately if any of the permits disappear.

Display(10,1);
while Guardian_Is_Faulted() && Permit_Okay()
    pause(0.02);
    CYCLE = CYCLE + 1;
    if mod(CYCLE, 50) == 0
        % Update heartbeat counter
        lcaPutSmart('SIOC:SYS0:ML02:AO005', lcaGetSmart('SIOC:SYS0:ML02:AO005') + 1);
    end
end
Display(12,1);

end

function Respond_To_BCS()
% Warns the user of the BCS fault and waits for it to clear.
% Stops immediately if any of the permits disappear.

Display(11,1)
while BCS_Is_Faulted() && Permit_Okay()
    pause(0.02);
    CYCLE = CYCLE + 1;
    if mod(CYCLE, 50) == 0
        % Update heartbeat counter
        lcaPutSmart('SIOC:SYS0:ML02:AO005', lcaGetSmart('SIOC:SYS0:ML02:AO005') + 1);
    end
end
Display(12,1);

end

function Respond_To_MPS()

if MPS_Unlatch_Okay()
    % First step - save the time interval since the last unlatch
    RECENT_INTERVALS(mod(N_UNLATCHES,BYKIK_NUMFAULTS-1)+1)= toc;
    if (max(RECENT_INTERVALS) < UNLATCH_INTERVAL)
        % We've unlatched too many faults in the recent past.
        if strcmpi(lcaGetSmart('IOC:BSY0:MP01:BYKIKCTL'), 'NO') || ...
                strcmpi(lcaGetSmart('IOC:BSY0:MP01:PCELLCTL'), 'NO') || ...
                strcmpi(lcaGetSmart('IOC:BSY0:MP01:MSHUTCTL'), 'NO') || ...
                strcmpi(lcaGetSmart('DUMP:LI21:305:TD11_PNEU'), 'IN') || ...
                strcmpi(lcaGetSmart('STPR:BSYH:847:OUT'), 'NOT_OUT')
            % If BYKIK is already on or an upstream stopper is in, we
            % shouldn't mess around with BYKIK.
            if ~lcaGetSmart('SIOC:SYS0:ML02:AO006')
                % If the NeverGiveUp box is not checked on the Hammer GUI,
                % we're out of options - warn the user and stop automation.
                % Reset the array of intervals
                RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
                Display(13,1);
                lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
                return
            else
                % If the NeverGiveUp box is checked, unlatch the fault.
                Unlatch()
                return
            end
        else
            % If BYKIK is not on, apply it for three seconds to give
            % feedbacks time to converge.
            % Reset the array of intervals
            RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
            % Apply BYKIK
            lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',0);
            Unlatch()
            Display(6,1)
            WatchAndWait(0.5,1);
            result = WatchAndWait(2.5,0);
            lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',1);
            Display(7,1)
            switch result
                case 0
                    % Ran smoothly, proceed to recovery.
                case 1
                    % Guardian fault, return to main
                    return
                case 2
                    % BCS fault, return to main
                    return
                case 3
                    % MPS fault.
                    if ~lcaGetSmart('SIOC:SYS0:ML02:AO006')
                        % NeverGiveUp box not checked - warn user, halt automation.
                        Display(13,1);
                        lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
                        return
                    else
                        % NeverGiveUp box checked - return to main,
                        % will continue to unlatch.
                        return
                    end
                case 4
                    % Lost permit, return to main
                    return
                otherwise
                    % Error state.
                    Display(15,1);
                    return
            end
            % Now check whether anything trips after going down to
            % the dump again.
            WatchAndWait(0.5,1);
            result = WatchAndWait(1.5,0);
            switch result
                case 0
                    % Ran smoothly.
                case 1
                    % Guardian fault, return to main
                    return
                case 2
                    % BCS fault, return to main
                    return
                case 3
                    % MPS fault.
                    if ~lcaGetSmart('SIOC:SYS0:ML02:AO006')
                        % NeverGiveUp box not checked - warn user, halt automation.
                        Display(14,1);
                        lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
                        return
                    else
                        % Just return to main (will continue to
                        % unlatch)
                        return
                    end
                case 4
                    % Lost permit, return to main
                    return
                otherwise
                    % Error state.
                    Display(15,1);
                    return
            end
        end
    else
        % Haven't unlatched too many times recently, so just unlatch the fault.
        Unlatch()
    end
end

end

function Unlatch()
% Stores time since last unlatch, unlatches current MPS fault,
% updates a PV that tracks number of MPS events. Waits 0.5 seconds
% before returning to the automation loop to allow the mechanical
% shutter time in which to come out.

% Save the time interval since last unlatch. Overwrites previous value
% if Unlatch() is called from Respond_To_MPS(); this is intentional.
RECENT_INTERVALS(mod(N_UNLATCHES,BYKIK_NUMFAULTS-1)+1) = toc;
lcaPutSmart('IOC:BSY0:MP01:UNLATCHALL',1);
if (RECENT_INTERVALS(mod(N_UNLATCHES,BYKIK_NUMFAULTS-1)+1) > 5)
    % Increments a counter whenever a distinct MPS event occurs, defined as
    % a trip with no unlatches in the last 5 seconds.
    lcaPutSmart('SIOC:SYS0:ML02:AO007', lcaGetSmart('SIOC:SYS0:ML02:AO007') + 1);
end
N_UNLATCHES = N_UNLATCHES + 1;
Display(5,1);
tic
WatchAndWait(0.5, 1);
end

function result = WatchAndWait(period, ignoreMPS)
% Waits for [period] seconds, watching for various issues
% (and checking that the permits still exist).
%
% If [ignoreMPS] = 0, WatchAndWait will halt immediately if the MPS trips
% If [ignoreMPS] ~= 0, WatchAndWait will not halt if the MPS trips
%
% Returns [result] = 0 if the beam stays on for [period]
% seconds with no faults of any kind.
% Returns [result] = 1 immediately if there's a Guardian fault.
% Returns [result] = 2 immediately if there's a BCS fault.
% Returns [result] = 3 immediately if there's an MPS fault & ignoreMPS = 0.
% Returns [result] = 4 immediately if the permit is taken away
% during the waiting period.

result = 0;
for i=1:(50*period)
    pause(0.02);
    if ~Permit_Okay()
        result = 4;
        return
    end
    if Guardian_Is_Faulted()
        result = 1;
        return
    end
    if BCS_Is_Faulted()
        result = 2;
        return
    end
    if MPS_Is_Faulted() && ~ignoreMPS
        result = 3;
        return
    end
end

end

end