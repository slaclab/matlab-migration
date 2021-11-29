%
% Example on how to use lcaNewMonitorWait
%
% Note that pulse id's are encoded ito the lower 14 bits of the timestamp
% nanosecond field an count at 360Hz.
%

[sys,accelerator]=getSystem();
rate_pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];

Logger = getLogger('example lca monitor wait');
pv = cell(0);
pv{end+1} = 'BPMS:IN20:371:X'; % changes at the beam rate
pv{end+1} = 'BPMS:IN20:371:X.NAME'; % pv name
pv{end+1} = 'BPMS:IN20:371:X.DESC'; % BPM X dscription
pv{end+1} = 'BPMS:IN20:371:X.EGU'; % BPM X engineering units
pv{end+1} = rate_pv; % the beam rate
pv{end+1} = [rate_pv '.DESC']; % the beam rate description
pv{end+1} = [rate_pv '.EGU']; % the beam rate engineering units
try
    lcaSetMonitor(pv{1});
    lcaNewMonitorWait(pv{1}); % Till recommends this as it will be true immediately
    lcaGet(pv{1}); % to clear the trigger pv's event flag
    count = 0;
    tic;
    while 1
        lcaNewMonitorWait(pv{1}); % blocks until trigger pv changes
        lcaGet(pv{1}); % clear the trigger pv's event flag
        count = count +1;
        if isequal(0,mod(count,100)) % issue message once every 10 seconds (at 10 Hz) Pulse Id's should be 3600 apart.
            [values,timestamps] = lcaGet(pv', 0, 'char');
            put2log(sprintf(...
                '%s is %s %s - %s %s %s %s - BPM timestamp says %s - Pulse Id=%d - Elapsed time is %.1f s', ...
                values{6}, values{5}, values{7}, ... % beam rate
                values{2}, values{3}, values{1}, values{4}, ...% bpm data
                imgUtil_matlabTime2String(lca2matlabTime(timestamps(1))), ... % the time
                lcaTs2PulseId(timestamps(1)), ... % the pulse id
                toc)); % the elapsed time
        end
    end
catch
    put2log('Channel Access failure'); % logs to both the message log and terminal
    lcaLastError % channel access status codes
end
