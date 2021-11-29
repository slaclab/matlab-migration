function [handles, cancd, val] = gui_dataRemove(hObject, handles, val)

cancd=0;
if ~isfield(handles,'data'), return, end

if any(handles.data.status) && ~handles.process.saved
    btn=questdlg('Measured Data not saved!','Unsaved Data', ...
        'Discard','Save','Cancel','Save');
    if strcmp(btn,'Save')
        feval(get(handles.output,'tag'),'dataSave',hObject,handles,0);
    end
    if strcmp(btn,'Cancel')
        cancd=1;
        if nargout > 2, val=[];end
        return
    end
end
handles=rmfield(handles,'data');
