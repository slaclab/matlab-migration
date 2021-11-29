function [imgAcqData, properties] = imgAcq_updateDataFromPVs(imgAcqData)
properties = {};
camera = imgAcqData.camera{imgAcqData.current.cameraIndex};

ts = imgAcq_epics_getSavedBgImgTs(camera);
isNewBgImgTs = ~isequal(ts, imgAcqData.rawSavedBgImg.timestamp);
if isNewBgImgTs
    imgAcqData.rawSavedBgImg.timestamp = ts;
    properties{end+1} = 'savedBgImgTs';
end

if imgAcqData.showLiveImg 
    liveRawImg = imgAcq_epics_getLiveImg(camera);
    if ~isempty(liveRawImg)
        imgAcqData.liveImg.raw = liveRawImg;
        if imgAcqData.processLiveImg
            ipParam = imgAcqData.liveImg.ipParam;
            if ipParam.subtractBg.acquired
                %if not yet retrieved, or a new BG image available
                if isempty(imgAcqData.rawSavedBgImg.data) || isNewBgImgTs
                    imgAcqData.rawSavedBgImg = imgAcq_epics_getSavedBgImg(camera);
                end
                bgImg = imgAcqData.rawSavedBgImg.data;
            else 
                bgImg = [];
            end
            ipOutput = imgProcessing_processRawImg(...
                imgAcqData.liveImg.raw, camera, ipParam, bgImg);
            tsAsString = imgUtil_matlabTime2String(lca2matlabTime(imgAcqData.liveImg.raw.timestamp));
            imgAcq_epics_putFit(camera, ipOutput.beamlist, tsAsString);
        else
            ipOutput = imgUtil_rawImg2ipOutput(liveRawImg, camera);
        end
        imgAcqData.liveImg.ipOutput = ipOutput;
        properties{end+1} = 'liveImg';
    end
end

if camera.features.screen
    screenPos = imgAcq_epics_getScreenPos(camera);
    if ~strcmpi(screenPos, imgAcqData.current.screenPos)
        imgAcqData.current.screenPos = screenPos;
        properties{end+1} = 'pos';
    end
end

properties{end+1} = getMeasureProperty();
    %%%%%%%%%%%%%%%%%
    function measureProperty = getMeasureProperty()
        measureProperty = 'disableMeasure';
        if imgAcqData.showLiveImg
            return;
        end
        if  ~strcmpi(imgAcq_epics_getImgAcqAvailability(), 'ready')
            return;
        end
        %only if a camera has a screen
        if camera.features.screen && strcmpi(imgAcqData.current.screenPos, 'in')
            measureProperty = 'enableMeasure';
            return;
        end
            
    end
end
