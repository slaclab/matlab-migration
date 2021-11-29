function control_emitSet(name, twiss, twissStd, tag)
%CONTROL_EMITSET
%  CONTROL_EMITSET(NAME, WISS, TWISSSTD, TAG) sets measured emittance data
%  for device NAME.

% Features:

% Input arguments:
%    NAME:     Device name
%    TWISS:    Measured Twiss parameters [4 x 1|2 x N_NAME]
%    TWISSSTD: STD of TWISS
%    TAG:      Plane to update (both X & Y default)

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments
if nargin < 3, twissStd=[];end
if nargin < 4, tag='xy';end

name=model_nameConvert(cellstr(name));
twiss(1,:)=twiss(1,:)*1e6; % Normalized emittance in um

for j=1:length(name)
    for iPlane=1:length(tag)
        names=strcat({'EMITN' 'BETA' 'ALPHA' 'BMAG'}','_',upper(tag(iPlane)));
        pvList=strcat(name{j},':',names);
        pvStdList=strcat(name{j},':D',names);
        val=twiss(:,iPlane,j);
        if ~val(1), continue, end
        lcaPut(pvList(1:size(val,1)),val);
        if ~isempty(twissStd)
            valStd=twissStd(:,iPlane,j);valStd(1)=valStd(1)*1e6;
            lcaPut(pvStdList(1:size(val,1)),valStd);
        end
    end
end
