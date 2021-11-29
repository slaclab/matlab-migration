function beamLine=model_beamLineLCLS2cu()
%
% -----------------------------------------------------------------------------
% *** OPTICS=AD_ACCEL-13JUN19 ***
% -----------------------------------------------------------------------------
%
% Returns Matlab model beam lines that correspond to defined AD_ACCEL
% room temperture Cu linac beampaths:
%
%  beamLine.CU_GSPEC = gun to 6 MeV spectrometer FARC (was 'GS' in LCLS)
%  beamLine.CU_SPEC  = gun to 135 MeV spectrometer beam dump (was 'SP' in LCLS)
%  beamLine.CU_HXR   = gun to HXR beam dump (was 'FullMachine' in LCLS)
%  beamLine.CU_ALINE = gun to End Station A
%  beamLine.CU_SXR   = gun to SXR beam dump
%
% -----------------------------------------------------------------------------
%

global SETCUS SETAL ROLLON EBC2 EF EU

SETCUS = 0;SETAL = 0;ROLLON = 0;EBC2 = 4.3;EF = 13.64;EU = 13.64;
[DL1_1,GSPEC,GUNBXG,GUNL0A,L0B,LCLS2CUA,LCLS2CUH,LCLS2CUS,SPECBL]=bl();
beamLine.CU_HXR=[GUNL0A,L0B,LCLS2CUH]';
beamLine.CU_HXR=SETK2CUH(beamLine.CU_HXR);

SETCUS = 1;SETAL = 0;ROLLON = 0;EBC2 = 3.0;EF = 4.0;EU = 4.0;
[DL1_1,GSPEC,GUNBXG,GUNL0A,L0B,LCLS2CUA,LCLS2CUH,LCLS2CUS,SPECBL]=bl();
beamLine.CU_SXR=[GUNL0A,L0B,LCLS2CUS]';
beamLine.CU_SXR=SETK2CUS(beamLine.CU_SXR);
beamLine.CU_SXR=SETCU4GEV(beamLine.CU_SXR);
SETCUS = 0;SETAL = 1;ROLLON = 1;EBC2 = 4.3;EF = 13.64;EU = 13.64;
[DL1_1,GSPEC,GUNBXG,GUNL0A,L0B,LCLS2CUA,LCLS2CUH,LCLS2CUS,SPECBL]=bl();
beamLine.CU_ALINE=[GUNL0A,L0B,LCLS2CUA]';
beamLine.CU_ALINE=SETK2CUA(beamLine.CU_ALINE);

SETCUS = 0;SETAL = 0;ROLLON = 0;EBC2 = 4.3;EF = 13.64;EU = 13.64;
[DL1_1,GSPEC,GUNBXG,GUNL0A,L0B,LCLS2CUA,LCLS2CUH,LCLS2CUS,SPECBL]=bl();
beamLine.CU_GSPEC=[GUNBXG,GSPEC]';


SETCUS = 0;SETAL = 0;ROLLON = 0;EBC2 = 4.3;EF = 13.64;EU = 13.64;
[DL1_1,GSPEC,GUNBXG,GUNL0A,L0B,LCLS2CUA,LCLS2CUH,LCLS2CUS,SPECBL]=bl();
beamLine.CU_SPEC=[GUNL0A,L0B,DL1_1,SPECBL]';



function [DL1_1,GSPEC,GUNBXG,GUNL0A,L0B,LCLS2CUA,LCLS2CUH,LCLS2CUS,SPECBL]=bl()

global SETCUS SETAL ROLLON EBC2 EF EU


PI     = pi;
TWOPI  = 2*pi;
DEGRAD = 180/pi;
RADDEG = pi/180;
E      = exp(1);
EMASS  = 0.510998902e-3; % electron rest mass [GeV]
PMASS  = 0.938271998;    % proton rest mass [GeV]
CLIGHT = 2.99792458e8;   % speed of light [m/s]
%copper linac
% *** OPTICS=AD_ACCEL-13JUN19 ***



% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 22-JAN-2016, M. Woodley
%  * start LCLS2cuS at CATHODE; EBC2=3.0, Ef=4.0 (Eu=4.0)
%  * add SETcu4GeV to rematch through lower energy linac
%  * modify color plots for LCLS2cuS
% ------------------------------------------------------------------------------
% 30-OCT-2018, M. Woodley
%  * set IntgSX= 20 kG (was 30 kG) for 4 GeV beam (cuS and scS optics identical
%    downstream of QDL11)
% ------------------------------------------------------------------------------
% 19-JUL-2017, M. Woodley
%  * structural changes in deck to accomodate MAD-to-BMAD
% ------------------------------------------------------------------------------
% 01-MAR-2017, M. Woodley
%  * WS24 is actually installed (per LCLS)
% ------------------------------------------------------------------------------
% 25-SEP-2015, Y. Nosochkov
%  * rename LCLS1AL to LCLS2cuAL
%  * load ALINE.xsif before LTU.xsif
%  * load SPRD.xsif
% 24-AUG-2015, Y. Nosochkov
%  * see list of changes in .xsif files
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * see list of changes in .xsif files and in file MADdeckChanges.pdf
% ------------------------------------------------------------------------------
% 12-MAR-2015, Y. Nosochkov
%  * remove PCTDKIK1-4 collimators in BSY1 (per S. Mao)
%  * use kicker/septum or pulsed magnets to connect BSY with the A-line
%  * add CUSXR beamline for transport from Cu-linac to SXR
% ------------------------------------------------------------------------------
% 09-DEC-2014, Y. Nosochkov
%  * update initial Twiss and survey coordinates at BSYBEG (BEGBSY1)
% ------------------------------------------------------------------------------
% 28-OCT-2014, M. Woodley
%  * redefine DBMARK29 to be LI30 IV30-9 (Z=3042.005)
% ------------------------------------------------------------------------------
% 15-SEP-2014, Y. Nosochkov
%  * designate BSY1 line connecting the end of LCLS1 L3 with the beginning of
%    LCLS2 HXR merge bend BXSP1h
% 02-MAY-2014, Y. Nosochkov
%  * rematch HXR undulator for 13.64 GeV and 40 kG quad integral field
% 18-APR-2014, Y. Nosochkov
%  * combine upstream LCLS1 lattice with downstream LCLS2scH lattice
% ==============================================================================
% ==============================================================================
% Beamline area names (see LCLSII-2.1-PR-0134)
%   https://docs.slac.stanford.edu/sites/pub/Publications/
%   Beamline Boundaries.pdf
% ------------------------------------------------------------------------------
% Cu linac common areas
% ------------------------------------------------------------------------------
% GUN    : cathode to BXG u/s face
% L0     : L0A and L0B
% DL1_1  : laser heater, diagnostics, matching
% DL1_2  : injection into main linac
% L1     : L1 linac (21-1b,c,d)
% BC1    : L1X and BC1 chicane
% L2     : L2 linac (21-3, LI22, LI23, LI24->24-6)
% BC2    : BC2 chicane
% L3     : L2 linac (LI25, LI26, LI27, LI28, LI29, LI30->30-8c)
% CLTH_0 : end of linac sector 30 to start of BSY (wooden door)
% CLTH_1 : start of BSY to CUSXR kicker
% ------------------------------------------------------------------------------
% Cu linac to HXR areas
% ------------------------------------------------------------------------------
% CLTH_2 : CUSXR kickers to Cu/SC linac merge (HXR line)
% BSYH_1 : Cu/SC linac merge to A-line kickers
% BSYH_2 : A-line kickers to end of BSY
% LTUH   : HXR LTU (from end of BSY)
% UNDH   : HXR undulator
% DMPH_1 : HXR post-undulator line
% DMPH_2 : HXR dump line
% SFTH_1 : BYDSH u/s face to BXPM1 u/s face
% SFTH_2 : BXPM1 u/s face to HXR safety dump
% HXTES  : BXPM1 u/s face to HXR XTES (BSY coordinate SURVEY only)
% ------------------------------------------------------------------------------
% Cu linac to SXR areas
% ------------------------------------------------------------------------------
% CUSXR  : CUSXR kicker to Cu/SC linac merge
% BSYS   : Cu/SC merge to end of BSY
% LTUS   : SXR LTU (from end of BSY)
% UNDS   : SXR extension + SXR undulator
% DMPS_1 : SXR post-undulator line
% DMPS_2 : SXR dump line
% SFTS_1 : BYDSS u/s face to BXPM1B u/s face
% SFTS_2 : BXPM1B u/s face to SXR safety dump
% SXTES  : BXPM1B u/s face to SXR XTES (BSY coordinate SURVEY only)
% ------------------------------------------------------------------------------
% Cu linac to other areas
% ------------------------------------------------------------------------------
% GSPEC  : 6 MeV spectrometer
% SPEC   : 135 MeV spectrometer
% BSYA_1 : A-line kickers to A-line merge
% BSYA_2 : A-line merge to Beam Dump East
% ==============================================================================
% ------------------------------------------------------------------------------
% deflector switch definitions
% ------------------------------------------------------------------------------
SETSP =  0 ;%deflector switch for HXR/SXR/BSYD spreader


SETDA =  0 ;%deflector switch for BSYD/DASEL
SETXLEAP2 =  0 ;%selector switch for XLEAP-II components
SETHXRSS =  0 ;%ON/OFF switch for HXR self-seeding chicane
SETSXRSS =  0 ;%ON/OFF switch for SXR self-seeding chicane
% ------------------------------------------------------------------------------
% integrated gradients for undulator quadrupoles
% ------------------------------------------------------------------------------
INTGSX =  20.0 ;%kG (30.0)
INTGHX =  40.0 ;%kG
EBC2CU =   4.300 ;%nominal BC2 beam energy for copper (Cu) linac (GeV)
EFCU =  13.640 ;%nominal final beam energy from copper (Cu) linac (GeV)
EUCU =  13.640 ;%nominal beam energy in undulator (GeV)
% ------------------------------------------------------------------------------
% element and line definitions
% ------------------------------------------------------------------------------
% *** OPTICS=AD_ACCEL-13JUN19 ***
% ------------------------------------------------------------------------------
% constants and global parameters
% ------------------------------------------------------------------------------
% constants
CB=1.0E10/CLIGHT;%energy to magnetic rigidity
GEV2MEV=1000.0;%GeV to MeV
IN2M=0.0254;%inches to meters
MC2=510.99906E-6;%e- rest mass [GeV]
% initial conditions (exit of L0)
INJDEG =  -35.0    ;%injector bend angle w.r.t. linac [degrees]
E00 =  0.006    ;%beam energy after gun (GeV)
E0I =  0.064    ;%beam energy between L0a and L0b sections (GeV)
EI =  0.135    ;%initial beam energy (GeV) (150->135 MeV on July 9, 2003)
EBC1 =  0.250    ;%BC1 energy (GeV)



EMITXN =  1.00E-06 ;%normalized horizontal emittance (m)
EMITYN =  1.00E-06 ;%normalized vertical emittance (m)
BLENG =  0.83E-03 ;%bunch length (m)
ESPRD =  2.00E-05 ;%slice rms energy spread at 135 MeV (1)
ZOFFINJ =  0.012100 ;%moves entire injector in main-linac z-direction by this amount (+12.100 mm Nov. 17, 2004)
XOFF =  -25.610*IN2M ;%x-offset of bypass line (old PEP-II 9-GeV) w.r.t. old linac axis (<0 is south)
YOFF =   25.570*IN2M ;%y-offset of bypass line (old PEP-II 9-GeV) w.r.t. old linac axis(>0 is up)
% miscellaneous parameters
BRHOF =  CB*EF;
% ------------------------------------------------------------------------------
% twiss parameter definitions
% ------------------------------------------------------------------------------
% twiss parameters at L0a-exit:
TBETX =   1.410  ;%twiss beta x (m)   back-tracked from measured/matched OTR2 through post Aug. 11, 2008 QA01-QE04 real BDES settings
TALFX =  -2.613  ;%twiss alpha x
TBETY =   6.706  ;%twiss beta y (m)
TALFY =   0.506  ;%twiss alpha y
% Dummy, fitted twiss parameters at cathode which yield the above twiss parameters at
% L0a-exit (for plotting purposes only - assumes only drift between cathode and L0a-exit)
CBETX =   15.574222013212  ;% consistent with back-tracked from matched OTR2 through post Aug. 11, 2008 QA01-QE04 real BDES
CALFX =   -3.081460532254;
CBETY =   0.390930039559;
CALFY =   0.551432669489E-2;
% initial Twiss for SXR dogleg cells for Cu-linac beam (at DBMARK34B)
MBETXCUS =  14.230935994022 ;%14.265662820746
MALFXCUS =  -0.492407537024 ;%-0.492521160533
MBETYCUS =  41.635541126271 ;%41.585692319056
MALFYCUS =   2.277864883454 ;% 2.277903990577
% periodic Twiss in HXR dogleg cells (copy from LCLS2sc_main.mad8)
MBETXH =  48.881918788199;
MALFXH =   3.139871668464;
MBETYH =  96.323786537904;
MALFYH =   3.616905252587;
% Twiss at the beginning of L3 linac
ENBEGL3 =   4.3;
BXBEGL3 =   1.106003893E+01;
AXBEGL3 =  -9.490138298E-01;
BYBEGL3 =   7.102804796E+01;
AYBEGL3 =   2.204492752E+00;
% Twiss at the end of L3 linac (L3END)
ENENDL3 =  13.64;
BXENDL3 =  33.136631364328;
AXENDL3 =   1.179540229644;
BYENDL3 =  62.298526576063;
AYENDL3 =  -1.660316777995;
% for matching ...
BET11 =  10.090395936353;
BET12 =  2.470673595371;
BET21 =  43.876719659503;
BET22 =  16.019619746515;
%BET31 := 53.481287866029
%BET32 := 35.468087644847
%BET33 := 29.55797372867
%BET34 := 63.601589300188
BET31 =  61.868125327071;
BET32 =  36.40742728964;
BET33 =  36.353377790534;
BET34 =  61.956709274457;
%BET31 := 69.818359882868   for WS28 45 deg/wire
%BET32 := 37.0062095289
%BET33 := 42.5680425597
%BET34 := 60.952049693321
% linac phase advances
MU_L1 =  75/360;
MU_L2 =  55.500/360;
MUX_L3 =  30.175/360 ;%July 13, 2008 - set for best WS28 45-deg mux phase advances
MUY_L3 =  30.130/360 ;%July 13, 2005 - set for 3*90 deg TCAV3[1] to OTR30 (TCAV3 -> 25-2d)
% ------------------------------------------------------------------------------
% beam definitions
% ------------------------------------------------------------------------------
% input beam definition (at L0a-exit)
EMITX =   EMITXN/(E0I/EMASS);
EMITY =   EMITYN/(E0I/EMASS);
TGAMX =   (1+TALFX*TALFX)/TBETX;
TGAMY =   (1+TALFY*TALFY)/TBETY;
SIG11 =   EMITX*TBETX;
SIG21 =  -EMITX*TALFX;
SIG22 =   EMITX*TGAMX;
SIG33 =   EMITY*TBETY;
SIG43 =  -EMITY*TALFY;
SIG44 =   EMITY*TGAMY;
C21 =   SIG21/sqrt(SIG11*SIG22);
C43 =   SIG43/sqrt(SIG33*SIG44);
% input beam definition (at cathode)
CGAMX =   (1+CALFX*CALFX)/CBETX;
CGAMY =   (1+CALFY*CALFY)/CBETY;
SIG11C =   EMITX*CBETX;
SIG21C =  -EMITX*CALFX;
SIG22C =   EMITX*CGAMX;
SIG33C =   EMITY*CBETY;
SIG43C =  -EMITY*CALFY;
SIG44C =   EMITY*CGAMY;
C21C =   SIG21C/sqrt(SIG11C*SIG22C);
C43C =   SIG43C/sqrt(SIG33C*SIG44C);
% ------------------------------------------------------------------------------
% Database MARKer point definitions
% ------------------------------------------------------------------------------
DBMARK80={'mo' 'DBMARK80' 0 []}';%(LCLS GUN) RF gun cathode
DBMARK81={'mo' 'DBMARK81' 0 []}';%(BXG_entr) entrance of BXG
DBMARK97={'mo' 'DBMARK97' 0 []}';%(GUNSPECT) 6 MeV gun spectrometer dump
DBMARK82={'mo' 'DBMARK82' 0 []}';%(BX01entr) entrance of BX01
DBMARK98={'mo' 'DBMARK98' 0 []}';%(135SPECT) 135-MeV spect. dump
DBMARK83={'mo' 'DBMARK83' 0 []}';%(BX02exit) exit of BX02 ... LCLS injection point
DBMARK28={'mo' 'DBMARK28' 0 []}';%(QM15exit) exit of QM15 ... just after TD11
DBMARK29={'mo' 'DBMARK29' 0 []}';%(IV30-9  ) LI30 isolation valve ... start of BSY
% ------------------------------------------------------------------------------
% load lattice definitions
% ------------------------------------------------------------------------------
% LCLS2scH and LCLS1 optics
% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc common parameters
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 30-JAN-2019, M. Woodley
%  * add area BEG/END MARKers for the Cu-linac (u/s of BSY)
% ------------------------------------------------------------------------------
% 31-OCT-2018, Y. Nosochkov
%  * adjust ABRDAS2, TBRDAS2 for DASEL optics with 25G kicker field
% 19-SEP-2018, M. Woodley
%  * add LPCTDKIK definition
% 30-MAY-2018, M. Woodley
%  * add self-seeding chicane ON/OFF switch definitions
% 16-MAY-2018, M. Woodley
%  * add narrow-frame SLTR QF1545 quadrupole type
% ------------------------------------------------------------------------------
% 24-JAN-2018, M. Woodley
%  * change length of BCS protection collimators (PCs) in spreader from 30 cm
%    to 5.08 cm (2")
% 05-DEC-2017, M. Woodley
%  * add BEGHXTES, ENDHXTES, BEGSXTES, ENDSXTES MARKers
% 06-SEP-2017, Y. Nosochkov
%  * update spreader kicker gap GBKSP to 20 mm (= 10 mm beam aperture +
%    10 mm pipe walls) (T. Beukers)
% 22-AUG-2017, M. Woodley
%  * add low-energy dump line (area=SLTDX)
%  * split SLTS and SLTD areas
% ------------------------------------------------------------------------------
% 28-NOV-2016, M. Woodley
%  * replace BEGCOL2/ENDCOL2 with BEGEMIT2/ENDEMIT2
% ------------------------------------------------------------------------------
% 04-NOV-2016, M. Woodley
%  * change "1.259Q3.5" to "1.26Q3.5"
%  * change Everson-Tesla 2.362Q3.5 (r=30mm) to SigmaPhi 1.69Q3.4 (bore=43mm)
% 02-NOV-2016, Y. Nosochkov
%  * move definition of DRFB drift to LTU.xsif
%  * remove no longer used definition of SPhOFF
%  * add markers BEGSPD3, ENDSPD3
%  * add kicker switches for DASEL
% 30-SEP-2016, Y. Nosochkov
%  * add some missing GLmax data (per J. Amann)
% ------------------------------------------------------------------------------
% 12-FEB-2016, M. Woodley
%  * add FFTB sextupole definitions (for 2nd-order dispersion correction)
% ------------------------------------------------------------------------------
% 01-OCT-2015, M. Woodley
%  * add SETDG0 ... switch beam between straight-ahead (DG0OFF) and DIAG0 line
%    (DG0ON)
% 25-SEP-2015, Y. Nosochkov
%  * add deflector switches for CUSXR and A-line
% 28-AUG-2015, M. Woodley
%  * add GLmax comment for 2Q4 ("QM")
%  * replace "Qs" definitions with  SLC positron inflector (LI01) quadrupole
%    definitions
% 24-AUG-2015, Y. Nosochkov
%  * specify gap height and length of fast kickers and septa
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * restore definition of 1.97Q20 quadrupole
% ------------------------------------------------------------------------------
% 16-APR-2015, M. Woodley
%  * restore "LQL" parameter (used in SPRD.xsif)
% 20-MAR-2015, M. Woodley
%  * remove 1.97Q10 and 1.97Q20 quadrupole definitions (replaced with 2Q10s)
%  * set length of tungsten jaw collimators (15*X0; X0(W)= 4 mm; Ljaw = 6 cm)
%  * add SEQ20BEG, SEQ20END, BEGCuSXR, ENDCuSXR MARKERs (for LCLS1 to SXR line)
%  * add SEQ21BEG, SEQ21END, BEGBSYA, ENDBSYA MARKERs (for BSY to A-line)
% ------------------------------------------------------------------------------
% 12-DEC-2014, M. Woodley
%  * add PEPII "2Q10" quadrupole type
%  * add area and SEQ BEG/END MARKers for safety dump lines
% 09-DEC-2014, Y. Nosochkov
%  * specify a preliminary length of protection collimators in the spreader
% 19-NOV-2014, Y. Nosochkov
%  * specify type of undulator quadrupole (per J. Amann)
% ------------------------------------------------------------------------------
% 28-OCT-2014, M. Woodley
%  * add SEQ17BEG, SEQ17END, BSY1BEG, BSY1END MARKERs (for LCLS1 BSY)
% ------------------------------------------------------------------------------
% 15-OCT-2014, M. Woodley
%  * add R56 compensation chicane parameters
% ------------------------------------------------------------------------------
% ==============================================================================
% magnets
% ------------------------------------------------------------------------------
% LCLS2 quadrupoles
% QK : 1.625Q27.3
% QA : 1.26Q12 (NOTE: bore of captured BPM is 0.870")
% Qu : undulator quadrupole (0.433Q3.1)
LQK =  0.7142  ;
RQK =  1.625*IN2M/2 ;%GLmax=   ?   kG @   ? A
LQA =  0.32    ;
RQA =  0.016        ;%GLmax= 112   kG @ 120 A
LQU =  0.084   ;
RQU =  0.0055       ;%GLmax=  41.8 kG @   6 A
% LCLS quadrupoles
% Qx  : Everson-Tesla quadrupole (1.26Q3.5)
% Qc  : SigmaPhi "tweaker" quadrupole (1.69Q3.4)
% QsB : "Bertsche" skew quadrupole
LQX =  0.108 ;
RQX =  0.016    ;%GLmax= 20.0 kG @ 12 A
LQC =  0.108 ;
RQC =  0.043/2  ;%GLmax=  2.1 kG @ 12 A
LQSB =  0.16  ;
RQSB =  0.06     ;%GLmax=  1.3 kG @ 12 A
% PEP-II quadrupoles
% QM : PEPII injection quadrupole (2Q4)
% QP : PEPII LER quadrupole (3.94Q17)
% QR : PEPII injection quadrupole (2Q10)
% QN : PEPII injection "50Q" quadrupole (1.97Q20)
LQM =  0.1244 ;
RQM =  0.0269 ;%GLmax= 6.75 kG @  45 A; GLmax= 27 kG for 2Q4W
LQP =  0.43   ;
RQP =  0.05   ;%GLmax= 44.6 kG @ 178 A
LQR =  0.263  ;
RQR =  0.0257 ;%GLmax= 50   kG @ 160 A
LQN =  0.542  ;
RQN =  0.025  ;%GLmax= 78   kG @   ? A
% FFTB quadrupoles
% QF : FFTB "Russian" quad 0.91Q17.72
% QD : FFTB dump quad (3.25Q20)
LQF =  0.46092 ;
RQF =  0.023/2   ;%GLmax= 386.8 kG @ 240 A
LQD =  0.55    ;
RQD =  0.08255/2 ;%GLmax=  74.7 kG @  35 A
% SLC quadrupoles
% QE : linac QE4 (1.085Q4.31)
% Qs : LI01 positron inflector type
% QW : "wraparound" type (4.63Q8.0; i.e. SLTR QWF1015)
% Qz : special narrow quad (SLTR QF1545)
LQE =  0.1068  ;
RQE =  1.085*IN2M/2 ;%GLmax= 106   kG @ 220 A
%LQs := 0.09181 ; rQs := 1.013*in2m/2 GLmax=  52   kG @ 207 A
LQS =  0.197   ;
RQS =  1.510*IN2M/2 ;%GLmax=  31   kG @  90 A
LQW =  0.248   ;
RQW =  4.625*IN2M/2 ;%GLmax=  16.5 kG @  50 A
LQZ =  0.09181 ;
RQZ =  1.013*IN2M/2 ;%GLmax=  63.8 kG @ 160 A
% R56 compensation chicanes (0.788D11.50):
%   GBCC = bend magnet full gap height (m)
%   ZBCC = bend magnet Z-length (m)
%   FBCC = average measured bend magnet FINT value (m)
%   ZDCC = Z-space between magnets (m)
GBCC =  0.032;
ZBCC =  0.35;
FBCC =  0.8436;
ZDCC =  0.2;
% FFTB sextupoles
% Sa : 2.13S3.00
% Sb : 1.38S3.00
LSA =  0.1 ;
RSA =  2.13*IN2M/2 ;%G'Lmax= 240 kG/m @ 8 A; Kmax=18 (4 GeV)
LSB =  0.1 ;
RSB =  1.38*IN2M/2 ;%G'Lmax= 870 kG/m @ 8 A; Kmax=65 (4 GeV)
% ==============================================================================
% kickers and septa
% ------------------------------------------------------------------------------
SETSPS =   1 ;%deflector switch for SXR
SETSPH =  -1 ;%deflector switch for HXR
SETSPD =   0 ;%deflector switch for dump
CUSON =   1 ;%deflector switch ON for pulsed Cu-linac to SXR
CUSONDC =  -1 ;%deflector switch ON for DC Cu-linac to SXR
CUSOFF =   0 ;%deflector switch OFF for Cu-linac to HXR
ALON =   1 ;%deflector switch ON for Cu/SC-linac to A-line
ALOFF =   0 ;%deflector switch OFF for Cu/SC-linac to HXR
DAON =   1 ;%deflector switch ON for DASEL
DAOFF =   0 ;%deflector switch OFF for DASEL
% ==============================================================================
% self seeding chicanes
% ------------------------------------------------------------------------------
SSON =   1 ;%self-seeding chicane ON
SSOFF =   0 ;%self-seeding chicane OFF
% ==============================================================================
% miscellaneous
% ------------------------------------------------------------------------------
SBANDF =  2856.0   ;%S-band rf frequency (MHz)
XBANDF =  4*SBANDF ;%X-band rf frequency (MHz)
LJAW =  0.06   ;%standard jaw collimator length
LCOLL =  0.08   ;%standard collimator length
LPCSP =  0.0508 ;%length of BCS protection collimator in spreader (2")
LPCPM =  0.076  ;%length of BCS protection collimator
LPCPMW =  0.08   ;%length of BCS WHA protection collimator
GBKSP =  0.02   ;%fast kicker gap height - round pipe, square bore aperture
LBKSP =  1.0    ;%fast kicker straight length (m)
GBLSP =  0.0159 ;%0.625SD38.98 septum gap height (m)
LBLSP =  1.0    ;%0.625SD38.98 septum straight length (m)
GBSP =  0.0254 ;%1.0D38.37 gap height (m)
LBSP =  1.0    ;%1.0D38.37 straight length (m)
R56SPS =  0.0    ;%R56 of the SXR spreader
R56SPH =  0.0    ;%R56 of the HXR spreader
LQL =  0.28   ;%length of no-longer-used 1.97Q10 quadrupole
LRFBUB =  0.05   ;%length of undulator RF BPM
LPCTDKIK =  0.8128 ;%length of muon protection collimators associated with
% TDKIK and TDKIKS (0.875" ID w/pipe)
% wooden BSY door (separates LI30 from BSY)
WOODDOOR={'mo' 'WOODDOOR' 0 []}';
% Note: BRDAS2 is a merge DC-bend which is either turned ON to operate
%       DASEL beam in A-line, or turned OFF to operate beam in A-line from
%       BSY pulsed magnets
ABRDAS2 =  -0.011874293037;
TBRDAS2 =   0.371701698805 ;%BRDAS2 roll angle (rad)
% ------------------------------------------------------------------------------
% beamline area delimiters (see PRD LCLSII-2.1-PR-0134)
% ------------------------------------------------------------------------------
% areas "owned" by SC linac
BEGGUNB={'mo' 'BEGGUNB' 0 []}';
ENDGUNB={'mo' 'ENDGUNB' 0 []}';
BEGL0B={'mo' 'BEGL0B' 0 []}';
ENDL0B={'mo' 'ENDL0B' 0 []}';
BEGHTR={'mo' 'BEGHTR' 0 []}';
ENDHTR={'mo' 'ENDHTR' 0 []}';
BEGDIAG0={'mo' 'BEGDIAG0' 0 []}';
ENDDIAG0={'mo' 'ENDDIAG0' 0 []}';
BEGCOL0={'mo' 'BEGCOL0' 0 []}';
ENDCOL0={'mo' 'ENDCOL0' 0 []}';
BEGL1B={'mo' 'BEGL1B' 0 []}';
ENDL1B={'mo' 'ENDL1B' 0 []}';
BEGBC1B={'mo' 'BEGBC1B' 0 []}';
ENDBC1B={'mo' 'ENDBC1B' 0 []}';
BEGCOL1={'mo' 'BEGCOL1' 0 []}';
ENDCOL1={'mo' 'ENDCOL1' 0 []}';
BEGL2B={'mo' 'BEGL2B' 0 []}';
ENDL2B={'mo' 'ENDL2B' 0 []}';
BEGBC2B={'mo' 'BEGBC2B' 0 []}';
ENDBC2B={'mo' 'ENDBC2B' 0 []}';
BEGEMIT2={'mo' 'BEGEMIT2' 0 []}';
ENDEMIT2={'mo' 'ENDEMIT2' 0 []}';
BEGL3B={'mo' 'BEGL3B' 0 []}';
ENDL3B={'mo' 'ENDL3B' 0 []}';
BEGEXT={'mo' 'BEGEXT' 0 []}';
ENDEXT={'mo' 'ENDEXT' 0 []}';
BEGDOG={'mo' 'BEGDOG' 0 []}';
ENDDOG={'mo' 'ENDDOG' 0 []}';
BEGBYP={'mo' 'BEGBYP' 0 []}';
ENDBYP={'mo' 'ENDBYP' 0 []}';
BEGSPH={'mo' 'BEGSPH' 0 []}';
ENDSPH={'mo' 'ENDSPH' 0 []}';
BEGSLTH={'mo' 'BEGSLTH' 0 []}';
ENDSLTH={'mo' 'ENDSLTH' 0 []}';
BEGSPD_1={'mo' 'BEGSPD_1' 0 []}';
ENDSPD_1={'mo' 'ENDSPD_1' 0 []}';
BEGSPD_2={'mo' 'BEGSPD_2' 0 []}';
ENDSPD_2={'mo' 'ENDSPD_2' 0 []}';
BEGSPD_3={'mo' 'BEGSPD_3' 0 []}';
ENDSPD_3={'mo' 'ENDSPD_3' 0 []}';
BEGSLTD={'mo' 'BEGSLTD' 0 []}';
ENDSLTD={'mo' 'ENDSLTD' 0 []}';
BEGSPS={'mo' 'BEGSPS' 0 []}';
ENDSPS={'mo' 'ENDSPS' 0 []}';
BEGSLTS={'mo' 'BEGSLTS' 0 []}';
ENDSLTS={'mo' 'ENDSLTS' 0 []}';
BEGBSYS={'mo' 'BEGBSYS' 0 []}';
ENDBSYS={'mo' 'ENDBSYS' 0 []}';
BEGLTUS={'mo' 'BEGLTUS' 0 []}';
ENDLTUS={'mo' 'ENDLTUS' 0 []}';
BEGUNDS={'mo' 'BEGUNDS' 0 []}';
ENDUNDS={'mo' 'ENDUNDS' 0 []}';
BEGDMPS_1={'mo' 'BEGDMPS_1' 0 []}';
ENDDMPS_1={'mo' 'ENDDMPS_1' 0 []}';
BEGDMPS_2={'mo' 'BEGDMPS_2' 0 []}';
ENDDMPS_2={'mo' 'ENDDMPS_2' 0 []}';
BEGSFTS_1={'mo' 'BEGSFTS_1' 0 []}';
ENDSFTS_1={'mo' 'ENDSFTS_1' 0 []}';
BEGSFTS_2={'mo' 'BEGSFTS_2' 0 []}';
ENDSFTS_2={'mo' 'ENDSFTS_2' 0 []}';
BEGSXTES={'mo' 'BEGSXTES' 0 []}';
ENDSXTES={'mo' 'ENDSXTES' 0 []}';
% areas "owned" by Cu linac
BEGGUN={'mo' 'BEGGUN' 0 []}';
ENDGUN={'mo' 'ENDGUN' 0 []}';
BEGGSPEC={'mo' 'BEGGSPEC' 0 []}';
ENDGSPEC={'mo' 'ENDGSPEC' 0 []}';
BEGL0={'mo' 'BEGL0' 0 []}';
ENDL0={'mo' 'ENDL0' 0 []}';
BEGDL1_1={'mo' 'BEGDL1_1' 0 []}';
ENDDL1_1={'mo' 'ENDDL1_1' 0 []}';
BEGSPEC={'mo' 'BEGSPEC' 0 []}';
ENDSPEC={'mo' 'ENDSPEC' 0 []}';
BEGDL1_2={'mo' 'BEGDL1_2' 0 []}';
ENDDL1_2={'mo' 'ENDDL1_2' 0 []}';
BEGL1={'mo' 'BEGL1' 0 []}';
ENDL1={'mo' 'ENDL1' 0 []}';
BEGBC1={'mo' 'BEGBC1' 0 []}';
ENDBC1={'mo' 'ENDBC1' 0 []}';
BEGL2={'mo' 'BEGL2' 0 []}';
ENDL2={'mo' 'ENDL2' 0 []}';
BEGBC2={'mo' 'BEGBC2' 0 []}';
ENDBC2={'mo' 'ENDBC2' 0 []}';
BEGL3={'mo' 'BEGL3' 0 []}';
ENDL3={'mo' 'ENDL3' 0 []}';
BEGCLTH_0={'mo' 'BEGCLTH_0' 0 []}';
ENDCLTH_0={'mo' 'ENDCLTH_0' 0 []}';
BEGCLTH_1={'mo' 'BEGCLTH_1' 0 []}';
ENDCLTH_1={'mo' 'ENDCLTH_1' 0 []}';
BEGCLTH_2={'mo' 'BEGCLTH_2' 0 []}';
ENDCLTH_2={'mo' 'ENDCLTH_2' 0 []}';
BEGBSYH_1={'mo' 'BEGBSYH_1' 0 []}';
ENDBSYH_1={'mo' 'ENDBSYH_1' 0 []}';
BEGBSYH_2={'mo' 'BEGBSYH_2' 0 []}';
ENDBSYH_2={'mo' 'ENDBSYH_2' 0 []}';
BEGLTUH={'mo' 'BEGLTUH' 0 []}';
ENDLTUH={'mo' 'ENDLTUH' 0 []}';
BEGUNDH={'mo' 'BEGUNDH' 0 []}';
ENDUNDH={'mo' 'ENDUNDH' 0 []}';
BEGDMPH_1={'mo' 'BEGDMPH_1' 0 []}';
ENDDMPH_1={'mo' 'ENDDMPH_1' 0 []}';
BEGDMPH_2={'mo' 'BEGDMPH_2' 0 []}';
ENDDMPH_2={'mo' 'ENDDMPH_2' 0 []}';
BEGSFTH_1={'mo' 'BEGSFTH_1' 0 []}';
ENDSFTH_1={'mo' 'ENDSFTH_1' 0 []}';
BEGSFTH_2={'mo' 'BEGSFTH_2' 0 []}';
ENDSFTH_2={'mo' 'ENDSFTH_2' 0 []}';
BEGHXTES={'mo' 'BEGHXTES' 0 []}';
ENDHXTES={'mo' 'ENDHXTES' 0 []}';
BEGCLTS={'mo' 'BEGCLTS' 0 []}';
ENDCLTS={'mo' 'ENDCLTS' 0 []}';
BEGBSYA_1={'mo' 'BEGBSYA_1' 0 []}';
ENDBSYA_1={'mo' 'ENDBSYA_1' 0 []}';
BEGBSYA_2={'mo' 'BEGBSYA_2' 0 []}';
ENDBSYA_2={'mo' 'ENDBSYA_2' 0 []}';
% ------------------------------------------------------------------------------

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc 3-way spreader system
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 06-JUN-2019, M. Woodley
%  * adjust location of BSY dump face per A. Ibrahimov
% 30-APR-2019, M. Woodley
%  * use measured FINT=0.4861 for 1.0D38.37 @ 200A
% ------------------------------------------------------------------------------
% 31-OCT-2018, Y. Nosochkov
%  * drift adjustment for DASEL with 25G kickers
%  * BSY dump face to BTM face = 61.120" (per Alev)
% 11-OCT-2018, M. Woodley
%  * use measured FINT for 1.0D22.265's
% ------------------------------------------------------------------------------
% 30-MAY-2018, M. Woodley
%  * add backup DC spreader definitions per J. Chan
% ------------------------------------------------------------------------------
% 30-JAN-2018, M. Woodley
%  * remove PCSP1H/BTMSP1H,PCSP1D/BTMSP1D,PCSP2D/BTMSP2D per D. Hanquist
%  * remove PCSP2H/BTMSP2H,PCSP3D per A. Ibramimov
%  * set length of PCSP3D to 2" per A. Ibrahimov
% 22-DEC-2017, M. Woodley
%  * remove BCS ACMs IMSP1s,IMSP2s,IMSP1h,IMSP2h,IMSP1d,IMSP2d per C. Clarke
%  * add BCS ACM triplets IMBCSh1-3,IMBCSs1-3,IMBCSd1-3 per C. Clarke
% ------------------------------------------------------------------------------
% 06-SEP-2017, Y. Nosochkov
%  * add placeholder zero-strength deferred large aperture kickers 
%    BKYSP5H, BKYSP5S for future LCLS-II-HE 
%  * remove baseline stoppers STSP6hb, STSP5s and the corresponding BTMs
%    BTMSP6hb, BTMSP5s (J. Blaha, J. Welch)
%  * remove deferred stoppers STSP6hc, STSP6hd as they will never be needed
%    (P. Emma)
%  * move BCS collimators PCSP1s,2s and the corresponding BTMs BTMSP1s,2s
%    downstream, per RP-RPG-170802-MEM-01 (M. Santana)
% 09-AUG-2017, M. Woodley
%  * move TWSSP BETA0 definition to LCLS2sc_main.mad8 (for BMAD compatability)
%  * move SETKIKs and SETKIKh definitions here from common.xsif
% ------------------------------------------------------------------------------
% 05-MAY-2017, Y. Nosochkov
%  * move OTRSPDMP 0.5 m downstream of BPMSP5d (P. Emma, J. Welch)
%  * replace 1.97Q20 type quads (QSP3H,11H and QSP1S,2S,3S,7S,8S,9S) with
%    1.26Q12 type quads, keep BPMs unchanged (J. Amann, P. Emma)
%  * add two type-5 deferred correctors XCSP5d, YCSP6d in BSY dumpline (P. Emma)
% 24-FEB-2017, Y. Nosochkov
%  * move BPMSP5D 0.761425 m upstream to Z=3203.327 m (M. Kosovsky)
% 23-NOV-2016, Y. Nosochkov
%  * redefine SPRDd line for updated DASEL kicker
% 04-NOV-2016, M. Woodley
%  * fix drift lengths around WOODDOOR in SPRDh line
% 02-NOV-2016, Y. Nosochkov
%  * move BPMSP1d 4.457 m upstream to provide space for DASEL kicker
%  * add a note that BTM behind stopper is part of the stopper design
%  * add a note that BXSP1h is a special merge DC-bend which is turned ON
%    for SCRF beam to HXR or OFF for CURF beam to HXR
%  * move to baseline: BPMSPH, BPMSP1, XCSP1, BPMSP2, YCSP2, BPMSPS, IMSP1H,
%    BTMSP6HB, BTMSP5S, PCSP1D, PCSP1H, PCSP1S, BTMSP1D, BTMSP1H, BTMSP1S,
%    IMSP1S, PCSP2S, BTMSP2S, XCSP3D, YCSP4D, IMSP1D, IMSP2D, PCSP2D, BTMSPDMP,
%    BTMSP2D, PCSP2H, BTMSP2H, BKXRASD, BKYRASD, BPMSP5D, PCSP3D, BTMSP3D
% 29-JUN-2016, M. Woodley
%  * adjust location of WOODDOOR (Z=3050.512)
% 24-JUN-2016, Y. Nosochkov
%  * move BPMSPh, BPMSPs upstream to the positions where kicked orbit is 5 mm
%    (P. Emma)
%  * move BPMs inside the 1.085Q4.31 quads QSP2h, QSP7h, QSP12h
%    (M. Gaynor, Alev)
%  * add deferred XCSP3d, YCSP4d correctors just after BYSP2d (P. Emma)
%  * add deferred BKXRASd, BKYRASd rastering kickers 60 m upstream of the
%    BSY dump (J. Welch)
%  * move the deferred OTRSPDMP upstream of the rastering kickers (P. Emma)
%  * move BPMSP4d upstream of OTRSPDMP (J. Welch)
%  * add deferred large aperture BPMSP5d (Stripline-14 with 5" ID)
%    within 5 m of BSY dump (J. Welch)
%  * move BPMSP2D 12" upstream and BPMSP3D 24" upstream (M. Gaynor)
%  * remove deferred STSP6ha (S. Mao)
%  * remove STSP6hc, STSP6hd stoppers from baseline and defer them at level 9
%    (for cost tracking -- P. Emma)
%  * designate all stoppers to be PPS stoppers (S. Mao)
%  * add deferred BTMSP6hb behind PPS stopper STSP6hb (S. Mao)
%  * add deferred BTMSP5s behind PPS stopper STSP5s (S. Mao)
%  * move IMSP1h to just downstream of QSP6h (S. Mao)
%  * move IMSP1s to just downstream of BXSP2s (S. Mao)
%  * add deferred IMSP2h, IMSP2s BCS cavity current monitors (S. Mao, J. Welch)
%  * update engineering type designations of current monitors (J. Welch)
%  * update the engineering type of BKYSP0h,...,BKYSP4h and BKYSP0s,...,BKYSP4s
%    kickers to "0.787K35.4" (J. Amann)
% ------------------------------------------------------------------------------
% 26-FEB-2016, Y. Nosochkov
%  * adjust positions of QSP3h,4h,5h,9h,10h,11h and corresponding
%    BPMs and correctors to resolve interferences (T. O'Heron)
%  * move XCSP1 1.216 m downstream (T. O'Heron)
%  * move WSSP1d 1.0 m downstream (T. O'Heron)
%  * adjust positions of STSP6Ha,b,c,d to resolve interferences (T. O'Heron)
%  * change engineering name of BSY dump from "D10" to "DUMPBSY"
%  * move BYSP1s, BYSP2s 9" (0.2286 m) upstream (T. O'Heron)
%  * align PCSP1h, PCSP1s, PCSP1d at the same Z (S. Mao)
%  * move IMSP2d to just downstream of IMSP1d (S. Mao)
%  * move IMSP1h to just dowstream of BRSP2H (S. Mao)
%  * increase distance between 1-m kicker sections from 15 cm to 30 cm
%    (T. Beukers)
%  * add BPMSPh and BPMSPs between fast kickers and septa for calibration
%    of the kick angle and kicker phase (per P. Emma) -- deferred @0
%  * add BCS BTM (BTMSPDMP) behind BSY dump (per S. Mao) -- deferred @0
%  * move BPMSP1 upstream to within 23 m of the HXR septum (for greater
%    phase advance with BPMSP2)
% 12-FEB-2016, M. Woodley
%  * remove SETKIKh and SETKIKs; remove SEQnn MARKers
%  * add sextupoles to correct 2nd-order dispersion per P. Emma
%  * add wood door at LI30/BSY boundary (WOODDOOR)
% ------------------------------------------------------------------------------
% 25-SEP-2015, Y. Nosochkov
%  * update definition of BXSP1h to allow zero angle
% 24-AUG-2015, Y. Nosochkov
%  * add placeholder kickers for future  expansion (2 HXR and 2 SXR sections)
%    deferred at level @2
%  * move BYSP1h 1.8 m downstream to increase separation with dump line
%  * update the TYPE of septa from 0.39SD38.98 to 0.625SD38.98 (J. Amann)
%  * add two quads QSP1, QSP2 (baseline) with BPMs/correctors (deferred
%    at level @0)
%  * separate the HXR/SXR spreader kickers by moving the SXR kicker, septum
%    and chicane ~86 m downstream
%  * use positive sign of vertical kick in both HXR/SXR kickers for the same
%    style septa in HXR and SXR
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * add OTRSPDMP ~12 m before the muon wall, deferred at @0 (per Paul)
%  * move WSSP1D upstream to between vertical bends where Dy=0.4 m (per Paul)
%  * add deferred BTMs behind BCS PCSP collimators (per S. Mao)
%  * move IMSP1D upstream of PCSP2D (per S. Mao)
%  * remove PCSP4D, move PCSP3D close to muon wall (per S. Mao)
%  * move BPMSP1d upstream to within 23 m of the septum (per Tor and T. O'Heron)
%  * change the type of BPMSP4D to "Stripline-5" (per C. Iverson)
%  * change the status of IMSP0D, WSSP1D, STSP5S from deferred to baseline
%  * move BPMSP2H,7H,12H outside of the quads (per T. O'Heron)
%  * move QSP1S 5 cm downstream and QSP9S 5 cm upstream (per T. O'Heron)
%  * change type of quads QSP1S,2S,3S,7S,8S,9S,3H,11H to 1.97Q20
%  * adjust positions of correctors and BPMs at 1.97Q20 quads (per T. O'Heron)
%  * remove BXSP1D assuming new BSY dump will be installed (per A. Ibrahimov)
%  * adjust positions of BPMSP3D, IMSP0D, IMSP0H, IMSP0S (per T. O'Heron)
%  * change BPMSP3D to "Stripline-8" (per M. Gaynor)
%  * change type of BPMs at 2Q10 quads to "Stripline-5" (per M. Gaynor)
% ------------------------------------------------------------------------------
% 16-APR-2015, M. Woodley
%  * restore "LQL" parameter and its dependencies
% 20-MAR-2015, M. Woodley
%  * remove dependences on (now undefined) parameter "LQL"
%  * assign TYPEs to BCS devices ... defer at level 0
% 12-MAR-2015, Y. Nosochkov
%  * move QSP3H u/s and QSP11H d/s by 15 inches (per T. O'Heron)
%  * move BPMs outside of 2Q10 quads and adjust positions of corresponding
%    correctors (per T. O'Heron)
%  * move STSP6HB 32 inches downstream (per T. O'Heron)
% 28-FEB-2015, Y. Nosochkov
%  * minor update to definiton of the spreader kickers and septa
%  * change type of QSP1S-QSP9S, QSP1H, QSP3H-QSP6H, QSP8H-QSP11H, QSP13H,
%    QSP1D, QSP2D from "1.97Q10" to "2Q10"
% ------------------------------------------------------------------------------
% 12-DEC-2014, M. Woodley
%  * assign BPM TYPE attributes per PRD LCLSII-2.4-PR-0136
% 09-DEC-2014, Y. Nosochkov
%  * move STBP32 stopper to inside of the SXR spreader chicane and rename it
%    to STSP5s
%  * move D10 dump inside the muon wall in the BSY
%  * change engineering TYPE of QSP1d, QSP2d to "1.97Q10"
%  * rename BXSPd to BXSP1d and change its engineering TYPE to "9D28.5"
%  * rename ROSPs to ROSP1s
%  * rename IMSPs -> IMSP0s, IMSPh -> IMSP0h, IMSPd -> IMSP0d
%  * add BSC current monitors IMSP1d, IMSP2d in SPD (S. Mao)
%  * add BCS collimators PCSP1s, PCSP2s in SPS (S. Mao)
%  * add BCS collimators PCSP1h, PCSP2h in SPH (S. Mao)
%  * add BCS collimators PCSP1d, PCSP2d, PCSP3d, PCSP4d in SPD (S. Mao)
%  * change TYPE of septum magnets from "HLAM" to "0.39SD38.98" (J. Amann)
%  * add BPMSP3d, BPMSP4d at the last two bends in SPD
%  * add fast wire WSSP1d to measure beam size upstream of D10 dump (J. Frisch)
%  * change to type "QE" the following quadrupoles: QSP2h, QSP7h, QSP12h
%  * change to type "1.97Q10" the quads: QSP1h, QSP3h,...,QSP6h,
%    QSP8h,...,QSP11h, QSP13h, QSP1s,...,QSP9s
%    note: field of QSP1s,3s,7s,9s reaches the limit at 7.8 GeV
% ------------------------------------------------------------------------------
% 10-OCT-2014, Y. Nosochkov
%  * update the TYPE of STSP6ha (BCS stopper) and IMSPd (toroid) to indicate
%    the non-baseline level "0"
% 28-JUL-2014, Y. Nosochkov
%  * replace a 3-hole spreader septum with two separate 2-hole septa for SXR
%    and HXR
%  * replace a 1-m deflector in the spreader with six 1-m magnetic kickers
%    (per T. Beukers)
%  * replace dipole corrector type "1.0D18.69" with "1.0D22.625" (per J. Amann)
% 15-JUL-2014, Y. Nosochkov
%  * replace RFBSP1d, RFBSP2d with stripline BPMSP1d, BPMSP2d (per J. Frisch)
% 02-MAY-2014, M. Woodley
%  * add "CNT" MARKERs after dispersive areas (ELEGANT CENTERing)
% 01-MAY-2014, Y. Nosochkov
%  * replace BPMSP1d, BPMSP2d with cavity BPMs RFBSP1d, RFBSP2d (per J. Frisch)
% 30-APR-2014, Y. Nosochkov
%  * add average current monitors IMSPs, IMSPh, IMSPd (per J. Frisch)
% 28-APR-2014, Y. Nosochkov
%  * remove QSP3D, QSP4D and their BPMs and correctors in BSY dumpline
%    assuming OTR and beta waist are not needed (per J. Frisch)
% 23-APR-2014, Y. Nosochkov
%  * remove OTRDMPd in SPD near D10 (per J. Frisch)
% 07-APR-2014, M. Woodley
%  * reorder and/or modify some drift length parameter definitions to avoid
%    using parameters before they are defined
% 04-APR-2014, Y. Nosochkov
% *  add BCS stopper upstream of 3 PPS stoppers in HXR,
%    name the BCS stopper STSP6ha, and PPS stoppers STSP6hb, STSP6hc, STSP6hd
% ------------------------------------------------------------------------------
% 31-MAR-2014, M. Woodley
%  * element names changed to conform to nomenclature PRD
% 25-MAR-2014, Y. Nosochkov
%  * add insertable beam stoppers STSP6ha, STSP6hb, STSP6hc in HXR
% 07-MAR-2014, Y. Nosochkov
%  * move corrector YCSP8h upstream of quad QSP8h for better separation with
%    nearby LCLS-1 quad
% 26-FEB-2014, Y. Nosochkov
%  * change from L=2.623 m dipoles (type 1.26D102.0T) to L=1.0 m dipoles
%    (type 1.0D38.37)
%  * reduce septum length from 2.0 to 1.0 m
%  * change type of BCSP1, BCSP2 dipoles from 1.26D18.43 to 1.0D18.69
% 14-FEB-2014, Y. Nosochkov
%  * add a dumpline from the spreader to D10 dump including optics
%    for energy diagnostic
% 17-JAN-2014, Y. Nosochkov
%  * modify HXR spreader from 1-step to 2-step dogleg for tunable R56
%    and better magnet separation
% 18-DEC-2013, Y. Nosochkov
%  * adjust magnet positions in the spreader for less magnet interference
% 16-DEC-2013, Y. Nosochkov
%  * 3-way spreader design with low R56
% ------------------------------------------------------------------------------
% XYZ (linac system) and optimized Twiss at the beginning of spreader (BEGSPH)
XSP =  XOFF;
YSP =  YOFF;
ZSP =  2780.276003;
THSP =  0.0;
PHSP =  0.0;
PSSP =  0.0;
TBXSP =  1.112796938491E2;
TBYSP =  60.000000012297;
TAXSP =  2.930243793946;
TAYSP =  0.853023050724;
% XYZ (linac system) at the end of HXR merge bend BXSP1h
XSPH =   0.0;
YSPH =   0.0;
ZSPH =   3110.961492;
THSPH =   0.0;
PHSPH =   0.0;
PSSPH =   0.0;
% HXR quads
KQSP1H =   0.492283667698 ;% 0.492284061187
KQSP2H =  -1.000975451311 ;%-1.000975933726
KQSP3H =   0.304631037813 ;% 0.304631069714
KQSP4H =  -0.301467336919 ;%-0.301467337182
KQSP5H =   0.179797525903 ;% 0.179797501925
KQSP6H =  -0.221916299351 ;%-0.221916295184
KQSP7H =   0.447153951126 ;% 0.447153906987
KQSP10H =  -0.301520274195 ;%-0.301520272128
KQSP11H =   0.304797784837 ;% 0.304797809076
KQSP12H =  -0.991899431333 ;%-0.991897597733
KQSP13H =   0.491351727496 ;% 0.49135154631
KQSP8H =   KQSP6H;
KQSP9H =   KQSP5H;
QSP1H={'qu' 'QSP1H' LQR/2 [KQSP1H 0]}';
QSP2H={'qu' 'QSP2H' LQE/2 [KQSP2H 0]}';
QSP3H={'qu' 'QSP3H' LQA/2 [KQSP3H 0]}';
QSP4H={'qu' 'QSP4H' LQR/2 [KQSP4H 0]}';
QSP5H={'qu' 'QSP5H' LQR/2 [KQSP5H 0]}';
QSP6H={'qu' 'QSP6H' LQR/2 [KQSP6H 0]}';
QSP7H={'qu' 'QSP7H' LQE/2 [KQSP7H 0]}';
QSP8H={'qu' 'QSP8H' LQR/2 [KQSP8H 0]}';
QSP9H={'qu' 'QSP9H' LQR/2 [KQSP9H 0]}';
QSP10H={'qu' 'QSP10H' LQR/2 [KQSP10H 0]}';
QSP11H={'qu' 'QSP11H' LQA/2 [KQSP11H 0]}';
QSP12H={'qu' 'QSP12H' LQE/2 [KQSP12H 0]}';
QSP13H={'qu' 'QSP13H' LQR/2 [KQSP13H 0]}';
% HXR sextupoles
KSSP1H =  -20.980886636913 ;%-20.980854539502
KSSP2H =   22.597513710817 ;% 22.597505265891
TSSP1H =   15.249352738505 ;% 15.249361095235
TSSP2H =   17.803041269766 ;% 17.803035424509
SSP1H={'dr' 'SSP1H' LSB/2 []}';
SSP2H={'dr' 'SSP2H' LSB/2 []}';
% 
% 
% 

% SXR & dumpline shared quads
KQSP1 =   0.52687626083;
KQSP2 =  -0.521500809125;
QSP1={'qu' 'QSP1' LQR/2 [KQSP1 0]}';
QSP2={'qu' 'QSP2' LQR/2 [KQSP2 0]}';
% SXR quads
KQSP1S =   0.633675228645 ;% 0.633675409102
KQSP2S =  -0.558846778994 ;%-0.558846970939
KQSP3S =   0.652027259917 ;% 0.652027344684
KQSP4S =  -0.497671456472 ;%-0.497671571574
KQSP5S =   0.184431144204 ;% 0.184431117493
KQSP8S =  -0.559080484823 ;%-0.559079941433
KQSP9S =   0.633806872701 ;% 0.633806671882
KQSP6S =   KQSP4S;
KQSP7S =   KQSP3S;
QSP1S={'qu' 'QSP1S' LQA/2 [KQSP1S 0]}';
QSP2S={'qu' 'QSP2S' LQA/2 [KQSP2S 0]}';
QSP3S={'qu' 'QSP3S' LQA/2 [KQSP3S 0]}';
QSP4S={'qu' 'QSP4S' LQR/2 [KQSP4S 0]}';
QSP5S={'qu' 'QSP5S' LQR/2 [KQSP5S 0]}';
QSP6S={'qu' 'QSP6S' LQR/2 [KQSP6S 0]}';
QSP7S={'qu' 'QSP7S' LQA/2 [KQSP7S 0]}';
QSP8S={'qu' 'QSP8S' LQA/2 [KQSP8S 0]}';
QSP9S={'qu' 'QSP9S' LQA/2 [KQSP9S 0]}';
% SXR sextupoles
KSSP1S =   12.701345963181 ;% 12.701341641754
KSSP2S =   12.699237045946 ;% 12.699235330279
SSP1S={'dr' 'SSP1S' LSB/2 []}';
SSP2S={'dr' 'SSP2S' LSB/2 []}';
% 
% 
% 

% BSY dumpline quads
KQSP1D =  -0.258027172416;
KQSP2D =   0.232777714022;
QSP1D={'qu' 'QSP1D' LQR/2 [KQSP1D 0]}';
QSP2D={'qu' 'QSP2D' LQR/2 [KQSP2D 0]}';
% HXR vertical magnetic kickers
% All kickers aligned along the same z-axis (per T. Beukers)
% Assume the same z-length per kicker and same field (in SXR or HXR)
GBKYSP =  GBKSP ;%kicker gap (m) - round pipe, square bore aperture
LBKYSP =  LBKSP ;%kicker straight length (m)
SETKIKH =  0.5*SETSP*(SETSP-1)    ;%scale for HXR spreader kicker & septum
ABKYSPH0 =  -0.75E-3;
ABKYSPH =  ABKYSPH0 *SETKIKH      ;%total HXR kicker y-angle (rad)
ABKYSP1H =  asin(  sin(ABKYSPH)/3) ;%1st HXR kicker y-angle (rad)
ABKYSP12H =  asin(2*sin(ABKYSPH)/3) ;%1st+2nd HXR kicker y-angle (rad)
ABKYSP2H =  ABKYSP12H-ABKYSP1H     ;%2nd HXR kicker y-angle (rad)
ABKYSP3H =  ABKYSPH  -ABKYSP12H    ;%3rd HXR kicker y-angle (rad)
LBKYSP1H =    LBKYSP/(1-ABKYSP1H *ABKYSP1H /6);
LBKYSP12H =  2*LBKYSP/(1-ABKYSP12H*ABKYSP12H/6);
LBKYSP13H =  3*LBKYSP/(1-ABKYSPH  *ABKYSPH  /6);
LBKYSP2H =    LBKYSP12H-LBKYSP1H;
LBKYSP3H =    LBKYSP13H-LBKYSP12H;
BKYSP1HA={'be' 'BKYSP1H' LBKYSP1H/2 [ABKYSP1H/2 GBKYSP/2 0 0 0.5 0 pi/2]}';
BKYSP1HB={'be' 'BKYSP1H' LBKYSP1H/2 [ABKYSP1H/2 GBKYSP/2 0 ABKYSP1H 0 0.5 pi/2]}';
BKYSP2HA={'be' 'BKYSP2H' LBKYSP2H/2 [ABKYSP2H/2 GBKYSP/2 -ABKYSP1H 0 0.5 0 pi/2]}';
BKYSP2HB={'be' 'BKYSP2H' LBKYSP2H/2 [ABKYSP2H/2 GBKYSP/2 0 ABKYSP12H 0 0.5 pi/2]}';
BKYSP3HA={'be' 'BKYSP3H' LBKYSP3H/2 [ABKYSP3H/2 GBKYSP/2 -ABKYSP12H 0 0.5 0 pi/2]}';
BKYSP3HB={'be' 'BKYSP3H' LBKYSP3H/2 [ABKYSP3H/2 GBKYSP/2 0 ABKYSPH 0 0.5 pi/2]}';
% placeholder zero-strength magnets for future LCLS-II-HE HXR kickers
LBKYSP0H =  LBKYSP;
LBKYSP4H =  LBKYSP/cos(ABKYSPH);
BKYSP0HA={'be' 'BKYSP0H' LBKYSP0H/2 [0 GBKYSP/2 0 0 0.5 0 pi/2]}';
BKYSP0HB={'be' 'BKYSP0H' LBKYSP0H/2 [0 GBKYSP/2 0 0 0 0.5 pi/2]}';
BKYSP4HA={'be' 'BKYSP4H' LBKYSP4H/2 [0 GBKYSP/2 -ABKYSPH 0 0.5 0 pi/2]}';
BKYSP4HB={'be' 'BKYSP4H' LBKYSP4H/2 [0 GBKYSP/2 0 ABKYSPH 0 0.5 pi/2]}';
GBKYSP5H =  0.035;
ZBKYSP5H =  1.0;
LBKYSP5H =  ZBKYSP5H/cos(ABKYSPH);
BKYSP5HA={'be' 'BKYSP5H' LBKYSP5H/2 [0 GBKYSP5H/2 -ABKYSPH 0 0.5 0 pi/2]}';
BKYSP5HB={'be' 'BKYSP5H' LBKYSP5H/2 [0 GBKYSP5H/2 0 ABKYSPH 0 0.5 pi/2]}';
% SXR vertical magnetic kickers
% All kickers aligned along the same z-axis (per T. Beukers)
% Assume the same z-length per kicker and same field (in SXR or HXR)
SETKIKS =  0.5*SETSP*(SETSP+1)    ;%scale for SXR spreader kicker & septum
ABKYSPS0 =  -0.75E-3;
ABKYSPS =  ABKYSPS0 *SETKIKS      ;%total SXR kicker y-angle (rad)
ABKYSP1S =  asin(  sin(ABKYSPS)/3) ;%1st SXR kicker y-angle (rad)
ABKYSP12S =  asin(2*sin(ABKYSPS)/3) ;%1st+2nd SXR kicker y-angle (rad)
ABKYSP2S =  ABKYSP12S-ABKYSP1S     ;%2nd SXR kicker y-angle (rad)
ABKYSP3S =  ABKYSPS  -ABKYSP12S    ;%3rd SXR kicker y-angle (rad)
LBKYSP1S =    LBKYSP/(1-ABKYSP1S *ABKYSP1S /6);
LBKYSP12S =  2*LBKYSP/(1-ABKYSP12S*ABKYSP12S/6);
LBKYSP13S =  3*LBKYSP/(1-ABKYSPS  *ABKYSPS  /6);
LBKYSP2S =    LBKYSP12S-LBKYSP1S;
LBKYSP3S =    LBKYSP13S-LBKYSP12S;
BKYSP1SA={'be' 'BKYSP1S' LBKYSP1S/2 [ABKYSP1S/2 GBKYSP/2 0 0 0.5 0 pi/2]}';
BKYSP1SB={'be' 'BKYSP1S' LBKYSP1S/2 [ABKYSP1S/2 GBKYSP/2 0 ABKYSP1S 0 0.5 pi/2]}';
BKYSP2SA={'be' 'BKYSP2S' LBKYSP2S/2 [ABKYSP2S/2 GBKYSP/2 -ABKYSP1S 0 0.5 0 pi/2]}';
BKYSP2SB={'be' 'BKYSP2S' LBKYSP2S/2 [ABKYSP2S/2 GBKYSP/2 0 ABKYSP12S 0 0.5 pi/2]}';
BKYSP3SA={'be' 'BKYSP3S' LBKYSP3S/2 [ABKYSP3S/2 GBKYSP/2 -ABKYSP12S 0 0.5 0 pi/2]}';
BKYSP3SB={'be' 'BKYSP3S' LBKYSP3S/2 [ABKYSP3S/2 GBKYSP/2 0 ABKYSPS 0 0.5 pi/2]}';
% placeholder zero-strength magnets for future LCLS-II-HE SXR kickers
LBKYSP0S =  LBKYSP;
LBKYSP4S =  LBKYSP/cos(ABKYSPS);
BKYSP0SA={'be' 'BKYSP0S' LBKYSP0S/2 [0 GBKYSP/2 0 0 0.5 0 pi/2]}';
BKYSP0SB={'be' 'BKYSP0S' LBKYSP0S/2 [0 GBKYSP/2 0 0 0 0.5 pi/2]}';
BKYSP4SA={'be' 'BKYSP4S' LBKYSP4S/2 [0 GBKYSP/2 -ABKYSPS 0 0.5 0 pi/2]}';
BKYSP4SB={'be' 'BKYSP4S' LBKYSP4S/2 [0 GBKYSP/2 0 ABKYSPS 0 0.5 pi/2]}';
GBKYSP5S =  0.035;
ZBKYSP5S =  1.0;
LBKYSP5S =  ZBKYSP5S/cos(ABKYSPS);
BKYSP5SA={'be' 'BKYSP5S' LBKYSP5S/2 [0 GBKYSP5S/2 -ABKYSPS 0 0.5 0 pi/2]}';
BKYSP5SB={'be' 'BKYSP5S' LBKYSP5S/2 [0 GBKYSP5S/2 0 ABKYSPS 0 0.5 pi/2]}';
% 2-hole HXR horizontal septum aligned along the bypass axis
GBLXSP =  GBLSP ;%septum gap height (m)
LBLXSP =  LBLSP ;%septum straight length (m)
ABLXSPH0 =  -0.0055277237035;
ABLXSPH =  ABLXSPH0 *SETKIKH;
ABLXSPHA =  asin(sin(ABLXSPH)/2);
ABLXSPHB =  ABLXSPH-ABLXSPHA;
ABLXSPH_2 =  ABLXSPH   *ABLXSPH;
ABLXSPH_4 =  ABLXSPH_2 *ABLXSPH_2;
ABLXSPHA_2 =  ABLXSPHA  *ABLXSPHA;
ABLXSPHA_4 =  ABLXSPHA_2*ABLXSPHA_2;
LBLXSPH =  LBLXSP   /(1-ABLXSPH_2/6 +ABLXSPH_4/120 )/cos(ABKYSPH);
LBLXSPHA =  LBLXSP/2 /(1-ABLXSPHA_2/6+ABLXSPHA_4/120)/cos(ABKYSPH);
LBLXSPHB =  LBLXSPH-LBLXSPHA;
BLXSPHA={'be' 'BLXSPH' LBLXSPHA [ABLXSPHA GBLXSP/2 0 0 0.5 0 0]}';
BLXSPHB={'be' 'BLXSPH' LBLXSPHB [ABLXSPHB GBLXSP/2 0 ABLXSPH 0 0.5 0]}';
% 2-hole SXR horizontal septum aligned along the bypass axis
ABLXSPS0 =  0.011055447407;
ABLXSPS =  ABLXSPS0 *SETKIKS;
ABLXSPSA =  asin(sin(ABLXSPS)/2);
ABLXSPSB =  ABLXSPS-ABLXSPSA;
ABLXSPS_2 =  ABLXSPS   *ABLXSPS;
ABLXSPS_4 =  ABLXSPS_2 *ABLXSPS_2;
ABLXSPSA_2 =  ABLXSPSA  *ABLXSPSA;
ABLXSPSA_4 =  ABLXSPSA_2*ABLXSPSA_2;
LBLXSPS =  LBLXSP   /(1-ABLXSPS_2/6 +ABLXSPS_4/120 )/cos(ABKYSPS);
LBLXSPSA =  LBLXSP/2 /(1-ABLXSPSA_2/6+ABLXSPSA_4/120)/cos(ABKYSPS);
LBLXSPSB =  LBLXSPS-LBLXSPSA;
BLXSPSA={'be' 'BLXSPS' LBLXSPSA [ABLXSPSA GBLXSP/2 0 0 0.5 0 0]}';
BLXSPSB={'be' 'BLXSPS' LBLXSPSB [ABLXSPSB GBLXSP/2 0 ABLXSPS 0 0.5 0]}';
% measured FINT for 1.0D38.37 @ 200A
FBSP =  0.4861;
% HXR rolled bends
ABRSPH =  0.650488048269E-2;
LBRSPH =  LBSP*ABRSPH/(2*sin(ABRSPH/2)) ;%BRSPh path length (m)
TBRSPH =  0.555232529864                ;%BRSPh roll angle (rad)
BRSP1HA={'be' 'BRSP1H' LBRSPH/2 [ABRSPH/2 GBSP/2 ABRSPH/2 0 FBSP 0 TBRSPH]}';
BRSP1HB={'be' 'BRSP1H' LBRSPH/2 [ABRSPH/2 GBSP/2 0 ABRSPH/2 0 FBSP TBRSPH]}';
BRSP2HA={'be' 'BRSP2H' LBRSPH/2 [-ABRSPH/2 GBSP/2 -ABRSPH/2 0 FBSP 0 TBRSPH]}';
BRSP2HB={'be' 'BRSP2H' LBRSPH/2 [-ABRSPH/2 GBSP/2 0 -ABRSPH/2 0 FBSP TBRSPH]}';
% HXR horizontal bend
% Note: BXSP1h is a merge DC-bend which is either turned ON to operate
%       SCRF beam in HXR, or turned OFF to operate CURF beam in HXR
DABXSPH =  0.155464098791E-8;
ABXSPH =  (-ABLXSPH0+DABXSPH) *SETKIKH;
ABXSPHH =  ABXSPH/2;
ABXSPHH_2 =  ABXSPHH   *ABXSPHH;
ABXSPHH_4 =  ABXSPHH_2 *ABXSPHH_2;
LBXSPH =  LBSP/(1-ABXSPHH_2/6 +ABXSPHH_4/120) ;%BXSP1h path length (m)
BXSP1HA={'be' 'BXSP1H' LBXSPH/2 [ABXSPH/2 GBSP/2 ABXSPH/2 0 FBSP 0 0]}';
BXSP1HB={'be' 'BXSP1H' LBXSPH/2 [ABXSPH/2 GBSP/2 0 ABXSPH/2 0 FBSP 0]}';
% SXR horizontal bends
DABXSPS =  0.310901777441E-8;
ABXSPS =  ABLXSPS0+DABXSPS;
LBXSPS =  LBSP*ABXSPS/(2*sin(ABXSPS/2)) ;%BXSPs path length (m)
BXSP1SA={'be' 'BXSP1S' LBXSPS/2 [-ABXSPS/2 GBSP/2 -ABXSPS/2 0 FBSP 0 0]}';
BXSP1SB={'be' 'BXSP1S' LBXSPS/2 [-ABXSPS/2 GBSP/2 0 -ABXSPS/2 0 FBSP 0]}';
BXSP2SA={'be' 'BXSP2S' LBXSPS/2 [-ABXSPS/2 GBSP/2 -ABXSPS/2 0 FBSP 0 0]}';
BXSP2SB={'be' 'BXSP2S' LBXSPS/2 [-ABXSPS/2 GBSP/2 0 -ABXSPS/2 0 FBSP 0]}';
BXSP3SA={'be' 'BXSP3S' LBXSPS/2 [ABXSPS/2 GBSP/2 ABXSPS/2 0 FBSP 0 0]}';
BXSP3SB={'be' 'BXSP3S' LBXSPS/2 [ABXSPS/2 GBSP/2 0 ABXSPS/2 0 FBSP 0]}';
% BSY dumpline vertical bends
ABYSPD =  0.877684127155E-2;
LBYSPD =  LBSP*ABYSPD/(2*sin(ABYSPD/2)) ;%BYSPd path length (m)
BYSP1DA={'be' 'BYSP1D' LBYSPD/2 [ABYSPD/2 GBSP/2 ABYSPD/2 0 FBSP 0 pi/2]}';
BYSP1DB={'be' 'BYSP1D' LBYSPD/2 [ABYSPD/2 GBSP/2 0 ABYSPD/2 0 FBSP pi/2]}';
BYSP2DA={'be' 'BYSP2D' LBYSPD/2 [-ABYSPD/2 GBSP/2 -ABYSPD/2 0 FBSP 0 pi/2]}';
BYSP2DB={'be' 'BYSP2D' LBYSPD/2 [-ABYSPD/2 GBSP/2 0 -ABYSPD/2 0 FBSP pi/2]}';
% HXR DC bend correctors to compensate kicker orbit and dispersion
LBCSP =  0.6    ;%DC corrector length
GBCSP =  0.0254 ;%DC corrector gap
FBCSP =  0.4725 ;%measured DC corrector FINT value
ABCSP1H =   0.445436076072E-2;
ABCSP2H =  -0.370437221909E-2;
LBCSP1H =  LBCSP*ABCSP1H/(2*sin(ABCSP1H/2)) ;%BYSP1h path length (m)
LBCSP2H =  LBCSP*ABCSP2H/(2*sin(ABCSP2H/2)) ;%BYSP2h path length (m)
BYSP1HA={'be' 'BYSP1H' LBCSP1H/2 [ABCSP1H/2 GBCSP/2 ABCSP1H/2 0 FBCSP 0 pi/2]}';
BYSP1HB={'be' 'BYSP1H' LBCSP1H/2 [ABCSP1H/2 GBCSP/2 0 ABCSP1H/2 0 FBCSP pi/2]}';
BYSP2HA={'be' 'BYSP2H' LBCSP2H/2 [ABCSP2H/2 GBCSP/2 ABCSP2H/2 0 FBCSP 0 pi/2]}';
BYSP2HB={'be' 'BYSP2H' LBCSP2H/2 [ABCSP2H/2 GBCSP/2 0 ABCSP2H/2 0 FBCSP pi/2]}';
% SXR DC bend correctors to compensate kicker orbit and dispersion
ABCSP1S =   0.315465742092E-2;
ABCSP2S =  -0.240470325405E-2;
LBCSP1S =  LBCSP*ABCSP1S/(2*sin(ABCSP1S/2)) ;%BYSP1s path length (m)
LBCSP2S =  LBCSP*ABCSP2S/(2*sin(ABCSP2S/2)) ;%BYSP2s path length (m)
BYSP1SA={'be' 'BYSP1S' LBCSP1S/2 [ABCSP1S/2 GBCSP/2 ABCSP1S/2 0 FBCSP 0 pi/2]}';
BYSP1SB={'be' 'BYSP1S' LBCSP1S/2 [ABCSP1S/2 GBCSP/2 0 ABCSP1S/2 0 FBCSP pi/2]}';
BYSP2SA={'be' 'BYSP2S' LBCSP2S/2 [ABCSP2S/2 GBCSP/2 ABCSP2S/2 0 FBCSP 0 pi/2]}';
BYSP2SB={'be' 'BYSP2S' LBCSP2S/2 [ABCSP2S/2 GBCSP/2 0 ABCSP2S/2 0 FBCSP pi/2]}';
% drifts
LDSPCOR1 =  0.3617;
LDSPCOR2 =  0.5263;
LDSPBPM1 =  0.4471;
LDSPBPM2 =  0.5342;
LDSPBK =  0.3;
LDSPBK0H =  LDSPBK;
LDSPBK1H =  LDSPBK/cos(ABKYSP1H);
LDSPBK2H =  LDSPBK/cos(ABKYSP12H);
LDSPBK3H =  LDSPBK/cos(ABKYSPH);
LDSPBK4H =  LDSPBK/cos(ABKYSPH);
LDSPBK5H =  15.1  /cos(ABKYSPH);
LDSPBK5HA =   2.267/cos(ABKYSPH);
LDSPBK5HB =  LDSPBK5H-LDSPBK5HA;
DSPBK0H={'dr' '' LDSPBK0H []}';
DSPBK1H={'dr' '' LDSPBK1H []}';
DSPBK2H={'dr' '' LDSPBK2H []}';
DSPBK3H={'dr' '' LDSPBK3H []}';
DSPBK4H={'dr' '' LDSPBK4H []}';
DSPBK5HA={'dr' '' LDSPBK5HA []}';
DSPBK5HB={'dr' '' LDSPBK5HB []}';
DLDSP2H =  0.0;
LDSP2H =  43.284 +DLDSP2H;
LDSP2HB =  10.0;
LDSP2HC =  0.5285;
LDSP2HA =  LDSP2H-LDSP2HB-LDSP2HC-LBCSP1H-LBCSP2H;
DLDSP3H =  0.0;
LDSP3H =  4.6611 +DLDSP3H;
LDSP3HA =  LDSPBPM1;
LDSP3HAA =  0.1;
LDSP3HAB =  LDSP3HA-LDSP3HAA-LSB;
LDSP3HB =  0.6368;
LDSP3HD =  0.1924;
LDSP3HC =  LDSP3H-LDSP3HA-LDSP3HB-LDSP3HD;
DLDSP4H =  0.012085492416;
LDSP4H =  9.5126 -DLDSP2H-DLDSP3H+DLDSP4H;
LDSP4HA =  0.4;
LDSP4HC =  0.3459992;
LDSP4HB =  LDSP4H-LDSP4HA-LDSP4HC;
DLDSP5H =  0.0 ;%adjust position of QSP3h,QSP11h
LDSP5H =  14.474 +(LQN-LQA)/2 +DLDSP5H;
LDSP5HA =  1.424131;
LDSP5HC =  LDSPCOR2 +(LQN-LQA)/2;
LDSP5HCB =  0.1 +(LQN-LQA)/2;
LDSP5HCA =  LDSP5HC-LDSP5HCB-LSB;
LDSP5HB =  LDSP5H-LDSP5HA-LDSP5HC;
DLDSP6H =  0.0 ;%adjust position of QSP4h,QSP10h
LDSP6H =  8.6805 +(LQN-LQA)/2 -DLDSP5H+DLDSP6H ;
LDSP6HA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP6HC =  LDSPCOR1;
LDSP6HB =  LDSP6H-LDSP6HA-LDSP6HC;
DLDSP7H =  0.0 ;%adjust position of QSP5h,QSP9h
LDSP7H =  21.795894248291 -DLDSP6H+DLDSP7H;
LDSP7HA =  LDSPBPM1;
LDSP7HC =  LDSPCOR1;
LDSP7HB =  LDSP7H-LDSP7HA-LDSP7HC;
LDSP8H =  23.795894248291 -DLDSP7H;
LDSP8HA =  LDSPBPM1;
LDSP8HC =  LDSPCOR1;
LDSP8HB =  LDSP8H-LDSP8HA-LDSP8HC;
DLDSP9H =  0.0 ;%adjust length of dogleg
LDSP9H =  188.409365489746/2-3*LQR-LQA-LQE/2-LDSP5H-LDSP6H-LDSP7H-LDSP8H +DLDSP9H;
LDSP9HA =  LDSPBPM1;
LDSP9HB =  0.5;
LDSP9HC =  5.7942;
LDSP9HD =  10.6452;
LDSP9HE =  1.616;
LDSP9HG =  0.1924;
LDSP9HF =  LDSP9H-LDSP9HA-LDSP9HB-LDSP9HC-LDSP9HD-LDSP9HE-LDSP9HG;
LDSP10H =  LDSP9H;
LDSP10HA =  0.4;
LDSP10HB =  17.6279586;
LDSP10HD =  LDSPCOR1;
LDSP10HC =  LDSP10H-LDSP10HA-LDSP10HB-LDSP10HD;
LDSP11H =  LDSP8H;
LDSP11HA =  LDSPBPM1;
LDSP11HC =  0.4781;
LDSP11HB =  LDSP11H-LDSP11HA-LDSP11HC;
LDSP12H =  LDSP7H;
LDSP12HA =  0.4475;
LDSP12HB =  0.644;
LDSP12HD =  0.759;
LDSP12HE =  0.3315;
LDSP12HC =  LDSP12H-LDSP12HA-LDSP12HB-LDSP12HD-LDSP12HE;
LDSP13H =  LDSP6H;
LDSP13HB =  0.778;
LDSP13HC =  0.749 +(LQN-LQA)/2;
LDSP13HA =  LDSP13H-LDSP13HB-LDSP13HC;
LDSP14H =  LDSP5H;
LDSP14HA =  13.863119 +(LQN-LQA)/2;
LDSP14HB =  LDSP14H-LDSP14HA;
LDSP15H =  LDSP4H;
LDSP15HA =  0.5;
LDSP15HB =  0.5;
LDSP15HD =  0.1924;
LDSP15HC =  LDSP15H-LDSP15HA-LDSP15HB-LDSP15HD;
LDSP16H =  LDSP3H;
LDSP16HA =  0.4;
LDSP16HC =  LDSPCOR1;
LDSP16HB =  LDSP16H-LDSP16HA-LDSP16HC;
DLDSP17H =  -0.801500183647E-4;
LDSP17H =  LDSP2H +DLDSP17H +LBLXSPH/2-LBXSPH/2;
LDSP17HA =  LDSPBPM1;
LDSP17HB =  LDSP17H-LDSP17HA;
DSP2HA={'dr' '' LDSP2HA []}';
DSP2HB={'dr' '' LDSP2HB []}';
DSP2HC={'dr' '' LDSP2HC []}';
DSP3HA={'dr' '' LDSP3HA []}';
DSP3HAA={'dr' '' LDSP3HAA []}';
DSP3HAB={'dr' '' LDSP3HAB []}';
DSP3HB={'dr' '' LDSP3HB []}';
DSP3HC={'dr' '' LDSP3HC []}';
DSP3HD={'dr' '' LDSP3HD []}';
DSP4HA={'dr' '' LDSP4HA []}';
DSP4HB={'dr' '' LDSP4HB []}';
DSP4HC={'dr' '' LDSP4HC []}';
DSP5H={'dr' '' LDSP5H []}';
DSP5HA={'dr' '' LDSP5HA []}';
DSP5HB={'dr' '' LDSP5HB []}';
DSP5HC={'dr' '' LDSP5HC []}';
DSP5HCA={'dr' '' LDSP5HCA []}';
DSP5HCB={'dr' '' LDSP5HCB []}';
DSP6HA={'dr' '' LDSP6HA []}';
DSP6HB={'dr' '' LDSP6HB []}';
DSP6HC={'dr' '' LDSP6HC []}';
DSP7HA={'dr' '' LDSP7HA []}';
DSP7HB={'dr' '' LDSP7HB []}';
DSP7HC={'dr' '' LDSP7HC []}';
DSP8HA={'dr' '' LDSP8HA []}';
DSP8HB={'dr' '' LDSP8HB []}';
DSP8HC={'dr' '' LDSP8HC []}';
DSP9HA={'dr' '' LDSP9HA []}';
DSP9HB={'dr' '' LDSP9HB []}';
DSP9HC={'dr' '' LDSP9HC []}';
DSP9HD={'dr' '' LDSP9HD []}';
DSP9HE={'dr' '' LDSP9HE []}';
DSP9HF={'dr' '' LDSP9HF []}';
DSP9HG={'dr' '' LDSP9HG []}';
DSP10HA={'dr' '' LDSP10HA []}';
DSP10HB={'dr' '' LDSP10HB []}';
DSP10HC={'dr' '' LDSP10HC []}';
DSP10HD={'dr' '' LDSP10HD []}';
DSP11HA={'dr' '' LDSP11HA []}';
DSP11HB={'dr' '' LDSP11HB []}';
DSP11HC={'dr' '' LDSP11HC []}';
DSP12HA={'dr' '' LDSP12HA []}';
DSP12HB={'dr' '' LDSP12HB []}';
DSP12HC={'dr' '' LDSP12HC []}';
DSP12HC1={'dr' '' 9.035399208502 []}';
DSP12HC2={'dr' '' 0.30541 []}';
DSP12HC3={'dr' '' 0.30541 []}';
DSP12HC4={'dr' '' DSP12HC{3}-DSP12HC1{3}-DSP12HC2{3}-DSP12HC3{3} []}';
DSP12HD={'dr' '' LDSP12HD []}';
DSP12HE={'dr' '' LDSP12HE []}';
DSP13HA={'dr' '' LDSP13HA []}';
DSP13HB={'dr' '' LDSP13HB []}';
DSP13HC={'dr' '' LDSP13HC []}';
DSP14HA={'dr' '' LDSP14HA []}';
DSP14HB={'dr' '' LDSP14HB []}';
DSP15H={'dr' '' LDSP15H []}';
DSP15HA={'dr' '' LDSP15HA []}';
DSP15HB={'dr' '' LDSP15HB []}';
DSP15HC={'dr' '' LDSP15HC []}';
DSP15HD={'dr' '' LDSP15HD []}';
DSP16HA={'dr' '' LDSP16HA []}';
DSP16HB={'dr' '' LDSP16HB []}';
DSP16HC={'dr' '' LDSP16HC []}';
DSP17HA={'dr' '' LDSP17HA []}';
DSP17HB={'dr' '' LDSP17HB []}';
LDSPQ1 =  45.126;
LDSPQ1A =  23.0;
LDSPQ1C =  LDSPCOR1;
LDSPQ1B =  LDSPQ1-LDSPQ1A-LDSPQ1C;
DLDSPQ2 =  0.0;
LDSPQ2 =  1.8 +DLDSPQ2;
LDSPQ2A =  0.5913;
LDSPQ2C =  0.4781;
LDSPQ2B =  LDSPQ2-LDSPQ2A-LDSPQ2C;
LDSPQ3 =  16.124 -DLDSPQ2 ;
LDSPQ3A =  0.4285;
LDSPQ3B =  LDSPQ3-LDSPQ3A;
DSPQ1A={'dr' '' LDSPQ1A []}';
DSPQ1B={'dr' '' LDSPQ1B []}';
DSPQ1C={'dr' '' LDSPQ1C []}';
DSPQ2A={'dr' '' LDSPQ2A []}';
DSPQ2B={'dr' '' LDSPQ2B []}';
DSPQ2C={'dr' '' LDSPQ2C []}';
DSPQ3A={'dr' '' LDSPQ3A []}';
DSPQ3B={'dr' '' LDSPQ3B []}';
LDSPBK0S =  LDSPBK;
LDSPBK1S =  LDSPBK/cos(ABKYSP1S);
LDSPBK2S =  LDSPBK/cos(ABKYSP12S);
LDSPBK3S =  LDSPBK/cos(ABKYSPS);
LDSPBK4S =  LDSPBK/cos(ABKYSPS);
LDSPBK5S =  15.1  /cos(ABKYSPS);
LDSPBK5SA =   2.267/cos(ABKYSPS);
LDSPBK5SB =  LDSPBK5S-LDSPBK5SA;
DSPBK0S={'dr' '' LDSPBK0S []}';
DSPBK1S={'dr' '' LDSPBK1S []}';
DSPBK2S={'dr' '' LDSPBK2S []}';
DSPBK3S={'dr' '' LDSPBK3S []}';
DSPBK4S={'dr' '' LDSPBK4S []}';
DSPBK5SA={'dr' '' LDSPBK5SA []}';
DSPBK5SB={'dr' '' LDSPBK5SB []}';
DLDSP2S =  0.0;
DLDSP2SA =  -0.781886051378E-6;
LDSP2S =  32.6265 +(LQN-LQA)/2 +DLDSP2S +DLDSP2SA;
LDSP2SB =  11.8;
LDSP2SC =  0.6676 +(LQN-LQA)/2;
LDSP2SA =  LDSP2S-LDSP2SB-LDSP2SC-LBCSP1S-LBCSP2S;
DLDSP3S =  0.0;
LDSP3S =  1.828 +(LQN-LQA) +DLDSP3S;
LDSP3SA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP3SAA =  0.1 +(LQN-LQA)/2;
LDSP3SAB =  LDSP3SA-LDSP3SAA-LSB;
LDSP3SB =  0.6445;
LDSP3SC =  LDSP3S-LDSP3SA-LDSP3SB;
LDSP4S =  8.689 +(LQN-LQA)/2 -DLDSP2S -DLDSP3S;
LDSP4SA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP4SB =  0.6445;
LDSP4SD =  0.3442954;
LDSP4SC =  LDSP4S-LDSP4SA-LDSP4SB-LDSP4SD;
DLDSP5S =  0.0;
LDSP5S =  6.512 +(LQN-LQA)/2 +DLDSP5S;
LDSP5SB =  LDSPCOR2 +(LQN-LQA)/2;
LDSP5SA =  LDSP5S-LDSP5SB;
DLDSP6S =  0.0;
LDSP6S =  2.5925 +(LQN-LQA)/2 +DLDSP6S;
LDSP6SA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP6SC =  LDSPCOR1;
LDSP6SB =  LDSP6S-LDSP6SA-LDSP6SC;
LDSP7S =  56.746/2-LQA-1.5*LQR-LDSP5S-LDSP6S;
LDSP7SA =  LDSPBPM1;
LDSP7SB =  1.2814;
LDSP7SD =  LDSPCOR1;
LDSP7SC =  LDSP7S-LDSP7SA-LDSP7SB-LDSP7SD;
LDSP8S =  LDSP7S;
LDSP8SA =  LDSPBPM1;
LDSP8SB =  1.9614;
LDSP8SC =  7.810257;
LDSP8SE =  LDSPCOR1;
LDSP8SD =  LDSP8S-LDSP8SA-LDSP8SB-LDSP8SC-LDSP8SE;
LDSP9S =  LDSP6S;
LDSP9SA =  LDSPBPM1;
LDSP9SC =  LDSPCOR2 +(LQN-LQA)/2;
LDSP9SB =  LDSP9S-LDSP9SA-LDSP9SC;
LDSP10S =  LDSP5S;
LDSP10SA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP10SB =  LDSP10S-LDSP10SA;
LDSP11S =  LDSP4S;
LDSP11SA =  0.5;
LDSP11SB =  0.5;
LDSP11SC =  0.5;
LDSP11SE =  LDSPCOR2 +(LQN-LQA)/2;
LDSP11SD =  LDSP11S-LDSP11SA-LDSP11SB-LDSP11SC-LDSP11SE;
LDSP12S =  LDSP3S;
LDSP12SA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP12SC =  LDSPCOR2 +(LQN-LQA)/2;
LDSP12SCB =  0.1 +(LQN-LQA)/2;
LDSP12SCA =  LDSP12SC-LDSP12SCB-LSB;
LDSP12SB =  LDSP12S-LDSP12SA-LDSP12SC;
DLDSP13S =  -0.406195675138E-4;
LDSP13S =  LDSP2S +DLDSP13S +LBLXSPS/2-LBXSPS/2;
LDSP13SA =  LDSPBPM2 +(LQN-LQA)/2;
LDSP13SB =  LDSP13S-LDSP13SA;
DSP2SA={'dr' '' LDSP2SA []}';
DSP2SB={'dr' '' LDSP2SB []}';
DSP2SC={'dr' '' LDSP2SC []}';
DSP3SA={'dr' '' LDSP3SA []}';
DSP3SAA={'dr' '' LDSP3SAA []}';
DSP3SAB={'dr' '' LDSP3SAB []}';
DSP3SB={'dr' '' LDSP3SB []}';
DSP3SC={'dr' '' LDSP3SC []}';
DSP4SA={'dr' '' LDSP4SA []}';
DSP4SB={'dr' '' LDSP4SB []}';
DSP4SC={'dr' '' LDSP4SC []}';
DSP4SD={'dr' '' LDSP4SD []}';
DSP5SA={'dr' '' LDSP5SA []}';
DSP5SB={'dr' '' LDSP5SB []}';
DSP6SA={'dr' '' LDSP6SA []}';
DSP6SB={'dr' '' LDSP6SB []}';
DSP6SC={'dr' '' LDSP6SC []}';
DSP7SA={'dr' '' LDSP7SA []}';
DSP7SB={'dr' '' LDSP7SB []}';
DSP7SC={'dr' '' LDSP7SC []}';
DSP7SD={'dr' '' LDSP7SD []}';
DSP8SA={'dr' '' LDSP8SA []}';
DSP8SB={'dr' '' LDSP8SB []}';
DSP8SC={'dr' '' LDSP8SC []}';
DSP8SD={'dr' '' LDSP8SD []}';
DSP8SE={'dr' '' LDSP8SE []}';
DSP9SA={'dr' '' LDSP9SA []}';
DSP9SB={'dr' '' LDSP9SB []}';
DSP9SC={'dr' '' LDSP9SC []}';
DSP10SA={'dr' '' LDSP10SA []}';
DSP10SB={'dr' '' LDSP10SB []}';
DSP11SA={'dr' '' LDSP11SA []}';
DSP11SB={'dr' '' LDSP11SB []}';
DSP11SC={'dr' '' LDSP11SC []}';
DSP11SD={'dr' '' LDSP11SD []}';
DSP11SE={'dr' '' LDSP11SE []}';
DSP12SA={'dr' '' LDSP12SA []}';
DSP12SB={'dr' '' LDSP12SB []}';
DSP12SC={'dr' '' LDSP12SC []}';
DSP12SCA={'dr' '' LDSP12SCA []}';
DSP12SCB={'dr' '' LDSP12SCB []}';
DSP13SA={'dr' '' LDSP13SA []}';
DSP13SB={'dr' '' LDSP13SB []}';
DSP13SB1={'dr' '' 9.337992506693 []}';
DSP13SB2={'dr' '' 0.30541 []}';
DSP13SB3={'dr' '' 0.30541 []}';
DSP13SB4={'dr' '' DSP13SB{3}-DSP13SB1{3}-DSP13SB2{3}-DSP13SB3{3} []}';
LDSP2DA2 =  2.0;
LDSP2DA1 =  23.0-4.457-LDSP2DA2 ;%adjusted for DASEL
LDSP2DB =  1.657;
LDSP2DC1 =  27.25 +3.685 ;%adjustment for DASEL with 25G kickers
LDSP2DD =  LDSPCOR1;
DLDSP3D =  0.0;
LDSP3D =  3.317 +DLDSP3D;
LDSP3DA =  LDSPBPM1;
LDSP3DB =  0.6234;
LDSP3DD =  0.4781+0.3048 ;%=0.7829
LDSP3DC =  LDSP3D-LDSP3DA-LDSP3DB-LDSP3DD;
LDSP4D =  4.5085 -DLDSP3D;
LDSP4DA =  0.4285;
LDSP4DB =  LDSP4D-LDSP4DA;
LDSP2DC2 =  76.149-LDSP2DA1-LDSP2DA2-LDSP2DB-LDSP2DC1-LDSP2DD-LDSP3D-LDSP4D;
LDSP5D =  73.0 ;%distance between two bends
LDSP5DA =  6.2732486;
LDSP5DB =  45.575+1.0-LDSP5DA-LBYSPD/2;
LDSP5DD =  0.2298134+0.609623481 ;%=0.839436881
LDSP5DC =  LDSP5D-LDSP5DA-LDSP5DB-LDSP5DD;
DLDSP6D =  0.0 ;%adjust Z at muon wall
LDSP6D =  143.648999999997-0.4 +18.115253 -0.761425 +DLDSP6D;
LDSP6DA =  0.5;
LDSP6DB =  0.5;
LDSP6DC =  1.0;
LDSP6DD =  0.3048;
LDSP6DE =  1.1952;
LDSP6DG =  0.5;
LDSP6DH =  0.5;
LDSP6DI =  0.5;
LDSP6DJ =  37.0 +18.0 -0.761425;
LDSP6DF =  LDSP6D-LDSP6DA-LDSP6DB-LDSP6DC-LDSP6DD-LDSP6DE-LDSP6DG-LDSP6DH -LDSP6DI-LDSP6DJ;
LDSP6DFA =  4.287828;
LDSP6DFC =  0.5;
LDSP6DFD =  1.0;
LDSP6DFB =  LDSP6DF-LDSP6DFA-LDSP6DFC-LDSP6DFD;
LDSP7D =  20.0818610101+0.4+0.803391932471 -18.115253 +0.761425;
LDSP7DB =  1.5;
LDSP7DA =  LDSP7D-LDSP7DB-LPCSP;
LDSP7DAA =  0.5;
LDSP7DAB =  LDSP7DA-LDSP7DAA;
DSP2DA1={'dr' '' LDSP2DA1 []}';
DSP2DA2={'dr' '' LDSP2DA2 []}';
DSP2DB={'dr' '' LDSP2DB []}';
DSP2DC1={'dr' '' LDSP2DC1 []}';
DSP2DC2={'dr' '' LDSP2DC2 []}';
DSP2DD={'dr' '' LDSP2DD []}';
DSP3DA={'dr' '' LDSP3DA []}';
DSP3DB={'dr' '' LDSP3DB []}';
DSP3DC={'dr' '' LDSP3DC []}';
DSP3DD={'dr' '' LDSP3DD []}';
DSP4DA={'dr' '' LDSP4DA []}';
DSP4DB={'dr' '' LDSP4DB []}';
DSP5DA={'dr' '' LDSP5DA []}';
DSP5DB={'dr' '' LDSP5DB []}';
DSP5DC={'dr' '' LDSP5DC []}';
DSP5DC1={'dr' '' 0.694411378263 []}';
DSP5DC2={'dr' '' 0.30541 []}';
DSP5DC3={'dr' '' 0.30541 []}';
DSP5DC4={'dr' '' DSP5DC{3}-DSP5DC1{3}-DSP5DC2{3}-DSP5DC3{3} []}';
DSP5DD={'dr' '' LDSP5DD []}';
DSP6DA={'dr' '' LDSP6DA []}';
DSP6DB={'dr' '' LDSP6DB []}';
DSP6DC={'dr' '' LDSP6DC []}';
DSP6DD={'dr' '' LDSP6DD []}';
DSP6DE={'dr' '' LDSP6DE []}';
DSP6DF={'dr' '' LDSP6DF []}';
DSP6DFA={'dr' '' LDSP6DFA []}';
DSP6DFB={'dr' '' LDSP6DFB []}';
DSP6DFC={'dr' '' LDSP6DFC []}';
DSP6DFD={'dr' '' LDSP6DFD []}';
DSP6DG={'dr' '' LDSP6DG []}';
DSP6DH={'dr' '' LDSP6DH []}';
DSP6DI={'dr' '' LDSP6DI []}';
DSP6DJ={'dr' '' LDSP6DJ []}';
DSP7DAA={'dr' '' LDSP7DAA []}';
DSP7DAB={'dr' '' LDSP7DAB []}';
DSP7DB={'dr' '' LDSP7DB []}';
DWALLAD={'dr' '' 1.840975 []}';%distance from face of muon wall to BSY dump
DDUMPBSY={'dr' '' 61.120*IN2M []}';%length of BSY dump (per A. Ibrahimov)
% markers
CNTSP1S={'mo' 'CNTSP1S' 0 []}';
CNTSP2S={'mo' 'CNTSP2S' 0 []}';
CNTSP1H={'mo' 'CNTSP1H' 0 []}';
CNTSP2H={'mo' 'CNTSP2H' 0 []}';
CNTSP3H={'mo' 'CNTSP3H' 0 []}';
CNTSP1D={'mo' 'CNTSP1D' 0 []}';
RWWAKE3D={'mo' 'RWWAKE3D' 0 []}';%SPRDD/BSY beampipe wake applied here
MUWALLD={'mo' 'MUWALLD' 0 []}';%front face of muon wall for dump beam
DUMPBSY={'mo' 'DUMPBSY' 0 []}';%front face of BSY dump
% monitors
BPMSPH={'mo' 'BPMSPH' 0 []}';
BPMSPS={'mo' 'BPMSPS' 0 []}';
BPMSP1={'mo' 'BPMSP1' 0 []}';
BPMSP2={'mo' 'BPMSP2' 0 []}';
BPMSP1H={'mo' 'BPMSP1H' 0 []}';
BPMSP2H={'mo' 'BPMSP2H' 0 []}';
BPMSP3H={'mo' 'BPMSP3H' 0 []}';
BPMSP4H={'mo' 'BPMSP4H' 0 []}';
BPMSP5H={'mo' 'BPMSP5H' 0 []}';
BPMSP6H={'mo' 'BPMSP6H' 0 []}';
BPMSP7H={'mo' 'BPMSP7H' 0 []}';
BPMSP8H={'mo' 'BPMSP8H' 0 []}';
BPMSP9H={'mo' 'BPMSP9H' 0 []}';
BPMSP10H={'mo' 'BPMSP10H' 0 []}';
BPMSP11H={'mo' 'BPMSP11H' 0 []}';
BPMSP12H={'mo' 'BPMSP12H' 0 []}';
BPMSP13H={'mo' 'BPMSP13H' 0 []}';
BPMSP1S={'mo' 'BPMSP1S' 0 []}';
BPMSP2S={'mo' 'BPMSP2S' 0 []}';
BPMSP3S={'mo' 'BPMSP3S' 0 []}';
BPMSP4S={'mo' 'BPMSP4S' 0 []}';
BPMSP5S={'mo' 'BPMSP5S' 0 []}';
BPMSP6S={'mo' 'BPMSP6S' 0 []}';
BPMSP7S={'mo' 'BPMSP7S' 0 []}';
BPMSP8S={'mo' 'BPMSP8S' 0 []}';
BPMSP9S={'mo' 'BPMSP9S' 0 []}';
BPMSP1D={'mo' 'BPMSP1D' 0 []}';
BPMSP2D={'mo' 'BPMSP2D' 0 []}';
BPMSP3D={'mo' 'BPMSP3D' 0 []}';%has been already ordered
BPMSP4D={'mo' 'BPMSP4D' 0 []}';
BPMSP5D={'mo' 'BPMSP5D' 0 []}';%large aperture BPM for raster
MRFBSP1D={'mo' 'MRFBSP1D' 0 []}';%MONI, TYPE="CavityS-1" make RF-bpm if spreader is RF
MRFBSP2D={'mo' 'MRFBSP2D' 0 []}';%MONI, TYPE="CavityS-1" make RF-bpm if spreader is RF
% steering correctors
XCSP1H={'mo' 'XCSP1H' 0 []}';
XCSP3H={'mo' 'XCSP3H' 0 []}';
XCSP5H={'mo' 'XCSP5H' 0 []}';
XCSP7H={'mo' 'XCSP7H' 0 []}';
XCSP9H={'mo' 'XCSP9H' 0 []}';
XCSP11H={'mo' 'XCSP11H' 0 []}';
XCSP13H={'mo' 'XCSP13H' 0 []}';
YCSP2H={'mo' 'YCSP2H' 0 []}';
YCSP4H={'mo' 'YCSP4H' 0 []}';
YCSP6H={'mo' 'YCSP6H' 0 []}';
YCSP8H={'mo' 'YCSP8H' 0 []}';
YCSP10H={'mo' 'YCSP10H' 0 []}';
YCSP12H={'mo' 'YCSP12H' 0 []}';
XCSP1={'mo' 'XCSP1' 0 []}';
YCSP2={'mo' 'YCSP2' 0 []}';
XCSP1S={'mo' 'XCSP1S' 0 []}';
XCSP3S={'mo' 'XCSP3S' 0 []}';
XCSP5S={'mo' 'XCSP5S' 0 []}';
XCSP7S={'mo' 'XCSP7S' 0 []}';
XCSP9S={'mo' 'XCSP9S' 0 []}';
YCSP2S={'mo' 'YCSP2S' 0 []}';
YCSP4S={'mo' 'YCSP4S' 0 []}';
YCSP6S={'mo' 'YCSP6S' 0 []}';
YCSP8S={'mo' 'YCSP8S' 0 []}';
XCSP1D={'mo' 'XCSP1D' 0 []}';
XCSP3D={'mo' 'XCSP3D' 0 []}';
XCSP5D={'mo' 'XCSP5D' 0 []}';
YCSP2D={'mo' 'YCSP2D' 0 []}';
YCSP4D={'mo' 'YCSP4D' 0 []}';
YCSP6D={'mo' 'YCSP6D' 0 []}';
% rastering kickers operating at ~60 Hz with 90 deg phase between each other
BKXRASD={'mo' 'BKXRASD' 0 []}';
BKYRASD={'mo' 'BKYRASD' 0 []}';
% SROT to remove rotation angle
AROSP1H =   0.414577244197E-5;
AROSP2H =   0.947723870567E-5;
AROSP3H =  -AROSP2H;
AROSP1S =  -0.829141820709E-5;
ROSP1H={'ro' 'ROSP1H' 0 [-(AROSP1H)]}';
ROSP2H={'ro' 'ROSP2H' 0 [-(AROSP2H)]}';
ROSP3H={'ro' 'ROSP3H' 0 [-(AROSP3H)]}';
ROSP1S={'ro' 'ROSP1S' 0 [-(AROSP1S)]}';
% other diagnostic
IMSP0H={'mo' 'IMSP0H' 0 []}';%diagnostic ACM in SPH
IMSP0S={'mo' 'IMSP0S' 0 []}';%diagnostic ACM in SPS
IMSP0D={'mo' 'IMSP0D' 0 []}';%diagnostic ACM in SPD
IMBCSH1={'mo' 'IMBCSH1' 0 []}';%BCS ACM triplet in SPH
IMBCSH2={'mo' 'IMBCSH2' 0 []}';%BCS ACM triplet in SPH
IMBCSH3={'mo' 'IMBCSH3' 0 []}';%BCS ACM triplet in SPH
IMBCSS1={'mo' 'IMBCSS1' 0 []}';%BCS ACM triplet in SPS
IMBCSS2={'mo' 'IMBCSS2' 0 []}';%BCS ACM triplet in SPS
IMBCSS3={'mo' 'IMBCSS3' 0 []}';%BCS ACM triplet in SPS
IMBCSD1={'mo' 'IMBCSD1' 0 []}';%BCS ACM triplet in SPD
IMBCSD2={'mo' 'IMBCSD2' 0 []}';%BCS ACM triplet in SPD
IMBCSD3={'mo' 'IMBCSD3' 0 []}';%BCS ACM triplet in SPD
PCSP3D={'dr' 'PCSP3D' LPCSP []}';%BCS protection collimator
BTMSP3D={'mo' 'BTMSP3D' 0 []}';%Burn-Through-Monitor behind PCSP3d
BTMSPDMP={'mo' 'BTMSPDMP' 0 []}';%Burn-Through-Monitor behind BSY dump
WSSP1D={'mo' 'WSSP1D' 0 []}';%to measure beam size and energy before BSY dump
OTRSPDMP={'mo' 'OTRSPDMP' 0 []}';%OTR screen before BSY dump
% beamlines
SPRDKH=[BKYSP0HA,BKYSP0HB,DSPBK0H,BKYSP1HA,BKYSP1HB,DSPBK1H,BKYSP2HA,BKYSP2HB,DSPBK2H,BKYSP3HA,BKYSP3HB,DSPBK3H,BKYSP4HA,BKYSP4HB,DSPBK4H,BKYSP5HA,BKYSP5HB,DSPBK5HA,BPMSPH,DSPBK5HB,BLXSPHA ,BLXSPHB ];
SPRDKSA=[DSPQ1A,BPMSP1,DSPQ1B,DSPQ1C,QSP1,QSP1,DSPQ2A,XCSP1 ,DSPQ2B,BPMSP2,DSPQ2C,QSP2,QSP2,DSPQ3A,YCSP2 ,DSPQ3B];
SPRDKSB=[BKYSP0SA,BKYSP0SB,DSPBK0S,BKYSP1SA,BKYSP1SB,DSPBK1S,BKYSP2SA,BKYSP2SB,DSPBK2S,BKYSP3SA,BKYSP3SB,DSPBK3S,BKYSP4SA,BKYSP4SB,DSPBK4S,BKYSP5SA,BKYSP5SB,DSPBK5SA,BPMSPS,DSPBK5SB,BLXSPSA ,BLXSPSB ];
SPRDKS=[SPRDKSA,SPRDKSB];
SPRDHA=[ROSP1H  ,DSP2HA ,BYSP1HA,BYSP1HB ,DSP2HB ,BYSP2HA,BYSP2HB ,CNTSP1H,DSP2HC  ,QSP1H  ,QSP1H   ,DSP3HAA,SSP1H  ,SSP1H   ,DSP3HAB,BPMSP1H ,DSP3HB ,XCSP1H  ,DSP3HC ,DSP3HD ,QSP2H  ,BPMSP2H ,QSP2H  ,DSP4HA  ,YCSP2H ,DSP4HB ,IMSP0H  ,DSP4HC ,BRSP1HA,BRSP1HB ,ROSP2H ,DSP5HA  ,DSP5HB ,XCSP3H  ,DSP5HCA,SSP2H  ,SSP2H   ,DSP5HCB,QSP3H  ,QSP3H   ,DSP6HA ,BPMSP3H ,DSP6HB ,YCSP4H  ,DSP6HC ,QSP4H  ,QSP4H   ,DSP7HA ,BPMSP4H ,DSP7HB ,XCSP5H  ,DSP7HC ,QSP5H  ,QSP5H   ,DSP8HA ,BPMSP5H ,DSP8HB ,YCSP6H  ,DSP8HC ,QSP6H  ,QSP6H   ,DSP9HA ,BPMSP6H ,DSP9HB ,DSP9HC ,DSP9HD ,DSP9HE ,DSP9HF ,DSP9HG ,QSP7H  ,BPMSP7H ,QSP7H  ,DSP10HA ,XCSP7H ,DSP10HB,DSP10HC,YCSP8H  ,DSP10HD,QSP8H  ,QSP8H   ,DSP11HA,BPMSP8H ,DSP11HB,DSP11HC,QSP9H  ,QSP9H   ,DSP12HA,BPMSP9H ,DSP12HB,XCSP9H  ,DSP12HC1,IMBCSH1 ,DSP12HC2,IMBCSH2 ,DSP12HC3,IMBCSH3 ,DSP12HC4,BPMSP10H,DSP12HD,YCSP10H ,DSP12HE,QSP10H ,QSP10H  ,DSP13HA,XCSP11H ,DSP13HB,BPMSP11H,DSP13HC,QSP11H ,QSP11H  ,DSP14HA,WOODDOOR];
SPRDHB=[DSP14HB ,ROSP3H ,BRSP2HA,BRSP2HB ,CNTSP2H,DSP15HA ,DSP15HB,DSP15HC ,DSP15HD,QSP12H ,BPMSP12H,QSP12H ,DSP16HA ,YCSP12H,DSP16HB,XCSP13H ,DSP16HC,QSP13H ,QSP13H  ,DSP17HA,BPMSP13H,DSP17HB,BXSP1HA,BXSP1HB ,CNTSP3H];
SPRDH=[SPRDKH,SPRDHA,SPRDHB];
SPRDSA=[SPRDKH,SPRDKS];
SPRDSB=[ROSP1S ,DSP2SA ,BYSP1SA,BYSP1SB,DSP2SB ,BYSP2SA,BYSP2SB,CNTSP1S,DSP2SC ,QSP1S  ,QSP1S  ,DSP3SAA,SSP1S  ,SSP1S,  DSP3SAB,BPMSP1S,DSP3SB ,XCSP1S ,DSP3SC ,QSP2S  ,QSP2S  ,DSP4SA ,BPMSP2S,DSP4SB ,YCSP2S ,DSP4SC ,IMSP0S ,DSP4SD ,BXSP1SA,BXSP1SB,DSP5SA ,XCSP3S ,DSP5SB ,QSP3S  ,QSP3S  ,DSP6SA ,BPMSP3S,DSP6SB ,YCSP4S ,DSP6SC ,QSP4S  ,QSP4S  ,DSP7SA ,BPMSP4S,DSP7SB ,DSP7SC,XCSP5S ,DSP7SD ,QSP5S  ,QSP5S  ,DSP8SA ,BPMSP5S,DSP8SB ,DSP8SC ,DSP8SD ,YCSP6S ,DSP8SE ,QSP6S  ,QSP6S  ,DSP9SA ,BPMSP6S,DSP9SB ,XCSP7S ,DSP9SC ,QSP7S  ,QSP7S  ,DSP10SA,BPMSP7S,DSP10SB,BXSP2SA,BXSP2SB,DSP11SA,DSP11SB,DSP11SC,DSP11SD,YCSP8S ,DSP11SE,QSP8S  ,QSP8S  ,DSP12SA,BPMSP8S,DSP12SB,XCSP9S ,DSP12SCA,SSP2S  ,SSP2S  ,DSP12SCB,QSP9S  ,QSP9S  ,DSP13SA,BPMSP9S,DSP13SB1,IMBCSS1 ,DSP13SB2,IMBCSS2 ,DSP13SB3,IMBCSS3 ,DSP13SB4,BXSP3SA,BXSP3SB,CNTSP2S];
SPRDS=[SPRDSA,SPRDSB];
SPRDDA=[DSP2DA1,MRFBSP1D,DSP2DA2,BPMSP1D,DSP2DB];
SPRDDB=[DSP2DC1];
SPRDDC=[DSP2DC2,XCSP1D  ,DSP2DD ,QSP1D  ,QSP1D  ,DSP3DA          ,DSP3DB ,IMSP0D  ,DSP3DC ,MRFBSP2D,BPMSP2D ,DSP3DD ,QSP2D  ,QSP2D  ,DSP4DA ,YCSP2D  ,DSP4DB ,BYSP1DA,BYSP1DB,DSP5DA ,         DSP5DB,WSSP1D  ,DSP5DC1,IMBCSD1,DSP5DC2,IMBCSD2,DSP5DC3,IMBCSD3,DSP5DC4,BPMSP3D ,DSP5DD ,BYSP2DA,BYSP2DB,CNTSP1D,DSP6DA  ,XCSP3D ,DSP6DB ,YCSP4D  ,DSP6DC ,DSP6DD ,DSP6DE ,DSP6DFA,WOODDOOR];
SPRDDD=[DSP6DFB,XCSP5D  ,DSP6DFC,YCSP6D  ,DSP6DFD,BPMSP4D ,DSP6DG ,DSP6DH ,RWWAKE3D,BKXRASD ,DSP6DI ,BKYRASD ,DSP6DJ ,BPMSP5D ,DSP7DAA,OTRSPDMP,DSP7DAB,PCSP3D  ,BTMSP3D,DSP7DB ,MUWALLD ,DWALLAD,DUMPBSY,DDUMPBSY,BTMSPDMP];
SPRDD=[SPRDKH,SPRDKS,SPRDDA,SPRDDB,SPRDDC,SPRDDD];

% ==============================================================================
% DC spreader option (HXR): single type-5 corrector (SA-388-310-30)
GBSPDC =  0.0254       ;%wrapped around a 2" OD pipe (m)
ZBSPDC =  0.3375       ;%measured B vs Z (m)
FBSPDC =  0.5          ;%dummy
ABSPDC =  -0.75E-3     ;%total HXR spreader y-angle (rad)
BLSPDC =  BRHOF*ABSPDC ;%kG-m
ABSPDC_2 =  ABSPDC*ABSPDC;
ABSPDC_4 =  ABSPDC_2*ABSPDC_2;
ABSPDC_6 =  ABSPDC_4*ABSPDC_2;
SINCABSPDC =  1-ABSPDC_2/6+ABSPDC_4/120-ABSPDC_6/5040 ;%~sinc(x)=sin(x)/x
LBSPDC =  ZBSPDC/SINCABSPDC;
ABSPDCS =  asin(sin(ABSPDC)/2);
ABSPDCS_2 =  ABSPDCS*ABSPDCS;
ABSPDCS_4 =  ABSPDCS_2*ABSPDCS_2;
ABSPDCS_6 =  ABSPDCS_4*ABSPDCS_2;
SINCABSPDCS =  1-ABSPDCS_2/6+ABSPDCS_4/120-ABSPDCS_6/5040 ;%~sinc(x)=sin(x)/x
LBSPDCS =  ZBSPDC/(2*SINCABSPDCS);
ABSPDCL =  ABSPDC-ABSPDCS;
LBSPDCL =  LBSPDC-LBSPDCS;
BYSPHA={'be' 'BYSPH' LBSPDCL [ABSPDCL GBSPDC 0 0 FBSPDC 0 pi/2]}';
BYSPHB={'be' 'BYSPH' LBSPDCS [ABSPDCS GBSPDC 0 ABSPDC 0 FBSPDC pi/2]}';
LZSPDC =  23.1 ;%Z distance from BEGSPH to BLXSPH center (m)
LDSPDC =  LZSPDC-LBLSP/2-ZBSPDC ;%sum of drift lengths (m)
DSPDC1={'dr' '' 2.931253585645 []}';%BEGSPH to BYSPH
DSPDC2={'dr' '' (LDSPDC-DSPDC1{3})/cos(ABSPDC) []}';%BYSPH to BLXSPH
DSPDC2B={'dr' '' 12.833/cos(ABSPDC) []}';%BPMSPH to BLXSPH
DSPDC2A={'dr' '' DSPDC2{3}-DSPDC2B{3} []}';%BYSPH to BPMSPH
SPRDKHDC=[DSPDC1,BYSPHA,BYSPHB,DSPDC2A,BPMSPH,DSPDC2B,BLXSPHA,BLXSPHB];
% DC spreader option (SXR): single type-5 corrector (SA-388-310-30)
BYSPSA={'be' 'BYSPS' LBSPDCL [ABSPDCL GBSPDC 0 0 FBSPDC 0 pi/2]}';
BYSPSB={'be' 'BYSPS' LBSPDCS [ABSPDCS GBSPDC 0 ABSPDC 0 FBSPDC pi/2]}';
SPRDKSBDC=[DSPDC1,BYSPSA,BYSPSB,DSPDC2A,BPMSPS,DSPDC2B,BLXSPSA,BLXSPSB];
% BDES and IDES
BDES =  BLSPDC;
IDES =  47.04*BDES+671*BDES^3;

% ------------------------------------------------------------------------------

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc transport from Cu-linac to SXR
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 28-MAY-2019, M. Woodley
%  * relocate XCCUS1, YCCUS2, and BPMCUS3 per L. Borzenets
% 13-MAY-2019, M. Woodley
%  * change length of STCLTS to 30" and move 5.1 cm d/s per A. Ibrahimov
% 30-APR-2019, M. Woodley
%  * use measured FINT=0.4861 for 1.0D38.37 @ 200A
% ------------------------------------------------------------------------------
% 04-OCT-2018, M. Woodley
%  * include alternative DC extraction into CUSXR
%  * replace 1.0D22.265 dipoles (BYCUS1&2) with 3D8.8MK3 corrector magnets
% 15-AUG-2018, M. Woodley
%  * add STCLTS (PEP-II insertable PPS stopper) between QCUS8 and QCUS9
% 04-MAY-2018, M. Woodley
%  * undefer everything (LCLS pays)
% ------------------------------------------------------------------------------
% 02-NOV-2016, Y. Nosochkov
%  * minor adjustment to kicker angle
%  * add a note that BRCUS1 is a special merge DC-bend which is turned ON
%    for CURF beam to SXR or OFF for SCRF beam to SXR
% ------------------------------------------------------------------------------
% 24-JUN-2016, Y. Nosochkov
%  * add deferred BPMCUS between kicker and septum
%  * move BPMs inside the quads QCUS4, QCUS5, QCUS7
%  * update the engineering type of BKRCUS kicker to "1.92K41.2" (J. Amann)
%  * remove corrector dipoles BRCCUS1&2, rematch geometry and optics
% ------------------------------------------------------------------------------
% 26-FEB-2016, M. Woodley
%  * remove SEQnn MARKers
% 26-FEB-2016, Y. Nosochkov
%  * replace 5 kickers (based on spreader kicker design) with one kicker
%    based on BYKIK1 design (per T. Beukers)
%  * increase CUSXR length by 1.2 m to avoid interference with A-line kicker
%    (septum and first 3 quad positions are not changed, but the rest is moved
%    downstream while keeping the CUSXR symmetry) 
% ------------------------------------------------------------------------------
% 25-SEP-2015, Y. Nosochkov
%  * update definitions of kickers, septum and last DC bend to allow
%    zero angle
% 24-AUG-2015, Y. Nosochkov
%  * move BPMCUS2 downstream of QCUS2
%  * move XCCUS10 upstream of QCUS10
%  * replace the first DC bend with a fast kicker and a septum (deferred at @3)
%  * increase the distance from first/last bend to the nearest quad
%  * add two corrector bends to cancel the kicker orbit and dispersion (at @3)
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * add additional deferred quadrupole at center of CUSXR
%  * rename some magnets/devices to put the names in order
%  * change magnet type of QCUS4, QCUS5, QCUS6, QCUS7 from 2Q10 to 1.085Q4.31
%  * change BPM type at 2Q10 to Stripline-5, and at 1.085Q4.31 to Stripline-2
%  * move BPMs outside of the quads
%  * adjust distance from BPM/corr to the quad
% ------------------------------------------------------------------------------
% 20-MAR-2015, M. Woodley
%  * move definitions of BEGCUSXR and ENDCUSXR MARKERs to common.xsif
%  * add SEQ20BEG and SEQ20END MARKERs
% 12-MAR-2015, Y. Nosochkov
%  * add a dogleg transport line from Cu-linac to SXR (deferred to level 3)
% ------------------------------------------------------------------------------
% XYZ (linac system) at entrance of the kicker (BEGCLTS)
XCUS1 =  -3.309962022E-7 ;%per existing LCLS-1 coordinates
YCUS1 =   0.0;
ZCUS1 =   3058.456916    ;%moved upstream for CUSXR DC extraction
THCUS1 =   0.0;
PHCUS1 =   0.0;
PSCUS1 =   0.0;
% XYZ (linac system) at exit of the last bend (ENDCUSXR)
XCUS2 =  -25.610*IN2M;
YCUS2 =   25.570*IN2M;
ZCUS2 =   3177.65;
THCUS2 =   0.0;
PHCUS2 =   0.0;
PSCUS2 =   0.0;
% Twiss at BEGCLTS
TBXCUS1 =  28.733475248907;
TBYCUS1 =  51.61209559579;
TAXCUS1 =  -0.11996119728;
TAYCUS1 =   0.738889504715;
% ------------------------------------------------------------------------------
% quads (Cu-linac energy is limited to 10 GeV)
KQCUS1 =   0.491233972308;
KQCUS2 =  -0.414060432356;
KQCUS3 =  -0.314369385154;
KQCUS4 =   2.369394892073;
KQCUS5 =  -1.396338070942;
KQCUS9 =  -0.456516817666;
KQCUS10 =   0.496780961708;
KQCUS6 =   KQCUS5;
KQCUS7 =   KQCUS4;
KQCUS8 =   KQCUS3;
QCUS1={'qu' 'QCUS1' LQR/2 [KQCUS1 0]}';
QCUS2={'qu' 'QCUS2' LQR/2 [KQCUS2 0]}';
QCUS3={'qu' 'QCUS3' LQR/2 [KQCUS3 0]}';
QCUS4={'qu' 'QCUS4' LQE/2 [KQCUS4 0]}';
QCUS5={'qu' 'QCUS5' LQE/2 [KQCUS5 0]}';
QCUS6={'qu' 'QCUS6' LQE/2 [KQCUS6 0]}';
QCUS7={'qu' 'QCUS7' LQE/2 [KQCUS7 0]}';
QCUS8={'qu' 'QCUS8' LQR/2 [KQCUS8 0]}';
QCUS9={'qu' 'QCUS9' LQR/2 [KQCUS9 0]}';
QCUS10={'qu' 'QCUS10' LQR/2 [KQCUS10 0]}';
% ------------------------------------------------------------------------------
% kicker is aligned along the BSY1 axis and rolled approx. -45 deg
% kicker design is based on existing BYKIK1 (max. field ~600G per T. Beukers)
TCUSXR =  -0.673868825333 ;%roll angle of kicker (+pi/2) and septum (rad)
GBKRCUS =  25.4E-3 ;%kicker gap (m)
ZBKRCUS =  1.0601  ;%kicker straight length (m)
ABKRCUS0 =  -0.87326308078E-3;
PULSED =  abs(SETCUS)*(1+SETCUS)/2;
ABKRCUS =  ABKRCUS0*PULSED          ;%total kicker angle (rad)
ABKRCUSA =  asin(sin(ABKRCUS)/2)     ;%1st half-kicker angle (rad)
ABKRCUSB =  ABKRCUS-ABKRCUSA         ;%2nd half-kicker angle (rad)
ABKRCUS_2 =  ABKRCUS   *ABKRCUS;
ABKRCUS_4 =  ABKRCUS_2 *ABKRCUS_2;
ABKRCUSA_2 =  ABKRCUSA  *ABKRCUSA;
ABKRCUSA_4 =  ABKRCUSA_2*ABKRCUSA_2;
LBKRCUS =  ZBKRCUS   /(1 -ABKRCUS_2 /6 +ABKRCUS_4 /120);
LBKRCUSA =  ZBKRCUS/2 /(1 -ABKRCUSA_2/6 +ABKRCUSA_4/120);
LBKRCUSB =  LBKRCUS-LBKRCUSA;
BKRCUSA={'be' 'BKRCUS' LBKRCUSA [ABKRCUSA GBKRCUS/2 0 0 0.5 0 PI/2+TCUSXR]}';
BKRCUSB={'be' 'BKRCUS' LBKRCUSB [ABKRCUSB GBKRCUS/2 0 ABKRCUS 0 0.5 PI/2+TCUSXR]}';
% ------------------------------------------------------------------------------
% DC alternative to kicker comprised of two 3D8.8MK3 correctors, one at each end of BKRCUS
% - both correctors are aligned along the linac z-axis
GBRCUSDC =  2.031*IN2M ;%full gap (m)
ZBRCUSDC =  0.2691     ;%on-axis effective length (m) (measured)
FBRCUSDC =  0.3041     ;%FINT (measured)
TBRCUSDC =  TCUSXR     ;%roll angle (+pi/2)
DCMODE =  abs(SETCUS)*(1-SETCUS)/2;
ABRCUSDC =  ABKRCUS0*DCMODE          ;%total bend angle (rad)
ABRCUSDC1 =  asin(sin(ABRCUSDC)/2)    ;%1st corrector bend angle (rad)
ABRCUSDC2 =  ABRCUSDC-ABRCUSDC1       ;%2nd corrector bend angle (rad)
% Note: 1-theta^2/6 ~ sinc(theta)
LBRCUSDC =  2*ZBRCUSDC/(1-ABRCUSDC*ABRCUSDC/6);
LBRCUSDC1 =  ZBRCUSDC/(1-ABRCUSDC1*ABRCUSDC1/6);
LBRCUSDC2 =  LBRCUSDC-LBRCUSDC1;
LBRCUSDC1A =  0.134538920784 ;%ZBRCUSdc/2
LBRCUSDC1B =  LBRCUSDC1-LBRCUSDC1A;
ABRCUSDC1A =  ABRCUSDC1*(LBRCUSDC1A/LBRCUSDC1);
ABRCUSDC1B =  ABRCUSDC1-ABRCUSDC1A;
BRCUSDC1A={'be' 'BRCUSDC1' LBRCUSDC1A [ABRCUSDC1A GBRCUSDC/2 0 0 FBRCUSDC 0 PI/2+TBRCUSDC]}';
BRCUSDC1B={'be' 'BRCUSDC1' LBRCUSDC1B [ABRCUSDC1B GBRCUSDC/2 0 ABRCUSDC1 0 FBRCUSDC PI/2+TBRCUSDC]}';
LBRCUSDC2A =  0.1345578935 ;%ZBRCUSdc/2
LBRCUSDC2B =  LBRCUSDC2-LBRCUSDC2A;
ABRCUSDC2A =  ABRCUSDC2*(LBRCUSDC2A/LBRCUSDC2);
ABRCUSDC2B =  ABRCUSDC2-ABRCUSDC2A;
BRCUSDC2A={'be' 'BRCUSDC2' LBRCUSDC2A [ABRCUSDC2A GBRCUSDC/2 -ABRCUSDC1 0 FBRCUSDC 0 PI/2+TBRCUSDC]}';
BRCUSDC2B={'be' 'BRCUSDC2' LBRCUSDC2B [ABRCUSDC2B GBRCUSDC/2 0 ABRCUSDC 0 FBRCUSDC PI/2+TBRCUSDC]}';
LDCK =  40.03*IN2M                ;%center-to-center Z-distance between corrector and kicker
ZCKDC =  LDCK-(ZBRCUSDC+ZBKRCUS)/2 ;%Z-distance between corrector and kicker
ZCUSBLR =  16.1469-ZCKDC-ZBRCUSDC    ;%Z-distance between kicker and septum
ZCUSBLRA =  5.1956-(ZCKDC+ZBRCUSDC)   ;%Z-distance between corrector and BPM
ZCUSBLRB =  ZCUSBLR-ZCUSBLRA          ;%Z-distance between BPM and septum
LDCKDC1 =  ZCKDC/cos(ABRCUSDC1);
LDCKDC2 =  ZCKDC/cos(ABRCUSDC1+ABKRCUS)   ;%one of these angles will be zero
LDCUSBLR =  ZCUSBLR/cos(ABRCUSDC+ABKRCUS)  ;%one of these angles will be zero
LDCUSBLRA =  ZCUSBLRA/cos(ABRCUSDC+ABKRCUS) ;%one of these angles will be zero
LDCUSBLRB =  ZCUSBLRB/cos(ABRCUSDC+ABKRCUS) ;%one of these angles will be zero
DCKDC1={'dr' '' LDCKDC1 []}';
DCKDC2={'dr' '' LDCKDC2 []}';
DCUSBLRA={'dr' '' LDCUSBLRA []}';
DCUSBLRB={'dr' '' LDCUSBLRB []}';
% ------------------------------------------------------------------------------
% 2-hole rolled septum aligned along the BSY1 axis
GBLRCUS =  GBLSP ;%septum gap height (m)
ZBLRCUS =  LBLSP ;%septum straight length (m)
ABLRCUS0 =  0.911077773379E-2;
ABLRCUS =  ABLRCUS0*abs(SETCUS) ;%septum bending angle (rad)
ABLRCUSA =  asin(sin(ABLRCUS)/2) ;%angle per 1st half of the septum
ABLRCUSB =  ABLRCUS-ABLRCUSA     ;%angle per 2nd half of the septum
ABLRCUS_2 =  ABLRCUS   *ABLRCUS;
ABLRCUS_4 =  ABLRCUS_2 *ABLRCUS_2;
ABLRCUSA_2 =  ABLRCUSA  *ABLRCUSA;
ABLRCUSA_4 =  ABLRCUSA_2*ABLRCUSA_2;
LBLRCUS =  ZBLRCUS   /(1 -ABLRCUS_2/6  +ABLRCUS_4 /120)/cos(ABKRCUS);
LBLRCUSA =  ZBLRCUS/2 /(1 -ABLRCUSA_2/6 +ABLRCUSA_4/120)/cos(ABKRCUS);
LBLRCUSB =  LBLRCUS-LBLRCUSA;
BLRCUSA={'be' 'BLRCUS' LBLRCUSA [ABLRCUSA GBLRCUS/2 0 0 0.5 0 TCUSXR]}';
BLRCUSB={'be' 'BLRCUS' LBLRCUSB [ABLRCUSB GBLRCUS/2 0 ABLRCUS 0 0.5 TCUSXR]}';
% rolled DC bend
% Note: BRCUS1 is a merge DC-bend which is either turned ON to operate
%       CURF beam in SXR, or turned OFF to operate SCRF beam in SXR
TBRCUS =  -0.769423721099 ;%roll angle of DC bend (rad)
GBRCUS =  GBSP ;%bend gap height (m)
ZBRCUS =  LBSP ;%bend straight length (1.0D38.37) (m)
FBRCUS =  0.4861 ;%measured FINT
DABRCUS =  -0.417540592574E-4;
ABRCUS =  (-ABLRCUS0+DABRCUS)*abs(SETCUS);
ABRCUSH =  ABRCUS/2;
ABRCUSH_2 =  ABRCUSH   *ABRCUSH;
ABRCUSH_4 =  ABRCUSH_2 *ABRCUSH_2;
LBRCUS =  ZBRCUS/(1-ABRCUSH_2/6 +ABRCUSH_4/120) ;%bend path length (m)
BRCUS1A={'be' 'BRCUS1' LBRCUS/2 [ABRCUS/2 GBRCUS/2 ABRCUS/2 0 FBRCUS 0 TBRCUS]}';
BRCUS1B={'be' 'BRCUS1' LBRCUS/2 [ABRCUS/2 GBRCUS/2 0 ABRCUS/2 0 FBRCUS TBRCUS]}';
% inner vertical bends for R56 cancellation
% NOTE: 1.0D22.265 dipoles replaced with 3D8.8MK3 correctors
GBYCUS =  GBRCUSDC       ;%full gap (m)
ZBYCUS =  ZBRCUSDC       ;%on-axis effective length (m)
FBYCUS =  0.5 ;%FBRCUSdc  FINT
DLD2C =  (0.6-ZBYCUS)/2 ;%1.0D22.265 -> 3D8.8MK3 
ABYCUS =  0.4E-3;
LBYCUS =  ZBYCUS*ABYCUS/(2*sin(ABYCUS/2)) ;%bend path length (m)
BYCUS1A={'be' 'BYCUS1' LBYCUS/2 [ABYCUS/2 GBYCUS/2 ABYCUS/2 0 FBYCUS 0 PI/2]}';
BYCUS1B={'be' 'BYCUS1' LBYCUS/2 [ABYCUS/2 GBYCUS/2 0 ABYCUS/2 0 FBYCUS PI/2]}';
BYCUS2A={'be' 'BYCUS2' LBYCUS/2 [-ABYCUS/2 GBYCUS/2 -ABYCUS/2 0 FBYCUS 0 PI/2]}';
BYCUS2B={'be' 'BYCUS2' LBYCUS/2 [-ABYCUS/2 GBYCUS/2 0 -ABYCUS/2 0 FBYCUS PI/2]}';
% rolled DC corrector bends -- removed
LBRCCUS =  0.6;
DBRCCUS1={'dr' '' LBRCCUS/2 []}';
DBRCCUS2={'dr' '' LBRCCUS/2 []}';
% drifts
DLDCUS0 =   0.0  ;%adjust length of CUSXR
DLDCUS2 =   0.0  ;%adjust positions of QCUS2,9
DLDCUS3 =  -0.9  ;%adjust positions of QCUS3,8
DLDCUS4 =   0.16 ;%adjust positions of QCUS4,7
DLDCUS13 =   0.0  ;%asymmetry between LDCUS1 and LDCUS13
LDCUS0 =  5.133675753223652 +DLDCUS0;
LDCUS1 =  29.4;
LDCUS2 =  LDCUS0         +DLDCUS2;
LDCUS3 =  LDCUS0 -DLDCUS2+DLDCUS3;
LDCUS4 =  LDCUS0 -DLDCUS3+DLDCUS4 +0.599963125932;
LDCUS5 =  1.5-0.25 -DLDCUS4 +DLD2C;
LDCUS6 =  1.0+0.25 +DLD2C;
LDCUS7 =  0.3/2;
LDCUS8 =  LDCUS6;
LDCUS9 =  LDCUS5;
LDCUS10 =  LDCUS4;
LDCUS11 =  LDCUS3;
LDCUS12 =  LDCUS2;
LDCUS13 =  LDCUS1+LBLRCUS/2-LBRCUS/2 +DLDCUS13;
LDCUS1B =  7.0;
LDCUS1C =  0.5;
LDCUS1A =  LDCUS1-LDCUS1B-LDCUS1C-LBRCCUS-LBRCCUS -DLDCUS13;
LDCUS2A =  0.464083 ;%0.4471
LDCUS2B =  0.747032 ;%0.619817
LDCUS2C =  LDCUS2-LDCUS2A-LDCUS2B;
LDCUS3A =  0.463634 ;%0.4471
LDCUS3B =  0.747031 ;%0.843035
LDCUS3D =  0.389900 ;%0.593909
LDCUS3C =  LDCUS3-LDCUS3A-LDCUS3B-LDCUS3D;
LDCUS4A =  0.4285;
LDCUS4C =  0.1924;
LDCUS4B =  LDCUS4-LDCUS4A-LDCUS4C +(LQR-LQE)/2;
LDCUS5A =  0.4;
LDCUS5B =  LDCUS5-LDCUS5A +(LQR-LQE)/2;
LDCUS6B =  0.1924;
LDCUS6A =  LDCUS6-LDCUS6B +(LQR-LQE)/2 -LQE/2-LDCUS7;
LDCUS8A =  0.4;
LDCUS8B =  LDCUS8-LDCUS8A +(LQR-LQE)/2 -LQE/2-LDCUS7;
LDCUS9B =  0.1924;
LDCUS9A =  LDCUS9-LDCUS9B +(LQR-LQE)/2;
LDCUS10A =  0.4;
LDCUS10C =  0.390327 ;%0.4781
LDCUS10B =  LDCUS10-LDCUS10A-LDCUS10C +(LQR-LQE)/2;
LDCUS11A =  0.4285;
LDCUS11C =  0.390815 ;%0.4781
LDCUS11B =  LDCUS11-LDCUS11A-LDCUS11C;
LDCUS12A =  0.4285;
LDCUS12C =  0.821035 ;%0.6058
LDCUS12D =  0.390264 ;%0.4781
LDCUS12B =  LDCUS12-LDCUS12A-LDCUS12C-LDCUS12D;
DCUS1A={'dr' '' LDCUS1A []}';
DCUS1B={'dr' '' LDCUS1B []}';
DCUS1C={'dr' '' LDCUS1C []}';
DCUS2A={'dr' '' LDCUS2A []}';
DCUS2B={'dr' '' LDCUS2B []}';
DCUS2C={'dr' '' LDCUS2C []}';
DCUS3A={'dr' '' LDCUS3A []}';
DCUS3B={'dr' '' LDCUS3B []}';
DCUS3C={'dr' '' LDCUS3C []}';
DCUS3D={'dr' '' LDCUS3D []}';
DCUS4A={'dr' '' LDCUS4A []}';
DCUS4B={'dr' '' LDCUS4B []}';
DCUS4C={'dr' '' LDCUS4C []}';
DCUS5A={'dr' '' LDCUS5A []}';
DCUS5B={'dr' '' LDCUS5B []}';
DCUS6A={'dr' '' LDCUS6A []}';
DCUS6B={'dr' '' LDCUS6B []}';
DCUS7={'dr' '' LDCUS7 []}';
DCUS8A={'dr' '' LDCUS8A []}';
DCUS8B={'dr' '' LDCUS8B []}';
DCUS9A={'dr' '' LDCUS9A []}';
DCUS9B={'dr' '' LDCUS9B []}';
DCUS10A={'dr' '' LDCUS10A []}';
DCUS10B={'dr' '' LDCUS10B []}';
DCUS10C={'dr' '' LDCUS10C []}';
DCUS11A={'dr' '' LDCUS11A []}';
DCUS11B={'dr' '' LDCUS11B []}';
DCUS11C={'dr' '' LDCUS11C []}';
DCUS12A={'dr' '' LDCUS12A []}';
DCUS12B={'dr' '' LDCUS12B []}';
DCUS12C={'dr' '' LDCUS12C []}';
DCUS12D={'dr' '' LDCUS12D []}';
DCUS13={'dr' '' LDCUS13 []}';
% markers
BEGCUSXR={'mo' 'BEGCUSXR' 0 []}';
MIDCUSXR={'mo' 'MIDCUSXR' 0 []}';%center of CUSXR
CNTCUS1={'mo' 'CNTCUS1' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
CNTCUS2={'mo' 'CNTCUS2' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
CNTCUS3={'mo' 'CNTCUS3' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
CNTCUS4={'mo' 'CNTCUS4' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
CNTCUS5={'mo' 'CNTCUS5' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
ENDCUSXR={'mo' 'ENDCUSXR' 0 []}';
% monitors
BPMCUS={'mo' 'BPMCUS' 0 []}';
BPMCUS1={'mo' 'BPMCUS1' 0 []}';
BPMCUS2={'mo' 'BPMCUS2' 0 []}';
BPMCUS3={'mo' 'BPMCUS3' 0 []}';
BPMCUS4={'mo' 'BPMCUS4' 0 []}';
BPMCUS5={'mo' 'BPMCUS5' 0 []}';
BPMCUS7={'mo' 'BPMCUS7' 0 []}';
BPMCUS8={'mo' 'BPMCUS8' 0 []}';
BPMCUS9={'mo' 'BPMCUS9' 0 []}';
BPMCUS10={'mo' 'BPMCUS10' 0 []}';
% steering correctors
XCCUS1={'mo' 'XCCUS1' 0 []}';%type TBD
XCCUS4={'mo' 'XCCUS4' 0 []}';%type TBD
XCCUS7={'mo' 'XCCUS7' 0 []}';%type TBD
XCCUS10={'mo' 'XCCUS10' 0 []}';%type TBD
YCCUS2={'mo' 'YCCUS2' 0 []}';%type TBD
YCCUS3={'mo' 'YCCUS3' 0 []}';%type TBD
YCCUS6={'mo' 'YCCUS6' 0 []}';%type TBD
YCCUS8={'mo' 'YCCUS8' 0 []}';%type TBD
YCCUS9={'mo' 'YCCUS9' 0 []}';%type TBD
% insertable stopper / tuneup dump
STCLTS={'mo' 'STCLTS' 30*IN2M []}';%from PEP-II injection line
DCUS11B1={'dr' '' 1.883313 []}';%2.0609115
DCUS11B2={'dr' '' DCUS11B{3}-DCUS11B1{3}-STCLTS{3} []}';
% SROT to remove rotation angle
AROCUS1 =  -0.249098811997E-4;
AROCUS2 =   0.209318005136E-4;
AROCUS3 =   0.117879544139E-19;
AROCUS4 =  -AROCUS3;
ROCUS1={'ro' 'ROCUS1' 0 [-(AROCUS1)]}';
ROCUS2={'ro' 'ROCUS2' 0 [-(AROCUS2)]}';
ROCUS3={'ro' 'ROCUS3' 0 [-(AROCUS3)]}';
ROCUS4={'ro' 'ROCUS4' 0 [-(AROCUS4)]}';
% beamlines
KCUSXRA=[BRCUSDC1A,BRCUSDC1B,DCKDC1,BKRCUSA,BKRCUSB,DCKDC2,BRCUSDC2A,BRCUSDC2B,DCUSBLRA,BPMCUS,DCUSBLRB,BLRCUSA,BLRCUSB];
KCUSXRB=[CNTCUS1 ,ROCUS1  ,DCUS1A,DBRCCUS1,DBRCCUS1,DCUS1B,DBRCCUS2,DBRCCUS2,CNTCUS5];
KCUSXR=[KCUSXRA,KCUSXRB];
DLCUSXR=[              DCUS1C ,QCUS1  ,QCUS1  ,DCUS2A ,BPMCUS1,DCUS2B ,XCCUS1 ,DCUS2C,QCUS2  ,QCUS2  ,DCUS3A ,BPMCUS2,DCUS3B ,YCCUS2 ,DCUS3C,BPMCUS3,DCUS3D ,QCUS3  ,QCUS3  ,DCUS4A ,YCCUS3 ,DCUS4B ,DCUS4C ,QCUS4  ,BPMCUS4,QCUS4  ,DCUS5A ,XCCUS4 ,DCUS5B ,BYCUS1A,BYCUS1B,CNTCUS3,ROCUS3 ,DCUS6A ,DCUS6B ,QCUS5  ,BPMCUS5,QCUS5  ,DCUS7  ,MIDCUSXR,DCUS7 ,QCUS6  ,QCUS6  ,DCUS8A ,YCCUS6 ,DCUS8B ,ROCUS4 ,BYCUS2A,BYCUS2B,CNTCUS4,        DCUS9A ,DCUS9B ,QCUS7  ,BPMCUS7,QCUS7  ,DCUS10A,XCCUS7 ,DCUS10B,BPMCUS8,DCUS10C,QCUS8  ,QCUS8  ,DCUS11A,YCCUS8 ,DCUS11B1,STCLTS,DCUS11B2,BPMCUS9,DCUS11C,QCUS9  ,QCUS9  ,DCUS12A,YCCUS9 ,DCUS12B,XCCUS10,DCUS12C,BPMCUS10,DCUS12D,QCUS10 ,QCUS10 ,DCUS13 ,ROCUS2 ,BRCUS1A,BRCUS1B,CNTCUS2];
CUSXR=[BEGCUSXR,KCUSXR,DLCUSXR,ENDCUSXR];

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc A-line
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 26-MAR-2019, M. Woodley
%  * split BSYA area into two subareas, BSYA_1 and BSYA_2
% ------------------------------------------------------------------------------
% 31-OCT-2018, Y. Nosochkov
%  * minor adjustment of DA04c drift length for DASEL with 25G kicker field
% 09-OCT-2018, M. Woodley
%  * add YCBSYA per D. McCormick
% ------------------------------------------------------------------------------
% 25-MAY-2018, M. Woodley
%  * change name of E158 bends in ESA to avoid redefinitions
% ------------------------------------------------------------------------------
% 07-FEB-2018, M. Woodley
%  * add TYPE designations for A-line magnets
% 05-FEB-2018, Y. Nosochkov
%  * minor optics rematch
% 25-JAN-2018, M. Woodley
%  * remove PCBSY2/BTMBSY2 per A. Ibrahimov
% ------------------------------------------------------------------------------
% 07-JUL-2017, Y. Nosochkov
%  * minor optics rematch for LCLS-II-HE
% ------------------------------------------------------------------------------
% 05-MAY-2017, M. Woodley
%  * remove deferral designations
%  * remove unused element definitions
%  * pulsed correctors XCAPM2/YCAPM2 will be timed to affect the straight-ahead
%    LTUH beam, but not the A-line beam
%  * extend line to 3PR2
% ------------------------------------------------------------------------------
% 02-MAR-2017, M. Woodley
%  * rename "SQ27.5" to SQ27p5 per G. White
%  * expand BSYA area to include entire A-line (up to End Station wall)
%  * add definitions for ABRDAS2 and TBRDAS2 (copied from DASEL.xsif)
% 24-FEB-2017, Y. Nosochkov
%  * merge with A-line deck containing diagnostic + E158 (from M. Woodley)
%  * rename rolled BKXAPM1-4 to BKRAPM1-4 (per naming convention)
%  * rename rolled BXAM1 to BRAM1 (per naming convention)
%  * remove ROLL4 S-rotation and replace it with BRAM1 tilt angle
%  * update ROLL2 value
%  * rename some parameters and drifts
%  * update definition of 2-hole DUMPBSYA copper collimator using two separate
%    collimators: for A-line (PCBSYA) and straight ahead BSY (PCBSYH)
%  * move PCBSYA/PCBSYH (formerly DUMPBSYA) 1.35 m upstream (D. McCormick)
%  * add deferred profile monitor PRBRAM1 and Cu target TGTBRAM1 upstream of
%    BRAM1 (D. McCormick)
%  * make the PRAPM profile monitor a YAG monitor (D. McCormick) and change
%    name to YAGAPM 
%  * add deferred corrector package XCAPM2/YCAPM2 to the pulsed magnets
%    (D. McCormick)
%  * change deferment level of new A-line components from @3 to @1
% ------------------------------------------------------------------------------
% 02-NOV-2016, Y. Nosochkov
%  * replace fast kicker/septum magnets with 120 Hz pulsed magnets (deferred)
%    for ESTB (D. McCormick, J. Amann)
%  * the pulsed magnets and other ESTB devices are not funded by LCLS-II (Paul)
%  * update eng. type of BXAM1 from 1.0D38.37 to 2.0D38.37 (J. Amann)
%  * move to baseline: PCBSY2, BTMBSY2
% ------------------------------------------------------------------------------
% 24-JUN-2016, Y. Nosochkov
%  * add deferred BPMCUA between A-line kicker and septum
%  * update the engineering type of BKYAL1,...,BKYAL5 kickers to
%    "0.787K35.4" (J. Amann)
% ------------------------------------------------------------------------------
% 26-FEB-2016, M. Woodley
%  * remove SEQnn MARKers
% 26-FEB-2016, Y. Nosochkov
%  * add BCS PCBSY2/BTMBSY2 at Z=3124 m (deferred @0) (S. Mao)
%  * increase distance between kickers from 15 cm to 30 cm
% ------------------------------------------------------------------------------
% 25-SEP-2015, Y. Nosochkov
%  * update definitions of kickers and septum to allow zero angle
% 24-AUG-2015, Y. Nosochkov
%  * update the TYPE of septum from 0.39SD38.98 to 0.625SD38.98 (J. Amann)
%  * adjust quad strengths for match to the updated BSY optics
%  * match geometry to the updated positions of A-line kicker & septum
% ------------------------------------------------------------------------------
% 20-MAR-2015, M. Woodley
%  * add SEQ21BEG, SEQ21END, BEGBSYA, ENDBSYA MARKERs
% 12-MAR-2015, Y. Nosochkov
%  * add fast kickers and septum (as in spreader) to deflect beam into A-line
%  * A-line optics based on original design per M. Woodley's deck
% ------------------------------------------------------------------------------
% NOTE: ABRDAS2 and TBRDAS2 are defined in common.xsif
% ==============================================================================
% dipoles
% ------------------------------------------------------------------------------
% yawed pulsed magnets
GBKRAPM =  35.687E-3      ;%1.405K40.83 pulsed magnet gap (m)
SBKRAPM =  1.055          ;%PM eff. straight length (m)
TBKRAPM =  0.014303833885 ;%PM tilt angle (rad)
ABKRAPM0 =  -0.276615046502E-2;
ABKRAPM =  ABKRAPM0 *SETAL     ;%angle per one PM (rad)
ABKRAPMH =  ABKRAPM/2           ;%PM half-angle
ABKRAPMH2 =  ABKRAPMH *ABKRAPMH;
ABKRAPMH4 =  ABKRAPMH2*ABKRAPMH2;
LBKRAPM =  SBKRAPM/(1 -ABKRAPMH2/6 +ABKRAPMH4/120) ;%PM path length
BKRAPM1A={'be' 'BKRAPM1' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 ABKRAPM/2 0 0.5 0 TBKRAPM]}';
BKRAPM1B={'be' 'BKRAPM1' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 0 ABKRAPM/2 0 0.5 TBKRAPM]}';
BKRAPM2A={'be' 'BKRAPM2' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 ABKRAPM/2 0 0.5 0 TBKRAPM]}';
BKRAPM2B={'be' 'BKRAPM2' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 0 ABKRAPM/2 0 0.5 TBKRAPM]}';
BKRAPM3A={'be' 'BKRAPM3' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 ABKRAPM/2 0 0.5 0 TBKRAPM]}';
BKRAPM3B={'be' 'BKRAPM3' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 0 ABKRAPM/2 0 0.5 TBKRAPM]}';
BKRAPM4A={'be' 'BKRAPM4' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 ABKRAPM/2 0 0.5 0 TBKRAPM]}';
BKRAPM4B={'be' 'BKRAPM4' LBKRAPM/2 [ABKRAPM/2 GBKRAPM/2 0 ABKRAPM/2 0 0.5 TBKRAPM]}';
% PM projections onto BSY HXR beam
ZBKRAPM1 =  SBKRAPM*cos(ABKRAPM0*1/2);
ZBKRAPM2 =  SBKRAPM*cos(ABKRAPM0*3/2);
ZBKRAPM3 =  SBKRAPM*cos(ABKRAPM0*5/2);
ZBKRAPM4 =  SBKRAPM*cos(ABKRAPM0*7/2);
DBKRAPM1A={'dr' '' ZBKRAPM1/2 []}';
DBKRAPM1B={'dr' '' ZBKRAPM1/2 []}';
DBKRAPM2A={'dr' '' ZBKRAPM2/2 []}';
DBKRAPM2B={'dr' '' ZBKRAPM2/2 []}';
DBKRAPM3A={'dr' '' ZBKRAPM3/2 []}';
DBKRAPM3B={'dr' '' ZBKRAPM3/2 []}';
DBKRAPM4A={'dr' '' ZBKRAPM4/2 []}';
DBKRAPM4B={'dr' '' ZBKRAPM4/2 []}';
% A-line merge bend 
GBRAM1 =  50.8E-3                         ;%2.0D38.37 gap height (m)
SBRAM1 =  1.025                           ;%2.0D38.37 straight length (m)
ABRAM1 =  0.23261117109E-2                ;%bend angle (rad)
LBRAM1 =  SBRAM1*ABRAM1/(2*sin(ABRAM1/2)) ;%path length (m)
TBRAM1 =  0.014303788803                  ;%bend roll (rad)
BRAM1A={'be' 'BRAM1' LBRAM1/2 [ABRAM1/2 GBRAM1/2 ABRAM1/2 0 0.5 0 TBRAM1]}';
BRAM1B={'be' 'BRAM1' LBRAM1/2 [ABRAM1/2 GBRAM1/2 0 ABRAM1/2 0 0.5 TBRAM1]}';
% A-bends
AARC =  -24*RADDEG             ;%total arc bend angle (24 degrees)
NBEND =  12                     ;%number of arc bends
%ABA   := AARC/Nbend             nominal arc bend angle
ABA =  -1.999526617334*RADDEG ;%arc bend angle per Transport deck
LBA =  3.024;
GBA =  0.06  ;%Blue Book value
B11A={'be' 'B11' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B11B={'be' 'B11' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B12A={'be' 'B12' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B12B={'be' 'B12' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B13A={'be' 'B13' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B13B={'be' 'B13' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B14A={'be' 'B14' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B14B={'be' 'B14' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B15A={'be' 'B15' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B15B={'be' 'B15' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B16A={'be' 'B16' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B16B={'be' 'B16' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B21A={'be' 'B21' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B21B={'be' 'B21' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B22A={'be' 'B22' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B22B={'be' 'B22' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B23A={'be' 'B23' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B23B={'be' 'B23' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B24A={'be' 'B24' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B24B={'be' 'B24' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B25A={'be' 'B25' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B25B={'be' 'B25' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
B26A={'be' 'B26' LBA/2 [ABA/2 GBA/2 ABA/2 0 0.5 0 0]}';
B26B={'be' 'B26' LBA/2 [ABA/2 GBA/2 0 ABA/2 0 0.5 0]}';
% ESA bends (E158)
LD1S =  1.83;
LD2S =  3.45;
LD3S =  3.45;
AD1S =   0.022344631354;
AD2S =  -0.044690490267;
AD3S =   0.022345239962;
BXD1S={'be' 'BXD1S' LD1S/2 [AD1S/2 0 0 0 0 0 0]}';
BXD2S={'be' 'BXD2S' LD2S/2 [AD2S/2 0 0 0 0 0 0]}';
BXD3S={'be' 'BXD3S' LD3S/2 [AD3S/2 0 0 0 0 0 0]}';
% ==============================================================================
% quadrupoles
% ------------------------------------------------------------------------------
LQ8CM =  2.0;
RQ8CM =  0.08/2;
LQ19 =  2.0;
RQ19 =  0.186/2;
LQ20 =  1.31318;
RQ20 =  8.25*0.0254/2;
LSQ =  0.55;
RSQ =  0.08/2;
% * the K-values below are for SC beam; also copy these settings 
%   to SETK2scA in "LCLS2sc_main.mad8"
% * settings for Cu beam are in SETK2cuA in "LCLS2cu_main.mad8"
% * settings for DASEL are in SETK2scDA in "LCLS2sc_main.mad8"
KQ10 =   0.040732418682 ;% 0.040693762343
KQ11 =  -0.035470391686 ;%-0.034911857604
KQ19 =   0.028832646424 ;% 0.028757782261
KQ20 =   0.011866327361 ;% 0.012103871688
KQ27 =  -0.068187477866 ;%-0.066254695301
KQ28 =   0.029868541394 ;% 0.030361940715
KQ30 =  -0.029618830812 ;%-0.029784752775
KQ38 =   0.034798028844 ;% 0.034797296483
Q10={'qu' 'Q10' LQ8CM/2 [KQ10 0]}';
Q11={'qu' 'Q11' LQ8CM/2 [KQ11 0]}';
Q19={'qu' 'Q19' LQ19/2 [KQ19 0]}';
Q20={'qu' 'Q20' LQ20/2 [KQ20 0]}';
Q27={'qu' 'Q27' LQ8CM/2 [KQ27 0]}';
Q28={'qu' 'Q28' LQ8CM/2 [KQ28 0]}';
Q30={'qu' 'Q30' LQ8CM/2 [KQ30 0]}';
Q38={'qu' 'Q38' LQ8CM/2 [KQ38 0]}';
KSQ =  0.0;
SQ27P5={'qu' 'SQ27P5' LSQ/2 [KSQ pi/4]}';
% ESA quads (E158)
LQSA =  1.327;
RQSA =  193.0E-3;
% E158 run value (P. Bosted)
KQ1SA =   0.016723215505;
KQ2SA =  -0.031838409505;
KQ3SA =   0.031838409505;
KQ4SA =  -0.016080013116;
Q1S={'qu' 'Q1S' LQSA/2 [KQ1SA 0]}';
Q2S={'qu' 'Q2S' LQSA/2 [KQ2SA 0]}';
Q3S={'qu' 'Q3S' LQSA/2 [KQ3SA 0]}';
Q4S={'qu' 'Q4S' LQSA/2 [KQ4SA 0]}';
% ==============================================================================
% drifts
% ------------------------------------------------------------------------------
D105={'dr' '' 5.5372 []}';
D106={'dr' '' 0.727 []}';
D107={'dr' '' 0.7755 []}';
D108={'dr' '' 3.84839 []}';
D109={'dr' '' 0.7755 []}';
D110={'dr' '' 3.84839 []}';
D111={'dr' '' 0.7755 []}';
D112={'dr' '' 15.74899 []}';
D113={'dr' '' 9.0997 []}';
D114={'dr' '' 5.94572 []}';
D115={'dr' '' 0.7755 []}';
D116={'dr' '' 3.84839 []}';
D117={'dr' '' 0.7755 []}';
D118={'dr' '' 3.84839 []}';
D119={'dr' '' 0.7755 []}';
D120={'dr' '' 1.744768 []}';%1.74477
D121={'dr' '' 1.525 []}';
D122={'dr' '' 1.925 []}';
D123={'dr' '' 38.1116 []}';
D124={'dr' '' 21.4778 []}';
D125={'dr' '' 5.04065 []}';
DPR2={'dr' '' 12.25174 []}';%wall to 3PR2 in ESA alcove
D201={'dr' '' 20.44174-DPR2{3} []}';
D202={'dr' '' 2.5 []}';
D203={'dr' '' 1.69 []}';
D204={'dr' '' 1.4865 []}';
D205={'dr' '' 1.413 []}';
D206={'dr' '' 2.603 []}';
D207={'dr' '' 1.013 []}';
D208={'dr' '' 31.04932 []}';
D209={'dr' '' 92.118 []}';
% drifts for diagnostic and correction devices
D002A={'dr' '' 0.090479 []}';
D002B={'dr' '' 1.654993 []}';
D002C={'dr' '' 0.0184 []}';
D002D={'dr' '' 2.466807 []}';
D002E={'dr' '' 0.34925 []}';
D002F={'dr' '' 4.3434 []}';
D002G={'dr' '' 6.213125 []}';
D002H={'dr' '' 0.3429 []}';
D002I={'dr' '' 0.447449 []}';
D003A={'dr' '' 0.128016 []}';
D003B={'dr' '' 1.609344 []}';
D003C={'dr' '' 0.331248 []}';
D003D={'dr' '' 0.628073 []}';
D003E={'dr' '' 0.2286 []}';
D003F={'dr' '' 0.4826 []}';
D003G={'dr' '' 0.3556 []}';
D003H={'dr' '' 0.415546 []}';
D004A={'dr' '' 0.204216 []}';
D004B={'dr' '' 0.581559 []}';
D005A={'dr' '' 0.762 []}';
D005B={'dr' '' 2.329 []}';
D005C={'dr' '' 5.402548 []}';
D101A={'dr' '' 7.405675 []}';
D101B={'dr' '' 3.2853 []}';
D101C={'dr' '' 0.635 []}';
D101D={'dr' '' 0.787 []}';
D101E={'dr' '' 0.534 []}';
D101F={'dr' '' 0.813 []}';
D101G={'dr' '' 0.685 []}';
D101H={'dr' '' 0.61 []}';
D101I={'dr' '' 1.27 []}';
D101J={'dr' '' 1.778 []}';
D101K={'dr' '' 0.457 []}';
D101L={'dr' '' 0.153 []}';
D101M={'dr' '' 0.177 []}';
D101N={'dr' '' 0.483 []}';
D101O={'dr' '' 0.483 []}';
D101P={'dr' '' 0.587 []}';
PMV={'dr' '' 0.4 []}';
D101Q={'dr' '' 0.589942 []}';
D102A={'dr' '' 1.06296 []}';
PM={'dr' '' 7.0 []}';
D102B={'dr' '' 1.06296 []}';
D103A={'dr' '' 66.20934 []}';
D103B={'dr' '' 0.615959 []}';
D103C={'dr' '' 2.850589 []}';
D103D={'dr' '' 0.15875 []}';
D105A={'dr' '' 0.808 []}';
D105B={'dr' '' 0.38 []}';
D105C={'dr' '' 0.478 []}';
D105D={'dr' '' 0.628 []}';
D105E={'dr' '' 0.684 []}';
D105F={'dr' '' 0.62 []}';
D105G={'dr' '' 0.88 []}';
D105H={'dr' '' 0.668 []}';
D105I={'dr' '' 0.3912 []}';
D108A={'dr' '' 0.829 []}';
D108B={'dr' '' 0.785 []}';
D108C={'dr' '' 2.23439 []}';
D110A={'dr' '' 2.98539 []}';
D110B={'dr' '' 0.863 []}';
D112A={'dr' '' 7.4348 []}';
D112B={'dr' '' 3.19319 []}';
D112C={'dr' '' 1.159 []}';
D112D={'dr' '' 1.302 []}';
D112E={'dr' '' 1.264 []}';
D112F={'dr' '' 0.723 []}';
D112G={'dr' '' 0.673 []}';
D113A={'dr' '' 1.32 []}';
D113B={'dr' '' 1.981 []}';
D113C={'dr' '' 5.7987 []}';
D114A={'dr' '' 4.47 []}';
D114B={'dr' '' 0.775 []}';
D114C={'dr' '' 0.70072 []}';
D116A={'dr' '' 2.81239 []}';
D116B={'dr' '' 1.036 []}';
D118A={'dr' '' 0.65139 []}';
D118B={'dr' '' 0.707 []}';
D118C={'dr' '' 1.131 []}';
D118D={'dr' '' 0.501 []}';
D118E={'dr' '' 0.858 []}';
D120B={'dr' '' 0.35 []}';
D120C={'dr' '' 0.513 []}';
D120A={'dr' '' D120{3}-D120B{3}-D120C{3} []}';%0.881768
D123A={'dr' '' 0.655 []}';
D123B={'dr' '' 0.673 []}';
D123C={'dr' '' 0.644 []}';
D123D={'dr' '' 0.657 []}';
D123E={'dr' '' 0.816 []}';
D123F={'dr' '' 0.445 []}';
D123G={'dr' '' 0.844 []}';
D123H={'dr' '' 31.9656 []}';
D123I={'dr' '' 0.729 []}';
D123J={'dr' '' 0.683 []}';
D124A={'dr' '' 0.629 []}';
D124B={'dr' '' 0.381 []}';
D124C={'dr' '' 0.635 []}';
D124D={'dr' '' 0.559 []}';
D124E={'dr' '' 1.041 []}';
D124F={'dr' '' 16.5857 []}';
D124G={'dr' '' 1.6471 []}';
% PM drifts along A-line
ZPCAPM =  0.1824 ;%length of PM collimator aligned along BSY HXR beam
LPCAPM1 =  ZPCAPM/cos(1*ABKRAPM);
LPCAPM2 =  ZPCAPM/cos(2*ABKRAPM);
LPCAPM3 =  ZPCAPM/cos(3*ABKRAPM);
LPCAPM4 =  ZPCAPM/cos(4*ABKRAPM);
LDAPM =  0.5951 ;%space between two PMs along A-line trajectory
LDAPM1 =  (LDAPM-LPCAPM1)/2;
LDAPM2 =  (LDAPM-LPCAPM2)/2;
LDAPM3 =  (LDAPM-LPCAPM3)/2;
LDAPM4 =  (LDAPM-LPCAPM4)/2;
DAPM1={'dr' '' LDAPM1 []}';
DAPM2={'dr' '' LDAPM2 []}';
DAPM2A={'dr' '' LDAPM2/2 []}';
DAPM2B={'dr' '' LDAPM2/2 []}';
DAPM3={'dr' '' LDAPM3 []}';
DAPM4={'dr' '' LDAPM4 []}';
LDA01 =  0.0471765+0.15 ;
LDA02 =  4.371494-LDA01-1.35/cos(4*ABKRAPM0);
LDA03 =  1.3206+1.35/cos(4*ABKRAPM0);
LDA04 =  47.451381526647;
LDBRDAS2 =  LBSP*cos(ABRDAS2*sin(TBRDAS2)/2)*cos(ABRDAS2*cos(TBRDAS2)/2)/ cos(ABRDAS2*cos(TBRDAS2));
LDA04B =  0.5;
LDA04C =  19.829173726034 ;
LDA04A =  LDA04-LDBRDAS2-LDA04B-LDA04C;
LDA05 =  0.5;
LDA06 =  0.5;
DA01={'dr' '' LDA01 []}';
DA02={'dr' '' LDA02 []}';
DA03={'dr' '' LDA03 []}';
DA03B={'dr' '' 0.6 []}';
DA03A={'dr' '' DA03{3}-DA03B{3} []}';
DBRDAS2A={'dr' '' LDBRDAS2/2 []}';
DBRDAS2B={'dr' '' LDBRDAS2/2 []}';
DRCDAS19={'dr' '' 0.0 []}';
DA04A={'dr' '' LDA04A []}';
DA04B={'dr' '' LDA04B []}';
DA04C={'dr' '' LDA04C []}';
DA05={'dr' '' LDA05 []}';
DA06={'dr' '' LDA06 []}';
DAMQ10={'dr' '' 0.9875 []}';
% PM drifts projected onto BSY HXR beamline
LDZAPM1 =  (LDAPM*cos(1*ABKRAPM0)-ZPCAPM)/2;
LDZAPM2 =  (LDAPM*cos(2*ABKRAPM0)-ZPCAPM)/2;
LDZAPM3 =  (LDAPM*cos(3*ABKRAPM0)-ZPCAPM)/2;
LDZAPM4 =  (LDAPM*cos(4*ABKRAPM0)-ZPCAPM)/2;
LDZA01 =   LDA01*cos(4*ABKRAPM0);
LDZA02 =   LDA02*cos(4*ABKRAPM0);
DZAPM1={'dr' '' LDZAPM1 []}';
DZAPM2={'dr' '' LDZAPM2 []}';
DZAPM2A={'dr' '' LDZAPM2/2 []}';
DZAPM2B={'dr' '' LDZAPM2/2 []}';
DZAPM3={'dr' '' LDZAPM3 []}';
DZAPM4={'dr' '' LDZAPM4 []}';
DZA01={'dr' '' LDZA01 []}';
DZA02={'dr' '' LDZA02 []}';
DSCAPM2={'dr' '' 0.0 []}';
% ==============================================================================
% coordinate rolls ... bend plane rotated to remove linac slope
% ------------------------------------------------------------------------------

% original A-line values
%ROLL1 : SROT, ANGLE= 0.014303845885    * ROLLON
%ROLL2 : SROT, ANGLE=-0.393462907527E-2 * ROLLON
%ROLL3 : SROT, ANGLE=-0.011395368282    * ROLLON
% new values
%ROLL4 : SROT, ANGLE= 0.014303788803    * ROLLON
%ROLL2 : SROT, ANGLE=-0.399639784046E-2 * ROLLON
%ROLL3 : SROT, ANGLE= 0.0               * ROLLON no ROLL3 per alignment group
ROLL2={'ro' 'ROLL2' 0 [-((0.014303788803-0.399639784046E-2)*ROLLON)]}';
ROLL3={'ro' 'ROLL3' 0 [-(0.0*ROLLON)]}';%no ROLL3 per alignment group
% ==============================================================================
% XCORs and YCORs
% ------------------------------------------------------------------------------
XCAPM2={'mo' 'XCAPM2' 0 []}';%type to be determined
A28X={'mo' 'A28X' 0 []}';
A32X={'mo' 'A32X' 0 []}';
YCAPM2={'mo' 'YCAPM2' 0 []}';%type to be determined
YCBSYA={'mo' 'YCBSYA' 0 []}';
A10Y={'mo' 'A10Y' 0 []}';
A18Y={'mo' 'A18Y' 0 []}';
A29Y={'mo' 'A29Y' 0 []}';
A33Y={'mo' 'A33Y' 0 []}';
% ==============================================================================
% BPMs
% ------------------------------------------------------------------------------
% rename BPM10 and BPM12 to avoid conflicts
BPM10A={'mo' 'BPM10A' 0 []}';
BPM12A={'mo' 'BPM12A' 0 []}';
BPM17={'mo' 'BPM17' 0 []}';
BPM24={'mo' 'BPM24' 0 []}';
BPM28={'mo' 'BPM28' 0 []}';
BPM31={'mo' 'BPM31' 0 []}';
BPM32={'mo' 'BPM32' 0 []}';
% ==============================================================================
% profile monitors, wire scanners, wire arrays, synchrotron light ports, 
% spectrum foils, burn-through monitors, and Cu-target
% ------------------------------------------------------------------------------
PR10={'mo' 'PR10' 0 []}';
SYNC={'mo' 'SYNC' 0 []}';
PR18={'mo' 'PR18' 0 []}';
SP18={'mo' 'SP18' 0 []}';
PR20={'mo' 'PR20' 0 []}';
PR28={'mo' 'PR28' 0 []}';
PR33={'mo' 'PR33' 0 []}';
% new devices
YAGAPM={'mo' 'YAGAPM' 0 []}';%YAG profile monitor
PRBRAM1={'mo' 'PRBRAM1' 0 []}';%profile monitor, type to be determined
TGTBRAM1={'mo' 'TGTBRAM1' 0 []}';%secondary production Cu target
% ==============================================================================
% toroids and beam charge monitors
% ------------------------------------------------------------------------------
I10={'mo' 'I10' 0 []}';
I11={'mo' 'I11' 0 []}';
I24={'mo' 'I24' 0 []}';
I28={'mo' 'I28' 0 []}';
I29={'mo' 'I29' 0 []}';
% ==============================================================================
% collimators and slits
% ------------------------------------------------------------------------------
PC10={'dr' 'PC10' 0 []}';
PC12={'dr' 'PC12' 0 []}';
PC14={'dr' 'PC14' 0 []}';
PC17={'dr' 'PC17' 0 []}';
SL19={'dr' 'SL19' 0 []}';
SL10={'dr' 'SL10' 0 []}';
PC20={'dr' 'PC20' 0 []}';
PC24={'dr' 'PC24' 0 []}';
C24={'dr' 'C24' 0 []}';
PC26={'dr' 'PC26' 0 []}';
PC29={'dr' 'PC29' 0 []}';
C37={'dr' 'C37' 0 []}';
PCAPM1={'dr' 'PCAPM1' LPCAPM1 []}';
PCAPM2={'dr' 'PCAPM2' LPCAPM2 []}';
PCAPM3={'dr' 'PCAPM3' LPCAPM3 []}';
PCAPM4={'dr' 'PCAPM4' LPCAPM4 []}';
% 1" ID A-line collimator -- part of 2-hole copper collimator d/s of A-line PM
PCBSYA={'dr' 'PCBSYA' 0.45/cos(4*ABKRAPM0) []}';
% ==============================================================================
% vacuum components
% ------------------------------------------------------------------------------
IV10={'mo' 'IV10' 0 []}';
FV10={'mo' 'FV10' 0 []}';
IV26={'mo' 'IV26' 0 []}';
FV28={'mo' 'FV28' 0 []}';
% ==============================================================================
% points of interest
% ------------------------------------------------------------------------------
RWWAKE3A={'mo' 'RWWAKE3A' 0 []}';%CLTH/BSYH beampipe wake applied here
BEGB={'mo' 'BEGB' 0 []}';%start of A-line bending
ST22={'mo' 'ST22' 0 []}';%beam stopper
MARC={'mo' 'MARC' 0 []}';%match point
ENDB={'mo' 'ENDB' 0 []}';%end of A-line bending (final emittance)
ST29={'mo' 'ST29' 0 []}';%beam stopper
ALWALL={'mo' 'ALWALL' 0 []}';%upstream face of wall that separates A-line tunnel from alcove
ESAE={'mo' 'ESAE' 0 []}';%east wall of ESA
BMDE={'mo' 'BMDE' 0 []}';%Beam Dump East
% ==============================================================================
% beamlines
% ------------------------------------------------------------------------------
SCAPM2=[XCAPM2,YCAPM2];
LD105=[D105A,PC10,D105B,IV10,D105C,FV10,D105D,BPM10A,D105E,I10,D105F,PR10,D105G,A10Y,D105H,I11,D105I];
LD108=[D108A,PC12,D108B,BPM12A,D108C];
LD110=[D110A,PC14,D110B];
LD112=[D112A,SYNC,D112B,PC17,D112C,BPM17,D112D,A18Y,D112E,PR18,D112F,SP18,D112G];
LD113=[D113A,SL19,D113B,SL10,D113C];
LD114=[D114A,PC20,D114B,PR20,D114C];
LD116=[D116A,ST22,D116B];
LD118=[D118A,PC24,D118B,BPM24,D118C,I24,D118D,C24,D118E];
LD120=[D120A,PC26,D120B,IV26,D120C];
LD123=[D123A,FV28,D123B,BPM28,D123C,I28,D123D,PR28,D123E,A28X,D123F,A29Y,D123G,ST29,D123H,PC29,D123I,I29,D123J];
LD124=[D124A,A32X,D124B,A33Y,D124C,BPM31,D124D,BPM32,D124E,PR33,D124F,C37,D124G];
% shared line with BSY
ALINEA=[BEGBSYA_1,RWWAKE3A,BKRAPM1A,BKRAPM1B,DAPM1,PCAPM1,DAPM1,BKRAPM2A,BKRAPM2B,DAPM2A,DSCAPM2,DAPM2B,PCAPM2,DAPM2,BKRAPM3A,BKRAPM3B,DAPM3,PCAPM3,DAPM3,BKRAPM4A,BKRAPM4B,DAPM4,PCAPM4,DA01,DA02];
% separate line from BSY
ALINEB=[PCBSYA,DA03A,YCBSYA,DA03B,YAGAPM,DA04A,DBRDAS2A,DBRDAS2B,DA04B,DRCDAS19,ENDBSYA_1];
ALINEC=[BEGBSYA_2,DA04C,PRBRAM1,DA05,TGTBRAM1,DA06,BRAM1A,BRAM1B,ROLL2,DAMQ10,Q10,Q10,LD105,Q11,Q11,D106,BEGB,B11A,B11B,D107,B12A,B12B,LD108,B13A,B13B,D109,B14A,B14B,LD110,B15A,B15B,D111,B16A,B16B,LD112,Q19,Q19,LD113,Q20,Q20,LD114,B21A,B21B,D115,B22A,B22B,LD116,B23A,B23B,D117,B24A,B24B,LD118,B25A,B25B,D119,B26A,B26B,MARC,ROLL3,ENDB,LD120,Q27,Q27,D121,SQ27P5,SQ27P5,D122,Q28,Q28,LD123,Q30,Q30,LD124,Q38,Q38,D125,ALWALL,DPR2,ENDBSYA_2];
ESAS=[D201,BXD1S,BXD1S,D202,BXD2S,BXD2S,D203,BXD3S,BXD3S,D204,Q1S,Q1S,D205,Q2S,Q2S,D206,Q3S,Q3S,D207,Q4S,Q4S,D208,ESAE,D209,BMDE];
ALINE=[ALINEA,ALINEB,ALINEC,ESAS];
% ------------------------------------------------------------------------------

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc bypass line, plus match to LTU
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 11-JUN-2019, M. Woodley
%  * change STBP34A/STBP34B from ST60-type to LCLS EBD-type per A. Ibrahimov
%  * move STBP34A/BTMBP34A and STBP34B/BTMBP34B u/s ~17 m per L. Borzenets
% 20-FEB-2019, M. Woodley
%  * move CBP33 ~20 cm u/s per A. Ibrahimov
% ------------------------------------------------------------------------------
% 07-JAN-2019, M. Woodley
%  * remove BTMSP1s, BTMSP2s, BTMSP3s, and BTMSP4s per RP-RPG-181130-MEM-01
% ------------------------------------------------------------------------------
% 17-OCT-2018, M. Woodley (per A. Ibrahimov)
%  * add CBP33 (PPS "collimator" plate w/o BTM)
% 31-MAY-2018, M. Woodley (per A. Ibrahimov)
%  * remove STBP34A (D2-type)
%  * STBP34B and STBP34C (ST60-type) move into STBP34A and STBP34B locations
%  * undefer STBP34A,B ... LCLS will pay for them
% ------------------------------------------------------------------------------
% 25-JAN-2018, M. Woodley
%  * set length of PCSP1S-4S to 2" per A. Ibrahimov
%  * remove PC90B per A. Ibrahimov
% 20-DEC-2017, M. Woodley
%  * remove BCS ACM IMBP28 per C. Clarke
% 02-NOV-2017, M. Woodley
%  * add sector boundary MARKERs
% ------------------------------------------------------------------------------
% 06-SEP-2017, Y. Nosochkov
%  * update positions of BCS collimators PCSP1S,2S,3S,4S and the corresponding
%    BTMs BTMSP1S,2S,3S,4S per RP-RPG-170802-MEM-01 (M. Santana)
%  * add deferred BCS collimator PC90B (M. Santana)
%  * defer stoppers STBP34a,b,c, and the corresponding BTMs BTMBP34a,b,c
%    to level 4 as they are not required for baseline (J. Welch, P. Emma)
% ------------------------------------------------------------------------------
% 24-FEB-2017, Y. Nosochkov
%  * move BPMBP32 0.060376 m downstream (M. Kosovsky)
% 16-FEB-2016, M. Woodley
%  * move Dogleg/Bypass boundary to Z= 1202.631303 m per G. DeContreras
%  * move RFBWSBP4 and WSBP4 to DLBM.xsif ... rename WSBPs
% ------------------------------------------------------------------------------
% 02-NOV-2016, Y. Nosochkov
%  * move BPMBP36 1.2 cm downstream (Alev)
%  * add a note that BTM behind stopper is part of the stopper design
%  * move BPMBP32 to upstream side of QBP32 (M. Kosovsky)
%  * move to baseline: BPMBP24, BPMBP35, IMBP28, PCSP3s, BTMSP3s, XCBP33,
%    YCBP33, PCSP4S, BTMSP4S, BTMBP34A, BTMBP34B, BTMBP34C
% ------------------------------------------------------------------------------
% 29-JUN-2016, M. Woodley
%  * adjust location of WOODDOOR (Z=3050.512)
% 24-JUN-2016, Y. Nosochkov
%  * change engineering type of the following correctors from "Bypass"
%    to "class-4": XCBP30 through XCBP34 and YCBP30 through YCBP34 (P. Emma)
%  * add deferred BTMBP34a, BTMBP34b, BTMBP34c behind the corresponding
%    PPS stoppers (S. Mao)
%  * move IMSP1s to just downstream of the BXSP2s (S. Mao)
%  * update engineering type designations of current monitors (J. Welch)
% ------------------------------------------------------------------------------
% 26-FEB-2016, M. Woodley
%  * add wood door at LI30/BSY boundary (WOODDOOR)
%  * remove SEQnn MARKers
% 26-FEB-2016, Y. Nosochkov
%  * move RFBWSBP4, WSBP4 to linac sector 12 and rename to RFBWSBP1, WSBP1
%    (see DLBM.xsif) (Tor)
%  * rename the remaining three sets of RFBWSBP/WSBP in this file with
%    numbers 2,3,4
%  * move BPMBP32, XCBP32, YCBP32 24" downstream (C.Iverson)
%  * remove IMSP2s (per S. Mao)
%  * move QBP28 0.3 m upstream to provide space for a longer spreader kicker
%  * move CYBP20, CYBP24 two sectors downstream to avoid interference with
%    FACET-II and change their names to CYBP22, CYBP26
% ------------------------------------------------------------------------------
% 01-OCT-2015, M. Woodley
%  * move CYBP20, CXBP21, CYBP24, and CXBP25 0.381 m downstream per T. O'Heron
%  * set collimator gaps per P. Emma
% 25-SEP-2015, Y. Nosochkov
%  * make the CUSXR merge bend to appear in LCLS2scS line
% 24-AUG-2015, Y. Nosochkov
%  * add stripline BPMBP24, BPMBP35 (deferred @0) next to deferred
%    RFBBP24, RFBBP35 to improve orbit correction (per P. Emma)
%  * restore correctors XCBP33, YCBP33 (deferred at level @0)
%  * move CXBP34 1 m upstream of QBP34 for a higher beta-x
%  * adjust length of FODOLb, BYPM sections to accommodate the shifted
%    downstream SXR chicane
%  * adjust positions of QBP35, QBP36, QBP30, QBP31, QBP32, QBP33 and
%    corresponding devices
%  * adjust position of CXBP30 for optimal phase and beta function
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * add deferred BTMSP3s and BTMSP4s behind PCSP3s and PCSP4s (per S. Mao)
%  * move IMSP1s, IMSP2s, PCSP3s just d/s of BXSP3S (per S. Mao)
%  * remove QBP37, QBP38 and the corresponding BPMs/corrs
%  * rename STBP33a,STBP33b,STBP33c -> STBP34a,STBP34b,STBP34c and move them
%    close to the muon wall (per S. Mao)
%  * move CXBP34, PCSP4S ~6 m upstream
%  * update gaps of the halo collimators (per P. Emma)
%  * reduce length of halo collimators (CX.., CY..) from 8 cm to 6 cm (P. Emma)
%  * move CXBP30 ~30 m downstream for 100 m beta function (per P. Emma)
%  * adjust position of BPMBP36 (per T. O'Heron)
% ------------------------------------------------------------------------------
% 20-MAR-2015, M. Woodley
%  * assign TYPEs to BCS devices ... defer at level 0
% 12-MAR-2015, Y. Nosochkov
%  * modify drifts downstream of QBP32 to include the CUSXR merge point
%  * add QBP37, QBP38 (with BPM & corrs) for optics match with CUSXR beamline
%  * adjust positions of QBP33, QBP34 for a better match with CUSXR
% ------------------------------------------------------------------------------
% 12-DEC-2014, M. Woodley
%  * assign BPM TYPE attributes per PRD LCLSII-2.4-PR-0136
% 09-DEC-2014, Y. Nosochkov
%  * move STBP32 stopper to inside of the SXR spreader chicane and rename it
%    to STSP5s
%  * move D10 dump inside the muon wall in the BSY
%  * add BCS current monitor IMBP28 upstream of the spreader (S. Mao)
%  * add BCS current monitors IMSP1s, IMSP2s upstream of muon wall
%    in SXR (S. Mao)
%  * add BCS collimators PCSP3s, PCSP4s in SPS
% ------------------------------------------------------------------------------
% 28-OCT-2014, M. Woodley
%  * rematch downstream end bypass line (matching subroutine MBYPSP)
%  * set TYPE="fast" for all wire scanners
% ------------------------------------------------------------------------------
% 15-OCT-2014, M. Woodley
%  * rematch downstream end bypass line (matching subroutine MBYPSP)
% 13-OCT-2014, Y. Nosochkov
%  * remove XCBP37, YCBP37 and XCBP33, YCBP33 correctors as redundant
% 10-OCT-2014, Y. Nosochkov
%  * update the TYPE of (4) RFBPMs to indicate the non-baseline level "0"
% 07-AUG-2014, M. Woodley
%  * change "Q2MRK" to "MQBP23" to obey naming convention
%  * restore existing stripline BPMs BPMBP14, BPMPB16, BPMBP18, and BPMBP20;
%    add cavity BPMs near wire scanners
%  * decorate device TYPE attributes to indicate non-baseline status
% 30-JUL-2014, Y. Nosochkov
%  * adjust positions of QBP31, QBP32, QBP35, QBP36 to minimize beta functions
%  * remove quad QBP37
% 22-JUL-2014, Y. Nosochkov
%  * move 4 bypass betatron collimators further downstream
% 02-MAY-2014, M. Woodley
%  * add RWWAKEss MARKER at end of bypass line (for resistive wall wakefield)
% 01-MAY-2014, Y. Nosochkov
%  * replace BPMBP30, BPMBP33 with cavity BPMs RFBBP30, RFBBP33 (per J. Frisch)
% 23-APR-2014, Y. Nosochkov
%  * replace stripline BPMs BPMBP14, BPMBP16, BPMBP18, BPMBP20, BPMBP24,
%    BPMBP35 with cavity BPMs RFBBP14, RFBBP16, RFBBP18, RFBBP20, RFBBP24,
%    RFBBP35 (per J. Frisch)
% 15-APR-2014, Y. Nosochkov
%  * update collimator jaw aperture per LCLSII-2.4-PR-0095
% 09-APR-2014, Y. Nosochkov
%  * add SXR betatron collimators CXBP30, CXBP34
% 07-APR-2014, M. Woodley
%  * reorder some drift length parameter definitions and drift length
%    definitions to avoid using parameters/attributes before they are defined
% 04-APR-2014, Y. Nosochkov
%  * add BCS stopper STBP32 upstream of 3 PPS stoppers in SXR
% ------------------------------------------------------------------------------
% 31-MAR-2014, M. Woodley
%  * element names changed to conform to nomenclature PRD
% 25-MAR-2014, Y. Nosochkov
%  * add marker D10Js for location of D10 dump face in SXR line
%  * remove BYKIKb, SPOILERb, TDKIKb, SPOILD2b
%  * change names: D2b -> STBP33a, ST60b -> STBP33b, ST61b -> STBP33c
% 06-MAR-2014, Y. Nosochkov
%  * minor matching update
% 26-FEB-2014, Y. Nosochkov
%  * rematch to the updated spreader
% 17-JAN-2014, Y. Nosochkov
%  * add QBP36, rematch to the updated spreader
% 18-DEC-2013, Y. Nosochkov
%  * update match to the spreader
% 16-DEC-2013, Y. Nosochkov
%  * match to the updated 3-way spreader with low R56
% 03-DEC-2013, Y. Nosochkov
%  * match to the updated spreader
% 21-NOV-2013, Y. Nosochkov
%  * rematch bypass quads for the 3-way spreader system
% 17-OCT-2013, M. Woodley
%  * merge Yuri's LTU.xsif into BYP.xsif ... this file now defines QBP13
%   (center) to MUWALL
% ------------------------------------------------------------------------------
% ==============================================================================
% dipoles
% ------------------------------------------------------------------------------
% single beam dumper vertical kicker (removed)
LKIKY =  1.0601 ;%kicker coil length per magnet (m) [41.737"; SA-380-330-02]
% ==============================================================================
% quadrupoles
% ------------------------------------------------------------------------------
KQY =   0.060580505638 ;%45 degree bypass FODO
QFY={'qu' 'QFY' LQM/2 [KQY 0]}';%dummy magnet
QDY={'qu' 'QDY' LQM/2 [-KQY 0]}';%dummy magnet
KQBP25 =   0.070273904791;
KQBP26 =  -0.10552161126;
KQBP27 =   0.11147451141;
KQBP35 =  -0.291127425586;
KQBP28 =   0.323836147473;
% note: the below K-values are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQBP36 =   0.581697629762;
KQBP30 =  -0.590302308366;
KQBP31 =   0.613494534195;
KQBP32 =  -0.4894624779;
KQBP33 =  -0.372466028535 ;%-0.372465866026
KQBP34 =   0.548440043187 ;% 0.548440309982
QBP13={'qu' 'QBP13' LQM/2 [KQY 0]}';
QBP14={'qu' 'QBP14' LQM/2 [-KQY 0]}';
QBP15={'qu' 'QBP15' LQM/2 [KQY 0]}';
QBP16={'qu' 'QBP16' LQM/2 [-KQY 0]}';
QBP17={'qu' 'QBP17' LQM/2 [KQY 0]}';
QBP18={'qu' 'QBP18' LQM/2 [-KQY 0]}';
QBP19={'qu' 'QBP19' LQM/2 [KQY 0]}';
QBP20={'qu' 'QBP20' LQM/2 [-KQY 0]}';
QBP21={'qu' 'QBP21' LQM/2 [KQY 0]}';
QBP22={'qu' 'QBP22' LQM/2 [-KQY 0]}';
QBP23={'qu' 'QBP23' LQM/2 [KQY 0]}';
QBP24={'qu' 'QBP24' LQM/2 [-KQY 0]}';
QBP25={'qu' 'QBP25' LQM/2 [KQBP25 0]}';
QBP26={'qu' 'QBP26' LQM/2 [KQBP26 0]}';
QBP27={'qu' 'QBP27' LQM/2 [KQBP27 0]}';
QBP35={'qu' 'QBP35' LQM/2 [KQBP35 0]}';
QBP28={'qu' 'QBP28' LQM/2 [KQBP28 0]}';
QBP36={'qu' 'QBP36' LQM/2 [KQBP36 0]}';
QBP30={'qu' 'QBP30' LQM/2 [KQBP30 0]}';
QBP31={'qu' 'QBP31' LQM/2 [KQBP31 0]}';
QBP32={'qu' 'QBP32' LQM/2 [KQBP32 0]}';
QBP33={'qu' 'QBP33' LQM/2 [KQBP33 0]}';
QBP34={'qu' 'QBP34' LQM/2 [KQBP34 0]}';
% ==============================================================================
% drifts
% ------------------------------------------------------------------------------
% bypass drifts which locate BPMs, XCORs, YCORs, WSs, and collimators w.r.t.
% bypass line "2Q4" QUADs
LCM2A =  31.2135115 ;%places upstream face of muon wall at proper z-location
ZQBP35 =  28.5 ;%adjust position of QBP35
ZQBP36 =   0.0 ;%adjust position of QBP36
ZQBP30 =   0.0 ;%adjust position of QBP30
ZQBP31 =   0.0 ;%adjust position of QBP31
ZQBP32 =   0.0 ;%adjust position of QPB32
ZQBP33 =   0.0 ;%adjust position of QBP33
ZQBP34 =   0.0 ;%adjust position of QBP34
ZMRGCUS =   0.0 ;%adjust position of MRGCUSXR
% DCY : 1/2 dist. between bypass quads - from PEP-II deck
DCY={'dr' '' (101.6-LQM)/2 []}';
DCYSA={'dr' '' 15.468697 []}';%to sector boundary
DCYSB={'dr' '' DCY{3}-DCYSA{3} []}';
DCYC={'dr' '' 15.28728-ZQBP30 []}';
% D2Q4a : QUAD to BPM
% D2Q4b : BPM to XCOR
% D2Q4c : XCOR to YCOR
% D2Q4d : a+b+c+d=DCY
% DQ24e : YCOR to COLL
D2Q4A={'dr' '' 0.4598 []}';
D2Q4B={'dr' '' 0.7433 []}';
%D2Q4aa : DRIF, L=D2Q4a[L] -0.012
%D2Q4ba : DRIF, L=D2Q4b[L] +0.012
D2Q4AB={'dr' '' D2Q4A{3}+0.6096 []}';
D2Q4C={'dr' '' 0.2794 []}';
D2Q4D={'dr' '' DCY{3}-(D2Q4A{3}+D2Q4B{3}+D2Q4C{3}) []}';
DDCYD =  0.0 ;%adjust Z at BSYEND
DCYD={'dr' '' 35.977199997076+DDCYD+ZQBP31 []}';
DCYDB={'dr' '' 1.0 []}';
DCYDA={'dr' '' DCYD{3}-DCYDB{3}-LJAW []}';
DCYFA={'dr' '' 1.0 []}';
DCYFB={'dr' '' 0.5 []}';
DCYFC={'dr' '' 1.0 []}';
DCYFD={'dr' '' 5.952523028144+0.3 []}';
DCYFE={'dr' '' 12.43034602883-DCYFA{3}-DCYFB{3}-DCYFC{3}-DCYFD{3}+ZQBP36 []}';
DCYFEA={'dr' '' 2.512 []}';%3.0
DCYFEB={'dr' '' DCYFE{3}-DCYFEA{3} []}';
DCYG={'dr' '' 3.9034-ZQBP36+ZQBP30 []}';
DBP1B={'dr' '' 19.48139075 []}';
DBP2B={'dr' '' 0.0 []}';
DBP3B={'dr' '' 1.0 []}';
DBP3A={'dr' '' 10.02938-LQM-(D2Q4A{3}+D2Q4B{3}+D2Q4C{3})-DBP3B{3}-LJAW-ZQBP33+ZQBP34 []}';
DBP3AA={'dr' '' 4.854935+0.2492 []}';
DBP3AB={'dr' '' DBP3A{3}-DBP3AA{3}-LPCSP []}';
LDCWL =  7.0;
DCWLB={'dr' '' 2.158425 []}';
DCWLA={'dr' '' LDCWL-LPCSP-DCWLB{3} []}';
D2Q4E={'dr' '' 1.651 []}';%1.27
D2Q4F={'dr' '' D2Q4D{3}-(D2Q4E{3}+LJAW) []}';
D2Q4H={'dr' '' 2.4 []}';
D2Q4G={'dr' '' D2Q4F{3}-D2Q4H{3} []}';
D2Q4G2={'dr' '' 0.1 []}';
D2Q4G1={'dr' '' D2Q4G{3}-D2Q4G2{3} []}';
D2Q4J={'dr' '' 1.0 []}';
D2Q4I={'dr' '' D2Q4D{3}-D2Q4J{3} []}';
D2Q4I2={'dr' '' 0.1 []}';
D2Q4I1={'dr' '' D2Q4I{3}-D2Q4I2{3} []}';
D2Q4K={'dr' '' 2.0 []}';
D2Q4L={'dr' '' 4.47139075-(D2Q4A{3}+D2Q4B{3}+D2Q4C{3})-ZQBP31+ZQBP32 []}';
D2Q4LB={'dr' '' 0.52015-0.060376 []}';
D2Q4LA={'dr' '' D2Q4L{3}-D2Q4LB{3} []}';
D2Q4LAA={'dr' '' 1.282797 []}';
D2Q4LAB={'dr' '' D2Q4LA{3}-D2Q4LAA{3}-LPCSP []}';
D2Q4M={'dr' '' 72.3206715-0.6096-(D2Q4A{3}+D2Q4B{3}+D2Q4C{3})-LQM/2-ZQBP32+ZQBP33 []}';
D2Q4MA={'dr' '' 61.387806499999-LBRCUS-0.6096-ZQBP32+ZMRGCUS []}';
D2Q4MA1={'dr' '' 6.128206+0.2492 []}';
D2Q4MA2={'dr' '' D2Q4MA{3}-D2Q4MA1{3}-LPCSP []}';
LSTEBD =  2*(3.125*IN2M) ;%length of EBD-type stopper
D2Q4MB={'dr' '' D2Q4M{3}-D2Q4MA{3}-LBRCUS []}';
D2Q4MBA={'dr' '' 2.15244 []}';%2.35
D2Q4MBB={'dr' '' 5.09756-LSTEBD/2 []}';
D2Q4MBC={'dr' '' 1.648-LSTEBD []}';
D2Q4MBD={'dr' '' D2Q4MB{3}-D2Q4MBA{3}-D2Q4MBB{3}-LSTEBD-D2Q4MBC{3}-LSTEBD []}';
D2Q4O={'dr' '' 8.58398-LDCWL-ZQBP34 []}';
D2Q4Q={'dr' '' 0.5 []}';
D2Q4S={'dr' '' D2Q4D{3}-LQM/2+ZQBP35 []}';
D2Q4SA={'dr' '' 64.723997 []}';
D2Q4SB={'dr' '' D2Q4S{3}-D2Q4SA{3} []}';
D2Q4T={'dr' '' D2Q4D{3}-LQM/2-ZQBP35-0.3 []}';
% ==============================================================================
% collimators
% ------------------------------------------------------------------------------
CXBP21={'dr' 'CXBP21' LJAW []}';
CYBP22={'dr' 'CYBP22' LJAW []}';
CXBP25={'dr' 'CXBP25' LJAW []}';
CYBP26={'dr' 'CYBP26' LJAW []}';
CXBP30={'dr' 'CXBP30' LJAW []}';
CXBP34={'dr' 'CXBP34' LJAW []}';
% ==============================================================================
% BPMs
% ------------------------------------------------------------------------------
BPMBP13={'mo' 'BPMBP13' 0 []}';
BPMBP14={'mo' 'BPMBP14' 0 []}';
BPMBP15={'mo' 'BPMBP15' 0 []}';
BPMBP16={'mo' 'BPMBP16' 0 []}';
BPMBP17={'mo' 'BPMBP17' 0 []}';
BPMBP18={'mo' 'BPMBP18' 0 []}';
BPMBP19={'mo' 'BPMBP19' 0 []}';
BPMBP20={'mo' 'BPMBP20' 0 []}';
BPMBP21={'mo' 'BPMBP21' 0 []}';
BPMBP22={'mo' 'BPMBP22' 0 []}';
BPMBP23={'mo' 'BPMBP23' 0 []}';%2/22/11
BPMBP24={'mo' 'BPMBP24' 0 []}';%to be replaced by RF BPM later
BPMBP25={'mo' 'BPMBP25' 0 []}';%2/22/11
BPMBP26={'mo' 'BPMBP26' 0 []}';%2/22/11
BPMBP27={'mo' 'BPMBP27' 0 []}';%2/22/11
BPMBP28={'mo' 'BPMBP28' 0 []}';%2/22/11
BPMBP35={'mo' 'BPMBP35' 0 []}';%to be replaced by RF BPM later
BPMBP36={'mo' 'BPMBP36' 0 []}';
BPMBP31={'mo' 'BPMBP31' 0 []}';
BPMBP32={'mo' 'BPMBP32' 0 []}';
BPMBP34={'mo' 'BPMBP34' 0 []}';
RFBWSBP2={'mo' 'RFBWSBP2' 0 []}';
RFBWSBP3={'mo' 'RFBWSBP3' 0 []}';
RFBWSBP4={'mo' 'RFBWSBP4' 0 []}';
RFBBP24={'mo' 'RFBBP24' 0 []}';%4/23/14
RFBBP35={'mo' 'RFBBP35' 0 []}';%4/23/14
RFBBP30={'mo' 'RFBBP30' 0 []}';
RFBBP33={'mo' 'RFBBP33' 0 []}';
% ==============================================================================
% XCORs
% ------------------------------------------------------------------------------
XCBP13={'mo' 'XCBP13' 0 []}';
XCBP14={'mo' 'XCBP14' 0 []}';
XCBP15={'mo' 'XCBP15' 0 []}';
XCBP16={'mo' 'XCBP16' 0 []}';
XCBP17={'mo' 'XCBP17' 0 []}';
XCBP18={'mo' 'XCBP18' 0 []}';
XCBP19={'mo' 'XCBP19' 0 []}';
XCBP20={'mo' 'XCBP20' 0 []}';
XCBP21={'mo' 'XCBP21' 0 []}';
XCBP22={'mo' 'XCBP22' 0 []}';
XCBP23={'mo' 'XCBP23' 0 []}';%2/22/11
XCBP24={'mo' 'XCBP24' 0 []}';%4/18/13
XCBP25={'mo' 'XCBP25' 0 []}';%4/18/13
XCBP26={'mo' 'XCBP26' 0 []}';%4/18/13
XCBP27={'mo' 'XCBP27' 0 []}';%4/18/13
XCBP35={'mo' 'XCBP35' 0 []}';%10/1/13
XCBP28={'mo' 'XCBP28' 0 []}';%4/18/13
%XCBP36 : HKIC, TYPE="class-4"  remove
XCBP30={'mo' 'XCBP30' 0 []}';
XCBP31={'mo' 'XCBP31' 0 []}';
XCBP32={'mo' 'XCBP32' 0 []}';
XCBP33={'mo' 'XCBP33' 0 []}';%restore
XCBP34={'mo' 'XCBP34' 0 []}';
% ==============================================================================
% YCORs
% ------------------------------------------------------------------------------
YCBP13={'mo' 'YCBP13' 0 []}';
YCBP14={'mo' 'YCBP14' 0 []}';
YCBP15={'mo' 'YCBP15' 0 []}';
YCBP16={'mo' 'YCBP16' 0 []}';
YCBP17={'mo' 'YCBP17' 0 []}';
YCBP18={'mo' 'YCBP18' 0 []}';
YCBP19={'mo' 'YCBP19' 0 []}';
YCBP20={'mo' 'YCBP20' 0 []}';
YCBP21={'mo' 'YCBP21' 0 []}';
YCBP22={'mo' 'YCBP22' 0 []}';
YCBP23={'mo' 'YCBP23' 0 []}';%2/22/11
YCBP24={'mo' 'YCBP24' 0 []}';%4/18/13
YCBP25={'mo' 'YCBP25' 0 []}';%4/18/13
YCBP26={'mo' 'YCBP26' 0 []}';%4/18/13
YCBP27={'mo' 'YCBP27' 0 []}';%4/18/13
YCBP35={'mo' 'YCBP35' 0 []}';%10/1/13
YCBP28={'mo' 'YCBP28' 0 []}';%4/18/13
%YCBP36 : VKIC, TYPE="class-4"  remove
YCBP30={'mo' 'YCBP30' 0 []}';
YCBP31={'mo' 'YCBP31' 0 []}';
YCBP32={'mo' 'YCBP32' 0 []}';
YCBP33={'mo' 'YCBP33' 0 []}';%restore
YCBP34={'mo' 'YCBP34' 0 []}';
% ==============================================================================
% diagnostics, etc.
% ------------------------------------------------------------------------------
WSBP2={'mo' 'WSBP2' 0 []}';
WSBP3={'mo' 'WSBP3' 0 []}';
WSBP4={'mo' 'WSBP4' 0 []}';
STBP34A={'mo' 'STBP34A' LSTEBD []}';%LCLS EBD-type stopper
STBP34B={'mo' 'STBP34B' LSTEBD []}';%LCLS EBD-type stopper
PCSP1S={'dr' 'PCSP1S' LPCSP []}';%BCS protection collimator
PCSP2S={'dr' 'PCSP2S' LPCSP []}';%BCS protection collimator
PCSP3S={'dr' 'PCSP3S' LPCSP []}';%BCS protection collimator
PCSP4S={'dr' 'PCSP4S' LPCSP []}';%BCS protection collimator
% Note: BTMBP34a and BTMBP34b are part of stopper design
CBP33={'mo' 'CBP33' 0 []}';%collimator plate (no BTM)
BTMBP34A={'mo' 'BTMBP34A' 0 []}';%Burn-Through-Monitor behind STBP34A
BTMBP34B={'mo' 'BTMBP34B' 0 []}';%Burn-Through-Monitor behind STBP34B
% ==============================================================================
% MARKER points
% ------------------------------------------------------------------------------
% MQBP23 : QBP23 (Q285330T) quad center (Z=2270.531303)
% S100B  : Station-100B is same Z as Station-100, but off axis in X & Y
MQBP13={'mo' 'MQBP13' 0 []}';%QBP13 FODO quad center ... Z=1254.531303 (a.k.a. "QB01")
MQBP23={'mo' 'MQBP23' 0 []}';
S100B={'mo' 'S100B' 0 []}';
RWWAKE2={'mo' 'RWWAKE2' 0 []}';%bypass line beampipe wake applied here
LTUSPLIT={'mo' 'LTUSPLIT' 0 []}';%SXR/HXR/Dump split point
MRGCUSXR={'mo' 'MRGCUSXR' 0 []}';%merge point (with CUSXR)
% sector boundaries (ZBEG=101.6*(n-1); ZEND=101.6*n)
BPN12END={'mo' 'BPN12END' 0 []}';
BPN13BEG={'mo' 'BPN13BEG' 0 []}';
BPN13END={'mo' 'BPN13END' 0 []}';
BPN14BEG={'mo' 'BPN14BEG' 0 []}';
BPN14END={'mo' 'BPN14END' 0 []}';
BPN15BEG={'mo' 'BPN15BEG' 0 []}';
BPN15END={'mo' 'BPN15END' 0 []}';
BPN16BEG={'mo' 'BPN16BEG' 0 []}';
BPN16END={'mo' 'BPN16END' 0 []}';
BPN17BEG={'mo' 'BPN17BEG' 0 []}';
BPN17END={'mo' 'BPN17END' 0 []}';
BPN18BEG={'mo' 'BPN18BEG' 0 []}';
BPN18END={'mo' 'BPN18END' 0 []}';
BPN19BEG={'mo' 'BPN19BEG' 0 []}';
BPN19END={'mo' 'BPN19END' 0 []}';
BPN20BEG={'mo' 'BPN20BEG' 0 []}';
BPN20END={'mo' 'BPN20END' 0 []}';
BPN21BEG={'mo' 'BPN21BEG' 0 []}';
BPN21END={'mo' 'BPN21END' 0 []}';
BPN22BEG={'mo' 'BPN22BEG' 0 []}';
BPN22END={'mo' 'BPN22END' 0 []}';
BPN23BEG={'mo' 'BPN23BEG' 0 []}';
BPN23END={'mo' 'BPN23END' 0 []}';
BPN24BEG={'mo' 'BPN24BEG' 0 []}';
BPN24END={'mo' 'BPN24END' 0 []}';
BPN25BEG={'mo' 'BPN25BEG' 0 []}';
BPN25END={'mo' 'BPN25END' 0 []}';
BPN26BEG={'mo' 'BPN26BEG' 0 []}';
BPN26END={'mo' 'BPN26END' 0 []}';
BPN27BEG={'mo' 'BPN27BEG' 0 []}';
BPN27END={'mo' 'BPN27END' 0 []}';
% ==============================================================================
% BEAMLINEs
% ------------------------------------------------------------------------------
FODO=[QFY,DCY,DCY,QDY,QDY,DCY,DCY,QFY];
BYPI=[BEGBYP,RFBWSBP2,D2Q4I2,WSBP2,D2Q4J,DCYSA,BPN12END,BPN13BEG,DCYSB,QBP13,MQBP13];
FODOLA=[QBP13,D2Q4A,BPMBP13,D2Q4B,XCBP13,D2Q4C,YCBP13,D2Q4D,DCYSA,BPN13END,BPN14BEG,DCYSB,QBP14,QBP14,D2Q4A,BPMBP14,D2Q4B,XCBP14,D2Q4C,YCBP14,D2Q4I1,RFBWSBP3,D2Q4I2,WSBP3,D2Q4J,DCYSA,BPN14END,BPN15BEG,DCYSB,QBP15,QBP15,D2Q4A,BPMBP15,D2Q4B,XCBP15,D2Q4C,YCBP15,D2Q4D,DCYSA,BPN15END,BPN16BEG,DCYSB,QBP16,QBP16,D2Q4A,BPMBP16,D2Q4B,XCBP16,D2Q4C,YCBP16,D2Q4I1,RFBWSBP4,D2Q4I2,WSBP4,D2Q4J,DCYSA,BPN16END,BPN17BEG,DCYSB,QBP17,QBP17,D2Q4A,BPMBP17,D2Q4B,XCBP17,D2Q4C,YCBP17,D2Q4D,DCYSA,BPN17END,BPN18BEG,DCYSB,QBP18,QBP18,D2Q4A,BPMBP18,D2Q4B,XCBP18,D2Q4C,YCBP18,D2Q4D,DCYSA,BPN18END,BPN19BEG,DCYSB,QBP19,QBP19,D2Q4A,BPMBP19,D2Q4B,XCBP19,D2Q4C,YCBP19,D2Q4D,DCYSA,BPN19END,BPN20BEG,DCYSB,QBP20,QBP20,D2Q4A,BPMBP20,D2Q4B,XCBP20,D2Q4C,YCBP20,D2Q4D,DCYSA,BPN20END,BPN21BEG,DCYSB,QBP21,QBP21,D2Q4A,BPMBP21,D2Q4B,XCBP21,D2Q4C,YCBP21,D2Q4E,CXBP21,D2Q4F,DCYSA,BPN21END,BPN22BEG,DCYSB,QBP22,QBP22,D2Q4A,BPMBP22,D2Q4B,XCBP22,D2Q4C,YCBP22,D2Q4E,CYBP22,D2Q4F,DCYSA,BPN22END,BPN23BEG,DCYSB,QBP23,MQBP23,QBP23,D2Q4A,BPMBP23,D2Q4B,XCBP23,D2Q4C,YCBP23,D2Q4D,DCYSA,BPN23END,BPN24BEG,DCYSB,QBP24,QBP24,D2Q4A,BPMBP24,RFBBP24,D2Q4B,XCBP24,D2Q4C,YCBP24,D2Q4D,DCYSA,BPN24END,BPN25BEG,DCYSB,QBP25,QBP25,D2Q4A,BPMBP25,D2Q4B,XCBP25,D2Q4C,YCBP25,D2Q4E,CXBP25,D2Q4F,DCYSA,BPN25END,BPN26BEG,DCYSB,QBP26,QBP26,D2Q4A,BPMBP26,D2Q4B,XCBP26,D2Q4C,YCBP26,D2Q4E,CYBP26,D2Q4F,DCYSA,BPN26END,BPN27BEG,DCYSB,QBP27,QBP27,D2Q4A,BPMBP27,D2Q4B,XCBP27,D2Q4C,YCBP27,D2Q4SA,BPN27END,D2Q4SB,QBP35,QBP35,D2Q4A,BPMBP35,RFBBP35,D2Q4B,XCBP35,D2Q4C,YCBP35,D2Q4T,QBP28,QBP28,D2Q4A,BPMBP28,D2Q4B,XCBP28,D2Q4C,YCBP28,D2Q4Q,LTUSPLIT,RWWAKE2,ENDBYP];
FODOLB=[DCYFA,DCYFB,DCYFC,DCYFD,S100B,DCYFEA,WOODDOOR];
FODOLC=[DCYFEB,QBP36,QBP36,D2Q4A,BPMBP36,D2Q4B,D2Q4C ,DCYG ,QBP30,QBP30,D2Q4A,RFBBP30,D2Q4B,XCBP30,D2Q4C,YCBP30,DCYC];
FODOL=[FODOLA,SPRDS,FODOLB,FODOLC];
BYPM1=[DCYDA ,CXBP30 ,DCYDB,QBP31,QBP31,D2Q4A ,BPMBP31,D2Q4B,XCBP31,D2Q4C,YCBP31,D2Q4LAA,PCSP1S,D2Q4LAB,BPMBP32,D2Q4LB,QBP32,QBP32,D2Q4AB,D2Q4B,XCBP32,D2Q4C,YCBP32,D2Q4MA1,PCSP2S,D2Q4MA2];
BYPM2=[D2Q4MBA,CBP33,D2Q4MBB,STBP34A,BTMBP34A,D2Q4MBC,STBP34B,BTMBP34B,D2Q4MBD,DBP2B,QBP33,QBP33,D2Q4A,RFBBP33,D2Q4B,XCBP33,D2Q4C,YCBP33,DBP3AA,PCSP3S,DBP3AB,CXBP34,DBP3B,QBP34,QBP34,D2Q4A,BPMBP34,D2Q4B,XCBP34,D2Q4C,YCBP34,D2Q4O,DCWLA,PCSP4S,DCWLB];
BYPM=[BYPM1,BRCUS1A,BRCUS1B,MRGCUSXR,BYPM2];
BYPASS=[BYPI,FODOL,BYPM];
% ------------------------------------------------------------------------------

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc LTU and dump
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 06-JUN-2019, M. Woodley
%  * adjust location of BSY dump face per A. Ibrahimov
% 28-MAY-2019, M. Woodley
%  * remove LTUS BFWXL1, BFWXL2, BFWXL3, BFWXL4 per G. Kraft
%  * remove LTUH OTR30 per G. Kraft
%  * add XCXL1/YCXL1 u/s of UMXL1, amd XCXL2/YCXL2 u/s of UMXL3 per T. O'Heron
%  * flip RFBXL1-4 per T. O'Heron ... each moves 0.61" d/s
% 23-MAY-2019, M. Woodley
%  * move TDKIKS and PCTDKIK1-4 u/s 0.020651 m per T. O'Heron
%  * adjust BYKIK1S/BYKIK2S separation per T. O'Heron
% 24-APR-2019, M. Woodley
%  * fix edge angle definitions for XLEAP-II self-seeding chicane per Yuri
% 20-FEB-2019, M. Woodley
%  * remove CY32, CX35, and CY36 per D. Hanquist (reconfigured as CYBX32,
%    CXQT22, and CYBX36 respectively)
% ------------------------------------------------------------------------------
% 07-JAN-2019, M. Woodley
%  * remove BTMBSY3, BTMBSY4, and BTMBSY5 per RP-RPG-181130-MEM-01
% 24-JAN-2019, M. Woodley
%  * move CC36 5.8" d/s per T. O'Heron
% ------------------------------------------------------------------------------
% 24-NOV-2018, M. Woodley
%  * EBD dump face to BTM face = 61.120" (per Alev)
% 09-NOV-2018, M. Woodley
%  * move CC32 1.2924 m d/s per T. O'Heron
%  * move WSVM2 0.0046 m d/s per T. O'Heron
% 29-OCT-2018, M. Woodley
%  * add XLEAP-II components (4 undulators, self-seeding chicane, wiggler)
%    > wiggler and undulators scale with Eu
% 19-OCT-2018, M. Woodley
%  * move BTM06 d/s 4 cm per T. O'Heron
% 11-OCT-2018, M. Woodley
%  * use average measured FINT for 0.788D11.50's
% 04-OCT-2018, M. Woodley
%  * include alternative DC extraction into CUSXR:
%    - change length of DBSY52b (moves BEGCLTH2 and BEGCLTS u/s 0.621262 m)
%    - change definition of DBSY52c
%  * undefer all BCS BTMs listed in RP-RPG-170714-MEM-01-R1 (Table 1)
% 24-SEP-2018, M. Woodley
%  * defer OTRDMPB (level 1) per D. Hanquist
% 10-SEP-2018, M. Woodley
%  * set TYPE of "YAGPSI" (in LTUH) to "YAG-PAL", as in LCLS
% 15-AUG-2018, M. Woodley
%  * remove BXKIK1, SPOILER1, and TDKIK1 (replaced by STCLTS)
% 06-AUG-2018, M. Woodley
%  * move LCLS XLEAP self-seeding chicane to LTUS (between QUM3B and QUM4B)
% 26-JUL-2018, Y. Nosochkov
%  * add BYKIK1S,2S, BPMBYKS, SPOILERS and TDKIKS to SXR (P. Krejcik, A. Brachmann)
% 15-MAY-2018, M. Woodley
%  * PCPM1L/PCPM1LB and PCPM2L/PCPM2LB are aligned along the beamline (not
%    pitched/yawed)
% 12-MAR-2018, M. Woodley
%  * move PC119 to its present location (Z=3191 (center)) per A. Ibrahimov
%  * move CXQ6 to Z=3202.672 (center) per L. Borzenets
%  * add PCBSY5 (2" long) at Z=3203.2 (d/s face) per L. Borzenets
% ------------------------------------------------------------------------------
% 30-JAN-2018, M. Woodley
%  * set length of PCBSY3 and PCBSY4 to 2" per A. Ibrahimov
%  * remove PCBSY1/BTMBSY1 per A. Ibrahimov
%  * change complement/locations of BCS BTMs in BTH per RP-RPG-170714-MEM-01-R1
%    > BTM_X352 removed
%    > BTM06 has the wrong Z and needs to be relocated
% 20-DEC-2017, M. Woodley
%  * change engineering type of BX31B,32B from "1.0D103.3T" to "1.14D103.3T"
%    NOTE: don't change gap until new magnetic measurements are complete
%  * use measured FINT (0.5513) for BYD1B, BYD2B, and BYD3B
%  * remove BCS ACMs IMDUMPH and IMDUMPS per C. Clarke
% ------------------------------------------------------------------------------
% 06-SEP-2017, Y. Nosochkov
%  * update aperture size of PCMUON and PCMUONB (P. Emma)
%  * reduce gap of BX31B,32B to 1.0 inch and change engineering type to
%    1.0D103.3T (J. Amann) -- this is to allow these bends to be on the same
%    string with BYD1B,2B,3B
%  * update positions and aperture of BSC collimators and BTMs:
%    PCBSY3/BTMBSY3, PCBSY4/BTMBSY4, PC90, PC119 per RP-RPG-170802-MEM-01
%    (M. Santana);
%    notes: 1) position of PC119 is adjusted by +45 cm to avoid interference 
%    with CXQ6; 2) PCBSY3 may interfere with CuSXR line
% 09-AUG-2017, M. Woodley
%  * move wiggler definitions to top of file (for BMAD compatability)
% ------------------------------------------------------------------------------
% 08-MAY-2017, M. Woodley
%  * add 0.000001 m to LDBSY00 to align downstream Z-locations with 06MAR17
%  * put XCUM3 back where it was prior to XLEAP
%  * set D2, ST60, and ST61 lengths ... remove half-drifts
%  * undefer YCBSYQ1, XCBSYQ2, and XCBSYQ3 ... installed as part of BSY
%    Reconfiguration
%  * set minimum ID of PCPM1L/PCPM1LB to 1.125" per E. Ortiz
% 05-MAY-2017, Y. Nosochkov
%  * Update FINT, FINTX values in BX31B, BX32B to 0.4297 (M. Woodley)
% ------------------------------------------------------------------------------
% 02-MAR-2017, M. Woodley
%  * add XLEAP components between QUM2 and QUM3 (Kwig=0 ... fully open gap)
%  * assign WIRE TYPEs
%  * remove WS35 and WS36 (LTUH) ... not installed per D. Bohler, A. Cedillos
% 24-FEB-2017, Y. Nosochkov
%  * move VV999, VV999b 0.05 m downstream (D. Bruch)
%  * move RFBHX12 0.129 m upstream (from UND to LTUH) (D. Bruch)
%  * add toroids IMBSY1B, IMBSY2B, IMBSY3B as a backup for IMBSY1, IMBSY2,
%    IMBSY3 (K. Grouev); they are un-deferred since they will be installed
%  * update positions of IMBSY2, IMBSY3 (K. Grouev)
%  * update some drift names
%  * add deferred PCBSYH collimator -- it is HXR part of 2-hole copper
%    collimator downstream of A-line pulsed magnets
%  * move BPMBSYQ1 0.017624 m downstream to Z=3050.7319 m (K. Grouev)
%  * per recent measurements update Z-positions in BSY for:
%    D2 (-0.349426 m) -> Z=3192.8882 m, ST60 (-0.282226 m) -> Z=3194.3270 m,
%    DM60 (-0.342826 m) -> 3195.1480 m (K. Grouev)
%  * add new (deferred) HXR BTM_X352 at Z=3334.2 m (M. Santana, J. Stieber)
%  * move BTM_1B through BTM_6B, and BTM_8B, BTM_9B in SXR,
%    add deferred BTM_X352 in HXR (M. Santana, RP-RPG-170202-MEM-01-DRAFT)
%  * update aperture of PCPM1L, PCPM1LB, PCPM2L, PCPM2LB per present
%    engineering design (A. Ibrahimov)
% ------------------------------------------------------------------------------
% 23-NOV-2016, Y. Nosochkov
%  * change "1.259Q3.5" to "1.26Q3.5"
% ------------------------------------------------------------------------------
% 02-NOV-2016, Y. Nosochkov
%  * move definition of DRFB drift from common.xsif
%  * move BPMBSYQ1 0.0585 m downstream (K. Grouev)
%  * move BPMDL13, BPMDL16, BPMDL17 to the downstream side of a corresponding
%    collimator (J. Stieber)
%  * increase vertical half-aperture of PCMUON to 4 mm to satisfy BSC,
%    however it is an existing device, so it will need to be either rebuilt
%    or removed (J. Welch)
%  * make half-aperture of PCMUONB equal to 4 mm to satisfy BSC
%  * increase vertical half-aperture of PCPM2L, PCPM2LB to 37 mm to satisfy
%    BSC, but note that PCPM2L is an existing device
%  * move to baseline: Q50Q1, Q50Q2, IMBSY1, IMBSY2, IMBSY3, BPMBSYQ1,
%    BPMBSYQ2, PCBSY1, BTMBSY1, BPMBSYQ4, PCBSY3, BTMBSY3, PCBSY4, BTMBSY4,
%    XCVB2, BTM_1B through BTM_9B, XCVB2B, BPMEM4B, BPME32B, BPME34B, BPME36B,
%    IMDUMPH, IMDUMPS, BPMDD, BPMDDB
% ------------------------------------------------------------------------------
% 29-JUN-2016, M. Woodley
%  * adjust location of WOODDOOR (Z=3050.512)
%  * undefer OTRDMP and OTRDMPB
%  * BSY BPM names per R. Iverson and S. Hoobler
% 24-JUN-2016, Y. Nosochkov
%  * change engineering type "R56" to "0.788D11.50" (J. Amann)
%  * remove deferred BXKIK2 and change the type of deferred BXKIK1 to
%    1.26D18.43 (DC bend) (Tor, J. Amann)
%  * replace existing deferred Q50Q1 with a larger aperture quad type 2Q10 
%    to provide enough aperture for the kicked beam
%  * change the type of BPMBSY1 from Stripline-6 to Stripline-5 to
%    match the aperture of "2Q10" Q50Q1
%  * change the type of BPME31B,...,BPME36B from Stripline-2 to Stripline-1
%    (E. Kraft, J. Stieber)
%  * change the type of BPMDL11,...,BPMDL19 from Stripline-2 to
%    Stripline-5 and move them outside of the quads (E. Kraft, J. Stieber);
%    this resolves BSC at QDL13 & 17, and fits the quads better
%  * update the engineering types of existing LTUH BPMs (M. Woodley)
%  * remove existing toroids IMDUMP, IMBCS4 as they are not compatible
%    with SCRF beam (S. Mao, P. Emma)
%  * remove deferred IMBCS4B (S. Mao)
%  * add deferred BCS cavity ACMs IMDUMPH, IMDUMPS downstream of dumpline bends
%    (S. Mao)
%  * add deferred BPMEM4B (Stripline-2) at QEM4B (J. Welch)
%  * update engineering type designations of current monitors (J. Welch)
%  * move CXQ6 to the downstream side of CC31 chicane to be closer to
%    a BPM (J. Welch); move CC31 chicane 1 m upstream to provide space for CXQ6;
%    update CXQ6 X-aperture as sqrt(betx)
%  * move CYBX36 1.9 m downstream to get it closer to the nearest BPM (J. Welch)
%    and have it at a similar location relative to a bend as CYBX32 (P. Emma);
%    update CYBX36 Y-aperture as sqrt(bety)
%  * restore existing LCLS collimators CX31, CX35, CY32, CY36 (D. Hanquist)
%  * restore the existing length (8 cm) of existing collimators CEDL1, CEDL3
%  * update the engineering type of BYKIK1,2 to "1.92K41.2" (J. Amann)
%  * restore YCBSYQ1, XCBSYQ2, XCBSYQ3 correctors in BSY to deferment level 0
%  * put the existing BPMBSY39, BPMBSY88 in the baseline (P. Emma)
%  * move PC119 7.0 m upstream to Z=3191 m (S. Mao)
%  * move YCBSYQ1 upstream of Q50Q1 (K. Grouev)
%  * change the type of QVM3B to 1.26Q12 and the corresponding BPMVM3B
%    to Stripline-10 (P. Emma)
%  * move XCVM3B 0.1066 m upstream to fit with the longer QVM3B (J. Stieber)
% ------------------------------------------------------------------------------
% 15-MAR-2016, M. Woodley
%  * assign IMON TYPEs per R. Iverson
% 26-FEB-2016, Y. Nosochkov
%  * adjust positions of BPMBSY1, BPMBSY29, BPMBSY39, BPMBSY88 to match to
%    their existing installation at the corresponding BSY quads (C. Iverson)
%  * change engineering type of BPMBSY39 to Stripline-6 (C. Iverson)
%  * add existing BCS PC119 d/s of CXQ6 at Z=3198 m and existing BCS PC90
%    d/s of PCBSY4/BTMBSY4 at Z=3176 m (baseline) (S. Mao)
%  * add BCS PCBSY4/BTMBSY4 at Z=3174 (deferred @0) (S. Mao)
%  * add BCS PCBSY3/BTMBSY3 at Z=3155 m (deferred @0) (S. Mao)
%  * place BCS PCBSY1/BTMBSY1 39.199" d/s of Q50Q3 center (S. Mao & C. Iverson)
%  * place XCBSY36 64" downstream of Q50Q3 center (C. Iverson)
%  * remove BCS PCSP3H/BTMSP3H (S. Mao)
%  * move IMDUMP, IMBCS4, IMBCS4b upstream to near PCPM1L(b) to avoid 
%    potential hazard from the high power load on the dump (S. Mao)
%  * move YCBSY35 to the upstream side of Q4 to ease interference with CUSXR
%  * move IMSP1h to just dowstream of BRSP2H (S. Mao)
%  * remove IMSP2h (S. Mao)
%  * add BCS ACM IMBSY3 in the BSY1 (R. Ragle)
%  * designate the IMBSY1 as a BCS toroid (R. Ragle)
%  * designate the IMBSY34 as a diagnostic current monitor (not a BCS device)
%  * reserve separate power supply for QDL11 for future match with Cu-linac beam
% 09-FEB-2016, M. Woodley
%  * add sextupoles to correct 2nd-order dispersion per P. Emma
%  * remove SEQnn MARKers
%  * add wood door at LI30/BSY boundary (WOODDOOR)
% 13-OCT-2015, M. Woodley
%  * fix error in definition of HXR dechirpers
% ------------------------------------------------------------------------------
% 01-OCT-2015, M. Woodley
%  * add "BEG" and "END" MARKers to R56 compensation chicanes
%  * set collimator gaps per P. Emma
% 25-SEP-2015, Y. Nosochkov
%  * correct the deferment level of OTRDMP to @1
%  * change type of QDMP1B,2B from 3.25Q20 to 3.94Q17 (per D. Hanquist, P. Emma)
%  * make kickers & septum of CUSXR, and the merge bend of HXR spreader
%    to appear in LCLS2cuH, LCLS2cuAL lines
%  * make kickers & septum of A-line to appear in LCLS2cuH, LCLS2scH lines
%  * include stripline BPMDD(B) (deferred @0) at the current location of
%    RFBDD(B); move RFBDD(B) to just downstream of OTRDMP(B) (per Alev, P. Emma)
%  * defer WSDUMP, WSDUMPB to @3 as they violate BSC (per P. Emma)
%  * IMDUMP will be replaced with the toroid design as in the existing 
%    IMBCS4 for larger aperture (per Alev)
%  * existing OTRDMP will be replaced with the design SA380-536-84 for
%    larger aperture (per Alev)
%  * increase bending angle in the R56 chicanes by 15%
%  * move IMBSY34 upstream to just after the IMBSY2 (per R. Ragle)
%  * group IMBSY1, IMBSY2, IMBSY34 together separated by 12" center-to-center
%  * (per R. Ragle)
% 28-AUG-2015, M. Woodley
%  * undefer R56 compensation chicane bends (CC32, CC35, CC36, CC31B, CC32B)
%  * add wire scanner WSDL4
%  * add dechirper modules DCHIRPV and DCHIRPH (split in half)
%  * move correctors XCDL4 and YCDL4 downstream
%  * remove BEGCuSXR MARKer point from S100BSY1 line
%  * set deferment level of YCWIGS and YCWIGH same as wigglers themselves
% 24-AUG-2015, Y. Nosochkov
%  * add correctors XCVB2, XCVB2B deferred at @0 (type TBD) (per P. Emma)
%  * restore stripline BPMBSY39, BPMBSY88, BPME32B, BPME34B, BPME36B
%    (deferred @0) next to deferred RFBBSY39, RFBBSY88, RFBE32B, RFBE34B,
%    RFBE36B to improve orbit correction (per P. Emma)
%  * match dumpline optics to new TCAV/OTR constraints (per Y. Ding)
%  * add XCBSY36 corrector in BSY (deferred @0)
%  * move BPMBSY29 ~6" downstream (per C. Iverson)
%  * adjust positions of Q50Q1, Q50Q2, SPOILER1, TDKIK1 and BCS devices
%  * assume 85% larger BXKIK1,2 kick angle due to shorter distance to TDKIK1
%  * adjust position of Q6 in BSY for lower beta functions
%  * add Q4 quadrupole (baseline) and BPMBSYQ4 (deferred @0) in BSY
%  * rematch the updated spreader and BSY optics
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * move CXQ6 1 m downstream of DM60 for higher beta-x (per Paul)
%  * assign IMDUMP, IMBCS4b to be BCS current monitors
%  * add deferred BTMSP3h and BTMBSY1 behind PCSP3h and PCBSY1 (per S. Mao)
%  * move IMBSY2 upstream of BXKIK1
%  * exchange positions of IMBSY34 and PCBSY1 (per S. Mao)
%  * move IMSP2H to just d/s of IMSP1H, adjust positions of IMSP1H, PCSP3H
%    (per S. Mao)
%  * update gaps of the halo collimators (per P. Emma)
%  * reduce length of halo collimators (CX.., CY..) from 8 cm to 6 cm (P. Emma)
%  * change the status of BPMQD, BPMQDB from deferred to baseline
%  * rename CEDL14 -> CEDL13 and CEDL18 -> CEDL17 and move them next to
%    QDL13 and QDL17 (larger dispersion and ratio of disp/sqrt(beta)) 
%  * change the type of BPMQD, BPMQDB to "stripline-8" (per M. Owens)
%  * rename SPOILER -> SPOILER1 and TDKIK -> TDKIK1 in BSY1
%  * defer BXKIK, SPOILER1 and TDKIK1 in BSY1 at level @2 (per Tor)
%  * defer BSY1 magnets and devices at level @0 (per Tor)
%  * restore existing BYKIK, SPOILER, TDKIK and PCTDKIK1-4 in LTUH (per Tor)
% ------------------------------------------------------------------------------
% 20-MAR-2015, M. Woodley
%  * change TYPE for BPMVM4B, BPMBSY1, BPMBSY29, BPMBSY85, and BPMBSY92
%  * assign TYPEs to BCS devices ... defer at level 0
% 12-MAR-2015, Y. Nosochkov
%  * change type of QVM4B to "1.26Q12" in order to provide enough strength
%  * rename WSVM1 to WSVM2 and move it downstream of QVM2 (per LCLS-I update)
%  * move XCVM2 upstream between QVM1 and QVM2 (per LCLS-I update)
%  * add existing wire scanners WS35, WS36 (per LCLS-I update)
%  * remove PCTDKIK1-4 collimators in BSY1 (per S. Mao)
%  * move XCUM1B downstream of QUM1B, and then move both QUM1B and XCUM1B 0.5 m
%    downstream to provide extra 1 m room upstream for moving undulators
%    through the BTH East maze
%  * change type of QDL11-QDL19 from "1.97Q10" to "2Q10"
%  * add split point for transport from BSY1 to SXR (CUSXR beamline)
%  * add scaling with energy for R56 chicane field
% ------------------------------------------------------------------------------
% 12-DEC-2014, M. Woodley
%  * un-defer existing LTUH wire scanners (WSDL31,WS31,WS32,WS33,WS34)
%  * change some RFBs (defer=2) to BPMs (defer=0)
%  * assign BPM TYPE attributes per PRD LCLSII-2.4-PR-0136
% 09-DEC-2014, Y. Nosochkov
%  * add four PCTDKIK muon collimators d/s of the TDKIK in-line dump in BSY1
%  * restore existing YAGPSI profile monitor in HXR
%  * rename marker MUWALL (for front face of muon wall) to MUWALLb in SXR,
%    and add a corresponding marker MUWALL in HXR
%  * update length of main dump slug (DDUMP)
%  * restore existing RFB07, RFB08
%  * move D10 dump inside the muon wall in the BSY
%  * add 9 BCS burn-through-monitors BTM_1,...,BTM_9 in LTUH (S. Mao)
%  * add 9 BCS burn-through-monitors BTM_1b,...,BTM_9b in LTUS (S. Mao)
%  * add BCS current monitors IMSP1h, IMSP2h in HXR BSY (SPH)
%  * add BCS current monitors IMBSY1, IMBSY2, IMBSY34 in BSY1
%  * add BCS collimator PCBSY1 in BSY1
%  * add BCS collimator PCSP3h in HXR BSY (SPH)
%  * assign the BCX311, BCX312, BCX313, BCX314 R56 chicane bends to
%    non-baseline level "2"
%  * change to type "QE" the quads: QDBL1, QDBL2, QDL20, QDL21, QDL22, QVB1b,
%    QVB2b, QVB3b, QVM3b, QVM4b, QEM1b,...,QEM4b, QUM1b,...,QUM4b
%    note: field of QVM4b reaches the limit at 8.2 GeV
%  * change to type "1.97Q10" the quads QDL11,...,QDL19
% ------------------------------------------------------------------------------
% 28-OCT-2014, M. Woodley
%  * add resistive-wall wakefield MARKers (for ELEGANT) per P. Emma
%  * set TYPE="fast" for all wire scanners
%  * redefine start of BSY to be LI30 IV30-9 (Z=3042.005)
%  * add SEQ17 MARKers; move ENDBSY1 MARKer to entrance of SPhBSY line
% 27-OCT-2014, Y. Nosochkov
%  * move wiggler EWIGH ~1.4 m downstream and restore existing positions of
%    CEDL1, YCDL1, XCDL1, WSDL31 in LTUH
%  * add missing existing TYPE of XCA0, YCA0
% ------------------------------------------------------------------------------
% 15-OCT-2014, M. Woodley
%  * move Brhof, GBCC, ZBCC, and ZDCC parameter definitions to common.xsif
%  * change names of R56 compensation chicane bends from "BX..." to "BCX..."
%    to conform with nomenclature rules
%  * rematch BSY to DL2 dogleg (matching subroutine MBSYDL2)
% 14-OCT-2014, Y. Nosochkov
%  * add four R56 compensating chicanes in HXR (u/s of muon wall,
%    d/s of BX32, u/s of BX35, and d/s of BX36) and two chicanes in SXR
%    (u/s of BX31b, and d/s of BX32b) -- set to non-baseline level "0"
%  * add existing WSVM1 wire scanner in the LTUH VBEND area at Z'=177.4709 m
%    (per J. Stieber)
%  * restore dumpline toroids IMDUMP, IMBCS4, IMBCS4b (per LCLSII-2.4-PR-0107)
%  * modify locations of various devices in the dumpline (per A. Callen)
% 10-OCT-2014, Y. Nosochkov
%  * update the TYPE of (13) RFBPMs to indicate the non-baseline level "0"
%  * update the TYPE of (5) LTUH WIRE scanners to indicate the non-baseline
%    level "0"
% 30-SEP-2014, Y. Nosochkov
%  * rematch geometry and optics for the updated type of BX31B, BX32B
%    (1.26D103.3T)
%  * restore TDUND to its existing position in LCLS-I, specify TDUND length
%    per D. Bruch
%  * restore locations of QUM1B, QUM2B, QUM3B, QUM4B as in LCLS-I
%  * add markers for BTH/UH walls
%  * change type of XCDL4 from class-4f to class-5f (per J. Amann)
%  * restore existing LCLS-I devices IMUNDI, IM31, IM36, IMBCS1, IMBCS2,
%    OTR33, BPMEM4, BPMDL1, BPME32, BPME34, BPME36 (not part of LCLS2)
%    to avoid cost of their removal (per A. Callen)
%  * replace YCEM1B with XCEM1B, XCEM2B with YCEM2B, YCEM3B with XCEM3B,
%    and XCEM4B with YCEM4B
% 15-SEP-2014, Y. Nosochkov
%  * designate BSY1 line connecting the end of LCLS-I L3 with the beginning of
%    LCLS2 HXR merge bend BXSP1h
% 07-AUG-2014, M. Woodley
%  * change bend type of BX31B, BX32B to 1.26D103.3T (per J. Amann) ... did
%    not change length (yet)
%  * decorate device TYPE attributes to indicate non-baseline status
% 31-JUL-2014, Y. Nosochkov
%  * replace BPMDL1 with RFBDL1 in HXR
%  * remove IM31, IM31b, IMBCS1, IMBCS1b, IM36, IM36b, IMBCS2, IMUNDI, IMUNDIb,
%    RFB07, RFB07b, RFB08, RFB08b, IMDUMP, IMDUMPb, IMBCS4, IMBCS4b
% 23-JUL-2014, Y. Nosochkov
%  * move TDUNDb 2.8 m downstream (per J. Stieber)
% 15-JUL-2014, Y. Nosochkov
%  * move SXR quad QUM1b 2.0 m downstream (per J. Stieber)
% 14-JUL-2014, Y. Nosochkov
%  * move SXR quad QDL19 2.5 m downstream (per J. Stieber) -- this requires
%    moving along (2.5 m d/s) the quads QDL11 to QDL18 (to maintain dispersion
%    cancellation without moving the bends)
% 17-JUN-2014, Y. Nosochkov
%  * remove OTR33 in HXR (per J. Frisch)
%  * replace all stripline BPMs downstream of the undulators with RFBPMs
%    (per J. Frisch)
%  * move OTR33B to dispersive location near QDL18 and rename it to OTRDL18
% 12-MAY-2014, Y. Nosochkov
%  * add beam abort horizontal kicker BXKIK, SPOILER and in-line dump TDKIK
%    in the beginning of LCLS-I BSY, upstream of the LCLS2 HXR merge bend BXSP1h
% 02-MAY-2014, M. Woodley
%  * move definition of DRFB drift to common.xsif
%  * add "CNT" MARKERs after dispersive areas (ELEGANT CENTERing)
%  * remove RWWAKEal* MARKER points per P. Emma
%  * change names of wiggler segments (WIG11s/WIG12s -> WIG1SA/WIG1SB, etc.)
% 01-MAY-2014, Y. Nosochkov
%  * change YCUM3 -> XCUM3, XCUM4 -> YCUM4, YCUM3B -> XCUM3B, XCUM4B -> YCUM4B
%  * replace BPMBSY39, BPMBSY88 with cavity BPMs RFBBSY39, RFBBSY88
% 29-APR-2014, Y. Nosochkov
%  * add sync. light vertical wiggler EWIGh in LTUH
%  * add sync. light vertical wiggler EWIGs in LTUS (per J. Frisch)
% 23-APR-2014, Y. Nosochkov
%  * replace stripline BPMs BPMEM4B, BPME32B, BPME34B, BPME36B, BPMEM4,
%    BPME32, BPME34, BPME36, BPMDDB, BPMDD with cavity BPMs RFBEM4B, RFBE32B,
%    RFBE34B, RFBE36B, RFBEM4, RFBE32, RFBE34, RFBE36, RFBDDB, RFBDD
%    (per J. Frisch)
% 22-APR-2014, Y. Nosochkov
%  * add missing existing DM60 BTM monitor in the HXR BSY
%  * adjust length of PCPM1L,PCPM2L,PCPM1Lb,PCPM2Lb
%  * change magnet type of QDMP1, QDMP2 to 3.94Q17
%  * change magnet type of QDMP1b, QDMP2b to 3.25Q20
% 17-APR-2014, Y. Nosochkov
%  * change D2 definition from MARK to INST
% 15-APR-2014, Y. Nosochkov
%  * update collimator jaw aperture per LCLSII-2.4-PR-0095
% 08-APR-2014, Y. Nosochkov
%  * remove HXR betatron collimators CX31, CY32, CX35, CY36
%  * remove SXR betatron collimators CX31b, CY32b, CX35b, CY36b
%  * add HXR betatron collimators CXQ6, CYBX32, CXQT22, CYBX36
%  * add SXR betatron collimator CYBDL, CYDL16
%  * rename YCQT22 to YCQT21 and move it upstream of QT21
% 07-APR-2014, M. Woodley
%  * reorder some drift length parameter definitions and drift length
%    definitions to avoid using parameters/attributes before they are defined
% ------------------------------------------------------------------------------
% 31-MAR-2014, M. Woodley
%  * element names changed to conform to nomenclature PRD
% 26-MAR-2014, Y. Nosochkov
%  * remove PCTDKIK1,2,3,4 from HXR LTU
%  * update beta match to undulator
% 25-MAR-2014, Y. Nosochkov
%  * remove BYKIK, TDKIK and SPOILER from HXR LTU
%  * add missing ST60, ST61 stoppers in the BSY
% 21-MAR-2014, Y. Nosochkov
%  * rematch to updated undulator cells
% 07-MAR-2014, Y. Nosochkov
%  * increase main dump length (from DUMPFACE to BTMDUMP) to 1.5 m (to be
%    confirmed), remove markers EOL, EOLB
% 06-MAR-2014, Y. Nosochkov
%  * add a 0.6 mrad soft bend in front of the dump bends
%  * roll the HXR/SXR dumplines starting from the soft bend by 10 deg
%    to reduce the beam-to-beam x-separation at the dumps to ~1.88 m
%    and the vertical descent (relative to undulator) to ~1.76 m
%  * adjust Z-positions of the dump face and QDMP quads (per Mario and Maceo)
% ------------------------------------------------------------------------------
% 28-FEB-2014, Y. Nosochkov
%  * rematch to the updated undulator
% 26-FEB-2014, Y. Nosochkov
%  * rematch to the updated spreader
% 17-JAN-2014, Y. Nosochkov
%  * rematch to the updated spreader
% 18-DEC-2013, Y. Nosochkov
%  * update match to the spreader
% 16-DEC-2013, Y. Nosochkov
%  * update match to the 3-way spreader with low R56
% 03-DEC-2013, Y. Nosochkov
%  * update match to the spreader
% 25-NOV-2013, Y. Nosochkov
%  * remove QBSY1, QBSY2 and adjust locations of Q50Q1,Q50Q2,Q50Q3,Q5,Q6 to
%    maintain FODO optics while avoiding interference with divergent and
%    biconcave chambers
% 21-NOV-2013, Y. Nosochkov
%  * update QDBL1,2 strengths for the 3-way spreader system
% 26-OCT-2013, Y. Nosochkov
%  * update quadrupole type 1.26Q12 in SXR
%  * move QDBL1, QDBL2 0.5 m downstream
% 25-OCT-2013, Y. Nosochkov
%  * add BPMs, correctors to FODO BSY in HXR
%  * add place holder for pulse magnets to FODO BSY (per R. Iverson)
% 22-OCT-2013, Y. Nosochkov
%  * move TDUNDb 4.844538 m upstream
% 18-OCT-2013, Y. Nosochkov
%  * change quadrupole type of QBSY1, QBSY2 to 1.26Q12
% 17-OCT-2013, Y. Nosochkov
%  * change quadrupole type of QVB1B, QVB2B, QVB3B, QVM3B, QVM4B to 1.26Q12
%  * change bend type of BX31B, BX32B to 1.26D102.0T (per C. Spencer)
% 17-OCT-2013, M. Woodley
%  * from Yuri's LTU.xsif ... this file now defines MUWALL to SXXSTART, plus
%    the SXR dump line
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% SXR R56 compensating chicanes
% - use series approximation for sinc(x)=sin(x)/x to allow zero field
% ------------------------------------------------------------------------------
% Brhof  : beam rigidity at chicane (kG-m)
% GBCC   : gap height (m)
% ZBCC   : magnet Z-length along axis (m)
% ZDCC   : Z-space between magnets (m)
% BBX..  : chicane bend field (kG) at 4 GeV
% ABX..  : chicane bend angle (rad)
% LBX..  : chicane bend path length (m)
% ABX..S : "short" half chicane bend angle (rad)
% ABX..L : "long" half chicane bend angle (rad)
% LBX..S : "short" half chicane bend path length (m)
% LBX..L : "long" half chicane bend path length (m)
BBX31B =  5.0450 *EF/4.0 *1.15;
ARG31B =  ZBCC*BBX31B/BRHOF;
ABX31B =  asin(ARG31B);
ABX31B_2 =  ABX31B*ABX31B;
ABX31B_4 =  ABX31B_2*ABX31B_2;
ABX31B_6 =  ABX31B_4*ABX31B_2;
SINC31B =  1-ABX31B_2/6+ABX31B_4/120-ABX31B_6/5040;
LBX31B =  ZBCC/SINC31B;
ABX31BS =  asin(ARG31B/2);
ABX31BS_2 =  ABX31BS*ABX31BS;
ABX31BS_4 =  ABX31BS_2*ABX31BS_2;
ABX31BS_6 =  ABX31BS_4*ABX31BS_2;
SINC31BS =  1-ABX31BS_2/6+ABX31BS_4/120-ABX31BS_6/5040;
LBX31BS =  ZBCC/(2*SINC31BS);
ABX31BL =  ABX31B-ABX31BS;
LBX31BL =  LBX31B-LBX31BS;
BCX31B1A={'be' 'BCX31B1' LBX31BS [+ABX31BS GBCC/2 0 0 FBCC 0 0]}';
BCX31B1B={'be' 'BCX31B1' LBX31BL [+ABX31BL GBCC/2 0 +ABX31B 0 FBCC 0]}';
BCX31B2A={'be' 'BCX31B2' LBX31BL [-ABX31BL GBCC/2 -ABX31B 0 FBCC 0 0]}';
BCX31B2B={'be' 'BCX31B2' LBX31BS [-ABX31BS GBCC/2 0 0 0 FBCC 0]}';
BCX31B3A={'be' 'BCX31B3' LBX31BS [-ABX31BS GBCC/2 0 0 FBCC 0 0]}';
BCX31B3B={'be' 'BCX31B3' LBX31BL [-ABX31BL GBCC/2 0 -ABX31B 0 FBCC 0]}';
BCX31B4A={'be' 'BCX31B4' LBX31BL [+ABX31BL GBCC/2 +ABX31B 0 FBCC 0 0]}';
BCX31B4B={'be' 'BCX31B4' LBX31BS [+ABX31BS GBCC/2 0 0 0 FBCC 0]}';
DCC31BO={'dr' '' ZDCC/cos(ABX31B) []}';
DCC31BI={'dr' '' ZDCC []}';
CC31BBEG={'mo' 'CC31BBEG' 0 []}';
CC31BEND={'mo' 'CC31BEND' 0 []}';
CC31B=[CC31BBEG,BCX31B1A,BCX31B1B,DCC31BO,BCX31B2A,BCX31B2B,DCC31BI,BCX31B3A,BCX31B3B,DCC31BO,BCX31B4A,BCX31B4B,CC31BEND];
BBX32B =  5.0450 *EF/4.0 *1.15;
ARG32B =  ZBCC*BBX32B/BRHOF;
ABX32B =  asin(ARG32B);
ABX32B_2 =  ABX32B*ABX32B;
ABX32B_4 =  ABX32B_2*ABX32B_2;
ABX32B_6 =  ABX32B_4*ABX32B_2;
SINC32B =  1-ABX32B_2/6+ABX32B_4/120-ABX32B_6/5040;
LBX32B =  ZBCC/SINC32B;
ABX32BS =  asin(ARG32B/2);
ABX32BS_2 =  ABX32BS*ABX32BS;
ABX32BS_4 =  ABX32BS_2*ABX32BS_2;
ABX32BS_6 =  ABX32BS_4*ABX32BS_2;
SINC32BS =  1-ABX32BS_2/6+ABX32BS_4/120-ABX32BS_6/5040;
LBX32BS =  ZBCC/(2*SINC32BS);
ABX32BL =  ABX32B-ABX32BS;
LBX32BL =  LBX32B-LBX32BS;
BCX32B1A={'be' 'BCX32B1' LBX32BS [+ABX32BS GBCC/2 0 0 FBCC 0 0]}';
BCX32B1B={'be' 'BCX32B1' LBX32BL [+ABX32BL GBCC/2 0 +ABX32B 0 FBCC 0]}';
BCX32B2A={'be' 'BCX32B2' LBX32BL [-ABX32BL GBCC/2 -ABX32B 0 FBCC 0 0]}';
BCX32B2B={'be' 'BCX32B2' LBX32BS [-ABX32BS GBCC/2 0 0 0 FBCC 0]}';
BCX32B3A={'be' 'BCX32B3' LBX32BS [-ABX32BS GBCC/2 0 0 FBCC 0 0]}';
BCX32B3B={'be' 'BCX32B3' LBX32BL [-ABX32BL GBCC/2 0 -ABX32B 0 FBCC 0]}';
BCX32B4A={'be' 'BCX32B4' LBX32BL [+ABX32BL GBCC/2 +ABX32B 0 FBCC 0 0]}';
BCX32B4B={'be' 'BCX32B4' LBX32BS [+ABX32BS GBCC/2 0 0 0 FBCC 0]}';
DCC32BO={'dr' '' ZDCC/cos(ABX32B) []}';
DCC32BI={'dr' '' ZDCC []}';
CC32BBEG={'mo' 'CC32BBEG' 0 []}';
CC32BEND={'mo' 'CC32BEND' 0 []}';
CC32B=[CC32BBEG,BCX32B1A,BCX32B1B,DCC32BO,BCX32B2A,BCX32B2B,DCC32BI,BCX32B3A,BCX32B3B,DCC32BO,BCX32B4A,BCX32B4B,CC32BEND];
% ------------------------------------------------------------------------------
% wiggler for sync. light energy diagnostic (described in SLAC-PUB-3945)
% based on FACET optics model (M. Woodley)
% (series approximation for sinc(x)=sin(x)/x to enable setting with x=0)
% ------------------------------------------------------------------------------
GWIG =  0.02032       ;%gap height
ZWHP =  0.244         ;%half-pole Z length
ZDWG =  0.126525      ;%pole-to-pole Z spacing
ZWIG =  4*ZWHP+2*ZDWG ;%total wiggler Z length
BWGS =  1.E-12                  ;%wiggler bend field (kG)
AWGS =  asin(BWGS*ZWHP/(EF*CB)) ;%bend angle per half-pole
AWGS2 =  AWGS*AWGS;
AWGS4 =  AWGS2*AWGS2;
AWGS6 =  AWGS4*AWGS2;
SINCS =  1-AWGS2/6+AWGS4/120-AWGS6/5040;
LWGS =  ZWHP/SINCS              ;%half-pole path length
AWG1S =  asin(sin(AWGS)/2) ;%"short half" half-pole bend angle
AWG1S2 =  AWG1S*AWG1S;
AWG1S4 =  AWG1S2*AWG1S2;
AWG1S6 =  AWG1S4*AWG1S2;
SINC1S =  1-AWG1S2/6+AWG1S4/120-AWG1S6/5040;
LWG1S =  (ZWHP/2)/SINC1S   ;%"short half" half-pole path length
AWG2S =  AWGS-AWG1S        ;%"long half" half-pole bend angle
LWG2S =  LWGS-LWG1S        ;%"long half" half-pole path length
WIG1SA={'be' 'WIG1S' LWG1S [AWG1S GWIG/2 0 0 0.5 0 pi/2]}';
WIG1SB={'be' 'WIG1S' LWG2S [AWG2S GWIG/2 0 AWGS 0 0.5 pi/2]}';
WIG2SA={'be' 'WIG2S' LWGS [-AWGS GWIG/2 -AWGS 0 0.5 0 pi/2]}';
WIG2SB={'be' 'WIG2S' LWGS [-AWGS GWIG/2 0 -AWGS 0 0.5 pi/2]}';
WIG3SA={'be' 'WIG3S' LWG2S [AWG2S GWIG/2 AWGS 0 0.5 0 pi/2]}';
WIG3SB={'be' 'WIG3S' LWG1S [AWG1S GWIG/2 0 0 0 0.5 pi/2]}';
LDWGS =  ZDWG/cos(AWGS);
DWGS={'dr' '' LDWGS []}';
DWGSA={'dr' '' 0.090883 []}';
DWGSB={'dr' '' DWGS{3}-DWGSA{3} []}';
YCWIGS={'mo' 'YCWIGS' 0 []}';
BTM03B={'mo' 'BTM03B' 0 []}';
CNTWIGS={'mo' 'CNTWIGS' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
EWIGS=[WIG1SA,WIG1SB,DWGS,WIG2SA,YCWIGS,WIG2SB,DWGSA,BTM03B,DWGSB,WIG3SA,WIG3SB,CNTWIGS];
% ------------------------------------------------------------------------------
% SXR dogleg
% ------------------------------------------------------------------------------
% note: the K-values below are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQDBL1 =  -0.048421283879 ;%-0.048429590145
KQDBL2 =  -0.561694148767 ;%-0.561685997799
QDBL1={'qu' 'QDBL1' LQE/2 [KQDBL1 0]}';
QDBL2={'qu' 'QDBL2' LQE/2 [KQDBL2 0]}';
KQDLB =  0.424676241757;
KQDL11 =  KQDLB;
QDL11={'qu' 'QDL11' LQR/2 [KQDL11 0]}';%reserve separate PS
QDL12={'qu' 'QDL12' LQR/2 [-KQDLB 0]}';
QDL13={'qu' 'QDL13' LQR/2 [KQDLB 0]}';
QDL14={'qu' 'QDL14' LQR/2 [-KQDLB 0]}';
QDL15={'qu' 'QDL15' LQR/2 [KQDLB 0]}';
QDL16={'qu' 'QDL16' LQR/2 [-KQDLB 0]}';
QDL17={'qu' 'QDL17' LQR/2 [KQDLB 0]}';
QDL18={'qu' 'QDL18' LQR/2 [-KQDLB 0]}';
QDL19={'qu' 'QDL19' LQR/2 [KQDLB 0]}';
KQDL20 =  -0.488634879381;
KQDL21 =  -1.904099100556;
KQDL22 =   2.191884099551;
QDL20={'qu' 'QDL20' LQE/2 [KQDL20 0]}';
QDL21={'qu' 'QDL21' LQE/2 [KQDL21 0]}';
QDL22={'qu' 'QDL22' LQE/2 [KQDL22 0]}';
KSDL1 =   -8.734519131231;
KSDL2 =  -24.395452957412;
SDL1={'dr' 'SDL1' LSB/2 []}';
SDL2={'dr' 'SDL2' LSB/2 []}';
% 
% 
% 

LB3B =  2.656      ;%1.14D103.3T effective length (m)
GB3B =  0.0254     ;%1.14D103.3T gap height (m) ... should be 1.14*in2m
AB3PB =  0.018633330237;
AB3MB =  -AB3PB;
LEFFB3B =  LB3B*AB3PB/(2*sin(AB3PB/2)) ;%full bend eff. path length (m)
BX31BA={'be' 'BX31B' LEFFB3B/2 [AB3MB/2 GB3B/2 AB3MB/2 0 0.4297 0.0 0]}';
BX31BB={'be' 'BX31B' LEFFB3B/2 [AB3MB/2 GB3B/2 0 AB3MB/2 0.0 0.4297 0]}';
BX32BA={'be' 'BX32B' LEFFB3B/2 [AB3PB/2 GB3B/2 AB3PB/2 0 0.4297 0.0 0]}';
BX32BB={'be' 'BX32B' LEFFB3B/2 [AB3PB/2 GB3B/2 0 AB3PB/2 0.0 0.4297 0]}';
% SXR single beam dumper vertical kicker, BPM, spoiler and in-line dump
LKIKS =  1.0601 ;%kicker coil length per magnet (m) [41.737 in from SA-380-330-02, rev. 0]
ABYKIKS =  1E-20  ;%=0.889371410732E-3 when BYKIKS1,2 are turned on
BYKIK1SA={'be' 'BYKIK1S' LKIKS/2 [ABYKIKS/4 25.4E-3 ABYKIKS/4 0 0.5 0 pi/2]}';
BYKIK1SB={'be' 'BYKIK1S' LKIKS/2 [ABYKIKS/4 25.4E-3 0 ABYKIKS/4 0 0.5 pi/2]}';
BYKIK2SA={'be' 'BYKIK2S' LKIKS/2 [ABYKIKS/4 25.4E-3 ABYKIKS/4 0 0.5 0 pi/2]}';
BYKIK2SB={'be' 'BYKIK2S' LKIKS/2 [ABYKIKS/4 25.4E-3 0 ABYKIKS/4 0 0.5 pi/2]}';
BPMBYKS={'mo' 'BPMBYKS' 0 []}';
SPOILERS={'mo' 'SPOILERS' 0 []}';%TDKIKS dump spoiler (1 mm Ti)
TDKIKS={'mo' 'TDKIKS' 0.6096 []}';%vertical off-axis in-line dump
LDBLDL =  3.0 ;% length of LTU doublet including drifts
WALL={'dr' '' 16.764 []}';%length of muon wall
DWALLA={'dr' '' 1.840975 []}';%distance from face of muon wall to face of BSY dump
DWALLB={'dr' '' WALL{3}-DWALLA{3} []}';
DDBLDLB={'dr' '' 0.5+(LQA-LQE)/2 []}';
DDBLDLC={'dr' '' 0.4 []}';
DDBLDLD={'dr' '' (LQA-LQE)/2 []}';
DDBLDLA={'dr' '' 0.5*(LDBLDL-2*LQE-DDBLDLB{3}-2*DDBLDLC{3}-DDBLDLD{3}-LJAW) []}';
LDLCEL =  25.5;
LDL6B =  0.4;
LDL0A =  LDLCEL/2-LQA-LDL6B;
LDL0B =  LDLCEL/2-LQA-LDL6B+(LQA-LQR);
LDL0BA =  0.1953;
LDL0BB =  3.213005+(LQA-LQR)/2-LDL0BA;
LDL0BC =  LDL0B-LDL0BA-LDL0BB;
LDL1B =  2.9815+(LQA-LQR)/2;
LDL1BA =  1.317304;
LDL1BC =  0.1953;
LDL1BB =  LDL1B-LDL1BA-LDL1BC;
LDL2B =  LDL0B+LDL6B-LDL1B-LB3B+(LEFFB3B-LB3B)*3;
LDL2BA =  0.1953;
LDL2BB =  LDL2B-LDL2BA;
LDL4B =  1.996-LDL6B+(LQA-LQE);
LDL3B =  LDL0A-LQA-LDL4B-2*LDL6B+1.0+2*(LQA-LQE);
LDL5B =  0.498+(LQA-LQE)/2;
LDL7B =  0.93209;
LDL8B =  LDL0B-LDL7B-LJAW;
LDL8C =  1.0;
LDL8CA =  0.1953;
LDL8CB =  LDL8C-LDL8CA;
LDL8D =  LDL0B-LDL8C-ZWIG;
LDL9B =  LDL0B-LDL6B;
LDL9BA =  6.045762 ;%5.076366+(LQA-LQR)/2 +2.7012019
LDL9BB =  LDL9B-LDL9BA;
LDL10B =  1.230797;
LDL10BA =  0.81;
LDL10BB =  LDL10B-LDL10BA;
LDL11B =  LDL0B-LDL10B-LJAW;
LDL11BA =  0.162952;
LDL11BB =  LDL11B-LDL11BA;
LDL13B =  0.4;
LDL12B =  LDL0B-LDL13B-LDL7B-LJAW;
DLDL14B =  0.0;
LDL14B =  0.4815+(LQA-LQE)/2 +DLDL14B;
LDL16B =  0.5;
LDL15B =  LDL2B-LDL16B-2.0;
LDL15BA =  0.1953;
LDL15BB =  1.224657+(LQA-LQR)/2-LDL15BA;
LDL15BC =  LDL15B-LDL15BA-LDL15BB;
LDL17B =  0.5;
LDL18B =  LDL3B-LDL17B-2.0;
LDL18BA =  1.139421;
LDL18BB =  LDL18B-LDL18BA;
LDL19BA =  0.1953;
LDL19BB =  6.213736 ;%1.409836+0.51+0.08+(LQA-LQR)/2-LDL19ba
LDL19BC =  LDL0B-LDL19BA-LDL19BB;
LDL20B =  LDL0B+1.002-(LQA-LQR)/2;
DDL0B={'dr' '' LDL0B []}';
DDL0BA={'dr' '' LDL0BA []}';
DDL0BB={'dr' '' LDL0BB []}';
DDL0BC={'dr' '' LDL0BC []}';
DDL1B={'dr' '' LDL1B []}';
DDL1BA={'dr' '' LDL1BA []}';
DDL1BB={'dr' '' LDL1BB []}';
DDL1BC={'dr' '' LDL1BC []}';
DDL2B={'dr' '' LDL2B []}';
DDL2BA={'dr' '' LDL2BA []}';
DDL2BB={'dr' '' LDL2BB []}';
DDL4B={'dr' '' LDL4B []}';
DDL5B={'dr' '' LDL5B []}';
DDL6B={'dr' '' LDL6B []}';
DDL6BB={'dr' '' 0.1 []}';
DDL6BA={'dr' '' DDL6B{3}-DDL6BB{3}-LSB []}';
DDL7B={'dr' '' LDL7B []}';
DDL7BA={'dr' '' 0.51 []}';
DDL7BB={'dr' '' LDL7B-DDL7BA{3} []}';
DDL7BBA={'dr' '' 0.135832 []}';
DDL7BBB={'dr' '' DDL7BB{3}-DDL7BBA{3} []}';
DDL8B={'dr' '' LDL8B []}';
DDL8C={'dr' '' LDL8C []}';
DDL8CA={'dr' '' LDL8CA []}';
DDL8CB={'dr' '' LDL8CB []}';
DDL8D={'dr' '' LDL8D []}';
DDL9B={'dr' '' LDL9B []}';
DDL9BA={'dr' '' LDL9BA []}';
DDL9BB={'dr' '' LDL9BB []}';
DDL10B={'dr' '' LDL10B []}';
DDL10BA={'dr' '' LDL10BA []}';
DDL10BB={'dr' '' LDL10BB []}';
DDL11B={'dr' '' LDL11B []}';
DDL11BA={'dr' '' LDL11BA []}';
DDL11BB={'dr' '' LDL11BB []}';
DDL12B={'dr' '' LDL12B []}';
DDL13B={'dr' '' LDL13B []}';
DDL14B={'dr' '' LDL14B []}';
DDL15B={'dr' '' LDL15B []}';
DDL15BA={'dr' '' LDL15BA []}';
DDL15BB={'dr' '' LDL15BB []}';
DDL15BC={'dr' '' LDL15BC []}';
DDL16B={'dr' '' LDL16B []}';
DDL17B={'dr' '' LDL17B []}';
DDL18B={'dr' '' LDL18B []}';
DDL18BA={'dr' '' LDL18BA []}';
DDL18BB={'dr' '' LDL18BB []}';
DDL19BA={'dr' '' LDL19BA []}';
DDL19BB={'dr' '' LDL19BB []}';
DDL19BC={'dr' '' LDL19BC []}';
DDL20B={'dr' '' LDL20B []}';
% drifts for BYKIKS system
LDBYKS =  LDLCEL/2-LQR ;%DL cell drift length
DBYKS01={'dr' '' DDL10BA{3} []}';%QDL16 to CYDL16
DBYKS02={'dr' '' DDL10BB{3} []}';%CYDL16 to BPMDL16
DBYKS03={'dr' '' DDL11BA{3}+0.25 []}';%BPMDL16 to BTM04B
DBYKS05={'dr' '' 0.5893-LKIKS/2 []}';%(BYKIK1S to BYKIK2S)/2 (0.609226)
DBYKS06={'dr' '' 4.360149 []}';%BYKIK2S to XCDL17      (4.340223)
DBYKS07={'dr' '' 0.634128 []}';%XCDL17 to BPMDL17
DBYKS08={'dr' '' 0.415873 []}';%BPMDL17 to QDL17
DBYKS04={'dr' '' LDBYKS-DBYKS01{3}-LJAW-DBYKS02{3}-DBYKS03{3}-2*(LKIKS+DBYKS05{3})-DBYKS06{3}-DBYKS07{3}-DBYKS08{3} []}';%BTM04B to BYKIK1S
DBYKS11={'dr' '' 0.51 []}';%QDL17 to CEDL17
DBYKS12={'dr' '' 0.735832 []}';%CEDL17 to BTM05B
DBYKS13={'dr' '' 0.687668 []}';%BTM05B to SPOILERS
DBYKS14={'dr' '' 3.200208 []}';%SPOILERS to TDKIKS (3.220859)
DBYKS15={'dr' '' 0.257457 []}';%TDKIKS to PCTDKIKS1 (0.257426)
DBYKS16={'dr' '' 0.266697 []}';%PCTDKIKS to PCTDKIKS
DBYKS18={'dr' '' 0.4 []}';%OTRDL18 to YCDL18
DBYKS19={'dr' '' 0.4 []}';%YCDL18 to QDL18
DBYKS17={'dr' '' LDBYKS-DBYKS11{3}-LJAW-DBYKS12{3}-DBYKS13{3}-DBYKS14{3}-TDKIKS{3}-DBYKS15{3}-4*LPCTDKIK-3*DBYKS16{3}-DBYKS18{3}-DBYKS19{3} []}';%PCTDKIK4S to OTRDL18
BPMDBL1={'mo' 'BPMDBL1' 0 []}';
BPMDBL2={'mo' 'BPMDBL2' 0 []}';
BPMDL11={'mo' 'BPMDL11' 0 []}';
BPMDL12={'mo' 'BPMDL12' 0 []}';
BPMDL13={'mo' 'BPMDL13' 0 []}';
BPMDL14={'mo' 'BPMDL14' 0 []}';
BPMDL15={'mo' 'BPMDL15' 0 []}';
BPMDL16={'mo' 'BPMDL16' 0 []}';
BPMDL17={'mo' 'BPMDL17' 0 []}';
BPMDL18={'mo' 'BPMDL18' 0 []}';
BPMDL19={'mo' 'BPMDL19' 0 []}';
BPMDL20={'mo' 'BPMDL20' 0 []}';
BPMDL21={'mo' 'BPMDL21' 0 []}';
BPMDL22={'mo' 'BPMDL22' 0 []}';
XCDBL2={'mo' 'XCDBL2' 0 []}';
XCDL11={'mo' 'XCDL11' 0 []}';
XCDL13={'mo' 'XCDL13' 0 []}';
XCDL15={'mo' 'XCDL15' 0 []}';
XCDL17={'mo' 'XCDL17' 0 []}';
XCDL19={'mo' 'XCDL19' 0 []}';
XCDL22={'mo' 'XCDL22' 0 []}';
YCDBL1={'mo' 'YCDBL1' 0 []}';
YCDL12={'mo' 'YCDL12' 0 []}';
YCDL14={'mo' 'YCDL14' 0 []}';
YCDL16={'mo' 'YCDL16' 0 []}';
YCDL18={'mo' 'YCDL18' 0 []}';
YCDL20={'mo' 'YCDL20' 0 []}';
YCDL21={'mo' 'YCDL21' 0 []}';
CEDL13={'dr' 'CEDL13' LJAW []}';
CEDL17={'dr' 'CEDL17' LJAW []}';
CYBDL={'dr' 'CYBDL' LJAW []}';
CYDL16={'dr' 'CYDL16' LJAW []}';
% muon collimators after SBD TDKIKS in-line dump
PCTDKIK1S={'dr' 'PCTDKIK1S' LPCTDKIK []}';
PCTDKIK2S={'dr' 'PCTDKIK2S' LPCTDKIK []}';
PCTDKIK3S={'dr' 'PCTDKIK3S' LPCTDKIK []}';
PCTDKIK4S={'dr' 'PCTDKIK4S' LPCTDKIK []}';
OTRDL18={'mo' 'OTRDL18' 0 []}';
BTM01B={'mo' 'BTM01B' 0 []}';
BTM02B={'mo' 'BTM02B' 0 []}';
BTM04B={'mo' 'BTM04B' 0 []}';
BTM05B={'mo' 'BTM05B' 0 []}';
BTM06B={'mo' 'BTM06B' 0 []}';
BTM07B={'mo' 'BTM07B' 0 []}';
DBMARK34B={'mo' 'DBMARK34B' 0 []}';%entrance of BX31
CNTLT1S={'mo' 'CNTLT1S' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
DBLDL21=[BEGLTUS,DDBLDLB,QDBL1,BPMDBL1,QDBL1,DDBLDLC,YCDBL1,DDBLDLA,CYBDL,DDBLDLA,XCDBL2,DDBLDLC,QDBL2,BPMDBL2,QDBL2,DDBLDLD];
DL2SC=[DBMARK34B          ,DDL20B ,XCDL11 ,DDL6B  ,QDL11 ,QDL11       ,DDL15BA,BPMDL11,DDL15BB,DDL15BC,CC31B  ,DDL16B ,BX31BA,BX31BB      ,DDL1BA ,BTM01B ,DDL1BB ,BPMDL12,DDL1BC ,QDL12 ,QDL12       ,DDL6B  ,YCDL12 ,DDL9BA ,BTM02B ,DDL9BB ,XCDL13 ,DDL6BA ,SDL1  ,SDL1        ,DDL6BB ,QDL13 ,QDL13       ,DDL7BA ,CEDL13 ,DDL7BB ,BPMDL13,DDL8B  ,YCDL14 ,DDL6B  ,QDL14 ,QDL14       ,DDL8CA ,BPMDL14,DDL8CB ,EWIGS  ,DDL8D  ,XCDL15 ,DDL6BA ,SDL2  ,SDL2        ,DDL6BB ,QDL15 ,QDL15       ,DDL0BA ,BPMDL15,DDL0BB ,DDL0BC ,YCDL16 ,DDL6B  ,QDL16 ,QDL16       ,DBYKS01,CYDL16,DBYKS02,BPMDL16,DBYKS03,BTM04B,DBYKS04,BYKIK1SA,BYKIK1SB,DBYKS05,DBYKS05,BYKIK2SA,BYKIK2SB,DBYKS06,XCDL17,DBYKS07,BPMDL17,DBYKS08,QDL17 ,QDL17       ,DBYKS11,CEDL17,DBYKS12,BTM05B,DBYKS13,SPOILERS,DBYKS14,TDKIKS,DBYKS15,PCTDKIK1S,DBYKS16,PCTDKIK2S,DBYKS16,PCTDKIK3S,DBYKS16,PCTDKIK4S,DBYKS17,OTRDL18,DBYKS18,YCDL18,DBYKS19,QDL18 ,QDL18       ,DDL19BA,BPMDL18,DDL19BB,BTM06B ,DDL19BC,XCDL19 ,DDL6B  ,QDL19 ,QDL19       ,DDL2BA ,BPMDL19,DDL2BB ,BX32BA,BX32BB              ,CNTLT1S,DDL14B ,QDL20,BPMDL20,QDL20,DDL6B  ,YCDL20 ,DDL17B ,CC32B  ,DDL18BA,BTM07B ,DDL18BB,YCDL21 ,DDL6B  ,QDL21,BPMDL21,QDL21,DDL4B  ,XCDL22 ,DDL6B  ,QDL22,BPMDL22,QDL22,DDL5B  ];
% %test line to find ABYKIKS angle for -14.2 mm offset at front face of TDKIKS
% 
% KYKIK1S={'mo' 'KYKIK1S' LKIKS/2 []}';
% KYKIK2S={'mo' 'KYKIK2S' LKIKS/2 []}';
% TESTBYKIKS=[KYKIK1S,KYKIK1S,DBYKS05,DBYKS05,KYKIK2S,KYKIK2S,DBYKS06,XCDL17,DBYKS07,BPMDL17,DBYKS08,QDL17,QDL17,DBYKS11,CEDL17,DBYKS12,BTM05B,DBYKS13,SPOILERS,DBYKS14];
% 
% 
% 
% 
% %LMDIF, TOL=1.E-20
% %MIGRAD, TOL=1.E-20
% 
% 
% 
% 
% 

% ------------------------------------------------------------------------------
% SXR VBEND
% ------------------------------------------------------------------------------
KQVBB =  -2.509359002417;
KQVM3B =   0.947818535712;
KQVM4B =  -1.161589322114;
QVB1B={'qu' 'QVB1B' LQE/2 [KQVBB 0]}';
QVB2B={'qu' 'QVB2B' LQE/2 [-KQVBB 0]}';
QVB3B={'qu' 'QVB3B' LQE/2 [KQVBB 0]}';
QVM3B={'qu' 'QVM3B' LQA/2 [KQVM3B 0]}';
QVM4B={'qu' 'QVM4B' LQA/2 [KQVM4B 0]}';
S100_PITCH =  -4.760000E-3;
S100_HEIGHT =  77.643680;
Z_S100_UNDH =  583.000000;
R_EARTH =  6.372508025E6;
LVB =  1.025      ;%3D39 vertical bend effective length (m)
GVB =  0.034925   ;%gap width (m)
AVB =  (S100_PITCH+asin(Z_S100_UNDH/(R_EARTH+S100_HEIGHT)))/2 ;%bend up twice this angle so e- is level in cnt. of und.
BY1BA={'be' 'BY1B' LVB/2 [AVB/2 GVB/2 AVB/2 0 0.5 0 pi/2]}';
BY1BB={'be' 'BY1B' LVB/2 [AVB/2 GVB/2 0 AVB/2 0 0.5 pi/2]}';
BY2BA={'be' 'BY2B' LVB/2 [AVB/2 GVB/2 AVB/2 0 0.5 0 pi/2]}';
BY2BB={'be' 'BY2B' LVB/2 [AVB/2 GVB/2 0 AVB/2 0 0.5 pi/2]}';
DDVB =  4.114978912453 ;%adjust Y in undulator
DVB1B={'dr' '' 7.44546-DDVB*0.5+(LQA-LQE)/2 []}';
DVB2B={'dr' '' 4.14092-DDVB*0.5+(LQA-LQE) []}';
DVB2M80CMB={'dr' '' 3.34092-DDVB*0.5+(LQA-LQE) []}';
DVB1M40CMB={'dr' '' 7.04546-DDVB*0.5+(LQA-LQE)/2 []}';
DVB1M40CMBA={'dr' '' 3.189788 []}';
DVB1M40CMBB={'dr' '' DVB1M40CMB{3}-DVB1M40CMBA{3} []}';
D40CMC={'dr' '' 0.40 []}';
DYCVM1={'dr' '' 0.40 []}';
DQVM1={'dr' '' 0.34 []}';
DQVM2={'dr' '' 0.5 []}';
DQVM2BA={'dr' '' 0.483901 []}';
DQVM2BB={'dr' '' DQVM2{3}-DQVM2BA{3} []}';
DRQVM1={'dr' '' LQF/2 []}';
DRQVM2={'dr' '' LQF/2 []}';
DXCVM2={'dr' '' 0.25 []}';
DVB25CM={'dr' '' 0.25 []}';
DVB25CMCB={'dr' '' 1.32046 []}';
D25CM={'dr' '' 0.25 []}';
DVBEM25CMB={'dr' '' 1.39092 []}';
DVBEM15CMB={'dr' '' 0.243073 []}';
D10CMB={'dr' '' 0.1064869 []}';
D25CMA={'dr' '' 0.2209001 []}';
BPMVB1B={'mo' 'BPMVB1B' 0 []}';
BPMVB2B={'mo' 'BPMVB2B' 0 []}';
BPMVB3B={'mo' 'BPMVB3B' 0 []}';
BPMVM3B={'mo' 'BPMVM3B' 0 []}';
BPMVM4B={'mo' 'BPMVM4B' 0 []}';
XCVB2B={'mo' 'XCVB2B' 0 []}';
XCVM3B={'mo' 'XCVM3B' 0 []}';
YCVB1B={'mo' 'YCVB1B' 0 []}';
YCVB3B={'mo' 'YCVB3B' 0 []}';
YCVM4B={'mo' 'YCVM4B' 0 []}';
BTM08B={'mo' 'BTM08B' 0 []}';
BTM09B={'mo' 'BTM09B' 0 []}';
VBINB={'mo' 'VBINB' 0 []}';%start of vert. bend system
VBOUTB={'mo' 'VBOUTB' 0 []}';%end of vert. bend system
CNTLT2S={'mo' 'CNTLT2S' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
VBENDB=[VBINB,BY1BA,BY1BB,DVB1B,QVB1B,BPMVB1B,QVB1B,D40CMC,YCVB1B,DVB2M80CMB,XCVB2B,D40CMC,QVB2B,BPMVB2B,QVB2B,DVB2B,QVB3B,BPMVB3B,QVB3B,D40CMC,YCVB3B,DVB1M40CMBA,BTM09B,DVB1M40CMBB,BY2BA,BY2BB,CNTLT2S,VBOUTB];
VBSYSB=[DYCVM1,DQVM1,DRQVM1,DRQVM1,DQVM2BA,BTM08B,DQVM2BB,DRQVM2,DRQVM2,DXCVM2,DVB25CM,VBENDB,DVB25CMCB,XCVM3B,D25CM,QVM3B,BPMVM3B,QVM3B,DVBEM25CMB,YCVM4B,D25CM,QVM4B,BPMVM4B,QVM4B,DVBEM15CMB,D10CMB,D25CMA];
% ------------------------------------------------------------------------------
% SXR emittance diagnostic
% ------------------------------------------------------------------------------
KQEM1B =   1.999441277361 ;% 2.000222254932
KQEM2B =  -1.810331661376 ;%-1.809296889507
KQEM3B =   1.272436815231 ;% 1.273739135291
KQEM4B =  -0.893098062371 ;%-0.895317266409
QEM1B={'qu' 'QEM1B' LQE/2 [KQEM1B 0]}';
QEM2B={'qu' 'QEM2B' LQE/2 [KQEM2B 0]}';
QEM3B={'qu' 'QEM3B' LQE/2 [KQEM3B 0]}';
QEM4B={'qu' 'QEM4B' LQE/2 [KQEM4B 0]}';
QEM3VB={'qu' 'QEM3VB' LQX/2 [0 0]}';
KQED2B =  0.402753197988 ;%ED2 FODO quad strength
KQE31B =  +KQED2B;
KQE32B =  -KQED2B;
KQE33B =  +KQED2B;
KQE34B =  -KQED2B;
KQE35B =  +KQED2B;
KQE36B =  -KQED2B;
QE31B={'qu' 'QE31B' LQX/2 [KQE31B 0]}';
QE32B={'qu' 'QE32B' LQX/2 [KQE32B 0]}';
QE33B={'qu' 'QE33B' LQX/2 [KQE33B 0]}';
QE34B={'qu' 'QE34B' LQX/2 [KQE34B 0]}';
QE35B={'qu' 'QE35B' LQX/2 [KQE35B 0]}';
QE36B={'qu' 'QE36B' LQX/2 [KQE36B 0]}';
DZ_ADJUST =  47.825;
DDMM =  0.161670898486E-2 ;%adjust Z in undulator
DRFB={'dr' '' 0.2 []}';%separation between (warm) quadrupole and RF BPM
D25CMB={'dr' '' 0.2627 []}';
D25CMC={'dr' '' 0.2373 []}';
DMM1M90CMB={'dr' '' DDVB*2-0.79954+DDMM+(LQA-LQE)/2 []}';
DMM1M90CMBA={'dr' '' 3.548482 []}';
DMM1M90CMBB={'dr' '' DMM1M90CMB{3}-DMM1M90CMBA{3} []}';
DEM1A={'dr' '' 0.37 []}';
DEM1B={'dr' '' 4.14092 []}';
DEM1BAB={'dr' '' 1.086830+(LQA-LQE)/2 []}';
DEM1BBB={'dr' '' DEM1B{3}-DEM1BAB{3}+(LQA-LQE) []}';
DEM2B={'dr' '' 0.50 []}';
DMM3M80CM={'dr' '' 11.27092 []}';
DMM3M80CMX={'dr' '' DMM3M80CM{3}+(LQA-LQE) []}';
DMM3MAB={'dr' '' 4.425910+(LQA-LQE)/2 []}';
DMM3MBB={'dr' '' DMM3M80CM{3}-DMM3MAB{3}+(LQA-LQE) []}';
DEM3A={'dr' '' 0.37 []}';
DEM3B={'dr' '' 0.773299 []}';
DEM3BB={'dr' '' DEM3B{3}+(LQA-LQE)/2 []}';
DMM4M90CM={'dr' '' 2.759621 []}';
DMM4M90CMB={'dr' '' DMM4M90CM{3}+(LQA-LQE)/2 []}';
DMM4M90CMBA={'dr' '' 0.223554 []}';
DMM4M90CMBB={'dr' '' DMM4M90CMB{3}-DMM4M90CMBA{3} []}';
DEM4A={'dr' '' 0.50 []}';
DMM5={'dr' '' 2.07046-DRFB{3} []}';
DMM5AB={'dr' '' 0.90407+(LQA-LQE)/2 []}';
DMM5BB={'dr' '' DMM5{3}-DMM5AB{3}+(LQA-LQE)/2 []}';
D40CM={'dr' '' 0.40 []}';
D40CMW={'dr' '' 0.3915855 []}';
DE3M80CMA={'dr' '' 4.6-0.4-0.4+DZ_ADJUST/12+0.15046 []}';
DE3MAB={'dr' '' 5.333610 []}';
DE3MBB={'dr' '' DE3M80CMA{3}-DE3MAB{3} []}';
DQEA={'dr' '' 0.40+(LQF-LQX)/2-0.15046 []}';
DQEBX={'dr' '' 0.32+(LQF-LQX)/2+0.33655-0.0768665+0.04 []}';
DQEBX2={'dr' '' 4.6-0.4-0.4+DZ_ADJUST/12-0.33655+0.0768665-0.04 []}';
DE3A={'dr' '' 4.6+DZ_ADJUST/12+0.14046 []}';
DE3ABA={'dr' '' 1.341982 []}';
DE3ABB={'dr' '' DE3A{3}-DE3ABA{3} []}';
DQEAA={'dr' '' 0.40+(LQF-LQX)/2-0.14046 []}';
DQEBY={'dr' '' 0.32+(LQF-LQX)/2+0.33655-0.0768665+0.04 []}';
DQEBY1={'dr' '' DQEBY{3}-DRFB{3} []}';
DQEBY2={'dr' '' 4.6-0.4+DZ_ADJUST/12-0.33655+0.0768665-0.04 []}';
DE3M80CMB={'dr' '' 4.6-0.4-0.4+DZ_ADJUST/12+0.12046 []}';
DQEAB={'dr' '' 0.40+(LQF-LQX)/2-0.12046 []}';
DQEC={'dr' '' 4.6+DZ_ADJUST/12+(LQF-LQX)/2 []}';
DQECBA={'dr' '' 1.440646 []}';
DQECBB={'dr' '' DQEC{3}-DQECBA{3} []}';
DQEC1={'dr' '' DQEC{3}-DRFB{3} []}';
DE3M40CM={'dr' '' 4.6-0.4+DZ_ADJUST/12+0.15046 []}';
DE3M80CM={'dr' '' 4.6-0.4-0.4+DZ_ADJUST/12-0.02954 []}';
DE3M80CMBA={'dr' '' 2.647321 []}';
DE3M80CMBB={'dr' '' DE3M80CM{3}-DE3M80CMBA{3} []}';
DQEAC={'dr' '' 0.40+(LQF-LQX)/2+0.02954 []}';
DE3={'dr' '' 4.6+DZ_ADJUST/12+0.15046 []}';
BPMEM1B={'mo' 'BPMEM1B' 0 []}';
BPMEM2B={'mo' 'BPMEM2B' 0 []}';
BPMEM3B={'mo' 'BPMEM3B' 0 []}';
BPMEM4B={'mo' 'BPMEM4B' 0 []}';
RFBEM4B={'mo' 'RFBEM4B' 0 []}';
BPME31B={'mo' 'BPME31B' 0 []}';
BPME32B={'mo' 'BPME32B' 0 []}';%type to be checked
RFBE32B={'mo' 'RFBE32B' 0 []}';
BPME33B={'mo' 'BPME33B' 0 []}';
BPME34B={'mo' 'BPME34B' 0 []}';%type to be checked
RFBE34B={'mo' 'RFBE34B' 0 []}';
BPME35B={'mo' 'BPME35B' 0 []}';
BPME36B={'mo' 'BPME36B' 0 []}';%type to be checked
RFBE36B={'mo' 'RFBE36B' 0 []}';
XCEM1B={'mo' 'XCEM1B' 0 []}';
XCEM3B={'mo' 'XCEM3B' 0 []}';
XCE31B={'mo' 'XCE31B' 0 []}';
XCE33B={'mo' 'XCE33B' 0 []}';
XCE35B={'mo' 'XCE35B' 0 []}';
YCEM2B={'mo' 'YCEM2B' 0 []}';
YCEM4B={'mo' 'YCEM4B' 0 []}';
YCE32B={'mo' 'YCE32B' 0 []}';
YCE34B={'mo' 'YCE34B' 0 []}';
YCE36B={'mo' 'YCE36B' 0 []}';
WS31B={'mo' 'WS31B' 0 []}';%LTU emittance
WS32B={'mo' 'WS32B' 0 []}';%LTU emittance
WS33B={'mo' 'WS33B' 0 []}';%LTU emittance
WS34B={'mo' 'WS34B' 0 []}';%LTU emittance
BTM10B={'mo' 'BTM10B' 0 []}';
BTM11B={'mo' 'BTM11B' 0 []}';
BTM12B={'mo' 'BTM12B' 0 []}';
BTM13B={'mo' 'BTM13B' 0 []}';
BTM14B={'mo' 'BTM14B' 0 []}';
DCX31B={'dr' '' 0.08 []}';
DCY32B={'dr' '' 0.08 []}';
DCX35B={'dr' '' 0.08 []}';
DCY36B={'dr' '' 0.08 []}';
DBMARK36B={'mo' 'DBMARK36B' 0 []}';%center of WS31B
% ==============================================================================
% XLEAP-II devices
% ==============================================================================
% ------------------------------------------------------------------------------
% recycled XLEAP type-4 correctors
% ------------------------------------------------------------------------------
YCXL1={'mo' 'YCXL1' 0 []}';
XCXL1={'mo' 'XCXL1' 0 []}';
YCXL2={'mo' 'YCXL2' 0 []}';
XCXL2={'mo' 'XCXL2' 0 []}';
% ------------------------------------------------------------------------------
% recycled LCLS undulators
% ------------------------------------------------------------------------------
% definition of Eu is in LCLS2sc_master.xsif and LCLS2cu_master.xsif
GAMXL =  EU/MC2       ;%Lorentz energy factor [ ]
KUND =  50           ;%undulator parameter (rms) [ ]
LAMU =  0.40         ;%undulator period [m]
LSEG =  3.400        ;%undulator segment length [m]
LUE =  0.035        ;%undulator termination length (approx) [m]
LUND =  LSEG - 2*LUE ;%undulator segment length without terminations [m]
LUNDH =  LUND/2       ;%undulator segment half-length [m]
% natural undulator focusing "k" in y-plane [m^-2]
KQUND =  SETXLEAP2*(KUND*2*PI/LAMU/sqrt(2)/GAMXL)^2;
% handle K_und->0 (undulator moved out of beam) by expressing R34 as an
% approximate SINC function
ARGU =  LUNDH*sqrt(KQUND);
ARGU2 =  ARGU*ARGU;
ARGU4 =  ARGU2*ARGU2;
ARGU6 =  ARGU4*ARGU2;
SINCARGU =  1-ARGU2/6+ARGU4/120-ARGU6/5040 ;%~sinc(ARGu)=sin(ARGu)/ARGu
R34U =  LUNDH*SINCARGU;
% undulator segment modeled as R-matrix to include vertical natural focusing
% over all but its edge terminations:
UMXLH={'un' 'UMXLH' LUNDH [KQUND LAMU 1]}';
UMXL1H=UMXLH;UMXL1H{2}='UMXL1H';
UMXL2H=UMXLH;UMXL2H{2}='UMXL2H';
UMXL3H=UMXLH;UMXL3H{2}='UMXL3H';
UMXL4H=UMXLH;UMXL4H{2}='UMXL4H';
SHRT =  0.470                                 ;%standard short break length [m]
LRFBU =  0                                     ;%undulator RF-BPM only implemented as zero length monitor
LBR1 =  6.889E-2                              ;%und-seg to quad [m]
LBR3 =  9.111E-2                              ;%quad to BPM [m]
LBR4 =  5.8577E-2                             ;%radiation monitor to segment [m]
LBRWM =  7.1683E-2                             ;%BFW to radiation monitor [m]
LBRS =  SHRT-LRFBU-0.078-LBR1-LBR3-LBR4-LBRWM ;%standard short break length (BPM-to-quad distance) [m]
DLBFW =  3.6016-3.63815 ;%BFW location adjustment per H. Loos
DBRS={'dr' '' LBRS-DLBFW []}';%standard short undulator drift from BPM to segment
DBWM={'dr' '' LBRWM+DLBFW []}';%BFW to radiation monitor drift
DB4={'dr' '' LBR4 []}';%radiation monitor to segment drift
DT={'dr' '' LUE []}';%undulator segment small terminations modeled as drift
DUU={'dr' '' 0.238/2 []}';%undulator pair half-drift
RFBXL1={'mo' 'RFBXL1' LRFBU []}';%undulator BPM
RFBXL2={'mo' 'RFBXL2' LRFBU []}';%undulator BPM
RFBXL3={'mo' 'RFBXL3' LRFBU []}';%undulator BPM
RFBXL4={'mo' 'RFBXL4' LRFBU []}';%undulator BPM
% flip RF BPMs
DRFBF =  0.61*IN2M;
DUUF={'dr' '' DUU{3}+DRFBF []}';
DBRSF={'dr' '' DBRS{3}-DRFBF []}';
XL2UND1=[RFBXL1,DBRSF,DBWM,DB4,DT,UMXL1H,UMXL1H,DT];
XL2UND2=[RFBXL2,DBRSF,DBWM,DB4,DT,UMXL2H,UMXL2H,DT];
XL2UND3=[RFBXL3,DBRSF,DBWM,DB4,DT,UMXL3H,UMXL3H,DT];
XL2UND4=[RFBXL4,DBRSF,DBWM,DB4,DT,UMXL4H,UMXL4H,DT];
LXL2UND =  2*(RFBXL1{3}+DBRS{3}+DBWM{3}+DB4{3}+DT{3}+UMXL1H{3}+ UMXL1H{3}+DT{3})+2*DUU{3};
% drifts around undulator pair
LXL3132 =  DQEBX{3}+DCX31B{3}+DQEBX2{3}+DE3ABA{3};
DXLUA={'dr' '' (LXL3132-LXL2UND)/2 []}';
DXLUB={'dr' '' LXL3132-LXL2UND-DXLUA{3} []}';
%VALUE, DXLUa[L],DXLUb[L]
DXLUA1={'dr' '' 0.404978 []}';
DXLUA2={'dr' '' 0.395986 []}';
DXLUA3={'dr' '' DXLUA{3}-DXLUA1{3}-DXLUA2{3} []}';
DXLUA3F={'dr' '' DXLUA3{3}+DRFBF []}';%flip RF BPM
% ------------------------------------------------------------------------------
% original XLEAP self-seeding chicane (normally OFF)
% ------------------------------------------------------------------------------
% - from RadiaBeam (C-bends; 0.75 T peak field; 1 degree max)
% - use series approximation for sinc(x)=sin(x)/x to allow ABXL=0
% - deflects toward -X (to the right/south/aisle)
% GBXL  : 1D19.7 gap height (m)
% ZBXL  : 1D19.7 "Z" length (m)
% FBXL  : measured fringe field
% ABXL  : chicane bend angle (rad)
% BBXL  : chicane bend field (kG)
% LBXL  : chicane bend path length (m)
% ABXLs : "short" half chicane bend angle (rad)
% LBXLs : "short" half chicane bend path length (m)
% ABXLl : "long" half chicane bend angle (rad)
% LBXLl : "long" half chicane bend path length (m)
% BCXXL1 gets an X-offset of  -5 mm (toward the aisle)
% BCXXL2 gets an X-offset of -12 mm (toward the aisle)
% BCXXL3 gets an X-offset of -12 mm (toward the aisle)
% BCXXL4 gets an X-offset of  -5 mm (toward the aisle)
GBXL =  0.008;
ZBXL =  0.364;
FBXL =  0.5;
ABXL0 =  0.0174 ;%R56=0.56 mm
ABXL =  ABXL0*SETXLEAP2;
BBXL =  BRHOF*sin(ABXL)/ZBXL;
ABXL_2 =  ABXL*ABXL;
ABXL_4 =  ABXL_2*ABXL_2;
ABXL_6 =  ABXL_4*ABXL_2;
SINCABXL =  1-ABXL_2/6+ABXL_4/120-ABXL_6/5040 ;%~sinc(ABXL)=sin(ABXL)/ABXL
LBXL =  ZBXL/SINCABXL;
ABXLS =  asin(sin(ABXL)/2);
ABXLS_2 =  ABXLS*ABXLS;
ABXLS_4 =  ABXLS_2*ABXLS_2;
ABXLS_6 =  ABXLS_4*ABXLS_2;
SINCABXLS =  1-ABXLS_2/6+ABXLS_4/120-ABXLS_6/5040 ;%~sinc(ABXLs)=sin(ABXLs)/ABXLs
LBXLS =  ZBXL/(2*SINCABXLS);
ABXLL =  ABXL-ABXLS;
LBXLL =  LBXL-LBXLS;
BCXXL1A={'be' 'BCXXL1' LBXLS [+ABXLS GBXL/2 0 0 FBXL 0 0]}';
BCXXL1B={'be' 'BCXXL1' LBXLL [+ABXLL GBXL/2 0 +ABXL 0 FBXL 0]}';
BCXXL2A={'be' 'BCXXL2' LBXLL [-ABXLL GBXL/2 -ABXL 0 FBXL 0 0]}';
BCXXL2B={'be' 'BCXXL2' LBXLS [-ABXLS GBXL/2 0 0 0 FBXL 0]}';
BCXXL3A={'be' 'BCXXL3' LBXLS [-ABXLS GBXL/2 0 0 FBXL 0 0]}';
BCXXL3B={'be' 'BCXXL3' LBXLL [-ABXLL GBXL/2 0 -ABXL 0 FBXL 0]}';
BCXXL4A={'be' 'BCXXL4' LBXLL [+ABXLL GBXL/2 +ABXL 0 FBXL 0 0]}';
BCXXL4B={'be' 'BCXXL4' LBXLS [+ABXLS GBXL/2 0 0 0 FBXL 0]}';
% magnet-to-magnet path lengths
ZDXLO =  1.046-ZBXL ;%outer bend-to-bend Z distance (m)
ZDXLI =  0.520-ZBXL ;%inner bend-to-bend Z distance (m)
DXLO={'dr' '' ZDXLO/cos(ABXL) []}';
DXLI={'dr' '' ZDXLI/2 []}';
LBCXL =  4*ZBXL+2*ZDXLO+ZDXLI ;%chicane length
% MARKers
BCXLSSBEG={'mo' 'BCXLSSBEG' 0 []}';
BCXLSSMID={'mo' 'BCXLSSMID' 0 []}';
BCXLSSEND={'mo' 'BCXLSSEND' 0 []}';
% beamline
BCXLSS=[BCXLSSBEG, BCXXL1A,BCXXL1B,DXLO,BCXXL2A,BCXXL2B,DXLI,BCXLSSMID,DXLI,BCXXL3A,BCXXL3B,DXLO,BCXXL4A,BCXXL4B,BCXLSSEND];
% drifts around chicane and undulator pair
LXL3536 =  DQEBX{3}+DCX35B{3}+DQEBX2{3}+DE3{3};
DXLUC={'dr' '' 3.5 []}';
DXLUD={'dr' '' 1.0 []}';
DXLUE={'dr' '' LXL3536-DXLUC{3}-LBCXL-DXLUD{3}-LXL2UND []}';
%VALUE, DXLUc[L],DXLUd[L],DXLUe[L]
DXLUD1={'dr' '' 0.323714 []}';
DXLUD2={'dr' '' 0.393700 []}';
DXLUD3={'dr' '' DXLUD{3}-DXLUD1{3}-DXLUD2{3} []}';
DXLUD3F={'dr' '' DXLUD3{3}+DRFBF []}';%flip RF BPM
% ------------------------------------------------------------------------------
% original XLEAP wiggler
% ------------------------------------------------------------------------------
% wiggler is modeled as R-matrix to include natural vertical focusing;
% it is nominally OFF (opened to full gap, with Kwig~2); at minimum gap, Kwig=50
KWIG =  34                                        ;%wiggler parameter [m^-1]
LAMW =  0.34                                      ;%wiggler period [m]
LWIGH =  2.38/2                                    ;%wiggler half-length [m]
GAMW =  EU/MC2                                    ;%Lorentz energy factor in wiggler [ ]
KQWIG =  SETXLEAP2*(2*PI*KWIG/LAMW/sqrt(2)/GAMW)^2 ;%natural vertical focusing "k" [m^-2]
% handle Kwig->0 by expressing R34 as an approximate SINC function
ARGW =  LWIGH*sqrt(KQWIG);
ARGW2 =  ARGW*ARGW;
ARGW4 =  ARGW2*ARGW2;
ARGW6 =  ARGW4*ARGW2;
SINCARGW =  1-ARGW2/6+ARGW4/120-ARGW6/5040 ;%~sinc(ARGw)=sin(ARGw)/ARGw
R34W =  LWIGH*SINCARGW;
WIGXLH={'un' 'WIGXLH' LWIGH [KQWIG LAMW 1]}';
%VALUE, WIGXLh[RM(1,1)],WIGXLh[RM(1,2)],WIGXLh[RM(2,1)],WIGXLh[RM(2,2)]
%VALUE, WIGXLh[RM(3,3)],WIGXLh[RM(3,4)],WIGXLh[RM(4,3)],WIGXLh[RM(4,4)]
% ------------------------------------------------------------------------------
% SXR emittance diagnostic beamline
% ------------------------------------------------------------------------------
EDMCHB=[D25CMB,D25CMC,DMM1M90CMBA,BTM10B,DMM1M90CMBB,XCEM1B,DEM1A,QEM1B,BPMEM1B,QEM1B,DEM1BAB,DEM1BBB,QEM2B,BPMEM2B,QEM2B,DEM2B,YCEM2B,DMM3M80CMX,XCEM3B,DEM3A,QEM3B,BPMEM3B,QEM3B,DEM3BB,QEM3VB,QEM3VB,DMM4M90CMBA,BTM11B,DMM4M90CMBB,YCEM4B,DEM4A,QEM4B,BPMEM4B,QEM4B,DRFB,RFBEM4B,DMM5AB,DMM5BB];
%XLEAP2a : LINE=(DQEBx,DCX31B,DQEBx2,DE3aBa)
XLEAP2A=[DXLUA1,YCXL1,DXLUA2,XCXL1,DXLUA3F,XL2UND1,DUU,DUUF,XL2UND2,DXLUB];
%XLEAP2b : LINE=(DQEBx,DCX35B,DQEBx2,DE3)
XLEAP2B=[DXLUC,BCXLSS,DXLUD1,YCXL2,DXLUD2,XCXL2,DXLUD3F,XL2UND3,DUU,DUUF,XL2UND4,DXLUE];
EDSYSB=[DBMARK36B,WS31B,D40CM,DE3MAB,DE3MBB,XCE31B,DQEA,QE31B,BPME31B,QE31B,XLEAP2A,BTM12B,DE3ABB,YCE32B,DQEAA,QE32B,BPME32B,QE32B,DRFB,RFBE32B,DQEBY1,DCY32B,DQEBY2,WS32B,D40CM,DE3M80CMB,XCE33B,DQEAB, QE33B,BPME33B,QE33B,DQECBA,BTM13B,DQECBB,DE3M40CM,YCE34B,DQEA,QE34B,BPME34B,QE34B,DRFB,RFBE34B,DQEC1,WS33B,D40CM,DE3M80CMBA,BTM14B,DE3M80CMBB,XCE35B,DQEAC,QE35B,BPME35B,QE35B,XLEAP2B,YCE36B,DQEA,QE36B,BPME36B,QE36B,DRFB,RFBE36B,DQEBY1,DCY36B,DQEBY2,WS34B,D40CM];
ECELLB=[QE31B,DQEC,DQEC,QE32B,QE32B,DQEC,DQEC,QE31B];
% ------------------------------------------------------------------------------
% SXR undulator match
% ------------------------------------------------------------------------------
% note: the below K-values are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQUM1B =   0.348825519173 ;% 0.347147476566
KQUM2B =  -0.13           ;%-0.13
KQUM3B =   0.383666483043 ;% 0.385625357669
KQUM4B =  -0.629809901233 ;%-0.628348037766
QUM1B={'qu' 'QUM1B' LQE/2 [KQUM1B 0]}';
QUM2B={'qu' 'QUM2B' LQE/2 [KQUM2B 0]}';
QUM3B={'qu' 'QUM3B' LQE/2 [KQUM3B 0]}';
QUM4B={'qu' 'QUM4B' LQE/2 [KQUM4B 0]}';
DU1M80CM={'dr' '' 4.550 []}';
DU1M80CMBA={'dr' '' 0.384174 []}';
DU1M80CMBB={'dr' '' DU1M80CM{3}-DU1M80CMBA{3} []}';
DCX37={'dr' '' 0.08 []}';
DCY38={'dr' '' 0.08 []}';
D32CMCB={'dr' '' 1.30046+(LQA-LQE)/2+0.5 []}';
DUM1A={'dr' '' 0.49 []}';
DUM1B={'dr' '' 0.47046 []}';
D32CM={'dr' '' 0.32 []}';
DU2M120CMB={'dr' '' 3.730+(LQA-LQE)-0.5 []}';
D32CMA={'dr' '' 0.42046 []}';
DUM2A={'dr' '' 0.37 []}';
DUM2B={'dr' '' 0.47046 []}';
DU3M80CM={'dr' '' 7.29046 []}';
DU3M80CMB={'dr' '' DU3M80CM{3}+(LQA-LQE) []}';
DUM3A={'dr' '' 0.38 []}';
DUM3B={'dr' '' 0.47046 []}';
D40CMA={'dr' '' 1.807939 []}';
DU4M120CM={'dr' '' 1.362521 []}';
DU4M120CMB={'dr' '' DU4M120CM{3}+(LQA-LQE) []}';
DUM4A={'dr' '' 0.50 []}';
DUM4B={'dr' '' 0.59746 []}';
DU5M80CM={'dr' '' 0.5 []}';
DU5M80CMB={'dr' '' DU5M80CM{3}+(LQA-LQE)/2 []}';
DUHWALL1={'dr' '' 0.250825 []}';%length of BTH/UH wall-1
DUHVEST={'dr' '' 2.009175 []}';%length of BTH/UH vestibule
DUHVESTA={'dr' '' 1.605684 []}';
DUHVESTB={'dr' '' DUHVEST{3}-DUHVESTA{3} []}';
DUHWALL2={'dr' '' 0.250825 []}';%length of BTH/UH wall-2
DW2TDUNDB={'dr' '' 3.001537 []}';%drift from BTH/UH wall-2 to TDUNDB u/s flange
DTDUND1={'dr' '' 0.855853 []}';%from u/s TDUND flange to TDUND center
DTDUND2={'dr' '' 0.347853 []}';%from TDUND center to d/s TDUND flange
DPCMUON={'dr' '' 0.031498 []}';
DMUON1={'dr' '' 0.154859+0.05 []}';
DMUON3B={'dr' '' 0.310592-0.05 []}';
DW2TDB1={'dr' '' 61.51*IN2M-WIGXLH{3} []}';
DW2TDB2={'dr' '' DW2TDUNDB{3}-DW2TDB1{3}-2*WIGXLH{3} []}';
%VALUE, DW2TDb1[L],DW2TDb2[L]
%VALUE, DW2TDb1[L]+2*WIGXLh[L]+DW2TDb2[L],DW2TDUNDb[L]
BPMUM1B={'mo' 'BPMUM1B' 0 []}';
BPMUM2B={'mo' 'BPMUM2B' 0 []}';
BPMUM3B={'mo' 'BPMUM3B' 0 []}';
BPMUM4B={'mo' 'BPMUM4B' 0 []}';
XCUM1B={'mo' 'XCUM1B' 0 []}';%fast-feedback (loop-5)
XCUM3B={'mo' 'XCUM3B' 0 []}';%fast-feedback (loop-5)
YCUM2B={'mo' 'YCUM2B' 0 []}';%fast-feedback (loop-5)
YCUM4B={'mo' 'YCUM4B' 0 []}';%fast-feedback (loop-5)
BTM15B={'mo' 'BTM15B' 0 []}';
TDUNDB={'mo' 'TDUNDB' 0 []}';%LTU insertable block at und. extension entrance (w/ screen)
% Note: PCMUONb Y-aperture violates standard BSC -- approved by P. Emma
PCMUONB={'dr' 'PCMUONB' 1.1684 []}';%muon scattering collimator
VV999B={'mo' 'VV999B' 0 []}';%vacuum valve just upbeam of undulator - TBD
PFILT1B={'mo' 'PFILT1B' 0 []}';
MM1B={'mo' 'MM1B' 0 []}';
MM2B={'mo' 'MM2B' 0 []}';
MM3B={'mo' 'MM3B' 0 []}';
MUWALLB={'mo' 'MUWALLB' 0 []}';%front face of muon wall for SXR beam
DUMPBSYS={'mo' 'DUMPBSYS' 0 []}';%front face of BSY dump for SXR beam
BSYENDB={'mo' 'BSYENDB' 0 []}';%FFTB side of muon plug wall
RWWAKE3S={'mo' 'RWWAKE3S' 0 []}';%SPRDS/BSY beampipe wake applied here
MUHWALL1B={'mo' 'MUHWALL1B' 0 []}';%upstream end of BTH/UH wall-1
MUHWALL2B={'mo' 'MUHWALL2B' 0 []}';%upstream end of BTH/UH wall-2
DBMARK37B={'mo' 'DBMARK37B' 0 []}';%end of undulator match
RWWAKE4S={'mo' 'RWWAKE4S' 0 []}';%LTUS beampipe wake applied here
%LW2TDb : LINE=(DW2TDUNDb)
LW2TDB=[DW2TDB1,WIGXLH,WIGXLH,DW2TDB2];
UNMCHB=[DU1M80CMBA,BTM15B,DU1M80CMBB,DCX37,D32CMCB,DUM1A,QUM1B,BPMUM1B,QUM1B,DUM1B,XCUM1B,D32CM,DU2M120CMB,DCY38,D32CMA,YCUM2B,DUM2A,QUM2B,BPMUM2B,QUM2B,DUM2B,DU3M80CMB,XCUM3B,DUM3A,QUM3B,BPMUM3B,QUM3B,DUM3B,D40CMA,DU4M120CMB,YCUM4B,DUM4A,QUM4B,BPMUM4B,QUM4B,DUM4B,DU5M80CMB,D40CMW,MUHWALL1B,DUHWALL1,DUHVEST,MUHWALL2B,DUHWALL2,LW2TDB,DTDUND1,TDUNDB,DTDUND2,DPCMUON,PCMUONB,DMUON1,VV999B,DMUON3B,MM3B,PFILT1B,DBMARK37B];
LTUSC=[MM1B,DL2SC,VBSYSB,MM2B,EDMCHB,EDSYSB,UNMCHB];
BSYLTUSC=[MUWALLB,DWALLA,DUMPBSYS,DWALLB,BSYENDB,ENDSPS,DBLDL21,LTUSC];
% ------------------------------------------------------------------------------
% SXR dumpline
% ------------------------------------------------------------------------------
KQDMPB =  -0.15522011426 ;%-0.154946553294
QDMP1B={'qu' 'QDMP1B' LQP/2 [KQDMPB 0]}';
QDMP2B={'qu' 'QDMP2B' LQP/2 [KQDMPB 0]}';
LBYDS =  0.5   ;%effective straight length of dump soft bend 1.26D18.43
GBYDS =  0.032 ;%full gap of dump soft bend
ABYDS =  6.E-4;
LEFFBYDS =  LBYDS*ABYDS/(2*sin(ABYDS/2)) ;%bend path length (m)
BYDSSA={'be' 'BYDSS' LEFFBYDS/2 [ABYDS/2 GBYDS/2 ABYDS/2 0 0.5 0.0 pi/2]}';
BYDSSB={'be' 'BYDSS' LEFFBYDS/2 [ABYDS/2 GBYDS/2 0 ABYDS/2 0.0 0.5 pi/2]}';
LBDM =  1.452  ;%effective straight bend length of main dump bends - from J. Tanabe (m)
GBDM =  0.043  ;%full gap (m) of main dump bends (SA-380-328-03 shows magnet half-gap = 0.866")
FBDM =  0.5513 ;%measured FINT
ABDM =  0.02240073511             ;%angle per main dump bend (rad)
LEFFBDM =  LBDM*ABDM/(2*sin(ABDM/2)) ;%bend path length (m)
BYD1BA={'be' 'BYD1B' LEFFBDM/2 [ABDM/2 GBDM/2 ABDM/2 0 FBDM 0.00 pi/2]}';
BYD1BB={'be' 'BYD1B' LEFFBDM/2 [ABDM/2 GBDM/2 0 ABDM/2 0.00 FBDM pi/2]}';
BYD2BA={'be' 'BYD2B' LEFFBDM/2 [ABDM/2 GBDM/2 ABDM/2 0 FBDM 0.00 pi/2]}';
BYD2BB={'be' 'BYD2B' LEFFBDM/2 [ABDM/2 GBDM/2 0 ABDM/2 0.00 FBDM pi/2]}';
BYD3BA={'be' 'BYD3B' LEFFBDM/2 [ABDM/2 GBDM/2 ABDM/2 0 FBDM 0.00 pi/2]}';
BYD3BB={'be' 'BYD3B' LEFFBDM/2 [ABDM/2 GBDM/2 0 ABDM/2 0.00 FBDM pi/2]}';
PCPM1LB={'dr' 'PCPM1LB' LPCPM []}';
PCPM2LB={'dr' 'PCPM2LB' LPCPM []}';
LDS1 =   0.3158763;
LDS =   0.247946;
LDMP1 =  11.516159251113 ;%BYD3/BYD3B to QDmp1/QDmp1B
DDMPV =  -0.73352263654;
DDWSDUMP =   0.248126313572 ;%set Z at DUMPFACEB
DS1={'dr' '' LDS1 []}';
DS={'dr' '' LDS []}';
DD1BA={'dr' '' 0.577681352129 []}';
DD1BB={'dr' '' 1.000087502327 []}';
DD1BC={'dr' '' 0.3048 []}';
DD1BE={'dr' '' 0.24963810293 []}';
DD1BF={'dr' '' 0.409240108574 []}';
DD1BD={'dr' '' LDMP1-(DD1BA{3}+PCPM1LB{3}+DD1BB{3}+DD1BC{3}+DD1BE{3}+PCPM2LB{3}+DD1BF{3}) []}';
DD12A={'dr' '' 0.25-0.0079372+0.06 []}';
DD12B={'dr' '' 0.0079372 []}';
DD12C={'dr' '' 0.25+0.06 []}';
DD2A={'dr' '' 0.4+0.0634916+0.0115084 []}';
DD2C={'dr' '' 1.0 []}';
DD2B={'dr' '' 8.1507760-LQD/2+DDMPV-DD2C{3}+0.06 []}';
DD3A={'dr' '' 0.3+0.049684+0.001583 []}';
DD3B={'dr' '' 0.3-0.001583-0.1447026 []}';
DWSDUMPA={'dr' '' 0.44156/2 []}';
DWSDUMPB={'dr' '' 0.44156-DWSDUMPA{3} []}';
DWSDUMPC={'dr' '' 2.038949+DDWSDUMP []}';
DDUMP={'dr' '' 61.120*IN2M []}';%length of EBD dump (per A. Ibrahimov)
BPMQDB={'mo' 'BPMQDB' 0 []}';%RFBQDB : MONI, TYPE="@2,CavityL-1"
BPMDDB={'mo' 'BPMDDB' 0 []}';
RFBDDB={'mo' 'RFBDDB' 0 []}';
XCDDB={'mo' 'XCDDB' 0 []}';
YCDDB={'mo' 'YCDDB' 0 []}';
OTRDMPB={'mo' 'OTRDMPB' 0 []}';%Dump screen
WSDUMPB={'mo' 'WSDUMPB' 0 []}';
MIMBCS4B={'mo' 'MIMBCS4B' 0 []}';
BTM1LB={'mo' 'BTM1LB' 0 []}';%Burn-Through-Monitor behind PCPM1LB
BTM2LB={'mo' 'BTM2LB' 0 []}';%Burn-Through-Monitor behind PCPM2LB
DUMPFACEB={'mo' 'DUMPFACEB' 0 []}';%entrance face of main e- dump
BTMDUMPB={'mo' 'BTMDUMPB' 0 []}';%Burn-Through-Monitor of main e- dump
MQDMPB={'mo' 'MQDMPB' 0 []}';
DMPENDB={'mo' 'DMPENDB' 0 []}';
DBMARK38B={'mo' 'DBMARK38B' 0 []}';%end of final undulator dump
ARODMP1S =  -0.174519678252;
ARODMP2S =   0.174913455104;
RODMP1S={'ro' 'RODMP1S' 0 [-(ARODMP1S)]}';
RODMP2S={'ro' 'RODMP2S' 0 [-(ARODMP2S)]}';
DUMPLINEB=[BEGDMPS_2,RODMP1S,BYDSSA,BYDSSB,DS1,BYD1BA,BYD1BB,DS,BYD2BA,BYD2BB,DS,BYD3BA,BYD3BB,DD1BA,PCPM1LB,BTM1LB,DD1BB,DD1BC,MIMBCS4B,DD1BD,YCDDB,DD1BE,PCPM2LB,BTM2LB,DD1BF,QDMP1B,QDMP1B,DD12A,BPMQDB,DD12B,MQDMPB,DD12C,QDMP2B,QDMP2B,DD2A,XCDDB,DD2B,DD2C,DD3A,BPMDDB,DD3B,OTRDMPB,DWSDUMPA,RFBDDB,DWSDUMPB,WSDUMPB,DWSDUMPC,RODMP2S,DUMPFACEB,DDUMP,DMPENDB,BTMDUMPB,DBMARK38B,ENDDMPS_2];
% ==============================================================================
% HXR LTU and dump
% ==============================================================================
% ------------------------------------------------------------------------------
% HXR R56 compensating chicanes
% - use series approximation for sinc(x)=sin(x)/x to allow zero field
% ------------------------------------------------------------------------------
% Brhof  : beam rigidity at chicane (kG-m)
% GBCC   : gap height (m)
% ZBCC   : magnet Z-length along axis (m)
% ZDCC   : Z-space between magnets (m)
% BBX..  : chicane bend field (kG) at 4 GeV
% ABX..  : chicane bend angle (rad)
% LBX..  : chicane bend path length (m)
% ABX..S : "short" half chicane bend angle (rad)
% ABX..L : "long" half chicane bend angle (rad)
% LBX..S : "short" half chicane bend path length (m)
% LBX..L : "long" half chicane bend path length (m)
BBX31 =  0.0 *EF/4.0;
ARG31 =  ZBCC*BBX31/BRHOF;
ABX31 =  asin(ARG31);
ABX31_2 =  ABX31*ABX31;
ABX31_4 =  ABX31_2*ABX31_2;
ABX31_6 =  ABX31_4*ABX31_2;
SINC31 =  1.0-ABX31_2/6+ABX31_4/120-ABX31_6/5040;
LBX31 =  ZBCC/SINC31;
ABX31S =  asin(ARG31/2);
ABX31S_2 =  ABX31S*ABX31S;
ABX31S_4 =  ABX31S_2*ABX31S_2;
ABX31S_6 =  ABX31S_4*ABX31S_2;
SINC31S =  1.0-ABX31S_2/6+ABX31S_4/120-ABX31S_6/5040;
LBX31S =  ZBCC/(2*SINC31S);
ABX31L =  ABX31-ABX31S;
LBX31L =  LBX31-LBX31S;
BCX311A={'be' 'BCX311' LBX31S [+ABX31S GBCC/2 0 0 FBCC 0 0]}';
BCX311B={'be' 'BCX311' LBX31L [+ABX31L GBCC/2 0 +ABX31 0 FBCC 0]}';
BCX312A={'be' 'BCX312' LBX31L [-ABX31L GBCC/2 -ABX31 0 FBCC 0 0]}';
BCX312B={'be' 'BCX312' LBX31S [-ABX31S GBCC/2 0 0 0 FBCC 0]}';
BCX313A={'be' 'BCX313' LBX31S [-ABX31S GBCC/2 0 0 FBCC 0 0]}';
BCX313B={'be' 'BCX313' LBX31L [-ABX31L GBCC/2 0 -ABX31 0 FBCC 0]}';
BCX314A={'be' 'BCX314' LBX31L [+ABX31L GBCC/2 +ABX31 0 FBCC 0 0]}';
BCX314B={'be' 'BCX314' LBX31S [+ABX31S GBCC/2 0 0 0 FBCC 0]}';
DCC31O={'dr' '' ZDCC/cos(ABX31) []}';
DCC31I={'dr' '' ZDCC []}';
CC31BEG={'mo' 'CC31BEG' 0 []}';
CC31END={'mo' 'CC31END' 0 []}';
CC31=[CC31BEG,BCX311A,BCX311B,DCC31O,BCX312A,BCX312B,DCC31I,BCX313A,BCX313B,DCC31O,BCX314A,BCX314B,CC31END];
BBX32 =  2.3628*sqrt(2.0) *EF/4.0 *1.15;
ARG32 =  ZBCC*BBX32/BRHOF;
ABX32 =  asin(ARG32);
ABX32_2 =  ABX32*ABX32;
ABX32_4 =  ABX32_2*ABX32_2;
ABX32_6 =  ABX32_4*ABX32_2;
SINC32 =  1-ABX32_2/6+ABX32_4/120-ABX32_6/5040;
LBX32 =  ZBCC/SINC32;
ABX32S =  asin(ARG32/2);
ABX32S_2 =  ABX32S*ABX32S;
ABX32S_4 =  ABX32S_2*ABX32S_2;
ABX32S_6 =  ABX32S_4*ABX32S_2;
SINC32S =  1-ABX32S_2/6+ABX32S_4/120-ABX32S_6/5040;
LBX32S =  ZBCC/(2*SINC32S);
ABX32L =  ABX32-ABX32S;
LBX32L =  LBX32-LBX32S;
BCX321A={'be' 'BCX321' LBX32S [+ABX32S GBCC/2 0 0 FBCC 0 0]}';
BCX321B={'be' 'BCX321' LBX32L [+ABX32L GBCC/2 0 +ABX32 0 FBCC 0]}';
BCX322A={'be' 'BCX322' LBX32L [-ABX32L GBCC/2 -ABX32 0 FBCC 0 0]}';
BCX322B={'be' 'BCX322' LBX32S [-ABX32S GBCC/2 0 0 0 FBCC 0]}';
BCX323A={'be' 'BCX323' LBX32S [-ABX32S GBCC/2 0 0 FBCC 0 0]}';
BCX323B={'be' 'BCX323' LBX32L [-ABX32L GBCC/2 0 -ABX32 0 FBCC 0]}';
BCX324A={'be' 'BCX324' LBX32L [+ABX32L GBCC/2 +ABX32 0 FBCC 0 0]}';
BCX324B={'be' 'BCX324' LBX32S [+ABX32S GBCC/2 0 0 0 FBCC 0]}';
DCC32O={'dr' '' ZDCC/cos(ABX32) []}';
DCC32I={'dr' '' ZDCC []}';
CC32BEG={'mo' 'CC32BEG' 0 []}';
CC32END={'mo' 'CC32END' 0 []}';
CC32=[CC32BEG,BCX321A,BCX321B,DCC32O,BCX322A,BCX322B,DCC32I,BCX323A,BCX323B,DCC32O,BCX324A,BCX324B,CC32END];
BBX35 =  2.3628 *EF/4.0 *1.15;
ARG35 =  ZBCC*BBX35/BRHOF;
ABX35 =  asin(ARG35);
ABX35_2 =  ABX35*ABX35;
ABX35_4 =  ABX35_2*ABX35_2;
ABX35_6 =  ABX35_4*ABX35_2;
SINC35 =  1-ABX35_2/6+ABX35_4/120-ABX35_6/5040;
LBX35 =  ZBCC/SINC35;
ABX35S =  asin(ARG35/2);
ABX35S_2 =  ABX35S*ABX35S;
ABX35S_4 =  ABX35S_2*ABX35S_2;
ABX35S_6 =  ABX35S_4*ABX35S_2;
SINC35S =  1-ABX35S_2/6+ABX35S_4/120-ABX35S_6/5040;
LBX35S =  ZBCC/(2*SINC35S);
ABX35L =  ABX35-ABX35S;
LBX35L =  LBX35-LBX35S;
BCX351A={'be' 'BCX351' LBX35S [+ABX35S GBCC/2 0 0 FBCC 0 0]}';
BCX351B={'be' 'BCX351' LBX35L [+ABX35L GBCC/2 0 +ABX35 0 FBCC 0]}';
BCX352A={'be' 'BCX352' LBX35L [-ABX35L GBCC/2 -ABX35 0 FBCC 0 0]}';
BCX352B={'be' 'BCX352' LBX35S [-ABX35S GBCC/2 0 0 0 FBCC 0]}';
BCX353A={'be' 'BCX353' LBX35S [-ABX35S GBCC/2 0 0 FBCC 0 0]}';
BCX353B={'be' 'BCX353' LBX35L [-ABX35L GBCC/2 0 -ABX35 0 FBCC 0]}';
BCX354A={'be' 'BCX354' LBX35L [+ABX35L GBCC/2 +ABX35 0 FBCC 0 0]}';
BCX354B={'be' 'BCX354' LBX35S [+ABX35S GBCC/2 0 0 0 FBCC 0]}';
DCC35O={'dr' '' ZDCC/cos(ABX35) []}';
DCC35I={'dr' '' ZDCC []}';
CC35BEG={'mo' 'CC35BEG' 0 []}';
CC35END={'mo' 'CC35END' 0 []}';
CC35=[CC35BEG,BCX351A,BCX351B,DCC35O,BCX352A,BCX352B,DCC35I,BCX353A,BCX353B,DCC35O,BCX354A,BCX354B,CC35END];
BBX36 =  2.3628 *EF/4.0 *1.15;
ARG36 =  ZBCC*BBX36/BRHOF;
ABX36 =  asin(ARG36);
ABX36_2 =  ABX36*ABX36;
ABX36_4 =  ABX36_2*ABX36_2;
ABX36_6 =  ABX36_4*ABX36_2;
SINC36 =  1-ABX36_2/6+ABX36_4/120-ABX36_6/5040;
LBX36 =  ZBCC/SINC36;
ABX36S =  asin(ARG36/2);
ABX36S_2 =  ABX36S*ABX36S;
ABX36S_4 =  ABX36S_2*ABX36S_2;
ABX36S_6 =  ABX36S_4*ABX36S_2;
SINC36S =  1-ABX36S_2/6+ABX36S_4/120-ABX36S_6/5040;
LBX36S =  ZBCC/(2*SINC36S);
ABX36L =  ABX36-ABX36S;
LBX36L =  LBX36-LBX36S;
BCX361A={'be' 'BCX361' LBX36S [+ABX36S GBCC/2 0 0 FBCC 0 0]}';
BCX361B={'be' 'BCX361' LBX36L [+ABX36L GBCC/2 0 +ABX36 0 FBCC 0]}';
BCX362A={'be' 'BCX362' LBX36L [-ABX36L GBCC/2 -ABX36 0 FBCC 0 0]}';
BCX362B={'be' 'BCX362' LBX36S [-ABX36S GBCC/2 0 0 0 FBCC 0]}';
BCX363A={'be' 'BCX363' LBX36S [-ABX36S GBCC/2 0 0 FBCC 0 0]}';
BCX363B={'be' 'BCX363' LBX36L [-ABX36L GBCC/2 0 -ABX36 0 FBCC 0]}';
BCX364A={'be' 'BCX364' LBX36L [+ABX36L GBCC/2 +ABX36 0 FBCC 0 0]}';
BCX364B={'be' 'BCX364' LBX36S [+ABX36S GBCC/2 0 0 0 FBCC 0]}';
DCC36O={'dr' '' ZDCC/cos(ABX36) []}';
DCC36I={'dr' '' ZDCC []}';
CC36BEG={'mo' 'CC36BEG' 0 []}';
CC36END={'mo' 'CC36END' 0 []}';
CC36=[CC36BEG,BCX361A,BCX361B,DCC36O,BCX362A,BCX362B,DCC36I,BCX363A,BCX363B,DCC36O,BCX364A,BCX364B,CC36END];
% ------------------------------------------------------------------------------
% HXR BSY downstream of the merge bend
% ------------------------------------------------------------------------------
% note: the K-values below are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQ50Q3 =   0.434154040462 ;
KQ4 =  -0.217498744833 ;
KQ5 =   0.110634649191 ;
KQ6 =  -0.107282100403 ;
KQA0 =   0.096403505318 ;
Q50Q3={'qu' 'Q50Q3' 0.143254 [KQ50Q3 0]}';
Q4={'qu' 'Q4' LQF/2 [KQ4 0]}';
Q5={'qu' 'Q5' LQF/2 [KQ5 0]}';
Q6={'qu' 'Q6' LQF/2 [KQ6 0]}';
QA0={'qu' 'QA0' LQF/2 [KQA0 0]}';
CXQ6={'dr' 'CXQ6' LJAW []}';
PCBSY3={'dr' 'PCBSY3' LPCSP []}';%BCS protection collimator
PCBSY4={'dr' 'PCBSY4' LPCSP []}';%BCS protection collimator
PCBSY5={'dr' 'PCBSY5' LPCSP []}';%BCS protection collimator
LPC90 =  0.453644;
LPC119 =  0.453644;
PC90={'dr' 'PC90' LPC90 []}';%existing BCS protection collimator in BSY
PC119={'dr' 'PC119' LPC119 []}';%existing BCS protection collimator in BSY
% 2" ID BSY collimator -- part of 2-hole copper collimator d/s of A-line pulsed magnets
PCBSYH={'dr' 'PCBSYH' 0.45 []}';
DM3={'dr' '' 0.1524+0.349426-0.282226 []}';
DM4A={'dr' '' 0.8816-0.6096+0.282226-0.342826 []}';
DM4C={'dr' '' 0.331133-LJAW/2 []}';
DM4D={'dr' '' 1.168867-LJAW/2 []}';
DM4DA={'dr' '' 0.2832 []}';
DM4DB={'dr' '' DM4D{3}-DM4DA{3}-LPCSP []}';
DM4B={'dr' '' 8.622041-DM4A{3}-DM4C{3}-DM4D{3}-LJAW-2.0+0.282226 []}';
DXCA0={'dr' '' 0.31 []}';
DYCA0={'dr' '' 0.356220-0.076799 []}';
DM5={'dr' '' 0.561379 []}';
DM6={'dr' '' 0.567588 []}';
DMONI={'dr' '' 0.009525 []}';
ZQ5 =  0.0 ;%adjust position of Q5
ZQ6 =  0.0 ;%adjust position of Q6
DBSY52D={'dr' '' 0.5 []}';
DBSY53A={'dr' '' 0.091696 []}';
DBSY53B={'dr' '' 0.760705-0.15 []}';
DBSY53C={'dr' '' 0.629945+0.15 []}';
DBSY53F={'dr' '' 0.5 []}';
DBSY53D={'dr' '' 4.0-DBSY53A{3}-DBSY53B{3}-DBSY53C{3}-DBSY53F{3} []}';
DBSY53G={'dr' '' 1.2 []}';
DBSY53GA={'dr' '' 0.91928 []}';
DBSY53GB={'dr' '' DBSY53G{3}-DBSY53GA{3}-LPCSP []}';
DBSY53H={'dr' '' 34.45562-DBSY53G{3}-ZBKRAPM1-ZBKRAPM2-ZBKRAPM3-ZBKRAPM4-2*LDZAPM1-2*LDZAPM2-2*LDZAPM3-LDZAPM4-LDZA01-LDZA02-PCBSYH{3}-LPCAPM1-LPCAPM2-LPCAPM3-LPCAPM4+ZQ5 []}';
DBSY54A={'dr' '' 0.5 []}';
DBSY54B={'dr' '' 3.22454-ZQ5 []}';
DBSY54C={'dr' '' 19.260056-DBSY54A{3}-DBSY54B{3}-ZQ5+ZQ6 []}';
DBSY55A={'dr' '' 0.5 []}';
DBSY55B={'dr' '' 4.226742 []}';
DBSY55C={'dr' '' 8.022378-ZQ6 []}';
DBSY55D={'dr' '' 6.473178 []}';
DBSY55E={'dr' '' 21.432164-DRFB{3}-DBSY55A{3}-DBSY55B{3}-LPC90-DBSY55C{3}-LPCSP-DBSY55D{3}-LPC119-ZQ6 []}';
BPMBSYQ3={'mo' 'BPMBSYQ3' 0 []}';%per C. Iverson
RFBBSYQ3={'mo' 'RFBBSYQ3' 0 []}';
BPMBSYQ4={'mo' 'BPMBSYQ4' 0 []}';
BPMBSYQ5={'mo' 'BPMBSYQ5' 0 []}';%per C. Iverson
BPMBSYQ6={'mo' 'BPMBSYQ6' 0 []}';%per C. Iverson
RFBBSYQ6={'mo' 'RFBBSYQ6' 0 []}';
BPMBSYQA0={'mo' 'BPMBSYQA0' 0 []}';%per C. Iverson
XCBSYQ3={'mo' 'XCBSYQ3' 0 []}';%barcode=4602
XCBSYQ5={'mo' 'XCBSYQ5' 0 []}';%barcode=2100
XCA0={'mo' 'XCA0' 0 []}';%barcode=2195
YCBSYQ4={'mo' 'YCBSYQ4' 0 []}';%barcode=4603
YCBSYQ6={'mo' 'YCBSYQ6' 0 []}';%barcode=2107
YCA0={'mo' 'YCA0' 0 []}';%barcode=2195
D2={'mo' 'D2' 1.2192 []}';%PPS stopper
ST60={'mo' 'ST60' 1.2192 []}';%backup PPS stopper
DM60={'mo' 'DM60' 0 []}';%"disaster" BTM behind ST60
ST61={'mo' 'ST61' 1.2192 []}';%backup PPS stopper
BSYEND={'mo' 'BSYEND' 0 []}';%FFTB side of muon plug wall: Z=3224.022426 (Z'=176.020508 m, X'=0.0 m, Y'=-0.821761 m)
DUMPBSYH={'mo' 'DUMPBSYH' 0 []}';%front face of BSY dump for HXR beam
MUWALL={'mo' 'MUWALL' 0 []}';%front face of muon wall for HXR beam
MRGALINE={'mo' 'MRGALINE' 0 []}';%merge point with A-line
RWWAKE3H={'mo' 'RWWAKE3H' 0 []}';%BSY/SPRDH beampipe wake applied here
SPHAL=[DBSY52D,Q50Q3,Q50Q3,DBSY53A,BPMBSYQ3,RFBBSYQ3,DBSY53B,DBSY53C,XCBSYQ3,DBSY53D,YCBSYQ4,DBSY53F,Q4,BPMBSYQ4,Q4,DBSY53GA,PCBSY3,DBSY53GB,MRGALINE];
SPHBSYA=[SPHAL,ALINEA];
SPHBSYB=[PCBSYH,DBSY53H,Q5,BPMBSYQ5,Q5,DBSY54A,XCBSYQ5,DBSY54B,DBSY54C,Q6,BPMBSYQ6,Q6,DRFB,RFBBSYQ6,DBSY55A,YCBSYQ6,DBSY55B,PC90,DBSY55C,PCBSY4,DBSY55D,PC119,DBSY55E,D2,DM3,ST60,DM4A,DM60,DM4B,CC31,DM4C,CXQ6,DM4DA,PCBSY5,DM4DB,XCA0,DXCA0,YCA0,DYCA0,ST61,DM5,QA0,BPMBSYQA0,QA0,DM6,DMONI,DMONI,MUWALL,DWALLA,DUMPBSYH,DWALLB,BSYEND,RWWAKE3H];
SPHBSY=[SPHBSYA,SPHBSYB,ENDSPH];
% ------------------------------------------------------------------------------
% BSY1 upstream of the HXR merge bend
% ------------------------------------------------------------------------------
KQ30801 =   0.480537684959;
KQ50Q1 =  -0.231937689242;
KQ50Q2 =   0.102502945834;
Q50Q1={'qu' 'Q50Q1' LQR/2 [KQ50Q1 0]}';
Q50Q2={'qu' 'Q50Q2' 0.162151 [KQ50Q2 0]}';
LDBSY01 =  5.995 ;%from beginning of BSY to Station 100
DBSY01A={'dr' '' 0.7286 []}';
DBSY01B={'dr' '' 0.25005 []}';
DBSY01C={'dr' '' 0.25005 []}';
DBSY01D={'dr' '' 0.4143 []}';
DBSY01E={'dr' '' 2.9046 []}';%0.807+0.6+1.4976
DBSY01F={'dr' '' 0.31575 []}';
DBSY01G={'dr' '' 0.31575 []}';
DBSY01H={'dr' '' 0.7975 []}';
DBSY01I={'dr' '' 0.0184 []}';
LDBSY50 =  2.144276 ;%Station 100 to center of Q50Q1
DBSY50={'dr' '' LDBSY50-LQR/2 []}';
DBSY50A={'dr' '' 0.5782 []}';
DBSY50B={'dr' '' DBSY50{3}-DBSY50A{3} []}';
DBSY02={'dr' '' 0.456124 []}';
DBSY02B={'dr' '' 0.2199 []}';
DBSY02A={'dr' '' DBSY02{3}-DBSY02B{3} []}';
DBSY51={'dr' '' 5.521976 []}';
DBSY51B={'dr' '' 0.5 []}';
DBSY51A={'dr' '' DBSY51{3}-DBSY51B{3} []}';
DBSY52={'dr' '' 54.883314 []}';
DBSY52A={'dr' '' 0.079149 []}';
DBSY52B={'dr' '' 1.799589 []}';%2.420851
DBSY52C={'dr' '' DBSY52{3}-DBSY52A{3}-DBSY52B{3}-LBRCUSDC1-DCKDC1{3}-LBKRCUS-DCKDC2{3}-LBRCUSDC2-DCUSBLRA{3}-DCUSBLRB{3}-LBLRCUS-LBXSPH-DBSY52D{3} []}';
BPMBSYQ1={'mo' 'BPMBSYQ1' 0 []}';%changed from "-6" to fit 2Q10
BPMBSYQ2={'mo' 'BPMBSYQ2' 0 []}';%per C. Iverson
YCBSYQ1={'mo' 'YCBSYQ1' 0 []}';%barcode=4600
XCBSYQ2={'mo' 'XCBSYQ2' 0 []}';%barcode=4601
IMBSY1={'mo' 'IMBSY1' 0 []}';%Bergoz toroid
IMBSY2={'mo' 'IMBSY2' 0 []}';%Bergoz toroid
IMBSY3={'mo' 'IMBSY3' 0 []}';%Bergoz toroid
IMBSY1B={'mo' 'IMBSY1B' 0 []}';%PEP2 backup toroid for IMBSY1
IMBSY2B={'mo' 'IMBSY2B' 0 []}';%PEP2 backup toroid for IMBSY2
IMBSY3B={'mo' 'IMBSY3B' 0 []}';%PEP2 backup toroid for IMBSY3
IMBSY34={'mo' 'IMBSY34' 0 []}';%diagnostic toroid - existing LCLS device
LPCBSY =  0.3 ;%TBD
BSYBEG={'mo' 'BSYBEG' 0 []}';
FFTBORGN={'mo' 'FFTBORGN' 0 []}';
S100={'mo' 'S100' 0 []}';%station 100
ZLIN15={'mo' 'ZLIN15' 0 []}';%station-100 (or "S100"): Z=3048.0 (Z'=X'=Y'=0.0 m)
BEGBSY1={'mo' 'BEGBSY1' 0 []}';
ENDBSY1={'mo' 'ENDBSY1' 0 []}';
%BSYS100 : LINE=(&
%  BEGBSY1,&
%  DBSY03a,IMBSY1,DBSY03b,IMBSY2,DBSY03c,IMBSY3,DBSY03d,IMBSY34,DBSY03e,&
%  BXTDBSYA,BXTDBSYB,DBSY02c,IMBSY1b,DBSY02d,IMBSY2b,DBSY02e,IMBSY3b,DBSY02a,&
%  FFTBORGN,DBSY02b)
BSYS100=[BEGBSY1,DBSY01A,IMBSY1,DBSY01B,IMBSY2,DBSY01C,IMBSY3,DBSY01D,IMBSY34,DBSY01E,IMBSY1B,DBSY01F,IMBSY2B,DBSY01G,IMBSY3B,DBSY01H,FFTBORGN,DBSY01I];
S100SXRA=[S100,ZLIN15,DBSY50A,YCBSYQ1,DBSY50B,Q50Q1,Q50Q1,DBSY02A,WOODDOOR];
S100SXRB=[DBSY02B,BPMBSYQ1,DBSY51A,XCBSYQ2,DBSY51B,Q50Q2,Q50Q2,DBSY52A,BPMBSYQ2,DBSY52B];
S100SXR=[S100SXRA,S100SXRB];
%BSYSXR : LINE=(BSYbeg,BSYS100,S100SXR)
S100BSY1=[S100SXR,KCUSXRA,DBSY52C,BXSP1HA,BXSP1HB];
BSY1=[BSYS100,S100BSY1];
BSY=[BSYBEG,BSY1,ENDBSY1,SPHBSY];
% ------------------------------------------------------------------------------
% HXR VBEND
% ------------------------------------------------------------------------------
KQVM1 =  -0.33743727324  ;%-0.337436662826
KQVM2 =   0.236577259388 ;% 0.236576383685
KQVM3 =   0.715150825178 ;% 0.715150537655
KQVM4 =  -0.681650171008 ;%-0.681649920823
QVM1={'qu' 'QVM1' LQF/2 [KQVM1 0]}';
QVM2={'qu' 'QVM2' LQF/2 [KQVM2 0]}';
QVM3={'qu' 'QVM3' LQF/2 [KQVM3 0]}';
QVM4={'qu' 'QVM4' LQF/2 [KQVM4 0]}';
KQVB =  -0.42223036711;
QVB1={'qu' 'QVB1' LQF/2 [KQVB 0]}';
QVB2={'qu' 'QVB2' LQF/2 [-KQVB 0]}';
QVB3={'qu' 'QVB3' LQF/2 [KQVB 0]}';
BY1A={'be' 'BY1' LVB/2 [AVB/2 GVB/2 AVB/2 0 0.5 0 pi/2]}';
BY1B={'be' 'BY1' LVB/2 [AVB/2 GVB/2 0 AVB/2 0 0.5 pi/2]}';
BY2A={'be' 'BY2' LVB/2 [AVB/2 GVB/2 AVB/2 0 0.5 0 pi/2]}';
BY2B={'be' 'BY2' LVB/2 [AVB/2 GVB/2 0 AVB/2 0 0.5 pi/2]}';
DVB1={'dr' '' 8.0-2*0.3125 []}';
DVB2M80CM={'dr' '' 4.0-0.4-0.4 []}';
DVB2={'dr' '' 4.0 []}';
DVB2HA={'dr' '' 0.933932 []}';%0.995885
DVB2HB={'dr' '' DVB2{3}-DVB2HA{3} []}';
DVB1M40CM={'dr' '' 8.0-0.4-2*0.3125 []}';
DVB25CMC={'dr' '' 0.5-0.25 []}';
DVBEM25CM={'dr' '' 0.5-0.25 []}';
DVBEM15CM={'dr' '' 0.150+0.00381+0.018803 []}';
DQVM2B={'dr' '' 0.24954 []}';
DQVM2A={'dr' '' DQVM2{3}-DQVM2B{3} []}';
DWSVM2={'dr' '' DXCVM2{3}+DVB25CM{3} []}';
DWSVM2A={'dr' '' 0.24954+0.0046 []}';
DWSVM2B={'dr' '' DWSVM2{3}-DWSVM2A{3} []}';
BPMVM1={'mo' 'BPMVM1' 0 []}';
BPMVM2={'mo' 'BPMVM2' 0 []}';
BPMVM3={'mo' 'BPMVM3' 0 []}';
BPMVM4={'mo' 'BPMVM4' 0 []}';
BPMVB1={'mo' 'BPMVB1' 0 []}';
BPMVB2={'mo' 'BPMVB2' 0 []}';
BPMVB3={'mo' 'BPMVB3' 0 []}';
XCVB2={'mo' 'XCVB2' 0 []}';
XCVM2={'mo' 'XCVM2' 0 []}';
XCVM3={'mo' 'XCVM3' 0 []}';
YCVM1={'mo' 'YCVM1' 0 []}';%calibrated to <1%
YCVB1={'mo' 'YCVB1' 0 []}';
YCVB3={'mo' 'YCVB3' 0 []}';
YCVM4={'mo' 'YCVM4' 0 []}';
IM31={'mo' 'IM31' 0 []}';%comparator with IM36 (existing LCLS device)
IMBCS1={'mo' 'IMBCS1' 0 []}';%comparator with IMBCS2 (existing LCLS device)
WSVM2={'mo' 'WSVM2' 0 []}';%existing LCLS device
BTM01={'mo' 'BTM01' 0 []}';
VBIN={'mo' 'VBIN' 0 []}';%start of vert. bend system: Z=3226.684265 (Z'=178.682318 m, X'=0.0 m, Y'=-0.834187 m)
VBOUT={'mo' 'VBOUT' 0 []}';%end of vert. bend system: Z=3252.866951 (Z'=204.865005 m, X'= 0.0 m, Y'=-0.895304 m)
CNTLT1H={'mo' 'CNTLT1H' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
VBEND=[VBIN,BY1A,BY1B,DVB1,QVB1,BPMVB1,QVB1,D40CMC,YCVB1,DVB2M80CM,XCVB2,D40CMC,QVB2,BPMVB2,QVB2,DVB2HA,BTM01,DVB2HB, QVB3,BPMVB3,QVB3,D40CMC,YCVB3,DVB1M40CM,BY2A,BY2B,CNTLT1H,VBOUT];
VBSYS=[BEGLTUH,DYCVM1,YCVM1,DQVM1,QVM1,BPMVM1,QVM1,DQVM2A,XCVM2,DQVM2B,QVM2,BPMVM2,QVM2,DWSVM2A,WSVM2,DWSVM2B,VBEND,DVB25CMC,XCVM3,D25CM,QVM3,BPMVM3,QVM3,DVBEM25CM,YCVM4,D25CM,QVM4,BPMVM4,QVM4,DVBEM15CM,IM31,D10CMB,IMBCS1,D25CMA];
% ------------------------------------------------------------------------------
% HXR dogleg
% ------------------------------------------------------------------------------
KQDL =  0.437183970154;
QDL31={'qu' 'QDL31' LQA/2 [KQDL 0]}';
QDL32={'qu' 'QDL32' LQA/2 [KQDL 0]}';
QDL33={'qu' 'QDL33' LQA/2 [KQDL 0]}';
QDL34={'qu' 'QDL34' LQA/2 [KQDL 0]}';
KCQ31 =  0;
KCQ32 =  0;
CQ31={'qu' 'CQ31' LQX/2 [KCQ31 0]}';
CQ32={'qu' 'CQ32' LQX/2 [KCQ32 0]}';
KQT1 = -0.420937827343;
KQT2 =  0.839614778043;
QT11={'qu' 'QT11' LQF/2 [KQT1 0]}';
QT12={'qu' 'QT12' LQF/2 [KQT2 0]}';
QT13={'qu' 'QT13' LQF/2 [KQT1 0]}';
QT21={'qu' 'QT21' LQF/2 [KQT1 0]}';
QT22={'qu' 'QT22' LQF/2 [KQT2 0]}';
QT23={'qu' 'QT23' LQF/2 [KQT1 0]}';
QT31={'qu' 'QT31' LQF/2 [KQT1 0]}';
QT32={'qu' 'QT32' LQF/2 [KQT2 0]}';
QT33={'qu' 'QT33' LQF/2 [KQT1 0]}';
QT41={'qu' 'QT41' LQF/2 [KQT1 0]}';
QT42={'qu' 'QT42' LQF/2 [KQT2 0]}';
QT43={'qu' 'QT43' LQF/2 [KQT1 0]}';
LB3 =   2.623                   ;%4D102.36T effective length (m)
GB3 =   0.023                   ;%4D102.36T gap height (m)
AB3P =   0.499999821952*RADDEG;
AB3M =  -AB3P;
LEFFB3 =  LB3*AB3P/(2*sin(AB3P/2)) ;%full bend eff. path length (m)
BX31A={'be' 'BX31' LEFFB3/2 [AB3P/2 GB3/2 AB3P/2 0 0.5 0.0 0]}';
BX31B={'be' 'BX31' LEFFB3/2 [AB3P/2 GB3/2 0 AB3P/2 0.0 0.5 0]}';
BX32A={'be' 'BX32' LEFFB3/2 [AB3P/2 GB3/2 AB3P/2 0 0.5 0.0 0]}';
BX32B={'be' 'BX32' LEFFB3/2 [AB3P/2 GB3/2 0 AB3P/2 0.0 0.5 0]}';
BX35A={'be' 'BX35' LEFFB3/2 [AB3M/2 GB3/2 AB3M/2 0 0.5 0.0 0]}';
BX35B={'be' 'BX35' LEFFB3/2 [AB3M/2 GB3/2 0 AB3M/2 0.0 0.5 0]}';
BX36A={'be' 'BX36' LEFFB3/2 [AB3M/2 GB3/2 AB3M/2 0 0.5 0.0 0]}';
BX36B={'be' 'BX36' LEFFB3/2 [AB3M/2 GB3/2 0 AB3M/2 0.0 0.5 0]}';
% single beam dumper vertical kicker (existing, restored)
LKIK =  1.0601 ;%kicker coil length per magnet (m) [41.737 in from SA-380-330-02, rev. 0]
ABYKIK =  0.75E-3 *1E-12 ;%full angle =0.75E-3 when BYKIK1,2 are turned on
BYKIK1A={'be' 'BYKIK1' LKIK/2 [ABYKIK/4 25.4E-3 ABYKIK/4 0 0.5 0 pi/2]}';
BYKIK1B={'be' 'BYKIK1' LKIK/2 [ABYKIK/4 25.4E-3 0 ABYKIK/4 0 0.5 pi/2]}';
BYKIK2A={'be' 'BYKIK2' LKIK/2 [ABYKIK/4 25.4E-3 ABYKIK/4 0 0.5 0 pi/2]}';
BYKIK2B={'be' 'BYKIK2' LKIK/2 [ABYKIK/4 25.4E-3 0 ABYKIK/4 0 0.5 pi/2]}';
%DBYKIK1 : DRIF, L=LKIK
%DBYKIK2 : DRIF, L=LKIK
LSPONT =  1.5 ;%length of possible spontaneous undulator (<=5 m now that TDKIK is also there)
DCB32={'dr' '' 0.8+0.01 []}';
DDL10W={'dr' '' 11.99440265 []}';
DDL10WA={'dr' '' 1.028339 []}';%1.090222
DDL10WB={'dr' '' DDL10W{3}-DDL10WA{3} []}';
DWSDL31A={'dr' '' 0.096237 []}';
DWSDL31B={'dr' '' 0.153763 []}';
DDL10X={'dr' '' 0.126314 []}';
D32CMB={'dr' '' 0.6638034 []}';
D31A={'dr' '' 0.562465-0.002 []}';
D31B={'dr' '' 0.5624381-DRFB{3}-0.002 []}';
D31C={'dr' '' 0.5 []}';
DDL10EM80CM={'dr' '' 9.017887+0.01 []}';
DDL10EM80CMA={'dr' '' 3.744796 []}';
DDL10EM80CMB={'dr' '' DDL10EM80CM{3}-DDL10EM80CMA{3} []}';
DX33A={'dr' '' 1.4154 []}';%LB3-DX33B[L]-2.0
DX33B={'dr' '' 0.427646 []}';%0.5
DX34B={'dr' '' 0.5 []}';
DX34A={'dr' '' LB3-DX34B{3}-2.0 []}';
DX37B={'dr' '' 0.5 []}';
DX37A={'dr' '' LB3-DX37B{3}-2.0 []}';
DX38A={'dr' '' LB3/2 []}';
DX38B={'dr' '' LB3/2 []}';
DDL1A={'dr' '' 5.820626-LKIK/2 []}';
DDL1AA={'dr' '' 1.220046 []}';%1.261541
DDL1AB={'dr' '' DDL1A{3}-DDL1AA{3} []}';
DDL1D={'dr' '' 0.609226-LKIK/2 []}';
DDL1E={'dr' '' 5.421642-LKIK/2 []}';
D32A={'dr' '' 0.47046 []}';
D32B={'dr' '' 0.47046 []}';
D33A={'dr' '' 0.39 []}';
D33B={'dr' '' 0.32 []}';
D34A={'dr' '' 0.56 []}';
D34B={'dr' '' 0.32 []}';
DSPLR={'dr' '' 0.43036 []}';
DDL1CM40CM={'dr' '' 6.03036-0.43036-0.6096/2 []}';
D30CMA={'dr' '' 0.257426 []}';
DPC1={'dr' '' 0.266697 []}';
DPC2={'dr' '' 0.266697 []}';
DPC3={'dr' '' 0.266697 []}';
DPC4={'dr' '' 0.266697+0.339613-0.8128/2 []}';
DSPONTUA={'dr' '' LSPONT/2 []}';
DSPONTUB={'dr' '' LSPONT/2 []}';
DDL1DM30CM={'dr' '' 0.379160-0.262228 []}';%allow possible new spontaneous undulator here
DCQ31A={'dr' '' 6.037182 []}';
DCQ31AA={'dr' '' 1.414467 []}';%1.475565
DCQ31AB={'dr' '' 2.000098 []}';%3.199061
DCQ31AC={'dr' '' DCQ31A{3}-DCQ31AA{3}-DCQ31AB{3} []}';
DCQ31B={'dr' '' 5.811658 []}';
D29CMA={'dr' '' 0.29+0.023878+0.1000244+0.1704396 []}';
D32CMD={'dr' '' 0.32-0.056221+0.4000244+0.2404381 []}';
DCQ32A={'dr' '' 5.4817585 []}';
DCB36={'dr' '' 2.7+0.01-1.9 []}';%make it identical to DCB32[L]
DCQ32B={'dr' '' 6.0371785-DCB36{3}-LJAW []}';
D30CM={'dr' '' 0.30 []}';
DDL10M70CM={'dr' '' 12.86072-0.4-0.3-0.09+0.00046 []}';
DDL10MA={'dr' '' 1.365410 []}';
DDL10MB={'dr' '' DDL10M70CM{3}-DDL10MA{3} []}';
DDL10UM25CM={'dr' '' 0.5-0.25-0.2399776+0.2404376 []}';
DDL10V={'dr' '' 12.86072-0.5 []}';
DDL20E={'dr' '' 0.5 []}';
DDL30EM40CM={'dr' '' 1.0-0.4-0.090013 []}';
D40CMB={'dr' '' 0.40+0.090013 []}';
D46CM={'dr' '' (1.0-LJAW)/2 []}';
DDL20={'dr' '' 0.5 []}';
DDL30EM40CMA={'dr' '' 1.0-0.4-0.090013+0.000473 []}';
D40CMD={'dr' '' 0.40+0.090013-0.000473 []}';
D40CME={'dr' '' 0.40+0.090013+0.010447 []}';
DDL30EM40CMB={'dr' '' 1.0-0.4-0.090013-0.010447 []}';
DDL30EM40CMC={'dr' '' 1.0-0.4-0.090013+0.065013 []}';
D40CMF={'dr' '' 0.40+0.090013-0.065013 []}';
% RFBHX12 is moved upstream of BEGHXR
RFBHX12={'mo' 'RFBHX12' LRFBUB []}';
DMUON4={'dr' '' 0.059608016 []}';
DMUON3={'dr' '' DMUON3B{3}-DMUON4{3}-LRFBUB []}';
% dechirper installation (August, 2015)
LCHIRP =  2.0;
D37A={'dr' '' 0.27032 []}';%0.123
D37B={'dr' '' 0.65268 []}';%0.8
D37BA={'dr' '' 0.157367 []}';%0.304687
D37BB={'dr' '' D37B{3}-D37BA{3} []}';
D37C={'dr' '' 2.804723 []}';%1.36541
D37D={'dr' '' 6.218668237037 []}';%7.657981237037
WSDL4={'mo' 'WSDL4' 0 []}';%Patrick K. says this device is used only with the dechirper
D37E={'dr' '' 1.097522857741 []}';
DCHIRPV={'mo' 'DCHIRPV' LCHIRP/2 []}';%split in half
MDCHIRPV={'mo' 'MDCHIRPV' 0 []}';%center of dechirper
%D37f     : DRIF, L=DDL10mb[L]+D34A[L]-D37d[L]-D37e[L]-LCHIRP
D37F={'dr' '' DDL10MB{3}+D34A{3}-7.657981237037-D37E{3}-LCHIRP []}';%D37d changed
D38A={'dr' '' 0.509870493892 []}';
D38AA={'dr' '' 0.293656 []}';
D38AB={'dr' '' D38A{3}-D38AA{3} []}';
DCHIRPH={'mo' 'DCHIRPH' LCHIRP/2 []}';%split in half
MDCHIRPH={'mo' 'MDCHIRPH' 0 []}';%center of dechirper
D38B={'dr' '' 0.609117535347 []}';
D38C={'dr' '' 0.540705892339 []}';
D38D={'dr' '' (D34B{3}+DDL10UM25CM{3}+DDL10V{3}+DX38A{3}+DX38B{3})-(D38A{3}+LCHIRP+D38B{3}+D38C{3}) []}';
RFBDL1={'mo' 'RFBDL1' 0 []}';
BPMDL2={'mo' 'BPMDL2' 0 []}';
BPMDL3={'mo' 'BPMDL3' 0 []}';
BPMDL4={'mo' 'BPMDL4' 0 []}';
BPMT12={'mo' 'BPMT12' 0 []}';
BPMT22={'mo' 'BPMT22' 0 []}';
BPMT32={'mo' 'BPMT32' 0 []}';
BPMT42={'mo' 'BPMT42' 0 []}';
BPMDL1={'mo' 'BPMDL1' 0 []}';%existing LCLS device
XCDL1={'mo' 'XCDL1' 0 []}';
XCDL2={'mo' 'XCDL2' 0 []}';
XCDL3={'mo' 'XCDL3' 0 []}';
XCQT12={'mo' 'XCQT12' 0 []}';
XCQT22={'mo' 'XCQT22' 0 []}';
XCQT42={'mo' 'XCQT42' 0 []}';
YCDL1={'mo' 'YCDL1' 0 []}';
YCDL2={'mo' 'YCDL2' 0 []}';
YCDL3={'mo' 'YCDL3' 0 []}';
YCDL4={'mo' 'YCDL4' 0 []}';
YCQT12={'mo' 'YCQT12' 0 []}';
YCQT21={'mo' 'YCQT21' 0 []}';
XCQT32={'mo' 'XCQT32' 0 []}';%fast-feedback (loop-4)
XCDL4={'mo' 'XCDL4' 0 []}';%fast-feedback (loop-4)
YCQT32={'mo' 'YCQT32' 0 []}';%fast-feedback (loop-4)
YCQT42={'mo' 'YCQT42' 0 []}';%fast-feedback (loop-4)
SPOILER={'mo' 'SPOILER' 0 []}';%TDKIK dump spoiler
TDKIK={'mo' 'TDKIK' 0.6096 []}';%vertical off-axis in-line dump
%DSPOILER : MARK
%DTDKIK   : DRIF, L=0.6096
WSDL31={'mo' 'WSDL31' 0 []}';
%OTR30  : PROF, TYPE="OTR" LTU slice energy spread (90 deg from TCAV3)
MOTR30={'mo' 'MOTR30' 0 []}';%OTR30 abandoned in place
CEDL1={'dr' 'CEDL1' 0.08 []}';%existing LCLS
CEDL3={'dr' 'CEDL3' 0.08 []}';%existing LCLS
CYBX32={'dr' 'CYBX32' LJAW []}';%reconfigured LCLS CY32
CXQT22={'dr' 'CXQT22' LJAW []}';%reconfigured LCLS CX35
CYBX36={'dr' 'CYBX36' LJAW []}';%reconfigured LCLS CY36
% muon collimators after SBD TDKIK in-line dump
PCTDKIK1={'dr' 'PCTDKIK1' LPCTDKIK []}';
PCTDKIK2={'dr' 'PCTDKIK2' LPCTDKIK []}';
PCTDKIK3={'dr' 'PCTDKIK3' LPCTDKIK []}';
PCTDKIK4={'dr' 'PCTDKIK4' LPCTDKIK []}';
%DPCTDKIK : DRIF, L=LPCTDKIK
IMBCS2={'mo' 'IMBCS2' 0 []}';%comparator with IMBCS1 (existing LCLS device)
BTM02={'mo' 'BTM02' 0 []}';
BTM22={'mo' 'BTM22' 0 []}';
BTM03={'mo' 'BTM03' 0 []}';
BTM04={'mo' 'BTM04' 0 []}';
BTM42={'mo' 'BTM42' 0 []}';
BTM43={'mo' 'BTM43' 0 []}';
BTM05={'mo' 'BTM05' 0 []}';
BTM06={'mo' 'BTM06' 0 []}';
DL23BEG={'mo' 'DL23BEG' 0 []}';
CNTWIGH={'mo' 'CNTWIGH' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
CNTLT2H={'mo' 'CNTLT2H' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
CNTLT3H={'mo' 'CNTLT3H' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
SS1={'mo' 'SS1' 0 []}';
SS3={'mo' 'SS3' 0 []}';
DBMARK34={'mo' 'DBMARK34' 0 []}';%entrance of BX31
% wiggler for sync. light energy diagnostic (described in SLAC-PUB-3945)
% based on FACET optics model (M. Woodley)
% (series approximation for sinc(x)=sin(x)/x to enable setting with x=0)
BWGH =  1.E-12                  ;%wiggler bend field (kG)
AWGH =  asin(BWGH*ZWHP/(EF*CB)) ;%bend angle per half-pole
AWGH2 =  AWGH*AWGH;
AWGH4 =  AWGH2*AWGH2;
AWGH6 =  AWGH4*AWGH2;
SINCH =  1-AWGH2/6+AWGH4/120-AWGH6/5040;
LWGH =  ZWHP/SINCH              ;%half-pole path length
AWG1H =  asin(sin(AWGH)/2) ;%"short half" half-pole bend angle
AWG1H2 =  AWG1H*AWG1H;
AWG1H4 =  AWG1H2*AWG1H2;
AWG1H6 =  AWG1H4*AWG1H2;
SINC1H =  1-AWG1H2/6+AWG1H4/120-AWG1H6/5040;
LWG1H =  (ZWHP/2)/SINC1H   ;%"short half" half-pole path length
AWG2H =  AWGH-AWG1H        ;%"long half" half-pole bend angle
LWG2H =  LWGH-LWG1H        ;%"long half" half-pole path length
WIG1HA={'be' 'WIG1H' LWG1H [AWG1H GWIG/2 0 0 0.5 0 pi/2]}';
WIG1HB={'be' 'WIG1H' LWG2H [AWG2H GWIG/2 0 AWGH 0 0.5 pi/2]}';
WIG2HA={'be' 'WIG2H' LWGH [-AWGH GWIG/2 -AWGH 0 0.5 0 pi/2]}';
WIG2HB={'be' 'WIG2H' LWGH [-AWGH GWIG/2 0 -AWGH 0 0.5 pi/2]}';
WIG3HA={'be' 'WIG3H' LWG2H [AWG2H GWIG/2 AWGH 0 0.5 0 pi/2]}';
WIG3HB={'be' 'WIG3H' LWG1H [AWG1H GWIG/2 0 0 0 0.5 pi/2]}';
LDWGH =  ZDWG/cos(AWGH);
DWGH={'dr' '' LDWGH []}';
YCWIGH={'mo' 'YCWIGH' 0 []}';
EWIGH=[WIG1HA,WIG1HB,DWGH,WIG2HA,YCWIGH,WIG2HB,DWGH,WIG3HA,WIG3HB,CNTWIGH];
DL21=[DBMARK34,BX31A,BX31B,DDL10WA,BTM02,DDL10WB,DWSDL31A,WSDL31,DWSDL31B,DDL10X,XCDL1,D31A,QDL31,BPMDL1,QDL31,DRFB,RFBDL1,D31B,YCDL1,D32CMB,CEDL1,D31C,EWIGH,DDL10EM80CMA,BTM22,DDL10EM80CMB,CYBX32,DCB32,BX32A,BX32B,CNTLT2H];
DL22=[DX33A,CC32,DX33B,BTM03,DDL1AB,BYKIK1A,BYKIK1B,DDL1D,DDL1D,BYKIK2A,BYKIK2B,DDL1E,XCDL2,D32A,QDL32,BPMDL2,QDL32,D32B,YCDL2,DSPLR,SPOILER,DDL1CM40CM,TDKIK,D30CMA,PCTDKIK1,DPC1,PCTDKIK2,DPC2,PCTDKIK3,DPC3,PCTDKIK4,DPC4,DSPONTUA,DSPONTUB,DDL1DM30CM,DX34A,CC35,DX34B];
DL23=[DL23BEG,BX35A,BX35B,DCQ31AA,BTM04,DCQ31AB,BTM42,DCQ31AC,CQ31,CQ31,DCQ31B,MOTR30,D29CMA,XCDL3,D33A,QDL33,BPMDL3,QDL33,D33B,YCDL3,D32CMD,CEDL3,DCQ32A, CQ32,CQ32,DCQ32B,CYBX36,DCB36,BX36A,BX36B,CNTLT3H];
DCHIRPVL=[DCHIRPV,MDCHIRPV,DCHIRPV];
DCHIRPHL=[DCHIRPH,MDCHIRPH,DCHIRPH];
DL24=[D37A,CC36,D37BA,BTM43,D37BB,IMBCS2,D37C,BTM05,D37D,WSDL4,D37E,DCHIRPVL,D37F,QDL34,BPMDL4,QDL34,D38AA,BTM06,D38AB,DCHIRPHL,D38B,XCDL4,D38C,YCDL4,D38D];
TRIP1=[DDL20E,QT11,QT11,DDL30EM40CM,XCQT12,D40CMB,QT12,BPMT12,QT12,D40CMB,YCQT12,DDL30EM40CM,QT13,QT13,DDL20E];
TRIP2=[YCQT21,DDL20,QT21,QT21,DDL30EM40CM,XCQT22,D40CMB,QT22,BPMT22,QT22,D46CM,CXQT22,D46CM,QT23,QT23,DDL20];
TRIP3=[DDL20E,QT31,QT31,DDL30EM40CMA,XCQT32,D40CMD,QT32,BPMT32,QT32,D40CME,YCQT32,DDL30EM40CMB,QT33,QT33,DDL20E];
TRIP4=[DDL20,QT41,QT41,DDL30EM40CMC,XCQT42,D40CMF,QT42,BPMT42,QT42,D40CMB,YCQT42,DDL30EM40CM,QT43,QT43,DDL20];
DOGLG2A=[DL21,TRIP1,SS1,DL22,TRIP2];
DOGLG2B=[DL23,TRIP3,SS3,DL24,TRIP4];
% ------------------------------------------------------------------------------
% HXR emittance diagnostic
% ------------------------------------------------------------------------------
KQEM1 =  -0.386250956878 ;%-0.385933654152
KQEM2 =   0.429466776058 ;% 0.429261112104
KQEM3 =  -0.596168395282 ;%-0.596365130037
KQEM4 =   0.419766074433 ;% 0.419727067489
QEM1={'qu' 'QEM1' LQA/2 [KQEM1 0]}';
QEM2={'qu' 'QEM2' LQA/2 [KQEM2 0]}';
QEM3={'qu' 'QEM3' LQA/2 [KQEM3 0]}';
QEM3V={'qu' 'QEM3V' LQX/2 [0 0]}';
QEM4={'qu' 'QEM4' LQA/2 [KQEM4 0]}';
KQED2 =  0.402753198232;
KQE31 =  +KQED2;
KQE32 =  -KQED2;
KQE33 =  +KQED2;
KQE34 =  -KQED2;
KQE35 =  +KQED2;
KQE36 =  -KQED2;
QE31={'qu' 'QE31' LQX/2 [KQE31 0]}';
QE32={'qu' 'QE32' LQX/2 [KQE32 0]}';
QE33={'qu' 'QE33' LQX/2 [KQE33 0]}';
QE34={'qu' 'QE34' LQX/2 [KQE34 0]}';
QE35={'qu' 'QE35' LQX/2 [KQE35 0]}';
QE36={'qu' 'QE36' LQX/2 [KQE36 0]}';
DMM1M90CM={'dr' '' 1.20046 []}';
DEM1BA={'dr' '' 2.326522 []}';%1.086830
DEM1BB={'dr' '' DEM1B{3}-DEM1BA{3} []}';
DMM3MA={'dr' '' 10.315743 []}';%4.425910
DMM3MB={'dr' '' DMM3M80CM{3}-DMM3MA{3} []}';
DE3MA={'dr' '' 1.173550 []}';%5.333610
DE3MB={'dr' '' DE3M80CMA{3}-DE3MA{3} []}';
DE3AA={'dr' '' 1.341982 []}';
DE3AB={'dr' '' DE3A{3}-DE3AA{3} []}';
DQECA={'dr' '' 7.950716+0.000011 []}';
DQECAA={'dr' '' 1.440646 []}';
DQECAB={'dr' '' DQECA{3}-DQECAA{3} []}';
DQECB={'dr' '' DQEC{3}-DQECA{3} []}';
DE3M80CMC={'dr' '' 2.647321 []}';
DE3M80CMD={'dr' '' DE3M80CM{3}-DE3M80CMC{3} []}';
D40CMH={'dr' '' 0.0317 []}';
D40CMG={'dr' '' D40CM{3}-D40CMH{3} []}';
BPMEM1={'mo' 'BPMEM1' 0 []}';
BPMEM2={'mo' 'BPMEM2' 0 []}';
BPMEM3={'mo' 'BPMEM3' 0 []}';
BPMEM4={'mo' 'BPMEM4' 0 []}';%existing LCLS device
RFBEM4={'mo' 'RFBEM4' 0 []}';
BPME31={'mo' 'BPME31' 0 []}';
BPME32={'mo' 'BPME32' 0 []}';%existing LCLS device
RFBE32={'mo' 'RFBE32' 0 []}';
BPME33={'mo' 'BPME33' 0 []}';
BPME34={'mo' 'BPME34' 0 []}';%existing LCLS device
RFBE34={'mo' 'RFBE34' 0 []}';
BPME35={'mo' 'BPME35' 0 []}';
BPME36={'mo' 'BPME36' 0 []}';%existing LCLS device
RFBE36={'mo' 'RFBE36' 0 []}';
XCEM2={'mo' 'XCEM2' 0 []}';
XCEM4={'mo' 'XCEM4' 0 []}';
XCE31={'mo' 'XCE31' 0 []}';
XCE33={'mo' 'XCE33' 0 []}';
XCE35={'mo' 'XCE35' 0 []}';
YCEM1={'mo' 'YCEM1' 0 []}';
YCEM3={'mo' 'YCEM3' 0 []}';
YCE32={'mo' 'YCE32' 0 []}';
YCE34={'mo' 'YCE34' 0 []}';
YCE36={'mo' 'YCE36' 0 []}';
WS31={'mo' 'WS31' 0 []}';%LTU emittance
WS32={'mo' 'WS32' 0 []}';%LTU emittance
WS33={'mo' 'WS33' 0 []}';%LTU emittance
WS34={'mo' 'WS34' 0 []}';%LTU emittance
%  WS35 : WIRE, TYPE="fast"  prototype ... not installed
%  WS36 : WIRE, TYPE="piezo" prototype ... not installed
DWS35={'mo' 'DWS35' 0 []}';
DWS36={'mo' 'DWS36' 0 []}';
IM36={'mo' 'IM36' 0 []}';%comparator with IM31 (existing LCLS device)
YAGPSI={'mo' 'YAGPSI' 0 []}';%existing LCLS device
OTR33={'mo' 'OTR33' 0 []}';%LTU slice emittance (existing LCLS device)
BTM07={'mo' 'BTM07' 0 []}';
BTM08={'mo' 'BTM08' 0 []}';
BTM09={'mo' 'BTM09' 0 []}';
BTM10={'mo' 'BTM10' 0 []}';%BCS BTM
BTM11={'mo' 'BTM11' 0 []}';%BCS BTM
BTM12={'mo' 'BTM12' 0 []}';%BCS BTM
%DCX31 : DRIF, L=0.08
DCX35={'dr' '' 0.08 []}';
DCY32={'dr' '' 0.08 []}';
DCY36={'dr' '' 0.08 []}';
CX31={'dr' 'CX31' 0.08 []}';%fully open existing LCLS collimator
%CX35 : RCOL, L=0.08 reconfigured as CXQT22
%CY32 : RCOL, L=0.08 reconfigured as CYBX32
%CY36 : RCOL, L=0.08 reconfigured as CYBX36
DBMARK36={'mo' 'DBMARK36' 0 []}';%center of WS31
EDMCH=[D25CMB,IM36,D25CMC,DMM1M90CM,YCEM1,DEM1A,QEM1,BPMEM1,QEM1,DEM1BA,BTM07,DEM1BB,QEM2,BPMEM2,QEM2,DEM2B,XCEM2,DMM3MA,BTM08,DMM3MB,YCEM3,DEM3A,QEM3,BPMEM3,QEM3,DEM3B,QEM3V,QEM3V,DMM4M90CM,XCEM4,DEM4A,QEM4,BPMEM4,QEM4,DRFB,RFBEM4,DMM5];
EDSYS=[DBMARK36,WS31,D40CM,DE3MA,BTM09,DE3MB,XCE31,DQEA,QE31,BPME31,QE31,DQEBX,CX31,DQEBX2,DE3AA,BTM10,DE3AB,YCE32,DQEAA,QE32,BPME32,QE32,DRFB,RFBE32,DQEBY1,DCY32,DQEBY2,WS32,D40CM,DE3M80CMB,XCE33,DQEAB, QE33,BPME33,QE33,DQECAA,BTM11,DQECAB,YAGPSI,DQECB,OTR33,DE3M40CM,YCE34,DQEA,QE34,BPME34,QE34,DRFB,RFBE34,DQEC1,WS33,D40CM,DE3M80CMC,BTM12,DE3M80CMD,XCE35,DQEAC,QE35,BPME35,QE35,DQEBX,DCX35,DQEBX2,DE3,YCE36,DQEA,QE36,BPME36,QE36,DRFB,RFBE36,DQEBY1,DCY36,DQEBY2,WS34,D40CMG,DWS35,D40CMH];
% ------------------------------------------------------------------------------
% HXR undulator match
% ------------------------------------------------------------------------------
% note: the below K-values are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQUM1 =   0.266446647337;
KQUM2 =  -0.257070322217;
KQUM3 =   0.249191553356;
KQUM4 =  -0.21849398386;
QUM1={'qu' 'QUM1' LQA/2 [KQUM1 0]}';
QUM2={'qu' 'QUM2' LQA/2 [KQUM2 0]}';
QUM3={'qu' 'QUM3' LQA/2 [KQUM3 0]}';
QUM4={'qu' 'QUM4' LQA/2 [KQUM4 0]}';
DU1M80CMA={'dr' '' 0.16515 []}';
DU1M80CMB={'dr' '' 0.219024 []}';
DU1M80CMC={'dr' '' DU1M80CM{3}-DU1M80CMA{3}-DU1M80CMB{3} []}';
D32CMC={'dr' '' 0.30046 []}';
DU2M120CM={'dr' '' 4.730 []}';
DW2TDUND={'dr' '' 0.201537 []}';%drift from BTH/UH wall-2 to TDUNDB u/s flange
BPMUM1={'mo' 'BPMUM1' 0 []}';
BPMUM2={'mo' 'BPMUM2' 0 []}';
BPMUM3={'mo' 'BPMUM3' 0 []}';
BPMUM4={'mo' 'BPMUM4' 0 []}';
RFB07={'mo' 'RFB07' 0 []}';%existing LCLS device
RFB08={'mo' 'RFB08' 0 []}';%existing LCLS device
IMUNDI={'mo' 'IMUNDI' 0 []}';%FEL-undulator input toroid (existing LCLS device)
XCUM1={'mo' 'XCUM1' 0 []}';%fast-feedback (loop-5)
XCUM3={'mo' 'XCUM3' 0 []}';%fast-feedback (loop-5)
YCUM2={'mo' 'YCUM2' 0 []}';%fast-feedback (loop-5)
YCUM4={'mo' 'YCUM4' 0 []}';%fast-feedback (loop-5)
% Note: PCMUON is rolled 90 degree to have X-aperture smaller than Y-aperture
%       X-aperture violates standard BSC -- approved by P. Emma
%PCMUON : ECOL,L=1.1684,XSIZE=8.64E-3/2,YSIZE=4.32E-3/2 original muon scattering collimator after pre-undulator tune-up dump (ID from Rago: 7/18/08)
PCMUON={'dr' 'PCMUON' 1.1684 []}';%90 deg rolled muon scattering collimator
BTM13={'mo' 'BTM13' 0 []}';
TDUND={'mo' 'TDUND' 0 []}';%LTU insertable block at und. extension entrance (w/ screen)
MM1={'mo' 'MM1' 0 []}';
MM2={'mo' 'MM2' 0 []}';
MM3={'mo' 'MM3' 0 []}';
EOBLM={'mo' 'EOBLM' 0 []}';%future electro-optic bunch length monitor?
VV999={'mo' 'VV999' 0 []}';%new vacuum valve just upbeam of undulator
PFILT1={'mo' 'PFILT1' 0 []}';
MUHWALL1={'mo' 'MUHWALL1' 0 []}';%upstream end of BTH/UH wall-1
MUHWALL2={'mo' 'MUHWALL2' 0 []}';%upstream end of BTH/UH wall-2
DBMARK37={'mo' 'DBMARK37' 0 []}';%end of undulator match
RWWAKE4H={'mo' 'RWWAKE4H' 0 []}';%LTUH beampipe wake applied here
UNMCH=[DU1M80CMA,DWS36,DU1M80CMB,BTM13,DU1M80CMC,DCX37,D32CMC,XCUM1,DUM1A,QUM1,BPMUM1,QUM1,DUM1B,D32CM,DU2M120CM,DCY38,D32CMA,YCUM2,DUM2A,QUM2,BPMUM2,QUM2,DUM2B,DU3M80CM,XCUM3,DUM3A,QUM3,BPMUM3,QUM3,DUM3B,D40CMA,EOBLM,DU4M120CM,YCUM4,DUM4A,QUM4,BPMUM4,QUM4,DUM4B,RFB07,DU5M80CM,IMUNDI,D40CMW,MUHWALL1,DUHWALL1,DUHVESTA,RFB08,DUHVESTB,MUHWALL2,DUHWALL2,DW2TDUND,DTDUND1,TDUND,DTDUND2,DPCMUON,PCMUON,DMUON1,VV999,DMUON3,RFBHX12,DMUON4,MM3,PFILT1,DBMARK37];
LTU=[VBSYS,MM1,DOGLG2A,DOGLG2B,MM2,EDMCH,EDSYS,UNMCH,RWWAKE4H,ENDLTUH];
% ------------------------------------------------------------------------------
% HXR dumpline
% ------------------------------------------------------------------------------
KQDMP =  -0.155212710055;
QDMP1={'qu' 'QDMP1' LQP/2 [KQDMP 0]}';
QDMP2={'qu' 'QDMP2' LQP/2 [KQDMP 0]}';
BYDSHA={'be' 'BYDSH' LEFFBYDS/2 [ABYDS/2 GBYDS/2 ABYDS/2 0 0.5 0.0 pi/2]}';
BYDSHB={'be' 'BYDSH' LEFFBYDS/2 [ABYDS/2 GBYDS/2 0 ABYDS/2 0.0 0.5 pi/2]}';
BYD1A={'be' 'BYD1' LEFFBDM/2 [ABDM/2 GBDM/2 ABDM/2 0 0.57 0.00 pi/2]}';
BYD1B={'be' 'BYD1' LEFFBDM/2 [ABDM/2 GBDM/2 0 ABDM/2 0.00 0.57 pi/2]}';
BYD2A={'be' 'BYD2' LEFFBDM/2 [ABDM/2 GBDM/2 ABDM/2 0 0.57 0.00 pi/2]}';
BYD2B={'be' 'BYD2' LEFFBDM/2 [ABDM/2 GBDM/2 0 ABDM/2 0.00 0.57 pi/2]}';
BYD3A={'be' 'BYD3' LEFFBDM/2 [ABDM/2 GBDM/2 ABDM/2 0 0.57 0.00 pi/2]}';
BYD3B={'be' 'BYD3' LEFFBDM/2 [ABDM/2 GBDM/2 0 ABDM/2 0.00 0.57 pi/2]}';
PCPM1L={'dr' 'PCPM1L' LPCPM []}';
PCPM2L={'dr' 'PCPM2L' LPCPM []}';
DD1A={'dr' '' 0.577681302427 []}';
DD1B={'dr' '' 1.000087502327 []}';
DD1C={'dr' '' 0.3048 []}';
DD1E={'dr' '' 0.249638105611 []}';
DD1F={'dr' '' 0.409240058046 []}';
DD1D={'dr' '' LDMP1-(DD1A{3}+PCPM1L{3}+DD1B{3}+DD1C{3}+DD1E{3}+PCPM2L{3}+DD1F{3}) []}';
BPMQD={'mo' 'BPMQD' 0 []}';%RFBQD : MONI, TYPE="@2,CavityL-1"
BPMDD={'mo' 'BPMDD' 0 []}';
RFBDD={'mo' 'RFBDD' 0 []}';
XCDD={'mo' 'XCDD' 0 []}';
YCDD={'mo' 'YCDD' 0 []}';
OTRDMP={'mo' 'OTRDMP' 0 []}';%Dump screen
WSDUMP={'mo' 'WSDUMP' 0 []}';
%IMDUMP  : IMON, TYPE="BCS toroid" BCS toroid in dumpline after Y-bends
%IMBCS4  : IMON, TYPE="BCS toroid" BCS comparator toroid (ACM) in dumpline after Y-bends
MIMDUMP={'mo' 'MIMDUMP' 0 []}';
MIMBCS4={'mo' 'MIMBCS4' 0 []}';
BTM1L={'mo' 'BTM1L' 0 []}';%Burn-Through-Monitor behind PCPM1L
BTM2L={'mo' 'BTM2L' 0 []}';%Burn-Through-Monitor behind PCPM2L
DUMPFACE={'mo' 'DUMPFACE' 0 []}';%entrance face of main e- dump
BTMDUMP={'mo' 'BTMDUMP' 0 []}';%Burn-Through-Monitor of main e- dump
MQDMP={'mo' 'MQDMP' 0 []}';
DMPEND={'mo' 'DMPEND' 0 []}';
DBMARK38={'mo' 'DBMARK38' 0 []}';%end of final undulator dump
ARODMP1H =  -ARODMP1S;
ARODMP2H =  -ARODMP2S;
RODMP1H={'ro' 'RODMP1H' 0 [-(ARODMP1H)]}';
RODMP2H={'ro' 'RODMP2H' 0 [-(ARODMP2H)]}';
DUMPLINE=[BEGDMPH_2,RODMP1H,BYDSHA,BYDSHB,DS1,BYD1A,BYD1B,DS,BYD2A,BYD2B,DS,BYD3A,BYD3B,DD1A,PCPM1L,BTM1L,DD1B,MIMDUMP,DD1C,MIMBCS4,DD1D,YCDD,DD1E,PCPM2L,BTM2L,DD1F,QDMP1,QDMP1,DD12A,BPMQD,DD12B,MQDMP,DD12C,QDMP2,QDMP2,DD2A,XCDD,DD2B,DD2C,DD3A,BPMDD,DD3B,OTRDMP,DWSDUMPA,RFBDD,DWSDUMPB,WSDUMP,DWSDUMPC,RODMP2H,DUMPFACE,DDUMP,DMPEND,BTMDUMP,DBMARK38,ENDDMPH_2];

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc undulator and undulator extension
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 10-MAY-2019, M. Woodley
%  * move BLM's in HXR cells from before undulator to after per H.-D. Nuhn
% 30-APR-2019, M. Woodley
%  * remove M1, M2, and YAGBRAG from HXRSS self-seeding chicane per H.-D. Nuhn
% 19-FEB-2019, M. Woodley
%  * move SXRSS self-seeding chicane from undulator cell 33 to cell 35 per
%    G. Marcus (DCR_2018-012)
%  * move undulator 35 and associated devices to cell 33 (replace "35" with
%    "33" in device names)
% ------------------------------------------------------------------------------
% 08-JAN-2019, M. Woodley
%  * define HXRSS and SXRSS chicane bend angles (rather than integrated
%    strengths) to allow constant R56 when energy changes
%  * set nominal SXRSS beam offset to +17.0 mm per G. Marcus
%  * set nominal HXRSS R56 to +15.0 um per G. Marcus
% ------------------------------------------------------------------------------
% 27-NOV-2018, M. Woodley
%  * move definition of Eu to LCLS2sc_master.xsif and LCLS2cu_master.xsif
%    (for BMAD compatability)
% 29-MAY-2018, M. Woodley
%  * install LCLS HXRSS self-seeding chicane in HXR cell #28 per
%    LCLSII-3.2-PR-0102-R1; chicane is off for high-rate beams from SC linac
%  * install LCLS SXRSS self-seeding chicane in SXR cell #33 per
%    LCLSII-3.2-PR-0101-R0
% 30-APR-2018, M. Woodley
%  * set aperture radius of PCPM0/PCPM0B to 1.75 cm (circular) per RP-14-15-R5
%    section 4.3 (two permanant magnet bends in SXR safety dump line)
% 27-APR-2018, M. Woodley
%  * add a second set of beam phase monitors 1.5 m u/s of original set per
%    C. Xu (TID); original cavities (PH31-32,PH31B-32B, for low-rate beam) are
%    2805 MHz ... new cavities (PH33-34,PH33B-34B, for high-rate beam) will be
%    2604 MHz; all but original LCLS cavities (PH31-32) are deferred
% ------------------------------------------------------------------------------
% 22-JAN-2018, M. Woodley
%  * move SXR phase shifters 5 mm upstream per D. Bruch
% 20-DEC-2017, M. Woodley
%  * defer (level 0) PH31b and PH32b
% 04-DEC-2017, M. Woodley
%  * define dzHXTES parameter to adjust lengths of DUE5e and DDLWALL by ~0.7 um
%    to set BSY-Z of MDLWALL to exactly 685 m (to align with HXR XTES system)
%  * define drifts DUE5eB and DDLWALLB (DUE5e and DDLWALL on SXR side)
%  * define dzSXTES parameter to adjust lengths of DUE5eB and DDLWALLB by ~0.7 um
%    to set BSY-Z of MDLWALLb to exactly 685 m (to align with SXR XTES system)
% ------------------------------------------------------------------------------
% 06-SEP-2017, Y. Nosochkov
%  * move PH32, PH32B 0.012 m upstream to Z = 674.062492 (BSY coordinates)
%    (M. Kosovsky)
%  * change length of DU2h drift from negative value to zero, adjust lengths
%    of nearby drifts to keep the same device positions
%  * update definition of phase shifters in undulators (H.-D. Nuhn),
%    increase phase shifter period to 75 mm (SXR) and 45 mm (HXR),
%    define phase shifter undulator K-parameter through phase integral (PI)
%  * note: the present setting of the integrated field IntgHX of HXR undulator
%    quadrupoles is 12 kG. Per H.-D. Nuhn, it needs to be increased to 26 kG.
%    This however, does not match well with the dumpline optics at 4 GeV.
%    Additional quad(s) may need to be included downstream of the undulator
%    or in the dumpline -- to be studied
% 05-SEP-2017, M. Woodley
%  * move IntgSX and IntgHX defn's to LCLS2sc_main.xsif and LCLS2cu_main.xsif
%  * move XbandF definition to common.xsif
% ------------------------------------------------------------------------------
% 05-MAY-2017, M. Woodley
%  * Beam Loss Monitors (BLMS*, BLMH*): keyword=INST
% ------------------------------------------------------------------------------
% 24-FEB-2017, Y. Nosochkov
%  * update device positions in the undulator cells (D. Bruch)
%    note that RFBHX12 moves upstream into LTUH
%  * remove RFBHX49 (D. Bruch, H-D. Nuhn)
%  * move RFBHX51, RFBSX51 0.057 m upstream (D. Bruch)
%  * move BTMQUEB 0.1016 m downstream (M. Owens)
% ------------------------------------------------------------------------------
% 02-NOV-2016, Y. Nosochkov
%  * specify half-aperture of PCTCX, PCTCXB to be 4.5 mm (per deck note)
% ------------------------------------------------------------------------------
% 24-JUN-2016, Y. Nosochkov
%  * defer PCTCXB, SPTCXB to level @1 (P. Emma)
%  * change the type of existing BPMUE1, BPMUE2 from Stripline-1 to
%    Stripline-13 (M. Woodley, Alev)
%  * change the type of BPMUE1B, BPMUE2B from Stripline-1 to Stripline-5 to
%    fit the 2Q10 quads
%  * remove existing toroids IMUNDO, IMBCS3 as they are not compatible
%    with SCRF beam (S. Mao, P. Emma)
%  * remove deferred IMUNDOB (S. Mao)
%  * update positions of BPMUE1&2, BPMUE1B&2B and BTMQUEB (M. Owens)
% ------------------------------------------------------------------------------
% 26-FEB-2016, Y. Nosochkov
%  * replace the HXR undulator with HGVPU undulator (D. Bruch, M. Rowen)
%  * VPU undulator length: 3.373968 m
%  * VPU undulator cell length: 4.01266666667 m
%  * same undulator period and K-value in VPU as before (H-D. Nuhn)
%  * move the RFBHX16, previously located upstream of undulator, to just after
%    the VPU undulator and rename to RFBHX49 -- this keeps the number
%    of RFBPMs unchanged
% 26-FEB-2016, M. Woodley
%  * remove SEQnn MARKers
%  * define new areas: UEH (HXR end to BYD1) and UES (SXR end to BYD1B)
% ------------------------------------------------------------------------------
% 24-AUG-2015, Y. Nosochkov
%  * adjust positions of BPMUE1, BPMUE2 (per M. Owens)
%  * match dumpline optics to new TCAV/OTR constraints (per Y. Ding)
% ------------------------------------------------------------------------------
% 19-JUN-2015, Y. Nosochkov
%  * assign IMUNDO, IMUNDOb to be BCS current monitors
% 20-MAY-2015, Y. Nosochkov
%  * change the status of BPMUE1, BPMUE2, BPMUE1B, BPMUE2B from deferred
%    to baseline
%  * update aperture of PCPM0, PCPM0B (per Shanjie)
%  * defer THz Be foils TRUE1, TRUE1B at level @5 (per Tor and A. Fisher)
% ------------------------------------------------------------------------------
% 20-MAR-2015, M. Woodley
%  * assign TYPEs to BCS devices ... defer at level 0
% 12-MAR-2015, Y. Nosochkov
%  * change type of QUE1B, QUE2B from "1.97Q10" to "2Q10"
% ------------------------------------------------------------------------------
% 12-DEC-2014, M. Woodley
%  * change some RFBs (defer=2) to BPMs (defer=0)
%  * assign BPM TYPE attributes per PRD LCLSII-2.4-PR-0136
% 09-DEC-2014, Y. Nosochkov
%  * restore dumpline toroid IMBCS3 in HXR (per LCLSII-2.4-PR-0107)
%  * assign the non-baseline level "4" to TRUE1b (Be foil, THz) in SXR
%  * change type of QUE1b, QUE2b to "1.97Q10"
%  * change type of undulator quads to "0.433Q3.1" (per J. Amann)
%  * rename BTM0, BTM0b to BTMQUE, BTMQUEb (per Shanjie Xiao)
%  * add BTM0, BTM0b downstream of PCPM0 and PCPM0b (per Shanjie Xiao)
%  * change stripline to RF bpms in the SXR undulator extension:
%    BPMSX16 -> RFBSX16, BPMSX19 -> RFBSX19, BPMSX21 -> RFBSX21
%  * add PH31, PH32, PH31b, PH32b post-undulator phase measurement cavities
% ------------------------------------------------------------------------------
% 13-OCT-2014, Y. Nosochkov
%  * remove RFBUE3, RFBUE3B in the dumplines
%  * replace XCUE1 -> YCUE1, YCUE2 -> XCUE2, XCUE1b -> YCUE1b, YCUE2b -> XCUE2b
%  * add marker for dumpline wall
% 10-OCT-2014, Y. Nosochkov
%  * update TYPE of (6) RFBPMs to indicate the non-baseline level "0"
% 07-AUG-2014, M. Woodley
%  * decorate device TYPE attributes to indicate non-baseline status
% 31-JUL-2014, Y. Nosochkov
%  * remove IMBCS3, IMBCS3b
% 23-JUL-2014, Y. Nosochkov
%  * remove SXR extension cell SXCEL15, use this space (4.4 m) for moving
%    TDUNDb 2.8 m downstream,
%  * replace the quads QSXh15 and QSXh22 with QSXh16 and QSXh21
% 17-JUN-2014, Y. Nosochkov
%  * replace all stripline BPMs downstream of the undulators with RFBPMs
%    (per J. Frisch)
%  * change type of IMUNDO, IMUNDOB from toroid to beam current monitor
%    (per J. Frisch)
% 21-MAY-2014, Y. Nosochkov
%  * move marker points ENDSXR, BEGDMPS and ENDHXR, BEGDMPH to the downstream
%    end of RFBSX51 and RFBHX51 in order to include these RFBPMs into the
%    SXR and HXR areas as defined in PRD LCLSII-2.1-PR-0134
%    (per request from D. Hanquist)
% 02-MAY-2014, M. Woodley
%  * add MTCX01 and MTCX01b MARKERs (for ELEGANT WATCH points)
%  * explicitly define R55=R66=1 in MATRs (for translation to BMAD)
% 24-APR-2014, Y. Nosochkov
%  * include place holder DBKXDMPS(H) for dumpline x-kicker (per J. Frisch)
% 22-APR-2014, Y. Nosochkov
%  * restore T-cavities TCX01B, TCX02B in SXR dumpline (per J. Frisch)
% 07-APR-2014, M. Woodley
%  * move undulator phase shifter definitions earlier in this file to avoid
%    using LPSSH and LPSHX parameters before they are defined
% ------------------------------------------------------------------------------
% 31-MAR-2014, M. Woodley
%  * element names changed to conform to nomenclature PRD
% 26-MAR-2014, Y. Nosochkov
%  * put phase shifter and RFBPM positions back to 03/14 version
% 21-MAR-2014, Y. Nosochkov
%  * update positions of phase shifters and RFBPMs in undulator cells
%  * add Y-corrector to each undulator
%  * update phase shifter parameters (per H-D. Nuhn)
% 07-MAR-2014, Y. Nosochkov
%  * remove transverse deflecting cavities from SXR dumpline
%  * slightly adjust Z-position of dumpline bends
% 06-MAR-2014, Y. Nosochkov
%  * minor matching update
% ------------------------------------------------------------------------------
% 28-FEB-2014, Y. Nosochkov
%  * reduce undulator break length from 1.15 m to 1.0 m for cell length of 4.4 m
%    use cell numbering from 15 to 50 (this includes cells with and without
%    undulators)
%    put SXR undulators in cells 26-32, 34-47
%    put HXR undulators in cells 17-23, 25-31, 33-50
%    the SXR cell-33 and HXR cells 24 and 32 have only quad and RFBPM --
%    these cells will be used for self-seeding
%    reduce length of undulator quadrupole to 0.084 m
%    add one extra RFBPM about ~1 m after end of cell-50 in SXR and HXR
%    add two RFBPMs in two cells upstream of SXR and HXR undulators
%    use the last undulator quadrupole in cell-50 for matching to dump line
% 17-JAN-2014, Y. Nosochkov
%  * minor matching update
% 18-DEC-2013, Y. Nosochkov
%  * minor matching update
% 16-DEC-2013, Y. Nosochkov
%  * minor matching update
% 23-OCT-2013, Y. Nosochkov
%  * change the number of SXR undulator cells to 22 and the number of
%    SXR extension cells to 12
%  * change the number of HXR undulator cells to 34
%  * change undulator cell length to 4.55 m
%  * update undulator parameters and undulator quad field (per H.-D. Nuhn)
%  * new position of SXRTERM, HXRTERM is at Z'=669.586491 m in BSY coordinates
%  * move QUE1, QUE1B 4.0 m downstream
%  * adjust strengths in the last two undulator quads to help with
%    beta match in the dumpline
% 17-OCT-2013, Y. Nosochkov
%  * change quadrupole type of QUE1B, QUE2B, QDMP1B, QDMP2B to 3.94Q17
% ------------------------------------------------------------------------------
% ==============================================================================
% SXR undulator and extension (north)
% ==============================================================================
% ------------------------------------------------------------------------------
% SXR undulator PPM phase shifter
% - Author: Heinz-Dieter Nuhn, Stanford Linear Accelerator Center
% - Last edited September 06, 2017
% - 10.0 mm miminum Undulator Gap
% ------------------------------------------------------------------------------
% - LPSSX  = SXR Phase Shifter length
% - luPSSX = SXR Phase Shifter period
% - PIPSSX = SXR Phase Shifter phase integral
% - KPSSX  = SXR Phase Shifter Undulator parameter (rms); range 1.34-3.59
% - kQPSSX = natural SXR Phase Shifter undulator focusing "k" in y-plane
% ------------------------------------------------------------------------------
%Eu     :  definition moved to LCLS2sc_master.xsif and LCLS2cu_master.xsif
GAMU =  EU/MC2                             ;%Lorentz energy factor in undulator [ ]
LPSSX =  0.0825                             ;%m
LUPSSX =  0.075                              ;%m
LPSSXH =  LPSSX/2;
PIPSSX =  3814                               ;%T^2mm^3 (180-3814)
KPSSX =  1.E-9*CLIGHT/MC2*sqrt(2.E-9*PIPSSX/LUPSSX);
KQPSSX =  (KPSSX*2*PI/LUPSSX/sqrt(2)/GAMU)^2 ;%m^-2
PSSXH={'un' 'PSSXH' LPSSXH [KQPSSX LUPSSX 1]}';
% ------------------------------------------------------------------------------
% SXR drifts
% ------------------------------------------------------------------------------
LDUSEGS =  3.4;
LDU1S =  0.1;
LDU2S =  0.03;
LDU3S =  0.25-LPSSXH -0.04 -0.005;
LDU4S =  (0.25-LPSSXH-0.5*LQU)/2 +0.04 +0.005;
LDU5S =  (0.25-LPSSXH-0.5*LQU)/2;
LDU6S =  0.12-LQU/2-LRFBUB/2 +0.01;
LDU7S =  0.25-LRFBUB/2 -0.01;
DLDU0S =  0.0 ;%fine tune Z in undulator
LDU0S =  2.1359-LDU6S-LDU7S-LQU +DLDU0S;
DU0S={'dr' '' LDU0S []}';
DU1S={'dr' '' LDU1S []}';
DU2S={'dr' '' LDU2S []}';
DU3S={'dr' '' LDU3S []}';
DU4S={'dr' '' LDU4S []}';
DU5S={'dr' '' LDU5S []}';
DU6S={'dr' '' LDU6S []}';
DU7S={'dr' '' LDU7S []}';
DUE1AB={'dr' '' 0.9-LRFBUB-0.057 []}';
DUE1E={'dr' '' 0.057 []}';
% ------------------------------------------------------------------------------
% SXR extension quads
% ------------------------------------------------------------------------------
% note: the below K-values are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQSX16 =   0.589502458599 ;% 0.584170476419 
KQSX19 =  -0.91531741252  ;%-0.916029555737 
KQSX21 =   1.109876931688 ;% 1.112214118849 
KQSX24 =  -1.085714742294 ;%-1.119664961437 
QSXH16={'qu' 'QSXH16' LQU/2 [KQSX16 0]}';
QSXH19={'qu' 'QSXH19' LQU/2 [KQSX19 0]}';
QSXH21={'qu' 'QSXH21' LQU/2 [KQSX21 0]}';
QSXH24={'qu' 'QSXH24' LQU/2 [KQSX24 0]}';
% ------------------------------------------------------------------------------
% SXR extension X-steering coils in quads
% ------------------------------------------------------------------------------
XCSX16={'mo' 'XCSX16' 0 []}';
XCSX19={'mo' 'XCSX19' 0 []}';
XCSX21={'mo' 'XCSX21' 0 []}';
XCSX24={'mo' 'XCSX24' 0 []}';
% ------------------------------------------------------------------------------
% SXR extension Y-steering coils in quads
% ------------------------------------------------------------------------------
YCSX16={'mo' 'YCSX16' 0 []}';
YCSX19={'mo' 'YCSX19' 0 []}';
YCSX21={'mo' 'YCSX21' 0 []}';
YCSX24={'mo' 'YCSX24' 0 []}';
% ------------------------------------------------------------------------------
% SXR extension BPMs
% ------------------------------------------------------------------------------
RFBSX16={'mo' 'RFBSX16' LRFBUB []}';
DRFBS17={'dr' '' LRFBUB []}';
DRFBS18={'dr' '' LRFBUB []}';
RFBSX19={'mo' 'RFBSX19' LRFBUB []}';
DRFBS20={'dr' '' LRFBUB []}';
RFBSX21={'mo' 'RFBSX21' LRFBUB []}';
DRFBS22={'dr' '' LRFBUB []}';
DRFBS23={'dr' '' LRFBUB []}';
RFBSX24={'mo' 'RFBSX24' LRFBUB []}';
RFBSX25={'mo' 'RFBSX25' LRFBUB []}';
SXXSTART={'mo' 'SXXSTART' 0 []}';%start of soft X-ray extension system
SXXTERM={'mo' 'SXXTERM' 0 []}';%end of soft X-ray extension system
SXRSTART={'mo' 'SXRSTART' 0 []}';%start of undulator system
RWWAKE5S={'mo' 'RWWAKE5S' 0 []}';%SXR beampipe wake applied here
SXRTERM={'mo' 'SXRTERM' 0 []}';%~end of undulator system
MUQS={'mo' 'MUQS' 0 []}';
MPHS={'mo' 'MPHS' 0 []}';
QSXBLK16=[QSXH16,XCSX16,YCSX16,QSXH16];
DQSXBL17={'dr' '' LQU []}';
DQSXBL18={'dr' '' LQU []}';
QSXBLK19=[QSXH19,XCSX19,YCSX19,QSXH19];
DQSXBL20={'dr' '' LQU []}';
QSXBLK21=[QSXH21,XCSX21,YCSX21,QSXH21];
DQSXBL22={'dr' '' LQU []}';
DQSXBL23={'dr' '' LQU []}';
QSXBLK24=[QSXH24,XCSX24,YCSX24,QSXH24];
DQSXBL25={'dr' '' LQU []}';
DPHSS17={'dr' '' LPSSX []}';
DPHSS18={'dr' '' LPSSX []}';
DPHSS19={'dr' '' LPSSX []}';
DPHSS20={'dr' '' LPSSX []}';
DPHSS21={'dr' '' LPSSX []}';
DPHSS22={'dr' '' LPSSX []}';
DPHSS23={'dr' '' LPSSX []}';
DPHSS24={'dr' '' LPSSX []}';
DPHSS25={'dr' '' LPSSX []}';
SXBRK17=[DU3S,DPHSS17,DU4S,        DU5S,DQSXBL17,DU6S,DRFBS17,DU7S];
SXBRK18=[DU3S,DPHSS18,DU4S,        DU5S,DQSXBL18,DU6S,DRFBS18,DU7S];
SXBRK19=[DU3S,DPHSS19,DU4S,        DU5S,QSXBLK19,DU6S,RFBSX19,DU7S];
SXBRK20=[DU3S,DPHSS20,DU4S,        DU5S,DQSXBL20,DU6S,DRFBS20,DU7S];
SXBRK21=[DU3S,DPHSS21,DU4S,        DU5S,QSXBLK21,DU6S,RFBSX21,DU7S];
SXBRK22=[DU3S,DPHSS22,DU4S,        DU5S,DQSXBL22,DU6S,DRFBS22,DU7S];
SXBRK23=[DU3S,DPHSS23,DU4S,        DU5S,DQSXBL23,DU6S,DRFBS23,DU7S];
SXBRK24=[DU3S,DPHSS24,DU4S,        DU5S,QSXBLK24,DU6S,RFBSX24,DU7S];
SXBRK25=[DU3S,DPHSS25,DU4S,        DU5S,DQSXBL25,DU6S,RFBSX25,DU7S];
DUSEGS17={'dr' '' LDUSEGS []}';
DUSEGS18={'dr' '' LDUSEGS []}';
DUSEGS19={'dr' '' LDUSEGS []}';
DUSEGS20={'dr' '' LDUSEGS []}';
DUSEGS21={'dr' '' LDUSEGS []}';
DUSEGS22={'dr' '' LDUSEGS []}';
DUSEGS23={'dr' '' LDUSEGS []}';
DUSEGS24={'dr' '' LDUSEGS []}';
DUSEGS25={'dr' '' LDUSEGS []}';
SXCEL17=[DU1S,       DU2S,DUSEGS17,SXBRK17];
SXCEL18=[DU1S,       DU2S,DUSEGS18,SXBRK18];
SXCEL19=[DU1S,       DU2S,DUSEGS19,SXBRK19];%Q+RFBPM
SXCEL20=[DU1S,       DU2S,DUSEGS20,SXBRK20];
SXCEL21=[DU1S,       DU2S,DUSEGS21,SXBRK21];%Q+RFBPM
SXCEL22=[DU1S,       DU2S,DUSEGS22,SXBRK22];
SXCEL23=[DU1S,       DU2S,DUSEGS23,SXBRK23];
SXCEL24=[DU1S,       DU2S,DUSEGS24,SXBRK24];%Q+RFBPM
SXCEL25=[DU1S,       DU2S,DUSEGS25,SXBRK25];%RFBPM
SXRXX=[BEGUNDS,SXXSTART,DU0S,QSXBLK16,DU6S,RFBSX16,DU7S,SXCEL17,SXCEL18,SXCEL19,SXCEL20,SXCEL21,SXCEL22,SXCEL23,SXCEL24,SXCEL25,SXXTERM];
% ------------------------------------------------------------------------------
% SXR undulator
% ------------------------------------------------------------------------------
% - Author: Heinz-Dieter Nuhn, Stanford Linear Accelerator Center
% - Last edited Mar 03, 2014
% - 7.2 mm miminum Undulator Gap; only constant break length each
% - include natural vertical focusing over all but edge terminations
% ------------------------------------------------------------------------------
% - IntgSX  = integrated quadrupole gradient
% - GQFSX   = QF and QD gradients can be made different to compensate for
%             undulator focussing ...
% - GQDSX   = ... but since undulator focussing depends on gamma^2, compensation
%             will only work for one energy
% - kQFSX   = QF undulator quadrupole focusing "k"
% - kQDSX   = QD undulator quadrupole focusing "k"
% - LDUSEGS = SXR Undulator segment length
% - luSXU   = SXR Undulator period
% - NpSXU   = SXR Undulator period count
% - LSXUCR  = SXR Undulator magnetic length
% - LSXUe   = SXR Undulator spacing between magnet array and strongback end
% - KSXU    = SXR Undulator parameter (rms); range 2-5.5
% - kQSX    = natural SXR undulator focusing "k" in y-plane
% ------------------------------------------------------------------------------
%IntgSX :   definition moved to LCLS2sc_main.xsif and LCLS2cu_main.xsif
GQFSX =   INTGSX/LQU/10*1.0           ;%T/m
GQDSX =  -INTGSX/LQU/10*1.0           ;%T/m
KQFSX =   1.E-9*GQFSX*CLIGHT/GAMU/MC2 ;%m^-2
KQDSX =   1.E-9*GQDSX*CLIGHT/GAMU/MC2 ;%m^-2
KQDSXM =  -0.266792876891 ;%-0.406434161462
QSXH26={'qu' 'QSXH26' LQU/2 [KQFSX 0]}';
QSXH27={'qu' 'QSXH27' LQU/2 [KQDSX 0]}';
QSXH28={'qu' 'QSXH28' LQU/2 [KQFSX 0]}';
QSXH29={'qu' 'QSXH29' LQU/2 [KQDSX 0]}';
QSXH30={'qu' 'QSXH30' LQU/2 [KQFSX 0]}';
QSXH31={'qu' 'QSXH31' LQU/2 [KQDSX 0]}';
QSXH32={'qu' 'QSXH32' LQU/2 [KQFSX 0]}';
QSXH33={'qu' 'QSXH33' LQU/2 [KQDSX 0]}';
QSXH34={'qu' 'QSXH34' LQU/2 [KQFSX 0]}';
QSXH35={'qu' 'QSXH35' LQU/2 [KQDSX 0]}';
QSXH36={'qu' 'QSXH36' LQU/2 [KQFSX 0]}';
QSXH37={'qu' 'QSXH37' LQU/2 [KQDSX 0]}';
QSXH38={'qu' 'QSXH38' LQU/2 [KQFSX 0]}';
QSXH39={'qu' 'QSXH39' LQU/2 [KQDSX 0]}';
QSXH40={'qu' 'QSXH40' LQU/2 [KQFSX 0]}';
QSXH41={'qu' 'QSXH41' LQU/2 [KQDSX 0]}';
QSXH42={'qu' 'QSXH42' LQU/2 [KQFSX 0]}';
QSXH43={'qu' 'QSXH43' LQU/2 [KQDSX 0]}';
QSXH44={'qu' 'QSXH44' LQU/2 [KQFSX 0]}';
QSXH45={'qu' 'QSXH45' LQU/2 [KQDSX 0]}';
QSXH46={'qu' 'QSXH46' LQU/2 [KQFSX 0]}';
QSXH47={'qu' 'QSXH47' LQU/2 [KQDSXM 0]}';
LUSXU =  0.039                            ;%m
NPSXU =  87;
LSXUCR =  LUSXU*NPSXU                      ;%m
LSXUE =  (LDUSEGS-LSXUCR)/2               ;%m
LSXUH =  LSXUCR/2;
KSXU =  5.0;
KQSX =  (KSXU*2*PI/LUSXU/sqrt(2)/GAMU)^2 ;%m^-2
UMASXH={'un' 'UMASXH' LSXUH [KQSX LUSXU 1]}';
UMASXH26=UMASXH;UMASXH26{2}='UMASXH26';
UMASXH27=UMASXH;UMASXH27{2}='UMASXH27';
UMASXH28=UMASXH;UMASXH28{2}='UMASXH28';
UMASXH29=UMASXH;UMASXH29{2}='UMASXH29';
UMASXH30=UMASXH;UMASXH30{2}='UMASXH30';
UMASXH31=UMASXH;UMASXH31{2}='UMASXH31';
UMASXH32=UMASXH;UMASXH32{2}='UMASXH32';
UMASXH33=UMASXH;UMASXH33{2}='UMASXH33';
UMASXH34=UMASXH;UMASXH34{2}='UMASXH34';
UMASXH36=UMASXH;UMASXH36{2}='UMASXH36';
UMASXH37=UMASXH;UMASXH37{2}='UMASXH37';
UMASXH38=UMASXH;UMASXH38{2}='UMASXH38';
UMASXH39=UMASXH;UMASXH39{2}='UMASXH39';
UMASXH40=UMASXH;UMASXH40{2}='UMASXH40';
UMASXH41=UMASXH;UMASXH41{2}='UMASXH41';
UMASXH42=UMASXH;UMASXH42{2}='UMASXH42';
UMASXH43=UMASXH;UMASXH43{2}='UMASXH43';
UMASXH44=UMASXH;UMASXH44{2}='UMASXH44';
UMASXH45=UMASXH;UMASXH45{2}='UMASXH45';
UMASXH46=UMASXH;UMASXH46{2}='UMASXH46';
UMASXH47=UMASXH;UMASXH47{2}='UMASXH47';
% ------------------------------------------------------------------------------
% SXR undulator X-steering coils in quads
% ------------------------------------------------------------------------------
XCSX26={'mo' 'XCSX26' 0 []}';
XCSX27={'mo' 'XCSX27' 0 []}';
XCSX28={'mo' 'XCSX28' 0 []}';
XCSX29={'mo' 'XCSX29' 0 []}';
XCSX30={'mo' 'XCSX30' 0 []}';
XCSX31={'mo' 'XCSX31' 0 []}';
XCSX32={'mo' 'XCSX32' 0 []}';
XCSX33={'mo' 'XCSX33' 0 []}';
XCSX34={'mo' 'XCSX34' 0 []}';
XCSX35={'mo' 'XCSX35' 0 []}';
XCSX36={'mo' 'XCSX36' 0 []}';
XCSX37={'mo' 'XCSX37' 0 []}';
XCSX38={'mo' 'XCSX38' 0 []}';
XCSX39={'mo' 'XCSX39' 0 []}';
XCSX40={'mo' 'XCSX40' 0 []}';
XCSX41={'mo' 'XCSX41' 0 []}';
XCSX42={'mo' 'XCSX42' 0 []}';
XCSX43={'mo' 'XCSX43' 0 []}';
XCSX44={'mo' 'XCSX44' 0 []}';
XCSX45={'mo' 'XCSX45' 0 []}';
XCSX46={'mo' 'XCSX46' 0 []}';
XCSX47={'mo' 'XCSX47' 0 []}';
% ------------------------------------------------------------------------------
% SXR undulator Y-steering coils in quads
% ------------------------------------------------------------------------------
YCSX26={'mo' 'YCSX26' 0 []}';
YCSX27={'mo' 'YCSX27' 0 []}';
YCSX28={'mo' 'YCSX28' 0 []}';
YCSX29={'mo' 'YCSX29' 0 []}';
YCSX30={'mo' 'YCSX30' 0 []}';
YCSX31={'mo' 'YCSX31' 0 []}';
YCSX32={'mo' 'YCSX32' 0 []}';
YCSX33={'mo' 'YCSX33' 0 []}';
YCSX34={'mo' 'YCSX34' 0 []}';
YCSX35={'mo' 'YCSX35' 0 []}';
YCSX36={'mo' 'YCSX36' 0 []}';
YCSX37={'mo' 'YCSX37' 0 []}';
YCSX38={'mo' 'YCSX38' 0 []}';
YCSX39={'mo' 'YCSX39' 0 []}';
YCSX40={'mo' 'YCSX40' 0 []}';
YCSX41={'mo' 'YCSX41' 0 []}';
YCSX42={'mo' 'YCSX42' 0 []}';
YCSX43={'mo' 'YCSX43' 0 []}';
YCSX44={'mo' 'YCSX44' 0 []}';
YCSX45={'mo' 'YCSX45' 0 []}';
YCSX46={'mo' 'YCSX46' 0 []}';
YCSX47={'mo' 'YCSX47' 0 []}';
% ------------------------------------------------------------------------------
% SXR undulator X-steering coils in undulator segments
% ------------------------------------------------------------------------------
XCSU26={'mo' 'XCSU26' 0 []}';
XCSU27={'mo' 'XCSU27' 0 []}';
XCSU28={'mo' 'XCSU28' 0 []}';
XCSU29={'mo' 'XCSU29' 0 []}';
XCSU30={'mo' 'XCSU30' 0 []}';
XCSU31={'mo' 'XCSU31' 0 []}';
XCSU32={'mo' 'XCSU32' 0 []}';
XCSU33={'mo' 'XCSU33' 0 []}';
XCSU34={'mo' 'XCSU34' 0 []}';
XCSU36={'mo' 'XCSU36' 0 []}';
XCSU37={'mo' 'XCSU37' 0 []}';
XCSU38={'mo' 'XCSU38' 0 []}';
XCSU39={'mo' 'XCSU39' 0 []}';
XCSU40={'mo' 'XCSU40' 0 []}';
XCSU41={'mo' 'XCSU41' 0 []}';
XCSU42={'mo' 'XCSU42' 0 []}';
XCSU43={'mo' 'XCSU43' 0 []}';
XCSU44={'mo' 'XCSU44' 0 []}';
XCSU45={'mo' 'XCSU45' 0 []}';
XCSU46={'mo' 'XCSU46' 0 []}';
XCSU47={'mo' 'XCSU47' 0 []}';
% ------------------------------------------------------------------------------
% SXR undulator Y-steering coils in undulator segments
% ------------------------------------------------------------------------------
YCSU26={'mo' 'YCSU26' 0 []}';
YCSU27={'mo' 'YCSU27' 0 []}';
YCSU28={'mo' 'YCSU28' 0 []}';
YCSU29={'mo' 'YCSU29' 0 []}';
YCSU30={'mo' 'YCSU30' 0 []}';
YCSU31={'mo' 'YCSU31' 0 []}';
YCSU32={'mo' 'YCSU32' 0 []}';
YCSU33={'mo' 'YCSU33' 0 []}';
YCSU34={'mo' 'YCSU34' 0 []}';
YCSU36={'mo' 'YCSU36' 0 []}';
YCSU37={'mo' 'YCSU37' 0 []}';
YCSU38={'mo' 'YCSU38' 0 []}';
YCSU39={'mo' 'YCSU39' 0 []}';
YCSU40={'mo' 'YCSU40' 0 []}';
YCSU41={'mo' 'YCSU41' 0 []}';
YCSU42={'mo' 'YCSU42' 0 []}';
YCSU43={'mo' 'YCSU43' 0 []}';
YCSU44={'mo' 'YCSU44' 0 []}';
YCSU45={'mo' 'YCSU45' 0 []}';
YCSU46={'mo' 'YCSU46' 0 []}';
YCSU47={'mo' 'YCSU47' 0 []}';
% ------------------------------------------------------------------------------
% SXR undulator BPMs
% ------------------------------------------------------------------------------
RFBSX26={'mo' 'RFBSX26' LRFBUB []}';
RFBSX27={'mo' 'RFBSX27' LRFBUB []}';
RFBSX28={'mo' 'RFBSX28' LRFBUB []}';
RFBSX29={'mo' 'RFBSX29' LRFBUB []}';
RFBSX30={'mo' 'RFBSX30' LRFBUB []}';
RFBSX31={'mo' 'RFBSX31' LRFBUB []}';
RFBSX32={'mo' 'RFBSX32' LRFBUB []}';
RFBSX33={'mo' 'RFBSX33' LRFBUB []}';
RFBSX34={'mo' 'RFBSX34' LRFBUB []}';
RFBSX35={'mo' 'RFBSX35' LRFBUB []}';
RFBSX36={'mo' 'RFBSX36' LRFBUB []}';
RFBSX37={'mo' 'RFBSX37' LRFBUB []}';
RFBSX38={'mo' 'RFBSX38' LRFBUB []}';
RFBSX39={'mo' 'RFBSX39' LRFBUB []}';
RFBSX40={'mo' 'RFBSX40' LRFBUB []}';
RFBSX41={'mo' 'RFBSX41' LRFBUB []}';
RFBSX42={'mo' 'RFBSX42' LRFBUB []}';
RFBSX43={'mo' 'RFBSX43' LRFBUB []}';
RFBSX44={'mo' 'RFBSX44' LRFBUB []}';
RFBSX45={'mo' 'RFBSX45' LRFBUB []}';
RFBSX46={'mo' 'RFBSX46' LRFBUB []}';
RFBSX47={'mo' 'RFBSX47' LRFBUB []}';
DRFBS48={'dr' '' LRFBUB []}';
DRFBS49={'dr' '' LRFBUB []}';
DRFBS50={'dr' '' LRFBUB []}';
RFBSX51={'mo' 'RFBSX51' LRFBUB []}';
% ------------------------------------------------------------------------------
% DTSXU  = SXU undulator segment small terminations modeled as drift
% ------------------------------------------------------------------------------
DTSXU={'dr' '' LSXUE []}';
% ------------------------------------------------------------------------------
% SXR undulator phase shifters
% ------------------------------------------------------------------------------
PHSSX26=[PSSXH,MPHS,PSSXH];
PHSSX27=[PSSXH,MPHS,PSSXH];
PHSSX28=[PSSXH,MPHS,PSSXH];
PHSSX29=[PSSXH,MPHS,PSSXH];
PHSSX30=[PSSXH,MPHS,PSSXH];
PHSSX31=[PSSXH,MPHS,PSSXH];
PHSSX32=[PSSXH,MPHS,PSSXH];
PHSSX33=[PSSXH,MPHS,PSSXH];
PHSSX34=[PSSXH,MPHS,PSSXH];
DPHSS35={'dr' '' LPSSX []}';
PHSSX36=[PSSXH,MPHS,PSSXH];
PHSSX37=[PSSXH,MPHS,PSSXH];
PHSSX38=[PSSXH,MPHS,PSSXH];
PHSSX39=[PSSXH,MPHS,PSSXH];
PHSSX40=[PSSXH,MPHS,PSSXH];
PHSSX41=[PSSXH,MPHS,PSSXH];
PHSSX42=[PSSXH,MPHS,PSSXH];
PHSSX43=[PSSXH,MPHS,PSSXH];
PHSSX44=[PSSXH,MPHS,PSSXH];
PHSSX45=[PSSXH,MPHS,PSSXH];
PHSSX46=[PSSXH,MPHS,PSSXH];
DPHSS47={'dr' '' LPSSX []}';
DPHSS48={'dr' '' LPSSX []}';
DPHSS49={'dr' '' LPSSX []}';
DPHSS50={'dr' '' LPSSX []}';
% ------------------------------------------------------------------------------
% SXR undulator inline valves, VAT Series 48
% ------------------------------------------------------------------------------
VVSXU26={'mo' 'VVSXU26' 0 []}';
VVSXU32={'mo' 'VVSXU32' 0 []}';
VVSXU38={'mo' 'VVSXU38' 0 []}';
VVSXU44={'mo' 'VVSXU44' 0 []}';
VVSXU47={'mo' 'VVSXU47' 0 []}';
% ------------------------------------------------------------------------------
% SXR undulator Beam Loss Monitors
% ------------------------------------------------------------------------------
BLMS26={'mo' 'BLMS26' 0 []}';
BLMS27={'mo' 'BLMS27' 0 []}';
BLMS28={'mo' 'BLMS28' 0 []}';
BLMS29={'mo' 'BLMS29' 0 []}';
BLMS30={'mo' 'BLMS30' 0 []}';
BLMS31={'mo' 'BLMS31' 0 []}';
BLMS32={'mo' 'BLMS32' 0 []}';
BLMS33={'mo' 'BLMS33' 0 []}';
BLMS34={'mo' 'BLMS34' 0 []}';
BLMS36={'mo' 'BLMS36' 0 []}';
BLMS37={'mo' 'BLMS37' 0 []}';
BLMS38={'mo' 'BLMS38' 0 []}';
BLMS39={'mo' 'BLMS39' 0 []}';
BLMS40={'mo' 'BLMS40' 0 []}';
BLMS41={'mo' 'BLMS41' 0 []}';
BLMS42={'mo' 'BLMS42' 0 []}';
BLMS43={'mo' 'BLMS43' 0 []}';
BLMS44={'mo' 'BLMS44' 0 []}';
BLMS45={'mo' 'BLMS45' 0 []}';
BLMS46={'mo' 'BLMS46' 0 []}';
BLMS47={'mo' 'BLMS47' 0 []}';
% ------------------------------------------------------------------------------
% SXRSS self-seeding chicane (LCLSII-3.2-PR-0101-R0 doesn't specify chicane
% requirements ... use LCLS PRD SLAC-I-081-101-003-00-R000)
% NOTE: chicane slides across the aisle from LCLS to SXR; now bends toward the
%       (north) wall, away from the aisle
% ------------------------------------------------------------------------------
% NOTEs:
% - in LCLS: BXSS1-4
% - nominal beam energy range is 3.35-4.74 GeV
% - minimum energy is 2.6 GeV; maximum energy is 5.2 GeV
% - Bmax = 2.56 kG-m @ 9 A (20 mm maximum beam offset)
% - use series approximation for sinc(x)=sin(x)/x to allow AB5=0
% - deflects toward +X (to the left/north/wall)
% - bends toward coil side
% - Dieter Walz designation: 1.575D14-C (pole-width rather than gap height)
% BCXSS1 gets an X-offset of +1.0 mm (toward the wall)
% BCXSS2 gets an X-offset of +9.7 mm (toward the wall)
% BCXSS3 gets an X-offset of +9.7 mm (toward the wall)
% BCXSS4 gets an X-offset of +1.0 mm (toward the wall)
BRHO5 =  CB*EU                             ;%beam rigidity at chicane (kG-m)
GB5 =  0.315*IN2M                        ;%full gap height [m]
ZB5 =  14.315*IN2M                       ;%on-axis effective length is 14" + gap (rule-of-thumb)
FB5 =  0.5                               ;%not measured
AB5 =  -0.014249046471*SETSXRSS          ;%bend angle (rad) for dX=+17.0 mm
BLB5 =  BRHO5*AB5                         ;%integrated strength (-1.901188 kG-m @ 4 GeV)
AB5_2 =  AB5*AB5;
AB5_4 =  AB5_2*AB5_2;
AB5_6 =  AB5_4*AB5_2;
SINCAB5 =  1-AB5_2/6+AB5_4/120-AB5_6/5040    ;%~sinc(AB5)=sin(AB5)/AB5
LB5 =  ZB5/SINCAB5                       ;%chicane bend path length (m)
AB5S =  asin(sin(AB5)/2)                  ;%"short" half chicane bend angle (rad)
AB5S_2 =  AB5S*AB5S;
AB5S_4 =  AB5S_2*AB5S_2;
AB5S_6 =  AB5S_4*AB5S_2;
SINCAB5S =  1-AB5S_2/6+AB5S_4/120-AB5S_6/5040 ;%~sinc(AB5s)=sin(AB5s)/AB5s
LB5S =  ZB5/(2*SINCAB5S)                  ;%"short" half chicane bend path length (m)
AB5L =  AB5-AB5S                          ;%"long" half chicane bend angle (rad)
LB5L =  LB5-LB5S                          ;%"long" half chicane bend path length (m)
BCXSS1A={'be' 'BCXSS1' LB5S [+AB5S GB5/2 0 0 0.5 0 0]}';
BCXSS1B={'be' 'BCXSS1' LB5L [+AB5L GB5/2 0 +AB5 0 0.5 0]}';
BCXSS2A={'be' 'BCXSS2' LB5L [-AB5L GB5/2 -AB5 0 0.5 0 0]}';
BCXSS2B={'be' 'BCXSS2' LB5S [-AB5S GB5/2 0 0 0 0.5 0]}';
BCXSS3A={'be' 'BCXSS3' LB5S [-AB5S GB5/2 0 0 0.5 0 0]}';
BCXSS3B={'be' 'BCXSS3' LB5L [-AB5L GB5/2 0 -AB5 0 0.5 0]}';
BCXSS4A={'be' 'BCXSS4' LB5L [+AB5L GB5/2 +AB5 0 0.5 0 0]}';
BCXSS4B={'be' 'BCXSS4' LB5S [+AB5S GB5/2 0 0 0 0.5 0]}';
LSSSB2BO =  1.193 ;%outer bend center-to-center (PRD Table 3)
LSSSB2BI =  0.52  ;%inner bend center-to-center (PRD Table 3)
ZD1S =  LSSSB2BO-ZB5;
ZD1SA =  0.44;
ZD1SB =  0.049;
ZD1SC =  ZD1S-(ZD1SA+ZD1SB);
ZD1SD =  0.077;
ZD1SE =  0.185;
ZD1SF =  0.128;
ZD1SG =  ZD1S-(ZD1SD+ZD1SE+ZD1SF);
DMONOS={'dr' '' (3.4-2*LSSSB2BO-LSSSB2BI-ZB5)/2 []}';
D1SA={'dr' '' ZD1SA/cos(AB5) []}';
D1SB={'dr' '' ZD1SB/cos(AB5) []}';
D1SC={'dr' '' ZD1SC/cos(AB5) []}';
D1SD={'dr' '' ZD1SD/cos(AB5) []}';
D1SE={'dr' '' ZD1SE/cos(AB5) []}';
D1SF={'dr' '' ZD1SF/cos(AB5) []}';
D1SG={'dr' '' ZD1SG/cos(AB5) []}';
DCHS={'dr' '' (LSSSB2BI-ZB5)/2 []}';
SXRSSBEG={'mo' 'SXRSSBEG' 0 []}';
GSXS1={'mo' 'GSXS1' 0 []}';
MSXS1={'mo' 'MSXS1' 0 []}';
CNTRS={'mo' 'CNTRS' 0 []}';
SLSXS1={'mo' 'SLSXS1' 0 []}';
MSXS2={'mo' 'MSXS2' 0 []}';
MSXS3={'mo' 'MSXS3' 0 []}';
SXRSSEND={'mo' 'SXRSSEND' 0 []}';
SCHICANE=[SXRSSBEG,DMONOS,BCXSS1A,BCXSS1B,D1SA,GSXS1,D1SB,MSXS1,D1SC,BCXSS2A,BCXSS2B,DCHS,CNTRS,DCHS,BCXSS3A,BCXSS3B,D1SD,SLSXS1,D1SE,MSXS2,D1SF,MSXS3,D1SG,BCXSS4A,BCXSS4B,DMONOS,SXRSSEND];
% ------------------------------------------------------------------------------
% SXR undulator cells
% ------------------------------------------------------------------------------
USEGSX26=[DTSXU,UMASXH26,XCSU26,YCSU26,UMASXH26,DTSXU];
USEGSX27=[DTSXU,UMASXH27,XCSU27,YCSU27,UMASXH27,DTSXU];
USEGSX28=[DTSXU,UMASXH28,XCSU28,YCSU28,UMASXH28,DTSXU];
USEGSX29=[DTSXU,UMASXH29,XCSU29,YCSU29,UMASXH29,DTSXU];
USEGSX30=[DTSXU,UMASXH30,XCSU30,YCSU30,UMASXH30,DTSXU];
USEGSX31=[DTSXU,UMASXH31,XCSU31,YCSU31,UMASXH31,DTSXU];
USEGSX32=[DTSXU,UMASXH32,XCSU32,YCSU32,UMASXH32,DTSXU];
USEGSX33=[DTSXU,UMASXH33,XCSU33,YCSU33,UMASXH33,DTSXU];
USEGSX34=[DTSXU,UMASXH34,XCSU34,YCSU34,UMASXH34,DTSXU];
DUSEGS35=[SCHICANE];%DRIF, L=LDUSEGS
USEGSX36=[DTSXU,UMASXH36,XCSU36,YCSU36,UMASXH36,DTSXU];
USEGSX37=[DTSXU,UMASXH37,XCSU37,YCSU37,UMASXH37,DTSXU];
USEGSX38=[DTSXU,UMASXH38,XCSU38,YCSU38,UMASXH38,DTSXU];
USEGSX39=[DTSXU,UMASXH39,XCSU39,YCSU39,UMASXH39,DTSXU];
USEGSX40=[DTSXU,UMASXH40,XCSU40,YCSU40,UMASXH40,DTSXU];
USEGSX41=[DTSXU,UMASXH41,XCSU41,YCSU41,UMASXH41,DTSXU];
USEGSX42=[DTSXU,UMASXH42,XCSU42,YCSU42,UMASXH42,DTSXU];
USEGSX43=[DTSXU,UMASXH43,XCSU43,YCSU43,UMASXH43,DTSXU];
USEGSX44=[DTSXU,UMASXH44,XCSU44,YCSU44,UMASXH44,DTSXU];
USEGSX45=[DTSXU,UMASXH45,XCSU45,YCSU45,UMASXH45,DTSXU];
USEGSX46=[DTSXU,UMASXH46,XCSU46,YCSU46,UMASXH46,DTSXU];
USEGSX47=[DTSXU,UMASXH47,XCSU47,YCSU47,UMASXH47,DTSXU];
DUSEGS48={'dr' '' LDUSEGS []}';
DUSEGS49={'dr' '' LDUSEGS []}';
DUSEGS50={'dr' '' LDUSEGS []}';
QSXBLK26=[QSXH26,XCSX26,MUQS,YCSX26,QSXH26];
QSXBLK27=[QSXH27,XCSX27,MUQS,YCSX27,QSXH27];
QSXBLK28=[QSXH28,XCSX28,MUQS,YCSX28,QSXH28];
QSXBLK29=[QSXH29,XCSX29,MUQS,YCSX29,QSXH29];
QSXBLK30=[QSXH30,XCSX30,MUQS,YCSX30,QSXH30];
QSXBLK31=[QSXH31,XCSX31,MUQS,YCSX31,QSXH31];
QSXBLK32=[QSXH32,XCSX32,MUQS,YCSX32,QSXH32];
QSXBLK33=[QSXH33,XCSX33,MUQS,YCSX33,QSXH33];
QSXBLK34=[QSXH34,XCSX34,MUQS,YCSX34,QSXH34];
QSXBLK35=[QSXH35,XCSX35,MUQS,YCSX35,QSXH35];
QSXBLK36=[QSXH36,XCSX36,MUQS,YCSX36,QSXH36];
QSXBLK37=[QSXH37,XCSX37,MUQS,YCSX37,QSXH37];
QSXBLK38=[QSXH38,XCSX38,MUQS,YCSX38,QSXH38];
QSXBLK39=[QSXH39,XCSX39,MUQS,YCSX39,QSXH39];
QSXBLK40=[QSXH40,XCSX40,MUQS,YCSX40,QSXH40];
QSXBLK41=[QSXH41,XCSX41,MUQS,YCSX41,QSXH41];
QSXBLK42=[QSXH42,XCSX42,MUQS,YCSX42,QSXH42];
QSXBLK43=[QSXH43,XCSX43,MUQS,YCSX43,QSXH43];
QSXBLK44=[QSXH44,XCSX44,MUQS,YCSX44,QSXH44];
QSXBLK45=[QSXH45,XCSX45,MUQS,YCSX45,QSXH45];
QSXBLK46=[QSXH46,XCSX46,MUQS,YCSX46,QSXH46];
QSXBLK47=[QSXH47,XCSX47,MUQS,YCSX47,QSXH47];
DQSXBL48={'dr' '' LQU []}';
DQSXBL49={'dr' '' LQU []}';
DQSXBL50={'dr' '' LQU []}';
SXBRK26=[DU3S,PHSSX26,DU4S,VVSXU26,DU5S,QSXBLK26,DU6S,RFBSX26,DU7S];
SXBRK27=[DU3S,PHSSX27,DU4S,        DU5S,QSXBLK27,DU6S,RFBSX27,DU7S];
SXBRK28=[DU3S,PHSSX28,DU4S,        DU5S,QSXBLK28,DU6S,RFBSX28,DU7S];
SXBRK29=[DU3S,PHSSX29,DU4S,        DU5S,QSXBLK29,DU6S,RFBSX29,DU7S];
SXBRK30=[DU3S,PHSSX30,DU4S,        DU5S,QSXBLK30,DU6S,RFBSX30,DU7S];
SXBRK31=[DU3S,PHSSX31,DU4S,        DU5S,QSXBLK31,DU6S,RFBSX31,DU7S];
SXBRK32=[DU3S,PHSSX32,DU4S,VVSXU32,DU5S,QSXBLK32,DU6S,RFBSX32,DU7S];
SXBRK33=[DU3S,PHSSX33,DU4S,        DU5S,QSXBLK33,DU6S,RFBSX33,DU7S];
SXBRK34=[DU3S,PHSSX34,DU4S,        DU5S,QSXBLK34,DU6S,RFBSX34,DU7S];
SXBRK35=[DU3S,DPHSS35,DU4S,        DU5S,QSXBLK35,DU6S,RFBSX35,DU7S];
SXBRK36=[DU3S,PHSSX36,DU4S,        DU5S,QSXBLK36,DU6S,RFBSX36,DU7S];
SXBRK37=[DU3S,PHSSX37,DU4S,        DU5S,QSXBLK37,DU6S,RFBSX37,DU7S];
SXBRK38=[DU3S,PHSSX38,DU4S,VVSXU38,DU5S,QSXBLK38,DU6S,RFBSX38,DU7S];
SXBRK39=[DU3S,PHSSX39,DU4S,        DU5S,QSXBLK39,DU6S,RFBSX39,DU7S];
SXBRK40=[DU3S,PHSSX40,DU4S,        DU5S,QSXBLK40,DU6S,RFBSX40,DU7S];
SXBRK41=[DU3S,PHSSX41,DU4S,        DU5S,QSXBLK41,DU6S,RFBSX41,DU7S];
SXBRK42=[DU3S,PHSSX42,DU4S,        DU5S,QSXBLK42,DU6S,RFBSX42,DU7S];
SXBRK43=[DU3S,PHSSX43,DU4S,        DU5S,QSXBLK43,DU6S,RFBSX43,DU7S];
SXBRK44=[DU3S,PHSSX44,DU4S,VVSXU44,DU5S,QSXBLK44,DU6S,RFBSX44,DU7S];
SXBRK45=[DU3S,PHSSX45,DU4S,        DU5S,QSXBLK45,DU6S,RFBSX45,DU7S];
SXBRK46=[DU3S,PHSSX46,DU4S,        DU5S,QSXBLK46,DU6S,RFBSX46,DU7S];
SXBRK47=[DU3S,DPHSS47,DU4S,VVSXU47,DU5S,QSXBLK47,DU6S,RFBSX47,DU7S];
SXBRK48=[DU3S,DPHSS48,DU4S,        DU5S,DQSXBL48,DU6S,DRFBS48,DU7S];
SXBRK49=[DU3S,DPHSS49,DU4S,        DU5S,DQSXBL49,DU6S,DRFBS49,DU7S];
SXBRK50=[DU3S,DPHSS50,DU4S,        DU5S,DQSXBL50,DU6S,DRFBS50,DU7S];
SXCEL26=[DU1S,BLMS26,DU2S,USEGSX26,SXBRK26];
SXCEL27=[DU1S,BLMS27,DU2S,USEGSX27,SXBRK27];
SXCEL28=[DU1S,BLMS28,DU2S,USEGSX28,SXBRK28];
SXCEL29=[DU1S,BLMS29,DU2S,USEGSX29,SXBRK29];
SXCEL30=[DU1S,BLMS30,DU2S,USEGSX30,SXBRK30];
SXCEL31=[DU1S,BLMS31,DU2S,USEGSX31,SXBRK31];
SXCEL32=[DU1S,BLMS32,DU2S,USEGSX32,SXBRK32];
SXCEL33=[DU1S,BLMS33,DU2S,USEGSX33,SXBRK33];
SXCEL34=[DU1S,BLMS34,DU2S,USEGSX34,SXBRK34];
SXCEL35=[DU1S,       DU2S,DUSEGS35,SXBRK35];%empty with Q+RFBPM
SXCEL36=[DU1S,BLMS36,DU2S,USEGSX36,SXBRK36];
SXCEL37=[DU1S,BLMS37,DU2S,USEGSX37,SXBRK37];
SXCEL38=[DU1S,BLMS38,DU2S,USEGSX38,SXBRK38];
SXCEL39=[DU1S,BLMS39,DU2S,USEGSX39,SXBRK39];
SXCEL40=[DU1S,BLMS40,DU2S,USEGSX40,SXBRK40];
SXCEL41=[DU1S,BLMS41,DU2S,USEGSX41,SXBRK41];
SXCEL42=[DU1S,BLMS42,DU2S,USEGSX42,SXBRK42];
SXCEL43=[DU1S,BLMS43,DU2S,USEGSX43,SXBRK43];
SXCEL44=[DU1S,BLMS44,DU2S,USEGSX44,SXBRK44];
SXCEL45=[DU1S,BLMS45,DU2S,USEGSX45,SXBRK45];
SXCEL46=[DU1S,BLMS46,DU2S,USEGSX46,SXBRK46];
SXCEL47=[DU1S,BLMS47,DU2S,USEGSX47,SXBRK47];
SXCEL48=[DU1S,       DU2S,DUSEGS48,SXBRK48];%empty
SXCEL49=[DU1S,       DU2S,DUSEGS49,SXBRK49];%empty
SXCEL50=[DU1S,       DU2S,DUSEGS50,SXBRK50];%empty
SXRCL=[SXCEL26,SXCEL27,SXCEL28,SXCEL29,SXCEL30,SXCEL31,SXCEL32,SXCEL33,SXCEL34,SXCEL35,SXCEL36,SXCEL37,SXCEL38,SXCEL39,SXCEL40,SXCEL41,SXCEL42,SXCEL43,SXCEL44,SXCEL45,SXCEL46,SXCEL47,SXCEL48,SXCEL49,SXCEL50];
SXR=[SXRSTART,SXRCL,RWWAKE5S,SXRTERM,DUE1AB,RFBSX51,DUE1E,ENDUNDS];
% ------------------------------------------------------------------------------
% SXR undulator exit section
% ------------------------------------------------------------------------------
% note: the below K-values are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQUE1B =  -0.306247962224 ;%-0.297915551865
KQUE2B =   0.394195575969 ;% 0.390984021273
QUE1B={'qu' 'QUE1B' LQR/2 [KQUE1B 0]}';
QUE2B={'qu' 'QUE2B' LQR/2 [KQUE2B 0]}';
TCX01B={'tc' 'TCX01B' 1.0/2 [XBANDF 0 0*TWOPI]}';%horiz. deflection
TCX02B={'tc' 'TCX02B' 1.0/2 [XBANDF 0 0*TWOPI]}';%horiz. deflection
LBKXDMP =  1.0 ;%x-kicker length in dumpline
DBKXDMPS={'dr' '' LBKXDMP []}';%placeholder for x-kicker in SXR dumpline
DZSXTES =  0.468389399848E-10 ;%set MDLWALLb at 685 m exactly to align with SXR XTES system
DZHXTES =  0.749541186639E-6  ;%set MDLWALL at 685 m exactly to align with HXR XTES system
DUE1D={'dr' '' 0.1 []}';
DUE1B={'dr' '' 1.5 []}';
DUE1C={'dr' '' 0.5 []}';
DUE1CA={'dr' '' 0.3 []}';
DUE1CB={'dr' '' 0.188-0.012 []}';
DUE1CC={'dr' '' DUE1C{3}-DUE1CA{3}-DUE1CB{3} []}';
DUE2A={'dr' '' 0.5 []}';
DUE2B={'dr' '' 0.8 []}';
DUE2D={'dr' '' 0.188-0.012 []}';
DUE2E={'dr' '' 1.740055-DUE2B{3}-DUE2D{3} []}';
DUE2CB={'dr' '' 0.615+(LQP-LQR)/2 []}';
DUE3AB={'dr' '' 0.375504+(LQP-LQR)/2-0.014955 []}';
DUE3BB={'dr' '' 1.2630495+0.014955 []}';
DUE3C={'dr' '' (1.7968755-LBKXDMP)/2 []}';
DPCVV={'dr' '' 0.397 []}';
DVVTCX={'dr' '' 0.32 []}';
DTCX12={'dr' '' 0.373/2 []}';
DTCXSP={'dr' '' 0.381 []}';
DUE4B={'dr' '' 0.454+(LQP-LQR)/2 []}';
DUE5AB={'dr' '' 0.477799+(LQP-LQR)/2-0.114162 []}';
DUE5BB={'dr' '' 0.264+0.114162-0.1016+0.1016 []}';
DUE5CB={'dr' '' 0.2674+0.1016-0.1016 []}';
DUE5D={'dr' '' 0.137055-0.05 []}';
DUE5F={'dr' '' 0.05 []}';
DUE5E={'dr' '' 0.252825-DUE5D{3}-DUE5F{3}-DZHXTES []}';
DSB0A={'dr' '' 0.260150 []}';
DSB0B={'dr' '' 0.344 []}';
DSB0C={'dr' '' 0.32646 []}';
DSB0D={'dr' '' 0.123366 []}';
DDSB0E =  -0.403705866174E-3;
DSB0E={'dr' '' 0.1059327+DDSB0E []}';
DDLWALL={'dr' '' 0.250825+DZHXTES []}';%length of dumpline thermal barrier wall
DUE5EB={'dr' '' 0.252825-DUE5D{3}-DUE5F{3}+DZSXTES []}';
DDLWALLB={'dr' '' 0.250825-DZSXTES []}';%length of dumpline thermal barrier wall
XCUE2B={'mo' 'XCUE2B' 0 []}';
XCD3B={'mo' 'XCD3B' 0 []}';
YCUE1B={'mo' 'YCUE1B' 0 []}';
YCD3B={'mo' 'YCD3B' 0 []}';
BPMUE1B={'mo' 'BPMUE1B' 0 []}';%RFBUE1B : MONI, TYPE="@2,CavityS-1"
BPMUE2B={'mo' 'BPMUE2B' 0 []}';%RFBUE2B : MONI, TYPE="@2,CavityS-1"
%RFBUE3B : MONI, TYPE="@2,CavityS-1"
TRUE1B={'mo' 'TRUE1B' 0 []}';%Be foil inserter (THz)
SPTCXB={'mo' 'SPTCXB' 0 []}';%XTCAV spoiler
BTMQUEB={'mo' 'BTMQUEB' 0 []}';%Burn-Through-Monitor
BTM0B={'mo' 'BTM0B' 0 []}';%Burn-Through-Monitor behind the PCPM0B
PCTCXB={'dr' 'PCTCXB' 0 []}';%XTCAV photon collimator (9 mm aperture)
PCPM0B={'dr' 'PCPM0B' LPCPM []}';
%IMUNDOB : IMON, TYPE="@0,BCS ACM" BCS ACM
MIMUNDOB={'mo' 'MIMUNDOB' 0 []}';
PH31B={'mo' 'PH31B' 0 []}';%post-undulator phase measurement RF cavity (low rate)
PH32B={'mo' 'PH32B' 0 []}';%post-undulator phase measurement RF cavity (low rate)
PH33B={'mo' 'PH33B' 0 []}';%post-undulator phase measurement RF cavity (high rate)
PH34B={'mo' 'PH34B' 0 []}';%post-undulator phase measurement RF cavity (high rate)
UEBEGB={'mo' 'UEBEGB' 0 []}';
VVTCXB={'mo' 'VVTCXB' 0 []}';%XTCAV vacuum valve
MTCX01B={'mo' 'MTCX01B' 0 []}';%entrance to TCX01B (for ELEGANT WATCH point)
MTCXB={'mo' 'MTCXB' 0 []}';%centerline between TCX01B and TCX02B (for matching)
UEENDB={'mo' 'UEENDB' 0 []}';
VV36B={'mo' 'VV36B' 0 []}';%treaty-point vacuum valve just downbeam of undulator
VV37B={'mo' 'VV37B' 0 []}';%vac. valve in dumpline
DLSTARTB={'mo' 'DLSTARTB' 0 []}';
MDLWALLB={'mo' 'MDLWALLB' 0 []}';%front face of dumpline thermal barrier wall
UNDEXITB=[BEGDMPS_1,UEBEGB,DUE1D,VV36B,DUE1B,MIMUNDOB,DUE1CA,PH33B,DUE1CB,PH34B,DUE1CC,DUE2A,YCUE1B,DUE2B,PH31B,DUE2D,PH32B,DUE2E,XCUE2B,DUE2CB,QUE1B,QUE1B,DUE3AB,BPMUE1B,DUE3BB,TRUE1B,DUE3C,DBKXDMPS,DUE3C,PCTCXB,DPCVV,VVTCXB,DVVTCX,MTCX01B,TCX01B,TCX01B,DTCX12,MTCXB,DTCX12,TCX02B,TCX02B,DTCXSP,SPTCXB,DUE4B,QUE2B,QUE2B,DUE5AB,BPMUE2B,DUE5BB,BTMQUEB,DUE5CB,PCPM0B,DUE5F,BTM0B,DUE5D,DUE5EB,MDLWALLB,DDLWALLB,UEENDB,DLSTARTB,DSB0A,YCD3B,DSB0B,XCD3B,DSB0C,VV37B,DSB0D,DSB0E,ENDDMPS_1];
SXRUND=[SXRXX,SXR,UNDEXITB];
% ==============================================================================
% HXR HGVPU undulator (south)
% ==============================================================================
% ------------------------------------------------------------------------------
% HXR undulator PPM phase shifter
% - Author: Heinz-Dieter Nuhn, Stanford Linear Accelerator Center
% - Last edited September 06, 2017
% - 10.0 mm miminum Undulator Gap
% ------------------------------------------------------------------------------
% - LPSHX  = HXR Phase Shifter length
% - luPSHX = HXR Phase Shifter period
% - PIPSHX = HXR Phase Shifter phase integral 
% - KPSHX  = HXR Phase Shifter Undulator parameter (rms); range 0.18-1.91
% - kQPSHX = natural HXR Phase Shifter undulator focusing "k" in y-plane
% ------------------------------------------------------------------------------
LPSHX =  0.0495                             ;%m
LUPSHX =  0.045                              ;%m
LPSHXH =  LPSHX/2;
PIPSHX =  490                                ;%T^2mm^3 (80-490)
KPSHX =  1.E-9*CLIGHT/MC2*sqrt(2.E-9*PIPSHX/LUPSHX);
KQPSHX =  (KPSHX*2*PI/LUPSHX/sqrt(2)/GAMU)^2 ;%m^-2
PSHXH={'un' 'PSHXH' LPSHXH [KQPSHX LUPSHX 1]}';
% ------------------------------------------------------------------------------
% - Author: Heinz-Dieter Nuhn, Stanford Linear Accelerator Center
% - Edited Mar 03, 2014
% - Updated Dec 02, 2015 for HGVPU (Y. Nosochkov, D. Bruch)
% - 7.2 mm miminum Undulator Gap; only constant break length each
% - include natural horizontal focusing over all but edge terminations
% ------------------------------------------------------------------------------
% - IntgHX  = integrated quadrupole gradient
% - GQFHX   = QF and QD gradients can be made different to compensate for
%             undulator focussing ...
% - GQDHX   = ... but since undulator focussing depends on gamma^2, compensation
%             will only work for one energy
% - kQFHX   = QF undulator quadrupole focusing "k"
% - kQDHX   = QD undulator quadrupole focusing "k"
% - LDUSEGH = HXR Undulator segment length
% - luHXU   = HXR Undulator period
% - NpHXU   = HXR Undulator period count
% - LHXUCR  = HXR Undulator magnetic length
% - LHXUe   = HXR Undulator spacing between magnet array and strongback end
% - KHXU    = HXR Undulator parameter (rms); range 0.54-2.45
% - kQHX    = natural HXR undulator focusing "k" in x-plane
% ------------------------------------------------------------------------------
LDUSEGH =  3.372032;
LDU1H =  0.040984;
LDU2H =  0.0;
LDU3H =  (1.83-LDUSEGH/2-LQU/2)/2;
LDU4H =  0.13-LQU/2-LRFBUB/2;
LDU5H =  0.1275-LPSHXH-LRFBUB/2;
LDU6H =  0.109243-LPSHXH;
LDU7H =  0.08892366667;
LDU8H =  0.025;
DLDU0H =  0.0 ;%fine tune Z of undulator
LDU0H =  0.094391984077-LDU8H-LRFBUB +LRFBUB +DLDU0H;
DU0H={'dr' '' LDU0H []}';
DU1H={'dr' '' LDU1H []}';
DU2H={'dr' '' LDU2H []}';
DU3H={'dr' '' LDU3H []}';
DU4H={'dr' '' LDU4H []}';
DU5H={'dr' '' LDU5H []}';
DU6H={'dr' '' LDU6H []}';
DU7H={'dr' '' LDU7H []}';
DU8H={'dr' '' LDU8H []}';
DDUE1A =  0.0;
DUE1A={'dr' '' 2.853174666558-LRFBUB+DDUE1A []}';
%IntgHX :   definition moved to LCLS2sc_main.xsif and LCLS2cu_main.xsif
GQFHX =   INTGHX/LQU/10*1.0           ;%T/m
GQDHX =  -INTGHX/LQU/10*1.0           ;%T/m
KQFHX =   1.E-9*GQFHX*CLIGHT/GAMU/MC2 ;%m^-2
KQDHX =   1.E-9*GQDHX*CLIGHT/GAMU/MC2 ;%m^-2
KQDHXM =  -0.51857909178;
QHXH13={'qu' 'QHXH13' LQU/2 [KQFHX 0]}';
QHXH14={'qu' 'QHXH14' LQU/2 [KQDHX 0]}';
QHXH15={'qu' 'QHXH15' LQU/2 [KQFHX 0]}';
QHXH16={'qu' 'QHXH16' LQU/2 [KQDHX 0]}';
QHXH17={'qu' 'QHXH17' LQU/2 [KQFHX 0]}';
QHXH18={'qu' 'QHXH18' LQU/2 [KQDHX 0]}';
QHXH19={'qu' 'QHXH19' LQU/2 [KQFHX 0]}';
QHXH20={'qu' 'QHXH20' LQU/2 [KQDHX 0]}';
QHXH21={'qu' 'QHXH21' LQU/2 [KQFHX 0]}';
QHXH22={'qu' 'QHXH22' LQU/2 [KQDHX 0]}';
QHXH23={'qu' 'QHXH23' LQU/2 [KQFHX 0]}';
QHXH24={'qu' 'QHXH24' LQU/2 [KQDHX 0]}';
QHXH25={'qu' 'QHXH25' LQU/2 [KQFHX 0]}';
QHXH26={'qu' 'QHXH26' LQU/2 [KQDHX 0]}';
QHXH27={'qu' 'QHXH27' LQU/2 [KQFHX 0]}';
QHXH28={'qu' 'QHXH28' LQU/2 [KQDHX 0]}';
QHXH29={'qu' 'QHXH29' LQU/2 [KQFHX 0]}';
QHXH30={'qu' 'QHXH30' LQU/2 [KQDHX 0]}';
QHXH31={'qu' 'QHXH31' LQU/2 [KQFHX 0]}';
QHXH32={'qu' 'QHXH32' LQU/2 [KQDHX 0]}';
QHXH33={'qu' 'QHXH33' LQU/2 [KQFHX 0]}';
QHXH34={'qu' 'QHXH34' LQU/2 [KQDHX 0]}';
QHXH35={'qu' 'QHXH35' LQU/2 [KQFHX 0]}';
QHXH36={'qu' 'QHXH36' LQU/2 [KQDHX 0]}';
QHXH37={'qu' 'QHXH37' LQU/2 [KQFHX 0]}';
QHXH38={'qu' 'QHXH38' LQU/2 [KQDHX 0]}';
QHXH39={'qu' 'QHXH39' LQU/2 [KQFHX 0]}';
QHXH40={'qu' 'QHXH40' LQU/2 [KQDHX 0]}';
QHXH41={'qu' 'QHXH41' LQU/2 [KQFHX 0]}';
QHXH42={'qu' 'QHXH42' LQU/2 [KQDHX 0]}';
QHXH43={'qu' 'QHXH43' LQU/2 [KQFHX 0]}';
QHXH44={'qu' 'QHXH44' LQU/2 [KQDHX 0]}';
QHXH45={'qu' 'QHXH45' LQU/2 [KQFHX 0]}';
QHXH46={'qu' 'QHXH46' LQU/2 [KQDHXM 0]}';
LUHXU =  0.026                            ;%m
NPHXU =  129;
LHXUCR =  LUHXU*NPHXU                      ;%m
LHXUE =  (LDUSEGH-LHXUCR)/2               ;%m
LHXUH =  LHXUCR/2;
KHXU =  2.0;
KQHX =  (KHXU*2*PI/LUHXU/sqrt(2)/GAMU)^2 ;%m^-2
UMAHXH={'un' 'UMAHXH' LHXUH [KQHX LUHXU 0]}';
UMAHXH13=UMAHXH;UMAHXH13{2}='UMAHXH13';
UMAHXH14=UMAHXH;UMAHXH14{2}='UMAHXH14';
UMAHXH15=UMAHXH;UMAHXH15{2}='UMAHXH15';
UMAHXH16=UMAHXH;UMAHXH16{2}='UMAHXH16';
UMAHXH17=UMAHXH;UMAHXH17{2}='UMAHXH17';
UMAHXH18=UMAHXH;UMAHXH18{2}='UMAHXH18';
UMAHXH19=UMAHXH;UMAHXH19{2}='UMAHXH19';
UMAHXH21=UMAHXH;UMAHXH21{2}='UMAHXH21';
UMAHXH22=UMAHXH;UMAHXH22{2}='UMAHXH22';
UMAHXH23=UMAHXH;UMAHXH23{2}='UMAHXH23';
UMAHXH24=UMAHXH;UMAHXH24{2}='UMAHXH24';
UMAHXH25=UMAHXH;UMAHXH25{2}='UMAHXH25';
UMAHXH26=UMAHXH;UMAHXH26{2}='UMAHXH26';
UMAHXH27=UMAHXH;UMAHXH27{2}='UMAHXH27';
UMAHXH29=UMAHXH;UMAHXH29{2}='UMAHXH29';
UMAHXH30=UMAHXH;UMAHXH30{2}='UMAHXH30';
UMAHXH31=UMAHXH;UMAHXH31{2}='UMAHXH31';
UMAHXH32=UMAHXH;UMAHXH32{2}='UMAHXH32';
UMAHXH33=UMAHXH;UMAHXH33{2}='UMAHXH33';
UMAHXH34=UMAHXH;UMAHXH34{2}='UMAHXH34';
UMAHXH35=UMAHXH;UMAHXH35{2}='UMAHXH35';
UMAHXH36=UMAHXH;UMAHXH36{2}='UMAHXH36';
UMAHXH37=UMAHXH;UMAHXH37{2}='UMAHXH37';
UMAHXH38=UMAHXH;UMAHXH38{2}='UMAHXH38';
UMAHXH39=UMAHXH;UMAHXH39{2}='UMAHXH39';
UMAHXH40=UMAHXH;UMAHXH40{2}='UMAHXH40';
UMAHXH41=UMAHXH;UMAHXH41{2}='UMAHXH41';
UMAHXH42=UMAHXH;UMAHXH42{2}='UMAHXH42';
UMAHXH43=UMAHXH;UMAHXH43{2}='UMAHXH43';
UMAHXH44=UMAHXH;UMAHXH44{2}='UMAHXH44';
UMAHXH45=UMAHXH;UMAHXH45{2}='UMAHXH45';
UMAHXH46=UMAHXH;UMAHXH46{2}='UMAHXH46';
% ------------------------------------------------------------------------------
% HXR undulator X-steering coils in quads
% ------------------------------------------------------------------------------
XCHX13={'mo' 'XCHX13' 0 []}';
XCHX14={'mo' 'XCHX14' 0 []}';
XCHX15={'mo' 'XCHX15' 0 []}';
XCHX16={'mo' 'XCHX16' 0 []}';
XCHX17={'mo' 'XCHX17' 0 []}';
XCHX18={'mo' 'XCHX18' 0 []}';
XCHX19={'mo' 'XCHX19' 0 []}';
XCHX20={'mo' 'XCHX20' 0 []}';
XCHX21={'mo' 'XCHX21' 0 []}';
XCHX22={'mo' 'XCHX22' 0 []}';
XCHX23={'mo' 'XCHX23' 0 []}';
XCHX24={'mo' 'XCHX24' 0 []}';
XCHX25={'mo' 'XCHX25' 0 []}';
XCHX26={'mo' 'XCHX26' 0 []}';
XCHX27={'mo' 'XCHX27' 0 []}';
XCHX28={'mo' 'XCHX28' 0 []}';
XCHX29={'mo' 'XCHX29' 0 []}';
XCHX30={'mo' 'XCHX30' 0 []}';
XCHX31={'mo' 'XCHX31' 0 []}';
XCHX32={'mo' 'XCHX32' 0 []}';
XCHX33={'mo' 'XCHX33' 0 []}';
XCHX34={'mo' 'XCHX34' 0 []}';
XCHX35={'mo' 'XCHX35' 0 []}';
XCHX36={'mo' 'XCHX36' 0 []}';
XCHX37={'mo' 'XCHX37' 0 []}';
XCHX38={'mo' 'XCHX38' 0 []}';
XCHX39={'mo' 'XCHX39' 0 []}';
XCHX40={'mo' 'XCHX40' 0 []}';
XCHX41={'mo' 'XCHX41' 0 []}';
XCHX42={'mo' 'XCHX42' 0 []}';
XCHX43={'mo' 'XCHX43' 0 []}';
XCHX44={'mo' 'XCHX44' 0 []}';
XCHX45={'mo' 'XCHX45' 0 []}';
XCHX46={'mo' 'XCHX46' 0 []}';
% ------------------------------------------------------------------------------
% HXR undulator Y-steering coils in quads
% ------------------------------------------------------------------------------
YCHX13={'mo' 'YCHX13' 0 []}';
YCHX14={'mo' 'YCHX14' 0 []}';
YCHX15={'mo' 'YCHX15' 0 []}';
YCHX16={'mo' 'YCHX16' 0 []}';
YCHX17={'mo' 'YCHX17' 0 []}';
YCHX18={'mo' 'YCHX18' 0 []}';
YCHX19={'mo' 'YCHX19' 0 []}';
YCHX20={'mo' 'YCHX20' 0 []}';
YCHX21={'mo' 'YCHX21' 0 []}';
YCHX22={'mo' 'YCHX22' 0 []}';
YCHX23={'mo' 'YCHX23' 0 []}';
YCHX24={'mo' 'YCHX24' 0 []}';
YCHX25={'mo' 'YCHX25' 0 []}';
YCHX26={'mo' 'YCHX26' 0 []}';
YCHX27={'mo' 'YCHX27' 0 []}';
YCHX28={'mo' 'YCHX28' 0 []}';
YCHX29={'mo' 'YCHX29' 0 []}';
YCHX30={'mo' 'YCHX30' 0 []}';
YCHX31={'mo' 'YCHX31' 0 []}';
YCHX32={'mo' 'YCHX32' 0 []}';
YCHX33={'mo' 'YCHX33' 0 []}';
YCHX34={'mo' 'YCHX34' 0 []}';
YCHX35={'mo' 'YCHX35' 0 []}';
YCHX36={'mo' 'YCHX36' 0 []}';
YCHX37={'mo' 'YCHX37' 0 []}';
YCHX38={'mo' 'YCHX38' 0 []}';
YCHX39={'mo' 'YCHX39' 0 []}';
YCHX40={'mo' 'YCHX40' 0 []}';
YCHX41={'mo' 'YCHX41' 0 []}';
YCHX42={'mo' 'YCHX42' 0 []}';
YCHX43={'mo' 'YCHX43' 0 []}';
YCHX44={'mo' 'YCHX44' 0 []}';
YCHX45={'mo' 'YCHX45' 0 []}';
YCHX46={'mo' 'YCHX46' 0 []}';
% ------------------------------------------------------------------------------
% HXR undulator X-steering coils in undulator segments
% ------------------------------------------------------------------------------
XCHU13={'mo' 'XCHU13' 0 []}';
XCHU14={'mo' 'XCHU14' 0 []}';
XCHU15={'mo' 'XCHU15' 0 []}';
XCHU16={'mo' 'XCHU16' 0 []}';
XCHU17={'mo' 'XCHU17' 0 []}';
XCHU18={'mo' 'XCHU18' 0 []}';
XCHU19={'mo' 'XCHU19' 0 []}';
XCHU21={'mo' 'XCHU21' 0 []}';
XCHU22={'mo' 'XCHU22' 0 []}';
XCHU23={'mo' 'XCHU23' 0 []}';
XCHU24={'mo' 'XCHU24' 0 []}';
XCHU25={'mo' 'XCHU25' 0 []}';
XCHU26={'mo' 'XCHU26' 0 []}';
XCHU27={'mo' 'XCHU27' 0 []}';
XCHU29={'mo' 'XCHU29' 0 []}';
XCHU30={'mo' 'XCHU30' 0 []}';
XCHU31={'mo' 'XCHU31' 0 []}';
XCHU32={'mo' 'XCHU32' 0 []}';
XCHU33={'mo' 'XCHU33' 0 []}';
XCHU34={'mo' 'XCHU34' 0 []}';
XCHU35={'mo' 'XCHU35' 0 []}';
XCHU36={'mo' 'XCHU36' 0 []}';
XCHU37={'mo' 'XCHU37' 0 []}';
XCHU38={'mo' 'XCHU38' 0 []}';
XCHU39={'mo' 'XCHU39' 0 []}';
XCHU40={'mo' 'XCHU40' 0 []}';
XCHU41={'mo' 'XCHU41' 0 []}';
XCHU42={'mo' 'XCHU42' 0 []}';
XCHU43={'mo' 'XCHU43' 0 []}';
XCHU44={'mo' 'XCHU44' 0 []}';
XCHU45={'mo' 'XCHU45' 0 []}';
XCHU46={'mo' 'XCHU46' 0 []}';
% ------------------------------------------------------------------------------
% HXR undulator Y-steering coils in undulator segments
% ------------------------------------------------------------------------------
YCHU13={'mo' 'YCHU13' 0 []}';
YCHU14={'mo' 'YCHU14' 0 []}';
YCHU15={'mo' 'YCHU15' 0 []}';
YCHU16={'mo' 'YCHU16' 0 []}';
YCHU17={'mo' 'YCHU17' 0 []}';
YCHU18={'mo' 'YCHU18' 0 []}';
YCHU19={'mo' 'YCHU19' 0 []}';
YCHU21={'mo' 'YCHU21' 0 []}';
YCHU22={'mo' 'YCHU22' 0 []}';
YCHU23={'mo' 'YCHU23' 0 []}';
YCHU24={'mo' 'YCHU24' 0 []}';
YCHU25={'mo' 'YCHU25' 0 []}';
YCHU26={'mo' 'YCHU26' 0 []}';
YCHU27={'mo' 'YCHU27' 0 []}';
YCHU29={'mo' 'YCHU29' 0 []}';
YCHU30={'mo' 'YCHU30' 0 []}';
YCHU31={'mo' 'YCHU31' 0 []}';
YCHU32={'mo' 'YCHU32' 0 []}';
YCHU33={'mo' 'YCHU33' 0 []}';
YCHU34={'mo' 'YCHU34' 0 []}';
YCHU35={'mo' 'YCHU35' 0 []}';
YCHU36={'mo' 'YCHU36' 0 []}';
YCHU37={'mo' 'YCHU37' 0 []}';
YCHU38={'mo' 'YCHU38' 0 []}';
YCHU39={'mo' 'YCHU39' 0 []}';
YCHU40={'mo' 'YCHU40' 0 []}';
YCHU41={'mo' 'YCHU41' 0 []}';
YCHU42={'mo' 'YCHU42' 0 []}';
YCHU43={'mo' 'YCHU43' 0 []}';
YCHU44={'mo' 'YCHU44' 0 []}';
YCHU45={'mo' 'YCHU45' 0 []}';
YCHU46={'mo' 'YCHU46' 0 []}';
% ------------------------------------------------------------------------------
% HXR undulator BPMs
% ------------------------------------------------------------------------------
RFBHX13={'mo' 'RFBHX13' LRFBUB []}';
RFBHX14={'mo' 'RFBHX14' LRFBUB []}';
RFBHX15={'mo' 'RFBHX15' LRFBUB []}';
RFBHX16={'mo' 'RFBHX16' LRFBUB []}';
RFBHX17={'mo' 'RFBHX17' LRFBUB []}';
RFBHX18={'mo' 'RFBHX18' LRFBUB []}';
RFBHX19={'mo' 'RFBHX19' LRFBUB []}';
RFBHX20={'mo' 'RFBHX20' LRFBUB []}';
RFBHX21={'mo' 'RFBHX21' LRFBUB []}';
RFBHX22={'mo' 'RFBHX22' LRFBUB []}';
RFBHX23={'mo' 'RFBHX23' LRFBUB []}';
RFBHX24={'mo' 'RFBHX24' LRFBUB []}';
RFBHX25={'mo' 'RFBHX25' LRFBUB []}';
RFBHX26={'mo' 'RFBHX26' LRFBUB []}';
RFBHX27={'mo' 'RFBHX27' LRFBUB []}';
RFBHX28={'mo' 'RFBHX28' LRFBUB []}';
RFBHX29={'mo' 'RFBHX29' LRFBUB []}';
RFBHX30={'mo' 'RFBHX30' LRFBUB []}';
RFBHX31={'mo' 'RFBHX31' LRFBUB []}';
RFBHX32={'mo' 'RFBHX32' LRFBUB []}';
RFBHX33={'mo' 'RFBHX33' LRFBUB []}';
RFBHX34={'mo' 'RFBHX34' LRFBUB []}';
RFBHX35={'mo' 'RFBHX35' LRFBUB []}';
RFBHX36={'mo' 'RFBHX36' LRFBUB []}';
RFBHX37={'mo' 'RFBHX37' LRFBUB []}';
RFBHX38={'mo' 'RFBHX38' LRFBUB []}';
RFBHX39={'mo' 'RFBHX39' LRFBUB []}';
RFBHX40={'mo' 'RFBHX40' LRFBUB []}';
RFBHX41={'mo' 'RFBHX41' LRFBUB []}';
RFBHX42={'mo' 'RFBHX42' LRFBUB []}';
RFBHX43={'mo' 'RFBHX43' LRFBUB []}';
RFBHX44={'mo' 'RFBHX44' LRFBUB []}';
RFBHX45={'mo' 'RFBHX45' LRFBUB []}';
RFBHX46={'mo' 'RFBHX46' LRFBUB []}';
DRFBH47={'dr' '' LRFBUB []}';
DRFBH48={'dr' '' LRFBUB []}';
DRFBH49={'dr' '' LRFBUB []}';
DRFBH50={'dr' '' LRFBUB []}';
RFBHX51={'mo' 'RFBHX51' LRFBUB []}';
% ------------------------------------------------------------------------------
% DTHXU = HXU undulator segment small terminations modeled as drift
% ------------------------------------------------------------------------------
DTHXU={'dr' '' LHXUE []}';
% ------------------------------------------------------------------------------
% markers
% ------------------------------------------------------------------------------
HXRSTART={'mo' 'HXRSTART' 0 []}';%start of undulator system
RWWAKE5H={'mo' 'RWWAKE5H' 0 []}';%HXR beampipe wake applied here
HXRTERM={'mo' 'HXRTERM' 0 []}';%end of undulator system
MUQH={'mo' 'MUQH' 0 []}';
MPHH={'mo' 'MPHH' 0 []}';
% ------------------------------------------------------------------------------
% HXR undulator phase shifters
% ------------------------------------------------------------------------------
PHSHX13=[PSHXH,MPHH,PSHXH];
PHSHX14=[PSHXH,MPHH,PSHXH];
PHSHX15=[PSHXH,MPHH,PSHXH];
PHSHX16=[PSHXH,MPHH,PSHXH];
PHSHX17=[PSHXH,MPHH,PSHXH];
PHSHX18=[PSHXH,MPHH,PSHXH];
PHSHX19=[PSHXH,MPHH,PSHXH];
DPHSH20={'dr' '' LPSHX []}';
PHSHX21=[PSHXH,MPHH,PSHXH];
PHSHX22=[PSHXH,MPHH,PSHXH];
PHSHX23=[PSHXH,MPHH,PSHXH];
PHSHX24=[PSHXH,MPHH,PSHXH];
PHSHX25=[PSHXH,MPHH,PSHXH];
PHSHX26=[PSHXH,MPHH,PSHXH];
PHSHX27=[PSHXH,MPHH,PSHXH];
DPHSH28={'dr' '' LPSHX []}';
PHSHX29=[PSHXH,MPHH,PSHXH];
PHSHX30=[PSHXH,MPHH,PSHXH];
PHSHX31=[PSHXH,MPHH,PSHXH];
PHSHX32=[PSHXH,MPHH,PSHXH];
PHSHX33=[PSHXH,MPHH,PSHXH];
PHSHX34=[PSHXH,MPHH,PSHXH];
PHSHX35=[PSHXH,MPHH,PSHXH];
PHSHX36=[PSHXH,MPHH,PSHXH];
PHSHX37=[PSHXH,MPHH,PSHXH];
PHSHX38=[PSHXH,MPHH,PSHXH];
PHSHX39=[PSHXH,MPHH,PSHXH];
PHSHX40=[PSHXH,MPHH,PSHXH];
PHSHX41=[PSHXH,MPHH,PSHXH];
PHSHX42=[PSHXH,MPHH,PSHXH];
PHSHX43=[PSHXH,MPHH,PSHXH];
PHSHX44=[PSHXH,MPHH,PSHXH];
PHSHX45=[PSHXH,MPHH,PSHXH];
DPHSH46={'dr' '' LPSHX []}';
DPHSH47={'dr' '' LPSHX []}';
DPHSH48={'dr' '' LPSHX []}';
DPHSH49={'dr' '' LPSHX []}';
DPHSH50={'dr' '' LPSHX []}';
% ------------------------------------------------------------------------------
% HXR undulator inline valves (VAT Series 48?)
% ------------------------------------------------------------------------------
VVHXU13={'mo' 'VVHXU13' 0 []}';
VVHXU14={'mo' 'VVHXU14' 0 []}';
VVHXU15={'mo' 'VVHXU15' 0 []}';
VVHXU16={'mo' 'VVHXU16' 0 []}';
VVHXU17={'mo' 'VVHXU17' 0 []}';
VVHXU18={'mo' 'VVHXU18' 0 []}';
VVHXU19={'mo' 'VVHXU19' 0 []}';
VVHXU21={'mo' 'VVHXU21' 0 []}';
VVHXU22={'mo' 'VVHXU22' 0 []}';
VVHXU23={'mo' 'VVHXU23' 0 []}';
VVHXU24={'mo' 'VVHXU24' 0 []}';
VVHXU25={'mo' 'VVHXU25' 0 []}';
VVHXU26={'mo' 'VVHXU26' 0 []}';
VVHXU27={'mo' 'VVHXU27' 0 []}';
VVHXU29={'mo' 'VVHXU29' 0 []}';
VVHXU30={'mo' 'VVHXU30' 0 []}';
VVHXU31={'mo' 'VVHXU31' 0 []}';
VVHXU32={'mo' 'VVHXU32' 0 []}';
VVHXU33={'mo' 'VVHXU33' 0 []}';
VVHXU34={'mo' 'VVHXU34' 0 []}';
VVHXU35={'mo' 'VVHXU35' 0 []}';
VVHXU36={'mo' 'VVHXU36' 0 []}';
VVHXU37={'mo' 'VVHXU37' 0 []}';
VVHXU38={'mo' 'VVHXU38' 0 []}';
VVHXU39={'mo' 'VVHXU39' 0 []}';
VVHXU40={'mo' 'VVHXU40' 0 []}';
VVHXU41={'mo' 'VVHXU41' 0 []}';
VVHXU42={'mo' 'VVHXU42' 0 []}';
VVHXU43={'mo' 'VVHXU43' 0 []}';
VVHXU44={'mo' 'VVHXU44' 0 []}';
VVHXU45={'mo' 'VVHXU45' 0 []}';
VVHXU46={'mo' 'VVHXU46' 0 []}';
% ------------------------------------------------------------------------------
% HXR undulator Beam Loss Monitors
% ------------------------------------------------------------------------------
BLMH13={'mo' 'BLMH13' 0 []}';
BLMH14={'mo' 'BLMH14' 0 []}';
BLMH15={'mo' 'BLMH15' 0 []}';
BLMH16={'mo' 'BLMH16' 0 []}';
BLMH17={'mo' 'BLMH17' 0 []}';
BLMH18={'mo' 'BLMH18' 0 []}';
BLMH19={'mo' 'BLMH19' 0 []}';
BLMH21={'mo' 'BLMH21' 0 []}';
BLMH22={'mo' 'BLMH22' 0 []}';
BLMH23={'mo' 'BLMH23' 0 []}';
BLMH24={'mo' 'BLMH24' 0 []}';
BLMH25={'mo' 'BLMH25' 0 []}';
BLMH26={'mo' 'BLMH26' 0 []}';
BLMH27={'mo' 'BLMH27' 0 []}';
BLMH29={'mo' 'BLMH29' 0 []}';
BLMH30={'mo' 'BLMH30' 0 []}';
BLMH31={'mo' 'BLMH31' 0 []}';
BLMH32={'mo' 'BLMH32' 0 []}';
BLMH33={'mo' 'BLMH33' 0 []}';
BLMH34={'mo' 'BLMH34' 0 []}';
BLMH35={'mo' 'BLMH35' 0 []}';
BLMH36={'mo' 'BLMH36' 0 []}';
BLMH37={'mo' 'BLMH37' 0 []}';
BLMH38={'mo' 'BLMH38' 0 []}';
BLMH39={'mo' 'BLMH39' 0 []}';
BLMH40={'mo' 'BLMH40' 0 []}';
BLMH41={'mo' 'BLMH41' 0 []}';
BLMH42={'mo' 'BLMH42' 0 []}';
BLMH43={'mo' 'BLMH43' 0 []}';
BLMH44={'mo' 'BLMH44' 0 []}';
BLMH45={'mo' 'BLMH45' 0 []}';
BLMH46={'mo' 'BLMH46' 0 []}';
% ------------------------------------------------------------------------------
% HXRSS self-seeding chicane (LCLSII-3.2-PR-0102-R1)
% ------------------------------------------------------------------------------
% NOTEs:
% - in LCLS: BXHS1-4
% - Bmax = 1.9 kG-m @ 6 A (~24 mm beam offset)
% - use series approximation for sinc(x)=sin(x)/x to allow BLB4=0
% - deflects toward -X (to the right/south/wall)
% - bends away from coil side
% BCXHS1 gets an X-offset of  0    mm (toward the wall)
% BCXHS2 gets an X-offset of -2.39 mm (toward the wall)
% BCXHS3 gets an X-offset of -2.39 mm (toward the wall)
% BCXHS4 gets an X-offset of  0    mm (toward the wall)
BRHO4 =  CB*EU                             ;%beam rigidity at chicane (kG-m)
GB4 =  0.315*IN2M                        ;%full gap height [m]
ZB4 =  14.315*IN2M                       ;%on-axis effective length is 14" + gap (rule-of-thumb)
FB4 =  0.5                               ;%not measured
AB4 =  +3.02786616797E-3*SETHXRSS        ;%bend angle (rad) for R56=+15.0 um
BLB4 =  BRHO4*AB4                         ;%integrated strength (1.377623 kG-m @ 13.64 GeV)
AB4_2 =  AB4*AB4;
AB4_4 =  AB4_2*AB4_2;
AB4_6 =  AB4_4*AB4_2;
SINCAB4 =  1-AB4_2/6+AB4_4/120-AB4_6/5040    ;%~sinc(AB4)=sin(AB4)/AB4
LB4 =  ZB4/SINCAB4                       ;%chicane bend path length (m)
AB4S =  asin(sin(AB4)/2)                  ;%"short" half chicane bend angle (rad)
AB4S_2 =  AB4S*AB4S;
AB4S_4 =  AB4S_2*AB4S_2;
AB4S_6 =  AB4S_4*AB4S_2;
SINCAB4S =  1-AB4S_2/6+AB4S_4/120-AB4S_6/5040 ;%~sinc(AB4s)=sin(AB4s)/AB4s
LB4S =  (ZB4/2)/SINCAB4S                  ;%"short" half chicane bend path length (m)
AB4L =  AB4-AB4S                          ;%"long" half chicane bend angle (rad)
LB4L =  LB4-LB4S                          ;%"long" half chicane bend path length (m)
BCXHS1A={'be' 'BCXHS1' LB4S [+AB4S GB4/2 0 0 FB4 0 0]}';
BCXHS1B={'be' 'BCXHS1' LB4L [+AB4L GB4/2 0 +AB4 0 FB4 0]}';
BCXHS2A={'be' 'BCXHS2' LB4L [-AB4L GB4/2 -AB4 0 FB4 0 0]}';
BCXHS2B={'be' 'BCXHS2' LB4S [-AB4S GB4/2 0 0 0 FB4 0]}';
BCXHS3A={'be' 'BCXHS3' LB4S [-AB4S GB4/2 0 0 FB4 0 0]}';
BCXHS3B={'be' 'BCXHS3' LB4L [-AB4L GB4/2 0 -AB4 0 FB4 0]}';
BCXHS4A={'be' 'BCXHS4' LB4L [+AB4L GB4/2 +AB4 0 FB4 0 0]}';
BCXHS4B={'be' 'BCXHS4' LB4S [+AB4S GB4/2 0 0 0 FB4 0]}';
LHSSB2BO =  0.939 ;%outer bend center-to-center (PRD Table 3)
LHSSB2BI =  0.936 ;%inner bend center-to-center (PRD Table 3)
D1={'dr' '' (LHSSB2BO-ZB4)/cos(AB4) []}';
DCH={'dr' '' (LHSSB2BI-ZB4)/2 []}';
DMONO={'dr' '' (LDUSEGH-2*LHSSB2BO-LHSSB2BI-ZB4)/2 []}';
HXRSSBEG={'mo' 'HXRSSBEG' 0 []}';
DIAMOND={'mo' 'DIAMOND' 0 []}';
HXRSSEND={'mo' 'HXRSSEND' 0 []}';
HCHICANE=[HXRSSBEG,DMONO,BCXHS1A,BCXHS1B,D1,BCXHS2A,BCXHS2B,DCH,DIAMOND,DCH,BCXHS3A,BCXHS3B,D1,BCXHS4A,BCXHS4B,DMONO,HXRSSEND];
% ------------------------------------------------------------------------------
% HXR undulator cells
% ------------------------------------------------------------------------------
USEGHX13=[DTHXU,UMAHXH13,XCHU13,YCHU13,UMAHXH13,DTHXU];
USEGHX14=[DTHXU,UMAHXH14,XCHU14,YCHU14,UMAHXH14,DTHXU];
USEGHX15=[DTHXU,UMAHXH15,XCHU15,YCHU15,UMAHXH15,DTHXU];
USEGHX16=[DTHXU,UMAHXH16,XCHU16,YCHU16,UMAHXH16,DTHXU];
USEGHX17=[DTHXU,UMAHXH17,XCHU17,YCHU17,UMAHXH17,DTHXU];
USEGHX18=[DTHXU,UMAHXH18,XCHU18,YCHU18,UMAHXH18,DTHXU];
USEGHX19=[DTHXU,UMAHXH19,XCHU19,YCHU19,UMAHXH19,DTHXU];
DUSEGH20={'dr' '' LDUSEGH []}';
USEGHX21=[DTHXU,UMAHXH21,XCHU21,YCHU21,UMAHXH21,DTHXU];
USEGHX22=[DTHXU,UMAHXH22,XCHU22,YCHU22,UMAHXH22,DTHXU];
USEGHX23=[DTHXU,UMAHXH23,XCHU23,YCHU23,UMAHXH23,DTHXU];
USEGHX24=[DTHXU,UMAHXH24,XCHU24,YCHU24,UMAHXH24,DTHXU];
USEGHX25=[DTHXU,UMAHXH25,XCHU25,YCHU25,UMAHXH25,DTHXU];
USEGHX26=[DTHXU,UMAHXH26,XCHU26,YCHU26,UMAHXH26,DTHXU];
USEGHX27=[DTHXU,UMAHXH27,XCHU27,YCHU27,UMAHXH27,DTHXU];
DUSEGH28=[HCHICANE];%DRIF, L=LDUSEGH
USEGHX29=[DTHXU,UMAHXH29,XCHU29,YCHU29,UMAHXH29,DTHXU];
USEGHX30=[DTHXU,UMAHXH30,XCHU30,YCHU30,UMAHXH30,DTHXU];
USEGHX31=[DTHXU,UMAHXH31,XCHU31,YCHU31,UMAHXH31,DTHXU];
USEGHX32=[DTHXU,UMAHXH32,XCHU32,YCHU32,UMAHXH32,DTHXU];
USEGHX33=[DTHXU,UMAHXH33,XCHU33,YCHU33,UMAHXH33,DTHXU];
USEGHX34=[DTHXU,UMAHXH34,XCHU34,YCHU34,UMAHXH34,DTHXU];
USEGHX35=[DTHXU,UMAHXH35,XCHU35,YCHU35,UMAHXH35,DTHXU];
USEGHX36=[DTHXU,UMAHXH36,XCHU36,YCHU36,UMAHXH36,DTHXU];
USEGHX37=[DTHXU,UMAHXH37,XCHU37,YCHU37,UMAHXH37,DTHXU];
USEGHX38=[DTHXU,UMAHXH38,XCHU38,YCHU38,UMAHXH38,DTHXU];
USEGHX39=[DTHXU,UMAHXH39,XCHU39,YCHU39,UMAHXH39,DTHXU];
USEGHX40=[DTHXU,UMAHXH40,XCHU40,YCHU40,UMAHXH40,DTHXU];
USEGHX41=[DTHXU,UMAHXH41,XCHU41,YCHU41,UMAHXH41,DTHXU];
USEGHX42=[DTHXU,UMAHXH42,XCHU42,YCHU42,UMAHXH42,DTHXU];
USEGHX43=[DTHXU,UMAHXH43,XCHU43,YCHU43,UMAHXH43,DTHXU];
USEGHX44=[DTHXU,UMAHXH44,XCHU44,YCHU44,UMAHXH44,DTHXU];
USEGHX45=[DTHXU,UMAHXH45,XCHU45,YCHU45,UMAHXH45,DTHXU];
USEGHX46=[DTHXU,UMAHXH46,XCHU46,YCHU46,UMAHXH46,DTHXU];
DUSEGH47={'dr' '' LDUSEGH []}';
DUSEGH48={'dr' '' LDUSEGH []}';
DUSEGH49={'dr' '' LDUSEGH []}';
DUSEGH50={'dr' '' LDUSEGH []}';
QHXBLK13=[QHXH13,XCHX13,MUQH,YCHX13,QHXH13];
QHXBLK14=[QHXH14,XCHX14,MUQH,YCHX14,QHXH14];
QHXBLK15=[QHXH15,XCHX15,MUQH,YCHX15,QHXH15];
QHXBLK16=[QHXH16,XCHX16,MUQH,YCHX16,QHXH16];
QHXBLK17=[QHXH17,XCHX17,MUQH,YCHX17,QHXH17];
QHXBLK18=[QHXH18,XCHX18,MUQH,YCHX18,QHXH18];
QHXBLK19=[QHXH19,XCHX19,MUQH,YCHX19,QHXH19];
QHXBLK20=[QHXH20,XCHX20,MUQH,YCHX20,QHXH20];
QHXBLK21=[QHXH21,XCHX21,MUQH,YCHX21,QHXH21];
QHXBLK22=[QHXH22,XCHX22,MUQH,YCHX22,QHXH22];
QHXBLK23=[QHXH23,XCHX23,MUQH,YCHX23,QHXH23];
QHXBLK24=[QHXH24,XCHX24,MUQH,YCHX24,QHXH24];
QHXBLK25=[QHXH25,XCHX25,MUQH,YCHX25,QHXH25];
QHXBLK26=[QHXH26,XCHX26,MUQH,YCHX26,QHXH26];
QHXBLK27=[QHXH27,XCHX27,MUQH,YCHX27,QHXH27];
QHXBLK28=[QHXH28,XCHX28,MUQH,YCHX28,QHXH28];
QHXBLK29=[QHXH29,XCHX29,MUQH,YCHX29,QHXH29];
QHXBLK30=[QHXH30,XCHX30,MUQH,YCHX30,QHXH30];
QHXBLK31=[QHXH31,XCHX31,MUQH,YCHX31,QHXH31];
QHXBLK32=[QHXH32,XCHX32,MUQH,YCHX32,QHXH32];
QHXBLK33=[QHXH33,XCHX33,MUQH,YCHX33,QHXH33];
QHXBLK34=[QHXH34,XCHX34,MUQH,YCHX34,QHXH34];
QHXBLK35=[QHXH35,XCHX35,MUQH,YCHX35,QHXH35];
QHXBLK36=[QHXH36,XCHX36,MUQH,YCHX36,QHXH36];
QHXBLK37=[QHXH37,XCHX37,MUQH,YCHX37,QHXH37];
QHXBLK38=[QHXH38,XCHX38,MUQH,YCHX38,QHXH38];
QHXBLK39=[QHXH39,XCHX39,MUQH,YCHX39,QHXH39];
QHXBLK40=[QHXH40,XCHX40,MUQH,YCHX40,QHXH40];
QHXBLK41=[QHXH41,XCHX41,MUQH,YCHX41,QHXH41];
QHXBLK42=[QHXH42,XCHX42,MUQH,YCHX42,QHXH42];
QHXBLK43=[QHXH43,XCHX43,MUQH,YCHX43,QHXH43];
QHXBLK44=[QHXH44,XCHX44,MUQH,YCHX44,QHXH44];
QHXBLK45=[QHXH45,XCHX45,MUQH,YCHX45,QHXH45];
QHXBLK46=[QHXH46,XCHX46,MUQH,YCHX46,QHXH46];
DQHXBL47={'dr' '' LQU []}';
DQHXBL48={'dr' '' LQU []}';
DQHXBL49={'dr' '' LQU []}';
DQHXBL50={'dr' '' LQU []}';
HXBRK13=[DU3H,BLMH13,DU3H,QHXBLK13,DU4H,RFBHX13,DU5H,PHSHX13,DU6H,VVHXU13,DU7H];
HXBRK14=[DU3H,BLMH14,DU3H,QHXBLK14,DU4H,RFBHX14,DU5H,PHSHX14,DU6H,VVHXU14,DU7H];
HXBRK15=[DU3H,BLMH15,DU3H,QHXBLK15,DU4H,RFBHX15,DU5H,PHSHX15,DU6H,VVHXU15,DU7H];
HXBRK16=[DU3H,BLMH16,DU3H,QHXBLK16,DU4H,RFBHX16,DU5H,PHSHX16,DU6H,VVHXU16,DU7H];
HXBRK17=[DU3H,BLMH17,DU3H,QHXBLK17,DU4H,RFBHX17,DU5H,PHSHX17,DU6H,VVHXU17,DU7H];
HXBRK18=[DU3H,BLMH18,DU3H,QHXBLK18,DU4H,RFBHX18,DU5H,PHSHX18,DU6H,VVHXU18,DU7H];
HXBRK19=[DU3H,BLMH19,DU3H,QHXBLK19,DU4H,RFBHX19,DU5H,PHSHX19,DU6H,VVHXU19,DU7H];
HXBRK20=[DU3H       ,DU3H,QHXBLK20,DU4H,RFBHX20,DU5H,DPHSH20,DU6H        ,DU7H];
HXBRK21=[DU3H,BLMH21,DU3H,QHXBLK21,DU4H,RFBHX21,DU5H,PHSHX21,DU6H,VVHXU21,DU7H];
HXBRK22=[DU3H,BLMH22,DU3H,QHXBLK22,DU4H,RFBHX22,DU5H,PHSHX22,DU6H,VVHXU22,DU7H];
HXBRK23=[DU3H,BLMH23,DU3H,QHXBLK23,DU4H,RFBHX23,DU5H,PHSHX23,DU6H,VVHXU23,DU7H];
HXBRK24=[DU3H,BLMH24,DU3H,QHXBLK24,DU4H,RFBHX24,DU5H,PHSHX24,DU6H,VVHXU24,DU7H];
HXBRK25=[DU3H,BLMH25,DU3H,QHXBLK25,DU4H,RFBHX25,DU5H,PHSHX25,DU6H,VVHXU25,DU7H];
HXBRK26=[DU3H,BLMH26,DU3H,QHXBLK26,DU4H,RFBHX26,DU5H,PHSHX26,DU6H,VVHXU26,DU7H];
HXBRK27=[DU3H,BLMH27,DU3H,QHXBLK27,DU4H,RFBHX27,DU5H,PHSHX27,DU6H,VVHXU27,DU7H];
HXBRK28=[DU3H       ,DU3H,QHXBLK28,DU4H,RFBHX28,DU5H,DPHSH28,DU6H        ,DU7H];
HXBRK29=[DU3H,BLMH29,DU3H,QHXBLK29,DU4H,RFBHX29,DU5H,PHSHX29,DU6H,VVHXU29,DU7H];
HXBRK30=[DU3H,BLMH30,DU3H,QHXBLK30,DU4H,RFBHX30,DU5H,PHSHX30,DU6H,VVHXU30,DU7H];
HXBRK31=[DU3H,BLMH31,DU3H,QHXBLK31,DU4H,RFBHX31,DU5H,PHSHX31,DU6H,VVHXU31,DU7H];
HXBRK32=[DU3H,BLMH32,DU3H,QHXBLK32,DU4H,RFBHX32,DU5H,PHSHX32,DU6H,VVHXU32,DU7H];
HXBRK33=[DU3H,BLMH33,DU3H,QHXBLK33,DU4H,RFBHX33,DU5H,PHSHX33,DU6H,VVHXU33,DU7H];
HXBRK34=[DU3H,BLMH34,DU3H,QHXBLK34,DU4H,RFBHX34,DU5H,PHSHX34,DU6H,VVHXU34,DU7H];
HXBRK35=[DU3H,BLMH35,DU3H,QHXBLK35,DU4H,RFBHX35,DU5H,PHSHX35,DU6H,VVHXU35,DU7H];
HXBRK36=[DU3H,BLMH36,DU3H,QHXBLK36,DU4H,RFBHX36,DU5H,PHSHX36,DU6H,VVHXU36,DU7H];
HXBRK37=[DU3H,BLMH37,DU3H,QHXBLK37,DU4H,RFBHX37,DU5H,PHSHX37,DU6H,VVHXU37,DU7H];
HXBRK38=[DU3H,BLMH38,DU3H,QHXBLK38,DU4H,RFBHX38,DU5H,PHSHX38,DU6H,VVHXU38,DU7H];
HXBRK39=[DU3H,BLMH39,DU3H,QHXBLK39,DU4H,RFBHX39,DU5H,PHSHX39,DU6H,VVHXU39,DU7H];
HXBRK40=[DU3H,BLMH40,DU3H,QHXBLK40,DU4H,RFBHX40,DU5H,PHSHX40,DU6H,VVHXU40,DU7H];
HXBRK41=[DU3H,BLMH41,DU3H,QHXBLK41,DU4H,RFBHX41,DU5H,PHSHX41,DU6H,VVHXU41,DU7H];
HXBRK42=[DU3H,BLMH42,DU3H,QHXBLK42,DU4H,RFBHX42,DU5H,PHSHX42,DU6H,VVHXU42,DU7H];
HXBRK43=[DU3H,BLMH43,DU3H,QHXBLK43,DU4H,RFBHX43,DU5H,PHSHX43,DU6H,VVHXU43,DU7H];
HXBRK44=[DU3H,BLMH44,DU3H,QHXBLK44,DU4H,RFBHX44,DU5H,PHSHX44,DU6H,VVHXU44,DU7H];
HXBRK45=[DU3H,BLMH45,DU3H,QHXBLK45,DU4H,RFBHX45,DU5H,PHSHX45,DU6H,VVHXU45,DU7H];
HXBRK46=[DU3H,BLMH46,DU3H,QHXBLK46,DU4H,RFBHX46,DU5H,DPHSH46,DU6H,VVHXU46,DU7H];
HXBRK47=[DU3H       ,DU3H,DQHXBL47,DU4H,DRFBH47,DU5H,DPHSH47,DU6H        ,DU7H];
HXBRK48=[DU3H       ,DU3H,DQHXBL48,DU4H,DRFBH48,DU5H,DPHSH48,DU6H        ,DU7H];
HXBRK49=[DU3H       ,DU3H,DQHXBL49,DU4H,DRFBH49,DU5H,DPHSH49,DU6H        ,DU7H];
HXBRK50=[DU3H       ,DU3H,DQHXBL50,DU4H,DRFBH50,DU5H,DPHSH50,DU6H        ,DU7H];
HXCEL13=[DU1H,DU2H,USEGHX13,HXBRK13];
HXCEL14=[DU1H,DU2H,USEGHX14,HXBRK14];
HXCEL15=[DU1H,DU2H,USEGHX15,HXBRK15];
HXCEL16=[DU1H,DU2H,USEGHX16,HXBRK16];
HXCEL17=[DU1H,DU2H,USEGHX17,HXBRK17];
HXCEL18=[DU1H,DU2H,USEGHX18,HXBRK18];
HXCEL19=[DU1H,DU2H,USEGHX19,HXBRK19];
HXCEL20=[DU1H,DU2H,DUSEGH20,HXBRK20];%empty with Q+RFBPM
HXCEL21=[DU1H,DU2H,USEGHX21,HXBRK21];
HXCEL22=[DU1H,DU2H,USEGHX22,HXBRK22];
HXCEL23=[DU1H,DU2H,USEGHX23,HXBRK23];
HXCEL24=[DU1H,DU2H,USEGHX24,HXBRK24];
HXCEL25=[DU1H,DU2H,USEGHX25,HXBRK25];
HXCEL26=[DU1H,DU2H,USEGHX26,HXBRK26];
HXCEL27=[DU1H,DU2H,USEGHX27,HXBRK27];
HXCEL28=[DU1H,DU2H,DUSEGH28,HXBRK28];%empty with Q+RFBPM
HXCEL29=[DU1H,DU2H,USEGHX29,HXBRK29];
HXCEL30=[DU1H,DU2H,USEGHX30,HXBRK30];
HXCEL31=[DU1H,DU2H,USEGHX31,HXBRK31];
HXCEL32=[DU1H,DU2H,USEGHX32,HXBRK32];
HXCEL33=[DU1H,DU2H,USEGHX33,HXBRK33];
HXCEL34=[DU1H,DU2H,USEGHX34,HXBRK34];
HXCEL35=[DU1H,DU2H,USEGHX35,HXBRK35];
HXCEL36=[DU1H,DU2H,USEGHX36,HXBRK36];
HXCEL37=[DU1H,DU2H,USEGHX37,HXBRK37];
HXCEL38=[DU1H,DU2H,USEGHX38,HXBRK38];
HXCEL39=[DU1H,DU2H,USEGHX39,HXBRK39];
HXCEL40=[DU1H,DU2H,USEGHX40,HXBRK40];
HXCEL41=[DU1H,DU2H,USEGHX41,HXBRK41];
HXCEL42=[DU1H,DU2H,USEGHX42,HXBRK42];
HXCEL43=[DU1H,DU2H,USEGHX43,HXBRK43];
HXCEL44=[DU1H,DU2H,USEGHX44,HXBRK44];
HXCEL45=[DU1H,DU2H,USEGHX45,HXBRK45];
HXCEL46=[DU1H,DU2H,USEGHX46,HXBRK46];%no phase shifter
HXCEL47=[DU1H,DU2H,DUSEGH47,HXBRK47];%empty
HXCEL48=[DU1H,DU2H,DUSEGH48,HXBRK48];%empty
HXCEL49=[DU1H,DU2H,DUSEGH49,HXBRK49];%empty with RFBPM
HXCEL50=[DU1H,DU2H,DUSEGH50,HXBRK50];%empty
HXRCL=[HXCEL13,HXCEL14,HXCEL15,HXCEL16,HXCEL17,HXCEL18,HXCEL19,HXCEL20,HXCEL21,HXCEL22,HXCEL23,HXCEL24,HXCEL25,HXCEL26,HXCEL27,HXCEL28,HXCEL29,HXCEL30,HXCEL31,HXCEL32,HXCEL33,HXCEL34,HXCEL35,HXCEL36,HXCEL37,HXCEL38,HXCEL39,HXCEL40,HXCEL41,HXCEL42,HXCEL43,HXCEL44,HXCEL45,HXCEL46,HXCEL47,HXCEL48,HXCEL49,HXCEL50];
HXR=[BEGUNDH,DU0H,DU8H,HXRSTART,HXRCL,RWWAKE5H,HXRTERM,DUE1A,RFBHX51,DUE1E,ENDUNDH];
% ------------------------------------------------------------------------------
% HXR undulator exit section
% ------------------------------------------------------------------------------
% note: the below K-values are for SC beam; the settings for Cu beam are
% in the "LCLS2cu_main.mad8" file
KQUE1 =  -0.09207220416;
KQUE2 =   0.160489725306;
QUE1={'qu' 'QUE1' LQD/2 [KQUE1 0]}';
QUE2={'qu' 'QUE2' LQD/2 [KQUE2 0]}';
TCX01={'tc' 'TCX01' 1.0/2 [XBANDF 0 0*TWOPI]}';%horizontal deflection
TCX02={'tc' 'TCX02' 1.0/2 [XBANDF 0 0*TWOPI]}';%horizontal deflection
DBKXDMPH={'dr' '' LBKXDMP []}';%placeholder for x-kicker in HXR dumpline
DUE2C={'dr' '' DUE2CB{3}+(LQR-LQD)/2 []}';%0.555
DUE3A={'dr' '' 0.375504+(LQP-LQD)/2+0.11496-0.063643 []}';
DUE3B={'dr' '' 1.2630495-0.11496+0.063643 []}';
DUE4={'dr' '' DUE4B{3}+(LQR-LQD)/2 []}';%0.394
DUE5A={'dr' '' 0.477799+(LQP-LQD)/2+0.012675-0.063653 []}';
DUE5B={'dr' '' 0.264-0.012675+0.063653 []}';
DUE5C={'dr' '' 0.2674 []}';
XCUE2={'mo' 'XCUE2' 0 []}';
XCD3={'mo' 'XCD3' 0 []}';
YCUE1={'mo' 'YCUE1' 0 []}';
YCD3={'mo' 'YCD3' 0 []}';
BPMUE1={'mo' 'BPMUE1' 0 []}';%RFBUE1 : MONI, TYPE="@2,CavityS-1"
BPMUE2={'mo' 'BPMUE2' 0 []}';%RFBUE2 : MONI, TYPE="@2,CavityS-1"
%RFBUE3 : MONI, TYPE="@2,CavityS-1"
%IMUNDO : IMON, TYPE="BCS toroid" BCS toroid
%IMBCS3 : IMON, TYPE="BCS toroid" BCS toroid before dump bend (comparator with IMBCS4)
MIMUNDO={'mo' 'MIMUNDO' 0 []}';
MIMBCS3={'mo' 'MIMBCS3' 0 []}';
TRUE1={'mo' 'TRUE1' 0 []}';%Be foil inserter (THz) -- existing LCLS device
SPTCX={'mo' 'SPTCX' 0 []}';%XTCAV spoiler
BTMQUE={'mo' 'BTMQUE' 0 []}';%Burn-Through-Monitor
BTM0={'mo' 'BTM0' 0 []}';%Burn-Through-Monitor behind the PCPM0
PCTCX={'dr' 'PCTCX' 0 []}';%XTCAV photon collimator (9 mm aperture)
PCPM0={'dr' 'PCPM0' LPCPM []}';
PH31={'mo' 'PH31' 0 []}';%post-undulator phase measurement RF cavity (existing LCLS device)
PH32={'mo' 'PH32' 0 []}';%post-undulator phase measurement RF cavity (existing LCLS device)
PH33={'mo' 'PH33' 0 []}';%post-undulator phase measurement RF cavity (high rate)
PH34={'mo' 'PH34' 0 []}';%post-undulator phase measurement RF cavity (high rate)
UEBEG={'mo' 'UEBEG' 0 []}';
UEEND={'mo' 'UEEND' 0 []}';
VVTCX={'mo' 'VVTCX' 0 []}';%XTCAV vacuum valve
VV36={'mo' 'VV36' 0 []}';%treaty-point vacuum valve just downbeam of undulator
VV37={'mo' 'VV37' 0 []}';%vac. valve in dumpline
MTCX01={'mo' 'MTCX01' 0 []}';%entrance to TCX01 (for ELEGANT WATCH point)
MTCX={'mo' 'MTCX' 0 []}';%centerline between TCX01 and TCX02 (for matching)
DLSTART={'mo' 'DLSTART' 0 []}';%start of dumpline
MDLWALL={'mo' 'MDLWALL' 0 []}';%front face of dumpline thermal barrier wall
UNDEXIT=[BEGDMPH_1,UEBEG,DUE1D,VV36,DUE1B,MIMUNDO,DUE1CA,PH33,DUE1CB,PH34,DUE1CC,DUE2A,YCUE1,DUE2B,PH31,DUE2D,PH32,DUE2E,XCUE2,DUE2C,QUE1,QUE1,DUE3A,BPMUE1,DUE3B,TRUE1,DUE3C,DBKXDMPH,DUE3C,PCTCX,DPCVV,VVTCX,DVVTCX,MTCX01,TCX01,TCX01,DTCX12,MTCX,DTCX12,TCX02,TCX02,DTCXSP,SPTCX,DUE4,QUE2,QUE2,DUE5A,BPMUE2,DUE5B,BTMQUE,DUE5C,PCPM0,DUE5F,BTM0,DUE5D,MIMBCS3,DUE5E,MDLWALL,DDLWALL,UEEND,DLSTART,DSB0A,YCD3,DSB0B,XCD3,DSB0C,VV37,DSB0D,DSB0E,ENDDMPH_1];
HXRUND=[HXR,UNDEXIT];

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2sc safety dump lines
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 26-MAR-2019, M. Woodley
%  * split SFTH and SFTS areas into two subareas each: SFTH_1/SFTH_2
%    and SFTS_1/SFTS_2
% ------------------------------------------------------------------------------
% 08-OCT-2018, M. Woodley
%  * locations of devices downstream of HXR XTES treaty flange per
%    2017-11-21__REF__XTES_BG_HXR__mo37504899_update2017-12-19.xlsx
%  * locations of devices downstream of SXR XTES treaty flange per
%    2017-11-21__REF__XTES_BG_SXR__mo37504999_update2017-12-19.xlsx
%  * some device locations per SD-375-048-01 (SFTH) and SD-375-049-01 (SFTS)
% 20-JUN-2018, M. Woodley
%  * redefine SFTDUMP1 and SFTDUMPB1 beamlines: end at entrance to PM bends
% ------------------------------------------------------------------------------
% 14-FEB-2018, M. Woodley
%  * split SFTDUMP and SFTDUMPb lines to allow XTES output in linac coordinates
% 06-DEC-2017, M. Woodley
%  * add HXTES0 (treaty point flange for HXR XTES system)
%  * add SXTES0 (treaty point flange for SXR XTES system)
% ------------------------------------------------------------------------------
% 24-FEB-2017, Y. Nosochkov
%  * update some parameter names
% ------------------------------------------------------------------------------
% 24-JUN-2016, Y. Nosochkov
%  * move XDCXRAY & YAGXRAY 0.75 m downstream (E. Johnson)
% ------------------------------------------------------------------------------
% 24-AUG-2015, Y. Nosochkov
%  * remove PCPM3/BTM3, PCPM3B/BTM3B as they are not part of electron line
% ------------------------------------------------------------------------------
% 20-MAY-2015, Y. Nosochkov
%  * add PCPM3, PCPM3B, remove BXPM3 (per Shanjie)
%  * update aperture of PCPM1,2,3 and PCPM1B,2B,3B (per LCLSII-3.5-PR-0111-R1)
%  * update positions of PCPM2, BXPM1, BXPM2 (per Shanjie)
%  * move PCPM1, PCPM1B 0.135 m downstream (per A. Ibrahimov)
% ------------------------------------------------------------------------------
% 12-MAR-2015, Y. Nosochkov
%  * add existing XDCXRAY screen in the XDC chamber in HXR
% ------------------------------------------------------------------------------
% 12-DEC-2014, M. Woodley
%  * move area BEG/END MARKers to common.xsif
%  * add SEQ BEG/END MARKers
% 09-DEC-2014, Y. Nosochkov
%  * safety dump lines based on LCLS-I design and PRD LCLSII-3.5-PR-0111
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% HXR safety dump
% ------------------------------------------------------------------------------
% note that axis of BXPM1H,2H bends is parallel to HXR undulator axis but
% horizontally offset by +35 mm towards the North
LBXPM =  0.944               ;%effective straight length of permanent magnet FFTB dump bends (m)
GBXPM0 =  0.0381              ;%original gap height in FFTB magnets in 2005 (m)
GBXPM =  0.052               ;%modified (larger) gap height for LCLS safety dump
BBXPM0 =  4.3                 ;%original magnetic field (kG) at gap = 3.81 cm
BBXPM =  BBXPM0*GBXPM0/GBXPM ;%magnetic field (kG) at gap = 5.2 cm
RBXPM =  BRHOF/BBXPM         ;%bending radius (m) in permanent magnets
ABXPM =  (LBXPM/RBXPM)/2             ;%PM bend half-angle
ABXPM1S =  asin(1*ABXPM)               ;%bending angle of "short" half of BXPM1
ABXPM1L =  asin(2*ABXPM)-asin(1*ABXPM) ;%bending angle of "long"  half of BXPM1
ABXPM2S =  asin(3*ABXPM)-asin(2*ABXPM) ;%bending angle of "short" half of BXPM2
ABXPM2L =  asin(4*ABXPM)-asin(3*ABXPM) ;%bending angle of "long"  half of BXPM2
ABXPM1 =  ABXPM1S+ABXPM1L;
ABXPM2 =  ABXPM2S+ABXPM2L;
LBXPM1S =  RBXPM*ABXPM1S ;%path length in "short" half of BXPM1
LBXPM1L =  RBXPM*ABXPM1L ;%path length in "long"  half of BXPM1
LBXPM2S =  RBXPM*ABXPM2S ;%path length in "short" half of BXPM2
LBXPM2L =  RBXPM*ABXPM2L ;%path length in "long"  half of BXPM2
BXPM1A={'be' 'BXPM1' LBXPM1S [ABXPM1S GBXPM/2 0 0 0.5 0.0 0]}';
BXPM1B={'be' 'BXPM1' LBXPM1L [ABXPM1L GBXPM/2 0 ABXPM1 0.0 0.5 0]}';
BXPM2A={'be' 'BXPM2' LBXPM2S [ABXPM2S GBXPM/2 -ABXPM1 0 0.5 0.0 0]}';
BXPM2B={'be' 'BXPM2' LBXPM2L [ABXPM2L GBXPM/2 0 ABXPM1+ABXPM2 0.0 0.5 0]}';
DYDS={'dr' '' LBYDS*cos(ABYDS/2) []}';
DYD1={'dr' '' LBDM*cos(ABYDS+ABDM/2) []}';
DYD2={'dr' '' LBDM*cos(ABYDS+3*ABDM/2) []}';
DYD3={'dr' '' LBDM*cos(ABYDS+5*ABDM/2) []}';
LDSCA =  0.479300 ;%0.479298938157
LDSCB =  0.094517171073;
DS1S={'dr' '' LDS1*cos(ABYDS) []}';
DSSA={'dr' '' LDS*cos(ABYDS+ABDM) []}';
DSSB={'dr' '' LDS*cos(ABYDS+2*ABDM) []}';
DSCSA={'dr' '' LDSCA*cos(ABYDS+3*ABDM) []}';
DSCSB={'dr' '' LDSCB*cos(ABYDS+3*ABDM) []}';
LDPM3 =  8.784;
LDPM31 =  8.2704483799;
LDPM32 =  LDPM3-LDPM31;
ZSFTDMP =  0.0762 ;%safety dump Z-length
DPCBTM1={'dr' '' 0.15-0.135 []}';
DPCBTM2={'dr' '' 0.15 []}';
DPM1={'dr' '' 0.5350338 []}';%0.298
DPM2={'dr' '' 0.30/cos(ABXPM1) []}';
DPM3={'dr' '' LDPM3/cos(ABXPM1+ABXPM2) []}';
DPM31={'dr' '' LDPM31/cos(ABXPM1+ABXPM2) []}';
DPM32={'dr' '' LDPM32/cos(ABXPM1+ABXPM2) []}';
DPCBTM3={'dr' '' 0 []}';%BTM3 is attached to d/s face of PCPM3
DPM4={'dr' '' 2.42/cos(ABXPM1+ABXPM2) []}';
DSFTDMP={'dr' '' ZSFTDMP/cos(ABXPM1+ABXPM2) []}';
DXDCU={'dr' '' 1.092223+0.75 []}';
DXDCU1={'dr' '' 0.8783 []}';
DXDCU2={'dr' '' DXDCU{3}-DXDCU1{3} []}';
XDCA={'dr' '' 0.312777 []}';%XDC chamber
XDCB={'dr' '' 0.693 []}';%XDC chamber
XDCC={'dr' '' 0.542 []}';%XDC chamber
XDCD={'dr' '' 0.255376 []}';%XDC chamber
DXDCD={'dr' '' 7.1789662-DXDCU{3}-XDCA{3}-XDCB{3}-XDCC{3}-XDCD{3} []}';%7.266
DXDCD1={'dr' '' 2.661321 []}';
DXDCD2={'dr' '' 0.512986 []}';
DXDCD3={'dr' '' DXDCD{3}-DXDCD1{3}-DXDCD2{3} []}';
PCPM1={'dr' 'PCPM1' LPCPM []}';%per LCLSII-3.5-PR-0111-R1
PCPM2={'dr' 'PCPM2' LPCPM []}';
%PCPM3  : ECOL, L=LPCPMW/COS(ABXPM1+ABXPM2), XSIZE=0.0080, YSIZE=0.0080
DPCPM3={'dr' '' LPCPMW/cos(ABXPM1+ABXPM2) []}';%placeholder for PCPM3
BTM1={'mo' 'BTM1' 0 []}';%Burn-Through-Monitor behind PCPM1
BTM2={'mo' 'BTM2' 0 []}';%Burn-Through-Monitor behind PCPM2
%BTM3   : INST Burn-Through-Monitor behind PCPM3
MBTM3={'mo' 'MBTM3' 0 []}';%placeholder for BTM3
BTMSFT={'mo' 'BTMSFT' 0 []}';%Burn-Through-Monitor behind HXR safety dump
XDCXRAY={'mo' 'XDCXRAY' 0 []}';%existing safety dump line X-ray screen
YAGXRAY={'mo' 'YAGXRAY' 0 []}';%existing safety dump line X-ray screen
HXTES0={'mo' 'HXTES0' 0 []}';%treaty point for HXR XTES system
IM1H={'mo' 'IM1H' 0 []}';
SFTDMP={'mo' 'SFTDMP' 0 []}';%front face of HXR safety dump (Z'=712-715 m per PRD)
VV38={'mo' 'VV38' 0 []}';%vac. valve in HXR safety dump line
VV1H={'mo' 'VV1H' 0 []}';%vac. valve in HXR XTES line
VV2H={'mo' 'VV2H' 0 []}';%vac. valve in HXR XTES line
MVV10={'mo' 'MVV10' 0 []}';%placeholder for vac. valve in HXR XTES line
SFTDUMP1=[BEGSFTH_1,DYDS,DS1S,DYD1,DSSA,DYD2,DSSB,DYD3,DSCSA,VV38,DSCSB,PCPM1,DPCBTM1,BTM1,DXDCU1,HXTES0,DXDCU2,XDCA,XDCXRAY,XDCB,XDCC,YAGXRAY,XDCD,DXDCD1,VV2H,DXDCD2,IM1H,DXDCD3,BTM2,PCPM2,DPM1,ENDSFTH_1];
SFTDUMP2=[BEGSFTH_2,BXPM1A,BXPM1B,DPM2,BXPM2A,BXPM2B,DPM31,MVV10,DPM32,DPCPM3,DPCBTM3,MBTM3,DPM4,SFTDMP,DSFTDMP,BTMSFT,ENDSFTH_2];
SFTDUMP=[SFTDUMP1,SFTDUMP2];
% ------------------------------------------------------------------------------
% SXR safety dump
% ------------------------------------------------------------------------------
% note that BXPM1b bend axis is aligned with the SXR undulator axis without
% any offset
RBXPMB =  BRHOF/BBXPM ;%bending radius (m) in permanent magnet
ABXPMB =  (LBXPM/RBXPMB)/2            ;%PM bend half-angle
ABXPM1BS =  asin(ABXPMB)                ;%bending angle of "short" half of BXPM1B
ABXPM1BL =  asin(2*ABXPMB)-asin(ABXPMB) ;%bending angle of "long"  half of BXPM1B
LBXPM1BS =  RBXPMB*ABXPM1BS ;%path length in "short" half of BXPM1B
LBXPM1BL =  RBXPMB*ABXPM1BL ;%path length in "long"  half of BXPM1B
BXPM1BA={'be' 'BXPM1B' LBXPM1BS [ABXPM1BS GBXPM/2 0 0 0.5 0.0 0]}';
BXPM1BB={'be' 'BXPM1B' LBXPM1BL [ABXPM1BL GBXPM/2 0 ABXPM1BS+ABXPM1BL 0.0 0.5 0]}';
DSCSB1={'dr' '' 0.478198407804 []}';%DSCSa[L]
DSCSB2={'dr' '' 0.0943 []}';%DSCSa[L]
DXDCUB={'dr' '' 1.842223 []}';%1.092223
DXDCUB1={'dr' '' 0.8407994 []}';%0.878299738776
DXDCUB2={'dr' '' 0.0375006 []}';
DXDCUB3={'dr' '' DXDCUB{3}-DXDCUB1{3}-DXDCUB2{3} []}';
XDCBA={'dr' '' 0.312777 []}';%XDC chamber
XDCBB={'dr' '' 0.693 []}';%XDC chamber
XDCBC={'dr' '' 0.542 []}';%XDC chamber
XDCBD={'dr' '' 0.255376 []}';%XDC chamber
DXDCDB={'dr' '' 7.266-DXDCUB{3}-XDCBA{3}-XDCBB{3}-XDCBC{3}-XDCBD{3} []}';
DXDCDB1={'dr' '' 0.262395 []}';
DXDCDB2={'dr' '' 0.363747 []}';
DXDCDB3={'dr' '' 0.966253 []}';
DXDCDB4={'dr' '' 1.492023 []}';
DXDCDB5={'dr' '' DXDCDB{3}-DXDCDB1{3}-DXDCDB2{3}-DXDCDB3{3}-DXDCDB4{3} []}';
DPM1B={'dr' '' 0.448 []}';
DPM2B={'dr' '' 3.8732111/cos(ABXPM1BS+ABXPM1BL) []}';%10.03
DPM2BA={'dr' '' 3.8732111/cos(ABXPM1BS+ABXPM1BL) []}';
DPM2BB={'dr' '' DPM2B{3}-DPM2BA{3} []}';
DPCBTM3B={'dr' '' 0 []}';%BTM3B is attached to d/s face of PCPM3B
DPM3B={'dr' '' 8.5747889/cos(ABXPM1BS+ABXPM1BL) []}';%2.272
DPM3BA={'dr' '' 0.6560246/cos(ABXPM1BS+ABXPM1BL) []}';
DPM3BB={'dr' '' DPM3B{3}-DPM3BA{3} []}';
DSFTDMPB={'dr' '' ZSFTDMP/cos(ABXPM1BS+ABXPM1BL) []}';
PCPM1B={'dr' 'PCPM1B' LPCPM []}';%per LCLSII-3.5-PR-0111-R1
PCPM2B={'dr' 'PCPM2B' LPCPM []}';
%PCPM3B  : ECOL, L=LPCPM/COS(ABXPM1BS+ABXPM1BL), XSIZE=0.0100, YSIZE=0.0100
DPCPM3B={'dr' '' LPCPMW/cos(ABXPM1BS+ABXPM1BL) []}';%placeholder for PCPM3B
BTM1B={'mo' 'BTM1B' 0 []}';%Burn-Through-Monitor behind PCPM1B
BTM2B={'mo' 'BTM2B' 0 []}';%Burn-Through-Monitor behind PCPM2B
%BTM3B   : INST Burn-Through-Monitor behind PCPM3B
MBTM3B={'mo' 'MBTM3B' 0 []}';%placeholder for BTM3B
BTMSFTB={'mo' 'BTMSFTB' 0 []}';%Burn-Through-Monitor behind SXR safety dump
YAGXRAYB={'mo' 'YAGXRAYB' 0 []}';%safety dump line X-ray screen
SXTES0={'mo' 'SXTES0' 0 []}';%treaty point for SXR XTES system
PC1S={'mo' 'PC1S' 0 []}';
GMD1S={'mo' 'GMD1S' 0 []}';
IM1S={'mo' 'IM1S' 0 []}';
MSL1S={'mo' 'MSL1S' 0 []}';
SFTDMPB={'mo' 'SFTDMPB' 0 []}';%front face of SXR safety dump (Z'=712-715 m per PRD)
VV38B={'mo' 'VV38B' 0 []}';%vac. valve in SXR safety dump line
VV1S={'mo' 'VV1S' 0 []}';%vac. valve in SXR safety dump line
VV2S={'mo' 'VV2S' 0 []}';%vac. valve in SXR safety dump line
MVV3S={'mo' 'MVV3S' 0 []}';%placeholder for vac. valve in SXR XTES line
SFTDUMPB1=[BEGSFTS_1,DYDS,DS1S,DYD1,DSSA,DYD2,DSSB,DYD3,DSCSB1,VV38B,DSCSB2,PCPM1B,DPCBTM1,BTM1B,DXDCUB1,VV1S,DXDCUB2,SXTES0,DXDCUB3,XDCBA,XDCBB,XDCBC,YAGXRAYB,XDCBD,DXDCDB1,PC1S,DXDCDB2,VV2S,DXDCDB3,GMD1S,DXDCDB4,IM1S,DXDCDB5,BTM2B,PCPM2B,DPM1B,ENDSFTS_1];
SFTDUMPB2=[BEGSFTS_2,BXPM1BA,BXPM1BB,DPM2BA,DPCPM3B,DPCBTM3B,MBTM3B,DPM2BB,MSL1S,DPM3BA,MVV3S,DPM3BB,SFTDMPB,DSFTDMPB,BTMSFTB,ENDSFTS_2];
SFTDUMPB=[SFTDUMPB1,SFTDUMPB2];

% *** OPTICS=AD_ACCEL-13JUN19 ***
% HXR XTES
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 20-JUN-2018, M. Woodley
%  * PCPM3: keyw=ECOL, L=LPCPMW, XSIZE=0.008, YSIZE=0.008
% ------------------------------------------------------------------------------
% 09-JAN-2018, M. Woodley
%  * from: 2017-11-21__REF__XTES_BG_HXR__mo37504899_update2017-12-19.xlsx
% ------------------------------------------------------------------------------
% ==============================================================================
% mirrors
% ------------------------------------------------------------------------------
% NOTE: change mirrors from MULT to INST for Matlab model generator creation
A1X =  -0.0042 ;
A1Y =  0.0;
A2X =   0.0042 ;
A2Y =  0.0;
M1L0={'mu' 'M1L0' 0 [A1X 0 0 0]}';
M2L0={'mu' 'M2L0' 0 [A2X 0 0 0]}';
%M1L0 : INST, TYPE="MIRROR"
%M2L0 : INST, TYPE="MIRROR"
% ==============================================================================
% DRIF
% ------------------------------------------------------------------------------
A12X =  A1X+A2X ;
A12Y =  A1Y +A2Y;
DHXTES01={'dr' '' 0.472 []}';
DHXTES02={'dr' '' 1.244 []}';
DHXTES03={'dr' '' 3.506 []}';
DHXTES04={'dr' '' 1.0 []}';
DHXTES05={'dr' '' 0.0 []}';
DHXTES06={'dr' '' 0.0 []}';
DHXTES07={'dr' '' 4.2364483799 []}';
DHXTES08={'dr' '' 0.1422748201 []}';
DHXTES09={'dr' '' 0.0 []}';
DHXTES10={'dr' '' 0.4112768-LPCPMW/2 []}';
DHXTES11={'dr' '' 0.0 []}';
DHXTES12={'dr' '' 0.16-LPCPMW/2 []}';
DHXTES13={'dr' '' 0.8059 []}';
DHXTES14={'dr' '' 0.0 []}';
DHXTES15={'dr' '' 1.1298914 []}';
DHXTES16={'dr' '' 0.3642086 []}';
DHXTES17={'dr' '' 0.0762 []}';
DHXTES18={'dr' '' 5.5038 []}';
DHXTES19={'dr' '' 2.34 []}';
DHXTES20={'dr' '' 0.2151282 []}';
DHXTES21={'dr' '' 0.0966606 []}';
DHXTES22={'dr' '' 0.0 []}';
DHXTES23={'dr' '' 0.0 []}';
DHXTES24={'dr' '' 2.20007119 []}';
DHXTES25={'dr' '' 0.06335691 []}';
DHXTES26={'dr' '' 1.7027831 []}';
DHXTES27={'dr' '' 3.097995 []}';
DHXTES28={'dr' '' 3.098005 []}';
DHXTES29={'dr' '' 1.623186076 []}';
DHXTES30={'dr' '' 0.0 []}';
DHXTES31={'dr' '' 0.0 []}';
DHXTES32={'dr' '' 0.505514924 []}';
DHXTES33={'dr' '' 0.4156609 []}';
DHXTES34={'dr' '' 0.2727363 []}';
DHXTES35={'dr' '' 0.1793446 []}';
DHXTES36={'dr' '' 0.2931593 []}';
DHXTES37={'dr' '' 0.4112028 []}';
DHXTES38={'dr' '' 1.2223747 []}';
DHXTES39={'dr' '' 0.5262329 []}';
DHXTES40={'dr' '' 0.487171995 []}';
DHXTES41={'dr' '' 0.431850805 []}';
DHXTES42={'dr' '' 0.1409877 []}';
DHXTES43={'dr' '' 0.0 []}';
DHXTES44={'dr' '' 0.0 []}';
DHXTES45={'dr' '' 0.1423749 []}';
DHXTES46={'dr' '' 0.9542021 []}';
% mirror #1 (M1L0; horizontal)
DHXTES47={'dr' '' 1.0397644/cos(A1X)/cos(A1Y) []}';
DHXTES48={'dr' '' 2.4731437/cos(A1X)/cos(A1Y) []}';
DHXTES49={'dr' '' 0.0/cos(A1X)/cos(A1Y) []}';
DHXTES50={'dr' '' 0.308033894/cos(A1X)/cos(A1Y) []}';
DHXTES51={'dr' '' 0.319058006/cos(A1X)/cos(A1Y) []}';
DHXTES52={'dr' '' 0.12245/cos(A1X)/cos(A1Y) []}';
DHXTES53={'dr' '' 0.0568946/cos(A1X)/cos(A1Y) []}';
DHXTES54={'dr' '' 0.3206554/cos(A1X)/cos(A1Y) []}';
DHXTES55={'dr' '' 1.4845097/cos(A1X)/cos(A1Y) []}';
DHXTES56={'dr' '' 0.1422743/cos(A1X)/cos(A1Y) []}';
DHXTES57={'dr' '' 0.0/cos(A1X)/cos(A1Y) []}';
DHXTES58={'dr' '' 0.0/cos(A1X)/cos(A1Y) []}';
DHXTES59={'dr' '' 0.0/cos(A1X)/cos(A1Y) []}';
DHXTES60={'dr' '' 1.019216/cos(A1X)/cos(A1Y) []}';
% mirror #2 (M2L0; horizontal)
DHXTES61={'dr' '' 0.9667925/cos(A12X)/cos(A12Y) []}';
DHXTES62={'dr' '' 0.4503304/cos(A12X)/cos(A12Y) []}';
DHXTES63={'dr' '' 0.5268771/cos(A12X)/cos(A12Y) []}';
DHXTES64={'dr' '' 0.0/cos(A12X)/cos(A12Y) []}';
DHXTES65={'dr' '' 0.0/cos(A12X)/cos(A12Y) []}';
DHXTES66={'dr' '' 0.0/cos(A12X)/cos(A12Y) []}';
DHXTES67={'dr' '' 0.0/cos(A12X)/cos(A12Y) []}';
DHXTES68={'dr' '' 0.3351736/cos(A12X)/cos(A12Y) []}';
DHXTES69={'dr' '' 0.142401456/cos(A12X)/cos(A12Y) []}';
DHXTES70={'dr' '' 2.167424944/cos(A12X)/cos(A12Y) []}';
DHXTES71={'dr' '' 0.12245/cos(A12X)/cos(A12Y) []}';
DHXTES72={'dr' '' 0.0568946/cos(A12X)/cos(A12Y) []}';
DHXTES73={'dr' '' 1.3854904/cos(A12X)/cos(A12Y) []}';
DHXTES74={'dr' '' 0.73931966/cos(A12X)/cos(A12Y) []}';
DHXTES75={'dr' '' 0.77084634/cos(A12X)/cos(A12Y) []}';
DHXTES76={'dr' '' 0.654999/cos(A12X)/cos(A12Y) []}';
DHXTES77={'dr' '' 0.12245/cos(A12X)/cos(A12Y) []}';
DHXTES78={'dr' '' 0.0568946/cos(A12X)/cos(A12Y) []}';
DHXTES79={'dr' '' 0.3058936/cos(A12X)/cos(A12Y) []}';
DHXTES80={'dr' '' 0.2697618/cos(A12X)/cos(A12Y) []}';
DHXTES81={'dr' '' 1.93/cos(A12X)/cos(A12Y) []}';
DHXTES82={'dr' '' 1.71/cos(A12X)/cos(A12Y) []}';
DHXTES83={'dr' '' 0.0/cos(A12X)/cos(A12Y) []}';
DHXTES84={'dr' '' 0.0/cos(A12X)/cos(A12Y) []}';
DHXTES85={'dr' '' 2.8140924/cos(A12X)/cos(A12Y) []}';
DHXTES86={'dr' '' 4.1859076/cos(A12X)/cos(A12Y) []}';
% ==============================================================================
% instruments
% ------------------------------------------------------------------------------
MBXPM1={'mo' 'MBXPM1' 0 []}';
MBXPM2={'mo' 'MBXPM2' 0 []}';
IP5H={'mo' 'IP5H' 0 []}';
R02H={'mo' 'R02H' 0 []}';
CG1H={'mo' 'CG1H' 0 []}';
PG1H={'mo' 'PG1H' 0 []}';
VV10={'mo' 'VV10' 0 []}';
IP7H={'mo' 'IP7H' 0 []}';
R03H={'mo' 'R03H' 0 []}';
PCPM3={'dr' 'PCPM3' LPCPMW []}';
BTM3={'mo' 'BTM3' 0 []}';%Burn-Through-Monitor behind PCPM3
SENSOR1={'mo' 'SENSOR1' 0 []}';
CG7H={'mo' 'CG7H' 0 []}';
PG7H={'mo' 'PG7H' 0 []}';
IP6H={'mo' 'IP6H' 0 []}';
MSFTDMP={'mo' 'MSFTDMP' 0 []}';
MBTMSFT={'mo' 'MBTMSFT' 0 []}';
WALL1HE={'mo' 'WALL1HE' 0 []}';
WALL1HW={'mo' 'WALL1HW' 0 []}';
VV3H={'mo' 'VV3H' 0 []}';
R06H={'mo' 'R06H' 0 []}';
CG2H={'mo' 'CG2H' 0 []}';
PG2H={'mo' 'PG2H' 0 []}';
SL1H={'mo' 'SL1H' 0 []}';
IP1H={'mo' 'IP1H' 0 []}';
GEM1={'mo' 'GEM1' 0 []}';
AT1H={'mo' 'AT1H' 0 []}';
GEM2={'mo' 'GEM2' 0 []}';
RO7H={'mo' 'RO7H' 0 []}';
CG10H={'mo' 'CG10H' 0 []}';
PG10H={'mo' 'PG10H' 0 []}';
AT2H={'mo' 'AT2H' 0 []}';
VV4H={'mo' 'VV4H' 0 []}';
PC1H={'mo' 'PC1H' 0 []}';
PCB1H={'mo' 'PCB1H' 0 []}';
IM2H={'mo' 'IM2H' 0 []}';
SL2H={'mo' 'SL2H' 0 []}';
SP2H={'mo' 'SP2H' 0 []}';
RGA1H={'mo' 'RGA1H' 0 []}';
PA1H={'mo' 'PA1H' 0 []}';
FV1H={'mo' 'FV1H' 0 []}';
R04H={'mo' 'R04H' 0 []}';
CG3H={'mo' 'CG3H' 0 []}';
PG3H={'mo' 'PG3H' 0 []}';
VV5H={'mo' 'VV5H' 0 []}';
IP8H={'mo' 'IP8H' 0 []}';
CG4H={'mo' 'CG4H' 0 []}';
PG4H={'mo' 'PG4H' 0 []}';
IM3H={'mo' 'IM3H' 0 []}';
PC2H={'mo' 'PC2H' 0 []}';
BTM2H={'mo' 'BTM2H' 0 []}';
PCB2H={'mo' 'PCB2H' 0 []}';
SW1H={'mo' 'SW1H' 0 []}';
VV6H={'mo' 'VV6H' 0 []}';
IP2H={'mo' 'IP2H' 0 []}';
CG5H={'mo' 'CG5H' 0 []}';
PG5H={'mo' 'PG5H' 0 []}';
BD1H={'mo' 'BD1H' 0 []}';
FV2H={'mo' 'FV2H' 0 []}';
PA2H={'mo' 'PA2H' 0 []}';
RGA2H={'mo' 'RGA2H' 0 []}';
RO5H={'mo' 'RO5H' 0 []}';
CG6H={'mo' 'CG6H' 0 []}';
PG6H={'mo' 'PG6H' 0 []}';
PC5H={'mo' 'PC5H' 0 []}';
IP11H={'mo' 'IP11H' 0 []}';
VV7H={'mo' 'VV7H' 0 []}';
PC3H={'mo' 'PC3H' 0 []}';
BTM3H={'mo' 'BTM3H' 0 []}';
PCB3H={'mo' 'PCB3H' 0 []}';
IP9H={'mo' 'IP9H' 0 []}';
IM4H={'mo' 'IM4H' 0 []}';
ST1H={'mo' 'ST1H' 0 []}';
PC4H={'mo' 'PC4H' 0 []}';
BTM4H={'mo' 'BTM4H' 0 []}';
PCB4H={'mo' 'PCB4H' 0 []}';
IP10H={'mo' 'IP10H' 0 []}';
WALL2HE={'mo' 'WALL2HE' 0 []}';
WALL2HW={'mo' 'WALL2HW' 0 []}';
RO8H={'mo' 'RO8H' 0 []}';
CG8H={'mo' 'CG8H' 0 []}';
PG8H={'mo' 'PG8H' 0 []}';
VV11H={'mo' 'VV11H' 0 []}';
SENSOR2={'mo' 'SENSOR2' 0 []}';
% ==============================================================================
% BEAMLINE
% ------------------------------------------------------------------------------
HXTES=[BEGHXTES,DHXTES01,MBXPM1,DHXTES02,MBXPM2,DHXTES03,IP5H,DHXTES04,R02H,DHXTES05,CG1H,DHXTES06,PG1H,DHXTES07,VV10,DHXTES08,IP7H,DHXTES09,R03H,DHXTES10,PCPM3,DHXTES11,BTM3,DHXTES12,SENSOR1,DHXTES13,CG7H,DHXTES14,PG7H,DHXTES15,IP6H,DHXTES16,MSFTDMP,DHXTES17,MBTMSFT,DHXTES18,WALL1HE,DHXTES19,WALL1HW,DHXTES20,VV3H,DHXTES21,R06H,DHXTES22,CG2H,DHXTES23,PG2H,DHXTES24,SL1H,DHXTES25,IP1H,DHXTES26,GEM1,DHXTES27,AT1H,DHXTES28,GEM2,DHXTES29,RO7H,DHXTES30,CG10H,DHXTES31,PG10H,DHXTES32,AT2H,DHXTES33,VV4H,DHXTES34,PC1H,DHXTES35,PCB1H,DHXTES36,IM2H,DHXTES37,SL2H,DHXTES38,SP2H,DHXTES39,RGA1H,DHXTES40,PA1H,DHXTES41,FV1H,DHXTES42,R04H,DHXTES43,CG3H,DHXTES44,PG3H,DHXTES45,VV5H,DHXTES46,M1L0,DHXTES47,IP8H,DHXTES48,CG4H,DHXTES49,PG4H,DHXTES50,IM3H,DHXTES51,PC2H,DHXTES52,BTM2H,DHXTES53,PCB2H,DHXTES54,SW1H,DHXTES55,VV6H,DHXTES56,IP2H,DHXTES57,CG5H,DHXTES58,PG5H,DHXTES59,BD1H,DHXTES60,M2L0,DHXTES61,FV2H,DHXTES62,PA2H,DHXTES63,RGA2H,DHXTES64,RO5H,DHXTES65,CG6H,DHXTES66,PG6H,DHXTES67,PC5H,DHXTES68,IP11H,DHXTES69,VV7H,DHXTES70,PC3H,DHXTES71,BTM3H,DHXTES72,PCB3H,DHXTES73,IP9H,DHXTES74,IM4H,DHXTES75,ST1H,DHXTES76,PC4H,DHXTES77,BTM4H,DHXTES78,PCB4H,DHXTES79,IP10H,DHXTES80,WALL2HE,DHXTES81,WALL2HW,DHXTES82,RO8H,DHXTES83,CG8H,DHXTES84,PG8H,DHXTES85,VV11H,DHXTES86,SENSOR2,ENDHXTES];
% ------------------------------------------------------------------------------

% *** OPTICS=AD_ACCEL-13JUN19 ***
% LCLS2cu various parts upstream of BSY
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 30-JAN-2019, M. Woodley
%  * move area BEG/END MARKERs to common.xsif
%  * DL1 becomes two areas (DL1_1 and DL1_2)
%  * rename MRK/FIN MARKERs at BC1 and BC2 to proper area boundary names
% ------------------------------------------------------------------------------
% 07-JAN-2019, M. Woodley
%  * rename some LI21 correctors to avoid name conflicts with LCLS-II
%    per T. Maxwell
%  * define BC1 and BC2 bend angles (rather than B-fields) to allow constant
%    R56 when energy changes
%  * remove "52-line stuff"
% ------------------------------------------------------------------------------
% 08-MAY-2017, M. Woodley
%  * add 0.000001 m to DM19 to force Z=2059.732900 m at ZLIN04 and to line up
%    sector boundaries; reduce DAQ17 by the same amount to compensate
% 01-MAR-2017, M. Woodley
%  * WS24 is actually installed (per LCLS)
% ------------------------------------------------------------------------------
% 23-NOV-2016, Y. Nosochkov
%  * update KQ30801 value
% ------------------------------------------------------------------------------
% 04-NOV-2016, M. Woodley
%  * change "1.259Q3.5" to "1.26Q3.5"
%  * change Everson-Tesla 2.362Q3.5 (r=30mm) to SigmaPhi 1.69Q3.4 (bore=43mm)
%  * remove definition of DRIFT "DAQ6A"
% ------------------------------------------------------------------------------
% 28-OCT-2014, M. Woodley
%  * redefine drift DAQ17 to end at LI30 IV30-9 (Z=3042.005)
% ==============================================================================
LSOL1 =  0.200 ;%needed for DL01a definition
% ==============================================================================
% Longitudinal misalignments observed after installation and difficult to fix:
% Added to MAD file (but not drawings) so that optics comes out right (1/11/07).
% ------------------------------------------------------------------------------
DZ_QA11 =  3.42E-3    ;%quad is too far downstream when dz>0
DZ_Q21201 = -2.39E-3    ;%quad is too far downstream when dz>0
DZ_Q21301 =  5.73E-3    ;%quad is too far downstream when dz>0
DZ_QM14 =  2.17E-3    ;%quad is too far downstream when dz>0
DZ_QM15 =  2.48E-3    ;%quad is too far downstream when dz>0
% ==============================================================================
% LCAVs
% ------------------------------------------------------------------------------
% global LCAV parameters
DLWLX =  0.5948  ;%X-band structure length from input-coupler center to output-coupler center, each with tooling balls (m)
DLWL10 =  3.0441  ;%"10  ft" (29 Sband wavelengths; 87 DLWG cavities)
DLWL9 =  2.8692  ;%"9.41 ft" (27 1/3 Sband wavelengths; 82 DLWG cavities)
DLWL7 =  2.1694  ;%"7   ft" (20 2/3 Sband wavelengths; 62 DLWG cavities)
P25 =  1       ;%25% power factor
P50 =  sqrt(2) ;%50% power factor
% L0 energy profile (model the one 3-m L0b section only)
L0PHASE =  -1.1              ;%L0b S-band rf phase (deg)
DEL0A =  GEV2MEV*(E0I-E00) ;%total L0a energy gain (MeV)
DEL0B =  GEV2MEV*(EI-E0I)  ;%total L0b energy gain (MeV)
PHIL0 =  L0PHASE/360       ;%radians/2pi
%gfac0   := 3.130139          flange-to-flange length of dual-feed L0-a and L0-b RF structures [m]
GFAC0 =  3.095244          ;%flange-to-flange length (121.86" Oct. 18, '05) of dual-feed L0-a and L0-b RF structures [m]
GRADL0A =  DEL0A/(GFAC0*cos(PHIL0*TWOPI));
GRADL0B =  DEL0B/(GFAC0*cos(PHIL0*TWOPI));
% L1 energy profile
L1PHASE =  -25.1             ;%L1 S-band rf phase (deg)
L1XPHASE = -160.0             ;%L1 X-band rf phase (deg)
DEL1 =  GEV2MEV*(EBC1-EI) ;%total L1 energy gain (MeV)
DEL1X =  19.0              ;%L1 X-band amplitude (MeV)
PHIL1 =  L1PHASE/360       ;%radians/2pi
PHIL1X =  L1XPHASE/360      ;%radians/2pi
GFAC1 =  P50*DLWL9+P25*DLWL9+P25*DLWL10;
GRADL1 =  (DEL1-DEL1X*cos(PHIL1X*TWOPI))/(GFAC1*cos(PHIL1*TWOPI));
%VALUE, gradL1
% L2 energy profile
L2PHASE =  -41.4               ;%L2 rf phase (deg)
DEL2 =  GEV2MEV*(EBC2-EBC1) ;%total L2 energy gain (MeV)
PHIL2 =  L2PHASE/360         ;%radians/2pi
GFAC2 =  110*P25*DLWL10+1*P50*DLWL10;
GRADL2 =  DEL2/(GFAC2*cos(PHIL2*TWOPI));
%VALUE, gradL2
% L3 energy profile
L3PHASE =  0.0               ;%L3 rf phase (deg)
DEL3 =  GEV2MEV*(EF-EBC2) ;%total L3 energy gain (MeV)
PHIL3 =  L3PHASE/360       ;%radians/2pi
GFAC3 =  161*P25*DLWL10 + 12*P50*DLWL10 + 3*P25*DLWL9 + 4*P25*DLWL7;
GRADL3 =  DEL3/(GFAC3*cos(PHIL3*TWOPI));
%VALUE, gradL3
L1X___1={'lc' 'L1X' DLWLX/2 [XBANDF DEL1X/2 PHIL1X*TWOPI]}';
L1X___2={'lc' 'L1X' DLWLX/2 [XBANDF DEL1X/2 PHIL1X*TWOPI]}';
% L0 sections
L0A___1={'lc' 'L0A' 0.0586460 [SBANDF GRADL0A*0.0586460 PHIL0*TWOPI]}';
L0A___2={'lc' 'L0A' 0.1993540 [SBANDF GRADL0A*0.1993540 PHIL0*TWOPI]}';
L0A___3={'lc' 'L0A' 0.6493198 [SBANDF GRADL0A*0.6493198 PHIL0*TWOPI]}';
L0A___4={'lc' 'L0A' 0.6403022 [SBANDF GRADL0A*0.6403022 PHIL0*TWOPI]}';
L0A___5={'lc' 'L0A' 1.1518464 [SBANDF GRADL0A*1.1518464 PHIL0*TWOPI]}';
L0A___6={'lc' 'L0A' 0.3348566 [SBANDF GRADL0A*0.3348566 PHIL0*TWOPI]}';
L0A___7={'lc' 'L0A' 0.0609190 [SBANDF GRADL0A*0.0609190 PHIL0*TWOPI]}';
L0B___1={'lc' 'L0B' 0.0586460 [SBANDF GRADL0B*0.0586460 PHIL0*TWOPI]}';
L0B___2={'lc' 'L0B' 0.3371281 [SBANDF GRADL0B*0.3371281 PHIL0*TWOPI]}';
L0B___3={'lc' 'L0B' 1.1518479 [SBANDF GRADL0B*1.1518479 PHIL0*TWOPI]}';
L0B___4={'lc' 'L0B' 1.1515630 [SBANDF GRADL0B*1.1515630 PHIL0*TWOPI]}';
L0B___5={'lc' 'L0B' 0.3351400 [SBANDF GRADL0B*0.3351400 PHIL0*TWOPI]}';
L0B___6={'lc' 'L0B' 0.0609190 [SBANDF GRADL0B*0.0609190 PHIL0*TWOPI]}';
FLNGA1={'mo' 'FLNGA1' 0 []}';%upstream   face of L0a entrance flange
FLNGA2={'mo' 'FLNGA2' 0 []}';%downstream face of L0a exit flange
FLNGB1={'mo' 'FLNGB1' 0 []}';%upstream   face of L0b entrance flange
FLNGB2={'mo' 'FLNGB2' 0 []}';%downstream face of L0b exit flange
% transverse deflecting cavities
%TCAV0 : DRIF, L=0.6680236/2  flange-to-flange (then split in two)
%TCAV3 : DRIF, L=2.438/2
TCAV0={'tc' 'TCAV0' 0.6680236/2 [0 0 0*TWOPI]}';%flange-to-flange (then split in two)
TCAV3={'tc' 'TCAV3' 2.438/2 [0 0 0*TWOPI]}';
%LKIK   := 1.0601               kicker coil length per magnet (m) [41.737 in from SA-380-330-02, rev. 0]
BXKIKA={'be' 'BXKIK' LKIK/2 [1E-12 25.4E-3 0 0 0.5 0 0]}';
BXKIKB={'be' 'BXKIK' LKIK/2 [1E-12 25.4E-3 0 2E-12 0 0.5 0]}';
% ==============================================================================
% BENDs
% ------------------------------------------------------------------------------
% global BEND parameters
DLBH =  0.0144     ;%increase to lengthen BXH1-4 eff. length (m)
LBH =  0.110+DLBH ;%5D3.9 "Z" length (m)   laser-heater chicane bends approx. effective length (R. Carr, 01-AUG-05 -PE)
GBH =  30E-3      ;%5D3.9 gap height (m)
LB0 =  0.2032     ;%5D7.1 "Z" length (m)
GB0 =  30E-3      ;%5D7.1 gap height (m)
LB1 =  0.2032     ;%5D7.1 "Z" length (m)
GB1 =  43.28E-3   ;%5D7.1 gap height (m)
LB2 =  0.5490     ;%1D19.7 "Z" length (m)      changed from 0.540 m to 0.549 on Sep. 28, '07 based on magnetic measurements - PE
GB2 =  33.35E-3   ;%1D19.7 gap height (m)
%LB3  := 2.623      4D102.36T effective length (m)
%GB3  := 0.023      4D102.36T gap height (m)
%LVB  := 1.025      3D39 vertical bend effective length (m)
%GVB  := 0.034925   vertical bend gap width (m)
% GTL
% ===
RBXG =  0.1963       ;%BXG bend radius (measured) [m]
ABXG =  85.0*RADDEG  ;%bend angle of BXG dipole [deg*RADDEG = rad]
EBXG =  24.25*RADDEG ;%BXG pole-face rot. edge angle of BXG dipole [deg*RADDEG = rad]
GBXG =  0.043        ;%BXG magnet full gap height (m)
LBXG =  RBXG*ABXG    ;%path length of BXG dipole when ON (= R*theta) [m]
%VALUE, LBXG
BXGA={'be' 'BXG' LBXG/2 [ABXG/2 GBXG/2 EBXG 0 0.492 0 0]}';% 1st-half of gun spectrometer bend (set to ~zero length and strength, with longitudinal position as the actual bend's center)
BXGB={'be' 'BXG' LBXG/2 [ABXG/2 GBXG/2 0 EBXG 0.0 0.492 0]}';% 1st-half of gun spectrometer bend (set to ~zero length and strength, with longitudinal position as the actual bend's center)
DXG0={'dr' '' RBXG*sin(ABXG/2) []}';% drift, w/BXG off, from BXG entrance face to its z-projected center
DXGA={'be' 'DXG' 1E-9/2 [0/2 0 0 0 0 0 0]}';% 1st-half of gun-spec bend (set to ~zero length and strength, with longitudinal position as bend's center)
DXGB={'be' 'DXG' 1E-9/2 [0/2 0 0 0 0 0 0]}';% 2nd-half of gun-spec bend (set to ~zero length and strength, with longitudinal position as bend's center)
DBXG={'dr' '' 0.132618358755 []}';%replaces DXG0/DXGA/DXGB
RQGX =  0.020 ;% QG quadrupole pole-tip radius [m]
LQGX =  0.076 ;% QG quadrupole effective length [m]
CQ01={'qu' 'CQ01' 1E-9/2 [0 0]}';%correction quad in 1st solenoid at gun (nominally set to 0) (set to ~zero length, with longitudinal position as the actual quad's center)
SQ01={'qu' 'SQ01' 1E-9/2 [0 pi/4]}';%correction skew-quad in 1st solenoid at gun (nominally set to 0) (set to ~zero length, with longitudinal position as the actual quad's center)
QG02={'qu' 'QG02' LQGX/2 [-35.48540 0]}';
QG03={'qu' 'QG03' LQGX/2 [80.16051 0]}';
DGS1={'dr' '' 0.1900-LQGX/2-20E-6-0.0155757 []}';
DGS2={'dr' '' (0.2300-LQGX)/2+20E-6 []}';
DGS3={'dr' '' (0.2300-LQGX)/2-20E-6 []}';
DGS4={'dr' '' 0.1680-LQGX/2-0.00283 []}';
DGS5={'dr' '' 0.0300-0.02271 []}';
DGS6={'dr' '' 0.0240-0.00402 []}';
DGS7={'dr' '' 0.05 []}';
XCG1={'mo' 'XCG1' 0 []}';
XCG2={'mo' 'XCG2' 0 []}';
YCG1={'mo' 'YCG1' 0 []}';
YCG2={'mo' 'YCG2' 0 []}';
SCG1=[XCG1,YCG1];
SCG2=[XCG2,YCG2];
BPMG1={'mo' 'BPMG1' 0 []}';
CRG1={'mo' 'CRG1' 0 []}';% Cerenkov radiator bunch length monitor
YAGG1={'mo' 'YAGG1' 0 []}';% 6-MeV spectrometer screen
FCG1={'mo' 'FCG1' 0 []}';% gun-spec. Faraday cup w/screen
GSPEC=[BEGGSPEC,BXGA,BXGB,DGS1,QG02,SCG1,QG02,DGS2,BPMG1,DGS3,QG03,SCG2,QG03,DGS4,YAGG1,DGS5,CRG1,DGS6,FCG1,DGS7,DBMARK97,ENDGSPEC];% gun spectrometer from BXG to Faraday cup and dump
% 135-MeV Spectrometer
% ====================
KQS01 =   9.682244191676;
KQS02 =  -5.648980372134;
QS01={'qu' 'QS01' LQX/2 [KQS01 0]}';
QS02={'qu' 'QS02' LQX/2 [KQS02 0]}';
DX01A={'be' 'DX01' LB0/2 [1E-9 0 0 0 0 0 0]}';% 1st half of BX01 magnet switched off here
DX01B={'be' 'DX01' LB0/2 [1E-9 0 0 0 0 0 0]}';% 2nd half of BX01 magnet switched off here
DBX01A={'dr' '' 0.1016 []}';%replaces DX01A
DBX01B={'dr' '' 0.1016 []}';%replaces DX01B
DS0={'dr' '' 0.5583996 []}';
DS0A={'dr' '' 0.1691504 []}';
DS0B={'dr' '' 0.4615/2 []}';
DS1A={'dr' '' 0.0890085 []}';
DS1B={'dr' '' 0.1451215 []}';
DS1C={'dr' '' 0.171796 []}';
DS1D={'dr' '' 0.251824 []}';
DS2={'dr' '' 0.478250 []}';
DS3A={'dr' '' 0.199626 []}';
DS3B={'dr' '' 0.200374 []}';
DS4={'dr' '' 0.287275 []}';
DS6A={'dr' '' 0.2575952 []}';
DS6B={'dr' '' 0.2273298-0.008205 []}';
DS7={'dr' '' 0.3801874+0.008205-0.02 []}';
DS8={'dr' '' 0.1976126+0.02 []}';
DS9={'dr' '' 0.3378194 []}';
BPMS1={'mo' 'BPMS1' 0 []}';
BPMS2={'mo' 'BPMS2' 0 []}';
BPMS3={'mo' 'BPMS3' 0 []}';
VVS1={'mo' 'VVS1' 0 []}';%135-MeV spectrometer vacuum valve
YAGS1={'mo' 'YAGS1' 0 []}';%1st 135-MeV spectrometer YAG-screen - center of device in MAD is defined as center of YAG crystal, not mirror
IMS1={'mo' 'IMS1' 0 []}';%135-MeV spectrometer toroid
YAGS2={'mo' 'YAGS2' 0 []}';%2nd 135-MeV spectrometer YAG-screen - center of device in MAD is defined as center of YAG crystal, not mirror
OTRS1={'mo' 'OTRS1' 0 []}';%135-MeV spectrometer OTR-screen
SDMP={'mo' 'SDMP' 0 []}';% gun-spec. dump (exact location? - 11/09/05)
XCS1={'mo' 'XCS1' 0 []}';
YCS1={'mo' 'YCS1' 0 []}';
XCS2={'mo' 'XCS2' 0 []}';
YCS2={'mo' 'YCS2' 0 []}';
SCS1=[XCS1,YCS1];
SCS2=[XCS2,YCS2];
LBS =  0.5435        ;%measured effective length along curved trajectory (m)
GBS =  34E-3         ;%gap height (m)
ABS =  INJDEG*RADDEG ;%injection line angle (rad)
BXSEJ =  -7.29*RADDEG;
BXSA={'be' 'BXS' LBS/2 [ABS/2 GBS/2 BXSEJ 0 0.391 0 0]}';
BXSB={'be' 'BXS' LBS/2 [ABS/2 GBS/2 0 BXSEJ 0 0.391 0]}';
SPECBL=[BEGSPEC,DBX01A,DBX01B,DS0,SCS1,DS0A,DS0B,DS1A,VVS1,DS1B,YAGS1,DS1C,BPMS1,DS1D,BXSA,BXSB,DS2,QS01,BPMS2,QS01,DS3A,SCS2,DS3B,QS02,QS02,DS4,IMS1,DS6A,BPMS3,DS6B,YAGS2,DS7,OTRS1,DS8,DS9,SDMP,DBMARK98,ENDSPEC];
% DL1
% ===
ADL1 =  INJDEG*RADDEG            ;%injection line angle (rad)
AB0 =  ADL1/2                 ;%full bend angle (rad)
LEFFB0 =  LB0*AB0/(2*sin(AB0/2)) ;%full bend path length (m)
AEB0 =  AB0/2                  ;%edge angles
BX01A={'be' 'BX01' LEFFB0/2 [AB0/2 GB0/2 AEB0 0 0.45 0 0]}';
BX01B={'be' 'BX01' LEFFB0/2 [AB0/2 GB0/2 0 AEB0 0 0.45 0]}';
BX02A={'be' 'BX02' LEFFB0/2 [AB0/2 GB0/2 AEB0 0 0.45 0 0]}';
BX02B={'be' 'BX02' LEFFB0/2 [AB0/2 GB0/2 0 AEB0 0 0.45 0]}';
% BC1
% ===
BRHO1 =  CB*EBC1            ;%beam rigidity at BC1 (kG-m)
AB11 =  -0.086753564890323 ;%full chicane bend angle (rad)
RB11 =  LB1/sin(AB11)      ;%bend radius (m)
BB11 =  BRHO1/RB11         ;%bend field (kG) [-3.555805785115 kG @ 0.250 GeV]
AB11S =  asin((LB1/2)/RB11) ;%"short" half chicane bend angle (rad)
LB11S =  RB11*AB11S         ;%"short" half chicane bend path length (m)
AB11L =  AB11-AB11S         ;%"long" half chicane bend angle (rad)
LB11L =  RB11*AB11L         ;%"long" half chicane bend path length (m)
FB11 =  0.387              ;%fringe field integral
% BX11 gets an offset of 2.2 mm (theta*L/8) towards the wall
% BX12 gets an offset of 2.2 mm (theta*L/8) towards the aisle
% BX13 gets an offset of 2.2 mm (theta*L/8) towards the aisle
% BX14 gets an offset of 2.2 mm (theta*L/8) towards the wall
BX11A={'be' 'BX11' LB11S [+AB11S GB1/2 0 0 FB11 0 0]}';
BX11B={'be' 'BX11' LB11L [+AB11L GB1/2 0 +AB11 0 FB11 0]}';
BX12A={'be' 'BX12' LB11L [-AB11L GB1/2 -AB11 0 FB11 0 0]}';
BX12B={'be' 'BX12' LB11S [-AB11S GB1/2 0 0 0 FB11 0]}';
BX13A={'be' 'BX13' LB11S [-AB11S GB1/2 0 0 FB11 0 0]}';
BX13B={'be' 'BX13' LB11L [-AB11L GB1/2 0 -AB11 0 FB11 0]}';
BX14A={'be' 'BX14' LB11L [+AB11L GB1/2 +AB11 0 FB11 0 0]}';
BX14B={'be' 'BX14' LB11S [+AB11S GB1/2 0 0 0 FB11 0]}';
% magnet-to-magnet path lengths
LD11 =  2.434900                  ;%outer bend-to-bend "Z" distance (m)
LD11O =  LD11/cos(AB11)            ;%outer bend-to-bend path length (m) (minus ~0.15 m 9/21/04)
LD11A =  0.261301                  ;%"Z" distance upstream of SQ13 (m)
LD11B =  LD11-LD11A-0.16*cos(AB11) ;%"Z" distance downstream of SQ13 (m)
LD11OA =  LD11A/cos(AB11)           ;%path length upstream of SQ13
LD11OB =  LD11B/cos(AB11)           ;%path length downstream of SQ13
% BC2
% ===
BRHO2 =  CB*EBC2            ;%beam rigidity at BC2 (kG-m)
AB21 =  -0.034727452562382 ;%full chicane bend angle (rad)
RB21 =  LB2/sin(AB21)      ;%bend radius (m)
BB21 =  BRHO2/RB21         ;%bend field (kG) [-9.071122639275 kG @ 4.300 GeV]
AB21S =  asin((LB2/2)/RB21) ;%"short" half chicane bend angle (rad)
LB21S =  RB21*AB21S         ;%"short" half chicane bend path length (m)
AB21L =  AB21-AB21S         ;%"long" half chicane bend angle (rad)
LB21L =  RB21*AB21L         ;%"long" half chicane bend path length (m)
FB21 =  0.633              ;%fringe field integral
% BX21 gets an offset of ~2.3 mm (theta*L/8) towards the wall
% BX22 gets an offset of ~2.3 mm (theta*L/8) towards the aisle
% BX23 gets an offset of ~2.3 mm (theta*L/8) towards the aisle
% BX24 gets an offset of ~2.3 mm (theta*L/8) towards the wall
BX21A={'be' 'BX21' LB21S [+AB21S GB2/2 0 0 FB21 0 0]}';
BX21B={'be' 'BX21' LB21L [+AB21L GB2/2 0 +AB21 0 FB21 0]}';
BX22A={'be' 'BX22' LB21L [-AB21L GB2/2 -AB21 0 FB21 0 0]}';
BX22B={'be' 'BX22' LB21S [-AB21S GB2/2 0 0 0 FB21 0]}';
BX23A={'be' 'BX23' LB21S [-AB21S GB2/2 0 0 FB21 0 0]}';
BX23B={'be' 'BX23' LB21L [-AB21L GB2/2 0 -AB21 0 FB21 0]}';
BX24A={'be' 'BX24' LB21L [+AB21L GB2/2 +AB21 0 FB21 0 0]}';
BX24B={'be' 'BX24' LB21S [+AB21S GB2/2 0 0 0 FB21 0]}';
% magnet-to-magnet path lengths
LD21I =  1.0 - 2*0.1       ;%inner bend-to-bend "Z" distance (m)
LD1 =  2.00-0.04-0.0045   ;%outer bend-to-bend "Z" distance (m)
LD2 =  8.00-0.04-0.0508-0.0045   ;%outer bend-to-bend "Z" distance (m)
LD3 =  8.00-0.04-0.0508-0.0045   ;%outer bend-to-bend "Z" distance (m)
LD4 =  2.00-0.04-0.0045   ;%outer bend-to-bend "Z" distance (m)
LDO1 =  LD1/cos(AB21)      ;%outer bend-to-bend path length (m)
LDO2 =  LD2/cos(AB21)-LQC  ;%outer bend-to-bend path length (m)
LDO3 =  LD3/cos(AB21)-LQC  ;%outer bend-to-bend path length (m)
LDO4 =  LD4/cos(AB21)      ;%outer bend-to-bend path length (m)
% DL1
%  KQA01 :=  -7.474220813631             OLD - no lsr-htr (for commissioning in Dec. '06 through July '07) & on-measured TWSS0
%  KQA02 :=   8.137641193725
%  KQE01 :=  -2.215639104385
%  KQE02 :=  -0.241173314721
%  KQE03 :=   7.613440306134
%  KQE04 :=  -6.985386854286
%  KQA01 := -12.492179751016             OLD - with 5.4-cm lamu lsr-htr and "MATRIX" focusing, but non-measured TWSS0
%  KQA02 :=  11.022504569397
%  KQE01 :=  -3.089332618348
%  KQE02 :=   0.090132722014
%  KQE03 :=   6.822078966488
%  KQE04 :=  -5.731166555613
%  KQA01 := -6.1200                      post Aug. 11, 2008 matching based on real measurements with heater/chicane not yet installed (64 & 135 MeV)
%  KQA02 := 12.6808
%  KQE01 := -1.4046
%  KQE02 := -2.4546
%  KQE03 :=  9.6624
%  KQE04 := -7.4610
KQA01 =  -12.317411498864            ;% new design with laser-heater ON (chicane and und, w/Betx=Bety=12 m), based on measured (back-tracked) TWSS0
KQA02 =   13.706906173749;
KQE01 =   -6.538179321052;
KQE02 =    5.354060093454;
KQE03 =    6.054674881291;
KQE04 =   -5.235476556481;
KQM01 =   15.072053882204;
KQM02 =  -11.974604636345;
KQM03 =   -8.255421303054;
KQM04 =   13.306105246908;
KQB =   22.169715923059 ;%22.169701529353
QA01={'qu' 'QA01' LQX/2 [KQA01 0]}';
QA02={'qu' 'QA02' LQX/2 [KQA02 0]}';
QE01={'qu' 'QE01' LQX/2 [KQE01 0]}';
QE02={'qu' 'QE02' LQX/2 [KQE02 0]}';
QE03={'qu' 'QE03' LQX/2 [KQE03 0]}';
QE04={'qu' 'QE04' LQX/2 [KQE04 0]}';
QM01={'qu' 'QM01' LQX/2 [KQM01 0]}';
QM02={'qu' 'QM02' LQX/2 [KQM02 0]}';
QB={'qu' 'QB' LQE/2 [KQB 0]}';
QM03={'qu' 'QM03' LQX/2 [KQM03 0]}';
QM04={'qu' 'QM04' LQX/2 [KQM04 0]}';
% L1
KQL1 =  3.789198342593;
QFL1={'qu' 'QFL1' LQE/2 [+KQL1 0]}';
QDL1={'qu' 'QDL1' LQE/2 [-KQL1 0]}';
KQA11 =  -KQL1;
KQA12 =   1.863910872552;
QA11={'qu' 'QA11' LQX/2 [KQA11 0]}';
QA12={'qu' 'QA12' LQX/2 [KQA12 0]}';
% BC1
KQ21201 =   -9.357677119503;
KQM11 =    7.960339117021;
KQM12 =   -8.366726970987;
KQM13 =    9.860390676906;
KCQ11 =    1E-12;
KSQ13 =    1E-12;
KCQ12 =    1E-12;
KQ21301 =   -0.1347              ;% turn this quad OFF for LCLS operations (this is meas'd remnant field of Gdl = 0.12 kG)
KQM14 =    7.079239169293;
KQM15 =   -6.765038435385;
Q21201={'qu' 'Q21201' LQE/2 [KQ21201 0]}';% (QE-072 after Aug 2006) gets moved downstream of pre-LCLS location by 1.101312 m (measured parallel to main linac axis)
QM11={'qu' 'QM11' LQX/2 [KQM11 0]}';
CQ11={'qu' 'CQ11' LQC/2 [KCQ11 0]}';% now ETB tweaker quad
SQ13={'qu' 'SQ13' 0.16/2 [KSQ13 pi/4]}';% per Kirk Bertsche
CQ12={'qu' 'CQ12' LQC/2 [KCQ12 0]}';% now ETB tweaker quad
QM12={'qu' 'QM12' LQX/2 [KQM12 0]}';
QM13={'qu' 'QM13' LQX/2 [KQM13 0]}';
Q21301={'qu' 'Q21301' LQE/2 [KQ21301 0]}';% (QE-004 after Aug 2006) gets moved downstream of pre-LCLS location by 1.247066 m (measured parallel to main linac axis), and turned off for LCLS
QM14={'qu' 'QM14' LQX/2 [KQM14 0]}';
QM15={'qu' 'QM15' LQX/2 [KQM15 0]}';
% L2
KQL2 =  0.708388522907;
QFL2={'qu' 'QFL2' LQE/2 [+KQL2 0]}';
QDL2={'qu' 'QDL2' LQE/2 [-KQL2 0]}';
KQ21401 =   1.044881943081  ;% (QE-002 after Aug 2006)
KQ21501 =  -0.833170329125 ;% (use pre-Aug-2006 Q21201 magnet)
KQ21601 =   KQL2           ;% (use pre-Aug-2006 Q21301 magnet)
KQ21701 =  -KQL2;
KQ21801 =   0.721703961622;
KQ21901 =  -0.721930035688;
KQ22201 =   0.711368406706;
KQ22301 =  -0.764179973154;
KQ22401 =   KQL2;
KQ22501 =  -KQL2;
KQ22601 =   KQL2;
KQ22701 =  -KQL2;
KQ22801 =   0.748596129657;
KQ22901 =  -0.709657173604;
KQ23201 =   0.721241098608;
KQ23301 =  -0.741011348313;
KQ23401 =   KQL2;
KQ23501 =  -KQL2;
KQ23601 =   KQL2;
KQ23701 =  -KQL2;
KQ23801 =   0.770675623153;
KQ23901 =  -0.726878264576;
KQ24201 =   0.779404953697;
KQ24301 =  -0.856812505218;
KQ24401 =   1.025618689057;
KQ24501 =  -0.931675081162;
KQ24601 =   0.603160584173;
Q21401={'qu' 'Q21401' LQE/2 [KQ21401 0]}';
Q21501={'qu' 'Q21501' LQE/2 [KQ21501 0]}';
Q21601={'qu' 'Q21601' LQE/2 [KQ21601 0]}';
Q21701={'qu' 'Q21701' LQE/2 [KQ21701 0]}';
Q21801={'qu' 'Q21801' LQE/2 [KQ21801 0]}';
Q21901={'qu' 'Q21901' LQE/2 [KQ21901 0]}';
Q22201={'qu' 'Q22201' LQE/2 [KQ22201 0]}';
Q22301={'qu' 'Q22301' LQE/2 [KQ22301 0]}';
Q22401={'qu' 'Q22401' LQE/2 [KQ22401 0]}';
Q22501={'qu' 'Q22501' LQE/2 [KQ22501 0]}';
Q22601={'qu' 'Q22601' LQE/2 [KQ22601 0]}';
Q22701={'qu' 'Q22701' LQE/2 [KQ22701 0]}';
Q22801={'qu' 'Q22801' LQE/2 [KQ22801 0]}';
Q22901={'qu' 'Q22901' LQE/2 [KQ22901 0]}';
Q23201={'qu' 'Q23201' LQE/2 [KQ23201 0]}';
Q23301={'qu' 'Q23301' LQE/2 [KQ23301 0]}';
Q23401={'qu' 'Q23401' LQE/2 [KQ23401 0]}';
Q23501={'qu' 'Q23501' LQE/2 [KQ23501 0]}';
Q23601={'qu' 'Q23601' LQE/2 [KQ23601 0]}';
Q23701={'qu' 'Q23701' LQE/2 [KQ23701 0]}';
Q23801={'qu' 'Q23801' LQE/2 [KQ23801 0]}';
Q23901={'qu' 'Q23901' LQE/2 [KQ23901 0]}';
Q24201={'qu' 'Q24201' LQE/2 [KQ24201 0]}';
Q24301={'qu' 'Q24301' LQE/2 [KQ24301 0]}';
Q24401={'qu' 'Q24401' LQE/2 [KQ24401 0]}';
Q24501={'qu' 'Q24501' LQE/2 [KQ24501 0]}';
Q24601={'qu' 'Q24601' LQE/2 [KQ24601 0]}';
% BC2
KQ24701 =  -1.286030138047;
KQM21 =   0.508115309359;
KCQ21 =   1E-12;
KCQ22 =   1E-12;
KQM22 =  -0.590418980634;
KQ24901 =   1.082042245094;
Q24701A={'qu' 'Q24701A' LQE/2 [KQ24701 0]}';% in same location as pre-LCLS (with its BPM)
Q24701B={'qu' 'Q24701B' LQE/2 [KQ24701 0]}';% 10 cm between Q24701A & B
QM21={'qu' 'QM21' LQF/2 [KQM21 0]}';
CQ21={'qu' 'CQ21' LQC/2 [KCQ21 0]}';
CQ22={'qu' 'CQ22' LQC/2 [KCQ22 0]}';
QM22={'qu' 'QM22' LQF/2 [KQM22 0]}';
Q24901A={'qu' 'Q24901A' LQE/2 [KQ24901 0]}';% moved 2.397400 m downstream of original Q24901 position
Q24901B={'qu' 'Q24901B' LQE/2 [KQ24901 0]}';% 10 cm between Q24901A & B (BPM in this 2nd quad)
% L3
%  KQFL3 :=  0.446670469684  was used for 12*2*pi MUX from BX24 to BX31
%  KQDL3 := -0.424793498653  was used for 12*2*pi MUX from BX24 to BX31
KQFL3 =   0.395798933782  ;% gives psix = 50.76 deg, 44.64 deg, 45.00 deg between four LI28 wires
KQDL3 =  -0.395649286346  ;% gives TCAV3 -> OTR30 right + WS28 psiy: 48.96 deg, 45.72 deg, 43.92 deg
QFL3={'qu' 'QFL3' LQE/2 [KQFL3 0]}';
QDL3={'qu' 'QDL3' LQE/2 [KQDL3 0]}';
KQ25201 =   0.697993592575;
KQ25301 =  -0.478388226374;
KQ25401 =   0.42896785871;
KQ25501 =  -0.399864956514;
KQ25601 =   KQFL3;
KQ25701 =   KQDL3;
KQ25801 =   0.407168436855;
KQ25901 =  -0.388171234952;
KQ26201 =   0.388578933647;
KQ26301 =  -0.405404843557;
KQ26401 =   KQFL3;
KQ26501 =   KQDL3;
KQ26601 =   KQFL3;
KQ26701 =   KQDL3;
KQ26801 =   0.406308742855;
KQ26901 =  -0.388549789828;
KQ27201 =   0.390161854669;
KQ27301 =  -0.406474370795;
KQ27401 =   KQFL3;
KQ27501 =   KQDL3;
KQ27601 =   KQFL3;
KQ27701 =   KQDL3;
KQ27801 =   0.406495928662;
KQ27901 =  -0.388870517181;
KQ28201 =   0.390352348197;
KQ28301 =  -0.406461529502;
KQ28401 =   KQFL3;
KQ28501 =   KQDL3;
KQ28601 =   KQFL3;
KQ28701 =   KQDL3;
KQ28801 =   0.406649614831;
KQ28901 =  -0.389077444001;
KQ29201 =   0.390429567548;
KQ29301 =  -0.406416613477;
KQ29401 =   KQFL3;
KQ29501 =   KQDL3;
KQ29601 =   KQFL3;
KQ29701 =   KQDL3;
KQ29801 =   0.406588653506;
KQ29901 =  -0.389037213556;
KQ30201 =   0.39027307525;
KQ30301 =  -0.406178588622;
KQ30401 =   KQFL3;
KQ30501 =  -0.395648794699 ;%KQDL3
KQ30601 =   0.395797744026 ;%KQFL3
KQ30701 =  -0.395649272846 ;%KQDL3
%KQ30801 :=  0.418744300937 0.418743774352
%KQ30801 :=  0.484416787325 copy from LCLS2sc LTU.xsif
Q25201={'qu' 'Q25201' LQE/2 [KQ25201 0]}';
Q25301={'qu' 'Q25301' LQE/2 [KQ25301 0]}';
Q25401={'qu' 'Q25401' LQE/2 [KQ25401 0]}';
Q25501={'qu' 'Q25501' LQE/2 [KQ25501 0]}';
Q25601={'qu' 'Q25601' LQE/2 [KQ25601 0]}';
Q25701={'qu' 'Q25701' LQE/2 [KQ25701 0]}';
Q25801={'qu' 'Q25801' LQE/2 [KQ25801 0]}';
Q25901={'qu' 'Q25901' LQE/2 [KQ25901 0]}';
Q26201={'qu' 'Q26201' LQE/2 [KQ26201 0]}';
Q26301={'qu' 'Q26301' LQE/2 [KQ26301 0]}';
Q26401={'qu' 'Q26401' LQE/2 [KQ26401 0]}';
Q26501={'qu' 'Q26501' LQE/2 [KQ26501 0]}';
Q26601={'qu' 'Q26601' LQE/2 [KQ26601 0]}';
Q26701={'qu' 'Q26701' LQE/2 [KQ26701 0]}';
Q26801={'qu' 'Q26801' LQE/2 [KQ26801 0]}';
Q26901={'qu' 'Q26901' LQE/2 [KQ26901 0]}';
Q27201={'qu' 'Q27201' LQE/2 [KQ27201 0]}';
Q27301={'qu' 'Q27301' LQE/2 [KQ27301 0]}';
Q27401={'qu' 'Q27401' LQE/2 [KQ27401 0]}';
Q27501={'qu' 'Q27501' LQE/2 [KQ27501 0]}';
Q27601={'qu' 'Q27601' LQE/2 [KQ27601 0]}';
Q27701={'qu' 'Q27701' LQE/2 [KQ27701 0]}';
Q27801={'qu' 'Q27801' LQE/2 [KQ27801 0]}';
Q27901={'qu' 'Q27901' LQE/2 [KQ27901 0]}';
Q28201={'qu' 'Q28201' LQE/2 [KQ28201 0]}';
Q28301={'qu' 'Q28301' LQE/2 [KQ28301 0]}';
Q28401={'qu' 'Q28401' LQE/2 [KQ28401 0]}';
Q28501={'qu' 'Q28501' LQE/2 [KQ28501 0]}';
Q28601={'qu' 'Q28601' LQE/2 [KQ28601 0]}';
Q28701={'qu' 'Q28701' LQE/2 [KQ28701 0]}';
Q28801={'qu' 'Q28801' LQE/2 [KQ28801 0]}';
Q28901={'qu' 'Q28901' LQE/2 [KQ28901 0]}';
Q29201={'qu' 'Q29201' LQE/2 [KQ29201 0]}';
Q29301={'qu' 'Q29301' LQE/2 [KQ29301 0]}';
Q29401={'qu' 'Q29401' LQE/2 [KQ29401 0]}';
Q29501={'qu' 'Q29501' LQE/2 [KQ29501 0]}';
Q29601={'qu' 'Q29601' LQE/2 [KQ29601 0]}';
Q29701={'qu' 'Q29701' LQE/2 [KQ29701 0]}';
Q29801={'qu' 'Q29801' LQE/2 [KQ29801 0]}';
Q29901={'qu' 'Q29901' LQE/2 [KQ29901 0]}';
Q30201={'qu' 'Q30201' LQE/2 [KQ30201 0]}';
Q30301={'qu' 'Q30301' LQE/2 [KQ30301 0]}';
Q30401={'qu' 'Q30401' LQE/2 [KQ30401 0]}';
Q30501={'qu' 'Q30501' LQE/2 [KQ30501 0]}';
Q30601={'qu' 'Q30601' LQE/2 [KQ30601 0]}';
Q30615A={'mo' 'Q30615A' 0 []}';%power supply decommissioned
Q30615B={'mo' 'Q30615B' 0 []}';%power supply decommissioned
Q30615C={'mo' 'Q30615C' 0 []}';%power supply decommissioned
Q30701={'qu' 'Q30701' LQE/2 [KQ30701 0]}';
Q30715A={'mo' 'Q30715A' 0 []}';%power supply decommissioned
Q30715B={'mo' 'Q30715B' 0 []}';%power supply decommissioned
Q30715C={'mo' 'Q30715C' 0 []}';%power supply decommissioned
Q30801={'qu' 'Q30801' LQE/2 [KQ30801 0]}';
% ==============================================================================
% DRIFTs
% ------------------------------------------------------------------------------
% L1/2/3 FODO cells
D9={'dr' '' DLWL9 []}';
D10={'dr' '' DLWL10 []}';
DAQ1={'dr' '' 0.0342 []}';
DAQ2={'dr' '' 0.027 []}';
% injector geometry
LGGUN =  7.51*0.3048;
LGL0 =  2*3.0441+1.0;
LGBEND =  0.95 + 2*0.3048     ;% add 12" to either side of QB for more room (22JAN04 - PE)
LGEMIT =  9.000328707307;
LGMATCH =  1.5134597681;
DGGUN={'dr' '' LGGUN []}';
DGL0={'dr' '' LGL0 []}';
% L0
LOADLOCK={'dr' '' LGGUN-1.42 []}';
DL00={'dr' '' -LOADLOCK{3} []}';%from cathode back to u/s end of loadlock
DL01A={'dr' '' 0.19601-LSOL1/2 []}';
DL01A1={'dr' '' 0.07851 []}';
DL01A2={'dr' '' 0.11609 []}';
DL01A3={'dr' '' 0.10461 []}';
DL01A4={'dr' '' 0.0170+0.0014 []}';
DL01A5={'dr' '' 0.0132-0.00223 []}';
DL01B={'dr' '' 0.0825 []}';
DL01C={'dr' '' 0.1340-0.00353-0.003175 []}';
DL01D={'dr' '' 0.1008464-0.0155757 []}';
DL01H={'dr' '' 0.0581886 []}';
DL01E={'dr' '' 0.2286-DXG0{3}-0.00536+0.0155757 []}';
DL01F={'dr' '' 0.1353+0.00708 []}';
DL01F2={'dr' '' 0.0277+0.00167 []}';
DL01G={'dr' '' 0.0740-0.00341 []}';
DL02A1={'dr' '' 0.066356+0.0021436-0.008205 []}';
DL02A2={'dr' '' 0.104580+0.008205 []}';
DL02A3={'dr' '' 0.098776-LQX/2+0.028834 []}';
DL02B1={'dr' '' 0.169672-LQX/2-0.028834+0.007646 []}';
DL02B2={'dr' '' 0.185928-LQX/2-0.007646+0.001610 []}';
DL02C={'dr' '' 0.121498-LQX/2-0.001610 []}';
% Heater-Chicane:
% LSRHTR_ON := 1E-12          set to 1E-12 for laser heater bends & undulator OFF and 1.0 for ON (nominal)
LSRHTR_ON =  1              ;%set to 1E-12 for laser heater bends & undulator OFF and 1.0 for ON (nominal)
BRHOH =  CB*EI              ;%beam rigidity at heater (kG-m)
BBH1 =  -4.751481741801*LSRHTR_ON    ;%heater-chicane bend field for 35-mm etaX_pk (kG)
RBH1 =  BRHOH/BBH1         ;%heater-chicane bend radius (m)
ABH1 =  asin(LBH/RBH1)     ;%heater-chicane bend angle (rad)
ABH1S =  asin((LBH/2)/RBH1) ;%"short" half heater-chicane bend angle (rad)
LBH1S =  RBH1*ABH1S         ;%"short" half heater-chicane bend path length (m)
ABH1L =  ABH1-ABH1S         ;%"long" half heater-chicane bend angle (rad)
LBH1L =  RBH1*ABH1L         ;%"long" half heater-chicane bend path length (m)
DH00={'dr' '' 0.13453045-DLBH/2 []}';
DH01={'dr' '' (0.155-DLBH)/cos(ABH1) []}';
DH02A={'dr' '' 0.06717020-DLBH/2 []}';
DH03A={'dr' '' 0.09290825 []}';
DH03B={'dr' '' 0.08401830 []}';
DH02B={'dr' '' 0.09503020-DLBH/2 []}';
DH06={'dr' '' 0.13010070-DLBH/2 []}';
HTRUND={'mo' 'HTRUND' 0 []}';
BXH1A={'be' 'BXH1' LBH1S [+ABH1S GBH/2 0 0 0.400 0 0]}';
BXH1B={'be' 'BXH1' LBH1L [+ABH1L GBH/2 0 +ABH1 0 0.400 0]}';
BXH2A={'be' 'BXH2' LBH1L [-ABH1L GBH/2 -ABH1 0 0.400 0 0]}';
BXH2B={'be' 'BXH2' LBH1S [-ABH1S GBH/2 0 0 0 0.400 0]}';
BXH3A={'be' 'BXH3' LBH1S [-ABH1S GBH/2 0 0 0.400 0 0]}';
BXH3B={'be' 'BXH3' LBH1L [-ABH1L GBH/2 0 -ABH1 0 0.400 0]}';
BXH4A={'be' 'BXH4' LBH1L [+ABH1L GBH/2 +ABH1 0 0.400 0 0]}';
BXH4B={'be' 'BXH4' LBH1S [+ABH1S GBH/2 0 0 0 0.400 0]}';
% Laser-Heater Undulator Model:
LAM =  0.054                            ;% laser-heater undulator period [m]
LAMR =  758E-9                           ;% heater laser wavelength [m]
GAMI =  EI/MC2                           ;% Lorentz energy factor in laser-heater undulator [ ]
K_UND =  LSRHTR_ON*sqrt(2*(LAMR*2*GAMI^2/LAM - 1))  ;% undulator K for laser heater und.
LHUN =  0.506263                         ;% length of laser-heater undulator
KQLH =  (K_UND*2*PI/LAM/sqrt(2)/GAMI)^2  ;% natural undulator focusing "k" in y-plane [m^-2]
%VALUE,gami,kqlh,K_und
LHBEG={'mo' 'LHBEG' 0 []}';
LHEND={'mo' 'LHEND' 0 []}';
% laser-heater undulator modeled as R-matrix to include vertical natural focusing:
LH_UND={'un' 'LH_UND' LHUN/2 [KQLH LAM 1]}';
% RM(5,6) =  Lhun/2/(gami^2)*(1+(K_und^2)/2)
%VALUE, LH_UND[RM(1,2)],Lhun/2
%VALUE, LH_UND[RM(3,3)],cos(Lhun/2*sqrt(kqlh))
%VALUE, LH_UND[RM(3,4)],sin(Lhun/2*sqrt(kqlh))/sqrt(kqlh)
%VALUE, LH_UND[RM(4,3)],-sin(Lhun/2*sqrt(kqlh))*sqrt(kqlh)
%VALUE, LH_UND[RM(4,4)],cos(Lhun/2*sqrt(kqlh))
%VALUE, LH_UND[RM(5,6)],Lhun/2/(gami^2)*(1+(K_und^2)/2)
% DL1
LWS01_03 =   3.827458            ;% distance from WS01 to WS03 wire centers [m] (changed 06MAY05 -PE)
BMIN0 =  LWS01_03/sqrt(3)/2      ;% betaX=betaY at WS02 where waist is located (12NOV03 -PE)
%VALUE, BMIN0
MRK0={'mo' 'MRK0' 0 []}';
DE00={'dr' '' 0.024994 []}';
DE00A={'dr' '' 0.070613-LQX/2 []}';
DE01A={'dr' '' 0.130373-LQX/2 []}';
DE01B={'dr' '' 0.176359-LQX/2 []}';
DE01C={'dr' '' 0.094781 []}';
DE02={'dr' '' 0.0897395-LQX/2 []}';
DE03A={'dr' '' 0.16832-LQX/2 []}';
DE03B={'dr' '' 0.047581 []}';
DE03C={'dr' '' 0.190499-LQX/2 []}';
DE04={'dr' '' 0.197688-LQX/2 []}';
DE05={'dr' '' 0.151968 []}';
DE05A={'dr' '' DE05{3}/2 []}';
DE05C={'dr' '' 0.104470 []}';
DE06B={'dr' '' 0.2478024 []}';
DE06A={'dr' '' LWS01_03/2-DE05{3}-DE05C{3}-DE06B{3} []}';
DE06D={'dr' '' 0.1638307 []}';
DE06E={'dr' '' LWS01_03/2-DE05{3}-DE06D{3} []}';
DE07={'dr' '' 0.2045007-LQX/2+0.305E-3 []}';
DE08={'dr' '' 0.2318721-LQX/2-0.03 []}';
DE08A={'dr' '' 0.153330+0.03 []}';
DE08B={'dr' '' 0.170620-LQX/2 []}';
DE09={'dr' '' 0.27745-LQX/2 []}';
DLDB00 =  -0.54842233769E-6;
DB00A={'dr' '' 0.3997+DLDB00 []}';
DB00B={'dr' '' 0.161 []}';
DB00C={'dr' '' 0.2191-LQE/2 []}';
DB00D={'dr' '' 0.342-LQE/2 []}';
DB00E={'dr' '' 0.4378+DLDB00 []}';
DLDM00 =  2*abs(DLDB00)*cos(ADL1/2);
DM00={'dr' '' 0.203400-ZOFFINJ+0.03+DLDM00 []}';% move entire injector ~12 mm dntr. (Nov. 17, 2004 - PE)
DM00A={'dr' '' 0.224683-LQX/2-0.03 []}';
DM01={'dr' '' 0.142367-LQX/2 []}';
DM01A={'dr' '' 0.262800-LQX/2 []}';
DM02={'dr' '' 0.194200-LQX/2 []}';
DM02A={'dr' '' 0.157448 []}';
% L1
DAQA1={'dr' '' 0.033450+DZ_QA11 []}';
DAQA2={'dr' '' 0.033450-DZ_QA11 []}';
DAQA3={'dr' '' 0.033450 []}';
DAQA4={'dr' '' 0.033450 []}';
% BC1
LWW1 =  1.656196                                     ;% WS11-12 drift length and therefore ~ beam size
BMIN1 =  LWW1/sqrt(3)                                 ;% betaX,Y at WS12
DL1XA={'dr' '' 0.093369 []}';
DL1XB={'dr' '' 0.2 []}';
DM10A={'dr' '' 0.227400-0.022322 []}';
DM10C={'dr' '' 0.122322+DZ_Q21201 []}';
DM10X={'dr' '' 0.083617-DZ_Q21201 []}';
DM11={'dr' '' 0.272500+0.006383 []}';
DM12={'dr' '' 0.127801 []}';
DBQ1={'dr' '' (0.400381-LB1/2-LQC/2)/cos(AB11) []}';
D11O={'dr' '' LD11O-(DBQ1{3}+LQC)-2E-7 []}';
D11OA={'dr' '' LD11OA []}';
D11OB={'dr' '' LD11OB-(DBQ1{3}+LQC)-2E-7 []}';
DDG0={'dr' '' 0.1698-0.084915+0.0508-0.0045 []}';% additional drift in BC2 center prior to diag. package
DDGA={'dr' '' 0.084915+0.0508-0.0045 []}';% additional drift in BC2 center prior to diag. package
DDG1={'dr' '' 0.2891-0.04046 []}';% BC1 and BC2 diag. package drifts (BX*2B to BPM)
DDG2={'dr' '' 0.1240+0.04046 []}';% BC1 and BC2 diag. package drifts (BPM to CE)
DDG3={'dr' '' 0.1460+0.036606 []}';% BC1 and BC2 diag. package drifts (CE to OTR)
DDG4={'dr' '' 0.2711-0.036606 []}';% BC1 and BC2 diag. package drifts (OTR to BX*3A)
DM13A={'dr' '' 0.323450/2 []}';
DM13B={'dr' '' 0.323450/2 []}';
DM14A={'dr' '' 0.25-0.07615 []}';
DM14B={'dr' '' 0.15638875-0.0254+0.07615 []}';
DM14C={'dr' '' 0.15638875+0.0254 []}';
DM15A={'dr' '' 0.252872-0.1524 []}';
DM15B={'dr' '' 0.2836740-0.0826 []}';
DM15C={'dr' '' 0.1524+0.0826 []}';
DWW1A={'dr' '' LWW1 []}';
DWW1B={'dr' '' 0.295 []}';
DWW1C1={'dr' '' 0.812030-0.295-0.1017 []}';
DWW1C2={'dr' '' LWW1-1.427096+0.1017-0.0142-0.014199 []}';
DWW1D={'dr' '' 0.346099 []}';
DWW1E={'dr' '' 0.297366 []}';
DM16={'dr' '' 0.25+DZ_Q21301 []}';
DM17A={'dr' '' 0.2658341-DZ_Q21301 []}';
DM16A={'dr' '' 0.0 []}';
DM16B={'dr' '' 0.0 []}';
DM17B={'dr' '' 0.4008829 []}';
DM17C={'dr' '' 0.385417+DZ_QM14 []}';
DM18A={'dr' '' 0.228300-DZ_QM14 []}';
DM18B={'dr' '' 0.228200+DZ_QM15 []}';
DM19={'dr' '' 0.099400-DZ_QM15+0.000001 []}';%force Z=2059.732900 m at ZLIN04
% L2 and L3
DAQ3={'dr' '' 0.3533 []}';
DAQ4={'dr' '' 2.5527 []}';
DAQ5={'dr' '' 2.841-0.3048-1.2192 []}';
DAQ6={'dr' '' 0.2373 []}';
DAQ7={'dr' '' 0.2748 []}';
DAQ8={'dr' '' 2.6312 []}';
DAQ8A={'dr' '' 0.5+0.003200 []}';
DAQ8B={'dr' '' 2.1312-0.003200 []}';
DAQ12={'dr' '' 0.2286 []}';
DAQ13={'dr' '' 0.0231 []}';
DAQ14={'dr' '' 0.2130 []}';
DAQ15={'dr' '' 0.0087 []}';
DAQ16={'dr' '' 0.2274 []}';
DAQ17={'dr' '' 0.061900 []}';%30-8c exit to IV30-9
D255A={'dr' '' 0.06621-0.001510 []}';
D255B={'dr' '' 0.11184+0.001510 []}';
D255C={'dr' '' 0.17805-0.275500+0.25 []}';
D255D={'dr' '' 0.03420+0.275500 []}';
D256A={'dr' '' 2.350-1.1919-0.559100 []}';
D256B={'dr' '' 0.559100 []}';
D256C={'dr' '' 0.61475 []}';%0.540500-0.40505
D256D={'dr' '' 0.21115 []}';
% BC2
DM21Z={'dr' '' 0.0828006-0.027 []}';
DM21A={'dr' '' 0.3199994 []}';
DM21H={'dr' '' 0.193 []}';
DM21B={'dr' '' 0.6340002 []}';
DM21C={'dr' '' 0.3202404 []}';
DM21D={'dr' '' 0.139536 []}';
DM21E={'dr' '' 0.1996034-0.0045 []}';
DM20={'dr' '' 0.034200 []}';
DBQ2A={'dr' '' LDO1 []}';
D21OA={'dr' '' LDO2 []}';
D21I={'dr' '' LD21I/2 []}';
D21OB={'dr' '' LDO3 []}';
DBQ2B={'dr' '' LDO4 []}';
D21W={'dr' '' 0.311000-0.0045 []}';
D21X={'dr' '' 0.208700 []}';
D21Y={'dr' '' 0.114235 []}';
DM23B={'dr' '' 0.050405 []}';
DM24A={'dr' '' 0.129440 []}';
DM24B={'dr' '' 0.178000 []}';
DM24D={'dr' '' 0.070700 []}';
DM24C={'dr' '' 0.106300 []}';
DM25={'dr' '' 0.160400 []}';
% ==============================================================================
% MARKERs
% ------------------------------------------------------------------------------
% wire scanners
WS01={'mo' 'WS01' 0 []}';%DL1- emittance
WS02={'mo' 'WS02' 0 []}';%DL1- emittance
WS03={'mo' 'WS03' 0 []}';%DL1- emittance
WS04={'mo' 'WS04' 0 []}';%DL1- energy spread
WS11={'mo' 'WS11' 0 []}';%BC1+ emittance
WS12={'mo' 'WS12' 0 []}';%BC1+ emittance
WS13={'mo' 'WS13' 0 []}';%BC1+ emittance
%  WS21 : WIRE, TYPE="slow" LI24 emittance
%  WS22 : WIRE, TYPE="slow" LI24 emittance
%  WS23 : WIRE, TYPE="slow" LI24 emittance
WS24={'mo' 'WS24' 0 []}';%BC2- emittance
DWS21={'mo' 'DWS21' 0 []}';%someday will be a wire-scanner again?
DWS22={'mo' 'DWS22' 0 []}';%someday will be a wire-scanner again?
DWS23={'mo' 'DWS23' 0 []}';%someday will be a wire-scanner again?
%  DWS24 : MARK someday will be a wire-scanner again?
WS27644={'mo' 'WS27644' 0 []}';%LI27 emittance (existing; moved)
WS28144={'mo' 'WS28144' 0 []}';%LI28 emittance
WS28444={'mo' 'WS28444' 0 []}';%LI28 emittance
WS28744={'mo' 'WS28744' 0 []}';%LI28 emittance (existing; moved)
% profile monitors
YAG01={'mo' 'YAG01' 0 []}';%gun (15.5 in from cathode, per J. Schmerge, June 17, 2003; -PE)
YAG02={'mo' 'YAG02' 0 []}';%gun (need proper positions still - June 10, 2003)
YAG03={'mo' 'YAG03' 0 []}';%after L0-a (~ 60 MeV) - center of device in MAD is defined as center of YAG crystal, not mirror
YAG04={'mo' 'YAG04' 0 []}';%temporarily (Dec. '06 - July '07) placed in laser-heater region (135 MeV) - center of device in MAD is defined as center of YAG crystal, not mirror
PH01={'mo' 'PH01' 0 []}';%phase measurement RF cavity between L0-a and L0-b
PH02={'mo' 'PH02' 0 []}';%phase measurement RF cavity after BC1
PH03={'mo' 'PH03' 0 []}';%phase measurement RF cavity after BC2
VV01={'mo' 'VV01' 0 []}';%vacuum valve near gun
VV02={'mo' 'VV02' 0 []}';%vacuum valve in injector
VV03={'mo' 'VV03' 0 []}';%vacuum valve in injector
VV04={'mo' 'VV04' 0 []}';%vacuum valve in injector
VVX1={'mo' 'VVX1' 0 []}';%vacuum valve before X-band structure
VVX2={'mo' 'VVX2' 0 []}';%vacuum valve after X-band structure
VV21={'mo' 'VV21' 0 []}';%vacuum valve in front of BC2
VV22={'mo' 'VV22' 0 []}';%vacuum valve after BC2
RST1={'mo' 'RST1' 0 []}';%radiation stopper near WS02 in injector
OTRH1={'mo' 'OTRH1' 0 []}';%Laser-heater OTR screen just upbeam of heater-undulator (12NOV03 - PE)
OTRH2={'mo' 'OTRH2' 0 []}';%Laser-heater OTR screen just dnbeam of heater-undulator (12NOV03 - PE)
%  DOTRH1   : MARK                  Laser-heater OTR screen PLACE-HOLDER just upbeam of heater-undulator (not installed until summer 2008)
%  DOTRH2   : MARK                  Laser-heater OTR screen PLACE-HOLDER just dnbeam of heater-undulator (not installed until summer 2008)
OTR1={'mo' 'OTR1' 0 []}';%DL1-emit
OTR2={'mo' 'OTR2' 0 []}';%DL1-emit
OTR3={'mo' 'OTR3' 0 []}';%DL1-emit
OTR4={'mo' 'OTR4' 0 []}';%DL1 slice and proj. energy spread
OTR11={'mo' 'OTR11' 0 []}';%BC1 energy spread
OTR12={'mo' 'OTR12' 0 []}';%BC1 emittance
OTR21={'mo' 'OTR21' 0 []}';%BC2 energy spread
%OTR22    : PROF, TYPE="OTR"      moved to XLEAP (February 2017)
OTR_TCAV={'mo' 'OTR_TCAV' 0 []}';%LI25 longitudinal diagnostics
% bunch length monitors
BL11={'mo' 'BL11' 0 []}';%BC1+ (CSR-based relative bunch length monitor)
BL12={'mo' 'BL12' 0 []}';%BC1+ (ceramic gap-based relative bunch length monitor)
BL21={'mo' 'BL21' 0 []}';%BC2+ (CSR-based relative bunch length monitor)
BL22={'mo' 'BL22' 0 []}';%BC2+ (ceramic gap-based relative bunch length monitor)
% bunch charge monitors (toroids)
IM01={'mo' 'IM01' 0 []}';%L0
IM02={'mo' 'IM02' 0 []}';%L0
IM03={'mo' 'IM03' 0 []}';%DL1-
IMBC1I={'mo' 'IMBC1I' 0 []}';%BC1 input toriod (comparator with IMBC1O)
IMBC1O={'mo' 'IMBC1O' 0 []}';%BC1 output toroid (comparator with IMBC1I)
IMBC2I={'mo' 'IMBC2I' 0 []}';%BC2 input toroid (comparator with IMBC2O)
IMBC2O={'mo' 'IMBC2O' 0 []}';%BC2 output toroid (comparator with IMBC2I)
% other diagnostics
FC01={'mo' 'FC01' 0 []}';%L0 Faraday cup w/screen
AM00={'mo' 'AM00' 0 []}';%gun laser normal incidence mirror
AM01={'mo' 'AM01' 0 []}';%alignment mirror
CR01={'mo' 'CR01' 0 []}';%Cerenkov radiator bunch length monitor
% collimators
CE11={'dr' 'CE11' 0 []}';%adjustable energy (x) collimator in middle of BC1 chicane
CE21={'dr' 'CE21' 0 []}';%adjustable energy (x) collimator in middle of BC2 chicane
% dumps
TD11={'mo' 'TD11' 0 []}';%BC1+ insertable block
% miscellany
SOL1BK={'so' 'SOL1BK' 1E-9 [0]}';%gun-bucking-solenoid (set to ~zero length and strength, with longitudinal unknown for now)
CATHODE={'mo' 'CATHODE' 0 []}';
SOL1={'so' 'SOL1' LSOL1/2 [1E-9]}';%gun-solenoid (set to zero strength)
SOL2={'so' 'SOL2' 1E-9 [1E-9]}';%2nd-solenoid (set to ~zero length and strength, with longitudinal position as the actual solenoid's center)
L0AWAKE={'mo' 'L0AWAKE' 0 []}';
EMAT={'mo' 'EMAT' 0 []}';% for Elegant only to remove energy error in DL1 bends
DLFDA={'mo' 'DLFDA' 0 []}';% dual-feed input coupler location at start of L0-a RF structure
L0AMID={'mo' 'L0AMID' 0 []}';
OUTCPA={'mo' 'OUTCPA' 0 []}';% output coupler location at end of L0-a RF structure
L0BBEG={'mo' 'L0BBEG' 0 []}';
DLFDB={'mo' 'DLFDB' 0 []}';% dual-feed input coupler location at start of L0-b RF structure
L0BMID={'mo' 'L0BMID' 0 []}';
OUTCPB={'mo' 'OUTCPB' 0 []}';% output coupler location at end of L0-b RF structure
CNT0={'mo' 'CNT0' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
XBEG={'mo' 'XBEG' 0 []}';%before X-band RF, but after L1
XEND={'mo' 'XEND' 0 []}';%after X-band RF, but before BC1
BC1CBEG={'mo' 'BC1CBEG' 0 []}';%start of BC1 chicane
CNT1={'mo' 'CNT1' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
BC1CEND={'mo' 'BC1CEND' 0 []}';%end of BC1 chicane
LI21BEG={'mo' 'LI21BEG' 0 []}';
LI21END={'mo' 'LI21END' 0 []}';
LI22BEG={'mo' 'LI22BEG' 0 []}';
LI22END={'mo' 'LI22END' 0 []}';
LI23BEG={'mo' 'LI23BEG' 0 []}';
LI23END={'mo' 'LI23END' 0 []}';
LI24BEG={'mo' 'LI24BEG' 0 []}';
LI24END={'mo' 'LI24END' 0 []}';
BC2CBEG={'mo' 'BC2CBEG' 0 []}';%start of BC2 chicane
CNT2={'mo' 'CNT2' 0 []}';%ELEGANT will correct the orbit here for CSR-steering
BC2CEND={'mo' 'BC2CEND' 0 []}';%end of BC2 chicane
LI25BEG={'mo' 'LI25BEG' 0 []}';
LI25END={'mo' 'LI25END' 0 []}';
LI26BEG={'mo' 'LI26BEG' 0 []}';
LI26END={'mo' 'LI26END' 0 []}';
LI27BEG={'mo' 'LI27BEG' 0 []}';
LI27END={'mo' 'LI27END' 0 []}';
LI28BEG={'mo' 'LI28BEG' 0 []}';
LI28END={'mo' 'LI28END' 0 []}';
LI29BEG={'mo' 'LI29BEG' 0 []}';
LI29END={'mo' 'LI29END' 0 []}';
LI30BEG={'mo' 'LI30BEG' 0 []}';
LI30END={'mo' 'LI30END' 0 []}';
% Permanent reference points in the linac (and LTU: Z') Z-coordinate system (in meters)
% (NOTE: Z' is measured parallel to the undulator axis which is at an angle of
% 2*AVB [=4.668514 mrad on May 4, 2004] w.r.t. the linac axis):
% (Note Q20-901 is at 2029.4060 m in drawing ID-380-802-00 pg. 2 - this does not agree
%  with Woodley/Seeman database at 2029.3939 m.  We assume drawing is right -PE, June 11, 2004)
% ============================================================================================
ZLIN00={'mo' 'ZLIN00' 0 []}';% face of L0-a entrance flange : Z=2019.106625 (= 1.459000 m from cathode parallel to injector line, X = 9.612087)
% DBMARK98 : MARK   (135SPECT)135-MeV spect. dump: Z=2036.774471
ZLIN01={'mo' 'ZLIN01' 0 []}';% entrance to 21-1b            : Z=2035.035130 (= 20*101.600 m + 3.0441 m - 0.00897 m: 8/1/05)
ZLIN02={'mo' 'ZLIN02' 0 []}';% center of QUAD LI21 201      : (not used anymore since Q21201 is a few mm off) [was Z=2045.436400 pre 1/11/07]
ZLIN03={'mo' 'ZLIN03' 0 []}';% center of QUAD LI21 301      : (not used anymore since Q21301 is a few mm off) [was Z=2057.855466 pre 1/11/07]
ZLIN04={'mo' 'ZLIN04' 0 []}';% entrance to 21-3b            : Z=2059.732900
ZLIN05={'mo' 'ZLIN05' 0 []}';% start of LI22                : Z=2133.600000
ZLIN06={'mo' 'ZLIN06' 0 []}';% start of LI23                : Z=2235.200000
ZLIN07={'mo' 'ZLIN07' 0 []}';% start of LI24                : Z=2336.800000
ZLIN08={'mo' 'ZLIN08' 0 []}';% center of QUAD LI24 701 (A)  : Z=2410.786000 (not moved)
ZLIN09={'mo' 'ZLIN09' 0 []}';% start of LI25                : Z=2438.400000
ZLIN10={'mo' 'ZLIN10' 0 []}';% start of LI26                : Z=2540.000000
ZLIN11={'mo' 'ZLIN11' 0 []}';% start of LI27                : Z=2641.600000
ZLIN12={'mo' 'ZLIN12' 0 []}';% start of LI28                : Z=2743.200000
ZLIN13={'mo' 'ZLIN13' 0 []}';% start of LI29                : Z=2844.800000
ZLIN14={'mo' 'ZLIN14' 0 []}';% start of LI30                : Z=2946.400000
% DBMARK29 : MARK   end of linac                 : Z=3042.005000
% WOODDOOR : MARK   start of BSY                 : Z=3050.512000
% S100     : MARK   Station 100                  : Z=3048.000000
% ==============================================================================
% existing XCORs
% ------------------------------------------------------------------------------
%  XC460009T : HKIC
%  XC460026T : HKIC
%  XC460034T : HKIC do not use to steer ... bad results in Elegant
%  XC460036T : HKIC do not use to steer ... bad results in Elegant
%  XC920020T : HKIC
%  XC921010T : HKIC do not use to steer ... bad results in Elegant
%  XCBSY09   : HKIC  names changed from above to these (Sep. 2008)
%  XCBSY26   : HKIC
%  XCBSY36   : HKIC do not use to steer ... bad results in Elegant
% XCBSYQ2 : HKIC, TYPE="class-4" was XCBSY09 (Mar. 2016)
XCBSY34={'mo' 'XCBSY34' 0 []}';%do not use to steer ... bad results in Elegant
% XCBSYQ3 : HKIC, TYPE="class-4" was XCBSY09 (Mar. 2016)
XCBSY60={'mo' 'XCBSY60' 0 []}';
XCBSY81={'mo' 'XCBSY81' 0 []}';%do not use to steer ... bad results in Elegant
% ==============================================================================
% new XCORs
% ------------------------------------------------------------------------------
XC00={'mo' 'XC00' 0 []}';
XC01={'mo' 'XC01' 0 []}';
XC02={'mo' 'XC02' 0 []}';
XC03={'mo' 'XC03' 0 []}';
XC04={'mo' 'XC04' 0 []}';% fast-feedback (loop-1)
XC05={'mo' 'XC05' 0 []}';% calibrated to <1%
XC06={'mo' 'XC06' 0 []}';
XC07={'mo' 'XC07' 0 []}';% fast-feedback (loop-1)
XC08={'mo' 'XC08' 0 []}';
XC09={'mo' 'XC09' 0 []}';
XC10={'mo' 'XC10' 0 []}';
XC21101={'mo' 'XC21101' 0 []}';
XC21135={'mo' 'XC21135' 0 []}';
XC21165={'mo' 'XC21165' 0 []}';% calibrated to <1%
XC21175={'mo' 'XC21175' 0 []}';% pulled off structure and replaced on beamline?
XC21302={'mo' 'XC21302' 0 []}';% pulled off structure and replaced on beamline?
XC21191={'mo' 'XC21191' 0 []}';
XC21275={'mo' 'XC21275' 0 []}';
XC21325={'mo' 'XC21325' 0 []}';
% ==============================================================================
% existing YCORs
% ------------------------------------------------------------------------------
% YC460010T : VKIC
% YC460027T : VKIC do not use to steer ... bad results in Elegant
% YC460035T : VKIC do not use to steer ... bad results in Elegant
% YC460037T : VKIC
% YC920020T : VKIC
% YC921010T : VKIC do not use to steer ... bad results in Elegant
% YCBSY10   : VKIC  names changed from above to these (Sep. 2008)
% YCBSYQ1   : VKIC, TYPE="class-4" was YCBSY10 (Mar. 2016)
YCBSY27={'mo' 'YCBSY27' 0 []}';%do not use to steer ... bad results in Elegant
% YCBSY35   : VKIC do not use to steer ... bad results in Elegant
YCBSY37={'mo' 'YCBSY37' 0 []}';
% YCBSY62   : VKIC
YCBSY82={'mo' 'YCBSY82' 0 []}';%do not use to steer ... bad results in Elegant
% ==============================================================================
% new YCORs
% ------------------------------------------------------------------------------
YC00={'mo' 'YC00' 0 []}';
YC01={'mo' 'YC01' 0 []}';
YC02={'mo' 'YC02' 0 []}';
YC03={'mo' 'YC03' 0 []}';
YC04={'mo' 'YC04' 0 []}';% fast-feedback (loop-1)
YC05={'mo' 'YC05' 0 []}';% calibrated to <1%
YC06={'mo' 'YC06' 0 []}';
YC07={'mo' 'YC07' 0 []}';% fast-feedback (loop-1)
YC08={'mo' 'YC08' 0 []}';
YC09={'mo' 'YC09' 0 []}';
YC10={'mo' 'YC10' 0 []}';
YC21102={'mo' 'YC21102' 0 []}';
YC21136={'mo' 'YC21136' 0 []}';% calibrated to <1%
YC21166={'mo' 'YC21166' 0 []}';
YC21174={'mo' 'YC21174' 0 []}';
YC21303={'mo' 'YC21303' 0 []}';% pulled off structure and replaced on beamline?
YC21192={'mo' 'YC21192' 0 []}';
YC21276={'mo' 'YC21276' 0 []}';
YC21325={'mo' 'YC21325' 0 []}';
YC5={'mo' 'YC5' 0 []}';
% ==============================================================================
% existing BPMs
% ------------------------------------------------------------------------------
BPM21201={'mo' 'BPM21201' 0 []}';
BPM21301={'mo' 'BPM21301' 0 []}';
BPM21401={'mo' 'BPM21401' 0 []}';
BPM21501={'mo' 'BPM21501' 0 []}';
BPM21601={'mo' 'BPM21601' 0 []}';
BPM21701={'mo' 'BPM21701' 0 []}';
BPM21801={'mo' 'BPM21801' 0 []}';
BPM21901={'mo' 'BPM21901' 0 []}';
BPM22201={'mo' 'BPM22201' 0 []}';
BPM22301={'mo' 'BPM22301' 0 []}';
BPM22401={'mo' 'BPM22401' 0 []}';
BPM22501={'mo' 'BPM22501' 0 []}';
BPM22601={'mo' 'BPM22601' 0 []}';
BPM22701={'mo' 'BPM22701' 0 []}';
BPM22801={'mo' 'BPM22801' 0 []}';
BPM22901={'mo' 'BPM22901' 0 []}';
BPM23201={'mo' 'BPM23201' 0 []}';
BPM23301={'mo' 'BPM23301' 0 []}';
BPM23401={'mo' 'BPM23401' 0 []}';
BPM23501={'mo' 'BPM23501' 0 []}';
BPM23601={'mo' 'BPM23601' 0 []}';
BPM23701={'mo' 'BPM23701' 0 []}';
BPM23801={'mo' 'BPM23801' 0 []}';
BPM23901={'mo' 'BPM23901' 0 []}';
BPM24201={'mo' 'BPM24201' 0 []}';
BPM24301={'mo' 'BPM24301' 0 []}';
BPM24401={'mo' 'BPM24401' 0 []}';
BPM24501={'mo' 'BPM24501' 0 []}';
BPM24601={'mo' 'BPM24601' 0 []}';
BPM24701={'mo' 'BPM24701' 0 []}';
BPM24901={'mo' 'BPM24901' 0 []}';
BPM25201={'mo' 'BPM25201' 0 []}';
BPM25301={'mo' 'BPM25301' 0 []}';
BPM25401={'mo' 'BPM25401' 0 []}';
BPM25501={'mo' 'BPM25501' 0 []}';
BPM25601={'mo' 'BPM25601' 0 []}';
BPM25701={'mo' 'BPM25701' 0 []}';
BPM25801={'mo' 'BPM25801' 0 []}';
BPM25901={'mo' 'BPM25901' 0 []}';
BPM26201={'mo' 'BPM26201' 0 []}';
BPM26301={'mo' 'BPM26301' 0 []}';
BPM26401={'mo' 'BPM26401' 0 []}';
BPM26501={'mo' 'BPM26501' 0 []}';
BPM26601={'mo' 'BPM26601' 0 []}';
BPM26701={'mo' 'BPM26701' 0 []}';
BPM26801={'mo' 'BPM26801' 0 []}';
BPM26901={'mo' 'BPM26901' 0 []}';
BPM27201={'mo' 'BPM27201' 0 []}';
BPM27301={'mo' 'BPM27301' 0 []}';
BPM27401={'mo' 'BPM27401' 0 []}';
BPM27501={'mo' 'BPM27501' 0 []}';
BPM27601={'mo' 'BPM27601' 0 []}';
BPM27701={'mo' 'BPM27701' 0 []}';
BPM27801={'mo' 'BPM27801' 0 []}';
BPM27901={'mo' 'BPM27901' 0 []}';
BPM28201={'mo' 'BPM28201' 0 []}';
BPM28301={'mo' 'BPM28301' 0 []}';
BPM28401={'mo' 'BPM28401' 0 []}';
BPM28501={'mo' 'BPM28501' 0 []}';
BPM28601={'mo' 'BPM28601' 0 []}';
BPM28701={'mo' 'BPM28701' 0 []}';
BPM28801={'mo' 'BPM28801' 0 []}';
BPM28901={'mo' 'BPM28901' 0 []}';
BPM29201={'mo' 'BPM29201' 0 []}';
BPM29301={'mo' 'BPM29301' 0 []}';
BPM29401={'mo' 'BPM29401' 0 []}';
BPM29501={'mo' 'BPM29501' 0 []}';
BPM29601={'mo' 'BPM29601' 0 []}';
BPM29701={'mo' 'BPM29701' 0 []}';
BPM29801={'mo' 'BPM29801' 0 []}';
BPM29901={'mo' 'BPM29901' 0 []}';
BPM30201={'mo' 'BPM30201' 0 []}';
BPM30301={'mo' 'BPM30301' 0 []}';
BPM30401={'mo' 'BPM30401' 0 []}';
BPM30501={'mo' 'BPM30501' 0 []}';
BPM30601={'mo' 'BPM30601' 0 []}';
BPM30701={'mo' 'BPM30701' 0 []}';
BPM30801={'mo' 'BPM30801' 0 []}';
% ==============================================================================
% new BPMs
% ------------------------------------------------------------------------------
BPM2={'mo' 'BPM2' 0 []}';
BPM3={'mo' 'BPM3' 0 []}';
BPM5={'mo' 'BPM5' 0 []}';
BPM6={'mo' 'BPM6' 0 []}';
BPM8={'mo' 'BPM8' 0 []}';
BPM9={'mo' 'BPM9' 0 []}';
BPM10={'mo' 'BPM10' 0 []}';
BPM11={'mo' 'BPM11' 0 []}';
BPM12={'mo' 'BPM12' 0 []}';
BPM13={'mo' 'BPM13' 0 []}';
BPM14={'mo' 'BPM14' 0 []}';
BPM15={'mo' 'BPM15' 0 []}';
BPMA11={'mo' 'BPMA11' 0 []}';
BPMA12={'mo' 'BPMA12' 0 []}';
BPMS11={'mo' 'BPMS11' 0 []}';
BPMM12={'mo' 'BPMM12' 0 []}';
BPMM14={'mo' 'BPMM14' 0 []}';
BPMS21={'mo' 'BPMS21' 0 []}';
% ==============================================================================
% miscellaneous
% ------------------------------------------------------------------------------
D10CMA={'dr' '' 0.127 []}';
% ==============================================================================
% LINE definitions
% ------------------------------------------------------------------------------
L1C=[D9,DAQ1,QFL1,QFL1,DAQ1,D9,DAQ1,QDL1,QDL1,DAQ1];
L2C=[D10,D10,D10,D10,DAQ1,QFL2,QFL2,DAQ2,D10,D10,D10,D10,DAQ1,QDL2,QDL2,DAQ2];
L3C=[D10,D10,D10,D10,DAQ1,QFL3,QFL3,DAQ2,D10,D10,D10,D10,DAQ1,QDL3,QDL3,DAQ2];
SC0=[XC00,YC00];
SC1=[XC01,YC01];
SC2=[XC02,YC02];
SC3=[XC03,YC03];
SC4=[XC04,YC04];
SC5=[XC05,YC05];
SC6=[XC06,YC06];
SC7=[XC07,YC07];
SC8=[XC08,YC08];
SC9=[XC09,YC09];
SC10=[XC10,YC10];
SC11=[XC21101,YC21102];
SCA11=[XC21135,YC21136];
SCA12=[XC21165,YC21166];
SCM11=[XC21191,YC21192];
SCM13=[XC21275,YC21276];
SCM15=[XC21325,YC21325];
GUNBXG=[DL00,LOADLOCK,BEGGUN,SOL1BK,DBMARK80,CATHODE,DL01A,SOL1,CQ01,CQ01,SC0,SQ01,SQ01,SOL1,DL01A1,VV01,DL01A2,AM00,DL01A3,AM01,DL01A4,YAG01,DL01A5,FC01,DL01B,IM01,DL01C,SC1,DL01H,BPM2,DL01D,DBMARK81,ENDGUN];
BXGL0A=[BEGL0,DBXG,DL01E,BPM3,DL01F,CR01,DL01F2,YAG02,DL01G,ZLIN00,FLNGA1,L0A___1,DLFDA,L0A___2,SOL2,L0A___3,SC2,L0A___4,L0AMID,L0A___5,SC3,L0A___6,OUTCPA,L0A___7,FLNGA2,L0AWAKE];
GUNL0A=[GUNBXG,BXGL0A];
L0B=[L0BBEG,DL02A1,YAG03,DL02A2,DL02A3,QA01,QA01,DL02B1,PH01,DL02B2,QA02,BPM5,QA02,DL02C,FLNGB1,L0B___1,DLFDB,L0B___2,SC4,L0B___3,L0BMID,L0B___4,SC5,L0B___5,OUTCPB,L0B___6,FLNGB2,ENDL0];
LSRHTR=[LHBEG,BXH1A,BXH1B,DH01,BXH2A,BXH2B,DH02A,OTRH1,DH03A,LH_UND,HTRUND,LH_UND,DH03B,OTRH2,DH02B,BXH3A,BXH3B,DH01,BXH4A,BXH4B,LHEND];
DL1_1=[BEGDL1_1,EMAT,DE00,DE00A,QE01,BPM6,QE01,DE01A,IM02,DE01B,VV02,DE01C,QE02,QE02,DH00,LSRHTR,DH06,TCAV0,SC6,TCAV0,DE02,QE03,BPM8,QE03,DE03A,DE03B,SC7,DE03C,QE04,BPM9,QE04,DE04,WS01,DE05,OTR1,DE05C,VV03,DE06A,RST1,DE06B,WS02,DE05A,MRK0,DE05A,OTR2,DE06D,BPM10,DE06E,WS03,DE05,OTR3,DE07,QM01,BPM11,QM01,DE08,SC8,DE08A,VV04,DE08B,QM02,BPM12,QM02,DE09,DBMARK82,ENDDL1_1];
DL1_2=[BEGDL1_2,BX01A,BX01B,DB00A,OTR4,DB00B,SC9,DB00C,QB,BPM13,QB,DB00D,WS04,DB00E,BX02A,BX02B,CNT0,DBMARK83,DM00,SC10,DM00A,QM03,BPM14,QM03,DM01,DM01A,QM04,BPM15,QM04,DM02,IM03,DM02A,ENDDL1_2];
DL1=[DL1_1,DL1_2];%nominal LCLS DL1 layout with BX01/BX02 bends on
DIAG1=[DDG1,BPMS11,DDG2,CE11,DDG3,OTR11,DDG4];
BC1C=[BC1CBEG,BX11A,BX11B,DBQ1,CQ11,CQ11,D11O,BX12A,BX12B,DIAG1,BX13A,BX13B,D11OA,SQ13,SQ13,D11OB,CQ12,CQ12,DBQ1,BX14A,BX14B,CNT1,BC1CEND];
BC1I=[DL1XA,VVX1,DL1XB,XBEG,L1X___1,SCM11,L1X___2,XEND,DM10A,VVX2,DM10C,Q21201,BPM21201,ZLIN02,Q21201,DM10X,IMBC1I,DM11,QM11,QM11,DM12];
BC1E=[DM13A,BL11,DM13B,QM12,QM12,DM14A,DM14B,IMBC1O,DM14C,QM13,BPMM12,QM13,DM15A,BL12,DM15B,SCM13,DM15C,WS11,DWW1A,WS12,DWW1B,OTR12,DWW1C1,PH02,DWW1C2,XC21302,DWW1D,YC21303,DWW1E,WS13,DM16,Q21301,BPM21301,ZLIN03,Q21301,DM17A,DM17B,TD11,DM17C,QM14,BPMM14,QM14,DM18A,SCM15,DM18B,QM15,QM15,DBMARK28,DM19];
BC1=[BEGBC1,BC1I,BC1C,BC1E,ENDBC1];
DIAG2=[DDG1,BPMS21,DDG2,CE21,DDG3,OTR21,DDG4];
BC2C1=[BC2CBEG,BX21A,BX21B,DBQ2A,CQ21,CQ21,D21OA,BX22A,BX22B,DDG0,DIAG2,DDGA,BX23A,BX23B,D21OB,CQ22,CQ22,DBQ2B,BX24A,BX24B,CNT2,BC2CEND];
BC2=[BEGBC2,DM20,Q24701A,ZLIN08,Q24701A,D10CMA,Q24701B,BPM24701,Q24701B,DM21Z,DM21A,WS24,DM21H,IMBC2I,DM21B,VV21,DM21C,QM21,QM21,DM21D,DM21E,BC2C1,D21W,D21X,BL21,D21Y,DM23B,QM22,QM22,DM24A,VV22,DM24B,DM24D,Q24901A,BPM24901,Q24901A,DM24C,Q24901B,Q24901B,DM25,ENDBC2];
ECELL=[QE31,DQEC,DQEC,QE32,QE32,DQEC,DQEC,QE31];
% ------------------------------------------------------------------------------

% design L1, L2, and L3 lattices ...
% *** OPTICS=AD_ACCEL-13JUN19 ***
% ==============================================================================
% 07-JAN-2019, M. Woodley
%  * rename some LI21 correctors to avoid name conflicts with LCLS-II per
%    T. Maxwell
% ------------------------------------------------------------------------------
% 11-JAN-2007, P. Emma
%    Move QA11 a few mm as observed by alignment.
% 09-MAR-2006, P. Emma
%    Move SC11, SCA11, SCA12, and XC21202 and YC21203 per P. Stephens.
% 01-DEC-2005, P. Emma
%    Move XC21202 and YC21203 onto end of 21-1d.
% 29-NOV-2005, P. Emma
%    Add types for LCAV's.
% 09-NOV-2005, P. Emma
%    Use type-1 x/y corrector packages in L1-linac and relocate.
% 25-SEP-2005, P. Emma
%    Break L1 structure up to insert correctors at proper locations.
% ==============================================================================
% LCAVs
% ------------------------------------------------------------------------------
% the L1 linac consists of:   1 9.4  ft S-band sections @ 50% power
%                             1 9.4  ft S-band sections @ 25% power
%                             1 10   ft S-band sections @ 25% power
% ------------------------------------------------------------------------------
DLB1 =  0.200+0.253432;
DLB2 =  DLWL9-DLB1;
K21_1B1={'lc' 'K21_1B' DLB1 [SBANDF P50*GRADL1*DLB1 PHIL1*TWOPI]}';
K21_1B2={'lc' 'K21_1B' DLB2 [SBANDF P50*GRADL1*DLB2 PHIL1*TWOPI]}';
DLC1 =  0.200+0.2534458;
DLC2 =  DLWL9-DLC1;
K21_1C1={'lc' 'K21_1C' DLC1 [SBANDF P25*GRADL1*DLC1 PHIL1*TWOPI]}';
K21_1C2={'lc' 'K21_1C' DLC2 [SBANDF P25*GRADL1*DLC2 PHIL1*TWOPI]}';
DLD1 =  0.200+0.1693348;
DLD3 =  0.300+0.167527-0.1799554;
DLD4 =  0.200+0.1799554;
DLD2 =  DLWL10-DLD1-DLD3-DLD4;
K21_1D1={'lc' 'K21_1D' DLD1 [SBANDF P25*GRADL1*DLD1 PHIL1*TWOPI]}';
K21_1D2={'lc' 'K21_1D' DLD2 [SBANDF P25*GRADL1*DLD2 PHIL1*TWOPI]}';
K21_1D3={'lc' 'K21_1D' DLD3 [SBANDF P25*GRADL1*DLD3 PHIL1*TWOPI]}';
K21_1D4={'lc' 'K21_1D' DLD4 [SBANDF P25*GRADL1*DLD4 PHIL1*TWOPI]}';
% ==============================================================================
% BEAMLINEs
% ------------------------------------------------------------------------------
L1=[BEGL1,ZLIN01,K21_1B1,SC11 ,K21_1B2,DAQA1,QA11,BPMA11,QA11,DAQA2,K21_1C1,SCA11,K21_1C2,DAQA3,QA12,BPMA12,QA12,DAQA4,K21_1D1,SCA12,K21_1D2,YC21174,K21_1D3,XC21175,K21_1D4,ENDL1];
% ==============================================================================

% *** OPTICS=AD_ACCEL-13JUN19 ***
% ==============================================================================
% 23-FEB-2017, M. Woodley
%    Change TYPE of LI21 XCORs and YCORs to "type-4al" for consistency with LCLS
% ------------------------------------------------------------------------------
% 01-JUL-2010, M. Woodley
%    Per H. Loos: fix DELTAE arithmetic for the following LCAV elements:
%      K24_2a1, K24_2a2, K24_2a3
%      K24_4a2, K24_4a3
%      K24_5a2, K24_5a3
%      K24_6a2, K24_6a3
%      K24_6d1, K24_6d2
% 11-SEP-2007, P. Emma
%    Replace WS21,22,23 with MARKer points DWS21-23 (no longer in baseline);
%    add back 25-3d, 4d, and 5d sections (now 110 10-ft P25% sections & 1 P50%)
% 15-DEC-2006, P. Emma
%    Move WS21,22,23 upbeam by 4 feet each to reduce possible quad-reflected
%    dark charge
% 13-DEC-2006, P. Emma
%    Per T. Osier: move (~6") XC24202, YC24203, YC24403, YC24503, YC24603,
%    and XC24702
% 15-OCT-2006, P. Emma
%    Move WS21,22,23 for Jose Chan (DAQ6 becomes DAQ6A).
% 20-MAR-2006, P. Emma
%    Remove YCM15 from this file as should have been done back in Nov. 9, 2005.
% 29-NOV-2005, P. Emma
%    Add types for LCAV's, HKIC's, and VKIC's.
% 09-NOV-2005, P. Emma
%    Move YCM15 back into main LCLS file.
% 02-JUN-2005, P. Emma
%    Add comments adjacent to fast-feedback correctors
% 18-JAN-2005, P. Emma
%    Added the two 1%-calibrated correctors.
% 01-DEC-2004, P. Emma
%    Move YCM15 into this file from the main LCLS file (moved dnstr. by 0.401 m
%    and jumped over QM15 onto the L2 linac as a wrap-around corrector)
% ==============================================================================
% LCAVs
% ------------------------------------------------------------------------------
% the L2 linac consists of: 110 10   ft S-band sections @ 25% power
%                             1 10   ft S-band sections @ 50% power
% ------------------------------------------------------------------------------
K21_3B1={'lc' 'K21_3B' 0.2672 [SBANDF P50*GRADL2*0.2672 PHIL2*TWOPI]}';
K21_3B2={'lc' 'K21_3B' 2.7769 [SBANDF P50*GRADL2*2.7769 PHIL2*TWOPI]}';
K21_3C={'lc' 'K21_3C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_3D={'lc' 'K21_3D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_4A1={'lc' 'K21_4A' 0.3268 [SBANDF P25*GRADL2*0.3268 PHIL2*TWOPI]}';
K21_4A2={'lc' 'K21_4A' 0.3707 [SBANDF P25*GRADL2*0.3707 PHIL2*TWOPI]}';
K21_4A3={'lc' 'K21_4A' 2.3466 [SBANDF P25*GRADL2*2.3466 PHIL2*TWOPI]}';
K21_4B={'lc' 'K21_4B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_4C={'lc' 'K21_4C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_4D={'lc' 'K21_4D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_5A1={'lc' 'K21_5A' 0.3324 [SBANDF P25*GRADL2*0.3324 PHIL2*TWOPI]}';
K21_5A2={'lc' 'K21_5A' 0.3778 [SBANDF P25*GRADL2*0.3778 PHIL2*TWOPI]}';
K21_5A3={'lc' 'K21_5A' 2.3339 [SBANDF P25*GRADL2*2.3339 PHIL2*TWOPI]}';
K21_5B={'lc' 'K21_5B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_5C={'lc' 'K21_5C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_5D={'lc' 'K21_5D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_6A1={'lc' 'K21_6A' 0.3280 [SBANDF P25*GRADL2*0.3280 PHIL2*TWOPI]}';
K21_6A2={'lc' 'K21_6A' 0.3885 [SBANDF P25*GRADL2*0.3885 PHIL2*TWOPI]}';
K21_6A3={'lc' 'K21_6A' 2.3276 [SBANDF P25*GRADL2*2.3276 PHIL2*TWOPI]}';
K21_6B={'lc' 'K21_6B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_6C={'lc' 'K21_6C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_6D={'lc' 'K21_6D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_7A1={'lc' 'K21_7A' 0.3336 [SBANDF P25*GRADL2*0.3336 PHIL2*TWOPI]}';
K21_7A2={'lc' 'K21_7A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K21_7A3={'lc' 'K21_7A' 2.4605 [SBANDF P25*GRADL2*2.4605 PHIL2*TWOPI]}';
K21_7B={'lc' 'K21_7B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_7C={'lc' 'K21_7C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_7D={'lc' 'K21_7D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_8A1={'lc' 'K21_8A' 0.3292 [SBANDF P25*GRADL2*0.3292 PHIL2*TWOPI]}';
K21_8A2={'lc' 'K21_8A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K21_8A3={'lc' 'K21_8A' 2.4649 [SBANDF P25*GRADL2*2.4649 PHIL2*TWOPI]}';
K21_8B={'lc' 'K21_8B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_8C={'lc' 'K21_8C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K21_8D1={'lc' 'K21_8D' 2.3869 [SBANDF P25*GRADL2*2.3869 PHIL2*TWOPI]}';
K21_8D2={'lc' 'K21_8D' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K21_8D3={'lc' 'K21_8D' 0.4072 [SBANDF P25*GRADL2*0.4072 PHIL2*TWOPI]}';
K22_1A={'lc' 'K22_1A' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_1B={'lc' 'K22_1B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_1C={'lc' 'K22_1C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_1D={'lc' 'K22_1D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_2A1={'lc' 'K22_2A' 0.3256 [SBANDF P25*GRADL2*0.3256 PHIL2*TWOPI]}';
K22_2A2={'lc' 'K22_2A' 0.3782 [SBANDF P25*GRADL2*0.3782 PHIL2*TWOPI]}';
K22_2A3={'lc' 'K22_2A' 2.3403 [SBANDF P25*GRADL2*2.3403 PHIL2*TWOPI]}';
K22_2B={'lc' 'K22_2B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_2C={'lc' 'K22_2C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_2D={'lc' 'K22_2D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_3A1={'lc' 'K22_3A' 0.3312 [SBANDF P25*GRADL2*0.3312 PHIL2*TWOPI]}';
K22_3A2={'lc' 'K22_3A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K22_3A3={'lc' 'K22_3A' 2.4629 [SBANDF P25*GRADL2*2.4629 PHIL2*TWOPI]}';
K22_3B={'lc' 'K22_3B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_3C={'lc' 'K22_3C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_3D={'lc' 'K22_3D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_4A1={'lc' 'K22_4A' 0.3268 [SBANDF P25*GRADL2*0.3268 PHIL2*TWOPI]}';
K22_4A2={'lc' 'K22_4A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K22_4A3={'lc' 'K22_4A' 2.4673 [SBANDF P25*GRADL2*2.4673 PHIL2*TWOPI]}';
K22_4B={'lc' 'K22_4B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_4C={'lc' 'K22_4C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_4D={'lc' 'K22_4D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_5A1={'lc' 'K22_5A' 0.3324 [SBANDF P25*GRADL2*0.3324 PHIL2*TWOPI]}';
K22_5A2={'lc' 'K22_5A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K22_5A3={'lc' 'K22_5A' 2.4617 [SBANDF P25*GRADL2*2.4617 PHIL2*TWOPI]}';
K22_5B={'lc' 'K22_5B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_5C={'lc' 'K22_5C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_5D={'lc' 'K22_5D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_6A1={'lc' 'K22_6A' 0.3280 [SBANDF P25*GRADL2*0.3280 PHIL2*TWOPI]}';
K22_6A2={'lc' 'K22_6A' 0.3790 [SBANDF P25*GRADL2*0.3790 PHIL2*TWOPI]}';
K22_6A3={'lc' 'K22_6A' 2.3371 [SBANDF P25*GRADL2*2.3371 PHIL2*TWOPI]}';
K22_6B={'lc' 'K22_6B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_6C={'lc' 'K22_6C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_6D={'lc' 'K22_6D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_7A1={'lc' 'K22_7A' 0.3336 [SBANDF P25*GRADL2*0.3336 PHIL2*TWOPI]}';
K22_7A2={'lc' 'K22_7A' 0.3829 [SBANDF P25*GRADL2*0.3829 PHIL2*TWOPI]}';
K22_7A3={'lc' 'K22_7A' 2.3276 [SBANDF P25*GRADL2*2.3276 PHIL2*TWOPI]}';
K22_7B={'lc' 'K22_7B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_7C={'lc' 'K22_7C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_7D={'lc' 'K22_7D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_8A1={'lc' 'K22_8A' 0.3292 [SBANDF P25*GRADL2*0.3292 PHIL2*TWOPI]}';
K22_8A2={'lc' 'K22_8A' 0.3969 [SBANDF P25*GRADL2*0.3969 PHIL2*TWOPI]}';
K22_8A3={'lc' 'K22_8A' 2.3180 [SBANDF P25*GRADL2*2.3180 PHIL2*TWOPI]}';
K22_8B={'lc' 'K22_8B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_8C={'lc' 'K22_8C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K22_8D1={'lc' 'K22_8D' 2.3869 [SBANDF P25*GRADL2*2.3869 PHIL2*TWOPI]}';
K22_8D2={'lc' 'K22_8D' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K22_8D3={'lc' 'K22_8D' 0.4072 [SBANDF P25*GRADL2*0.4072 PHIL2*TWOPI]}';
K23_1A={'lc' 'K23_1A' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_1B={'lc' 'K23_1B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_1C={'lc' 'K23_1C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_1D={'lc' 'K23_1D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_2A1={'lc' 'K23_2A' 0.3256 [SBANDF P25*GRADL2*0.3256 PHIL2*TWOPI]}';
K23_2A2={'lc' 'K23_2A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K23_2A3={'lc' 'K23_2A' 2.4685 [SBANDF P25*GRADL2*2.4685 PHIL2*TWOPI]}';
K23_2B={'lc' 'K23_2B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_2C={'lc' 'K23_2C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_2D={'lc' 'K23_2D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_3A1={'lc' 'K23_3A' 0.3312 [SBANDF P25*GRADL2*0.3312 PHIL2*TWOPI]}';
K23_3A2={'lc' 'K23_3A' 0.3726 [SBANDF P25*GRADL2*0.3726 PHIL2*TWOPI]}';
K23_3A3={'lc' 'K23_3A' 2.3403 [SBANDF P25*GRADL2*2.3403 PHIL2*TWOPI]}';
K23_3B={'lc' 'K23_3B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_3C={'lc' 'K23_3C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_3D={'lc' 'K23_3D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_4A1={'lc' 'K23_4A' 0.3268 [SBANDF P25*GRADL2*0.3268 PHIL2*TWOPI]}';
K23_4A2={'lc' 'K23_4A' 0.3770 [SBANDF P25*GRADL2*0.3770 PHIL2*TWOPI]}';
K23_4A3={'lc' 'K23_4A' 2.3403 [SBANDF P25*GRADL2*2.3403 PHIL2*TWOPI]}';
K23_4B={'lc' 'K23_4B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_4C={'lc' 'K23_4C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_4D={'lc' 'K23_4D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_5A1={'lc' 'K23_5A' 0.3324 [SBANDF P25*GRADL2*0.3324 PHIL2*TWOPI]}';
K23_5A2={'lc' 'K23_5A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K23_5A3={'lc' 'K23_5A' 2.4617 [SBANDF P25*GRADL2*2.4617 PHIL2*TWOPI]}';
K23_5B={'lc' 'K23_5B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_5C={'lc' 'K23_5C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_5D={'lc' 'K23_5D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_6A1={'lc' 'K23_6A' 0.3280 [SBANDF P25*GRADL2*0.3280 PHIL2*TWOPI]}';
K23_6A2={'lc' 'K23_6A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K23_6A3={'lc' 'K23_6A' 2.4661 [SBANDF P25*GRADL2*2.4661 PHIL2*TWOPI]}';
K23_6B={'lc' 'K23_6B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_6C={'lc' 'K23_6C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_6D={'lc' 'K23_6D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_7A1={'lc' 'K23_7A' 0.3336 [SBANDF P25*GRADL2*0.3336 PHIL2*TWOPI]}';
K23_7A2={'lc' 'K23_7A' 0.3671 [SBANDF P25*GRADL2*0.3671 PHIL2*TWOPI]}';
K23_7A3={'lc' 'K23_7A' 2.3434 [SBANDF P25*GRADL2*2.3434 PHIL2*TWOPI]}';
K23_7B={'lc' 'K23_7B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_7C={'lc' 'K23_7C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_7D={'lc' 'K23_7D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_8A1={'lc' 'K23_8A' 0.3292 [SBANDF P25*GRADL2*0.3292 PHIL2*TWOPI]}';
K23_8A2={'lc' 'K23_8A' 0.4064 [SBANDF P25*GRADL2*0.4064 PHIL2*TWOPI]}';
K23_8A3={'lc' 'K23_8A' 2.3085 [SBANDF P25*GRADL2*2.3085 PHIL2*TWOPI]}';
K23_8B={'lc' 'K23_8B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_8C={'lc' 'K23_8C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K23_8D1={'lc' 'K23_8D' 2.3869 [SBANDF P25*GRADL2*2.3869 PHIL2*TWOPI]}';
K23_8D2={'lc' 'K23_8D' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K23_8D3={'lc' 'K23_8D' 0.4072 [SBANDF P25*GRADL2*0.4072 PHIL2*TWOPI]}';
K24_1A={'lc' 'K24_1A' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_1B={'lc' 'K24_1B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_1C={'lc' 'K24_1C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_1D={'lc' 'K24_1D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_2A1={'lc' 'K24_2A' 0.3716 [SBANDF P25*GRADL2*0.3716 PHIL2*TWOPI]}';
K24_2A2={'lc' 'K24_2A' 0.2810 [SBANDF P25*GRADL2*0.2810 PHIL2*TWOPI]}';
K24_2A3={'lc' 'K24_2A' 2.3915 [SBANDF P25*GRADL2*2.3915 PHIL2*TWOPI]}';
K24_2B={'lc' 'K24_2B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_2C={'lc' 'K24_2C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_2D={'lc' 'K24_2D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_3A1={'lc' 'K24_3A' 0.3312 [SBANDF P25*GRADL2*0.3312 PHIL2*TWOPI]}';
K24_3A2={'lc' 'K24_3A' 0.2500 [SBANDF P25*GRADL2*0.2500 PHIL2*TWOPI]}';
K24_3A3={'lc' 'K24_3A' 2.4629 [SBANDF P25*GRADL2*2.4629 PHIL2*TWOPI]}';
K24_3B={'lc' 'K24_3B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_3C={'lc' 'K24_3C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_3D={'lc' 'K24_3D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_4A1={'lc' 'K24_4A' 0.3268 [SBANDF P25*GRADL2*0.3268 PHIL2*TWOPI]}';
K24_4A2={'lc' 'K24_4A' 0.3048 [SBANDF P25*GRADL2*0.3048 PHIL2*TWOPI]}';
K24_4A3={'lc' 'K24_4A' 2.4125 [SBANDF P25*GRADL2*2.4125 PHIL2*TWOPI]}';
K24_4B={'lc' 'K24_4B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_4C={'lc' 'K24_4C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_4D={'lc' 'K24_4D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_5A1={'lc' 'K24_5A' 0.3324 [SBANDF P25*GRADL2*0.3324 PHIL2*TWOPI]}';
K24_5A2={'lc' 'K24_5A' 0.3048 [SBANDF P25*GRADL2*0.3048 PHIL2*TWOPI]}';
K24_5A3={'lc' 'K24_5A' 2.4069 [SBANDF P25*GRADL2*2.4069 PHIL2*TWOPI]}';
K24_5B={'lc' 'K24_5B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_5C={'lc' 'K24_5C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_5D={'lc' 'K24_5D' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_6A1={'lc' 'K24_6A' 0.3280 [SBANDF P25*GRADL2*0.3280 PHIL2*TWOPI]}';
K24_6A2={'lc' 'K24_6A' 0.3048 [SBANDF P25*GRADL2*0.3048 PHIL2*TWOPI]}';
K24_6A3={'lc' 'K24_6A' 2.4113 [SBANDF P25*GRADL2*2.4113 PHIL2*TWOPI]}';
K24_6B={'lc' 'K24_6B' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_6C={'lc' 'K24_6C' 3.0441 [SBANDF P25*GRADL2*3.0441 PHIL2*TWOPI]}';
K24_6D1={'lc' 'K24_6D' 2.3321 [SBANDF P25*GRADL2*2.3321 PHIL2*TWOPI]}';
K24_6D2={'lc' 'K24_6D' 0.3048 [SBANDF P25*GRADL2*0.3048 PHIL2*TWOPI]}';
K24_6D3={'lc' 'K24_6D' 0.4072 [SBANDF P25*GRADL2*0.4072 PHIL2*TWOPI]}';
% ==============================================================================
% XCORs
% ------------------------------------------------------------------------------
XC21402={'mo' 'XC21402' 0 []}';%fast-feedback (loop-2)
XC21502={'mo' 'XC21502' 0 []}';
XC21602={'mo' 'XC21602' 0 []}';
XC21702={'mo' 'XC21702' 0 []}';
XC21802={'mo' 'XC21802' 0 []}';%fast-feedback (loop-2)
XC21900={'mo' 'XC21900' 0 []}';
XC22202={'mo' 'XC22202' 0 []}';
XC22302={'mo' 'XC22302' 0 []}';
XC22402={'mo' 'XC22402' 0 []}';
XC22502={'mo' 'XC22502' 0 []}';
XC22602={'mo' 'XC22602' 0 []}';
XC22702={'mo' 'XC22702' 0 []}';
XC22802={'mo' 'XC22802' 0 []}';
XC22900={'mo' 'XC22900' 0 []}';
XC23202={'mo' 'XC23202' 0 []}';
XC23302={'mo' 'XC23302' 0 []}';
XC23402={'mo' 'XC23402' 0 []}';
XC23502={'mo' 'XC23502' 0 []}';
XC23602={'mo' 'XC23602' 0 []}';
XC23702={'mo' 'XC23702' 0 []}';
XC23802={'mo' 'XC23802' 0 []}';
XC23900={'mo' 'XC23900' 0 []}';
XC24202={'mo' 'XC24202' 0 []}';
XC24302={'mo' 'XC24302' 0 []}';
XC24402={'mo' 'XC24402' 0 []}';
XC24502={'mo' 'XC24502' 0 []}';
XC24602={'mo' 'XC24602' 0 []}';
XC24702={'mo' 'XC24702' 0 []}';%calibrated to <1%
% ==============================================================================
% YCORs
% ------------------------------------------------------------------------------
YC21403={'mo' 'YC21403' 0 []}';
YC21503={'mo' 'YC21503' 0 []}';%fast-feedback (loop-2)
YC21603={'mo' 'YC21603' 0 []}';
YC21703={'mo' 'YC21703' 0 []}';
YC21803={'mo' 'YC21803' 0 []}';
YC21900={'mo' 'YC21900' 0 []}';%fast-feedback (loop-2)
YC22203={'mo' 'YC22203' 0 []}';
YC22303={'mo' 'YC22303' 0 []}';
YC22403={'mo' 'YC22403' 0 []}';
YC22503={'mo' 'YC22503' 0 []}';
YC22603={'mo' 'YC22603' 0 []}';
YC22703={'mo' 'YC22703' 0 []}';
YC22803={'mo' 'YC22803' 0 []}';
YC22900={'mo' 'YC22900' 0 []}';
YC23203={'mo' 'YC23203' 0 []}';
YC23303={'mo' 'YC23303' 0 []}';
YC23403={'mo' 'YC23403' 0 []}';
YC23503={'mo' 'YC23503' 0 []}';
YC23603={'mo' 'YC23603' 0 []}';
YC23703={'mo' 'YC23703' 0 []}';
YC23803={'mo' 'YC23803' 0 []}';
YC23900={'mo' 'YC23900' 0 []}';
YC24203={'mo' 'YC24203' 0 []}';
YC24303={'mo' 'YC24303' 0 []}';
YC24403={'mo' 'YC24403' 0 []}';
YC24503={'mo' 'YC24503' 0 []}';
YC24603={'mo' 'YC24603' 0 []}';
YC24703={'mo' 'YC24703' 0 []}';%calibrated to <1%
% ==============================================================================
% BEAMLINEs
% ------------------------------------------------------------------------------
K21_3=[K21_3B1,K21_3B2,K21_3C ,K21_3D];
K21_4=[K21_4A1,XC21402,K21_4A2,YC21403,K21_4A3,K21_4B,K21_4C,K21_4D];
K21_5=[K21_5A1,XC21502,K21_5A2,YC21503,K21_5A3,K21_5B,K21_5C,K21_5D];
K21_6=[K21_6A1,XC21602,K21_6A2,YC21603,K21_6A3,K21_6B,K21_6C,K21_6D];
K21_7=[K21_7A1,XC21702,K21_7A2,YC21703,K21_7A3,K21_7B,K21_7C,K21_7D];
K21_8=[K21_8A1,XC21802,K21_8A2,YC21803,K21_8A3,K21_8B,K21_8C,K21_8D1,XC21900,K21_8D2,YC21900,K21_8D3];
LI21=[LI21BEG,ZLIN04,K21_3,DAQ1,Q21401,BPM21401,Q21401,DAQ2,K21_4,DAQ1,Q21501,BPM21501,Q21501,DAQ2,K21_5,DAQ1,Q21601,BPM21601,Q21601,DAQ2,K21_6,DAQ1,Q21701,BPM21701,Q21701,DAQ2,K21_7,DAQ1,Q21801,BPM21801,Q21801,DAQ2,K21_8,DAQ3,Q21901,BPM21901,Q21901,DAQ4,LI21END];
% ------------------------------------------------------------------------------
K22_1=[K22_1A,K22_1B,K22_1C,K22_1D];
K22_2=[K22_2A1,XC22202,K22_2A2,YC22203,K22_2A3,K22_2B,K22_2C,K22_2D];
K22_3=[K22_3A1,XC22302,K22_3A2,YC22303,K22_3A3,K22_3B,K22_3C,K22_3D];
K22_4=[K22_4A1,XC22402,K22_4A2,YC22403,K22_4A3,K22_4B,K22_4C,K22_4D];
K22_5=[K22_5A1,XC22502,K22_5A2,YC22503,K22_5A3,K22_5B,K22_5C,K22_5D];
K22_6=[K22_6A1,XC22602,K22_6A2,YC22603,K22_6A3,K22_6B,K22_6C,K22_6D];
K22_7=[K22_7A1,XC22702,K22_7A2,YC22703,K22_7A3,K22_7B,K22_7C,K22_7D];
K22_8=[K22_8A1,XC22802,K22_8A2,YC22803,K22_8A3,K22_8B,K22_8C,K22_8D1,XC22900,K22_8D2,YC22900,K22_8D3];
LI22=[LI22BEG,ZLIN05,K22_1,DAQ1,Q22201,BPM22201,Q22201,DAQ2,K22_2,DAQ1,Q22301,BPM22301,Q22301,DAQ2,K22_3,DAQ1,Q22401,BPM22401,Q22401,DAQ2,K22_4,DAQ1,Q22501,BPM22501,Q22501,DAQ2,K22_5,DAQ1,Q22601,BPM22601,Q22601,DAQ2,K22_6,DAQ1,Q22701,BPM22701,Q22701,DAQ2,K22_7,DAQ1,Q22801,BPM22801,Q22801,DAQ2,K22_8,DAQ3,Q22901,BPM22901,Q22901,DAQ4,LI22END];
% ------------------------------------------------------------------------------
K23_1=[K23_1A,K23_1B,K23_1C,K23_1D];
K23_2=[K23_2A1,XC23202,K23_2A2,YC23203,K23_2A3,K23_2B,K23_2C,K23_2D];
K23_3=[K23_3A1,XC23302,K23_3A2,YC23303,K23_3A3,K23_3B,K23_3C,K23_3D];
K23_4=[K23_4A1,XC23402,K23_4A2,YC23403,K23_4A3,K23_4B,K23_4C,K23_4D];
K23_5=[K23_5A1,XC23502,K23_5A2,YC23503,K23_5A3,K23_5B,K23_5C,K23_5D];
K23_6=[K23_6A1,XC23602,K23_6A2,YC23603,K23_6A3,K23_6B,K23_6C,K23_6D];
K23_7=[K23_7A1,XC23702,K23_7A2,YC23703,K23_7A3,K23_7B,K23_7C,K23_7D];
K23_8=[K23_8A1,XC23802,K23_8A2,YC23803,K23_8A3,K23_8B,K23_8C,K23_8D1,XC23900,K23_8D2,YC23900,K23_8D3];
LI23=[LI23BEG,ZLIN06,K23_1,DAQ1,Q23201,BPM23201,Q23201,DAQ2,K23_2,DAQ1,Q23301,BPM23301,Q23301,DAQ2,K23_3,DAQ1,Q23401,BPM23401,Q23401,DAQ2,K23_4,DAQ1,Q23501,BPM23501,Q23501,DAQ2,K23_5,DAQ1,Q23601,BPM23601,Q23601,DAQ2,K23_6,DAQ1,Q23701,BPM23701,Q23701,DAQ2,K23_7,DAQ1,Q23801,BPM23801,Q23801,DAQ2,K23_8,DAQ3,Q23901,BPM23901,Q23901,DAQ4,LI23END];
% ------------------------------------------------------------------------------
K24_1=[K24_1A,K24_1B,K24_1C,K24_1D];
K24_2=[K24_2A1,XC24202,K24_2A2,YC24203,K24_2A3,K24_2B,K24_2C,K24_2D];
%  K24_3 : LINE=(K24_3a1,XC24302,K24_3a2,YC24303,K24_3a3,K24_3b,K24_3c)    WS21 descoped in 2007
%  K24_4 : LINE=(K24_4a1,XC24402,K24_4a2,YC24403,K24_4a3,K24_4b,K24_4c)    WS22 descoped in 2007
%  K24_5 : LINE=(K24_5a1,XC24502,K24_5a2,YC24503,K24_5a3,K24_5b,K24_5c)    WS23 descoped in 2007
K24_3=[K24_3A1,XC24302,K24_3A2,YC24303,K24_3A3,K24_3B,K24_3C,K24_3D];% WS21 descoped in 2007
K24_4=[K24_4A1,XC24402,K24_4A2,YC24403,K24_4A3,K24_4B,K24_4C,K24_4D];% WS22 descoped in 2007
K24_5=[K24_5A1,XC24502,K24_5A2,YC24503,K24_5A3,K24_5B,K24_5C,K24_5D];% WS23 descoped in 2007
K24_6=[K24_6A1,XC24602,K24_6A2,YC24603,K24_6A3,K24_6B,K24_6C,K24_6D1,XC24702,K24_6D2,YC24703,K24_6D3];
LI24=[LI24BEG,ZLIN07,K24_1,DAQ1,Q24201,BPM24201,Q24201,DAQ2,K24_2,DAQ1,Q24301,BPM24301,Q24301,DAQ2,K24_3,DAQ1,Q24401,BPM24401,Q24401,DAQ2,K24_4,DAQ1,Q24501,BPM24501,Q24501,DAQ2,K24_5,DAQ1,Q24601,BPM24601,Q24601,DAQ2,K24_6,LI24END];% WS21 descoped in 2007
%                K24_3,DAQ5,DWS21,DAQ6A,Q24401,BPM24401,Q24401,DAQ2,&    WS21 descoped in 2007
%                K24_4,DAQ5,DWS22,DAQ6A,Q24501,BPM24501,Q24501,DAQ2,&    WS22 descoped in 2007
%                K24_5,DAQ5,DWS23,DAQ6A,Q24601,BPM24601,Q24601,DAQ2,&    WS23 descoped in 2007
% ------------------------------------------------------------------------------
L2=[BEGL2,LI21,LI22,LI23,LI24,ENDL2];
% ==============================================================================

% *** OPTICS=AD_ACCEL-13JUN19 ***
% ==============================================================================
% 05-MAY-2017, M. Woodley
%    Remove OTR22; change name: C30096 -> C29956
% ------------------------------------------------------------------------------
% 23-FEB-2017, M. Woodley
%    Swap locations of XC30900 and YC30900 per J. Sheppard
% ------------------------------------------------------------------------------
% 04-NOV-2016, M. Woodley
%    Make definitions of drifts around LI27/LI28 wire scanners consistent
% ------------------------------------------------------------------------------
% 15-NOV-2011, M. Woodley
%    Change LI30 wraparound quads (QUAD LI30 615 and QUAD LI30 715) to MARKERs
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
%    was negative
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
%    quadrupoles (NOTE: uses negative drifts)
% 29-NOV-2005, P. Emma
%    Add types for LCAV's, HKIC's, and VKIC's.
% 13-JUL-2005, P. Emma
%    Move TCAV3 to 25-2d for better sigZ resolution (was 25-5a).  Restored 25-5a
%    and removed 25-2d.
% 06-JUL-2005, P. Emma
%    Rename TCAVH to TCAV3.
% 02-JUN-2005, P. Emma
%    Add comments adjacent to fast-feedback correctors.
% ==============================================================================
% LCAVs
% ------------------------------------------------------------------------------
% the L3 linac consists of: 161 10   ft S-band sections @ 25% power
%                            12 10   ft S-band sections @ 50% power
%                             3  9.4 ft S-band sections @ 25% power
%                             4  7   ft S-band sections @ 25% power
% ------------------------------------------------------------------------------
K25_1A1={'lc' 'K25_1A' 0.3250 [SBANDF P25*GRADL3*0.3250 PHIL3*TWOPI]}';
K25_1A2={'lc' 'K25_1A' 0.3250 [SBANDF P25*GRADL3*0.3250 PHIL3*TWOPI]}';
K25_1A3={'lc' 'K25_1A' 2.3941 [SBANDF P25*GRADL3*2.3941 PHIL3*TWOPI]}';
K25_1B={'lc' 'K25_1B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
%K25_1c  : LCAV, FREQ=SbandF, L=3.0441, DELTAE=P25*gradL3*3.0441, PHI0=PhiL3, &
%                TYPE="10ft"
D25_1C={'dr' '' 3.0441 []}';
K25_1D={'lc' 'K25_1D' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
%D25_1d  : DRIFT,L=3.0441
K25_2A1={'lc' 'K25_2A' 0.4530 [SBANDF P25*GRADL3*0.4530 PHIL3*TWOPI]}';
K25_2A2={'lc' 'K25_2A' 0.3175 [SBANDF P25*GRADL3*0.3175 PHIL3*TWOPI]}';
K25_2A3={'lc' 'K25_2A' 2.2736 [SBANDF P25*GRADL3*2.2736 PHIL3*TWOPI]}';
K25_2B={'lc' 'K25_2B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_2C={'lc' 'K25_2C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_3A1={'lc' 'K25_3A' 0.3312 [SBANDF P25*GRADL3*0.3312 PHIL3*TWOPI]}';
K25_3A2={'lc' 'K25_3A' 0.3504 [SBANDF P25*GRADL3*0.3504 PHIL3*TWOPI]}';
K25_3A3={'lc' 'K25_3A' 2.3625 [SBANDF P25*GRADL3*2.3625 PHIL3*TWOPI]}';
K25_3B={'lc' 'K25_3B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_3C={'lc' 'K25_3C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_4A1={'lc' 'K25_4A' 0.3268 [SBANDF P25*GRADL3*0.3268 PHIL3*TWOPI]}';
K25_4A2={'lc' 'K25_4A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K25_4A3={'lc' 'K25_4A' 2.4673 [SBANDF P25*GRADL3*2.4673 PHIL3*TWOPI]}';
K25_4B={'lc' 'K25_4B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_4C={'lc' 'K25_4C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_4D={'lc' 'K25_4D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_5A1={'lc' 'K25_5A' 0.3268 [SBANDF P25*GRADL3*0.3268 PHIL3*TWOPI]}';
K25_5A2={'lc' 'K25_5A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K25_5A3={'lc' 'K25_5A' 2.4673 [SBANDF P25*GRADL3*2.4673 PHIL3*TWOPI]}';
K25_5B={'lc' 'K25_5B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_5C={'lc' 'K25_5C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_5D={'lc' 'K25_5D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_6A1={'lc' 'K25_6A' 0.3280 [SBANDF P25*GRADL3*0.3280 PHIL3*TWOPI]}';
K25_6A2={'lc' 'K25_6A' 0.3822 [SBANDF P25*GRADL3*0.3822 PHIL3*TWOPI]}';
K25_6A3={'lc' 'K25_6A' 2.3339 [SBANDF P25*GRADL3*2.3339 PHIL3*TWOPI]}';
K25_6B={'lc' 'K25_6B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_6C={'lc' 'K25_6C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_6D={'lc' 'K25_6D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_7A1={'lc' 'K25_7A' 0.3336 [SBANDF P25*GRADL3*0.3336 PHIL3*TWOPI]}';
K25_7A2={'lc' 'K25_7A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K25_7A3={'lc' 'K25_7A' 2.4605 [SBANDF P25*GRADL3*2.4605 PHIL3*TWOPI]}';
K25_7B={'lc' 'K25_7B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_7C={'lc' 'K25_7C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_7D={'lc' 'K25_7D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_8A1={'lc' 'K25_8A' 0.3292 [SBANDF P25*GRADL3*0.3292 PHIL3*TWOPI]}';
K25_8A2={'lc' 'K25_8A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K25_8A3={'lc' 'K25_8A' 2.4649 [SBANDF P25*GRADL3*2.4649 PHIL3*TWOPI]}';
K25_8B={'lc' 'K25_8B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_8C={'lc' 'K25_8C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K25_8D1={'lc' 'K25_8D' 2.3869 [SBANDF P25*GRADL3*2.3869 PHIL3*TWOPI]}';
K25_8D2={'lc' 'K25_8D' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K25_8D3={'lc' 'K25_8D' 0.4072 [SBANDF P25*GRADL3*0.4072 PHIL3*TWOPI]}';
K26_1A={'lc' 'K26_1A' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_1B={'lc' 'K26_1B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_1C={'lc' 'K26_1C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_1D={'lc' 'K26_1D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_2A1={'lc' 'K26_2A' 0.3256 [SBANDF P25*GRADL3*0.3256 PHIL3*TWOPI]}';
K26_2A2={'lc' 'K26_2A' 0.3719 [SBANDF P25*GRADL3*0.3719 PHIL3*TWOPI]}';
K26_2A3={'lc' 'K26_2A' 2.3466 [SBANDF P25*GRADL3*2.3466 PHIL3*TWOPI]}';
K26_2B={'lc' 'K26_2B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_2C={'lc' 'K26_2C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_2D={'lc' 'K26_2D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_3A1={'lc' 'K26_3A' 0.3312 [SBANDF P25*GRADL3*0.3312 PHIL3*TWOPI]}';
K26_3A2={'lc' 'K26_3A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K26_3A3={'lc' 'K26_3A' 2.4629 [SBANDF P25*GRADL3*2.4629 PHIL3*TWOPI]}';
K26_3B={'lc' 'K26_3B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_3C={'lc' 'K26_3C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_3D={'lc' 'K26_3D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_4A1={'lc' 'K26_4A' 0.3268 [SBANDF P25*GRADL3*0.3268 PHIL3*TWOPI]}';
K26_4A2={'lc' 'K26_4A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K26_4A3={'lc' 'K26_4A' 2.4673 [SBANDF P25*GRADL3*2.4673 PHIL3*TWOPI]}';
K26_4B={'lc' 'K26_4B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_4C={'lc' 'K26_4C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_4D={'lc' 'K26_4D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_5A1={'lc' 'K26_5A' 0.3324 [SBANDF P25*GRADL3*0.3324 PHIL3*TWOPI]}';
K26_5A2={'lc' 'K26_5A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K26_5A3={'lc' 'K26_5A' 2.4617 [SBANDF P25*GRADL3*2.4617 PHIL3*TWOPI]}';
K26_5B={'lc' 'K26_5B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_5C={'lc' 'K26_5C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_5D={'lc' 'K26_5D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_6A1={'lc' 'K26_6A' 0.3280 [SBANDF P25*GRADL3*0.3280 PHIL3*TWOPI]}';
K26_6A2={'lc' 'K26_6A' 0.4108 [SBANDF P25*GRADL3*0.4108 PHIL3*TWOPI]}';
K26_6A3={'lc' 'K26_6A' 2.3053 [SBANDF P25*GRADL3*2.3053 PHIL3*TWOPI]}';
K26_6B={'lc' 'K26_6B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_6C={'lc' 'K26_6C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_6D={'lc' 'K26_6D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_7A1={'lc' 'K26_7A' 0.3336 [SBANDF P25*GRADL3*0.3336 PHIL3*TWOPI]}';
K26_7A2={'lc' 'K26_7A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K26_7A3={'lc' 'K26_7A' 2.4605 [SBANDF P25*GRADL3*2.4605 PHIL3*TWOPI]}';
K26_7B={'lc' 'K26_7B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_7C={'lc' 'K26_7C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_7D={'lc' 'K26_7D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_8A1={'lc' 'K26_8A' 0.3292 [SBANDF P25*GRADL3*0.3292 PHIL3*TWOPI]}';
K26_8A2={'lc' 'K26_8A' 0.3810 [SBANDF P25*GRADL3*0.3810 PHIL3*TWOPI]}';
K26_8A3={'lc' 'K26_8A' 2.3339 [SBANDF P25*GRADL3*2.3339 PHIL3*TWOPI]}';
K26_8B={'lc' 'K26_8B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_8C={'lc' 'K26_8C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K26_8D1={'lc' 'K26_8D' 2.3869 [SBANDF P25*GRADL3*2.3869 PHIL3*TWOPI]}';
K26_8D2={'lc' 'K26_8D' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K26_8D3={'lc' 'K26_8D' 0.4072 [SBANDF P25*GRADL3*0.4072 PHIL3*TWOPI]}';
K27_1A={'lc' 'K27_1A' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_1B={'lc' 'K27_1B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_1C={'lc' 'K27_1C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_1D={'lc' 'K27_1D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_2A1={'lc' 'K27_2A' 0.3256 [SBANDF P25*GRADL3*0.3256 PHIL3*TWOPI]}';
K27_2A2={'lc' 'K27_2A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K27_2A3={'lc' 'K27_2A' 2.4685 [SBANDF P25*GRADL3*2.4685 PHIL3*TWOPI]}';
K27_2B={'lc' 'K27_2B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_2C={'lc' 'K27_2C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_2D={'lc' 'K27_2D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_3A1={'lc' 'K27_3A' 0.3312 [SBANDF P25*GRADL3*0.3312 PHIL3*TWOPI]}';
K27_3A2={'lc' 'K27_3A' 0.3695 [SBANDF P25*GRADL3*0.3695 PHIL3*TWOPI]}';
K27_3A3={'lc' 'K27_3A' 2.3434 [SBANDF P25*GRADL3*2.3434 PHIL3*TWOPI]}';
K27_3B={'lc' 'K27_3B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_3C={'lc' 'K27_3C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_3D={'lc' 'K27_3D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_4A1={'lc' 'K27_4A' 0.3268 [SBANDF P25*GRADL3*0.3268 PHIL3*TWOPI]}';
K27_4A2={'lc' 'K27_4A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K27_4A3={'lc' 'K27_4A' 2.4673 [SBANDF P25*GRADL3*2.4673 PHIL3*TWOPI]}';
K27_4B={'lc' 'K27_4B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_4C={'lc' 'K27_4C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_4D={'lc' 'K27_4D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_5A1={'lc' 'K27_5A' 0.3324 [SBANDF P25*GRADL3*0.3324 PHIL3*TWOPI]}';
K27_5A2={'lc' 'K27_5A' 0.3683 [SBANDF P25*GRADL3*0.3683 PHIL3*TWOPI]}';
K27_5A3={'lc' 'K27_5A' 2.3434 [SBANDF P25*GRADL3*2.3434 PHIL3*TWOPI]}';
K27_5B={'lc' 'K27_5B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_5C={'lc' 'K27_5C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_5D={'lc' 'K27_5D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_6A1={'lc' 'K27_6A' 0.3280 [SBANDF P25*GRADL3*0.3280 PHIL3*TWOPI]}';
K27_6A2={'lc' 'K27_6A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K27_6A3={'lc' 'K27_6A' 2.4661 [SBANDF P25*GRADL3*2.4661 PHIL3*TWOPI]}';
K27_6B={'lc' 'K27_6B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_6C={'lc' 'K27_6C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_7A1={'lc' 'K27_7A' 0.3336 [SBANDF P25*GRADL3*0.3336 PHIL3*TWOPI]}';
K27_7A2={'lc' 'K27_7A' 0.3512 [SBANDF P25*GRADL3*0.3512 PHIL3*TWOPI]}';
K27_7A3={'lc' 'K27_7A' 2.3593 [SBANDF P25*GRADL3*2.3593 PHIL3*TWOPI]}';
K27_7B={'lc' 'K27_7B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_7C={'lc' 'K27_7C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_7D={'lc' 'K27_7D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_8A1={'lc' 'K27_8A' 0.3292 [SBANDF P25*GRADL3*0.3292 PHIL3*TWOPI]}';
K27_8A2={'lc' 'K27_8A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K27_8A3={'lc' 'K27_8A' 2.4649 [SBANDF P25*GRADL3*2.4649 PHIL3*TWOPI]}';
K27_8B={'lc' 'K27_8B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_8C={'lc' 'K27_8C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K27_8D1={'lc' 'K27_8D' 2.2411 [SBANDF P25*GRADL3*2.2411 PHIL3*TWOPI]}';
K27_8D2={'lc' 'K27_8D' 0.3958 [SBANDF P25*GRADL3*0.3958 PHIL3*TWOPI]}';
K27_8D3={'lc' 'K27_8D' 0.4072 [SBANDF P25*GRADL3*0.4072 PHIL3*TWOPI]}';
K28_1A={'lc' 'K28_1A' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_1B={'lc' 'K28_1B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_1C={'lc' 'K28_1C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_2A1={'lc' 'K28_2A' 0.3256 [SBANDF P25*GRADL3*0.3256 PHIL3*TWOPI]}';
K28_2A2={'lc' 'K28_2A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K28_2A3={'lc' 'K28_2A' 2.4685 [SBANDF P25*GRADL3*2.4685 PHIL3*TWOPI]}';
K28_2B={'lc' 'K28_2B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_2C={'lc' 'K28_2C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_2D={'lc' 'K28_2D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_3A1={'lc' 'K28_3A' 0.3312 [SBANDF P25*GRADL3*0.3312 PHIL3*TWOPI]}';
K28_3A2={'lc' 'K28_3A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K28_3A3={'lc' 'K28_3A' 2.4629 [SBANDF P25*GRADL3*2.4629 PHIL3*TWOPI]}';
K28_3B={'lc' 'K28_3B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_3C={'lc' 'K28_3C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_3D={'lc' 'K28_3D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_4A1={'lc' 'K28_4A' 0.3800 [SBANDF P25*GRADL3*0.3800 PHIL3*TWOPI]}';
K28_4A2={'lc' 'K28_4A' 0.2921 [SBANDF P25*GRADL3*0.2921 PHIL3*TWOPI]}';
K28_4A3={'lc' 'K28_4A' 2.3720 [SBANDF P25*GRADL3*2.3720 PHIL3*TWOPI]}';
K28_4B={'lc' 'K28_4B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_4C={'lc' 'K28_4C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_5A1={'lc' 'K28_5A' 0.3959 [SBANDF P25*GRADL3*0.3959 PHIL3*TWOPI]}';
K28_5A2={'lc' 'K28_5A' 0.3111 [SBANDF P25*GRADL3*0.3111 PHIL3*TWOPI]}';
K28_5A3={'lc' 'K28_5A' 2.3371 [SBANDF P25*GRADL3*2.3371 PHIL3*TWOPI]}';
K28_5B={'lc' 'K28_5B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_5C={'lc' 'K28_5C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
%  K28_5d  : LCAV, FREQ=SbandF, L=3.0441, DELTAE=P25*gradL3*3.0441, PHI0=PhiL3, &
%                  TYPE="10ft"
D28_5D={'dr' '' 3.0441 []}';
K28_6A1={'lc' 'K28_6A' 0.3280 [SBANDF P25*GRADL3*0.3280 PHIL3*TWOPI]}';
K28_6A2={'lc' 'K28_6A' 0.3600 [SBANDF P25*GRADL3*0.3600 PHIL3*TWOPI]}';
K28_6A3={'lc' 'K28_6A' 2.3561 [SBANDF P25*GRADL3*2.3561 PHIL3*TWOPI]}';
K28_6B={'lc' 'K28_6B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_6C={'lc' 'K28_6C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_6D={'lc' 'K28_6D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_7A1={'lc' 'K28_7A' 0.3336 [SBANDF P25*GRADL3*0.3336 PHIL3*TWOPI]}';
K28_7A2={'lc' 'K28_7A' 0.4052 [SBANDF P25*GRADL3*0.4052 PHIL3*TWOPI]}';
K28_7A3={'lc' 'K28_7A' 2.3053 [SBANDF P25*GRADL3*2.3053 PHIL3*TWOPI]}';
K28_7B={'lc' 'K28_7B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_7C={'lc' 'K28_7C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_8A1={'lc' 'K28_8A' 0.3292 [SBANDF P25*GRADL3*0.3292 PHIL3*TWOPI]}';
K28_8A2={'lc' 'K28_8A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K28_8A3={'lc' 'K28_8A' 2.4649 [SBANDF P25*GRADL3*2.4649 PHIL3*TWOPI]}';
K28_8B={'lc' 'K28_8B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_8C={'lc' 'K28_8C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K28_8D1={'lc' 'K28_8D' 2.3869 [SBANDF P25*GRADL3*2.3869 PHIL3*TWOPI]}';
K28_8D2={'lc' 'K28_8D' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K28_8D3={'lc' 'K28_8D' 0.4072 [SBANDF P25*GRADL3*0.4072 PHIL3*TWOPI]}';
K29_1A={'lc' 'K29_1A' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_1B={'lc' 'K29_1B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_1C={'lc' 'K29_1C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_2A1={'lc' 'K29_2A' 0.3256 [SBANDF P25*GRADL3*0.3256 PHIL3*TWOPI]}';
K29_2A2={'lc' 'K29_2A' 0.3528 [SBANDF P25*GRADL3*0.3528 PHIL3*TWOPI]}';
K29_2A3={'lc' 'K29_2A' 2.3657 [SBANDF P25*GRADL3*2.3657 PHIL3*TWOPI]}';
K29_2B={'lc' 'K29_2B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_2C={'lc' 'K29_2C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_2D={'lc' 'K29_2D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_3A1={'lc' 'K29_3A' 0.3312 [SBANDF P25*GRADL3*0.3312 PHIL3*TWOPI]}';
K29_3A2={'lc' 'K29_3A' 0.3599 [SBANDF P25*GRADL3*0.3599 PHIL3*TWOPI]}';
K29_3A3={'lc' 'K29_3A' 2.3530 [SBANDF P25*GRADL3*2.3530 PHIL3*TWOPI]}';
K29_3B={'lc' 'K29_3B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_3C={'lc' 'K29_3C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_3D={'lc' 'K29_3D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_4A1={'lc' 'K29_4A' 0.3268 [SBANDF P25*GRADL3*0.3268 PHIL3*TWOPI]}';
K29_4A2={'lc' 'K29_4A' 0.2500 [SBANDF P25*GRADL3*0.2500 PHIL3*TWOPI]}';
K29_4A3={'lc' 'K29_4A' 2.4673 [SBANDF P25*GRADL3*2.4673 PHIL3*TWOPI]}';
K29_4B={'lc' 'K29_4B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_4C={'lc' 'K29_4C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_5A1={'lc' 'K29_5A' 0.3800 [SBANDF P25*GRADL3*0.3800 PHIL3*TWOPI]}';
K29_5A2={'lc' 'K29_5A' 0.2762 [SBANDF P25*GRADL3*0.2762 PHIL3*TWOPI]}';
K29_5A3={'lc' 'K29_5A' 2.3879 [SBANDF P25*GRADL3*2.3879 PHIL3*TWOPI]}';
K29_5B={'lc' 'K29_5B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_5C={'lc' 'K29_5C' 3.0441 [SBANDF P50*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_6A1={'lc' 'K29_6A' 0.4498 [SBANDF P25*GRADL3*0.4498 PHIL3*TWOPI]}';
K29_6A2={'lc' 'K29_6A' 0.3715 [SBANDF P25*GRADL3*0.3715 PHIL3*TWOPI]}';
K29_6A3={'lc' 'K29_6A' 2.2228 [SBANDF P25*GRADL3*2.2228 PHIL3*TWOPI]}';
K29_6B={'lc' 'K29_6B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_6C={'lc' 'K29_6C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_6D={'lc' 'K29_6D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_7A1={'lc' 'K29_7A' 0.3336 [SBANDF P25*GRADL3*0.3336 PHIL3*TWOPI]}';
K29_7A2={'lc' 'K29_7A' 0.3988 [SBANDF P25*GRADL3*0.3988 PHIL3*TWOPI]}';
K29_7A3={'lc' 'K29_7A' 2.3117 [SBANDF P25*GRADL3*2.3117 PHIL3*TWOPI]}';
K29_7B={'lc' 'K29_7B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_7C={'lc' 'K29_7C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_7D={'lc' 'K29_7D' 2.8692 [SBANDF P25*GRADL3*2.8692 PHIL3*TWOPI]}';
K29_8A1={'lc' 'K29_8A' 0.3896 [SBANDF P25*GRADL3*0.3896 PHIL3*TWOPI]}';
K29_8A2={'lc' 'K29_8A' 0.2790 [SBANDF P25*GRADL3*0.2790 PHIL3*TWOPI]}';
K29_8A3={'lc' 'K29_8A' 2.3755 [SBANDF P25*GRADL3*2.3755 PHIL3*TWOPI]}';
K29_8B={'lc' 'K29_8B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_8C={'lc' 'K29_8C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K29_8D1={'lc' 'K29_8D' 2.4558 [SBANDF P25*GRADL3*2.4558 PHIL3*TWOPI]}';
K29_8D2={'lc' 'K29_8D' 0.2800 [SBANDF P25*GRADL3*0.2800 PHIL3*TWOPI]}';
K29_8D3={'lc' 'K29_8D' 0.3083 [SBANDF P25*GRADL3*0.3083 PHIL3*TWOPI]}';
K30_1A={'lc' 'K30_1A' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_1B={'lc' 'K30_1B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_1C={'lc' 'K30_1C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_1D={'lc' 'K30_1D' 2.1694 [SBANDF P25*GRADL3*2.1694 PHIL3*TWOPI]}';
K30_2A1={'lc' 'K30_2A' 0.5006 [SBANDF P25*GRADL3*0.5006 PHIL3*TWOPI]}';
K30_2A2={'lc' 'K30_2A' 0.3302 [SBANDF P25*GRADL3*0.3302 PHIL3*TWOPI]}';
K30_2A3={'lc' 'K30_2A' 2.2133 [SBANDF P25*GRADL3*2.2133 PHIL3*TWOPI]}';
K30_2B={'lc' 'K30_2B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_2C={'lc' 'K30_2C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_2D={'lc' 'K30_2D' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_3A1={'lc' 'K30_3A' 0.3986 [SBANDF P25*GRADL3*0.3986 PHIL3*TWOPI]}';
K30_3A2={'lc' 'K30_3A' 0.3300 [SBANDF P25*GRADL3*0.3300 PHIL3*TWOPI]}';
K30_3A3={'lc' 'K30_3A' 2.3155 [SBANDF P25*GRADL3*2.3155 PHIL3*TWOPI]}';
K30_3B={'lc' 'K30_3B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_3C={'lc' 'K30_3C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_3D={'lc' 'K30_3D' 2.1694 [SBANDF P25*GRADL3*2.1694 PHIL3*TWOPI]}';
K30_4A1={'lc' 'K30_4A' 0.3856 [SBANDF P25*GRADL3*0.3856 PHIL3*TWOPI]}';
K30_4A2={'lc' 'K30_4A' 0.2790 [SBANDF P25*GRADL3*0.2790 PHIL3*TWOPI]}';
K30_4A3={'lc' 'K30_4A' 2.3795 [SBANDF P25*GRADL3*2.3795 PHIL3*TWOPI]}';
K30_4B={'lc' 'K30_4B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_4C={'lc' 'K30_4C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_4D={'lc' 'K30_4D' 2.1694 [SBANDF P25*GRADL3*2.1694 PHIL3*TWOPI]}';
K30_5A1={'lc' 'K30_5A' 0.3726 [SBANDF P25*GRADL3*0.3726 PHIL3*TWOPI]}';
K30_5A2={'lc' 'K30_5A' 0.2920 [SBANDF P25*GRADL3*0.2920 PHIL3*TWOPI]}';
K30_5A3={'lc' 'K30_5A' 2.3795 [SBANDF P25*GRADL3*2.3795 PHIL3*TWOPI]}';
K30_5B={'lc' 'K30_5B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_5C={'lc' 'K30_5C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_5D={'lc' 'K30_5D' 2.1694 [SBANDF P25*GRADL3*2.1694 PHIL3*TWOPI]}';
K30_6A1={'lc' 'K30_6A' 0.3940 [SBANDF P25*GRADL3*0.3940 PHIL3*TWOPI]}';
K30_6A2={'lc' 'K30_6A' 0.3930 [SBANDF P25*GRADL3*0.3930 PHIL3*TWOPI]}';
K30_6A3={'lc' 'K30_6A' 0.4070 [SBANDF P25*GRADL3*0.4070 PHIL3*TWOPI]}';
K30_6A4={'lc' 'K30_6A' 0.9810 [SBANDF P25*GRADL3*0.9810 PHIL3*TWOPI]}';
K30_6A5={'lc' 'K30_6A' 0.3550 [SBANDF P25*GRADL3*0.3550 PHIL3*TWOPI]}';
K30_6A6={'lc' 'K30_6A' 0.5141 [SBANDF P25*GRADL3*0.5141 PHIL3*TWOPI]}';
K30_6B={'lc' 'K30_6B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_6C={'lc' 'K30_6C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_6D={'lc' 'K30_6D' 2.8692 [SBANDF P25*GRADL3*2.8692 PHIL3*TWOPI]}';
K30_7A1={'lc' 'K30_7A' 0.3813 [SBANDF P25*GRADL3*0.3813 PHIL3*TWOPI]}';
K30_7A2={'lc' 'K30_7A' 0.4317 [SBANDF P25*GRADL3*0.4317 PHIL3*TWOPI]}';
K30_7A3={'lc' 'K30_7A' 0.3740 [SBANDF P25*GRADL3*0.3740 PHIL3*TWOPI]}';
K30_7A4={'lc' 'K30_7A' 0.9910 [SBANDF P25*GRADL3*0.9910 PHIL3*TWOPI]}';
K30_7A5={'lc' 'K30_7A' 0.3590 [SBANDF P25*GRADL3*0.3590 PHIL3*TWOPI]}';
K30_7A6={'lc' 'K30_7A' 0.5071 [SBANDF P25*GRADL3*0.5071 PHIL3*TWOPI]}';
K30_7B={'lc' 'K30_7B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_7C={'lc' 'K30_7C' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_7D={'lc' 'K30_7D' 2.8692 [SBANDF P25*GRADL3*2.8692 PHIL3*TWOPI]}';
K30_8A1={'lc' 'K30_8A' 0.3859 [SBANDF P25*GRADL3*0.3859 PHIL3*TWOPI]}';
K30_8A2={'lc' 'K30_8A' 0.3810 [SBANDF P25*GRADL3*0.3810 PHIL3*TWOPI]}';
K30_8A3={'lc' 'K30_8A' 2.2772 [SBANDF P25*GRADL3*2.2772 PHIL3*TWOPI]}';
K30_8B={'lc' 'K30_8B' 3.0441 [SBANDF P25*GRADL3*3.0441 PHIL3*TWOPI]}';
K30_8C1={'lc' 'K30_8C' 0.7620 [SBANDF P50*GRADL3*0.7620 PHIL3*TWOPI]}';
K30_8C2={'lc' 'K30_8C' 1.4669 [SBANDF P50*GRADL3*1.4669 PHIL3*TWOPI]}';
K30_8C3={'lc' 'K30_8C' 0.8152 [SBANDF P50*GRADL3*0.8152 PHIL3*TWOPI]}';
% ==============================================================================
% DRIFs
% ------------------------------------------------------------------------------
DAQ4A={'dr' '' 0.2527 []}';
DAQ4B={'dr' '' 0.203 []}';
DAQ4C={'dr' '' 0.915 []}';
DAQ4D={'dr' '' 0.272 []}';
DAQ4E={'dr' '' 0.91 []}';
DAQ5A={'dr' '' 2.3435 []}';
DAQ6A={'dr' '' 0.7348 []}';
DAQ5B={'dr' '' 2.841 []}';
DAQ6B={'dr' '' 0.2373 []}';
DAQ5C={'dr' '' 2.841 []}';
DAQ6C={'dr' '' 0.2373 []}';
DAQ5D={'dr' '' 2.344 []}';
DAQ6D={'dr' '' 0.7343 []}';
DAQ5B1={'dr' '' 2.0907 []}';
DAQ5B2={'dr' '' 0.296 []}';
DAQ5B3={'dr' '' 0.4543 []}';
DAQ5C1={'dr' '' 2.0807 []}';
DAQ5C2={'dr' '' 0.286 []}';
DAQ5C3={'dr' '' 0.4743 []}';
DAQ8C={'dr' '' 0.3352 []}';
DAQ8D={'dr' '' 2.296 []}';
DAQ9A={'dr' '' 0.0811 []}';
DAQ9B={'dr' '' 0.128 []}';
DAQ10A={'dr' '' 0.1333 []}';
DAQ10B={'dr' '' 0.203 []}';
DAQ10C={'dr' '' 0.215 []}';
DAQ10D={'dr' '' 0.3576 []}';
DAQ10E={'dr' '' 0.7765 []}';
DAQ10F={'dr' '' 0.1324 []}';
DAQ10G={'dr' '' 0.1301 []}';
DAQ10H={'dr' '' 0.203 []}';
DAQ10I={'dr' '' 0.206 []}';
DAQ10J={'dr' '' 0.237 []}';
DAQ10K={'dr' '' 0.1328 []}';
DAQ11A={'dr' '' 0.1317 []}';
DAQ11B={'dr' '' 0.211 []}';
DAQ11C={'dr' '' 0.211 []}';
DAQ11D={'dr' '' 0.1536 []}';
D10CA={'dr' '' 2.8157 []}';
D10CB={'dr' '' 0.2284 []}';
D10CC={'dr' '' 2.8159 []}';
D10CD={'dr' '' 0.2282 []}';
D10CE={'dr' '' 2.8161 []}';
D10CF={'dr' '' 0.228 []}';
% ==============================================================================
% XCORs
% ------------------------------------------------------------------------------
XC24900={'mo' 'XC24900' 0 []}';
XC25202={'mo' 'XC25202' 0 []}';%fast-feedback (loop-3)
XC25302={'mo' 'XC25302' 0 []}';
XC25402={'mo' 'XC25402' 0 []}';
XC25502={'mo' 'XC25502' 0 []}';
XC25602={'mo' 'XC25602' 0 []}';%fast-feedback (loop-3)
XC25702={'mo' 'XC25702' 0 []}';
XC25802={'mo' 'XC25802' 0 []}';
XC25900={'mo' 'XC25900' 0 []}';
XC26202={'mo' 'XC26202' 0 []}';
XC26302={'mo' 'XC26302' 0 []}';
XC26402={'mo' 'XC26402' 0 []}';
XC26502={'mo' 'XC26502' 0 []}';
XC26602={'mo' 'XC26602' 0 []}';
XC26702={'mo' 'XC26702' 0 []}';
XC26802={'mo' 'XC26802' 0 []}';
XC26900={'mo' 'XC26900' 0 []}';
XC27202={'mo' 'XC27202' 0 []}';
XC27302={'mo' 'XC27302' 0 []}';
XC27402={'mo' 'XC27402' 0 []}';
XC27502={'mo' 'XC27502' 0 []}';
XC27602={'mo' 'XC27602' 0 []}';
XC27702={'mo' 'XC27702' 0 []}';
XC27802={'mo' 'XC27802' 0 []}';
XC27900={'mo' 'XC27900' 0 []}';
XC29092={'mo' 'XC29092' 0 []}';
XC28202={'mo' 'XC28202' 0 []}';
XC28302={'mo' 'XC28302' 0 []}';
XC28402={'mo' 'XC28402' 0 []}';
XC29095={'mo' 'XC29095' 0 []}';
XC28502={'mo' 'XC28502' 0 []}';
XC28602={'mo' 'XC28602' 0 []}';
XC28702={'mo' 'XC28702' 0 []}';
XC28802={'mo' 'XC28802' 0 []}';
XC28900={'mo' 'XC28900' 0 []}';
XC29202={'mo' 'XC29202' 0 []}';
XC29302={'mo' 'XC29302' 0 []}';
XC29402={'mo' 'XC29402' 0 []}';
XC29502={'mo' 'XC29502' 0 []}';
XC29602={'mo' 'XC29602' 0 []}';
XC29702={'mo' 'XC29702' 0 []}';
XC29802={'mo' 'XC29802' 0 []}';
XC29900={'mo' 'XC29900' 0 []}';
XC30202={'mo' 'XC30202' 0 []}';
XC30302={'mo' 'XC30302' 0 []}';
XC30402={'mo' 'XC30402' 0 []}';
XC30502={'mo' 'XC30502' 0 []}';
XC30602={'mo' 'XC30602' 0 []}';
XC30702={'mo' 'XC30702' 0 []}';
XC30802={'mo' 'XC30802' 0 []}';
XC30900={'mo' 'XC30900' 0 []}';
% ==============================================================================
% YCORs
% ------------------------------------------------------------------------------
YC24900={'mo' 'YC24900' 0 []}';%fast-feedback (loop-3)
YC25203={'mo' 'YC25203' 0 []}';
YC25303={'mo' 'YC25303' 0 []}';
YC25403={'mo' 'YC25403' 0 []}';
YC25503={'mo' 'YC25503' 0 []}';%fast-feedback (loop-3)
YC25603={'mo' 'YC25603' 0 []}';
YC25703={'mo' 'YC25703' 0 []}';
YC25803={'mo' 'YC25803' 0 []}';
YC25900={'mo' 'YC25900' 0 []}';
YC26203={'mo' 'YC26203' 0 []}';
YC26303={'mo' 'YC26303' 0 []}';
YC26403={'mo' 'YC26403' 0 []}';
YC26503={'mo' 'YC26503' 0 []}';
YC26603={'mo' 'YC26603' 0 []}';
YC26703={'mo' 'YC26703' 0 []}';
YC26803={'mo' 'YC26803' 0 []}';
YC26900={'mo' 'YC26900' 0 []}';
YC27203={'mo' 'YC27203' 0 []}';
YC27303={'mo' 'YC27303' 0 []}';
YC27403={'mo' 'YC27403' 0 []}';
YC27503={'mo' 'YC27503' 0 []}';
YC27603={'mo' 'YC27603' 0 []}';
YC27703={'mo' 'YC27703' 0 []}';
YC27803={'mo' 'YC27803' 0 []}';
YC27900={'mo' 'YC27900' 0 []}';
YC29092={'mo' 'YC29092' 0 []}';
YC28203={'mo' 'YC28203' 0 []}';
YC28303={'mo' 'YC28303' 0 []}';
YC28403={'mo' 'YC28403' 0 []}';
YC29095={'mo' 'YC29095' 0 []}';
YC28503={'mo' 'YC28503' 0 []}';
YC28603={'mo' 'YC28603' 0 []}';
YC28703={'mo' 'YC28703' 0 []}';
YC28803={'mo' 'YC28803' 0 []}';
YC28900={'mo' 'YC28900' 0 []}';
YC29203={'mo' 'YC29203' 0 []}';
YC29303={'mo' 'YC29303' 0 []}';
YC29403={'mo' 'YC29403' 0 []}';
YC29503={'mo' 'YC29503' 0 []}';
YC29603={'mo' 'YC29603' 0 []}';
YC29703={'mo' 'YC29703' 0 []}';
YC29803={'mo' 'YC29803' 0 []}';
YC29900={'mo' 'YC29900' 0 []}';
YC30203={'mo' 'YC30203' 0 []}';
YC30303={'mo' 'YC30303' 0 []}';
YC30403={'mo' 'YC30403' 0 []}';
YC30503={'mo' 'YC30503' 0 []}';
YC30603={'mo' 'YC30603' 0 []}';
YC30703={'mo' 'YC30703' 0 []}';
YC30803={'mo' 'YC30803' 0 []}';
YC30900={'mo' 'YC30900' 0 []}';
% ==============================================================================
% MARKERs
% ------------------------------------------------------------------------------
% profile monitors ("Decker screens")
P30013={'mo' 'P30013' 0 []}';
P30014={'mo' 'P30014' 0 []}';
P30143={'mo' 'P30143' 0 []}';
P30144={'mo' 'P30144' 0 []}';
P30443={'mo' 'P30443' 0 []}';
P30444={'mo' 'P30444' 0 []}';
P30543={'mo' 'P30543' 0 []}';
P30544={'mo' 'P30544' 0 []}';
% collimators
C29096={'dr' 'C29096' 0 []}';
C29146={'dr' 'C29146' 0 []}';
C29446={'dr' 'C29446' 0 []}';
C29546={'dr' 'C29546' 0 []}';
C29956={'dr' 'C29956' 0 []}';
C30146={'dr' 'C30146' 0 []}';
C30446={'dr' 'C30446' 0 []}';
C30546={'dr' 'C30546' 0 []}';
% miscellany
PK297={'mo' 'PK297' 0 []}';
PK299={'mo' 'PK299' 0 []}';
PK303={'mo' 'PK303' 0 []}';
PK304={'mo' 'PK304' 0 []}';
% ==============================================================================
% BEAMLINEs
% ------------------------------------------------------------------------------
K25_1=[K25_1A1,XC24900,K25_1A2,YC24900,K25_1A3,K25_1B,D25_1C,K25_1D];
K25_2=[K25_2A1,XC25202,K25_2A2,YC25203,K25_2A3,K25_2B,K25_2C];
K25_3=[K25_3A1,XC25302,K25_3A2,YC25303,K25_3A3,K25_3B,K25_3C];
K25_4=[K25_4A1,XC25402,K25_4A2,YC25403,K25_4A3,K25_4B,K25_4C,K25_4D];
K25_5=[K25_5A1,XC25502,K25_5A2,YC25503,K25_5A3,K25_5B,K25_5C,K25_5D];
K25_6=[K25_6A1,XC25602,K25_6A2,YC25603,K25_6A3,K25_6B,K25_6C,K25_6D];
K25_7=[K25_7A1,XC25702,K25_7A2,YC25703,K25_7A3,K25_7B,K25_7C,K25_7D];
K25_8=[K25_8A1,XC25802,K25_8A2,YC25803,K25_8A3,K25_8B,K25_8C,K25_8D1,XC25900,K25_8D2,YC25900,K25_8D3];
LI25=[LI25BEG,ZLIN09,K25_1,DAQ1,Q25201,BPM25201,Q25201,DAQ2,K25_2,D255A,IMBC2O,D255B,D255C,TCAV3,TCAV3,D255D,Q25301,BPM25301,Q25301,DAQ2,K25_3,D256A,PH03,D256B,BL22,D256C,BXKIKA,BXKIKB,D256D,DAQ1,Q25401,BPM25401,Q25401,DAQ2,K25_4,DAQ1,Q25501,BPM25501,Q25501,DAQ2,K25_5,DAQ1,Q25601,BPM25601,Q25601,DAQ2,K25_6,DAQ1,Q25701,BPM25701,Q25701,DAQ2,K25_7,DAQ1,Q25801,BPM25801,Q25801,DAQ2,K25_8,DAQ7,Q25901,BPM25901,Q25901,DAQ8A,OTR_TCAV,DAQ8B,LI25END];
% ------------------------------------------------------------------------------
K26_1=[K26_1A,K26_1B,K26_1C,K26_1D];
K26_2=[K26_2A1,XC26202,K26_2A2,YC26203,K26_2A3,K26_2B,K26_2C,K26_2D];
K26_3=[K26_3A1,XC26302,K26_3A2,YC26303,K26_3A3,K26_3B,K26_3C,K26_3D];
K26_4=[K26_4A1,XC26402,K26_4A2,YC26403,K26_4A3,K26_4B,K26_4C,K26_4D];
K26_5=[K26_5A1,XC26502,K26_5A2,YC26503,K26_5A3,K26_5B,K26_5C,K26_5D];
K26_6=[K26_6A1,XC26602,K26_6A2,YC26603,K26_6A3,K26_6B,K26_6C,K26_6D];
K26_7=[K26_7A1,XC26702,K26_7A2,YC26703,K26_7A3,K26_7B,K26_7C,K26_7D];
K26_8=[K26_8A1,XC26802,K26_8A2,YC26803,K26_8A3,K26_8B,K26_8C,K26_8D1,XC26900,K26_8D2,YC26900,K26_8D3];
LI26=[LI26BEG,ZLIN10,K26_1,DAQ1,Q26201,BPM26201,Q26201,DAQ2,K26_2,DAQ1,Q26301,BPM26301,Q26301,DAQ2,K26_3,DAQ1,Q26401,BPM26401,Q26401,DAQ2,K26_4,DAQ1,Q26501,BPM26501,Q26501,DAQ2,K26_5,DAQ1,Q26601,BPM26601,Q26601,DAQ2,K26_6,DAQ1,Q26701,BPM26701,Q26701,DAQ2,K26_7,DAQ1,Q26801,BPM26801,Q26801,DAQ2,K26_8,DAQ7,Q26901,BPM26901,Q26901,DAQ8,LI26END];
% ------------------------------------------------------------------------------
K27_1=[K27_1A,K27_1B,K27_1C,K27_1D];
K27_2=[K27_2A1,XC27202,K27_2A2,YC27203,K27_2A3,K27_2B,K27_2C,K27_2D];
K27_3=[K27_3A1,XC27302,K27_3A2,YC27303,K27_3A3,K27_3B,K27_3C,K27_3D];
K27_4=[K27_4A1,XC27402,K27_4A2,YC27403,K27_4A3,K27_4B,K27_4C,K27_4D];
K27_5=[K27_5A1,XC27502,K27_5A2,YC27503,K27_5A3,K27_5B,K27_5C,K27_5D];
K27_6=[K27_6A1,XC27602,K27_6A2,YC27603,K27_6A3,K27_6B,K27_6C];
K27_7=[K27_7A1,XC27702,K27_7A2,YC27703,K27_7A3,K27_7B,K27_7C,K27_7D];
K27_8=[K27_8A1,XC27802,K27_8A2,YC27803,K27_8A3,K27_8B,K27_8C,K27_8D1,XC27900,K27_8D2,YC27900,K27_8D3];
LI27=[LI27BEG,ZLIN11,K27_1,DAQ1,Q27201,BPM27201,Q27201,DAQ2,K27_2,DAQ1,Q27301,BPM27301,Q27301,DAQ2,K27_3,DAQ1,Q27401,BPM27401,Q27401,DAQ2,K27_4,DAQ1,Q27501,BPM27501,Q27501,DAQ2,K27_5,DAQ1,Q27601,BPM27601,Q27601,DAQ2,K27_6,DAQ5A,WS27644,DAQ6A,Q27701,BPM27701,Q27701,DAQ2,K27_7,DAQ1,Q27801,BPM27801,Q27801,DAQ2,K27_8,DAQ7,Q27901,BPM27901,Q27901,DAQ8,LI27END];
% ------------------------------------------------------------------------------
K28_1=[K28_1A,K28_1B,K28_1C];
K28_2=[K28_2A1,XC28202,K28_2A2,YC28203,K28_2A3,K28_2B,K28_2C,K28_2D];
K28_3=[K28_3A1,XC28302,K28_3A2,YC28303,K28_3A3,K28_3B,K28_3C,K28_3D];
K28_4=[K28_4A1,XC28402,K28_4A2,YC28403,K28_4A3,K28_4B,K28_4C];
K28_5=[K28_5A1,XC28502,K28_5A2,YC28503,K28_5A3,K28_5B,K28_5C,D28_5D];
K28_6=[K28_6A1,XC28602,K28_6A2,YC28603,K28_6A3,K28_6B,K28_6C,K28_6D];
K28_7=[K28_7A1,XC28702,K28_7A2,YC28703,K28_7A3,K28_7B,K28_7C];
K28_8=[K28_8A1,XC28802,K28_8A2,YC28803,K28_8A3,K28_8B,K28_8C,K28_8D1,XC28900,K28_8D2,YC28900,K28_8D3];
LI28=[LI28BEG,ZLIN12,K28_1,DAQ5B1,XC29092,DAQ5B2,YC29092,DAQ5B3,WS28144,DAQ6B,Q28201,BPM28201,Q28201,DAQ2,K28_2,DAQ1,Q28301,BPM28301,Q28301,DAQ2,K28_3,DAQ1,Q28401,BPM28401,Q28401,DAQ2,K28_4,DAQ5C1,XC29095,DAQ5C2,YC29095,DAQ5C3,WS28444,DAQ6C,Q28501,BPM28501,Q28501,DAQ2,K28_5,DAQ1,Q28601,BPM28601,Q28601,DAQ2,K28_6,DAQ1,Q28701,BPM28701,Q28701,DAQ2,K28_7,DAQ5D,WS28744,DAQ6D,Q28801,BPM28801,Q28801,DAQ2,K28_8,DAQ7,Q28901,BPM28901,Q28901,DAQ8C,C29096,DAQ8D,LI28END];
% ------------------------------------------------------------------------------
K29_1=[K29_1A,K29_1B,K29_1C];
K29_2=[K29_2A1,XC29202,K29_2A2,YC29203,K29_2A3,K29_2B,K29_2C,K29_2D];
K29_3=[K29_3A1,XC29302,K29_3A2,YC29303,K29_3A3,K29_3B,K29_3C,K29_3D];
K29_4=[K29_4A1,XC29402,K29_4A2,YC29403,K29_4A3,K29_4B,K29_4C];
K29_5=[K29_5A1,XC29502,K29_5A2,YC29503,K29_5A3,K29_5B,K29_5C];
K29_6=[K29_6A1,XC29602,K29_6A2,YC29603,K29_6A3,K29_6B,K29_6C,K29_6D];
K29_7=[K29_7A1,XC29702,K29_7A2,YC29703,K29_7A3,K29_7B,K29_7C,K29_7D];
K29_8=[K29_8A1,XC29802,K29_8A2,YC29803,K29_8A3,K29_8B,K29_8C,K29_8D1,XC29900,K29_8D2,YC29900,K29_8D3];
LI29=[LI29BEG,ZLIN13,K29_1,D10CA,C29146,D10CB,DAQ1,Q29201,BPM29201,Q29201,DAQ2,K29_2,DAQ1,Q29301,BPM29301,Q29301,DAQ2,K29_3,DAQ1,Q29401,BPM29401,Q29401,DAQ2,K29_4,D10CC,C29446,D10CD,DAQ1,Q29501,BPM29501,Q29501,DAQ2,K29_5,D10CE,C29546,D10CF,DAQ1,Q29601,BPM29601,Q29601,DAQ2,K29_6,DAQ1,Q29701,BPM29701,Q29701,DAQ2,K29_7,DAQ9A,PK297,DAQ9B,Q29801,BPM29801,Q29801,DAQ2,K29_8,DAQ3,Q29901,BPM29901,Q29901,DAQ4A,P30013,DAQ4B,P30014,DAQ4C,C29956,DAQ4D,PK299,DAQ4E,LI29END];
% ------------------------------------------------------------------------------
K30_1=[K30_1A,K30_1B,K30_1C,K30_1D];
K30_2=[K30_2A1,XC30202,K30_2A2,YC30203,K30_2A3,K30_2B,K30_2C,K30_2D];
K30_3=[K30_3A1,XC30302,K30_3A2,YC30303,K30_3A3,K30_3B,K30_3C,K30_3D];
K30_4=[K30_4A1,XC30402,K30_4A2,YC30403,K30_4A3,K30_4B,K30_4C,K30_4D];
K30_5=[K30_5A1,XC30502,K30_5A2,YC30503,K30_5A3,K30_5B,K30_5C,K30_5D];
K30_6=[K30_6A1,XC30602,K30_6A2,Q30615A,K30_6A3,YC30603,K30_6A4,Q30615B,K30_6A5,Q30615C,K30_6A6,K30_6B,K30_6C,K30_6D];
K30_7=[K30_7A1,XC30702,K30_7A2,Q30715A,K30_7A3,YC30703,K30_7A4,Q30715B,K30_7A5,Q30715C,K30_7A6,K30_7B,K30_7C,K30_7D];
K30_8=[K30_8A1,XC30802,K30_8A2,YC30803,K30_8A3,K30_8B,K30_8C1,YC30900,K30_8C2,XC30900,K30_8C3];
LI30=[LI30BEG,ZLIN14,K30_1,DAQ10A,P30143,DAQ10B,P30144,DAQ10C,C30146,DAQ10D,Q30201,BPM30201,Q30201,DAQ2,K30_2,DAQ1,Q30301,BPM30301,Q30301,DAQ2,K30_3,DAQ10E,PK303,DAQ10F,Q30401,BPM30401,Q30401,DAQ2,K30_4,DAQ10G,P30443,DAQ10H,P30444,DAQ10I,C30446,DAQ10J,PK304,DAQ10K,Q30501,BPM30501,Q30501,DAQ2,K30_5,DAQ11A,P30543,DAQ11B,P30544,DAQ11C,C30546,DAQ11D,Q30601,BPM30601,Q30601,DAQ12,K30_6,DAQ13,Q30701,BPM30701,Q30701,DAQ14,K30_7,DAQ15,Q30801,BPM30801,Q30801,DAQ16,K30_8,DAQ17,LI30END];
% ------------------------------------------------------------------------------
L3=[BEGL3,LI25,LI26,LI27,LI28,LI29,LI30,DBMARK29,ENDL3];
% ==============================================================================

% ... or simplified L1, L2, and L3 lattices (for ELEGANT)
%CALL, FILENAME="LCLS_L1e.xsif"
%CALL, FILENAME="LCLS_L2e.xsif"
%CALL, FILENAME="LCLS_L3e.xsif"
% new BSY area definitions
% *** OPTICS=AD_ACCEL-13JUN19 ***
% ==============================================================================
% Modification History
% ------------------------------------------------------------------------------
% 04-OCT-2018, M. Woodley
%  * include alternative DC extraction into CUSXR:
%    - define new drifts DBRCUSdc1A,B and DBRCUSdc2A,B (3D8.8MK3's)
%    - change definition of beamline CLTH2 (gets 0.40745 m longer)
% ------------------------------------------------------------------------------
% 21-FEB-2018, M. Woodley
%  * add BSYLTUHXTES and LCLS2cuHXTES line definitions
% 25-JAN-2018, M. Woodley
%  * remove PCBSY2/BTMBSY2 per A. Ibrahimov
% ------------------------------------------------------------------------------
% 05-MAY-2017, M. Woodley
%  * pulsed correctors XCAPM2/YCAPM2 will be timed to affect the straight-ahead
%    LTUH beam, but not the A-line beam
% ------------------------------------------------------------------------------
% 24-FEB-2017, Y. Nosochkov
%  * update some drift names
% ------------------------------------------------------------------------------
% 02-NOV-2016, Y. Nosochkov
%  * update BSYH2 definition for use with A-line pulsed magnets
% ------------------------------------------------------------------------------
% 24-JUN-2016, Y. Nosochkov
%  * update beamline definitions to avoid duplication with other files
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% from copper linac
% ------------------------------------------------------------------------------
CLTH0=[BEGCLTH_0,BSYBEG,BSYS100,S100SXRA,ENDCLTH_0];
CLTH1=[BEGCLTH_1,S100SXRB,ENDCLTH_1];
DBRCUSDC1A={'dr' '' ZBRCUSDC/2 []}';
DBRCUSDC1B={'dr' '' ZBRCUSDC/2 []}';
DBKRCUSA={'dr' '' BKRCUSA{3} []}';
DBKRCUSB={'dr' '' BKRCUSB{3} []}';
DBRCUSDC2A={'dr' '' ZBRCUSDC/2 []}';
DBRCUSDC2B={'dr' '' ZBRCUSDC/2 []}';
DBLRCUSA={'dr' '' BLRCUSA{3} []}';
DBLRCUSB={'dr' '' BLRCUSB{3} []}';
DBXSP1HA={'dr' '' BXSP1HA{3} []}';
DBXSP1HB={'dr' '' BXSP1HB{3} []}';
CLTH2=[BEGCLTH_2,DBRCUSDC1A,DBRCUSDC1B,DCKDC1,DBKRCUSA,DBKRCUSB,DCKDC2,DBRCUSDC2A,DBRCUSDC2B,DCUSBLRA,BPMCUS,DCUSBLRB,DBLRCUSA,DBLRCUSB,DBSY52C,DBXSP1HA,DBXSP1HB,ENDBSY1,ENDCLTH_2];
BSYH1=[BEGBSYH_1,SPHAL,ENDBSYH_1];
BSYH2=[BEGBSYH_2,DBKRAPM1A,DBKRAPM1B,DZAPM1,PCAPM1,DZAPM1,DBKRAPM2A,DBKRAPM2B,DZAPM2A,SCAPM2,DZAPM2B,PCAPM2,DZAPM2,DBKRAPM3A,DBKRAPM3B,DZAPM3,PCAPM3,DZAPM3,DBKRAPM4A,DBKRAPM4B,DZAPM4,PCAPM4,DZA01,DZA02,SPHBSYB,ENDBSYH_2];
% ------------------------------------------------------------------------------
CLTS=[BEGCLTS,KCUSXR,DLCUSXR,ENDCLTS];
BSYS=[BEGBSYS,BYPM2,MUWALLB,DWALLA,DUMPBSYS,DWALLB,BSYENDB,RWWAKE3S,ENDBSYS];
% ------------------------------------------------------------------------------
BSYA=[ALINEA,ALINEB,ALINEC];
% ------------------------------------------------------------------------------
LTUS=[DBLDL21,LTUSC,RWWAKE4S,ENDLTUS];
LTUH=[LTU];
BSYLTUH=[CLTH0,CLTH1,CLTH2,BSYH1,BSYH2,LTUH,HXRUND,DUMPLINE];
BSYLTUHS=[CLTH0,CLTH1,CLTH2,BSYH1,BSYH2,LTUH,HXRUND,SFTDUMP];
BSYLTUS=[CLTH0,CLTH1,CLTS,BSYS,LTUS,SXRUND,DUMPLINEB];
BSYLTUSS=[CLTH0,CLTH1,CLTS,BSYS,LTUS,SXRUND,SFTDUMPB];
BSYALINE=[CLTH0,CLTH1,CLTH2,BSYH1,BSYA];
BSYLTUHXTES=[CLTH0,CLTH1,CLTH2,BSYH1,BSYH2,LTUH,HXRUND,SFTDUMP1,HXTES];
LCLS2CUC=[DL1,L1,BC1,L2,BC2,L3];%common
LCLS2CUH=[LCLS2CUC,BSYLTUH];%to HXR
LCLS2CUHS=[LCLS2CUC,BSYLTUHS];%to HXR safety dump
LCLS2CUS=[LCLS2CUC,BSYLTUS];%to SXR
LCLS2CUSS=[LCLS2CUC,BSYLTUSS];%to SXR safety dump
LCLS2CUA=[LCLS2CUC,BSYALINE];%to A-line
LCLS2CUHXTES=[LCLS2CUC,BSYLTUHXTES];%to HXR XTES system
% ------------------------------------------------------------------------------

% beam paths
%CU_HXR   : copper linac to e- HXR dump
%CU_SFTH  : copper linac to e- HXR safety dump
%CU_HXTES : copper linac to HXR XTES system
%CU_SXR   : copper linac to e- SXR dump
%CU_ALINE : copper linac to End Station A
%CU_GSPEC : copper linac to gun spectrometer
%CU_SPEC  : copper linac to 135 MeV spectrometer
CU_HXR=[GUNL0A,L0B,LCLS2CUH];
CU_SFTH=[GUNL0A,L0B,LCLS2CUHS];
CU_HXTES=[GUNL0A,L0B,LCLS2CUHXTES];
CU_SXR=[GUNL0A,L0B,LCLS2CUS];
CU_ALINE=[GUNL0A,L0B,LCLS2CUA];
CU_GSPEC=[GUNBXG,GSPEC];
CU_SPEC=[GUNL0A,L0B,DL1_1,SPECBL];
% ------------------------------------------------------------------------------
% initial SURVEY coordinates
% ------------------------------------------------------------------------------
% set initial linac survey coordinates
% (NOTE: pitch is not included here for simplicity - for linac coordinates,
%        read in pitched plane of linac)
XLL =  10.9474                   ;%X at loadlock start [m]
ZLL =  2032.0-14.8125+ZOFFINJ    ;%Z at loadlock start (move injector ~12 mm dnstr. - Nov. 17, 2004, -PE) [m]
XI =  XLL+LOADLOCK{3}*sin(ADL1) ;%subtract from upbeam side of loadlock to get to cathode [m]
ZI =  ZLL+LOADLOCK{3}*cos(ADL1) ;%subtract from upbeam side of loadlock to get to cathode [m]
%VALUE, ADL1,Xi,Zi
% initial BSY survey coordinates at BSYbeg
XF =   0           ;%hor. position is on linac axis, which is zero here [m]
YF =   0.027987637 ;%at BSYbeg (~6 m upbeam S100) in undulator coordinates (for LTU engineers)
ZF =  -5.99493367  ;%at BSYbeg (~6 m upbeam S100) in undulator coordinates (for LTU engineers)
THETAF =   0           ;%no yaw at S100
PSIF =   0           ;%no roll at S100
PHIF =  2*AVB        ;%S100 pitch in undulator coordinates (for LTU engineers)
%VALUE, Xf,Yf,Zf,THETAf,PHIf,PSIf,AVB
% linac survey coordinates at BSYbeg (BEGBSY1)
XBSY1 =  -3.309620550E-07;
ZBSY1 =   3042.005;
THBSY1 =  -2.000049721E-12;
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% input beam definitions
% ------------------------------------------------------------------------------



% ------------------------------------------------------------------------------
% BETA0 block definitions
% ------------------------------------------------------------------------------
% twiss parameters at L0a-exit:
TWSS0=struct('ENERGY',E0I,'BETX',TBETX,'ALFX',TALFX,'BETY',TBETY,'ALFY',TALFY);
% Dummy, fitted twiss parameters at cathode which yield the above twiss parameters at
% L0a-exit (for plotting purposes only - assumes only drift between cathode and L0a-exit)
TWSSC=struct('ENERGY',E00,'BETX',CBETX,'ALFX',CALFX,'BETY',CBETY,'ALFY',CALFY);
% initial Twiss for SXR dogleg cells for Cu-linac beam (at DBMARK34B)
TWSSMCUS=struct('ENERGY',EF,'BETX',MBETXCUS,'ALFX',MALFXCUS,'BETY',MBETYCUS,'ALFY',MALFYCUS);
% periodic Twiss in HXR dogleg cells (copy from LCLS2sc_main.mad8)
TWSSMH=struct('ENERGY',EF,'BETX',MBETXH,'ALFX',MALFXH,'BETY',MBETYH,'ALFY',MALFYH);
% Twiss at the beginning of L3 linac
TWBEGL3=struct('BETX',BXBEGL3,'ALFX',AXBEGL3,'BETY',BYBEGL3,'ALFY',AYBEGL3,'ENERGY',ENBEGL3);
% Twiss at the end of L3 linac
TWENDL3=struct('BETX',BXENDL3,'ALFX',AXENDL3,'BETY',BYENDL3,'ALFY',AYENDL3,'ENERGY',ENENDL3);
% Twiss at the entrance of CUSXR kicker (BEGCLTS)
TWSCUS1=struct('BETX',TBXCUS1,'BETY',TBYCUS1,'ALFX',TAXCUS1,'ALFY',TAYCUS1);
% ==============================================================================
% SUBROUTINEs
% ------------------------------------------------------------------------------
% special redefinitions for 4 GeV Cu-linac beam (BC2 @ 3 GeV)
% SETCU4GEV : SUBROUTINE
%   SET, KQM22, -0.589570998224
%   SET, KQ24901, 1.082580150374
%   SET, KQ25201, 0.688761727353
%   SET, KQ25301, -0.476435254001
%   SET, KQ25401, 0.428715988011
%   SET, KQ25501, -0.39999856091

% special redefinitions for Cu-linac (high energy) beam passing through lattice
% defined for SC-linac (low energy) beam
% SETK2CUH : SUBROUTINE !for LCLS2cuH
% ! set BSY quad strengths for Cu-linac beam optics
% ! fine-tune HXR quad strengths for a better match
%   SET, KQ50Q3, 0.385752335743
%   SET, KQ4, -0.220385532634
%   SET, KQ5, 0.172839699359
%   SET, KQ6, -0.115520035877
%   SET, KQA0, 0.115396472684
%   SET, KQVM1, -0.337436663026
%   SET, KQVM2, 0.236576383993
%   SET, KQVM3, 0.71515053765
%   SET, KQVM4, -0.681649920856
%   SET, KQUM1, 0.265384062224
%   SET, KQUM2, -0.236197967124
%   SET, KQUM3, 0.165786910657
%   SET, KQUM4, -0.176289890719
%   SET, KQDHXM, -0.456644089634
%   SET, KQUE1, -0.092119193855
%   SET, KQUE2, 0.157955482519
%   SET, KQDMP, -0.155219342716

% SETK2CUS : SUBROUTINE !for LCLS2cuS
% ! fine-tune SXR quad strengths for a better match
%   SET, KQBP33, -0.644563496901
%   SET, KQBP34, 0.595165383865
%   SET, KQDBL1, -1.066849469579
%   SET, KQDBL2, 0.618084331747
%   SET, KQDL11, 0.358720317054
%   SET, KQSX16, 0.58425577059
%   SET, KQSX19, -0.916613463141
%   SET, KQSX21, 1.112461107836
%   SET, KQSX24, -1.11933302972

% SETK2CUA : SUBROUTINE !for LCLS2cuA
% ! set BSY and A-line quad strengths for Cu-linac beam optics
%   SET, KQ50Q3, 0.385752335743
%   SET, KQ4, -0.220385532634
%   SET, KQ10, 0.041961707092
%   SET, KQ11, -0.03648177506
%   SET, KQ19, 0.02837620076
%   SET, KQ20, 0.01338101228
%   SET, KQ27, -0.054612770505
%   SET, KQ28, 0.157593407299E-2
%   SET, KQ30, -0.030459807124
%   SET, KQ38, 0.035234930357

% SETK2CUXL2 : SUBROUTINE !for XLEAP-II (copy of LCLS2sc_main.mad8:SETK2scXL2)
%   SET, SETXLEAP2, 1
% ! UMXL1-4 undulator K=50
% ! self-seeding chicane R56=0.56 mm
% ! wiggler K=34
%   SET, KQEM1B, 1.782105086906
%   SET, KQEM2B, -1.893427941353
%   SET, KQEM3B, 1.4778561902
%   SET, KQEM4B, -1.008420259435
%   SET, KQE31B, 0.263097822804
%   SET, KQE32B, -0.465049032014
%   SET, KQE33B, 0.708498263073
%   SET, KQE34B, -0.702975844569
%   SET, KQE35B, 0.725508067973
%   SET, KQE36B, -0.272464322584
%   SET, KQUM1B, 1.043940116043
%   SET, KQUM2B, -1.131319760136
%   SET, KQUM3B, 0.091635243224
%   SET, KQUM4B, 0.164719091719
%   SET, KQSX16, 1.149746713176
%   SET, KQSX19, -1.551005594041
%   SET, KQSX21, 1.654950860956
%   SET, KQSX24, -1.927727127613
%   SET, KQDSXM, -0.257825061187
%   SET, KQUE1B, -0.30534765361
%   SET, KQUE2B, 0.393680974176
%   SET, KQDMPB, -0.155219672598

% ------------------------------------------------------------------------------
% %for testing the online Matlab model
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %pulsed
% 
% 
% 
% 
% 
% %SETK2cuXL2 turns on XLEAP2 components and optics
% 
% 
% 
% 

% ==============================================================================
% COMMANDs
% ------------------------------------------------------------------------------



% ------------------------------------------------------------------------------
%CALL, FILENAME="LCLS2cu_match.mad8" upstream of BSY routines not checked
%CALL, FILENAME="RDB/LCLS2cu_makeSymbols.mad8"
%CALL, FILENAME="elegant/LCLS2cu_makeElegant.mad8" use LCLS_L*e.xsif
%STOP
% ------------------------------------------------------------------------------
% SURVEY in linac coordinates
% ------------------------------------------------------------------------------
% HXR
%COMMENT






%SAVELINE, NAME="CU_HXR", FILENAME="LCLS2cuH.saveline"


%, &
%  RTAPE="LCLS2cuH_rmat.tape"



%ENDCOMMENT
% ------------------------------------------------------------------------------
% HXR safety dump
% 
% 
% 
% 
% 
% 
% 
% %SAVELINE, NAME="CU_SFTH", FILENAME="LCLS2cuHS.saveline"
% 
% 
% %, &
% %  RTAPE="LCLS2cuHS_rmat.tape"
% 
% 
% 

% ------------------------------------------------------------------------------
% HXR XTES (SURVEY only)
% 
% 
% 
% 
% 
% 
% 
% %SAVELINE, NAME="CU_HXTES", FILENAME="LCLS2cuHXTES.saveline"
% 
% 

% ------------------------------------------------------------------------------
% SXR
%COMMENT


%pulsed
%SET, SETCUS, CUSONDC DC
%VALUE, PULSED,DCMODE





%SETK2cuXL2 turns on XLEAP2 components and optics

%SAVELINE, NAME="CU_SXR", FILENAME="LCLS2cuS.saveline"


%, &
%  RTAPE="LCLS2cuS_rmat.tape"






%ENDCOMMENT
% ------------------------------------------------------------------------------
% A-line
%COMMENT






%SAVELINE, NAME="CU_ALINE", FILENAME="LCLS2cuA.saveline"


%, &
%  RTAPE="LCLS2cuA_rmat.tape"



%ENDCOMMENT
% ------------------------------------------------------------------------------
% 6 MeV gun spectrometer
%COMMENT



%SAVELINE, NAME="CU_GSPEC", FILENAME="LCLS2cuGSPEC.saveline"


%, &
%  RTAPE="LCLS2cuGSPEC_rmat.tape"

%ENDCOMMENT
% ------------------------------------------------------------------------------
% 135 MeV spectrometer
%COMMENT



%SAVELINE, NAME="CU_SPEC", FILENAME="LCLS2cuSPEC.saveline"


%, &
%  RTAPE="LCLS2cuSPEC_rmat.tape"

%ENDCOMMENT
% ------------------------------------------------------------------------------
% SURVEY in BSY coordinates (from end of L3)
% ------------------------------------------------------------------------------
% HXR
%COMMENT








%ENDCOMMENT
% ------------------------------------------------------------------------------
% HXR safety dump
%COMMENT








%ENDCOMMENT
% ------------------------------------------------------------------------------
% HXR XTES
%COMMENT







%ENDCOMMENT
% ------------------------------------------------------------------------------
% SXR
%COMMENT




%pulsed
%SET, SETCUS, CUSONDC DC
%VALUE, PULSED,DCMODE

%SETK2cuXL2 turns on XLEAP2 components and optics





%ENDCOMMENT
% ------------------------------------------------------------------------------
% A-line
%COMMENT








%ENDCOMMENT
% ------------------------------------------------------------------------------
% S100 to A-line ("A-line BSY" coordinates from Transport deck)
% Note: the "A-line BSY" coordinates differ from the LCLS BSY coordinates
% 
% 
% 
% 
% 
% 
% 
% 
% 

% ==============================================================================
% Twiss plots
% 
% 
% % Cathode to HXR Main Dump
% 
% 
% 
% 
% 
% 
% 
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=ENERGY, COLOUR=100, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac=DL1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=ENERGY, COLOUR=100, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=ENERGY, COLOUR=100, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac=DL1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac=DL1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, RANGE=BEGGUN/ENDL0, FILE=LCLS2cu_color, TITLE=Cu_linac=Gun;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, RANGE=BEGGUN/ENDL0, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, RANGE=BEGGUN/ENDL0, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=LHBEG/LHEND, FILE=LCLS2cu_color, TITLE=Cu_linac=Laser;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=LHBEG/LHEND, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=LHBEG/LHEND, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=L0BBEG/ENDDL1_2, FILE=LCLS2cu_color, TITLE=Cu_linac=L0b;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=L0BBEG/ENDDL1_2, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=L0BBEG/ENDDL1_2, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL1/ENDL1, FILE=LCLS2cu_color, TITLE=Cu_linac=L1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL1/ENDL1, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL1/ENDL1, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=BEGBC1/ENDBC1, FILE=LCLS2cu_color, TITLE=Cu_linac=BC1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=BEGBC1/ENDBC1, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=BEGBC1/ENDBC1, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL2/ENDL2, FILE=LCLS2cu_color, TITLE=Cu_linac=L2;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL2/ENDL2, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL2/ENDL2, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=BEGBC2/ENDBC2, FILE=LCLS2cu_color, TITLE=Cu_linac=BC2;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=BEGBC2/ENDBC2, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX, COLOUR=100, SPLINE, RANGE=BEGBC2/ENDBC2, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL3/ENDL3, FILE=LCLS2cu_color, TITLE=Cu_linac=L3;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL3/ENDL3, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGL3/ENDL3, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYH_2, FILE=LCLS2cu_color, TITLE=Cu_linac=BSY;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYH_2, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYH_2, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGLTUH/ENDLTUH, FILE=LCLS2cu_color, TITLE=Cu_linac=LTUH";PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGLTUH/ENDLTUH, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGLTUH/ENDLTUH, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGUNDH/ENDUNDH, FILE=LCLS2cu_color, TITLE=Cu_linac=HXR;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGUNDH/ENDUNDH, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGUNDH/ENDUNDH, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDMPH_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac=HXR;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDMPH_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDMPH_1/DUMPFACE, FILE=LCLS2cu_color, TITLE=Cu_linac';
% % Cathode to HXR Safety Dump
% 
% 
% 
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGSFTH_1/SFTDUMP, FILE=LCLS2cu_color, TITLE=Cu_linac=HXR;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGSFTH_1/SFTDUMP, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGSFTH_1/SFTDUMP, FILE=LCLS2cu_color, TITLE=Cu_linac';
% % Cathode to SXR Main Dump
% 
% %pulsed
% %SET, SETCUS, CUSONDC DC
% %VALUE, PULSED,DCMODE
% 
% 
% 
% 
% 
% %SETK2cuXL2 turns on XLEAP2 components and optics
% 
% %SAVELINE, NAME="CU_SXR", FILENAME="LCLS2cuS.saveline"
% 
% 
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=ENERGY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac=DL1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=ENERGY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=ENERGY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac=DL1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac=DL1;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDL1_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYS, FILE=LCLS2cu_color, TITLE=Cu_linac=BSY;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYS, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYS, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGLTUS/ENDLTUS, FILE=LCLS2cu_color, TITLE=Cu_linac=LTUS";PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGLTUS/ENDLTUS, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGLTUS/ENDLTUS, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGUNDS/ENDUNDS, FILE=LCLS2cu_color, TITLE=Cu_linac=SXR;PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGUNDS/ENDUNDS, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS=BETX,BETY, COLOUR=100, SPLINE, RANGE=BEGUNDS/ENDUNDS, FILE=LCLS2cu_color, TITLE=Cu_linac';
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDMPS_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac=SXR;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDMPS_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=BETX,BETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGDMPS_1/DUMPFACEB, FILE=LCLS2cu_color, TITLE=Cu_linac';
% 
% 
% 
% % Cathode to A-line
% 
% 
% 
% 
% 
% 
% PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=RBETX,RBETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYA_2, FILE=LCLS2cu_color, TITLE=Cu_linac=BSY;PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=RBETX,RBETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYA_2, FILE=LCLS2cu_color, TITLE=Cu_linac{2}='PLOT, TABLE=TWISS, HAXIS=S, VAXIS1=RBETX,RBETY, VAXIS2=DX,DY, COLOUR=100, SPLINE, RANGE=BEGCLTH_0/ENDBSYA_2, FILE=LCLS2cu_color, TITLE=Cu_linac';

% ------------------------------------------------------------------------------
%CALL, FILENAME="LCLS2cu_area_plots.mad8"
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% working stuff
% ------------------------------------------------------------------------------
% %match HXRSS chicane to R56= 15.0 um
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 

% ------------------------------------------------------------------------------

function b=SETCU4GEV(b)
for n=find(strcmp('QM22',b(:,2)))',b{n,4}(1)=-0.589570998224;end
for n=find(strcmp('Q24901A',b(:,2)))',b{n,4}(1)=1.082580150374;end
for n=find(strcmp('Q24901B',b(:,2)))',b{n,4}(1)=1.082580150374;end
for n=find(strcmp('Q25201',b(:,2)))',b{n,4}(1)=0.688761727353;end
for n=find(strcmp('Q25301',b(:,2)))',b{n,4}(1)=-0.476435254001;end
for n=find(strcmp('Q25401',b(:,2)))',b{n,4}(1)=0.428715988011;end
for n=find(strcmp('Q25501',b(:,2)))',b{n,4}(1)=-0.39999856091;end

function b=SETK2CUH(b)
for n=find(strcmp('Q50Q3',b(:,2)))',b{n,4}(1)=0.385752335743;end
for n=find(strcmp('Q4',b(:,2)))',b{n,4}(1)=-0.220385532634;end
for n=find(strcmp('Q5',b(:,2)))',b{n,4}(1)=0.172839699359;end
for n=find(strcmp('Q6',b(:,2)))',b{n,4}(1)=-0.115520035877;end
for n=find(strcmp('QA0',b(:,2)))',b{n,4}(1)=0.115396472684;end
for n=find(strcmp('QVM1',b(:,2)))',b{n,4}(1)=-0.337436663026;end
for n=find(strcmp('QVM2',b(:,2)))',b{n,4}(1)=0.236576383993;end
for n=find(strcmp('QVM3',b(:,2)))',b{n,4}(1)=0.71515053765;end
for n=find(strcmp('QVM4',b(:,2)))',b{n,4}(1)=-0.681649920856;end
for n=find(strcmp('QUM1',b(:,2)))',b{n,4}(1)=0.265384062224;end
for n=find(strcmp('QUM2',b(:,2)))',b{n,4}(1)=-0.236197967124;end
for n=find(strcmp('QUM3',b(:,2)))',b{n,4}(1)=0.165786910657;end
for n=find(strcmp('QUM4',b(:,2)))',b{n,4}(1)=-0.176289890719;end
for n=find(strcmp('QHXH46',b(:,2)))',b{n,4}(1)=-0.456644089634;end
for n=find(strcmp('QUE1',b(:,2)))',b{n,4}(1)=-0.092119193855;end
for n=find(strcmp('QUE2',b(:,2)))',b{n,4}(1)=0.157955482519;end
for n=find(strcmp('QDMP1',b(:,2)))',b{n,4}(1)=-0.155219342716;end
for n=find(strcmp('QDMP2',b(:,2)))',b{n,4}(1)=-0.155219342716;end

function b=SETK2CUS(b)
for n=find(strcmp('QBP33',b(:,2)))',b{n,4}(1)=-0.644563496901;end
for n=find(strcmp('QBP34',b(:,2)))',b{n,4}(1)=0.595165383865;end
for n=find(strcmp('QDBL1',b(:,2)))',b{n,4}(1)=-1.066849469579;end
for n=find(strcmp('QDBL2',b(:,2)))',b{n,4}(1)=0.618084331747;end
for n=find(strcmp('QDL11',b(:,2)))',b{n,4}(1)=0.358720317054;end
for n=find(strcmp('QSXH16',b(:,2)))',b{n,4}(1)=0.58425577059;end
for n=find(strcmp('QSXH19',b(:,2)))',b{n,4}(1)=-0.916613463141;end
for n=find(strcmp('QSXH21',b(:,2)))',b{n,4}(1)=1.112461107836;end
for n=find(strcmp('QSXH24',b(:,2)))',b{n,4}(1)=-1.11933302972;end

function b=SETK2CUA(b)
for n=find(strcmp('Q50Q3',b(:,2)))',b{n,4}(1)=0.385752335743;end
for n=find(strcmp('Q4',b(:,2)))',b{n,4}(1)=-0.220385532634;end
for n=find(strcmp('Q10',b(:,2)))',b{n,4}(1)=0.041961707092;end
for n=find(strcmp('Q11',b(:,2)))',b{n,4}(1)=-0.03648177506;end
for n=find(strcmp('Q19',b(:,2)))',b{n,4}(1)=0.02837620076;end
for n=find(strcmp('Q20',b(:,2)))',b{n,4}(1)=0.01338101228;end
for n=find(strcmp('Q27',b(:,2)))',b{n,4}(1)=-0.054612770505;end
for n=find(strcmp('Q28',b(:,2)))',b{n,4}(1)=0.157593407299E-2;end
for n=find(strcmp('Q30',b(:,2)))',b{n,4}(1)=-0.030459807124;end
for n=find(strcmp('Q38',b(:,2)))',b{n,4}(1)=0.035234930357;end

function b=SETK2CUXL2(b)
for n=find(strcmp('QEM1B',b(:,2)))',b{n,4}(1)=1.782105086906;end
for n=find(strcmp('QEM2B',b(:,2)))',b{n,4}(1)=-1.893427941353;end
for n=find(strcmp('QEM3B',b(:,2)))',b{n,4}(1)=1.4778561902;end
for n=find(strcmp('QEM4B',b(:,2)))',b{n,4}(1)=-1.008420259435;end
for n=find(strcmp('QE31B',b(:,2)))',b{n,4}(1)=0.263097822804;end
for n=find(strcmp('QE32B',b(:,2)))',b{n,4}(1)=-0.465049032014;end
for n=find(strcmp('QE33B',b(:,2)))',b{n,4}(1)=0.708498263073;end
for n=find(strcmp('QE34B',b(:,2)))',b{n,4}(1)=-0.702975844569;end
for n=find(strcmp('QE35B',b(:,2)))',b{n,4}(1)=0.725508067973;end
for n=find(strcmp('QE36B',b(:,2)))',b{n,4}(1)=-0.272464322584;end
for n=find(strcmp('QUM1B',b(:,2)))',b{n,4}(1)=1.043940116043;end
for n=find(strcmp('QUM2B',b(:,2)))',b{n,4}(1)=-1.131319760136;end
for n=find(strcmp('QUM3B',b(:,2)))',b{n,4}(1)=0.091635243224;end
for n=find(strcmp('QUM4B',b(:,2)))',b{n,4}(1)=0.164719091719;end
for n=find(strcmp('QSXH16',b(:,2)))',b{n,4}(1)=1.149746713176;end
for n=find(strcmp('QSXH19',b(:,2)))',b{n,4}(1)=-1.551005594041;end
for n=find(strcmp('QSXH21',b(:,2)))',b{n,4}(1)=1.654950860956;end
for n=find(strcmp('QSXH24',b(:,2)))',b{n,4}(1)=-1.927727127613;end
for n=find(strcmp('QSXH47',b(:,2)))',b{n,4}(1)=-0.257825061187;end
for n=find(strcmp('QUE1B',b(:,2)))',b{n,4}(1)=-0.30534765361;end
for n=find(strcmp('QUE2B',b(:,2)))',b{n,4}(1)=0.393680974176;end
for n=find(strcmp('QDMP1B',b(:,2)))',b{n,4}(1)=-0.155219672598;end
for n=find(strcmp('QDMP2B',b(:,2)))',b{n,4}(1)=-0.155219672598;end

