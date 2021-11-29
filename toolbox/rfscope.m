%rfscope.m

loops = 10; 1e7;

% zero phases - to offset measured phase
ph0_deg(1) =109.26; % -127;
ph0_deg(2)= -120.37; %-97;
ph0_deg(3) =0; %; % -90;
ph0_deg(4) =3.6855; % 9.37; %115;


trigdelay = .25;

%time is relative to channel 1
time_pv{1,1} = 'SIOC:SYS0:ML00:AO034';
time_pv{2,1} = 'SIOC:SYS0:ML00:AO035';
time_pv{3,1} = 'SIOC:SYS0:ML00:AO036';
scope_control_pv = 'SIOC:SYS0:ML00:AO037';

lcaPut([time_pv{1,1}, '.DESC'], '25.5 MHz REF time');
lcaPut([time_pv{1,1}, '.EGU'], 'ps');
lcaPut([time_pv{2,1}, '.DESC'], 'SPPS lock voltage');
lcaPut([time_pv{2,1}, '.EGU'], 'mv');
lcaPut([time_pv{3,1}, '.DESC'], 'LCLS 119 MHz REF time');
lcaPut([time_pv{3,1}, '.EGU'], 'ps');

lcaPut([scope_control_pv, '.DESC'], 'Scope 0 manual, 1 run');


scope_data_pv{1,1} = 'SCOP:IN20:RF01:CH1';
scope_data_pv{2,1} = 'SCOP:IN20:RF01:CH2';
scope_data_pv{3,1} = 'SCOP:IN20:RF01:CH3';
scope_data_pv{4,1} = 'SCOP:IN20:RF01:CH4';

scope_trig_pv = 'SCOP:IN20:RF01:TRGMODES';
time_per_div_pv = 'SCOP:IN20:RF01:TIMEDIVM';
refpv = 'SIOC:SYS0:ML00:AO028';

disp('Starting')
startnum = lcaGet(refpv);
pause(5);
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end
disp('Running');

lcaPut([refpv, '.DESC'], 'rfscope_running');
lcaPut ([refpv, '.EGU'], ' ');

divisions = 10; % for total record KLUDGE
samples = 1000; % KLUDGE



fbase = 476e6;
f(1) = fbase;
f(2) = fbase * 6 / 112;
f(3) = 0;
f(4) = fbase / 4;
channels = 4;

inum = 1; % interpretation ratio
isamples = samples * inum; % interpretated samples

iterm = zeros(loops,channels);
qterm = zeros(loops, channels);
ph = zeros(loops, channels);
tm = zeros(loops, channels);
tm_fix = zeros(loops, channels-1);
data = zeros(channels, inum * samples);
ph0 = ph0_deg * pi / 180; % conver to radians

reset_num = 500; % reset scope after 500 cyles

% restore scope settings
lcaPut('SCOP:IN20:RF01:LDPNLSTP', 'Setup 2');
pause(1);
crun_last = 1;
rcnt = 0;
ncnt = 0;
while 1
    j = 1;
    while j <= loops
        lcaPut(refpv, num2str(ncnt));
        ncnt = mod(ncnt, 100)+1;
        crun = lcaGet(scope_control_pv);
        if crun == 1 % in run mode
            if crun_last == 0; % change in state
                crun_last = 1;
                disp('scope returning to remote');
                lcaPut('SCOP:IN20:RF01:LDPNLSTP', 'Setup 2');
                j = 1;
                pause(1);
            end
            rcnt = rcnt + 1;
            tmp = lcaGet('SCOP:IN20:RF01:TRGMODEM');
            if ~strcmp(tmp, 'STOP');
                disp('not triggered yet');
                pause(1);
                lcaPut('SCOP:IN20:RF01:LDPNLSTP', 'Setup 1');
                pause(1);
                lcaPut('SCOP:IN20:RF01:TRGMODES', 'AUTO');
                pause(2);
                lcaPut('SCOP:IN20:RF01:LDPNLSTP', 'Setup 2');
                pause(1);


                lcaPut('SCOP:IN20:RF01:TRGSRCS', 'C2');
                pause(1);
                lcaPut(scope_trig_pv, 'NORMAL');
                pause(1);
                lcaPut('SCOP:IN20:RF01:TRGSRCS', 'C1');
                pause(1);
                lcaPut(scope_trig_pv, 'SINGLE');
                pause(1);
                disp('Done reset');
                lcaPut(scope_trig_pv, 'STOP');
            end
            pause(trigdelay);
            time_per_div = lcaGet(time_per_div_pv);
            datax = lcaGet(scope_data_pv);
            lcaPut(scope_trig_pv, 'SINGLE');
            pause(trigdelay);
            


            if inum ~= 1
                for k = 1:channels
                    data(k,:) = interp(datax(k,1:samples),inum);
                end
            else
                data = datax;
            end
            sample_time = time_per_div / isamples * divisions;
            time = sample_time*(cumsum(ones(isamples,1))-1);
            cycles = floor(samples*f*sample_time);
            for k = 1:channels
                if k == 1
                    us = round(isamples / 2);
                else
                    us = isamples;
                end
                wf = hann(us);
                iterm(j,k) = sum(sin(2*pi*f(k)*time(1:us)).*data(k,1:us)'.*wf);
                qterm(j,k) = sum(cos(2*pi*f(k)*time(1:us)).*data(k,1:us)'.*wf);
                itmp = iterm(j,k) * cos(-ph0(k)) - qterm(j,k) * sin(-ph0(k)); % rotate phase
                qtmp = iterm(j,k) * sin(-ph0(k)) + qterm(j,k) * cos(-ph0(k));
                ph(j,k) = atan2(qtmp, itmp);
                amp = iterm.*iterm + qterm.*qterm;
                tm(j,k) = ph(j,k) /(2 * pi * f(k));
                if (k == 2) || (k == 4)
                    tm_fix(j,k-1) = 1e12*(tm(j,k) - tm(j,1)); % time relative to 476MHz
                elseif k == 3
                    tm_fix(j,k-1) = 1000 * mean(data(k,1:us));
                end
            end
            j = j + 1;
        else
            if crun_last == 1 % change in state
                crun_last = 0;
                lcaPut('SCOP:IN20:RF01:LDPNLSTP', 'Setup 1');
                pause(1);
                lcaPut(scope_trig_pv, 'NORMAL');
                disp('Scope in manual control');
            end
        end
    end
    md_fix = median(tm_fix); % median values for each.
    mdx = zeros(loops, channels-1);
    sdx = std(tm_fix);
    bad = zeros(loops);
    for n = 1:loops
        bad(n);
        for m = 1:channels -1;
            if abs(tm_fix(n,m) - md_fix(m)) > sdx(m) % bad data
                bad(n) = 1;
            end
        end
    end
    goodnum = 0;
    for n = 1:loops
        if ~bad(n)
            goodnum = goodnum + 1;
            mdx(goodnum,:) = tm_fix(n,:);
        end
    end
    if goodnum == 0
        tm_fix_av = zeros(1,3);
    else
        tm_fix_av = mean(mdx(1:goodnum,:));
    end
    disp(tm_fix_av);
    %tm_fix_avg = md_fix;
    lcaPut(time_pv, tm_fix_av'); % write output variables.
end



