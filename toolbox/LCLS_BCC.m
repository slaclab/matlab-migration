function varargout = LCLS_BCC(varargin)
% LCLS_BCC M-file for LCLS_BCC.fig
%      LCLS_BCC, by itself, creates a new LCLS_BCC or raises the existing
%      singleton*.
%
%      H = LCLS_BCC returns the handle to a new LCLS_BCC or the handle to
%      the existing singleton*.
%
%      LCLS_BCC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LCLS_BCC.M with the given input arguments.
%
%      LCLS_BCC('Property','Value',...) creates a new LCLS_BCC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LCLS_BCC_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LCLS_BCC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help LCLS_BCC

% Last Modified by GUIDE v2.5 29-Nov-2007 16:35:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LCLS_BCC_OpeningFcn, ...
                   'gui_OutputFcn',  @LCLS_BCC_OutputFcn, ...
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


% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles)
set(handles.listbox1,'String',handles.file_names,'Value',1)
set(handles.dirtext,'String',dir_path)
set(handles.saved,'String',' ')
set(handles.XRAY,'Visible','off')


% --- Executes just before LCLS_BCC is made visible.
function LCLS_BCC_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
if nargin == 3,
  initial_dir = pwd;
elseif nargin > 4
  if strcmpi(varargin{1},'dir')
    if exist(varargin{2},'dir')
      initial_dir = varargin{2};
    else
      errordlg('Input argument must be a valid directory','Input Argument Error!')
      return
    end
  else
    errordlg('Unrecognized input argument','Input Argument Error!');
    return;
  end
end
handles.initial_dir = initial_dir;
guidata(hObject, handles);
load_listbox(initial_dir,handles)
load_bcc_params(handles,hObject)

% UIWAIT makes LCLS_BCC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function load_bcc_params(handles,hObject)
handles.dphiv   = [0.2 0.2 0.2 0.2 0.2];						% phase errors used to test sensitivity of each linac [deg-S, deg-X, deg-L, etc]
handles.dV_Vv   = [0.2 0.2 0.2 0.2 0.2]/100;					% relative voltage errors used to test sensitivity of each linac [ ]
handles.dtg     = 1;											% gun timing error used to test sensitivity [ps]
handles.dN_N    = 2;											% relative bunch charge error used to test sensitivity [%]
handles.lamS    = 2.99792458E8/2856E6;							% S-band RF wavelength [m]
handles.dI_tol  = 0.12;											% tolerable rms relative peak current jitter [ ]
handles.dE_tol  = 0.10;											% tolerable rms relative energy jitter [%]
handles.dt_tol  = 0.10;											% tolerable rms final timing jitter [ps]
handles.b       = [0.10 0.10 0.50 0.07 0.15 0.0010 0.0010 0.0025 0.0010 0.0008 0.80 2.0];		% nominal jitter budget (L0,1,x,2,3 phase[deg], dV/Volt[ ], dt[ps], dQ/Q[%])
handles.N        = 6.24E9*str2double(get(handles.Charge,'String'));
handles.Eg       = 1E-3*str2double(get(handles.GUNE,'String'));
handles.sz0      = str2double(get(handles.SIGZ0,'String'));
handles.sd0      = 1E-4*str2double(get(handles.SIGE0,'String'))/handles.Eg;
handles.Gemit    = 1E-6*str2double(get(handles.gemit,'String'));
handles.phiv(1)  = str2double(get(handles.L0phase,'String'));
handles.phiv(2)  = str2double(get(handles.L1phase,'String'));
handles.phiv(3)  = str2double(get(handles.LXphase,'String'));
handles.phiv(4)  = str2double(get(handles.L2phase,'String'));
handles.phiv(5)  = str2double(get(handles.L3phase,'String'));
handles.Lv(1)    = 6.1;         % L0 length (m)
handles.Lv(2)    = 8.8;         % L1 length (m)
handles.Lv(3)    = 0.5;         % LX length (m)
handles.Lv(4)    = 329;         % L2 length (m)
handles.Lv(5)    = 550;         % L3 length (m)
handles.lamv(1)  = 0.10497;     % L0 wavelength (m)
handles.lamv(2)  = 0.10497;     % L1 wavelength (m)
handles.lamv(3)  = 0.10497/4;   % LX wavelength (m)
handles.lamv(4)  = 0.10497;     % L2 wavelength (m)
handles.lamv(5)  = 0.10497;     % L3 wavelength (m)
handles.av(1)    = 11.6;        % L0 iris radius (m)
handles.av(2)    = 11.6;        % L1 iris radius (m)
handles.av(3)    = 4.72;        % LX iris radius (m)
handles.av(4)    = 11.6;        % L2 iris radius (m)
handles.av(5)    = 11.6;        % L3 iris radius (m)
handles.s0v(1)   = 1.32;        % L0 wakefield characteristic length (m)
handles.s0v(2)   = 1.32;        % L1 wakefield characteristic length (m)
handles.s0v(3)   = 0.77;        % LX wakefield characteristic length (m)
handles.s0v(4)   = 1.32;        % L2 wakefield characteristic length (m)
handles.s0v(5)   = 1.32;        % L3 wakefield characteristic length (m)
handles.Ev(1)    = str2double(get(handles.DL1E,'String'));
handles.Ev(2)    = str2double(get(handles.L1E,'String'));
handles.Ev(3)    = str2double(get(handles.BC1E,'String'));
handles.Ev(4)    = str2double(get(handles.BC2E,'String'));
handles.Ev(5)    = str2double(get(handles.DL2E,'String'));
handles.R56v(1)  = 6.3E-3;      % DL1 R56 is fixed (m)
handles.R56v(2)  = 0;           % between L1 and LX there are no bends (m)
handles.R56v(3)  = str2double(get(handles.BC1R56,'String'))/1E3;
handles.R56v(4)  = str2double(get(handles.BC2R56,'String'))/1E3;
handles.R56v(5)  = str2double(get(handles.DL2R56,'String'))/1E3;
handles.T566v(1) = 0.14;        % DL1 T566 is fixed (m)
handles.T566v(2) = 0;           % between L1 and LX there are no bends (m)
handles.T566v(3) = -3/2*handles.R56v(3);    % T566 for chicane is -3/2 of R56
handles.T566v(4) = -3/2*handles.R56v(4);    % T566 for chicane is -3/2 of R56
handles.T566v(5) = 5E-3;        % DL2 T566 is almost fixed (m)
handles.Gemit    = str2double(get(handles.gemit,'String'))/1E6;
handles.UndK     = str2double(get(handles.undK,'String'));
handles.Beta     = str2double(get(handles.beta,'String'));
handles.Lamu     = str2double(get(handles.lamu,'String'))/100;
handles.Lund     = str2double(get(handles.LUND,'String'));
handles.fn       = get(handles.filename,'String');
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = LCLS_BCC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function L0phase_Callback(hObject, eventdata, handles)
handles.phiv(1) = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function L0phase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L1phase_Callback(hObject, eventdata, handles)
handles.phiv(2) = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function L1phase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LXphase_Callback(hObject, eventdata, handles)
handles.phiv(3) = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function LXphase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L2phase_Callback(hObject, eventdata, handles)
handles.phiv(4) = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function L2phase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L3phase_Callback(hObject, eventdata, handles)
handles.phiv(5) = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function L3phase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1R56_Callback(hObject, eventdata, handles)
handles.R56v(3)  = str2double(get(hObject,'String'))/1E3;
handles.T566v(3) = -3/2*handles.R56v(3);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BC1R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1E_Callback(hObject, eventdata, handles)
handles.Ev(3)   = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BC1E_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2R56_Callback(hObject, eventdata, handles)
handles.R56v(4)  = str2double(get(hObject,'String'))/1E3;
handles.T566v(4) = -3/2*handles.R56v(4);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BC2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2E_Callback(hObject, eventdata, handles)
handles.Ev(4)   = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BC2E_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2R56_Callback(hObject, eventdata, handles)
handles.R56v(5) = str2double(get(hObject,'String'))/1E3;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function DL2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2E_Callback(hObject, eventdata, handles)
handles.Ev(5)   = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function DL2E_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Charge_Callback(hObject, eventdata, handles)
handles.N = 6.24E9*str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Charge_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GUNE_Callback(hObject, eventdata, handles)
handles.Eg = 1E-3*str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function GUNE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGZ0_Callback(hObject, eventdata, handles)
handles.sz0 = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SIGZ0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGE0_Callback(hObject, eventdata, handles)
handles.sd0 = 1E-4*str2double(get(hObject,'String'))/handles.Eg;    % (converted to percent)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SIGE0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RUN.
function RUN_Callback(hObject, eventdata, handles)

[sigE_E0,meanE_E0] = und_esprd(handles.Ev(5),handles.UndK,handles.Lamu,handles.Lund); % calc. spont. rms rel. energy spread [ ]

[I_jit,E_jit,t_jit,tol_I,tol_E,tol_t,szn,sdn,Ipkn] = FEL_jitter_tols(handles.N,handles.sz0,handles.sd0,...
																	 handles.Eg,handles.Ev,handles.R56v,...
																	 handles.T566v,handles.phiv,handles.dphiv,...
																	 handles.dV_Vv,handles.dtg,handles.dN_N,...
																	 handles.Lv,handles.lamS,handles.lamv,...
																	 handles.s0v,handles.av,handles.dI_tol,...
																	 handles.dE_tol,handles.dt_tol,handles.b,...
																	 'u');

sigEs = handles.sd0/100*handles.sz0/szn(5)*handles.Eg/handles.Ev(5); % final slice rel. rms E-spread ( )
sigEs = sqrt(sigEs^2 + (sigE_E0^2)/2);  % add 1/2 spont. und. E-spread
[Lg,L1d,Psat,rho,Lr,Ipk,sigx,lamr,Nphot,Ephot] = sase_fel(handles.Ev(5),handles.UndK,1E-9*handles.N/6.24E9,...
                                                          szn(5)*1E-3,handles.Gemit,handles.Beta,...
                                                          sigEs,handles.Lamu);

%Pn = sqrt(2*pi)*rho^2*2.99792458E8*handles.Ev(5)*1.602E-19/lamr    % initial noise power [GW]
%N_Lg = log(9*Psat/Pn)       % number of gain lengths to get to Psat from startup noise power [ ]
N_Lg = 20;                  % assume saturation in 20 gain lengths (20*Lg) 
Pn = 9*Psat/exp(N_Lg);      %  initial noise power based on 20*Lg saturation [GW]
if handles.Lund/Lg >= N_Lg  % if und long enough for saturation...
  Pund = Psat;              % ...undulator output power is Ming Xie's value [GW]
else
  Pund = Pn/9*exp(handles.Lund/Lg);     % if not saturated, use exponential estimate [GW]
end

SIGZ1s = sprintf('%5.3f',szn(3));
set(handles.SIGZ1,'String',SIGZ1s);
SIGZ2s = sprintf('%5.3f',szn(4));
set(handles.SIGZ2,'String',SIGZ2s);
SIGZ3s = sprintf('%5.3f',szn(5));
set(handles.SIGZ3,'String',SIGZ3s);
SIGE1s = sprintf('%5.3f',sdn(3));
set(handles.SIGE1,'String',SIGE1s);
SIGE2s = sprintf('%5.3f',sdn(4));
set(handles.SIGE2,'String',SIGE2s);
SIGE3s = sprintf('%5.3f',sigEs*100);
set(handles.SIGE3,'String',SIGE3s);
BC1IPKs = sprintf('%5.3f',Ipkn(3)/1E3);
set(handles.BC1IPK,'String',BC1IPKs);
BC2IPKs = sprintf('%5.3f',Ipkn(4)/1E3);
set(handles.BC2IPK,'String',BC2IPKs);
BC3IPKs = sprintf('%5.3f',Ipkn(5)/1E3);
set(handles.DL2IPK,'String',BC3IPKs);
Lg20s = sprintf('%5.1f',N_Lg*Lg);
set(handles.Lg20,'String',Lg20s);
Punds = sprintf('%5.2f',Pund);
set(handles.PUND,'String',Punds);
LAMRs = sprintf('%5.3f',lamr*1E9);
set(handles.LAMR,'String',LAMRs);
set(handles.XRAY,'Visible','on')


function DL1E_Callback(hObject, eventdata, handles)
x = str2double(get(hObject,'String'));
if isnan(x)
  set(hObject, 'String', 0);
  errordlg('Input must be a number','Error');
end
handles.Ev(1)   = x;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function DL1E_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGZ1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SIGZ1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGZ2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SIGZ2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGZ3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SIGZ3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGE1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SIGE1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGE2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SIGE2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SIGE3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SIGE3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function undK_Callback(hObject, eventdata, handles)
handles.UndK = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function undK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function beta_Callback(hObject, eventdata, handles)
handles.Beta = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lamu_Callback(hObject, eventdata, handles)
handles.Lamu = str2double(get(hObject,'String'))/100;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function lamu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Lg20_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Lg20_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PUND_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PUND_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LAMR_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function LAMR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gemit_Callback(hObject, eventdata, handles)
handles.Gemit = str2double(get(hObject,'String'))/1E6;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function gemit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function L1E_Callback(hObject, eventdata, handles)
handles.Ev(2) = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function L1E_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC1IPK_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function BC1IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2IPK_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function BC2IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DL2IPK_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DL2IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
  index_selected = get(handles.listbox1,'Value');
  file_list = get(handles.listbox1,'String');	
  filename = file_list{index_selected};
  [path,name,ext,ver] = fileparts(filename);
  switch ext
  case '.mat'
    cmnd = ['load ' fullfile(handles.initial_dir, name) ext];
    eval(cmnd)
	handles.dphiv   = handles_sav.dphiv;			% phase errors used to test sensitivity of each linac [deg-S, deg-X, deg-L, etc]
	handles.dV_Vv   = handles_sav.dV_Vv;			% relative voltage errors used to test sensitivity of each linac [ ]
	handles.dtg     = handles_sav.dtg ;				% gun timing error used to test sensitivity [ps]
	handles.dN_N    = handles_sav.dN_N;				% relative bunch charge error used to test sensitivity [%]
	handles.lamS    = handles_sav.lamS;				% S-band RF wavelength [m]
	handles.dI_tol  = handles_sav.dI_tol;			% tolerable rms relative peak current jitter [ ]
	handles.dE_tol  = handles_sav.dE_tol;			% tolerable rms relative energy jitter [%]
	handles.dt_tol  = handles_sav.dt_tol;			% tolerable rms final timing jitter [ps]
	handles.b       = handles_sav.b;				% nominal jitter budget (L0,1,x,2,3 phase[deg], dV/Volt[ ], dt[ps], dQ/Q[%])
	handles.N       = handles_sav.N;
	handles.Eg      = handles_sav.Eg;
	handles.sz0     = handles_sav.sz0;
	handles.sd0     = handles_sav.sd0;
	handles.phiv    = handles_sav.phiv;
	handles.Lv      = handles_sav.Lv;
	handles.lamv    = handles_sav.lamv;
	handles.av      = handles_sav.av;
	handles.s0v     = handles_sav.s0v;
	handles.Ev      = handles_sav.Ev;
	handles.R56v    = handles_sav.R56v;
	handles.T566v   = handles_sav.T566v;
    handles.Gemit   = handles_sav.Gemit;
    handles.UndK    = handles_sav.UndK;
    handles.Beta    = handles_sav.Beta;
    handles.Lamu    = handles_sav.Lamu;
    handles.Lund    = handles_sav.Lund;
	set(handles.Charge ,'String',num2str(handles_sav.N/6.24E9));
	set(handles.GUNE   ,'String',num2str(1E3*handles_sav.Eg));
	set(handles.SIGZ0  ,'String',num2str(handles_sav.sz0));
	set(handles.SIGE0  ,'String',num2str(handles.Eg*handles_sav.sd0/1E-4));
	set(handles.gemit  ,'String',num2str(1E6*handles_sav.Gemit));
	set(handles.L0phase,'String',num2str(handles_sav.phiv(1)));
	set(handles.L1phase,'String',num2str(handles_sav.phiv(2)));
	set(handles.LXphase,'String',num2str(handles_sav.phiv(3)));
	set(handles.L2phase,'String',num2str(handles_sav.phiv(4)));
	set(handles.L3phase,'String',num2str(handles_sav.phiv(5)));
	set(handles.DL1E   ,'String',num2str(handles_sav.Ev(1)));
	set(handles.L1E    ,'String',num2str(handles_sav.Ev(2)));
	set(handles.BC1E   ,'String',num2str(handles_sav.Ev(3)));
	set(handles.BC2E   ,'String',num2str(handles_sav.Ev(4)));
	set(handles.DL2E   ,'String',num2str(handles_sav.Ev(5)));
	set(handles.BC1R56 ,'String',num2str(1E3*handles_sav.R56v(3)));
	set(handles.BC2R56 ,'String',num2str(1E3*handles_sav.R56v(4)));
	set(handles.DL2R56 ,'String',num2str(1E3*handles_sav.R56v(5)));
	set(handles.undK   ,'String',num2str(handles_sav.UndK));
	set(handles.beta   ,'String',num2str(handles_sav.Beta));
	set(handles.lamu   ,'String',num2str(100*handles_sav.Lamu));
	set(handles.LUND   ,'String',num2str(handles_sav.Lund));
    set(handles.filename,'String',[name ext])
    handles.fn = get(handles.filename,'String');
  otherwise
	errordlg(lasterr,'File Type is not .MAT','modal')
  end
end
set(handles.SIGZ1  ,'String',' ');
set(handles.SIGZ2  ,'String',' ');
set(handles.SIGZ3  ,'String',' ');
set(handles.SIGE1  ,'String',' ');
set(handles.SIGE2  ,'String',' ');
set(handles.SIGE3  ,'String',' ');
set(handles.BC1IPK ,'String',' ');
set(handles.BC2IPK ,'String',' ');
set(handles.DL2IPK ,'String',' ');
set(handles.Lg20   ,'String',' ');
set(handles.PUND   ,'String',' ');
set(handles.LAMR   ,'String',' ');
set(handles.saved,'String',' ')
set(handles.XRAY,'Visible','off')
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SAVE.
function SAVE_Callback(hObject, eventdata, handles)
handles_sav = handles;
str = [handles.initial_dir '/' handles.fn];
cmnd = ['save ' str ' handles_sav'];
eval(cmnd)
load_listbox(handles.initial_dir,handles)
set(handles.saved,'String','(saved)')


function filename_Callback(hObject, eventdata, handles)
set(handles.saved,'String',' ')
handles.fn = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LUND_Callback(hObject, eventdata, handles)
handles.Lund = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function LUND_CreateFcn(hObject, eventdata, handles)
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

if strcmp('/usr/local/lcls/tools/matlab/toolbox/run_LCLS_BCC.m', which('run_LCLS_BCC'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end
