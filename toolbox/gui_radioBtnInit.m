function handles = gui_radioBtnInit(hObject, handles, name, tagList, ext, lab)
%GUI_RADIOBTNINIT
%  HANDLES = GUI_RADIOBTNINIT(HOBJECT, HANDLES, NAME, TAGLIST, EXT) sets up
%  radio buttons or push buttons with tags derived from NAME and TAGLIST.
%  It is assumed that at least the first control object already exists. EXT
%  encodes the control style which defaults to '_rbn' for radio button.
%  The callback function is set differently depending if the first object
%  was created by GUIDE or by the application.

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: Reference name for base name of buttons
%    TAGLIST: Desired button names
%    EXT: suffix for TAG property of control, default '_rbn'

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(TAG).

% Compatibility: Version 2007b, 2012a
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 6, lab='';end
if nargin < 5, ext='_rbn';end

% Find existing button names.
fn=fieldnames(handles);
fieldList=regexp(sprintf('%s ',fn{:}),[name '\w*' ext],'match');
hList=zeros(numel(fieldList),1);
for j=1:numel(fieldList), hList(j)=handles.(fieldList{j});end
handles=rmfield(handles,fieldList);

% Find leftmost button and remove all others.
pos=get(hList,'Position');if iscell(pos), pos=cell2mat(pos);end
[d,id]=min(pos(:,1));h=hList(id);delete(setdiff(hList,h));
set(h,'Visible','off');

% Determine callback function, set to GUIDE generated name as default.
[pathName,fileName]=fileparts(get(get(h,'Parent'),'FileName'));
callbackBase=[fileName '(''' name ext '_Callback'',gcbo,[],guidata(gcbo),'];

% Set callback to standalone function if button created in program.
if isempty(strfind(char(get(h,'Callback')),[fileName '(']))
    callbackBase=['gui_' name 'Control(gcbo,guidata(gcbo),'];
end

% Create new buttons and line them up.
for j=1:numel(tagList)
    if j > 1, h=copyobj(h,get(h,'Parent'));end
    str=tagList{j};if ~isempty(lab), str=lab{j};end
    callback=[callbackBase '''' tagList{j} ''')'];
    set(h,'Position',pos(id,:)+[pos(id,3)*(j-1) 0 0 0],'String',str, ...
        'Callback',callback,'Visible','on');
    newTag=[name tagList{j} ext];
    handles.(newTag)=h;
end
if ~numel(tagList), handles.([name ext])=h;end
guidata(hObject,handles);
