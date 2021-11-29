function handles = gui_printLogInit(hObject, handles)
%GUI_PRINTLOGINIT
%  HANDLES = GUI_PRINTLOGINIT(HOBJECT, HANDLES) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA

% Output arguments:
%    HANDLES: Updated HANDLES structure

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Determine callback function, set to GUIDE generated name as default.
h=handles.printLog_btn;
[pathName,fileName]=fileparts(get(get(h,'Parent'),'FileName'));
callback=[fileName '(''dataExport_btn_Callback'',gcbo,[],guidata(gcbo),2)'];

% Split existing button into two.
set(h,'Position',get(h,'Position').*[1 1 .5 1],'String','>LOG');
h2=copyobj(h,get(h,'Parent'));
pos=get(h2,'Position');
set(h2,'Position',pos+[pos(3) 0 0 0],'Callback',callback,'String','>MCC');

handles.printLogAlt_btn=h2;
guidata(hObject,handles);
