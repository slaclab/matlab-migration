function varargout = master_lascfg(varargin)
% MASTER_LASCFG M-file for master_lascfg.fig
%  Author: Christopher Melton
%
%  This code is for the config expert control gui which is linked to the
%  LCLS injector laser diagnostic tool which will show/load configs
%  depending up on the laser type in use.
%  
%  Created: 17 APR 2010 
%  
%  Updates: 17 APR 2010 20:00 Established gui layout, password protect
%                18 APR 2010 18:00 Adding initialization, and user load/save
%                
%%%%%%%%%%%%%%%%%%%%%%%%
%
%      ORIGINAL Matlab comments:
%      MASTER_LASCFG, by itself, creates a new MASTER_LASCFG or raises the existing
%      singleton*.
%
%      H = MASTER_LASCFG returns the handle to a new MASTER_LASCFG or the handle to
%      the existing singleton*.
%
%      MASTER_LASCFG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASTER_LASCFG.M with the given input arguments.
%
%      MASTER_LASCFG('Property','Value',...) creates a new MASTER_LASCFG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before master_lascfg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to master_lascfg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help master_lascfg

% Last Modified by GUIDE v2.5 17-Apr-2010 21:25:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @master_lascfg_OpeningFcn, ...
                   'gui_OutputFcn',  @master_lascfg_OutputFcn, ...
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


% --- Executes just before master_lascfg is made visible.
function master_lascfg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to master_lascfg (see VARARGIN)

% Choose default command line output for master_lascfg
handles.output = hObject;

scrn = get(0,'ScreenSize'); 

if scrn(3) >= 4000  % Determine if running on large display or not
    set(hObject,'Position',[620 50 125 53.4]); % lg OPI: middle-right
else
    set(hObject,'Position',[scrn(3)/4 scrn(3)/4 125 53.4]); % sm scrn lower-left
end

set(handles.buttonCoherent,'Visible','off');
set(handles.buttonThales,'Visible','off');
set(handles.TenterMOSC,'Visible','off');
set(handles.TenterTRIP,'Visible','off');
set(handles.TenterPM1,'Visible','off');
set(handles.TenterPM2,'Visible','off');
set(handles.TenterPM3,'Visible','off');
set(handles.TenterUVWP,'Visible','off');
set(handles.TenterIRIS,'Visible','off');
set(handles.TenterVCCP,'Visible','off');
set(handles.TenterFBKP,'Visible','off');
set(handles.TenterPMH3,'Visible','off');
set(handles.TenterPMH2,'Visible','off');
set(handles.TenterPMH1,'Visible','off');
set(handles.TenterLHWP,'Visible','off');

set(handles.CenterMOSC,'Visible','off');
set(handles.CenterTRIP,'Visible','off');
set(handles.CenterPM1,'Visible','off');
set(handles.CenterPM2,'Visible','off');
set(handles.CenterPM3,'Visible','off');
set(handles.CenterUVWP,'Visible','off');
set(handles.CenterIRIS,'Visible','off');
set(handles.CenterVCCP,'Visible','off');
set(handles.CenterFBKP,'Visible','off');
set(handles.CenterPMH3,'Visible','off');
set(handles.CenterPMH2,'Visible','off');
set(handles.CenterPMH1,'Visible','off');
set(handles.CenterLHWP,'Visible','off');

fprintf('\nMaster Laser Configuration Interface Launched\n');
warning('off','MATLAB:dispatcher:InexactMatch');
warning off verbose
echo on 

initload(handles);

% UIWAIT makes laserdoc_v1 wait for user response (see UIRESUME)
% uiwait(handles.laserdoc);

% Update handles structure
guidata(hObject, handles);
end

% UIWAIT makes master_lascfg wait for user response (see UIRESUME)
% uiwait(handles.LASRCFGMaster);


% --- Outputs from this function are returned to the command line.
function varargout = master_lascfg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


 
%%%%%%%%   Control Buttons  %%%%%%%%%%

% --- Executes on button press in buttonThales.
function buttonThales_Callback(hObject, eventdata, handles)
% hObject    handle to buttonThales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% thal_cfg = {
%     
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% };
% 
% 
% 
% save('/u1/lcls/matlab/config/laserdoc_cfg_Thales.mat', );

end


% --- Executes on button press in buttonCoherent.
function buttonCoherent_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCoherent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% cohr_cfg = {
%     
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% };
% 
% 
% 
% save('/u1/lcls/matlab/config/laserdoc_cfg_Coherent.mat', );

end


% --- Executes on button press in buttonShowvals.
function buttonShowvals_Callback(hObject, eventdata, handles)
% hObject    handle to buttonShowvals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

options.Resize='off';
options.WindowStyle='modal';
dlghedr = '*** PASSWORD REQUIRED ***';
def={'',''};
prompt = {'Name:', 'Password:'};
loggins = inputdlg(prompt,dlghedr,1,def,options);
passname = char(loggins(2));

if strcmp(passname,'weyland')
    void = warndlg(sprintf('\nPassword accepted for user:\nYou have unlocked expert config load function\nBE CAREFUL!\n'),'modal');
    pause(3);
    fprintf('\nUser name and password accepted.\n');
    unlock(handles);
    return;    
else
    void = errordlg(sprintf('\nPassword incorrect for user. You are unauthorized to set and load a new config.'),'modal');
    pause(3);
    fprintf('\nIncorrect user name and password for access to loading a config\n');
    return;
end

end




%%%%%%%%  Function Calls  %%%%%%%%%%%
%%%%          (and create functions)                %%%%


% Thales Callbacks

function TenterMOSC_Callback(hObject, eventdata, handles)
% hObject    handle to TenterMOSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterMOSC as text
%        str2double(get(hObject,'String')) returns contents of TenterMOSC as a double
end

% --- Executes during object creation, after setting all properties.
function TenterMOSC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterMOSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterTRIP_Callback(hObject, eventdata, handles)
% hObject    handle to TenterTRIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterTRIP as text
%        str2double(get(hObject,'String')) returns contents of TenterTRIP as a double
end

% --- Executes during object creation, after setting all properties.
function TenterTRIP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterTRIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterPM1_Callback(hObject, eventdata, handles)
% hObject    handle to TenterPM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterPM1 as text
%        str2double(get(hObject,'String')) returns contents of TenterPM1 as a double
end

% --- Executes during object creation, after setting all properties.
function TenterPM1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterPM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterPM2_Callback(hObject, eventdata, handles)
% hObject    handle to TenterPM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterPM2 as text
%        str2double(get(hObject,'String')) returns contents of TenterPM2 as a double
end

% --- Executes during object creation, after setting all properties.
function TenterPM2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterPM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterPM3_Callback(hObject, eventdata, handles)
% hObject    handle to TenterPM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterPM3 as text
%        str2double(get(hObject,'String')) returns contents of TenterPM3 as a double
end

% --- Executes during object creation, after setting all properties.
function TenterPM3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterPM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterUVWP_Callback(hObject, eventdata, handles)
% hObject    handle to TenterUVWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterUVWP as text
%        str2double(get(hObject,'String')) returns contents of TenterUVWP as a double
end

% --- Executes during object creation, after setting all properties.
function TenterUVWP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterUVWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterIRIS_Callback(hObject, eventdata, handles)
% hObject    handle to TenterIRIS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterIRIS as text
%        str2double(get(hObject,'String')) returns contents of TenterIRIS as a double
end

% --- Executes during object creation, after setting all properties.
function TenterIRIS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterIRIS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterVCCP_Callback(hObject, eventdata, handles)
% hObject    handle to TenterVCCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterVCCP as text
%        str2double(get(hObject,'String')) returns contents of TenterVCCP as a double
end

% --- Executes during object creation, after setting all properties.
function TenterVCCP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterVCCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterFBKP_Callback(hObject, eventdata, handles)
% hObject    handle to TenterFBKP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterFBKP as text
%        str2double(get(hObject,'String')) returns contents of TenterFBKP as a double
end

% --- Executes during object creation, after setting all properties.
function TenterFBKP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterFBKP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterPMH3_Callback(hObject, eventdata, handles)
% hObject    handle to TenterPMH3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterPMH3 as text
%        str2double(get(hObject,'String')) returns contents of TenterPMH3 as a double
end

% --- Executes during object creation, after setting all properties.
function TenterPMH3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterPMH3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterPMH2_Callback(hObject, eventdata, handles)
% hObject    handle to TenterPMH2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterPMH2 as text
%        str2double(get(hObject,'String')) returns contents of TenterPMH2 as a double
end

% --- Executes during object creation, after setting all properties.
function TenterPMH2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterPMH2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterPMH1_Callback(hObject, eventdata, handles)
% hObject    handle to TenterPMH1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterPMH1 as text
%        str2double(get(hObject,'String')) returns contents of TenterPMH1 as a double
end

% --- Executes during object creation, after setting all properties.
function TenterPMH1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterPMH1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TenterLHWP_Callback(hObject, eventdata, handles)
% hObject    handle to TenterLHWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TenterLHWP as text
%        str2double(get(hObject,'String')) returns contents of TenterLHWP as a double
end

% --- Executes during object creation, after setting all properties.
function TenterLHWP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenterLHWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




% Coherent Callbacks


function CenterMOSC_Callback(hObject, eventdata, handles)
% hObject    handle to CenterMOSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterMOSC as text
%        str2double(get(hObject,'String')) returns contents of CenterMOSC as a double
end

% --- Executes during object creation, after setting all properties.
function CenterMOSC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterMOSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterTRIP_Callback(hObject, eventdata, handles)
% hObject    handle to CenterTRIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterTRIP as text
%        str2double(get(hObject,'String')) returns contents of CenterTRIP as a double
end

% --- Executes during object creation, after setting all properties.
function CenterTRIP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterTRIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterPM1_Callback(hObject, eventdata, handles)
% hObject    handle to CenterPM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterPM1 as text
%        str2double(get(hObject,'String')) returns contents of CenterPM1 as a double
end

% --- Executes during object creation, after setting all properties.
function CenterPM1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterPM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterPM2_Callback(hObject, eventdata, handles)
% hObject    handle to CenterPM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterPM2 as text
%        str2double(get(hObject,'String')) returns contents of CenterPM2 as a double
end

% --- Executes during object creation, after setting all properties.
function CenterPM2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterPM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function CenterPM3_Callback(hObject, eventdata, handles)
% hObject    handle to CenterPM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterPM3 as text
%        str2double(get(hObject,'String')) returns contents of CenterPM3 as a double
end

% --- Executes during object creation, after setting all properties.
function CenterPM3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterPM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterUVWP_Callback(hObject, eventdata, handles)
% hObject    handle to CenterUVWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterUVWP as text
%        str2double(get(hObject,'String')) returns contents of CenterUVWP as a double
end

% --- Executes during object creation, after setting all properties.
function CenterUVWP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterUVWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterIRIS_Callback(hObject, eventdata, handles)
% hObject    handle to CenterIRIS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterIRIS as text
%        str2double(get(hObject,'String')) returns contents of CenterIRIS as a double
end

% --- Executes during object creation, after setting all properties.
function CenterIRIS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterIRIS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterVCCP_Callback(hObject, eventdata, handles)
% hObject    handle to CenterVCCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterVCCP as text
%        str2double(get(hObject,'String')) returns contents of CenterVCCP as a double
end

% --- Executes during object creation, after setting all properties.
function CenterVCCP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterVCCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterFBKP_Callback(hObject, eventdata, handles)
% hObject    handle to CenterFBKP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterFBKP as text
%        str2double(get(hObject,'String')) returns contents of CenterFBKP as a double
end

% --- Executes during object creation, after setting all properties.
function CenterFBKP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterFBKP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterPMH3_Callback(hObject, eventdata, handles)
% hObject    handle to CenterPMH3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterPMH3 as text
%        str2double(get(hObject,'String')) returns contents of CenterPMH3 as a double
end

% --- Executes during object creation, after setting all properties.
function CenterPMH3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterPMH3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterPMH2_Callback(hObject, eventdata, handles)
% hObject    handle to CenterPMH2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterPMH2 as text
%        str2double(get(hObject,'String')) returns contents of CenterPMH2 as a double
end

% --- Executes during object creation, after setting all properties.
function CenterPMH2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterPMH2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterPMH1_Callback(hObject, eventdata, handles)
% hObject    handle to CenterPMH1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterPMH1 as text
%        str2double(get(hObject,'String')) returns contents of CenterPMH1 as a double
end

% --- Executes during object creation, after setting all properties.
function CenterPMH1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterPMH1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function CenterLHWP_Callback(hObject, eventdata, handles)
% hObject    handle to CenterLHWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterLHWP as text
%        str2double(get(hObject,'String')) returns contents of CenterLHWP as a double
end

% --- Executes during object creation, after setting all properties.
function CenterLHWP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterLHWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



%  Functions

function void = unlock(handles)

set(handles.buttonCoherent,'Visible','on');
set(handles.buttonThales,'Visible','on');
set(handles.TenterMOSC,'Visible','on');
set(handles.TenterTRIP,'Visible','on');
set(handles.TenterPM1,'Visible','on');
set(handles.TenterPM2,'Visible','on');
set(handles.TenterPM3,'Visible','on');
set(handles.TenterUVWP,'Visible','on');
set(handles.TenterIRIS,'Visible','on');
set(handles.TenterVCCP,'Visible','on');
set(handles.TenterFBKP,'Visible','on');
set(handles.TenterPMH3,'Visible','on');
set(handles.TenterPMH2,'Visible','on');
set(handles.TenterPMH1,'Visible','on');
set(handles.TenterLHWP,'Visible','on');

set(handles.CenterMOSC,'Visible','on');
set(handles.CenterTRIP,'Visible','on');
set(handles.CenterPM1,'Visible','on');
set(handles.CenterPM2,'Visible','on');
set(handles.CenterPM3,'Visible','on');
set(handles.CenterUVWP,'Visible','on');
set(handles.CenterIRIS,'Visible','on');
set(handles.CenterVCCP,'Visible','on');
set(handles.CenterFBKP,'Visible','on');
set(handles.CenterPMH3,'Visible','on');
set(handles.CenterPMH2,'Visible','on');
set(handles.CenterPMH1,'Visible','on');
set(handles.CenterLHWP,'Visible','on');

pause(0.5);

set(handles.buttonCoherent,'Visible','on');
set(handles.buttonThales,'Visible','on');

pause(0.5);

set(handles.buttonShowvals,'Visible','off');

return;

end

function void = initload(handles) % Load nominal running setpoints for laser

cohr = checkmode(handles);

thal_file = exist('/u1/lcls/matlab/config/laserdoc_cfg_Thales.mat','file');
cohr_file = exist('/u1/lcls/matlab/config/laserdoc_cfg_Coherent.mat','file');

if ~cohr
switch thal_file  % using a SWITCH for more complex file handling at a later date
    case 0
        fprintf('\nCannot find the Thales config in a file, so I will load the default config values into the static display.\n');
        set(handles.TvalMOSC,'String','520');
        set(handles.TvalTRIP,'String','140');
        set(handles.TvalPM1,'String','2.3');
        set(handles.TvalPM2,'String','1.2');
        set(handles.TvalPM3,'String','0.1');
        set(handles.TvalUVWP,'String','88');
        set(handles.TvalIRIS,'String','1.2');
        set(handles.TvalVCCP,'String','55');
        set(handles.TvalFBKP,'String','60');
        set(handles.TvalPMH3,'String','10');
        set(handles.TvalPMH2,'String','4.88');
        set(handles.TvalPMH1,'String','0.77');
        set(handles.TvalLHWP,'String','30');
    otherwise
        fprintf('\nIt appears that the Thales laser config file exists. I will load its config file into the static display..\n');
end
switch cohr_file  % using a SWITCH for more complex file handling at a later date
    case 0
        fprintf('\nCannot find the Coherent config in a file, so I will load the default config values into the static display.\n');
        set(handles.CvalMOSC,'String','520');
        set(handles.CvalTRIP,'String','140');
        set(handles.CvalPM1,'String','0.3');
        set(handles.CvalPM2,'String','0.15');
        set(handles.CvalPM3,'String','0.05');
        set(handles.CvalUVWP,'String','88');
        set(handles.CvalIRIS,'String','1.2');
        set(handles.CvalVCCP,'String','55');
        set(handles.CvalFBKP,'String','60');
        set(handles.CvalPMH3,'String','10');
        set(handles.CvalPMH2,'String','4.88');
        set(handles.CvalPMH1,'String','0.77');
        set(handles.CvalLHWP,'String','30');        
    otherwise
        fprintf('\nIt appears that the Coherent laser config file exists. I will load its config file into the static display.\n');    
end
end


if cohr
switch thal_file  % using a SWITCH for more complex file handling at a later date
    case 0
        fprintf('\nCannot find the Thales config in a file, so I will load the default config values into the static display.\n');
        set(handles.TvalMOSC,'String','520');
        set(handles.TvalTRIP,'String','140');
        set(handles.TvalPM1,'String','2.3');
        set(handles.TvalPM2,'String','1.2');
        set(handles.TvalPM3,'String','0.1');
        set(handles.TvalUVWP,'String','88');
        set(handles.TvalIRIS,'String','1.2');
        set(handles.TvalVCCP,'String','55');
        set(handles.TvalFBKP,'String','60');
        set(handles.TvalPMH3,'String','10');
        set(handles.TvalPMH2,'String','4.88');
        set(handles.TvalPMH1,'String','0.77');
        set(handles.TvalLHWP,'String','30');
    otherwise
        fprintf('\nIt appears that the Thales laser config file exists. I will load its config file into the static display..\n');
end
switch cohr_file  % using a SWITCH for more complex file handling at a later date
    case 0
        fprintf('\nCannot find the Coherent config in a file, so I will load the default config values into the static display.\n');
        set(handles.CvalMOSC,'String','520');
        set(handles.CvalTRIP,'String','140');
        set(handles.CvalPM1,'String','0.3');
        set(handles.CvalPM2,'String','0.15');
        set(handles.CvalPM3,'String','0.05');
        set(handles.CvalUVWP,'String','88');
        set(handles.CvalIRIS,'String','1.2');
        set(handles.CvalVCCP,'String','55');
        set(handles.CvalFBKP,'String','60');
        set(handles.CvalPMH3,'String','10');
        set(handles.CvalPMH2,'String','4.88');
        set(handles.CvalPMH1,'String','0.77');
        set(handles.CvalLHWP,'String','30');        
    otherwise
        fprintf('\nIt appears that the Coherent laser config file exists. I will load its config file into the static display.\n');    
end    
end


return;

end

function [cohr] = checkmode(handles)

%%%%%%%%%%%%%%%%
%
% Code for checking laser type ("mode") in use.
% The convention for reference is whether or not the 
% Coherent (new) laser is enabled. 
% This is my personal choice. - C.Melton
%
%%%%%%%%%%%%%%%%

try % In case the VME crate is down
vbuf = lcaGet('LASR:LR20:1:MODE',0,'float');  %dummy variable to hold value
switch vbuf
    case 0 % if laser = Thales, then not using Coherent laser
        cohr = 0;

    case 1 % if laser ~= Thales, then using Coherent laser
        cohr = 1;

    otherwise % if laser mode PV not reporting 0 or 1, then set fault flag '2'  (this should never happen)
        cohr = 2;
        fprintf('\nDrive laser mode PV is not reporting a boolean value. Has the PV changed.\n');

end
catch % if the PV cannot be read at all
    fprintf('\nDrive laser mode PV is not reporting at all. Cannot determine drive laser in use at scan time\n');
    cohr = 3; % Set "not reporting" flag as '3' - this might sometimes happen, esp. if VME crate is down or IOC is sick
end

end











