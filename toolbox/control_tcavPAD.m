function act = control_tcavPAD(state, name)

if nargin < 2, name='TCAV3';end
if nargin < 1, state=[];end

if isempty(state), state=1;end
if ischar(state),state=strcmpi(state,'ACCEL');end

name=model_nameConvert(name,'MAD');

if strcmp(name,'XTCAVF')
    lcaPut('TCAV:LI20:2400:C_1_TCTL',state);
    if state, act = 1; else act = 2; end
    return
end

if strcmp(name,'XTCAV')
    return
end

% Switch to PAD on accelerate.
% Turn off LLRF phase FB.
lcaPut('TCAV:LI24:800:TC3_PHAS_FB',0);
dSTY=61180; % Accel-Standby time difference
%t0=60639;
t0=60139; % Stby time

if state
    % Set PAD trigger delay to accel.
    lcaPut('TCAV:LI24:800:TC3_D_TDES',t0-dSTY);
    lcaPut('EVR:LI24:RF01:EVENT14CTRL.OUT8',0);
    lcaPut('EVR:LI24:RF01:EVENT13CTRL.OUT8',1);
else
    % Set PAD trigger delay to standby.
    lcaPut('EVR:LI24:RF01:EVENT13CTRL.OUT8',0);
    lcaPut('EVR:LI24:RF01:EVENT14CTRL.OUT8',1);
    lcaPut('TCAV:LI24:800:TC3_D_TDES',t0);
end

% Gold PAD
pause(.5);
control_phaseGold({'TCAV3_0' 'TCAV3_1'});
