function val = gui_beamPathControl(hObject, handles, val)

if isempty(val) 
    val = get(handles.beamPath_btn,'String'); 
end
beamPathTags={'CU_HXR' 'CU_SXR' };

if ischar(val)
    val=find(strcmp(val,beamPathTags));
end

vmax=get(handles.beamPath_btn,'Max');
set(handles.beamPath_btn,'String', beamPathTags{val},'Value',min(val-1,vmax));
