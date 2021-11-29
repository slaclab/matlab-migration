function phase = util_phaseBranch(phase, phaseRef)
%PHASEBRANCH
%  PHASE = PHASEBRANCH(PHASE, PHASEREF) returns PHASE with the branch point
%  180 deg away from PHASEREF, i.e. PHASE will be within PHASEREF +-180.

% Input arguments:
%    PHASE: Phase values
%    PHASEREF: Reference phase where PHASE should be linear

% Output arguments:
%    PHASE: Phase made linear about PHASEREF

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 2, phaseRef=0;end
phase=mod(phase-phaseRef+180,360)+phaseRef-180;
