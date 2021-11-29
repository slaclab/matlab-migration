function [dx]=SXRSS_moveMirrors(pvs, dx,opt)

%SXRSS_MOVEMIRRORS
%   SXRSS_MOVEMIRRORS(PVS, DX) moves mirror positions

% Features:

% Input arguments:
%    PVS: Cell array of string containing mirror pv's
%    DX:  Array containing distance mirror displacement or position
%    DISABLE: 1 - for dev mode, will not move mirrors
%    OPT: 0 - displacement, 1 - absolute position

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions:

% Author: Dorian Bohler SLAC

% Example:
%
% --------------------------------------------------------------------


events = cell(size(pvs));
[events{:}]=deal('PROC');
[list, pList]= SXRSS_pvBuilder(pvs, events);
[c]=size(pvs) ~= size(dx);

if c(2) || c(1)
    disp('Warning array size mismatch')
    return
end

if opt ==0;
    values=lcaGetSmart(pList(:,2));
    dx=values+dx';
end

lcaPutSmart(list, dx);
lcaPutSmart(pList(:,1), 1);

if epicsSimul_status 
    lcaPutSmart(pList(:,2), dx)
end