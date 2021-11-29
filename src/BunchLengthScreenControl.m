function BunchLengthScreenControl (position)

% Bunch Length OTR/YAG Screen Control
%
% Author: Mike Zelazny (zelazny@stanford.edu)
%
% position can be either 'IN' or 'OUT'

global gBunchLength;

BunchLengthLogMsg(sprintf('Request to move %s %s', ...
    gBunchLength.screen.a{gBunchLength.screen.i}, position));

%
% Blindly trust the caller that the selected screen can go to the requested
% position.  The IOC will either set it there or not
%

lcaPutNoWait (gBunchLength.screen.pv.name, position);

%
% OTRTCAV doesn't get inserted all the way into the beam.  It gets next to
% the beam.  A kicker magnet, BXKIK, needs to be activated to move the beam
% onto the screen.
%

if isequal('OTRTCAV', gBunchLength.screen.a{gBunchLength.screen.i})

    % Setup pv list for BXKIK control
    gBunchLength.screen.magnet.pvs = cell(0);
    gBunchLength.screen.magnet.pvs{end+1} = 'KICK:LI25:344:ABORT_TCTL';
    gBunchLength.screen.magnet.pvs{end+1} = 'KICK:LI25:344:ABORT_TRIG';


    if isequal(position,'IN')

        BunchLengthLogMsg('Attempting to turn BXKIK abort triggers on.');

        try
            % Save the state of BXKIK triggers.
            gBunchLength.screen.magnet.values = lcaGet(gBunchLength.screen.magnet.pvs');
        catch
            BunchLengthLogMsg('For some reason I can''t get BXKIK trigger states.');
            gBunchLength.screen.magnet = [];
            return;
        end

        % How to turn BXKIK on, from Steph (Jan. 2008):
        %      Set KICK:LI25:344:ABORT_TCTL to 1 or "Enabled".
        %      Set KICK:LI25:344:ABORT_TRIG to one of the following values:
        %           1 or "0.5Hz"
        %           2 or "1Hz"
        %           3 or "5Hz"
        %           4 or "10Hz"
        %           5 or "Full Rate"
        %           6 or "TCAV3 Only" (not yet available)

        ON = {'Enabled';'Full Rate'};
        try
            lcaPutNoWait(gBunchLength.screen.magnet.pvs',ON);
            BunchLengthLogMsg('Attempt to setup BXKIK abort triggers successful.');
        catch
            BunchLengthLogMsg('For some reason I can''t turn on BXKIK.');
        end

    end % IN

    if isequal(position,'OUT')

        if ~isempty(gBunchLength.screen.magnet)
            BunchLengthLogMsg('Attempting to turn BXKIK abort triggers off.');

            try
                % Restore previous BXKIK abort trigger state
                lcaPutNoWait(gBunchLength.screen.magnet.pvs',gBunchLength.screen.magnet.values);
                BunchLengthLogMsg('Attempt to restore BXKIK abort trgiiers successful.');
            catch
                BunchLengthLogMsg('For some reason I can''t restore BXKIK state.');
            end

        end

    end % OUT

end % OTRTCAV