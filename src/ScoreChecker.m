function ScoreChecker()
% Test loading snapshots from SCORE

%
% Connect to message log
%
Logger = getLogger('ScoreChecker.m');

% To use Oracle Wallet
setenv('TNS_ADMIN','/usr/local/lcls/tools/oracle/wallets/epics_mon_user');

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
%setupjavapath([getenv('PHYSICS_TOP') '/ScoreAPI/jar/ScoreAPI.jar']);
if ~isequal(8,exist('edu.stanford.slac.score.api.ScoreAPI','class'))
    put2log(sprintf('Sorry, %s unable to find SCORE Java classes in ScoreChecker.m, please contact Mike Zelazny x3673',caller));
    return;
end

%
% Connect to SCORE
%
try
    ScoreAPI = edu.stanford.slac.score.api.ScoreAPI();
    put2log(sprintf('successfully connected to SCORE'));
catch
    put2log(sprintf('Sorry, unable to connect to SCORE'));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end

try
    lcaPut('SIOC:SYS0:ML00:AO824.DESC',getenv('HOSTNAME'));
catch
    lcaPut('SIOC:SYS0:ML00:AO824.DESC','Unknown Host');
end

import java.sql.Timestamp
ts1 = java.sql.Timestamp(0);
ts2 = java.sql.Timestamp(java.lang.System.currentTimeMillis());

pvIndex = 825;
dTime = cell(0);
ts = cell(0);
rand('state',sum(100*clock))
regions = getScoreRegions(ScoreAPI); % Get a list of SCORE regions
for i = 1 : size(regions)
    region = char(regions(i));
    try
        tic;
        initialize(ScoreAPI, caller, region);
        snapshotList = readSnapshots(ScoreAPI, ts1, ts2);
        lastSnapshotIndex = size(snapshotList,1);
        snapshotIndex = ceil(lastSnapshotIndex.*rand);
        snapshot = snapshotList(snapshotIndex);
        ts{end+1} = char(getTimestamp(snapshot));
        readData(ScoreAPI,getTimestamp(snapshot))
        dt = toc
        dTime{end+1} = sprintf('%f seconds',dt);
        lcaPut(sprintf('SIOC:SYS0:ML00:AO%d',pvIndex+i-1),dt);
        lcaPut(sprintf('SIOC:SYS0:ML00:AO%d.DESC',pvIndex+i-1),region);
        lcaPut(sprintf('SIOC:SYS0:ML00:SO0%d',pvIndex+i-1),ts{end});
    catch
        ts{end+1} = 'n/a';
        dTime{end+1} = 'ERROR';
    end
end

% nice report
disp(' ');
disp(' ');
disp(' ');
unix('hostname');
disp(datestr(now));
for i = 1 : size(regions)
    disp(sprintf('%s %s - %s', dTime{i}, char(regions(i)), ts{i}));
end
disp(' ');
disp(' ');

if usejava('desktop')
    % don't exit from Matlab
else
    exit
end
