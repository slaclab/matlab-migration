function varargout = archive_gui(varargin)
% ARCHIVE_GUI M-file for archive_gui.fig
%      ARCHIVE_GUI, by itself, creates a new ARCHIVE_GUI or raises the existing
%      singleton*.
%
%      H = ARCHIVE_GUI returns the handle to a new ARCHIVE_GUI or the handle to
%      the existing singleton*.
%
%      ARCHIVE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARCHIVE_GUI.M with the given input arguments.
%
%      ARCHIVE_GUI('Property','Value',...) creates a new ARCHIVE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before archive_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to archive_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help archive_gui

% Last Modified by GUIDE v2.5 19-Aug-2013 11:49:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @archive_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @archive_gui_OutputFcn, ...
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


% --- Executes just before archive_gui is made visible.
function archive_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to archive_gui (see VARARGIN)

% Choose default command line output for archive_gui
handles.output = hObject;

set(handles.startTime_txt,'String',datestr(now-1));
set(handles.endTime_txt,'String',datestr(now));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes archive_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = archive_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


function archive_plot(hObject, handles)

if ~isfield(handles,'v'), return, end

pvList=get(handles.pvList_txt,'String');
startTime=get(handles.startTime_txt,'String');
endTime=get(handles.endTime_txt,'String');
v=handles.v;t=handles.t;

% Plot data.
[hAxes,hFig]=util_plotInit('figure',1);
xLim=datenum({startTime endTime});
if strcmp(get(zoom(hFig),'Enable'),'on'), xLim=get(hAxes,'XLim');end

col=get(hAxes,'ColorOrder');
sty={'-' '--' ':' '-.'};
use=1:numel(v);
for j=use
    vj=v{j};
    if get(handles.showNorm_box,'Value')
        if min(vj) == max(vj), vj(:)=0.5;
        else vj=(vj-min(vj))/(max(vj)-min(vj));
        end
        vj=vj+j/10.5;
    end
    stairs(hAxes,t{j},vj,'Color',col(mod(j-1,7)+1,:), ...
        'LineStyle',sty{mod(floor((j-1)/7),4)+1});
    hold(hAxes,'on');
end
hold(hAxes,'off');
legend(hAxes,strrep(pvList(use),'_','\_'));legend(hAxes,'boxoff');
xlim(hAxes,xLim);
datetick(hAxes,'keeplimits');
xlabel(hAxes,'Time');


function pvList_txt_Callback(hObject, eventdata, handles)


% --- Executes on button press in getData_btn.
function getData_btn_Callback(hObject, eventdata, handles)

pvList=get(handles.pvList_txt,'String');
startTime=get(handles.startTime_txt,'String');
endTime=get(handles.endTime_txt,'String');

[handles.v,handles.t,vv,tt]=archive_dataGet(pvList,startTime,endTime);
guidata(hObject,handles);

archive_plot(hObject, handles);


function startTime_txt_Callback(hObject, eventdata, handles)


function endTime_txt_Callback(hObject, eventdata, handles)


% --- Executes on button press in showNorm_box.
function showNorm_box_Callback(hObject, eventdata, handles)

archive_plot(hObject, handles);


% --- Executes on button press in replot_btn.
function replot_btn_Callback(hObject, eventdata, handles)

archive_plot(hObject, handles);

