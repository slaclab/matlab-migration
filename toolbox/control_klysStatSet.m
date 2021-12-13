function act = control_klysStatSet(name, stat, beamCode)
%KLYSSTATSET
%  ACT = KLYSSTATSET(NAME, STAT, BEAMCODE) Activate or deactivate klystrons in list
%  NAME. Returns new activation status.

% Features:

% Input arguments:
%    NAME:     String or cell string array for base name of klystron or MAD alias.
%    STAT:     Desired activation status value or list
%              1: Activated
%              0: Deactivated
%    BEAMCODE: Beam code(s) for klystrons, default 1 (LCLS) or 10 (FACET)

% Output arguments:
%    ACT: Actual klystron activation status after setting

% Compatibility: Version 2007b, 2012a
% Called functions: getSystem, aidaget, DaObject, control_klysStatGet,
%                   control_klysName, lcaPut, lcaPutSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments
if nargin < 3
    [sys,accel]=getSystem;
    beamCode=1;
    if strcmp(accel,'FACET')
        rate = lcaGetSmart({'EVNT:SYS1:1:BEAMRATE' 'EVNT:SYS1:1:POSITRONRATE'});
        if rate(1) >= rate(2)
            beamCode=10; % FACET e-
        else
            beamCode=6;  % FACET e+
        end
    end
end

name=cellstr(name);name=name(:);stat=stat(:);nName=numel(name);
beamCode(end+1:nName,:)=repmat(beamCode(end,:),nName-size(beamCode,1),1);
act=control_klysStatGet(name,beamCode);

% Check for TCAV.
[name,nameEpics,isSLC]=control_klysName(name);
isTCAV=ismember(name,{'KLYS:LI20:51' 'KLYS:LI24:81'});

% Find TRIG devices.
isTrig=~cellfun('isempty',strfind(name,'TRIG'));
isMK2=strncmp(name,'KLYS:DMP',8);

% Find klystrons to change.
isSet=~bitget(act,3) & (bitget(act,2) == stat);
isSet(isTrig)=act(isTrig) ~= stat(min(find(isTrig),end));

if epicsSimul_status
    statj=stat(min(find(isSet),end));
%    lcaPut(strcat(name,'_S_AV'),stat);
%    lcaPut(strcat(name,'_ADES'),stat);
    lcaPut(strcat(nameEpics,':TACT'),stat);
%    act=control_klysStatGet(name);
    if ~any(isSet), return, end
    disp(char(strcat({'Trying '},name(isSet),{' to set to '},num2str(statj))));
    return
end

% Return if nothing to set.
if ~any(isSet | isTCAV), return, end

% Try MKSU-II controls.
use=isMK2 & isSet;
if any(use)
    statj=stat(min(find(use),end));
    lcaPut(strcat(nameEpics(use),':MOD_SET'),2-double(statj));
end

% Try EPICS controls.
use=~isSLC & isSet & ~isMK2;
if any(use)
    statj=stat(min(find(use),end));
    lcaPut(strcat(nameEpics(use),':BEAMCODE',num2str(beamCode(use,1)),'_TCTL'),double(statj));
end

% Do uTCA.
isMTC=strcmp(name,'KLYS:LI28:21'); % uTCA controlled
if any(isMTC), isMTC=isMTC & lcaGetSmart('LLRF:LI28:21:MTCAON',0,'double') == 1;end % Catches NaN
if any(isMTC)
  lcaPutSmart('LLRF:LI28:21:LLA_USRCMD_KLYMD',stat(min(find(isMTC),end)));
end

% Activate/deactivate klystrons.
global da
if any(isSet & isSLC & ~isMK2)
    da.setParam('BEAM',num2str(beamCode(1,1)));
    if ~any(isTrig), da.setParam('DGRP','LIN_KLYS');end
end

for j=find(isSet & isSLC & ~isMK2)'
    statj=stat(min(j,end));
    disp(['Trying ' name{j} ' to set to ' num2str(statj)]);
    try
        requestBuilder=pvaRequest([name{j} ':TACT']);
        requestBuilder.with('BEAM', beamCode(1,1));
        if ~any(isTrig), requestBuilder.with('DGRP', 'LIN_KLYS'); end
        out=requestBuilder.set(statj);
    catch e
        handleExceptions(e, ['Failed to set ' name{j} ' to activation ' num2str(statj)]);
    end
end
%import java.util.Vector;
for j=find(isTCAV)'
    statj=stat(min(j,end));
    if strcmp(name{j},'KLYS:LI24:81')
        lcaPut('TCAV:LI24:800:TC3_C_1_TCTL',statj);
    elseif strcmp(name{j},'KLYS:LI20:51')
        lcaPut('TCAV:IN20:490:TC0_C_1_TCTL',statj);
    end

end
act(isSet)=control_klysStatGet(name(isSet),beamCode(isSet));
