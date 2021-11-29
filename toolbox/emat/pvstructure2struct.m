function [ s ] = pvstructure2struct( pvstruct )

% PVSTRUCTURE2STRUCT converts an EPICS V4 PvStructure to a matlab struct.
% TODO: NOTE THIS IS NOT YET RECURSIVE! It will only do the 1st ply.
% That is, it does the fields inside a "top level" pvstructure, but if 
% any one of those fields is a pvStructure, it doesn't do those too.

% Get introspection interface (describes the sructure), and from it
% get the field names.
str_ii = pvstruct.getStructure();
fieldnames = str_ii.getFieldNames();

% Construct a matlab struct from the elements of the pvStructure.
s=struct;
for fi = 1:fieldnames.length;
    s=setfield(s,char(fieldnames(fi)),...
        pvstruct.getSubField(fieldnames(fi)).get());
end


