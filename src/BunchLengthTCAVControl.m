function BunchLengthTCAVControl (action)

% Mike Zelazny (zelazny@stanford.edu)

% action can be 'ACTIVATE' or 'STANDBY'

global gBunchLength;

% AIDA-PVA imports
aidapva;

if strcmp('ACTIVATE',action)

    if isfield(gBunchLength,'fb')

        % Save status of Matlab feedbacks
        gBunchLength.tcav.save = cell(0);
        for i = 1:length(gBunchLength.fb)
            gBunchLength.tcav.save(i) = gBunchLength.fb(i).value{1};
        end

        % Turn Matlab feedbacks off
        off = cell(0);
        for i = 1:length(gBunchLength.fb)
            off{end+1} = 'Disable';
        end

        gBunchLength.tcav.save_pvs = cell(0);
        for i = 1:length(gBunchLength.fb)
            gBunchLength.tcav.save_pvs{end+1} = gBunchLength.fb(i).pv.name{1};
        end

        try
            lcaPut(gBunchLength.tcav.save_pvs',off');
        catch
            BunchLengthLogMsg ('Sorry, Unable to turn TCAV and Matlab feedbacks off.');
        end

    end

    try

        % reactivate triggers
        requestBuilder = pvaRequest(gBunchLength.tcav.aida);
        requestBuilder.with('BEAM', 1);
        requestBuilder.returning(AIDA_STRING);
        status = requestBuilder.get();

        if ~strcmp('activated',status)
            try
                SetKlysTact (gBunchLength.tcav.aida, 1, 'LIN_KLYS', 1);
            catch
                BunchLengthLogMsg (sprintf ('aida-pva TCAV control failed for %s', gBunchLength.tcav.aida));
            end
        end

    catch
        BunchLengthLogMsg (sprintf ('aida-pva get failed for %s',gBunchLength.tcav.aida));
    end

    try % set TCAV BGRP variable
        SetBgrpVariable ('LCLS', gBunchLength.tcav.bgrp_variable, 'Y');
    catch
        BunchLengthLogMsg (sprintf ('Unable to set BGRP valiable %s', gBunchLength.tcav.bgrp_variable));
    end

end

if strcmp ('STANDBY', action)

    % Restore Matlab feedbacks
    if isfield(gBunchLength.tcav,'save')
        if ~isempty(gBunchLength.tcav.save)
            if ~isempty(gBunchLength.tcav.save_pvs)
                try
                    lcaPut(gBunchLength.tcav.save_pvs',gBunchLength.tcav.save');
                    gBunchLength.tcav.save = [];
                    gBunchLength.tcav.save_pvs = [];
                catch
                    BunchLengthLogMsg ('OOPS! Unable to restore Matlab feedback states.');
                end
            end
        end
    end

    try
        % Deactivate triggers
        requestBuilder = pvaRequest(gBunchLength.tcav.aida);
        requestBuilder.with('BEAM', 1);
        requestBuilder.returning(AIDA_STRING);
        status = requestBuilder.get();

        if ~strcmp('deactivated',status)
            try
                SetKlysTact (gBunchLength.tcav.aida, 1, 'LIN_KLYS', 0);
            catch
                BunchLengthLogMsg (sprintf ('Aida TCAV control failed for %s', gBunchLength.tcav.aida));
            end
        end

    catch
        BunchLengthLogMsg (sprintf ('aidaget failed for %s',gBunchLength.tcav.aida));
    end

    try % reset TCAV BGRP variable
        SetBgrpVariable ('LCLS', gBunchLength.tcav.bgrp_variable, 'N');
    catch
        BunchLengthLogMsg (sprintf ('Unable to set BGRP valiable %s', gBunchLength.tcav.bgrp_variable));
    end

end
