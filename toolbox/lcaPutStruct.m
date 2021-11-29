function isPV = lcaPutStruct(pvstruct, valstruct, varargin)
%LCAPUTTSTRUCT
% ISPV = LCAPUTSTRUCT(PVSTRUCT, VALSTRUCT, [NMAX, TYPE])
% Wrapper function for lcaPutSmart() to allow fast, structured channel 
% access for large numbers of PVs.  See lcaPutSmart documentation for more
% details.  Values in VALSTRUCT are put into the PVs in PVSTRUCT.
%
% Input arguments:
%    PVSTRUCT: Arbitrary struct of EPICS PV names.  PVSTRUCT can have
%       substructs, arrays of substructs, and leaf elements of type char or
%       cellstr (array).
%    VALSTRUCT: Data struct of values, with same shape as PVSTRUCT.
%    NMAX:  Optional max number of output elements per PV, passed to lcaGetSmart()
%    TYPE:  Optional string of output type passed to lcaGetSmart()
%
% Output arguments:
%    ISPV:  Struct of logicals, with 1 for successful PVs and 0 for failed ones
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC
%
% --------------------------------------------------------------------

% flatten structure tree into N X 1 list
pvlist = flatten(pvstruct)';
vallist = nflatten(valstruct)';

% lcaGet everything as an array
list_isPV = lcaPutSmart(pvlist, vallist, varargin{:});

% unflatten the list back into tree structure
isPV = unflatten(list_isPV, pvstruct);

end

function l = nflatten(s)
% depth-first traversal of input structure s
% returns l, a list of all leaf nodes in s

% get the names of all children
fields = fieldnames(s);

% identify which are branches and which are leaves
branch = [];
for ix = 1:numel(fields)
    branch = [branch; any(arrayfun(@(x) isstruct(x), s.(char(fields(ix)))(:)))];
end
leaf = ~branch;
branches = fields(find(branch));
leafs = fields(find(leaf));

% make an empty list
l = [];

% put the leaves on the list
for ix = 1:numel(leafs)
    thisleaf = reshape(s.(char(leafs(ix))), 1, []);    
    l = [l, thisleaf];
end

% recursively put the branches' leaves on the list
for ix = 1:numel(branches)
    thisbranch = s.(char(branches(ix)));
    for jx = 1:numel(thisbranch)
        l = [l, nflatten(thisbranch(jx))];
    end
end

% done
end

function l = flatten(s)
% depth-first traversal of input structure s
% returns l, a list of all leaf nodes in s

% get the names of all children
fields = fieldnames(s);

% identify which are branches and which are leaves
branch = [];
for ix = 1:numel(fields)
    branch = [branch; any(arrayfun(@(x) isstruct(x), s.(char(fields(ix)))(:)))];
end
leaf = ~branch;
branches = fields(find(branch));
leafs = fields(find(leaf));

% make an empty list
l = {};

% put the leaves on the list
for ix = 1:numel(leafs)
    thisleaf = reshape(cellstr(s.(char(leafs(ix)))), 1, []);    
    l = [l, thisleaf];
end

% recursively put the branches' leaves on the list
for ix = 1:numel(branches)
    thisbranch = s.(char(branches(ix)));
    for jx = 1:numel(thisbranch)
        l = [l, flatten(thisbranch(jx))];
    end
end

% done
end

function [s, l] = unflatten(l, r)
% reconstructs a tree structure identical to reference struct r
% l is the input list, which is returned modified
% this should be the inverse of flatten()

% get the names of all children
fields = fieldnames(r);

% identify which are branches and which are leaves
branch = [];
for ix = 1:numel(fields)
    branch = [branch; any(arrayfun(@(x) isstruct(x), r.(char(fields(ix)))(:)))];
end
leaf = ~branch;
branches = fields(find(branch));
leafs = fields(find(leaf));

% populate the leaves with list elements
for ix = 1:numel(leafs)
    % leaf dimensions come from r
    leafsize = size(cellstr(r.(char(leafs(ix)))));
    leaflen = numel(cellstr(r.(char(leafs(ix)))));
    % pop the leaf elements off the front of the list
    thisleaf = reshape(l(1:leaflen), leafsize);
    s.(char(leafs(ix))) = thisleaf;
    l(1:leaflen) = [];
end

% recursively put the rest of the list into s's branches
for ix = 1:numel(branches)
    % branch dimensions comes from r
    branchsize = size(r.(char(branches(ix))));
    branchlen = numel(r.(char(branches(ix))));    
    
    % l gets modified here, as stuff is popped off it.
    %thisbranch = s.(char(branches(ix)));
    for jx = 1:branchlen
        [s.(char(branches(ix)))(jx), l] = unflatten(l, r.(char(branches(ix)))(jx));        
    end
    s.(char(branches(ix))) = reshape(s.(char(branches(ix))), branchsize);
end

% done
end