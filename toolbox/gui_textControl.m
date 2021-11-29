function handles = gui_textControl(hObject, handles, name, val, num, vis, def)
%GUI_TEXTCONTROL
%  HANDLES = GUI_TEXTCONTROL(HOBJECT, HANDLES, NAME, VAL, NUM, VIS) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: Reference name for base name of buttons
%    VAL: New string
%    NUM: Index for multiple controls
%    VIS: Visibility flag for buttons

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(TAG).

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 7, def='';end
if nargin < 5, num=1;end

% Find out if edit is multiline
multi=diff(cell2mat(get(handles.([name '_txt']),{'Min' 'Max'}))) > 1;
idx={};if multi, idx={':'};end

if isempty(val) && isnumeric(val)
    val=cellstr(handles.(name));
    if ~multi, val=val(min(num,end));end
end
val=cellstr(val);
if isempty(char(val)), val=cellstr(def);end
if multi && isempty(char(val)), val={};end

if multi
    handles.(name)=val;
elseif ischar(handles.(name))
    handles.(name)=char(val);
else
    handles.(name)(num)=val;
end

if nargin < 6, vis=true;end
state={'off' 'on'};

if isempty(char(val)), val={''};end
for j=1:length(num)
    str=num2str(num(j));if num(j) == 1, str='';end
    hEdit=handles.([name str '_txt']);
    hLabel=[];sLabel=[name str 'Label_txt'];
    if isfield(handles,sLabel), hLabel=handles.(sLabel);end
    set(hEdit,'String',val(idx{:},min(j,size(val,1+~isempty(idx)))));
    set([hEdit hLabel],'Visible',state{vis+1});
end

guidata(hObject,handles);
