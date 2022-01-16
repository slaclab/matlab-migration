function [act, stat, swrd, hdsc, dsta, enld] = control_klysStatGet(name, beamCode)
%KLYSSTATGET
%  [ACT, STAT, SWRD, HDSC, DSTA, ENLD] = KLYSSTATGET(NAME, BEAMCODE)
%  returns the status of the klystrons in string or cellarray NAME.

% Input arguments:
%    NAME:     Name of klystron (MAD, Epics, or SLC), string or cell string
%              array
%    BEAMCODE: Beam code(s) for klystrons, default 1 (LCLS) or 10 (FACET)

% Output arguments:
%    ACT:  Activation state of klystrons NAME on beam code(s) BEAMCODE
%          0: Deactivated
%          1: Activated
%          NaN: Unknown status or NAME or AIDA error
%    STAT: Operation state of klystrons NAME as short
%    SWRD: PIOP status of klystrons NAME as short
%    HDSC: Hardware descriptor of klystrons NAME as short
%    DSTA: Digital status of klystrons NAME as short
%    ENLD: Energy gain

% Compatibility: Version 2007b, 2012a
% Called functions: getSystem, control_klysName, epicsSimul_status,
%                   aidaget, lcaGet, lcaGetSmart

% Author: Henrik Loos, SLAC

% Modified 28-May-2021 to always report 26-3 as DEACT'd as missing PVs and
% nonfunctional. See lines 113-121 (v 1.36->1.37) --T. Maxwell

% AIDA-PVA imports
global pvaRequest;
global AIDA_SHORT;

% --------------------------------------------------------------------
% Check input arguments
if nargin < 2
    [sys,accel]=getSystem;
    beamCode=1;
    if strcmp(accel,'FACET')
        rate = lcaGetSmart({'EVNT:SYS1:1:BEAMRATE' 'EVNT:SYS1:1:POSITRONRATE'});
        if rate(1) > rate(2)
            beamCode=10; % FACET e-
        else
            beamCode=6;  % FACET e+
        end
    end
end

% Get EPICS name.
name=cellstr(name);name=name(:);nName=numel(name);
act=zeros(nName,size(beamCode,2));
[stat,swrd,hdsc,enld]=deal(zeros(size(name)));
dsta=zeros(numel(name),2);
if ~nName, return, end
useAida=1;
beamCode(end+1:nName,:)=repmat(beamCode(end,:),nName-size(beamCode,1),1);
[name,nameEpics,isSLC]=control_klysName(name);

use=~cellfun('isempty',strfind(name,':'));
if ~all(use), disp(char(strcat({'KlysStatGet: Invalid name(s): '},name(~use))));end
if ~any(use), return, end

if epicsSimul_status
    act(use)=lcaGet(strcat(nameEpics(use),':TACT'));
    act(use)=2.^~act(use);
    enld=enld+220;
    enld(use)=lcaGet(strcat(name(use),':ENLD'));
    return
end

isTrig=~cellfun('isempty',strfind(name,'TRIG'));
isMK2=strncmp(name,'KLYS:DMP',8);
is263 = strcmp(nameEpics,'KLYS:LI26:31');
use2=use & ~isTrig & ~isMK2 & ~is263;
if any(use2)
    try
        stat(use2)=lcaGetSmart(strcat(nameEpics(use2),':STAT'));
        swrd(use2)=lcaGetSmart(strcat(nameEpics(use2),':SWRD'));
        hdsc(use2)=lcaGetSmart(strcat(nameEpics(use2),':HDSC'));
        dsta(use2,1:2)=lcaGetSmart(strcat(nameEpics(use2),':DSTA'),0,'long');
        enld(use2)=lcaGetSmart(strcat(nameEpics(use2),':ENLD'));
    catch ex
        warning('control_klysStatGet.m issues retrieving klystron status words')
        disp(ex.message)
    end
    stat(isnan(stat)) = 0;
    swrd(isnan(swrd)) = 0;
    hdsc(isnan(hdsc)) = 0;
    dsta(isnan(dsta)) = 0;
    enld(isnan(enld)) = 0;
    swrd(use2) = bitand(swrd(use2)+2^16,2^16-1);
else
    %stat = lcaGetSmart(strcat(nameEpics,':MOD.RVAL'));
end

% Get TACT
dgrpMatch = { ...
    'KLYS:LI00:97' 'INJECTOR'; ...
    'KLYS:LI00:98' 'INJECTOR'; ...
    'KLYS:LI00:99' 'INJECTOR'; ...
    'KLYS:DR13:1'  'NDRFACET'; ...
    'KLYS:DR01:1'  'INJ_POSI'; ...
    'KLYS:DR01:1'  'SDRFACET'; ...
    'KLYS:DR03:1'  'SDRFACET'; ...
    'KLYS:LI20:93' 'POS_KLYS'; ...
    'KLYS:LI20:94' 'POS_KLYS'; ...
   };

% Try MKSU-II controls.
if any(isMK2 & use)
    for k=1:size(beamCode,2)
        u=isMK2 & use;
        act(u,k)=lcaGetSmart(strcat(nameEpics(u),':MOD'),0,'double');
        act(u & (act(:,k) == 3 | isnan(act(:,k))),k)=4; % Mock-up old TACT bits
    end
    use=use & ~isMK2;
end

% Try EPICS controls.
if any(~isSLC & use)
    for k=1:size(beamCode,2)
        bc=beamCode(:,k);
        u=~isSLC & use & ~is263;
        u(isnan(bc) | bc < 0)=0;
        act(u,k)=lcaGetSmart(strcat(nameEpics(u),':BEAMCODE',cellstr(num2str(bc(u))),'_STAT'));
    end
    act(isnan(act) | is263)=0;
    use=use & isSLC;
end

if ~useAida
    % ACT status bits   STAT equivalent
    % 1: ACCEL          ~No Accel Rate & ~Maintenance & ~Offline
    % 2: STANDBY        No Accel Rate & ~Maintenance & ~Offline
    % 3: BAD            Maintenance | Offline
    act=bitset(act,3,bitget(stat,2) | bitget(stat,3));
    act=bitset(act,2,bitget(swrd,16) & ~bitget(act,3));
    act=bitset(act,1,~bitget(swrd,16) & ~bitget(act,3));
    act=act.*(stat ~= 0); % Invalid ACT if invalid STAT
else
    for j=find(use')
        matchIndx = strcmp(name{j},dgrpMatch(:,1));
        if ~any(matchIndx), dgrpStr='LIN_KLYS';else dgrpStr=dgrpMatch{matchIndx,2};end
        for k=1:size(beamCode,2)
            bc=beamCode(j,k);
            if isnan(bc) || bc < 0, continue, end
            bcStr=num2str(bc,'BEAM=%d');
            try
                requestBuilder = pvaRequest([name{j} ':TACT']);
                requestBuilder.returning(AIDA_SHORT);
                requestBuilder.with('DGRP',dgrpStr);
                act(j,k) = requestBuilder.get();
%            stat(j)=aidaget([name{j} ':STAT'],'short');
%            swrd(j)=aidaget([name{j} ':SWRD'],'short');
            catch
            end
        end
    end
end
