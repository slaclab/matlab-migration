function pvRec = beamAnalysis_convert2PV(name, beam, ts)
%BEAMANALYSIS_CONVERT2PV
%  BEAMANALYSIS_CONVERT2PV(NAME, BEAM, TS)

% Input arguments:
%    NAME: Name of device or image or wire scan data structure
%    BEAM: Structure array returned from beamAnalysis_beamParams
%    TS:   Time stamp

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
    data.beam=beam;
    data.ts=ts;
end
pvRec=repmat(struct,6,length(data));
for j=1:length(data)
    nameList=strcat(data(j).name,':',{'X' 'Y' 'XRMS' 'YRMS' 'XY' 'SUM'}');
    descList={'X position' 'Y position' 'X rms' 'Y rms' 'XY corr' 'profile intensity'};
    eguList={'um' 'um' 'um' 'um' 'um^2' 'cts'};
    val=num2cell(vertcat(data(j).beam.stats)',2);
    [pvRec(1:6,j).name]=deal(nameList{:});
    [pvRec(1:6,j).val]=deal(val{:});
    [pvRec(1:6,j).ts]=deal(data(j).ts);
    [pvRec(1:6,j).desc]=deal(descList{:});
    [pvRec(1:6,j).egu]=deal(eguList{:});
end
