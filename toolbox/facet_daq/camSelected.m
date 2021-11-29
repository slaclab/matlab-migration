function camSel = camSelected(handles)
	camind = get(handles.Cameralist,'Value')';
	camlist = handles.camlist;
	% display(camind)
	camSel = [camlist.AD_CAMS.NAMES(camind),camlist.AD_CAMS.PVS(camind)];
end
