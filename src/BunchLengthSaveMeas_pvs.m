% Save Bunch Length Measurement pvs to soft IOC
% Mike Zelazny (zelazny@stanford.edu)

function BunchLengthSaveMeas_pvs()

global gBunchLength;

BunchLengthLogMsg('Saving Bunch Length Measurement results to soft IOC');

if isfield (gBunchLength,'meas')
    % BPM, screen, and time stamp for first phase measurement step
    if isfield (gBunchLength.meas,'options')
        if size(gBunchLength.meas.options,2) > 0
            if ~isempty (gBunchLength.meas.options{1})
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '1BPM'), gBunchLength.meas.options{1}.bpm.desc);
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '1SCREEN'), gBunchLength.meas.options{1}.screen.desc);
            end
        end
    end
    if isfield (gBunchLength.meas,'tss')
        if size(gBunchLength.meas.tss,2) > 0
            if ~isempty (gBunchLength.meas.tss{1})
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '1TS'), imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.meas.tss{1}),1));
            end
        end
    end


    % BPM, screen, and time stamp for second measurement step
    if isfield (gBunchLength.meas,'options')
        if size(gBunchLength.meas.options,2) > 1
            if ~isempty (gBunchLength.meas.options{2})
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '2SCREEN'), gBunchLength.meas.options{2}.screen.desc);
            end
        end
    end
    if isfield (gBunchLength.meas,'tss')
        if size(gBunchLength.meas.tss,2) > 1
            if ~isempty (gBunchLength.meas.tss{2})
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '2TS'), imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.meas.tss{2}),1));
            end
        end
    end


    % BPM, screen, and time stamp for third phase measurement step
    if isfield (gBunchLength.meas,'options')
        if size(gBunchLength.meas.options,2) > 2
            if ~isempty (gBunchLength.meas.options{3})
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '3BPM'), gBunchLength.meas.options{3}.bpm.desc);
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '3SCREEN'), gBunchLength.meas.options{3}.screen.desc);
            end
        end
    end
    if isfield (gBunchLength.meas,'tss')
        if size(gBunchLength.meas.tss,2) > 2
            if ~isempty (gBunchLength.meas.tss{3})
                lcaPutNoWait (sprintf (gBunchLength.blen.pv.format, '3TS'), imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.meas.tss{3}),1));
            end
        end
    end

end

% The Measurement Results
lcaPutNoWait (gBunchLength.blen.nel.pv.name, gBunchLength.blen.nel.value{1});
lcaPutNoWait (gBunchLength.blen.meas_img_alg.pv.name, gBunchLength.blen.meas_img_alg.value{1});
lcaPutNoWait (gBunchLength.blen.sigx.pv.name, gBunchLength.blen.sigx.value{1});
lcaPutNoWait (gBunchLength.blen.sigx.std_pv.name, gBunchLength.blen.sigx.std{1});
lcaPutNoWait (gBunchLength.blen.mm.pv.name, gBunchLength.blen.mm.value{1});
lcaPutNoWait (gBunchLength.blen.mm.std_pv.name, gBunchLength.blen.mm.std{1});
lcaPutNoWait (gBunchLength.blen.sigt.pv.name, gBunchLength.blen.sigt.value{1});
lcaPutNoWait (gBunchLength.blen.sigt.std_pv.name, gBunchLength.blen.sigt.std{1});
lcaPutNoWait (gBunchLength.blen.r35.pv.name, gBunchLength.blen.r35.value{1});
lcaPutNoWait (gBunchLength.blen.r35.std_pv.name, gBunchLength.blen.r35.std{1});
lcaPutNoWait (gBunchLength.blen.meas_ts.pv.name, gBunchLength.blen.meas_ts.value{1});

