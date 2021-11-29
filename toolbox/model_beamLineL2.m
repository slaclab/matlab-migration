function beamLine = model_beamLineL2()
%MODEL_BEAMLINEL2
% BEAMLINE = MODEL_BEAMLINEL2() Returns beam line description list for L2.

% Features:

% Input arguments: none

% Output arguments:
%    BEAMLINE: Cell array of beam line information for L2

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

  GeV2MeV =1000.0;        %GeV to MeV
  EBC1   = 0.250;    %BC1 energy (GeV)
  EBC2   = 4.300;    %BC2 energy (GeV)
  TWOPI  = 2*pi;

% global LCAV parameters

  SbandF = 2856.0;    %rf frequency (MHz)
  DLWL10 = 3.0441;    %"10  ft" (29 Sband wavelengths; 87 DLWG cavities)
%  DLWL9  = 2.8692;    %"9.41 ft" (27 1/3 Sband wavelengths; 82 DLWG cavities)
%  DLWL7  = 2.1694;    %"7   ft" (20 2/3 Sband wavelengths; 62 DLWG cavities)
  P25    = 1;         %25% power factor
  P50    = sqrt(2);   %50% power factor

% L2 energy profile

  L2phase = -41.4;               %L2 rf phase (deg)
  dEL2    = GeV2MeV*(EBC2-EBC1); %total L2 energy gain (MeV)
  PhiL2   = L2phase/360;         %radians/2pi
  gfac2   = 110*P25*DLWL10+1*P50*DLWL10;
  gradL2  = dEL2/(gfac2*cos(PhiL2*TWOPI));

  L2beg   ={'mo' '' 0 []}';
  LI21beg ={'mo' '' 0 []}';
  LI21end ={'mo' '' 0 []}';
  LI22beg ={'mo' '' 0 []}';
  LI22end ={'mo' '' 0 []}';
  LI23beg ={'mo' '' 0 []}';
  LI23end ={'mo' '' 0 []}';
  LI24beg ={'mo' '' 0 []}';
  LI24end ={'mo' '' 0 []}';
  L2end   ={'mo' '' 0 []}';

  ZLIN04  ={'mo' 'ZLIN04' 0 []}'; % entrance to 21-3b            : Z=2059.732900
  ZLIN05  ={'mo' 'ZLIN05' 0 []}'; % start of LI22                : Z=2133.600000
  ZLIN06  ={'mo' 'ZLIN06' 0 []}'; % start of LI23                : Z=2235.200000
  ZLIN07  ={'mo' 'ZLIN07' 0 []}'; % start of LI24                : Z=2336.800000

% L1/2/3 FODO cells

%  D9   ={'dr' '' DLWL9 []}';
%  D10  ={'dr' '' DLWL10 []}';
  DAQ1 ={'dr' '' 0.0342 []}';
  DAQ2 ={'dr' '' 0.027 []}';

% L2 and L3

  DAQ3  ={'dr' '' 0.3533 []}';
  DAQ4  ={'dr' '' 2.5527 []}';
%{
  DAQ5  ={'dr' '' 2.841-0.3048-1.2192 []}';
  DAQ6  ={'dr' '' 0.2373 []}';
  DAQ6A ={'dr' '' 0.2373+0.3048+1.2192 []}';
  DAQ7  ={'dr' '' 0.2748 []}';
  DAQ8  ={'dr' '' 2.6312 []}';
  DAQ8A ={'dr' '' 0.5+0.003200 []}';
  DAQ8B ={'dr' '' 2.1312-0.003200 []}';
  DAQ12 ={'dr' '' 0.2286 []}';
  DAQ13 ={'dr' '' 0.0231 []}';
  DAQ14 ={'dr' '' 0.2130 []}';
  DAQ15 ={'dr' '' 0.0087 []}';
  DAQ16 ={'dr' '' 0.2274 []}';
  DAQ17 ={'dr' '' 3.9709 []}';
  D255a ={'dr' '' 0.06621-0.001510 []}';
  D255b ={'dr' '' 0.11184+0.001510 []}';
  D255c ={'dr' '' 0.17805-0.275500+0.25 []}';
  D255d ={'dr' '' 0.03420+0.275500 []}';
  D256a ={'dr' '' 2.350-1.1919-0.559100 []}';
  D256b ={'dr' '' 0.559100 []}';
  D256e ={'dr' '' 1.019800-0.540500 []}';
  D256c ={'dr' '' 0.540500-0.40505 []}';
  D256d ={'dr' '' 0.21115 []}';
%}

% L2

  LQE = 0.1068;         %QE effective length (m)
  KQL2 = 0.708388522907;

%  QFL2 ={'qu' '' LQE/2 +KQL2}';
%  QDL2 ={'qu' '' LQE/2 -KQL2}';

  KQ21401 =  1.044881943081; % (QE-002 after Aug 2006)
  KQ21501 = -0.833170329125; % (use pre-Aug-2006 Q21201 magnet)
  KQ21601 =  KQL2;           % (use pre-Aug-2006 Q21301 magnet)
  KQ21701 = -KQL2;
  KQ21801 =  0.721703961622;
  KQ21901 = -0.721930035688;

  KQ22201 =  0.711368406706;
  KQ22301 = -0.764179973154;
  KQ22401 =  KQL2;
  KQ22501 = -KQL2;
  KQ22601 =  KQL2;
  KQ22701 = -KQL2;
  KQ22801 =  0.748596129657;
  KQ22901 = -0.709657173604;

  KQ23201 =  0.721241098608;
  KQ23301 = -0.741011348313;
  KQ23401 =  KQL2;
  KQ23501 = -KQL2;
  KQ23601 =  KQL2;
  KQ23701 = -KQL2;
  KQ23801 =  0.770675623153;
  KQ23901 = -0.726878264576;

  KQ24201 =  0.779404953697;
  KQ24301 = -0.856812505218;
  KQ24401 =  1.025618689057;
  KQ24501 = -0.931675081162;
  KQ24601 =  0.603160584173;

  Q21401 ={'qu' 'Q21401' LQE/2 KQ21401}';
  Q21501 ={'qu' 'Q21501' LQE/2 KQ21501}';
  Q21601 ={'qu' 'Q21601' LQE/2 KQ21601}';
  Q21701 ={'qu' 'Q21701' LQE/2 KQ21701}';
  Q21801 ={'qu' 'Q21801' LQE/2 KQ21801}';
  Q21901 ={'qu' 'Q21901' LQE/2 KQ21901}';

  Q22201 ={'qu' 'Q22201' LQE/2 KQ22201}';
  Q22301 ={'qu' 'Q22301' LQE/2 KQ22301}';
  Q22401 ={'qu' 'Q22401' LQE/2 KQ22401}';
  Q22501 ={'qu' 'Q22501' LQE/2 KQ22501}';
  Q22601 ={'qu' 'Q22601' LQE/2 KQ22601}';
  Q22701 ={'qu' 'Q22701' LQE/2 KQ22701}';
  Q22801 ={'qu' 'Q22801' LQE/2 KQ22801}';
  Q22901 ={'qu' 'Q22901' LQE/2 KQ22901}';

  Q23201 ={'qu' 'Q23201' LQE/2 KQ23201}';
  Q23301 ={'qu' 'Q23301' LQE/2 KQ23301}';
  Q23401 ={'qu' 'Q23401' LQE/2 KQ23401}';
  Q23501 ={'qu' 'Q23501' LQE/2 KQ23501}';
  Q23601 ={'qu' 'Q23601' LQE/2 KQ23601}';
  Q23701 ={'qu' 'Q23701' LQE/2 KQ23701}';
  Q23801 ={'qu' 'Q23801' LQE/2 KQ23801}';
  Q23901 ={'qu' 'Q23901' LQE/2 KQ23901}';

  Q24201 ={'qu' 'Q24201' LQE/2 KQ24201}';
  Q24301 ={'qu' 'Q24301' LQE/2 KQ24301}';
  Q24401 ={'qu' 'Q24401' LQE/2 KQ24401}';
  Q24501 ={'qu' 'Q24501' LQE/2 KQ24501}';
  Q24601 ={'qu' 'Q24601' LQE/2 KQ24601}';

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
%  BPM24701={'mo' 'BPM24701' 0 []}';

% ==============================================================================
% 11-SEP-2007, P. Emma
%    Replace WS21,22,23 with MARKer points DWS21-23 (no longer in baseline), and
%    add back 25-3d, 4d, and 5d sections (now 110 10-ft P25% sections & 1 P50%).
% 15-DEC-2006, P. Emma
%    Move WS21,22,23 upbeam by 4 feet each to reduce possible quad-reflected dark charge.
% 13-DEC-2006, P. Emma
%    Move (~6 in.) XC24202, YC24203, YC24403, YC24503, YC24603, XC24702 per T. Osier.
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

  K21_3b1={'lc' 'K21_3b' 0.2672 [SbandF P50*gradL2*0.2672 PhiL2*TWOPI]}';

  K21_3b2={'lc' 'K21_3b' 2.7769 [SbandF P50*gradL2*2.7769 PhiL2*TWOPI]}';

  K21_3c ={'lc' 'K21_3c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_3d ={'lc' 'K21_3d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_4a1={'lc' 'K21_4a' 0.3268 [SbandF P25*gradL2*0.3268 PhiL2*TWOPI]}';

  K21_4a2={'lc' 'K21_4a' 0.3707 [SbandF P25*gradL2*0.3707 PhiL2*TWOPI]}';

  K21_4a3={'lc' 'K21_4a' 2.3466 [SbandF P25*gradL2*2.3466 PhiL2*TWOPI]}';

  K21_4b ={'lc' 'K21_4b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_4c ={'lc' 'K21_4c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_4d ={'lc' 'K21_4d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_5a1={'lc' 'K21_5a' 0.3324 [SbandF P25*gradL2*0.3324 PhiL2*TWOPI]}';

  K21_5a2={'lc' 'K21_5a' 0.3778 [SbandF P25*gradL2*0.3778 PhiL2*TWOPI]}';

  K21_5a3={'lc' 'K21_5a' 2.3339 [SbandF P25*gradL2*2.3339 PhiL2*TWOPI]}';

  K21_5b ={'lc' 'K21_5b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_5c ={'lc' 'K21_5c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_5d ={'lc' 'K21_5d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_6a1={'lc' 'K21_6a' 0.3280 [SbandF P25*gradL2*0.3280 PhiL2*TWOPI]}';

  K21_6a2={'lc' 'K21_6a' 0.3885 [SbandF P25*gradL2*0.3885 PhiL2*TWOPI]}';

  K21_6a3={'lc' 'K21_6a' 2.3276 [SbandF P25*gradL2*2.3276 PhiL2*TWOPI]}';

  K21_6b ={'lc' 'K21_6b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_6c ={'lc' 'K21_6c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_6d ={'lc' 'K21_6d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_7a1={'lc' 'K21_7a' 0.3336 [SbandF P25*gradL2*0.3336 PhiL2*TWOPI]}';

  K21_7a2={'lc' 'K21_7a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K21_7a3={'lc' 'K21_7a' 2.4605 [SbandF P25*gradL2*2.4605 PhiL2*TWOPI]}';

  K21_7b ={'lc' 'K21_7b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_7c ={'lc' 'K21_7c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_7d ={'lc' 'K21_7d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_8a1={'lc' 'K21_8a' 0.3292 [SbandF P25*gradL2*0.3292 PhiL2*TWOPI]}';

  K21_8a2={'lc' 'K21_8a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K21_8a3={'lc' 'K21_8a' 2.4649 [SbandF P25*gradL2*2.4649 PhiL2*TWOPI]}';

  K21_8b ={'lc' 'K21_8b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_8c ={'lc' 'K21_8c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K21_8d1={'lc' 'K21_8d' 2.3869 [SbandF P25*gradL2*2.3869 PhiL2*TWOPI]}';

  K21_8d2={'lc' 'K21_8d' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K21_8d3={'lc' 'K21_8d' 0.4072 [SbandF P25*gradL2*0.4072 PhiL2*TWOPI]}';


  K22_1a ={'lc' 'K22_1a' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_1b ={'lc' 'K22_1b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_1c ={'lc' 'K22_1c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_1d ={'lc' 'K22_1d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_2a1={'lc' 'K22_2a' 0.3256 [SbandF P25*gradL2*0.3256 PhiL2*TWOPI]}';

  K22_2a2={'lc' 'K22_2a' 0.3782 [SbandF P25*gradL2*0.3782 PhiL2*TWOPI]}';

  K22_2a3={'lc' 'K22_2a' 2.3403 [SbandF P25*gradL2*2.3403 PhiL2*TWOPI]}';

  K22_2b ={'lc' 'K22_2b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_2c ={'lc' 'K22_2c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_2d ={'lc' 'K22_2d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_3a1={'lc' 'K22_3a' 0.3312 [SbandF P25*gradL2*0.3312 PhiL2*TWOPI]}';

  K22_3a2={'lc' 'K22_3a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K22_3a3={'lc' 'K22_3a' 2.4629 [SbandF P25*gradL2*2.4629 PhiL2*TWOPI]}';

  K22_3b ={'lc' 'K22_3b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_3c ={'lc' 'K22_3c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_3d ={'lc' 'K22_3d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_4a1={'lc' 'K22_4a' 0.3268 [SbandF P25*gradL2*0.3268 PhiL2*TWOPI]}';

  K22_4a2={'lc' 'K22_4a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K22_4a3={'lc' 'K22_4a' 2.4673 [SbandF P25*gradL2*2.4673 PhiL2*TWOPI]}';

  K22_4b ={'lc' 'K22_4b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_4c ={'lc' 'K22_4c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_4d ={'lc' 'K22_4d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_5a1={'lc' 'K22_5a' 0.3324 [SbandF P25*gradL2*0.3324 PhiL2*TWOPI]}';

  K22_5a2={'lc' 'K22_5a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K22_5a3={'lc' 'K22_5a' 2.4617 [SbandF P25*gradL2*2.4617 PhiL2*TWOPI]}';

  K22_5b ={'lc' 'K22_5b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_5c ={'lc' 'K22_5c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_5d ={'lc' 'K22_5d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_6a1={'lc' 'K22_6a' 0.3280 [SbandF P25*gradL2*0.3280 PhiL2*TWOPI]}';

  K22_6a2={'lc' 'K22_6a' 0.3790 [SbandF P25*gradL2*0.3790 PhiL2*TWOPI]}';

  K22_6a3={'lc' 'K22_6a' 2.3371 [SbandF P25*gradL2*2.3371 PhiL2*TWOPI]}';

  K22_6b ={'lc' 'K22_6b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_6c ={'lc' 'K22_6c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_6d ={'lc' 'K22_6d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_7a1={'lc' 'K22_7a' 0.3336 [SbandF P25*gradL2*0.3336 PhiL2*TWOPI]}';

  K22_7a2={'lc' 'K22_7a' 0.3829 [SbandF P25*gradL2*0.3829 PhiL2*TWOPI]}';

  K22_7a3={'lc' 'K22_7a' 2.3276 [SbandF P25*gradL2*2.3276 PhiL2*TWOPI]}';

  K22_7b ={'lc' 'K22_7b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_7c ={'lc' 'K22_7c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_7d ={'lc' 'K22_7d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_8a1={'lc' 'K22_8a' 0.3292 [SbandF P25*gradL2*0.3292 PhiL2*TWOPI]}';

  K22_8a2={'lc' 'K22_8a' 0.3969 [SbandF P25*gradL2*0.3969 PhiL2*TWOPI]}';

  K22_8a3={'lc' 'K22_8a' 2.3180 [SbandF P25*gradL2*2.3180 PhiL2*TWOPI]}';

  K22_8b ={'lc' 'K22_8b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_8c ={'lc' 'K22_8c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K22_8d1={'lc' 'K22_8d' 2.3869 [SbandF P25*gradL2*2.3869 PhiL2*TWOPI]}';

  K22_8d2={'lc' 'K22_8d' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K22_8d3={'lc' 'K22_8d' 0.4072 [SbandF P25*gradL2*0.4072 PhiL2*TWOPI]}';


  K23_1a ={'lc' 'K23_1a' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_1b ={'lc' 'K23_1b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_1c ={'lc' 'K23_1c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_1d ={'lc' 'K23_1d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_2a1={'lc' 'K23_2a' 0.3256 [SbandF P25*gradL2*0.3256 PhiL2*TWOPI]}';

  K23_2a2={'lc' 'K23_2a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K23_2a3={'lc' 'K23_2a' 2.4685 [SbandF P25*gradL2*2.4685 PhiL2*TWOPI]}';

  K23_2b ={'lc' 'K23_2b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_2c ={'lc' 'K23_2c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_2d ={'lc' 'K23_2d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_3a1={'lc' 'K23_3a' 0.3312 [SbandF P25*gradL2*0.3312 PhiL2*TWOPI]}';

  K23_3a2={'lc' 'K23_3a' 0.3726 [SbandF P25*gradL2*0.3726 PhiL2*TWOPI]}';

  K23_3a3={'lc' 'K23_3a' 2.3403 [SbandF P25*gradL2*2.3403 PhiL2*TWOPI]}';

  K23_3b ={'lc' 'K23_3b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_3c ={'lc' 'K23_3c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_3d ={'lc' 'K23_3d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_4a1={'lc' 'K23_4a' 0.3268 [SbandF P25*gradL2*0.3268 PhiL2*TWOPI]}';

  K23_4a2={'lc' 'K23_4a' 0.3770 [SbandF P25*gradL2*0.3770 PhiL2*TWOPI]}';

  K23_4a3={'lc' 'K23_4a' 2.3403 [SbandF P25*gradL2*2.3403 PhiL2*TWOPI]}';

  K23_4b ={'lc' 'K23_4b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_4c ={'lc' 'K23_4c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_4d ={'lc' 'K23_4d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_5a1={'lc' 'K23_5a' 0.3324 [SbandF P25*gradL2*0.3324 PhiL2*TWOPI]}';

  K23_5a2={'lc' 'K23_5a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K23_5a3={'lc' 'K23_5a' 2.4617 [SbandF P25*gradL2*2.4617 PhiL2*TWOPI]}';

  K23_5b ={'lc' 'K23_5b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_5c ={'lc' 'K23_5c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_5d ={'lc' 'K23_5d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_6a1={'lc' 'K23_6a' 0.3280 [SbandF P25*gradL2*0.3280 PhiL2*TWOPI]}';

  K23_6a2={'lc' 'K23_6a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K23_6a3={'lc' 'K23_6a' 2.4661 [SbandF P25*gradL2*2.4661 PhiL2*TWOPI]}';

  K23_6b ={'lc' 'K23_6b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_6c ={'lc' 'K23_6c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_6d ={'lc' 'K23_6d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_7a1={'lc' 'K23_7a' 0.3336 [SbandF P25*gradL2*0.3336 PhiL2*TWOPI]}';

  K23_7a2={'lc' 'K23_7a' 0.3671 [SbandF P25*gradL2*0.3671 PhiL2*TWOPI]}';

  K23_7a3={'lc' 'K23_7a' 2.3434 [SbandF P25*gradL2*2.3434 PhiL2*TWOPI]}';

  K23_7b ={'lc' 'K23_7b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_7c ={'lc' 'K23_7c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_7d ={'lc' 'K23_7d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_8a1={'lc' 'K23_8a' 0.3292 [SbandF P25*gradL2*0.3292 PhiL2*TWOPI]}';

  K23_8a2={'lc' 'K23_8a' 0.4064 [SbandF P25*gradL2*0.4064 PhiL2*TWOPI]}';

  K23_8a3={'lc' 'K23_8a' 2.3085 [SbandF P25*gradL2*2.3085 PhiL2*TWOPI]}';

  K23_8b ={'lc' 'K23_8b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_8c ={'lc' 'K23_8c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K23_8d1={'lc' 'K23_8d' 2.3869 [SbandF P25*gradL2*2.3869 PhiL2*TWOPI]}';

  K23_8d2={'lc' 'K23_8d' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K23_8d3={'lc' 'K23_8d' 0.4072 [SbandF P25*gradL2*0.4072 PhiL2*TWOPI]}';


  K24_1a ={'lc' 'K24_1a' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_1b ={'lc' 'K24_1b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_1c ={'lc' 'K24_1c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_1d ={'lc' 'K24_1d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_2a1={'lc' 'K24_2a' 0.3716 [SbandF P25*gradL2*0.3716 PhiL2*TWOPI]}';

  K24_2a2={'lc' 'K24_2a' 0.2810 [SbandF P25*gradL2*0.2810 PhiL2*TWOPI]}';

  K24_2a3={'lc' 'K24_2a' 2.3915 [SbandF P25*gradL2*2.3915 PhiL2*TWOPI]}';

  K24_2b ={'lc' 'K24_2b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_2c ={'lc' 'K24_2c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_2d ={'lc' 'K24_2d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_3a1={'lc' 'K24_3a' 0.3312 [SbandF P25*gradL2*0.3312 PhiL2*TWOPI]}';

  K24_3a2={'lc' 'K24_3a' 0.2500 [SbandF P25*gradL2*0.2500 PhiL2*TWOPI]}';

  K24_3a3={'lc' 'K24_3a' 2.4629 [SbandF P25*gradL2*2.4629 PhiL2*TWOPI]}';

  K24_3b ={'lc' 'K24_3b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_3c ={'lc' 'K24_3c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_3d ={'lc' 'K24_3d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_4a1={'lc' 'K24_4a' 0.3268 [SbandF P25*gradL2*0.3268 PhiL2*TWOPI]}';

  K24_4a2={'lc' 'K24_4a' 0.3048 [SbandF P25*gradL2*0.3048 PhiL2*TWOPI]}';

  K24_4a3={'lc' 'K24_4a' 2.4125 [SbandF P25*gradL2*2.4125 PhiL2*TWOPI]}';

  K24_4b ={'lc' 'K24_4b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_4c ={'lc' 'K24_4c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_4d ={'lc' 'K24_4d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_5a1={'lc' 'K24_5a' 0.3324 [SbandF P25*gradL2*0.3324 PhiL2*TWOPI]}';

  K24_5a2={'lc' 'K24_5a' 0.3048 [SbandF P25*gradL2*0.3048 PhiL2*TWOPI]}';

  K24_5a3={'lc' 'K24_5a' 2.4069 [SbandF P25*gradL2*2.4069 PhiL2*TWOPI]}';

  K24_5b ={'lc' 'K24_5b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_5c ={'lc' 'K24_5c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_5d ={'lc' 'K24_5d' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_6a1={'lc' 'K24_6a' 0.3280 [SbandF P25*gradL2*0.3280 PhiL2*TWOPI]}';

  K24_6a2={'lc' 'K24_6a' 0.3048 [SbandF P25*gradL2*0.3048 PhiL2*TWOPI]}';

  K24_6a3={'lc' 'K24_6a' 2.4113 [SbandF P25*gradL2*2.4113 PhiL2*TWOPI]}';

  K24_6b ={'lc' 'K24_6b' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_6c ={'lc' 'K24_6c' 3.0441 [SbandF P25*gradL2*3.0441 PhiL2*TWOPI]}';

  K24_6d1={'lc' 'K24_6d' 2.3321 [SbandF P25*gradL2*2.3321 PhiL2*TWOPI]}';

  K24_6d2={'lc' 'K24_6d' 0.3048 [SbandF P25*gradL2*0.3048 PhiL2*TWOPI]}';

  K24_6d3={'lc' 'K24_6d' 0.4072 [SbandF P25*gradL2*0.4072 PhiL2*TWOPI]}';

% ==============================================================================
% XCORs
% ------------------------------------------------------------------------------

  XC21402={'mo' 'XC21402' 0 []}';       % fast-feedback (loop-2)
  XC21502={'mo' 'XC21502' 0 []}';
  XC21602={'mo' 'XC21602' 0 []}';
  XC21702={'mo' 'XC21702' 0 []}';
  XC21802={'mo' 'XC21802' 0 []}';       % fast-feedback (loop-2)
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
  XC24702={'mo' 'XC24702' 0 []}';        % calibrated to <1%

% ==============================================================================
% YCORs
% ------------------------------------------------------------------------------

  YC21403={'mo' 'YC21403' 0 []}';
  YC21503={'mo' 'YC21503' 0 []}';       % fast-feedback (loop-2)
  YC21603={'mo' 'YC21603' 0 []}';
  YC21703={'mo' 'YC21703' 0 []}';
  YC21803={'mo' 'YC21803' 0 []}';
  YC21900={'mo' 'YC21900' 0 []}';       % fast-feedback (loop-2)

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
  YC24703={'mo' 'YC24703' 0 []}';        % calibrated to <1%

% ==============================================================================
% BEAMLINEs
% ------------------------------------------------------------------------------

  K21_3=[K21_3b1,K21_3b2,K21_3c ,K21_3d];
  K21_4=[K21_4a1,XC21402,K21_4a2,YC21403,K21_4a3,K21_4b,K21_4c,K21_4d];
  K21_5=[K21_5a1,XC21502,K21_5a2,YC21503,K21_5a3,K21_5b,K21_5c,K21_5d];
  K21_6=[K21_6a1,XC21602,K21_6a2,YC21603,K21_6a3,K21_6b,K21_6c,K21_6d];
  K21_7=[K21_7a1,XC21702,K21_7a2,YC21703,K21_7a3,K21_7b,K21_7c,K21_7d];
  K21_8=[K21_8a1,XC21802,K21_8a2,YC21803,K21_8a3,K21_8b,K21_8c,...
                K21_8d1,XC21900,K21_8d2,YC21900,K21_8d3];

  LI21 =[LI21beg,ZLIN04,...
                K21_3,DAQ1,Q21401,BPM21401,Q21401,DAQ2,...
                K21_4,DAQ1,Q21501,BPM21501,Q21501,DAQ2,...
                K21_5,DAQ1,Q21601,BPM21601,Q21601,DAQ2,...
                K21_6,DAQ1,Q21701,BPM21701,Q21701,DAQ2,...
                K21_7,DAQ1,Q21801,BPM21801,Q21801,DAQ2,...
                K21_8,DAQ3,Q21901,BPM21901,Q21901,DAQ4,...
                LI21end];

% ------------------------------------------------------------------------------

  K22_1=[K22_1a,K22_1b,K22_1c,K22_1d];
  K22_2=[K22_2a1,XC22202,K22_2a2,YC22203,K22_2a3,K22_2b,K22_2c,K22_2d];
  K22_3=[K22_3a1,XC22302,K22_3a2,YC22303,K22_3a3,K22_3b,K22_3c,K22_3d];
  K22_4=[K22_4a1,XC22402,K22_4a2,YC22403,K22_4a3,K22_4b,K22_4c,K22_4d];
  K22_5=[K22_5a1,XC22502,K22_5a2,YC22503,K22_5a3,K22_5b,K22_5c,K22_5d];
  K22_6=[K22_6a1,XC22602,K22_6a2,YC22603,K22_6a3,K22_6b,K22_6c,K22_6d];
  K22_7=[K22_7a1,XC22702,K22_7a2,YC22703,K22_7a3,K22_7b,K22_7c,K22_7d];
  K22_8=[K22_8a1,XC22802,K22_8a2,YC22803,K22_8a3,K22_8b,K22_8c,...
                K22_8d1,XC22900,K22_8d2,YC22900,K22_8d3];

  LI22 =[LI22beg,ZLIN05,...
                K22_1,DAQ1,Q22201,BPM22201,Q22201,DAQ2,...
                K22_2,DAQ1,Q22301,BPM22301,Q22301,DAQ2,...
                K22_3,DAQ1,Q22401,BPM22401,Q22401,DAQ2,...
                K22_4,DAQ1,Q22501,BPM22501,Q22501,DAQ2,...
                K22_5,DAQ1,Q22601,BPM22601,Q22601,DAQ2,...
                K22_6,DAQ1,Q22701,BPM22701,Q22701,DAQ2,...
                K22_7,DAQ1,Q22801,BPM22801,Q22801,DAQ2,...
                K22_8,DAQ3,Q22901,BPM22901,Q22901,DAQ4,...
                LI22end];

% ------------------------------------------------------------------------------

  K23_1=[K23_1a,K23_1b,K23_1c,K23_1d];
  K23_2=[K23_2a1,XC23202,K23_2a2,YC23203,K23_2a3,K23_2b,K23_2c,K23_2d];
  K23_3=[K23_3a1,XC23302,K23_3a2,YC23303,K23_3a3,K23_3b,K23_3c,K23_3d];
  K23_4=[K23_4a1,XC23402,K23_4a2,YC23403,K23_4a3,K23_4b,K23_4c,K23_4d];
  K23_5=[K23_5a1,XC23502,K23_5a2,YC23503,K23_5a3,K23_5b,K23_5c,K23_5d];
  K23_6=[K23_6a1,XC23602,K23_6a2,YC23603,K23_6a3,K23_6b,K23_6c,K23_6d];
  K23_7=[K23_7a1,XC23702,K23_7a2,YC23703,K23_7a3,K23_7b,K23_7c,K23_7d];
  K23_8=[K23_8a1,XC23802,K23_8a2,YC23803,K23_8a3,K23_8b,K23_8c,...
                K23_8d1,XC23900,K23_8d2,YC23900,K23_8d3];

  LI23 =[LI23beg,ZLIN06,...
                K23_1,DAQ1,Q23201,BPM23201,Q23201,DAQ2,...
                K23_2,DAQ1,Q23301,BPM23301,Q23301,DAQ2,...
                K23_3,DAQ1,Q23401,BPM23401,Q23401,DAQ2,...
                K23_4,DAQ1,Q23501,BPM23501,Q23501,DAQ2,...
                K23_5,DAQ1,Q23601,BPM23601,Q23601,DAQ2,...
                K23_6,DAQ1,Q23701,BPM23701,Q23701,DAQ2,...
                K23_7,DAQ1,Q23801,BPM23801,Q23801,DAQ2,...
                K23_8,DAQ3,Q23901,BPM23901,Q23901,DAQ4,...
                LI23end];

% ------------------------------------------------------------------------------

  K24_1=[K24_1a,K24_1b,K24_1c,K24_1d];
  K24_2=[K24_2a1,XC24202,K24_2a2,YC24203,K24_2a3,K24_2b,K24_2c,K24_2d];
%  K24_3=[K24_3a1,XC24302,K24_3a2,YC24303,K24_3a3,K24_3b,K24_3c];   % WS21 descoped in 2007
%  K24_4=[K24_4a1,XC24402,K24_4a2,YC24403,K24_4a3,K24_4b,K24_4c];   % WS22 descoped in 2007
%  K24_5=[K24_5a1,XC24502,K24_5a2,YC24503,K24_5a3,K24_5b,K24_5c];   % WS23 descoped in 2007
  K24_3=[K24_3a1,XC24302,K24_3a2,YC24303,K24_3a3,K24_3b,K24_3c,K24_3d];   % WS21 descoped in 2007
  K24_4=[K24_4a1,XC24402,K24_4a2,YC24403,K24_4a3,K24_4b,K24_4c,K24_4d];   % WS22 descoped in 2007
  K24_5=[K24_5a1,XC24502,K24_5a2,YC24503,K24_5a3,K24_5b,K24_5c,K24_5d];   % WS23 descoped in 2007
  K24_6=[K24_6a1,XC24602,K24_6a2,YC24603,K24_6a3,K24_6b,K24_6c,...
                K24_6d1,XC24702,K24_6d2,YC24703,K24_6d3];

  LI24 =[LI24beg,ZLIN07,...
                K24_1,DAQ1,Q24201,BPM24201,Q24201,DAQ2,...
                K24_2,DAQ1,Q24301,BPM24301,Q24301,DAQ2,...
                K24_3,DAQ1,Q24401,BPM24401,Q24401,DAQ2,...   % WS21 descoped in 2007
                K24_4,DAQ1,Q24501,BPM24501,Q24501,DAQ2,...   % WS22 descoped in 2007
                K24_5,DAQ1,Q24601,BPM24601,Q24601,DAQ2,...   % WS23 descoped in 2007
                K24_6,...
                LI24end];
%                K24_3,DAQ5,DWS21,DAQ6A,Q24401,BPM24401,Q24401,DAQ2,...   % WS21 descoped in 2007
%                K24_4,DAQ5,DWS22,DAQ6A,Q24501,BPM24501,Q24501,DAQ2,...   % WS22 descoped in 2007
%                K24_5,DAQ5,DWS23,DAQ6A,Q24601,BPM24601,Q24601,DAQ2,...   % WS23 descoped in 2007

% ==============================================================================


  L2   =[L2beg,...
                LI21,LI22,LI23,LI24,...
                L2end];

LINE=L2;

beamLine=LINE';
