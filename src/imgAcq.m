% Starts the image acquisition cycle and BLOCKS until complete or timeout 
% is reached.

% Mike Zelazny (zelazny@slac.stanford.edu)

% timeout in seconds

% If successful eTime will return the amount of time in seconds the
% acquisition took, otherwise eTime will be greater than or equal to timeout.

function [eTime] = imgAcq (timeout)

pause_time = 1.0; % seconds
eTime = 0;

% press GO button
imgAcqOn;

% wait for done flag
startTime = clock;
while (true)
    try
        if (imgAcqDone)
            break;
        else
            eTime = etime (clock, startTime);
            if (eTime > timeout)
                imgAcqAbort;
                break;
            else
                pause(pause_time);
            end
        end
    catch
        imgAcqAbort;
        break;
    end
end