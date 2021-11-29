function varargout = UndulatorAlignmentDiagnostics_gui(varargin)
% UNDULATORALIGNMENTDIAGNOSTICS_GUI M-file for UndulatorAlignmentDiagnostics_gui.fig
%      UNDULATORALIGNMENTDIAGNOSTICS_GUI, by itself, creates a new UNDULATORALIGNMENTDIAGNOSTICS_GUI or raises the existing
%      singleton*.
%
%      H = UNDULATORALIGNMENTDIAGNOSTICS_GUI returns the handle to a new UNDULATORALIGNMENTDIAGNOSTICS_GUI or the handle to
%      the existing singleton*.
%
%      UNDULATORALIGNMENTDIAGNOSTICS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDULATORALIGNMENTDIAGNOSTICS_GUI.M with the given input arguments.
%
%      UNDULATORALIGNMENTDIAGNOSTICS_GUI('Property','Value',...) creates a new UNDULATORALIGNMENTDIAGNOSTICS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UndulatorAlignmentDiagnostics_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UndulatorAlignmentDiagnostics_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UndulatorAlignmentDiagnostics_gui

% Last Modified by GUIDE v2.5 09-Jan-2018 17:09:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UndulatorAlignmentDiagnostics_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UndulatorAlignmentDiagnostics_gui_OutputFcn, ...
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


% --- Executes just before UndulatorAlignmentDiagnostics_gui is made visible.
function UndulatorAlignmentDiagnostics_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UndulatorAlignmentDiagnostics_gui (see VARARGIN)

% Choose default command line output for UndulatorAlignmentDiagnostics_gui
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;
global debug;
global verbose;

handles.output              = hObject;

timerRunning                = false;
timerRestart                = false;
timerDelay                  = 2;      % sec
timerData.hObject           = hObject;
debug                       = false;
verbose                     = false;
handles.fb                  = '/u1/lcls/matlab/UndulatorAlignmentDiagnostics_gui/';

handles.printTo_e_Log       = true;
handles.printTo_Files       = true;
handles.showLogFigure       = false;
handles.initialize          = true;

if ( handles.printTo_Files || handles.printTo_e_Log )
    if ( handles.showLogFigure )
        handles.log_fig         = figure ( 'Visible', 'On' );
    else
        handles.log_fig         = figure ( 'Visible', 'Off' );
    end
    
    handles.log_fig_X_axes  = subplot ( 2, 1, 1 );
    handles.log_fig_Y_axes  = subplot ( 2, 1, 2 );
end

handles.geo                 = girderGeo;
handles.UndConsts           = util_UndulatorConstants;
handles.segmentList         = 1 : 33;
handles.segments            = length ( handles.segmentList );
handles.DISPLAY_MODES       = { 'Display ADS',  'Display CAM',  'Display ADS - CAM' };

handles.MODE_DISPLAY_ADS    = 1;
handles.MODE_DISPLAY_CAM    = 2;
handles.MODE_ADS_CAM        = 3;

handles.Y_AXIS_A_STRINGS    = { 'Current Positions', 'Snapshot', 'Archive A', 'Archive B', 'LTQ Reference' };
handles.Y_AXIS_B_STRINGS    = { 'None',              'Snapshot', 'Initial',   'Archive A', 'Archive B', 'LTQ Reference' };

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
handles.totalDataChannels   = handles.A_Options * handles.B_Options;
handles.DisplayValues       = cell ( 1, handles.totalDataChannels );

handles.DisplayItem_A       = '';
handles.DisplayItem_B       = '';

handles.ADS.positions       = { 'BFW',  'QUAD' };
handles.ADS.units           = { '10',   '90' };
handles.ADS.datname         = { 'LTQ',  'LTQ',  'LTC' };
handles.ADS.refname         = { 'RFQ',  'RFQ',  'REF' };
handles.ADS.parameter       = { 'XPOS', 'YPOS', 'ROLL' };
handles.ADS.segmentList     = handles.segmentList;
handles.ADS.segments        = handles.segments;
handles.ADS.npos            = length ( handles.ADS.positions );
handles.ADS.nprm            = length ( handles.ADS.parameter );
handles.ADS.PVindex         = zeros ( handles.segments, handles.ADS.npos, handles.ADS.nprm );
handles.ADS.nPVs            = handles.segments * handles.ADS.npos * handles.ADS.nprm; 
handles.ADS.oldPVs          = cell ( handles.ADS.nPVs, 1 );
handles.ADS.PVs             = cell ( handles.ADS.nPVs, 1 );
handles.ADS.refPVs          = cell ( handles.ADS.nPVs, 1 );
handles.ADS.fb              = handles.fb;
handles.ADS.fn              = 'ArchivedADSbuffer.mat';
handles.ADS.buffer_loaded   = false;
handles.ADS.old_end_date    = '07/10/2009 10:11:00';
handles.ADS.mid_ini_date    = '07/10/2009 18:05:00';
handles.ADS.mid_end_date    = '07/16/2009 15:39:00';
handles.ADS.new_ini_date    = '07/16/2009 17:40:30';
PVindex = 0;

%ADS:UND1:110:BFW_LTQ_XPOS

for p = 1 : handles.ADS.npos
    for slot = handles.segmentList
        for j = 1 : handles.ADS.nprm
            PVindex                            = PVindex + 1;
            handles.ADS.PVindex ( slot, p, j ) = PVindex;
            handles.ADS.oldPVs { PVindex }     = sprintf ( '%s:UND1:%2.2d:%s:%s', handles.ADS.positions { p }, slot, handles.ADS.units { p }, handles.ADS.parameter { j } ( 1 ) );
            handles.ADS.midPVs { PVindex }     = sprintf ( 'ADS:UND1:%2.2d%s:%s_%s_%s', ...
                   slot, ...
                   handles.ADS.units { p }, ...
                   handles.ADS.positions   { p }, ...
                   handles.ADS.datname { j }, ...
                   handles.ADS.parameter   { j } );
               
            handles.ADS.PVs    { PVindex }     = sprintf ( 'ADS:UND1:%d%s:%s_%s_%s', ...
                   slot, ...
                   handles.ADS.units { p }, ...
                   handles.ADS.positions   { p }, ...
                   handles.ADS.datname { j }, ...
                   handles.ADS.parameter   { j } );
               
            handles.ADS.refPVs { PVindex }     = sprintf ( 'ADS:UND1:%d%s:%s_%s_%s', ...
                   slot, ...
                   handles.ADS.units { p }, ...
                   handles.ADS.positions { p }, ...
                   handles.ADS.refname { j }, ...
                   handles.ADS.parameter { j } );
        end
    end
end

reference_date = lcaGet ( 'ADS:UND1:SI:REF:TIME' );
%reference_date = lcaGet ( 'ADS:UND1:GS:TIME:STAMP.VALB' );

if ( any ( cell2mat ( reference_date ) ) )
    handles.ADS.reference_date  = datestr ( datenum ( reference_date ), 'mm/dd/yyyy HH:MM:SS' );
else
    handles.ADS.reference_date  = datestr ( now, 'mm/dd/yyyy HH:MM:SS' );
end

handles.ADS.initial_date    = sprintf ( '%s', datestr ( datenum ( lcaGet ( 'ADS:UND1:SI:CURR:TIME' ) ), 'yyyy-mm-dd HH:MM:SS' ) );
handles.ADS.initial_vals    = array2ADS ( lcaGet ( handles.ADS.PVs )', handles.segmentList, handles.ADS.PVindex );

handles.ADS.snapshot_date   = handles.ADS.initial_date;
handles.ADS.snapshot_vals   = handles.ADS.initial_vals;
handles.ADS.archive_A_date  = handles.ADS.initial_date;
handles.ADS.archive_A_vals  = handles.ADS.initial_vals;
handles.ADS.archive_B_date  = handles.ADS.initial_date;
handles.ADS.archive_B_vals  = handles.ADS.initial_vals;
%handles.ADS.reference_date  = handles.ADS.initial_date;
handles.ADS.reference_vals  = handles.ADS.initial_vals;
handles.ADS.current_date    = handles.ADS.initial_date;
handles.ADS.current_vals    = handles.ADS.initial_vals;

handles.CAM.motors          = { '1',  '2', '3', '4', '5' };
handles.CAM.segmentList     = handles.segmentList;
handles.CAM.segments        = handles.segments;
handles.CAM.nmot            = length ( handles.CAM.motors );
handles.CAM.PVindex         = zeros ( handles.segments, handles.CAM.nmot );
handles.CAM.nPVs            = handles.CAM.segments * handles.CAM.nmot; 
handles.CAM.PVs             = cell (handles.CAM.nPVs, 1 );
handles.CAM.fb              = handles.fb;
handles.CAM.fn              = 'ArchivedCAMbuffer.mat';
handles.CAM.buffer_loaded   = false;
handles.CAM.old_end_date    = '07/10/2009 10:11:00';
handles.CAM.mid_ini_date    = '07/10/2009 18:05:00';
handles.CAM.mid_end_date    = '07/16/2009 15:39:00';
handles.CAM.new_ini_date    = '07/16/2009 17:40:30';

PVindex = 0;

for slot = handles.segmentList
    for m = 1 : handles.CAM.nmot
        PVindex                         = PVindex + 1;
        handles.CAM.PVindex ( slot, m ) = PVindex;
        handles.CAM.PVs    { PVindex }  = sprintf ( 'USEG:UND1:%d50:CM%sMOTOR.RBV', slot, handles.CAM.motors { m } );
    end
end

handles.CAM.oldPVs          = handles.CAM.PVs;
handles.CAM.midPVs          = handles.CAM.PVs;

handles.CAM.initial_date    = handles.ADS.initial_date;
handles.CAM.initial_vals    = array2CAM ( lcaGet ( handles.CAM.PVs )', handles.segmentList, handles.CAM.PVindex, handles.geo );
handles.CAM.snapshot_date   = handles.CAM.initial_date;
handles.CAM.snapshot_vals   = handles.CAM.initial_vals;
handles.CAM.archive_A_date  = handles.CAM.initial_date;
handles.CAM.archive_A_vals  = handles.CAM.initial_vals;
handles.CAM.archive_B_date  = handles.CAM.initial_date;
handles.CAM.archive_B_vals  = handles.CAM.initial_vals;
handles.CAM.reference_date  = handles.CAM.initial_date;
handles.CAM.reference_vals  = handles.CAM.initial_vals;
handles.CAM.current_date    = handles.CAM.initial_date;
handles.CAM.current_vals    = handles.CAM.initial_vals;

handles.dispBufferSize      = 10;

handles.dispHistory         = cell ( handles.totalDataChannels, handles.dispBufferSize );
handles.dateHistory         = cell ( handles.totalDataChannels, handles.dispBufferSize );

handles.DisplayDate         = handles.ADS.initial_date;
handles.DisplayDate_A       = handles.ADS.initial_date;
handles.DisplayDate_B       = handles.ADS.initial_date;

handles.bfw_zp              = zeros ( 1, handles.segments );
handles.quad_zp             = zeros ( 1, handles.segments );
UBEG_ST100                  = 1031.240;

for segment = handles.segmentList
    handles.bfw_zp  ( segment ) = handles.UndConsts.Z_BFW  { segment } + UBEG_ST100;
    handles.quad_zp ( segment ) = handles.UndConsts.Z_QUAD { segment } + UBEG_ST100;
end

params.getNewADSdata        = true;
params.vals_name            = 'reference_vals';
params.date_name            = 'reference_date';
params.YA_ID                = handles.YA_REFERENCE_ID;
params.YB_ID                = handles.YB_REFERENCE_ID;
params.DATE                 = handles.CAM_REFERENCE_DATE;
params.requestDate          = handles.ADS.reference_date;
params.LOAD_BTN             = handles.CAM_REFERENCE;

handles                     = getArchivedData ( handles, params );

if ( handles.loadedCAMdata )
    set ( handles.CAM_REFERENCE,          'Visible', 'On' );
    set ( handles.CAM_REFERENCE_DATE,     'Visible', 'On' );
    set ( handles.CAM_REFERENCE,          'String', 'CAM Reference Data Loaded' );
    set ( handles.CAM_REFERENCE_DATE,     'String', handles.CAM.reference_date );
    
    handles.CAM.reference_loaded = true;
else
    set ( handles.CAM_REFERENCE,          'Visible', 'Off' );
    set ( handles.CAM_REFERENCE_DATE,     'Visible', 'Off' );
    handles.CAM.reference_date   = handles.CAM.initial_date;
    handles.CAM.reference_vals   = handles.CAM.initial_vals;
    
    handles.CAM.reference_loaded = false;
end

set ( handles.Y_AXIS_QUANTITY_A_MENU, 'String', handles.Y_AXIS_A_STRINGS );
set ( handles.Y_AXIS_QUANTITY_A_MENU, 'Value',  handles.YA_CURRENT_ID    );
set ( handles.Y_AXIS_QUANTITY_B_MENU, 'String', handles.Y_AXIS_B_STRINGS );
set ( handles.Y_AXIS_QUANTITY_B_MENU, 'Value',  handles.YB_REFERENCE_ID  );
set ( handles.DISPLAY_MODE_MENU,      'String', handles.DISPLAY_MODES    );

set ( handles.USE_CAM_REFERENCE_CHECKBOX,  'Value', 0 );

adjustCAMcheckboxDisplays ( handles );

handles = updateDisplay ( handles, handles.XFIGURE, handles.YFIGURE );

% Update handles structure
guidata ( hObject, handles );

timerData.handles = handles;

% UIWAIT makes UndulatorAlignmentDiagnostics_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


function adjustCAMcheckboxDisplays ( handles )

set ( handles.REM_LIN_CHECKBOX,        'Visible', 'On' );
set ( handles.REM_LIN_LABEL,           'Visible', 'On' );

if ( get ( handles.DISPLAY_MODE_MENU, 'Value' )      ~= handles.MODE_DISPLAY_ADS && ...
     get ( handles.Y_AXIS_QUANTITY_B_MENU, 'Value' ) == handles.YB_NONE_ID && ...
     handles.CAM.reference_loaded )
    set ( handles.USE_CAM_REFERENCE_CHECKBOX,  'Visible', 'On' );
    set ( handles.USE_CAM_REFERENCE_LABEL,     'Visible', 'On' );
else
    set ( handles.USE_CAM_REFERENCE_CHECKBOX,  'Visible', 'Off' );
    set ( handles.USE_CAM_REFERENCE_LABEL,     'Visible', 'Off' );
end

if ( get ( handles.DISPLAY_MODE_MENU, 'Value' ) == handles.MODE_ADS_CAM )
    set ( handles.CAM_MOTION_ENABLED_CHECKBOX, 'Visible', 'Off' );
    set ( handles.CAM_MOTION_ENABLED_LABEL,    'Visible', 'Off' );

    set ( handles.MOVE_GIRDERS_BTN,            'Visible', 'Off' );
else
    set ( handles.CAM_MOTION_ENABLED_CHECKBOX, 'Visible', 'On' );
    set ( handles.CAM_MOTION_ENABLED_LABEL,    'Visible', 'On' );

    if ( get ( handles.CAM_MOTION_ENABLED_CHECKBOX, 'Value' )  )
        set ( handles.MOVE_GIRDERS_BTN,        'Visible', 'On' );
    end    
end
 
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

dataage = ( now - datenum ( lcaGet ( 'ADS:UND1:SI:DATA:TIME' ) ) ) * 24 * 3600;

set ( handles.DATAAGE, 'String', sprintf ( 'Age of recent ADS data %6.2f sec', dataage ) );
set ( handles.DATAAGE, 'Visible', 'On' );

handles = updateDisplay ( handles, handles.XFIGURE, handles.YFIGURE );

% Update handles structure
guidata ( hObject, handles );

timerData.handles = handles;

if ( debug )
    fprintf ( '%s event occurred at %s\n', event.Type, datestr ( event.Data.time ) );
    get ( obj );
end

end

function z = setXaxis ( handles, z, segment )

Lseg     = 4.000;

jb       = ( segment - 1 ) * 2 + 1;
jq       = ( segment - 1 ) * 2 + 2;

z ( jb ) = handles.bfw_zp  ( segment );
z ( jq ) = handles.quad_zp ( segment );
    
if ( xAxis_has_GirderNumbers ( handles ) )
    center   = ( z ( jb ) + z ( jq ) ) /  2;
    z ( jb ) = ( z ( jb ) - center ) / Lseg + segment;
    z ( jq ) = ( z ( jq ) - center ) / Lseg + segment;
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

handles.reference_date = StandardDateFormat ( lcaGet ( 'ADS:UND1:SI:REF:TIME' ) );
%handles.reference_date = StandardDateFormat ( lcaGet ( 'ADS:UND1:GS:TIME:STAMP.VALB' ) );

%reference_date = lcaGet ( 'ADS:UND1:GS:TIME:STAMP.VALB' );
%
%ref_date_type = whos ( 'reference_date' );
%
%if ( strcmp ( ref_date_type.class, 'double' )
%    handles.reference_date = datestr ( datenum ( char ( reference_date ), 'yyy-mm-dd HH:MM:SS' );
%elseif ( any ( cell2mat ( reference_date ) ) )
%    handles.reference_date = datestr ( datenum ( reference_date ), 'yyyy-mm-dd HH:MM:SS' ) ;
%else
%    handles.reference_date = datestr ( datenum ( now ), 'yyyy-mm-dd HH:MM:SS' ) ;
%end

set ( handles.RESETDATE, 'String', sprintf ( 'LTQ Reference Date %s', handles.reference_date ) );

%set ( handles.RESETDATE, 'String', ...
%    sprintf ( 'LTC Reference Date %s', datestr ( datenum ( handles.reference_date ), 'yyyy-mm-dd HH:MM:SS' ) ) );

set ( handles.RESETDATE, 'Visible', 'On' );

set ( handles.INITIAL_DATA_TAKEN, 'String', 'Intitial Data Memorized' );
set ( handles.INITIAL_DATA_TAKEN, 'Visible', 'On' );
set ( handles.INITIALDATE,        'String', sprintf ( 'Initial Date: %s', handles.ADS.initial_date ) );
set ( handles.INITIALDATE,        'Visible', 'On' );
set ( handles.ADS_SNAPSHOTDATE,   'String', handles.ADS.snapshot_date );
set ( handles.ADS_SNAPSHOTDATE,   'Visible', 'On' );
set ( handles.ARCHIVE_SET_A_DATE, 'String', handles.ADS.archive_A_date );
set ( handles.ARCHIVE_SET_A_DATE, 'Visible', 'On' );
set ( handles.ARCHIVE_SET_B_DATE, 'String', handles.ADS.archive_B_date );
set ( handles.ARCHIVE_SET_B_DATE, 'Visible', 'On' );

handles.ADS.current_date = datestr ( datenum ( lcaGet ('ADS:UND1:SI:DATA:TIME' ) ), 'yyyy-mm-dd HH:MM:SS' );
%handles.ADS.current_date = sprintf ( '%s', datestr ( datenum ( lcaGet ( 'ADS:UND1:SI:CURR:TIME' ) ), 'yyyy-mm-dd HH:MM:SS' ) );
handles.ADS.current_vals = array2ADS ( lcaGet ( handles.ADS.PVs )', handles.segmentList, handles.ADS.PVindex );
handles.CAM.current_date = sprintf ( '%s', datestr ( now, 'yyyy-mm-dd HH:MM:SS' ) );
handles.CAM.current_vals = array2CAM ( lcaGet ( handles.CAM.PVs )', handles.segmentList, handles.CAM.PVindex, handles.geo );

%set ( handles.TIMESTAMP, 'String', ...
%    sprintf ( 'Data Timestamp %s', datestr ( datenum ( lcaGet ( 'ADS:UND1:SI:DATA:TIME' ) ), 'yyyy-mm-dd HH:MM:SS' ) ) );
set ( handles.TIMESTAMP, 'String', handles.ADS.current_date );
set ( handles.TIMESTAMP, 'Visible', 'On' );

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

plotADS_Xstatus ( handles, XFIGURE_AXIS );
plotADS_Ystatus ( handles, YFIGURE_AXIS );

new_handles = handles;

end


function diff = subtractPositionStructures ( A, B )

diff.x = A.x - B.x;
diff.y = A.y - B.y;
diff.r = A.r - B.r;
    
end


function new_handles = manageDataChannels ( handles )

handles.YselA      = get ( handles.Y_AXIS_QUANTITY_A_MENU,     'Value' );
handles.YselB      = get ( handles.Y_AXIS_QUANTITY_B_MENU,     'Value' );
handles.UseRef     = get ( handles.USE_CAM_REFERENCE_CHECKBOX, 'Value' );
handles.Rel        = get ( handles.REM_LIN_CHECKBOX,       'Value' );
handles            = getCurrentDataChannel ( handles, handles.YselA, handles.YselB );

initial_ADS_vals   = handles.ADS.initial_vals;
current_ADS_vals   = handles.ADS.current_vals;
snapshot_ADS_vals  = handles.ADS.snapshot_vals;
archive_A_ADS_vals = handles.ADS.archive_A_vals;
archive_B_ADS_vals = handles.ADS.archive_B_vals;    
reference_ADS_vals = handles.ADS.reference_vals;

initial_CAM_vals   = handles.CAM.initial_vals;
current_CAM_vals   = handles.CAM.current_vals;
snapshot_CAM_vals  = handles.CAM.snapshot_vals;
archive_A_CAM_vals = handles.CAM.archive_A_vals;
archive_B_CAM_vals = handles.CAM.archive_B_vals;    
reference_CAM_vals = handles.CAM.reference_vals;

if ( handles.UseRef )
    initial_CAM_vals   = subtractPositionStructures ( initial_CAM_vals,   reference_CAM_vals );
    current_CAM_vals   = subtractPositionStructures ( current_CAM_vals,   reference_CAM_vals );
    snapshot_CAM_vals  = subtractPositionStructures ( snapshot_CAM_vals,  reference_CAM_vals );
    archive_A_CAM_vals = subtractPositionStructures ( archive_A_CAM_vals, reference_CAM_vals );
    archive_B_CAM_vals = subtractPositionStructures ( archive_B_CAM_vals, reference_CAM_vals );
    reference_CAM_vals = subtractPositionStructures ( reference_CAM_vals, reference_CAM_vals );
end

for A = 1 : handles.A_Options
    for B = 1 : handles.B_Options
        k = ( A - 1 ) * handles.B_Options + B;

        switch A
            case handles.YA_CURRENT_ID
                handles.DisplayValuesA           = useMode ( handles, current_ADS_vals,   current_CAM_vals );
            case handles.YA_SNAPSHOT_ID
                handles.DisplayValuesA           = useMode ( handles, snapshot_ADS_vals,  snapshot_CAM_vals );
            case handles.YA_ARCHIVE_A_ID
                handles.DisplayValuesA           = useMode ( handles, archive_A_ADS_vals, archive_A_CAM_vals );                
            case handles.YA_ARCHIVE_B_ID
                handles.DisplayValuesA           = useMode ( handles, archive_B_ADS_vals, archive_B_CAM_vals );
            case handles.YA_REFERENCE_ID
                handles.DisplayValuesA           = useMode ( handles, reference_ADS_vals, reference_CAM_vals );
            otherwise
                handles.DisplayValuesA           = current_ADS_vals;
        end
         
        switch B
            case handles.YB_NONE_ID
                handles.DisplayValues { k }      = handles.DisplayValuesA;
            case handles.YB_SNAPSHOT_ID
                handles.DisplayValues { k }      = subtractPositionStructures ( handles.DisplayValuesA, useMode ( handles, snapshot_ADS_vals,  snapshot_CAM_vals ) );
            case handles.YB_INITIAL_ID
                handles.DisplayValues { k }      = subtractPositionStructures ( handles.DisplayValuesA, useMode ( handles, initial_ADS_vals,   initial_CAM_vals ) );
            case handles.YB_ARCHIVE_A_ID
                handles.DisplayValues { k }      = subtractPositionStructures ( handles.DisplayValuesA, useMode ( handles, archive_A_ADS_vals, archive_A_CAM_vals ) );
            case handles.YB_ARCHIVE_B_ID
                handles.DisplayValues { k }      = subtractPositionStructures ( handles.DisplayValuesA, useMode ( handles, archive_B_ADS_vals, archive_B_CAM_vals ) );
            case handles.YB_REFERENCE_ID
                handles.DisplayValues { k }      = subtractPositionStructures ( handles.DisplayValuesA, useMode ( handles, reference_ADS_vals, reference_CAM_vals ) );
            otherwise
                handles.DisplayValues { k }      = handles.DisplayValuesA;
        end
        
        if ( handles.Rel )
            DisplayValue_CAM_base       = fitGirderPositions ( handles.DisplayValues { k },   handles.segmentList, handles.UndConsts );
            handles.DisplayValues { k } = subtractPositionStructures ( handles.DisplayValues { k },   DisplayValue_CAM_base );
        end        
    end
end

handles.DisplayDate = handles.ADS.current_date;
new_handles         = handles;

end


function C = useMode ( handles, ADS, CAM )

switch get ( handles.DISPLAY_MODE_MENU, 'Value' );
    case handles.MODE_DISPLAY_ADS
        C = ADS;
    case handles.MODE_DISPLAY_CAM
        C = CAM;
    case handles.MODE_ADS_CAM
        C = subtractPositionStructures ( ADS, CAM );
end

end


function plotADS_Xstatus ( handles, axes_handle )

z = zeros ( 1, 2 * handles.segments );
k = handles.currentDataChannel;

for segment = handles.segmentList
    z = setXaxis ( handles, z, segment );
end

x = cell ( 1, handles.dispBufferSize );

for j = 1 : handles.dispBufferSize
    x { j } = handles.dispHistory { k, j }.x;
end

plotADSdata ( handles, axes_handle, z, x, handles.segmentList )

grid ( axes_handle, 'on' );

if ( xAxis_has_GirderNumbers ( handles ) )
    xlabel ('Girder Numbers', 'Parent', axes_handle );
else
    xlabel ( 'z [m]', 'Parent', axes_handle );
end

ylabel ( 'x [microns]', 'Parent', axes_handle );

hold ( axes_handle, 'off' );

end


function plotADS_Ystatus ( handles, axes_handle )

z = zeros ( 1, 2 * handles.segments );
k = handles.currentDataChannel;

for segment = handles.segmentList
    z = setXaxis ( handles, z, segment );
end

y = cell ( 1, handles.dispBufferSize );

for j = 1 : handles.dispBufferSize
    y { j } = handles.dispHistory { k, j }.y;
end

plotADSdata ( handles, axes_handle, z, y, handles.segmentList )

grid ( axes_handle, 'on' );

if ( xAxis_has_GirderNumbers ( handles ) )
    xlabel ('Girder Numbers', 'Parent', axes_handle );
else
    xlabel ( 'z [m]', 'Parent', axes_handle );
end

ylabel ( 'y [microns]', 'Parent', axes_handle );

hold ( axes_handle, 'off' );

end


function plotADSdata ( handles, axes_handle, x, y, segmentList )

n    = length ( y );

plotb = get ( handles.SHOW_BFW_NUMBERS_CHECKBOX,  'Value' );
plotq = get ( handles.SHOW_QUAD_NUMBERS_CHECKBOX, 'Value' );
precb = get ( handles.BFW_PREC_EDIT,              'Value' );
precq = get ( handles.QUAD_PREC_EDIT,             'Value' );
FMTb  = sprintf ( '%%.%df', precb );
FMTq  = sprintf ( '%%.%df', precq );

for segment = segmentList
    jb      = ( segment - 1 ) * 2 + 1;
    jq      = jb + 1;

    for j = 1 : n - 1
        c = zeros ( 1, 3 ) + ( n - j ) / ( n - 1 );
        plot ( x ( jb : jq ), y { j } ( jb : jq ), 'Color', c, 'LineWidth', 4, 'Parent', axes_handle );
        hold ( axes_handle, 'on' );
    end
    
    plot ( x ( jb : jq ), y { n } ( jb : jq ), 'Color', [ 0.3 0.5 0.9 ], 'LineWidth', 4, 'Parent', axes_handle );
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
    
    dyb = 0.050 * ( v ( 4 ) - v ( 3 ) ); 
    dyq = 0.100 * ( v ( 4 ) - v ( 3 ) ); 
    dx  = 0.007 * ( v ( 2 ) - v ( 1 ) );

    for segment = segmentList
        jb      = ( segment - 1 ) * 2 + 1;
        jq      = jb + 1;

        yb = y { n } ( jb );
        yq = y { n } ( jq );
    
        if ( yb < yq )
            yb = yb - dyb;
        else
            yb = yb + dyb;
        end
    
        if ( yq < yb )
            yq = yq - dyq;
        else
            yq = yq + dyq;
        end
        
        if ( plotb )
            text ( x ( jb ) + dx, yb, sprintf ( FMTb, y { n } ( jb ) ), ...
                'FontSize', 7, ...
                'Color', [ 0.5, 0.9, 0.0 ], ...
                            'FontWeight', 'normal', ...
                'HorizontalAlignment', 'Center', ...
                'VerticalAlignment', 'Cap', ...
                'Parent', axes_handle);
        end
    
        if ( plotq )
            text ( x ( jq ) - dx, yq, sprintf ( FMTq, y { n } ( jq ) ), ...
                'FontSize', 7, ...
                'Color', [ 0.9, 0.5, 0.0 ], ...
                'FontWeight', 'normal', ...
                'HorizontalAlignment', 'Center', ...
                'VerticalAlignment', 'Cap', ...
                'Parent', axes_handle);
        end
    end
end

textPos = estimatePosition ( 1, 92,  axis ( axes_handle ) );
textStr = formatModeString ( handles );
text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 7, 'Parent', axes_handle );

if ( handles.Rel && strcmp ( get ( handles.REM_LIN_CHECKBOX, 'Visible' ), 'on' ) )
    textPos = estimatePosition ( 99, 2,  axis ( axes_handle ) );
    textStr = 'Linear portion removed from data.';
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'right', 'FontSize', 7, 'Parent', axes_handle );   
end

end


% --- Outputs from this function are returned to the command line.
function varargout = UndulatorAlignmentDiagnostics_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
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

st1    = 'Change X-Axis to Girder Numbers';
st2    = 'Change X-Axis to Z-Locations';

if ( xAxis_has_GirderNumbers ( handles ) )
    set ( hObject, 'String', st1 );
else
    set ( hObject, 'String', st2 );
end

end


% --- Executes on button press in TAKE_SNAPSHOT.
function TAKE_SNAPSHOT_Callback(hObject, eventdata, handles)
% hObject    handle to TAKE_SNAPSHOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerData;

handles.ADS.snapshot_date = sprintf ( '%s', datestr ( now,'mm/dd/yyyy HH:MM:SS' ) );
handles.ADS.snapshot_vals = array2ADS ( lcaGet ( handles.ADS.PVs )', handles.segmentList, handles.ADS.PVindex );

handles.CAM.snapshot_date = handles.ADS.snapshot_date;
handles.CAM.snapshot_vals = array2CAM ( lcaGet ( handles.CAM.PVs )', handles.segmentList, handles.CAM.PVindex, handles.geo );
%handles.CAM.snapshot_base = fitCAM ( handles.CAM.snapshot_vals, handles.segmentList, handles.UndConsts );

handles                   = eraseHistory ( handles, handles.YA_SNAPSHOT_ID, handles.YB_SNAPSHOT_ID );

timerData.handles = handles;

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
        handles.DisplayDate_A      = handles.ADS.current_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_SNAPSHOT_ID
        handles.currentDataChannel = ( handles.YA_SNAPSHOT_ID - 1 )     * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.ADS.snapshot_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_ARCHIVE_A_ID
        handles.currentDataChannel = ( handles.YA_ARCHIVE_A_ID    - 1 ) * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.ADS.archive_A_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_ARCHIVE_B_ID
        handles.currentDataChannel = ( handles.YA_ARCHIVE_B_ID    - 1 ) * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.ADS.archive_B_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    case handles.YA_REFERENCE_ID
        handles.currentDataChannel = ( handles.YA_REFERENCE_ID    - 1 ) * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.ADS.reference_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( YselA );
    otherwise
        handles.currentDataChannel = ( handles.YA_CURRENT_ID - 1 )      * handles.B_Options + 1;
        handles.DisplayDate_A      = handles.ADS.current_date;
        handles.DisplayItem_A      = handles.Y_AXIS_A_STRINGS ( 1 );
end
         
switch YselB
    case handles.YB_NONE_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_NONE_ID - 1;
        handles.DisplayDate_B      = NaN;
        handles.DisplayItem_B      = '';
    case handles.YB_SNAPSHOT_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_SNAPSHOT_ID - 1;
        handles.DisplayDate_B      = handles.ADS.snapshot_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_INITIAL_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_INITIAL_ID - 1;
        handles.DisplayDate_B      = handles.ADS.initial_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_ARCHIVE_A_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_ARCHIVE_A_ID - 1;
        handles.DisplayDate_B      = handles.ADS.archive_A_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_ARCHIVE_B_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_ARCHIVE_B_ID - 1;
        handles.DisplayDate_B      = handles.ADS.archive_B_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    case handles.YB_REFERENCE_ID
        handles.currentDataChannel = handles.currentDataChannel + handles.YB_REFERENCE_ID - 1;
        handles.DisplayDate_B      = handles.ADS.reference_date;
        handles.DisplayItem_B      = handles.Y_AXIS_B_STRINGS ( YselB );
    otherwise
        handles.currentDataChannel = handles.currentDataChannel  + handles.YB_NONE_ID - 1;
        handles.DisplayDate_B      = NaN;
        handles.DisplayItem_B      = '';
end

new_handles = handles;

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

[ quad_rbi, bfw_rbi, roll_rbi ] = girderAxisFromCamAngles ( handles.segmentList, handles.geo.quadz, handles.geo.bfwz );

handles.quad_rbi = quad_rbi;
handles.bfw_rbi  = bfw_rbi;
handles.quad_sp  = quad_rbi;
handles.bfw_sp   = bfw_rbi;

x  = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.x;
y  = handles.dispHistory { handles.currentDataChannel, handles.dispBufferSize }.y;

for j = 1 : length ( x )
    if ( isnan ( x ( j ) ) )
        x ( j ) = 0;
    end
    
    if ( isnan ( y ( j ) ) )
        y ( j ) = 0;
    end   
end

for segment = handles.segmentList
    jb      = ( segment - 1 ) * 2 + 1;
    jq      = jb + 1;
    
    fprintf ( 'Changing girder %2.2d from %+6.1f %+6.1f %+6.1f %+6.1f', segment, handles.bfw_sp ( segment, 1 )*1e3, handles.bfw_sp ( segment, 2 )*1e3, handles.quad_sp  ( segment, 1 )*1e3, handles.quad_sp  ( segment, 2 )*1e3);

%    fprintf ( '\n%2.2d %2.2d %f %f %f %f\n', jb, jq, x ( jb ), y ( jb ), x ( jq ), y ( jq ) );
    
    handles.bfw_sp  ( segment, 1 ) = handles.bfw_sp  ( segment, 1 ) - x ( jb ) / 1000;    
    handles.bfw_sp  ( segment, 2 ) = handles.bfw_sp  ( segment, 2 ) - y ( jb ) / 1000;    
    handles.quad_sp ( segment, 1 ) = handles.quad_sp ( segment, 1 ) - x ( jq ) / 1000;    
    handles.quad_sp ( segment, 2 ) = handles.quad_sp ( segment, 2 ) - y ( jq ) / 1000;    

    fprintf ( ' to %+6.1f %+6.1f %+6.1f %+6.1f\n', handles.bfw_sp ( segment, 1 )*1e3, handles.bfw_sp  ( segment, 2 )*1e3, handles.quad_sp  ( segment, 1 )*1e3, handles.quad_sp  ( segment, 2 )*1e3);
end

fprintf ( '\n' );

btnString = get ( handles.MOVE_GIRDERS_BTN, 'String' );

set ( handles.MOVE_GIRDERS_BTN, 'String', 'Moving ...' );

girderAxisSet (  handles.segmentList, handles.quad_sp, handles.bfw_sp );
girderCamWait (  handles.segmentList );

set ( handles.MOVE_GIRDERS_BTN, 'String', btnString );

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on selection change in Y_AXIS_QUANTITY_A_MENU.
function Y_AXIS_QUANTITY_A_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Y_AXIS_QUANTITY_A_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Y_AXIS_QUANTITY_A_MENU contents as cell array
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

% Hints: contents = get(hObject,'String') returns Y_AXIS_QUANTITY_B_MENU contents as cell array
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
catch
    success = false;
end

if ( success )
    datestr_fmt1 = datestr ( date, 'mm/dd/yyyy HH:MM:SS' );

    getNewADSdata = true;
    
    if ( isfield ( handles, 'ArchiveArequestDate' ) )
        if ( datestr_fmt1 == handles.ArchiveArequestDate )
            fprintf ( 'Date already loaded\n' );
%            getNewADSdata = false;
        end
    end
    
    handles.ArchiveArequestDate  = datestr_fmt1;

    if ( getNewADSdata )
        params.getNewADSdata = getNewADSdata;
        params.vals_name     = 'archive_A_vals';
        params.date_name     = 'archive_A_date';
        params.YA_ID         = handles.YA_ARCHIVE_A_ID;
        params.YB_ID         = handles.YB_ARCHIVE_A_ID;
        params.DATE          = handles.ARCHIVE_SET_A_DATE;
        params.requestDate   = handles.ArchiveArequestDate;
        params.LOAD_BTN      = handles.LOAD_ARCHIVE_SET_A_BTN;

        handles = getArchivedData ( handles, params );
    end
end

set ( handles.SET_STC_REFERENCE_BTN, 'Visible', 'On' );

timerData.handles       = handles;

% Update handles structure
guidata(hObject, handles);

end


function  new_handles = getArchivedData ( handles, params )

new_handles = handles;

new_handles.loadedADSdata = true;
new_handles.loadedCAMdata = true;

if ( params.getNewADSdata )
    [ vals, date, ADS, success ] = readArchiveBufferData ( handles.ADS, datenum ( params.requestDate ) );

    if ( success )
        params.getNewADSdata                 = false;
        new_handles.ADS                      = ADS;
        new_handles.ADS.( params.vals_name ) = vals;
        new_handles.ADS.( params.date_name ) = date;

        set ( params.DATE,     'String', new_handles.ADS.( params.date_name ) );
        set ( params.DATE,     'Visible', 'On' );            
            
        new_handles = eraseHistory ( new_handles, params.YA_ID, params.YB_ID );
    end
end

if ( params.getNewADSdata )
    [ ADSdata, success ] = readArchivedData ( new_handles.ADS, params.requestDate, params.LOAD_BTN );

    if ( success )
        new_handles.ADS.( params.date_name ) = sprintf ( '%s', datestr ( ADSdata ( 2, 1 ), 'yyyy-mm-dd HH:MM:SS' ) );
        new_handles.ADS.( params.vals_name ) = array2ADS ( ADSdata, new_handles.segmentList, new_handles.ADS.PVindex );
            
        listPositionData ( new_handles.ADS.( params.vals_name ), params.requestDate, 'ADS', new_handles.segmentList )

        [ ADS, success ] = ...        
            saveArchiveBufferData ( new_handles.ADS, datenum ( params.requestDate ), new_handles.ADS.( params.vals_name ), new_handles.ADS.( params.date_name ) );
            
        if ( success )
            new_handles.ADS = ADS;
        else
            fprintf ( 'Unable to save ADS data to buffer.\n' );
        end

        set ( params.DATE,     'String', new_handles.ADS.( params.date_name ) );
        set ( params.DATE,     'Visible', 'On' );
            
        new_handles = eraseHistory ( new_handles, params.YA_ID, params.YB_ID );
    else
        new_handles.loadedADSdata = false;

        fprintf ( 'Unable to get ADS data.\n' );
    end
end
    
getNewCAMdata = true;
    
[ vals, date, CAM, success ] = readArchiveBufferData ( new_handles.CAM, datenum ( params.requestDate ) );

if ( success )
    getNewCAMdata                        = false;
    new_handles.CAM                      = CAM;
    new_handles.CAM.( params.vals_name ) = vals;
    new_handles.CAM.( params.date_name ) = date;
end        
    
if ( getNewCAMdata )        
    [ CAMdata, success ] = readArchivedData ( new_handles.CAM, params.requestDate, params.LOAD_BTN );

    if ( success )
        new_handles.CAM.( params.date_name ) = sprintf ( '%s', datestr ( CAMdata ( 2, 1 ), 'yyyy-mm-dd HH:MM:SS' ) );
        new_handles.CAM.( params.vals_name ) = array2CAM ( CAMdata, new_handles.segmentList, new_handles.CAM.PVindex, new_handles.geo );

        listPositionData ( new_handles.CAM.( params.vals_name ), params.requestDate, 'CAM', new_handles.segmentList )

        [ CAM, success ] = ...
            saveArchiveBufferData ( new_handles.CAM, datenum ( params.requestDate ), new_handles.CAM.( params.vals_name ), new_handles.CAM.( params.date_name ) );
            
        if ( success )
            new_handles.CAM = CAM;
        else
            fprintf ( 'Unable to save CAM data to buffer.\n' );
        end
    else
        new_handles.loadedCAMdata = false;
        fprintf ( 'Unable to get CAM data.\n' );        
    end
end

end


function listPositionData ( data, date, type, list )

fprintf ( '%s data listing for %s\n', type, date );
            
for segment = list
    jb = ( segment - 1 ) * 2 + 1;
    jq = ( segment - 1 ) * 2 + 2;

    fprintf ( '%2.2d bx: %+6.1f, by: %+6.1f, qx: %+6.1f. qy: %+6.1f\n', segment, data.x ( jb ), data.y ( jb ), data.x ( jq ), data.y ( jq ) );
end 

end


function [ ArchivedData, success ] = readArchivedData ( PVinfo, finalTime, progressHandle )

ArchivedData = zeros ( 2, PVinfo.nPVs );

success            = true;
finalTime          = sprintf ( '%s', datestr ( datenum ( finalTime ),'mm/dd/yyyy HH:MM:SS' ) );
startTime          = sprintf ( '%s', datestr ( datenum ( finalTime ) - 2.0/24,'mm/dd/yyyy HH:MM:SS' ) );
timeRange          = { startTime; finalTime };

savedProgressHandleString = get ( progressHandle, 'String' );
set ( progressHandle, 'String', '' );

%handles.ADS.old_end_date    = '07/10/2009 10:11:00';
%handles.ADS.mid_ini_date    = '07/10/2009 18:05:00';
%handles.ADS.mid_end_date    = '07/16/2009 16:00:00';
%handles.ADS.new_ini_date    = '07/16/2009 16:00:00';


old_end_date    = datenum ( PVinfo.old_end_date );
mid_ini_date    = datenum ( PVinfo.mid_ini_date );
mid_end_date    = datenum ( PVinfo.mid_end_date );
new_ini_date    = datenum ( PVinfo.new_ini_date );

if ( datenum ( finalTime ) > new_ini_date )
    PVs = PVinfo.PVs;
elseif (datenum ( finalTime ) > mid_ini_date && datenum ( finalTime ) < mid_end_date )
    PVs = PVinfo.midPVs;
elseif (datenum ( finalTime ) < old_end_date )
    PVs = PVinfo.oldPVs;
else
    fprintf ( 'No AIDA data avalailable for period %s - %s\n', old_end_date, new_ini_date );
    success = false;
    return;
end

for PV = 1 : PVinfo.nPVs
    set ( progressHandle, 'String', sprintf ( 'Retreiving %s', PVs { PV } ) );
            
    %AIDA_Name  = sprintf ( '%s//HIST.lcls', PVs { PV } );  3/2014 (colocho)  move from AIDA to appliance
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
            
    ArchivedData ( 1, PV ) = T ( length ( T ) );
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


function ADS = array2ADS ( array, segmentList, PVindex )

for segment = segmentList
    jb = ( segment - 1 ) * 2 + 1;
    jq = ( segment - 1 ) * 2 + 2;

    ADS.x ( jb ) = validateADS ( array ( 1, PVindex ( segment, 1, 1 ) ) );
    ADS.y ( jb ) = validateADS ( array ( 1, PVindex ( segment, 1, 2 ) ) );
    ADS.r ( jb ) = validateADS ( array ( 1, PVindex ( segment, 1, 3 ) ) );

    ADS.x ( jq ) = validateADS ( array ( 1, PVindex ( segment, 2, 1 ) ) );
    ADS.y ( jq ) = validateADS ( array ( 1, PVindex ( segment, 2, 2 ) ) );
    ADS.r ( jq ) = validateADS ( array ( 1, PVindex ( segment, 2, 3 ) ) );
end

end


function CAM = array2CAM ( array, segmentList,  PVindex, geo )

segments = length ( segmentList );
CAM.x    = zeros ( 1, 2 * segments );
CAM.y    = zeros ( 1, 2 * segments );
CAM.r    = zeros ( 1, 2 * segments );

for segment = segmentList
    jb = ( segment - 1 ) * 2 + 1;
    jq = ( segment - 1 ) * 2 + 2;
                                    
    [ b, rb ] = girderAngle2Axis ( geo.bfwz,  array ( 1, PVindex ( segment, : ) ) * pi /180 );
    [ q, rq ] = girderAngle2Axis ( geo.quadz, array ( 1, PVindex ( segment, : ) ) * pi /180 );
    
    CAM.x ( jb ) = b ( 1 ) * 1e3;
    CAM.y ( jb ) = b ( 2 ) * 1e3;
    CAM.r ( jb ) = rb      * 1e3;
    
    CAM.x ( jq ) = q ( 1 ) * 1e3;
    CAM.y ( jq ) = q ( 2 ) * 1e3;
    CAM.r ( jq ) = rq      * 1e3;
end            

end


function fittedGirderPositions = fitGirderPositions ( GirderPositions, segmentList, UndConsts )

fittedGirderPositions = GirderPositions;
segments              = length ( segmentList );
z                     = zeros ( 1, 2 * segments );

for segment = segmentList                                    
    z ( ( segment - 1 ) * 2 + 1 ) = UndConsts.Z_BFW  { segment };
    z ( ( segment - 1 ) * 2 + 2 ) = UndConsts.Z_QUAD { segment };
end

fittedGirderPositions.x = findBaseline ( z, GirderPositions.x, segments );
fittedGirderPositions.y = findBaseline ( z, GirderPositions.y, segments );

end


function baseline = findBaseline ( x, y, segments )

BFWindex = ( 1 : 2 : 2 * segments );
QUDindex = ( 2 : 2 : 2 * segments );

[ BFWcoeffs, BFWerror, BFW_S ] = removeLinear_DropResiduals ( x ( BFWindex ), y ( BFWindex ) );

BFWbaseline = polyval ( BFWcoeffs, x ( BFWindex ), BFW_S );
rmsBFWmove  = std ( y ( BFWindex ) - BFWbaseline );

[ QUDcoeffs, QUDerror, QUD_S ] = removeLinear_DropResiduals ( x ( QUDindex ), y ( QUDindex ) );

QUDbaseline = polyval ( QUDcoeffs, x ( QUDindex ), QUD_S );
rmsQUDmove  = std ( y ( QUDindex ) - QUDbaseline );

if ( rmsBFWmove < rmsQUDmove )
    baseline = polyval ( BFWcoeffs, x, BFW_S );
else
    baseline = polyval ( QUDcoeffs, x, QUD_S );
end

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


function r = validateADS ( x )

if ( abs ( x ) < 1e-10 )
    r = NaN;
else
    r = x;
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

fp = strcat ( newInfo.fb, newInfo.fn );

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

recIDs                                           = newInfo.buffer_recIDs;
records                                          = newInfo.buffer_records;
archive                                          = newInfo.buffer;

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

    getNewADSdata = true;
    
    if ( isfield ( handles, 'ArchiveBrequestDate' ) )
        if ( datestr_fmt1 == handles.ArchiveBrequestDate )
            fprintf ( 'Date already loaded\n' );
%            getNewADSdata = false;
        end
    end

    handles.ArchiveBrequestDate  = datestr_fmt1;

    if ( getNewADSdata )
        params.getNewADSdata = getNewADSdata;
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


% --- Executes on button press in SHOW_BFW_NUMBERS_CHECKBOX.
function SHOW_BFW_NUMBERS_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to SHOW_BFW_NUMBERS_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SHOW_BFW_NUMBERS_CHECKBOX

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

% Hints: contents = get(hObject,'String') returns DISPLAY_MODE_MENU contents as cell array
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


function BFW_PREC_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to BFW_PREC_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BFW_PREC_EDIT as text
%        str2double(get(hObject,'String')) returns contents of BFW_PREC_EDIT as a double

btnString = get ( handles.BFW_PREC_EDIT, 'String' );

btnValue = str2double ( btnString );

if ( isnan ( btnValue ) )
    btnValue = 0;
else
    btnValue = floor ( abs ( btnValue ) );
end

set ( handles.BFW_PREC_EDIT, 'Value', btnValue );
set ( handles.BFW_PREC_EDIT, 'String', sprintf ( '%.0f', btnValue ) );

end


% --- Executes during object creation, after setting all properties.
function BFW_PREC_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BFW_PREC_EDIT (see GCBO)
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
        textStr = sprintf ( 'ADS Reference Date: %s', handles.ADS.reference_date );
        text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'right', 'FontSize', 8, 'Parent', handles.log_fig_Y_axes );
    end

    if ( handles.printTo_e_Log )
        print ( fig, '-dpsc2', '-Pphysics-lclslog', '-adobecset' );
    end
    
    if ( handles.printTo_Files )
        refDate         = now;
        [ fp, success ] = createFolder ( handles.fb, refDate );
        
        if ( success )
            figName = sprintf ( 'UndulatorAlignmentDiagnostics--%s', datestr ( refDate, 'yyyy-mm-dd-HHMMSS' ) );

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
        
switch get ( handles.DISPLAY_MODE_MENU, 'Value' );
    case handles.MODE_DISPLAY_ADS
        modeStr = sprintf ( 'only ADS' );
    case handles.MODE_DISPLAY_CAM
        if ( strcmp ( get ( handles.USE_CAM_REFERENCE_CHECKBOX,  'Visible' ), 'on' ) )
            modeStr = sprintf ( 'CAM - CAMref (%s)', handles.CAM.reference_date );
        else
            modeStr = sprintf ( 'only CAM' );
        end
    case handles.MODE_ADS_CAM
        if ( strcmp ( get ( handles.USE_CAM_REFERENCE_CHECKBOX,  'Visible' ), 'on' ) )
            modeStr = sprintf ( 'ADS - CAM - CAMref (%s)', handles.CAM.reference_date );
        else
            modeStr = sprintf ( 'ADS - CAM' );
        end
end

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
[ fp, success ] = createFolder ( handles.fb, refDate );

if  ( success )    
    handles.fn = sprintf ( 'UndulatorAlignmentDiagnostics--%s.mat', datestr ( refDate, 'yyyy-mm-dd-HHMMSS' ) );
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

fprintf ( 'Closing  UndulatorAlignmentDiagnostics_gui.\n' );

util_appClose ( hObject );
lcaClear ( );

end


% --- Executes on button press in SET_STC_REFERENCE_BTN.
function SET_STC_REFERENCE_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_STC_REFERENCE_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vals = handles.ADS.archive_A_vals;
date = handles.ADS.archive_A_date;

lcaPut ( 'ADS:UND1:SI:REF:TIME', datestr ( date, 'mm/dd/yyyy HH:MM:SS' ) );

n = length ( vals.x );

for slot = 1 : n / 2
    jb = ( slot - 1 ) * 2 + 1;
    jq = ( slot - 1 ) * 2 + 2;

%    fprintf ( '%2.2d: x: %f; y: %f; r: %f\n', slot, vals.x ( jb ), vals.y ( jb ), vals.r ( jb ) );
%    fprintf (    '    x: %f; y: %f; r: %f\n',       vals.x ( jq ), vals.y ( jq ), vals.r ( jq ) );

    lcaPut ( handles.ADS.refPVs { handles.ADS.PVindex ( slot, 1, 1 ) }, zeroNaN (vals.x ( jb ) ) );
    lcaPut ( handles.ADS.refPVs { handles.ADS.PVindex ( slot, 1, 2 ) }, zeroNaN (vals.y ( jb ) ) );
    lcaPut ( handles.ADS.refPVs { handles.ADS.PVindex ( slot, 1, 3 ) }, zeroNaN (vals.r ( jb ) ) );

    lcaPut ( handles.ADS.refPVs { handles.ADS.PVindex ( slot, 2, 1 ) }, zeroNaN (vals.x ( jq ) ) );
    lcaPut ( handles.ADS.refPVs { handles.ADS.PVindex ( slot, 2, 2 ) }, zeroNaN (vals.y ( jq ) ) );
    lcaPut ( handles.ADS.refPVs { handles.ADS.PVindex ( slot, 2, 3 ) }, zeroNaN (vals.r ( jq ) ) );
end

% Copy the LTQ readings for the fixed sensors upstream of the first girder
% to the RFQ location. This readings is presently not monitored.

lcaPut ( 'ADS:UND1:100:RFBPM_RFQ_XPOS', zeroNaN ( lcaGet ( 'ADS:UND1:100:RFBPM_LTQ_XPOS' ) ) );
lcaPut ( 'ADS:UND1:100:RFBPM_RFQ_YPOS', zeroNaN ( lcaGet ( 'ADS:UND1:100:RFBPM_LTQ_YPOS' ) ) );
lcaPut ( 'ADS:UND1:100:RFBPM_REF_ROLL', zeroNaN ( lcaGet ( 'ADS:UND1:100:RFBPM_LTC_ROLL' ) ) );

end


function c = zeroNaN ( x )

if ( isnan ( x ) )
    c = 0;
else
    c = x;
end

end
