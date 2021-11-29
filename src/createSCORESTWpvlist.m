function createSCORESTWpvlist()
% Dumps SCORE Save-the-world PV names to /tmp/SCORE.pvlist

%
% Connect to message log
%
me = 'createSCORESTWpvlist.m';
fname = '/tmp/SCORESTW.pvlist';
import java.sql.Timestamp
ts1 = java.sql.Timestamp(0);
ts2 = java.sql.Timestamp(java.lang.System.currentTimeMillis());
pvcnt = 0;
Logger = getLogger(me);

%
% Make sure SCORE Java classes can be found
%
if ~isequal(8,exist('edu.stanford.slac.score.api.ScoreAPI','class'))
    put2log(sprintf('Sorry, Unable to find SCORE Java classes in %s, please contact Mike Zelazny x3673',me));
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

%
% Get a list of SCORE regions
%
try
    regions = getScoreRegions(ScoreAPI);
    regions = cell(regions);
    put2log(sprintf('Successfully got a list of SCORE regions'));
catch
    put2log(sprintf('Sorry, unable to get a list of SCORE regions'));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end

%
% Open the ascii text file
%
try
    fid = fopen(fname,'w');
    put2log(sprintf('Successfully opened %s',fname));
catch
    put2log(sprintf('Sorry, unable to open %s', fname));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end

%
% Loop through all of the regions
%
for i=1:size(regions,1)
    %
    % connect to scpre region
    %
    try
        initialize(ScoreAPI, me, regions{i});
        put2log(sprintf('%s successfully connected to SCORE region %s', me, regions{i}));
        ok = 1;
    catch
        put2log(sprintf('Sorry, %s unable to connect to SCORE region %s', me, regions{i}));
        Error = lasterr;
        if isfield(Error,'message')
            Error.message
        end
        ok = 0;
    end
    %
    % Get a list of snapshots
    %
    if (ok)
        try
            snapshotList = readSnapshots(ScoreAPI, ts1, ts2);
            snapshotIndex = size(snapshotList,1);
            snapshot = snapshotList(snapshotIndex);
        catch
            ok = 0;
        end
    end
    %
    % read the snapshot
    %
    if (ok)
        try
            readData(ScoreAPI,getTimestamp(snapshot));
        catch
            ok = 0;
        end
    end
    %
    % Actually get the data
    %
    if (ok)
        try
            ScoreArrayList = getData(ScoreAPI);
            comment = char(getComment(ScoreAPI));
            ts = getTimestamp(ScoreAPI);
        catch
            ok = 0;
        end
    end
    %
    % Write pvnames to file
    %
    if (ok)
        regionpvcnt = 0;
        for j=1:size(ScoreArrayList)
            try
                ScoreAPIRecord = get(ScoreArrayList,j-1);
                region       = char(getRegion(ScoreAPIRecord));
                area         = char(getArea(ScoreAPIRecord));
                readbackName = char(getReadbackName(ScoreAPIRecord));
                readbackVal  = getReadbackVal(ScoreAPIRecord);
                setpointName = char(getSetpointName(ScoreAPIRecord));
                setpointVal  = getSetpointVal(ScoreAPIRecord);
                aliasName    = char(getAliasName(ScoreAPIRecord));

                if ~isempty(strfind(region,'Old'))
                    break;
                end
                if ~isempty(strfind(region,'Design-LEM'))
                    break;
                end
                if ~isempty(strfind(region,'Undulator Motion'))
                    break;
                end
                if (size(setpointName,2) > 4)
                    fprintf(fid,sprintf('%s\n',setpointName));
                    pvcnt = pvcnt + 1;
                    regionpvcnt = regionpvcnt + 1;
                end

                if (size(readbackName,2) > 4)
                    fprintf(fid,sprintf('%s\n',readbackName));
                    pvcnt = pvcnt + 1;
                    regionpvcnt = regionpvcnt + 1;
                end
            catch
                ok = 0;
            end
        end
    end
    put2log(sprintf('%s Added %d PVs from SCORE region %s', me, regionpvcnt, region));
end

status = fclose(fid);
put2log(sprintf('Done, creating %s. Found %d PVs', fname, pvcnt));

if ~usejava('desktop')
    exit
end
