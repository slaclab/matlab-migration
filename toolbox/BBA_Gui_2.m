function varargout = BBA_Gui_2(varargin)
% BBA_GUI_2 MATLAB code for BBA_Gui_2.fig
%      BBA_GUI_2, by itself, creates a new BBA_GUI_2 or raises the existing
%      singleton*.
%
%      H = BBA_GUI_2 returns the handle to a new BBA_GUI_2 or the handle to
%      the existing singleton*.
%
%      BBA_GUI_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BBA_GUI_2.M with the given input arguments.
%
%      BBA_GUI_2('Property','Value',...) creates a new BBA_GUI_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BBA_Gui_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BBA_Gui_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BBA_Gui_2

% Last Modified by GUIDE v2.5 27-Jan-2021 10:05:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BBA_Gui_2_OpeningFcn, ...
                   'gui_OutputFcn',  @BBA_Gui_2_OutputFcn, ...
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


% --- Executes just before BBA_Gui_2 is made visible.
function BBA_Gui_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BBA_Gui_2 (see VARARGIN)

% Choose default command line output for BBA_Gui_2
handles.output = hObject;
handles.number_of_bba_preparation_actions=12;
handles.FitForBBADir='/u1/lcls/matlab/SMAC_Data/BBA_ModelData';
handles.FitForOP='/u1/lcls/matlab/SMAC_Data/orbitPatchwork_ModelData';
ColorOn=[0,1,0]; ColorWait=[1,1,0]; ColorOff=[1,0,0]; ColorON=[0,1,0];
handles.UndulatorLineFunctions_handler=ULT_UndulatorLine_functions();
handles.sf=Steering_Functions();
handles.MODEL_TYPE='TYPE=EXTANT';
set(handles.ECT,'visible','off')
handles.SaveDir='/u1/lcls/matlab/ULT_GuiData';
try 
    if(strcmp(varargin{1},'test'))
        handles.ONLINE=2;
        addpath('/afs/slac/g/ad/simul/BBA');
        set(handles.ECT,'visible','on');
    else
        handles.ONLINE=1;
    end
catch
    handles.ONLINE=1;
end
%lcaGetSmart('SIOC:SYS0:ML02:AO314');
if (isnan(handles.ONLINE))
    handles.ONLINE=0;
    InitUndulatorLine;
    handles.MODEL=MODEL;
    save FAKE_Beamlinestate UL
else
    try
        load([handles.SaveDir,'/UL.mat'])
    catch
        InitUndulatorLine_Machine;
    end
end

handles.ONLINE

handles.ColorIdle=get(handles.pushbutton3,'backgroundcolor');
handles.ColorOn=ColorOn; handles.ColorOff=ColorOff; handles.ColorWait=ColorWait; handles.ColorLogBook=[0.4,0.4,1]; handles.ColorError=[1,0,0];
handles.ColorOk=[0,0,0];
set(handles.ULS,'visible','on'); set(handles.PA,'visible','off'); set(handles.BBA_PANEL,'visible','off'); set(handles.ApplyBBA,'visible','off')
try
   handles.PhyConsts=load('NonExistingFile'); 
catch
   handles.PhyConsts.c=299792458;
   handles.PhyConsts.mc2_e=5.109989180000000e+05;
   handles.PhyConsts.echarge=1.602176530000000e-19;
   handles.PhyConsts.mu_0=1.256637061435917e-06;
   handles.PhyConsts.eps_0=8.854187817620391e-12;
   handles.PhyConsts.r_e=2.817940318198647e-15;
   handles.PhyConsts.Z_0=3.767303134617707e+02;
   handles.PhyConsts.h_bar=1.054571682364455e-34; %J s
   handles.PhyConsts.alpha=0.007297352554051;
   handles.PhyConsts.Avogadro=6.022141500000000e+23;
   handles.PhyConsts.k_Boltzmann=1.380650500000000e-23;
   handles.PhyConsts.Stefan_Boltzmann=5.670401243654186e-08;
   handles.PhyConsts.hplanck=4.135667516*10^-15; %eV s -> photon energy [eV] = hplanck [eV s] cluce [m/s] / lambda [m]; 
end

handles.UL=UL;
handles.static=static;
set(handles.UL_SELECT,'string',{handles.UL.name}); set(handles.UL_SELECT,'value',1);
% Update handles structure
handles.UniqueGuiRunString=['BBA GUI ',datestr(now)];
set(handles.FN,'string',handles.UniqueGuiRunString);
guidata(hObject, handles);
% UIWAIT makes BBA_Gui_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BBA_Gui_2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles=ReadUndulatorBeamline(handles)
if(handles.ONLINE)
    [handles.UL_SELECT,ES]=UUT_BuildUndulatorLinesScript();
else
     load FAKE_Beamlinestate
     handles.UL=UL;
end

% --- Executes on selection change in UL_SELECT.
function UL_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to UL_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns UL_SELECT contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UL_SELECT


% --- Executes during object creation, after setting all properties.
function UL_SELECT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UL_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UL_OK.
function handles=UL_OK_Callback(hObject, eventdata, handles)
ID=get(handles.UL_SELECT,'value');
handles.eDefNumber=Reserve_Callback(hObject, eventdata, handles);
handles.UL=handles.UL(ID);
handles.static=handles.static(ID);
handles.MODEL_TYPE='TYPE=EXTANT';
if(ID==1)
    handles.BEAMPATH=['BEAMPATH=','CU_HXR'];
    eDefParams (handles.eDefNumber, 1, 2800, [], [], [], [], 1);
    handles.BEAMCODE=1;
elseif(ID==2)
    handles.BEAMCODE=2;
    handles.BEAMPATH=['BEAMPATH=','CU_SXR'];
    eDefParams (handles.eDefNumber, 1, 2800, [], [], [], [], 2);
    REMOVEBPM=3;
    REMOVEQUAD=4;
    REMOVECORR=7; CHF=length(handles.static.corrList)/2;
    REMCORR=[1:REMOVECORR,CHF+(1:REMOVECORR)];
    handles.static.bpmList(1:REMOVEBPM)=[]; handles.static.bpmList_e(1:REMOVEBPM)=[]; handles.static.zBPM(1:REMOVEBPM)=[]; handles.static.lBPM(1:REMOVEBPM)=[];
    handles.static.quadList(1:REMOVEQUAD)=[]; handles.static.quadList_e(1:REMOVEQUAD)=[]; handles.static.zQuad(1:REMOVEQUAD)=[]; handles.static.lQuad(1:REMOVEQUAD)=[];
    handles.static.corrList(REMCORR)=[]; handles.static.corrList_e(REMCORR)=[]; handles.static.zCorr(REMCORR)=[]; handles.static.lCorr(REMCORR)=[];
    handles.static.corrRange(REMCORR,:)=[]; handles.static.quadRange(1:REMOVEQUAD,:)=[];
end
guidata(hObject, handles);
if(ID==1)
   set(handles.emin,'string','4000'); set(handles.emax,'string','14000'); set(handles.esteps,'string','4');
   
else
   set(handles.emin,'string','3500'); set(handles.emax,'string','10000'); set(handles.esteps,'string','4');
end
pushbutton25_Callback(hObject, eventdata, handles)
for II=1:handles.number_of_bba_preparation_actions
    set(handles.(['d',num2str(II)]),'value',1);
end
set(handles.ULSTRING,'string',['Undulator Line: ',handles.UL.name]);
set(handles.text5,'string',['Undulator Line: ',handles.UL.name]);
set(handles.ULS,'visible','off'); set(handles.PA,'visible','on'); set(handles.BBA_PANEL,'visible','off');set(handles.ApplyBBA,'visible','off')


% --- Executes on button press in pushbutton3.
function handles=pushbutton3_Callback(hObject, eventdata, handles)
handles.BBA_Energies=str2num(get(handles.BBA_Energies_editbox,'string'));
DATA={}; EnergyName={}; Data={};
for II=1:length(handles.BBA_Energies), DATA{1,II}=' Data Missing '; Data{1,II}=[]; EnergyName{end+1}=num2str(handles.BBA_Energies(II)); end

handles.Pos.nBPM=length(handles.static.bpmList);
handles.Pos.nQuad=length(handles.static.quadList);
handles.Pos.nCorr=length(handles.static.corrList);
handles.Pos.nUnd=length(handles.static.undList);

[~, MP] = min(handles.static.zBPM);
handles.StartBPM=handles.static.bpmList{MP};

handles.ToList=[handles.static.bpmList;handles.static.quadList;handles.static.quadList;handles.static.corrList;handles.static.undList;handles.static.undList];
handles.PosList=[repmat({'POSB=END'},length(handles.static.bpmList),1);repmat({'POSB=BEG'},length(handles.static.quadList),1);repmat({'POSB=END'},length(handles.static.quadList),1);repmat({'POSB=END'},length(handles.static.corrList),1);repmat({'POSB=BEG'},length(handles.static.undList),1);repmat({'POSB=END'},length(handles.static.undList),1)];

handles.Pos.Bpm=1:handles.Pos.nBPM;
handles.Pos.QuadBeg=handles.Pos.nBPM+(1:handles.Pos.nQuad);
handles.Pos.QuadEnd=handles.Pos.nBPM+handles.Pos.nQuad+(1:handles.Pos.nQuad);
handles.Pos.Corr=handles.Pos.nBPM+2*handles.Pos.nQuad+(1:handles.Pos.nCorr);
handles.Pos.UndBeg=handles.Pos.nBPM+2*handles.Pos.nQuad+handles.Pos.nCorr+(1:handles.Pos.nUnd);
handles.Pos.UndEnd=handles.Pos.nBPM+2*handles.Pos.nQuad+handles.Pos.nCorr+handles.Pos.nUnd+(1:handles.Pos.nUnd);

set(handles.TABLE,'data',DATA); set(handles.TABLE,'userdata',[]); set(handles.TABLE,'userdata',Data);
%set(handles.t10,'visible','off');
set(handles.TABLE,'columnname',EnergyName); set(handles.popupmenu3,'string',EnergyName); set(handles.popupmenu3,'value',1); set(handles.popupmenu3,'visible','off');set(handles.ApplyBBA,'visible','off')
set(handles.OEC,'value',0); set(handles.ApplyBBA,'visible','off')
set(handles.ULS,'visible','off'); set(handles.PA,'visible','off'); set(handles.BBA_PANEL,'visible','on');
if(~handles.ONLINE)
    set(handles.SIMUL,'visible','on');
    handles.MODEL_TYPE='TRACKER_SIMUL';
else
    if(handles.ONLINE==2)
        handles.MODEL_TYPE='TYPE=EXTANT';
    else
        handles.MODEL_TYPE='TYPE=EXTANT';
    end
end
handles.ModelRMatGet_STRING=handles.PosList;
handles.ModelRMatGet_STRING{end+1}=handles.MODEL_TYPE;
handles.ModelRMatGet_STRING{end+1}=handles.BEAMPATH;
handles.ModelRMatGet_STRING{end+1}='SelPosUse=BBA';

guidata(hObject, handles);




% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TakeData.
function TakeData_Callback(hObject, eventdata, handles)
%Take Data and Model & Save data.
TABLE=get(handles.TABLE,'data');
Samples=str2double(get(handles.SampleAmount,'string'));
Energy=lcaGetSmart(handles.UL.Basic.EBeamEnergyPV); % GeV
ExcludeNaN=get(handles.ExcludeNaN,'value');

if(~get(handles.OEC,'value'))
    if(all(abs(handles.BBA_Energies-Energy*1000)>200))
        Message=['Current machine energy is: ',num2str(Energy*1000),' MeV is more than 200 MeV off from any selected BBA_Energy.',char(13),' Selected BBA Energies are: ',char(13),num2str(handles.BBA_Energies)];
        warndlg(Message,'Energy off range')
        return
    else
       [~,EnergyID]=min(abs(handles.BBA_Energies-Energy*1000)); 
    end
else
    EnergyID=get(handles.popupmenu3,'value');
end

handles.MODEL_TYPE

if(any(strfind(handles.BEAMPATH,'CU_SXR')))
    model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
elseif(any(strfind(handles.BEAMPATH,'CU_HXR')))
    model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
end

if(handles.ONLINE)
    %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(handles.StartBPM,handles.ToList,{handles.MODEL_TYPE,handles.BEAMPATH},handles.PosList);
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(handles.StartBPM,handles.ToList,handles.ModelRMatGet_STRING);
else
    %[Data.MODEL,Data.Energy] = Get_Model(handles.static,~handles.ONLINE);
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(handles.StartBPM,handles.ToList,handles.PosList);
end

disp(['Model Energy: ',num2str(median(MODEL.energy))]);
if (norm(MODEL.rMat(:,:,handles.Pos.QuadBeg(1) ) - MODEL.rMat(:,:,handles.Pos.QuadEnd(1)))==0)
    disp('Quadrupole offset matrix are WRONG. Beginning and End of Quadrupole are identical');
else
    disp('No obvious error in quadrupole matrices')
end

Data.MODEL=MODEL;
Data.MODEL_Original=Data.MODEL;
QuadrupoleStrengths=lcaGetSmart(strcat(handles.static.quadList_e,':BCTRL'));
CorrectorStrengths=lcaGetSmart(strcat(handles.static.corrList_e,':BCTRL'));

CORRECTORUND=cellfun(@(x) ~isempty(x),strfind(handles.static.corrList_e,'UND'));
if(any(CorrectorStrengths(CORRECTORUND)~=0))
    Message=['SOME CORRECTORS IN UNDULATOR LINE ARE NOT ZERO, PLEASE CHECK'];
    warndlg(Message,'Correctors not zero!')
end

Data.MODEL.quadB=QuadrupoleStrengths;
Data.MODEL.corrB=CorrectorStrengths;
Data.MODEL.Pos=handles.Pos;
Data.MODEL.static=handles.static;

[Energy, EnergyID]

TABLE{1,EnergyID}='TAKING DATA';
set(handles.TABLE,'data',TABLE); drawnow
BSA=get(handles.useBSA,'value');
BBA_DATA=get(handles.TABLE,'userdata');

mintmit=util_pCtoTmit(str2double(get(handles.mincharge,'string')));

if(BSA)
    Data.Orbits=handles.sf.getBPMData_reserveBSA(handles.static.bpmList_e, Samples, 1, handles.eDefNumber,mintmit,[],ExcludeNaN,handles.BEAMCODE);
else
    Data.Orbits=handles.sf.getBPMData_caget(handles.static.bpmList_e, Samples, 1,mintmit,[]);
end
disp(['Collected: ',num2str(size(Data.Orbits,2)),' shots']);

if(get(handles.JollyFilter,'value'))
    disp('Filtering out shots that look too off...');
    XTEMP=Data.Orbits(1:length(handles.static.bpmList),:);
    YTEMP=Data.Orbits((1+length(handles.static.bpmList)):(2*length(handles.static.bpmList)),:); 
    TMITTEMP=Data.Orbits((1+2*length(handles.static.bpmList)):(3*length(handles.static.bpmList)),:); 
    
    mTMIT=min(TMITTEMP);
    OKTMIT=(mTMIT>3*10^8);
    
    AVGX=mean(XTEMP(:,OKTMIT),2);
    AVGY=mean(YTEMP(:,OKTMIT),2);
    
    for HH=1:size(XTEMP,2)
        ErrorLevelX(:,HH)=abs(XTEMP(:,HH)- AVGX);
        ErrorLevelY(:,HH)=abs(YTEMP(:,HH)- AVGY);
    end
    
    maxXE=max(abs(ErrorLevelX));
    maxYE=max(abs(ErrorLevelY));
    
    OKX=maxXE<0.04;
    OKY=maxYE<0.04;
    
    OKSHOTS = OKTMIT & OKX & OKY ;
    Data.Orbits=Data.Orbits(:,OKSHOTS);
    
    disp([num2str(sum(OKSHOTS)),' retained after filtering.']);
    
end
    
Data.Orbits_x=Data.Orbits(1:length(handles.static.bpmList_e),:);
Data.Orbits_y=Data.Orbits(1+length(handles.static.bpmList_e):2*length(handles.static.bpmList_e),:);
Data.Orbits_tmit=Data.Orbits(1+2*length(handles.static.bpmList_e):3*length(handles.static.bpmList_e),:);

BBA_DATA{1, EnergyID} = Data;
set(handles.TABLE,'userdata',BBA_DATA);
TABLE{1, EnergyID} = 'COLLECTED';
set(handles.TABLE,'data',TABLE);

function SampleAmount_Callback(hObject, eventdata, handles)
% hObject    handle to SampleAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampleAmount as text
%        str2double(get(hObject,'String')) returns contents of SampleAmount as a double


% --- Executes during object creation, after setting all properties.
function SampleAmount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useBSA.
function useBSA_Callback(hObject, eventdata, handles)
set(handles.useBSA,'value',1); set(handles.DoNotBSA,'value',0);


% --- Executes on button press in EvalBBA.
function EvalBBA_Callback(hObject, eventdata, handles)
Data=get(handles.TABLE,'userdata'); WarningMessage=[];
%handles.ONLINE=2
for II=1:length(handles.BBA_Energies)
   if(isempty(Data{1,II}))
       if(isempty(WarningMessage))
           WarningMessage='Missing Data.';
       end
      WarningMessage=[WarningMessage, 'Energy ',num2str(handles.BBA_Energies(II)),' MeV is missing']; 
   end 
end
if(~isempty(WarningMessage))
    warndlg(WarningMessage);
    return
end

options.UseForInit=[1,1,1,1,0,0];
options.fitBPMLin=0;
options.fitBPMMin=0;
options.fitQuadLin=1;
options.fitQuadKick=1;
options.fitQuadMin=0;
options.fitQuadAbs=0;

for TT=1:length(Data)
   AllDataModel{TT}=Data{TT}.MODEL; 
end

[Matrix,CMeas,Locations]=handles.sf.Build_BBA_Matrix(AllDataModel, options);

for II=1:length(handles.BBA_Energies)
    if(size(Data{1,TT}.Orbits_x,2)>1)
       AVG_x_Orbits = mean(Data{1,II}.Orbits_x,2);
       AVG_y_Orbits = mean(Data{1,II}.Orbits_y,2);
       STD_x_Orbits = std(Data{1,II}.Orbits_x.').'; %da controllare
       STD_y_Orbits = std(Data{1,II}.Orbits_y.').'; %da controllare
    else
       AVG_x_Orbits = Data{1,II}.Orbits_x;
       AVG_y_Orbits = Data{1,II}.Orbits_y;
       STD_x_Orbits = 10^-6*ones(size(AVG_x_Orbits));
       STD_y_Orbits = 10^-6*ones(size(AVG_y_Orbits));
    end
    OrbitMeas{II}=[AVG_x_Orbits.'; AVG_y_Orbits.'].';
    OrbitMeasStd{II}=[STD_x_Orbits.'; STD_y_Orbits.'].';
    %OrbitMeas{II}=[Data{1,TT}.Orbits_x; Data{1,TT}.Orbits_y].';
end

%save TEMPALL Matrix CMeas Locations OrbitMeas CumulativeR Data 1

disp('Solving BBA system')
[Offsets,lsqSolution]=handles.sf.SolveBBA_System(Matrix, OrbitMeas, OrbitMeasStd, CMeas, Locations);

Quad_X_Offsets=Offsets.Quad(1:2:end).';
BPM_X_Offsets=Offsets.Bpm(1:2:end).';
Quad_Y_Offsets=Offsets.Quad(2:2:end).';
BPM_Y_Offsets=Offsets.Bpm(2:2:end).';

Quad_X_OffsetsErr=Offsets.QuadErr(1:2:end).';
BPM_X_OffsetsErr=Offsets.BpmErr(1:2:end).';
Quad_Y_OffsetsErr=Offsets.QuadErr(2:2:end).';
BPM_Y_OffsetsErr=Offsets.BpmErr(2:2:end).';

for TT=1:length(handles.BBA_Energies)
   Init_Vector(:,TT)=Offsets.Init(1+(4*(TT-1)) : (4*TT)).'; 
   Init_VectorErr(:,TT)=Offsets.InitErr(1+(4*(TT-1)) : (4*TT)).'; 
end

BBA_Result.Quad_X_Offsets=Quad_X_Offsets;
BBA_Result.BPM_X_Offsets=BPM_X_Offsets;
BBA_Result.Quad_Y_Offsets=Quad_Y_Offsets;
BBA_Result.BPM_Y_Offsets=BPM_Y_Offsets;
BBA_Result.Init_Vector=Init_Vector;
BBA_Result.Quad_X_OffsetsErr=Quad_X_OffsetsErr;
BBA_Result.BPM_X_OffsetsErr=BPM_X_OffsetsErr;
BBA_Result.Quad_Y_OffsetsErr=Quad_Y_OffsetsErr;
BBA_Result.BPM_Y_OffsetsErr=BPM_Y_OffsetsErr;
BBA_Result.Init_VectorErr=Init_VectorErr;
BBA_Result.lsqSolution=lsqSolution;
BBA_Result.OrbitMeas=OrbitMeas;
BBA_Result.OrbitMeasStd=OrbitMeasStd;
BBA_Result.CMeas=CMeas;
BBA_Result.Matrix=Matrix;
BBA_Result.Locations=Locations;
BBA_Result.Energies=handles.BBA_Energies;
BBA_Result.static=handles.static;

BBA_Result.Data=Data;

if(handles.ONLINE==2)
    disp('Saving results locally to LAST_RESULTS file ...')   
    FN=get(handles.FN,'string');
    try
        mkdir(FN)
    end
    FILENAME=['RESULTS_',regexprep(datestr(now),':','-')];
     
    save([FN,'/',FILENAME],'Matrix','CMeas','Locations','OrbitMeas','BBA_Result','Data','Offsets','lsqSolution');
    set(handles.TEST,'visible','on');
else
    set(handles.TEST,'visible','off');
end
    
set(handles.APPLY,'userdata',BBA_Result);
[New_Figure, New_Figure2, New_Figure3, New_Figure4]=PlotResults_Callback(hObject, eventdata, handles);
if(1)
    util_printLog(New_Figure,'title','BBA Iteration');
    util_printLog(New_Figure2,'title','BBA Iteration');
    util_printLog(New_Figure3,'title','BBA Iteration');
    util_printLog(New_Figure4,'title','BBA Iteration');
end
set(handles.ApplyBBA,'visible','on');


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function BBA_Energies_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to BBA_Energies_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BBA_Energies_editbox as text
%        str2double(get(hObject,'String')) returns contents of BBA_Energies_editbox as a double


% --- Executes during object creation, after setting all properties.
function BBA_Energies_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BBA_Energies_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowData.
function ShowData_Callback(hObject, eventdata, handles)
SelectedCell=get(handles.ShowData,'userdata');
if(isempty(SelectedCell))
   warndlg('Please select a cell on the table to show data'); 
else
   Data=get(handles.TABLE,'userdata');
   DataToShow=Data{SelectedCell(1),SelectedCell(2)};
   if(isempty(DataToShow))
       warndlg(['The Energy: ',num2str(handles.BBA_Energies(SelectedCell(2))),' MeV has no data yet.']);
   else
       New_Figure=figure;
       set(New_Figure,'name',['Beam Based Alignment Data - Energy = ',num2str(median(DataToShow.MODEL.energy)) ,' MeV']);
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes('position',[0.1,0.1,0.85,0.35]);
       AY=axes('position',[0.1,0.55,0.85,0.35]);
       BPMz=DataToShow.MODEL.static.zBPM - min(DataToShow.MODEL.static.zBPM);
       if(numel(DataToShow.Orbits_x)>length(DataToShow.MODEL.static.bpmList))
           STDx=std(DataToShow.Orbits_x.'); STDy=std(DataToShow.Orbits_y.');
           MEAx=mean(DataToShow.Orbits_x.'); MEAy=mean(DataToShow.Orbits_y.');
           plot(AX,BPMz,DataToShow.Orbits_x,'color',[0.85,0.85,0.85])
           hold(AX,'on');
           plot(AX,BPMz,mean(DataToShow.Orbits_x,2),'color',[0,0,0],'linewidth',2);
           errorbar(AX,BPMz,MEAx,STDx,'-r')
           plot(AY,BPMz,DataToShow.Orbits_y,'color',[0.85,0.85,0.85])
           hold(AY,'on');
           plot(AY,BPMz,mean(DataToShow.Orbits_y,2),'color',[0,0,0],'linewidth',2);
           errorbar(AY,BPMz,MEAy,STDy,'-r')
           title(AY,'Y - Orbit'); title(AX,'X - Orbit');
           ylabel(AX,'[mm]'); ylabel(AY,'[mm]');
       else
           plot(AX,BPMz,DataToShow.Orbits_x,'color',[0,0,0],'linewidth',2)
           plot(AY,BPMz,DataToShow.Orbits_y,'color',[0,0,0],'linewidth',2)
       end
       %ylim(AX,[-0.03,0.03]); ylim(AY,[-0.03,0.03]);
       xlim(AX,[-1,163]); xlim(AY,[-1,163]);
       util_printLog(New_Figure,'title',['Beam Based Alignment Data - Energy = ',num2str(median(DataToShow.MODEL.energy)) ,' MeV']);
   end
end

% --- Executes when selected cell(s) is changed in TABLE.
function TABLE_CellSelectionCallback(hObject, eventdata, handles)
try
    Cell_Selected=eventdata.Indices(1,:);
    set(handles.ShowData,'userdata',Cell_Selected);
catch
    disp('Cell selection was called, with multiple or no selection')
end


% --- Executes when entered data in editable cell(s) in TABLE.
function TABLE_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to TABLE (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OEC.
function OEC_Callback(hObject, eventdata, handles)
if(~get(handles.OEC,'value'))
   set(handles.popupmenu3,'value',1); set(handles.popupmenu3,'visible','off'); set(handles.ApplyBBA,'visible','off')
   set(handles.text9,'visible','off');
else
   set(handles.popupmenu3,'visible','on');
   set(handles.text9,'visible','on');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
global Launch_Conditions
ENERGY=get(handles.edit3,'string');
ENE=str2double(ENERGY);
lcaPutSmart(handles.UL.Basic.EBeamEnergyPV,ENE);
Launch_Conditions(6)=ENE;
lcaGetSmart({[handles.MODEL.static.bpmList_e{1},':X']})


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
global Launch_Conditions

for HH=1:length(handles.BBA_Energies)
    Launch_Conditions(1:4)=randn(1,4)*10^-4;
set(handles.SampleAmount,'string','5');
set(handles.edit3,'string',num2str(handles.BBA_Energies(HH)));
drawnow; pause(0.1);
pushbutton9_Callback(hObject, eventdata, handles)
drawnow; pause(0.1);
TakeData_Callback(hObject, eventdata, handles)
end


% --- Executes on selection change in Selector.
function Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Selector


% --- Executes during object creation, after setting all properties.
function Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
D=get(handles.Selector,'userdata');
S=get(handles.Selector,'value');
if(S==1) %shows data vs orbits
    OrbitFit=D.Full.Matrix*D.Full.lsqSolution;
    New_Figure=figure;
    set(New_Figure,'name',['BBA-II. Fit results - Measured - Fitted orbits',''])
    Position=get(New_Figure,'position');
    set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
    AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
    AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
    hold(AX,'on'); hold(AY,'on');
    colors={'k','b','r','g','c','y'};
    for HH=1:length(handles.BBA_Energies)
        
        OFit=OrbitFit(1:(end-length(D.Full.CMeas)));
        Bpm2Length=2*length(D.Full.BPM_X_Offsets);
        O=OFit((Bpm2Length*(HH-1)+1) : (Bpm2Length*HH));
        OX=O(1:2:end);
        OY=O(2:2:end);
        plot(AX,D.Full.OrbitMeas{HH}(:,1) - OX,'o-','color',colors{mod(HH+6,7)+1});
        plot(AY,D.Full.OrbitMeas{HH}(:,2) - OY,'o-','color',colors{mod(HH+6,7)+1});       
    end
    legend(handles.BBA_Energies)

    if(~handles.ONLINE) %simulation mode, show actual offsets
       
       disp('1')
       New_Figure=figure;
       set(New_Figure,'name',['BBA-II. Fit results - Simulation mode: BPM Offset difference',''])
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
       AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
       %BPMz=D.MODEL.static.zBPM - min(D.MODEL.static.zBPM);
       
       disp('Simulation Mode: reading quadrupole offsets from machine:')
       D.dynamic.quadOffsetX=lcaGetSmart(strcat(handles.static.quadList_e,':XPHYSOFF'));
       D.dynamic.quadOffsetY=lcaGetSmart(strcat(handles.static.quadList_e,':YPHYSOFF'));
       D.dynamic.BPM_X_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':XPHYSOFF'));
       D.dynamic.BPM_Y_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':YPHYSOFF'));
       D.dynamic.BPM_SOFT_X_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':XSOFTOFF'));
       D.dynamic.BPM_SOFT_Y_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':YSOFTOFF'));
       
       plot(AX,D.dynamic.BPM_X_OFFSET - (D.dynamic.BPM_SOFT_X_OFFSET + D.Full.BPM_X_Offsets),'-x')
       plot(AY,D.dynamic.BPM_Y_OFFSET - (D.dynamic.BPM_SOFT_Y_OFFSET + D.Full.BPM_Y_Offsets),'-x')
       title(AX,'BPM Physical offset - (BPM_SOFT_X_OFFSET(OLD)  +   BPM Retrieved offset X)')
       title(AY,'BPM Physical offset - (BPM_SOFT_Y_OFFSET(OLD)  +   BPM Retrieved offset Y)')
       
       return
       
       disp('1')
       New_Figure=figure;
       set(New_Figure,'name',['BBA-II. Fit results - Simulation mode: known offsets',''])
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
       AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
       %BPMz=D.MODEL.static.zBPM - min(D.MODEL.static.zBPM);
       
       
       
       plot(AX,D.dynamic.quadOffsetX,'o')
       hold(AX,'on')
       plot(AX,D.Full.Quad_X_Offsets,'.')
       title(AX,'Raw Quadrupole Offsets - X')
       plot(AY,D.dynamic.quadOffsetY,'o')
       hold(AY,'on')
       plot(AY,D.Full.Quad_Y_Offsets,'.')
       title(AY,'Raw Quadrupole Offsets - Y')
       
       New_Figure=figure;
       set(New_Figure,'name',['BBA-II. Fit results - Simulation mode: known offsets',''])
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
       AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
       %BPMz=D.MODEL.static.zBPM - min(D.MODEL.static.zBPM);
       plot(AX,D.dynamic.quadOffsetX - D.Full.Quad_X_Offsets,'x')
       title(AX,'New Quadrupole Line - X')
       plot(AY,D.dynamic.quadOffsetY - D.Full.Quad_Y_Offsets,'x')
       title(AY,'New Quadrupole Line - Y')
       
       New_Figure=figure;
       set(New_Figure,'name',['BBA-II. Fit results - known offsets',''])
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
       AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
       %BPMz=D.MODEL.static.zBPM - min(D.MODEL.static.zBPM);
       plot(AX,D.dynamic.BPM_X_OFFSET,'o')
       hold(AX,'on')
       plot(AX,D.Full.BPM_X_Offsets,'.')
       title(AX,'Raw BPM Offsets - X')
       plot(AY,D.dynamic.BPM_Y_OFFSET,'o')
       hold(AY,'on')
       plot(AY,D.Full.BPM_Y_Offsets,'.')
       title(AY,'Raw BPM Offsets - Y')
       NewQuadrupolePointingLineY=polyfit(handles.static.zQuad, D.dynamic.quadOffsetY - D.Full.Quad_Y_Offsets,1);
       LineOffsetAtBPMLocationsY=polyval(NewQuadrupolePointingLineY,handles.static.zBPM);
       
       NewQuadrupolePointingLineX=polyfit(handles.static.zQuad, D.dynamic.quadOffsetX - D.Full.Quad_X_Offsets,1);
       LineOffsetAtBPMLocationsX=polyval(NewQuadrupolePointingLineX,handles.static.zBPM);
       
%       plot(AY,D.dynamic.BPM_Y_OFFSET-(D.dynamic.quadOffsetY - D.Full.Quad_Y_Offsets),'ok')
%        
       New_Figure=figure;
       set(New_Figure,'name',['BBA-II. Fit results - known offsets',''])
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
       AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
       %BPMz=D.MODEL.static.zBPM - min(D.MODEL.static.zBPM);
       plot(AX,D.dynamic.BPM_X_OFFSET-LineOffsetAtBPMLocationsX,'o')
       hold(AX,'on')
       plot(AX,D.Full.BPM_X_Offsets,'.')
       title(AX,'BPM Offsets - X - Quad Slope Corrected')
       plot(AY,D.dynamic.BPM_Y_OFFSET-LineOffsetAtBPMLocationsY,'o')
       hold(AY,'on')
       plot(AY,D.Full.BPM_Y_Offsets,'.')
       title(AY,'BPM Offsets - Y - Quad Slope Corrected')
       
%        QuadSpline=spline(handles.static.zQuad, - D.Full.Quad_Y_Offsets);
%        New_BPM_Location_Y=ppval(QuadSpline,handles.static.zBPM);
%        
%        QuadSpline=spline(handles.static.zQuad, - D.Full.Quad_X_Offsets);
%        New_BPM_Location_X=ppval(QuadSpline,handles.static.zBPM);
        
       OrbitFit=D.Full.Matrix*D.Full.lsqSolution;
       
       for HH=1:size(D.Full.Init_Vector,1)
            NewFigure=figure;
            OFit=OrbitFit(1:(end-length(D.Full.CMeas)));
            Bpm2Length=2*length(D.Full.BPM_X_Offsets);
            O=OFit((Bpm2Length*(HH-1)+1) : (Bpm2Length*HH));
            OX=O(1:2:end);
            OY=O(2:2:end);
            plot(D.Full.OrbitMeas{HH}(:,1) - OX);
            plot(D.Full.OrbitMeas{HH}(:,2) - OY);
            
       end
       
       New_Figure=figure
       plot(D.static.zBPM,D.dynamic.BPM_X_OFFSET-New_BPM_Location_X-D.Full.BPM_X_Offsets,'k-o')
       hold on
       plot(D.static.zBPM,D.dynamic.BPM_Y_OFFSET-New_BPM_Location_Y-D.Full.BPM_Y_Offsets,'b-o')
       legend('X','Y')
       title('New BPM Zero Line in absolute coordinates')
    
       
       
    end
else %Show full solution to partial solutions to see if one is completely off.
    
end

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
D=get(handles.Selector,'userdata');
%Do some undulator cam restore point.
QLIST=cell2mat(cellfun(@(x) x(end-3:end),D.static.quadList_e,'UniformOutput',false));
QCellNumber=str2num(QLIST(:,1:2));
BLIST=cell2mat(cellfun(@(x) x(end-3:end),D.static.bpmList_e,'UniformOutput',false)); BLIST(BLIST==':')='0';
BCellNumber=str2num(BLIST(:,1:2));


%        D.dynamic.BPM_X_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':XPHYSOFF'));
%        D.dynamic.BPM_Y_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':YPHYSOFF'));
%        D.dynamic.BPM_SOFT_X_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':XSOFTOFF'));
%        D.dynamic.BPM_SOFT_Y_OFFSET=lcaGetSmart(strcat(handles.static.bpmList_e,':YSOFTOFF'));

quadOffsetX=lcaGetSmart(strcat(handles.static.quadList_e,':XPHYSOFF'));
quadOffsetY=lcaGetSmart(strcat(handles.static.quadList_e,':YPHYSOFF'));
NquadOffsetX=quadOffsetX-D.Full.Quad_X_Offsets;
NquadOffsetY=quadOffsetY-D.Full.Quad_Y_Offsets;
for II=1:length(NquadOffsetX)
    lcaPutSmart(strcat(handles.static.quadList_e{II},':XPHYSOFF'),NquadOffsetX(II));
    lcaPutSmart(strcat(handles.static.quadList_e{II},':YPHYSOFF'),NquadOffsetY(II));
end
% 
OLD_SOFT_BPM_X=lcaGetSmart(strcat(D.static.bpmList_e,':XSOFTOFF'));
OLD_SOFT_BPM_Y=lcaGetSmart(strcat(D.static.bpmList_e,':YSOFTOFF'));
% 
N_SOFT_BPM_X=OLD_SOFT_BPM_X+D.Full.BPM_X_Offsets;
N_SOFT_BPM_Y=OLD_SOFT_BPM_Y+D.Full.BPM_Y_Offsets;
% 
for II=1:length(OLD_SOFT_BPM_X)
    lcaPutSmart(strcat(handles.static.bpmList_e{II},':XSOFTOFF'),N_SOFT_BPM_X(II));
    lcaPutSmart(strcat(handles.static.bpmList_e{II},':YSOFTOFF'),N_SOFT_BPM_Y(II));
end

pushbutton3_Callback(hObject, eventdata, handles)

return

for II=1:length(BCellNumber)
        if(any(BCellNumber(II)==QCellNumber))
            %Move Quadrupole Set BPM Offset
            
%             QID=find((BCellNumber(II)==QCellNumber));
%             OLD_POSITION_X=lcaGetSmart([D.static.quadList_e{QID},':XPHYSOFF']);
%             OLD_POSITION_Y=lcaGetSmart([D.static.quadList_e{QID},':YPHYSOFF']);
%             OLD_SOFT_BPM_X=lcaGetSmart([D.static.bpmList_e{II},':XSOFTOFF']);
%             OLD_SOFT_BPM_Y=lcaGetSmart([D.static.bpmList_e{II},':YSOFTOFF']);
%             OLD_PHYS_BPM_X=lcaGetSmart([D.static.bpmList_e{II},':XPHYSOFF']);
%             OLD_PHYS_BPM_Y=lcaGetSmart([D.static.bpmList_e{II},':YPHYSOFF']);
%             
%             disp([D.static.quadList_e{QID},' - ',D.static.bpmList_e{II}]);
%             
%             NEW_POSITION_X=OLD_POSITION_X-D.Full.Quad_X_Offsets(QID);
%             NEW_POSITION_Y=OLD_POSITION_Y-D.Full.Quad_Y_Offsets(QID);
%             lcaPutSmart([D.static.quadList_e{QID},':XPHYSOFF'],NEW_POSITION_X);
%             lcaPutSmart([D.static.quadList_e{QID},':YPHYSOFF'],NEW_POSITION_Y);
%             
%             NEW_SOFT_BPM_X=OLD_SOFT_BPM_X+D.Full.Quad_X_Offsets(QID)-D.Full.BPM_X_Offsets(II);
%             NEW_SOFT_BPM_Y=OLD_SOFT_BPM_Y+D.Full.Quad_Y_Offsets(QID)-D.Full.BPM_Y_Offsets(II);
%             NEW_PHYS_BPM_X=OLD_PHYS_BPM_X-D.Full.Quad_X_Offsets(QID);
%             NEW_PHYS_BPM_Y=OLD_PHYS_BPM_Y-D.Full.Quad_X_Offsets(QID);
%             lcaPutSmart([D.static.bpmList_e{II},':XSOFTOFF'],NEW_SOFT_BPM_X);
%             lcaPutSmart([D.static.bpmList_e{II},':YSOFTOFF'],NEW_SOFT_BPM_Y);
%             lcaPutSmart([D.static.bpmList_e{II},':XPHYSOFF'],NEW_PHYS_BPM_X);
%             lcaPutSmart([D.static.bpmList_e{II},':YPHYSOFF'],NEW_PHYS_BPM_Y);
        else
%             disp(D.static.bpmList_e{II});
%             OLD_SOFT_BPM_X=lcaGetSmart([D.static.bpmList_e{II},':XSOFTOFF']);
%             OLD_SOFT_BPM_Y=lcaGetSmart([D.static.bpmList_e{II},':YSOFTOFF']);
%             NEW_SOFT_BPM_X=OLD_SOFT_BPM_X-D.Full.BPM_X_Offsets(II);
%             NEW_SOFT_BPM_Y=OLD_SOFT_BPM_Y-D.Full.BPM_Y_Offsets(II);
%             lcaPutSmart([D.static.bpmList_e{II},':XSOFTOFF'],NEW_SOFT_BPM_X);
%             lcaPutSmart([D.static.bpmList_e{II},':YSOFTOFF'],NEW_SOFT_BPM_Y);
        end
        %Move only quadrupoles and set offset readings:
        
        
        
end
pushbutton3_Callback(hObject, eventdata, handles)

% for KK=1:length(D.static.bpmList_e)
%         OLD_SOFT_X=lcaGetSmart([D.static.bpmList_e{KK},':XSOFTOFF']);
%         lcaPutSmart([D.static.bpmList_e{KK},':XSOFTOFF'],OLD_SOFT_X - D.Full.BPM_X_Offsets(KK));
%         OLD_SOFT_Y=lcaGetSmart([D.static.bpmList_e{KK},':YSOFTOFF']);
%         lcaPutSmart([D.static.bpmList_e{KK},':YSOFTOFF'],OLD_SOFT_Y - D.Full.BPM_Y_Offsets(KK));
% end

%set(handles.BBA_PANEL,'visible','on');set(handles.ApplyBBA,'visible','off')


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
set(handles.BBA_PANEL,'visible','on');set(handles.ApplyBBA,'visible','off')

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function TakeData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TakeData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)

ActionList=struct('InsertTDUND',0,'SetPSGaps',0,'RestoreTDUND',0,'RemovePointing',0,'RestoreCamAngles',0,'SetUndulatorGaps',0,'LEM_BBA',0,'UndulatorCorrectionOff',0,'ZeroCorrectors',0,'StandardizeQuadsAndCorrs',0,'ZeroChicane',0,'ZeroChicaneTrims',0,'DeGaussChicane',0);
for II=1:handles.number_of_bba_preparation_actions
   Action(II)=get(handles.(['d',num2str(II)]),'value');
   set(handles.(['d',num2str(II)]),'foregroundcolor',[0,0,0]); drawnow;
end
if(Action(1)), ActionList.InsertTDUND=1; end
if(Action(10)), ActionList.RestoreTDUND=1; end
if(Action(11)), ActionList.RemovePointing=1; end
if(Action(12)), ActionList.RestoreCamAngles=1; end
if(Action(2)), ActionList.SetUndulatorGaps=1; end
if(Action(3)), ActionList.SetPSGaps=1; end
if(Action(4)), ActionList.LEM_BBA=1; end
if(Action(5)), ActionList.UndulatorCorrectionOff=1;end
if(Action(6)), ActionList.ZeroCorrectors=1;end
if(Action(7)), ActionList.StandardizeQuadsAndCorrs=1;  end 
if(Action(8)), ActionList.ZeroChicane=1;end
if(Action(13)), ActionList.ZeroChicaneTrims=1;end
if(Action(9)), ActionList.DeGaussChicane=1;end

% Get TDUND state and then insert.
%if(ActionList.InsertTDUND) 
%    set(handles.(['d',num2str(1)]),'foregroundcolor',handles.ColorWait); drawnow;
%    RESTORE.RestoreTDUND=hanldes.UL.f.SetTDUND(handles.UL,'IN');
%    set(handles.(['d',num2str(1)]),'foregroundcolor',handles.ColorOn);
%end

% Select BBA mode for LEM.
if(ActionList.LEM_BBA)
    set(handles.(['d',num2str(4)]),'foregroundcolor',handles.ColorWait); drawnow
    RESTORE.RestoreLEM_PVs=handles.UL.f.SelectBBAMode(handles.UL); pause(1.0);
    set(handles.(['d',num2str(4)]),'foregroundcolor',handles.ColorOn);
end

corrList=handles.static.corrList_e(cellfun(@(x) any(strfind(x,'UND')), handles.static.corrList_e));
quadList=handles.static.quadList_e(cellfun(@(x) any(strfind(x,'UND')), handles.static.quadList_e));
bpmList=handles.static.bpmList_e(cellfun(@(x) any(strfind(x,'UND')), handles.static.bpmList_e));
bpmCells=cellfun(@(x) x(end-3:end-2),bpmList,'uniformoutput',0);
switch(handles.UL.name(1))
    case 'H'
        line='HXR';
    case 'S'
        line='SXR';
    otherwise
        line='UNK';
end

if(ActionList.RemovePointing)
    set(handles.(['d',num2str(11)]),'foregroundcolor',handles.ColorWait); drawnow
    XBPMOFF_D=lcaGetSmart(strcat(bpmList,':XOFF.D'))*1000;
    YBPMOFF_D=lcaGetSmart(strcat(bpmList,':YOFF.D'))*1000;
    ZigZagString='{';
    for AA=2:length(XBPMOFF_D)
        ZigZagString=[ZigZagString,bpmCells{AA},',',num2str(XBPMOFF_D(AA)),',',num2str(YBPMOFF_D(AA)),';'];
    end
    ZigZagString(end)='}';
    command=['posChanges=repointUndLineMult(''',line,'''',',',bpmCells{1},',',ZigZagString,')'];
    pause(2.0);
    moveRFBPMoffsets_D_to_A(line)
    pause(1.0);
    set(handles.(['d',num2str(11)]),'foregroundcolor',handles.ColorOn);
end

if(ActionList.RestoreCamAngles)
    set(handles.(['d',num2str(11)]),'foregroundcolor',handles.ColorWait); drawnow
    NuhnGUI=CamAlignmentDiagnostics_gui();
    set(handles.BBACamDone,'visible','on','enable','on','backgroundcolor',handles.ColorIdle);
    COLOR=get(handles.BBACamDone);
    while(all(COLOR==handles.ColorIdle))
        COLOR=get(handles.BBACamDone); pause(0.5);
    end
    set(handles.BBACamDone,'visible','off','enable','on','backgroundcolor',handles.ColorIdle);
end

%Set Undulator Line
if(ActionList.SetUndulatorGaps || ActionList.SetPSGaps)
    set(handles.(['d',num2str(2)]),'foregroundcolor',handles.ColorWait);
    set(handles.(['d',num2str(3)]),'foregroundcolor',handles.ColorWait); drawnow
    drawnow;
    GapState=get(handles.BBA_UL_STATE,'value');
    RESTORE.UndulatorLineState=handles.UL.f.ReadAllLine(handles.UL);
    handles.UL.f.PrepareForBBA(handles.UL,GapState);
    set(handles.(['d',num2str(2)]),'foregroundcolor',handles.ColorOn);
    set(handles.(['d',num2str(3)]),'foregroundcolor',handles.ColorOn); 
end

% Turn undulator orbit correction off.
if(ActionList.UndulatorCorrectionOff)
    set(handles.(['d',num2str(5)]),'foregroundcolor',handles.ColorWait); drawnow
    %NEED TO ADD A LINE FOR THE BPM GAP CORRECTION
    PV_Corr_GapCorrection=strcat(corrList,':POLYCOEF.A',0);
    lcaPut(PV_Corr_GapCorrection,0);
    pause(1);
    set(handles.(['d',num2str(5)]),'foregroundcolor',handles.ColorOn);
end

% Set undulator correctors to zero.
if(ActionList.ZeroCorrectors)
    set(handles.(['d',num2str(6)]),'foregroundcolor',handles.ColorWait); drawnow
    control_magnetSet(corrList,0,'action','TRIM');
    set(handles.(['d',num2str(6)]),'foregroundcolor',handles.On);  
end

% Standardize first quads, then x-corrs, then y-corrs.
%gui_statusDisp(handles,'STDZ Magnets: Quads ...');
%gui_statusDisp(handles,'STDZ Magnets: X-Corrs ...');
if(ActionList.StandardizeQuadsAndCorrs)
    set(handles.(['d',num2str(7)]),'foregroundcolor',handles.ColorWait); drawnow
    control_magnetSet(quadList,[],'action','STDZ');
    control_magnetSet(corrList,[],'action','STDZ');
    set(handles.(['d',num2str(7)]),'foregroundcolor',handles.ColorOn); 
end
% Turn self-seeding chicane controls off.
%gui_statusDisp(handles,'Turn off: H/SXRSS Chicane Control Phase Shift & BTRMs');
%lcaPut('SIOC:SYS0:ML01:AO902',0);pause(2.); % Wait for HXRSS gui response.
ChicaneSlots=find(cell2mat(handles.UL.DeviceMap(:,5))==1);

if(ActionList.ZeroChicane)
    set(handles.(['d',num2str(8)]),'foregroundcolor',handles.ColorWait); drawnow
    control_magnetSet(handles.UL.slot(ChicaneSlots(II)).BEND.PVNAMES,0);
    set(handles.(['d',num2str(8)]),'foregroundcolor',handles.ColorOn); 
end

if(ActionList.ZeroChicaneTrims)
    set(handles.(['d',num2str(13)]),'foregroundcolor',handles.ColorWait); drawnow
    for II=1:length(ChicaneSlots)
        control_magnetSet(handles.UL.slot(ChicaneSlots(II)).BEND.TRIMMADNAMES,0);
    end
    set(handles.(['d',num2str(13)]),'foregroundcolor',handles.ColorOn);
end

% Degauss self-seeding chicanes.

if(ActionList.ZeroChicane || ActionList.DeGaussChicane)
    if(ActionList.ZeroChicane)
       set(handles.(['d',num2str(8)]),'foregroundcolor',handles.ColorWait); drawnow 
    end
    ChicaneList={};
    for II=1:length(ChicaneSlots)
        ChicaneList{end+1}=UL.slot(ChicaneSlots).BEND.MADNAMES{2};
    end
    if(ActionList.ZeroChicane)
        controlMagnetSet(ChicaneList,0);
        set(handles.(['d',num2str(8)]),'foregroundcolor',handles.ColorOn);
    end
    
    if(ActionList.DeGaussChicane)
        set(handles.(['d',num2str(9)]),'foregroundcolor',handles.ColorWait); drawnow
        control_magnetSet(ChicaneList,[],'action','DEGAUSS');
        set(handles.(['d',num2str(9)]),'foregroundcolor',handles.ColorON);
    end
    pause(2);
end

% % Put TDUND back to what it was.
% if(ActionList.RestoreTDUND)
%     set(handles.(['d',num2str(10)]),'foregroundcolor',handles.ColorWait); drawnow
%     hanldes.UL.f.SetTDUND(handles.UL,RESTORE.RestoreTDUND);
%     set(handles.(['d',num2str(9)]),'foregroundcolor',handles.ColorON);
% end


% --- Executes on button press in d1.
function d1_Callback(hObject, eventdata, handles)
% hObject    handle to d1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d1


% --- Executes on button press in d2.
function d2_Callback(hObject, eventdata, handles)
VAL=get(handles.d2,'value');
set(handles.d3,'value',VAL);


% --- Executes on button press in d4.
function d4_Callback(hObject, eventdata, handles)
% hObject    handle to d4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d4


% --- Executes on button press in d5.
function d5_Callback(hObject, eventdata, handles)
% hObject    handle to d5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d5


% --- Executes on button press in d6.
function d6_Callback(hObject, eventdata, handles)
% hObject    handle to d6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d6


% --- Executes on button press in d7.
function d7_Callback(hObject, eventdata, handles)
% hObject    handle to d7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d7


% --- Executes on button press in d8.
function d8_Callback(hObject, eventdata, handles)
% hObject    handle to d8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d8


% --- Executes on button press in d10.
function d10_Callback(hObject, eventdata, handles)
% hObject    handle to d10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d10


% --- Executes on button press in d3.
function d3_Callback(hObject, eventdata, handles)
VAL=get(handles.d3,'value');
set(handles.d2,'value',VAL);


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)

EXTERNAL_BPM_OFFSETS=str2num(get(handles.edit4,'string'));
EXTERNAL_QUAD_OFFSETS=str2num(get(handles.edit5,'string'));
EXTERNAL_FOCTERM_OFFSETS=str2num(get(handles.edit6,'string'));
EXTERNAL_KSPLINE_OFFSETS=str2num(get(handles.edit7,'string'));
EXTERNAL_FOCUSDIR=get(handles.checkbox15,'value');
EXTERNAL_USE_MATRIX_WITH_FOCUSING=get(handles.checkbox16,'value');
InitUndulatorLine


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in Reserve.
function myeDefNumber=Reserve_Callback(hObject, eventdata, handles)
myeDefNumber=eDefReserve('Beam Based Alignemnt GUI');
if(isnan(myeDefNumber) || (myeDefNumber==0))
    set(handles.testo,'string','FAILED');
    set(handles.testo,'userdata',[]);
    set(handles.Reserve,'enable','on')
    set(handles.Release,'enable','off');
else
    set(handles.testo,'string',num2str(myeDefNumber));
    set(handles.testo,'userdata',myeDefNumber);
    set(handles.Reserve,'enable','off');
    set(handles.Release,'enable','on');
end


% --- Executes on button press in Release.
function Release_Callback(hObject, eventdata, handles)
myeDefNumber=get(handles.testo,'userdata');
if(~isempty(myeDefNumber))
    eDefRelease(myeDefNumber);
end
set(handles.Reserve,'enable','on')
set(handles.Release,'enable','off');
set(handles.testo,'string','NONE');
set(handles.testo,'userdata',[]);


% --- Executes on button press in Reinit.
function Reinit_Callback(hObject, eventdata, handles)
set(handles.Reinit,'backgroundcolor',handles.ColorWait); drawnow
InitUndulatorLine_Machine
save([handles.SaveDir,'/UL.mat'],'UL','static','ul');
handles.UL=UL;
handles.static=static;
set(handles.UL_SELECT,'value',1);
set(handles.Reinit,'backgroundcolor',handles.ColorIdle);
guidata(hObject, handles);



% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
CurrentTime=clock;
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentGiornoString=num2str(CurrentTime(3),'%.2d');
targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentGiornoString];
[FILENAME,FILEPATH]=uigetfile(targetdir);
load([FILEPATH,'/',FILENAME],'Data','restore');

handles.MODEL_TYPE=restore.MODEL_TYPE;
ES='[';
for AK=1:numel(restore.EnergySelection_list)
    ES=[ES,restore.EnergySelection_list{AK},','];
end
ES(end)=']';
switch(restore.UL.name(1))
    case 'H'
        set(handles.UL_SELECT,'value',1);
    case 'S'
        set(handles.UL_SELECT,'value',2);
end
handles=UL_OK_Callback(handles.UL_OK, [], handles);
set(handles.BBA_Energies_editbox,'string',ES); drawnow;
handles=pushbutton3_Callback(handles.pushbutton3, [], handles);
pause(0.05);
set(handles.TABLE,'data',restore.Data_Table_Appearance)
set(handles.TABLE,'userdata',Data)
handles.BEAMCODE=restore.BEAMCODE;
guidata(hObject, handles);


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in DoNotBSA.
function DoNotBSA_Callback(hObject, eventdata, handles)
set(handles.useBSA,'value',0); set(handles.DoNotBSA,'value',1);


% --- Executes on button press in SaveData.
function SaveData_Callback(hObject, eventdata, handles)
restore.MODEL_TYPE=handles.MODEL_TYPE;
restore.BEAMCODE=handles.BEAMCODE;
restore.BEAMPATH=handles.BEAMPATH;
restore.static=handles.static;
restore.UL=handles.UL;
restore.PhyConsts=handles.PhyConsts;

%restore.SelectedElements=handles.SelectedElements;
%restore.GapPoints=handles.GapPoints;
restore.Pos=handles.Pos;
restore.StartBPM=handles.StartBPM;
restore.ToList=handles.ToList;
restore.PosList=handles.PosList;
restore.Data_Table_Appearance=get(handles.TABLE,'data');
Data=get(handles.TABLE,'userdata');
restore.EnergySelection_list=get(handles.popupmenu3,'string');
restore.UniqueGuiRunString=handles.UniqueGuiRunString;
restore.DeviceList=get(handles.TABLE,'rowname');
restore.DeviceList2=get(handles.TABLE,'columnname');

CurrentTime=clock;
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentGiornoString=num2str(CurrentTime(3),'%.2d');
CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentGiornoString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];
targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentGiornoString];
filename=regexprep(handles.UniqueGuiRunString,' ','_');
restore.BBA_Result=get(handles.APPLY,'userdata');
if(exist(targetdir))
    save([targetdir,'/',filename],'Data','restore','-v7.3');
else
    mkdir(targetdir);
    save([targetdir,'/',filename],'Data','restore','-v7.3');
end


% --- Executes on button press in NewFilename.
function NewFilename_Callback(hObject, eventdata, handles)
handles.UniqueGuiRunString=['BBA GUI ',datestr(now)];
set(handles.FN,'string',handles.UniqueGuiRunString);
guidata(hObject, handles);


function mincharge_Callback(hObject, eventdata, handles)
disp('ss')


% --- Executes during object creation, after setting all properties.
function mincharge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mincharge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BBA_UL_STATE.
function BBA_UL_STATE_Callback(hObject, eventdata, handles)
% hObject    handle to BBA_UL_STATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BBA_UL_STATE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BBA_UL_STATE


% --- Executes during object creation, after setting all properties.
function BBA_UL_STATE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BBA_UL_STATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emax_Callback(hObject, eventdata, handles)
% hObject    handle to emax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emax as text
%        str2double(get(hObject,'String')) returns contents of emax as a double


% --- Executes during object creation, after setting all properties.
function emax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emin_Callback(hObject, eventdata, handles)
% hObject    handle to emin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emin as text
%        str2double(get(hObject,'String')) returns contents of emin as a double


% --- Executes during object creation, after setting all properties.
function emin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function esteps_Callback(hObject, eventdata, handles)
% hObject    handle to esteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of esteps as text
%        str2double(get(hObject,'String')) returns contents of esteps as a double


% --- Executes during object creation, after setting all properties.
function esteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to esteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
MaxEnergy=str2double(get(handles.emax,'string')); MinEnergy=str2double(get(handles.emin,'string')); Points=str2double(get(handles.esteps,'string'));
Energies=1./linspace(1/MinEnergy,1/MaxEnergy,Points);
Energystring=['[',num2str(Energies(1),'%0.0f')];
for II=2:(length(Energies)-1)
    Energystring=[Energystring,',',num2str(Energies(II),'%0.0f')];
end
Energystring=[Energystring,',',num2str(Energies(end),'%0.0f'),']'];
set(handles.BBA_Energies_editbox,'string',Energystring)


% --- Executes on button press in PlotResults.
function [New_Figure, New_Figure2, New_Figure3, New_Figure4]=PlotResults_Callback(hObject, eventdata, handles)
BBA_Result=get(handles.APPLY,'userdata');
OrbitFit=BBA_Result.Matrix*BBA_Result.lsqSolution;
ZeroAllOffsets=zeros(size(BBA_Result.lsqSolution));
ZeroAllOffsets(1:4*length(BBA_Result.Energies))=BBA_Result.lsqSolution(1:4*length(BBA_Result.Energies));
OrbitFitLaunchOnly=BBA_Result.Matrix*ZeroAllOffsets;
New_Figure=figure;
set(New_Figure,'name',['BBA-II. Fit results - Measured - Fitted orbits',''])
Position=get(New_Figure,'position');
set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
AX=axes('position',[0.1,0.1,0.85,0.35]);
AY=axes('position',[0.1,0.55,0.85,0.35]);
hold(AX,'on'); hold(AY,'on');

New_Figure2=figure;
set(New_Figure2,'name',['BBA-II. Fit results - Measured - Launch Orbit Component',''])
Position=get(New_Figure2,'position');
set(New_Figure2,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
AXX=axes('position',[0.1,0.1,0.85,0.35]);
AYY=axes('position',[0.1,0.55,0.85,0.35]);
hold(AXX,'on'); hold(AYY,'on');

colors={'k','b','r','g','c','y','k','b','r','g','c','y','k'}; LEGEND={};
for HH=1:length(BBA_Result.Energies)
    OFit=OrbitFit(1:(end-length(BBA_Result.CMeas)));
    OFitLO=OrbitFitLaunchOnly(1:(end-length(BBA_Result.CMeas)));
    Bpm2Length=2*length(BBA_Result.BPM_X_Offsets);
    O=OFit((Bpm2Length*(HH-1)+1) : (Bpm2Length*HH));
    OLO=OFitLO((Bpm2Length*(HH-1)+1) : (Bpm2Length*HH));
    OX=O(1:2:end);
    OY=O(2:2:end);
    OXLO=OLO(1:2:end);
    OYLO=OLO(2:2:end);
    errorbar(AX,handles.static.zBPM+(HH-1)*0.1,BBA_Result.OrbitMeas{HH}(:,1) - OX, BBA_Result.OrbitMeasStd{HH}(:,1),'-o','color',colors{mod(HH+6,7)+1});
    errorbar(AY,handles.static.zBPM+(HH-1)*0.1,BBA_Result.OrbitMeas{HH}(:,2) - OY, BBA_Result.OrbitMeasStd{HH}(:,2),'o-','color',colors{mod(HH+6,7)+1});
    errorbar(AXX,handles.static.zBPM+(HH-1)*0.1,BBA_Result.OrbitMeas{HH}(:,1) - OXLO, BBA_Result.OrbitMeasStd{HH}(:,1),'o-','color',colors{mod(HH+6,7)+1});
    errorbar(AYY,handles.static.zBPM+(HH-1)*0.1,BBA_Result.OrbitMeas{HH}(:,2) - OYLO, BBA_Result.OrbitMeasStd{HH}(:,2),'o-','color',colors{mod(HH+6,7)+1});
    LEGEND{HH} = num2str(BBA_Result.Energies(HH));
end
title(AX,'X: Measured orbits - Fitted orbits');
title(AY,'Y: Measured orbits - Fitted orbits');
xlabel(AX,'z [m]'); xlabel(AY,'z [m]'); ylabel(AX,'mm orbit difference'); ylabel(AY,'mm orbit difference');
legend(AX,LEGEND);

title(AXX,'X: Measured orbits - Fitted Launch orbits only');
title(AYY,'Y: Measured orbits - Fitted Launch orbits only');
xlabel(AXX,'z [m]'); xlabel(AYY,'z [m]'); ylabel(AXX,'mm orbit difference'); ylabel(AYY,'mm orbit difference');
legend(AXX,LEGEND); 

New_Figure3=figure;
set(New_Figure3,'name',['BBA-II. Quadrupole displacements',''])
Position=get(New_Figure3,'position');
set(New_Figure3,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
AQx=axes('position',[0.1,0.1,0.85,0.35]);
AQy=axes('position',[0.1,0.55,0.85,0.35]);
hold(AQx,'on'); hold(AQy,'on'); 
errorbar(AQx,handles.static.zQuad,BBA_Result.Quad_X_Offsets,BBA_Result.Quad_X_OffsetsErr)
errorbar(AQy,handles.static.zQuad,BBA_Result.Quad_Y_Offsets,BBA_Result.Quad_Y_OffsetsErr)
ylabel(AQx,'mm'); ylabel(AQy,'mm'); xlabel(AQx,'z [m]'); xlabel(AQy,'z [m]');
title('BBA-II. Quadrupole displacements');

New_Figure4=figure;
set(New_Figure4,'name',['BBA-II. Bpm displacements',''])
Position=get(New_Figure4,'position');
set(New_Figure4,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
ABx=axes('position',[0.1,0.1,0.85,0.35]);
ABy=axes('position',[0.1,0.55,0.85,0.35]);
hold(ABx,'on'); hold(ABy,'on'); 
errorbar(ABx,handles.static.zBPM,BBA_Result.BPM_X_Offsets,BBA_Result.BPM_X_OffsetsErr)
errorbar(ABy,handles.static.zBPM,BBA_Result.BPM_Y_Offsets,BBA_Result.BPM_Y_OffsetsErr)
ylabel(ABx,'mm'); ylabel(ABy,'mm'); xlabel(ABx,'z [m]'); xlabel(ABy,'z [m]');
title('BBA-II. Bpm displacements');

% --- Executes on button press in APPLY.
function APPLY_Callback(hObject, eventdata, handles)
BBA_Result=get(handles.APPLY,'userdata');
try
    save TEMPORARY_STATE
end

bpm_X=BBA_Result.BPM_X_Offsets;
bpm_Y=BBA_Result.BPM_Y_Offsets;
bpmList_e=BBA_Result.static.bpmList_e;
quadList_e=BBA_Result.static.quadList_e;
quad_X=BBA_Result.Quad_X_Offsets;
quad_Y=BBA_Result.Quad_Y_Offsets;

bpmCells=str2num(cell2mat(cellfun(@(x) x(end-1:end),BBA_Result.static.bpmList,'UniformOutput',false)));
quadCells=str2num(cell2mat(cellfun(@(x) x(end-1:end),BBA_Result.static.quadList,'UniformOutput',false)));

if(any(strfind(handles.BEAMPATH,'HXR')))
    UndulatorLine='HXR';
elseif(any(strfind(handles.BEAMPATH,'SXR')))
    UndulatorLine='SXR';
end

%quadMoveList=[quad_X.',quad_Y.'];

SolutionToBeApplied.BBA_Result=BBA_Result;
SolutionToBeApplied.quadMoveList=-[quad_X.',quad_Y.'];
SolutionToBeApplied.quadMoveList_units='mm';
SolutionToBeApplied.Line=UndulatorLine;
SolutionToBeApplied.quadCells=quadCells;
SolutionToBeApplied.quadList_e=quadList_e;
SolutionToBeApplied.bpm_X=bpm_X;
SolutionToBeApplied.bpm_Y=bpm_Y;
SolutionToBeApplied.bpm_units='mm';
SolutionToBeApplied.bpmList_e=bpmList_e;
SolutionToBeApplied.bpmAOffsetsPV{1}=strcat(bpmList_e,':XAOFF');
SolutionToBeApplied.bpmAOffsetsPV{2}=strcat(bpmList_e,':YAOFF');
SolutionToBeApplied.bpm_X_OLD=lcaGet(SolutionToBeApplied.bpmAOffsetsPV{1});
SolutionToBeApplied.bpm_Y_OLD=lcaGet(SolutionToBeApplied.bpmAOffsetsPV{2});
SolutionToBeApplied.UL=handles.UL;

[New_Figure, New_Figure2, New_Figure3, New_Figure4]=PlotResults_Callback(hObject, eventdata, handles);

CurrentTime=clock;
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentGiornoString=num2str(CurrentTime(3),'%.2d');
CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentGiornoString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];
targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentGiornoString];
filename=['Solution-',regexprep(handles.UniqueGuiRunString,' ','_')];
restore.BBA_Result=get(handles.APPLY,'userdata');
if(exist(targetdir))
    save([targetdir,'/',filename],'SolutionToBeApplied','-v7.3');
else
    mkdir(targetdir);
    save([targetdir,'/',filename],'SolutionToBeApplied','-v7.3');
end

disp('Saving Data and Solution before application');
util_printLog(New_Figure,'title','BBA Iteration');
util_printLog(New_Figure2,'title','BBA Iteration');
util_printLog(New_Figure3,'title','BBA Iteration');
util_printLog(New_Figure4,'title','BBA Iteration');

handles.sf.ApplyBBA(SolutionToBeApplied);

set(handles.ApplyBBA,'visible','off');
pushbutton3_Callback(hObject, eventdata, handles);





% 
% %
% bykik_state=lcaGetSmart(handles.UL.Basic.bykikPV);
% lcaPutSmart(handles.UL.Basic.bykikPV,handles.UL.Basic.bykik_On); pause(0.1);
% %
% moveQuadsSmoothly(UndulatorLine, quadCells, -quadMoveList); %this applies the quadrupole motion.
% PV{1}=strcat(bpmList_e,':XAOFF'); PV{2}=strcat(bpmList_e,':YAOFF');
% bpm_X_OLD=lcaGet(PV{1}); bpm_Y_OLD=lcaGet(PV{2});
% bpm_X_NEW=bpm_X_OLD - bpm_X.'; bpm_Y_NEW=bpm_Y_OLD - bpm_Y.';
% lcaPut(PV{1},bpm_X_NEW); lcaPut(PV{2},bpm_Y_NEW);
% 
% % restore bykik
% lcaPutSmart(handles.UL.Basic.bykikPV,bykik_state); pause(0.1);

% pvList=model_nameConvert(static.bpmList,'EPICS');
% pvOff=[strcat(pvList(:),':XAOFF') strcat(pvList(:),':YAOFF')]';
% off=lcaGet(pvOff(:));
% if opts.init, off=0;end
% lcaPut(pvOff(:),off-bpmDelta(:)*1e3);
% cData=[static.bpmList num2cell(reshape([off;off-bpmDelta(:)*1e3],[],4))]';
% disp('BPM Off   Old x    Old Y    New X    New Y');
% disp(sprintf('%-6s %8.3f %8.3f %8.3f %8.3f\n',cData{:}));


%example 23,24 of some amount in mm
%sucess=moveQuadsSmoothly('HXR',23:24,[+0.05,-0.10;+0.01,0]);

%    BBA_Result.Quad_X_Offsets=Quad_X_Offsets;
%    BBA_Result.BPM_X_Offsets=BPM_X_Offsets;
%    BBA_Result.Quad_Y_Offsets=Quad_Y_Offsets;
%    BBA_Result.BPM_Y_Offsets=BPM_Y_Offsets;

% BBA_Result.Init_Vector=Init_Vector;
% BBA_Result.lsqSolution=lsqSolution;
% BBA_Result.OrbitMeas=OrbitMeas;
% BBA_Result.CMeas=CMeas;
% BBA_Result.Matrix=Matrix;
% BBA_Result.Locations=Locations;
% BBA_Result.Energies=handles.BBA_Energies;
% BBA_Result.static=handles.static;



% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FOLDER_Callback(hObject, eventdata, handles)
% hObject    handle to FOLDER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FOLDER as text
%        str2double(get(hObject,'String')) returns contents of FOLDER as a double


% --- Executes during object creation, after setting all properties.
function FOLDER_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FOLDER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_And_Compare.
function Load_And_Compare_Callback(hObject, eventdata, handles)
DIR=get(handles.FOLDER,'string');
Q_OFF=load([DIR,'/','quadOffsets.mat']);
B_OFF=load([DIR,'/','bpmOffsets.mat']);
load([DIR,'/','quadOffsets.mat']);
disp('fun from here')
BBA_Result=get(handles.APPLY,'userdata');
xOffsets(1:2:68)=xOffsets(1:2:68) - BBA_Result.Quad_X_Offsets/1000;
xOffsets(2:2:68)=xOffsets(2:2:68) - BBA_Result.Quad_X_Offsets/1000;
yOffsets(1:2:68)=yOffsets(1:2:68) - BBA_Result.Quad_Y_Offsets/1000;
yOffsets(2:2:68)=yOffsets(2:2:68) - BBA_Result.Quad_Y_Offsets/1000;
try
    save([DIR,'/','new_quadOffsets.mat'],'xOffNames','xOffsets','yOffNames','yOffsets');
catch
    save([pwd,'/','new_quadOffsets.mat'],'xOffNames','xOffsets','yOffNames','yOffsets');
end
load([DIR,'/','bpmOffsets.mat']);
OrigXOffsets=xOffsets; OrigYOffsets=yOffsets; 
xOffsets=xOffsets - BBA_Result.BPM_X_Offsets(3:end)/1000;
yOffsets=yOffsets - BBA_Result.BPM_Y_Offsets(3:end)/1000;
try
    save([DIR,'/','new_bpmOffsets.mat'],'xOffNames','xOffsets','yOffNames','yOffsets');
catch
    save([pwd,'/','new_bpmOffsets.mat'],'xOffNames','xOffsets','yOffNames','yOffsets');
end
figure
plot(BBA_Result.static.zBPM(3:end), xOffsets,'o-')
title('X BPM Difference');

figure
plot(BBA_Result.static.zBPM(3:end), yOffsets,'o-')
title('Y BPM Difference');

figure
plot(BBA_Result.static.zBPM(3:end), OrigXOffsets,'.'), hold on
plot(BBA_Result.static.zBPM(3:end), BBA_Result.BPM_X_Offsets(3:end)/1000,'o')

figure
plot(BBA_Result.static.zBPM(3:end), OrigYOffsets,'.'), hold on
plot(BBA_Result.static.zBPM(3:end), BBA_Result.BPM_Y_Offsets(3:end)/1000,'o')


% --- Executes on button press in SetEnergy.
function SetEnergy_Callback(hObject, eventdata, handles)
simulacrum_loadEnergyConfig(get(handles.popupmenu6,'value'));


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in d11.
function d11_Callback(hObject, eventdata, handles)
% hObject    handle to d11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d11


% --- Executes on button press in d12.
function d12_Callback(hObject, eventdata, handles)
% hObject    handle to d12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d12


% --- Executes on button press in d13.
function d13_Callback(hObject, eventdata, handles)
% hObject    handle to d13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d13


% --- Executes on button press in BBACamDone.
function BBACamDone_Callback(hObject, eventdata, handles)
set(handles.BBACamDone,'visible','on','enable','on','backgroundcolor',handles.ColorOn); drawnow;


% --- Executes during object deletion, before destroying properties.
function BBA_PANEL_DeleteFcn(hObject, eventdata, handles)
try
    Release_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in ExcludeNaN.
function ExcludeNaN_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeNaN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExcludeNaN


% --- Executes on button press in LogBook.
function LogBook_Callback(hObject, eventdata, handles)
% hObject    handle to LogBook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LogBook


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
POS=str2double(get(handles.EnergyPos,'string'));
BBA_DATA=get(handles.TABLE,'userdata');
WORKDATA=BBA_DATA{1, POS};
Setting=get(handles.popupmenu8,'value');
if(Setting==2)
    WORKDATA.MODEL=WORKDATA.MODEL_Original;
    BBA_DATA{1,POS}=WORKDATA;
    set(handles.TABLE,'userdata',BBA_DATA);
else
    Filename=get(handles.FN_MODEL,'string');
    NEWRMAT_AND_ENERGY=load([handles.FitForBBADir,'/',Filename]);
    if(strcmp(handles.StartBPM,'RFBSX16'))
       %needs to rework a little the matrix order and add a matrix for first quad that is before first BPM (The SMAC stuff works sequentially from first BPM forward, this can be fixed, by exporting matrices before first BPM and calculating them wrt to first BPM)
       if(NEWRMAT_AND_ENERGY.MODEL_BBA.Pos.nQuad<handles.Pos.nQuad)
            NewrMat(:,:,1:handles.Pos.nBPM)=NEWRMAT_AND_ENERGY.MODEL_BBA.rMat(:,:,1:handles.Pos.nBPM);
            NewrMat(:,:,end+1)=BBA_DATA{1,POS}.MODEL_Original.rMat(:,:,handles.Pos.QuadBeg(1)); %one of the missimng matrices!
            NewrMat(:,:,end+(1:NEWRMAT_AND_ENERGY.MODEL_BBA.Pos.nQuad))=NEWRMAT_AND_ENERGY.MODEL_BBA.rMat(:,:,NEWRMAT_AND_ENERGY.MODEL_BBA.Pos.QuadBeg);
            NewrMat(:,:,end+1)=BBA_DATA{1,POS}.MODEL_Original.rMat(:,:,handles.Pos.QuadEnd(1)); %one of the missimng matrices!
            NewrMat(:,:,end+(1:NEWRMAT_AND_ENERGY.MODEL_BBA.Pos.nQuad))=NEWRMAT_AND_ENERGY.MODEL_BBA.rMat(:,:,NEWRMAT_AND_ENERGY.MODEL_BBA.Pos.QuadEnd);
            NewrMat(:,:,end+1)=zeros(6,6,1); % In a corrector matrix location. Irrelevant for BBA.
            NewrMat(:,:,end+1)=zeros(6,6,1); % In a corrector matrix location. Irrelevant for BBA.
            NewrMat(:,:,(end+1):(length(BBA_DATA{1,POS}.MODEL_Original.zPos))) = NEWRMAT_AND_ENERGY.MODEL_BBA.rMat(:,:,NEWRMAT_AND_ENERGY.MODEL_BBA.Pos.Corr(1):end);
            NEWRMAT_AND_ENERGY.MODEL_BBA.rMat=NewrMat;
       end
    end
    WORKDATA.MODEL.rMat=NEWRMAT_AND_ENERGY.MODEL_BBA.rMat;
    WORKDATA.MODEL.energy=ones(size(WORKDATA.MODEL.energy))*NEWRMAT_AND_ENERGY.MODEL_BBA.energy;
    BBA_DATA{1,POS}=WORKDATA;
    NEWRMAT_AND_ENERGY.MODEL_BBA.energy;
    disp(['Found New Model with Energy: ',num2str(NEWRMAT_AND_ENERGY.MODEL_BBA.energy)])
    set(handles.TABLE,'userdata',BBA_DATA);
end


function EnergyPos_Callback(hObject, eventdata, handles)
% hObject    handle to EnergyPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EnergyPos as text
%        str2double(get(hObject,'String')) returns contents of EnergyPos as a double


% --- Executes during object creation, after setting all properties.
function EnergyPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnergyPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FN_MODEL_Callback(hObject, eventdata, handles)
% hObject    handle to FN_MODEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FN_MODEL as text
%        str2double(get(hObject,'String')) returns contents of FN_MODEL as a double


% --- Executes during object creation, after setting all properties.
function FN_MODEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FN_MODEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in JollyFilter.
function JollyFilter_Callback(hObject, eventdata, handles)
% hObject    handle to JollyFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of JollyFilter
