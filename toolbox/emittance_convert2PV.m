function pvRec = emittance_convert2PV(name, twiss, ts)
%EMITTANCE_CONVERT2PV
%  EMITTANCE_CONVERT2PV(NAME, BEAM, TS)

% Input arguments:
%    NAME:  Name of device or emittance scan data structure
%    TWISS: Array of twiss parameters
%    TS:    Time stamp

% Output arguments:
%    PVREC: Stats results structure mimicking return from util_readPV

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin == 1
    data=name;
else
    data.name=name;
    data.twiss=twiss;
    data.ts=ts;
end
pvRec=repmat(struct,8,length(data));
tags={'EMIT' 'BETA' 'ALPHA' 'BMAG'}';
desc={'Normalized emittance ' 'Beta ' 'Alpha ' 'Mismatch parameter '}';
for j=1:length(data)
    nameList=strcat(data(j).name,':',[strcat(tags,'X');strcat(tags,'Y')]);
    descList=[strcat(desc,'X');strcat(desc,'Y')];
    eguList={'um' 'm' '' '' 'um' 'm' '' ''};
    twiss=data(j).twiss(:,:,:,1);twiss(1,:)=twiss(1,:)*1e6;
    val=num2cell(reshape(twiss,8,[]),2);
    [pvRec(1:8,j).name]=deal(nameList{:});
    [pvRec(1:8,j).val]=deal(val{:});
    [pvRec(1:8,j).ts]=deal(data(j).ts);
    [pvRec(1:8,j).desc]=deal(descList{:});
    [pvRec(1:8,j).egu]=deal(eguList{:});
end
