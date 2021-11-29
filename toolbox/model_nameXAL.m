function name = model_nameXAL(name, isEPICS)
%MODEL_NAMEXAL
%  NAME = MODEL_NAMEXAL(NAME) returns the XAL name of the device.

% Input arguments:
%    NAME:    Name of device (MAD, Epics, or SLC), string or cell string
%             array
%    ISEPICS: 1 if NAME is already in EPICS type, default 0

% Output arguments:
%    NAME: XAL name of related klystron

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert, model_nameSplit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments

% Get EPICS name.
name=cellstr(name);name=name(:);
if ~numel(name), name={};return, end % need to return {} array for aidaget to work

if nargin < 2 || ~isEPICS, name=model_nameConvert(name);end

n24=model_nameConvert({'24-1' '24-2' '24-3'},{'EPICS' 'SLC'});
[is24,id]=ismember(name,n24(:,1));

[prim,micro,unit,secn]=model_nameSplit(name);
name=strcat(prim,':',micro,':',unit);
noUnit=cellfun('isempty',unit);
name(noUnit)=strcat(prim(noUnit),':',micro(noUnit));
noMicro=cellfun('isempty',micro);
name(noMicro)=prim(noMicro);
isBSY1=strcmp(micro,'BSY1');
name(isBSY1)=strcat(name(isBSY1),':',secn(isBSY1));

name(is24)=n24(id(is24),2);
name(ismember(name,{'ACCL:LI21:1' 'KLYS:LI21:K1'}))={'KLYS:LI21:11'};
