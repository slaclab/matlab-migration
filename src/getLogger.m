function [ Logger ] = getLogger(facility)
% returns handle to message logger - Zelazny

% Usage:
%   Logger = getLogger();
%   Logger = getLogger('My application'); % sets cmLog facility to "My application"
%   Logger.log('My message'); % goes to cmlog
%   Logger.logl('My Message'); % goes to cmLog and terminal

try
    if nargin > 0
        Logger = edu.stanford.slac.err.Err.getInstance(facility);
    else
        Logger = edu.stanford.slac.err.Err.getInstance();
    end
catch
    stack = dbstack();
    try
        Logger = edu.stanford.slac.err.Err.getInstance(stack(length(stack)).name);
    catch
        Logger = 0; % Err probably not installed
    end
end
