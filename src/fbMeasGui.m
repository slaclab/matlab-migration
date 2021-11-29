function varargout = fbMeasGui(varargin)
% FBMEASGUI M-file for fbMeasGui.fig
%      FBMEASGUI, by itself, creates a new FBMEASGUI or raises the existing
%      singleton*.
%
%      H = FBMEASGUI returns the handle to a new FBMEASGUI or the handle to
%      the existing singleton*.
%
%      FBMEASGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBMEASGUI.M with the given input arguments.
%
%      FBMEASGUI('Property','Value',...) creates a new FBMEASGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbMeasGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbMeasGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbMeasGui

% Last Modified by GUIDE v2.5 12-Dec-2007 16:30:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbMeasGui_OpeningFcn, ...
                   'gui_OutputFcn',  @fbMeasGui_OutputFcn, ...
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


% --- Executes just before fbMeasGui is made visible.
function fbMeasGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbMeasGui (see VARARGIN)

% Choose default command line output for fbMeasGui
handles.output = hObject;

% get the configuration values we need
config = getappdata(0,'Config_structure');

% save the config values in the handles structure for now
% we'll keep them here for gui work, and move them back to 'config'
% when the save button is pressed
handles.meas = config.meas;
handles.feedbackAcro = config.feedbackAcro;

% init the checkbox
if (config.refInit>0)
    handles.refOrbit = 1;
    set(handles.refOrbitCbx, 'Value', 1);
    set(handles.refOrbitCbx, 'Enable', 'on');
else
    set(handles.refOrbitCbx, 'Value', 0);
    set(handles.refOrbitCbx, 'Enable', 'off');
end
handles.configchanged = config.configchanged;
handles.softIOCchanged = 0;

% initialize the values in the list boxes from the config values
set(handles.possMeasList, 'String', handles.meas.allmeasPVs);
setListBoxes(handles);
setEditValues(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fbMeasGui wait for user response (see UIRESUME)
uiwait(handles.measFig);


% --- Outputs from this function are returned to the command line.
function varargout = fbMeasGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.measFig);

% ----------------------UTILITY FUNCTIONS -------------------------------

% --------------------------function-------------------------------------
function setFinalBox(handles)
% --- redraw the finalMeasList box 
% handles  the BUI handles data structure

% Get engineering units
% If MDL fbck or lcaGet fails, set units to ' '
eguNames = fbAddToPVNames(handles.meas.allmeasPVs, '.EGU');
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

%display STATUS of measurement units!
[sevrStrs,sevr] = fbGetSevrString(handles.meas.allmeasPVs);
if any(sevr) 
    set(handles.finalMeasList, 'ForegroundColor', 'red');
else
    set(handles.finalMeasList, 'ForegroundColor', 'black');
end

% create the meas PV + limits list
devpluslimits = [];
s = 0;
if ~isempty(handles.meas.PVs)
    for i=1:length(handles.meas.PVs)
        if handles.meas.PVs(i)==1
            s = s+1;
            if (sevr(i)>0)
               devpluslimits{s} = strcat(char(handles.meas.allmeasPVs(i)), ...
                '   dspr:', num2str(handles.meas.dispersion(i)), ...
                '   low:', num2str(handles.meas.limits.low(i)), ...
                '   high:', num2str(handles.meas.limits.high(i)),' (',char(units(i)),')   alarm status: ',sevrStrs{i,1});
            else
                devpluslimits{s} = strcat(char(handles.meas.allmeasPVs(i)), ...
                '   dspr:', num2str(handles.meas.dispersion(i)), ...
                '   low:', num2str(handles.meas.limits.low(i)), ...
                '   high:', num2str(handles.meas.limits.high(i)),' (',char(units(i)),')');
            end
        end
    end
end
set(handles.finalMeasList, 'String', devpluslimits);


% --------------------------function-------------------------------------
function setListBoxes(handles)
% --- set the strings in each PV list box
% handles  the GUI handles data structure
set(handles.chosenMeasList, 'Value',1)
set(handles.chosenMeasList, 'String', handles.meas.chosenmeasPVs);
set(handles.measTolList, 'Value',1)
set(handles.measTolList, 'String', handles.meas.chosenmeasPVs);
setFinalBox(handles);

% --------------------------function-------------------------------------
function setEditValues(handles)
% --- set the limits and initial value edit boxes, based on new names in
% --- list box, the selected item
% handles   references the components we are working with

if isempty(handles.meas.chosenmeasPVs)==0
    i = get(handles.measTolList, 'Value');
    index = strmatch(handles.meas.chosenmeasPVs(i), handles.meas.allmeasPVs);
    %initialize the sp limits edit boxes
    set(handles.dsprEdit,  'String', num2str(handles.meas.dispersion(index)) );
    set(handles.loTolEdit, 'String', num2str(handles.meas.limits.low(index)) );
    set(handles.hiTolEdit, 'String', num2str(handles.meas.limits.high(index)) );
end

% --------------------------function-------------------------------------
function clearEditValues(handles)
% --- set the limits and initial value edit boxes, based on new names in
% --- list box
% handles    references to the components we are working with

% clear the sp limits edit boxes
set(handles.dsprEdit,  'String', '');
set(handles.loTolEdit, 'String', '');
set(handles.hiTolEdit, 'String', '');



% --- Executes on selection change in possMeasList.
function possMeasList_Callback(hObject, eventdata, handles)
% hObject    handle to possMeasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns possMeasList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from possMeasList


% --- Executes during object creation, after setting all properties.
function possMeasList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to possMeasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chosenMeasList.
function chosenMeasList_Callback(hObject, eventdata, handles)
% hObject    handle to chosenMeasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chosenMeasList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chosenMeasList


% --- Executes during object creation, after setting all properties.
function chosenMeasList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chosenMeasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chooseOneBtn.
function chooseOneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseOneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the list of SELECTED measurment PVs; can be more than one
allPVs = get(handles.possMeasList, 'String');
selPVs = get(handles.possMeasList, 'Value');
ls = length(selPVs);

%check that at least one is selected
if (ls>0)
    for i=1:ls
        selectedMeasurements(i) = cellstr(allPVs(selPVs(i)) );
    end

    %get the list of currently chosen measurement PVs
    chosenMeasurements = cellstr(get(handles.chosenMeasList, 'String') );
    %add any SELECTED actuator that is not already in the chosen list
    members = ismember(selectedMeasurements, chosenMeasurements);
    for i=1:length(selectedMeasurements)
        if (members(i) == 0)
            chosenMeasurements(end+1) = selectedMeasurements(i);
        end
    end

    % update data structures
    handles.meas.PVs = ismember(handles.meas.allmeasPVs, chosenMeasurements);
    % re-order chosenmeas, chosenres
    handles.meas.chosenmeasPVs = fbGetPVNames(handles.meas.PVs, handles.meas.allmeasPVs);
    handles.meas.chosenresPVs = fbGetPVNames(handles.meas.PVs, handles.meas.allresPVs);
    handles.meas.chosenstorePVs = fbGetPVNames(handles.meas.PVs, handles.meas.allstorePVs);
    handles.softIOCchanged = 1;

    % update the gui components
    setListBoxes(handles);
    setEditValues(handles);

    % Update handles structure
    guidata(hObject, handles);

end


% --- Executes on button press in chooseAllBtn.
function chooseAllBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseAllBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get all the list of possible measurement pvs and update data structures
measurements = get(handles.possMeasList, 'String');
handles.meas.PVs = ismember(handles.meas.allmeasPVs, measurements);
handles.meas.chosenmeasPVs = handles.meas.allmeasPVs;
handles.meas.chosenresPVs = handles.meas.allresPVs;
handles.meas.chosenstorePVs = handles.meas.allstorePVs;
handles.softIOCchanged = 1;

% replace the list of chosen measurement pvs with ALL the measurement pvs
%update the gui components
setListBoxes(handles);
if isempty(handles.meas.PVs)==0
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
chosenMeasurements = get(handles.chosenMeasList,'String');
selPVs = get(handles.chosenMeasList, 'Value');
ls = length(selPVs);
if (ls>0)
    for i=1:ls
        delMeasurements(i) = chosenMeasurements(selPVs(i));
    end
    measurements = setdiff(chosenMeasurements, delMeasurements);

    %update data structures
    handles.meas.PVs = ismember(handles.meas.allmeasPVs, measurements);
    handles.meas.chosenmeasPVs = fbGetPVNames(handles.meas.PVs, handles.meas.allmeasPVs);
    handles.meas.chosenresPVs = fbGetPVNames(handles.meas.PVs, handles.meas.allresPVs);
    handles.meas.chosenstorePVs = fbGetPVNames(handles.meas.PVs, handles.meas.allstorePVs);
    handles.softIOCchanged = 1;
    
    %update gui components
    setListBoxes(handles);
    if isempty(handles.meas.PVs)==0
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
handles.meas.PVs = zeros(length(handles.meas.allmeasPVs),1);
handles.meas.chosenmeasPVs = fbGetPVNames(handles.meas.PVs, handles.meas.allmeasPVs);
handles.meas.chosenresPVs = fbGetPVNames(handles.meas.PVs, handles.meas.allresPVs);
handles.meas.chosenstorePVs = fbGetPVNames(handles.meas.PVs, handles.meas.allstorePVs);
handles.softIOCchanged = 1;

%delete all actuator names update components
setListBoxes(handles);
clearEditValues(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in measTolList.
function measTolList_Callback(hObject, eventdata, handles)
% hObject    handle to measTolList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns measTolList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measTolList

% set the limits in the edit boxes for the selected measurement PV
setEditValues(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function measTolList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measTolList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loTolEdit_Callback(hObject, eventdata, handles)
% hObject    handle to loTolEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loTolEdit as text
%        str2double(get(hObject,'String')) returns contents of loTolEdit as a double

% get the index of the PV selected
pvs = get(handles.measTolList, 'String');
str = pvs{get(handles.measTolList, 'Value')};
% get the new limit value
lolimit = str2double(get(hObject, 'String'));
% get the index in the full list of sp PVs
ll = strmatch(str, handles.meas.allmeasPVs);
% set the new sp upper limit
handles.meas.limits.low(ll) = lolimit;
handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function loTolEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loTolEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hiTolEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hiTolEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hiTolEdit as text
%        str2double(get(hObject,'String')) returns contents of hiTolEdit as a double

% get the index of the PV selected
pvs = get(handles.measTolList, 'String');
str = pvs{get(handles.measTolList, 'Value')};
% get the new limit value
uplimit = str2double(get(hObject, 'String'));
% get the index in the full list of sp PVs
ll = strmatch(str, handles.meas.allmeasPVs);
% set the new sp upper limit
handles.meas.limits.high(ll) = uplimit;
handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function hiTolEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hiTolEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in finalMeasList.
function finalMeasList_Callback(hObject, eventdata, handles)
% hObject    handle to finalMeasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns finalMeasList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from finalMeasList


% --- Executes during object creation, after setting all properties.
function finalMeasList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finalMeasList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close measFig.
function measFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to measFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.measFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
   uiresume(handles.measFig);
else
   % The GUI is no longer waiting, just close it
   delete(handles.measFig);
end



% --- Executes on button press in refOrbitCbx.
function refOrbitCbx_Callback(hObject, eventdata, handles)
% hObject    handle to refOrbitCbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of refOrbitCbx

% --- Executes on button press in lmtsFromDevBtn.
function lmtsFromDevBtn_Callback(hObject, eventdata, handles)
% hObject    handle to lmtsFromDevBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the index of the actPV selected
pvs = get(handles.measTolList, 'String');
pvs = fbStripEDefFromPVs(pvs);

str{1} = pvs{get(handles.measTolList, 'Value')};

% get the new upper limit value
pv = fbAddToPVNames(str, '.HOPR');
uplimit = lcaGet(pv);
% get the index in the full list of act PVs
ll = strmatch(str, handles.meas.allmeasPVs);
% set the new act upper limit
handles.meas.limits.high(ll) = uplimit;
set(handles.hiTolEdit, 'String', num2str(uplimit));

% get the new lower limit value
pv = fbAddToPVNames(str, '.LOPR');
lolimit = lcaGet(pv);
% get the index in the full list of act PVs
ll = strmatch(str, handles.meas.allmeasPVs);
% set the new act upper limit
handles.meas.limits.low(ll) = lolimit;
set(handles.loTolEdit, 'String', num2str(lolimit));

handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% we're done with this window, store data changes
% (we just assume there were changes)
config = getappdata(0, 'Config_structure');
config.meas.PVs = handles.meas.PVs;
config.meas.nummeasPVs = length(handles.meas.chosenmeasPVs);

%write changes to softIOC
fbSoftIOCFcn('PutMeasInfo',handles.meas);

config.meas = handles.meas;
config.configchanged = handles.configchanged;
setappdata(0,'Config_structure',config);

%resume - outputFcn will delete the figure and close dialog
uiresume(handles.measFig);


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%resume - outputFcn will delete the figure and close dialog
uiresume(handles.measFig);

function dsprEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dsprEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dsprEdit as text
%        str2double(get(hObject,'String')) returns contents of dsprEdit as a double
% get the index of the PV selected
pvs = get(handles.measTolList, 'String');
str{1} = pvs{get(handles.measTolList, 'Value')};
% get the new limit value
dspr = str2double(get(hObject, 'String'));
% get the index in the full list of sp PVs
ll = strmatch(str, handles.meas.allmeasPVs);
% set the new sp upper limit
handles.meas.dispersion(ll) = dspr;
handles.softIOCchanged = 1;
%update the finalactuator listbox
setFinalBox(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dsprEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsprEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


