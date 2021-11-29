% process EPICS channels
% Mike Zelazny (zelazny@stanford.edu)

function [value, tsLca, connected, flag] = lcaUtil_NewMonitorValue (pv, force, inValue, inTS)

% Input arguments:
%   pv - cell array column vector of EPICS pv names. Example(s):
%       (1) pv = {'DOES:NOT:EXIST'};
%       (2) pv = {'DOES:NOT:EXIST';'ALSO:DOES:NOT:EXIST'};
%       (3) pv = 'DOES:NOT:EXIST'; pv{end+1}='ALSO:DOES:NOT:EXIST';
%   force *optional* cell array column vector - perform lcaGet when pv is
%       connected, but channel access says there is no new value. Defaults
%       to 0. Must have the same number of elements of the pv cell array.
%       Example:
%       (1) force = {0;0};
%       (2) force = {0;1}; % force first pv in cell array, but not second
%           pv in cell array.
%   inValue *optional* - cell array column vector of value(s) to be
%       returned when no new value present.  Must have the same number of
%       elements of the pv cell array.  Defaults to empty cell.
%   inTS *optional*cell array column vector - Lca time stamp(s) of
%       inValue(s).  Cell Array.  Must have the same number of elements of
%       the pv cell array.  Defaults to empty cell.
% Output arguments:
%   value cell array column vector - value(s) returned from lcaGet or
%       inValue.
%   tsLca *optional* cell array column vector - lca time stamp. One for
%       each value.
%   connected *optional* - 0=not connected, 1=connected. One cell element
%       for each value.
%   flag *optional* - flag(s) returned from lcaNewMonitorValue.  One for
%       each pv.

npv = size(pv,1); % 1 for first dimension

if nargin < 2, force = cell(npv, 1); end
if nargin < 3, inValue = cell(npv,1); end
if nargin < 4, inTS = cell(npv,1); end

value = inValue;
tsLca = inTS;

for eachpv = 1:npv

    try
        labCA_Error_Code = lcaNewMonitorValue (pv{eachpv});
    catch
        labCA_Error_Code = lcaLastError ();
    end

    connected{eachpv} = 0;
    flag(eachpv) = labCA_Error_Code;

    if (isequal(labCA_Error_Code, 20)) % never connected, but available
        lcaSetMonitor(pv{eachpv});
    elseif (isequal(labCA_Error_Code,0)) % connected, no new value
        connected{eachpv} = 1;
        if (isequal(force{eachpv},1))
            [value{eachpv}, tsLca{eachpv}] = lcaGet(pv{eachpv});
        end
    elseif (isequal(labCA_Error_Code,1)) % connected, new value
        connected{eachpv} = 1;
        [value{eachpv}, tsLca{eachpv}] = lcaGet(pv{eachpv});
    elseif (isequal(labCA_Error_Code,21)) % invalid or unavailable
        stack = dbstack; % call stack
        if length(stack) > 1
            caller = stack(2).file;
        else
            caller = getenv('PHYSICS_USER');
        end
        Logger = getLogger('lcaUtil_NewMonitorValue.m');
        put2log(sprintf('%s requested unknown or unavailable pv=%s', caller, ...
            char(pv{eachpv})));
    end

end
