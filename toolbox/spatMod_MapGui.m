function varargout = spatModMap_gui(varargin)
% SPATMODMAP_GUI MATLAB code for spatModMap_gui.fig
%      SPATMODMAP_GUI, by itself, creates a new SPATMODMAP_GUI or raises the existing
%      singleton*.
%
%      H = SPATMODMAP_GUI returns the handle to a new SPATMODMAP_GUI or the handle to
%      the existing singleton*.
%
%      SPATMODMAP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPATMODMAP_GUI.M with the given input arguments.
%
%      SPATMODMAP_GUI('Property','Value',...) creates a new SPATMODMAP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spatModMap_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spatModMap_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spatModMap_gui

% Last Modified by GUIDE v2.5 21-Jul-2015 22:20:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spatModMap_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @spatModMap_gui_OutputFcn, ...
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


% --- Executes just before spatModMap_gui is made visible.
function spatModMap_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.pvs={'SIOC:SYS0:ML02:AO073','SIOC:SYS0:ML02:AO074','SIOC:SYS0:ML02:AO075',...
'SIOC:SYS0:ML02:AO076', 'SIOC:SYS0:ML02:AO077', 'SIOC:SYS0:ML02:AO078'};
handles.tags={'hand_editTxt', 'deg_editTxt', 'rCenter1_editTxt', ...
    'rCenter2_editTxt', 'ratio1_editTxt', 'ratio2_editTxt'};

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = spatModMap_gui_OutputFcn(hObject, eventdata, handles) 

guidata(hObject, handles);
varargout{1} = handles.output;



function frac1_editTxt_Callback(hObject, eventdata, handles)
% 

function frac2_editTxt_Callback(hObject, eventdata, handles)
% 

function dmd1_editTxt_Callback(hObject, eventdata, handles)
% 

function dmd2_editTxt_Callback(hObject, eventdata, handles)
% 

function thick_editTxt_Callback(hObject, eventdata, handles)
% 

function hand_editTxt_Callback(hObject, eventdata, handles)
% 

function deg_editTxt_Callback(hObject, eventdata, handles)
% 

function rCenter1_editTxt_Callback(hObject, eventdata, handles)
% 

function rCenter2_editTxt_Callback(hObject, eventdata, handles)
% 

function ratio1_editTxt_Callback(hObject, eventdata, handles)
% 

function ratio2_editTxt_Callback(hObject, eventdata, handles)
% 

% --- Executes on button press in mapstart1_btn.
function mapstart1_btn_Callback(hObject, eventdata, handles)
frac1=str2double(get(handles.frac1_editTxt, 'String'));
frac2=str2double(get(handles.frac2_editTxt, 'String'));
dmd1=str2double(get(handles.dmd1_editTxt, 'String'));
dmd2=str2double(get(handles.dmd2_editTxt, 'String'));
thick=str2double(get(handles.thick_editTxt, 'String'));
values=[frac1, frac2, dmd1, dmd2, thick];
cameraL=spatMod_makeL(values);
imagesc(cameraL, 'Parent', handles.axes1);



% --- Executes on button press in mapstart2_btn.
function mapstart2_btn_Callback(hObject, eventdata, handles)
frac1=str2double(get(handles.frac1_editTxt, 'String'));
frac2=str2double(get(handles.frac2_editTxt, 'String'));
dmd1=str2double(get(handles.dmd1_editTxt, 'String'));
lcaPutSmart('SIOC:SYS0:ML02:AO079', dmd1)
dmd2=str2double(get(handles.dmd2_editTxt, 'String'));
lcaPutSmart('SIOC:SYS0:ML02:AO080', dmd2);
values=[frac1, frac2, dmd1, dmd2];
[img ,newValues]=spatMod_fitL(values);

s=length(handles.pvs);
for i = 1:s
    lcaPutSmart(handles.pvs{i}, newValues(i));   
    set(handles.(handles.tags{i}), 'String', num2str( newValues(i)));
end
imagesc(img, 'Parent', handles.axes2);
