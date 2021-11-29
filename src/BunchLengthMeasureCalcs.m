% Calculates Bunch Length

function [ok, test] = BunchLengthMeasureCalcs (request)

global gBunchLength;

test = request;
ok = 1;
request.results = [];
amp = [-1, 0 ,1]; % as per Henrik

try

    BunchLengthLogMsg('Calculating Bunch Length');

    if size(request.tcav,2) < 3
        BunchLengthLogMsg ('Warning, Not enough data to calculate bunch length.');
        return; % not enough data collected
    end

    index = 0;
    request.results.tmit.total = 0;
    request.results.tmit.num = 0;

    for each_phase = 1:3
        if isempty (request.tcav{each_phase})
            BunchLengthLogMsg ('Warning, Not enough data to calculate bunch length.');
            return; % not enough data collected
        end

        ds(each_phase) = 0; % check to be sure we have a good dataset

        % the number of reading per phase
        for each_reading = 1:size(request.tcav{each_phase}.pact.val,2)

            % is the TCAV phase good?
            if request.tcav{each_phase}.pact.goodmeas(each_reading) > 0

                % is the image good?
                imgIndex = each_reading + request.gIMG_MAN_DATA.dataset{each_phase}.nrBgImgs;
                rawImg = request.gIMG_MAN_DATA.dataset{each_phase}.rawImg{imgIndex};
                ipOutput = request.gIMG_MAN_DATA.dataset{each_phase}.ipOutput{imgIndex};
                if (imgUtil_isImgOK(rawImg, ipOutput))

                    ds(each_phase) = 1; % have at least one good image/TCAV PACT for this dataset

                    index = index + 1;
                    request.results.pact(index) = request.tcav{each_phase}.pact.val(each_reading);
                    request.results.amp(index) = amp(each_phase);

                    algIndex = request.gIMG_MAN_DATA.dataset{each_phase}.ipParam{imgIndex}.algIndex;
                    request.results.beamlist(index) = request.gIMG_MAN_DATA.dataset{each_phase}.ipOutput{imgIndex}.beamlist(algIndex);

                    % Is TORO good?
                    if request.toro{each_phase}.goodmeas(each_reading) > 0

                        request.results.tmit.total = request.toro{each_phase}.tmit(each_reading) + request.results.tmit.total;
                        request.results.tmit.num = 1 + request.results.tmit.num;
                        request.results.tmit.each(request.results.tmit.num) = request.toro{each_phase}.tmit(each_reading);

                    end

                end % image OK

            end % good TCAV phase

        end % each reading

    end % each measurement phase

    request.results.calConst = gBunchLength.screen.blen_phase.value{1};
    request.results.calConstSTD = gBunchLength.screen.blen_phase.std{1};

    request.results.calConstpix = 1000.0 * request.results.calConst / request.option.screen.image.resolution{1};
    request.results.calConstSTDpix = 1000.0 * request.results.calConstSTD / request.option.screen.image.resolution{1};

    if request.results.tmit.num > 0
        request.results.tmit.avg = request.results.tmit.total / request.results.tmit.num;
    else
        request.results.tmit.avg = NaN;
    end

    if ds(1) && ds(2) && ds(3)

        opts.doPlot = 0;

        [request.results.sigxpix, ...
            request.results.sigt, ...
            request.results.sigxstdpix, ...
            request.results.sigtstd, ...
            request.results.r35, ...
            request.results.r35std] = tcav_bunchLength (...
            request.results.amp, ...
            request.results.beamlist, ...
            request.results.calConstpix, ...
            request.results.calConstSTDpix, ...
            opts);

        request.results.sigx = request.results.sigxpix * request.option.screen.image.resolution{1} / 1000.0;
        request.results.sigxstd = request.results.sigxstdpix * request.option.screen.image.resolution{1} / 1000.0;

        rf_phase = 2856e6;
        speed_of_light = 2.99792458e8;
        request.results.mm = request.results.sigt * (speed_of_light/rf_phase*1000/360);
        request.results.mmstd = request.results.sigtstd * (speed_of_light/rf_phase*1000/360);

    else
        % don't have 3 valid datasets
        BunchLengthLogMsg ('Error, Not enough data to calculate bunch length.');
        ok = 0;
        return;
    end

catch
    BunchLengthLogMsg ('Error from tcav_bunchLength.m');
    ok = 0;
    return;
end

test = request;

try  % Save to globals
    gBunchLength.blen.nel.value{1} = request.results.tmit.avg;
    gBunchLength.blen.meas_img_alg.value{1} = request.gIMG_MAN_DATA.dataset{each_phase}.ipOutput{imgIndex}.beamlist(algIndex).method;
    gBunchLength.blen.sigt.value{1} = request.results.sigt;
    gBunchLength.blen.sigt.std{1} = request.results.sigtstd;
    gBunchLength.blen.sigx.value{1} = request.results.sigx;
    gBunchLength.blen.sigx.std{1} = request.results.sigxstd;
    gBunchLength.blen.mm.value{1} = request.results.mm;
    gBunchLength.blen.mm.std{1} = request.results.mmstd;
    gBunchLength.blen.meas_ts.value{1} = imgUtil_matlabTime2String(lca2matlabTime(request.ts),1);
    if isfield(request.results,'r35')
        gBunchLength.blen.r35.value{1} = request.results.r35;
    else
        gBunchLength.blen.r35.value{1} = 0;
    end
    if isfield(request.results,'r35std')
        gBunchLength.blen.r35.std{1} = request.results.r35std;
    else
        gBunchLength.blen.r35.std{1} = 0;
    end
    BunchLengthLogMsg (sprintf('Bunch Length is %.3f%s%.3f mm', request.results.mm, char(177), request.results.mmstd));
catch
end
