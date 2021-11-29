function varargout = KnifeEdge(varargin)
% KNIFEEDGE M-file for KnifeEdge.fig
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

%      KNIFEEDGE, by itself, creates a new KNIFEEDGE or raises the existing
%      singleton*.
%
%      H = KNIFEEDGE returns the handle to a new KNIFEEDGE or the handle to
%      the existing singleton*.
%
%      KNIFEEDGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KNIFEEDGE.M with the given input
%      arguments.
%
%      KNIFEEDGE('Property','Value',...) creates a new KNIFEEDGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KnifeEdge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KnifeEdge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KnifeEdge

% Last Modified by GUIDE v2.5 25-Jul-2012 08:59:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KnifeEdge_OpeningFcn, ...
                   'gui_OutputFcn',  @KnifeEdge_OutputFcn, ...
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


% --- Executes just before KnifeEdge is made visible.
function KnifeEdge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KnifeEdge (see VARARGIN)

% Choose default command line output for KnifeEdge
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KnifeEdge wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global THzSource filePath fileName figHandle
global amplitude mean sigma

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

mean  = 0;
sigma = 0;
amplitude = 0;

set(handles.Mean,  'String','')
set(handles.Sigma, 'String','')
set(handles.Amplitude, 'String','')
set(handles.Status,'String','')

figHandle = 0;

end


% --- Outputs from this function are returned to the command line.
function varargout = KnifeEdge_OutputFcn(hObject, eventdata, handles) 
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

global filePath
filePath = get(hObject,'String');
if ~isempty(filePath) && ~strcmp(filePath(length(filePath)),'/')
    filePath = [filePath,'/'];
    set(hObject,'String',filePath)
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

global fileName
fileName = get(hObject,'String');
if strcmp(fileName(1),'/')
    fileName = fileName(2:length(fileName));
    set(hObject,'String',fileName)
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

global filePath fileName

[filename,filepath] = uigetfile({'*.txt';'*.dir'},...
    'Select a Scan File',filePath);

if isequal(filename,0) || isequal(filepath,0)
    set(handles.Status,'String',' Canceled by user.')
else
    filePath = filepath;
    fileName = filename;
    set(handles.FilePath,'String',filePath)
    set(handles.FileName,'String',fileName)
end
end



function Mean_Callback(hObject, eventdata, handles)
% hObject    handle to Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mean as text
%        str2double(get(hObject,'String')) returns contents of Mean as a double

global mean
set(hObject,'String',num2str(mean))
set(handles.Status,'String','')
end



% --- Executes during object creation, after setting all properties.
function Mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Sigma_Callback(hObject, eventdata, handles)
% hObject    handle to Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sigma as text
%        str2double(get(hObject,'String')) returns contents of Sigma as a double

global sigma
set(hObject,'String',num2str(sigma))
set(handles.Status,'String','')
end


% --- Executes during object creation, after setting all properties.
function Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Amplitude_Callback(hObject, eventdata, handles)
% hObject    handle to Amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Amplitude as text
%        str2double(get(hObject,'String')) returns contents of Amplitude as a double

global amplitude
set(hObject,'String',num2str(amplitude))
set(handles.Status,'String','')
end


% --- Executes during object creation, after setting all properties.
function Amplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Amplitude (see GCBO)
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
global figHandle
if ishandle(figHandle)
    util_printLog(figHandle)
    status = ' Figure sent to eLog.';
else
    status = ' No valid figure.';
end
set(handles.Status,'String',status)
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

global filePath fileName figHandle
global amplitude mean sigma

plotX = 5;
plotY = 350;
plotWidth = 560;
plotHeight = 420;

% Get scan data
try
    % Get the time steps and data.
    data = load([filePath,fileName],'-ascii');
    x = data(:,1);
    y = data(:,size(data,2));
    status = ' File loaded.';
    OK = 1;
catch ME
    status = [' Error in loading file: ',ME.message];
    OK = 0;
end
set(handles.Status,'String',status)

if OK
    y = y*sign(abs(max(y))-abs(min(y))); % Invert if signal is negative
    [fit,p]=erffit(x,y);
    amplitude = p(1);
    mean      = p(2);
    sigma     = p(3);

    set(handles.Amplitude,'String',num2str(amplitude))
    set(handles.Mean,     'String',num2str(mean))
    set(handles.Sigma,    'String',num2str(sigma))

    % Plot the scan data.
    try
        set(0,'CurrentFigure',figHandle)
        set(gcf,'Name','Knife-Edge Scan')
    catch
        figHandle = figure('Name','Interferometer Scan',...
            'Position',[plotX,plotY,plotWidth,plotHeight]);
    end
    pause(0.1)
    plot(x,y,'or',x,fit,'b')
    title(['Knife-Edge Scan with erf Fit - ',fileName]);
    xlabel('Blade position (mm)');
    ylabel('Signal');
    xlimits = xlim;
    text(xlimits(1)+0.05*(xlimits(2)-xlimits(1)), max(y)/2,...
        {texlabel(num2str(mean,'mu = %2.3f mm'));...
         texlabel(num2str(sigma,'sigma = %2.3f mm'))},'Fontsize',14);
    set(handles.Status,'String',' Calculation completed.')
end
end    



function [fit,p] = erffit(x,y)
% Use this to fit an error function points (x,y) with equal x spacing,
% sorted in increasing x order. The function, the integral of a Gaussian
% beam, is given by:
% y = p(1)*p(3)*sqrt(pi/2)*(1+erf((x-p(2))/(sqrt(2)*p(3)))

% Initial guesses for parameters
p0 = zeros(1,3);
M = max(y);
yM = abs(y-M/2);
halfmax = find(yM==min(yM),1,'first');
% Mean of Gaussian, midpoint of integral
p0(2) = x(halfmax);
% Amplitude of Gaussian, amplitude of integral at mean
p0(1) = ((y(halfmax+2)-y(halfmax-2))/(x(halfmax+2)-x(halfmax-2)));
% Sigma of Gaussian
p0(3) = M/(sqrt(2*pi)*p0(1));

model = @erfFitError;
p = fminsearch(model,p0);
if p(1) < 0 && p(3) < 0
    p(1) = -p(1);
    p(3) = -p(3);
    s = -1;
else
    s = 1;
end
fit = p(1)*p(3)*sqrt(pi/2)*(1+erf(s*(x-p(2))/(sqrt(2)*p(3))));

    function sse = erfFitError(p)
    f = p(1)*p(3)*sqrt(pi/2)*(1+erf((x-p(2))/(sqrt(2)*p(3))));
    sse = sum((f-y).^2);
    end
end
