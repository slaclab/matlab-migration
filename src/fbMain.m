function varargout = fbMain(varargin)
% FBMAIN M-file for fbMain.fig
%      FBMAIN, by itself, creates a new FBMAIN or raises the existing
%      singleton*.
%
%      H = FBMAIN returns the handle to a new FBMAIN or the handle to
%      the existing singleton*.
%
%      FBMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBMAIN.M with the given input arguments.
%
%      FBMAIN('Property','Value',...) creates a new FBMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbMain_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbMain

% Last Modified by GUIDE v2.5 17-Sep-2007 13:55:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbMain_OpeningFcn, ...
                   'gui_OutputFcn',  @fbMain_OutputFcn, ...
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


% --- Executes just before fbMain is made visible.
function fbMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbMain (see VARARGIN)

% Choose default command line output for fbMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set the feedback name
config = getappdata(0, 'Config_structure');
set(handles.fbckPanel, 'Title', config.feedbackName);

% fill in the list boxes
if ~isempty(config.act.allactPVs)
    setactList(handles, config);
else
    set(handles.actMenu, 'Enable', 'off');
end
if ~isempty(config.meas.allmeasPVs)
    setmeasList(handles, config);
else
    set(handles.measMenu, 'Enable', 'off');
end
if ~isempty(config.states.allstatePVs)
    setstateList(handles, config);
else
    set(handles.stateMenu, 'Enable', 'off');
end
if isempty(config.matrix.f) && isempty(config.matrix.g) 
   if strcmp(config.matrix.fFcnName,'0') && strcmp(config.matrix.gFcnName,'0')
    set(handles.matrixMenu, 'Enable', 'off');
   end
end

%check the check PVs
tryOtherPVs(config);

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes fbMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fbMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -------------------- SOME GUI UTILITY FUNCTIONS --------------------

% --------------------------function-------------------------------------
function setstateList(handles, c)
% --- redraw the finalActuatorList box 
% handles  the BUI handles data structure

try
    % Get engineering units
    % If MDL fbck or lcaGet fails, set units to ' '
   eguNames = fbAddToPVNames(c.states.allstatePVs, '.EGU');
   for i = 1:length(eguNames)
       if strcmp(c.feedbackAcro,'MDL')
           units(i) = {' '};
       else
           try
               units(i) = lcaGet(eguNames(i));
           catch
               units(i) = {' '};
           end
       end
   end

   %display STATUS of state pvs
   [sevrStrs, sevr] = fbGetSevrString(c.states.allstatePVs);
   if any(sevr) 
      set(handles.stateList, 'ForegroundColor', 'red');
   else
      set(handles.stateList, 'ForegroundColor', 'black');
   end
catch
   dbstack;
   h = errordlg('Could not read sioc-sys0-fb00 State PVs, quitting.');
   waitfor(h);
   fbLogMsg(['Could not read sioc-sys-fb00 State PVs, ' c.feedbackName ' quitting']);
   rethrow(lasterror);
end

% create the states PV + limits list
sppluslimits = [];
if ~isempty(c.states.PVs)
   s=0;
   for i=1:length(c.states.PVs)
      if c.states.PVs(i)==1
         s = s+1;
         if (sevr(i)>0)
            sppluslimits{s} = strcat(c.states.names{i,1},...
            '   setpoint:', num2str(c.states.SPs(i)), ...
            '   low:', num2str(c.states.limits.low(i)), ...
            '   high:', num2str(c.states.limits.high(i)),' (',char(units(i)),')   alarm status: ',sevrStrs{i,1});
         else
            sppluslimits{s} = strcat( char(c.states.names(i)), ...
            '   setpoint:',  num2str(c.states.SPs(i)), ...
            '   low:',  num2str(c.states.limits.low(i)), ...
            '   high:', num2str(c.states.limits.high(i)),' (',char(units(i)),')' );
         end
      end
    end
end
set(handles.stateList, 'String', sppluslimits);
%
% --------------------------function-------------------------------------
function setactList(handles, c)
% --- redraw the finalActuatorList box 
% handles  the BUI handles data structure

try
    % Get engineering units
    % If MDL fbck or lcaGet fails, set units to ' '
   eguNames = fbAddToPVNames(c.act.allactPVs, '.EGU');
   for i = 1:length(eguNames)
       if strcmp(c.feedbackAcro,'MDL')
           units(i) = {' '};
       else
           try
               units(i) = lcaGet(eguNames(i));
           catch
               units(i) = {' '};
           end
       end
   end

   %display STATUS of actuator units!
   [sevrStrs, sevr] = fbGetSevrString(c.act.allactPVs);
   if any(sevr) 
      set(handles.actList, 'ForegroundColor', 'red');
   else
      set(handles.actList, 'ForegroundColor', 'black');
   end
catch
   dbstack;
   h = errordlg('Could not read actuator PVs, quitting.');
   waitfor(h);
   fbLogMsg(['Could not read actuator PVs, ' c.feedbackName ' quitting']);
   %rethrow(lasterror);
end

% create the actuator PV + limits list
devpluslimits = [];
s = 0;
if ~isempty(c.act.PVs)
    for i=1:length(c.act.PVs)
        if c.act.PVs(i)==1
            s = s+1;
            if (sevr(i)>0)
            devpluslimits{s} = strcat(char(c.act.allactPVs(i)), ...
            '   energy:', num2str(c.act.energy(i)),...
            '   low:', num2str(c.act.limits.low(i)),...
            '   high:', num2str(c.act.limits.high(i)),' (',char(units(i)),')   alarm status: ',sevrStrs{i,1});
            else
            devpluslimits{s} = strcat(char(c.act.allactPVs(i)), ...
            '   energy:', num2str(c.act.energy(i)),...
            '   low:', num2str(c.act.limits.low(i)),...
            '   high:', num2str(c.act.limits.high(i)),' (',char(units(i)),')');
            end
        end
    end
end
set(handles.actList, 'String', devpluslimits);
%

% --------------------------function-------------------------------------
function setmeasList(handles, c)
% --- redraw the finalActuatorList box 
% handles  the BUI handles data structure

try
    % Get engineering units
    % If MDL fbck or lcaGet fails, set units to ' '
   eguNames = fbAddToPVNames(c.meas.allmeasPVs, '.EGU');
   for i = 1:length(eguNames)
       if strcmp(c.feedbackAcro,'MDL')
           units(i) = {' '};
       else
           try
               units(i) = lcaGet(eguNames(i));
           catch
               units(i) = {' '};
           end
       end
   end

   %display STATUS of measurement units!
   [sevrStrs,sevr] = fbGetSevrString(c.meas.allmeasPVs);
   if any(sevr) 
      set(handles.measList, 'ForegroundColor', 'red');
   else
      set(handles.measList, 'ForegroundColor', 'black');
   end
catch
   dbstack;
   h = errordlg('Could not read measurement PVs, quitting.');
   waitfor(h);
   fbLogMsg(['Could not read measurement PVs, ' c.feedbackName ' quitting']);
   %rethrow(lasterror);
end
    
% create the actuator PV + limits list
devpluslimits = [];
s = 0;
if ~isempty(c.meas.PVs)
    for i=1:length(c.meas.PVs)
        if c.meas.PVs(i)==1
            s = s+1;
            if (sevr(i)>0)
            devpluslimits{s} = strcat(char(c.meas.allmeasPVs(i)), ...
            '   dspr:', num2str(c.meas.dispersion(i)),...
            '   low:', num2str(c.meas.limits.low(i)), ...
            '   high:', num2str(c.meas.limits.high(i)),' (',char(units(i)),')   alarm status: ',sevrStrs{i,1});
            else
            devpluslimits{s} = strcat(char(c.meas.allmeasPVs(i)), ...
            '   dspr:', num2str(c.meas.dispersion(i)),...
            '   low:', num2str(c.meas.limits.low(i)), ...
            '   high:', num2str(c.meas.limits.high(i)),' (',char(units(i)),') ');
            end
        end
    end
end
set(handles.measList, 'String', devpluslimits);

% --------------------------function-------------------------------------
function tryOtherPVs(config)
% try to read from all other required PVs, stop the program if they aren't
% there to read.
%
% config - configuration structure, contains pv names

% misc. soft IOC PVs
pvs = {config.states.statePV;
       ['FBCK:' config.feedbackAcro config.feedbackNum ':1:ENABLE'];...
       ['FBCK:' config.feedbackAcro config.feedbackNum ':1:STATE']};
try
   lcaGet(pvs);
catch
   dbstack;
   h = errordlg('Could not read sioc-sys-fb00 feedback PVs, quitting');
   waitfor(h);
   fbLogMsg(['Could not read sioc-sys-fb00 feedback PVs, ' config.feedbackName ' quitting']);
   %rethrow(lasterror);
end

% pvs used to check TMIT values (help determine if beam is on)
pvs = fbGetTMITPVs(config.meas.allmeasPVs);
if ~isempty(pvs)
   try
      lcaGet(pvs);
   catch
      dbstack;
      h = errordlg('Could not read TMIT check PVs, quitting');
      waitfor(h);
      fbLogMsg(['Could not read TMIT check PVs, ' config.feedbackName ' quitting']); 
      %rethrow(lasterror);
   end
end


% --- Executes on selection change in measList.
function measList_Callback(hObject, eventdata, handles)
% hObject    handle to measList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns measList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measList


% --- Executes during object creation, after setting all properties.
function measList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in actList.
function actList_Callback(hObject, eventdata, handles)
% hObject    handle to actList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns actList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from actList


% --- Executes during object creation, after setting all properties.
function actList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
% --- Executes on selection change in stateList.
function stateList_Callback(hObject, eventdata, handles)
% hObject    handle to stateList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns stateList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stateList


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function stateList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stateList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function saveMenu_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
config = getappdata(0, 'Config_structure');
% 
filename =  sprintf ('%s/Feedback/%s', ...
         getenv('MATLABDATAFILES'), config.filename); 
unix(sprintf ('pushd %s/Feedback',getenv('MATLABDATAFILES')));
[file,path]=uiputfile(filename, 'Save Configuration File');
if (file ~= 0)
    config.filename = file;
end
config.configchanged = 0;
setappdata(0, 'Config_structure', config);
fbWriteConfigFile();
unix('popd')


% --------------------------------------------------------------------
function exitMenu_Callback(hObject, eventdata, handles)
% hObject    handle to exitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%loop = getappdata(0, 'Loop_structure');
[hobj, fig] = gcbo;
figure1_CloseRequestFcn(fig, eventdata, handles)



% --------------------------------------------------------------------
function configMenu_Callback(hObject, eventdata, handles)
% hObject    handle to configMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fbckMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fbckMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% bring up the feedback loop configuration figure
h = fbLoopGui();
waitfor(h);
config = getappdata(0,'Config_structure');
set(handles.fbckPanel, 'Title', config.feedbackName);


% --------------------------------------------------------------------
function timerMenu_Callback(hObject, eventdata, handles)
% hObject    handle to timerMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA%)
h = fbTimerGui();
waitfor(h);

% --------------------------------------------------------------------
function matrixMenu_Callback(hObject, eventdata, handles)
% hObject    handle to matrixMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = fbMatrixGui();
waitfor(h);

% --------------------------------------------------------------------
function actMenu_Callback(hObject, eventdata, handles)
% hObject    handle to actMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% bring up the actuator configuration figure
h = fbActuatorGui();
waitfor(h);
config = getappdata(0, 'Config_structure');
setactList(handles,config);


% --------------------------------------------------------------------
function measMenu_Callback(hObject, eventdata, handles)
% hObject    handle to measMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% bring up the measurement configuration figure
h= fbMeasGui();
waitfor(h);
config = getappdata(0, 'Config_structure');
setmeasList(handles, config);

% --------------------------------------------------------------------
function stateMenu_Callback(hObject, eventdata, handles)
% hObject    handle to stateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h= fbStateGui();
waitfor(h);
config = getappdata(0, 'Config_structure');
setstateList(handles,config)

% --------------------------------------------------------------------
function helpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function refOrbitMenu_Callback(hObject, eventdata, handles)
% hObject    handle to refOrbitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function collectRefMenu_Callback(hObject, eventdata, handles)
% hObject    handle to collectRefMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h= fbOrbitGUI();
waitfor(h);

% --------------------------------------------------------------------
function loadRefMenu_Callback(hObject, eventdata, handles)
% hObject    handle to loadRefMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

config = getappdata(0,'Config_structure');

if ~strcmpi(config.reforbitName, '0')
    filename =  sprintf ('%s/Feedback/data/%s%s/%s', ...
         getenv('MATLABDATAFILES'), config.feedbackAcro, config.feedbackNum, config.reforbitName); 
else
    filename =  sprintf ('%s/Feedback/data/%s%s/%s', ...
         getenv('MATLABDATAFILES'), config.feedbackAcro, config.feedbackNum, 'reforbit.mat'); 
end
unix(sprintf ('pushd %s/Feedback/data/%s%s',getenv('MATLABDATAFILES'), config.feedbackAcro, config.feedbackNum));
[file,path]=uigetfile('*.mat', 'Load Reference Orbit File', filename);
if (file ~= 0)
   config.reforbitName = file;
   load([path config.reforbitName]);
   config.refInit = 1;
   config.refData = refData;
   config.act.limits = fbCalcNewActLimits(config.refData.actvals, config.act.limits);
   config.configchanged = 1;
   setappdata(0, 'Config_structure', config);
   fbSoftIOCFcn('PutActInfo',config.act);
   try
      % write the actuator values to the restore storage place
      rstrNames = fbAddToPVNames(config.act.allstorePVs, 'RSTR');
      lcaPut(rstrNames, config.refData.actvals);
   catch
      dbstack;
      fbLogMsg(['Could not write act ref PVs, ' config.feedbackName ' quitting']);
      %rethrow(lasterror);
   end     
end
unix('popd')

% --------------------------------------------------------------------
function editRefMenu_Callback(hObject, eventdata, handles)
% hObject    handle to editRefMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of refOrbitBtn
config = getappdata(0,'Config_structure');

actvals = cellstr(num2str(config.refData.actvals));
data = cellstr(num2str(config.refData.data));

%prompt user to edit actuator values
prompt = config.act.allactPVs;
good_acts = 0;
dlg_title = 'Reference Orbit: Actuators';
num_lines = 1;
new  = str2num(char(inputdlg(prompt,dlg_title,num_lines, actvals)));
if any(new)
   refData.actvals = new;
   good_acts = 1;
end

%now get the measurement values
%prompt user to edit  values
prompt = config.meas.allmeasPVs;
dlg_title = 'Reference Orbit: Measurements';
num_lines = 1;
new = str2num(char(inputdlg(prompt,dlg_title,num_lines, data)));
if ~any(new) && ~good_acts
   h = errordlg('No new values, no orbit will be saved.');
   waitfor(h);
   return;
else
   refData.data = new;
   refData.count = 1;

   if ~strcmpi(config.reforbitName, '0')
       def = {config.reforbitName};
   else
       def = {'reforbit.mat'};
   end
   % get a filename for the reference orbit file
   prompt = {'If you wish to keep and use this reference, enter a name for the reference orbit MAT file'};
   dlg_title = 'Reference Orbit filename';
   num_lines = 1;
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
      config.act.limits = fbCalcNewActLimits(config.refData.actvals, config.act.limits);
      config.configchanged = 1;
      setappdata(0, 'Config_structure', config);
      fbSoftIOCFcn('PutActInfo',config.act);
   else
      h = errordlg('No filename entered; No reference orbit will be saved.');
      waitfor(h);
   end
end


% --------------------------------------------------------------------
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% do we want to save current configuration?
config = getappdata(0,'Config_structure');
if config.configchanged==1
    rsp = questdlg('The configuration has changed, do you want to save it?', 'Save configuration', 'Yes', 'No','Yes');
    if strcmpi(rsp,'Yes')
       % just save the file, no name changes here
       fbWriteConfigFile();
       %saveMenu_Callback(hObject, eventdata, handles); 
       %this may save a changed config, get it again
       config = getappdata(0,'Config_structure');
    end
    delete(config.fbckTimer);
    rmappdata(0,'Config_structure');
    % Hint: delete(hObject) closes the figure
    delete(hObject);
else
    delete(config.fbckTimer);
    rmappdata(0,'Config_structure');
    % Hint: delete(hObject) closes the figure
    delete(hObject);
end
%if not running the desktop, exit from matlab
if usejava('desktop')
    % dont exit
else
    exit
end



