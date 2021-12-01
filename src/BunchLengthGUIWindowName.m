% Sets Bunch Length Measurement GUI Window Name
% Mike Zelazny - zelazny@stanford.edu
function BunchLengthGUIWindowName (handle, windowName)

global gBunchLength;

if nargin < 2
else
    gBunchLength.windowName = windowName;
end

if gBunchLength.gui
    set(handle,'Name',sprintf('%s %s Bunch Length %s: %s',...
        char(gBunchLength.mode{1}), gBunchLength.tcav.name, gBunchLength.windowName, gBunchLength.fileName));
end
