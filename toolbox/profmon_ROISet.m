function profmon_ROISet(name, pos)
%PROFMON_ROISET
%  PROFMON_ROISET(NAME, POS) sets the ROI for cameras NAME to ROIs in POS.
%  POS needs to be a [4xN] vector for N cameras and refers to raw image
%  pixel coordinates.

% Features:

% Input arguments:
%    NAME: base EPICS or MAD name of cameras
%    POS:  [4xN] vector of ROI X & Y start position and X & Y size

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: profmon_propNames, lcaPutNoWait, lcaPut,
%                   epicsSimul_status

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get camera property PVs and types.
[propsList,name,is]=profmon_propNames(name);
props=propsList(:,21:24);
use=~strcmp(props(:,1),'');
if ~any(use), return, end

% Stop image acquisition for certain cameras.
isAL=use & is.AreaDet & is.LCLS;
isC=use & is.Cascade;
if any(isAL), lcaPutNoWait(strcat(name(isAL),':Acquisition'),'Idle');pause(.5);end
if any(isC)
    pos(3:4,isC)=pos(1:2,isC)+pos(3:4,isC)-1;
    lcaPut(strcat(name(isC),':StopDAQ'),1);pause(.5);
end

% Set new ROI.
props=reshape(props(use,:)',[],1);
pos=max(0,reshape(pos(:,use),[],1));
lcaPut(props,pos);pause(.2); % Set twice (for some complicated reason)
lcaPut(props,pos); % Set twice (for some complicated reason)
%lcaPut([props;props],[pos;pos]); % Set twice (for some complicated reason)
if epicsSimul_status, lcaPut(reshape(propsList(use,5:8)',[],1),pos);end

% Start image acquisition for certain cameras.
if any(isAL), lcaPutNoWait(strcat(name(isAL),':Acquisition'),'Acquire');end
if any(isC)
    pause(.5);lcaPut(strcat(name,':StartDAQ'),1);
end
pause(.5);
