function [amp, phase, is, map, globPh] = model_energyKlys(name, check, varargin) %getSCP, usePDES)
%MODEL_ENERGYKLYS
% [AMP, PHASE, IS, MAP, GLOBPH] = MODEL_ENERGYKLYS(NAME, CHECK, GETSCP) or
% [AMP, PHASE, IS, MAP, GLOBPH] = MODEL_ENERGYKLYS(NAME, CHECK, OPTIONS)
% Gets for list of klystron names NAME the crest gain AMP, PHASE and a
% structure IS with fields like L0, L1, etc. which indicate if the klystron
% is in the respective region. The SCP controlled klystron phases are
% assumed to be 0 unless GETSCP is set to one. The epics controlled global
% phases for L2, L3, S-29, S-30, and FACET are added to the respective
% klystrons.
%
% Features:
%
% Input arguments:
%    NAME:    Cellstring array of klystron MAD names (e.g. L0B or 26-2)
%    CHECK:   Flag to only return IS as first output
%    OPTS:   Options
%            GETSCP:  Flag to get SCP klystron phases, default 0
%            USEPDES: Flag to use PDES (1) or PACT/PHAS (0), default 1 (PDES)
%            GETSBST: Flag to get SCP sub-booster phases, default 0
%
% Output arguments:
%    AMP:    Vector of klystron amplitudes in MeV
%    PHASE:  Vector of klystron phases in degrees
%    IS:     Structure with fields L0, L1, L2, L3, FACET, etc.
%            L0: Logical vector indicating if klystron is in L0
%    MAP:    Cell array mapping vector of area fields from IS to global
%            phase devices, e.g. {'S29' '29-0'}
%    GLOBPH: Global phases for such devices from MAP affecting klystrons in
%            NAME, unused ones not queried and NaN returned

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert, control_klysStatGet,
%                   control_phaseGet, model_nameRegion

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% NAME is MAD name.
name=reshape(cellstr(name),[],1);
if ~all(cellfun('isempty',strfind(name,':')))
    name=model_nameConvert(name,'MAD');
end

[sys,accel]=getSystem;
modK24=false(1,3);
if strcmp(accel,'LCLS')
    modK24=lcaGetSmart('SIOC:SYS0:RF01:KLY_SELECTOR',0,'double') == [1 2 0];
end

nameC=char(name);
klysSect=cell(size(name));
klysSect(:)=cellstr(nameC(:,1:min(2,end)));
isEP=strncmp(name,'L',1);
is.L0=ismember(name,{'L0A' 'L0B'});
is.L1=ismember(name,{'L1S' 'L1X'});
is.K41=ismember(name,{'24-1'}) & ~modK24(1);
is.K42=ismember(name,{'24-2'}) & ~modK24(2);
is.K43=ismember(name,{'24-3'}) & ~modK24(3);
is.L2_FS=is.K41 | is.K42 | is.K43;
is.S29=ismember(klysSect,{'29'});
is.S30=ismember(klysSect,{'30'});
is.L2_NOFS=ismember(klysSect,{'21' '22' '23' '24'}) & ~is.L2_FS;
is.L3_NOFS=ismember(klysSect,{'25' '26' '27' '28'});
is.F1=ismember(klysSect,{'02' '03' '04' '05' '06' '07' '08' '09' '10'});
is.F2=ismember(klysSect,{'11' '12' '13' '14' '15' '16' '17' '18' '19'});
is.L0F=ismember(name,{'L0AF' 'L0BF'});
is.L1F=ismember(name,{'L1SB' 'L1XF'}); 
is.L2F=ismember(klysSect,{'11' '12' '13' '14'}); %FACET II 
is.L3F=ismember(klysSect,{'15' '16' '17' '18' '19'});
is.K91=ismember(name,{'09-1'});
is.K92=ismember(name,{'09-2'});
is.S17=ismember(klysSect,{'17'});
is.S18=ismember(klysSect,{'18'});

is.S24=ismember(name,{'24-1' '24-2' '24-3'});
is.L2_SV=ismember(klysSect,{'21' '22' '23' '24'}) & ~is.S24;

% Collect linac sections, field order arbitrary.
is.L2=is.L2_NOFS | is.L2_FS;
is.L3_FS=is.S29 | is.S30;
is.L3=is.L3_NOFS | is.L3_FS;
is.FACET=is.F1 | is.F2;
is.F2_ELEC= is.L2F | is.L3F;
is.F1_FS=is.K91 | is.K92;
is.F1_NOFS=is.F1 & ~is.F1_FS;
is.F2_FS=is.S17 | is.S18;
is.F2_NOFS=is.F2 & ~is.F2_FS;

%Add LEM regions with no klystrons, same as L3 for fudge calculations
%is.CLTH_DMPH = is.L3;
%is.CLTS_DMPS = is.L3;
is.CLTH_DMPH = ismember(name,{'NONE_NO_MATCH'});
is.CLTS_DMPS = ismember(name,{'NONE_NO_MATCH'});
is.FACET2_LI20 = ismember(name,{'NONE_NO_MATCH'});


% Define global phase relations, any order.
map={ ...
%   <Region>  <Global Phase>
%
%LCLS
%
%    'K41'     '24-1'; ...
%    'K42'     '24-2'; ...
%    'K43'     '24-3'; ...
    'S29'     '29-0'; ...
    'S30'     '30-0'; ...
    'L2_SV'   'L2'  ; ...
    'L3_NOFS' 'L3'  ; ...
%
%FACET
%
    'K91'     '09-10'; ...
    'K92'     '09-20'; ...
    'S17'     '17-0' ; ...
    'S18'     '18-0' ; ...
    };

% Return IS when CHECK
if nargin > 1 && check, amp=is;return, end

% Legacy syntax.
if nargin == 3 && ~isstruct(varargin{1}), varargin=[{'getSCP'} varargin];end

% Set defaults.
optsdef=struct( ...
    'getSCP',0, ...
    'usePDES',1, ...
    'getSBST',0, ...
    'region','CU_HXR' ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Determine attribute type.
type='PDES';if ~opts.usePDES, type='PACT';end

switch opts.region
    case 'CU_HXR', beamCode = 1; dataSlot = 0;
    case 'CU_SXR', beamCode = 2; dataSlot = 1;
    case 'F2_ELEC', beamCode = 10; dataSlot=0;
    otherwise,  beamCode = 1; dataSlot = 0;
end

% Get klystron trigger.
[act,stat,swrd,d,d,amp]=control_klysStatGet(name, beamCode); % AMP in MeV

global ignoreSWRD
if isempty(ignoreSWRD), ignoreSWRD =  0; disp('ignoreSWRD set to FALSE'); end
if ignoreSWRD
    isAct=bitand(act,1) ;%:& ~bitand(swrd,1+2+4+8+16); %& bitand(stat,1); doesn't work for L1X
else
     isAct=bitand(act,1) & ~bitand(swrd,1+2+4+8+16); %& bitand(stat,1); doesn't work for L1X
end
% Get klystron phase.
phase=zeros(size(name,1),1);
phase(is.S24)=control_phaseGet(name(is.S24), [], dataSlot);
[phase(isEP),amp(isEP)]=control_phaseGet(name(isEP),{type 'ADES'});

% Get SCP phases when GETSCP
if opts.getSCP
    phase(~isEP & ~is.S24)=control_phaseGet(name(~isEP & ~is.S24),type);
end

phase(isnan(phase))=0;
amp=amp.*isAct;

% Determine global phases to request.
useList=struct2cell(is);
[isR,idR]=ismember(map(:,1),fieldnames(is));
useList=[useList{idR(isR)}];map=map(isR,:);

globPh=zeros(size(map,1),1);
globPh(any(useList))=control_phaseGet(map(any(useList),2));
globPh(isnan(globPh))=0; % Make sure used areas have finite global phase
phase=phase+useList*globPh;
globPh(~any(useList))=NaN;

% Add SBSTs.
if opts.getSCP && any(is.L2 | is.L3)
    nSBST=cellstr(num2str((21:28)'));
    [isJ,idJ]=ismember(klysSect,nSBST);
    isJ=isJ & ~is.S24;
    sbstPh=control_phaseGet(strcat(nSBST,'-S'),type);
    phase(isJ)=phase(isJ)+sbstPh(idJ(isJ));
end

% Fix L2_NOFS in map.
map=strrep(map,'L2_SV','L2_NOFS');

% Return if no FACET.
if ~any(is.L2F | is.L3F), return, end

% Return if no SBST phases requested.
%if ~opts.getSBST, return, end

% Get SBST phases.
sbstPh=control_phaseGet(model_nameRegion('SBST','F2_ELEC'),type);
for j=11:19
    isJ=ismember(klysSect,num2str(j,'%02d'));
    phase(isJ)=phase(isJ)+sbstPh(j-10)*0;  %TODO remove *0 
end

%{
% Calculate energy gain of each station
function egain = station_gain(enld, hsta, stat, swrd, act)
if ~isfinite(enld) || ~isfinite(hsta) || ~isfinite(stat) || ~isfinite(swrd)
    egain = 0;  % Assume zero gain if we can't read something
    return
end
online  = bitand(hsta, 1); % station online
nomaint = ~bitand(stat, 2); % not maintainance mode
mod_ok = ~bitand(swrd, 8);
cable_ok = ~bitand(swrd,1);
mksu_notprotect = ~bitand(swrd,2);
%acc_rate = ~bitand(swrd,32768);
acc_rate = bitget(act,1);
bad_camac = bitand(swrd, 16);
overall_ok=online & nomaint & mod_ok & cable_ok & mksu_notprotect & acc_rate & ~bad_camac;
egain=enld*overall_ok;
%}
