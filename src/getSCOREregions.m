function [regions] = getSCOREregions(arg)
% Fetch regions from SCORE
%
% arg may be empty or contain any of the following fields
%    accelerator (optional) - 'LCLS' , 'LCLS2', etc...

regions = '';

if nargin < 1
    [ sys , arg.accelerator ] = getSystem();
end 
if ~isfield(arg, 'accelerator')
    [ sys , arg.accelerator ] = getSystem();
end

%
% To use Oracle Wallet
%
setenv('TNS_ADMIN','/usr/local/lcls/tools/oracle/wallets/epics_mon_user');

%
% Connect to message log
%
Logger = getLogger('getSCOREregions.m');

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
    put2log(sprintf('Sorry, %s unable to find SCORE Java classes in getSCOREregions.m, please contact Mike Zelazny x3673',caller));
    return;
end
%
% Get the score regions by calling the API ..
%
try
    ScoreAPI = edu.stanford.slac.score.api.ScoreAPI(arg.accelerator);
    regions = getScoreRegions(ScoreAPI);
    regions = cell(regions);
catch
    put2log(sprintf('Sorry, unable to connect to SCORE'));
    Error = lasterr;
    if isfield(Error,'message')
        Error.message
    end
    return;
end
