function [data, comment, ts, title] = FromSCORE(arg)
% Fetch EPICS variables from SCORE
%
% arg may be empty or contain any of the following fields
%    region (optional) - such as 'BSA-All', will prompt if empty
%    fetchGold (optional) - if supplied fetch the Gold Orbit for the region
%    accelerator (optional) - 'LCLS' , 'LCLS2', etc...
%    Snap_id (optional) - "Number" from SCPRE GUI, such as 284569, not
%       valid if fetchGold supplied
%
% data is a cell array that contains the following fields from the SCORE
%    saveset: region, aliasName, area, readbackName, readbackVal,
%    setpointName, and setpointVal.  Example (Pleasee see DumpDataFromSCORE.m):
%       data{i}.region = LTU
%       data{i}.aliasName = QUE1
%       data{i}.area = DUMP
%       data{i}.readbackName =  QUAD:DMP1:200:BACT
%       data{i}.readbackVal = 0.259380
%       data{i}.setpointName = QUAD:DMP1:200:BDES
%       data{i}.setpointVal = 0.260000
%
% comment is a string that contains the text entered by the user when the
%    SCORE saveset was saved.  Example:
%       comment = Save the World test after adding Undulator region
%
% ts is the time stamp the data was saved.  Display with disp(char(ts));
%    Example: 2008-11-18 16:29:59.0
%
% title is a string that contains the title of the score config.  Example:
%

data = cell(0); % empty
comment = '(Unknown)';
title = '(Unknown)';
ts = 0;
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
Logger = getLogger('FromSCORE.m');

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
    put2log(sprintf('Sorry, %s unable to find SCORE Java classes in FromSCORE.m, please contact Mike Zelazny x3673',caller));
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
% Did the user request the gold orbit?
%
if isfield(arg,'fetchGold')
    try
        readGoldData(ScoreAPI);
        ScoreArrayList = getData(ScoreAPI);
        comment = char(getComment(ScoreAPI));
        ts = getTimestamp(ScoreAPI);
        title = char(getConfigTitle(ScoreAPI));
        put2log(sprintf('%s successfully fetched Gold SCORE region %s', caller, arg.region));
    catch
        put2log(sprintf('Sorry, %s unable to fetch Gold SCORE region %s', caller, arg.region));
        Error = lasterr;
        if isfield(Error,'message')
            Error.message
        end
        return;
    end
elseif isfield(arg, 'Snap_id')
    try
        import java.sql.Timestamp
        ts1 = java.sql.Timestamp(0);
        ts2 = java.sql.Timestamp(java.lang.System.currentTimeMillis());
        found = 0;
        snapshotList = readSnapshots(ScoreAPI, ts1, ts2);
        lastSnapshotIndex = size(snapshotList,1);
        for eachSnapshot = 1:lastSnapshotIndex
            snapshot = snapshotList(eachSnapshot);
            if isequal(arg.Snap_id, str2int(char(getSnap_id(snapshot))))
                found = 1;
                readData(ScoreAPI,getTimestamp(snapshot));
                ScoreArrayList = getData(ScoreAPI);
                comment = char(getComment(ScoreAPI));
                ts = getTimestamp(ScoreAPI);
                title = char(getConfigTitle(ScoreAPI));
                put2log(sprintf('%s successfully fetched SCORE snapshot %d from region %s', caller, arg.Snap_id, arg.region));
                break;
            end
        end
        if isequal(0,found)
            put2log(sprintf('Sorry, %s unable to read SCORE snapshot %d for region %s', caller, arg.Snap_id, arg.region));
        end
    catch
        put2log(sprintf('Sorry, %s unable to fetch SCORE snapshot %d from region %s', caller, arg.Snap_id, arg.region));
        Error = lasterr;
        if isfield(Error,'message')
            Error.message
        end
        return;
    end
else
    % prompt for SCORE save set
    try
        readDataFromChooser(ScoreAPI);
        ScoreArrayList = getData(ScoreAPI);
        comment = char(getComment(ScoreAPI));
        ts = getTimestamp(ScoreAPI);
        title = char(getConfigTitle(ScoreAPI));
        put2log(sprintf('%s successfully fetched SCORE snapshot for region %s', caller, arg.region));
    catch
        put2log(sprintf('Sorry, %s unable to fetch SCORE snapshot for region %s', caller, arg.region));
        Error = lasterr;
        if isfield(Error,'message')
            Error.message
        end
        return;
    end
end % fetchGold

%
% Convert the SCORE ScoreAPIRecord into something Matlaby
%
if strcmp(who('ScoreArrayList'),'ScoreArrayList')
    for i=1:size(ScoreArrayList)
        try
            ScoreAPIRecord = get(ScoreArrayList,i-1);
            data{i}.region       = char(getRegion(ScoreAPIRecord));
            data{i}.area         = char(getArea(ScoreAPIRecord));
            data{i}.readbackName = char(getReadbackName(ScoreAPIRecord));
            data{i}.readbackVal  = getReadbackVal(ScoreAPIRecord);
            data{i}.setpointName = char(getSetpointName(ScoreAPIRecord));
            data{i}.setpointVal  = getSetpointVal(ScoreAPIRecord);
            data{i}.setpointValStr  = char(getSetpointValStr(ScoreAPIRecord));
            data{i}.waveformType = char(getWaveformType(ScoreAPIRecord));
            data{i}.aliasName    = char(getAliasName(ScoreAPIRecord));
        catch
            if isfield(data{i}.aliasName)
                disp(sprintf('Sorry, %s unable to decode %s', caller, arg.region));
            end
            Error = lasterr;
            if isfield(Error,'message')
                Error.message
            end
        end
    end
end

%
% Disconnect from database
%
try
    if hasConnected(ScoreAPI)
	disconnect(ScoreAPI)
    end
catch
    put2log(sprintf('Error, unable to disconnect from database'));
    Error = lasterr
    if isfield(Error,'message')
	Error.message
    end
end
