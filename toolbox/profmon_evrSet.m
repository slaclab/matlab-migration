function profmon_evrSet(pv)
%PROFMON_EVRSET
%  PROFMON_EVRSET(PV) Enables the trigger for the profile monitor(s) PV and
%  disables the trigger for the other profile monitors on the same IOC.
%  Waits for zero frame rate on the disabled monitor until enabling.
%
% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211
% Output arguments: none

%---------------------------------------------------------------------
% Compatibility: Version 2007b, 2012a
% Author: Henrik Loos, Greg White, SLAC
% Mod:    
%       5-Apr-2017, Sonya Hoobler, permanently removed PR55 and
%                   PR45 (were previously just commented out)
%       9-Sep-2016, Greg White: rm pr45 & pr55 in BSY in prep for LCLS2.
% --------------------------------------------------------------------

if epicsSimul_status, return, end

[pv,is]=profmon_names(pv);

if numel(pv) ~= 1
    for j=1:numel(pv), profmon_evrSet(pv(j));end
    return
end
pv=char(pv);

% Define camera - trigger IOC association.
%      {1. Camera PV     2. Camera PV     3. Camera PV     Sector  IOC#   single use}
pvList={'YAGS:IN20:211'  'YAGS:IN20:841'  ''   '' '' ''    'IN20'  'PM01' 1; ...
        'YAGS:IN20:241'  'YAGS:IN20:351'  ''   '' '' ''    'IN20'  'PM02' 1; ...
        'CTHD:IN20:206'  'OTRS:IN20:465'  ''   '' '' ''    'IN20'  'PM03' 1; ...
        'OTRS:IN20:471'  'OTRS:IN20:541'  ''   '' '' ''    'IN20'  'PM04' 1; ...
        'OTRS:IN20:571'  'OTRS:IN20:621'  ''   '' '' ''    'IN20'  'PM05' 1; ...
        'OTRS:IN20:711'  'YAGS:IN20:921'  ''   '' '' ''    'IN20'  'PM06' 1; ...
        'YAGS:IN20:995'  ''               ''   '' '' ''    'IN20'  'PM07' 0; ...
        'OTRS:LI21:237'  'OTRS:LI21:291'  ''   '' '' ''    'LI21'  'PM01' 1; ...
        'OTRS:LI24:807'  'OTRS:LI25:342'  ''   '' '' ''    'LI24'  'PM01' 1; ...
        'OTRS:LI25:920'  ''               ''   '' '' ''    'LI25'  'PM01' 0; ...
        'PROF:BSYA:1800' ''               ''   '' '' ''    'BSY0'  'PM02' 0; ...
        'OTRS:LTU1:449'  ''               ''   '' '' ''    'LTU1'  'PM01' 0; ...
%        'OTRS:LTU1:745'  ''               ''   '' '' ''    'LTU1'  'PM02' 0; ... % Temporarily gutted for PR18
        'PROF:UND1:960'  ''               ''   '' '' ''    'UND1'  'PM02' 0; ...
        'YAGS:UND1:1005' 'YAGS:UND1:1305' ''   '' '' ''    'UND1'  'PM03' 1; ...
        'YAGS:UND1:1650' ''               ''   '' '' ''    'UND1'  'PM01' 0; ...
        'OTRS:DMP1:695'  ''               ''   '' '' ''    'DMP1'  'PM10' 0; ...
        'YAGS:DMP1:500'  ''               ''   '' '' ''    'DMP1'  'PM02' 0; ...
        'YAGS:DMP1:498'  ''               ''   '' '' ''    'DMP1'  'PM03' 0; ...
%        'CAMR:FEE1:1561' 'CAMR:FEE1:1692'  ''               ''               ''              'CAMR:FEE1:913' 'FEE1' '712:1' 1; ... % P1 not connected
        ''               'CAMR:FEE1:1692'  ''               ''               ''              '' 'FEE1' '712:1' 1; ...
        ''               ''                'CAMR:FEE1:1953' '' 'CAMR:FEE1:2953'              ''              'FEE1' '712:2' 1; ...
%        ''               ''                ''               ''               'CAMR:FEE1:852' ''              'FEE1' '712:3' 0; ...
        ''               ''               'CAMR:NEH1:124'   'CAMR:NEH1:195' ''               ''              'NEH1' '121:2' 1; ...
        'CAMR:NEH1:1124' 'CAMR:NEH1:2124' ''                ''              ''               ''              'NEH1' '121:1' 1; ...
        'HXX:UM6:CVP:01' ''               ''   '' '' ''    'HXX:UM6' ''   0; ...
%        'XPP:OPAL1K:1'   ''               ''   '' '' ''    'XPP:R30' '27' 0; ...
        'YAGS:LI20:2432' 'OTRS:LI20:3158' ''   '' '' ''    'LI20'  'PM02' 0; ...
        'OTRS:LI20:3180' 'OTRS:LI20:3206' ''   '' '' ''    'LI20'  'PM04' 0; ...
};

if is.NLCTA
    pvList={
        '13PS4:cam1' '13PS2:cam1' '13PS9:cam1' '13PS5:cam1' '13PS1:cam1' '13PS3:cam1' '13PS8:cam1' '13PS7:cam1' '13PS6:cam1'
    };        
end

% For LCLS FEE/NEH cameras, enable trigger and acquire, but only ever
% disable the acquire (never disable triggers for these)

% For LCLS and FACET Area detector cameras.
if (is.LCLS || is.FACET) && is.AreaDet
    lcaPutNoWait([pv ':Acquisition'],'Acquire');
end

% Find camera in PVLIST
pvIdList=strcmp(pv,pvList(:,1:6));
% And yet another, if we aren't going to set it again below.
if (is.AreaDet2 | is.SWROI) && ~any(pvIdList(:))
    lcaPutNoWait([pv ':Acquire'],'Acquire');
end
if ~any(pvIdList(:)), return, end

% Get EVR and channel.
pvId=any(pvIdList,2);
pvPos=pvIdList(pvId,:);
pvPosOther=~pvPos & ~cellfun('isempty',pvList(pvId,1:6));
pvOther=pvList(pvId,pvPosOther)';
evrStr=['EVR:' pvList{pvId,7} ':' pvList{pvId,8} ':CTRL.'];
if strncmp(pv,'HXX',3), evrStr=[pvList{pvId,7} ':EVR' ':CTRL.'];end
chanList={'0' '1' '2' '3' '4' '5'};

if is.NLCTA
    disable_pvs=strcat(pvList(~strcmp(pv,pvList))',':Acquire');
    for idx=1:length(disable_pvs)
        try
        lcaPut(disable_pvs(idx),0);
        catch
            disp('Error disabling camera IOCs')
        end
    end
    lcaPutNoWait([pv ':Acquire'],'Acquire');
    return
end

% Disable other camera trigger.
if pvList{pvId,9}
    if ~is.Popin
        lcaPutSmart(strcat(evrStr,'DG',chanList(pvPosOther)','E'),0);
    elseif ~isempty(pvOther)
        lcaPutNoWait(strcat(pvOther, ':Acquire'),'Done'); % for FEE/NEH, don't disable trig
    end
end

% Wait until other camera is not triggered anymore.
if ~isempty(pvOther) && pvList{pvId,9}
    [~,isOther] = profmon_names(pvOther);
    pvRate = cell(size(pvOther,1),1);
    pvRate(:) = {':FRAME_RATE'};
    pvRate(isOther.AreaDet2) = {':ArrayRate_RBV'};
    t0 = now;
    while any(lcaGetSmart(strcat(pvOther,pvRate))) && (now-t0)*24*60*60 < 10, pause(0.1);end
    if (now-t0)*24*60*60 > 10, disp('Timeout for frame rate:');disp(pv);end
end

% Enable selected camera trigger.
if ~is.FrameGrab
    if ~is.Popin
        lcaPutSmart([evrStr 'DG' chanList{pvPos} 'E'],1);
    else
        lcaPutSmart([strrep(pv,'CAMR','EVR') ':TRIG' chanList{pvPos},...
            ':TCTL'],1);
        lcaPutNoWait([pv ':Acquire'],'Acquire');
    end
end

% Deselect scanning for other x-ray cameras and enable scan for image.
%{ 
% Obsolete 12-Jun-2017
if is.Popin
    if ~isempty(pvOther) && pvList{pvId,9}
        lcaPut(strcat(pvOther,':COMPRESSOR.DISV'),0);
    end
    lcaPutSmart([pv,':COMPRESSOR.DISV'],2);
%    lcaPut([pv ':IMAGE.SCAN'],6);

end
%}