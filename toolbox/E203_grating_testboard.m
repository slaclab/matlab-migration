function varargout = E203_grating_testboard(varargin)
% E203_GRATING_TESTBOARD M-file for E203_grating_testboard.fig
%      E203_GRATING_TESTBOARD, by itself, creates a new E203_GRATING_TESTBOARD or raises the existing
%      singleton*.
%
%      H = E203_GRATING_TESTBOARD returns the handle to a new E203_GRATING_TESTBOARD or the handle to
%      the existing singleton*.
%
%      E203_GRATING_TESTBOARD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in E203_GRATING_TESTBOARD.M with the given input arguments.
%
%      E203_GRATING_TESTBOARD('Property','Value',...) creates a new E203_GRATING_TESTBOARD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before E203_grating_testboard_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to E203_grating_testboard_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help E203_grating_testboard

% Last Modified by GUIDE v2.5 06-Nov-2013 04:47:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @E203_grating_testboard_OpeningFcn, ...
                   'gui_OutputFcn',  @E203_grating_testboard_OutputFcn, ...
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


% --- Executes just before E203_grating_testboard is made visible.
function E203_grating_testboard_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to E203_grating_testboard (see VARARGIN)

% Choose default command line output for E203_grating_testboard
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes E203_grating_testboard wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = E203_grating_testboard_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Setpoint_M6_Callback(hObject, eventdata, handles)
% hObject    handle to Setpoint_M6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Setpoint_M6 as text
%        str2double(get(hObject,'String')) returns contents of Setpoint_M6 as a double


% --- Executes during object creation, after setting all properties.
function Setpoint_M6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Setpoint_M6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in minus_1_mm.
function minus_1_mm_Callback(hObject, eventdata, handles)
% hObject    handle to minus_1_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a-1
if a<0
    set(handles.Status,'String',' Position lower than Low Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)


var3=lcaGet('XPS:LI20:DWFA:M6.RBV');  %%%%% IMPORTANT TEST
set(handles.Readback_M6,'String',num2str(var3)) ;

end % end for i=1:20
set(handles.Status,'String','')


        end
end



% --- Executes on button press in plus_1_mm.
function plus_1_mm_Callback(hObject, eventdata, handles)
% hObject    handle to plus_1_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a+1
str2=num2str(a)


if a>49
    set(handles.Status,'String',' Position above High Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end
end


% --- Executes on button press in plus_100_um.
function plus_100_um_Callback(hObject, eventdata, handles)
% hObject    handle to plus_100_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a+0.1
str2=num2str(a)


if a>49
    set(handles.Status,'String',' Position above High Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end
end

% --- Executes on button press in minus_100_um.
function minus_100_um_Callback(hObject, eventdata, handles)
% hObject    handle to minus_100_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a-0.1
str2=num2str(a)

if a<0
    set(handles.Status,'String',' Position lower than Low Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end

end


% --- Executes on button press in plus_50_um.
function plus_50_um_Callback(hObject, eventdata, handles)
% hObject    handle to plus_50_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a+0.05
str2=num2str(a)

if a>49
    set(handles.Status,'String',' Position above High Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end
end


% --- Executes on button press in minus_50_um.
function minus_50_um_Callback(hObject, eventdata, handles)
% hObject    handle to minus_50_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a-0.05
str2=num2str(a)

if a<0
    set(handles.Status,'String',' Position lower than Low Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end
end

% --- Executes on button press in rotate_grating.
function rotate_grating_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_grating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('XPS:LI20:DWFA:M6',27)

for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
set(handles.Status,'String','Now code pausing. Please wait a few sec...') ;
pause(7)
set(handles.Status,'String','') ;

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3))
lcaPutSmart('XPS:LI20:DWFA:M6',3)
for i=1:20
pause(1)


var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
pause(2)
var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3))


% --- Executes on button press in minus_20_um.
function minus_20_um_Callback(hObject, eventdata, handles)
% hObject    handle to minus_20_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a-0.02
str2=num2str(a)


if a<0
    set(handles.Status,'String',' Position lower than Low Limit, motion not allowed')
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end
end

% --- Executes on button press in plus_20_um.
function plus_20_um_Callback(hObject, eventdata, handles)
% hObject    handle to plus_20_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.Setpoint_M6,'String')
a=str2num(str)
a=a+0.02
str2=num2str(a)

if a>49
    set(handles.Status,'String',' Position above High Limit, motion not allowed')
    
else
        if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
        end
end

% --- Executes on button press in MOVE.
function MOVE_Callback(hObject, eventdata, handles)
% hObject    handle to MOVE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setvar=get(handles.Setpoint_M6,'String')
a=str2num(setvar)

if a>49 
    set(handles.Status,'String',' Position above High Limit, motion not allowed')
else
    if a<0
            set(handles.Status,'String',' Position below Low Limit, motion not allowed')
    else
    if ((a>19) & (a<22))
        set(handles.Status,'String',' Position in the unstable region 19<x<22. Please chose another setpoint. Motion not allowed')
    else
    
        
lcaPutSmart('XPS:LI20:DWFA:M6',a)
str2=num2str(a)
set(handles.Setpoint_M6,'String',str2)
set(handles.Status,'String','')
for i=1:20
pause(1)

var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20
    end
    end
end



% --- Executes on button press in home_M6.
function home_M6_Callback(hObject, eventdata, handles)
% hObject    handle to home_M6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lcaPutSmart('XPS:LI20:DWFA:M6',0)
set(handles.Setpoint_M6,'String','0')
set(handles.Status,'String','')
for i=1:20
pause(1)


var3=lcaGet('XPS:LI20:DWFA:M6.RBV');
set(handles.Readback_M6,'String',num2str(var3)) ;
end % end for i=1:20



function Status_Callback(hObject, eventdata, handles)
% hObject    handle to Status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Status as text
%        str2double(get(hObject,'String')) returns contents of Status as a double


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


% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
var3=lcaGet('XPS:LI20:DWFA:M6.RBV');



set(handles.Readback_M6,'String',num2str(var3))

