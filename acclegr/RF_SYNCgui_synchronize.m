%% AUTOMATED PROGRAM TO SYNCHRONIZE LCLS LLRF

% Program name: RF_SYNCgui_synchronize.m
% written:      Vojtech Pacak
% Development started:    Jan-11-2008

% Version 1: Finished. Jan-15-2008
% Version 2: Running under the GUI finished. Jan-22-2008
% Version 3: Uses pre-defined I and Q values for MDL setup. Mar-3-2008
% Version 4: Added the setup of 119MHz Laser Phase. Apr-3-2008
% Version 5: Rewrote adjustment of the MDL phase, (= -168 deg), adjusted
%   by EPICS by entering -168 into the "desired phase" PV. Jun-24-2008
% Version 6: Check for 25.5MHz phase deviate from zero. Jun-25-2008
% Version 7: Removed bugs related to using the STOP button; keep polar
%   graph on GUI to finish the full rotation; rotation counter displays the
%   correct number of rotation. Oct-16-2008
% Version 8: Added "pause(1)" commands at different locations in order the
%   PV's have time to update. Changed FIDO to EVG. Added "drawnow" commands
%   to make the "disp" function reliable. May-13-2009 - Jun-29-2009
% Version 9: Changed "pause(1)" commands to pause(2.5).
%   Turning Laser feedback OFF during first part of the program. Jul-9-2009
%
%******NOTE: The Version Number has been changed to agree with the CVS
%****** revision number.***************************************************
%
% Version 17: The "slow" updated phase PVs changed for the equivalent fast
%   updating PV names. The new PVs' rate of updating is at least 10 Hz.
%   The 2.5 sec pauses in the the function 1 and 3 changed to 0.2 sec.
%   Disabled the adjustment of the MDL phase. MDL_DES value is not changing
%   by more than couple of degrees during the last six months.  Jul-15-2009
% Update: Jul-15-2009
% *******************
% Version 18: Changed the MDL_DES Phase from -143 to -158 deg.
% Update: May-5-2010
%*******************
% Version 19: Uncomment the "fdb_gain" initial assignment. Even if the
% program is not using this PV anymore, it caused the program bomb. This PV
% should be completely removed in the future versions
% Update: May-13-2010
%*******************
% Version 20:
%Removed "fdb_gain", added missing variable "pv_fdb" into the "stop_sync"
%function.
% Update: Oct-18-2010
%*******************
% Version 21:
% Display the original MDL_DES value when MDL phase change larger than 5 deg.
% Update: Apr-8-2011
%*******************
% Version 22:
% Place a timestamp, date and time at the start of the program.
% Update: Apr-27-2012
%*******************
% Version 23:
% Added watchdog to check if program is already running elsewhere.
% Update: Jun-8-2012
%*******************
% Version 24:
% Changed MDL desired phase target from -158>-110; disabled the second part
% of the program - Laser Phase Adjustment. It was not working for the
% Coherent laser.
% Update: Oct-11-2012
%*******************
% Version 25:
% Changed MDL desired phase target back to original value of -158.
% Update: Oct-26-2012
%*******************

%% Program Name
function RF_SYNCgui_synchronize(hObject, eventdata, handles)

%% Reset the handles.Return
handles.Return = 0;
guidata(handles.output,handles);

%% Define all the PV's
pvNames = {                               %PVs for LLRF synchronization
    'LLRF:IN20:RH:MDL_I_ADJUST'
    'LLRF:IN20:RH:MDL_Q_ADJUST'
    'LLRF:IN20:RH:RFR_I_ADJUST'
    'LLRF:IN20:RH:RFR_Q_ADJUST'
    'LLRF:IN20:RH:REF_3_PACT'
    'LLRF:IN20:RH:REF_2_PACT'
    'LASR:IN20:1:LSR_3_PACT'
    'SIOC:SYS0:ML00:AO001'
    'LLRF:IN20:RH:REF_2_PDES'
    };

MDL_send_to_PAC =   {'LLRF:IN20:RH:REF_2_SEND'}; % MDL I & Q send to PAC
REF_send_to_PAC =   {'LLRF:IN20:RH:REF_0_SEND'}; % REF I & Q send to PAC

%PVs for 119MHz laser phase lock
pv_fdb =           {'SIOC:SYS0:ML02:AO476.DESC'}; %local laser feedback
pv_IQ_send =       {'LASR:IN20:1:LSR_SEND'}; % I & Q send to PAC
pv_lasr_ampl_lim = {'LASR:IN20:1:LSR_2_S_AA.LOLO'}; %min limit for lsr ampl
pv_lasr_ampl =     {'LASR:IN20:1:LSR_2_S_AA'}; %ampli of 119MHz laser
pv_lasr_phas =     {'LASR:IN20:1:LSR_2_S_PA'}; %phase of 119MHz laser
pv_fdbk_input =    {'LASR:IN20:1:LSR_SOURCE'}; %switch 119 or 2856MHz input
pv_pdes_119 =      {'LASR:IN20:1:LSR_PDES119'};%desired value of 119MHz phase
pv_zeroing_476 =   {'LASR:IN20:1:LSR_ZEROING'};%zeroing of 476MHz
pv_new_stpt =      {'LASR:IN20:1:LSR_S_PS'}; % new set point for 476MHz

% Adjustment target limits for MDL I_Q; RF Ref I_Q; 25.5; 119EVG; 119LCLS
% phases; MDL_DES phase.
target_setpoint = [-15650;-3325;0;0;3;8;45;-158];
watchdog_cycle = 1;
Text_2 = ['Test if other program is running'];
Text_3 = ['Program already running-restart later'];

%% Check the value of MDL_DES phase within limits and re-confirm start
MDL_desired_phase = round(lcaGet(pvNames(9))); %current value of MDL_DES

if abs(MDL_desired_phase-target_setpoint(8)) > 5
    disp(' ')
    disp(['MDL phase is more than 5 deg different from the last operating'...
        ' value of ',num2str(target_setpoint(8)),' deg'])
    disp(' ')
    start_sync = questdlg(['MDL PHASE CHANGED BY MORE THAN 5 DEG, FROM ',...
        num2str(target_setpoint(8)),' TO ',num2str(MDL_desired_phase),...
        ' deg. THE PROGRAM MAY NOT WORK PROPERLY. DO YOU WANT TO CONTINUE?'],...
        'MDL PHASE WARNING','YES', 'NO', 'NO');

    if strcmp(start_sync,'YES')
    else
        set(handles.s,'string','START');
        disp('PROGRAM EXECUTION TERMINATED')
        disp(' ')
        return
    end

    %Checking if other program running
    set(findobj('Tag','text18'),'Visible','ON','String',Text_2);
    W = watchdog('SIOC:SYS0:ML00:AO245', watchdog_cycle, 'RF_SYNCgui');
    if get_watchdog_error(W)
        disp('Program is already running');
        set(findobj('Tag','text18'),'Visible','ON','String',Text_3);
        set(handles.s,'string','START');
        return
    end
    disp(['RF_SYNC BEGINS:  ',datestr(now)])
    disp(' ')
else
    disp(' ')
    disp('MDL_DES within limits')
    disp(' ')

    % Once more confirm start of the program
    start_sync = questdlg('BEGIN PROGRAM EXECUTION?','START CONFIRMATION',...
        'YES','NO','YES');
    if strcmp(start_sync,'YES')
    else
        set(handles.s,'string','START');
        disp(' ')
        disp('PROGRAM EXECUTION TERMINATED')
        disp(' ')
        return
    end

    %Checking if other program running
    set(findobj('Tag','text18'),'Visible','ON','String',Text_2);
    W = watchdog('SIOC:SYS0:ML00:AO245', watchdog_cycle, 'RF_SYNCgui');
    if get_watchdog_error(W)
        disp('Program is already running');
        set(findobj('Tag','text18'),'Visible','ON','String',Text_3);
        set(handles.s,'string','START');
        return
    end
    disp(['RF_SYNC BEGINS:  ',datestr(now)])
    disp(' ')
end % if MDL_DES phase within limits

set(findobj('Tag','text18'),'Visible','OFF'); % clear GUI text
pause(0.01)

%% BEGINNING OF THE SYNC PROGRAM
%%%************************************************************************
lcaPut(pv_fdb,{'OFF'});               %Turn OFF Laser feedback
lcaPut(MDL_send_to_PAC,{'Disabled'}); %disable the MDL I&Q PAC
lcaPut(REF_send_to_PAC,{'Disabled'}); %disable the REF I&Q PAC
disp(' ')
disp('LASER FEEDBACK OFF')
disp('MDL PAC SEND DIABLED')
disp('REF PAC SEND DISABLED')
disp(' ')
pause(2)


% Step (I) - rotating the MDL phase - has been removed
%**************************************************************************
%% (II) Check the status and adjust the 25.5 MHz phase
inival = round(lcaGet(pvNames(1:7))); %update phase values
drawnow
handles=guidata(handles.output); %update handles from the GUI
set(findobj('Tag','text3'),'visible','on')
set(handles.Num_rot,'visible','on','String','0')
set(handles.Ph_25,'String',num2str(inival(5)));
set(handles.Ph_119_F,'String',num2str(inival(6)));
set(handles.Ph_119_L,'String',num2str(inival(7)));
drawnow
new_I_Q = inival;
k=0; % counter of completed full phase rotations
l=3; % switch between REF RF I & Q (l=3,4) and MDL I and Q (l=1,2)
m=2; % switch to select "condition" in functions 1=MDL, 2=25.5, 3=EVG, 4=LCLS
n=12; % number of 30deg steps for a complete circle phase rotation

if abs(inival(5)) > target_setpoint(5) %Check status of 25.5 MHz phase
    set(handles.Ph_25,'backgroundcolor','y')
    disp('ADJUSTING 25.5MHz PHASE')
    disp(' ')
    drawnow
    if (inival(5)>80 && inival(5)<100)
        phase_step = -30; %  CW rotation
    else
        phase_step = 30;  % CCW rotation
    end
    % call the function 1 to rotate the RF Ref I and Q
    [new_I_Q,k,W] = rotate_phase_1(pvNames,inival,target_setpoint,l,m,n,...
        handles,phase_step,W);

    handles = guidata(handles.output); % get updated handles from GUI
    if handles.Return
        handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
        return
    end
else
end % first if: "if abs(inival(5)) > target_setpoint(5)"
W=watchdog_run(W);
pause(2) % pause just in case...
disp(['25.5MHz Phase is synchronized after ',num2str(k),...
    ' full circle RF Ref rotations'])
disp(['25.5MHz phase = ',num2str(new_I_Q(5)),' deg'])
disp(' ')
drawnow

%**************************************************************************
%% (III) Check the status and adjust the 119EVG phase
inival = round(lcaGet(pvNames(1:7))); %update phase values
drawnow
handles=guidata(handles.output); %update handles from the GUI
set(handles.Num_rot,'String','0')
set(handles.Ph_25,'String',num2str(inival(5)));
set(handles.Ph_119_F,'String',num2str(inival(6)));
set(handles.Ph_119_L,'String',num2str(inival(7)));
drawnow
new_I_Q = inival;
k=0;
l=3; % rotate REF RF
m=3; % selected condition to check EVG -> target_value
n=12; % number of 30deg steps for a complete circle phase rotation

if abs(inival(6)) > target_setpoint(6) %Check status of 119EVG phase
    set(handles.Ph_119_F,'backgroundcolor','y')
    disp('ADJUSTING 119 MHz EVG PHASE')
    disp(' ')
    drawnow
    if exist('phase_step','var')  % rotate in the same direction as 25.5MHz
    else
        if inival(6) > 0
            phase_step = -30; % CW  rotation
        else
            phase_step =  30; % CCW rotation
        end
    end
    % Go to function 3 to rotate the RF Ref I and Q
    [new_I_Q,k,phase_step,Flag,W] = rotate_phase_3(pvNames,inival,...
        target_setpoint,l,m,n,handles,phase_step,W);

    handles = guidata(handles.output); % get updated handles from GUI
    if handles.Return
        handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
        return
    end

    %% Return to adjust 25.5 MHz if Flag was set in "rotate_phase_3". Flag
    %  is set ON when 25.5 phase gets outside the target limit during the
    %  119EVG phase adjustment
    if Flag
        %% adjusting 25.5
        W=watchdog_run(W);
        pause(2) % pause just in case...
        inival = round(lcaGet(pvNames(1:7))); %update phase values
        set(handles.Ph_25,'backgroundcolor','y')
        set(handles.Ph_119_F,'backgroundcolor','w')
        set(handles.Num_rot,'visible','on','String','0')
        m = 2; %have to do this, selected condition to check 25.5->target_value
        disp('25.5 MHz PHASE SHIFTED')
        disp('RETURNED TO ADJUST 25.5MHz PHASE')
        disp(' ')
        drawnow

        %% Go to the phase rotation function 1
        [new_I_Q,k,W] = rotate_phase_1(pvNames,inival,target_setpoint,l,m,n,...
            handles,phase_step,W);
        %% Program continues
        handles = guidata(handles.output); % get updated handles from GUI
        if handles.Return
            handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
            return
        end
        W=watchdog_run(W);
        pause(2) % pause just in case...
        disp(['25.5MHz Phase is synchronized after ',num2str(k),...
            ' full circle RF Ref rotations'])
        disp(['25.5MHz phase = ',num2str(new_I_Q(5)),' deg'])
        disp(' ')
        drawnow

        %% Return to 119EVG phase adjustment - second round
        inival = round(lcaGet(pvNames(1:7))); %update phase values
        pause(0.1)
        handles=guidata(handles.output); %update handles from the GUI
        set(handles.Num_rot,'String','0')
        set(handles.Ph_25,'String',num2str(inival(5)));
        set(handles.Ph_119_F,'String',num2str(inival(6)));
        set(handles.Ph_119_L,'String',num2str(inival(7)));
        drawnow
        new_I_Q = inival;
        k=0;
        l=3; % rotate REF RF
        m=3; % selected condition to check EVG -> target_value
        n=12; % number of 30deg steps for a complete circle phase rotation

        if abs(inival(6)) > target_setpoint(6) %Check status of 119EVG phase
            set(handles.Ph_119_F,'backgroundcolor','y')
            disp('ADJUSTING 119 MHz EVG PHASE')
            disp(' ')
            drawnow
            %% Go to the phase rotation function 3
            [new_I_Q,k,phase_step,Flag,W] = rotate_phase_3(pvNames,inival,...
                target_setpoint,l,m,n,handles,phase_step,W);
            %% Program continues
            handles = guidata(handles.output); % get updated handles from GUI
            if handles.Return
                handles = stop_sync(handles,MDL_send_to_PAC,...
                    REF_send_to_PAC,pv_fdb);
                return
            end
        else
        end % second if: "if abs(inival(6)) > target_setpoint(6)"
    end % if Flag
else
end % first if:  "if abs(inival(6)) > target_setpoint(6)"

W=watchdog_run(W);
pause(1) % pause just in case...
disp(['119 MHz EVG Phase is synchronized after ',num2str(k),...
    ' full circle RF Ref rotations'])
disp(['119 MHz phase = ',num2str(new_I_Q(6)),' deg'])
disp(' ')
drawnow

%**************************************************************************
%% (IV) Check the status and adjust the 119LCLS phase
inival = round(lcaGet(pvNames(1:7))); %update phase values
drawnow
handles=guidata(handles.output); %update handles from the GUI
set(handles.Num_rot,'String','0')
set(handles.Ph_25,'String',num2str(inival(5)));
set(handles.Ph_119_F,'String',num2str(inival(6)));
set(handles.Ph_119_L,'String',num2str(inival(7)));
drawnow
new_I_Q = inival;
k=0;
l=3;  % rotate REF RF I & Q
m=4;  % selected condition to check 119LCLS -> target_value
n=72; % number of 30deg steps for a complete 6 circles REF phase rotation

if abs(inival(7)) > target_setpoint(7) %Check status of 119LCLS phase
    set(handles.Ph_119_L,'backgroundcolor','y')
    disp('ADJUSTING 119 MHz LCLS PHASE')
    disp(' ')
    drawnow
    phase_step = 30;
    %Go to phase rotation function 1
    [new_I_Q,k,W] = rotate_phase_1(pvNames,inival,target_setpoint,l,m,n,...
        handles,phase_step,W);
    handles = guidata(handles.output); % get updated handles from GUI
    if handles.Return
        handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
        return
    end
else
end
W=watchdog_run(W);
pause(2) % pause just in case...
disp(['119 MHz LCLS Phase is synchronized after ',num2str(k),...
    'x6 full circle RF Ref rotations'])
disp(['119 MHz LCLS phase = ',num2str(new_I_Q(7)),' deg'])
disp(' ')
drawnow

%% Enable REF and MDL PACs
lcaPut(MDL_send_to_PAC,{'Enabled'}); %  enable the MDL I&Q PAC
lcaPut(REF_send_to_PAC,{'Enabled'}); %  enable the REF I&Q PAC
lcaPut(pv_fdb,{'ON'}); %Turn ON Laser feedback
pause(0.05)
disp('LASER FEEDBACK ON')
disp(' ')
disp('LLRF SYNCHRONIZATION DONE WITHIN THE TARGET LIMITS')
disp(' ')
drawnow

%% Laser Phase sync part of the program temporarily disabled
% %% Question dialog if to continue with 119 MHz Laser setup
% start_119_laser = questdlg('CONTINUE 119MHz LASER SETUP?','START 119 MHz LASER SETUP');
% if strcmp(start_119_laser,'Yes')
% else
%     set(handles.s,'string','START');
%     %lcaPut(pvNames(9),MDL_desired_phase); %restore the original MDL phase
%     pause(0.05)
%     guidata(handles.output,handles); %updates handles
%     disp(' ')
%     disp('LLRF SYNCHRONIZATION FINISHED SUCCESSFULLY')
%     disp('SKIPPING 119 MHZ LASER SETUP')
%     disp(' ')
%     drawnow
%     return
% end

%% temporarily modified RFSync end, skipping laser phase adjustment
%h = helpdlg(['The Laser phase sync does not work for Coherent laser.',...
%    'It is temporarily disabled.'],'Laser 119 MHz Phase Setup');
set(handles.s,'string','START');
%lcaPut(pvNames(9),MDL_desired_phase); %restore the original MDL phase
pause(0.05)
guidata(handles.output,handles); %updates handles
disp(' ')
disp('LLRF SYNCHRONIZATION FINISHED SUCCESSFULLY')
disp('SKIPPING 119 MHZ LASER SETUP')
disp(' ')
drawnow
return


%%%************************************************************************
%%%************************************************************************
%% SECOND PART OF THE PROGRAM -119 MHZ LASER PHASE CHECK AND SETUP
%%%************************************************************************
%%%************************************************************************
%% Remove the phase graph from GUI and display information text
set(handles.polar_plot,'position',[100,100,1,1]); %shifts graph out of GUI
set(findobj('Tag','text18'),'Visible','ON','String',handles.Text);

%% Set the local feedback, check laser amplitude, stop program if laser off
disp('CHECK IF THE LASER IS RUNNING')
disp(' ')
drawnow
lcaPut(pv_fdb,{'ON'});
lcaPut(pv_IQ_send,{'Enabled'});
drawnow
ampl_lasr_limit = lcaGet(pv_lasr_ampl_lim);
ampl_lasr       = lcaGet(pv_lasr_ampl);
if ampl_lasr < ampl_lasr_limit
    set(findobj('Tag','text18'),'Visible','ON','String',...
        'LASER IS NOT RUNNING, ACTIVATE LASER FIRST')
    handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
    disp('!!! LASER IS NOT RUNNING, ACTIVATE THE LASER FIRST')
    disp('    AND THEN RE-START THE PROGRAM !!!')
    disp (' ')
    drawnow
    return
end

%% Check the laser 119MHz phase stability
% First acquire 5 phase samples
disp('CHECKING THE LASER 119MHz PHASE STABILITY')
disp(' ')
drawnow
lcaSetMonitor(pv_lasr_phas); % set the monitor
buffer = zeros(5,1);
k = 1;
while k < 6
    W=watchdog_run(W);
    flag = lcaNewMonitorValue(pv_lasr_phas); %wait for the next value
    if ~flag
    else
        try
            buffer(k) = lcaGet(pv_lasr_phas);
        catch
            disp('Channel Access Failed')
        end
        k = k + 1;
    end
end
rel_err = std(buffer);
if abs(rel_err) > 5
    set(findobj('Tag','text18'),'Visible','ON','String',...
        'LASER IS NOT LOCKED, LOCK LASER FIRST')
    handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
    disp('!!! LASER IS NOT LOCKED, LOCK THE LASER FIRST')
    disp('    AND THEN RE-START THE PROGRAM !!!')
    disp (' ')
    drawnow
    return
end

%% Check the value of "stabile" laser phase and adjust if necessary
%  This is the main loop correcting the 119 MHz laser phase
try
    laser_phase_119 = lcaGet(pv_lasr_phas);
catch
    disp('Channel Access Failed')
end
if -5 < laser_phase_119 && 10>laser_phase_119
    EndOfProgram(handles,MDL_send_to_PAC,...
        REF_send_to_PAC)
    return
else
    disp('CORRECTING THE 119 MHz LASER PHASE')
    disp('BE PATIENT, THIS MAY TAKE A WHILE')
    disp('IF YOU WISH TO EXIT, PUSH THE STOP BUTTON ON THE GUI')
    disp(' ')
    drawnow

    lcaPut(pv_fdbk_input,{'119MHz Lsr Osc'}) %switch fdbk input to 119MHz
    try
        desir_phase_119 = lcaGet(pv_pdes_119); %desired 119MHz phase value
    catch
        disp('Channel Access Failed')
        %lcaPut(pvNames(9),MDL_desired_phase); %restore the original MDL phase
        disp('CANNOT READ THE 119 MHz DESIRED PHASE')
        disp('PROGRAM TERMINATES, LASER FEEDBACK INPUT STILL 119 MHZ!!!')
        disp('PRESS "STOP" AND THEN RE-START PROGRAM')
        disp(' ')
        drawnow
        return
    end %try-catch
    while abs(desir_phase_119 - laser_phase_119) > 1
        W=watchdog_run(W);
        laser_phase_119 = lcaGet(pv_lasr_phas);
        if handles.Return
            handles = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb);
            return
        end %if
        pause(2)
    end %while, 119MHz phase is now within 1 degree of the desired value
end %if

%% Check if 476 MHz phase is within limits before switchin back to 2856MHz
disp('CHECKING 476 MHz PHASE')
disp(' ')
drawnow
try
    phase_476 = lcaGet([pv_zeroing_476;pv_new_stpt]);
catch
    disp('Channel Access Failed')
end %try-catch

if abs(phase_476(1) - phase_476(2)) < 15
    %do nothing
else
    disp('476 MHz PHASE HAS SHIFTED, ENTERING CURRENT PHASE SETPOINT')
    disp(' ')
    drawnow
    try
        lcaPut(pv_zeroing_476,round(phase_476(2)));
    catch
        disp('Channel Access Failed')
        %lcaPut(pvNames(9),MDL_desired_phase); %restore the original MDL phase
        disp('PROGRAM TERMINATES, LASER FEEDBACK INPUT STILL 119 MHZ!!!')
        disp('PRESS "STOP" AND THEN RE-START PROGRAM')
        disp(' ')
        drawnow
        return
    end %try-catch
end

%% Switch the feedback input source back to 2856 MHz
disp('SWITCHING BACK THE FEEDBACK INPUT TO 2856MHz SOURCE')
disp(' ')
drawnow
lcaPut(pv_fdbk_input,{'2856MHz Lsr Os'}) %switch fdbk input to 2856MHz
pause(1)

%% Call closing function
EndOfProgram(handles,MDL_send_to_PAC,REF_send_to_PAC)
return

%%%************************************************************************
%%%************************************************************************
%%  F U N C T I O N S
%%%************************************************************************
%%%************************************************************************

%% Main Function to adjust MDL, 25.5MHz, 119MHz-LCLS      - FUNCTION 1
%  When adjusting 25.5 and 119 function rotates REF RF phase
function [new_I_Q,k,W] = rotate_phase_1(pvNames,inival,target_setpoint,l,m,n,...
    handles,phase_step,W)

%calculate initial amplitude and phase
Ampl = sqrt(inival(l)^2+inival(l+1)^2);
Phase= atan2(inival(l+1),inival(l))*180/pi;
k=0;
new_I_Q=inival; %first value of new_I_Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if m == 1
    set(findobj('tag','text11'),'visible','on','string','MDL Phase Rotation');
else
    set(findobj('tag','text11'),'visible','on','string','RF Ref Phase Rotation');
end

%activate the polar plot on the GUI
[x1,y1]=pol2cart(Phase*pi/180,1);
set(gca,'FontSize',1);
%plot initial phase vector
hold off
f=compass(x1,y1,'r');
set(handles.polar_plot,'position',handles.graph_position);
set(f,'LineWidth',3);
hold on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setup condition for exiting from phasing loop when within the target_setpoint
%condition 1=MDL, 2=25.5, 3=EVG, 4=LCLS, condition(1) currently never used
condition={abs(new_I_Q(1)-target_setpoint(1))<3500 && ...
    abs(new_I_Q(2)-target_setpoint(2))<3500;...
    abs(new_I_Q(5))<target_setpoint(5);abs(new_I_Q(6))<target_setpoint(6);...
    abs(new_I_Q(7))<target_setpoint(7)};

while ~condition{m}  %reset polar display for RF_Ref after rotating the MDL
    W=watchdog_run(W);
    if m == 4
        hold off
        f=compass(x1,y1,'r');
        set(handles.polar_plot,'position',handles.graph_position);
        set(f,'LineWidth',3);
        hold on
    end
    for c = 1:n
        W=watchdog_run(W);
        Phase = Phase + phase_step;
        New_vector = Ampl*exp(1i*pi*Phase/180);
        new_I_Q(l:l+1) = round([real(New_vector);imag(New_vector)]);
        lcaPut(pvNames(l:l+1),new_I_Q(l:l+1));
        pause(0.05)
        [x,y]=pol2cart(Phase*pi/180,1);
        f=compass(x,y);
        drawnow
        set(f,'LineWidth',1);
        if mod(c,12) == 0
            hold off
            f=compass(x1,y1,'r');
            set(f,'LineWidth',3);
            hold on
            drawnow
        end %if
    end %for
    handles = guidata(handles.output); % get updated handles from GUI

    % if adjusting the 119MHz LCLS, rotate MDL "back" once after every 6
    % rotations of RF Ref
    if m == 4
        [handles,W] = rotate_phase_2(pvNames,inival,handles,W);%counterrotation of MDL
    end

    k = k+1; % update the rotation counter of last rotation
    set(handles.Num_rot,'String',num2str(k));

    if handles.Return
        return
    end
    % update the "condition" and GUI windows for exiting the while loop
    pause(0.2)
    new_I_Q(5:7) = round(lcaGet(pvNames(5:7))); %read phases from slow PVs
    pause(0.01)
    condition={abs(new_I_Q(1)-target_setpoint(1))<3500 && ...
        abs(new_I_Q(2)-target_setpoint(2))<3500;...
        abs(new_I_Q(5))<target_setpoint(5);abs(new_I_Q(6))<target_setpoint(6);...
        abs(new_I_Q(7))<target_setpoint(7)};
    set(handles.MDL_I,'String',num2str(new_I_Q(1)));
    set(handles.MDL_Q,'String',num2str(new_I_Q(2)));
    set(handles.Ph_25,'String',num2str(new_I_Q(5)));
    set(handles.Ph_119_F,'String',num2str(new_I_Q(6)));
    set(handles.Ph_119_L,'String',num2str(new_I_Q(7)));
    drawnow
end %while
set(handles.MDL_I,'backgroundcolor','w')
set(handles.MDL_Q,'backgroundcolor','w')
set(handles.Ph_25,'backgroundcolor','w')
set(handles.Ph_119_F,'backgroundcolor','w')
set(handles.Ph_119_L,'backgroundcolor','w')
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary Function to rotate MDL back 1 turn for every 6 turns of REF
%  Used when adjusting 119 LCLS                               - FUNCTION 2
function  [handles,W] = rotate_phase_2(pvNames,inival,handles,W)
Ampl = sqrt(inival(1)^2+inival(2)^2);
Phase= atan2(inival(2),inival(1))*180/pi;
new_I_Q=inival; %first value of new_I_Q
[x1,y1]=pol2cart(Phase*pi/180,1);
%plot initial phase vector
set(findobj('tag','text11'),'String','MDL Phase Rotation');
hold off
f=compass(x1,y1,'r');
set(f,'LineWidth',3);
hold on
for c = 1:180
    W=watchdog_run(W);
    Phase = Phase - 2;
    New_vector = Ampl*exp(1i*pi*Phase/180);
    new_I_Q(1:2)= [real(New_vector);imag(New_vector)];
    lcaPut(pvNames(1:2),new_I_Q(1:2));
    pause(0.05)
    [x,y]=pol2cart(Phase*pi/180,1);
    f=compass(x,y);
    set(f,'LineWidth',1);
    pause(0.05)
end
% Check if the STOP button was activated
handles = guidata(handles.output); % get updated handles from GUI
if handles.Return
    return
end

set(findobj('tag','text11'),'String','RF Ref Phase Rotation');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Function to adjust 119EVG phase                        - FUNCTION 3
%  Goes back to adjust 25.5 if changed during 119EVG adjustment
function [new_I_Q,k,phase_step,Flag,W] = rotate_phase_3(pvNames,inival,...
    target_setpoint,l,m,n,handles,phase_step,W)

Flag = 0; % Flag has to be defined in advance for correct exit when STOP

%calculate initial amplitude and phase
Ampl = sqrt(inival(l)^2+inival(l+1)^2);
Phase= atan2(inival(l+1),inival(l))*180/pi;
k=0;
new_I_Q=inival; %first value of new_I_Q

set(findobj('tag','text11'),'visible','on','string','RF Ref Phase Rotation');

%activate the polar plot on the GUI
[x1,y1]=pol2cart(Phase*pi/180,1);
%plot initial phase vector
hold off
f=compass(x1,y1,'r');
set(handles.polar_plot,'position',handles.graph_position);
set(f,'LineWidth',3);
hold on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setup condition for exiting from phasing loop when within the target_setpoint
%condition 1=MDL, 2=25.5, 3=EVG, 4=LCLS, condition(1) currently never used
condition={abs(new_I_Q(1)-target_setpoint(1))<3500 && ...
    abs(new_I_Q(2)-target_setpoint(2))<3500;...
    abs(new_I_Q(5))<target_setpoint(5);abs(new_I_Q(6))<target_setpoint(6);...
    abs(new_I_Q(7))<target_setpoint(7)};

while ~condition{m}
    W=watchdog_run(W);
    for c = 1:n
        W=watchdog_run(W);
        Phase = Phase + phase_step;
        New_vector = Ampl*exp(1i*pi*Phase/180);
        new_I_Q(l:l+1) = round([real(New_vector);imag(New_vector)]);
        lcaPut(pvNames(l:l+1),new_I_Q(l:l+1));
        pause(0.05)
        [x,y]=pol2cart(Phase*pi/180,1);
        f=compass(x,y);
        drawnow
        set(f,'LineWidth',1);
        if mod(c,12) == 0
            hold off
            f=compass(x1,y1,'r');
            set(f,'LineWidth',3);
            hold on
            drawnow
        end %if
    end %for
    handles = guidata(handles.output); % get updated handles from GUI

    k = k+1; % update the rotation counter of last rotation
    set(handles.Num_rot,'String',num2str(k));

    if handles.Return
        return
    end
    % update the "condition" for exiting the while loop
    pause(0.2)
    new_I_Q(5:7) = round(lcaGet(pvNames(5:7))); %read phases from slow PVs
    pause(0.01)
    condition={abs(new_I_Q(1)-target_setpoint(1))<3500 && ...
        abs(new_I_Q(2)-target_setpoint(2))<3500;...
        abs(new_I_Q(5))<target_setpoint(5);abs(new_I_Q(6))<target_setpoint(6);...
        abs(new_I_Q(7))<target_setpoint(7)};
    set(handles.MDL_I,'String',num2str(new_I_Q(1)));
    set(handles.MDL_Q,'String',num2str(new_I_Q(2)));
    set(handles.Ph_25,'String',num2str(new_I_Q(5)));
    set(handles.Ph_119_F,'String',num2str(new_I_Q(6)));
    set(handles.Ph_119_L,'String',num2str(new_I_Q(7)));
    drawnow
    % check if phase of 25.5 MHz is still OK; if not, set Flag and return
    % to the calling program; change the sense of rotation and go back to
    % adjusting the 25.5 MHz phase
    if condition{m-1}
        Flag = 0;
    else
        Flag =1; %Set Flag to return to re-adjust 25.5 phase
        phase_step = -phase_step; % reverse the rotation
        return
    end
end %while" "while ~condition{m}"
set(handles.MDL_I,'backgroundcolor','w')
set(handles.MDL_Q,'backgroundcolor','w')
set(handles.Ph_25,'backgroundcolor','w')
set(handles.Ph_119_F,'backgroundcolor','w')
set(handles.Ph_119_L,'backgroundcolor','w')
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Stop SYNC program and return to GUI                        - FUNCTION 4
function [handles] = stop_sync(handles,MDL_send_to_PAC,REF_send_to_PAC,pv_fdb)
%update the GUI handles, STOP>START button, set handles.Return=0
handles.Return = 0;
set(handles.s,'string','START','value',0);
lcaPut(pv_fdb,{'ON'}); %Turn ON Laser feedback
lcaPut(MDL_send_to_PAC,{'Enabled'}); %  enable the MDL I&Q PAC
lcaPut(REF_send_to_PAC,{'Enabled'}); %  enable the REF I&Q PAC
pause(0.05)
set(handles.s,'string','START');
set(handles.MDL_I,'backgroundcolor','w')
set(handles.MDL_Q,'backgroundcolor','w')
set(handles.Ph_25,'backgroundcolor','w')
set(handles.Ph_119_F,'backgroundcolor','w')
set(handles.Ph_119_L,'backgroundcolor','w')
drawnow
guidata(handles.output,handles); %update handles in GUI from this program
disp(' ')
disp('PROGRAM DID NOT FINISH ALL ADJUSTMENTS')
disp (' ')
disp('***!!! CHECK THE SYSTEM STATUS !!!***')
disp('***!!! RESTART THE PROGRAM TO FINISH THE SETUP !!!***')
disp(' ')
drawnow
handles = guidata(handles.output); %update handles in the GUI


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Closing function, STOP>START button, set handles.Return=0 and update
%                                                             - FUNCTION 5
function EndOfProgram(handles,MDL_send_to_PAC,REF_send_to_PAC)
handles.Return = 0;
set(handles.s,'string','START','value',0);
lcaPut(MDL_send_to_PAC,{'Enabled'}); %  enable the MDL I&Q PAC
lcaPut(REF_send_to_PAC,{'Enabled'}); %  enable the REF I&Q PAC
pause(0.05)
guidata(handles.output,handles); %updates handles in the GUI from current...
%...handles in this program
% Display final messages
set(findobj('Tag','text18'),'String','PROGRAM FINISHED SUCCESSFULLY')
disp('PROGRAM FINISHED SUCCESSFULLY')
disp(' ')
drawnow