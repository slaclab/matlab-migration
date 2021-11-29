%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_set : function to set TCAV phase
%
% phase : absolute phase in deg.
%         NOTE: '0' indicates zero-crossing
% flip  : subtracts 180 deg. to phase if set to 'flip'
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_phase(phase, flip)

% TCAV PVs
TCAV_PV_BASE = 'TCAV:LI20:2400:';
% phase (deg. X-band)
PHASE_SET = 'PDES';

% flip the phase (i.e. add 180 deg.) if asked
if nargin<2; flip=''; end
if nargin>=2 && strcmp(flip,'flip'); phase = phase + 180; end

% set phase
lcaPutSmart([TCAV_PV_BASE PHASE_SET], phase);
     
% print amp and phase to screen
fprintf('Set TCAV phase to %d deg. X-band. \n',phase);
    
end%function
