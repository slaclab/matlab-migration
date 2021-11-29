function varargout = BC_chicane_control(varargin)
% BC_CHICANE_CONTROL M-file for BC_chicane_control.fig
%      BC_CHICANE_CONTROL, by itself, creates a new BC_CHICANE_CONTROL or
%      raises the existing
%      singleton*.
%
%      H = BC_CHICANE_CONTROL returns the handle to a new BC_CHICANE_CONTROL or the handle to
%      the existing singleton*.
%
%      BC_CHICANE_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BC_CHICANE_CONTROL.M with the given input arguments.
%
%      BC_CHICANE_CONTROL('Property','Value',...) creates a new BC_CHICANE_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BC_chicane_control_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BC_chicane_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help BC_chicane_control

% Last Modified by GUIDE v2.5 22-Jul-2014 00:28:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BC_chicane_control_OpeningFcn, ...
                   'gui_OutputFcn',  @BC_chicane_control_OutputFcn, ...
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


% --- Executes just before BC_chicane_control is made visible.
function BC_chicane_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BC_chicane_control (see VARARGIN)

% Choose default command line output for BC_chicane_control
handles.output = hObject;

% Update handles structure
handles.tagQuad={'qBdesLabel_txt' 'qBdes_txt' 'qBdesArrow_txt' 'qBact_txt' 'qBdesUnits_txt'};
handles=gui_objectRepeat(hObject,handles,handles.tagQuad,6);

set(handles.Dave,'CData',imread('DD.bmp'));

handles.panel1Pos0=get(handles.uipanel1,'Position');

handles=appInit(hObject,handles);

guidata(hObject, handles);

% UIWAIT makes BC_chicane_control wait for user response (see UIRESUME)
% uiwait(handles.BC_chicane_control);


% --- Outputs from this function are returned to the command line.
function varargout = BC_chicane_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close BC_chicane_control.
function BC_chicane_control_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of index names
% handles.indexList={'LCLS' {'BCH' 'BC1' 'BC2' 'XLEAP'}; ...
handles.indexList={'LCLS' {'BCH' 'BC1' 'BC2'}; ...
    'FACET' {}; ...
    'NLCTA' {}; ...
    'LCLSII' {'BCHB' 'BC1B' 'BC2B'}; ...
    };

handles.sector.BCH.Xmax = 40;        % max. Xpos (mm)
handles.sector.BCH.Xmin =  0;        % min. Xpos (mm)
handles.sector.BCH.Xnom = 35;        % nom. Xpos (mm)
handles.energy1max = 0.100;  % max. e- energy at QA01/02 (GeV)
handles.energy1min = 0.030;  % min. e- energy at QA01/02 (GeV)
handles.energy1nom = 0.064;  % nom. e- energy at QA01/02 (GeV)
handles.sector.BCH.energymax = 0.200;  % max. e- energy at chicane (GeV)
handles.sector.BCH.energymin = 0.050;  % min. e- energy at chicane (GeV)
handles.sector.BCH.energynom = 0.135;  % nom. e- energy at chicane (GeV)
handles.sector.BCH.R56_pv    = '';         % operating point BC1 R56 target value (mm)
handles.sector.BCH.Energy_pv = '';         % operating point BC1 energy target value (MeV)
handles.sector.BCH.LEM_pv = 'REFS:IN20:751:EDES';

handles.sector.BCH.nQuad={'QA01';'QA02';'QE01';'QE02';'QE03';'QE04'};
handles.sector.BCH.nUse=[1 2:6];
handles.sector.BCH.nTrim={'BXH1_TRIM';'BXH3_TRIM';'BXH4_TRIM'}; % BXH trim coils [main-coil Amperes]
handles.sector.BCH.nCQ={};
handles.sector.BCH.phasePV ='SIOC:SYS0:ML00:AO080'; % beam phase prior to BCH [deg-2856 MHz] (move PDES more neg. if X decreases)
handles.sector.BCH.bendPV  ='BEND:IN20:461';        % BCH chicane main bend [kG-m]
handles.sector.BCH.XMOVD_pv='';
handles.sector.BCH.XMOVA_pv='';
handles.sector.BCH.colors=[0 0 1;0.678 0.922 1;1 1 1];
handles.sector.BCH.fdbkPV  ={'FBCK:INL0:1:ENABLE';'FBCK:INL1:1:ENABLE';'FBCK:IN20:TR01:MODE'};
handles.sector.BCH.nOTR={'OTRH1' 'OTRH2'}; % OTRH1 IN/OUT status PV

handles.sector.BC1.r56max = 65;        % max. R56 (mm) - should be 65 mm, but hits vac. manifiold (4/14/07)
handles.sector.BC1.r56min =  0;        % min. R56 (mm)
handles.sector.BC1.energymax = 0.300;  % max. e- energy (GeV)
handles.sector.BC1.energymin = 0.010;  % min. e- energy (GeV)
handles.sector.BC1.R56_pv    = 'SIOC:SYS0:ML00:AO116';         % operating point BC1 R56 target value (mm)
handles.sector.BC1.Energy_pv = 'SIOC:SYS0:ML00:AO123';         % operating point BC1 energy target value (MeV)
handles.sector.BC1.LEM_pv = 'REFS:LI21:231:EDES';

handles.sector.BC1.nQuad={'QA12';'Q21201';'QM11';'QM12';'QM13'};
handles.sector.BC1.nUse=[1 2 3:5];
handles.sector.BC1.nTrim={'BX11_TRIM';'BX13_TRIM';'BX14_TRIM'};
handles.sector.BC1.nCQ={'CQ11';'CQ12'};
handles.sector.BC1.phasePV ='SIOC:SYS0:ML00:AO060'; % beam phase prior to BC1 [deg-2856 MHz] (move PDES more neg. if |R56| decreases)
handles.sector.BC1.bendPV  ='BEND:LI21:231';        % BC1 chicane main bend [kG-m]
handles.sector.BC1.XMOVD_pv='BMLN:LI21:235:MOTR';   % BC1 chicane stage desired position [mm]
handles.sector.BC1.XMOVA_pv='BMLN:LI21:235:LVPOS';  % BC1 chicane stage actual LVDT position [mm]
handles.sector.BC1.colors=[0.855 0.702 1;0.659 1 0.659;1 1 0];
handles.sector.BC1.fdbkPV  ={ ...
    'FBCK:LNG2:1:ENABLE'; ...          % longitudinal DL1/BC1 energy feedback (0=OFF,1=ON)
    'FBCK:LNG3:1:ENABLE'; ...          % longitudinal DL1/BC1 energy/sigZ feedback (0=OFF,1=ON)
    'SIOC:SYS0:ML00:AO292'; ...        % Joe's longitudinal BC1 energy feedback (0=OFF,1=ON)
    'SIOC:SYS0:ML00:AO293'; ...        % Joe's longitudinal BC1 energy feedback (0=OFF,1=ON)
    'FBCK:FB04:LG01:S2USED'; ...
    'FBCK:FB04:LG01:S3USED'};

handles.sector.BC2.r56max = 50;        % max. R56 (mm)
handles.sector.BC2.r56min =  0;        % min. R56 (mm)
handles.sector.BC2.energymax = 7.000;  % max. e- energy (GeV)
handles.sector.BC2.energymin = 0.100;  % min. e- energy (GeV)
handles.sector.BC2.R56_pv    = 'SIOC:SYS0:ML00:AO119';         % operating point BC2 R56 target value (mm)
handles.sector.BC2.Energy_pv = 'SIOC:SYS0:ML00:AO124';         % operating point BC2 energy target value (GeV)
handles.sector.BC2.LEM_pv = 'REFS:LI24:790:EDES';

handles.sector.BC2.nQuad={'Q24701A';'QM21';'QM22';'Q24901A'};
handles.sector.BC2.nUse=[1:4];
handles.sector.BC2.nTrim={'BX21_TRIM';'BX23_TRIM';'BX24_TRIM'};
handles.sector.BC2.nCQ={'CQ21';'CQ22'};
handles.sector.BC2.phasePV ='SIOC:SYS0:ML00:AO063'; % beam phase prior to BC2 [deg-2856 MHz] (move PDES more neg. if |R56| decreases)
handles.sector.BC2.bendPV  ='BEND:LI24:790';        % BC2 chicane main bend [kG-m]
handles.sector.BC2.XMOVD_pv='BMLN:LI24:805:MOTR';   % BC2 chicane stage desired position [mm]
handles.sector.BC2.XMOVA_pv='BMLN:LI24:805:LVPOS';  % BC2 chicane stage actual LVDT position [mm]
handles.sector.BC2.colors=[0.043 0.518 0.78;0.702 0.78 1;1 1 1];
handles.sector.BC2.fdbkPV  ={ ...
    'SIOC:SYS0:ML00:AO023'; ...       % turn off BC2 energy feedback
    'FBCK:LNG4:1:ENABLE'; ...         % turn off EPICS BC2 energy feedback
    'FBCK:LNG5:1:ENABLE'; ...         % turn off EPICS BC2 energy feedback
    'FBCK:LNG6:1:ENABLE'; ...         % turn off EPICS BC2 energy feedback
    'SIOC:SYS0:ML00:AO294'; ...       % turn off Joe's BC2 energy feedback
    'SIOC:SYS0:ML00:AO295'; ...       % turn off Joe's BC2 energy feedback
    'FBCK:FB04:LG01:S4USED'; ...      % New fast 6x6 feedback
    'FBCK:FB04:LG01:S5USED'; ...      % New fast 6x6 feedback
};

handles.sector.XLEAP.r56max = 1450;        % max. delay (fs) 
handles.sector.XLEAP.r56min =  0;        % min. delay (fs)
handles.sector.XLEAP.energymax = 17.500;  % max. e- energy (GeV)
handles.sector.XLEAP.energymin = 0.100;  % min. e- energy (GeV)
handles.sector.XLEAP.R56_pv    = 'SIOC:SYS0:ML03:AO610';         % operating point XLEAP R56 target value (mm)
handles.sector.XLEAP.Energy_pv = 'BEND:LTU0:125:BDES';        % operating point XLEAP energy target value (GeV)
handles.sector.XLEAP.LEM_pv = 'SIOC:SYS0:ML03:AO612';
disp('change LEM PV')
handles.sector.XLEAP.nQuad={'QUM2';'QUM3';'QUM4';};
handles.sector.XLEAP.nUse  = 0;
disp('confirm its correct to omit quads')

handles.sector.XLEAP.nUse=[1:3];
handles.sector.XLEAP.nTrim={'BTRM:LTU1:866', 'BTRM:LTU1:870','BTRM:LTU1:872'};
%handles.sector.XLEAP.nTrim={'BCXXL1_TRIM';'BCXXL3_TRIM';'BCXXL4_TRIM'};
disp('make BCXXL1T work')
handles.sector.XLEAP.nCQ={'';''};
handles.sector.XLEAP.phasePV ='SIOC:SYS0:ML03:AO613'; % beam phase prior to XLEAP  (move PDES more neg. if |R56| decreases)
handles.sector.XLEAP.bendPV  ='BEND:LTU1:868';        % XLEAP chicane main bend [kG-m]
handles.sector.XLEAP.colors=[0.043 0.518 0.78;0.702 0.78 1;1 1 1];
handles.sector.XLEAP.delay ='SIOC:SYS0:ML03:AO615';
handles.sector.XLEAP.fdbkPV  ={''};
disp('feedbacks to disable?')
handles.bykikPV='IOC:BSY0:MP01:BYKIKCTL';

% Devices to use and data initialization for each wire/prof by sector
for tag=fieldnames(handles.sector)'
    sector=handles.sector.(tag{:});
    if ~isstruct(sector), continue, end
    sector.quadPV=model_nameConvert(sector.nQuad);
    sector.trimPV=model_nameConvert(sector.nTrim);
    sector.cqPV=model_nameConvert(sector.nCQ);
    if isfield(sector,'nOTR')
        sector.scPV=strcat(model_nameConvert(sector.nOTR),':PNEUMATIC');
    end
    handles.sector.(tag{:})=sector;
end

% Initialize indices (a.k.a. facilities).
handles=gui_indexInit(hObject,handles,'');
handles=appSetup(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=gui_indexControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, name)
nameList=handles.sector.nameList;
handles=gui_popupMenuControl(hObject,handles,'sectorSel',name,nameList,nameList);
handles.name=handles.sectorSel;
set(handles.text1,'String',[handles.sectorSel ' Chicane Control']);

for t=fieldnames(handles.sector.(handles.sectorSel))'
    handles.(t{:})=handles.sector.(handles.sectorSel).(t{:});
end

handles.isLH=numel(handles.nCQ) == 0;

if handles.isLH
    handles.X = handles.Xnom*1E-3;                  % default for BCH Xpos (mm -> m)
else
    handles.X=[];
end
state={'inactive' 'on'};
set(handles.XDES,'Enable',state{handles.isLH+1});

str=' R56 Control';if handles.isLH, str=' Offset Control';end
if strcmp(handles.name, 'XLEAP')
    str = 'Delay Control'; 
    set(handles.text10, 'String', 'Delay')
    set(handles.text13, 'String', 'fs')
    handles.delay = lcaGet(handles.sector.XLEAP.delay);
    delay =handles.delay;
    set(handles.R56DES, 'String', delay)
else
    set(handles.text10, 'String', 'R56(Des)')
    set(handles.text13, 'String', 'mm')
end

set(handles.r56Control_pan,'Title',[handles.name str],'HighlightColor',handles.colors(3,:));
set([handles.r56Control_pan handles.text10 handles.text13 handles.text14 ...
    handles.text15 handles.R56MIN handles.R56MAX handles.text4],'BackgroundColor',handles.colors(2,:));
set([handles.uipanel1 handles.uipanel2 handles.uipanel3 handles.uipanel5 ...
    handles.text19 handles.text20 handles.text21 handles.text24 handles.text25 ...
    handles.text26],'BackgroundColor',handles.colors(1,:));

if handles.isLH
    set(handles.text10,'BackgroundColor','default');
else
    set(handles.text4,'BackgroundColor','default');
end

if handles.isLH
    vMax=handles.Xmax;vMin=handles.Xmin;
    handles.r56=[];
    handles.energy1 = handles.energy1nom;         % default for QA01/02 energy (GeV)
    handles.energy = handles.energynom;           % default for BCH energy (GeV)

    bdes0  = lcaGetSmart([handles.bendPV ':BDES']);       % read initial BCH setting [kG-m]
    bmin   = lcaGetSmart([handles.bendPV ':BMIN']);       % read BCH minimum setting [kG-m]
    if abs(bdes0)<0.01                              % if chicane is OFF for all practical purposes...
        bnow = bdes0 - bmin;
        write_message('Laser-Heater chicane is OFF','MESSAGE',handles);
    else
        bnow = bdes0;
        write_message('Laser-Heater chicane is ON','MESSAGE',handles);
    end
    [BDES,xpos,dphi,theta,eta,r560,Lm,dL,Xact] = BC_adjust('BCH',0,[handles.energy1 handles.energy],bnow); % this likely replaces stuff below
%     if strcmp(handles.name, 'XLEAP')
%         energy = lcaGetSmart(handles.sector.XLEAP.Energy_pv);
%         set(handles.Energy, 'String', num2str(energy))
%         delay = lcaGetSmart(handles.sector.XLEAP.delay);
%         [BDES, iMain, xpos, theta, R56] = BCSS_adjust(delay, energy,'XLEAP');
%     else
%         
%         [BDES,xpos,dphi,theta,eta,r560,Lm,dL,Xact] = BC_adjust('BCH',0,[handles.energy1 handles.energy],bnow);
%     end
    
    val=Xact;
    set(handles.XDES,'String',Xact*1E3);            % show present Xpos (mm)
%    set(handles.ENERGY1,'String',handles.energy1);  % show QA01/02 energy (GeV)
else
    vMax=handles.r56max;vMin=handles.r56min;
    handles.r56    = abs(lcaGetSmart(handles.R56_pv)/1E3);   % read OP target value for BC1 R56 (mm -> m)
    handles.energy = lcaGetSmart(handles.Energy_pv)/1E3;     % read OP target value for BC1 energy (MeV -> GeV)
    val=handles.r56;
    set(handles.MESSAGE,'String','');
end
set(handles.R56MAX,'String',vMax);
set(handles.R56MIN,'String',vMin);

if strcmp(handles.name, 'XLEAP')
    val = str2double(get(handles.R56DES,'String'));
    set(handles.R56SLIDER,'Max',vMax,'Min',vMin,'SliderStep',[0.5 5]/100);
    pause(0.1);
    set(handles.R56SLIDER, 'Value', val);
else
    set(handles.R56SLIDER,'Max',vMax,'Min',vMin,'SliderStep',[0.5 5]/(vMax-vMin));
end


if strcmp(handles.name,'BC2'), handles.energy=handles.energy*1e3;end
if strcmp(handles.name,'XLEAP')
    handles.energy=handles.energy*1e3;
else
  set(handles.R56DES,'String',handles.r56*1E3);
  set(handles.ENERGY,'String',handles.energy); % show BC energy (GeV)
  set(handles.R56SLIDER,'Value',val*1E3);      % show slider position correctly
  %move above two line our of else statement if you have a problem
end


% Update matching quad display.
state={'off' 'on'};
for j=1:6
    str='';if j > 1, str=num2str(j);end
    tag=strrep(handles.tagQuad,'_',[str '_']);
    for t=tag
        set(handles.([t{:}]),'Visible',state{(j <= numel(handles.nQuad))+1});
    end
    if j > numel(handles.nQuad), continue, end
    set(handles.(tag{1}),'String',[handles.nQuad{j} ' =']);
end

% Update CQ display.
isCQ=~handles.isLH;
set([handles.cq1label_txt handles.cq2label_txt handles.CQ11ACT handles.CQ12ACT ...
    handles.text5 handles.text18 handles.uipanel21 handles.uipanel22 ...
    handles.uipanel23 handles.uipanel24 handles.XACT handles.text27 handles.text28],'Visible',state{isCQ+1});
set([handles.OTRH1OUT handles.OTRH1IN handles.OTRH2OUT handles.OTRH2IN],'Visible',state{1+~isCQ});
set([handles.ENERGY1 handles.text48 handles.text49 handles.SHOWDAVE handles.uipanel31 ...
    handles.K_VALUE handles.text54 handles.SET_K handles.text64 ...
    handles.text65 handles.text66 handles.text67 handles.text68 handles.text69 ...
    handles.ETAXNEW handles.ETAXACT handles.R56TNEW handles.R56TACT],'Visible',state{1+~isCQ});
if isCQ
    set(handles.cq1label_txt,'String',handles.nCQ{1});
    set(handles.cq2label_txt,'String',handles.nCQ{2});
else
end

% Move controls around.
h=[handles.uipanel1 handles.uipanel3 handles.uipanel10 handles.uipanel18 ...
    handles.uipanel13 handles.uipanel16 handles.uipanel11 handles.uipanel19 ...
    handles.uipanel6 handles.text11 handles.text12 handles.text22 handles.text23 ...
    handles.BDES handles.BACT];
h=[h handles.text4 handles.XDES handles.text10 handles.R56DES handles.text64 ...
    handles.text65 handles.text66 handles.ETAXNEW handles.ETAXACT handles.text67 ...
     handles.text68 handles.text69 handles.R56TNEW handles.R56TACT ...
     handles.text29 handles.text30 handles.R56ACT];
del=[-8 8 -6 6 -6 6 -6 6 -8 -20 -20 -20 -20 -20 -20];
del2=[-.1 -.1 -.1 -.1 -.1 1.2 1.2 1.2 1.2 1.2 3 3 3];
pos=cell2mat(get(h,'Position'));
if handles.isLH && isequal(handles.panel1Pos0,get(handles.uipanel1,'Position'))
    pos(1:15,1)=pos(1:15,1)+del';
    pos(9,3)=pos(9,3)+16;
    pos(16:19,2)=pos([18 19 16 17],2);
    pos(20:32,2)=pos(20:32,2)+del2';
    set(h,{'Position'},num2cell(pos,2));
elseif ~handles.isLH && ~isequal(handles.panel1Pos0,get(handles.uipanel1,'Position'))
    pos(1:15,1)=pos(1:15,1)-del';
    pos(9,3)=pos(9,3)-16;
    pos(16:19,2)=pos([18 19 16 17],2);
    pos(20:32,2)=pos(20:32,2)-del2';
    set(h,{'Position'},num2cell(pos,2));
end

guidata(hObject, handles);
calc_all(handles,0);


% ------------------------------------------------------------------------
function calc_all(handles, act_trim)

handles.bact   = lcaGetSmart([handles.bendPV   ':BACT']);
handles.r56    = str2double(get(handles.R56DES,'String'))/1E3;
handles.energy = str2double(get(handles.ENERGY,'String'));
val=handles.r56;
if handles.isLH
    handles.X        = str2double(get(handles.XDES,'String'))/1E3;
    handles.energy1  = str2double(get(handles.ENERGY1,'String'));
    val=handles.X;
    handles.UND_pv = 'USEG:IN20:466';       % undulator gap control PV

%    handles.gap    = lcaGetSmart([handles.UND_pv ':MOTR.RBV']);
%    handles.gapDES = lcaGetSmart([handles.UND_pv ':MOTR.VAL']);
%    handles.gapmin = lcaGetSmart([handles.UND_pv ':MOTR.LLM']);
%    handles.gapmax = lcaGetSmart([handles.UND_pv ':MOTR.HLM']);
    handles.gap    = 0;     % temporary until this undulator gap control PV works (10/16/08 - PE)
    handles.gapDES = 0;
    handles.gapmin = -30000;
    handles.gapmax = 30000;

    gamma = handles.energy/511E-6;
    lambda_u = 5.4E-2;  % LH und. period [m]
%    lambda_IR = lcaGetSmart('IR wavelength PV in m');
    lambda_IR = 758E-9;     % temporary until OP_GUI PV is available (10/16/08 - PE) [m]
    handles.K = sqrt(2*(2*gamma^2*lambda_IR/lambda_u - 1));
end

if handles.isLH
    handles.energy=[handles.energy1 handles.energy];
end

if strcmp(handles.name, 'XLEAP')
    energy = lcaGetSmart(handles.sector.XLEAP.Energy_pv);
    delay = lcaGetSmart(handles.sector.XLEAP.delay);
    set(handles.ENERGY, 'String', num2str(energy));
    set(handles.R56DES, 'String', num2str(delay));
    %[BDES, iMain, xpos, theta, R56] = BCSS_adjust(delay,energy,'XLEAP');
    act_trim=0;
else
    [BDES,xpos,dphi,theta,eta,r560,Lm,dL,X0,r56,eta0]  = BC_adjust(handles.name,val,handles.energy,handles.bact);
    
    % Check if R_56 already there.
    if ~handles.isLH && act_trim && abs(r560-handles.r56) < 1e-3
        if abs(r560) < 1e-7
            msg = 'R56 is already at the actual value AND/OR chicane bends are already off.  Do you want to continue?';
        else
            msg = 'R56 is already at the actual value.  Do you want to continue?';
        end
        yn = questdlg(msg,'CAUTION');
        if ~strcmp(yn,'Yes')
            act_trim=0;
        end
    end
    
    
    
    
    
    %   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
    %               BDES(2):    The BXn1 BTRM BDES - absolute BDES (in main-coil Amperes)
    %               BDES(3):    The BXn3 BTRM BDES - absolute BDES (in main-coil Amperes)
    %               BDES(4):    The BXn4 BTRM BDES - absolute BDES (in main-coil Amperes)
    %               BDES(5):    The qBact_txt delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
    %               BDES(6):    The Q21201 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
    %               BDES(7):    The QM11 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
    %               BDES(8):    The QM12 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
    %               BDES(9):    The QM13 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
    
    handles.qbdes = lcaGetSmart(strcat(handles.quadPV,':BDES'));  % read present quad BDES values (kG-m)
    BDESn = BDES((1:numel(handles.qbdes))+4)+handles.qbdes';
end


if act_trim
    fdbkOn = lcaGetSmart(handles.fdbkPV,0,'double');   % check if longitudinal feedback is ON

% Close Pockels cell shutter:
    write_message('Beam OFF - working - please wait...','MESSAGE',handles);
    shutter_open = lcaGetSmart(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of Pockels cell shutter
    lcaPut(handles.beamOffPV,0);                              % turn off beam at Pockels cell shutter

% shift injector RF_ref_phase and its tolerances:
    phi = -dphi;                                % (minus for MALAB variable)
    if handles.isLH
        phi  = dphi;                             % add dphi to Joe's present phase (degS)
    end

    write_message(sprintf('Beam OFF - adjusting RF_ref_setpoint to %5.1f deg (& tols)',phi),'MESSAGE',handles);
%    write_message(sprintf('Beam OFF - adjusting upstream phases to %5.1f deg',phi),'MESSAGE',handles);
    lcaPut(handles.phasePV,phi);                 % act_trim (set absolute PDES) for pre-BC1 beam phase

% set BC1 mover to new position:
    if ~handles.isLH
        write_message(sprintf(['Beam OFF - ' handles.name ' mover set to %5.1f mm'],xpos*1E3),'MESSAGE',handles);
        if xpos <= 0
            xpost = xpos - 1.0E-3;              % make sure chicane hits limit switch with an extra 1 mm
        else
            xpost = xpos;
        end
        lcaPutNoWait(handles.XMOVD_pv,xpost*1E3); % set abs position for BC1 chicane mover
        if epicsSimul_status, lcaPut(handles.XMOVA_pv,xpost*1E3);end
    end

% set BC bends to new currents:
    if abs(BDES(1)) < abs(handles.bact)       % if reducing main supply setting...
        BMAX = lcaGetSmart([handles.bendPV   ':BDES.HOPR']);

        write_message(['Beam OFF - trimming ' handles.name ' main supply to BMAX for STDZ'],'MESSAGE',handles);
%        trim_magnet(handles.bendPV,BMAX,'T',120);       % set BC main supply to max for 10 sec    
        control_magnetSet(handles.bendPV,BMAX,'action','TRIM');       % set BC main supply to max for 10 sec    

        write_message('Beam OFF - pause for 10 sec at BMAX for STDZ','MESSAGE',handles);
        pause(10);

        write_message(['Beam OFF - trimming ' handles.name ' main supply to zero for STDZ'],'MESSAGE',handles);
%        trim_magnet(handles.bendPV,0,'T',120);          % set BC supply to zero
        control_magnetSet(handles.bendPV,0,'action','TRIM');          % set BC supply to zero

        if BDES(1) <= 0                        % if setting chicane completely OFF...
            write_message(['Beam OFF - DAC-zeroing ' handles.name ' main supply'],'MESSAGE',handles);
            lcaPut([handles.bendPV ':CTRL'],'DAC_ZERO');  % DAC zero
            pause(5);
            write_message(['Beam OFF - writing ' handles.name ' BACT -> BDES'],'MESSAGE',handles);
            bact = lcaGetSmart([handles.bendPV   ':BACT']);    % set BDES to BACT
            lcaPut([handles.bendPV ':BDES'],bact);
        else                                  % if setting chicane to  low value, but not OFF...
            pause(5);
        end
    end

    if BDES(1) > 0                          % if BDES of chicane is not exactly zero (i.e., OFF)...
        write_message(sprintf(['Beam OFF - trimming ' handles.name ' BDES to %7.4f kG-m'],BDES(1)),'MESSAGE',handles);
%        trim_magnet(handles.bendPV,BDES(1),'T',120);    % act & trim BC main supply, if not to be left OFF
        control_magnetSet(handles.bendPV,BDES(1),'action','TRIM');    % act & trim BC1 main supply, if not to be left OFF
    end

    if handles.isLH
        write_message('Beam OFF - setting 6 quad supplies to BMIN for STDZ','MESSAGE',handles);
        pvs = strcat(handles.quadPV,':BMIN');
%        pvs = {[QA01_pv ':BMIN']; [QA02_pv ':BMIN']; [QE01_pv ':BMIN']; [QE02_pv ':BMIN']; [QE03_pv ':BMIN']; [QE04_pv ':BMIN']};
        BMIN =lcaGetSmart(pvs);
%        pvs = {QA01_pv; QA02_pv; QE01_pv; QE02_pv; QE03_pv; QE04_pv};
%        trim_magnet(handles.quadPV,BMIN,'T');           % act & trim 6 quads to BMIN for STDZ
        control_magnetSet(handles.quadPV,BMIN,'action','TRIM');           % act & trim 6 quads to BMIN for STDZ
        pause(2);
    end

    write_message(['Beam OFF - setting ' handles.name ' trim & quad supplies to new settings'],'MESSAGE',handles);
    pvs = [handles.trimPV(1:3);handles.quadPV(handles.nUse)];
    BDESt = [BDES(2:4) BDESn(handles.nUse)];
%    trim_magnet(pvs,BDESt,'T');           % act & trim 3 BTRMs + 4 quads (not Q21201)
    control_magnetSet(pvs,BDESt,'action','TRIM');           % act & trim 3 BTRMs + 4 quads (not Q21201)
    lcaPut(handles.LEM_pv,handles.energy(end)); % Update LEM energy set point

    if ~handles.isLH
        n=[{handles.bendPV};handles.quadPV(handles.nUse)];
        lcaPut(strcat(n,':EDES'),handles.energy); % Set EDES PVs
    end

    if BDES(1) <= 0                                   % if BC being switched off...
        lcaPut(handles.fdbkPV,0);                         % turn off feedbacks
        write_message([handles.name ' OFF, so feedbacks disabled'],'MESSAGE',handles);
    end

%  pause(2) % if LH

% Now wait for BC1 mover to converge to its proper position...
    if handles.isLH
        iok = 1;
    else
        for j = 1:40
            xpos_act = lcaGetSmart(handles.XMOVA_pv);                    % read BC1 LVDT position (mm)
            if abs(xpos_act - xpos*1E3) < 5
                iok = 1;
                break
            else
                if j==40
                    write_message([handles.name ' mover is not converging - beam left OFF'],'MESSAGE',handles);
                    iok = 0;
                    break
                end
                write_message(sprintf(['Waiting for ' handles.name ' mover: %5.1f mm should be %5.1f mm'],xpos_act,xpos*1E3),'MESSAGE',handles);
                pause(3);
            end
        end
    end

    if iok
        write_message('All finished - Pockels cell shutter restored','MESSAGE',handles);
        lcaPut(handles.beamOffPV,shutter_open);       % restore state of Pockels cell shutter
    end
end

handles.bact       = lcaGetSmart([handles.bendPV    ':BACT']);           % read final BACT (kG-m)

    if strcmp(handles.name, 'XLEAP')
        energy = lcaGetSmart(handles.sector.XLEAP.Energy_pv);
        delay = lcaGetSmart(handles.sector.XLEAP.delay);
        [BDES, iMain, xpos, theta, r56] = BCSS_adjust(delay, energy,'XLEAP');
        dphi=0;
    else
        [BDES,xpos,phi,theta,eta,r56]= BC_adjust(handles.name,val,handles.energy,handles.bact); % update actual R56 (r56f)
    end

str = sprintf('%5.2f',r56*1E3);
set(handles.R56ACT,'String',str);

handles.btrmact = lcaGetSmart(strcat(handles.trimPV,':BACT'));   % read present BTRM BACTs...
handles.qbact   = lcaGetSmart(strcat(handles.quadPV,':BACT'));   % read present quad BACTs...

if ~handles.isLH
    handles.cqact   = lcaGetSmart(strcat(handles.cqPV,':BACT'));
    handles.xact    = lcaGetSmart(handles.XMOVA_pv);       % read pos. of BC1 (mm)
end

str = sprintf('%6.4f',handles.bact);
set(handles.BACT,'String',str);
str = sprintf('%6.4f',BDES(1));
set(handles.BDES,'String',str);
str = sprintf('%6.3f',BDES(2));
set(handles.BTRM1,'String',str);
str = sprintf('%6.3f',BDES(3));
set(handles.BTRM3,'String',str);
str = sprintf('%6.3f',BDES(4));
set(handles.BTRM4,'String',str);
str = sprintf('%6.3f',handles.btrmact(1));
set(handles.BTRM1ACT,'String',str);
str = sprintf('%6.3f',handles.btrmact(2));
set(handles.BTRM3ACT,'String',str);
str = sprintf('%6.3f',handles.btrmact(3));
set(handles.BTRM4ACT,'String',str);
str = sprintf('%7.1f',dphi);
set(handles.PHASE,'String',str);
str = sprintf('%5.1f',xpos*1E3);
if handles.isLH
    str = sprintf('%5.1f',handles.X*1E3);
end
set(handles.XDES,'String',str);
if ~handles.isLH
    str = sprintf('%5.1f',handles.xact);
    set(handles.XACT,'String',str);
    str = sprintf('%6.3f',handles.cqact(1));
    set(handles.CQ11ACT,'String',str);
    str = sprintf('%6.3f',handles.cqact(2));
    set(handles.CQ12ACT,'String',str);
end

nQuad=numel(handles.qbact);
try
gui_editControl(handles.output,handles,'qBact',handles.qbact,1:nQuad,1,3);
catch
end
try
gui_editControl(handles.output,handles,'qBdes',BDESn,1:nQuad,1,3);
catch
end

state={'off' 'on'};
if handles.isLH
    handles.otrh  = lcaGetSmart(handles.scPV,0,'double');   % =1 if OTR is IN beam (otherwise =0)
    if ~isnumeric(handles.otrh), handles.otrh=strcmp(handles.otrh,'IN');end
    set(handles.OTRH1OUT,'Visible',state{1+~handles.otrh(1)});
    set(handles.OTRH1IN,'Visible',state{1+handles.otrh(1)});
    set(handles.OTRH2OUT,'Visible',state{1+~handles.otrh(2)});
    set(handles.OTRH2IN,'Visible',state{1+handles.otrh(2)});

    str = sprintf('%5.2f',r56*1E3);
    set(handles.R56DES,'String',str);

    str = sprintf('%5.2f',r56*1E3 - 6.32);  % 6.32 mm is the constant R56 of DL1 (opposit sign of chicane)
    set(handles.R56TNEW,'String',str);
    str = sprintf('%5.2f',r56*1E3 - 6.32); % 6.32 mm is the constant R56 of DL1 (opposit sign of chicane)
    set(handles.R56TACT,'String',str);
    str = sprintf('%5.2f',eta*1E3);
    set(handles.ETAXNEW,'String',str);
    str = sprintf('%5.2f',eta0*1E3);
    set(handles.ETAXACT,'String',str);

    str = sprintf('%5.3f',handles.gap/1E3);
    set(handles.UNDGAP_ACT,'String',str);
    str = sprintf('%5.3f',handles.gapDES/1E3);
    set(handles.UNDGAP_DES,'String',str);
    str = sprintf('%5.3f',handles.K);
    set(handles.K_VALUE,'String',str)
end

set(handles.DATE,'String',get_time);
drawnow;


% --- Executes on slider movement.
function R56SLIDER_Callback(hObject, eventdata, handles)

val=get(hObject,'Value')/1E3;

if handles.isLH
    handles.X = val;
    set(handles.XDES,'String',handles.X*1E3);
elseif strcmp(handles.name,'XLEAP')
    delay = round(val*1E3); 
    lcaPutSmart(handles.sector.XLEAP.delay, delay);
    set(handles.R56DES, 'String', delay);
    
else
    handles.r56 = val;
    set(handles.R56DES,'String',handles.r56*1E3);
end

guidata(hObject, handles);
calc_all(handles,0);


function R56DES_Callback(hObject, eventdata, handles)
if strcmp(handles.name, 'XLEAP')
   handles.delay = str2double(get(hObject,'String'));
   set(handles.R56SLIDER,'Value',handles.delay);
   lcaPutSmart(handles.sector.XLEAP.delay, str2double(get(hObject,'String')))
   
else
handles.r56 = str2double(get(hObject,'String'))/1E3;
if (handles.r56*1E3 > handles.r56max)
    errordlg(sprintf('R56 must be <= %5.2f mm',handles.r56max),'Error');
    set(handles.R56DES,'String',handles.r56max);
    handles.r56 = handles.r56max/1E3;
end
if (handles.r56*1E3 < handles.r56min)
    errordlg(sprintf('R56 must be >= %5.2f mm',handles.r56min),'Error');
    set(handles.R56DES,'String',handles.r56min);
    handles.r56 = handles.r56min/1E3;
end
set(handles.R56SLIDER,'Value',handles.r56*1E3)
end
guidata(hObject, handles);
calc_all(handles,0);


function XDES_Callback(hObject, eventdata, handles)

handles.X = str2double(get(hObject,'String'))/1E3;
if (handles.X*1E3 > handles.Xmax)
  errordlg(sprintf('Xpos must be <= %5.2f mm',handles.Xmax),'Error');
  set(handles.XDES,'String',handles.Xmax);
  handles.X = handles.Xmax/1E3;
end
if (handles.X*1E3 < handles.Xmin)
  errordlg(sprintf('Xpos must be >= %5.2f mm',handles.Xmin),'Error');
  set(handles.XDES,'String',handles.Xmin);
  handles.X = handles.Xmin/1E3;
end
set(handles.R56SLIDER,'Value',handles.X*1E3)
guidata(hObject, handles);
calc_all(handles,0);


function ENERGY_Callback(hObject, eventdata, handles, str, str2)

if nargin < 4, str='';str2=handles.name;end

handles.(['energy' str]) = str2double(get(hObject,'String'));
if (handles.(['energy' str]) < handles.(['energy' str 'min']))
    errordlg(sprintf([str2 ' energy must be >= %5.3f GeV'],handles.energymin),'Error');
    set(handles.(['ENERGY' str]),'String',(['energy' str 'min']));
    handles.(['energy' str]) = handles.(['energy' str 'min']);
end
if (handles.(['energy' str]) > handles.(['energy' str 'max']))
    errordlg(sprintf([str2 ' energy must be <= %5.3f GeV'],handles.energymax),'Error');
    set(handles.(['ENERGY' str]),'String',(['energy' str 'max']));
    handles.(['energy' str]) = handles.(['energy' str 'max']);
end
guidata(hObject, handles);
calc_all(handles,0);


function ENERGY1_Callback(hObject, eventdata, handles)

ENERGY_Callback(hObject,[],handles,'1','QA01/02');


% --- Executes on button press in UPDATE.
function UPDATE_Callback(hObject, eventdata, handles)

calc_all(handles,0);


% --- Executes on button press in ACT_TRIM.
function ACT_TRIM_Callback(hObject, eventdata, handles)
if strcmp(handles.name, 'XLEAP')
    adjustChicane(hObject, handles);
else
      % Phase control process moved to SIOC, check for watcher removed.
str='position, adjust its ';
if handles.isLH, str='and nearby quadrupole ';end
if ~strcmp(handles.name, 'XLEAP')
    yn = questdlg(['This will put the Pockels cell shutter IN, change the ' handles.name ' chicane ' str 'magnet settings, change the injector phase, and then open the Pockels cell shutter when done.  Do you want to continue?'],'CAUTION');
else
    yn = 'No';
end
if ~strcmp(yn,'Yes')
    return
end

calc_all(handles,1);
end

function handles=adjustChicane(hObject, handles)
energy=lcaGetSmart(handles.sector.XLEAP.Energy_pv);
chicanePower=strcmp(lcaGetSmart('BEND:LTU1:868:STATE'),'ON');

if chicanePower == 0
    set(handles.PHASE, 'Enable', 'On')
    %phase adjust
    degrees = str2double(get(handles.PHASE, 'String'));
    lambda=12398.4/lcaGet('SIOC:SYS0:ML00:AO627');
    %phase=360*Angstroms/lambda;   %Degrees
    Angstroms = degrees*lambda/360;
    [BDES,theta,Itrim,R56] = BC_phase(Angstroms,energy,'XLEAP');
    lcaPutSmart(handles.sector.XLEAP.R56_pv,R56); %XLEAP R56 PV
    BDES(1:4)=BDES; disp(BDES);
    handles=setMags(hObject, handles, BDES);
    %guidata(handles.output, handles);
else
    %delay adjust
    set(handles.PHASE, 'Enable', 'Off')
    delay = lcaGetSmart(handles.sector.XLEAP.delay);
    [BDES,iMain,xpos,theta,R56] = BCSS_adjust(delay,energy,'XLEAP');
    setMags(hObject, handles, BDES);
    %handles=setMags(hObject, handles, BDES);
end
guidata(hObject, handles);

function handles=setMags(hObject, handles, BDES)
chicanePower=strcmp(lcaGetSmart('BEND:LTU1:868:STATE'),'ON');
if chicanePower == 1
    magPV={'BEND:LTU1:868';'BTRM:LTU1:866'; 'BTRM:LTU1:870'; 'BTRM:LTU1:872'};   
else
    magPV={'BTRM:LTU1:866'; 'BTRM:LTU1:870'; 'BTRM:LTU1:872'};
end
write_message('Setting XLEAP magnets to BDES ...','MESSAGE',handles);
control_magnetSet(magPV,BDES,'wait',.25);
guidata(hObject,handles);


% --- Executes on button press in BC1OFF.
function BC1OFF_Callback(hObject, eventdata, handles)
if strcmp(handles.name, 'XLEAP')
    set(handles.PHASE, 'Enable',  'On')
    write_message('BYKIK Enabled','MESSAGE',handles)
    lcaPutSmart(handles.bykikPV, 0); %Disable Beam
    write_message('Wait for EPICS TRIM ...','MESSAGE',handles)
    control_magnetSet({'BCXXL1_TRIM' 'BCXXL3_TRIM' 'BCXXL4_TRIM'}, 0,'action','TRIM');
    write_message('Wait for EPICS DEGAUSS ...','MESSAGE',handles)
    control_magnetSet('BCXXL2',[],'action','DEGAUSS');
    write_message('XLEAP Chicane off, BYKIK Disabled','MESSAGE',handles)
    lcaPutSmart(handles.bykikPV, 1); %Enable
    return
else
    str='and straighten out ';
    if handles.isLH, str='';end
    yn = questdlg(['Caution, this will temporaily switch off beam ' str 'and turn off the ' handles.name ' chicane.  Do you really want to do this?'],'CAUTION');
    if ~strcmp(yn,'Yes')
        return
    end
    
    if handles.isLH
        handles.X = 0;
        set(handles.R56SLIDER,'Value',handles.X*1E3)
        set(handles.XDES,'String',handles.X*1E3)
    else
        handles.r56 = 0;
        set(handles.R56SLIDER,'Value',handles.r56*1E3)
        set(handles.R56DES,'String',handles.r56*1E3)
    end
end
guidata(hObject, handles);
calc_all(handles,1)


% --- Executes on button press in BC1ON.
function BC1ON_Callback(hObject, eventdata, handles)
if strcmp(handles.name, 'XLEAP')
    set(handles.PHASE, 'Enable',  'On')
    lcaPutSmart(handles.bykikPV, 0); %Insert
    write_message('BYKIK Enabled, Wait for EPICS TURN_ON ...','MESSAGE',handles)
    control_magnetSet('BCXXL2',[],'action','TURN_ON');
    write_message('Wait for EPICS STDZ ...','MESSAGE',handles)
    control_magnetSet('BCXXL2',[],'action','STDZ');
    write_message('Wait for EPICS TRIM ...','MESSAGE',handles)
    control_magnetSet({'BCXXL1_TRIM' 'BCXXL3_TRIM' 'BCXXL4_TRIM'}, 0,'action','TRIM');
    write_message('Chicane ready BYKIK Disabled','MESSAGE',handles)
    lcaPutSmart(handles.bykikPV, 1); %Insert
    
    return
else
    
str='and displace ';
if handles.isLH, str='';end
yn = questdlg(['Caution, this will turn ON ' str 'the ' handles.name ' chicane to its nominal settings.  Do you really want to do this?'],'CAUTION');
if ~strcmp(yn,'Yes')
    return
end

if handles.isLH
    handles.X = handles.Xnom*1E-3;   % nominal value for BCH Xpos (mm -> m)
    set(handles.R56SLIDER,'Value',handles.X*1E3)
    set(handles.XDES,'String',handles.X*1E3);
else
    handles.r56    = abs(lcaGetSmart(handles.R56_pv)/1E3);   % read OP target value for BC1 R56 (mm -> m)
    handles.energy = lcaGetSmart(handles.Energy_pv)/1E3;     % read OP target value for BC1 energy (MeV -> GeV)
    if strcmp(handles.name,'BC2'), handles.energy=handles.energy*1e3;end
    set(handles.R56SLIDER,'Value',handles.r56*1E3)
    set(handles.R56DES,'String',handles.r56*1E3);
    set(handles.ENERGY,'String',handles.energy);
end
end
guidata(hObject, handles);
calc_all(handles,1)


% --- Executes on button press in SET_K.
function SET_K_Callback(hObject, eventdata, handles)

yn = questdlg('This will change the heater-undulator gap.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
  set(handles.SET_K,'Value',0);
  return
end
set(handles.K_VALUE,'String','...')
drawnow
pause(1)    % temporary
%gap = f(K) ???
%lcaPut([handles.UND_pv ':MOTR.VAL'],handles.gapDES)
guidata(hObject, handles);
calc_all(handles,0);
set(handles.SET_K,'Value',0);


function UNDGAP_DES_Callback(hObject, eventdata, handles)

yn = questdlg('This will change the heater-undulator gap.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
  calc_all(handles,0);
  guidata(hObject, handles);
  return
end
handles.gapDES = str2double(get(hObject,'String'))*1E3;
if (handles.gapDES > handles.gapmax)
  errordlg(sprintf('gap must be <= %5.3f mm',handles.gapmax/1E3),'Error');
  handles.gapDES = handles.gapmax;
end
if (handles.gapDES < handles.gapmin)
  errordlg(sprintf('gap must be >= %5.3f mm',handles.gapmin/1E3),'Error');
  handles.gapDES = handles.gapmin;
end
%lcaPut([handles.UND_pv ':MOTR.VAL'],handles.gapDES)
guidata(hObject, handles);
calc_all(handles,0);


% --- Executes on selection change in sectorSel_pmu.
function sectorSel_pmu_Callback(hObject, eventdata, handles)

sectorControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in Dave.
function Dave_Callback(hObject, eventdata, handles)


% --- Executes on button press in SHOWDAVE.
function SHOWDAVE_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
  set(handles.Dave,'Visible','on');
else
  set(handles.Dave,'Visible','off');
end


% ----------------------------------------------------------
% Create functions and inactive edit uicontrol callbacks
% ----------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function R56SLIDER_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function R56DES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function XDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ11ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CQ11ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ12ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CQ12ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BDES_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHASE_Callback(hObject, eventdata, handles)
phase = get(handles.PHASE, 'String');
lcaPut(handles.sector.XLEAP.phasePV, phase)

% --- Executes during object creation, after setting all properties.
function PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM1ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM3ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM4ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function XACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function XACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function R56ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function qBact_txt_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function qBact_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function qBdes_txt_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function qBdes_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function UNDGAP_ACT_Callback(hObject, eventdata, handles)

function ETAXACT_Callback(hObject, eventdata, handles)

function ETAXNEW_Callback(hObject, eventdata, handles)

function R56TACT_Callback(hObject, eventdata, handles)

function R56TNEW_Callback(hObject, eventdata, handles)

%edited scripts BC_adjust.m model_energyBTrim.m BCSS_adjust.m BC_phase.m
%BC_chicane_control.fig model_nameList.m 
