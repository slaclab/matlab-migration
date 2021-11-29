function [prim, micro, unit, secn] = model_nameSplit(name)
%NAMESPLIT
%  [PRIM, MICRO, UNIT, SECN] = NAMESPLIT(NAME) splits EPICS or SLC name
%  or list of names into primary, micro/area (IOC), unit string and
%  secondary/attribute. If name doesn't have all parts, empty strings are
%  returned for them.  Colons in the attribute part are preserved.

% Input arguments:
%    NAME: Name or cell string array of EPICS or SLC names to be split

% Output arguments:
%    PRIM:  Primary name or list
%    MIRCO: Micro or IOC name or list
%    UNIT:  Unit number as string or list
%    SECN:  Secondary name or list

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

name=cellstr(name);name=name(:);
parts=regexp(name,':','split');
num=cellfun('length',parts);

list=repmat({''},numel(name),4);
for j=unique(num)'
    partsj=vertcat(parts{num == j});
    if j > 4
        list(num == j,1:3)=partsj(:,1:3);
        str=[num2cell(partsj(:,4:end),1);repmat({':'},1,j-4) {''}];
        list(num == j,4)=strcat(str{:});
    else
        list(num == j,1:j)=partsj;
    end
end

prim=list(:,1);
micro=list(:,2);
unit=list(:,3);
secn=list(:,4);
