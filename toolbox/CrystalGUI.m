function varargout = CrystalGUI(varargin)
% CRYSTALGUI MATLAB code for CrystalGUI.fig
%      CRYSTALGUI, by itself, creates a new CRYSTALGUI or raises the existing
%      singleton*.
%
%      H = CRYSTALGUI returns the handle to a new CRYSTALGUI or the handle to
%      the existing singleton*.
%
%      CRYSTALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRYSTALGUI.M with the given input arguments.
%
%      CRYSTALGUI('Property','Value',...) creates a new CRYSTALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CrystalGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CrystalGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CrystalGUI

% Last Modified by GUIDE v2.5 28-Feb-2014 13:51:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CrystalGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CrystalGUI_OutputFcn, ...
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


% --- Executes just before CrystalGUI is made visible.
function CrystalGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CrystalGUI (see VARARGIN)

% Choose default command line output for CrystalGUI
handles.output = hObject;
load CrystalGUI_Default
handles.Offset_Vector = Offset_Vector;
handles.Preset1=Preset1;
handles.Preset2=Preset2;
handles.material=CostantiMateriali;
handles.Configuration=Configuration;
handles.lattice_constant=lattice_constant;
set(handles.Material,'String',handles.material);
set(handles.SNO_Tx,'String',num2str(handles.Offset_Vector.X_Rotation_Error));
set(handles.SNO_Yy,'String',num2str(handles.Offset_Vector.Y_Rotation_Error));
set(handles.SNO_Rz,'String',num2str(handles.Offset_Vector.Z_Rotation_Error));
set(handles.SNO_eyRA,'String',num2str(handles.Offset_Vector.Y_Rotation_ThetaAxis));
set(handles.SNO_ezRA,'String',num2str(handles.Offset_Vector.Z_Rotation_ThetaAxis));
set(handles.SNO_exYA,'String',num2str(handles.Offset_Vector.X_Rotation_YawAxis));
set(handles.SNO_ezYA,'String',num2str(handles.Offset_Vector.Z_Rotation_YawAxis));
set(handles.SNO_Tmis,'String',num2str(handles.Offset_Vector.Theta_Misreading));
set(handles.SNO_Ymis,'String',num2str(handles.Offset_Vector.Yaw_Misreading));
set(handles.C_1x,'BackGroundColor',[1,0,0]);
set(handles.C_2x,'BackGroundColor',[0,0,0]);
set(handles.C_3x,'BackGroundColor',[1,1,1]);
set(handles.C_1x,'ForeGroundColor',[0,0,0]);
set(handles.C_2x,'ForeGroundColor',[1,1,1]);
set(handles.C_3x,'ForeGroundColor',[0,0,0]);
set(handles.Tabula,'Visible','off')
set(handles.Color12Scan147,'Enable','off')
set(handles.SearchAngles147,'Enable','off')   
handles.ConfNames{1}='Current Configuration';
handles.YawPutPV='XTAL:UND1:1652:MOTOR';
handles.YawGetPV='XTAL:UND1:1652:MOTOR';
handles.PitchPutPV='XTAL:UND1:1653:MOTOR';
handles.PitchGetPV='XTAL:UND1:1653:MOTOR';
handles.VernierPV='FBCK:FB04:LG01:DL2VERNIER';
handles.Giaciture=TutteLeGiaciture;
handles.MaxSumSqr=SUMSQR;
handles.MaxAbs=MaxAbsGiaciture;
handles.Thres=10^-3; handles.PauseSet=0.01;
handles.AnglePreset=AnglePreset;
try
    X=imread('CrystalGUI_FIG_COMP.png');
    image(X,'Parent',handles.axes6);
    set(handles.axes6,'Xtick',[]);
    set(handles.axes6,'Ytick',[]);
catch ME
end

for II=1:numel(handles.Configuration)
        handles.ConfNames{II+1} = handles.Configuration(II).name;
end
set(handles.srl,'String',handles.ConfNames);
set(handles.srl,'Value',1);

handles.ColorON=[0,1,0];handles.ColorOFF=[1,0,0];handles.ColorWAIT=[1,1,0.2];handles.ColorIDLE=get(handles.SC_Stop,'BackGroundColor');

set(handles.Testo_X,'String',{'E','l','dE/dy','dE/dq'},'FontName','Symbol','FontSize',14)
set(handles.Testo_Y,'String',{'[eV]','[nm]','[eV/deg]','[eV/deg]'},'FontName','Times New Roman','FontSize',14)
handles.WorkingAngles = str2num([get(handles.V_T,'String'),get(handles.V_Y,'String'),get(handles.V_R,'String')]);
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off'); set(handles.ISS_Panel,'visible','off');
set(handles.MovingPanel,'visible','off')
set(handles.AngleControlPanel,'visible','on');set(handles.IchBinFaulPanel,'visible','off');set(handles.MovingPanel,'visible','off')
% Update handles structure
guidata(hObject, handles);

%Executes additional instructions contained in varargin script
if(~isempty(varargin))
    if(exist(varargin{1},'file'))
        %['FID = fopen(',varargin{1},',''r'');']
        FID=fopen(varargin{1},'r');
        %eval(['FID = fopen(',varargin{1},',''r'');'])
        Line=fgetl(FID);
        fclose(FID);
        isok=strcmp('%Crystal GUI External Command Script Header%',Line);
        if(isok)
            eval(varargin{1}(1:(end-2)))
        end
    end
end
Draw_Upper_LR(handles)

% UIWAIT makes CrystalGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CrystalGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function V_T_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.V_T,'String'));
if(numel(Read)~=1)
    set(handles.V_T,'String','0')
    return
end
if(isnan(Read))
    set(handles.V_T,'String','0')
    return
end
if((Read<0) || (Read>180))
    set(handles.V_T,'String','56')
    return
end


% --- Executes during object creation, after setting all properties.
function V_T_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V_T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function V_Y_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.V_Y,'String'));
if(numel(Read)~=1)
    set(handles.V_Y,'String','0')
    return
end
if(isnan(Read))
    set(handles.V_Y,'String','0')
    return
end
if(abs(Read)>45)
    set(handles.V_Y,'String','0')
    return
end


% --- Executes during object creation, after setting all properties.
function V_Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function V_R_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.V_R,'String'));
if(numel(Read)~=1)
    set(handles.V_R,'String','0')
    return
end
if(isnan(Read))
    set(handles.V_R,'String','0')
    return
end
if(abs(Read)>20)
    set(handles.V_R,'String','0')
    return
end


% --- Executes during object creation, after setting all properties.
function V_R_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function T_min_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<0) || (numread>180))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function T_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function T_max_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','180');
    return
end
if((numread<0) || (numread>180))
    set(hObject,'String','180');
    return
end
if (isnan(numread))
    set(hObject,'String','180');
    return
end

% --- Executes during object creation, after setting all properties.
function T_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_min_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.E_min,'String'));
if(numel(Read)~=1)
    set(handles.E_min,'String','3000')
    return
end
if(isnan(Read))
    set(handles.E_min,'String','3000')
    return
end
if(Read<3000)
    set(handles.E_min,'String','3000')
    return
end
if(Read>44000)
    set(handles.E_max,'String','44000')
    return
end


% --- Executes during object creation, after setting all properties.
function E_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_max_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.E_max,'String'));
if(numel(Read)~=1)
    set(handles.E_max,'String','16000')
    return
end
if(isnan(Read))
    set(handles.E_max,'String','16000')
    return
end
if(Read>45000)
    set(handles.E_max,'String','45000')
    return
end
if(Read<3100)
    set(handles.E_max,'String','3100')
    return
end


% --- Executes during object creation, after setting all properties.
function E_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_min_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','-5');
    return
end
if((numread<-45) || (numread>45))
    set(hObject,'String','-5');
    return
end
if (isnan(numread))
    set(hObject,'String','-5');
    return
end


% --- Executes during object creation, after setting all properties.
function Y_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_max_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','5');
    return
end
if((numread<-44) || (numread>46))
    set(hObject,'String','5');
    return
end
if (isnan(numread))
    set(hObject,'String','5');
    return
end


% --- Executes during object creation, after setting all properties.
function Y_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in P1.
function P1_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.P1_E,'String'));
if(numel(Read)~=3)
    set(handles.P1_E,'String','')
    set(handles.P1,'Value',0)
    return
end
if(isnan(sum(Read)))
    set(handles.P1_E,'String','')
    set(handles.P1,'Value',0)
    return
end
if((Read(1)~=round(Read(1))) || (Read(2)~=round(Read(2))) || (Read(2)~=round(Read(2))))
    set(handles.P1_E,'String','')
    set(handles.P1,'Value',0)
    return
end

% --- Executes on button press in P2.
function P2_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.P2_E,'String'));
if(numel(Read)~=3)
    set(handles.P2_E,'String','')
    set(handles.P2,'Value',0)
    return
end
if(isnan(sum(Read)))
    set(handles.P2_E,'String','')
    set(handles.P2,'Value',0)
    return
end
if((Read(1)~=round(Read(1))) || (Read(2)~=round(Read(2))) || (Read(2)~=round(Read(2))))
    set(handles.P2_E,'String','')
    set(handles.P2,'Value',0)
    return
end


% --- Executes on button press in P3.
function P3_Callback(hObject, eventdata, handles)
Read=str2num(get(handles.P3_E,'String'));
if(numel(Read)~=3)
    set(handles.P3_E,'String','')
    set(handles.P3,'Value',0)
    return
end
if(isnan(sum(Read)))
    set(handles.P3_E,'String','')
    set(handles.P3,'Value',0)
    return
end
if((Read(1)~=round(Read(1))) || (Read(2)~=round(Read(2))) || (Read(2)~=round(Read(2))))
    set(handles.P3_E,'String','')
    set(handles.P3,'Value',0)
    return
end



function P1_E_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    set(handles.P1,'Value',0)
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    set(handles.P1,'Value',0)
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    set(handles.P1,'Value',0)
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
            set(handles.P1,'Value',0)
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
            set(handles.P1,'Value',0)
        return
        end
    case 1
        set(hObject,'String','');
        set(handles.P1,'Value',0)
        return
    case 2
        set(hObject,'String','');
        set(handles.P1,'Value',0)
        return
    case 3
    otherwise
        set(hObject,'String','');
        set(handles.P1,'Value',0)
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    set(handles.P1,'Value',0)
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])


% --- Executes during object creation, after setting all properties.
function P1_E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P1_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P2_E_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    set(handles.P2,'Value',0)
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    set(handles.P2,'Value',0)
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    set(handles.P2,'Value',0)
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
            set(handles.P2,'Value',0)
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
            set(handles.P2,'Value',0)
        return
        end
    case 1
        set(hObject,'String','');
        set(handles.P2,'Value',0)
        return
    case 2
        set(hObject,'String','');
        set(handles.P2,'Value',0)
        return
    case 3
    otherwise
        set(hObject,'String','');
        set(handles.P2,'Value',0)
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    set(handles.P2,'Value',0)
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])


% --- Executes during object creation, after setting all properties.
function P2_E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P2_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P3_E_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    set(handles.P3,'Value',0)
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    set(handles.P3,'Value',0)
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    set(handles.P3,'Value',0)
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
            set(handles.P3,'Value',0)
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
            set(handles.P3,'Value',0)
        return
        end
    case 1
        set(hObject,'String','');
        set(handles.P3,'Value',0)
        return
    case 2
        set(hObject,'String','');
        set(handles.P3,'Value',0)
        return
    case 3
    otherwise
        set(hObject,'String','');
        set(handles.P3,'Value',0)
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    set(handles.P3,'Value',0)
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])


% --- Executes during object creation, after setting all properties.
function P3_E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P3_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SNO.
function SNO_Callback(hObject, eventdata, handles)
Current_SNO=upper(get(handles.SNO_Panel,'visible'));
if(strcmp(Current_SNO,'ON'))
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
else
    set(handles.SNO_Tx,'String',num2str(handles.Offset_Vector.X_Rotation_Error));
    set(handles.SNO_Yy,'String',num2str(handles.Offset_Vector.Y_Rotation_Error));
    set(handles.SNO_Rz,'String',num2str(handles.Offset_Vector.Z_Rotation_Error));
    set(handles.SNO_eyRA,'String',num2str(handles.Offset_Vector.Y_Rotation_ThetaAxis));
    set(handles.SNO_ezRA,'String',num2str(handles.Offset_Vector.Z_Rotation_ThetaAxis));
    set(handles.SNO_exYA,'String',num2str(handles.Offset_Vector.X_Rotation_YawAxis));
    set(handles.SNO_ezYA,'String',num2str(handles.Offset_Vector.Z_Rotation_YawAxis));
    set(handles.SNO_Tmis,'String',num2str(handles.Offset_Vector.Theta_Misreading));
    set(handles.SNO_Ymis,'String',num2str(handles.Offset_Vector.Yaw_Misreading));
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','off');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','on');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
end


% --- Executes on selection change in Material.
function Material_Callback(hObject, eventdata, handles)
% hObject    handle to Material (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Material contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Material


% --- Executes during object creation, after setting all properties.
function Material_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Material (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_Tx_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end



% --- Executes during object creation, after setting all properties.
function SNO_Tx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_Tx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_Yy_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_Yy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_Yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_Rz_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_Rz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_Rz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SNO_SET.
function SNO_SET_Callback(hObject, eventdata, handles)
Offset_Vector.X_Rotation_Error=str2num(get(handles.SNO_Tx,'String'));
Offset_Vector.Y_Rotation_Error=str2num(get(handles.SNO_Yy,'String'));
Offset_Vector.Z_Rotation_Error=str2num(get(handles.SNO_Rz,'String'));
Offset_Vector.Y_Rotation_ThetaAxis=str2num(get(handles.SNO_eyRA,'String'));
Offset_Vector.Z_Rotation_ThetaAxis=str2num(get(handles.SNO_ezRA,'String'));
Offset_Vector.X_Rotation_YawAxis=str2num(get(handles.SNO_exYA,'String'));
Offset_Vector.Z_Rotation_YawAxis=str2num(get(handles.SNO_ezYA,'String'));
Offset_Vector.Theta_Misreading=str2num(get(handles.SNO_Tmis,'String'));
Offset_Vector.Yaw_Misreading=str2num(get(handles.SNO_Ymis,'String'));
handles.Offset_Vector=Offset_Vector;
guidata(hObject, handles);
Draw_Upper_LR(handles);
Draw_2_Callback(0, 0, handles);



% --- Executes on button press in SNO_SAVE.
function SNO_SAVE_Callback(hObject, eventdata, handles)
Offset_Vector.X_Rotation_Error=str2num(get(handles.SNO_Tx,'String'));
Offset_Vector.Y_Rotation_Error=str2num(get(handles.SNO_Yy,'String'));
Offset_Vector.Z_Rotation_Error=str2num(get(handles.SNO_Rz,'String'));
Offset_Vector.Y_Rotation_ThetaAxis=str2num(get(handles.SNO_eyRA,'String'));
Offset_Vector.Z_Rotation_ThetaAxis=str2num(get(handles.SNO_ezRA,'String'));
Offset_Vector.X_Rotation_YawAxis=str2num(get(handles.SNO_exYA,'String'));
Offset_Vector.Z_Rotation_YawAxis=str2num(get(handles.SNO_ezYA,'String'));
Offset_Vector.Theta_Misreading=str2num(get(handles.SNO_Tmis,'String'));
Offset_Vector.Yaw_Misreading=str2num(get(handles.SNO_Ymis,'String'));
handles.Offset_Vector=Offset_Vector;
Draw_Upper_LR(handles);
Draw_2_Callback(0, 0, handles);
guidata(hObject, handles);
save CrystalGUI_Default -append Offset_Vector

% --- Executes during object creation, after setting all properties.
function ax_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ax_1


% --- Executes on button press in SNO_Close.
function SNO_Close_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off')


% --- Executes on button press in Draw_Button.
function Draw_Button_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off')
set(hObject,'String','.. evaluating ..');drawnow
handles.WorkingAngles = str2num([get(handles.V_T,'String'),get(handles.V_Y,'String'),get(handles.V_R,'String')]);
guidata(hObject, handles);
Draw_Upper_LR(handles)
set(hObject,'String','Draw');

function Draw_Upper_LR(handles)
Theta=str2num(get(handles.V_T,'String'));
Yaw=str2num(get(handles.V_Y,'String'));
% Roll=str2num(get(handles.V_R,'String')); legacy

Tmin=str2num(get(handles.T_min,'String')); Tmax=str2num(get(handles.T_max,'String'));
Ymin=str2num(get(handles.Y_min,'String')); Ymax=str2num(get(handles.Y_max,'String'));
Emin=str2num(get(handles.E_min,'String')); Emax=str2num(get(handles.E_max,'String'));

if(Emax<Emin)
    set(handles.E_min,'String',num2str(Emax));
    set(handles.E_max,'String',num2str(Emin));
    Emin=str2num(get(handles.E_min,'String')); Emax=str2num(get(handles.E_max,'String'));
end

if(Tmax<Tmin)
    set(handles.T_min,'String',num2str(Tmax));
    set(handles.T_max,'String',num2str(Tmin));
    Tmin=str2num(get(handles.T_min,'String')); Tmax=str2num(get(handles.T_max,'String'));
end

if(Ymax<Ymin)
    set(handles.Y_min,'String',num2str(Ymax));
    set(handles.Y_max,'String',num2str(Ymin));
    Ymin=str2num(get(handles.Y_min,'String')); Ymax=str2num(get(handles.Y_max,'String'));
end

YawV=linspace(Ymin-1,Ymax+1,round(30*(2+(Ymax-Ymin))));
ThetaV=linspace(Tmin-2.5,Tmax+2.5,round(10*(5+Tmax-Tmin)));

MaxOrder=str2num(get(handles.MaxOrder,'String'));
MaxSumSquare=str2num(get(handles.MaxSumSquare,'String'));

KEEP=find((handles.MaxAbs<=MaxOrder) & (handles.MaxSumSqr<=MaxSumSquare));

xlim(handles.ax_1,[Tmin,Tmax]); ylim(handles.ax_1,[Emin,Emax]);
xlim(handles.ax_2,[Ymin,Ymax]); ylim(handles.ax_2,[Emin,Emax]);
incremental_line=0;

% Offset_Vector=[handles.T,handles.Y,handles.R,handles.ey,handles.ez,handles.ex,handles.eT0];
% Theta=Theta-handles.TMisreading;
% Yaw=Yaw-handles.YMisreading;

MAT=handles.lattice_constant(get(handles.Material,'Value'));

for i1=1:length(KEEP)
    plane=handles.Giaciture(KEEP(i1),1:3);
    [col, sty, lin]=CrystalGUI_LineType(plane);
    incremental_line=incremental_line+1;
    
    [photon_energy_ev1]=CrystalGUI_NotchEnergy(Theta, YawV, plane, handles.Offset_Vector, MAT, 1);
    [photon_energy_ev2]=CrystalGUI_NotchEnergy(ThetaV, Yaw ,plane, handles.Offset_Vector, MAT, 1);
    handles.Pointers.UL(incremental_line)=plot(handles.ax_1,ThetaV,photon_energy_ev2,'Color',col,'Linestyle',sty,'linewidth',lin);
    set(handles.Pointers.UL(incremental_line),'UserData',plane);
    handles.Pointers.UR(incremental_line)=plot(handles.ax_2,YawV,photon_energy_ev1,'Color',col,'Linestyle',sty,'linewidth',lin);
    set(handles.Pointers.UR(incremental_line),'UserData',plane);
    if(incremental_line==1)
            hold(handles.ax_1,'on')
            hold(handles.ax_2,'on')
    end
end
%
set(handles.Tfixed,'String',['Theta = ',get(handles.V_T,'String')]);
set(handles.Yfixed,'String',['Yaw = ',get(handles.V_Y,'String')]);

% Save plane of handles into somewhere userdata....
TBSE1=get(handles.ax_1,'parent');
TBSE2=get(handles.ax_2,'parent');
set(TBSE1,'UserData',[handles.P1_E,handles.P1;handles.P2_E,handles.P2 ;handles.P3_E ,handles.P3]);
set(TBSE2,'UserData',[handles.P1_E,handles.P1;handles.P2_E,handles.P2 ;handles.P3_E ,handles.P3]);

hcmenu = uicontextmenu;
hcb1 = ['CrystalGUI_setplane(get(gco,''UserData''),1,get(gco,''parent''))'];
hcb2 = ['CrystalGUI_setplane(get(gco,''UserData''),2,get(gco,''parent''))'];
hcb3 = ['CrystalGUI_setplane(get(gco,''UserData''),3,get(gco,''parent''))'];

item1 = uimenu(hcmenu, 'Label', 'to plane 1', 'Callback', hcb1);
item2 = uimenu(hcmenu, 'Label', 'to plane 2', 'Callback', hcb2);
item3 = uimenu(hcmenu, 'Label', 'to plane 3',  'Callback', hcb3);

hlines = findall(handles.ax_1,'Type','line');
for line = 1:length(hlines)
    set(hlines(line),'uicontextmenu',hcmenu)
end

hlines = findall(handles.ax_2,'Type','line');
for line = 1:length(hlines)
    set(hlines(line),'uicontextmenu',hcmenu)
end

xlim(handles.ax_1,[Tmin,Tmax]); ylim(handles.ax_1,[Emin,Emax]);
xlim(handles.ax_2,[Ymin,Ymax]); ylim(handles.ax_2,[Emin,Emax]);

hold(handles.ax_1,'off')
hold(handles.ax_2,'off')
set(handles.ax_2,'Ytick',[])


% --- Executes on button press in Draw_2.
function Draw_2_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off')
set(handles.AngleControlPanel,'visible','on');set(handles.IchBinFaulPanel,'visible','off');set(handles.MovingPanel,'visible','off')
handles.WorkingAngles = str2num([get(handles.V_T,'String'),get(handles.V_Y,'String'),get(handles.V_R,'String')]);
hold(handles.ax_3,'off'); hold(handles.ax_4,'off');
cla(handles.ax_3); cla(handles.ax_4);
Theta=str2num(get(handles.V_T,'String'));
Yaw=str2num(get(handles.V_Y,'String'));
% Roll=str2num(get(handles.V_R,'String'));
set(handles.thetval,'String',num2str(Theta)); set(handles.thetval,'Userdata',Theta);
set(handles.yawval,'String',num2str(Yaw)); set(handles.yawval,'Userdata',Yaw);
% set(handles.rollval,'String',num2str(Roll)); set(handles.rollval,'Userdata',Roll);

YawV=linspace(-20,20,600);
ThetaV=linspace(0,180,1800);

Tmin=str2num(get(handles.T_min,'String')); Tmax=str2num(get(handles.T_max,'String'));
Ymin=str2num(get(handles.Y_min,'String')); Ymax=str2num(get(handles.Y_max,'String'));
Emin=str2num(get(handles.E_min,'String')); Emax=str2num(get(handles.E_max,'String'));

if(Emax<Emin)
    set(handles.E_min,'String',num2str(Emax)); set(handles.E_max,'String',num2str(Emin));
    Emin=str2num(get(handles.E_min,'String')); Emax=str2num(get(handles.E_max,'String'));
end
if(Tmax<Tmin)
    set(handles.T_min,'String',num2str(Tmax));
    set(handles.T_max,'String',num2str(Tmin));
    Tmin=str2num(get(handles.T_min,'String')); Tmax=str2num(get(handles.T_max,'String'));
end

if(Ymax<Ymin)
    set(handles.Y_min,'String',num2str(Ymax));
    set(handles.Y_max,'String',num2str(Ymin));
    Ymin=str2num(get(handles.Y_min,'String')); Ymax=str2num(get(handles.Y_max,'String'));
end

xlim(handles.ax_3,[Tmin,Tmax]); ylim(handles.ax_3,[Emin,Emax]);
xlim(handles.ax_4,[Ymin,Ymax]); ylim(handles.ax_4,[Emin,Emax]);

MAT=handles.lattice_constant(get(handles.Material,'Value'));

colori=[0,0,0;1,0,0;0,0,1];
Colore_Ph=zeros(3,1); Colore_Wl=zeros(3,1);
for II=1:3
    if(eval(['get(handles.P',char(48+II),',''Value'')']))
        eval(['plane=str2num(get(handles.P',char(48+II),'_E,''String''));'])
        piano{II}=plane;
        eval(['set(handles.LINEA',char(48+II),',''String'',''Plane ',char(48+II),' = [',num2str(piano{II}),']'')'])
        %['set(handles.LINEA',char(48+II),',''Userdata'',[',num2str(piano{II}),'])']
        eval(['set(handles.LINEA',char(48+II),',''Userdata'',[',num2str(piano{II}),'])'])
        
        [photon_energy_ev1]=CrystalGUI_NotchEnergy(Theta, YawV, plane, handles.Offset_Vector, MAT, 1);
        [photon_energy_ev2]=CrystalGUI_NotchEnergy(ThetaV, Yaw ,plane, handles.Offset_Vector, MAT, 1);
        
%         [photon_energy_ev1]=FormulaFinaleEnergia(Theta,YawV,plane,handles.roll_off, handles.theta_off, handles.yaw_off, handles.lattice_constant(get(handles.Material,'Value')));
%         [photon_energy_ev2]=FormulaFinaleEnergia(ThetaV,Yaw,plane,handles.roll_off, handles.theta_off, handles.yaw_off, handles.lattice_constant(get(handles.Material,'Value')));
%         [photon_energy_ev1]=FJD_F_matrice(Theta, YawV, Roll, plane, [handles.theta_off,handles.yaw_off,handles.roll_off] ,handles.lattice_constant(get(handles.Material,'Value')));
%         [photon_energy_ev2]=FJD_F_matrice(ThetaV, Yaw, Roll, plane, [handles.theta_off,handles.yaw_off,handles.roll_off] ,handles.lattice_constant(get(handles.Material,'Value')));
        plot(handles.ax_3,ThetaV,photon_energy_ev2,'Color',colori(II,:),'linewidth',2);
        plot(handles.ax_4,YawV,photon_energy_ev1,'Color',colori(II,:),'linewidth',2);
        hold(handles.ax_3,'on'); hold(handles.ax_4,'on');
        [Colore_Ph(II),Colore_Wl(II)]= CrystalGUI_NotchEnergy(Theta, Yaw ,plane, handles.Offset_Vector, MAT, 1); %FormulaFinaleEnergia(Theta,Yaw,plane,handles.roll_off, handles.theta_off, handles.yaw_off, handles.lattice_constant(get(handles.Material,'Value')));
%         [Colore_Ph(II),Colore_Wl(II)]=FJD_F_matrice(Theta, Yaw, Roll, plane, [handles.theta_off,handles.yaw_off,handles.roll_off] ,handles.lattice_constant(get(handles.Material,'Value')));
    else
        eval(['set(handles.LINEA',char(48+II),',''String'','' '')'])
        eval(['set(handles.LINEA',char(48+II),',''Userdata'',[nan,nan,nan,])'])
    end
end
xlim(handles.ax_3,[Tmin,Tmax]); ylim(handles.ax_3,[Emin,Emax]);
xlim(handles.ax_4,[Ymin,Ymax]); ylim(handles.ax_4,[Emin,Emax]);
xlabel(handles.ax_3,'Theta');%ylabel(handles.ax_3,'Energy');
xlabel(handles.ax_4,'Yaw');ylabel(handles.ax_4,'Energy');
grid(handles.ax_3,'on'); grid(handles.ax_4,'on');

%Update Wavelengths
for II=1:3
    if(Colore_Ph(II))
        OUT=CrystalGUI_Partials_and_scans([Theta, Yaw], piano{II}, handles.Offset_Vector, MAT);
        colonna={num2str(Colore_Ph(II),'%7.2f'),num2str(Colore_Wl(II)*10^9,'%7.4f'),num2str(OUT.in_dy1,'%7.3f'),num2str(OUT.in_dt1,'%7.3f')};
        eval(['pointer=handles.RES_C',char(48+II),';']);
        set(pointer,'String',colonna,'FontName','Times New Roman','FontSize',14)
        set(handles.SearchAngles147,'Enable','on') 
        if(II==1)
            set(handles.C_1x,'UserData',Colore_Ph(1));
        end
        if(II==2)
            set(handles.C_2x,'UserData',Colore_Ph(2));
        end
    else
        colonna='';
        eval(['pointer=handles.RES_C',char(48+II),';']);
        set(pointer,'String',colonna,'FontName','Times New Roman','FontSize',14)
    end
end

if(Colore_Ph(1) && Colore_Ph(2))
    OUT=CrystalGUI_Partials_and_scans([Theta, Yaw],[piano{1};piano{2}], handles.Offset_Vector, MAT);
    set(handles.X_1,'String',num2str(((Colore_Ph(2)+Colore_Ph(1))/2),'%7.3f'),'FontName','Times New Roman','FontSize',14)
    set(handles.X_2,'String',num2str(((Colore_Ph(2)-Colore_Ph(1))),'%7.3f'),'FontName','Times New Roman','FontSize',14)
    set(handles.X_3,'String',num2str(((Colore_Ph(1))),'%7.3f'),'FontName','Times New Roman','FontSize',14)
    set(handles.Color12Scan147,'Enable','on')
    set(handles.Color12Scan147,'String','Two Color Scans')
    set(handles.Color12Scan147,'Userdata',2)
    set(handles.Y_1,'String',num2str(OUT.Coeff_Center_Still,'%9.6f'),'FontName','Times New Roman','FontSize',14)
    set(handles.Y_2,'String',num2str(OUT.Coeff_difference_Still,'%9.6f'),'FontName','Times New Roman','FontSize',14)
    set(handles.Y_3,'String',num2str(OUT.Color1_still,'%9.6f'),'FontName','Times New Roman','FontSize',14)    
elseif(Colore_Ph(1))
    set(handles.Color12Scan147,'Enable','on')
    set(handles.Color12Scan147,'String','Single Color Scan')
    set(handles.X_1,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.X_2,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.X_3,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Y_1,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Y_2,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Y_3,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Color12Scan147,'Userdata',1)
else
    set(handles.Color12Scan147,'Enable','off')
    set(handles.Color12Scan147,'String','No color on plane 1')
    set(handles.X_1,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.X_2,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.X_3,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Y_1,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Y_2,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Y_3,'String',' ','FontName','Times New Roman','FontSize',14)
    set(handles.Color12Scan147,'Userdata',0)
end

% 
% set(handles.Testo_X,'String',{'l','E','dE/dy','dE/dq'},'FontName','Symbol')


% --- Executes on button press in Color12Scan147.
function Color12Scan147_Callback(hObject, eventdata, handles)

Current_SNO=upper(get(handles.Tabula,'visible'));
if(strcmp(Current_SNO,'ON'))
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
    set(handles.AngleControlPanel,'visible','on');set(handles.IchBinFaulPanel,'visible','off');set(handles.MovingPanel,'visible','off')
else
    set(handles.AngleControlPanel,'visible','on');set(handles.IchBinFaulPanel,'visible','off');set(handles.MovingPanel,'visible','off')
    set(handles.BasicLineSearchPanel,'visible','off'); set(handles.Selected_Lines_Panel,'visible','off');
    set(handles.Tabula,'visible','on'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','on');
    set(handles.ISS_Panel,'Visible','off')
    ScanValue=get(handles.Color12Scan147,'Userdata');
    set(handles.SC_StartScanPanel,'visible','off')
    if(ScanValue==1)
        
        set(handles.popupmenu2,'String',{'Move Color 1 on path'})
        set(handles.popupmenu2,'Value',1)
        Current=get(handles.C_1x,'UserData');
        set(handles.Input1,'String',['[',num2str(Current),',',num2str(Current),']'])
        set(handles.Input3,'String','5')
        set(handles.Input2,'Visible','off')
        set(handles.labell2,'Visible','off')
    elseif(ScanValue==2)
        set(handles.popupmenu2,'String',{'Scan Separation, Center Fixed','Scan Center, Separation Fixed','Scan Color 2, Color 1 Fixed','Move Color 1 and 2 on path'})
        set(handles.popupmenu2,'Value',1)
        Center=get(handles.X_1,'String');
        set(handles.labell1,'String','Center')
        set(handles.labell2,'String','Separation Range')
        set(handles.Input1,'String',Center)
        set(handles.Input2,'String','[-5,5]')
        set(handles.Input3,'String','5')
        set(handles.Input2,'Visible','on')
        set(handles.labell2,'Visible','on')
    end
end



% --- Executes on button press in SC_ClosePanelButton.
function SC_ClosePanelButton_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off')

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
Menu=get(handles.popupmenu2,'Value');
Center=get(handles.X_1,'String');
Separation=get(handles.X_2,'String');
Color1=get(handles.X_3,'String');
ScanValue=get(handles.Color12Scan147,'Userdata');

if(ScanValue==2)
    set(handles.labell2,'visible','on')
    set(handles.Input2,'visible','on')
    switch(Menu)
        case 1
            set(handles.labell1,'String','Center')
            set(handles.labell2,'String','Separation Range')
            set(handles.Input1,'String',Center)
            set(handles.Input2,'String','[-5,5]')
            set(handles.Input3,'String','5')
        case 2
            set(handles.labell1,'String','Separation')
            set(handles.labell2,'String','Center Range')
            set(handles.Input1,'String',Separation)
            set(handles.Input2,'String',[Center,'+[-5,5]'])
            set(handles.Input3,'String','5')
        case 3
            set(handles.labell1,'String','Color 1')
            set(handles.labell2,'String','Color 2 Range')
            set(handles.Input1,'String',Color1)
            set(handles.Input2,'String','[-5,5]')
            set(handles.Input3,'String','5')
        case 4
            Current1=get(handles.C_1x,'UserData');
            Current2=get(handles.C_2x,'UserData');
            set(handles.labell1,'String','Color 1 path')
            set(handles.labell2,'String','Color 2 path')
            set(handles.Input1,'String',['[',num2str(Current1,6),',',num2str(Current1,6),']'])
            set(handles.Input2,'String',['[',num2str(Current2,6),',',num2str(Current2,6),']'])
            set(handles.Input3,'String','5')
    end

end
if(ScanValue==1)
    set(handles.labell1,'String','Color 1 path')
    set(handles.labell2,'visible','off')
    set(handles.Input2,'visible','off')
    Current=get(handles.C_1x,'UserData');
    set(handles.Input1,'String',['[',num2str(Current,6),',',num2str(Current,6),']'])
    set(handles.Input3,'String','5')
end


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



function Input1_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);

Menu=get(handles.popupmenu2,'Value');
Center=get(handles.X_1,'String');
Separation=get(handles.X_2,'String');
Color1=get(handles.X_3,'String');
ScanValue=get(handles.Color12Scan147,'Userdata');
if(ScanValue==2)
switch(Menu)
    case 1
        
        if (numel(numread)~=1)
            set(hObject,'String',Center);
            return
        end
        if((numread<2000) || (numread>50000))
            set(hObject,'String',Center);
            return
        end
        if (isnan(numread))
            set(hObject,'String',Center);
            return
        end
      
    case 2
        if (numel(numread)~=1)
            set(hObject,'String',Separation);
            return
        end
        if((numread<-1000) || (numread>1000))
            set(hObject,'String',Separation);
            return
        end
        if (isnan(numread))
            set(hObject,'String',Separation);
            return
        end
        
    case 3
        if (numel(numread)~=1)
            set(hObject,'String',Color1);
            return
        end
        if((numread<-1000) || (numread>1000))
            set(hObject,'String',Color1);
            return
        end
        if (isnan(numread))
            set(hObject,'String',Color1);
            return
        end

end
end

% --- Executes during object creation, after setting all properties.
function Input1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Input2_Callback(hObject, eventdata, handles)
Menu=get(handles.popupmenu2,'Value');
Center=get(handles.X_1,'String');
Separation=get(handles.X_2,'String');
Color1=get(handles.X_3,'String');

switch(Menu)
    case 1
        read=get(hObject,'String');
            numread=str2num(read);
            if (numel(numread)~=2)
                set(hObject,'String','[-5,5]');
                return
            end
            if (isnan(sum(numread)))
                set(hObject,'String','[-5,5]');
                return
            end
            if ((sum(abs(numread)))>1000000)
                set(hObject,'String','[-5,5]');
                return
            end
    case 2
            read=get(hObject,'String');
            numread=str2num(read);
            if (numel(numread)~=2)
                set(hObject,'String',[Center,'+[-5,5]']);
                return
            end
            if (isnan(sum(numread)))
                set(hObject,'String',[Center,'+[-5,5]']);
                return
            end
            if ((sum(abs(numread)))>1000000)
                set(hObject,'String',[Center,'+[-5,5]']);
                return
            end
    case 3
            read=get(hObject,'String');
            numread=str2num(read);
            if (numel(numread)~=2)
                set(hObject,'String','[-5,5]');
                return
            end
            if (isnan(sum(numread)))
                set(hObject,'String','[-5,5]');
                return
            end
            if ((sum(abs(numread)))>1000000)
                set(hObject,'String','[-5,5]');
                return
            end
end

% --- Executes during object creation, after setting all properties.
function Input2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_K_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','3.5');
    return
end
if((numread<3.4) || (numread>3.55))
    set(hObject,'String','3.5');
    return
end
if (isnan(numread))
    set(hObject,'String','3.5');
    return
end
% --- Executes during object creation, after setting all properties.
function Edit_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Input3_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','5');
    return
end
if((numread<2) || (numread>100))
    set(hObject,'String','5');
    return
end
if (isnan(numread))
    set(hObject,'String','5');
    return
end
set(hObject,'String',num2str(round(numread)));

% --- Executes during object creation, after setting all properties.
function Input3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EvalScanPoints.
function EvalScanPoints_Callback(hObject, eventdata, handles)
ScanValue=get(handles.Color12Scan147,'Userdata');
if(ScanValue==2)
plane1=get(handles.LINEA1,'Userdata');
plane2=get(handles.LINEA2,'Userdata');

T0=str2num(get(handles.thetval,'String'));
Y0=str2num(get(handles.yawval,'String'));
% R0=str2num(get(handles.V_R,'String'));

Input1=str2num(get(handles.Input1,'String'));
Input2=str2num(get(handles.Input2,'String'));
Input3=str2num(get(handles.Input3,'String'));
Input4=str2num(get(handles.Edit_K,'String'));

CEN=str2num(get(handles.X_1,'String'));
SEP=str2num(get(handles.X_2,'String'));
C1=str2num(get(handles.X_3,'String'));

Lungo1=get(handles.RES_C1,'String');
Lungo2=get(handles.RES_C2,'String');

d1dy=str2num(Lungo1{3});
d1dt=str2num(Lungo1{4});

d2dy=str2num(Lungo2{3});
d2dt=str2num(Lungo2{4});

Tipo_Di_Scan=get(handles.popupmenu2,'Value');

switch(Tipo_Di_Scan)
    case 1
        Input2=linspace(Input2(1),Input2(2),Input3);
        E1=Input1-Input2/2;
        E2=Input1+Input2/2;
        Center_DeltaRat=str2num(get(handles.Y_1,'String'));
        DeltaE2=CEN+SEP/2-E2;
        theta_guess=DeltaE2/(d2dt+Center_DeltaRat*d2dy);
        yaw_guess=theta_guess*Center_DeltaRat;
        theta_guess=T0-theta_guess;
        yaw_guess=Y0-yaw_guess;
    case 2
        Input2=linspace(Input2(1),Input2(2),Input3);
        E1=Input2-Input1/2;
        E2=Input2+Input1/2;
        Separation_DeltaRat=str2num(get(handles.Y_2,'String'));
        DeltaE2=CEN+SEP/2-E2;
        theta_guess=DeltaE2/(d2dt+Separation_DeltaRat*d2dy);
        yaw_guess=theta_guess*Separation_DeltaRat;
        theta_guess=T0-theta_guess;
        yaw_guess=Y0-yaw_guess;
    case 3
        Input2=linspace(Input2(1),Input2(2),Input3);
        E2=Input1+Input2;
        E1=Input1*ones(size(E2));
        C1Fixed_DeltaRat=str2num(get(handles.Y_3,'String'));
        DeltaE2=CEN+SEP/2-E2;
        theta_guess=DeltaE2/(d2dt+C1Fixed_DeltaRat*d2dy);
        yaw_guess=theta_guess*C1Fixed_DeltaRat;
        theta_guess=T0-theta_guess;
        yaw_guess=Y0-yaw_guess;
    case 4
        E1=linspace(Input1(1),Input1(2),Input3);
        E2=linspace(Input2(1),Input2(2),Input3);
        theta_guess=ones(size(E1))*T0;
        yaw_guess=ones(size(E1))*Y0;
        
end
Mat=handles.lattice_constant(get(handles.Material,'Value'));
funzionale_da_minimizzare=inline('sum( ( (E1 - CrystalGUI_NotchEnergy(X(1), X(2), plane1, Offset_Vector ,Mat, Norder) )^2   + (E2 - CrystalGUI_NotchEnergy(X(1), X(2), plane2, Offset_Vector ,Mat, Norder) )^2  ) )','X','plane1','plane2','Offset_Vector','Mat','E1','E2','Norder');

h_planck=4.135667516*10^-15;
c_luce=299792458;
GammaTheor=sqrt(CEN/(h_planck*c_luce)/2*0.03*(1+Input4^2/2));
BeamEnergyTheor=0.510998910*GammaTheor;
CenterDestinationGamma=sqrt(((E1+E2)/2)/(h_planck*c_luce)/2*0.03*(1+Input4^2/2));
BeamEnergyDestinationTheor=0.510998910*CenterDestinationGamma;

try
    verniercurrent=lcaGetSmart(handles.VernierPV);
catch ME
    verniercurrent=0;
end

for KK=1:length(theta_guess) %non linear refinement from theta_guess and yaw_guess
%     [photon_energy_ev1]=FJD_F_matrice(X(1), X(2), R0, plane1, OFV ,Mat);
%     [photon_energy_ev2]=FJD_F_matrice(X(1), X(2), R0, plane2, OFV ,Mat);
    if(KK==1)
        XX = fminsearch(@(X) funzionale_da_minimizzare(X,plane1,plane2,handles.Offset_Vector,Mat,E1(KK),E2(KK),1),[theta_guess(KK),yaw_guess(KK)]);
    else
        XX = fminsearch(@(X) funzionale_da_minimizzare(X,plane1,plane2,handles.Offset_Vector,Mat,E1(KK),E2(KK),1),[Theta_Makina,Yaw_Makina]);
    end
    Theta_Makina= XX(1);
    Yaw_Makina= XX(2);

    Finale1=CrystalGUI_NotchEnergy(Theta_Makina, Yaw_Makina, plane1, handles.Offset_Vector ,Mat, 1);
    Finale2=CrystalGUI_NotchEnergy(Theta_Makina, Yaw_Makina, plane2, handles.Offset_Vector ,Mat, 1);
    
    Col3{KK}=Finale1;
    Col4{KK}=Finale2;
    Col1{KK}=Theta_Makina;
    Col2{KK}=Yaw_Makina;
    
    DeltaECenter=CEN-(Finale1+Finale2)/2;
    
    Col5{KK}=round(100*(BeamEnergyDestinationTheor(KK)-BeamEnergyTheor+verniercurrent))/100;
end

set(handles.Scan_res1,'String',Col1);
set(handles.Scan_res2,'String',Col2);
set(handles.Scan_res3,'String',Col3);
set(handles.Scan_res4,'String',Col4);
set(handles.Scan_res5,'String',Col5);

    if(prod((cell2mat(Col1)>=45).*(cell2mat(Col1)<=90).*(cell2mat(Col2)>=-2.45).*(cell2mat(Col2)<=2.45)))
        set(handles.SC_StartScanPanel,'visible','on')
        handles.CurrentScanTheta=cell2mat(Col1);
        handles.CurrentScanYaw=cell2mat(Col2);
        handles.CurrentScanVernier=cell2mat(Col5);
        handles.CurrentScanEnergy=cell2mat(Col3);
%         Theta=handles.CurrentScanTheta;
%         Yaw=handles.CurrentScanYaw;
%         Energy=handles.CurrentScanEnergy;
%         save TSC plane1 Theta Yaw Energy plane2
        guidata(hObject, handles);
        set(handles.SC_Start,'Backgroundcolor',handles.ColorON);
        set(handles.SC_Start,'enable','on');
        set(handles.SC_Stop,'enable','off');
        set(handles.SC_Stop,'BackGroundColor',handles.ColorIDLE);
        set(handles.SC_Theta,'string','....');
        set(handles.SC_Yaw,'string','....');
    else
        set(handles.SC_StartScanPanel,'visible','off')
    end
end

%1valore solo
if(ScanValue==1)
plane1=get(handles.LINEA1,'Userdata');

T0=str2num(get(handles.thetval,'String'));
Y0=str2num(get(handles.yawval,'String'));

Input1=str2num(get(handles.Input1,'String'));
Input3=str2num(get(handles.Input3,'String'));
Input4=str2num(get(handles.Edit_K,'String'));

        E1=linspace(Input1(1),Input1(2),Input3);
        theta_guess=ones(size(E1))*T0;
        yaw_guess=ones(size(E1))*Y0;


Mat=handles.lattice_constant(get(handles.Material,'Value'));
funzionale_da_minimizzare=inline('sum( ( (E1 - CrystalGUI_NotchEnergy(X(1), YFixed, plane1, Offset_Vector ,Mat, Norder) )^2 ) )','X','plane1','Offset_Vector','Mat','E1','Norder','YFixed');

h_planck=4.135667516*10^-15;
c_luce=299792458;
GammaTheor=sqrt(get(handles.C_1x,'UserData')/(h_planck*c_luce)/2*0.03*(1+Input4^2/2));
BeamEnergyTheor=0.510998910*GammaTheor;
CenterDestinationGamma=sqrt(((E1))/(h_planck*c_luce)/2*0.03*(1+Input4^2/2));
BeamEnergyDestinationTheor=0.510998910*CenterDestinationGamma;

try
    verniercurrent=lcaGetSmart(handles.VernierPV);
catch ME
    verniercurrent=0;
end

for KK=1:length(theta_guess) %non linear refinement from theta_guess and yaw_guess
%     [photon_energy_ev1]=FJD_F_matrice(X(1), X(2), R0, plane1, OFV ,Mat);
%     [photon_energy_ev2]=FJD_F_matrice(X(1), X(2), R0, plane2, OFV ,Mat);
    if(KK==1)
        XX = fminsearch(@(X) funzionale_da_minimizzare(X,plane1,handles.Offset_Vector,Mat,E1(KK),1,yaw_guess(KK)),theta_guess(KK));
    else
        XX = fminsearch(@(X) funzionale_da_minimizzare(X,plane1,handles.Offset_Vector,Mat,E1(KK),1,yaw_guess(KK)),Theta_Makina);
    end
    Theta_Makina= XX(1);
    Yaw_Makina= yaw_guess(KK);

    Finale1=CrystalGUI_NotchEnergy(Theta_Makina, Yaw_Makina, plane1, handles.Offset_Vector ,Mat, 1);
    
    Col3{KK}=Finale1;
    
    Col1{KK}=Theta_Makina;
    Col2{KK}=Yaw_Makina;
    
    DeltaECenter=get(handles.C_1x,'UserData')-Finale1;
    
    Col5{KK}=round(100*(BeamEnergyDestinationTheor(KK)-BeamEnergyTheor+verniercurrent))/100;
end

set(handles.Scan_res1,'String',Col1);
set(handles.Scan_res2,'String',Col2);
set(handles.Scan_res3,'String',Col3);
set(handles.Scan_res4,'String','');
set(handles.Scan_res5,'String',Col5);

    if(prod((cell2mat(Col1)>=45).*(cell2mat(Col1)<=90).*(cell2mat(Col2)>=-2.45).*(cell2mat(Col2)<=2.45)))
        set(handles.SC_StartScanPanel,'visible','on')
        handles.CurrentScanTheta=cell2mat(Col1);
        handles.CurrentScanYaw=cell2mat(Col2);
        handles.CurrentScanVernier=cell2mat(Col5);
        handles.CurrentScanEnergy=cell2mat(Col3);
%         Theta=handles.CurrentScanTheta;
%         Yaw=handles.CurrentScanYaw;
%         Energy=handles.CurrentScanEnergy;
%         save TSC plane1 Theta Yaw Energy
        guidata(hObject, handles);
        set(handles.SC_Start,'Backgroundcolor',handles.ColorON);
        set(handles.SC_Start,'enable','on');
        set(handles.SC_Stop,'enable','off');
        set(handles.SC_Stop,'BackGroundColor',handles.ColorIDLE);
        set(handles.SC_Theta,'string','....');
        set(handles.SC_Yaw,'string','....');
    else
        set(handles.SC_StartScanPanel,'visible','off')
    end

end


% --- Executes on button press in Recall.
function Recall_Callback(hObject, eventdata, handles)
Current_SRA=upper(get(handles.SaveRecall,'visible'));
for II=1:numel(handles.Configuration)
   handles.ConfNames{II+1} = handles.Configuration(II).name;
end
set(handles.srl,'String',handles.ConfNames);
set(handles.srl,'Value',1);
if(strcmp(Current_SRA,'ON')) 
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
else
    % Cerca una configurazione in macchina nel pannello piccolo, se non
    % c'e', metti i valori attualmente in macchina di base e chiama la
    % configurazione nuova "New_Configuration"
    % disabilita Recall
    % disabilita Delete
    % se modifica disabilita Delete e disabilita Richiama
    att=get(handles.thetval,'String');
    if(numel(str2num(att))~=1)
        Cur_theta=get(handles.V_T,'String');
        Cur_yaw=get(handles.V_Y,'String');
%         Cur_roll=get(handles.V_R,'String');
        Cur_plane1='';
        Cur_plane2='';
        Cur_plane3='';
    else
        Cur_plane1=get(handles.LINEA1,'String');Cur_plane1=Cur_plane1(11:end);
        Cur_plane2=get(handles.LINEA2,'String');Cur_plane2=Cur_plane2(11:end);
        Cur_plane3=get(handles.LINEA3,'String');Cur_plane3=Cur_plane3(11:end);
        Cur_theta=str2num(get(handles.thetval,'String'));
        Cur_yaw=str2num(get(handles.yawval,'String'));
        Cur_roll=str2num(get(handles.rollval,'String'));
    end
    Cur_e1='';
    Cur_e2='';
    Cur_e3='';
    nowis=clock;
    anno=num2str(nowis(1),'%.4d');
    mese=num2str(nowis(2),'%.2d');
    giorno=num2str(nowis(3),'%.2d');
    datestring=[anno,'/',mese,'/',giorno];
    set(handles.sr2,'String',Cur_theta); set(handles.sr3,'String',Cur_yaw); %set(handles.sr4,'String',Cur_to); set(handles.srn1,'String',Cur_yo);
    %set(handles.srn2,'String',Cur_ey); set(handles.srn3,'String',Cur_ez); set(handles.srn4,'String',Cur_ex); set(handles.srn5,'String',Cur_eT0);
    %set(handles.sro1,'String',Cur_misT); set(handles.sro2,'String',Cur_misY); set(handles.sro3,'String',Cur_ro);
    set(handles.sr5,'String',Cur_plane1); set(handles.sr6,'String',Cur_plane2); set(handles.sr7,'String',Cur_plane3);
    set(handles.sr8,'String',Cur_e1); set(handles.sr9,'String',Cur_e2); set(handles.sr10,'String',Cur_e3);
    set(handles.sr11,'String',datestring);
    
    set(handles.BasicLineSearchPanel,'visible','off'); set(handles.Selected_Lines_Panel,'visible','on');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','on');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');  
    set(handles.ISS_Panel,'Visible','off')
end

% --- Executes on button press in SearchAngles147.
function SearchAngles147_Callback(hObject, eventdata, handles)
Current_SFA=upper(get(handles.SFA,'visible'));
%get(handles.LINEA2,'Userdata')
if(strcmp(Current_SFA,'ON')) 
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
    set(handles.AngleControlPanel,'visible','on');set(handles.IchBinFaulPanel,'visible','off');set(handles.MovingPanel,'visible','off')
else
    set(handles.AngleControlPanel,'visible','on');set(handles.IchBinFaulPanel,'visible','off');set(handles.MovingPanel,'visible','off')
    Res1=get(handles.RES_C1,'String');
    Res2=get(handles.RES_C2,'String');
    Res3=get(handles.RES_C3,'String');
    if(numel(Res1))
        set(handles.SAC_e1,'String',Res1{1});set(handles.SAC_e1,'visible','on')
        set(handles.text107,'visible','on')
        set(handles.text135,'visible','on')
    else
        set(handles.SAC_e1,'visible','off')
        set(handles.text107,'visible','off')
        set(handles.text135,'visible','off')
    end
    if(numel(Res2))
        set(handles.SAC_e2,'String',Res2{1});set(handles.SAC_e2,'visible','on')
        set(handles.text108,'visible','on')
        set(handles.text136,'visible','on')
    else
        set(handles.SAC_e2,'visible','off')
        set(handles.text108,'visible','off')
        set(handles.text136,'visible','off')
    end
    if(numel(Res3))
        set(handles.SAC_e3,'String',Res3{1});set(handles.SAC_e3,'visible','on')
        set(handles.text109,'visible','on')
        set(handles.text137,'visible','on')
    else
        set(handles.SAC_e3,'visible','off')
        set(handles.text109,'visible','off')
        set(handles.text137,'visible','off')
    end
    
    set(handles.SAC_1,'String',''); set(handles.SAC_2,'String',''); set(handles.SAC_3,'String','');
    set(handles.SAC_4,'String',''); set(handles.SAC_5,'String',''); set(handles.SAC_6,'String','');
    set(handles.BasicLineSearchPanel,'visible','off'); set(handles.Selected_Lines_Panel,'visible','off');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
    set(handles.SFA,'visible','on'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','on'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
    set(handles.SAC_SET,'enable','off'); set(handles.SAC_BACK,'enable','off');
end


% --- Executes on button press in SAC_ClosePanel.
function SAC_ClosePanel_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off')

function SAC_e1_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','7125');
    return
end
if((numread<0) || (numread>50000))
    set(hObject,'String','7125');
    return
end
if (isnan(numread))
    set(hObject,'String','7125');
    return
end

% --- Executes during object creation, after setting all properties.
function SAC_e1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SAC_e1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SAC_e2_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','7125');
    return
end
if((numread<0) || (numread>50000))
    set(hObject,'String','7125');
    return
end
if (isnan(numread))
    set(hObject,'String','7125');
    return
end
% --- Executes during object creation, after setting all properties.
function SAC_e2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SAC_e2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SAC_e3_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','7125');
    return
end
if((numread<0) || (numread>50000))
    set(hObject,'String','7125');
    return
end
if (isnan(numread))
    set(hObject,'String','7125');
    return
end

% --- Executes during object creation, after setting all properties.
function SAC_e3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SAC_e3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SAC_CalculateButton.
function SAC_CalculateButton_Callback(hObject, eventdata, handles)
plane1=get(handles.LINEA1,'Userdata');
plane2=get(handles.LINEA2,'Userdata');
plane3=get(handles.LINEA3,'Userdata');
Theta_machine=str2num(get(handles.thetval,'String'));
Yaw_machine=str2num(get(handles.yawval,'String'));
% R0=str2num(get(handles.V_R,'String'));

T0=Theta_machine;
Y0=Yaw_machine;

colori=0;
isIN=[0,0,0];
if(strcmp(get(handles.SAC_e1,'visible'),'on'))
    E(colori+1)=str2num(get(handles.SAC_e1,'String'));
    colori=colori+1;
    piano(colori,1:3)=plane1;
    isIN(1)=1;
end
    
if(strcmp(get(handles.SAC_e2,'visible'),'on'))
    E(colori+1)=str2num(get(handles.SAC_e2,'String'));
    colori=colori+1;
    piano(colori,1:3)=plane2;
    isIN(2)=1;
end

if(colori<2)
   if(strcmp(get(handles.SAC_e3,'visible'),'on'))
        E(colori+1)=str2num(get(handles.SAC_e3,'String'));
        colori=colori+1;
        piano(colori,1:3)=plane3;
   end
else
    if(strcmp(get(handles.SAC_e3,'visible'),'on'))
        isIN(3)=1;
    end
end

Mat=handles.lattice_constant(get(handles.Material,'Value'));
switch(colori)
    case 0
        return
    case 1
        funzionale_da_minimizzare_singolo=inline('sum( ( (E1 - CrystalGUI_NotchEnergy(X(1), Y0, plane1, Offset_Vector ,Mat , Ordern) )^2  ) )','X','Y0','plane1','plane2','Offset_Vector','Mat','E1','Ordern');
        XX = fminsearch(@(X) funzionale_da_minimizzare_singolo(X,Y0,plane1,plane2,handles.Offset_Vector,Mat,E(1),1),T0);
        Out_Y_Makina=Yaw_machine;
        Out_T_Makina=XX;
    case 2
        funzionale_da_minimizzare=inline('sum( ( (E1 - CrystalGUI_NotchEnergy(X(1), X(2), plane1,  Offset_Vector ,Mat , Ordern) )^2   + (E2 - CrystalGUI_NotchEnergy(X(1), X(2), plane2,  Offset_Vector ,Mat , Ordern) )^2  ) )','X','plane1','plane2','Offset_Vector','Mat','E1','E2','Ordern');
        XX = fminsearch(@(X) funzionale_da_minimizzare(X,plane1,plane2,handles.Offset_Vector,Mat,E(1),E(2),1),[T0,Y0]);
        Out_Y_Makina=XX(2);
        Out_T_Makina=XX(1);
end
if(colori)
    set(handles.SAC_1,'String',num2str(Out_T_Makina)); set(handles.SAC_2,'String',num2str(Out_Y_Makina)); %set(handles.SAC_3,'String',num2str(R0));
end

for II=1:3
    if(isIN(II))
        eval(['piano=plane',char(48+II),';']);
        Finale=CrystalGUI_NotchEnergy(Out_T_Makina, Out_Y_Makina, piano, handles.Offset_Vector, Mat,1);
        eval(['set(handles.SAC_',char(48+3+II),',''string'',''',num2str(Finale),''');'])
        F(II)=Finale;
    else
        eval(['set(handles.SAC_',char(48+3+II),',''string'','''');'])
    end
end
% if(abs(F(1)-F(2))<0.01)
    if(isfield(handles,'History'))
       handles.History(end+1).plane1 = plane1;
       handles.History(end).plane2 = plane2;
       handles.History(end).T = Out_Y_Makina;
       handles.History(end).Y = Out_T_Makina; 
    else
       handles.History(1).plane1 = plane1;
       handles.History(1).plane2 = plane2;
       handles.History(1).T = Out_Y_Makina;
       handles.History(1).Y = Out_T_Makina;
    end
    guidata(hObject, handles);
% end
if ((abs(Out_Y_Makina)<=2.46) && (Out_T_Makina>=45) && (Out_T_Makina<=90))
    set(handles.SAC_SET,'enable','on')
else
    set(handles.SAC_SET,'enable','off')
end

% --- Executes on button press in ClosePanelSR.
function ClosePanelSR_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off')

% --- Executes on selection change in srl.
function srl_Callback(hObject, eventdata, handles)
if(get(handles.srl,'Value')==1)
    att=get(handles.thetval,'String');
    if(numel(str2num(att))~=1)
        Cur_theta=get(handles.V_T,'String');
        Cur_yaw=get(handles.V_Y,'String');
%         Cur_roll=get(handles.V_R,'String'); legacy
        Cur_plane1='';
        Cur_plane2='';
        Cur_plane3='';
    else
        Cur_plane1=get(handles.LINEA1,'String');Cur_plane1=Cur_plane1(11:end);
        Cur_plane2=get(handles.LINEA2,'String');Cur_plane2=Cur_plane2(11:end);
        Cur_plane3=get(handles.LINEA3,'String');Cur_plane3=Cur_plane3(11:end);
        Cur_theta=str2num(get(handles.thetval,'String'));
        Cur_yaw=str2num(get(handles.yawval,'String'));
%         Cur_roll=str2num(handles.rollval,'String'); legacy
    end
    Cur_e1='';
    Cur_e2='';
    Cur_e3='';
    nowis=clock;
    anno=num2str(nowis(1),'%.4d');
    mese=num2str(nowis(2),'%.2d');
    giorno=num2str(nowis(3),'%.2d');
    datestring=[anno,'/',mese,'/',giorno];
    set(handles.sr2,'String',Cur_theta); set(handles.sr3,'String',Cur_yaw); %set(handles.sr4,'String',Cur_to); set(handles.srn1,'String',Cur_yo);
%     set(handles.srn2,'String',Cur_ey); set(handles.srn3,'String',Cur_ez); set(handles.srn4,'String',Cur_ex); set(handles.srn5,'String',Cur_eT0);
%     set(handles.sro1,'String',Cur_misT); set(handles.sro2,'String',Cur_misY); set(handles.sro3,'String',Cur_ro);
    set(handles.sr5,'String',Cur_plane1); set(handles.sr6,'String',Cur_plane2); set(handles.sr7,'String',Cur_plane3);
    set(handles.sr8,'String',Cur_e1); set(handles.sr9,'String',Cur_e2); set(handles.sr10,'String',Cur_e3);
    set(handles.sr11,'String',datestring);
else
    TBS=handles.Configuration(get(handles.srl,'Value')-1);
    Cur_theta=num2str(TBS.theta);
    Cur_yaw=num2str(TBS.yaw);
%     Cur_roll=num2str(TBS.R); Legacy
%     Cur_T=num2str(TBS.T);
%     Cur_Y=num2str(TBS.Y);
%     Cur_R=num2str(TBS.R);
    if(numel(TBS.plane1)==3)
        Cur_plane1=['[',num2str(TBS.plane1),']'];
    else
        Cur_plane1='';
    end
    if(numel(TBS.plane2)==3)
        Cur_plane2=['[',num2str(TBS.plane2),']'];
    else
        Cur_plane2='';
    end
    if(numel(TBS.plane3)==3)
        Cur_plane3=['[',num2str(TBS.plane3),']'];
    else
        Cur_plane3='';
    end
    Cur_e1=num2str(TBS.energy1);
    Cur_e2=num2str(TBS.energy2);
    Cur_e3=num2str(TBS.energy3);
%     Cur_Tmisreading=num2str(TBS.Tmis);
%     Cur_Ymisreading=num2str(TBS.Ymis);
    datestring=TBS.date;
%     Cur_ex=num2str(TBS.ex);
%     Cur_ey=num2str(TBS.ey);
%     Cur_ez=num2str(TBS.ez);
%     Cur_eT0=num2str(TBS.eT0);
    
    set(handles.sr2,'String',Cur_theta); set(handles.sr3,'String',Cur_yaw);% set(handles.sr4,'String',Cur_T); set(handles.srn1,'String',Cur_Y);
%     set(handles.sro1,'String',Cur_Tmisreading); set(handles.sro2,'String',Cur_Ymisreading); set(handles.sro3,'String',Cur_R);
%     set(handles.srn2,'String',Cur_ey); set(handles.srn3,'String',Cur_ez); set(handles.srn4,'String',Cur_ex); set(handles.srn5,'String',Cur_eT0);
    set(handles.sr5,'String',Cur_plane1); set(handles.sr6,'String',Cur_plane2); set(handles.sr7,'String',Cur_plane3);
    set(handles.sr8,'String',Cur_e1); set(handles.sr9,'String',Cur_e2); set(handles.sr10,'String',Cur_e3);
    set(handles.sr11,'String',datestring);
end


% --- Executes during object creation, after setting all properties.
function srl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SAVE_CONF.
function SAVE_CONF_Callback(hObject, eventdata, handles)
Tv=str2num(get(handles.sr2,'String')); 
Yv=str2num(get(handles.sr3,'String'));

plane1=str2num(get(handles.sr5,'String'));
plane2=str2num(get(handles.sr6,'String'));
plane3=str2num(get(handles.sr7,'String'));

e1=str2num(get(handles.sr8,'String'));
e2=str2num(get(handles.sr9,'String'));
e3=str2num(get(handles.sr10,'String'));
date=get(handles.sr11,'String');
name=get(handles.sr1,'String');

Configuration=handles.Configuration;
Configuration(end+1).name=name;
Configuration(end).energy1=e1;
Configuration(end).energy2=e2;
Configuration(end).energy3=e3;
Configuration(end).plane1=plane1;
Configuration(end).plane2=plane2;
Configuration(end).plane3=plane3;

Configuration(end).theta=Tv;
Configuration(end).yaw=Yv;
Configuration(end).date=date;

handles.Configuration=Configuration;
handles.ConfNames{end+1}=name;
guidata(hObject, handles);
save CrystalGUI_Default -append Configuration
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');



function sr2_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','64');
    return
end
if((numread<0) || (numread>180))
    set(hObject,'String','64');
    return
end
if (isnan(numread))
    set(hObject,'String','64');
    return
end



% --- Executes during object creation, after setting all properties.
function sr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr3_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-45) || (numread>45))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function sr3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr4_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end



% --- Executes during object creation, after setting all properties.
function sr4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
if(get(handles.srl,'Value')==1)
    return
end
% T=str2num(get(handles.sr4,'String')); 
% Y=str2num(get(handles.srn1,'String'));
% R=str2num(get(handles.sro3,'String'));
% To=str2num(get(handles.sro1,'String')); 
% Yo=str2num(get(handles.sro2,'String')); 
TV=str2num(get(handles.sr2,'String'));
YV=str2num(get(handles.sr3,'String'));
% ey=str2num(get(handles.srn2,'String'));
% ez=str2num(get(handles.srn3,'String'));
% ex=str2num(get(handles.srn4,'String'));
% eT0=str2num(get(handles.srn5,'String'));
p1=get(handles.sr5,'String');
p2=get(handles.sr6,'String');
p3=get(handles.sr7,'String');
plane1=str2num(get(handles.sr5,'String'));
plane2=str2num(get(handles.sr6,'String'));
plane3=str2num(get(handles.sr7,'String'));

% handles.T=T;
% handles.Y=Y;
% handles.R=R;
% handles.ex = ex;
% handles.ey = ey;
% handles.ez = ez;
% handles.eT0 = eT0;
    set(handles.V_T,'String',num2str(TV));
    set(handles.V_Y,'String',num2str(YV));


    if(length(plane1)==3)
        set(handles.P1_E,'String',p1);
        set(handles.P1,'Value',1);
    else
        set(handles.P1_E,'String','');
        set(handles.P1,'Value',0);
    end
    if(length(plane2)==3)
        set(handles.P2_E,'String',p2);
        set(handles.P2,'Value',1);
    else
        set(handles.P2_E,'String','');
        set(handles.P2,'Value',0);
    end
    if(length(plane3)==3)
        set(handles.P3_E,'String',p3);
        set(handles.P2,'Value',1);
    else
        set(handles.P3_E,'String','');
        set(handles.P3,'Value',0);
    end
    
guidata(hObject, handles);
Draw_Upper_LR(handles)


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
val=get(handles.srl,'Value');
if(val==1)
    return
else
   val=val-1;
   ins=1;
   for II=1:numel(handles.Configuration)
       if(val~=II)
           Configuration(ins)=handles.Configuration(II);
           ins=ins+1;
       end
   end        
end
save CrystalGUI_Default -append Configuration
handles.Configuration=Configuration;
NewNames{1}='Current Configuration';
for II=1:numel(handles.Configuration)
   NewNames{II+1} = handles.Configuration(II).name;
end
handles.ConfNames=NewNames;
set(handles.srl,'String',handles.ConfNames);
guidata(hObject, handles);
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');


function sr1_Callback(hObject, eventdata, handles)
% hObject    handle to sr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sr1 as text
%        str2double(get(hObject,'String')) returns contents of sr1 as a double


% --- Executes during object creation, after setting all properties.
function sr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr5_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
        return
        end
    case 1
        set(hObject,'String','');
        return
    case 2
        set(hObject,'String','');
        return
    case 3
    otherwise
        set(hObject,'String','');
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])

% --- Executes during object creation, after setting all properties.
function sr5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr6_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
        return
        end
    case 1
        set(hObject,'String','');
        return
    case 2
        set(hObject,'String','');
        return
    case 3
    otherwise
        set(hObject,'String','');
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])


% --- Executes during object creation, after setting all properties.
function sr6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr7_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
        return
        end
    case 1
        set(hObject,'String','');
        return
    case 2
        set(hObject,'String','');
        return
    case 3
    otherwise
        set(hObject,'String','');
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])

% --- Executes during object creation, after setting all properties.
function sr7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr8_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','');
    return
end
if((numread<0) || (numread>50000))
    set(hObject,'String','');
    return
end
if (isnan(numread))
    set(hObject,'String','');
    return
end
% --- Executes during object creation, after setting all properties.
function sr8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr9_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','');
    return
end
if((numread<0) || (numread>50000))
    set(hObject,'String','');
    return
end
if (isnan(numread))
    set(hObject,'String','');
    return
end

% --- Executes during object creation, after setting all properties.
function sr9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr10_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','');
    return
end
if((numread<0) || (numread>50000))
    set(hObject,'String','');
    return
end
if (isnan(numread))
    set(hObject,'String','');
    return
end

% --- Executes during object creation, after setting all properties.
function sr10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sr11_Callback(hObject, eventdata, handles)
% hObject    handle to sr11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sr11 as text
%        str2double(get(hObject,'String')) returns contents of sr11 as a double


% --- Executes during object creation, after setting all properties.
function sr11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sr11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sro1_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<0) || (numread>180))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function sro1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sro1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sro2_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-45) || (numread>45))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end


% --- Executes during object creation, after setting all properties.
function sro2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sro2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sro3_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function sro3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sro3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_All.
function Load_All_Callback(hObject, eventdata, handles)
set(handles.LoadVal,'Value',0)
set(handles.Load_All,'Value',1)

% --- Executes on button press in LoadVal.
function LoadVal_Callback(hObject, eventdata, handles)
set(handles.LoadVal,'Value',1)
set(handles.Load_All,'Value',0)



function MaxSumSquare_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','75');
    return
end
if((numread<3) || (numread>1447))
    set(hObject,'String','75');
    return
end
if (isnan(numread))
    set(hObject,'String','75');
    return
end
set(hObject,'String',num2str(round(numread)));

% --- Executes during object creation, after setting all properties.
function MaxSumSquare_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxSumSquare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxOrder_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','5');
    return
end
if((numread<1) || (numread>20))
    set(hObject,'String','5');
    return
end
if (isnan(numread))
    set(hObject,'String','5');
    return
end
set(hObject,'String',num2str(round(numread)));


% --- Executes during object creation, after setting all properties.
function MaxOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_eyRA_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-0.3) || (numread>0.3))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_eyRA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_eyRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_ezRA_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-0.3) || (numread>0.3))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end


% --- Executes during object creation, after setting all properties.
function SNO_ezRA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_ezRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_exYA_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-0.3) || (numread>0.3))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_exYA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_exYA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SNO_ezYA_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_ezYA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_ezYA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_Tmis_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-180) || (numread>180))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_Tmis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_Tmis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SNO_Ymis_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-180) || (numread>180))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function SNO_Ymis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNO_Ymis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function srn1_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function srn1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit51_Callback(hObject, eventdata, handles)
% hObject    handle to edit51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit51 as text
%        str2double(get(hObject,'String')) returns contents of edit51 as a double


% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function srn2_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-0.3) || (numread>0.3))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function srn2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function srn3_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-0.3) || (numread>0.3))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function srn3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srn3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function srn4_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-0.3) || (numread>0.3))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end

% --- Executes during object creation, after setting all properties.
function srn4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srn4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function srn5_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','0');
    return
end
if((numread<-2*pi) || (numread>2*pi))
    set(hObject,'String','0');
    return
end
if (isnan(numread))
    set(hObject,'String','0');
    return
end
% --- Executes during object creation, after setting all properties.
function srn5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srn5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OPEN_THE_CALCULATOR_PANEL.
function OPEN_THE_CALCULATOR_PANEL_Callback(hObject, eventdata, handles)
set(handles.pushbutton26,'UserData',0);
State=upper(get(handles.ISS_Panel,'Visible'));
set(handles.SAVE_AND_APPLY,'enable','off');
if(strcmp(State,'ON'))
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','off');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','on');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')
else
    load Conditions Plane2 Plane1 ThetaV YawV
    handles.C.Plane2=Plane2;
    handles.C.Plane1=Plane1;
    handles.C.ThetaV=ThetaV;
    handles.C.YawV=YawV;
    set(handles.ISS_List,'Value',1);
    set(handles.ISS_DIAG,'String','');
    guidata(hObject, handles);
    Update_List_Box(hObject, handles)
    set(handles.BasicLineSearchPanel,'visible','off'); set(handles.Selected_Lines_Panel,'visible','off');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','on');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','on')
end

% --- Executes on selection change in ISS_List.
function ISS_List_Callback(hObject, eventdata, handles)
% hObject    handle to ISS_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ISS_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ISS_List


% --- Executes during object creation, after setting all properties.
function ISS_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISS_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ISS_E1_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
        return
        end
    case 1
        set(hObject,'String','');
        return
    case 2
        set(hObject,'String','');
        return
    case 3
    otherwise
        set(hObject,'String','');
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])

% --- Executes during object creation, after setting all properties.
function ISS_E1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISS_E1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ISS_E2_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=3)
    set(hObject,'String','');
    return
end
if((round(numread(1))~=numread(1)) ||  (round(numread(2))~=numread(2)) ||  (round(numread(3))~=numread(3)) )
    set(hObject,'String','');
    return
end
if((abs(numread(1))>1000 ) ||  (abs(numread(2))>1000 )  || (abs(numread(3))>1000 )  )
    set(hObject,'String','');
    return
end
switch(sum(mod(numread,2)))
    case 0
        if(~numread(1) && ~numread(2) && ~numread(3))
            set(hObject,'String','');
        return
        end 
        if(mod(sum(numread),4))
            set(hObject,'String','');
        return
        end
    case 1
        set(hObject,'String','');
        return
    case 2
        set(hObject,'String','');
        return
    case 3
    otherwise
        set(hObject,'String','');
        return
end
    
if (isnan(sum(numread)))
    set(hObject,'String','');
    return
end

set(hObject,'String',['[',num2str(round(numread(1))),',',num2str(round(numread(2))),',',num2str(round(numread(3))),']'])


% --- Executes during object creation, after setting all properties.
function ISS_E2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISS_E2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ISS_E3_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','');
    return
end
if((numread<0) || (numread>180))
    set(hObject,'String','');
    return
end
if (isnan(numread))
    set(hObject,'String','');
    return
end

% --- Executes during object creation, after setting all properties.
function ISS_E3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISS_E3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ISS_E4_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','');
    return
end
if((numread<-45) || (numread>45))
    set(hObject,'String','');
    return
end
if (isnan(numread))
    set(hObject,'String','');
    return
end

% --- Executes during object creation, after setting all properties.
function ISS_E4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISS_E4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ISS_ADD.
function ISS_ADD_Callback(hObject, eventdata, handles)
PE=str2num(get(handles.ISS_E1,'String'));
RE=str2num(get(handles.ISS_E2,'String'));
TV=str2num(get(handles.ISS_E3,'String'));
YV=str2num(get(handles.ISS_E4,'String'));
ERROR=0;
if((numel(PE)~=3))
    ERROR=1;
    set(handles.text179,'Foregroundcolor',[1,0,0]);
end
if((numel(RE)~=3))
    ERROR=1;
    set(handles.text180,'Foregroundcolor',[1,0,0]);
end
if((numel(TV)~=1))
    ERROR=1;
    set(handles.text181,'Foregroundcolor',[1,0,0]);
end
if((numel(YV)~=1))
    ERROR=1;
    set(handles.text182,'Foregroundcolor',[1,0,0]);
end
drawnow
if(~ERROR)
    handles.C.Plane2(end+1,:)=PE;
    handles.C.Plane1(end+1,:)=RE;
    handles.C.ThetaV(end+1)=TV;
    handles.C.YawV(end+1)=YV;
    guidata(hObject, handles);
    Update_List_Box(hObject, handles);
else
    pause(3)
    set(handles.text179,'Foregroundcolor',[0,0,0]);
    set(handles.text180,'Foregroundcolor',[0,0,0]);
    set(handles.text181,'Foregroundcolor',[0,0,0]);
    set(handles.text182,'Foregroundcolor',[0,0,0]);
end
    



% --- Executes on button press in ISS_DEL.
function ISS_DEL_Callback(hObject, eventdata, handles)
VAL=get(handles.ISS_List,'Value');
LLEN=length(handles.C.ThetaV);
if((VAL==1) && (LLEN==1))
    handles.C.ThetaV=[];
    handles.C.YawV=[];
    handles.C.Plane1=[];
    handles.C.Plane2=[];
    guidata(hObject, handles);
    Update_List_Box(hObject, handles)
    return
end
if ((VAL==1) && (LLEN>1))
    handles.C.ThetaV=handles.C.ThetaV(2:end);
    handles.C.YawV=handles.C.YawV(2:end);
    handles.C.Plane1=handles.C.Plane1(2:end,:);
    handles.C.Plane2=handles.C.Plane2(2:end,:);
    guidata(hObject, handles);
    Update_List_Box(hObject, handles)
    return
end
if ((VAL==LLEN))
    handles.C.ThetaV=handles.C.ThetaV(1:(end-1));
    handles.C.YawV=handles.C.YawV(1:(end-1));
    handles.C.Plane1=handles.C.Plane1(1:(end-1),:);
    handles.C.Plane2=handles.C.Plane2(1:(end-1),:);
    guidata(hObject, handles);
    set(handles.ISS_List,'Value',LLEN-1);
    Update_List_Box(hObject, handles)
    return
end
KEEP=[1:(VAL-1),(VAL+1):LLEN];
handles.C.ThetaV=handles.C.ThetaV(KEEP);
handles.C.YawV=handles.C.YawV(KEEP);
handles.C.Plane1=handles.C.Plane1(KEEP,:);
handles.C.Plane2=handles.C.Plane2(KEEP,:);
guidata(hObject, handles);
Update_List_Box(hObject, handles)


% --- Executes on button press in ISS_SC.
function ISS_SC_Callback(hObject, eventdata, handles)
Plane2=handles.C.Plane2;
Plane1=handles.C.Plane1;
ThetaV=handles.C.ThetaV;
YawV=handles.C.YawV;
save Conditions Plane2 Plane1 ThetaV YawV

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
if(get(hObject,'UserData')==0)
enablechangepanels(handles,0)
ShowCrosses=get(handles.ISS_C1,'Value');
CloseCrosses=get(handles.ISS_C2,'Value');
set(hObject,'UserData',1);
set(hObject,'String','Just show me the numbers..')
if(CloseCrosses)
    TimeClose=str2num(get(handles.ISS_C2E,'String'));
else
    TimeClose=-1;
end
 handles.NEWOFFSETS=CrystalGUI_EvaluateInitialState(handles.C.Plane1,handles.C.Plane2,handles.C.ThetaV,handles.C.YawV,ShowCrosses,TimeClose,hObject,100)
try
    handles.NEWOFFSETS=CrystalGUI_EvaluateInitialState(handles.C.Plane1,handles.C.Plane2,handles.C.ThetaV,handles.C.YawV,ShowCrosses,TimeClose,hObject,100);
    set(handles.SAVE_AND_APPLY,'enable','on')
    
    Linea{1}=['In. Crystal Theta Z Rot. (rad)= ',num2str(handles.NEWOFFSETS.Z_Rotation_Error)];
    Linea{2}=['In. Crystal Yaw Y Rot. (rad)= ',num2str(handles.NEWOFFSETS.Y_Rotation_Error)];
    Linea{3}=['In. Crystal Roll X Rot (rad)= ',num2str(handles.NEWOFFSETS.X_Rotation_Error)];
    Linea{4}=['Rot. Stage Rot Y (rad)= ',num2str(handles.NEWOFFSETS.Y_Rotation_ThetaAxis)];
    Linea{5}=['Rot. Stage Rot Z (rad) = ',num2str(handles.NEWOFFSETS.Z_Rotation_ThetaAxis)];
    Linea{6}=['Yaw Stage Rot X (rad) = ',num2str(handles.NEWOFFSETS.X_Rotation_YawAxis)];
    Linea{7}=['Yaw Stage Rot Z (rad)= ',num2str(handles.NEWOFFSETS.Z_Rotation_YawAxis)];
    Linea{8}=['Misreading Theta (deg)= ',num2str(handles.NEWOFFSETS.Theta_Misreading)];
    Linea{9}=['Misreading Yaw (deg)= ',num2str(handles.NEWOFFSETS.Yaw_Misreading)];
    set(handles.ISS_DIAG,'String',Linea);
    guidata(hObject, handles);
    enablechangepanels(handles,1)
    set(hObject,'String','Find offsets')
    set(hObject,'UserData',0);
catch ME
    set(handles.SAVE_AND_APPLY,'enable','off')
    enablechangepanels(handles,1)
    set(hObject,'String','Find offsets')
    set(hObject,'UserData',0);
end

end
if(get(hObject,'UserData')==1)
    set(hObject,'UserData',2);
    set(hObject,'String','Find offsets')
    enablechangepanels(handles,1)
end
% --- Executes on button press in ISS_C1.
function ISS_C1_Callback(hObject, eventdata, handles)
% hObject    handle to ISS_C1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ISS_C1



function ISS_C2E_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','3');
    return
end
if((numread<0) || (numread>45))
    set(hObject,'String','3');
    return
end
if (isnan(numread))
    set(hObject,'String','3');
    return
end
set(hObject,'String',num2str(round(numread)));

% --- Executes during object creation, after setting all properties.
function ISS_C2E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISS_C2E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ISS_C2.
function ISS_C2_Callback(hObject, eventdata, handles)
% hObject    handle to ISS_C2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ISS_C2


% --- Executes on button press in SAVE_AND_APPLY.
function SAVE_AND_APPLY_Callback(hObject, eventdata, handles)
Offset_Vector=handles.NEWOFFSETS;
handles.Offset_Vector=handles.NEWOFFSETS;
save CrystalGUI_Default -append Offset_Vector
guidata(hObject, handles);

set(handles.SNO_Tx,'String',num2str(handles.Offset_Vector.X_Rotation_Error));
set(handles.SNO_Yy,'String',num2str(handles.Offset_Vector.Y_Rotation_Error));
set(handles.SNO_Rz,'String',num2str(handles.Offset_Vector.Z_Rotation_Error));
set(handles.SNO_eyRA,'String',num2str(handles.Offset_Vector.Y_Rotation_ThetaAxis));
set(handles.SNO_ezRA,'String',num2str(handles.Offset_Vector.Z_Rotation_ThetaAxis));
set(handles.SNO_exYA,'String',num2str(handles.Offset_Vector.X_Rotation_YawAxis));
set(handles.SNO_ezYA,'String',num2str(handles.Offset_Vector.Z_Rotation_YawAxis));
set(handles.SNO_Tmis,'String',num2str(handles.Offset_Vector.Theta_Misreading));
set(handles.SNO_Ymis,'String',num2str(handles.Offset_Vector.Yaw_Misreading));

set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'visible','off');

function Update_List_Box(hObject, handles)
Line{1}='';
for IK=1:length(handles.C.ThetaV)
    Line{IK}=['Plane1 =[',num2str(handles.C.Plane1(IK,:)),'] ; Plane2 =[',num2str(handles.C.Plane2(IK,:)),'] ; Theta = ',num2str(handles.C.ThetaV(IK)),' ; Yaw = ',num2str(handles.C.YawV(IK))];
end
set(handles.ISS_List,'String',Line);

% --- Executes on button press in ISS_CLOSE.
function ISS_CLOSE_Callback(hObject, eventdata, handles)
    set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','off');
    set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','on');
    set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
    set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
    set(handles.ISS_Panel,'Visible','off')


% --- Executes during object creation, after setting all properties.
function SaveRecall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveRecall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text179_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text179 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function enablechangepanels(handles,variabile)
if(~variabile)
    set(handles.ISS_CLOSE,'enable','off')
    set(handles.Draw_Button,'enable','off')
    set(handles.SNO_Close,'enable','off')
    set(handles.OPEN_THE_CALCULATOR_PANEL,'enable','off')
    set(handles.Draw_2,'enable','off')
    set(handles.Color12Scan147,'enable','off')
    set(handles.SearchAngles147,'enable','off')
    set(handles.SNO,'enable','off')
    set(handles.Recall,'enable','off')
    set(handles.ClosePanelSR,'enable','off')
    set(handles.SAC_ClosePanel,'enable','off')
    set(handles.SC_ClosePanelButton,'enable','off')
else
    set(handles.ISS_CLOSE,'enable','on')
    set(handles.Draw_Button,'enable','on')
    set(handles.SNO_Close,'enable','on')
    set(handles.OPEN_THE_CALCULATOR_PANEL,'enable','on')
    set(handles.Draw_2,'enable','on')
    set(handles.Color12Scan147,'enable','on')
    set(handles.SearchAngles147,'enable','on')
    set(handles.SNO,'enable','on')
    set(handles.Recall,'enable','on')
    set(handles.ClosePanelSR,'enable','on')
    set(handles.SAC_ClosePanel,'enable','on')
    set(handles.SC_ClosePanelButton,'enable','on')
end
drawnow


% --- Executes on button press in SSH.
function SSH_Callback(hObject, eventdata, handles)
HI=handles.History;
save TX HI


% --- Executes on button press in SAC_SET.
function SAC_SET_Callback(hObject, eventdata, handles)
val1=get(handles.SAC_1,'String');
val2=get(handles.SAC_2,'String');
T=str2num(val1)
Y=str2num(val2)
try
   V1=lcaGet(handles.YawGetPV);
   V2=lcaGet(handles.PitchGetPV);
   set(handles.SAC_BACKT,'String',[num2str(V2),',',num2str(V1)]);
   set(handles.SAC_BACKT,'Userdata',[V1,V2]);
   V=1;
catch ME
   V=0; 
end
set(handles.V_T,'String',val1);
set(handles.V_Y,'String',val2);
if V
    MoveAngles(handles, T, Y)
    set(handles.SAC_BACK,'enable','on')
    set(handles.MovingPanel,'visible','off')   
    set(handles.AngleControlPanel,'visible','on')
end

% --- Executes on button press in SAC_BACK.
function SAC_BACK_Callback(hObject, eventdata, handles)
[Y,T]=get(handles.SAC_BACKT,'Userdata');

try
   V1=lcaGet(handles.YawGetPV);
   V2=lcaGet(handles.PitchGetPV);
   set(handles.SAC_BACKT,'String',[num2str(V2),',',num2str(V1)]);
   set(handles.SAC_BACKT,'Userdata',[V1,V2]);
   V=1;
catch ME
   V=0; 
end
T
Y
if V
    set(handles.V_T,'String',val1);
    set(handles.V_Y,'String',val2);
    MoveAngles(handles, T, Y)
    set(handles.SAC_BACK,'enable','on')
    set(handles.MovingPanel,'visible','off')  
    set(handles.AngleControlPanel,'visible','on')
end


% --- Executes on button press in SNO_Preset1.
function SNO_Preset1_Callback(hObject, eventdata, handles)
set(handles.SNO_Tx,'String',num2str(handles.Preset1.X_Rotation_Error,10));
set(handles.SNO_Yy,'String',num2str(handles.Preset1.Y_Rotation_Error,10));
set(handles.SNO_Rz,'String',num2str(handles.Preset1.Z_Rotation_Error,10));
set(handles.SNO_eyRA,'String',num2str(handles.Preset1.Y_Rotation_ThetaAxis,10));
set(handles.SNO_ezRA,'String',num2str(handles.Preset1.Z_Rotation_ThetaAxis,10));
set(handles.SNO_exYA,'String',num2str(handles.Preset1.X_Rotation_YawAxis,10));
set(handles.SNO_ezYA,'String',num2str(handles.Preset1.Z_Rotation_YawAxis,10));
set(handles.SNO_Tmis,'String',num2str(handles.Preset1.Theta_Misreading,10));
set(handles.SNO_Ymis,'String',num2str(handles.Preset1.Yaw_Misreading,10));

% --- Executes on button press in SNO_Preset2.
function SNO_Preset2_Callback(hObject, eventdata, handles)
set(handles.SNO_Tx,'String',num2str(handles.Preset2.X_Rotation_Error,10));
set(handles.SNO_Yy,'String',num2str(handles.Preset2.Y_Rotation_Error,10));
set(handles.SNO_Rz,'String',num2str(handles.Preset2.Z_Rotation_Error,10));
set(handles.SNO_eyRA,'String',num2str(handles.Preset2.Y_Rotation_ThetaAxis,10));
set(handles.SNO_ezRA,'String',num2str(handles.Preset2.Z_Rotation_ThetaAxis,10));
set(handles.SNO_exYA,'String',num2str(handles.Preset2.X_Rotation_YawAxis,10));
set(handles.SNO_ezYA,'String',num2str(handles.Preset2.Z_Rotation_YawAxis,10));
set(handles.SNO_Tmis,'String',num2str(handles.Preset2.Theta_Misreading,10));
set(handles.SNO_Ymis,'String',num2str(handles.Preset2.Yaw_Misreading,10));


% --- Executes on button press in SC_Start.
function SC_Start_Callback(hObject, eventdata, handles)
%DISABLE EVERYTHING ---
set(handles.SC_ClosePanelButton,'enable','off')
set(handles.EvalScanPoints,'enable','off')
set(handles.Draw_2,'enable','off')
Current2SCAN=get(handles.Color12Scan147,'enable');
CurrentSearch=get(handles.SearchAngles147,'enable');
set(handles.Color12Scan147,'enable','off')
set(handles.SearchAngles147,'enable','off')
set(handles.Draw_Button,'enable','off')
set(handles.SETMACANG,'enable','off')
set(handles.SNO,'enable','off')
set(handles.SC_Start,'enable','off')
set(handles.SC_Start,'BackgroundColor',handles.ColorWAIT)

%Read Scan Stuff
ContON=get(handles.SC_Cont,'Value');
VerON=get(handles.SC_Vernier,'Value');
StepsN=str2num(get(handles.SC_Steps,'String'));
PauseN=str2num(get(handles.SC_Pause,'String'));

%Read Restore Point
try
    ThetaHome=lcaGetSmart(handles.PitchGetPV);
    YawHome=lcaGetSmart(handles.YawGetPV);
    VernierHome=lcaGetSmart(handles.VernierPV);
    MachineStatus=1;
catch ME
    MachineStatus=0; 
end

%PreparePath
set(handles.SC_Stop,'Enable','on')
set(handles.SC_Stop,'BackGroundColor',handles.ColorON);
OriginalScale=linspace(0,1,length(handles.CurrentScanTheta));
ThetaValues=interp1(OriginalScale,handles.CurrentScanTheta,linspace(0,1,StepsN));
YawValues=interp1(OriginalScale,handles.CurrentScanYaw,linspace(0,1,StepsN));
VernierValues=interp1(OriginalScale,handles.CurrentScanVernier,linspace(0,1,StepsN));

%Do Scan
if(~ContON) %Do from start to end and stop
    
    for CurrentPosition=1:StepsN
       if(MachineStatus)
           MoveAngles(handles,ThetaValues(CurrentPosition),YawValues(CurrentPosition));
           if(VerON)
                lcaPutSmart(handles.VernierPV,VernierValues(CurrentPosition));
           end
       end
       set(handles.SC_Theta,'String',num2str(ThetaValues(CurrentPosition)));
       set(handles.SC_Yaw,'String',num2str(YawValues(CurrentPosition)));
       if(PauseN<=1)
            pause(PauseN)
       else
          for JK=1:floor(PauseN)
             pause(1);
             StopC=get(handles.SC_Stop,'BackgroundColor');
             if(sum(StopC==handles.ColorWAIT)==3)
                 break; 
             end
          end
          pause(PauseN-floor(PauseN));
       end
       %Check for Stop button
       StopC=get(handles.SC_Stop,'BackgroundColor');
       if(sum(StopC==handles.ColorWAIT)==3)
          break; 
       end
       
    end
else
    CurrentPosition=1;
    Delta=+1;
    while(1)
       if(MachineStatus)
           MoveAngles(handles,ThetaValues(CurrentPosition),YawValues(CurrentPosition));
           if(VerON)
                lcaPutSmart(handles.VernierPV,VernierValues(CurrentPosition));
           end
       end
       set(handles.SC_Theta,'String',num2str(ThetaValues(CurrentPosition)));
       set(handles.SC_Yaw,'String',num2str(YawValues(CurrentPosition)));
       if(((CurrentPosition+Delta)==0) || ((CurrentPosition+Delta)>StepsN)) 
           Delta=-Delta;
       end
       if(PauseN<=1)
            pause(PauseN)
       else
          for JK=1:floor(PauseN)
             pause(1);
             StopC=get(handles.SC_Stop,'BackgroundColor');
             if(sum(StopC==handles.ColorWAIT)==3)
                 break; 
             end
          end
          pause(PauseN-floor(PauseN));
       end
       CurrentPosition=CurrentPosition+Delta;
       StopC=get(handles.SC_Stop,'BackgroundColor');
       if(sum(StopC==handles.ColorWAIT)==3)
          break; 
       end
    end
    
end

%RestoreStartingPoint
if(MachineStatus)
    MoveAngles(handles, ThetaHome, YawHome);
    if(VerON)
        lcaPutSmart(handles.VernierPV,VernierHome);
    end
end
%Restore enable
set(handles.SC_ClosePanelButton,'enable','on')
set(handles.EvalScanPoints,'enable','on')
set(handles.Draw_2,'enable','on')
set(handles.Color12Scan147,'enable',Current2SCAN)
set(handles.SearchAngles147,'enable',CurrentSearch)
set(handles.Draw_Button,'enable','on')
set(handles.SETMACANG,'enable','on')
set(handles.SNO,'enable','on')
set(handles.SC_Start,'enable','on')
set(handles.SC_Stop,'Enable','off');
set(handles.SC_Stop,'BackgroundColor',handles.ColorIDLE);
set(handles.SC_Start,'BackgroundColor',handles.ColorON)


% --- Executes on button press in SC_Stop.
function SC_Stop_Callback(hObject, eventdata, handles)
set(handles.SC_Stop,'BackGroundColor',handles.ColorWAIT);
drawnow


% --- Executes on button press in SC_Cont.
function SC_Cont_Callback(hObject, eventdata, handles)
% hObject    handle to SC_Cont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SC_Cont


% --- Executes on button press in SC_Vernier.
function SC_Vernier_Callback(hObject, eventdata, handles)
% hObject    handle to SC_Vernier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SC_Vernier



function SC_Steps_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','10');
    return
end
if((numread<2) || (numread>10000))
    set(hObject,'String','10');
    return
end
if (isnan(numread))
    set(hObject,'String','10');
    return
end
set(hObject,'String',num2str(round(numread)));


% --- Executes during object creation, after setting all properties.
function SC_Steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SC_Steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SC_Pause_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','2');
    return
end
if((numread<0) || (numread>10000))
    set(hObject,'String','2');
    return
end
if (isnan(numread))
    set(hObject,'String','2');
    return
end


% --- Executes during object creation, after setting all properties.
function SC_Pause_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SC_Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Moves angles of the crystal in the machine
function MoveAngles(handles, Tval, Yval)
set(handles.MovingPanel,'visible','on')
set(handles.AngleControlPanel,'visible','off')
set(handles.MovingDia,'string','Moving')
set(handles.STOPMOVING,'BackGroundColor',handles.ColorON)
drawnow
CurrentT=lcaGetSmart(handles.PitchGetPV);
CurrentY=lcaGetSmart(handles.YawGetPV);
lcaPutSmart(handles.PitchGetPV,Tval);
lcaPutSmart(handles.YawGetPV,Yval);
distTOld=abs(CurrentT-Tval);
distYOld=abs(CurrentY-Yval);
if ((distTOld<handles.Thres) && (distYOld<handles.Thres))
    return
else
    ExitCrit=1;
    while(ExitCrit)
        StopMovingColor=get(handles.STOPMOVING,'BackGroundColor');
        if(sum(StopMovingColor==handles.ColorWAIT)==3)
            NewP=lcaGetSmart(handles.PitchGetPV);
            NewY=lcaGetSmart(handles.YawGetPV);
            lcaPutSmart(handles.PitchGetPV,NewP);
            lcaPutSmart(handles.YawGetPV,NewY);
            set(handles.MovingPanel,'visible','off')
            set(handles.AngleControlPanel,'visible','on')
            set(handles.SC_Stop,'BackGroundColor',handles.ColorWAIT); %This will kill a scan if it was in use.
            drawnow
            return
        end
        pause(handles.PauseSet);
        CurrentT=lcaGetSmart(handles.PitchGetPV);
        CurrentY=lcaGetSmart(handles.YawGetPV);
        distT=abs(CurrentT-Tval);
        distY=abs(CurrentY-Yval);

        if( (distT>distTOld) && (distT>=handles.Thres) ) % Moving Away!! somebody changed from outside
            ExitCrit=0;
            set(handles.MovingDia,'string','Interrupted')
            pause(1)
        end

        if( (distY>distYOld) && (distY>=handles.Thres) ) % Moving Away!! somebody changed from outside
            ExitCrit=0;
            set(handles.MovingDia,'string','Interrupted')
            pause(1)
        end

        if((distT<=handles.Thres) && (distY<=handles.Thres)) % Safe at Destination
            ExitCrit=0;
            set(handles.MovingDia,'string','At Destination')
        end
        if(ExitCrit==1);
            %Still Moving
            distTOld=distT;
            distYOld=distY;
            set(handles.MovingDia,'string','Moving')
        end
    end
    
end


% --- Executes on button press in STOPMOVING.
function STOPMOVING_Callback(hObject, eventdata, handles)
set(handles.STOPMOVING,'BackGroundColor',handles.ColorWAIT);


% --- Executes on button press in SETMACANG.
function SETMACANG_Callback(hObject, eventdata, handles)
try
   V1=lcaGet(handles.YawGetPV);
   V2=lcaGet(handles.PitchGetPV);
   set(handles.V_T,'String',num2str(V2));
   set(handles.V_Y,'String',num2str(V1));
catch ME 
end


% --- Executes during object creation, after setting all properties.
function MovingPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovingPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in IchBinFaul.
function IchBinFaul_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off'); set(handles.IchBinFaulPanel,'visible','on');
set(handles.AngleControlPanel,'visible','off');



function IchBinFaul_e1_Callback(hObject, eventdata, handles)
read=get(hObject,'String');
numread=str2num(read);
if (numel(numread)~=1)
    set(hObject,'String','8000');
    return
end
if((numread<=4950) || (numread>=11250))
    set(hObject,'String','8000');
    return
end
if (isnan(numread))
    set(hObject,'String','8000');
    return
end


% --- Executes during object creation, after setting all properties.
function IchBinFaul_e1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IchBinFaul_e1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in eVP_CLOSE.
function eVP_CLOSE_Callback(hObject, eventdata, handles)
set(handles.BasicLineSearchPanel,'visible','on'); set(handles.Selected_Lines_Panel,'visible','on');
set(handles.Tabula,'visible','off'); set(handles.SNO_Panel,'visible','off');
set(handles.SFA,'visible','off'); set(handles.SaveRecall,'visible','off');
set(handles.SAC,'visible','off'); set(handles.TabulaC,'visible','off');
set(handles.ISS_Panel,'Visible','off'); set(handles.IchBinFaulPanel,'visible','off');
set(handles.AngleControlPanel,'visible','on');


% --- Executes on selection change in NumberOfColors.
function NumberOfColors_Callback(hObject, eventdata, handles)
if(get(handles.NumberOfColors,'value')==1)
    set(handles.eVP_GO,'String','Find Line and Angles')
else
    set(handles.eVP_GO,'String','Find Lines and Angles')
end


% --- Executes during object creation, after setting all properties.
function NumberOfColors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in eVP_GO.
function eVP_GO_Callback(hObject, eventdata, handles)
Colors=get(handles.NumberOfColors,'Value');
Energy=str2num(get(handles.IchBinFaul_e1,'String'));

if(Colors==1)
   [Useless,Closest]=min(abs(Energy-handles.AnglePreset.Single.E));
   DE=diff(handles.AnglePreset.Single.E);
   Changes=find(DE<10^-2);
   if(Closest<Changes(1))
       UsedPlane=1;
   elseif(Closest>Changes(end));
       UsedPlane=length(handles.AnglePreset.Single.PlanesLimits)-1;
   else
       UsedPlane=find(Changes>=Closest,1,'first');
   end
   Plane=handles.AnglePreset.Single.Plane(UsedPlane,:);  
   T=handles.AnglePreset.Single.T(Closest);
   Y=handles.AnglePreset.Single.Y(Closest);
   set(handles.V_T,'String',num2str(T));
   set(handles.V_Y,'String',num2str(Y));
   set(handles.P1_E,'String',['[',num2str(Plane),']']);
   set(handles.P1,'Value',1);
   set(handles.P2_E,'String','');
   set(handles.P2,'Value',0);
   set(handles.P3_E,'String','');
   set(handles.P3,'Value',0);
   Draw_2_Callback(hObject, eventdata, handles)
   SearchAngles147_Callback(hObject, eventdata, handles)
   set(handles.SAC_e1,'String',num2str(Energy))
   SAC_CalculateButton_Callback(hObject, eventdata, handles)
else
   [Useless,Closest]=min(abs(Energy-handles.AnglePreset.Double.E));
   DE=diff(handles.AnglePreset.Double.E);
   Changes=find(DE<10^-2);
   if(Closest<Changes(1))
       UsedPlane=1;
   elseif(Closest>Changes(end));
       UsedPlane=length(handles.AnglePreset.Double.PlanesLimits)-1;
   else
       UsedPlane=find(Changes>=Closest,1,'first');
   end
   Plane1=handles.AnglePreset.Double.Plane1(UsedPlane,:);
   Plane2=handles.AnglePreset.Double.Plane2(UsedPlane,:);
   T=handles.AnglePreset.Double.T(Closest);
   Y=handles.AnglePreset.Double.Y(Closest);
   set(handles.V_T,'String',num2str(T));
   set(handles.V_Y,'String',num2str(Y));
   set(handles.P1_E,'String',['[',num2str(Plane1),']']);
   set(handles.P1,'Value',1);
   set(handles.P2_E,'String',['[',num2str(Plane2),']']);
   set(handles.P2,'Value',1);
   set(handles.P3_E,'String','');
   set(handles.P3,'Value',0);
   Draw_2_Callback(hObject, eventdata, handles)
   SearchAngles147_Callback(hObject, eventdata, handles)
   set(handles.SAC_e1,'String',num2str(Energy))
   set(handles.SAC_e2,'String',num2str(Energy))
   SAC_CalculateButton_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in Logbookbutton.
function Logbookbutton_Callback(hObject, eventdata, handles)
    Res1=get(handles.RES_C1,'String');
    Res2=get(handles.RES_C2,'String');
    Res3=get(handles.RES_C3,'String');
    LINES_FOUND=0;

    if(numel(Res1))
        handles.WorkingPoint.Plane1=str2num(Res1{1});
        plane1=get(handles.LINEA1,'Userdata');
        handles.WorkingPoint.Plane1=plane1;
        LINES_FOUND=1;
    else
        
    end
    if(numel(Res2))
        handles.WorkingPoint.Plane2=str2num(Res2{1});
        plane2=get(handles.LINEA2,'Userdata');
        handles.WorkingPoint.Plane2=plane2;
        LINES_FOUND=1;
    else
        
    end
    if(numel(Res3))
        handles.WorkingPoint.Plane3=str2num(Res3{1});
        plane3=get(handles.LINEA3,'Userdata');
        handles.WorkingPoint.Plane3=plane3;
        LINES_FOUND=1;
    else
        
    end

    if(LINES_FOUND) %PRINT TO LOGBOOOK
        handles.WorkingPoint.AngleT=str2num(get(handles.thetval,'String'));
        handles.WorkingPoint.AngleY=str2num(get(handles.yawval,'String'));
        % do something with the numbers        
    end
