function varargout = LLRFgui(varargin)
% LLRFGUI M-file for LLRFgui.fig
%      LLRFGUI, by itself, creates a new LLRFGUI or raises the existing
%      singleton*.
%
%      H = LLRFGUI returns the handle to a new LLRFGUI or the handle to
%      the existing singleton*.
%
%      LLRFGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LLRFGUI.M with the given input arguments.
%
%      LLRFGUI('Property','Value',...) creates a new LLRFGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LLRFgui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      exit_gui.  All inputs are passed to LLRFgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LLRFgui

% Last Modified by GUIDE v2.5 10-Jun-2013 14:53:57
% Last Update 21-Jun-2013  ver 15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LLRFgui_OpeningFcn, ...
    'gui_OutputFcn',  @LLRFgui_OutputFcn, ...
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

% --- Executes just before LLRFgui is made visible.
function LLRFgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LLRFgui (see VARARGIN)

%Initialize the pull down program menu
h = findobj('Tag', 'program_selection');
selProgramList = {'       Phase Rotation';'         Pulse Shape';...
    'Average Ampl and Phase';'        PLL Waveform'};%Curly braces!!!
set(h,'String', selProgramList,'Value',3);

%Initialize the pull down signal selection menu
h = findobj('Tag', 'signal_selection');
selSignalList = {'   THALES LSR';'   GUN1';...
    '   L0A';'   L0B';'   TC0';'   L1S';...
    '   L1X';'   TC3';'   COHERENT LSR';'   XTCAV'};%Curly braces!!!
set(h,'String', selSignalList,'Value',1 );

%Initialize the pull down phase PAC selection, # of rotation and phase step
selPhasePacList = {'      MDL';'Local Osc';'     Clock';...
    '     Laser';'    Ref RF';'    S24 Ref'};%Curly braces!!!
selRotationList = ('1');
selPhaseList = ('2');

%Initialize the axis1 - invisible at first
h = findobj('Tag', 'axes1');
P=get(h,'position');


%%%%%*****************************
%DEFINE HANDLES PARAMETERS
handles = struct( 'output', ...
    hObject, ...  % pointer to figure window
    'phase_pac_selection',[],...
    'phase_step',selPhaseList,...
    'full_rotation',selRotationList,...
    'graph_position',P,...
    'pvNamesSel',1,...
    'pvNamesSel_2',1,...
    'averaging_time','10',...
    'pulse_width','512',...
    'rotation_direction',get(findobj('Tag','rotation_direction'),'Value'),...
    'Return',0,...
    'max_phase',[],...
    'exportFig',[]);
%%%*******************************

guidata(handles.output,handles);


% Choose default command line output for LLRFgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = LLRFgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in program_selection.
function program_selection_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns program_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from program_selection

% make the polar graph invisible when changing program.
% find the index of the Gui figure children for the polar graph
c=get(gcf,'children');
t=get(c,'type');
index=find(strcmp('axes',t));
set(c(index),'position',[100 100 1 1]); %move the graph out of the Gui

%change GUI window with the selected program
h1 = findobj('Tag','program_selection');
idAction = get(h1,'Value');
switch idAction
    case 1   %PHASE ROTATION
        h=findobj('Tag', 'phase_pac_selection');
        selPhasePacList = {'      MDL';'Local Osc';'     Clock';...
            '     Laser';'    Ref RF';'    S24 Ref'};%Curly braces!!!
        set(h,'Visible','on','String',selPhasePacList,...
            'Position',[21.6 24.4 15,1.7],'Value',1)
        set(findobj('Tag','phase_step'),'Visible','on','String',2)
        set(findobj('-regexp','Tag','rotation'),'Visible','on')
        set(findobj('Tag', 'select_averaging_time'),'Visible','off')
        set(findobj('Tag', 'signal_selection'),'Visible','off')
        set(findobj('-regexp','Tag','text[2-5,9-10]'),'Visible','on')
        set(findobj('Tag', 'text2'),'String','Phase Step');
        set(findobj('Tag', 'text6'),'Visible','on','Position',...
            [15.5 25.3 28.2 2.1],'String', 'PAC Selection')
        set(findobj('-regexp','Tag','text[7-8]'),'Visible','off')
        set(findobj('Tag', 'text23'),'Visible','off')
        set(findobj('Tag','Logbook'),'Visible','off')
        set(findobj('Tag', 'text4'),'String','Completed Rotations');
        set(findobj('Tag', 'text5'),'String',num2str(0))
        handles.pvNamesSel = 1;

    case 2  %PULSE SHAPE
        h=findobj('Tag', 'phase_pac_selection');
        selPulseList = {'   Cell 1A';'   Cell 1B';'   Cell 2A';...
            '   Cell 2B'};
        set(h,'String', selPulseList,'Visible','on','Value',1,...
            'Position',[25,23.7,15,1.7]);
        set(findobj('-regexp','Tag','rotation'),'Visible','off')
        set(findobj('Tag', 'phase_step'),'Visible','off')
        set(findobj('Tag', 'select_averaging_time'),'Visible','on',...
            'String','512','Position',[45, 23.7, 13.2, 1.6]);
        set(findobj('Tag', 'signal_selection'),'Visible','on')
        set(findobj('Tag', 'text6'),'Visible','on','String','Signal Select',...
            'Position',[25,25.46, 15,1.7]);
        set(findobj('Tag', 'text7'),'Visible','on','String','Width',...
            'Position',[44,25.46, 15,1.7]);
        set(findobj('Tag', 'text8'),'String','Pulse PAD');
        set(findobj('-regexp','Tag','text[8,10]'),'Visible','on')
        set(findobj('Tag','Logbook'),'Visible','on')
        set(findobj('-regexp','Tag','text1[1-9]'),'Visible','off')
        set(findobj('-regexp','Tag','text[2-5,9]'),'Visible','off')

        %Initialize the pull down signal selection menu
        h = findobj('Tag', 'signal_selection');
        selSignalList = {'   GUN';'   GUN TUNE';...
            '   L0 A-B IN / OUT';'L1S 21-1B / C/ D';...
            '   L1X IN / OUT';'       TC0';'       TC3'};%Curly braces!!!
        set(h,'String', selSignalList );
        set(h,'value',1);
        handles.pvNamesSel   = 1;
        handles.pvNamesSel_2 = 1;
        handles.pulse_width = '512';

    case 3   %AVERAGE AMPLITUDE AND PHASE PLOT
        set(findobj('Tag', 'select_averaging_time'),'Visible','on',...
            'String','10','Position',[39.8 23.385 13.2 1.846])
        set(findobj('Tag', 'text7'),'Visible','on','String',...
            'Averaging Time [s]','Position',[36.8 25.385 22.2 1.923])
        set(findobj('Tag', 'signal_selection'),'Visible','on')
        set(findobj('Tag', 'phase_pac_selection'),'Visible','off')
        set(findobj('Tag', 'phase_step'),'Visible','off')
        set(findobj('Tag', 'full_rotation'),'Visible','off')
        set(findobj('Tag', 'rotation_direction'),'Visible','off')
        set(findobj('Tag', 'text8'),'String','Select VME');
        set(findobj('-regexp','Tag','text[5,8]'),'Visible','on')
        set(findobj('-regexp','Tag','text[2-4,6,9]'),'Visible','off')
        set(findobj('-regexp','Tag','text1[1-9]'),'Visible','off')
        set(findobj('Tag', 'text10'),'Visible','off')
        set(findobj('Tag', 'text4'),'Visible','on','String','Seconds Remaining')
        set(findobj('Tag','Logbook'),'Visible','on')
        %Initialize the pull down signal selection menu
        h = findobj('Tag', 'signal_selection');
        selSignalList = {'   THALES LSR';'   GUN1';...
            '   L0A';'   L0B';'   TC0';'   L1S';...
            '   L1X';'   TC3';'   COHERENT LSR';'   XTCAV'};%Curly braces!!!
        set(h,'String', selSignalList,'Value',1 );
        set(findobj('Tag', 'text5'),'String',num2str(0))
        handles.pvNamesSel_2 = 1;
        handles.averaging_time = '10';
    case 4  %PLL WAVEFORM
        set(findobj('Tag', 'select_averaging_time'),'Visible','off')
        set(findobj('Tag', 'text7'),'Visible','off')
        set(findobj('Tag', 'signal_selection'),'Visible','off')
        
        h=findobj('Tag', 'phase_pac_selection');
        selPulseList = {'  Average Wave';' Fourier Transform'};
        set(h,'String', selPulseList,'Visible','on','Value',1,...
            'Position',[18,27,25,1.7]);
        
        set(findobj('Tag', 'phase_step'),'Visible','off')
        set(findobj('Tag', 'full_rotation'),'Visible','off')
        set(findobj('Tag', 'rotation_direction'),'Visible','off')
        set(findobj('-regexp','Tag','text[2-4,6,8,9]'),'Visible','off')
        set(findobj('-regexp','Tag','text1[1-9]'),'Visible','off')
        set(findobj('Tag', 'text10'),'Visible','off')
        set(findobj('Tag', 'text4'),'Visible','on','String','Elapsed Seconds')
        set(findobj('Tag', 'text5'),'Visible','on','String',num2str(0))
        set(findobj('Tag','Logbook'),'Visible','on')
        handles.pvNamesSel = 1;
end %switch
guidata(handles.output,handles);  %update handles


% --- Executes during object creation, after setting all properties.
function program_selection_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phase_step_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of phase_step as text
%        str2double(get(hObject,'String')) returns contents of phase_step as a double


% --- Executes during object creation, after setting all properties.
program = get(findobj('Tag','program_selection'),'Value');
if program == 4
figure(1)
max_freq = str2num(get(findobj('Tag','phase_step'),'String'));
axis([0,max_freq,0,1.2e5]);
else
phase_step= get(hObject,'String');
handles.phase_step = phase_step;
end
guidata(handles.output,handles);


function phase_step_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function full_rotation_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of full_rotation as text
%        str2double(get(hObject,'String')) returns contents of full_rotation as a double
full_rotation= get(hObject,'String');
handles.full_rotation = full_rotation;
guidata(handles.output,handles); %Updates GUI

% --- Executes during object creation, after setting all properties.
function full_rotation_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exit_gui.
function exit_gui_Callback(hObject, eventdata, handles)
close all
return


% --- Executes on button press in start_program.
function start_program_Callback(hObject, eventdata, handles)

%First update the parameters from the GUI windows
handles.phase_step = get(findobj('Tag','phase_step'),'String');
handles.full_rotation = get(findobj('Tag','full_rotation'),'String');
guidata(hObject, handles); %update handles
idAction = get(findobj('Tag','program_selection'),'Value');
String   = get(findobj('Tag','start_program'),'String');
switch idAction
    case 1
        if strcmp(String,'STOP')
            handles.Return = 1; %% flag to stop early
            guidata(handles.output,handles);
        else
            set(findobj('Tag','start_program'),'string','STOP');
            LLRFgui_phase_rotation(hObject, eventdata, handles);
            handles=guidata(handles.output);
        end

    case 2
        LLRFgui_pulse_shape(hObject, eventdata, handles);
        handles=guidata(handles.output);
    case 3
        if strcmp(String,'STOP')
            handles.Return = 1; %% flag to stop early
            guidata(handles.output,handles);
        else
            set(findobj('Tag','start_program'),'string','STOP');
            LLRFgui_average_ampl_phase(hObject, eventdata, handles)
            handles=guidata(handles.output);
            handles.Return = 0;
            set(findobj('Tag','start_program'),'string','START')
            guidata(handles.output,handles);
            handles=guidata(handles.output);
        end
    case 4
        if strcmp(String,'RUNNING')
        else
            set(findobj('Tag','start_program'),'String','RUNNING')
            LLRFgui_pll_waveform(hObject, eventdata, handles)
            handles=guidata(handles.output);
        end
end %switch


% --- Executes on selection change in phase_pac_selection.
function phase_pac_selection_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns phase_pac_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phase_pac_selection
h1 = findobj('Tag','phase_pac_selection');
handles.pvNamesSel = get(h1,'Value');
guidata(handles.output,handles); %Updates GUI
h3 = findobj('Tag','phase_step');
program = get(findobj('Tag','program_selection'),'Value');
switch handles.pvNamesSel
    case {1 4}
        set(h3,'string','2');
        if program == 4
        set(findobj('Tag', 'text4'),'String','Elapsed Seconds')
        set(findobj('Tag', 'text5'),'String',num2str(0))
        set(findobj('Tag','phase_step'),'Visible','Off')
        set(findobj('Tag','text2'),'Visible','Off')
        end
    case {2 3 5 6}
        set(h3,'string','30');
        if program == 4
        set(findobj('Tag', 'text4'),'String',{'FFT Resolution';'[Hz]'})
        set(findobj('Tag', 'text5'),'String',' ')
        set(findobj('Tag','phase_step'),'Visible','Off')
        set(findobj('Tag','text2'),'Visible','Off')
        end
end
guidata(handles.output,handles);

% --- Executes during object creation, after setting all properties.
function phase_pac_selection_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function select_averaging_time_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of select_averaging_time as text
%        str2double(get(hObject,'String')) returns contents of select_averaging_time as a double
handles.averaging_time = get(hObject,'String');
handles.pulse_width = handles.averaging_time; %
guidata(handles.output,handles); %Updates GUI

% --- Executes during object creation, after setting all properties.
function select_averaging_time_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change of VME or PAD (Av_ampl_phas or Puls_shape).
function signal_selection_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns signal_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signal_selection
% check selected program
h1 = findobj('Tag','program_selection');
idAction = get(h1,'Value');
switch idAction
    case 2
        h2 = findobj('Tag','signal_selection');
        idAction2 = get(h2,'Value');
        h3 = findobj('Tag', 'phase_pac_selection'); %Labeled "Signal Select"
        switch idAction2

            case 1
                selPulseList = {'   Cell 1A';'   Cell 1B';'   Cell 2A';...
                    '   Cell 2B'};
                set(h3,'String', selPulseList,'Value',1);

            case 2
                selPulseList = {'   Forward RF';'   Reflected RF';...
                    '   Spare 1';'   Spare 2'};
                set(h3,'String', selPulseList,'Value',1);

            case 3
                selPulseList = {'   L0A IN';'   L0A OUT';...
                    '   L0B IN';'   L0B OUT'};
                set(h3,'String', selPulseList,'Value',1);

            case 4
                selPulseList = {'   21-1B IN';'   21-1B OUT';'   21-1C OUT';...
                    '   21-1D OUT'};
                set(h3,'String', selPulseList,'Value',1);

            case 5
                selPulseList = {'   L1X IN';'   L1X OUT';...
                    '   Spare 1';'   Spare 2'};
                set(h3,'String', selPulseList,'Value',1);

            case 6
                selPulseList = {'  TC0 IN';' TC0 OUT';...
                    '   Spare 1';'   Spare 2'};
                set(h3,'String', selPulseList,'Value',1);
            case 7
                selPulseList = {'  TC3 IN';' TC3 OUT';...
                    '   Spare 1';'S24-2856MHz'};
                set(h3,'String', selPulseList,'Value',1);
        end

end
h1 = findobj('Tag','signal_selection');
handles.pvNamesSel_2 = get(h1,'Value');
h3 = findobj('Tag', 'phase_pac_selection');
handles.pvNamesSel = get(h3,'Value');

guidata(handles.output,handles); %Updates GUI

% --- Executes during object creation, after setting all properties.
function signal_selection_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton "Direction".
function rotation_direction_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton1
h1 = findobj('Tag','rotation_direction');
idAction = get(h1,'Value');
if idAction ==0
    set(h1, 'String', 'CCW' );
else
    set(h1, 'String', 'CW' );
end
handles.rotation_direction = idAction;
guidata(handles.output,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/acclegr/LLRFgui.m', which('LLRFgui'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end


% --- Executes on button press in Logbook.
function Logbook_Callback(hObject, eventdata, handles)
%util_printLog(handles.exportFig)
print(handles.exportFig,'-dpsc2','-Pphysics-lclslog');


% --- Executes on button press in close_fig.
function close_fig_Callback(hObject, eventdata, handles)
% hObject    handle to close_fig (see GCBO)

close(1:handles.exportFig)
return

