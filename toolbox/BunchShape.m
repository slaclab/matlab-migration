function varargout = BunchShape(varargin)
% BUNCHSHAPE M-file for BunchShape.fig
% This program computes the temporal profile of an electron bunch from a
% scan of a terahertz Michelson interferometer. It first approximately
% restores the missing low-frequency component of the spectrum. The
% Kramers-Kronig relations provide the phase of the spectrum from its
% magnitude. Then the spectrum can be inverted to give the temporal
% profile.
% There are two optional inputs, text strings giving the file path and file
% name for the Michelson scan data. If this is not provided, the user can
% enter or browse to the file.
% Alan Fisher, February 2012
% Last revision: 2012-10-04

%      BUNCHSHAPE, by itself, creates a new BUNCHSHAPE or raises the existing
%      singleton*.
%
%      H = BUNCHSHAPE returns the handle to a new BUNCHSHAPE or the handle to
%      the existing singleton*.
%
%      BUNCHSHAPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUNCHSHAPE.M with the given input
%      arguments.
%
%      BUNCHSHAPE('Property','Value',...) creates a new BUNCHSHAPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BunchShape_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BunchShape_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last revision: 2012-09-28
% Edit the above text to modify the response to help BunchShape

% Last Modified by GUIDE v2.5 03-Jul-2013 16:39:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BunchShape_OpeningFcn, ...
                   'gui_OutputFcn',  @BunchShape_OutputFcn, ...
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


% --- Executes just before BunchShape is made visible.
function BunchShape_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BunchShape (see VARARGIN)

% Choose default command line output for BunchShape
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BunchShape wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global step steps lastStep stepNum guesses symmetrize
global THzSource filePath fileName
global xFull xRange
global smoothT smoothF parabola hpFilter highPass nBlaschke nWrap
global figHandles

p=inputParser;
p.addOptional('filePath','')
p.addOptional('fileName','')
p.parse(varargin{:})
filePath = lower(p.Results.filePath);
fileName = lower(p.Results.fileName);

[sys,THzSource] = getSystem();
THzSource = lower(THzSource);

if isempty(filePath) || strcmp(filePath,'today')
    dateVector = datevec(now);
    filePath = sprintf('/u1/%s/matlab/THz/%d/%d-%02d/',...
    	THzSource,dateVector(1),dateVector(1),dateVector(2));
elseif strcmp(filePath,'pwd')
        filePath = pwd;
end    
set(handles.FilePath,'String',filePath)
set(handles.FileName,'String',fileName)

steps = {'start';...    % 1
         'smoothT';...  % 2
         'smoothF';...  % 3
         'restoreDC';...% 4
         'plotF';...    % 5
         'blaschke';... % 6
         'shrinkwrap'}; % 7
lastStep = length(steps);
stepNum = 1;
step = steps(stepNum);

xFull = [];
xRange = [];
smoothT = 0;
smoothF = 0;
set(handles.SmoothTime,'String',num2str(smoothT))
set(handles.SmoothFreq,'String',num2str(smoothF))

hpFilter = 0.344;
set(handles.HighPass,  'String',num2str(hpFilter,'%.3f'))
hpFilter = 1e12*hpFilter;
set(handles.NewHighPass,'Value',0)
highPass = 0;

parabola = [0.4 0.8];
set(handles.Parabola,  'String',num2str(parabola,'%.1f:%.1f'))

nBlaschke = 0;
nWrap = 0;
set(handles.Blaschke,  'String',num2str(nBlaschke))
set(handles.ShrinkWrap,'String',num2str(nWrap))

guesses.gaussians = 0;
guesses.Gauss = zeros(1,6);
symmetrize = 0;
set(handles.Gauss0,     'Value',  1)
set(handles.Symmetrize, 'Value',  0);
set(handles.GuessTitle, 'Visible','off')
set(handles.GuessHeight,'Visible','off')
set(handles.GuessMean,  'Visible','off')
set(handles.GuessSigma, 'Visible','off')
set(handles.Gauss1Ampl, 'Visible','off')
set(handles.Gauss1Mean, 'Visible','off')
set(handles.Gauss1Sigma,'Visible','off')
set(handles.Gauss2Ampl, 'Visible','off')
set(handles.Gauss2Mean, 'Visible','off')
set(handles.Gauss2Sigma,'Visible','off')
set(handles.Gauss1Ampl, 'String',  '')
set(handles.Gauss1Mean, 'String',  '')
set(handles.Gauss1Sigma,'String',  '')
set(handles.Gauss2Ampl, 'String',  '')
set(handles.Gauss2Mean, 'String',  '')
set(handles.Gauss2Sigma,'String',  '')

if highPass ~= get(handles.NewHighPass,'Value')
    highPass = get(handles.NewHighPass,'Value');
    stepNum = min(stepNum,2);
end

set(handles.Status,'String','')

figHandles = zeros(1,9);

end


% --- Outputs from this function are returned to the command line.
function varargout = BunchShape_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



function FilePath_Callback(hObject, eventdata, handles)
% hObject    handle to FilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilePath as text
%        str2double(get(hObject,'String')) returns contents of FilePath as a double

global step steps stepNum filePath

step = 'start';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
    
    filePath = get(hObject,'String');
    if ~isempty(filePath) && ~strcmp(filePath(length(filePath)),'/')
        filePath = [filePath,'/'];
        set(hObject,'String',filePath)
    end
end
end


% --- Executes during object creation, after setting all properties.
function FilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function FileName_Callback(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileName as text
%        str2double(get(hObject,'String')) returns contents of FileName as a double

global step steps stepNum fileName

step = 'start';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
    
    fileName = get(hObject,'String');
    if strcmp(fileName(1),'/')
        fileName = fileName(2:length(fileName));
        set(hObject,'String',fileName)
    end
end
end


% --- Executes during object creation, after setting all properties.
function FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global step steps stepNum filePath fileName

step = 'start';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
    [filename,filepath] = uigetfile({'*.txt';'*.dir'},...
        'Select a Scan File',filePath);

    if isequal(filename,0) || isequal(filepath,0)
        set(handles.Status,'String','Canceled by user.')
    else
        filePath = filepath;
        fileName = filename;
        set(handles.FilePath,  'String',filePath)
        set(handles.FileName,  'String',fileName)
        set(handles.PointRange,'String','ALL')
        xFull = [];
        xRange = [];
    end
end
end



% --- Executes on button press in TestData.
function TestData_Callback(hObject, eventdata, handles)
% hObject    handle to TestData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TestData
global step steps stepNum
step = 'start';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
end
end



function SmoothTime_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothTime as text
%        str2double(get(hObject,'String')) returns contents of SmoothTime as a double

global step steps stepNum smoothT

step = 'smoothT';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = get(hObject,'String');
    if isempty(s)
        smoothT = 0;
        status = '';
    else
        r = str2double(s);
        if isnan(r) || r < 0 || r > 8
            smoothT = 0;
            status = ['Smooth the scan using up to 8 points on either side;',...
                ' 0 means no smoothing.'];
        else
            smoothT = round(r);
            status = '';
        end
    end
    set(hObject,'String',num2str(smoothT))
    set(handles.Status,'String',status)
end
end



function PointRange_Callback(hObject, eventdata, handles)
% hObject    handle to PointRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PointRange as text
%        str2double(get(hObject,'String')) returns contents of PointRange as a double

global step steps stepNum xFull xRange

step = 'start';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
end


if ~isempty(xFull)
    OK = 0;
    N = length(xFull);
    s = get(hObject,'String');
    if isempty(strfind(lower(s),'all'))
        colon = strfind(s,':');
        if ~isempty(colon) && length(colon)==1 &&...
                colon(1)>1  && colon(1)<length(s)
            r(1) = max(str2double(s(1:colon(1)-1)),xFull(1));
            r(2) = min(str2double(s(colon(1)+1:length(s))),xFull(N));
            if ~any(isnan(r)) && r(2)-r(1)>=0.05
                OK = 1;
            end
        end
    end
    if OK
        for k=1:2
            d = abs(xFull-r(k));
            j = find(d==min(d),1);
            xRange(k) = xFull(j);
        end
        set(hObject,'String',[num2str(xRange(1)),':',num2str(xRange(2))])
        status = '';
    else
        set(hObject,'String','ALL')
        status = 'Enter two positions within the range of the scan.';
    end
else
    set(hObject,'String','ALL')
    status = 'First plot a scan.';
end
set(handles.Status,'String',status)
end


% --- Executes during object creation, after setting all properties.
function PointRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PointRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in SpikeFilter.
function SpikeFilter_Callback(hObject, eventdata, handles)
% hObject    handle to SpikeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SpikeFilter
global step steps stepNum
step = 'start';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
end
end



% --- Executes during object creation, after setting all properties.
function SmoothTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in Symmetrize.
function Symmetrize_Callback(hObject, eventdata, handles)
% hObject    handle to Symmetrize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Symmetrize
end



function SmoothFreq_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothFreq as text
%        str2double(get(hObject,'String')) returns contents of SmoothFreq as a double

global step steps stepNum smoothF

step = 'smoothF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
    
    s = get(hObject,'String');
    if isempty(s)
        smoothF = 0;
        status = '';
    else
        r = str2double(s);
        if isnan(r) || r < 0 || r > 8
            smoothF = 0;
            status = ['Smooth the spectrum using up to 8 points on either side;',...
                ' 0 means no smoothing.'];
        else
            smoothF = round(r);
            status = '';
        end
    end
    set(hObject,'String',num2str(smoothF))
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function SmoothFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in NewHighPass.
function NewHighPass_Callback(hObject, eventdata, handles)
% hObject    handle to NewHighPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NewHighPass
global step steps stepNum
step = 'smoothT';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
end
end



function HighPass_Callback(hObject, eventdata, handles)
% hObject    handle to HighPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HighPass as text
%        str2double(get(hObject,'String')) returns contents of HighPass as a double

global step steps stepNum hpFilter

step = 'smoothT';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || s < 0 || s > 5
        status = 'Filter, 1-exp(-(f/hpFilter)^2), must be between 0 and 5 THz.';
    else
        set(hObject,'String',num2str(s,'%.3f'))
        hpFilter = 1e12*s;
        status = '';
    end
    set(handles.Status,'String',status)
    if hpFilter == 0
        set(handles.NewHighPass,'Value',0)
    end
end
end


% --- Executes during object creation, after setting all properties.
function HighPass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HighPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Parabola_Callback(hObject, eventdata, handles)
% hObject    handle to Parabola (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Parabola as text
%        str2double(get(hObject,'String')) returns contents of Parabola as a double

global step steps stepNum parabola

step = 'restoreDC';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    r = [0.3 0.5];
    s = get(hObject,'String');
    colon = strfind(s,':');
    OK = 1;
    if ~isempty(colon) && length(colon)==1 &&...
            colon(1)>1  && colon(1)<length(s)
        r(1) = str2double(s(1:colon(1)-1));
        r(2) = str2double(s(colon(1)+1:length(s)));
        if any(isnan(r) | r<0 | r>5) || r(2)-r(1) < 0.05
            OK = 0;
        end
    else
        OK = 0;
    end
    if OK
        parabola = r;
    else
        parabola = [0.4 0.8];
        status = 'Enter a frequency range (THz) to extend the spectrum to f=0.';
        set(handles.Status,'String',status)
    end
    set(hObject,'String',[num2str(parabola(1)),':',num2str(parabola(2))])
end
end


% --- Executes during object creation, after setting all properties.
function Parabola_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Parabola (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in Water.
function Water_Callback(hObject, eventdata, handles)
% hObject    handle to Water (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Water
global step steps stepNum
step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
end
end


% --- Executes on button press in DetectorModel.
function DetectorModel_Callback(hObject, eventdata, handles)
% hObject    handle to DetectorModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DetectorModel
global step steps stepNum
step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
end
end



function Gauss1Ampl_Callback(hObject, eventdata, handles)
% hObject    handle to Gauss1Ampl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauss1Ampl as text
%        str2double(get(hObject,'String')) returns contents of Gauss1Ampl as a double

global step steps stepNum guesses

step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || s < 0 || s > 5
        status = 'The amplitude must be between 0 and 5.';
    else
        set(hObject,'String',num2str(s))
        guesses.Gauss(1) = s;
        status = '';
    end
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Gauss1Ampl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauss1Ampl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Gauss1Mean_Callback(hObject, eventdata, handles)
% hObject    handle to Gauss1Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauss1Mean as text
%        str2double(get(hObject,'String')) returns contents of Gauss1Mean as a double

global step steps stepNum guesses

step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || abs(s) > 1e4
        status = 'The mean must be inside the limits of the plot.';
    else
        set(hObject,'String',num2str(s))
        guesses.Gauss(2) = s;
        status = '';
    end
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Gauss1Mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauss1Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Gauss1Sigma_Callback(hObject, eventdata, handles)
% hObject    handle to Gauss1Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauss1Sigma as text
%        str2double(get(hObject,'String')) returns contents of Gauss1Sigma as a double

global step steps stepNum guesses

step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || s < 0 || s > 1000
        status = 'Sigma must be positive and below 1000.';
    else
        set(hObject,'String',num2str(s))
        guesses.Gauss(3) = s;
        status = '';
    end
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Gauss1Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauss1Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Gauss2Ampl_Callback(hObject, eventdata, handles)
% hObject    handle to Gauss2Ampl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauss2Ampl as text
%        str2double(get(hObject,'String')) returns contents of Gauss2Ampl as a double

global step steps stepNum guesses

step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || s < 0 || s > 5
        status = 'The amplitude must be between 0 and 5.';
    else
        set(hObject,'String',num2str(s))
        guesses.Gauss(4) = s;
        status = '';
    end
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Gauss2Ampl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauss2Ampl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Gauss2Mean_Callback(hObject, eventdata, handles)
% hObject    handle to Gauss2Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauss2Mean as text
%        str2double(get(hObject,'String')) returns contents of Gauss2Mean as a double

global step steps stepNum guesses

step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || abs(s) > 1e4
        status = 'The mean must be inside the limits of the plot.';
    else
        set(hObject,'String',num2str(s))
        guesses.Gauss(5) = s;
        status = '';
    end
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Gauss2Mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauss2Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Gauss2Sigma_Callback(hObject, eventdata, handles)
% hObject    handle to Gauss2Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauss2Sigma as text
%        str2double(get(hObject,'String')) returns contents of Gauss2Sigma as a double

global step steps stepNum guesses

step = 'plotF';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = str2double(get(hObject,'String'));
    if isnan(s) || s < 0 || s > 1000
        status = 'Sigma must be positive and below 1000.';
    else
        set(hObject,'String',num2str(s))
        guesses.Gauss(6) = s;
        status = '';
    end
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Gauss2Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauss2Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Blaschke_Callback(hObject, eventdata, handles)
% hObject    handle to Blaschke (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Blaschke as text
%        str2double(get(hObject,'String')) returns contents of Blaschke as a double
global step steps stepNum nBlaschke

step = 'blaschke';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);
    
    s = get(hObject,'String');
    if isempty(s)
        nBlaschke = 0;
        status = '';
    else
        r = str2double(s);
        if ~isnan(r) && r>=0 && r<=4
            b = r;
            status = '';
            nBlaschke = b;
        else
            status = 'The program can attempt to use from 0 to 4 zeros.';
        end
    end
    set(hObject,'String',num2str(nBlaschke))
    set(handles.Status,'String',status)
end
end


% --- Executes during object creation, after setting all properties.
function Blaschke_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Blaschke (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function ShrinkWrap_Callback(hObject, eventdata, handles)
% hObject    handle to ShrinkWrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ShrinkWrap as text
%        str2double(get(hObject,'String')) returns contents of ShrinkWrap as a double
global step steps stepNum nWrap

step = 'shrinkwrap';
s = find(strcmp(step,steps),1);
if ~isempty(s)
    stepNum = min(stepNum,s);
    step = steps(stepNum);

    s = get(hObject,'String');
    if isempty(s)
        nWrap = 0;
        status = '';
    else
        r = str2double(s);
        if ~isnan(r) && r >= 0 && r <= 1000
            nWrap = round(r);
            status = '';
        else
            status = 'Choose 0 to 1000 iterations of the "shrink-wrap" algorithm.';
        end
    end
    set(hObject,'String',num2str(nWrap))
    set(handles.Status,'String',status)
end
end



% --- Executes during object creation, after setting all properties.
function ShrinkWrap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShrinkWrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Status_Callback(hObject, eventdata, handles)
% hObject    handle to Status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Status as text
%        str2double(get(hObject,'String')) returns contents of Status as a double
set(hObject,'String','')
end


% --- Executes during object creation, after setting all properties.
function Status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in Plots.
function Plots_Callback(hObject, eventdata, handles)
% hObject    handle to Plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global figHandles
set(handles.Status,'String','')
figStr = inputdlg('Enter a list (1 4 6) or range (1:3) of figure numbers',...
    'Send Plots to Log',1,{''},'on');
s=figStr{1};
if ~isempty(s)
    OK = 1;
    colon = strfind(s,':');
    if isempty(colon)
        r = str2num(s);
        if any(isnan(r) | r<1 | r>max(figHandles))
            OK = 0;
        end
    elseif length(colon)>=1 && length(colon)<=2 &&...
            colon(1)>1  && colon(length(colon))<length(s)
        rr = [1 1 1];
        rr(1) = str2double(s(1:colon(1)-1));
        if length(colon)==1
            rr(3) = str2double(s(colon(1)+1:length(s)));
        else
            rr(2) = str2double(s(colon(1)+1:colon(2)-1));
            rr(3) = str2double(s(colon(2)+1:length(s)));
        end
        if any(isnan(rr) | rr<1 | rr>max(figHandles)) ||...
                rr(length(rr))<rr(1)
            OK = 0;
        else
            r = rr(1):rr(2):rr(3);
        end
    else
        OK = 0;
    end
    if OK
        for k = 1:length(r)
            util_printLog(r(k))
            pause(0.5)
        end
        set(handles.Status,'String','Figures sent to eLog.')
    else
        set(handles.Status,'String','Invalid figure number(s)')
    end
else
    set(handles.Status,'String','Canceled by user.')
end
end



% --- Executes on button press in SaveData.
function SaveData_Callback(hObject, eventdata, handles)
% hObject    handle to SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global THzSource filePath fileName
global t v vs uK f Va Vasm Vasf Ea phi

if get(handles.TestData,'Value')
    set(handles.Status,'String','Test Data cannot be saved.')
else
    set(handles.Status,'String','')
    mkdirStatus = mkdir(filePath);
    if mkdirStatus == 1
        try
            m = strfind(fileName,'Scan');
            if isempty(m)
                m = 1;
            else
                m = m(1);
            end
            filename = [THzSource,'Shape',fileName(m+4:length(fileName))];
            tData = [t,v,vs,uK];
            fData = [f,Va/Vasm,Vasf/Vasm,Ea,unwrap(phi)];
%             if figHandles(8)
%                 for nb = 1:size(ub,2)
%                     if any(ub(:,nb))
%                         tData = [tData,ub(:,nb)];
%                         fData = [fData,unwrap(phb(:,nb))];
%                     end
%                 end
%             end                        
            save([filePath,filename],'tData','fData',...
                '-ascii','-double','-tabs')
            set(handles.Status,'String','File saved.')
        catch
            status = 'Error in opening file diaglog. Please try again.';
            set(handles.Status,'String',status)
        end
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



% --- Executes on button press in Calculate.
function Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global step steps lastStep stepNum guesses symmetrize
global filePath fileName filename
global interpolated smoothT smoothF hpFilter highPass parabola restorePts 
global nBlaschke oldBlaschke score scoreK scoreB scoreW nWrap
global figHandles
global x xFull xRange t N dt
global f Nf fs df omega dOmega pyro
global scan scanRaw v vs ux uK uz uB
global V Va Vas Vasm Vasf Ea kp kLim
global phx phi phz phb phxLeft phiLeft
global timescale timelabel
global jstart jstop jp1 jp2

% To get the electric field in absolute units, stop DC restoration and set:
sigmax = 1.21;     % RMS bunch size (mm)
sigmay = 0.93;
THzEnergy = 0.35;  % Energy (mJ) in the THz pulse

c = 2.99792458e8;
epsilon0 = 1/(4e-7*pi*c^2);

plotStep = 30;
plotX = 5;
plotY = 350;
plotWidth = 560;
plotHeight = 420;

minLength = 1024;
noiseThreshT = 0.03;
noiseThreshF = 0.03;
noisePoints = 5;

testData    = get(handles.TestData,     'Value');
showWater   = get(handles.Water,        'Value');
showDet     = get(handles.DetectorModel,'Value');
spikeFilter = get(handles.SpikeFilter,  'Value');

k = guesses.gaussians;
if get(handles.Gauss0,'Value') == 1
    guesses.gaussians = 0;
    set(handles.GuessTitle, 'Visible','off')
    set(handles.GuessHeight,'Visible','off')
    set(handles.GuessMean,  'Visible','off')
    set(handles.GuessSigma, 'Visible','off')
    set(handles.Gauss1Ampl, 'Visible','off')
    set(handles.Gauss1Mean, 'Visible','off')
    set(handles.Gauss1Sigma,'Visible','off')
    set(handles.Gauss2Ampl, 'Visible','off')
    set(handles.Gauss2Mean, 'Visible','off')
    set(handles.Gauss2Sigma,'Visible','off')
elseif get(handles.Gauss1,'Value') == 1
    guesses.gaussians = 1;
    set(handles.GuessTitle, 'Visible','on')
    set(handles.GuessHeight,'Visible','on')
    set(handles.GuessMean,  'Visible','on')
    set(handles.GuessSigma, 'Visible','on')
    set(handles.Gauss1Ampl, 'Visible','on')
    set(handles.Gauss1Mean, 'Visible','on')
    set(handles.Gauss1Sigma,'Visible','on')
    set(handles.Gauss2Ampl, 'Visible','off')
    set(handles.Gauss2Mean, 'Visible','off')
    set(handles.Gauss2Sigma,'Visible','off')
else
    guesses.gaussians = 2;
    set(handles.GuessTitle, 'Visible','on')
    set(handles.GuessHeight,'Visible','on')
    set(handles.GuessMean,  'Visible','on')
    set(handles.GuessSigma, 'Visible','on')
    set(handles.Gauss1Ampl, 'Visible','on')
    set(handles.Gauss1Mean, 'Visible','on')
    set(handles.Gauss1Sigma,'Visible','on')
    set(handles.Gauss2Ampl, 'Visible','on')
    set(handles.Gauss2Mean, 'Visible','on')
    set(handles.Gauss2Sigma,'Visible','on')
end
if k ~= guesses.gaussians
    stepNum = min(stepNum,5);
end

k = symmetrize;
symmetrize  = get(handles.Symmetrize,'Value');
if k ~= symmetrize
    stepNum = 1;
end

if highPass ~= get(handles.NewHighPass,'Value')
    highPass = get(handles.NewHighPass,'Value');
    stepNum = min(stepNum,2);
end

% 1) start: Get scan data.
if stepNum == 1
    set(handles.Status,'String',['Calculating step ',num2str(stepNum),...
        ' of ',num2str(lastStep)])
    pause(0.1)
    if testData
        % Build a beam: Gaussians, Horns, Lorentzian
        dt = 1.5e-15; % Scale in seconds (100 nm delay steps = 1.5 fs)
        N = 4*minLength;
        jsig = 120;
        sig = dt*2*jsig;
        addNoise = 0;
        t = dt*(-N/2:N/2-1)';
        x = c*t*1000/2; % Steps (mm) of delay stage
        ux = zeros(N,1);
        scan = zeros(N,1);
        
        filename = 'Gaussian';
        
        switch filename
            case 'Gaussian'	% Three (truncated) Gaussians.
            ampl  =	[0.00,  1.00,   0.30];
            mu    =	[-0.1,  0.00,	0.40]*sig;
            sigma =	[0.04,	0.08,	0.15]*sig;
            for n = 1:3
                ux = ux + ampl(n)*exp(-0.5*((t-mu(n))/sigma(n)).^2)...
                    .*(t >= -sig) .* (t <= sig);
            end
        
            case 'Horns'        % Double horns
                jOffset = -10; %jsig/10;
                for j = 1:N
                    if abs(j-N/2) <= jsig
                        ux(j) = 0.5*cosh(acosh(2)*(j-N/2-jOffset)/jsig);
                    elseif j-N/2 > jsig && j-N/2 < jsig+32
                        ux(j) = 0.5*cosh(acosh(2)*(jsig-jOffset)/jsig)...
                                   *(N/2+jsig+32-j)/32;
                    elseif j-N/2 < -jsig && j-N/2 > -jsig-32
                        ux(j) = 0.5*cosh(acosh(2)*(jsig+jOffset)/jsig)...
                                   *(j-N/2+jsig+32)/32;
                    end
                end
                
            case 'Lorentzian'     % Single Lorentzian peak
                ux = (1./(1+(12*t/sig).^2)).*(abs(t)<=sig);
        end
        ux = ux.*(1+(rand(N,1)-0.5)*addNoise);
        
        % Use a high-pass filter to remove the DC component.
        Nf = N/2 + 1;
        fs = 1/dt;
        df = fs/N;
        f = df*(0:N-1)';
        V = fft(ux);
        phx = unwrap(angle(V)); % Phase of the starting function
        if hpFilter
            Vf = V.*(1-exp(-(f/hpFilter).^2));
        else
            Vf = V;
        end
        Vf = [Vf(1:Nf);conj(Vf(Nf-1:-1:2))];
        uf = ifft(Vf,'symmetric');
        
        % Find the autocorrelation of this beam.
        for j = 1:N
            jj = j-floor(N/2)-1;
            j1 = max( 1, 1-jj);
            j2 = min(N,N-jj);
            scan(j) = dt*(uf(j1:j2)'*uf((j1:j2)+jj));
        end
        
        status = 'Test data loaded.';
    else
        try
            % Get the time steps and data.
            filename = fileName;
            data = load([filePath,fileName],'-ascii');
            xFull = data(:,1);
            scanFull = data(:,size(data,2));        % Use last column
            N = find(scanFull~=0,1,'last'); % Remove trailing zeros
            xFull = xFull(1:N);
            scanFull = scanFull(1:N);
            scanFull = scanFull...
                * sign(abs(max(scanFull))-abs(min(scanFull))); % Invert?
            status = 'File loaded.';
            
            % Remove points outside the range specified by the user.
            if isempty(strfind(lower(get(handles.PointRange,'String')),'all'))...
                     && ~isempty(xRange)
                jRange = find(xFull>=xRange(1) & xFull<=xRange(2));
                x = xFull(jRange);
                scan = scanFull(jRange);
            else
                x = xFull;
                scan = scanFull;
            end            
            
            % Filter out any single-point spikes.
            if spikeFilter
                N = length(x);
                scanRaw = scan;
                pp = mean(scan);
                for j = 1:N
                    if j == 1
                        p1 = scanRaw(2);
                        p2 = p1;
                        p  = p1;
                    elseif j == N
                        p1 = scanRaw(N-1);
                        p2 = p1;
                        p  = p1;
                    else
                        weight = (x(j)-x(j-1))/(x(j+1)-x(j-1));
                        p1 = scanRaw(j-1);
                        p2 = scanRaw(j+1);
                        p  = p1*(1-weight) + p2*weight;
                    end
                    if (scanRaw(j)>3*pp  &&  scanRaw(j)>3*p1 &&...
                        scanRaw(j)>3*p2) || (scanRaw(j)<pp/3 &&...
                        scanRaw(j)<p1/3  &&  scanRaw(j)<p2/3)
                        scan(j) = p;
                    end
                end
            end
            
        catch ME
            status = ['Error in loading file: ',ME.message];
            set(handles.Status,'String',status)
        end
    end
    
    if ~strcmp(status(1:5),'Error')
        % If a mixture of delay steps was used, interpolate the data to
        % get uniform spacing at the shortest step size.
        deltax = x(2:length(x)) - x(1:length(x)-1);
        dx = min(deltax);
        interpolated = any(abs(deltax/dx-1) > 1e-6);
        j1 = find(deltax==dx,1);
        xInterp = [fliplr(x(j1):-dx:x(1)),x(j1+1):dx:x(length(x))]';
        scanInterp = interp1(x,scan,xInterp,'pchip');
        
        % Optionally, symmetrize the scan about the peak.
        N = length(xInterp);
        if symmetrize
            p = find(abs(scanInterp/max(scanInterp)-1)<1e-6,1);
            j1 = p(ceil(length(p)/2));
            if 2*j1 < N+1
                scanI = (scanInterp(1:j1-1)+scanInterp(2*j1-1:-1:j1+1))/2;
                scanInterp = [scanInterp(N:-1:2*j1);...
                              scanI;...
                              scanInterp(j1);...
                              flipud(scanI);...
                              scanInterp(2*j1:N)];
                xInterp = [xInterp(1)-dx*(N+1-2*j1:-1:1)';xInterp];
            elseif 2*j1 > N+1
                scanI = (scanInterp(2*j1-N:j1-1)+scanInterp(N:-1:j1+1))/2;
                scanInterp = [scanInterp(1:2*j1-N-1);...
                              scanI;...
                              scanInterp(j1);...
                              flipud(scanI);...
                              scanInterp(2*j1-N-1:-1:1)];
                xInterp = [xInterp;xInterp(N)+dx*(1:2*j1-N-1)'];
            end
        end

        % Convert mm of stage delay to time, with t=0 at the peak of
        % the scan. Remove the DC offset of the scan.
        % If the scan has fewer than 1024 points, pad both ends with
        % zeros. If the number of points is odd, add a point.
        p = find(abs(scanInterp/max(scanInterp)-1)<1e-6,1);
        j1 = p(ceil(length(p)/2));
        t = (xInterp-xInterp(j1))*0.001*2/c;
        dt = t(2)-t(1);
        N = length(t);
        pow2Length = max(minLength,2^nextpow2(N));
        v = scanInterp - mean(scanInterp);
        if N < pow2Length
            before = floor((pow2Length-N)/2);
            after = pow2Length - N - before;
            t = [t(1)-(before:-1:1)'*dt; t; t(N)+(1:after)'*dt];
            v = [zeros(before,1); v; zeros(after,1)];
            N = pow2Length;
        end
        
        % Define the frequency points.
        Nf = N/2 + 1;
        fs = 1/dt;
        df = fs/N;
        dOmega = 2*pi*df;
        f = df*(0:N-1)';
        omega = 2*pi*f;
                
        stepNum = stepNum + 1;
    end
    set(handles.Status,'String',status)
end


% 2) smoothT: Smooth over +-smoothT points with linear weighting.
%    (For no smoothing, smoothT should be zero.)
%    Then find the Fourier transform of the scan.
if stepNum == 2
    set(handles.Status,'String',['Calculating step ',num2str(stepNum),...
        ' of ',num2str(lastStep)])
    pause(0.1)
    if smoothT > 0
        vs = zeros(N,1);
        for j = 1:N
            weights = 0;
            for jj = max(j-smoothT,1):min(j+smoothT,N)
                weight = 1 - abs(j-jj)/(smoothT+1);
                weights = weights + weight;
                vs(j) = vs(j) + v(jj)*weight;
            end
            vs(j) = vs(j)/weights;
        end
        vs = vs - mean(vs);
    else
        vs = v;
    end
    
    % Remeasure the Gaussian high-pass filter.
    if highPass
        % Fit only region near central peak and surrounding dips.
        vsm = max(vs);
        jmax = find(abs(vs-vsm)/vsm<1e-6,1);
        j1 = max(1,jmax-max(1,find(vs(jmax-1:-1:1)<=vsm/2,1)));
        j2 = min(N,jmax+max(1,find(vs(jmax+1:N)<=vsm/2,1)));
        
        j3 = max(1,jmax-(j2-j1)*10);
        jmin = j1+1-find(vs(j1:-1:j3)==min(vs(j1:-1:j3)),1);
        j3 = max(1,jmin-(j2-j1)*4);
        jstart = jmin+1-ceil(0.75*find(vs(jmin:-1:j3)==max(vs(jmin:-1:j3)),1));
        
        j3 = min(N,jmax+(j2-j1)*10);
        jmin = j2-1+find(vs(j2:j3)==min(vs(j2:j3)),1);
        j3 = min(N,jmin+(j2-j1)*4);
        jstop  = jmin-1+ceil(0.75*find(vs(jmin:j3)==max(vs(jmin:j3)),1));

       % Fit a filtered Gaussian beam to this region
        [fFit,fParam] = filterFit(1e12*t(jstart:jstop),vs(jstart:jstop)/vsm);
        if fParam(4) < 0.1 || fParam(4) > 5
            status = sprintf('Bad fit to high-pass filter: %.3f',fParam(4));
            set(handles.Status,'String',status)
        else
            hpFilter = 1e12*fParam(4);
            fFit = vsm*fFit;
            set(handles.HighPass,'String',num2str(1e-12*hpFilter,'%.3f'))
        end
    end


    % Plot the scan data.
    fig = 1;
    try
        set(0,'CurrentFigure',figHandles(fig))
        set(gcf,'Name','Raw Interferometer Scan')
    catch
        figHandles(fig) = figure('Name','Interferometer Scan');
        pause(0.1)
        set(gcf,'Position',[plotX,plotY,plotWidth,plotHeight])
    end
    pause(0.1)
    if testData
        plot(1e15*t,ux)
        title('Test Function before Autocorrelation')
        xlabel('Time (fs)')
    elseif spikeFilter
        plot(x,scanRaw,'g',x,scan,'b')
        title([filename,' - Interferometer Scan'])
        xlabel('Stage Position (mm)')
        ylabel('Interference/Reference')
        legend('Raw scan','Spikes Filtered')
    else
        plot(x,scan)
        title([filename,' - Interferometer Scan'])
        xlabel('Stage Position (mm)')
        ylabel('Interference/Reference')
    end
    
    fig = 2;
    try
        set(0,'CurrentFigure',figHandles(fig))
        set(gcf,'Name','Smoothed Interferometer Scan')
    catch
        figHandles(fig) = figure('Name','Smoothed Interferometer Scan',...
            'Position',[plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
    end
    pause(0.1)
    if interpolated
        titl = [filename,' - Uniform Spacing'];
        leg = {'Interpolated'};
    else
        titl = [filename,' - Scan vs Delay'];
        leg = {'Scan'};
    end
    if smoothT
        plot(1e12*t,v,'g',1e12*t,vs,'b')
        title([titl,' with Smoothing'])
        leg = [leg;'Smoothed'];
    else
        plot(1e12*t,vs,'b')
        title(titl)
    end
    if highPass
        hold on
        plot(1e12*t(jstart:jstop),fFit,'r')
        hold off
        leg = [leg;'Filter Fit'];
    end
    xlabel('Stage Delay (ps)')
    ylabel('Interference/Reference')
    legend(leg)

    % Compute the Fourier transform of the scan.
    V = fft(vs);
    Va = abs(V);
    stepNum = stepNum + 1;
end


% 3) smoothF: Smooth over +-smoothF points with linear weighting.
%    (For no smoothing, smoothF should be zero.)
if stepNum == 3
    set(handles.Status,'String',['Calculating step ',num2str(stepNum),...
        ' of ',num2str(lastStep)])
    pause(0.1)
    if smoothF > 0
        Vas = zeros(N,1);
        for k = 1:Nf
            weights = 0;
            for kk = max(k-smoothF,1):min(k+smoothF,N)
                weight = 1 - abs(k-kk)/(smoothF+1);
                weights = weights + weight;
                Vas(k) = Vas(k) + Va(kk)*weight;
            end
            Vas(k) = Vas(k)/weights;
        end
        Vas(1) = 0;
        Vas(Nf+1:N) = Vas(Nf-1:-1:2);
    else
        Vas = Va;
    end
    Vasm = max(Vas);
    stepNum = stepNum + 1;
end


% 4) parabola: Restore the low-frequency content of the spectrum with an
%    approximation that assumes that the low-frequency cutoff behaves like
%    a Gaussian filter, 1-exp(-(f/hpFilter)^2) for the electric field.
%    We divide by this function to compensate. To avoid division by zero at
%    very low frequencies, we then attach a parabola that peaks at zero
%    frequency and meets a fit to the filter-compensated spectrum over
%    the frequency range specified in parabola. The fit matches the log of
%    the Gaussian (ln(A) - 0.5*(f/sigmaf)^2), which is a parabola, to the
%    log of the points. This is a linear fit in f^2 versus ln(Vasf).
if stepNum == 4
    set(handles.Status,'String',['Calculating step ',num2str(stepNum),...
        ' of ',num2str(lastStep)])
    pause(0.1)
    Vasf = Vas;
    restorePts = round(1e12*parabola/df + 1);
    restorePts(2) = max(restorePts(1)+3,restorePts(2));
    kp = find(abs(Vas(1:Nf)/Vasm-1)<1e-6,1,'first');
    if isempty(kp)
        kp = Nf-restorePts(2);
    end
    
    if hpFilter
        for k = max(restorePts(1),2):Nf
            Vasf(k) = Vas(k)/(1-exp(-(f(k)/hpFilter)^2))^2;
        end
    end
    fit = polyfit((f(restorePts(1):restorePts(2))/f(restorePts(1))).^2,...
            log(Vasf(restorePts(1):restorePts(2))/Vasf(restorePts(1))),1);
    if fit(1) >= 0
        fit = [0 0];
    end
    if parabola(1) > 0
        for k = 1:max(restorePts(1),2)-1
            p = Vasf(restorePts(1))*...
                exp(polyval(fit,(f(k)/f(restorePts(1))).^2));
            if p > 0
                Vasf(k) = p;
            else
                Vasf(k) = Vas(k);
            end
        end
    end
        
    % Remove high-frequency noise from the spectrum with a power law.
    kLim = floor(0.9*Nf);
    while kLim>=floor(0.5*Nf) &&...
        	any((Vasf(Nf-noisePoints:Nf)/Vasm)...
                .*(f(Nf-noisePoints:Nf)/f(kLim)).^-4>0.005)
        kLim = kLim - floor(0.05*Nf);
    end        
    Vasf(kLim:Nf) = Vasf(kLim:Nf) .* (f(kLim:Nf)/f(kLim)).^-4;    
    Vasf(Nf+1:N) = Vasf(Nf-1:-1:2);
    stepNum = stepNum + 1;
end


% 5) plotF: Plot the spectrum, zooming in on the nonzero region.
if stepNum == 5
    set(handles.Status,'String',['Calculating step ',num2str(stepNum),...
        ' of ',num2str(lastStep)])
    pause(0.1)
    fig = 3;
    try
        set(0,'CurrentFigure',figHandles(fig))
        set(gcf,'Name','Spectrum')
    catch
        figHandles(fig) = figure('Name','Spectrum',...
            'Position',[plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
    end
    pause(0.1)
    if smoothF
        plot(1e-12*f,Va/Vasm,'g',...
             1e-12*f,Vas/Vasm,'b')
        leg = {'Raw';'Smoothed'};
    else
        plot(1e-12*f,Vas/Vasm,'b')
        leg = {'Raw'};
    end
    title([filename,' - Scan Spectrum'])
    set(gca,'XLim',1e-12*[f(1),f(kLim)])
    xlabel('Frequency (THz)')
    ylabel('Normalized')
    if length(leg) > 1
        legend(leg)
    end
    
    fig = 4;
    try
        set(0,'CurrentFigure',figHandles(fig))
        set(gcf,'Name','Spectrum with Corrections')
    catch
        figHandles(fig) = figure('Name','Spectrum with Corrections',...
            'Position',[plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
    end
    pause(0.1)
    if showWater
        water = load('WaterAbsorption.txt','-ascii');
        waterFreq = 1e6*c./water(:,1);
        waterAbs = water(:,2);
        plot(1e-12*waterFreq,waterAbs,'y')
        hold on
    end
    if showDet
        pyro = pyro_det_new(0.01*f(1:Nf)/c,30e-4,4e-7,7e-5);
        plot(1e-12*f(1:Nf),pyro,'c')
        hold on
    end
    plot(1e-12*f,Vas/Vasm,'g')
    set(gca,'XLim',1e-12*[f(1),f(kLim)])
    xlabel('Frequency (THz)')
    ylabel('Normalized')
    hold on
    plot(1e-12*f(restorePts(1):restorePts(2)),...
             Vasf(restorePts(1):restorePts(2))/Vasm,...
             'LineStyle','none','Marker','o',...
             'MarkerEdgeColor','r','MarkerSize',5)
    plot(1e-12*f,Vasf/Vasm,'b')
    hold off
    title([filename,' - Low-Frequency Compensation'])
    leg = {'Before';'Fit Points';'Compensated'};
    if showDet
        leg = ['Detector resp';leg];
    end
    if showWater
        leg = ['Water abs';leg];
    end
    legend(leg)
    
    % The Kramers-Kronig relations give the phase of the form factor.
    % This phase is incomplete if the amplitude has a zero in the upper
    % half of the complex omega plane.
    Ea = sqrt(Vasf);
    Eam = max(Ea);
    phi = zeros(N,1);
    for k = 1:Nf
        integrand = zeros(Nf,1);
        for kk = 1:Nf-1
            if min(Ea(k),Ea(kk)) < Eam*1e-6
                integrand(kk) = 0;
            elseif kk == k
                k1 = max(k-1,1);
                k2 = min(k+1,Nf);
                integrand(kk) =...
                    (Ea(k2)-Ea(k1))/(Ea(k)*(omega(k2)^2-omega(k1)^2));
            else
                integrand(kk) = log(Ea(kk)/Ea(k))/(omega(kk)^2-omega(k)^2);
            end
        end
        phi(k) = (2*omega(k)*dOmega/pi)...
            * (sum(integrand) - 0.5*(integrand(1)+integrand(Nf)));
    end
    % Kramers-Kronig assumes that the profile is purely real, which gives
    % the transform conjugate symmetry.
    phi(Nf) = 0;
    phi(Nf+1:N) = -phi(Nf-1:-1:2);
    
    % Shift the reconstructed pulse by adding a linear slope to the phase.
    if testData
        jphx = find(abs(ux/max(ux)-1)<1e-6,1);
        phx = phx+2*pi*f*t(jphx);
    end
    uK = ifft(Ea.*exp(1i*phi),'symmetric'); % Reconstruct to find peak
    jphi = find(abs(uK/max(uK)-1)<1e-6,1);
    % Move peak to center of plot, or to match the exact test function
    if testData
        phi = unwrap(phi+2*pi*f*(t(jphi)-t(jphx)));
        phxLeft = 2*pi*f*(t(1)-t(jphx));  % For moving to start of plot
        phiLeft = phxLeft;
    else
        phi = unwrap(phi+2*pi*f*t(jphi));
        phiLeft = 2*pi*f*(t(1)-t(jphi+1));
    end
    phi(Nf) = 0;
    phi(Nf+1:N) = -phi(Nf-1:-1:2);
    
    % For clarity, plot the calculated phase without the slope.
    fig = 5;
    try
        set(0,'CurrentFigure',figHandles(fig))
        set(gcf,'Name','Kramers-Kronig Calculation of Phase')
    catch
        figHandles(fig) = figure('Name',...
            'Kramers-Kronig Calculation of Phase','Position',...
            [plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
    end
    pause(0.1)
    if testData
        plot(1e-12*f,unwrap(phx+phxLeft),'g--',...
             1e-12*f,unwrap(phi+phiLeft),'b')
        legend('Exact','Calculated')
    else
        plot(1e-12*f,unwrap(phi+phiLeft),'b')

    end
    set(gca,'XLim',1e-12*[f(1),f(kLim)])
    title([filename,' - Phase of Form Factor'])
    xlabel('Frequency (THz)')
    ylabel('Phase (radians)')
    
    % Get the beam's temporal profile from the magnitude and phase.
    uK = ifft(Ea.*exp(1i*phi),'symmetric');
    uK = uK-mean(uK(1:32));
    if testData
        uK = uK*max(ux)/max(uK);
    else
        uK = uK/max(uK);
    end
    % For a real scale (GV/m) on the electric-field (not bunch) profile
    if parabola(1)==0
        Epeak = 1e-9*sqrt(1e-3*THzEnergy/...
            (2*pi*epsilon0*c*1e-6*sigmax*sigmay*sum(uK.^2)*dt));
        uK = Epeak*uK;
    end
    
    % Plot the temporal profile, zooming in on the nonzero region.
    p = max(uK)*noiseThreshT;
    notNoise = uK>p | -uK>2*p;
    nn = find(notNoise);
    if isempty(nn)
        j1 = 1;
        j2 = N;
    else
        j1 = min(nn(min(noisePoints,length(nn))),N/2-10);
        j2 = max(nn(max(1,length(nn)-noisePoints+1)),j1+10);
    end
    nn = find(uK>max(uK)*0.25); % Equal margin on either side of max/4
    if ~isempty(nn)
        jj = max(nn(1)-j1,j2-nn(length(nn)));
        jj = max(jj,50);
        j1 = nn(1)-jj;
        j2 = nn(length(nn))+jj;
    end
    
    if testData
    p = max(ux)*noiseThreshT;
    notNoise = ux>p | -ux>2*p;
        nn = find(notNoise);
        if isempty(nn)
            j3 = 1;
            j4 = N;
        else
            j3 = min(nn(min(noisePoints,length(nn))),N/2);
            j4 = max(nn(max(1,length(nn)-noisePoints)),j1+10);
        end
        nn = find(ux>max(ux)*0.25);
        if ~isempty(nn)
            jj = max(nn(1)-j3,j4-nn(length(nn)));
            jj = max(jj,20);
            j3 = nn(1)-jj;
            j4 = nn(length(nn))+jj;
        end
        j1 = min(j1,j3);
        j2 = max(j2,j4);
    end
    jstart = max(1,j1-20);
    jstop =  min(N,j2+20);
    
    if max(abs(t(jstart)),abs(t(jstop))) >= 1e-11
        timescale = 1e12;
        timelabel = 'Time (ps)';
    else
        timescale = 1e15;
        timelabel = 'Time (fs)';
    end
    
    % Fit a Gaussian to the reconstructed profile (with time in ps).
    % Also, find the RMS width of the profile itself.
    % Use only points from the peak down to 10% of the peak value.
    jmax = jstart - 1 +...
        find(abs(uK(jstart:jstop)/max(uK(jstart:jstop))-1)<1e-6,1);
    switch guesses.gaussians
        case 0
            set(handles.Gauss1Ampl, 'String','')
            set(handles.Gauss1Mean, 'String','')
            set(handles.Gauss1Sigma,'String','')
            set(handles.Gauss2Ampl, 'String','')
            set(handles.Gauss2Mean, 'String','')
            set(handles.Gauss2Sigma,'String','')
            guesses.Gauss = zeros(1,6);
        case 1
            j1 = jmax+1-max(16,find(uK(jmax-1:-1:jstart)<uK(jmax)*0.1,1));
            j2 = jmax-1+max(16,find(uK(jmax+1:jstop)    <uK(jmax)*0.1,1));
            [gFit,gParam] =...
                gaussFit(timescale*t(j1:j2),uK(j1:j2),guesses.Gauss(1:3));
            set(handles.Gauss1Ampl, 'String',num2str(gParam(1),'%6.2f'))
            set(handles.Gauss1Mean, 'String',num2str(gParam(2),'%6.2f'))
            set(handles.Gauss1Sigma,'String',num2str(gParam(3),'%6.2f'))
            set(handles.Gauss2Ampl, 'String','')
            set(handles.Gauss2Mean, 'String','')
            set(handles.Gauss2Sigma,'String','')
            guesses.Gauss(1:3)  = gParam(1:3);
            guesses.Gauss(4:6)  = zeros(1,3);
            gParam(2:3) = gParam(2:3)/timescale;
            tPlot(1,:) = t(jstart):(t(j1)-t(jstart))/100:t(j1);
            tPlot(2,:) = t(j1)    :(t(j2)-t(j1))/100    :t(j2);
            tPlot(3,:) = t(j2)    :(t(jstop)-t(j2))/100 :t(jstop);
            fPlot = gParam(1)*exp(-0.5*((tPlot-gParam(2))/gParam(3)).^2);
        case 2
            j1 = jmax+1-max(15,find(uK(jmax-1:-1:jstart)<uK(jmax)*0.1,1));
            j2 = jmax-1+max(15,find(uK(jmax+1:jstop)    <uK(jmax)*0.1,1));
            [gFit,gParam] =...
                doubleGaussFit(timescale*t(j1:j2),uK(j1:j2),guesses.Gauss);
            disp(gParam)
            set(handles.Gauss1Ampl, 'String',num2str(gParam(1),'%6.2f'))
            set(handles.Gauss1Mean, 'String',num2str(gParam(2),'%6.2f'))
            set(handles.Gauss1Sigma,'String',num2str(gParam(3),'%6.2f'))
            set(handles.Gauss2Ampl, 'String',num2str(gParam(4),'%6.2f'))
            set(handles.Gauss2Mean, 'String',num2str(gParam(5),'%6.2f'))
            set(handles.Gauss2Sigma,'String',num2str(gParam(6),'%6.2f'))
            guesses.Gauss = gParam;
            gParam(2:3) = gParam(2:3)/timescale;
            gParam(5:6) = gParam(5:6)/timescale;
            tPlot(1,:) = t(jstart):(t(j1)-t(jstart))/100:t(j1);
            tPlot(2,:) = t(j1)    :(t(j2)-t(j1))/100    :t(j2);
            tPlot(3,:) = t(j2)    :(t(jstop)-t(j2))/100 :t(jstop);
            fPlot = gParam(1)*exp(-0.5*((tPlot-gParam(2))/gParam(3)).^2)...
                  + gParam(4)*exp(-0.5*((tPlot-gParam(5))/gParam(6)).^2);
    end
    tsum = 0;
    tmean = 0;
    tvar = 0;
    j1 = jmax + 1 - max(2,find(uK(jmax-1:-1:jstart)<uK(jmax)*0.1,1));
    j2 = jmax - 1 + max(2,find(uK(jmax+1:jstop)    <uK(jmax)*0.1,1));
    for j = j1:j2
        tsum  = tsum  + uK(j);
        tmean = tmean + uK(j)*t(j);
        tvar  = tvar  + uK(j)*t(j)^2;
    end
    widthRMS = sqrt(tvar/tsum-(tmean/tsum)^2);  
    
    fig = 6;
    try
        set(0,'CurrentFigure',figHandles(fig))
        set(gcf,'Name','Kramers-Kronig Calculation of Temporal Profile')
    catch
        figHandles(fig) = figure('Name',...
            'Kramers-Kronig Calculation of Temporal Profile','Position',...
            [plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
    end
    pause(0.1)
    if testData
        if guesses.gaussians == 0
            plot(timescale*t,ux,'g--',timescale*t,uK,'b')
            legend('Exact','Calculated','Location','NorthWest')
        else
            plot(timescale*tPlot(2,:),fPlot(2,:),'g--',...
                 timescale*t,ux,'r',timescale*t,uK,'b',...
                 timescale*tPlot(1,:),fPlot(1,:),'g-.',...
                 timescale*tPlot(3,:),fPlot(3,:),'g-.')
            legend('GaussFit','Exact','Calculated','Location','NorthEast')
        end
        title([filename,' - Test Data and Recreated Bunch'])
    else
        if guesses.gaussians == 0
            plot(timescale*t,uK,'b')
        else
            plot(timescale*tPlot(2,:),fPlot(2,:),'g',...
                 timescale*t,uK,'b',...
                 timescale*tPlot(1,:),fPlot(1,:),'g-.',...
                 timescale*tPlot(3,:),fPlot(3,:),'g-.')
            legend('Gauss Fit','Profile','Location','NorthWest')
        end
        if parabola(1)==0
            % Profile of electric field, not bunch
            title([filename,' - Reconstructed Field Profile'])
            ylabel('Electric Field (GV/m)');
        else
            title([filename,' - Reconstructed Bunch Profile'])
        end
    end
    yLim = get(gca,'YLim');
    text((0.97*t(jstart)+0.03*t(jstop))*timescale,...
          0.225*yLim(1)  +0.775*yLim(2),'For Points >= 10% of Peak',...
          'FontSize',12)
    text((0.95*t(jstart)+0.05*t(jstop))*timescale,...
          0.29*yLim(1)  +0.71*yLim(2),'RMS Profile Width:',...
          'FontSize',12)
    text((0.93*t(jstart)+0.07*t(jstop))*timescale,...
          0.39*yLim(1)  +0.61*yLim(2),...
        {texlabel(num2str(1e15 *widthRMS,'t_{RMS} = %3.0f fs'));...
         texlabel(num2str(1e6*c*widthRMS,'z_{RMS} = %3.0f {mu}m'))},...
         'FontSize',12)
    switch guesses.gaussians
        case 1
            text((0.95*t(jstart)+0.05*t(jstop))*timescale,...
                  0.49*yLim(1)  +0.51*yLim(2),'Gaussian Fit:',...
                  'FontSize',12)
            text((0.93*t(jstart)+0.07*t(jstop))*timescale,...
                  0.59*yLim(1)  +0.41*yLim(2),...
                {texlabel(num2str(1e15 *gParam(3),...
                   'sigma_t = %3.0f fs'));...
                 texlabel(num2str(1e6*c*gParam(3),...
                   'sigma_z = %3.0f {mu}m'))},'FontSize',12)
        case 2
            text((0.95*t(jstart)+0.05*t(jstop))*timescale,...
                  0.49*yLim(1)  +0.51*yLim(2),'Two-Gaussian Fit:',...
                  'FontSize',12)
            text((0.93*t(jstart)+0.07*t(jstop))*timescale,...
                  0.63*yLim(1)  +0.37*yLim(2),...
                {texlabel(num2str(1e15 *[gParam(3),gParam(6)],...
                   'sigma_t = %3.0f & %3.0f fs'));...
                 texlabel(num2str(1e6*c*[gParam(3),gParam(6)],...
                   'sigma_z = %3.0f & %3.0f {mu}m'));...
                 texlabel(num2str(1e15*(gParam(5)-gParam(2)),...
                   '{Delta}t = %3.0f fs'));...
                 texlabel(num2str(1e6*c*(gParam(5)-gParam(2)),...
                   '{Delta}z = %3.0f {mu}m'))},...
                'FontSize',12)
    end
    set(gca,'XLim',timescale*[t(jstart),t(jstop)])
    xlabel(timelabel)
    stepNum = stepNum + 1;
    oldBlaschke = -1;
end


% 6) blaschke: Approximate locations of zeros of the bunch spectrum, to
%    include the "Blaschke phase" term. Leave blank when not needed.
if nBlaschke ~= oldBlaschke || (nBlaschke == 0 && nWrap == 0)
    for n = 7:9
        try
            close(figHandles(n))
            figHandles(n) = 0;
        catch
        end
    end
end
if stepNum == 6
    % Region where uK is large
    oldBlaschke = nBlaschke;
    jmax = jstart - 1 +...
        find(abs(uK(jstart:jstop)/max(uK(jstart:jstop))-1)<1e-6,1);
    jp1 = jmax - find(uK(jmax-1:-1:jstart)<uK(jmax)*0.05,1);
    jp2 = jmax + find(uK(jmax+1:jstop)    <uK(jmax)*0.05,1);
    scoreK = ProfileScore(uK);
    score  = 10*ones(1,nBlaschke);
    if ~isempty(nBlaschke) && nBlaschke>0
        status = ['Calculating step ',num2str(stepNum),...
            ' of ',num2str(lastStep)];
        set(handles.Status,'String',status)
        pause(0.1)
        fig = 7;
        figHandles(fig) = figure('Name','Phase with Complex Zeros',...
            'Position',[plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
        colors = {'g-.';'b-.';'r--';'k--';'m--';'c--';'y--'};
        leg = cell(0);
        pause(0.1)
        
        % Baseline: Kramers-Kronig, without the Blaschke product
        % Replot Kramers-Kronig phase
        if testData
            scorex = ProfileScore(ux);
            plot(1e-12*f,unwrap(phx+phxLeft),colors{1})
            leg = {[num2str(scorex,'%5.3f'),': Exact']};
            hold on
        end
        plot(1e-12*f,unwrap(phi+phiLeft),colors{2})
        leg = [leg;[num2str(scoreK,'%5.3f'),': Kramers-Kronig']];
        ax1 = gca;
        title([filename,' - Phases with Complex Zeros'])
        xlabel('Frequency (THz)')
        ylabel('Phase (radians)')
        hold on

        % Replot Kramers-Kronig shape
        fig = 8;
        figHandles(fig) = figure('Name','Profile with Complex Zeros',...
            'Position',[plotX+plotStep*(fig-1),plotY-plotStep*(fig-1),...
            plotWidth,plotHeight]);
        if testData
            plot(timescale*t,ux,'g-.')
            hold on
        end
        plot(timescale*t,uK,'b-.')
        ax2 = gca;
        title([filename,' - Bunch Shape with Complex Zeros'])
        xlabel(timelabel)
        ylabel('Normalized')
        hold on
        color = 2;
        
        % Now optimize with one or more zeros.
        fzr =  (0  :0.2:1)*f(kLim);
        fzi = -(0.2:0.2:1)*f(kLim);
        Nr = length(fzr);
        Ni = length(fzi);
        zer = zeros(0);
        zb = zeros(0);
        phb = zeros(N,nBlaschke);
        ub = zeros(N,nBlaschke);
        options = optimset('MaxIter',25,'TolFun',0.001,...
            'TolX',f(kLim)*0.001,'Display','off');
        for nb = 1:nBlaschke
            if nb == 1
                set(handles.Status,'String',[status,', with 1 zero'])
            else
                set(handles.Status,'String',...
                    [status,', with ',num2str(nb),' zeros'])
            end
            pause(0.1)
            if length(zer) == 2*(nb-1)
                for nr = 1:Nr
                    for ni = 1:Ni
                        [z,scr] = fminsearch(@BlaschkeZero,...
                            [zer,fzr(nr),fzi(ni)],options);
                        if scr < score(nb) && all(z(2:2:2*nb)<0) &&...
                                all(abs(z)<10*f(kLim))
                            score(nb) = scr;
                            zb = z;
                            phb(:,nb) = phz;
                            ub(:,nb) = uz;
                        end
                    end
                end
            end
            if score(nb) < 10
                if testData
                    ub(:,nb) = ub(:,nb)*max(ux);
                else
                    ub(:,nb) = ub(:,nb)*max(uK);
                end
                zer = zb;
                color = min(color+1,length(colors));
                plot(ax1,1e-12*f,unwrap(phb(:,nb)+phiLeft),colors{color})
                plot(ax2,timescale*t,ub(:,nb),colors{color})
                zstr = '';
                for n = 1:2:2*nb
                    zstr = [zstr,' ',...
                        num2str(1e-12*(zb(n)+zb(n+1)*1i),'%7.2f'),','];
                end
                zstr = zstr(1:length(zstr)-1);
                leg = [leg;[num2str(score(nb),'%5.3f'),':',zstr]];
            end
        end
        
        set(ax1,'XLim',1e-12*[f(1),f(kLim)])
        yLim = get(ax1,'YLim');
        if yLim(1)+yLim(2) >= 0
            legLoc = 'NorthWest';
        else
            legLoc = 'SouthWest';
        end
        legend(ax1,leg,'Location',legLoc,'FontSize',10)
        hold(ax1,'off')
        set(ax2,'XLim',timescale*[t(jstart),t(jstop)])
        legend(ax2,leg,'Location','NorthWest','FontSize',10)
        hold(ax2,'off')
        
        if min(score) < 10
            scoreB = min(score);
            nb = find(score==scoreB,1);
            uB = ub(:,nb);
        else
            scoreB = 10;
        end
    end
    stepNum = stepNum + 1;
end

% 7) shrinkwrap: Iterative improvement by chopping negative and non-causal
%    features in time domain, getting corresponding phase in frequency
%    domain, and using this with DC-restored magnitude to find a new, and
%    perhaps better, temporal profile.
if stepNum == 7
    if ~isempty(nWrap) && nWrap > 0
        status = ['Calculating step ',num2str(stepNum),...
            ' of ',num2str(lastStep)];
        set(handles.Status,'String',status)
        pause(0.1)
        if nBlaschke
            leg = cell(3+testData,1);
            leg{2+testData} = sprintf('%5.3f: Blaschke',scoreB);
        else
            leg = cell(2+testData,1);
        end
        if testData
            leg{1} = 'Exact';
        end
        leg{1+testData} = sprintf('%5.3f: Kramers-Kronig',scoreK);
        if scoreB < scoreK
            uW = uB;
        else
            uW = uK;
        end
        jmax = jstart - 1 +...
            find(abs(uW(jstart:jstop)/max(uW(jstart:jstop))-1)<1e-6,1);
        jp1 = jmax - find(uW(jmax-1:-1:jstart)<uW(jmax)*0.05,1);
        jp2 = jmax + find(uW(jmax+1:jstop)    <uW(jmax)*0.05,1);
%         scoreW = 10;
%         nw = 0;
%         new = 1;
%         while nw < nWrap
%             nw = nw + 1;
%             if new
%                 % Clean up the previous time profile
%                 uW1 = [zeros(jp1,1);ones(jp2-jp1-1,1);zeros(N-jp2+1,1)].*uW;
%                 vW = fft(uW1);  % Go back to the frequency domain
%                 phW0 = angle(vW);
%                 phW = phW0;
%             else
%                 phW = phW0 + rand(N,1)*0.1;
%             end
%             % Kramers-Kronig magnitude with new phase, plus phase noise
%             uW2 = ifft(Ea.*exp(1i*phW),'symmetric');
%             uW2 = uW2-mean(uW2(1:32));
%             if testData
%                 uW2 = uW2*max(ux)/max(uW2);
%             else
%                 uW2 = uW2/max(uW2);
%             end
%             scoreW2 = ProfileScore(uW2);
%             if scoreW2 < scoreW
%                 scoreW = scoreW2;
%                 uW = uW2;
%                 new = 1;
%                 disp([nw scoreW])
%             else
%                 new = 0;
%             end
%         end
        options = optimset('MaxIter',nWrap,'TolFun',0.0001,'Display','off');
        [phWk,scoreW] = fminsearch(@ShrinkWrapper,phi(1:kLim),options);
        phW = [phWk;phi(kLim+1:N-kLim+1);-phWk(kLim:-1:2)];
        uW = ifft(Ea.*exp(1i*phW),'symmetric');
        uW = uW-mean(uW(1:32));
        if testData
            uW = uW*max(ux)/max(uW);
        else
            uW = uW/max(uW);
        end
        
        % Replot previous profile with the shrink-wrap result
        fig = 9;
        n=1;
        if all(figHandles(7:8)==0)
            n=3;
        end
        try
            set(0,'CurrentFigure',figHandles(fig))
            set(gcf,'Name','   Profile Refined using Shrink-Wrap')
        catch
        figHandles(fig) = figure('Name','   Profile Refined using Shrink-Wrap',...
            'Position',[plotX+plotStep*(fig-n),plotY-plotStep*(fig-n),...
            plotWidth,plotHeight]);
        end
        if testData
            plot(timescale*t,ux,'g-.')
            hold on
        end
        plot(timescale*t,uK,'b-.')
        hold on
        if nBlaschke
            plot(timescale*t,uB,'k--')
        end                
        plot(timescale*t,uW,'r--')
        hold off
        title([filename,' - Profile Refined using Shrink-Wrap'])
        xlabel(timelabel)
        ylabel('Normalized')
        set(gca,'XLim',timescale*[t(jstart),t(jstop)])
        leg{size(leg,1)} = sprintf('%5.3f: Shrink-Wrap',scoreW);
        legend(leg,'Location','NorthWest','FontSize',10)
    end
end

step = steps(stepNum);
set(handles.Status,'String','Calculation completed.')
end


function score = BlaschkeZero(zer)

global N f Nf
global Ea phi
global phz uz

fz = complex(zeros(1,length(zer)/2));
for n = 1:length(zer)/2
    fz(n) = zer(2*n-1)+zer(2*n)*1i;
end
Nb = length(fz);
nb = 0;
phz = phi;
while nb < Nb
    nb = nb+1;
    phz = phz + angle((f-fz(nb)).*(f+conj(fz(nb)))...
                   ./((f+fz(nb)).*(f-conj(fz(nb)))));
end
phz(Nf) = 0;
phz(Nf+1:N) = -phz(Nf-1:-1:2);

uz = ifft(Ea.*exp(1i*phz),'symmetric');
uz = uz-mean(uz(1:32));
uz = uz/max(uz);
score = ProfileScore(uz);
end


function score = ShrinkWrapper(phk)
global N kLim Ea phi
% Vary only phases phk at frequencies with significant magnitude.
% Recall that the transform must have conjugate symmetry so that u is real.
phase = [phk;phi(kLim+1:N-kLim+1);-phk(kLim:-1:2)];
u = ifft(Ea.*exp(1i*phase),'symmetric');
score = ProfileScore(u);
end



function score = ProfileScore(u)
global jstart jstop jp1 jp2
% A good reconstruction is positive and without a prepulse or tail.

ujj = u(jstart:jstop);
uajj = abs(ujj);
tails = [2*ones(1,jp1-jstart+1),zeros(1,jp2-jp1-1),...
           ones(1,jstop-jp2+1)]*uajj;
neg = -(ujj'*(ujj<0));
score = sqrt(tails^2+neg^2)/sum(uajj);
end


function [fit,p] = filterFit(x,y)
% Use this to fit a high-pass Gaussian filter, transformed to the time
% domain, to points (x,y) with equal x spacing, sorted in order of
% increasing x. In the frequency domain, the filter for the electric field
% is 1-exp(-xi^2*omega^2) = 1-exp(-f^2/hpFilter^2). We multiply this by the
% transform of a Gaussian bunch, take the squared magnitude, and do the fit
% in the time domain in the region near the spectral peak. The parameters
% are:
%   p(1) = amplitude
%   p(2) = mean x value
%   p(3) = sigma of the Gaussian beam
%   p(4) = xi (width) of the filter
%   p(5) = offset
% Afterward, we throw away the fit to the bunch sigma, since it generally
% is not Gaussian, but keep the filter width xi. We convert xi to hpFilter
% in THz

p0 = zeros(1,4);
p0(1) = max(y);
p0(2) = x(find(y==p0(1),1,'first'));
halfmax = find(y>p0(1)/2);
if length(halfmax)>1
    p0(3) = (x(halfmax(length(halfmax)))-x(halfmax(1)))/2.35;
end
p0(3) = max(p0(3),x(3)-x(1));
p0(4) = 1/(2*pi*0.5);	% Use 0.5 THz as a guess.
p0(5) = 0;

p = fminsearch(@filterFitError,p0);
fit =                   p(5) + p(1)*(exp(-0.25*(x-p(2)).^2/p(3)^2)...
      - 2*(p(3)/sqrt(p(3)^2+p(4)^2))*exp(-0.25*(x-p(2)).^2/(p(3)^2+p(4)^2))...
      + (p(3)/sqrt(p(3)^2+2*p(4)^2))*exp(-0.25*(x-p(2)).^2/(p(3)^2+2*p(4)^2)));
p(4) = 1/abs(2*pi*p(4));

    function sse = filterFitError(p)
    f =                 p(5) + p(1)*(exp(-0.25*(x-p(2)).^2/p(3)^2)...
      - 2*(p(3)/sqrt(p(3)^2+p(4)^2))*exp(-0.25*(x-p(2)).^2/(p(3)^2+p(4)^2))...
      + (p(3)/sqrt(p(3)^2+2*p(4)^2))*exp(-0.25*(x-p(2)).^2/(p(3)^2+2*p(4)^2)));
    sse = sum((f-y).^2);
    end
end


function [fit,p] = gaussFit(x,y,p0)
% Use this to fit a Gaussian to points (x,y) with equal x spacing,
% sorted in order of increasing x. The function is:
% y = p(1)*exp(-0.5*((x-p(2))/p(3))^2)
% Initial guesstitle for the parameters are in p0, but new guesstitle are
% calculated if the input sigma is zero.

if p0(3) <= 0 || length(p0)~=3
    p0(1) = max(y);
    p0(2) = x(find(y==p0(1),1,'first'));
    halfmax = find(y>p0(1)/2);
    if length(halfmax)>1
        p0(3) = ((x(halfmax(length(halfmax)))-x(halfmax(1)))/2.355);
    end
    p0(3) = max(p0(3),x(3)-x(1));
end

p = fminsearch(@gaussFitError,p0);
p(3) = abs(p(3));
fit = p(1)*exp(-0.5*((x-p(2))/p(3)).^2);

    function sse = gaussFitError(p)
    f = p(1)*exp(-0.5*((x-p(2))/p(3)).^2);
    sse = sum((f-y).^2);
    end
end


function [fit,p] = doubleGaussFit(x,y,p0)
% Use this to fit a sum of two Gaussians to points (x,y) with equal x
% spacing, sorted in order of increasing x. The function is:
% y = abs(p(1))*exp(-0.5*((x-p(2))/p(3))^2)+abs(p(4))*exp(-0.5*((x-p(5))/p(6))^2)
% Initial guesstitle for the parameters are in p0, but new guesstitle are
% calculated for each Gaussian if its input sigma is zero.

N = length(x);

% Initial guesstitle for first Gaussian
if p0(3)<=0 || length(p0)~=6
    k = find(y>=max(y)*0.1,1,'first');
    kPeak = k;
    p0(1) = y(k);
    p0(2) = x(k);
    p0(3) = 0;
    while k < N
        k = k+1;
        if y(k) > p0(1)
            kPeak = k;
            p0(1) = y(k);
            p0(2) = x(k);
        elseif y(k) < 0.85*p0(1)
            k = N;
        end
    end
    halfmax = find(y(1:kPeak)<p0(1)*0.5,1,'last');
    if ~isempty(halfmax)
        p0(3) = (x(kPeak)-x(halfmax(1)))/1.177;
    end
    p0(3) = max(p0(3),x(2)-x(1));
end

% Initial guesstitle for second Gaussian
if p0(6) <= 0 || length(p0)~=6
    k = find(y>=max(y)*0.1,1,'last');
    kPeak = k;
    k = kPeak;
    p0(4) = y(k);
    p0(5) = x(k);
    p0(6) = 0;
    while k > 1
        k = k-1;
        if y(k) > p0(4)
            kPeak = k;
            p0(4) = y(k);
            p0(5) = x(k);
        elseif y(k) < 0.85*p0(4)
            k = 1;
        end
    end
    halfmax = find(y(kPeak:N)<p0(4)*0.5,1,'first');
    if ~isempty(halfmax)
        p0(6) = (x(kPeak+halfmax(1)-1)-x(kPeak))/1.177;
    end
    p0(6) = max(p0(6),x(2)-x(1));
end

p = fminsearch(@doubleGaussFitError,p0);
p(1) = abs(p(1));
p(3) = abs(p(3));
p(4) = abs(p(4));
p(6) = abs(p(6));
fit = p(1)*exp(-0.5*((x-p(2))/p(3)).^2) + p(4)*exp(-0.5*((x-p(5))/p(6)).^2);

    function sse = doubleGaussFitError(p)
    f = abs(p(1))*exp(-0.5*((x-p(2))/p(3)).^2)...
      + abs(p(4))*exp(-0.5*((x-p(5))/p(6)).^2);
    sse = sum((f-y).^2);
    end
end
