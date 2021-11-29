function varargout = ULT_AdditionalPlot(varargin)
% ULT_ADDITIONALPLOT MATLAB code for ULT_AdditionalPlot.fig
%      ULT_ADDITIONALPLOT, by itself, creates a new ULT_ADDITIONALPLOT or raises the existing
%      singleton*.
%
%      H = ULT_ADDITIONALPLOT returns the handle to a new ULT_ADDITIONALPLOT or the handle to
%      the existing singleton*.
%
%      ULT_ADDITIONALPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT_ADDITIONALPLOT.M with the given input arguments.
%
%      ULT_ADDITIONALPLOT('Property','Value',...) creates a new ULT_ADDITIONALPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_AdditionalPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_AdditionalPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT_AdditionalPlot

% Last Modified by GUIDE v2.5 08-Oct-2019 09:37:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ULT_AdditionalPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @ULT_AdditionalPlot_OutputFcn, ...
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


% --- Executes just before ULT_AdditionalPlot is made visible.
function ULT_AdditionalPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT_AdditionalPlot (see VARARGIN)

petizione.To=3.52;set(handles.PlotTo,'string',num2str(petizione.To));
petizione.From=3.41;set(handles.PlotTo,'string',num2str(petizione.From));
petizione.FullRange=0; petizione.AutoRange=0; petizione.ManualRange=1; petizione.UpdateNow=1;
set(handles.Petizione,'userdata',petizione);
set(handles.ADD_Markers,'userdata',[]);
% Choose default command line output for ULT_AdditionalPlot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ULT_AdditionalPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ULT_AdditionalPlot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function PlotFrom_Callback(hObject, eventdata, handles)
VAL=str2double(get(hObject,'string'));
petizione=get(handles.Petizione,'userdata');
if(~isempty(VAL) && ~isnan(VAL) && ~isinf(VAL))
    if(petizione.To>VAL)
        petizione.From=VAL;
        set(handles.Petizione,'userdata',petizione);
        return
    elseif(abs(petizione.To - VAL)<10^-4)
        petizione.From=petizione.To-10^-4;
        set(handles.Petizione,'userdata',petizione);
        return
    elseif(petizione.To<VAL)
        petizione.From=petizione.To;
        petizione.To=VAL;
        set(handles.PlotTo,'string',num2str(VAL));
        set(handles.From,'string',num2str(petizione.From));
        set(handles.Petizione,'userdata',petizione);
        return
    end
    petizione.UpdateNow=1;
    set(handles.Petizione,'userdata',petizione);
end


% --- Executes during object creation, after setting all properties.
function PlotFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlotTo_Callback(hObject, eventdata, handles)
VAL=str2double(get(hObject,'string'));
petizione=get(handles.Petizione,'userdata');
if(~isempty(VAL) && ~isnan(VAL) && ~isinf(VAL))
    if(petizione.From<VAL)
        petizione.To=VAL;
        set(handles.Petizione,'userdata',petizione);
        return
    elseif(abs(petizione.To - VAL)<10^-4)
        petizione.To=petizione.From + 10^-4;
        set(handles.Petizione,'userdata',petizione);
        return
    elseif(petizione.From > VAL)
        petizione.To=petizione.From;
        petizione.From=VAL;
        set(handles.PlotFrom,'string',num2str(VAL));
        set(handles.PlotTo,'string',num2str(petizione.To));
        set(handles.Petizione,'userdata',petizione);
        return
    end
    petizione.UpdateNow=1;
    set(handles.Petizione,'userdata',petizione);
end


% --- Executes during object creation, after setting all properties.
function PlotTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FullRange.
function FullRange_Callback(hObject, eventdata, handles)
set(handles.FullRange,'value',1);set(handles.AutoRange,'value',0);set(handles.ManualRange,'value',0);
set(handles.FullRange,'userdata',1);
petizione=get(handles.Petizione,'userdata');
petizione.FullRange=1; petizione.AutoRange=0; petizione.ManualRange=0; petizione.UpdateNow=1;
set(handles.Petizione,'userdata',petizione);

% --- Executes on button press in AutoRange.
function AutoRange_Callback(hObject, eventdata, handles)
set(handles.FullRange,'value',0);set(handles.AutoRange,'value',1);set(handles.ManualRange,'value',0);
set(handles.FullRange,'userdata',2);
petizione.FullRange=0; petizione.AutoRange=1; petizione.ManualRange=0; petizione.UpdateNow=1;
set(handles.Petizione,'userdata',petizione);

% --- Executes on button press in ManualRange.
function ManualRange_Callback(hObject, eventdata, handles)
set(handles.FullRange,'value',0);set(handles.AutoRange,'value',0);set(handles.ManualRange,'value',1);
set(handles.FullRange,'userdata',3);
petizione.FullRange=0; petizione.AutoRange=0; petizione.ManualRange=1; petizione.UpdateNow=1;
set(handles.Petizione,'userdata',petizione);


% --- Executes during object creation, after setting all properties.
function ADD_Markers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADD_Markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
