function [nameSLC, nameSLCCAS, isSLC] = control_klysName(name)
%CONTROL_KLYSNAME
%  [NAMESLC, NAMESLCCAS] = KLYSNAME(NAME) returns the SLC name of the klystron related
%  to the MAD name of the structure.

% Input arguments:
%    NAME: Name of structure (MAD or Epics), string or cell string
%          array

% Output arguments:
%    NAMESLC:    SLC name of related klystron
%    NAMESLCCAS: SLCCAS name of related klystron (MICR:PRIM:UNIT)

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments

% Get EPICS name.
name=cellstr(name);
[name,d,isSLC]=model_nameConvert(name(:),{'EPICS' 'SLC'});

% Map EPICS controlled structures to SLC klystrons.
klysMap={'TCAV0' 'GUN' 'L0A' 'L0B' 'L1S' 'L1X' 'TCAV3' 'XTCAV' 'XTCAVB' 'XTCAVF' 'GUNF' 'L0AF' 'L0BF' 'L1SB' 'L1XF'; ...
         '20-5' '20-6' '20-7' '20-8' '21-1' '21-2' '24-8' 'D1-1' 'D1-1' '20-4' '10-2'  '10-3' '10-4' '11-1' '11-2'}';
[is,id]=ismember(name(:,1),model_nameConvert(klysMap(:,1)));
[name(is,:),d,isSLC(is)]=model_nameConvert(klysMap(id(is),2),{'EPICS' 'SLC'});

nameSLC=name(:,2);
nameSLCCAS=name(:,1);
nameSLCCAS(~isSLC)=nameSLC(~isSLC);
