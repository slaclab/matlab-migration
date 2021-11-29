% Starts the event definition data acquisition cycle and BLOCKS until
% complete or timeout is reached.

% Mike Zelazny (zelazny@slac.stanford.edu)

% eDefNumber is the number returned from eDefReserve.
% timeout in seconds

% If successful eTime will return the amount of time in seconds the
% acquisition took, otherwise eTime will be greater than or equal to timeout.

function [eTime] = eDefAcq (eDefNumber, timeout)

if (eDefNumber > 0)

    pause_time = 1.0; % seconds
    eTime = 0;
    startTime = clock;

    % press GO button
    eDefOn (eDefNumber);

    % wait for done flag
    while (true)
        if (eDefDone(eDefNumber))
            break;
        else
            eTime = etime (clock, startTime);
            if (eTime > timeout)
                eDefAbort (eDefNumber);
                break;
            else
                pause(pause_time);
            end
        end
    end
    eTime = etime (clock, startTime);
else
    eTime = timeout; % failure
end
