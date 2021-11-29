function result = epicsSimul_status(result)
%EPICSSIMUL_STATUS
%  RESULT = EPICSSIMUL_STATUS(RESULT) sets status of EPICS PV simulation
%  mode.

% Features: .

% Input arguments:
%    RESULT: Desired simulation status (optional, returns present status
%            otherwise)

% Output arguments:
%    RESULT: Simulation status

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

global epicsSimul

if nargin > 0
    epicsSimul=result;
end

if isempty(epicsSimul)
    epicsSimul=ispc;
    if ismember(getenv('HOSTNAME'),{'mcclogin' 'lcls-prod02'})
        epicsSimul=1;
    end
    result=epicsSimul;
end

if nargin < 1
    result=epicsSimul;
end
