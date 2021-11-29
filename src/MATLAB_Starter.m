% MATLAB_Starter.m (Zelazny) Used to quickly run any MATLAB command by setting a PV

[ sys , accelerator ] = getSystem();
[ s, hostname ] = unix('hostname');
hostname = deblank(hostname);
display = getenv('DISPLAY');

found = 0;
for i = 0 : 999
    PV = sprintf('SIOC:%s:ML01:CA%3.3d', sys, i);
    r = char(lcaGet(PV));
    if strcmp('reserved',deblank(r))
        s = sprintf('%s %s <ready>', hostname, display);
        lcaPut(PV,double(int8(s)));
        r = char(lcaGet(PV));
    end
    [node, r] = strtok(r);
    [disp, r] = strtok(r);
    if strcmp(node, hostname)
        if strcmp(disp, display)
            cntPV = sprintf('%s.DESC',PV);
            cnt_s = lcaGet(cntPV);
            count_s = strtok(cnt_s);
            count = str2num(char(count_s));
            lcaSetMonitor(PV);
            found = 1;
            break;
        end
    end
end

if found
    done = 0;
    while ~done
        try
            if lcaNewMonitorValue(PV)

                r = char(lcaGet(PV));
                [node, r] = strtok(r);
                [display, r] = strtok(r);
                [c, r] = strtok(r);
                command = deblank(c);

                if ~strcmp('<ready>', command)
                    s = sprintf('%s %s <ready>', node, display);
                    lcaPut(PV,double(int8(s)));
                    count = count + 1;
                    lcaPut(cntPV, sprintf('%d count', count));
                    tic;
                    try
                        disp(sprintf('About to %s', command));
                    catch
                        command
                    end
                    try                       
                        eval(command)
                    catch
                        '...failed!!'
                    end
                    try
                        disp(sprintf('... took %f seconds.', toc));
                    catch
                        toc
                    end
                end

            else
                pause(0.1);
                t = toc;
                if (t > (10*60*60))
                    disp(sprintf('Exiting because process was idle for %d hours', t/(60*60)));
                    exit;
                end
            end
        catch
            lcaSetMonitor(PV);
        end
    end
else
    disp(sprintf('Sorry, Can not find PV for %s %s', hostname, display));
end
exit
