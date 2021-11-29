function val = gui_modelSourceControl(hObject, handles, val, beamPath)

if isempty(val)
    if nargin < 4 | isempty(beamPath)
        [modelSource,modelOnline,~,~,beamPath]=model_init;
    else
        [modelSource,modelOnline]=model_init;
    end
    val=modelSource;
    if ~modelOnline, val=3;end
elseif nargin < 4 | isempty(beamPath)
    [~,~,~,~,beamPath]=model_init;
end

modelList={'SLC' 'EPICS' 'MATLAB'};
modelTags={'SCP' 'XAL' 'MAT'};

if ischar(val)
    val=find(strcmp(val,modelList));
end

model_init('source',modelList{val},'online',val < 3,'beamPath',beamPath);
vmax=get(handles.modelSource_btn,'Max');
set(handles.modelSource_btn,'String',[modelTags{val} ' Model'],'Value',min(val-1,vmax));
