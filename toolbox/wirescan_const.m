% WIRESCAN_CONST defines constants for the Wirescan GUI.
%
% -----------------------------------------------------------------------
% Auth: Greg White, 19-Apr-2016
% Modified: 
% =======================================================================

%% Streams. 
% The following standard file Ids understood by matlab.
global STDOUT STDERR;
STDOUT=1;
STDERR=2;

% Alarm Severities, as EPICS alarm.h
NO_ALARM=0;
MINOR_ALARM=1;
MAJOR_ALARM=2;
INVALID_ALARM=3;

%% Error messages

% All wirescanner exception identifiers (eg WS:ERRORDURINGABORT) MUST start
% with 'WS:'. The Wirescanner GUI error handling tests that to decide
% whether to issue a stacktrace to the console when receiving a exception.
% All except those beginning WS: are stacktraced. As such, it's assumed WS:
% messages are "functional" - ie, to do with normal wire scan GUI error
% handling, rather than programming exception.
global WS_EXID_PREFIX;
WS_EXID_PREFIX = 'WS:';

% The exception messages of the wire scanner GUI. These MUST be issued
% with an id of the same name, but 'WS_' replaced by 'WS:', eg
% error(' WS:ERRORDURINGABORT',WS_ERRORDURINGABORT_MSG).
%
global WS_ERRORDURINGABORT_MSG WS_MOTORNOTENABLED_MSG ...
    WS_MOTORINITFAILER_MSG WS_SECTORINITERROR_MSG ...
    WS_POLLNEVERSUCCEEDED_MSG WS_POLLABORTING_MSG ...
    WS_INVALIDWIRESPEED_MSG WS_LOGFILEERR_MSG ...
    WS_CANTOPENCONTROLSSCREEN_MSG ...
    WS_RATEISZERO;

WS_ERRORDURINGABORT_MSG =...
    'Wire scan abort itself enountered error!';
WS_MOTORNOTENABLED_MSG = ...
    'Motor was found to be off or otherwise not enabled : %s. ';
WS_MOTORINITFAILER_MSG = ...
    'Motor (re)initialize attempt failed; no write to %s. ';
WS_SECTORINITERROR_MSG = ...
    'Sector initialization failed. ';
WS_POLLNEVERSUCCEEDED_MSG = ...
    'PV %s never returned success condition %d in %d tries. ';
WS_POLLABORTING_MSG = ...
    'Polling %s aborted on iteration %d due to bad CA return from lcaGetSmart. ';
WS_INVALIDWIRESPEED_MSG = ...
    'Wire speed warning. %s. Check beam rate, range and number pulses.';
WS_LOGFILEERR_MSG = ...
    'Problem encountered with log file operation.';
WS_CANTOPENCONTROLSSCREEN_MSG = ...
    'Cannot open Controls screen %s %s.';
WS_CANTLAUNCH_MSG = ...
    'Cannot execute, "%s."';
WS_RATEISZERO = ...
    'Machine repetition rate is zero';

%% EPICS API 
global LCA_SUCCESS;
LCA_SUCCESS = 1;         % EPICS lca operation success return code

% <wiredevice>:MOTR_ENABLED_STS
global WIREMOTORISOFF WIREMOTORISON;
WIREMOTORISOFF=0;        % Motor is now off.
WIREMOTORISON=1;         % Motor is now on.  

%  <wiredevice>:MOTR_INIT
global WIREMOTORINIT;
WIREMOTORINIT=1;         % Request motor to init or re-init.

%% Online help URL
global WIRESCANHELP_URL;
WIRESCANHELP_URL=...
    'http://ad-ops.slac.stanford.edu/wiki/index.php/Wire_Scan_GUI';

%% External commands
% Opens a control system panel.
% -server : use an existing edm server on a host if one exists.
% -x      : open screen in "execute" mode (with data) rather than edit.
% Replace %s with edl file name.
global SCREENCOMMAND;
SCREENCOMMAND='exec edm -server -x %s &';

global STRIPTOOLCMD WIRESCONFIGFILE;
STRIPTOOLCMD='StripTool %s &';
WIRESCONFIGFILE='wires_motrandposn.stp';

% Define shell command to open a log file for viewing. 
% use an xterm 220 chars wide, 40 rows, windowing last 10000 lines of
% the log file, using tail starting at line 1, and kill the process
% when the parent process pid dies.
global VIEWLOGCMD;
VIEWLOGCMD=...
   ['xterm -geometry 220x40 -sl 10000 -title "%s" -sb -e '...
   'tail -n +1 -f %s --pid=%d &'];


