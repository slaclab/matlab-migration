function [sectors,states] = luGetCamacState()
%
%   luGetCamacState.m
%
%   This function queries the Linac Upgrade CAMAC control PVs to see if the IOC or 
%   the micro is controlling the CAMAC on a sector-by-sector  basis. The 
%   CAMAC control PV name has the form IOC:<sector>:CV01:SWITCHSTS.RVAL.
%   A value of 0 means the micro is controlling the CAMAC; a value of 1 means 
%   the IOC is controlling the CAMAC; a value of 2 means that it is
%   unknown, in which case we will assume the micro is in control, and
%   return a 0.
%
%   	Arguments:
%                   None
%
%       Return:
%                   sectors     Vector of sector name strings
%                   states      Vector of sector states, 0 for micro, 1 for IOC
%
%
%
%

% Hard-code linac upgrade sectors as this is not likely to change or be
% used in the long-term
sectors = {'LI20'; 'LI21'; 'LI22'; 'LI23'; 'LI24'; 'LI25'; 'LI26'; 'LI27'; 'LI28'; 'LI29'; 'LI30'};
numSectors = length(sectors);
states = zeros(numSectors,1); 

% Initialize 'state' value to -1
for i=1:numSectors; states(i)=-1; end

% For each sector, determine whether IOC or micro controlling CAMAC:
%   Get CAMAC control PV, 1=IOC, 0=micro, 2=unknown. If result is 2, assume
%   micro is in control and set state to 0
%   If state value not successfully set, throw exception
for i=1:numSectors
    try
        states(i) = lcaGet(sprintf('IOC:%s:CV01:SWITCHSTS.RVAL',sectors{i}));
    catch
        err = lasterror;
        if strfind(err.identifier,'timedOut')
            states(i)=1;
            % Change fprintf to fblog
            disp(sprintf('%s CAMAC status PV timed out; assume micro is controlling %s CAMAC\n',sectors{i},sectors{i}));
        else
            dbstack;
            rethrow(lasterror);
        end
    end
    if states(i) == 2
        states(i) = 0;
    end       
    if states(i) < 0
        exception = MException('fbGetCamacState:CAMACunknown', 'Unable to determine %s CAMAC state', sectors{i});
        throw(exception);
    end
end


