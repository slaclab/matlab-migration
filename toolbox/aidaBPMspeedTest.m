function aidaBPMspeedTest()

% AIDA-PVA imports
global pvaRequest;

[sys,accelerator]=getSystem();
rate_pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
count = 0;
pause_time = 1; % seconds between each pvaGet

Logger = getLogger('Aida BPM Speed Test');
put2log(sprintf('Aida BPM Speed test started, interval = %.0f second(s)', pause_time));

aida_command = 'LCLS_SL2:BPMS';

while 1

    try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% the following lines were added it make this test
%% more like Glen White's Matlab script, which exhibits
%% the 58 second problem:
        requestBuilder = pvaRequest(aida_command);
        requestBuilder.with('BPMD', 55);
        requestBuilder.with('SORTORDER', 1);
        requestBuilder.with('N', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tic;
        vBPMS = ML(requestBuilder.get());
        count = count + 1;
        t(count) = toc;
        nBPMS = vBPMS.size;
        name = vBPMS.values.name;
        hsta = vBPMS.values.hsta;
        stat = vBPMS.values.stat;
        x = vBPMS.values.x;
        y = vBPMS.values.y;
        z = vBPMS.values.z;
        tmit = vBPMS.values.tmits;

        % plot
        title_s = sprintf('%s %s time(%d)=%.2fs time_{avg}=%.2fs time_{min}=%.2fs time_{max}=%.2fs', ...
            aida_command, bpmd, count, t(count), mean(t), min(t), max(t));
        subplot(3,1,1), plot(z,x), title (title_s), ylabel('x (mm)');
        subplot(3,1,2), plot(z,y), ylabel('y (mm)');
        subplot(3,1,3), plot(z,tmit), ylabel('tmit'), xlabel('z (m)');

        % issue status message every 10 iterations or if onen acq takes
        % more than 5 seconds.
        if or(isequal(0,mod(count,10)),(t(count)>5))
            put2log(title_s);
        end

    catch
        put2log('error');
        while isequal(0,lcaGet(rate_pv))
            put2log('Waiting for beam rate...');
            pause(60);
        end
    end

    pause(pause_time);

end % while
