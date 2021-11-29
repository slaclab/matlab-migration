% Perform Bunch Length Measurement Calibration

% Mike Zelazny (zelazny@stanford.edu)

global gBunchLength;
global gBunchLengthGUI;

% Save Options used for calibration
test.option.screen = gBunchLength.screen;
test.option.bpm = gBunchLength.bpm;
test.option.toro = gBunchLength.toro;
test.option.tcav = gBunchLength.tcav;
test.option.blen = gBunchLength.blen;

BunchLengthLogMsg (sprintf('Bunch Length Calibration for %s and %s',...
    test.option.screen.desc,...
    test.option.bpm.desc));

name = sprintf('%s BLM Cal %s %s',gBunchLength.tcav.name, test.option.screen.desc,test.option.bpm.desc);

% Get an eDef Number
try
    BunchLengthLogMsg('Attempt to reserve event definition.');
    test.eDefNumber = eDefReserve(name);
    if isequal (test.eDefNumber, 0)
        BunchLengthLogMsg ('Sorry, failed to get event definition.');
        return;
    end
catch
    BunchLengthLogMsg ('Sorry, failed to get event definition. Is EVG up?');
    return;
end

% Reserve image acquisition
try
    BunchLengthLogMsg('Attempt to reserve image acquisition.');
    imgAcqReserveSuccess = imgAcqReserve(name);
catch
    BunchLengthLogMsg (sprintf('Sorry, failed to reserve %s', test.option.screen.desc));
end

% Get TCAV PDES for where the given BPM y reads 0.0mm
tcav_pdes_zero = test.option.bpm.blen_phase.tcav_phase.value{1};

if imgAcqReserveSuccess
    ok = 1;

    % Activate the TCAV
    BunchLengthTCAVControl ('ACTIVATE');

    % Determine TCAV PDES where BPM reads "zero"
    if strcmp(test.option.bpm.blen_phase.apply.value{1},'Yes')

        test.cf.bpm = cell(0);
        test.cf.toro = cell(0);
        test.cf.tcav = cell(0);

        [test, tcav_pdes_zero, ok] = BunchLengthCorrectionFunction (test, tcav_pdes_zero);

    end

    if ok % i.e. no correction function or correction function converged and TORO TMIT OK

        % Determine TCAV PDES increments
        tcav_pdes = test.option.tcav.cal.start_phase.value{1}; % starting value
        tcav_incr = (abs(test.option.tcav.cal.start_phase.value{1}) + abs(test.option.tcav.cal.end_phase.value{1})) ...
            / (test.option.tcav.cal.num_phase.value{1} - 1);
        if test.option.tcav.cal.start_phase.value{1} > test.option.tcav.cal.end_phase.value{1}
            tcav_incr = -1.0*tcav_incr;
        end

        % If any Image Analysis window is up, close it
        if gBunchLength.gui
            if isfield (gBunchLengthGUI, 'imgBrowser_handle')
                if ishandle (gBunchLengthGUI.imgBrowser_handle);
                    close (gBunchLengthGUI.imgBrowser_handle);
                end
                clear gBunchLengthGUI.imgBrowser_handle;
            end
        end

        % Clear out any image data in memory
        test.gIMG_MAN_DATA = [];

        test.bpm = cell(0);
        test.toro = cell(0);
        test.tcav = cell(0);
        test.raw.bpm = cell(0);
        test.raw.toro = cell(0);
        test.raw.tcav = cell(0);
        test.camera = [];

        % Scan TCAV PDES around TCAV PDES calculated above
        for step = 1:test.option.tcav.cal.num_phase.value{1}

            gBunchLength.step = step;
            gBunchLength.numSteps = test.option.tcav.cal.num_phase.value{1};

            test.tcav{step}.pdes = tcav_pdes_zero + tcav_pdes;

            % Set TCAV Phase
            ok = BunchLengthSetTCAVPhase (test.tcav{step}.pdes);

            if ~ok
                break;
            end

            if gBunchLength.gui
                pause(gBunchLength.gui_pause_time);
            end

            if gBunchLength.cancel
                ok = 0;
                break;
            end

            % Collect data set
            [test, ok] = BunchLengthDataAcq (test, step);

            if ~ok
                break;
            end

            if gBunchLength.gui
                pause(gBunchLength.gui_pause_time);
            end

            if gBunchLength.cancel
                ok = 0;
                break;
            end

            tcav_pdes = tcav_pdes + tcav_incr;

        end
    end

    % Release image reservation
    imgAcqRelease;

else
    BunchLengthLogMsg (sprintf('Sorry, failed to reserve %s', test.option.screen.desc));
end

% Release eDef
eDefRelease(test.eDefNumber);

% Put TCAV back to standby
BunchLengthTCAVControl ('STANDBY');

% Make sure TORO TMIT OK
if ok
    ok = BunchLengthTOROTMITOK (test.toro, test.option.blen.tmit_tol.value{1});
    if ok
    else
        BunchLengthLogMsg(sprintf('Bunch Length Calibration failed due to changing %s TMIT values.', test.option.toro.desc));
    end
end

if ok
    % Run Henrick's calculations
    BunchLengthLogMsg('Bunch Length Calibration Image Processing. Please be patient.');

    for step = 1:test.option.tcav.cal.num_phase.value{1}
        if gBunchLength.gui
            pause(gBunchLength.gui_pause_time);
        end
        if gBunchLength.cancel
            return;
        end
        try
            ipParam = imgData_construct_ipParam();
            ipParam.beamSizeUnits = 'um';
            ipParam.algIndex = 6; % RMS floor
            ipParam.subtractBg.acquired = 1; % subtract acquired background
        catch
            BunchLengthLogMsg ('Sorry, image processing initialization failed.');
            return;
        end
        try
            test.gIMG_MAN_DATA.dataset{step}.ipOutput = imgProcessing_processDataset(test.gIMG_MAN_DATA.dataset{step}, ipParam);
            for indexImg = 1:size(test.gIMG_MAN_DATA.dataset{step}.rawImg,2)
                test.gIMG_MAN_DATA.dataset{step}.ipParam{indexImg} = ipParam;
            end
        catch
            BunchLengthLogMsg ('Sorry, image processing failed.');
            return;
        end
    end

    % Calculate new phase to screen and phase to bpm calibration constants
    [ok,test.polyfit, test.lscov] = BunchLengthCalibrationCalcs (test);

    if ok
        BunchLengthLogMsg('Success! New Bunch Length Calibration values available');
    end

    gBunchLength.cal = test;     % save data
    gBunchLength.lastLoadedImageData = 1;
    gBunchLength.noImageAnalysis = 0;

end
