function varargout = CVCRCI2_Scan_gui(varargin)
% CVCRCI2_SCAN_GUI MATLAB code for CVCRCI2_Scan_gui.fig
%      CVCRCI2_SCAN_GUI, by itself, creates a new CVCRCI2_SCAN_GUI or raises the existing
%      singleton*.
%
%      H = CVCRCI2_SCAN_GUI returns the handle to a new CVCRCI2_SCAN_GUI or the handle to
%      the existing singleton*.
%
%      CVCRCI2_SCAN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI2_SCAN_GUI.M with the given input arguments.
%
%      CVCRCI2_SCAN_GUI('Property','Value',...) creates a new CVCRCI2_SCAN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI2_Scan_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI2_Scan_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI2_Scan_gui

% Last Modified by GUIDE v2.5 10-Apr-2015 16:54:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI2_Scan_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI2_Scan_gui_OutputFcn, ...
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


% --- Executes just before CVCRCI2_Scan_gui is made visible.
function CVCRCI2_Scan_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI2_Scan_gui (see VARARGIN)

% Choose default command line output for CVCRCI2_Scan_gui
handles.output = hObject;
handles.ColorON=[0,1,0];
handles.ColorOff=[1,0,0];
handles.ConfigurationDirectory=pwd;
handles.ColorIdle=get(handles.Load_Scan_Configuration,'backgroundcolor');
handles.NumberOfPresets=12;
CVCRCI2_Scan_gui_configuration_file;
handles.ScanConfiguration=ScanConfiguration;
set(handles.PRESETPAGE,'string',{ScanConfiguration.NameOfThisList});
set(handles.PRESETPAGE,'value',1);
handles=SetVisibility_and_names(handles);
ActivatePreset(1,handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVCRCI2_Scan_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI2_Scan_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles=SetVisibility_and_names(handles)
PRESETSELECTION=get(handles.PRESETPAGE,'value');
for II=1:handles.NumberOfPresets
    if(II<=handles.ScanConfiguration(PRESETSELECTION).NumberOfItems)
        set(handles.(['p',num2str(II)]),'string',handles.ScanConfiguration(PRESETSELECTION).(['MenuItem',num2str(II)]).name);
        set(handles.(['p',num2str(II)]),'visible','on');
        Preset_Setup=handles.ScanConfiguration(PRESETSELECTION).(['MenuItem',num2str(II)]);
        set(handles.(['p',num2str(II)]),'userdata',Preset_Setup);
    else
       set(handles.(['p',num2str(II)]),'visible','off'); 
    end
end
handles.ExistingPresets=handles.ScanConfiguration(PRESETSELECTION).NumberOfItems;

function ActivatePreset(PresetNumber,handles)
for II=1:handles.ExistingPresets
    if(II==PresetNumber)
        set(handles.(['p',num2str(II)]),'backgroundcolor',handles.ColorON);
        PresetData=get(handles.(['p',num2str(II)]),'userdata');
        Table=cell(0,2);
        if(PresetData.Calc.ParameterNumber)
            for JJ=1:PresetData.Calc.ParameterNumber
                Table{JJ,1}=PresetData.Calc.ParameterNames{JJ};
                Table{JJ,2}=PresetData.Calc.ParameterDefault(JJ);
            end
        else
           set(handles.CalculationParameters,'data',Table);
        end
        set(handles.CalculationParameters,'data',Table);
        List={};
        if(PresetData.Additional.ParameterNumber)
            for JJ=1:PresetData.Additional.ParameterNumber
                List{JJ}=PresetData.Additional.ParameterNames{JJ};
            end
        else
            set(handles.CalculatedParameters,'string',List);
        end
        set(handles.CalculatedParameters,'string',List);
        Table=cell(1,8);
        for JJ=1:PresetData.ScanPVs.ParameterNumber
            Table{JJ,1} = PresetData.ScanPVs.ParameterNames{JJ};
            if(isfield(PresetData.ScanPVs,'StartDefault'))
                Table{JJ,2} = PresetData.ScanPVs.StartDefault(JJ);
            else
                Table{JJ,2}=[];
            end
            if(isfield(PresetData.ScanPVs,'EndDefault'))
                Table{JJ,3} = PresetData.ScanPVs.EndDefault(JJ);
            else
                Table{JJ,3}=[];
            end
            if(isfield(PresetData.ScanPVs,'StepsDefault'))
                Table{JJ,4} = PresetData.ScanPVs.StepsDefault(JJ);
            else
                Table{JJ,4}=[];
            end
            Table{JJ,5} = PresetData.ScanPVs.ParameterKnobsID(JJ);
            Table{JJ,6} = PresetData.ScanPVs.ParameterReadout{JJ};
            Table{JJ,7} = PresetData.ScanPVs.ParameterReadoutScale(JJ);
            Table{JJ,8} = PresetData.ScanPVs.ParameterToleranceOrPause(JJ);

        end
        set(handles.SCANPV,'data',Table);
        Funzione{1}=PresetData.CalcFunction;
        Funzione{2}=PresetData.PreScanFunction;
        Funzione{3}=PresetData.AfterEachSettingFunction;
        Funzione{4}=PresetData.PostScanFunction;
        set(handles.Functions,'userdata',Funzione);
        set(handles.DisplayText,'string',PresetData.DisplayText);
        if(PresetData.type==1)
            set(handles.DisplayText,'userdata',0);
        else
            set(handles.DisplayText,'userdata',1);
        end
        set(handles.Edit_Guaranteed_PV,'string',PresetData.GuaranteedPV.name);
        set(handles.GuaranteedParameterMIN,'string',PresetData.GuaranteedPV.minval);
        set(handles.GuaranteedParameterMAX,'string',PresetData.GuaranteedPV.maxval);
        set(handles.RestoreStartingPointAtEnd,'value',PresetData.ResetConditionWhenScanFinishes);
        
    else
        set(handles.(['p',num2str(II)]),'backgroundcolor',handles.ColorIdle); 
    end
end
if(get(handles.DisplayText,'userdata'))
    set(handles.MoreLines,'enable','off');
    set(handles.SCANPV,'ColumnEditable',[false,false,false,false,false,false,true,true])
else
    set(handles.MoreLines,'enable','on');
    set(handles.SCANPV,'ColumnEditable',[true,true,true,true,true,true,true,true])
end
SCANPV_CellEditCallback(0, 0, handles)

% --- Executes on button press in p1.
function p1_Callback(hObject, eventdata, handles)
ActivatePreset(1,handles);
% --- Executes on button press in p2.
function p2_Callback(hObject, eventdata, handles)
ActivatePreset(2,handles);
% --- Executes on button press in p3.
function p3_Callback(hObject, eventdata, handles)
ActivatePreset(3,handles);
% --- Executes on button press in p4.
function p4_Callback(hObject, eventdata, handles)
ActivatePreset(4,handles);

% --- Executes on button press in Load_Scan_Configuration.
function Load_Scan_Configuration_Callback(hObject, eventdata, handles)
[FileName,Path]=uigetfile([handles.ConfigurationDirectory,'/VOM_SCAN_CONF_*.mat'], 'Select Configuration to be loaded');
if(isnumeric(FileName) || isnumeric(Path))
    set(handles.Load_Scan_Configuration,'backgroundcolor',handles.ColorOff);
    drawnow, pause(1)
    set(handles.Load_Scan_Configuration,'backgroundcolor',handles.ColorIdle);
    return
else
    load([handles.ConfigurationDirectory,'/',FileName],'CONFIGURATION');
end
set(handles.PRESETPAGE,'value',CONFIGURATION.Preset);
PRESETPAGE_Callback(hObject, eventdata, handles)
eval(['p',num2str(CONFIGURATION.SubPreset),'_Callback(hObject, eventdata, handles)']);
set(handles.SCANPV,'data',CONFIGURATION.SCANPV_data);
set(handles.SCANPV,'userdata',CONFIGURATION.SCANPV_userdata);
set(handles.CalculationParameters,'data',CONFIGURATION.CalculationParameters);
SCANPV_CellEditCallback(hObject, eventdata, handles)

% --- Executes on button press in Save_Scan_Configuration.
function Save_Scan_Configuration_Callback(hObject, eventdata, handles)
CONFIGURATION.Preset=get(handles.PRESETPAGE,'value');
for II=1:12
    bkc=get(handles.(['p',num2str(II)]),'backgroundcolor');
    if(all(bkc==handles.ColorON))
        break
    end
end    
CONFIGURATION.SubPreset=II;
CONFIGURATION.SCANPV_data=get(handles.SCANPV,'data');
CONFIGURATION.SCANPV_userdata=get(handles.SCANPV,'userdata');
CONFIGURATION.CalculationParameters=get(handles.CalculationParameters,'data');

[FileName,Path]=uiputfile([handles.ConfigurationDirectory,'/*.mat'], 'Pick a file name for the configuration');
FileName=['VOM_SCAN_CONF_',FileName];
if(isnumeric(FileName) || isnumeric(Path))
    set(handles.Save_Scan_Configuration,'backgroundcolor',handles.ColorOff);
    drawnow, pause(1)
    set(handles.Save_Scan_Configuration,'backgroundcolor',handles.ColorIdle);
else
    save([handles.ConfigurationDirectory,'/',FileName],'CONFIGURATION');
end

% --- Executes on button press in MoreLines.
function MoreLines_Callback(hObject, eventdata, handles)
CT=get(handles.SCANPV,'data');
CT{end+1,1}=CT{end,1};
for II=2:8
    CT{end,II}=CT{end-1,II};
end
set(handles.SCANPV,'data',CT);

function setupscan_fromparam(handles)
Sdata=get(handles.SCANPV,'data');
[SA,SB]=size(Sdata);
set(handles.SCANPV,'data',CT);
%save TEMP






    
    




function Edit_Guaranteed_PV_Callback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end


% --- Executes during object creation, after setting all properties.
function Edit_Guaranteed_PV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Guaranteed_PV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GuaranteedParameterMIN_Callback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end

% --- Executes during object creation, after setting all properties.
function GuaranteedParameterMIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GuaranteedParameterMIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GuaranteedParameterMAX_Callback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end

% --- Executes during object creation, after setting all properties.
function GuaranteedParameterMAX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GuaranteedParameterMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RestoreStartingPointAtEnd.
function RestoreStartingPointAtEnd_Callback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end

% --- Executes on slider movement.
function SetSlider_Callback(hObject, eventdata, handles)
% hObject    handle to SetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SetSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in SET.
function SET_Callback(hObject, eventdata, handles)
Pvs=get(handles.CONDITIONS,'data');
SCAN=get(handles.CONDITIONS,'userdata');
[SA,SB]=size(Pvs);
for II=1:SA
  if(~isempty(Pvs{II,2}) && ~isempty(Pvs{II,1}))
    lcaPutNoWait(Pvs{II,1},Pvs{II,2})
    disp(['Setting ',Pvs{II,1},' to ',num2str(Pvs{II,2})])
  end
end
SCAN.Functions{3}()

function ConditionSet_Callback(hObject, eventdata, handles)
% hObject    handle to ConditionSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ConditionSet as text
%        str2double(get(hObject,'String')) returns contents of ConditionSet as a double


% --- Executes during object creation, after setting all properties.
function ConditionSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConditionSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LogBookButton.
function LogBookButton_Callback(hObject, eventdata, handles)
% hObject    handle to LogBookButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in p5.
function p5_Callback(hObject, eventdata, handles)
ActivatePreset(5,handles);
% --- Executes on button press in p6.
function p6_Callback(hObject, eventdata, handles)
ActivatePreset(6,handles);
% --- Executes on button press in p7.
function p7_Callback(hObject, eventdata, handles)
ActivatePreset(7,handles);
% --- Executes on button press in p8.
function p8_Callback(hObject, eventdata, handles)
ActivatePreset(8,handles);
% --- Executes on button press in p9.
function p9_Callback(hObject, eventdata, handles)
ActivatePreset(9,handles);
% --- Executes on button press in p10.
function p10_Callback(hObject, eventdata, handles)
ActivatePreset(10,handles);
% --- Executes on button press in p11.
function p11_Callback(hObject, eventdata, handles)
ActivatePreset(11,handles);
% --- Executes on button press in p12.
function p12_Callback(hObject, eventdata, handles)
ActivatePreset(12,handles);


% --- Executes on selection change in CalculatedParameters.
function CalculatedParameters_Callback(hObject, eventdata, handles)
% hObject    handle to CalculatedParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CalculatedParameters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CalculatedParameters


% --- Executes during object creation, after setting all properties.
function CalculatedParameters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalculatedParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in SCANPV.
function SCANPV_CellEditCallback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end
SCAN=get(handles.Ready,'Userdata');

if(isstruct(SCAN))
  Knobs.numberscanknobs=0;
  Knobs.Minknobs=[];
  Knobs.Maxknobs=[];
  MAT={};
  MAT2={};
  for II=1:SCAN.NumberOfScanPVs
    MAT{II,1}=SCAN.SCANPVLIST{II};
    MAT{II,2}=[];
    if(any(strcmp(SCAN.ScanBufferNames,['Scan Knob ',num2str(II)])))
     
      Knobs.numberscanknobs=Knobs.numberscanknobs+1;
      MAT2{Knobs.numberscanknobs,1}=['Scan Knob ',num2str(Knobs.numberscanknobs)];
      MAT2{Knobs.numberscanknobs,2}=1;
    end
  end
  set(handles.CONDITIONS,'userdata',SCAN);
  set(handles.CONDITIONS,'data',MAT);
  set(handles.KNOBS,'data',MAT2);
  KNOBS_CellEditCallback(hObject, eventdata, handles);
end

% --- Executes when entered data in editable cell(s) in CalculationParameters.
function CalculationParameters_CellEditCallback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end
SCAN=get(handles.Ready,'Userdata');
if(isstruct(SCAN))
  Knobs.numberscanknobs=0;
  Knobs.Minknobs=[];
  Knobs.Maxknobs=[];
  MAT={};
  MAT2={};
  for II=1:SCAN.NumberOfScanPVs
    MAT{II,1}=SCAN.SCANPVLIST{II};
    MAT{II,2}=[];
    if(any(strcmp(SCAN.ScanBufferNames,['Scan Knob ',num2str(II)])))
     
      Knobs.numberscanknobs=Knobs.numberscanknobs+1;
      MAT2{Knobs.numberscanknobs,1}=['Scan Knob ',num2str(Knobs.numberscanknobs)];
      MAT2{Knobs.numberscanknobs,2}=1;
    end
  end
  set(handles.CONDITIONS,'userdata',SCAN);
  set(handles.CONDITIONS,'data',MAT);
  set(handles.KNOBS,'data',MAT2);
  KNOBS_CellEditCallback(hObject, eventdata, handles);
end

function setupscan_fromcalculationfirst(handles)
set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
Functions=get(handles.Functions,'userdata');
SCAN.Functions=Functions;
CALCDATA=get(handles.CalculationParameters,'data');
[PVScanValues,MoreValues,PVScanNames,MoreValuesNames]=Functions{1}(CALCDATA);
[ScanLength,ScanPVsNumber]=size(PVScanValues);
[MoreValuesLength,MoreValuesNumber]=size(MoreValues);

if(ScanLength~=MoreValuesLength)
    disp('The additional values have a different length than the Scan PVs')
    return
end
% if((MoreValuesNumber~=ScanPVsNumber) || (MoreValuesNumber~=numel(PVScanNames)) ||  (MoreValuesNumber~=numel(MoreValuesNames)) )
%     return
% end

Sdata=get(handles.SCANPV,'data');
[SA,SB]=size(Sdata);
SC=numel(PVScanNames);
SCANPVLIST=Sdata(:,1);
KEEPLINE=ones(SA,1);
ThisKnob=[];
%PVScanNames
 
for II=1:SC
    SAMEPV = find(strcmp(PVScanNames(II),SCANPVLIST));
    if(~isempty(SAMEPV))
        KEEPLINE(SAMEPV)=0;
        Sdata{SAMEPV,4}=ScanLength;
        ThisKnob(end+1)=Sdata{SAMEPV,5};
    else
        
    end
end

if(any(diff(ThisKnob)~=0))
    return
else
    MultiKnobAddParameters=ThisKnob(1);
end

START=[Sdata{logical(KEEPLINE),2}];
END=[Sdata{logical(KEEPLINE),3}];
STEPS=[Sdata{logical(KEEPLINE),4}];

STARTF=[Sdata{:,2}];
ENDF=[Sdata{:,3}];
STEPSF=[Sdata{:,4}];

SAR=sum(KEEPLINE);

if((numel(START)~=SAR) || (numel(END)~=SAR) || (numel(STEPS)~=SAR) || any(isnan(START)) || any(isnan(END))  || any(isnan(STEPS))  )
    set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
    return
end
KNOBS=[Sdata{:,5}];
UniqueKnobs=unique(KNOBS);
for II=1:length(UniqueKnobs)
   AmountOfSteps=STEPSF(KNOBS==UniqueKnobs(II)); 
   if(any(diff(AmountOfSteps)~=0))
       set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
       return
   end
   StepsAmount(II)=AmountOfSteps(1);
end
TotalNumberOfSettings=prod(StepsAmount);
ConditionsMatrix=zeros(TotalNumberOfSettings,length(UniqueKnobs));
ScanValuesMatrix=zeros(TotalNumberOfSettings,numel(SCANPVLIST));
AdditionalValuesMatrix=zeros(TotalNumberOfSettings,numel(MoreValuesNames));
LUK=length(UniqueKnobs);
%Treated=LUK;
PreviousBlock=1;
for KK=LUK:-1:1
   ColonnaBase=[];
   %ValuesThisParameter=linspace(START(KK),END(KK),STEPS(KK));
   for SS=1:StepsAmount(KK)
       ColonnaBase((end+1):(end+PreviousBlock))=SS;
   end
   ColonnaBase=transpose(ColonnaBase);
   PreviousBlock=length(ColonnaBase);
   Column=repmat(ColonnaBase,TotalNumberOfSettings/PreviousBlock,1);
   ConditionsMatrix(:,KK)=Column;
   
   for TT=1:numel(SCANPVLIST)
       if(KNOBS(TT)==KK) %Se si tratta di questa knob
           if(KEEPLINE(TT)) % e' standard
                ValuesThisParameter=linspace(Sdata{TT,2},Sdata{TT,3},Sdata{TT,4});
           else %e' precalcolato
                PositionWithinValues=find(strcmp(Sdata{TT,1},PVScanNames));
                ValuesThisParameter=PVScanValues(:,PositionWithinValues);
           end
           for SS=1:StepsAmount(KK)          
                ScanValuesMatrix(Column==SS,TT)=ValuesThisParameter(SS); 
           end
           if(KNOBS(TT)==MultiKnobAddParameters) %scrivi tutta la additional val matrix
               AdditionalValuesMatrix=MoreValues(ConditionsMatrix(:,KNOBS(TT)),:);
           end
       end
   end
end
%Scan Values Matrix is filled
%ConditionsMatrix is filled
READOUTPVLIST=Sdata(:,6);
PauseVector=zeros(size(SCANPVLIST));
ToleranceVector=PauseVector;
ScaleFactor=ToleranceVector;
WaitUntilArrived=ToleranceVector;

ExpandedKnobs=zeros(TotalNumberOfSettings,numel(SCANPVLIST));

for SS=1:LUK
   REPSTO=numel(find([Sdata{:,5}]==SS));
   ExpandedKnobs(:,find([Sdata{:,5}]==SS)) = repmat(ConditionsMatrix(:,SS),1,REPSTO);
end

for II=1:numel(SCANPVLIST)
   if(~isempty(READOUTPVLIST{II}))
       ToleranceVector(II)=Sdata{II,8};
       ScaleFactor(II)=Sdata{II,7};
       WaitUntilArrived(II)=1;
   else
       PauseVector(II)=Sdata{II,8};
   end
end

if(iscolumn(PauseVector))
    PauseVector=transpose(PauseVector);
end
if(iscolumn(ToleranceVector))
    ToleranceVector=transpose(ToleranceVector);
end
if(iscolumn(ScaleFactor))
    ScaleFactor=transpose(ScaleFactor);
end

DCD=(diff(ExpandedKnobs))~=0;
DCD=[ones(1,numel(SCANPVLIST));DCD];
PauseDCD= repmat(PauseVector,TotalNumberOfSettings,1).*DCD;
if(iscolumn(PauseDCD))
    ConditionByConditionPauseVector=PauseDCD.';
elseif(isrow(PauseDCD))
    ConditionByConditionPauseVector=PauseDCD;
else
    ConditionByConditionPauseVector=max(PauseDCD.').';
end

NOE=str2num(get(handles.NOE,'string'));
if(any(isinf(NOE)) || (numel(NOE)~=1) || any(isnan(NOE)))
    return
end

GPV=get(handles.Edit_Guaranteed_PV,'string');
GPVMIN=str2num(get(handles.GuaranteedParameterMIN,'string'));
GPVMAX=str2num(get(handles.GuaranteedParameterMAX,'string'));
if(isempty(GPV) || (numel(GPVMIN)>1) || (numel(GPVMAX)>1) || isempty(GPVMIN) || isempty(GPVMAX) || any(isnan(GPVMAX) | isinf(GPVMAX)) || any(isnan(GPVMIN) | isinf(GPVMAX)) )
    set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
   return 
end
RestoreStarting=get(handles.RestoreStartingPointAtEnd,'value');
Functions=get(handles.Functions,'userdata');

SCAN.NumberOfScanPVs=numel(SCANPVLIST);
SCAN.TotalNumberOfConditions=TotalNumberOfSettings;
SCAN.NumberOfEvents=NOE;
SCAN.Functions=Functions;
SCAN.SCANPVLIST=SCANPVLIST;
SCAN.READOUTPVLIST=READOUTPVLIST;
SCAN.WaitUntilArrived=WaitUntilArrived.';
SCAN.WaitUntilArrivedPosition=find(SCAN.WaitUntilArrived);
SCAN.ScaleFactor=ScaleFactor;
SCAN.ToleranceVector=ToleranceVector;
SCAN.Pause=ConditionByConditionPauseVector;
SCAN.GuaranteedPV=GPV;
SCAN.GuaranteedPV_MIN=GPVMIN;
SCAN.GuaranteedPV_MAX=GPVMAX;
SCAN.RestoreStarting=RestoreStarting;
SCAN.ConditionsMatrix=ConditionsMatrix;
SCAN.ScanValuesMatrix=ScanValuesMatrix;
SCAN.AdditionalValuesNumber=numel(MoreValuesNames);
SCAN.AdditionalValuesNames=MoreValuesNames;
SCAN.AdditionalValuesMatrix=AdditionalValuesMatrix;
SCAN.ScanBufferNames=SCANPVLIST;
SCAN.KNOBS=KNOBS;
for II=1:numel(MoreValuesNames)
    SCAN.ScanBufferNames{end+1}=MoreValuesNames{II};
end

for II=1:LUK
    SCAN.ScanBufferNames{end+1}=['Scan Knob ',num2str(II)];
end
SCAN.ScanBufferNames{end+1}='Scan Setting';
SCAN.ScanBufferValues=[ScanValuesMatrix,AdditionalValuesMatrix,ConditionsMatrix,(1:TotalNumberOfSettings).'];
SCAN.ScanBufferLength=numel(SCAN.ScanBufferNames);

set(handles.Ready,'string','Ready to Start'); set(handles.Ready,'backgroundcolor',[0,1,0]);
set(handles.Ready,'userdata',SCAN);


function setupscan_fromtable(handles)
set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
Sdata=get(handles.SCANPV,'data');
[SA,SB]=size(Sdata);
START=[Sdata{:,2}];
END=[Sdata{:,3}];
STEPS=[Sdata{:,4}];
if((numel(START)~=SA) || (numel(END)~=SA) || (numel(STEPS)~=SA) || any(isnan(START)) || any(isnan(END))  || any(isnan(STEPS))  )
    set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
    return
end
SCANPVLIST=Sdata(:,1);
KNOBS=[Sdata{:,5}];
UniqueKnobs=unique(KNOBS);
for II=1:length(UniqueKnobs)
   AmountOfSteps=STEPS(KNOBS==UniqueKnobs(II));
   if(any(diff(AmountOfSteps)~=0))
       set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
       return
   end
   StepsAmount(II)=AmountOfSteps(1);
end
TotalNumberOfSettings=prod(StepsAmount);
ConditionsMatrix=zeros(TotalNumberOfSettings,length(UniqueKnobs));
ScanValuesMatrix=zeros(TotalNumberOfSettings,numel(SCANPVLIST));
% ProdCum=cumprod(StepsAmount);
% ProdCumOD=cumprod(StepsAmount(end:-1:1));
LUK=length(UniqueKnobs);
%Treated=LUK;
PreviousBlock=1;
for KK=LUK:-1:1
   ColonnaBase=[];
   ValuesThisParameter=linspace(START(KK),END(KK),STEPS(KK));
   for SS=1:StepsAmount(KK)
       ColonnaBase((end+1):(end+PreviousBlock))=SS;
   end
   ColonnaBase=transpose(ColonnaBase);
   PreviousBlock=length(ColonnaBase);
   Column=repmat(ColonnaBase,TotalNumberOfSettings/PreviousBlock,1);
   ColumnValues=zeros(size(Column));
   ConditionsMatrix(:,KK)=Column;
   for SS=1:STEPS(KK)
       ColumnValues(Column==SS) = ValuesThisParameter(KK);
   end
   
   for TT=1:numel(SCANPVLIST)
       if(KNOBS(TT)==KK) %Se si tratta di questa knob
           ValuesThisParameter=linspace(Sdata{TT,2},Sdata{TT,3},Sdata{TT,4});
           for SS=1:StepsAmount(KK)          
                ScanValuesMatrix(Column==SS,TT)=ValuesThisParameter(SS); 
           end
       end
   end
   
   
end
READOUTPVLIST=Sdata(:,6);
PauseVector=zeros(size(SCANPVLIST));
ToleranceVector=PauseVector;
ScaleFactor=ToleranceVector;
WaitUntilArrived=ToleranceVector;
ExpandedKnobs=zeros(TotalNumberOfSettings,numel(SCANPVLIST));
for SS=1:LUK
   REPSTO=numel(find([Sdata{:,5}]==SS));
   ExpandedKnobs(:,find([Sdata{:,5}]==SS)) = repmat(ConditionsMatrix(:,SS),1,REPSTO);
end

for II=1:numel(SCANPVLIST)
   if(~isempty(READOUTPVLIST{II}))
       ToleranceVector(II)=Sdata{II,8};
       ScaleFactor(II)=Sdata{II,7};
       WaitUntilArrived(II)=1;
   else
       PauseVector(II)=Sdata{II,8};
   end
end

if(iscolumn(PauseVector))
    PauseVector=transpose(PauseVector);
end
if(iscolumn(ToleranceVector))
    ToleranceVector=transpose(ToleranceVector);
end
if(iscolumn(ScaleFactor))
    ScaleFactor=transpose(ScaleFactor);
end

%save TEMP

DCD=(diff(ExpandedKnobs))~=0;
DCD=[ones(1,numel(SCANPVLIST));DCD];
PauseDCD= repmat(PauseVector,TotalNumberOfSettings,1).*DCD;
if(iscolumn(PauseDCD))
    ConditionByConditionPauseVector=PauseDCD.';
elseif(isrow(PauseDCD))
    ConditionByConditionPauseVector=PauseDCD;
else
    ConditionByConditionPauseVector=max(PauseDCD.').';
end


NOE=str2num(get(handles.NOE,'string'));
if(any(isinf(NOE)) || (numel(NOE)~=1) || any(isnan(NOE)))
    return
end

GPV=get(handles.Edit_Guaranteed_PV,'string');
GPVMIN=str2num(get(handles.GuaranteedParameterMIN,'string'));
GPVMAX=str2num(get(handles.GuaranteedParameterMAX,'string'));
if(isempty(GPV) || (numel(GPVMIN)>1) || (numel(GPVMAX)>1) || isempty(GPVMIN) || isempty(GPVMAX) || any(isnan(GPVMAX) | isinf(GPVMAX)) || any(isnan(GPVMIN) | isinf(GPVMAX)) )
    set(handles.Ready,'String','NOT READY');set(handles.Ready,'Backgroundcolor',[1,0,0]);set(handles.Ready,'userdata',NaN);
   return 
end
RestoreStarting=get(handles.RestoreStartingPointAtEnd,'value');
Functions=get(handles.Functions,'userdata');

SCAN.NumberOfScanPVs=numel(SCANPVLIST);
SCAN.TotalNumberOfConditions=TotalNumberOfSettings;
SCAN.NumberOfEvents=NOE;
SCAN.Functions=Functions;
SCAN.SCANPVLIST=SCANPVLIST;
SCAN.READOUTPVLIST=READOUTPVLIST;
SCAN.WaitUntilArrived=WaitUntilArrived.';
SCAN.WaitUntilArrivedPosition=find(SCAN.WaitUntilArrived);
SCAN.ScaleFactor=ScaleFactor;
SCAN.ToleranceVector=ToleranceVector;
SCAN.Pause=ConditionByConditionPauseVector;
SCAN.GuaranteedPV=GPV;
SCAN.GuaranteedPV_MIN=GPVMIN;
SCAN.GuaranteedPV_MAX=GPVMAX;
SCAN.RestoreStarting=RestoreStarting;
SCAN.ConditionsMatrix=ConditionsMatrix;
SCAN.ScanValuesMatrix=ScanValuesMatrix;
SCAN.AdditionalValuesNumber=0;
SCAN.AdditionalValuesNames={};
SCAN.AdditionalValuesMatrix=[];
SCAN.ScanBufferNames=SCANPVLIST;
SCAN.KNOBS=KNOBS;
for II=1:LUK
    SCAN.ScanBufferNames{end+1}=['Scan Knob ',num2str(II)];
end
SCAN.ScanBufferNames{end+1}='Scan Setting';
SCAN.ScanBufferValues=[ScanValuesMatrix,ConditionsMatrix,(1:TotalNumberOfSettings).'];
SCAN.ScanBufferLength=numel(SCAN.ScanBufferNames);

set(handles.Ready,'string','Ready to Start'); set(handles.Ready,'backgroundcolor',[0,1,0]);
set(handles.Ready,'userdata',SCAN);



function NOE_Callback(hObject, eventdata, handles)
if(get(handles.DisplayText,'userdata'));
    setupscan_fromcalculationfirst(handles)
else
    setupscan_fromtable(handles)
end


% --- Executes during object creation, after setting all properties.
function NOE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NOE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in KNOBS.
function KNOBS_CellEditCallback(hObject, eventdata, handles)
Pvs=get(handles.CONDITIONS,'data');
Selection=get(handles.KNOBS,'data');
SCAN=get(handles.CONDITIONS,'userdata');
%save TEMP
[SA,SB]=size(Selection);
[SX,SY]=size(SCAN.ConditionsMatrix);
if(SX>1)
    KnobsMax=max(SCAN.ConditionsMatrix);
else
    KnobsMax=SCAN.ConditionsMatrix;
end
KnobsSelection=[Selection{:,2}];
for II=1:length(KnobsSelection)
   if((KnobsSelection(II)<1) || (KnobsSelection(II)>KnobsMax(II)))
        KNNEXT(II)=NaN;
        KNPREV(II)=NaN;
   else
        KNNEXT(II)=ceil(KnobsSelection(II));
        KNPREV(II)=floor(KnobsSelection(II));
        if(KNNEXT(II)==KNPREV(II))
           KNDIST(II)=0; 
        else
           KNDIST(II)=(KnobsSelection(II)-KNPREV(II))/(KNNEXT(II)-KNPREV(II));
        end
   end
    
end

if(~any(isnan(KNNEXT)) && ~any(isnan(KNPREV))  )
    for II=1:SA
      KNOBPOSITION = find(strcmp(SCAN.ScanBufferNames,['Scan Knob ',num2str(II)]));
      if(II==1)
        NarrowedSelectionPREV=find((SCAN.ScanBufferValues(:,KNOBPOSITION)==KNPREV(II)));
      else
        NewSelection=find((SCAN.ScanBufferValues(:,KNOBPOSITION)==KNPREV(II)));
        NarrowedSelectionPREV=intersect(NarrowedSelectionPREV,NewSelection);
      end
    end
    for II=1:SA
      KNOBPOSITION = find(strcmp(SCAN.ScanBufferNames,['Scan Knob ',num2str(II)]));
      if(II==1)
        NarrowedSelectionNEXT=find((SCAN.ScanBufferValues(:,KNOBPOSITION)==KNNEXT(II)));
      else
        NewSelection=find((SCAN.ScanBufferValues(:,KNOBPOSITION)==KNNEXT(II)));
        NarrowedSelectionNEXT=intersect(NarrowedSelectionNEXT,NewSelection);
      end
    end
else
    [SC,SD]=size(Pvs);
    for II=1:SC
        Pvs{II,2}=[];
    end
    set(handles.CONDITIONS,'data',Pvs);
    return
end
[SC,SD]=size(Pvs);
% NarrowedSelectionPREV
% NarrowedSelectionNEXT
% save TEMP
for II=1:SC
    Pvs{II,2}=SCAN.ScanBufferValues(NarrowedSelectionPREV,II)*(1-KNDIST(SCAN.KNOBS(II))) + SCAN.ScanBufferValues(NarrowedSelectionNEXT,II)*KNDIST(SCAN.KNOBS(II));
end
% Pvs
set(handles.CONDITIONS,'data',Pvs);
% if(isempty(NarrowedSelectionNEXT) || isempty(NarrowedSelectionPREV))
%   for II=1:SC
%     Pvs{II,2}=[];
%   end
% else
  
% end
%save TEMPS



% --- Executes on selection change in PRESETPAGE.
function PRESETPAGE_Callback(hObject, eventdata, handles)
handles=SetVisibility_and_names(handles);
guidata(hObject, handles);
ActivatePreset(1,handles);



% --- Executes during object creation, after setting all properties.
function PRESETPAGE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PRESETPAGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
