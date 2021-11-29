function varargout = collimator_GUI(varargin)
% COLLIMATOR_GUI M-file for collimator_GUI.fig
%      COLLIMATOR_GUI, by itself, creates a new COLLIMATOR_GUI or raises the existing
%      singleton*.
%
%      H = COLLIMATOR_GUI returns the handle to a new COLLIMATOR_GUI or the handle to
%      the existing singleton*.
%
%      COLLIMATOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLLIMATOR_GUI.M with the given input arguments.
%
%      COLLIMATOR_GUI('Property','Value',...) creates a new COLLIMATOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before collimator_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to collimator_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help collimator_GUI

% Last Modified by GUIDE v2.5 27-Sep-2010 11:56:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @collimator_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @collimator_GUI_OutputFcn, ...
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


% --- Executes just before collimator_GUI is made visible.
function collimator_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to collimator_GUI (see VARARGIN)

% Choose default command line output for collimator_GUI
handles.output = hObject;

handles.fakedata = 0;
handles.command_str =  ['Move          '
                        'Open full     '
                        'Open to 20 mm '
                        'Open by  4 mm '
                        'Open by  2 mm '
                        'Open by  1 mm '
                        'Open by 0.1 mm'
                        'Close by 0.1mm'
                        'Close by 1 mm '
                        'Close by 2 mm '
                        'Close by 4 mm '
                        'Set to nominal'
                                        ];
set(handles.MOVE_LINAC_COLLS,'String',['Move 29-30    '; handles.command_str(2:end,:)])
set(handles.MOVE_ECOLLS,     'String',['Move E-colls  '; handles.command_str(2:end,:)])
set(handles.MOVE_LTU_COLLS,  'String',['Move LTU      '; handles.command_str(2:end,:)])
set(handles.MOVE_E_AND_LTU,  'String',['Move E&LTU    '; handles.command_str(2:end,:)])
set(handles.MOVE_ALL_COLLS,  'String',['Move ALL      '; handles.command_str(2:end,:)])

%{
handles.xcollL_pvs = {'LI29:STEP:96'   'COLL:LI29:96'
                      'LI29:STEP:146'  'COLL:LI29:146'
                      'LI29:STEP:446'  'COLL:LI29:446'
                      'LI29:STEP:546'  'COLL:LI29:546'
                      'LI30:STEP:96'   'COLL:LI30:96'
                      'LI30:STEP:146'  'COLL:LI30:146'
                      'LI30:STEP:446'  'COLL:LI30:446'
                      'LI30:STEP:546'  'COLL:LI30:546'};

handles.xcollR_pvs = {'LI29:STEP:97'   'COLL:LI29:97'
                      'LI29:STEP:147'  'COLL:LI29:147'
                      'LI29:STEP:447'  'COLL:LI29:447'
                      'LI29:STEP:547'  'COLL:LI29:547'
                      'LI30:STEP:97'   'COLL:LI30:97'
                      'LI30:STEP:147'  'COLL:LI30:147'
                      'LI30:STEP:447'  'COLL:LI30:447'
                      'LI30:STEP:547'  'COLL:LI30:547'};

handles.ycollT_pvs = {'LI29:STEP:98'   'COLL:LI29:98'
                      'LI29:STEP:148'  'COLL:LI29:148'
                      'LI29:STEP:448'  'COLL:LI29:448'
                      'LI29:STEP:548'  'COLL:LI29:548'
                      'LI30:STEP:98'   'COLL:LI30:98'
                      'LI30:STEP:148'  'COLL:LI30:148'
                      'LI30:STEP:448'  'COLL:LI30:448'
                      'LI30:STEP:548'  'COLL:LI30:548'};

handles.ycollB_pvs = {'LI29:STEP:99'   'COLL:LI29:99'
                      'LI29:STEP:149'  'COLL:LI29:149'
                      'LI29:STEP:449'  'COLL:LI29:449'
                      'LI29:STEP:549'  'COLL:LI29:549'
                      'LI30:STEP:99'   'COLL:LI30:99'
                      'LI30:STEP:149'  'COLL:LI30:149'
                      'LI30:STEP:449'  'COLL:LI30:449'
                      'LI30:STEP:549'  'COLL:LI30:549'};
%}

handles.xcollL_pvs = {'COLL:LI28:916'
                      'COLL:LI29:146'
                      'COLL:LI29:446'
                      'COLL:LI29:546'
                      'COLL:LI29:956'
                      'COLL:LI30:146'
                      'COLL:LI30:446'
                      'COLL:LI30:546'};

handles.xcollR_pvs = {'COLL:LI28:917'
                      'COLL:LI29:147'
                      'COLL:LI29:447'
                      'COLL:LI29:547'
                      'COLL:LI29:957'
                      'COLL:LI30:147'
                      'COLL:LI30:447'
                      'COLL:LI30:547'};

handles.ycollT_pvs = {'COLL:LI28:918'
                      'COLL:LI29:148'
                      'COLL:LI29:448'
                      'COLL:LI29:548'
                      'COLL:LI29:958'
                      'COLL:LI30:148'
                      'COLL:LI30:448'
                      'COLL:LI30:548'};

handles.ycollB_pvs = {'COLL:LI28:919'
                      'COLL:LI29:149'
                      'COLL:LI29:449'
                      'COLL:LI29:549'
                      'COLL:LI29:959'
                      'COLL:LI30:149'
                      'COLL:LI30:449'
                      'COLL:LI30:549'};

handles.coll_zs = [ 2842.504
                    2856.748
                    2893.781
                    2906.126
                    2945.218
                    2958.253
                    2995.274
                    3007.633];

%Nominal collimator jaw settings basd on: http://www-ssrl.slac.stanford.edu/lcls/prd/1.3-017-ro.pdf:
%==================================================================================================
handles.xcollL_nom = [-1.6   %'COLL:LI29:96'
                      -1.6   %'COLL:LI29:146'
                      -1.6   %'COLL:LI29:446'
                      -1.6   %'COLL:LI29:546'
                      -1.8   %'COLL:LI30:96'
                      -1.8   %'COLL:LI30:146'
                      -1.8   %'COLL:LI30:446'
                      -1.8]; %'COLL:LI30:546'};

handles.xcollR_nom = [+1.6   % 'COLL:LI29:97'
                      +1.6   % 'COLL:LI29:147'
                      +1.6   % 'COLL:LI29:447'
                      +1.6   % 'COLL:LI29:547'
                      +1.8   % 'COLL:LI30:97'
                      +1.8   % 'COLL:LI30:147'
                      +1.8   % 'COLL:LI30:447'
                      +1.8]; % 'COLL:LI30:547'};

handles.ycollT_nom = [+1.6   % 'COLL:LI29:98'
                      +1.6   % 'COLL:LI29:148'
                      +1.6   % 'COLL:LI29:448'
                      +1.6   % 'COLL:LI29:548'
                      +1.8   % 'COLL:LI30:98'
                      +1.8   % 'COLL:LI30:148'
                      +1.8   % 'COLL:LI30:448'
                      +1.8]; % 'COLL:LI30:548'};

handles.ycollB_nom = [-1.6   % 'COLL:LI29:99'
                      -1.6   % 'COLL:LI29:149'
                      -1.6   % 'COLL:LI29:449'
                      -1.6   % 'COLL:LI29:549'
                      -1.8   % 'COLL:LI30:99'
                      -1.8   % 'COLL:LI30:149'
                      -1.8   % 'COLL:LI30:449'
                      -1.8]; % 'COLL:LI30:549'};

handles.EcollL_nom  = [-2.5   %'COLL:LTU1:253'
                       -2.5]; %'COLL:LTU1:453'};
handles.EcollR_nom  = [+2.5   %'COLL:LTU1:252'
                       +2.5]; %'COLL:LTU1:452'};
handles.xBcollL_nom = [-2.2   %'COLL:LTU1:723'
                       -2.2]; %'COLL:LTU1:763'};
handles.xBcollR_nom = [+2.2   %'COLL:LTU1:722'
                       +2.2]; %'COLL:LTU1:762'};
handles.yBcollR_nom = [+2.2   %'COLL:LTU1:732'
                       +2.2]; %'COLL:LTU1:772'};
handles.yBcollL_nom = [-2.2   %'COLL:LTU1:733'
                       -2.2]; %'COLL:LTU1:773'};
                    
handles.EcollL_pvs = {'COLL:LTU1:253'
                      'COLL:LTU1:453'};
handles.EcollR_pvs = {'COLL:LTU1:252'
                      'COLL:LTU1:452'};
                     
handles.Ecoll_zs  = [3272.466
                     3344.080];

handles.xBcollL_pvs = {'COLL:LTU1:723'
                       'COLL:LTU1:763'};
handles.xBcollR_pvs = {'COLL:LTU1:722'
                       'COLL:LTU1:762'};
                     
handles.xBcoll_zs  = [3434.112
                      3504.639];

handles.yBcollL_pvs = {'COLL:LTU1:732'
                       'COLL:LTU1:772'};
handles.yBcollR_pvs = {'COLL:LTU1:733'
                       'COLL:LTU1:773'};
                     
handles.yBcoll_zs  = [3451.744
                      3522.270];

handles.LinacBPM_pvs = {'BPMS:LI28:901'
                        'BPMS:LI29:201'
                        'BPMS:LI29:301'
                        'BPMS:LI29:401'
                        'BPMS:LI29:501'
                        'BPMS:LI29:601'
                        'BPMS:LI29:701'
                        'BPMS:LI29:801'
                        'BPMS:LI29:901'
                        'BPMS:LI30:201'
                        'BPMS:LI30:301'
                        'BPMS:LI30:401'
                        'BPMS:LI30:501'
                        'BPMS:LI30:601'
                        'BPMS:LI30:701'};

%{
handles.LinacBPM_zs =  [2842.115
                        2857.064
                        2869.408
                        2881.753
                        2894.097
                        2906.442
                        2918.786
                        2931.130
                        2943.794
                        2958.664
                        2971.008
                        2983.353
                        2995.697
                        3007.840
                        3020.200];
%}

handles.LinacBPM_zs =  model_rMatGet(handles.LinacBPM_pvs,[],{},'Z') + 2014.702;

handles.LTUBPM_pvs = {'BPMS:LTU0:190'
                      'BPMS:LTU1:250'
                      'BPMS:LTU1:290'
                      'BPMS:LTU1:350'
                      'BPMS:LTU1:390'
                      'BPMS:LTU1:450'
                      'BPMS:LTU1:490'
                      'BPMS:LTU1:680'
                      'BPMS:LTU1:720'
                      'BPMS:LTU1:730'
                      'BPMS:LTU1:740'
                      'BPMS:LTU1:750'
                      'BPMS:LTU1:760'
                      'BPMS:LTU1:770'
                      'BPMS:LTU1:820'};
                    
handles.LTUBPM_zs =  model_rMatGet(handles.LTUBPM_pvs,[],{},'Z') + 2014.702;

handles.BLM_pvs = {'BLM:LTU1:722:LOSS'
                   'BLM:LTU1:732:LOSS'
                   'BLM:LTU1:762:LOSS'
                   'BLM:LTU1:772:LOSS'};

handles.BLM_zs = [3434.112
                  3451.744
                  3504.639
                  3522.270];

handles.dx = (handles.coll_zs(end) - handles.coll_zs(1))/30;
handles.dy = 10;
handles.xymax = str2double(get(handles.XYMAX,'String'));
util_appFonts(hObject,'fontName','Times','fontSize',16,'lineWidth',2,'markerSize',8);
guidata(hObject, handles);

% UIWAIT makes collimator_GUI wait for user response (see UIRESUME)
% uiwait(handles.collimator_GUI);



% --- Outputs from this function are returned to the command line.
function varargout = collimator_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes when user attempts to close collimator_GUI.
function collimator_GUI_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);



function MOVE_ALL_COLLS_Callback(hObject, eventdata, handles)
icoll = get(hObject,'Value');
set(handles.MSG,'String','WAIT...')
set(handles.MSG,'ForegroundColor','red')
set(handles.MSG,'FontWeight','bold')
drawnow
move_linac_collimators(handles,icoll)
move_energy_collimators(handles,icoll)
move_LTU_collimators(handles,icoll)
set(handles.MSG,'String','READY')
set(handles.MSG,'ForegroundColor','green')
set(handles.MSG,'FontWeight','normal')
drawnow

function MOVE_ALL_COLLS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MOVE_LINAC_COLLS_Callback(hObject, eventdata, handles)
icoll = get(hObject,'Value');
set(handles.MSG,'String','WAIT...')
set(handles.MSG,'ForegroundColor','red')
set(handles.MSG,'FontWeight','bold')
drawnow
move_linac_collimators(handles,icoll)
set(handles.MSG,'String','READY')
set(handles.MSG,'ForegroundColor','green')
set(handles.MSG,'FontWeight','normal')
drawnow

function MOVE_LINAC_COLLS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MOVE_ECOLLS_Callback(hObject, eventdata, handles)
icoll = get(hObject,'Value');
set(handles.MSG,'String','WAIT...')
set(handles.MSG,'ForegroundColor','red')
set(handles.MSG,'FontWeight','bold')
drawnow
move_energy_collimators(handles,icoll)
set(handles.MSG,'String','READY')
set(handles.MSG,'ForegroundColor','green')
set(handles.MSG,'FontWeight','normal')
drawnow

function MOVE_ECOLLS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MOVE_LTU_COLLS_Callback(hObject, eventdata, handles)
icoll = get(hObject,'Value');
set(handles.MSG,'String','WAIT...')
set(handles.MSG,'ForegroundColor','red')
set(handles.MSG,'FontWeight','bold')
drawnow
move_LTU_collimators(handles,icoll)
set(handles.MSG,'String','READY')
set(handles.MSG,'ForegroundColor','green')
set(handles.MSG,'FontWeight','normal')
drawnow

function MOVE_LTU_COLLS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XYMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MOVE_E_AND_LTU_Callback(hObject, eventdata, handles)
icoll = get(hObject,'Value');
set(handles.MSG,'String','WAIT...')
set(handles.MSG,'ForegroundColor','red')
set(handles.MSG,'FontWeight','bold')
drawnow
move_energy_collimators(handles,icoll)
move_LTU_collimators(handles,icoll)
set(handles.MSG,'String','READY')
set(handles.MSG,'ForegroundColor','green')
set(handles.MSG,'FontWeight','normal')
drawnow

function MOVE_E_AND_LTU_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%{
function move_linac_collimators(handles,icoll)
PVLs = [handles.xcollL_pvs(:,1); handles.xcollR_pvs(:,1); handles.ycollT_pvs(:,1); handles.ycollB_pvs(:,1)];
vmax = lcaGetSmart(strcat(PVLs,':VMAX'));
if icoll == 1                   % do nothing
  return
end
if icoll == 2                   % open full
  half_gaps = vmax*0.95;
end
if icoll == 3                   % open to 20-mm gaps (or as close as possible)
  half_gaps = min([10 min(abs(vmax*0.95))]).*sign(vmax).*ones(size(PVLs));     % desired full gap size (mm)
end
if icoll == 4
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 + 4/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 5
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 + 2/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 6
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 + 1/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 7
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 + 0.1/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 8
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 - 0.1/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 9
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 - 1/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 10
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 - 2/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 11
  half_gaps0 = control_magnetGet(PVLs);
  half_gaps = half_gaps0 - 4/2*sign(vmax); % desired full gap size (mm)
end
if icoll == 12                  % set nominal gaps
  half_gaps = [handles.xcollL_nom; handles.xcollR_nom; handles.ycollT_nom; handles.ycollB_nom];
end
if ~handles.fakedata
  control_magnetSet(PVLs,half_gaps);
end



function move_energy_collimators(handles,icoll)
PVs = strcat(handles.EcollR_pvs,':SETGAP');
if icoll == 1               % do nothing
  return
end
if icoll == 2               % open full
  PVL = strcat(handles.EcollL_pvs,':MOTR.LLM');
  PVR = strcat(handles.EcollR_pvs,':MOTR.HLM');
  lolim = lcaGetSmart(PVL);
  hilim = lcaGetSmart(PVR);
  gap = (hilim - lolim);   % desired full gap size (mm)
end
if icoll == 3              % open to 20 mm
  gap = 20;                % desired full gap size (mm)
end
if icoll == 4
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 4;          % desired full gap size (mm)
end
if icoll == 5
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 2;   % desired full gap size (mm)
end
if icoll == 6
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 1;   % desired full gap size (mm)
end
if icoll == 7
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 0.1;   % desired full gap size (mm)
end
if icoll == 8
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 0.1;   % desired full gap size (mm)
end
if icoll == 9
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 1;   % desired full gap size (mm)
end
if icoll == 10
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 2;   % desired full gap size (mm)
end
if icoll == 11
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 4;   % desired full gap size (mm)
end
if icoll == 12      % do nothing yet
  gap = 2*[handles.EcollR_nom];
end
if ~handles.fakedata
  lcaPutSmart(PVs,gap)
end



function move_LTU_collimators(handles,icoll)
PVs = [strcat(handles.xBcollR_pvs,':SETGAP'); strcat(handles.yBcollL_pvs,':SETGAP')];
if icoll == 1               % do nothing
  return
end
if icoll == 2               % open full
  PVLx = strcat(handles.xBcollL_pvs,':MOTR.LLM');
  PVRx = strcat(handles.xBcollR_pvs,':MOTR.HLM');
  PVLy = strcat(handles.yBcollL_pvs,':MOTR.LLM');
  PVRy = strcat(handles.yBcollR_pvs,':MOTR.HLM');
  lolimx = lcaGetSmart(PVLx);
  hilimx = lcaGetSmart(PVRx);
  lolimy = lcaGetSmart(PVLy);
  hilimy = lcaGetSmart(PVRy);
  gap = [(hilimx - lolimx); (hilimy - lolimy)];   % desired full gap size (mm)
end
if icoll == 3               % open to 20 mm
  gap = [20 20 20 20]';     % desired full gap size (mm)
end
if icoll == 4
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 4;           % desired full gap size (mm)
end
if icoll == 5
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 2;           % desired full gap size (mm)
end
if icoll == 6
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 1;           % desired full gap size (mm)
end
if icoll == 7
  gap0 = lcaGetSmart(PVs);
  gap = gap0 + 0.1;           % desired full gap size (mm)
end
if icoll == 8
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 0.1;           % desired full gap size (mm)
end
if icoll == 9
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 1;   % desired full gap size (mm)
end
if icoll == 10
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 2;   % desired full gap size (mm)
end
if icoll == 11
  gap0 = lcaGetSmart(PVs);
  gap = gap0 - 4;   % desired full gap size (mm)
end
if icoll == 12      % set nominal gaps
  gap = 2*[handles.xBcollR_nom; handles.yBcollR_nom];
end
if ~handles.fakedata
  lcaPutSmart(PVs,gap)
end
%}

function move_linac_collimators(handles,icoll)
move_collimators(handles,icoll, ...
    [handles.xcollL_pvs;handles.ycollT_pvs], ...
    [handles.xcollL_pvs;handles.ycollB_pvs], ...
    [handles.xcollR_pvs;handles.ycollT_pvs], ...
    [handles.xcollR_nom;handles.ycollT_nom]);



function move_energy_collimators(handles,icoll)
move_collimators(handles,icoll, ...
    handles.EcollR_pvs, ...
    handles.EcollL_pvs, ...
    handles.EcollR_pvs, ...
    handles.EcollR_nom);



function move_LTU_collimators(handles,icoll)
move_collimators(handles,icoll, ...
    [handles.xBcollR_pvs;handles.yBcollL_pvs], ...
    [handles.xBcollL_pvs;handles.yBcollL_pvs], ...
    [handles.xBcollR_pvs;handles.yBcollR_pvs], ...
    [handles.xBcollR_nom;handles.yBcollR_nom]);



function move_collimators(handles, icoll, pvsgap, pvsl, pvsr, nom)
PVs = strcat(pvsgap,':SETGAP');
gap0 = lcaGetSmart(PVs);
switch icoll
    case 1               % do nothing
        return
    case 2               % open full
        PVL = strcat(pvsl,':MOTR.LLM');
        PVR = strcat(pvsr,':MOTR.HLM');
        lolim = lcaGetSmart(PVL);
        hilim = lcaGetSmart(PVR);
        gap = hilim - lolim;      % desired full gap size (mm)
    case 3               % open to 20 mm
        gap = 20;                 % desired full gap size (mm)
    case 4
        gap = gap0 + 4;           % desired full gap size (mm)
    case 5
        gap = gap0 + 2;           % desired full gap size (mm)
    case 6
        gap = gap0 + 1;           % desired full gap size (mm)
    case 7
        gap = gap0 + 0.1;         % desired full gap size (mm)
    case 8
        gap = gap0 - 0.1;         % desired full gap size (mm)
    case 9
        gap = gap0 - 1;           % desired full gap size (mm)
    case 10
        gap = gap0 - 2;           % desired full gap size (mm)
    case 11
        gap = gap0 - 4;           % desired full gap size (mm)
    case 12              % set nominal gaps
        gap = 2*nom;
end
if ~handles.fakedata
    lcaPutSmart(PVs,gap)
end



function ELOG_Callback(hObject, eventdata, handles)
plot_collimators(1,hObject,handles)
util_printLog(1);



% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
tags={'Start' 'Stop'};
colr={'green' 'red '};
set(hObject,'String',tags{get(hObject,'Value')+1});
set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});
while get(hObject,'Value')
  handles.E0 = lcaGetSmart('BEND:DMP1:400:BDES');

%{
  handles.xcollL_des  = lcaGetSmart(strcat(handles.xcollL_pvs(:,1),':VACT'));
  handles.xcollR_des  = lcaGetSmart(strcat(handles.xcollR_pvs(:,1),':VACT'));
  handles.ycollT_des  = lcaGetSmart(strcat(handles.ycollT_pvs(:,1),':VACT'));
  handles.ycollB_des  = lcaGetSmart(strcat(handles.ycollB_pvs(:,1),':VACT'));
%}
  handles.xcollL_des  = lcaGetSmart(strcat(handles.xcollL_pvs,':LVPOS'));
  handles.xcollR_des  = lcaGetSmart(strcat(handles.xcollR_pvs,':LVPOS'));
  handles.ycollT_des  = lcaGetSmart(strcat(handles.ycollT_pvs,':LVPOS'));
  handles.ycollB_des  = lcaGetSmart(strcat(handles.ycollB_pvs,':LVPOS'));
  handles.EcollL_des  = lcaGetSmart(strcat(handles.EcollL_pvs,':LVPOS'));
  handles.EcollR_des  = lcaGetSmart(strcat(handles.EcollR_pvs,':LVPOS'));
  handles.xBcollL_des = lcaGetSmart(strcat(handles.xBcollL_pvs,':LVPOS'));
  handles.xBcollR_des = lcaGetSmart(strcat(handles.xBcollR_pvs,':LVPOS'));
  handles.yBcollL_des = lcaGetSmart(strcat(handles.yBcollL_pvs,':LVPOS'));
  handles.yBcollR_des = lcaGetSmart(strcat(handles.yBcollR_pvs,':LVPOS'));
  handles.LinacBPMX   = lcaGetSmart(strcat(handles.LinacBPM_pvs,':X'));
  handles.LinacBPMY   = lcaGetSmart(strcat(handles.LinacBPM_pvs,':Y'));
  handles.LTUBPMX     = lcaGetSmart(strcat(handles.LTUBPM_pvs,':X'));
  handles.LTUBPMY     = lcaGetSmart(strcat(handles.LTUBPM_pvs,':Y'));

%{
  handles.xcollL_lo  = lcaGetSmart(strcat(handles.xcollL_pvs(:,2),':VACT.LOW'));
  handles.xcollL_hi  = lcaGetSmart(strcat(handles.xcollL_pvs(:,2),':VACT.HIGH'));
  handles.xcollR_lo  = lcaGetSmart(strcat(handles.xcollR_pvs(:,2),':VACT.LOW'));
  handles.xcollR_hi  = lcaGetSmart(strcat(handles.xcollR_pvs(:,2),':VACT.HIGH'));
  handles.ycollT_lo  = lcaGetSmart(strcat(handles.ycollT_pvs(:,2),':VACT.LOW'));
  handles.ycollT_hi  = lcaGetSmart(strcat(handles.ycollT_pvs(:,2),':VACT.HIGH'));
  handles.ycollB_lo  = lcaGetSmart(strcat(handles.ycollB_pvs(:,2),':VACT.LOW'));
  handles.ycollB_hi  = lcaGetSmart(strcat(handles.ycollB_pvs(:,2),':VACT.HIGH'));
%}

  handles.xcollL_lo  = lcaGetSmart(strcat(handles.xcollL_pvs,':LVPOS.LOW'));
  handles.xcollL_hi  = lcaGetSmart(strcat(handles.xcollL_pvs,':LVPOS.HIGH'));
  handles.xcollR_lo  = lcaGetSmart(strcat(handles.xcollR_pvs,':LVPOS.LOW'));
  handles.xcollR_hi  = lcaGetSmart(strcat(handles.xcollR_pvs,':LVPOS.HIGH'));
  handles.ycollT_lo  = lcaGetSmart(strcat(handles.ycollT_pvs,':LVPOS.LOW'));
  handles.ycollT_hi  = lcaGetSmart(strcat(handles.ycollT_pvs,':LVPOS.HIGH'));
  handles.ycollB_lo  = lcaGetSmart(strcat(handles.ycollB_pvs,':LVPOS.LOW'));
  handles.ycollB_hi  = lcaGetSmart(strcat(handles.ycollB_pvs,':LVPOS.HIGH'));

  handles.EcollL_lo  = lcaGetSmart(strcat(handles.EcollL_pvs,':LVPOS.LOW'));
  handles.EcollL_hi  = lcaGetSmart(strcat(handles.EcollL_pvs,':LVPOS.HIGH'));
  handles.EcollR_lo  = lcaGetSmart(strcat(handles.EcollR_pvs,':LVPOS.LOW'));
  handles.EcollR_hi  = lcaGetSmart(strcat(handles.EcollR_pvs,':LVPOS.HIGH'));
  handles.xBcollL_lo = lcaGetSmart(strcat(handles.xBcollL_pvs,':LVPOS.LOW'));
  handles.xBcollR_lo = lcaGetSmart(strcat(handles.xBcollR_pvs,':LVPOS.LOW'));
  handles.yBcollL_lo = lcaGetSmart(strcat(handles.yBcollL_pvs,':LVPOS.LOW'));
  handles.yBcollR_lo = lcaGetSmart(strcat(handles.yBcollR_pvs,':LVPOS.LOW'));
  handles.xBcollL_hi = lcaGetSmart(strcat(handles.xBcollL_pvs,':LVPOS.HIGH'));
  handles.xBcollR_hi = lcaGetSmart(strcat(handles.xBcollR_pvs,':LVPOS.HIGH'));
  handles.yBcollL_hi = lcaGetSmart(strcat(handles.yBcollL_pvs,':LVPOS.HIGH'));
  handles.yBcollR_hi = lcaGetSmart(strcat(handles.yBcollR_pvs,':LVPOS.HIGH'));

  handles.BLM = lcaGetSmart(handles.BLM_pvs);
  guidata(hObject,handles);

  plot_collimators(0,hObject,handles)

  pause(3)
  handles=guidata(hObject);
end


function plot_collimators(Elog_fig, hObject, handles)
if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(3,1,1);
  ax2 = subplot(3,1,2);
  ax3 = subplot(3,1,3);
else
  ax1 = handles.AXES1;
  ax2 = handles.AXES2;
  ax3 = handles.AXES3;
end

hold(ax1,'off');
plot(handles.coll_zs+handles.dx/2,handles.coll_zs*0,'.w','Parent',ax1)
hold(ax1,'on');
plotJaws(handles,ax1,handles.coll_zs,handles.xcollR_des,handles.xcollR_hi,handles.xcollR_lo,handles.xcollR_nom,'b',0);
plotJaws(handles,ax1,handles.coll_zs,handles.xcollL_des,handles.xcollL_hi,handles.xcollL_lo,handles.xcollL_nom,'b',1);
plotJaws(handles,ax1,handles.Ecoll_zs,handles.EcollR_des,handles.EcollR_hi,handles.EcollR_lo,handles.EcollR_nom,'b',0);
plotJaws(handles,ax1,handles.Ecoll_zs,handles.EcollL_des,handles.EcollL_hi,handles.EcollL_lo,handles.EcollL_nom,'b',1);
plotJaws(handles,ax1,handles.xBcoll_zs,handles.xBcollR_des,handles.xBcollR_hi,handles.xBcollR_lo,handles.xBcollR_nom,'b',0);
plotJaws(handles,ax1,handles.xBcoll_zs,handles.xBcollL_des,handles.xBcollL_hi,handles.xBcollL_lo,handles.xBcollL_nom,'b',1);
z=[handles.LinacBPM_zs handles.LTUBPM_zs];
x=[handles.LinacBPMX' handles.LTUBPMX'];
plot([1;1]*z,[0;1]*x,'g','LineWidth',4,'Parent',ax1)
plot(z,0*z,'.k','Parent',ax1)
%plot([1;1]*handles.LinacBPM_zs',[0;1]*handles.LinacBPMX','g','LineWidth',4,'Parent',ax1)
%plot(handles.LinacBPM_zs',0*handles.LinacBPM_zs','.k','Parent',ax1)
%plot([1;1]*handles.LTUBPM_zs,[0;1]*handles.LTUBPMX','g','LineWidth',4,'Parent',ax1)
%plot(handles.LTUBPM_zs,0*handles.LTUBPM_zs','.k','Parent',ax1)
ylim(ax1,[-handles.xymax handles.xymax])
plot(get(ax1,'XLim'),[0 0],'k--','Parent',ax1);
title(ax1,[get_time sprintf(' (%5.2f GeV)',handles.E0)])
ylabel(ax1,'X (mm)')

hold(ax2,'off');
plot(handles.coll_zs+handles.dx/2,handles.coll_zs*0,'.w','Parent',ax2)
hold(ax2,'on');
plotJaws(handles,ax2,handles.coll_zs,handles.ycollT_des,handles.ycollT_hi,handles.ycollT_lo,handles.ycollT_nom,'c',0);
plotJaws(handles,ax2,handles.coll_zs,handles.ycollB_des,handles.ycollB_hi,handles.ycollB_lo,handles.ycollB_nom,'c',1);
plotJaws(handles,ax2,handles.yBcoll_zs,handles.yBcollR_des,handles.yBcollR_hi,handles.yBcollR_lo,handles.yBcollR_nom,'c',0);
plotJaws(handles,ax2,handles.yBcoll_zs,handles.yBcollL_des,handles.yBcollL_hi,handles.yBcollL_lo,handles.yBcollL_nom,'c',1);
y=[handles.LinacBPMY' handles.LTUBPMY'];
plot([1;1]*z,[0;1]*y,'g','LineWidth',4,'Parent',ax2)
plot(z,0*z,'.k','Parent',ax2)
%plot([1;1]*handles.LinacBPM_zs',[0;1]*handles.LinacBPMY','g','LineWidth',4,'Parent',ax2)
%plot(handles.LinacBPM_zs',0*handles.LinacBPM_zs','.k','Parent',ax2)
%plot([1;1]*handles.LTUBPM_zs,[0;1]*handles.LTUBPMY','g','LineWidth',4,'Parent',ax2)
%plot(handles.LTUBPM_zs,0*handles.LTUBPM_zs','.k','Parent',ax2)
ylim(ax2,[-handles.xymax handles.xymax])
plot(get(ax2,'XLim'),[0 0],'k--','Parent',ax2);
ylabel(ax2,'Y (mm)')
xlabel(ax2,'Z (m)')

hold(ax3,'off');
plot([1;1]*handles.BLM_zs',[0;1]*handles.BLM','g','LineWidth',4,'Parent',ax3)
hold(ax3,'on');
plot(handles.BLM_zs',0*handles.BLM_zs','.b','Parent',ax3)
xlim(ax3,get(ax2,'XLim'))
ylim(ax3,[-0.1 0.5])
plot(get(ax3,'XLim'),[0 0],'k--','Parent',ax3);
ylabel(ax3,'Beam Loss (arb)')


function plotJaws(handles, ax, z, des, hi, lo, nom, c, rl)

for j = 1:length(z)
  if des(j) == 0 || hi(j) == 0 && lo(j) == 0, continue, end
  if (des(j) > hi(j)) || (des(j) < lo(j))
    clr = 'r';
    txt_clr = 'red';
  else
    clr = c;
    txt_clr = 'black';
  end
  if ~isnan(des(j))
    rectangle('Position',[z(j) des(j)-rl*handles.dy handles.dx handles.dy],'LineWidth',1,'FaceColor',clr,'Parent',ax)
  end
  if ~isnan(lo(j))
    rectangle('Position',[z(j)-handles.dx/2 lo(j) handles.dx*2 0.0001],'LineWidth',1,'EdgeColor',0.0*[1 1 1],'Parent',ax)
  end
  if ~isnan(hi(j))
    rectangle('Position',[z(j)-handles.dx/2 hi(j) handles.dx*2 0.0001],'LineWidth',1,'EdgeColor',0.0*[1 1 1],'Parent',ax)
  end
  rectangle('Position',[z(j)-handles.dx/2 nom(j) handles.dx*2 0.0001],'LineWidth',1,'EdgeColor','green','Parent',ax)
  if abs(des(j))>handles.xymax
    text(z(j)-handles.dx*1.5,(1-2*rl)*handles.xymax*(0.8 + 0.1*rem(j,2)),sprintf('%5.2f',des(j)),'FontSize',8,'Color',txt_clr,'Parent',ax)
  end
end


function XYMAX_Callback(hObject, eventdata, handles)
handles.xymax = str2double(get(hObject,'String'));
guidata(hObject,handles);
