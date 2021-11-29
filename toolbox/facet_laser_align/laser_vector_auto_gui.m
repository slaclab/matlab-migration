function varargout = laser_vector_auto_gui(varargin)
% LASER_VECTOR_AUTO_GUI MATLAB code for laser_vector_auto_gui.fig
%      LASER_VECTOR_AUTO_GUI, by itself, creates a new LASER_VECTOR_AUTO_GUI or raises the existing
%      singleton*.
%
%      H = LASER_VECTOR_AUTO_GUI returns the handle to a new LASER_VECTOR_AUTO_GUI or the handle to
%      the existing singleton*.
%
%      LASER_VECTOR_AUTO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASER_VECTOR_AUTO_GUI.M with the given input arguments.
%
%      LASER_VECTOR_AUTO_GUI('Property','Value',...) creates a new LASER_VECTOR_AUTO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before laser_vector_auto_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to laser_vector_auto_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help laser_vector_auto_gui

% Last Modified by GUIDE v2.5 23-Nov-2015 14:18:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @laser_vector_auto_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @laser_vector_auto_gui_OutputFcn, ...
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


% --- Executes just before laser_vector_auto_gui is made visible.
function laser_vector_auto_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to laser_vector_auto_gui (see VARARGIN)


% Choose default command line output for laser_vector_auto_gui
handles.output = hObject;

% Initialize the desired position struct.
handles.desired.x1 = 375;
handles.desired.y1 = 334;
handles.desired.x2 = 650;
handles.desired.y2 = 550;

% Initialize the currnet position struct.
handles.current.x1 = 0;
handles.current.y1 = 0;
handles.current.x2 = 0;
handles.current.y2 = 0;

% Initialize the mirror motion struct.
handles.mirrormotion.M1X = 10;
handles.mirrormotion.M1Y = 1;
handles.mirrormotion.M2X = 2;
handles.mirrormotion.M2Y = 3;

% Assign Motors to move.
handles.mirror_motors.M1X = 'MOTR:LI20:MC06:M0:CH1';
handles.mirror_motors.M1Y = 'MOTR:LI20:MC06:M0:CH2';
handles.mirror_motors.M2X = 'MOTR:LI20:MC06:M0:CH3';
handles.mirror_motors.M2Y = 'MOTR:LI20:MC06:M0:CH4';

% Initialize the loop variable to NOT loop.
handles.loop = 0;

% Intialized the calibrations.  It seems safer to start them forming a unit matrix.
% xC11 is the distance moved on screen 1 due to an x move on mirror 1.
% xC12 is the distance moved on screen 1 due to an x move on mirror 2 and
% so on.
handles.calib.xC11 = 140;
handles.calib.xC12 = 175;
handles.calib.xC21 = 195;
handles.calib.xC22 = 215;

handles.calib.yC11 = 80;
handles.calib.yC12 = 195;
handles.calib.yC21 = 135;
handles.calib.yC22 = 150;

% Update the GUI.
initialize_desired_point(handles);
initialize_current_point(handles);
initialize_mirror_motion(handles);
initialize_calibration_matrices(handles);

% save the handles for the images, so they can be redrawn.
h=findobj('Type','axes','Tag','axes1');
handles.image_1_handle = h;

h=findobj('Type','axes','Tag','axes2');
handles.image_2_handle = h;

% Define the cameras to use.
handles.camera1 = 'PROF:LI20:B103';
handles.camera2 = 'PROF:LI20:12';


% Initialize the camera list and set the default values.
S_camera = {'Laser Room Near','Laser Room Far','B4','B6','Ax_Img_1','Ax_Img_2'};
set(handles.camera_1_selection,'String',S_camera);
set(handles.camera_1_selection,'Value',1);
set(handles.camera_2_selection,'String',S_camera);
set(handles.camera_2_selection,'Value',2);


% For the peak finders
% 1 = simple finder, it just finds the max, good for well defind functions.
% 2 = Lroom_Near_Finder, this guy finds the center of flat beams pretty
% well.
% 'finder' here should be replaced with 'fit_type' at some point.  Then the
% various funciton have to be corrected.
handles.camera_1_finder = 2; 
handles.camera_2_finder = 1;

% Initalize the fit_type pop up lists and set the defult values to match
% the values set above.
S_fit_type = {'Max From Projection','Laser Room Near'};
set(handles.camera_1_fit_type,'String',S_fit_type);
set(handles.camera_1_fit_type,'Value',2);
set(handles.camera_2_fit_type,'String',S_fit_type);
set(handles.camera_2_fit_type,'Value',1);


% Define a "reasonable" step size for the calibration.
handles.calibration.step_size = 0.2;
set(handles.calibration_step_size,'String',num2str(handles.calibration.step_size));

% This section does the initial population of the GUI.
handles = redraw_images(handles);

handles = find_centers(handles);
draw_current_position(handles);
draw_desired_position(handles);

find_mirror_solution(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes laser_vector_auto_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = laser_vector_auto_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2



function desired_x1_Callback(hObject, eventdata, handles)
% hObject    handle to desired_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of desired_x1 as text
%        str2double(get(hObject,'String')) returns contents of desired_x1 as a double

handles.desired.x1 = str2double(get(hObject,'String'));
set(handles.desired_x1,'String',num2str(handles.desired.x1))
redraw_images(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function desired_x1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to desired_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function desired_y1_Callback(hObject, eventdata, handles)
% hObject    handle to desired_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of desired_y1 as text
%        str2double(get(hObject,'String')) returns contents of desired_y1 as a double

handles.desired.y1 = str2double(get(hObject,'String'));
set(handles.desired_y1,'String',num2str(handles.desired.y1))
redraw_images(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function desired_y1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to desired_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function desired_x2_Callback(hObject, eventdata, handles)
% hObject    handle to desired_x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of desired_x2 as text
%        str2double(get(hObject,'String')) returns contents of desired_x2 as a double

handles.desired.x2 = str2double(get(hObject,'String'));
set(handles.desired_x2,'String',num2str(handles.desired.x2))
redraw_images(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function desired_x2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to desired_x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function desired_y2_Callback(hObject, eventdata, handles)
% hObject    handle to desired_y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of desired_y2 as text
%        str2double(get(hObject,'String')) returns contents of desired_y2 as a double

handles.desired.y2 = str2double(get(hObject,'String'));
set(handles.desired_y2,'String',num2str(handles.desired.y2))
redraw_images(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function desired_y2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to desired_y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function current_x1_Callback(hObject, eventdata, handles)
% hObject    handle to current_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_x1 as text
%        str2double(get(hObject,'String')) returns contents of current_x1 as a double


% --- Executes during object creation, after setting all properties.
function current_x1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_y1_Callback(hObject, eventdata, handles)
% hObject    handle to current_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_y1 as text
%        str2double(get(hObject,'String')) returns contents of current_y1 as a double


% --- Executes during object creation, after setting all properties.
function current_y1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_x2_Callback(hObject, eventdata, handles)
% hObject    handle to current_x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_x2 as text
%        str2double(get(hObject,'String')) returns contents of current_x2 as a double


% --- Executes during object creation, after setting all properties.
function current_x2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_y2_Callback(hObject, eventdata, handles)
% hObject    handle to current_y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_y2 as text
%        str2double(get(hObject,'String')) returns contents of current_y2 as a double


% --- Executes during object creation, after setting all properties.
function current_y2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function xC11_Callback(hObject, eventdata, handles)
% hObject    handle to xC11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xC11 as text
%        str2double(get(hObject,'String')) returns contents of xC11 as a double
handles.calib.xC11 = str2double(get(hObject,'String'));
set(handles.xC11,'String',num2str(handles.calib.xC11));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xC11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xC11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xC12_Callback(hObject, eventdata, handles)
% hObject    handle to xC12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xC12 as text
%        str2double(get(hObject,'String')) returns contents of xC12 as a double
handles.calib.xC12 = str2double(get(hObject,'String'));
set(handles.xC12,'String',num2str(handles.calib.xC12));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xC12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xC12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xC21_Callback(hObject, eventdata, handles)
% hObject    handle to xC21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xC21 as text
%        str2double(get(hObject,'String')) returns contents of xC21 as a double

handles.calib.xC21 = str2double(get(hObject,'String'));
set(handles.xC21,'String',num2str(handles.calib.xC21));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xC21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xC21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xC22_Callback(hObject, eventdata, handles)
% hObject    handle to xC22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xC22 as text
%        str2double(get(hObject,'String')) returns contents of xC22 as a double
handles.calib.xC22 = str2double(get(hObject,'String'));
set(handles.xC22,'String',num2str(handles.calib.xC22));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xC22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xC22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function yC11_Callback(hObject, eventdata, handles)
% hObject    handle to yC11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yC11 as text
%        str2double(get(hObject,'String')) returns contents of yC11 as a double
handles.calib.yC11 = str2double(get(hObject,'String'));
set(handles.yC11,'String',num2str(handles.calib.yC11));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yC11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yC11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yC12_Callback(hObject, eventdata, handles)
% hObject    handle to yC12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yC12 as text
%        str2double(get(hObject,'String')) returns contents of yC12 as a double
handles.calib.yC12 = str2double(get(hObject,'String'));
set(handles.yC12,'String',num2str(handles.calib.yC12));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yC12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yC12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yC21_Callback(hObject, eventdata, handles)
% hObject    handle to yC21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yC21 as text
%        str2double(get(hObject,'String')) returns contents of yC21 as a double
handles.calib.yC21 = str2double(get(hObject,'String'));
set(handles.yC21,'String',num2str(handles.calib.yC21));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yC21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yC21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yC22_Callback(hObject, eventdata, handles)
% hObject    handle to yC22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yC22 as text
%        str2double(get(hObject,'String')) returns contents of yC22 as a double

handles.calib.yC22 = str2double(get(hObject,'String'));
set(handles.yC22,'String',num2str(handles.calib.yC22));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yC22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yC22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function M1X_Callback(hObject, eventdata, handles)
% hObject    handle to M1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M1X as text
%        str2double(get(hObject,'String')) returns contents of M1X as a double

handles.mirrormotion.M1X = str2double(get(hObject,'String'));
set(handles.M1X,'String',num2str(handles.mirrormotion.M1X));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function M1X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function M1Y_Callback(hObject, eventdata, handles)
% hObject    handle to M1Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M1Y as text
%        str2double(get(hObject,'String')) returns contents of M1Y as a double

handles.mirrormotion.M1Y = str2double(get(hObject,'String'));
set(handles.M1Y,'String',num2str(handles.mirrormotion.M1Y));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function M1Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M1Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function M2X_Callback(hObject, eventdata, handles)
% hObject    handle to M2X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M2X as text
%        str2double(get(hObject,'String')) returns contents of M2X as a double

handles.mirrormotion.M2X = str2double(get(hObject,'String'));
set(handles.M2X,'String',num2str(handles.mirrormotion.M2X));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function M2X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M2X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function M2Y_Callback(hObject, eventdata, handles)
% hObject    handle to M2Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M2Y as text
%        str2double(get(hObject,'String')) returns contents of M2Y as a double

handles.mirrormotion.M2Y = str2double(get(hObject,'String'));
set(handles.M2Y,'String',num2str(handles.mirrormotion.M2Y));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function M2Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M2Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refresh_cameras.
function refresh_cameras_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_cameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = redraw_images(handles);
guidata(hObject, handles)


% --- Executes on button press in keyboard_button.
function keyboard_button_Callback(hObject, eventdata, handles)
% hObject    handle to keyboard_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard;


% --- Executes on button press in find_mirror_solution.
function find_mirror_solution_Callback(hObject, eventdata, handles)
% hObject    handle to find_mirror_solution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = find_mirror_solution(handles);
initialize_mirror_motion(handles)
guidata(hObject, handles);



% --- Executes on button press in perform_motion.
function perform_motion_Callback(hObject, eventdata, handles)
% hObject    handle to perform_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
perform_mirror_match(handles)


% --- Executes on button press in perform_calibration.
function perform_calibration_Callback(hObject, eventdata, handles)
% hObject    handle to perform_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = C_matrix_builder(handles);
initialize_calibration_matrices(handles);
guidata(hObject, handles)



function calibration_step_size_Callback(hObject, eventdata, handles)
% hObject    handle to calibration_step_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calibration_step_size as text
%        str2double(get(hObject,'String')) returns contents of calibration_step_size as a double
handles.calibration.step_size = str2double(get(hObject,'String'));
set(handles.calibration_step_size,'String',num2str(handles.calibration.step_size));
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function calibration_step_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calibration_step_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in one_step.
function one_step_Callback(hObject, eventdata, handles)
% hObject    handle to one_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = perform_one_alignment_pass(handles);
guidata(hObject, handles);


% --- Executes on selection change in camera_1_selection.
function camera_1_selection_Callback(hObject, eventdata, handles)
% hObject    handle to camera_1_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns camera_1_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from camera_1_selection
contents = cellstr(get(hObject,'String'));
temp = contents{get(hObject,'Value')};
handles.camera1 = pop_up_camera_selection_decoder(temp);
[motor_1_temp , motor_2_temp] = pop_up_motor_selection_decoder(temp);
handles.mirror_motors.M1X = motor_1_temp;
handles.mirror_motors.M1Y = motor_2_temp;
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function camera_1_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_1_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in camera_2_selection.
function camera_2_selection_Callback(hObject, eventdata, handles)
% hObject    handle to camera_2_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns camera_2_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from camera_2_selection
contents = cellstr(get(hObject,'String'));
temp = contents{get(hObject,'Value')};
handles.camera2 = pop_up_camera_selection_decoder(temp);
[motor_1_temp , motor_2_temp] = pop_up_motor_selection_decoder(temp);
handles.mirror_motors.M2X = motor_1_temp;
handles.mirror_motors.M2Y = motor_2_temp;
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function camera_2_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_2_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in camera_1_fit_type.
function camera_1_fit_type_Callback(hObject, eventdata, handles)
% hObject    handle to camera_1_fit_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns camera_1_fit_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from camera_1_fit_type
contents = cellstr(get(hObject,'String'));
temp = contents{get(hObject,'Value')};
handles.camera_1_finder = pop_up_fit_type_selection_decoder(temp);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function camera_1_fit_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_1_fit_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in camera_2_fit_type.
function camera_2_fit_type_Callback(hObject, eventdata, handles)
% hObject    handle to camera_2_fit_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns camera_2_fit_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from camera_2_fit_type
contents = cellstr(get(hObject,'String'));
temp = contents{get(hObject,'Value')};
handles.camera_2_finder = pop_up_fit_type_selection_decoder(temp);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function camera_2_fit_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_2_fit_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in one_hz_auto_update.
function one_hz_auto_update_Callback(hObject, eventdata, handles)
% hObject    handle to one_hz_auto_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of one_hz_auto_update

motion_on = 0;

for i = 1 : 3600000
   button_down = get(hObject,'Value');
   if button_down == 0;
       break;
   end
   handles = redraw_images(handles);
   pause(1.0)
   motion_on = motion_on + 1;
   
   if (mod(motion_on,30)) == 0
      perform_one_alignment_pass(handles) 
   end
end









