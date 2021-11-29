function varargout = beamline_plot_example(varargin)
% BEAMLINE_PLOT_EXAMPLE M-file for beamline_plot_example.fig
%      BEAMLINE_PLOT_EXAMPLE, by itself, creates a new BEAMLINE_PLOT_EXAMPLE or raises the existing
%      singleton*.
%
%      H = BEAMLINE_PLOT_EXAMPLE returns the handle to a new BEAMLINE_PLOT_EXAMPLE or the handle to
%      the existing singleton*.
%
%      BEAMLINE_PLOT_EXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEAMLINE_PLOT_EXAMPLE.M with the given input arguments.
%
%      BEAMLINE_PLOT_EXAMPLE('Property','Value',...) creates a new BEAMLINE_PLOT_EXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before beamline_plot_example_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to beamline_plot_example_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help beamline_plot_example

% Last Modified by GUIDE v2.5 31-Oct-2008 09:27:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @beamline_plot_example_OpeningFcn, ...
                   'gui_OutputFcn',  @beamline_plot_example_OutputFcn, ...
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


% --- Executes just before beamline_plot_example is made visible.
function beamline_plot_example_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to beamline_plot_example (see VARARGIN)

% Choose default command line output for beamline_plot_example
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes beamline_plot_example wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% jar = '/usr/local/lcls/physics/xyplot/jar/xyplot.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end
% 
% jar = '/usr/local/lcls/physics/xyplot/lib/jcommon-1.0.13.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end
% 
% jar = '/usr/local/lcls/physics/xyplot/lib/servlet.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end
% 
% jar = '/usr/local/lcls/physics/xyplot/libdemo/iText-2.1.1.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end
% 
% jar = '/usr/local/lcls/physics/xyplot/libdemo/jfreechart-1.0.10-experimental.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end
% 
% jar = '/usr/local/lcls/physics/SLAColors/jar/SLAColors.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end
% 
% jar = '/usr/local/lcls/physics/beamlineZplot/jar/beamlineZplot.jar';
% if exist(jar,'file')
%     javaaddpath(jar);
% end

javaclasspath

global myeDefNumber
global BSA_pvs
global numBSA_pvs
global BPM_z

try
    myCounter_pv = 'SIOC:SYS0:ML00:AO400'
    lcaPut(myCounter_pv, 1+lcaGet(myCounter_pv))
    counter = lcaGet(myCounter_pv)
    myName = sprintf('beamline plot %d',counter)
    myNAVG = 1
    myNRPOS = 1
    BSA_pvs_fmt = {'BPMS:IN20:221:XHST%d';'BPMS:IN20:235:XHST%d';'BPMS:IN20:371:XHST%d'}
    BPM_z = [0.892574 1.21666 5.18331]
    myeDefNumber = eDefReserve(myName)
    eDefParams (myeDefNumber, myNAVG, myNRPOS, {''},{'TS4';'pockcel_perm'},{''},{''})

    BSA_pvs = cell(0);
    numBSA_pvs = size(BSA_pvs_fmt,1)
    for i=1:numBSA_pvs
        BSA_pvs{end+1} = sprintf(BSA_pvs_fmt{i},myeDefNumber)
    end

catch

    'Dang, eDef setup didn''t work'

end


% --- Outputs from this function are returned to the command line.
function varargout = beamline_plot_example_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1




% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import edu.stanford.slac.util.zplot.*

global myeDefNumber
global BSA_pvs
global numBSA_pvs
global BPM_z

try
    sprintf('collect BSA data for eDef %d',myeDefNumber)
    timeout = 3.0 % seconds
    eDefAcq(myeDefNumber, timeout)

    data = lcaGet(BSA_pvs')

    numPlots = 1;
    try
        if exist('edu/stanford/slac/util/zplot/ZPlot')
            zPlot = edu.stanford.slac.util.zplot.ZPlot(numPlots)

            firstPlot = getSubplot(zPlot, 0)
            rangeAxis = getRangeAxis(firstPlot)
            setLabel(rangeAxis,'BPM X Data')
            bpms = javaArray('edu.stanford.slac.util.zplot.model.Device', numBSA_pvs)
            cartoonDevices = javaArray('edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice', numBSA_pvs)
            for i=1:numBSA_pvs
                bpms(i) = edu.stanford.slac.util.zplot.model.Device(BSA_pvs{i}, BPM_z(i), data(i,1), getBPMWidget(edu.stanford.slac.util.zplot.model.WidgetsRepository, 1))
                cartoonDevices(i) = edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(BSA_pvs{i}, BPM_z(i), edu.stanford.slac.util.zplot.cartoon.model.widget.BPMWidget())
            end

            setDevices(zPlot, firstPlot, bpms, 0, getRenderer(zPlot))
            setCartoonDevices(zPlot, cartoonDevices)

            panel = javax.swing.JPanel()
            frame = javax.swing.JFrame()
            zPlotPanel = edu.stanford.slac.util.zplot.ZPlotPanel(panel, zPlot)
            setPreferredSize(frame, java.awt.Dimension(800, 400))
            pack(frame)
            add(frame,panel)
            setVisible(frame,1)
            repaint(zPlotPanel)
        end
    catch
        'Dang, unable to create zPlot'
    end

catch

    'Dang, eDefAcq failed.'

end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global myeDefNumber

sprintf('release eDef %d on exit',myeDefNumber)
eDefRelease(myeDefNumber)
util_appClose (hObject)
lcaClear()


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




