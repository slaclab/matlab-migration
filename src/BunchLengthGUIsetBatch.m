% Transition to Bunch Length Batch Mode Setup GUI
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIsetBatch (handles)

BunchLengthGUIresetMeas (handles);
BunchLengthGUIresetCal (handles);
BunchLengthGUIresetOpts (handles);

set (handles.BatchGUI,'Enable','off');
BunchLengthGUIWindowName (handles.BunchLengthGUI, 'Batch Mode Setup');

