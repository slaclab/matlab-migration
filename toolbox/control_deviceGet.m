function varargout = control_deviceGet(name, secn, type)
%CONTROL_DEVICEGET
%  CONTROL_DEVICEGET(NAME, SECN) expand NAME to EPICS name and get NAME:SECN.

% Features:

% Input arguments:
%    NAME: Base name of device PV.
%    SECN: Attribute(s) of device PVs to get.
%    type: Data type to request.

% Output arguments:
%    VAL: Device SECN, multiple outputs for multiple SECN columns.

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaGetSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

name=model_nameConvert(reshape(cellstr(name),[],1));

if nargin < 3, type={};end
type=cellstr(type);
secn=cellstr(secn);
nVal=min(max(1,size(secn,2)),max(1,nargout));
val=cell(1,nVal);
if isempty(name)
    varargout(1:nVal)=val(1:nVal);
    return
end

% Get VAL for SECNs.
for j=1:nVal
    val{j}=lcaGetSmart(strcat(name,':',secn(:,j)),0,type{:});
end

varargout(1:nVal)=val(1:nVal);
