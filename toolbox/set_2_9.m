function set_2_9(state, beamcode)
%SET_2_9
% GET_2_9(STATE, [BEAMCODE]) returns the current activation state of 2-9 dump
%
% Input arguments:
%   STATE:  Desired activation state of 2-9.  Activated = 1, deactivated = 0.
%   BEAMCODE: Beam code, default 10 (FACET)
%
% Author: Nate Lipkowitz, SLAC

if nargin < 2
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

if state
    str = 'reactivate';
else
    str = 'deactivate';
end

curr = get_2_9(beamcode);

if curr ~= state
    try
        da.setDaValue('TRIG:LI02:813//TACT', DaValue(java.lang.Short(state)));
        ok = 1;
    catch error
        ok = 0;
    end
else
    disp_log(strcat({'Dump 2-9 is already '}, str, {'d on beamcode '}, num2str(beamcode), {', no change'}));
    return
end

if ok
    disp_log(strcat({'Dump 2-9 '}, str, {'d on beamcode '}, num2str(beamcode)));
else
    disp_log(strcat({'Failed to '}, str, {' dump 2-9 or it was already '}, str, {'d on '}, num2str(beamcode)))
end

end



