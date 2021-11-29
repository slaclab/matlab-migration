function varargout = girderPositionPlotGui(varargin)
% GIRDERPOSITIONPLOTGUI M-file for girderPositionPlotGui.fig
%      GIRDERPOSITIONPLOTGUI, by itself, creates a new GIRDERPOSITIONPLOTGUI or raises the existing
%      singleton*.
%
%      H = GIRDERPOSITIONPLOTGUI returns the handle to a new GIRDERPOSITIONPLOTGUI or the handle to
%      the existing singleton*.
%
%      GIRDERPOSITIONPLOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GIRDERPOSITIONPLOTGUI.M with the given input arguments.
%
%      GIRDERPOSITIONPLOTGUI('Property','Value',...) creates a new GIRDERPOSITIONPLOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before girderPositionPlotGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to girderPositionPlotGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help girderPositionPlotGui

% Last Modified by GUIDE v2.5 23-Jan-2009 13:58:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @girderPositionPlotGui_OpeningFcn, ...
                   'gui_OutputFcn',  @girderPositionPlotGui_OutputFcn, ...
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


% --- Executes just before girderPositionPlotGui is made visible.
function girderPositionPlotGui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Choose default command line output for girderPositionPlotGui
handles.output = hObject;

% times
handles.initTime = datestr(now); 
set(handles.text8,'String',handles.initTime);

% plot parameters
handles.scale = 1000; %initialize default xy scale
handles.rollScale = 8; % initialize default roll scale [mrad]

handles.stop = 0; % stop = 1 means stop the updates
handles.figure = hObject; % handle to the gui figure

%legend(handles.PlotKey, 'Static','Moving')
set(hObject,'CurrentAxes', handles.PlotKey); % set to current so attention isn't grabbed.
hold(handles.PlotKey);
plot(handles.PlotKey,[.15 .4],[.7 .7],'LineWidth',8,...
    'Color',[0 0.5 0]) ;
plot(handles.PlotKey,[.15 .4],[.3 .3],'LineWidth',8,...
    'Color',[0 0 1]) ;
plot(handles.PlotKey,.145,.7,'+')
plot(handles.PlotKey,.405,.7,'d')

text( .15, .55, 'Ready');
text( .15, .15, 'Moving');
text(.08, .79,'BFW');
text(.4, .79,'Q/BPM');
axis off;

% Default is not to display numbers on plots
handles.displayQNumbers = 0;
handles.displayBFWNumbers = 0;

% Initialize Ref positions to home
handles.paRef(33,3) = 0;
handles.pbRef(33,3) = 0;
handles.rRef(33,1) = 0;

% Initialize Init configuration
handles.paInit(33,3) = 0;
handles.pbInit(33,3) = 0;
handles.rInit(33,1) = 0;

% Get initial configuration
for p=1:33
  geo = girderGeo(p);
  [pa, pb, r] = girderAxisFind(p,geo.bfwz, geo.quadz);
  handles.paInit(p,:) = pa;
  handles.pbInit(p,:) = pb;
  handles.rInit(p,:) = r;
end

% Initialize the RPot Find position
handles.pfa = handles.paInit;
handles.pfb = handles.pbInit;
handles.rf = handles.rInit;

% Initial plot type choice 
handles.choice = 1; % actual

% Update handles structure

guidata(hObject, handles);

% UIWAIT makes girderPositionPlotGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = girderPositionPlotGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on START button press
function pushbutton1_Callback(hObject, eventdata, handles)
%
% Continuously plots the horizontal and vertical positions of all girders
%
display('Start Button Pushed');
handles.stop = 0; % unstop it if it is has been stopped
geo = girderGeo();

% pset up figure
slf = 0.8; % faction of plot occupied by plotted segment lengths
%

% Choice of data to plot 1=LPot , 2=RPot, 3=Ref, 4=Init, 5=LPot-RPot, 6=LP-Ref,
% 7=LP-Init, 8=RP-Ref,9=RP-Init

% Loop every couple of seconds
while(handles.stop ~= 1)
    set(hObject,'String','Running...');
    maxDisplay = handles.scale; %scale for displays

    % get current theoretical position data
    for p = 1:33
        [pfa, pfb, rf] = girderAxisFind(p, geo.bfwz, geo.quadz);

        %update handle data
        handles.pfa(p,:) = pfa;
        handles.pfb(p,:) = pfb;
        handles.rf(p) = rf;
    end

    % get the measured position data
    [pa, pb, r] = girderAxisMeasure(1:33,geo.bfwz, geo.quadz);%actual measured

    switch handles.choice
        case 1 % Lpot
            ya1 = pa;
            yb1 = pb;
            r1 = r;

        case 2 % Rpot
            ya1 = handles.pfa;
            yb1 = handles.pfb;
            r1  = handles.rf;

        case 3 % ref
            ya1 = handles.paRef;
            yb1 = handles.pbRef;
            r1  = handles.rRef;

        case 4 % Initial
            ya1 = handles.paInit;
            yb1 = handles.pbInit;
            r1  = handles.rInit;

        case 5 % LPot - RPot
            ya1 = pa - handles.pfa;
            yb1 = pb - handles.pfb;
            r1  = r  - handles.rf;

        case 6 % LPot - Ref
            ya1 = pa - handles.paRef;
            yb1 = pb - handles.pbRef;
            r1 =  r  - handles.rRef;

        case 7 % LPot - Init
            ya1 = pa - handles.paInit;
            yb1 = pb - handles.pbInit;
            r1  = r  - handles.rInit;

        case 8 % RPot - Ref
            ya1 =  handles.pfa - handles.paRef;
            yb1 =  handles.pfb - handles.pbRef;
            r1  =  handles.rf  - handles.rRef;

        case 9 % RPot - Init
            ya1 =  handles.pfa - handles.paInit;
            yb1 =  handles.pfb - handles.pbInit;
            r1  =  handles.rf  - handles.rInit;
    end

    % get the moving status and set color
    for p = 1:33
        status{p} = girderMotorStatusRead(p);
        if strcmp(status{p}, 'Moving')
            segColor(p,:) = [0 0 1];
        else
            segColor(p,:) = [0 .5  0];
        end
    end

 % x position plot (Plan View)
    cla(handles.Horizontal);
    set(handles.figure,'CurrentAxes', handles.Horizontal); % set to current so attention isn't grabbed.

    hold on;
    plot( handles.Horizontal,[0 33], [0 0],'-.k',...
        'LineWidth',1.5 )
    for p=1:33 % plot lots of short segments
          
        plot(handles.Horizontal, [p-slf/2, p+slf/2], [ 1000*ya1(p,1) 1000*yb1(p,1) ],'-',...
            'LineWidth',8,...
            'Color',segColor(p,:)) ;
        plot(handles.Horizontal,p-slf/2, 1000*ya1(p,1),'+');
        plot(handles.Horizontal,p+slf/2, 1000*yb1(p,1),'d');
        
        title(handles.Horizontal,'Horizontal Position (Plan View)')

        ylabel(handles.Horizontal,'x position [um]')
        ylim([-maxDisplay, maxDisplay]);
        if strcmp(status{p}, 'Moving')
            text(p, 1000*ya1(p,1),'Moving')
        end
        if handles.displayQNumbers
            xnumber = p+slf/2;        
            ynumber = 1000*yb1(p,1);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yb1(p,1),'%3.0f'),...
                'HorizontalAlignment','center');
        end
        if handles.displayBFWNumbers
            xnumber = p-slf/2;
            ynumber = 1000*ya1(p,1);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*ya1(p,1),'%3.0f'),'Color',[.5 .5 .5],...
                'HorizontalAlignment','center');
        end


    end

    text(1,maxDisplay, datestr(now)); % date for whole figure

    % y position Plot, (Elevation View)
    cla(handles.Vertical)
    set(handles.figure,'CurrentAxes', handles.Vertical); % set to current so attention isn't grabbed.
    hold on;
    plot( handles.Vertical,[0 33], [0 0],'-.k',...
        'LineWidth',1.5 )
    for p=1:33 % plot lots of short segments
        plot(handles.Vertical, [p-slf/2, p+slf/2], [ 1000*ya1(p,2) 1000*yb1(p,2) ],'-',...
            'LineWidth',8,...
            'Color',segColor(p,:) );
        plot(handles.Vertical,p-slf/2, 1000*ya1(p,2),'+');
        plot(handles.Vertical,p+slf/2, 1000*yb1(p,2),'d');
      
        title(handles.Vertical, 'Vertical Position (Elevation View)')

        ylabel(handles.Vertical,'y position [um]')
        ylim([-maxDisplay, maxDisplay]);
        if strcmp(status{p}, 'Moving')
            text(p, 1000*ya1(p,2),'Moving')
        end
        
        if handles.displayQNumbers
            xnumber = p+slf/2;
            ynumber = 1000*yb1(p,2);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yb1(p,2),'%3.0f'),...
                'HorizontalAlignment','center');
        end
        if handles.displayBFWNumbers
            xnumber = p-slf/2;
            ynumber = 1000*ya1(p,2);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*ya1(p,2),'%3.0f'),'Color',[.5 .5 .5],...
                'HorizontalAlignment','center');
        end

    end
    
    % Roll Plot, (Side View)
    cla(handles.Roll)
    set(handles.figure,'CurrentAxes', handles.Roll); % set to current so attention isn't grabbed.
    hold on;
    plot( handles.Roll,[0 33], [0 0],'-.k',...
        'LineWidth',1.5 )
    for p=1:33 % plot circles
        plot(handles.Roll, p, 1000*r1(p) ,'o',...
            'Color',segColor(p,:),...
            'LineWidth',2 );
          
        title(handles.Roll, 'Roll (Side View)')

        ylabel(handles.Roll,'Roll  [mrad]')
        ylim([-8, 8]);
        if strcmp(status{p}, 'Moving')
            text(p, 1000*r1(p),'Moving')
        end
    end

    set([handles.Horizontal,handles.Vertical], 'Unit', 'Normalized');% make resizable
    guidata(hObject, handles);
    pause(3)
    handles = guidata(hObject); % update the local handles structure

end %end update loop



% --- Executes on STOP button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stop = 1; %stop the updates
display('Stop Button Pushed.');
    set(handles.pushbutton1,'String','Start');
guidata(hObject, handles);



% --- Executes on selection change in Scale.
function Scale_Callback(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Scale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Scale
scaleIndex = get(hObject,'Value');
switch scaleIndex
    case 1
        handles.scale = 100;
    case 2 
        handles.scale = 200;
    case 3
        handles.scale = 500;
    case 4
        handles.scale = 1000;
    case 5 
        handles.scale = 2000;
    case 6
        handles.scale = 5000;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Value', 4)% default selection is 1000 microns


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% Save present girder positions to reference set

% save current girder position data to ref
  handles.paRef = handles.pfa;
  handles.pbRef = handles.pfb;
  handles.rRef  = handles.rf;
  handles.refTime = datestr(now);
  set(handles.text9,'String', handles.refTime);

%  update the guidata
guidata(hObject, handles);


    
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
%Restore the reference positions when gui was launched
girderAxisSet([1:33], handles.paRef, handles.pbRef, handles.rRef);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
%Restore the initial positions when gui was launched
girderAxisSet([1:33], handles.paInit, handles.pbInit, handles.rInit);

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3

% Select what type of data to plot, update plots
handles.choice = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

util_printLog(handles.figure); % very distorted !


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

display('Display numbers on plots');
%set(handles.pushbutton1,'String','Start');
handles.displayQNumbers = get(hObject, 'Value'); % turn on number display
guidata(hObject, handles);


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
handles.displayBFWNumbers = get(hObject, 'Value'); % turn on number display
guidata(hObject, handles);


