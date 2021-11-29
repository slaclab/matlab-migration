function varargout = fbStateGui(varargin)
% FBSTATEGUI M-file for fbStateGui.fig
%      FBSTATEGUI, by itself, creates a new FBSTATEGUI or raises the existing
%      singleton*.
%
%      H = FBSTATEGUI returns the handle to a new FBSTATEGUI or the handle to
%      the existing singleton*.
%
%      FBSTATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBSTATEGUI.M with the given input arguments.
%
%      FBSTATEGUI('Property','Value',...) creates a new FBSTATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbStateGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbStateGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's4Edit Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbStateGui

% Last Modified by GUIDE v2.5 12-Dec-2007 16:34:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbStateGui_OpeningFcn, ...
                   'gui_OutputFcn',  @fbStateGui_OutputFcn, ...
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


% --- Executes just before fbStateGui is made visible.
function fbStateGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbStateGui (see VARARGIN)

%get the config data structure
config = getappdata(0,'Config_structure');
handles.feedbackAcro = config.feedbackAcro;

% Choose default command line output for fbStateGui
handles.output = hObject;

% save the config in the handles structure for now
% we'll keep them here for gui work, and move them back to 'config'
% when the save button is pressed
handles.states = config.states;

handles.maxerrs = config.states.maxerrs;
handles.pGain = config.states.pGain;
handles.iGain = config.states.iGain;
handles.configchanged = config.configchanged;
handles.softIOCchanged = 0;

% initialize the values in the list boxes from the config values
set(handles.possStatesList, 'String', handles.states.names);
setListBoxes(handles);
setEditValues(handles);
set(handles.numErrsEdit, 'String', num2str(config.states.maxerrs));
set(handles.pGainEdit, 'String', num2str(config.states.pGain));
set(handles.iGainEdit, 'String', num2str(config.states.iGain));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fbStateGui wait for user response (see UIRESUME)
uiwait(handles.stateFig);


% --- Outputs from this function are returned to the command line.
function varargout = fbStateGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.stateFig);

% --------------------------function-------------------------------------
function setFinalBox(handles)
% --- redraw the finalActuatorList box 
% handles  the BUI handles data structure

% Get engineering units
% If MDL fbck or lcaGet fails, set units to ' '
eguNames = fbAddToPVNames(handles.states.allstatePVs, '.EGU');
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

%display STATUS of state pvs!
[sevrStrs, sevr] = fbGetSevrString(handles.states.allstatePVs);
if any(sevr) 
  set(handles.finalSPList, 'ForegroundColor', 'red');
else
  set(handles.finalSPList, 'ForegroundColor', 'black');
end

% create the states PV + limits list
sppluslimits = [];
if ~isempty(handles.states.PVs)
   s=0;
   for i=1:length(handles.states.PVs)
      if handles.states.PVs(i)==1
         s = s+1;
         if (sevr(i)>0)
            sppluslimits{s} = strcat(handles.states.names{i,1},...
            '   setpoint:', num2str(handles.states.SPs(i)), ...
            '   low:', num2str(handles.states.limits.low(i)), ...
            '   high:', num2str(handles.states.limits.high(i)),' (',char(units(i)),')   alarm status: ',sevrStrs{i,1});
         else
            sppluslimits{s} = strcat( char(handles.states.names(i)), ...
            '   setpoint:',  num2str(handles.states.SPs(i)), ...
            '   low:',  num2str(handles.states.limits.low(i)), ...
            '   high:', num2str(handles.states.limits.high(i)),' (',char(units(i)),')' );
         end
      end
    end
end
set(handles.finalSPList, 'String', sppluslimits);

% --------------------------function-------------------------------------
function setChosenStatesList(handles)
% --- set the strings in each list box
% handles  the GUI handles data structure
stateplusPV = [];
if ~isempty(handles.states.PVs)
   s=0;
   for i=1:length(handles.states.PVs)
      if handles.states.PVs(i)==1
         s = s+1;
         stateplusPV{s} = strcat( char(handles.states.names(i)), ...
            '          PV name:', char(handles.states.allstatePVs(i)) );
      end
    end
end
set(handles.chosenStatesList, 'Value',1)
set(handles.chosenStatesList, 'String', stateplusPV);

% --------------------------function-------------------------------------
function setListBoxes(handles)
% --- set the strings in each list box
% handles  the GUI handles data structure
setChosenStatesList(handles);
set(handles.spLimitsList, 'Value',1)
set(handles.spLimitsList, 'String', handles.states.chosennames);
setFinalBox(handles);

% --------------------------function-------------------------------------
function setEditValues(handles)
% --- set the limits and initial value edit boxes, based on new names in
% --- list box, the selected item
% handles   references the components we are working with

if ~isempty(handles.states.chosennames)
    i = get(handles.spLimitsList, 'Value');
    %initialize the act limits edit boxes
    set(handles.lowerLimitEdit, 'String', num2str(handles.states.limits.low(i)) );
    set(handles.upperLimitEdit, 'String', num2str(handles.states.limits.high(i)) );
    set(handles.spEdit, 'String', num2str(handles.states.SPs(i)) );
end

% --------------------------function-------------------------------------
function clearEditValues(handles)
% --- set the limits and initial value edit boxes, based on new names in
% --- list box
% handles    references to the components we are working with

% clear the act limits edit boxes
set(handles.lowerLimitEdit, 'String', '');
set(handles.upperLimitEdit, 'String', '');
set(handles.spEdit, 'String', '');


% --- Executes on selection change in possStatesList.
function possStatesList_Callback(hObject, eventdata, handles)
% hObject    handle to possStatesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns possStatesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from possStatesList


% --- Executes during object creation, after setting all properties.
function possStatesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to possStatesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chosenStatesList.
function chosenStatesList_Callback(hObject, eventdata, handles)
% hObject    handle to chosenStatesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chosenStatesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chosenStatesList


% --- Executes during object creation, after setting all properties.
function chosenStatesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chosenStatesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in choseOneBtn.
function choseOneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to choseOneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get the list of SELECTED measurment PVs; can be more than one
allPVs = get(handles.possStatesList, 'String');
selPVs = get(handles.possStatesList, 'Value');
ls = length(selPVs);

%check that at least one is selected
if (ls>0)
    for i=1:ls
        selectedStates(i) = cellstr(allPVs(selPVs(i)) );
    end

    %get the list of currently chosen measurement PVs
    chosenStates = handles.states.chosennames;
    %add any SELECTED actuator that is not already in the chosen list
    members = ismember(selectedStates, chosenStates);
    for i=1:length(selectedStates)
        if (members(i) == 0)
            chosenStates(end+1) = selectedStates(i);
        end
    end

    % update data structures
    handles.states.PVs = ismember(handles.states.names, chosenStates);
    % re-order chosenmeas, chosenres
    handles.states.chosenstatePVs = fbGetPVNames(handles.states.PVs, handles.states.allstatePVs);
    handles.states.chosenspPVs = fbGetPVNames(handles.states.PVs, handles.states.allspPVs);
    handles.states.chosennames = chosenStates;
    handles.softIOCchanged = 1;

    % update the gui components
    setListBoxes(handles);
    setEditValues(handles);

    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in choseAllBtn.
function choseAllBtn_Callback(hObject, eventdata, handles)
% hObject    handle to choseAllBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get all the list of possible state pvs and update data structures
states = get(handles.possStatesList, 'String');
handles.states.PVs = ismember(handles.states.names, states);
handles.states.chosenstatePVs = handles.states.allstatePVs;
handles.states.chosenspPVs = handles.states.allspPVs;
handles.states.chosennames = handles.states.names;
handles.softIOCchanged = 1;

% replace the list of chosen state pvs with ALL the state pvs
%update the gui components
setListBoxes(handles);
if ~isempty(handles.states.PVs)
    setEditValues(handles);
else
    clearEditValues(handles);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in deleteOneBtn.
function deleteOneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to deleteOneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the list of chosen measurement pvs and delete the SELECTED one(s)
chosenStates = handles.states.chosennames;
selPVs = get(handles.chosenStatesList, 'Value');
ls = length(selPVs);
if (ls>0)
    for i=1:ls
        delStates(i) = chosenStates(selPVs(i));
    end
    states = setdiff(chosenStates, delStates);

    %update data structures
    handles.states.PVs = ismember(handles.states.names, states);
    handles.states.chosenstatePVs = fbGetPVNames(handles.states.PVs, handles.states.allstatePVs);
    handles.states.chosenspPVs = fbGetPVNames(handles.states.PVs, handles.states.allspPVs);
    handles.states.chosennames = fbGetPVNames(handles.states.PVs, handles.states.names);
    handles.softIOCchanged = 1;
    
    %update gui components
    setListBoxes(handles);
    if isempty(handles.states.PVs)==0
        setEditValues(handles);
    else
        clearEditValues(handles);
    end

    % Update handles structure
    guidata(hObject, handles);

end


% --- Executes on button press in deleteAllBtn.
function deleteAllBtn_Callback(hObject, eventdata, handles)
% hObject    handle to deleteAllBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%update data structures
handles.states.PVs = zeros(length(handles.states.allstatePVs),1);
handles.states.chosenstatePVs = fbGetPVNames(handles.states.PVs, handles.states.allstatePVs);
handles.states.chosenspPVs = fbGetPVNames(handles.states.PVs, handles.states.allspPVs);
handles.states.chosennames = fbGetPVNames(handles.states.PVs, handles.states.names);
handles.softIOCchanged = 1;

%delete all actuator names update components
setListBoxes(handles);
clearEditValues(handles);
% Update handles structure
guidata(hObject, handles);



% --------------------------function-------------------------------------
function pGainEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pGainEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pGainEdit as text
%        str2double(get(hObject,'String')) returns contents of pGainEdit as a double
handles.pGain = str2num(get(hObject, 'String') );
handles.configchanged = 1;
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function pGainEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pGainEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function iGainEdit_Callback(hObject, eventdata, handles)
% hObject    handle to iGainEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iGainEdit as text
%        str2double(get(hObject,'String')) returns contents of iGainEdit as a double
handles.iGain = str2num(get(hObject, 'String') );
handles.configchanged = 1;
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function iGainEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iGainEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function numErrsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to numErrsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numErrsEdit as text
%        str2double(get(hObject,'String')) returns contents of numErrsEdit as a double
handles.maxerrs = str2num(get(hObject, 'String') );
handles.configchanged = 1;
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function numErrsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numErrsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in spLimitsList.
function spLimitsList_Callback(hObject, eventdata, handles)
% hObject    handle to spLimitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns spLimitsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spLimitsList
% set the limits and initial pv edit boxes based on the newly selected PV
setEditValues(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function spLimitsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spLimitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowerLimitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lowerLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of lowerLimitEdit as a double
% get the index of the setpoint selected
pvs = get(handles.spLimitsList, 'String');
str = pvs{get(handles.spLimitsList, 'Value')};
% get the index in the full list of sp PVs
ll = strmatch(str, handles.states.names);
% get the new limit value
lolimit = str2double(get(hObject, 'String'));
% set the new sp lower limit
handles.states.limits.low(ll) = lolimit;
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
% hObject    handle to upperLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of upperLimitEdit as a double
% get the index of the setpoint selected
pvs = get(handles.spLimitsList, 'String');
str = pvs{get(handles.spLimitsList, 'Value')};
% get the index in the full list of sp PVs
hl = strmatch(str, handles.states.names);
% get the new limit value
hilimit = str2double(get(hObject, 'String'));
% set the new act upper limit
handles.states.limits.high(hl) = hilimit;
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


% --- Executes on selection change in finalSPList.
function finalSPList_Callback(hObject, eventdata, handles)
% hObject    handle to finalSPList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns finalSPList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from finalSPList


% --- Executes during object creation, after setting all properties.
function finalSPList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finalSPList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spEdit_Callback(hObject, eventdata, handles)
% hObject    handle to spEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spEdit as text
%        str2double(get(hObject,'String')) returns contents of spEdit as a double
% get the index of the setpoint selected
pvs = get(handles.spLimitsList, 'String');
str = pvs{get(handles.spLimitsList, 'Value')};
% get the index in the full list of sp PVs
sl = strmatch(str, handles.states.names);
% get the new limit value
sp = str2double(get(hObject, 'String'));
% set the new act upper limit
handles.states.SPs(sl) = sp;
handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function spEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

config = getappdata(0, 'Config_structure');

%get the state setpoints 
handles.states.pGain = handles.pGain;
handles.states.iGain = handles.iGain;
handles.states.maxerrs = handles.maxerrs;
config.states = handles.states;
guidata(gcbf,handles);

%save state info in feedback IOC
fbSoftIOCFcn('PutStatesInfo',handles.states);

%save the changes
config.configchanged = handles.configchanged;
setappdata(0,'Config_structure',config);

% get the figure and call it's close function
uiresume(handles.stateFig);

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%just close without saving changes.
uiresume(handles.stateFig);

% --- Executes when user attempts to close stateFig.
function stateFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to stateFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%just close without saving changes.
if isequal(get(handles.stateFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
   uiresume(handles.stateFig);
else
   % The GUI is no longer waiting, just close it
   delete(handles.stateFig);
end


