function varargout = LCLSopt(varargin)
% LCLSOPT M-file for LCLSopt.fig
%      LCLSOPT, by itself, creates a new LCLSOPT or raises the existing
%      singleton*.
%
%      H = LCLSOPT returns the handle to a new LCLSOPT or the handle to
%      the existing singleton*.
%
%      LCLSOPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LCLSOPT.M with the given input arguments.
%
%      LCLSOPT('Property','Value',...) creates a new LCLSOPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LCLSopt_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LCLSopt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LCLSopt

% Last Modified by GUIDE v2.5 13-Jul-2008 15:40:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LCLSopt_OpeningFcn, ...
                   'gui_OutputFcn',  @LCLSopt_OutputFcn, ...
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


% --- Executes just before LCLSopt is made visible.
function LCLSopt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LCLSopt (see VARARGIN)

% Choose default command line output for LCLSopt
handles.output = hObject;
handles.charge = str2double(get(handles.CHARGE,'String'));
handles.energy0 = str2double(get(handles.ENERGY0,'String'))/1E3;
handles.sigz0 = str2double(get(handles.SIGZ0,'String'));
handles.sigd0 = str2double(get(handles.SIGD0,'String'));
handles.dl1energy = str2double(get(handles.DL1ENERGY,'String'))/1E3;
handles.dl1sigz = str2double(get(handles.DL1SIGZ,'String'));
handles.dl1sigd = str2double(get(handles.DL1SIGD,'String'));
handles.bc1energy = str2double(get(handles.BC1ENERGY,'String'))/1E3;
handles.bc1sigz = str2double(get(handles.BC1SIGZ,'String'));
handles.minbc1sigz = str2double(get(handles.MINBC1SIGZ,'String'));
handles.maxbc1sigz = str2double(get(handles.MAXBC1SIGZ,'String'));
handles.bc1sigd = str2double(get(handles.BC1SIGD,'String'));
handles.minbc1sigd = str2double(get(handles.MINBC1SIGD,'String'));
handles.maxbc1sigd = str2double(get(handles.MAXBC1SIGD,'String'));
handles.bc2energy = str2double(get(handles.BC2ENERGY,'String'));
handles.bc2sigz = str2double(get(handles.BC2SIGZ,'String'));
handles.bc2sigd = str2double(get(handles.BC2SIGD,'String'));
handles.dl2energy = str2double(get(handles.DL2ENERGY,'String'));
if handles.dl2energy == handles.bc2energy
  handles.dl2energy = handles.bc2energy + 0.0001;
end
handles.dl2ipkdes = str2double(get(handles.DL2IPKDES,'String'));
handles.dl2ipkerror = str2double(get(handles.DL2IPKERROR,'String'));
handles.dl2sigd = str2double(get(handles.DL2SIGD,'String'));
handles.dl2sigderror = str2double(get(handles.DL2SIGDERROR,'String'));
handles.l0phase = str2double(get(handles.L0PHASE,'String'));
handles.l1phase = str2double(get(handles.L1PHASE,'String'));
handles.maxl1phase = str2double(get(handles.MAXL1PHASE,'String'));
handles.minl1phase = str2double(get(handles.MINL1PHASE,'String'));
handles.lxphase = str2double(get(handles.LXPHASE,'String'));
handles.lxvolts = str2double(get(handles.LXVOLTS,'String'))/1E3;
if handles.lxvolts == 0
  handles.lxvolts = 0.00001;
end
handles.l2phase = str2double(get(handles.L2PHASE,'String'));
handles.maxl2phase = str2double(get(handles.MAXL2PHASE,'String'));
handles.minl2phase = str2double(get(handles.MINL2PHASE,'String'));
handles.l3phase = str2double(get(handles.L3PHASE,'String'));
handles.maxl3phase = str2double(get(handles.MAXL3PHASE,'String'));
handles.minl3phase = str2double(get(handles.MINL3PHASE,'String'));
handles.dl1r56 = str2double(get(handles.DL1R56,'String'))/1E3;
handles.bc1r56 = str2double(get(handles.BC1R56,'String'))/1E3;
handles.minbc1r56 = str2double(get(handles.MINBC1R56,'String'))/1E3;
handles.maxbc1r56 = str2double(get(handles.MAXBC1R56,'String'))/1E3;
handles.bc2r56 = str2double(get(handles.BC2R56,'String'))/1E3;
handles.minbc2r56 = str2double(get(handles.MINBC2R56,'String'))/1E3;
handles.maxbc2r56 = str2double(get(handles.MAXBC2R56,'String'))/1E3;
handles.dl2r56 = str2double(get(handles.DL2R56,'String'))/1E3;
handles.maxdidt = str2double(get(handles.MAXDIDT,'String'));
handles.maxdedt = str2double(get(handles.MAXDEDT,'String'));
handles.maxdidn = str2double(get(handles.MAXDIDN,'String'));
handles.maxdedn = str2double(get(handles.MAXDEDN,'String'));
handles.emitx = str2double(get(handles.EMITX,'String'))*1E-6;
handles.emity = str2double(get(handles.EMITY,'String'))*1E-6;
handles.K = 3.5;
handles.beta = 30;
handles.lamu = 0.03;
dt = get_time;
set(handles.DATETIME,'String',dt)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LCLSopt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LCLSopt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function EMITX_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))*1E-6;
if x <= 0
  errordlg('Emittance at or below zero is not acceptable','BAD ENTRY')
  x = 1.20;
  set(handles.EMITX,'String',num2str(x))
end
handles.emitx = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EMITX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMITY_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))*1E-6;
if x <= 0
  errordlg('Emittance at or below zero is not acceptable','BAD ENTRY')
  x = 1.20;
  set(handles.EMITY,'String',num2str(x))
end
handles.emity = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EMITY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CHARGE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Charge at or below zero is not acceptable','BAD ENTRY')
  x = 0.25;
  set(handles.CHARGE,'String',num2str(x))
end
handles.charge = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function CHARGE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ENERGY0_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x <= 0
  errordlg('Energy at or below zero is not acceptable','BAD ENTRY')
  x = 6.00;
  set(handles.ENERGY0,'String',num2str(x))
end
handles.energy0 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ENERGY0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGZ0_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Bunch length at or below zero is not acceptable','BAD ENTRY')
  x = 0.750;
  set(handles.SIGZ0,'String',num2str(x))
end
handles.sigz0 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SIGZ0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGD0_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Energy spread at or below zero is not acceptable','BAD ENTRY')
  x = 0.05;
  set(handles.SIGD0,'String',num2str(x))
end
handles.sigd0 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SIGD0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL1ENERGY_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x <= 0
  errordlg('Energy at or below zero is not acceptable','BAD ENTRY')
  x = 135;
  set(handles.DL1ENERGY,'String',num2str(x))
end
handles.dl1energy = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL1ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL1SIGZ_Callback(hObject, eventdata, handles)
handles.dl1sigz = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL1SIGZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL1SIGD_Callback(hObject, eventdata, handles)
handles.dl1sigd = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL1SIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL1IPK_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DL1IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LXENERGY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LXENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LXSIGD_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LXSIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L0PHASE_Callback(hObject, eventdata, handles)
handles.l0phase = str2double(get(hObject,'String'));
guidata(hObject, handles);


function L1PHASE_Callback(hObject, eventdata, handles)
handles.l1phase = str2double(get(hObject,'String'));
guidata(hObject, handles);


function MAXL1PHASE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= handles.minl1phase
  errordlg('Phase less than or equal to minimum is not acceptable','BAD ENTRY')
  x = handles.minl1phase+1;
  set(handles.MAXL1PHASE,'String',num2str(x))
end
handles.maxl1phase = x;
guidata(hObject, handles);


function MINL1PHASE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x >= handles.maxl1phase
  errordlg('Phase greater than or equal to maximum is not acceptable','BAD ENTRY')
  x = handles.maxl1phase-1;
  set(handles.MINL1PHASE,'String',num2str(x))
end
handles.minl1phase = x;
guidata(hObject, handles);


function LXPHASE_Callback(hObject, eventdata, handles)
handles.lxphase = str2double(get(hObject,'String'));
guidata(hObject, handles);


function L2PHASE_Callback(hObject, eventdata, handles)
handles.l2phase = str2double(get(hObject,'String'));
guidata(hObject, handles);


function L3PHASE_Callback(hObject, eventdata, handles)
handles.l3phase = str2double(get(hObject,'String'));
guidata(hObject, handles);


function MINL2PHASE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x >= handles.maxl2phase
  errordlg('Phase greater than or equal to maximum is not acceptable','BAD ENTRY')
  x = handles.maxl2phase-1;
  set(handles.MINL2PHASE,'String',num2str(x))
end
handles.minl2phase = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MINL2PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXL2PHASE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= handles.minl2phase
  errordlg('Phase less than or equal to minimum is not acceptable','BAD ENTRY')
  x = handles.minl2phase+1;
  set(handles.MAXL2PHASE,'String',num2str(x))
end
handles.maxl2phase = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXL2PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MINL3PHASE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x >= handles.maxl3phase
  errordlg('Phase greater than or equal to maximum is not acceptable','BAD ENTRY')
  x = handles.maxl3phase-1;
  set(handles.MINL3PHASE,'String',num2str(x))
end
handles.minl3phase = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MINL3PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXL3PHASE_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= handles.minl3phase
  errordlg('Phase less than or equal to minimum is not acceptable','BAD ENTRY')
  x = handles.minl3phase+1;
  set(handles.MAXL3PHASE,'String',num2str(x))
end
handles.maxl3phase = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXL3PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LXVOLTS_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x < 0
  errordlg('Voltage below zero is not acceptable','BAD ENTRY')
  x = 20.0;
  set(handles.LXVOLTS,'String',num2str(x))
end
handles.lxvolts = x;
if handles.lxvolts == 0
  handles.lxvolts =  0.00001;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LXVOLTS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1R56_Callback(hObject, eventdata, handles)
handles.bc1r56 = str2double(get(hObject,'String'))/1E3;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC1R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXBC1R56_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x <= handles.minbc1r56
  errordlg('Maximum R56 less than or equal to minimum R56 is not acceptable','BAD ENTRY')
  x = handles.minbc1r56+0.001;
  set(handles.MAXBC1R56,'String',num2str(x*1E3))
end
handles.maxbc1r56 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXBC1R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MINBC1R56_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x >= handles.maxbc1r56
  errordlg('Minimum R56 greater than or equal to maximum R56 is not acceptable','BAD ENTRY')
  x = handles.maxbc1r56-0.001;
  set(handles.MINBC1R56,'String',num2str(x*1E3))
end
handles.minbc1r56 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MINBC1R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2R56_Callback(hObject, eventdata, handles)
handles.bc2r56 = str2double(get(hObject,'String'))/1E3;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXBC2R56_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x <= handles.minbc2r56
  errordlg('Maximum R56 less than or equal to minimum R56 is not acceptable','BAD ENTRY')
  x = handles.minbc2r56+0.001;
  set(handles.MAXBC2R56,'String',num2str(x*1E3))
end
handles.maxbc2r56 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXBC2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MINBC2R56_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x >= handles.maxbc2r56
  errordlg('Minimum R56 greater than or equal to maximum R56 is not acceptable','BAD ENTRY')
  x = handles.maxbc2r56-0.001;
  set(handles.MINBC2R56,'String',num2str(x*1E3))
end
handles.minbc2r56 = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MINBC2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL1R56_Callback(hObject, eventdata, handles)
handles.dl1r56 = str2double(get(hObject,'String'))/1E3;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL1R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2R56_Callback(hObject, eventdata, handles)
handles.dl2r56 = str2double(get(hObject,'String'))/1E3;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1ENERGY_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'))/1E3;
if x <= 0
  errordlg('Energy at or below zero is not acceptable','BAD ENTRY')
  x = 250;
  set(handles.BC1ENERGY,'String',num2str(x))
end
handles.bc1energy = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC1ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1SIGZ_Callback(hObject, eventdata, handles)
handles.bc1sigz = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC1SIGZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1SIGD_Callback(hObject, eventdata, handles)
handles.bc1sigd = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC1SIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1IPK_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BC1IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2ENERGY_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Energy at or below zero is not acceptable','BAD ENTRY')
  x = 4.30;
  set(handles.BC2ENERGY,'String',num2str(x))
end
handles.bc2energy = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC2ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2SIGZ_Callback(hObject, eventdata, handles)
handles.bc2sigz = str2double(get(hObject,'String'))/1E3;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC2SIGZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2SIGD_Callback(hObject, eventdata, handles)
handles.bc2sigd = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BC2SIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2IPK_Callback(hObject, eventdata, handles)

function BC2IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2ENERGY_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Energy at or below zero is not acceptable','BAD ENTRY')
  x = 13.64;
  set(handles.DL2ENERGY,'String',num2str(x))
end
handles.dl2energy = x;
if handles.dl2energy == handles.bc2energy
  handles.dl2energy = handles.bc2energy + 0.0001;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL2ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2IPKDES_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Peak current at or less than zero is not acceptable','BAD ENTRY')
  x = 2700;
  set(handles.DL2IPKDES,'String',num2str(x))
end
handles.dl2ipkdes = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL2IPKDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2SIGD_Callback(hObject, eventdata, handles)
handles.dl2sigd = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL2SIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2IPK_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DL2IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MINBC1SIGZ_Callback(hObject, eventdata, handles)
handles.minbc1sigz = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MINBC1SIGZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXBC1SIGZ_Callback(hObject, eventdata, handles)
handles.maxbc1sigz = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXBC1SIGZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXBC1SIGD_Callback(hObject, eventdata, handles)
handles.maxbc1sigd = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXBC1SIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MINBC1SIGD_Callback(hObject, eventdata, handles)
handles.minbc1sigd = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MINBC1SIGD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2IPKERROR_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Peak current tolerance at or below zero is not acceptable','BAD ENTRY')
  x = 5;
  set(handles.DL2IPKERROR,'String',num2str(x))
end
handles.dl2ipkerror = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL2IPKERROR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2SIGDERROR_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x <= 0
  errordlg('Energy spread tolerance at or below zero is not acceptable','BAD ENTRY')
  x = 0.01;
  set(handles.DL2SIGDERROR,'String',num2str(x))
end
handles.dl2sigderror = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DL2SIGDERROR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGZF_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function SIGZF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGDF_Callback(hObject, eventdata, handles)

function SIGDF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXDIDT_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x < 0
  errordlg('|dI/dt| below zero is not acceptable','BAD ENTRY')
  x = 300;
  set(handles.MAXDIDT,'String',num2str(x))
end
handles.maxdidt = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXDIDT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DIDTo_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DIDTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXDIDN_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x < 0
  errordlg('|dI/dN| below zero is not acceptable','BAD ENTRY')
  x = 50;
  set(handles.MAXDIDN,'String',num2str(x))
end
handles.maxdidn = x;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MAXDIDN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXDEDT_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x < 0
  errordlg('|dE/dt| below zero is not acceptable','BAD ENTRY')
  x = 0.1;
  set(handles.MAXDEDT,'String',num2str(x))
end
handles.maxdedt = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXDEDT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MAXDEDN_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if x < 0
  errordlg('|dE/dN| below zero is not acceptable','BAD ENTRY')
  x = 0.01;
  set(handles.MAXDEDN,'String',num2str(x))
end
handles.maxdedn = x;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MAXDEDN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DIDNo_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DIDNo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DEDTo_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DEDTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DEDNo_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DEDNo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CHISQ_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CHISQ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LAMR_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LAMR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LGAIN_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LGAIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PSAT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PSAT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NPHOTON_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function NPHOTON_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHOTONENERGY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PHOTONENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CALCULATE.
function CALCULATE_Callback(hObject, eventdata, handles)
N = handles.charge*6.2415E9;
sz0 = handles.sigz0;
sd0 = handles.sigd0;
Eg = handles.energy0;
Ev(1) = handles.dl1energy;
Ev(2) = (handles.bc1energy - handles.lxvolts*cosd(handles.lxphase));
Ev(3) = handles.bc1energy;
Ev(4) = handles.bc2energy;
Ev(5) = handles.dl2energy;
R56v0(1) = handles.dl1r56;
R56v0(2) = 0;
R56v0(3) = handles.bc1r56;
R56v0(4) = handles.bc2r56;
R56v0(5) = handles.dl2r56;
phiv0(1) = handles.l0phase;
phiv0(2) = handles.l1phase;
phiv0(3) = handles.lxphase;
phiv0(4) = handles.l2phase;
phiv0(5) = handles.l3phase;
lamS   = 2.99792458E8/2856E6;							% S-band RF wavelength [m]
T566v0 = [0.1400 0 -1.5*R56v0(3) -1.5*R56v0(4) 0.005];	% T566 values (<0 compresses with phi1<0) [m]
lamv   = [lamS lamS lamS/4 lamS lamS];                  % rf wavelength [m]
s0v    = [1.32 1.32 0.77 1.32 1.32];                    % characteristic wakefield-length [mm]
av     = [11.6 11.6 4.72 11.6 11.6];                    % mean iris radius [mm]
Lv     = [6.1 8.8 0.6 329 553];                         % active length of each linac (scales wake) [m]
dphiv  = 0.0*ones(1,5);                                 % RF phase error of linacs to test sensitivity with [deg]

[szc,sdc,kc,Ipkc,dE_Ec,dtc,Elossc,dI_dNc,dE_dNc,dI_dtgc,dE_dtgc,sdsgnc] = ...
  					LCLSopt_fun(sz0,sd0,Eg,Ev,R56v0,T566v0,phiv0,Lv,N,dphiv,lamv,s0v,av);

K = handles.K;
Q = handles.charge*1E-9;  % nC
sz = szc(5)*1E-3;
exey = sqrt(handles.emitx*handles.emity);
beta = handles.beta;
sd = handles.sigd0*1E-2*Eg/Ev(5)*handles.sigz0/szc(5);
lamu = handles.lamu;

FELp = util_LCLS_FEL_Performance_Estimate (Ev(5),exey*1E6,Ipkc(5),sz*1E6,2.8);

Lg = FELp.L_G3D;
Psat = FELp.P_out_c*1E-9;
lamr = FELp.lambda_r;
Ephot = 4.13566733E-15*2.99792458E8/lamr;                   % eV
Nphot = Psat*1E6*szc(5)*sqrt(12)/2.99792458E8/Ephot/1.602177E-19;

%[Lg,L1d,Psat,rho,Lr,Ipk,sigx,lamr,Nphot,Ephot] = sase_fel(Ev(5),K,Q,sz,exey,30,sd,lamu);

set(handles.LAMR,'String',sprintf('%5.3f',lamr*1E9))
set(handles.LGAIN,'String',sprintf('%5.3f',Lg))
set(handles.PSAT,'String',sprintf('%5.2f',Psat))
set(handles.NPHOTON,'String',sprintf('%5.3f',Nphot/1E12))
set(handles.PHOTONENERGY,'String',sprintf('%5.3f',Ephot/1E3))

set(handles.DL1SIGZ,'String',sprintf('%5.3f',szc(1)))
set(handles.DL1IPK,'String',sprintf('%4.1f',Ipkc(1)))
set(handles.LXENERGY,'String',sprintf('%5.1f',Ev(2)*1E3))
set(handles.LXSIGD,'String',sprintf('%5.3f',sdc(2)))
set(handles.BC1SIGZ,'String',sprintf('%5.3f',szc(3)))
if (szc(3) > handles.maxbc1sigz) || (szc(3) < handles.minbc1sigz)
  set(handles.BC1SIGZ,'ForegroundColor','red')
else
  set(handles.BC1SIGZ,'ForegroundColor','green')
end
set(handles.BC2SIGZ,'String',sprintf('%5.2f',szc(4)*1E3))

set(handles.SIGZF,'String',sprintf('%5.2f',szc(5)*1E3))
dl2ipk = handles.charge*1E-9*2.99792458E8/sqrt(12)/szc(5)/1E-3;
if (abs(dl2ipk - handles.dl2ipkdes) > handles.dl2ipkerror)
  set(handles.DL2IPK,'ForegroundColor','red')
else
  set(handles.DL2IPK,'ForegroundColor','green')
end
set(handles.DL1SIGD,'String',sprintf('%5.3f',sdc(1)))
set(handles.BC1SIGD,'String',sprintf('%5.3f',sdc(3)))
if (sdc(3) > handles.maxbc1sigd) || (sdc(3) < handles.minbc1sigd)
  set(handles.BC1SIGD,'ForegroundColor','red')
else
  set(handles.BC1SIGD,'ForegroundColor','green')
end
set(handles.BC1IPK,'String',sprintf('%4.1f',Ipkc(3)))
set(handles.BC2SIGD,'String',sprintf('%5.3f',sdc(4)))
set(handles.SIGDF,'String',sprintf('%5.3f',sdc(5)))
if (abs(sdc(5)-handles.dl2sigd) > handles.dl2sigderror)
  set(handles.SIGDF,'ForegroundColor','red')
else
  set(handles.SIGDF,'ForegroundColor','green')
end
set(handles.DIDNo,'String',sprintf('%5.1f',dI_dNc))
if (abs(dI_dNc) > handles.maxdidn)
  set(handles.DIDNo,'ForegroundColor','red')
else
  set(handles.DIDNo,'ForegroundColor','green')
end
set(handles.DEDNo,'String',sprintf('%5.3f',dE_dNc))
if (abs(dE_dNc) > handles.maxdedn)
  set(handles.DEDNo,'ForegroundColor','red')
else
  set(handles.DEDNo,'ForegroundColor','green')
end
set(handles.DIDTo,'String',sprintf('%5.1f',dI_dtgc))
if (abs(dI_dtgc) > handles.maxdidt)
  set(handles.DIDTo,'ForegroundColor','red')
else
  set(handles.DIDTo,'ForegroundColor','green')
end
set(handles.DEDTo,'String',sprintf('%5.3f',dE_dtgc))
if (abs(dE_dtgc) > handles.maxdedt)
  set(handles.DEDTo,'ForegroundColor','red')
else
  set(handles.DEDTo,'ForegroundColor','green')
end
set(handles.DL2IPK,'String',sprintf('%4.0f',Ipkc(5)))
set(handles.BC1R56,'String',sprintf('%5.1f',R56v0(3)*1E3))
if (R56v0(3) > handles.maxbc1r56) || (R56v0(3) < handles.minbc1r56)
  set(handles.BC1R56,'ForegroundColor','red')
else
  set(handles.BC1R56,'ForegroundColor','green')
end
set(handles.BC2IPK,'String',sprintf('%4.0f',Ipkc(4)))
set(handles.BC2R56,'String',sprintf('%5.1f',R56v0(4)*1E3))
if (R56v0(4) > handles.maxbc2r56) || (R56v0(4) < handles.minbc2r56)
  set(handles.BC2R56,'ForegroundColor','red')
else
  set(handles.BC2R56,'ForegroundColor','green')
end
set(handles.L1PHASE,'String',sprintf('%5.1f',phiv0(2)))
if (phiv0(2) > handles.maxl1phase) || (phiv0(2) < handles.minl1phase)
  set(handles.L1PHASE,'ForegroundColor','red')
else
  set(handles.L1PHASE,'ForegroundColor','cyan')
end
set(handles.L2PHASE,'String',sprintf('%5.1f',phiv0(4)))
if (phiv0(4) > handles.maxl2phase) || (phiv0(4) < handles.minl2phase)
  set(handles.L2PHASE,'ForegroundColor','red')
else
  set(handles.L2PHASE,'ForegroundColor','cyan')
end
set(handles.L3PHASE,'String',sprintf('%5.1f',phiv0(5)))
if (phiv0(5) > handles.maxl3phase) || (phiv0(5) < handles.minl3phase)
  set(handles.L3PHASE,'ForegroundColor','red')
else
  set(handles.L3PHASE,'ForegroundColor','cyan')
end

if (1+R56v0(3)*kc(3)) > 0
  set(handles.BC1UNDEROVER,'String','under-compressed')
  set(handles.BC1UNDEROVER,'ForegroundColor','green')
else
  set(handles.BC1UNDEROVER,'String','over-compressed')
  set(handles.BC1UNDEROVER,'ForegroundColor','red')
end
if (1+R56v0(4)*kc(4)) > 0
  set(handles.BC2UNDEROVER,'String','under-compressed')
  set(handles.BC2UNDEROVER,'ForegroundColor','green')
else
  set(handles.BC2UNDEROVER,'String','over-compressed')
  set(handles.BC2UNDEROVER,'ForegroundColor','red')
end
dt = get_time;
set(handles.DATETIME,'String',dt)
drawnow
guidata(hObject, handles);


% --- Executes on button press in OPTIMIZE.
function OPTIMIZE_Callback(hObject, eventdata, handles)
set(handles.OPTIMIZE,'String','running...')
set(handles.OPTIMIZE,'BackgroundColor','white')
drawnow
N = handles.charge*6.2415E9;
sz0 = handles.sigz0;
sd0 = handles.sigd0;
Eg = handles.energy0;
Ev(1) = handles.dl1energy;
Ev(2) = (handles.bc1energy - handles.lxvolts*cosd(handles.lxphase));
Ev(3) = handles.bc1energy;
Ev(4) = handles.bc2energy;
Ev(5) = handles.dl2energy;
R56v0(1) = handles.dl1r56;
R56v0(2) = 0;
R56v0(3) = handles.bc1r56;
R56v0(4) = handles.bc2r56;
R56v0(5) = handles.dl2r56;
phiv0(1) = handles.l0phase;
phiv0(2) = handles.l1phase;
phiv0(3) = handles.lxphase;
phiv0(4) = handles.l2phase;
phiv0(5) = handles.l3phase;
dszf = handles.charge*1E-12*2.99792458E8/sqrt(12)/handles.dl2ipkerror;
Xmin(1) = handles.minbc1r56;
Xmin(2) = handles.minbc2r56;
Xmin(3) = handles.minl1phase;
Xmin(4) = handles.minl2phase;
Xmin(5) = handles.minl3phase;
Xmax(1) = handles.maxbc1r56;
Xmax(2) = handles.maxbc2r56;
Xmax(3) = handles.maxl1phase;
Xmax(4) = handles.maxl2phase;
Xmax(5) = handles.maxl3phase;
szn0(1) = 0;
szn0(2) = 0;
szn0(3) = handles.bc1sigz;
szn0(4) = 0;
szn0(5) = handles.charge*1E-6*2.99792458E8/sqrt(12)/handles.dl2ipkdes;
szmin(1) = 0;
szmin(2) = 0;
szmin(3) = handles.minbc1sigz;
szmin(4) = 0;
szmin(5) = 0;
szmax(1) = 0;
szmax(2) = 0;
szmax(3) = handles.maxbc1sigz;
szmax(4) = 0;
szmax(5) = 0;
sdn0(1) = 0;
sdn0(2) = 0;
sdn0(3) = handles.bc1sigd;
sdn0(4) = 0;
sdn0(5) = 0;
sdmin(1) = 0;
sdmin(2) = 0;
sdmin(3) = handles.minbc1sigd;
sdmin(4) = 0;
sdmin(5) = 0;
sdmax(1) = 0;
sdmax(2) = 0;
sdmax(3) = handles.maxbc1sigd;
sdmax(4) = 0;
sdmax(5) = 0;
sdsgn0(1) = 0;
sdsgn0(2) = 0;
sdsgn0(3) = 0;
sdsgn0(4) = 0;
sdsgn0(5) = handles.dl2sigd;
dsdsgn0(1) = 0;
dsdsgn0(2) = 0;
dsdsgn0(3) = 0;
dsdsgn0(4) = 0;
dsdsgn0(5) = handles.dl2sigderror;
dI_dN0   = handles.maxdidn;
ddI_dN0  = 0;
dE_dN0   = handles.maxdedn;
ddE_dN0  = 0;
dI_dtg0  = handles.maxdidt;
ddI_dtg0 = 0;
dE_dtg0  = handles.maxdedt;
ddE_dtg0 = 0;


% non-user input...
X0      = [R56v0(3) R56v0(4) phiv0(2) phiv0(4) phiv0(5)];
Gvmax   = [0 0.019  0  0.017      0.017];               % maximum limit to allowed gradients [GV/m]
Gvmin   = Gvmax*0.1;                                    % minimum limit to allowed gradients [GV/m]

% Above are initial parameters
% ==================================================================

% Fixed parameters:
lamS   = 2.99792458E8/2856E6;							% S-band RF wavelength [m]
T566v0 = [0.1400 0 -1.5*R56v0(3) -1.5*R56v0(4) 0.005];	% T566 values (<0 compresses with phi1<0) [m]
lamv   = [lamS lamS lamS/4 lamS lamS];                  % rf wavelength [m]
s0v    = [1.32 1.32 0.77 1.32 1.32];                    % characteristic wakefield-length [mm]
av     = [11.6 11.6 4.72 11.6 11.6];                    % mean iris radius [mm]
Lv     = [6.1 8.8 0.6 329 553];                         % active length of each linac (scales wake) [m]

Gv(1)    = (Ev(1)  -Eg     ) /Lv(1)   /cosd(phiv0(1));	% linac-0 gradient [GV/m]
Gv(2:5)  = (Ev(2:5)-Ev(1:4))./Lv(2:5)./cosd(phiv0(2:5));	% linac-1,x,2,3 gradient [GV/m]

Gcos0(1)   = (Ev(1)   - Eg     ) /Lv(1);                % initial value of RF-gradient*cos(phi) in L0 [GeV/m]
Gcos0(2:5) = (Ev(2:5) - Ev(1:4))./Lv(2:5);              % initial value of RF-gradient*cos(phi) in L1 [GeV/m]

Lmax     = Lv(2)+Lv(3)+Lv(4)+Lv(5);                     % maximum linac length available - not including injector [m]
dphiv    = 0.0*ones(1,5);                               % RF phase error of linacs to test sensitivity with [deg]

options = optimset('MaxIter',30000,'MaxFunEvals',30000,'TolFun',1E-6,'TolX',1E-6); %,'Display','iter');

[X,FVAL,EXITFLAG,OUTPUT]    = fminsearch('LCLSopt_min',X0,options,Xmin,Xmax,Lmax,Eg,Ev,R56v0,T566v0,phiv0,Lv,Gcos0,Gvmax,Gvmin,...
                                         sz0,sd0,N,dphiv,...
                                         szn0,szmin,szmax,dszf,...
                                         sdn0,sdmin,sdmax,...
                                         sdsgn0,dsdsgn0,...
                                         dI_dN0,ddI_dN0,...
                                         dE_dN0,ddE_dN0,...
                                         dI_dtg0,ddI_dtg0,...
                                         dE_dtg0,ddE_dtg0,lamv,s0v,av,0);

R56vo     = R56v0;
R56vo(3)  = X(1);
R56vo(4)  = X(2);
T566vo    = T566v0;
T566vo(3) = -1.5*R56vo(3);
T566vo(4) = -1.5*R56vo(4);
phivo     = phiv0;
phivo(2)  = X(3);
phivo(4)  = X(4);
phivo(5)  = X(5);
Lvo(1)    = (Ev(1)  -Eg     ) /Gcos0(1);		% linac-0 length [m]
Lvo(2:5)  = (Ev(2:5)-Ev(1:4))./Gcos0(2:5);		% linac-1 length [m]

% calculate initial compression, before fit...
% =========================================
[szi,sdi,ki,Ipki,dE_Ei,dti,Elossi,dI_dNi,dE_dNi,dI_dtgi,dE_dtgi,sdsgni] = ...
  					LCLSopt_fun(sz0,sd0,Eg,Ev,R56v0,T566v0,phiv0,Lv,N,dphiv,lamv,s0v,av);

% calculate new compression, after fit...
% ====================================
[szo,sdo,ko,Ipko,dE_Eo,dto,Elosso,dI_dNo,dE_dNo,dI_dtgo,dE_dtgo,sdsgno] = ...
  					LCLSopt_fun(sz0,sd0,Eg,Ev,R56vo,T566vo,phivo,Lvo,N,dphiv,lamv,s0v,av);

X0      = [R56vo(3) R56vo(4) phivo(2) phivo(4) phivo(5)];
chisq = LCLSopt_min(X0,Xmin,Xmax,Lmax,Eg,Ev,R56vo,T566vo,phivo,Lvo,Gcos0,Gvmax,Gvmin,sz0,sd0,N,...
                    dphiv,szn0,szmin,szmax,dszf,sdn0,sdmin,sdmax,sdsgn0,dsdsgn0,dI_dN0,ddI_dN0,...
                    dE_dN0,ddE_dN0,dI_dtg0,ddI_dtg0,dE_dtg0,ddE_dtg0,...
                    lamv,s0v,av,0);

handles.l1phase = phivo(2);
handles.l2phase = phivo(4);
handles.l3phase = phivo(5);
handles.bc1r56  = R56vo(3);
handles.bc2r56  = R56vo(4);

K = handles.K;
Q = handles.charge*1E-9;  % nC
sz = szo(5)*1E-3;
exey = sqrt(handles.emitx*handles.emity);
beta = handles.beta;
sd = handles.sigd0*1E-2*Eg/Ev(5)*handles.sigz0/szo(5);
lamu = handles.lamu;
dl2ipk = handles.charge*1E-9*2.99792458E8/sqrt(12)/szo(5)/1E-3;

FELp = util_LCLS_FEL_Performance_Estimate (Ev(5),exey*1E6,dl2ipk,szo(5)*1E6,2.8);

Lg = FELp.L_G3D;
Psat = FELp.P_out_c*1E-9;
lamr = FELp.lambda_r;

Ephot = 4.13566733E-15*2.99792458E8/lamr;                   % eV
Nphot = Psat*1E6*szo(5)*sqrt(12)/2.99792458E8/Ephot/1.602177E-19;

%[Lg,L1d,Psat,rho,Lr,Ipk,sigx,lamr,Nphot,Ephot] = sase_fel(Ev(5),K,Q,sz,exey,30,sd,lamu);

set(handles.LAMR,'String',sprintf('%5.3f',lamr*1E9))
set(handles.LGAIN,'String',sprintf('%5.3f',Lg))
set(handles.PSAT,'String',sprintf('%5.2f',Psat))
set(handles.NPHOTON,'String',sprintf('%5.3f',Nphot/1E12))
set(handles.PHOTONENERGY,'String',sprintf('%5.3f',Ephot/1E3))

set(handles.CHISQ,'String',sprintf('%7.5f',chisq))
if chisq > 1
  set(handles.CHISQ,'ForegroundColor','red')
else
  set(handles.CHISQ,'ForegroundColor','green')
end
set(handles.DL1SIGZ,'String',sprintf('%5.3f',szo(1)))
set(handles.DL1SIGD,'String',sprintf('%5.3f',sdo(1)))
set(handles.DL1IPK,'String',sprintf('%4.1f',Ipko(1)))
set(handles.LXENERGY,'String',sprintf('%5.1f',Ev(2)*1E3))
set(handles.LXSIGD,'String',sprintf('%5.3f',sdo(2)))
set(handles.BC1SIGZ,'String',sprintf('%5.3f',szo(3)))
if (szo(3) > handles.maxbc1sigz) || (szo(3) < handles.minbc1sigz)
  set(handles.BC1SIGZ,'ForegroundColor','red')
else
  set(handles.BC1SIGZ,'ForegroundColor','green')
end
set(handles.BC2SIGZ,'String',sprintf('%5.2f',szo(4)*1E3))

set(handles.SIGZF,'String',sprintf('%5.2f',szo(5)*1E3))
if (abs(dl2ipk - handles.dl2ipkdes) > handles.dl2ipkerror)
  set(handles.DL2IPK,'ForegroundColor','red')
else
  set(handles.DL2IPK,'ForegroundColor','green')
end
set(handles.DL2IPK,'String',sprintf('%4.0f',Ipko(5)))
set(handles.BC1SIGD,'String',sprintf('%5.3f',sdo(3)))
if (sdo(3) > handles.maxbc1sigd) || (sdo(3) < handles.minbc1sigd)
  set(handles.BC1SIGD,'ForegroundColor','red')
else
  set(handles.BC1SIGD,'ForegroundColor','green')
end
set(handles.BC2SIGD,'String',sprintf('%5.3f',sdo(4)))
set(handles.SIGDF,'String',sprintf('%5.3f',sdo(5)))
if (abs(sdo(5)-handles.dl2sigd) > handles.dl2sigderror)
  set(handles.SIGDF,'ForegroundColor','red')
else
  set(handles.SIGDF,'ForegroundColor','green')
end
set(handles.DIDNo,'String',sprintf('%5.1f',dI_dNo))
if (abs(dI_dNo) > handles.maxdidn)
  set(handles.DIDNo,'ForegroundColor','red')
else
  set(handles.DIDNo,'ForegroundColor','green')
end
set(handles.DEDNo,'String',sprintf('%5.3f',dE_dNo))
if (abs(dE_dNo) > handles.maxdedn)
  set(handles.DEDNo,'ForegroundColor','red')
else
  set(handles.DEDNo,'ForegroundColor','green')
end
set(handles.DIDTo,'String',sprintf('%5.1f',dI_dtgo))
if (abs(dI_dtgo) > handles.maxdidt)
  set(handles.DIDTo,'ForegroundColor','red')
else
  set(handles.DIDTo,'ForegroundColor','green')
end
set(handles.DEDTo,'String',sprintf('%5.3f',dE_dtgo))
if (abs(dE_dtgo) > handles.maxdedt)
  set(handles.DEDTo,'ForegroundColor','red')
else
  set(handles.DEDTo,'ForegroundColor','green')
end
set(handles.BC1R56,'String',sprintf('%5.1f',R56vo(3)*1E3))
if (R56vo(3) > handles.maxbc1r56) || (R56vo(3) < handles.minbc1r56)
  set(handles.BC1R56,'ForegroundColor','red')
else
  set(handles.BC1R56,'ForegroundColor','cyan')
end
set(handles.BC1IPK,'String',sprintf('%5.1f',Ipko(3)))
set(handles.BC2R56,'String',sprintf('%5.1f',R56vo(4)*1E3))
if (R56vo(4) > handles.maxbc2r56) || (R56vo(4) < handles.minbc2r56)
  set(handles.BC2R56,'ForegroundColor','red')
else
  set(handles.BC2R56,'ForegroundColor','cyan')
end
set(handles.BC2IPK,'String',sprintf('%4.0f',Ipko(4)))
set(handles.L1PHASE,'String',sprintf('%5.1f',phivo(2)))
if (phivo(2) > handles.maxl1phase) || (phivo(2) < handles.minl1phase)
  set(handles.L1PHASE,'ForegroundColor','red')
else
  set(handles.L1PHASE,'ForegroundColor','cyan')
end
set(handles.L2PHASE,'String',sprintf('%5.1f',phivo(4)))
if (phivo(4) > handles.maxl2phase) || (phivo(4) < handles.minl2phase)
  set(handles.L2PHASE,'ForegroundColor','red')
else
  set(handles.L2PHASE,'ForegroundColor','cyan')
end
set(handles.L3PHASE,'String',sprintf('%5.1f',phivo(5)))
if (phivo(5) > handles.maxl3phase) || (phivo(5) < handles.minl3phase)
  set(handles.L3PHASE,'ForegroundColor','red')
else
  set(handles.L3PHASE,'ForegroundColor','cyan')
end

if (1+R56vo(3)*ko(3)) > 0
  set(handles.BC1UNDEROVER,'String','under-compressed')
  set(handles.BC1UNDEROVER,'ForegroundColor','green')
else
  set(handles.BC1UNDEROVER,'String','over-compressed')
  set(handles.BC1UNDEROVER,'ForegroundColor','red')
end
if (1+R56vo(4)*ko(4)) > 0
  set(handles.BC2UNDEROVER,'String','under-compressed')
  set(handles.BC2UNDEROVER,'ForegroundColor','green')
else
  set(handles.BC2UNDEROVER,'String','over-compressed')
  set(handles.BC2UNDEROVER,'ForegroundColor','red')
end
set(handles.OPTIMIZE,'Value',0)
set(handles.OPTIMIZE,'String','Optimize')
set(handles.OPTIMIZE,'BackgroundColor','green')
dt = get_time;
set(handles.DATETIME,'String',dt)
drawnow
guidata(hObject, handles);


% --- Executes on button press in ELOG.
function ELOG_Callback(hObject, eventdata, handles)

