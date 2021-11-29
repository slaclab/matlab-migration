% Perform Bunch Length Measurement Data Acquisition
% Mike Zelazny (zelazny@stanford.edu)

% Assumes you have image acquisition reserved and eDef slot reserved.

% Note that no new data is returned if there is an error or the user presses cancel.

function [data, ok] = BunchLengthDataAcq(request, dsIndex)

global gBunchLength;

data = request;
ok = 1;

request.gIMG_MAN_DATA.dataset{dsIndex} = imgData_construct_dataset();

assign_camera = 1;
if isfield(request,'camera')
    if ~isempty(request.camera)
        assign_camera = 0;
    end
end

if (assign_camera)
    BunchLengthLogMsg(sprintf('Reading %s camera properties.',request.option.screen.desc));
    request.camera = imgData_construct_camera();
    request.camera.label = request.option.screen.desc;
    totChars = size(request.option.screen.pv.format{request.option.screen.i},2);
    copyChars = totChars - 3;
    format = sprintf('%s.%ds','%',copyChars);
    request.camera.pvPrefix = sprintf(format,request.option.screen.pv.format{request.option.screen.i});
    request.camera = imgAcq_epics_getCameraParam(request.camera);
    if gBunchLength.gui
        pause(gBunchLength.gui_pause_time);
    end
    if gBunchLength.cancel
        ok = 0;
        return;
    end
end

% Get the number of requested background images
nrBgImgs = request.option.blen.num_bkg.value{1};

rawImg = cell(0);
if isequal(0,nrBgImgs)
    % If the user requested no background images, then get the saved background image
    nrBgImgs = 1;
    BunchLengthLogMsg(sprintf('Reading %s last saved background image',request.option.screen.desc));
    rawImg{1} = imgAcq_epics_getSavedBgImg(request.camera);
    if gBunchLength.gui
        pause(gBunchLength.gui_pause_time);
    end
    if gBunchLength.cancel
        ok = 0;
        return;
    end
else
    try
        % Take and collect background images
        BunchLengthLogMsg(sprintf('Bunch Length Calibration requesting %d background image(s).',nrBgImgs));
        imgAcqParams(nrBgImgs,0);
        imgAcqOn;
        if gBunchLength.cancel
            ok = 0;
            return;
        end
    catch
        BunchLengthLogMsg('Failed to request background images.')
        ok = 0;
        return;
    end

    % Wait until profile monitor completes acquisition, or user presses cancel
    while (true)
        try
            if (imgAcqDone)
                break;
            else
                pause(gBunchLength.gui_pause_time); % allow time for the GUI to respond
                if gBunchLength.cancel
                    ok = 0;
                    return;
                end
            end
        catch
            BunchLengthLogMsg ('Failed to collect background images');
            ok = 0;
            return;
        end
    end

    % Calculate Sheng's Index
    IMG_BUF_IDX = 1 - nrBgImgs;

    % start collecting the just taken images
    BunchLengthLogMsg(sprintf('Reading just collected background images from %s.',request.option.screen.desc));
    request.camera = imgAcq_epics_getCameraParam(request.camera);
    while IMG_BUF_IDX < 1
        rawImg{end+1} = imgAcq_epics_getBufferedImg(request.camera, IMG_BUF_IDX);
        if gBunchLength.gui
            pause(gBunchLength.gui_pause_time);
        end
        if gBunchLength.cancel
            ok = 0;
            return;
        end
        IMG_BUF_IDX = IMG_BUF_IDX + 1; % next image
    end % while more images

    if gBunchLength.cancel
        ok = 0;
        return;
    end
end

% Save the number of requested background images
request.gIMG_MAN_DATA.dataset{dsIndex}.nrBgImgs = nrBgImgs;

try
    % Set up event definition parameters
    BunchLengthLogMsg(sprintf('set up event definition #%d', request.eDefNumber));
    pv = sprintf('%s%d',sprintf(request.option.toro.pv.format,'TMITHST'),request.eDefNumber);
    nelm = lcaGetNelem(pv); % size of eDef arrays
    eDefParams (request.eDefNumber, 1, double(nelm));
    if gBunchLength.cancel
        ok = 0;
        return;
    end
catch
    BunchLengthLogMsg(sprintf('Unable to setup event definition parameters for eDef #%d.', request.eDefNumber));
    ok = 0;
    return;
end

try
    % Start event definition
    BunchLengthLogMsg(sprintf('Starting event definition #%d', request.eDefNumber));
    eDefOn (request.eDefNumber);
    if gBunchLength.cancel
        ok = 0;
        return;
    end
catch
    BunchLengthLogMsg(sprintf('Event Definition #%d failed to start.', request.eDefNumber));
    ok = 0;
    return;
end

% Get the number of requested foreground images
nrBeamImgs = request.option.blen.num_img.value{1};

try
    % Take and collect foreground images
    BunchLengthLogMsg(sprintf('Bunch Length Calibration requesting %d image(s).', nrBeamImgs));
    imgAcqParams(nrBeamImgs,1);
    imgAcqOn;
    if gBunchLength.cancel
        ok = 0;
        return;
    end
catch
    BunchLengthLogMsg('Failed to request foreground images.')
    ok = 0;
    return;
end

% Wait until profile monitor completes acquisition, or user presses cancel
while (true)
    try
        if (imgAcqDone)
            break;
        else
            pause(gBunchLength.gui_pause_time); % allow time for the GUI to respond
            if gBunchLength.cancel
                ok = 0;
                return;
            end
        end
    catch
        BunchLengthLogMsg ('Failed to collect foreground images');
        ok = 0;
        return;
    end
end

% stop the eDef
try
    BunchLengthLogMsg (sprintf('Stopping event definition #%d', request.eDefNumber));
    eDefOff(request.eDefNumber);
catch
    BunchLengthLogMsg (sprintf('Unable to stop event definition #%d', request.eDefNumber));
end

% get the number of readings actually acquired by the event definition
try
    count = eDefCount(request.eDefNumber);
catch
    BunchLengthLogMsg (sprintf('Unable to determine whether there is data in event definition #%d',request.eDefNumber));
end


try
    BunchLengthLogMsg(sprintf('Reading Pulse Id''s %s & %s', gBunchLength.bpm.desc, gBunchLength.toro.desc));
    pv = cell(0);
    % Read the pulse id's
    pv{end+1} = sprintf('PATT:SYS0:1:PULSEIDHST%d',request.eDefNumber);
    % Read the TORO
    pv{end+1} = sprintf('%sHST%d', request.option.toro.pv.name{1}, request.eDefNumber);
    pv{end+1} = sprintf('%sCNTHST%d', request.option.toro.pv.name{1}, request.eDefNumber);
    % Read the currently selected feedback BPM
    if ~gBunchLength.bpm.slc
        pv{end+1} = sprintf('%s%d',sprintf(request.option.bpm.pv.format{request.option.bpm.i},'XHST'),request.eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(request.option.bpm.pv.format{request.option.bpm.i},'XCNTHST'),request.eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(request.option.bpm.pv.format{request.option.bpm.i},'YHST'),request.eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(request.option.bpm.pv.format{request.option.bpm.i},'YCNTHST'),request.eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(request.option.bpm.pv.format{request.option.bpm.i},'TMITHST'),request.eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(request.option.bpm.pv.format{request.option.bpm.i},'TMITCNTHST'),request.eDefNumber);
    end
    vals = lcaGet(pv',count);
    request.raw.pidVec{dsIndex}.pid = vals(1,:);
    request.raw.toro{dsIndex}.tmit = vals(2,:);
    request.raw.toro{dsIndex}.goodmeas = vals(3,:);
    if gBunchLength.bpm.slc
       x = lcaGet(sprintf(request.option.bpm.pv.fmtslc{request.option.bpm.i},'X'));
       y = lcaGet(sprintf(request.option.bpm.pv.fmtslc{request.option.bpm.i},'Y'));
       tmit = lcaGet(sprintf(request.option.bpm.pv.fmtslc{request.option.bpm.i},'TMIT'));
       for i = 1:count
           request.raw.bpm{dsIndex}.x.val(i) = x;
           request.raw.bpm{dsIndex}.x.goodmeas(i) = 1;
           request.raw.bpm{dsIndex}.y.val(i) = y;
           request.raw.bpm{dsIndex}.y.goodmeas(i) = 1;
           request.raw.bpm{dsIndex}.tmit.val(i) = tmit;
           request.raw.bpm{dsIndex}.tmit.goodmeas(i) = 1;
       end
    else
        request.raw.bpm{dsIndex}.x.val = vals(4,:);
        request.raw.bpm{dsIndex}.x.goodmeas = vals(5,:);
        request.raw.bpm{dsIndex}.y.val = vals(6,:);
        request.raw.bpm{dsIndex}.y.goodmeas = vals(7,:);
        request.raw.bpm{dsIndex}.tmit.val = vals(8,:);
        request.raw.bpm{dsIndex}.tmit.goodmeas = vals(9,:);
    end
catch
    BunchLengthLogMsg(sprintf('Sorry, unable to read event definition #%d.',request.eDefNumber));
    ok = 0;
    return;
end

if gBunchLength.gui
    pause(gBunchLength.gui_pause_time);
end

if gBunchLength.cancel
    ok = 0;
    return;
end

% Read the TCAV
% pv = sprintf('%s%d', sprintf(request.option.tcav.pv.format,'PHST'), request.eDefNumber);
% try
%     BunchLengthLogMsg('Reading TCAV');
%     request.raw.tcav{dsIndex}.pact.val = lcaGet(pv, count);
%     if gBunchLength.gui
%         pause(gBunchLength.gui_pause_time);
%     end
%     if gBunchLength.cancel
%         ok = 0;
%         return;
%     end
% catch
%     BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
%     ok = 0;
% end

% pv = sprintf('%s%d', sprintf(request.option.tcav.pv.format,'PCNTHST'), request.eDefNumber);
% try
%     request.raw.tcav{dsIndex}.pact.goodmeas = lcaGet(pv, count);
%     if gBunchLength.gui
%         pause(gBunchLength.gui_pause_time);
%     end
%     if gBunchLength.cancel
%         ok = 0;
%         return;
%     end
% catch
%     BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
%     ok = 0;
% end

% pv = sprintf('%s%d', sprintf(request.option.tcav.pv.format,'AHST'), request.eDefNumber);
% try
%     request.raw.tcav{dsIndex}.aact.val = lcaGet(pv, count);
%     if gBunchLength.gui
%         pause(gBunchLength.gui_pause_time);
%     end
%     if gBunchLength.cancel
%         ok = 0;
%         return;
%     end
% catch
%     BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
%     ok = 0;
% end

% pv = sprintf('%s%d', sprintf(request.option.tcav.pv.format,'ACNTHST'), request.eDefNumber);
% try
%     request.raw.tcav{dsIndex}.aact.goodmeas = lcaGet(pv, count);
%     if gBunchLength.gui
%         pause(gBunchLength.gui_pause_time);
%     end
%     if gBunchLength.cancel
%         ok = 0;
%         return;
%     end
% catch
%     BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
%     ok = 0;
% end

for i = 1:count
    request.raw.tcav{dsIndex}.pact.val(i) = gBunchLength.tcav.pdes.value{1}; % {} this is soooo wrong.
    request.raw.tcav{dsIndex}.pact.goodmeas(i) = 1;
    request.raw.tcav{dsIndex}.aact.val(i) = gBunchLength.tcav.aact.value{1};
    request.raw.tcav{dsIndex}.aact.goodmeas(i) = 1;
end

% Calculate Sheng's Index
IMG_BUF_IDX = 1 - nrBeamImgs;

% start collecting the just taken images
BunchLengthLogMsg(sprintf('Reading just collected images from %s.',request.option.screen.desc));
request.camera = imgAcq_epics_getCameraParam(request.camera);
while IMG_BUF_IDX < 1
    rawImg{end+1} = imgAcq_epics_getBufferedImg(request.camera, IMG_BUF_IDX);
    if gBunchLength.gui
        pause(gBunchLength.gui_pause_time);
    end
    if gBunchLength.cancel
        ok = 0;
        return;
    end
    IMG_BUF_IDX = IMG_BUF_IDX + 1; % next image
end % while more images

request.gIMG_MAN_DATA.dataset{dsIndex}.rawImg = rawImg;
request.gIMG_MAN_DATA.dataset{dsIndex}.camera = request.camera;
request.gIMG_MAN_DATA.dataset{dsIndex}.isValid = 1;
request.gIMG_MAN_DATA.dataset{dsIndex}.label = 'Unknown';
if isfield(request,'tcav')
    if size(request.tcav,2) >= dsIndex
        if isfield(request.tcav{dsIndex},'pdes')
            request.gIMG_MAN_DATA.dataset{dsIndex}.label = sprintf('%0.2f TCAV PDES', request.tcav{dsIndex}.pdes);
        end
    end
end

% Save the number of requested foreground images
request.gIMG_MAN_DATA.dataset{dsIndex}.nrBeamImgs = nrBeamImgs;

% Sift through the event data looking for the readings that correspond with the image time stamps
for each_ts = 1:nrBeamImgs
    indexImg = nrBgImgs + each_ts;
    request.ts = rawImg{indexImg}.timestamp;
    PulseIdImage = lcaTs2PulseId(request.ts);
%     BunchLengthLogMsg(sprintf('Matching Image ts %s Pulse Id %d',...
%         imgUtil_matlabTime2String(lca2matlabTime(request.ts)), PulseIdImage));
    found = 0;
    event = 0;
    for each_event_reading = 2:count
        if found
        else
            % BunchLengthLogMsg(sprintf('Image Pulse Id=%d eDef Pulse Id=%d',PulseIdImage,request.raw.pidVec{dsIndex}.pid(each_event_reading)));
            if isequal(PulseIdImage,hex2dec('1FFFF')) % Bad Pulse Id Flag
                BunchLengthLogMsg(sprintf('Bad Image Pulse Id=%X',PulseIdImage));
            end
            if isequal(PulseIdImage,hex2dec('1FFFF')) || (request.raw.pidVec{dsIndex}.pid(each_event_reading) >= PulseIdImage)
                if (request.raw.pidVec{dsIndex}.pid(each_event_reading) == PulseIdImage)
                    event = each_event_reading;
                else
                    event = each_event_reading - 1; % {} Profile Monitor doesn't yet report correct time stamp, off by one
                end
                found = 1;
                request.bpm{dsIndex}.x.val(each_ts) = request.raw.bpm{dsIndex}.x.val(event);
                request.bpm{dsIndex}.x.goodmeas(each_ts) = request.raw.bpm{dsIndex}.x.goodmeas(event);
                request.bpm{dsIndex}.y.val(each_ts) = request.raw.bpm{dsIndex}.y.val(event);
                request.bpm{dsIndex}.y.goodmeas(each_ts) = request.raw.bpm{dsIndex}.y.goodmeas(event);
                request.bpm{dsIndex}.tmit.val(each_ts) = request.raw.bpm{dsIndex}.tmit.val(event);
                request.bpm{dsIndex}.tmit.goodmeas(each_ts) = request.raw.bpm{dsIndex}.tmit.goodmeas(event);
                request.toro{dsIndex}.tmit(each_ts) = request.raw.toro{dsIndex}.tmit(event);
                request.toro{dsIndex}.goodmeas(each_ts) = request.raw.toro{dsIndex}.goodmeas(event);
                request.tcav{dsIndex}.pact.val(each_ts) = request.raw.tcav{dsIndex}.pact.val(event);
                request.tcav{dsIndex}.pact.goodmeas(each_ts) = request.raw.tcav{dsIndex}.pact.goodmeas(event);
                request.tcav{dsIndex}.aact.val(each_ts) = request.raw.tcav{dsIndex}.aact.val(event);
                request.tcav{dsIndex}.aact.goodmeas(each_ts) = request.raw.tcav{dsIndex}.aact.goodmeas(event);
                request.pidVec{dsIndex}.pid(each_ts) = request.raw.pidVec{dsIndex}.pid(event);
            end
        end
    end
    if found
    else
        % not sure whether this is fatal
        BunchLengthLogMsg(sprintf('Unable to Match Pulse Id %d',PulseIdImage));
    end
end

if ok
    % SUCCESS
    data = request;
end
