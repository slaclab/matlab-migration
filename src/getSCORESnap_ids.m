function [Snap_ids] = getSCORESnap_ids(arg)
% Fetch snapshot numbers from SCORE region
%
% arg may be empty or contain any of the following fields
%    region  - such as 'BSA-All', will prompt if empty
%    accelerator (optional) - 'LCLS' , 'LCLS2', etc...

Snap_ids = 0;

if nargin < 1
    [ sys , arg.accelerator ] = getSystem();
end
if ~isfield(arg, 'accelerator')
    [ sys , arg.accelerator ] = getSystem();
end

% To use Oracle Wallet
setenv('TNS_ADMIN','/usr/local/lcls/tools/oracle/wallets/epics_mon_user');

%
% Connect to message log
%
Logger = getLogger('getSCORESnap_ids.m');

%
% Determine caller (for later finger pointing)
%
stack = dbstack; % call stack
if length(stack) > 1
    caller = stack(2).file;
else
    caller = getenv('PHYSICS_USER');
end

%
% Make sure SCORE Java classes can be found
%
if ~isequal(8,exist('edu.stanford.slac.score.api.ScoreAPI','class'))
    put2log(sprintf('Sorry, %s unable to find SCORE Java classes in getSCORESnap_ids.m, please contact Mike Zelazny x3673',caller));
    return;
end
%
% Connect to SCORE
%
try
    ScoreAPI = edu.stanford.slac.score.api.ScoreAPI(arg.accelerator);
    put2log(sprintf('successfully connected to SCORE'));
catch
    put2log(sprintf('Sorry, unable to connect to SCORE'));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end

if ~isfield(arg, 'region')
    % Get the score regions by calling the API ..
    regions = getScoreRegions(ScoreAPI);
    regions = cell(regions);
    [Selection,ok] = listdlg('ListString',regions,...
        'SelectionMode','single',...
        'Name',[caller ' SCORE Region Selection'],...
        'PromptString','Please select SCORE region:',...
        'ListSize',[300 200]);
    if ok
        arg.region = regions{Selection};
    else
        return;
    end
end

try
    % now connect to the region selected by the user
    initialize(ScoreAPI, caller, arg.region);
    put2log(sprintf('%s successfully connected to SCORE region %s', caller, arg.region));
catch
    put2log(sprintf('Sorry, %s unable to connect to SCORE region %s', caller, arg.region));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end

%
% Get Snap_id numbers
%
try
    import java.sql.Timestamp
    ts1 = java.sql.Timestamp(0);
    ts2 = java.sql.Timestamp(java.lang.System.currentTimeMillis());
    snapshotList = readSnapshots(ScoreAPI, ts1, ts2);
    lastSnapshotIndex = size(snapshotList,1);
    for eachSnapshot = 1:lastSnapshotIndex
        snapshot = snapshotList(eachSnapshot);
        Snap_ids(eachSnapshot) = str2int(char(getSnap_id(snapshot)));
    end
catch
    put2log(sprintf('Sorry, %s unable to fetch SCORE snapshot %d from region %s', caller, arg.Snap_id, arg.region));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end