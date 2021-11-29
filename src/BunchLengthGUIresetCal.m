% Transition from Bunch Length Calibration GUI
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIresetCal (handles)

set (handles.CalGUI,'Enable','on');

set (handles.Calibrate,'Visible','off');
set (handles.cCancel,'Visible','off');
set (handles.cImageAnalysis,'Visible','off');

set (handles.Save,'Visible','off');
set (handles.SaveToFile,'Visible','off');
set (handles.SmallSaveToFile,'Visible','off');

set (handles.ScreenIn,'Visible','off');
set (handles.ScreenOut,'Visible','off');
set (handles.ScreenDesc,'Visible','off');

set (handles.Rate,'Visible','off');
set (handles.RateEgu,'Visible','off');
set (handles.RateDesc,'Visible','off');

set (handles.TCAVPDES,'visible','off');
set (handles.TCAVPDESDESC,'visible','off');
set (handles.TCAVPDESEGU,'visible','off');
set (handles.TCAVPACT,'visible','off');
set (handles.TCAVPACTDESC,'visible','off');
set (handles.TCAVPACTEGU,'visible','off');
set (handles.TCAVAACT,'visible','off');
set (handles.TCAVAACTDESC,'visible','off');
set (handles.TCAVAACTEGU,'visible','off');
set (handles.TCAVACTIVE,'visible','off');

set (handles.PSCREEN,'Visible','off');
set (handles.screenCalConst,'Visible','off');
set (handles.screenCalConstSign,'Visible','off');
set (handles.screenCalConstSTD,'Visible','off');
set (handles.screenCalConstEGU,'Visible','off');
set (handles.screenCalConstDESC,'Visible','off');
set (handles.screenTCAVAACT,'Visible','off');
set (handles.screenTCAVAACTEGU,'Visible','off');
set (handles.screenTCAVAACTDESC,'Visible','off');
set (handles.selScreenCalConstAlg,'Visible','off');
set (handles.screenCalConstTs,'Visible','off');
set (handles.CALIMGALG,'Visible','off');
set (handles.CALIMGALGSEL,'Visible','off');

set (handles.BSCREEN,'Visible','off');
set (handles.bpmCalConst,'Visible','off');
set (handles.bpmCalConstEGU,'Visible','off');
set (handles.bpmCalConstDESC,'Visible','off');
set (handles.bpmTCAVAACT,'Visible','off');
set (handles.bpmTCAVAACTEGU,'Visible','off');
set (handles.bpmTCAVAACTDESC,'Visible','off');
set (handles.bpmCalConstTs,'Visible','off');

set (handles.TCAVON,'Visible','off');
set (handles.TCAVOFF,'Visible','off');

plot_handles = get(handles.cplot,'Children');
for i = 1:size(plot_handles,1)
    set (plot_handles(i),'Visible','off');
end
