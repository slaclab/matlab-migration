function imgAnalysis_gui_update(handles, imgAnalysisData, property)

global gIMG_MAN_DATA;
isArgSet = nargin > 2;

dsIndex = imgAnalysisData.dsIndex;
ds = gIMG_MAN_DATA.dataset{dsIndex};
imgIndex = imgAnalysisData.imgIndex;
rawImg = ds.rawImg{imgIndex};
ipOutput = imgAnalysisData.ipOutput; 
ipParam = imgAnalysisData.ipParam;
algIndex = ipParam.algIndex;

ipParam.algNames = imgUtil_getAlgNames({ipOutput});
if ~isArgSet
    imgProcessing_panel_update(handles, ipParam);
    progress_panel_update(handles);
else
    imgProcessing_panel_update(handles, ipParam, property);
end

if ~isArgSet
    %do all
    updateBrowseButtons();
    updateImgAxes();
    updateFitAxes();
    updateFitResultsText();
    updateInfoText();
    return;
end

if strcmpi(property, 'algIndex')
    if ipParam.annotation.centroid.current.flag
        updateImgAxes();
    end
    updateFitAxes();
    updateFitResultsText();
end

if strcmpi(property, 'beamSizeUnits')
    updateFitAxes();
    updateFitResultsText();
end


if strcmpi(property, 'centroid')
    updateImgAxes();
end

if strcmpi(property, 'imgIndex')
    updateBrowseButtons();
    updateImgAxes();
    updateFitAxes();
    updateFitResultsText();
    updateInfoText();
    imgProcessing_panel_update(handles, ipParam);
end

%%%%%%%%%%%%%%%%%%%%%%%
    function updateBrowseButtons()
        nrBgImgs = ds.nrBgImgs;
        nrImgs = nrBgImgs + ds.nrBeamImgs;
 
        if imgIndex == nrImgs
            %last (beam) image
            set(handles.nextButton, 'enable', 'off');
        else
            set(handles.nextButton, 'enable', 'on')
        end
        if imgAnalysisData.imgIndex == nrBgImgs + 1
            %first beam image
            set(handles.previousButton, 'enable', 'off');
        else
            set(handles.previousButton, 'enable', 'on')
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%
    function updateInfoText()
        tsAsStr = imgUtil_matlabTime2String(lca2matlabTime(ds.rawImg{imgIndex}.timestamp));
        str = sprintf('Image #%d (%s), %s', imgIndex, ds.label, tsAsStr);
        set(handles.infoText, 'string', str);
        enable = imgUtil_isImgOK(rawImg, ipOutput);
        if enable
            set(handles.infoText, 'enable', 'on');
        else
            set(handles.infoText, 'enable', 'off');
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgAxes()  
        if isempty(ipOutput)
            return;
        end
        imgProcessing_showProcessedImg(handles.imgAxes, ipParam, ipOutput);
    end

%%%%%%%%%%%%%%%%%%%%%%%
    function updateFitAxes()
        imgUtil_clearFitAxes(handles.xPlaneAxes);
        imgUtil_clearFitAxes(handles.yPlaneAxes);
        
        if isempty(ipOutput)
            return;
        end
               
        if isempty(ipOutput.beamlist)
            return;
        end
        imgUtil_showPixelBeamDataOnAxes(...
            ipOutput.beamlist(algIndex).profx,...
            1,...
            handles.xPlaneAxes,...
            handles.imgAxes);    
        if strcmpi(ipParam.beamSizeUnits, 'um')
            imgProcessing_pixel2Micron(handles.xPlaneAxes, ds.camera, 1, 0);
            axLabel = get(handles.xPlaneAxes, 'xlabel');
            set(axLabel, 'string', ipParam.beamSizeUnits);
        end
        
        imgUtil_showPixelBeamDataOnAxes(...
            ipOutput.beamlist(algIndex).profy,...
            0,...
            handles.yPlaneAxes,...
            handles.imgAxes);
        if strcmpi(ipParam.beamSizeUnits, 'um')
            imgProcessing_pixel2Micron(handles.yPlaneAxes, ds.camera, 0, 1);
            axLabel = get(handles.yPlaneAxes, 'ylabel');
            set(axLabel, 'string', ipParam.beamSizeUnits);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%
    function updateFitResultsText()   
       imgUtil_showBeamDataOnText(...
            ds.camera, ipParam, ipOutput, handles.fitResultsText);
    end
end