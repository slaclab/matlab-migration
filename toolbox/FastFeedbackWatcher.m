function FastFeedbackWatcher()
% Monitors LCLS fast feedbacks and updates a status PV if they freeze.

lcaSetMonitor({'SIOC:SYS0:ML00:AO984'; 'SIOC:SYS0:ML00:AO985'; 'FBCK:LR20:LS01:PCTRL'; ...
    'XCOR:IN20:221:BCTRL'; 'XCOR:IN20:381:BCTRL'; 'XCOR:LI21:101:BCTRL'; ...
    'XCOR:LI21:275:BCTRL'; 'XCOR:LI25:202:BCTRL'; 'XCOR:LI28:202:BCTRL'; ...
    'XCOR:BSYH:452:BCTRL'; 'XCOR:LTU1:488:BCTRL'; 'XCOR:LTU1:738:BCTRL'; ...
    'FBCK:FB02:GN01:MODE'; 'FBCK:FB01:TR01:MODE'; 'FBCK:IN20:TR01:MODE'; ... 
    'FBCK:FB01:TR03:MODE'; 'FBCK:FB01:TR04:MODE'; 'FBCK:FB02:TR01:MODE'; ...
    'FBCK:FB02:TR02:MODE'; 'FBCK:FB01:TR05:MODE'; 'FBCK:FB03:TR01:MODE'; ... 
    'FBCK:FB03:TR04:MODE'; 'FBCK:FB02:GN01:STATE'; 'FBCK:FB01:TR01:STATE'; ...
    'FBCK:IN20:TR01:STATE'; 'FBCK:FB01:TR03:STATE'; 'FBCK:FB01:TR04:STATE'; ...
    'FBCK:FB02:TR01:STATE'; 'FBCK:FB02:TR02:STATE'; 'FBCK:FB01:TR05:STATE'; ... 
    'FBCK:FB03:TR01:STATE'; 'FBCK:FB03:TR04:STATE'; 'SIOC:SYS0:ML02:AO131'; ...
    'SIOC:SYS0:ML02:AO110'; 'SIOC:SYS0:ML02:AO101'; 'SIOC:SYS0:ML02:AO107'; ... 
    'SIOC:SYS0:ML02:AO113'; 'SIOC:SYS0:ML02:AO116'; 'SIOC:SYS0:ML02:AO119'; ...
    'SIOC:SYS0:ML02:AO122'; 'SIOC:SYS0:ML02:AO104'; 'SIOC:SYS0:ML02:AO127'; ...
    'BPMS:IN20:221:TMIT1H'; 'BPMS:IN20:371:TMIT1H'; 'BPMS:IN20:581:TMIT1H'; ... 
    'BPMS:LI21:201:TMIT1H'; 'BPMS:LI21:601:TMIT1H'; 'BPMS:LI25:701:TMIT1H'; ...
    'BPMS:LI28:601:TMIT1H'; 'BPMS:BSYH:735:TMIT1H'; 'BPMS:LTU1:680:TMIT1H'; ...
    'BPMS:UND1:490:TMIT1H'; 'SIOC:SYS0:FB00:TMITLOW'})

Feedback_Names = {'Bunch charge';'Gun launch';'Inj. Launch';'XCAV launch'; ...
    'L2 launch';'L3 launch';'LI28 launch';'BSY launch';'LTU launch';'Und. launch'};

New_Vals = Get_Actuator_Vals();
Old_Vals = New_Vals;

Error_Counts = zeros(10,1);
% To avoid spuriously reporting frozen feedbacks, need to see the actuators
% failing to update multiple times in a row before declaring the feedback
% frozen. Error_Counts will keep track of this.

while Permit_Okay()
    
    pause(10);
    lcaPutSmart('SIOC:SYS0:ML00:AO983', lcaGetSmart('SIOC:SYS0:ML00:AO983') + 1);
    New_Vals = Get_Actuator_Vals();
    Same_Vals = (New_Vals == Old_Vals);
    
    Frozen_Fbcks = Same_Vals .* Get_Modes() .* Get_States() .* ...
        Get_Active_Feedbacks() .* Get_TMITs();
    % If Frozen_Fbcks contains any 1s, that indicates that the associated
    % fast feedback(s) were selected, on, enabled, and in the presence of
    % beam, but their actuator values did not change over this cycle.
    
    Error_Counts = (Error_Counts + Frozen_Fbcks) .* Frozen_Fbcks;
    % If Frozen_Fbcks contains any 1s, the associated counter variable in
    % Error_Counts will increment. These counter variables reset when the
    % associated actuator values are seen to update.
    
    if max(Error_Counts) > 17
        % At least one feedback's actuators have not changed for > 17
        % cycles, i.e. at least three minutes.
        lcaPutSmart('SIOC:SYS0:ML00:AO985', 1);
        disp(strcat(datestr(clock, 31), ' -- frozen feedbacks detected!'))
        i = 1;
        while i <= length(Frozen_Fbcks)
            if Frozen_Fbcks(i) && (Error_Counts(i) > 17)
                disp(strcat('     ', cellstr(Feedback_Names(i)), [' --> frozen for ' ...
                    num2str(Error_Counts(i) * 10)], ' seconds'))
            end
            i = i + 1;
        end
        disp(' ')
    else
        lcaPutSmart('SIOC:SYS0:ML00:AO985', 0);
        disp(strcat(datestr(clock, 31), ' -- no problems found'))
        disp(' ')
    end
    
    Old_Vals = New_Vals;
    
end

    function permit = Permit_Okay()
        % This permit can be used as a killswitch if needed.
        permit = lcaGetSmart('SIOC:SYS0:ML00:AO984');
    end

    function actuator_vals = Get_Actuator_Vals()

        actuator_vals = lcaGetSmart({'FBCK:LR20:LS01:PCTRL'; ...
            'XCOR:IN20:221:BCTRL'; 'XCOR:IN20:381:BCTRL'; 'XCOR:LI21:101:BCTRL'; ...
            'XCOR:LI21:275:BCTRL'; 'XCOR:LI25:202:BCTRL'; 'XCOR:LI28:202:BCTRL'; ...
            'XCOR:BSYH:452:BCTRL'; 'XCOR:LTU1:488:BCTRL'; 'XCOR:LTU1:738:BCTRL'});

    end

    function modes = Get_Modes()
        % Returns an array with 1s representing feedbacks that are enabled
        % and 0s representing feedbacks that are disabled.

        modes = strcmpi('Enable', lcaGetSmart({'FBCK:FB02:GN01:MODE'; ... 
            'FBCK:FB01:TR01:MODE'; 'FBCK:IN20:TR01:MODE'; 'FBCK:FB01:TR03:MODE'; ...
            'FBCK:FB01:TR04:MODE'; 'FBCK:FB02:TR01:MODE'; 'FBCK:FB02:TR02:MODE'; ... 
            'FBCK:FB01:TR05:MODE'; 'FBCK:FB03:TR01:MODE'; 'FBCK:FB03:TR04:MODE'}));
        
    end

    function states = Get_States()
        % Returns an array with 1s representing feedbacks that are on and
        % 0s representing feedbacks that are off.

        states = strcmpi('ON', lcaGetSmart({'FBCK:FB02:GN01:STATE'; ... 
            'FBCK:FB01:TR01:STATE'; 'FBCK:IN20:TR01:STATE'; 'FBCK:FB01:TR03:STATE'; ...
            'FBCK:FB01:TR04:STATE'; 'FBCK:FB02:TR01:STATE'; 'FBCK:FB02:TR02:STATE'; ...
            'FBCK:FB01:TR05:STATE'; 'FBCK:FB03:TR01:STATE'; 'FBCK:FB03:TR04:STATE'}));

    end

    function active_feedbacks = Get_Active_Feedbacks()
        % Returns an array with 1s representing areas where fast feedbacks
        % are currently running and 0s representing areas where matlab
        % feedbacks are currently running.
        
        active_feedbacks = ones(10,1) == lcaGetSmart({'SIOC:SYS0:ML02:AO131'; ...
            'SIOC:SYS0:ML02:AO110'; 'SIOC:SYS0:ML02:AO101'; 'SIOC:SYS0:ML02:AO107'; ...
            'SIOC:SYS0:ML02:AO113'; 'SIOC:SYS0:ML02:AO116'; 'SIOC:SYS0:ML02:AO119'; ...
            'SIOC:SYS0:ML02:AO122'; 'SIOC:SYS0:ML02:AO104'; 'SIOC:SYS0:ML02:AO127'});

    end

    function tmits = Get_TMITs()
        % Returns an array with 1s representing areas where BPM TMITs
        % are high enough that fast feedbacks will actuate and 0s
        % representing areas where TMITs are too low for feedbacks to
        % actuate.
        
        tmits = lcaGetSmart({'BPMS:IN20:221:TMIT1H'; ... 
            'BPMS:IN20:371:TMIT1H'; 'BPMS:IN20:581:TMIT1H'; 'BPMS:LI21:201:TMIT1H'; ...
            'BPMS:LI21:601:TMIT1H'; 'BPMS:LI25:701:TMIT1H'; 'BPMS:LI28:601:TMIT1H'; ...
            'BPMS:BSYH:735:TMIT1H'; 'BPMS:LTU1:680:TMIT1H'; 'BPMS:UND1:490:TMIT1H'}) ...
            > lcaGetSmart('SIOC:SYS0:FB00:TMITLOW');
        

    end

end
