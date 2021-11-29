function imgAnalysisFig = imgAnalysis_main(imgAnalysisData, left, top)
%   the main function of the image analysis application

global gIMG_MAN_DATA;
imgAnalysisFig = [];

if imgUtil_getNrValidDatasets() < 1
    msgbox('No valid datasets available', 'Sorry...', 'warn');
    return;
end
if nargin < 1
    imgAnalysisData = [];
end
if nargin < 2
    left = [];
end
if nargin < 3
    top = [];
end
imgAnalysisData = imgUtil_copyStructVals(imgAnalysisData, imgData_construct_imgAnalysis());
if imgAnalysisData.ipParam.nrColors.auto
    setOptimalNrColors();
end
%create gui
imgAnalysisFig = imgAnalysis_gui();
%[left, bottom, width, height]
winPos = get(imgAnalysisFig, 'position');
if ~isempty(left)
    winPos(1) = left;
end
if ~isempty(top)
    winPos(2) = top - winPos(4);
end
set(imgAnalysisFig, 'position', winPos);

setappdata(imgAnalysisFig, 'notifyImgManDataChangedFcn', @fireImgManDataChanged);
handles = guihandles(imgAnalysisFig);

%before callbacks
doImgProcessing();
imgAnalysis_gui_update(handles, imgAnalysisData);
drawnow();

%push buttons
set(handles.adjustCropAreaButton, 'callback',{@adjustCropAreaButton_Callback});
set(handles.nextButton, 'callback', {@nextButton_Callback});
set(handles.previousButton, 'callback', {@previousButton_Callback});
set(handles.logBookButton, 'callback', {@logBookButton_Callback});

%img processing setup panel
imgProcessing_panel_setCallbacks(handles, {@imgProcessing_callback})

%%%%%%%%%%%%%%%%%%%%%
    function fireImgManDataChanged()
        doImgProcessing();
        imgAnalysis_gui_update(handles, imgAnalysisData);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function adjustCropAreaButton_Callback(source, eventdata)        
        ipOutput = imgAnalysisData.ipOutput;
        if isempty(ipOutput)
            return;
        end
        dsIndex = imgAnalysisData.dsIndex;
        imgIndex = imgAnalysisData.imgIndex;
        rawImg = gIMG_MAN_DATA.dataset{dsIndex}.rawImg{imgIndex};
        
        masterCropArea = gIMG_MAN_DATA.dataset{dsIndex}.masterCropArea;
        if isempty(masterCropArea)
            imgSize = size(rawImg.data);
            masterCropArea = [1 1 imgSize(2) imgSize(1)];
        end
        roi = imgProcessing_rubberbandRawImg(...
            'Adjust Crop Area...', rawImg.data, imgAnalysisData.ipParam, masterCropArea);
        if isempty(roi)
            return;
        end
        
        selection = imgUtil_dialog_keepMasterCrop();
        
        selectionSize = size(selection, 2);
        
        if selectionSize <= 0
            return;
        end
        
         %[xmin ymin width height] spatial coordinates
        if selectionSize == 2 || selection(1, 1) == 1
            % keep the height of the master crop area
            roi(4) = masterCropArea(4);
        end
        if selectionSize == 2 || selection(1, 1) == 2
            % keep the width of the master crop area
            roi(3) = masterCropArea(3);
        end

        imgAnalysisData.ipParam.crop.custom = 1;
        gIMG_MAN_DATA.dataset{dsIndex}.rawImg{imgIndex}.customCropArea = roi;
        doImgProcessing();
        imgAnalysis_gui_update(handles, imgAnalysisData, 'imgIndex');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function nextButton_Callback(source, eventdata)
        nrImgsInDS = size(gIMG_MAN_DATA.dataset{imgAnalysisData.dsIndex}.rawImg, 2);
        if nrImgsInDS <= imgAnalysisData.imgIndex
            %no more images in the dataset
            return;
        end
        imgAnalysisData.imgIndex = imgAnalysisData.imgIndex + 1;
        doImgProcessing();
        imgAnalysis_gui_update(handles, imgAnalysisData, 'imgIndex');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function previousButton_Callback(source, eventdata)
        if imgAnalysisData.imgIndex <= 1
            return;
        end
        imgAnalysisData.imgIndex = imgAnalysisData.imgIndex - 1;
        doImgProcessing();
        imgAnalysis_gui_update(handles, imgAnalysisData, 'imgIndex');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function logBookButton_Callback(source, eventdata)
        util_printLog(imgAnalysisFig);
    end

%%%%%%%%%%%%%%%%%%%%%
    function imgProcessing_callback(source, eventdata)
        [ipParam, property] = imgProcessing_panel_defaultCallback(...
            source, eventdata, imgAnalysisData.ipParam);
        imgAnalysisData.ipParam = ipParam;
        imgAnalysis_gui_update(handles, imgAnalysisData, property);
        drawnow();
        if ipParam.nrColors.auto
            setOptimalNrColors();
            imgAnalysis_gui_update(handles, imgAnalysisData, 'colormap');
        end

       
        if strcmpi(property, 'algIndex')
            imgUtil_dumpIpParamAndOutput(imgAnalysisData.dsIndex, imgAnalysisData.imgIndex,...
                ipParam, imgAnalysisData.ipOutput);
            gIMG_MAN_DATA.hasChanged = 1;
        end
        
        if strcmpi(property, 'applyIp');
            doImgProcessing();
            imgAnalysis_gui_update(handles, imgAnalysisData);
        else
            if imgProcessing_panel_isAutoApply(handles)
                if strcmpi(property, 'crop') ||...
                        strcmpi(property, 'filter') ||...
                        strcmpi(property, 'slice') ||...
                        strcmpi(property, 'subtractBg')
                    doImgProcessing();
                    imgAnalysis_gui_update(handles, imgAnalysisData);
                end
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setOptimalNrColors()
        dsIndex = imgAnalysisData.dsIndex;
        imgIndex = imgAnalysisData.imgIndex;
        ds = gIMG_MAN_DATA.dataset{dsIndex};
        imgAnalysisData.ipParam.nrColors.val = imgUtil_getOptimalNrColors(ds.rawImg{imgIndex});
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function doImgProcessing()
        dsIndex = imgAnalysisData.dsIndex;
        imgIndex = imgAnalysisData.imgIndex;
        ds = gIMG_MAN_DATA.dataset{dsIndex};
        ipParam = imgAnalysisData.ipParam;
        
        if ds.rawImg{imgIndex}.ignore
            imgAnalysisData.ipOutput = imgUtil_rawImg2ipOutput(ds.rawImg{imgIndex}, ds.camera);
            return;
        end
        
        progData = progress_panel_update(handles, [], 'start');
        
        progData.message = sprintf('Processing image #%d...', imgIndex);
        progData.value = 0.5;
        progress_panel_update(handles, progData);
        
        bgImg = [];
        if ipParam.subtractBg.acquired
            bgImg = imgUtil_averageDsImgs(ds, 1, ds.nrBgImgs);        
        end
        
        imgAnalysisData.ipOutput = imgProcessing_processRawImg(...
            ds.rawImg{imgIndex}, ds.camera, ipParam, bgImg);
        
        imgUtil_dumpIpParamAndOutput(dsIndex, imgIndex, ...
            ipParam, imgAnalysisData.ipOutput);     
        gIMG_MAN_DATA.hasChanged = 1;
        
        progress_panel_update(handles, [], 'stop');
    end
end
