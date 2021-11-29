function [G, F] = fbGetMatLaunchMatrices(name)
% function [G, F] = fbGetMatLaunchMatrices(NAME)
%
% This function calculates the G and F matrices for fast transverse
% feedback with EPICS rootname NAME (e.g., FBCK:FB01:TR01) based on
% the EPICS FB configuration and extant (Matlab) model.

% On LCLS, this will assume copper linac as source and select the
% downstream region associated with the devices configured in feedback for
% beampath.

[CORs,BPMs] = fbGetUsedTrDevices(name);
if isempty(CORs) || isempty(BPMs)
    G=[];F=[];
    warning('fbGetMatLaunchMatrices: Trouble getting at least one expected EPICS config PVs');return;end

% Exception handling: For one-plane feedbacks, workaround was to use 2D and
% use NULL device named actuators in the other plane. Check for this case.
isNullCor = strcmpi(CORs,'NULL');
[a,bC,c] = model_nameSplit(CORs);
CORs = strcat(a,':',bC,':',c);
isXcor = strcmpi(a,'XCOR');
isYcor = strcmpi(a,'YCOR');

[a,bB,c,xy] = model_nameSplit(BPMs);
BPMs = strcat(a,':',bB,':',c);
isXbpm = strcmpi(xy,'X');
isYbpm = strcmpi(xy,'Y');
if (sum(isXbpm) ~= sum(isYbpm)) || ~all(strcmpi(BPMs(isXbpm),BPMs(isYbpm)))
    warning(['EPICS BPM config for ' name ' not consistent. X and Y BPM list must use same devices.'])
    G = nan;F= nan;return;
end
BPMs = BPMs(isXbpm);

% Usually use first X BPM as reference.
refBPM = 1;
% Exception handling! Maybe the ref BPM index should be in EPICs.
if strcmpi(name,'FBCK:FB02:TR03')
    refBPM = sum(isXcor); % This uses the last BPM instead of first (is in DL2)
end
% Name the chosen one.
refBPM = BPMs{refBPM};

% Corrector kick matrix, Get Rn2's for X, Rn4's for Y:
if numel(BPMs) == 1 % position FB only
    incl = [1,3];
else
    incl = 1:4;
end

% What is your beampath?
if strcmp(getSystem,'SYS0')
    if any(ismember([bB;bC],...
            {'BSYS','LTUS','UNDS','DMPS'}));
        beamPath = 'CU_SXR';
    else
        beamPath = 'CU_HXR';
    end
    model_init('SOURCE','MATLAB','useBDES',1,'beamPath',beamPath);
else
    model_init('SOURCE','MATLAB','useBDES',1);
end

G = zeros(numel(incl),numel(CORs)); % isNull devices will have "0" matrices...
r=model_rMatGet(CORs(isXcor),refBPM);
G(:,isXcor)=squeeze(r(incl,2,:));
r=model_rMatGet(CORs(isYcor),refBPM);
G(:,isYcor)=squeeze(r(incl,4,:));
% Careful... G rows are coordinates, columns are BPMs. Waveforms expect
% rows are BPMs (first values are for first BPM)
G = G.';

% Feedback matrix, Get first 5 R1n's for X, R3n's for Y:
F = zeros(5,numel(BPMs)*2);
r=model_rMatGet(refBPM,BPMs);
F(:,isXbpm) = squeeze(r(1,1:5,:));
F(:,isYbpm) = squeeze(r(3,1:5,:));
% For F, rows are coordinate, columns are per device, so we're good.


function [CORs,BPMs] = fbGetUsedTrDevices(name)
% Funciton to get the list of actuators and references for a fast orbit
% feedback configured in EPICS.
nums = lcaGetSmart(strcat(name,{':MEASNUM';':ACTNUM'}));
if any(isnan(nums))
    CORs='';BPMs='';return;end
[pvs,~,ispv] = lcaGetSmart([strcat(name,':M',strtrim(cellstr(num2str((1:nums(1)).'))),'DEVNAME');...
    strcat(name,':A',strtrim(cellstr(num2str((1:nums(2)).'))),'DEVNAME')]);
if any(~ispv)
    CORs='';BPMs='';return;end
BPMs = pvs(1:nums(1));
CORs = pvs(nums(1)+1:end);
% Only active devices are included in matrix waveforms.
[pvs,~,ispv] = lcaGetSmart([strcat(name,':M',strtrim(cellstr(num2str((1:nums(1)).'))),'USED');...
    strcat(name,':A',strtrim(cellstr(num2str((1:nums(2)).'))),'USED')],1,'double');
if any(~ispv)
    CORs='';BPMs='';return;end
usedBPMs = pvs(1:nums(1));
usedCORs = pvs(nums(1)+1:end);
BPMs(~usedBPMs) = [];
CORs(~usedCORs) = [];