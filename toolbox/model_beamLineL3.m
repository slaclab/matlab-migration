function beamLine = model_beamLineL3()
%MODEL_BEAMLINEL3
% BEAMLINE = MODEL_BEAMLINEL3() Returns beam line description list for L3.
%
% Input arguments: none
%
% Output arguments:
%    BEAMLINE: Cell array of beam line information for L3

% Compatibility: Version 7 and higher
% Called functions: none
% --------------------------------------------------------------------
% Author: Henrik Loos, SLAC
% History:
%   25-Apr-2017, M. Woodley
%    * remove OTR22
%    * correct position of WS28744
%    * change name: C30096 -> C29956
%    * swap positions of XC30900 and YC30900 per visual inspection
%   25-Jan-2017, M. Woodley (OPTICS=LCLS27JAN17)
%    * make wire scanner locations in LI27 and LI27 consistent
%    * LI30 rematch to reconfigured BSY
%   11-Aug-2016, M. Woodley (OPTICS=LCLS11AUG16)

% --------------------------------------------------------------------

global modelUseNewBSY
if isempty(modelUseNewBSY), modelUseNewBSY=0;end

  GeV2MeV =1000.0;   %GeV to MeV
  EBC2   = 4.300;    %BC2 energy (GeV)
  Ef     = 13.640;   %final beam energy (GeV)
  TWOPI  = 2*pi;

% global LCAV parameters

  SbandF = 2856.0;    %rf frequency (MHz)
  DLWL10 = 3.0441;    %"10  ft" (29 Sband wavelengths; 87 DLWG cavities)
  DLWL9  = 2.8692;    %"9.41 ft" (27 1/3 Sband wavelengths; 82 DLWG cavities)
  DLWL7  = 2.1694;    %"7   ft" (20 2/3 Sband wavelengths; 62 DLWG cavities)
  P25    = 1;         %25% power factor
  P50    = sqrt(2);   %50% power factor

% L3 energy profile

  L3phase = 0.0;               %L3 rf phase (deg)
  dEL3    = GeV2MeV*(Ef-EBC2); %total L3 energy gain (MeV)
  PhiL3   = L3phase/360;       %radians/2pi
  gfac3   = 161*P25*DLWL10 + 12*P50*DLWL10 + 3*P25*DLWL9 + 4*P25*DLWL7;
  gradL3  = dEL3/(gfac3*cos(PhiL3*TWOPI));

% transverse deflecting cavities

 % TCAV0 ={'dr' '' 0.6680236/2  % flange-to-flange (then split in two)
 % TCAV3 ={'dr' '' 2.438/2
  TCAV3 ={'tc' 'TCAV3' 2.438/2 [2856.0 0 90*pi/2 pi/2]}';
  LKIK    = 1.0601;              % kicker coil length per magnet (m) [41.737 in from SA-380-330-02, rev. 0]
  BXKIKA  ={'be' 'BXKIK' LKIK/2 [1E-12 25.4E-3 0     0 0.5 0 0]}';
  BXKIKB  ={'be' 'BXKIK' LKIK/2 [1E-12 25.4E-3 0 2E-12 0 0.5 0]}';

 %OTR22    ={'mo' 'OTR22'    0 []}';    %post-BC2 beam size ... moved to XLEAP
  OTR_TCAV ={'mo' 'OTR_TCAV' 0 []}';    %LI25 longitudinal diagnostics

  WS27644  ={'mo' 'WS27644' 0 []}'; %LI27 emittance (existing; moved)
  WS28144  ={'mo' 'WS28144' 0 []}'; %LI28 emittance
  WS28444  ={'mo' 'WS28444' 0 []}'; %LI28 emittance
  WS28744  ={'mo' 'WS28744' 0 []}'; %LI28 emittance (existing; moved)

  L3beg   ={'mo' '' 0 []}';
  LI25beg ={'mo' '' 0 []}';
  LI25end ={'mo' '' 0 []}';
  LI26beg ={'mo' '' 0 []}';
  LI26end ={'mo' '' 0 []}';
  LI27beg ={'mo' '' 0 []}';
  LI27end ={'mo' '' 0 []}';
  LI28beg ={'mo' '' 0 []}';
  LI28end ={'mo' '' 0 []}';
  LI29beg ={'mo' '' 0 []}';
  LI29end ={'mo' '' 0 []}';
  LI30beg ={'mo' '' 0 []}';
  LI30end ={'mo' '' 0 []}';
  L3end   ={'mo' '' 0 []}';

  ZLIN09  ={'mo' 'ZLIN09' 0 []}';  % start of LI25                : Z=2438.400000
  ZLIN10  ={'mo' 'ZLIN10' 0 []}';  % start of LI26                : Z=2540.000000
  ZLIN11  ={'mo' 'ZLIN11' 0 []}';  % start of LI27                : Z=2641.600000
  ZLIN12  ={'mo' 'ZLIN12' 0 []}';  % start of LI28                : Z=2743.200000
  ZLIN13  ={'mo' 'ZLIN13' 0 []}';  % start of LI29                : Z=2844.800000
  ZLIN14  ={'mo' 'ZLIN14' 0 []}';  % start of LI30                : Z=2946.400000

  DBMARK29={'mo' 'DBMARK29' 0 []}';  %(LI30 GV ) LI30 gate valve ... start of BSY

% L1/2/3 FODO cells

%  D9   ={'dr' '' DLWL9 []}';
%  D10  ={'dr' '' DLWL10 []}';
  DAQ1 ={'dr' '' 0.0342 []}';
  DAQ2 ={'dr' '' 0.027 []}';

% L2 and L3

  DAQ3  ={'dr' '' 0.3533 []}';
%  DAQ4  ={'dr' '' 2.5527 []}';
%  DAQ5  ={'dr' '' 2.841-0.3048-1.2192 []}';
  DAQ6  ={'dr' '' 0.2373 []}';
%  DAQ6A ={'dr' '' 0.2373+0.3048+1.2192 []}';
  DAQ7  ={'dr' '' 0.2748 []}';
  DAQ8  ={'dr' '' 2.6312 []}';
  DAQ8A ={'dr' '' 0.5+0.003200 []}';
  DAQ8B ={'dr' '' 2.1312-0.003200 []}';
  DAQ12 ={'dr' '' 0.2286 []}';
  DAQ13 ={'dr' '' 0.0231 []}';
  DAQ14 ={'dr' '' 0.2130 []}';
  DAQ15 ={'dr' '' 0.0087 []}';
  DAQ16 ={'dr' '' 0.2274 []}';
  DAQ17 ={'dr' '' 0.061901 []}'; % 3.9709
  D255a ={'dr' '' 0.06621-0.001510 []}';
  D255b ={'dr' '' 0.11184+0.001510 []}';
  D255c ={'dr' '' 0.17805-0.275500+0.25 []}';
  D255d ={'dr' '' 0.03420+0.275500 []}';
  D256a ={'dr' '' 2.350-1.1919-0.559100 []}';
  D256b ={'dr' '' 0.559100 []}';
 %D256e ={'dr' '' 1.019800-0.540500 []}';
  D256c ={'dr' '' 0.61475 []}';
  D256d ={'dr' '' 0.21115 []}';

% L3
  LQE = 0.1068;         %QE effective length (m)
  LQW = 0.248;          %QW (wraparound quad) effective length (m)
%  KQFL3 =  0.446670469684; % was used for 12*2*pi MUX from BX24 to BX31
%  KQDL3 = -0.424793498653; % was used for 12*2*pi MUX from BX24 to BX31
  KQFL3 =  0.395798933782;  % gives psix = 50.76 deg, 44.64 deg, 45.00 deg between four LI28 wires
  KQDL3 = -0.395649286346;  % gives TCAV3 -> OTR30 right + WS28 psiy: 48.96 deg, 45.72 deg, 43.92 deg
%  QFL3 ={'qu' '' LQE/2 KQFL3}';
%  QDL3 ={'qu' '' LQE/2 KQDL3}';

  KQ25201 =  0.697993592575;
  KQ25301 = -0.478388226374;
  KQ25401 =  0.42896785871;
  KQ25501 = -0.399864956514;
  KQ25601 =  KQFL3;
  KQ25701 =  KQDL3;
  KQ25801 =  0.407168436855;
  KQ25901 = -0.388171234952;

  KQ26201 =  0.388578933647;
  KQ26301 = -0.405404843557;
  KQ26401 =  KQFL3;
  KQ26501 =  KQDL3;
  KQ26601 =  KQFL3;
  KQ26701 =  KQDL3;
  KQ26801 =  0.406308742855;
  KQ26901 = -0.388549789828;

  KQ27201 =  0.390161854669;
  KQ27301 = -0.406474370795;
  KQ27401 =  KQFL3;
  KQ27501 =  KQDL3;
  KQ27601 =  KQFL3;
  KQ27701 =  KQDL3;
  KQ27801 =  0.406495928662;
  KQ27901 = -0.388870517181;

  KQ28201 =  0.390352348197;
  KQ28301 = -0.406461529502;
  KQ28401 =  KQFL3;
  KQ28501 =  KQDL3;
  KQ28601 =  KQFL3;
  KQ28701 =  KQDL3;
  KQ28801 =  0.406649614831;
  KQ28901 = -0.389077444001;

  KQ29201 =  0.390429567548;
  KQ29301 = -0.406416613477;
  KQ29401 =  KQFL3;
  KQ29501 =  KQDL3;
  KQ29601 =  KQFL3;
  KQ29701 =  KQDL3;
  KQ29801 =  0.406588653506;
  KQ29901 = -0.389037213556;

  KQ30201 =  0.39027307525; % Original BSY optics
  KQ30301 = -0.406178588622;
  KQ30401 =  KQFL3;
  KQ30501 = -0.395648794699; %KQDL3
  KQ30601 =  0.395797744026; %KQFL3;
%  KQ30615 =  0;
  KQ30701 = -0.397753915501; %KQDL3;
%  KQ30715 =  0;
  KQ30801 =  0.484434266;

if modelUseNewBSY
  % post BSY Reconfiguration ... no "NewBSY" optics
end

  Q25201 ={'qu' 'Q25201' LQE/2 KQ25201}';
  Q25301 ={'qu' 'Q25301' LQE/2 KQ25301}';
  Q25401 ={'qu' 'Q25401' LQE/2 KQ25401}';
  Q25501 ={'qu' 'Q25501' LQE/2 KQ25501}';
  Q25601 ={'qu' 'Q25601' LQE/2 KQ25601}';
  Q25701 ={'qu' 'Q25701' LQE/2 KQ25701}';
  Q25801 ={'qu' 'Q25801' LQE/2 KQ25801}';
  Q25901 ={'qu' 'Q25901' LQE/2 KQ25901}';

  Q26201 ={'qu' 'Q26201' LQE/2 KQ26201}';
  Q26301 ={'qu' 'Q26301' LQE/2 KQ26301}';
  Q26401 ={'qu' 'Q26401' LQE/2 KQ26401}';
  Q26501 ={'qu' 'Q26501' LQE/2 KQ26501}';
  Q26601 ={'qu' 'Q26601' LQE/2 KQ26601}';
  Q26701 ={'qu' 'Q26701' LQE/2 KQ26701}';
  Q26801 ={'qu' 'Q26801' LQE/2 KQ26801}';
  Q26901 ={'qu' 'Q26901' LQE/2 KQ26901}';

  Q27201 ={'qu' 'Q27201' LQE/2 KQ27201}';
  Q27301 ={'qu' 'Q27301' LQE/2 KQ27301}';
  Q27401 ={'qu' 'Q27401' LQE/2 KQ27401}';
  Q27501 ={'qu' 'Q27501' LQE/2 KQ27501}';
  Q27601 ={'qu' 'Q27601' LQE/2 KQ27601}';
  Q27701 ={'qu' 'Q27701' LQE/2 KQ27701}';
  Q27801 ={'qu' 'Q27801' LQE/2 KQ27801}';
  Q27901 ={'qu' 'Q27901' LQE/2 KQ27901}';

  Q28201 ={'qu' 'Q28201' LQE/2 KQ28201}';
  Q28301 ={'qu' 'Q28301' LQE/2 KQ28301}';
  Q28401 ={'qu' 'Q28401' LQE/2 KQ28401}';
  Q28501 ={'qu' 'Q28501' LQE/2 KQ28501}';
  Q28601 ={'qu' 'Q28601' LQE/2 KQ28601}';
  Q28701 ={'qu' 'Q28701' LQE/2 KQ28701}';
  Q28801 ={'qu' 'Q28801' LQE/2 KQ28801}';
  Q28901 ={'qu' 'Q28901' LQE/2 KQ28901}';

  Q29201 ={'qu' 'Q29201' LQE/2 KQ29201}';
  Q29301 ={'qu' 'Q29301' LQE/2 KQ29301}';
  Q29401 ={'qu' 'Q29401' LQE/2 KQ29401}';
  Q29501 ={'qu' 'Q29501' LQE/2 KQ29501}';
  Q29601 ={'qu' 'Q29601' LQE/2 KQ29601}';
  Q29701 ={'qu' 'Q29701' LQE/2 KQ29701}';
  Q29801 ={'qu' 'Q29801' LQE/2 KQ29801}';
  Q29901 ={'qu' 'Q29901' LQE/2 KQ29901}';

  Q30201 ={'qu' 'Q30201' LQE/2 KQ30201}';
  Q30301 ={'qu' 'Q30301' LQE/2 KQ30301}';
  Q30401 ={'qu' 'Q30401' LQE/2 KQ30401}';
  Q30501 ={'qu' 'Q30501' LQE/2 KQ30501}';
  Q30601 ={'qu' 'Q30601' LQE/2 KQ30601}';
%  Q30615A={'qu' 'Q30615' LQW/2 KQ30615}';
%  Q30615B={'qu' 'Q30615' LQW/2 KQ30615}';
%  Q30615C={'qu' 'Q30615' LQW/2 KQ30615}';
  Q30615A={'mo' 'Q30615' 0 []}'; %power supply decommissioned
  Q30615B={'mo' 'Q30615' 0 []}'; %power supply decommissioned
  Q30615C={'mo' 'Q30615' 0 []}'; %power supply decommissioned
  Q30701 ={'qu' 'Q30701' LQE/2 KQ30701}';
%  Q30715A={'qu' 'Q30715' LQW/2 KQ30715}';
%  Q30715B={'qu' 'Q30715' LQW/2 KQ30715}';
%  Q30715C={'qu' 'Q30715' LQW/2 KQ30715}';
  Q30715A={'mo' 'Q30715' 0 []}'; %power supply decommissioned
  Q30715B={'mo' 'Q30715' 0 []}'; %power supply decommissioned
  Q30715C={'mo' 'Q30715' 0 []}'; %power supply decommissioned
  Q30801 ={'qu' 'Q30801' LQE/2 KQ30801}';

%  BPM24901 ={'mo' 'BPM24901' 0 []}';
  BPM25201 ={'mo' 'BPM25201' 0 []}';
  BPM25301 ={'mo' 'BPM25301' 0 []}';
  BPM25401 ={'mo' 'BPM25401' 0 []}';
  BPM25501 ={'mo' 'BPM25501' 0 []}';
  BPM25601 ={'mo' 'BPM25601' 0 []}';
  BPM25701 ={'mo' 'BPM25701' 0 []}';
  BPM25801 ={'mo' 'BPM25801' 0 []}';
  BPM25901 ={'mo' 'BPM25901' 0 []}';
  BPM26201 ={'mo' 'BPM26201' 0 []}';
  BPM26301 ={'mo' 'BPM26301' 0 []}';
  BPM26401 ={'mo' 'BPM26401' 0 []}';
  BPM26501 ={'mo' 'BPM26501' 0 []}';
  BPM26601 ={'mo' 'BPM26601' 0 []}';
  BPM26701 ={'mo' 'BPM26701' 0 []}';
  BPM26801 ={'mo' 'BPM26801' 0 []}';
  BPM26901 ={'mo' 'BPM26901' 0 []}';
  BPM27201 ={'mo' 'BPM27201' 0 []}';
  BPM27301 ={'mo' 'BPM27301' 0 []}';
  BPM27401 ={'mo' 'BPM27401' 0 []}';
  BPM27501 ={'mo' 'BPM27501' 0 []}';
  BPM27601 ={'mo' 'BPM27601' 0 []}';
  BPM27701 ={'mo' 'BPM27701' 0 []}';
  BPM27801 ={'mo' 'BPM27801' 0 []}';
  BPM27901 ={'mo' 'BPM27901' 0 []}';
  BPM28201 ={'mo' 'BPM28201' 0 []}';
  BPM28301 ={'mo' 'BPM28301' 0 []}';
  BPM28401 ={'mo' 'BPM28401' 0 []}';
  BPM28501 ={'mo' 'BPM28501' 0 []}';
  BPM28601 ={'mo' 'BPM28601' 0 []}';
  BPM28701 ={'mo' 'BPM28701' 0 []}';
  BPM28801 ={'mo' 'BPM28801' 0 []}';
  BPM28901 ={'mo' 'BPM28901' 0 []}';
  BPM29201 ={'mo' 'BPM29201' 0 []}';
  BPM29301 ={'mo' 'BPM29301' 0 []}';
  BPM29401 ={'mo' 'BPM29401' 0 []}';
  BPM29501 ={'mo' 'BPM29501' 0 []}';
  BPM29601 ={'mo' 'BPM29601' 0 []}';
  BPM29701 ={'mo' 'BPM29701' 0 []}';
  BPM29801 ={'mo' 'BPM29801' 0 []}';
  BPM29901 ={'mo' 'BPM29901' 0 []}';
  BPM30201 ={'mo' 'BPM30201' 0 []}';
  BPM30301 ={'mo' 'BPM30301' 0 []}';
  BPM30401 ={'mo' 'BPM30401' 0 []}';
  BPM30501 ={'mo' 'BPM30501' 0 []}';
  BPM30601 ={'mo' 'BPM30601' 0 []}';
  BPM30701 ={'mo' 'BPM30701' 0 []}';
  BPM30801 ={'mo' 'BPM30801' 0 []}';

% ==============================================================================
% LCAVs
% ------------------------------------------------------------------------------
% the L3 linac consists of: 161 10   ft S-band sections @ 25% power
%                            12 10   ft S-band sections @ 50% power
%                             3  9.4 ft S-band sections @ 25% power
%                             4  7   ft S-band sections @ 25% power
% ------------------------------------------------------------------------------
% 24-OCT-2008, M. Woodley
%    Change XC29092, YC29092, XC29095, and YC29095 to MARK ... the physical
%    devices are still there, but they won't be used
% 18-SEP-2008, M. Woodley
%    Fixed structure counts in header comments
% 17-AUG-2008, P. Emma
%    K25_1d was changed back to LCAVITY (from D25_1d) and uses P50 (should since Jan. 2008)
%    K25_3c LCAVITY was changed to use P50 (should since Jan. 2008)
%    K28_5c LCAVITY was changed to use P50 (should since Jan. 2008)
% 02-JAN-2008, P. Emma
%    Rename sec-28 wires (WS044 -> WS27644, WS144 -> WS28144,
%    WS444 -> WS28444, WS544 -> WS28744).
% 04-NOV-2007, P. Emma
%    Move XC25502 & YC25503 to downstream of Q25501, as they should be (were upstream).
%    Remove XC29090, YC29090, XC29096, and YC29096 correctors (not installed).
% 04-OCT-2007, P. Emma
%    Remove D25cm from upbeam of TCAV3 and replace with 25-cm longer D255c, which
%    was negative!
% 11-SEP-2007, P. Emma
%    Move BL22 from near BX24 to just upbeam of OTR22 & remove 25_1c, 1d, and
%    28-5d (these no longer re-installed into linac due to money limits).
% 10-DEC-2006, P. Emma
%    Move BXKIK to 25-3d where it will fit after removing the 25-3d RF acc.
%    structure.  Also add OTR22 near BXKIK.
% 03-DEC-2006, P. Emma
%    Move IMBC2O toroid to upbeam of BXKIK (from QM22 area).
% 02-AUG-2006, M. Woodley
%    Reinstate LI30 wraparound quads (QUAD LI30 615 and QUAD LI30 715) as
%    quadrupoles (NOTE: uses negative drifts!)
% 29-NOV-2005, P. Emma
%    Add types for LCAV's, HKIC's, and VKIC's.
% 13-JUL-2005, P. Emma
%    Move TCAV3 to 25-2d for better sigZ resolution (was 25-5a).  Restored 25-5a
%    and removed 25-2d.
% 06-JUL-2005, P. Emma
%    Rename TCAVH to TCAV3.
% 02-JUN-2005, P. Emma
%    Add comments adjacent to fast-feedback correctors.
% ------------------------------------------------------------------------------

  K25_1a1 ={'lc' 'K25_1a' 0.3250 [SbandF P25*gradL3*0.3250 PhiL3*TWOPI]}';

  K25_1a2 ={'lc' 'K25_1a' 0.3250 [SbandF P25*gradL3*0.3250 PhiL3*TWOPI]}';

  K25_1a3 ={'lc' 'K25_1a' 2.3941 [SbandF P25*gradL3*2.3941 PhiL3*TWOPI]}';

  K25_1b  ={'lc' 'K25_1b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

%  K25_1c  ={'lc' 'K25_1c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';
%
  D25_1c ={'dr' '' 3.0441 []}';
  K25_1d  ={'lc' 'K25_1d' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

%  D25_1d ={'dr' '' 3.0441 []}';
  K25_2a1 ={'lc' 'K25_2a' 0.4530 [SbandF P25*gradL3*0.4530 PhiL3*TWOPI]}';

  K25_2a2 ={'lc' 'K25_2a' 0.3175 [SbandF P25*gradL3*0.3175 PhiL3*TWOPI]}';

  K25_2a3 ={'lc' 'K25_2a' 2.2736 [SbandF P25*gradL3*2.2736 PhiL3*TWOPI]}';

  K25_2b  ={'lc' 'K25_2b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_2c  ={'lc' 'K25_2c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_3a1 ={'lc' 'K25_3a' 0.3312 [SbandF P25*gradL3*0.3312 PhiL3*TWOPI]}';

  K25_3a2 ={'lc' 'K25_3a' 0.3504 [SbandF P25*gradL3*0.3504 PhiL3*TWOPI]}';

  K25_3a3 ={'lc' 'K25_3a' 2.3625 [SbandF P25*gradL3*2.3625 PhiL3*TWOPI]}';

  K25_3b  ={'lc' 'K25_3b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_3c  ={'lc' 'K25_3c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_4a1 ={'lc' 'K25_4a' 0.3268 [SbandF P25*gradL3*0.3268 PhiL3*TWOPI]}';

  K25_4a2 ={'lc' 'K25_4a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K25_4a3 ={'lc' 'K25_4a' 2.4673 [SbandF P25*gradL3*2.4673 PhiL3*TWOPI]}';

  K25_4b  ={'lc' 'K25_4b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_4c  ={'lc' 'K25_4c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_4d  ={'lc' 'K25_4d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_5a1 ={'lc' 'K25_5a' 0.3268 [SbandF P25*gradL3*0.3268 PhiL3*TWOPI]}';

  K25_5a2 ={'lc' 'K25_5a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K25_5a3 ={'lc' 'K25_5a' 2.4673 [SbandF P25*gradL3*2.4673 PhiL3*TWOPI]}';

  K25_5b  ={'lc' 'K25_5b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_5c  ={'lc' 'K25_5c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_5d  ={'lc' 'K25_5d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_6a1 ={'lc' 'K25_6a' 0.3280 [SbandF P25*gradL3*0.3280 PhiL3*TWOPI]}';

  K25_6a2 ={'lc' 'K25_6a' 0.3822 [SbandF P25*gradL3*0.3822 PhiL3*TWOPI]}';

  K25_6a3 ={'lc' 'K25_6a' 2.3339 [SbandF P25*gradL3*2.3339 PhiL3*TWOPI]}';

  K25_6b  ={'lc' 'K25_6b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_6c  ={'lc' 'K25_6c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_6d  ={'lc' 'K25_6d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_7a1 ={'lc' 'K25_7a' 0.3336 [SbandF P25*gradL3*0.3336 PhiL3*TWOPI]}';

  K25_7a2 ={'lc' 'K25_7a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K25_7a3 ={'lc' 'K25_7a' 2.4605 [SbandF P25*gradL3*2.4605 PhiL3*TWOPI]}';

  K25_7b  ={'lc' 'K25_7b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_7c  ={'lc' 'K25_7c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_7d  ={'lc' 'K25_7d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_8a1 ={'lc' 'K25_8a' 0.3292 [SbandF P25*gradL3*0.3292 PhiL3*TWOPI]}';

  K25_8a2 ={'lc' 'K25_8a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K25_8a3 ={'lc' 'K25_8a' 2.4649 [SbandF P25*gradL3*2.4649 PhiL3*TWOPI]}';

  K25_8b  ={'lc' 'K25_8b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_8c  ={'lc' 'K25_8c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K25_8d1 ={'lc' 'K25_8d' 2.3869 [SbandF P25*gradL3*2.3869 PhiL3*TWOPI]}';

  K25_8d2 ={'lc' 'K25_8d' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K25_8d3 ={'lc' 'K25_8d' 0.4072 [SbandF P25*gradL3*0.4072 PhiL3*TWOPI]}';


  K26_1a  ={'lc' 'K26_1a' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_1b  ={'lc' 'K26_1b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_1c  ={'lc' 'K26_1c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_1d  ={'lc' 'K26_1d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_2a1 ={'lc' 'K26_2a' 0.3256 [SbandF P25*gradL3*0.3256 PhiL3*TWOPI]}';

  K26_2a2 ={'lc' 'K26_2a' 0.3719 [SbandF P25*gradL3*0.3719 PhiL3*TWOPI]}';

  K26_2a3 ={'lc' 'K26_2a' 2.3466 [SbandF P25*gradL3*2.3466 PhiL3*TWOPI]}';

  K26_2b  ={'lc' 'K26_2b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_2c  ={'lc' 'K26_2c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_2d  ={'lc' 'K26_2d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_3a1 ={'lc' 'K26_3a' 0.3312 [SbandF P25*gradL3*0.3312 PhiL3*TWOPI]}';

  K26_3a2 ={'lc' 'K26_3a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K26_3a3 ={'lc' 'K26_3a' 2.4629 [SbandF P25*gradL3*2.4629 PhiL3*TWOPI]}';

  K26_3b  ={'lc' 'K26_3b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_3c  ={'lc' 'K26_3c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_3d  ={'lc' 'K26_3d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_4a1 ={'lc' 'K26_4a' 0.3268 [SbandF P25*gradL3*0.3268 PhiL3*TWOPI]}';

  K26_4a2 ={'lc' 'K26_4a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K26_4a3 ={'lc' 'K26_4a' 2.4673 [SbandF P25*gradL3*2.4673 PhiL3*TWOPI]}';

  K26_4b  ={'lc' 'K26_4b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_4c  ={'lc' 'K26_4c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_4d  ={'lc' 'K26_4d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_5a1 ={'lc' 'K26_5a' 0.3324 [SbandF P25*gradL3*0.3324 PhiL3*TWOPI]}';

  K26_5a2 ={'lc' 'K26_5a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K26_5a3 ={'lc' 'K26_5a' 2.4617 [SbandF P25*gradL3*2.4617 PhiL3*TWOPI]}';

  K26_5b  ={'lc' 'K26_5b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_5c  ={'lc' 'K26_5c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_5d  ={'lc' 'K26_5d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_6a1 ={'lc' 'K26_6a' 0.3280 [SbandF P25*gradL3*0.3280 PhiL3*TWOPI]}';

  K26_6a2 ={'lc' 'K26_6a' 0.4108 [SbandF P25*gradL3*0.4108 PhiL3*TWOPI]}';

  K26_6a3 ={'lc' 'K26_6a' 2.3053 [SbandF P25*gradL3*2.3053 PhiL3*TWOPI]}';

  K26_6b  ={'lc' 'K26_6b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_6c  ={'lc' 'K26_6c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_6d  ={'lc' 'K26_6d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_7a1 ={'lc' 'K26_7a' 0.3336 [SbandF P25*gradL3*0.3336 PhiL3*TWOPI]}';

  K26_7a2 ={'lc' 'K26_7a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K26_7a3 ={'lc' 'K26_7a' 2.4605 [SbandF P25*gradL3*2.4605 PhiL3*TWOPI]}';

  K26_7b  ={'lc' 'K26_7b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_7c  ={'lc' 'K26_7c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_7d  ={'lc' 'K26_7d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_8a1 ={'lc' 'K26_8a' 0.3292 [SbandF P25*gradL3*0.3292 PhiL3*TWOPI]}';

  K26_8a2 ={'lc' 'K26_8a' 0.3810 [SbandF P25*gradL3*0.3810 PhiL3*TWOPI]}';

  K26_8a3 ={'lc' 'K26_8a' 2.3339 [SbandF P25*gradL3*2.3339 PhiL3*TWOPI]}';

  K26_8b  ={'lc' 'K26_8b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_8c  ={'lc' 'K26_8c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K26_8d1 ={'lc' 'K26_8d' 2.3869 [SbandF P25*gradL3*2.3869 PhiL3*TWOPI]}';

  K26_8d2 ={'lc' 'K26_8d' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K26_8d3 ={'lc' 'K26_8d' 0.4072 [SbandF P25*gradL3*0.4072 PhiL3*TWOPI]}';


  K27_1a  ={'lc' 'K27_1a' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_1b  ={'lc' 'K27_1b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_1c  ={'lc' 'K27_1c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_1d  ={'lc' 'K27_1d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_2a1 ={'lc' 'K27_2a' 0.3256 [SbandF P25*gradL3*0.3256 PhiL3*TWOPI]}';

  K27_2a2 ={'lc' 'K27_2a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K27_2a3 ={'lc' 'K27_2a' 2.4685 [SbandF P25*gradL3*2.4685 PhiL3*TWOPI]}';

  K27_2b  ={'lc' 'K27_2b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_2c  ={'lc' 'K27_2c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_2d  ={'lc' 'K27_2d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_3a1 ={'lc' 'K27_3a' 0.3312 [SbandF P25*gradL3*0.3312 PhiL3*TWOPI]}';

  K27_3a2 ={'lc' 'K27_3a' 0.3695 [SbandF P25*gradL3*0.3695 PhiL3*TWOPI]}';

  K27_3a3 ={'lc' 'K27_3a' 2.3434 [SbandF P25*gradL3*2.3434 PhiL3*TWOPI]}';

  K27_3b  ={'lc' 'K27_3b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_3c  ={'lc' 'K27_3c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_3d  ={'lc' 'K27_3d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_4a1 ={'lc' 'K27_4a' 0.3268 [SbandF P25*gradL3*0.3268 PhiL3*TWOPI]}';

  K27_4a2 ={'lc' 'K27_4a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K27_4a3 ={'lc' 'K27_4a' 2.4673 [SbandF P25*gradL3*2.4673 PhiL3*TWOPI]}';

  K27_4b  ={'lc' 'K27_4b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_4c  ={'lc' 'K27_4c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_4d  ={'lc' 'K27_4d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_5a1 ={'lc' 'K27_5a' 0.3324 [SbandF P25*gradL3*0.3324 PhiL3*TWOPI]}';

  K27_5a2 ={'lc' 'K27_5a' 0.3683 [SbandF P25*gradL3*0.3683 PhiL3*TWOPI]}';

  K27_5a3 ={'lc' 'K27_5a' 2.3434 [SbandF P25*gradL3*2.3434 PhiL3*TWOPI]}';

  K27_5b  ={'lc' 'K27_5b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_5c  ={'lc' 'K27_5c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_5d  ={'lc' 'K27_5d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_6a1 ={'lc' 'K27_6a' 0.3280 [SbandF P25*gradL3*0.3280 PhiL3*TWOPI]}';

  K27_6a2 ={'lc' 'K27_6a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K27_6a3 ={'lc' 'K27_6a' 2.4661 [SbandF P25*gradL3*2.4661 PhiL3*TWOPI]}';

  K27_6b  ={'lc' 'K27_6b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_6c  ={'lc' 'K27_6c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_7a1 ={'lc' 'K27_7a' 0.3336 [SbandF P25*gradL3*0.3336 PhiL3*TWOPI]}';

  K27_7a2 ={'lc' 'K27_7a' 0.3512 [SbandF P25*gradL3*0.3512 PhiL3*TWOPI]}';

  K27_7a3 ={'lc' 'K27_7a' 2.3593 [SbandF P25*gradL3*2.3593 PhiL3*TWOPI]}';

  K27_7b  ={'lc' 'K27_7b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_7c  ={'lc' 'K27_7c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_7d  ={'lc' 'K27_7d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_8a1 ={'lc' 'K27_8a' 0.3292 [SbandF P25*gradL3*0.3292 PhiL3*TWOPI]}';

  K27_8a2 ={'lc' 'K27_8a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K27_8a3 ={'lc' 'K27_8a' 2.4649 [SbandF P25*gradL3*2.4649 PhiL3*TWOPI]}';

  K27_8b  ={'lc' 'K27_8b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_8c  ={'lc' 'K27_8c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K27_8d1 ={'lc' 'K27_8d' 2.2411 [SbandF P25*gradL3*2.2411 PhiL3*TWOPI]}';

  K27_8d2 ={'lc' 'K27_8d' 0.3958 [SbandF P25*gradL3*0.3958 PhiL3*TWOPI]}';

  K27_8d3 ={'lc' 'K27_8d' 0.4072 [SbandF P25*gradL3*0.4072 PhiL3*TWOPI]}';

     
  K28_1a  ={'lc' 'K28_1a' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_1b  ={'lc' 'K28_1b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_1c  ={'lc' 'K28_1c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_2a1 ={'lc' 'K28_2a' 0.3256 [SbandF P25*gradL3*0.3256 PhiL3*TWOPI]}';

  K28_2a2 ={'lc' 'K28_2a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K28_2a3 ={'lc' 'K28_2a' 2.4685 [SbandF P25*gradL3*2.4685 PhiL3*TWOPI]}';

  K28_2b  ={'lc' 'K28_2b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_2c  ={'lc' 'K28_2c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_2d  ={'lc' 'K28_2d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_3a1 ={'lc' 'K28_3a' 0.3312 [SbandF P25*gradL3*0.3312 PhiL3*TWOPI]}';

  K28_3a2 ={'lc' 'K28_3a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K28_3a3 ={'lc' 'K28_3a' 2.4629 [SbandF P25*gradL3*2.4629 PhiL3*TWOPI]}';

  K28_3b  ={'lc' 'K28_3b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_3c  ={'lc' 'K28_3c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_3d  ={'lc' 'K28_3d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_4a1 ={'lc' 'K28_4a' 0.3800 [SbandF P25*gradL3*0.3800 PhiL3*TWOPI]}';

  K28_4a2 ={'lc' 'K28_4a' 0.2921 [SbandF P25*gradL3*0.2921 PhiL3*TWOPI]}';

  K28_4a3 ={'lc' 'K28_4a' 2.3720 [SbandF P25*gradL3*2.3720 PhiL3*TWOPI]}';

  K28_4b  ={'lc' 'K28_4b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_4c  ={'lc' 'K28_4c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_5a1 ={'lc' 'K28_5a' 0.3959 [SbandF P25*gradL3*0.3959 PhiL3*TWOPI]}';

  K28_5a2 ={'lc' 'K28_5a' 0.3111 [SbandF P25*gradL3*0.3111 PhiL3*TWOPI]}';

  K28_5a3 ={'lc' 'K28_5a' 2.3371 [SbandF P25*gradL3*2.3371 PhiL3*TWOPI]}';

  K28_5b  ={'lc' 'K28_5b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_5c  ={'lc' 'K28_5c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

%  K28_5d  ={'lc' 'K28_5d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';
%
  D28_5d ={'dr' '' 3.0441 []}';
  K28_6a1 ={'lc' 'K28_6a' 0.3280 [SbandF P25*gradL3*0.3280 PhiL3*TWOPI]}';

  K28_6a2 ={'lc' 'K28_6a' 0.3600 [SbandF P25*gradL3*0.3600 PhiL3*TWOPI]}';

  K28_6a3 ={'lc' 'K28_6a' 2.3561 [SbandF P25*gradL3*2.3561 PhiL3*TWOPI]}';

  K28_6b  ={'lc' 'K28_6b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_6c  ={'lc' 'K28_6c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_6d  ={'lc' 'K28_6d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_7a1 ={'lc' 'K28_7a' 0.3336 [SbandF P25*gradL3*0.3336 PhiL3*TWOPI]}';

  K28_7a2 ={'lc' 'K28_7a' 0.4052 [SbandF P25*gradL3*0.4052 PhiL3*TWOPI]}';

  K28_7a3 ={'lc' 'K28_7a' 2.3053 [SbandF P25*gradL3*2.3053 PhiL3*TWOPI]}';

  K28_7b  ={'lc' 'K28_7b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_7c  ={'lc' 'K28_7c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_8a1 ={'lc' 'K28_8a' 0.3292 [SbandF P25*gradL3*0.3292 PhiL3*TWOPI]}';

  K28_8a2 ={'lc' 'K28_8a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K28_8a3 ={'lc' 'K28_8a' 2.4649 [SbandF P25*gradL3*2.4649 PhiL3*TWOPI]}';

  K28_8b  ={'lc' 'K28_8b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_8c  ={'lc' 'K28_8c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K28_8d1 ={'lc' 'K28_8d' 2.3869 [SbandF P25*gradL3*2.3869 PhiL3*TWOPI]}';

  K28_8d2 ={'lc' 'K28_8d' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K28_8d3 ={'lc' 'K28_8d' 0.4072 [SbandF P25*gradL3*0.4072 PhiL3*TWOPI]}';

     
  K29_1a  ={'lc' 'K29_1a' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_1b  ={'lc' 'K29_1b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_1c  ={'lc' 'K29_1c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_2a1 ={'lc' 'K29_2a' 0.3256 [SbandF P25*gradL3*0.3256 PhiL3*TWOPI]}';

  K29_2a2 ={'lc' 'K29_2a' 0.3528 [SbandF P25*gradL3*0.3528 PhiL3*TWOPI]}';

  K29_2a3 ={'lc' 'K29_2a' 2.3657 [SbandF P25*gradL3*2.3657 PhiL3*TWOPI]}';

  K29_2b  ={'lc' 'K29_2b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_2c  ={'lc' 'K29_2c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_2d  ={'lc' 'K29_2d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_3a1 ={'lc' 'K29_3a' 0.3312 [SbandF P25*gradL3*0.3312 PhiL3*TWOPI]}';

  K29_3a2 ={'lc' 'K29_3a' 0.3599 [SbandF P25*gradL3*0.3599 PhiL3*TWOPI]}';

  K29_3a3 ={'lc' 'K29_3a' 2.3530 [SbandF P25*gradL3*2.3530 PhiL3*TWOPI]}';

  K29_3b  ={'lc' 'K29_3b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_3c  ={'lc' 'K29_3c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_3d  ={'lc' 'K29_3d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_4a1 ={'lc' 'K29_4a' 0.3268 [SbandF P25*gradL3*0.3268 PhiL3*TWOPI]}';

  K29_4a2 ={'lc' 'K29_4a' 0.2500 [SbandF P25*gradL3*0.2500 PhiL3*TWOPI]}';

  K29_4a3 ={'lc' 'K29_4a' 2.4673 [SbandF P25*gradL3*2.4673 PhiL3*TWOPI]}';

  K29_4b  ={'lc' 'K29_4b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_4c  ={'lc' 'K29_4c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_5a1 ={'lc' 'K29_5a' 0.3800 [SbandF P25*gradL3*0.3800 PhiL3*TWOPI]}';

  K29_5a2 ={'lc' 'K29_5a' 0.2762 [SbandF P25*gradL3*0.2762 PhiL3*TWOPI]}';

  K29_5a3 ={'lc' 'K29_5a' 2.3879 [SbandF P25*gradL3*2.3879 PhiL3*TWOPI]}';

  K29_5b  ={'lc' 'K29_5b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_5c  ={'lc' 'K29_5c' 3.0441 [SbandF P50*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_6a1 ={'lc' 'K29_6a' 0.4498 [SbandF P25*gradL3*0.4498 PhiL3*TWOPI]}';

  K29_6a2 ={'lc' 'K29_6a' 0.3715 [SbandF P25*gradL3*0.3715 PhiL3*TWOPI]}';

  K29_6a3 ={'lc' 'K29_6a' 2.2228 [SbandF P25*gradL3*2.2228 PhiL3*TWOPI]}';

  K29_6b  ={'lc' 'K29_6b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_6c  ={'lc' 'K29_6c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_6d  ={'lc' 'K29_6d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_7a1 ={'lc' 'K29_7a' 0.3336 [SbandF P25*gradL3*0.3336 PhiL3*TWOPI]}';

  K29_7a2 ={'lc' 'K29_7a' 0.3988 [SbandF P25*gradL3*0.3988 PhiL3*TWOPI]}';

  K29_7a3 ={'lc' 'K29_7a' 2.3117 [SbandF P25*gradL3*2.3117 PhiL3*TWOPI]}';

  K29_7b  ={'lc' 'K29_7b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_7c  ={'lc' 'K29_7c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_7d  ={'lc' 'K29_7d' 2.8692 [SbandF P25*gradL3*2.8692 PhiL3*TWOPI]}';
  
  K29_8a1 ={'lc' 'K29_8a' 0.3896 [SbandF P25*gradL3*0.3896 PhiL3*TWOPI]}';

  K29_8a2 ={'lc' 'K29_8a' 0.2790 [SbandF P25*gradL3*0.2790 PhiL3*TWOPI]}';

  K29_8a3 ={'lc' 'K29_8a' 2.3755 [SbandF P25*gradL3*2.3755 PhiL3*TWOPI]}';

  K29_8b  ={'lc' 'K29_8b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_8c  ={'lc' 'K29_8c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K29_8d1 ={'lc' 'K29_8d' 2.4558 [SbandF P25*gradL3*2.4558 PhiL3*TWOPI]}';

  K29_8d2 ={'lc' 'K29_8d' 0.2800 [SbandF P25*gradL3*0.2800 PhiL3*TWOPI]}';

  K29_8d3 ={'lc' 'K29_8d' 0.3083 [SbandF P25*gradL3*0.3083 PhiL3*TWOPI]}';

     
  K30_1a  ={'lc' 'K30_1a' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_1b  ={'lc' 'K30_1b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_1c  ={'lc' 'K30_1c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_1d  ={'lc' 'K30_1d' 2.1694 [SbandF P25*gradL3*2.1694 PhiL3*TWOPI]}';
  
  K30_2a1 ={'lc' 'K30_2a' 0.5006 [SbandF P25*gradL3*0.5006 PhiL3*TWOPI]}';

  K30_2a2 ={'lc' 'K30_2a' 0.3302 [SbandF P25*gradL3*0.3302 PhiL3*TWOPI]}';

  K30_2a3 ={'lc' 'K30_2a' 2.2133 [SbandF P25*gradL3*2.2133 PhiL3*TWOPI]}';

  K30_2b  ={'lc' 'K30_2b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_2c  ={'lc' 'K30_2c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_2d  ={'lc' 'K30_2d' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_3a1 ={'lc' 'K30_3a' 0.3986 [SbandF P25*gradL3*0.3986 PhiL3*TWOPI]}';

  K30_3a2 ={'lc' 'K30_3a' 0.3300 [SbandF P25*gradL3*0.3300 PhiL3*TWOPI]}';

  K30_3a3 ={'lc' 'K30_3a' 2.3155 [SbandF P25*gradL3*2.3155 PhiL3*TWOPI]}';

  K30_3b  ={'lc' 'K30_3b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_3c  ={'lc' 'K30_3c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_3d  ={'lc' 'K30_3d' 2.1694 [SbandF P25*gradL3*2.1694 PhiL3*TWOPI]}';
  
  K30_4a1 ={'lc' 'K30_4a' 0.3856 [SbandF P25*gradL3*0.3856 PhiL3*TWOPI]}';

  K30_4a2 ={'lc' 'K30_4a' 0.2790 [SbandF P25*gradL3*0.2790 PhiL3*TWOPI]}';

  K30_4a3 ={'lc' 'K30_4a' 2.3795 [SbandF P25*gradL3*2.3795 PhiL3*TWOPI]}';

  K30_4b  ={'lc' 'K30_4b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_4c  ={'lc' 'K30_4c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_4d  ={'lc' 'K30_4d' 2.1694 [SbandF P25*gradL3*2.1694 PhiL3*TWOPI]}';
  
  K30_5a1 ={'lc' 'K30_5a' 0.3726 [SbandF P25*gradL3*0.3726 PhiL3*TWOPI]}';

  K30_5a2 ={'lc' 'K30_5a' 0.2920 [SbandF P25*gradL3*0.2920 PhiL3*TWOPI]}';

  K30_5a3 ={'lc' 'K30_5a' 2.3795 [SbandF P25*gradL3*2.3795 PhiL3*TWOPI]}';

  K30_5b  ={'lc' 'K30_5b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_5c  ={'lc' 'K30_5c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_5d  ={'lc' 'K30_5d' 2.1694 [SbandF P25*gradL3*2.1694 PhiL3*TWOPI]}';
  
  K30_6a1 ={'lc' 'K30_6a' 0.3940 [SbandF P25*gradL3*0.3940 PhiL3*TWOPI]}';

  K30_6a2 ={'lc' 'K30_6a' 0.3930 [SbandF P25*gradL3*0.3930 PhiL3*TWOPI]}';

  K30_6a3 ={'lc' 'K30_6a' 0.4070 [SbandF P25*gradL3*0.4070 PhiL3*TWOPI]}';

  K30_6a4 ={'lc' 'K30_6a' 0.9810 [SbandF P25*gradL3*0.9810 PhiL3*TWOPI]}';

  K30_6a5 ={'lc' 'K30_6a' 0.3550 [SbandF P25*gradL3*0.3550 PhiL3*TWOPI]}';

  K30_6a6 ={'lc' 'K30_6a' 0.5141 [SbandF P25*gradL3*0.5141 PhiL3*TWOPI]}';

  K30_6b  ={'lc' 'K30_6b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_6c  ={'lc' 'K30_6c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_6d  ={'lc' 'K30_6d' 2.8692 [SbandF P25*gradL3*2.8692 PhiL3*TWOPI]}';

  K30_7a1 ={'lc' 'K30_7a' 0.3813 [SbandF P25*gradL3*0.3813 PhiL3*TWOPI]}';

  K30_7a2 ={'lc' 'K30_7a' 0.4317 [SbandF P25*gradL3*0.4317 PhiL3*TWOPI]}';

  K30_7a3 ={'lc' 'K30_7a' 0.3740 [SbandF P25*gradL3*0.3740 PhiL3*TWOPI]}';

  K30_7a4 ={'lc' 'K30_7a' 0.9910 [SbandF P25*gradL3*0.9910 PhiL3*TWOPI]}';

  K30_7a5 ={'lc' 'K30_7a' 0.3590 [SbandF P25*gradL3*0.3590 PhiL3*TWOPI]}';

  K30_7a6 ={'lc' 'K30_7a' 0.5071 [SbandF P25*gradL3*0.5071 PhiL3*TWOPI]}';

  K30_7b  ={'lc' 'K30_7b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_7c  ={'lc' 'K30_7c' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_7d  ={'lc' 'K30_7d' 2.8692 [SbandF P25*gradL3*2.8692 PhiL3*TWOPI]}';
  
  K30_8a1 ={'lc' 'K30_8a' 0.3859 [SbandF P25*gradL3*0.3859 PhiL3*TWOPI]}';

  K30_8a2 ={'lc' 'K30_8a' 0.3810 [SbandF P25*gradL3*0.3810 PhiL3*TWOPI]}';

  K30_8a3 ={'lc' 'K30_8a' 2.2772 [SbandF P25*gradL3*2.2772 PhiL3*TWOPI]}';

  K30_8b  ={'lc' 'K30_8b' 3.0441 [SbandF P25*gradL3*3.0441 PhiL3*TWOPI]}';

  K30_8c1 ={'lc' 'K30_8c' 0.7620 [SbandF P50*gradL3*0.7620 PhiL3*TWOPI]}';

  K30_8c2 ={'lc' 'K30_8c' 1.4669 [SbandF P50*gradL3*1.4669 PhiL3*TWOPI]}';

  K30_8c3 ={'lc' 'K30_8c' 0.8152 [SbandF P50*gradL3*0.8152 PhiL3*TWOPI]}';


% ==============================================================================
% DRIFs
% ------------------------------------------------------------------------------

  DAQ4A  ={'dr' '' 0.2527 []}';
  DAQ4B  ={'dr' '' 0.203  []}';
  DAQ4C  ={'dr' '' 0.915  []}';
  DAQ4D  ={'dr' '' 0.272  []}';
  DAQ4E  ={'dr' '' 0.91   []}';
  DAQ5A  ={'dr' '' 2.3435 []}';
  DAQ6A  ={'dr' '' 0.7348 []}';
  DAQ5B  ={'dr' '' 2.841  []}';
  DAQ6B  ={'dr' '' 0.2373 []}';
  DAQ5C  ={'dr' '' 2.841  []}';
  DAQ6C  ={'dr' '' 0.2373 []}';
  DAQ5D  ={'dr' '' 2.344  []}';
  DAQ6D  ={'dr' '' 0.7343 []}';
  DAQ5B1 ={'dr' '' 2.0907 []}';
  DAQ5B2 ={'dr' '' 0.296  []}';
  DAQ5B3 ={'dr' '' 0.4543 []}';
  DAQ5C1 ={'dr' '' 2.0807 []}';
  DAQ5C2 ={'dr' '' 0.286  []}';
  DAQ5C3 ={'dr' '' 0.4743 []}';
  DAQ8C  ={'dr' '' 0.3352 []}';
  DAQ8D  ={'dr' '' 2.296  []}';
  DAQ9A  ={'dr' '' 0.0811 []}';
  DAQ9B  ={'dr' '' 0.128  []}';
  DAQ10A ={'dr' '' 0.1333 []}';
  DAQ10B ={'dr' '' 0.203  []}';
  DAQ10C ={'dr' '' 0.215  []}';
  DAQ10D ={'dr' '' 0.3576 []}';
  DAQ10E ={'dr' '' 0.7765 []}';
  DAQ10F ={'dr' '' 0.1324 []}';
  DAQ10G ={'dr' '' 0.1301 []}';
  DAQ10H ={'dr' '' 0.203  []}';
  DAQ10I ={'dr' '' 0.206  []}';
  DAQ10J ={'dr' '' 0.237  []}';
  DAQ10K ={'dr' '' 0.1328 []}';
  DAQ11A ={'dr' '' 0.1317 []}';
  DAQ11B ={'dr' '' 0.211  []}';
  DAQ11C ={'dr' '' 0.211  []}';
  DAQ11D ={'dr' '' 0.1536 []}';
  D10CA  ={'dr' '' 2.8157 []}';
  D10CB  ={'dr' '' 0.2284 []}';
  D10CC  ={'dr' '' 2.8159 []}';
  D10CD  ={'dr' '' 0.2282 []}';
  D10CE  ={'dr' '' 2.8161 []}';
  D10CF  ={'dr' '' 0.2280 []}';

% ==============================================================================
% XCORs
% ------------------------------------------------------------------------------

  XC24900 ={'mo' 'XC24900' 0 []}';

  XC25202 ={'mo' 'XC25202' 0 []}';       % fast-feedback (loop-3)
  XC25302 ={'mo' 'XC25302' 0 []}';
  XC25402 ={'mo' 'XC25402' 0 []}';
  XC25502 ={'mo' 'XC25502' 0 []}';
  XC25602 ={'mo' 'XC25602' 0 []}';       % fast-feedback (loop-3)
  XC25702 ={'mo' 'XC25702' 0 []}';
  XC25802 ={'mo' 'XC25802' 0 []}';
  XC25900 ={'mo' 'XC25900' 0 []}';

  XC26202 ={'mo' 'XC26202' 0 []}';
  XC26302 ={'mo' 'XC26302' 0 []}';
  XC26402 ={'mo' 'XC26402' 0 []}';
  XC26502 ={'mo' 'XC26502' 0 []}';
  XC26602 ={'mo' 'XC26602' 0 []}';
  XC26702 ={'mo' 'XC26702' 0 []}';
  XC26802 ={'mo' 'XC26802' 0 []}';
  XC26900 ={'mo' 'XC26900' 0 []}';

  XC27202 ={'mo' 'XC27202' 0 []}';
  XC27302 ={'mo' 'XC27302' 0 []}';
  XC27402 ={'mo' 'XC27402' 0 []}';
  XC27502 ={'mo' 'XC27502' 0 []}';
  XC27602 ={'mo' 'XC27602' 0 []}';
  XC27702 ={'mo' 'XC27702' 0 []}';
  XC27802 ={'mo' 'XC27802' 0 []}';
  XC27900 ={'mo' 'XC27900' 0 []}';

  XC29092 ={'mo' '' 0 []}';
  XC28202 ={'mo' 'XC28202' 0 []}';
  XC28302 ={'mo' 'XC28302' 0 []}';
  XC28402 ={'mo' 'XC28402' 0 []}';
  XC29095 ={'mo' '' 0 []}';
  XC28502 ={'mo' 'XC28502' 0 []}';
  XC28602 ={'mo' 'XC28602' 0 []}';
  XC28702 ={'mo' 'XC28702' 0 []}';
  XC28802 ={'mo' 'XC28802' 0 []}';
  XC28900 ={'mo' 'XC28900' 0 []}';

  XC29202 ={'mo' 'XC29202' 0 []}';
  XC29302 ={'mo' 'XC29302' 0 []}';
  XC29402 ={'mo' 'XC29402' 0 []}';
  XC29502 ={'mo' 'XC29502' 0 []}';
  XC29602 ={'mo' 'XC29602' 0 []}';
  XC29702 ={'mo' 'XC29702' 0 []}';
  XC29802 ={'mo' 'XC29802' 0 []}';
  XC29900 ={'mo' 'XC29900' 0 []}';

  XC30202 ={'mo' 'XC30202' 0 []}';
  XC30302 ={'mo' 'XC30302' 0 []}';
  XC30402 ={'mo' 'XC30402' 0 []}';
  XC30502 ={'mo' 'XC30502' 0 []}';
  XC30602 ={'mo' 'XC30602' 0 []}';
  XC30702 ={'mo' 'XC30702' 0 []}';
  XC30802 ={'mo' 'XC30802' 0 []}';
  XC30900 ={'mo' 'XC30900' 0 []}';

% ==============================================================================
% YCORs
% ------------------------------------------------------------------------------

  YC24900 ={'mo' 'YC24900' 0 []}';       % fast-feedback (loop-3)

  YC25203 ={'mo' 'YC25203' 0 []}';
  YC25303 ={'mo' 'YC25303' 0 []}';
  YC25403 ={'mo' 'YC25403' 0 []}';
  YC25503 ={'mo' 'YC25503' 0 []}';       % fast-feedback (loop-3)
  YC25603 ={'mo' 'YC25603' 0 []}';
  YC25703 ={'mo' 'YC25703' 0 []}';
  YC25803 ={'mo' 'YC25803' 0 []}';
  YC25900 ={'mo' 'YC25900' 0 []}';

  YC26203 ={'mo' 'YC26203' 0 []}';
  YC26303 ={'mo' 'YC26303' 0 []}';
  YC26403 ={'mo' 'YC26403' 0 []}';
  YC26503 ={'mo' 'YC26503' 0 []}';
  YC26603 ={'mo' 'YC26603' 0 []}';
  YC26703 ={'mo' 'YC26703' 0 []}';
  YC26803 ={'mo' 'YC26803' 0 []}';
  YC26900 ={'mo' 'YC26900' 0 []}';

  YC27203 ={'mo' 'YC27203' 0 []}';
  YC27303 ={'mo' 'YC27303' 0 []}';
  YC27403 ={'mo' 'YC27403' 0 []}';
  YC27503 ={'mo' 'YC27503' 0 []}';
  YC27603 ={'mo' 'YC27603' 0 []}';
  YC27703 ={'mo' 'YC27703' 0 []}';
  YC27803 ={'mo' 'YC27803' 0 []}';
  YC27900 ={'mo' 'YC27900' 0 []}';

  YC29092 ={'mo' '' 0 []}';
  YC28203 ={'mo' 'YC28203' 0 []}';
  YC28303 ={'mo' 'YC28303' 0 []}';
  YC28403 ={'mo' 'YC28403' 0 []}';
  YC29095 ={'mo' '' 0 []}';
  YC28503 ={'mo' 'YC28503' 0 []}';
  YC28603 ={'mo' 'YC28603' 0 []}';
  YC28703 ={'mo' 'YC28703' 0 []}';
  YC28803 ={'mo' 'YC28803' 0 []}';
  YC28900 ={'mo' 'YC28900' 0 []}';

  YC29203 ={'mo' 'YC29203' 0 []}';
  YC29303 ={'mo' 'YC29303' 0 []}';
  YC29403 ={'mo' 'YC29403' 0 []}';
  YC29503 ={'mo' 'YC29503' 0 []}';
  YC29603 ={'mo' 'YC29603' 0 []}';
  YC29703 ={'mo' 'YC29703' 0 []}';
  YC29803 ={'mo' 'YC29803' 0 []}';
  YC29900 ={'mo' 'YC29900' 0 []}';

  YC30203 ={'mo' 'YC30203' 0 []}';
  YC30303 ={'mo' 'YC30303' 0 []}';
  YC30403 ={'mo' 'YC30403' 0 []}';
  YC30503 ={'mo' 'YC30503' 0 []}';
  YC30603 ={'mo' 'YC30603' 0 []}';
  YC30703 ={'mo' 'YC30703' 0 []}';
  YC30803 ={'mo' 'YC30803' 0 []}';
  YC30900 ={'mo' 'YC30900' 0 []}';

% ==============================================================================
% MARKERs
% ------------------------------------------------------------------------------

% profile monitors ("Decker screens")

  P30013 ={'mo' '' 0 []}';
  P30014 ={'mo' '' 0 []}';
  P30143 ={'mo' '' 0 []}';
  P30144 ={'mo' '' 0 []}';
  P30443 ={'mo' '' 0 []}';
  P30444 ={'mo' '' 0 []}';
  P30543 ={'mo' '' 0 []}';
  P30544 ={'mo' '' 0 []}';

% collimators

  C29096 ={'mo' 'C29096' 0 []}';
  C29146 ={'mo' 'C29146' 0 []}';
  C29446 ={'mo' 'C29446' 0 []}';
  C29546 ={'mo' 'C29546' 0 []}';
  C29956 ={'mo' 'C29956' 0 []}';
  C30146 ={'mo' 'C30146' 0 []}';
  C30446 ={'mo' 'C30446' 0 []}';
  C30546 ={'mo' 'C30546' 0 []}';

% miscellany

  PK297 ={'mo' '' 0 []}';
  PK299 ={'mo' '' 0 []}';
  PK303 ={'mo' '' 0 []}';
  PK304 ={'mo' '' 0 []}';

  IMBC2O ={'mo' 'IMBC2O' 0 []}'; %BC2 output toroid (comparator with IMBC2I)
  PH03   ={'mo' 'PH03'   0 []}'; %phase measurement RF cavity after BC2
  BL22   ={'mo' 'BL22'   0 []}'; %BC2+ (ceramic gap-based relative bunch length monitor)

  RWWAKEss={'mo' 'RWWAKEss' 0 []}';

% ==============================================================================
% BEAMLINEs
% ------------------------------------------------------------------------------

  K25_1 =[K25_1a1,XC24900,K25_1a2,YC24900,K25_1a3,K25_1b,D25_1c,K25_1d];
  K25_2 =[K25_2a1,XC25202,K25_2a2,YC25203,K25_2a3,K25_2b,K25_2c];
  K25_3 =[K25_3a1,XC25302,K25_3a2,YC25303,K25_3a3,K25_3b,K25_3c];
  K25_4 =[K25_4a1,XC25402,K25_4a2,YC25403,K25_4a3,K25_4b,K25_4c,K25_4d];
  K25_5 =[K25_5a1,XC25502,K25_5a2,YC25503,K25_5a3,K25_5b,K25_5c,K25_5d];
  K25_6 =[K25_6a1,XC25602,K25_6a2,YC25603,K25_6a3,K25_6b,K25_6c,K25_6d];
  K25_7 =[K25_7a1,XC25702,K25_7a2,YC25703,K25_7a3,K25_7b,K25_7c,K25_7d];
  K25_8 =[K25_8a1,XC25802,K25_8a2,YC25803,K25_8a3,K25_8b,K25_8c, ...
                K25_8d1,XC25900,K25_8d2,YC25900,K25_8d3];

  LI25  =[LI25beg,ZLIN09, ...
                K25_1,DAQ1,Q25201,BPM25201,Q25201,DAQ2, ...
                K25_2,D255a,IMBC2O,D255b,D255c,TCAV3,TCAV3, ...
                D255d,Q25301,BPM25301,Q25301,DAQ2, ...
                K25_3,D256a,PH03,D256b,BL22,D256c, ...
                BXKIKA,BXKIKB,D256d,DAQ1,Q25401,BPM25401,Q25401,DAQ2, ...
                K25_4,DAQ1,Q25501,BPM25501,Q25501,DAQ2, ...
                K25_5,DAQ1,Q25601,BPM25601,Q25601,DAQ2, ...
                K25_6,DAQ1,Q25701,BPM25701,Q25701,DAQ2, ...
                K25_7,DAQ1,Q25801,BPM25801,Q25801,DAQ2, ...
                K25_8,DAQ7,Q25901,BPM25901,Q25901,DAQ8A,OTR_TCAV,DAQ8B, ...
                LI25end];

% ------------------------------------------------------------------------------

  K26_1 =[K26_1a,K26_1b,K26_1c,K26_1d];
  K26_2 =[K26_2a1,XC26202,K26_2a2,YC26203,K26_2a3,K26_2b,K26_2c,K26_2d];
  K26_3 =[K26_3a1,XC26302,K26_3a2,YC26303,K26_3a3,K26_3b,K26_3c,K26_3d];
  K26_4 =[K26_4a1,XC26402,K26_4a2,YC26403,K26_4a3,K26_4b,K26_4c,K26_4d];
  K26_5 =[K26_5a1,XC26502,K26_5a2,YC26503,K26_5a3,K26_5b,K26_5c,K26_5d];
  K26_6 =[K26_6a1,XC26602,K26_6a2,YC26603,K26_6a3,K26_6b,K26_6c,K26_6d];
  K26_7 =[K26_7a1,XC26702,K26_7a2,YC26703,K26_7a3,K26_7b,K26_7c,K26_7d];
  K26_8 =[K26_8a1,XC26802,K26_8a2,YC26803,K26_8a3,K26_8b,K26_8c, ...
                K26_8d1,XC26900,K26_8d2,YC26900,K26_8d3];

  LI26  =[LI26beg,ZLIN10, ...
                K26_1,DAQ1,Q26201,BPM26201,Q26201,DAQ2, ...
                K26_2,DAQ1,Q26301,BPM26301,Q26301,DAQ2, ...
                K26_3,DAQ1,Q26401,BPM26401,Q26401,DAQ2, ...
                K26_4,DAQ1,Q26501,BPM26501,Q26501,DAQ2, ...
                K26_5,DAQ1,Q26601,BPM26601,Q26601,DAQ2, ...
                K26_6,DAQ1,Q26701,BPM26701,Q26701,DAQ2, ...
                K26_7,DAQ1,Q26801,BPM26801,Q26801,DAQ2, ...
                K26_8,DAQ7,Q26901,BPM26901,Q26901,DAQ8, ...
                LI26end];

% ------------------------------------------------------------------------------

  K27_1 =[K27_1a,K27_1b,K27_1c,K27_1d];
  K27_2 =[K27_2a1,XC27202,K27_2a2,YC27203,K27_2a3,K27_2b,K27_2c,K27_2d];
  K27_3 =[K27_3a1,XC27302,K27_3a2,YC27303,K27_3a3,K27_3b,K27_3c,K27_3d];
  K27_4 =[K27_4a1,XC27402,K27_4a2,YC27403,K27_4a3,K27_4b,K27_4c,K27_4d];
  K27_5 =[K27_5a1,XC27502,K27_5a2,YC27503,K27_5a3,K27_5b,K27_5c,K27_5d];
  K27_6 =[K27_6a1,XC27602,K27_6a2,YC27603,K27_6a3,K27_6b,K27_6c];
  K27_7 =[K27_7a1,XC27702,K27_7a2,YC27703,K27_7a3,K27_7b,K27_7c,K27_7d];
  K27_8 =[K27_8a1,XC27802,K27_8a2,YC27803,K27_8a3,K27_8b,K27_8c, ...
                K27_8d1,XC27900,K27_8d2,YC27900,K27_8d3];

  LI27  =[LI27beg,ZLIN11, ...
                K27_1,DAQ1,Q27201,BPM27201,Q27201,DAQ2, ...
                K27_2,DAQ1,Q27301,BPM27301,Q27301,DAQ2, ...
                K27_3,DAQ1,Q27401,BPM27401,Q27401,DAQ2, ...
                K27_4,DAQ1,Q27501,BPM27501,Q27501,DAQ2, ...
                K27_5,DAQ1,Q27601,BPM27601,Q27601,DAQ2, ...
                K27_6,DAQ5A,WS27644,DAQ6A,Q27701,BPM27701,Q27701,DAQ2, ...
                K27_7,DAQ1,Q27801,BPM27801,Q27801,DAQ2, ...
                K27_8,DAQ7,Q27901,BPM27901,Q27901,DAQ8, ...
                LI27end];

% ------------------------------------------------------------------------------

  K28_1 =[K28_1a,K28_1b,K28_1c];
  K28_2 =[K28_2a1,XC28202,K28_2a2,YC28203,K28_2a3,K28_2b,K28_2c,K28_2d];
  K28_3 =[K28_3a1,XC28302,K28_3a2,YC28303,K28_3a3,K28_3b,K28_3c,K28_3d];
  K28_4 =[K28_4a1,XC28402,K28_4a2,YC28403,K28_4a3,K28_4b,K28_4c];
  K28_5 =[K28_5a1,XC28502,K28_5a2,YC28503,K28_5a3,K28_5b,K28_5c,D28_5d];
  K28_6 =[K28_6a1,XC28602,K28_6a2,YC28603,K28_6a3,K28_6b,K28_6c,K28_6d];
  K28_7 =[K28_7a1,XC28702,K28_7a2,YC28703,K28_7a3,K28_7b,K28_7c];
  K28_8 =[K28_8a1,XC28802,K28_8a2,YC28803,K28_8a3,K28_8b,K28_8c, ...
                K28_8d1,XC28900,K28_8d2,YC28900,K28_8d3];

  LI28  =[LI28beg,ZLIN12, ...
                K28_1,DAQ5B1,XC29092,DAQ5B2,YC29092,DAQ5B3,WS28144,DAQ6B, ...
                Q28201,BPM28201,Q28201,DAQ2, ...
                K28_2,DAQ1,Q28301,BPM28301,Q28301,DAQ2, ...
                K28_3,DAQ1,Q28401,BPM28401,Q28401,DAQ2, ...
                K28_4,DAQ5C1,XC29095,DAQ5C2,YC29095,DAQ5C3,WS28444,DAQ6C, ...
                Q28501,BPM28501,Q28501,DAQ2, ...
                K28_5,DAQ1,Q28601,BPM28601,Q28601,DAQ2, ...
                K28_6,DAQ1,Q28701,BPM28701,Q28701,DAQ2, ...
                K28_7,DAQ5D,WS28744,DAQ6D,Q28801,BPM28801,Q28801,DAQ2, ...
                K28_8,DAQ7,Q28901,BPM28901,Q28901,DAQ8C,C29096,DAQ8D, ...
                LI28end];

% ------------------------------------------------------------------------------

  K29_1 =[K29_1a,K29_1b,K29_1c];
  K29_2 =[K29_2a1,XC29202,K29_2a2,YC29203,K29_2a3,K29_2b,K29_2c,K29_2d];
  K29_3 =[K29_3a1,XC29302,K29_3a2,YC29303,K29_3a3,K29_3b,K29_3c,K29_3d];
  K29_4 =[K29_4a1,XC29402,K29_4a2,YC29403,K29_4a3,K29_4b,K29_4c];
  K29_5 =[K29_5a1,XC29502,K29_5a2,YC29503,K29_5a3,K29_5b,K29_5c];
  K29_6 =[K29_6a1,XC29602,K29_6a2,YC29603,K29_6a3,K29_6b,K29_6c,K29_6d];
  K29_7 =[K29_7a1,XC29702,K29_7a2,YC29703,K29_7a3,K29_7b,K29_7c,K29_7d];
  K29_8 =[K29_8a1,XC29802,K29_8a2,YC29803,K29_8a3,K29_8b,K29_8c, ...
                K29_8d1,XC29900,K29_8d2,YC29900,K29_8d3];

  LI29  =[LI29beg,ZLIN13, ...
                K29_1,D10CA,C29146,D10CB,DAQ1,Q29201,BPM29201,Q29201,DAQ2, ...
                K29_2,DAQ1,Q29301,BPM29301,Q29301,DAQ2, ...
                K29_3,DAQ1,Q29401,BPM29401,Q29401,DAQ2, ...
                K29_4,D10CC,C29446,D10CD,DAQ1,Q29501,BPM29501,Q29501,DAQ2, ...
                K29_5,D10CE,C29546,D10CF,DAQ1,Q29601,BPM29601,Q29601,DAQ2, ...
                K29_6,DAQ1,Q29701,BPM29701,Q29701,DAQ2, ...
                K29_7,DAQ9A,PK297,DAQ9B,Q29801,BPM29801,Q29801,DAQ2, ...
                K29_8,DAQ3,Q29901,BPM29901,Q29901,DAQ4A,P30013,DAQ4B,P30014, ...
                DAQ4C,C29956,DAQ4D,PK299,DAQ4E, ...
                LI29end];

% ------------------------------------------------------------------------------

  K30_1 =[K30_1a,K30_1b,K30_1c,K30_1d];
  K30_2 =[K30_2a1,XC30202,K30_2a2,YC30203,K30_2a3,K30_2b,K30_2c,K30_2d];
  K30_3 =[K30_3a1,XC30302,K30_3a2,YC30303,K30_3a3,K30_3b,K30_3c,K30_3d];
  K30_4 =[K30_4a1,XC30402,K30_4a2,YC30403,K30_4a3,K30_4b,K30_4c,K30_4d];
  K30_5 =[K30_5a1,XC30502,K30_5a2,YC30503,K30_5a3,K30_5b,K30_5c,K30_5d];
  K30_6 =[K30_6a1,XC30602,K30_6a2,Q30615A,K30_6a3,YC30603,K30_6a4, ...
                Q30615B,K30_6a5,Q30615C,K30_6a6,K30_6b,K30_6c,K30_6d];
  K30_7 =[K30_7a1,XC30702,K30_7a2,Q30715A,K30_7a3,YC30703,K30_7a4, ...
                Q30715B,K30_7a5,Q30715C,K30_7a6,K30_7b,K30_7c,K30_7d];
%  K30_6 =[K30_6a1,XC30602,K30_6a2,DAQW,Q30615A,Q30615A,DAQW, ...
%                K30_6a3,YC30603,K30_6a4,DAQW,Q30615B,Q30615B,DAQW, ...
%                                K30_6a5,DAQW,Q30615C,Q30615C,DAQW, ...
%                K30_6a6,K30_6b,K30_6c,K30_6d];
%  K30_7 =[K30_7a1,XC30702,K30_7a2,DAQW,Q30715A,Q30715A,DAQW, ...
%                K30_7a3,YC30703,K30_7a4,DAQW,Q30715B,Q30715B,DAQW, ...
%                                K30_7a5,DAQW,Q30715C,Q30715C,DAQW, ...
%                K30_7a6,K30_7b,K30_7c,K30_7d];
  K30_8 =[K30_8a1,XC30802,K30_8a2,YC30803,K30_8a3,K30_8b,K30_8c1,YC30900, ...
                K30_8c2,XC30900,K30_8c3];

  LI30  =[LI30beg,ZLIN14, ...
                K30_1,DAQ10A,P30143,DAQ10B,P30144,DAQ10C,C30146,DAQ10D, ...
                Q30201,BPM30201,Q30201,DAQ2, ...
                K30_2,DAQ1,Q30301,BPM30301,Q30301,DAQ2, ...
                K30_3,DAQ10E,PK303,DAQ10F,Q30401,BPM30401,Q30401,DAQ2, ...
                K30_4,DAQ10G,P30443,DAQ10H,P30444,DAQ10I,C30446,DAQ10J, ...
                PK304,DAQ10K,Q30501,BPM30501,Q30501,DAQ2, ...
                K30_5,DAQ11A,P30543,DAQ11B,P30544,DAQ11C,C30546,DAQ11D, ...
                Q30601,BPM30601,Q30601,DAQ12, ...
                K30_6,DAQ13,Q30701,BPM30701,Q30701,DAQ14, ...
                K30_7,DAQ15,Q30801,BPM30801,Q30801,DAQ16, ...
                K30_8,DAQ17, ...
                LI30end];

% ==============================================================================

  L3 =[L3beg,LI25,LI26,LI27,LI28,LI29,LI30,L3end,RWWAKEss,DBMARK29];

LINE=L3;

beamLine=LINE';
