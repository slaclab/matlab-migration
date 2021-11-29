%GUNB_BakeGuardian.m

function out = GUNB_BakeGuardian()
disp('GUNB_BakeGuardian.m 10/26/2018 v1.02');
%
% 11/20/18 - add extractor gauge option
% 10/26/18 - add vacG filament status, new VARIAC circuit 6
%
global DISABLE_TRIP;
DISABLE_TRIP = 0;  %%%%%%%%% Should be 0 for normal opearation
%
delay = 0.5; % loop rate
watchdog_pv = 'SIOC:SYS0:ML04:AO050';%check this

L = generate_pv_list(); %
lcaSetSeverityWarnLevel(5); % disables almost all warnings
W = watchdog(watchdog_pv, 5, 'GUNB_BakeGuardian.m');
d  = lcaGetSmart(L.pv, 16000, 'double'); % once through to get initial data
lcaSetMonitor(L.pv); % set up monitor
stats = struct;
max_strikes = 1; 
strikes = 0;
cycle = 0;
startup_msg_str = ['Starting GUNB Bakeout Guardian  ', datestr(now)];
sty = double(int8(startup_msg_str));
lcaPutSmart(L.error_string_pv, sty);
%reset to start
lcaPutSmart(L.pv{L.trip_reset_n,1}, 0); 
%
while 1 % Loop forever
    cycle = cycle + 1;
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp(['Some sort of watchdog error  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        break;  % Exit program
    end
    try
        flags = lcaNewMonitorValue(L.pv); % look for new data
    catch %#ok<*CTCH>
        disp(['lca get error', '  ', num2str(cycle), '  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
    end
    if sum(flags) % There is some new data to look at
        d = lcaGetSmart(L.pv, 16000, 'double'); % get data
    else
        continue; % nothing to do here
    end
    %
    %stats are the things moniotred
    stats.TripStatus = d(L.trip_status_n);      % Guardian says trip
    stats.TripReset = d(L.trip_reset_n);        % manual reset required
    stats.RFon = d(L.GunRF_ON_n);               % GUN RF open loop amplitude
    stats.CuTemps = d(L.GunBodyCuTemps_n(:));   %
    stats.SSTemps = d(L.GunBodySSTemps_n(:));   %
    stats.CPLRTemps = d(L.GunCPLRTemps_n(:));   %
    stats.gunanouttemp = d(L.GunANOUTtemp_n);   % not included in Gun Cu temps, too low
    stats.bucktemp = d(L.BuckCoilTemp_n);       % 
    stats.solntemp = d(L.SolenoidTemp_n);       %
    stats.gvalvetemp = d(L.GateValveTemp_n);    %
    stats.sprinktemp= d(L.SprinklerTemp_n);     % Room air temp
    stats.gunvac = d(L.GunVac_n);               % IonGaurge 100
    stats.gunvacfil = d(L.GunVacFilament_n);    % VGHF On/Off status, 0 = Off
    stats.gunvacxig = d(L.GunVacXIG_n);         % Extractor ion gauge 100
    stats.gunvacxighv = d(L.GunVacXIGstat_n);   % Extractor gauge sensor status
    stats.bypassgunvacfil = d(L.GunVacFilBypass_n); % bypass vac filament trip
    stats.lebEstopstat = d(L.LEBestopStatus_n); % 0=FAULT, 1 = OK
    for nv = 1:5
        stats.varstats(nv) =  d(L.Variac(nv).POWERSTATE_n);
    end
    %
    %
    % ctrl are the setpoints
    ctrl.maxmaxtemp = d(L.AnyRTDHigh_n);        % Absolute max allowed
    ctrl.maxRFwintemp = d(L.RFWindowsHigh_n);   % Max for both RF windows
    ctrl.maxgunvac = d(L.GunVacHigh_n);         % max pressure
    ctrl.maxsprinktemp = d(L.SprinklerHigh_n);  % 
    ctrl.maxCuSSdeltaT = d(L.CuSSdeltaTHigh_n); % max temp difference Cu-SS
    ctrl.maxsolntemp = d(L.SolnBuckHigh_n);     % Max for bucking coil and solenoid
    ctrl.maxgvalvetemp = d(L.GateValveHigh_n);  % MaxT for Gate Valve
    ctrl.maxwhat1 = d(L.Future1High_n);         % I'm sure they'll want more
    ctrl.maxwhat2 = d(L.Future2High_n);         %
    ctrl.useVGXIG = d(L.UseXIG_n);              % Use VGXIG instead of VGHF?  
    
    [trip out] = trip_logic(ctrl, stats);  %%%%%% MAIN TRIP LOGIC IS HERE
    
    % don't just update these if bake is on, do it all the time...
    output.pv{1,1} = L.pv{L.bakeIsOn_rb_n, 1}; % Sanity check
    output.value(1,1) = out.bake_on;
    output.pv{2,1} = L.pv{L.maxCuTemp_rb_n, 1}; % maximum tCu temp
    output.value(2,1) = out.maxCuTemp;
    output.pv{3,1} = L.pv{L.maxSSTemp_rb_n, 1}; % maximum SS temp
    output.value(3,1) = out.maxSSTemp;
    output.pv{4,1} = L.pv{L.maxCPLRTemp_rb_n, 1}; % maximum CPLR temp
    output.value(4,1) = out.maxCPLRTemp;
    output.pv{5,1} = L.pv{L.minCuTemp_rb_n, 1}; % mimium Cu temp
    output.value(5,1) = out.minCuTemp;
    output.pv{6,1} = L.pv{L.minSSTemp_rb_n, 1}; % maxinimum SS temp
    output.value(6,1) = out.minSSTemp;
    output.pv{7,1} = L.pv{L.maxRTDallTemp_rb_n, 1}; % maxi temp of alls
    output.value(7,1) = out.maxRTDtemp;
    output.pv{8,1} = L.pv{L.maxRFwinTemp_rb_n, 1}; % max RF window temp
    output.value(8,1) = out.maxRFwintemp;
    output.pv{9,1} = L.pv{L.LEBestopStatus_rb_n, 1}; %LEB status readback
    output.value(9,1) = out.LEBestopstat;
    
    lcaPutSmart(output.pv, output.value);
    %    end
    
    if trip
        strikes = strikes + 1;
        if strikes > max_strikes % really trip
            bake_control(0, L); % turns off bake
            disp([out.message, '  ', datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF')]);
            sty = double(int8(out.message));
            lcaPutSmart(L.error_string_pv, sty);
            disp(['Terminating bake  ', out.message, '  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
            pause(1);
        else
            disp(['First strike   ', out.message, '  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        end
    elseif out.bake_on  % not tripped, below critical temp
        if strikes
            disp(['Strike cleared  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
            msg_str = ['Clearing single strike...  ', out.message, datestr(now)];
            sty = double(int8(msg_str));
            lcaPutSmart(L.error_string_pv, sty);
        end
        strikes = 0;
    end
    if ~trip && d(L.trip_reset_n)  % reset trip
        disp(['Resetting trip  ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        lcaPutSmart(L.pv{L.trip_reset_n,1}, 0); % reset trip
        sty = double(int8(out.message));
        lcaPutSmart(L.error_string_pv, sty); %
        pause(1);
        bake_control(1, L); % restore bake power
    end
end

out.stats = stats;
lcaClear; % clear all monitors
end

%%
% generates list of all PVs
% S.p{n,1} is pv name
function L = generate_pv_list()
%put generated matlab PVs first...
n = 0;
pvstart = 15;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Guardian thinks bake is on', '1=on', 0, 'GUNB_BakeGuardian.m');
L.bakeIsOn_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Bakeout Trip reset', '1=rst', 0, 'GUNB_BakeGuardian.m');
L.trip_reset_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'Bakeout Trip Status', '1=trp', 0, 'GUNB_BakeGuardian.m');
L.trip_status_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'minimum Cu temp ', 'degC', 3, 'GUNB_BakeGuardian.m');
L.minCuTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'maximum Cu temp ', 'degC', 3, 'GUNB_BakeGuardian.m');
L.maxCuTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'minimum SS temp', 'degC', 3, 'GUNB_BakeGuardian.m');
L.minSSTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'maximum SS temp', 'degC', 3, 'GUNB_BakeGuardian.m');
L.maxSSTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'maximum coupler temp', 'degC', 3, 'GUNB_BakeGuardian.m');
L.maxCPLRTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'maximum of all RTD temps', 'degC', 3, 'GUNB_BakeGuardian.m');
L.maxRTDallTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'maximum RFwindow temp', 'degC', 3, 'GUNB_BakeGuardian.m');
L.maxRFwinTemp_rb_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(pvstart + n  , 'LEB Spider Box Status', '1=on', 0, 'GUNB_BakeGuardian.m');
L.LEBestopStatus_rb_n = n; 
%
%%%% THE DUMMY PVs %%%%
% Built the same was as real action PVs
dummypvstart = 52;
extstr{1} = {'ON'};
extstr{2} = {'OFF'};
for m = 1:5
    for k = 1:2
        n = n + 1;
        L.pv{n,1} = setup_pv(dummypvstart + n  , ['dummy test pv' num2str(m) char(extstr{k})], '1/0', 0, 'GUNB_BakeGuardian.m');
        eval(['L.dummy(m).', char(extstr{k}), '_n = n;']);
    end
end
%%%%%
%
%Fixed-name PVs here...
L.error_string_pv = 'SIOC:SYS0:ML04:CA002';
%
n = n + 1;
L.pv{n,1} = 'GUN:GUNB:100:AOPEN'; % is RF on? AOPEN > 0 = ON
L.GunRF_ON_n = n;
L.desc{n} = 'Is Gun RF on?';

%RTDs
% PVs starting wuth GUN:GUNB:100:, grouped in max/min groups
GunBodyCuTemps = [...
%    'ANOUTTEMP        '; %remove from Cu max-min group
'ANCENTEMP        ';
'NOSETEMP         ';
'CATHENDCAPOUTTEMP';
'CATHENDCAPCENTEMP' ];
GunBodySSTemps = [...
    'VACWALLNTEMP';
    'ANFLANGETEMP';
    'VACWALLSTEMP' ];
GunCPLRTemps = [...
    'A4CPLRRFWNDWTEMP'; % list window temps first
    'A3CPLRRFWNDWTEMP';
    'WGA4ELBOWTEMP   ';
    'WGA4MIDTEMP     ';
    'WGA4VRUNTEMP    ';
    'WGA4CPLRENDTEMP ';
    'WGA3ELBOWTEMP   ';
    'WGA3MIDTEMP     ';
    'WGA3VRUNTEMP    ';
    'WGA3CPLRENDTEMP '];
bodyCu_num_rtds = size(GunBodyCuTemps,1);
bodySS_num_rtds = size(GunBodySSTemps,1);
cplr_num_rtds = size(GunCPLRTemps,1);
for m = 1:bodyCu_num_rtds
    n = n + 1;
    fatPV = ['GUN:GUNB:100:' GunBodyCuTemps(m,:)];
    L.pv{n,1} = deblank(fatPV);
    L.GunBodyCuTemps_n(m) = n;
end
for m = 1:bodySS_num_rtds
    n = n + 1;
    fatPV = ['GUN:GUNB:100:' GunBodySSTemps(m,:)];
    L.pv{n,1} = deblank(fatPV);
    L.GunBodySSTemps_n(m) = n;
end
for m = 1:cplr_num_rtds
    n = n + 1;
    fatPV = ['GUN:GUNB:100:' GunCPLRTemps(m,:)];
    L.pv{n,1} = deblank(fatPV);
    L.GunCPLRTemps_n(m) = n;
end
n = n + 1;
L.pv{n,1} = ('GUN:GUNB:100:ANOUTTEMP'); % removed from Cu group
L.GunANOUTtemp_n = n;
n = n + 1;
L.pv{n,1} = ('GUN:GUNB:100:BUCKCOILTEMP');
L.BuckCoilTemp_n = n;
n = n + 1;
L.pv{n,1} = ('SOLN:GUNB:212:BDYTEMP');
L.SolenoidTemp_n = n;
n = n + 1;
L.pv{n,1} = ('ACCL:GUNB:455:CPLR2TEMP'); % rtd taken from LEB
L.GateValveTemp_n = n;
n = n + 1;
L.pv{n,1} = ('ROOM:GUNB:100:AIRTEMP2');
L.SprinklerTemp_n = n;
n = n + 1;
L.pv{n,1} = ('VGHF:GUNB:100:P');      % IonGauge 100 pressure
L.GunVac_n = n;
n = n + 1;
L.pv{n,1} = ('VGHF:GUNB:100:STATUS'); % Filament On/Off status
L.GunVacFilament_n = n;
n = n + 1;
L.pv{n,1} = ('VGXIG:GUNB:100:P');      % Extractor Gauge 100 pressure
L.GunVacXIG_n = n;
n = n + 1;
L.pv{n,1} = ('VGXIG:GUNB:100:STATUSMON'); % Extractor Gauge status, 0 = OK
L.GunVacXIGstat_n = n;
%
%The BakeOut controllers:
%
% The LEB baking spider box...
n = n + 1;
L.pv{n,1} = ('GUN:GUNB:100:LEB_BAKE_ESTOP_STATUS'); % rdbk: 1=Bake ON, 0=off
L.LEBestopStatus_n = n;
n = n + 1;
L.pv{n,1} = ('GUN:GUNB:100:LEB_BAKE_ESTOP');        % ctrl: 1=STOP, 0=ON
L.LEBestopControl_n = n;
%
%the small Variacs...
% 1 =  WG/Drift
% 2 = Soln1/Gate Valve
% 3 = PF Cart
% 4 = Solenoid
% 5 = RGA (added 10/26/18)
VARIACS = [...
    'NW01:1';
    'NW02:1';
    'NW03:1';
    'NW03:4';
    'NW03:6'];
nv = size(VARIACS);
extstr{1} = {'POWEROFF'};   % send 1 for OFF
extstr{2} = {'POWERON'};    % send 1 for ON
extstr{3} = {'POWERSTATE'}; % ON = 0; OFF = 1 or 2
for m = 1:nv(1)
    for k = 1:3
        n = n + 1;
        L.pv{n,1} = ['ACSW:GUNB:' VARIACS(m,:) char(extstr{k})];
        eval(['L.Variac(m).', char(extstr{k}), '_n = n;']);
    end
end
%
% The Matlab Setpoint PVs from the edm:
%
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO001');
L.AnyRTDHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO002');
L.RFWindowsHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO003');
L.GunVacHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO004');
L.SprinklerHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO005');
L.CuSSdeltaTHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO006');
L.SolnBuckHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO007');
L.GateValveHigh_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO008');
L.Future1High_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO009');
L.Future2High_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO010');
L.UseXIG_n = n;
n = n + 1;
L.pv{n,1} = ('SIOC:SYS0:ML04:AO015');
L.GunVacFilBypass_n = n;
end
%%
% This is where the bake trip decision is made
function [trip out] = trip_logic(ctrl, stats)

trip = 0;
out.message = 'All OK ';
%
% if any Variacs are on, there is a bake happening...
if (~all(stats.varstats) || stats.lebEstopstat) % at least one variac is not off (0 = on)
    out.bake_on = 1;                                 % or LEB bake is on (1 = on)
else
    out.bake_on = 0;
end

out.LEBestopstat = stats.lebEstopstat;
out.maxCuTemp = max(abs(stats.CuTemps));
out.maxSSTemp = max(abs(stats.SSTemps));
out.maxCPLRTemp = max(abs(stats.CPLRTemps));
out.maxRFwintemp = max(stats.CPLRTemps(1:2));
out.minCuTemp = min(abs(stats.CuTemps));
out.minSSTemp = min(abs(stats.SSTemps));
out.maxRTDtemp = max([out.maxCuTemp out.maxSSTemp out.maxCPLRTemp ...
     stats.gunanouttemp stats.gvalvetemp stats.bucktemp stats.solntemp]);
%
if ~out.bake_on
    trip = 0;  %  no bake, no need to trip bake
    out.message = 'Bakeout is not on, no need to trip it off';
    return;
end
if ctrl.useVGXIG % 1 = use the Extractor gauge
    gunVacuum = stats.gunvacxig;
    if stats.gunvacxighv > 0
        vacGaugeOK = 0;
    else
        vacGaugeOK = 1;
    end
else
    gunVacuum = stats.gunvac;
    % 11/26 Set filament to 1 (On) even if OFF
    %vacGaugeOK = stats.gunvacfil;
    vacGaugeOK = 1;
    
end

if ~(gunVacuum < ctrl.maxgunvac)
    trip = 1;  % Too Much Pressure, this pressure got to stop
    out.message = 'Vacuum pressure too high!';
    return;
end
if ~stats.bypassgunvacfil
    if ~(vacGaugeOK)
        trip = 1;  % Vacuum filament is not on, and not bypassed
        out.message = 'Vacuum filament is not on!';
        return;
    end
end
if ~(stats.sprinktemp < ctrl.maxsprinktemp)
    trip = 1;  % Room is on fire.
    out.message = 'Sprinkler temperature too high!';
    return;
end
if ~(out.maxRTDtemp < ctrl.maxmaxtemp)
    trip = 1;  % somebody's too hot
    out.message = 'At least one RTD is above max allowed temp';
    return;
end
if ~(max([stats.bucktemp stats.solntemp]) < ctrl.maxsolntemp)
    trip = 1;  % Solenoid or Bucking Coil too hot
    out.message = 'Solenoid/Bucking Coil too hot!';
    return;
end
if ~(out.maxRFwintemp < ctrl.maxRFwintemp)
    trip = 1;  % an RF Window is too hot
    out.message = 'RF Window temperature exceeded!';
    return;
end
if stats.gvalvetemp > ctrl.maxgvalvetemp
    trip = 1;  % Gate Valve temperature too high
    out.message = 'Gate valve temperature too high!';
    return;
end

if ~(((out.maxCuTemp - out.minSSTemp) < ctrl.maxCuSSdeltaT) && ((out.maxSSTemp - out.minCuTemp) < ctrl.maxCuSSdeltaT))
    trip = 1;  % Copper-SS temp difference too high
    out.message = 'Copper-to-SS temp difference too high!';
    return;
end


%
end

%%
% 1 turns on bake
% 0 turn off bake
function bake_control(x, L)
global DISABLE_TRIP

tripped = lcaGetSmart(L.pv{L.trip_status_n,1});

%For the Variacs:
for nv = 1:5
    powerOnPVs(nv) =  L.pv(L.Variac(nv).POWERON_n);
    powerOffPVs(nv) = L.pv(L.Variac(nv).POWEROFF_n);
    dummyOnPVs(nv) = L.pv(L.dummy(nv).ON_n);
    dummyOffPVs(nv) = L.pv(L.dummy(nv).OFF_n);
end
TheCommand = [1; 1; 1; 1; 1];
TheReset = [0; 0; 0; 0; 0];
%For the SpiderBox
powerOffLEB = L.pv(L.LEBestopControl_n); % 1 = Stop, 0 = On

%persistent bakePowerOnOffstats; %holds On/Off status for bakeout power
%if isempty(bakePowerOnOffstats)
%    bakePowerOnOffstats = [1; 1; 1]; %default = all ON
%end

if x == 1  % Turn on bake
    if ~DISABLE_TRIP
        lcaPutSmart(powerOnPVs, TheCommand); % write '1's to the ON PVs
        lcaPutSmart(powerOffLEB, 0);  % Just a 0,1 toggle
    end
    lcaPutSmart(dummyOnPVs, TheCommand); %dummy for testing
    lcaPutSmart(dummyOffPVs, TheReset);
    lcaPutSmart(L.pv{L.trip_status_n,1}, 0); % clear trip reporting stat
elseif x == 0 % Turn off bake
    if ~DISABLE_TRIP
%        if ~tripped
%            %if there are states to save, save them here
%        end
        lcaPutSmart(powerOffPVs, TheCommand);   %turn off variacs
        lcaPutSmart(powerOffLEB, 1);            % turn off LEB_BAKE
    end
    lcaPutSmart(dummyOffPVs, TheCommand);
    lcaPutSmart(dummyOnPVs, TheReset);
    %dummy for testing
    lcaPutSmart(L.pv{L.trip_status_n,1}, 1); % set trip reporting stat
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
pvname = ['SIOC:SYS0:ML04:AO', numstr];
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
