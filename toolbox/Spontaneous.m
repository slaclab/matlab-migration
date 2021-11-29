function varargout = Spontaneous(varargin)
% SPONTANEOUS, with its associated GUI Spontaneous.fig, computes and plots
% the intensity of spontaneous radiation from the LCLS undulator in
% anynum2str(eV,'%0f')
% single harmonic or in a group of harmonics, on the transverse plane.
% 
%      SPONTANEOUS, by itself, creates a new SPONTANEOUS or raises the
%      existing
%      singleton*.
%
%      H = SPONTANEOUS returns the handle to a new SPONTANEOUS or the handle to
%      the existing singleton*.
%
%      SPONTANEOUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPONTANEOUS.M with the given input arguments.
%
%      SPONTANEOUS('Property','Value',...) creates a new SPONTANEOUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Spontaneous_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Spontaneous_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Spontaneous

% Last Modified by GUIDE v2.5 10-Dec-2011 22:45:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Spontaneous_OpeningFcn, ...
                   'gui_OutputFcn',  @Spontaneous_OutputFcn, ...
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
end


% --- Executes just before Spontaneous is made visible.
function Spontaneous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Spontaneous (see VARARGIN)

% Choose default command line output for Spontaneous
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Spontaneous wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% This indicates that an input parameter has changed, and further plots
% will require a fresh calculation.
global guiHandle c qe me hbar white gray ELimits KUnd lambdaUnd...
    defaultSlit aperture
guiHandle = gcf;
c    = 2.99792458e8;  % speed of light (m/s)
qe   = 1.6021892e-19; % electron charge (C)
me   = 9.109534e-31;  % electron mass (kg)
hbar = 1.0545887e-34; % Planck's constant /(2*pi)

white= [1,  1,  1  ];
gray = [0.6,0.6,0.6];

KUnd      = str2double(get(handles.KUnd,'String'));
lambdaUnd = str2double(get(handles.lambdaUnd,'String'));
defaultSlit = 10;  % in mm, for each of the 4 slits

Harmonics_Callback(   handles.Harmonics,   eventdata,handles)
GeV_Callback(         handles.GeV,         eventdata,handles)
charge_Callback(      handles.charge,      eventdata,handles)
Girders_Callback(     handles.Girders,     eventdata,handles)
theta_Callback(       handles.theta,       eventdata,handles)
phi_Callback(         handles.phi,         eventdata,handles)
psiOffset_Callback(   handles.psiOffset,   eventdata,handles)
YAG_Callback(         handles.YAG,         eventdata,handles)
EnergySpread_Callback(handles.EnergySpread,eventdata,handles)
xSlit1_Callback(      handles.xSlit1,      eventdata,handles)
xSlit2_Callback(      handles.xSlit2,      eventdata,handles)
ySlit1_Callback(      handles.ySlit1,      eventdata,handles)
ySlit2_Callback(      handles.ySlit2,      eventdata,handles)
aperture = get(handles.Aperture,'Value')*2; % Radius (if set) in gas detector

set(handles.charge,      'BackgroundColor',white)
set(handles.Girders,     'BackgroundColor',white)
set(handles.Harmonics,   'BackgroundColor',white)
set(handles.theta,       'BackgroundColor',gray)
set(handles.phi,         'BackgroundColor',gray)
set(handles.psiOffset,   'BackgroundColor',gray)
set(handles.YAG,         'BackgroundColor',gray)
set(handles.EnergySpread,'BackgroundColor',gray)
set(handles.xSlit1,      'BackgroundColor',gray)
set(handles.xSlit2,      'BackgroundColor',gray)
set(handles.ySlit1,      'BackgroundColor',gray)
set(handles.ySlit2,      'BackgroundColor',gray)
set(handles.StartButton, 'String',         'START')

absorb = load('YagAbsorptionLength.txt','-ascii');
ELimits(2) = 10^(absorb(size(absorb,1),1)); % Maximum energy in YAG table
ELimits(1) = 10^(absorb(1,1));              % Minimum energy in YAG table
end

% --- Outputs from this function are returned to the command line.
function varargout = Spontaneous_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function GeV_Callback(hObject, eventdata, handles)
% hObject    handle to GeV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GeV as text
%        str2double(get(hObject,'String')) returns contents of GeV as a double
global newCalc c qe me hbar GeV eV KUnd lambdaUnd
newCalc = 1;
GeVString = get(hObject,'String');
KMono = get(handles.TaskMenu,'Value') == 8;
colon = strfind(GeVString,':');
OK = 1;
if isempty(colon)
    GeVScan = str2double(GeVString);
    if isnan(GeVScan) || GeVScan <= 0 || GeVScan > 50
        OK = 0;
    end
else
    if colon(1) > 1
        GeVScan(1) = str2double(GeVString(1:colon(1)-1));
        if isnan(GeVScan(1)) || GeVScan(1) <= 0 || GeVScan(1) > 50
            OK = 0;
        end
        if length(colon) == 1
            GeVScan(3) = str2double(GeVString(colon(1)+1:length(GeVString)));
            if isnan(GeVScan(3)) || GeVScan(3) <= 0 || GeVScan(3) > 50
                OK = 0;
            else
                GeVScan(2) = max(1e-4,GeVScan(3)-GeVScan(1));
            end
        elseif length(colon) == 2
            GeVScan(3) = str2double(GeVString(colon(2)+1:length(GeVString)));
            GeVScan(2) = str2double(GeVString(colon(1)+1:colon(2)-1));
            if  isnan(GeVScan(2)) || GeVScan(2) <= 0 ||...
                isnan(GeVScan(3)) || GeVScan(3) < GeVScan(1) ||...
                GeVScan(3) > 50
                OK = 0;
            else
                GeVScan(2) = max(1e-4,GeVScan(2));
            end
        else
            OK = 0;
        end
    end
end
if OK
    if ~isempty(colon) && KMono
        GeV = GeVScan(1):GeVScan(2):GeVScan(3);
    else
        GeV = GeVScan(1);
    end
else
    GeV = 13.64;
    fprintf('%s\n%s%.3f\n',...
        'The beam energy must be between 0 and 50 GeV.',...
        'It is reset to: ',GeV)
end
gamma     = GeV*qe*1e9/(me*c^2);
gammaStar = gamma./sqrt(1+0.5*KUnd(1)^2);
kUnd      = 2*pi/(lambdaUnd*0.001);
eV        = (2*hbar*c*kUnd/qe)*gammaStar.^2;
if length(GeV) > 1
    set(hObject,'String',[num2str(GeVScan(1:2),'%.3f:%.4f:'),...
                          num2str(GeV(length(GeV)),'%.3f')])
    set(handles.eV,'String',num2str([eV(1),eV(length(eV))],'%.1f:%.1f'))
elseif length(GeV) == 1 && KMono
    set(hObject,'String',num2str([GeV,GeV],'%.3f:%.3f'))
    set(handles.eV,'String',num2str(eV,'%.1f'))
else
    set(hObject,'String',num2str(GeV,'%.3f'))
    set(handles.eV,'String',num2str(eV,'%.1f'))
end
Harmonics_Callback(handles.Harmonics,eventdata,handles)
end

% --- Executes during object creation, after setting all properties.
function GeV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GeV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function eV_Callback(hObject, eventdata, handles)
% hObject    handle to eV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eV as text
%        str2double(get(hObject,'String')) returns contents of eV as a double
global newCalc c qe me hbar GeV eV KUnd lambdaUnd
newCalc = 1;
eVString = get(hObject,'String');
KMono = get(handles.TaskMenu,'Value') == 8;
colon = strfind(eVString,':');
OK = 1;
if isempty(colon)
    eVScan = str2double(eVString);
    if isnan(eVScan) || eVScan <= 0 || eVScan > 1e5
        OK = 0;
    end
else
    if colon(1) > 1
        eVScan(1) = str2double(eVString(1:colon(1)-1));
        if isnan(eVScan(1)) || eVScan(1) <= 0 || eVScan(1) > 1e5
            OK = 0;
        end
        if length(colon) == 1
            eVScan(2) = str2double(eVString(colon(1)+1:length(eVString)));
            if isnan(eVScan(2)) || eVScan(2) < eVScan(1) || eVScan(2) > 1e5
                OK = 0;
            end
        else
            OK = 0;
        end
    end
end        
if OK
    if ~isempty(colon) && KMono
        eV = eVScan;
    else
        eV = eVScan(1);
    end
else
    fprintf('%s\n%s\n%s%s\n%s%.1f\n',...
        'Energy scans are done in equal steps of beam energy.',...
        'Since the photon energy goes like gamma^2, only the',...
        'end points of the scan are shown here.',...
        'The photon energy must be between 0 and 100 keV.',...
        'It is reset to: ',eV)
end
kUnd   = 2*pi/(lambdaUnd*0.001);
gamma  = sqrt((1+0.5*KUnd(1)^2)*(eV*qe/(2*hbar*c*kUnd)));
GeVNew = gamma*1e-9*me*c^2/qe;
if length(eV) > 1
    GeVScan(1) = GeVNew(1);
    GeVScan(3) = GeVNew(2);
    if length(GeV) > 1
        GeVScan(2) = GeV(2)-GeV(1);
    else
        GeVScan(2) = max(1e-4,GeVScan(3)-GeVScan(1));
    end
    set(hObject,'String',num2str(eV,'%.1f:%.1f'))
    set(handles.GeV,'String',num2str(GeVScan,'%.3f:%.4f:%.3f'))
else
    set(hObject,'String',num2str(eV,'%.1f'))
    set(handles.GeV,'String',num2str(GeVNew,'%.3f'))
end
GeV_Callback(handles.GeV,eventdata,handles)
end

% --- Executes during object creation, after setting all properties.
function eV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function charge_Callback(hObject, eventdata, handles)
% hObject    handle to charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge as text
%        str2double(get(hObject,'String')) returns contents of charge as a double
global newCalc charge
newCalc = 1;
charge = str2double(get(hObject,'String'));
if charge <= 0 || charge > 5000 || isnan(charge)
    charge = 250;
    fprintf('%s\n%s%d\n',...
        'The charge must be between 0 and 5000 pC.',...
        'It is reset to:',charge)
    set(hObject,'String',num2str(charge))
end
end

% --- Executes during object creation, after setting all properties.
function charge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function EnergySpread_Callback(hObject, eventdata, handles)
% hObject    handle to EnergySpread (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EnergySpread as text
%        str2double(get(hObject,'String')) returns contents of EnergySpread as a double
global newCalc EnergySpread
newCalc = 1;
EnergySpread = str2double(get(hObject,'String'));
if (EnergySpread < 0.01 && EnergySpread ~= 0) ||...
        EnergySpread > 100 || isnan(EnergySpread)
    EnergySpread = 0;
    fprintf('%s\n%s\n%s\n',...
        'The fractional energy spread entered here is in units of 1e-4.',...
        'It must be 0, or between 0.01 and 100 (* 0.0001).',...
        'It is reset to 0.')
    set(hObject,'String',num2str(EnergySpread))
end
end

% --- Executes during object creation, after setting all properties.
function EnergySpread_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnergySpread (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function KUnd_Callback(hObject, eventdata, handles)
% hObject    handle to KUnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of KUnd as text
%        str2double(get(hObject,'String')) returns contents of KUnd as a double
global newCalc KUnd girder
newCalc = 1;
KUndString = get(hObject,'String');
colon = strfind(KUndString,':');
KMono = get(handles.TaskMenu,'Value') == 8;
NGirder = 1;
if KMono
    NGirder = girder(2)-girder(1)+1;
end
OK = 1;
if strncmp(KUndString,'KACT',4)
    % Use only the first girder's value for calculations,
    % except for K-Mono calculation, which gets all girder values.
    KUnd = 3.5*ones(1,NGirder);
    for g = 1:NGirder
        gird = girder(1)+g-1;
        try
            KU = lcaGetSmart(['USEG:UND1:',num2str(gird),'50:KACT']);
            if KU <= 0 || isnan(KU)
                OK = 0;
            else
                KUnd(g) = KU;
            end
        catch
            disp(lasterror)
            OK = 0;
        end
    end
    KUndStrOut = 'KACT';
    if ~OK
        KUnd = 3.5;
        fprintf('%s\n%s\n',...
        'Valid KACTs could not be read for all girders in the range.',...
        'Specify the K value(s) instead.')
    end
else
    if isempty(colon)
        KUndScan = str2double(KUndString);
        if isnan(KUndScan) || KUndScan <= 0 || KUndScan > 20
            OK = 0;
        end
    else
        if colon(1) > 1
            KUndScan(1) = str2double(KUndString(1:colon(1)-1));
            if isnan(KUndScan(1)) || KUndScan(1) <= 0 || KUndScan(1) > 20
                OK = 0;
            end
            if NGirder > 1
                if length(colon) == 1
                    KUndScan(3) = str2double(...
                        KUndString(colon(1)+1:length(KUndString)));
                    if isnan(KUndScan(3)) ||...
                            KUndScan(3) <= 0 || KUndScan(3) > 20
                        OK = 0;
                    else
                        KUndScan(2) = (KUndScan(3)-KUndScan(1))/(NGirder-1);
                    end
                elseif length(colon) == 2 && NGirder > 1
                    KUndScan(3) = str2double(...
                        KUndString(colon(2)+1:length(KUndString)));
                    KUndScan(2) = str2double(...
                        KUndString(colon(1)+1:colon(2)-1));
                    if isnan(KUndScan(2)) || isnan(KUndScan(3)) ||...
                            KUndScan(3) < KUndScan(1) || KUndScan(3) > 20
                        OK = 0;
                    else
                        KUndScan(2) = min(KUndScan(2),...
                            (KUndScan(3)-KUndScan(1))/(NGirder-1));
                    end
                else
                    OK = 0;
                end
            end
        end
    end
    if OK
        if ~isempty(colon) && NGirder > 1 && KMono
            KUnd = KUndScan(1):KUndScan(2):KUndScan(3);
            KUnd = KUnd(1:NGirder);
            KUndScan(3) = KUnd(NGirder);
            if strcmp(KUndString,'KACT')
                KUndStrOut = 'KACT';
            else
                KUndStrOut = num2str(KUndScan,'%.4f:%.4f:%.4f');
            end
        else
            KUnd = KUndScan;
            KUndStrOut = num2str(KUnd,'%.4f');
        end
    else
        KUnd = 3.5;
        KUndStrOut = num2str(KUnd,'%.4f');
        fprintf('%s\n%s%3.2f\n',...
        'KUnd must be between 0 and 20.',...
        'It is reset to: ',KUnd)
    end
end
set(hObject,'String',KUndStrOut)
GeV_Callback(handles.GeV,eventdata,handles)
end

% --- Executes during object creation, after setting all properties.
function KUnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KUnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lambdaUnd_Callback(hObject, eventdata, handles)
% hObject    handle to lambdaUnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambdaUnd as text
%        str2double(get(hObject,'String')) returns contents of lambdaUnd as a double
global newCalc c qe me hbar GeV KUnd lambdaUnd
newCalc = 1;
lambdaUnd = str2double(get(hObject,'String'));
if lambdaUnd <= 0 || lambdaUnd > 1000 || isnan(lambdaUnd)
    lambdaUnd = 30;
    fprintf('%s\n%s%d\n',...
        'lambdaUnd must be between 0 and 1000 mm.',...
        'It is reset to: ',lambdaUnd)
    set(hObject,'String',num2str(lambdaUnd))
end
gamma     = GeV(1)*qe*1e9/(me*c^2);
gammaStar = gamma/sqrt(1+0.5*KUnd(1)^2);
kUnd      = 2*pi/(lambdaUnd*0.001);
eV        = 2*hbar*c*kUnd*gammaStar^2/qe;
set(handles.eV,'String',num2str(eV,'%4.0f'))
Harmonics_Callback(handles.Harmonics,eventdata,handles)
end

% --- Executes during object creation, after setting all properties.
function lambdaUnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambdaUnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Girders_Callback(hObject, eventdata, handles)
% hObject    handle to Girders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Girders as text
%        str2double(get(hObject,'String')) returns contents of Girders as a
%        double
global newCalc girder
newCalc = 1;
girderString = get(hObject,'String');
colon = strfind(girderString,':');
girder = [1 1];
OK = 1;
if isempty(colon)
    girder(1) = str2double(girderString);
    if isnan(girder(1)) || girder(1) < 1 || girder(1) > 33
        OK = 0;
        girder(1) = 1;
    end
    girder(2) = girder(1);
else
    if colon(1) > 1
        girder(1) = str2double(girderString(1:colon(1)-1));
        if isnan(girder(1)) || girder(1) < 1 || girder(1) > 33
            OK = 0;
            girder(1) = 1;
        end
        if length(colon) == 1
            girder(2) = str2double(girderString(colon(1)+1:length(girderString)));
            if isnan(girder(2)) || girder(2) < girder(1) || girder(2) > 33
                OK = 0;
                girder(2) = girder(1);
            end
        else
            OK = 0;
            girder(2) = girder(1);
        end
    end
end        
if ~OK
    fprintf('%s\n%s%d%s%d\n',...
        'The girders must be between 1 and 33.',...
        'They are reset to: ',girder(1),':',girder(2))
end
set(hObject,'String',[num2str(girder(1)),':',num2str(girder(2))])
if strncmp(get(handles.KUnd,'String'),'KACT',4)
    KUnd_Callback(handles.KUnd,eventdata,handles)
    eV_Callback(handles.eV,eventdata,handles)
end
end

% --- Executes during object creation, after setting all properties.
function Girders_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Girders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Harmonics_Callback(hObject, eventdata, handles)
% hObject    handle to Harmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Harmonics as text
%        str2double(get(hObject,'String')) returns contents of Harmonics as a double
global newCalc ELimits eV harmonic
newCalc = 1;
harmString = get(hObject,'String');
colon = strfind(harmString,':');
harmonic = [1 1];
OK = 1;
YagOK = 1;
task = get(handles.TaskMenu,'Value');

if isempty(colon)
    harmonic(1) = str2double(harmString);
    if isnan(harmonic(1)) || harmonic(1) < 1 || harmonic(1) > 30
        OK = 0;
        harmonic(1) = 1;
    end
    if task == 7 && min(eV)*harmonic(1) < ELimits(1)
        YagOK = 0;
        harmonic(1) = min(30,ceil(ELimits(1)/min(eV)));
    end
    harmonic(2) = harmonic(1);
else
    if colon(1) > 1
        harmonic(1) = str2double(harmString(1:colon(1)-1));
        if isnan(harmonic(1)) || harmonic(1) < 1 || harmonic(1) > 30
            OK = 0;
            harmonic(1) = 1;
        end
        if task == 7 && min(eV)*harmonic(1) < ELimits(1)
            YagOK = 0;
            harmonic(1) = min(30,ceil(ELimits(1)/min(eV)));
        end
        if length(colon) == 1
            harmonic(2) = str2double(harmString(colon(1)+1:length(harmString)));
            if isnan(harmonic(2)) || harmonic(2) < harmonic(1) || harmonic(2) > 30
                OK = 0;
                harmonic(2) = harmonic(1);
            end
            if task == 7 && max(eV)*harmonic(2) > ELimits(2)
                YagOK = 0;
                harmonic(2) = min(30,floor(ELimits(2)/max(eV)));
                harmonic(1) = min(harmonic);
            end
        else
            OK = 0;
            harmonic(2) = harmonic(1);
        end
    end
end        
if ~OK
    fprintf('%s\n%s%d%s%d\n',...
        'You can calculate harmonics only between 1 and 30.',...
        'The harmonic range is reset to: ',harmonic(1),':',harmonic(2))
end
if ~YagOK
    fprintf('%s\n%s%d%s%d\n',...
        'To stay within the range of the YAG absorption table,',...
        'the harmonic range was reset to: ',harmonic(1),':',harmonic(2))
end
set(hObject,'String',[num2str(harmonic(1)),':',num2str(harmonic(2))])
end

% --- Executes during object creation, after setting all properties.
function Harmonics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Harmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function theta_Callback(hObject, eventdata, handles)
% hObject    handle to theta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of theta as text
%        str2double(get(hObject,'String')) returns contents of theta as a double
global theta
theta = str2double(get(hObject,'String'));
if theta < 0 || theta > 5000 || isnan(theta)
    theta = 0;
    fprintf('%s\n%s%d\n',...
        'Theta must be between 0 and 5000 urad.',...
        'It is reset to:',theta)
    set(hObject,'String',num2str(theta))
end
end

% --- Executes during object creation, after setting all properties.
function theta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function phi_Callback(hObject, eventdata, handles)
% hObject    handle to phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi as text
%        str2double(get(hObject,'String')) returns contents of phi as a double
global phi
phiIn = str2double(get(hObject,'String'));
if isnan(phiIn)
    phi = 0;
else
    phi = mod(phiIn,360);
    if phi > 180
        phi = phi-360;
    end
end
if phi ~= phiIn
    fprintf('%s\n%s%d\n',...
        'Phi must be between -180 and 180 degrees.',...
        'It is reset to: ',phi)
    set(hObject,'String',num2str(phi))
end
end

% --- Executes during object creation, after setting all properties.
function phi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function psiOffset_Callback(hObject, eventdata, handles)
% hObject    handle to psiOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psiOffset as text
%        str2double(get(hObject,'String')) returns contents of psiOffset as a double
global newCalc psiOffset
newCalc = 1;
psiOffString = get(hObject,'String');
KMono = get(handles.TaskMenu,'Value') == 8;
colon = strfind(psiOffString,':');
OK = 1;
if isempty(colon)
    psiOffScan = str2double(psiOffString);
    if isnan(psiOffScan) || abs(psiOffScan) > 100
        OK = 0;
    end
else
    if colon(1) > 1
        psiOffScan(1) = str2double(psiOffString(1:colon(1)-1));
        if isnan(psiOffScan(1)) || abs(psiOffScan(1)) > 100
            OK = 0;
        end
        if length(colon) == 1
            psiOffScan(3) = str2double(psiOffString(colon(1)+1:length(psiOffString)));
            if isnan(psiOffScan(3)) || abs(psiOffScan(1)) > 100
                OK = 0;
            else
                psiOffScan(2) = max(0.1,psiOffScan(3)-psiOffScan(1));
            end
        elseif length(colon) == 2
            psiOffScan(3) = str2double(psiOffString(colon(2)+1:length(psiOffString)));
            psiOffScan(2) = str2double(psiOffString(colon(1)+1:colon(2)-1));
            if  isnan(psiOffScan(2)) || psiOffScan(2) <= 0 ||...
                isnan(psiOffScan(3)) || psiOffScan(3) < psiOffScan(1) ||...
                psiOffScan(3) > 100
                OK = 0;
            else
                psiOffScan(2) = max(0.1,psiOffScan(2));
            end
        else
            OK = 0;
        end
    end
end
if OK
    if ~isempty(colon) && KMono
        psiOffset = psiOffScan(1):psiOffScan(2):psiOffScan(3);
        psiOffStrOut = [num2str(psiOffScan(1),'%.1f:'),...
          num2str(psiOffScan(2),'%.1f:'),...
          num2str(psiOffset(length(psiOffset)),'%.1f')];
    else
        psiOffset = psiOffScan(1);
        psiOffStrOut = num2str(psiOffset,'%.1f');
    end
else
    psiOffset = 0;
    psiOffStrOut = num2str(psiOffset,'%.1f');
    fprintf('%s\n%s%.1f\n',...
        'The x angle offset must be between -100 and +100 urad.',...
        'It is reset to:',psiOffset)
end
set(hObject,'String',num2str(psiOffStrOut,'%.1f'))
end

% --- Executes during object creation, after setting all properties.
function psiOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psiOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function YAG_Callback(hObject, eventdata, handles)
% hObject    handle to YAG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YAG as text
%        str2double(get(hObject,'String')) returns contents of YAG as a double
global yag
yagIn = str2double(get(hObject,'String'));
if yagIn >= 10 && yagIn <= 1000 && ~isnan(yagIn)
    yag = round(yagIn);
end
if yag ~= yagIn
    fprintf('%s\n%s%d\n',...
        'YAG thickness must be between 10 um and 1 mm.',...
        'It is reset to: ',yag)
end
set(hObject,'String',num2str(yag))
end

% --- Executes during object creation, after setting all properties.
function YAG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YAG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function xSlit1_Callback(hObject, eventdata, handles)
% hObject    handle to xSlit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xSlit1 as text
%        str2double(get(hObject,'String')) returns contents of xSlit1 as a double
global newCalc xSlit1 defaultSlit
newCalc = 1;
xSlit1 = str2double(get(hObject,       'String'));
xSlit2 = str2double(get(handles.xSlit2,'String'));
if xSlit1 < xSlit2 || xSlit1 > defaultSlit || isnan(xSlit1)
    xSlit1 = defaultSlit;
    fprintf('%s%d%s\n%s%d%s\n',...
        'The positive x slit must be between the negative slit and ',...
        defaultSlit,' mm.','It is reset to:',xSlit1,' mm.')
    set(hObject,'String',num2str(xSlit1))
end
end

% --- Executes during object creation, after setting all properties.
function xSlit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xSlit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function xSlit2_Callback(hObject, eventdata, handles)
% hObject    handle to xSlit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xSlit2 as text
%        str2double(get(hObject,'String')) returns contents of xSlit2 as a double
global newCalc xSlit2 defaultSlit
newCalc = 1;
xSlit1 = str2double(get(handles.xSlit1,'String'));
xSlit2 = str2double(get(hObject,       'String'));
if xSlit2 > xSlit1 || xSlit2 < -defaultSlit || isnan(xSlit2)
    xSlit2 = -defaultSlit;
    fprintf('%s%d%s\n%s%d%s\n',...
        'The negative x slit must be between the postive slit and ',...
        -defaultSlit,' mm.','It is reset to:',xSlit2,' mm.')
    set(hObject,'String',num2str(xSlit2))
end
end

% --- Executes during object creation, after setting all properties.
function xSlit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xSlit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function ySlit1_Callback(hObject, eventdata, handles)
% hObject    handle to ySlit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ySlit1 as text
%        str2double(get(hObject,'String')) returns contents of ySlit1 as a double
global newCalc ySlit1 defaultSlit
newCalc = 1;
ySlit1 = str2double(get(hObject,       'String'));
ySlit2 = str2double(get(handles.ySlit2,'String'));
if ySlit1 < ySlit2 || ySlit1 > defaultSlit || isnan(ySlit1)
    ySlit1 = defaultSlit;
    fprintf('%s%d%s\n%s%d%s\n',...
        'The positive y slit must be between the negative slit and ',...
        defaultSlit,' mm.','It is reset to:',ySlit1,' mm.')
    set(hObject,'String',num2str(ySlit1))
end
end

% --- Executes during object creation, after setting all properties.
function ySlit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ySlit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function ySlit2_Callback(hObject, eventdata, handles)
% hObject    handle to ySlit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ySlit2 as text
%        str2double(get(hObject,'String')) returns contents of ySlit2 as a double
global newCalc ySlit2 defaultSlit
newCalc = 1;
ySlit1 = str2double(get(handles.ySlit1,'String'));
ySlit2 = str2double(get(hObject,       'String'));
if ySlit2 > ySlit1 || ySlit2 < -defaultSlit || isnan(ySlit2)
    ySlit2 = -defaultSlit;
    fprintf('%s%d%s\n%s%d%s\n',...
        'The negative y slit must be between the positive slit and ',...
        -defaultSlit,' mm.','It is reset to:',ySlit2,' mm.')
    set(hObject,'String',num2str(ySlit2))
end
end

% --- Executes during object creation, after setting all properties.
function ySlit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ySlit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in Aperture.
function Aperture_Callback(hObject, eventdata, handles)
% hObject    handle to Aperture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Aperture
end


% --- Executes on selection change in EnergyTable.
function EnergyTable_Callback(hObject, eventdata, handles)
% hObject    handle to EnergyTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns EnergyTable contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EnergyTable
end

% --- Executes during object creation, after setting all properties.
function EnergyTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnergyTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in TaskMenu.
function TaskMenu_Callback(hObject, eventdata, handles)
% hObject    handle to TaskMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns TaskMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TaskMenu
global newCalc GeV white gray ELimits eV KUnd harmonic
newCalc = 1;
task = get(hObject,'Value');
switch task
    case 1     % Emission vs solid angle, in each harmonic: 3D plots, totals
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',white)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',gray)
        set(handles.psiOffset,   'BackgroundColor',gray)
        psiOffset_Callback(handles.psiOffset,eventdata,handles)
        set(handles.YAG,         'BackgroundColor',gray)
        set(handles.EnergySpread,'BackgroundColor',gray)
        set(handles.xSlit1,      'BackgroundColor',gray)
        set(handles.xSlit2,      'BackgroundColor',gray)
        set(handles.ySlit1,      'BackgroundColor',gray)
        set(handles.ySlit2,      'BackgroundColor',gray)

    case {2 4} % Emission vs theta at fixed phi, in each harmonic:
               %	Plots, peak values
               % Photon energy vs theta at fixed phi, in each harmonic,
               %	with intensity contours
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',white)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',white)
        set(handles.psiOffset,   'BackgroundColor',gray)
        psiOffset_Callback(handles.psiOffset,eventdata,handles)
        set(handles.YAG,         'BackgroundColor',gray)
        set(handles.EnergySpread,'BackgroundColor',gray)
        set(handles.xSlit1,      'BackgroundColor',gray)
        set(handles.xSlit2,      'BackgroundColor',gray)
        set(handles.ySlit1,      'BackgroundColor',gray)
        set(handles.ySlit2,      'BackgroundColor',gray)
        
    case 3     % Emission vs photon energy at fixed theta and phi
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',white)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.theta,       'BackgroundColor',white)
        set(handles.phi,         'BackgroundColor',white)
        set(handles.psiOffset,   'BackgroundColor',gray)
        psiOffset_Callback(handles.psiOffset,eventdata,handles)
        set(handles.YAG,         'BackgroundColor',gray)
        set(handles.EnergySpread,'BackgroundColor',gray)
        set(handles.xSlit1,      'BackgroundColor',gray)
        set(handles.xSlit2,      'BackgroundColor',gray)
        set(handles.ySlit1,      'BackgroundColor',gray)
        set(handles.ySlit2,      'BackgroundColor',gray)
        
    case 5     %  Photon energy vs theta and electron energy,
               %     in each harmonic: 3D plots
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',gray)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',gray)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',gray)
        set(handles.psiOffset,   'BackgroundColor',gray)
        psiOffset_Callback(handles.psiOffset,eventdata,handles)
        set(handles.YAG,         'BackgroundColor',gray)
        set(handles.EnergySpread,'BackgroundColor',gray)
        set(handles.xSlit1,      'BackgroundColor',gray)
        set(handles.xSlit2,      'BackgroundColor',gray)
        set(handles.ySlit1,      'BackgroundColor',gray)
        set(handles.ySlit2,      'BackgroundColor',gray)
        
    case 6     % Energy Distribution on Direct Imager
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',white)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.XYPol,       'Value',          0)
        set(handles.TotalPol,    'Value',          1)
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',gray)
        set(handles.psiOffset,   'BackgroundColor',gray)
        set(handles.YAG,         'BackgroundColor',gray)
        set(handles.EnergySpread,'BackgroundColor',white)
        set(handles.xSlit1,      'BackgroundColor',white)
        set(handles.xSlit2,      'BackgroundColor',white)
        set(handles.ySlit1,      'BackgroundColor',white)
        set(handles.ySlit2,      'BackgroundColor',white)
        
    case 7     % Response vs x and y of the Direct Imager's YAG
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',white)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.XYPol,       'Value',          0)
        set(handles.TotalPol,    'Value',          1)
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',gray)
        set(handles.psiOffset,   'BackgroundColor',gray)
        set(handles.YAG,         'BackgroundColor',white)
        set(handles.EnergySpread,'BackgroundColor',white)
        set(handles.xSlit1,      'BackgroundColor',white)
        set(handles.xSlit2,      'BackgroundColor',white)
        set(handles.ySlit1,      'BackgroundColor',white)
        set(handles.ySlit2,      'BackgroundColor',white)
        if min(eV)*harmonic(1) < ELimits(1)
            harmonic(1) = min(30,ceil(ELimits(1)/min(eV)));
            harmonic(2) = max(harmonic);
            set(hObject,'String',...
                [num2str(harmonic(1)),':',num2str(harmonic(2))])
        end
        if max(eV)*harmonic(2) > ELimits(2)
            harmonic(2) = min(30,floor(ELimits(2)/max(eV)));
            harmonic(1) = min(harmonic);
            set(hObject,'String',...
                [num2str(harmonic(1)),':',num2str(harmonic(2))])
        end
        
    case 8     % Image and energy on Direct Imager through K-Monochromator
        set(handles.charge,      'BackgroundColor',white)
        set(handles.Harmonics,   'String',         '')
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Girders,     'String',         '1:1')
        Girders_Callback(  handles.Girders,  eventdata,handles)
        if length(GeV) > 1
            set(handles.GeV,     'String',[num2str(GeV(1)),':',...
                num2str(GeV(2)-GeV(1)),':',num2str(GeV(length(GeV)))])
        else
            set(handles.GeV,     'String',[num2str(GeV(1)),':0.005:',...
                num2str(GeV(1))])
        end
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.Harmonics,   'BackgroundColor',[0.8,0.8,0.6])
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',gray)
        set(handles.psiOffset,   'BackgroundColor',white)
        psiOffset_Callback(handles.psiOffset,eventdata,handles)
        set(handles.YAG,         'BackgroundColor',gray)
        set(handles.XYPol,       'Value',          0)
        set(handles.TotalPol,    'Value',          1)
        set(handles.EnergySpread,'BackgroundColor',white)
        set(handles.xSlit1,      'BackgroundColor',white)
        set(handles.xSlit2,      'BackgroundColor',white)
        set(handles.ySlit1,      'BackgroundColor',white)
        set(handles.ySlit2,      'BackgroundColor',white)
    otherwise
        set(handles.GeV,         'String',         num2str(GeV(1)))
        GeV_Callback(      handles.GeV,      eventdata,handles)
        set(handles.charge,      'BackgroundColor',white)
        set(handles.KUnd,        'String',         num2str(KUnd(1)))
        KUnd_Callback(     handles.KUnd,     eventdata,handles)
        set(handles.Girders,     'BackgroundColor',white)
        set(handles.Harmonics,   'BackgroundColor',white)
        Harmonics_Callback(handles.Harmonics,eventdata,handles)
        set(handles.theta,       'BackgroundColor',gray)
        set(handles.phi,         'BackgroundColor',gray)
        set(handles.psiOffset,   'BackgroundColor',gray)
        psiOffset_Callback(handles.psiOffset,eventdata,handles)
        set(handles.EnergySpread,'BackgroundColor',gray)
        set(handles.xSlit1,      'BackgroundColor',gray)
        set(handles.xSlit2,      'BackgroundColor',gray)
        set(handles.ySlit1,      'BackgroundColor',gray)
        set(handles.ySlit2,      'BackgroundColor',gray)
end
end

% --- Executes during object creation, after setting all properties.
function TaskMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TaskMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiHandle newCalc GeV charge girder theta phi harmonic...
    KUnd lambdaUnd psiOffset yag EnergySpread xrayEnergy...
    xSlit1 xSlit2 ySlit1 ySlit2 aperture...
    EHarm SDist PDist TDist eV spectrum
set(guiHandle,'HandleVisibility','off')

polarized = get(handles.XYPol,'Value');
set(handles.XYPol,   'Value', polarized)
set(handles.TotalPol,'Value',~polarized)
NUnd      = (girder(2)-girder(1)+1)*113;
slit      = [xSlit1,xSlit2,ySlit1,ySlit2,0]; % FEE slits in mm
newAper = get(handles.Aperture,'Value');
if newAper ~= aperture
    newCalc = 1;
    aperture = newAper;
end
if aperture ~= 0
    slit(5) = 2;  % 2-mm radius for aperture in gas detector
end
set(handles.StartButton,'String','Working')
pause(0.1)
blanks = '            ';
set(handles.EnergyTable,'String','')

% Choice of tasks:
%  1. Emission vs solid angle, in each harmonic: 3D plots, totals
%  2. Emission vs theta at fixed phi, in each harmonic: Plots, peak values
%  3. Emission vs photon energy at fixed theta and phi
%  4. Photon energy vs theta at fixed phi, in each harmonic, with intensity contours
%  5. Photon energy vs theta and electron energy, in each harmonic: 3D plots
%  6. Energy distribution vs x and y at Direct Imager
%  7. Response vs x and y of the Direct Imager's YAG
%  8. Image and energy on Direct Imager through K-Monochromator

switch get(handles.TaskMenu,'Value');
    
    case 1  % Emission vs solid angle, in each harmonic: 3D plots, totals
        if newCalc
            EHarm   = 0;
            SDist   = 0;
            PDist   = 0;
            newCalc = 0;
        end
        pause(0.1)
        [EHarm,SDist,PDist] = SpontAngle3D(harmonic,polarized,GeV,charge,...
            KUnd(1),lambdaUnd,NUnd,handles.EnergyTable,EHarm,SDist,PDist);
        set(guiHandle,'HandleVisibility','on')
        if polarized
            table = char(32*ones(10+3*(harmonic(2)-harmonic(1)),20));
            table(5+   harmonic(2)-harmonic(1) ,:) = 'Horiz Polarization  ';
            table(8+2*(harmonic(2)-harmonic(1)),:) = 'Vert Polarization   ';
        else
            table = char(32*ones(4+harmonic(2)-harmonic(1),20));
        end
        table(1,:)                                 = 'Harmonic        uJ  ';
        table(2,:)                                 = 'Both Polarizations  ';
        for pol=1:1+2*polarized
            for harm=harmonic(1):harmonic(2)
                h = harm-harmonic(1)+1;
                s1 = [blanks,num2str(harm)];
                s1 = s1(length(s1)-7:length(s1));
                s2 = [blanks,num2str(EHarm(pol,h)*1e6,'%10.5g')];
                s2 = s2(length(s2)-10:length(s2));
                table(h+2+(pol-1)*(harmonic(2)-harmonic(1)+3),:)...
                   = [s1,' ',s2];
            end
            s2 = [blanks,num2str(sum(EHarm(pol,:)*1e6),'%10.5g')];
            s2 = s2(length(s2)-10:length(s2));
            table(h+3+(pol-1)*(harmonic(2)-harmonic(1)+3),:)...
               = ['   Total',' ',s2];
        end
        set(handles.EnergyTable,'String',table)
        
    case 2  % Emission vs theta at fixed phi, in each harmonic: Plots, peak values
        EHarm = SpontAngle2D(phi,harmonic,...
            polarized,GeV,charge,KUnd(1),lambdaUnd,NUnd);
        set(guiHandle,'HandleVisibility','on')
        xrayEnergy = EHarm*1e-3;
        table = char(32*ones(harmonic(2)-harmonic(1)+3,20));
        table(1,:) = 'Harmonic  nJ/urad^2 ';
        for harm=harmonic(1):harmonic(2)
            h = harm-harmonic(1)+1;
            s1 = [blanks,num2str(harm)];
            s1 = s1(length(s1)-7:length(s1));
            s2 = [blanks,num2str(xrayEnergy(h),'%8.3f')];
            s2 = s2(length(s2)-7:length(s2));
            table(h+1,:) = [s1,'  ',s2,'  '];
        end
        s2 = [blanks,num2str(sum(xrayEnergy),'%8.3f')];
        s2 = s2(length(s2)-7:length(s2));
        table(h+2,:) = ['   Total','  ',s2,'  '];
        set(handles.EnergyTable,'String',table)
        
    case 3  % Emission vs photon energy at fixed theta and phi
        EHarm = SpontEV(theta,phi,harmonic,...
            polarized,GeV,charge,KUnd(1),lambdaUnd,NUnd);
        set(guiHandle,'HandleVisibility','on')
        if polarized
            table = char(32*ones(7+3*(harmonic(2)-harmonic(1)),20));
            table(4+   harmonic(2)-harmonic(1) ,:) = 'Horiz Polarization  ';
            table(6+2*(harmonic(2)-harmonic(1)),:) = 'Vert Polarization   ';
        else
            table = char(32*ones(3+harmonic(2)-harmonic(1),20));
        end
        table(1,:)                                 = 'Harmonic  J/rad^2*eV';
        table(2,:)                                 = 'Both Polarizations  ';
        for pol=1:1+2*polarized
            for harm=harmonic(1):harmonic(2)
                h=harm-harmonic(1)+1;
                s1 = [blanks,num2str(harm)];
                s1 = s1(length(s1)-6:length(s1));
                s2 = [blanks,num2str(EHarm(pol,harm),'%10.4g')];
                s2 = s2(length(s2)-9:length(s2));
                table(h+2+(pol-1)*(harmonic(2)-harmonic(1)+2),:)...
                   = [s1,'  ',s2,' '];
            end
        end
        set(handles.EnergyTable,'String',table)

    case 4  % Photon energy vs theta at fixed phi, in each harmonic,
            %   with intensity contours
        SpontAngleEV(phi,harmonic,polarized,GeV,charge,KUnd(1),lambdaUnd,NUnd)
        set(guiHandle,'HandleVisibility','on')
            
    case 5  % Photon energy vs theta and electron energy, in each harmonic:
            %   3D plots
        SpontAngleEb(harmonic,GeV,KUnd(1),lambdaUnd);
        set(guiHandle,'HandleVisibility','on')
        
    case 6  % Energy Distribution on Direct Imager
        set(handles.XYPol,   'Value',0)
        set(handles.TotalPol,'Value',1)
        if newCalc
            EHarm    = zeros(1,harmonic(2)-harmonic(1)+1);
            eV       = 0;
            TDist    = 0;
            spectrum = 0;
            newCalc  = 0;
        end
        [EHarm,eV,TDist,spectrum] = ...
            SpontDirImager(harmonic,GeV,charge,KUnd,girder,slit,...
            lambdaUnd,EnergySpread,0,handles.EnergyTable,EHarm,eV,TDist,spectrum);
        set(guiHandle,'HandleVisibility','on')
                
    case 7  % Response vs x and y of the Direct Imager's YAG
        set(handles.XYPol,   'Value',0)
        set(handles.TotalPol,'Value',1)
        if newCalc
            EHarm    = zeros(1,harmonic(2)-harmonic(1)+1);
            eV       = 0;
            TDist    = 0;
            spectrum = 0;
            newCalc  = 0;
        end
        [EHarm,eV,TDist,spectrum] = ...
            SpontDirImager(harmonic,GeV,charge,KUnd,girder,slit,...
            lambdaUnd,EnergySpread,yag,handles.EnergyTable,EHarm,eV,TDist,spectrum);
        set(guiHandle,'HandleVisibility','on')
        
    case 8  % Image and energy on Direct Imager through K-Monochromator
        set(handles.XYPol,   'Value',0)
        set(handles.TotalPol,'Value',1)
        [EKMono,harmonic] = ...
            SpontKMono(psiOffset,GeV,charge,KUnd,girder,slit,lambdaUnd,...
            EnergySpread,handles.EnergyTable);
        set(guiHandle,'HandleVisibility','on')
        set(handles.Harmonics,'String',...
            [num2str(harmonic(1)),':',num2str(harmonic(2))])
end
drawnow
set(handles.StartButton,'String','START')
end


function MatFile_Callback(hObject, eventdata, handles)
% hObject    handle to MatFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MatFile as text
%        str2double(get(hObject,'String')) returns contents of MatFile as a double

filename = get(hObject,'String');
dot = strfind(filename,'.');
if ~isequal(dot,[])
    filename = filename(1:dot(1)-1);
end
filename = [filename,'.mat'];
set(hObject,'String',filename)
end

% --- Executes during object creation, after setting all properties.
function MatFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MatFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in SaveMat.
function SaveMat_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GeV harmonic psiOffset xrayEnergy EHarm SDist PDist TDist eV spectrum
filename = get(handles.MatFile,'String');
if isequal(filename,'path/filename') || isequal(filename,'')
    disp(['Enter a valid path and file name ',...
        'in the box below the ''--> MAT file'' button.'])
else
    switch get(handles.TaskMenu,'Value');
        case {1 2}  % Emission vs solid angle, in each harmonic: 3D plots, totals
                    % Emission vs theta at fixed phi, in each harmonic: Plots, peak values
            harm = (harmonic(1):harmonic(2))';
            save(filename,'harm','xrayEnergy')
        case {3 4 5 7}
            disp('Nothing to save for this task.')
        case 6      % Energy Distribution on Direct Imager
            save(filename,'harm','EHarm','eV','TDist','spectrum')
        case 8      % Image and energy on Direct Imager through K-Monochromator
            urad = psiOffset';
            save(filename,'urad','GeV','xrayEnergy')
    end
end
end


% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exit
end
