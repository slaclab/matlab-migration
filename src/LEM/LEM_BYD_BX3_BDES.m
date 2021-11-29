function [BDES,Imain,Itrim,pBYD] = LEM_BYD_BX3_BDES(energy)

%   [BDES,Imain,Itrim,pBYD] = LEM_BYD_BX3_BDES(energy);
%
%   Function to calculate BDES of the four BX3 trims, with the 3 BYD's in
%   series on the same supply with the four BX3 main coils, for any beam energy.
%   The polynomials for the BX3's and BYD's include a small sin(a/2)/(a/2) factor
%   to include the arced trajectory through the bends (were measured with a
%   straight probe), and the main coil BDES units are converted here to GeV/c.
%
%   INPUTS:     energy:     The e- beam momentum (GeV/c)
%
%   OUTPUTS:
%               BDES(1):    The BX31 BTRM BDES (in main-coil Amperes)
%               BDES(2):    The BX32 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BX35 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BX36 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the BYD & BX3 bends (main-coil Amperes)
%               Itrim(1):   The current required in the BX31 trim (trim-coil Amperes)
%               Itrim(2):   The current required in the BX32 trim (trim-coil Amperes)
%               Itrim(3):   The current required in the BX35 trim (trim-coil Amperes)
%               Itrim(4):   The current required in the BX36 trim (trim-coil Amperes)
%               pBYD:       The mean polynomial for all magnets in series [A/(GeV/c)]

% ------------------------------------------------------------------------------
% 09-DEC-2008, M. Woodley
%    Suppress call to enhance_plot ... create LEM_BYD_BX3_BDES.m
% ------------------------------------------------------------------------------

% http://www-group.slac.stanford.edu/met/MagMeas/MAGDATA/LCLS/dipole/000602/wiredat.ru2
% (BYD1 dipole measured on June 24, 2008 - run-2, 0 A to 320 A to 0 A)
%---------+---------  ----------+----------  ----------+---------- 
%   Imag    sigImag       BL       sigBL        BL/I     sigBL/I   
%   (A)       (A)        (Tm)       (Tm)       (Tm/A)    (Tm/A)    
%---------+---------  ----------+----------  ----------+---------- 
BYD1 = [
    0.001     0.001     0.00752    0.00001    0.000000   0.000000
   31.931     0.000     0.19063    0.00001    0.005970   0.000000
   64.120     0.000     0.37946    0.00002    0.005918   0.000000
   96.030     0.007     0.56798    0.00004    0.005915   0.000000
  128.174     0.006     0.75703    0.00004    0.005906   0.000000
  159.811     0.002     0.94148    0.00004    0.005891   0.000000
  192.070     0.001     1.12788    0.00007    0.005872   0.000000
  224.098     0.003     1.30993    0.00006    0.005845   0.000000
  256.110     0.003     1.48454    0.00009    0.005796   0.000000
  288.332     0.001     1.64337    0.00006    0.005700   0.000000
  320.137     0.002     1.77766    0.00013    0.005553   0.000000
  288.334     0.001     1.65440    0.00012    0.005738   0.000000
  256.111     0.003     1.49910    0.00015    0.005853   0.000001
  224.097     0.004     1.32291    0.00010    0.005903   0.000000
  192.071     0.001     1.13900    0.00011    0.005930   0.000001
  159.814     0.003     0.95121    0.00006    0.005952   0.000000
  128.179     0.004     0.76557    0.00005    0.005973   0.000000
   96.035     0.006     0.57582    0.00003    0.005996   0.000000
   64.123     0.005     0.38676    0.00002    0.006032   0.000000
   31.932     0.000     0.19608    0.00001    0.006141   0.000000
    0.001     0.000     0.00752    0.00001    0.000000   0.000000];

% http://www-group.slac.stanford.edu/met/MagMeas/MAGDATA/LCLS/dipole/000605/wiredat.ru1
% (BYD2 dipole measured on June 19, 2008 - run-1, 0 A to 320 A to 0 A)
%---------+---------  ----------+----------  ----------+---------- 
%   Imag    sigImag       BL       sigBL        BL/I     sigBL/I   
%   (A)       (A)        (Tm)       (Tm)       (Tm/A)    (Tm/A)    
%---------+---------  ----------+----------  ----------+---------- 
BYD2 = [
    0.000     0.001     0.00788    0.00001    0.000000   0.000000
   31.930     0.000     0.19095    0.00001    0.005980   0.000000
   64.119     0.000     0.38006    0.00002    0.005927   0.000000
   96.030     0.000     0.56892    0.00002    0.005924   0.000000
  128.171     0.007     0.75819    0.00003    0.005915   0.000000
  159.807     0.003     0.94270    0.00002    0.005899   0.000000
  192.067     0.001     1.12903    0.00002    0.005878   0.000000
  224.096     0.003     1.31038    0.00004    0.005847   0.000000
  256.108     0.003     1.48239    0.00003    0.005788   0.000000
  288.327     0.000     1.63673    0.00005    0.005677   0.000000
  320.144     0.002     1.76764    0.00005    0.005521   0.000000
  288.331     0.001     1.64787    0.00002    0.005715   0.000000
  256.108     0.003     1.49772    0.00002    0.005848   0.000000
  224.096     0.002     1.32442    0.00005    0.005910   0.000000
  192.070     0.002     1.14099    0.00003    0.005940   0.000000
  159.814     0.005     0.95304    0.00003    0.005963   0.000000
  128.179     0.008     0.76722    0.00003    0.005986   0.000000
   96.036     0.009     0.57710    0.00001    0.006009   0.000000
   64.125     0.009     0.38773    0.00002    0.006046   0.000000
   31.932     0.000     0.19671    0.00001    0.006160   0.000000
    0.000     0.000     0.00788    0.00001    0.000000   0.000000];

% http://www-group.slac.stanford.edu/met/MagMeas/MAGDATA/LCLS/dipole/000608/wiredat.ru2
% (BYD3 dipole measured on July 7, 2008 - run-2, 0 A to 320 A to 0 A)
%---------+---------  ----------+----------  ----------+---------- 
%   Imag    sigImag       BL       sigBL        BL/I     sigBL/I   
%   (A)       (A)        (Tm)       (Tm)       (Tm/A)    (Tm/A)    
%---------+---------  ----------+----------  ----------+---------- 
BYD3 = [
    0.001     0.001     0.00772    0.00001    0.000000   0.000000
   31.932     0.009     0.19061    0.00002    0.005969   0.000001
   64.124     0.009     0.37945    0.00002    0.005917   0.000000
   96.040     0.005     0.56806    0.00003    0.005915   0.000000
  128.188     0.003     0.75718    0.00004    0.005907   0.000000
  159.826     0.000     0.94164    0.00004    0.005892   0.000000
  192.087     0.004     1.12809    0.00005    0.005873   0.000000
  224.118     0.004     1.30984    0.00005    0.005844   0.000000
  256.134     0.003     1.48345    0.00005    0.005792   0.000000
  288.358     0.001     1.64074    0.00006    0.005690   0.000000
  320.151     0.001     1.77468    0.00006    0.005543   0.000000
  288.361     0.000     1.65215    0.00005    0.005729   0.000000
  256.135     0.003     1.49863    0.00003    0.005851   0.000000
  224.118     0.003     1.32352    0.00005    0.005905   0.000000
  192.090     0.001     1.13966    0.00006    0.005933   0.000000
  159.829     0.002     0.95176    0.00002    0.005955   0.000000
  128.193     0.004     0.76601    0.00002    0.005975   0.000000
   96.046     0.005     0.57608    0.00003    0.005998   0.000000
   64.131     0.005     0.38697    0.00002    0.006034   0.000000
   31.937     0.000     0.19628    0.00001    0.006146   0.000000
    0.001     0.000     0.00773    0.00001    0.000000   0.000000];

ang = 5/3;                                  % bend angle per BYD dipole (deg)
fac = sin(ang*pi/180/2)/(ang*pi/180/2);     % mag. was meas'd with straight probe, so increase int-field by 1/fac (> 1)
f = 1/(ang*pi/180)*2.99792458E8/1E10/fac;   % convert kG-m to GeV/c as BDES units for BX3-BYD main supply

ium  =  1:11;                               % only use "up" (IVBU) data
IBYD =      [BYD1(ium,1)' BYD2(ium,1)' BYD3(ium,1)']; % group all BYD1,2,3 current data to do one (averging) polynomial fit (no BYD trims)
BBYD = 10*f*[BYD1(ium,3)' BYD2(ium,3)' BYD3(ium,3)']; % group all BYD1,2,3 field data to do one (averging) polynomial fit (no BYD trims)

[pBYD,dpBYD] = plot_polyfit(BBYD,IBYD,1,5,'BL','Current','GeV/c','A',1);  % global BYD1,2,3 polynomial (no trims)
%enhance_plot

p1 = [-9.299675E-1 1.712876E+1];      % BDES to I polynomial for BX31 (A/(GeV/c)^n)
p2 = [-9.746283E-1 1.706508E+1];      % BDES to I polynomial for BX32 (A/(GeV/c)^n)
p3 = [-9.600769E-1 1.710969E+1];      % BDES to I polynomial for BX35 (A/(GeV/c)^n)
p4 = [-1.051428    1.713753E+1];      % BDES to I polynomial for BX36 (A/(GeV/c)^n)
ptrim = 0.6;                          % BX3 BTRM linear polynomial coeff. (N_main/N_trim)

v     = [1 energy energy.^2 energy.^3 energy.^4 energy.^5]';

Imain = pBYD'*v;        % current needed in BYD's (A) (no trims on these dump dipoles)

I1    = p1*v(1:2);      % current needed in BX31 (A)
I2    = p2*v(1:2);      % current needed in BX32 (A)
I3    = p3*v(1:2);      % current needed in BX35 (A)
I4    = p4*v(1:2);      % current needed in BX36 (A)

Imain = max([0 Imain]); % can't have negative main currents (A)

BDES(1) = I1 - Imain;   % extra (or less) current needed in BX31 (main-coil Amperes)
BDES(2) = I2 - Imain;   % extra (or less) current needed in BX32 (main-coil Amperes)
BDES(3) = I3 - Imain;   % extra (or less) current needed in BX35 (main-coil Amperes)
BDES(4) = I4 - Imain;   % extra (or less) current needed in BX36 (main-coil Amperes)

Itrim(1) = BDES(1)*ptrim;   % trim current (trim-coil Amperes) to get field in BX31 exact for this BYD energy (A)
Itrim(2) = BDES(2)*ptrim;   % trim current (trim-coil Amperes) to get field in BX32 exact for this BYD energy (A)
Itrim(3) = BDES(3)*ptrim;   % trim current (trim-coil Amperes) to get field in BX35 exact for this BYD energy (A)
Itrim(4) = BDES(4)*ptrim;   % trim current (trim-coil Amperes) to get field in BX36 exact for this BYD energy (A)
