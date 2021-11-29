function varargout = gui_indexControl(hObject, handles, name)
%GUI_INDEXCONTROL
%  HANDLES = GUI_INDEXCONTROL(HOBJECT, HANDLES, NAME) callback function for index
%  button to setup application for facility specific settings.  It
%  highlights the selected index button, sets internal accelerator and
%  system variables, generates PV names for beam rate and beam on/off, adds
%  or changes the title text to the selected facility name, sets the figure
%  background and button colors to the facility specific color scheme,
%  initializes the sector buttons (if present) to available sectors for
%  actice facility, and calls the GUIs sectorControl callback function. It
%  also sets the facility to NAME if run in dev env.

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME:    String of selected facility name or empty

% Output arguments:
%    HANDLES: Structure as returned from GUIDATA

% Compatibility: Version 7 and higher
% Called functions: getSystem, gui_radioBtnInit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set index buttons.
[handles,cancd,name]=gui_dataRemove(hObject,handles,name);
set(handles.(['index' handles.index '_btn']),'BackgroundColor',get(handles.output,'Color'));
handles=gui_radioBtnControl(hObject,handles,'index',name, ...
    size(handles.indexList,1) > 1,'_btn');
if cancd, return, end

% Set system & accelerator for simul case.
if size(handles.indexList,1) > 1
    [handles.system,handles.accelerator]=getSystem(handles.index);
end

% Generate global PV names.
accel=handles.accelerator;if strcmp(accel,'FACET'), accel='';end
handles.beamRatePV=['EVNT:' handles.system ':1:' accel 'BEAMRATE'];
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
% nate 6/25/14 hack to adapt to FACET e+ or e-
if strcmp(handles.accelerator, 'FACET') 
    handles.beamRatePV='EVNT:SYS1:1:INJECTRATE'; % New PV for beam rate
    %rate = lcaGetSmart({handles.beamRatePV; 'EVNT:SYS1:1:POSITRONRATE'});
    % Old nate code to compare to positron rate
    %if rate(2)>rate(1)
    %    handles.beamRatePV = 'EVNT:SYS1:1:POSITRONRATE';
    %end
end

% Set title text.
str=get(handles.title_txt,'String');
patt=sprintf('\\<%s\\>|',handles.indexList{:,1});
str=regexprep(str,patt,handles.index);
if isempty(regexp(str,patt,'once')), str=[handles.index ' ' str];end
set(handles.title_txt,'String',str);

% Set figure background and button colors to index specific color.
set(handles.(['index' handles.index '_btn']),'BackgroundColor','b');
col=gui_indexColor(handles.index);
h=findobj(handles.output,'-property','BackgroundColor');
cal0=get(handles.output,'Color');
hc=get(h,'BackgroundColor');
h(cellfun(@ischar,hc))=[];hc(cellfun(@ischar,hc))=[]; % Remove color 'none' objects
set(handles.output,'Color',col);
set(h(all(cell2mat(hc)==repmat(cal0,numel(hc),1),2)),'BackgroundColor',col);

% Initialize sector buttons.
nameList=handles.indexList{strcmp(handles.index,handles.indexList(:,1)),2};
%if isfield(handles,'sectorSel_btn')
if ~all(cellfun('isempty',regexp(fieldnames(handles),'sectorSel\w*_btn')))
    handles=gui_radioBtnInit(hObject,handles,'sectorSel',nameList,'_btn');
end
if ~numel(nameList), return, end

% Call sector setup.
[pathName,fileName]=fileparts(get(handles.output,'FileName'));
if isfield(handles,'sectorSel') && ismember(handles.sectorSel,nameList), nameList{1}=[];end
handles=feval(fileName,'sectorControl',hObject,handles,nameList{1});

if nargout, varargout{1}=handles;end
