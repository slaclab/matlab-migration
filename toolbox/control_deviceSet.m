function control_deviceSet(name, secn, val)
%CONTROL_DEVICESET
%  CONTROL_DEVICESET(NAME, SECN, VAL) expand NAME to EPICS name and set
%  NAME:SECN to VAL.

% Features:

% Input arguments:
%    NAME: Base name of device PV.
%    SECN: Attribute(s) of device PVs to set.
%    VAL: Values for device SECN, string, cellstring, or numerical array,
%         or cell array if more than one SECN.

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaSetSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Input checking.
name=model_nameConvert(reshape(cellstr(name),[],1));

if isempty(name), return, end

secn=cellstr(secn);
nVal=size(secn,2);

if iscellstr(val) || ~iscell(val)
    val={val};
end

% Set SECNs to VAL.
for j=1:nVal
    lcaPutSmart(strcat(name,':',secn(:,j)),val{j});
end
