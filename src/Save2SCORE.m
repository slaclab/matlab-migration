function [region, comment, ts] = Save2SCORE(arg)
% Save EPICS variables to SCORE
%
% This function assumes that you have a particular dataset that you want
% to save and possibly re-load later with FromSCORE.m.  This function does
% NOT read live machine data.  If you want to read live machine data, then
% use the SCORE GUI application off of lclshome.
%
% (Input) arg may be contain any of the following fields:
%
%    region (String, optional) - SCORE region, such as 'BSA-All' - will prompt if
%       not supplied.
%
%    data a cell array that contains the following fields, one for each signal:
%       region (String, optional) - SCORE region, such as 'LTU'.  If not supplied,
%          defaults to arg.region.
%       aliasName (String, optional) - Usually MAD name, such as 'QUE1'.
%          Blank if not supplied.
%       area (String, optional) - SCORE area for this signal, such as 'DUMP'.
%          Defaults to data{i}.region.
%       readbackName (String) - EPICS pv name that contains the "readback"
%          signal, such as 'QUAD:DMP1:200:BACT'
%       readbackVal (double, optional) - Value of EPICS pv name stored in
%          readbackName. Defaults to NaN.
%       setpointName (String, optional) - EPICS pv name that contains the
%          "setpoint" signal, such as 'QUAD:DMP1:200:BDES'.  Defaults to null.
%       setpointVal (double, optional) - Value of EPICS pv name stored in
%          setpointName.  Defaults to NaN.
%
%       Example:
%          data{i}.region = 'LTU'
%          data{i}.aliasName = 'QUE1'
%          data{i}.area = 'DUMP'
%          data{i}.readbackName =  'QUAD:DMP1:200:BACT'
%          data{i}.readbackVal = 0.259380
%          data{i}.setpointName = 'QUAD:DMP1:200:BDES'
%          data{i}.setpointVal = 0.260000
%
%    comment (String, optional) - A useful comment describing the arg.data.
%       If not supplied, the user will be prompted to enter one.  Example:
%          arg.comment = 'Save the World test after adding Undulator region';
%
%    ts (Matlab time, such as now, type "help now" in the Matlab command window,
%        Optional) - the time stamp the data was saved.  If not supplied,
%        it defaults to now.
%
%    accelerator (String, optional) - 'LCLS' or 'LCLS2', etc...
%
% (Output)
% region (String) - user selected SCORE region.
% comment (String) - user entered comment describing arg.data.
% ts (Matlab time) - time stamp associated with your arg.data in SCORE.
%
% -------------------------------------------------------------------------
%
% Connect to message log
%
Logger = getLogger('Save2SCORE.m');
if nargin < 1
    [ sys , arg.accelerator ] = getSystem();
end
if ~isfield(arg, 'accelerator')
    [ sys , arg.accelerator ] = getSystem();
end

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
if ~isequal(8,exist('edu.stanford.slac.score.api.ScoreAPI','class'))
    put2log(sprintf('Sorry, %s unable to find SCORE Java classes in Save2SCORE.m, please contact Mike Zelazny x3673',caller));
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
% Convert the data to what SCORE expects
%
if isfield(arg,'data')
    n = size(arg.data,2);
    for i=1:n
        try
            isscalar = 1;
            if isfield(arg.data{i},'waveformType')
                if ~isempty(arg.data{i}.waveformType)
                    isscalar = 0; % must be a valid waveform
                end
            end
            if isfield(arg.data{i},'readbackName')
                readbackName = java.lang.String(arg.data{i}.readbackName);
            else
                readbackName = java.lang.String('');
            end
            if isfield(arg.data{i},'readbackVal')
                readbackVal = arg.data{i}.readbackVal;
            else
                readbackVal = java.lang.Double.NaN;
            end
            if isfield(arg.data{i},'setpointName')
                setpointName = java.lang.String(arg.data{i}.setpointName);
            else
                setpointName = java.lang.String('');
            end
            if isfield(arg.data{i},'setpointVal')
                if isscalar
                    setpointVal = arg.data{i}.setpointVal;
                else
                    setpointVal = java.lang.String(arg.data{i}.setpointValStr);
                end
            else
                setpointVal = java.lang.Double.NaN;
            end
            if isscalar
                addRBandSP(ScoreAPI, readbackName, readbackVal, setpointName, setpointVal);
            else
                addRBandSPStr(ScoreAPI, readbackName, readbackVal, setpointName, setpointVal, java.lang.String(arg.data{i}.waveformType));
            end
        catch
            put2log(sprintf('Warning, %s unable to encode data for SCORE region %s', caller, arg.region));
            Error = lasterr
            if isfield(Error,'message')
                Error.message
            end
        end
    end
else
    put2log(sprintf('Error, %s no data supplied for SCORE region %s', caller, arg.region));
    return;
end

%
% Did the user supply a comment?
%
if ~isfield(arg, 'comment')
    try
        promptForComment(ScoreAPI);
        arg.comment = char(getComment(ScoreAPI));
    catch
        put2log(sprintf('Warning, %s unable to enter comment for SCORE region %s', caller, arg.region));
        Error = lasterr
        if isfield(Error,'message')
            Error.message
        end
    end
end

%
% Did the user supply a ts?
%
if ~isfield(arg,'ts')
    date = java.util.Date();
    arg.ts = java.sql.Timestamp(getTime(date));
end

%
% Actually save the data to SCORE
%
try
    setupSCOREtitle;
catch
    % Not much I can do 
end

try
    arg.ts = saveData(ScoreAPI, java.lang.String(arg.comment), arg.ts);
catch
    put2log(sprintf('Error, %s unable to save data for SCORE region %s', caller, arg.region));
    Error = lasterr
    if isfield(Error,'message')
        Error.message
    end
end

%
% Set output args
%
if isfield(arg,'region')
    region = arg.region;
else
    region = '(Unknown)';
end

if isfield(arg,'comment')
    comment = arg.comment;
else
    comment = '(Unknown)';
end

if isfield(arg,'ts')
    ts = arg.ts;
else
    ts = 0;
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
