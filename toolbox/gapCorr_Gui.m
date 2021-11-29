function varargout = gapCorr_Gui(varargin)
% GAPCORR_GUI MATLAB code for gapCorr_Gui.fig
%      GAPCORR_GUI, by itself, creates a new GAPCORR_GUI or raises the existing
%      singleton*.
%fdgsfgdg
%      H = GAPCORR_GUI returns the handle to a new GAPCORR_GUI or the handle to
%      the existing singleton*.
%
%      GAPCORR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAPCORR_GUI.M with the given input arguments.
%
%      GAPCORR_GUI('Property','Value',...) creates a new GAPCORR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gapCorr_Gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gapCorr_Gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gapCorr_Gui

% Last Modified by GUIDE v2.5 07-Sep-2020 10:27:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gapCorr_Gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gapCorr_Gui_OutputFcn, ...
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


% --- Executes just before gapCorr_Gui is made visible.
function gapCorr_Gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gapCorr_Gui (see VARARGIN)

% Choose default command line output for gapCorr_Gui
handles.output = hObject;
ColorOn=[0,1,0]; ColorWait=[1,1,0]; ColorOff=[1,0,0];
handles.UndGapDefaultHXR=[7.2,7.4,7.6,7.8,linspace(8,10,3),linspace(12,20,5),linspace(25,30,2),linspace(40,100,4)];
handles.UndGapDefaultHXR=handles.UndGapDefaultHXR(end:-1:1);
handles.PhasGapDefault=[linspace(11,15,9),linspace(16,22,7),linspace(25,30,3),linspace(40,100,7)];
handles.UndGapDefaultSXR=[7.2,7.4,7.6,7.8,linspace(8,10,3),linspace(12,20,5),linspace(25,30,2),linspace(40,100,4),135,170];
handles.UndGapDefaultSXR=handles.UndGapDefaultSXR(end:-1:1);
handles.PhasGapDefault=handles.PhasGapDefault(end:-1:1);

handles.SaveDir='/u1/lcls/matlab/ULT_GuiData';
handles.UndulatorLineFunctions_handler=ULT_UndulatorLine_functions();
handles.sf=Steering_Functions();
try 
    if(strcmp(varargin{1},'test'))
        handles.ONLINE=2;
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
        load([handles.SaveDir,'/UL.mat']);
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

set(handles.uipanel7,'visible','off');

handles.UL=UL;
handles.static=static;
set(handles.UL_SELECT,'string',{handles.UL.name}); set(handles.UL_SELECT,'value',1);
% Update handles structure
handles.UniqueGuiRunString=['Gap Correction GUI ',datestr(now)];
set(handles.FN,'string',handles.UniqueGuiRunString);
guidata(hObject, handles);

% UIWAIT makes gapCorr_Gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gapCorr_Gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% function handles=ReadUndulatorBeamline(handles)
% if(handles.ONLINE)
%     [handles.UL_SELECT,ES]=UUT_BuildUndulatorLinesScript();
% else
%      load FAKE_Beamlinestate
%      handles.UL=UL;
% end


% --- Executes on selection change in UL_SELECT.
function UL_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to UL_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%thfghfghf
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
function UL_OK_Callback(hObject, eventdata, handles)
ID=get(handles.UL_SELECT,'value');
handles.eDefNumber=Reserve_Callback(hObject, eventdata, handles);
if(handles.ONLINE==2)
   set(handles.kickmag,'visible','on'); 
   set(handles.bpmmag,'visible','on'); 
else
   set(handles.kickmag,'visible','off'); 
   set(handles.bpmmag,'visible','off');    
end
%handles.eDefNumber=Reserve_Callback(hObject, eventdata, handles);
handles.UL=handles.UL(ID);
handles.static=handles.static(ID);
handles.MODEL_TYPE='TYPE=EXTANT';
if(ID==1)
    handles.BEAMCODE=1;
    handles.BEAMPATH=['BEAMPATH=','CU_HXR'];
    handles.launch_corr=bba2_init('sector','LTUH','devList',{'XCOR' 'YCOR'},'beampath','CU_HXR','sortZ',1);
    handles.UndGapDefault=handles.UndGapDefaultHXR;
    eDefParams (handles.eDefNumber, 1, 2800, [], [], [], [], 1);
elseif(ID==2)
    handles.BEAMCODE=2;
    handles.BEAMPATH=['BEAMPATH=','CU_SXR'];
    handles.launch_corr=bba2_init('sector','LTUS','devList',{'XCOR' 'YCOR'},'beampath','CU_SXR','sortZ',1);
    handles.UndGapDefault=handles.UndGapDefaultSXR;
    eDefParams (handles.eDefNumber, 1, 2800, [], [], [], [], 2);
end
guidata(hObject, handles);
set(handles.checkbox3,'value',1);set(handles.checkbox4,'value',0);
UpdateTable(handles,handles.UL,1);
set(handles.ULSTRING,'string',['Undulator Line: ',handles.UL.name]);
set(handles.text5,'string',['Undulator Line: ',handles.UL.name]);
set(handles.ULS,'visible','off'); set(handles.PA,'visible','on'); set(handles.BBA_PANEL,'visible','off');set(handles.ApplyBBA,'visible','off')

function UpdateTable(handles,UL,Type)
TABLE={};ins=0;
for II=1:UL.slotlength
    if(Type==1) %undulators
        if(UL.slot(II).USEG.present)
           ins=ins+1;
           TABLE{ins,1}=handles.UL.slot(II).USEG.PV;
           TABLE{ins,2}=true;
           TABLE{ins,3}=II;
        else
            
        end
    else %Phase shifters
        if(UL.slot(II).PHAS.present)
           ins=ins+1;
           TABLE{ins,1}=handles.UL.slot(II).PHAS.PV;
           TABLE{ins,2}=true;
           TABLE{ins,3}=II;
        else
            
        end
    end
end
set(handles.uitable2,'data',TABLE);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
if(get(handles.checkbox3,'value'))
    handles.USEG=1; handles.PHAS=0;
else
    handles.PHAS=1; handles.USEG=0;
end
TABLE=get(handles.uitable2,'data');
handles.SelectedElements=TABLE;
handles.GapPointsMultiplier=str2double(get(handles.edit5,'string'));
handles.Pos.nBPM=length(handles.static.bpmList);
handles.Pos.nQuad=length(handles.static.quadList);
handles.Pos.nCorr=length(handles.static.corrList);
handles.Pos.nUnd=length(handles.static.undList);

if(handles.PHAS)
    handles.MEAS_POINTS=handles.PhasGapDefault;
    set(handles.DA_GT,'string','0.010');
elseif(handles.USEG)
    handles.MEAS_POINTS=handles.UndGapDefault;
    set(handles.DA_GT,'string','0.002');
end
if(handles.GapPointsMultiplier~=1);
   ORIG=length(handles.MEAS_POINTS);
   NEW=round(ORIG*handles.GapPointsMultiplier);
   OS=linspace(0,1,ORIG); NS=linspace(0,1,NEW);
   handles.MEAS_POINTS=interp1(OS,handles.MEAS_POINTS,NS);
end

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

handles.GapPoints=length(handles.MEAS_POINTS);

DeviceList={};
TABLE2=cell(sum(cell2mat(TABLE(:,2))),handles.GapPoints);
DATA=TABLE2;
ins=0;
for II=1:size(handles.SelectedElements,1)
    if(TABLE{II,2})
        DeviceList{end+1}=[num2str(TABLE{II,3}),'-',TABLE{II,1}];
        ins=ins+1;
        SLOT(ins)=TABLE{II,3};
        for HH=1:handles.GapPoints
           TABLE2{ins,HH}='Not Collected';
           DATA{ins,HH}=[];
        end
    end
end

if(handles.ONLINE==2) %sets up a test for simulacrum
   disp('Setting up kicks for simualtion') 
   kickmag=str2num(get(handles.kickmag,'string'));
   bpmmag=str2num(get(handles.bpmmag,'string'));
   handles.TestTable=randn(handles.GapPoints,4,length(DeviceList))*kickmag;
   handles.TestTableBPM=randn(handles.GapPoints,2,length(DeviceList))*bpmmag;
   XCorrPos=find(cellfun(@(x) x(1),handles.static.corrList_e)=='X');
   YCorrPos=find(cellfun(@(x) x(1),handles.static.corrList_e)=='Y');
   for SS=1:length(DeviceList)
       if(handles.USEG)
           Device=handles.UL.slot(SLOT(SS)).USEG.PV;
           LocationInStatic=find(strcmp(handles.static.undList_e,Device));
           Z=handles.static.zUnd(LocationInStatic); 
           CellString=handles.UL.slot(SLOT(SS)).USEG.Cell_String;
       elseif(handles.PHAS)
           Device=handles.UL.slot(SLOT(SS)).PHAS.PV;
           LocationInStatic=find(strcmp(handles.static.phasList_e,Device)); 
           Z=handles.static.zPhas(LocationInStatic);
           CellString=handles.UL.slot(SLOT(SS)).PHAS.Cell_String;
       end
       BPMs=find(cellfun(@(x) any(x),strfind(handles.static.bpmList_e,CellString)));
       PXPos=XCorrPos(find(handles.static.zCorr(XCorrPos)<Z,1,'last'));
       PYPos=YCorrPos(find(handles.static.zCorr(YCorrPos)<Z,1,'last'));
       NXPos=XCorrPos(find(handles.static.zCorr(XCorrPos)>Z,1,'first'));
       NYPos=YCorrPos(find(handles.static.zCorr(YCorrPos)>Z,1,'first'));
       handles.DeviceCorrectorList{SS}={handles.static.corrList_e{PXPos},handles.static.corrList_e{PYPos},handles.static.corrList_e{NXPos},handles.static.corrList_e{NYPos}};
       handles.DeviceBPMsList{SS}=handles.static.bpmList_e(BPMs);
       handles.DeviceBPMPositionX{SS}=BPMs;
       handles.DeviceBPMPositionY{SS}=BPMs + length(handles.static.bpmList_e);
       
       
   end
   handles.TestTable(1,:,1)=0; handles.TestTableBPM(1,:,1)=0;
   DeviceCorrectorList=handles.DeviceCorrectorList;
   TestTable=handles.TestTable; TestTableBPM=handles.TestTableBPM;
   save TEST DeviceCorrectorList TestTable TestTableBPM
end

handles.EnergyBPMs=handles.UL.Basic.EnergyBPMsLTU;
handles.EnergyBPMPos = 3*length(handles.static.bpmList) + (1:length(handles.EnergyBPMs));
handles.XLaunchPos = 1:2 ; % X, Y, TMIT, X, Y, TMIT ... X, Y, TMIT, EnergyBPM
handles.YLaunchPos = handles.XLaunchPos + length(handles.static.bpmList);
handles.LaunchBPMDistance=handles.static.zBPM(2) - handles.static.zBPM(1);

handles.ModelRMatGet_STRING=handles.PosList;
handles.ModelRMatGet_STRING{end+1}=handles.MODEL_TYPE;
handles.ModelRMatGet_STRING{end+1}=handles.BEAMPATH;
handles.ModelRMatGet_STRING{end+1}='SelPosUse=BBA';

guidata(hObject, handles);
set(handles.TABLE,'data',TABLE2); set(handles.TABLE,'userdata',DATA);
set(handles.TABLE,'rowname',DeviceList); set(handles.popupmenu5,'string',DeviceList); set(handles.popupmenu5,'value',1); set(handles.ApplyBBA,'visible','off')
set(handles.ULS,'visible','off'); set(handles.PA,'visible','off'); set(handles.BBA_PANEL,'visible','on');
set(handles.popupmenu6,'string',DeviceList); set(handles.popupmenu6,'value',1);
set(handles.popupmenu6,'userdata',SLOT); set(handles.popupmenu5,'userdata',SLOT);

set(handles.uipanel7,'visible','on');

if(~handles.ONLINE)
    set(handles.SIMUL,'visible','on');
end




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
function EXIT=TakeData_Callback(hObject, eventdata, handles)
EXIT=0;
set(handles.TakeData,'enable','off');
%Take Data and Model & Savfunction EXIT=TakeData_Callback(hObject, eventdata, handles)e data.
TABLE=get(handles.TABLE,'data');
set(handles.pushbutton21,'backgroundcolor',handles.ColorIdle);
set(handles.pushbutton21,'enable','on')
SLOT=get(handles.popupmenu5,'userdata');
DeviceList=get(handles.popupmenu5,'string');
SLOTID=get(handles.popupmenu5,'value');
s=SLOT(SLOTID);
ExcludeNaN=get(handles.ExcludeNaN,'value');
TAVOLA2{1,1}=DeviceList{SLOTID};
if(handles.USEG)
    DEVICE=handles.UL.slot(s).USEG;
    TAVOLA2{1,2}=DEVICE.f.Get_Gap(DEVICE);
else
    DEVICE=handles.UL.slot(s).PHAS;
    TAVOLA2{1,2}=DEVICE.f.Get_Gap(DEVICE);
end

set(handles.uitable3,'data',TAVOLA2); drawnow;
set(handles.uitable3,'columnname',{'Device','ACT','DES'})

Samples=str2double(get(handles.SampleAmount,'string'));

GAP_CORR_DATA=get(handles.TABLE,'userdata');

Energy=lcaGetSmart(handles.UL.Basic.EBeamEnergyPV);
GapPoints=size(TABLE,2);

BSA=get(handles.useBSA,'value');
if(BSA)
   eDefNumber=get(handles.testo,'userdata');
   if(isempty(eDefNumber))
       eDefNumber=Reserve_Callback(hObject, eventdata, handles);
   end
   if(isempty(eDefNumber) || (eDefNumber==0) || isnan(eDefNumber))
      BSA=0; %no way to use reserved BSA
      set(handles.useBSA,'value',0); set(handles.DoNotUseBSA,'value',1);
   end
else
    
end

%THRESHOLD=0.002;
THRESHOLD=str2num(get(handles.DA_GT,'string'));
disp(['Threshold set at: ',num2str(THRESHOLD), ' mm']);

mintmit=util_pCtoTmit(str2double(get(handles.mincharge,'string')));

if(any(strfind(handles.BEAMPATH,'CU_SXR')))
    model_init('SOURCE','MATLAB','beamPath','CU_SXR','useBdes',1);
elseif(any(strfind(handles.BEAMPATH,'CU_HXR')))
    model_init('SOURCE','MATLAB','beamPath','CU_HXR','useBdes',1);
end

%Get Model:
if(handles.ONLINE)
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(handles.StartBPM,handles.ToList,handles.ModelRMatGet_STRING);
    MODEL.Pos=handles.Pos;
    %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(handles.StartBPM,handles.ToList,{handles.MODEL_TYPE,handles.BEAMPATH},handles.PosList);
else
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(handles.StartBPM,handles.ToList,handles.PosList); MODEL.Pos=handles.Pos;
end

if(handles.ONLINE==2)
    BASECORR=lcaGetSmart(strcat(handles.static.corrList_e,':BCTRL'));
end

Data.MODEL=MODEL;
QuadrupoleStrengths=lcaGetSmart(strcat(handles.static.quadList_e,':BCTRL'));
CorrectorStrengths=lcaGetSmart(strcat(handles.static.corrList_e,':BCTRL'));
Data.MODEL.quadB=QuadrupoleStrengths;
Data.MODEL.corrB=CorrectorStrengths;
Data.MODEL.Pos=handles.Pos;
Data.MODEL.static=handles.static;
if(handles.ONLINE~=2)
    GapRestore=DEVICE.f.Get_Gap(DEVICE);
end

if(BSA)
    Data.Reference.Orbits=handles.sf.getBPMData_reserveBSA(handles.static.bpmList_e, min(5*Samples,2800), 1, eDefNumber,mintmit,handles.EnergyBPMs,ExcludeNaN,handles.BEAMCODE);
    %Data.Reference.Orbits=handles.sf.getBPMData_reserveBSA(handles.static.bpmList_e, 5*Samples, 1, eDefNumber,mintmit,handles.EnergyBPMs);
else
    Data.Reference.Orbits=handles.sf.getBPMData_caget(handles.static.bpmList_e, 5*Samples, 1,mintmit,handles.EnergyBPMs);
end

Data.Reference.EnergyBPMs=Data.Reference.Orbits(handles.EnergyBPMPos,:);
Data.Reference.XLaunch=Data.Reference.Orbits(handles.XLaunchPos,:);
Data.Reference.YLaunch=Data.Reference.Orbits(handles.YLaunchPos,:);
Data.Reference.Orbits_x=Data.Reference.Orbits(1:length(handles.static.bpmList_e),:);
Data.Reference.Orbits_y=Data.Reference.Orbits(1+length(handles.static.bpmList_e):2*length(handles.static.bpmList_e),:);
Data.Reference.Orbits_tmit=Data.Reference.Orbits(1+2*length(handles.static.bpmList_e):3*length(handles.static.bpmList_e),:);
Data.Reference.XAngle=diff(Data.Reference.XLaunch)/handles.LaunchBPMDistance;
Data.Reference.YAngle=diff(Data.Reference.YLaunch)/handles.LaunchBPMDistance;

Tolerances=[str2num(get(handles.EnergyAcc,'string')), str2num(get(handles.LBPM,'string'))];

GAP_POINTS=handles.MEAS_POINTS;

%for GAP_POS
for GAP_POS=1:length(GAP_POINTS)
       if all(get(handles.pushbutton21,'backgroundcolor')==handles.ColorWait)
          set(handles.pushbutton21,'backgroundcolor',handles.ColorIdle);
          EXIT=1;
          return 
       end
           
       if(handles.ONLINE~=2)
            SUCCESS=SetNextGap(handles, DEVICE, GAP_POINTS(GAP_POS), THRESHOLD);
       else
           
           lcaPutSmart(strcat(handles.static.corrList_e,':BCTRL'),BASECORR);
           pause(0.1);
           VALUES=handles.TestTable(GAP_POS,:,SLOTID);
           MyOldValues=lcaGetSmart(strcat(handles.DeviceCorrectorList{SLOTID},':BCTRL'));
           lcaPutSmart(strcat(handles.DeviceCorrectorList{SLOTID},':BCTRL'),VALUES.'+ MyOldValues);
           for II=1:2
               
               %handles.DeviceCorrectorList{SS} handles.TestTable
               pause(0.1)
               disp('MOVING');
           end
       end

       if(~SUCCESS)
           set(handles.TakeData,'enable','on');
           disp('Not Able to set next gap, skipping this one')
           continue
       end
       if(SUCCESS==-1)
          disp('Scan cancelled by user');
          return
       end
       Validity=0;
       while(~Validity)
           TABLE{SLOTID,GAP_POS} = 'TAKING DATA';
           set(handles.TABLE,'data',TABLE); drawnow
           
           if(BSA)
               Data.Orbits.Raw=handles.sf.getBPMData_reserveBSA(handles.static.bpmList_e, min(Samples,2800), 1, eDefNumber,mintmit,handles.EnergyBPMs,ExcludeNaN,handles.BEAMCODE);
               %Data.Reference.Orbits=handles.sf.getBPMData_reserveBSA(handles.static.bpmList_e, 5*Samples, 1, eDefNumber,mintmit,handles.EnergyBPMs);
           else
               Data.Orbits.Raw=handles.sf.getBPMData_caget(handles.static.bpmList_e, Samples, 1,mintmit,handles.EnergyBPMs);
           end
           
       if(handles.ONLINE==2)
            Data.Orbits.Original.Raw=Data.Orbits.Raw;
            Data.Orbits.Original.x=Data.Orbits.Original.Raw(1:length(handles.static.bpmList_e),:);
            Data.Orbits.Original.y=Data.Orbits.Original.Raw(1+length(handles.static.bpmList_e):2*length(handles.static.bpmList_e),:);
            Data.Orbits.Raw(handles.DeviceBPMPositionX{SLOTID},:)=Data.Orbits.Raw(handles.DeviceBPMPositionX{SLOTID},:) - handles.TestTableBPM(GAP_POS,1,SLOTID);
            Data.Orbits.Raw(handles.DeviceBPMPositionY{SLOTID},:)=Data.Orbits.Raw(handles.DeviceBPMPositionY{SLOTID},:) - handles.TestTableBPM(GAP_POS,2,SLOTID);
       end
       Data.Orbits.x=Data.Orbits.Raw(1:length(handles.static.bpmList_e),:);
       Data.Orbits.y=Data.Orbits.Raw(1+length(handles.static.bpmList_e):2*length(handles.static.bpmList_e),:);
       Data.Orbits.tmit=Data.Orbits.Raw(1+2*length(handles.static.bpmList_e):3*length(handles.static.bpmList_e),:);
       
       Data.Orbits.EnergyBPMs=Data.Orbits.Raw(handles.EnergyBPMPos,:);
       Data.Orbits.XLaunch=Data.Orbits.Raw(handles.XLaunchPos,:);
       Data.Orbits.XAngle=diff(Data.Orbits.XLaunch)/handles.LaunchBPMDistance;
       Data.Orbits.YLaunch=Data.Orbits.Raw(handles.YLaunchPos,:);
       Data.Orbits.YAngle=diff(Data.Orbits.YLaunch)/handles.LaunchBPMDistance;
       
       [Validity, SimilarShots] = CheckDataValidity(Data.Orbits, Data.Reference, Tolerances, [handles.ax_XLaunch,handles.ax_YLaunch,handles.ax_Energy, handles.ax_OrbitsX, handles.ax_OrbitsY]);                            
       if(Validity)
            set(handles.DATA_OK,'string',{'DATA','OK'},'backgroundcolor',[0,1,0]); drawnow
        else
            set(handles.DATA_OK,'string',{'DATA','NOT OK','TAKING AGAIN'},'backgroundcolor',[1,0,0]); drawnow
       disp('Launch / Energy different w.r.t reference  - try to take data again'); 
       end

       end
       
       if all(get(handles.pushbutton21,'backgroundcolor')==handles.ColorWait)
          set(handles.pushbutton21,'backgroundcolor',handles.ColorIdle);
          EXIT=1;
          return 
       end
       
       disp('Valid data taken. Launch and Energy match.');
       Data.GapList=GAP_POINTS;
       Data.Gap=GAP_POINTS(GAP_POS);
       Data.Device=DEVICE;
       GAP_CORR_DATA{SLOTID,GAP_POS} = Data;
       set(handles.TABLE,'userdata',GAP_CORR_DATA);
       TABLE{SLOTID,GAP_POS} = 'COLLECTED';
       set(handles.TABLE,'data',TABLE);
end

if(handles.ONLINE~=2)
    SUCCESS=SetNextGap(handles, DEVICE, GapRestore, THRESHOLD);
else
    lcaPutSmart(strcat(handles.static.corrList_e,':BCTRL'),CorrectorStrengths);
end

set(handles.TakeData,'enable','on');
set(handles.pushbutton21,'enable','off');

 
function [Validity, SimilarShots]=CheckDataValidity(Orbits, Reference, Tolerances, ASSI)

SimilarShots.Baseline.x=[]; SimilarShots.Baseline.y=[];
SimilarShots.Measurement.x=[]; SimilarShots.Measurement.y=[];
ins=0; OK={}; OKValues=[]; OverallSimilarity=[]; SortedDistance={}; SortedOrder={};
for II=1:size(Orbits.EnergyBPMs,2)
   DistanceEnergy=sum(abs(Orbits.EnergyBPMs(:,II)*ones(1,size(Reference.EnergyBPMs,2)) - Reference.EnergyBPMs),1); 
   DistanceLaunchPos=sum(abs(Orbits.XLaunch(:,II)*ones(1,size(Reference.XLaunch,2)) - Reference.XLaunch),1) + sum(abs(Orbits.YLaunch(:,II)*ones(1,size(Reference.YLaunch,2)) - Reference.YLaunch),1);
   DistanceLaunchAngle=sum(abs(Orbits.XAngle(:,II)*ones(1,size(Reference.XAngle,2)) - Reference.XAngle),1) + sum(abs(Orbits.YAngle(:,II)*ones(1,size(Reference.YAngle,2)) - Reference.YAngle),1);
   
   OverallSimilarity=DistanceLaunchPos + DistanceLaunchAngle;
   
   OK{II}=find((DistanceLaunchPos<Tolerances(2)) & (DistanceLaunchAngle<Tolerances(2)) & (DistanceEnergy < Tolerances(1)));
   OKValues(II)=length(OK{II});
   
   if(OKValues(II))
        [SortedDistance{II},SortedOrder{II}]=sort(OverallSimilarity(OK{II}),'ascend');
        
        ins=ins+1;
        SimilarShots.Measurement.x(:,ins)=Orbits.x(:,II);
        SimilarShots.Measurement.y(:,ins)=Orbits.y(:,II);
        SimilarShots.Baseline.x(:,ins)=Reference.Orbits_x(:,SortedOrder{II}(1));
        SimilarShots.Baseline.y(:,ins)=Reference.Orbits_y(:,SortedOrder{II}(1));
   else
       SortedDistance{II}=[];
       SortedOrder{II}=[];
   end
end

if(ins==0)
    Validity=0;
else
    Validity=1;
end
if(nargin>3)
    [HR,VR]=hist(Reference.EnergyBPMs(1,:),35);
    bar(ASSI(3),VR,HR,'r'); hold(ASSI(3),'on');
    [HR,VR]=hist(Reference.EnergyBPMs(2,:),35);
    bar(ASSI(3),VR,HR,'m');
    [HR,VR]=hist(Orbits.EnergyBPMs(1,:),35);
    bar(ASSI(3),VR,HR,'facecolor',[0,0,1]);
    [HR,VR]=hist(Orbits.EnergyBPMs(2,:),35);
    bar(ASSI(3),VR,HR,'facecolor',[0,0,0.5]); hold(ASSI(3),'off');
      
    plot(ASSI(1), Reference.XLaunch,'r'); hold(ASSI(1),'on');
    plot(ASSI(1), Orbits.XLaunch,'b--'); hold(ASSI(1),'off');
    
    plot(ASSI(2), Reference.YLaunch,'r'); hold(ASSI(2),'on');
    plot(ASSI(2), Orbits.YLaunch,'b--'); hold(ASSI(2),'off');
    
    plot(ASSI(4), Reference.Orbits_x,'r'); hold(ASSI(4),'on');
    plot(ASSI(4), Orbits.x,'b--'); hold(ASSI(4),'off');
    
    plot(ASSI(5), Reference.Orbits_y,'r'); hold(ASSI(5),'on');
    plot(ASSI(5), Orbits.y,'b--'); hold(ASSI(5),'off');   
end






function SUCCESS=SetNextGap(handles, DEVICE, TARGET_GAP, THRESHOLD)
SUCCESS=0;
DEVICE.f.Set_Gap(DEVICE, TARGET_GAP);
TAVOLA2=get(handles.uitable3,'data');
TAVOLA2{1,3}=TARGET_GAP;
set(handles.uitable3,'data',TAVOLA2); drawnow;
ActualValue=DEVICE.f.Get_Gap(DEVICE);
TAVOLA2{1,2}=ActualValue;
set(handles.uitable3,'data',TAVOLA2); drawnow;
Distance=abs(ActualValue-TARGET_GAP);
COUNTER=0;
while(Distance>THRESHOLD)
    pause(2);
    ActualValue=DEVICE.f.Get_Gap(DEVICE);
    NewDistance=abs(ActualValue-TARGET_GAP);
    if(NewDistance>=Distance)
        COUNTER=COUNTER+1;
        %device seems stopped but not arrived.
        if(COUNTER==20)
            COUNTER=0;
            DEVICE.f.Set_Gap(DEVICE, TARGET_GAP);
            disp('Device seems stopped but not arrived')
        end
    end
    Distance=NewDistance;
    TAVOLA2{1,2}=ActualValue;
    set(handles.uitable3,'data',TAVOLA2); drawnow;

        COLOR=get(handles.pushbutton21,'backgroundcolor');
        if(all(COLOR==handles.ColorWait))
            SUCCESS=-1;
            set(handles.pushbutton21,'backgroundcolor',handles.ColorIdle);
            return
        end
end
set(handles.uitable3,'data',TAVOLA2);
SUCCESS=1;


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


% --- Executes on button press in FIT_GAP_CORRECTION.
function EvalBBA_Callback(hObject, eventdata, handles)
SaveData_Callback(hObject, eventdata, handles); %Saves raw data before looking for trouble.
set(handles.BBA_PANEL,'visible','off');set(handles.ApplyBBA,'visible','on')
return
 WarningMessage=[];

%Make average orbit data here for each recorded position.

disp('analyzing data')
[SA,SB]=size(handles.SelectedElements);
for II=1:SA
   DATA=Data(II,:);
   s=handles.SelectedElements{II,3};
   UL=handles.UL(handles.SelectedElements{II,2});
   cellNumber=UL.slot(s).Chamber.CellNumber;
   corrDir=cell2mat(cellfun(@(x) x(1),handles.static.corrList,'un',0));
   corrNumber=str2num(cell2mat(regexprep(cellfun(@(x) x(end-1:end),handles.static.corrList,'un',0),'M','0')));
   
   Xcorr=handles.static.corrList_e(corrDir=='X');
   Ycorr=handles.static.corrList_e(corrDir=='Y');
   corrNumberX=corrNumber(corrDir=='X');
   corrNumberY=corrNumber(corrDir=='X');
   
   ownCorrectorX=find(corrNumberX==cellNumber);
   beforeCorrectorX=ownCorrectorX-1; %e' ok anche per il primo purche' sia incluso in static.
   ownCorrectorY=find(corrNumberY==cellNumber);
   beforeCorrectorY=ownCorrectorY-1; %e' ok anche per il primo purche' sia incluso in static.
   
   OffsetsFit(SA).Device=handles.SelectedElements{II,1};
   OffsetsFit(SA).prevCorrX=handles.static.corrList_e(beforeCorrectorX);
   OffsetsFit(SA).nextCorrX=handles.static.corrList_e(ownCorrectorX);
   OffsetsFit(SA).prevCorrY=handles.static.corrList_e(beforeCorrectorY);
   OffsetsFit(SA).nextCorrY=handles.static.corrList_e(ownCorrectorY);

   Options.useCorr=false(size(handles.static.corrList));
   Options.useCorr(ownCorrector)=true; Options.useCorr(beforeCorrector)=true;
   Options.rMat=DATA.MODEL.rMat;
   Options.energy=DATA.MODEL.energy;
   
end


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
       set(New_Figure,'name',['Gap Correction Data - Energy = ',num2str(mean(DataToShow.MODEL.energy)) ,' GeV']);
       Position=get(New_Figure,'position');
       set(New_Figure,'position',[Position(1),Position(2)-Position(4),Position(3)*2,Position(4)*2]);
       AX=axes(New_Figure,'position',[0.1,0.1,0.85,0.35]);
       AY=axes(New_Figure,'position',[0.1,0.55,0.85,0.35]);
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
       else
           plot(AX,BPMz,DataToShow.Orbits_x,'color',[0,0,0],'linewidth',2)
           plot(AY,BPMz,DataToShow.Orbits_y,'color',[0,0,0],'linewidth',2)
       end
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
SLOT=get(handles.popupmenu6,'userdata');
VALUE=get(handles.popupmenu6,'value');

TargetGap=str2double(get(handles.edit3,'string'));
handles.UL.slot(SLOT(VALUE)).USEG.f.Set_Gap(handles.UL.slot(SLOT(VALUE)).USEG,TargetGap)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
for HH=1:length(handles.BBA_Energies)
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


% --- Executes on button press in pushbutton12.
function FIT_GAP_CORRECTION_Callback(hObject, eventdata, handles)
D=get(handles.TABLE,'userdata');
targetDir=get(handles.edit6,'string');
options.thresholds=[str2num(get(handles.EnergyAcc,'string')), str2num(get(handles.LBPM,'string'))];
if(isempty(targetDir) || strcmp(targetDir,'pwd')), targetDir=pwd; end
if(handles.ONLINE==2)
   RESULTS=load('TEST'); 
end
L{1}='# Gap correction file';
L{2}=['# Date = ',datestr(now)];

XCORRS=find(cellfun(@(x) x(1), handles.static.corrList_e)=='X');
YCORRS=find(cellfun(@(x) x(1), handles.static.corrList_e)=='Y');

for II=1:size(D,1) %ondulators
    if(isempty(D{II,1}))
        continue
    end
    DeviceInStatic=find(strcmp(handles.static.undList_e,D{II,1}.Device.PV));
    CellNumber=D{II,1}.Device.Cell_Number; CellString=D{II,1}.Device.Cell_String;
    OwnBPM=find(strcmp(cellfun(@(x) x(end-1:end),handles.static.bpmList,'UniformOutput',false),CellString));
    if(any(strfind(D{II,1}.Device.PV,'USEG')))
        L{3}=['# MadDevice = ',handles.static.undList{DeviceInStatic}];
        L{4}=['# EpicsDevice = ',D{II,1}.Device.PV];
        L{5}=['# Undulator Serial = ',D{II,1}.Device.Serial];
        Z=handles.static.zUnd(DeviceInStatic);
    else
        L{3}=['# MadDevice = ',handles.static.phasList{DeviceInStatic}];
        L{4}=['# EpicsDevice = ',D{II,1}.Device.PV];
        L{5}=['# Phaseshifter Serial = ',D{II,1}.Device.Serial];
        Z=handles.static.zPhas(DeviceInStatic);
    end
    PrevX_ID=XCORRS(find(handles.static.zCorr(XCORRS)<Z,1,'last'));
    NextX_ID=XCORRS(find(handles.static.zCorr(XCORRS)>Z,1,'first'));
    PrevY_ID=YCORRS(find(handles.static.zCorr(YCORRS)<Z,1,'last'));
    NextY_ID=YCORRS(find(handles.static.zCorr(YCORRS)>Z,1,'first'));
    L{6}=['# Previous Corrector X = ',handles.static.corrList_e{PrevX_ID}];
    L{7}=['# Previous Corrector Y = ',handles.static.corrList_e{PrevY_ID}];
    L{8}=['# Next Corrector X = ',handles.static.corrList_e{NextX_ID}];
    L{9}=['# Next Corrector Y = ',handles.static.corrList_e{NextY_ID}];
    
    for XX=1:length(OwnBPM)
        L{end+1}=['# Affected BPM N',num2str(XX),' = ',handles.static.bpmList_e{OwnBPM(XX)}];
    end
    
    corrList={handles.static.corrList_e{PrevX_ID},handles.static.corrList_e{NextX_ID},handles.static.corrList_e{PrevY_ID},handles.static.corrList_e{NextY_ID}};
    L{end+1}=['# Gap [mm]        Pr.XCOR[kGm]    Pr.YCOR[kGm]    Ne.XCOR[kGm]    Ne.YCOR[kGm]'];
    for XX=1:length(OwnBPM)
        L{end}=[L{end},'  BPM N',num2str(XX),' x [mm]  ','  BPM N',num2str(XX),' y [mm]  '];
    end
    
    if any(strfind(D{II,1}.Device.PV,'UNDH')), letter='H'; else, letter='S'; end
    filename=['GapCorr_',letter,'_',regexprep(D{II,1}.Device.PV,':','_'),'.dat'];
    
    LaunchBPM=find(handles.static.zBPM<Z);
    SteerBPM=find(handles.static.zBPM>Z);
    
    [~,SORTINGORDER]=sort([PrevX_ID,PrevY_ID,NextX_ID,NextY_ID]);
    
    options.fitBPM=false(size(handles.static.bpmList));
    options.fitBPM(OwnBPM)=true;
    options.useBPMx=false(size(handles.static.bpmList));
    options.useBPMy=false(size(handles.static.bpmList));
    options.useCorr=false(size(handles.static.corrList));
    options.useCorr([PrevX_ID,NextX_ID,PrevY_ID,NextY_ID])=true;
    options.useBPMx=true; options.useBPMy=true;
    options.LaunchBPM=LaunchBPM;
    Matrix=[]; DistanzeTutteCorrettori=[]; DistanzeTutteBPM=[];
    for JJ=1:size(D,2) %gap values
        Orbit.X=D{II,JJ}.Orbits.x;
        Orbit.Y=D{II,JJ}.Orbits.y;
        Orbit.T=D{II,JJ}.Orbits.tmit;
        Orbit.XLaunch=D{II,JJ}.Orbits.XLaunch;
        Orbit.YLaunch=D{II,JJ}.Orbits.YLaunch;
        Orbit.XAngle=D{II,JJ}.Orbits.XAngle;
        Orbit.YAngle=D{II,JJ}.Orbits.YAngle;
        Orbit.EnergyBPMs=D{II,JJ}.Orbits.EnergyBPMs;
        
        Reference.X=D{II,JJ}.Reference.Orbits_x;
        Reference.Y=D{II,JJ}.Reference.Orbits_y;
        Reference.T=D{II,JJ}.Reference.Orbits_tmit;
        Reference.XLaunch=D{II,JJ}.Reference.XLaunch;
        Reference.YLaunch=D{II,JJ}.Reference.YLaunch;
        Reference.XAngle=D{II,JJ}.Reference.XAngle;
        Reference.YAngle=D{II,JJ}.Reference.YAngle;
        Reference.EnergyBPMs=D{II,JJ}.Reference.EnergyBPMs;
        
        options.Orbit=Orbit;
        options.Reference=Reference;
        options.MODEL=D{II,JJ}.MODEL;
        Solution=handles.sf.gapCorrectionFit(handles.static, options);
        if(handles.ONLINE==2)
            
            disp('===============================')
            disp('CORRECTORS')
            disp('SYSTEM SOLUTION:')
            disp(Solution.CorrectorValues(SORTINGORDER).')
            disp('ACTUAL VALUES:')
            disp(RESULTS.TestTable(JJ,:,II))
            DistanzeTutteCorrettori(JJ,:)=abs(Solution.CorrectorValues(SORTINGORDER).'+RESULTS.TestTable(JJ,:,II));
            disp('DIFFERENCE:')
            disp(Solution.CorrectorValues(SORTINGORDER).' + RESULTS.TestTable(JJ,:,II))
            disp('************')
            disp('BPM OFFSETS')
            disp('SYSTEM SOLUTION:')
            disp(Solution.BPMValues.')
            disp('ACTUAL VALUES:')
            disp(RESULTS.TestTableBPM(JJ,:,II))
            disp('DIFFERENCE:')
            disp(Solution.BPMValues.' + RESULTS.TestTableBPM(JJ,:,II))
            DistanzeTutteBPM(JJ,:)=abs(Solution.BPMValues.' + RESULTS.TestTableBPM(JJ,:,II));
        end
        Matrix(JJ,:)=[D{II,JJ}.Gap,Solution.CorrectorValues(SORTINGORDER).',Solution.BPMValues(:).'];
    end
    
    if(handles.ONLINE==2)
        A=figure;
        hist(DistanzeTutteCorrettori(:,1));
        title(max(DistanzeTutteCorrettori(:,1)))
        xlabel('CORR 1')
        A=figure;
        hist(DistanzeTutteCorrettori(:,2));
        title(max(DistanzeTutteCorrettori(:,2)))
        xlabel('CORR 2')
        A=figure;
        hist(DistanzeTutteCorrettori(:,3));
        title(max(DistanzeTutteCorrettori(:,3)))
        xlabel('CORR 3')
        A=figure;
        hist(DistanzeTutteCorrettori(:,4));
        title(max(DistanzeTutteCorrettori(:,4)))
        xlabel('CORR 4')
        A=figure;
        hist(DistanzeTutteBPM(:,1));
        title(max(DistanzeTutteBPM(:,1)))
        xlabel('BPM 1')
        A=figure;
        hist(DistanzeTutteBPM(:,2));
        title(max(DistanzeTutteBPM(:,2)))
        xlabel('BPM 2')
        save TEMPRES DistanzeTutteBPM DistanzeTutteCorrettori
    end
    
    FID=fopen([targetDir,'/',filename],'wt');
    for HH=1:length(L)
        fprintf(FID,[L{HH},'\n']);
    end
    [Size1,Size2]=size(Matrix);
    
    for SS=1:Size1
        string={};
        for DD=1:Size2
            string{DD}=num2str(Matrix(SS,DD),'%3.10f');
        end
    
    
    if(Matrix(SS,1)<10)
        Space='    ';
    elseif(Matrix(SS,1)<100)
        Space='   ';
    else
        Space='  ';
    end
    SpaceFixed='    ';
    SAD=0;
    STRINGA=string{1};
    for DD=2:Size2
        if(Matrix(SS,DD)<0), SAD(DD)=1; else, SAD(DD)=0; end
        if(DD==2)
            STRINGA=[STRINGA,Space(1:end-SAD(DD)),string{DD}];
        else%if(DD<Size2)
            STRINGA=[STRINGA,SpaceFixed(1:end-SAD(DD)),string{DD}];
        %else
        %    STRINGA=[STRINGA,string{DD}];
        end
    end
    fprintf(FID, STRINGA);
    fprintf(FID, '\n');
    end
    fclose(FID);
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
set(handles.BBA_PANEL,'visible','on');set(handles.ApplyBBA,'visible','off')

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
disp(['Disabling transverse feedback for: ',handles.UL.name]);
handles.UL.f.LaunchFeedback_Set(handles.UL,0);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
UpdateTable(handles,handles.UL,1);
set(handles.checkbox3,'value',1);set(handles.checkbox4,'value',0);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
UpdateTable(handles,handles.UL,2);
set(handles.checkbox3,'value',0);set(handles.checkbox4,'value',1);

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
TABLE=get(handles.uitable2,'data');
for II=1:size(TABLE,1)
    TABLE{II,2}=true;
end
set(handles.uitable2,'data',TABLE);


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
TABLE=get(handles.uitable2,'data');
for II=1:size(TABLE,1)
    TABLE{II,2}=false;
end
set(handles.uitable2,'data',TABLE);


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
TABLE=get(handles.uitable2,'data');
for II=1:size(TABLE,1)
    TABLE{II,2}=~TABLE{II,2};
end
set(handles.uitable2,'data',TABLE);



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


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
TABLE=get(handles.uitable2,'data');
EXPR=str2num(get(handles.edit4,'string'));
for II=1:size(TABLE,1)
    if(any(II==EXPR))
        TABLE{II,2}=true;
    else
        TABLE{II,2}=false;
    end
end
set(handles.uitable2,'data',TABLE);



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


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
set(handles.pushbutton21,'backgroundcolor',handles.ColorWait);
drawnow


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)



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


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
set(handles.TakeData,'enable','on');
set(handles.pushbutton21,'backgroundcolor',handles.ColorIdle);


% --- Executes during object creation, after setting all properties.
function pushbutton21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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


% --- Executes on button press in Reserve.
function myeDefNumber=Reserve_Callback(hObject, eventdata, handles)
myeDefNumber=eDefReserve('Gap correction GUI');
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


% --- Executes on button press in DoNotBSA.
function DoNotBSA_Callback(hObject, eventdata, handles)
set(handles.useBSA,'value',0); set(handles.DoNotBSA,'value',1);


% --- Executes on button press in SaveData.
function SaveData_Callback(hObject, eventdata, handles)
restore.MODEL_TYPE=handles.MODEL_TYPE;
restore.BEAMPATH=handles.BEAMPATH;
restore.BEAMCODE=handles.BEAMCODE;
restore.static=handles.static;
restore.UL=handles.UL;
restore.PhyConsts=handles.PhyConsts;
restore.USEG=handles.USEG;
restore.PHAS=handles.PHAS;
restore.SelectedElements=handles.SelectedElements;
restore.GapPoints=handles.GapPoints;
restore.Pos=handles.Pos;
restore.StartBPM=handles.StartBPM;
restore.ToList=handles.ToList;
restore.PosList=handles.PosList;
restore.Data_Table_Appearance=get(handles.TABLE,'data');
Data=get(handles.TABLE,'userdata');
restore.DeviceSelection_list=get(handles.popupmenu5,'string');
restore.DevicePosition_Table=get(handles.uitable3,'data');
restore.UniqueGuiRunString=handles.UniqueGuiRunString;
restore.DeviceList=get(handles.TABLE,'rowname');
restore.DeviceList2=get(handles.TABLE,'columnname');
restore.SLOT=get(handles.popupmenu5,'userdata');

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

if(exist(targetdir))
    save([targetdir,'/',filename],'Data','restore','-v7.3');
else
    mkdir(targetdir);
    save([targetdir,'/',filename],'Data','restore','-v7.3');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
CurrentTime=clock;
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentGiornoString=num2str(CurrentTime(3),'%.2d');
targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentGiornoString];
[FILENAME,FILEPATH]=uigetfile(targetdir);
load([FILEPATH,'/',FILENAME],'Data','restore');

handles.BEAMCODE=restore.BEAMCODE;
handles.MODEL_TYPE=restore.MODEL_TYPE;
handles.BEAMPATH=restore.BEAMPATH;
handles.static=restore.static;
handles.UL=restore.UL;
handles.PhyConsts=restore.PhyConsts;
handles.USEG=restore.USEG;
handles.PHAS=restore.PHAS;
handles.SelectedElements=restore.SelectedElements;
handles.GapPoints=restore.GapPoints;
handles.Pos=restore.Pos;
handles.StartBPM=restore.StartBPM;
handles.ToList=restore.ToList;
handles.PosList=restore.PosList;
set(handles.TABLE,'data',restore.Data_Table_Appearance);
set(handles.TABLE,'userdata',Data);
set(handles.TABLE,'rowname',restore.DeviceList);
set(handles.TABLE,'columnname',restore.DeviceList2);
set(handles.popupmenu5,'string',restore.DeviceSelection_list); set(handles.popupmenu5,'value',1)
set(handles.popupmenu6,'userdata',restore.SLOT); set(handles.popupmenu5,'userdata',restore.SLOT);
set(handles.popupmenu6,'string',DeviceList_list); set(handles.popupmenu6,'value',1);
set(handles.uitable3,'data',restore.DevicePosition_Table);
handles.UniqueGuiRunString=restore.UniqueGuiRunString;
set(handles.FN,'string',handles.UniqueGuiRunString);

guidata(hObject, handles);

set(handles.ApplyBBA,'visible','off'); set(handles.ULS,'visible','off'); set(handles.PA,'visible','off'); set(handles.BBA_PANEL,'visible','on');


%Set visibility

% --- Executes on button press in NewFilename.
function NewFilename_Callback(hObject, eventdata, handles)
handles.UniqueGuiRunString=['Gap Correction GUI ',datestr(now)];
set(handles.FN,'string',handles.UniqueGuiRunString);
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    Release_Callback(hObject, eventdata, handles);
end
% Hint: delete(hObject) closes the figure
delete(hObject);



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


% --- Executes on button press in c9.
function c9_Callback(hObject, eventdata, handles)
set(handles.c9,'value',1); set(handles.c10,'value',0); 
% --- Executes on button press in c10.
function c10_Callback(hObject, eventdata, handles)
set(handles.c9,'value',0); set(handles.c10,'value',1);  



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
% hObject    handle to c10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c10
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
set(handles.BBA_PANEL,'visible','on');set(handles.ApplyBBA,'visible','off')



function mincharge_Callback(hObject, eventdata, handles)
% hObject    handle to mincharge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mincharge as text
%        str2double(get(hObject,'String')) returns contents of mincharge as a double


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


% --- Executes on button press in c11.
function c11_Callback(hObject, eventdata, handles)
set(handles.c9,'value',0); set(handles.c10,'value',0); set(handles.c11,'value',1);


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
LISTA=get(handles.popupmenu5,'string');
for TT=1:numel(LISTA)
    set(handles.popupmenu5,'value',TT); pause(0.05); drawnow
    EXIT=TakeData_Callback(hObject, eventdata, handles);
    if(EXIT)
        return
    end
end

% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
options.MODEL_TYPE='EXTANT';
s=handles.static;
% XSL=find(cellfun(@(x) x(1),s.corrList)=='X'); YSL=find(cellfun(@(x) x(1),s.corrList)=='Y');
% XS=find(cellfun(@(x) x(1),handles.launch_corr.corrList)=='X'); YS=find(cellfun(@(x) x(1),handles.launch_corr.corrList)=='Y');
% 
% s.corrList_e=[handles.launch_corr.corrList_e(XS(end-3:end)) ; s.corrList_e(XSL) ; handles.launch_corr.corrList_e(YS(end-3:end)) ; s.corrList_e(YSL) ];
% s.corrList=[handles.launch_corr.corrList(XS(end-3:end)) ; s.corrList(XSL) ; handles.launch_corr.corrList(YS(end-3:end)) ; s.corrList(YSL) ];
% s.zCorr=[handles.launch_corr.zCorr(XS(end-3:end)) , s.zCorr(XSL) , handles.launch_corr.zCorr(YS(end-3:end)) , s.zCorr(YSL) ];
% s.lCorr=[handles.launch_corr.lCorr(XS(end-3:end)) , s.lCorr(XSL) , handles.launch_corr.lCorr(YS(end-3:end)) , s.lCorr(YSL) ];

options.useBPMx=true(length(s.bpmList),1);
options.useBPMy=true(length(s.bpmList),1);
options.useCorr=true(length(s.corrList),1);
options.tmitMin=-1;

if(handles.ONLINE==2) %'test mode'
    options.BSA_HB=0;
    options.BSA=0;
    options.CAGET=1;
    options.Samples=3;
else
    options.BSA_HB=1;
    options.BSA=0;
    options.CAGET=0;
end

Solution=handles.sf.steer(s, options);
lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr);



function kickmag_Callback(hObject, eventdata, handles)
% hObject    handle to kickmag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kickmag as text
%        str2double(get(hObject,'String')) returns contents of kickmag as a double


% --- Executes during object creation, after setting all properties.
function kickmag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kickmag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bpmmag_Callback(hObject, eventdata, handles)
% hObject    handle to bpmmag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bpmmag as text
%        str2double(get(hObject,'String')) returns contents of bpmmag as a double


% --- Executes during object creation, after setting all properties.
function bpmmag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpmmag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EnergyAcc_Callback(hObject, eventdata, handles)
% hObject    handle to EnergyAcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EnergyAcc as text
%        str2double(get(hObject,'String')) returns contents of EnergyAcc as a double


% --- Executes during object creation, after setting all properties.
function EnergyAcc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnergyAcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LBPM_Callback(hObject, eventdata, handles)
% hObject    handle to LBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LBPM as text
%        str2double(get(hObject,'String')) returns contents of LBPM as a double


% --- Executes during object creation, after setting all properties.
function LBPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UseStandard.
function UseStandard_Callback(hObject, eventdata, handles)
% hObject    handle to UseStandard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseStandard


% --- Executes on button press in ExcludeNaN.
function ExcludeNaN_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeNaN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExcludeNaN



function DA_GT_Callback(hObject, eventdata, handles)
% hObject    handle to DA_GT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DA_GT as text
%        str2double(get(hObject,'String')) returns contents of DA_GT as a double


% --- Executes during object creation, after setting all properties.
function DA_GT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DA_GT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
