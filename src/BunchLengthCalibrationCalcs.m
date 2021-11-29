% Performs Bunch Length Calibration after data collection

% Mike Zelazny (zelazny@stanford.edu)

function [status, polyfitResults, lscovResults] = BunchLengthCalibrationCalcs(data)

global gBunchLength;

BunchLengthLogMsg ('Calculating new Bunch Length Calibration values.');
status = 1; % OK

% Calculate new Phase to BPM Calibration Constant
k = 0;
x = [];
y = [];
goodmeas = 0;
n = size(data.toro,2);
m = size(data.toro{1}.tmit,2);

for i=1:n
    for j=1:m
        if data.tcav{i}.pact.goodmeas(j) > 0
            if data.bpm{i}.y.goodmeas(j) > 0
                goodmeas = goodmeas + 1;
                k = k + 1;
                x(k) = data.tcav{i}.pact.val(j);
                y(k) = data.bpm{i}.y.val(j);
            end
        end
    end
end

if goodmeas < 2
    BunchLengthLogMsg(sprintf('Sorry, too many bad %s Ys or TCAV Phases', gBunchLength.bpm.desc));
    status = 0;
    return;
end

try
    polyfitResults.bpm.n = k;
    polyfitResults.bpm.x = x;
    polyfitResults.bpm.y = y;
    polyfitResults.bpm.value = polyfit(x,y,1);
    old = gBunchLength.bpm.blen_phase.value{1};
    gBunchLength.bpm.blen_phase.value{1} = abs(polyfitResults.bpm.value(1));
    gBunchLength.bpm.blen_phase.timestamp{1} = imgUtil_matlabTime2String(lca2matlabTime(data.ts),1);
    gBunchLength.bpm.blen_phase.tcav_power{1} = data.tcav{n}.aact.val(m);
    if isfield (data,'cf')
        gBunchLength.bpm.blen_phase.tcav_phase.value{1} = data.cf.tcav{data.cf.steps}.pact;
    end
    if isequal(old, gBunchLength.bpm.blen_phase.value{1})
        % Don't issue message
    else
        BunchLengthLogMsg(sprintf('%s changed from %f %s to %f %s',...
            char(gBunchLength.bpm.blen_phase.desc{1}), old, char(gBunchLength.bpm.blen_phase.egu{1}),...
            gBunchLength.bpm.blen_phase.value{1}, char(gBunchLength.bpm.blen_phase.egu{1})));
    end
catch
    status = 0;
    BunchLengthLogMsg(sprintf('Sorry, unable to calculate new %s %s', gBunchLength.bpm.desc, char(gBunchLength.bpm.blen_phase.desc{1})));
    return;
end

% Calculate new Phase to Screen Calibration Constant
k = 0;
x = [];
y = [];
goodmeas = 0;
for i=1:n
    for j=1:m
        if data.tcav{i}.pact.goodmeas(j) > 0
            goodmeas = goodmeas + 1;
            imgIndex = j+data.gIMG_MAN_DATA.dataset{i}.nrBgImgs;
            rawImg = data.gIMG_MAN_DATA.dataset{i}.rawImg{imgIndex};
            ipOutput = data.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex};
            if imgUtil_isImgOK(rawImg, ipOutput)
                k = k + 1;
                x(k) = data.tcav{i}.pact.val(j);
                algIndex = data.gIMG_MAN_DATA.dataset{i}.ipParam{imgIndex}.algIndex;
                y(k) = data.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex).stats(2);
                lscovResults.beamlist(k) = data.gIMG_MAN_DATA.dataset{i}.ipOutput{imgIndex}.beamlist(algIndex);
                method = lscovResults.beamlist(k).method;
            end
        end
    end
end

if goodmeas < 2
    BunchLengthLogMsg('Sorry, TCAV failed to return good phase readings,');
end

polyfitResults.screen.n = k;
polyfitResults.screen.x = x;
polyfitResults.screen.y = y;
lscovResults.phase = x;
if k < 2
    BunchLengthLogMsg('Not enough valid images for new Calibration Constant. Try the Image Browser.');
    return;
end

try
    polyfitResults.screen.value = polyfit(x,y,1);
    old = gBunchLength.screen.blen_phase.value{1};
    gBunchLength.screen.blen_phase.timestamp{1} = imgUtil_matlabTime2String(lca2matlabTime(data.ts),1);
    gBunchLength.screen.blen_phase.tcav_power{1} = data.tcav{n}.aact.val(m);
    opts.doPlot = 0;
    [lscovResults.cal, lscovResults.calstd] = tcav_calibration (lscovResults.phase, lscovResults.beamlist, opts);
    if strcmp ('lscov',gBunchLength.screen.blen_phase.alg{1})
        gBunchLength.screen.blen_phase.value{1} = abs(lscovResults.cal * gBunchLength.screen.image.resolution{1}/1000);
        gBunchLength.screen.blen_phase.std{1} = abs(lscovResults.calstd * gBunchLength.screen.image.resolution{1}/1000);
    end
    if strcmp ('polyfit',gBunchLength.screen.blen_phase.alg{1})
        gBunchLength.screen.blen_phase.value{1} = abs(polyfitResults.screen.value(1) * gBunchLength.screen.image.resolution{1}/1000);
        gBunchLength.screen.blen_phase.std{1} = 0;
    end
    if isequal(old, gBunchLength.screen.blen_phase.value{1})
        % Don't issue message
    else
        gBunchLength.blen.cal_img_alg.value{1} = method;
        BunchLengthLogMsg(sprintf('%s changed from %f %s to %f %s',...
            char(gBunchLength.screen.blen_phase.desc{1}), old, char(gBunchLength.screen.blen_phase.egu{1}),...
            gBunchLength.screen.blen_phase.value{1}, char(gBunchLength.screen.blen_phase.egu{1})));
        % Redo measurement calculations, if measurement data exists
        if isfield (gBunchLength,'meas')
            [gbunchLength.meas.ok,gBunchLength.meas] = BunchLengthMeasureCalcs (gBunchLength.meas);
        end
    end
catch
    BunchLengthLogMsg(sprintf('Sorry, unable to calculate new %s %s. Try the image browser.', gBunchLength.screen.desc, char(gBunchLength.screen.blen_phase.desc{1})));
    lasterr
    return;
end
