function varargout = beamDropOut(varargin)
% BEAMDROPOUT M-file for beamDropOut.fig
%      BEAMDROPOUT, by itself, creates a new BEAMDROPOUT or raises the existing
%      singleton*.
%
%      H = BEAMDROPOUT returns the handle to a new BEAMDROPOUT or the handle to
%      the existing singleton*.
%
%      BEAMDROPOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEAMDROPOUT.M with the given input arguments.
%
%      BEAMDROPOUT('Property','Value',...) creates a new BEAMDROPOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before beamDropOut_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to beamDropOut_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help beamDropOut

% Last Modified by GUIDE v2.5 03-Apr-2009 09:07:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @beamDropOut_OpeningFcn, ...
                   'gui_OutputFcn',  @beamDropOut_OutputFcn, ...
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


% --- Executes just before beamDropOut is made visible.
function beamDropOut_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to beamDropOut (see VARARGIN)

% Choose default command line output for beamDropOut
handles.output = hObject;

% Default values
handles.duration = 10*60; % seconds 






% Update handles structure
guidata(hObject, handles);

% UIWAIT makes beamDropOut wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = beamDropOut_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% prep for elog
handles.output = hObject; % handle to gui figure

% define data pvs
pvPulseID ='PATT:SYS0:1:PULSEIDHSTBR'; % gives pulseIDs at full beam rate
pvCharge = 'BPMS:IN20:221:TMITHSTBR'; % charge at the gun
pvDL250 = 'BPMS:LTU1:250:XHSTBR';
pvDL450 = 'BPMS:LTU1:450:XHSTBR';

% constants

[sys,accelerator]=getSystem();
rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']); 

if rate ~= 0;
    
% update the message board
set(handles.messages,'String',['Rate = ' num2str(rate) 'Hz']);

% collect and  display data

    % if last 2800, collect and display all at once
    sampleChoice = get( get(handles.uipanel2,'SelectedObject'), 'String');
    switch sampleChoice
        case 'Last 2800 Pulses'
            
            %[pulseID, Charge, bpmDL250, bpmDL450, ts] =...
             data =  lcaGet( [ {pvPulseID}; {pvCharge}; {pvDL250}; {pvDL450} ] );
             plotData(data, handles); % update the plots
            
            
            
        case 'Accumulate' %acquire and contiuously update plots
            % loop until accumulation time is up
            % create edef, acquire data, update display
            
    end
    
else
    display('Beam is at Zero Rate')
    set(handles.messages,'String','Zero Beam Rate!');
end

% update the button
set(hObject, 'String', 'Run')
    
function plotData(data, handles)

etaxDL2 = .125 ; % [m] design value for absolute value of dispersion at bpms in dogleg
bendEnergyGeV = lcaGetSmart('BEND:DMP1:400:BDES'); %use bdes for consistency
MeVDL2 = 0 + bendEnergyGeV*(data(3,:)...
                        - data(4,:))/(2*etaxDL2) ;

plot( handles.axes1, diff(data(1,:))  );
ylabel(handles.axes1,'PID increments');
set(handles.axes1,'XLimMode','manual', 'YLim', [-500,500]);

plot( handles.axes2, data(2,:));
ylabel(handles.axes2,'Charge');


plot( handles.axes3, MeVDL2);
ylabel(handles.axes3,'DL2 \Delta E [MeV]');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Send to elog
util_printLog(handles.output); % print main window to elog


function duration_Callback(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duration as text
%        str2double(get(hObject,'String')) returns contents of duration as a double


% --- Executes during object creation, after setting all properties.
function duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


