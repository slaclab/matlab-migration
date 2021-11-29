% EMITTANCE_CONST defines constants for the Emittance GUI.
%
% -----------------------------------------------------------------------
% Auth: Greg White, 20-June-2016
% Modified: 
% =======================================================================

%% Streams. 

% The following standard file Ids understood by matlab.
global STDOUT STDERR;
STDOUT=1;
STDERR=2;


%% Error messages

global EM_EXID_PREFIX;           % Emittance generated exceptions prefix
EM_EXID_PREFIX = 'EM:';

global EM_SCANFAILED_MSG ...     % Remote app failed to make scan measurement
    EM_GETDATAERR_MSG ...        % Could not successfull get single data pt 
    EM_UNEXPECTEDDATASTRUCT_MSG ...  % Different structure def returned to structure def expected
    EM_LOGFILEERR_MSG...         % Problem finding or viewing log file
    EM_CANTOPENCONTROLSSCREEN_MSG...  % Unable to display EPICS screen
    EM_NOFITMETHODASSIGNED_MSG;

EM_SCANFAILED_MSG = ...
    'Scan failed.';
EM_GETDATAERR_MSG = ...
    'Unable to get data from remote application.';
EM_UNEXPECTEDDATASTRUCT_MSG = ...
    ['Dissimilar data strcuture between what expected ' ...
     'and what provided from app %s'];
EM_LOGFILEERR_MSG = ...
    'Problem encountered with log file operation.';
EM_CANTOPENCONTROLSSCREEN_MSG = ...
    'Cannot open Controls screen %s %s.';
EM_NOFITMETHODASSIGNED_MSG = ...
    'No fitting method assigned.';

%% Online help URL
global EMITTANCEGUIHELP_URL;
EMITTANCEGUIHELP_URL=...
    'http://ad-ops.slac.stanford.edu/wiki/index.php/Emittance_GUI';

%% External commands
% Opens a control system panel.
% -server : use an existing edm server on a host if one exists.
% -x      : open screen in "execute" mode (with data) rather than edit.
% Replace %s with edl file name.
global SCREENCOMMAND;
SCREENCOMMAND='exec edm -server -x %s &';

% Define shell command to open a log file for viewing. 
% Use an xterm 220 chars wide, 40 rows, windowing last 10000 lines of
% the log file, using tail starting at line 1, and kill the process
% when the parent process pid dies.
global VIEWLOGCMD;
VIEWLOGCMD=...
    ['xterm -geometry 220x40 -sl 10000 -title "%s" -sb -e '...
    'tail -n +1 -f %s --pid=%d &'];
