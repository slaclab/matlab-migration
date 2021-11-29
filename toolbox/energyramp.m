function varargout = energyramp(varargin)
% ENERGYRAMP M-file for energyramp.fig
%      ENERGYRAMP, by itself, creates a new ENERGYRAMP or raises the existing
%      singleton*.
%
%      H = ENERGYRAMP returns the handle to a new ENERGYRAMP or the handle to
%      the existing singleton*.
%
%      ENERGYRAMP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENERGYRAMP.M with the given input arguments.
%
%      ENERGYRAMP('Property','Value',...) creates a new ENERGYRAMP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before energyramp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to energyramp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help energyramp

% Last Modified by GUIDE v2.5 30-Jan-2015 05:51:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @energyramp_OpeningFcn, ...
                   'gui_OutputFcn',  @energyramp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before energyramp is made visible.
function energyramp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to energyramp (see VARARGIN)

% Choose default command line output for energyramp
handles.output = hObject;


% initialize the list of magnet PVs
disp('Initializing list of magnets to scale...');
handles = InitMagnetList(handles);

% initialize LEM (per Henrik)
disp('Initialize LEM...');
handles.region = 'CU_HXR';
handles.static = model_energyMagProfile([], handles.region, 'init', 1);
handles.lemPV = 'REFS:LI30:901:EDES';
%handles.lemPV = 'SIOC:SYS0:ML00:AO409';
set([handles.TargetEnergyBox handles.StartEnergyBox],'String',lcaGet(handles.lemPV));

% % stuff needed to initialize LEM
% handles.region = 'L3';
% handles.static=[];
% handles.static=model_energyMagProfile(handles.static,handles.region,'doPlot',0,'init',1);
% handles.sectorList = {'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30'};

disp('List of BCTRL PVs that are OK and will be scaled:');
disp(handles.magnetBDES_PVs);
disp('List of EDES PVs that are OK and will be scaled:');
disp(handles.magnetEDES_PVs);

if handles.disconnected
    msg(strcat(num2str(handles.disconnected), ...
        {' PVs are disconnected and will be ignored, check the terminal!'}), 1, handles);
else
    msg('GUI loaded, press Start to begin scaling energy', 0, handles);
end

% save the old 6x6 state
%handles.OldFeedbackGain = lcaGet('SIOC:SYS0:ML00:AO023');

% PV to show active ramping state
% for SXR grating following stuff
handles.rampingPV = 'SIOC:SYS0:ML00:AO098';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes energyramp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = energyramp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LemCheckbox.
function LemCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to LemCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.LemThresholdBox, 'Enable', 'on');
    set(handles.checkbox_PlotLEM, 'Enable', 'on');
    set(handles.designLEMCheckbox, 'Enable', 'on');
    set(handles.FudgeThresholdBox, 'Enable', 'on');
    set(handles.ManageKlysCheckbox,'Enable','on');
    if get(handles.ManageKlysCheckbox, 'Value')
        set(handles.Klys2930OptBox, 'Enable', 'on');
        set(handles.MaxStationsBox, 'Enable', 'on');
    else
        set(handles.Klys2930OptBox, 'Enable', 'off');
        set(handles.MaxStationsBox, 'Enable', 'off');
    end
else
    set(handles.LemThresholdBox, 'Enable', 'off');
    set(handles.checkbox_PlotLEM, 'Enable', 'off');
    set(handles.designLEMCheckbox, 'Enable', 'off');
    set(handles.FudgeThresholdBox, 'Enable', 'off');
    set(handles.ManageKlysCheckbox,'Enable','off');
    set(handles.Klys2930OptBox, 'Enable', 'off');
    set(handles.MaxStationsBox, 'Enable', 'off');
end
% Hint: get(hObject,'Value') returns toggle state of LemCheckbox



function TargetEnergyBox_Callback(hObject, eventdata, handles)
% hObject    handle to TargetEnergyBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetEnergyBox as text
%        str2double(get(hObject,'String')) returns contents of TargetEnergyBox as a double


% --- Executes during object creation, after setting all properties.
function TargetEnergyBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetEnergyBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LemThresholdBox_Callback(hObject, eventdata, handles)
% hObject    handle to LemThresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LemThresholdBox as text
%        str2double(get(hObject,'String')) returns contents of LemThresholdBox as a double


% --- Executes during object creation, after setting all properties.
function LemThresholdBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LemThresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WaitTimeBox_Callback(hObject, eventdata, handles)
% hObject    handle to WaitTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WaitTimeBox as text
%        str2double(get(hObject,'String')) returns contents of WaitTimeBox as a double


% --- Executes during object creation, after setting all properties.
function WaitTimeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaitTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StepSizeBox_Callback(hObject, eventdata, handles)
% hObject    handle to StepSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepSizeBox as text
%        str2double(get(hObject,'String')) returns contents of StepSizeBox as a double


% --- Executes during object creation, after setting all properties.
function StepSizeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ManageKlysCheckbox.
function ManageKlysCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to ManageKlysCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.Klys2930OptBox, 'Enable', 'on');
    set(handles.MaxStationsBox, 'Enable', 'on');
else
    set(handles.Klys2930OptBox, 'Enable', 'off');
    set(handles.MaxStationsBox, 'Enable', 'off');
end
% Hint: get(hObject,'Value') returns toggle state of ManageKlysCheckbox


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% record start time
start_time = tic;

msg('Starting Energy Change...', 0, handles);

% update the starting energy in case it's changed since the last time the
% GUI ran - this fixes the problem encountered 10/02/09 owl shift
set(handles.StartEnergyBox,'String',lcaGet(handles.lemPV));

% clear the abort flag
set(hObject, 'UserData', 1);

% Get parameters from the UI
handles.guimode = get(handles.GUIModeButton, 'Value') && ~get(handles.PVModeButton, 'Value');
StartEnergy = str2double(get(handles.StartEnergyBox,'String'));

StepSize = 0.001 * str2double(get(handles.StepSizeBox,'String'));
WaitTime = str2double(get(handles.WaitTimeBox,'String'));
LemCheck = get(handles.LemCheckbox,'Value');
LemThreshold = 0.001 * str2double(get(handles.LemThresholdBox,'String'));
ManageKlys = get(handles.ManageKlysCheckbox,'Value');
FeedbackGain = str2double(get(handles.FeedbackGainBox,'String'));
handles.FudgeThreshold = 0.01 * str2double(get(handles.FudgeThresholdBox,'String'));
handles.Klys2930Option = get(handles.Klys2930OptBox, 'Value');
handles.MaxStations = str2double(get(handles.MaxStationsBox, 'String'));
handles.AutoStandardize = get(handles.StandardizeCheckbox, 'Value');
handles.PlotLEM = get(handles.checkbox_PlotLEM, 'Value');
energy_setpoints = model_energySetPoints();
handles.BC2_energy = energy_setpoints(4);


% get target energy from PV or 
if handles.guimode
    handles.TargetEnergy = str2double(get(handles.TargetEnergyBox,'String'));
else
    handles.TargetEnergy = lcaGetSmart(get(handles.edit_EnergyPV, 'String'));
    set(handles.TargetEnergyBox, 'String', num2str(handles.TargetEnergy));
end

% dump some useful info into the log file for debug purposes
disp([datestr(now) ': GUI Mode = ' num2str(handles.guimode)]);
disp([datestr(now) ': Starting Energy = ' num2str(StartEnergy)]);
disp([datestr(now) ': Target Energy = ' num2str(handles.TargetEnergy)]);
disp([datestr(now) ': Step size = ' num2str(StepSize)]);
disp([datestr(now) ': Wait Time = ' num2str(WaitTime)]);
disp([datestr(now) ': 6x6 Gain = ' num2str(FeedbackGain)]);
disp([datestr(now) ': Auto LEM = ' num2str(LemCheck)]);
disp([datestr(now) ': Lem Delta = ' num2str(LemThreshold)]);
disp([datestr(now) ': Fudge Threshold = ' num2str(handles.FudgeThreshold)]);
disp([datestr(now) ': Klys Manage = ' num2str(ManageKlys)]);
disp([datestr(now) ': 29-30 option = ' num2str(handles.Klys2930Option)]);
disp([datestr(now) ': Max Stations = ' num2str(handles.MaxStations)]);
disp([datestr(now) ': Auto Stdz = ' num2str(handles.AutoStandardize)]);

% idiot proofing checks
StupidSettings = 0;

% check to make sure the E_end PV and the bend strengths are not
% desynchronized.  simple equality checks are a bad idea for floating point reasons,
% so difference more than 0.001 (1 MeV) is an arbitrary threshold i picked out of my ass.
% this check also happens in WaitUntilHappy(), that is, while the GUI is
% ramping.

if ((abs(lcaGet('BEND:LTUH:125:BDES') - lcaGet(handles.lemPV)) > 0.001) || ...
    (abs(lcaGet('BEND:DMPH:400:BDES') - lcaGet(handles.lemPV)) > 0.001) || ...
    (abs(lcaGet('BEND:DMPH:400:BDES') - lcaGet('BEND:LTUH:125:BDES')) > 0.001))
        errordlg('Oh crap, it looks like the LEM E_end PV (REFS:DMPH:400:EDES) and either of the main bend strings (BYD and BY1) are not self-consistent.  Bailing out!', ...
        'Inconsistent energy numbers');
        msg('PV synchronization check failure, exiting', 2, handles);
        StupidSettings = 1;
end

% hard errors
if ((handles.TargetEnergy < 2) || (handles.TargetEnergy > 18))
    StupidSettings = 1;
    errordlg('Target Energy must be between 2 and 18 GeV!', 'Ya big dummy');
end
if (StepSize <= 0)
    StupidSettings = 1;
    errordlg('Step size must be greater than zero', 'Ya big dummy');
end
if (LemCheck && (handles.FudgeThreshold <= 0))
    StupidSettings = 1;
    errordlg('Fudge factor limit must be greater than zero, or LEM will never work', 'Ya big dummy');
end
if ((FeedbackGain >= 1) || (FeedbackGain <= 0))
    StupidSettings = 1;
    errordlg('Feedback gain must be between 0 and 1.', 'Ya big dummy');
end

% soft errors
if ((StepSize >= 0.5) && ~StupidSettings)
    response = questdlg(['Step size is large (' num2str(StepSize * 1000) ' MeV).  You are a wild crazy person.  Are you sure you want to continue?'], 'Step size is large', 'No');
    if (strcmp(response, 'No') || strcmp(response, 'Cancel'))
        StupidSettings = 1;
    end
end
if ((WaitTime <= 0.5) && ~StupidSettings)
    response = questdlg(['Wait Time is small (' num2str(WaitTime) ' seconds).  Feedbacks will probably not keep up and you will die a painful firey death.  Are you sure you want to continue?'], 'Wait time is small', 'No');
    if (strcmp(response, 'No') || strcmp(response, 'Cancel'))
        StupidSettings = 1;
    end
end
if (LemCheck && (LemThreshold <= 0.05) && ~StupidSettings)
    response = questdlg(['LEM threshold is small (' num2str(LemThreshold * 1000) ' MeV).  You will be old and grey by the time it finishes.  Are you sure you want to continue?'], 'LEM threshold is large', 'No');
    if (strcmp(response, 'No') || strcmp(response, 'Cancel'))
        StupidSettings = 1;
    end
end
if (LemCheck && ManageKlys && ((handles.MaxStations * 0.25) < LemThreshold) && ~StupidSettings)
    response = questdlg(['Only switching ' num2str(handles.MaxStations) ' klystrons every ' ...
        num2str(LemThreshold * 1000) ' MeV probably wont be able to keep up.  Continue anyway?'], 'Max tubes is too small', 'No');
    if (strcmp(response, 'No') || strcmp(response, 'Cancel'))
        StupidSettings = 1;
    end
end

if ~StupidSettings
    
    set(handles.StartButton,'BackgroundColor',[0.9, 0.9, 0.0]);
    set(handles.StartButton,'String','Running...');

    % Disable the UI controls
    set(handles.StartButton,'Enable','off');
    set(handles.TargetEnergyBox,'Enable','off');
    set(handles.StepSizeBox,'Enable','off');
    set(handles.WaitTimeBox,'Enable','off');
    set(handles.LemThresholdBox,'Enable','off');
    set(handles.LemCheckbox,'Enable','off');
    set(handles.checkbox_PlotLEM, 'Enable', 'off');
    set(handles.ManageKlysCheckbox,'Enable','off');
    set(handles.FeedbackGainBox,'Enable','off');
    set(handles.FudgeThresholdBox,'Enable','off');
    set(handles.PauseButton,'Enable','on');
    set(handles.GUIModeButton,'Enable','off');
    set(handles.PVModeButton,'Enable','off');
    set(handles.Klys2930OptBox, 'Enable', 'off');
    set(handles.MaxStationsBox, 'Enable', 'off');
    set(handles.StandardizeCheckbox, 'Enable', 'off');
    set(handles.GUIModeButton, 'Enable', 'off');
    set(handles.PVModeButton, 'Enable', 'off');
    
    % get the starting magnet state
    magnetBDES=lcaGet(handles.magnetBDES_PVs);
    magnetEDES=lcaGet(handles.magnetEDES_PVs);

    handles.L3ActuatorStart = lcaGet('SIOC:SYS0:ML00:AO285');
    handles.L3Minimum = handles.L3ActuatorStart - 0.1;
    handles.L3Maximum = handles.L3ActuatorStart + 0.1;

    % Change the 6x6 gain

%    lcaPut('SIOC:SYS0:ML00:AO023', FeedbackGain);

    % Main loop

    LemDelta = 0;
    while run_check(handles) %UserData is the abort button flag

        if handles.guimode
            handles.TargetEnergy = str2double(get(handles.TargetEnergyBox,'String'));
        else
            handles.TargetEnergy = lcaGetSmart(get(handles.edit_EnergyPV, 'String'));
            set(handles.TargetEnergyBox, 'String', num2str(handles.TargetEnergy));
        end
        
        % Choose the step size
        CurrentEnergy = lcaGet(handles.lemPV);
        EnergyDelta = handles.TargetEnergy - CurrentEnergy;
        if abs(EnergyDelta) > StepSize
            EnergyEpsilon = StepSize * sign(EnergyDelta);
        else
            EnergyEpsilon = EnergyDelta;
        end

        % calculate magnet epsilons
        BDES_epsilon=magnetBDES.*(EnergyEpsilon/StartEnergy);
        EDES_epsilon=magnetEDES.*(EnergyEpsilon/StartEnergy);

        % calculate where the BX31/32 etc trims should go
%         [BTRM_new_BDES,Imain,Itrim,pBYD] = LEM_BYD_BX3_BDES(CurrentEnergy + EnergyEpsilon);
        [BTRM_new_BDES, par] = model_energyBX3trim(CurrentEnergy + EnergyEpsilon);
        
        WaitUntilHappy(handles);

        
        if get(hObject, 'UserData') && (abs(EnergyEpsilon) > 1e-5)

            lcaPutSmart(handles.rampingPV, 1);
            
            msg(['Scaling to ' num2str(CurrentEnergy + EnergyEpsilon) ' GeV'], 0, handles);

            % set LEM E_end
            lcaPut(handles.lemPV,CurrentEnergy + EnergyEpsilon);
            
            % increment the internal LEM counter
            LemDelta = LemDelta + EnergyEpsilon;

            % send magnet epsilons
            lcaPut(handles.magnetBDES_PVs, (BDES_epsilon + lcaGet(handles.magnetBDES_PVs)));
            lcaPut(handles.magnetEDES_PVs, (EDES_epsilon + lcaGet(handles.magnetEDES_PVs)));
        
            % send BTRM BDESes
            lcaPut(handles.BTRM_PVs, BTRM_new_BDES);

            % wait the specified time for the supplies to settle
            pause(WaitTime);
            msg(['Scaled to ' num2str(lcaGet(handles.lemPV)) ' GeV'], 0, handles);
        end
        
        if abs(EnergyEpsilon) < 1e-5

           lcaPutSmart(handles.rampingPV, 0);

           msg(['Current Energy (' num2str(CurrentEnergy) ') = Target Energy (' num2str(handles.TargetEnergy) ')'], 0, handles);
           pause(WaitTime);
        end

        % Do a LEM if needed
        if (LemCheck && get(hObject, 'UserData'))  % LemCheck = gui checkbox status, UserData = stop not pressed
            WaitUntilHappy(handles);
            if(abs(LemDelta) >= abs(LemThreshold))
                msg('Suppressing beam during LEM', 1, handles);
                lcaPut('IOC:BSY0:MP01:MSHUTCTL', 'No');
                handles = disable_all_feedbacks(handles);
                if ManageKlys     % fix the klystron complement
                    msg('Adjusting klystron complement...', 1, handles);
                    handles = SetKlystronComplement(handles);
                end
                msg('Starting LEM', 1, handles);
                handles = DoLEM(handles);
                LemDelta = 0;
                msg('LEM scaling finished. Unsuppressing beam', 0, handles);
                handles = enable_all_feedbacks(handles);
                lcaPut('IOC:BSY0:MP01:MSHUTCTL', 'Yes');
                pause(0.5);
            end
            WaitUntilHappy(handles);
        end

    end % end main loop

    %stupid godawful kluge to prevent cumulative floating point errors from
    %cropping up in the LEM E_end & bend magnet BDES as 4.29999874 etc

    if get(hObject, 'UserData')
        lcaPut(handles.lemPV, handles.TargetEnergy);
        lcaPut('BEND:LTUH:125:BDES', handles.TargetEnergy);
        lcaPut('BEND:DMPH:400:BDES', handles.TargetEnergy);
    end
    
    % do a final lem

    if ((abs(LemDelta) > 0) && LemCheck && get(hObject, 'UserData')) 
        WaitUntilHappy(handles);
        msg('Pausing a few moments to let feedbacks settle...', 0, handles);
        pause(3);
        WaitUntilHappy(handles);
        msg('Doing a Final LEM, suppressing beam', 1, handles);
        lcaPut('IOC:BSY0:MP01:MSHUTCTL', 'No');
        handles = disable_all_feedbacks(handles);
        handles = DoLEM(handles);
        LemDelta = 0;
        msg('LEM scaling finished. Unsuppressing beam', 0, handles);
        model_fbUndSetup();
        pause(0.5);
        handles = enable_all_feedbacks(handles);
        lcaPut('IOC:BSY0:MP01:MSHUTCTL', 'Yes');
        pause(0.5);
        WaitUntilHappy(handles);
    end

    % trim all correctors after the ramp
    msg('Trimming correctors...', 1, handles);
    pause(1);
    lcaPut(handles.corrector_ctrlPVs, 'TRIM');

    % wait max 30 seconds for correctors to go back to Ready
    for i=0:15
        if ~sum(~strcmp(lcaGet(handles.corrector_ctrlPVs), 'Ready'))
            break
        else
            pause(2);
        end
    end
    
    if (i >= 15)
        msg('Some correctors failed to return from trim!', 2, handles);
    else
        msg('Corrector trim finished.', 1, handles);
    end

    % Put the 6x6 Gain back
    lcaPut('SIOC:SYS0:ML00:AO023', handles.OldFeedbackGain);
    
    % enable the STDZ all button if needed
    if (handles.AutoStandardize && get(hObject, 'UserData'))
        if lcaGet(handles.lemPV) < StartEnergy
            !StripTool /u1/lcls/tools/StripTool/config/byd_by1_stdz.stp &
            msg('Suppressing beam and STDZing BSY LTU and DMP magnets...', 1, handles);
            lcaPut('IOC:BSY0:MP01:MSHUTCTL', 'No');   
            pause(0.5);
%            lcaPut('BEND:LTU0:125:CTRL', 'STDZ');
%            lcaPut('BEND:DMP1:400:CTRL', 'STDZ');
            lcaPut(handles.magnetCTRL_PVs, 'STDZ');
            while ~strcmp(lcaGet('BEND:DMPH:400:CTRL'), 'Ready')
                pause(2);
            end
        end
    end
    

    

    % Update the Start Energy
    set(handles.StartEnergyBox,'String',lcaGet(handles.lemPV));

    
    set(handles.StartButton,'BackgroundColor',[0.4, 0.8, 0.4]);
    set(handles.StartButton,'String','Start');
    
    % Re-enable the UI controls
    set(handles.StartButton,'Enable','on');
    set(handles.TargetEnergyBox,'Enable','on');
    set(handles.StepSizeBox,'Enable','on');
    set(handles.WaitTimeBox,'Enable','on');
    set(handles.LemCheckbox,'Enable','on');
    set(handles.FeedbackGainBox,'Enable','on');
    set(handles.PauseButton,'Enable','off');
    set(handles.GUIModeButton,'Enable','on');
    set(handles.Klys2930OptBox, 'Enable', 'on');
    set(handles.StandardizeCheckbox, 'Enable', 'on');
    set(handles.GUIModeButton, 'Enable', 'on');
    set(handles.PVModeButton, 'Enable', 'on');
    if get(handles.LemCheckbox, 'Value')
        set(handles.checkbox_PlotLEM, 'Enable', 'on');
        set(handles.LemThresholdBox,'Enable','on');
        set(handles.FudgeThresholdBox,'Enable','on');
        set(handles.ManageKlysCheckbox,'Enable','on');
        if get(handles.ManageKlysCheckbox, 'Value')
            set(handles.Klys2930OptBox, 'Enable', 'on');
            set(handles.MaxStationsBox, 'Enable', 'on');
        end
    end

    
    if ~get(hObject, 'UserData')
        msg('Energy change aborted by user.', 0, handles);
    else
        msg('Finished Scaling.', 0, handles);
    end
else
    msg('Scaling aborted.', 0, handles);
end

% record elapsed time
elapsed_time = toc(start_time);
old_value = lcaGetSmart('SIOC:SYS0:ML03:AO711',0,'double');
lcaPutSmart('SIOC:SYS0:ML03:AO711', old_value + elapsed_time);


% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == 1)
    set(hObject,'BackgroundColor',[0.9, 0.9, 0]);
    set(hObject,'String','Paused');
end
if (get(hObject,'Value') == 0)
    set(hObject,'BackgroundColor',[0.702, 0.702, 0.702]);
    set(hObject,'String','Pause');
end
% Hint: get(hObject,'Value') returns toggle state of PauseButton


% --- Executes during object creation, after setting all properties.
function MessageBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','Press Start to Scale Energy');


% --- Executes during object creation, after setting all properties.
function StartEnergyBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartEnergyBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function LemCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LemCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1);


% --- Executes during object deletion, before destroying properties.
function LemCheckbox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to LemCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function StartEnergyBox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to StartEnergyBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function TargetEnergyBox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to TargetEnergyBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function StepSizeBox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to StepSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function WaitTimeBox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to WaitTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function LemThresholdBox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to LemThresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function [status]=AllOK(handles)
%status=1 is machine in state to continue
CurrentEnergy = lcaGet(handles.lemPV);
status=1;
if ((lcaGet('SIOC:SYS0:ML00:AO466') == 1) || ...                % Guardian tripped
   ~strcmp(lcaGet('BCS:MCC0:1:BEAMPMSV'), 'OK') || ...         % BCS tripped
   ~strcmp(lcaGet('BCS:IN20:1:BEAMPERM'), 'OK') || ...         % Beam permit off
   strcmp(lcaGet('IOC:BSY0:MP01:PC_RATE'), '0 Hz') || ...      % New MPS zero rated
   strcmp(lcaGet('IOC:BSY0:MP01:MS_RATE'), '0 Hz') || ...      % New MPS zero rated
   strcmp(lcaGet('IOC:BSY0:MP01:BYKIK_RATE'), '0 Hz') || ...   % New MPS zero rated
   (get(handles.PauseButton,'Value') == 1) || ...              % pause button pressed
   ((-0.99 >= lcaGet('SIOC:SYS0:ML00:AO285')) && (handles.TargetEnergy <= CurrentEnergy))  || ...
   ((lcaGet('SIOC:SYS0:ML00:AO285') >= 0.99) && (handles.TargetEnergy >= CurrentEnergy)))     % 6x6 near a rail
        status=0;
end


function FeedbackGainBox_Callback(hObject, eventdata, handles)
% hObject    handle to FeedbackGainBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FeedbackGainBox as text
%        str2double(get(hObject,'String')) returns contents of FeedbackGainBox as a double


% --- Executes during object creation, after setting all properties.
function FeedbackGainBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FeedbackGainBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',0.6);

function msg(MessageString, severity, handles)
set(handles.MessageBox, 'String', MessageString);
disp_log(strcat(datestr(now), {': '}, MessageString));
if severity == 1
    set(handles.MessagePanel, 'BackgroundColor', [0.9, 0.9, 0]);
elseif severity == 2
    set(handles.MessagePanel, 'BackgroundColor', [0.9, 0.2, 0.2]);
else
    set(handles.MessagePanel, 'BackgroundColor', [0.702, 0.702, 0.702]);
end 
drawnow;


function handles = DoLEM(handles)
% collects lem data - now using Henrik's API 6/29/2010
msg('Collecting LEM data', 1, handles);
handles.static=model_energyMagProfile(handles.static,handles.region,'doPlot',handles.PlotLEM);

if (((1 - handles.FudgeThreshold) <= handles.static.klys.fudgeDes(4)) && ...
    ((1 + handles.FudgeThreshold) >= handles.static.klys.fudgeDes(4)))
    % Do the LEM
    msg('Fudge factors OK', 1, handles);
    handles = ScaleLEM(handles);
else
    % Collect again
    msg('Fudge factor out of tols.  Collecting again.', 1, handles);
    pause(1);
    handles.static=model_energyMagProfile(handles.static,handles.region,'doPlot',handles.PlotLEM);
    if (((1 - handles.FudgeThreshold) <= handles.static.klys.fudgeDes(4)) && ...
        ((1 + handles.FudgeThreshold) >= handles.static.klys.fudgeDes(4)))
        msg('Fudge factors OK on second try', 1, handles);
        handles = ScaleLEM(handles);
    else
        response = questdlg(['L3 Fudge factor is ' num2str(handles.static.klys.fudgeDes(4)) '.  Do you want to LEM anyway?'], 'Fudge factor out of tols', 'No');
        if (strcmp(response, 'Yes'))
            msg(['Implementing LEM with fudge of ' num2str(handles.static.klys.fudgeDes(4)) '.'], 2, handles);
            handles = ScaleLEM(handles);
        end
    end
end

function handles = ScaleLEM(handles)
% update 6/29/2010 use Henrik API

msg('LEM calculation for L3 ...', 1, handles);
lemOptions = struct('design',get(handles.designLEMCheckbox,'Value'), ...
    'undMatch',1, ...
    'dmpMatch',1, ...
    'designAll',0, ...
    'undBBA',0 ...
    );

if lemOptions.design
    msg('Using LEM to Design option. Not including matching quads.', 1, handles);
end
[m, k] = model_energyMagScale(handles.static.magnet, handles.static.klys, lemOptions);
msg('Waiting for LEM to trim ...', 1, handles);
model_energyMagTrim(m, k);
msg('LEM trim finished.', 0, handles);


function FudgeThresholdBox_Callback(hObject, eventdata, handles)
% hObject    handle to FudgeThresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FudgeThresholdBox as text
%        str2double(get(hObject,'String')) returns contents of FudgeThresholdBox as a double


% --- Executes during object creation, after setting all properties.
function FudgeThresholdBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FudgeThresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = SetKlystronComplement(handles)

% get current energy
CurrentEnergy = lcaGet(handles.lemPV);
CurrentL3Gain = CurrentEnergy - handles.BC2_energy;
TargetL3Gain = handles.TargetEnergy - handles.BC2_energy;

% get current L3 complement
names = model_nameConvert(model_nameRegion('KLYS', handles.region), 'MAD');
%names = model_nameConvert({'KLYS'},'MAD',handles.sectorList);
phi29 = lcaGet('ACCL:LI29:0:KLY_PDES');
phi30 = lcaGet('ACCL:LI30:0:KLY_PDES');
[act, stat, swrd, hdsc, dsta, enld] = control_klysStatGet(names);

% parse the complement into useful blocks

names_25_28 = names(1:32);          % station names
names_29 = names(33:40);
names_30 = names(41:48);

enld_25_28 = 0.001 * enld(1:32);    % station enlds
enld_29 = 0.001 * enld(33:40);
enld_30 = 0.001 * enld(41:48);

accel_25_28 = (bitget(act(1:32), 1) .* ~bitget(swrd(1:32),4)); % good stations on the beam
accel_29 = (bitget(act(33:40), 1) .* ~bitget(swrd(33:40), 4)); % swrd bit 4 is modulator on/off
accel_30 = (bitget(act(41:48), 1) .* ~bitget(swrd(41:48), 4));

spares_25_28 = (bitget(act(1:32), 2) .* ~bitget(swrd(1:32), 4));% good spares
spares_29 = (bitget(act(33:40), 2) .* ~bitget(swrd(33:40), 4));
spares_30 = (bitget(act(41:48), 2) .* ~bitget(swrd(41:48), 4));

% calculate the energy contribution from each section

dE_25_28 = sum(enld_25_28 .* accel_25_28);
dE_29_30 =  sum((enld_29 .* accel_29) * cosd(phi29)) + ...
            sum((enld_30 .* accel_30) * cosd(phi30));

EnergyMax = sum((0.001 * enld) .* (~bitget(act, 3))); 

% manage the 29-30 tubes

if (handles.Klys2930Option == 1) % if user selected "make 29-30 proportional"
    
    % find the "ideal" number of stations to have on in each of 29 & 30
    % i claim the ideal number of stations grows linearly between 2 and 8
    % as the energy scales from 4.3 to 13.7.
    % this keeps the 29-30 energy vernier from being too big relative to
    % the actual beam energy and reduces the problems associated with phase
    % errors, etc.
    IdealVernier = round(((7 - 2) / (14.2 - handles.BC2_energy)) * abs(CurrentL3Gain)) + 3;
    disp(['ideal vernier = ' num2str(IdealVernier)]);
    if sum(spares_29)   % if there are any stations left in 29, add or drop a tube as needed
        if IdealVernier > sum(accel_29)
            candidate = find(spares_29, 1, 'first');
            accel_29(candidate) = 1;
            spares_29(candidate) = 0;
            disp(['adding 29-' num2str(candidate)]);
        elseif IdealVernier < sum(accel_29)
            candidate = find(accel_29, 1, 'last');
            accel_29(candidate) = 0;
            spares_29(candidate) = 1;
            disp(['dropping 29-' num2str(candidate)]);
        end
    end
    
    if sum(spares_30)   % if there are any stations left in 30, add or drop a tube as needed
        if IdealVernier > sum(accel_30)
            candidate = find(spares_30, 1, 'first');
            accel_30(candidate) = 1;
            spares_30(candidate) = 0;
            disp(['adding 30-' num2str(candidate)]);
        elseif IdealVernier < sum(accel_30)
            candidate = find(accel_30, 1, 'last');
            accel_30(candidate) = 0;
            spares_30(candidate) = 1;
            disp(['dropping 30-' num2str(candidate)]);
        end
    end
    
elseif (handles.Klys2930Option == 2) % if user selected "make 29-30 strong"

    if sum(spares_29)   % if there are any stations left in 29, add a tube
        candidate = find(spares_29, 1, 'first');
        accel_29(candidate) = 1;
        spares_29(candidate) = 0;
        disp(['adding 29-' num2str(candidate)]);
    end
    if sum(spares_30)   % if there are any stations left in 29, add a tube
        candidate = find(spares_30, 1, 'first');
        accel_30(candidate) = 1;
        spares_30(candidate) = 0;
        disp(['adding 30-' num2str(candidate)]);
    end

end  % if user selected "leave 29-30 alone", don't do anything there

% find the max contribution of the new 29-30 complement
dE_25_28 = sum(enld_25_28 .* accel_25_28);
dE_29_30_max = sum((enld_29 .* accel_29)) + sum((enld_30 .* accel_30));
            
% change 25-28 complement by (no more than MaxStations) tubes in the right direction

for i=1:handles.MaxStations
    dE_25_28 = sum(enld_25_28 .* accel_25_28);
    disp(['loop ' num2str(i) ', dE2528 = ' num2str(dE_25_28)]);

    % try to make 25-28 contribute all of the current energy if possible...
    % this will tend to make the 29/30 phase shifters stay centered in
    % their range.
    
    if (CurrentL3Gain - dE_25_28) > 0.2      % if the 25-28 complement is at least 200 mev too little
        if sum(spares_25_28) % if there are any spares in 25-28,
            % add a tube in 25-28
            candidate = find(spares_25_28,1,'first');
            accel_25_28(candidate) = 1;
            spares_25_28(candidate) = 0;
            disp(['adding tube in 25-28 number ' num2str(candidate)]);
        else    % if there are no spares in 25-28, add a tube in 29 or 30
            if sum(accel_29) <= sum(accel_30)   % choose whether to use a tube in 29 or in 30
                % add a tube in 29
                if sum(spares_29)
                    candidate = find(spares_29, 1, 'first');
                    accel_29(candidate) = 1;
                    spares_29(candidate) = 0;
                    disp(['adding 29-' num2str(candidate)]);
                end
            else
                %add a tube in 30
                if sum(spares_30)
                    candidate = find(spares_30, 1, 'first');
                    accel_30(candidate) = 1;
                    spares_30(candidate) = 0;
                    disp(['adding 30-' num2str(candidate)]);
                end
            end
        end
    elseif (CurrentL3Gain - dE_25_28) < -0.2    % if the 25-28 complement is too big,
        % drop a tube in 25-28
        candidate = find(accel_25_28,1,'last');
        accel_25_28(candidate) = 0;
        spares_25_28(candidate) = 1;
        disp(['dropping tube ' num2str(candidate)]);
    end
end

dE_25_28 = sum(enld_25_28 .* accel_25_28);
dE_29_max = sum((enld_29 .* accel_29));
dE_30_max = sum((enld_30 .* accel_30));

% figure out where the phase shifters should go
% not sure if this is right or not
new_phi29 = -acosd((CurrentL3Gain - dE_25_28) / (2 * dE_29_max));
new_phi30 = acosd((CurrentL3Gain - dE_25_28) / (2 * dE_30_max));
disp(['new phi 29 = ' num2str(new_phi29)]);
disp(['new phi 30 = ' num2str(new_phi30)]);

% reconstruct the vector of stations on the beam
newact = [accel_25_28; accel_29; accel_30];

% change the complement
control_klysStatSet(names, newact);

% set the phase shifters
%lcaPut('ACCL:LI29:0:KLY_PDES', new_phi29);
%lcaPut('ACCL:LI30:0:KLY_PDES', new_phi30);
%msg('pausing for a few seconds...', 1, handles);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%lcaPut('SIOC:SYS0:ML00:AO023', handles.OldFeedbackGain);
lcaPutSmart(handles.rampingPV, 0);
% Hint: delete(hObject) closes the figure
util_appClose(hObject);


% --- Executes during object creation, after setting all properties.
function ManageKlysCheckbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ManageKlysCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function WaitUntilHappy(handles)

while ~AllOK(handles)
   
    if (get(handles.PauseButton,'Value') == 1)
        msg('Pause button pressed, waiting...', 1, handles);
    end
    if (lcaGet('SIOC:SYS0:ML00:AO466') == 1)
        msg('Guardian tripped, waiting...', 2, handles);
    end
    if ~strcmp(lcaGet('BCS:IN20:1:BEAMPERM'), 'OK')
        msg('Beam permissive off, waiting...', 2, handles);
    end
    if strcmp(lcaGet('IOC:BSY0:MP01:PC_RATE'), '0 Hz')
        msg('Pockels cell zero rated, waiting...', 2, handles);
    end
    if strcmp(lcaGet('IOC:BSY0:MP01:MS_RATE'), '0 Hz')
        msg('Mechanical Shutter zero rated, waiting...', 2, handles);
    end
    if strcmp(lcaGet('IOC:BSY0:MP01:BYKIK_RATE'), '0 Hz')
        msg('BYKICK zero rated, waiting...', 2, handles);
    end
    if ((-0.99 >= lcaGet('SIOC:SYS0:ML00:AO285')) || (lcaGet('SIOC:SYS0:ML00:AO285')  >= 0.99))
        msg('Six by six railed, waiting...', 2, handles);
    end
    pause(2);
    
end


% check to make sure the E_end PV and the bend strengths are not
% desynchronized.  simple equality checks are a bad idea for floating point reasons,
% so difference more than 0.001 (1 MeV) is an arbitrary threshold i picked out of my ass.

if ((abs(lcaGet('BEND:LTUH:125:BDES') - lcaGet(handles.lemPV)) > 0.001) || ...
    (abs(lcaGet('BEND:DMPH:400:BDES') - lcaGet(handles.lemPV)) > 0.001) || ...
    (abs(lcaGet('BEND:DMPH:400:BDES') - lcaGet('BEND:LTUH:125:BDES')) > 0.001))
        errordlg('Oh crap, it looks like the LEM E_end PV (REFS:DMPH:400:EDES) and either of the main bend strings (BYD and BY1) are not self-consistent.  Bailing out!', ...
        'Inconsistent energy numbers');
        msg('PV synchronization check failure, exiting', 2, handles);
        set(handles.StartButton, 'UserData', 0); % set the abort flag
end


% --- Executes during object creation, after setting all properties.
function MessagePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessagePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function PauseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes on button press in PVModeButton.
function PVModeButton_Callback(hObject, eventdata, handles)
% hObject    handle to PVModeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.TargetEnergyBox,'Enable','off');
handles.TargetEnergy = lcaGetSmart(get(handles.edit_EnergyPV, 'String'));
set(handles.TargetEnergyBox, 'String', num2str(handles.TargetEnergy));

handles.PVMode = 1;

% Hint: get(hObject,'Value') returns toggle state of PVModeButton


% --- Executes on button press in GUIModeButton.
function GUIModeButton_Callback(hObject, eventdata, handles)
% hObject    handle to GUIModeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.TargetEnergyBox,'Enable','on');
handles.PVMode = 0;
% Hint: get(hObject,'Value') returns toggle state of GUIModeButton


% --- Executes on button press in AbortButton.
function AbortButton_Callback(hObject, eventdata, handles)
% hObject    handle to AbortButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.StartButton, 'UserData', 0);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PVModeButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PVModeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in Klys2930OptBox.
function Klys2930OptBox_Callback(hObject, eventdata, handles)
% hObject    handle to Klys2930OptBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Klys2930OptBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Klys2930OptBox


% --- Executes during object creation, after setting all properties.
function Klys2930OptBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Klys2930OptBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxStationsBox_Callback(hObject, eventdata, handles)
% hObject    handle to MaxStationsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxStationsBox as text
%        str2double(get(hObject,'String')) returns contents of MaxStationsBox as a double


% --- Executes during object creation, after setting all properties.
function MaxStationsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxStationsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in StandardizeCheckbox.
function StandardizeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to StandardizeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StandardizeCheckbox

function handles = InitMagnetList(handles)
% dynamically generate a list of all magnets needing to be scaled during the energy
% ramp

primList = {'BEND', 'QUAD', 'XCOR', 'YCOR', 'KICK', 'SOLN'};
magnet_PVs = model_nameRegion(primList,'LTUH_DMPH','LEM',1);

% select only those which are online, not under feedback control and healthy
OkStatusList = {'Good', 'BCON Warning', 'BDES Change', 'Not Stdz''d', 'Out-of-Tol', 'BAD Ripple'};

magnet_stats = string(lcaGetSmart(strcat(magnet_PVs, ':STATMSG')));

good_magnet_PVs = magnet_PVs(magnet_stats.contains(OkStatusList));

% ask user if they want to scale sickly magnets
BadStatusList = {'In Trouble', 'Turned Off', 'Not Cal''d', 'Tripped', 'DAC Error', 'ADC Error', 'BAD BACT'};
bad_magnet_PVs = magnet_PVs(magnet_stats.contains(BadStatusList));

for mag = bad_magnet_PVs'
    response = questdlg(['The magnet ' mag ' has status ' magnet_stats(strmatch(mag, magnet_PVs)) '.  Include it in the list of magnets to ramp anyway?'], ...
        'Include ?', 'No');
    if strcmp(response, 'Yes')
        good_magnet_PVs = [good_magnet_PVs; mag];
    end
end

% add on :BDES and :EDES and store the lists

handles.magnetBDES_PVs = strcat(good_magnet_PVs, ':BCTRL');
handles.magnetCTRL_PVs = strcat(good_magnet_PVs, ':CTRL');

handles.BTRM_PVs = {'BTRM:LTUH:220:BCTRL' ...
'BTRM:LTUH:280:BCTRL' ...
'BTRM:LTUH:420:BCTRL' ...
'BTRM:LTUH:480:BCTRL' ...
}';

% add BTRM and no-ctrl/feedback-ctrl magnet names to the list of EDES to be scaled

good_magnet_PVs = [good_magnet_PVs; 'BTRM:LTUH:220'; 'BTRM:LTUH:280'; 'BTRM:LTUH:420'; 'BTRM:LTUH:480'];

good_magnet_PVs = [good_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, 'No Control'))))];
good_magnet_PVs = [good_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, 'Feedback Ctrl'))))];
good_magnet_PVs = [good_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, 'Offline'))))];


handles.magnetEDES_PVs = strcat(good_magnet_PVs, ':EDES');

% create a list of correctors only to be trimmed after ramp is done

corrector_PVs = [];
corrector_PVs = [corrector_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_PVs, 'XCOR'))))];
corrector_PVs = [corrector_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_PVs, 'YCOR'))))];

handles.corrector_ctrlPVs = strcat(corrector_PVs, ':CTRL');

% flag PVs cant connect to
bdes_bad = find(isnan(lcaGetSmart(handles.magnetBDES_PVs, 0, 'double')));
ctrl_bad = find(isnan(lcaGetSmart(handles.magnetCTRL_PVs, 0, 'double')));
edes_bad = find(isnan(lcaGetSmart(handles.magnetEDES_PVs, 0, 'double')));
btrm_bad = find(isnan(lcaGetSmart(handles.BTRM_PVs, 0, 'double')));
corr_bad = find(isnan(lcaGetSmart(handles.corrector_ctrlPVs, 0, 'double')));

% warn user
if isempty([bdes_bad; ctrl_bad; edes_bad; btrm_bad; corr_bad])
    handles.disconnected = 0;
else
    handles.disconnected = numel([bdes_bad; ctrl_bad; edes_bad; btrm_bad; corr_bad]);
    if ~isempty(bdes_bad), disp_log(strcat({'Could not connect to PV: '}, handles.magnetBDES_PVs(bdes_bad))); end
    if ~isempty(ctrl_bad), disp_log(strcat({'Could not connect to PV: '}, handles.magnetCTRL_PVs(ctrl_bad))); end
    if ~isempty(edes_bad), disp_log(strcat({'Could not connect to PV: '}, handles.magnetEDES_PVs(edes_bad))); end
    if ~isempty(btrm_bad), disp_log(strcat({'Could not connect to PV: '}, handles.BTRM_PVs(btrm_bad))); end
    if ~isempty(corr_bad), disp_log(strcat({'Could not connect to PV: '}, handles.corrector_ctrlPVs(corr_bad))); end
end

% strip disconnected PVs from lists
handles.magnetBDES_PVs(bdes_bad) = [];
handles.magnetCTRL_PVs(ctrl_bad) = [];
handles.magnetEDES_PVs(edes_bad) = [];
handles.BTRM_PVs(btrm_bad) = [];
handles.corrector_ctrlPVs(corr_bad) = [];


% --- Executes on button press in checkbox_PlotLEM.
function checkbox_PlotLEM_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_PlotLEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_PlotLEM


function handles = disable_all_feedbacks(handles)
handles.fbstate = lcaGet(control_fbNames(), 1, 'double');
lcaPut(control_fbNames(), zeros(size(handles.fbstate)));

function handles = enable_all_feedbacks(handles)
lcaPut(control_fbNames(), handles.fbstate);


function out = run_check(handles)

if handles.guimode
    out = ((lcaGet(handles.lemPV) ~= handles.TargetEnergy) && get(handles.StartButton, 'UserData'));
else
    out = get(handles.StartButton, 'UserData');
end   



function edit_EnergyPV_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EnergyPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EnergyPV as text
%        str2double(get(hObject,'String')) returns contents of edit_EnergyPV as a double
handles.TargetEnergy = lcaGetSmart(get(handles.edit_EnergyPV, 'String'));
set(handles.TargetEnergyBox, 'String', num2str(handles.TargetEnergy));



% --- Executes during object creation, after setting all properties.
function edit_EnergyPV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EnergyPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in designLEMCheckbox.
function designLEMCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to designLEMCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of designLEMCheckbox
