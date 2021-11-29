% Transition to Bunch Length Measurement GUI
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIsetMeas (handles)

global gBunchLength;

BunchLengthGUIresetCal (handles);
BunchLengthGUIresetOpts (handles);
BunchLengthGUIresetBatch (handles);

set (handles.MeasGUI,'Enable','off');
BunchLengthGUIWindowName (handles.BunchLengthGUI, 'Measurement');

set (handles.Measure,'Visible','on');
set (handles.mCancel,'Visible','on');
set (handles.mImageAnalysis,'Visible','on');

set (handles.Save,'Visible','on');
set (handles.Restore,'Visible','on');

set (handles.Measure1,'Visible','on');
set (handles.Measure2,'Visible','on');
set (handles.Measure3,'Visible','on');

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

set (handles.MM,'Visible','on');
set (handles.MMSTD,'Visible','on');
set (handles.MMEGU,'Visible','on');
set (handles.MMDESC,'Visible','on');

set (handles.SIGT,'Visible','on');
set (handles.SIGTSTD,'Visible','on');
set (handles.SIGTEGU,'Visible','on');
set (handles.SIGTDESC,'Visible','on');
set (handles.R35,'Visible','on');
set (handles.R35STD,'Visible','on');
set (handles.R35DESC,'Visible','on');
set (handles.MEAS_TS,'Visible','on');
set (handles.NEL,'Visible','on');
set (handles.NELEGU,'Visible','on');
set (handles.NELDESC,'Visible','on');
set (handles.MEASIMGALG,'Visible','on');

set (handles.plot,'Visible','on');

set (handles.TCAVON,'Visible','on');
set (handles.TCAVOFF,'Visible','on');
