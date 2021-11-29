function [ stpPlotLimits ] = optimizeSTP( S )
%OPTIMIZESTP Calculate appropriate StripPlot graph limits
%
%   Based on the stored snapshot values for the various
%   parameters saved by the SXRSS Guardian, this calculates
%   the desired limits for the strip charts based on the guardian's
%   trip limits.
%
% 8/31/17 Change BC1 coll tols from rel% to abs.
%
Q = CQ_PV_to_string();
L = generate_pv_list(); %
lcaSetSeverityWarnLevel(5); % disable almost all warnings
d  = lcaGetSmart(L.pv, 16000, 'double'); % get data
%
S.FEL_pulse_energy  = d(L.FEL_pulseE_store_n);
S.bunchq      = d(L.bunchq_setpt_store_n);
S.bunchq_mat  = d(L.bunchq_mat_setpt_store_n);
S.BC1_I       = d(L.BC1_current_setpt_store_n);
S.L1S_p       = d(L.L1S_phase_setpt_store_n);
S.BC2_I       = d(L.BC2_current_setpt_store_n);
S.L2chirp     = d(L.L2_chirp_setpt_store_n);
for iund = 1:8
    stored_undLocationStat(iund)    = d(L.undulators_in_store_n(iund));%#ok<*AGROW>
    stored_undK(iund)               = d(L.undulator_K_store_n(iund));
end
S.und_in      = stored_undLocationStat;
S.und_K       = stored_undK;
S.LH_waveplate      = d(L.LH_waveplate_store_n);
S.LH_delay          = d(L.LH_delay_store_n);
S.LHpower           = d(L.LH_power_store_n);
S.BC1coll_L         = d(L.BC1coll_L_store_n);
S.BC1coll_R         = d(L.BC1coll_R_store_n);
S.SlotFoil          = d(L.SlottedFoil_store_n);
% ALL the match and CQ quads
for iquad = 1:20
    CQMQctrlValue(iquad) = d(L.CQMQctrl_store_n(iquad)); %#ok<*AGROW>
end
S.CQMQctrl          = CQMQctrlValue;
S.CQMQctrltols      = d(L.CQMQctrltols_n);
%
S.BC1tols           = d(L.BC1tols_n);
S.L1Sphasetols      = d(L.L1Sphasetols_n);
S.BC2tols           = d(L.BC2tols_n);
S.bunchQtols        = d(L.bunchQtols_n);
S.L2tols            = d(L.L2chirptols_n);
S.LHpowertols       = d(L.LHpowertols_n);
S.undK_tols         = d(L.undKtols_n);
S.BC1colltols       = d(L.BC1colltols_n);
S.SlotFoiltols      = d(L.SlottedFoiltols_n);
%
M(1).PVname = 'FBCK:FB02:GN01:S1P1';
M(1).lo     = S.bunchq - abs(S.bunchq * S.bunchQtols * 0.01);
M(1).hi     = S.bunchq + abs(S.bunchq * S.bunchQtols * 0.01);
M(2).PVname = 'FBCK:BCI0:1:CHRG_S';
M(2).lo     = S.bunchq_mat - abs(S.bunchq_mat * S.bunchQtols * 0.01);
M(2).hi     = S.bunchq_mat + abs(S.bunchq_mat * S.bunchQtols * 0.01);
M(3).PVname  = 'FBCK:FB04:LG01:S3P1';
M(3).lo      = S.BC1_I - abs(S.BC1_I * S.BC1tols * 0.01);
M(3).hi      = S.BC1_I + abs(S.BC1_I * S.BC1tols * 0.01);
M(4).PVname = 'ACCL:LI21:1:L1S_PDES';
M(4).lo      = S.L1S_p - abs(S.L1S_p * S.L1Sphasetols * 0.01);
M(4).hi      = S.L1S_p + abs(S.L1S_p * S.L1Sphasetols * 0.01);
M(5).PVname  = 'FBCK:FB04:LG01:S5P1';
M(5).lo      = S.BC2_I - abs(S.BC2_I * S.BC2tols * 0.01);
M(5).hi      = S.BC2_I + abs(S.BC2_I * S.BC2tols * 0.01);
M(6).PVname = 'FBCK:FB04:LG01:CHIRPDES';
M(6).lo    = S.L2chirp - abs(S.L2chirp * S.L2tols * 0.01);
M(6).hi    = S.L2chirp + abs(S.L2chirp * S.L2tols * 0.01);
M(7).PVname = 'LASR:IN20:475:PWR';
M(7).lo    = S.LHpower - abs(S.LHpowertols);
M(7).hi    = S.LHpower + abs(S.LHpowertols);
M(8).PVname = 'COLL:LI21:236:LVPOS';
BCtols = S.BC1colltols;
M(8).lo  = S.BC1coll_L - abs(BCtols);
M(8).hi  = S.BC1coll_L + abs(BCtols);
M(9).PVname = 'COLL:LI21:235:LVPOS';
M(9).lo  = S.BC1coll_R - abs(BCtols);
M(9).hi  = S.BC1coll_R + abs(BCtols);
M(10).PVname = 'FOIL:LI24:804:LVPOS';
M(10).lo   = S.SlotFoil - abs(S.SlotFoil * S.SlotFoiltols * 0.01);
M(10).hi   = S.SlotFoil + abs(S.SlotFoil * S.SlotFoiltols * 0.01);
%
for mlim = 1:10
    outputLO.pv{mlim,1} = L.pv{L.Mlim_lo_n(mlim),1};
    outputLO.val(mlim,1) = M(mlim).lo;
end
for mlim2 = 1:10
    outputHI.pv{mlim2,1} = L.pv{L.Mlim_hi_n(mlim2),1};
    outputHI.val(mlim2,1) = M(mlim2).hi;
    lcaPut(pv_to_comment(outputHI.pv{mlim2,1}), M(mlim2).PVname);
end
%
%Undulators
%
for ulim = 1:8
MU.undPVname{ulim,1}  = ['USEG:UND1:' num2str(ulim) '50:KACT'];
end
%%MU.undPVname  = 'USEG:UND1:n50:KACT';
MU.und_K_lo      = (S.und_K - abs(S.und_K * S.undK_tols * 0.01));
MU.und_K_hi      = (S.und_K + abs(S.und_K * S.undK_tols * 0.01));
%
for ulim = 1:8
    outputLO_U.pv{ulim,1} = L.pv{L.UNDlim_lo_n(ulim),1};
    outputLO_U.val(ulim) = MU.und_K_lo(ulim);
    lcaPutSmart(outputLO_U.pv(ulim), outputLO_U.val(ulim));
end
for ulim2 = 1:8
    outputHI_U.pv{ulim2,1} = L.pv{L.UNDlim_hi_n(ulim2),1};
    outputHI_U.val(ulim2) = MU.und_K_hi(ulim2);
    lcaPutSmart(outputHI_U.pv(ulim2), outputHI_U.val(ulim2));
    lcaPut(pv_to_comment(outputHI_U.pv{ulim2,1}), MU.undPVname(ulim2));
    %   outputHIC.comval(mlim,1) = double(int8(M(mlim).PVname));
end
%
%Match and CQs
%
for qlim = 1:20
QM.PVname{qlim,1}  = Q.pv{Q.CQ_n(qlim),1};
end
QM.lo      = (S.CQMQctrl - abs(S.CQMQctrl * S.CQMQctrltols * 0.01));
QM.hi      = (S.CQMQctrl + abs(S.CQMQctrl * S.CQMQctrltols * 0.01));
%
for qlim = 1:20
    outputLO_QM.pv{qlim,1} = L.pv{L.QMlim_lo_n(qlim),1};
    outputLO_QM.val(qlim) = QM.lo(qlim);
    lcaPutSmart(outputLO_QM.pv(qlim), outputLO_QM.val(qlim));
end
for qlim2 = 1:20
    outputHI_QM.pv{qlim2,1} = L.pv{L.QMlim_hi_n(qlim2),1};
    outputHI_QM.val(qlim2) = QM.hi(qlim2);
    lcaPutSmart(outputHI_QM.pv(qlim2), outputHI_QM.val(qlim2));
    lcaPut(pv_to_comment(outputHI_QM.pv{qlim2,1}), QM.PVname(qlim2));
    %convolution to stash the PVname into the matlab PV comment field
end
lcaPutSmart(outputLO.pv, outputLO.val);
lcaPutSmart(outputHI.pv, outputHI.val);


end

function L = generate_pv_list()
n = 0;
% These PVs are got from FELpulseEnergyMonitor.m -- in the interest of
% expedience I just copypastad the L.pv chunk of that code. The setup_pv
% function below has been altered so as not to stomp on the text, egu,
% prec, and comment fields set up in FELpulseEnergyMonitor.m.
%
pvstart = 872; %set up the list of storage slots = matlab PVs in ML01
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'FEL pulse energy from from SXRSS GUI?', '1=yes', 0, 'FELpulseEnergyMonitor.m');
L.BOD_scan_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'FEL pulse energy in use by guardian', 'uJ', 3, 'FELpulseEnergyMonitor.m');
L.FEL_pulseE_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge feedback setpoint', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge feedback state ', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge matlab fbck setpt', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_mat_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'bunch charge matlab fbck state ', 'nC', 3, 'FELpulseEnergyMonitor.m');
L.bunchq_mat_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'BC1 current setpoint', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC1_current_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'BC1 current state', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC1_current_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'L1S phase setpoint', 'deg', 2, 'FELpulseEnergyMonitor.m');
L.L1S_phase_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'BC2 current setpoint', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC2_current_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'BC2 current state', 'amps', 1, 'FELpulseEnergyMonitor.m');
L.BC2_current_state_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'L2 chirp setpoint', 'MeV', 1, 'FELpulseEnergyMonitor.m');
L.L2_chirp_setpt_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Dump bend BDES', 'GeV', 3, 'FELpulseEnergyMonitor.m');
L.dump_bend_bdes_store_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Dump bend BACT', 'GeV', 3, 'FELpulseEnergyMonitor.m');
L.dump_bend_bact_store_n = n;
%Loop over undulator positions
for iund = 1:8
    n = n + 1;
    descStr = ['Undulator ', num2str(iund), ' Position'];
    L.pv{n,1} = setup_pv(pvstart + n  , descStr, '1=OUT', 0, 'FELpulseEnergyMonitor.m');
    L.undulators_in_store_n(iund) = n;
end
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'FEL pulse energy (manual entry)', 'uJ', 3, 'FELpulseEnergyMonitor.m');
L.manual_FELpulseE_n = n;
%
pvstart4 = 960;
n = n + 1;
mm = 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'BC1 left (+) collimator position', 'mm', 3, 'FELpulseEnergyMonitor.m');
L.BC1coll_L_store_n = n;
n = n + 1;
mm = mm + 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'BC1 right (-) collimator position', 'mm', 3, 'FELpulseEnergyMonitor.m');
L.BC1coll_R_store_n = n;
n = n + 1;
mm = mm + 1;
L.pv{n,1} = setup_pv(pvstart4 + mm  , 'LI24 Slotted Foil position', 'mm', 1, 'FELpulseEnergyMonitor.m');
L.SlottedFoil_store_n = n;
%
pvstart2 = 932;
n = n + 1;
m = 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater Waveplate Angle', 'deg', 3, 'FELpulseEnergyMonitor.m');
L.LH_waveplate_store_n = n;
n = n + 1;
m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater Delay', 'ps', 3, 'FELpulseEnergyMonitor.m');
L.LH_delay_store_n = n;
n = n + 1;
m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater Power', 'uJ', 1, 'FELpulseEnergyMonitor.m');
L.LH_power_store_n = n;
% All the damn CQs and Matching quads
pvstart666 = 173;
qq = 1;
for iquad = 1:20
    n = n + 1;
    descStr = ['CQ or Matching Quad ', num2str(iquad), ' BDES value'];
    L.pv{n,1} = setup_pv(pvstart666 + qq  , descStr, 'kG', 4, 'FELpulseEnergyMonitor.m');
    L.CQMQctrl_store_n(iquad) = n;
    qq = qq + 1;
end
n = n + 1;
L.pv{n,1} = setup_pv(pvstart666 + qq  , 'Matching quad/CQ BDES tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.CQMQctrltols_n = n;
%
% control PVs, for tolerances, starting at SIOC:SYS0:ML01:AO936
n = n + 1;
m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'bunch charge feedback tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.bunchQtols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'L1S phase setpoint tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.L1Sphasetols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'BC1 current feedback tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.BC1tols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'BC2 current feedback tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.BC2tols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'L2 chirp tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.L2chirptols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Laser Heater power tolerance', 'uJ', 3, 'FELpulseEnergyMonitor.m');
L.LHpowertols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Undulator K value tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.undKtols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'BC1 collimator jaws position tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.BC1colltols_n = n;
n = n + 1;m = m + 1;
L.pv{n,1} = setup_pv(pvstart2 + m  , 'Slotted Foil position tolerance', '%', 3, 'FELpulseEnergyMonitor.m');
L.SlottedFoiltols_n = n;
% and a new batch for the Undulator K values
pvstart3 = 980;
k = 1;
for iund = 1:8
    n = n + 1;
    descStr = ['Undulator ', num2str(iund), ' K value'];
    L.pv{n,1} = setup_pv(pvstart3 + k  , descStr, 'K', 4, 'FELpulseEnergyMonitor.m');
    L.undulator_K_store_n(iund) = n;
    k = k + 1;
end
%
% and finally, pvs in ML02 to store the ABS limits for the most recent
% parameters saved by FELpulseEnergyMonitor, to be read by STP generator
%
LIMpvstart = 204;p = 0;
%
for ilim = 1:10
    n = n + 1;p = p + 1;
    text = ['low limit for M' num2str(ilim)];
    L.pv{n,1} = setup_LIMpv(LIMpvstart + p , text, 'abs', 4, 'FELpulseEmonitor monitor STP');
    L.Mlim_lo_n(ilim) = n;
end
for ilim2 = 1:10
    n = n + 1;p = p + 1;
    text = ['high limit for M' num2str(ilim2)];
    L.pv{n,1} = setup_LIMpv(LIMpvstart + p , text, 'abs', 4, 'FELpulseEmonitor monitor STP');
    L.Mlim_hi_n(ilim2) = n;
end
for ulim = 1:8
    n = n + 1;p = p + 1;
    text = ['low limit for UND' num2str(ulim)];
    L.pv{n,1} = setup_LIMpv(LIMpvstart + p , text, 'abs', 6, 'FELpulseEmonitor Umonitor STP');
    L.UNDlim_lo_n(ulim) = n;
end
for ulim2 = 1:8
    n = n + 1;p = p + 1;
    text = ['high limit for UND' num2str(ulim2)];
    L.pv{n,1} = setup_LIMpv(LIMpvstart + p , text, 'abs', 6, 'FELpulseEmonitor Umonitor STP');
    L.UNDlim_hi_n(ulim2) = n;
end
% And for the CQs and match quads...
LIMpvstart2 = 351;p = 0;
%
for qlim = 1:20
    n = n + 1;p = p + 1;
    text = ['low limit for QM' num2str(qlim)];
    L.pv{n,1} = setup_LIMpv(LIMpvstart2 + p , text, 'abs', 4, 'FELpulseEmonitor Qmonitor STP');
    L.QMlim_lo_n(qlim) = n;
end
for qlim2 = 1:20
    n = n + 1;p = p + 1;
    text = ['high limit for QM' num2str(qlim2)];
    L.pv{n,1} = setup_LIMpv(LIMpvstart2 + p , text, 'abs', 4, 'FELpulseEmonitor Qmonitor STP');
    L.QMlim_hi_n(qlim2) = n;
end
end
%
% Really convoluted way to list the PVs for the matching quads
function Q = CQ_PV_to_string( )
LI21QS = [201 211 271 278];
LI24QS = [740 860];
LTUQS = [440 460 620 640 660 680];
li21_numQs = length(LI21QS);
li24_numQs = length(LI24QS);
li26_numQs = 8;
ltu_numQs = length(LTUQS);
n=0;
for iq = 1:li21_numQs
  iquad = iq;
  n = n + 1;
  Q.pv{n,1} = ['QUAD:LI21:', num2str(LI21QS(iq)),':BDES'];
  Q.CQ_n(iquad) = n;
end
for iq = 1:li24_numQs
  iquad = li21_numQs + iq;
  n = n + 1;
  Q.pv{n,1} = ['QUAD:LI24:', num2str(LI24QS(iq)),':BDES'];
  Q.CQ_n(iquad) = n;
end
for iq = 1:li26_numQs
  iquad = li21_numQs + li24_numQs + iq;
  n = n + 1;
  Q.pv{n,1} = ['QUAD:LI26:', num2str(iq + 1),'01:BDES'];
  Q.CQ_n(iquad) = n;
end
for iq = 1:ltu_numQs
  iquad = li21_numQs + li24_numQs + li26_numQs + iq;
  n = n + 1;
  Q.pv{n,1} = ['QUAD:LTU1:', num2str(LTUQS(iq)),':BDES'];
  Q.CQ_n(iquad) = n;
end
end
%
function pvname = setup_pv(num, ~, ~, ~, ~)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
    numstr = ['00', numtxt];
elseif numlen == 2
    numstr = ['0', numtxt];
else
    numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML01:AO', numstr];
% don't stomp on details written by FELpulseEnergyMonitor.m
%        lcaPut([pvname, '.DESC'], text);
%        lcaPut([pvname, '.EGU'], egu);
%        lcaPut([pvname, '.PREC'], prec);
%        lcaPut(pv_to_comment(pvname), comment);
end
%
function pvname = setup_LIMpv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
    numstr = ['00', numtxt];
elseif numlen == 2
    numstr = ['0', numtxt];
else
    numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML02:AO', numstr];
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
