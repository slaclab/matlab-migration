function gui_acquireAbortAll()
%GUI_ACQUIREABORTALL
%  GUI_ACQUIREABORTALL() finds all figure objects and calls
%  ACQUIRESTATUSSET with 0 to abort acquisition in all applications.

% Features:

% Input arguments: none

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: gui_acquireStatusSet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Find all applications.
[hObject,handles]=util_appFind;

% Abort applications.
for j=1:length(hObject)
    gui_acquireStatusSet(hObject(j),handles{j},0);
end
