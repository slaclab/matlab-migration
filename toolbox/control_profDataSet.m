function control_profDataSet(name, beam, tag)
%CONTROL_PROFDATASET
%  CONTROL_PROFDATASET(NAME, BEAM, TAG) sets result PVs for profile monitor
%  or wire scanner NAME based on processing results in BEAM structure for
%  plane TAG.

% Input arguments:
%    NAME: Name of device (MAD, Epics, or SLC), string or cell string
%    BEAM: Processing result struct
%    TAG: Plane to update (both X & Y default)

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaPutSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments
if nargin < 3, tag='xy';end

name=model_nameConvert(cellstr(name));
if ~isempty(strfind(name{1},'LR20')), return, end
stats=beam(1).stats.*[1e-3 1e-3 1 1 1/prod(beam(1).stats(3:4)) 1]; % Data in [mm mm um um 1 cts]
use=true(6,1);
if ~any(tag == 'x'), use([1 3 5])=0;end
if ~any(tag == 'y'), use([2 4 5])=0;end

names={'X' 'Y' 'XRMS' 'YRMS' 'XY' 'SUM'}';
pvList=strcat(name{1},':',names);

lcaPutSmart(pvList(use),stats(use)');
