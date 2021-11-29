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

if nargin < 1
    beamcode = 10;  % BC10 is FACET
end

global da;
aidainit;
if isempty(da), 
   import edu.stanford.slac.aida.lib.da.DaObject; 
   da=DaObject; 
end

da.reset;
da.setParam('BEAM', num2str(beamcode));
try
    state = da.get('TRIG:LI02:813//TACT', 9);
catch
    state = NaN;
end