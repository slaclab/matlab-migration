function imgProcessing_panel_setCallbacks(handles, mainCallback)
ipHandles  = {
    handles.algPopupmenu,...
    handles.applyButton,...
    handles.autoApplyCheckbox,...
    handles.autoBppCheckbox,...
    handles.autoCropCheckbox,...
    handles.beamSizeUnitsPopupmenu,...
    handles.bppSlider,...
    handles.colormapFcnPopupmenu,...
    handles.currentCentroidCheckbox,...
    handles.customCropCheckbox,...
    handles.floorFilterCheckbox,...
    handles.medianFilterCheckbox,...
    handles.nrSlicesEdit,...
    handles.slicePopupmenu,...
    handles.sliceXCheckbox,...
    handles.sliceYCheckbox,...
    handles.subtractAcquiredBgCheckbox,...
    handles.subtractCalculatedBgCheckbox...
    };
nrIpHandles = size(ipHandles, 2);
for i=1:nrIpHandles
    set(ipHandles{i}, 'callback', mainCallback);
end