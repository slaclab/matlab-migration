function varargout = fbOrbitGUI(varargin)
% FBORBITGUI M-file for fbOrbitGUI.fig
%      FBORBITGUI by itself, creates a new FBORBITGUI or raises the
%      existing singleton*.
%
%      H = FBORBITGUI returns the handle to a new FBORBITGUI or the handle to
%      the existing singleton*.
%
%      FBORBITGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBORBITGUI.M with the given input arguments.
%
%      FBORBITGUI('Property','Value',...) creates a new FBORBITGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbOrbitGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbOrbitGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbOrbitGUI

% Last Modified by GUIDE v2.5 28-Jul-2009 14:56:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbOrbitGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @fbOrbitGUI_OutputFcn, ...
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

% --- Executes just before fbOrbitGUI is made visible.
function fbOrbitGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbOrbitGUI (see VARARGIN)

% Choose default command line output for fbOrbitGUI
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

navg = str2num(get(handles.numEdit, 'String'));
beamrate = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
set(handles.beamrateTxt, 'String', ['The current Beam Rate is ' num2str(beamrate) ' Hz.']);
if beamrate<=0
   set(handles.infoTxt, 'String', 'You cannot collect a reference orbit now, there is no beam.');
   set(handles.collectBtn, 'Enable', 'off');
else
   delay_sec = navg/beamrate + 10;
   if delay_sec>60 
      delay_min=delay_sec/60;
      set(handles.infoTxt, 'String', ['This can take up to ' num2str(delay_min) ' minutes to collect.']);
   else
      set(handles.infoTxt, 'String', ['This can take up to ' num2str(delay_sec) ' seconds to collect.']);
   end
end

% Make the GUI modal
set(handles.orbitFig,'WindowStyle','modal')
config = getappdata(0,'Config_structure');
set(handles.uipanel1, 'Title', ['Orbit Collection: ' config.feedbackName]);
% UIWAIT makes fbOrbitGUI wait for user response (see UIRESUME)
uiwait(handles.orbitFig);

% --- Outputs from this function are returned to the command line.
function varargout = fbOrbitGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.orbitFig);


% --- Executes when user attempts to close orbitFig.
function orbitFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to orbitFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.orbitFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.orbitFig);
else
    % The GUI is no longer waiting, just close it
    delete(handles.orbitFig);
end



function secondsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to secondsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of secondsEdit as text
%        str2double(get(hObject,'String')) returns contents of secondsEdit as a double


% --- Executes during object creation, after setting all properties.
function secondsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secondsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in collectBtn.
function collectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to collectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of refOrbitBtn
config = getappdata(0,'Config_structure');

%get the number of measurements to average and the timeout
refData.max = str2double(get(handles.numEdit, 'String'));

navg = str2num(get(handles.numEdit, 'String'));
beamrate = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
timeout = navg/beamrate + 10;

% disable the collect button and show the Collecting strings
set(handles.collectBtn, 'Enable', 'off');
set(handles.collectTxt, 'Visible', 'on');


% get the actuator values for this ref orbit
actvals = [];
try
   actvals = lcaGet(config.act.allactPVs);
catch
   dbstack;
   h = errordlg('Could not read actuator PVs');
   waitfor(h);
   fbLogMsg(['Could not read actuator PVs, ' config.feedbackName ' quitting']);
   %rethrow(lasterror);
end

%now get the measurements and average them
% Define e-def
eDefNumber = eDefReserve('collect_orbit');
if eDefNumber<=0
   h = errordlg('Could not get an EDEF, quitting');
   waitfor(h);
   fbLogMsg(['Could not get an EDEF, Regold ' config.feedbackName ' quitting']);
end
eDefParams(eDefNumber, refData.max, 1,...
    {''}, {''}, {''}, {''});
%remove the old eDef name from the meas pvs
measPVs = config.meas.allmeasPVs;
if ~isempty(strfind(config.meas.allmeasPVs{1,1}, 'F1'))
   measPVs = regexprep(config.meas.allmeasPVs, 'F1', '', 1);
end
if ~isempty(strfind(config.meas.allmeasPVs{1,1}, 'F2'))
   measPVs = regexprep(config.meas.allmeasPVs, 'F2', '', 1);
end
if ~isempty(strfind(config.meas.allmeasPVs{1,1}, 'BR'))
   measPVs = regexprep(config.meas.allmeasPVs, 'BR', '', 1);
end
if ~isempty(strfind(config.meas.allmeasPVs{1,1}, 'TH'))
   measPVs = regexprep(config.meas.allmeasPVs, 'TH', '', 1);
end
if ~isempty(strfind(config.meas.allmeasPVs{1,1}, '1H'))
   measPVs = regexprep(config.meas.allmeasPVs, '1H', '', 1);
end
% now add the new eDef name
pvs = fbAddToPVNames(measPVs, num2str(eDefNumber));

% run eDef, get data
result.acqTime = eDefAcq(eDefNumber, timeout);
data = [];

try
   data = lcaGet(pvs);
catch
   dbstack;
   h = errordlg('Could not read measurement PVs');
   waitfor(h);
   fbLogMsg(['Could not read measurement PVs, ' config.feedbackName ' quitting']);
   %rethrow(lasterror);
end
refData.count = refData.max;
refData.data = data;
refData.actvals = actvals;

if (any(data))
   actvals = cellstr(num2str(refData.actvals));
   data = cellstr(num2str(refData.data));

   %prompt user to edit actuator values
   prompt = config.act.allactPVs;
   dlg_title = 'Review Actuator values:';
   num_lines = 1;
   new  = str2num(char(inputdlg(prompt,dlg_title,num_lines, actvals)));
   if any(new)
      refData.actvals = new;
   end
   %now get the measurement values
   %prompt user to edit  values
   prompt = config.meas.allmeasPVs;
   dlg_title = 'Reference Orbit: Measurements';
   num_lines = 1;
   new = str2num(char(inputdlg(prompt,dlg_title,num_lines, data)));
   if any(new)
      refData.data = new;
      refData.count = 1;
   end
   % get a filename for the reference orbit file
   prompt = {'If you wish to keep and use this reference, enter a name for the reference orbit MAT file'};
   dlg_title = 'Reference Orbit filename';
   num_lines = 1;
   def = {'reforbit.mat'};
   filename = inputdlg(prompt, dlg_title, num_lines,def);

   %now save the data to file, and store in config struct
   if ~isempty(filename)
      temp.refData = refData;
      file = sprintf ('%s/Feedback/data/%s%s/%s', ...
         getenv('MATLABDATAFILES'), config.feedbackAcro, config.feedbackNum, filename{1}); 
      save(file, '-struct', 'temp');
      config.reforbitName = filename{1};
      config.refInit = 1;
      config.refData = refData;
      %config.act.limits = fbCalcNewActLimits(config.refData.actvals, config.act.limits);
      config.configchanged = 1;
      setappdata(0, 'Config_structure', config);
      %fbSoftIOCFcn('PutActInfo',config.act);
      try
         % write the actuator values to the restore storage place
         rstrNames = fbAddToPVNames(config.act.allstorePVs, 'RSTR');
         lcaPut(rstrNames, config.refData.actvals);
      catch
         dbstack;
         fbLogMsg(['Could not write act ref PVs, ' config.feedbackName ' quitting']);
         %rethrow(lasterror);
      end     
   else
      h = errordlg('No filename entered; Reference orbit will be deleted.');
      waitfor(h);
   end
else
   h = errordlg('No data collected; no reference orbit saved!');
   waitfor(h);
end

eDefRelease(eDefNumber);
% enable the collect button and remove the Collecting strings
set(handles.collectBtn, 'Enable', 'on');
set(handles.collectTxt, 'Visible', 'off');
set(handles.infoTxt, 'Visible', 'off');

uiresume(handles.orbitFig);





function numEdit_Callback(hObject, eventdata, handles)
% hObject    handle to numEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numEdit as text
%        str2double(get(hObject,'String')) returns contents of numEdit as a double
numAvg=str2num(get(hObject, 'String'));
beamrate = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
set(handles.beamrateTxt, 'String', ['The current Beam Rate is ' num2str(beamrate) ' Hz.']);
if beamrate <= 0
   set(handles.infoTxt, 'String', 'You cannot collect a reference orbit now, there is no beam.');
   set(handles.collectBtn, 'Enable', 'off');
else
   delay_sec = numAvg/beamrate;
   if delay_sec>60 
      delay_min=delay_sec/60;
      set(handles.infoTxt, 'String', ['This can take up to ' num2str(delay_min) ' minutes to collect.']);
   else
      set(handles.infoTxt, 'String', ['This can take up to ' num2str(delay_sec) ' seconds to collect.']);
   end
end
   


% --- Executes during object creation, after setting all properties.
function numEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function orbitFig_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to orbitFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


