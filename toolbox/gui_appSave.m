function gui_appSave(hObject, handles)
%GUI_APPSAVE
%  GUI_APPSAVE(HOBJECT, HANDLES) saves parts of HANDLES structure specified
%  in field list HANDLES.CONFIGLIST using UTIL_CONFIGSAVE. The generated
%  file name is based on the GUI figure FILENAME property.  If present,
%  sector specific fields are also saved.

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: util_configSave

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments.
if nargin < 2, handles=guidata(hObject);end

% Initialize CONFIG.
config=struct;

% Copy sector data to config.
if isfield(handles,'sector') && isfield(handles.sector,'configList')
    for name=handles.sector.nameList
        if ~isfield(handles.sector,name{:}), continue, end
        sector=handles.sector.(name{:});
        for tag=handles.sector.configList
            if ~isfield(sector,tag{:}), continue, end
            config.sector.(name{:}).(tag{:})=sector.(tag{:});
        end
    end
end

% Copy common data from handles to config.
for tag=handles.configList
    if ~isfield(handles,tag{:}), continue, end
    config.(tag{:})=handles.(tag{:});
end

% Save config to file.
[pathName,fileName]=fileparts(get(handles.output,'FileName'));
util_configSave(fileName,config);
