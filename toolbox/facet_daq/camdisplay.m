function camdisplay(handles)
	camSel = camSelected(handles);
	str = '';
	for i=1:size(camSel,1)
		if size(camSel{i,1},2) > 8
			tabstr = '\t';
		else
			tabstr = '\t\t';
		end
		str = [str camSel{i,1} tabstr camSel{i,2} '\n'];
	end
	str = sprintf(str);
	
	set(handles.camDisplay,'String',str);
end
