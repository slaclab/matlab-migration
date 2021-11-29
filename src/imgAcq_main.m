function imgAcqFig = imgAcq_main(cameraArray)
%to update occasionaly
VERSION = '1.2 (01-16-2008)';

%   the main function of the image acquisition application
global gIMG_MAN_DATA;
lcaSetTimeout(0.05);
lcaSetRetryCount(200);
%backwards compatibility
gIMG_MAN_DATA = imgUtil_copyStructVals(gIMG_MAN_DATA, imgData_construct_imgMan());

imgAcqData = initImgAcqData();
defaultCamera = imgData_construct_camera();

if nargin < 1
    cameraArray = [];
end
if isempty(cameraArray)
    cameraArray = imgAcq_initCameraProperties();
end

realCameraAvailable = 0;
if size(cameraArray, 2) < 1
    % a trick
    msgbox('There are no real cameras available.', 'No camera found', 'warn');
    imgAcqData.camera{1} = defaultCamera;
else
    realCameraAvailable = 1;
    for counter=1:size(cameraArray, 2)
        imgAcqData.camera{counter} = ...
            imgUtil_copyStructVals(cameraArray{counter}, defaultCamera);
    end
end

%%%%%%%%%%%
%create gui
imgAcqFig = imgAcq_gui();
name = get(imgAcqFig, 'name');
if imgAcqData.isProd
    name = [name '(PRODUCTION) Version ' VERSION];
else
    name = [name ' (DEVELOPMENT) Version ' VERSION];
end
set(imgAcqFig, 'name', name);
    
setappdata(imgAcqFig, 'notifyImgManDataChangedFcn', @fireImgManDataChanged);

handles = guihandles(imgAcqFig);

imgAcq_gui_update(handles, imgAcqData);
displayNextDsLabel();

if realCameraAvailable
    %PV timer
    imgAcqData.pvTimer = timer(...
        'executionMode', 'fixedSpacing',...
        'name', 'PV timer',...
        'period', imgAcqData.camera{imgAcqData.current.cameraIndex}.updatePause,...
        'tasksToExecute', 24*3600,...%some large number, but not infinity
        'timerFcn', @updateGuiFromPVs);
    start(imgAcqData.pvTimer);
end

%%%%%%%%%%%
% set callbacks
%figure set(handles.imgAcquisitionFig, 'visible', 'off')
set(imgAcqFig, 'closeRequestFcn', {@imgAcquisitionFig_CloseRequestFcn});

%pushbutton callbacks
set(handles.browseButton, 'callback', @browseButton_Callback);
set(handles.saveButton, 'callback', @saveButton_Callback);
set(handles.loadButton, 'callback', @loadButton_Callback);
set(handles.inButton, 'callback', {@moveScreen, 'IN'});
set(handles.outButton, 'callback', {@moveScreen, 'OUT'});
set(handles.measureButton, 'callback', {@measureButton_Callback});
set(handles.cancelButton, 'callback', {@cancelMeasurement});
set(handles.undockButton, 'callback', {@undockButton_Callback});
set(handles.captureButton, 'callback', {@captureButton_Callback});
set(handles.logBookButton, 'callback', {@logBookButton_Callback});
set(handles.helpButton, 'callback', {@helpButton_Callback});
set(handles.exitButton, 'callback', {@exitButton_Callback});

%checkbox callbacks
set(handles.processLiveImgCheckbox, 'callback', {@processLiveImgCheckbox_Callback});
set(handles.showLiveImgCheckbox, 'callback', {@showLiveImgCheckbox_Callback});

%edit callbacks
set(handles.dsLabelEdit, 'callback', {@dsLabelEdit_Callback});
set(handles.nrBgImgsEdit, 'callback', {@nrBgImgsEdit_Callback});
set(handles.nrBeamImgsEdit, 'callback', {@nrBeamImgsEdit_Callback});

%popupmenu callbacks
set(handles.cameraPopupmenu, 'callback', {@cameraPopupmenu_Callback});

%img processing setup panel
imgProcessing_panel_setCallbacks(handles, {@imgProcessing_callback});
set(handles.goldenOrbitCentroidCheckbox, 'callback', {@goCentrCheckbox_callback});
set(handles.laserBeamCentroidCheckbox, 'callback', {@lbCentrCheckbox_callback});
set(handles.saveCurrentCentroidButton, 'callback', {@saveCurrentCentroidButton_callback});

%%%%%%%%%%%%%%%%%%%%%
    function fireImgManDataChanged()
        imgAcq_gui_update(handles, imgAcqData);
    end

%%%%%%%%%%%%%%%%%%%%%
    function browseButton_Callback(source, eventdata)        
        if imgUtil_getNrValidDatasets() < 1
            loadData();
        end
        imgBrowserData.ipParam = imgAcqData.liveImg.ipParam;
        %[left, bottom, width, height]
        imgAcqPos = get(imgAcqFig, 'position');
        imgBrowser_main(imgBrowserData, imgAcqPos(1), imgAcqPos(2) + 80);
    end

%%%%%%%%%%%%%%%%%%%%%
    function logBookButton_Callback(source, eventdata) 
        stop(imgAcqData.pvTimer);
        util_printLog(imgAcqFig);
        start(imgAcqData.pvTimer);
    end

        
%%%%%%%%%%%%%%%%%%%%%
    function imgAcquisitionFig_CloseRequestFcn(source, eventdata)
        try
            if gIMG_MAN_DATA.isDirty
                answer = imgUtil_dialog_saveData();
                if strcmpi(answer, 'cancel')
                    return;
                end
                if strcmpi(answer, 'yes')
                    saveData();
                    return;
                end
            end
            cancelMeasurement();
            if ~isempty(imgAcqData.pvTimer)
                stop(imgAcqData.pvTimer);
                wait(imgAcqData.pvTimer);
                delete(imgAcqData.pvTimer);
            end
        catch
            imgUtil_notifyLastError();
        end
        lcaClear; %won't hurt
        delete(source);
    end

%%%%%%%%%%%%%%%%%%%%
    function exitButton_Callback(source, eventdata)
        answer = imgUtil_dialog_stopExit();
        if ~strcmpi(answer, 'yes')
            return;
        end
        f = imgUtil_getParentFig(source);
        imgAcquisitionFig_CloseRequestFcn(f, eventdata);
        try
            guihandles(f);
        catch
            %f was closed
            exit;
        end        
    end

%%%%%%%%%%%%%%%%%%%%%
    function saveButton_Callback(source, eventdata)
        saveData();
    end

%%%%%%%%%%%%%%%%%%%%%
    function saveData()
        defFileName = ['ImageAcq_' datestr(now, 'dd_mm_yy_HH_MM_SS') '.mat'];
        [filename, pathname] = uiputfile('mat', 'Save image datasets...', defFileName);
        if filename == 0
            return;
        end
        stop(imgAcqData.pvTimer);
        putAvgBgImg();
        start(imgAcqData.pvTimer);
        imgUtil_saveImgManData(fullfile(pathname, filename), gIMG_MAN_DATA);
        gIMG_MAN_DATA.isDirty = 0;
    end

%%%%%%%%%%%%%%%%%%%%%
    function loadButton_Callback(source, eventdata)
        if gIMG_MAN_DATA.isDirty
            answer = imgUtil_dialog_saveData();
            if strcmpi(answer, 'cancel')
                return;
            end
            if strcmpi(answer, 'yes')
                saveData();
                return;
            end
        end
        loadData();
    end

%%%%%%%%%%%%%%%%%%%%%
    function loadData()
        [filename, pathname] = uigetfile('*.mat', 'Load image datasets...');
        if filename == 0
            return;
        end
        gIMG_MAN_DATA = imgUtil_loadImgManData(fullfile(pathname, filename));
        gIMG_MAN_DATA.isDirty = 0;
        imgUtil_fireImgManDataChanged();
    end

%%%%%%%%%%%%%%%%%%%%%
    function measureButton_Callback(source, eventdata)
        nrBgImgs = imgAcqData.nrBgImgs;
        nrBeamImgs = imgAcqData.nrBeamImgs;
        camera = imgAcqData.camera{imgAcqData.current.cameraIndex};
        
        if nrBgImgs > camera.bufferSize
            answer = imgUtil_dialog_tooManyImagesToBuffer(nrBgImgs, camera.bufferSize);
            if strcmpi(answer,'no')
               return;
            end
        end
        
        if nrBeamImgs > camera.bufferSize
            answer = imgUtil_dialog_tooManyImagesToBuffer(nrBeamImgs, camera.bufferSize);
            if strcmpi(answer,'no')
               return;
            end
        end
        
        %Don't stop the timer because of knobbing etc.
        try            
            [rawImg, camera] = imgAcq_runBufferedAcq(camera, nrBgImgs, nrBeamImgs, handles);
            imgAcqData.camera{imgAcqData.current.cameraIndex} = camera;
            if ~isempty(rawImg)            
                ds = imgData_construct_dataset();
                ds.label = imgAcqData.dsLabel;
                if nrBgImgs == 0
                    ds.nrBgImgs = 1;
                else
                    ds.nrBgImgs = nrBgImgs;
                end
                ds.nrBeamImgs = nrBeamImgs;
                ds.rawImg = rawImg;
                ds.camera = camera;
                
                gIMG_MAN_DATA.dataset{end+1} = ds;
                gIMG_MAN_DATA.isDirty = 1;
                displayNextDsLabel();
                imgUtil_fireImgManDataChanged();
            end
        catch
            imgUtil_notifyLastError();
        end
    end

%%%%%%%%%%%%%%%%%%%%%
    function captureButton_Callback(source, eventdata)        
        cameraIndex = imgAcqData.current.cameraIndex;
        caption{1}= ...
            sprintf('Camera: %s', imgAcqData.camera{cameraIndex}.label);
        try
            tsAsString = imgUtil_matlabTime2String(lca2matlabTime(imgAcqData.liveImg.raw.timestamp));
        catch
            tsAsString = 'N/A';
        end
        caption{2} = sprintf('Time: %s', tsAsString);
        
        f = imgUtil_gui_detachedLiveImg();
        set(f, 'name', 'Captured Image');
        
        annotation(f,...
            'textbox',...
            'lineStyle', 'none',...
            'position', [0 0 1 1],...
            'string', caption...
            );
        ipParam = imgAcqData.liveImg.ipParam;
        imgUtil_setFigColormap(f, ipParam);
        
        fHandles = guihandles(f);
        ipOutput = imgAcqData.liveImg.ipOutput;
        if ~isempty(ipOutput)
            try
                imgProcessing_showProcessedImg(...
                    fHandles.imgAxes, ipParam, ipOutput, imgAcqData.camera{cameraIndex});              
            catch
                imgUtil_notifyLastError();
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%
    function helpButton_Callback(source, eventdata)
        try
            web(imgAcq_getHelpUrl());
        catch
            imgUtil_notifyLastError();
        end
    end


%%%%%%%%%%%%%%%%%%%%%
    function processLiveImgCheckbox_Callback(source, eventdata)
        stop(imgAcqData.pvTimer);
        wait(imgAcqData.pvTimer);
        try
            imgAcqData.processLiveImg = get(source, 'value');
            imgAcq_gui_update(handles, imgAcqData, 'processLiveImg');
        catch
            %do nothing
        end
        start(imgAcqData.pvTimer);
    end

%%%%%%%%%%%%%%%%%%%%%
    function showLiveImgCheckbox_Callback(source, eventdata)
        stop(imgAcqData.pvTimer);
        wait(imgAcqData.pvTimer);
        try
            imgAcqData.showLiveImg = get(source, 'value');
            if imgAcqData.showLiveImg
                imgAcqData.camera{imgAcqData.current.cameraIndex}...
                    = imgAcq_epics_getCameraParam(imgAcqData.camera{imgAcqData.current.cameraIndex});    
            end
            imgAcq_gui_update(handles, imgAcqData, 'showLiveImg');
        catch
            %do nothing
        end
        start(imgAcqData.pvTimer);
    end

%%%%%%%%%%%%%%%%%%%%%
    function dsLabelEdit_Callback(source, eventdata)
        imgAcqData.dsLabel = get(source, 'string');
        imgAcq_gui_update(handles, imgAcqData, 'dsLabel');
    end

%%%%%%%%%%%%%%%%%%%%%
    function nrBgImgsEdit_Callback(source, eventdata)
        try
            val = str2double(get(source, 'string'));
            if isempty(val) || val < 0
                return;
            end
            imgAcqData.nrBgImgs = round(val);
            imgAcq_gui_update(handles, imgAcqData, 'nrBgImgs');
        catch
            imgUtil_notifyLastError();
        end
    end

%%%%%%%%%%%%%%%%%%%%%
    function nrBeamImgsEdit_Callback(source, eventdata)
        try
            val = str2double(get(source, 'string'));
            if isempty(val) || val < 0
                return;
            end
            maxNrBeamImgs = imgAcqData.camera{imgAcqData.current.cameraIndex}.maxNrBeamImgs;
            if val > maxNrBeamImgs
                imgUtil_dialog_tooManyBeamImages(val, maxNrBeamImgs);
            else
                imgAcqData.nrBeamImgs = round(val);
            end
            imgAcq_gui_update(handles, imgAcqData, 'nrBeamImgs');   
        catch
            imgUtil_notifyLastError();
        end
    end

%%%%%%%%%%%%%%%%%%%%%
    function cameraPopupmenu_Callback(source, eventdata)
    	cameraIndex = get(source, 'value');
        imgAcqData.current.cameraIndex = cameraIndex;
        camera = imgAcqData.camera{imgAcqData.current.cameraIndex};
                
        stop(imgAcqData.pvTimer);
        try
            %reset
            if imgAcqData.showLiveImg
                imgAcqData.camera{cameraIndex} = imgAcq_epics_getCameraParam(camera);
            end
            imgAcqData.current.screenPos = [];     
            imgAcqData.rawSavedBgImg.timestamp = [];  

            set(imgAcqData.pvTimer,...
                'period', camera.updatePause);
            displayNextDsLabel();
            imgAcq_gui_update(handles, imgAcqData, 'cameraIndex'); 
        catch
            %do nothing
        end
        start(imgAcqData.pvTimer);
    end

%%%%%%%%%%%%%%%%%%%%%
    function undockButton_Callback(source, eventdata)
        %if the GUI already exists, return it
        fig = findobj('tag', 'liveImgFig');
        if ~isempty(fig)
            close(fig);
        end

        %create gui
        liveImgFig = imgUtil_gui_detachedLiveImg();
        set(liveImgFig, 'name', 'Live Image');
        set(liveImgFig, 'dockControls', 'off');
        set(liveImgFig, 'closeRequestFcn', {@dockLiveImg});
        imgUtil_setFigColormap(liveImgFig, imgAcqData.liveImg.ipParam); 
     
        imgAcqData.detachedLiveImgFig = liveImgFig;
        imgAcq_gui_update(handles, imgAcqData, 'dock');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dockLiveImg(source, eventdata)
        delete(source);
        imgAcqData.detachedLiveImgFig = [];
        imgAcq_gui_update(handles, imgAcqData, 'dock');
    end

%%%%%%%%%%%%%%%%%%%%%
    function imgProcessing_callback(source, eventdata)
        [ipParam, property]...
            = imgProcessing_panel_defaultCallback(source, eventdata, imgAcqData.liveImg.ipParam);
        imgAcqData.liveImg.ipParam = ipParam;
        if strcmpi(property, 'colormap')
            if ~isempty(imgAcqData.detachedLiveImgFig)
                imgUtil_setFigColormap(imgAcqData.detachedLiveImgFig, ipParam); 
            end
        end
        imgAcq_gui_update(handles, imgAcqData, property);
    end

%%%%%%%%%%%%%%%%%%%%%
    function goCentrCheckbox_callback(source, eventdata)
        val = get(source, 'value');
        imgAcqData.liveImg.ipParam.annotation.centroid.goldenOrbit.flag = val;
        if val == 1
            loadCentroid('goldenOrbit');
        end
        imgAcq_gui_update(handles, imgAcqData, 'centroid');
    end

%%%%%%%%%%%%%%%%%%%%%
    function lbCentrCheckbox_callback(source, eventdata)
        val = get(source, 'value');
        imgAcqData.liveImg.ipParam.annotation.centroid.laserBeam.flag = val;
        if val == 1
            loadCentroid('laserBeam');
        end
        imgAcq_gui_update(handles, imgAcqData, 'centroid');
    end

%%%%%%%%%%%%%%%%%%%%%
    function saveCurrentCentroidButton_callback(source, eventdata)
        %show dialog
        [index, flag] = imgUtil_dialog_saveCentroid();
        if ~flag
            return;
        end
        switch index
            case 1
                centrType = 'goldenOrbit';
            case 2
                centrType = 'laserBeam';
        end
        saveCurrentCentroid(centrType);
        loadCentroid(centrType, 1);
    end

%%%%%%%%%%%%%%%%%%%%%
    function moveScreen(source, eventdata, spVal)
        if isempty(spVal) || strcmpi(spVal, imgAcqData.current.screenPos)
            return;
        end
        cameraIndex = imgAcqData.current.cameraIndex;
        imgAcq_epics_putScreenPos(imgAcqData.camera{cameraIndex}, spVal);
    end

%%%%%%%%%%%%%%%%%%%%%%%%
    function updateGuiFromPVs(obj, event)
        %check whether the timer is still valid
        try
            if ~isvalid(obj)
                return;
            end

            [imgAcqData, properties] = imgAcq_updateDataFromPVs(imgAcqData);

            if imgAcqData.liveImg.ipParam.nrColors.auto
                imgAcqData.liveImg.ipParam.nrColors.val = imgUtil_getOptimalNrColors(imgAcqData.liveImg.raw);
                properties{end+1} = 'colormap';
            end
            for i=1:size(properties,2)
                imgAcq_gui_update(handles, imgAcqData, properties{i});
            end
        catch
%           try
%               stop(obj);%restart in the command window
%           catch
%               %do nothing
%           end
            imgUtil_notifyLastError();
        end
    end

%%%%%%%%%%%%%%%%%
    function loadCentroid(centrType, force)
        if nargin < 2
            force = 0;
        end
        %check if already loaded
        if ~force && ~isempty(imgAcqData.liveImg.ipParam.annotation.centroid.(centrType).xCoords)
            return;
        end
        camera = imgAcqData.camera{imgAcqData.current.cameraIndex};
        if strcmpi(centrType, 'goldenOrbit')
            [xCoords, yCoords] = imgAcq_epics_getGoldenOrbitCentroid(camera);
        else
            [xCoords, yCoords] = imgAcq_epics_getLaserBeamCentroid(camera);
        end
        imgAcqData.liveImg.ipParam.annotation.centroid.(centrType).xCoords = xCoords;
        imgAcqData.liveImg.ipParam.annotation.centroid.(centrType).yCoords = yCoords;
    end

%%%%%%%%%%%%%%%%%
    function saveCurrentCentroid(centrType)
        ipOutput = imgAcqData.liveImg.ipOutput;
        if isempty(ipOutput)
            return;
        end
        beamlist = ipOutput.beamlist;
        nrAlgs = size(beamlist, 2);
        xWaveform = zeros(1, nrAlgs);
        yWaveform = xWaveform;
        for i=1:nrAlgs
            xWaveform(i) = beamlist(i).stats(1);
            yWaveform(i) = beamlist(i).stats(2);
        end
        camera = imgAcqData.camera{imgAcqData.current.cameraIndex};
        try
            if strcmpi(centrType, 'goldenOrbit')
                imgAcq_epics_putGoldenOrbitCentroid(camera, xWaveform, yWaveform);
            else
                imgAcq_epics_putLaserBeamCentroid(camera, xWaveform, yWaveform);
            end
        catch
            imgUtil_notifyLastError();
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cancelMeasurement(source, eventdata)
        imgAcq_epics_putDone(1);
        progress_panel_update(handles, [], 'cancel');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function putAvgBgImg()
        %get the index of the last valid dataset
        dsIndex = size(gIMG_MAN_DATA.dataset, 2); %last dataset
        while dsIndex > 0
            ds = gIMG_MAN_DATA.dataset{dsIndex};
            if ~isempty(ds) && ds.isValid
                % convention: at least one valid DS is present
                break;
            end
            dsIndex = dsIndex -1;
        end
        if dsIndex <= 0
            %no valid datasets
            disp('No valid datasets');
            return;
        end
        camera = imgAcqData.camera{imgAcqData.current.cameraIndex};
        imgAcq_epics_putAvgBgImg(camera, dsIndex);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function displayNextDsLabel()
        nrDatasets = 0;
        try
            nrDatasets = size(gIMG_MAN_DATA.dataset, 2);
        catch
            %do nothing
        end
        imgAcqData.dsLabel = sprintf('Dataset #%d (%s)',...
                nrDatasets + 1,...
                imgAcqData.camera{imgAcqData.current.cameraIndex}.label);
        imgAcq_gui_update(handles, imgAcqData, 'dsLabel');        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imgAcqData = initImgAcqData()
imgAcqData.camera = [];
%always > 0
imgAcqData.current.cameraIndex = 1; 
imgAcqData.current.imgAcqAvailability = [];
imgAcqData.current.screenPos = 'N/A'; 
imgAcqData.detachedLiveImgFig = [];
imgAcqData.dsLabel = [];
imgAcqData.isProd = imgAcq_epics_isProduction();
imgAcqData.liveImg.ipOutput = [];
imgAcqData.liveImg.ipParam = imgData_construct_ipParam();
imgAcqData.liveImg.raw = imgData_construct_rawImg();
imgAcqData.nrBeamImgs = 6;
imgAcqData.nrBgImgs = 3;
imgAcqData.processLiveImg = 0;
imgAcqData.pvTimer = [];
imgAcqData.rawSavedBgImg = imgData_construct_rawImg();
imgAcqData.showLiveImg = 0;
end
