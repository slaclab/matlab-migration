function [BDES, iMain, iTrim] = model_energyBTrim(bMain, energy, str)
%   [BDES,Imain,Itrim] = model_energyBTrim(angl,energy);
%
%   Function to calculate BDES of main supply and its 1 to 4 trims (BXn1,
%   BXn2, BXn3, BXn4) for any bend angle and beam energy.  Since the bends
%   were measured with a straight probe, here we add a BDES reduction
%   factor, sin(theta)/theta, to include the slightly increased path length
%   of the e- arcing through the bends (see "fac").
%
%    INPUTS:    bMain:      The main supply BDES (kG-m) if energy [] otherwise
%                           the abs value of the bend angle per dipole (deg)
%               energy:     The e- beam energy (GeV)
%               str:        The chicane location, 'BXH', 'BX0', 'BX1', 'BX2', 'BX3'
%
%   OUTPUTS:    BDES(1):    The main supply BDES (kG-m) if energy not []
%               BDES(2):    The BXn1 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BXn3 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BXn4 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the main coils (main-coil Amperes)
%               Itrim(1):   The current required in the BXn1 trim (trim-coil Amperes)
%               Itrim(2):   The current required in the BXn3 trim (trim-coil Amperes)
%               Itrim(3):   The current required in the BXn4 trim (trim-coil Amperes)

% ====================================================================================




if ~isempty(energy)
    angl  = bMain;
    c     = 2.99792458e8;                 % light speed (m/s)
    anglR = angl*pi/180;                  % degress to radians
    fac   = sin(anglR+eps)/(anglR+eps);   % rectangular bend Leff factor, <=1 ("eps" added so fac=1 at anglR=0)
    bMain = 1E10*fac/c*energy*anglR;      % BDES needed, including Leff increase as "1/fac" (kG-m)
    if ismember(str,{'BX0' 'DL1'})
        bMain = energy*angl/17.5;
    end
end

isTrim=logical([1 0 1 1]);
switch str
    case {'BXH' 'BCH'}
        p1 = [-1.3000880 2.871939E2 -1.851752E2 6.095439E2 -8.801983E2 4.603718E2];   % BDES to I polynomial for BXH1 (A/kG-m^n)
        p2 = [-0.3783284 2.764696E2 -1.385662E2 5.186152E2 -7.957934E2 4.302896E2];   % BDES to I polynomial for BXH2 (A/kG-m^n)
        p3 = [-0.3702678 2.766265E2 -1.375625E2 5.119401E2 -7.819566E2 4.216546E2];   % BDES to I polynomial for BXH3 (A/kG-m^n)
        p4 = [-0.4765466 2.747545E2 -1.182852E2 4.486741E2 -7.003644E2 3.854325E2];   % BDES to I polynomial for BXH4 (A/kG-m^n) - Sep. 8, '08
        ptrim = 3.00;                                       % BTRM linear polynomial coeff. (N_main/N_trim)
        pMain = p2;
    case {'BX0' 'DL1'}
        p1 = [-0.3185546 1.643291E3 -2.731068E3 4.238484E4 -2.656437E5 6.149535E5];     % BDES to I polynomial for BX01 (A/kG^n)
        p2 = [-0.2668666 1.642822E3 -2.430014E3 3.825926E4 -2.447695E5 5.780101E5];     % BDES to I polynomial for BX02 (A/kG^n)
        p3 = [];
        p4 = [];
        ptrim = 1.0588;                                                                 % BTRM linear polynomial coeff. (N_main/N_trim)
        pMain = p2;
        isTrim = logical([1 0]);
    case {'BX1' 'BC1'}
        p1 = [-1.927670E-1  3.084010E2 -6.47041     5.07454     0 0 0 0 0 0];   % BDES to I polynomial for BX11 (A/kG^n)
        p2 = [-4.004983E-1  3.041257E2  3.190752E1 -1.351165E3  1.178857E4 -4.865154E4  1.094169E5 -1.369621E5  8.930395E4 -2.353094E4];   % BDES to I polynomial for BX12 (A/kG^n) after poles replaced (Nov. 12, 2007)
        p3 = [-3.637365E-1  3.027337E2  1.102520E2 -2.282392E3  1.693391E4 -6.425975E4  1.368579E5 -1.647365E5  1.042660E5 -2.684397E4];   % BDES to I polynomial for BX13 (A/kG^n) after poles replaced (Nov. 12, 2007)
        p4 = [-1.582680E-1  3.076740E2 -3.90914     3.50885     0 0 0 0 0 0];   % BDES to I polynomial for BX14 (A/kG^n)
        ptrim = 28/45;                          % J. Welch, Dec. 9, 2007
        pMain = p2;
        %p2 = [-0.322616 , 307.702 , -4.81872  , 4.25820];   % BDES to I polynomial for BX12 (A/kG^n)
        %p3 = [-0.333022 , 307.866 , -4.07724  , 3.41429];   % BDES to I polynomial for BX13 (A/kG^n)
        %ptrim = 0.63;                           % BTRM linear polynomial coeff. (N_main/N_trim)
    case {'BX2' 'BC2'}
        p1 = [-2.620139E-1  2.323024E1 -3.523976E-1  1.388913E-1 -2.270363E-2  1.345011E-3];   % BDES to I polynomial for BX21 (A/kG^n)
        p2 = [-2.542380E-1  2.317352E1 -3.033643E-1  1.249265E-1 -2.101173E-2  1.271024E-3];   % BDES to I polynomial for BX22 (A/kG^n)
        % Original
        %p3 = [-2.575559E-1  2.333321E1 -3.463651E-1  1.347859E-1 -2.183821E-2  1.289172E-3];   % BDES to I polynomial for BX23 (A/kG^n)
        %p4 = [-2.855774E-1  2.319316E1 -4.168129E-1  1.512411E-1 -2.365816E-2  1.369928E-3];   % BDES to I polynomial for BX24 (A/kG^n)
        % After BX23 repair, fitting orbit out of BX2
        %p3 = [0.0292311855465144,22.6837302734911,-0.3463651,0.1347859,-0.02183821,0.001289172];
        %p4 = [-0.289293051514795,23.1178534098963,-0.4168129,0.1512411,-0.02365816,0.001369928]; 
        % After also including upstream steering effects
        %p3 = [  0.083585233165558  22.586923984442890  -0.3463651   0.1347859  -0.02183821 0.001289172];
        %p4 =  [-0.363939646752891  23.276535919929959  -0.4168129   0.1512411  -0.02365816 0.001369928];
        % One-point recalibration after relocation of quad in front of BC2
        p3 =   [-0.265760432535308  22.565930365695806  -0.3463651   0.1347859  -0.02183821 0.001289172];
        p4 =   [-0.326169948755355  23.253779647380899  -0.4168129   0.1512411  -0.02365816 0.001369928];
        ptrim = 2.2917;                                       % BTRM linear polynomial coeff. (N_main/N_trim)
        pMain = p2;
    case {'BX3' 'DL2'}
        par = [0.00003804891  -0.001880491   0.03493854 ...
             -0.285094  13.65292  -1.412433];% BDES to I polynomial for BYDs
        p1 = [-1.916925  13.61884  -0.05508877 ... % BDES to I polynomial for BX31 (A/(GeV/c)^n)
           0.003029748  -0.00007800216   0.00000078067]; 
        p2 = [-2.013111  13.50199  -0.05991272 ... % BDES to I polynomial for BX32 (A/(GeV/c)^n)
           0.003355768  -0.00009043783   0.000001001041];
        p3 = [-2.067444  13.34656  -0.05621299 ... % BDES to I polynomial for BX35 (A/(GeV/c)^n)
           0.003038784  -0.00007785784   0.0000007961515];
        p4 = [-1.495717  13.76929  -0.07516737 ... % BDES to I polynomial for BX36 (A/(GeV/c)^n)
           0.005479599  -0.0001901449   0.000002573463];
        ptrim = 0.6;                          % BX3 BTRM linear polynomial coeff. (N_main/N_trim)
        pMain = fliplr(par);
        isTrim = logical([1 1 1 1]);
    case {'BX3B' 'DL2B'}
        pMain = [-0.341366877  12.93442626  -0.108828347   0.014709484  -0.000834029   0.0000176]; %BDES to I polynomial for BYD1B
        p1 = [-1.084169961  12.99189637  -0.057942915 0.005024955  -0.000234992   0.00000498];  % BDES to I polynomial for BX31B (A/(GeV/c)^n)
        p2 = [-1.042520643  13.00644459  -0.045829903 0.002336986   0.00000461  -0.00000214];  % BDES to I polynomial for BX32B (A/(GeV/c)^n)
        p3 = [0 0 0 0 0 0]; % Only two bends
        p4 = [0 0 0 0 0 0]; % Only two bends
        ptrim = 1.461293;
        isTrim = logical([1 1 0 0]);
    case {'BCSS' 'HXRSS'}
        pvList={'BEND:UND1:1630'; 'BEND:UND1:1640'; 'BEND:UND1:1660'; 'BEND:UND1:1670'};
        lcaPut(strcat(pvList,':IVB.UDF'),0);
        coeffs=lcaGet(strcat(pvList,':IVB'));
        p1 = coeffs(1,:);   % BDES to I polynomial for BXHS1 (A, A/kG-m, A/kG-m^2, ...)
        p2 = coeffs(2,:);   % BDES to I polynomial for BXHS2 (A, A/kG-m, A/kG-m^2, ...)
        p3 = coeffs(3,:);   % BDES to I polynomial for BXHS3 (A, A/kG-m, A/kG-m^2, ...)
        p4 = coeffs(4,:);   % BDES to I polynomial for BXHS4 (A, A/kG-m, A/kG-m^2, ...)
        ptrim = 68.5;       % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
        pMain = p2;
    case {'SXRSS'}
        pvList={'BEND:UNDS:3510'; 'BEND:UNDS:3530'; 'BEND:UNDS:3550'; 'BEND:UNDS:3570'};
        lcaPut(strcat(pvList,':IVB.UDF'),0);
        coeffs=lcaGet(strcat(pvList,':IVB'));
        p1 = coeffs(1,:);   % BDES to I polynomial for BCXSS1 (A, A/kG-m, A/kG-m^2, ...)
        p2 = coeffs(2,:);   % BDES to I polynomial for BCXSS2 (A, A/kG-m, A/kG-m^2, ...)
        p3 = coeffs(3,:);   % BDES to I polynomial for BCXSS3 (A, A/kG-m, A/kG-m^2, ...)
        p4 = coeffs(4,:);   % BDES to I polynomial for BCXSS4 (A, A/kG-m, A/kG-m^2, ...)
        ptrim = 68.5;       % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
        pMain = p2;
    case {'XLEAP'}
        pvList={'BEND:LTU1:866'; 'BEND:LTU1:868'; 'BEND:LTU1:870'; 'BEND:LTU1:872'};
        lcaPut(strcat(pvList,':IVB.UDF'),0);
        coeffs=lcaGet(strcat(pvList,':IVB'));
        p1 = coeffs(1,:);   % BDES to I polynomial for BXSS1 (A, A/kG-m, A/kG-m^2, ...)
        p2 = coeffs(2,:);   % BDES to I polynomial for BXSS2 (A, A/kG-m, A/kG-m^2, ...)
        p3 = coeffs(3,:);   % BDES to I polynomial for BXSS3 (A, A/kG-m, A/kG-m^2, ...)
        p4 = coeffs(4,:);   % BDES to I polynomial for BXSS4 (A, A/kG-m, A/kG-m^2, ...)
        ptrim = 38.4;       % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
        pMain = p2;
        
end
p=fliplr([p1;p2;p3;p4]); % Make Matlab polynomial order
nTrim=size(p,1);

iMain = polyval(pMain(end:-1:1),bMain); % current needed in BXn2 (A) (no trim on BXn2 - use this for main supply)
iMain = max(0,iMain); % can't have negative main currents (A)

bOff=zeros(nTrim,1);

if iMain == 0 && ~all(isTrim) && ismember(str,{'BX1' 'BC1'})
%   BDES(3) = BDES(3)+p2(1);  % if BXn2 remnant is not compensated, add BXn2 remnant to BXn3 (A)
    bOff(3) = bMain + pMain(1)/pMain(2);    % J. Welch, Dec. 9, 2007
end

if ismember(str,{'BCSS' 'HXRSS'})
%    bOff(1,:) = polyval([-0.001246952066002  0.004888910006052  0.000023532228580],bMain); % (Measured fudge 3/26/12 -HL)
%    bOff(4,:) = polyval([-0.000043769003605  0.002396326791752 -0.000003031903106],bMain); % (Measured fudge 3/26/12 -HL)
%    bOff(1,:) = bOff(1,:)+polyval([0.000100426244060 -0.001640795321436 -0.000008289898936],bMain); % (Measured fudge 3/26/12 -HL)
%    bOff(4,:) = bOff(4,:)+polyval([0.000146281232809  0.000264115196680  0.000016724421921],bMain); % (Measured fudge 3/26/12 -HL)
%    bOff(1,:) = bOff(1,:)+polyval([-0.108328148200166  0.608148228707427  0.007794665984392]*1e-3,bMain); % (Measured fudge 3/26/12 -HL)
%    bOff(4,:) = bOff(4,:)+polyval([0.001190152065322 -0.316352962279092 -0.004561531027326]*1e-3,bMain); % (Measured fudge 3/26/12 -HL)
    bOff(1,:) = polyval([-0.001254853970142   0.003856262913323   0.000023036995628],bMain); % (Measured fudge 3/26/12 -HL)
    bOff(4,:) = polyval([0.000103702381269   0.002344089026153   0.000009130987788],bMain); % (Measured fudge 3/26/12 -HL)
end

if ismember(str,{'SXRSS'})
%    bOff(1,:) = -polyval([-0.001815479249768   0.001243412052621   0.000238962594457],bMain); % (Measured fudge 9/24/13 -HL)
%    bOff(4,:) = -polyval([-0.002065065995651   0.002876433779041   0.000583345375528],bMain); % (Measured fudge 9/24/13 -HL)
    bOff(1,:) = -polyval(1.0e-03*[-0.761123437213851   0.416926515645104   0.185687230696375],bMain); % (Measured fudge 9/24/13 -HL)
    bOff(3,:) =  polyval([-0.002283370311642   0.001250779546935   0.000557061692089],bMain); % (Measured fudge 9/24/13 -HL)
    bOff(4,:) = -polyval([-0.000433564583510   0.001375048911181   0.000683191125070],bMain); % (Measured fudge 9/24/13 -HL)
%    bOff(1,:) = bOff(1,:)-polyval([-0.004601314812232   0.028854920984860  -0.067740350227287   0.072940207512270  -0.034123377927459   0.004641538674457   0.000073583105158],bMain); % (Measured fudge 3/26/12 -HL)
%    bOff(4,:) = bOff(4,:)-polyval([-0.001926407562100   0.011142481935263  -0.025012295383084   0.027520846892072  -0.014451163001203   0.002242412561180   0.000238152506252],bMain); % (Measured fudge 3/26/12 -HL)
    bOff(1,:) = bOff(1,:)-polyval([-0.002062574420324   0.012898720478231  -0.029904620302491   0.031157561488558  -0.013590635205716   0.001742507995570  -0.000079682970914],bMain);
    bOff(3,:) = bOff(3,:)+polyval([-0.004399633817511   0.026241087813191  -0.058365115754246   0.058676111621590  -0.024435991283630   0.002441209436189  -0.000057190478200],bMain);
    bOff(4,:) = bOff(4,:)-polyval([0.001192059628974  -0.008303382414334   0.020899163435485  -0.023197715229390   0.010890609555678  -0.001857543033682   0.000121238956362],bMain);
%    bOff(1,:) = bOff(1,:)-polyval([-0.000963768992056   0.006734152287015    -0.017502665704089   0.021189335720621  -0.012301762641900    0.002995734798954  -0.000150445140667],bMain); % Made things worse (SXRSSScan--2013-10-08-144842.mat)
%    bOff(3,:) = bOff(3,:)+polyval([0     0     0     0     0     0     0],bMain);
%    bOff(4,:) = bOff(4,:)-polyval([-0.001795828653806   0.011328933970503  -0.026516489881639   0.028089277773913  -0.012859239941921   0.001881590898436   0.000080387161455],bMain)
end



if ismember(str,{'XLEAP'})
    bOff(1,:) = bOff(1,:)-polyval([0 0 0 0 0 0 0],bMain);
    bOff(3,:) = bOff(3,:)+polyval([0 0 0 0 0 0 0],bMain);
    bOff(4,:) = bOff(4,:)-polyval([0 0 0 0 0 0 0],bMain);
end

iBX=zeros(nTrim,1);
for j=find(isTrim)
    iBX(j,1) = polyval(p(j,:),bMain+bOff(j)); % current needed in BXnj (A)
end
iBX(~isTrim)=[];

%iBX(1,1) = polyval(p(1,:),bMain); % current needed in BXn1 (A)
%iBX(2,1) = polyval(p(3,:),bDes3); % current needed in BXn3 (A)
%iBX(3,1) = polyval(p(4,:),bMain); % current needed in BXn4 (A)

BDES = iBX - iMain;   % extra (or less) current needed in BXn1,3,4 (main-coil Amperes)

if iMain == 0 && ~all(isTrim) && ~ismember(str,{'BX1' 'BC1' 'BX0' 'DL1'})
   BDES(2) = BDES(2)+p2(1);  % if BXn2 remnant is not compensated, add BXn2 remnant to BXn3 (A)
end

if ismember(str,{'BX1' 'BC1'})
    BDES(1) = 1.16*BDES(1); % (1.16 factor to get BPMS:LI21:278:X at zero - 3/28/09 -PE)
end

if ismember(str,{'BCSS' 'HXRSS'})
%    BDES(3) =.0039*bMain+4e-7; % (factor to get flat und orbit - 11/6/11 -JR)
end

iTrim = BDES*ptrim;   % trim current (trim-coil Amperes) to get field in BXn1,3,4 = field in BXn2 (A)

if ~isempty(energy) && ~all(isTrim) % Prepend bMain for chicanes
    BDES=[bMain BDES'];
end
