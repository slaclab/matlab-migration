function handles = gui_checkBoxControl(hObject, handles, name, val, vis)
%GUI_CHECKBOXCONTROL
%  HANDLES = GUI_CHECKBOXCONTROL(HOBJECT, HANDLES, NAME, VAL, VIS) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: Reference name for base name of buttons
%    VAL: New value
%    VIS: Visibility flag for buttons

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(TAG).

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if isempty(val)
    val=handles.(name);
end
handles.(name)=val;

if nargin < 5, vis=true;end
state={'off' 'on'};

set(handles.([name '_box']),'Value',val,'Visible',state{logical(vis)+1});

guidata(hObject,handles);
