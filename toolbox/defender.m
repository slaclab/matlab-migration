function defender()

% Defender EPS - soft EPS for FACET-II.
% S Gessner, R Arinello, C Clark, N Lipkowitz, et al SLAC

%% constants

% set script rate, 0.1 = 10 Hz
delay = 0.05;  

% debug flag turns off inhibitors
debug = 0;


%% initialize the script

% determine script name
scr = strcat(mfilename, {'.m'});

% log startup
disp_log(strcat({'Starting '}, scr, {', ver. 1.0 12/8/2020'}));

% start watchdog
watchdog_pv = 'SIOC:SYS1:ML01:AO901';
W = watchdog(watchdog_pv, 1, scr);
switch get_watchdog_error(W)
    case 1
        disp_log(strcat({'Another '}, scr, {' is running - exiting'}));
        return;
    case 2
        disp_log(strcat({'Error reading/writing '}, watchdog_pv, {' - exiting'}));
        return;
    otherwise
        disp_log(strcat({'Watchdog started on '}, watchdog_pv));
end


%% define process controls (read and write)

% status message
pvs.msg =           'SIOC:SYS1:ML01:CA001';
lcaPutSmart([pvs.msg, '.DESC'], scr);
lcaPutSmart('SIOC:SYS1:ML01:CA002.DESC', scr);

% global inputs
pvs.ctrl.disable =      script_setupPV('SIOC:SYS1:ML01:AO902', 'Defender Disable', 'bool', 0, scr);
pvs.ctrl.trip =         script_setupPV('SIOC:SYS1:ML01:AO903', 'Trip status', 'bool', 0, scr);
pvs.ctrl.reset =        script_setupPV('SIOC:SYS1:ML01:AO904', 'Reset', 'bool', 0, scr);

% bypass control for each fault condition
pvs.bypass(1) =         script_setupPV('SIOC:SYS1:ML00:AOXXX', 'EXP Bypass', 'bool', 0, scr);

%% PV inputs (not defined)

% motor PVs
pvs.in.motor1 = 'TBD';
pvs.in.motor2 = 'TBD';

% laser PVs
pvs.in.laser1 = 'TBD';
pvs.in.laser2 = 'TBD';

% OTR PVs
pvs.in.otr1 = 'TBD';
pvs.in.otr2 = 'TBD';

%% outputs (not defined)

% trip states
pvs.out.trip(1) = script_setupPV('SIOC:SYS1:ML01:AOXXX', 'Trip condition', 'bool', 0, scr);

%% first iteration stuff

disp_msg(pvs.msg, 'Defender OK');

% start out no trip
tripped = 0;

% clear the trip and reset PVs
lcaPutSmart(pvs.ctrl.trip, 0);
lcaPutSmart(pvs.ctrl.reset, 0);
pause(0.1);

% get a data set
data = get_data(pvs);

% no strikes for bad data
strikes = 0;
max_strikes = 3;

%% main loop

while 1
    
    % pause and increment watchdog
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog error');
        break;  % exit program
    end
    
    % store last iteration's trip state
    was_tripped = data.ctrl.trip;
    
    % store last iteration's data
    old = data;
    
    % get a data set
    data = get_data(pvs);
    
    % decide whether to trip
    [tripped, message] = trip(pvs, data);
   

end

%% helper functions

function data = get_data(pvs)
    % this function wraps up all the input stuff and does some intermediate
    % processing

    % get all PVS in the PV struct
    data = lcaGetStruct(pvs, 0, 'double');

end

function [tripped, message] = trip(pvs,data)

    % trip logic goes here
    % probably something like
    %if ~lasersafe
    %    tripped = 1;
    %    message = 'DANGER WILL ROBINSON';
    %end
        
end

function motorsafe = check_motor(pvs,data)

    % motor logic goes here
    
end

function lasersafe = check_laser(pvs, data)
    
    % laser logic goes here

end
    
function disp_msg(strpv, msg)
    % function to copy log messages to PV
    disp_log(msg);
    lcaPutSmart(strpv, double(int8(msg)));    
end

end