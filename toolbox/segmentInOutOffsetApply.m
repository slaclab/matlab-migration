function [isApplied, undStat, undInst, pvNames] = segmentInOutOffsetApply(nUnd, varargin)
%SEGMENTINOUTOFFSETAPPLY
%  SEGMENTINOUTOFFSETAPPLY(NUND) sets BPM offsets and corrrector magnets in
%  undulator to correct orbit deviations due to undulator
%  insertion/retraction. It shifts offsets from XAOFF to XOFF.C for
%  retracted segments as necessary.

% Input arguments:
%    NUND: vector of segment numbers

% Output arguments:

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'noApply',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 1, nUnd=1:33;end
if isempty(nUnd), return, end

nUnd=nUnd(:);
undPV=model_nameConvert(cellstr(num2str(nUnd,'US%02d')));

% Determine and apply BPM offset and orbit correction.
undStat=ismember(lcaGet(strcat(undPV,':LOCATIONSTAT')),{'AT-XOUT'}); % 1 = retracted
undInst=lcaGet(strcat(undPV,':INSTALTNSTAT'),0,'double');
appliedPV=strcat(undPV,':XOUTCORSTAT');
isApplied=lcaGet(appliedPV,0,'double');
val=~undStat; % 1 = inserted

% Generate names for correction PVs.
pvBase=strcat(undPV,':XOUT');
pvNames.bpmOff=[strcat(pvBase,'BPMDX');strcat(pvBase,'BPMDY')];
pvNames.cor2Off=[strcat(pvBase,'XCOR2');strcat(pvBase,'YCOR2')];
pvNames.cor1Off=[strcat(pvBase,'XCOR1');strcat(pvBase,'YCOR1')];

% Generate names for offset and corrector PVs.
pv=model_nameConvert(cellstr(num2str(nUnd,'RFBU%02d')));
pvNames.bpm=[strcat(pv,':XOFF.C');strcat(pv,':YOFF.C')];
pv=model_nameConvert(cellstr(num2str(nUnd,'XCU%02d')));
pvNames.cor2=strcat([pv;strrep(pv,'X','Y')],':BCTRL');
pv=model_nameConvert(cellstr(num2str(nUnd-1,'XCU%02d')));
corPV1=strcat([pv strrep(pv,'X','Y')],':BCTRL');

% Replace corrector PV with BPM offset for US01.
is1st=nUnd == 1;
pv(is1st)=model_nameConvert({'RFBU00'});
if any(is1st)
    corPV1(is1st,:)=[strcat(pv(is1st),':XOFF.C') strcat(pv(is1st),':YOFF.C')];
end
corPV1=corPV1(:);
pvNames.cor1=corPV1;

if opts.noApply, return, end

% Get EPICS correction status.
corrStat=~any(lcaGet(strcat(undPV,':XCORCORSTAT'),0,'double'));

% Get corrections.
bpmDOffs=lcaGet(pvNames.bpmOff);
corrOffs2=lcaGet(pvNames.cor2Off);
corrOffs1=lcaGet(pvNames.cor1Off);

% Apply BPM offset corrections.
use=undStat & undInst;
use2=[use;use];
if corrStat, lcaPutSmart(pvNames.bpm,use2.*bpmDOffs);end

% Apply absolute corrector values.
[corPV,b,c]=unique([pvNames.cor1;pvNames.cor2]);
corrOffs=accumarray(c,[use2.*corrOffs1;use2.*corrOffs2]);
lcaPutSmart(corPV,corrOffs*corrStat);

% Set correction status.
isApplied=~(val | ~undInst);
lcaPut(appliedPV,double(isApplied));
