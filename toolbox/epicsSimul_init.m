function epicsSimul_init(varargin)
%EPICSSIMUL_INIT
%  EPICSSIMUL_INIT() initializes all PVs for epics simulation.

% Features:

% Input arguments:
%    OPTS: options struct

% Output arguments: none

% Compatibility: Version 2007b, 2012a, 2014b
% Called functions: epicsSimul_status, getSystem, model_init,
%                   util_parseOptions, lcaPut, model_nameConvert,
%                   profmon_setup, control_energyNames, control_magnetSet,
%                   control_phaseSet, control_klysName,
%                   control_klysStatSet, control_ampSet, model_rMatModel,
%                   control_chargeName, control_emitSet, model_twissGet

% Author: Henrik Loos, SLAC
%         Sonya Hoobler, SLAC 17-Apr-2017, Removed obsolete BSY area name
%                        'BSY0' and added new names 'CLTH' and 'BSYH'
%         Greg White, SLAC 5-Apr-2016, Added MOTR_ENABLED_STS for FWS
% 

% --------------------------------------------------------------------

global epicsUseAida
epicsUseAida=0;

%{
% Set default options.
optsdef=struct( ...
    'all',1 ...
);
%}

% Make sure Aida is initialized to avoid javaaddpath clearing globals later.
aidainit;

% Set simulation state.
epicsSimul_status(1);

% Add lcaWrapper path.
pLca='/home/physics/loos/matlab/lcaWrapper';
if exist(pLca,'dir'), addpath(pLca);end

% Clear simulation.
epicsSimul_clear;

% Check if lcaGet points to simulation.
lcaGet('');

% Reset accelerator.
getSystem('');

% Init model system.
model_init('source','MATLAB','online',0);

% Use default options if OPTS undefined.
%opts=util_parseOptions(varargin{:},optsdef);

% Set global simulation parameters.
charge=6.2418e9; % Nel

% Set profile monitor properties.
pvList=model_nameConvert({'CTHD' 'YAGS' 'OTRS' 'PROF' 'EXPT' 'MIRR'},'MAD','*');
props={'N_OF_COL' 1392; ...
       'N_OF_ROW' 1040; ...
       'N_OF_BITS' 12; ...
       'RESOLUTION' 4.65; ...
       'ROI_X' 498; ...
       'ROI_Y' 316; ...
       'ROI_XNP' 400; ...
       'ROI_YNP' 400; ...
       'X_ORIENT' 1; ...
       'Y_ORIENT' 1; ...
       'X_RTCL_CTR' 700; ...
       'Y_RTCL_CTR' 500; ...
       'FLT1_OUT' 1; ...
       'FLT1_IN' 0; ...
       'FLT2_OUT' 1; ...
       'FLT2_IN' 0; ...
       'OUT_LMTSW' 1; ...
       'IN_LMTSW' 1; ...
       'TRIGGER_DAQ' 0; ...
       'X_BM_CTR' 0; ...
       'Y_BM_CTR' 0; ...
      };
setProp(pvList,props);
props={'PNEUMATIC' 'IN'; ...
      };
setProp(pvList,props);
profmon_setup;

% GUNB Camera (other new cameras may be similar...)
pvList=model_nameConvert({'YAG01B','OTRDMP'},'MAD');
props = {'ROI:MaxSizeX_RBV' 1024;...
    'ROI:MaxSizeY_RBV' 1024;...
    'BitsPerPixel_RBV' 12;...
    'RESOLUTION' 35;...
    'ROI:MinX_RBV' 0;...
    'ROI:MinY_RBV' 0;...
    'ROI:SizeX_RBV' 1024;...
    'ROI:SizeY_RBV' 1024;...
    'X_ORIENT' 1;...
    'Y_ORIENT' 0;...
    'X_RTCL_CTR' 524;...
    'Y_RTCL_CTR' 527;...
    'ROI:BinX' 1;...
    'ROI:BinY' 1;...
    'ROI:MinX' 0;...
    'ROI:MinY' 0;...
    'ROI:SizeX' 1024;...
    'ROI:SizeY' 1024};
setProp(pvList,props);
props={'PNEUMATIC' 'IN'; ...
      };
setProp(pvList,props);

% Laser camera properties.
pvList=model_nameConvert('CAMR','MAD','*');
props={'N_OF_COL' 640; ...
       'N_OF_ROW' 480; ...
       'N_OF_BITS' 8; ...
       'RESOLUTION' 9; ...
      };
setProp(pvList,props);

%Wire scanner properties.
pvList=model_nameConvert('WIRE','MAD','*');
props={'USEXWIRE' 1; ...
       'USEYWIRE' 0; ...
       'USEUWIRE' 0; ...
       'MOTR.VMAX' 850; ...
       'MOTR.VBAS' 250; ...
       'MOTR.LLM' -20000; ...
       'MOTR.HLM' 28000; ...
       'SCANPULSES' 150; ...
       'XWIREINNER' 10000; ...
       'XWIREOUTER' 13000; ...
       'YWIREINNER' -15000; ...
       'YWIREOUTER' -12000; ...
       'UWIREINNER' -1000; ...
       'UWIREOUTER' 1000; ...
       'INSTALLANGLE' 45; ...
       'SCANTOCENTER' 0; ...
       'XWIREOFFSET' 11500; ...
       'YWIREOFFSET' -13500; ...
       'UWIREOFFSET' 0; ...
       'MOTR_ENABLED_STS' 1; ...
      };
setProp(pvList,props);
props={'SCANTEXT' 'READY to START Wire Scan'};
setProp(pvList,props);

%BFW properties.
pvList=model_nameConvert('BFW','MAD','*');
props={'camsMovingM' 0; ...
       'XOFFSET' -500; ...
       'YOFFSET' -500; ...
      };
setProp(pvList,props);

%UND properties.
pvList=model_nameConvert('USEG','MAD','UNDH');
props={'LOCATIONSTAT' 'ACTIVE-RANGE'; ...
      };
setProp(pvList,props);
props={'INSTALTNSTAT' 1; ...
       'XOUTCORSTAT' 0; ...
       'XACT' 0; ...
       'XDES' 0; ...
       'TMXPOSC' 0; ...
       'TM1MOTOR.RBV' 0; ...
       'TM2MOTOR.RBV' 0; ...
       'CAMSMOVINGM' 0; ...
      };
setProp(pvList,props);

% BPM properties.
pvList=model_nameConvert({'BPMS' 'RFBU'},'MAD','*');
props={'X' 0; ...
       'Y' 0; ...
       'TMIT' charge; ...
       'TMIT1H' charge; ...
       'TMITBR' charge; ...
      };
setProp(pvList,props);

% SXRSS properties.
% pvList0=model_nameConvert({'SLIT' 'GRAT' 'MIRR' 'BOD'},'EPICS','UNDS');
% pvList=[strcat(pvList0(1:5),':',{'Y';'X';'X';'X';'X'});pvList0(6:7)];
% props={'LOCATIONSTAT' 'OUT'; ...
%       };
% setProp(pvList,props);
% 
% pvList=[strcat(pvList0([1 1 2 2 3 4 5 5 5]),':',{'X';'Y';'X';'Y';'P';'X';'X';'P';'O'});pvList0(6:7)];
% props={'DES' 0; ...
%        'ACT' 0; ...
%       };
% setProp(pvList,props,[0 -4 50 0 -30 50 50 0 0 0 0]);
% %MOTOR.TWV
% 
% props={'IN_LIMIT_MPS.SEVR' 0; ...
%       };
% setProp(pvList0,props);

lcaPut('BEND:UNDS:940:STATE','OFF');
lcaPut('BEND:UNDS:940:CTRLSTATE','Done');
lcaPut('MPS:UNDS:950:SXRSS_MODE','SASE Mode');
lcaPut('GATT:FEE1:310:R_ACT',0.99);
lcaPut(strcat('HVCH:FEE1:',{'241';'242';'361';'362'},':VoltageSet'),[700;850;650;900]);
lcaPut(strcat('DIAG:FEE1:202:',{'241';'242';'361';'362'},':Data'),30000-25000*exp(-((1:500)-200).^2/2/50^2));

lcaPut(strcat('SIOC:SYS0:ML01:AO8',{'20';'21';'26';'27';'31';'32';'38';'39';'01';'02';'24';'25'}),0);
lcaPut(strcat('SIOC:SYS0:ML00:AO',{'470';'627';'195';'500'}),0);
lcaPut(strcat('SIOC:SYS0:ML01:AO',{'813';'812';'874'}),0);
lcaPut(strcat('SIOC:SYS0:ML01:AO',{'810'}),0);
lcaPut(strcat('SIOC:SYS0:ML01:AO',{'856';'809';'900'}),0);
lcaPut(strcat('SIOC:SYS0:ML01:AO8',{'57';'59';'60';'65';'66';'67';'68';'69';'70';'71'}),[1 .5 .5 0 1 0 0 0 0 0]');

pvList=model_nameConvert({'BXSS1' 'BXSS2' 'BXSS3' 'BXSS4'}');
lcaPut([strcat(pvList,':IDES');strcat(pvList,':IACT')],0);
lcaPut(strcat('VPIO:UND1:9',{'3';'6'},'4:PMON'),1e-9);
lcaPut(strcat('VGXX:UND1:9',{'3';'6'},'6:P'),1e-9);

% Gain length
lcaPut('VFC:FEE1:E207:PSTAT',0);
lcaPut(strcat('HVCH:FEE1:36',{'1';'2'},':STATUS'),'ON');

% Simulation PVs
lcaPut('EMIT',1e-6); % Emittance
lcaPut('CHARGE',charge*1.6021e-10); % Charge [nC]
lcaPut('DELTA',5e-4); % Energy spread []
lcaPut('TAU',400e-6); % Bunch length [m]

lcaPut('BEND:IN20:751:BDES',0.135); % Initial beam energy
lcaPut('BEND:DMPH:400:BDES',13.64); % Final beam energy
lcaPut('USEG:IN20:466:KDES',1.3852); % LH_UND K design
lcaPut('SIOC:SYS0:ML00:AO876',1); % Laser heater on
lcaPut('SIOC:SYS0:ML00:AO877',1); % Undulator position
lcaPut('SIOC:SYS0:ML00:AO878',800e-6); % Bunch length
lcaPut('SIOC:SYS0:ML00:AO879',0); % Unused
lcaPut(strcat('ACCL:',{'IN20:350' 'LI21:1' 'LI22:1' 'LI25:1'}',':FUDGELAST'),1);
model_init('simul',1);
model_energySetPoints([0.006 0.135 0.250 4.300 8.0], 1:5, 'CU_HXR');
model_init('simul',0);
model_energySetPoints([0.006 0.135 0.250 4.300 8.0], 1:5, 'CU_HXR');
lcaPut('LI11:LGPS:3420:BACT',1.1); % FACET chicane state
lcaPut(strcat('VX00:LEMG:',{'4';'5'},':EINI'),1.19); % FACET initial energies
lcaPut(strcat('VX00:LEMG:',{'4';'5'},':EEND'),[21 0;9 21]); % FACET end energies
lcaPut(strcat('VX00:LEMG:',{'4';'5'},':FUDG'),[1 0;1 1]); % FACET fudges
lcaPut('SIOC:SYS2:ML01:AO001',750e-6); % GUNB kin. energy, to change w/ LCLS2 LEM

% A-Line stuff.
pvList=model_nameConvert({'QUAS'},'MAD','AB01');
props={'PSCP' 0.01; ...
      };
setProp(pvList,props,[1010 1090 1950 2050 2750 2850 3050 3850]);

pvList=model_nameConvert({'BNDS'},'MAD','AB01');
props={'PSCP' 1100; ...
      };
setProp(pvList,props);
props={'PSCP' 140; ...
      };
setProp(pvList(ismember(pvList,{'B1' 'B2'})),props);

% SCP LGPS.
pvList=model_nameConvert({'LGPS'},[],'*');
val=[ ...
      140  200  NaN  NaN  NaN  NaN; ... % (AB01:140)
      150    0    0    0    0    0; ... % (AB01:150)
      190    0    0    0    0    0; ... % (AB01:190)
     1010  NaN  NaN  NaN  NaN  NaN; ... % (AB01:1010)
     1090  NaN  NaN  NaN  NaN  NaN; ... % (AB01:1090)
     1950  NaN  NaN  NaN  NaN  NaN; ... % (AB01:1100)
     2050  NaN  NaN  NaN  NaN  NaN; ... % (AB01:2050)
     2750  NaN  NaN  NaN  NaN  NaN; ... % (AB01:2750)
     2850  NaN  NaN  NaN  NaN  NaN; ... % (AB01:2850)
     3050  NaN  NaN  NaN  NaN  NaN; ... % (AB01:3050)
     3850  NaN  NaN  NaN  NaN  NaN; ... % (AB01:3850)
      985  NaN  NaN  NaN  NaN  NaN; ... % (LI01:5) BENDs
       10   20   80  NaN  NaN  NaN; ... % (DR12:2) BENDs
      410  NaN  NaN  NaN  NaN  NaN; ... % (DR12:28) BENDs
      212  214  218  220  NaN  NaN; ... % (LI02:216) BENDs
     3420 3440 3460 3480 2440 2460; ... % (LI11:3420) BENDs
     1990 3000  NaN  NaN  NaN  NaN; ... % (LI20:1990) BENDs
     2061 2441  NaN  NaN  NaN  NaN; ... % (LI20:2160) QUADs
     2061  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2161) LGPS
     2110 2390  NaN  NaN  NaN  NaN; ... % (LI20:2110) BENDs
     2131 2371  NaN  NaN  NaN  NaN; ... % (LI20:2130) QUADs
     2131  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2131) LGPS
     2145  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2145) SEXT
     2151 2161 2341 2351  NaN  NaN; ... % (LI20:2150) QUADs
     2151 2161  NaN  NaN  NaN  NaN; ... % (LI20:2151) QUADs
     2165  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2165) SEXT
     2195 2225  NaN  NaN  NaN  NaN; ... % (LI20:2195) SEXTs
     2201 2211 2221 2281 2291 2301; ... % (LI20:2200) QUADs
     2201 2211 2221  NaN  NaN  NaN; ... % (LI20:2201) QUADs
     2231 2262  NaN  NaN  NaN  NaN; ... % (LI20:2230) QUADs
     2231  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2231) LGPS
     2240 2260  NaN  NaN  NaN  NaN; ... % (LI20:2240) BENDs
     2251  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2251) QUAD
     2262  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2262) QUAD
     2275 2305  NaN  NaN  NaN  NaN; ... % (LI20:2275) Sexts
     2281 2291 2301  NaN  NaN  NaN; ... % (LI20:2281) QUADs
     2335  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2335) SEXT
     2341 2351  NaN  NaN  NaN  NaN; ... % (LI20:2341) QUADs
     2365  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2365) SEXT
     2371  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2371) QUAD
     2420  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2420) BENDs
     2441  NaN  NaN  NaN  NaN  NaN; ... % (LI20:2441) QUAD
     3011  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3011) QUAD
     3031 3041 3051  NaN  NaN  NaN; ... % (LI20:3031) QUADs
     3091 3111  NaN  NaN  NaN  NaN; ... % (LI20:3091) QUADs
     3141  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3141) QUAD
     3151  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3151) QUAD
     3204  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3204) QUAD
     3261  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3261) QUAD
     3311  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3311) QUAD
     3330  NaN  NaN  NaN  NaN  NaN; ... % (LI20:3330) BEND
    ];
val2=val;val2(~isnan(val2))=64;val=[val2 val];
val(:,[1:2:end 2:2:end])=val;
lcaPut(strcat(pvList([1:6 8:14 16 19:end]),':MAGS'),val);

val=[ ...
     [1100 1200 1300 1400 1500 1600 2100 2200 2300 2400 2500 2600  NaN; ...
       160  210  220  230  240  250  260  270  280  290  310  320  330; ...
       190  200  250  300  310  370  380  420  430  480  510  640  680; ...
        54  184  224  244  254  274  314  344  384  404  434  464  544] ...
     [ NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN; ...
       340  350  360  370  380  390  440  560  610  620  630  640  650; ...
       690  790  191  201  251  301  311  371  381  421  431  481  491; ...
       564  664  744  774  844  864  NaN  NaN  NaN  NaN  NaN  NaN  NaN] ...
     [ NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN; ...
       660  670  680  690  710  720  730  730  740  750  760  770  780  790  840; ...
       511  571  641  681  711  791  811  871  985  NaN  NaN  NaN  NaN  NaN  NaN; ...
       NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN  NaN] ...
    ];
val2=val;val2(~isnan(val2))=64;val=[val2 val];
val(:,[1:2:end 2:2:end])=val;
lcaPut(strcat(pvList([7 15 17 18]),':MAGS'),val);

% FACET QUAS PSCP.
pvList=model_nameConvert({'QUAS'},'MAD','LI20');
props={'PSCP' 0.01; ...
      };
setProp(pvList,props,[2061 2131 2151 2151 2201 2201 2201 2231 2251 2262 2281 2281 2281 2341 2341 2371 2441 3011 3031 3031 3031 3091 3091 3141 3151 3204 3261 3311]);

% Magnets.
pvList=model_nameConvert({'XCOR' 'YCOR'},'MAD','*');
props={'BMAX' 0.01; ...
       'BDES' 0; ...
       'BACT' 0; ...
       'BCTRL' 0; ...
      };
setProp(pvList,props);

pvList=model_nameConvert({'QUAD'},'MAD','*'); % LCLS Injector default
props={'BMAX'  20; ...
       'BMIN' -20; ...
      };
setProp(pvList,props);

pvList={'CQ01' 'SQ01' 'QB' 'QG02' 'QG03' 'CQ11' 'SQ13' 'CQ12' ...
        'Q24601' 'Q24701A' 'Q24701B' 'QM21' 'CQ21' 'CQ22' 'QM22' 'Q24901A' 'Q24901B' ...
        'Q50Q1' 'Q50Q2' 'Q50Q3' 'QSM1' 'Q5' 'Q6' 'QA0' ...
        'QVM1' 'QVM2' 'QVB1' 'QVB2' 'QVB3' 'QVM3' 'QVM4' 'CQ31' 'CQ32' 'QEM3V' 'QUE2'...
        };
props={'BMAX'; ...
       'BMIN'; ...
      };
setProp(pvList,props,[[ 0.015  0.015 16.5  4.8  4.8  1.2  0.87  1.2; ...
                       -0.015 -0.015    0 -4.8 -4.8 -1.2 -0.87 -1.2] ...
                      [100    0    0 200  2.1  2.1    0 100 100; ...
                         0 -100 -100   0 -2.1 -2.1 -200   0   0] ...
                      [  0 41   0  10.2   0 80   0; ...
                       -41  0 -41 -10.2 -80  0 -80] ...
                      [-0.88  250 -0.91  130 -0.91  250 -1.11  5  5  15   40; ...
                        -250 1.03  -130 0.91  -130 0.87  -250 -5 -5 -15 0.26] ...
                     ]);

pvList={'Q21201' 'Q21301' 'Q21501' 'Q21701' 'Q21901' ...
        'Q22301' 'Q22501' 'Q22701' 'Q22901' ...
        'Q23301' 'Q23501' 'Q23701' 'Q23901' ...
        'Q24301' 'Q24501' ...
        'Q25301' 'Q25501' 'Q25701' 'Q25901' ...
        'Q26301' 'Q26501' 'Q26701' 'Q26901' ...
        'Q27301' 'Q27501' 'Q27701' 'Q27901' ...
        'Q28301' 'Q28501' 'Q28701' 'Q28901' ...
        'Q29301' 'Q29501' 'Q29701' 'Q29901' ...
        };
props={'BMAX' 0; ...
       'BMIN' -21.384; ...
      };
setProp(pvList,props);

pvList={'Q21401' 'Q21601' 'Q21801' ...
        'Q22201' 'Q22401' 'Q22601' 'Q22801' ...
        'Q23201' 'Q23401' 'Q23601' 'Q23801' ...
        'Q24201' 'Q24401' ...
        'Q25201' 'Q25401' 'Q25601' 'Q25801' ...
        'Q26201' 'Q26401' 'Q26601' 'Q26801' ...
        'Q27201' 'Q27401' 'Q27601' 'Q27801' ...
        'Q28201' 'Q28401' 'Q28601' 'Q28801' ...
        'Q29201' 'Q29401' 'Q29601' 'Q29801' ...
        };
props={'BMAX' 21.384; ...
       'BMIN' 0; ...
      };
setProp(pvList,props);

pvList={'Q30301' 'Q30501' 'Q30701'};
props={'BMAX' 0; ...
       'BMIN' -106.28; ...
      };
setProp(pvList,props);

pvList={'Q30201' 'Q30401' 'Q30601' 'Q30801'};
props={'BMAX' 106.28; ...
       'BMIN' 0; ...
      };
setProp(pvList,props);

pvList={'QDL31' 'QDL32' 'QDL33' 'QDL34'};
props={'BMAX' 112; ...
       'BMIN' 1.11; ...
      };
setProp(pvList,props);

pvList={'QT11' 'QT13' 'QT21' 'QT23' 'QT31' 'QT33' 'QT41' 'QT43'};
props={'BMAX' -0.99; ...
       'BMIN' -140; ...
      };
setProp(pvList,props);

pvList={'QT12' 'QT22' 'QT32' 'QT42'};
props={'BMAX' 250; ...
       'BMIN' 0.96; ...
      };
setProp(pvList,props);

pvList={'QEM1' 'QEM2' 'QEM3' 'QEM4'};
props={'BMAX' 112; ...
       'BMIN' -112; ...
      };
setProp(pvList,props);

pvList={'QE31' 'QE33' 'QE35'};
props={'BMAX' 25; ...
       'BMIN' 0.305; ...
      };
setProp(pvList,props);

pvList={'QE32' 'QE34' 'QE36'};
props={'BMAX' -0.305; ...
       'BMIN' -25; ...
      };
setProp(pvList,props);

pvList={'QUM1' 'QUM2' 'QUM3' 'QUM4'};
props={'BMAX' 100; ...
       'BMIN' -100; ...
      };
setProp(pvList,props);

pvList=model_nameConvert({'QUAD'},'MAD',{'UNDH'});
props={'BMAX' 40; ...
       'BMIN' -40; ...
      };
setProp(pvList,props);

pvList={'QUE1' 'QDMP1' 'QDMP2'};
props={'BMAX' -0.26; ...
       'BMIN' -40; ...
      };
setProp(pvList,props);

pvList=model_nameConvert({'XCOR' 'YCOR' 'QUAD' 'BEND' 'KICK'},'MAD',{'CLTH' 'BSYH' 'LTU0' 'LTU1' 'LTUH' 'UNDH' 'DMPH'});
props={'EDES' 13.64; ...
      };
setProp(pvList,props);

pvList=model_nameConvert({'QUAD'},'MAD',{'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30'});
eDes=interp1([1 numel(pvList)-7],[4.3 13.64],1:numel(pvList),[],0);
bDes=interp1([1 numel(pvList)-7],[6.25 19.8],1:numel(pvList),[],0);
bDes=-bDes.*(-1).^(1:numel(pvList));
bDes30=bDes(end-13:end-7);
bDes(end-6:end)=sign(bDes30).*(abs(bDes30)-5.1);
bDes(end-13:end-7)=sign(bDes30).*5.1;
n=control_energyNames(pvList);
lcaPutSmart(strcat(n,':EDES'),eDes');
control_magnetSet(pvList,bDes');

pvList=model_nameConvert({'QUAD'},[],'LI30');
val=[ ...
     0 0 0 0    0.0000   -0.0000    0.0002   -0.0046    1.8318   -0.3567; ...
     0 0 0 0   -0.0000   -0.0000   -0.0002   -0.0046   -1.8318   -0.3567; ...
     0 0 0 0    0.0000   -0.0000    0.0002   -0.0046    1.8318   -0.3567; ...
     0 0 0 0   -0.0000   -0.0000   -0.0002   -0.0046   -1.8318   -0.3567; ...
     0 0 0 0    0.0000   -0.0000    0.0002   -0.0046    1.8318   -0.3567; ...
     0 0 0 0   -0.0000   -0.0000   -0.0002   -0.0046   -1.8318   -0.3567; ...
     0 0 0 0    0.0000   -0.0000    0.0002   -0.0046    1.8318   -0.3567; ...
    ];
lcaPut(strcat(pvList,':IVBU'),fliplr(val));

% KLYS properties.
[pvList,d,isSLC]=model_nameConvert({'KLYS' 'SBST' 'ACCL'},'MAD','*');
pvList2=pvList(isSLC);
control_deviceSet(pvList2,'ADES',60);
gold=360*(rand(length(pvList2),1)*2-1);
control_phaseSet(pvList2,gold,0,0,'GOLD');
control_phaseSet(pvList2,0);
lcaPut(strcat(control_klysName(pvList),':ENLD'),230);
control_klysStatSet(pvList,1);

% EPICS KLYS properties.
pvList=model_nameConvert({'ACCL'},'MAD',{'LI24' 'LI29' 'LI30'});
gold=360*(rand(length(pvList),1)*2-1);
control_phaseSet(pvList,gold,0,0,'GOLD');
control_klysStatSet(pvList,1);
pvList={'L2' 'L3'};
gold=360*(rand(length(pvList),1)*2-1);
control_phaseSet(pvList,gold,0,0,'GOLD');

% LCLS RF
pv={'GUN' 'L0A' 'L0B' 'TCAV0' 'L1S' 'L1X' 'TCAV3' 'XTCAV' 'XTCAVF'};
control_klysStatSet(pv,[1 1 1 0 1 1 0 0 0]);
pv={'GUN' 'L0A' 'L0B' 'TCAV0' 'L1S' 'L1X' 'L2' 'L3' '24-1' '24-2' '24-3' 'TCAV3' '29-0' '30-0' 'XTCAV' 'XTCAVF'};
control_phaseSet(pv,[0 0 -2.5 90 -25.1 -160 -36 0 -20-36 20-36 0-36 90 -45 45 90 90]);
control_ampSet(pv,[6 57.84 70.70 20.0 141.57 20.0 5006.1 9340.0 230 230 230 18 1840 1840 10]);
pv={'LASER' 'LASER2' 'GUN' 'L0A' 'L0B' 'TCAV0' 'L1S' 'L1X' 'TCAV3' 'XTCAV' 'XTCAVF'};
[d,d,d,d,d,d,d,d,fdbk_pv,disable_pv]=control_phaseNames(pv);
lcaPut(disable_pv,0);lcaPut(fdbk_pv,1);
lcaPut('BMLN:LI21:235:MOTR.RBV',229.3);
lcaPut('BMLN:LI24:805:MOTR.RBV',361.6);
lcaPut('SIOC:SYS0:RF01:KLY_SELECTOR',0);

% FACET RF
pv={'09-10' '09-20' '17-0' '18-0'};
control_phaseSet(pv,[46 -46 62.5 -62.5]);
control_phaseSet({'02-S' '03-S' '04-S' '05-S' '06-S' '07-S' '08-S' '09-S' '10-S'},-20.4);
control_phaseSet({'11-S' '12-S' '13-S' '14-S' '15-S' '16-S' '17-S' '18-S' '19-S'},0);

% Init model.
model_rMatModel({'OTR1' 'OTRS1' 'OTR12' 'OTR21' 'OTR33' 'PR55' 'PR18'},[],[],'init',1);

% Turn SS bends off, the design model has HXRSS on and SXRSS at eps value.
control_magnetSet({'BXSS1' 'BXSS2' 'BXSS3' 'BXSS4' 'BXHS1' 'BXHS2' 'BXHS3' 'BXHS4'},0);

% Miscellaneous
rate=120;
lcaPut('IOC:IN20:BP01:QANN',0.05); % BPM charge reference
lcaPut('EVNT:SYS0:1:LCLSBEAMRATE',rate); % Beam rate
lcaPut('EVNT:SYS0:1:BEAMRATE',rate); % Generic Beam rate for getSystem
lcaPut('IOC:IN20:MC01:LCLSBEAMRATE',rate); % Beam rate
lcaPut('TRIG:LR20:LS01:TCTL',1); % Laser Pockels cell
lcaPut('PATT:SYS0:1:POCKCTRL',1); % New Laser Pockels cell trigger control
lcaPut('IOC:BSY0:MP01:MSHUTCTL',1); % Mechanical shutter beam permit
lcaPut('IOC:BSY0:MP01:PCELLCTL',1); % Pockels-cell beam permit
lcaPut('IOC:BSY0:MP01:BYKIKCTL',1); % BYKIK LTU vertical abort kicker
lcaPut('IOC:BSY0:MP01:LSHUTCTL',1); % Laser heater shutter
lcaPut('DUMP:LI21:305:TD11_PNEU',1); % TD11 beam permit
lcaPut('DUMP:LTU1:970:TDUND_PNEU',1); % TDUND beam permit
lcaPut('SIOC:SYS0:ML00:AO066',0); % Joe phase_control busy
lcaPut('SIOC:SYS0:ML00:AO017',0); % Phase_Scans busy
lcaPut('LLRF:IN20:RH:REF_2_CONVERGE',0); % 119 MHz EVG done
lcaPut('LASR:IN20:1:LSR_SOURCE','2856'); % Laser source PAD
lcaPut('LASR:IN20:2:LSR_SOURCE','2856'); % Laser source PAD
lcaPut('SIOC:SYS2:MP01:DISABLE_AOM',0); % GUNB AOM Disabled Bit

% Feedbacks
lcaPut('FBCK:FB02:GN01:STATE',1); % EPICS Gun charge feedback state
lcaPut('FBCK:BCI0:1:STATE',1); % Matlab Gun charge feedback state
lcaPut('SIOC:SYS0:ML00:AO016',210); % Joe 6x6 BC1 peak current
lcaPut('SIOC:SYS0:ML00:AO044',3000); % Joe 6x6 BC2 peak current
lcaPut('FBCK:FB04:LG01:S3DES',210); % Fast 6x6 BC1 peak current
lcaPut('FBCK:FB04:LG01:S5DES',3000); % Fast 6x6 BC2 peak current
lcaPut('LASR:IN20:475:PWR1H',10); % Laser heater power
lcaPut('FOIL:LI24:804:MOTR',-6000); % BC2 slotted foil position
lcaPut('FOIL:LI24:804:LVPOS',-6001); % BC2 slotted foil LVDT position
lcaPut('FOIL:LI24:806:MOTR',-14000); % BC2 slotted foil position
lcaPut('FOIL:LI24:806:LVPOS',-14001); % BC2 slotted foil LVDT position
lcaPut('MPS:IN20:200:LHSHT1_OUT_MPS',1); % Laser heater shutter status
[d,charge_pv] = control_chargeName;  % nC
lcaPut(charge_pv,0.150); % nC

% Emittance
pvList={'OTR2' 'WS02' 'OTR3' 'YAGS2' 'OTRS1' 'OTR12' 'WS12' 'WS24' 'WS28144' 'WSVM2' 'OTR33' 'WS32' 'BFW07'};
control_emitSet(pvList,[model_twissGet(pvList,'TYPE=DESIGN');ones(1,2,numel(pvList))]);

% Operating Point GUI
lcaPut('SIOC:SYS0:ML00:AO107',-30);   % Laser phase (deg)
lcaPut('SIOC:SYS0:ML00:AO109',0);     % L0A phase (deg)
lcaPut('SIOC:SYS0:ML00:AO111',-2.5);  % L0B phase (deg)
lcaPut('SIOC:SYS0:ML00:AO113',-22);   % L1S phase (deg)
lcaPut('SIOC:SYS0:ML00:AO115',-160);  % L1X phase (deg)
lcaPut('SIOC:SYS0:ML00:AO116',-45.5); % BC1 R_56 (mm)
lcaPut('SIOC:SYS0:ML00:AO118',-36);   % L2 phase (deg)
lcaPut('SIOC:SYS0:ML00:AO119',-24.7); % BC2 R_56 (mm)
lcaPut('SIOC:SYS0:ML00:AO121',0);     % L3 phase (deg)
lcaPut('SIOC:SYS0:ML00:AO122',13.64); % BSY energy (GeV)
lcaPut('SIOC:SYS0:ML00:AO123',250);   % BC1 energy (MeV)
lcaPut('SIOC:SYS0:ML00:AO124',4.3);   % BC2 energy (GeV)

% Phase_Scans
lcaPut('SIOC:SYS0:ML00:AO934',90);
lcaPut('SIOC:SYS0:ML00:AO936',-180);

% Done
disp('Done!');


function setProp(pvList, props, vals)

pvList=model_nameConvert(cellstr(pvList),'EPICS');
for j=1:length(pvList)
    if nargin > 2
        props(:,2)=num2cell(vals(:,j));
    end
    lcaPut(strcat(pvList(j),':',props(:,1)),vertcat(props{:,2}));
end
