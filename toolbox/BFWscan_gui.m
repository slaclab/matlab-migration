function varargout = BFWscan_gui(varargin)
% BFWSCAN_GUI M-file for BFWscan_gui.fig
%      BFWSCAN_GUI, by itself, creates a new BFWSCAN_GUI or raises the existing
%      singleton*.
%
%      H = BFWSCAN_GUI returns the handle to a new BFWSCAN_GUI or the handle to
%      the existing singleton*.
%
%      BFWSCAN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BFWSCAN_GUI.M with the given input arguments.
%
%      BFWSCAN_GUI('Property','Value',...) creates a new BFWSCAN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BFWscan_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BFWscan_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BFWscan_gui

% Last Modified by GUIDE v2.5 17-Feb-2009 15:01:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BFWscan_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @BFWscan_gui_OutputFcn, ...
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

end

% --- Executes just before BFWscan_gui is made visible.
function BFWscan_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BFWscan_gui (see VARARGIN)

global abortRequest

abortRequest = false;

% Choose default command line output for BFWscan_gui
handles.output = hObject;

handles.minSlot      =     1;
handles.maxSlot      =    33;
handles.wire         =   'X';
handles.slot         =     1;
handles.ini_startPos =  -250;
handles.ini_finalPos =   250;
handles.ini_stepSize =    50;
handles.min_Energy   =     3.0; % GeV
handles.BeamEnergyPV = 'BEND:DMP1:400:BACT';

set ( handles.X_MULTIPLE_UNITS_SELECT,     'Value',   0  );
set ( handles.Y_MULTIPLE_UNITS_SELECT,     'Value',   0  );
set ( handles.START_MULTIPLE_UNITS_SELECT, 'String',  '' );
set ( handles.END_MULTIPLE_UNITS_SELECT,   'String',  '' );

countSelectedUnits ( handles );

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BFWscan_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


% --- Outputs from this function are returned to the command line.
function varargout = BFWscan_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

% --- Executes on button press in START_BTN.
function START_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to START_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global abortRequest

state = get ( hObject, 'String' );

if ( strcmp ( state, 'start' ) )
    set ( hObject, 'String', 'stop' );
    refresh;
    abortRequest = false;
else
    abortRequest = true;
    set ( hObject, 'String', 'Aborting' );
    refresh;
    return;
end

foundSlot    = true;

while ( foundSlot && ~abortRequest )
    [ foundSlot, slot, wire ] = getNextBFW ( handles );

    if ( foundSlot && ~abortRequest )
%        fprintf ( 'running BFW%2.2d-%s Wire\n', slot, wire );

        startPos = str2double ( get ( handles.LOWER_RANGE_LIMIT_VALUE, 'String' ) );
        finalPos = str2double ( get ( handles.UPPER_RANGE_LIMIT_VALUE, 'String' ) );
        stepSize = str2double ( get ( handles.STEP_SIZE_VALUE,         'String' ) );

%        new_result = test_scanBFW ( slot, wire, startPos, finalPos, stepSize, 'reportStatus', handles );
        new_result = scanBFW_8figs ( slot, wire, startPos, finalPos, stepSize, 'reportStatus', handles );
        
        set ( handles.INFO_AREA, 'String', '' );

        if ( ~abortRequest )
            set ( handles.( sprintf ( 'BFW_%s_%2.2d_SELECT', wire, slot ) ), 'Value', 0 );
        end
    end
end

set ( hObject, 'String', 'start' );

countSelectedUnits ( handles );

refresh;

end


function ok = checkBeamEnergy ( handles )

handles.BeamEnergy      = lcaGet ( handles.BeamEnergyPV );    % GeV

if ( handles.BeamEnergy < handles.min_Energy )
    set ( handles.DISABLED_MSG, 'String', ...
        sprintf ( 'Panel Disabled: BEAM ENERGY %4.1f GeV (<%4.1f GeV)', ...
        handles.BeamEnergy, handles.min_Energy ) );
    ok = false;
    set ( handles.DISABLED_MSG, 'Visible', 'On' );
else
    ok = true;
    set ( handles.DISABLED_MSG, 'Visible', 'Off' );
end

end


function selectedUnits = countSelectedUnits ( handles )

selectedUnits = 0;

beamEnergyOK = checkBeamEnergy ( handles );

for slot = handles.minSlot : handles.maxSlot
    if ( get ( handles.( sprintf ( 'BFW_X_%2.2d_SELECT', slot ) ), 'Value' ) )
        selectedUnits = selectedUnits + 1;
    end
    
    if ( get ( handles.( sprintf ( 'BFW_Y_%2.2d_SELECT', slot ) ), 'Value' ) )
        selectedUnits = selectedUnits + 1;
    end
    
    if ( selectedUnits && beamEnergyOK )
        set ( handles.START_BTN, 'Visible', 'On' );
    else
        set ( handles.START_BTN, 'Visible', 'Off' );
    end
end

end


function UPPER_RANGE_LIMIT_VALUE_Callback(hObject, eventdata, handles)
% hObject    handle to UPPER_RANGE_LIMIT_VALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LOWER_RANGE_LIMIT_VALUE as text
%        str2double(get(hObject,'String')) returns contents of LOWER_RANGE_LIMIT_VALUE as a double


% --- Executes during object creation, after setting all properties.

end


% --- Executes during object creation, after setting all properties.
function UPPER_RANGE_LIMIT_VALUE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UPPER_RANGE_LIMIT_VALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function LOWER_RANGE_LIMIT_VALUE_Callback(hObject, eventdata, handles)
% hObject    handle to LOWER_RANGE_LIMIT_VALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LOWER_RANGE_LIMIT_VALUE as text
%        str2double(get(hObject,'String')) returns contents of LOWER_RANGE_LIMIT_VALUE as a double


% --- Executes during object creation, after setting all properties.

end


function LOWER_RANGE_LIMIT_VALUE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LOWER_RANGE_LIMIT_VALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function STEP_SIZE_VALUE_Callback(hObject, eventdata, handles)
% hObject    handle to STEP_SIZE_VALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of STEP_SIZE_VALUE as text
%        str2double(get(hObject,'String')) returns contents of STEP_SIZE_VALUE as a double
end


% --- Executes during object creation, after setting all properties.
function STEP_SIZE_VALUE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STEP_SIZE_VALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in X_WIRE_SELECTOR.
function X_WIRE_SELECTOR_Callback(hObject, eventdata, handles)
% hObject    handle to X_WIRE_SELECTOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of X_WIRE_SELECTOR

setSelectMultipleUnitsFields ( handles );

end


% --- Executes on button press in Y_WIRE_SELECTOR.
function Y_WIRE_SELECTOR_Callback(hObject, eventdata, handles)
% hObject    handle to Y_WIRE_SELECTOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Y_WIRE_SELECTOR

setSelectMultipleUnitsFields ( handles );

end


% --- Executes on button press in BFW_?_?/_SELECT.
function Unit_Select_Callback(hObject, eventdata, handles,wire,slot)
% hObject    handle to BFW_X_01_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BFW_X_01_SELECT

units = countSelectedUnits ( handles );
fprintf ( 'Unit_Select_Callback called. wire: %s, slot: %2.2d. (%d selected now)\n', wire, slot, units );

end


% --- Executes on button press in X_MULTIPLE_UNITS_SELECT.
function X_MULTIPLE_UNITS_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to X_MULTIPLE_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of X_MULTIPLE_UNITS_SELECT

end


% --- Executes on button press in Y_MULTIPLE_UNITS_SELECT.
function Y_MULTIPLE_UNITS_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to Y_MULTIPLE_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Y_MULTIPLE_UNITS_SELECT

end


function START_MULTIPLE_UNITS_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to START_MULTIPLE_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of START_MULTIPLE_UNITS_SELECT as text
%        str2double(get(hObject,'String')) returns contents of START_MULTIPLE_UNITS_SELECT as a double

Start = str2double ( get ( handles.START_MULTIPLE_UNITS_SELECT,   'String' ) );

if ( Start < 1 || Start > 33 )
    Start = 1;
    set ( handles.START_MULTIPLE_UNITS_SELECT,   'String', sprintf ( '%d', Start ) );
end

end


% --- Executes during object creation, after setting all properties.
function START_MULTIPLE_UNITS_SELECT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to START_MULTIPLE_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function END_MULTIPLE_UNITS_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to END_MULTIPLE_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of END_MULTIPLE_UNITS_SELECT as text
%        str2double(get(hObject,'String')) returns contents of END_MULTIPLE_UNITS_SELECT as a double

End   = str2double ( get ( handles.END_MULTIPLE_UNITS_SELECT,   'String' ) );

if ( End < 1 || End > 33 )
    End = 33;
    set ( handles.END_MULTIPLE_UNITS_SELECT,   'String', sprintf ( '%d', End ) );
end

end


% --- Executes during object creation, after setting all properties.
function END_MULTIPLE_UNITS_SELECT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to END_MULTIPLE_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in MULTI_UNITS_SELECT.
function MULTI_UNITS_SELECT_Callback(hObject, eventdata, handles)
% hObject    handle to MULTI_UNITS_SELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf ( 'MULTI_UNITS_SELECT_Callback called.\n' );

Xwire = get ( handles.X_MULTIPLE_UNITS_SELECT,     'Value'  );
Ywire = get ( handles.Y_MULTIPLE_UNITS_SELECT,     'Value'  );
Start = str2double ( get ( handles.START_MULTIPLE_UNITS_SELECT, 'String' ) );
End   = str2double ( get ( handles.END_MULTIPLE_UNITS_SELECT,   'String' ) );

deselectAllUnits ( handles );

if ( End >= Start )
    for s = Start : End
        if ( Xwire )
            set ( handles.( sprintf ( 'BFW_X_%2.2d_SELECT', s ) ), 'Value', 1 );
        end
        
        if ( Ywire )
            set ( handles.( sprintf ( 'BFW_Y_%2.2d_SELECT', s ) ), 'Value', 1 );
        end
    end
end

set ( handles.X_MULTIPLE_UNITS_SELECT,     'Value',  0  );
set ( handles.Y_MULTIPLE_UNITS_SELECT,     'Value',  0  );
set ( handles.START_MULTIPLE_UNITS_SELECT, 'String', '' );
set ( handles.END_MULTIPLE_UNITS_SELECT,   'String', '' );

countSelectedUnits ( handles );

end


function deselectAllUnits ( handles )

for slot = handles.minSlot : handles.maxSlot
    set ( handles.( sprintf ( 'BFW_X_%2.2d_SELECT', slot ) ), 'Value', 0 );
    set ( handles.( sprintf ( 'BFW_Y_%2.2d_SELECT', slot ) ), 'Value', 0 );
end

countSelectedUnits ( handles );

end


function selectAllUnits ( handles )

for slot = handles.minSlot : handles.maxSlot
    set ( handles.( sprintf ( 'BFW_X_%2.2d_SELECT', slot ) ), 'Value', 1 );
    set ( handles.( sprintf ( 'BFW_Y_%2.2d_SELECT', slot ) ), 'Value', 1 );
end

countSelectedUnits ( handles );

end


function [ found, slot, wire ] = getNextBFW ( handles )

found = false;
wire  = '';

for slot = handles.minSlot : handles.maxSlot    
    if ( get ( handles.( sprintf ( 'BFW_X_%2.2d_SELECT', slot ) ), 'Value' ) )
        found = true;
        wire  = 'X';
        return;
    end
        
    if ( get ( handles.( sprintf ( 'BFW_Y_%2.2d_SELECT', slot ) ), 'Value' ) )
        found = true;
        wire  = 'Y';
        return;
    end
end

end


% --- Executes on button press in MULTI_UNITS_CLEAR.
function MULTI_UNITS_CLEAR_Callback(hObject, eventdata, handles)
% hObject    handle to MULTI_UNITS_CLEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

deselectAllUnits ( handles );

end

% --- Executes on button press in MULTI_UNITS_SELECT_ALL.
function MULTI_UNITS_SELECT_ALL_Callback(hObject, eventdata, handles)
% hObject    handle to MULTI_UNITS_SELECT_ALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectAllUnits ( handles );

end


% --- Executes on button press in BYKIK_PERMIT_BOX.
function BYKIK_PERMIT_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to BYKIK_PERMIT_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BYKIK_PERMIT_BOX

global result;

result.BYKIKPermit = get ( hObject, 'Value' );

end


% --- Executes on button press in WIRE_CARD_PERMIT_BOX.
function WIRE_CARD_PERMIT_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to WIRE_CARD_PERMIT_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WIRE_CARD_PERMIT_BOX

global result;

result.WireCardPermit = get ( hObject, 'Value' );

end


% --- Executes on button press in ALIGN_BFW_BOX.
function ALIGN_BFW_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGN_BFW_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ALIGN_BFW_BOX

global result;

result.alignBFW = get ( hObject, 'Value' );

end


% --- Executes on button press in PRINT_TO_ELOG_BOX.
function PRINT_TO_ELOG_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to PRINT_TO_ELOG_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PRINT_TO_ELOG_BOX

global result;

result.printTo_e_Log = get ( hObject, 'Value' );

end


% --- Executes on button press in GIRDER_MOTION_PERMIT_BOX.
function GIRDER_MOTION_PERMIT_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to GIRDER_MOTION_PERMIT_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GIRDER_MOTION_PERMIT_BOX

global result;

result.motionPermit = get ( hObject, 'Value' );

end


% --- Executes on button press in IGNORE_CHARGE_BOX.
function IGNORE_CHARGE_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to IGNORE_CHARGE_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IGNORE_CHARGE_BOX

global result;

result.ignoreCharge = get ( hObject, 'Value' );

end


% --- Executes on button press in USE_ORBIT_THRESHOLD_BOX.
function USE_ORBIT_THRESHOLD_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ORBIT_THRESHOLD_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ORBIT_THRESHOLD_BOX

global result;

result.useTrajectory = get ( hObject, 'Value' );

end


% --- Executes when user attempts to close checkOP_gui.
function CloseRequestFcn ( hObject, eventdata, handles )

global result;

fprintf ( 'Closing  moveUndulatorQuadrupole_gui.\n' );

if ( isfield ( result, 'PLTfig' ) && ishandle ( result.PLTfig ) )
    delete ( result.PLTfig );
end

util_appClose ( hObject );
lcaClear ( );

end

