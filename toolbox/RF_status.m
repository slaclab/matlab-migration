function varargout = RF_status(varargin)
% RF_STATUS M-file for RF_status.fig
%      RF_STATUS, by itself, creates a new RF_STATUS or raises the existing
%      singleton*.
%
%      H = RF_STATUS returns the handle to a new RF_STATUS or the handle to
%      the existing singleton*.
%
%      RF_STATUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RF_STATUS.M with the given input arguments.
%
%      RF_STATUS('Property','Value',...) creates a new RF_STATUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RF_status_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RF_status_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RF_status

% Last Modified by GUIDE v2.5 19-Oct-2010 11:46:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RF_status_OpeningFcn, ...
                   'gui_OutputFcn',  @RF_status_OutputFcn, ...
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


% --- Executes just before RF_status is made visible.
function RF_status_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.pv_list = {
                    'GUN:IN20:1:GN1_S_AV'    0.006
                    'GUN:IN20:1:GN1_ADES'    0
                    'GUN:IN20:1:GN1_S_PV'    0.3
                    'GUN:IN20:1:GN1_PDES'    0
                    'GUN:IN20:1:GN1_PHAS_FB' 0
                    'GUN:IN20:1:GN1_AMPL_FB' 0
                    'GUN:IN20:1:GN1_SEND'    0
                    'GUN:IN20:1:GN1_S_AS'    0
%
                    'ACCL:IN20:300:L0A_S_AV'    0.2
                    'ACCL:IN20:300:L0A_ADES'    0
                    'ACCL:IN20:300:L0A_S_PV'    0.3
                    'ACCL:IN20:300:L0A_PDES'    0
                    'ACCL:IN20:300:L0A_PHAS_FB' 0
                    'ACCL:IN20:300:L0A_AMPL_FB' 0
                    'ACCL:IN20:300:L0A_SEND'    0
                    'ACCL:IN20:300:L0A_S_AS'    0
%
                    'ACCL:IN20:400:L0B_S_AV'    0.2
                    'ACCL:IN20:400:L0B_ADES'    0
                    'ACCL:IN20:400:L0B_S_PV'    0.3
                    'ACCL:IN20:400:L0B_PDES'    0
                    'ACCL:IN20:400:L0B_PHAS_FB' 0
                    'ACCL:IN20:400:L0B_AMPL_FB' 0
                    'ACCL:IN20:400:L0B_SEND'    0
                    'ACCL:IN20:400:L0B_S_AS'    0
%
                    'TCAV:IN20:490:TC0_S_AV'    0.05
                    'TCAV:IN20:490:TC0_ADES'    0
                    'TCAV:IN20:490:TC0_S_PV'    0.5
                    'TCAV:IN20:490:TC0_PDES'    0
                    'TCAV:IN20:490:TC0_PHAS_FB' 0
                    'TCAV:IN20:490:TC0_AMPL_FB' 0
                    'TCAV:IN20:490:TC0_SEND'    0
                    'TCAV:IN20:490:TC0_S_AS'    0
%
                    'ACCL:LI21:1:L1S_S_AV'    0.5
                    'ACCL:LI21:1:L1S_ADES'    0
                    'ACCL:LI21:1:L1S_S_PV'    0.5
                    'ACCL:LI21:1:L1S_PDES'    0
                    'ACCL:LI21:1:L1S_PHAS_FB' 0
                    'ACCL:LI21:1:L1S_AMPL_FB' 0
                    'ACCL:LI21:1:L1S_SEND'    0
                    'ACCL:LI21:1:L1S_S_AS'    0
%
                    'ACCL:LI21:180:L1X_S_AV'    0.2
                    'ACCL:LI21:180:L1X_ADES'    0
                    'ACCL:LI21:180:L1X_S_PV'    1.0
                    'ACCL:LI21:180:L1X_PDES'    0
                    'ACCL:LI21:180:L1X_PHAS_FB' 0
                    'ACCL:LI21:180:L1X_AMPL_FB' 0
                    'ACCL:LI21:180:L1X_SEND'    0
                    'ACCL:LI21:180:L1X_S_AS'    0
%
                    'LASR:IN20:1:LSR_ADES'       10
                    'LASR:IN20:1:LSR_ADES'       0
                    'LASR:IN20:1:LSR_0_S_PA'     0.5
                    'LASR:IN20:1:LSR_PDES2856'   0
                    'LASR:IN20:1:LSR_P_FB_PND'   0
                    'LASR:IN20:1:LSR_P_FB_PND'   0
                    'LASR:IN20:1:LSR_SEND'       0
                    'LASR:IN20:1:LSR_S_PS'       0
                                            };
handles.klys_pv_list = {
                    'KLYS:LI20:51:TACT' 'TC0'
                    'KLYS:LI20:61:TACT' 'GN1'
                    'KLYS:LI20:71:TACT' 'L0A'
                    'KLYS:LI20:81:TACT' 'L0B'
                    'KLYS:LI21:11:TACT' 'L1S'
                    'KLYS:LI21:21:TACT' 'L1X'
                                            };      % TCAV must be first in list
handles.Nsystems = round(length(handles.pv_list(:,1))/8);
handles.SysNames = '   ';
for j = 1:handles.Nsystems
  str = cell2mat(handles.pv_list(8*(j-1)+1,1));
  i = find(str==':');
  if length(i) < 3
    error('PV List is screwed up - needs at least 3 colons - quitting.')
  end
  handles.SysNames(j,:) = str((i(3)+1):(i(3)+3));
  handles.AmpTols(j)   = cell2mat(handles.pv_list(8*(j-1)+1,2));
  handles.PhaseTols(j) = cell2mat(handles.pv_list(8*(j-1)+3,2));
end
handles.Nklys = length(handles.klys_pv_list(:,1));
handles.KlysNames = '   ';
for j = 1:handles.Nklys
  str = cell2mat(handles.klys_pv_list(j,2));
  handles.KlysNames(j,:) = str;
end
guidata(hObject, handles);

% UIWAIT makes RF_status wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RF_status_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Needed or it will complain on entry (strange!)
function edit19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LSR_PHASE_S_Callback(hObject, eventdata, handles)


function LASER_PHASE_A_Callback(hObject, eventdata, handles)

function LASER_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GN1_VOLT_S_Callback(hObject, eventdata, handles)


function GN1_VOLT_A_Callback(hObject, eventdata, handles)

function GN1_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GN1_PHASE_S_Callback(hObject, eventdata, handles)


function GN1_PHASE_A_Callback(hObject, eventdata, handles)

function GN1_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L0A_VOLT_S_Callback(hObject, eventdata, handles)


function L0A_VOLT_A_Callback(hObject, eventdata, handles)

function L0A_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L0A_PHASE_S_Callback(hObject, eventdata, handles)


function L0A_PHASE_A_Callback(hObject, eventdata, handles)

function L0A_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L0B_VOLT_S_Callback(hObject, eventdata, handles)


function L0B_VOLT_A_Callback(hObject, eventdata, handles)

function L0B_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L0B_PHASE_S_Callback(hObject, eventdata, handles)


function L0B_PHASE_A_Callback(hObject, eventdata, handles)

function L0B_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TC0_VOLT_S_Callback(hObject, eventdata, handles)


function TC0_VOLT_A_Callback(hObject, eventdata, handles)

function TC0_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TC0_PHASE_S_Callback(hObject, eventdata, handles)


function TC0_PHASE_A_Callback(hObject, eventdata, handles)

function TC0_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L1S_VOLT_S_Callback(hObject, eventdata, handles)


function L1S_VOLT_A_Callback(hObject, eventdata, handles)

function L1S_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L1S_PHASE_S_Callback(hObject, eventdata, handles)


function L1S_PHASE_A_Callback(hObject, eventdata, handles)

function L1S_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L1X_VOLT_S_Callback(hObject, eventdata, handles)


function L1X_VOLT_A_Callback(hObject, eventdata, handles)

function L1X_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function L1X_PHASE_S_Callback(hObject, eventdata, handles)


function L1X_PHASE_A_Callback(hObject, eventdata, handles)

function L1X_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LSR_PHASE_A_Callback(hObject, eventdata, handles)

function LSR_PHASE_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LSR_VOLT_A_Callback(hObject, eventdata, handles)

function LSR_VOLT_A_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function STARTSTOP_Callback(hObject, eventdata, handles)
% AIDA-PVA imports
global pvaRequest;
global AIDA_STRING;

tags={'Start' 'Stop'};
colr={'green' 'white '};
set(hObject,'String',tags{get(hObject,'Value')+1});
set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});
while get(hObject,'Value')
  try
    set(handles.MSG,'String',' ')
    data = lcaGetSmart(handles.pv_list(:,1),0,'double');
    if any(isnan(data));
      set(handles.MSG,'String','lcaGet error on one or more PVs')
      drawnow
      pause(1)
    end
  catch
    set(handles.MSG,'String','lcaGet error on one or more PVs')
    drawnow
    pause(1)
%    data = zeros(size(handles.pv_list(:,1)));
  end
  for j=1:handles.Nsystems
    Hcolr = 'green';
    Vcolr = 'green';
    Pcolr = 'green';
    Fcolr = 'green';
    Fstr  = 'ON';
    Scolr = 'green';
    Sstr  = 'OK';
    pact  = data(8*(j-1)+3);
    pdes  = data(8*(j-1)+4);
    pactn = mod(pact + 180 - pdes, 360) - 180 + pdes;
    if abs(data(8*(j-1)+1) - data(8*(j-1)+2)) > handles.AmpTols(j)
      Vcolr = 'red';
      Hcolr = 'red';
    end
%    if abs(data(8*(j-1)+3) - data(8*(j-1)+4)) > handles.PhaseTols(j)
    if abs(pactn - data(8*(j-1)+4)) > handles.PhaseTols(j)
      Pcolr = 'red';
      Hcolr = 'red';
    end
    if data(8*(j-1)+5)~=1 | data(8*(j-1)+6)~=1 | data(8*(j-1)+7)~=0
      Fstr = 'OFF';
      Fcolr = 'red';
      Hcolr = 'red';
    end
    if data(8*(j-1)+8)>=32767
      Scolr = 'red';
      Sstr  = 'saturated';
      Hcolr = 'red';
    end
    cmnd = ['set(handles.' handles.SysNames(j,:) ',''HighlightColor'',Hcolr)'];
    eval(cmnd)
    cmnd = ['set(handles.' handles.SysNames(j,:) '_VOLT_A,''String'',num2str(data(8*(j-1)+1),''%5.2f''))'];
    eval(cmnd)
    cmnd = ['set(handles.' handles.SysNames(j,:) '_VOLT_A,''ForegroundColor'',Vcolr)'];
    eval(cmnd)
    cmnd = ['set(handles.' handles.SysNames(j,:) '_VOLT_S,''String'',num2str(data(8*(j-1)+2),''%5.2f''))'];
    eval(cmnd)
%    cmnd = ['set(handles.' handles.SysNames(j,:) '_PHASE_A,''String'',num2str(data(8*(j-1)+3),''%5.2f''))'];
    cmnd = ['set(handles.' handles.SysNames(j,:) '_PHASE_A,''String'',num2str(pactn,''%5.2f''))'];
    eval(cmnd)
    cmnd = ['    set(handles.' handles.SysNames(j,:) '_PHASE_A,''ForegroundColor'',Pcolr)'];
    eval(cmnd)
    cmnd = ['    set(handles.' handles.SysNames(j,:) '_PHASE_S,''String'',num2str(data(8*(j-1)+4),''%5.2f''))'];
    eval(cmnd)
    cmnd = ['   set(handles.' handles.SysNames(j,:) '_FDBK,''String'',Fstr)'];
    eval(cmnd)
    cmnd = ['   set(handles.' handles.SysNames(j,:) '_FDBK,''ForegroundColor'',Fcolr)'];
    eval(cmnd)
    cmnd = ['    set(handles.' handles.SysNames(j,:) '_STATUS,''String'',Sstr)'];
    eval(cmnd)
    cmnd = ['    set(handles.' handles.SysNames(j,:) '_STATUS,''ForegroundColor'',Scolr)'];
    eval(cmnd)
  end
  for j = 1:handles.Nklys
    try
      set(handles.MSG,'String',' ')
      requestBuilder = pvaRequest(handles.klys_pv_list(j,1));
      requestBuilder.returning(AIDA_STRING);
      requestBuilder.with('BEAM',1);
      actstr = requestBuilder.get();  % returns 'activated' when on beam code #1 (LCLS)
    catch
      set(handles.MSG,'String','aidaGet error on klys PV list')
      drawnow
      pause(1)
      actstr = '?';
    end
    if strcmp(actstr,'deactivated');
      if j == 1
        Acolr = 'blue';
        Astr = 'DEACT';
      else
        Acolr = 'red';
        Astr = 'DEACT';
      end
    else
      if j == 1
        Acolr = 'yellow';
        Astr  = 'ACT';
      else
        Acolr = 'green';
        Astr  = 'ACT';
      end
    end
    cmnd = ['set(handles.' handles.KlysNames(j,:) '_ACT,''String'',Astr)'];
    eval(cmnd)
    cmnd = ['set(handles.' handles.KlysNames(j,:) '_ACT,''ForegroundColor'',Acolr)'];
    eval(cmnd)
  end
clc
clc
tstr = get_time;
  set(hObject,'BackgroundColor','green');
  pause(0.2)
  set(hObject,'BackgroundColor','white');
  set(handles.DATE_TIME,'String',tstr)
  pause(1.8)
  guidata(hObject,handles);
end
set(hObject,'BackgroundColor','green');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
% exit from Matlab when not running the desktop
if usejava('desktop')
    % don't exit from Matlab
else
    exit
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('firefox https::confluence.slac.stanford.edu/display/LCLSHELP/RF+Status+GUI')

