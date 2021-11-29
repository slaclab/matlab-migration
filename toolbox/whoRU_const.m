% Global Constants for whoRUMini GUI.
%
% whoRUMini is a GUI for collecting and viewing Klsytron and FEL
% related BSA data  
%
% -----------------------------------------------------------------
% Auth: Greg White, 7-Sel-2017
% Mod:
% =================================================================

%% Streams. 
% The following standard file Ids understood by matlab.
global STDOUT STDERR;
STDOUT=1;
STDERR=2;

%
global WRU_EXID_PREFIX
WRU_EXID_PREFIX='WRU:';


% String constants

global KLYSBEAMVOLTNAMES;
KLYSBEAMVOLTNAMES = { 'TCAV0 Beam Volts' 'Gun Beam Volts' 'L0-A Beam Volts' ...
                     'L0-B Beam Volts' 'L1-S Beam Volts' 'L1-X Beam Volts' };

% Messages
global NOACQMSG NOGOODBSADATAMSG ...
LOGFILEERR_MSG CANTOPENCONTROLSSCREEN_MSG UNDEFLOGENV;
NOACQMSG=...
    ['No data yet acquired. Please make a successful Get Data first, ' ...
     'then retry this operation.'];
NOGOODBSADATAMSG=...
    'No good BSA data acquired from station (all NaNs) for %s';
LOGFILEERR_MSG = ...
    'Problem encountered with log file operation.';
CANTOPENCONTROLSSCREEN_MSG = ...
    'Cannot open Controls screen %s %s.';
UNDEFLOGENV=...
   'Environment variable MATLAB_LOG_FILE_NAME is undefined or empty.';

%% Online help URL
global WRUHELP_URL;
WRUHELP_URL=...
    'http://ad-ops.slac.stanford.edu/wiki/index.php/Who_RU';

%% External commands
% Opens a control system panel.
% -server : use an existing edm server on a host if one exists.
% -x      : open screen in "execute" mode (with data) rather than edit.
% Replace %s with edl file name.
global SCREENCOMMAND;
SCREENCOMMAND='exec edm -server -x %s &';

% Define shell command to open a log file for viewing. 
% use an xterm 220 chars wide, 40 rows, windowing last 10000 lines of
% the log file, using tail starting at line 1, and kill the process
% when the parent process pid dies.
global VIEWLOGCMD;
VIEWLOGCMD=...
   ['xterm -geometry 220x40 -sl 10000 -title "%s" -sb -e '...
   'tail -n +1 -f %s --pid=%d &'];
