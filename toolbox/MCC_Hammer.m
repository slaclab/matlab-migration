function MCC_Hammer()
% MCC_Hammer attempts to mimic the fault-unlatching behavior of operators.
% Unlatches most MPS faults immediately. If too many faults are
% unlatched in rapid succession, retreats to BYKIK and tries to stabilize
% the beam there. Will pause while the Guardian or the BCS is faulted. Will
% not unlatch certain "blacklisted" faults.
%
% It is dope on the floor and magic on the mic.
%
% Author: Benjamin Ripman
% Last revision on 3/26/12 by Benjamin Ripman


% Notes to self:
% 
% Rate PV is EVNT:SYS0:1:LCLSBEAMRATE
%
% aidalist syntax:
% aidalist TORO%MPSC --> find all MPS inputs matching this query
% caget `aidalist TORO%MPSC` -> get all states for MPS inputs matching this
% query (note use of special quote-marks)
%
%
% Things to work on:
%
% When one or more of the blacklisted faults is paralyzing MCC_Hammer, have
% it tell the user which fault(s) are responsible. Maybe give them the
% option to bypass those faults.
%
% Add bad klystron statuses as a reason for MCC_Hammer to pause.
% Also add magnets that have tripped off, 6x6 or other feedbacks
% going wild, VVS trips, and vacuum valves that have gone in.
% Update: might have to pass on some of these, or just check them when
% MCC_Hammer gives up so that it can give the user a helpful error message.
% Klystron statuses alone take over a second to check.
% 
% Magnet info can be had by drilling down into magnet panels, then going
% to status -> summary, e.g. QUAD:LI27:501:STATMSG (probe to see possible
% messages; find out which ones are worth stopping Hammer for). Vacuum
% valve info can be had from MPS global -> all digital inputs.
%
% Make the content of the message window global.

clear

HammerFig = figure('Name','MCC Hammer','Position',[360,600,575,300], ...
    'MenuBar','none','Resize','off', 'Color',get(0,'defaultuicontrolbackgroundcolor'), ...
    'CloseRequestFcn', {@Close_MCC_Hammer});

Start = uicontrol(HammerFig,'Style','pushbutton','String','Start', ...
    'Position',[25 200 75 30],'BackgroundColor',[0.4,0.8,0.4], 'Callback', {@Start_Callback});
Reset = uicontrol(HammerFig,'Style','pushbutton','String','Reset', 'Enable', 'off', ...
    'Position',[25 145 75 30],'BackgroundColor',[0.8,0.8,0], 'Visible', 'off', ...
    'Callback', {@Reset_Callback});
Stop = uicontrol(HammerFig,'Style','pushbutton','String','Stop', ...
    'Position',[25 90 75 30],'Enable','off','Interruptible','off', ...
    'BackgroundColor',[0.9,0.2,0.2],'Callback', {@Stop_Callback});
Messages = uipanel('Parent',HammerFig,'Title','Messages','BackgroundColor', ...
    get(0,'defaultuicontrolbackgroundcolor'),'Position',[0.22 0.14 0.69 0.81]);
MessageBox = uicontrol('Parent',Messages,'Style','text','Position', ...
    [12 12 370 210],'String',{'Every time you see me, that Hammer''s just so hype.', ...
    'I''m dope on the floor and I''m magic on the mic.'},'BackgroundColor','white');
NeverGiveUp = uicontrol(HammerFig,'Style','checkbox','Position',[270 17 20 15], ...
    'Value',0);
NeverGiveUpLabel = uicontrol(HammerFig,'Style','text','Position',[293 15 90 15], ...
    'string','Never give up');

AUTOMATION_RUNNING_HERE = 0;
% Indicates whether this particular instance of MCC_Hammer is
% currently running the automation. (Only one instance is allowed to run at
% any given time, globally.)

HAMMER_LOCAL_PERMIT = 1;
% Lost when the GUI's CloseRequest is called. Mostly redundant, but I
% never want to see another Skynet scenario with MCC_Hammer.

BYKIK_NUMFAULTS = 5;
% Number of times faults must occur in rapid succession before engaging BYKIK;
% decrease to use BYKIK more liberally, increase for opposite effect.

UNLATCH_INTERVAL = 1.5;
% Maximum time interval between unlatches considered to be in rapid succession;
% increase to use BYKIK more liberally, decrease for opposite effect.

RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
% Stores the last [BYKIK_NUMFAULTS - 1] time intervals between unlatches.

N_UNLATCHES = 0;
% Number of times this instance of the GUI has unlatched MPS faults.

RECENT_KIKS = 0;
% Number of times we have parked the beam on BYKIK recently

lcaSetMonitor({'SIOC:SYS0:ML00:AO865'; 'SIOC:SYS0:ML00:AO866'; ...
    'SIOC:SYS0:ML00:AO466'; 'BCS:IN20:1:BEAMPERM'; 'BCS:IN20:1:SBIPERM'; ...
    'BCS:MCC0:1:SBIPERMIT'; 'BCS:IN20:1:TIUPERM'; 'BCS:IN20:1:LSSPERM'; ...
    'IOC:BSY0:MP01:PC_RATE'; 'IOC:BSY0:MP01:PCELLCTL'; 'IOC:BSY0:MP01:MS_RATE'; ...
    'IOC:BSY0:MP01:MSHUTCTL'; 'IOC:BSY0:MP01:BYKIK_RATE'; 'IOC:BSY0:MP01:BYKIKCTL'; ...
    'SIOC:SYS0:ML02:AO007'; 'STEP:FEE1:1561:ERROR.L'; 'CXI:DET:01:MPSFAULT_MPS'; ...
    'CXI:DET:02:MPSFAULT_MPS'; 'XPP:DET:01:MPSFAULT_MPS'; 'PPS:NEH1:1:S1STPRSUM'; ...
    'PPS:NEH1:2:S2STPRSUM'; 'PPS:NEH1:3:S2BSTPRSUM'; 'PPS:NEH1:3:SH1STPRSUM'; ...
    'PPS:FEH1:5:S5STPRSUM'; 'PPS:FEH1:5:S5BSTPRSUM'; 'DUMP:LTU1:970:TDUND_OUT'; ...
    'DUMP:LTU1:970:TDUND_IN'; 'DUMP:LI21:305:TD11_OUT'; 'DUMP:LI21:305:TD11_IN'; ...
    'OTRS:LI21:237:OUT_LMTSW'; 'OTRS:LI21:237:IN_LMTSW'; 'OTRS:LI21:291:OUT_LMTSW'; ...
    'OTRS:LI21:291:IN_LMTSW'; 'OTRS:IN20:541:OUT_LMTSW'; 'OTRS:IN20:541:IN_LMTSW'; ...
    'OTRS:IN20:571:OUT_LMTSW'; 'OTRS:IN20:571:IN_LMTSW'; 'OTRS:IN20:621:OUT_LMTSW'; ...
    'OTRS:IN20:621:IN_LMTSW'; 'OTRS:IN20:711:OUT_LMTSW'; 'OTRS:IN20:711:IN_LMTSW'; ...
    'OTRS:LI25:920:OUT_LMTSW'; 'OTRS:LI25:920:IN_LMTSW'; 'OTRS:LI24:807:OUT_LMTSW'; ... 
    'OTRS:LI24:807:IN_LMTSW'; 'OTRS:LI25:342:OUT_LMTSW'; 'OTRS:LI25:342:IN_LMTSW'; ...
    'OTRS:LTU1:449:OUT_LMTSW'; 'OTRS:LTU1:449:IN_LMTSW'; 'OTRS:LTU1:745:OUT_LMTSW_MPS'; ... 
    'OTRS:LTU1:745:IN_LMTSW_MPS'; 'OTRS:IN20:465:OUT_LMTSW'; 'OTRS:IN20:465:IN_LMTSW'; ...
    'FLTR:IN20:130:FLT1_STS'; 'OTRS:IN20:471:OUT_LMTSW'; 'OTRS:IN20:471:IN_LMTSW'; ...
    'TORO:IN20:215:CHASIM11_MPS'; 'TORO:IN20:431:CHASIM12_MPS'; 'TORO:LI24:1:CHASIMB2_MPS'; ...
    'TORO:LTU1:920:IMUNDI_L1_MPS'; 'TORO:LTU1:920:IMUNDI_L2_MPS'; 'TORO:DMP1:198:IMUNDO_L1_MPS'; ...
    'TORO:DMP1:198:IMUNDO_L2_MPS'; 'TORO:IN20:203:TC203L1_MPS'; 'TORO:IN20:203:TC203L2_MPS'; ...
    'TORO:IN20:971:TC2S1L1_MPS'; 'TORO:IN20:971:TC2S1L2_MPS'; 'TORO:LI21:205:TCBC1L1_MPS'; ...
    'TORO:LI21:205:TCBC1L2_MPS'; 'TORO:LI24:707:TCBC2L1_MPS'; 'TORO:LI24:707:TCBC2L2_MPS'; ...
    'TORO:B921:198:CHASIMUND_MPS'; 'TORO:IN20:BL215:MPS_STATE_MPS'; 'XPP:DET:01:MPSFAULT_BYPS'; ...
    'CXI:DET:01:MPSFAULT_BYPS'; 'CXI:DET:02:MPSFAULT_BYPS'; 'STPR:XRT1:1:SH2_PPSSUM'; ...
    'OTRS:IN20:471:OUT_LMTSW_BYPC';'OTRS:IN20:471:IN_LMTSW_BYPC'})

refreshTimer = timer ('TimerFcn', @Timer_Callback_fcn, 'Period', 0.5, 'ExecutionMode', 'fixedRate' );
start(refreshTimer);


% UI-related functions
    function Start_Callback(source, eventdata)
        % Starts the automation if it isn't running elsewhere.

        if Hammer_Running()
           
            Display({'MCC_Hammer is already running somewhere else.'; ...
                'Also, you shouldn''t be seeing this message.'; ...
                'Please inform bripman that an error occurred.'}, 0);
            Prepare_To_Stop()
            return

        else

            lcaPutSmart('SIOC:SYS0:ML00:AO866',1);
            lcaPutSmart('SIOC:SYS0:ML00:AO865',1);
            AUTOMATION_RUNNING_HERE = 1;
            set(HammerFig,'Color',[0.72941,0.83137,0.95686]);
            set(Messages,'BackgroundColor',[0.72941,0.83137,0.95686]);
            set(NeverGiveUp,'BackgroundColor',[0.72941,0.83137,0.95686]);
            set(NeverGiveUpLabel,'BackgroundColor',[0.72941,0.83137,0.95686]);
            Prepare_To_Stop()
            Display({'Yo, let me bust the funky lyrics!'},0);
            RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
            
            drawnow
            
            tic

            while Permits_Okay()
                % Main automation loop

                pause(0.02); % Pause briefly between loops so as not to overstress the system

                if Guardian_Is_Faulted() && Permits_Okay()

                    Respond_To_Guardian()

                end

                if BCS_Is_Faulted() && Permits_Okay()

                    Respond_To_BCS()

                end

                if MPS_Is_Faulted() && Permits_Okay()
                    
                    Respond_To_MPS()

                end

            end

            if AUTOMATION_RUNNING_HERE
                % We exited from the main loop because the stop button was
                % pressed, not because the CloseRequest function was
                % called.
                
                lcaPutSmart('SIOC:SYS0:ML00:AO865',0);
                AUTOMATION_RUNNING_HERE = 0;
            
            end
            
            if ~isempty(get(0,'CurrentFigure'))

                Prepare_To_Start()
                set(HammerFig,'Color',get(0,'defaultuicontrolbackgroundcolor'));
                set(Messages,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                set(NeverGiveUp,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                set(NeverGiveUpLabel,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                Display({'Now, why would I ever stop doing this'; ...
                    'With others making records that just don''t hit.'}, 1);

            end

        end

    end

    function Stop_Callback(source, eventdata)
        % Takes away MCC_Hammer global permit.

        if Hammer_Running() && ~AUTOMATION_RUNNING_HERE
           
            Display({'Terminating MCC_Hammer remotely!'}, 0)
            
        end
        
        lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
        
    end

    function Reset_Callback(source, eventdata)
        % Resets MCC_Hammer status PV.
        % (Sometimes gets stuck at 1 when Hammer is closed incorrectly.)

        lcaPutSmart('SIOC:SYS0:ML00:AO865',0);
        set(Reset,'Enable','off');
        set(Reset,'Visible','off');
        Display({'Every time you see me, that Hammer''s just so hype.', ...
            'I''m dope on the floor and I''m magic on the mic.'}, 0)

    end

    function Close_MCC_Hammer(source, eventdata)
        
        if AUTOMATION_RUNNING_HERE
            % Set both the global permit and the global status PV to 0,
            % because they'll get out of synch otherwise. Take away the
            % local permit to help ensure that the main loop terminates.

            lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
            lcaPutSmart('SIOC:SYS0:ML00:AO865',0);
            HAMMER_LOCAL_PERMIT = 0;
            AUTOMATION_RUNNING_HERE = 0;

        end

        stop(refreshTimer);
        delete(refreshTimer);

        delete(gcf);
        % exit from Matlab when not running the desktop
        if usejava('desktop')
            % don't exit from Matlab
            disp('Goodbye!')
        else
            exit
        end

    end

    function Timer_Callback_fcn (obj, event)
        % Executes with each timer tick. Keeps UI controls up-to-date.
        
        if Hammer_Running()
            
            Prepare_To_Stop()
        
        else

            Prepare_To_Start()
            
        end
        
        if Hammer_Running() && ~Global_Permit_Okay()

            set(Reset,'Enable','on');
            set(Reset,'Visible','on');
            Display({'MCC_Hammer status PV is dorked - press reset button.'}, 0)

        end
        
    end


% Info-fetching functions
    function running = Hammer_Running()

        running = lcaGetSmart('SIOC:SYS0:ML00:AO865');

    end

    function global_permit = Global_Permit_Okay()
        
        global_permit = lcaGetSmart('SIOC:SYS0:ML00:AO866');

    end

    function local_permit = Local_Permit_Okay()

        local_permit = HAMMER_LOCAL_PERMIT;

    end

    function permits = Permits_Okay()

        permits = Global_Permit_Okay() && Local_Permit_Okay();

    end

    function g_faulted = Guardian_Is_Faulted()
        % Checks whether the Guardian is faulted.
        % Returns [g_faulted] = 0 if the Guardian is not faulted.
        % Returns [g_faulted] = 1 if the Guardian is faulted.

        g_faulted = lcaGetSmart('SIOC:SYS0:ML00:AO466');

    end

    function b_faulted = BCS_Is_Faulted()
        % Checks whether the BCS is faulted.
        % Returns [b_faulted] = 0 if the BCS is not faulted.
        % Returns [b_faulted] = 1 if the BCS is faulted.

        b_faulted = strcmpi(lcaGetSmart('BCS:IN20:1:BEAMPERM'), 'FAULT') || ...
            strcmpi(lcaGetSmart('BCS:IN20:1:SBIPERM'), 'FAULT') || ...
            strcmpi(lcaGetSmart('BCS:MCC0:1:SBIPERMIT'), 'FAULT') || ...
            strcmpi(lcaGetSmart('BCS:IN20:1:TIUPERM'), 'FAULT') || ...
            strcmpi(lcaGetSmart('BCS:IN20:1:LSSPERM'), 'FAULT');

    end

    function m_faulted = MPS_Is_Faulted()
        % Checks whether the MPS is faulted.
        % Returns [m_faulted] = 0 if the MPS is not faulted.
        % Returns [m_faulted] = 1 if the MPS is faulted.
        
        m_faulted = (strcmpi(lcaGetSmart('IOC:BSY0:MP01:PC_RATE'), '0 Hz') && ...
            strcmpi(lcaGetSmart('IOC:BSY0:MP01:PCELLCTL'), 'Yes')) || ...
            (strcmpi(lcaGetSmart('IOC:BSY0:MP01:MS_RATE'), '0 Hz') && ...
            strcmpi(lcaGetSmart('IOC:BSY0:MP01:MSHUTCTL'), 'Yes')) || ...
            (strcmpi(lcaGetSmart('IOC:BSY0:MP01:BYKIK_RATE'), '0 Hz') && ...
            strcmpi(lcaGetSmart('IOC:BSY0:MP01:BYKIKCTL'), 'Yes'));

        if m_faulted > 0
            
            %disp('m_faulted:')
            %disp(m_faulted)

        end

    end

    function mps_unlatch = MPS_Unlatch_Okay()
       % Returns 1 if we are in a configuration where we can safely unlatch MPS faults.
       % Returns 0 if Guardian or BCS is currently faulted.
       % Returns 0 if any stoppers or OTR screens are in motion.
       % Returns 0 if there's a toroid fault, which we shouldn't unlatch willy-nilly. 
       % Returns 0 if any of the hutches are in a configuration where we shouldn't unlatch faults.
       
       mps_unlatch = ~Guardian_Is_Faulted() && ~BCS_Is_Faulted() && ...
           Stoppers_Okay() && OTRs_Okay() && Toroids_Okay() && ...
           AMO_Okay() && SXR_Okay() && XPP_Okay() && ... 
           XCS_Okay() && CXI_Okay() && MEC_Okay();
        
    end

    function stoppers_unlatch_okay = Stoppers_Okay()
        % Returns 1 if stoppers are in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if TD11 and TDUND are not moving.
        % Returns 0 if TD11 or TDUND is moving.

        stoppers_unlatch_okay =  ~strcmpi(lcaGetSmart('DUMP:LI21:305:TD11_OUT'), lcaGetSmart('DUMP:LI21:305:TD11_IN')) && ...
            ~strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_OUT'), lcaGetSmart('DUMP:LTU1:970:TDUND_IN'));

        if (~stoppers_unlatch_okay)
            disp('Blacklisted MPS fault detected -- stoppers.');
        end
                
    end

    function otrs_unlatch_okay = OTRs_Okay()
        % Returns 1 if OTR screens are in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if no OTR screens are moving and OTRH1/H2 are not in
        % with the LH attenuator out or TDUND out.
        % Returns 0 if any OTR screens are moving or if OTRH1/H2 are in
        % with the LH attenuator out or TDUND out.
        
        otrs_unlatch_okay = ~strcmpi(lcaGetSmart('OTRS:LI21:237:OUT_LMTSW'), lcaGetSmart('OTRS:LI21:237:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:LI21:291:OUT_LMTSW'), lcaGetSmart('OTRS:LI21:291:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:IN20:541:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:541:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:IN20:571:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:571:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:IN20:621:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:621:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:IN20:711:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:711:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:LI25:920:OUT_LMTSW'), lcaGetSmart('OTRS:LI25:920:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:LI24:807:OUT_LMTSW'), lcaGetSmart('OTRS:LI24:807:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:LI25:342:OUT_LMTSW'), lcaGetSmart('OTRS:LI25:342:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:LTU1:449:OUT_LMTSW'), lcaGetSmart('OTRS:LTU1:449:IN_LMTSW')) && ...
            ~strcmpi(lcaGetSmart('OTRS:LTU1:745:OUT_LMTSW_MPS'), lcaGetSmart('OTRS:LTU1:745:IN_LMTSW_MPS')) && ...
            ~strcmpi(lcaGetSmart('OTRS:IN20:465:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:465:IN_LMTSW')) && ...
            (strcmpi(lcaGetSmart('OTRS:IN20:465:OUT_LMTSW'), 'Active') || (strcmpi(lcaGetSmart('FLTR:IN20:130:FLT1_STS'), 'IN')) && ...
            (strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_IN'), 'Active'))) && ...
            (((~strcmpi(lcaGetSmart('OTRS:IN20:471:OUT_LMTSW'), lcaGetSmart('OTRS:IN20:471:IN_LMTSW')) && ...
            strcmpi(lcaGetSmart('OTRS:IN20:471:OUT_LMTSW'), 'Active') || (strcmpi(lcaGetSmart('FLTR:IN20:130:FLT1_STS'), 'IN')) && ...
            (strcmpi(lcaGetSmart('DUMP:LTU1:970:TDUND_IN'), 'Active')))) || ...
            (lcaGetSmart('OTRS:IN20:471:OUT_LMTSW_BYPC') && lcaGetSmart('OTRS:IN20:471:IN_LMTSW_BYPC')));
        
        if (~otrs_unlatch_okay)
            disp('Blacklisted MPS fault detected -- OTR screens.');
        end
        
    end

    function toroids_unlatch_okay = Toroids_Okay()
        % Returns 1 if toroids are not faulted.
        
        toroids_unlatch_okay = strcmpi(lcaGetSmart('TORO:IN20:215:CHASIM11_MPS'), 'OK') && ...
            strcmpi(lcaGetSmart('TORO:IN20:431:CHASIM12_MPS'), 'OK') && ...
            strcmpi(lcaGetSmart('TORO:LI24:1:CHASIMB2_MPS'), 'OK') && ...
            strcmpi(lcaGetSmart('TORO:LTU1:920:IMUNDI_L1_MPS'), 'LEVEL1') && ...
            strcmpi(lcaGetSmart('TORO:LTU1:920:IMUNDI_L2_MPS'), 'LEVEL2') && ...
            strcmpi(lcaGetSmart('TORO:DMP1:198:IMUNDO_L1_MPS'), 'LEVEL1') && ...
            strcmpi(lcaGetSmart('TORO:DMP1:198:IMUNDO_L2_MPS'), 'LEVEL2') && ...
            strcmpi(lcaGetSmart('TORO:IN20:203:TC203L1_MPS'), 'LEVEL_1') && ...
            strcmpi(lcaGetSmart('TORO:IN20:203:TC203L2_MPS'), 'LEVEL_2') && ...
            strcmpi(lcaGetSmart('TORO:LI21:205:TCBC1L1_MPS'), 'LEVEL_1') && ...
            strcmpi(lcaGetSmart('TORO:LI21:205:TCBC1L2_MPS'), 'LEVEL_2') && ...
            strcmpi(lcaGetSmart('TORO:LI24:707:TCBC2L1_MPS'), 'OK') && ...
            strcmpi(lcaGetSmart('TORO:LI24:707:TCBC2L2_MPS'), 'OK') && ...
            strcmpi(lcaGetSmart('TORO:B921:198:CHASIMUND_MPS'), 'IS_ON') && ...
            strcmpi(lcaGetSmart('TORO:IN20:BL215:MPS_STATE_MPS'), 'OUT');

        %        strcmpi(lcaGetSmart('TORO:IN20:971:TC2S1L1_MPS'), 'LEVEL_1') && ...
        %        strcmpi(lcaGetSmart('TORO:IN20:971:TC2S1L2_MPS'), 'LEVEL_2') && ...

        if (~toroids_unlatch_okay)
            disp('Blacklisted MPS fault detected -- toroids.');
        end

    end

    function amo_unlatch_okay = AMO_Okay()
        % Returns 1 if AMO is in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if we're on the hard x-ray line or if shutter S1 is not moving.

        amo_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') < -3000 || ... % We're on the hard x-ray line OR
            ~strcmpi(lcaGetSmart('PPS:NEH1:1:S1STPRSUM'),'INCONSISTENT'); % Shutter S1 is not moving.

        if (~amo_unlatch_okay)
            disp('Blacklisted MPS fault detected -- AMO.');
        end
        
    end

    function sxr_unlatch_okay = SXR_Okay()
        % Returns 1 if SXR is in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if we're on the hard x-ray line or S2 is IN or (OUT and
        % S2B is not moving). Returns 0 otherwise.

        sxr_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') < -3000 || ... % We're on the hard x-ray line OR
            strcmpi(lcaGetSmart('PPS:NEH1:2:S2STPRSUM'),'IN') || ... Shutter S2 is IN OR
            (strcmpi(lcaGetSmart('PPS:NEH1:2:S2STPRSUM'),'OUT') && ... Shutter S2 is OUT AND
            ~strcmpi(lcaGetSmart('PPS:NEH1:3:S2BSTPRSUM'),'INCONSISTENT')); % Shutter S2B is not moving.

        if (~sxr_unlatch_okay)
            disp('Blacklisted MPS fault detected -- SXR.');
        end

    end

    function xpp_unlatch_okay = XPP_Okay()
        % Returns 1 if XPP is in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if we're on the soft x-ray line or SH1 is IN or (SH1 is
        % OUT and there are no un-bypassed PAD detector damage faults).
        % Returns 0 otherwise.
        
        xpp_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
            strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... % Shutter SH1 is IN OR
            (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... % Shutter SH1 is OUT AND
            (strcmpi(lcaGetSmart('XPP:DET:01:MPSFAULT_MPS'),'IS_OK') || ... % No un-bypassed detector damage faults
            strcmpi(lcaGetSmart('XPP:DET:01:MPSFAULT_BYPS'), 'BYPASSED')));

        if (~xpp_unlatch_okay)
            disp('Blacklisted MPS fault detected -- XPP.');
        end

    end

    function xcs_unlatch_okay = XCS_Okay()
        % Returns 1 if XCS is in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if we're on the soft x-ray line or SH1 is IN or (SH1 is
        % OUT and SH2 is IN or (SH2 is OUT and S4 is not moving)). Returns
        % 0 otherwise.
        
        xcs_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
            strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... % Shutter SH1 is IN OR
            (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... % Shutter SH1 is OUT AND
            (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'IN') || ... % Shutter SH2 is IN OR
            (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'OUT') && ... % SH2 is OUT AND
            ~strcmpi(lcaGetSmart('PPS:FEH1:4:S4STPRSUM'),'INCONSISTENT')))); % Shutter S4 is not moving.

        if (~xcs_unlatch_okay)
            disp('Blacklisted MPS fault detected -- XCS.');
        end

    end

    function cxi_unlatch_okay = CXI_Okay()
        % Returns 1 if CXI is in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if we're on the soft x-ray line or SH1 is IN or (OUT and SH2 is IN
        % or (OUT and S5 is IN or (OUT and S5B is IN or (OUT and there are no un-bypassed
        % detector damage faults)))). Returns 0 otherwise.

        cxi_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
            strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... Shutter SH1 is IN OR
            (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... Shutter SH1 is OUT AND
            (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'IN') || ... % Shutter SH2 is IN OR
            (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'OUT') && ... % Shutter SH2 is OUT AND
            (strcmpi(lcaGetSmart('PPS:FEH1:5:S5STPRSUM'),'IN') || ... % Shutter S5 is IN OR
            (strcmpi(lcaGetSmart('PPS:FEH1:5:S5STPRSUM'),'OUT') && ... % Shutter S5 is OUT AND
            (strcmpi(lcaGetSmart('PPS:FEH1:5:S5BSTPRSUM'),'IN') || ... % Shutter S5B is IN OR
            (strcmpi(lcaGetSmart('PPS:FEH1:5:S5BSTPRSUM'),'OUT') && ... % Shutter S5B is OUT AND
            ((strcmpi(lcaGetSmart('CXI:DET:01:MPSFAULT_MPS'),'IS_OK') || ... % No un-bypassed detector damage faults.
            strcmpi(lcaGetSmart('CXI:DET:01:MPSFAULT_BYPS'), 'BYPASSED')) && ...
            (strcmpi(lcaGetSmart('CXI:DET:02:MPSFAULT_MPS'),'IS_OK') || ...
            strcmpi(lcaGetSmart('CXI:DET:02:MPSFAULT_BYPS'), 'BYPASSED'))))))))));
        
        disp(cxi_unlatch_okay)
        disp(lcaGetSmart('PPS:FEH1:5:S5STPRSUM'))

        if (~cxi_unlatch_okay)
            disp('Blacklisted MPS fault detected -- CXI.');
        end

    end

    function mec_unlatch_okay = MEC_Okay()
        % Returns 1 if MEC is in a configuration where we can safely unlatch MPS faults.
        % Returns 1 if we're on the soft x-ray line or SH1 is IN or (SH1 is
        % OUT and SH2 is IN or (SH2 is OUT and S6 is not moving)). Returns
        % 0 otherwise.

        mec_unlatch_okay = lcaGetSmart('STEP:FEE1:1561:ERROR.L') > -3000 || ... % We're on the soft x-ray line OR
            strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'IN') || ... % Shutter SH1 is IN OR
            (strcmpi(lcaGetSmart('PPS:NEH1:3:SH1STPRSUM'),'OUT') && ... % Shutter SH1 is OUT AND
            (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'IN') || ... % Shutter SH2 is IN OR
            (strcmpi(lcaGetSmart('STPR:XRT1:1:SH2_PPSSUM'),'OUT') && ... % SH2 is OUT AND
            ~strcmpi(lcaGetSmart('PPS:FEH1:6:S6STPRSUM'),'INCONSISTENT')))); % Shutter S6 is not moving.

        if (~mec_unlatch_okay)
            disp('Blacklisted MPS fault detected -- MEC.');
        end

    end

    function faultedVVS = VVS_Faulted()
        % Returns an array with the names of LCLS VVSs w/open breakers.
        % Returns an empty array if all VVS breakers are closed.
        % (~0.008s)
        
        faultedVVS = {};
        numfaulted = 0;
        
        % Collect current VVS statuses
        statuses = { ...
            char(lcaGetSmart('VVS:LI20:1:BREAKER_MPSC')) 'VVS 10'; ...
            char(lcaGetSmart('VVS:LI22:1:BREAKER_MPSC')) 'VVS 11'; ...
            char(lcaGetSmart('VVS:LI24:1:BREAKER_MPSC')) 'VVS 12'; ...
            char(lcaGetSmart('VVS:LI26:1:BREAKER_MPSC')) 'VVS 13'; ...
            char(lcaGetSmart('VVS:LI28:1:BREAKER_MPSC')) 'VVS 14'; ...
            char(lcaGetSmart('VVS:LI30:1:BREAKER_MPSC')) 'VVS 15'; ...
        };
        
        % Add faulted VVSs to the faultedVVS array
        i = 1;
        while i < 7 && Permits_Okay()
            if ~any(strcmp(statuses(i,1), {'READY' 'OK'}))
                numfaulted = numfaulted + 1;
                faultedVVS(numfaulted,1) = statuses(i,2);
            end
            i = i + 1;
        end
        
    end

    function faultedKLYS = KLYS_Faulted()
        % Returns an array with the names of LCLS klystrons currently on
        % the beam w/mod faults. Returns an empty array if no klystrons
        % on the beam are mod faulted.
        % Update: This function is now taking 15.3 seconds to execute. Why?
        % The line with [act, ...] is responsible for 15.1 secs of delay.

        faultedKLYS = {};
        numfaulted = 0;
        
        % Get current complement and associated statuses (note - doesn't
        % get L0 and L1 properly yet). Henrik knows why, ask him when I'm
        % ready to fix this.
        names = model_nameConvert(model_nameRegion({'GUN' 'ACCL' 'KLYS'}, {'L0' 'L1' 'L2' 'L3'}), 'MAD');
        [act, stat, swrd, hdsc, dsta, enld] = control_klysStatGet(names);
        
        % Find stations that are on the beam (act bit 1 = true) and have
        % mod faults (swrd bit 4 = true)
        badstations = (bitget(act, 1) .* bitget(swrd,4));
        
        % Add faulted stations to the faultedKLYS array
        numstations = size(names);
        i = 1;
        while i <= numstations(1,1) && Permits_Okay()
            if badstations(i,1)
                numfaulted = numfaulted + 1;
                faultedKLYS(numfaulted,1) = names(i,1);
            end            
            i = i + 1;
        end
        
    end


% Action-taking functions.
    function Display(message, append)
        % Displays messages in MCC_Hammer's message box.
        % If [append] == 0, replaces message box text with new message.
        % If [append] ~= 0, appends new message to message box text.
        % Message box can contain 14 lines of text.

        if append
            % Horrible craptastic code. Maybe I'll clean this
            % up when I bother to learn about cell arrays.

            oldmessage = get(MessageBox, 'String');
            oldsize = size(oldmessage);
            addedsize = size(message);
            oldplusadded = oldsize(1,1) + addedsize(1,1);

            if oldplusadded < 14
                % Message box won't be filled with text when we add the new
                % message
                
                newmessage = cell(oldplusadded, 1);

                for m = 1:oldplusadded

                    if m <= oldsize(1,1)

                        newmessage(m,1) = oldmessage(m,1);

                    else

                        newmessage(m,1) = message(m - oldsize(1,1), 1);

                    end

                end
                
            else
                % Message box will be filled with text - need to truncate
                % lines from oldmessage
                
                newmessage = cell(14,1);
                extralines = oldsize(1,1) + addedsize(1,1) - 14;

                for m = 1:14

                    if (m + extralines) <= oldsize(1,1)

                        newmessage(m,1) = oldmessage((m + extralines),1);

                    else

                        newmessage(m,1) = message(m + addedsize(1,1) - 14,1);

                    end

                end

            end

            set(MessageBox, 'String', newmessage);

        else

            set(MessageBox, 'String', message);

        end

    end

    function Prepare_To_Start()
        % Reconfigures uicontrols to reflect that MCC_Hammer is not running
        % anywhere and can be started here.
        
        set(Start,'Enable','on');
        set(Start,'String','Start');
        set(Stop,'Enable','off');
        
    end

    function Prepare_To_Stop()
        % Reconfigures uicontrols to reflect that MCC_Hammer is running
        % somewhere and can be stopped here.
        
        set(Start,'Enable','off');
        set(Start,'String','Running...');
        set(Stop,'Enable','on');
        
    end

    function Respond_To_Guardian()
        % Warns the user of the Guardian fault and waits for it to clear.
        % Stops immediately if any of the permits disappear.
        % Should probably modify this to give more information on the
        % machine setup at the time of the fault.

        Display({'***************** GUARDIAN FAULT *****************'}, 1)

        while Guardian_Is_Faulted() && Permits_Okay()

            pause(0.02);

        end

        Display({'Yo, sound the bell - school is in, suckah!'}, 1)

    end

    function Respond_To_BCS()
        % Warns the user of the BCS fault and waits for it to clear.
        % Stops immediately if any of the permits disappear.
        % Should probably modify this to give more information on the
        % machine setup at the time of the fault.

        Display({'******************** BCS FAULT ********************'}, 1)

        while BCS_Is_Faulted() && Permits_Okay()

            pause(0.02);

        end

        Display({'Yo, sound the bell - school is in, suckah!'}, 1)

    end

    function Respond_To_MPS()
        
        if MPS_Unlatch_Okay()

            % First step - save the time interval since the last unlatch
            RECENT_INTERVALS(mod(N_UNLATCHES,BYKIK_NUMFAULTS-1)+1)= toc;
            % Display the array of intervals in the XTERM window for debugging
            disp('Recent intervals between MPS trips:')
            disp(RECENT_INTERVALS)
            
            if (max(RECENT_INTERVALS) < UNLATCH_INTERVAL)
                % We've unlatched too many faults in the recent past.
                
                if ~strcmpi(lcaGetSmart('IOC:BSY0:MP01:BYKIKCTL'), 'Yes')
                    % If BYKIK is already on, we shouldn't mess around with
                    % it.
                    
                    if ~get(NeverGiveUp,'Value')
                        % If the NeverGiveUp box is not checked, we're out of
                        % options - warn the user and stop automation.
                        
                        % Reset the array of intervals
                        RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;

                        Display({'Beam won''t run to BYKIK - stopping MCC_Hammer!'},1);
                        lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
                        return

                    else
                        % If the NeverGiveUp box is checked, unlatch the fault.

                        Unlatch()
                        return

                    end
                    
                else
                    % If BYKIK is not on, apply it for two seconds to give
                    % feedbacks time to converge.
                    
                    % Reset the array of intervals
                    RECENT_INTERVALS = ones(1,BYKIK_NUMFAULTS-1)*2*UNLATCH_INTERVAL;
                    
                    % Apply BYKIK
                    lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',0);
                    Unlatch()
                    Display({'STOP!'}, 1)
                    WatchAndWait(0.5,1); % Initial pause while MPS unlatches
                    result = WatchAndWait(1.5,0);
                    lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',1);
                    Display({'Hammer time!'}, 1)
                    
                    switch result
                        case 0
                            % Ran smoothly, proceed to recovery.
                        case 1
                            % Guardian fault, return to main
                            return
                        case 2
                            % BCS fault, return to main
                            return
                        case 3
                            % MPS fault.
                            if ~get(NeverGiveUp,'Value')
                                % NeverGiveUp box not checked - warn user, halt automation.
                                Display({'Beam won''t run to BYKIK - stopping MCC_Hammer!'},1);
                                lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
                                return
                            else
                                % NeverGiveUp box checked - return to main,
                                % will continue to unlatch.
                                return
                            end
                        case 4
                            % Lost a permit, return to main
                            return
                        otherwise
                            % Error state.
                            Display({'Something went wrong. Please email bripman.'},1);
                            return
                    end

                    % Now check whether anything trips after going down to
                    % the dump again.
                    WatchAndWait(0.5,1);
                    result = WatchAndWait(1.5,0);

                    switch result
                        case 0
                            % Ran smoothly.
                        case 1
                            % Guardian fault, return to main
                            return
                        case 2
                            % BCS fault, return to main
                            return
                        case 3
                            % MPS fault.
                            if ~get(NeverGiveUp,'Value')
                                % Warn user, halt automation.
                                Display({'Beam won''t run to dump - stopping MCC_Hammer!'},1);
                                lcaPutSmart('SIOC:SYS0:ML00:AO866',0);
                                return
                            else
                                % Just return to main (will continue to
                                % unlatch)
                                return
                            end
                        case 4
                            % Lost a permit, return to main
                            return
                        otherwise
                            % Error state.
                            Display({'Something went wrong. Please email bripman.'},1);
                            return
                    end
                    
                end

            else
                % Haven't unlatched much recently, so just unlatch the fault.

                Unlatch()

            end

        end

    end

    function Unlatch()
        % Stores time since last unlatch, unlatches current MPS fault,
        % updates a PV that tracks number of MPS events. Waits 0.5 seconds
        % before returning to the automation loop to allow the mechanical
        % shutter time in which to come out.
        
        % Save the time interval since last unlatch (overwrites previous value
        % if Unlatch() is called from Respond_To_MPS()) - this behavior is
        % intentional.
        RECENT_INTERVALS(mod(N_UNLATCHES,BYKIK_NUMFAULTS-1)+1)= toc;
        
        lcaPutSmart('IOC:BSY0:MP01:UNLATCHALL',1);
        
        if (RECENT_INTERVALS(mod(N_UNLATCHES,BYKIK_NUMFAULTS-1)+1) > 5)
            % Increments a PV whenever a distinct MPS event occurs, defined as
            % a trip with no unlatches in the last 5 seconds.

            lcaPutSmart('SIOC:SYS0:ML02:AO007', lcaGetSmart('SIOC:SYS0:ML02:AO007') + 1);

        end

        N_UNLATCHES = N_UNLATCHES + 1;
        Display({datestr(clock, 13); 'You can''t touch this'}, 1);
        tic
        WatchAndWait(0.5, 1);

    end

    function result = WatchAndWait(period, ignoreMPS)
        % Waits for [period] seconds, watching for various issues
        % (and checking that the permits still exist).
        %
        % If [ignoreMPS] = 0, WatchAndWait will halt immediately if the MPS trips
        % If [ignoreMPS] ~= 0, WatchAndWait will not halt if the MPS trips
        %
        % Returns [result] = 0 if the beam stays on for [period]
        % seconds with no faults of any kind.
        % Returns [result] = 1 immediately if there's a Guardian fault.
        % Returns [result] = 2 immediately if there's a BCS fault.
        % Returns [result] = 3 immediately if there's an MPS fault.
        % Returns [result] = 4 immediately if any of the permits are taken away
        % during the waiting period.

        result = 0;

        for i=1:(50*period)

            pause(0.02);

            if ~Permits_Okay()

                result = 4;
                return

            end

            if Guardian_Is_Faulted()

                result = 1;
                return

            end

            if BCS_Is_Faulted()

                result = 2;
                return

            end

            if MPS_Is_Faulted() && ~ignoreMPS

                result = 3;
                return

            end

        end

    end


end
