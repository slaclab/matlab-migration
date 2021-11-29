function varargout = fbActuatorGui(varargin)
% FBACTUATORGUI M-file for fbActuatorGui.fig
%      FBACTUATORGUI, by itself, creates a new FBACTUATORGUI or raises the existing
%      singleton*.
%
%      H = FBACTUATORGUI returns the handle to a new FBACTUATORGUI or the handle to
%      the existing singleton*.
%
%      FBACTUATORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBACTUATORGUI.M with the given input arguments.
%
%      FBACTUATORGUI('Property','Value',...) creates a new FBACTUATORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbActuatorGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbActuatorGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbActuatorGui

% Last Modified by GUIDE v2.5 13-Aug-2007 15:00:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbActuatorGui_OpeningFcn, ...
                   'gui_OutputFcn',  @fbActuatorGui_OutputFcn, ...
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

% ---------------------- GUI FUNCTIONS -------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = fbActuatorGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% now we can delete this dialog
delete(handles.actuatorFig);


% --- Executes just before fbActuatorGui is made visible.
function fbActuatorGui_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Initialize the components and save the data we are working with
% --- in the handles structure 
% --- This function has no output args, see OutputFcn. 
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbActuatorGui (see VARARGIN)

% Choose default command line output for fbActuatorGui
handles.output = hObject;

% get the config and configuration values we need
config = getappdata(0,'Config_structure');
handles.feedbackAcro = config.feedbackAcro;

% save the config values in the handles structure for now
% we'll keep them here for gui work, and move them back to 'config'
% when the done button is pressed
handles.act = config.act;

handles.ctrl = config.ctrl;
handles.configchanged = config.configchanged;
handles.softIOCchanged = 0;

% initialize the values in the list boxes from the config values
set(handles.possActList, 'String', handles.act.allactPVs);
setListBoxes(handles);
setEditValues(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fbActuatorGui wait for user response (see UIRESUME)
uiwait(handles.actuatorFig);

% ----------------------UTILITY FUNCTIONS -------------------------------

% --------------------------function-------------------------------------
function setFinalBox(handles)
% --- redraw the finalActuatorList box 
% handles  the GUI handles data structure

% Get engineering units
% If MDL fbck or lcaGet fails, set units to ' '
eguNames = fbAddToPVNames(handles.act.allactPVs, '.EGU');
for i = 1:length(eguNames)
    if strcmp(handles.feedbackAcro,'MDL')
        units(i) = {' '};
    else
        try
            units(i) = lcaGet(eguNames(i));
        catch
            units(i) = {' '};
        end
    end
end
   
%display STATUS of actuators
[sevrStrs, sevr] = fbGetSevrString(handles.act.allactPVs);
if any(sevr) 
  set(handles.finalActuatorList, 'ForegroundColor', 'red');
else
  set(handles.finalActuatorList, 'ForegroundColor', 'black');
end

% create the actuator PV + limits list
devpluslimits = [];
s = 0;
if length(handles.act.PVs)>0
    for i=1:length(handles.act.PVs)
        if handles.act.PVs(i)==1
            s = s+1;
            if (sevr(i)>0)
            devpluslimits{s} = strcat(char(handles.act.allactPVs(i)), ...
            '   energy:', num2str(handles.act.energy(i)),...
            '   low:', num2str(handles.act.limits.low(i)),...
            '   high:', num2str(handles.act.limits.high(i)),' (',char(units(i)),')   alarm status: ',sevrStrs{i,1});
            else
            devpluslimits{s} = strcat(char(handles.act.allactPVs(i)), ...
            '   energy:', num2str(handles.act.energy(i)),...
            '   low:', num2str(handles.act.limits.low(i)), ...
            '   high:', num2str(handles.act.limits.high(i)),' (',char(units(i)),')');
            end
        end
    end
end
set(handles.finalActuatorList, 'String', devpluslimits);

% --------------------------function-------------------------------------
function setListBoxes(handles)
% --- set the strings in each PV list box
% handles  the GUI handles data structure
set(handles.chosenActList, 'Value',1)
set(handles.chosenActList, 'String', handles.act.chosenactPVs);
set(handles.rbPVList, 'String', fbGetPVNames(handles.act.PVs, handles.act.allrbPVs));
set(handles.ctrlPVList, 'String', fbGetPVNames(handles.act.PVs, handles.ctrl.allctrlPVs));
set(handles.actLimitsList, 'Value',1)
set(handles.actLimitsList, 'String', handles.act.chosenactPVs);
setFinalBox(handles);

% --------------------------function-------------------------------------
function setEditValues(handles)
% --- set the limits and initial value edit boxes, based on new names in
% --- list box, the selected item
% handles   references the components we are working with

if length(handles.act.chosenactPVs)>0
    i = get(handles.actLimitsList, 'Value');
    index = strmatch(handles.act.chosenactPVs(i), handles.act.allactPVs);
    %initialize the act limits edit boxes
    set(handles.lowerLimitEdit, 'String', num2str(handles.act.limits.low(index)) );
    set(handles.upperLimitEdit, 'String', num2str(handles.act.limits.high(index)) );
    set(handles.percentTolEdit, 'String', num2str(handles.act.limits.percent(index)) );
end

% --------------------------function-------------------------------------
function clearEditValues(handles)
% --- set the limits and initial value edit boxes, based on new names in
% --- list box
% handles    references to the components we are working with

% clear the act limits edit boxes
set(handles.lowerLimitEdit, 'String', '');
set(handles.upperLimitEdit, 'String', '');
set(handles.percentTolEdit, 'String', '');



% ----------------------GUI FUNCTIONS -------------------------------


% --------------------------function-------------------------------------
% --- Executes during object creation, after setting all properties.
function possActList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to possActList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function chosenActList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chosenActList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function finalActuatorList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finalActuatorList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function rbPVList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actLimitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ctrlPVList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actLimitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function actLimitsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actLimitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in chosenActList.
function chosenActList_Callback(hObject, eventdata, handles)
% hObject    handle to chosenActList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chosenActList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chosenActList


% --- Executes on selection change in possActList.
function possActList_Callback(hObject, eventdata, handles)
% hObject    handle to possActList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns possActList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from possActList



% --- Executes on button press in choseOneBtn.
function choseOneBtn_Callback(hObject, eventdata, handles)
%--- add the selected PV names to the 'chosen' PVs list and update all of
%--- the componenets and data structures we are working with
% hObject    handle to choseOneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the list of SELECTED actuators; can be more than one
allPVs = get(handles.possActList, 'String');
selPVs = get(handles.possActList, 'Value');
ls = length(selPVs);

%check that at least one is selected
if (ls>0)
    for i=1:ls
        selectedActuators(i) = cellstr(allPVs(selPVs(i)) );
    end

    %get the list of currently chosen actuators
    chosenActuators = cellstr(get(handles.chosenActList, 'String') );
    %add any SELECTED actuator that is not already in the chosen list
    members = ismember(selectedActuators, chosenActuators);
    for i=1:length(selectedActuators)
        if (members(i) == 0)
            chosenActuators(end+1) = selectedActuators(i);
        end
    end

    % update data structures
    handles.act.PVs = ismember(handles.act.allactPVs, chosenActuators);
    % re-order chosenActuators
    handles.act.chosenactPVs = fbGetPVNames(handles.act.PVs, handles.act.allactPVs);
    handles.act.chosenrbPVs = fbGetPVNames(handles.act.PVs, handles.act.allrbPVs);
    handles.act.chosenstorePVs = fbGetPVNames(handles.act.PVs, handles.act.allstorePVs);
    handles.softIOCchanged = 1;

    % update the gui components
    setListBoxes(handles);
    setEditValues(handles);

    % Update handles structure
    guidata(hObject, handles);

end


% --- Executes on button press in choseAllBtn.
function choseAllBtn_Callback(hObject, eventdata, handles)
%--- place all setpoint PV names into the 'chosen' PV list
% hObject    handle to choseAllBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get all the list of possible actuators and update data structures
actuators = get(handles.possActList, 'String');
handles.act.PVs = ismember(handles.act.allactPVs, actuators);
handles.act.chosenactPVs = handles.act.allactPVs;
handles.act.chosenrbPVs = handles.act.allrbPVs;
handles.act.chosenstorePVs = handles.act.allstorePVs;
handles.softIOCchanged = 1;

% replace the list of chosen actuators with ALL the actuators
%update the gui components
setListBoxes(handles);
if length(handles.act.PVs)>0
    setEditValues(handles);
else
    clearEditValues(handles);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in deleteOneBtn.
function deleteOneBtn_Callback(hObject, eventdata, handles)
% --- delete the selected PV name from the 'chosen' PVs list
% hObject    handle to deleteOneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the list of chosen actuators and delete the SELECTED one(s)
chosenActuators = get(handles.chosenActList,'String');
selPVs = get(handles.chosenActList, 'Value');
ls = length(selPVs);
if (ls>0)
    for i=1:ls
        delActuators(i) = chosenActuators(selPVs(i));
    end
    actuators = setdiff(chosenActuators, delActuators);

    %update data structures
    handles.act.PVs = ismember(handles.act.allactPVs, actuators);
    handles.act.chosenactPVs = fbGetPVNames(handles.act.PVs, handles.act.allactPVs);
    handles.act.chosenrbPVs = fbGetPVNames(handles.act.PVs, handles.act.allrbPVs);
    handles.act.chosenstorePVs = fbGetPVNames(handles.act.PVs, handles.act.allstorePVs);
    handles.softIOCchanged = 1;
    
    %update gui components
    setListBoxes(handles);
    if length(handles.act.PVs)>0
        setEditValues(handles);
    else
        clearEditValues(handles);
    end

    % Update handles structure
    guidata(hObject, handles);

end

% --- Executes on button press in deleteAllBtn.
function deleteAllBtn_Callback(hObject, eventdata, handles)
% --- delete all PV names from the 'chosen' PVs list
% hObject    handle to deleteAllBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%update data structuresinit
handles.act.PVs = zeros(length(handles.act.allactPVs),1);
handles.act.chosenactPVs = fbGetPVNames(handles.act.PVs, handles.act.allactPVs);
handles.act.chosenrbPVs = fbGetPVNames(handles.act.PVs, handles.act.allrbPVs);
handles.act.chosenstorePVs = fbGetPVNames(handles.act.PVs, handles.act.allstorePVs);
handles.softIOCchanged = 1;

%delete all actuator names update components
setListBoxes(handles);
clearEditValues(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in actLimitsList.
function actLimitsList_Callback(hObject, eventdata, handles)
% --- display the low/high limits on the selected actPV name
% hObject    handle to actLimitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns actLimitsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from actLimitsList

% set the limits and initial pv edit boxes based on the newly selected PV
setEditValues(handles);
% Update handles structure
guidata(hObject, handles);

function percentTolEdit_Callback(hObject, eventdata, handles)
% hObject    handle to percentTolEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of percentTolEdit as text
%        str2double(get(hObject,'String')) returns contents of percentTolEdit as a double

% get the config and configuration values we need
config = getappdata(0,'Config_structure');

% get the index of the actPV selected
pvs = get(handles.actLimitsList, 'String');
str = pvs{get(handles.actLimitsList, 'Value')};
% get the new percent tol value
tol = str2double(get(hObject, 'String'));
% get the index in the full list of act PVs
ll = strmatch(str, handles.act.allactPVs);
% set the new tol value
handles.act.limits.percent(ll) = tol;
%calc new limits for this actuator
if config.refInit
   handles.act.limits = fbCalcNewActLimits(config.refData.actvals, handles.act.limits);
   % show the new limits
   set(handles.upperLimitEdit, 'String', num2str(handles.act.limits.high(ll)));
   set(handles.lowerLimitEdit, 'String', num2str(handles.act.limits.low(ll)));
   set(handles.percentTolEdit, 'String', num2str(handles.act.limits.percent(ll)));
   handles.softIOCchanged = 1;
end;

%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function percentTolEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to percentTolEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lowerLimitEdit_Callback(hObject, eventdata, handles)
% --- Gets the new value of the lower limit of the PV selected in the 
% --- actLimitsListand inserts it into the full list of act PV limits
% --- update the data structure too
% hObject    handle to lowerLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of lowerLimitEdit as a double

% get the index of the actPV selected
pvs = get(handles.actLimitsList, 'String');
str = pvs{get(handles.actLimitsList, 'Value')};
% get the new limit value
lolimit = str2double(get(hObject, 'String'));
% get the index in the full list of act PVs
ll = strmatch(str, handles.act.allactPVs);
% set the new act upper limit
handles.act.limits.low(ll) = lolimit;
handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lowerLimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function upperLimitEdit_Callback(hObject, eventdata, handles)
% --- get the new value of the upper limit of the PV selected in the 
% --- actLimitsList list box and inserts it into the full act Limits list. 
% --- update the data structure too
% hObject    handle to upperLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of upperLimitEdit as a double

% get the index of the actPV selected
pvs = get(handles.actLimitsList, 'String');
str = pvs{get(handles.actLimitsList, 'Value')};
% get the new limit value
uplimit = str2double(get(hObject, 'String'));
% get the index in the full list of act PVs
ll = strmatch(str, handles.act.allactPVs);
% set the new act upper limit
handles.act.limits.high(ll) = uplimit;
handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function upperLimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in limFromDevBtn.
function limFromDevBtn_Callback(hObject, eventdata, handles)
% hObject    handle to limFromDevBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the tolerances from the actuator PV

% get the index of the actPV selected
pvs = get(handles.actLimitsList, 'String');
str{1} = pvs{get(handles.actLimitsList, 'Value')};

% get the new upper limit value
pv = fbAddToPVNames(str, '.HOPR');
uplimit = lcaGet(pv);
% get the index in the full list of act PVs
ll = strmatch(str, handles.act.allactPVs);
% set the new act upper limit
handles.act.limits.high(ll) = uplimit;
set(handles.upperLimitEdit, 'String', num2str(uplimit));

% get the new lower limit value
pv = fbAddToPVNames(str, '.LOPR');
lolimit = lcaGet(pv);
% get the index in the full list of act PVs
ll = strmatch(str, handles.act.allactPVs);
% set the new act upper limit
handles.act.limits.low(ll) = lolimit;
set(handles.lowerLimitEdit, 'String', num2str(lolimit));

handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%just close this figure, don't save changes
%resume so that we can exit
uiresume(handles.actuatorFig);
%fig = gcbf;
%delete(fig);

% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% we're done with this window, store data changes
% (we just assume there were changes)

%first store to feedback IOC
fbSoftIOCFcn('PutActInfo',handles.act);

% now write to config
config = getappdata(0, 'Config_structure');
config.act = handles.act;
config.act.numactPVs = length(handles.act.chosenactPVs);

config.configchanged = handles.configchanged;
setappdata(0,'Config_structure',config);

%resume so that we can exit
uiresume(handles.actuatorFig);
% get the figure and close it
%fig = gcbf;
%delete(gcbf);


% --- Executes when user attempts to close actuatorFig.
function actuatorFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to actuatorFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if the user hits x then assume it means cancel
% Hint: delete(hObject) closes the figure
if isequal(get(handles.actuatorFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
   uiresume(handles.actuatorFig);
else
   % The GUI is no longer waiting, just close it
   delete(handles.actuatorFig);
end





