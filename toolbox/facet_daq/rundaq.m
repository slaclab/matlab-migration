function par=rundaq(handles)
	global hl;
	hl=handles;
	
	par.increment_save_num = 1; % Don't change this!!!
	par.experiment         = get(handles.ExperimentStr,'String');

	camlist  = camSelected(handles);
	par.cams = camlist(:,2);

	par.save_E200      = get(handles.SaveE200,'Value');
	par.save_back      = get(handles.Savebackground,'Value');
	par.set_print2elog = get(handles.Print2elog,'Value');
	par.n_shot         = str2num(get(handles.Numberofshots,'String'));
	
	if get(handles.eventcode213,'Value') == 1
		par.event_code = 213;
	end
	if get(handles.eventcode233,'Value') == 1
		par.event_code = 233;
    end
    if get(handles.eventcode223,'Value') == 1
		par.event_code = 223;
    end
    if get(handles.eventcode225,'Value') == 1
		par.event_code = 225;
    end
    if get(handles.eventcode53,'Value') == 1
		par.event_code = 53;
    end
    if get(handles.eventcode229,'Value') == 1
		par.event_code = 229;
    end
    if get(handles.eventcode231,'Value') == 1
		par.event_code = 231;
    end
	
	par.comt_str=get(handles.Commentstring,'String');
	
	if get(handles.Daqscan,'Value')
		par.fcnHandle        = handles.func;
		par.Control_PV_start = str2num(get(handles.Scanstartval,'String'));
		par.Control_PV_end   = str2num(get(handles.Scanendval,'String'));;
		par.n_step           = str2num(get(handles.Scanstepsval,'String'));

		if get(handles.Scan2d,'Value')
			par.fcnHandle2        = handles.func2;
			par.Control_PV_start2 = str2num(get(handles.Scanstartval2,'String'));
			par.Control_PV_end2   = str2num(get(handles.Scanendval2,'String'));;
			par.n_step2           = str2num(get(handles.Scanstepsval2,'String'));
		end
	end

	
	% E200_DAQ_2013(par);
	FACET_DAQ_2014(par);

	display('Data Acquisition Successfully Taken via GUI');
end
