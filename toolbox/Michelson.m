function varargout = Michelson(varargin)
% MICHELSON M-fileaveraged for Michelson.fig
%      MICHELSON, by itself, creates a new MICHELSON or raises the existing
%      singleton*.
%
%      H = MICHELSON returns the handle to a new MICHELSON or the handle to
%      the existing singleton*.
%
%      MICHELSON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MICHELSON.M with the given input arguments.
%
%      MICHELSON('Property','Value',...) creates a new MICHELSON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Michelson_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Michelson_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last revision: 2012-09-28
% Edit the above text to modify the response to help Michelson

% Last Modified by GUIDE v2.5 28-May-2015 17:26:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Michelson_OpeningFcn, ...
                   'gui_OutputFcn',  @Michelson_OutputFcn, ...
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



% --- Executes just before Michelson is made visible.
function Michelson_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Michelson (see VARARGIN)

% Choose default command line output for Michelson
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Michelson wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global THzSource refHigh refLow source ch description
global nAverage scopeAverage smooth mode
global motorNumber motorPV start stop step
global PauseScan StopScan x mStep maxTStampDiff
global nSig nNorm normNum normOp normDenom

sys = getSystem();
if strcmp(sys,'SYS0')
    THzSource = 'lcls';
elseif strcmp(sys,'SYS1')
    THzSource = 'facet';
end

description = cell(5,1);
description{1} = get(handles.SigADesc,'String');
description{2} = get(handles.SigBDesc,'String');
description{3} = get(handles.SigCDesc,'String');
description{4} = get(handles.SigDDesc,'String');
description{5} = get(handles.SigEDesc,'String');

motorPV = '';
nSig = 3;
switch THzSource
    case 'lcls'
        source = [4 4  2 8 8];
        ch     = [3 4 17 3 5];
        % motorNumber = 16;
        % start = 15;
        % stop  = 25;
        motorNumber = -1;
        motorPV = 'TIME';
        start = 0;
        stop = 120;
        step = 1;
        smooth = 0;
        nNorm = 0;
        normNum   = [0, 0, 0, 0];
        sourceString = {'Scope';...
                        'Struck 3301';...
                        'CAEN Digitizer';...
                        'SLAC Digitizer';...
                        'Acromag Digitizer';...
                        'Lock-In Amplifier';...
                        'Mass Spectrometer';...
                        'None'};
        set(handles.SigAIntegral,         'Value',1)
        set(handles.SigBIntegral,         'Value',1)
        set(handles.SigCBkgdGetBefore,    'Value',0)
        set(handles.SigCBkgd,             'Visible','on')
        set(handles.SigCBkgdFromTraceText,'Visible','on')
        set(handles.SigCBkgdGetBeforeText,'Visible','on')
        set(handles.SigCIntegral,         'Value',1)
        set(handles.SigCGetVal,           'Visible','on')
        set(handles.SigCMaxMinText,       'Visible','on')
        set(handles.SigCIntegralText,     'Visible','on')
        
    case 'facet'
        source = [2 2 6 6 6];
        ch     = [4 7 5 6 1];
        motorNumber = 9;
        start = 1;
        stop  = 5.3;
        step = 0.01;
        smooth = 3;
        nNorm = 1;
        normNum   = [2, 0, 0, 0];
        sourceString = {'Scope';...
                        'Struck 3301';...
                        'CAEN Digitizer';...
                        'SLAC Digitizer';...
                        'Digitizer RAW';...
                        'None'};
        set(handles.SigAMaxMin,           'Value',1)
        set(handles.SigBMaxMin,           'Value',1)
        set(handles.SigCBkgdFromTrace,    'Value',1)
        set(handles.SigCBkgd,             'Visible','off')
        set(handles.SigCBkgdFromTraceText,'Visible','off')
        set(handles.SigCBkgdGetBeforeText,'Visible','off')
        set(handles.SigCMaxMin,           'Value',1)
        set(handles.SigCGetVal,           'Visible','off')
        set(handles.SigCMaxMinText,       'Visible','off')
        set(handles.SigCIntegralText,     'Visible','off')
end

set(handles.SigABkgdFromTrace,    'Value',1)
set(handles.SigABkgd,             'Visible','on')
set(handles.SigABkgdGetBeforeText,'Visible','on')
set(handles.SigABkgdFromTraceText,'Visible','on')
set(handles.SigAGetVal,           'Visible','on')
set(handles.SigAMaxMinText,       'Visible','on')
set(handles.SigAIntegralText,     'Visible','on')

set(handles.SigBBkgdFromTrace,    'Value',1)
set(handles.SigBBkgd,             'Visible','on')
set(handles.SigBBkgdFromTraceText,'Visible','on')
set(handles.SigBBkgdGetBeforeText,'Visible','on')
set(handles.SigBGetVal,           'Visible','on')
set(handles.SigBMaxMinText,       'Visible','on')
set(handles.SigBIntegralText,     'Visible','on')

set(handles.SigDBkgdFromTrace,    'Value',1)
set(handles.SigDBkgd,             'Visible','off')
set(handles.SigDBkgdFromTraceText,'Visible','off')
set(handles.SigDBkgdGetBeforeText,'Visible','off')
set(handles.SigDMaxMin,           'Value',1)
set(handles.SigDGetVal,           'Visible','off')
set(handles.SigDMaxMinText,       'Visible','off')
set(handles.SigDIntegralText,     'Visible','off')

set(handles.SigEBkgdFromTrace,    'Value',1)
set(handles.SigEBkgd,             'Visible','off')
set(handles.SigEBkgdFromTraceText,'Visible','off')
set(handles.SigEBkgdGetBeforeText,'Visible','off')
set(handles.SigEMaxMin,           'Value',1)
set(handles.SigEGetVal,           'Visible','off')
set(handles.SigEMaxMinText,       'Visible','off')
set(handles.SigEIntegralText,     'Visible','off')

set(handles.LogAll,          'Value',1)
set(handles.SaveAveraged,    'Value',1)
set(handles.SaveMeasurements,'Value',0)
set(handles.SaveWaveforms,   'Value',0)

if strcmp(THzSource,'lcls')
    set(handles.FileWaveforms,   'Visible','off')
    set(handles.SaveWaveforms,   'Visible','off')
end

mode = 1;
nAverage = 1;
scopeAverage = 1;
x = start;
mStep = 1;
refHigh = 1.3;
refLow  = 0.75;

set(handles.RefHigh,   'String',num2str(refHigh))
set(handles.RefLow,    'String',num2str(refLow))
set(handles.Mode,      'Value', mode)
maxTStampDiff = str2double(get(handles.TDiff,'String'));

set(handles.SigASource,'Value', source(1))
set(handles.SigBSource,'Value', source(2))
set(handles.SigCSource,'Value', source(3))
set(handles.SigDSource,'Value', source(4))
set(handles.SigESource,'Value', source(5))

set(handles.SigASource,'String',sourceString(1:length(sourceString)-1))
set(handles.SigBSource,'String',sourceString)
set(handles.SigCSource,'String',sourceString)
set(handles.SigDSource,'String',sourceString)
set(handles.SigESource,'String',sourceString)

set(handles.SigAChan,  'String',num2str(ch(1)))
set(handles.SigBChan,  'String',num2str(ch(2)))
set(handles.SigCChan,  'String',num2str(ch(3)))
set(handles.SigDChan,  'String',num2str(ch(4)))
set(handles.SigEChan,  'String',num2str(ch(5)))

if motorNumber > -1
    set(handles.Motor, 'String',num2str(motorNumber))
else
    set(handles.Motor, 'String',motorPV)
end
set(handles.Start,     'String',num2str(start))
set(handles.Stop,      'String',num2str(stop))
set(handles.Averages,  'String',num2str(nAverage))
set(handles.ScopeAv,   'String',num2str(scopeAverage))
set(handles.Smooth,    'String',num2str(smooth));
set(handles.Step,      'String',num2str(step))
set(handles.StartText, 'String','Start Position')
set(handles.StopText,  'String','Stop Position')
set(handles.Step,      'Visible','on')
set(handles.StepText,  'Visible','on')

status = '';
set(handles.Status,   'String',status)

normOp    = [4, 4, 4, 4];
normDenom = [1, 1, 1, 1];
set(handles.NormNum1,  'Value',normNum(1)+1)
set(handles.NormNum2,  'Value',normNum(2)+1)
set(handles.NormNum3,  'Value',normNum(3)+1)
set(handles.NormNum4,  'Value',normNum(4)+1)
set(handles.NormOp1,   'Value',4)
set(handles.NormOp2,   'Value',4)
set(handles.NormOp3,   'Value',4)
set(handles.NormOp4,   'Value',4)
set(handles.NormDenom1,'Value',normDenom(1))
set(handles.NormDenom2,'Value',normDenom(2))
set(handles.NormDenom3,'Value',normDenom(3))
set(handles.NormDenom4,'Value',normDenom(4))

StopScan  = 0;
PauseScan = 0;
set(handles.StartScan,    'Value', 0)
set(handles.StopScan,     'Value', 0)
set(handles.PauseScan,    'Value', 0)
set(handles.StartScan,    'String','Start Scan')
set(handles.StopScan,     'String','Stop Scan')
set(handles.PauseScan,    'String','Pause Scan')
set(handles.Resume,       'Visible','off')
set(handles.ResumeText,   'Visible','off')
set(handles.BkgdTitleText,'Visible','on')
end



% --- Outputs from this function are returned to the command line.
function varargout = Michelson_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function SelectSource(s,n,handles)
global THzSource source nSig nNorm normNum scopeAverage
smax = 5+2*strcmp(THzSource,'lcls')+(n>1);
if s<1 || s>smax
    s = 1;
    status = [' The source must be between 1 and ',num2str(smax),'.'];
    pause(1)
else
    status = '';
end
set(handles.Status,'String',status)
source(n) = s;

switch n
    case 1
        hBkgd              = handles.SigABkgd;
        hBkgdFromTrace     = handles.SigABkgdFromTrace;
        hBkgdGetBefore     = handles.SigABkgdGetBefore;
        hBkgdFromTraceText = handles.SigABkgdFromTraceText;
        hBkgdGetBeforeText = handles.SigABkgdGetBeforeText;
        hGetVal       = handles.SigAGetVal;
        hMaxMin       = handles.SigAMaxMin;
        hMaxMinText   = handles.SigAMaxMinText;
        hIntegralText = handles.SigAIntegralText;
    case 2
        hBkgd              = handles.SigBBkgd;
        hBkgdFromTrace     = handles.SigBBkgdFromTrace;
        hBkgdGetBefore     = handles.SigBBkgdGetBefore;
        hBkgdFromTraceText = handles.SigBBkgdFromTraceText;
        hBkgdGetBeforeText = handles.SigBBkgdGetBeforeText;
        hGetVal       = handles.SigBGetVal;
        hMaxMin       = handles.SigBMaxMin;
        hMaxMinText   = handles.SigBMaxMinText;
        hIntegralText = handles.SigBIntegralText;
    case 3
        hBkgd              = handles.SigCBkgd;
        hBkgdFromTrace     = handles.SigCBkgdFromTrace;
        hBkgdGetBefore     = handles.SigCBkgdGetBefore;
        hBkgdFromTraceText = handles.SigCBkgdFromTraceText;
        hBkgdGetBeforeText = handles.SigCBkgdGetBeforeText;
        hGetVal       = handles.SigCGetVal;
        hMaxMin       = handles.SigCMaxMin;
        hMaxMinText   = handles.SigCMaxMinText;
        hIntegralText = handles.SigCIntegralText;
    case 4
        hBkgd              = handles.SigDBkgd;
        hBkgdFromTrace     = handles.SigDBkgdFromTrace;
        hBkgdGetBefore     = handles.SigDBkgdGetBefore;
        hBkgdFromTraceText = handles.SigDBkgdFromTraceText;
        hBkgdGetBeforeText = handles.SigDBkgdGetBeforeText;
        hGetVal       = handles.SigDGetVal;
        hMaxMin       = handles.SigDMaxMin;
        hMaxMinText   = handles.SigDMaxMinText;
        hIntegralText = handles.SigDIntegralText;
    case 5
        hBkgd              = handles.SigEBkgd;
        hBkgdFromTrace     = handles.SigEBkgdFromTrace;
        hBkgdGetBefore     = handles.SigEBkgdGetBefore;
        hBkgdFromTraceText = handles.SigEBkgdFromTraceText;
        hBkgdGetBeforeText = handles.SigEBkgdGetBeforeText;
        hGetVal       = handles.SigEGetVal;
        hMaxMin       = handles.SigEMaxMin;
        hMaxMinText   = handles.SigEMaxMinText;
        hIntegralText = handles.SigEIntegralText;
end    

switch s
    case 1  % Scope
        set(hBkgdFromTrace,    'Value', 1)
        set(hBkgdGetBefore,    'Value', 0)
        set(hBkgd,             'Visible','off')
        set(hBkgdFromTraceText,'Visible','off')
        set(hBkgdGetBeforeText,'Visible','off')
        set(hMaxMin,           'Value', 1)
        set(hGetVal,           'Visible','on')
        set(hMaxMinText,       'Visible','on')
        set(hIntegralText,     'Visible','on')
    case 2  % Struck 3301 digitizer
        set(hBkgdFromTrace,    'Value', 1)
        set(hBkgdGetBefore,    'Value', 0)
        set(hBkgd,             'Visible','on')
        set(hBkgdFromTraceText,'Visible','on')
        set(hBkgdGetBeforeText,'Visible','on')
        set(hMaxMin,           'Value', 1)
        set(hGetVal,           'Visible','on')
        set(hMaxMinText,       'Visible','on')
        set(hIntegralText,     'Visible','on')
    case 3  % CAEN charge digitizer
        set(hBkgdFromTrace,    'Value', 0)
        set(hBkgdGetBefore,    'Value', 1)
        set(hBkgd,             'Visible','off')
        set(hBkgdFromTraceText,'Visible','off')
        set(hBkgdGetBeforeText,'Visible','off')
        set(hMaxMin,           'Value', 1)
        set(hGetVal,           'Visible','off')
        set(hMaxMinText,       'Visible','off')
        set(hIntegralText,     'Visible','off')
    case 4  % SLAC "pizza-box" digitizer
        set(hBkgdFromTrace,    'Value', 0)
        set(hBkgdGetBefore,    'Value', 1)
        set(hMaxMin,           'Value', 1)
        set(hGetVal,           'Visible','on')
        set(hMaxMinText,       'Visible','on')
        set(hIntegralText,     'Visible','on')
        set(hBkgd,             'Visible','on')
        set(hBkgdFromTraceText,'Visible','on')
        set(hBkgdGetBeforeText,'Visible','on')
    case 5  % Acromag IP330a digitizer (LCLS) or
            % BRAW integral for bunch length (FACET)
        if strcmp(THzSource,'lcls')
            set(hBkgdFromTrace,    'Value', 0)
            set(hBkgdGetBefore,    'Value', 1)
            set(hBkgd,             'Visible','on')
            set(hBkgdFromTraceText,'Visible','on')
            set(hBkgdGetBeforeText,'Visible','on')
        else
            set(hBkgdFromTrace,    'Value', 1)
            set(hBkgdGetBefore,    'Value', 0)
            set(hBkgd,             'Visible','off')
            set(hBkgdFromTraceText,'Visible','off')
            set(hBkgdGetBeforeText,'Visible','off')
        end
        set(hMaxMin,      'Value', 1)
        set(hGetVal,      'Visible','off')
        set(hMaxMinText,  'Visible','off')
        set(hIntegralText,'Visible','off')
    case 6  % SRS830 lock-in (LCLS) or no signal (FACET)
        if strcmp(THzSource,'lcls')
            set(hBkgdFromTrace,    'Value', 1)
            set(hBkgdGetBefore,    'Value', 0)
            set(hBkgd,             'Visible','off')
            set(hBkgdFromTraceText,'Visible','off')
            set(hBkgdGetBeforeText,'Visible','off')
            set(hMaxMin,           'Value', 1)
            set(hGetVal,           'Visible','off')
            set(hMaxMinText,       'Visible','off')
            set(hIntegralText,     'Visible','off')
        else
            if n<=2
                set(handles.SigBSource,'Value',6)
                set(handles.SigBMaxMin,'Value',1)
                set(handles.SigBBkgd,             'Visible','off')
                set(handles.SigBBkgdFromTraceText,'Visible','off')
                set(handles.SigBBkgdGetBeforeText,'Visible','off')
                set(handles.SigBGetVal,           'Visible','off')
                set(handles.SigBMaxMinText,       'Visible','off')
                set(handles.SigBIntegralText,     'Visible','off')
            end
            if n<=3
                set(handles.SigCSource,'Value',6)
                set(handles.SigCMaxMin,'Value',1)
                set(handles.SigCBkgd,             'Visible','off')
                set(handles.SigCBkgdFromTraceText,'Visible','off')
                set(handles.SigCBkgdGetBeforeText,'Visible','off')
                set(handles.SigCGetVal,           'Visible','off')
                set(handles.SigCMaxMinText,       'Visible','off')
                set(handles.SigCIntegralText,     'Visible','off')
            end
            if n<=4
                set(handles.SigDSource,'Value',6)
                set(handles.SigDMaxMin,'Value',1)
                set(handles.SigDBkgd,             'Visible','off')
                set(handles.SigDBkgdFromTraceText,'Visible','off')
                set(handles.SigDBkgdGetBeforeText,'Visible','off')
                set(handles.SigDGetVal,           'Visible','off')
                set(handles.SigDMaxMinText,       'Visible','off')
                set(handles.SigDIntegralText,     'Visible','off')
            end
            if n<=5
                set(handles.SigESource,'Value',6)
                set(handles.SigEMaxMin,'Value',1)
                set(handles.SigEBkgd,             'Visible','off')
                set(handles.SigEBkgdFromTraceText,'Visible','off')
                set(handles.SigEBkgdGetBeforeText,'Visible','off')
                set(handles.SigEGetVal,           'Visible','off')
                set(handles.SigEMaxMinText,       'Visible','off')
                set(handles.SigEIntegralText,     'Visible','off')
            end
        end
    case 7  % Nilsson group's mass spectrometer
        set(hBkgdFromTrace,    'Value', 1)
        set(hBkgdGetBefore,    'Value', 0)
        set(hBkgd,             'Visible','off')
        set(hBkgdFromTraceText,'Visible','off')
        set(hBkgdGetBeforeText,'Visible','off')
        set(hMaxMin,           'Value',  1)
        set(hGetVal,           'Visible','off')
        set(hMaxMinText,       'Visible','off')
        set(hIntegralText,     'Visible','off')
    case 8  % No signal (LCLS)
        if n<=2
            set(handles.SigBSource,'Value',8)
            set(handles.SigBMaxMin,'Value',1)
            set(handles.SigBBkgd,             'Visible','off')
            set(handles.SigBBkgdFromTraceText,'Visible','off')
            set(handles.SigBBkgdGetBeforeText,'Visible','off')
            set(handles.SigBGetVal,           'Visible','off')
            set(handles.SigBMaxMinText,       'Visible','off')
            set(handles.SigBIntegralText,     'Visible','off')
        end
        if n<=3
            set(handles.SigCSource,'Value',8)
            set(handles.SigCMaxMin,'Value',1)
            set(handles.SigCBkgd,             'Visible','off')
            set(handles.SigCBkgdFromTraceText,'Visible','off')
            set(handles.SigCBkgdGetBeforeText,'Visible','off')
            set(handles.SigCGetVal,           'Visible','off')
            set(handles.SigCMaxMinText,       'Visible','off')
            set(handles.SigCIntegralText,     'Visible','off')
        end
        if n<=4
            set(handles.SigDSource,'Value',8)
            set(handles.SigDMaxMin,'Value',1)
            set(handles.SigDBkgd,             'Visible','off')
            set(handles.SigDBkgdFromTraceText,'Visible','off')
            set(handles.SigDBkgdGetBeforeText,'Visible','off')
            set(handles.SigDGetVal,           'Visible','off')
            set(handles.SigDMaxMinText,       'Visible','off')
            set(handles.SigDIntegralText,     'Visible','off')
        end
        if n<=5
            set(handles.SigESource,'Value',8)
            set(handles.SigEMaxMin,'Value',1)
            set(handles.SigEBkgd,             'Visible','off')
            set(handles.SigEBkgdFromTraceText,'Visible','off')
            set(handles.SigEBkgdGetBeforeText,'Visible','off')
            set(handles.SigEGetVal,           'Visible','off')
            set(handles.SigEMaxMinText,       'Visible','off')
            set(handles.SigEIntegralText,     'Visible','off')
        end
end
if any(source==2) || any(source==4)
    set(handles.BkgdTitleText,'Visible','on')
else
    set(handles.BkgdTitleText,'Visible','off')
end
if any(source==1) || any(source==2) || any(source==4)
    set(handles.ValueTitleText,'Visible','on')
else
    set(handles.ValueTitleText,'Visible','off')
end
scopeAverage = 1;
set(handles.ScopeAv,'String',num2str(scopeAverage))
s = get(handles.SigBSource,'String');
nSig = 1 ...                                  % Number of signals in use
    + ~strcmp(s(get(handles.SigBSource,'Value')),'None')...
    + ~strcmp(s(get(handles.SigCSource,'Value')),'None')...
    + ~strcmp(s(get(handles.SigDSource,'Value')),'None')...
    + ~strcmp(s(get(handles.SigESource,'Value')),'None');
m = find(normNum>nSig,1);
if ~isempty(m)
    if m==1
        set(handles.NormNum1,'Value',1)
    end
    if m<=2
        set(handles.NormNum2,'Value',1)
    end
    if m<=3
        set(handles.NormNum3,'Value',1)
    end
    if m<=4
        set(handles.NormNum4,'Value',1)
    end
    normNum(m:4) = 0;
    nNorm = min(nNorm,m-1);
end
end



function SelectChannel(c,n,handles)
global THzSource source ch
status = '';
set(handles.Status,'String',status)
minChan = 1;
maxChan = 1;
switch THzSource
    case 'lcls'
        switch source(n)
            case 1  % LCLS scope
                maxChan =  4;
            case 2  % LCLS Struck 3301 (0 to 7) and 8300 (8 to 17) digitizers
                minChan =  0;
                maxChan =  17;
            case 3  % LCLS has access to part of a CAEN charge digitizer.
                minChan =  8;
                maxChan =  9;
            case 4  % There is 1 LCLS SLAC waveform digitizer ("pizza box").
                maxChan =  4;
            case 5  % Acromag IP330a 16-input digitizer
                minChan =  0;
                maxChan = 15;
            case 6  % SR830 lock-in amplifier (mag, phase, cos, sin)
                minChan =  1;
                maxChan =  4;
            case 7  % Nilsson group's mass spectrometer
                maxChan =  1;
        end
    case 'facet'
        switch source(n)
            case 1  % There are 2 FACET scopes.
                maxChan =  8;
            case 2  % There are 3 FACET Struck 3301 waveform digitizers.
                minChan =  0;
                maxChan = 23;
            case 3  % There is 1 FACET CAEN charge digitizer.
                minChan =  0;
                maxChan = 31;
            case 4  % There is 1 FACET SLAC waveform digitizer ("pizza box").
                maxChan =  4;
            case 5  % BRAW, integral of SLAC digitizer for bunch length
                minChan =  1;
                maxChan =  2;
        end
end
if c<minChan || c>maxChan
    c = minChan;
    status = [' The channel must be between ',num2str(minChan),...
        ' and ',num2str(maxChan),' for this instrument.'];
    set(handles.Status,'String',status)
end
ch(n) = c;
switch n
    case 1
        set(handles.SigAChan,'String',num2str(ch(n)))
    case 2
        set(handles.SigBChan,'String',num2str(ch(n)))
    case 3
        set(handles.SigCChan,'String',num2str(ch(n)))
    case 4
        set(handles.SigDChan,'String',num2str(ch(n)))
    case 5
        set(handles.SigEChan,'String',num2str(ch(n)))
end
end



% --- Executes on selection change in SigASource.
function SigASource_Callback(hObject, eventdata, handles)
% hObject    handle to SigASource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SigASource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SigASource
global source ch
s = get(hObject,'Value');
n = 1;
SelectSource(s,n,handles)
set(hObject,'Value',source(n));
SelectChannel(ch(1),1,handles)
end


% --- Executes during object creation, after setting all properties.
function SigASource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigASource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigAChan_Callback(hObject, eventdata, handles)
% hObject    handle to SigAChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigAChan as text
%        str2double(get(hObject,'String')) returns contents of SigAChan as a double
c = round(str2double(get(hObject,'String')));
n = 1;
SelectChannel(c,n,handles)
end


% --- Executes during object creation, after setting all properties.
function SigAChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigAChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in SigBSource.
function SigBSource_Callback(hObject, eventdata, handles)
% hObject    handle to SigBSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SigBSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SigBSource
global source ch
s = get(hObject,'Value');
n = 2;
SelectSource(s,n,handles)
set(hObject,'Value',source(n));
SelectChannel(ch(2),2,handles)
end


% --- Executes during object creation, after setting all properties.
function SigBSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigBSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigBChan_Callback(hObject, eventdata, handles)
% hObject    handle to SigBChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigBChan as text
%        str2double(get(hObject,'String')) returns contents of SigBChan as a double
c = round(str2double(get(hObject,'String')));
n = 2;
SelectChannel(c,n,handles)
end


% --- Executes during object creation, after setting all properties.
function SigBChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigBChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in SigCSource.
function SigCSource_Callback(hObject, eventdata, handles)
% hObject    handle to SigCSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SigCSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SigCSource
global source ch
s = get(hObject,'Value');
n = 3;
SelectSource(s,n,handles)
set(hObject,'Value',source(n));
SelectChannel(ch(3),3,handles)
end


% --- Executes during object creation, after setting all properties.
function SigCSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigCSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigCChan_Callback(hObject, eventdata, handles)
% hObject    handle to SigCChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigCChan as text
%        str2double(get(hObject,'String')) returns contents of SigCChan as a double
global ch
c = round(str2double(get(hObject,'String')));
n = 3;
SelectChannel(c,n,handles)
% set(hObject,'String',num2str(ch(n)))
end


% --- Executes during object creation, after setting all properties.
function SigCChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigCChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in SigDSource.
function SigDSource_Callback(hObject, eventdata, handles)
% hObject    handle to SigDSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SigDSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SigDSource
global source ch
s = get(hObject,'Value');
n = 4;
SelectSource(s,n,handles)
set(hObject,'Value',source(n));
SelectChannel(ch(4),4,handles)
end


% --- Executes during object creation, after setting all properties.
function SigDSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigDSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigDChan_Callback(hObject, eventdata, handles)
% hObject    handle to SigDChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigDChan as text
%        str2double(get(hObject,'String')) returns contents of SigDChan as a double
global ch
c = round(str2double(get(hObject,'String')));
n = 4;
SelectChannel(c,n,handles)
% set(hObject,'String',num2str(ch(n)))
end


% --- Executes during object creation, after setting all properties.
function SigDChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigDChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in SigESource.
function SigESource_Callback(hObject, eventdata, handles)
% hObject    handle to SigESource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SigESource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SigESource
global source ch
s = get(hObject,'Value');
n = 5;
SelectSource(s,n,handles)
set(hObject,'Value',source(n));
SelectChannel(ch(5),5,handles)
end


% --- Executes during object creation, after setting all properties.
function SigESource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigESource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigEChan_Callback(hObject, eventdata, handles)
% hObject    handle to SigEChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigEChan as text
%        str2double(get(hObject,'String')) returns contents of SigEChan as a double
global ch
c = round(str2double(get(hObject,'String')));
n = 5;
SelectChannel(c,n,handles)
% set(hObject,'String',num2str(ch(n)))
end


% --- Executes during object creation, after setting all properties.
function SigEChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigEChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigADesc_Callback(hObject, eventdata, handles)
% hObject    handle to SigADesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigADesc as text
%        str2double(get(hObject,'String')) returns contents of SigADesc as a double
global description
description{1} = get(hObject,'String');
set(hObject,'String',description(1))
end


% --- Executes during object creation, after setting all properties.
function SigADesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigADesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigBDesc_Callback(hObject, eventdata, handles)
% hObject    handle to SigBDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigBDesc as text
%        str2double(get(hObject,'String')) returns contents of SigBDesc as a double
global description
description{2} = get(hObject,'String');
set(hObject,'String',description(2))
end


% --- Executes during object creation, after setting all properties.
function SigBDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigBDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigCDesc_Callback(hObject, eventdata, handles)
% hObject    handle to SigCDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigCDesc as text
%        str2double(get(hObject,'String')) returns contents of SigCDesc as a double
global description
description{3} = get(hObject,'String');
set(hObject,'String',description(3))
end


% --- Executes during object creation, after setting all properties.
function SigCDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigCDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigDDesc_Callback(hObject, eventdata, handles)
% hObject    handle to SigDDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigDDesc as text
%        str2double(get(hObject,'String')) returns contents of SigDDesc as a double
global description
description{4} = get(hObject,'String');
set(hObject,'String',description(4))
end


% --- Executes during object creation, after setting all properties.
function SigDDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigDDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function SigEDesc_Callback(hObject, eventdata, handles)
% hObject    handle to SigEDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigEDesc as text
%        str2double(get(hObject,'String')) returns contents of SigEDesc as a double
global description
description{5} = get(hObject,'String');
set(hObject,'String',description(5))
end


% --- Executes during object creation, after setting all properties.
function SigEDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigEDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function RefHigh_Callback(hObject, eventdata, handles)
% hObject    handle to RefHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefHigh as text
%        str2double(get(hObject,'String')) returns contents of RefHigh as a double
global refHigh
r = str2double(get(hObject,'String'));
if r < 1 || r > 5
    status = ' The upper limit for reference/mean must be between 1 and 5.';
    set(handles.Status,'String',status)
else
    status = '';
    refHigh = r;
    set(hObject,'String',num2str(refHigh))
end
set(handles.Status,'String',status)
end


% --- Executes during object creation, after setting all properties.
function RefHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function RefLow_Callback(hObject, eventdata, handles)
% hObject    handle to RefLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefLow as text
%        str2double(get(hObject,'String')) returns contents of RefLow as a double
global refLow
r = str2double(get(hObject,'String'));
if r < 0 || r > 1
    status = ' The lower limit for reference/mean must be between 0 and 1.';
    set(handles.Status,'String',status)
else
    status = '';
    refLow = r;
    set(hObject,'String',num2str(refLow))
end
set(handles.Status,'String',status)
end


% --- Executes during object creation, after setting all properties.
function RefLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function TDiff_Callback(hObject, eventdata, handles)
% hObject    handle to TDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TDiff as text
%        str2double(get(hObject,'String')) returns contents of TDiff as a double
global maxTStampDiff
s = str2double(get(hObject,'String'));
if isnan(s) || s>1
    maxTStampDiff = 0.1;
    status = 'The maximum time-stamp difference is 1 s or less.';
else
    maxTStampDiff = s;
    status = '';
end
set(handles.Status,'String',status)
end


% --- Executes during object creation, after setting all properties.
function TDiff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Averages_Callback(hObject, eventdata, handles)
% hObject    handle to Averages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Averages as text
%        str2double(get(hObject,'String')) returns contents of Averages as a double
global nAverage
status = '';
set(handles.Status,'String',status)
nAverage = round(str2double(get(hObject,'String')));
if nAverage < 1 || nAverage > 100
    nAverage = 1;    
    status = ' The number of traces to average must be between 1 and 100.';
    set(handles.Status,'String',status)
end
set(hObject,'String',num2str(nAverage))
end


% --- Executes during object creation, after setting all properties.
function Averages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Averages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function ScopeAv_Callback(hObject, eventdata, handles)
% hObject    handle to ScopeAv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScopeAv as text
%        str2double(get(hObject,'String')) returns contents of ScopeAv as a double
global THzSource source scopeAverage
status = '';
set(handles.Status,'String',status)
r = round(str2double(get(hObject,'String')));
if ~(any(source==1) ||...
    (strcmp(THzSource,'lcls') && any(source==5)))
    status = ' No averaging can be done in these instruments.';
    set(handles.Status,'String',status)
elseif scopeAverage < 1 || scopeAverage > 256
    status = ' The number of traces averaged by the instrument must be between 1 and 256.';
    set(handles.Status,'String',status)
else
    scopeAverage = r;
    set(hObject,'String',num2str(scopeAverage))
end
end


% --- Executes during object creation, after setting all properties.
function ScopeAv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScopeAv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Smooth_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Smooth as text
%        str2double(get(hObject,'String')) returns contents of Smooth as a double
global smooth
status = '';
set(handles.Status,'String',status)
smooth = round(str2double(get(hObject,'String')));
if smooth < 0 || smooth > 10
    smooth = 0;    
    status = [' Waveform smoothing uses 0 to 10 adjacent points ',...
        'with linearly decreasing weights.'];
    set(handles.Status,'String',status)
end
set(hObject,'String',num2str(smooth))
end


% --- Executes during object creation, after setting all properties.
function Smooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Motor_Callback(hObject, eventdata, handles)
% hObject    handle to Motor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Motor as text
%        str2double(get(hObject,'String')) returns contents of Motor as a double
global THzSource motorNumber motorPV start stop step mode
status = '';
set(handles.Status,'String',status)
s = get(hObject,'String');
motorNumber = round(str2double(s));
if strcmpi(THzSource,'lcls')
    minMotor =  1;
    maxMotor = 36;
else
    minMotor =  0;
    maxMotor = 24;
end
if isnan(motorNumber)
    if strcmpi(s,'TIME')
        if mode==1
            motorNumber = -1;
            motorPV = 'TIME';
            set(hObject,'String',motorPV)
            start = 0;
            stop = 120;
            step = 1;
            set(handles.Start,'String',num2str(start))
            set(handles.Stop, 'String',num2str(stop))
            set(handles.Step, 'String',num2str(step))
        else
            motorNumber = 1;
            motorPV = '';
            status = ' Use TIME only in SCAN mode.';
            set(hObject,'String',num2str(motorNumber))
        end            
    elseif strcmpi(s,'SAMPLES')
        if mode == 2
            motorNumber = -1;
            motorPV = 'SAMPLES';
            set(hObject,'String',motorPV)
            start = 0;
            set(handles.Start,'String',num2str(start))
        else
            motorNumber = 1;
            motorPV = '';
            status =...
                ' Use SAMPLES only in Strip-Chart or On-Off Peak modes.';
            set(hObject,'String',num2str(motorNumber))
        end            
    elseif isnan(lcaGetSmart(s))
        motorNumber = 1;
        motorPV = '';
        status = ' Enter a valid motor number or a PV name.';
        set(hObject,'String',num2str(motorNumber))
    else
        motorNumber = -1;
        motorPV = s;
        status = ' The PV is valid.';
    end
else
    if motorNumber < minMotor || motorNumber > maxMotor
        motorNumber = 1;
        motorPV = '';
        status = [' The motor number must be between ',num2str(minMotor),...
            ' and ',num2str(maxMotor),'.'];
    else
        motorPV = '';
        status = '';
    end
    set(hObject,'String',num2str(motorNumber))
end
set(handles.Status,'String',status)
end


% --- Executes during object creation, after setting all properties.
function Motor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Motor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Start as text
%        str2double(get(hObject,'String')) returns contents of Start as a double
global motorPV start stop step mode
status = '';
set(handles.Status,'String',status)
start = str2double(get(hObject,'String'));
if strcmp(motorPV,'TIME')
    start = 0;
    set(hObject,'String',num2str(start))
    status = ' The start time is always 0.';
    set(handles.Status,'String',status)
elseif abs(start) > 2e5 %75
    start = 0;
    set(hObject,'String',num2str(start))
    status = ' The stage position must be between -75 and 75 mm.';
    set(handles.Status,'String',status)
end
if mode == 1
    step = abs(step)*sign(stop-start);
    set(handles.Step,'String',num2str(step))
end
end


% --- Executes during object creation, after setting all properties.
function Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Stop as text
%        str2double(get(hObject,'String')) returns contents of Stop as a double
global motorPV start stop step mode
status = '';
set(handles.Status,'String',status)
stopInput = str2double(get(hObject,'String'));
if mode == 2
    step = round(stopInput);
    if step < 20 || step > 3000
        step = 200;
        status =...
            ' The number of points on the strip chart must be between 20 and 3000.';
        set(handles.Status,'String',status)
    end
    set(hObject,'String',num2str(step))
else
    stop = stopInput;
    if strcmp(motorPV,'TIME') && (stop<start || stop>1000)
        stop = 120;
        set(hObject,'String',num2str(stop))
        status = ' The stop time must be between the start and 1000 s.';
        set(handles.Status,'String',status)
    elseif abs(stop) > 2e5 %75
        stop = 0;
        set(hObject,'String',num2str(stop))
        status = ' The stage position must be between -75 and 75 mm.';
        set(handles.Status,'String',status)
    end
    if mode == 1
        step = abs(step)*sign(stop-start);
        set(handles.Step,'String',num2str(step))
    end
end
end


% --- Executes during object creation, after setting all properties.
function Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Step_Callback(hObject, eventdata, handles)
% hObject    handle to Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step as text
%        str2double(get(hObject,'String')) returns contents of Step as a double
global start stop step mode
status = '';
set(handles.Status,'String',status)
if mode == 1
    step = str2num(get(hObject,'String'));
    if any(abs(step) < 1e-4) || any(abs(step) > 250)
        step = 0.1;
        set(hObject,'String',num2str(step))
        status = ' The step size must be between 0.0001 and 250.';
        set(handles.Status,'String',status)
    else
        step = abs(step)*sign(stop-start);
        set(hObject,'String',num2str(step,'%7.4f'))
    end
elseif mode == 3
    step = str2double(get(hObject,'String'));
    if step < 20 || step > 500
        step = 200;
        set(hObject,'String',num2str(step))
        status = ' The number of points on the strip chart must be between 20 and 500.';
        set(handles.Status,'String',status)
    end
end
end


% --- Executes during object creation, after setting all properties.
function Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Resume_Callback(hObject, eventdata, handles)
% hObject    handle to Resume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Resume as text
%        str2double(get(hObject,'String')) returns contents of Resume as a double
global x mStep mResume start
status = '';
set(handles.Status,'String',status)
r = str2double(get(hObject,'String'));
if r < min(start,x(mStep)) || r > max(start,x(mStep))
    status = ' Resume between the start and the position where you paused.';
    set(handles.Status,'String',status)
elseif mStep == 1
    mResume = 1;
else
    d = abs(x(1:mStep)-r);
    mResume = find(d==min(d),1);
end
set(handles.Resume,'String',num2str(x(mResume)))
end


% --- Executes during object creation, after setting all properties.
function Resume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Resume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Time_Callback(hObject, eventdata, handles)
% hObject    handle to Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Time as text
%        str2double(get(hObject,'String')) returns contents of Time as a double
set(hObject,'String','')
end


% --- Executes during object creation, after setting all properties.
function Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Status_Callback(hObject, eventdata, handles)
% hObject    handle to Status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Status as text
%        str2double(get(hObject,'String')) returns contents of Status as a double
set(hObject,'String','')
end


% --- Executes during object creation, after setting all properties.
function Status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in Mode.
function Mode_Callback(hObject, eventdata, handles)
% hObject    handle to Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Mode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Mode
global THzSource start stop step mode motorNumber motorPV
mode = get(hObject,'Value');
switch mode
    case 1  % Scan Mode
        set(handles.StartText,'String', 'Start')
        set(handles.StopText, 'String', 'Stop')
        set(handles.StepText, 'String',...
            sprintf('Step Size\n(Enter multiple values to vary step size.) '))
        set(handles.Step,     'Visible','on')
        set(handles.StepText, 'Visible','on')
        if motorNumber<0 && strcmp(get(handles.Motor,'String'),'SAMPLES')
            motorPV = 'TIME';
            set(handles.Motor,'String',motorPV)
            start = 0;
            stop  = 120;
            step  = 1;
        else
            switch THzSource
                case 'lcls'
                    start = 15;
                    stop  = 25;
                case 'facet'
                    start = 1;
                    stop  = 5.3;
            end
            step  = 0.02;
        end
        set(handles.Start,    'String', num2str(start))
        set(handles.Stop,     'String', num2str(stop))
        set(handles.Step,     'String', num2str(step))
    case 2  % Strip-Chart Mode
        set(handles.StartText,'String','Position')
        set(handles.StopText, 'String','Points')
        set(handles.Step,     'Visible','off')
        set(handles.StepText, 'Visible','off')
        if motorNumber<0 && strcmp(get(handles.Motor,'String'),'TIME')
            motorPV = 'SAMPLES';
            set(handles.Motor,'String',motorPV)
            start = 0;
        else
            switch THzSource
                case 'lcls'
                    start = -2.65;
                case 'facet'
                    start = 3.15;
            end
        end
        step  = 200;
        set(handles.Start,    'String', num2str(start))
        set(handles.Stop,     'String', num2str(step))
    case 3  % On-Peak/Off-Peak Mode
        set(handles.StartText,'String','On Peak')
        set(handles.StopText, 'String','Off Peak')
        set(handles.StepText, 'String','Points    ')
        set(handles.Step,     'Visible','on')
        set(handles.StepText, 'Visible','on')
        switch THzSource
            case 'lcls'
                start = 24;    % On peak
                stop  = 23;    % Off peak
            case 'facet'
                start = 3.15;  % On peak
                stop  = 2;     % Off peak
        end
        step  = 200;
        set(handles.Start,    'String', num2str(start))
        set(handles.Stop,     'String', num2str(stop))
        set(handles.Step,     'String', num2str(step))
end
end


% --- Executes during object creation, after setting all properties.
function Mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in Logbook.
function Logbook_Callback(hObject, eventdata, handles)
% hObject    handle to Logbook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global figHandle THzSource source

if ishandle(figHandle(1))
    util_printLog(figHandle(1))
end
if strcmp(THzSource,'lcls')
    if any(source==7) &&...
        any(size(figHandle)>1) && ishandle(figHandle(2))
    util_printLog(figHandle(2))
    end
    if (any(source==2) || any(source==4)) && any(size(figHandle)>1)
        for n=2:min(length(figHandle),6)
            if ishandle(figHandle(n))
                pause(0.5)
                util_printLog(figHandle(n))
            end
        end
    end
end
end


% --- Executes on button press in LogAll.
function LogAll_Callback(hObject, eventdata, handles)
% hObject    handle to LogAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LogAll
end



% --- Executes on button press in FileAveraged.
function FileAveraged_Callback(hObject, eventdata, handles)
% hObject    handle to FileAveraged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB10
% handles    structure with handles and user data (see GUIDATA)
global THzSource source filePath
global x meanSig normSig RGA temperature

status = '';
set(handles.Status,'String',status)
dateVector = datevec(now);
filePath = sprintf('/u1/%s/matlab/THz/%d/%d-%02d/%d-%02d-%02d/',THzSource,...
            dateVector(1),dateVector(1),dateVector(2),...
            dateVector(1),dateVector(2),dateVector(3));
fileName = sprintf('%sScan-%d%02d%02d-%02d%02d%02d.txt',THzSource,...
            dateVector(1),dateVector(2),dateVector(3),...
            dateVector(4),dateVector(5),round(dateVector(6)));
mkdirStatus = mkdir(filePath);
if mkdirStatus == 1
    try
        if get(handles.SaveAveraged,'Value') == 0
            [filename,filepath] =...
                uiputfile('*.txt','Save File As',[filePath,fileName]);
        else
            filename = fileName;
            filepath = filePath;
        end
        if isequal(filename,0) || isequal(filepath,0)
            status = ' Save canceled by user.';
            set(handles.Status,'String',status)
        else
            filePath = filepath;
            data = [x,meanSig,normSig];
            save([filepath,filename],'data','-ascii','-double','-tabs')
            status = ' Scan file saved.';
            set(handles.Status,'String',status)
        end
    catch
        status = ' Error in opening file.';
        set(handles.Status,'String',status)
    end
    if strcmp(THzSource,'lcls') && any(source==6)
        RgaFileName  = ['lclsRGA', fileName(5:length(fileName))];
        TempFileName = ['lclsTemp',fileName(5:length(fileName))];
        try
            if get(handles.SaveAveraged,'Value') == 0
                [filename,filepath] =...
                    uiputfile('*.txt','Save File As',[filePath,RgaFileName]);
            else
                filename = fileName;
                filepath = filePath;
            end
            if isequal(filename,0) || isequal(filepath,0)
                status = ' Save canceled by user.';
                set(handles.Status,'String',status)
            else
                save([filepath,filename],'RGA','-ascii','-double','-tabs')
                status = ' RGA file saved.';
                set(handles.Status,'String',status)
            end
        catch
            status = ' Error in opening file.';
            set(handles.Status,'String',status)
        end
        try
            if get(handles.SaveAveraged,'Value') == 0
                [filename,filepath] =...
                    uiputfile('*.txt','Save File As',[filePath,TempFileName]);
            else
                filename = fileName;
                filepath = filePath;
            end
            if isequal(filename,0) || isequal(filepath,0)
                status = ' Save canceled by user.';
                set(handles.Status,'String',status)
            else
                save([filepath,filename],'temperature','-ascii','-double','-tabs')
                status = ' Sample temperature file saved.';
                set(handles.Status,'String',status)
            end
        catch
            status = ' Error in opening file.';
            set(handles.Status,'String',status)
        end
    end
else
    status = ' Error when creating directory.';
    set(handles.Status,'String',status)    
end
end


% --- Executes on button press in SaveAveraged.
function SaveAveraged_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAveraged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveAveraged
end



% --- Executes on button press in FileMeasurements.
function FileMeasurements_Callback(hObject, eventdata, handles)
% hObject    handle to FileMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global THzSource filePath
global x nAverage allSig

status = '';
set(handles.Status,'String',status)
dateVector = datevec(now);
if strcmp(THzSource,'lcls')
    status = ' Error: You must run from facet-srv20 to save this data.';
    set(handles.Status,'String',status)    
end    
filePath = sprintf('/u1/%s/matlab/THz/%d/%d-%02d/%d-%02d-%02d/',...
            THzSource,...
            dateVector(1),dateVector(1),dateVector(2),...
            dateVector(1),dateVector(2),dateVector(3));
fileName = sprintf('%sAllPoints-%d%02d%02d-%02d%02d%02d.txt',THzSource,...
            dateVector(1),dateVector(2),dateVector(3),...
            dateVector(4),dateVector(5),round(dateVector(6)));
mkdirStatus = mkdir(filePath);
if mkdirStatus == 1
    try
        if get(handles.SaveMeasurements,'Value') == 0
            [filename,filepath] =...
                uiputfile('*.txt','Save File As',[filePath,fileName]);
        else
            filename = fileName;
            filepath = filePath;
        end
        if isequal(filename,0) || isequal(filepath,0)
            status = ' Save canceled by user.';
            set(handles.Status,'String',status)
        else
            filePath = filepath;  %allSig((1-nAverage:0)+nAverage*mStep,n) = diff(:,n)
            p = floor(size(allSig,1)/nAverage);
            X = ones(size(allSig,1),1)*x(p);
            for m = 1:p
                X((1-nAverage:0)+nAverage*m) = x(m);
            end
            data = [X,allSig];
            save([filepath,filename],'data','-ascii','-double','-tabs')
            status = ' Scan file saved.';
            set(handles.Status,'String',status)
        end
    catch
        status = ' Error in opening file.';
        set(handles.Status,'String',status)
    end
else
    status = ' Error when creating directory.';
    set(handles.Status,'String',status)    
end
end


% --- Executes on button press in SaveMeasurements.
function SaveMeasurements_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveMeasurements
end



% --- Executes on button press in FileWaveforms.
function FileWaveforms_Callback(hObject, eventdata, handles)
% hObject    handle to FileWaveforms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global THzSource filePathW
global x nAverage waveform

status = '';
set(handles.Status,'String',status)
dateVector = datevec(now);
[~,host] = unix('hostname');
if strcmp(THzSource,'lcls')...
        || (strcmp(THzSource,'facet') && ~strcmp(host(1:11),'facet-srv20'))
    set(handles.Status,'String',...
        ' You can save waveforms only when running on facet-srv20.')
    return
end    
filePathW = sprintf('/nas/nas-li20-pm00/THz/%d/%d-%02d/%d-%02d-%02d/',...
            dateVector(1),dateVector(1),dateVector(2),...
            dateVector(1),dateVector(2),dateVector(3));
fileName = sprintf('%sWaveforms-%d%02d%02d-%02d%02d%02d.mat',THzSource,...
            dateVector(1),dateVector(2),dateVector(3),...
            dateVector(4),dateVector(5),round(dateVector(6)));
mkdirStatus = mkdir(filePathW);
if mkdirStatus == 1
    try
        if get(handles.SaveMeasurements,'Value') == 0
            [filename,filepath] =...
                uiputfile('*.mat','Save File As',[filePathW,fileName]);
            if isempty(strfind(filepath,'/nas/nas-li20-pm00/THz'))
                status = ['You must store this data in a subdirectory ',...
                    'of /nas/nas-li20-pm00/THz'];
                set(handles.Status,'String',status)
                return
            end
        else
            filename = fileName;
            filepath = filePathW;
        end
        if isequal(filename,0) || isequal(filepath,0)
            status = ' Save canceled by user.';
            set(handles.Status,'String',status)
        else
            filePathW = filepath;
            save([filepath,filename],'x','nAverage','waveform')
            status = ' Scan file saved.';
            set(handles.Status,'String',status)
        end
    catch
        status = ' Error in opening file.';
        set(handles.Status,'String',status)
    end
else
    status = ' Error: You must run from facet-srv20 to save this data.';
    set(handles.Status,'String',status)    
end
end


% --- Executes on button press in SaveWaveforms.
function SaveWaveforms_Callback(hObject, eventdata, handles)
% hObject    handle to SaveWaveforms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveWaveforms
end



function NormNum(num,n,handles)
global nSig nNorm normNum
num = num-1;
normNum(n) = num;
k1 = find(normNum>nSig,1);
k2 = find(normNum==0,1);
if ~isempty(k1) || ~isempty(k2)
    m = min([k1,k2]);
    if m==1
        set(handles.NormNum1,'Value',1)
    end
    if m<=2
        set(handles.NormNum2,'Value',1)
    end
    if m<=3
        set(handles.NormNum3,'Value',1)
    end
    if m<=4
        set(handles.NormNum4,'Value',1)
    end
    normNum(m:4) = 0;
    nNorm = min(nNorm,m-1);
end
end



% --- Executes on selection change in NormNum1.
function NormNum1_Callback(hObject, eventdata, handles)
% hObject    handle to NormNum1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormNum1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormNum1
num = get(hObject,'Value');
NormNum(num,1,handles)
end


% --- Executes during object creation, after setting all properties.
function NormNum1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormNum1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormOp1.
function NormOp1_Callback(hObject, eventdata, handles)
% hObject    handle to NormOp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormOp1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormOp1
global normOp
normOp(1) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormOp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormOp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormDenom1.
function NormDenom1_Callback(hObject, eventdata, handles)
% hObject    handle to NormDenom1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormDenom1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormDenom1
global normDenom
normDenom(1) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.stage position must be between -75 and 75 mm
function NormDenom1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormDenom1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormNum2.
function NormNum2_Callback(hObject, eventdata, handles)
% hObject    handle to NormNum2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormNum2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormNum2
num = get(hObject,'Value');
NormNum(num,2,handles)
end


% --- Executes during object creation, after setting all properties.
function NormNum2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormNum2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormOp2.
function NormOp2_Callback(hObject, eventdata, handles)
% hObject    handle to NormOp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormOp2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormOp2
global normOp
normOp(2) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormOp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormOp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormDenom2.
function NormDenom2_Callback(hObject, eventdata, handles)
% hObject    handle to NormDenom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormDenom2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormDenom2
global normDenom
normDenom(2) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormDenom2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormDenom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormNum3.
function NormNum3_Callback(hObject, eventdata, handles)
% hObject    handle to NormNum3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormNum3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormNum3
num = get(hObject,'Value');
NormNum(num,3,handles)
end


% --- Executes during object creation, after setting all properties.
function NormNum3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormNum3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormOp3.
function NormOp3_Callback(hObject, eventdata, handles)
% hObject    handle to NormOp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormOp3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormOp3
global normOp
normOp(3) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormOp3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormOp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.stage position must be between -75 and 75 mm
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormDenom3.
function NormDenom3_Callback(hObject, eventdata, handles)
% hObject    handle to NormDenom3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormDenom3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormDenom3
global normDenom
normDenom(3) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormDenom3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormDenom3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormNum4.
function NormNum4_Callback(hObject, eventdata, handles)
% hObject    handle to NormNum4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormNum4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormNum4
num = get(hObject,'Value');
NormNum(num,4,handles)
end


% --- Executes during object creation, after setting all properties.
function NormNum4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormNum4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormOp4.
function NormOp4_Callback(hObject, eventdata, handles)
% hObject    handle to NormOp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormOp4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormOp4
global normOp
normOp(4) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormOp4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormOp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in NormDenom4.
function NormDenom4_Callback(hObject, eventdata, handles)
% hObject    handle to NormDenom4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormDenom4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormDenom4
global normDenom
normDenom(4) = get(hObject,'Value');
end


% --- Executes during object creation, after setting all properties.
function NormDenom4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormDenom4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in PauseScan.
function PauseScan_Callback(hObject, eventdata, handles)
% hObject    handle to PauseScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PauseScan x mStep mResume startTimeSteps
if PauseScan
    PauseScan = 0;
    mStep = max(1,mResume-1);
    set(handles.PauseScan, 'Value',0)
    set(handles.PauseScan, 'String', 'Pause Scan')
    set(handles.Resume,    'Visible','off')
    set(handles.ResumeText,'Visible','off')
    set(handles.Status,    'String' ,' Resuming the scan')
    startTimeSteps = now-x(mStep)/(3600*24);
else
    PauseScan = 1;
    mResume = mStep;
    set(handles.PauseScan, 'Value',1)
    set(handles.PauseScan, 'String','Resume Scan')
    set(handles.Resume,    'String',num2str(x(mResume)))
    set(handles.Resume,    'Visible','on')
    set(handles.ResumeText,'Visible','on')
    set(handles.Status,    'String' ,' Pausing the scan')
end
drawnow update
end



% --- Executes on button press in StopScan.
function StopScan_Callback(hObject, eventdata, handles)
% hObject    handle to StopScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global StopScan
StopScan = 1;
set(handles.StopScan,'Value',1)
set(handles.StopScan,'String','Stopping...')
drawnow update
end



% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exit
end



%==========================================================================
% --- Executes on button press in StartScan.
function StartScan_Callback(hObject, eventdata, handles)
% hObject    handle to StartScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global THzSource source ch description refHigh refLow mode
global nAverage scopeAverage smooth motorNumber motorPV start stop step
global PauseScan StopScan maxTStampDiff
global figHandle x mStep meanSig normSig allSig waveform startTimeSteps
global RGA temperature
global nSig nNorm normNum normOp normDenom


if get(handles.SaveWaveforms,'Value')>0
    [~,host] = unix('hostname');
    if strcmp(THzSource,'lcls')...
            || (strcmp(THzSource,'facet') && ~strcmp(host,'facet-srv20'))
        set(handles.Status,'String',...
            ' You can save waveforms only when running on facet-srv20.')
        return
    end
end    

% Initialization
StopScan = 0;
PauseScan = 0;
set(handles.StartScan,'Value',1)
set(handles.StopScan, 'Value',0)
set(handles.PauseScan,'Value',0)
set(handles.StartScan,'String','Scanning...')
set(handles.StopScan, 'String','Stop Scan')
set(handles.PauseScan,'String','Pause Scan')
status = ' Starting...';
set(handles.Status,'String',status)
set(handles.Time,  'String','')

switch THzSource
    case 'lcls'
        if motorNumber<=32 && motorNumber>0
            motorPV = sprintf('DMP:THZ:MMN:%02d',motorNumber);
        elseif motorNumber > 32
            % Nilsson group's chamber: Z,X,Y,theta
            motorPV = sprintf('THZ:TST:MMS:%02d',motorNumber-32);
        end
        if any(motorNumber==[3 4 24 36])
            motorUnit = 'deg';
        elseif motorNumber<=32 && motorNumber>0
            motorUnit = 'mm';
        elseif strcmp(motorPV,'TIME')
            motorUnit = 's';
        elseif strcmp(motorPV,'SAMPLES')
            motorUnit = '';
        elseif motorNumber < 0
            motorUnit = lcaGetSmart([motorPV,'.EGU']);
            motorUnit = motorUnit{1};
        else
            motorUnit = '';
        end
        ratePV = 'EVR:DMP1:MC01:EVENT1RATE'; % 'DMP:THZ:EVR:01:EVENT1RATE';
        
    case 'facet'
        if motorNumber == 0
            motorPV = 'XPS:LI20:DWFA:X';
        elseif motorNumber > 0
            motorPV = sprintf('MIRR:LI20:500:%02d_XPS%1d_%02d',motorNumber,...
                floor((motorNumber-1)/8)+1,mod(motorNumber-1,8)+1);
        end
        if motorNumber == 8
            motorUnit = 'deg';
        elseif motorNumber<=24 && motorNumber>=0
            motorUnit = 'mm';
        elseif strcmp(motorPV,'TIME')
            motorUnit = 's';
        elseif strcmp(motorPV,'SAMPLES')
            motorUnit = '';
        elseif motorNumber < 0
            motorUnit = lcaGetSmart([motorPV,'.EGU']);
            motorUnit = motorUnit{1};
        else
            motorUnit = '';
        end
        if lcaGetSmart('EVNT:SYS1:1:BEAMRATE') > 0
            ratePV = 'EVNT:SYS1:1:BEAMRATE';
        elseif lcaGetSmart('EVNT:SYS1:1:POSITRONRATE') > 0
            ratePV = 'EVNT:SYS1:1:POSITRONRATE';
        else
            set(handles.Status,'String',' No beam rate')
            return
        end

end

% Identify cases needing special handling.
rgaMotor = 0;
phaseShifter = 0;
laser = 0;
if strfind(motorPV,'THZ:TST:MMS')                 % Catalysis experiment
    rgaMotor = 1;
elseif strcmp(motorPV,'DMP:THZ:PHS:01:PHASEVAL')  % Phase shifter
    phaseShifter = 1;
    oneCycle = 942;     % Phase shifter counts for a shift of 360 degrees
    fRF = 476e6;        % Frequency of RF clock
    motorUnit = 'ps';
elseif strcmp(motorPV,'OSC:LA20:10:FS_TGT_TIME')  % FACET laser timing
    laser = 1;
    laserStep = 2;      % Move laser loop slowly (ns), and in small steps
    laserPause = 2;     % Delay between steps (s)
    laserPhaseMotorPV = 'OSC:LA20:10:PHASE_MOTOR_POS';
end

% Check name of readback PV and save stage position before scan
if strcmp(motorPV,'TIME') || strcmp(motorPV,'SAMPLES')
    readbackPV = '';
    before = 0;
else
    if motorNumber < 0
        % endOfMotorPV = motorPV(length(motorPV)-3:length(motorPV));
        % elseif strcmp(endOfMotorPV,'TDES') || laser
        readbackPV = motorPV;
    else
        readbackPV = [motorPV,'.RBV'];
    end
    before = lcaGet(readbackPV);
end

% Set up scan modes.
if mode == 1
    nSizes = length(step);
    nSteps = zeros(1,nSizes);
    for i = 1:nSizes
        nSteps(i) = max(1,round(0.0001+(stop-start)/(nSizes*step(i))));
    end
    NSteps = sum(nSteps)+1;
    x = zeros(NSteps,1);
    border = start + (0:nSizes-1)*(stop-start)/nSizes;
    k = 1;
    for i = 1:nSizes
        for j = 0:nSteps(i)-1
            x(k+j) = border(i) + j*step(i);
        end
        k = sum(nSteps(1:i))+1;
    end
    x(NSteps) = stop;
    % Round phase-shifter steps to integers but leave in ps
    if phaseShifter
        for m = 1:NSteps
            x(m) = 1e12*round(1e-12*x(m)*fRF*oneCycle)/(fRF*oneCycle);
        end
    end
else
    x = (0:step)';
    NSteps = step+1;
end

%--------------------------------------------------------------------------
% Set up PVs and other parameters
s = get(handles.SigBSource,'String');
nSig = 1 ...                                  % Number of signals in use
    + ~strcmp(s(get(handles.SigBSource,'Value')),'None')...
    + ~strcmp(s(get(handles.SigCSource,'Value')),'None')...
    + ~strcmp(s(get(handles.SigDSource,'Value')),'None')...
    + ~strcmp(s(get(handles.SigESource,'Value')),'None');
nNorm = (get(handles.NormNum1,'Value')>1)...  % Number of normalized plots
      + (get(handles.NormNum2,'Value')>1)...
      + (get(handles.NormNum3,'Value')>1)...
      + (get(handles.NormNum4,'Value')>1);
meanSig = zeros(NSteps,nSig);
normSig = zeros(NSteps,nNorm);
if get(handles.SaveMeasurements,'Value')==1
    allSig = zeros(nAverage*NSteps,nSig);
end
if get(handles.SaveWaveforms,'Value') == 1
    waveform = cell(nAverage,NSteps,nSig);
end
diff = zeros(nAverage,nSig);
getErrorBar = (nAverage>=5);
if getErrorBar
    errorBar = zeros(NSteps,nSig+nNorm);
end
if mode == 3
    contrast = zeros(NSteps-1,nSig+nNorm);
end
sigName = {'A';'B';'C';'D';'E'};
scope     = {'';'';'';'';''};
runScope  = {'';'';'';'';''};
stopScope = {'';'';'';'';''};
PV = cell(nSig,1);
scopePoints = 500;      % Scope transfers 600 points, but last 100 are 0
scalePV = {'';'';''};
scaleStr = {'1mV';  '2mV';  '5mV';'10mV';'20mV';'50mV';...
          '100mV';'200mV';'500mV'; '1V' ; '2V' ; '5V' ; '10V'};
scaleVal = [ 1;      2;      5;    10;    20;    50;...
           100;    200;    500;  1000;  2000;  5000;  10000];
scaleIndex  = [0 0];
beamRate = lcaGetSmart(ratePV);
deviceRate = 120*ones(1,nSig);  % Will set to slowest channel
StruckRate = 120;               % Will measure later if Struck is used
minStruck  = zeros(nSig,1);
maxStruck  = zeros(nSig,1);
scaleFactor = [1 1 1 1 1];
clockRate = zeros(1,nSig);
gateEdges = zeros(nSig,6);
beamGate  = cell(nSig,1);
nPersist  = 20;                 % Number of traces in persistance buffer
pPersist  = zeros(nPersist,1);  % Pointer into persistance buffer
fPersist  = zeros(nPersist,1);  % Number of traces already in buffer
persist   = cell(nSig,1);
ylm1 = -50*ones(1,nSig);
doRGA = [0 0 0 0 0];
normOps = {' + ';' - ';' * ';' / '};
yAxisLabel = cell(nSig+nNorm,1);
yAxisLabel(1:nSig) = sigName(1:nSig);
for m = 1:nNorm
    yAxisLabel{nSig+m} = [sigName{normNum(m)},...
        normOps{normOp(m)},sigName{normDenom(m)}];
end
yAxisLabelFontSize = 10;
if mode==3
    yAxisLabelFontSize = 8;
end
descript = description;
yAxisUnit = {'';'';'';'';''};
maxMin = [get(handles.SigAMaxMin,'Value'),...
          get(handles.SigBMaxMin,'Value'),...
          get(handles.SigCMaxMin,'Value'),...
          get(handles.SigDMaxMin,'Value'),...
          get(handles.SigEMaxMin,'Value')];
tStampOld = [0;0;0;0;0];
elapsed = 0;
if any(source==1) || strcmp(THzSource,'lcls') && any(source==5)
    scopeAveraging = scopeAverage;
else
    scopeAveraging = 1;
end
if strcmp(THzSource,'lcls') && any(source==3)
    % If LCLS CAEN is used, it's timing will be changed and reset afterward
    oldTDES  = lcaGetSmart('QADC:DMP1:100:TDES');    
    oldWidth = lcaGetSmart('QADC:DMP1:100:TWID');
    lcaPutSmart('QADC:DMP1:100:TDES',-2000);    
    lcaPutSmart('QADC:DMP1:100:TWID',20);
end

for n = 1:nSig
    switch THzSource
        case 'lcls'
            maxBeamRate = 120;
            switch source(n)
                case 1  % Scope
                    scope{n} = 'SCOP:UND1:BLF1'; % 'SCOP:UND1:BLF2';
                    runScope{n}  = strcat(scope{n},':RUN.PROC');
                    stopScope{n} = strcat(scope{n},':STOP.PROC');
                    PV{n} = [scope{n},':GS_CH',num2str(ch(n)),...
                        '_WFORM.VALA'];
                    scalePV{n} = [scope{n},':W_CH',num2str(ch(n)),'_SCL'];
                    scale = lcaGetSmart(scalePV{n});
                    scaleIndex(n) = find(strcmp(scale,scaleStr),1,'first');
                    scaleFactor(n) = scaleVal(scaleIndex(n));
                    yAxisUnit{n} = ' [mV]';
                    deviceRate(n) = 5;
                    
                case 2  % Struck digitizer
                    % PV{n} = ['DMP:THZ:waveform',num2str(ch(n))];
                    if ch(n) <= 7
                        s1 = 'FADC:DMP1:100:sis3301';
                        PV{n} = [s1,'waveform',num2str(ch(n))];
                    else
                        s1 = 'FADC:DMP1:RM01:';
                        PV{n} = [s1,'waveform',num2str(ch(n)-8)];
                    end
                    if beamRate > 1
                        if StruckRate >= 120
                            s = 0;
                            for m=1:50
                                % s = s + lcaGetSmart('DMP:THZ:perSecond');
                                s = s + lcaGetSmart...
                                    ([s1,'perSecond']);
                                pause(0.2)
                            end
                            StruckRate = max(1,s/50);
                        end
                    else
                        StruckRate = 3;
                    end
                    if maxMin(n)
                        yAxisUnit{n} = ' [counts]';
                    else
                        yAxisUnit{n} = ' [counts*us]';
                    end
                    deviceRate(n) = StruckRate;
                    % Two gate types: +1 during beam only, -1 exclude beam
                    % uTCA Struck trigger at 109788 ticks, event code 140
                    gate =         [[0 0   -1   -1 0 0 0 0],   -1*ones(1,10)];
                    beamTime =     [[0 0 1160 1160 0 0 0 0],4300*ones(1,10)]*1e-9;%17790
                    beamGateWidth =[[0 0   55   55 0 0 0 0],   55*ones(1,10)]*1e-9;
                    if ch(n) <= 7
                        clockStr = char(lcaGetSmart([s1,'clock']));
                        clockRate(n) = str2double(clockStr(1:3))*1e6;
                        minStruck(n) =     0;
                        maxStruck(n) = 32767;
                    else
                        clockRate(n) = lcaGetSmart([s1,'fclk']);
                        minStruck(n) = -8000;
                        maxStruck(n) =  8000;
                    end
                    traces = lcaGetSmart(PV{n});
                    if gate(ch(n)+1) ~= 0
                        gateEdges(n,3) = max(1,ceil(beamTime(ch(n)+1)*clockRate(n)));
                        gateEdges(n,:) = max(1,min(length(traces),... 
                            gateEdges(n,3)+round(clockRate(n)*[-300e-9,0,0,...
                            beamGateWidth(ch(n)+1)+[0,0,300e-9]])));
                        persist{n} = zeros(nPersist,gateEdges(n,6)-gateEdges(n,1)+1);
                        beamGate{n} = zeros(1,gateEdges(n,6)-gateEdges(n,1)+1);
                        if gate(ch(n)+1) < 0
                            gateEdges(n,2:5) = max(1,min(length(traces),... 
                                gateEdges(n,3)+round(clockRate(n)*[-200e-9,0,...
                                beamGateWidth(ch(n)+1)+[0,200e-9]])));
                            beamGate{n}(([gateEdges(n,2):gateEdges(n,3)-1,...
                                          gateEdges(n,4)+1:gateEdges(n,5)])...
                                         -gateEdges(n,1)+1) = 1;
                        else
                            beamGate{n}((gateEdges(n,3):gateEdges(n,4))...
                                        -gateEdges(n,1)+1) = 1;
                        end
                    end

                case 3  % CAEN digitizer
                    PV{n} = ['THZR:DMP1:',num2str(342+ch(n)),'DETECTOR'];
                    % Pedestal
                    if lcaGetSmart('QADC:DMP1:100:QDCSETBASELN') < 40
                        lcaPutSmart('QADC:DMP1:100:QDCSETBASELN',90);
                    end
                    yAxisUnit{n} = ' [pC]';
                    
                case 4  % SLAC digitizer
                    c = {'A';'B';'C';'D'};
                    PV{n} = ['UBLF:UND1:500:',c{ch(n)},'_P_WF'];%'_S_P_WF'
                    if maxMin(n) == 0
                        yAxisUnit{n} = ' [counts*us]';
                    else
                        yAxisUnit{n} = ' [counts]';
                    end
                    % Two gate types: +1 during beam only, -1 exclude beam
                    % Trigger at TDES=-4000ns (110194 ticks), event code 140
                    gate =          [0 0   -1   -1];
                    beamTime =      [0 0 1662 1765]*1e-9;
                    beamGateWidth = [0 0   45   45]*1e-9;
                    clockRate(n) = 119*1e6;
                    traces = lcaGetSmart(PV{n});
                    if gate(ch(n)) ~= 0
                        gateEdges(n,3) = max(1,ceil(beamTime(ch(n))*clockRate(n)));
                        gateEdges(n,:) = max(1,min(length(traces),... 
                            gateEdges(n,3)+round(clockRate(n)*[-300e-9,0,0,...
                            beamGateWidth(ch(n))+[0,0,300e-9]])));
                        persist{n} = zeros(nPersist,gateEdges(n,6)-gateEdges(n,1)+1);
                        beamGate{n} = zeros(1,gateEdges(n,6)-gateEdges(n,1)+1);
                        if gate(ch(n)) < 0
                            gateEdges(n,2:5) = max(1,min(length(traces),... 
                                gateEdges(n,3)+round(clockRate(n)*[-200e-9,0,...
                                beamGateWidth(ch(n))+[0,200e-9]])));
                            beamGate{n}(([gateEdges(n,2):gateEdges(n,3)-1,...
                                          gateEdges(n,4)+1:gateEdges(n,5)])...
                                         -gateEdges(n,1)+1) = 1;
                        else
                            beamGate{n}((gateEdges(n,3):gateEdges(n,4))...
                                        -gateEdges(n,1)+1) = 1;
                        end
                    end
                    
                case 5  % Acromag IP330a digitizer
                    PV{n} = ['DMP:THZ:R03:AIN:ai0:',num2str(ch(n))];
                    yAxisUnit{n} = ' [V]';
                    
                case 6  % SRS830 lock-in amp
                    lockNames = {'X';'Y';'R';'TH'};
                    PV{n} = ['THZ:AMP2:SR830:1:',lockNames{ch(n)}];
                    yAxisUnit{n} = ' [V]';
                    deviceRate(n) = 3;
                    
                case 7  % Nilsson group's mass spectrometer
                    PV{n} = 'THZ:RGA:01:Bar:Val-Buf';
                    yAxisUnit{n} = ' [Torr]';
                    RgaBuffer = 100;
                    RGA = zeros(NSteps,RgaBuffer);
                    doRGA(n) = 1;
                    deviceRate(n) = 8;
                    velocity = min(0.4,max(0.02,abs(step)));
                    temperature = zeros(NSteps,1);
                    tempScale = 100;
            end
        
        case 'facet'
            maxBeamRate = 10;
            switch source(n)
                case 1  % Scope
                    scope{n} = ['SCOP:LI20:TDS1',num2str(floor((ch(n)-1)/4))];
                    runScope{n}  = strcat(scope{n},':RUN.PROC');
                    stopScope{n} = strcat(scope{n},':STOP.PROC');
                    PV{n} = [scope{n},':GS_CH',num2str(mod(ch(n)-1,4)+1),...
                        '_WFORM.VALA'];
                    scalePV{n} = [scope{n},':W_CH',num2str(ch(n)),'_SCL'];
                    scale = lcaGetSmart(scalePV{n});
                    scaleIndex(n) = find(strcmp(scale,scaleStr),1,'first');
                    scaleFactor(n) = scaleVal(scaleIndex(n));
                    yAxisUnit{n} = ' [mV]'; 
                    deviceRate(n) = 5;
                case 2  % Struck digitizer
                    PV{n} = ['FADC',num2str(floor(ch(n)/8)),...
                        ':LI20:EX01:waveform',num2str(mod(ch(n),8))];
                    if beamRate > 1
                        if StruckRate >= 120
                            s = 0;
                            for m=1:50
                                s = s + lcaGetSmart(['FADC',...
                                    num2str(floor(ch(n)/8)),':LI20:EX01:perSecond']);
                                pause(0.2)
                            end
                            StruckRate = max(1,s/50);
                        end
                    else
                        StruckRate = 10;
                    end
                    clockStr = char(lcaGetSmart(['FADC',...
                        num2str(floor(ch(n)/8)),':LI20:EX01:clock']));
                    clockRate(n) = str2double(clockStr(1:3))*1e6;
                    if maxMin(n) == 0
                        yAxisUnit{n} = ' [mV*us]';
                    else
                        yAxisUnit{n} = ' [mV]';
                    end
                    scaleFactor(n) = 5000;
                    deviceRate(n) = StruckRate;
                    minStruck(:) = 0;
                    maxStruck(:) = 1;
                case 3  % CAEN digitizer
                    PV{n} = ['GADC0:LI20:EX01:AI:CH',num2str(ch(n))];
                    lcaPutSmart('GADC0:LI20:EX01:LO:SC:IPED',64); % Pedestal
                    yAxisUnit{n} = ' [pC]';
                case 4  % SLAC digitizer
                    switch ch(n)
                        case 1
                            PV{n} = 'BLEN:LI20:3014:BL31A_R_WF';%_S_R_WF
                        case 2
                            PV{n} = 'BLEN:LI20:3014:BL31B_R_WF';
                        case 3
                            PV{n} = 'THZR:LI20:3075:C_R_WF';
                        otherwise
                            PV{n} = 'THZR:LI20:3075:D_R_WF';
                    end
                    if maxMin(n) == 0
                        yAxisUnit{n} = ' [counts*us]';
                    else
                        yAxisUnit{n} = ' [counts]';
                    end
                case 5  % "Bunch length" from integrating the SLAC digitizer
                    switch ch(n)
                        case 1
                            PV{n} = 'BLEN:LI20:3014:ARAW';
                        case 2
                            PV{n} = 'BLEN:LI20:3014:BRAW';
                    end
                    yAxisUnit{n} = ' [counts]';
            end
    end
    if strcmp(description{n},'Description') || isempty(description{n})
        description{n} = PV{n};
    end
    switch n
        case 1
            set(handles.SigADesc','String',description{n})
        case 2
            set(handles.SigBDesc','String',description{n})
        case 3
            set(handles.SigCDesc','String',description{n})
        case 4
            set(handles.SigDDesc','String',description{n})
        case 5
            set(handles.SigEDesc','String',description{n})
    end
    k = strfind(description{n},'_');
    descript(n) = description(n);
    if ~isempty(k)
        for m = length(k):-1:1
            if k>1
                descript{n} = [descript{n}(1:k(m)-1),'\',...
                    descript{n}(k(m):length(descript{n}))];
            else
                descript{n} = ['\',descript{n}];
            end
        end
    end
    yAxisLabel{n} = [yAxisLabel{n},'=',descript{n}];
    if size([yAxisLabel{n},yAxisUnit{n}]) > 20
        yAxisLabelFontSize = 8;
    end
end
if strcmp(THzSource,'lcls')...
        && (any(source==2) || any(source==4)...
        && any(gateEdges(:,2)<gateEdges(:,3)))
    diff    = complex(diff);
    meanSig = complex(meanSig);
    allSig  = complex(allSig);
end
devRate = min(deviceRate);
MatchPulseIDs = get(handles.PulseID,'Value');
% Typically <80-ms time-stamp match
% maxTStampDiff = max(0.1,1/min(beamRate,devRate))/(3600*24);

%--------------------------------------------------------------------------
% Get baselines, when needed beforehand
baseline  = [0 0 0 0 0];
bkgdBefore = [get(handles.SigABkgdGetBefore,'Value'),...
              get(handles.SigBBkgdGetBefore,'Value'),...
              get(handles.SigCBkgdGetBefore,'Value'),...
              get(handles.SigDBkgdGetBefore,'Value'),...
              get(handles.SigEBkgdGetBefore,'Value')];
for n = 1:nSig
    if bkgdBefore(n)
        status = [' Finding baseline for Signal ',sigName{n},'.'];
        set(handles.Status,'String',status)
        % Set up for baseline measurement
        switch THzSource
            case 'lcls'
                switch source(n)
                    case 2  % Struck digitizer
                        % lcaPutSmart('DMP:THZ:EVR:01:EVENT14CTRL.ENM',22);
                        % lcaPutSmart('DMP:THZ:EVR:01:EVENT1CTRL.OUT0','Disabled');
                        % lcaPutSmart('DMP:THZ:EVR:01:EVENT14CTRL.OUT0','Enabled');
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.ENM',22);
                        lcaPutSmart('EVR:DMP1:MC01:EVENT1CTRL.OUT2','Disabled');
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.OUT2','Enabled');
                    case 3  % CAEN digitizer
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.ENM',20);
                        lcaPutSmart('EVR:DMP1:MC01:EVENT1CTRL.OUT0','Disabled');
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.OUT0','Enabled');
                    case 4 % SLAC digitizer ("pizza box")
                        lcaPutSmart('EVR:UND1:BLF1:EVENT14CTRL.ENM',20);
                        lcaPutSmart('EVR:UND1:BLF1:EVENT1CTRL.OUT0','Disabled');
                        lcaPutSmart('EVR:UND1:BLF1:EVENT14CTRL.OUT0','Enabled');
                        
                    case {5,6,7}  % Acromag, lock-in, or mass spectrometer
                        % Toggle catalysis flipper
                        lcaPutSmart('DMP:THZ:FLP:06',0);
                        pause(1)
                end
            case 'facet'
                switch source(n)
                    case 2  % Struck digitizer
                        lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.ENM',52);
                        if floor(ch(n)/8) == 0
                            lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUTC','Disabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUTD','Disabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUTD','Enabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUTC','Enabled');
                        else
                            lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUT1','Disabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUT1','Enabled');
                        end
                    case 3  % CAEN digitizer
                        lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.ENM',52);
                        lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUT9','Disabled');
                        lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUT9','Enabled'); 
                end
        end

        % Check for rate, and then measure baseline
        beamRate = lcaGetSmart(ratePV);
        while beamRate <= 0 && ~StopScan
            pause(2)
            status = ' No beam rate';
            set(handles.Status,'String',status)
            beamRate = lcaGetSmart(ratePV);
        end
        beamRate = max(1,min(maxBeamRate,beamRate));
        repTime = scopeAveraging/min(beamRate,deviceRate(n));
        nMean = min(100,ceil(20/repTime));
        tic
        for m = 1:nMean
            pause(max(0.005,repTime-toc))
            traces = lcaGetSmart(PV{n});
            tic
            if     source(n) == 2
                goodPt  = ~isnan(traces) & traces>minStruck(n) & traces<maxStruck(n);
                startPt = find(goodPt,1,'first');
               	stopPt  = find(goodPt,1,'last');
                baseline(n) = baseline(n) + mean(traces(startPt:stopPt));
            elseif source(n) == 4
                goodPt  = ~isnan(traces) & abs(traces)<2^16-1;
                startPt = find(goodPt,1,'first');
               	stopPt  = find(goodPt,1,'last');
                baseline(n) = baseline(n) + mean(traces(startPt:stopPt));
            elseif source(n) == 7
                goodPt  = ~isnan(traces);
                startPt = find(goodPt,1,'first');
               	stopPt  = find(goodPt,1,'last');
                baseline(n) = baseline(n) + mean(traces(startPt:stopPt));                
            else
                baseline(n) = baseline(n) + traces;
            end
        end
        baseline(n) = baseline(n)/nMean;

        % Restore setup for measuring signal
        switch THzSource
            case 'lcls'
                switch source(n)
                    case 2  % Struck digitizer
                        % lcaPutSmart('DMP:THZ:EVR:01:EVENT1CTRL.ENM',140);
                        % lcaPutSmart('DMP:THZ:EVR:01:EVENT14CTRL.OUT0','Disabled');
                        % lcaPutSmart('DMP:THZ:EVR:01:EVENT1CTRL.OUT0','Enabled');
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.ENM',13);
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.OUT2','Disabled');
                        lcaPutSmart('EVR:DMP1:MC01:EVENT1CTRL.OUT2','Enabled');
                    case 3  % CAEN digitizer
                        lcaPutSmart('EVR:DMP1:MC01:EVENT1CTRL.ENM',140);
                        lcaPutSmart('EVR:DMP1:MC01:EVENT13CTRL.OUT0','Disabled');
                        lcaPutSmart('EVR:DMP1:MC01:EVENT1CTRL.OUT0','Enabled');             
                    case 4  % SLAC digitizer ("pizza box")
                        lcaPutSmart('EVR:UND1:BLF1:EVENT14CTRL.ENM',13);
                        lcaPutSmart('EVR:UND1:BLF1:EVENT14CTRL.OUT0','Disabled');
                        lcaPutSmart('EVR:UND1:BLF1:EVENT1CTRL.OUT0','Enabled');
                    case {5,6,7} % Acromag, lock-in, or mass spectrometer
                        % Toggle catalysis flipper
                        lcaPutSmart('DMP:THZ:FLP:06',0);
                        pause(1)
                end
            case 'facet'
                switch source(n)
                    case 2  % Struck digitizer
                        lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.ENM',203);
                        if floor(ch(n)/8) == 0
                            lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUTC','Disabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUTD','Disabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUTD','Enabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUTC','Enabled');
                        else
                            lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUT1','Disabled');
                            lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUT1','Enabled');
                        end
                    case 3  % CAEN digitizer
                        lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.ENM',203);
                        lcaPutSmart('EVR:LI20:EX01:EVENT14CTRL.OUT9','Disabled');
                        lcaPutSmart('EVR:LI20:EX01:EVENT1CTRL.OUT9','Enabled');             
                end
        end
    end
end

%--------------------------------------------------------------------------
% Get mean of reference (later used to reject invalid shots)
beamRate = lcaGetSmart(ratePV);
while beamRate <= 0 && ~StopScan && ~PauseScan
    pause(2)
    status = ' No beam rate';
    set(handles.Status,'String',status)
    beamRate = lcaGetSmart(ratePV);
end
beamRate = max(1,min(maxBeamRate,beamRate));
repTime = scopeAveraging/min(beamRate,deviceRate(1));
nMean = min(100,ceil(20/repTime));
refSamples = zeros(1,nMean);
m = 0;
tic

% Measure reference
while m<nMean && ~StopScan && ~PauseScan && nNorm
    status = sprintf(' Finding mean of Reference channel, point %d of %d.',...
        m,nMean);
    set(handles.Status,'String',status)
    pause(max(0.005,repTime-toc));
    tic
    traces = lcaGetSmart(PV{1});
    OK = 1;
    if source(1)<3 || doRGA(1) || source(1)==4
        switch source(1)
            case 1  % Scope
                startPt = 1;
                stopPt  = scopePoints;
                p = max(traces(1:scopePoints)) -...
                    min(traces(1:scopePoints));
                if any(abs(traces(1:scopePoints)) > 5) &&...
                        scaleIndex(1) < length(scaleVal)
                    scaleIndex(1) = scaleIndex(1)+1;
                    OK = 0; % Off scale: Redo with new scale
                elseif p < 1 && scaleIndex(1) > 1
                    scaleIndex(1) = scaleIndex(1)-1;
                    OK = 0; % Low scale: Redo with new scale
                end
                if ~OK
                    scaleFactor(1) = scaleVal(scaleIndex(1));
                    lcaPutSmart(scalePV{1},scaleStr{scaleIndex(1)});
                    status = ' Changed scope scale. Repeating point.';
                    set(handles.Status,'String',status)
                end
            case 2  % Struck digitizer
                goodPt  = ~isnan(traces) &...
                    traces>minStruck(1) & traces<maxStruck(1);
                startPt = find(goodPt,1,'first');
                stopPt  = find(goodPt,1,'last')-20;
                if stopPt-startPt < 499
                    OK = 0;
                    status = ' Bad points in waveform. Repeating.';
                    set(handles.Status,'String',status)
                end
            case 4  % SLAC pizza-box digitizer
                goodPt  = ~isnan(traces);
                startPt = find(goodPt,1,'first');
                stopPt  = find(goodPt,1,'last');
                if stopPt-startPt < 499
                    OK = 0;
                    status = ' Bad points in waveform. Repeating.';
                    set(handles.Status,'String',status)
                end
            case 7  % Mass spectrometer
                goodPt  = ~isnan(traces) & traces>0;
                startPt = find(goodPt,1,'first');
                stopPt  = find(goodPt,1,'last');
        end
        if OK
            if doRGA(1)
                d = mean(traces(startPt:stopPt)-baseline(n));
            else
                if ~bkgdBefore(1)
                    baseline(1) = mean(traces(...
                        startPt:startPt+ceil((stopPt-startPt+1)/10)));
                end
                if maxMin(1)
                    % Peak
                    smoothed = zeros(stopPt-startPt+1,1);
                    for p = startPt:stopPt
                        psmooth = p-startPt+1;
                        weights = 0;
                        for pp = max(p-smooth,startPt):min(p+smooth,stopPt)
                            weight = 1 - abs(p-pp)/(smooth+1);
                            weights = weights + weight;
                            smoothed(psmooth) = smoothed(psmooth) +...
                                traces(pp)*weight;
                        end
                        smoothed(psmooth) = smoothed(psmooth)/weights;
                    end
                    smoothed = smoothed-baseline(1);
                    if strcmp(THzSource,'lcls')...
                        && (source(1)==2 || source(1)==4) && gateEdges(1,3)>0
                        if gateEdges(1,2) < gateEdges(1,3)
                            % Gates before and after beam time
                            pDiff =  max(smoothed((gateEdges(n,2):...
                                gateEdges(n,3)-1)-startPt+1));
                            nDiff = -min(smoothed((gateEdges(n,2):...
                                gateEdges(n,3)-1)-startPt+1));
                            d = max(pDiff,nDiff)*sign(pDiff-nDiff);
                            pDiff =  max(smoothed((gateEdges(n,4)+1:...
                                gateEdges(n,5))-startPt+1));
                            nDiff = -min(smoothed((gateEdges(n,4)+1:...
                                gateEdges(n,5))-startPt+1));
                            d = d+1i*max(pDiff,nDiff)*sign(pDiff-nDiff);
                        else
                            % Gate during beam time
                            pDiff =  max(smoothed((gateEdges(n,3):...
                                gateEdges(n,4))-startPt+1));
                            nDiff = -min(smoothed((gateEdges(n,3):...
                                gateEdges(n,4))-startPt+1));
                            d = max(pDiff,nDiff)*sign(pDiff-nDiff);
                        end
                    else
                        pDiff =  max(smoothed);
                        nDiff = -min(smoothed);
                        d = max(pDiff,nDiff)*sign(pDiff-nDiff);
                    end
                else
                    % Integral
                    if strcmp(THzSource,'lcls')...
                        && (source(1)==2 || source(1)==4) && gateEdges(1,3)>0
                        if gateEdges(1,2) < gateEdges(1,3)
                                % Gates before and after beam time
                            d = sum(traces(...
                                (gateEdges(1,2):gateEdges(1,3)-1)-gateEdges(1,1)+1))...
                                +1i*sum(traces(...
                                (gateEdges(1,4)+1:gateEdges(1,5))-gateEdges(1,1)+1))...
                                -(1*1i)*baseline(1);
                        else
                            % Gate during beam time
                            d = sum(traces(...
                                (gateEdges(1,3):gateEdges(1,4))-gateEdges(1,1)+1))...
                                -baseline(n);
                        end
%                         d = sum((traces(startPt:stopPt)-baseline(1))...
%                             .*beamGate{1}(startPt:stopPt));
                    else
                        d = sum(traces(startPt:stopPt)-baseline(1));
                    end
                    d = d*1e6/clockRate(1);
                end
            end
        end
    else     % CAEN digitizer, BRAW, Acromag, or lock-in
        d = traces(1)-baseline(1);
    end

    if OK
        m = m+1;
        refSamples(m) = d;
    end
end
if nNorm
    refStd  = std(refSamples);
    refMean = mean(refSamples);
    if abs(refMean) < refStd
        reflow  = 0;
        refhigh = 3*refStd;
        refplotlow = -refhigh;
    else
        reflow  = refMean*refLow;
        refhigh = refMean*refHigh;
        refplotlow = reflow;
    end
    status  = [' Reference mean = ',num2str(refMean),...
        ' +- ',num2str(100*refStd/abs(refMean),'%4.2f'),'%'];
    set(handles.Status,'String',status)
    pause(2)
end

%--------------------------------------------------------------------------
% Move stage to starting position, but quit if motor doesn't respond
if ~strcmp(motorPV,'TIME') && ~strcmp(motorPV,'SAMPLES')
    status = ' Motor moving to first position.';
    set(handles.Status,'String',status)
    if phaseShifter
        % Take small steps to avoid losing laser lock or jumping by a period
        % Steps are relative to phase-shifter setting before scan (delay=0)
        newPhase = round(1e-12*start*fRF*oneCycle);
        m = 0;
        while abs(m) < abs(newPhase)
            m = m+sign(start);
            lcaPutSmart(motorPV,mod(before+m,oneCycle));
            pause(0.01);
        end
    elseif laser && start~=before
        st = (start-before)/max(1,floor(abs(start-before)/laserStep));
        for m = before+st:st:start
            lcaPutSmart(motorPV,m);
            pause(laserPause)
        end
    else
        lcaPutSmart(motorPV,start);
        pause(1)
    end

    % Count times when motor appears stuck, and quit on 3rd failure
    howFar = abs(start-before);
    motorCheck = 0; 
    while howFar > abs(min(step))/10 && ~phaseShifter && ~laser
        pause(0.5)
        howFarNow = abs(lcaGetSmart(readbackPV)-start);
        if howFar - howFarNow >= abs(min(step))/10
            howFar = howFarNow;
            motorCheck = 0;
            pause(0.25)
        else
            if motorCheck < 2
                motorCheck = motorCheck + 1;
            else
                howFar = -1;
                StopScan = -1;
                status = ' Motor is not responding. Aborting scan.';
                set(handles.Status,'String',status)
            end
        end
    end
    if laser
        laserPhaseMotor = lcaGetSmart(laserPhaseMotorPV);
        pause(0.5)
        while motorCheck<3 &&...
                abs(lcaGetSmart(laserPhaseMotorPV)-laserPhaseMotor)>1e-3
            if motorCheck < 2
                motorCheck = motorCheck + 1;
                pause(0.5)
                laserPhaseMotor = lcaGetSmart(laserPhaseMotorPV);
                pause(0.5)
            else
                StopScan = -1;
                status = ' Laser phase motor is not responding. Aborting scan.';
                set(handles.Status,'String',status)
            end
        end
    end
    if ~StopScan
        status = ' Motor is at first position.';
        set(handles.Status,'String',status)
    end
end

%--------------------------------------------------------------------------
% Set up the figure(s)
if any(size(figHandle)>0) && ishandle(figHandle(1))
    close(figHandle(1))
end
if any(doRGA) && any(size(figHandle)>1) && ishandle(figHandle(2))
    close(figHandle(2))
end
if length(figHandle)>1
    for k = 2:length(figHandle)
        if  ishandle(figHandle(k))
            close(figHandle(k))
        end
    end
end
nSubplots(1) = nSig + nNorm + (any(doRGA) && mode==2);
axisHandle = zeros(1,nSubplots(1));
if mode == 1
    if motorNumber >= 0
        figTitle = ['Scan of Motor ',num2str(motorNumber),...
            ' with steps of ',num2str(step),' ',motorUnit];
    else
        figTitle = ['Scan of ',motorPV,' with steps of ',num2str(step)];
    end
else
    figTitle = 'Strip Chart';
end
if motorNumber >= 0
    switch mode
        case 1  % Scan Mode
            xLabel = ['Position of Motor ',num2str(motorNumber),...
                ' [',motorUnit,']'];
        case 2  % Strip-Chart Mode
            xLabel = ['Measuring with Motor ',num2str(motorNumber),...
                ' at ',num2str(start),' ',motorUnit];
        case 3  % On-Peak/Off-Peak Mode
            xLabel = ['Measuring with Motor ',num2str(motorNumber),...
                ' at ',num2str(start),' and ',num2str(stop),...
                ' ',motorUnit];
    end
elseif phaseShifter
    switch mode
        case 1  % Scan Mode
            xLabel = ['Phase-Shifter Delay [',motorUnit,']'];
        case 2  % Strip-Chart Mode
            xLabel = ['Measuring with Phase-Shifter Delay at',...
                num2str(start),' ',motorUnit];
        case 3  % On-Peak/Off-Peak Mode
            xLabel = ['Measuring with Phase-Shifter Delay at ',...
                num2str(start),' and ',num2str(stop),' ',motorUnit];
    end
else
    switch mode
        case 1  % Scan Mode
            xLabel = [motorPV,' [',motorUnit,']'];
        case 2  % Strip-Chart Mode
            if strcmp(motorPV,'SAMPLES')
                xLabel = motorPV;
            else
                xLabel = ['Measuring with ',motorPV,' at ',num2str(start)];
            end
        case 3  % On-Peak/Off-Peak Mode
            xLabel = ['Measuring with ',motorPV,' at ',num2str(start),...
                ' and ',num2str(stop),' [',motorUnit,']'];
    end
end
if motorNumber < 0
    k = strfind(figTitle,'_');
    if ~isempty(k)
        for m = length(k):-1:1
            figTitle =...
                [figTitle(1:k(m)-1),'\',figTitle(k(m):length(figTitle))];
        end
    end
    k = strfind(xLabel,'_');
    if ~isempty(k)
        for m = length(k):-1:1
            xLabel = [xLabel(1:k(m)-1),'\',xLabel(k(m):length(xLabel))];
        end
    end
end
figHandle = 0;
if nSubplots(1) <= 5
    subplots = [nSubplots(1),1];
    subplotOrder = (1:nSubplots(1));
    figHandle(1) = figure('Position',[40,40,900,300+200*subplots(1)],...
        'Name',figTitle);
else
    subplots = [ceil(nSubplots(1)/2),2];
    subplotOrder = [1:2:nSubplots(1),2:2:nSubplots(1)];
    figHandle(1) = figure('Position',[40,40,1100,300+200*subplots(1)],...
        'Name',figTitle);
end
if strcmp(THzSource,'lcls') &&...
        ((any(source(n)==2) || any(source(n)==4)) && gateEdges(n,3)>0)
    figHandle = [figHandle(1),0];
    nSubplots(2) = 0;
    for n = 1:nSig
        if (source(n)==2 || source(n)==4) && gateEdges(n,3)>0
            nSubplots(2) = nSubplots(2)+1;
        end
    end
    figHandle(2) = figure('Position',[1200,40,400*nSubplots(2),450],...
        'Name','Loss-Monitor Traces ');
    axisHandle = [axisHandle,zeros(1,nSig)];
end

%==========================================================================
% Measure the points and update the plots
mStep = 0;
startTimeSteps = now;
while mStep < NSteps && ~StopScan
    if PauseScan
        pause(0.5)
    else
        mStep = mStep+1;
        k = 1;
        startTime = now;

        % Move stage to next position
        if mode == 1
            if rgaMotor
                if mStep == 1
                    % If the scan uses catalysis Z motor (33), then the X
                    % motor (34) must move a bit too, since the surface is
                    % tilted by 3 degrees. The initial X position will be
                    % set manually by the user.
                    lcaPutSmart([motorPV,'.VELO'],velocity)
                    if strcmp(THzSource,'lcls') && motorNumber==33 && mode==1
                        tilt34 = 3*pi/180;
                        stop34 = lcaGetSmart('THZ:TST:MMS:34.RBV') -...
                            (stop-start)*tan(tilt34);
                        lcaPutSmart('THZ:TST:MMS:34.VELO',...
                            velocity*tan(tilt34));
                        lcaPutSmart({motorPV;'THZ:TST:MMS:34'},[stop;stop34]);
                    else
                        lcaPutSmart(motorPV,stop);
                    end
                end
                x(mStep) = lcaGetSmart(readbackPV);
            elseif phaseShifter && mStep > 1
                newPhase = round(1e-12*x(mStep)  *fRF*oneCycle);
                oldPhase = round(1e-12*x(mStep-1)*fRF*oneCycle);
                m = 0;
                while abs(m) < abs(newPhase-oldPhase)
                    m = m+sign(newPhase-oldPhase);
                    lcaPutSmart(motorPV,mod(before+oldPhase+m,oneCycle));
                    pause(0.01);
                end
            elseif laser && mStep > 1
                st = x(mStep)-x(mStep-1);
                m = floor(abs(st)/laserStep);
                for n = 1:m
                    lcaPutSmart(motorPV,x(mStep-1)+n*st);
                    pause(laserPause)
                end
                lcaPutSmart(motorPV,x(mStep));
                laserPhaseMotor = lcaGetSmart(laserPhaseMotorPV);
                pause(0.1)
                while abs(lcaGetSmart(laserPhaseMotorPV)-laserPhaseMotor)...
                        > 1e-3 && ~PauseScan
                    pause(0.05)
                    laserPhaseMotor = lcaGetSmart(laserPhaseMotorPV);
                    pause(0.05)
                end
            elseif strcmp(motorPV,'TIME')
                pause(x(mStep)-(now-startTimeSteps)*3600*24-0.15)
            else
                lcaPutSmart(motorPV,x(mStep));
                pause(0.05)
                while abs(lcaGetSmart(readbackPV)-x(mStep)) > ...
                        abs(min(step))*0.01 && ~PauseScan
                    pause(0.05)
                end
            end
        elseif mode == 3
            if phaseShifter
                startPhase = round(1e-12*start*fRF*oneCycle);
                stopPhase  = round(1e-12*stop *fRF*oneCycle);
                if mod(mStep,2)
                    newPhase = startPhase;    % On peak for mStep odd
                    oldPhase = stopPhase;
                else
                    newPhase = stopPhase;     % Off peak for mStep even
                    oldPhase = startPhase;
                end
                m = 0;
                while abs(m) < abs(newPhase-oldPhase)
                    m = m+sign(newPhase-oldPhase);
                    lcaPutSmart(motorPV,mod(before+oldPhase+m,oneCycle));
                    pause(0.01);
                end
            elseif laser && mStep > 1
                if mod(mStep,2)
                    newPos = start;    % On peak for mStep odd
                    oldPos = stop;
                else
                    newPos = stop;     % Off peak for mStep even
                    oldPos = start;
                end
                st = newPos-oldPos;
                m = floor(abs(st)/laserStep);
                for n = 1:m
                    lcaPutSmart(motorPV,oldPos+n*st);
                    pause(laserPause)
                end
                lcaPutSmart(motorPV,newPos);
                laserPhaseMotor = lcaGetSmart(laserPhaseMotorPV);
                pause(0.1)
                while abs(lcaGetSmart(laserPhaseMotorPV)-laserPhaseMotor)...
                        > 1e-3 && ~PauseScan
                    pause(0.05)
                    laserPhaseMotor = lcaGetSmart(laserPhaseMotorPV);
                    pause(0.05)
                end
            else
                if mod(mStep,2)
                    newPos = start;    % On peak for mStep odd
                else
                    newPos = stop;     % Off peak for mStep even
                end
                lcaPutSmart(motorPV,newPos);
                pause(0.2)
                while abs(lcaGetSmart(readbackPV)-newPos)...
                        > abs(min(step))*0.01 && ~PauseScan
                    pause(0.05)
                end
            end
        end

        if mode == 1
            if phaseShifter
                stepxStr = sprintf(' Step %d of %d, x = %8.4f ps, point',...
                    mStep,NSteps,1e12*x(mStep)/(oneCycle*fRF));
            else
                stepxStr = sprintf(' Step %d of %d, x = %8.4f %s, point',...
                    mStep,NSteps,x(mStep),motorUnit);
            end
        else
            stepxStr = sprintf(' Step %d of %d, point',mStep,NSteps);
        end
        stepStr = sprintf('%s  1.',stepxStr);
        
        % Check beam rate, and wait if there is no beam
        beamRate = lcaGetSmart(ratePV);
        while beamRate <= 0 && ~StopScan && ~PauseScan
            pause(2)
            status = strcat(stepStr,'  No beam rate');
            set(handles.Status,'String',status)
            beamRate = lcaGetSmart(ratePV);
        end
        beamRate = max(1,min(maxBeamRate,beamRate));
        repTime = scopeAveraging/min(beamRate,devRate);
        
        % Get nAverage measurements
        if any(doRGA)
            rga = zeros(nAverage,RgaBuffer);
            temper = zeros(1,nAverage);
        end
        tic
        while k <= nAverage && ~StopScan && ~PauseScan
            if mode==2 && strcmp('motorPV','SAMPLES')
                pause(max(0.01,repTime-toc));
            else
                pause(max(0.005,repTime-toc));
            end
            tic
            if all(source==1)
                lcaPutSmart(stopScope,0);
                pause(0.25)
            end
            % Get data and time stamps
            [traces,tStampCA] = lcaGetSmart(PV);
            OK = 1;
            if all(source==1)
                lcaPutSmart(runScope,0);
            end
            if MatchPulseIDs
                % Check matching of pulse IDs.
                pulseID = lcaTs2PulseId(tStampCA);
                if any(pulseID(2:end)~=pulseID(1))
                    OK = 0;
                    status = strcat(stepStr,'  Mismatched pulse IDs.');
                    set(handles.Status,'String',status)
                    disp(status)
                    disp([pulseID,[0;pulseID(2:end)-pulseID(1:end-1)]])
                end
            else
                % Check matching of time stamps. Note that they often are
                % mismatched if signals come from different sources. It's
                % best to have all of them on the Struck, for example.
                tStampML = lca2matlabTime(tStampCA);
                for n = 1:nSig
                    if OK && tStampML(n)<=tStampOld(n)
                        OK = 0;
                        status = sprintf('%s  Time stamp of %s did not change.',...
                            stepStr,sigName{n});
                        set(handles.Status,'String',status)
                    end
                end
                if OK  && ((now-max(tStampML) > 10*maxTStampDiff)...
                       ||  (now-min(tStampML) > 10*maxTStampDiff))
                    status = [stepStr,'  Bad time stamps: Difference from now is  ',...
                        num2str((now-min(tStampML))*24*3600,'%5.3f s')];
                    set(handles.Status,'String',status)
                elseif OK && max(tStampML)-min(tStampML) > maxTStampDiff
                    OK = 0;
                    status = [stepStr,'  Mismatched time stamps: ',...
                        num2str((max(tStampML)-min(tStampML))*24*3600,'%5.3f s')];
                    set(handles.Status,'String',status)
                end
            end

            sPlot = 0;
            for n = 1:nSig
                if OK && (source(n)<3 || doRGA(n) || source(n)==4)
                    switch source(n)
                        case 1  % Scope
                            startPt = 1;
                            stopPt  = scopePoints;
                            p = max(traces(n,1:scopePoints)) -...
                                min(traces(n,1:scopePoints));
                            if any(abs(traces(n,1:scopePoints)) > 5) &&...
                                    scaleIndex(n) < length(scaleVal)
                                scaleIndex(n) = scaleIndex(n)+1;
                                OK = 0; % Off scale: Redo with new scale
                            elseif p < 1 && scaleIndex(n) > 1
                                scaleIndex(n) = scaleIndex(n)-1;
                                OK = 0; % Low scale: Redo with new scale
                            end
                            if ~OK
                                scaleFactor(n) = scaleVal(scaleIndex(n));
                                lcaPutSmart(scalePV{n},scaleStr{scaleIndex(n)});
                                k = 1;
                                status = strcat(stepStr,...
                                    '  Changed scope scale.');
                            end
                        case 2  % Struck digitizer
                            goodPt  = ~isnan(traces(n,:)) &...
                                traces(n,:)>minStruck(n) & traces(n,:)<maxStruck(n);
                            startPt = find(goodPt,1,'first');
                            stopPt  = find(goodPt,1,'last')-20;
                            if isempty(startPt) || isempty(stopPt) ||...
                                    stopPt-startPt < 499
                                OK = 0;
                                status = strcat(stepStr,...
                                    '  Bad points in waveform.');
                            end
                        case 4  % SLAC digitizer
                            goodPt  = ~isnan(traces(n,:));
                            startPt = find(goodPt,1,'first');
                            stopPt  = find(goodPt,1,'last');
                            if isempty(startPt) || isempty(stopPt) ||...
                                    stopPt-startPt < 499
                                OK = 0;
                                status = strcat(stepStr,...
                                    '  Bad points in waveform.');
                            end
                        case 7  % Mass spectrometer
                            goodPt  = ~isnan(traces(n,:));
                            startPt = find(goodPt,1,'first');
                            stopPt  = find(goodPt,1,'last');
                            if isempty(startPt) || isempty(stopPt) ||...
                                    stopPt-startPt > RgaBuffer-1
                                OK = 0;
                                status = strcat(stepStr,...
                                    '  Bad points in waveform.');
                            end
                    end
                    if OK
                        if doRGA(n)
                            diff(k,n) =...
                                mean(traces(n,startPt:stopPt)-baseline(n),2);
                            rga(k,startPt:stopPt) =...
                                traces(n,startPt:stopPt)-baseline(n);
                            temper(k) = lcaGetSmart('DMP:THZ:R03:AIN:ai0:0');
                        else
                            if ~bkgdBefore(n)
                                baseline(n) = mean(traces(n,...
                                    startPt:startPt+ceil((stopPt-startPt)/10)),2);
                            end
                            if maxMin(n)
                                % Peak
                                smoothed = zeros(1,stopPt-startPt+1);
                                for p = startPt:stopPt
                                    psmooth = p-startPt+1;
                                    weights = 0;
                                    for pp = max(p-smooth,startPt):min(p+smooth,stopPt)
                                        weight = 1 - abs(p-pp)/(smooth+1);
                                        weights = weights + weight;
                                        smoothed(psmooth) = smoothed(psmooth) +...
                                            traces(n,pp)*weight;
                                    end
                                    smoothed(psmooth) = smoothed(psmooth)/weights;
                                end
                                smoothed = smoothed-baseline(n);
                                if strcmp(THzSource,'lcls')...
                                    && (source(n)==2 || source(n)==4)...
                                    && gateEdges(n,3)>0
                                    pPersist(n) = mod(pPersist(n),nPersist)+1;
                                    fPersist(n) = min(fPersist(n)+1,nPersist);
                                    pts = max(startPt,gateEdges(n,1)):...
                                          min( stopPt,gateEdges(n,6));
                                    ns = (pts-gateEdges(n,3))*1e9/clockRate(n);
                                    persist{n}(pPersist(n),:) = traces(n,pts)-baseline(n);
                                    persist{n}(pPersist(n),...
                                        ([gateEdges(n,1):startPt,...
                                        stopPt:gateEdges(n,6)]-gateEdges(n,1)+1)) = 0;
                                    if fPersist(n) < nPersist
                                        jTrc = fPersist(n):-1:1;
                                    else
                                        jTrc = [pPersist(n):-1:1,nPersist:-1:pPersist(n)+1];
                                    end
                                    figure(figHandle(2))
                                    sPlot = sPlot+1;
                                    subplot(1,nSubplots(2),sPlot)
                                    hold on
                                    b = 0;
                                    for jt = jTrc
                                        if axisHandle(nSubplots(1)+n)
                                            plot(axisHandle(nSubplots(1)+n),...
                                                ns,persist{n}(jt,:),...
                                                'Color',[b b 1])
                                        else
                                            plot(ns,persist{n}(jt,:),...
                                                'Color',[b b 1])
                                            axisHandle(nSubplots(1)+n) = gca;
                                        set(gca,'XLim',[ns(1),ns(end)])
                                        xlabel('Time (ns)')
                                        title(descript(n))
                                        end
                                        b = b+1/nPersist;
                                    end
                                    if mStep == min(5,NSteps)
                                        ylm1(n) = -10^round(log10(abs(mean(...
                                            min(persist{n}(1:5,:),[],2)/3))));
                                    end
                                    if mStep >= 5 
                                        plot(ns,ylm1(n)*beamGate{n},'g')
                                    end
                                    hold off
                                    figure(figHandle(1))
                                    if gateEdges(n,2) < gateEdges(n,3)
                                        % Gates before and after beam time
                                        pDiff =  max(smoothed((gateEdges(n,2):...
                                            gateEdges(n,3)-1)-startPt+1));
                                        nDiff = -min(smoothed((gateEdges(n,2):...
                                            gateEdges(n,3)-1)-startPt+1));
                                        diff(k,n) = max(pDiff,nDiff)*sign(pDiff-nDiff);
                                        pDiff =  max(smoothed((gateEdges(n,4)+1:...
                                            gateEdges(n,5))-startPt+1));
                                        nDiff = -min(smoothed((gateEdges(n,4)+1:...
                                            gateEdges(n,5))-startPt+1));
                                        diff(k,n) = diff(k,n)...
                                            +1i*max(pDiff,nDiff)*sign(pDiff-nDiff);
                                    else
                                        % Gate during beam time
                                        pDiff =  max(smoothed((gateEdges(n,3):...
                                            gateEdges(n,4))-startPt+1));
                                        nDiff = -min(smoothed((gateEdges(n,3):...
                                            gateEdges(n,4))-startPt+1));
                                        diff(k,n) = max(pDiff,nDiff)*sign(pDiff-nDiff);
                                    end
                                else
                                    pDiff =  max(smoothed);
                                    nDiff = -min(smoothed);
                                    diff(k,n) = max(pDiff,nDiff)*sign(pDiff-nDiff);
                                end
                            else
                                % Integral
                                if strcmp(THzSource,'lcls')...
                                    && (source(n)==2 || source(n)==4)...
                                    && ~isempty(beamGate{n})
                                    pPersist(n) = mod(pPersist(n),nPersist)+1;
                                    fPersist(n) = min(fPersist(n)+1,nPersist);
                                    pts = gateEdges(n,1):gateEdges(n,6);
                                    ns = (pts-gateEdges(n,3))*1e9/clockRate(n);
                                    persist{n}(pPersist(n),:) = traces(n,pts)-baseline(n);
                                    persist{n}(pPersist(n),...
                                        ([gateEdges(n,1):startPt,...
                                        stopPt:gateEdges(n,6)]-gateEdges(n,1)+1)) = 0;
                                    if fPersist(n) < nPersist
                                        jTrc = fPersist(n):-1:1;
                                    else
                                        jTrc = [pPersist(n):-1:1,nPersist:-1:pPersist(n)+1];
                                    end
                                    figure(figHandle(2))
                                    sPlot = sPlot+1;
                                    subplot(1,nSubplots(2),sPlot)
                                    hold on
                                    b = 0;
                                    for jt = jTrc
                                        if axisHandle(nSubplots(1)+n)
                                            plot(axisHandle(nSubplots(1)+n),...
                                                ns,persist{n}(jt,:),...
                                                'Color',[b b 1])
                                        else
                                            plot(ns,persist{n}(jt,:),...
                                                'Color',[b b 1])
                                            set(gca,'XLim',[ns(1),ns(end)])
                                            xlabel('Time (ns)')
                                            title(descript(n))
                                            axisHandle(nSubplots(1)+n) = gca;
                                        end
                                        b = b+1/nPersist;
                                    end
                                    if mStep == min(5,NSteps)
                                        ylm1(n) = -10^round(log10(abs(mean(...
                                            min(persist{n}(1:5,:),[],2)/3))));
                                    end
                                    if mStep >= 5
                                        plot(ns,ylm1(n)*beamGate{n},'g')
                                    end
                                    hold off
                                    figure(figHandle(1))
                                    if gateEdges(n,2) < gateEdges(n,3)
                                        % Gates before and after beam time
                                        diff(k,n) = sum(persist{n}(pPersist(n),...
                                            (gateEdges(n,2):gateEdges(n,3)-1)-gateEdges(n,1)+1))...
                                            +1i*sum(persist{n}(pPersist(n),...
                                            (gateEdges(n,4)+1:gateEdges(n,5))-gateEdges(n,1)+1))...
                                            -(1*1i)*baseline(n);
                                    else
                                        % Gate during beam time
                                        diff(k,n) = sum(persist{n}(pPersist(n),...
                                            (gateEdges(n,3):gateEdges(n,4))-gateEdges(n,1)+1))...
                                            -baseline(n);
                                    end
                                else
                                    diff(k,n) = sum(traces(n,startPt:stopPt)...
                                        -baseline(n));
                                end
                                diff(k,n) = diff(k,n)*1e6/clockRate(n);
                            end
                        end
                        if get(handles.SaveWaveforms,'Value')==1
                            waveform{k,mStep,n} =...
                                traces(n,startPt:stopPt)-baseline(n);
                        end
                    end
                elseif OK   % CAEN, BRAW, Acromag, or lock-in
                    diff(k,n) = traces(n,1)-baseline(n);
                    if get(handles.SaveWaveforms,'Value')==1
                        waveform{k,mStep,n} = traces(n,1)-baseline(n);
                    end
                end
                % Is reference (Signal A) within bounds?
                if OK && nNorm && n==1 
                    if     abs(real(diff(k,1)))<abs(reflow)
                        status = strcat(stepStr,'  |Reference| < Lower limit');
                        OK = 0;
                    elseif abs(real(diff(k,1)))>abs(refhigh)
                        status = strcat(stepStr,'  |Reference| > Upper limit');
                        OK = 0;
                    end
                end
            end
            
            % If data is valid, advance to the next point.
            if OK
                status = stepStr;
                k = k+1;
                stepStr = sprintf('%s %2d.',stepxStr,k);
                if ~MatchPulseIDs
                    tStampOld = tStampML;
                end
                if strcmp(motorPV,'TIME')
                    x(mStep) = (now-startTimeSteps)*3600*24;
                end
            end
            set(handles.Status,'String',status)
        end

        % Averages and noramlized signals
        if ~StopScan && ~PauseScan
            for n = 1:nSig
                diff(:,n) = diff(:,n)*scaleFactor(n);
                meanSig(mStep,n) = mean(diff(:,n));
                if getErrorBar
                    errorBar(mStep,n) = std(diff(:,n))/sqrt(nAverage);
                end
                if get(handles.SaveMeasurements,'Value') > 0
                    allSig((1-nAverage:0)+nAverage*mStep,n) = diff(:,n);
                end
            end
            for n = 1:nNorm
                switch normOp(n)
                    case 1  % +
                        normSig(mStep,n) = mean(real(diff(:,normNum(n)))...
                                               +real(diff(:,normDenom(n))));
                        if getErrorBar
                            errorBar(mStep,nSig+n) = sqrt((...
                                  errorBar(mStep,normNum(n))^2 ...
                                + errorBar(mStep,normDenom(n))^2)/nAverage);
                        end
                    case 2  % -
                        normSig(mStep,n) = mean(real(diff(:,normNum(n)))...
                                               -real(diff(:,normDenom(n))));
                        if getErrorBar
                            errorBar(mStep,nSig+n) = sqrt((...
                                  errorBar(mStep,normNum(n))^2 ...
                                + errorBar(mStep,normDenom(n))^2)/nAverage);
                        end
                    case 3  % *
                        normSig(mStep,n) = mean(real(diff(:,normNum(n)))...
                                              .*real(diff(:,normDenom(n))));
                        if getErrorBar
                            errorBar(mStep,nSig+n) = normSig(mStep,n)*sqrt((...
                                  (errorBar(mStep,normNum(n))  /meanSig(mStep,normNum(n)))^2 ...
                                + (errorBar(mStep,normDenom(n))/meanSig(mStep,normDenom(n)))^2)...
                                /nAverage);
                        end
                    case 4  % /
                        normSig(mStep,n) = mean(real(diff(:,normNum(n)))...
                                              ./real(diff(:,normDenom(n))));
                        if getErrorBar
                            errorBar(mStep,nSig+n) = normSig(mStep,n)*sqrt((...
                                  (errorBar(mStep,normNum(n))  /meanSig(mStep,normNum(n)))^2 ...
                                + (errorBar(mStep,normDenom(n))/meanSig(mStep,normDenom(n)))^2)...
                                /nAverage);
                        end
                end
            end
            if any(doRGA)
                RGA(mStep,:) = mean(rga,1);
                temperature(mStep) = mean(temper)*tempScale;
            end
            % Contrast (on, off peak) for all signals except reference (A)
            % Expect 0<contrast<1 for field autocorrelations
            if mode == 3 && mStep > 1
                for n = 1:nNorm
                    contrast(mStep-1,n) = 3*(2*mod(mStep,2)-1)*...
                        (normSig(mStep,n)-normSig(mStep-1,n))/...
                        (normSig(mStep,n)+normSig(mStep-1,n));
                end
            end
            
            % Update the plots
            x0 = min(x);
            x1 = max(x);
            figure(figHandle(1))
            p = 0;
            clr = 'g';
            
            while p < nSig
                p = p+1;
                subplot(subplots(1),subplots(2),subplotOrder(p))
                if gateEdges(p,2) < gateEdges(p,3)
                    if axisHandle(p)
                        plot(axisHandle(p),x(1:mStep),real(meanSig(1:mStep,p)),'r',...
                                           x(1:mStep),imag(meanSig(1:mStep,p)),'b')
                    else
                    plot(x(1:mStep),real(meanSig(1:mStep,p)),'r',...
                         x(1:mStep),imag(meanSig(1:mStep,p)),'b')
                    axisHandle(p) = gca;
                    end
                    legend({'Before beam';'After beam'},'FontSize',8)
                else
                    if p > 1
                        clr = 'b';
                    end
                    if getErrorBar
                        if axisHandle(p)
                            axes(axisHandle(p))
                            errorbar(x(1:mStep),real(meanSig(1:mStep,p)),...
                                errorBar(1:mStep,p),clr)
                        else
                            errorbar(x(1:mStep),real(meanSig(1:mStep,p)),...
                                errorBar(1:mStep,p),clr)
                            axisHandle(p) = gca;
                        end
                    else
                        if axisHandle(p)
                            plot(axisHandle(p),x(1:mStep),...
                                real(meanSig(1:mStep,p)),clr)
                        else
                            plot(x(1:mStep),real(meanSig(1:mStep,p)),clr)
                            axisHandle(p) = gca;
                        end
                    end
%                     if p == 1
%                         if axisHandle(p)
%                             plot(axisHandle(p),x(1:mStep),real(meanSig(1:mStep,p)),'g')
%                         else
%                             plot(x(1:mStep),real(meanSig(1:mStep,p)),'g')
%                             axisHandle(p) = gca;
%                         end
%                     else
%                         if axisHandle(p)
%                             plot(axisHandle(p),x(1:mStep),real(meanSig(1:mStep,p)),'b')
%                         else
%                             plot(x(1:mStep),real(meanSig(1:mStep,p)),'b')
%                             axisHandle(p) = gca;
%                         end
%                     end
                end
                if nNorm && p==1
                    hold on
                    line([start,stop],[1,1]*refplotlow,...
                        'Color','k','LineStyle',':')
                    line([start,stop],[1,1]*refhigh,...
                        'Color','k','LineStyle',':')
                    hold off
                end
                ylabel([yAxisLabel{p},yAxisUnit{p}],...
                    'FontSize',yAxisLabelFontSize)
                ylm = get(gca,'YLim');
                axis([x0,x1,min(0,ylm(1)),max(0,ylm(2))])
                if p==subplots(1) || p==nSubplots(1)
                    xlabel(xLabel)
                elseif p==1 || p==subplots(1)+1
                    title(figTitle)
                end
            end
            
            while p < nSig+nNorm
                p = p+1;
                np = p-nSig;
                subplot(subplots(1),subplots(2),subplotOrder(p))
                if mode == 3
                    if axisHandle(p)
                        plot(axisHandle(p),x(1:2:mStep),normSig(1:2:mStep,np),'r')
                    else
                        plot(x(1:2:mStep),normSig(1:2:mStep,np),'r')
                        axisHandle(p) = gca;
                    end
                    if mStep < 2
                        ylabel([yAxisLabel{p},...
                            ', on (-) & off (-.) Peak'],...
                            'FontSize',yAxisLabelFontSize,'Color','r')
                        axis([x0,x1,0,2*normSig(1,np)])
                    else
                        hold on
                        [ax,handle1] = plotyy(x(2:2:max(mStep,2)),...
                            normSig(2:2:max(mStep,2),np),...
                            x(2:max(mStep,2)),...
                            contrast(1:max(mStep-1,1),np));
                        hold off
                        set(handle1,'Color','r','LineStyle','-.')
                        set(get(ax(1),'YLabel'),'String',...
                            [yAxisLabel{np+1},', on (-) & off (-.) Peak'],...
                            'FontSize',yAxisLabelFontSize,'Color','r')
                        set(get(ax(2),'YLabel'),'String',...
                            'Contrast=3*(Pk-Base)/(Pk+Base)',...
                            'FontSize',yAxisLabelFontSize)
                        set(ax(1),'XLim',[x0,x1],'YColor','r')
                        tick1 = get(ax(1),'YTick');
                        nTicks = length(tick1) - 1;
                        tickStep2 = max(0.1,...
                            0.05*ceil(max(contrast(:,np))/(0.05*nTicks)));
                        tick2 = (0:nTicks)*tickStep2;
                        set(ax(2),'XLim',[x0,x1],...
                            'YLim',[0,nTicks*tickStep2],'YTick',tick2)
                    end
                else
                    if getErrorBar
                        if axisHandle(p)
                            axes(axisHandle(p))
                            errorbar(x(1:mStep),normSig(1:mStep,np),...
                                errorBar(1:mStep,p),'r')
                        else
                            errorbar(x(1:mStep),normSig(1:mStep,np),...
                                errorBar(1:mStep,p),'r')
                            axisHandle(p) = gca;
                        end
                    else
                        if axisHandle(p)
                            plot(axisHandle(p),x(1:mStep),normSig(1:mStep,np),'r')
                        else
                            plot(x(1:mStep),normSig(1:mStep,np),'r')
                            axisHandle(p) = gca;
                        end
%                         if axisHandle(p)
%                             plot(axisHandle(p),x(1:mStep),...
%                                 real(meanSig(1:mStep,p)),clr)
%                         else
%                             plot(x(1:mStep),real(meanSig(1:mStep,p)),clr)
%                             axisHandle(p) = gca;
%                         end
                    end
                    ylabel(yAxisLabel(p),'FontSize',yAxisLabelFontSize)
                    y0 = min(normSig(1:mStep,np));
                    y1 = max(normSig(1:mStep,np));
                    if isnan(y0) || isnan(y1) || y0==y1
                        y0 = min([0,y0,y1]);
                        y1 = max([1,y0,y1]);
                    end
                    axis([x0,x1,y0,y1])
                end
                if p==subplots(1) || p==nSubplots(1)
                    xlabel(xLabel)
                elseif p==1 || p==subplots(1)+1
                    title(figTitle)
                end
            end
            pause(0.05)
            if any(doRGA) && mode==2
                p = p+1;
                subplot(subplots(1),subplots(2),subplotOrder(p))
                if axisHandle(p)
                    plot(axisHandle(p),temperature(1:mStep),mean(RGA(1:mStep,:),2))
                else
                    plot(temperature(1:mStep),mean(RGA(1:mStep,:),2))
                    axisHandle(p) = gca;
                end
                xlabel('Temperature [C]')
                ylabel('Partial Pressure [Torr]')
            end
%             if ~strcmp(motorPV,'TIME')
%                 pause(0.1)
%             end
            elapse = (now-startTime)*3600*24;
            if elapsed
                finish = (elapsed+elapse)/2;
            else
                finish = elapse;                
            end
            finish = finish*(NSteps-mStep)/60;
            elapseStr = sprintf(' Last step =%5.1f sec%8.1f min remaining',...
                elapse,finish);
            set(handles.Time,'String',elapseStr);
            elapsed = elapse;
        end
    end
end

disp([x,meanSig,normSig])
% Automatic logging and saving
if get(handles.LogAll,'Value') > 0
    Logbook_Callback(hObject, eventdata, handles)
end
if get(handles.SaveAveraged,'Value') > 0
    FileAveraged_Callback(hObject, eventdata, handles)
end
if get(handles.SaveMeasurements,'Value') > 0
    FileMeasurements_Callback(hObject, eventdata, handles)
end
if get(handles.SaveWaveforms,'Value') > 0
    FileWaveforms_Callback(hObject, eventdata, handles)
end

% Restore stage position
if phaseShifter
    % Take small steps to avoid losing laser lock or jumping by a period.
    m = 0;
    while m < abs(before-newPhase)
        m = m+sign(before-newPhase);
        lcaPutSmart(motorPV,mod(before+newPhase+m,oneCycle));
        pause(0.005);
    end
elseif laser
    r = lcaGet(readbackPV);
    if r ~= before
        st = (before-r)/max(1,floor(abs(r-before)/laserStep));
        for m = r+st:st:before
            lcaPutSmart(motorPV,m);
            pause(laserPause)
        end
    end
else
    lcaPutSmart(motorPV,before);
end
if StopScan > 0
    status = ' Scan stopped by user.';
    if ~strcmp(motorPV,'TIME') && ~strcmp(motorPV,'SAMPLES')
        status = [status,' Returning to original setting.'];
    end
    StopScan = 0;
    set(handles.StopScan,'Value',0)
    set(handles.StopScan,'String','Stop Scan')
elseif StopScan < 0
    close(figHandle)
else
    status = ' Scan completed.';
    if ~strcmp(motorPV,'TIME') && ~strcmp(motorPV,'SAMPLES')
        status = [status,' Returning to original setting.'];
    end
end
if any(doRGA) && StopScan>=0 && any(any(RGA>0))
    figHandle(2) = figure('Position',[70,1020,600,600],...
        'Name','Mass Spectrometer Scans');
    waterfall(RGA)
    xlabel('RGA Sample Buffer')
    if mode == 1
        ylabel('Motor Position [mm]')
    else
        ylabel('Steps')
    end
    zlabel('Partial Pressure [Torr]')
    disp(RGA)
    disp(temperature)
end
set(handles.Status,    'String',status)
set(handles.Time,      'String','')
set(handles.Resume,    'Visible','off')
set(handles.ResumeText,'Visible','off')
% Reset CAEN timing
if strcmp(THzSource,'lcls') && any(source==3)
    lcaPutSmart('QADC:DMP1:100:TDES',oldTDES);    
    lcaPutSmart('QADC:DMP1:100:TWID',oldWidth);
end
set(handles.StartScan, 'Value' ,0)
set(handles.StartScan, 'String','Start Scan')
pause(1)
set(handles.Status,    'String',' Ready...')
end
