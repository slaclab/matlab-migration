% Perform Bunch Length Measurement

% Mike Zelazny (zelazny@stanford.edu)

function BunchLengthMeasure (select_TCAV_OFF, select_TCAV_PDES1, select_TCAV_PDES3)

global gBunchLength;
global gBunchLengthGUI;

gBunchLength.step = 0;
gBunchLength.numSteps = 0;
if select_TCAV_OFF
    gBunchLength.numSteps = gBunchLength.numSteps + 1;
end
if select_TCAV_PDES1
    gBunchLength.numSteps = gBunchLength.numSteps + 1;
end
if select_TCAV_PDES3
    gBunchLength.numSteps = gBunchLength.numSteps + 1;
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

BunchLengthLogMsg (sprintf('Bunch Length Measurement for %s and %s',...
    gBunchLength.screen.desc,...
    gBunchLength.bpm.desc));

name = sprintf('%s BLM %s %s',gBunchLength.tcav.name, gBunchLength.screen.desc, gBunchLength.bpm.desc);

try % Get an eDef Number
    BunchLengthLogMsg('Attempt to reserve event definition.');
    eDefNumber = eDefReserve(name);
    if isequal (eDefNumber, 0)
        BunchLengthLogMsg ('Sorry, failed to get event definition.');
        return;
    else
        BunchLengthLogMsg (sprintf('Got event definition %d.', eDefNumber));
        %pv = sprintf('%s%d',sprintf(gBunchLength.bpm.pv.format{gBunchLength.bpm.i},'XHST'),eDefNumber);
    end

catch
    BunchLengthLogMsg ('Sorry, failed to get event definition. Is EVG up?');
    return;
end

try % Reserve image acquisition
    BunchLengthLogMsg ('Attempt to reserve image acquisition.');
    ok = imgAcqReserve(name);
    if gBunchLength.gui
        pause(gBunchLength.gui_pause_time);
    end
    if gBunchLength.cancel
        ok = 0;
    end
catch
    BunchLengthLogMsg (sprintf('Sorry, failed to reserve %s', gBunchLength.screen.desc));
end

if ok
    BunchLengthLogMsg (sprintf('Got %s', gBunchLength.screen.desc));

    if isfield(gBunchLength,'meas')
        test = gBunchLength.meas;
    else
        test.gIMG_MAN_DATA.dataset{3} = [];
    end
    test.eDefNumber = eDefNumber;

    if (select_TCAV_OFF)
        BunchLengthLogMsg ('Request to measure with TCAV OFF.');
        gBunchLength.step = gBunchLength.step + 1;
        BunchLengthTCAVControl ('STANDBY');
        dsIndex = 2;

        % save the current setup
        request = test;
        request.options{dsIndex}.screen = gBunchLength.screen;
        request.options{dsIndex}.bpm = gBunchLength.bpm;
        request.options{dsIndex}.toro = gBunchLength.toro;
        request.options{dsIndex}.tcav = gBunchLength.tcav;
        request.options{dsIndex}.blen = gBunchLength.blen;
        request.option = request.options{dsIndex};
        request.raw.bpm{dsIndex} = cell(0);
        request.raw.toro{dsIndex} = cell(0);
        request.raw.tcav{dsIndex} = cell(0);
        request.raw.pidVec{dsIndex} = cell(0);
        request.camera = [];
        request.gIMG_MAN_DATA.dataset{dsIndex} = [];

        % Collect data set
        [request, ok] = BunchLengthDataAcq (request, dsIndex);

        if gBunchLength.gui
            pause(gBunchLength.gui_pause_time);
        end

        if gBunchLength.cancel
            ok = 0;
        end

        if ok
            request.cameras{dsIndex} = request.camera;
            request.tss{dsIndex} = request.ts;
            request.gIMG_MAN_DATA.dataset{dsIndex}.label = 'TCAV OFF';
            % Set TCAV phase to half way between first and third phase, arbitrary
            for i = 1:size(request.tcav{dsIndex}.pact.val,2)
                request.tcav{dsIndex}.pact.val(i) = (gBunchLength.blen.first_phase.value{1} + gBunchLength.blen.third_phase.value{1})/2;
                request.tcav{dsIndex}.pact.goodmeas(i) = 1;
                request.tcav{dsIndex}.aact.val(i) = 0;
                request.tcav{dsIndex}.aact.goodmeas(i) = 1;
            end
            test = request;
        end

    end % measure with TCAV off

    if (ok && (select_TCAV_PDES1 || select_TCAV_PDES3))
        % Activate TCAV
        BunchLengthTCAVControl ('ACTIVATE');
    end

    for num_TCAV_phase = 1:2
        gBunchLength.step = gBunchLength.step + 1;
        if isequal(2,num_TCAV_phase)
            PDES = gBunchLength.blen.first_phase.value{1};
            select_TCAV_phase = select_TCAV_PDES1;
            dsIndex = 1;
        else
            PDES = gBunchLength.blen.third_phase.value{1};
            select_TCAV_phase = select_TCAV_PDES3;
            dsIndex = 3;
        end
        if (ok && select_TCAV_phase)
            BunchLengthLogMsg (sprintf('Request to measure with TCAV at %f %s.',...
                PDES, char(gBunchLength.tcav.pdes.egu{1})));

            % save the current setup
            request = test;
            request.options{dsIndex}.screen = gBunchLength.screen;
            request.options{dsIndex}.bpm = gBunchLength.bpm;
            request.options{dsIndex}.toro = gBunchLength.toro;
            request.options{dsIndex}.tcav = gBunchLength.tcav;
            request.options{dsIndex}.blen = gBunchLength.blen;
            request.option = request.options{dsIndex};
            request.cf = [];
            request.raw.bpm{dsIndex} = cell(0);
            request.raw.toro{dsIndex} = cell(0);
            request.raw.tcav{dsIndex} = cell(0);
            request.raw.pidVec{dsIndex} = cell(0);
            request.camera = [];
            request.gIMG_MAN_DATA.dataset{dsIndex} = [];

            % If the user requested the correction function, the phase will be
            % adjusted slightly from the requested phase.
            if strcmp(request.option.bpm.blen_phase.apply.value{1},'Yes')

                request.cf.bpm = cell(0);
                request.cf.toro = cell(0);
                request.cf.tcav = cell(0);

                [request, PDES, ok] = BunchLengthCorrectionFunction (request, PDES);

                if ok
                    request.cfs{dsIndex} = request.cf; % save cf data for later
                end

            else

                if isfield (request, 'cfs')
                    request.cfs{dsIndex} = [];
                end

                ok = BunchLengthSetTCAVPhase (PDES);

            end

            if gBunchLength.gui
                pause(gBunchLength.gui_pause_time);
            end

            if gBunchLength.cancel
                ok = 0;
            end

            if ok % TCAV phase setting OK

                request.tcav{dsIndex}.pdes = PDES;

                % Collect data set
                [request, ok] = BunchLengthDataAcq (request, dsIndex);

                if gBunchLength.gui
                    pause(gBunchLength.gui_pause_time);
                end

                if gBunchLength.cancel
                    ok = 0;
                end

                if ok
                    request.cameras{dsIndex} = request.camera;
                    request.tss{dsIndex} = request.ts;
                    test = request;
                end
            end

        end % TCAV phase
    end % for each TCAV phase

    if (ok && (select_TCAV_PDES1 || select_TCAV_PDES3))
        % TCAV back to standby
        BunchLengthTCAVControl ('STANDBY');
    end

    % Release image reservation
    BunchLengthLogMsg(sprintf('Releasing %s', gBunchLength.screen.desc));
    imgAcqRelease;

else
    BunchLengthLogMsg (sprintf('Sorry, failed to reserve %s', gBunchLength.screen.desc));
end

% Release eDef
eDefRelease(eDefNumber);

if ok
    % Run Henrick's image calculations
    BunchLengthLogMsg('Bunch Length Measurement Image Processing. Please be patient.');

    for step = 1:size(test.gIMG_MAN_DATA.dataset,2)
        if gBunchLength.gui
            pause(gBunchLength.gui_pause_time);
        end
        if gBunchLength.cancel
            ok = 0;
        end
        if ok
            try
                ipParam = imgData_construct_ipParam();
                ipParam.beamSizeUnits = 'um';
                ipParam.algIndex = 6; % RMS floor
                ipParam.subtractBg.acquired = 1; % subtract acquired background
            catch
                BunchLengthLogMsg ('Sorry, image processing initialization failed.');
                return;
            end
        end
        try
            if ok
                if isfield(test.gIMG_MAN_DATA.dataset{step},'isValid')
                    test.gIMG_MAN_DATA.dataset{step}.ipOutput = imgProcessing_processDataset(test.gIMG_MAN_DATA.dataset{step}, ipParam);
                    for indexImg = 1:size(test.gIMG_MAN_DATA.dataset{step}.rawImg,2)
                        test.gIMG_MAN_DATA.dataset{step}.ipParam{indexImg} = ipParam;
                    end
                end
            end
        catch
            BunchLengthLogMsg ('Sorry, image processing failed.');
            return;
        end
    end
end

if ok
    % Run Henrik's Bunch Length Measurement Calculations
    [ok,test] = BunchLengthMeasureCalcs (test);
end

if ok
    BunchLengthLogMsg('Success! New Bunch Length Available');
end

% Success, save data ANYWAY! (changed by chevtsov 08-21-2007)
gBunchLength.meas = test;
gBunchLength.lastLoadedImageData = 2;
gBunchLength.noImageAnalysis = 0;


if gBunchLength.cancel
    BunchLengthLogMsg ('Bunch Length measurement canceled by user request.');
end
