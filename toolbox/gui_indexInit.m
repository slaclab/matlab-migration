function handles = gui_indexInit(hObject, handles, titleStr)
%GUI_INDEXINIT
%  GUI_INDEXINIT(HOBJECT, HANDLES) initializes GUI to enable multiple
%  facilies support.  It queries getSystem to get faciliy information and
%  selects availiable regions.  It adds an index button object to select the
%  facility (if getSystem returns empty) and adds a GUI title object.

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA

% Output arguments:
%    HANDLES: Structure as returned from GUIDATA

% Compatibility: Version 7 and higher
% Called functions: getSystem, gui_radioBtnInit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments.
if nargin < 3, titleStr='';end

% Get facility from host.
[handles.system,handles.accelerator]=getSystem; % Save present state
[d,accel]=getSystem(''); % Check for test env
getSystem(handles.accelerator); % Restore present state

% Reduce index list to available facility.
indexList2=handles.indexList;
indexId2=ismember(handles.indexList(:,1),accel); % List of available facilities
indexId=ismember(handles.indexList(:,1),handles.accelerator); % List of displayed facilities
if ~any(indexId), indexId(:)=true;indexId2(:)=true;end
if ~any(indexId & indexId2), indexId2=indexId;end
if ~isempty(accel)
    handles.indexList(~indexId,:)=[];indexId(~indexId)=[];
    indexList2(~indexId2,:)=[];
end

% Select present facility or first in list.
handles.index=handles.indexList{find(indexId,1),1};
%handles.index=handles.indexList{min(max(1,find([true;indexId],1,'last')-1),end),1};

% Collect list of all sector names.
handles.sector.nameList=[indexList2{:,2}];

% Add index button.
if ~isfield(handles,'index_btn')
    pos=get(hObject,'Position');
    handles.index_btn=uicontrol(hObject,'Style','pushbutton','Units','characters', ...
       'FontSize',8,'Position',[5.8 pos(4)-(33-2)*23/299 12 1.7692307692307696], ...
       'HorizontalAlignment','center');
end

% Add index Title.
if ~isfield(handles,'title_txt')
    pos=get(hObject,'Position');
    set(hObject,'Position',pos+[0 -1.75 0 1.75]);
    handles.title_txt=uicontrol(hObject,'Style','text','Units','characters','String',titleStr, ...
       'FontSize',18,'Position',[pos(3)/2-40 pos(4)-.5 80 2.25],'HorizontalAlignment','center', ...
       'ForegroundColor','b');
end

% Setup screen position.
%units=get(0,'Units');set(0,'Units','Characters');
%mPos=get(0,'MonitorPositions');
fPos=get(handles.output,'Position');set(handles.output,'Position',fPos.*[0 1 1 1]+[20 0 0 0]);
%set(0,'Units',units');

% Initialize index buttons.
handles=gui_radioBtnInit(hObject,handles,'index',handles.indexList(:,1),'_btn');
