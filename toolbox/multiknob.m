%multiknob.m

disp('multknob.m updated 5/31/09');
refpv = 'SIOC:SYS0:ML00:AO039';
knob{1,1} = 'SIOC:SYS0:ML00:AO040';
knob{2,1} = 'SIOC:SYS0:ML00:AO041';
knob{3,1} = 'SIOC:SYS0:ML00:AO042';
knob{4,1} = 'SIOC:SYS0:ML00:AO043';

numk = 4; % number of knobs
lcaPut([refpv, '.DESC'], 'multiknob running');


header = 'multi';

startnum = lcaGet(refpv);
pause(5);
m = 0;
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end



for k = 1:numk
    knobdes{k,1} = [knob{k,1}, '.DESC'];
    mfunc{k} = str2func('multi_null'); %initialize to null routine
    out{k} = struct;
    out{k}.num_pvs = 0;
    lcaPut(knob{k,1}, 0);
end

dat = zeros(numk,1);

delay = .03;

lcaSetMonitor(knob);
lcaSetMonitor(knobdes);
initialized = zeros(numk,1);
m = 0;
while 1
    pause(delay);
    if m > 10000
        m = 1;
    end
    m = m + 1;
    if ~mod(m,10)
        try
            lcaPut(refpv, num2str(m));
        catch
        end
    end
    try
        flags = lcaNewMonitorValue(knob);
        flagsdes = lcaNewMonitorValue(knobdes); % knob descriptions
    catch
    end
    for k = 1:numk % loop over knobs
        if flagsdes(k) || ~initialized(k) % new descriptor
            rehash % look for new versions of programs
            try
                st1 = lcaGet(knobdes{k,1});
                st = st1{1};
                disp(['new multiknob ', knob{k,1}, ' is ', st]);
                initialized(k) = 1;
            catch
            end
            if strcmp(st(1:5), header) && exist(st, 'file')
                mfunc{k} = str2func(st); % multiknob function
                in.initialize = 1;
                in.knob = 0;
                out{k} = mfunc{k}(in);
                try
                    lcaPut(knob{k,1}, 0); % set knob to zero
                    lcaPut([knob{k,1}, '.EGU'], out{k}.egu);
                catch
                end
            else
                disp('invalid multiknob');
            end
        end
    end
    for k = 1:numk % loop over knobs
        if flags(k) % new data
            try
                in.knob = lcaGet(knob{k,1});
                in.initialize = 0;
                out{k} = mfunc{k}(in);
                if out{k}.num_pvs ~= 0  % have pvs to control
                    lcaPut(out{k}.pvs, out{k}.val);
                    disp('multiknob.m');
                    disp([' writing knob ', knob{k,1}, ' ', num2str(in.knob)]);
                end

            catch
                disp('Failed lcaPut , trying to fix');
            end
        end
    end
end

lcaClear(knob);
lcaClear(knobdes);