% Transition to Bunch Length Options GUI
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIsetOpts (handles)

global gBunchLength;

BunchLengthGUIresetMeas (handles);
BunchLengthGUIresetCal (handles);
BunchLengthGUIresetBatch (handles);

set (handles.OptsGUI,'Enable','off');
BunchLengthGUIWindowName (handles.BunchLengthGUI, 'Options');

set (handles.Save,'Visible','on');

if gBunchLength.screen.movable
    set (handles.ScreenIn,'Visible','on');
    set (handles.ScreenOut,'Visible','on');
    set (handles.ScreenDesc,'Visible','on');
end

set (handles.Rate,'Visible','on');
set (handles.RateEgu,'Visible','on');
set (handles.RateDesc,'Visible','on');

set (handles.TCAVPDES,'visible','on');
set (handles.TCAVPDESDESC,'visible','on');
set (handles.TCAVPDESEGU,'visible','on');
set (handles.TCAVPACT,'visible','on');
set (handles.TCAVPACTDESC,'visible','on');
set (handles.TCAVPACTEGU,'visible','on');
set (handles.TCAVAACT,'visible','on');
set (handles.TCAVAACTDESC,'visible','on');
set (handles.TCAVAACTEGU,'visible','on');
set (handles.TCAVACTIVE,'visible','on');

set (handles.IMGCNTOPTS,'Visible','on');
set (handles.NBI,'Visible','on');
set (handles.NBIDESC,'Visible','on');
set (handles.NI,'Visible','on');
set (handles.NIDESC,'Visible','on');

set (handles.TOROOPTS,'Visible','on');
set (handles.TMITTOL,'Visible','on');
set (handles.TMITTOLEGU,'Visible','on');
set (handles.TMITTOLDESC,'Visible','on');

set (handles.TCAVMEASOPTS,'Visible','on');
set (handles.FPHASE,'Visible','on');
set (handles.FPHASEEGU,'Visible','on');
set (handles.FPHASEDESC1,'Visible','on');
set (handles.FPHASEDESC2,'Visible','on');
set (handles.TPHASE,'Visible','on');
set (handles.TPHASEEGU,'Visible','on');
set (handles.TPHASEDESC1,'Visible','on');
set (handles.TPHASEDESC2,'Visible','on');

set (handles.TCAVCALOPTS,'Visible','on');
set (handles.STCAVPDES,'Visible','on');
set (handles.STCAVPDESEGU,'Visible','on');
set (handles.STCAVPDESDESC,'Visible','on');
set (handles.STARTING,'Visible','on');
set (handles.ETCAVPDES,'Visible','on');
set (handles.ETCAVPDESEGU,'Visible','on');
set (handles.ETCAVPDESDESC,'Visible','on');
set (handles.ENDING,'Visible','on');
set (handles.TCAVCN,'Visible','on');
set (handles.TCAVCNDESC,'Visible','on');
set (handles.TPBZ,'Visible','on');
set (handles.TPBZEGU,'Visible','on');
set (handles.TPBZDESC,'Visible','on');
set (handles.TPST,'Visible','on');
set (handles.TPSTEGU,'Visible','on');
set (handles.TPSTDESC,'Visible','on');

set (handles.CFOPANEL,'Visible','on');
set (handles.CFOApply,'Visible','on');
set (handles.bpmMeasConst,'Visible','on');
set (handles.bpmMeasConstEGU,'Visible','on');
set (handles.bpmMeasConstDESC,'Visible','on');
set (handles.bpmMeasTCAVAACT,'Visible','on');
set (handles.bpmMeasTCAVAACTEGU,'Visible','on');
set (handles.bpmMeasTCAVAACTDESC,'Visible','on');
set (handles.bpmMeasConstTs,'Visible','on');
set (handles.bpmG,'Visible','on');
set (handles.bpmGDESC,'Visible','on');
set (handles.bpmref,'Visible','on');
set (handles.bpmrefEGU,'Visible','on');
set (handles.bpmrefDESC,'Visible','on');
set (handles.bpmtol,'Visible','on');
set (handles.bpmtolEGU,'Visible','on');
set (handles.bpmtolDESC,'Visible','on');
set (handles.CFOMAXPULSES,'Visible','on');
set (handles.CFOMAXPULSESDESC,'Visible','on');
