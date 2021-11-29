function varargout = undulatorPositionPlotGui(varargin)
% undulatorPOSITIONPLOTGUI M-file for undulatorPositionPlotGui.fig
%      undulatorPOSITIONPLOTGUI, by itself, creates a new undulatorPOSITIONPLOTGUI or raises the existing
%      singleton*.
%
%      H = undulatorPOSITIONPLOTGUI returns the handle to a new undulatorPOSITIONPLOTGUI or the handle to
%      the existing singleton*.
%
%      undulatorPOSITIONPLOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in undulatorPOSITIONPLOTGUI.M with the given input arguments.
%
%      undulatorPOSITIONPLOTGUI('Property','Value',...) creates a new undulatorPOSITIONPLOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before undulatorPositionPlotGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to undulatorPositionPlotGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help undulatorPositionPlotGui

% Last Modified by GUIDE v2.5 19-May-2009 11:51:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @undulatorPositionPlotGui_OpeningFcn, ...
                   'gui_OutputFcn',  @undulatorPositionPlotGui_OutputFcn, ...
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


% --- Executes just before undulatorPositionPlotGui is made visible.
function undulatorPositionPlotGui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Set defaults and load initial data
%

% Choose default command line output for undulatorPositionPlotGui
handles.output = hObject;

% Start time
handles.initTime = datestr(now);
set(handles.text8,'String',handles.initTime);

% Plot parameters
handles.scale = 1000; %initialize default xy scale
handles.rollScale = 8; % initialize default roll scale [mrad]

handles.stop = 0; % stop = 1 means stop the updates
handles.figure = hObject; % handle to the gui figure

% Plot Key
set(hObject,'CurrentAxes', handles.PlotKey); % set to current so attention isn't grabbed.
hold(handles.PlotKey);

% plot(handles.PlotKey,[.15 .5],[.7 .7],'LineWidth',8,...
%     'Color',[0 0.5 0]) ;
% plot(handles.PlotKey,[.15 .5],[.3 .3],'LineWidth',8,...
%     'Color',[0 0 1]) ;
% plot(handles.PlotKey,.145,.7,'+')
% plot(handles.PlotKey,.405,.7,'d')
% 
% plot(handles.PlotKey,[.15 .5],[0 0],'LineWidth', 5,...
%     'Color',[0 .2 .2]);
% 
% text( .15, .55, 'Ready');
% text( .15, .15, 'Moving');
% text(.15,  -.15, 'Segment');
% text(.08, .79,'BFW');
% text(.4, .79,'Q/BPM');

axis off;
linespacing = 1/8;
voff= .1;
text(.05, linespacing - voff,'Q');
text(.05, 2*linespacing - voff,'BFW');
text(.05, 3*linespacing - voff,'   offset');
text(.05, 4*linespacing - voff,'BPM');
text(.05, 5*linespacing - voff,'Undulator');
text(.05, 6*linespacing - voff,'   Ready');
text(.05, 7*linespacing - voff,'   Moving');
text(.05, 8*linespacing - voff,'Girder');

hspace = .7;
plot(hspace, linespacing - voff,'d');
plot(hspace, 2*linespacing - voff,'+');
plot(hspace, 3*linespacing - voff,'o');
plot(hspace, 3*linespacing - voff,'+');
plot(hspace, 4*linespacing - voff,'o');
plot([hspace,hspace+.2], [5*linespacing - voff, 5*linespacing - voff],...
    'LineWidth', 5,'Color',[0 .2 .2]);% Undulator
plot([hspace,hspace+.2], [6*linespacing - voff, 6*linespacing - voff],...
    'LineWidth',8,'Color',[0 0.5 0]) ;% Girder Ready
plot([hspace,hspace+.2], [7*linespacing - voff, 7*linespacing - voff],...
    'LineWidth',8,    'Color',[0 0 1]) ;% Girder Moving

% Display Numbers on Plots
handles.displayQnumbers = 1;
handles.displayBFWnumbers = 0;
handles.displayBPMnumbers = 0;
handles.displayUnumbers = 1; % translation position
handles.displayBPMoffsetNumbers = 1;
on = get(handles.checkbox5,'Max')';
set(handles.checkbox5,'Value', on);
on = get(handles.checkbox8,'Max')';
set(handles.checkbox8,'Value', on);
on = get(handles.checkbox10,'Max')';
set(handles.checkbox10,'Value', on);

% Default symbols to display
handles.displayQsymbols = 1;
handles.displayBFWsymbols = 1;
handles.displayBPMsymbols = 0;
handles.displayUsymbols = 1;
handles.displayBPMoffsets = 0;
handles.displayGirders = 1;
on = get(handles.checkbox1,'Max')';
set(handles.checkbox1,'Value', on);
on = get(handles.checkbox2,'Max')';
set(handles.checkbox2,'Value', on);
on = get(handles.checkbox4,'Max')';
set(handles.checkbox4,'Value', on);
on = get(handles.checkbox11,'Max')';
set(handles.checkbox11,'Value', on);

% Position data structures are of the form:
%
%     handles.dataset.zpoint.datatype = [33x3]
%
%     dataset is one of:   {'Current', 'Init', 'Ref', 'Score'}
%     zpoint is one of:    {'bfw', 'bpm', 'quad', 'roll'}
%     datatype is one of:  {'MOTR', 'LPOT', 'RPOT'}
%
% BPM offset data is in structures of the form:
%
%     handles.dataset.bpmOffset = [34x1]
%
%     bpmOffset is one of:  {'X', 'Y'}

handles.zpoints = {'bfw', 'bpm', 'quad', 'roll'};
handles.datasets = {'Current', 'Init', 'Ref', 'Score', 'Home'};
handles.dataTypes = {'MOTR', 'LPOT', 'RPOT'};
handles.bpmOffsets ={'X','Y'};

% Default choices for data sets and types
handles.data1Type = handles.dataTypes{1}; % use motor readback for position calculations
handles.data2Type = handles.dataTypes{1};
set(handles.uipanel8,'SelectedObject',handles.radiobutton2); % pre-select Motor
set(handles.uipanel9,'SelectedObject',handles.radiobutton5);  % pre-select Motor

handles.data1Choice = 'Current'; % 'current' is chosen for one data set
handles.data2Choice = 'Home'; % Home position, for "absolute" plots
set(handles.listbox2,'Value',5);

% Setup data panel data type
set(handles.uipanel8,'SelectionChangeFcn', @uipanel8_SelectionChangeFcn)
set(handles.uipanel9,'SelectionChangeFcn', @uipanel9_SelectionChangeFcn)

% Get the Initial current position data
handles = getCurrentPositionData(handles);
handles.Init = handles.Current;

% Define Home position
for p=1:length(handles.dataTypes)
    for q=1:(length(handles.zpoints) - 1)
        handles.Home.(handles.zpoints{q}).(handles.dataTypes{p}) = zeros(33,3);
    end
    handles.Home.roll.(handles.dataTypes{p}) = zeros(33,1);
end

handles.Home.(handles.bpmOffsets{1}) = zeros(34,1); %bpm offsets "home"
handles.Home.(handles.bpmOffsets{2}) = zeros(34,1);

% Initialize Score and Ref to Home
handles.Score = handles.Home;
handles.Ref = handles.Home;

% Get undulator segment translations
handles.translation = segmentTranslate();

% Get current value of  34 RF bpm offsets
[xoff, yoff] = bpmOffsetRead(); %includes RFB07, RFB08, and RFB00
xoff.a(1:2) = []; %get rid of non RFBPMs
yoff.a(1:2) = [];
handles.Init.(handles.bpmOffsets{1}) = xoff.a;
handles.Init.(handles.bpmOffsets{2}) = yoff.a;

% Update guidata
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = undulatorPositionPlotGui_OutputFcn(hObject, eventdata, handles)
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
handles.stop = 0; % unstop it if has been stopped
geo = girderGeo();
for q = 1:33
    pvSegmentInstall{q,1} = sprintf('USEG:UND1:%d50:INSTALTNSTAT', q); % installation status
end

% set up figure
slf = 0.8; % faction of plot occupied by plotted segment lengths

%  Default data sets to display
%       Plotted data is always data1 - data2
%       data1 choices are 1=Current, 2=Ref, 3=Init, 4=Score
%       data2 choices are  1=Current, 2=Ref, 3=Init, 4=Score 5=Home
%       default is data1 = current data2 = Home


% Main data taking and plotting update Loop
while(handles.stop ~= 1)

    set(hObject,'String','Running...');

    % pick up scale for displays
    maxDisplay = handles.scale;

    % get current data of all types
    handles = getCurrentPositionData(handles);

 
    % store the current state of check boxes
    handles.displayQsymbols = get(handles.checkbox1,'Value'); %Value=1 if checked
    handles.displayBFWsymbols = get(handles.checkbox2, 'Value');
    handles.displayBPMsymbols = get(handles.checkbox3,'Value');
    handles.displayUsymbols = get(handles.checkbox4,'Value');
    handles.displayBPMoffsets = get(handles.checkbox9,'Value');
    handles.displayGirders = get(handles.checkbox11,'Value');
    
    handles.displayQnumbers = get(handles.checkbox5,'Value');
    handles.displayBFWnumbers = get(handles.checkbox6,'Value');
    handles.displayBPMnumbers = get(handles.checkbox7,'Value');
    handles.displayUnumbers = get(handles.checkbox8,'Value');  
    handles.displayBPMoffsetNumbers = get(handles.checkbox10,'Value');
    
    % Form the data arrays to be plotted
    yaData1 = handles.(handles.data1Choice).bfw.(handles.data1Type);
    ybData1 = handles.(handles.data1Choice).bpm.(handles.data1Type);
    ycData1 = handles.(handles.data1Choice).quad.(handles.data1Type);
    rData1  = handles.(handles.data1Choice).roll.(handles.data1Type);
    ydData1 = handles.(handles.data1Choice).(handles.bpmOffsets{1});%X offsets
    yeData1 = handles.(handles.data1Choice).(handles.bpmOffsets{2});%Y offsets

    yaData2 = handles.(handles.data2Choice).bfw.(handles.data2Type);
    ybData2 = handles.(handles.data2Choice).bpm.(handles.data2Type);
    ycData2 = handles.(handles.data2Choice).quad.(handles.data2Type);
    rData2  = handles.(handles.data2Choice).roll.(handles.data2Type);
    ydData2 = handles.(handles.data2Choice).(handles.bpmOffsets{1});%X offsets
    yeData2 = handles.(handles.data2Choice).(handles.bpmOffsets{2});%Y offsets
    
    % Form the variables to be plotted
    ya1 = yaData1 - yaData2; %bfw positions
    yb1 = ybData1 - ybData2; %bpm positions
    yc1 = ycData1 - ycData2; %quad positions
    r1 = rData1 - rData2;    % rolls
    yd1 = ydData1 - ydData2; %bpm X offsets
    ye1 = yeData1 - yeData2; %bpm Y offsets
    
    % get the moving and installation status and set color
    for p = 1:33
        status{p} = girderMotorStatusRead(p);
        if strcmp(status{p}, 'Moving')
            girderColor(p,:) = [0 0 1];
        else
            girderColor(p,:) = [0 .5  0];
        end
    end


    handles.installed = lcaGetSmart(pvSegmentInstall); % 'INSTALLED' or 'NOT_INSTALLED'
    for q=1:33
        if strcmp(handles.installed{q}, 'INSTALLED')
            segmentColor(q,:) = 0.3* [0 0 1];
        else
            segmentColor(q,:) = [.8 .8 .8];
        end
    end


    % Plan View Plot
    cla(handles.Horizontal);
    set(handles.figure,'CurrentAxes', handles.Horizontal); % set to current so attention isn't grabbed.

    hold on;
    title(handles.Horizontal,'Horizontal Position (Plan View)')
    ylabel(handles.Horizontal,'x position [um]')
    plot( handles.Horizontal,[0 33], [0 0],'-.k',...
        'LineWidth',1.5 ) % reference line
    for p=1:33 % plot lots of short segments from bfws to quads
        if handles.displayGirders
            plot(handles.Horizontal, [p-slf/2, p+slf/2], [ 1000*ya1(p,1) 1000*yc1(p,1) ],'-',...
                'LineWidth',8,...
                'Color',girderColor(p,:)) ;
        end
        if handles.displayBFWsymbols
            plot(handles.Horizontal,p-slf/2, 1000*ya1(p,1),'+');
        end
        if handles.displayBPMsymbols
            plot(handles.Horizontal,p+slf/2, 1000*yb1(p,1),'o');
        end
        if handles.displayQsymbols
            plot(handles.Horizontal,p+slf/2, 1000*yc1(p,1),'d');
        end

        ylim([-maxDisplay, maxDisplay]);
        if strcmp(status{p}, 'Moving')
            text(p, 1000*ya1(p,1),'Moving')
        end
        if (handles.displayQnumbers && handles.displayQsymbols)
            xnumber = p+slf/2;
            ynumber = 1000*yc1(p,1);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yc1(p,1),'%3.0f'),...
                'HorizontalAlignment','center');
        end
        if (handles.displayBFWnumbers && handles.displayBFWsymbols)
            xnumber = p-slf/2;
            ynumber = 1000*ya1(p,1);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*ya1(p,1),'%3.0f'),'Color',[.5 .5 .5],...
                'HorizontalAlignment','center');
        end
        if (handles.displayBPMnumbers && handles.displayBPMsymbols)
            xnumber = p+slf/2;
            ynumber = 1000*yb1(p,1);
            extension = 0.25*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*1.5*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yb1(p,1),'%3.0f'),'Color',[0 .2 .2],...
                'HorizontalAlignment','center');
        end


    end
    
    for p=1:34 % bpm offset have 34 values
        if handles.displayBPMoffsets
            plot(handles.Horizontal, p+slf/2-1, 1000*yd1(p,1),'o',...
                p+slf/2-1, 1000*yd1(p,1),'+');
        end
        if (handles.displayBPMoffsetNumbers && handles.displayBPMoffsets)
            xnumber = p+slf/2-1;
            ynumber = 1000*yd1(p,1);
            extension = 0.25*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*1.5*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yd1(p,1),'%3.0f'),'Color',[0 .2 .2],...
                'HorizontalAlignment','center');
        end
    end



    text(1,maxDisplay, datestr(now)); % date for whole figure

    % Elevation View Plot
    cla(handles.Vertical)
    set(handles.figure,'CurrentAxes', handles.Vertical); % set to current so attention isn't grabbed.
    hold on;
    plot( handles.Vertical,[0 33], [0 0],'-.k',...
        'LineWidth',1.5 )
    for p=1:33 % plot lots of short segments
        if handles.displayGirders
            plot(handles.Vertical, [p-slf/2, p+slf/2], [ 1000*ya1(p,2) 1000*yc1(p,2) ],'-',...
                'LineWidth',8,...
                'Color',girderColor(p,:) );
        end
        if handles.displayBFWsymbols
            plot(handles.Vertical,p-slf/2, 1000*ya1(p,2),'+');
        end
        if handles.displayBPMsymbols
            plot(handles.Vertical,p+slf/2, 1000*yb1(p,2),'o');
        end
        if handles.displayQsymbols
            plot(handles.Vertical,p+slf/2, 1000*yc1(p,2),'d');
        end


        title(handles.Vertical, 'Vertical Position (Elevation View)')

        ylabel(handles.Vertical,'y position [um]')
        ylim([-maxDisplay, maxDisplay]);
        if strcmp(status{p}, 'Moving')
            text(p, 1000*ya1(p,2),'Moving')
        end

        if (handles.displayQnumbers && handles.displayQsymbols)
            xnumber = p+slf/2;
            ynumber = 1000*yc1(p,2);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yc1(p,2),'%3.0f'),...
                'HorizontalAlignment','center');
        end
        if (handles.displayBFWnumbers && handles.displayBFWsymbols)
            xnumber = p-slf/2;
            ynumber = 1000*ya1(p,2);
            extension = 0.1*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*2*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*ya1(p,2),'%3.0f'),'Color',[.5 .5 .5],...
                'HorizontalAlignment','center');
        end
        if (handles.displayBPMnumbers && handles.displayBPMnumbers)
            xnumber = p+slf/2;
            ynumber = 1000*yb1(p,2);
            extension = 0.25*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*1.5*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*yb1(p,2),'%3.0f'),'Color',[0 .2 .2],...
                'HorizontalAlignment','center');
        end

        end
    
    
    for p=1:34 % bpm offsets have 34 values
        if handles.displayBPMoffsets
            plot(handles.Vertical, p+slf/2-1, 1000*ye1(p,1),'o',...
                p+slf/2 -1 , 1000*ye1(p,1),'+');
        end
        if (handles.displayBPMoffsets && handles.displayBPMoffsetNumbers)
            xnumber = p+slf/2 - 1;
            ynumber = 1000*ye1(p,1);
            extension = 0.25*handles.scale;% vertical offset from number to pt
            yposoff = (ynumber >= 0)*extension; % displace up if non-negative
            ynegoff = -(ynumber < 0)*1.5*extension;  % displace down if negative
            ynumber = ynumber + yposoff + ynegoff;
            text(xnumber,ynumber, num2str(1000*ye1(p,1),'%3.0f'),'Color',[0 .2 .2],...
                'HorizontalAlignment','center');
        end
    end

    % Undulator or Roll Plot
    cla(handles.Roll)
    set(handles.figure,'CurrentAxes', handles.Roll); % set to current so attention isn't grabbed.
    hold on;
    %     plotSegments = get(handles.checkbox4, 'Max');
    %     handles.displayUnumbers = get(handles.checkbox8,'Value');
    %
    % if get(handles.checkbox4,'Value') == plotSegments  % Plot Undulator Segments
    if handles.displayUsymbols
        for p=1:33 % plot lots of short segments
            plot( [p-slf/2, p+slf/2], [ handles.translation(p), handles.translation(p)],'-',...
                'LineWidth',5,...
                'Color',segmentColor(p,:) );
            if  handles.displayUnumbers == get(handles.checkbox8,'Max');
                xnumber = p;
                ynumber = handles.translation(p);
                extension = 5;% vertical offset from n umber to pt
                yposoff = extension; % displace up always for translation
                ynumber = ynumber + yposoff ;
                text(xnumber,ynumber, num2str(handles.translation(p),'%4.1f'),'Color',[0 .2 .2],...
                    'HorizontalAlignment','center');
            end
            ylim([-10, 90]);
            ylabel('Translation [mm]');
            title('Undulator Segment Horizontal Translation')
            plot( handles.Roll,[0 33], [0 0],'-.k',...
                'LineWidth',1.5 )
        end

    else % Plot Roll
        plot( handles.Roll,[0 33], [0 0],'-.k',...
            'LineWidth',1.5 )
        for p=1:33 % plot circles
            plot(handles.Roll, p, 1000*r1(p) ,'o',...
                'Color',girderColor(p,:),...
                'LineWidth',2 );

            title(handles.Roll, 'Roll (Side View)')

            ylabel(handles.Roll,'Roll  [mrad]')
            ylim([-8, 8]);
            if strcmp(status{p}, 'Moving')
                text(p, 1000*r1(p),'Moving')
            end
        end
    end


    set([handles.Horizontal,handles.Vertical], 'Unit', 'Normalized');% make resizable



    guidata(hObject, handles); % update handles

    pause(1.5);
    drawnow; % maybe this will flush events
    handles = guidata(hObject); % update the local handles structure

end %end update loop


function handles = getCurrentPositionData(handles)
%
% Returns handle with current position and offset data of all types

geo = girderGeo;
lcaSetSeverityWarnLevel(4); % to remove warnings from low bpm signals


% MOTOR
[pbfw, pquad, r] = girderAxisFind(1:33,geo.bfwz, geo.quadz);
[pbfw, pbpm, r] = girderAxisFind(1:33,geo.bfwz, geo.bpmz);
data = {pbfw, pbpm, pquad, r};

for k=1:length(handles.zpoints)
    handles.Current.(handles.zpoints{k}).MOTR = data{k};
end

% LPOT 
[pbfw, pquad, r] = girderAxisMeasure(1:33,geo.bfwz, geo.quadz);
[pbfw, pbpm, r] = girderAxisMeasure(1:33,geo.bfwz, geo.bpmz);
data = {pbfw, pbpm, pquad, r};

for k=1:length(handles.zpoints)
    handles.Current.(handles.zpoints{k}).LPOT = data{k};
end

% RPOT
for p=1:33
    rPotAngles = (pi/180)*girderRotaryPot(p); % degrees to radians
    [pbfw(p,:) r(p)]  = girderAngle2Axis(geo.bfwz, rPotAngles);
    [pquad(p,:) r(p)] = girderAngle2Axis(geo.quadz, rPotAngles);
    [pbpm(p,:)  r(p)] = girderAngle2Axis(geo.bpmz, rPotAngles);
end
data = {pbfw, pbpm, pquad, r};

for k=1:length(handles.zpoints)
    handles.Current.(handles.zpoints{k}).RPOT = data{k};
end

% Get undulator segment positions
handles.translation = segmentTranslate(); % return all 33 positions

% Get current values of  34 RF bpm offsets
[xoff, yoff] = bpmOffsetRead(); %includes RFB07, RFB08, and RFB00
xoff.a(1:2) = []; %get rid of non RFBPMs
yoff.a(1:2) = [];
handles.Current.(handles.bpmOffsets{1}) = xoff.a;
handles.Current.(handles.bpmOffsets{2}) = yoff.a;



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

  handles.Ref =handles.Current;
  
  handles.refTime = datestr(now);
  set(handles.text9,'String', handles.refTime);

%  update the guidata
guidata(hObject, handles);
    
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
%Restore the reference positions when gui was launched
pa = handles.Ref.bfw.MOTR;
pb = handles.Ref.quad.MOTR;
roll = handles.Ref.roll.MOTR;
display('Restoring Reference Cam and BPMs')
girderAxisSet([1:33], pa, pb, roll);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
%Restore the initial positions when gui was launched
display('Restore Initial Cam and BPMs')
girderAxisSet([1:33], handles.Init.bfw.MOTR,...
    handles.Init.quad.MOTR, handles.Init.roll.MOTR); 

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)

% Select which data1 sets to plot
choiceNumber = get(hObject,'Value');
choices = get(hObject, 'String'); % 'Current', 'Ref', 'Initial', 'SCORE'

% handles.datasets = {'Current', 'Init', 'Ref', 'Score'};
choiceStr = choices{choiceNumber};
switch choiceStr
    case 'Current'
        handles.data1Choice = handles.datasets{1};
    case 'Ref'
        handles.data1Choice = handles.datasets{3};
    case 'Initial'
        handles.data1Choice = handles.datasets{2};
    case 'SCORE'
        handles.data1Choice = handles.datasets{4};
end

display(['Data1 data set chosen:  ' handles.data1Choice ]);
guidata(hObject, handles);

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% Select which data2 sets to plot
choiceNumber = get(hObject,'Value');
choices = get(hObject, 'String'); % 'Current', 'Ref', 'Initial', 'SCORE', 'Home'

% handles.datasets = {'Current', 'Init', 'Ref', 'Score', 'Home'};
choiceStr = choices{choiceNumber};
switch choiceStr
    case 'Current'
        handles.data2Choice = handles.datasets{1};
    case 'Ref'
        handles.data2Choice = handles.datasets{3};
    case 'Initial'
        handles.data2Choice = handles.datasets{2};
    case 'SCORE'
        handles.data2Choice = handles.datasets{4};
    case 'Home'
        handles.data2Choice = handles.datasets{5};
end

display(['data2 data set chosen:  ' handles.data2Choice ]);
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

% elogFigure = figure;

% set(elogFigure,'Position',get(handles.figure,'Position').*[1 1 1 1]);

% copyobj(objHandles,elogFigure);
% util_printLog(elogFigure); %
objHandles = [ handles.Horizontal, handles.Vertical, handles.Roll];
saveUnits = get(objHandles,'Units');
saveFigUnits = get(handles.figure,'Units');


set(objHandles,'Units','normalized');% they are usually set to normalized for rescaling
set(handles.figure,'Units','normalized');
savePosition = get(handles.figure,'Position');
set(handles.figure,'Position',savePosition.*[1 1 .7 .9]);
util_printLog(handles.figure);
set(handles.figure,'Position',savePosition);
set(handles.figure,'Units', saveFigUnits);
%set(objHandles, 'Units',saveUnits);



% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in Quad checkbox
function checkbox1_Callback(hObject, eventdata, handles)
if  get(hObject,'Value') == get(hObject,'Max')
    handles.displayQuads = 1;
else
    handles.displayQuads = 0;
end
guidata(hObject, handles);




% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max')
    handles.displayBFWs = 1;
else
    handles.displayBFWs = 0;
end
guidata(hObject, handles);

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayBPMs = 1;
else
    handles.displayBPMs = 0;
end
guidata(hObject, handles);

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayUndulators = 1;
    display('Display Undulator ');
else
    handles.displayUndulators = 0;
end
guidata(hObject, handles);

% --- Executes on button press in Display Undulator Numbers
function checkbox8_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayUnumbers = 1;
    display('Display Undulator Translations Numbers');
else
    handles.displayUnumbers = 0;
end
guidata(hObject, handles);

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox5
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayQnumbers = 1;
else
    handles.displayQnumbers = 0;
end
guidata(hObject, handles);



% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayBFWnumbers = 1;
else
    handles.displayBFWnumbers = 0;
end
guidata(hObject, handles);


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayBPMnumbers = 1;
else
    handles.displayBPMnumbers = 0;
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6

% Executes when radio buttons in data1 panel are changed
function uipanel8_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);
hbutton = get(hObject, 'SelectedObject');
choice = get(hbutton, 'String');
switch choice
    case 'Motor'
        handles.data1Type = handles.dataTypes{1};
    case 'Linear Pot'
        handles.data1Type = handles.dataTypes{2};
    case 'Rotary Pot'
        handles.data1Type = handles.dataTypes{3};
end
display(['Data1: Use data from ' handles.data1Type]);
guidata(hObject, handles);


% Executes when radio buttons in data2 panel are changed
function uipanel9_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);
hbutton = get(hObject, 'SelectedObject');
choice = get(hbutton, 'String');
switch choice
    case 'Motor'
        handles.data2Type = handles.dataTypes{1};
    case 'Linear Pot'
        handles.data2Type = handles.dataTypes{2};
    case 'Rotary Pot'
        handles.data2Type = handles.dataTypes{3};
end
display(['Data2: Use data from ' handles.data2Type]);
guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
%
% Open Score dialogue and retrieve config motor and rpot angles, lpot readings and put in SCORE set
%
% After late March 09, LPOT and RPOT are stored as well

%[camAnglesDeg, RPOTdeg, LPOTmm, handles.scoreTime, xaoff, yaoff] = girderScore(); % open score dialogue, grab data
[camAnglesDeg, RPOTdeg, LPOTmm, handles.scoreTime, xoff, yoff] = girderScore(); % new score variables 6/29/10
set(handles.text13,'Visible','on');
set(handles.text14,'String', handles.scoreTime, 'Visible', 'on');

camAngles = pi*camAnglesDeg/180;
geo = girderGeo();
for q=1:33
    pbfw(q,:) = girderAngle2Axis(geo.bfwz, camAngles(q,:));
    pbpm(q,:) = girderAngle2Axis(geo.bpmz, camAngles(q,:));
    [pquad(q,:), r(q,1)] = girderAngle2Axis(geo.quadz, camAngles(q,:));
end
dataCam = {pbfw, pbpm, pquad, r};

RPOTangles = pi*RPOTdeg/180;
for q=1:33
    pbfw(q,:) = girderAngle2Axis(geo.bfwz, RPOTangles(q,:));
    pbpm(q,:) = girderAngle2Axis(geo.bpmz, RPOTangles(q,:));
    [pquad(q,:), r(q,1)] = girderAngle2Axis(geo.quadz, RPOTangles(q,:));
end
dataRPOT = {pbfw, pbpm, pquad, r};

% LPOT
[pbfw pbpm r] = girderLPOT2Axis([1:33], geo.bfwz, geo.bpmz, LPOTmm);
[pquad pbpm r] = girderLPOT2Axis([1:33], geo.quadz, geo.bpmz, LPOTmm);
dataLPOT = {pbfw, pbpm, pquad, r};

for k=1:length(handles.zpoints)
    handles.Score.(handles.zpoints{k}).MOTR = dataCam{k};
    handles.Score.(handles.zpoints{k}).RPOT = dataRPOT{k};
    handles.Score.(handles.zpoints{k}).LPOT = dataLPOT{k};
end
display('Loading a Score Config into handles structure')

% BPM offsets
handles.Score.X(:,1) = xoff.b(3:36);
handles.Score.Y(:,1) = yoff.b(3:36);

guidata(hObject, handles);

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
%
% Plot BPM offset numbers
%
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% 
% Plot BPM offsets
%
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayUndulators = 1;
    display('Display BPM Offsets ');
else
    handles.displayBPMoffsets = 0;
end
guidata(hObject, handles);


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
%
% Plot Girder symbols
%
if get(hObject,'Value') == get(hObject,'Max') 
    handles.displayUndulators = 1;
    display('Display Girders');
else
    handles.displayGirders = 0;
end
guidata(hObject, handles);


function axDest = util_copyAxes(ax, axDest)

if nargin < 2, axDest=gca;end

set(axDest,'box','on');
copyobj(get(ax,'Children'),axDest);
tag={'XLabel' 'YLabel' 'Title'};
h=copyobj(cell2mat(get(ax,tag)),axDest);set(axDest,tag,num2cell(h'));


