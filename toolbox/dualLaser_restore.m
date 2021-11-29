function success = dualLaser_restore(dualState)
%function success = dual_laser_restore(dualState)
%
% LCLS specific. Restores which UV laser is currently in the common line
% based on prior execution of dual_laser_init
%

% OUTPUT:
%   success = Logical of whether or not we succeeded
%
% INPUTS:
%   dualState = structure from dual_laser_init with following fields:
%    dualState.success = 0 (no action taken), 1 (both lasers delivered)
%    dualState.primary = 1 or 2 (Coherent 1 or 2 is primary)
%    dualState.backup = 1 or 2 (Coherent 1 or 2 is backup)
%    dualState.restoreSet = .PVs and .val (PVs to reverse changes, in order
%                           they should be restored)
%
% For GUI usage, this should be added to GUI HANDLES object to be passed to
% later to dual_laser_restore(dualState)
success = 0;
if ~dualState.success;return;end
good = zeros(1,length(dualState.restoreSet.val));
disp_log(['dual_laser_restore.m is restoring LS02 settings for Coh ' num2str(dualState.secondary) 'and Pockels cell.']);

if dualState.secondary == 1;
    laserpv = 'LR20:100'; % coh 1 = 100, coh2 = 90.
else
    laserpv = 'LR20:90';
end

% Verify shutter closed for secondary before doing anything.
lcaPutSmart(['SHTR:' laserpv ':UV_SHUTTER'], 1);
val = 0;k = 0;
timeout = 40;
while (val ~= 2) && (k <= timeout)
    val = lcaGetSmart(['SHTR:' laserpv ':UV_STS'],1,'double');
    k = k+1;
    pause(0.5);
end

N = numel(dualState.restoreSet.PVs);
for k = 1:N
    if k == N;pause(10);end
    good(k) = lcaPutSmart(dualState.restoreSet.PVs{k},dualState.restoreSet.val(k));
    pause(0.05)
end

if all(good);dualState.success = 1;end