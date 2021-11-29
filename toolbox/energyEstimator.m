function varargout = energyEstimator(varargin)
% ENERGYESTIMATOR MATLAB code for energyEstimator.fig
%      ENERGYESTIMATOR, by itself, creates a new ENERGYESTIMATOR or raises the existing
%      singleton*.
%
%      H = ENERGYESTIMATOR returns the handle to a new ENERGYESTIMATOR or the handle to
%      the existing singleton*.
%
%      ENERGYESTIMATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENERGYESTIMATOR.M with the given input arguments.
%
%      ENERGYESTIMATOR('Property','Value',...) creates a new ENERGYESTIMATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before energyEstimator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to energyEstimator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help energyEstimator

% Last Modified by GUIDE v2.5 14-Oct-2016 14:29:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @energyEstimator_OpeningFcn, ...
                   'gui_OutputFcn',  @energyEstimator_OutputFcn, ...
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


% --- Executes just before energyEstimator is made visible.
function energyEstimator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to energyEstimator (see VARARGIN)

% Choose default command line output for energyEstimator
handles.output = hObject;

% Default to not using actual U1 K value
handles.useActualK = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes energyEstimator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = energyEstimator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in useRealK.
function useRealK_Callback(hObject, eventdata, handles)
% hObject    handle to useRealK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useRealK





% --- Executes on button press in doCalc.
function doCalc_Callback(hObject, eventdata, handles)
% hObject    handle to doCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find the starting photon and electron energies (and K values, if desired)

pickMethod = get(get(handles.pickStart,'SelectedObject'),'Tag');

switch pickMethod
    case 'useCurrent'
        startE_eV = lcaGet('SIOC:SYS0:ML00:AO627'); % Welch number
        lemE_end = lcaGet('REFS:DMP1:400:EDES'); % LEM's DL2 E_end
        vernier = lcaGet('FBCK:FB04:LG01:DL2VERNIER')*0.001; % Vernier in MeV converted to GeV
        startE_GeV = lemE_end + vernier;
        if get(handles.useRealK,'Value') == 1
            startK = lcaGet('USEG:UND1:150:KDES');
        else
            startK = 3.505;
        end
    case 'useFromDate'
        timeDes = handles.tvec; % Pulled from the values you entered earlier
        deltaT = [ 0 0 0 0 0 30]; % Create a 30-second time window on either side
        
        t_lo = timeDes - deltaT;
        t_hi = timeDes + deltaT;

        t_lo_str = datestr(t_lo, 'mm/dd/yy HH:MM:SS');
        t_hi_str = datestr(t_hi, 'mm/dd/yy HH:MM:SS');

        timeRange = {t_lo_str; t_hi_str};
        
        % Get archived data
        [t, E_eV_data] = getHistory('SIOC:SYS0:ML00:AO627', timeRange);
        [t, lemE_end_data] = getHistory('REFS:DMP1:400:EDES', timeRange);
        [t, vernier_data] = getHistory('FBCK:FB04:LG01:DL2VERNIER', timeRange);
        [t, K_data] = getHistory('USEG:UND1:150:KDES', timeRange);
        
        % Find the medians
        startE_eV = median(E_eV_data);
        lemE_end = median(lemE_end_data);
        vernier = median(vernier_data)*0.001; % Vernier in MeV converted to GeVcmbM@ggie
        startE_GeV = lemE_end + vernier; 
        if get(handles.useRealK,'Value') == 1
            startK = median(K_data);
        else
            startK = 3.505;
        end
    case 'typeItOut'
        startE_eV = handles.enteredE_eV;
        startE_GeV = handles.enteredE_GeV;
        startK = handles.enteredK;
end

desE_eV = str2double(get(handles.finalE_eV,'String'));


% Do the energy estimate
estE_GeV = estimateGeV(desE_eV, startE_eV, startE_GeV, startK);


% Poop out some relevant numbers

startK_str = [ 'U1 K value: ' num2str(startK)];
startE_eVstr = [ num2str(startE_eV) ' eV'];
startE_GeVstr = [ num2str(startE_GeV) ' GeV'];
estE_GeVstr = [ num2str(estE_GeV) ' GeV'];

set(handles.u1K, 'String', startK_str);
set(handles.print_startE_eV, 'String', startE_eVstr,'Visible','on');
set(handles.print_startE_GeV, 'String', startE_GeVstr,'Visible','on');
set(handles.print_estE_GeV, 'String', estE_GeVstr,'Visible','on');

handles.desE_eV = desE_eV;
handles.startE_eV = startE_eV;
handles.startE_GeV = startE_GeV;
handles.startK = startK;
handles.estE_GeV = estE_GeV
guidata(hObject, handles)


% --- Executes on button press in fancyMode.
function fancyMode_Callback(hObject, eventdata, handles)
% hObject    handle to fancyMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fancyMode

isFancyMode = get(handles.fancyMode, 'Value');

fancyFont = 'Gigi';
bigFont = 20;
medFont = 18;
smallFont = 16;

%color1 = [1 0.6 1]; % Orchid
%color2 = [1 0.85 1]; % Pale orchid
color1 = [1.0 0.6 0.784]; % Pink
color2 = [1 0.851 0.922]; % Light pink
color3 = [0.702 0.78 1]; % Periwinkle

if isFancyMode ==1
    set(gcf, 'Color', color1);
    set(handles.pickStart,'FontName',fancyFont,'FontSize',bigFont,'BackgroundColor',color2);
    set(handles.useCurrent,'FontName',fancyFont,'FontSize',smallFont);
    set(handles.useFromDate,'FontName',fancyFont,'FontSize',smallFont);
    set(handles.typeItOut,'FontName',fancyFont,'FontSize',smallFont);
    set(handles.desPhotText,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2);
    set(handles.finalE_eV,'FontName',fancyFont,'FontSize',medFont);
    set(handles.eVtext,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2);
    set(handles.useRealK,'FontName',fancyFont,'FontSize',smallFont,'BackgroundColor',color1,'ForegroundColor','k');
    
    set(handles.doCalc,'FontName',fancyFont,'BackgroundColor',color3);
    
    set(handles.uipanel2,'FontName',fancyFont,'FontSize',bigFont,'BackgroundColor',color2);
    set(handles.u1K,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2);
    set(handles.startingPhotonE,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2,'Position',[3.167 10.85 40 2]);
    set(handles.print_startE_eV,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2);
    set(handles.startingElectronE,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2,'Position',[3.167 7.25 40 2]);
    set(handles.print_startE_GeV,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2);
    set(handles.calcElectronE,'FontName',fancyFont,'FontSize',medFont,'BackgroundColor',color2);
    set(handles.print_estE_GeV,'FontName',fancyFont,'FontSize',bigFont);
    set(handles.fancyMode,'FontName',fancyFont,'FontSize',smallFont,'BackgroundColor',color1,'ForegroundColor','k');
    
    axes(handles.photoSlot)
    pamImage = imread('/home/physics/alsberg/E_jumper/pam.png');
    image(pamImage)
    axis off
    axis image
else
    set(handles.fancyMode, 'String', 'Fancy mode forever');
end
    




function finalE_eV_Callback(hObject, eventdata, handles)
% hObject    handle to finalE_eV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of finalE_eV as text
%        str2double(get(hObject,'String')) returns contents of finalE_eV as a double


% --- Executes during object creation, after setting all properties.
function finalE_eV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finalE_eV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in pickStart.
function pickStart_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pickStart 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

pickedMethod = get(hObject,'Tag');

switch pickedMethod
    case 'useFromDate'
        prompt = {'Enter date in mm/dd/yyyy format',...
            'Enter time in HH:MM format'};
        dlg_title = 'Pick a time';
        num_lines = 1;
        dayago = clock - [0 0 0 13 0 0];
        def_day = datestr(dayago, 'mm/dd/yyyy');
        def_time = datestr(dayago, 'HH:MM');
        def = {def_day, def_time};
        time_input_cell = inputdlg(prompt, dlg_title, num_lines, def);
        if isempty(time_input_cell)
            time_input_cell = {def_day; def_time};
        end
        time_input_char = char(time_input_cell);
        time_input_cat = [time_input_char(1,:) ' ' time_input_char(2,:)];
        tvec = datevec(time_input_cat, 'mm/dd/yyyy HH:MM');
        handles.tvec = tvec;
        guidata(hObject, handles)
    case 'typeItOut'
        prompt = {'Enter photon energy in eV',...
            'Enter electron energy in GeV',...
            'Enter starting undulator K'};
        dlg_title = 'Gimme value';
        num_lines = 1;
        defE_eV = '8198';
        defE_GeV = '13.452';
        defK = '3.505';
        def = {defE_eV, defE_GeV, defK};
        params_input_cell = inputdlg(prompt, dlg_title, num_lines, def);
        if isempty(params_input_cell)
            params_input_cell = {defE_eV; defE_GeV; defK};
        end
        params_input_char = char(params_input_cell);
        enteredE_eV = params_input_char(1,:);
        enteredE_GeV = params_input_char(2,:);
        enteredK = params_input_char(3,:);
        handles.enteredE_eV = str2double(enteredE_eV);
        handles.enteredE_GeV = str2double(enteredE_GeV);
        handles.enteredK = str2double(enteredK);
        guidata(hObject, handles)
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over useRealK.
function useRealK_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to useRealK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on useRealK and none of its controls.
function useRealK_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to useRealK (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
