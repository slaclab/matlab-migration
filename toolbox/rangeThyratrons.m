function varargout = rangeThyratrons(varargin)
% RANGETHYRATRONS MATLAB code for rangeThyratrons.fig
%      RANGETHYRATRONS, by itself, creates a new RANGETHYRATRONS or raises the existing
%      singleton*.
%
%      H = RANGETHYRATRONS returns the handle to a new RANGETHYRATRONS or the handle to
%      the existing singleton*.
%
%      RANGETHYRATRONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANGETHYRATRONS.M with the given input arguments.
%
%      RANGETHYRATRONS('Property','Value',...) creates a new RANGETHYRATRONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rangeThyratrons_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rangeThyratrons_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rangeThyratrons

% Last Modified by GUIDE v2.5 20-Jan-2016 07:50:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rangeThyratrons_OpeningFcn, ...
                   'gui_OutputFcn',  @rangeThyratrons_OutputFcn, ...
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


% --- Executes just before rangeThyratrons is made visible.
function rangeThyratrons_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rangeThyratrons (see VARARGIN)

% Choose default command line output for rangeThyratrons
handles.output = hObject;
handles.sectorStation = {'', ''};
handles.bsaMode = 'none';

handles.plt = plot(handles.axes2,pi,pi, 'o-', nan,nan,'*-');
handles.xlabel = xlabel(' ');
handles.ylabel = ylabel(' ');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rangeThyratrons wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rangeThyratrons_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

   
        
% --- Executes on selection change in sector.
function sector_Callback(hObject, eventdata, handles)
% hObject    handle to sector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sector
contents = cellstr(get(hObject,'String'));
sector = contents{get(hObject,'Value')}; 
stationList = getStationList(sector);
set(handles.station,'String', [{'Station'},stationList], 'Value',1);

% --- Executes during object creation, after setting all properties.
function sector_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
str = strcat('LI', {'20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30'});
str = [ {'Sector'}, str];
set(hObject,'String',str);


% --- Executes on selection change in station.
function station_Callback(hObject, eventdata, handles)
set(handles.go, 'Visible','off')
stepSize = 0.0067;                                                                 
rangeSize = 0.3;
contents = cellstr(get(hObject,'String'));
if length(contents) == 1,  return, end
station = contents{get(hObject,'Value')} ;
handles.sectorStation = {station(1:4), station(6:7)};
value = lcaGetSmart(sprintf('KLYS:%s:%s:MOD:THY_RES_V', handles.sectorStation{:}));
handles.originalValue = lcaGetSmart(sprintf('KLYS:%s:%s:MOD:THY_RES_V_SET', handles.sectorStation{:}));;
set(handles.restoreValuePushbutton, 'String', sprintf('Restore to %.2f V...', handles.originalValue))
if value + rangeSize > 6.4,
    sendMessage(handles,'Reservoir Voltage cannot be larger than 6.5 V',1)
    return
end

data = get(handles.inputs, 'Data');
if ~isnan(value), 
    data{1,1} = value;  
    data{2,1} = -stepSize;
    data{3,1} = value - rangeSize/10;
    
    data{1,2} = value- rangeSize/10; 
    data{2,2} = stepSize; 
    data{3,2} = value + rangeSize;
    
    data{1,3} = value + rangeSize; 
    data{2,3} = -stepSize; 
    data{3,3} = value ;


end
set(handles.inputs, 'Data', data)
set(handles.go, 'Visible','on')
[handles.time handles.reserviorVoltageRead handles.phaseJitter handles.beamVoltsJitter ...
    handles.beamVoltsTopJitter] = deal([]);  %clear data before next scan.

guidata(hObject, handles);

function stations = getStationList(sector)
stations = meme_names('name',['KLYS:',sector, '%:MOD:THY_RES_I'])';
inhibitList = {'KLYS:LI20:81', 'KLYS:LI21:11', 'KLYS:LI24:81'};

for val = inhibitList
    stations(strncmp(stations, val, 12)) = [];
end

if ~isempty(stations)
    stations = strrep(stations, 'KLYS:', ''); 
    stations = strrep(stations, ':MOD:THY_RES_I', ''); 
    stations = strrep(stations,':', '-');
end
% --- Executes during object creation, after setting all properties.
function station_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', 'Station');


function [ok okVals] = okGoOn(handles)
        
%Check station is ON in REMOTE and with amplitude for past 2  hours.
isOn = sprintf('KLYS:%s:%s:MOD:HVON_STATE', handles.sectorStation{:});
%startChecks(2).checkPV = sprintf('KLYS:%s:%s:MOD:LOCAL_STATE', handles.sectorStation{:});
%startChecks(2).checkVal = 'REMOTE';
reservoirVoltage = sprintf('KLYS:%s:%s:MOD:THY_RES_V', handles.sectorStation{:});

stationState = lcaGetSmart(isOn);
okVals = stationState;
stationResVoltage = lcaGetSmart(reservoirVoltage);
ok =  strcmp(stationState, 'ON');
if stationResVoltage + 0.3 > 6.5
    ok = [ok 0]; okVals{2} = 'Large reservoir voltage requested'; 
else
    ok = [ok 1]; okVals{2} = 'Ok';
end



% --- Executes on button press in go.

function go_Callback(hObject, eventdata, handles) %#ok<*INUSL>
set(handles.bestValueGo, 'Visible', 'off');
allTimers = timerfindall;
if ~isempty(allTimers), stop(allTimers); delete(allTimers), end
% If user selects "End" all timers have been stopped, do nothing
if strcmp(get(hObject,'String'), 'Stop...'), 
    set(handles.pauseGo,'Visible','off')
    set(hObject,'String', 'Range It...','BackgroundColor','g')
    return, 
end
[handles.time handles.reserviorVoltageRead handles.phaseJitter handles.beamVoltsJitter ...
    handles.backswingPercent] = deal([]);
handles.scanPaused = 0;
sectorStation =handles.sectorStation;
if ~any(sectorStation{2}), warndlg('Please select Sector and Station'); return, end

[okToStart startVals] = okGoOn(handles);
if ~all(okToStart), %We start if pass
    str = sprintf('Failed OK to Start checks station state is\n%s and voltage limit is %s', startVals{:}) ;
    sendMessage(handles,str,1)
    return
end
handles.resHeaterVSet = sprintf('KLYS:%s:%s:MOD:THY_RES_V_SET', sectorStation{:});
set(hObject, 'String','Working...','BackgroundColor','r')
handles.saveData = 0; %Dont save stuff for now...
handles.scanDone = 0;

settleTime = get(handles.settleTime,'Value'); %seconds
dataTimer = timer('ExecutionMode', 'fixedRate', 'Period', 15, 'BusyMode', 'queue', 'Name', 'dataTimer');
dataTimer.TimerFcn = {@getData, handles.go};

scanTimer = timer('ExecutionMode', 'fixedRate', 'Period', settleTime , 'BusyMode', 'drop', 'Name', 'scanTimer');
scanTimer.TimerFcn = {@stepCtrl, handles.go};
scanTimer.StopFcn = {@stopScan, handles.go};
% Figure out scan range
ranges = get(handles.inputs,'Data');
range1 = ranges{1,1}:ranges{2,1}:ranges{3,1};
range2 = ranges{1,2}:ranges{2,2}:ranges{3,2};
range3 = ranges{1,3}:ranges{2,3}:ranges{3,3};
handles.reserviorVoltageSet = [range1 range2 range3];

handles.dataCounter = 0;
handles.stepCounter = 0;
handles.scanTimer = scanTimer;
handles.dataTimer = dataTimer;
guidata(hObject,handles)

start(dataTimer)
start(scanTimer)
%set(handles.message, 'String', sprintf('%s Scan Started',datestr(now)))
set(handles.pauseGo, 'Visible', 'on', 'String','Pause')
set(handles.go, 'String', 'Stop...')
sendMessage(handles.message,'Scan Started');


function stopScan(obj, event,handleObj)
handles = guidata(handleObj);
set(handles.bestValueGo, 'Visible', 'on');
guidata(handles.go,handles);
updatePlot(handles)
if handles.scanDone
   set(handles.go, 'String','Range it...','BackgroundColor','g')
   %set(handles.message,'String',sprintf('%s Scan Completed', datestr(now)))
   sendMessage(handles.message,'Scan Completed')
   set(handles.pauseGo, 'Visible', 'off')
   set(handles.go, 'Visible', 'on')
end


function stepCtrl(obj, event, handleObj)
%timer function to control reservior Voltage
handles = guidata(handleObj);
ok = okGoOn(handles);
if ~ok 
  pauseGo_Callback(handles.go, eventdata, handles)  
  warndlg('Something wrong with station: Scan Paused until user Continues');
  return
end

%if backswing percent near zero, pause. TODO:

handles.stepCounter = handles.stepCounter + 1;
guidata(handles.go, handles);

if (handles.stepCounter > length(handles.reserviorVoltageSet) )
    stop(handles.scanTimer);
    stop(handles.dataTimer);
    handles.scanDone = 1;
    guidata(handles.go, handles);
    sendMessage(handles.message,'Scan Completed')
    %set(handles.message, 'String', sprintf('%s Scan completed',datestr(now))) 
    return
end

handles.debug = 0;
if handles.debug
   if handles.stepCounter < 2, warndlg('Debug mode, no control to voltage PV'), end
else
   lcaPutSmart(handles.resHeaterVSet, handles.reserviorVoltageSet(handles.stepCounter));
end
%fprintf('\n%s %s %.2f\n',datestr(now),handles.resHeaterVSet, handles.reserviorVoltageSet(handles.stepCounter));




function getData(obj,event, handleObj)
%timer function to get the data
handles = guidata(handleObj);
handles.dataCounter = handles.dataCounter + 1;
ii = handles.dataCounter;
handles.time(ii) = now;
%handles.reserviorVoltageRead(ii)  = getVal('reserviorVoltage', handles.sectorStation);
%handles.phaseJitter(ii) = getVal('phaseJitter', handles.sectorStation );
%handles.beamVoltsJitter(ii) = getVal('beamVoltsJitter', handles.sectorStation );
handles.reserviorVoltageRead(ii) = lcaGetSmart(sprintf('KLYS:%s:%s:MOD:THY_RES_V', handles.sectorStation{:}));
handles.phaseJitter(ii) = lcaGetSmart(sprintf('KLYS:%s:%s:PHASTSREDUCED', handles.sectorStation{:}));
handles.beamVoltsJitter(ii) = lcaGetSmart(sprintf('KLYS:%s:%s:MKBVTSREDUCED', handles.sectorStation{:}));
handles.beamVoltsTopJitter(ii) = lcaGetSmart(sprintf('KLYS:%s:%s:MKBVTOPJITT', handles.sectorStation{:}));
handles.backswingPercent(ii) = lcaGetSmart(sprintf('KLYS:%s:%s:BACKSWINGPERCENT', handles.sectorStation{:}));
fprintf('\nGot data %s point %i\n',datestr(now,'HH:MM:SS' ), ii);

guidata(handles.go, handles);
updatePlot(handles)



function updatePlot(handles)
plotSelect = get(handles.plotType, 'Value');
switch plotSelect
    case 1
        xData = (handles.time-handles.time(1))*24*60;
        yData = handles.reserviorVoltageRead;
        set(handles.xlabel, 'String', sprintf( 'Minutes since %s', datestr(handles.time(1)) ))
        set(handles.ylabel, 'String', 'Reserviour Voltage (V)');
    case 2
        xData = handles.reserviorVoltageRead;
        yData = handles.phaseJitter;
        set(handles.xlabel, 'String', 'Reserviour Voltage (V)')
        set(handles.ylabel, 'String', 'Phase Jitter (deg. S)');
    case 3
        xData = handles.reserviorVoltageRead;
        yData = handles.beamVoltsJitter;
        set(handles.xlabel, 'String',  'Reserviour Voltage (V)')
        set(handles.ylabel, 'String', 'Beam Volts Jitter (ppm)');
     case 4
        xData = handles.reserviorVoltageRead;
        yData = handles.beamVoltsTopJitter;
        set(handles.xlabel, 'String',  'Reserviour Voltage (V)')
        set(handles.ylabel, 'String', 'Beam Volts "Top" Jitter (ppm)');
     case 5
        xData = handles.reserviorVoltageRead;
        yData = handles.backswingPercent;
        set(handles.xlabel, 'String',  'Reserviour Voltage (V)')
        set(handles.ylabel, 'String', 'Beam Volts Backswing percent (%)');   
end
set(handles.plt(1),'XData',xData, 'YData', yData)

if (handles.scanDone || handles.scanPaused) && plotSelect ~= 1
[par, yFit, parstd] = util_polyFit(xData, yData,2);

set(handles.plt(2), 'XData',xData, 'YData', yFit);
handles.bestValue = abs(roots(par)); 
set(handles.message, 'String', sprintf('%s Best value from fit: %.1f Volts',datestr(now,'HH:MM:SS'), handles.bestValue(2)))
guidata(handles.go, handles);
else
   set(handles.plt(2), 'XData',nan, 'YData', nan); 
end

%function [value ok valVector] = getVal(valName, sectorStation, eDefS, measCnt, bsaFlag)
% %gets given value for given station
% beamCode = 'A'; %or 'A' for any
% jitPV = ''; getPV = '';
% timeNow =  now;
% switch valName
%     case 'phaseJitter', 
%         getPV = sprintf('KLYS:%s:%s:PJTN', sectorStation{:});
%             
%     case 'beamVoltsJitter', 
%         getPV = sprintf('KLYS:%s:%s:MKBVFTPJASIGMA', sectorStation{:});
%         jitPV = sprintf('KLYS:%s:%s:MKBVFTPJ%sPROC', sectorStation{:}, beamCode);
%     case 'reserviorVoltage', getPV = sprintf('KLYS:%s:%s:MOD:THY_RES_V',sectorStation{:});
%     case 'backSwing',
%         getPV = '';
%         startPV = sprintf('KLYS:%s:%s:MKBVBSFTPSTARTTIME',sectorStation{:});
%         ftpStart = lcaGetSmart(startPV);
%         ftpStep = 0;nFTP =1; inus = 1;
%      
%         [xVals, val] = piopFTP(sectorStation{1}, sectorStation{2}, ftpStart, ftpStep, nFTP, inus);
%         value = std(val);
%         valVector = val; ok = 1;
%     case 'beamVoltsBsa'
% %         eDefOn(eDefN)
% %         done = 0;
% %         while ~done
% %             done = eDefDone(eDefN); pause(0.1);
% %         end
%         pv = sprintf('KLYS:%s:%s:%s_FASTHST%s', sectorStation{:}, bsaFlag, eDefS);
%         val =  lcaGet(pv);
%         %just return rms for now
%         value = std(val(end-measCnt:end));
% end
% if any(jitPV) %if requesting a jitter value, trigger FTP and wait before getting value.
%     lcaPutSmart(jitPV, 1); 
%     statPV = strrep(jitPV, 'PROC', '');
%     tic
%     while 1
%         statVal = lcaGetSmart(statPV);
%         if strcmp(statVal, 'Completed successfully') || (toc > 10), break,end
%     end
% end
% if any(getPV)
%     [value , ~, ok] = lcaGetSmart(getPV);
%     if ~ok, warndlg('Failed to get %s value for %s',getPV, valName); end



% --- Executes during object creation, after setting all properties.
function inputs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'RowName', {'Start','Step', 'End'})
set(hObject,'ColumnName', {'Range 1' 'Range 2' 'Range 3'})
set(hObject,'Data', {''; ''; '';''; ''; '';''; ''; ''});
function settleTime_Callback(hObject, eventdata, handles)
% hObject    handle to settleTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of settleTime as text
%        str2double(get(hObject,'String')) returns contents of settleTime as a double
settleTime = get(hObject,'String');
set(hObject,'Value', str2num(settleTime));
% --- Executes during object creation, after setting all properties.
function settleTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to settleTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settleTime = 60;
set(hObject,'String', num2str(settleTime),'Value', settleTime);
% --- Executes when entered data in editable cell(s) in inputs.
function inputs_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to inputs (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on selection change in bsa.

function bsa_Callback(hObject, eventdata, handles)
% hObject    handle to bsa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bsa contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bsa
val = get(hObject,'Value');
bsaModes = {'none', 'PHAS', 'BVLT'};
handles.bsaMode = bsaModes{val};
%Freeze Fox phase shifter if BSA mode
if ~strncmp(handles.bsaMode, 'none',4), 
    handles.foxFreeze{1} = sprintf('KLYS:%s:%s:KPHR.DISP',handles.sectorStation{:});
    handles.foxFreeze{2} = lcaGetSmart(pvStr);
    lcaPutSmart(handles.foxFreeze{1}, 1); %Fox Freeze
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function bsa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bsa (see GCBO)
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

% Hints: contents = cellstr(get(hObject,'String')) returns plotType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotType
updatePlot(handles)
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
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes2
% --- Executes on button press in pauseGo.
function pauseGo_Callback(hObject, eventdata, handles)
% hObject    handle to pauseGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pauseGo
pause(0.1)
set(hObject, 'Value', 0);
str = get(hObject,'String');
switch str
    case 'Pause'
        handles.scanPaused = 1; guidata(hObject,handles);
        %set(handles.bestValueGo, 'Visible', 'on');
    case 'Continue'
        handles.scanPaused = 0; guidata(hObject,handles);
        set(handles.plt(2),'XData', nan, 'YData',nan);
        %set(handles.go, 'Visible', 'off');
        set(handles.bestValueGo, 'Visible', 'off');

end
sendMessage( handles.message, sprintf('Scan state is: %s', str))        
%set(handles.message, 'String', sprintf('%s Scan state is: %s',datestr(now), str));

switch str
    case 'Pause'
        set(hObject, 'String', 'Continue')
        stop(handles.scanTimer);
        stop(handles.dataTimer);
        
    case 'Continue'
        set(hObject, 'String', 'Pause')
        start(handles.dataTimer);
        start(handles.scanTimer);

end


% --- Executes on button press in printIt.
function printIt_Callback(hObject, eventdata, handles)
% hObject    handle to printIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of printIt
if handles.saveData
    saveData.phaseJitter = handles.phaseJitter;
    saveData.beamVoltsJitter = handles.beamVoltsJitter;
    saveData.time = handles.time;
    saveData.reserviorVoltageRead = handles.reserviorVoltageRead;
    [fileName, pathName] = util_dataSave(saveData,'Range_Thyratron', handles.resHeaterVSet, handles.time(1));
    handles.saveData = 0;
end

plotSelect = get(handles.plotType, 'Value');
figH = figure;ax = axes;
try
switch plotSelect
    case 1
        plot(ax, (handles.time-handles.time(1))*24*60, handles.reserviorVoltageRead, '-o')
        xlabel(sprintf( 'Minutes since %s', datestr(handles.time(1)) ))
        ylabel('Reserviour Voltage (V)');
    case 2
        plot(ax,handles.reserviorVoltageRead, handles.phaseJitter, '-o');
        xlabel('Reserviour Voltage (V)');
        ylabel('Phase Jitter (deg. S)');
    case 3
        plot(ax,handles.reserviorVoltageRead, handles.beamVoltsJitter, '-o');
        xlabel( 'Reserviour Voltage (V)')
        ylabel('Beam Volts Jitter (ppm)');
    case 4
        plot(ax,handles.reserviorVoltageRead, handles.beamVoltsTopJitter, '-o');
        xlabel( 'Reserviour Voltage (V)');
        ylabel('Beam Volts "Top" Jitter (ppm)');
    case 5
        plot(ax,handles.reserviorVoltageRead, handles.backswingPercent, '-o');
        xlabel( 'Reserviour Voltage (V)');
        ylabel('Beam Volts Backswing percent (%)'); 
end
title(['Range Thyratron ', handles.resHeaterVSet(1:12)], 'Interpreter','none')


util_printLog_wComments(figH, 'Range Thyratron GUI', handles.resHeaterVSet(1:12), ' ')

catch
    keyboard
end
guidata(hObject,handles)
     
% --- Executes on button press in bestValueGo.
function bestValueGo_Callback(hObject, eventdata, handles)
% hObject    handle to bestValueGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotSelect = get(handles.plotType, 'Value');
if plotSelect ==1
        warndlg('Please select a different plot before accepting best value');
        return
end
bestValue = handles.bestValue(2);
set(handles.go,'Visible','on')

answer = inputdlg('Accept best value',handles.resHeaterVSet(1:12),1,{sprintf('%.2f',bestValue)} );

if isempty(answer), return, end
answerN = str2double(answer{:});

%isok = lcaPutSmart(handles.resHeaterVSet, answerN);
startVal = lcaGetSmart(handles.resHeaterVSet);
isok = rampReservoirVoltage(handles,handles.resHeaterVSet,startVal, answerN)

if isok
    str = sprintf('Updated %s to %.2f\n',handles.resHeaterVSet, answerN);
    sendMessage(handles.message, str)
else
    sendMessage(handles.message,['Failed to write to ', handles.resHeaterVSet],1)
end
    
    
function sendMessage(h,str,isdlg)
% h is handle where text string is going
%write message to gui and history file
% isdlg =1 if imput dlg also requested
if nargin <3, isdlg = 0; end
strOut = sprintf('%s %s', datestr(now, 'HH:MM:SS'),str);
if isstruct(h)
set(h.message, 'String', strOut);
else
    set(h, 'String', strOut);
end

fprintf('%s\n',strOut);
if isdlg
    warndlg(str)
end
        
        
        


% --- Executes on button press in restoreValuePushbutton.
function restoreValuePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to restoreValuePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
controlPV = sprintf('KLYS:%s:%s:MOD:THY_RES_V_SET', handles.sectorStation{:});
valNow = lcaGetSmart(controlPV);
set(hObject,'String', 'Ramping back...')
rampReservoirVoltage(handles,controlPV, valNow, handles.originalValue);
set(hObject,'String', 'Done...')



function isok = rampReservoirVoltage(handles, controlPV,startVal, endVal)
nPts = ceil(abs(startVal - endVal)/0.0065);
ramp = linspace(startVal,endVal,nPts);
stnStr = [controlPV(6:9) '-' controlPV(12)];
startStr = sprintf('Starting ramp %s from %.2f to %.2f',stnStr,  startVal, endVal);
sendMessage(handles.message,startStr,0)

for v = ramp, 
    lcaPutSmart(controlPV, v) 
    pause(60);
end
sendMessage(handles.message, ['Ramp of ' stnStr  ' ended.'], 0)
logFileStr = sprintf('%s Ranged %s from %.2f to %.2f Volts\n', ...
   datestr(now,'mm/dd/yyyy HH:MM'),  stnStr, startVal, endVal);
system(['echo "' logFileStr '" >>   /u1/lcls/physics/data/thyratronRangeLogs/thyratronRangeLog']);
isok = 1;
