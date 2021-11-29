% Set Bunch Length Calibration GUI Plot Button Names

% Mike Zelazny (zelazny@stanford.edu)

global gBunchLength;
global gBunchLengthGUI;

vString = cell(0);
vString{end+1} = sprintf('cf %s X Plot',gBunchLength.bpm.desc);
vString{end+1} = sprintf('cf %s Y Plot',gBunchLength.bpm.desc);
vString{end+1} = sprintf('cf %s TMIT Plot',gBunchLength.bpm.desc);
vString{end+1} = sprintf('cf %s TMIT Plot',gBunchLength.toro.desc);
set (gBunchLengthGUI.handles.cfBPMPlot,'String',vString);

vString = cell(0);
vString{end+1} = sprintf('%s X Plot',gBunchLength.bpm.desc);
vString{end+1} = sprintf('%s Y Plot',gBunchLength.bpm.desc);
vString{end+1} = sprintf('%s TMIT Plot',gBunchLength.bpm.desc);
vString{end+1} = sprintf('%s TMIT Plot',gBunchLength.toro.desc);
set (gBunchLengthGUI.handles.cBPMPlot,'String',vString);

vString = cell(0);
vString{end+1} = sprintf('%s XMEAN Plot',gBunchLength.screen.desc);
vString{end+1} = sprintf('%s YMEAN Plot',gBunchLength.screen.desc);
vString{end+1} = sprintf('%s XRMS Plot',gBunchLength.screen.desc);
vString{end+1} = sprintf('%s YRMS Plot',gBunchLength.screen.desc);
vString{end+1} = sprintf('%s CORR Plot',gBunchLength.screen.desc);
vString{end+1} = sprintf('%s SUM Plot',gBunchLength.screen.desc);
set (gBunchLengthGUI.handles.cScreenPlot,'String',vString);