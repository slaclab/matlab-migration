function profmon_lampSet(pv, state, type)
%PROFMON_LAMPSET
%  PROFMON_LAMPSET(PV, STATE, TYPE) Turns the respective lamp TYPE (0
%  target, 1 grid) for profile monitor PV to STATE (-1 dimmer, 0 off, 1 on, 2 brighter).

% Features:

% Input arguments:
%    PV: Base name of camera PV, e.i. YAGS:IN20:211
%    STATE: 0 (off), 1 (on), -1 (dimmer), 2 brighter
%    TYPE: 0 (target) or 1 (grid)

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: lcaPut

% Author: Henrik Loos, Greg White, SLAC
% Mod:    9-Sep-2016, Greg White, Removed PR45 and PR55 from BSY in
%         preparation for changes for LCLS-2.
% --------------------------------------------------------------------

if epicsSimul_status, return, end
if nargin < 3, type=0;end
if nargin < 2, state=1;end

% Define camera - lamp IOC association.
%      {1. Camera PV     2. Camera PV     3. Camera PV     4. Camera PV     Sector IOC#}
pvList={'YAGS:IN20:211'  'YAGS:IN20:841'  'YAGS:IN20:241'  'YAGS:IN20:351'  'IN20' 'GP01'; ...
        'CTHD:IN20:206'  'OTRS:IN20:465'  'OTRS:IN20:471'  'OTRS:IN20:541'  'IN20' 'GP02'; ...
        'OTRS:IN20:571'  'OTRS:IN20:621'  'OTRS:IN20:711'  'YAGS:IN20:921'  'IN20' 'GP03'; ...
        'YAGS:IN20:995'  ''               'OTRS:LI21:237'  'OTRS:LI21:291'  'IN20' 'GP04'; ...
        'OTRS:LI24:807'  'OTRS:LI25:342'  ''               ''               'LI24' 'GP01'; ...
        'OTRS:LI25:920'  ''               ''               ''               'LI25' 'GP01'; ...
        'OTRS:LTU1:449'  ''               ''               ''               'LTU1' 'GP01'; ...
        'OTRS:LTU1:745'  'YAGS:UND1:1005' 'YAGS:UND1:1305' ''               'LTU1' 'GP02'; ...
        'OTRS:DMP1:695'  'YAGS:DMP1:500'  ''               ''               'DMP1' 'GP01'; ...
        'CAMR:FEE1:2953' 'CAMR:FEE1:852'  'CAMR:FEE1:913'  ''               'FEE1' 'GP01'; ...
        'CAMR:FEE1:1561' 'CAMR:FEE1:1692' 'CAMR:FEE1:1953' ''               'FEE1' 'GP02'; ...
        'CAMR:NEH1:124'  'CAMR:NEH1:195'  'CAMR:NEH1:1124' 'CAMR:NEH1:2124' 'NEH1' 'GP01'; ...
        '13PS4:cam1'     '13PS5:cam1'     ''               ''               ''     ''    ; ... %NLCTA
        'PROF:LI20:45'   'YAGS:LI20:2432' ''               ''               'LI200' 'GP01'; ...
        'OTRS:LI20:3158' 'OTRS:LI20:3206' ''               ''               'LI201' 'GP01'; ...
        };

% Deal with YAGSLIT.
pv=strrep(pv,'PROF:UND1:960','YAGS:UND1:1005');

% Find camera in PVLIST.
pvIdList=strcmp(pv,pvList(:,1:4));
if ~any(pvIdList(:)), return, end

% Get IOC and channel.
pvId=any(pvIdList,2);
pvPos=pvIdList(pvId,:);
%pvOther=pvList(pvId,~pvPos)';pvOther(cellfun('isempty',pvOther))=[];
iocStr=['PFMC:' pvList{pvId,5} ':' pvList{pvId,6}];
chanList=[0 1 2 3];
typeList={'T_LAMP' 'G_LAMP'};

if strncmp(pv,'13PS',4) %NLCTA
    lampPV={'ESB:BO:2124-1:BIT2' ''};
    lcaPut(lampPV(pvPos),state);
    return
end

% Set selected camera IOC channel.
lcaPut([iocStr ':LAMP_CH'],chanList(pvPos));

% Enable/disable selected camera lamp type.
if ismember(state,[0 1])
    lcaPut([iocStr ':' typeList{type+1} '_ENA'],state);
    return
end

% Dim or brighten selected camera lamp.
str={'DOWN' 'UP'};
lcaPut([iocStr ':' typeList{type+1} '_' str{(state > 0)+1}],1);pause(.5);
lcaPut([iocStr ':' typeList{type+1} '_' str{(state > 0)+1}],0);
