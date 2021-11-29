function varargout = CamAlignmentDiagnostics_gui(varargin)
% CAMALIGNMENTDIAGNOSTICS_GUI M-file for CamAlignmentDiagnostics_gui.fig
%      CAMALIGNMENTDIAGNOSTICS_GUI, by itself, creates a new CAMALIGNMENTDIAGNOSTICS_GUI or raises the existing
%      singleton*.
%
%      H = CAMALIGNMENTDIAGNOSTICS_GUI returns the handle to a new CAMALIGNMENTDIAGNOSTICS_GUI or the handle to
%      the existing singleton*.
%
%      CAMALIGNMENTDIAGNOSTICS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAMALIGNMENTDIAGNOSTICS_GUI.M with the given input arguments.
%
%      CAMALIGNMENTDIAGNOSTICS_GUI('Property','Value',...) creates a new CAMALIGNMENTDIAGNOSTICS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CamAlignmentDiagnostics_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CamAlignmentDiagnostics_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HXRAlignmentDLTQiagnostics_gui

% Last Modified by GUIDE v2.5 08-Mar-2021 21:20:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CamAlignmentDiagnostics_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @CamAlignmentDiagnostics_gui_OutputFcn, ...
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


% --- Executes just before CamAlignmentDiagnostics_gui is made visible.
function CamAlignmentDiagnostics_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.jb : jq 
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CamAlignmentDiagnostics_gui (see VARARGIN)

% Choose default command line output for CamAlignmentDiagnostics_gui
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;
global debug;
global verbose;

addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ) );

lcaSetSeverityWarnLevel ( 5 );

handles.fb             = '/u1/lcls/matlab/CamAlignmentDiagnostics_gui/SXR/';
handles.undulatorLine  = 'SXR';

handles.output         = hObject;
timerRunning           = false;
timerRestart           = false;
timerDelay             = 2;      % sec (timerDelays of less than 2 sec might not work
timerData.hObject      = hObject;
debug                  = false;
verbose                = false;
handles.dispBufferSize = 10;
handles.printTo_e_Log  = true;
handles.printTo_Files  = true;
handles.showLogFigure  = false;
handles.initialize     = true;

handles                = initializeData ( hObject, handles );
handles                = updateDisplay ( handles, handles.XFIGURE, handles.YFIGURE );

timerData.handles      = handles;

% Update handles structure
guidata ( hObject, handles );

% UIWAIT makes CamAlignmentDiagnostics_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


function adjustCAMcheckboxDisplays ( handles )

set ( handles.REM_LIN_CHECKBOX,        'Visible', 'On' );
set ( handles.REM_LIN_LABEL,           'Visible', 'On' );

if ( get ( handles.CAM_MOTION_ENABLED_CHECKBOX, 'Value' )  )
    set ( handles.MOVE_GIRDERS_BTN,            'Visible', 'On' );
else
    set ( handles.MOVE_GIRDERS_BTN,            'Visible', 'Off' );
end

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


if ( timerRunning )
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
end

if ( debug )
    fprintf ( 'Setting Timer Delay to %.0f sec.\n', timerDelay );
end

timerObj          = timer ( 'TimerFcn', @Timer_Callback_fcn, 'Period', timerDelay, 'ExecutionMode', 'fixedRate' );
timerRestart      = true;

if ( debug )
    fprintf ( 'Starting Timer\n' );
end

timerData.handles = handles;

start ( timerObj );

timerRunning      = true;

end


% --- Executes when timer completes. Used for periodic refreshes.
function Timer_Callback_fcn ( obj, event )

global timerData;
global debug;

if ( debug )
    fprintf ( 'Timer_Callback_fcn called\n' );
end

handles = timerData.handles;
hObject = timerData.hObject;

set ( handles.DATESTRING, 'String', sprintf ( '%s%s', datestr ( now,'dddd, ' ), datestr ( now,'mmmm dd, yyyy HH:MM:SS' ) ) );
set ( handles.DATESTRING, 'Visible', 'On' );

handles = updateDisplay ( handles, handles.XFIGURE, handles.YFIGURE );

% Update handles structure
guidata ( hObject, handles );

timerData.handles = handles;

if ( debug )
    fprintf ( '%s event occurred at %s\n', event.Type, datestr ( event.Data.time ) );
    get ( obj );
end

end


function date = StandardDateFormat ( a )

prop = whos ( 'a' );

if ( strcmp ( prop.class, 'double' ) )
    if ( prop.bytes == 8 )
        b = a;
    else
        b = datenum ( char ( a ) );
    end
elseif ( any ( cell2mat ( a ) ) )
    b = datenum ( a );
else
    b = now;
end

date = datestr ( b, 'yyyy-mm-dd HH:MM:SS' ) ;

end


function new_handles = updateDisplay ( handles, XFIGURE_AXIS, YFIGURE_AXIS )

handles.reference_date = datestr ( datenum ( handles.reference_date ), 'yyyy-mm-dd HH:MM:SS' );

set ( handles.RESETDATE,          'String', sprintf ( 'BBA Reference Date %s', handles.reference_date ) );
set ( handles.RESETDATE,          'Visible', 'On' );
set ( handles.INITIAL_DATA_TAKEN, 'String', 'Intitial Data Memorized' );
set ( handles.INITIAL_DATA_TAKEN, 'Visible', 'On' );
set ( handles.INITIALDATE,        'String', sprintf ( 'Initial Date: %s', handles.CAM.initial_date ) );
set ( handles.INITIALDATE,        'Visible', 'On' );
set ( handles.CAM_SNAPSHOTDATE,   'String', handles.CAM.snapshot_date );
set ( handles.CAM_SNAPSHOTDATE,   'Visible', 'On' );
set ( handles.ARCHIVE_SET_A_DATE, 'String', handles.CAM.archive_A_date );
set ( handles.ARCHIVE_SET_A_DATE, 'Visible', 'On' );
set ( handles.ARCHIVE_SET_B_DATE, 'String', handles.CAM.archive_B_date );
set ( handles.ARCHIVE_SET_B_DATE, 'Visible', 'On' );

handles.CAM.current_date = sprintf ( '%s', datestr ( now, 'yyyy-mm-dd HH:MM:SS' ) );
handles.CAM.current_vals = getCurrentGirderPositions ( handles.undulatorLine, handles.cellList, handles.geo );

handles                  = updatePlots ( handles, XFIGURE_AXIS, YFIGURE_AXIS );
new_handles              = handles;

end


function new_handles = updatePlots ( handles, XFIGURE_AXIS, YFIGURE_AXIS )

handles = manageDataChannels ( handles );

if ( handles.initialize )
    for j = 1 : handles.dispBufferSize 
        for k = 1 : handles.totalDataChannels
            handles.dispHistory { k, j } = handles.DisplayValues { k };
            handles.dateHistory { k, j } = handles.DisplayDate;
        end
    end

    deltaTime          = 0;
    handles.initialize = false;
else
    deltaTime          = datenum ( handles.dateHistory { handles.currentDataChannel, handles.dispBufferSize } ) - ...
                         datenum ( handles.DisplayDate );
end
        
if ( abs ( deltaTime ) > 1e-6 )
    if ( handles.dispBufferSize > 1 )
        for j = 1 : handles.dispBufferSize - 1
            for k = 1 : handles.totalDataChannels
                handles.dispHistory { k, j } = handles.dispHistory { k, j + 1 };
                handles.dateHistory { k, j } = handles.dateHistory { k, j + 1 };
            
%                fprintf ( 'date { %d } = %s y ( 1 ) = %f\n', j, handles.dateHistory { k, j }, handles.dispHistory { k, j }.y ( 1 ) );
            end
        end
    end

    for k = 1 : handles.totalDataChannels
        handles.dispHistory { k, handles.dispBufferSize } = handles.DisplayValues { k };
        handles.dateHistory { k, handles.dispBufferSize } = handles.DisplayDate;
    end
    
%    fprintf ( 'Updating buffer { %d, %d } at %s y ( 1 ) = %f.\n', handles.totalDataChannels, handles.dispBufferSize, handles.DisplayDate, ...
%                                                              handles.dispHistory {handles.totalDataChannels, handles.dispBufferSize }.y ( 1 ) );
end

plotCAM_Xstatus ( handles, XFIGURE_AXIS );
plotCAM_Ystatus ( handles, YFIGURE_AXIS );

new_handles = handles;

end


function diff = subtractPositionStructures ( A, B )

diff.x     = A.x     - B.x;
diff.y     = A.y     - B.y;
diff.z     = ( A.z + B.z ) / 2;
diff.yaw   = A.yaw   - B.yaw;
diff.pitch = A.pitch - B.pitch;
diff.r     = A.r     - B.r;
    
end


function new_handles = manageDataChannels ( handles )

handles.YselA                               = get ( handles.Y_AXIS_QUANTITY_A_MENU,     'Value' );
handles.YselB                               = get ( handles.Y_AXIS_QUANTITY_B_MENU,     'Value' );
handles.UseRef                              = get ( handles.USE_CAM_REFERENCE_CHECKBOX, 'Value' );
handles.Rel                                 = get ( handles.REM_LIN_CHECKBOX,           'Value' );
handles                                     = getCurrentDataChannel ( handles, handles.YselA, handles.YselB );

initial_CAM_vals                            = handles.CAM.initial_vals;
current_CAM_vals                            = handles.CAM.current_vals;
snapshot_CAM_vals                           = handles.CAM.snapshot_vals;
archive_A_CAM_vals                          = handles.CAM.archive_A_vals;
archive_B_CAM_vals                          = handles.CAM.archive_B_vals;    
reference_CAM_vals                          = handles.CAM.reference_vals;

if ( handles.UseRef )
    initial_CAM_vals                        = subtractPositionStructures ( initial_CAM_vals,   reference_CAM_vals );
    current_CAM_vals                        = subtractPositionStructures ( current_CAM_vals,   reference_CAM_vals );
    snapshot_CAM_vals                       = subtractPositionStructures ( snapshot_CAM_vals,  reference_CAM_vals );
    archive_A_CAM_vals                      = subtractPositionStructures ( archive_A_CAM_vals, reference_CAM_vals );
    archive_B_CAM_vals                      = subtractPositionStructures ( archive_B_CAM_vals, reference_CAM_vals );
    reference_CAM_vals                      = subtractPositionStructures ( reference_CAM_vals, reference_CAM_vals );
end

for A = 1 : handles.A_Options
    for B = 1 : handles.B_Options
        k                                   = ( A - 1 ) * handles.B_Options + B;

        switch A
            case handles.YA_CURRENT_ID
                handles.DisplayValuesA      = current_CAM_vals;
            case handles.YA_SNAPSHOT_ID
                handles.DisplayValuesA      = snapshot_CAM_vals;
            case handles.YA_ARCHIVE_A_ID
                handles.DisplayValuesA      = archive_A_CAM_vals;                
            case handles.YA_ARCHIVE_B_ID
                handles.DisplayValuesA      = archive_B_CAM_vals;
            case handles.YA_REFERENCE_ID
                handles.DisplayValuesA      = reference_CAM_vals;
            otherwise
                handles.DisplayValuesA      = current_CAM_vals;
        end
         
        switch B
            case handles.YB_NONE_ID
                handles.DisplayValues { k } = handles.DisplayValuesA;
            case handles.YB_SNAPSHOT_ID
                handles.DisplayValues { k } = subtractPositionStructures ( handles.DisplayValuesA, snapshot_CAM_vals );
            case handles.YB_INITIAL_ID
                handles.DisplayValues { k } = subtractPositionStructures ( handles.DisplayValuesA, initial_CAM_vals );
            case handles.YB_ARCHIVE_A_ID
                handles.DisplayValues { k } = subtractPositionStructures ( handles.DisplayValuesA, archive_A_CAM_vals );
            case handles.YB_ARCHIVE_B_ID
                handles.DisplayValues { k } = subtractPositionStructures ( handles.DisplayValuesA, archive_B_CAM_vals );
            case handles.YB_REFERENCE_ID
                handles.DisplayValues { k } = subtractPositionStructures ( handles.DisplayValuesA, reference_CAM_vals );
            otherwise
                handles.DisplayValues { k } = handles.DisplayValuesA;
        end
        
        if ( handles.Rel )
            DisplayValue_base               = fitGirderPositions ( handles.DisplayValues { k }, handles.cellList, handles.UndConsts );
            handles.DisplayValues { k }     = subtractPositionStructures ( handles.DisplayValues { k }, DisplayValue_base );
        end        
    end
end

handles.DisplayDate                        = handles.CAM.current_date;
new_handles         = handles;

end


function plotCAM_Xstatus ( handles, axes_handle )

z = zeros ( 3, handles.cells );
k = handles.currentDataChannel;

for j = 1 : handles.cells
    z = setXaxis ( handles, z, j );
end

x = cell ( 1, handles.dispBufferSize );

for j = 1 : handles.dispBufferSize
    x { j } = handles.dispHistory { k, j }.x;
end

plotCAMdata ( handles, axes_handle, z, x, handles.cellList )

grid ( axes_handle, 'on' );

if ( xAxis_has_GirderNumbers ( handles ) )
    xlabel ('Cell Numbers', 'Parent', axes_handle );
else
    xlabel ( 'z [m]', 'Parent', axes_handle );
end

ylabel ( 'x [microns]', 'Parent', axes_handle );

hold ( axes_handle, 'off' );

end


function plotCAM_Ystatus ( handles, axes_handle )

z = zeros ( 3, handles.cells );
k = handles.currentDataChannel;

for j = 1 : handles.cells
    z = setXaxis ( handles, z, j );
end

y = cell ( 1, handles.dispBufferSize );

for j = 1 : handles.dispBufferSize
    y { j } = handles.dispHistory { k, j }.y;
end

plotCAMdata ( handles, axes_handle, z, y, handles.cellList )

grid ( axes_handle, 'on' );

if ( xAxis_has_GirderNumbers ( handles ) )
    xlabel ('Cell Numbers', 'Parent', axes_handle );
else
    xlabel ( 'z [m]', 'Parent', axes_handle );
end

ylabel ( 'y [microns]', 'Parent', axes_handle );

hold ( axes_handle, 'off' );

end


function plotCAMdata ( handles, axes_handle, x, y, cellList )

n     = length ( y ); % shades

plotb = get ( handles.SHOW_SEG_NUMBERS_CHECKBOX,  'Value' );
plotq = get ( handles.SHOW_QUAD_NUMBERS_CHECKBOX, 'Value' );
precb = get ( handles.SEG_PREC_EDIT,              'Value' );
precq = get ( handles.QUAD_PREC_EDIT,             'Value' );
FMTb  = sprintf ( '%%+.%df', precb );
FMTq  = sprintf ( '%%+.%df', precq );

for j = 1 : length ( cellList )
    for k = 1 : n - 1
        shade = zeros ( 1, 3 ) + ( n - k ) / ( n - 1 );
        
        if ( handles.Line == 'H' )
            plot ( x ( 1 : 2, j ), y { k } ( 1 : 2, j ), 'Color', shade, 'LineWidth', 4, 'Parent', axes_handle );
        else
            if ( cellList ( j ) == 35 )
                if ( j == 1 )
                    plot ( x ( 2, j ), y { k } ( 2, j ), 'MarkerEdgeColor', shade, 'Marker', 's', 'Parent', axes_handle );
                else
                    plot ( x ( 2, j ), y { k } ( 2, j ), 'MarkerEdgeColor', shade, 'MarkerFaceColor', shade, 'Marker', 's', 'Parent', axes_handle );

%                    [ xn, yn ] = getLineFraction ( [ x(2,j-1) x(2,j) ], [ y{k}(2,j-1) y{k}(2,j) ], [ 0.2 0.8 ] );
                
%                    plot ( xn, yn , 'Color', shade, 'LineWidth', 3, 'Parent', axes_handle );
                end                
            elseif ( cellList ( j ) == 100 )
                plot ( x ( 1 : 2, j ), y { k } ( 1 : 2, j ), 'Color', shade, 'LineWidth', 3, 'Parent', axes_handle );
            else
                plot ( x ( [ 1, 3 ], j ), y { k } ( [1, 3], j ), 'Color', shade, 'LineWidth', 1, 'Parent', axes_handle );
                        
                if ( j == 1 )
                    plot ( x ( 2, j ), y { k } ( 2, j ), 'MarkerEdgeColor', shade, 'Marker', 's', 'Parent', axes_handle );
                else
                    plot ( x ( 2, j ), y { k } ( 2, j ), 'MarkerEdgeColor', shade, 'MarkerFaceColor', shade, 'Marker', 's', 'Parent', axes_handle );

                    [ xn, yn ] = getLineFraction ( [ x(2,j-1) x(2,j) ], [ y{k}(2,j-1) y{k}(2,j) ], [ 0.2 0.8 ] );
                
                    plot ( xn, yn , 'Color', shade, 'LineWidth', 3, 'Parent', axes_handle );
                end                
            end
        end
        
        hold ( axes_handle, 'on' );
    end
    
    if ( handles.Line == 'H' )
        plot ( x ( 1 : 2, j ), y { n } ( 1 : 2, j ), 'Color', [ 0.3 0.5 0.9 ], 'LineWidth', 4, 'Parent', axes_handle );
    else
        if ( cellList ( j ) == 35 )
            plot ( x ( 2, j ), y { n } ( 2, j ), 'MarkerEdgeColor', [ 0.3 0.5 0.9 ], 'MarkerFaceColor', [ 0.3 0.5 0.9 ], 'Marker', 's', 'Parent', axes_handle );
        elseif ( cellList ( j ) == 100 )
            plot ( x ( 1 : 2, j ), y { n } ( 1 : 2, j ), 'Color', [ 0.0 1.0 0.0 ], 'LineWidth', 3, 'Parent', axes_handle );
        else
            plot ( x ( [1, 3], j ), y { n } ( [1, 3], j ), 'Color',   [ 0.3 0.5 0.9 ], 'LineWidth', 1, 'Parent', axes_handle );
            
            if ( j == 1 )
                plot ( x ( 2, j ), y { n } ( 2, j ), 'MarkerEdgeColor', [ 0.3 0.5 0.9 ], 'Marker', 's', 'Parent', axes_handle );
            else
                plot ( x ( 2, j ), y { n } ( 2, j ), 'MarkerEdgeColor', [ 0.3 0.5 0.9 ], 'MarkerFaceColor', [ 0.3 0.5 0.9 ], 'Marker', 's', 'Parent', axes_handle );

                [ xn, yn ] = getLineFraction ( [ x(2,j-1) x(2,j) ], [ y{n}(2,j-1) y{n}(2,j) ], [ 0.2 0.8 ] );
            
                plot ( xn, yn , 'Color', [ 1.0 0.0 0.0 ], 'LineWidth', 3, 'Parent', axes_handle );
            end
        end
    end
    
    hold ( axes_handle, 'on' );
end

v       = axis ( axes_handle );
y_scale = get ( handles.Y_SCALE, 'Value' );

if ( y_scale )
    maxy    = y_scale;
else
    maxy    = max ( max ( abs ( v ( 3 ) ), abs ( v ( 4 ) ) ), 1 );
end

v ( 3 ) = - maxy;
v ( 4 ) =   maxy;

axis ( axes_handle, v );

if ( plotb || plotq )
    v  = axis ( axes_handle );
    
    dyd = +0.030 * ( v ( 4 ) - v ( 3 ) );
    dyb = +0.050 * ( v ( 4 ) - v ( 3 ) ); 
    dyq = +0.100 * ( v ( 4 ) - v ( 3 ) ); 
    dxb = +0.001 * ( v ( 2 ) - v ( 1 ) );
    dxq = +0.001 * ( v ( 2 ) - v ( 1 ) );

    for j = 1 : length ( cellList )
        if ( handles.Line == 'H' )
%            yb = max ( abs ( y { n } ( 1, j ) ), abs ( y { n } ( 2, j ) ) );
            yb = max (  y { n } ( 1, j ), y { n } ( 2, j ) );
            yq = y { n } ( 3, j );
    
            if ( yb < yq )
                yb = yb - dyb - mod ( j, 2 ) * dyd;
            else
                yb = yb + dyb + mod ( j, 2 ) * dyd;
            end
    
            if ( yq < yb )
                yq = yq - dyq - mod ( j, 2 ) * dyd;
            else
                yq = yq + dyq + mod ( j, 2 ) * dyd;
            end
        
            xb = (  x ( 1, j ) +  x ( 2, j ) ) / 2;
            xq = x ( 3, j );
        
            bypos = ( y { n } ( 1 , j ) + y { n } ( 2 , j ) ) / 2;
            qypos =   y { n } ( 3, j );
        else
            yq = y { n } ( 2, j );
        
            yq = yq + dyq + mod ( j, 2 ) * dyd;
        
            xq = x ( 2, j );
        
            qypos = y { n } ( 2, j );
        end
        
        if ( plotb && handles.Line == 'H' )
            text ( xb + dxb, yb, sprintf ( FMTb, bypos ), ...
                'FontSize', 7, ...
                'Color', [ 0.5, 0.9, 0.0 ], ...
                            'FontWeight', 'normal', ...
                'HorizontalAlignment', 'Center', ...
                'VerticalAlignment', 'Cap', ...
                'Parent', axes_handle);
        end
    
        if ( plotq )
            text ( xq - dxq, yq, sprintf ( FMTq, qypos ), ...
                'FontSize', 7, ...
                'Color', [ 0.9, 0.5, 0.0 ], ...
                'FontWeight', 'normal', ...
                'HorizontalAlignment', 'Center', ...
                'VerticalAlignment', 'Cap', ...
                'Parent', axes_handle);
        end
    end
end

textPos = estimatePosition ( 1, 95,  axis ( axes_handle ) );
textStr = formatModeString ( handles );
text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 7, 'Parent', axes_handle );

textPos = estimatePosition ( 99, 95,  axis ( axes_handle ) );
textStr = handles.undulatorLine;
text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'right', 'FontSize', 9, 'FontWeight', 'bold', 'Parent', axes_handle );

if ( handles.Rel && strcmp ( get ( handles.REM_LIN_CHECKBOX, 'Visible' ), 'on' ) )
    textPos = estimatePosition ( 99, 2,  axis ( axes_handle ) );
    textStr = 'Linear portion removed from data.';
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'right', 'FontSize', 7, 'Parent', axes_handle );   
end

end


function [ xn, yn ] = getLineFraction ( x, y, interval )

xn = x;
yn = y;

if ( length ( x ) ~= 2 || length ( y ) ~= 2 || length ( interval ) ~= 2 )
    return;
end

dx = x ( 2 ) - x ( 1 );
dy = y ( 2 ) - y ( 1 );

if ( ~dx )
    return;
end

a = dy / dx;
b = y ( 1 ) - a * x ( 1 );

xn ( 1 ) = x ( 1 ) + dx * interval ( 1 );
xn ( 2 ) = x ( 1 ) + dx * interval ( 2 );

yn = a * xn + b;

end


% --- Outputs from this function are returned to the command line.
function varargout = CamAlignmentDiagnostics_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  c array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

setContinuousRefreshMode ( handles );

end


function status = xAxis_has_GirderNumbers ( handles )

if ( any ( strfind ( get ( handles.X_AXIS_QUANTITY_BTN, 'String' ), 'umber' ) ) )
    status = false;
else
    status = true;
end

end


% --- Executes on button press in X_AXIS_QUANTITY_BTN.
function X_AXIS_QUANTITY_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to X_AXIS_QUANTITY_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( xAxis_has_GirderNumbers ( handles ) )
    set ( hObject, 'String', 'Change X-Axis to Girder Numbers' );
else
    set ( hObject, 'String', 'Change X-Axis to Z-Locations' );
end

end


% --- Executes on button press in TAKE_SNAPSHOT.
function TAKE_SNAPSHOT_Callback(hObject, eventdata, handles)
% hObject    handle to TAKE_SNAPSHOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerData;

handles.CAM.snapshot_date = sprintf ( '%s', datestr ( now, 'yyyy-mm-dd HH:MM:SS' ) );
handles.CAM.snapshot_vals = getCurrentGirderPositions ( handles.undulatorLine, handles.cellList, handles.geo );

handles                   = eraseHistory ( handles, handles.YA_SNAPSHOT_ID, handles.YB_SNAPSHOT_ID );

timerData.handles         = handles;

% Update handles structure
guidata(hObject, handles);

end


function new_handles = eraseHistory ( handles, A_IDs, B_IDs )

if ( handles.dispBufferSize > 1 )
    Channels      = getID_Channels ( handles, A_IDs, B_IDs );
    n             = length ( Channels );

    handles       = manageDataChannels ( handles );
    
    if ( n )
        for k = 1 : n
            ID = Channels ( k );

            for j = 1 : handles.dispBufferSize
                handles.dispHistory { ID, j } = handles.DisplayValues { ID };
                handles.dateHistory { ID, j } = handles.dateHistory { ID, handles.dispBufferSize };
            end
        end
    end
end

new_handles = handles;

end


function Channels = getID_Channels ( handles, A_IDs, B_IDs )

Channels = zeros ( 1, handles.totalDataChannels );
Channel  = 0;

nA_IDs = length ( A_IDs );
nB_IDs = length ( B_IDs );

for j = 1 : handles.A_Options
    YselA = handles.YA_IDs ( j );
    
    for k = 1 : handles.B_Options
        YselB = handles.YB_IDs ( k );

        foundMatch = false;
        
        for ID = 1 : nA_IDs
            if ( YselA == A_IDs ( ID ) )
                foundMatch = true;
                break;
            end
        end            
        
        for ID = 1 : nB_IDs
            if ( YselB == B_IDs ( ID ) )
                foundMatch = true;
                break;
            end
        end            

        if ( ~foundMatch )
            continue;
        end
        
        handles = getCurrentDataChannel ( handles, YselA, YselB );
                
        if ( handles.currentDataChannel )
            Channel              = Channel + 1;
            Channels ( Channel ) = handles.currentDataChannel;
        end
    end
end

count = 0;

for j = 1 : handles.totalDataChannels
    if ( Channels ( j ) )
        count = count + 1;
    end
end

if ( ~count )
    Channels = [];
    return;
else
    tmpChannels = Channels;
    Channels    = zeros ( 1, count );

    k = 0;
    
    for j = 1 : handles.totalDataChannels
        if ( tmpChannels ( j ) )
            k              = k + 1;
            Channels ( k ) = tmpChannels ( j );
        end
    end
end

end
    
    
function new_handles = getCurrentDataChannel ( handles, YselA, YselB )

switch YselA
    case handles.YA_CURRENT_ID
        handles.currentDataChannel = ( handles.YA_CURRENT_ID - 1 )      * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.CAM.current_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_SNAPSHOT_ID
        handles.currentDataChannel = ( handles.YA_SNAPSHOT_ID - 1 )     * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.CAM.snapshot_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_ARCHIVE_A_ID
        handles.currentDataChannel = ( handles.YA_ARCHIVE_A_ID    - 1 ) * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.CAM.archive_A_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_ARCHIVE_B_ID
        handles.currentDataChannel = ( handles.YA_ARCHIVE_B_ID    - 1 ) * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.CAM.archive_B_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_REFERENCE_ID
        handles.currentDataChannel = ( handles.YA_REFERENCE_ID    - 1 ) * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.CAM.reference_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    otherwise
        handles.currentDataChannel = ( handles.YA_CURRENT_ID - 1 )      * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.CAM.current_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( 1 );
end
         
switch YselB
    case handles.YB_NONE_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_NONE_ID - 1;
        handles.DisplayDate_B      = NaN;
        handles.DisplayItem_B      = '';
    case handles.YB_SNAPSHOT_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_SNAPSHOT_ID - 1;
        handles.DisplayDate_B      = handles.CAM.snapshot_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_INITIAL_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_INITIAL_ID - 1;
        handles.DisplayDate_B      = handles.CAM.initial_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_ARCHIVE_A_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_ARCHIVE_A_ID - 1;
        handles.DisplayDate_B      = handles.CAM.archive_A_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_ARCHIVE_B_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_ARCHIVE_B_ID - 1;
        handles.DisplayDate_B      = handles.CAM.archive_B_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_REFERENCE_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_REFERENCE_ID - 1;
        handles.DisplayDate_B      = handles.CAM.reference_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    otherwise
        handles.currentDataChannel = handles.currentDataChannel  + handles.YB_NONE_ID - 1;
        handles.DisplayDate_B      = NaN;
        handles.DisplayItem_B      = '';
end

new_handles = handles;

end


% --- Executes on selection change in Y_AXIS_QUANTITY_A_MENU.
function Y_AXIS_QUANTITY_A_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Y_AXIS_QUANTITY_A_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Y_AXIS_QUANTITY_A_MENU contents as c array
%        contents{get(hObject,'Value')} returns selected item from Y_AXIS_QUANTITY_A_MENU

end


% --- Executes during object creation, after setting all properties.
function Y_AXIS_QUANTITY_A_MENU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_AXIS_QUANTITY_A_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on selection change in Y_AXIS_QUANTITY_B_MENU.
function Y_AXIS_QUANTITY_B_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Y_AXIS_QUANTITY_B_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Y_AXIS_QUANTITY_B_MENU contents as c array
%        contents{get(hObject,'Value')} returns selected item from Y_AXIS_QUANTITY_B_MENU

adjustCAMcheckboxDisplays ( handles );

end


% --- Executes during object creation, after setting all properties.
function Y_AXIS_QUANTITY_B_MENU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_AXIS_QUANTITY_B_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in LOAD_ARCHIVE_SET_A_BTN.
function LOAD_ARCHIVE_SET_A_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to LOAD_ARCHIVE_SET_A_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

success = true;

try
    datestring = get ( handles.ARCHIVE_SET_A_DATE_REQUEST, 'String' );

    if ( any ( datestring ) )
        date = datenum ( datestring );
    end
    
    if ( date < 1 )
        success = false;
    end
catch ME
    success = false;
    MSG     = ME.identifier;
    Stack   = ME.stack;
end

if ( success )
    datestr_fmt1  = datestr ( date, 'mm/dd/yyyy HH:MM:SS' );

    getNewADSdata = true;
    
    if ( isfield ( handles, 'ArchiveArequestDate' ) )
        if ( datestr_fmt1 == handles.ArchiveArequestDate )
            fprintf ( 'Date already loaded\n' );
        end
    end
    
    success = false;

    if ( getNewADSdata )
        params.getNewADSdata = getNewADSdata;
        params.vals_name     = 'archive_A_vals';
        params.date_name     = 'archive_A_date';
        params.YA_ID         = handles.YA_ARCHIVE_A_ID;
        params.YB_ID         = handles.YB_ARCHIVE_A_ID;
        params.DATE          = handles.ARCHIVE_SET_A_DATE;
        params.requestDate   = datestr_fmt1;
        params.LOAD_BTN      = handles.LOAD_ARCHIVE_SET_A_BTN;

        [ handles, success ] = getArchivedData ( handles, params );
    end
    
    if ( success )
            handles.ArchiveArequestDate  = datestr_fmt1;
    end
end

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


function  [ new_handles, success] = getArchivedData ( handles, params )

new_handles                                  = handles;
new_handles.loadedCAMdata                    = true;
getNewCAMdata                                = true;
    
[ vals, date, CAM, success ]                 = readArchiveBufferData ( new_handles.CAM, datenum ( params.requestDate ) );

if ( success )
    getNewCAMdata                            = false;
    new_handles.CAM                          = CAM;
    new_handles.CAM.( params.vals_name )     = vals;
    new_handles.CAM.( params.date_name )     = date;
end        
    
if ( getNewCAMdata )        
    [ CAMdata, success ]                     = readArchivedData ( new_handles.CAM, params.requestDate, params.LOAD_BTN );

    if ( success )
        new_handles.CAM.( params.date_name ) = sprintf ( '%s', datestr ( CAMdata ( 2, 1 ), 'yyyy-mm-dd HH:MM:SS' ) );
        new_handles.CAM.( params.vals_name ) = camAngles2CAMstruct ( new_handles.undulatorLine, new_handles.cellList, reshape ( CAMdata ( 1, : ), new_handles.CAM.nmot, new_handles.CAM.cells )', new_handles.geo );

        listPositionData ( new_handles.CAM.( params.vals_name ), params.requestDate, 'CAM', new_handles.cellList )

        [ CAM, success ] = ...
            saveArchiveBufferData ( new_handles.CAM, datenum ( params.requestDate ), new_handles.CAM.( params.vals_name ), new_handles.CAM.( params.date_name ) );
            
        if ( success )
            new_handles.CAM                  = CAM;
        else
            fprintf ( 'Unable to save CAM data to buffer.\n' );
        end
    else
        new_handles.loadedCAMdata            = false;
        fprintf ( 'Unable to get CAM data.\n' );        
    end
end

end


function listPositionData ( data, date, type, list )

fprintf ( '%s data listing for %s\n', type, date );
            
for j = 1 : length ( list )
    c = list ( j );
    
    for k = 1 : 3
        fprintf ( '%3d %d x:%+7.1f microns, y:%+7.1f microns, z:%+9.3f mm, yaw:%+6.3f mrad, pitch:%+6.3f mrad, roll:%+6.3f mrad, \n', c, k, data.x ( k, j ), data.y ( k, j ), data.z ( k, j ), data.yaw ( k, j ), data.pitch ( k, j ), data.r ( k, j ) );
    end
end 

end


function [ ArchivedData, success ] = readArchivedData ( PVinfo, finalTime, progressHandle )
%CAM angles will be returned in [rad].
ArchivedData       = zeros ( 2, PVinfo.nPVs );

success            = true;
finalTime          = sprintf ( '%s', datestr ( datenum ( finalTime ),'mm/dd/yyyy HH:MM:SS' ) );
startTime          = sprintf ( '%s', datestr ( datenum ( finalTime ) - 2.0/24,'mm/dd/yyyy HH:MM:SS' ) );
timeRange          = { startTime; finalTime };

savedProgressHandleString = get ( progressHandle, 'String' );
set ( progressHandle, 'String', '' );

new_ini_date    = datenum ( PVinfo.new_ini_date );

if ( datenum ( finalTime ) > new_ini_date )
    PVs = PVinfo.PVs;
else
    fprintf ( 'No AIDA data avalailable for period %s - %s\n', old_end_date, new_ini_date );
    success = false;
    return;
end

for PV = 1 : PVinfo.nPVs
    set ( progressHandle, 'String', sprintf ( 'Retreiving %s', PVs { PV } ) );
            
    AIDA_Name  = sprintf ( '%s', PVs { PV } );
    
    try
        [ time, T ] = history ( AIDA_Name, timeRange, 'verbose', false);
    catch
        success = false;
    end

    if ( ~success )
        fprintf ( 'Failed getting AIDA parameter => %s (%s - %s)\n', AIDA_Name, timeRange { 1 }, timeRange { 2 } );
        set ( progressHandle, 'String', savedProgressHandleString );
        
       return;
    end
            
    ArchivedData ( 1, PV ) = T ( length ( T ) ) * pi / 180; % Convert from deg to radians
    ArchivedData ( 2, PV ) = time ( length ( T ) );
    
    pause ( 0.001 ); % To give queued tasks a change to catch up.
end

set ( progressHandle, 'String', savedProgressHandleString );

end


function V =  removeCell ( C )
    if ( iscell ( C ) )
        V = C { 1 };
    else
        V = C;
    end
end


function CAM = getCurrentGirderPositions ( undulatorLine, cellList, geo)

CAM = camAngles2CAMstruct ( undulatorLine, cellList, readCamAngles ( undulatorLine, cellList ), geo );

end


function z = setXaxis ( handles, z, j )
%
% j: index into handles.cellList
%
Lcell      = handles.UndConsts.CellLength;
cellOffset = handles.UndConsts.cellOffset;

if ( handles.Line == 'H' )
    z ( 1, j ) = handles.ubeg_zp ( j );
    z ( 2, j ) = handles.uend_zp ( j );
    z ( 3, j ) = handles.quad_zp ( j );

    if ( xAxis_has_GirderNumbers ( handles ) )
        center   = ( z ( 1, j ) + z ( 2, j ) ) /  2;
    
        z ( 1, j ) = ( z ( 1, j ) - center ) / Lcell + 0.01 + j + cellOffset;
        z ( 2, j ) = ( z ( 2, j ) - center ) / Lcell + 0.01 + j + cellOffset;
        z ( 3, j ) = ( z ( 3, j ) - center ) / Lcell + 0.01 + j + cellOffset;
    end
else
    if ( handles.cellList ( j ) == 100 ) % SXRSS Girder
        k          = 35 - cellOffset;
%        z ( 1, j ) = handles.quad_zp ( k ) - 2.2 - 1.8;
%        z ( 2, j ) = handles.quad_zp ( k ) - 2.2;
%        z ( 3, j ) = handles.quad_zp ( k ) - 2.2 + 1.8;
        z ( 1, j ) = handles.quad_zp ( k ) - 3.8;
        z ( 2, j ) = handles.quad_zp ( k ) - 0.3;
        z ( 3, j ) = handles.quad_zp ( k );

        if ( xAxis_has_GirderNumbers ( handles ) )
            center   = z ( 2, j );

            z ( 1, j ) = ( z ( 1, j ) - center ) / Lcell - 0.1 + k + cellOffset;
            z ( 2, j ) = ( z ( 2, j ) - center ) / Lcell - 0.1 + k + cellOffset;
            z ( 3, j ) = ( z ( 3, j ) - center ) / Lcell - 0.1 + k + cellOffset;
        end
    else % SXR interspace plates
        z ( 1, j ) = handles.quad_zp ( j ) - 0.5;
        z ( 2, j ) = handles.quad_zp ( j );
        z ( 3, j ) = handles.quad_zp ( j ) + 0.5;

        if ( xAxis_has_GirderNumbers ( handles ) )
            center   = z ( 2, j );

            z ( 1, j ) = ( z ( 1, j ) - center ) / Lcell - 0.01 + j + cellOffset;
            z ( 2, j ) = ( z ( 2, j ) - center ) / Lcell - 0.01 + j + cellOffset;
            z ( 3, j ) = ( z ( 3, j ) - center ) / Lcell - 0.01 + j + cellOffset;
        end
    end
end        

end


function CAM = camAngles2CAMstruct ( undulatorLine, cellList, CamAngles, geo )
%
% CamAngles are in [rad]
%
% The CAMstruct has the array
%   [x(mm),y(mm),componentZ(mm),pitch(rad),yaw(rad),roll(rad)]
% for each of 3 positions along the girder or cam stage.
% This will encode the yaw and pitch angles into the three x and y values.

Line = upper ( undulatorLine ( 1 ) );

if ( Line == 'H' )
    idUbeg    = 1;
    idUend    = 2;
    idCent    = 3;
else
    idGbeg    = 1;
    idCent    = 2;
    idGend    = 3;
end

cells     = length ( cellList );

CAM.x     = zeros ( 3, cells );
CAM.y     = zeros ( 3, cells );
CAM.z     = zeros ( 3, cells );
CAM.yaw   = zeros ( 3, cells );
CAM.pitch = zeros ( 3, cells );
CAM.r     = zeros ( 3, cells );

QuadAlignments = CamAngles2QuadAlignment ( undulatorLine, cellList, CamAngles );

if ( Line == 'H' )
    UbegAlignments = changeAlignmentZ ( - geo.quadztosegmentEndUpstream,   QuadAlignments );
    UendAlignments = changeAlignmentZ ( - geo.quadztosegmentEndDownstream, QuadAlignments );
    
    CAM.x     ( idUbeg, : ) = UbegAlignments ( :, 1 ) * 1e3; % microns
    CAM.y     ( idUbeg, : ) = UbegAlignments ( :, 2 ) * 1e3; % microns
    CAM.z     ( idUbeg, : ) = UbegAlignments ( :, 3 );       % mm
    CAM.yaw   ( idUbeg, : ) = UbegAlignments ( :, 4 ) * 1e3; % mrad
    CAM.pitch ( idUbeg, : ) = UbegAlignments ( :, 5 ) * 1e3; % mrad
    CAM.r     ( idUbeg, : ) = UbegAlignments ( :, 6 ) * 1e3; % mrad
    
    CAM.x     ( idUend, : ) = UendAlignments ( :, 1 ) * 1e3; % microns
    CAM.y     ( idUend, : ) = UendAlignments ( :, 2 ) * 1e3; % microns
    CAM.z     ( idUend, : ) = UendAlignments ( :, 3 );       % mm
    CAM.yaw   ( idUend, : ) = UendAlignments ( :, 4 ) * 1e3; % mrad
    CAM.pitch ( idUend, : ) = UendAlignments ( :, 5 ) * 1e3; % mrad
    CAM.r     ( idUend, : ) = UendAlignments ( :, 6 ) * 1e3; % mrad

    CAM.x     ( idCent, : ) = QuadAlignments ( :, 1 ) * 1e3; % microns
    CAM.y     ( idCent, : ) = QuadAlignments ( :, 2 ) * 1e3; % microns
    CAM.z     ( idCent, : ) = QuadAlignments ( :, 3 );       % mm
    CAM.yaw   ( idCent, : ) = QuadAlignments ( :, 4 ) * 1e3; % mrad
    CAM.pitch ( idCent, : ) = QuadAlignments ( :, 5 ) * 1e3; % mrad
    CAM.r     ( idCent, : ) = QuadAlignments ( :, 6 ) * 1e3; % mrad
else    
    regularIdx     = find ( cellList ~= 100 );

    if ( any ( regularIdx ) )
        Qus_Alignments = changeAlignmentZ ( - 1800.0, QuadAlignments );
        Qds_Alignments = changeAlignmentZ ( + 1800.0, QuadAlignments );

        CAM.x     ( idGbeg, regularIdx ) = Qus_Alignments ( regularIdx, 1 ) * 1e3; % microns
        CAM.y     ( idGbeg, regularIdx ) = Qus_Alignments ( regularIdx, 2 ) * 1e3; % micron
        CAM.z     ( idGbeg, regularIdx ) = Qus_Alignments ( regularIdx, 3 );       % mm
        CAM.yaw   ( idGbeg, regularIdx ) = Qus_Alignments ( regularIdx, 4 ) * 1e3; % mrad
        CAM.pitch ( idGbeg, regularIdx ) = Qus_Alignments ( regularIdx, 5 ) * 1e3; % mrad
        CAM.r     ( idGbeg, regularIdx ) = Qus_Alignments ( regularIdx, 6 ) * 1e3; % mrad
    
        CAM.x     ( idCent, regularIdx ) = QuadAlignments ( regularIdx, 1 ) * 1e3; % microns
        CAM.y     ( idCent, regularIdx ) = QuadAlignments ( regularIdx, 2 ) * 1e3; % microns
        CAM.z     ( idCent, regularIdx ) = QuadAlignments ( regularIdx, 3 );       % mm
        CAM.yaw   ( idCent, regularIdx ) = QuadAlignments ( regularIdx, 4 ) * 1e3; % mrad
        CAM.pitch ( idCent, regularIdx ) = QuadAlignments ( regularIdx, 5 ) * 1e3; % mrad
        CAM.r     ( idCent, regularIdx ) = QuadAlignments ( regularIdx, 6 ) * 1e3; % mrad

        CAM.x     ( idGend, regularIdx ) = Qds_Alignments ( regularIdx, 1 ) * 1e3; % microns
        CAM.y     ( idGend, regularIdx ) = Qds_Alignments ( regularIdx, 2 ) * 1e3; % microns
        CAM.z     ( idGend, regularIdx ) = Qds_Alignments ( regularIdx, 3 );       % mm
        CAM.yaw   ( idGend, regularIdx ) = Qds_Alignments ( regularIdx, 4 ) * 1e3; % mrad
        CAM.pitch ( idGend, regularIdx ) = Qds_Alignments ( regularIdx, 5 ) * 1e3; % mrad
        CAM.r     ( idGend, regularIdx ) = Qds_Alignments ( regularIdx, 6 ) * 1e3; % mrad
        
%for j = 7 : 7        
%    fprintf ( '%3d %+10.3f microns %+10.3f microns %+10.3f micro-rad %+10.3f micro-rad\n', cellList(j), CAM.x ( idCent, j ), CAM.y ( idCent, j ), CAM.yaw ( idCent, j ) * 1000, CAM.pitch( idCent, j ) * 1000 );
%end

    end

    SXRSS_Idx      = find ( cellList == 100 );

    if ( any ( SXRSS_Idx ) )
        Gds_Alignments = changeAlignmentZ ( -  300.0, QuadAlignments );
        Gus_Alignments = changeAlignmentZ ( - 3800.0, QuadAlignments );

        CAM.x     ( idGbeg, SXRSS_Idx ) = Gus_Alignments ( SXRSS_Idx, 1 ) * 1e3; % microns
        CAM.y     ( idGbeg, SXRSS_Idx ) = Gus_Alignments ( SXRSS_Idx, 2 ) * 1e3; % microns
        CAM.z     ( idGbeg, SXRSS_Idx ) = Gus_Alignments ( SXRSS_Idx, 3 );       % mm
        CAM.yaw   ( idGbeg, SXRSS_Idx ) = Gus_Alignments ( SXRSS_Idx, 4 ) * 1e3; % mrad
        CAM.pitch ( idGbeg, SXRSS_Idx ) = Gus_Alignments ( SXRSS_Idx, 5 ) * 1e3; % mrad
        CAM.r     ( idGbeg, SXRSS_Idx ) = Gus_Alignments ( SXRSS_Idx, 6 ) * 1e3; % mrad
    
        CAM.x     ( idCent, SXRSS_Idx ) = Gds_Alignments ( SXRSS_Idx, 1 ) * 1e3; % microns
        CAM.y     ( idCent, SXRSS_Idx ) = Gds_Alignments ( SXRSS_Idx, 2 ) * 1e3; % microns
        CAM.z     ( idCent, SXRSS_Idx ) = Gds_Alignments ( SXRSS_Idx, 3 );       % mm
        CAM.yaw   ( idCent, SXRSS_Idx ) = Gds_Alignments ( SXRSS_Idx, 4 ) * 1e3; % mrad
        CAM.pitch ( idCent, SXRSS_Idx ) = Gds_Alignments ( SXRSS_Idx, 5 ) * 1e3; % mrad
        CAM.r     ( idCent, SXRSS_Idx ) = Gds_Alignments ( SXRSS_Idx, 6 ) * 1e3; % mrad

        CAM.x     ( idGend, SXRSS_Idx ) = QuadAlignments ( SXRSS_Idx, 1 ) * 1e3; % microns
        CAM.y     ( idGend, SXRSS_Idx ) = QuadAlignments ( SXRSS_Idx, 2 ) * 1e3; % microns
        CAM.z     ( idGend, SXRSS_Idx ) = QuadAlignments ( SXRSS_Idx, 3 );       % mm
        CAM.yaw   ( idGend, SXRSS_Idx ) = QuadAlignments ( SXRSS_Idx, 4 ) * 1e3; % mrad
        CAM.pitch ( idGend, SXRSS_Idx ) = QuadAlignments ( SXRSS_Idx, 5 ) * 1e3; % mrad
        CAM.r     ( idGend, SXRSS_Idx ) = QuadAlignments ( SXRSS_Idx, 6 ) * 1e3; % mrad
    end
end

end


% --- Executes on button press in MOVE_GIRDERS_BTN.
function MOVE_GIRDERS_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to MOVE_GIRDERS_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

if ( ~get ( handles.CAM_MOTION_ENABLED_CHECKBOX, 'Value' ) )
    return;
end

cellList                    = handles.UndConsts.allCamStages';
Line                        = upper ( handles.undulatorLine ( 1 ) );

if ( Line == 'H' )
    idQuad                  = 3;
else
    idQuadRegular           = 2;
    idSXRSS                 = 3;
end

QuadAlignments_rb           = CamAngles2QuadAlignment ( handles.undulatorLine, handles.cellList, readCamAngles ( handles.undulatorLine, handles.cellList ) );
QuadAlignments_sp           = QuadAlignments_rb;

x_old                       = QuadAlignments_rb ( :, 1 );
y_old                       = QuadAlignments_rb ( :, 2 );
yaw_old                     = QuadAlignments_rb ( :, 4 );
pitch_old                   = QuadAlignments_rb ( :, 5 );

if ( Line == 'H' )
    dx                          = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.x     ( idQuad, : ) / 1000; % mm
    dy                          = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.y     ( idQuad, : ) / 1000; % mm
    dyaw                        = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.yaw   ( idQuad, : ) / 1000; % rad
    dpitch                      = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.pitch ( idQuad, : ) / 1000; % rad
else
    regularIdx     = find ( cellList ~= 100 );

    if ( any ( regularIdx ) )
        dx ( regularIdx )       = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.x     ( idQuadRegular, regularIdx ) / 1000; % mm
        dy ( regularIdx )       = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.y     ( idQuadRegular, regularIdx ) / 1000; % mm
        dyaw ( regularIdx )     = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.yaw   ( idQuadRegular, regularIdx ) / 1000; % rad
        dpitch ( regularIdx )   = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.pitch ( idQuadRegular, regularIdx ) / 1000; % rad
    end

    SXRSS_Idx      = find ( cellList == 100 );

    if ( any ( SXRSS_Idx ) )
        dx ( SXRSS_Idx )        = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.x     ( idSXRSS, SXRSS_Idx ) / 1000; % mm
        dy ( SXRSS_Idx )        = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.y     ( idSXRSS, SXRSS_Idx ) / 1000; % mm
        dyaw ( SXRSS_Idx )      = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.yaw   ( idSXRSS, SXRSS_Idx ) / 1000; % rad
        dpitch ( SXRSS_Idx )    = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.pitch ( idSXRSS, SXRSS_Idx ) / 1000; % rad
    end
end

dx     ( isnan ( dx ) )     = 0;
dy     ( isnan ( dy ) )     = 0;
dyaw   ( isnan ( dyaw ) )   = 0;
dpitch ( isnan ( dpitch ) ) = 0;

x_new                       = x_old     - dx';
y_new                       = y_old     - dy';
yaw_new                     = yaw_old   - dyaw';
pitch_new                   = pitch_old - dpitch';

fprintf ( '\n                          x[microm] y[microm] yaw[microrad] pitch[microrad]     x[microm]  y[microm] yaw[microrad] pitch[microrad]\n' );

for j = 1 : handles.cells
    c       = handles.cellList ( j );

    fprintf ( 'Changing girder %3d from  %+8.3f  %+8.3f    %+8.3f        %+8.3f', c, x_old ( j ) * 1e3, y_old ( j ) * 1e3, yaw_old ( j ) * 1e6, pitch_old ( j ) * 1e6 );
    fprintf (                  '    to   %+8.3f  %+8.3f    %+8.3f        %+8.3f\n',  x_new ( j ) * 1e3, y_new ( j ) * 1e3, yaw_new ( j ) * 1e6, pitch_new ( j ) * 1e6 );
end

fprintf ( '\n' );

btnString = get ( handles.MOVE_GIRDERS_BTN, 'String' );

set ( handles.MOVE_GIRDERS_BTN, 'String', 'Moving ...' );

QuadAlignments_sp ( :, 1 ) = x_new;
QuadAlignments_sp ( :, 2 ) = y_new;
QuadAlignments_sp ( :, 4 ) = yaw_new;
QuadAlignments_sp ( :, 5 ) = pitch_new;

setCamAngles ( handles.undulatorLine, handles.cellList, Alignment2CamAngles (  handles.undulatorLine, handles.cellList, QuadAlignments_sp ) );

set ( handles.MOVE_GIRDERS_BTN, 'String', btnString );

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


function fittedGirderPositions = fitGirderPositions ( GirderPositions, cellList, UndConsts )

fittedGirderPositions = GirderPositions;
cells                 = length ( cellList );
z                     = zeros ( 3, cells );

for j = 1 : length ( cellList )                                   
    z ( 1, j ) = UndConsts.firstUbegz + ( j - 1 ) * UndConsts.CellLength;
    z ( 2, j ) = UndConsts.firstUendz + ( j - 1 ) * UndConsts.CellLength;
    z ( 3, j ) = UndConsts.firstQuadz + ( j - 1 ) * UndConsts.CellLength;
end

fittedGirderPositions.x = findBaseline ( z, GirderPositions.x );
fittedGirderPositions.y = findBaseline ( z, GirderPositions.y );

end


function baseline = findBaseline ( x, y )

[ Pos1coeffs, ~, Pos1_S ] = removeLinear_DropResiduals ( x ( 1, : ), y ( 1, : ) );

Pos1baseline = polyval ( Pos1coeffs, x ( 1, : ), Pos1_S );
rmsPos1move  = std ( y ( 1, : ) - Pos1baseline );

[ Pos2coeffs, ~, Pos2_S ] = removeLinear_DropResiduals ( x ( 2, : ), y ( 2, : ) );

Pos2baseline = polyval ( Pos2coeffs, x ( 2, : ), Pos2_S );
rmsPos2move  = std ( y ( 2, : ) - Pos2baseline );

[ Pos3coeffs, ~, Pos3_S ] = removeLinear_DropResiduals ( x ( 3, : ), y ( 3, : ) );

Pos3baseline = polyval ( Pos3coeffs, x ( 3, : ), Pos3_S );
rmsPos3move  = std ( y ( 3, : ) - Pos3baseline );

rmsList       = [ rmsPos1move rmsPos2move rmsPos3move ];
[ ~, indmin ] = min ( rmsList ); 

baseline = y;

%switch indmin
%    case 1
%        baseline ( 1, : ) = polyval ( Pos1coeffs, x ( 1, : ), Pos1_S );
%    case 2
%        baseline ( 1, : ) = polyval ( Pos2coeffs, x ( 2, : ), Pos2_S );
%    otherwise
%        baseline ( 1, : ) = polyval ( Pos3coeffs, x ( 3, : ), Pos3_S );
%end

%baseline ( 2, : ) = baseline ( 1, : );
%baseline ( 3, : ) = baseline ( 1, : );


baseline ( 1, : ) = polyval ( Pos1coeffs, x ( 1, : ), Pos1_S );
baseline ( 2, : ) = polyval ( Pos1coeffs, x ( 2, : ), Pos2_S );
baseline ( 3, : ) = polyval ( Pos1coeffs, x ( 3, : ), Pos3_S );

end


function [ fitcoeffs, fiterror, S ] = removeLinear_DropResiduals ( x, y )

polyOrder             = 1;
n                     = length ( x );
new_n                 = 0;

fitx                  = x;
fity                  = y;

while ( new_n < n )
    n                      = length ( fitx );
    [ fitcoeffs, S ]       = polyfit ( fitx, fity, polyOrder );
    [ fitcurve, fiterror ] = polyval ( fitcoeffs, fitx, S );

    residuals              = fity - fitcurve;
    cutoff                 = 2.1 * std ( residuals );
    index                  = find ( abs ( residuals ) < cutoff );

    if ( ~any ( index ) )
        return;
    end

    new_n                  = length ( index );
    fitx                   = fitx ( index );
    fity                   = fity ( index );
end

end


function [ vals, date, newInfo, success ] = readArchiveBufferData ( Info, recID )

success    = true;
newInfo    = Info;
vals       = 0;
date       = '';

fp = strcat ( newInfo.fb, newInfo.fn );

if ( ~newInfo.buffer_loaded )
    if ( exist ( fp, 'file' ) )
        mat                    = load ( fp );
        newInfo.buffer         = mat.archive;
        newInfo.buffer_records = mat.records;
        newInfo.buffer_recIDs  = mat.recIDs;
        newInfo.buffer_loaded  = true;
    else
        success = false;
        return;
    end
end

rec = find ( recID == newInfo.buffer_recIDs );

if ( ~any ( rec ) )
    success = false;
    return;
else
    rec = rec ( 1 );
end

vals = newInfo.buffer { rec }.values;
date = newInfo.buffer { rec }.time;

end


function [ newInfo, success ] = saveArchiveBufferData ( Info, recID, data, Date )

success = true;
newInfo = Info;

fp      = strcat ( newInfo.fb, newInfo.fn );

if ( ~newInfo.buffer_loaded )
    if ( exist ( fp, 'file' ) )
        mat                    = load ( fp );
        newInfo.buffer         = mat.archive;
        newInfo.buffer_records = mat.records;
        newInfo.buffer_recIDs  = mat.recIDs;
        newInfo.buffer_loaded  = true;
    else
        if ( ~exist ( newInfo.fb, 'dir' ) )
            mkdir ( newInfo.fb );
        end
        
        if ( ~exist ( newInfo.fb, 'dir' ) )
            fprintf ('Unable to create folder "%s"\n', newInfo.fb );
            success = false;
            fprintf ( 'Leaving saveArchiveBufferData\n' );
            return;
        end

        newInfo.buffer_records = 0;
    end
end

newInfo.buffer_records                                  = newInfo.buffer_records + 1;
newInfo.buffer        { newInfo.buffer_records }.values = data;
newInfo.buffer        { newInfo.buffer_records }.time   = Date;
newInfo.buffer_recIDs ( newInfo.buffer_records )        = recID;

recIDs                                                  = newInfo.buffer_recIDs;
records                                                 = newInfo.buffer_records;
archive                                                 = newInfo.buffer;

save ( fp, 'recIDs', 'records', 'archive' );
fprintf ( 'Saved buffer to %s\n', fp );

end


function ARCHIVE_SET_A_DATE_REQUEST_Callback(hObject, eventdata, handles)
% hObject    handle to ARCHIVE_SET_A_DATE_REQUEST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ARCHIVE_SET_A_DATE_REQUEST as text
%        str2double(get(hObject,'String')) returns contents of ARCHIVE_SET_A_DATE_REQUEST as a double

success = true;

try
    date = datenum ( get ( hObject, 'String' ) );
catch
    success = false;
end

if ( success )   
    date = min ( date, now );
    date = max ( date, datenum ( '04/01/2009 00:00:00' ) );
    
    DateStr = datestr ( date, 'mm/dd/yyyy HH:MM:SS' );
else
    DateStr = datestr ( now,  'mm/dd/yyyy HH:MM:SS' );
end

set ( hObject, 'String', DateStr );

end


% --- Executes during object creation, after setting all properties.
function ARCHIVE_SET_A_DATE_REQUEST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ARCHIVE_SET_A_DATE_REQUEST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in LOAD_ARCHIVE_SET_B_BTN.
function LOAD_ARCHIVE_SET_B_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to LOAD_ARCHIVE_SET_B_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

success = true;

try
    datestring = get ( handles.ARCHIVE_SET_B_DATE_REQUEST, 'String' );
    
    if ( any ( datestring ) )
        date = datenum ( datestring );
    end
    
    if ( date < 1 )
        success = false;
    end
catch
    success = false;
end

if ( success )
    datestr_fmt1 = datestr ( date, 'mm/dd/yyyy HH:MM:SS' );

    getNewCamdata = true;
    
    if ( isfield ( handles, 'ArchiveBrequestDate' ) )
        if ( datestr_fmt1 == handles.ArchiveBrequestDate )
            fprintf ( 'Date already loaded\n' );
        end
    end

    handles.ArchiveBrequestDate  = datestr_fmt1;

    if ( getNewCamdata )
        params.getNewADSdata = getNewCamdata;
        params.vals_name     = 'archive_B_vals';
        params.date_name     = 'archive_B_date';
        params.YA_ID         = handles.YA_ARCHIVE_B_ID;
        params.YB_ID         = handles.YB_ARCHIVE_B_ID;
        params.DATE          = handles.ARCHIVE_SET_B_DATE;
        params.requestDate   = handles.ArchiveBrequestDate;
        params.LOAD_BTN      = handles.LOAD_ARCHIVE_SET_B_BTN;

        handles = getArchivedData ( handles, params );
    end
end

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


function ARCHIVE_SET_B_DATE_REQUEST_Callback(hObject, eventdata, handles)
% hObject    handle to ARCHIVE_SET_B_DATE_REQUEST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ARCHIVE_SET_B_DATE_REQUEST as text
%        str2double(get(hObject,'String')) returns contents of ARCHIVE_SET_B_DATE_REQUEST as a double

success = true;

try
    date = datenum ( get ( hObject, 'String' ) );
catch
    success = false;
end

if ( success )   
    date = min ( date, now );
    date = max ( date, datenum ( '04/01/2009 00:00:00' ) );
    
    DateStr = datestr ( date, 'mm/dd/yyyy HH:MM:SS' );
else
    DateStr = datestr ( now,  'mm/dd/yyyy HH:MM:SS' );
end

set ( hObject, 'String', DateStr );

end


% --- Executes during object creation, after setting all properties.
function ARCHIVE_SET_B_DATE_REQUEST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ARCHIVE_SET_B_DATE_REQUEST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in SHOW_SEG_NUMBERS_CHECKBOX.
function SHOW_SEG_NUMBERS_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to SHOW_SEG_NUMBERS_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SHOW_SEG_NUMBERS_CHECKBOX

end


% --- Executes on button press in SHOW_QUAD_NUMBERS_CHECKBOX.
function SHOW_QUAD_NUMBERS_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to SHOW_QUAD_NUMBERS_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SHOW_QUAD_NUMBERS_CHECKBOX

end


% --- Executes on selection change in DISPLAY_MODE_MENU.
function DISPLAY_MODE_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAY_MODE_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAY_MODE_MENU contents as c array
%        contents{get(hObject,'Value')} returns selected item from DISPLAY_MODE_MENU

global timerData;

adjustCAMcheckboxDisplays ( handles );

handles  = eraseHistory ( handles, handles.YA_IDs, handles.YB_IDs );

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function DISPLAY_MODE_MENU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAY_MODE_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in USE_CAM_REFERENCE_CHECKBOX.
function USE_CAM_REFERENCE_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_CAM_REFERENCE_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_CAM_REFERENCE_CHECKBOX

global timerData;

handles  = eraseHistory ( handles, handles.YA_IDs, handles.YB_IDs );

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in REM_LIN_CHECKBOX.
function REM_LIN_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to REM_LIN_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of REM_LIN_CHECKBOX

global timerData;

handles  = eraseHistory ( handles, handles.YA_IDs, handles.YB_IDs );

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in CAM_MOTION_ENABLED_CHECKBOX.
function CAM_MOTION_ENABLED_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to CAM_MOTION_ENABLED_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CAM_MOTION_ENABLED_CHECKBOX

if ( get ( handles.CAM_MOTION_ENABLED_CHECKBOX, 'Value' )  )
    set ( handles.CAM_MOTION_ENABLED_LABEL, 'String', 'Disable Cam Motion' );
    set ( handles.MOVE_GIRDERS_BTN,            'Visible', 'On' );
else
    set ( handles.CAM_MOTION_ENABLED_LABEL, 'String', 'Enable Cam Motion' );
    set ( handles.MOVE_GIRDERS_BTN,            'Visible', 'Off' );
end

end


function SEG_PREC_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to SEG_PREC_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SEG_PREC_EDIT as text
%        str2double(get(hObject,'String')) returns contents of SEG_PREC_EDIT as a double

btnString = get ( handles.SEG_PREC_EDIT, 'String' );

btnValue = str2double ( btnString );

if ( isnan ( btnValue ) )
    btnValue = 0;
else
    btnValue = floor ( abs ( btnValue ) );
end

set ( handles.SEG_PREC_EDIT, 'Value', btnValue );
set ( handles.SEG_PREC_EDIT, 'String', sprintf ( '%.0f', btnValue ) );

end


% --- Executes during object creation, after setting all properties.
function SEG_PREC_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SEG_PREC_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function QUAD_PREC_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to QUAD_PREC_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QUAD_PREC_EDIT as text
%        str2double(get(hObject,'String')) returns contents of QUAD_PREC_EDIT as a double

btnString = get ( handles.QUAD_PREC_EDIT, 'String' );

btnValue = str2double ( btnString );

if ( isnan ( btnValue ) )
    btnValue = 0;
else
    btnValue = floor ( abs ( btnValue ) );
end

set ( handles.QUAD_PREC_EDIT, 'Value', btnValue );
set ( handles.QUAD_PREC_EDIT, 'String', sprintf ( '%.0f', btnValue ) );

end


% --- Executes during object creation, after setting all properties.
function QUAD_PREC_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QUAD_PREC_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function Y_SCALE_Callback(hObject, eventdata, handles)
% hObject    handle to Y_SCALE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y_SCALE as text
%        str2double(get(hObject,'String')) returns contents of Y_SCALE as a double

Yscale = get ( hObject, 'String' );

Yscale = upper ( Yscale );

if ( strfind ( Yscale, 'A' ) )
    set ( hObject, 'String', 'AUTO' );
    set ( hObject, 'Value',  0 );
else
    Yscale = floor ( abs ( str2double ( Yscale ) ) );
    
    if ( Yscale )
        set ( hObject, 'String', sprintf ( '%d', Yscale ) );
        set ( hObject, 'Value',  Yscale );
    else
        set ( hObject, 'String', 'AUTO' );
        set ( hObject, 'Value',  0 );
    end    
end

end


% --- Executes during object creation, after setting all properties.
function Y_SCALE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_SCALE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in PRINTLOGBOOK.
function PRINTLOGBOOK_Callback(hObject, eventdata, handles)
% hObject    handle to PRINTLOGBOOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

saveData ( handles );

if ( isfield ( handles, 'log_fig' ) )
    fig = handles.log_fig;
else
    fprintf ( 'No plot request.\n' );
    return;
end

if ( any ( find ( findobj == fig ) ) ) % Avoid problems in case the user closed the figure before the gui window.
    if ( handles.printTo_Files || handles.printTo_e_Log )
        handles = manageDataChannels ( handles );

        handles = updatePlots ( handles, handles.log_fig_X_axes, handles.log_fig_Y_axes );

        ItemA =  removeCell ( handles.DisplayItem_A );
        DateA =  removeCell ( handles.DisplayDate_A );
        ItemB =  removeCell ( handles.DisplayItem_B );
        DateB =  removeCell ( handles.DisplayDate_B );

        if ( ~isnan ( DateB ) )
            titleText = sprintf ( '%s (%s) - %s (%s)', ItemA, DateA, ItemB, DateB );
        else
            titleText = sprintf ( '%s (%s)', ItemA, DateA );
        end
    
        title ( titleText, 'Parent', handles.log_fig_X_axes );
        
        modeStr = formatModeString ( handles );
            
        textPos = estimatePosition ( 50, 101.8,  axis ( handles.log_fig_X_axes ) );
        textStr = sprintf ( 'Displaying %s Readings', modeStr );
        text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'center', 'FontSize', 8, 'Parent', handles.log_fig_X_axes );
        
        textPos = estimatePosition ( 110, -27,  axis ( handles.log_fig_Y_axes ) );
        textStr = sprintf ( 'BBA Reference Date: %s', handles.CAM.reference_date );
        text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'right', 'FontSize', 8, 'Parent', handles.log_fig_Y_axes );
    end

    if ( handles.printTo_e_Log )
%        print ( fig, '-dpsc2', '-Pphysics-lclslog', '-adobecset' );
        util_printLog_wComments(gcf,'Nuhn',sprintf ( '%s alignment plot', handles.undulatorLine ),mfilename);
        print ( fig, '-dpsc2', '-Pphysics-lclslog' );

        fprintf ( 'sent plots to physics-lclslog.\n' );
    end
    
    if ( handles.printTo_Files )
        refDate         = now;
        [ fp, success ] = createFolder ( [ handles.fb handles.undulatorLine '/' ], refDate );
        
        if ( success )
            figName = sprintf ( 'CamAlignmentDiagnostics--%s', datestr ( refDate, 'yyyy-mm-dd-HHMMSS' ) );

            fn      = strcat ( fp, figName );
            
            print ( fig, '-dpdf',  '-r300', fn ); 
            print ( fig, '-djpeg', '-r300', fn );
        else
            fprintf ( 'Unable to create folder.\n' );
        end
    end    
end

end


function modeStr = formatModeString ( handles )
    
modeStr = sprintf ( 'only CAM' );

end


function pos = estimatePosition ( pctX, pctY, frame )

X0 = frame ( 1 );
Y0 = frame ( 3 );
W  = frame ( 2 ) - frame ( 1 );
H  = frame ( 4 ) - frame ( 3 );

X = X0 + W * pctX / 100;
Y = Y0 + H * pctY / 100;

pos = [ X, Y ];

end


function saveData ( handles )

refDate         = now;
[ fp, success ] = createFolder ( [ handles.fb handles.undulatorLine '/' ], refDate );

if  ( success )    
    handles.fn = sprintf ( 'CamAlignmentDiagnostics--%s.mat', datestr ( refDate, 'yyyy-mm-dd-HHMMSS' ) );
    handles.fd = sprintf ( '%s%s', fp, handles.fn );
    save ( handles.fd, 'handles' );
    
    fprintf ( 'Saved data to %s\n', handles.fn ); 
else
    fprintf ( 'Unable to save data.\n' ); 
end

end


function [ path, success ] = createFolder ( base, refDate )

path    = sprintf ( '%s%s/%s/%s/', base, datestr ( refDate, 'yyyy' ), datestr ( refDate, 'yyyy-mm' ), datestr ( refDate, 'yyyy-mm-dd' ) );
success = true;

if ( exist ( path, 'dir' ) )
    return;
else
    mkdir ( path )
end

if ( ~exist ( path, 'dir' ) )
    success = false;
    return;
end

end


% --- Executes when user attempts to close checkOP_gui.
function CloseRequestFcn ( hObject, eventdata, handles )

global timerRunning;
global timerObj;
global debug;

if ( timerRunning)
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
    timerRunning = false;    
end

fig = handles.log_fig;

if ( any ( find ( findobj == fig ) ) ) % Avoid problems in case the user closed the figure before the gui window.
    delete ( fig );
end

fprintf ( 'Closing  CamAlignmentDiagnostics_gui.\n' );

util_appClose ( hObject );
lcaClear ( );

end


% --- Executes on button press in SET_STC_REFERENCE_BTN.
function xSET_STC_REFERENCE_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_STC_REFERENCE_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vals = handles.CAM.archive_A_vals;
date = handles.CAM.archive_A_date;

lcaPut ( 'ADS:HXR:SI:REF:TIME', datestr ( date, 'mm/dd/yyyy HH:MM:SS' ) );

n = length ( vals.x );

for slot = 1 : n / 2
    jb = ( slot - 1 ) * 2 + 1;
    jq = ( slot - 1 ) * 2 + 2;

%    fprintf ( '%2.2d: x: %f; y: %f; r: %f\n', slot, vals.x ( jb ), vals.y ( jb ), vals.r ( jb ) );
%    fprintf (    '    x: %f; y: %f; r: %f\n',       vals.x ( jq ), vals.y ( jq ), vals.r ( jq ) );

    lcaPut ( handles.CAM.refPVs { handles.CAM.PVindex ( slot, 1, 1 ) }, zeroNaN (vals.x ( jb ) ) );
    lcaPut ( handles.CAM.refPVs { handles.CAM.PVindex ( slot, 1, 2 ) }, zeroNaN (vals.y ( jb ) ) );
    lcaPut ( handles.CAM.refPVs { handles.CAM.PVindex ( slot, 1, 3 ) }, zeroNaN (vals.r ( jb ) ) );

    lcaPut ( handles.CAM.refPVs { handles.CAM.PVindex ( slot, 2, 1 ) }, zeroNaN (vals.x ( jq ) ) );
    lcaPut ( handles.CAM.refPVs { handles.CAM.PVindex ( slot, 2, 2 ) }, zeroNaN (vals.y ( jq ) ) );
    lcaPut ( handles.CAM.refPVs { handles.CAM.PVindex ( slot, 2, 3 ) }, zeroNaN (vals.r ( jq ) ) );
end

% Copy the LTQ readings for the fixed sensors upstream of the first girder
% to the RFQ location. This readings is presently not monitored.

lcaPut ( 'ADS:HXR:100:RFBPM_RFQ_XPOS', zeroNaN ( lcaGet ( 'ADS:HXR:100:RFBPM_LTQ_XPOS' ) ) );
lcaPut ( 'ADS:HXR:100:RFBPM_RFQ_YPOS', zeroNaN ( lcaGet ( 'ADS:HXR:100:RFBPM_LTQ_YPOS' ) ) );
lcaPut ( 'ADS:HXR:100:RFBPM_REF_ROLL', zeroNaN ( lcaGet ( 'ADS:HXR:100:RFBPM_LTC_ROLL' ) ) );

end


function c = zeroNaN ( x )

if ( isnan ( x ) )
    c = 0;
else
    c = x;
end

end


% --- Executes on button press in SWITCH_BEAMLINE.
function SWITCH_BEAMLINE_Callback(hObject, eventdata, handles)
% hObject    handle to SWITCH_BEAMLINE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;
global timerObj;
global timerRunning;

if ( strcmp ( handles.undulatorLine, 'HXR' ) )
    handles.undulatorLine = 'SXR';
    handles.fb            = '/u1/lcls/matlab/CamAlignmentDiagnostics_gui/SXR/';
else
    handles.undulatorLine = 'HXR';
    handles.fb            = '/u1/lcls/matlab/CamAlignmentDiagnostics_gui/HXR/';
end

handles.initialize          = true;

clear ( 'handles.CAM.reference_vals' );
clear ( 'handles.dispHistory' );
clear ( 'handles.dateHistory' );
clear ( 'handles.DisplayValue' );
clear ( 'handles.CAM' );

handles = initializeData ( hObject, handles );
handles = updateDisplay ( handles, handles.XFIGURE, handles.YFIGURE );

setContinuousRefreshMode ( handles );

% Update handles structure
guidata(hObject, handles);

end

function handles = initializeData ( hObject, handles )

handles.Line = upper ( strtrim ( handles.undulatorLine ) );
handles.Line = handles.Line ( 1 );

if ( handles.Line == 'H' )
    handles.geo       = HXRGeo; % for z position data
    handles.UndConsts = util_HXRUndulatorConstants;
%    fmtXOFFB          = 'BPMS:UNDH:%d90:XOFF.B';
%    fmtYOFFB          = 'BPMS:UNDH:%d90:YOFF.B';
    handles.fmtRB     = 'MOVR:UNDH:%d50:CM%sMOTOR.RBV';
%    fmtSP             = 'MOVR:UNDH:%d50:CM%dMOTOR';
%    fmtM              = 'MOVR:UNDH:%d50:CAMSMOVINGM';

    BBArefDatePV       = 'SIOC:SYS0:ML04:AO036';
    BackgroundColor   = [ 202/255, 214/255, 230/255 ];
else
    handles.geo      = []; % Not used for SXR handling
%    handles.geo       = SXRGeo; % for z position data
    handles.UndConsts = util_SXRUndulatorConstants;
%    fmtXOFFB          = 'BPMS:UNDS:%d90:XOFF.B';
%    fmtYOFFB          = 'BPMS:UNDS:%d90:YOFF.B';
%    handles.fmtRB     = 'MOVR:UNDS:%d80:CM%s:READDEG';
%    handles.fmtRB100  = 'MOVR:UNDS:%d50:CM%s:READDEG';
    handles.fmtRB     = 'MOVR:UNDS:%d80:CM%s:MOTR.RBV';
    handles.fmtRB100  = 'MOVR:UNDS:%d50:CM%s:MOTR.RBV';
%    fmtSP             = 'MOVR:UNDS:%d80:CM%d:MOTR';
%    fmtM              = 'MOVR:UNDS:%d80:CAMSMOVDONE';
%    fmtC              = 'MOVR:UNDS:%d80:TRIGGERCAL.PROC';

    BBArefDatePV       = 'SIOC:SYS0:ML04:AO037';
    BackgroundColor    = [ 230/255, 184/255, 179/255 ];
end

set ( gcf,                                  'Color',           BackgroundColor );
set ( handles.DATA_PANEL,                   'BackgroundColor', BackgroundColor );
set ( handles.DATESTRING,                   'BackgroundColor', BackgroundColor );
set ( handles.GUI_TITLE,                    'BackgroundColor', BackgroundColor );
set ( handles.RESETDATE,                    'BackgroundColor', BackgroundColor );
set ( handles.BBA_REFERENCE,                'BackgroundColor', BackgroundColor );
set ( handles.USE_CAM_REFERENCE_LABEL,      'BackgroundColor', BackgroundColor );
set ( handles.USE_CAM_REFERENCE_CHECKBOX,   'BackgroundColor', BackgroundColor );
set ( handles.BBA_REFERENCE_DATE,           'BackgroundColor', BackgroundColor );
set ( handles.INITIALDATE,                  'BackgroundColor', BackgroundColor );
set ( handles.INITIAL_DATA_TAKEN,           'BackgroundColor', BackgroundColor );
set ( handles.TAKE_SNAPSHOT,                'BackgroundColor', BackgroundColor );
set ( handles.CAM_SNAPSHOTDATE,             'BackgroundColor', BackgroundColor );
set ( handles.LOAD_ARCHIVE_SET_A_BTN,       'BackgroundColor', BackgroundColor );
set ( handles.ARCHIVE_SET_A_DATE,           'BackgroundColor', BackgroundColor );
set ( handles.LOAD_ARCHIVE_SET_B_BTN,       'BackgroundColor', BackgroundColor );
set ( handles.ARCHIVE_SET_B_DATE,           'BackgroundColor', BackgroundColor );
set ( handles.REM_LIN_LABEL,                'BackgroundColor', BackgroundColor );
set ( handles.REM_LIN_CHECKBOX,             'BackgroundColor', BackgroundColor );
set ( handles.FIGURE_CONTROL_PANEL,         'BackgroundColor', BackgroundColor );
set ( handles.YAXIS,                        'BackgroundColor', BackgroundColor );
set ( handles.YSCALE,                       'BackgroundColor', BackgroundColor );
set ( handles.Y_AXIS_QUANTITY_A_MENU,       'BackgroundColor', BackgroundColor );
set ( handles.Y_AXIS_QUANTITY_HYPHEN,       'BackgroundColor', BackgroundColor );
set ( handles.Y_AXIS_QUANTITY_B_MENU,       'BackgroundColor', BackgroundColor );
set ( handles.X_AXIS_QUANTITY_BTN,          'BackgroundColor', BackgroundColor );
set ( handles.SHOW_POSITION_VALUE,          'BackgroundColor', BackgroundColor );
set ( handles.SHOW_SEG_NUMBERS_LABEL,       'BackgroundColor', BackgroundColor );
set ( handles.SHOW_SEG_NUMBERS_CHECKBOX,    'BackgroundColor', BackgroundColor );
set ( handles.SEG_NUMBER_PREC_LABEL,        'BackgroundColor', BackgroundColor );
set ( handles.SHOW_QUAD_NUMBERS_LABEL,      'BackgroundColor', BackgroundColor );
set ( handles.SHOW_QUAD_NUMBERS_CHECKBOX,   'BackgroundColor', BackgroundColor );
set ( handles.QUAD_NUMBER_PREC_LABEL,       'BackgroundColor', BackgroundColor );
set ( handles.GIRDER_CONTROL_PANEL,         'BackgroundColor', BackgroundColor );
set ( handles.CAM_MOTION_ENABLED_LABEL,     'BackgroundColor', BackgroundColor );
set ( handles.CAM_MOTION_ENABLED_CHECKBOX,  'BackgroundColor', BackgroundColor );
set ( handles.MOVE_GIRDERS_BTN,             'BackgroundColor', BackgroundColor );
set ( handles.QUAD_NUMBER_PREC_LABEL,       'BackgroundColor', BackgroundColor );

%USEG:UNDH:%d50:UndulatorError : 1 fault; 0 fine.

handles.cellList            = handles.UndConsts.allCamStages;
handles.cells               = length ( handles.cellList );

if ( handles.printTo_Files || handles.printTo_e_Log )
    if ( handles.showLogFigure )
        handles.log_fig         = figure ( 'Visible', 'On' );
    else
        handles.log_fig         = figure ( 'Visible', 'Off' );
    end
    
    handles.log_fig_X_axes  = subplot ( 2, 1, 1 );
    handles.log_fig_Y_axes  = subplot ( 2, 1, 2 );
end

handles.CAM.motors          = { '1',  '2', '3', '4', '5' };
handles.CAM.cellList        = handles.cellList;
handles.CAM.cells           = handles.cells;
handles.CAM.nmot            = length ( handles.CAM.motors );
handles.CAM.PVindex         = zeros ( handles.cells, handles.CAM.nmot );
handles.CAM.nPVs            = handles.CAM.cells * handles.CAM.nmot; 
handles.CAM.PVs             = cell (handles.CAM.nPVs, 1 );
handles.CAM.fb              = handles.fb;
handles.CAM.fn              = 'ArchivedCAMbuffer.mat';
handles.CAM.buffer_loaded   = false;
%handles.CAM.old_end_date    = '07/10/2009 10:11:00';handles.undulatorLine
%handles.CAM.mid_ini_date    = '07/10/2009 18:05:00';
%handles.CAM.mid_end_date    = '07/16/2009 15:39:00';
handles.CAM.new_ini_date    = '07/16/2009 17:40:30';

PVindex = 0;

for slot = handles.cellList
    for m = 1 : handles.CAM.nmot
        PVindex                         = PVindex + 1;
        handles.CAM.PVindex ( slot, m ) = PVindex;
        
        if ( handles.Line == 'S' && slot == 100 )
            handles.CAM.PVs    { PVindex }  = sprintf ( handles.fmtRB100, 35, handles.CAM.motors { m } );
        else
            handles.CAM.PVs    { PVindex }  = sprintf ( handles.fmtRB, slot, handles.CAM.motors { m } );
        end
    end
end

%handles.DISPLAY_MODES       = { 'Display CAM' };
%handles.MODE_DISPLAY_CAM    = 1;

handles.Y_AXIS_A_STRINGS    = { 'Current Positions', 'Snapshot', 'Archive A', 'Archive B', 'BBA Reference' };
handles.Y_AXIS_B_STRINGS    = { 'None',              'Snapshot', 'Initial',   'Archive A', 'Archive B', 'BBA Reference' };

handles.YA_CURRENT_ID       = 1;
handles.YA_SNAPSHOT_ID      = 2;
handles.YA_ARCHIVE_A_ID     = 3;
handles.YA_ARCHIVE_B_ID     = 4;
handles.YA_REFERENCE_ID     = 5;
handles.YB_NONE_ID          = 1;
handles.YB_SNAPSHOT_ID      = 2;
handles.YB_INITIAL_ID       = 3;
handles.YB_ARCHIVE_A_ID     = 4;
handles.YB_ARCHIVE_B_ID     = 5;
handles.YB_REFERENCE_ID     = 6;

handles.YA_IDs              = [ handles.YA_CURRENT_ID, handles.YA_SNAPSHOT_ID, handles.YA_ARCHIVE_A_ID, handles.YA_ARCHIVE_B_ID, handles.YA_REFERENCE_ID ];
handles.YB_IDs              = [ handles.YB_NONE_ID,    handles.YB_SNAPSHOT_ID, handles.YB_INITIAL_ID,   handles.YB_ARCHIVE_A_ID, handles.YB_ARCHIVE_B_ID, handles.YB_REFERENCE_ID ];

handles.A_Options           = length ( handles.YA_IDs );
handles.B_Options           = length ( handles.YB_IDs );

handles.DisplayItem_A       = '';
handles.DisplayItem_B       = '';

handles.reference_date      = sprintf ( '%s', datestr ( lcaGet( BBArefDatePV ), 'yyyy-mm-dd HH:MM:SS' ) );

handles.CAM.oldPVs          = handles.CAM.PVs;
handles.CAM.midPVs          = handles.CAM.PVs;

handles.totalDataChannels   = handles.A_Options * handles.B_Options;
handles.DisplayValues       = cell ( 1, handles.totalDataChannels );

handles.CAM.initial_date    = sprintf ( '%s', datestr ( now, 'yyyy-mm-dd HH:MM:SS' ) );
handles.CAM.initial_vals    = getCurrentGirderPositions ( handles.undulatorLine, handles.cellList, handles.geo );
handles.loadedCAMdata       = true;
handles.CAM.snapshot_date   = handles.CAM.initial_date;
handles.CAM.snapshot_vals   = handles.CAM.initial_vals;
handles.CAM.archive_A_date  = handles.CAM.initial_date;
handles.CAM.archive_A_vals  = handles.CAM.initial_vals;
handles.CAM.archive_B_date  = handles.CAM.initial_date;
handles.CAM.archive_B_vals  = handles.CAM.initial_vals;
handles.CAM.current_date    = handles.CAM.initial_date;
handles.CAM.current_vals    = handles.CAM.initial_vals;

handles.CAM.reference_date  = handles.CAM.initial_date;
handles.CAM.reference_vals  = handles.CAM.initial_vals;

%ddd = handles.reference_date
[ RefVals, RefDate, ~, success ]  = readArchiveBufferData ( handles.CAM, datenum ( handles.reference_date ) );
%CAM = handles.CAM
if ( success )
    handles.CAM.reference_date  = RefDate;
    handles.CAM.reference_vals  = RefVals; %%%abc
end
%xxx = handles.CAM.reference_vals
%RefVals
%zzz = subtractPositionStructures ( xxx, RefVals )

handles.ArchiveArequestDate = '00/00/0000 00:00:00';
handles.ArchiveBrequestDate = '00/00/0000 00:00:00';

handles.dispHistory         = cell ( handles.totalDataChannels, handles.dispBufferSize );
handles.dateHistory         = cell ( handles.totalDataChannels, handles.dispBufferSize );

handles.DisplayDate         = handles.CAM.initial_date;
handles.DisplayDate_A       = handles.CAM.initial_date;
handles.DisplayDate_B       = handles.CAM.initial_date;

handles.ubeg_zp             = zeros ( 1, handles.cells );
handles.uend_zp             = zeros ( 1, handles.cells );
handles.quad_zp             = zeros ( 1, handles.cells );

for j = 1 : handles.cells
    handles.ubeg_zp ( j ) = handles.UndConsts.firstUbegz + handles.UndConsts.CellLength * ( j - 1 );
    handles.uend_zp ( j ) = handles.UndConsts.firstUendz + handles.UndConsts.CellLength * ( j - 1 );
    handles.quad_zp ( j ) = handles.UndConsts.firstQuadz + handles.UndConsts.CellLength * ( j - 1 );
end

if ( handles.loadedCAMdata )
    set ( handles.BBA_REFERENCE,          'Visible', 'On' );
    set ( handles.BBA_REFERENCE_DATE,     'Visible', 'On' );
    set ( handles.BBA_REFERENCE,          'String', 'BBA Reference Data Loaded' );
    set ( handles.BBA_REFERENCE_DATE,     'String', handles.CAM.reference_date );
     
    handles.CAM.reference_loaded = true;
else
    set ( handles.BBA_REFERENCE,          'Visible', 'Off' );
    set ( handles.BBA_REFERENCE_DATE,     'Visible', 'Off' );
    handles.CAM.reference_date   = handles.CAM.initial_date;
    handles.CAM.reference_vals   = handles.CAM.initial_vals;
     
    handles.CAM.reference_loaded = false;
end

if ( handles.Line == 'H' )
    set ( handles.SHOW_SEG_NUMBERS_LABEL,    'Visible', 'On' );
    set ( handles.SHOW_SEG_NUMBERS_CHECKBOX, 'Visible', 'On' );
    set ( handles.SEG_NUMBER_PREC_LABEL,     'Visible', 'On' );
    set ( handles.SEG_PREC_EDIT,             'Visible', 'On' );
else
    set ( handles.SHOW_SEG_NUMBERS_LABEL,    'Visible', 'Off' );
    set ( handles.SHOW_SEG_NUMBERS_CHECKBOX, 'Visible', 'Off' );
    set ( handles.SEG_NUMBER_PREC_LABEL,     'Visible', 'Off' );
    set ( handles.SEG_PREC_EDIT,             'Visible', 'Off' );
end

adjustCAMcheckboxDisplays ( handles );

set ( handles.Y_AXIS_QUANTITY_A_MENU, 'String', handles.Y_AXIS_A_STRINGS );
set ( handles.Y_AXIS_QUANTITY_A_MENU, 'Value',  handles.YA_CURRENT_ID    );
set ( handles.Y_AXIS_QUANTITY_B_MENU, 'String', handles.Y_AXIS_B_STRINGS );
set ( handles.Y_AXIS_QUANTITY_B_MENU, 'Value',  handles.YB_NONE_ID  );

set ( handles.GUI_TITLE, 'String', sprintf ( '%s Undulator Line Alignment', handles.undulatorLine ) );
set ( handles.USE_CAM_REFERENCE_CHECKBOX,  'Value', 1 );

set ( handles.ARCHIVE_SET_A_DATE_REQUEST, 'String', '' );
set ( handles.ARCHIVE_SET_B_DATE_REQUEST, 'String', '' );

end
