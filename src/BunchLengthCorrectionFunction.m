% Perform Bunch Length Measurement Correction Function Data Readings & Anaylsis.

% Mike Zelazny (zelazny@stanford.edu)

function [data, correctedPDES, ok] = BunchLengthCorrectionFunction (request, PDES)

global gBunchLength;

data = request;
correctedPDES = PDES;
ok = 0;
gainFactor = gBunchLength.bpm.blen_phase.gain_factor.value{1};

for step = 1:request.option.blen.cf_np.value{1}

    request.cf.steps = step;

    [request.cf.ok, ...
        request.cf.converged, ...
        PDES, ...
        request.cf.bpm{end+1}, ...
        request.cf.toro{end+1}, ...
        request.cf.tcav{end+1}] = BunchLengthCorrectionFunctionStep (PDES, request.eDefNumber, gainFactor);

    if gBunchLength.gui
        pause(gBunchLength.gui_pause_time); % Allow time for the GUI to respond
    end

    if gBunchLength.cancel
        BunchLengthLogMsg('Bunch Length Correction Function Canceled.')
        return;
    end

    if request.cf.converged
        ok = BunchLengthTOROTMITOK (request.cf.toro, request.option.blen.tmit_tol.value{1});
        if ok
            data = request;
            correctedPDES = PDES;
        else
            BunchLengthLogMsg(sprintf('Bunch Length Correction Function failed due to changing %s TMIT values.', request.option.toro.desc));
        end
        return;
    else
        if step > 1
            if abs(request.cf.bpm{end}.y) > abs(request.cf.bpm{end-1}.y)
                gainFactor = -1.0 * gainFactor;
                BunchLengthLogMsg ('Flipping correction function gain factor sign');
            end
        end
    end
end

if ~request.cf.ok
    BunchLengthLogMsg('Bunch Length Correction Function failed.');
    return; % bad status from BunchLengthCorrectionFunctionStep
end

BunchLengthLogMsg(sprintf(...
    'Unable to find TCAV phase where %s y reads %.2f%s +-%.2f%s. Check Gain Factor sign.',...
    request.option.bpm.desc, ...
    request.option.bpm.blen_phase.y_ref.value{1},...
    char(request.option.bpm.blen_phase.y_ref.egu{1}),...
    request.option.bpm.blen_phase.y_tol.value{1},...
    char(request.option.bpm.blen_phase.y_tol.egu{1})));
