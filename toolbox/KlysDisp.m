function varargout = KlysDisp(varargin)
% KLYSDISP M-file for KlysDisp.fig
%      KLYSDISP, by itself, creates a new KLYSDISP or raises the existing
%      singleton*.
%
%      H = KLYSDISP returns the handle to a new KLYSDISP or the handle to
%      the existing singleton*.
%
%      KLYSDISP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KLYSDISP.M with the given input arguments.
%
%      KLYSDISP('Property','Value',...) creates a new KLYSDISP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KlysDisp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KlysDisp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KlysDisp

% Last Modified by GUIDE v2.5 17-Sep-2011 05:36:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KlysDisp_OpeningFcn, ...
                   'gui_OutputFcn',  @KlysDisp_OutputFcn, ...
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
end


% --- Executes just before KlysDisp is made visible.
function KlysDisp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KlysDisp (see VARARGIN)

% Choose default command line output for KlysDisp
handles.output = hObject;

set(handles.Stop_txt, 'String', 0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KlysDisp wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = KlysDisp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in Start_btn.
function Start_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Start_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in Run_btn.
function Run_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Run_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    set(handles.Run_btn, 'Enable', 'off');

    global kdisp;
    %Initialization Code (Get PV from Aida)
    if strcmp(get(handles.watchdog_txt, 'String'), '0')    
        clc;
        set(handles.Stop_txt, 'String', 'Initilizing');
        
        PV_ts = [];
        for sector = 20:1:30
            switchsts = lcaGetSmart(strcat('IOC:LI', num2str(sector), ':CV01:SWITCHSTS'));
            if strcmp(switchsts, 'IOC')
                PV_ts = [ PV_ts, aidalist(strcat('KLYS:LI', num2str(sector), ':%1:%ERRTTS')) ];
            end
        end
        
        PV_ts = PV_ts(~strcmp('AMPLERRTTS',cellfun(@(PV_ts) PV_ts(14:end), PV_ts, 'Uniformoutput', false)));
         
        PV_ec = cellfun(@(PV_ts) PV_ts(1:length(PV_ts)-2), PV_ts, 'Uniformoutput', false);
   
        kdisp = cell(5,length(PV_ts));
    
        kdisp(1,:) = PV_ts;
        kdisp(3,:) = PV_ec;
        kdisp(4,:) = num2cell(zeros(length(PV_ts),1)');
        kdisp(5,:) = num2cell(zeros(length(PV_ts),1)');
   
        disp 'Startup Completed Successfully'
    end

    %Start Error Count
    set(handles.Stop_txt, 'String', 'Running');
    disp (strcat({'Start Time '}, datestr(now)));

    start_err = lcaGetSmart(kdisp(3,:)');
    Display = get(handles.DispBox, 'String');
    if isempty(Display)
        Display = cell(100,1);
    end
        
    tripnum = lcaGetSmart(kdisp(3,:)');
    kdisp(5,:) = num2cell(tripnum);
    i=0;
    
    while strcmp(get(handles.Stop_txt, 'string'), 'Running')
        
        triptime = lcaGetSmart(kdisp(1,:)');
        kdisp(2,:) = num2cell(triptime);
        
        tripnum = lcaGetSmart(kdisp(3,:)');
        kdisp(4,:) = num2cell(tripnum);
        
        for j = 1:1:length(kdisp)
            if kdisp{4,j} > kdisp{5,j}
                for k = 100:-1:2
                    Display{k} = Display{k-1};
                end
                %fprintf('%s %s\n', char(kdisp{2,j}), char(kdisp{3,j}));
                temp = char(kdisp{3,j});
                Display{1} = strcat(char(kdisp{2,j}), {'     '}, temp(6:11), {'     '}, temp(14:end));
                set(handles.DispBox, 'String', cellfun(@char, Display, 'UniformOutput', false));
            end
        end
        
        kdisp(5,:) = kdisp(4,:);
        set(handles.watchdog_txt, 'String', num2str(i));
        pause(5);
        i = i+1;
    end
    
    disp (strcat({'End Time '}, datestr(now)));
    disp ('Run Completed Successfully');
    
    guidata(hObject, handles);
end


% --- Executes on selection change in DispBox.
function DispBox_Callback(hObject, eventdata, handles)
% hObject    handle to DispBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DispBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DispBox
end

% --- Executes during object creation, after setting all properties.
function DispBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DispBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end    


% --- Executes on button press in stop_btn.
function stop_btn_Callback(hObject, eventdata, handles)
% hObject    handle to stop_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.Stop_txt, 'String', 'Stopped');
    set(handles.Run_btn, 'Enable', 'on');
    guidata(hObject, handles);
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    Height = get(handles.figure1, 'Position');
    
    if Height(4) < 110
        Height(4) = 110;
        set(handles.figure1, 'Position', Height);
    end

    RbP = get(handles.Run_btn, 'Position');
    RbP(2) = Height(4) - 50;
    set(handles.Run_btn, 'Position', RbP);
    
    SbP = get(handles.stop_btn, 'Position');
    SbP(2) = Height(4) - 50;
    set(handles.stop_btn, 'Position', SbP);
    
    StP = get(handles.Stop_txt, 'Position');
    StP(2) = Height(4) - 50;
    set(handles.Stop_txt, 'Position', StP);
    
    WtP = get(handles.watchdog_txt, 'Position');
    WtP(2) = Height(4) - 50;
    set(handles.watchdog_txt, 'Position', WtP);
    
    DbP = get(handles.DispBox, 'Position');
    DbP(4) = Height(4) - 75;
    set(handles.DispBox, 'Position', DbP);
    
end

