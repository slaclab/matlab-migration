function handles = gui_popupMenuControl(hObject, handles, name, tag, tagList, labelList, vis)
%GUI_POPUPMENUCONTROL
%  HANDLES = GUI_POPUPMENUCONTROL(HOBJECT, HANDLES, NAME, TAG, TAGLIST, LABELLIST, VIS) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: Reference name for base name of buttons
%    TAG: New value (either double for index or string)
%    TAGLIST: List of values, defaults to String property of uicontrol
%    VIS: Visibility flag for buttons

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(TAG).

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

nameHandle=[name '_pmu'];
if ~ismember(nameHandle,fieldnames(handles)), nameHandle=upper(name);end

if isempty(tag)
    tag=handles.(name);
end
if isempty(tagList), tagList=get(handles.(nameHandle),'String');end
if ~ischar(tag), tag=tagList{tag};end
handles.(name)=tag;

val=[find(strcmp(tagList,tag)) 1]; % If TAG not in list default to 1

if nargin < 7, vis=true;end
state={'off' 'on'};

set(handles.(nameHandle),'Value',val(1),'Visible',state{logical(vis)+1});

if nargin < 6, labelList=[];end
if ~isempty(labelList)
    set(handles.(nameHandle),'String',labelList);
end

guidata(hObject,handles);
