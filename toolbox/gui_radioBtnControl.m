function handles = gui_radioBtnControl(hObject, handles, name, tag, vis, ext)
%GUI_RADIOBTNCONTROL
%  HANDLES = GUI_RADIOBTNCONTROL(HOBJECT, HANDLES, NAME, TAG, VIS) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: Reference name for base name of buttons
%    TAG: Selected button
%    VIS: Visibility flag for buttons
%    EXT: suffix for TAG property of control, default '_rbn'

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(TAG).

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if isempty(tag)
    tag=handles.(name);
end
handles.(name)=tag;

if nargin < 6, ext='_rbn';end

if nargin < 5, vis=true;end
state={'off' 'on'};

fn=fieldnames(handles);
fieldList=regexp(sprintf('%s ',fn{:}),[name '\w+' ext],'match');
tagList=strrep(strrep(fieldList,name,''),ext,'');

for j=[fieldList;tagList]
    val=strcmpi(j{2},tag);
    set(handles.(j{1}),'Value',val,'Visible',state{logical(vis)+1});
end

guidata(hObject,handles);
