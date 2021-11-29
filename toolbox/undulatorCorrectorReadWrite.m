function [xcors, ycors] = undulatorCorrectorReadWrite(xcors, ycors)
%
% xcors = xCorrectorReadWrite(xcors)
%
% If no input arguments are given, it returns the actual values of the
% undulator correctors. If both a set of x and y corrector values is given
% as input,  it sets the undulator correctors to those values. Only
% undulator correctors 1:33 are included. 
%
% Typical you call it with no arguments to get vectors you modify and then
% call it again with the modifed vectors.

% make pvs
for q=1:33
    pvXcors(q,1) = {sprintf('XCOR:UND1:%d80:BCTRL',q)};
    pvYcors(q,1) = {sprintf('YCOR:UND1:%d80:BCTRL',q)};
end

if nargin == 0
    xcors = lcaGet(pvXcors);
    ycors = lcaGet(pvYcors);
end

if nargin == 2
    lcaPut(pvXcors, xcors)
    lcaPut(pvYcors, ycors)
end