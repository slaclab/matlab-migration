function dualState = dualLaser_init
%function dualState = dualLaser_init
%
% LCLS specific. Identifies which UV laser is currently in the common line,
% then disables Feedback loop 2 and sets up the Pockels cell and backup
% laser timing to permit both lasers to go down and opens backup laser
% shutter.
%

% OUTPUTS:
%   dualState = structure with following fields:
%    dualState.success = 0 (no action taken), 1 (both lasers delivered)
%    dualState.primary = 1 or 2 (Coherent 1 or 2 is primary)
%    dualState.secondary = 1 or 2 (Coherent 1 or 2 is backup)
%    dualState.restoreSet = .PVs and .val (PVs to reverse changes, in order
%                           they should be restored)
%
% For GUI usage, this should be added to GUI HANDLES object to be passed to
% later to dual_laser_restore(dualState)

% TJM 07/27/2016

dualState.restoreSet.PVs = {};
dualState.restoreSet.val = {};
dualState.primary = nan;
dualState.secondary = nan;
dualState.success = 0;

% Determine which is running:
shutstate = lcaGetSmart(...
    {'SHTR:LR20:100:UV_STS',... % coh 1 shutter
    'SHTR:LR20:90:UV_STS'}% coh2 shutter
    %'MOTR:LR20:20:FLIPPER'});% LCLS-II flipper
isin = strcmp(shutstate,'IN');
isout = strcmp(shutstate,'OUT');
if isin(1) && isout(2)
    dualState.primary = 2;
    dualState.secondary = 1;
    laserpv = 'LR20:100'; % coh 1 = 100, coh2 = 90.
    unitNumBucket = 'LR20:20'; 
    %lcaPut('TRIG:LR20:LS01:TCTL', 0)%Disable Pockels cell
elseif isin(2) &&  isout (1)
    dualState.primary = 1;
    dualState.secondary = 2;
    laserpv = 'LR20:90';
    unitNumBucket = 'LR20:10';
else
    return; % indeterminate state, return and do nothing.
end

laserstr = num2str(dualState.secondary);



PVs = {...
    'LASR:IN20:160:POS_FDBK', 0;... % VCC feedback
    'FBCK:BCI0:1:ENABLE', 0;... % Bunch charge feedback also looks at VCC
    ['OSC:' unitNumBucket ':FS_ENABLE_BUCKET_FIX'], 0;... % Bucket jump detect, backup laser
    'EVR:LR20:LS02:EVENT9CTRL.ENM', 50;... % Create LS02 TS2,5 trigger (50)
    'EVR:LR20:LS02:EVENT9CTRL.OUT0', 1;... % Add trigger to Pockels cell, Ch0
    ['EVR:LR20:LS02:EVENT2CTRL.OUT' laserstr], 0;... % Take away backup laser event code 40
    ['EVR:LR20:LS02:EVENT9CTRL.OUT' laserstr], 1;... % Add backup laser event code 50
    ['SHTR:' laserpv ':UV_SHUTTER'], 0}; % backup laser shutter
% Nope nope. Don't change integration time if subtracting images.
%     'EVR:IN20:LS14:CTRL.DG0W', 9000;... % ensure long VCC integration time
%    'EVR:IN20:LS14:CTRL.DG0D', 650;... %last known good delay setting?

% Also remove Coh1 Flipper Mirror if Coh1 is backup (and restore when done)
% 10/23/2018 -- TJM, removed per Sharon, no more flipper mirror in layout.
%{
if dualState.secondary == 1
    PVs = [{'MOTR:LR20:20:FLIPPER', 0}; PVs];
    % Verify shutter closed if we're moving flipper (laser hazard)
    if isout(1) && isin(3)
        lcaPutSmart(['SHTR:' laserpv ':UV_SHUTTER'], 1);
        val = 0;k = 0;
        timeout = 20;
        while (val ~= 2) && (k <= timeout)
            val = lcaGetSmart('SHTR:LR20:100:UV_STS',1,'double');
            k = k+1;
            pause(0.5);
        end
    end
end
%}
dualState.restoreSet.PVs = flipud(PVs(:,1));
[dualState.restoreSet.val,~,ispv] = lcaGetSmart(dualState.restoreSet.PVs,1,'double');
dualState.restoreSet.val(1) = isin(dualState.secondary);
dualState.restoreSet.val = dualState.restoreSet.val([2:end,1]);
dualState.restoreSet.PVs = dualState.restoreSet.PVs([2:end,1]);

if any(isnan(dualState.restoreSet.val)) || any(~ispv);return;end %failed to get initial state
disp_log(['dual_laser_init.m is moving LS02 settings for Coh ' laserstr 'and Pockels cell.']);
for k = 1:length(PVs)
    lcaPutSmart(PVs{k,1},PVs{k,2});
    pause(0.05)
end
%if (isin(1) || isin(3)) && isout(2)
%    lcaPut('TRIG:LR20:LS01:TCTL', 1)% Enable Pockels cell
%end
dualState.success = 1;