function  kmSegmentTranslate (mainHandles)
%
% translationStatus = kmSegmentTranslate (mainHandles)
%
% Simultaneously translate all undulator segments to values in array
% mainHandles.translation. Applies bpm and corrector corrections for girder
% and field distortions. Returns when motion is complete.
%
% mainHandles.translation(1:33) holds the set point for horizontal translation
% of segments [mm]. 80 mm is fully out of the beam. mainHandles.messages is
% the handle to a message window. Normally this program is called from
% KMeasurement based functions: Initialize or Perform
%
% if mainHandles.debug = 1, no translation is made, but plots are updated

display('Translating segments');

taper = segmentTranslate();
for q=1:33
    pvs{q,1} = sprintf('USEG:UND1:%d50:TMXPOSC', q);
end
if mainHandles.debug == 1
    pause(.5); % for realism
else
    %  use segmentMoveInOut function 1= move in 0= move out with correction
    display('Moving segments to starting position');
    if any( abs(taper(:) - mainHandles.translation(:))>15 ) % if any motions are big, use IN/OUT
        nund = 1:33;
        vals = mainHandles.translation < 15; % 15 mm chosen for cutoff
        kmSegmentMoveInOut(nund, vals,mainHandles) % move IN or OUT with orbit corrections
    end
    % adjust to final positions
    segmentTranslate(mainHandles.translation(:))
end

kmSegmentPlot(mainHandles);

function kmSegmentMoveInOut(nUnd, val, mainHandles)
% kmSegmentMoveInOut(nUnd, val, mainHandles)
%
%  Inserts or retracts multiple undulator segments; work with K measurement
%  GUI

% Input arguments:
%    NUND: vector of segment numbers
%    VAL: scalar or vector of desired segment status (0: OUT, 1: IN)
%   mainHandles is the guidate from the main K measurement gui figure

% Output arguments:

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert

% Author: Henrik Loos, SLAC, modified by J. Welch

% --------------------------------------------------------------------

if isempty(nUnd), return, end

nUnd=nUnd(:);val=val(:);
val(end+1:length(nUnd),1)=val(end);
val=logical(val);

undPV=model_nameConvert(cellstr(num2str(nUnd,'US%02d')));
%undStat=ismember(lcaGet(strcat(undPV,':LOCATIONSTAT')),{'AT-XOUT'});
undInst=lcaGet(strcat(undPV,':INSTALTNSTAT'),0,'double');
appliedPV=strcat(undPV,':XOUTCORSTAT');
isApplied=lcaGet(appliedPV,0,'double');

% Determine undulator action.
action(val,1)={'TRIM'};
action(~val,1)={'EXTRACT'};

% Insert BYKICK.
%beamOffPV='DUMP:LTU1:970:TDUND_PNEU';
beamOffPV='IOC:BSY0:MP01:BYKIKCTL';
beamOffState=lcaGet(beamOffPV,0,'double');
lcaPut(beamOffPV,0);pause(1.);

% Move undulator segments.
lcaPutNoWait(strcat(undPV,':',action,'.PROC'),1);pause(1.);

% Wait until all completed.
while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), 
    kmSegmentPlot(mainHandles);
    pause(2);
    set(mainHandles.messages,'String', 'Moving segments...');
    pause(1);
    set(mainHandles.messages,'String', '......Moving segme');
    pause(1);
    set(mainHandles.messages,'String', '............Moving');
    kmSegmentPlot(mainHandles);
end
 

% Set BPM offsets and corrector BDES.
pvBase=strcat(undPV,':XOUT');
pv=[strcat(pvBase,'BPMDX') strcat(pvBase,'BPMDY')];
bpmDOffs=reshape(lcaGet(pv(:)),[],2);
pv=[strcat(pvBase,'XCOR2') strcat(pvBase,'YCOR2')];
corrOffs2=reshape(lcaGet(pv(:)),[],2);
pv=[strcat(pvBase,'XCOR1') strcat(pvBase,'YCOR1')];
corrOffs1=reshape(lcaGet(pv(:)),[],2);

pv=model_nameConvert(cellstr(num2str(nUnd,'RFBU%02d')));
bpmPVs=[strcat(pv,':XAOFF') strcat(pv,':YAOFF')];
bpmOffs=lcaGet(bpmPVs(:));

is1st=nUnd == 1;
pv=model_nameConvert(cellstr(num2str(nUnd,'XCU%02d')));
corPV2=strcat([pv strrep(pv,'X','Y')],':BCTRL');
pv=model_nameConvert(cellstr(num2str(nUnd-1,'XCU%02d')));
corPV1=strcat([pv strrep(pv,'X','Y')],':BCTRL');

if any(is1st)
    pv(is1st)=model_nameConvert({'RFBU00'});
    corPV1(is1st,:)=[strcat(pv(is1st),':XAOFF') strcat(pv(is1st),':YAOFF')];
end

% Set sign of corrections depending on insert or retract.
bpmDOffs(val,:)=-bpmDOffs(val,:);
corrOffs2(val,:)=-corrOffs2(val,:);
corrOffs1(val,:)=-corrOffs1(val,:);

% Set correction to 0 when already applied (insert & ~applied or retract & applied).
isZero=~(val == isApplied) | ~undInst;
bpmDOffs(isZero,:)=0;
corrOffs2(isZero,:)=0;
corrOffs1(isZero,:)=0;

% Apply corrections when not already applied.
lcaPut(bpmPVs(:),bpmOffs+bpmDOffs(:));
cor2=lcaGet(corPV2(:));
lcaPut(corPV2(:),cor2+corrOffs2(:));pause(2);
cor1=lcaGet(corPV1(:));
lcaPut(corPV1(:),cor1+corrOffs1(:));

% Set correction status.
lcaPut(appliedPV,double(~val & undInst));

% Put BYKICK to previous state.
lcaPut(beamOffPV,beamOffState);pause(1.);
