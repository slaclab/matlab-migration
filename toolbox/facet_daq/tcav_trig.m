%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_trig : function to set XTCAV PAC ACCL trigger
%             (i.e. enable/disable TCAV)
%
% state : 'Enable' to enable trigger
%         'Disable' to disable trigger
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_trig(state)

% TCAV PVs
TCAV_PV_BASE = 'TCAV:LI20:2400:';
% trigger
TRIG_SET = 'C_1_TCTL';

% do case insensitive matching for state
if strcmpi(state,'Enable')
    state = 'Enable';
    state_bool = 1;
elseif strcmpi(state,'Disable')
    state = 'Disable';
    state_bool = 0;
else
    fprintf('Could not process request for state %s. \n',state);
    error('Leaving TCAV state untouched...');
end
    
% set phase
lcaPutSmart([TCAV_PV_BASE TRIG_SET], state_bool);
     
% print trigger state to screen
fprintf('Set TCAV trigger state to "%s". \n',state);
    
end%function