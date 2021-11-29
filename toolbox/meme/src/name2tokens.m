function [PRIM, MICRO, UNIT, SECN] = name2tokens(NAME, varargin)

%% name2tokens tokenizes SLAC (EPICS or SLC) control system name(s)
%  nametok may be given a single or list of names. It splits each given into 
%  primary/type, micro/area, unit (string) and secondary/attribute according to the
%  SLAC control system naming convention. If NAME doesn't 
%  have all 4 parts, empty strings are returned for them. So 3-part device names, or
% 4 part pvnames can both be handled. Colons in the attribute part are preserved.
%
% Input arguments:
%        NAME: Name or cell string array of EPICS or SLC names to be split
%   [OPTIONS]: (Optional) If OPTIONS is given, and is valued 'D' (or 'd'), then 2
%              only items are returned; these are the device-name, and the 
%              secondary name (or more formally, the entity and the
%              attribute). 
%
% Output arguments:
%        PRIM:  Primary name or list
%       MIRCO:  Micro or IOC name or list
%        UNIT:  Unit number as string or list
%        SECN:  Secondary name or list

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, Greg White, SLAC.
% Mod:    Greg White, 3-Jun-2014, SLAC. Created this version, which simply
%         wraps Henrik's original, so that a symmetrical function NAMEDETOK
%         could also be written, and to drop the misleading 'model' prefix.

[prim, micro, unit, secn] = model_nameSplit( NAME );

if ( nargin == 2 )
    opt = upper(char( varargin{1} ));
    if ( opt(1) == 'D' )
        entity = tokens2name( prim, micro, unit );
        PRIM = entity;
        MICRO = secn;        % MICRO is a misleading name in this case, since it will
                             % either contain either the secondary (if NAME was
                             % a 4-tuple), or be null (if NAME was a 3-tuple).
    end
else
    PRIM = prim;
    MICRO = micro;
    UNIT = unit;
    SECN = secn;
end

