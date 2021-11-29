%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_set : function to set TCAV amplitude and phase
%
% amp   : amplitude in arb. I&Q units
% phase : absolute phase in deg.
%         NOTE: '0' indicates zero-crossing
% flip  : subtracts 180 deg. to phase if set to 'flip'
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcav_set(amp, phase, flip)

tcav_amp(amp);
tcav_phase(phase,flip);

end%function