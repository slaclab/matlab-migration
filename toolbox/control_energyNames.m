function [name, isSLC] = control_energyNames(name)
%ENERGYNAMES
%  ENERGYNAMES(NAME) Creates the proper epics PV base names for the EDES of
%  magnet PVs. Name is unchanged for epics controlled magnets and for SLC
%  magnets, the PRIM and MICRO are reversed.

% Features:

% Input arguments:
%    NAME: String or cell string array for name(s) of RF PV or MAD alias(es).

% Output arguments:
%    NAME : String or cell string array for name of EDES base PV.
%    ISSLC: Flag indicating if device is SLC controlled.

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get epics name and SLC flag.
name=cellstr(name);
[name,d,isSLC]=model_nameConvert(name(:));
nameSLC=char(name(isSLC));

% Switch PRIM and MICRO for SLC names.
name(isSLC)=cellstr(nameSLC(:,[6:min(10,end) 1:min(5,end) 11:end]));
