function varargout = PMTVoltage_gui(varargin)
% PMTVOLTAGE_GUI MATLAB code for PMTVoltage_gui.fig
%      PMTVOLTAGE_GUI, by itself, creates a new PMTVOLTAGE_GUI or raises the existing
%      singleton*.
%
%      H = PMTVOLTAGE_GUI returns the handle to a new PMTVOLTAGE_GUI or the handle to
%      the existing singleton*.
%
%      PMTVOLTAGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PMTVOLTAGE_GUI.M with the given input arguments.
%
%      PMTVOLTAGE_GUI('Property','Value',...) creates a new PMTVOLTAGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PMTVoltage_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PMTVoltage_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PMTVoltage_gui

% Last Modified by GUIDE v2.5 14-Feb-2012 14:41:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PMTVoltage_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @PMTVoltage_gui_OutputFcn, ...
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


% --- Executes just before PMTVoltage_gui is made visible.
function PMTVoltage_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PMTVoltage_gui (see VARARGIN)

% Choose default command line output for PMTVoltage_gui
handles.output = hObject;
handles=appInit(hObject,handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PMTVoltage_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PMTVoltage_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function PMTVoltage_gui_CloseRequestFcn(hObject, eventdata, handles)
disp('closing...')
if ~ispc
    util_appClose(hObject);
end
delete(hObject);


function handles=appInit(hObject,handles)

handles.pressurePV={'VGBA:FEE1:240:P';'VGBA:FEE1:360:P'};
handles.PMTPV={'HVCH:FEE1:241';'HVCH:FEE1:242'; ...
    'HVCH:FEE1:361';'HVCH:FEE1:362'};
handles.readPMT=strcat(handles.PMTPV,':VoltageMeasure');
handles.energyPV={'SIOC:SYS0:ML00:AO627'};
handles.pressures=[0.015,0.015; ... %eV<800
    0.02, 0.02;...  %800<eV<1200
    0.025, 0.025;...%1200<eV<1800
    0.05,0.05;...   %1800<eV<2000
    0.6, 0.2;...    %2000<eV<6000
    2.0, 0.6];      %eV>6000
handles.coeffs=cell(4,6);

handles.coeffs(1,:)={... %PMT241
    [-500 0.2767 810 1.10496 0.144];...    %eV<800
    [-500 0.280745 759 1.10496 0.144]; ...  %800<eV<1200
    [-500 0.284328 713 1.10496 0.144];...    %1200<eV<1800
    [-500 0.29588 565 1.10496 0.144];...   %1800<eV<2000
    [-6500 0.085143 892.5 1.10496 0.144];      %2000<eV<6000
    [-6500 0.085143 892.5 1.10496 0.144]}; %eV>6000

handles.coeffs(2,:)={...%PMT242
    [-500 0.2625 792.5 1.10496 0.144];...  %eV<800
    [-500 0.266882 744 1.10496 0.144]; ...   %800<eV<1200
    [-500 0.270802 700 1.10496 0.144];...  %1200<eV<1800
    [-500 0.28353 558 1.10496 0.144];...   %1800<eV<2000
    [-6500 0.078757 862 1.10496 0.144];      %2000<eV<6000
    [-6500 0.078757 862 1.10496 0.144]};   %eV>6000

% handles.coeffs(3,:)={...%PMT361
%     [0 0 700 1 0];...  %eV<800
%     [0 0 700 1 0]; ... %800<eV<1200
%     [0 0 700 1 0];...  %1200<eV<1800
%     [0 0 700 1 0];...  %1800<eV<2000
%     [0 0 900 1 0];     %2000<eV<6000
%     [0 0 1200 1 0]};   %eV>6000
% 
% handles.coeffs(4,:)={...%PMT362
%     [0 0 725 1 0];...  %eV<800
%     [0 0 725 1 0]; ... %800<eV<1200
%     [0 0 725 1 0];...  %1200<eV<1800
%     [0 0 725 1 0];...  %1800<eV<2000
%     [0 0 900 1 0];     %2000<eV<6000
%     [0 0 1200 1 0]};   %eV>6000

handles.coeffs(3,:)={...%PMT361
    [-5000 0.1213 1050 1.10496 0.144];...  %eV<800
    [-5000 0.1213 1050 1.10496 0.144]; ... %800<eV<1200
    [-5000 0.1213 1050 1.10496 0.144];...  %1200<eV<1800
    [-5000 0.1213 1050 1.10496 0.144];...  %1800<eV<2000
    [-5000 0.1213 1050 1.10496 0.144];     %2000<eV<6000
    [-5000 0.07640 869 1.10496 0.144]};   %eV>6000

handles.coeffs(4,:)={...%PMT362
    [-5000 0.1120 1128 1.09666 0.133];...  %eV<800
    [-5000 0.1120 1128 1.09666 0.133]; ... %800<eV<1200
    [-5000 0.1120 1128 1.09666 0.133];...  %1200<eV<1800
    [-5000 0.1120 1128 1.09666 0.133];...  %1800<eV<2000
    [-5000 0.1120 1128 1.09666 0.133];     %2000<eV<6000
    [-5000 0.07940 939 1.09666 0.133]};   %eV>6000

handles.tags.new={'PMT241new_txt' 'PMT242new_txt' 'PMT361new_txt' 'PMT362new_txt'};
handles.tags.old={'PMT241old_txt' 'PMT242old_txt' 'PMT361old_txt' 'PMT362old_txt'};
energy=lcaGet(handles.energyPV);
strEnergy=sprintf('%4.1f',energy);
set(handles.energy_txt,'String',strEnergy);
initVoltage=lcaGet(handles.readPMT);
idx=0;
for tag=handles.tags.old
    idx=idx+1;
    strV=sprintf('%3.0f',initVoltage(idx));
    set(handles.(tag{:}),'String',strV);
end

handles=calculateVoltage(hObject,handles);
guidata(hObject, handles);

function power_txt_Callback(hObject, eventdata, handles)
% hObject    handle to power_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power_txt as text
%        str2double(get(hObject,'String')) returns contents of power_txt as a double
handles=calculateVoltage(hObject,handles);
guidata(hObject, handles);

function energy_txt_Callback(hObject, eventdata, handles)
% hObject    handle to energy_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of energy_txt as text
%        str2double(get(hObject,'String')) returns contents of energy_txt as a double
handles=calculateVoltage(hObject,handles);
guidata(hObject, handles);

function handles=calculateVoltage(hObject,handles)
energy=str2double(get(handles.energy_txt,'String'));
power=str2double(get(handles.power_txt,'String'));
actP=lcaGet(handles.pressurePV)

if energy <800
    p_idx=1;
elseif energy<1200
    p_idx=2;
elseif energy<1800
    p_idx=3;
elseif energy<2500
    p_idx=4;
elseif energy<6100
    p_idx=5; 
else
    p_idx=6; 
end


set(handles.P1e_txt,'String',num2str(handles.pressures(p_idx,1)));
set(handles.P2e_txt,'String',num2str(handles.pressures(p_idx,2)));

set(handles.P1a_txt,'String',num2str(actP(1)));
set(handles.P2a_txt,'String',num2str(actP(2)));

[val,p1match]=min(abs(handles.pressures(:,1)-actP(1)))
[val,p2match]=min(abs(handles.pressures(:,2)-actP(2)))
pmatch=[p1match;p1match;p2match;p2match];

v=zeros(1,4);
for idx=1:4
    coeff=handles.coeffs{idx,pmatch(idx)};
    if energy <407 && idx<3
        v(idx)=(((energy*3.787-596)*coeff(2)+coeff(3))*coeff(4))/(power^coeff(5)); %special low energy expression 3/14/12
    else
        v(idx)=(((energy+coeff(1))*coeff(2)+coeff(3))*coeff(4))/(power^coeff(5));
    end
end
idx=0;
for tag=handles.tags.new
    idx=idx+1;
    strV=sprintf('%3.0f',v(idx));
    set(handles.(tag{:}),'String',strV);
end
guidata(hObject, handles);

% --- Executes on button press in setVoltage_btn.
function setVoltage_btn_Callback(hObject, eventdata, handles)
% hObject    handle to setVoltage_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx=0;
str=['Setting PMT voltages. Energy:' get(handles.energy_txt,'String') ' Power:' get(handles.power_txt,'String')];
disp_log(str);
writePV=strcat(handles.PMTPV,':VoltageSet');
readPV=strcat(handles.PMTPV,':VoltageMeasure');
for tag=handles.tags.new
    idx=idx+1;
    voltage=str2double(get(handles.(tag{:}),'String'));
    lcaPut(writePV{idx},voltage);
    str=[writePV{idx} ':' get(handles.(tag{:}),'String')];
    disp_log(str);
    pause(2.0);
    str=[readPV{idx} ':' num2str(lcaGet(readPV{idx}))];
    disp_log(str);
end
measureSignal(handles);

% --- Executes on button press in restoreVoltage_btn.
function restoreVoltage_btn_Callback(hObject, eventdata, handles)
% hObject    handle to restoreVoltage_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx=0;
str=['Restoring PMT voltages. Energy:' get(handles.energy_txt,'String') ' Power:' get(handles.power_txt,'String')];
disp_log(str);
writePV=strcat(handles.PMTPV,':VoltageSet');
readPV=strcat(handles.PMTPV,':VoltageMeasure');
for tag=handles.tags.old
    idx=idx+1;
    voltage=str2double(get(handles.(tag{:}),'String'));
    lcaPut(writePV{idx},voltage);
    str=[writePV{idx} ':' get(handles.(tag{:}),'String')];
    disp_log(str);
    pause(2.0);
    str=[readPV{idx} ':' num2str(lcaGet(readPV{idx}))];
    disp_log(str);
end
measureSignal(handles);

function measureSignal(handles)
% hObject    handle to restoreVoltage_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PMTList={'DIAG:FEE1:202:241:Data';'DIAG:FEE1:202:242:Data';'DIAG:FEE1:202:361:Data';'DIAG:FEE1:202:362:Data'};
startIdxList={'GDET:FEE1:241:STRT';'GDET:FEE1:242:STRT';'GDET:FEE1:361:STRT';'GDET:FEE1:362:STRT'};
stopIdxList={'GDET:FEE1:241:STOP';'GDET:FEE1:242:STOP';'GDET:FEE1:361:STOP';'GDET:FEE1:362:STOP'};
dataPMT=lcaGet(PMTList);
startIdx=lcaGet(startIdxList);
stopIdx=lcaGet(stopIdxList);
minVal=min(dataPMT(:,startIdx(:):stopIdx(:)),[],2)

function PMT241new_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT241new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT241new_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT241new_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT241new_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT241new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMT242new_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT242new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT242new_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT242new_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT242new_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT242new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMT361new_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT361new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT361new_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT361new_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT361new_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT361new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMT362new_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT362new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT362new_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT362new_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT362new_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT362new_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









% --- Executes during object creation, after setting all properties.
function energy_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energy_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P1e_txt_Callback(hObject, eventdata, handles)
% hObject    handle to P1e_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P1e_txt as text
%        str2double(get(hObject,'String')) returns contents of P1e_txt as a double


% --- Executes during object creation, after setting all properties.
function P1e_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P1e_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P1a_txt_Callback(hObject, eventdata, handles)
% hObject    handle to P1a_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P1a_txt as text
%        str2double(get(hObject,'String')) returns contents of P1a_txt as a double


% --- Executes during object creation, after setting all properties.
function P1a_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P1a_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P2e_txt_Callback(hObject, eventdata, handles)
% hObject    handle to P2e_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P2e_txt as text
%        str2double(get(hObject,'String')) returns contents of P2e_txt as a double


% --- Executes during object creation, after setting all properties.
function P2e_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P2e_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P2a_txt_Callback(hObject, eventdata, handles)
% hObject    handle to P2a_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P2a_txt as text
%        str2double(get(hObject,'String')) returns contents of P2a_txt as a double


% --- Executes during object creation, after setting all properties.
function P2a_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P2a_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function power_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function PMT241old_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT241old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT241old_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT241old_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT241old_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT241old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMT242old_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT242old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT242old_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT242old_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT242old_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT242old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMT361old_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT361old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT361old_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT361old_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT361old_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT361old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PMT362old_txt_Callback(hObject, eventdata, handles)
% hObject    handle to PMT362old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PMT362old_txt as text
%        str2double(get(hObject,'String')) returns contents of PMT362old_txt as a double


% --- Executes during object creation, after setting all properties.
function PMT362old_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMT362old_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
