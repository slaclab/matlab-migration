function [uAct,uDes,uMax,uMin,eDes]=control_undGet(name,secn)
%CONTROL_UNDGET
%  [UACT,UDES,UMAX,UMIN,EDES]=CONTROL_UNDGET(NAME)
%    Get undulator or PPM phase shifter ACT/DES/MAX value.
%
% NOTE: Presently gives 0 for missing XLEAP undulators!

% Input arguments:
%   NAME: Device name(s).
%   SECN: Secondary name (optional, default KACT)

% Output arguments:
%   UACT: ACT value(s)
%   UDES: DES value(s)
%   UMAX: MAX value(s)
%   UMIN: MIN value(s)
%   EDES: EDES value(s)

% Compatibility: Version 2007b, 2012a, 2019a

% Called functions: 
%   model_nameConvert
%   lcaGetSmart
%   control_energyNames

% Author: M. Woodley (SLAC) ... from control_magnetGet.m

% --------------------------------------------------------------------

[uAct,uDes,uMax,uMin,eDes]=deal([]);
if isempty(name(:)),return,end
name=reshape(cellstr(name),[],1);

[~, accel] = getSystem;
if strcmp(accel, 'FACET')
    % Temporary until we install FACET II heater
    id = strcmp(name,'UM10466');
    uAct(id,1) = 0;
    uDes(id,1) = 0;
    uMax(id,1) = 0;
    uMin(id,1) = 0;
    eDes(id,1) = 0.1350;
    return
end

% deal with absurd case-sensitivity of some secondary names
ACTsecn=repmat({'KACT'},numel(name),1);
DESsecn=repmat({'KDES'},numel(name),1);
MAXsecn=repmat({'KMAX'},numel(name),1);
MINsecn=repmat({'KMIN'},numel(name),1);
id=(strcmp(name,'LH_UND')); % Cu linac laser heater undulator
  ACTsecn(id)={'KACT'};
  DESsecn(id)={'KDES'};
  MAXsecn(id)={'KMAX'};
  MINsecn(id)={'KMIN'};
id=(strncmp(name,'UMAHXH',6)| ... % HXR undulator
    strncmp(name,'UMASXH',6)| ... % SXR undulator
    strcmp(name,'UMHTR')| ...     % SC linac laser heater undulator
    strncmp(name,'UMXL',4));        % XLEAP undulator
  ACTsecn(id)={'KAct'};
  DESsecn(id)={'KDes'};
  MAXsecn(id)={'KMax'};
  MINsecn(id)={'KMin'};
id=(strncmp(name,'PSHXH',5)| ... % HXR phase shifter
    strncmp(name,'PSSXH',5));    % SXR phase shifter
  ACTsecn(id)={'PIAct'};
  DESsecn(id)={'PIDes'};
  MAXsecn(id)={'PIMax'};
  MINsecn(id)={'PIMin'};

% construct PV's
dname=model_nameConvert(name,'EPICS');
uAct = zeros(size(dname));
uDes = uAct; uMax = uAct; uMin = uAct;
% XLEAP wiggler u values are done using gap, below
todo = ~strncmp(name,'UMXL',4) & ~strncmp(name,'WIGXL',5);
if (nargout>=1),uAct(todo)=lcaGetSmart(strcat(dname(todo),':',ACTsecn(todo)));end
if (nargout>=2),uDes(todo)=lcaGetSmart(strcat(dname(todo),':',DESsecn(todo)));end
if (nargout>=3),uMax(todo)=lcaGetSmart(strcat(dname(todo),':',MAXsecn(todo)));end
if (nargout>=4),uMin(todo)=lcaGetSmart(strcat(dname(todo),':',MINsecn(todo)));end
if (nargout==5)
  nameEDES=control_energyNames(name);
  eDes=lcaGetSmart(strcat(nameEDES,':EDES'));
end

id=strncmp(name,'UMXL',4);        % XLEAP wiggler, type 2
if any(id)
    KXLtype2 = 42.5; % K value when this type of XLEAP wiggler is in
    pvs = strcat(model_nameConvert(name(id)),':US:Motor.RBV');
    isIn = abs(lcaGetSmart(pvs)) < 3;
    uAct(id) = isIn.*KXLtype2;
    pvs = strcat(model_nameConvert(name(id)),':US:Motor');
    isIn = abs(lcaGetSmart(pvs)) < 3;
    uDes(id) = isIn.*KXLtype2;
    uMax(id) = KXLtype2.*ones(size(uDes(id)));
    uMin(id) = zeros(size(uDes(id)));
    eDes(id) = lcaGetSmart('REFS:DMPS:400:EDES');
end

% Temporary until we sort out old XLEAP undulators
id=strncmp(name,'WIGXL',5);
uAct(id) = 42.5;
uDes(id) = 0;
uMax(id) = 42.5;
uMin(id) = 0;
eDes(id) = lcaGetSmart('REFS:DMPS:400:EDES');


