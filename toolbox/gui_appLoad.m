function handles = gui_appLoad(hObject, handles)
%GUI_APPLOAD
%  GUI_APPLOAD(HOBJECT, HANDLES) load parts of HANDLES structure specified
%  in field list HANDLES.CONFIGLIST using UTIL_CONFIGLOAD. The file name
%  used is based on the GUI figure FILENAME property.  If present, sector
%  specific fields are also loaded.

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA

% Output arguments:
%    HANDLES: Structure as returned from GUIDATA

% Compatibility: Version 7 and higher
% Called functions: util_configLoad

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments.
if nargin < 2, handles=guidata(hObject);end

% Load config from file.
[pathName,fileName]=fileparts(get(handles.output,'FileName'));
config=util_configLoad(fileName);

% Return if no config exists.
if isempty(config), return, end

% Copy sector data from config.
if isfield(handles,'sector') && isfield(handles.sector,'configList')
    for name=handles.sector.nameList
        if ~isfield(config,'sector') || ~isfield(config.sector,name{:}), continue, end
        sector=config.sector.(name{:});
        for tag=handles.sector.configList
            if ~isfield(sector,tag{:}), continue, end
            t=sector.(tag{:});
            if ischar(t)
                handles.sector.(name{:}).(tag{:})=t;
            else
                [h1,h2]=size(handles.sector.(name{:}).(tag{:}));
                t(h1+1:end,:)=[];t(:,h2+1:end)=[];[t1,t2]=size(t);
                handles.sector.(name{:}).(tag{:})(1:t1,1:t2)=t;
            end
        end
    end
end

% Copy common data from config into handles.
for tag=handles.configList
    if ~isfield(config,tag{:}), continue, end
    handles.(tag{:})=config.(tag{:});
end
guidata(hObject,handles);

% Setup application with new settings.
handles=feval(fileName,'appSetup',hObject,handles);
