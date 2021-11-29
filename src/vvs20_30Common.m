function [loc,numLoc] = vvs20_30Common()
%
%   vvs20_30Common.m
%
%   This function performs common operations required by any LI20-LI30 VVS
%   batch functions. At this time, this is just to get a list of VVS
%   locations.
%
%   	Arguments:
%                   None
%
%       Return:
%                   loc         Vector of VVS location name strings
%                   numLoc      Number of VVSs
%


% VVS locations
loc = {'LI20'; 'LI22'; 'LI24'; 'LI26'; 'LI28'; 'LI30'};
numLoc = length(loc); 
