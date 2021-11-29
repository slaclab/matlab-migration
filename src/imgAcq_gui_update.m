% property is an optional arg, if missing => updates all views
function imgAcq_gui_update(handles, imgAcqData, property)

isArgSet = nargin > 2;
ipOutput = imgAcqData.liveImg.ipOutput;
ipParam = imgAcqData.liveImg.ipParam;
cameraIndex = imgAcqData.current.cameraIndex;
    
if ~isArgSet || strcmpi(property, 'camera')
    nrCameras = size(imgAcqData.camera, 2);
    cameraLabels = cell(1, nrCameras);
    for i=1:nrCameras
        cameraLabels{i} = imgAcqData.camera{i}.label;
    end
    set(handles.cameraPopupmenu, 'string', cameraLabels);
end
if ~isArgSet || strcmpi(property, 'cameraIndex')
    if imgAcqData.camera{cameraIndex}.features.screen;
        set(handles.inButton, 'visible', 'on');
        set(handles.outButton, 'visible', 'on');
        set(handles.screenText, 'visible', 'on');
        set(handles.screenStatusText, 'visible', 'on');
    else
        set(handles.inButton, 'visible', 'off');
        set(handles.outButton, 'visible', 'off');
        set(handles.screenText, 'visible', 'off');
        set(handles.screenStatusText, 'visible', 'off');
    end
   
    set(handles.cameraPopupmenu, 'value', cameraIndex);
end
if ~isArgSet || strcmpi(property, 'centroid')
    centroid = ipParam.annotation.centroid;
       
    set(handles.goldenOrbitCentroidCheckbox, 'foregroundColor', centroid.goldenOrbit.color);
    set(handles.goldenOrbitCentroidCheckbox, 'value', centroid.goldenOrbit.flag);
    
    set(handles.laserBeamCentroidCheckbox, 'foregroundColor', centroid.laserBeam.color);
    set(handles.laserBeamCentroidCheckbox, 'value', centroid.laserBeam.flag);
end
if ~isArgSet || strcmpi(property, 'dataset')
    nrValidDatasets = imgUtil_getNrValidDatasets();
    if nrValidDatasets == 1
        dsStr = 'dataset';
    else
        dsStr = 'datasets';
    end
    newStatus = sprintf('%d %s', nrValidDatasets, dsStr);
    set(handles.datasetsText, 'string', newStatus);
    set(handles.dsLabelEdit, 'string',  imgAcqData.dsLabel);
end
if isArgSet && strcmpi(property, 'disableMeasure')
    set(handles.measureButton, 'enable', 'off');
end
if ~isArgSet || strcmpi(property, 'dock')
    dockStateChanged();
    updateLiveImg();
end
if ~isArgSet || strcmpi(property, 'dsLabel')
    set(handles.dsLabelEdit, 'string', imgAcqData.dsLabel);
end
if isArgSet && strcmpi(property, 'enableMeasure')
    set(handles.measureButton, 'enable', 'on');
end
if ~isArgSet || strcmpi(property, 'liveImg')
    updateLiveImg();
    updateFitResultsText();
    try
        tsAsString = imgUtil_matlabTime2String(lca2matlabTime(imgAcqData.liveImg.raw.timestamp));
    catch
        tsAsString = 'N/A';
    end
    set(handles.liveImgTsText, 'string', tsAsString);
end
if ~isArgSet || strcmpi(property, 'nrBgImgs')
    set(handles.nrBgImgsEdit, 'string', imgAcqData.nrBgImgs);
end
if ~isArgSet || strcmpi(property, 'nrBeamImgs')
    set(handles.nrBeamImgsEdit, 'string', imgAcqData.nrBeamImgs);
end
if ~isArgSet || strcmpi(property, 'pos')
    pos = imgAcqData.current.screenPos;
    sText = handles.screenStatusText;
    set(sText, 'string', pos);
    if strcmpi(pos, 'IN')
        set(sText, 'foregroundColor', [1 0 0]); %red
    else
        set(sText, 'foregroundColor', [0 0 0]); %black
    end
end
if ~isArgSet || strcmpi(property, 'processLiveImg')
    set(handles.processLiveImgCheckbox, 'value', imgAcqData.processLiveImg);
end
if ~isArgSet || strcmpi(property, 'savedBgImgTs')
    str = '';
    lcaTs = imgAcqData.rawSavedBgImg.timestamp;
    if lcaTs > 0
        try
            tsAsStr = imgUtil_matlabTime2String(lca2matlabTime(lcaTs));
            str = sprintf('Background image from %s', tsAsStr);
        catch
            %do nothing
        end
    end
    set(handles.savedBgImgTsText, 'string', str);
end
if ~isArgSet || strcmpi(property, 'showLiveImg')
    updateLiveImgPanel();
end

%sub panels
ipParam.algNames = imgUtil_getAlgNames({ipOutput});
if isArgSet
    imgProcessing_panel_update(handles, ipParam, property);
else
    imgProcessing_panel_update(handles, ipParam);
    progress_panel_update(handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateLiveImgPanel()
        isLiveImgPanelVisible = strcmpi(get(handles.liveImgPanel, 'visible'), 'on');
        if isLiveImgPanelVisible && imgAcqData.showLiveImg
            %no changes
            return;
        end
        if ~isLiveImgPanelVisible && ~imgAcqData.showLiveImg
            %no changes
            return;
        end
        fig = imgUtil_getParentFig(handles.showLiveImgCheckbox);
        %[left, bottom, width, height]
        cpPos = get(handles.controlPanel, 'position');
        winPos = get(fig, 'position');
        LIVE_IMG_PANEL_HEIGHT = 640; %see imgAcq_gui.m
        if imgAcqData.showLiveImg       
            set(handles.liveImgPanel, 'visible', 'on');
            cpPos(2) = LIVE_IMG_PANEL_HEIGHT; %move up
            winPos(2) = winPos(2) - LIVE_IMG_PANEL_HEIGHT; %move down
            winPos(4) = winPos(4) + LIVE_IMG_PANEL_HEIGHT; %change height
        else
            set(handles.liveImgPanel, 'visible', 'off');
            winPos(2) = winPos(2) + LIVE_IMG_PANEL_HEIGHT;%move up
            winPos(4) = cpPos(4);%change height
            cpPos(2) = 0;%move down
        end
        set(handles.controlPanel, 'position', cpPos);
        set(fig, 'position', winPos);
        set(handles.showLiveImgCheckbox, 'value', imgAcqData.showLiveImg);  
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateLiveImg()
        %TODO change to use the same API as imgBrowser and imgAnalysis apps
        if isempty(imgAcqData.detachedLiveImgFig)
            h = handles;
        else
            fig = imgAcqData.detachedLiveImgFig;
            h = guihandles(fig);
        end
        if ~isempty(ipOutput)
            imgProcessing_showProcessedImg(h.imgAxes, ipParam, ipOutput, imgAcqData.camera{cameraIndex});
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dockStateChanged()
        fig = imgAcqData.detachedLiveImgFig;
        if isempty(fig)
            %docked
            set(handles.undockButton, 'enable', 'on');
            set(handles.imgAxes, 'visible', 'on');
        else
            %undocked
            set(handles.undockButton, 'enable', 'off');
            cla(handles.imgAxes);
            set(handles.imgAxes, 'visible', 'off');
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%
    function updateFitResultsText()
        imgUtil_showBeamDataOnText(...
            imgAcqData.camera{cameraIndex}, ipParam, ipOutput, handles.fitResultsText);
    end
end
