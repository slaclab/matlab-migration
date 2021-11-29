function handles=enableDAQ(handles)
	if get(handles.Daqscan,'Value')
		enable='on';
		set(handles.Scanvaluesstr,'Enable','inactive');
	else
		enable='off';
		set(handles.Scanvaluesstr,'Enable','off');
	end
	set(handles.Scanfunction,'Enable',enable);
	set(handles.Scanstartval,'Enable',enable);
	set(handles.Scanstarttext,'Enable',enable);
	set(handles.Scanendval,'Enable',enable);
	set(handles.Scanendtext,'Enable',enable);
	set(handles.Scanstepsval,'Enable',enable);
	set(handles.Scaninttext,'Enable',enable);
	set(handles.Scanvaluestext,'Enable',enable);
	set(handles.Scantypetext,'Enable',enable);
	
	set(handles.Scan2d,'Enable',enable);
	handles=enableDAQ_2D(handles);
	
	if get(handles.Scanfunction,'Value')~=4
		set(handles.Setfunctionval,'Enable',enable);
		set(handles.Setfunction,'Enable',enable);
	else
		set(handles.Setfunctionval,'Enable','off');
		set(handles.Setfunction,'Enable','off');
	end
	
end
