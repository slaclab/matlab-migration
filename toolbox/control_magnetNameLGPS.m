function [nameLGPS, is] = control_magnetNameLGPS(name, isSLC)
%CONTROL_MAGNETNAMELGPS
%  [NAMELGPS, IS] = CONTROL_MAGNETNAMELGPS(NAME, ISSLC) get name for LGPS
%  of magnet NAME if ISSLC.

% Features:

% Input arguments:
%    NAME: Base name or cellstring array of magnet PVs.
%    ISSLC: Logical array if device is SLC controlled, searches if omitted.

% Output arguments:
%    NAMELGPS: Name of LGPS for magnets
%    IS: QUAS, BNDS, STR: Logical arrays if device is QUAS or BNDS or
%    either

% Compatibility: Version 2007b, 2012a
% Called functions: lcaGet, model_nameConvert

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

name=cellstr(name);name=name(:);
if nargin < 2, [name,d,isSLC]=model_nameConvert(name);end

nameLGPS=cell(0,1);
[is.QUAS,is.BNDS,is.Str,is.BEND,is.Trim]=deal(false(numel(name),1));

if ~any(isSLC), return, end

[m,p]=model_nameSplit(name(isSLC));
is.QUAS(isSLC)=ismember(p,{'QUAS' 'SXTS'});
is.BNDS(isSLC)=ismember(p,{'BNDS' 'SPTS'});
is.BEND(isSLC)=ismember(p,{'BEND' 'SEPT'});
is.Trim(isSLC)=ismember(p,{'BTRM' 'QTRM'});
is.Str=is.QUAS | is.BNDS;
if any(is.Str)
    unit=lcaGet(strcat(name(is.Str),':PSCP'));
%    unit(~unit)=str2num(char(u(~unit)));
    nameLGPS=strcat(m(is.Str(isSLC)),':LGPS:',num2str(unit,'%0d'));
end
