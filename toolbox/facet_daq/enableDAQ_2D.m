function handles=enableDAQ_2D(handles)
	if get(handles.Scan2d,'Value') && get(handles.Daqscan,'Value')
		enable='on';
		set(handles.Scanvaluesstr2,'Enable','inactive');
	else
		enable='off';
		set(handles.Scanvaluesstr2,'Enable','off');
	end
	set(handles.Scanfunction2,'Enable',enable);
	set(handles.Scanstartval2,'Enable',enable);
	set(handles.Scanstarttext2,'Enable',enable);
	set(handles.Scanendval2,'Enable',enable);
	set(handles.Scanendtext2,'Enable',enable);
	set(handles.Scanstepsval2,'Enable',enable);
	set(handles.Scaninttext2,'Enable',enable);
	set(handles.Scanvaluestext2,'Enable',enable);
	set(handles.Scantypetext2,'Enable',enable);
	
	if get(handles.Scanfunction2,'Value')~=4
		set(handles.Setfunctionval2,'Enable',enable);
		set(handles.Setfunction2,'Enable',enable);
	else
		set(handles.Setfunctionval2,'Enable','off');
		set(handles.Setfunction2,'Enable','off');
	end
end