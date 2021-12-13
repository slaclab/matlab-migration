function varargout = facet_dither(varargin)
% FACET_DITHER M-file for facet_dither.fig
%      FACET_DITHER, by itself, creates a new FACET_DITHER or raises the existing
%      singleton*.
%
%      H = FACET_DITHER returns the handle to a new FACET_DITHER or the handle to
%      the existing singleton*.
%
%      FACET_DITHER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_DITHER.M with the given input arguments.
%
%      FACET_DITHER('Property','Value',...) creates a new FACET_DITHER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_dither_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_dither_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_dither

% Last Modified by GUIDE v2.5 22-Jun-2012 15:12:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_dither_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_dither_OutputFcn, ...
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


% --- Executes just before facet_dither is made visible.
function facet_dither_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_dither (see VARARGIN)

% Choose default command line output for facet_dither
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes facet_dither wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = facet_dither_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

oldstr = get(hObject, 'String');
set(hObject, 'String', 'Dithering...');

% get GUI stuff
handles.knob = get(handles.edit_knob, 'String');
handles.diag = get(handles.edit_diagname, 'String');
handles.constrain = get(handles.checkbox_constrain, 'Value');
handles.step = str2double(get(handles.edit_stepsize, 'String'));
handles.samp = str2double(get(handles.edit_samples, 'String'));
handles.wait = str2double(get(handles.edit_wait, 'String'));
handles.settle = str2double(get(handles.edit_wait, 'String'));
handles.gain = str2double(get(handles.edit_gain, 'String'));

gui_statusDisp(handles, 'Initializing dither...');
drawnow;

% start AIDA multiknob
try
    requestBuilder = pvaRequest('MKB:VAL');
    requestBuilder.with('MKB', strcat('MKB:', handles.knob));
catch
    gui_statusDisp(handles, strcat({'Error starting AIDA multiknob utility for '}, handles.knob));
    return;
end

% start monitor on BLEN
try
    lcaSetMonitor(handles.diag);
catch
    gui_statusDisp(handles, strcat({'Channel access error, cannot monitor '}, handles.diag));
    return;
end

x = zeros(3, 1);
y = zeros(3, handles.samp);

% main loop
while get(hObject, 'Value')

    % get data at starting value
    x(1) = dith(requestBuilder, handles, handles.step * 0);
    gui_statusDisp(handles, strcat({'Set '}, handles.knob, {' to '}, num2str(x(1))));
    pause(handles.settle);
    gui_statusDisp(handles, strcat({'Acquiring '}, num2str(handles.samp), {' points'}));
    for ix = 1:handles.samp
        lcaNewMonitorWait(handles.diag);
        y(1, ix) = lcaGetSmart(handles.diag);
    end

    % facet_dither positive
    x(2) = dith(requestBuilder, handles, handles.step * 1);
    gui_statusDisp(handles, strcat({'Set '}, handles.knob, {' to '}, num2str(x(2))));
    pause(handles.settle);
    gui_statusDisp(handles, strcat({'Acquiring '}, num2str(handles.samp), {' points'}));
    for ix = 1:handles.samp
        lcaNewMonitorWait(handles.diag);
        y(2, ix) = lcaGetSmart(handles.diag);
    end

    % facet_dither negative
    x(3) = dith(requestBuilder, handles, handles.step * -2);
    gui_statusDisp(handles, strcat({'Set '}, handles.knob, {' to '}, num2str(x(3))));
    pause(handles.settle);
    gui_statusDisp(handles, strcat({'Acquiring '}, num2str(handles.samp), {' points'}));
    for ix = 1:handles.samp
        lcaNewMonitorWait(handles.diag);
        y(3, ix) = lcaGetSmart(handles.diag);
    end

    % add some noise (for testing)
    %y = y + randn(size(y));

    yavg = mean(y, 2);  % avg over samples
    ystd = std(y, 0, 2);    % error bars
    xfit = linspace(min(x), max(x), 100); % x values for plotting the fit

    % fit to parabola
    [par, yfit, parstd, yfitstd] = util_parabFit(x, yavg, ystd, xfit);
    xpeak = par(2);
    ypeak = par(3);

    if handles.constrain
        if xpeak < min(x)
            xpeak = min(x);
            ypeak = yfit(1);
        end
        if xpeak > max(x)
            xpeak = max(x);
            ypeak = yfit(100);
        end
    end

    axes(handles.axes1);
    reset(handles.axes1);

    % plot data
    for ix = 1:numel(x)
        plot(handles.axes1, x(ix), y(ix, :), 'ko');
        hold all;
    end

    % plot fit
    plot(handles.axes1, xfit, yfit, 'b-');

    % draw peak
    plot(xpeak, ypeak, 'r*');

    % make some whitespace
    xlim('auto');

    % move to new peak
    xdiff = xpeak - x(1);
    % add stepsize because we have left off at the low point
    dx = (handles.gain * xdiff) + handles.step;
    xnew = dith(requestBuilder, handles, dx);
    gui_statusDisp(handles, strcat({'New setpoint is '}, num2str(xnew)), {' degS.'});

    % wait
    drawnow;
    pause(handles.wait);
end

set(hObject, 'String', oldstr);

function val = dith(requestBuilder, handles, stepsize)

try
    answer = requestBuilder.set(stepsize);
    values = toArray(answer.get('value'));
    val = mean(values);
catch
    gui_statusDisp(handles, strcat('AIDA Error setting ', handles.knob));
    val = NaN;
    return
end


function edit_stepsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stepsize as text
%        str2double(get(hObject,'String')) returns contents of edit_stepsize as a double


% --- Executes during object creation, after setting all properties.
function edit_stepsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_constrain.
function checkbox_constrain_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_constrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_constrain



function edit_knob_Callback(hObject, eventdata, handles)
% hObject    handle to edit_knob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_knob as text
%        str2double(get(hObject,'String')) returns contents of edit_knob as a double


% --- Executes during object creation, after setting all properties.
function edit_knob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_knob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_diagname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_diagname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_diagname as text
%        str2double(get(hObject,'String')) returns contents of edit_diagname as a double


% --- Executes during object creation, after setting all properties.
function edit_diagname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_diagname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_samples_Callback(hObject, eventdata, handles)
% hObject    handle to edit_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_samples as text
%        str2double(get(hObject,'String')) returns contents of edit_samples as a double


% --- Executes during object creation, after setting all properties.
function edit_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_wait_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wait as text
%        str2double(get(hObject,'String')) returns contents of edit_wait as a double


% --- Executes during object creation, after setting all properties.
function edit_wait_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gain as text
%        str2double(get(hObject,'String')) returns contents of edit_gain as a double


% --- Executes during object creation, after setting all properties.
function edit_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_settle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_settle as text
%        str2double(get(hObject,'String')) returns contents of edit_settle as a double


% --- Executes during object creation, after setting all properties.
function edit_settle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


