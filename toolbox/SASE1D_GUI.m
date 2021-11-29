function varargout = SASE1D_GUI(varargin)
% SASE1D_GUI M-file for SASE1D_GUI.fig
%      SASE1D_GUI, by itself, creates a new SASE1D_GUI or raises the existing
%      singleton*.
%
%      H = SASE1D_GUI returns the handle to a new SASE1D_GUI or the handle to
%      the existing singleton*.
%
%      SASE1D_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SASE1D_GUI.M with the given input arguments.
%
%      SASE1D_GUI('Property','Value',...) creates a new SASE1D_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SASE1D_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SASE1D_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help SASE1D_GUI

% Last Modified by GUIDE v2.5 05-Dec-2007 10:14:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SASE1D_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SASE1D_GUI_OutputFcn, ...
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


% --- Executes just before SASE1D_GUI is made visible.
function SASE1D_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.inp_struc.P0			= str2double(get(handles.P0,'String'));
handles.inp_struc.iopt			= get(handles.OPT,'Value') + 3;
handles.inp_struc.s_steps		= str2num(get(handles.SSTEPS,'String'));
handles.inp_struc.z_steps		= str2num(get(handles.ZSTEPS,'String'));
handles.inp_struc.npart			= str2num(get(handles.NPART,'String'));
handles.inp_struc.dEdz			= str2double(get(handles.ELOSS,'String'));
handles.inp_struc.radWavelength	= str2double(get(handles.LAMR,'String'));
handles.inp_struc.unduL			= str2double(get(handles.LENGTH,'String'));
handles.inp_struc.unduK			= str2double(get(handles.K,'String'));
handles.inp_struc.unduPeriod	= 1E-2*str2double(get(handles.PERIOD,'String'));
handles.inp_struc.beta			= str2double(get(handles.BETA,'String'));
handles.inp_struc.currentMax	= 1E3*str2double(get(handles.IPEAK,'String'));
handles.inp_struc.emitN			= 1E-6*str2double(get(handles.EMITN,'String'));
handles.inp_struc.eSpread		= 1E-2*str2double(get(handles.ESPREAD,'String'));
handles.inp_struc.energy		= 1E3*str2double(get(handles.ENERGY,'String'));
handles.inp_struc.constseed     = get(handles.CONSTSEED,'Value');
handles.axis = get(handles.AXISMAX,'Value');
handles.z = 0:1:handles.inp_struc.unduL;
set(handles.SLIDER1,'Max',handles.inp_struc.unduL);
set(handles.SLIDER1,'Min',0);
set(handles.SLIDER1,'SliderStep',[1/handles.inp_struc.z_steps 0.1]);
set(handles.SLIDER1,'Value',handles.inp_struc.unduL);
set(handles.CURVAL,'String',num2str(handles.inp_struc.unduL));
set(handles.ZMIN,'String','0');
set(handles.ZMAX,'String',num2str(handles.inp_struc.unduL));
handles.zplot = handles.inp_struc.unduL;
handles.runok = 0;
handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SASE1D_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function ENERGY_Callback(hObject, eventdata, handles)
handles.inp_struc.energy = 1E3*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.energy)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ESPREAD_Callback(hObject, eventdata, handles)
handles.inp_struc.eSpread = 1E-2*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.eSpread)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ESPREAD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMITN_Callback(hObject, eventdata, handles)
handles.inp_struc.emitN = 1E-6*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.emitN)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EMITN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function IPEAK_Callback(hObject, eventdata, handles)
handles.inp_struc.currentMax = 1E3*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.currentMax)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function IPEAK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BETA_Callback(hObject, eventdata, handles)
handles.inp_struc.beta = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.beta)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BETA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PERIOD_Callback(hObject, eventdata, handles)
handles.inp_struc.unduPeriod = 1E-2*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.unduPeriod)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PERIOD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function K_Callback(hObject, eventdata, handles)
handles.inp_struc.unduK = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.unduK)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function K_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LENGTH_Callback(hObject, eventdata, handles)
handles.inp_struc.unduL = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.unduL)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
set(handles.ZMAX,'String',num2str(handles.inp_struc.unduL));
set(handles.SLIDER1,'SliderStep',[1/handles.inp_struc.z_steps 0.1]);
set(handles.CURVAL,'String',num2str(handles.inp_struc.unduL));
set(handles.SLIDER1,'Value',handles.inp_struc.unduL);
set(handles.SLIDER1,'Max',handles.inp_struc.unduL);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function LENGTH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LAMR_Callback(hObject, eventdata, handles)
handles.inp_struc.radWavelength = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.radWavelength)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function LAMR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ELOSS_Callback(hObject, eventdata, handles)
handles.inp_struc.dEdz = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.dEdz)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ELOSS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NPART_Callback(hObject, eventdata, handles)
handles.inp_struc.npart = str2num(get(hObject,'String'));
if isnan(handles.inp_struc.npart)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NPART_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ZSTEPS_Callback(hObject, eventdata, handles)
handles.inp_struc.z_steps = str2num(get(hObject,'String'));
if isnan(handles.inp_struc.z_steps)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ZSTEPS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SSTEPS_Callback(hObject, eventdata, handles)
handles.inp_struc.s_steps = str2num(get(hObject,'String'));
if isnan(handles.inp_struc.s_steps)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SSTEPS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OPT.
function OPT_Callback(hObject, eventdata, handles)
handles.inp_struc.iopt = get(hObject,'Value') + 3;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function OPT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RUN.
function RUN_Callback(hObject, eventdata, handles)
%x = handles.inp_struc
[z,power_z,s,power_s,rho,gainLength,resWavelength] = sase1d(handles.inp_struc);
handles.runok = 1;
handles.z = z;
handles.power_z = power_z;
handles.s = s;
handles.power_s = power_s;
axes(handles.axes1)
semilogy(handles.z,handles.power_z*1E9,'r-')
axis([0 ceil(max(handles.z)) 1E9*handles.power_z(2)/1.2 1E9*ceil(2*max(handles.power_z))])
xlabel('{\itz} (m)')
ylabel('\langle{\itP}\rangle (W)')
title(['{\it\rho} = ' sprintf('%4.2e',rho) ',  {\itL_{G0}} = ' sprintf('%4.2f m',gainLength/sqrt(3)) ',  {\it\lambda_r} = ' sprintf('%5.3e m',resWavelength)])
enhance_plot('times',10,2,2)
[mn,i] = min(abs(handles.z-handles.zplot));
plot_P_vs_s(handles)
guidata(hObject, handles);


function plot_P_vs_s(handles)
[mn,i] = min(abs(handles.z-handles.zplot));
max(handles.power_s);
axes(handles.axes2)
plot(handles.s,handles.power_s(i,:),'-')
if handles.axis
  axis([0 max(handles.s) 0 max(max(handles.power_s))])
end
xlabel('{\its} (\mum)')
ylabel('{\itP} (GW)')
enhance_plot('times',10,1,1)


% --- Executes on button press in CONSTSEED.
function CONSTSEED_Callback(hObject, eventdata, handles)
handles.inp_struc.constseed = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on slider movement.
function SLIDER1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
newval = get(hObject,'Value');
[mn,i] = min(abs(handles.z-newval));
val = handles.z(i);
set(handles.CURVAL,'String',val);
handles.zplot = val;
if handles.runok
  plot_P_vs_s(handles)
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SLIDER1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function CURVAL_Callback(hObject, eventdata, handles)
newval = str2double(get(hObject,'String'));
zmax = get(handles.SLIDER1,'Max');
zmin = get(handles.SLIDER1,'Min');
if  isempty(newval) | (newval<zmin) | (newval>zmax)
	oldval = get(handles.SLIDER1,'Value');
	set(hObject,'String',oldval);
else
	set(handles.SLIDER1,'Value',newval)
end
handles.zplot = newval;
if handles.runok
  plot_P_vs_s(handles)
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CURVAL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AXISMAX.
function AXISMAX_Callback(hObject, eventdata, handles)
handles.axis = get(hObject,'Value');
if handles.runok
  plot_P_vs_s(handles)
end
guidata(hObject, handles);


function P0_Callback(hObject, eventdata, handles)
% hObject    handle to P0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P0 as text
%        str2double(get(hObject,'String')) returns contents of P0 as a double
handles.inp_struc.P0 = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.P0)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function P0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/toolbox/SASE1D_GUI.m', which('SASE1D_GUI'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end
