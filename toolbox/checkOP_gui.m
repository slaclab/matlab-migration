function varargout = checkOP_gui(varargin)
% CHECKOP_GUI M-file for checkOP_gui.fig
%      CHECKOP_GUI, by itself, creates a new CHECKOP_GUI or raises the existing
%      singleton*.
%
%      H = CHECKOP_GUI returns the handle to a new CHECKOP_GUI or the handle to
%      the existing singleton*.
%
%      CHECKOP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKOP_GUI.M with the given input arguments.
%
%      CHECKOP_GUI('Property','Value',...) creates a new CHECKOP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before checkOP_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to checkOP_gui_OpeningFcn via varargin.
%
%      CHECKOP_GUI('Xwin32') creates a new CHECKOP_GUI or raises the
%      existing singleton*.  It does correct window positioning under the
%      Xwin32 x-windows server.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%      
%      This GUI checks compliance of critical LCLS acclerator parameters
%      with Operating Point (OP) requirements.
%
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by HDN on 7-July-2010

% Edit the above text to modify the response to help checkOP_gui

% Last Modified by GUIDE v2.5 25-Feb-2008 09:37:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checkOP_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @checkOP_gui_OutputFcn, ...
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

% --- Executes just before checkOP_gui is made visible.
function checkOP_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to checkOP_gui (see VARARGIN)

global timerRunning;
global timerRestart;
global timerDelay;
global timerData;
global debug;
global verbose;
global Xwin32;
global OPctrl;
global SaveRestoreWindowExists;

if ( nargin > 3 && strcmp ( varargin { 1 } , 'Xwin32' ) )
    Xwin32 = true; 
else
    Xwin32 = false;
end

handles.obj.Window                             = hObject;
handles.obj.Column { 1 }.TAGbase               = 'LINE';
handles.obj.Column { 2 }.TAGbase               = 'PARAMETER';
handles.obj.Column { 3 }.TAGbase               = 'ACTUAL';
handles.obj.Column { 4 }.TAGbase               = 'TARGET';
handles.obj.Column { 5 }.TAGbase               = 'TOL';
handles.obj.Column { 6 }.TAGbase               = 'UNIT';
handles.obj.Column { 7 }.TAGbase               = 'COMMENT';
handles.obj.rowSep                             =  5;
handles.startWindowAtX                         = 10;  % %
handles.startWindowAtY                         = 50;  % %
timerRunning                                   = false;
timerRestart                                   = false;
timerDelay                                     = 10;      % sec
timerData.hObject                              = hObject;
debug                                          = false;
SaveRestoreWindowExists                        = false;
%handles.SaveRestoreFolder                      = '/home/physics/nuhn/wrk/matlab/SaveRestore_B/';
%handles.SaveRestoreFolder                      = '/usr/local/lcls/tools/matlab/checkOP/SaveFiles/';
handles.SaveRestoreFolder                      = '/u1/lcls/matlab/checkOP/SaveFiles/';
verbose                                        = true;

Visible = get ( hObject, 'Visible' );

if ( strcmp ( Visible, 'on' ) )
    delete ( hObject );
    error ( 'Previous window still open.' );
end
    
removeSpareObjects ( hObject, handles );

% Choose default command line output for autoButtonTest_gui
handles.output    = hObject;

if ( verbose )
    fprintf ( 'Starting checkOP_gui. Author: Heinz-Dieter Nuhn <nuhn@slac.stanford.edu>\n');
end

if ( debug )
    fprintf ( 'DEBUG printout activated!\n' );
end

set ( handles.DISPLAY_PVS, 'Value', false );
set ( handles.SAVE_RESTORE, 'Visible', 'Off' );
set ( handles.LAST_SAVE_RESTORE_CONFIG, 'Visible', 'Off' );

fprintf ( 'Initializing structures ...' );

handles.OP        = checkOperatingPoint;
handles.maxRows   = OPctrl.items;
handles.dspRows   = handles.maxRows;

lastRowY = calculateLastRowY ( handles, 1, handles.maxRows );

% Resize figure window to fit all required rows.
util_adjustWindow ( 'resizeWindow', hObject, 'pixels', -lastRowY );

% Add required rows
for k = 1 : length ( handles.obj.Column )
   handles = addRows ( handles, k, 1, handles.maxRows );
end

%Make all rows invisible during the initialization process.
handles = selectRows ( handles, 0 );

fprintf ( ' done!\n' );

% Update handles structure
guidata ( hObject, handles );

% UIWAIT makes checkOP_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


function removeSpareObjects ( hObject, handles )
% removeSpareObjects removes all rows but the first row of the
%           table in the gui figure.
%

Columns     = handles.obj.Column;
nColumns    = length ( Columns );

if ( nColumns < 1 )
    return;
end

allObjects  = findobj ( hObject );
nObjects    = length ( allObjects );

for j = 1 : nObjects
    obj = allObjects ( j );
        
    if ( obj ~= hObject )
        TAG     = get ( obj, 'Tag' );
        nTAG    = length ( TAG );
        TAGbase = TAG ( 1 : nTAG - 3 );
        row     = str2double ( TAG ( nTAG - 1 : nTAG ) );

        for k = 1 : nColumns
            if ( strcmp ( TAGbase, Columns { k }.TAGbase ) && row > 1 )
                fprintf ( 'deleting obj %f: TAG %s\n', obj, TAG );
                delete ( obj );
                break;
            end
        end
    end
end

end


function lastRowY = calculateLastRowY ( handles, cloneRow, rows )
% lastRowY calculates what would be the position of the bottom most row
%       in screen pixels after adding (rows - 1) to cloneRow;
%

thisObj   = handles.( sprintf ( '%s_%2.2d', handles.obj.Column { 1 }.TAGbase, cloneRow ) );
Position  = util_adjustWindow ( 'getPosition', thisObj, 'pixels' );
startPos  = Position ( 2 );
height    = Position ( 4 );
rowPosInc = height + handles.obj.rowSep;
lastRowY  = startPos - ( rows + 1 - cloneRow ) * rowPosInc;

end


function handles = addRows ( handles, column, cloneRow, rows )
% addRows generates display objects (rows) for one table column. It requires
%       that the first row (cloneRow) exists. It will clone the properties of
%       that inital cloneRow for all following rows.
%       The TAGbases of the columns need to be defined in
%           obj.Column { column }.TAGbase
%

k = column;
j = cloneRow;
obj = handles.obj;
cloneObj                               = handles.( sprintf ( '%s_%2.2d', obj.Column { k }.TAGbase, j ) );
obj.Column { k }.property { j }.handle = cloneObj;
Position                               = util_adjustWindow ( 'getPosition', cloneObj, 'pixels' );
obj.Column { k }.rowPos                = Position ( 1 );
obj.Column { k }.startColumnPos        = Position ( 2 );
obj.Column { k }.width                 = Position ( 3 );
obj.Column { k }.height                = Position ( 4 );
obj.rowPosInc                          = obj.Column { k }.height + obj.rowSep;
obj.Column { k }.Style                 = get ( cloneObj, 'Style' );
obj.Column { k }.Callback              = get ( cloneObj, 'Callback' );

cloneProperties = get ( cloneObj );

dontClone = { 'BeingDeleted', 'Extent', 'Type', 'Style', 'Units', 'Tag', 'Position', 'String', 'Callback' };

for j = 1 : length ( dontClone )
    cloneProperties = rmfield ( cloneProperties, dontClone { j } );
end

for j = cloneRow + 1 : rows
    newObj                                 = uicontrol ( 'Style', 'text', 'Units', 'characters' );
    obj.Column { k }.property { j }.handle = newObj;
    
    set ( newObj, cloneProperties );
    set ( newObj, 'Tag',      sprintf ( '%s_%2.2d', obj.Column { k }.TAGbase, j ) );
    set ( newObj, 'String',   sprintf ( '%2.2d', j ) );

    Callback  = obj.Column { k }.Callback;
    nCallback = length ( Callback );
    
    if ( nCallback && strcmp ( Callback ( nCallback - 2 : nCallback ), ',1)' ) )
        set ( newObj, 'Callback', sprintf ( '%s%d)', Callback ( 1 : nCallback - 2 ), j ) );
    else
        set ( newObj, 'Callback', '' );
    end
    
    Position ( 1 )                         = obj.Column { k }.rowPos;
    Position ( 2 )                         = obj.Column { k }.startColumnPos - ( j - cloneRow ) * obj.rowPosInc;
    Position ( 3 )                         = obj.Column { k }.width;
    Position ( 4 )                         = obj.Column { k }.height;

    util_adjustWindow ( 'setPosition', newObj, 'pixels', Position );

    handles.( get ( newObj, 'Tag' ) )      = newObj;       
end

handles.obj = obj;

end


function handles = selectRows ( handles, rows )
% selectRows function for checkOP_gui
%   This function sets the 'Visible' field of the first 'rows'
%   to 'On'. For any existing additional rows it will be set to 'Off'.
%   It limits the row display to 'rows' rows. The function depends on
%   the parameter handles.maxRows that needs to be updated whenever
%   the number of rows is changed in the GUI .fig file checkOP_gui.fig.

global debug

if ( debug )
    fprintf ( 'sectectRows %d; dspRows = %d\n', rows, handles.dspRows );
end

rows = max ( 0, min ( handles.maxRows, rows ) );

if ( handles.dspRows == rows )
    return
end

removeRows = handles.dspRows - rows;
nCOL       = length ( handles.obj.Column );

if ( removeRows > 0 )
    for j = rows + 1 : handles.dspRows
        for k = 1 : nCOL
            obj = handles.( sprintf ( '%s_%2.2d', handles.obj.Column { k }.TAGbase, j ) );
            set ( obj, 'Visible', 'Off' );
        end
    end
else
    for j = handles.dspRows + 1 : rows 
        for k = 1 : nCOL
            obj = handles.( sprintf ( '%s_%2.2d', handles.obj.Column { k }.TAGbase, j ) );
            set ( obj, 'Visible', 'On' );
        end
    end  
end

handles.dspRows = rows;

end


% --- Outputs from this function are returned to the command line.
function varargout = checkOP_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global OPctrl;

% Get default command line output from handles structure
varargout{1} = handles.output;

fprintf ( 'Filling structures      ...\n' );

handles.OP        = checkOperatingPoint ( handles.OP );
handles           = refresh ( handles );
handles           = selectRows ( handles, OPctrl.items );

util_adjustWindow ( 'positionWindow', hObject, handles.startWindowAtX, handles.startWindowAtY );

%setSingleShotRefreshMode ( handles );
setContinuousRefreshMode ( handles );

% Update handles structure
guidata ( hObject, handles );

fprintf ( '                        ... done!\n' );

set ( handles.SAVE_RESTORE, 'Visible', 'On' );

end


% --- Executes on button press in SINGLE_SHOT_REFRESH_PUSHBUTTON.
function SINGLE_SHOT_REFRESH_PUSHBUTTON_Callback ( hObject, eventdata, handles )
% hObject    handle to SINGLE_SHOT_REFRESH_PUSHBUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global debug;

if ( debug )
    fprintf ( 'SINGLE_SHOT_REFRESH_PUSHBUTTON_Callback called.\n' );
end

handles.OP = checkOperatingPoint ( handles.OP );
handles    = refresh ( handles );

% Update handles structure
guidata ( hObject, handles );

end


function REFRESH_DELAY_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to REFRESH_DELAY_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REFRESH_DELAY_EDIT as text
%        str2double(get(hObject,'String')) returns contents of REFRESH_DELAY_EDIT as a double

global timerDelay;
global debug;

new_timerDelay = round ( str2double ( get ( hObject, 'String' ) ) );

if ( debug )
    fprintf ( 'Got new timer delay: %.0f\n', new_timerDelay );
end

if ( new_timerDelay >= 1 && new_timerDelay <= 3600 )
    timerDelay = new_timerDelay;
end

setContinuousRefreshMode ( handles );

end


% --- Executes during object creation, after setting all properties.
function REFRESH_DELAY_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REFRESH_DELAY_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function setSingleShotRefreshMode ( handles )

global timerObj;
global timerRestart;
global timerRunning;
global debug

if ( debug )
    fprintf ( 'setSingleShotRefreshMode called\n' );
end

set ( handles.REFRESH_DELAY_LABEL,            'Visible',  'Off' );
set ( handles.REFRESH_DELAY_EDIT,             'Visible',  'Off' );
set ( handles.REFRESH_DELAY_UNIT_TEXT,        'Visible',  'Off' );
set ( handles.REFRESH_MODE_TEXT,              'String',   'Present Refresh Mode: Single Shot' );
set ( handles.REFRESH_MODE_PUSHBUTTON,        'String',   'Select Continuous Refresh Mode' );
set ( handles.SINGLE_SHOT_REFRESH_PUSHBUTTON, 'Visible', 'On'  );

if ( timerRunning )
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
    timerRunning = false;
end

timerRestart = false;

end


function setContinuousRefreshMode ( handles )

global timerObj;
global timerDelay;
global timerRestart;
global timerRunning;
global timerData;
global debug

if ( debug )
    fprintf ( 'setContinousRefreshMode called.\n' );
end

set ( handles.REFRESH_DELAY_LABEL,            'Visible', 'On'  );
set ( handles.REFRESH_DELAY_EDIT,             'Visible', 'On'  );
set ( handles.REFRESH_DELAY_EDIT,             'String',   sprintf ( '%.0f', timerDelay ) );
set ( handles.REFRESH_DELAY_UNIT_TEXT,        'Visible', 'On'  );
set ( handles.REFRESH_MODE_TEXT,              'String',  'Present Refresh Mode: Continuous' );
set ( handles.REFRESH_MODE_PUSHBUTTON,        'String',  'Select Single Shot Refresh Mode' );
set ( handles.SINGLE_SHOT_REFRESH_PUSHBUTTON, 'Visible', 'Off' );

if ( timerRunning )
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
end

if ( debug )
    fprintf ( 'Setting Timer Delay to %.0f sec.\n', timerDelay );
end

timerObj     = timer ( 'TimerFcn', @Timer_Callback_fcn, 'Period', timerDelay, 'ExecutionMode', 'fixedRate' );
timerRestart = true;

if ( debug )
    fprintf ( 'Starting Timer\n' );
end

timerData.handles = handles;start ( timerObj );
timerRunning = true;

end


% --- Executes when timer completes. Used for periodic refreshes.
function Timer_Callback_fcn ( obj, event )

global timerData;
global debug;

if ( debug )
    fprintf ( 'Timer_Callback_fcn called\n' );
end

handles    = timerData.handles;
hObject    = timerData.hObject;

handles.OP = checkOperatingPoint ( handles.OP );
handles    = refresh ( handles );

% Update handles structure
guidata ( hObject, handles );

timerData.handles = handles;

if ( debug )
    fprintf ( '%s event occurred at %s\n', event.Type, datestr ( event.Data.time ) );
    get ( obj );
end

end


% --- Executes during object creation, after setting all properties.
function SINGLE_SHOT_REFRESH_PUSHBUTTON_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SINGLE_SHOT_REFRESH_PUSHBUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end


% --- Executes on button press in DISPLAY_PVS.
function DISPLAY_PVS_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAY_PVS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DISPLAY_PVS

global OPctrl;
global debug;

display_PVS = get ( hObject, 'Value' );
hdrObject   = handles.ACTUAL_TITLE;

for j = 1 : OPctrl.items
    btnObject   = ( handles.( sprintf ( 'ACTUAL_%2.2d', j ) ) );
    btnPosition = get ( btnObject, 'Position' );
    item        = OPctrl.order ( j );

    if ( display_PVS )
        set (   hObject, 'String', 'Display Actuals' );
        set ( btnObject, 'String', handles.OP { item }.PV );
        set ( hdrObject, 'Enable', 'inactive' );
        set ( hdrObject, 'String', 'Actual PV' );
        btnPosition ( 2 ) = btnPosition ( 2 ) + 0.2;
        btnPosition ( 3 ) = btnPosition ( 3 ) + 1;
        set ( btnObject, 'Position', btnPosition );
        set ( btnObject, 'FontSize', 7.0 );
        set ( btnObject, 'Style',    'edit' );
        set ( btnObject, 'Callback', 'checkOP_gui(''PV_Callback'',gcbo,[],guidata(gcbo),1)' );
        set ( btnObject, 'ForegroundColor', 'black' );
    else
        set (   hObject, 'String', 'Display PVs' );
        set ( btnObject, 'String', sprintf ( handles.OP { item }.Vfmt, handles.OP { item }.Actual ) );
        set ( hdrObject, 'Enable', 'on' );
        set ( hdrObject, 'String', 'Actual' );
        btnPosition ( 2 ) = btnPosition ( 2 ) - 0.2;
        btnPosition ( 3 ) = btnPosition ( 3 ) - 1;
        set ( btnObject, 'Position', btnPosition );
        set ( btnObject, 'FontSize', 10.0 );
        set ( btnObject, 'Style',    'text' );
        Callback = sprintf ( 'checkOP_gui(''ACTUAL_Callback'',gcbo,[],guidata(gcbo),%d)', j ); 
        
        if ( debug )
            fprintf ( 'Setting Callback to "%s".\n', Callback );
        end
        
        set ( btnObject, 'Callback', Callback );
        setActualColor ( btnObject, handles.OP { item } );
    end
end

end


% --- Executes on button press in DISPLAY_OPV_PVS.
function DISPLAY_OPV_PVS_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAY_OPV_PVS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DISPLAY_OPV_PVS

global OPctrl;
global debug;

%TARGETedit = strcmp ( get ( handles.TARGET_01, 'Style' ), 'edit' );
%
%if ( TARGETedit  )
%    set ( hObject, 'Value', 1.0 );
%end

displayOPV_PVS = get ( hObject, 'Value' );
hdrObject      = handles.TARGET_TITLE;

for j = 1 : OPctrl.items
    btnObject   = ( handles.( sprintf ( 'TARGET_%2.2d', j ) ) );
    btnPosition = get ( btnObject, 'Position' );
    item        = OPctrl.order ( j );

    if ( displayOPV_PVS )
        set (   hObject, 'String', 'Display Targets' );
        set ( btnObject, 'String', handles.OP { item }.OPV_PV );
        set ( hdrObject, 'Enable', 'inactive' );
        set ( hdrObject, 'String', 'Target PV' );
        btnPosition ( 2 ) = btnPosition ( 2 ) + 0.2;
        btnPosition ( 3 ) = btnPosition ( 3 ) + 1;
        set ( btnObject, 'Position', btnPosition );
        set ( btnObject, 'FontSize', 7.0 );
        set ( btnObject, 'Style',    'edit' );
        set ( btnObject, 'Callback', 'checkOP_gui(''OPV_PV_Callback'',gcbo,[],guidata(gcbo),1)' );
    else
        set (   hObject, 'String', 'Display PVs' );
        set ( btnObject, 'String', sprintf ( handles.OP { item }.Vfmt, handles.OP { item }.Target ) );
        set ( hdrObject, 'Enable', 'on' );
        set ( hdrObject, 'String', 'Target' );
        btnPosition ( 2 ) = btnPosition ( 2 ) - 0.2;
        btnPosition ( 3 ) = btnPosition ( 3 ) - 1;
        set ( btnObject, 'Position', btnPosition );
        set ( btnObject, 'FontSize', 10.0 );
        set ( btnObject, 'Style',    'text' );
        Callback = sprintf ( 'checkOP_gui(''TARGET_Callback'',gcbo,[],guidata(gcbo),%d)', j ); 
        
        if ( debug )
            fprintf ( 'Setting Callback to "%s".\n', Callback );
        end
        
        set ( btnObject, 'Callback', Callback );
    end
end

end


% --- Executes on button press in TOGGLE_COMMENT_COLUMN.
function TOGGLE_COMMENT_COLUMN_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAY_OPV_PVS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DISPLAY_OPV_PVS

global OPctrl;

COMMENTedit    = strcmp ( get ( handles.COMMENT_01, 'Style' ), 'edit' );

if ( COMMENTedit  )
    set ( hObject, 'Value', 0.0 );
end

displayComment = ~get ( hObject, 'Value' );

hdrObject      = handles.COMMENT_TITLE;

for j = 1 : OPctrl.items
    btnObject = ( handles.( sprintf ( 'COMMENT_%2.2d', j ) ) );
    item      = OPctrl.order ( j );

    if ( displayComment )
        set ( btnObject, 'String',        handles.OP { item }.Comment );
        set ( hObject,   'String',        'Display Timestamps' );
        set ( hObject,   'TooltipString', 'Display Timestamps instead of Comments' );
        set ( hdrObject, 'Enable',        'on' );
        set ( hdrObject, 'String',        'Comments' );
    else
        set ( btnObject, 'String',        handles.OP { item }.TS );
        set ( hObject,   'String',        'Display Comments' );
        set ( hObject,   'TooltipString', 'Display Comments instead of Timestamps' );
        set ( hdrObject, 'Enable',        'inactive' );
        set ( hdrObject, 'String',        'Timestamp (Actual)' );
    end
end

end


% --- Executes on callback in TARGET title.
function TARGET_TITLE_Callback (hObject, eventdata, handles )
% hObject    handle to the pressed TARGET key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global debug;
global OPctrl;

if ( debug )
    fprintf ('TARGET_TITLE_Callback called\n' );
end

TARGETedit = strcmp ( get ( handles.TARGET_01, 'Style' ), 'edit' );
btnDISOPV  = handles.DISPLAY_OPV_PVS;

for j    = 1 : OPctrl.items
    item = OPctrl.order ( j );

    if ( handles.OP { item }.Tar_editbl )
        btnObject   = ( handles.( sprintf ( 'TARGET_%2.2d', j ) ) );
        btnPosition = get ( btnObject, 'Position' );

        if ( TARGETedit )
            set ( btnObject, 'Style', 'text' );
            btnPosition ( 2 ) = btnPosition ( 2 ) - 0.2;
            set ( btnObject, 'Position', btnPosition );
            set ( btnObject, 'BackgroundColor', [ 0.7020, 0.7020, 0.7020 ] );
            set ( btnDISOPV, 'Visible', 'on' );
        else
            set ( btnObject, 'Style', 'edit' );
            btnPosition ( 2 ) = btnPosition ( 2 ) + 0.2;
            set ( btnObject, 'Position', btnPosition );
            set ( btnObject, 'BackgroundColor', [ 1.0000, 1.0000, 1.0000 ] );
            set ( btnDISOPV, 'Visible', 'off' );
        end
    end
end

end


% --- Executes on callback in TOL title.
function TOL_TITLE_Callback (hObject, eventdata, handles )
% hObject    handle to the pressed TOL key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global debug;
global OPctrl;

if ( debug )
    fprintf ('TOL_TITLE_Callback called\n' );
end

OP      = handles.OP;
TOLedit = strcmp ( get ( handles.TOL_01, 'Style' ), 'edit' );

if ( debug )
    fprintf ( 'TOL_TITLE_Callback: TOLedit = %d\n', TOLedit );
end

for j    = 1 : OPctrl.items
    item = OPctrl.order ( j );

    if ( handles.OP { item }.Toleditbl ) 
        if ( TOLedit && OP { item }.Tol ~= 0 )
            pm = OP { item }.Tolmode;
        else
            pm = '';
        end
    
        set ( handles.( sprintf ( 'TOL_%2.2d', j ) ), 'String', sprintf ( OP { item }.Tfmt, pm, OP { item }.Tol ) );        

        btnObject   = handles.( sprintf ( 'TOL_%2.2d', j ) );
        btnPosition = get ( btnObject, 'Position' );

        if ( TOLedit )
            set ( btnObject, 'Style', 'text' );
            btnPosition ( 2 ) = btnPosition ( 2 ) - 0.2;
            set ( btnObject, 'Position', btnPosition );
            set ( btnObject, 'BackgroundColor', [ 0.7020, 0.7020, 0.7020 ] );
        else
            set ( btnObject, 'Style', 'edit' );
            btnPosition ( 2 ) = btnPosition ( 2 ) + 0.2;
            set ( btnObject, 'Position', btnPosition );
            set ( btnObject, 'BackgroundColor', [ 1.0000, 1.0000, 1.0000 ] );
        end
    else
        pm = OP { item }.Tolmode;
    
        set ( handles.( sprintf ( 'TOL_%2.2d', j ) ), 'String', sprintf ( OP { item }.Tfmt, pm, OP { item }.Tol ) );        
    end
 end

end


% --- Executes on callback in COMMENT title.
function COMMENT_TITLE_Callback (hObject, eventdata, handles )
% hObject    handle to the pressed TARGET key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global debug;
global OPctrl;

if ( debug )
    fprintf ('COMMENT_TITLE_Callback called\n' );
end

COMMENTedit = strcmp ( get ( handles.COMMENT_01, 'Style' ), 'edit' );
bntCMNTTGL  = handles.TOGGLE_COMMENT_COLUMN;

for j    = 1 : OPctrl.items
    item = OPctrl.order ( j );

    if ( handles.OP { item }.Comeditbl )
        btnObject   = ( handles.( sprintf ( 'COMMENT_%2.2d', j ) ) );
        btnPosition = get ( btnObject, 'Position' );

        if ( COMMENTedit )
            set ( btnObject, 'Style', 'text' );
            btnPosition ( 2 ) = btnPosition ( 2 ) - 0.2;
            set ( btnObject, 'Position', btnPosition );
            set ( btnObject, 'BackgroundColor', [ 0.7020, 0.7020, 0.7020 ] );
            set ( bntCMNTTGL, 'Visible', 'on' );
        else
            set ( btnObject, 'Style', 'edit' );
            btnPosition ( 2 ) = btnPosition ( 2 ) + 0.2;
            set ( btnObject, 'Position', btnPosition );
            set ( btnObject, 'BackgroundColor', [ 1.0000, 1.0000, 1.0000 ] );
            set ( bntCMNTTGL, 'Visible', 'off' );
        end
    end
end

end


% --- Executes on callback in inactive titles.
function INACTIVE_TITLE_Callback (hObject, eventdata, handles )
% hObject    handle to the pressed TARGET key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global debug;

if ( debug )
    fprintf ('INACTIVE_TITLE_Callback called\n' );
end

end


function PV_Callback(hObject, eventdata, handles, val)
% hObject    handle to PV_nn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PV_nn as text
%        str2double(get(hObject,'String')) returns contents of PV_nn as a double

% --- Executes during object creation, after setting all properties.

global OPctrl;

item = OPctrl.order ( val );

set ( hObject, 'String', handles.OP { item }.PV );

end
    

function OPV_PV_Callback(hObject, eventdata, handles, val)
% hObject    handle to OPV_PV_nn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPV_PV_nn as text
%        str2double(get(hObject,'String')) returns contents of OPV_PV_nn as a double

% --- Executes during object creation, after setting all properties.

global OPctrl;

item = OPctrl.order ( val );

set ( hObject, 'String', handles.OP { item }.OPV_PV );

end
    

% --- Executes on key press in TARGET_xx.
function TARGET_Callback (hObject, eventdata, handles, val)
% hObject    handle to the pressed TARGET key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% val        integer - number of TARGET key pressed.

global debug;
global timerRunning;
global timerData;
global OPctrl;

if ( debug )
    fprintf ( 'TARGET_Callback called.\n' );
end

item      = OPctrl.order ( val );
newTarget = getValue ( hObject, handles.OP { item }.Target );

 if ( debug )
     fprintf ('TARGET_Callback for %2.2d: newTarget: %f; was %f\n', ...
         val, newTarget, handles.OP { item }.Target );
 end

if ( newTarget ~= handles.OP { item }.Target )
    handles.OP { item }.Target          = newTarget;
    handles.OP { item }.Target_modified = true;

    if ( debug )
        fprintf ('TARGET_Callback: TARGET_%2.2d was set to %f\n', val, handles.OP { item }.Target );
    end

    handles.OP = checkOperatingPoint ( handles.OP );
    
    activateChange;

    % refresh screen to so that the new TARGET value is correctly incorporated
    handles = refresh ( handles );

    % Update handles copy in timerData

    if ( timerRunning )
        timerData.handles = handles;

        if ( debug )
            fprintf ('TARGET_Callback: Updating timerData.handles.\n' );
        end
    end

    % Update handles structure
    guidata ( hObject, handles );
end

end


% --- Executes on key press in TOL_xx.
function TOL_Callback (hObject, eventdata, handles, val)
% hObject    handle to the pressed TOL key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% val        integer - number of TOL key pressed.

global debug;
global timerRunning;
global timerData;
global OPctrl;

if ( debug )
    fprintf ( 'TOL_Callback called.\n' );
end

item   = OPctrl.order ( val );
newTol = abs ( getValue ( hObject, handles.OP { item }.Tol ) );

if ( newTol ~= handles.OP { item }.Tol )
    handles.OP { item }.Tol          = newTol;
    handles.OP { item }.Tol_modified = true;

    if ( debug )
        fprintf ('TOL_Callback: TOL_%2.2d was set to %f\n', val, handles.OP { item }.Tol );
    end

    handles.OP = checkOperatingPoint ( handles.OP );
    activateChange;

    % refresh screen to so that the new TOL value is correctly incorporated
    handles = refresh ( handles );

    % Update handles copy in timerData

    if ( timerRunning )
        timerData.handles = handles;

        if ( debug )
            fprintf ('TOL_Callback: Updating timerData.handles.\n' );
        end
    end
end

% Update handles structure
guidata ( hObject, handles );

end


% --- Executes on key press in COMMENT_xx.
function COMMENT_Callback (hObject, eventdata, handles, val)
% hObject    handle to the pressed COMMENT key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% val        integer - number of COMMENT key pressed.

global debug;
global timerRunning;
global timerData;
global OPctrl;

if ( debug )
    fprintf ( 'COMMENT_Callback called.\n' );
end

item       = OPctrl.order ( val );
newComment = get ( hObject, 'String' );

if ( ~strcmp ( newComment, handles.OP { item }.Comment ) )
    handles.OP { item }.Comment          = newComment;
    handles.OP { item }.Comment_modified = true;

    if ( debug )
        fprintf ('COMMENT_Callback: COMMENT_%2.2d was set to "%s"\n', val, handles.OP { item }.Comment );
    end

    handles.OP = checkOperatingPoint ( handles.OP );

    % refresh screen to so that the new TARGET value is correctly incorporated
    handles = refresh ( handles );
    
    activateChange;

    % Update handles copy in timerData

    if ( timerRunning )
        timerData.handles = handles;

        if ( debug )
            fprintf ('COMMENT_Callback: Updating timerData.handles.\n' );
        end
    end

    % Update handles structure
    guidata ( hObject, handles );
end

end


function v = getValue ( hObject, default )

try
    v = str2double ( get ( hObject, 'String' ) );
catch
    v = default;
end

if ( isnan ( v ) )
    v = default;
end

end


function activateChange

lcaPut ( 'SIOC:SYS0:ML00:AO511', 1 );

end


function h = refresh ( handles )

global debug;
global OPctrl;

h       = handles;
OP      = h.OP;
TOLedit = strcmp ( get ( handles.TOL_01, 'Style' ), 'edit' );

if ( debug )
    fprintf ( 'refresh: TOLedit = %d\n', TOLedit );
end

displayComment = ~get ( handles.TOGGLE_COMMENT_COLUMN, 'Value' );
display_PVS    =  get ( handles.DISPLAY_PVS,           'Value' );
displayOPV_PVS =  get ( handles.DISPLAY_OPV_PVS,       'Value' );

for j =    1 : OPctrl.items
    item      = OPctrl.order ( j );
    
    set ( h.( sprintf ( 'PARAMETER_%2.2d', j ) ), 'String', OP { item }.Parameter );
    
    if ( ~display_PVS )
        obj = h.( sprintf ( 'ACTUAL_%2.2d',    j ) );
        set ( obj, 'String', sprintf ( OP { item }.Vfmt, OP { item }.Actual) );
        setActualColor ( obj, OP { item } );
    end
    
    if ( ~displayOPV_PVS )
        set ( h.( sprintf ( 'TARGET_%2.2d',    j ) ), 'String', sprintf ( OP { item }.Vfmt, OP { item }.Target ) );
    end

    if ( ~TOLedit && OP { item }.Tol ~= 0 )
        pm = OP { item }.Tolmode;
    else
        pm = '';
    end

    set ( h.( sprintf ( 'TOL_%2.2d',       j ) ), 'String', sprintf ( OP { item }.Tfmt, pm, OP { item }.Tol ) );
    set ( h.( sprintf ( 'UNIT_%2.2d',      j ) ), 'String', OP { item }.Unit );

    if ( displayComment )
        set ( h.( sprintf ( 'COMMENT_%2.2d',   j ) ), 'String', OP { item }.Comment );
    else
        set ( h.( sprintf ( 'COMMENT_%2.2d',   j ) ), 'String', OP { item }.TS );
    end
end

%set ( h.DATETIME, 'String', util_longDateFormat ( clock ) );
set ( h.DATETIME, 'String', sprintf ( '%s%s', datestr ( now,'dddd, ' ), datestr ( now,'mmmm dd, yyyy HH:MM:SS' ) ) );

h.OP = OP;

end


function setActualColor ( obj, item )

lvl = checkTolerance ( item.Actual, item.Target, item.Tol, item.Tolmode ); 
        
switch lvl
    case 0
        set ( obj, 'ForegroundColor', 'white' );
    case 1
        set ( obj, 'ForegroundColor', [ 0 102/255 51/255 ] );
    case 2
        set ( obj, 'ForegroundColor', 'yellow' );
    otherwise
        set ( obj, 'ForegroundColor', 'red' );
end

end


% --- Executes on button press in PRINTLOGBOOK.
function PRINTLOGBOOK_Callback(hObject, eventdata, handles)
% hObject    handle to PRINTLOGBOOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global OPctrl;

handles.printTo_e_Log = true;
handles.printTo_Files = false;

%if ( ~OPctrl.saved )
%    answ = questdlg ( 'Load Target before print?', 'Documented Target Check', 'Yes', 'No', 'Cancel', 'Yes' );
%    
%    if ( strcmpi ( answ, 'yes' ) )
%        saved_handles = handles;
%        SAVE_RESTORE_Callback ( hObject, eventdata, handles )
%        handles       = guidata ( hObject );
%        uiwait ( handles.SAVE_RESTORE );
%        handles       = saved_handles;
%        handles.OP    = checkOperatingPoint ( handles.OP );
%
%        % refresh screen to so that the new TARGET value is correctly incorporated
%        handles = refresh ( handles );        
%    elseif ( strcmpi ( answ, 'cancel' ) )
%        return;
%    end
%end

fig = generateLogBookGraphics ( handles.OP, get ( handles.DATETIME, 'String' ) );
    
if ( fig )
    if ( handles.printTo_e_Log )
        print (fig, '-dpsc2', '-Pphysics-lclslog', '-adobecset' );
    end
    
    if ( handles.printTo_Files )
        figName = 'LCLS_OperatingPoint';
        print ( fig, '-dpdf',  '-r300', figName ); 
        print ( fig, '-djpeg', '-r300', figName ); 
    end
    
    if ( handles.printTo_e_Log || handles.printTo_Files )
        delete ( fig );
    end
end

fn     = 'checkOP_logbookFile.txt';
result = generateLogBookText ( handles.OP, get ( handles.DATETIME, 'String' ), fn );

if ( result )
    if ( handles.printTo_e_Log )
        system ( sprintf ( 'lpr -Pphysics-lclslog %s', fn ) );
    end
    
    if ( handles.printTo_e_Log || handles.printTo_Files )
        delete ( fn );
    end
end

end


function result = generateLogBookText ( OP, dateString, fn )
% generateLogBookGraphics generates a blank figure tablet and 
%           fills it with the formatted table contents, ready
%           to be send to the printer or saved to files.
%

global OPctrl;

result = false;

fid = fopen ( fn, 'w' );

if ( fid < 1 )
    return;
end

fprintf ( fid, '\n!LCLS Operating Point Check List\n\n----\n' );

fprintf ( fid, '!!Parameter     Actual Target Tol. Unit Comment   -\n----\n' );

yct = 0;
rct = 0;
ym1 = '(';
ym2 = ')';
rm1 = '((';
rm2 = '))';

for j    =  1 : OPctrl.items
    item = OPctrl.order ( j );
        
    if ( OP { item }.Tol == 0 )
        pm = '';
    else
        pm = OP { item }.Tolmode;
    end

    pm = strrep ( pm, '±', '+/-' );
    
    
    lvl = checkTolerance ( OP { item }.Actual, OP { item }.Target, OP { item }.Tol, OP { item }.Tolmode  ); 
        
    switch lvl
        case 0
            mk1 = ' ';
            mk2 = ' ';
        case 1
            mk1 = ' ';
            mk2 = ' ';
        case 2
            mk1 = ym1;
            mk2 = ym2;
            yct = yct + 1;
        otherwise
            mk1 = rm1;
            mk2 = rm2;
            rct = rct + 1;
    end
    
    Afmt = sprintf ( '%%s%s%%s', OP { item }.Vfmt );

    strV = util_stralign ( sprintf ( OP { item }.Vfmt,     OP { item }.Target ), 8, 'c' );
    strT = util_stralign ( sprintf ( OP { item }.Tfmt, pm, OP { item }.Tol   ),  8, 'c' );

    if ( OP { item }.aquired )
        strA = util_stralign ( sprintf ( Afmt, mk1, OP { item }.Actual, mk2 ), 11, 'c' );
    else
        strA = '   NaN  ';
    end

    fmt = sprintf ( '%%30.30s %s %s %s %%5.5s %%25s\n', strA, strV, strT );
    
    Unit    = strrep ( OP { item }.Unit,   'µm', 'micron' );
    Comment = strrep ( OP { item }.Comment,'º', 'deg' );
        
    fprintf ( fid, fmt, ...
        util_stralign ( OP { item }.Parameter, 30, 'l' ), ...
        util_stralign (             Unit,       5, 'l' ), ...
        util_stralign (             Comment,   25, 'l' ) );
end

if ( yct || rct )
    fprintf ( fid, '----\n' );
    
    if ( yct )
        fprintf ( fid, '%s%s - Actual moderately out of tolerance (yellow)\n', ym1, ym2 );
    end
    
    if ( rct )
        fprintf ( fid, '%s%s - Actual severely   out of tolerance (red)\n', rm1, rm2 );
    end
end

if ( OPctrl.saved )
    fprintf ( fid, '----\n\n' );

    fprintf ( fid, 'Target Config %2.2d: %s', OPctrl.configNo, sprintf ( OPctrl.DescrText ) );
end

fprintf ( fid, '----\n\n' );

fprintf ( fid, 'Actuals last updated on %s', dateString );
    
fclose ( fid );

result = true;

end


function fig = generateLogBookGraphics ( OP, dateString )
% generateLogBookGraphics generates a blank figure tablet and 
%           fills it with the formatted table contents, ready
%           to be send to the printer or saved to files.
%

global OPctrl;

generateFigure   = true;
n                = OPctrl.items;

if ( ~generateFigure )
    fig = 0;
else
    scrsz     = get ( 0, 'ScreenSize' );
    figHeight = ( n + 4 ) * 19;
    figWidth  = max ( 900, figHeight * 1.2 );
    figX      = ( scrsz ( 3 ) - figWidth  ) / 6;
    figY      = ( scrsz ( 4 ) - figHeight ) / 6;
    fig       = figure ( 'Position', [ figX figY figWidth figHeight ] );
    clf;
    set ( fig, 'color', [ 1 1 1 ] );

    plot ( [ 0, 1 ], [ 1, 1 ], 'w' );
    axis ( [ 0, 100, 0, 100 ] );
    axis off;
    
    parameterCol = -8;
    actualCol    = parameterCol + 37;
    targetCol    = actualCol    + 15;
    tolCol       = targetCol    + 10;
    unitCol      = tolCol       + 10;
    commentCol   = unitCol      + 10;
    titleRow     =  105;
    headerRow    = titleRow  - 7;
    
    startRow     = headerRow - 4;
    rowInc       = 103 / n;

    dateCol      = -15;
    dateRow      =  startRow - ( n + 1 ) * rowInc;
    
    confCol      = 50;
    confRow      = dateRow;
    
    putText  ( parameterCol, titleRow,  'LCLS Operating Point Check List', 'Arial',   14, 'bf', '{black}' );
    putText  ( parameterCol, headerRow, 'Parameter', 'Arial',   12, 'bf', '{black}' );
    putText  ( actualCol,    headerRow, 'Actual',    'Arial',   12, 'bf', '{black}' );
    putText  ( targetCol,    headerRow, 'Target',    'Arial',   12, 'bf', '{black}' );
    putText  ( tolCol,       headerRow, 'Tol.',      'Arial',   12, 'bf', '{black}' );
    putText  ( unitCol,      headerRow, 'Unit',      'Arial',   12, 'bf', '{black}' );
    putText  ( commentCol,   headerRow, 'Comment',   'Arial',   12, 'bf', '{black}' );

    for j    = 1 : OPctrl.items
        item = OPctrl.order ( j );

        if ( OP { item }.Tol == 0 )
            pm = '';
        else
            pm = OP { item }.Tolmode;
        end

        pm = strrep ( pm, '±', '{\pm}' );
 
        strV = util_stralign ( sprintf ( OP { item }.Vfmt,     OP { item }.Target ),  8, 'c' );
        strT = util_stralign ( sprintf ( OP { item }.Tfmt, pm, OP { item }.Tol    ), 10, 'c' );

        if ( OP { item }.aquired )
            strA = util_stralign ( sprintf ( OP { item }.Vfmt,     OP { item }.Actual), 8, 'c' );
        else
            strA = '   NaN   ';
        end

        thisRow = startRow - ( j - 1 ) * rowInc;

        Param   = strrep ( OP { item }.Parameter,   '_', '{\_}' );
    
        putText  ( parameterCol, thisRow, util_stralign ( Param, 32, 'l' ), ...
                                          'Arial',   10, 'rm', '{black}' );
        
        lvl = checkTolerance ( OP { item }.Actual, OP { item }.Target, OP { item }.Tol, OP { item }.Tolmode  ); 
        
        switch lvl
            case 0
                Acolor = '{black}';
                Atype  = 'it';
            case 1
%                Acolor = 'green';
%                Acolor = '[rgb]{0 102/255 0}';
                Acolor = '[rgb]{0 0.4 0}';
                Atype  = 'rm';
            case 2
                Acolor = '{orange}';
                Atype  = 'rm';
            otherwise
                Acolor = '{red}';
                Atype  = 'rm';
        end
    
        Unit    = strrep ( OP { item }.Unit,   'µ', '{\mu}' );
        Comment = strrep ( OP { item }.Comment,'º', '{^\circ}' );
        
        putText  ( actualCol,    thisRow, strA, 'Arial',   10, Atype, Acolor );
        putText  ( targetCol,    thisRow, strV, 'Arial',   10, 'rm', '{black}' );
        putText  ( tolCol,       thisRow, strT, 'Arial',   10, 'rm', '{black}' );
        putText  ( unitCol,      thisRow, util_stralign ( Unit, 9, 'l' ), ...
                                                'Arial',   10, 'rm', '{black}' );
        putText  ( commentCol,   thisRow, util_stralign ( Comment, 50, 'l' ), ...
                                                'Arial',   10, 'rm', '{black}' );
    end
    
    putText  ( dateCol, dateRow, sprintf ( 'Actuals last updated on %s', dateString ), 'Arial',   9, 'bf', '{blue}' );
    
    if ( OPctrl.saved )
        putText  ( confCol, confRow, ...
            util_stralign ( sprintf ( 'Target Config %2.2d: %s', OPctrl.configNo, sprintf ( OPctrl.DescrText ) ), 60, 'r' ), ...
            'Arial',   9, 'bf', '{blue}' );
    end
end

end


function level = checkTolerance ( A, P, T, M )
% checkTolerance compares the differences between
%       the actual measurement, A, and the target
%       value, P, to the tolerance, T. The single
%       character parameter, M, indicates the 
%       tolerance mode. The followin tolerance modes
%       are supported:
%           '±'  : symmetric tolerance
%           '<'  : upper bound tolerance
%           '>'  : lower bound tolerance
%       A level value is assigned depending on the
%       amount of tolerance violation:\
%           level = 0 : A is not a number
%           level = 1 : abs ( A - P ) within tolerance
%           level = 2 : abs ( A - P ) up to cutOff
%           level = 3 : abs ( A - P ) above cutOff
%       

cutOffFactor = 3;

if ( strcmp ( M, '±' ) )
    Dif = abs ( A - P );
    Tol = max ( T, .001 );
elseif ( strcmp ( M, '<' ) )
    Dif = max ( A - P, 0 );
    Tol = abs ( P - T );
elseif ( strcmp ( M, '>' ) )
    Dif = max ( P - A, 0 );
    Tol = abs ( T - P );
else
    Dif = 0;
    Tol = max ( T, .001 );
end

if ( isnan ( A ) ) 
    level = 0;
elseif ( Dif <= Tol ) 
    level = 1;
elseif( Dif > cutOffFactor * Tol )
    level = 3;
else
    level = 2;
end

end


function putText ( x, y, string, font, size, type, color )
% Example call for function
%
%     putText  ( Col, Row, strV, 'Arial', 10, 'rm', '{black}' );
%     putText  ( Col, Row, strV, 'Arial', 10, 'rm', '[rgb]{0 0.4 0}' );
%
fmt = sprintf ( '\\fontname{%s}\\fontsize{%d}\\%s\\color%s%s', font, size, type, color, string );
text  ( x, y, fmt );

end


% --- Executes on button press in REFRESH_MODE_PUSHBUTTON.
function REFRESH_MODE_PUSHBUTTON_Callback(hObject, eventdata, handles)
% hObject    handle to REFRESH_MODE_PUSHBUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of REFRESH_MODE_PUSHBUTTON

global timerRestart;
global debug

if ( debug )
    fprintf ( 'REFRESH_MODE_PUSHBUTTON_Callback called. (timerRestart: %d)\n', timerRestart );
end

if ( timerRestart )
    if ( debug )
        fprintf ( 'calling setSingleShotRefreshMode ( handles )\n' );
    end

    setSingleShotRefreshMode ( handles );
else
    if ( debug )
        fprintf ( 'calling setContinuousRefreshMode ( handles )\n' );
    end

    setContinuousRefreshMode ( handles );
end

end


% --- Executes on button press in SAVE_RESTORE.
function SAVE_RESTORE_Callback ( hObject, eventdata, handles )
% hObject    handle to SAVE_RESTORE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SaveRestoreWindowExists;

if ( ~SaveRestoreWindowExists )
    handles.OP = checkOperatingPoint ( handles.OP );
    handles    = refresh ( handles );

    handles    = OP_SaveRestoreDialog ( 'CreateDialog', handles );
end

% Update handles structure
guidata(hObject, handles);

end


% --- Executes when user attempts to close checkOP_gui.
function CloseRequestFcn ( hObject, eventdata, handles )

global timerRunning;
global timerObj;
global debug;
global verbose;

if ( timerRunning)
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
    timerRunning = false;    
end

if ( verbose )
    fprintf ( 'Closing  checkOP_gui.\n' );
end

util_appClose ( hObject );
lcaClear ( );

end
