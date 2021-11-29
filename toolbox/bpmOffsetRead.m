function [xoff, yoff,xoutbpmdx, xoutbpmdy,  pvxBase, pvyBase] = bpmOffsetRead()
%
%  [xoff, yoff,xoutbpmdx, xoutbpmdy,   pvxBase, pvyBase] = bpmOffsetRead()
%
% Return arrays of current bpm offsets in mm for undulator RF bpms. The
% total bpm offset is the sum off the individual offsets xoff.a  xoff.b...
% etc.
%
% Includes LTU bpms RFB07 and RFB08 and all  RF bpms in the undulator
%
%  Only works for HXR line as of 7/7/20

% BBA offset
pvx{1} = 'BPMS:LTUH:910:XAOFF';
pvx{2} = 'BPMS:LTUH:960:XAOFF';
%pvx{3} = 'BPMS:UNDH:100:XAOFF'; rm for LCLS2
pvy{1} = 'BPMS:LTUH:910:YAOFF';
pvy{2} = 'BPMS:LTUH:960:YAOFF';
%pvy{3} = 'BPMS:UNDH:100:YAOFF'; rm for LCLS2

pvxUNDH = meme_names('name','BPMS:UNDH%XAOFF');
pvx = vertcat(pvx', pvxUNDH);
pvyUNDH = meme_names('name','BPMS:UNDH%YAOFF');
pvy = vertcat(pvy', pvyUNDH);

xoff.a = lcaGetSmart(pvx);
yoff.a = lcaGetSmart(pvy);


% Other offsets - Base PV names
pvxLTU{1} = 'BPMS:LTUH:910:XOFF';
pvxLTU{2} = 'BPMS:LTUH:960:XOFF';
pvyLTU{1} = 'BPMS:LTUH:910:YOFF';
pvyLTU{2} = 'BPMS:LTUH:960:YOFF';
pvxUNDH = meme_names('name','BPMS:UNDH%XOFF');
badPV = strcmp(pvxUNDH, 'BPMS:UNDH:ALL:XOFF'); % what the heck is this?
pvxUNDH(badPV)=[];
pvxBase = vertcat(pvxLTU', pvxUNDH);
pvyUNDH = meme_names('name','BPMS:UNDH%YOFF');
badPV = strcmp(pvyUNDH, 'BPMS:UNDH:ALL:YOFF');
pvyUNDH(badPV)=[];
pvyBase = vertcat(pvyLTU', pvyUNDH);

% Cam offsets
pvx = strcat(pvxBase, '.B');
pvy = strcat(pvyBase, '.B');
xoff.b = lcaGetSmart(pvx);
yoff.b = lcaGetSmart(pvy);

% Translation distortion offset
pvx = strcat(pvxBase, '.C');
pvy = strcat(pvyBase, '.C');
xoff.c = lcaGetSmart(pvx);
yoff.c = lcaGetSmart(pvy);

% Pointing offset
pvx = strcat(pvxBase, '.D');
pvy = strcat(pvyBase, '.D');
xoff.d = lcaGetSmart(pvx);
yoff.d = lcaGetSmart(pvy);


% % BPM offset measured  data (not necessarily currently applied offset)
% for q=1:33
%     pvsx{q,1} = sprintf('USEG:UNDH:%d50:XOUTBPMDX',q);
%     pvsy{q,1} = sprintf('USEG:UNDH:%d50:XOUTBPMDY',q);
% end
% xoutbpmdx = lcaGet(pvsx);
% xoutbpmdy = lcaGet(pvsy);
xoutbpmdx = []; % not used for LCLS2
xoutbpmdy = [];
