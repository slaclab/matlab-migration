function [beamLineUN, beamLineBSY] = model_beamLineUnd(region)
%MODEL_BEAMLINEUND
% [BEAMLINEUN, BEAMLINEBSY] = MODEL_BEAMLINEUND(REGION)
%Returns beam line description list for BSY, LTU, undulator and dump.

% Features:

% Input arguments:
%    REGION: Optional argument for region, default BSY_DMP

% Output arguments:
%    BEAMLINEUN : Cell array of beam line information for BSY-DMP
%    BEAMLINEBSY: Cell array of beam line information for BSY

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% History:
%   13-Jul-2017, M. Woodley (OPTICS=LCLS05JUN17)
%    * relocate OTRDMP per A. Cedillos
%    * remove WSDUMP per K.Luchini
%    * add MIRXL (XLEAP "holey" mirror) per J. Mock
%   02-May-2017, M. Woodley
%    * add YAGBOD1, YAGBOD2, and YAGBRAG per Y. Ding
%    * return YCUM3 to its previous position upstream of QUM3 per A. Martinelli
%   28-Apr-2017, M. Woodley
%    * suppress "modelUseNewBSY" warning
%    * add period length and K-value for DELTA undulator
%    * add pulsed corrector pair XCAPM2/YCAPM2
%    * change name: DUMPBSYA -> PCBSYH
%    * remove prototype wire scanners WS35 and WS36
%   27-Apr-2017, M. Woodley (actually corresponds to LCLS27JAN17)
%    * fix lengths of BSY PCs
%    * adjust locations of XCVM2, WSVM2, WS35, and YAGPSI
%    * correct BFW-quad separation per H. Loos
%    * replace US33 with DELTA undulator
%    * adjust locations of RFBU34, RFBUE1, XCUE1, PH31, and PH32 per M. Carrasco
%   25-Jan-2017, M. Woodley (OPTICS=LCLS27JAN17)
%    * reconfigured BSY
%    * install XLEAP components
%    * rearrange Undulator End area
%   11-Oct-2016, M. Woodley, G. White 12OCT16 deck changes. 
%      NOTE: This change changed the signature of the function; it removes
%            the beamline52 return argument. Breaks unmodified callers. 
%            (Mark's plus IMBSY34).
%   11-Aug-2016, M. Woodley (OPTICS=LCLS11AUG16)
%    * removed 52LINE

% --------------------------------------------------------------------

% Set default options.
global modelUseHXRSS
if isempty(modelUseHXRSS), modelUseHXRSS=1;end

global modelUseSXRSS
if isempty(modelUseSXRSS), modelUseSXRSS=1;end

% NOTE: the "UseNewBSY" option was invalidated by the BSY Reconfiguration,
%       but we'll suppress the warning, since "UseNewBSY" is the default
%       for existing code ... 
global modelUseNewBSY
if isempty(modelUseNewBSY)
  modelUseNewBSY=0;
else
  if modelUseNewBSY~=0
   %warning('"modelUseNewBSY" is no longer valid (model_beamLineUnd)')
  end
end

% NOTE: the positions of some devices in the "Undulator End" area were changed
%       in October 2016 ... use of the "UseOldUE" option may result in
%       device location inconsistencies ... for this we'll issue a warning
global modelUseOldUE
if isempty(modelUseOldUE)
  modelUseOldUE=0;
else
  if modelUseOldUE~=0
    warning('"modelUseOldUE" is no longer valid (model_beamLineUnd)')
  end
end

if nargin < 1, region='BSY_DMP';end

if strcmp(region,'52-Line')
  error('52-Line model not available!')
end

% Global definitions
Ef     = 13.640;   % final beam energy (GeV)
mc2    = 510.99906E-6;  % e- rest mass [GeV]
clight = 2.99792458e8;  % speed of light [m/s]
Cb      =1.0E10/clight; %energy to magnetic rigidity
in2m    = 0.0254;       %inches to meters

% Undulator definitions
gamf   =  Ef/mc2;                                  % Lorentz energy factor in undulator [ ]
Kund   =   3.500;                                  % Undulator parameter (rms) [ ]
lamu   =   0.030;                                  % Undulator period [m]
GQF    =  38.461538;                               % Undulator F-quad gradient [T/m] (3 T integrated gradient)
GQD    = -38.461538;                               % Undulator D-quad gradient [T/m] (3 T integrated gradient)
LQu    =   0.078;                                  % Undulator quadrupole effective length [m]
Lseg   =   3.400;                                  % Undulator segment length [m]
Lue    =   0.035;                                  % Undulator termination length (approx) [m]
Lund   =   Lseg - 2*Lue;                           % Undulator segment length without terminations [m]
Lundh  =   Lund/2;
shrt   =   0.470;                                  % Standard short break length [m]
long   =   0.898;                                  % Standard long break length [m]
LRFBu  =   0;                                      % undulator RF-BPM only implemented as zero length monitor
Lbr1   =   6.889E-2;                               % und-seg to quad [m]
Lbr3   =   9.111E-2;                               % quad to BPM [m]
Lbr4   =   5.8577E-2;                              % Radiation monitor to segment [m]
Lbrwm  =   7.1683E-2;                              % BFW to radiation monitor [m]
Lbrs   =   shrt-LRFBu-LQu-Lbr1-Lbr3-Lbr4-Lbrwm;    % Standard short break length (BPM-to-quad distance) [m]
Lbrl   =   long-LRFBu-LQu-Lbr1-Lbr3-Lbr4-Lbrwm;    % Standard long break length (BPM-to-quad distance) [m]
LBUVV2 =   0.2;                                    % drift length after inline vaccum valve
LBUVV1 =   Lbrl - LBUVV2;                          % drift length before inline vaccum valve
Lbr5   =   0.244659 - LRFBu;                       % drift lengh from RFBU33 to new RFBU34

kqund  = (Kund*2*pi/lamu/sqrt(2)/gamf)^2;          % natural undulator focusing "k" in y-plane [m^-2]
kQF    = 1E-9*GQF*clight/Ef;                       % QF undulator quadrupole focusing "k" [m^-2]
kQD    = 1E-9*GQD*clight/Ef;                       % QD undulator quadrupole focusing "k" [m^-2]
kQU33  = -0.304403258403;                          % XTCAV optics
kQ=[kQF kQD];

UNDSTART={'mo' 'UNDSTART'        0           []}';
UNDTERM ={'mo' 'UNDTERM'         0           []}';

dLbfw=3.6016-3.63815; % BFW location adjustment per H. Loos

DF0     ={'dr' ''                LQu-0.04241 []}';
DB0     ={'dr' ''                0.5653-Lbr1-LQu-Lbr3-LRFBu-Lbr5 []}';
DB1     ={'dr' ''                Lbr1        []}';
DB3     ={'dr' ''                Lbr3        []}';
DB4     ={'dr' ''                Lbr4        []}';
DB5     ={'dr' ''                Lbr5        []}';
DBWM    ={'dr' ''                Lbrwm+dLbfw []}';
DBRS    ={'dr' ''                Lbrs-dLbfw  []}';
DBRL    ={'dr' ''                Lbrl-dLbfw  []}';
DT      ={'dr' ''                Lue         []}';
MUQ     ={'mo' 'MUQ'             0           []}';
DBUVV1  ={'dr' ''                LBUVV1      []}';
DBUVV2  ={'dr' ''                LBUVV2-dLbfw []}';
VVU10   ={'mo' 'VVU10'           0           []}';
VVU25   ={'mo' 'VVU25'           0           []}';
RFBU00  ={'mo' 'RFBU00'          0           []}';
RFBU34  ={'mo' 'RFBU34'          0           []}'; % Korean RFBPM

% HXRSS self-seeding undulator (diamond crystal)
% ==============================================

Brho4 =  Cb*Ef            ;%beam rigidity at chicane (kG-m)
GB4 =  0.008              ;%1.25D14-C gap height (m)
LB4 =  0.3556+GB4         ;%1.25D14-C "Z" length (m) ... rule-of-thumb est.
BB4 =  3.373513346927     ;%chicane bend field for 12-um R56 (kG)
RB4 =  Brho4/BB4          ;%chicane bend radius (m)
AB4 =  asin(LB4/RB4)      ;%chicane bend angle (rad)
AB4S =  asin((LB4/2)/RB4) ;%"short" half chicane bend angle (rad)
LB4S =  RB4*AB4S          ;%"short" half chicane bend path length (m)
AB4L =  AB4-AB4S          ;%"long" half chicane bend angle (rad)
LB4L =  RB4*AB4L          ;%"long" half chicane bend path length (m)

BXHS1A={'be' 'BXHS1' LB4S [+AB4S GB4/2 0 0 0.5 0 0]}';
BXHS1B={'be' 'BXHS1' LB4L [+AB4L GB4/2 0 +AB4 0 0.5 0]}';
BXHS2A={'be' 'BXHS2' LB4L [-AB4L GB4/2 -AB4 0 0.5 0 0]}';
BXHS2B={'be' 'BXHS2' LB4S [-AB4S GB4/2 0 0 0 0.5 0]}';
BXHS3A={'be' 'BXHS3' LB4S [-AB4S GB4/2 0 0 0.5 0 0]}';
BXHS3B={'be' 'BXHS3' LB4L [-AB4L GB4/2 0 -AB4 0 0.5 0]}';
BXHS4A={'be' 'BXHS4' LB4L [+AB4L GB4/2 +AB4 0 0.5 0 0]}';
BXHS4B={'be' 'BXHS4' LB4S [+AB4S GB4/2 0 0 0 0.5 0]}';

D1={'dr' '' 0.5828/cos(AB4) []}';%0.582802
DCH={'dr' '' 0.58/2 []}';
DMONO={'dr' '' 0.1 []}';
DIAMOND={'mo' 'DIAMOND' 0 []}';
YAGBRAG={'mo' 'YAGBRAG' 0 []}';
M1={'mo' 'M1' 0 []}';
M2={'mo' 'M2' 0 []}';
CHICANE=[DMONO,M1,BXHS1A,BXHS1B,D1,BXHS2A,BXHS2B,DCH,DIAMOND,YAGBRAG,DCH,BXHS3A,BXHS3B,D1,BXHS4A,BXHS4B,M2,DMONO];

% SXRSS self-seeding chicane
% ==========================

% NOTEs:
% - nominal operating energy for this chicane is 4.744 GeV
% - chicane is OFF for 13.64 GeV operation
% - use series approximation for sinc(x)=sin(x)/x to allow BB5=0

Brho5    = Cb*Ef;                             %beam rigidity at chicane (kG-m)
GB5      = 0.315*in2m;                        %full gap height [m]
ZB5      = 14.315*in2m;                       %on-axis effective length is 14" + gap (rule-of-thumb)
%BB5      = 5.921701953748 %(4.744 GeV);       %chicane bend field for 397-um R56 (kG) [1000 eV]
BB5      = 1e-12;                              %chicane is OFF for 13.64 GeV
ARG5     = ZB5*BB5/Brho5;
AB5      = asin(ARG5);                        %chicane bend angle (rad)
AB5_2    = AB5*AB5;
AB5_4    = AB5_2*AB5_2;
AB5_6    = AB5_4*AB5_2;
SINCAB5  = 1-AB5_2/6+AB5_4/120-AB5_6/5040;    %~sinc(AB5)=sin(AB5)/AB5
LB5      = ZB5/SINCAB5;                       %chicane bend path length (m)
AB5S     = asin(ARG5/2);                      %"short" half chicane bend angle (rad)
AB5S_2   = AB5S*AB5S;
AB5S_4   = AB5S_2*AB5S_2;
AB5S_6   = AB5S_4*AB5S_2;
SINCAB5S = 1-AB5S_2/6+AB5S_4/120-AB5S_6/5040; %~sinc(AB5s)=sin(AB5s)/AB5s
LB5S     = ZB5/(2*SINCAB5S);                  %"short" half chicane bend path length (m)
AB5L     = AB5-AB5S;                          %"long" half chicane bend angle (rad)
LB5L     = LB5-LB5S;                          %"long" half chicane bend path length (m)

BXSS1A={'be' 'BXSS1' LB5S [+AB5S GB5/2 0 0 0.5 0 0]}';
BXSS1B={'be' 'BXSS1' LB5L [+AB5L GB5/2 0 +AB5 0 0.5 0]}';
BXSS2A={'be' 'BXSS2' LB5L [-AB5L GB5/2 -AB5 0 0.5 0 0]}';
BXSS2B={'be' 'BXSS2' LB5S [-AB5S GB5/2 0 0 0 0.5 0]}';
BXSS3A={'be' 'BXSS3' LB5S [-AB5S GB5/2 0 0 0.5 0 0]}';
BXSS3B={'be' 'BXSS3' LB5L [-AB5L GB5/2 0 -AB5 0 0.5 0]}';
BXSS4A={'be' 'BXSS4' LB5L [+AB5L GB5/2 +AB5 0 0.5 0 0]}';
BXSS4B={'be' 'BXSS4' LB5S [+AB5S GB5/2 0 0 0 0.5 0]}';

ZD1S  = 0.8303985;
ZD1Sa = 0.44;
ZD1Sb = 0.049;
ZD1Sc = ZD1S-(ZD1Sa+ZD1Sb);
ZD1Sd = 0.077;
ZD1Se = 0.185;
ZD1Sf = 0.128;
ZD1Sg = ZD1S-(ZD1Sd+ZD1Se+ZD1Sf);

DMONOS={'dr' '' 0.0641995 []}'; %sets RFBU08-to-RFBU09 distance to 3.87 m exactly
D1S={'dr' '' ZD1S/cos(AB5) []}';
D1Sa={'dr' '' ZD1Sa/cos(AB5) []}';
D1Sb={'dr' '' ZD1Sb/cos(AB5) []}';
D1Sc={'dr' '' ZD1Sc/cos(AB5) []}';
D1Sd={'dr' '' ZD1Sd/cos(AB5) []}';
D1Se={'dr' '' ZD1Se/cos(AB5) []}';
D1Sf={'dr' '' ZD1Sf/cos(AB5) []}';
D1Sg={'dr' '' ZD1Sg/cos(AB5) []}';
DCHS={'dr' '' 0.1564/2 []}';

GSXS1={'mo' 'GSXS1' 0 []}';
MSXS1={'mo' 'MSXS1' 0 []}';
CNTRS={'mo' 'CNTRS' 0 []}';
SLSXS1={'mo' 'SLSXS1' 0 []}';
MSXS2={'mo' 'MSXS2' 0 []}';
MSXS3={'mo' 'MSXS3' 0 []}';

SCHICANE=[ ...
          DMONOS, ...
          BXSS1A,BXSS1B,D1Sa,GSXS1,D1Sb,MSXS1,D1Sc, ...
          BXSS2A,BXSS2B,DCHS,CNTRS,DCHS, ...
          BXSS3A,BXSS3B,D1Sd,SLSXS1,D1Se,MSXS2,D1Sf,MSXS3,D1Sg, ...
          BXSS4A,BXSS4B, ...
          DMONOS];

% DELTA undulator (focusing is negligible)
% ========================================

K_delta=2.53;                                     % undulator parameter
lam_delta=0.032;                                  % period length [m]
L_delta=3.184/2;                                  % half-length [m]
kq_delta=(2*pi*K_delta/lam_delta/sqrt(2)/gamf)^2; % focusing "k" [m^-2]

US33={'dr' 'US33' L_delta [kq_delta lam_delta]}';
DUS33b={'dr' '' 1.682-US33{3} []}';
DUS33c={'dr' '' 0.012891527481 []}';
DUS33a={'dr' '' Lseg-DUS33b{3}-2*US33{3}-DUS33c{3} []}';
PS33={'mo' 'PS33' 0 []}';

DELTA=[DUS33a,PS33,DUS33b,US33,US33,DUS33c];

% Overlap diagnostics
BOD10  ={'mo' 'BOD10' 0 []}';
YAGBOD1={'mo' 'YAGBOD1' 0 []}';
BOD13  ={'mo' 'BOD13' 0 []}';
YAGBOD2={'mo' 'YAGBOD2' 0 []}';
DBUVV1a={'dr' ''                LBUVV1-(0.22075-LBUVV2)      []}';
DBUVV1b={'dr' ''                0.22075-LBUVV2      []}';

% "delta" undulator (modeled as R-matrix with no focusing)

nGird=33;
GIRDs=cell(1,1,nGird);
for j=1:nGird
    QUj={
        'qu' num2str(j,'QU%02d')   LQu/2    kQ(mod(j,2)+1)}';
    XCUj={
        'mo' num2str(j,'XCU%02d')  0        []}';
    YCUj={
        'mo' num2str(j,'YCU%02d')  0        []}';
    RFBUj={
        'mo' num2str(j,'RFBU%02d') 0        []}';
    BFWj={
        'mo' num2str(j,'BFW%02d')  0        []}';
    USj={
        'un' num2str(j,'US%02d')   Lundh    [kqund lamu]}';
    USTBKj=[DT,USj,USj,DT];
    if modelUseHXRSS && j == 16, USTBKj=CHICANE;end
    if modelUseSXRSS && j ==  9, USTBKj=SCHICANE;end
    if                  j == 33, USTBKj=DELTA;end
    if ~modelUseOldUE && j == 33, QUj{4}=kQU33;end
    QBLKsj=[QUj,XCUj,MUQ,YCUj,QUj];
    GIRDs{j}=[BFWj,DBWM,DB4,USTBKj,DB1,QBLKsj,DB3,RFBUj];
end

%DBRL10=[DBUVV1,VVU10,DBUVV2];
DBRL10=[DBUVV1a,BOD10,YAGBOD1,DBUVV1b,VVU10,DBUVV2];
DBRL13=[DBUVV1a,BOD13,YAGBOD2,DBUVV1b,DBUVV2];
DBRL25=[DBUVV1,VVU25,DBUVV2];

UNDCL=[DBRS,  GIRDs{:,:,01},DBRS,GIRDs{:,:,02},DBRS,GIRDs{:,:,03}, ...
       DBRL,  GIRDs{:,:,04},DBRS,GIRDs{:,:,05},DBRS,GIRDs{:,:,06}, ...
       DBRL,  GIRDs{:,:,07},DBRS,GIRDs{:,:,08},DBRS,GIRDs{:,:,09}, ...
       DBRL10,GIRDs{:,:,10},DBRS,GIRDs{:,:,11},DBRS,GIRDs{:,:,12}, ...
       DBRL13,GIRDs{:,:,13},DBRS,GIRDs{:,:,14},DBRS,GIRDs{:,:,15}, ...
       DBRL,  GIRDs{:,:,16},DBRS,GIRDs{:,:,17},DBRS,GIRDs{:,:,18}, ...
       DBRL,  GIRDs{:,:,19},DBRS,GIRDs{:,:,20},DBRS,GIRDs{:,:,21}, ...
       DBRL,  GIRDs{:,:,22},DBRS,GIRDs{:,:,23},DBRS,GIRDs{:,:,24}, ...
       DBRL25,GIRDs{:,:,25},DBRS,GIRDs{:,:,26},DBRS,GIRDs{:,:,27}, ...
       DBRL,  GIRDs{:,:,28},DBRS,GIRDs{:,:,29},DBRS,GIRDs{:,:,30}, ...
       DBRL,  GIRDs{:,:,31},DBRS,GIRDs{:,:,32},DBRS,GIRDs{:,:,33}];

UND=[UNDSTART,DF0,DB3,RFBU00,UNDCL,DB5,RFBU34,DB0,UNDTERM];

% ------------------------------------------------------------------------------
% Beam Switch Yard
% ------------------------------------------------------------------------------

% QUADs

LQx=0.1080;  %Everson-Tesla (ET) quads "1.259Q3.5" effective length (m)
LQF=0.46092; %FFTB (0.91Q17.72) effective length (m)

% post BSY Reconfiguration optics

KQ50Q1=-0.229926560036; %-1.902546E-01
KQ50Q2=0.103081575692;  % 1.902546E-01
KQ50Q3=0.391321449198;  %-1.902546E-01
KQ4=-0.220136895709;    % 0.0 (was QSM1)
KQ5=0.166801168812;     %-1.770000E-01
KQ6=-0.111438374663;    % 2.281423E-01
KQA0=0.120427035985;    %-3.272445E-02

if modelUseNewBSY
  % post BSY Reconfiguration ... no "NewBSY" optics
end

Q50Q1={'qu' 'Q50Q1' 0.1315 KQ50Q1}';
Q50Q2={'qu' 'Q50Q2' 0.162151 KQ50Q2}';
Q50Q3={'qu' 'Q50Q3' 0.143254 KQ50Q3}';
Q4=   {'qu' 'Q4'    LQF/2    KQ4}';
Q5=   {'qu' 'Q5'    LQF/2    KQ5}';
Q6=   {'qu' 'Q6'    LQF/2    KQ6}';
QA0=  {'qu' 'QA0'   LQF/2    KQA0}';

% XCORs

XCBSYQ2={'mo' 'XCBSYQ2' 0 []}';
XCBSYQ3={'mo' 'XCBSYQ3' 0 []}';
XCAPM2= {'mo' 'XCAPM2'  0 []}';
XCBSYQ5={'mo' 'XCBSYQ5' 0 []}';
XCA0=   {'mo' 'XCA0'    0 []}';

% YCORs

YCBSYQ1={'mo' 'YCBSYQ1' 0 []}';
YCBSYQ4={'mo' 'YCBSYQ4' 0 []}';
YCAPM2= {'mo' 'YCAPM2'  0 []}';
YCBSYQ6={'mo' 'YCBSYQ6' 0 []}';
YCA0=   {'mo' 'YCA0'    0 []}';

% BPMs

BPMBSYQ1= {'mo' 'BPMBSYQ1'  0 []}';
BPMBSYQ2= {'mo' 'BPMBSYQ2'  0 []}';
BPMBSYQ3= {'mo' 'BPMBSYQ3'  0 []}';
BPMBSYQ4= {'mo' 'BPMBSYQ4'  0 []}';
BPMBSYQ5= {'mo' 'BPMBSYQ5'  0 []}';
BPMBSYQ6= {'mo' 'BPMBSYQ6'  0 []}';
BPMBSYQA0={'mo' 'BPMBSYQA0' 0 []}';

% TORO

IMBSY1=  {'mo' 'IMBSY1'   0 []}';
IMBSY2=  {'mo' 'IMBSY2'   0 []}';
IMBSY3=  {'mo' 'IMBSY3'   0 []}';
IMBSY34= {'mo' 'IMBSY34'  0 []}';
IMBSY1b= {'mo' 'IMBSY1b'  0 []}';
IMBSY2b= {'mo' 'IMBSY2b'  0 []}';
IMBSY3b= {'mo' 'IMBSY3b'  0 []}';

% DRIFTs: magnet-to-magnet

DBSY0={'dr' '' 8.007776  []}';
DBSY1={'dr' '' 5.9781    []}';
DBSY2={'dr' '' 54.883314 []}';
DBSY3={'dr' '' 4.0       []}';
DBSY4={'dr' '' 34.45562  []}';
DBSY5={'dr' '' 19.260056 []}';
DBSY6={'dr' '' 35.364431 []}';
DBSY7={'dr' '' 0.586638  []}';

% DRIFTs: device-to-device

DBSY0a={'dr' '' 0.7286          []}';
DBSY0b={'dr' '' 0.25005         []}';
DBSY0c={'dr' '' 0.25005         []}';
DBSY0d={'dr' '' 0.4143          []}';
DBSY0e={'dr' '' 2.9046          []}';
DBSY0f={'dr' '' 0.31575         []}';
DBSY0g={'dr' '' 0.31575         []}';
DBSY0h={'dr' '' 0.8159          []}';
DBSY0i={'dr' '' 0.5782          []}';
DBSY0j={'dr' '' 1.434576        []}';
DBSY1a={'dr' '' 0.236224        []}';
DBSY1b={'dr' '' 0.2199          []}';
DBSY1c={'dr' '' 5.021976        []}';
DBSY1d={'dr' '' 0.5             []}';
DBSY2a={'dr' '' 0.079149        []}';
DBSY2b={'dr' '' 2.420851        []}';
DBSY2c={'dr' '' 51.883314       []}';
DBSY2d={'dr' '' 0.5             []}';
DBSY3a={'dr' '' 0.091696        []}';
DBSY3b={'dr' '' 1.39065         []}';
DBSY3c={'dr' '' 2.017654        []}';
DBSY3d={'dr' '' 0.5             []}';
DBSY4a={'dr' '' 1.2             []}';
DBSY4b={'dr' '' 23.390478435971 []}';
DBSY5a={'dr' '' 0.5             []}';
DBSY5b={'dr' '' 18.760056       []}';
DBSY6a={'dr' '' 0.7             []}';
DBSY6b={'dr' '' 4.226742        []}';
DBSY6c={'dr' '' 14.546356       []}';
DBSY6d={'dr' '' 1.051778        []}';
DBSY6e={'dr' '' 0.2196          []}';
DBSY6f={'dr' '' 0.2114          []}';
DBSY6g={'dr' '' 8.692867        []}';
DBSY6h={'dr' '' 0.31            []}';
DBSY6i={'dr' '' 0.279421        []}';
DBSY6j={'dr' '' 0.561379        []}';
WALL  ={'dr' '' 16.764          []}';

% DRIFTs: pulsed magnet group

DBKXAPM1a={'dr' '' 0.527499495473 []}';
DBKXAPM1b={'dr' '' 0.527499495473 []}';
DZAPM1   ={'dr' '' 0.206348861636 []}';
DBKXAPM2a={'dr' '' 0.527495459267 []}';
DBKXAPM2b={'dr' '' 0.527495459267 []}';
DZAPM2a  ={'dr' '' 0.103172723276 []}';
DZAPM2b  ={'dr' '' 0.103172723276 []}';
DBKXAPM3a={'dr' '' 0.527487386885 []}';
DBKXAPM3b={'dr' '' 0.527487386885 []}';
DZAPM3   ={'dr' '' 0.206339754773 []}';
DBKXAPM4a={'dr' '' 0.527475278388 []}';
DBKXAPM4b={'dr' '' 0.527475278388 []}';
DZAPM4   ={'dr' '' 0.206331786344 []}';
DZA01    ={'dr' '' 0.197164430415 []}';
DPCBSY2  ={'dr' '' 0.3            []}';
DBTMBSY2 ={'dr' '' 0.0            []}';
DZA02    ={'dr' '' 2.524061981323 []}';

DZAPM2={'dr' '' DZAPM2a{3}+DZAPM2b{3} []}';

% collimators

PCAPM1={'mo' 'PCAPM1' 0.1824   []}';
PCAPM2={'mo' 'PCAPM2' 0.1824   []}';
PCAPM3={'mo' 'PCAPM3' 0.1824   []}';
PCAPM4={'mo' 'PCAPM4' 0.1824   []}';
PC90=  {'mo' 'PC90'   0.453644 []}';
PC119= {'mo' 'PC119'  0.453644 []}';

% dumps, stoppers, muon wall

PCBSYH={'dr' 'PCBSYH' 0.45   []}';
D2=    {'dr' 'D2'     1.2192 []}';
ST60=  {'dr' 'ST60'   1.2192 []}';
ST61=  {'dr' 'ST61'   1.2192 []}';

% MARKers

BEGCLTH0={'mo' 'BEGCLTH0' 0 []}';
BEGBSY=  {'mo' 'BEGBSY'   0 []}';
S100=    {'mo' 'S100'     0 []}'; %station 100
ZLIN15=  {'mo' 'ZLIN15'   0 []}';
WOODDOOR={'mo' 'WOODDOOR' 0 []}'; %start of BSY proper
ENDCLTH0={'mo' 'ENDCLTH0' 0 []}';
BEGCLTH1={'mo' 'BEGCLTH1' 0 []}';
ENDCLTH1={'mo' 'ENDCLTH1' 0 []}';
BEGCLTH2={'mo' 'BEGCLTH2' 0 []}';
ENDCLTH2={'mo' 'ENDCLTH2' 0 []}';
BEGBSYH1={'mo' 'BEGBSYH1' 0 []}';
MRGALINE={'mo' 'MRGALINE' 0 []}';
ENDBSYH1={'mo' 'ENDBSYH1' 0 []}';
BEGBSYH2={'mo' 'BEGBSYH2' 0 []}';
DM60=    {'mo' 'DM60'     0 []}';
MUWALL=  {'mo' 'MUWALL'   0 []}';
ENDBSY=  {'mo' 'ENDBSY'   0 []}';
ENDBSYH2={'mo' 'ENDBSYH2' 0 []}';

BSY=[BEGCLTH0,BEGBSY,DBSY0a,IMBSY1,DBSY0b,IMBSY2,DBSY0c,IMBSY3,DBSY0d, ...
    IMBSY34,DBSY0e,IMBSY1b,DBSY0f,IMBSY2b,DBSY0g,IMBSY3b,DBSY0h,S100, ...
    ZLIN15,DBSY0i,YCBSYQ1,DBSY0j, ...
  Q50Q1,Q50Q1,DBSY1a,WOODDOOR,ENDCLTH0,BEGCLTH1,DBSY1b,BPMBSYQ1,DBSY1c, ...
    XCBSYQ2,DBSY1d, ...
  Q50Q2,Q50Q2,DBSY2a,BPMBSYQ2,DBSY2b,ENDCLTH1,BEGCLTH2,DBSY2c,ENDCLTH2, ...
    BEGBSYH1,DBSY2d, ...
  Q50Q3,Q50Q3,DBSY3a,BPMBSYQ3,DBSY3b,XCBSYQ3,DBSY3c,YCBSYQ4,DBSY3d, ...
  Q4,BPMBSYQ4,Q4,DBSY4a,MRGALINE,ENDBSYH1,BEGBSYH2, ...
  DBKXAPM1a,DBKXAPM1b,DZAPM1,PCAPM1,DZAPM1, ...
  DBKXAPM2a,DBKXAPM2b,DZAPM2a,XCAPM2,YCAPM2,DZAPM2b,PCAPM2,DZAPM2, ...
  DBKXAPM3a,DBKXAPM3b,DZAPM3,PCAPM3,DZAPM3, ...
  DBKXAPM4a,DBKXAPM4b,DZAPM4,PCAPM4,DZA01,DPCBSY2,DBTMBSY2,DZA02,PCBSYH, ...
    DBSY4b, ...
  Q5,BPMBSYQ5,Q5,DBSY5a,XCBSYQ5,DBSY5b, ...
  Q6,BPMBSYQ6,Q6,DBSY6a,YCBSYQ6,DBSY6b,PC90,DBSY6c,PC119,DBSY6d,D2,DBSY6e, ...
    ST60,DBSY6f,DM60,DBSY6g,XCA0,DBSY6h,YCA0,DBSY6i,ST61,DBSY6j, ...
  QA0,BPMBSYQA0,QA0,DBSY7,MUWALL,WALL,ENDBSY,ENDBSYH2];

% ------------------------------------------------------------------------------
% LTU (Linac To Undulator)
% ------------------------------------------------------------------------------

% Parameters below are used to set LTU Y-bends so that beam is level w.r.t. gravity at center of FEL-undulator, including 30-m extension
S100_PITCH  = -4.760000E-3;                           % pitch-down angle of linac at station-100 [rad] (0.27272791 deg)
S100_HEIGHT = 77.643680;                              % station-100 height above local sea level, from Catherine LeCocq, Jan. 22, 2004 [m]
Z_S100_UNDH = 583.000000;                             % undulator center is defined as 583 m from sta-100 meas. along und. Z-axis (~1/2 und+xtns)
R_Earth     = 6.372508025E6;                          % total radius of Earth (gaussain sphere) from Catherine LeCocq, Jan. 2004 [m]

LB3 = 2.623;      %4D102.36T effective length (m)
GB3 = 0.023;      %4D102.36T gap height (m)
LVB = 1.025;      %3D39 vertical bend effective length (m)
GVB = 0.034925;   %vertical bend gap width (m)

AVB = (S100_PITCH + asin(Z_S100_UNDH/(R_Earth+S100_HEIGHT)))/2; %bend up twice this angle so e- is level in cnt. of und., incl. 30-m ext.

BY1A={'be' 'BY1'  LVB/2 [AVB/2 GVB/2 AVB/2     0 0.5 0.0 pi/2]}';
BY1B={'be' 'BY1'  LVB/2 [AVB/2 GVB/2     0 AVB/2 0.0 0.5 pi/2]}';
BY2A={'be' 'BY2'  LVB/2 [AVB/2 GVB/2 AVB/2     0 0.5 0.0 pi/2]}';
BY2B={'be' 'BY2'  LVB/2 [AVB/2 GVB/2     0 AVB/2 0.0 0.5 pi/2]}';

AB3P   = 0.5*pi/180*(+1);
AB3M   = 0.5*pi/180*(-1);
LeffB3 = LB3*AB3P/(2*sin(AB3P/2)); %full bend eff. path length (m)

BX31A={'be' 'BX31'  LeffB3/2 [AB3P/2 GB3/2 AB3P/2      0 0.5 0.0 0]}';
BX31B={'be' 'BX31'  LeffB3/2 [AB3P/2 GB3/2      0 AB3P/2 0.0 0.5 0]}';
BX32A={'be' 'BX32'  LeffB3/2 [AB3P/2 GB3/2 AB3P/2      0 0.5 0.0 0]}';
BX32B={'be' 'BX32'  LeffB3/2 [AB3P/2 GB3/2      0 AB3P/2 0.0 0.5 0]}';

DX33A={'dr' ''  LB3/2                     []}';     %optional bend for branch point
DX33B={'dr' ''  LB3/2                     []}';
DX34A={'dr' ''  LB3/2                     []}';
DX34B={'dr' ''  LB3/2                     []}';

BX35A={'be' 'BX35'  LeffB3/2 [AB3M/2 GB3/2 AB3M/2      0 0.5 0.0 0]}';
BX35B={'be' 'BX35'  LeffB3/2 [AB3M/2 GB3/2      0 AB3M/2 0.0 0.5 0]}';
BX36A={'be' 'BX36'  LeffB3/2 [AB3M/2 GB3/2 AB3M/2      0 0.5 0.0 0]}';
BX36B={'be' 'BX36'  LeffB3/2 [AB3M/2 GB3/2      0 AB3M/2 0.0 0.5 0]}';

%DX37A={'dr' ''  LB3/2                     []}';     %optional bend for branch point
%DX37B={'dr' ''  LB3/2                     []}';
%DX38A={'dr' ''  LB3/2                     []}';
%DX38B={'dr' ''  LB3/2                     []}';

% dechirper installation

D37a    ={'dr' '' 2.923    []}';
D37b    ={'dr' '' 9.02398  []}';
D37c    ={'dr' '' 1.0975   []}';
DCHIRPV ={'dr' 'DCHIRPV' 2.0/2    []}'; % split in half
MDCHIRPV={'mo' 'MDCHIRPV' 0        []}'; % center of dechirper
D37d    ={'dr' '' 0.5117   []}';
D38a    ={'dr' '' 0.5124   []}';
DCHIRPH ={'dr' 'DCHIRPH' 2.0/2    []}'; % split in half
MDCHIRPH={'mo' 'MDCHIRPH' 0        []}'; % center of dechirper
D38b    ={'dr' '' 0.6091   []}';
D38c    ={'dr' '' 0.5407   []}';
D38d    ={'dr' '' 11.89398 []}';

% Single beam dumper vertical kicker:
% ----------------------------------
LKIK    = 1.0601;              % kicker coil length per magnet (m) [41.737 in from SA-380-330-02, rev. 0]

BYKIK1A={'be' 'BYKIK1'  LKIK/2 [1E-12/2 25.4E-3 0 0 0.5 0.0 pi/2]}';
BYKIK1B={'be' 'BYKIK1'  LKIK/2 [1E-12/2 25.4E-3 0 0 0.0 0.5 pi/2]}';
BYKIK2A={'be' 'BYKIK2'  LKIK/2 [1E-12/2 25.4E-3 0 0 0.5 0.0 pi/2]}';
BYKIK2B={'be' 'BYKIK2'  LKIK/2 [1E-12/2 25.4E-3 0 0 0.0 0.5 pi/2]}';

TDKIK={'dr' 'TDKIK'  0.6096                    []}'; %SBD vertical off-axis kicker dump
SPOILER={'mo' 'SPOILER'  0                     []}'; %SBD dump spoiler

% X-ray stripe 'wiggler' vertical 3-dipole chicane (from SLC BSY)

LBxw  = 0.233681;            %"Z" length (m)
%GBxw  = 1.05*in2m;           %gap height - SLC wiggler gap not known yet - used 1.05 inches for now - 7/6/05 -PE (m)
Brhox = Cb*Ef;               %beam rigidity in LTU (kG-m)
BBxw  = -6.0;                %X-ray chicane bend field (kG) - (eta matching in DL2 not fixed yet: small error - PE)
RBxw  = Brhox/BBxw;          %X-ray chicane bend radius (m)
ABxw  = asin(LBxw/RBxw);     %full X-ray chicane bend angle (rad)

DBYw1A={'dr' ''  LBxw/2                     []}';
DBYw1B={'dr' ''  LBxw/2                     []}';
DBYw2A={'dr' ''  LBxw                     []}';
DBYw2B={'dr' ''  LBxw                     []}';
DBYw3A={'dr' ''  LBxw/2                     []}';
DBYw3B={'dr' ''  LBxw/2                     []}';

LDw1o = 0.173736;
SDw1o = LDw1o/cos(ABxw);
Dw1o={'dr' ''  SDw1o                     []}';

LQA= 0.31600;        %Q150kG effective length [not known yet] (m)
dLQA2=(0.46092 - LQA)/2;        %used to adjust LQA adjacent drifts (m)

KQVM1 = -0.33737663383;
KQVM2 =  0.233178602736;
KQVM3 =  0.724411572898;
KQVM4 = -0.682622141896;
KQVB  = -0.42223036711;

if modelUseNewBSY
  % post BSY Reconfiguration ... no "NewBSY" optics
end

KQDL   = 0.44267670105;
KCQ31  = 0;
KCQ32  = 0;
KQT1   =-0.420937827343;
KQT2   = 0.839614778043;

QVM1={'qu' 'QVM1' LQF/2  KQVM1}';
QVM2={'qu' 'QVM2' LQF/2  KQVM2}';
QVB1={'qu' 'QVB1' LQF/2  KQVB}';
QVB2={'qu' 'QVB2' LQF/2 -KQVB}';
QVB3={'qu' 'QVB3' LQF/2  KQVB}';
QVM3={'qu' 'QVM3' LQF/2  KQVM3}';
QVM4={'qu' 'QVM4' LQF/2  KQVM4}';
QDL31={'qu' 'QDL31' LQA/2 KQDL}';
QDL32={'qu' 'QDL32' LQA/2 KQDL}';
QDL33={'qu' 'QDL33' LQA/2 KQDL}';
QDL34={'qu' 'QDL34' LQA/2 KQDL}';
CQ31={'qu' 'CQ31'  LQx/2 KCQ31}';
CQ32={'qu' 'CQ32'  LQx/2 KCQ32}';
%CQ31={'dr' 'CQ31'  LQx/2 []}';
%CQ32={'dr' 'CQ32'  LQx/2 []}';
QT11={'qu' 'QT11' LQF/2 KQT1}';
QT12={'qu' 'QT12' LQF/2 KQT2}';
QT13={'qu' 'QT13' LQF/2 KQT1}';
QT21={'qu' 'QT21' LQF/2 KQT1}';
QT22={'qu' 'QT22' LQF/2 KQT2}';
QT23={'qu' 'QT23' LQF/2 KQT1}';
QT31={'qu' 'QT31' LQF/2 KQT1}';
QT32={'qu' 'QT32' LQF/2 KQT2}';
QT33={'qu' 'QT33' LQF/2 KQT1}';
QT41={'qu' 'QT41' LQF/2 KQT1}';
QT42={'qu' 'QT42' LQF/2 KQT2}';
QT43={'qu' 'QT43' LQF/2 KQT1}';

%dz_adjust = 47.825;
%={'dr' ''  0                     []}';
%D10cm={'dr' ''  0.10                     []}';
%D10cma={'dr' ''  0.127                     []}';
%DC10cm={'dr' ''  0.10                     []}';
%D21cm={'dr' ''  0.21                     []}';
D25cm={'dr' ''  0.25                     []}';
D29cma={'dr' ''  0.29+0.023878+0.1000244+0.1704396     []}';
%D30cm={'dr' ''  0.30                     []}';
%D32cm={'dr' ''  0.32                     []}';
D32cmb={'dr' ''  0.32-0.056221+0.4000244                     []}';
D32cmd={'dr' ''  0.32-0.056221+0.4000244+0.2404381           []}';
%D40cm={'dr' ''  0.40                     []}';
D40cmC={'dr' ''  0.4                     []}';
D40cmd={'dr' ''  0.40+0.090013-0.000473  []}';
D40cme={'dr' ''  0.40+0.090013+0.010447  []}';
D40cmf={'dr' ''  0.40+0.090013-0.065013  []}';
%D50cm={'dr' ''  0.50                     []}';
%D34cm={'dr' ''  0.34                     []}';
D31A={'dr' ''  0.40+dLQA2+0.090005                     []}';
D31B={'dr' ''  0.40+dLQA2+0.4900025-0.4000244                     []}';
D32A={'dr' ''  0.40+dLQA2                     []}';
D32B={'dr' ''  0.40+dLQA2                     []}';
D33A={'dr' ''  0.21+dLQA2+0.380004-0.1000244-0.1704396       []}';
D33B={'dr' ''  0.40+dLQA2+0.4900025-0.4000244-0.2404381      []}';
%D34A={'dr' ''  0.40+dLQA2+0.09-0.00046               []}';
%D34B={'dr' ''  0.25+dLQA2+0.2399776-0.2404376        []}';
%  DEM1A  : DRIF, L=0.40+dLQA2
%  DEM1B  : DRIF, L=4.00+dLQA2*2
%  DEM2B  : DRIF, L=0.40+dLQA2
%  DEM3A  : DRIF, L=0.40+dLQA2
%  DEM3B  : DRIF, L=0.30+dLQA2+0.402839
%  DEM4A  : DRIF, L=0.40+dLQA2-0.402839+(0.402839)
%  D32cmc : DRIF, L=0.32-0.0254
%  DUM1A  : DRIF, L=0.40+dLQA2+0.0254
%  DUM1B  : DRIF, L=0.40+dLQA2
%  D32cma : DRIF, L=0.32+0.0253999
%  DUM2A  : DRIF, L=0.40+dLQA2-0.0253999
%  DUM2B  : DRIF, L=0.40+dLQA2
%  DUM3A  : DRIF, L=0.40+dLQA2+0.125
%  DUM3B  : DRIF, L=0.40+dLQA2
%  DUM4A  : DRIF, L=0.40+dLQA2+0.0254
%  DUM4B  : DRIF, L=0.40+dLQA2+0.127
DYCVM1={'dr' ''  0.40                     []}';
DQVM1={'dr' ''  0.34                     []}';
DVB25cm={'dr' ''  0.5-0.254173               []}';
DVB25cmc={'dr' ''  0.5-0.25                     []}';
DQVM2={'dr' ''  0.5                     []}';
DQVM2b={'dr' ''  0.48-LQF/2                     []}';
DQVM2a={'dr' ''  DQVM2{3}-DQVM2b{3}                     []}';
DXCVM2={'dr' ''  0.254173                     []}';
DWSVM2={'dr' ''  DXCVM2{3}+DVB25cm{3}  []}';
DWSVM2a={'dr' ''  0.48-LQF/2            []}';
DWSVM2b={'dr' ''  DWSVM2{3}-DWSVM2a{3}  []}';
DVB1={'dr' ''  8.0-2*0.3125                     []}';
DVB1m40cm={'dr' ''  8.0-0.4-2*0.3125                     []}';
DVB2={'dr' ''  4.0                     []}';
DVB2m80cm={'dr' ''  4.0-0.4-0.4                     []}';
%DVBe={'dr' ''  0.5                     []}';
DVBem25cm={'dr' ''  0.5-0.25                     []}';
DVBem15cm={'dr' ''  0.150+0.00381+0.018803                     []}';
D10cmb={'dr' ''  0.1064869                     []}';
D25cma={'dr' ''  0.25-0.00381-0.018803-0.0064869                     []}';
%DDL10={'dr' ''  12.86072                     []}';
%DDL10m70cm={'dr' ''  12.86072-0.4-0.3-0.09+0.00046        []}';
%DDL10u={'dr' ''  0.5                     []}';
%DDL10um25cm={'dr' ''  0.5-0.25-0.2399776+0.2404376        []}';
%DDL10v={'dr' ''  12.86072-0.5                     []}';
%={'dr' ''                       []}';
DDL1a={'dr' ''  5.820626-LKIK/2                     []}';
DDL1c={'dr' ''  0.609226-LKIK/2                     []}';
DDL1b={'dr' ''  5.421642-LKIK/2                     []}';
DSPLR={'dr' ''  0.43036                     []}';
D30cma={'dr' ''  0.257426                     []}';
DPC1={'dr' ''  0.266697                     []}';
DPC2={'dr' ''  0.266697                     []}';
DPC3={'dr' ''  0.266697                     []}';
DPC4={'dr' ''  0.266697+0.339613-0.8128/2                     []}';
DDL1dm30cm={'dr' ''  0.379160-0.262228                     []}'; % allow possible new spontaneous undulator here
DDL1cm40cm={'dr' ''  6.03036-0.43036-0.6096/2       []}';
LSPONT = 1.5;                           % length of possible spontaneous undulator (<=5 m now that TDKIK is also there)
SPONTUA={'dr' 'SPONTU'  LSPONT/2                     []}';
SPONTUB={'dr' 'SPONTU'  LSPONT/2                     []}';
DDL20={'dr' ''  0.5                     []}';
%DDL30={'dr' ''  1.0                     []}';
%DDL30m40cm={'dr' ''  1.0-0.4                     []}';
DDL10w={'dr' ''  12.86072-2*LDw1o-3*(LBxw)-1.1                     []}';
DDL10x={'dr' ''  0.250000-0.033681-0.090005                     []}';
%DDL10e={'dr' ''  12.86072                     []}';
%DDL10em50cm={'dr' ''  12.86072-0.25-0.25-0.090002-0.313878                     []}';
DDL10em80cm={'dr' ''  12.86072-0.4-0.4-0.433783                     []}';
DCQ31a={'dr' ''  6.037182             []}';
DCQ31b={'dr' ''  5.811658             []}';
DCQ32a={'dr' ''  5.4817585             []}';
DCQ32b={'dr' ''  6.0371785             []}';
DDL20e={'dr' ''  0.5                     []}';
%DDL30e={'dr' ''  1.0                     []}';
DDL30em40cm={'dr' ''  1.0-0.4-0.090013                     []}';
DDL30em40cma={'dr' ''  1.0-0.4-0.090013+0.000473       []}';
DDL30em40cmb={'dr' ''  1.0-0.4-0.090013-0.010447       []}';
DDL30em40cmc={'dr' ''  1.0-0.4-0.090013+0.065013       []}';
D40cmb={'dr' ''  0.40+0.090013                     []}';
%D25cmb={'dr' ''  0.25+0.0127                     []}';
%D25cmc={'dr' ''  0.25-0.0127                     []}';
%D40cma={'dr' ''  0.4+1.407939                     []}';
DWSDL31a={'dr' ''  0.096237                     []}'; %0.096779-0.000542
DWSDL31b={'dr' ''  0.153763                     []}'; %0.153221+0.000542

WSVM2={'mo' 'WSVM2'  0                     []}';
OTR30={'mo' 'OTR30'  0                     []}'; %LTU slice energy spread (90 deg from TCAV3)
WSDL31={'mo' 'WSDL31'  0                     []}';
WSDL4={'mo' 'WSDL4'  0                     []}';

VBin={'mo' 'VBIN'  0                     []}'; % start of vert. bend system   : Z=3226.684266  (Z' = 178.682319 m, X'= 0.000000 m, Y'=-0.834188 m)
VBout={'mo' 'VBOUT'  0                     []}'; % end of vert. bend system     : Z=3252.866954  (Z' = 204.865007 m, X'= 0.000000 m, Y'=-0.895305 m)
SS1={'mo' 'SS1'  0                     []}';
SS3={'mo' 'SS3'  0                     []}';
MM1={'mo' 'MM1'  0                     []}';
MM2={'mo' 'MM2'  0                     []}';
CNTV={'mo' 'CNTV'  0                     []}'; %ELEGANT will correct the orbit here for CSR-steering
CNTw={'mo' 'CNTW'  0                     []}'; %ELEGANT will correct the orbit here for CSR-steering
CNT3a={'mo' 'CNT3A'  0                     []}'; %ELEGANT will correct the orbit here for CSR-steering
CNT3b={'mo' 'CNT3B'  0                     []}'; %ELEGANT will correct the orbit here for CSR-steering
IM31={'mo' 'IM31'    0                     []}';
IMBCS1={'mo' 'IMBCS1'        0                     []}';
IMBCS2={'mo' 'IMBCS2'        0                     []}';
DBMARK34={'mo' 'DBMARK34'  0                     []}';
CEDL1={'dr' 'CEDL1'  0.08                     []}'; % XSIZE (or YSIZE) is the collimator half-gap (Tungsten body with Nitanium-Nitrite surface?)
CEDL3={'dr' 'CEDL3'  0.08                     []}';
LPCTDKIK= 0.8128;                                            % length of each if 4 muon protection collimator after TDKIK (0.875" ID w/pipe)
PCTDKIK1={'dr' 'PCTDKIK1'  LPCTDKIK                     []}'; % muon collimator after SBD TDKIK in-line dump
PCTDKIK2={'dr' 'PCTDKIK2'  LPCTDKIK                     []}'; % muon collimator after SBD TDKIK in-line dump
PCTDKIK3={'dr' 'PCTDKIK3'  LPCTDKIK                     []}'; % muon collimator after SBD TDKIK in-line dump
PCTDKIK4={'dr' 'PCTDKIK4'  LPCTDKIK                     []}'; % muon collimator after SBD TDKIK in-line dump

%XCVB2={'mo' 'XCVB2'  0                     []}';      % removed from beamline
XCVM2={'mo' 'XCVM2'  0                     []}';      % calibrated to <1%
XCVM3={'mo' 'XCVM3'  0                     []}';
XCDL1={'mo' 'XCDL1'  0                     []}';
XCDL2={'mo' 'XCDL2'  0                     []}';
XCDL3={'mo' 'XCDL3'  0                     []}';
XCDL4={'mo' 'XCDL4'  0                     []}';     % fast-feedback (loop-4)
XCQT12={'mo' 'XCQT12'  0                     []}';
XCQT22={'mo' 'XCQT22'  0                     []}';
XCQT32={'mo' 'XCQT32'  0                     []}';      % fast-feedback (loop-4)
XCQT42={'mo' 'XCQT42'  0                     []}';

YCVB1={'mo' 'YCVB1'  0                     []}';
YCVB3={'mo' 'YCVB3'  0                     []}';
YCVM1={'mo' 'YCVM1'  0                     []}';        % calibrated to <1%
YCVM4={'mo' 'YCVM4'  0                     []}';
YCDL1={'mo' 'YCDL1'  0                     []}';
YCDL2={'mo' 'YCDL2'  0                     []}';
YCDL3={'mo' 'YCDL3'  0                     []}';
YCDL4={'mo' 'YCDL4'  0                     []}';
YCQT12={'mo' 'YCQT12'  0                     []}';
YCQT22={'mo' 'YCQT22'  0                     []}';
YCQT32={'mo' 'YCQT32'  0                     []}';        % fast-feedback (loop-4)
YCQT42={'mo' 'YCQT42'  0                     []}';        % fast-feedback (loop-4)

BPMVM1={'mo' 'BPMVM1'  0                     []}';
BPMVM2={'mo' 'BPMVM2'  0                     []}';
BPMVB1={'mo' 'BPMVB1'  0                     []}';
BPMVB2={'mo' 'BPMVB2'  0                     []}';
BPMVB3={'mo' 'BPMVB3'  0                     []}';
%BPMVB4={'mo' 'BPMVB4'  0                     []}'; % not existent?
BPMVM3={'mo' 'BPMVM3'  0                     []}';
BPMVM4={'mo' 'BPMVM4'  0                     []}';
BPMDL1={'mo' 'BPMDL1'  0                     []}';
BPMDL2={'mo' 'BPMDL2'  0                     []}';
BPMDL3={'mo' 'BPMDL3'  0                     []}';
BPMDL4={'mo' 'BPMDL4'  0                     []}';
BPMT12={'mo' 'BPMT12'  0                     []}';
BPMT22={'mo' 'BPMT22'  0                     []}';
BPMT32={'mo' 'BPMT32'  0                     []}';
BPMT42={'mo' 'BPMT42'  0                     []}';

%ECELL=[QE31,DQEC,DQEC,QE32,QE32,DQEC,DQEC,QE31];

VBEND=[VBin, ...
       BY1A,BY1B,DVB1,QVB1,BPMVB1,QVB1,D40cmC,YCVB1,  ...
       DVB2m80cm,D40cmC,QVB2,BPMVB2,QVB2,DVB2,  ...
       QVB3,BPMVB3,QVB3,D40cmC,YCVB3,DVB1m40cm,BY2A,BY2B,CNTV,  ...
       VBout];

VBSYS=[DYCVM1, ...
       YCVM1,DQVM1,QVM1,BPMVM1,QVM1,DQVM2a,XCVM2,DQVM2b, ...
       QVM2,BPMVM2,QVM2,DWSVM2a,WSVM2,DWSVM2b, ...
       VBEND,DVB25cmc, ...
       XCVM3,D25cm,QVM3,BPMVM3,QVM3,DVBem25cm, ...
       YCVM4,D25cm,QVM4,BPMVM4,QVM4,DVBem15cm,IM31,D10cmb,IMBCS1, ...
       D25cma];

EWIG=[DBYw1A,DBYw1B,Dw1o,DBYw2A,DBYw2B,Dw1o,DBYw3A,DBYw3B, ...
      CNTw];

DL21=[DBMARK34,BX31A,BX31B,DDL10w,EWIG, ...
      DWSDL31a,WSDL31,DWSDL31b,DDL10x, ...
      XCDL1,D31A,QDL31,BPMDL1,QDL31,D31B,YCDL1,D32cmb,CEDL1, ...
      DDL10em80cm,BX32A,BX32B,CNT3a];

DL22=[DX33A,DX33B,DDL1a,BYKIK1A,BYKIK1B,DDL1c,DDL1c, ...
      BYKIK2A,BYKIK2B,DDL1b,XCDL2,D32A,QDL32,BPMDL2, ...
      QDL32,D32B,YCDL2,DSPLR,SPOILER,DDL1cm40cm,TDKIK,D30cma, ...
      PCTDKIK1,DPC1,PCTDKIK2,DPC2,PCTDKIK3,DPC3,PCTDKIK4,DPC4, ...
      SPONTUA,SPONTUB,DDL1dm30cm,DX34A,DX34B];

DL23=[BX35A,BX35B,DCQ31a,CQ31,CQ31,DCQ31b,OTR30,D29cma,XCDL3, ...
      D33A,QDL33,BPMDL3,QDL33,D33B,YCDL3,D32cmd,CEDL3, ...
      DCQ32a,CQ32,CQ32,DCQ32b,BX36A,BX36B,CNT3b];

%DL24=[DX37A,DX37B,D30cm,IMBCS2,DDL10m70cm,XCDL4,D34A,QDL34, ...
%      BPMDL4,QDL34,D34B,YCDL4,DDL10um25cm,DDL10v,DX38A,DX38B];
DL24=[D37a,IMBCS2,D37b,WSDL4,D37c,DCHIRPV,MDCHIRPV,DCHIRPV, ...
      D37d,QDL34,BPMDL4,QDL34,D38a,DCHIRPH,MDCHIRPH,DCHIRPH, ...
      D38b,XCDL4,D38c,YCDL4,D38d];

TRIP1=[DDL20e,QT11,QT11,DDL30em40cm,XCQT12,D40cmb,QT12, ...
       BPMT12,QT12,D40cmb,YCQT12,DDL30em40cm,QT13,QT13,DDL20e];

TRIP2=[DDL20,QT21,QT21,DDL30em40cm,XCQT22,D40cmb,QT22, ...
       BPMT22,QT22,D40cmb,YCQT22,DDL30em40cm,QT23,QT23,DDL20];

TRIP3=[DDL20e,QT31,QT31,DDL30em40cma,XCQT32,D40cmd,QT32, ...
       BPMT32,QT32,D40cme,YCQT32,DDL30em40cmb,QT33,QT33,DDL20e];

TRIP4=[DDL20,QT41,QT41,DDL30em40cmc,XCQT42,D40cmf,QT42, ...
       BPMT42,QT42,D40cmb,YCQT42,DDL30em40cm,QT43,QT43,DDL20];

DOGLG2A=[DL21,TRIP1,SS1,DL22,TRIP2];

DOGLG2B=[DL23,TRIP3,SS3,DL24,TRIP4];


% (E)mittance (D)iagnostic matching

LQx=0.1080;         %Everson-Tesla (ET) quads "1.259Q3.5" effective length (m)
KQEM1=-0.3948193191;
KQEM2= 0.437029374266;
KQEM3=-0.601204901993;
KQEM4= 0.425609607536;
otr33=0;
if otr33
    KQEM1  = 0.52306699115;        % set KQED2=0 and match QEM1-4 for slice-y-emit on OTR33: BETX,Y=20.6 m, ALFX,Y=0 (20.6=12*DE3[L]/5)
    KQEM2  =-0.353726691931;
    KQEM3  = 0.476261672082;   % use to quad scan slice-y-emit on OTR33 (+-3%)
    KQEM4  =-0.277924519959;
end

D25cmb={'dr' ''          0.25+0.0127     []}';
D25cmc={'dr' ''          0.25-0.0127     []}';
DMM1m90cm={'dr' ''          2.0-0.25-0.25-0.4+0.10046     []}';
DMM3m80cm={'dr' ''          10.0-0.4-0.4+2.0+0.07092     []}';
DMM4m90cm={'dr' ''          3.6-0.30-LQx-(0.402839)-0.02954     []}';
DMM5={'dr' ''          2.0+dLQA2     []}';

DEM1A={'dr' ''           0.40+dLQA2-0.10046        []}';
DEM1B={'dr' ''           4.00+dLQA2*2        []}';
DEM2B={'dr' ''           0.40+dLQA2+0.02954        []}';
DEM3A={'dr' ''           0.40+dLQA2-0.10046        []}';
DEM3B={'dr' ''           0.30+dLQA2+0.402839        []}';
DEM4A={'dr' ''           0.40+dLQA2-0.402839+(0.402839)+0.02954        []}';

D40cm={'dr' ''          0.40                  []}';
D36cm={'dr' ''          0.3683-0.0618         []}';    
D3cm ={'dr' ''          0.0317+0.0618         []}'; 
D40cmh={'dr' ''          0.0317                []}';    
D40cmg={'dr' ''          D40cm{3}-D40cmh{3}    []}'; 

YCEM1 ={'mo' 'YCEM1'   0                     []}';
XCEM2 ={'mo' 'XCEM2'   0                     []}';
YCEM3 ={'mo' 'YCEM3'   0                     []}';
XCEM4 ={'mo' 'XCEM4'   0                     []}';
IM36  ={'mo' 'IM36'    0                     []}';
BPMEM1={'mo' 'BPMEM1'  0                     []}';
BPMEM2={'mo' 'BPMEM2'  0                     []}';
BPMEM3={'mo' 'BPMEM3'  0                     []}';
BPMEM4={'mo' 'BPMEM4'  0                     []}';
QEM1={'qu' 'QEM1'           LQA/2                 KQEM1}';
QEM2={'qu' 'QEM2'           LQA/2                 KQEM2}';
QEM3={'qu' 'QEM3'           LQA/2                 KQEM3}';
QEM3V={'qu' 'QEM3V'         LQx/2                     0}';
QEM4={'qu' 'QEM4'           LQA/2                 KQEM4}';

EDMCH=[D25cmb,IM36,D25cmc,DMM1m90cm,YCEM1, ...
       DEM1A,QEM1,BPMEM1,QEM1,DEM1B,QEM2,BPMEM2,QEM2,DEM2B, ...
       XCEM2,DMM3m80cm,YCEM3,DEM3A,QEM3,BPMEM3,QEM3, ...
       DEM3B,QEM3V,QEM3V,DMM4m90cm,XCEM4,DEM4A,QEM4,BPMEM4, ...
       QEM4,DMM5];

% (E)mittance (D)iagnistc system
dz_adjust=47.825;
KQED2=0.402753198232*1;      %ED2 FODO quad strength (set =0 for slice-emit on OTR33)

if otr33
    KQED2=0.402753198232*0;      %ED2 FODO quad strength (set =0 for slice-emit on OTR33)
end

DQEA={'dr' ''            0.40+(LQF-LQx)/2-0.15046       []}';
DQEAa={'dr' ''            0.40+(LQF-LQx)/2-0.14046       []}';
DQEAb={'dr' ''            0.40+(LQF-LQx)/2-0.12046       []}';
DQEAc={'dr' ''            0.40+(LQF-LQx)/2+0.02954       []}';
DQEBx={'dr' ''            0.32+(LQF-LQx)/2+0.33655-0.0768665+0.04       []}';
DQEBy={'dr' ''            0.32+(LQF-LQx)/2+0.33655-0.0768665+0.04       []}';
DQEC={'dr' ''            4.6+dz_adjust/12+(LQF-LQx)/2       []}';
DQECa={'dr' ''            7.950716   []}';
DQECb={'dr' ''            DQEC{3}-DQECa{3}       []}';
DE3={'dr' ''            4.6+dz_adjust/12+0.15046       []}';
DE3a={'dr' ''            4.6+dz_adjust/12+0.14046       []}';
DE3m40cm={'dr' ''            4.6-0.4+dz_adjust/12+0.15046       []}';
DE3m80cm={'dr' ''            4.6-0.4-0.4+dz_adjust/12-0.02954       []}';
DE3m80cma={'dr' ''            4.6-0.4-0.4+dz_adjust/12+0.15046       []}';
DE3m80cmb={'dr' ''            4.6-0.4-0.4+dz_adjust/12+0.12046       []}';
DQEBx2={'dr' ''            4.6-0.4-0.4+dz_adjust/12-0.33655+0.0768665-0.04       []}';
DQEBy2={'dr' ''            4.6-0.4+dz_adjust/12-0.33655+0.0768665-0.04       []}';

CX31={'dr' 'CX31'            0.08       []}'; % 2.2 mm half-gap in X and Y here (beta_max=67 m) keeps worst case radius: r = sqrt(x^2+y^2) < 2 mm in undulator (beta_max=35 m)
CY32={'dr' 'CY32'            0.08       []}';
CX35={'dr' 'CX35'            0.08       []}';
CY36={'dr' 'CY36'            0.08       []}';
DCX37={'dr' ''          0.08                  []}'; %CX37
DCY38={'dr' ''          0.08                  []}'; %CY38

DBMARK36={'mo' 'DBMARK36'   0                 []}'; %(WS31    ) center of WS31
XCE31 ={'mo' 'XCE31'   0                     []}';
YCE32 ={'mo' 'YCE32'   0                     []}';
XCE33 ={'mo' 'XCE33'   0                     []}';
YCE34 ={'mo' 'YCE34'   0                     []}';
XCE35 ={'mo' 'XCE35'   0                     []}';
YCE36 ={'mo' 'YCE36'   0                     []}';
WS31={'mo' 'WS31'    0                     []}';
WS32={'mo' 'WS32'    0                     []}';
WS33={'mo' 'WS33'    0                     []}';
WS34={'mo' 'WS34'    0                     []}';
%WS35={'mo' 'WS35'    0                     []}'; % prototype fast wire scanner ... removed
%WS36={'mo' 'WS36'    0                     []}'; % prototype piezo wire scanner ... removed
YAGPSI={'mo' 'YAGPSI'  0                     []}';
OTR33={'mo' 'OTR33'  0                     []}';
BPME31={'mo' 'BPME31'  0                     []}';
BPME32={'mo' 'BPME32'  0                     []}';
BPME33={'mo' 'BPME33'  0                     []}';
BPME34={'mo' 'BPME34'  0                     []}';
BPME35={'mo' 'BPME35'  0                     []}';
BPME36={'mo' 'BPME36'  0                     []}';
QE31={'qu' 'QE31'           LQx/2                +KQED2}';
QE32={'qu' 'QE32'           LQx/2                -KQED2}';
QE33={'qu' 'QE33'           LQx/2                +KQED2}';
QE34={'qu' 'QE34'           LQx/2                -KQED2}';
QE35={'qu' 'QE35'           LQx/2                +KQED2}';
QE36={'qu' 'QE36'           LQx/2                -KQED2}';

EDSYS=[DBMARK36,WS31,D40cm,DE3m80cma, ...
       XCE31,DQEA,QE31,BPME31,QE31,DQEBx,CX31,DQEBx2, ...
       DE3a,YCE32,DQEAa,QE32,BPME32,QE32,DQEBy,CY32, ...
       DQEBy2,WS32,D40cm,DE3m80cmb,XCE33,DQEAb, ...
       QE33,BPME33,QE33,DQECa,YAGPSI,DQECb,OTR33,DE3m40cm,YCE34,DQEA,QE34, ...
       BPME34,QE34,DQEC,WS33,D40cm,DE3m80cm,XCE35, ...
       DQEAc,QE35,BPME35,QE35,DQEBx,CX35,DQEBx2,DE3, ...
       YCE36,DQEA,QE36,BPME36,QE36,DQEBy,CY36,DQEBy2, ...
       WS34,D40cmg,D40cmh];

% ------------------------------------------------------------------------------
% XLEAP installation
% ------------------------------------------------------------------------------

LXLEAP=8.14492; % length of space between QUM2 and QUM3

% wiggler is nominally OFF (opened to full gap), with Kwig~2;
% at minimum gap, Kwig=50

Kwig=0;                                % wiggler parameter [m^-1]
lamw=0.34;                             % wiggler period [m]
Lwig=2.38/2;                           % wiggler half-length [m]
kqwig=(2*pi*Kwig/lamw/sqrt(2)/gamf)^2; % natural vertical focusing "k" [m^-2]

WIGXL={'un' 'WIGXL' Lwig [kqwig lamw]}';

DXL0={'dr' '' 0.59371     []}';
DXL1={'dr' '' 0.5183      []}';
DXL2={'dr' '' 0.4818      []}';
DXL3={'dr' '' 1.9847-Lwig []}';
DXL4={'dr' '' 1.8034-Lwig []}';
DXL5={'dr' '' 0.4318      []}';
DXL6={'dr' '' 0.5080      []}';
DXL7={'dr' '' 1.0922      []}';
DXL8={'dr' '' 0.34901     []}';
DXL9={'dr' '' 0.382       []}';

XCXL1={'mo' 'XCXL1' 0 []}';
XCXL2={'mo' 'XCXL2' 0 []}';

YCXL1={'mo' 'YCXL1' 0 []}';
YCXL2={'mo' 'YCXL2' 0 []}';
YCUM3={'mo' 'YCUM3' 0 []}';

MIRXL={'mo' 'MIRXL' 0 []}'; % "holey" mirror (for laser injection)
PRXL1={'mo' 'PRXL1' 0 []}'; % u/s beam overlap monitor (spatial)
PRXL2={'mo' 'PRXL2' 0 []}'; % d/s beam overlap monitor (spatial)
PRXL3={'mo' 'PRXL3' 0 []}'; % photodiode beam overlap monitor (temporal)

XLEAP=[DXL0,XCXL1,DXL1,YCXL1,DXL2,PRXL1,DXL3,WIGXL,WIGXL, ...
       DXL4,PRXL2,DXL5,YCXL2,DXL6,XCXL2,DXL7,PRXL3,DXL8, ...
       YCUM3,DXL9];

% ------------------------------------------------------------------------------

% Undulator match section for <beta>=30 m undulator

% XLEAP off, nominal (Kwig=0)
KQUM1= 0.438152708498; %
KQUM2=-0.387122017170; %for <beta>=30 m undulator
KQUM3= 0.092751923581; %for <beta>=30 m undulator
KQUM4= 0.340037095214; %for <beta>=30 m undulator

% XLEAP on (Kwig=50)
% KQUM1= 0.439094536397; %for <beta>=30 m undulator
% KQUM2=-0.386438932643; %for <beta>=30 m undulator
% KQUM3= 0.101239519138; %for <beta>=30 m undulator
% KQUM4= 0.335807817071; %for <beta>=30 m undulator

QUM1     ={'qu' 'QUM1'      LQA/2                 KQUM1}';
QUM2     ={'qu' 'QUM2'      LQA/2                 KQUM2}';
QUM3     ={'qu' 'QUM3'      LQA/2                 KQUM3}';
QUM4     ={'qu' 'QUM4'      LQA/2                 KQUM4}';

DUM1A={'dr' ''          0.40+dLQA2+0.0254-0.00586     []}';
DUM1B={'dr' ''          0.40+dLQA2     []}';
DUM2A={'dr' ''          0.40+dLQA2-0.0253999-0.0750601     []}';
DUM2B={'dr' ''          0.40+dLQA2     []}';
DUM3A={'dr' ''          0.40+dLQA2+0.125-0.21546     []}';
DUM3B={'dr' ''          0.40+dLQA2     []}';
DUM4A={'dr' ''          0.40+dLQA2+0.0254+0.00414     []}';
DUM4B={'dr' ''          0.40+dLQA2+0.127     []}';
%D16cm = {'dr' ''          0.16515                []}'; 
%DU4m38cm={'dr' ''          4.38485               []}';
DU1m80cm={'dr' ''          4.550                 []}';
DU2m120cm={'dr' ''          4.730 []}';
DU3m80cm={'dr' ''          8.0-0.4-0.4-0.125+0.21546 []}';
DU4m120cm={'dr' ''          2.800-1.407939-0.0254-0.00414 []}';
DU5m80cm={'dr' ''          0.5 []}';
DMUON2={'dr' ''          1.164391 []}';
DMUON1={'dr' ''          0.154859 []}';
DMUON3={'dr' ''          0.310592 []}';
DUHW1={'dr' ''               0.391584      []}';
UHWALL1={'dr' ''             9.875*in2m      []}';
DUHW2={'dr' ''               0.403491      []}';
UHWALL2={'dr' ''             9.875*in2m      []}';

D40cma   ={'dr' ''          0.4+1.407939          []}';
DVV35    ={'dr' ''          1.780-0.254-1.087896+0.003189 []}'; % drift after pre-undulator vacuum valve
D32cm    ={'dr' ''          0.32                  []}';
D32cmc   ={'dr' ''          0.32-0.0254+0.00586           []}';
D32cma   ={'dr' ''          0.32+0.0253999+0.0750601        []}';
DTDUND1  ={'dr' ''          1.057391        []}'; % drift before pre-undulator tune-up dump
DTDUND2  ={'dr' ''          0.37935               []}'; % drift after pre-undulator tune-up dump
PCMUON   ={'dr' 'PCMUON'    1.1684                []}'; % muon scattering collimator after pre-undulator tune-up dump (ID from Rago: 7/18/08)

XCUM1    ={'mo' 'XCUM1'     0                     []}';
YCUM2    ={'mo' 'YCUM2'     0                     []}';
XCUM4    ={'mo' 'XCUM4'     0                     []}';

IMUNDI   ={'mo' 'IMUNDI'    0                     []}';
EOBLM    ={'mo' 'EOBLM'     0                     []}';
RWWAKEAl ={'mo' 'RWWAKEAl'  0                     []}';
TDUND    ={'mo' 'TDUND'     0                     []}';
VV999    ={'mo' 'VV999'     0                     []}';
MM3      ={'mo' 'MM3'       0                     []}';
PFILT1   ={'mo' 'PFILT1'    0                     []}';
DBMARK37 ={'mo' 'DBMARK37'  0                     []}';

BPMUM1   ={'mo' 'BPMUM1'    0                     []}';
BPMUM2   ={'mo' 'BPMUM2'    0                     []}';
BPMUM3   ={'mo' 'BPMUM3'    0                     []}';
BPMUM4   ={'mo' 'BPMUM4'    0                     []}';
RFB07    ={'mo' 'RFB07'     0                     []}';
RFB08    ={'mo' 'RFB08'     0                     []}';

DXLM1={'dr' '' 1.10447               []}';
DXLM2={'dr' '' DU2m120cm{3}-DXLM1{3} []}';

UNMCH=[DU1m80cm,DCX37,D32cmc,XCUM1,DUM1A,QUM1,BPMUM1,QUM1,DUM1B, ...
       D32cm,DXLM1,MIRXL,DXLM2,DCY38,D32cma,YCUM2,DUM2A,QUM2,BPMUM2,QUM2, ...
       XLEAP, ...
       QUM3,BPMUM3,QUM3,DUM3B,D40cma,EOBLM,DU4m120cm, ...
       XCUM4,DUM4A,QUM4,BPMUM4,QUM4,DUM4B,RFB07,DU5m80cm, ...
       IMUNDI,DUHW1,RWWAKEAl,UHWALL1,DMUON2,DVV35,RFB08, ...
       DUHW2,UHWALL2,DTDUND1, ...
       TDUND,DTDUND2,PCMUON,DMUON1,VV999,DMUON3,MM3,PFILT1, ...
       DBMARK37];

% Undulator exit section

XTC01={'tc' 'XTCAV' 1/2 [11424 0 90*pi/180 0]}';
XTC02={'tc' 'XTCAV' 1/2 [11424 0 90*pi/180 0]}';
%XTC01={'dr' 'XTC01' 1/2 []}';
%XTC02={'dr' 'XTC02' 1/2 []}';

LQD=0.550; %FFTB dump quad (3.25Q20) effective length (m)
KQUE1= -0.063065263603; %XTCAV optics
KQUE2=  0.135705662403; %XTCAV optics
if modelUseOldUE
  KQUE1= 0.104402672527; % [<beta>=30 m]
  KQUE2=-0.034721612961; % [<beta>=30 m]
end
QUE1={'qu' 'QUE1' LQD/2 KQUE1}';
QUE2={'qu' 'QUE2' LQD/2 KQUE2}';

LPCPM=0.076;

DUE1a=  {'dr' ''      1.790539        []}';
DUE1b=  {'dr' ''      9.34167         []}';
DUE1c=  {'dr' ''      0.5522          []}';
DUE2a=  {'dr' ''      1.76648-LRFBu/2 []}';
DUE2b=  {'dr' ''      5.41752-LRFBu/2 []}';
DUE2c=  {'dr' ''      0.169           []}';
DUE2d=  {'dr' ''      3.944899        []}';
DUE2e=  {'dr' ''      0.4946          []}';
DUE2f=  {'dr' ''      0.460047        []}';
DUE3a=  {'dr' ''      5.5785535       []}';
DUE3b=  {'dr' ''      1.7968755       []}';
DPCVV=  {'dr' ''      0.397           []}';
DVVXTC= {'dr' ''      0.32            []}';
DXTC12= {'dr' ''      0.373/2         []}';
DXTCSP= {'dr' ''      0.381           []}';
DUE4=   {'dr' ''      0.394           []}';
DUE5a=  {'dr' ''      0.367           []}';
DUE5b=  {'dr' ''      0.514           []}';
DUE5c=  {'dr' ''      0.198151        []}';
DUE5d=  {'dr' ''      0.471           []}';
DUE5e=  {'dr' ''      0.137           []}';
DSB0a=  {'dr' ''      0.0             []}';
PCPM0=  {'dr' 'PCPM0' LPCPM           []}';
DSB0b=  {'dr' ''      0.163           []}';
DSB0c=  {'dr' ''      0.356           []}';
DSB0d=  {'dr' ''      0.202           []}';
DSB0e=  {'dr' ''      0.372634        []}';
DUHW3=  {'dr' ''      0.397024        []}';
UHWALL3={'dr' ''      9.875*in2m      []}';

UEbeg=  {'mo' 'UEbeg'   0 []}';
VV36=   {'mo' 'VV36'    0 []}';
IMUNDO= {'mo' 'IMUNDO'  0 []}';
RFBUE1= {'mo' 'RFBUE1'  0 []}'; % Korean RFBPM
XCUE1=  {'mo' 'XCUE1'   0 []}';
PH31=   {'mo' 'PH31'    0 []}';
PH32=   {'mo' 'PH32'    0 []}';
YCUE2=  {'mo' 'YCUE2'   0 []}';
BPMUE1= {'mo' 'BPMUE1'  0 []}';
TRUE1=  {'mo' 'TRUE1'   0 []}'; % Be foil inserter (THz)
PCXTC=  {'mo' 'PCXTC'   0 []}';
VVXTC=  {'mo' 'VVXTC'   0 []}';
MXTC=   {'mo' 'MXTC'    0 []}';
SPXTC=  {'mo' 'SPXTC'   0 []}';
BPMUE2= {'mo' 'BPMUE2'  0 []}';
BTM0=   {'mo' 'BTM0'    0 []}';
YCD3=   {'mo' 'YCD3'    0 []}';
XCD3=   {'mo' 'XCD3'    0 []}';
UEend=  {'mo' 'UEend'   0 []}';
DLstart={'mo' 'DLSTART' 0 []}';
IMBCS3= {'mo' 'IMBCS3'  0 []}';
VV37=   {'mo' 'VV37'    0 []}';
BPMUE3= {'mo' 'BPMUE3'  0 []}';

UNDEXIT=[UEbeg,DUE1a,VV36,DUE1b,IMUNDO,DUE1c,XCUE1, ...
         DUE2a,RFBUE1,DUE2b,PH31,DUE2c,PH32,DUE2d,YCUE2,DUE2e, ...
         BPMUE1,DUE2f,QUE1,QUE1,DUE3a,TRUE1,DUE3b, ...
         PCXTC,DPCVV,VVXTC,DVVXTC,XTC01,XTC01,DXTC12,MXTC,DXTC12, ...
         XTC02,XTC02,DXTCSP,SPXTC,DUE4,QUE2,QUE2, ...
         DUE5a,BPMUE2,DUE5b,BTM0,DUHW3,UHWALL3,DUE5c,YCD3,DUE5d, ...
         XCD3,DUE5e,UEend, ...
         DLstart,DSB0a,PCPM0,DSB0b,IMBCS3,DSB0c,VV37, ...
         DSB0d,BPMUE3,DSB0e];

if modelUseOldUE
  DUE1c={'dr' '' 0.818826 - 0.818826 + 0.126460  []}';
  DUE1d={'dr' '' 0 + 0.818826 - 0.126460 - LQD/2 []}';
  DUE2a={'dr' '' 1.0 - LQD/2                     []}';
  DUE2b={'dr' '' 10.43092                        []}';
  DUE2c={'dr' '' 0.555                           []}';
  DUE3a={'dr' '' 0.315504                        []}';
  DUE3b={'dr' '' 5.2630495                       []}';
  DUE3c={'dr' '' 1.7968755                       []}'; %11.919836
  DUE4= {'dr' '' 0.394 + LQD                     []}';
         
  UNDEXIT=[UEbeg,DUE1a,VV36,DUE1b,IMUNDO,DUE1c,XCUE1, ...
           DUE2a,RFBUE1,DUE2b,PH31,DUE2c,PH32,DUE2d,YCUE2,DUE2e, ...
           BPMUE1,DUE2f,QUE1,QUE1,DUE3a,TRUE1,DUE3b, ...
           PCXTC,DPCVV,VVXTC,DVVXTC,XTC01,XTC01,DXTC12,MXTC,DXTC12, ...
           XTC02,XTC02,DXTCSP,SPXTC,DUE4,QUE2,QUE2, ...
           DUE5a,BPMUE2,DUE5b,BTM0,DUHW3,UHWALL3,DUE5c,YCD3,DUE5d, ...
           XCD3,DUE5e,UEend, ...
           DLstart,DSB0a,PCPM0,DSB0b,IMBCS3,DSB0c,VV37, ...
           DSB0d,BPMUE3,DSB0e];
end

% Dumpline

LBdm   = 1.452;          %!effective vertical bend length of main dump bends - from J. Tanabe (m)
GBdm   = 0.043;          %full gap (m) - this is a full gap 'width' for these vert. dipoles
ABdm0  = (5.0*pi/180)/3;

LeffBdm = LBdm*ABdm0/(2*sin(ABdm0/2)); %full bend path length (m)

BYD1A={'be' 'BYD1'  LeffBdm/2 [ABdm0/2 GBdm/2 ABdm0/2 0 0.57 0.0  pi/2]}';
BYD1B={'be' 'BYD1'  LeffBdm/2 [ABdm0/2 GBdm/2 0 ABdm0/2 0.0  0.57 pi/2]}';
BYD2A={'be' 'BYD2'  LeffBdm/2 [ABdm0/2 GBdm/2 ABdm0/2 0 0.57 0.0  pi/2]}';
BYD2B={'be' 'BYD2'  LeffBdm/2 [ABdm0/2 GBdm/2 0 ABdm0/2 0.0  0.57 pi/2]}';
BYD3A={'be' 'BYD3'  LeffBdm/2 [ABdm0/2 GBdm/2 ABdm0/2 0 0.57 0.0  pi/2]}';
BYD3B={'be' 'BYD3'  LeffBdm/2 [ABdm0/2 GBdm/2 0 ABdm0/2 0.0  0.57 pi/2]}';

%KQDmp  = -0.112488747732;   % [<beta>=30 m]
KQDmp  = -0.135524516196;  %XTCAV optics
QDmp1={'qu' 'QDMP1' LQD/2 KQDmp}';
QDmp2={'qu' 'QDMP2' LQD/2 KQDmp}';
Ddmpv  = -0.73352263654;
LDS    = 0.300-0.026027*2;
LDSC   = 0.499225-0.026027+0.1124278-0.008032;

DS={'dr' ''         LDS        []}';
DSc={'dr' ''         LDSC        []}';
DD1a={'dr' ''         2.6512616        []}';
DD1b={'dr' ''         6.8896877-LQD/2-Ddmpv+0.017094407653        []}';
DD1f={'dr' ''         0.266645-0.017094407653        []}';
DD1c={'dr' ''         0.4+0.2920945-0.266645-2*0.0381452        []}';
DD1d={'dr' ''         0.25-0.0079372        []}';
DD1e={'dr' ''         0.25+0.0079372        []}';
DD2a={'dr' ''         0.4+0.0634916+0.0115084        []}';
DD2b={'dr' ''         8.425460-LQD/2+Ddmpv-0.15-0.0634916-0.049684-0.0115084        []}';
DD3a={'dr' ''         0.3+0.049684+0.001583        []}';
DD3b={'dr' ''         0.3-0.001583-0.1447026+0.294802        []}';
DD3c={'dr' ''         2.580+0.1447026-0.2441932-0.294802        []}';
DD3d={'dr' ''         0.2441932        []}';
DD3e={'dr' ''         0.2857474-0.2441932        []}';

DMPend  ={'mo' 'DMPend'        0                []}';
OTRDMP  ={'mo' 'OTRDMP'        0                []}'; %Dump screen
BTM1L   ={'mo' 'BTM1L'         0                []}'; % Burn-Through-Monitor behind PCPM1L
BTM2L   ={'mo' 'BTM2L'         0                []}'; % Burn-Through-Monitor behind PCPM2L
IMBCS4  ={'mo' 'IMBCS4'        0                []}'; %in dump line, after Y-bends, with >48-mm ID stay-clear (comparator with IMBCS3)
IMDUMP  ={'mo' 'IMDUMP'        0                []}'; %in dump line after Y-bends and quad (comparator with IMUNDO)
YCDD    ={'mo' 'YCDD'          0                []}';
XCDD    ={'mo' 'XCDD'          0                []}';
DBMARK38={'mo' 'DBMARK38'      0                []}'; %(UND_DUMP) final undulator dump
DUMPFACE={'mo' 'DUMPFACE'      0                []}'; % entrance face of main e- dump (same as EOL)
BTMDUMP ={'mo' 'BTMDUMP'       0                []}'; % Burn-Through-Monitor of main e- dump
BPMQD   ={'mo' 'BPMQD'         0                []}';
BPMDD   ={'mo' 'BPMDD'         0                []}';
EOL     ={'mo' 'EOL'           0                []}'; % near entrance face of dump   : Z=3763.781501  (Z' = 715.774454 m, X'=-1.250000 m, Y'=-3.180529 m)

LPCPM   = 0.076;
PCPM1L={'dr' 'PCPM1L'       LPCPM/cos(3*ABdm0)            []}';
PCPM2L={'dr' 'PCPM2L'       LPCPM/cos(3*ABdm0)            []}';

DUMPLINE=[BYD1A,BYD1B,DS,BYD2A,BYD2B,DS, ...
          BYD3A,BYD3B,DSc,PCPM1L,BTM1L,DD1a,IMDUMP,DD1b,YCDD, ...
          DD1f,PCPM2L,BTM2L,DD1c,QDmp1,QDmp1,DD1d,BPMQD,DD1e, ...
          QDmp2,QDmp2,DD2a,XCDD,DD2b,IMBCS4,DD3a,BPMDD,DD3b, ...
          OTRDMP,DD3c,DUMPFACE,DMPend,DD3d,EOL,DD3e,BTMDUMP, ...
          DBMARK38];

% BSY to End
LTU=[MM1,DOGLG2A,DOGLG2B,MM2,EDMCH,EDSYS,UNMCH];
BSYLTU=[BSY,VBSYS,LTU,UND,UNDEXIT,DUMPLINE];

beamLineUN=BSYLTU';
beamLineBSY=BSY';
