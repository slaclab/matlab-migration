function varargout = ARC_DualEnergySteering_gui(varargin)
%ARC_DualEnergySteering_gui MATLAB code file for ARC_DualEnergySteering_gui.fig
%      ARC_DualEnergySteering_gui, by itself, creates a new ARC_DualEnergySteering_gui or raises the existing
%      singleton*.
%
%      H = ARC_DualEnergySteering_gui returns the handle to a new ARC_DualEnergySteering_gui or the handle to
%      the existing singleton*.
%
%      ARC_DualEnergySteering_gui('Property','Value',...) creates a new ARC_DualEnergySteering_gui using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ARC_DualEnergySteering_gui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ARC_DualEnergySteering_gui('CALLBACK') and ARC_DualEnergySteering_gui('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ARC_DualEnergySteering_gui.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ARC_DualEnergySteering_gui

% Last Modified by GUIDE v2.5 01-Apr-2021 10:57:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ARC_DualEnergySteering_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ARC_DualEnergySteering_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before ARC_DualEnergySteering_gui is made visible.
function ARC_DualEnergySteering_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.ARC=ARC_Steering_Class;
handles.sh=Steering_Functions();
handles.filepath='/u1/lcls/matlab/orbitPatchwork_saves/Dual_Energy_Steering';
try
    %if online get a model to populate tables
    handles.ARC.makeStatic({'HXR','SXR'});
catch
    %if not online load some stuff from files, mainly for testing
    handles.ARC.loadModelFromFile('DualEnergySteeringConfig1.mat');
    handles.ARC.loadStaticFromFile('DualEnergySteeringConfig1.mat');
end

handles.colorOn=[0,1,0];
handles.colorOff=get(handles.DESELALLCORRECTORS,'backgroundcolor');

set(handles.xAutoZ,'backgroundcolor',handles.colorOn);
set(handles.xAutoX,'backgroundcolor',handles.colorOn);
set(handles.yAutoZ,'backgroundcolor',handles.colorOn);
set(handles.yAutoY,'backgroundcolor',handles.colorOn);
set(handles.zm,'string','0'); set(handles.zM,'string','1800');
set(handles.zzm,'string','0'); set(handles.zzM,'string','1800');
set(handles.xm,'string','-3'); set(handles.xM,'string','3');
set(handles.ym,'string','-3'); set(handles.yM,'string','3');

MatlabEToolboxversion=version;
dotposition=find(MatlabEToolboxversion=='.',1,'first');
handles.VER=str2double(MatlabEToolboxversion(1:(dotposition-1)));

CTAB={};
CTAB(:,1)=handles.ARC.static.X.corrList_e_shortname;
CTAB(:,2)=num2cell(handles.ARC.static.X.zCorr);
CTAB(:,3)=num2cell(char('B'*(handles.ARC.static.X.sCorr & handles.ARC.static.X.hCorr) + 'S'*(handles.ARC.static.X.sCorr & ~handles.ARC.static.X.hCorr) + 'H'*(~handles.ARC.static.X.sCorr & handles.ARC.static.X.hCorr)));
CTAB(:,4)=num2cell(false(size(CTAB(:,1))));
CTAB(:,5)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,6)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,7)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB{end,8}=[];
handles.XCclear=CTAB(:,8);
set(handles.XC,'data',CTAB);

CTAB={};
CTAB(:,1)=handles.ARC.static.Y.corrList_e_shortname;
CTAB(:,2)=num2cell(handles.ARC.static.Y.zCorr);
CTAB(:,3)=num2cell(char('B'*(handles.ARC.static.Y.sCorr & handles.ARC.static.Y.hCorr) + 'S'*(handles.ARC.static.Y.sCorr & ~handles.ARC.static.Y.hCorr) + 'H'*(~handles.ARC.static.Y.sCorr & handles.ARC.static.Y.hCorr)));
CTAB(:,4)=num2cell(false(size(CTAB(:,1))));
CTAB(:,5)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,6)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,7)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB{end,8}=[];
handles.YCclear=CTAB(:,8);
set(handles.YC,'data',CTAB);

CTAB={};
CTAB(:,1)=regexprep(handles.ARC.static.bpmList_e(handles.ARC.static.sBpm),'BPMS:','');
CTAB(:,2)=num2cell(handles.ARC.static.zBPM(handles.ARC.static.sBpm));
CTAB(:,3)=num2cell(false(size(CTAB(:,1))));
CTAB(:,4)=num2cell(false(size(CTAB(:,1))));
CTAB(:,5)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,6)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,7)=num2cell(zeros(size(CTAB(:,1))));
CTAB(:,8)=num2cell(zeros(size(CTAB(:,1))));
set(handles.SB,'data',CTAB);

CTAB={};
CTAB(:,1)=regexprep(handles.ARC.static.bpmList_e(handles.ARC.static.hBpm),'BPMS:','');
CTAB(:,2)=num2cell(handles.ARC.static.zBPM(handles.ARC.static.hBpm));
CTAB(:,3)=num2cell(false(size(CTAB(:,1))));
CTAB(:,4)=num2cell(false(size(CTAB(:,1))));
CTAB(:,5)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,6)=num2cell(NaN*ones(size(CTAB(:,1))));
CTAB(:,7)=num2cell(zeros(size(CTAB(:,1))));
CTAB(:,8)=num2cell(zeros(size(CTAB(:,1))));
set(handles.HB,'data',CTAB);

set(handles.HB,'Columnname',{'BPM','Hard z','UseX','UseY','Val X','Val Y','Target X','Target Y'});
set(handles.SB,'Columnname',{'BPM','Soft z','UseX','UseY','Val X','Val Y','Target X','Target Y'});
set(handles.XC,'Columnname',{'XCOR','z','Line','Use','Config','Current','New Value','Out Of Range'});
set(handles.YC,'Columnname',{'YCOR','z','Line','Use','Config','Current','New Value','Out Of Range'});

set(handles.HB,'ColumnWidth',{60,70,30,30,70,70,70,70})
set(handles.SB,'ColumnWidth',{60,70,30,30,70,70,70,70})
set(handles.XC,'ColumnWidth',{60,70,30,30,70,70,70,70})
set(handles.YC,'ColumnWidth',{60,70,30,30,70,70,70,70})

set(handles.XC,'ColumnEditable',[false,false,false,true,false,false,true,false]);
set(handles.YC,'ColumnEditable',[false,false,false,true,false,false,true,false]);
set(handles.SB,'ColumnEditable',[false,false,true,true,false,false,true,true]);
set(handles.HB,'ColumnEditable',[false,false,true,true,false,false,true,true]);

handles.CONF=repmat({'Dataset '},[50,1]);
handles.PLOTTA{1,1}='0 orbit';
handles.PLOTTA{2,1}='Config';
handles.PLOTTA{3,1}='New from Config';

for II=1:numel(handles.CONF)
   handles.CONF{II}=[handles.CONF{II},' ',num2str(II)];
   handles.PLOTTA{end+1}=handles.CONF{II};
end
handles.PLOTTA=handles.PLOTTA(:);
handles.PLOTTA(:,2)=num2cell(false(length(handles.PLOTTA),1));
handles.PLOTTA{2,2}=true;
handles.PLOTTA{3,2}=true;

set(handles.TD_SEL,'string',handles.CONF); set(handles.TD_SEL,'value',1);
set(handles.Plotta,'data',handles.PLOTTA);
set(handles.Plotta,'ColumnEditable',[false,true]);
set(handles.Plotta,'ColumnWidth',{100,30});

set(handles.XC_SelFrom,'string',handles.ARC.static.X.corrList_e);set(handles.XC_SelFrom,'value',1);
set(handles.XC_SelTo,'string',handles.ARC.static.X.corrList_e);set(handles.XC_SelTo,'value',1);

set(handles.YC_SelFrom,'string',handles.ARC.static.Y.corrList_e);set(handles.YC_SelFrom,'value',1);
set(handles.YC_SelTo,'string',handles.ARC.static.Y.corrList_e);set(handles.YC_SelTo,'value',1);

set(handles.C_SelFrom,'string',handles.ARC.static.corrList_e);set(handles.C_SelFrom,'value',1);
set(handles.C_SelTo,'string',handles.ARC.static.corrList_e);set(handles.C_SelTo,'value',1);

set(handles.SBPM,'string',handles.ARC.static.bpmList_e); set(handles.SBPM,'value',1);
set(handles.EBPM,'string',handles.ARC.static.bpmList_e); set(handles.EBPM,'value',1);
set(handles.SBPMS,'string',handles.ARC.staticS.bpmList_e); set(handles.SBPM,'value',1);
set(handles.EBPMS,'string',handles.ARC.staticS.bpmList_e); set(handles.EBPM,'value',1);
set(handles.SBPMH,'string',handles.ARC.staticH.bpmList_e); set(handles.SBPM,'value',1);
set(handles.EBPMH,'string',handles.ARC.staticH.bpmList_e); set(handles.EBPM,'value',1);

update_recConfs(handles);

set(handles.MessageList,'string','');
AddMessage(handles.MessageList,[datestr(now),' Dual energy steering GUI started'],50);

% Choose default command line output for ARC_DualEnergySteering_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ARC_DualEnergySteering_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ARC_DualEnergySteering_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function update_plot(handles,AxX,AxY,addnames)
P.xm=-0.05;
P.xM=0.05;
P.ym=-0.05;
P.yM=0.05;
P.zm=0;
P.zM=1800;
P.zmm=0;
P.zMM=1800;

HB=get(handles.HB,'data');
SB=get(handles.SB,'data');

if(nargin==3)
    addnames=0;
end
cla(AxX); cla(AxY);
hold(AxX,'on'); hold(AxY,'on');
Plotta=get(handles.Plotta,'data');
if(Plotta{1,2})
   plot(AxX,handles.ARC.staticS.zBPM,0*handles.ARC.staticS.zBPM,':'); %X
   plot(AxX,handles.ARC.staticH.zBPM,0*handles.ARC.staticH.zBPM,':'); %X
   plot(AxY,handles.ARC.staticS.zBPM,0*handles.ARC.staticS.zBPM,':'); %Y
   plot(AxY,handles.ARC.staticH.zBPM,0*handles.ARC.staticH.zBPM,':'); %Y
end
if(Plotta{2,2})
   SX=SB(:,5); HX=HB(:,5);
   SY=SB(:,6); HY=HB(:,6);
   plot(AxX,handles.ARC.staticS.zBPM,cell2mat(SX),'rx:'); %X
   plot(AxX,handles.ARC.staticH.zBPM,cell2mat(HX),'kx:'); %X
   plot(AxY,handles.ARC.staticS.zBPM,cell2mat(SY),'rx:'); %Y
   plot(AxY,handles.ARC.staticH.zBPM,cell2mat(HY),'kx:'); %Y
end
if(Plotta{3,2})
   ID=get(handles.TAB_SHOW,'value');
   MS=handles.ARC.D(ID).MODEL_S;
   MH=handles.ARC.D(ID).MODEL_H;
   
   HB=get(handles.HB,'data');
   SB=get(handles.SB,'data');
   SX=cell2mat(SB(:,5)); HX=cell2mat(HB(:,5));
   SY=cell2mat(SB(:,6)); HY=cell2mat(HB(:,6));
   
   XC=get(handles.XC,'data');
   YC=get(handles.YC,'data');
   
   ConfCorrX=cell2mat(XC(:,5));
   ConfCorrY=cell2mat(YC(:,5));
   NewCorrX=cell2mat(XC(:,7));
   NewCorrY=cell2mat(YC(:,7));
   
   DeltaCorrX= NewCorrX - ConfCorrX;
   DeltaCorrY= NewCorrY - ConfCorrY;
   
   %Cast new correctors on X-Y;
   
   [CorrMatrix_S,CorrMatrixAngles_S]=handles.sh.CorrectorOrbitMatrix_Fast(handles.ARC.staticS,MS.rMat,MS.Pos,MS.energy);
   [CorrMatrix_H,CorrMatrixAngles_H]=handles.sh.CorrectorOrbitMatrix_Fast(handles.ARC.staticH,MH.rMat,MH.Pos,MH.energy);
   
   [~,where_X_from_Soft,where_Soft_X] = intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticS.corrList_e,'stable');
   [~,where_X_from_Hard,where_Hard_X] = intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticH.corrList_e,'stable');
   [~,where_Y_from_Soft,where_Soft_Y] = intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticS.corrList_e,'stable');
   [~,where_Y_from_Hard,where_Hard_Y] = intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticH.corrList_e,'stable');
   
   Difference_CorrectorsH=0*handles.ARC.D(ID).CorrectorStrengths_H;
   Difference_CorrectorsS=0*handles.ARC.D(ID).CorrectorStrengths_S;
   Difference_CorrectorsH(where_Hard_X)=DeltaCorrX(where_X_from_Hard);
   Difference_CorrectorsH(where_Hard_Y)=DeltaCorrY(where_Y_from_Hard);
   Difference_CorrectorsS(where_Soft_X)=DeltaCorrX(where_X_from_Soft);
   Difference_CorrectorsS(where_Soft_Y)=DeltaCorrY(where_Y_from_Soft);
   
   InducedOrbit_S=CorrMatrix_S*Difference_CorrectorsS(:)*1000; %otherwise orbit in in meters.
   InducedOrbit_H=CorrMatrix_H*Difference_CorrectorsH(:)*1000; %otherwise orbit in in meters.
    
   InducedOrbit_SX=InducedOrbit_S(1:2:end);
   InducedOrbit_SY=InducedOrbit_S(2:2:end);
   InducedOrbit_HX=InducedOrbit_H(1:2:end);
   InducedOrbit_HY=InducedOrbit_H(2:2:end);
   
   NewOrbit_SX=SX+InducedOrbit_SX;
   NewOrbit_SY=SY+InducedOrbit_SY;
   NewOrbit_HX=HX+InducedOrbit_HX;
   NewOrbit_HY=HY+InducedOrbit_HY;
   
   plot(AxX,handles.ARC.staticS.zBPM,NewOrbit_SX,'bo:'); %X
   plot(AxX,handles.ARC.staticH.zBPM,NewOrbit_HX,'mo:'); %X
   plot(AxY,handles.ARC.staticS.zBPM,NewOrbit_SY,'bo:'); %Y
   plot(AxY,handles.ARC.staticH.zBPM,NewOrbit_HY,'mo:'); %Y
end
for II=1:size(Plotta,1)
    if(II<=3), continue, end
    if(Plotta{II,2})
       ID=II-3;
       SX=handles.ARC.D(ID).MS_X; HX=handles.ARC.D(ID).MH_X;
       SY=handles.ARC.D(ID).MS_Y; HY=handles.ARC.D(ID).MH_Y;
       plot(AxX,handles.ARC.staticS.zBPM,SX,'yd:'); %X
       plot(AxX,handles.ARC.staticH.zBPM,HX,'cd:'); %X
       plot(AxY,handles.ARC.staticS.zBPM,SY,'yd:'); %Y
       plot(AxY,handles.ARC.staticH.zBPM,HY,'cd:'); %Y
    end
    
end
if(addnames)
    if(handles.VER<=7)
        axes(AxX);
        for II=1:length(handles.ARC.static.zBPM)
            text(handles.ARC.static.zBPM(II),0.8,regexprep(handles.ARC.static.bpmList_e{II},'BPMS:',''),'Rotation',90,'HorizontalAlignment','center');
        end
        axes(AxY);
        for II=1:length(handles.ARC.static.zBPM)
            text(handles.ARC.static.zBPM(II),0.8,regexprep(handles.ARC.static.bpmList_e{II},'BPMS:',''),'Rotation',90,'HorizontalAlignment','center');
        end
    else
        for II=1:length(handles.ARC.static.zBPM)
            text(AxX,handles.ARC.static.zBPM(II),0.8,regexprep(handles.ARC.static.bpmList_e{II},'BPMS:',''),'Rotation',90,'HorizontalAlignment','center');
            text(AxY,handles.ARC.static.zBPM(II),0.8,regexprep(handles.ARC.static.bpmList_e{II},'BPMS:',''),'Rotation',90,'HorizontalAlignment','center');
        end
    end
end

function update_recConfs(handles)
SEL=zeros(size(handles.CONF));
for II=1:length(handles.ARC.D)
   if(II)
      SEL(II)=1; 
   end
end
if(~sum(SEL))
     set(handles.TAB_SHOW,'string',{'No data yet'});
    return
end
Available=handles.CONF(logical(SEL));
set(handles.TAB_SHOW,'string',Available);

function update_table(handles)
ID=get(handles.TAB_SHOW,'value');
STR=get(handles.TAB_SHOW,'string');
STR=STR{ID};
IDS=regexprep(STR,'Dataset ','');
ID=str2double(IDS);
if(~isempty(handles.ARC.D(ID)))
   HB=get(handles.HB,'data');
   SB=get(handles.SB,'data');
   XC=get(handles.XC,'data');
   YC=get(handles.YC,'data');
   [~,WASX,WSX]=intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticS.corrList_e);
   [~,WASY,WSY]=intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticS.corrList_e);
   [~,WAHX,WHX]=intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticH.corrList_e);
   [~,WAHY,WHY]=intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticH.corrList_e);
   
   CX=NaN*ones(size(XC(:,5)));
   CY=NaN*ones(size(YC(:,5)));
   
   if(isfield(handles.ARC.D(ID),'CorrectorStrengths_S')) 
       CX(WASX)=handles.ARC.D(ID).CorrectorStrengths_S(WSX);
       CY(WASY)=handles.ARC.D(ID).CorrectorStrengths_S(WSY);
   end
   if(isfield(handles.ARC.D(ID),'CorrectorStrengths_H')) 
       CX(WAHX)=handles.ARC.D(ID).CorrectorStrengths_H(WHX);
       CY(WAHY)=handles.ARC.D(ID).CorrectorStrengths_H(WHY);
   end
   
   XC(:,5)=num2cell(CX);
   YC(:,5)=num2cell(CY);
   XC(:,7)=num2cell(CX);
   YC(:,7)=num2cell(CY);
   
   HB(:,5)=num2cell(handles.ARC.D(ID).MH_X);
   HB(:,6)=num2cell(handles.ARC.D(ID).MH_Y);
   SB(:,5)=num2cell(handles.ARC.D(ID).MS_X);
   SB(:,6)=num2cell(handles.ARC.D(ID).MS_Y);
   
   set(handles.HB,'data',HB);
   set(handles.SB,'data',SB);
   set(handles.XC,'data',XC);
   set(handles.YC,'data',YC);
end


% --- Executes on button press in TakeDataAndSteer.
function TakeDataAndSteer_Callback(hObject, eventdata, handles)
% hObject    handle to TakeDataAndSteer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TakeDataOnly.
function TakeDataOnly_Callback(hObject, eventdata, handles)
Samples=round(str2num(get(handles.SampleN,'string')));
ID=get(handles.TD_SEL,'value');
takeModel=1;
handles.ARC.takeData(ID,Samples,takeModel);
EXCN=get(handles.ExcludeNaN,'value');
handles.ARC.evaluate_avg_trajectory(EXCN,-inf,4,ID);
update_recConfs(handles);
update_table(handles);


% --- Executes on button press in OpenSteerPanel.
function OpenSteerPanel_Callback(hObject, eventdata, handles)
% hObject    handle to OpenSteerPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in TD_SEL.
function TD_SEL_Callback(hObject, eventdata, handles)
% hObject    handle to TD_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TD_SEL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TD_SEL


% --- Executes during object creation, after setting all properties.
function TD_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TD_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
disp('Reading correctors from machine');
CorrVal_X=lcaGetSmart(strcat(handles.ARC.static.X.corrList_e,':BCTRL'));
CorrVal_Y=lcaGetSmart(strcat(handles.ARC.static.Y.corrList_e,':BCTRL'));
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XC(:,6)=num2cell(CorrVal_X); YC(:,6)=num2cell(CorrVal_Y);
set(handles.XC,'data',XC); set(handles.YC,'data',YC);
update_plot(handles,handles.axes1,handles.axes2);


% --- Executes on button press in DetachFigure.
function DetachFigure_Callback(hObject, eventdata, handles)
if(handles.VER<=7)
    BPMnames=get(handles.BPMnames,'value');
    F7=figure(7); AX7=axes();
    set(F7,'position',[0,0,1600,400]);
    set(F7,'name','X - Trajectory');

    F10=figure(10); AX10=axes();
    set(F10,'name','Y - Trajectory');
    set(F10,'position',[0,500,1600,400]);
    update_plot(handles,AX7,AX10,BPMnames);
else
    BPMnames=get(handles.BPMnames,'value');
    F1571=figure(1571);
    set(F1571,'position',[0,0,1600,400]);
    F1571.Name='X - Trajectory';
    AX1571=axes('parent',F1571);
    F1920=figure(1920);
    F1920.Name='Y - Trajectory';
    set(F1920,'position',[0,500,1600,400]);
    AX1920=axes('parent',F1920);
    update_plot(handles,AX1571,AX1920,BPMnames);
end


% --- Executes on selection change in TAB_SHOW.
function TAB_SHOW_Callback(hObject, eventdata, handles)
update_table(handles);

% --- Executes during object creation, after setting all properties.
function TAB_SHOW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TAB_SHOW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadOrbitFromFile.
function LoadOrbitFromFile_Callback(hObject, eventdata, handles)
FN=get(handles.Filename,'string');
ID=get(handles.TD_SEL,'value');
handles.ARC.loadOrbitFromFile(ID,FN);
handles.ARC.evaluate_avg_trajectory(1,0,7,ID)
guidata(hObject, handles);
update_recConfs(handles);
set(handles.TAB_SHOW,'value',ID);
update_table(handles)


function Filename_Callback(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Filename as text
%        str2double(get(hObject,'String')) returns contents of Filename as a double


% --- Executes during object creation, after setting all properties.
function Filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in Plotta.
function Plotta_CellEditCallback(hObject, eventdata, handles)
update_plot(handles,handles.axes1,handles.axes2);


% --- Executes when entered data in editable cell(s) in XC.
function XC_CellEditCallback(hObject, eventdata, handles)
UpdatePlot=0;
try
    if(eventdata.Indices(2)==7)
        UpdatePlot=1;
    end
catch
end
if(UpdatePlot)
    check_for_out_of_range_values(handles);
    update_plot(handles,handles.axes1,handles.axes2);
end

function check_for_out_of_range_values(handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
NCX=cell2mat(XC(:,7)); NCY=cell2mat(YC(:,7));
XABOVE=find(NCX-eps/13>handles.ARC.static.X.corrRange(:,2));
XBELOW=find(NCX+eps/13<handles.ARC.static.X.corrRange(:,1));
YABOVE=find(NCY-eps/13>handles.ARC.static.Y.corrRange(:,2));
YBELOW=find(NCY+eps/13<handles.ARC.static.Y.corrRange(:,1));
if(isempty(XABOVE) && isempty(XBELOW) && isempty(XABOVE) && isempty(XBELOW))
    AddMessage(handles.MessageList,'',50);
    AddMessage(handles.MessageList,[datestr(now),' All correctors are within range'],50);
else
    AddMessage(handles.MessageList,'',50);
    AddMessage(handles.MessageList,[datestr(now),' Out of range correctors'],50);
end
XC(:,8)=handles.XCclear;
YC(:,8)=handles.YCclear;
if(~isempty(XABOVE))
    for II=1:length(XABOVE)
        XC{XABOVE(II),8}='Too high';
        AddMessage(handles.MessageList,['XCOR:',XC{XABOVE(II),1},' too high (max: ',num2str(handles.ARC.static.X.corrRange(XABOVE(II),2)),' )'],50);
    end
end
if(~isempty(XBELOW))
    for II=1:length(XBELOW)
        XC{XBELOW(II),8}='Too low';
        AddMessage(handles.MessageList,['XCOR:',XC{XBELOW(II),1},' too low (min: ',num2str(handles.ARC.static.X.corrRange(XBELOW(II),1)),' )'],50);
    end
end
if(~isempty(YABOVE))
    for II=1:length(YABOVE)
        YC{YABOVE(II),8}='Too high';
        AddMessage(handles.MessageList,['YCOR:',YC{YABOVE(II),1},' too high (max: ',num2str(handles.ARC.static.Y.corrRange(YABOVE(II),2)),' )'],50);
    end
end
if(~isempty(YBELOW))
    for II=1:length(YBELOW)
        YC{YBELOW(II),8}='Too low';
        AddMessage(handles.MessageList,['YCOR:',YC{YBELOW(II),1},' too low (min: ',num2str(handles.ARC.static.Y.corrRange(YBELOW(II),1)),' )'],50);
    end
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);

function AddMessage(List,String,MaxMessages)
Messaggi=get(List,'string');
NumeroMessaggi=numel(Messaggi);
if(NumeroMessaggi>=MaxMessages)
    Messaggi(1)=[];
    Messaggi{MaxMessages}=String;
    set(List,'value',NumeroMessaggi);
    set(List,'string',Messaggi);
else
    Messaggi{NumeroMessaggi+1}=String;
    set(List,'string',Messaggi);
    set(List,'value',NumeroMessaggi+1);
end


% --- Executes on selection change in MessageList.
function MessageList_Callback(hObject, eventdata, handles)
% hObject    handle to MessageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MessageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MessageList


% --- Executes during object creation, after setting all properties.
function MessageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in YC.
function YC_CellEditCallback(hObject, eventdata, handles)
UpdatePlot=0;
try
    if(eventdata.Indices(2)==7)
        UpdatePlot=1;
    end
catch
end
if(UpdatePlot)
    check_for_out_of_range_values(handles);
    update_plot(handles,handles.axes1,handles.axes2);
end


% --- Executes on button press in RailAndUncheck.
function RailAndUncheck_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
NCX=cell2mat(XC(:,7)); NCY=cell2mat(YC(:,7));
XABOVE=find(NCX>handles.ARC.static.X.corrRange(:,2));
XBELOW=find(NCX<handles.ARC.static.X.corrRange(:,1));
YABOVE=find(NCY>handles.ARC.static.Y.corrRange(:,2));
YBELOW=find(NCY<handles.ARC.static.Y.corrRange(:,1));
if(isempty(XABOVE) && isempty(XBELOW) && isempty(XABOVE) && isempty(XBELOW))
    AddMessage(handles.MessageList,'',50);
    AddMessage(handles.MessageList,[datestr(now),' All correctors were within range, nothing done.'],50);
else
    AddMessage(handles.MessageList,'',50);
    AddMessage(handles.MessageList,[datestr(now),' Railing and unchecking ...'],50);
end

if(~isempty(XABOVE))
    for II=1:length(XABOVE)
        XC{XABOVE(II),8}='';
        XC{XABOVE(II),7}=handles.ARC.static.X.corrRange(XABOVE(II),2);
        XC{XABOVE(II),4}=false;
        AddMessage(handles.MessageList,['XCOR:',XC{XABOVE(II),1},' new value set to max: ',num2str(handles.ARC.static.X.corrRange(XABOVE(II),2))],50);
    end
end
if(~isempty(XBELOW))
    for II=1:length(XBELOW)
        XC{XBELOW(II),8}='Too low';
        XC{XBELOW(II),7}=handles.ARC.static.X.corrRange(XBELOW(II),1);
        XC{XBELOW(II),4}=false;
        AddMessage(handles.MessageList,['XCOR:',XC{XBELOW(II),1},' new value set to min: ',num2str(handles.ARC.static.X.corrRange(XBELOW(II),1))],50);
    end
end
if(~isempty(YABOVE))
    for II=1:length(YABOVE)
        YC{YABOVE(II),8}='Too high';
        YC{YABOVE(II),7}=handles.ARC.static.Y.corrRange(YABOVE(II),2);
        YC{YABOVE(II),4}=false;
        AddMessage(handles.MessageList,['YCOR:',YC{YABOVE(II),1},' new value set to max: ',num2str(handles.ARC.static.Y.corrRange(YABOVE(II),2))],50);
    end
end
if(~isempty(YBELOW))
    for II=1:length(YBELOW)
        YC{YBELOW(II),8}='Too low';
        YC{YBELOW(II),7}=handles.ARC.static.Y.corrRange(YBELOW(II),1);
        YC{YBELOW(II),4}=false;
        AddMessage(handles.MessageList,['YCOR:',YC{YBELOW(II),1},' new value set to min: ',num2str(handles.ARC.static.Y.corrRange(YBELOW(II),1))],50);
    end
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
update_plot(handles,handles.axes1,handles.axes2);


% --- Executes on button press in SetSelectedTo0.
function SetSelectedTo0_Callback(hObject, eventdata, handles)
update_plot(handles,handles.axes1,handles.axes2);
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
ChangeX=find(cell2mat(XC(:,4))); ChangeY=find(cell2mat(YC(:,4)));
AddMessage(handles.MessageList,'',50);
if(isempty(ChangeX) && isempty(ChangeY))
    AddMessage(handles.MessageList,[datestr(now),' No corrector was selected.'],50);
    return
else
    AddMessage(handles.MessageList,[datestr(now),' Setting selected correctors to 0'],50);
end
if(~isempty(ChangeX))
    for II=1:length(ChangeX)
        XC{ChangeX(II),7}=0;
    end
end
if(~isempty(ChangeY))
    for II=1:length(ChangeY)
        YC{ChangeY(II),7}=0;
    end
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
update_plot(handles,handles.axes1,handles.axes2);


% --- Executes on button press in BPMnames.
function BPMnames_Callback(hObject, eventdata, handles)
% hObject    handle to BPMnames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BPMnames


% --- Executes on selection change in XC_SelFrom.
function XC_SelFrom_Callback(hObject, eventdata, handles)
% hObject    handle to XC_SelFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XC_SelFrom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XC_SelFrom


% --- Executes during object creation, after setting all properties.
function XC_SelFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XC_SelFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in XC_SelTo.
function XC_SelTo_Callback(hObject, eventdata, handles)
% hObject    handle to XC_SelTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XC_SelTo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XC_SelTo


% --- Executes during object creation, after setting all properties.
function XC_SelTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XC_SelTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data');
START=get(handles.XC_SelFrom,'value'); END=get(handles.XC_SelTo,'value');
LINE=cell2mat(XC(:,3)); VECT=(1:length(LINE)).';
S=get(handles.checkbox4,'value');
H=get(handles.checkbox5,'value');
IDchange= find((VECT>=START) & (VECT<=END) & ((LINE=='B') | (S & LINE=='S') | (H & LINE=='H')));
XC(IDchange,4) = num2cell(true(size(XC(IDchange,4))));
set(handles.XC,'data',XC);

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data');
START=get(handles.XC_SelFrom,'value'); END=get(handles.XC_SelTo,'value');
LINE=cell2mat(XC(:,3)); VECT=(1:length(LINE)).';
S=get(handles.checkbox4,'value');
H=get(handles.checkbox5,'value');
IDchange= find((VECT>=START) & (VECT<=END) & ((LINE=='B') | (S & LINE=='S') | (H & LINE=='H')));
XC(IDchange,4) = num2cell(false(size(XC(IDchange,4))));
set(handles.XC,'data',XC);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on selection change in YC_SelFrom.
function YC_SelFrom_Callback(hObject, eventdata, handles)
% hObject    handle to YC_SelFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YC_SelFrom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YC_SelFrom


% --- Executes during object creation, after setting all properties.
function YC_SelFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YC_SelFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YC_SelTo.
function YC_SelTo_Callback(hObject, eventdata, handles)
% hObject    handle to YC_SelTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YC_SelTo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YC_SelTo


% --- Executes during object creation, after setting all properties.
function YC_SelTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YC_SelTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on selection change in C_SelFrom.
function C_SelFrom_Callback(hObject, eventdata, handles)
% hObject    handle to C_SelFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns C_SelFrom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from C_SelFrom


% --- Executes during object creation, after setting all properties.
function C_SelFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_SelFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in C_SelTo.
function C_SelTo_Callback(hObject, eventdata, handles)
% hObject    handle to C_SelTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns C_SelTo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from C_SelTo


% --- Executes during object creation, after setting all properties.
function C_SelTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_SelTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
s=get(handles.C_SelFrom,'value'); e=get(handles.C_SelTo,'value');
corrSel=handles.ARC.static.corrList_e(s:e);
SOFT=get(handles.checkbox33,'value'); HARD=get(handles.checkbox34,'value');
XCOR=corrSel(find(cellfun(@(x) x(1)=='X',corrSel)));
YCOR=corrSel(find(cellfun(@(x) x(1)=='Y',corrSel)));
[~,UseX,~]=intersect(handles.ARC.static.X.corrList_e,XCOR,'stable');
[~,UseY,~]=intersect(handles.ARC.static.Y.corrList_e,YCOR,'stable');

if(SOFT && HARD)
    %use all UseX
elseif(SOFT)
  UseX(cell2mat(XC(UseX,3))=='H')=[];
  UseY(cell2mat(XC(UseY,3))=='H')=[];
elseif(HARD)
  UseX(cell2mat(XC(UseX,3))=='S')=[];
  UseY(cell2mat(XC(UseY,3))=='S')=[];
end
    
if(~isempty(UseX))
   if(get(handles.checkbox8,'value'))
       XC(UseX,4)=num2cell(true(size(XC(UseX,4))));
   end
end
if(~isempty(UseY))
   if(get(handles.checkbox9,'value'))
       YC(UseY,4)=num2cell(true(size(YC(UseY,4))));
   end
end
set(handles.XC,'data',XC); set(handles.YC,'data',YC);


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
s=get(handles.C_SelFrom,'value'); e=get(handles.C_SelTo,'value');
corrSel=handles.ARC.static.corrList_e(s:e);
XCOR=corrSel(find(cellfun(@(x) x(1)=='X',corrSel)));
YCOR=corrSel(find(cellfun(@(x) x(1)=='Y',corrSel)));
[~,UseX,~]=intersect(handles.ARC.static.X.corrList_e,XCOR,'stable');
[~,UseY,~]=intersect(handles.ARC.static.Y.corrList_e,YCOR,'stable');
if(~isempty(UseX))
   if(get(handles.checkbox8,'value'))
       XC(UseX,4)=num2cell(false(size(XC(UseX,4))));
   end
end
if(~isempty(UseY))
   if(get(handles.checkbox9,'value'))
       YC(UseY,4)=num2cell(false(size(YC(UseY,4))));
   end
end
set(handles.XC,'data',XC); set(handles.YC,'data',YC);


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in XDESELALL.
function XDESELALL_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); XC(:,4)=num2cell(false(size(XC(:,4)))); set(handles.XC,'data',XC);

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
YC=get(handles.YC,'data');
START=get(handles.YC_SelFrom,'value'); END=get(handles.YC_SelTo,'value');
LINE=cell2mat(YC(:,3)); VECT=(1:length(LINE)).';
S=get(handles.checkbox10,'value');
H=get(handles.checkbox11,'value');
IDchange= find((VECT>=START) & (VECT<=END) & ((LINE=='B') | (S & LINE=='S') | (H & LINE=='H')));
YC(IDchange,4) = num2cell(true(size(YC(IDchange,4))));
set(handles.YC,'data',YC);

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
YC=get(handles.YC,'data');
START=get(handles.YC_SelFrom,'value'); END=get(handles.YC_SelTo,'value');
LINE=cell2mat(YC(:,3)); VECT=(1:length(LINE)).';
S=get(handles.checkbox10,'value');
H=get(handles.checkbox11,'value');
IDchange= find((VECT>=START) & (VECT<=END) & ((LINE=='B') | (S & LINE=='S') | (H & LINE=='H')));
YC(IDchange,4) = num2cell(false(size(YC(IDchange,4))));
set(handles.YC,'data',YC);

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in XSEL1.
function XSEL1_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
if(~isempty(SEL))
    XC=get(handles.XC,'data');
    XC(SEL,4)=num2cell(true(size(XC(SEL,4))));
    set(handles.XC,'data',XC);
end

% --- Executes on button press in XSEL0.
function XSEL0_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
if(~isempty(SEL))
    XC=get(handles.XC,'data');
    XC(SEL,4)=num2cell(false(size(XC(SEL,4))));
    set(handles.XC,'data',XC);
end

% --- Executes on button press in YDESELALL.
function YDESELALL_Callback(hObject, eventdata, handles)
YC=get(handles.YC,'data'); YC(:,4)=num2cell(false(size(YC(:,4)))); set(handles.YC,'data',YC);

% --- Executes on button press in YSEL1.
function YSEL1_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
if(~isempty(SEL))
    YC=get(handles.YC,'data');
    YC(SEL,4)=num2cell(true(size(YC(SEL,4))));
    set(handles.YC,'data',YC);
end

% --- Executes on button press in YSEL0.
function YSEL0_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
if(~isempty(SEL))
    YC=get(handles.YC,'data');
    YC(SEL,4)=num2cell(false(size(YC(SEL,4))));
    set(handles.YC,'data',YC);
end

% --- Executes on button press in DESELALLCORRECTORS.
function DESELALLCORRECTORS_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); XC(:,4)=num2cell(false(size(XC(:,4)))); set(handles.XC,'data',XC);
YC=get(handles.YC,'data'); YC(:,4)=num2cell(false(size(YC(:,4)))); set(handles.YC,'data',YC);


% --- Executes when selected cell(s) is changed in XC.
function XC_CellSelectionCallback(hObject, eventdata, handles)
try
    SelectedLines=unique(eventdata.Indices(:,1));
    set(handles.XSEL1,'userdata',SelectedLines)
    set(handles.XSEL0,'userdata',SelectedLines)
catch
    set(handles.XSEL1,'userdata',[])
    set(handles.XSEL0,'userdata',[])
end


% --- Executes when selected cell(s) is changed in YC.
function YC_CellSelectionCallback(hObject, eventdata, handles)
try
    SelectedLines=unique(eventdata.Indices(:,1));
    set(handles.YSEL1,'userdata',SelectedLines)
    set(handles.YSEL0,'userdata',SelectedLines)
catch
    set(handles.YSEL1,'userdata',[])
    set(handles.YSEL0,'userdata',[])
end


% --- Executes during object creation, after setting all properties.
function pushbutton13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in SBPM.
function SBPM_Callback(hObject, eventdata, handles)
% hObject    handle to SBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SBPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SBPM


% --- Executes during object creation, after setting all properties.
function SBPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EBPM.
function EBPM_Callback(hObject, eventdata, handles)
% hObject    handle to EBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EBPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EBPM


% --- Executes during object creation, after setting all properties.
function EBPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data'); HB=get(handles.HB,'data');
START=get(handles.SBPM,'value'); END=get(handles.EBPM,'value');
X=get(handles.checkbox16,'value');
Y=get(handles.checkbox17,'value');
S=get(handles.checkbox18,'value');
H=get(handles.checkbox19,'value');
SelBPM=handles.ARC.static.bpmList_e(START:END);
[~,InS,~]=intersect(handles.ARC.staticS.bpmList_e,SelBPM);
[~,InH,~]=intersect(handles.ARC.staticH.bpmList_e,SelBPM);
if(X)
    if(S)
        SB(InS,3)=num2cell(true(size(SB(InS,3))));
    end
    if(H)
        HB(InH,3)=num2cell(true(size(HB(InH,3))));
    end
end
if(Y)
    if(S)
        SB(InS,4)=num2cell(true(size(SB(InS,4))));
    end
    if(H)
        HB(InH,4)=num2cell(true(size(HB(InH,4))));
    end
end
set(handles.SB,'data',SB);set(handles.HB,'data',HB);


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data'); HB=get(handles.HB,'data');
START=get(handles.SBPM,'value'); END=get(handles.EBPM,'value');
X=get(handles.checkbox16,'value');
Y=get(handles.checkbox17,'value');
S=get(handles.checkbox18,'value');
H=get(handles.checkbox19,'value');
SelBPM=handles.ARC.static.bpmList_e(START:END);
[~,InS,~]=intersect(handles.ARC.staticS.bpmList_e,SelBPM);
[~,InH,~]=intersect(handles.ARC.staticH.bpmList_e,SelBPM);
if(X)
    if(S)
        SB(InS,3)=num2cell(false(size(SB(InS,3))));
    end
    if(H)
        HB(InH,3)=num2cell(false(size(HB(InH,3))));
    end
end
if(Y)
    if(S)
        SB(InS,4)=num2cell(false(size(SB(InS,4))));
    end
    if(H)
        HB(InH,4)=num2cell(false(size(HB(InH,4))));
    end
end
set(handles.SB,'data',SB);set(handles.HB,'data',HB);


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
X=get(handles.checkbox16,'value');
Y=get(handles.checkbox17,'value');
S=get(handles.checkbox18,'value');
H=get(handles.checkbox19,'value');
SB=get(handles.SB,'data');
HB=get(handles.HB,'data');
if(X)
    if(S)
        SB(:,3)=num2cell(false(size(SB(:,3))));
    end
    if(H)
        HB(:,3)=num2cell(false(size(HB(:,3))));
    end
end
if(Y)
    if(S)
        SB(:,4)=num2cell(false(size(SB(:,4))));
    end
    if(H)
        HB(:,4)=num2cell(false(size(HB(:,4))));
    end
end
set(handles.SB,'data',SB);
set(handles.HB,'data',HB);



% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on selection change in SBPMH.
function SBPMH_Callback(hObject, eventdata, handles)
% hObject    handle to SBPMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SBPMH contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SBPMH


% --- Executes during object creation, after setting all properties.
function SBPMH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SBPMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EBPMH.
function EBPMH_Callback(hObject, eventdata, handles)
% hObject    handle to EBPMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EBPMH contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EBPMH


% --- Executes during object creation, after setting all properties.
function EBPMH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EBPMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
HB=get(handles.HB,'data');
START=get(handles.SBPMH,'value'); END=get(handles.EBPMH,'value');
X=get(handles.checkbox20,'value'); Y=get(handles.checkbox21,'value');
LINE=cell2mat(HB(:,3)); 
VECT=(1:length(LINE)).';
IDchange= find((VECT>=START) & (VECT<=END));
if(X)
    HB(IDchange,3)=num2cell(true(size(HB(IDchange,3))));
end
if(Y)
    HB(IDchange,4)=num2cell(true(size(HB(IDchange,4))));
end
set(handles.HB,'data',HB);

% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
HB=get(handles.HB,'data');
START=get(handles.SBPMH,'value'); END=get(handles.EBPMH,'value');
X=get(handles.checkbox20,'value'); Y=get(handles.checkbox21,'value');
LINE=cell2mat(HB(:,3)); 
VECT=(1:length(LINE)).';
IDchange= find((VECT>=START) & (VECT<=END));
if(X)
    HB(IDchange,3)=num2cell(true(size(HB(IDchange,3))));
end
if(Y)
    HB(IDchange,4)=num2cell(true(size(HB(IDchange,4))));
end
set(handles.HB,'data',HB);


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21


% --- Executes on selection change in SBPMS.
function SBPMS_Callback(hObject, eventdata, handles)
% hObject    handle to SBPMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SBPMS contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SBPMS


% --- Executes during object creation, after setting all properties.
function SBPMS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SBPMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EBPMS.
function EBPMS_Callback(hObject, eventdata, handles)
% hObject    handle to EBPMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EBPMS contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EBPMS


% --- Executes during object creation, after setting all properties.
function EBPMS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EBPMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data');
START=get(handles.SBPMS,'value'); END=get(handles.EBPMS,'value');
X=get(handles.checkbox24,'value'); Y=get(handles.checkbox25,'value');
LINE=cell2mat(SB(:,3)); 
VECT=(1:length(LINE)).';
IDchange= find((VECT>=START) & (VECT<=END));
if(X)
    SB(IDchange,3)=num2cell(true(size(SB(IDchange,3))));
end
if(Y)
    SB(IDchange,4)=num2cell(true(size(SB(IDchange,4))));
end
set(handles.SB,'data',SB);


% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data');
START=get(handles.SBPMS,'value'); END=get(handles.EBPMS,'value');
X=get(handles.checkbox24,'value'); Y=get(handles.checkbox25,'value');
LINE=cell2mat(SB(:,3)); 
VECT=(1:length(LINE)).';
IDchange= find((VECT>=START) & (VECT<=END));
if(X)
    SB(IDchange,3)=num2cell(false(size(SB(IDchange,3))));
end
if(Y)
    SB(IDchange,4)=num2cell(false(size(SB(IDchange,4))));
end
set(handles.SB,'data',SB);


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25


% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
X=get(handles.checkbox24,'value');
Y=get(handles.checkbox25,'value');
if(~isempty(SEL))
    SB=get(handles.SB,'data');
    if(X)
        SB(SEL,3)=num2cell(true(size(SB(SEL,3))));
    end
    if(Y)
        SB(SEL,4)=num2cell(true(size(SB(SEL,4))));
    end
    set(handles.SB,'data',SB);
end


% --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
X=get(handles.checkbox24,'value');
Y=get(handles.checkbox25,'value');
if(~isempty(SEL))
    SB=get(handles.SB,'data');
    if(X)
        SB(SEL,3)=num2cell(false(size(SB(SEL,3))));
    end
    if(Y)
        SB(SEL,4)=num2cell(false(size(SB(SEL,4))));
    end
    set(handles.SB,'data',SB);
end


% --- Executes on button press in pushbutton42.
function pushbutton42_Callback(hObject, eventdata, handles)
SEL=get(hObject,'userdata');
X=get(handles.checkbox20,'value');
Y=get(handles.checkbox21,'value');
if(~isempty(SEL))
    HB=get(handles.HB,'data');
    if(X)
        HB(SEL,3)=num2cell(true(size(HB(SEL,3))));
    end
    if(Y)
        HB(SEL,4)=num2cell(true(size(HB(SEL,4))));
    end
    set(handles.HB,'data',HB);
end


% --- Executes on button press in pushbutton43.
function pushbutton43_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in SB.
function SB_CellEditCallback(hObject, eventdata, handles)
UpdatePlot=0;
try
    if((eventdata.Indices(2)==3) || (eventdata.Indices(2)==4))
        UpdatePlot=1;
    end
catch
end
if(UpdatePlot)
    update_plot(handles,handles.axes1,handles.axes2);
end
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in HB.
function HB_CellEditCallback(hObject, eventdata, handles)
UpdatePlot=0;
try
    if((eventdata.Indices(2)==3) || (eventdata.Indices(2)==4))
        UpdatePlot=1;
    end
catch
end
if(UpdatePlot)
    update_plot(handles,handles.axes1,handles.axes2);
end


% --- Executes when selected cell(s) is changed in SB.
function SB_CellSelectionCallback(hObject, eventdata, handles)
try
    SelectedLines=unique(eventdata.Indices(:,1));
    set(handles.pushbutton40,'userdata',SelectedLines)
    set(handles.pushbutton41,'userdata',SelectedLines)
catch
    set(handles.pushbutton40,'userdata',[])
    set(handles.pushbutton41,'userdata',[])
end


% --- Executes when selected cell(s) is changed in HB.
function HB_CellSelectionCallback(hObject, eventdata, handles)
try
    SelectedLines=unique(eventdata.Indices(:,1));
    set(handles.pushbutton42,'userdata',SelectedLines)
    set(handles.pushbutton43,'userdata',SelectedLines)
catch
    set(handles.pushbutton42,'userdata',[])
    set(handles.pushbutton43,'userdata',[])
end


% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, handles)
update_plot(handles,handles.axes1,handles.axes2);


% --- Executes on button press in pushbutton45.
function pushbutton45_Callback(hObject, eventdata, handles)
SVD_Parameter=str2num(get(handles.SVD_Parameter,'string'));
FromNew=get(handles.FromNew,'value'); FromConfig=get(handles.FromConfig,'value');
SB=get(handles.SB,'data'); HB=get(handles.HB,'data'); 
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
CloseAngleH=get(handles.CloseAngleH,'value');
CloseAngleS=get(handles.CloseAngleS,'value');
CloseOffsetH=get(handles.CloseOffsetH,'value');
CloseOffsetS=get(handles.CloseOffsetS,'value');
% UseCorr=[cell2mat(handles.ARC.static.X.corrList_e(XC(:,4)));cell2mat(handles.ARC.static.Y.corrList_e(YC(:,4)))];
% UseBPM_SX=cell2mat(handles.ARC.staticS.bpmList_e(SB(:,3)));
% UseBPM_SY=cell2mat(handles.ARC.staticS.bpmList_e(SB(:,4)));
% UseBPM_HX=cell2mat(handles.ARC.staticH.bpmList_e(HB(:,3)));
% UseBPM_HY=cell2mat(handles.ARC.staticH.bpmList_e(HB(:,4)));

UseCorr=[(handles.ARC.static.X.corrList_e(cell2mat(XC(:,4))));(handles.ARC.static.Y.corrList_e(cell2mat(YC(:,4))))];
UseBPM_SX=(handles.ARC.staticS.bpmList_e(cell2mat(SB(:,3))));
UseBPM_SY=(handles.ARC.staticS.bpmList_e(cell2mat(SB(:,4))));
UseBPM_HX=(handles.ARC.staticH.bpmList_e(cell2mat(HB(:,3))));
UseBPM_HY=(handles.ARC.staticH.bpmList_e(cell2mat(HB(:,4))));

Orbit_SX=cell2mat(SB(:,5));
Orbit_SY=cell2mat(SB(:,6));
Orbit_HX=cell2mat(HB(:,5));
Orbit_HY=cell2mat(HB(:,6));

Target_SX=cell2mat(SB(:,7));
Target_SY=cell2mat(SB(:,8));
Target_HX=cell2mat(HB(:,7));
Target_HY=cell2mat(HB(:,8));

Target_SX(isnan(Target_SX))=Orbit_SX(isnan(Target_SX));
Target_SY(isnan(Target_SY))=Orbit_SY(isnan(Target_SY));
Target_HX(isnan(Target_HX))=Orbit_HX(isnan(Target_HX));
Target_HY(isnan(Target_HY))=Orbit_HY(isnan(Target_HY));

Orbit_SX=Orbit_SX-Target_SX;
Orbit_SY=Orbit_SY-Target_SY;
Orbit_HX=Orbit_HX-Target_HX;
Orbit_HY=Orbit_HY-Target_HY;

if(FromNew) % must remove already induced orbit from new correctors.
    [CorrMatrix_S,CorrMatrixAngles_S]=handles.sh.CorrectorOrbitMatrix_Fast(handles.ARC.staticS,handles.ARC.D(1).MODEL_S.rMat,handles.ARC.D(1).MODEL_S.Pos,handles.ARC.D(1).MODEL_S.energy);
    [CorrMatrix_H,CorrMatrixAngles_H]=handles.sh.CorrectorOrbitMatrix_Fast(handles.ARC.staticH,handles.ARC.D(1).MODEL_H.rMat,handles.ARC.D(1).MODEL_H.Pos,handles.ARC.D(1).MODEL_H.energy);
    Difference_CorrectorsX=cell2mat(XC(:,7))-cell2mat(XC(:,5));
    Difference_CorrectorsY=cell2mat(YC(:,7))-cell2mat(YC(:,5));
    
    [~,Where_Xlist,Where_Soft_fromX]=intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticS.corrList_e,'stable');
    [~,Where_Ylist,Where_Soft_fromY]=intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticS.corrList_e,'stable');
    
    Difference_CorrectorsS=zeros(size(handles.ARC.staticS.corrList_e));
    Difference_CorrectorsS(Where_Soft_fromX)=Difference_CorrectorsX(Where_Xlist);
    Difference_CorrectorsS(Where_Soft_fromY)=Difference_CorrectorsY(Where_Ylist);
    
    [~,Where_Xlist,Where_Hard_fromX]=intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticH.corrList_e,'stable');
    [~,Where_Ylist,Where_Hard_fromY]=intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticH.corrList_e,'stable');
    
    Difference_CorrectorsH=zeros(size(handles.ARC.staticH.corrList_e));
    Difference_CorrectorsH(Where_Hard_fromX)=Difference_CorrectorsX(Where_Xlist);
    Difference_CorrectorsH(Where_Hard_fromY)=Difference_CorrectorsY(Where_Ylist);
    
    InducedOrbitH=CorrMatrix_H*Difference_CorrectorsH;
    InducedOrbitS=CorrMatrix_S*Difference_CorrectorsS;
    
    InducedAngleH=CorrMatrixAngles_H*Difference_CorrectorsH;
    InducedAngleS=CorrMatrixAngles_S*Difference_CorrectorsS;
    
    InducedOrbitH_X=InducedOrbitH(1:2:end);
    InducedOrbitH_Y=InducedOrbitH(2:2:end);
    
    InducedOrbitS_X=InducedOrbitS(1:2:end);
    InducedOrbitS_Y=InducedOrbitS(2:2:end);
    
    InducedAngleH_X=InducedAngleH(1:2:end);
    InducedAngleH_Y=InducedAngleH(2:2:end);
    InducedAngleS_X=InducedAngleS(1:2:end);
    InducedAngleS_Y=InducedAngleS(2:2:end);
    
    Orbit_SX=Orbit_SX-InducedOrbitS_X*1000;
    Orbit_SY=Orbit_SY-InducedOrbitS_Y*1000;
    Orbit_HX=Orbit_HX-InducedOrbitH_X*1000;
    Orbit_HY=Orbit_HY-InducedOrbitH_Y*1000;
    
    problem.XCorrStart=cell2mat(XC(:,7));
    problem.YCorrStart=cell2mat(YC(:,7));
    
    problem.InducedAngleH_X=InducedAngleH_X;
    problem.InducedAngleS_X=InducedAngleS_X;
    problem.InducedAngleH_Y=InducedAngleH_Y;
    problem.InducedAngleS_Y=InducedAngleS_Y;
else
    problem.XCorrStart=cell2mat(XC(:,5));
    problem.YCorrStart=cell2mat(YC(:,5));
    problem.InducedAngleH_X=zeros(size(Orbit_HX));
    problem.InducedAngleS_X=zeros(size(Orbit_SX));
    problem.InducedAngleH_Y=zeros(size(Orbit_HY));
    problem.InducedAngleS_Y=zeros(size(Orbit_SY));
end

problem.SVD_Parameter=SVD_Parameter;
problem.CloseAngleH=CloseAngleH;
problem.CloseAngleS=CloseAngleS;
problem.CloseOffsetH=CloseOffsetH;
problem.CloseOffsetS=CloseOffsetS;
problem.Orbit_SX=Orbit_SX;
problem.Orbit_SY=Orbit_SY;
problem.Orbit_HX=Orbit_HX;
problem.Orbit_HY=Orbit_HY;
problem.UseCorr=UseCorr;
problem.UseBPM_SX=UseBPM_SX;
problem.UseBPM_SY=UseBPM_SY;
problem.UseBPM_HX=UseBPM_HX;
problem.UseBPM_HY=UseBPM_HY;
problem.WHC=str2num(get(handles.WH,'string'));
problem.WSC=str2num(get(handles.WS,'string'));
%save(['AllSteerTry',regexprep(datestr(now),' ','')]);
Sol=handles.ARC.Steer(problem,handles.sh);

XC(:,7)=num2cell(Sol.NewCorrX);
YC(:,7)=num2cell(Sol.NewCorrY);

set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
%update_table(handles);
update_plot(handles,handles.axes1,handles.axes2);






% --- Executes on button press in pushbutton46.
function pushbutton46_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
OrigXC=cell2mat(XC(:,5));
NewXC=cell2mat(XC(:,7));
OrigYC=cell2mat(YC(:,5));
NewYC=cell2mat(YC(:,7));

CorrNamesX=strcat(handles.ARC.static.X.corrList_e,':BCTRL');
CorrNamesY=strcat(handles.ARC.static.Y.corrList_e,':BCTRL');

CorrXChanged=(abs(NewXC-OrigXC)>10^-9);
CorrYChanged=(abs(NewYC-OrigYC)>10^-9);

ApplyAllParameter=str2num(get(handles.ApplyAllParameter,'string'));

ApplyX=OrigXC + (NewXC - OrigXC)*ApplyAllParameter;
ApplyY=OrigYC + (NewYC - OrigYC)*ApplyAllParameter;

CorrNamesX=CorrNamesX(CorrXChanged); CorrNamesY=CorrNamesY(CorrYChanged);
ApplyX=ApplyX(CorrXChanged); ApplyY=ApplyY(CorrYChanged);
CN=[CorrNamesX;CorrNamesY]; A=[ApplyX;ApplyY];
Restore.PV=CN;
Restore.Val=lcaGetSmart(CN);
set(handles.pushbutton64,'userdata',Restore);
lcaPutSmart(CN,A);




% --- Executes on button press in pushbutton47.
function pushbutton47_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data');
OrigXC=cell2mat(XC(:,5));
NewXC=cell2mat(XC(:,7));
CorrNamesX=strcat(handles.static.X.corrList_e,':BCTRL');
CorrXChanged=(abs(NewXC-OrigXC)>10^-9);
ApplyXParameter=str2num(get(handles.ApplyXParameter,'string'));
ApplyX=OrigXC + (NewXC - OrigXC)*ApplyXParameter;
CorrNamesX=CorrNamesX(CorrXChanged);
ApplyX=ApplyX(CorrXChanged);
Restore.PV=CorrNamesX;
Restore.Val=lcaGetSmart(CorrNamesX);
set(handles.pushbutton64,'userdata',Restore);
lcaPutSmart(CorrNamesX,ApplyX);



% --- Executes on button press in pushbutton48.
function pushbutton48_Callback(hObject, eventdata, handles)
YC=get(handles.YC,'data');
OrigYC=cell2mat(YC(:,5));
NewYC=cell2mat(YC(:,7));
CorrNamesY=strcat(handles.static.Y.corrList_e,':BCTRL');
CorrYChanged=(abs(NewYC-OrigYC)>10^-9);
ApplyYParameter=str2num(get(handles.ApplyYParameter,'string'));
ApplyY=OrigYC + (NewYC - OrigYC)*ApplyYParameter;
CorrNamesY=CorrNamesY(CorrYChanged);
ApplyY=ApplyY(CorrYChanged);
Restore.PV=CorrNamesY;
Restore.Val=lcaGetSmart(CorrNamesY);
set(handles.pushbutton64,'userdata',Restore);
lcaPutSmart(CorrNamesY,ApplyY);


% --- Executes on button press in CloseAngleH.
function CloseAngleH_Callback(hObject, eventdata, handles)
% hObject    handle to CloseAngleH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CloseAngleH



function ApplyAllParameter_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyAllParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ApplyAllParameter as text
%        str2double(get(hObject,'String')) returns contents of ApplyAllParameter as a double


% --- Executes during object creation, after setting all properties.
function ApplyAllParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplyAllParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SVD_Parameter_Callback(hObject, eventdata, handles)
% hObject    handle to SVD_Parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SVD_Parameter as text
%        str2double(get(hObject,'String')) returns contents of SVD_Parameter as a double


% --- Executes during object creation, after setting all properties.
function SVD_Parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SVD_Parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ApplyXParameter_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyXParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ApplyXParameter as text
%        str2double(get(hObject,'String')) returns contents of ApplyXParameter as a double


% --- Executes during object creation, after setting all properties.
function ApplyXParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplyXParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ApplyYParameter_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyYParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ApplyYParameter as text
%        str2double(get(hObject,'String')) returns contents of ApplyYParameter as a double


% --- Executes during object creation, after setting all properties.
function ApplyYParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplyYParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FromNew.
function FromNew_Callback(hObject, eventdata, handles)
% hObject    handle to FromNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FromNew


% --- Executes on button press in FromConfig.
function FromConfig_Callback(hObject, eventdata, handles)
% hObject    handle to FromConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FromConfig


% --- Executes on button press in CloseAngleS.
function CloseAngleS_Callback(hObject, eventdata, handles)
% hObject    handle to CloseAngleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CloseAngleS



function SampleN_Callback(hObject, eventdata, handles)
% hObject    handle to SampleN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampleN as text
%        str2double(get(hObject,'String')) returns contents of SampleN as a double


% --- Executes during object creation, after setting all properties.
function SampleN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TSS.
function TSS_Callback(hObject, eventdata, handles)
ID=get(handles.TD_SEL,'value');
handles.ARC.takeSingleShotCAGET(ID,'Soft');
handles.ARC.evaluate_avg_trajectory(1,-inf,4,ID);
update_recConfs(handles);
update_table(handles);


% --- Executes on button press in TSH.
function TSH_Callback(hObject, eventdata, handles)
ID=get(handles.TD_SEL,'value');
handles.ARC.takeSingleShotCAGET(ID,'Hard');
handles.ARC.evaluate_avg_trajectory(1,-inf,4,ID);
update_recConfs(handles);
update_table(handles);


% --- Executes on button press in pushbutton54.
function pushbutton54_Callback(hObject, eventdata, handles)
ID=get(handles.TD_SEL,'value');
handles.ARC.takeModel(ID);


% --- Executes on button press in CloseOffsetH.
function CloseOffsetH_Callback(hObject, eventdata, handles)
% hObject    handle to CloseOffsetH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CloseOffsetH


% --- Executes on button press in CloseOffsetS.
function CloseOffsetS_Callback(hObject, eventdata, handles)
% hObject    handle to CloseOffsetS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CloseOffsetS


% --- Executes on button press in pushbutton55.
function pushbutton55_Callback(hObject, eventdata, handles)
disp('Reading correctors from machine');
CorrVal_X=lcaGetSmart(strcat(handles.ARC.static.X.corrList_e,':BCTRL'));
CorrVal_Y=lcaGetSmart(strcat(handles.ARC.static.Y.corrList_e,':BCTRL'));
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XC(:,6)=num2cell(CorrVal_X); YC(:,6)=num2cell(CorrVal_Y);
set(handles.XC,'data',XC); set(handles.YC,'data',YC);
update_plot(handles,handles.axes1,handles.axes2);


% --- Executes on button press in xAutoZ.
function xAutoZ_Callback(hObject, eventdata, handles)
% hObject    handle to xAutoZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in yAutoZ.
function yAutoZ_Callback(hObject, eventdata, handles)
% hObject    handle to yAutoZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function zzm_Callback(hObject, eventdata, handles)
% hObject    handle to zzm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zzm as text
%        str2double(get(hObject,'String')) returns contents of zzm as a double


% --- Executes during object creation, after setting all properties.
function zzm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zzm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zzM_Callback(hObject, eventdata, handles)
% hObject    handle to zzM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zzM as text
%        str2double(get(hObject,'String')) returns contents of zzM as a double


% --- Executes during object creation, after setting all properties.
function zzM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zzM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zm_Callback(hObject, eventdata, handles)
% hObject    handle to zm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zm as text
%        str2double(get(hObject,'String')) returns contents of zm as a double


% --- Executes during object creation, after setting all properties.
function zm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zM_Callback(hObject, eventdata, handles)
% hObject    handle to zM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zM as text
%        str2double(get(hObject,'String')) returns contents of zM as a double


% --- Executes during object creation, after setting all properties.
function zM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xm_Callback(hObject, eventdata, handles)
% hObject    handle to xm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xm as text
%        str2double(get(hObject,'String')) returns contents of xm as a double


% --- Executes during object creation, after setting all properties.
function xm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xM_Callback(hObject, eventdata, handles)
% hObject    handle to xM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xM as text
%        str2double(get(hObject,'String')) returns contents of xM as a double


% --- Executes during object creation, after setting all properties.
function xM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xAutoX.
function xAutoX_Callback(hObject, eventdata, handles)
% hObject    handle to xAutoX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ym_Callback(hObject, eventdata, handles)
% hObject    handle to ym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ym as text
%        str2double(get(hObject,'String')) returns contents of ym as a double


% --- Executes during object creation, after setting all properties.
function ym_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yM_Callback(hObject, eventdata, handles)
% hObject    handle to yM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yM as text
%        str2double(get(hObject,'String')) returns contents of yM as a double


% --- Executes during object creation, after setting all properties.
function yM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in yAutoY.
function yAutoY_Callback(hObject, eventdata, handles)
% hObject    handle to yAutoY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ExcludeNaN.
function ExcludeNaN_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeNaN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExcludeNaN


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data'); HB=get(handles.HB,'data');
SX=find(cell2mat(SB(:,3)));
SY=find(cell2mat(SB(:,4)));
HX=find(cell2mat(HB(:,3)));
HY=find(cell2mat(HB(:,4)));

SB(SX,7)=SB(SX,5);
SB(SY,8)=SB(SY,6);
HB(HX,7)=HB(HX,5);
HB(HY,8)=HB(HY,6);

set(handles.SB,'data',SB); set(handles.HB,'data',HB);



function WH_Callback(hObject, eventdata, handles)
% hObject    handle to WH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WH as text
%        str2double(get(hObject,'String')) returns contents of WH as a double


% --- Executes during object creation, after setting all properties.
function WH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WS_Callback(hObject, eventdata, handles)
% hObject    handle to WS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WS as text
%        str2double(get(hObject,'String')) returns contents of WS as a double


% --- Executes during object creation, after setting all properties.
function WS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SteerAsFeedback.
function SteerAsFeedback_Callback(hObject, eventdata, handles)
FeedbackGain=str2num(get(handles.SFeedbackGain,'string'));
set(handles.state,'string','Running');drawnow
StateString=get(handles.state,'stiring');
SVD_Parameter=str2num(get(handles.SVD_Parameter,'string'));
SB=get(handles.SB,'data'); HB=get(handles.HB,'data'); 
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
CloseAngleH=get(handles.CloseAngleH,'value');
CloseAngleS=get(handles.CloseAngleS,'value');
CloseOffsetH=get(handles.CloseOffsetH,'value');
CloseOffsetS=get(handles.CloseOffsetS,'value');

% UseCorr=[cell2mat(handles.ARC.static.X.corrList_e(XC(:,4)));cell2mat(handles.ARC.static.Y.corrList_e(YC(:,4)))];
% UseBPM_SX=cell2mat(handles.ARC.staticS.bpmList_e(SB(:,3)));
% UseBPM_SY=cell2mat(handles.ARC.staticS.bpmList_e(SB(:,4)));
% UseBPM_HX=cell2mat(handles.ARC.staticH.bpmList_e(HB(:,3)));
% UseBPM_HY=cell2mat(handles.ARC.staticH.bpmList_e(HB(:,4)));

UseCorr=[(handles.ARC.static.X.corrList_e(cell2mat(XC(:,4))));(handles.ARC.static.Y.corrList_e(cell2mat(YC(:,4))))];
UseBPM_SX=(handles.ARC.staticS.bpmList_e(cell2mat(SB(:,3))));
UseBPM_SY=(handles.ARC.staticS.bpmList_e(cell2mat(SB(:,4))));
UseBPM_HX=(handles.ARC.staticH.bpmList_e(cell2mat(HB(:,3))));
UseBPM_HY=(handles.ARC.staticH.bpmList_e(cell2mat(HB(:,4))));

Samples=round(str2num(get(handles.SampleN,'string')));
ID=get(handles.TD_SEL,'value');
takeModel=1;

while(strcmp(StateString,'Running'))
    disp('taking data')
    handles.ARC.takeData(ID,Samples,takeModel);
    EXCN=get(handles.ExcludeNaN,'value');
    handles.ARC.evaluate_avg_trajectory(EXCN,-inf,4,ID);
    
    [~,WASX,WSX]=intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticS.corrList_e);
    [~,WASY,WSY]=intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticS.corrList_e);
    [~,WAHX,WHX]=intersect(handles.ARC.static.X.corrList_e,handles.ARC.staticH.corrList_e);
    [~,WAHY,WHY]=intersect(handles.ARC.static.Y.corrList_e,handles.ARC.staticH.corrList_e);
    
    CX=NaN*ones(size(XC(:,5)));
    CY=NaN*ones(size(YC(:,5)));
    
    if(isfield(handles.ARC.D(ID),'CorrectorStrengths_S'))
        CX(WASX)=handles.ARC.D(ID).CorrectorStrengths_S(WSX);
        CY(WASY)=handles.ARC.D(ID).CorrectorStrengths_S(WSY);
    end
    if(isfield(handles.ARC.D(ID),'CorrectorStrengths_H'))
        CX(WAHX)=handles.ARC.D(ID).CorrectorStrengths_H(WHX);
        CY(WAHY)=handles.ARC.D(ID).CorrectorStrengths_H(WHY);
    end
    
    XC(:,5)=num2cell(CX);
    YC(:,5)=num2cell(CY);
    XC(:,7)=num2cell(CX);
    YC(:,7)=num2cell(CY);
    
    %Leggi le orbite...
    
    Orbit_SX=handles.ARC.D(ID).MS_X;
    Orbit_SY=handles.ARC.D(ID).MS_Y;
    Orbit_HX=handles.ARC.D(ID).MH_X;
    Orbit_HY=handles.ARC.D(ID).MH_Y;

    Target_SX=cell2mat(SB(:,7));
    Target_SY=cell2mat(SB(:,8));
    Target_HX=cell2mat(HB(:,7));
    Target_HY=cell2mat(HB(:,8));

    Target_SX(isnan(Target_SX))=Orbit_SX(isnan(Target_SX));
    Target_SY(isnan(Target_SY))=Orbit_SY(isnan(Target_SY));
    Target_HX(isnan(Target_HX))=Orbit_HX(isnan(Target_HX));
    Target_HY(isnan(Target_HY))=Orbit_HY(isnan(Target_HY));

    Orbit_SX=Orbit_SX-Target_SX;
    Orbit_SY=Orbit_SY-Target_SY;
    Orbit_HX=Orbit_HX-Target_HX;
    Orbit_HY=Orbit_HY-Target_HY;
    
    problem.XCorrStart=cell2mat(XC(:,5));
    problem.YCorrStart=cell2mat(YC(:,5));
    problem.InducedAngleH_X=zeros(size(Orbit_HX));
    problem.InducedAngleS_X=zeros(size(Orbit_SX));
    problem.InducedAngleH_Y=zeros(size(Orbit_HY));
    problem.InducedAngleS_Y=zeros(size(Orbit_SY));
    
    problem.SVD_Parameter=SVD_Parameter;
    problem.CloseAngleH=CloseAngleH;
    problem.CloseAngleS=CloseAngleS;
    problem.CloseOffsetH=CloseOffsetH;
    problem.CloseOffsetS=CloseOffsetS;
    problem.Orbit_SX=Orbit_SX;
    problem.Orbit_SY=Orbit_SY;
    problem.Orbit_HX=Orbit_HX;
    problem.Orbit_HY=Orbit_HY;
    problem.UseCorr=UseCorr;
    problem.UseBPM_SX=UseBPM_SX;
    problem.UseBPM_SY=UseBPM_SY;
    problem.UseBPM_HX=UseBPM_HX;
    problem.UseBPM_HY=UseBPM_HY;
    problem.WHC=1;
    problem.WSC=1;

    Sol=handles.ARC.Steer(problem,handles.sh);
    %check that no corrector in solution is NaN, otherwise do not apply
    %anything
    
    if(any(isnan(Sol.NewCorrX)) || any(isnan(Sol.NewCorrY)))
        StateString=get(handles.state,'stiring');
        disp('Skipping this iteration because solution has NaN');
        continue
    else
        disp('Apply Solution:');
        
        XC(:,7)=num2cell(Sol.NewCorrX);
        YC(:,7)=num2cell(Sol.NewCorrY);
        
        set(handles.XC,'data',XC);
        set(handles.YC,'data',YC);
        
        %     % APPLY STEERING
        OrigXC=cell2mat(XC(:,5));
        NewXC=cell2mat(XC(:,7));
        OrigYC=cell2mat(YC(:,5));
        NewYC=cell2mat(YC(:,7));
        %
        CorrNamesX=strcat(handles.ARC.static.X.corrList_e,':BCTRL');
        CorrNamesY=strcat(handles.ARC.static.Y.corrList_e,':BCTRL');
        %
        CorrXChanged=(abs(NewXC-OrigXC)>10^-9);
        CorrYChanged=(abs(NewYC-OrigYC)>10^-9);
        %
        ApplyX=OrigXC + (NewXC - OrigXC)*FeedbackGain;
        ApplyY=OrigYC + (NewYC - OrigYC)*FeedbackGain;
        %
        CorrNamesX=CorrNamesX(CorrXChanged); CorrNamesY=CorrNamesY(CorrYChanged);
        ApplyX=ApplyX(CorrXChanged); ApplyY=ApplyY(CorrYChanged);
        CN=[CorrNamesX;CorrNamesY]; A=[ApplyX;ApplyY];
        lcaPutSmart(CN,A);
    end
    
end




function SFeedbackGain_Callback(hObject, eventdata, handles)
% hObject    handle to SFeedbackGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SFeedbackGain as text
%        str2double(get(hObject,'String')) returns contents of SFeedbackGain as a double


% --- Executes during object creation, after setting all properties.
function SFeedbackGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SFeedbackGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton63.
function pushbutton63_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data'); HB=get(handles.HB,'data');
SX=find(cell2mat(SB(:,3)));
SY=find(cell2mat(SB(:,4)));
HX=find(cell2mat(HB(:,3)));
HY=find(cell2mat(HB(:,4)));

SB(SX,7)=num2cell(NaN*ones(size(SB(SX,7))));
SB(SY,8)=num2cell(NaN*ones(size(SB(SY,7))));
HB(HX,7)=num2cell(NaN*ones(size(HB(HX,7))));
HB(HY,8)=num2cell(NaN*ones(size(HB(HY,7))));

set(handles.SB,'data',SB); set(handles.HB,'data',HB);

% --- Executes on button press in checkbox33.
function checkbox33_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox33


% --- Executes on button press in checkbox34.
function checkbox34_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox34


% --- Executes on button press in pushbutton64.
function pushbutton64_Callback(hObject, eventdata, handles)
Restore=get(handles.pushbutton64,'userdata');
lcaPutSmart(Restore.PV,Restore.Val);


% hObject    handle to pushbutton64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in StopSteer.
function StopSteer_Callback(hObject, eventdata, handles)
set(handles.state,'string','Stopped');drawnow;
% hObject    handle to StopSteer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton66.
function pushbutton66_Callback(hObject, eventdata, handles)
SB=get(handles.SB,'data'); HB=get(handles.HB,'data'); 
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
ARC=handles.ARC;
save([handles.filepath,'/','ARC_DES_DUMP_',regexprep(datestr(now),' ','-')],'SB','HB','XC','YC','ARC');
save([handles.filepath,'/','ARC_DES_DUMP_LATEST'],'SB','HB','XC','YC','ARC');


% --- Executes on button press in pushbutton67.
function pushbutton67_Callback(hObject, eventdata, handles)
load([handles.filepath,'/','ARC_DES_DUMP_LATEST'],'SB','HB','XC','YC','ARC');
handles.ARC=ARC;
set(handles.SB,'data',SB); set(handles.HB,'data',HB); 
set(handles.XC,'data',XC); set(handles.YC,'data',YC);
guidata(hObject, handles);


% --- Executes on button press in pushbutton68.
function pushbutton68_Callback(hObject, eventdata, handles)
[FN,FP]=uigetfile([handles.filepath,'/','ARC_DES_DUMP*.mat']);
load([FP,'/',FN],'SB','HB','XC','YC','ARC');
handles.ARC=ARC;
set(handles.SB,'data',SB); set(handles.HB,'data',HB); 
set(handles.XC,'data',XC); set(handles.YC,'data',YC);
guidata(hObject, handles);
