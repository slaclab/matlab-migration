function imgBrowser_gui_update(handles, imgBrowserData, property)

% reminder
% NR_DS_BUTTONS = 6;
% NR_IMAGES_PER_ROW = 3;
global gIMG_MAN_DATA;

selectedDsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
selectedDs = gIMG_MAN_DATA.dataset{selectedDsIndex};
nrBgImgs = selectedDs.nrBgImgs;
nrImgs = nrBgImgs + selectedDs.nrBeamImgs;
nrValidDatasets = imgUtil_getNrValidDatasets();
%for tabs
figBgColor = get(imgUtil_getParentFig(handles.dsButton1), 'color');
ipParam = imgBrowserData.ipParam;

isArgSet = nargin > 2;
ipParam.algNames = imgUtil_getAlgNames(imgBrowserData.ipOutput);
if ~isArgSet
    imgProcessing_panel_update(handles, ipParam);
    progress_panel_update(handles);
else
    imgProcessing_panel_update(handles, ipParam, property);
end

if ~isArgSet
    %do all
    updateRemoveDSButton();
    updateDSPopupmenu();
    updateDSTabs();
    updateFitPlaneTabs()
    updateImgOffsetPopupmenu();
    updateImgRowSlider();
    updateImgAxes();
    updateImgAnalysisButtons();
    updateImgCheckboxes();
    updateImgTimestampTexts();
    updateImgIndexTexts();
    updateFitAxes();
    return;
end

if strcmpi(property, 'algIndex')
    if ipParam.annotation.centroid.current.flag
        updateImgAxes();
    end
    updateFitAxes();
end

if strcmpi(property, 'beamSizeUnits')
    updateFitAxes();
end

if strcmpi(property, 'centroid')
    updateImgAxes();
end

if strcmpi(property, 'fitPlane')
    updateFitPlaneTabs();
    updateFitAxes();
end

if strcmpi(property, 'imgOffset')
    updateImgOffsetPopupmenu();
    updateImgRowSlider();
    updateImgAxes();
    updateImgAnalysisButtons();
    updateImgCheckboxes();
    updateImgTimestampTexts();
    updateImgIndexTexts();
    updateFitAxes();
end

if strcmpi(property, 'imgValidity')
    updateImgCheckboxes();
    updateImgTimestampTexts();
    updateImgIndexTexts();
    updateImgAxes();
    updateFitAxes();
end

if strcmpi(property, 'validDsIndex') || strcmpi(property, 'validDsOffset')   
    updateRemoveDSButton();
    updateDSPopupmenu();
    updateDSTabs();
    updateImgOffsetPopupmenu();
    updateImgRowSlider();
    updateImgAxes();
    updateImgAnalysisButtons();
    updateImgCheckboxes();
    updateImgTimestampTexts();
    updateImgIndexTexts();
    updateFitAxes();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateRemoveDSButton()
        if nrValidDatasets == 1
            set(handles.removeDSButton, 'enable', 'off');
        else
            set(handles.removeDSButton, 'enable', 'on');
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateDSTabs()
        dsButtons = cell(1, imgBrowserData.nrDsTabs);
        for i=1:imgBrowserData.nrDsTabs
            tag = sprintf('dsButton%d', i);
            dsButtons{i} = handles.(tag);
        end
        
        for i=1:size(dsButtons, 2)
            vdsIndex = imgBrowserData.validDsOffset + i;
            if vdsIndex > nrValidDatasets
                %no datasets
                set(dsButtons{i}, 'visible', 'off');
            else
                dsIndex = imgBrowser_valid2actualDsIndex(vdsIndex);
                ds = gIMG_MAN_DATA.dataset{dsIndex};
                set(dsButtons{i}, 'visible', 'on');
                set(dsButtons{i}, 'string', ds.label);

                if vdsIndex == imgBrowserData.validDsIndex
                    bgColor = [0.9 0.9 0.9]; %constant
                else
                    %figure's background color
                    bgColor = figBgColor;
                end
                set(dsButtons{i}, 'backgroundColor', bgColor);
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateFitPlaneTabs()
        
        if strcmpi(imgBrowserData.fitPlane, 'x')
            xBgColor = [0.9 0.9 0.9];
            yBgColor = figBgColor;
        else
            xBgColor = figBgColor;
            yBgColor = [0.9 0.9 0.9];
        end
        set(handles.xProjectionButton, 'backgroundcolor', xBgColor);
        set(handles.yProjectionButton, 'backgroundcolor', yBgColor);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateDSPopupmenu()
        if nrValidDatasets <= imgBrowserData.nrDsTabs &&...
                imgBrowserData.validDsOffset == 0
            %max nr of tabs
            set(handles.dsPopupmenu, 'visible', 'off');
            return;
        end

        dsLabels = cell(1, nrValidDatasets);
        set(handles.dsPopupmenu, 'visible', 'on');
        for i=1:nrValidDatasets
            dsLabels{i} = sprintf('Ds %d', i);
        end
        set(handles.dsPopupmenu, 'string', dsLabels);
        set(handles.dsPopupmenu, 'value', imgBrowserData.validDsIndex);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgOffsetPopupmenu()
        imgIndexLabels = {};
        NR_IMAGES_PER_ROW = 3;
        nrLabels = max(1,ceil(nrImgs/NR_IMAGES_PER_ROW) - 1);
        for i=1:nrLabels
            imgIndexLabels{end+1} = sprintf('%d', NR_IMAGES_PER_ROW * (i-1) + 1);
        end
        set(handles.imgOffsetPopupmenu, 'string', imgIndexLabels);
        index = ceil(imgBrowserData.imgOffset/NR_IMAGES_PER_ROW) + 1;
        set(handles.imgOffsetPopupmenu, 'value', index);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nrImgs - sliderValue = imgOffset
    function updateImgRowSlider()
        NR_IMAGES_PER_ROW = 3;
        NR_IMG_BUTTONS = 6;
        if nrImgs <= NR_IMG_BUTTONS
            set(handles.imgRowSlider, 'visible', 'off');
        else
            set(handles.imgRowSlider, 'visible', 'on');
            %nrImgs > 0
            nrRows = ceil(nrImgs/NR_IMAGES_PER_ROW);
            max = nrRows - 2;
            set(handles.imgRowSlider,...
                'max', max,...
                'min', 0,...
                'sliderStep', [1/max 1/max],...
                'value',  max - imgBrowserData.imgOffset/3);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgCheckboxes()
        imgCheckBoxes = {...
            handles.imgCheckbox1,...
            handles.imgCheckbox2,...
            handles.imgCheckbox3,...
            handles.imgCheckbox4,...
            handles.imgCheckbox5,...
            handles.imgCheckbox6...
            };
        for i = 1:size(imgCheckBoxes, 2)
            imgIndex = i + imgBrowserData.imgOffset;
            if imgIndex > nrImgs
                %no more images
                set(imgCheckBoxes{i}, 'visible', 'off');
            else
                set(imgCheckBoxes{i}, 'visible', 'on');
                rawImg = selectedDs.rawImg{imgIndex};
                ipOutput = imgBrowserData.ipOutput{imgIndex};
                check = imgUtil_isImgOK(rawImg, ipOutput);
                set(imgCheckBoxes{i}, 'value', check);
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgTimestampTexts()
        imgTimestampTexts = {...
            handles.imgTimestampText1,...
            handles.imgTimestampText2,...
            handles.imgTimestampText3,...
            handles.imgTimestampText4,...
            handles.imgTimestampText5,...
            handles.imgTimestampText6...
            };
        for i = 1:size(imgTimestampTexts, 2)
            imgIndex = i + imgBrowserData.imgOffset;
            set(imgTimestampTexts{i}, 'visible', 'off');
            if imgIndex > nrImgs
                %no more images
                continue;
            end
            set(imgTimestampTexts{i}, 'visible', 'on');
            rawImg = selectedDs.rawImg{imgIndex};
            set(imgTimestampTexts{i},...
                'string',...
                imgUtil_matlabTime2String(lca2matlabTime(rawImg.timestamp)));

            rawImg = selectedDs.rawImg{imgIndex};
            ipOutput = imgBrowserData.ipOutput{imgIndex};
            enable = imgUtil_isImgOK(rawImg, ipOutput);
            
            if enable
                set(imgTimestampTexts{i}, 'enable', 'on');
            else
                set(imgTimestampTexts{i}, 'enable', 'off');
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgIndexTexts()
        imgIndexTexts = {...
            handles.imgIndexText1,...
            handles.imgIndexText2,...
            handles.imgIndexText3,...
            handles.imgIndexText4,...
            handles.imgIndexText5,...
            handles.imgIndexText6...
            };
        for i = 1:size(imgIndexTexts, 2)
            imgIndex = i + imgBrowserData.imgOffset;
            set(imgIndexTexts{i}, 'visible', 'off');
            if imgIndex > nrImgs
                %no more images
                continue;
            end
            set(imgIndexTexts{i}, 'visible', 'on');
            set(imgIndexTexts{i},...
                'string',...
                sprintf('#%d', imgIndex));

            rawImg = selectedDs.rawImg{imgIndex};
            ipOutput = imgBrowserData.ipOutput{imgIndex};
            enable = imgUtil_isImgOK(rawImg, ipOutput);
            if enable
                set(imgIndexTexts{i}, 'enable', 'on');
            else
                set(imgIndexTexts{i}, 'enable', 'off');
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgAxes()
        imgAxes = {...
            handles.imgAxes1,...
            handles.imgAxes2,...
            handles.imgAxes3,...
            handles.imgAxes4,...
            handles.imgAxes5,...
            handles.imgAxes6...
            };
        imgAxesPanel = {...
            handles.imgAxesPanel1,...
            handles.imgAxesPanel2,...
            handles.imgAxesPanel3,...
            handles.imgAxesPanel4,...
            handles.imgAxesPanel5,...
            handles.imgAxesPanel6...
            };

        for i=1:size(imgAxes, 2)
            set(imgAxesPanel{i}, 'visible', 'off');
            imgIndex = i + imgBrowserData.imgOffset;

            if imgIndex > nrImgs
                %no more images
                continue;
            end
            set(imgAxesPanel{i}, 'visible', 'on');
            if imgIndex <= nrBgImgs
                imgProcessing_showProcessedImg(imgAxes{i}, imgData_construct_ipParam(), imgBrowserData.ipOutput{imgIndex});
            else
                imgProcessing_showProcessedImg(imgAxes{i}, ipParam, imgBrowserData.ipOutput{imgIndex});
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateImgAnalysisButtons()
        imgAnalysisButtons = {...
            handles.imgAnalysisButton1,...
            handles.imgAnalysisButton2,...
            handles.imgAnalysisButton3,...
            handles.imgAnalysisButton4,...
            handles.imgAnalysisButton5,...
            handles.imgAnalysisButton6...
            };
        
        for i = 1:size(imgAnalysisButtons, 2)
            imgIndex = i + imgBrowserData.imgOffset;
            if imgIndex <= nrBgImgs || imgIndex > nrImgs
                %bg image, or no more images
                set(imgAnalysisButtons{i}, 'visible', 'off');
            else
                set(imgAnalysisButtons{i}, 'visible', 'on');
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateFitAxes()
        fitAxes = {...
            handles.imgFitAxes1,...
            handles.imgFitAxes2,...
            handles.imgFitAxes3,...
            handles.imgFitAxes4,...
            handles.imgFitAxes5,...
            handles.imgFitAxes6...
            };
         imgAxes = {...
            handles.imgAxes1,...
            handles.imgAxes2,...
            handles.imgAxes3,...
            handles.imgAxes4,...
            handles.imgAxes5,...
            handles.imgAxes6...
            };
        for i=1:size(fitAxes, 2)
            imgIndex = i + imgBrowserData.imgOffset;
            imgUtil_clearFitAxes(fitAxes{i});
            if imgIndex <= nrBgImgs || imgIndex > nrImgs
                %bg image, or no more images
                set(fitAxes{i}, 'visible', 'off');
            else
                set(fitAxes{i}, 'visible', 'on');
                isFitPlaneX = strcmpi(imgBrowserData.fitPlane, 'x');
                if isFitPlaneX
                    profFieldName = 'profx';
                else
                    profFieldName = 'profy';
                end

                beamlist = imgBrowserData.ipOutput{imgIndex}.beamlist;
                if isempty(beamlist)
                    continue;
                end
                imgUtil_showPixelBeamDataOnAxes(...
                    beamlist(ipParam.algIndex).(profFieldName),...
                    isFitPlaneX,...
                    fitAxes{i},...
                    imgAxes{i});
                if ~strcmpi(ipParam.beamSizeUnits, 'um')
                    continue;
                end
                imgProcessing_pixel2Micron(...
                    fitAxes{i}, selectedDs.camera, isFitPlaneX, ~isFitPlaneX);
                if isFitPlaneX
                    axLabel = get(fitAxes{i}, 'xlabel');
                else
                    axLabel = get(fitAxes{i}, 'ylabel');
                end
                set(axLabel, 'string', ipParam.beamSizeUnits);                
            end
        end
    end
end