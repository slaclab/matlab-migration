function aidaBPMspeedTest()

import java.util.Vector;
aidainit;
[sys,accelerator]=getSystem();
rate_pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
count = 0;
pause_time = 1; % seconds between each getDaValue

Logger = getLogger('Aida BPM Speed Test');
put2log(sprintf('Aida BPM Speed test started, interval = %.0f second(s)', pause_time));

bpmd = 'BPMD=55';
aida_command = 'LCLS_SL2//BPMS';
import edu.stanford.slac.aida.lib.da.DaObject; 
d = DaObject;
d.setParam(bpmd);
d.setParam('SORTORDER=1');

while 1

    try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% the following lines were added it make this test 
%% more like Glen White's Matlab script, which exhibits
%% the 58 second problem:
        d.setParam('N=1');
        d.setParam('BPMD=55');
        d.setParam('SORTORDER=1');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tic;
        vBPMS = d.getDaValue(aida_command);
        count = count + 1;
        t(count) = toc;
        names = Vector(vBPMS.get(0));
        xvals = Vector(vBPMS.get(1));
        yvals = Vector(vBPMS.get(2));
        zvals = Vector(vBPMS.get(3));
        tmits = Vector(vBPMS.get(4));
        hstas = Vector(vBPMS.get(5));
        stats = Vector(vBPMS.get(6));
        nBPMS = names.size();
        for i = 1:nBPMS
            name(i) = {names.elementAt(i-1)};
            hsta(i) = hstas.elementAt(i-1);
            stat(i) = stats.elementAt(i-1);
            x(i) = xvals.elementAt(i-1);
            y(i) = yvals.elementAt(i-1);
            z(i) = zvals.elementAt(i-1);
            tmit(i) = tmits.elementAt(i-1);
            % testname = sprintf('%s:',char(name(i)));
        end

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
