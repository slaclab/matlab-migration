% Transition to Bunch Length Calibration GUI
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIsetCal (handles)

global gBunchLength;

BunchLengthGUIresetMeas (handles);
BunchLengthGUIresetOpts (handles);
BunchLengthGUIresetBatch (handles);

set (handles.CalGUI,'Enable','off');
BunchLengthGUIWindowName (handles.BunchLengthGUI, 'Calibration');

set (handles.Calibrate,'Visible','on');
set (handles.cCancel,'Visible','on');
set (handles.cImageAnalysis,'Visible','on');

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

set (handles.PSCREEN,'Visible','on');
set (handles.screenCalConst,'Visible','on');
set (handles.screenCalConstSign,'Visible','on');
set (handles.screenCalConstSTD,'Visible','on');
set (handles.screenCalConstEGU,'Visible','on');
set (handles.screenCalConstDESC,'Visible','on');
set (handles.screenTCAVAACT,'Visible','on');
set (handles.screenTCAVAACTEGU,'Visible','on');
set (handles.screenTCAVAACTDESC,'Visible','on');
set (handles.selScreenCalConstAlg,'Visible','on');
set (handles.screenCalConstTs,'Visible','on');
set (handles.CALIMGALG,'Visible','on');

set (handles.BSCREEN,'Visible','on');
set (handles.bpmCalConst,'Visible','on');
set (handles.bpmCalConstEGU,'Visible','on');
set (handles.bpmCalConstDESC,'Visible','on');
set (handles.bpmTCAVAACT,'Visible','on');
set (handles.bpmTCAVAACTEGU,'Visible','on');
set (handles.bpmTCAVAACTDESC,'Visible','on');
set (handles.bpmCalConstTs,'Visible','on');

set (handles.TCAVON,'Visible','on');
set (handles.TCAVOFF,'Visible','on');

% set the plot button names
BunchLengthGUIsetCalBtnNames;