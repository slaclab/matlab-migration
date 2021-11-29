function [rawImgArray, camera] = imgAcq_runBufferedAcq(camera, nrBgImgs, nrBeamImgs, progHandles)

if nargin < 4
    progHandles = [];
end

%init
rawImgArray = [];
progData = progress_panel_update(progHandles, [], 'start');
progData.message = 'Launching image acquisition...';
progress_panel_update(progHandles, progData);

errorMessage = [];
try
    doImgAcq();
catch
    le=lasterror();
    errorMessage = le.message;
    imgUtil_notifyLastError();
end

if ~isempty(errorMessage)
    progData.message = sprintf('Error: %s', errorMessage);
    progress_panel_update(progHandles, progData);
    imgAcq_epics_putStop(1);
    pause(3);
else
    imgAcq_epics_putDone(1);
end

progress_panel_update(progHandles, [], 'stop');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function doImgAcq()
        %%%
        progData.message = 'Reserving laser trigger...';
        progress_panel_update(progHandles, progData);
        
        success = reserveImgAcq();
        if ~success
            return;
        end 

        %%%
        progData.message = 'Setting the number of images...';
        progress_panel_update(progHandles, progData);

        success = takeImgs(nrBgImgs, 0);
        if ~success
            return;
        end
        takeImgs(nrBeamImgs, 1);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function success = reserveImgAcq()
        %check availability
        success = 0;
        if ~strcmpi(imgAcq_epics_getImgAcqAvailability(), 'ready')
            return;
        end
        
        try
            user = getenv('USER');
        catch
            user = [];
        end
        appId = [user '@imgAcq'];

        % Wait for soft IOC to assign name
        while strcmpi('<empty>', imgAcq_epics_getName())
            imgAcq_epics_putName(appId);
            if checkIfCancelledAndReportProgress('Waiting for IOC to assign name...');
                return;
            end
            pause(0.1);
        end

        % Make sure I was the one who got the reservation
        success = strcmpi(appId, imgAcq_epics_getName()) &&...
        strcmpi('busy', imgAcq_epics_getImgAcqAvailability());
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function success = goImgAcq()
        success = 0;
        % wait for done flag
        while strcmpi(imgAcq_epics_getGo(), 'waiting')
            imgAcq_epics_putGo(1);
            if checkIfCancelledAndReportProgress('Waiting for image acquisition to complete...');
                return;
            end
            pause(0.1);
        end
        while ~strcmpi(imgAcq_epics_getGo(), 'waiting')
            if checkIfCancelledAndReportProgress('Waiting for image acquisition to complete...');
                return;
            end
            pause(0.1);
        end       
        
        success = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function success = takeImgs(nrImgs, isFgImg)
        success = 1;
        camera = imgAcq_epics_getCameraParam(camera);
        
        %%%
        if ~isFgImg && nrImgs == 0
            % If the user requested 0 (zero) background images, then get
            % the saved background imag
            progData.message = 'Retrieving the saved background image...';
            progress_panel_update(progHandles, progData);
            rawImgArray{1} = imgAcq_epics_getSavedBgImg(camera);
            return;
        end
        
        imgAcq_epics_putNrImgs(nrImgs, isFgImg);
        %%%        
        success = goImgAcq();
        if ~success 
            return;
        end
        
        progData.startTime = now();
        %retrieve the buffered images
        imgBufIndex = 1 - nrImgs;
        for i=1:nrImgs
            message = sprintf('Retrieving image #%d...', i);
            value = (i-0.5)/nrImgs;
            if checkIfCancelledAndReportProgress(message, value, 0);
                success = 0;
                return;
            end
            rawImg = imgAcq_epics_getBufferedImg(camera, imgBufIndex);
            if ~isFgImg
                %force not to ignore background images
                rawImg.ignore = 0;
            end
            rawImgArray{end+1} = rawImg;
            imgBufIndex = imgBufIndex + 1; % next image
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cancelled = checkIfCancelledAndReportProgress(message, value, reportStatus)
        cancelled = progress_wasCancelled(progHandles);
        if cancelled
            progData.message = 'Cancelling image acquisition...';
            progData.value = 0;
            rawImgArray = [];
        else
            if nargin < 2
                value = -1;
            end
            if nargin < 3
                reportStatus = 1;
            end
            if reportStatus
                iocStatus = imgAcq_epics_getStatus();
                progData.message = sprintf('%s [IOC status: %s]', message, iocStatus);
            else
                progData.message = message;
            end
            progData.value = value;
        end
        if isempty(progHandles)
            disp(progData.message);
        else
            progress_panel_update(progHandles, progData);
        end
    end
end
