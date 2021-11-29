% Transition from Bunch Length Measurement GUI
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIresetMeas (handles)

global gBunchLengthGUI;

set (handles.MeasGUI,'Enable','on');

set (handles.Measure,'Visible','off');
set (handles.mCancel,'Visible','off');
set (handles.mImageAnalysis,'Visible','off');

set (handles.Save,'Visible','off');
set (handles.RateEgu,'Visible','off');
set (handles.Restore,'Visible','off');

set (handles.Measure1,'Visible','off');
set (handles.Measure2,'Visible','off');
set (handles.Measure3,'Visible','off');

set (handles.ScreenIn,'Visible','off');
set (handles.ScreenOut,'Visible','off');
set (handles.ScreenDesc,'Visible','off');

set (handles.Rate,'Visible','off');
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

set (handles.MM,'Visible','off');
set (handles.MMSTD,'Visible','off');
set (handles.MMEGU,'Visible','off');
set (handles.MMDESC,'Visible','off');

set (handles.SIGT,'Visible','off');
set (handles.SIGTSTD,'Visible','off');
set (handles.SIGTEGU,'Visible','off');
set (handles.SIGTDESC,'Visible','off');
set (handles.R35,'Visible','off');
set (handles.R35STD,'Visible','off');
set (handles.R35DESC,'Visible','off');
set (handles.MEAS_TS,'Visible','off');
set (handles.NEL,'Visible','off');
set (handles.NELEGU,'Visible','off');
set (handles.NELDESC,'Visible','off');
set (handles.MEASIMGALG,'Visible','off');
set (handles.MEASIMGALGSEL,'Visible','off');
set (handles.EXPORT,'Visible','off');
set (handles.SaveToFile,'Visible','off');
set (handles.SmallSaveToFile,'Visible','off');

set (handles.table,'Visible','off');
set (handles.plot,'Visible','off');
set (handles.profile,'Visible','off');
set (handles.NextProfile,'Visible','off');
set (handles.PrevProfile,'Visible','off');
set (handles.iProfile,'Visible','off');

set (handles.TCAVON,'Visible','off');
set (handles.TCAVOFF,'Visible','off');

plot_handles = get(handles.plot,'Children');
for i = 1:size(plot_handles,1)
    set (plot_handles(i),'Visible','off');
end

plot_handles = get(handles.profile,'Children');
for i = 1:size(plot_handles,1)
    set (plot_handles(i),'Visible','off');
end

if isfield (gBunchLengthGUI,'meas')
    if isfield (gBunchLengthGUI.meas,'plotHandle')
        try
            set (gBunchLengthGUI.meas.plotHandle,'Visible','off');
        catch
        end
    end
end