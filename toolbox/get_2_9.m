function state = get_2_9(beamcode)
%GET_2_9
% [STATE] = GET_2_9(BEAMCODE) returns the current activation state of 2-9 dump
%
% Input arguments:
%   BEAMCODE: Beam code, default 10 (FACET)
%
% Output arguments:
%   STATE:  Activation state of 2-9.  Activated = 1, deactivated = 0.
%
% Author: Nate Lipkowitz, SLAC

% AIDA-PVA imports
aidapva;

if nargin < 1
    beamcode = 10;  % BC10 is FACET
end


try
    requestBuilder = pvaRequest('TRIG:LI02:813:TACT');
    requestBuilder.with('BEAM', beamcode);
    requestBuilder.returning(AIDA_SHORT);
    state = requestBuilder.get();
catch
    state = NaN;
end
