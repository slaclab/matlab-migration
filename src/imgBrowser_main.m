function imgBrowserFig = imgBrowser_main(imgBrowserData, left, top)
%   imgBrowser the main function of the image browser application

global gIMG_MAN_DATA;
imgBrowserFig = [];

if imgUtil_getNrValidDatasets() < 1
    msgbox('No valid datasets available', 'Sorry...', 'warn');
    return;
end

if nargin < 1
    imgBrowserData = [];
end
if nargin < 2
    left = [];
end
if nargin < 3
    top = [];
end
imgBrowserData = imgUtil_copyStructVals(imgBrowserData, imgData_construct_imgBrowser());

%set to defaults
imgBrowserData.imgOffset = 0;

%select the last dataset
if imgBrowserData.validDsIndex < 1
    imgBrowserData.validDsIndex = imgUtil_getNrValidDatasets();
    imgBrowserData.validDsOffset = max(0, imgBrowserData.validDsIndex - imgBrowserData.nrDsTabs);
else
    imgBrowserData.validDsOffset = imgBrowserData.validDsIndex - 1;
end
logValidDsIndexChanged();

imgBrowserData.ipParam.annotation.centroid.goldenOrbit.flag = 0;
imgBrowserData.ipParam.annotation.centroid.laserBeam.flag = 0;

if imgBrowserData.ipParam.nrColors.auto
    setOptimalNrColors();
end

%create gui
imgBrowserFig = imgBrowser_gui(imgBrowserData.nrDsTabs);
%[left, bottom, width, height]
winPos = get(imgBrowserFig, 'position');
if ~isempty(left)
    winPos(1) = left;
end
if ~isempty(top)
    winPos(2) = top - winPos(4);
end
set(imgBrowserFig, 'position', winPos);

setappdata(imgBrowserFig, 'notifyImgManDataChangedFcn', @fireImgManDataChanged);
handles = guihandles(imgBrowserFig);

%before setting callbacks
nrIpOutputs = size(imgBrowserData.ipOutput, 2);
dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
nrRawImgs = size(gIMG_MAN_DATA.dataset{dsIndex}.rawImg, 2);
if ~isequal(nrIpOutputs, nrRawImgs)
   doImgProcessing(handles);
end
imgBrowser_gui_update(handles, imgBrowserData);
drawnow();

%button callbacks
%flexible
for index=1:imgBrowserData.nrDsTabs
    tag = sprintf('dsButton%d', index);
    set(handles.(tag), 'callback', {@dsButton_Callback, index});
end
set(handles.removeDSButton, 'callback', {@removeDSButton_Callback});
set(handles.xProjectionButton, 'callback', {@fitPlaneChanged, 1});
set(handles.yProjectionButton, 'callback', {@fitPlaneChanged, 0});
set(handles.logBookButton, 'callback', {@logBookButton_Callback});
set(handles.masterCropAreaButton, 'callback', {@masterCropAreaButton_Callback});
for index=1:6 %see imgBrowser_gui
    tag = sprintf('imgAnalysisButton%d', index);
    set(handles.(tag), 'callback', {@imgAnalysisButton_Callback, index});
end

%popupmenu callbacks
set(handles.dsPopupmenu, 'callback', {@dsPopupmenu_Callback});
set(handles.imgOffsetPopupmenu, 'callback', {@imgOffsetPopupmenu_Callback});

%checkbox callbacks
for index=1:6 %see imgBrowser_gui
    tag = sprintf('imgCheckbox%d', index);
    set(handles.(tag), 'callback', {@imgCheckbox_Callback, index});
end

%slider callbacks
set(handles.imgRowSlider, 'callback', {@imgRowSlider_Callback});

%img processing setup panel callbacks
imgProcessing_panel_setCallbacks(handles, {@imgProcessing_callback});

%%%%%%%%%%%%%%%%%%%%%
    function fireImgManDataChanged()
        if imgBrowserData.validDsIndex >  imgUtil_getNrValidDatasets()
            imgBrowserData.validDsIndex = 1;
            imgBrowserData.validDsOffset = 0;
            logValidDsIndexChanged();
        end
        doImgProcessing(handles);
        imgBrowser_gui_update(handles, imgBrowserData);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dsButton_Callback(source, eventdata, buttonIndex)
        if imgBrowserData.validDsIndex == imgBrowserData.validDsOffset + buttonIndex
            return;
        end
        imgBrowserData.imgOffset = 0;
        imgBrowserData.validDsIndex = imgBrowserData.validDsOffset + buttonIndex;
        logValidDsIndexChanged();
        doImgProcessing(handles);
        imgBrowser_gui_update(handles, imgBrowserData, 'validDsIndex');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function removeDSButton_Callback(source, eventdata)
        if imgUtil_getNrValidDatasets() <= 1
            %don't let all datasets be removed
            return;
        end
        answer = imgUtil_dialog_removeDataset();
        if strcmpi(answer, 'No')
            return;
        end
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        gIMG_MAN_DATA.dataset{dsIndex}.isValid = 0;
        %last valid dataset
        if imgUtil_getNrValidDatasets(dsIndex) == 0
            imgBrowserData.validDsIndex = imgBrowserData.validDsIndex - 1;
            if imgBrowserData.validDsIndex == imgBrowserData.validDsOffset
                imgBrowserData.validDsOffset = imgBrowserData.validDsOffset - 1;
            end
            logValidDsIndexChanged();
        end
        imgBrowserData.imgOffset = 0;
        gIMG_MAN_DATA.isDirty = 1;
        %also processes images
        imgUtil_fireImgManDataChanged();
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function imgAnalysisButton_Callback(source, eventdata, index)
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        imgAnalysisData.dsIndex = dsIndex;
        imgAnalysisData.imgIndex = imgBrowserData.imgOffset + index;
        imgAnalysisData.ipParam = imgBrowserData.ipParam;
         %[left, bottom, width, height]
        imgBrowserPos = get(imgBrowserFig, 'position');
        imgAnalysis_main(imgAnalysisData,...
            imgBrowserPos(1) + imgBrowserPos(3),...
            imgBrowserPos(2) + imgBrowserPos(4));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dsPopupmenu_Callback(source, eventdata)
        imgBrowserData.validDsIndex = get(source, 'value');
        imgBrowserData.validDsOffset = imgBrowserData.validDsIndex - 1;
        logValidDsIndexChanged();
        doImgProcessing(handles);
        imgBrowser_gui_update(handles, imgBrowserData, 'validDsIndex');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function imgOffsetPopupmenu_Callback(source, eventdata)
        stringLabels = get(source, 'string');
        imgLabel = stringLabels{get(source, 'value')};
        try
            imgBrowserData.imgOffset = str2double(imgLabel) - 1;
            imgBrowser_gui_update(handles, imgBrowserData, 'imgOffset');
        catch
            imgUtil_notifyLastError();
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function imgCheckbox_Callback(source, eventdata, boxIndex)
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        ds = gIMG_MAN_DATA.dataset{dsIndex};
        imgIndex = imgBrowserData.imgOffset + boxIndex;
        
        gIMG_MAN_DATA.dataset{dsIndex}.rawImg{imgIndex}.ignore = ...
            ~get(source, 'value');

        if imgProcessing_panel_isAutoApply(handles) &&...
                imgIndex <= ds.nrBgImgs &&...
                imgBrowserData.ipParam.subtractBg.acquired
            doImgProcessing(handles);
        end
        gIMG_MAN_DATA.hasChanged = 1;
        imgBrowser_gui_update(handles, imgBrowserData, 'imgValidity');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function imgRowSlider_Callback(source, eventdata)
        %to prevent unnecessary scrolling
        set(source, 'enable', 'off');
        sliderMax = get(source, 'max');
        sliderValue = get(source, 'value');
        NR_IMAGES_PER_ROW = 3;
        imgBrowserData.imgOffset = NR_IMAGES_PER_ROW * (sliderMax - round(sliderValue));
        imgBrowser_gui_update(handles, imgBrowserData, 'imgOffset');
        set(source, 'enable', 'on');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function fitPlaneChanged(source, eventdata, isX)
        if isX
            imgBrowserData.fitPlane = 'x';
        else
            imgBrowserData.fitPlane = 'y';
        end
        imgBrowser_gui_update(handles, imgBrowserData, 'fitPlane');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function logBookButton_Callback(source, eventdata)
        util_printLog(imgBrowserFig);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function masterCropAreaButton_Callback(source, eventdata)
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        ds = gIMG_MAN_DATA.dataset{dsIndex};
        %crop beam images only
        avgImg = imgUtil_averageDsImgs(ds, ds.nrBgImgs + 1, ds.nrBgImgs + ds.nrBeamImgs);
               
        roi = imgProcessing_rubberbandRawImg(...
            'Define Master Crop Area...', avgImg, imgBrowserData.ipParam);
        if isempty(roi)
            return;
        end

        answer = imgUtil_dialog_applyMasterToAll();
        
        if strcmpi(answer, 'no')
            dsIndices = dsIndex;
        else
            dsIndices = 1:size(gIMG_MAN_DATA.dataset, 2);
        end
        
        for i=dsIndices
            gIMG_MAN_DATA.dataset{i}.masterCropArea = roi;
            
            imgIndices = gIMG_MAN_DATA.dataset{i}.nrBgImgs + 1:...
                gIMG_MAN_DATA.dataset{i}.nrBgImgs + gIMG_MAN_DATA.dataset{i}.nrBeamImgs;
            for j=imgIndices
                gIMG_MAN_DATA.dataset{i}.rawImg{j}.customCropArea = roi;
            end
        end
        if imgBrowserData.ipParam.crop.custom && imgProcessing_panel_isAutoApply(handles)
            doImgProcessing(handles);
            imgBrowser_gui_update(handles, imgBrowserData);
        end
    end

%%%%%%%%%%%%%%%%%%%%%
    function imgProcessing_callback(source, eventdata)
        [ipParam, property]...
            = imgProcessing_panel_defaultCallback(source, eventdata, imgBrowserData.ipParam);
        imgBrowserData.ipParam = ipParam;
        imgBrowser_gui_update(handles, imgBrowserData, property);
        drawnow();
        
        if ipParam.nrColors.auto
            setOptimalNrColors();
            imgBrowser_gui_update(handles, imgBrowserData, 'colormap');
        end

        if strcmpi(property, 'algIndex')
            dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
            ds = gIMG_MAN_DATA.dataset{dsIndex};
            nrImgs = size(ds.rawImg, 2);
            for i=1:nrImgs
                imgUtil_dumpIpParamAndOutput(dsIndex, i, ipParam, imgBrowserData.ipOutput{i});
            end
            gIMG_MAN_DATA.hasChanged = 1;
        end
        
        if strcmpi(property, 'applyIp')
            doImgProcessing(handles);
            ipParam = imgBrowserData.ipParam;
            if ipParam.slice.total ~= 1
                %if slicing activated
                imgBrowserData.fitPlane = ipParam.slice.plane;
            end
            imgBrowser_gui_update(handles, imgBrowserData);
        else
            if imgProcessing_panel_isAutoApply(handles)
                if strcmpi(property, 'slice') && ipParam.slice.total ~= 1
                    imgBrowserData.fitPlane = ipParam.slice.plane;
                end
                if  strcmpi(property, 'crop') ||...
                        strcmpi(property, 'filter') ||...
                        strcmpi(property, 'slice') ||...
                        strcmpi(property, 'subtractBg')
                    doImgProcessing(handles);
                    imgBrowser_gui_update(handles, imgBrowserData);
                end
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%
    function setOptimalNrColors()
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        ds = gIMG_MAN_DATA.dataset{dsIndex};
        imgBrowserData.ipParam.nrColors.val = imgUtil_getOptimalNrColors(ds.rawImg);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function doImgProcessing(handles)
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        ds = gIMG_MAN_DATA.dataset{dsIndex};
        ipParam = imgBrowserData.ipParam;

%         bgImg = [];
%         if ipParam.subtractBg.acquired
%             bgImg = imgUtil_averageDsImgs(ds, 1, ds.nrBgImgs);
%         end
% 
%         nrImgs = size(ds.rawImg, 2);
%         
%         progData = progress_panel_update(handles, [], 'start');
%         if ipParam.nrColors.auto
%             %force to set at least once in the loop below
%             ipParam.nrColors.val = -1;
%         end
%             
%         for i=1:nrImgs
%             progData.message = sprintf('Processing image #%d...', i);
%             progData.value = (i-0.5)/nrImgs;
%             progress_panel_update(handles, progData);
%             
%             if isequal(ds.rawImg{i}.ignore, 1) || (i <= ds.nrBgImgs)
%                 %no processing of ignored and BG images
%                 ipOutput = imgUtil_rawImg2ipOutput(ds.rawImg{i}, ds.camera);
%             else
%                 ipOutput = imgProcessing_processRawImg(...
%                     ds.rawImg{i}, ds.camera, ipParam, bgImg);
%             end
%             imgBrowserData.ipOutput{i} = ipOutput;
%             imgUtil_dumpIpParamAndOutput(dsIndex, i, ...
%                 ipParam, imgBrowserData.ipOutput{i});
%         end
        imgBrowserData.ipOutput = imgProcessing_processDataset(ds, ipParam, handles);
        for i = 1:size(ds.rawImg, 2)
            imgUtil_dumpIpParamAndOutput(dsIndex, i, ...
                 ipParam, imgBrowserData.ipOutput{i});
        end
        gIMG_MAN_DATA.hasChanged = 1;
        % progress_panel_update(handles, [], 'stop');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function logValidDsIndexChanged()
        str = sprintf('Dataset #%d selected.', imgBrowserData.validDsIndex);
        imgUtil_log(str);
    end

end