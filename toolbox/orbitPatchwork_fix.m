function varargout = orbitPatchwork_fix(varargin)
% ORBITPATCHWORK_FIX MATLAB code for orbitPatchwork_fix.fig
%      ORBITPATCHWORK_FIX, by itself, creates a new ORBITPATCHWORK_FIX or raises the existing
%      singleton*.
%
%      H = ORBITPATCHWORK_FIX returns the handle to a new ORBITPATCHWORK_FIX or the handle to
%      the existing singleton*.
%
%      ORBITPATCHWORK_FIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORBITPATCHWORK_FIX.M with the given input arguments.
%
%      ORBITPATCHWORK_FIX('Property','Value',...) creates a new ORBITPATCHWORK_FIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before orbitPatchwork_fix_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to orbitPatchwork_fix_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help orbitPatchwork_fix

% Last Modified by GUIDE v2.5 30-Sep-2020 20:22:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @orbitPatchwork_fix_OpeningFcn, ...
                   'gui_OutputFcn',  @orbitPatchwork_fix_OutputFcn, ...
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


% --- Executes just before orbitPatchwork_fix is made visible.
function orbitPatchwork_fix_OpeningFcn(hObject, eventdata, handles, varargin)
handles.Solution=varargin{1};
handles.static=varargin{2};
handles.options=varargin{3};
handles.target=varargin{4};
handles.XCORPOS=find(cellfun(@(x) x(1)=='X',handles.Solution.UsedCorr_e));
handles.YCORPOS=find(cellfun(@(x) x(1)=='Y',handles.Solution.UsedCorr_e));
handles.XCOR.names=handles.Solution.UsedCorr_e(handles.XCORPOS); handles.YCOR.names=handles.Solution.UsedCorr_e(handles.YCORPOS);
handles.XCOR.names=handles.Solution.UsedCorr_e(handles.XCORPOS); handles.YCOR.names=handles.Solution.UsedCorr_e(handles.YCORPOS);
handles.XCOR.orig=handles.Solution.OldCorrReset(handles.XCORPOS); handles.YCOR.orig=handles.Solution.OldCorrReset(handles.YCORPOS);
handles.XCOR.OutOfRange=handles.Solution.OutOfRange(handles.XCORPOS); handles.YCOR.OutOfRange=handles.Solution.OutOfRange(handles.YCORPOS);
handles.XCOR.NewCorr=handles.Solution.NewCorr(handles.XCORPOS); handles.YCOR.NewCorr=handles.Solution.NewCorr(handles.YCORPOS);
handles.XCOR.FAILED=handles.Solution.OutOfRange(handles.XCORPOS); handles.YCOR.FAILED=handles.Solution.OutOfRange(handles.YCORPOS);

handles.CORRLIMITS=handles.static.corrRange(handles.options.useCorr,:);
handles.XCOR.LIMITS=handles.CORRLIMITS(handles.XCORPOS,:); handles.YCOR.LIMITS=handles.CORRLIMITS(handles.YCORPOS,:);

handles.XBPM.names=handles.static.bpmList_e(handles.options.useBPMx); handles.YBPM.names=handles.static.bpmList_e(handles.options.useBPMy);
handles.XBPM.orig=handles.Solution.RecordedOrbit(handles.options.useBPMx,1); handles.YBPM.orig=handles.Solution.RecordedOrbit(handles.options.useBPMy,2);
handles.XBPM.target=handles.target(handles.options.useBPMx,1); handles.YBPM.target=handles.target(handles.options.useBPMy,2);
handles.XBPM.XBPMPOS=handles.options.useBPMx; handles.YBPM.YBPMPOS=handles.options.useBPMy;

handles.OrbitX=handles.Solution.RecordedOrbit(:,1);
handles.OrbitY=handles.Solution.RecordedOrbit(:,2);
handles.OrbitX_Std=handles.Solution.RecordedOrbitStd(:,1);
handles.OrbitY_Std=handles.Solution.RecordedOrbitStd(:,2);

for II=1:numel(handles.XCOR.names)
    XC{II,1}=true;
    XC{II,2}=handles.XCOR.names{II};
    XC{II,3}=handles.XCOR.orig(II);
    XC{II,4}=handles.XCOR.LIMITS(II,1);
    XC{II,5}=handles.XCOR.NewCorr(II);
    XC{II,6}=handles.XCOR.LIMITS(II,2);
    XC{II,7}=handles.XCOR.FAILED(II);
    XC{II,8}=0;
end
set(handles.XC,'data',XC);
set(handles.XC,'columnname',{'use','name','orig','MIN','new','MAX','failed','BCTRL'})
set(handles.XC,'ColumnEditable',[true,false,false,false,true,false,false,false]);

for II=1:numel(handles.YCOR.names)
    YC{II,1}=true;
    YC{II,2}=handles.YCOR.names{II};
    YC{II,3}=handles.YCOR.orig(II);
    YC{II,4}=handles.YCOR.LIMITS(II,1);
    YC{II,5}=handles.YCOR.NewCorr(II);
    YC{II,6}=handles.YCOR.LIMITS(II,2);
    YC{II,7}=handles.YCOR.FAILED(II);
    YC{II,8}=0;
end
set(handles.YC,'data',YC);
set(handles.YC,'columnname',{'use','name','orig','MIN','new','MAX','failed','BCTRL'})
set(handles.YC,'ColumnEditable',[true,false,false,false,true,false,false,false]);

for II=1:numel(handles.XBPM.names)
    XB{II,1}=true;
    XB{II,2}=handles.XBPM.names{II};
    XB{II,3}=handles.XBPM.orig(II);
    XB{II,4}=handles.XBPM.target(II);
end
set(handles.XB,'data',XB);
set(handles.XB,'columnname',{'use','name','orig','target'})
set(handles.XB,'ColumnEditable',[true,false,false,true]);

for II=1:numel(handles.YBPM.names)
    YB{II,1}=true;
    YB{II,2}=handles.YBPM.names{II};
    YB{II,3}=handles.YBPM.orig(II);
    YB{II,4}=handles.YBPM.target(II);
end
set(handles.YB,'data',YB);
set(handles.YB,'columnname',{'use','name','orig','target'})
set(handles.YB,'ColumnEditable',[true,false,false,true]);
pushbutton5_Callback(hObject, eventdata, handles);

SolutionSteer(handles, 1, 1);

% Choose default command line output for orbitPatchwork_fix
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes orbitPatchwork_fix wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = orbitPatchwork_fix_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in XC.
function XC_Callback(hObject, eventdata, handles)
% hObject    handle to XC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XC


% --- Executes during object creation, after setting all properties.
function XC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YC.
function YC_Callback(hObject, eventdata, handles)
% hObject    handle to YC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YC


% --- Executes during object creation, after setting all properties.
function YC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in XB.
function XB_Callback(hObject, eventdata, handles)
% hObject    handle to XB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XB


% --- Executes during object creation, after setting all properties.
function XB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YB.
function YB_Callback(hObject, eventdata, handles)
% hObject    handle to YB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YB


% --- Executes during object creation, after setting all properties.
function YB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SolutionSteer(handles, FromNew, UpdateOnly)
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
static=handles.static;
XBP=find(handles.XBPM.XBPMPOS);
YBP=find(handles.YBPM.YBPMPOS);
ReadOutOrbit=NaN*ones(length(static.bpmList),2);
ReadOutOrbit(XBP([XB{:,1}]),1) = [XB{[XB{:,1}],3}];
ReadOutOrbit(YBP([YB{:,1}]),2) = [YB{[YB{:,1}],3}];

TargetOrbit=NaN*ones(length(static.bpmList),2);
TargetOrbit(XBP([XB{:,1}]),1) = [XB{[XB{:,1}],4}];
TargetOrbit(YBP([YB{:,1}]),2) = [YB{[YB{:,1}],4}];

SVDC=str2double(get(handles.SVDCoefficient,'string'));

XCORuse=[XC{:,1}]; YCORuse=[YC{:,1}];

[~,XCORPOS,XCORPOS_REVERT]=intersect(static.corrList_e,handles.XCOR.names,'stable');
[~,YCORPOS,YCORPOS_REVERT]=intersect(static.corrList_e,handles.YCOR.names,'stable');


cla(handles.OX); cla(handles.OY);
hold(handles.OX,'on'); hold(handles.OY,'on');
plot(handles.OX,static.zBPM(XBP([XB{:,1}])),ReadOutOrbit(XBP([XB{:,1}]),1),'-ok','linewidth',2);
plot(handles.OY,static.zBPM(YBP([YB{:,1}])),ReadOutOrbit(YBP([YB{:,1}]),2),'-ok','linewidth',2);
plot(handles.OX,static.zBPM(XBP([XB{:,1}])),TargetOrbit(XBP([XB{:,1}]),1),':+g','linewidth',2);
plot(handles.OY,static.zBPM(YBP([YB{:,1}])),TargetOrbit(YBP([YB{:,1}]),2),':+g','linewidth',2);



if(FromNew)
    %Computes difference orbit in BPM locations.
    CorrectorsForOrbitChange=zeros(length(static.corrList),1);
    CorrectorsOldVal=zeros(length(static.corrList),1);
    CorrectorsForOrbitChange(XCORPOS)=[XC{:,5}] - [XC{:,3}];
    CorrectorsForOrbitChange(YCORPOS)=[YC{:,5}] - [YC{:,3}];
    CorrectorsOldVal(XCORPOS)=[XC{:,5}];
    CorrectorsOldVal(YCORPOS)=[YC{:,5}];
else
    CorrectorsForOrbitChange=zeros(length(static.corrList),1);
    CorrectorsOldVal=zeros(length(static.corrList),1);
    CorrectorsForOrbitChange(XCORPOS)=[XC{:,3}] - [XC{:,3}];
    CorrectorsForOrbitChange(YCORPOS)=[YC{:,3}] - [YC{:,3}];
    CorrectorsOldVal(XCORPOS)=[XC{:,3}];
    CorrectorsOldVal(YCORPOS)=[YC{:,3}];
end

BPMChange=handles.Solution.MODEL.CorrMatrix*CorrectorsForOrbitChange*1000;
BPMChangeX=BPMChange(1:2:end);
BPMChangeY=BPMChange(2:2:end);
ReadOutOrbit(:,1)=ReadOutOrbit(:,1) + BPMChangeX - TargetOrbit(:,1);
ReadOutOrbit(:,2)=ReadOutOrbit(:,2) + BPMChangeY - TargetOrbit(:,2);

if(UpdateOnly)
   hold(handles.OX,'on'); hold(handles.OY,'on');
   plot(handles.OX,static.zBPM(XBP([XB{:,1}])),ReadOutOrbit(XBP([XB{:,1}]),1),'--xr','linewidth',2);
   plot(handles.OY,static.zBPM(YBP([YB{:,1}])),ReadOutOrbit(YBP([YB{:,1}]),2),'--xr','linewidth',2);
else
    useBPMx = handles.options.useBPMx;
    useBPMy = handles.options.useBPMy;
    
    useBPMx(XBP) = [XB{:,1}];
    useBPMy(YBP) = [YB{:,1}];
    
    useBPM=false(2*length(static.bpmList),1);
    useBPM(1:2:end)=useBPMx;
    useBPM(2:2:end)=useBPMy;
    
    SystemBPMData=zeros(2*length(static.bpmList),1);
    SystemBPMData(1:2:end)=ReadOutOrbit(:,1); SystemBPMData(2:2:end)=ReadOutOrbit(:,2);
    
    useCorr=handles.options.useCorr;
    useCorr(XCORPOS)=XCORuse;
    useCorr(YCORPOS)=YCORuse;
     
    CorrMatrix_Reduced = handles.Solution.MODEL.CorrMatrix(useBPM,useCorr);
    
    BPMData=SystemBPMData(useBPM);
    Weights=10^-6*ones(size(BPMData));
    [SystemSolution,SystemSolution_Std] = util_lssvd(CorrMatrix_Reduced, BPMData, Weights, SVDC);
    
    SystemSolution=SystemSolution/1000;
    SystemSolution_Std=SystemSolution_Std/1000;
    
    Solution.SystemSolution=SystemSolution;
    Solution.SystemSolution_Std=SystemSolution_Std;
    Solution.OldCorr=CorrectorsOldVal;
    
    Solution.OldCorrReset=CorrectorsOldVal(useCorr);
    Solution.NewCorr=Solution.OldCorr(useCorr) - SystemSolution;
    Solution.OutOfRange=(Solution.NewCorr<static.corrRange(useCorr,1)) | (Solution.NewCorr>static.corrRange(useCorr,2));
    Solution.FAILED=any(Solution.OutOfRange);
    Solution.UsedCorr=static.corrList(useCorr);
    Solution.UsedCorr_e=static.corrList_e(useCorr);
       
    [~, Where_In_Table_X, Where_In_UsedCorr_X] = intersect(handles.XCOR.names,Solution.UsedCorr_e,'stable');
    [~, Where_In_Table_Y, Where_In_UsedCorr_Y] = intersect(handles.YCOR.names,Solution.UsedCorr_e,'stable');
    
    for II=1:length(Where_In_Table_X)
        if(XC{Where_In_Table_X(II),1})
            XC{Where_In_Table_X(II),5}=Solution.NewCorr(Where_In_UsedCorr_X(II));
        end
    end
    for II=1:length(Where_In_Table_Y)
        if(YC{Where_In_Table_Y(II),1})
            YC{Where_In_Table_Y(II),5}=Solution.NewCorr(Where_In_UsedCorr_Y(II));
        end
    end

    CorrectorsForOrbitChange=zeros(length(static.corrList),1);
    CorrectorsForOrbitChange(XCORPOS)=[XC{:,5}] - [XC{:,3}];
    CorrectorsForOrbitChange(YCORPOS)=[YC{:,5}] - [YC{:,3}];
    
    ReadOutOrbit=NaN*ones(length(static.bpmList),2);
    ReadOutOrbit(XBP([XB{:,1}]),1) = [XB{[XB{:,1}],3}];
    ReadOutOrbit(YBP([YB{:,1}]),2) = [YB{[YB{:,1}],3}];
    
    BPMChange=handles.Solution.MODEL.CorrMatrix*CorrectorsForOrbitChange*1000;
    BPMChangeX=BPMChange(1:2:end);
    BPMChangeY=BPMChange(2:2:end);
    ReadOutOrbit(:,1)=ReadOutOrbit(:,1) + BPMChangeX;
    ReadOutOrbit(:,2)=ReadOutOrbit(:,2) + BPMChangeY;
    hold(handles.OX,'on'); hold(handles.OY,'on');
    plot(handles.OX,static.zBPM(XBP([XB{:,1}])),ReadOutOrbit(XBP([XB{:,1}]),1),'--xr','linewidth',2);
    plot(handles.OY,static.zBPM(YBP([YB{:,1}])),ReadOutOrbit(YBP([YB{:,1}]),2),'--xr','linewidth',2);
    
    
    
end

MINX=[XC{:,4}]; MAXX=[XC{:,6}]; VALX=[XC{:,5}]; 
MINY=[YC{:,4}]; MAXY=[YC{:,6}]; VALY=[YC{:,5}];
for II=1:size(XC,1)
        XC{II,7}=~((VALX(II)>=MINX(II)) && (VALX(II)<=MAXX(II)));
end
for II=1:size(YC,1)
        YC{II,7}=~((VALY(II)>=MINY(II)) && (VALY(II)<=MAXY(II)));
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);

if(any([XC{:,7}]))
    set(handles.SX,'string','FAILED','backgroundcolor',[1,0,0]);
    set(handles.X,'value',0);
else
    set(handles.SX,'string','OK','backgroundcolor',[0,1,0]);
    set(handles.X,'value',1);
end

if(any([YC{:,7}]))
    set(handles.SY,'string','FAILED','backgroundcolor',[1,0,0]);
    set(handles.Y,'value',0);
else
    set(handles.SY,'string','OK','backgroundcolor',[0,1,0]);
    set(handles.Y,'value',1);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
SolutionSteer(handles, 0, 0);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
SolutionSteer(handles, 1, 0);

function SVDCoefficient_Callback(hObject, eventdata, handles)
% hObject    handle to SVDCoefficient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SVDCoefficient as text
%        str2double(get(hObject,'String')) returns contents of SVDCoefficient as a double


% --- Executes during object creation, after setting all properties.
function SVDCoefficient_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SVDCoefficient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
X=get(handles.X,'value'); Y=get(handles.Y,'value');
PVNamesX=strcat(XC(:,2),':BCTRL'); PVNamesY=strcat(YC(:,2),':BCTRL');
ValuesX=[XC{:,5}]; ValuesY=[YC{:,5}];
Old=[];
if(X)
    OldX=lcaGetSmart(PVNamesX);
    lcaPutSmart(PVNamesX,ValuesX(:));
    Old.X.V=OldX;
    Old.X.PV=PVNamesX;
end
if(Y)
    OldY=lcaGetSmart(PVNamesY);
    lcaPutSmart(PVNamesY,ValuesY(:));
    Old.Y.V=OldY;
    Old.Y.PV=PVNamesY;
end

set(handles.pushbutton4,'userdata',Old);

% --- Executes on button press in X.
function X_Callback(hObject, eventdata, handles)
% hObject    handle to X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of X


% --- Executes on button press in Y.
function Y_Callback(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Y


% --- Executes when entered data in editable cell(s) in XC.
function XC_CellEditCallback(hObject, eventdata, handles)
SolutionSteer(handles, 1, 1)


% --- Executes when entered data in editable cell(s) in YC.
function YC_CellEditCallback(hObject, eventdata, handles)
SolutionSteer(handles, 1, 1)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
Old=get(handles.pushbutton4,'userdata');
if(isempty(Old))
    set(handles.RestoreString,'string','NO');
    return
end
str=[];
if(isfield(Old,'X'))
    lcaPutSmart(Old.X.PV,Old.X.V(:));
    str=[str,'X '];
end
if(isfield(Old,'Y'))
    lcaPutSmart(Old.Y.PV,Old.Y.V(:));
    str=[str,'Y'];
end
set(handles.RestoreString,'string',str);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
XCOR=lcaGetSmart(strcat(handles.XCOR.names,':BCTRL'));
YCOR=lcaGetSmart(strcat(handles.YCOR.names,':BCTRL'));
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
for II=1:length(XCOR)
    XC{II,8}=XCOR(II);
end
for II=1:length(YCOR)
    YC{II,8}=YCOR(II);
end
set(handles.XC,'data',XC); set(handles.YC,'data',YC);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
for II=1:size(XC,1)
    if(XC{II,5}<XC{II,4})
        XC{II,5}=XC{II,4};
        XC{II,1}=false;
    end
    if(XC{II,5}>XC{II,6})
        XC{II,5}=XC{II,6};
        XC{II,1}=false;
    end
end
for II=1:size(YC,1)
    if(YC{II,5}<YC{II,4})
        YC{II,5}=YC{II,4};
        YC{II,1}=false;
    end
    if(YC{II,5}>YC{II,6})
        YC{II,5}=YC{II,6};
        YC{II,1}=false;
    end
end
set(handles.XC,'data',XC); set(handles.YC,'data',YC);
