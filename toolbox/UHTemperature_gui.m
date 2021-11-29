function varargout = UHTemperature_gui(varargin)
% UHTEMPERATURE_GUI M-file for UHTemperature_gui.fig
%      UHTEMPERATURE_GUI, by itself, creates a new UHTEMPERATURE_GUI or raises the existing
%      singleton*.
%
%      H = UHTEMPERATURE_GUI returns the handle to a new UHTEMPERATURE_GUI or the handle to
%      the existing singleton*.
%
%      UHTEMPERATURE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UHTEMPERATURE_GUI.M with the given input arguments.
%
%      UHTEMPERATURE_GUI('Property','Value',...) creates a new UHTEMPERATURE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UHTemperature_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UHTemperature_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UHTemperature_gui

% Last Modified by GUIDE v2.5 02-Oct-2008 15:20:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UHTemperature_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UHTemperature_gui_OutputFcn, ...
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


% --- Executes just before UHTemperature_gui is made visible.
function UHTemperature_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure

handles.output = hObject;
segPrefix = 'USEG:UND1:';
RTDprefix = ':RTD';
for p=1:33
    handles.segmentNames{p} = [segPrefix  num2str(p) '50'];
end

for p=1:12
    if p<10
        RTDnames{p} = [RTDprefix '0' num2str(p)];
    else
        RTDnames{p} = [RTDprefix num2str(p)];
    end
end

handles.RTDnames = RTDnames;

%
% RTDnames = {
%     'RTD 01'
%     'RTD 02'
%     'RTD 03'
%     'RTD 04'
%     'RTD 05'
%     'RTD 06'
%     'RTD 07'
%     'RTD 08'
%     'RTD 09'
%     'RTD 10'
%     'RTD 11'
%     'RTD 12'
%     };



%Set up temperature monitoring choices for profile plots
handles.monitorChoices = {
    'All RTDs'
    'Girder Ave' 
    'Pedestal Ave' 
    'Quad Ave'
    'Segment Ave'
    'Motor Ave'
    '1 Pedestal US Top'
    '2 Girder US Top'
    '3 Segment US'
    '4 Translation Motor US'
    '5 Pedestal DS Top'
    '6 Segment Middle'
    '7 Inteface Plate DS'
    '8 Quad Base'
    '9 Segment DS'
    '10 Quad Top'
    '11 Girder DS Top'
    '12 Translation Motor DS'
    };

handles.currentSegment = 27; %for time variation plots
handles.currentMonitor = 5; %default is Segment Average
handles.RTDlist = [3 6 9]; % default list to include in profile plots
handles.currentPVS = 'USEG:UND1:2750:RTD07';
handles.currentRTD = 1; %default RTD number for time plots
handles.profileAxisHold = 'off';%hold toggle
handles.zscale = 'segment numbers'; % 'meters' is the other choice

% Update handles structure
guidata(hObject, handles);
set(handles.popupmenu1,'Value',handles.currentMonitor);
set(handles.popupmenu1,'String',handles.monitorChoices);
set(handles.popupmenu2,'Value',27);
set(handles.popupmenu2,'String',handles.segmentNames);
set(handles.popupmenu3,'Value',1);
set(handles.popupmenu3,'String',RTDnames);

%put output in gui axes
axes(handles.profileAxis);
[Tave, Tmin, Tmax, z, time] = UHtemperatureProfile(handles);
title([ handles.monitorChoices{handles.currentMonitor} '     ' datestr(now) ]);
handles.Tave = Tave;
handles.Tmin = Tmin;
handles.Tmax = Tmax;
handles.z = z;
handles.time = time;
handles.currentProfile = {Tave Tmin Tmax z time};

%get archived temperature data for last day (default)
startTime = now - 1; %for now just get the last weeks data
[Thist, times ] = plotHistorical(hObject, handles, startTime);
handles.currentTimeVariation = {Thist times};
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = UHTemperature_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%
% Regular functions (not callbacks)
%

function [Thist, times] = plotHistorical(hObject, handles, startTime)
%plot value of currently selected segment and RTD from archived data
stopTime = now;

pvString = [handles.segmentNames{handles.currentSegment} handles.RTDnames{handles.currentRTD}];

pvs = pvString; %done constructing pvs, now get time data
handles.currentPVS = pvs;
[Thist, times] = get_archive(pvs,datestr(startTime,0),datestr(stopTime,0),0);
times = datenum(times)-now;

axes(handles.timeVariationAxis);% put output in timeVariation axes
ylim([19 23]);
hold on %necessary to make ylim work!!!
plot(times,Thist);
xlabel('Time [days]  (0 is now)');
title( [pvs '     ' datestr(now) ] );

hold off;
guidata(hObject, handles);
%
% Callback functions below
%


% --- Executes on button press in pushbutton1.
function Refresh_Callback(hObject, eventdata, handles)
axes(handles.profileAxis);
if strcmp(handles.profileAxisHold,'on');
    hold on;
else
    hold off;
    cla;
end
[Tave, Tmin, Tmax, z, time] = UHtemperatureProfile(handles);
title([ handles.monitorChoices{handles.currentMonitor} '     ' datestr(now) ]);
segmentNumbers =  find(Tave);
display('  ');%blank line
display('      Tave      Tmin      Tmax    Segment    z ');
disp([Tave' Tmin' Tmax'  segmentNumbers' z']);
handles.currentProfile = {Tave Tmin Tmax z time};
guidata(hObject, handles);


function LastDay_Callback(hObject, eventdata, handles)
%plot last 24 hour temperatures
axes(handles.timeVariationAxis);
cla;
startTime = now-1;
[Thist, times] = plotHistorical(hObject, handles, startTime);
handles.currentTimeVariation{1} = Thist;
handles.currentTimeVariation{2} = times;
guidata(hObject, handles);

function LastWeek_Callback(hObject, eventdata, handles)
%plot last weeks temperatures
axes(handles.timeVariationAxis);
cla;
startTime = now-7;
[Thist, times] = plotHistorical(hObject, handles, startTime);
handles.currentTimeVariation{1} = Thist;
handles.currentTimeVariation{2} = times;
guidata(hObject, handles);
% --- Executes on button press in pushbutton5.
function LastMonth_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.timeVariationAxis);
cla;
startTime = now-30;
[Thist, times] = plotHistorical(hObject, handles, startTime);
handles.currentTimeVariation{1} = Thist;
handles.currentTimeVariation{2} = times;
guidata(hObject, handles);
% --- Executes on button press in togglebutton1.

function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_state = get(hObject,'Value');
axes(handles.profileAxis);%make profile the current axis
if button_state == get(hObject,'Max')
    % Toggle button is pressed-take approperiate action
    UHtemperatureHistory();
elseif button_state == get(hObject,'Min')
    % Toggle button is not pressed-take appropriate action
    cla;
    [Tave, Tmin, Tmax, z, time] = UHtemperatureProfile();
end

% Hint: get(hObject,'Value') returns toggle state of togglebutton1



% --- Executes on PLT button press in TimeVariation.
function TimeVariation_Callback(hObject, eventdata, handles)

figure % new figure for printing etc.
Thist = handles.currentTimeVariation{1};
times = handles.currentTimeVariation{2};
% if handles.currentRTD < 10
%     str2 = ['0' num2str(handles.currentRTD)];
% else
%     str2 = num2str(handles.currentRTD);
% end
%pvs = [ 'U' num2str(handles.currentSegment) ':T' str2]
pvs = [handles.segmentNames(handles.currentSegment) handles.RTDnames(handles.currentRTD)];

ylim([19 21]);
hold on %necessary to make ylim work!!!
plot(times,Thist);
xlabel('Time [days]  (0 is now)');
ylabel('RTD Temperatures [C]');
title( ['RTD '  pvs '     ' datestr(now)] )



% --- Executes on button press in PlotProfile.
function PlotProfile_Callback(hObject, eventdata, handles)
figure; %create new figure for printing etc.
%axes(handles.profileAxis);
Tave  = handles.currentProfile{1};
Tmin = handles.currentProfile{2};
Tmax = handles.currentProfile{3};
z    = handles.currentProfile{4};

hold on
plot(z,Tave,'Color',[0 .5 .5],'Linewidth',3);
plot(z,Tmin,'--k',z,Tmax,'--k');
xlabel('Position [m]');
ylabel('RTD Temperature [C]');

if strcmp(handles.zscale, 'meters')
    xlabel('Position [m]');
    xlim([512,682]);
else
    xlabel('Segment Number');
    xlim([0,35]);
end
legend('Average','Min/Max');
title([ handles.monitorChoices{handles.currentMonitor} '     ' datestr(now) ]);



% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
button_state = get(hObject,'Value');

if button_state == get(hObject,'Max')
    % Toggle button is pressed-take approperiate action
   handles.profileAxisHold = 'on';
elseif button_state == get(hObject,'Min')
    % Toggle button is not pressed-take appropriate action
   handles.profileAxisHold = 'off';
end
guidata(hObject, handles);

function popupmenu1_Callback(hObject, eventdata, handles)
handles.currentMonitor = get(hObject,'Value');
switch handles.currentMonitor
    case 1 %All RTDs
        handles.RTDlist = [1 2 3 4 5 6 7 8 9 10 11 12];
    case 2 %Girder Average
        handles.RTDlist = [2  11];
    case 3 %Pedestal Average
        handles.RTDlist = [1 5];
    case 4 %Quad Average
        handles.RTDlist = [8 10];
    case 5 %Undulator Segment Average
        handles.RTDlist = [3 6 9];
    case 6 %Motor Average
        handles.RTDlist = [4 12];
    case 7 %RPedestal Top US
        handles.RTDlist = [1];
    case 8 % Girder US Top
        handles.RTDlist = [2];
    case 9 % Segment US
        handles.RTDlist = [3];
    case 10 %US Translation Motor
        handles.RTDlist = [4];
    case 11 %DS Pedestal
        handles.RTDlist = [5];
    case 12 %Segment Middle
        handles.RTDlist = [6];
    case 13 %DS Interface Plate
        handles.RTDlist = [7];
    case 14 % Quad base
        handles.RTDlist = [8];
    case 15 % Segment DS
        handles.RTDlist = [9];
    case 16 % Quad Top
        handles.RTDlist = [10];
    case 17 % Girder DS Top
        handles.RTDlist = [11];
    case 18 % Translation Motor DS
        handles.RTDlist = [12];
end

guidata(hObject, handles);

Refresh_Callback(hObject, eventdata, handles)

    

function popupmenu1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
handles.currentSegment = get(hObject,'Value');
guidata(hObject, handles);


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


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
handles.currentRTD = get(hObject,'Value');
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

function [Tave, Tmin, Tmax, z, time] = UHtemperatureProfile(handles)
%
% [Tave, Tmin, Tmax, z, time] = UHtemperatureProfile(RTDlist)
%
% For specified RTDs, return ave, min, and max temps for each segment. Plot
% results in current axes and save them in historical file.
%
% Default is all RTDs per segment.
% RTDlist is numerical array e.g. [1 2 4 5]

RTDlist = handles.RTDlist;

if nargin == 0 %default if no argument is supplied
    RTDlist = [1 2 3 4 5 6 7 8 9 10 11 12];
end

%Construct pv names
SegmentNames = {'U01', 'U02','U03', 'U04','U05','U06','U07','U08','U09','U10',...
                'U11', 'U12','U13', 'U14','U15','U16','U17','U18','U19','U20',...
                'U21', 'U22','U23', 'U24','U25','U26','U27','U28','U29','U30',...
                'U31', 'U32','U33'};%use all 19-25 are installed 9/23/08
            

statusMask(1:33) = 1; %these are segment with working RTDs
if strcmp(handles.zscale, 'meters')
z =  [...         
  518.8000
  522.7000
  526.6000
  530.8000
  534.7000
  538.6000
  542.9000
  546.8000
  550.6000
  554.9000
  558.8000
  562.7000
  567.0000
  570.8000
  574.7000
  579.0000
  582.9000
  586.7000
  591.0000
  594.9000
  598.8000
  603.1000
  606.9000
  610.8000
  615.1000
  619.0000
  622.9000
  627.2000
  631.0000
  634.9000
  639.2000
  643.1000
  646.9000];
else
    z = 1:33;
end


numberOfSegments = length(SegmentNames);


numberOfRTDs = length(RTDlist); %number of RTDs per segment

for sIndex = 1:numberOfSegments
    segment(sIndex).name = SegmentNames{sIndex};
end

pvs = cell(numberOfRTDs,1);% cell array for lcaGet
%Get the data
for sIndex=1:numberOfSegments

    for RTD=1:numberOfRTDs
        if RTDlist(RTD) < 10
            pvString = [segment(sIndex).name ':T0' num2str(RTDlist(RTD))];
        else
            pvString = [segment(sIndex).name ':T'  num2str(RTDlist(RTD))];
        end
        pvs{RTD} = pvString;
    end
  %  display(pvs)
    
  if (statusMask(sIndex)==1)
    [segment(sIndex).temperatures, ts] = mlcaGetSmart(pvs);
  else
    segment(sIndex).temperatures = NaN ;%dont waste time with mlcaGet
  end
    segment(sIndex).meanTemperature = mean(segment(sIndex).temperatures);
    segment(sIndex).maxTemperature = max(segment(sIndex).temperatures);
    segment(sIndex).minTemperature = min(segment(sIndex).temperatures);
end


%return data
Tave = [segment.meanTemperature];
Tmin = [segment.minTemperature];
Tmax = [segment.maxTemperature];
time = now;
tunnelAverage = mean(Tave);

%plot results
hold on
plot(z,Tave,'Color',[0 .5 .5],'Linewidth',3);
plot(z,Tmin,'--k',z,Tmax,'--k');
if strcmp(handles.zscale, 'meters')
    xlabel('Position [m]');
    xlim([512,682]);
else
    xlabel('Segment Number');
    xlim([0,35]);
end

ylabel('RTD Temperature [C]');
if handles.currentMonitor==5
    ylim([19,21])
else
    ylim([19, 23])
end

legend('Average','Min/Max','Location', 'NorthWest');
title( ['Undulator Hall '   datestr(now)] );
display(['Overall average ' num2str(tunnelAverage) ' [C]'])

%append the temperature profile data to a file if all RTDs is chosen
if length(RTDlist) == 12;%all RTDs are requested
    path_name=([getenv('MATLABDATAFILES') '/undulator/UH']);
    filename = '/UHtemperatureProfile.dat';
    filename = [path_name filename];
    display(['Temperature data appended to' filename]);
    fid = fopen(filename,'a');
    count = fprintf(fid,'% 5.3f',[Tave Tmin Tmax ]);
    count = fprintf(fid,'% 5.3f\n', time);
    fclose(fid);
end

%return profile

