function beamLine = model_beamLineA(region)
%MODEL_BEAMLINEA
% BEAMLINE = MODEL_BEAMLINEA(REGION)
% Returns beam line description list for the A-line, including extraction from BSY.

% Input argument:
%    REGION: Optional argument for region, default BSY_ALINE

% Output argument:
%    BEAMLINE : Cell array of beam line information for BSY-ALINE

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Mark Woodley, SLAC

% History:
%   19-MAY-2017, M. Woodley (OPTICS=LCLS05JUN17)
%    * add YCBSYA per D. McCormick
%   09-May-2017, M. Woodley
%    * remove SCAPM2 (XCAPM2/YCAPM2) from this line
%    * add drift to 3PR2; end at 3PR2
%   02-May-2017, M. Woodley (OPTICS=LCLS02MAY17)

% ------------------------------------------------------------------------------

% Set default options.
if nargin < 1, region='BSY_ALINE';end

% Global definitions
Ef=13.64;            % final beam energy (GeV)
mc2=510.99906e-6;    % e- rest mass [GeV]
clight=2.99792458e8; % speed of light [m/s]
Cb=1.0e10/clight;    % energy to magnetic rigidity
in2m=0.0254;         % inches to meters
RADDEG=pi/180;       % degrees-to-radians conversion

ABRDAS2=-0.012001987392; % BRDAS2 bend angle (rad)
TBRDAS2=0.398106089513;  % BRDAS2 roll angle (rad)

% ==============================================================================
% dipoles
% ------------------------------------------------------------------------------

% yawed pulsed magnets (1.405K40.83)

GBKRAPM=35.687e-3;          % 1.405K40.83 pulsed magnet gap (m)
SBKRAPM=1.055;              % PM effective straight length (m)
TBKRAPM=0.014303833885;     % PM tilt angle (rad)
ABKRAPM=-0.276615051231e-2; % angle per one PM (rad)
ABKRAPMh=ABKRAPM/2;         % PM half-angle

ABKRAPMh2=ABKRAPMh*ABKRAPMh;
ABKRAPMh4=ABKRAPMh2*ABKRAPMh2;
LBKRAPM=SBKRAPM/(1-ABKRAPMh2/6+ABKRAPMh4/120); % PM path length

%                        L          ANGLE    HGAP      E1       E2       FINT FINTX TILT
BKRAPM1a={'be' 'BKRAPM1' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 ABKRAPMh 0        0.5  0.0   TBKRAPM]}';
BKRAPM1b={'be' 'BKRAPM1' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 0        ABKRAPMh 0.0  0.5   TBKRAPM]}';
BKRAPM2a={'be' 'BKRAPM2' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 ABKRAPMh 0        0.5  0.0   TBKRAPM]}';
BKRAPM2b={'be' 'BKRAPM2' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 0        ABKRAPMh 0.0  0.5   TBKRAPM]}';
BKRAPM3a={'be' 'BKRAPM3' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 ABKRAPMh 0        0.5  0.0   TBKRAPM]}';
BKRAPM3b={'be' 'BKRAPM3' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 0        ABKRAPMh 0.0  0.5   TBKRAPM]}';
BKRAPM4a={'be' 'BKRAPM4' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 ABKRAPMh 0        0.5  0.0   TBKRAPM]}';
BKRAPM4b={'be' 'BKRAPM4' LBKRAPM/2 [ABKRAPMh GBKRAPM/2 0        ABKRAPMh 0.0  0.5   TBKRAPM]}';

% A-line merge bend (2.0D38.37)

GBRAM1=50.8e-3;                         % 2.0D38.37 gap height (m)
SBRAM1=1.025;                           % 2.0D38.37 straight length (m)
ABRAM1=0.232611190004e-2;               % bend angle (rad)
LBRAM1=SBRAM1*ABRAM1/(2*sin(ABRAM1/2)); % path length (m)
TBRAM1=0.014303788803;                  % bend roll (rad)

%                    L         ANGLE    HGAP     E1       E2       FINT FINTX TILT
BRAM1a={'be' 'BRAM1' LBRAM1/2 [ABRAM1/2 GBRAM1/2 ABRAM1/2 0        0.5  0.0   TBRAM1]}';
BRAM1b={'be' 'BRAM1' LBRAM1/2 [ABRAM1/2 GBRAM1/2 0        ABRAM1/2 0.0  0.5   TBRAM1]}';

% A-bends

% AARC=-24*RADDEG; % total arc bend angle (24 degrees)
% Nbend=12;        % number of arc bends
% ABA=AARC/Nbend;  % arc bend angle
ABA=-1.999526617334*RADDEG; % arc bend angle per Transport deck
LBA=3.024;
GBA=0.06; % Blue Book value

%                L      ANGLE HGAP  E1    E2    FINT FINTX TILT
B11a={'be' 'B11' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B11b={'be' 'B11' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B12a={'be' 'B12' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B12b={'be' 'B12' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B13a={'be' 'B13' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B13b={'be' 'B13' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B14a={'be' 'B14' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B14b={'be' 'B14' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B15a={'be' 'B15' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B15b={'be' 'B15' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B16a={'be' 'B16' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B16b={'be' 'B16' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B21a={'be' 'B21' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B21b={'be' 'B21' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B22a={'be' 'B22' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B22b={'be' 'B22' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B23a={'be' 'B23' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B23b={'be' 'B23' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B24a={'be' 'B24' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B24b={'be' 'B24' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B25a={'be' 'B25' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B25b={'be' 'B25' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';
B26a={'be' 'B26' LBA/2 [ABA/2 GBA/2 ABA/2 0     0.5  0.0   0   ]}';
B26b={'be' 'B26' LBA/2 [ABA/2 GBA/2 0     ABA/2 0.0  0.5   0   ]}';

% ==============================================================================
% quadrupoles
% ------------------------------------------------------------------------------

LQ8cm=2.0;
rQ8cm=0.08/2;
LQ19=2.0;
rQ19=0.186/2;
LQ20=1.31318;
rQ20=8.25*in2m/2;
LSQ=0.55;
rSQ=0.08/2;

% ELEGANT gives 200x200 um at 3PR2

KQ10= 0.039671140049;    % 0.041253414257;
KQ11=-0.039486914896;    %-0.032253444307;
KQ19= 0.030012988711;    % 0.028019346852;
KQ20= 0.786567003252E-2; % 0.014441223514;
KQ27=-0.068279189647;    %-0.057961211624;
KQ28= 0.058092383435;    % 0.058296876951;
KQ30=-0.024131808918;    %-0.027138834159;
KQ38= 0.018033595057;    % 0.018541594138;
KSQ=  0.0;

Q10=   {'qu' 'Q10'    LQ8cm/2 KQ10}';
Q11=   {'qu' 'Q11'    LQ8cm/2 KQ11}';
Q19=   {'qu' 'Q19'    LQ19/2  KQ19}';
Q20=   {'qu' 'Q20'    LQ20/2  KQ20}';
Q27=   {'qu' 'Q27'    LQ8cm/2 KQ27}';
SQ27p5={'qu' 'SQ27p5' LSQ/2   KSQ }'; % TILT
Q28=   {'qu' 'Q28'    LQ8cm/2 KQ28}';
Q30=   {'qu' 'Q30'    LQ8cm/2 KQ30}';
Q38=   {'qu' 'Q38'    LQ8cm/2 KQ38}';

% ==============================================================================
% drifts
% ------------------------------------------------------------------------------

D105={'dr' ''  5.5372   []}';
D106={'dr' ''  0.727    []}';
D107={'dr' ''  0.7755   []}';
D108={'dr' ''  3.84839  []}';
D109={'dr' ''  0.7755   []}';
D110={'dr' ''  3.84839  []}';
D111={'dr' ''  0.7755   []}';
D112={'dr' '' 15.74899  []}';
D113={'dr' ''  9.0997   []}';
D114={'dr' ''  5.94572  []}';
D115={'dr' ''  0.7755   []}';
D116={'dr' ''  3.84839  []}';
D117={'dr' ''  0.7755   []}';
D118={'dr' ''  3.84839  []}';
D119={'dr' ''  0.7755   []}';
D120={'dr' ''  1.744768 []}'; % 1.74477
D121={'dr' ''  1.525    []}';
D122={'dr' ''  1.925    []}';
D123={'dr' '' 38.1116   []}';
D124={'dr' '' 21.4778   []}';
D125={'dr' ''  5.04065  []}';
DPR2={'dr' '' 12.25174  []}'; % wall to 3PR2 in ESA alcove

% drifts for diagnostic and correction devices

D002a={'dr' '' 0.090479 []}';
D002b={'dr' '' 1.654993 []}';
D002c={'dr' '' 0.0184   []}';
D002d={'dr' '' 2.466807 []}';
D002e={'dr' '' 0.34925  []}';
D002f={'dr' '' 4.3434   []}';
D002g={'dr' '' 6.213125 []}';
D002h={'dr' '' 0.3429   []}';
D002i={'dr' '' 0.447449 []}';
D003a={'dr' '' 0.128016 []}';
D003b={'dr' '' 1.609344 []}';
D003c={'dr' '' 0.331248 []}';
D003d={'dr' '' 0.628073 []}';
D003e={'dr' '' 0.2286   []}';
D003f={'dr' '' 0.4826   []}';
D003g={'dr' '' 0.3556   []}';
D003h={'dr' '' 0.415546 []}';
D004a={'dr' '' 0.204216 []}';
D004b={'dr' '' 0.581559 []}';
D005a={'dr' '' 0.762    []}';
D005b={'dr' '' 2.329    []}';
D005c={'dr' '' 5.402548 []}';

D101a={'dr' ''  7.405675 []}';
D101b={'dr' ''  3.2853   []}';
D101c={'dr' ''  0.635    []}';
D101d={'dr' ''  0.787    []}';
D101e={'dr' ''  0.534    []}';
D101f={'dr' ''  0.813    []}';
D101g={'dr' ''  0.685    []}';
D101h={'dr' ''  0.61     []}';
D101i={'dr' ''  1.27     []}';
D101j={'dr' ''  1.778    []}';
D101k={'dr' ''  0.457    []}';
D101l={'dr' ''  0.153    []}';
D101m={'dr' ''  0.177    []}';
D101n={'dr' ''  0.483    []}';
D101o={'dr' ''  0.483    []}';
D101p={'dr' ''  0.587    []}';
PMV=  {'dr' ''  0.4      []}';
D101q={'dr' ''  0.589942 []}';
D102a={'dr' ''  1.06296  []}';
PM=   {'dr' ''  7.0      []}';
D102b={'dr' ''  1.06296  []}';
D103a={'dr' '' 66.20934  []}';
D103b={'dr' ''  0.615959 []}';
D103c={'dr' ''  2.850589 []}';
D103d={'dr' ''  0.15875  []}';
D105a={'dr' ''  0.808    []}';
D105b={'dr' ''  0.38     []}';
D105c={'dr' ''  0.478    []}';
D105d={'dr' ''  0.628    []}';
D105e={'dr' ''  0.684    []}';
D105f={'dr' ''  0.62     []}';
D105g={'dr' ''  0.88     []}';
D105h={'dr' ''  0.668    []}';
D105i={'dr' ''  0.3912   []}';
D108a={'dr' ''  0.829    []}';
D108b={'dr' ''  0.785    []}';
D108c={'dr' ''  2.23439  []}';
D110a={'dr' ''  2.98539  []}';
D110b={'dr' ''  0.863    []}';
D112a={'dr' ''  7.4348   []}';
D112b={'dr' ''  3.19319  []}';
D112c={'dr' ''  1.159    []}';
D112d={'dr' ''  1.302    []}';
D112e={'dr' ''  1.264    []}';
D112f={'dr' ''  0.723    []}';
D112g={'dr' ''  0.673    []}';
D113a={'dr' ''  1.32     []}';
D113b={'dr' ''  1.981    []}';
D113c={'dr' ''  5.7987   []}';
D114a={'dr' ''  4.47     []}';
D114b={'dr' ''  0.775    []}';
D114c={'dr' ''  0.70072  []}';
D116a={'dr' ''  2.81239  []}';
D116b={'dr' ''  1.036    []}';
D118a={'dr' ''  0.65139  []}';
D118b={'dr' ''  0.707    []}';
D118c={'dr' ''  1.131    []}';
D118d={'dr' ''  0.501    []}';
D118e={'dr' ''  0.858    []}';
D120b={'dr' ''  0.35     []}';
D120c={'dr' ''  0.513    []}';
D120a={'dr' ''  D120{3}-D120b{3}-D120c{3} []}'; % 0.881768
D123a={'dr' ''  0.655    []}';
D123b={'dr' ''  0.673    []}';
D123c={'dr' ''  0.644    []}';
D123d={'dr' ''  0.657    []}';
D123e={'dr' ''  0.816    []}';
D123f={'dr' ''  0.445    []}';
D123g={'dr' ''  0.844    []}';
D123h={'dr' '' 31.9656   []}';
D123i={'dr' ''  0.729    []}';
D123j={'dr' ''  0.683    []}';
D124a={'dr' ''  0.629    []}';
D124b={'dr' ''  0.381    []}';
D124c={'dr' ''  0.635    []}';
D124d={'dr' ''  0.559    []}';
D124e={'dr' ''  1.041    []}';
D124f={'dr' '' 16.5857   []}';
D124g={'dr' ''  1.6471   []}';

% PM drifts along A-line

ZPCAPM=0.1824; % length of PM collimator aligned along BSY HXR beam
LPCAPM1=ZPCAPM/cos(1*ABKRAPM);
LPCAPM2=ZPCAPM/cos(2*ABKRAPM);
LPCAPM3=ZPCAPM/cos(3*ABKRAPM);
LPCAPM4=ZPCAPM/cos(4*ABKRAPM);

LDAPM=0.5951; % space between two PMs along A-line trajectory
LDAPM1=(LDAPM-LPCAPM1)/2;
LDAPM2=(LDAPM-LPCAPM2)/2;
LDAPM3=(LDAPM-LPCAPM3)/2;
LDAPM4=(LDAPM-LPCAPM4)/2;

DAPM1= {'dr' ''  LDAPM1   []}';
DAPM2= {'dr' ''  LDAPM2   []}';
DAPM2a={'dr' ''  LDAPM2/2 []}';
DAPM2b={'dr' ''  LDAPM2/2 []}';
DAPM3= {'dr' ''  LDAPM3   []}';
DAPM4= {'dr' ''  LDAPM4   []}';

LBSP=1.0;                     % 1.0D38.37 straight length (m)
LPCSP=0.3;                    % length of BCS protection collimator in spreader
LPCBSY2=LPCSP/cos(4*ABKRAPM); % length of PCBSY2 aligned along BSY HXR beam

LDA01=0.0471765+0.15; % verify the position of PCBSY2 with Stan 
LDA02=4.371494-LDA01-LPCSP/cos(4*ABKRAPM)-1.35/cos(4*ABKRAPM);
LDA03=1.3206+1.35/cos(4*ABKRAPM);
LDA04=48.451380526704-1.0;
LDBRDAS2=LBSP*cos(ABRDAS2*sin(TBRDAS2)/2)*cos(ABRDAS2*cos(TBRDAS2)/2)/cos(ABRDAS2*cos(TBRDAS2));
LDA04b=0.5;
LDA04c=19.829173153578;
LDA04a=LDA04-LDBRDAS2-LDA04b-LDA04c;
LDA05=0.5;
LDA06=0.5;

DA01=    {'dr' ''  LDA01      []}';
DA02=    {'dr' ''  LDA02      []}';
DA03b=   {'dr' ''  0.6        []}';
DA03a=   {'dr' ''  LDA03-DA03b{3} []}';
DBRDAS2a={'dr' ''  LDBRDAS2/2 []}';
DBRDAS2b={'dr' ''  LDBRDAS2/2 []}';
DRCDAS19={'dr' ''  0.0        []}';
DA04a=   {'dr' ''  LDA04a     []}';
DA04b=   {'dr' ''  LDA04b     []}';
DA04c=   {'dr' ''  LDA04c     []}';
DA05=    {'dr' ''  LDA05      []}';
DA06=    {'dr' ''  LDA06      []}';
DAMQ10=  {'dr' ''  0.9875     []}';

DSCAPM2= {'dr' ''  0.0        []}';

% ==============================================================================
% coordinate rolls ... bend plane rotated to remove linac slope
% ------------------------------------------------------------------------------

ROLLON=-1; % roll must be negated to agree with MAD

% original A-line values

% ROLL1 : SROT, ANGLE= 0.014303845885    * ROLLON
% ROLL2 : SROT, ANGLE=-0.393462907527E-2 * ROLLON
% ROLL3 : SROT, ANGLE=-0.011395368282    * ROLLON

% new values

% ROLL4 : SROT, ANGLE= 0.014303788803    * ROLLON
% ROLL2 : SROT, ANGLE=-0.399639784046E-2 * ROLLON
% ROLL3 : SROT, ANGLE= 0.0               * ROLLON !no ROLL3 per alignment group

ROLL2={'ro' '' 0 (0.014303788803-0.399639784046e-2)*ROLLON}';
ROLL3={'ro' '' 0  0.0                              *ROLLON}'; % no ROLL3 per alignment group

% ==============================================================================
% XCORs and YCORs
% ------------------------------------------------------------------------------

A28X=   {'mo' 'A28X'   0 []}';
A32X=   {'mo' 'A32X'   0 []}';

YCBSYA= {'mo' 'YCBSYA' 0 []}';
A10Y=   {'mo' 'A10Y'   0 []}';
A18Y=   {'mo' 'A18Y'   0 []}';
A29Y=   {'mo' 'A29Y'   0 []}';
A33Y=   {'mo' 'A33Y'   0 []}';

% ==============================================================================
% BPMs
% ------------------------------------------------------------------------------

% rename BPM10 and BPM12 to avoid conflicts

BPM10A={'mo' 'BPM10A' 0 []}';
BPM12A={'mo' 'BPM12A' 0 []}';
BPM17= {'mo' 'BPM17'  0 []}';
BPM24= {'mo' 'BPM24'  0 []}';
BPM28= {'mo' 'BPM28'  0 []}';
BPM31= {'mo' 'BPM31'  0 []}';
BPM32= {'mo' 'BPM32'  0 []}';

% ==============================================================================
% profile monitors, wire scanners, wire arrays, synchrotron light ports, 
% spectrum foils, burn-through monitors, and Cu-target
% ------------------------------------------------------------------------------

PR10= {'mo' 'PR10' 0 []}';
SYNC= {'mo' 'SYNC' 0 []}';
PR18= {'mo' 'PR18' 0 []}';
SP18= {'mo' 'SP18' 0 []}';
PR20= {'mo' 'PR20' 0 []}';
PR28= {'mo' 'PR28' 0 []}';
PR33= {'mo' 'PR33' 0 []}';
P3PR2={'mo' '3PR2' 0 []}';

% new devices

YAGAPM=  {'mo' 'YAGAPM'   0 []}'; % YAG profile monitor
PRBRAM1= {'mo' 'PRBRAM1'  0 []}'; % profile monitor, type to be determined
TGTBRAM1={'mo' 'TGTBRAM1' 0 []}'; % secondary production Cu target

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

% new devices

PCAPM1={'dr' 'PCAPM1' LPCAPM1 []}'; % XSIZE=44.45E-3, YSIZE=6.35E-3
PCAPM2={'dr' 'PCAPM2' LPCAPM2 []}'; % XSIZE=44.45E-3, YSIZE=6.35E-3
PCAPM3={'dr' 'PCAPM3' LPCAPM3 []}'; % XSIZE=44.45E-3, YSIZE=6.35E-3
PCAPM4={'dr' 'PCAPM4' LPCAPM4 []}'; % XSIZE=44.45E-3, YSIZE=6.35E-3

% BCS devices (these will not be installed for LCLS running in 2017)

DPCBSY2= {'dr' 'PCAPM4' LPCBSY2 []}';
DBTMBSY2={'dr' 'PCAPM4' 0.0     []}';

% 1" ID A-line collimator -- part of 2-hole copper collimator d/s of A-line PM

PCBSYA={'dr' 'PCBSYA' 0.45/cos(4*ABKRAPM) []}'; % XSIZE=12.7E-3, YSIZE=12.7E-3

% existing devices

PC10={'dr' 'PC10' 0.0 []}';
PC12={'dr' 'PC12' 0.0 []}';
PC14={'dr' 'PC14' 0.0 []}';
PC17={'dr' 'PC17' 0.0 []}';
SL19={'dr' 'SL19' 0.0 []}';
SL10={'dr' 'SL10' 0.0 []}';
PC20={'dr' 'PC20' 0.0 []}';
PC24={'dr' 'PC24' 0.0 []}';
C24= {'dr' 'C24'  0.0 []}';
PC26={'dr' 'PC26' 0.0 []}';
PC29={'dr' 'PC29' 0.0 []}';
C37= {'dr' 'C37'  0.0 []}';

% ==============================================================================
% vacuum components
% ------------------------------------------------------------------------------

IV10={'mo' 'IV10' 0.0 []}';
FV10={'mo' 'FV10' 0.0 []}';
IV26={'mo' 'IV26' 0.0 []}';
FV28={'mo' 'FV28' 0.0 []}';

% ==============================================================================
% points of interest
% ------------------------------------------------------------------------------

BEGBSYA={'mo' 'BEGBSYA' 0.0 []}';
ENDBSYA={'mo' 'ENDBSYA' 0.0 []}';

BEGB=  {'mo' 'BEGB'   0.0 []}'; % start of A-line bending
ST22=  {'mo' 'ST22'   0.0 []}'; % beam stopper
MARC=  {'mo' 'MARC'   0.0 []}'; % match point
ENDB=  {'mo' 'ENDB'   0.0 []}'; % end of A-line bending (final emittance)
ST29=  {'mo' 'ST29'   0.0 []}'; % beam stopper
ALWALL={'mo' 'ALWALL' 0.0 []}'; % upstream face of wall that separates A-line tunnel from alcove

% ==============================================================================
% beamlines
% ------------------------------------------------------------------------------

LD105=[D105a,PC10,D105b,IV10,D105c,FV10,D105d,BPM10A,D105e,I10,D105f, ...
  PR10,D105g,A10Y,D105h,I11,D105i];
LD108=[D108a,PC12,D108b,BPM12A,D108c];
LD110=[D110a,PC14,D110b];
LD112=[D112a,SYNC,D112b,PC17,D112c,BPM17,D112d,A18Y,D112e,PR18,D112f, ...
  SP18,D112g];
LD113=[D113a,SL19,D113b,SL10,D113c];
LD114=[D114a,PC20,D114b,PR20,D114c];
LD116=[D116a,ST22,D116b];
LD118=[D118a,PC24,D118b,BPM24,D118c,I24,D118d,C24,D118e];
LD120=[D120a,PC26,D120b,IV26,D120c];
LD123=[D123a,FV28,D123b,BPM28,D123c,I28,D123d,PR28,D123e,A28X,D123f, ...
  A29Y,D123g,ST29,D123h,PC29,D123i,I29,D123j];
LD124=[D124a,A32X,D124b,A33Y,D124c,BPM31,D124d,BPM32,D124e,PR33,D124f, ...
  C37,D124g];

% shared line with BSY

ALINEa=[BEGBSYA, ...
  BKRAPM1a,BKRAPM1b,DAPM1,PCAPM1,DAPM1, ...
  BKRAPM2a,BKRAPM2b,DAPM2a,DSCAPM2,DAPM2b,PCAPM2,DAPM2, ...
  BKRAPM3a,BKRAPM3b,DAPM3,PCAPM3,DAPM3, ...
  BKRAPM4a,BKRAPM4b,DAPM4,PCAPM4,DA01,DPCBSY2,DBTMBSY2,DA02];

% separate line from BSY

ALINEb=[PCBSYA,DA03a,YCBSYA,DA03b,YAGAPM,DA04a, ...
  DBRDAS2a,DBRDAS2b,DA04b,DRCDAS19];

ALINEc=[DA04c,PRBRAM1,DA05,TGTBRAM1,DA06, ...
  BRAM1a,BRAM1b,ROLL2,DAMQ10, ...
  Q10,Q10,LD105, ...
  Q11,Q11,D106, ...
  BEGB, ...
  B11a,B11b,D107, ...
  B12a,B12b,LD108, ...
  B13a,B13b,D109, ...
  B14a,B14b,LD110, ...
  B15a,B15b,D111, ...
  B16a,B16b,LD112, ...
  Q19,Q19,LD113, ...
  Q20,Q20,LD114, ...
  B21a,B21b,D115, ...
  B22a,B22b,LD116, ...
  B23a,B23b,D117, ...
  B24a,B24b,LD118, ...
  B25a,B25b,D119, ...
  B26a,B26b,MARC,ROLL3, ...
  ENDB,LD120, ...
  Q27,Q27,D121, ...
  SQ27p5,SQ27p5,D122, ...
  Q28,Q28,LD123, ...
  Q30,Q30,LD124, ...
  Q38,Q38,D125,ALWALL,DPR2,P3PR2, ...
  ENDBSYA];

ALINE=[ALINEa,ALINEb,ALINEc];

beamLine=struct('Aline',{ALINE'});
