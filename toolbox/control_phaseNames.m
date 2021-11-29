function [name, is, PACT, PDES, GOLD, KPHR, AACT, ADES, FDBK, SEND, POFF, ...
          ACAL, FBKA] = control_phaseNames(name, ds)
%PHASENAMES
%  PHASENAMES(NAME) Creates epics PV names for different RF parameters from
%  MAD or EPICS input NAME. NAME can have suffixes for PAD number ('_n') in
%  either form.

% Features:

% Input arguments:
%    NAME: String or cell string array for name(s) of RF PV or MAD alias(es).
%    DS  : Data Slot for PAU, default empty, i.e. set global parameters

% Output arguments:
%    NAME: String or cell string array for name of RF PV or MAD alias.
%    IS  : Struct containing logical arrays indicating type of device
%    PACT: Names for actual phase (PDES if N/A)
%    PDES: Names for desired phase
%    GOLD: Names for phase offset (NAME if N/A)
%    KPHR: Names for fox phase shifter (NAME if N/A)
%    AACT: Names for actual amplitude (ADES if N/A)
%    ADES: Names for desired amplitude
%    FDBK: Names for phase FB status
%    SEND: Names for send to PAC
%    POFF: Names for PAU offsets
%    ACAL: Names for amplitude calibration
%    FBKA: Names for amplitude FB status

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, model_nameSplit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get EPICS name.
if nargin < 2, ds=[];end
name=cellstr(name);
[name,PAD]=strtok(name(:),'_'); % Find EPICS PAD extensions '_N'
[name,d,isSLC]=model_nameConvert(name,{'EPICS' 'SLC'});
nameSLC=name(:,2);name=name(:,1);
namePAD=strcat(name,PAD);if isempty(name), namePAD=name;end
[PACT,PDES,KPHR,GOLD,AACT,ADES,FDBK,SEND,POFF,ACAL,FBKA]=deal(repmat({''},size(name)));

% Determine device type.
[prim,micro,unit]=model_nameSplit(name);              % micro + unit
isL2 =strcmp(name,'ACCL:LI22:1');             % L2 control
isL3 =strcmp(name,'ACCL:LI25:1');             % L3 control
isL23=isL2 | isL3;                            % L2/3 from Joe's 6x6 feedback
isKLY=ismember(prim,{'KLYS' 'SBST'}) & ...
      ~strncmp(name,'KLYS:LI20:K',11);
isPAC=strncmp(name,'ACCL:LI24',9) | ...
      strncmp(name,'ACCL:LI29',9) | ...
      strncmp(name,'ACCL:LI30',9) | ...       % PAC only devices 24-1,2,3 & 29/30-0
      strncmp(name,'LLRF:IN20:RH:C',14) | ... % Clock
      strncmp(name,'LLRF:IN20:RH:L',14) | ... % L2 reference
      strncmp(name,'LLRF:LI24:0',11);         % Sector 24 reference
isLSR=strcmp(prim,'LASR');                    % Laser RF
isLSN=strcmp(prim,'OSC');                     % New laser phase control
isPCV=strcmp(prim,'PCAV');                    % Phase cavity
isFBK=~(isSLC | isPAC | isL23 | isKLY);       % EPICS RF with (feedback) PAD
isPAD=~strcmp(PAD,'');                        % EPICS RF names for specific PAD
isL1S=strncmp(name,'ACCL:LI21:1:',12);        % L1S
isL1X=strncmp(name,'ACCL:LI21:180',13);       % L1X
isTCV=strcmp(prim,'TCAV');                   % TCAV0,3,F,X
isSBS=strcmp(micro,'SBST') | ...
      strcmp(prim,'SBST');                    % Sub-booster
isREF=strncmp(name,'LLRF:IN20',9) | ...
      strncmp(name,'LLRF:LI24',9);            % Reference
isRE1=isREF & strcmp(PAD,'_1');               % REF_1 has no PAC
isPAU=strncmp(name,'LLRF:IN20:RH:L',14) | ...
      (isFBK & ~isPCV & ~isLSR & ~isLSN | ...
      isPAC | isL23) & ~isREF;                % (P)attern (A)ware (U)nits
isNLC=strncmp(name,'TA',2);                   % NLCTA klys
isFPS=strcmp(prim,'EP01') | ...            % Fast SLC phase shifter
      strncmp(name,'LI09:PHAS',9);
isMTC=strcmp(name,'LI28:KLYS:21') & ...       % uTCA controlled
      0; % PV broken
%      lcaGetSmart('LLRF:LI28:21:MTCAON',0,'double') == 1; % Catches NaN
isNew=strncmp(name,'TCAV:LI20',9) | ...
      strncmp(name,'TCAV:DMPH',9);            % New naming standard
isMK2=strncmp(name,'TCAV:DMPH',9);            % Uses MKSU-II
name(isKLY)=nameSLC(isKLY);namePAD(isKLY)=nameSLC(isKLY);

% Store original name
nameOrig=namePAD;
%nameOrig(isNew)=strcat(name(isNew),strrep(PAD(isNew),'_',':'));

% Append ':' or '_'
isCol=isSLC | isKLY | isL23 | isNew | isLSN; % Uses colon separator for attribute
name(isCol)=strcat(name(isCol),':');
name(~isCol)=strcat(name(~isCol),'_');
namePAD=strcat(namePAD,'_');
namePAD(isNew)=strcat(name(isNew),strrep(PAD(isNew),'_',''),':');
namePAD(isL23 | isPAC | isLSN)=name(isL23 | isPAC | isLSN);
name(isREF)=namePAD(isREF);

% Defaults for DES names and EPICS ACT.
PDES(:)=strcat(name,'PDES');
ADES(:)=strcat(name,'ADES');
PACT(:)=PDES(:);
AACT(:)=ADES(:);

% Do Laser PDES.
PDES(isLSR)=strcat(name(isLSR),'PDES2856'); % PDES for 2856 MHz

% Use AIDA EPICS PVs for SLC devices.
use=isSLC & ~isFPS | isKLY;
PACT(use)=strcat(name(use),'PHAS');
AACT(use)=strcat(name(use),'AMPL');
KPHR(use)=strcat(name(use),'KPHR');
GOLD(use)=strcat(name(use),'GOLD');

% Do NLCTA case.
PACT(isNLC)=strcat(name(isNLC),'PDES');
AACT(isNLC)=strcat(name(isNLC),'ENLD');
ADES(isNLC)=strcat(name(isNLC),'ENLD');

% Do fast SLC phase shifter case.
PDES(isFPS)=strcat(name(isFPS),'VDES');
PACT(isFPS)=strcat(name(isFPS),'VACT');
AACT(isFPS)=strcat(name(isFPS),'VDES'); % Need to look into this ACT/DES mixup
ADES(isFPS)=strcat(name(isFPS),'VACT'); % Need to look into this ACT/DES mixup

% Act names for EPICS FB devices.
%PACT(isFBK)=strcat(name(isFBK),'S_PV');
%AACT(isFBK)=strcat(name(isFBK),'S_AV');
PACT(isFBK)=strcat(name(isFBK),'PAVG');
AACT(isFBK)=strcat(name(isFBK),'AAVG');
nameB=regexprep(name(isLSR | isPCV),'(LSR|PH[1-4])_','');
PACT(isLSR | isPCV)=strcat(nameB,'PBR'); % LASR & PCAV have no :PH1_PAVG
AACT(isLSR | isPCV)=strcat(nameB,'ABR'); % LASR & PCAV have no :PH1_AAVG

% Names for devices with new naming convention.
PACT(isNew & isFBK)=strcat(name(isNew & isFBK),'S_PV'); % optional if PAVG exist
AACT(isNew & isFBK)=strcat(name(isNew & isFBK),'S_AV'); % optional if AAVG exist

% Get EPICS PAD specific names.
use=isPAD & ~(isL23 | isSLC | isKLY | isPAC);
PACT(use)=strcat(namePAD(use),'S_PA');
AACT(use)=strcat(namePAD(use),'S_AA');

% Get set value names for no PAC devices.
PDES(isPCV | isRE1)=PACT(isPCV | isRE1);
ADES(isPCV | isRE1)=AACT(isPCV | isRE1);

% Get GOLD & ACAL names.
GOLD(isPAD | isPAC | isL23 | isLSN)=strcat(namePAD(isPAD | isPAC | isL23 | isLSN),'POC');
ACAL(isPAD)=strcat(namePAD(isPAD),'AVC');

% Get Feedback enable names.
FDBK(isFBK & ~isREF)=strcat(name(isFBK & ~isREF),'PHAS_FB'); % REF does not have enable
FDBK(isLSR)=strcat(name(isLSR),'P_FB_PND');
FBKA(isFBK & ~isREF)=strcat(name(isFBK & ~isREF),'AMPL_FB'); % REF does not have enable
SEND(isFBK | isPAC)=strcat(name(isFBK | isPAC),'SEND');

% Deal with new laser controls crap.
%PACT(isLSN)=strcat(name(isLSN),'CH1_CALC_PHASE'); % [fs]
PACT(isLSN)=strcat('LASR:IN20:',strrep(unit(isLSN),'0',''),':PBR'); % [degS]
%PDES(isLSN)={'SIOC:SYS0:ML01:AO495'};
%GOLD(isLSN)={'SIOC:SYS0:ML01:AO496'};
%KPHR(isLSN)
AACT(isLSN)={''};
ADES(isLSN)={''};
FDBK(isLSN)=strcat(name(isLSN),'RF_LOCK_ENABLE');
SEND(isLSN)={''};
%POFF(isLSN)
ACAL(isLSN)={''};
FBKA(isLSN)={''};

% Get PAU names if DS is given.
if ~isempty(ds)
    ds=num2str(ds);
    POFF(isPAU)=strcat(PDES(isPAU),':OFFSET_',ds);
    noPAD=isPAU & (isPAC | isL23);
    noPAC=isPAU & ~(isPAC | isL23);
    PACT(noPAC)=strcat(name(noPAC),'PACT_DS',ds);
    AACT(noPAC)=strcat(name(noPAC),'AACT_DS',ds);
    PDES(noPAC)=strcat(PDES(noPAC),'_DS',ds);
    ADES(noPAC)=strcat(ADES(noPAC),'_DS',ds);
    PDES(noPAD)=strcat(PDES(noPAD),':SETDATA_',ds);
    ADES(noPAD)=strcat(ADES(noPAD),':SETDATA_',ds);
    PACT(noPAD)=PDES(noPAD);
    AACT(noPAD)=ADES(noPAD);
end

% New uTCA controls.
PDES(isMTC)={'LLRF:LI28:21:APP_PHA_SP'};
PACT(isMTC)={'LLRF:LI28:21:BSA_PHA_VAL'};
GOLD(isMTC)={'LLRF:LI28:21:APP_PHA_OFF'};
ADES(isMTC)={'LLRF:LI28:21:APP_AMP_SP'};
AACT(isMTC)={'LLRF:LI28:21:BSA_AMP_VAL'};

% Set isSLC for Epics klystrons to false.
isSLC(isKLY)=0;

% Put all logicals into struct.
is.SLC=isSLC;
is.PAD=isPAD;
is.L23=isL23;
is.FBK=isFBK;
is.PAC=isPAC | isMTC;
is.LSR=isLSR;
is.L1S=isL1S;
is.L1X=isL1X;
is.TCV=isTCV;
is.SBS=isSBS;
is.L2 =isL2 ;
is.L3 =isL3 ;
is.PAU=isPAU;
is.KLY=isKLY & ~isMTC;
is.MTC=isMTC;
is.FPS=isFPS;
is.New=isNew;
is.MK2=isMK2;
is.LSN=isLSN;

%is.REF=isREF;
%is.PCV=isPCV;

name=nameOrig;
