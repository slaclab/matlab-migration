%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_set : function to set TCAV amplitude
%
% amp   : amplitude in arb. I&Q units
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_amp(amp)

% TCAV PVs
TCAV_PV_BASE = 'TCAV:LI20:2400:';
% amplitude (MV)
AMP_SET   = 'ADES';
MAX_AMP   = 30.0; % MV

% check amplitude is within bounds
if (amp>1.1*MAX_AMP)
    error('Desired amplitude exceeds maximum allowable TCAV amplitude.');
elseif (amp < 0)
    error('Desired amplitude is less than zero.');
else

    % set amp
    lcaPutSmart([TCAV_PV_BASE AMP_SET], amp);
     
    % print amp and phase to screen
    fprintf('Set TCAV amp to %d MV. \n',amp);
    
end%if


end%function
