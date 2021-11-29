function updateScanText(handles,units,dimstr)
    % display(units);
    set(handles.(['Scanstarttext' dimstr]),'String',['Scan Start [' units ']'])
    set(handles.(['Scanendtext' dimstr]),'String',['Scan End [' units ']'])
    set(handles.(['Scanvaluestext' dimstr]),'String',['Scan Values [' units ']:'])
end
