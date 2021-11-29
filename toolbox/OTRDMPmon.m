function [ out ] = OTRDMPmon(  )
%OTRDMPmon Pulls the OTRDMP YAG screen if the XTCAV is not on.
%   Monitors the OUT limit switch the OTR Dump YAG screen, if the Screen is
%   NOT OUT and the XTCAV does not have (a) Accelerate triggers, and (b)
%   sufficient amplitude to smear out the beam on the screen, then pull the
%   screen after a designated amount of time.
%   Note:  Does not pull OTRDMP if TDUND is IN.

disp('OTRDMPmon.m, v1.0, 8/1/2014');
%
delay = 5.0; % loop cycle time, seconds
watchdog_pv = 'SIOC:SYS0:ML01:AO424';
L = generate_pv_list(); %
ringsize = 10;
lcaSetSeverityWarnLevel(5); % disable almost all warnings
W = watchdog(watchdog_pv, 1, 'OTRDMPmon.m');
d  = lcaGetSmart(L.pv, 16000, 'double'); % get data
lcaSetMonitor(L.pv); % set up monitor
D = cell(ringsize,1); % will hold all data
F = cell(ringsize,1); % will hold monitor flags
D{1}= d;  F{1} = zeros(length(d),1);  %just initialize
ctr = 1;  % start at 2, initialize old data
cycle = 0; %
target_in_time = 0;
%%
while 1 % Loop forever
    cycle = cycle + 1;
    if ctr > ringsize
        ctr = 1;
    else
        ctr = ctr + 1;
    end
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp('Some sort of watchdog error');
        break;  % Exit program
    end
    try
        flags = lcaNewMonitorValue(L.pv); % look for new data
    catch
        disp(['lca get error', '  ', num2str(cycle)]);
    end
    if sum(flags) % There is some new data to look at
        d = lcaGetSmart(L.pv, 16000, 'double'); % get data
        D{ctr} = d;  % save in structures to analyze later
        F{ctr} = flags;
    else
        continue; % nothing to do here
    end
    
    stats.TDUNDin           = d(L.TDUND_IN_n);
    stats.OTRDMPout         = d(L.OTRDMP_OUT_n);
    stats.TCAV_ACC          = d(L.TCAV_MOD_state_n);
    stats.TCAV_ampl         = d(L.TCAV_ampl_n);
    stats.screenTime_ctr    = target_in_time;
    ctrl.TCAV_ampl          = d(L.TCAV_ampl_setpt_n);
    ctrl.screenTime         = d(L.pullScreen_time_n);
    
    pullScreen_PV = L.pv{L.pullScreen_PV_n, 1};  % TRIP PV
    OTRDMP_command = L.pv{L.OTRDMP_PNEU_n, 1};  % TRIP PV
    [trip out] = trip_logic(ctrl, stats);
    
    if trip
        disp(out.message);
        target_in_time = target_in_time + delay;
        lcaPutSmart(pullScreen_PV, 1); % declare intention to pull YAG
        if target_in_time > ctrl.screenTime
            lcaPutSmart(OTRDMP_command, 0) ; % Pull the YAG for real
            disp(['Pulling OTRDMP1 screen ', out.message]);
            pause(1);
        end
    end
    if ~trip
        lcaPutSmart(pullScreen_PV, 0); % declare OK to insert YAG
        disp(['OTRDMP1 OK', out.message]);
        target_in_time = 0;
    end
    
    
    if cycle >= 1 %
        output.pv{1,1} = L.pv{L.TCAV_ON_n, 1}; % place to stash the TCAV status
        output.value(1,1) = out.TCAV_on; % the TCAV status as determined by us
        output.pv{2,1} = L.pv{L.pullScreen_countup_n, 1}; % countUp to pulling the screen out
        output.value(2,1) = stats.screenTime_ctr; % counter
        try
            lcaPutSmart(output.pv, output.value);
           % disp('Writing stats to Matlab PVs ML01 426+');
        catch
            disp('failed to save temp stats');
        end
    end
    
end
end
%%
function L = generate_pv_list()
n = 0;
pvstart = 424; %set up the storage slots = matlab PVs in ML01
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'Is XTCAV ON and up? (-1 = so what)', '1=yes', 0, 'OTRDMPmon.m');
L.TCAV_ON_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'XTCAV amplitude minimum setting', 'MV', 3, 'OTRDMPmon.m');
L.TCAV_ampl_setpt_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'Begin Pull Screen timer?', '1=yes', 0, 'OTRDMPmon.m');
L.pullScreen_PV_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'Time beam allowed on screen', 'sec', 0, 'OTRDMPmon.m');
L.pullScreen_time_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n , 'countUp to Pull screen', 'sec', 0, 'OTRDMPmon.m');
L.pullScreen_countup_n = n;
% Actual data PVs
n = n + 1;
L.pv{n,1} = 'KLYS:DMP1:1:MOD'; % XTCAV KLYS Mode, ACC = 1
%L.pv{n,1} = 'SIOC:SYS0:ML01:AO422'; %DUMMY for testing logic
L.TCAV_MOD_state_n = n;
n = n + 1;
L.pv{n,1} = 'TCAV:DMP1:360:S_AV'; % XTCAV amplitude
%L.pv{n,1} = 'SIOC:SYS0:ML01:AO423'; %DUMMY for testing logic
L.TCAV_ampl_n = n;
n = n + 1;
L.pv{n,1} = 'OTRS:DMP1:695:OUT_LMTSW'; % OTRDMP out = 1
L.OTRDMP_OUT_n = n;
n = n + 1;
L.pv{n,1} = 'OTRS:DMP1:695:PNEUMATIC'; % command to OTRDMP OUT = 0
L.OTRDMP_PNEU_n = n;
n = n + 1;
L.pv{n,1} = 'DUMP:LTU1:970:TDUND_IN'; % is TDUND IN? (ignore OTRDMP if Y)
L.TDUND_IN_n = n;
end
%%
function [trip out] = trip_logic(ctrl, stats)
%
trip = 0;
out.TCAV_on = -1; %-1 = bypass, who cares, OTR is OUT
out.message = ' Monitoring OTRDMP target to limit exposure with TCAV OFF ';
%
% we only care about the OTR if there might be beam on it, so 
% if TDUND is IN (which is usually the case when the beam is intentionally
% OFF), we're not going to care about OTRDMP
if ~(stats.TDUNDin == 1)
    % if OTR NOT OUT ...
    if ~(stats.OTRDMPout == 1)
        out.message = ' OTRDMP target is IN and ';
        % ... and XTCAV not on
        if  ~(stats.TCAV_ACC == 1)
            out.TCAV_on = 0;
            out.message = [out.message 'TCAV_ACC not ON'];
            trip = 1;
            % ... or if it's on but amplitude is too low
        elseif stats.TCAV_ampl < ctrl.TCAV_ampl
            out.TCAV_on = 0.5;
            out.message = [out.message 'TCAV on but AMPL low '];
            trip = 1;
        else
            out.TCAV_on = 1;
            out.message = ' TCAV ON, OK to insert OTRDMP target ';
        end
    end
end
end
%%
function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
    numstr = ['00', numtxt];
elseif numlen == 2
    numstr = ['0', numtxt];
else
    numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML01:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end


function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end
