function Setscanval(handles,dimension)
	if dimension == 1
		dimstr = '';
	elseif dimension == 2
		dimstr = '2';
	end

	% Validate
	scanstartval = validatescanvals(handles.(['Scanstartval' dimstr]),'Scan Start',handles,dimstr);
	scanendval   = validatescanvals(handles.(['Scanendval' dimstr]),'Scan End',handles,dimstr);
	scanstepsval = validatestepval(handles.(['Scanstepsval' dimstr]),'Scan Number of Steps',handles,dimstr);
	
	strlist=[scanstartval:(scanendval-scanstartval)/(scanstepsval-1):scanendval];
	strlist=[num2str(strlist(1:end-1),'%G, ') ' ' num2str(strlist(end))];
	
	set(handles.(['Scanvaluesstr' dimstr]),'String',strlist);
end
 
function out=validatescanvals(hObject,str,handles,dimstr)
	out=str2double(get(hObject,'String'));
	if ~(~isnan(out) && isnumeric(out) && (size(out,2)==1) && (size(out,2)==1) )
		set(handles.(['Scanvaluesstr' dimstr]),'String','');
		error([str ' needs to be a number.']);
	end
end

function out=validatestepval(hObject,str,handles,dimstr)
	out=str2double(get(hObject,'String'));
	if ~(~isnan(out) && isnumeric(out) && (size(out,2)==1) && (size(out,2)==1) )
		set(handles.(['Scanvaluesstr' dimstr]),'String','');
		error([str ' needs to be an integer.']);
	else
		out=round(out);
		set(hObject,'String',num2str(out));
	end
end
