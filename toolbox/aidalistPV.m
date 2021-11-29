function varargout = aidalistPV(varargin)
% AIDALISTPV M-file for aidalistPV.fig
%      AIDALISTPV, by itself, creates d new AIDALISTPV or raises the existing
%      singleton*.
%
%      H = AIDALISTPV returns the handle to d new AIDALISTPV or the handle to
%      the existing singleton*.
%
%      AIDALISTPV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AIDALISTPV.M with the given input arguments.
%
%      AIDALISTPV('Property','Value',...) creates d new AIDALISTPV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aidalistPV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aidalistPV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aidalistPV

% Last Modified by GUIDE v2.5 26-Jan-2014 06:45:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aidalistPV_OpeningFcn, ...
                   'gui_OutputFcn',  @aidalistPV_OutputFcn, ...
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

% --- Executes just before aidalistPV is made visible.
function aidalistPV_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = aidalistPV_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
handles.listPV = get(hObject, 'String');
myPVs = aidalist(handles.listPV);
if numel(myPVs) == 1
    handles.listPV = 'I found it';
    handles.out = myPVs;
elseif numel(myPVs) >1
    handles.out = myPVs;
    a = num2str(numel(handles.out));
    disp(a)
    handles.listPV = [a, ' PVs available, options are:'];
else
    handles.listPV = 'Not a PV';
    disp('Not a PV');
    
end
e = handles.listPV;
b = findobj(gcf,'Tag','e');
set(b,'String',e);
d = myPVs;
a = findobj(gcf,'Tag','d');
set(a,'String',d);
guidata(hObject, handles);

function d_Callback(hObject, eventdata, handles)
handles.selectPV = get(hObject, 'String');
disp(handles.selectPV)



% --- Executes during object creation, after setting all properties.
function d_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Stole this neat little sizing/positioning code from Shawn
pos = get(gcf,'Position');
set(0,'Units','characters');
scrnsz=get(0,'ScreenSize');
set(0,'Units','pixels');
newx = pos(1) + 90;
newy = pos(2);

if newx > (scrnsz(3) - 76)
    newx = pos(1) - 76;
end


% Launch a new figure for the help page
figure('Units','characters','Position',[newx newy 95 24],'Color',[1 0 1], ...
                'Name','Aidalist','NumberTitle','off','MenuBar','none','Resize','off');
uipanel('Title','Aidalist whos a whatsit?','units','characters', ...
           'Position',[0 0 95 24],'BorderType','none', ...
            'FontSize',15,'BackgroundColor',[0.85 0.85 0.85],'HighlightColor','white', ...
            'BorderWidth',1,'TitlePosition','centertop');


% All the text nonsense
props={'Style','text','HorizontalAlignment','left','units','characters'};
uicontrol(props{:},'String','What is aidalist?', ...
           'FontSize',14,'FontWeight','bold','Position',[2 19 73 2.8],'BackgroundColor',[0.85 0.85 0.85]); 
uicontrol(props{:},'String','aidalist is used to get the names of things that the Accelerator Independent Data Access (AIDA) system knows about. In general these things are accelerator devices or aggregates of devices, and AIDA can be used to get the reading value, or in some cases to set the value, of such devices. aidalist can be used in combination with aidaget to get the present value.', ...
           'FontSize',10,'FontWeight','normal','Position',[5 14 85 6],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','That is fine, but how about some examples?', ...
           'FontSize',14,'FontWeight','bold','Position',[2 10 93 2.8],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String',{'Entering XCOR:PR10:9042       - Confirms XCOR:PR10:9042 is known' 'Entering XCOR:PR10:9%         - All "9 something" XCOR in PR10' 'Entering XCOR:PR10:9042 X%    - All X attributes of XCOR:PR10:9042' 'Entering XCOR:PR10:9042 %     - All attributes of XCOR:PR10:9042' 'Entering XCOR%               - All XCOR with all their attributes' 'Entering XCOR:LI%:502 twiss   - Which linac 502 units have twiss' 'Entering -m XCOR:LI27:502% - Lists what AIDA knows about all' '   attributes of XCOR:LI27:502, from EPICS, SLC or anywhere else.'}, ...      
           'FontSize',10,'FontWeight','normal','Position',[5 1 95 10],'BackgroundColor',[0.85 0.85 0.85]);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(gcf)
if ~usejava('desktop')
    exit
end

function edit4_Callback(hObject, eventdata, handles)
handles.curPV = get(hObject, 'String');
q = lcaGet(handles.curPV);
e = findobj(gcf,'Tag','q');
set(e,'String',q);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
system(['probe ', handles.curPV])

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
h = gcf;
disp(h)
plotHistory(handles.curPV)
guidata(hObject, handles)

function edit5_Callback(hObject, eventdata, handles)
handles.newDes = get(hObject, 'String');
lcaput(handles.curPV, handles.newDes)
q = lcaGet(handles.curPV);
e = findobj(gcf,'Tag','q');
set(e,'String',q);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


