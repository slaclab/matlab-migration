function poly = control_magnetIVBGet(name)
%CONTROL_MAGNETIVBGET
%  CONTROL_MAGNETIVBGET(NAME) gets the right magnet polynomial for SLC
%  magnets, flips to Matlab order.

% Features:

% Input arguments:
%    NAME: Base name(s) of magnet PV(s).

% Output arguments:
%    POLY: Magnet polynomial, IVBU or if zero, IVBD

% Compatibility: Version 7 and higher
% Called functions: control_deviceGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get polynomials.
[polyU,polyD]=control_deviceGet(name,{'IVBU' 'IVBD'});

% Set NaNs to 0.
polyU(isnan(polyU))=0;polyD(isnan(polyD))=0;

% Remove trailing 0 columns.
polyU(:,find(any(polyU,1),1,'last')+1:end)=[];
polyD(:,find(any(polyD,1),1,'last')+1:end)=[];

% Find highest degree and expand arrays to it.
nDegree=max(size(polyU,2),size(polyD,2));
polyU(:,end+1:nDegree)=0;
polyD(:,end+1:nDegree)=0;

% Flip to Matlab poly order and select "down" poly if "op" zero.
poly=fliplr(polyU);
poly(~any(polyU,2),:)=fliplr(polyD(~any(polyU,2),:));
