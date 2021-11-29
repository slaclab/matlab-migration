function varargout = matching_gui(varargin)
% MATCHING_GUI MATLAB code for matching_gui.fig
%      MATCHING_GUI, by itself, creates a new MATCHING_GUI or raises the existing
%      singleton*.
%
%      H = MATCHING_GUI returns the handle to a new MATCHING_GUI or the handle to
%      the existing singleton*.
%
%      MATCHING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATCHING_GUI.M with the given input arguments.
%
%      MATCHING_GUI('Property','Value',...) creates a new MATCHING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before matching_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to matching_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help matching_gui

% Last Modified by GUIDE v2.5 24-Jun-2014 11:43:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @matching_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @matching_gui_OutputFcn, ...
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


% --- Executes just before matching_gui is made visible.
function matching_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to matching_gui (see VARARGIN)

% Choose default command line output for matching_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes matching_gui wait for user response (see UIRESUME)
% uiwait(handles.matching_gui);


% --- Outputs from this function are returned to the command line.
function varargout = matching_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close matching_gui.
function matching_gui_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of sector names per accelerator, default to LCLS
[sys, accelerator] = getSystem();
switch accelerator
    case 'NLCTA'
        handles.sector.nameList={'NLCTA77' 'NLCTA78'};
    case 'XTA'
        handles.sector.nameList={'XT01'};
    case 'FACET'
        handles.sector.nameList={'LI02' 'LI18' 'LI20'};
    otherwise
        handles.sector.nameList={'IN20' 'SPEC' 'LI21' 'LI28' 'LTUH','LTUS', 'UNDH' 'DMPH' 'BSYLTU'};
end
handles.accelerator=accelerator;

% Profile monitor MAD names by sector
handles.sector.IN20.locMADList={ ...
    'OTR2 HTRUND' 'WS02 HTRUND' 'OTR2' 'WS02' 'OTR3 HTRUND' 'OTR3'};
handles.sector.SPEC.locMADList={ ...
    'YAGS2'};
handles.sector.LI21.locMADList={ ...
    'OTR12' 'WS12'};
handles.sector.LI28.locMADList={ ...
    'WS28144' 'WS28144 Q27201' 'WS28744'};
handles.sector.LTUH.locMADList={ ...
    'WS32' 'OTR33' 'YAGPSI' 'OTR33 QEM3'};
handles.sector.LTUS.locMADList={ ...
    'WS32B'};
handles.sector.BSYLTU.locMADList={ ...
    'WSVM2'};
handles.sector.UNDH.locMADList={ ...
    'RFBU01' 'RFBU01 OTRDMP' 'RFBU02'};
handles.sector.DMPH.locMADList={ ...
    'OTRDMP MXTC' 'OTRDMP'};
handles.sector.NLCTA77.locMADList={ ...
    'P810595T'};
handles.sector.NLCTA78.locMADList={ ...
    'P811550T'};
handles.sector.XT01.locMADList={ ...
    'OTR350X'};
handles.sector.LI02.locMADList={ ...
    'WS02119' 'WS02125' 'WS02133' 'WS02148' 'WS02209' 'WS02239' 'WS02339'};
handles.sector.LI18.locMADList={ ...
    'WS18944'};
handles.sector.LI20.locMADList={ ...
    'WSIP1'};

% Profile monitor MAD names by sector
handles.sector.IN20.measMADList={ ...
    'OTR2' 'WS02' 'OTR3'};
handles.sector.SPEC.measMADList={ ...
    'OTR2' 'WS02'};
handles.sector.LI21.measMADList={ ...
    'OTR12' 'WS12'};
handles.sector.LI28.measMADList={ ...
    'WS28144' 'WS28744'};
handles.sector.LTUH.measMADList={ ...
    'WS32' 'OTR33' 'YAGPSI'};
handles.sector.LTUS.measMADList={ ...
    'WS32B'};
handles.sector.BSYLTU.measMADList={ ...
    'WSVM2'};
handles.sector.UNDH.measMADList={ ...
    'WS32' 'BFW07'};
handles.sector.DMPH.measMADList={ ...
    'WS32'};
handles.sector.NLCTA77.measMADList={ ...
    'P810595T'};
handles.sector.NLCTA78.measMADList={ ...
    'P811550T'};
handles.sector.XT01.measMADList={ ...
    'OTR350X'};
handles.sector.LI02.measMADList={ ...
    'WS02119' 'WS02125' 'WS02133' 'WS02148' 'WS02209' 'WS02239' 'WS02339'};
handles.sector.LI18.measMADList={ ...
    'WS18944'};
handles.sector.LI20.measMADList={ ...
    'WSIP1'};

% Twiss goals by sector, [beta_x alpha_x beta_y alpha_y [ ...]]
handles.sector.IN20.goalList={ ...
    [1.112 -0.067 1.112 -0.066 10 NaN 10 NaN] ...
    [1.113 0.070 1.112 0.071 10 NaN 10 NaN] ...
    [1.113 -0.069 1.113 -0.07] ...
    [1.113 0.068 1.113 0.067] ...
    [4.688 -1.80 4.688 -1.8 10 NaN 10 NaN] ...      % nate jsy add OTR3
    [4.683 -1.796 4.689 -1.798] };                     % nate jsy add oTR3
handles.sector.SPEC.goalList={ ...
    [0.1301 -0.0662 5.9774 -3.0500]};
handles.sector.LI21.goalList={ ...
    [1.046 -0.310 1.044 -0.309] ...
    [0.954 -0.001 0.953 -0.00]};
handles.sector.LI28.goalList={ ...
    [62.581 -1.257 35.446 0.671] ...
    [63.89844 -1.283798 34.489033 0.680743 62.784076 NaN 34.590647 NaN] ...
    [59.853 -1.270 37.617 0.807]};
handles.sector.LTUH.goalList={ ...
    [46.226 -1.085 46.226 1.085] ...
    [46.226 1.085 46.226 -1.085] ...
    [48.016 1.123 44.497 -1.046] ...
    [20.61 0 20.61 0 300 NaN NaN NaN] ...
%    [35.7095 0.8561 35.6939 0.8555] ...
    };
handles.sector.LTUS.goalList={ ...
    [46.221 -1.082 46.144 1.085] ...
    };
handles.sector.BSYLTU.goalList={ ...
    [28.876 0.227 52.436 1.314] ...
    };
handles.sector.UNDH.goalList={ ...
    [26.651 -0.873 30.836 1.015] ...
    [26.651 -0.873 30.836 1.015 252.0220 NaN 1.2568 NaN] ...
    [33.8133 1.1082 24.3084 -0.7999]};
handles.sector.DMPH.goalList={ ...
    [31.2952 NaN 0.5221 NaN 91.8609 NaN 47.7195 NaN] ...
    [31.2952 NaN 0.5221 NaN]};
handles.sector.NLCTA77.goalList={ ...
    [2.241 9.036 0.642 6.718]};
handles.sector.NLCTA78.goalList={ ...
    [0.233 3.458 -0.564 3.114]};
handles.sector.XT01.goalList={ ...
    [18.0722 0.7139 3.0985 -1.3657]};
handles.sector.LI02.goalList={ ...    
    [15.2817 -3.3690  7.1790  0.5265] ...
    [ 9.8837  3.7574 14.2297 -4.0725] ...
    [ 4.1200  0.2023 12.6090  2.3128] ...
    [ 8.1932 -3.1716  3.6094  1.3114] ...
    [ 1.4638  0.6016  9.8334 -2.0787] ...
    [10.7294 -2.8274  1.7211  0.5045] ...
    [10.7539 -2.8320  1.7260  0.5039]};
handles.sector.LI18.goalList={ ...
    [24.7326 -1.8678 87.1892 3.7921]}; % Low beta optics
%    [31.868 -3.164 195.161 8.253]};
handles.sector.LI20.goalList={ ...
    [0.3 0 3.0 0]};

% Initialize sector buttons
handles=gui_radioBtnInit(hObject,handles,'sectorSel',handles.sector.nameList,'_btn');

% Devices to use and data initialization for each wire scanner by sector
for tag=handles.sector.nameList
    sector=handles.sector.(tag{:});
    handles.sector.(tag{:})=sector;
end

gui_modelSourceControl(hObject,handles,[]);

handles=gui_objectRepeat(hObject,handles,{'magnet_txt' 'magnetBG_txt' 'bAct_txt' 'bFit_txt' 'bDesign_txt'},8);
handles=gui_objectRepeat(hObject,handles,{'goalbx_txt' 'goalax_txt' 'goalby_txt' 'goalay_txt'});
handles=gui_objectRepeat(hObject,handles,{'fitbx_txt' 'fitax_txt' 'fitby_txt' 'fitay_txt'});

handles.exportFig = hObject;
handles.sectorSel='';
handles.startDesign=0;
handles.updateMeas=1;
handles.undQuad=0;
handles=undQuadControl(hObject,handles,[]);
set(handles.gain_txt,'String',sprintf('%2.2f ', 1.0));
handles=expertControl(hObject,handles,0);
set(handles.measLoc_pmu,'Value',1,'String',{''});
set(handles.twissLoc_pmu,'Value',1,'String',{''});
set(handles.bmag_txt,'String','');
set(handles.date_txt,'String',datestr(now));
set([handles.betax handles.alphax handles.betay handles.alphay],{'String'},{''});

handles.goals=[];
handles.optics(1).reference='...';
handles.optics(1).location=[];
handles.optics(1).KL=[];
handles.optics(1).type=[];

displayInit(handles);
matching_updateGoals(handles);

% Set initial state of button: buttonmkb_assign
% (see function buttonMKB_Assign_Callback for more info
% This code block added 13 OCT 2010 by Chris Melton, AOSD Operations
set(handles.buttonMKB_Assign,'Enable','off');


% --------------------------------------------------------------------
function displayInit(handles)

matching_updateMagnets(handles,'magnetBG');
matching_updateMagnets(handles,'bAct');
matching_updateMagnets(handles,'bFit');
matching_updateMagnets(handles,'bDesign');


% --------------------------------------------------------------------
function handles = matching_opticsLoad(handles)
%
%  USAGE:
%  
%  INPUT: 
%
%  OUPUT: 
%
%  DECRIPTION : 
%            loads optics
%            tranform segments into mulitple segments
%            print quads used and current BACT values 
%            prints goal values 
%            ???? reads the twiss parameters from PV ????
%            set tolerances to default values 
%            refresh graphics 
%

file=[handles.pathName handles.fileName];

% reads optics from PARMELA type input
if ~any(strfind(file,'.mat'))
    handles.optics = matching_opticsRead(file);
    handles.goals=handles.optics(1).goals;
else
    load(file);
    handles.optics = matching_configCreate(quads,screens);
end
% increase number of segments for drifts (every 5 mm)
handles.optics = matching_beamlineModify(handles.optics,'drift',1,0.005);
% increase number of segments for quads (cut in 2 pieces)
handles.optics = matching_beamlineModify(handles.optics,'quad',2,2);
% increase number of segments to 1 in linac
handles.optics = matching_beamlineModify(handles.optics,'linac',2,1);

% Get design BDES
global modelBeamPath
% modelBeamPath
name={handles.optics(handles.optics(1).location).type}';
[k1,z,lEff]=design_k1Get(name);
%eDes=control_magnetGet(name,'EDES');
BEAMPATH = check_beampath(name{1},'QUAD');
handles.optics(1).BEAMPATH = BEAMPATH;
eDes=model_rMatGet(name,[],{'TYPE=EXTANT' ['BEAMPATH=',BEAMPATH]},'EN');
bp=eDes/299.792458*1e4; % kG m
bDes=k1(:)'.*lEff(:)'.*bp(:)';

% prints the names of the quadrupoles used 
% set visibility on for all quads used, off for unused
%displayInit(handles);
matching_updateMagnets(handles,'magnetBG');
matching_updateMagnets(handles,'bFit',[]);
matching_updateMagnets(handles,'bDesign',bDes);
matching_updateGoals(handles);

% set default tolerances
handles=expertControl(handles.output,handles,0);

% -------- erases the graphics 
% -------- print labels 
cla(handles.axes_beta);
cla(handles.axes_sigma);

set(handles.graphics_pan,'Title',sprintf('Graphics for %s ',file));

set(handles.date_txt,'String',datestr(now));
% commented out 
%set(handles.text47,'String','Toubleshooting: limborg@slac.stanford.edu, X8685');


% --------------------------------------------------------------------
function [k1, z, lEff] = design_k1Get(name)

modelSource=model_init;
BEAMPATH = check_beampath(name{1},'QUAD');
if strcmp(modelSource,'SLC')
    [rBeg,z,lEff]=model_rMatGet(name,[],{'POS=BEG' 'TYPE=DESIGN' ['BEAMPATH=',BEAMPATH]});
    rEnd=model_rMatGet(name,[],{'POS=END' 'TYPE=DESIGN'});
    n=size(rBeg,3);
    r=zeros(6,6,n);
    for j=1:n
        r(:,:,j)=rEnd(:,:,j)*inv(rBeg(:,:,j));
    end
else
    [r,z,lEff]=model_rMatGet(name,name,{'POS=BEG' 'POSB=END' 'TYPE=DESIGN' ['BEAMPATH=',BEAMPATH]});
end

r11=squeeze(r(1,1,:))';
phix=acos(r11);
k1=real((phix./lEff).^2);


% --------------------------------------------------------------------
function optics = matching_opticsRefresh(optics, handles)
%
%
% USAGE: 
%   optics=matching_opticsRefresh(FileName,handles)
%
% 
% FUNCTION:
%    updates the quadrupole and bend settings 
%    from BACT readings 
%    and writes them into the     
%  
%    quad: 
%    bend: 
% 
%k1=bAct/lEff/bp; % 1/m^2

for i = 1:length(optics)
    switch optics(i).name
        case 'quad'
             [d,KL_] = control_magnetGet(optics(i).type);
             optics(i).KL = KL_;
         case 'bend'
             BL_ = control_magnetGet(optics(i).type);
             Energy_ = handles.optics(1).Energy*1e-3;   % in GeV/c
             BRho = Energy_/299.792458*1e4; % kG m
             if abs(optics(i).angle) < 0.15 % non-chicane bends in GeV/c
                 optics(i).angle=BL_/BRho*optics(i).sign;
             end
%             disp(optics(i).angle);
%             disp(optics(i).sign);
         case 'und'
             Energy_ = handles.optics(1).Energy*1e-3;   % in GeV/c
             BRho = Energy_/299.792458*1e4; % kG m
%             KL_ = control_magnetGet(optics(i).type);
%             KL_ = optics(i).KL;KL_
%             KL_ = -0.2927*(lcaGet([model_nameConvert(optics(i).type) ':MOTR']) > 0);
             K_und = lcaGet([model_nameConvert(optics(i).type) ':KDES']);
             kqlh=(K_und*2*pi/0.054/sqrt(2)/(Energy_/510.99906E-6))^2;
             KL_ = -kqlh*BRho*optics(i).length;
             optics(i).KL = KL_;
             optics(i).angle=sqrt(-optics(i).KL*optics(i).length/BRho);
    end
end

%  writes value for quads of interest in GUI
matching_updateMagnets(handles,'bAct',optics);


% --- Executes on button press in opticsLoad_btn.
function opticsLoad_btn_Callback(hObject, eventdata, handles)

[fileName,pathName] = uigetfile({'*.config';'*.mat'},'Select Optics File');
if ~ischar(fileName), return, end

handles.sectorSel='';
handles.pathName = pathName;
handles.fileName = fileName;

%  loads the optics & refresh magnet settings (bends and quads)
handles = matching_opticsLoad(handles);
handles.optics = matching_opticsRefresh(handles.optics,handles);

% saves the handles after update
guidata(hObject,handles);

set(handles.twissLoc_pmu,'Value',1,'String',reshape(handles.optics(1).reference',1,[]));
set(handles.measLoc_pmu,'Value',1,'String',handles.optics(1).measured);

if ismember(handles.optics(1).sector,{'LI28' 'LTUH' 'LTUS' 'BSYLTU' 'UNDH' 'DMPH' 'NLCTA77' 'NLCTA78' 'XT01' 'LI02' 'LI18' 'LI20'})
    handles.optics = matching_beamlineModify(handles.optics,'screen',2,1);
    handles.optics = matching_beamlineModify(handles.optics,'matrix',2,3);
    handles.optics=matching_opticsModel(handles.optics);
end
if isempty(handles.optics(1).sector)
    handles.optics = matching_beamlineModify(handles.optics,'drift',2,1);
    handles.optics = matching_beamlineModify(handles.optics,'quad',2,1);
    handles.optics = matching_beamlineModify(handles.optics,'screen',2,1);
end
guidata(hObject,handles);
measured_Callback(hObject,[],handles);


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)

if handles.updateMeas
    handles=measured_Callback(hObject, eventdata, handles);
else
    handles=matching_init(hObject,handles);
end
matching_run(hObject,handles);


% --------------------------------------------------------------------
function handles = matching_init(hObject, handles)

% Refresh quad settings before matching
handles.optics=matching_opticsRefresh(handles.optics,handles);

% clear figure axes
cla(handles.axes_beta);
cla(handles.axes_sigma);
%cla(handles.axes_beta,'reset');
%cla(handles.axes_sigma,'reset');

% --- 1 ----    reads the quad strengths 
% -----------   sets the values of quads to default from optics file
 
% ------------------ Transport Initializations --------------------
ref=cellstr(handles.optics(1).measured);
screen_ref = find(strcmp({handles.optics.type},ref)); % --- location of measurement screen
zVectRef = handles.optics(1).zVect;        % --- position first element in z
Ek = handles.optics(1).Energy;             % --- energy at first element   (FUTURE UPDATE)
%  --------------- reads Energy from dipole -----------------
sector= handles.optics(1).sector;

switch sector
    case 'IN20'
        TMIT_ = lcaGet('BPMS:IN20:731:TMIT');
        if TMIT_ > 5e7
            Ek = lcaGet('BEND:IN20:751:BACT')*1e3;
        else
            Ek = lcaGet('BEND:IN20:931:BACT')*1e3;
        end
    case 'LI21'
        en=model_energySetPoints;
        Ek = en(3)*1e3; % in MeV
    otherwise
        BEAMPATH = check_beampath(ref,'WIRE');
        en = model_rMatGet(handles.optics(1).measured,[],{'TYPE=EXTANT' ['BEAMPATH=',BEAMPATH]},'EN');
        Ek = en*1e3; % in MeV
end

str = sprintf('Energy is %6.0f MeV at %s \n',Ek,handles.optics(1).measured);
str1 = sprintf('ex/ey = %2.2f/%2.2f microns (used in graph above)',handles.ex,handles.ey) ;

set(handles.energy_txt,'String',[str str1]);

indexEl = screen_ref:-1:1;

% back track from reading of alpha/beta at WS02 
% input parameters 

bx = str2double(get(handles.betax,'String'));
ax = str2double(get(handles.alphax,'String'));
by = str2double(get(handles.betay,'String'));
ay = str2double(get(handles.alphay,'String'));
 
%
if isempty(handles.ex),
    emittance = [1 1]*1e-6; 
else
    emittance(1) = handles.ex*1e-6;
    emittance(2) = handles.ey*1e-6;
end

Eo = 0.511;
gama = Ek/Eo;
ex = emittance(1)/gama;
ey = emittance(2)/gama;
gx = (1+ax^2)/bx;
gy  =(1+ay^2)/by;

SIG = zeros(6,6);
SIG(1,1) = ex*bx;
SIG(2,2) = ex*gx;
SIG(1,2) = -ex*ax;SIG(2,1) = SIG(1,2);

SIG(3,3) = ey*by;
SIG(4,4) = ey*gy;
SIG(3,4) = -ey*ay;SIG(4,3) = SIG(3,4);

X = [0 0 0 0 0 0 Ek]';

% transport back  
[SIGSTART,SIGMA,X] = matching_transport(handles.optics,SIG,X,indexEl,-1);
XSTART = X(7,1);

handles.SIGSTART=SIGSTART;
handles.XSTART=XSTART;
guidata(hObject,handles);

% prepares tables for transport forward
X = [0 0 0 0 0 0 XSTART]';

[SIGout,SIGMAout,Xout,zVect] = matching_transport(handles.optics,SIGSTART,X);
zVect = zVect + zVectRef;
matching_twissPlot(SIGMAout,Xout,zVect,handles);
matching_twissfun([handles.optics(handles.optics(1).location).KL],handles.optics(1).location, ...
    handles.optics,handles.SIGSTART,[0 0 0 0 0 0 handles.XSTART]',handles.goals,handles);


% --------------------------------------------------------------------
function handles = matching_run(hObject, handles)

set(handles.output,'Pointer','watch');
set(handles.trim,'Enable','off');
SIGSTART=handles.SIGSTART;
XSTART=handles.XSTART;

% --- 2 ---- runs the solver
% ----------
% Initializations 
nquad = handles.optics(1).location;
quads = [handles.optics(nquad).KL];quadsOld=quads;
if handles.startDesign
    for j = 1:length(nquad)
%        quads(j)=str2double(get(handles.(['edit' num2str(j+59)]),'String'));
        str='';if j > 1, str=num2str(j);end
        quads(j)=str2double(get(handles.(['bDesign' str '_txt']),'String'));
    end
end
optics = matching_beamlineModify(handles.optics,{'drift' 'quad' 'linac' 'bend'},2,1);
%optics = matching_beamlineModify(optics,{'bend'},2,2); % Test only
%optics=compress_optics(handles.optics,XSTART);

X = [0 0 0 0 0 0 XSTART]';

goals=handles.goals;

options = optimset('TolFun',handles.tolF,'TolX',handles.tolX);

%options = optimset('MaxIter',4000);
%options = optimset('MaxFunEvals',4000);
%xout = lsqnonlin(@matching_twissfun,quads,[],[],options,nquad,optics,SIGSTART,SIGMA,X,[1.1 0 1.1 0 10 10 ]);

%[xout,fval,exitflag] = fsolve(@matching_twissfun,quads,options,nquad,optics,SIGSTART,SIGMA,X,goals,handles);

set(handles.Run,'String','Running!!','FontSize',14,'Enable','on','BackGroundColor',[1 0 0]);
%set(handles.Run,'String','Running!!','FontSize',14,'Enable','off','BackGroundColor',[1 0 0]);

xout=fminsearch(@matching_twissfun,quads,options,nquad,optics,SIGSTART,X,goals,handles);
set(handles.Run,'String','Run','FontSize',8,'Enable','on');
disp(['Quads ' num2str(xout)]);

if 0 % Loos inserted
num_goal = length(handles.goals); 
if num_goal <6 
[xout,fval,exitflag] = lsqnonlin(@matching_twissfun,quads,[],[],options,nquad,optics,SIGSTART,X,goals,handles);
set(handles.Run,'String','Run','FontSize',8,'Enable','on');
disp(['Quads ' xout])
else
[xout,fval,exitflag] = lsqnonlin(@matching_twissfun,quads,[],[],options,nquad,optics,SIGSTART,X,goals,handles);
set(handles.Run,'String','Run','FontSize',8,'Enable','on');
disp(['Quads ' xout])
end
end % Loos inserted

for i = 1:length(nquad)
    handles.optics(nquad(i)).K_old = quadsOld(i);
    handles.optics(nquad(i)).KL = xout(i);
end
guidata(hObject,handles);
matching_updateMagnets(handles,'bFit');

X = [0 0 0 0 0 0 XSTART]';

[SIGout,SIGMAout,Xout,zVect] = matching_transport(handles.optics,SIGSTART,X);
zVectRef = handles.optics(1).zVect;        % --- position first element in z  
zVect = zVect + zVectRef;
matching_twissPlot(SIGMAout,Xout,zVect,handles,'br');
set(handles.output,'Pointer','arrow');
set(handles.trim,'Enable','on');

% Set both the string and enable bit to appropriate values for 
% buttonmkb_assign, once the Run has completed
% (see function buttonMKB_Assign_Callback for more info
% This code block added 13 OCT 2010 by Chris Melton, AOSD Operations
set(handles.buttonMKB_Assign,'Enable','on');
set(handles.buttonMKB_Assign,'String','Create MKB File');
%%%


function bAct_txt_Callback(hObject, eventdata, handles)


function bFit_txt_Callback(hObject, eventdata, handles)


function bDesign_txt_Callback(hObject, eventdata, handles)


% --- Executes on button press in trim.
function trim_Callback(hObject, eventdata, handles)

%CL_WORK

if ~isfield(handles.optics,'K_old'), return, end
% applies new values of quadrupoles 
% --reads gain 
gain_ = str2double(get(handles.gain_txt,'String'));

if isnan(gain_),
    msgbox('You need to give the gain value !!','Warning: gain value wanted','error')
else
    % FUTURE UPDATE :check 
    if gain_<0 || gain_>1
        msgbox('0 < Gain <1','Warning: gain value wanted','error');
    else
    % -- applies quads 
    % -- reads start value 
    nquad = handles.optics(1).location;

    for i = nquad(:)'
        Result_ = handles.optics(i).KL;
        Old_ = handles.optics(i).K_old;
        New_ = (Result_-Old_)*gain_+Old_;
        handles.optics(i).KL = New_;
    end
    end

    % Sets quadrupoles to new values
    trimMagnets(hObject,handles);
end


% --------------------------------------------------------------------
function handles = expertControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'expert',val);
str={'Off' 'On'};
set([handles.tolF_txt handles.tolX_txt],'Enable',str{handles.expert+1});
if ~handles.expert
    handles=gui_editControl(handles.output,handles,'tolF',1e-4);
    handles=gui_editControl(handles.output,handles,'tolX',1e-3);
end


% --- Executes on button press in expert_box.
function expert_box_Callback(hObject, eventdata, handles)

expertControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in refresh_RF.
function refresh_RF_Callback(hObject, eventdata, handles)

for j = find(strcmp({handles.optics.name},'linac'))
    name = handles.optics(j).type;
    [Phase,d,Amplitude]=control_phaseGet(upper(name(1:3)));

    handles.optics(j).phase=Phase;
    handles.optics(j).ampl=Amplitude/handles.optics(j).length;

    str=sprintf('%s  with %2.2f  MV and phase = %2.2f degrees from crest',name,Amplitude,Phase);
    msgbox({'The matching fitting routine will use :' str});
end
guidata(hObject,handles);


% --- Executes on button press in refresh_optics.
function refresh_optics_Callback(hObject, eventdata, handles)

handles.optics=matching_opticsRefresh(handles.optics,handles);
if ismember(handles.optics(1).sector,{'LI28' 'LTUH' 'BSYLTU' 'UNDH' 'DMPH'})
    handles.optics=matching_opticsModel(handles.optics);
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function handles = sectorControl(hObject, handles, sector)

% Set both the string and enable bit to default values for 
% buttonmkb_assign, any time sector is changed
% (see function buttonMKB_Assign_Callback for more info
% This code block added 13 OCT 2010 by Chris Melton, AOSD Operations
set(handles.buttonMKB_Assign,'Enable','off');
set(handles.buttonMKB_Assign,'String','Waiting for match solution...');
%%%

handles.sectorSel=sector;
% handles.pathName =  '/usr/local/lcls/tools/matlab/toolbox/';
handles.pathName =  [fileparts(which('matching_gui')) filesep];

handles=gui_radioBtnControl(hObject,handles,'sectorSel',sector, ...
    numel(handles.sector.nameList) > 0,'_btn');
%handles.pathName = '/u1/lcls/matlab/matching/';
global modelBeamPath
modelBeamPath = 'CU_HXR';
switch sector
    case 'IN20'
%        handles.fileName = 'config_Injector_PROD.config';
        handles.fileName = 'config_LH_PROD.config';
    case 'SPEC'
%        handles.fileName = 'config_Injector_YAG04.config';
        handles.fileName = 'config_SPEC_PROD.config';
    case 'LI21'
        handles.fileName = 'config_BC1_PROD.config';
    case 'LI28'
        handles.fileName = 'config_Linac_PROD.config';
    case 'LTUH'
        handles.fileName = 'config_LTU_PROD.config';
    case 'LTUS'
        handles.fileName = 'config_LTUS_PROD.config';
        modelBeamPath = 'CU_SXR';
    case 'BSYLTU'
        handles.fileName = 'config_BSY_PROD.config';
    case 'UNDH'
        handles.fileName = 'config_UND_PROD.config';
%        handles.fileName = 'config_UND_TEST.config';
    case 'DMPH'
        handles.fileName = 'config_DMP_PROD.config';
    case 'NLCTA77'
        handles.fileName = 'config_NLCTA77_PROD.config';
    case 'NLCTA78'
        handles.fileName = 'config_NLCTA78_PROD.config';
    case 'XT01'
        handles.fileName = 'config_XT01_PROD.config';
    case 'LI02'
        handles.fileName = 'config_LI02_PROD.config';
    case 'LI18'
        handles.fileName = 'config_LI18_PROD.config';    
    case 'LI20'
        handles.fileName = 'config_LI20_PROD.config';
end

source=[];
if ismember(sector,{'LTUS','LTUH' 'BSYLTU' 'UNDH' 'DMPH' 'NLCTA77' 'NLCTA78' 'XT01' 'LI28'})
    source='MATLAB';
end
if ismember(sector,{'LI02' 'LI18' 'LI20'})
    source='SLC';
end
gui_modelSourceControl(hObject,handles,source);

handles = matching_opticsLoad(handles);
handles.optics = matching_beamlineModify(handles.optics,'quad',2,1); % Test!!!!
handles.optics = matching_beamlineModify(handles.optics,'drift',2,3); % Test!!!!
handles.optics = matching_beamlineModify(handles.optics,'screen',2,1); % Test!!!!
handles.optics=matching_opticsRefresh(handles.optics,handles);
handles=twissLocControl(hObject,handles,[]);

if ismember(sector,{'LI28' 'LTUH' 'LTUS' 'BSYLTU' 'UNDH' 'DMPH' 'NLCTA77' 'NLCTA78' 'XT01' 'LI02' 'LI18' 'LI20'})
    handles.optics = matching_beamlineModify(handles.optics,'screen',2,1);
    handles.optics = matching_beamlineModify(handles.optics,'matrix',2,1);
    handles.optics=matching_opticsModel(handles.optics);
end
%handles.optics = matching_beamlineModify(handles.optics,'bend',2,3); % Test only
%handles.optics = matching_beamlineModify(handles.optics,'linac',2,3); % Test only
guidata(hObject,handles);
handles=measured_Callback(hObject,[],handles);
handles=undQuadControl(hObject,handles,[]);


% --- Executes on button press in sectorSel_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag)

sectorControl(hObject,handles,tag);


function tolF_txt_Callback(hObject, eventdata, handles)

gui_editControl(hObject,handles,'tolF',str2double(get(hObject,'String')));


function tolX_txt_Callback(hObject, eventdata, handles)

gui_editControl(hObject,handles,'tolX',str2double(get(hObject,'String')));


function bmag_txt_Callback(hObject, eventdata, handles)


function gain_txt_Callback(hObject, eventdata, handles)


% --- Executes on button press in measured.
function handles = measured_Callback(hObject, eventdata, handles)

if ismember(handles.optics(1).sector,{'UNDH' 'DMPH'}) && ~strncmp(handles.optics(1).measured,'BFW',3)
    vals=model_twissGet(handles.optics(1).measured,'TYPE=DESIGN');vals=[{1 1};num2cell(vals(2:3,:))];
% elseif ismember(handles.optics(1).sector,{'LI02'})
%     vals=model_twissGet(handles.optics(1).measured,'TYPE=DATABASE');vals=[{1 1};num2cell(vals(2:3,:))];
%elseif ismember(handles.optics(1).sector,{'DMPH'})
%    vals=model_twissGet(handles.optics(1).measured);vals=[{1 1};num2cell(vals(2:3,:))];
else
    vals=control_emitGet(handles.optics(1).measured);vals(1,:)=vals(1,:)*1e6;
    vals(1,isnan(vals(1,:)))=1;
    vals=num2cell(vals);
end
[handles.ex,handles.ey]=deal(vals{1,:});

strList=cellstr(num2str([vals{2:3,:}]','%2.4f'));
set([handles.betax handles.alphax handles.betay handles.alphay],{'String'},strList);

guidata(hObject,handles);
handles=matching_init(hObject,handles);


% --- Executes on button press in restore_previous.
function restore_previous_Callback(hObject, eventdata, handles)

if ~isfield(handles.optics,'K_old'), return, end
nquad = handles.optics(1).location;
[handles.optics(nquad).KL] = deal(handles.optics(nquad).K_old);
%for i = nquad(:)'
%    handles.optics(i).KL = handles.optics(i).K_old;
%end
matching_updateMagnets(handles,'bFit'); % Don't revert fit display
trimMagnets(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

if ~isfield(handles.optics,'K_old'), return, end
handles.exportFig=figure;
subplot(2,1,1);box on
ax=handles.axes_beta;
copyobj(get(ax,'Children'),gca);
tag={'XLabel' 'YLabel' 'Title'};
h=copyobj(cell2mat(get(ax,tag)),gca);set(gca,tag,num2cell(h'));
set(gca,'XLim',get(ax,'XLim'));
set(gca,'YLim',get(ax,'YLim'));
title(gca,['Matching ' handles.sectorSel ' ' datestr(now)]);
nquad = handles.optics(1).location;

str1={'Quad' handles.optics(nquad).type}';
str2=[{'Old (kG)'};cellstr(num2str([handles.optics(nquad).K_old]','%7.3f'))];
str3=[{'New (kG)'};cellstr(num2str([handles.optics(nquad).KL]','%7.3f'))];
opts={'Units' 'normalized' 'VerticalAlignment' 'top'};
text(.1,.95,str1,opts{:});
text(.3,.95,str2,opts{:});
text(.5,.95,str3,opts{:});

subplot(2,1,2);box on
ax=handles.axes_sigma;
copyobj(get(ax,'Children'),gca);
tag={'XLabel' 'YLabel' 'Title'};
h=copyobj(cell2mat(get(ax,tag)),gca);set(gca,tag,num2cell(h'));
set(gca,'XLim',get(ax,'XLim'));
set(gca,'YLim',get(ax,'YLim'));

util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',10);
if val
    util_appPrintLog(handles.exportFig,'Matching',[handles.sectorSel ' on ' reshape(handles.optics(1).reference',1,[])],now);
%    dataSave(hObject,handles,0);
end


% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)

dataExport(hObject,handles,1);


% -----------------------------------------------------------
function handles = trimMagnets(hObject, handles)

% Sets quadrupoles to new values
nquad = handles.optics(1).location;
pvName={handles.optics(nquad).type};
value=[handles.optics(nquad).KL];
opts.action='TRIM';
gui_statusDisp(handles,['Setting magnets ' sprintf('%s ',pvName{:}) '...']);
BACT=control_magnetSet(pvName,value,opts)';
BACT=num2cell(BACT);
str=[pvName;num2cell(value)];
gui_statusDisp(handles,['Setting magnets ' sprintf('%s %g ',str{:}) 'done.']);
[handles.optics(nquad).KL]=deal(BACT{:});
guidata(hObject,handles);
matching_updateMagnets(handles,'bAct');


% --- Executes on selection change in twissLoc_pmu.
function twissLoc_pmu_Callback(hObject, eventdata, handles)

handles=twissLocControl(hObject,handles,get(hObject,'Value'));
measured_Callback(hObject,[],handles);


% --- Executes on selection change in measLoc_pmu.
function measLoc_pmu_Callback(hObject, eventdata, handles)

handles=measLocControl(hObject,handles,get(hObject,'Value'));
measured_Callback(hObject,[],handles);


% --------------------------------------------------------------------
function handles = measLocControl(hObject, handles, name)

if isempty(name)
    name=handles.optics(1).measured;
end
sectorId=handles.optics(1).sector;
nameList=handles.sector.(sectorId).measMADList;
if isnumeric(name)
    name=nameList{name};
end
val=find(strcmp(nameList,name));
if isempty(val)
    if isempty(nameList), nameList{1}=name;end
    val=1;name=nameList{1};
end
set(handles.measLoc_pmu,'Value',val,'String',nameList);
handles.optics(1).measured=name;
guidata(hObject,handles);


% --------------------------------------------------------------------
function handles = twissLocControl(hObject, handles, name)

if isempty(name)
    name=handles.optics(1).reference;
end
sectorId=handles.optics(1).sector;
nameList=handles.sector.(sectorId).locMADList;
if isnumeric(name)
    name=nameList{name};
end
name=cellstr(name);
if length(name) > 1, name=[name{1} ' ' name{2}];end
name=char(name);
val=find(strcmp(nameList,name));
goals=[handles.sector.(sectorId).goalList{val}];
if strcmp(sectorId,'UNDH')
    goals(1:4)=reshape(model_undMatch,1,[]);
end
if ~isempty(goals), handles.goals = goals;end
if isempty(val),nameList{end+1}=name;val=length(nameList);end
set(handles.twissLoc_pmu,'Value',val,'String',nameList);
tok={};while ~isempty(name), [tok{end+1},name]=strtok(strtrim(name),' ');end
handles.optics(1).reference=char(tok(:));
guidata(hObject,handles);
handles=measLocControl(hObject,handles,tok{1});
matching_updateGoals(handles);


% -----------------------------------------------------------
function optics = compress_optics(opticsIn,Ek)

ref=cellstr(handles.optics(1).reference);
screen_ref = find(strcmp({handles.optics.type},ref{1}));

opticsIn=opticsIn(1:screen_ref);
opticsIn = modify_beamline(opticsIn,{'drift' 'quad' 'linac' 'screen'},2,1);
n=length(opticsIn);

SIG = zeros(6,6);
X(:,1)= [0 0 0 0 0 0 Ek]';
[SIGout,SIGMAout,Xout,zVect,rMat] = matching_transport(opticsIn,SIG,X);
loc=opticsIn(1).location;
optics(1)=opticsIn(1);
k0=1;cnt=0;
locN=cumsum((diff([0;loc(:)]) > 1)+1);
optics(locN)=opticsIn(loc);
optics(1).location=locN;
for j=1:length(loc)+1
    R=eye(6);k1=n;
    if j <= length(loc), k1=loc(j)-1;end
    for k=k0:k1
        R=rMat(:,:,k+1)*R;
    end
    if k0 <= k1
        cnt=cnt+1;
        optics(cnt).name='matrix';
        optics(cnt).type = '';
        optics(cnt).length = zVect(k1+1)-zVect(k0);
        optics(cnt).nsegment = 1;
        optics(cnt).KL = 0;
        optics(cnt).sign = 0;
        optics(cnt).factorE1 = 0;
        optics(cnt).factorE2 = 0;
        optics(cnt).angle = 0;
        optics(cnt).roll = 0;
        optics(cnt).hgap = 0;
        optics(cnt).FINT = 0.5;
        optics(cnt).R=R;
        optics(cnt).en=Xout(7,k1+1)*1e-3;
        if isfield(opticsIn,'rqq')
            optics(cnt).rqq=opticsIn(k1).rqq;
            if cnt > 1, optics(cnt-1).rqq=eye(6);end
        end
    end
    cnt=cnt+1;k0=loc(min(end,j))+1;
end
optics(end).type=opticsIn(end).type;

optics=matching_beamlineModify(optics,[],0,[]);


% --- Executes on button press in modelSource_btn.
function modelSource_btn_Callback(hObject, eventdata, handles)

val=gui_modelSourceControl(hObject,handles,[]);
gui_modelSourceControl(hObject,handles,mod(val,3)+1);
%gui_modelSourceControl(hObject,handles,get(hObject,'Value')+1);


% -----------------------------------------------------------
function handles = undQuadControl(hObject, handles, val)

%[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
vis=strcmp(handles.sectorSel,'UNDH');
if isempty(val) && vis, val=abs(control_magnetGet('QU01','BDES'));end
handles=gui_editControl(hObject,handles,'undQuad',val,1,vis,[1 .1 40]);
state={'Off' 'On'};
set([handles.undQuadLabel_txt handles.undQuadTrim_btn],'Visible',state{vis+1});


function undQuad_txt_Callback(hObject, eventdata, handles)

undQuadControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in undQuadTrim_btn.
function undQuadTrim_btn_Callback(hObject, eventdata, handles)

name=model_nameConvert('QUAD',[],'UNDH');
bSign=sign(control_magnetGet(name,'BDES'));
control_magnetSet(name,bSign*handles.undQuad,'action','TRIM');


% --- Executes on button press in trimDesign_btn.
function trimDesign_btn_Callback(hObject, eventdata, handles)

nquad = handles.optics(1).location;
if ~isfield(handles.optics,'K_old')
    [handles.optics(nquad).K_old]=deal(handles.optics(nquad).KL);
end
for j = 1:numel(nquad)
%    result = handles.optics(i).KL;
%    result = str2double(get(handles.(['edit' num2str(j+59)]),'String'));
    str='';if j > 1, str=num2str(j);end
    result=str2double(get(handles.(['bDesign' str '_txt']),'String'));
    handles.optics(nquad(j)).KL = result;
end

% Sets quadrupoles to new values
trimMagnets(hObject,handles);


% --- Executes on button press in startDesign_box.
function startDesign_box_Callback(hObject, eventdata, handles)

gui_checkBoxControl(hObject,handles,'startDesign',get(hObject,'Value'));


% --- Executes on button press in updateMeas_box.
function updateMeas_box_Callback(hObject, eventdata, handles)

gui_checkBoxControl(hObject,handles,'updateMeas',get(hObject,'Value'));


function betax_Callback(hObject, eventdata, handles)

matching_init(hObject,handles);


function alphax_Callback(hObject, eventdata, handles)

matching_init(hObject,handles);


function betay_Callback(hObject, eventdata, handles)

matching_init(hObject,handles);


function alphay_Callback(hObject, eventdata, handles)

matching_init(hObject,handles);


% -----------------------------------------------------------
function goalControl(hObject, handles, num, id, val)

handles.goals(id+(num-1)*4)=val;
matching_init(hObject,handles);


function goalbx_txt_Callback(hObject, eventdata, handles, num)

if nargin < 4, num=1;end
goalControl(hObject,handles,num,1,str2double(get(hObject,'String')));


function goalax_txt_Callback(hObject, eventdata, handles, num)

if nargin < 4, num=1;end
goalControl(hObject,handles,num,2,str2double(get(hObject,'String')));


function goalby_txt_Callback(hObject, eventdata, handles, num)

if nargin < 4, num=1;end
goalControl(hObject,handles,num,3,str2double(get(hObject,'String')));


function goalay_txt_Callback(hObject, eventdata, handles, num)

if nargin < 4, num=1;end
goalControl(hObject,handles,num,4,str2double(get(hObject,'String')));


function fitbx_txt_Callback(hObject, eventdata, handles)


function fitax_txt_Callback(hObject, eventdata, handles)


function fitby_txt_Callback(hObject, eventdata, handles)


function fitay_txt_Callback(hObject, eventdata, handles)

function BEAMPATH = check_beampath(name,type)
BEAMPATH = '';
[name_HXR,~,~] = model_nameRegion(type,'CU_HXR');
[name_SXR,~,~] = model_nameRegion(type,'CU_SXR');
name = model_nameConvert(name,'EPICS');
isHXR = sum(ismember(name_HXR,name));
isSXR = sum(ismember(name_SXR,name));
if isSXR
    BEAMPATH = 'CU_SXR';
end
if isHXR
    BEAMPATH = 'CU_HXR';
end


% --- Executes on button press in buttonMKB_Assign.
function buttonMKB_Assign_Callback(hObject, eventdata, handles)

%
%                     NOTES ON THIS FUNCTION:
%
% This function was added on 12 OCT 2010 by Chris Melton,
% AOSD Operations.  This function takes the Fit Result generated
% from the "run" callback, and allows the creation of a multiknob
% file which can be used by an operator to smoothly and 
% incrementally implement the match solution. This allows 
% parasitic tuning while delivering beam to users, without 
% interrupting beam operations.
%
% To support this function, a few additions have been
% made to the code in this file, matching_gui.m :
% 1) At end of function appInit(), Enable for buttonmkb_assign is set to 'off'
% 2) At start of function sectorControl(), both String and Enable for buttonMKB_assign are set to defaults
% 3) At end of function matching_run(), String and Enable are set for button use
% 

fprintf('Beta matching multiknob being created...\n');
debug = 1; % self-explanatory

% Initialize
secs = handles.sectorSel;
nquad = handles.optics(1).location;
device = handles.optics(nquad).type; % pvName in above code but is EPICS ident
pvSub = zeros(1,length(nquad));
target = zeros(1,length(nquad));
now = zeros(1,length(nquad));
switch secs % there has to be an easier way to pull this out of the model !?!
    case 'IN20'
        pvSub = {'QUAD:IN20:361:BCTRL' 
                     'QUAD:IN20:371:BCTRL' 
                     'QUAD:IN20:425:BCTRL' 
                     'QUAD:IN20:441:BCTRL' 
                     'QUAD:IN20:511:BCTRL' 
                     'QUAD:IN20:525:BCTRL' 
                     };
    case 'LI21'
        pvSub = {'QUAD:LI21:201:BCTRL' 
                     'QUAD:LI21:211:BCTRL' 
                     'QUAD:LI21:271:BCTRL' 
                     'QUAD:LI21:278:BCTRL' 
                     };
    case 'LI28'
        pvSub = {'QUAD:LI26:201:BCTRL' 
                     'QUAD:LI26:301:BCTRL' 
                     'QUAD:LI26:401:BCTRL' 
                     'QUAD:LI26:501:BCTRL' 
                     'QUAD:LI26:601:BCTRL' 
                     'QUAD:LI26:701:BCTRL' 
                     'QUAD:LI26:801:BCTRL'   
                     'QUAD:LI26:901:BCTRL'                       
                     };
    case 'LTUH' 
        pvSub = {'QUAD:LTUH:620:BCTRL' 
                     'QUAD:LTUH:640:BCTRL' 
                     'QUAD:LTUH:660:BCTRL' 
                     'QUAD:LTUH:680:BCTRL' 
                     };
    case 'LTUS'
        pvSub = {'QUAD:LTUS:620:BCTRL' 
                     'QUAD:LTUS:640:BCTRL' 
                     'QUAD:LTUS:660:BCTRL' 
                     'QUAD:LTUS:680:BCTRL' 
                     };
    otherwise
        fprintf('The multiknob match solution for the machine region selected (%s) is not available\n',secs);
        set(handles.buttonMKB_Assign,'String','Region Not Available');
        return;
end

% Pull quad values from the Run calculation
for i = 1:length(nquad)
    now(i) = handles.optics(nquad(i)).K_old;
    target(i) = handles.optics(nquad(i)).KL;
    fprintf('\nFor the %s quad #%g, the target strength is %7.3f kG.\n',secs,i,target(i));
    fprintf('The PV %s will be loaded into the multiknob file for quad #%g\n\n',char(pvSub{i}),i);
end

% Calculate multiknob coeffs
fprintf('* Calculating coefficients for multiknob file...*\n');
set(handles.buttonMKB_Assign,'String','Calculating coeffs...');
gainSet = str2double(get(handles.gain_txt,'String'));
sens = 10.0; % hard-coded now, may be variable later
normTurns = 10; % normalization coefficient so 1 turn = 10%

coeffs = zeros(1,length(nquad));
coeffs = (target-now)/(gainSet*sens*normTurns); % magnified by the gain field

fprintf('The coeff matrix is %s\n\n',num2str(coeffs));

% Determine the multiknob assignment slot to use
for slot=1:50
        fnam = cat(2,cat(2,'MKB:SYS0:',num2str(slot)),':FILE');
        knam = cat(2,cat(2,'MKB:SYS0:',num2str(slot)),':VAL');
        farray = lcaGet(fnam);
        if farray(1)>=32  % mkb PV definitely in use, so keep searching
            fprintf('File %s in use\n',fnam)
        elseif (length(farray)==256)&&(farray(1)==0)&&(farray(11)==0)&&(farray(21) == 0) % not in use
            writePV = fnam;
            break;
        end
end
fprintf('First file PV available: %s\n\n',writePV);

% Write the multiknob XML elements
set(handles.buttonMKB_Assign,'String','Writing XML file...');
pause(1);
try
    if debug, disp('Opening XML file stream for mkb creation'), end;
    mkbit = fopen('/u1/lcls/physics/mkb/Beta_match_gui','w');
    fprintf(mkbit,'<?xml version="1.0" encoding="UTF-8"?>\n<!--\nBeta Match GUI Multiknob Creator v1.0 by Chris Melton\nCreated 12-OCT-2010\n-->\n<mkb>\n');
    fprintf(mkbit,'   <set label="%sMATCH"',secs);
    fprintf(mkbit,' sens="%s" desc="Beta Match Multi-Knob for %s region" egu="%%"/>\n',num2str(sens),secs);
    for i=1:length(nquad)
        fprintf(mkbit,'   <def dev="%s" coeff="%s"/>\n',char(pvSub{i}),num2str(coeffs(i)));
    end
    fprintf(mkbit,'</mkb>\n');
    if debug, disp('closing file stream'), end;
    fclose(mkbit);
catch
    fprintf('Error opening/writing to filestream for mkb XML file.\n');
end
if debug, disp('finished writing XML file'), end;

% Assign the mkb file to the designated multiknob slot and give user the information
set(handles.buttonMKB_Assign,'String','Assigning XML to mkb PV...');
pause(1);
farray_= zeros(1,256);
farray_(1:35)=double('/u1/lcls/physics/mkb/Beta_match_gui');
lcaPut(writePV,farray_);
fprintf('XML file assigned %s for magnets in region %s\n',writePV,secs);
set(handles.buttonMKB_Assign,'String',knam);

% Prompt user to assign the mkb file to an EPICS knob
prompt = {'EPICS knob box to use:','Knob assignment slot:'};
def ={'2','0'};
options.Resize='off'; options.WindowStyle='modal';
assign = inputdlg(prompt,'Where to assign mkb?', 1, def, options);
if ~isempty(char(assign))
    kloc = sprintf('MKB on EPICS Box %s Knob %s',assign{:});
    boxasn = sprintf('KNOB:SYS0:%s:K%s_DEVNAME',assign{:});
    lcaPut(boxasn,knam);
    set(handles.buttonMKB_Assign,'String',kloc);
else
    fprintf('\n** User chose not to assign the mkb file to a knob. You must do this manually now. **\n');
    set(handles.buttonMKB_Assign,'String',cat(2,knam,' no knob'));
end
set(handles.buttonMKB_Assign,'Enable','off'); % to prevent over-acquisition of mkb PV slots by multiple use
disp('Multiknob creation complete');
