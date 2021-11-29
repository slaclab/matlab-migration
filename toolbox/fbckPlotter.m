function varargout = fbckPlotter(varargin)
% FBCKPLOTTER M-file for fbckPlotter.fig
%      FBCKPLOTTER, by itself, creates a new FBCKPLOTTER or raises the existing
%      singleton*.
%
%      H = FBCKPLOTTER returns the handle to a new FBCKPLOTTER or the handle to
%      the existing singleton*.
%
%      FBCKPLOTTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBCKPLOTTER.M with the given input arguments.
%
%      FBCKPLOTTER('Property','Value',...) creates a new FBCKPLOTTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbckPlotter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbckPlotter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbckPlotter

% Last Modified by GUIDE v2.5 20-Jul-2013 10:10:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbckPlotter_OpeningFcn, ...
                   'gui_OutputFcn',  @fbckPlotter_OutputFcn, ...
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

% --- Executes just before fbckPlotter is made visible.
function fbckPlotter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbckPlotter (see VARARGIN)

% Choose default command line output for fbckPlotter
handles.output = hObject;
% List of fields for data file
fbckListPv = [aidalist('FBCK:FB0%:TR0%:NAME') aidalist('FBCK:FB0%:LG0%:NAME')];
fbckListName = lcaGetSmart(fbckListPv);
%Move longitudinal to top of the list
I = strmatch('Longitudinal', fbckListName);
fbckListName = [fbckListName(I); fbckListName];
fbckListName(I+1) = [];
fbckListPv = [fbckListPv(I) fbckListPv];
fbckListPv(I+1) = [];

remove =  [strmatch('',fbckListName,'exact') ;strmatch('LaunchLoop',fbckListName) ] ;
fbckListPv(remove) = [];
fbckListName(remove) = [];

handles.fbckListPv = fbckListPv;
handles.fbckNameStr = fbckListName{1};

guidata(hObject, handles);
handles.dataList =  {'fbckListPv'  'devnames'  'pvs'  'fbckdata'  'ts'  'egu' 'fbckNameStr'};

set(handles.fbckName, 'String',fbckListName);
set(handles.fbckPv, 'String', fbckListPv{1}(1:end-5))
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using fbckPlotter.
if strcmp(get(hObject,'Visible'),'off')
    plot(magic(ceil(5+10*rand)));
    set(gca,'Visible', 'Off')
end


% UIWAIT makes fbckPlotter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fbckPlotter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in getData.
function getData_Callback(hObject, eventdata, handles)
% hObject    handle to getData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.fbckName,'Value');
fbckPv = handles.fbckListPv(val);
switch fbckPv{:}
    case 'FBCK:FB04:LG01:NAME'
        devnames = {'ACCL:IN20:400:L0B_ADES';'ACCL:LI21:1:L1S_ADES';'ACCL:LI21:1:L1S_PDES';'ACCL:LI22:1:ADES';'ACCL:LI22:1:PDES';'ACCL:LI25:1:ADES';'DL1.Energy';'BC1.Energy';'BC1.Current';'BC2.Energy';'BC2.Current';'DL2.Energy';'BPMS:IN20:731:X';'BPMS:IN20:981:X';'BPMS:LI21:233:X';'BLEN:LI21:265:AIMAXF2';'BPMS:LI24:801:X';'BLEN:LI24:886:BIMAXF2';'BPMS:BSY0:52:X';'BPMS:LTU1:250:X';'BPMS:LTU1:450:X';'BPMS:LTU0:170:Y'};
        pvs = {'FBCK:FB04:LG01:A1P1HST_S';'FBCK:FB04:LG01:A2P1HST_S';'FBCK:FB04:LG01:A3P1HST_S';'FBCK:FB04:LG01:A4P1HST_S';'FBCK:FB04:LG01:A5P1HST_S';'FBCK:FB04:LG01:A6P1HST_S';'FBCK:FB04:LG01:S1P1HST_S';'FBCK:FB04:LG01:S2P1HST_S';'FBCK:FB04:LG01:S3P1HST_S';'FBCK:FB04:LG01:S4P1HST_S';'FBCK:FB04:LG01:S5P1HST_S';'FBCK:FB04:LG01:S6P1HST_S';'FBCK:FB04:LG01:M1P1HST_S';'FBCK:FB04:LG01:M2P1HST_S';'FBCK:FB04:LG01:M3P1HST_S';'FBCK:FB04:LG01:M4P1HST_S';'FBCK:FB04:LG01:M5P1HST_S';'FBCK:FB04:LG01:M6P1HST_S';'FBCK:FB04:LG01:M7P1HST_S';'FBCK:FB04:LG01:M8P1HST_S';'FBCK:FB04:LG01:M9P1HST_S';'FBCK:FB04:LG01:M10P1HST_S'};
    case 'FBCK:FB01:TR01:NAME'
        devnames = {'XCOR:IN20:221:BCTRL';'YCOR:IN20:222:BCTRL';'XCOR:IN20:311:BCTRL';'YCOR:IN20:312:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:IN20:371:X';'BPMS:IN20:425:X';'BPMS:IN20:511:X';'BPMS:IN20:525:X';'BPMS:IN20:581:X';'BPMS:IN20:631:X';'BPMS:IN20:651:X';'BPMS:IN20:371:Y';'BPMS:IN20:425:Y';'BPMS:IN20:511:Y';'BPMS:IN20:525:Y';'BPMS:IN20:581:Y';'BPMS:IN20:631:Y';'BPMS:IN20:651:Y'};
        pvs = {'FBCK:FB01:TR01:A1HST';'FBCK:FB01:TR01:A2HST';'FBCK:FB01:TR01:A3HST';'FBCK:FB01:TR01:A4HST';'FBCK:FB01:TR01:S1HST';'FBCK:FB01:TR01:S1DESHST';'FBCK:FB01:TR01:S2HST';'FBCK:FB01:TR01:S2DESHST';'FBCK:FB01:TR01:S3HST';'FBCK:FB01:TR01:S3DESHST';'FBCK:FB01:TR01:S4HST';'FBCK:FB01:TR01:S4DESHST';'FBCK:FB01:TR01:M1HST';'FBCK:FB01:TR01:M2HST';'FBCK:FB01:TR01:M3HST';'FBCK:FB01:TR01:M4HST';'FBCK:FB01:TR01:M5HST';'FBCK:FB01:TR01:M6HST';'FBCK:FB01:TR01:M7HST';'FBCK:FB01:TR01:M8HST';'FBCK:FB01:TR01:M9HST';'FBCK:FB01:TR01:M10HST';'FBCK:FB01:TR01:M11HST';'FBCK:FB01:TR01:M12HST';'FBCK:FB01:TR01:M13HST';'FBCK:FB01:TR01:M14HST'};
    case 'FBCK:FB01:TR02:NAME'
        devnames = {'XCOR:IN20:381:BCTRL';'XCOR:IN20:521:BCTRL';'YCOR:IN20:382:BCTRL';'YCOR:IN20:522:BCTRL';'XPos';'XPos SP';'XAng';'XAng SP';'YPos';'YPos SP';'YAng';'YAng SP';'BPMS:IN20:525:X';'BPMS:IN20:581:X';'BPMS:IN20:631:X';'BPMS:IN20:651:X';'BPMS:IN20:771:X';'BPMS:IN20:781:X';'BPMS:IN20:525:Y';'BPMS:IN20:581:Y';'BPMS:IN20:631:Y';'BPMS:IN20:651:Y';'BPMS:IN20:771:Y';'BPMS:IN20:781:Y'};
        pvs = {'FBCK:FB01:TR02:A1HST';'FBCK:FB01:TR02:A2HST';'FBCK:FB01:TR02:A3HST';'FBCK:FB01:TR02:A4HST';'FBCK:FB01:TR02:S1HST';'FBCK:FB01:TR02:S1DESHST';'FBCK:FB01:TR02:S2HST';'FBCK:FB01:TR02:S2DESHST';'FBCK:FB01:TR02:S3HST';'FBCK:FB01:TR02:S3DESHST';'FBCK:FB01:TR02:S4HST';'FBCK:FB01:TR02:S4DESHST';'FBCK:FB01:TR02:M1HST';'FBCK:FB01:TR02:M2HST';'FBCK:FB01:TR02:M3HST';'FBCK:FB01:TR02:M4HST';'FBCK:FB01:TR02:M5HST';'FBCK:FB01:TR02:M6HST';'FBCK:FB01:TR02:M7HST';'FBCK:FB01:TR02:M8HST';'FBCK:FB01:TR02:M9HST';'FBCK:FB01:TR02:M10HST';'FBCK:FB01:TR02:M11HST';'FBCK:FB01:TR02:M12HST'};
    case 'FBCK:FB01:TR03:NAME'
        devnames = {'XCOR:LI21:101:BCTRL';'YCOR:LI21:136:BCTRL';'X Position';'X Position SP';'Y Position';'Y Position SP';'BPMS:LI21:201:X';'BPMS:LI21:201:Y'};
        pvs = {'FBCK:FB01:TR03:A1HST';'FBCK:FB01:TR03:A2HST';'FBCK:FB01:TR03:S1HST';'FBCK:FB01:TR03:S1DESHST';'FBCK:FB01:TR03:S2HST';'FBCK:FB01:TR03:S2DESHST';'FBCK:FB01:TR03:M1HST';'FBCK:FB01:TR03:M2HST'};
    case 'FBCK:FB01:TR04:NAME'
        devnames = {'XCOR:LI21:275:BCTRL';'XCOR:LI21:302:BCTRL';'YCOR:LI21:276:BCTRL';'YCOR:LI21:303:BCTRL';'X.Position';'X.Position SP';'X.Angle';'X.Angle SP';'Y.Position';'Y.Position SP';'Y.Angle';'Y.Angle SP';'BPMS:LI21:301:X';'BPMS:LI21:401:X';'BPMS:LI21:501:X';'BPMS:LI21:601:X';'BPMS:LI21:701:X';'BPMS:LI21:801:X';'BPMS:LI21:901:X';'BPMS:LI21:301:Y';'BPMS:LI21:401:Y';'BPMS:LI21:501:Y';'BPMS:LI21:601:Y';'BPMS:LI21:701:Y';'BPMS:LI21:801:Y';'BPMS:LI21:901:Y'};
        pvs = {'FBCK:FB01:TR04:A1HST';'FBCK:FB01:TR04:A2HST';'FBCK:FB01:TR04:A3HST';'FBCK:FB01:TR04:A4HST';'FBCK:FB01:TR04:S1HST';'FBCK:FB01:TR04:S1DESHST';'FBCK:FB01:TR04:S2HST';'FBCK:FB01:TR04:S2DESHST';'FBCK:FB01:TR04:S3HST';'FBCK:FB01:TR04:S3DESHST';'FBCK:FB01:TR04:S4HST';'FBCK:FB01:TR04:S4DESHST';'FBCK:FB01:TR04:M1HST';'FBCK:FB01:TR04:M2HST';'FBCK:FB01:TR04:M3HST';'FBCK:FB01:TR04:M4HST';'FBCK:FB01:TR04:M5HST';'FBCK:FB01:TR04:M6HST';'FBCK:FB01:TR04:M7HST';'FBCK:FB01:TR04:M8HST';'FBCK:FB01:TR04:M9HST';'FBCK:FB01:TR04:M10HST';'FBCK:FB01:TR04:M11HST';'FBCK:FB01:TR04:M12HST';'FBCK:FB01:TR04:M13HST';'FBCK:FB01:TR04:M14HST'};
    case 'FBCK:FB02:TR01:NAME'
        devnames = {'XCOR:LI25:202:BCTRL';'XCOR:LI25:602:BCTRL';'YCOR:LI24:900:BCTRL';'YCOR:LI25:503:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:LI25:701:X';'BPMS:LI25:801:X';'BPMS:LI25:901:X';'BPMS:LI26:201:X';'BPMS:LI26:301:X';'BPMS:LI26:401:X';'BPMS:LI26:501:X';'BPMS:LI26:601:X';'BPMS:LI26:701:X';'BPMS:LI26:801:X';'BPMS:LI26:901:X';'BPMS:LI27:301:X';'BPMS:LI27:401:X';'BPMS:LI27:701:X';'BPMS:LI27:801:X';'BPMS:LI25:701:Y';'BPMS:LI25:801:Y';'BPMS:LI25:901:Y';'BPMS:LI26:201:Y';'BPMS:LI26:301:Y';'BPMS:LI26:401:Y';'BPMS:LI26:501:Y';'BPMS:LI26:601:Y';'BPMS:LI26:701:Y';'BPMS:LI26:801:Y';'BPMS:LI26:901:Y';'BPMS:LI27:301:Y';'BPMS:LI27:401:Y';'BPMS:LI27:701:Y';'BPMS:LI27:801:Y'};
        pvs = {'FBCK:FB02:TR01:A1HST';'FBCK:FB02:TR01:A2HST';'FBCK:FB02:TR01:A3HST';'FBCK:FB02:TR01:A4HST';'FBCK:FB02:TR01:S1HST';'FBCK:FB02:TR01:S1DESHST';'FBCK:FB02:TR01:S2HST';'FBCK:FB02:TR01:S2DESHST';'FBCK:FB02:TR01:S3HST';'FBCK:FB02:TR01:S3DESHST';'FBCK:FB02:TR01:S4HST';'FBCK:FB02:TR01:S4DESHST';'FBCK:FB02:TR01:M1HST';'FBCK:FB02:TR01:M2HST';'FBCK:FB02:TR01:M3HST';'FBCK:FB02:TR01:M4HST';'FBCK:FB02:TR01:M5HST';'FBCK:FB02:TR01:M6HST';'FBCK:FB02:TR01:M7HST';'FBCK:FB02:TR01:M8HST';'FBCK:FB02:TR01:M9HST';'FBCK:FB02:TR01:M10HST';'FBCK:FB02:TR01:M11HST';'FBCK:FB02:TR01:M12HST';'FBCK:FB02:TR01:M13HST';'FBCK:FB02:TR01:M14HST';'FBCK:FB02:TR01:M15HST';'FBCK:FB02:TR01:M16HST';'FBCK:FB02:TR01:M17HST';'FBCK:FB02:TR01:M18HST';'FBCK:FB02:TR01:M19HST';'FBCK:FB02:TR01:M20HST';'FBCK:FB02:TR01:M21HST';'FBCK:FB02:TR01:M22HST';'FBCK:FB02:TR01:M23HST';'FBCK:FB02:TR01:M24HST';'FBCK:FB02:TR01:M25HST';'FBCK:FB02:TR01:M26HST';'FBCK:FB02:TR01:M27HST';'FBCK:FB02:TR01:M28HST';'FBCK:FB02:TR01:M29HST';'FBCK:FB02:TR01:M30HST'};
    case 'FBCK:FB02:TR02:NAME'
        devnames = {'XCOR:LI28:202:BCTRL';'XCOR:LI28:602:BCTRL';'YCOR:LI27:900:BCTRL';'YCOR:LI28:503:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:LI28:601:X';'BPMS:LI28:701:X';'BPMS:LI28:801:X';'BPMS:LI28:901:X';'BPMS:LI29:201:X';'BPMS:LI29:301:X';'BPMS:LI29:401:X';'BPMS:LI29:501:X';'BPMS:LI28:601:Y';'BPMS:LI28:701:Y';'BPMS:LI28:801:Y';'BPMS:LI28:901:Y';'BPMS:LI29:201:Y';'BPMS:LI29:301:Y';'BPMS:LI29:401:Y';'BPMS:LI29:501:Y'};
        pvs = {'FBCK:FB02:TR02:A1HST';'FBCK:FB02:TR02:A2HST';'FBCK:FB02:TR02:A3HST';'FBCK:FB02:TR02:A4HST';'FBCK:FB02:TR02:S1HST';'FBCK:FB02:TR02:S1DESHST';'FBCK:FB02:TR02:S2HST';'FBCK:FB02:TR02:S2DESHST';'FBCK:FB02:TR02:S3HST';'FBCK:FB02:TR02:S3DESHST';'FBCK:FB02:TR02:S4HST';'FBCK:FB02:TR02:S4DESHST';'FBCK:FB02:TR02:M1HST';'FBCK:FB02:TR02:M2HST';'FBCK:FB02:TR02:M3HST';'FBCK:FB02:TR02:M4HST';'FBCK:FB02:TR02:M5HST';'FBCK:FB02:TR02:M6HST';'FBCK:FB02:TR02:M7HST';'FBCK:FB02:TR02:M8HST';'FBCK:FB02:TR02:M9HST';'FBCK:FB02:TR02:M10HST';'FBCK:FB02:TR02:M11HST';'FBCK:FB02:TR02:M12HST';'FBCK:FB02:TR02:M13HST';'FBCK:FB02:TR02:M14HST';'FBCK:FB02:TR02:M15HST';'FBCK:FB02:TR02:M16HST'};
    case 'FBCK:FB01:TR05:NAME'
        devnames = {'XCOR:BSY0:34:BCTRL';'XCOR:BSY0:60:BCTRL';'YCOR:BSY0:35:BCTRL';'YCOR:BSY0:62:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:BSY0:61:X';'BPMS:BSY0:63:X';'BPMS:BSY0:83:X';'BPMS:BSY0:85:X';'BPMS:BSY0:88:X';'BPMS:BSY0:61:Y';'BPMS:BSY0:63:Y';'BPMS:BSY0:83:Y';'BPMS:BSY0:85:Y';'BPMS:BSY0:88:Y'};
        pvs = {'FBCK:FB01:TR05:A1HST';'FBCK:FB01:TR05:A2HST';'FBCK:FB01:TR05:A3HST';'FBCK:FB01:TR05:A4HST';'FBCK:FB01:TR05:S1HST';'FBCK:FB01:TR05:S1DESHST';'FBCK:FB01:TR05:S2HST';'FBCK:FB01:TR05:S2DESHST';'FBCK:FB01:TR05:S3HST';'FBCK:FB01:TR05:S3DESHST';'FBCK:FB01:TR05:S4HST';'FBCK:FB01:TR05:S4DESHST';'FBCK:FB01:TR05:M1HST';'FBCK:FB01:TR05:M2HST';'FBCK:FB01:TR05:M3HST';'FBCK:FB01:TR05:M4HST';'FBCK:FB01:TR05:M5HST';'FBCK:FB01:TR05:M6HST';'FBCK:FB01:TR05:M7HST';'FBCK:FB01:TR05:M8HST';'FBCK:FB01:TR05:M9HST';'FBCK:FB01:TR05:M10HST'};
    case 'FBCK:FB02:TR04:NAME'
        devnames = {'XCOR:LTU1:738:BCTRL';'XCOR:LTU1:818:BCTRL';'XCOR:LTU1:878:BCTRL';'YCOR:LTU1:747:BCTRL';'YCOR:LTU1:837:BCTRL';'YCOR:LTU1:857:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:UND1:100:X';'BPMS:UND1:190:X';'BPMS:UND1:290:X';'BPMS:UND1:390:X';'BPMS:UND1:490:X';'BPMS:UND1:590:X';'BPMS:UND1:690:X';'BPMS:UND1:790:X';'BPMS:UND1:890:X';'BPMS:UND1:990:X';'BPMS:UND1:1090:X';'BPMS:UND1:100:Y';'BPMS:UND1:190:Y';'BPMS:UND1:290:Y';'BPMS:UND1:390:Y';'BPMS:UND1:490:Y';'BPMS:UND1:590:Y';'BPMS:UND1:690:Y';'BPMS:UND1:790:Y';'BPMS:UND1:890:Y';'BPMS:UND1:990:Y';'BPMS:UND1:1090:Y'};
        pvs = {'FBCK:FB02:TR04:A1HST';'FBCK:FB02:TR04:A2HST';'FBCK:FB02:TR04:A3HST';'FBCK:FB02:TR04:A4HST';'FBCK:FB02:TR04:A5HST';'FBCK:FB02:TR04:A6HST';'FBCK:FB02:TR04:S1HST';'FBCK:FB02:TR04:S1DESHST';'FBCK:FB02:TR04:S2HST';'FBCK:FB02:TR04:S2DESHST';'FBCK:FB02:TR04:S3HST';'FBCK:FB02:TR04:S3DESHST';'FBCK:FB02:TR04:S4HST';'FBCK:FB02:TR04:S4DESHST';'FBCK:FB02:TR04:M1HST';'FBCK:FB02:TR04:M2HST';'FBCK:FB02:TR04:M3HST';'FBCK:FB02:TR04:M4HST';'FBCK:FB02:TR04:M5HST';'FBCK:FB02:TR04:M6HST';'FBCK:FB02:TR04:M7HST';'FBCK:FB02:TR04:M8HST';'FBCK:FB02:TR04:M9HST';'FBCK:FB02:TR04:M10HST';'FBCK:FB02:TR04:M11HST';'FBCK:FB02:TR04:M12HST';'FBCK:FB02:TR04:M13HST';'FBCK:FB02:TR04:M14HST';'FBCK:FB02:TR04:M15HST';'FBCK:FB02:TR04:M16HST';'FBCK:FB02:TR04:M17HST';'FBCK:FB02:TR04:M18HST';'FBCK:FB02:TR04:M19HST';'FBCK:FB02:TR04:M20HST';'FBCK:FB02:TR04:M21HST';'FBCK:FB02:TR04:M22HST'};
    case 'FBCK:FB03:TR01:NAME'
        devnames = {'XCOR:LTU1:488:BCTRL';'XCOR:LTU1:558:BCTRL';'YCOR:LTU1:493:BCTRL';'YCOR:LTU1:593:BCTRL';'X.Pos';'X.Pos SP';'X.Ang';'X.Ang SP';'Y.Pos';'Y.Pos SP';'Y.Ang';'Y.Ang SP';'BPMS:LTU1:620:X';'BPMS:LTU1:640:X';'BPMS:LTU1:660:X';'BPMS:LTU1:680:X';'BPMS:LTU1:720:X';'BPMS:LTU1:730:X';'BPMS:LTU1:740:X';'BPMS:LTU1:750:X';'BPMS:LTU1:760:X';'BPMS:LTU1:770:X';'BPMS:LTU1:620:Y';'BPMS:LTU1:640:Y';'BPMS:LTU1:660:Y';'BPMS:LTU1:680:Y';'BPMS:LTU1:720:Y';'BPMS:LTU1:730:Y';'BPMS:LTU1:740:Y';'BPMS:LTU1:750:Y';'BPMS:LTU1:760:Y';'BPMS:LTU1:770:Y'};
        pvs = {'FBCK:FB03:TR01:A1HST';'FBCK:FB03:TR01:A2HST';'FBCK:FB03:TR01:A3HST';'FBCK:FB03:TR01:A4HST';'FBCK:FB03:TR01:S1HST';'FBCK:FB03:TR01:S1DESHST';'FBCK:FB03:TR01:S2HST';'FBCK:FB03:TR01:S2DESHST';'FBCK:FB03:TR01:S3HST';'FBCK:FB03:TR01:S3DESHST';'FBCK:FB03:TR01:S4HST';'FBCK:FB03:TR01:S4DESHST';'FBCK:FB03:TR01:M1HST';'FBCK:FB03:TR01:M2HST';'FBCK:FB03:TR01:M3HST';'FBCK:FB03:TR01:M4HST';'FBCK:FB03:TR01:M5HST';'FBCK:FB03:TR01:M6HST';'FBCK:FB03:TR01:M7HST';'FBCK:FB03:TR01:M8HST';'FBCK:FB03:TR01:M9HST';'FBCK:FB03:TR01:M10HST';'FBCK:FB03:TR01:M11HST';'FBCK:FB03:TR01:M12HST';'FBCK:FB03:TR01:M13HST';'FBCK:FB03:TR01:M14HST';'FBCK:FB03:TR01:M15HST';'FBCK:FB03:TR01:M16HST';'FBCK:FB03:TR01:M17HST';'FBCK:FB03:TR01:M18HST';'FBCK:FB03:TR01:M19HST';'FBCK:FB03:TR01:M20HST'};
        %case 'FBCK:FB03:TR04:NAME'

        %case 'FBCK:FB03:TR05:NAME'
    otherwise warndlg(sprintf('Sorry %s name is not supported',fbckPv{:}));
        return

end
handles.devnames = devnames;
handles.pvs = pvs;
[handles.fbckdata ts] = lcaGetSmart(pvs);
handles.ts = now;
handles.egu  = lcaGetSmart(strcat(pvs,'.EGU'));
%handles.wfts = epics2matlabTime(wfts);

%set(handles.fbckName, 'String', devnames)
set(handles.yaxis, 'String', devnames)
set(handles.xaxis, 'String', devnames)
% Update handles structure
guidata(hObject, handles);



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in fbckName.
function fbckName_Callback(hObject, eventdata, handles)
% hObject    handle to fbckName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fbckName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fbckName
val = get(hObject,'Value');
str = get(hObject, 'String');
handles.fbckNameStr = str{val};
guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function fbckName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fbckName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doPlot.
function doPlot_Callback(hObject, eventdata, handles)
% hObject    handle to doPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xIndx = get(handles.xaxis, 'Value');
yIndx = get(handles.yaxis, 'Value');

[a r] = size(handles.fbckdata);
r=1:r;

plotType = get(handles.plotType,'String');
plt = get(handles.plotType,'Value');
plotType = plotType{plt};
if get(handles.newFig, 'Value'), 
    figH = figure;
    handles.figH = figH;
else
    figH = handles.figH;
end
figure(figH)
clf
switch plotType
    case 'X '
        plot(r,handles.fbckdata(xIndx,r), '-o')
        ylabel(makeLabel(handles, yIndx));
    case 'X vs Y'
        plot(handles.fbckdata(xIndx,r),handles.fbckdata(yIndx,r), 'o')
        xlabel(makeLabel(handles, xIndx));
        ylabel(makeLabel(handles, yIndx));
    case 'X and Y'
        clf
        [AX H1 H2] = plotyy(r,handles.fbckdata(xIndx,r),r,handles.fbckdata(yIndx,r));
        set(get(AX(1),'Ylabel'),'String',makeLabel(handles, xIndx))
        set(get(AX(2),'Ylabel'),'String',makeLabel(handles, yIndx))
    case 'X Histogram'
        hist(handles.fbckdata(xIndx,r),50)
        xlabel(makeLabel(handles, xIndx));
        ylabel('Counts')
    case 'Actuators'
        switch handles.fbckNameStr
            case 'Longitudinal'
                I = strmatch('ACCL', handles.devnames);

            otherwise
                I = [strmatch('XCOR', handles.devnames); strmatch('YCOR', handles.devnames)];

        end
        plot(r, handles.fbckdata(I, r))
        legH = legend(handles.devnames(I));
        ylabel(handles.egu(I(1)))
        set(legH,'FontSize',10,'Interpreter', 'none')
    case 'States'
        switch handles.fbckNameStr
            case 'Longitudinal'
                matchList1 = { 'DL1.Energy' 'BC1.Energy'   'BC2.Energy'   'DL2.Energy' };
                matchList2 = { 'BC1.Current'   'BC2.Current' };
            otherwise
                matchList1 = {  'XPos' 'YPos' 'X.Position' 'Y.Position'  'X Position' 'Y Position' };               
                matchList2 = {  'XAng' 'YAng'  'X.Angle' 'Y.Angle' 'X Angle' 'Y Angle'};      
        end
        [dummy I1]  = intersect( handles.devnames, matchList1); %#ok<NASGU,ASGLU>
        [dummy I2] =  intersect( handles.devnames, matchList2);  %#ok<NASGU>
        subplot(211), plot(r, handles.fbckdata(I1, r));  legend(handles.devnames(I1),'FontSize',10); ylabel(handles.egu(I1(1)))
        subplot(212), plot(r, handles.fbckdata(I2, r));  legend(handles.devnames(I2),'FontSize',10); ylabel(handles.egu(I2(1)))
    case 'Measurements'
        I = strmatch('BPMS', handles.devnames);
        switch handles.fbckNameStr
            case 'Longitudinal', I1 = strmatch('BLEN', handles.devnames);
            otherwise, I1 = [];
        end
        if any(I1), subplot(211)
            plot(r, handles.fbckdata(I1, r))
            legend(handles.devnames(I1),'Location','EastOutside','FontSize',10);
            ylabel(handles.egu(I1(1)))
            subplot(212)
        end
        plot(r, handles.fbckdata(I, r))
        legend(handles.devnames(I),'Location','EastOutside','FontSize',10);
        ylabel(handles.egu(I(1)))

    case 'FFT (Soon...)', warndlg('Someday!... :(')


end
% List of fields for config file
title(sprintf('%s %s', handles.fbckNameStr, datestr(handles.ts)))
guidata(hObject, handles); 

function labelStr = makeLabel(handles, I)
labelStr = sprintf('%s (%s)', handles.devnames{I}, handles.egu{I});




% --- Executes on selection change in yaxis.
function yaxis_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns yaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yaxis


% --- Executes during object creation, after setting all properties.
function yaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotType.
function plotType_Callback(hObject, eventdata, handles)
% hObject    handle to plotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns plotType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotType
val = get(hObject, 'Value');
str = get(hObject, 'String');
strVal = str{val};
xH = [handles.textX handles.xaxis];
yH = [handles.textY handles.yaxis];
switch strVal
    case 'X ', set(xH,'Visible', 'On'), set(yH,'Visible', 'Off'),
    case 'X vs Y', set(xH,'Visible', 'On'), set(yH,'Visible', 'On'),
    case 'X and Y',set(xH,'Visible', 'On'), set(yH,'Visible', 'On'),
    case 'X Histogram',set(xH,'Visible', 'On'), set(yH,'Visible', 'Off'),
    case 'Actuators',set(xH,'Visible', 'Off'), set(yH,'Visible', 'Off'),
    case 'States',set(xH,'Visible', 'Off'), set(yH,'Visible', 'Off'),
    case 'Measurements',set(xH,'Visible', 'Off'), set(yH,'Visible', 'Off'),
    case 'FFT (Soon...)',set(xH,'Visible', 'Off'), set(yH,'Visible', 'Off'),
  

    otherwise,
end



% --- Executes during object creation, after setting all properties.
function plotType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1


% --- Executes on selection change in xaxis.
function xaxis_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns xaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xaxis


% --- Executes during object creation, after setting all properties.
function xaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newFig.
function newFig_Callback(hObject, eventdata, handles)
% hObject    handle to newFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of newFig


% --- Executes during object creation, after setting all properties.
function newFig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

util_appClose(hObject);


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Tag'), 'saveAs'), showDlg = 1; else showDlg = 0; end
for tag=handles.dataList
    data.(tag{:})=handles.(tag{:});
end
I = get(handles.fbckName,'Value');
name = get(handles.fbckName,'String');
name = name{I};
[fileName, pathName] = util_dataSave(data, 'fbckPlots', name, handles.ts, showDlg);
if any(fileName)
    fprintf('%s Saved %s/%s\n', datestr(now), pathName, fileName)
else
    fprintf('%s Nothing saved\n', datestr(now))
end



% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[data, fileName] = util_dataLoad;
if ~any(fileName), return, end
try
    for tag=handles.dataList
        handles.(tag{:})=data.(tag{:});
    end
catch
    fprintf('%s Failed to load%s\n', datestr(now), fileName)
end
set(handles.xaxis, 'String', handles.devnames);
set(handles.yaxis, 'String', handles.devnames);
guidata(hObject, handles); 

fprintf('%s Loaded file: %s\n', datestr(now), fileName)
