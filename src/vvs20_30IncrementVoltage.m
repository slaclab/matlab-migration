function [] = vvs20_30IncrementVoltage()
%
%   vvs20_30IncrementVoltage.m
%
%   This function increments the reference voltage of all LI20-LI30
%   VVSs by 10 V. It first checks that the VVS is not near its maximum
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


% Define value near max voltage
maxVoltage = 119;

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

% Loop through VVSs, incrementing voltage if voltage is not already near
% maximum value
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
    if (refVoltage(i) < maxVoltage)
        try
            lcaPut(sprintf('VVS:%s:1:VOLTAGE_INCRCMD',loc{i}),1);
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


