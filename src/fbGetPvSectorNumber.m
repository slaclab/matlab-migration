function [sectors] = fbGetPvSectorNumber(pvs) 
%
%   fbGetPvSectorNumber.m
%
%   This function takes a vector of PV name strings and returns a vector 
%   of Linac sector number strings. If the location field is not a Linac
%   sector, return an empty string.
%   
%   	Arguments:
%                   pvs         Cell array of string PV names. PV names must
%                               have location in second field, for example
%                               SBST:LI22:1:PDES. 
%
%       Return:
%                   sectors     Cell array of char sector names
%
%   Examples:   pvs={'BPMS:LI25:201:X'}
%               fbGetPvSectorNumber(pvs) returns '25'
%
%               pvs={'BPMS:LTU1:880:X'}
%               fbGetPvSectorNumber(pvs) returns ''  
%
%
% For each PV, 
%       Locate sector string (first instance of ':LI') in PV name
%       Create string consisting of the 4-character sector name
%       Find index of that name in the sectors list from fbGetCamacState
%       Use index to get that sector's state 
%       If state=1, use aida to set value (is micro-controlled)
%           Else state=0, use lcaPut to set value (is IOC-controlled)
%       If sector not found in list of sectors, assume it is an EPICS PV
%       and use lcaPut

pvs=cellstr(pvs);
l_pvs=length(pvs); 

for j=1:l_pvs
    pv=pvs{j};
    n=findstr(pv,':LI');
    if n
        sectors{j}=char(pv(n+3:n+4));
    else
        sectors{j}=char('');
        disp(sprintf('%s location is not a Linac sector; returning empty string.\n',pvs{j}));
    end
end


