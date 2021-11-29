function [] = vvs20_30DecrementVoltage()
%
%   vvs20_30DecrementVoltage.m
%
%   This function decrements the reference voltage of all LI20-LI30
%   VVSs by 10 V. It first checks that the VVS is not near its minimum
%   voltage.
%
%   	Arguments:
%                   None
%
%       Return:
%                   None
%
%
%


% Define value near min voltage
minVoltage = 91;

% For error logging
facility = 'MATLAB';

% Get VVS locations
try
    [loc,numLoc] = vvs20_30Common;
catch
    message=sprintf('%s: Failed to get list of VVSs. Quitting.\n',mfilename);
    disp(message);
    gpLogMsg(facility,message);
    quit;
end

% Loop through VVSs, decrementing voltage if voltage is not already near
% minimum value
for i=1:numLoc
    try
        refVoltage(i) = lcaGet(sprintf('VVS:%s:1:REFERENCE',loc{i}));
    catch
        err = lasterror;
        if strfind(err.identifier,'timedOut')
            message=sprintf('%s: %s VVS PV timed out. Quitting.\n',mfilename,loc{i});
            disp(message);
            gpLogMsg(facility,message);
            quit;
        else
            dbstack;
            rethrow(lasterror);
        end 
    end
    if (refVoltage(i) > minVoltage)
        try
            lcaPut(sprintf('VVS:%s:1:VOLTAGE_DECRCMD',loc{i}),1);
        catch
            err = lasterror;
            if strfind(err.identifier,'timedOut')
                message=sprintf('%s: %s VVS PV timed out. Quitting.\n',mfilename,loc{i});
                disp(message);
                gpLogMsg(facility,message);
                quit;
            else
                dbstack;
                rethrow(lasterror);
            end
        end            
    end
end


