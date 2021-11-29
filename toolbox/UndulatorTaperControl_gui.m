function varargout = UndulatorTaperControl_gui(varargin)
% UNDULATORTAPERCONTROL_GUI M-file for UndulatorTaperControl_gui.fig
%      UNDULATORTAPERCONTROL_GUI, by itself, creates a new UNDULATORTAPERCONTROL_GUI or raises the existing
%      singleton*.
%
%      H = UNDULATORTAPERCONTROL_GUI returns the handle to a new UNDULATORTAPERCONTROL_GUI or the handle to
%      the existing singleton*.
%
%      UNDULATORTAPERCONTROL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDULATORTAPERCONTROL_GUI.M with the given input arguments.
%
%      UNDULATORTAPERCONTROL_GUI('Property','Value',...) creates a new UNDULATORTAPERCONTROL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UndulatorTaperControl_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UndulatorTaperControl_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UndulatorTaperControl_gui

% Last Modified by GUIDE v2.5 03-May-2011 12:21:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UndulatorTaperControl_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UndulatorTaperControl_gui_OutputFcn, ...
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


% --- Executes just before UndulatorTaperControl_gui is made visible.
function UndulatorTaperControl_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UndulatorTaperControl_gui (see VARARGIN)

global timerRunning;
global timerRestart;
global timerDelay;
global timerData;
global debug;
global hh;
global OPctrl;

handles.fb                  = '/u1/lcls/matlab/UndulatorTaperControl_gui/';
OPctrl.bufSize              = 20;                           % Number of integration samples for peak current averaging.
OPctrl.IpkBuf               = zeros ( 1, OPctrl.bufSize );
OPctrl.Ipklvl               = 0;

handles.PhyConsts           = util_PhysicsConstants;
handles.UndConsts           = util_UndulatorConstants;

timerRunning                = false;
timerRestart                = false;
timerDelay                  = 2;      % sec
timerData.hObject           = hObject;
debug                       = false;

handles.printTo_e_Log       = true;
handles.printTo_Files       = true;


%if ( isnan ( lcaGet ( 'YAGS:DMP1:500:FOIL1_PNEU', 0, 'double' ) ) )
    handles.YAGXRAYavailable = false;
    fprintf ( 'YAGXRAY is not available. Continuing without ...\n' );
%else
%    handles.YAGXRAYavailable = true;
%end

% Choose default command line output for UndulatorTaperControl_gui
handles.output              = hObject;
handles.Segments            = 33;
handles.EnergyLoss          = cell ( handles.Segments );
handles.dZ                  = 1033.340493;  % m z-Offset between LCLS and Station-100 Corrdinate system
handles.SegmentFieldLength  = handles.UndConsts.SegmentPeriods * handles.UndConsts.lambda_u;     % m
handles.isInstalled         = zeros ( 1, handles.Segments );
handles.moving_fstK         = false;
handles.LTU_Wake_Loss       = 30.0; % MeV

% For reason of compatibility, never change IDs, just add numbers.

handles.ID_ADD_GAIN_TAPER_BOX            =  1;
handles.ID_GAIN_TAPER_START_SEGMENT      =  2;
handles.ID_GAIN_TAPER_END_SEGMENT        =  3;
handles.ID_GAIN_TAPER_AMPLITUDE          =  4;
handles.ID_ADD_POST_SATURATION_TAPER_BOX =  5;
handles.ID_POST_TAPER_START_SEGMENT      =  6;
handles.ID_POST_TAPER_END_SEGMENT        =  7;
handles.ID_POST_TAPER_AMPLITUDE          =  8;

handles.ID_POST_TAPER_TYPE               =  9;
handles.ID_POST_TAPER_LG                 = 10;
handles.ID_USE_SPONT_RAD_BOX             = 11;
handles.ID_USE_WAKEFIELDS_BOX            = 12;
handles.ID_SET_ENERGY                    = 13;
handles.ID_SET_BUNCH_CHARGE              = 14;
handles.ID_SET_PEAK_CURRENT              = 15;
handles.ID_COMPRESSION_STATUS            = 16;
handles.ID_AUTOMOVE                      = 17;

handles.presentTaperParms { handles.ID_ADD_GAIN_TAPER_BOX }.PV              = 'SIOC:SYS0:ML00:AO422';
handles.presentTaperParms { handles.ID_GAIN_TAPER_START_SEGMENT }.PV        = 'SIOC:SYS0:ML00:AO423';
handles.presentTaperParms { handles.ID_GAIN_TAPER_END_SEGMENT }.PV          = 'SIOC:SYS0:ML00:AO424';
handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.PV            = 'SIOC:SYS0:ML00:AO425';
handles.presentTaperParms { handles.ID_ADD_POST_SATURATION_TAPER_BOX }.PV   = 'SIOC:SYS0:ML00:AO426';
handles.presentTaperParms { handles.ID_POST_TAPER_START_SEGMENT }.PV        = 'SIOC:SYS0:ML00:AO427';
handles.presentTaperParms { handles.ID_POST_TAPER_END_SEGMENT }.PV          = 'SIOC:SYS0:ML00:AO428';
handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.PV            = 'SIOC:SYS0:ML00:AO429';
handles.presentTaperParms { handles.ID_AUTOMOVE }.PV                        = 'SIOC:SYS0:ML00:AO430';

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE }.PV                 = 'SIOC:SYS0:ML00:AO411'; 
handles.presentTaperParms { handles.ID_POST_TAPER_LG }.PV                   = 'SIOC:SYS0:ML00:AO412'; 
handles.presentTaperParms { handles.ID_USE_SPONT_RAD_BOX }.PV               = 'SIOC:SYS0:ML00:AO413'; 
handles.presentTaperParms { handles.ID_USE_WAKEFIELDS_BOX }.PV              = 'SIOC:SYS0:ML00:AO414'; 
handles.presentTaperParms { handles.ID_SET_ENERGY }.PV                      = 'SIOC:SYS0:ML00:AO415'; 
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE }.PV                = 'SIOC:SYS0:ML00:AO416'; 
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT }.PV                = 'SIOC:SYS0:ML00:AO417'; 
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.PV              = 'SIOC:SYS0:ML00:AO418'; 

handles.presentTaperParms { handles.ID_ADD_GAIN_TAPER_BOX }.str             = false;
handles.presentTaperParms { handles.ID_GAIN_TAPER_START_SEGMENT }.str       = true;
handles.presentTaperParms { handles.ID_GAIN_TAPER_END_SEGMENT }.str         = true;
handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.str           = true;
handles.presentTaperParms { handles.ID_ADD_POST_SATURATION_TAPER_BOX }.str  = false;
handles.presentTaperParms { handles.ID_POST_TAPER_START_SEGMENT }.str       = true;
handles.presentTaperParms { handles.ID_POST_TAPER_END_SEGMENT }.str         = true;
handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.str           = true;
handles.presentTaperParms { handles.ID_AUTOMOVE }.str                       = false;

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE }.str                = false; 
handles.presentTaperParms { handles.ID_POST_TAPER_LG }.str                  = false; 
handles.presentTaperParms { handles.ID_USE_SPONT_RAD_BOX }.str              = false; 
handles.presentTaperParms { handles.ID_USE_WAKEFIELDS_BOX }.str             = false; 
handles.presentTaperParms { handles.ID_SET_ENERGY }.str                     = false; 
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE }.str               = false; 
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT }.str               = false; 
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.str             = false; 
 
handles.presentTaperParms { handles.ID_ADD_GAIN_TAPER_BOX }.hobj            = handles.ADD_GAIN_TAPER_BOX;
handles.presentTaperParms { handles.ID_GAIN_TAPER_START_SEGMENT }.hobj      = handles.GAIN_TAPER_START_SEGMENT;
handles.presentTaperParms { handles.ID_GAIN_TAPER_END_SEGMENT }.hobj        = handles.GAIN_TAPER_END_SEGMENT;
handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.hobj          = handles.GAIN_TAPER_AMPLITUDE;
handles.presentTaperParms { handles.ID_ADD_POST_SATURATION_TAPER_BOX }.hobj = handles.ADD_POST_SATURATION_TAPER_BOX;
handles.presentTaperParms { handles.ID_POST_TAPER_START_SEGMENT }.hobj      = handles.POST_TAPER_START_SEGMENT;
handles.presentTaperParms { handles.ID_POST_TAPER_END_SEGMENT }.hobj        = handles.POST_TAPER_END_SEGMENT;
handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.hobj          = handles.POST_TAPER_AMPLITUDE;
handles.presentTaperParms { handles.ID_AUTOMOVE }.hobj                      = handles.AUTO_MOVE_CHECKBOX;

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE }.hobj               = handles.POST_TAPER_MENU; 
handles.presentTaperParms { handles.ID_POST_TAPER_LG }.hobj                 = handles.POST_TAPER_LG; 
handles.presentTaperParms { handles.ID_USE_SPONT_RAD_BOX }.hobj             = handles.USE_SPONT_RAD_BOX; 
handles.presentTaperParms { handles.ID_USE_WAKEFIELDS_BOX }.hobj            = handles.USE_WAKEFIELDS_BOX; 
handles.presentTaperParms { handles.ID_SET_ENERGY }.hobj                    = handles.SET_ENERGY_RADIO_BTN; 
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE }.hobj              = handles.SET_BUNCH_CHARGE_RADIO_BTN; 
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT }.hobj              = handles.SET_PEAK_CURRENT_RADIO_BTN; 
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.hobj            = handles.COMPRESSION_STATUS; 

handles.ntps = length ( handles.presentTaperParms );

for j = 1 : handles.ntps
    handles.presentTaperParms { j }.set_callback = '';
    handles.presentTaperParms { j }.get_callback = '';
end

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE    }.set_callback    = 'setPostTaperType';
handles.presentTaperParms { handles.ID_SET_ENERGY         }.set_callback    = 'setRadioButton';
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE   }.set_callback    = 'setRadioButton';
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT   }.set_callback    = 'setRadioButton';
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.set_callback    = 'setCompressionStatus';
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.get_callback    = 'getCompressionStatus';
handles.presentTaperParms { handles.ID_AUTOMOVE           }.set_callback    = 'setAutomoveStatus';

handles.PostTaperModes    = { 'Linear', 'Quadratic', 'Exponential' };
handles.PostTaperLinearID = 1;
handles.PostTaperSquareID = 2;
handles.PostTaperExpontID = 3;

set ( handles.POST_TAPER_MENU, 'String', handles.PostTaperModes );

handles                     = getKcoeffs ( handles );
handles.slideAdjust         = getSlideAdjusts;
hh                          = handles;

handles.initialDate         = sprintf ( '%s', datestr ( now,'mm/dd/yyyy HH:MM:SS' ) );
handles.initialKvalues      = loadPresentKvalues ( handles );
handles.referenceDate       = handles.initialDate;
handles.referenceKvalues    = handles.initialKvalues;

set ( handles.GAIN_TAPER_SOFT_PV, 'String', handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.PV );
set ( handles.POST_TAPER_SOFT_PV, 'String', handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.PV );
set ( handles.AUTOMOVE_SOFT_PV,   'String', handles.presentTaperParms { handles.ID_AUTOMOVE }            .PV );

set ( handles.MODEL_BEAM_ENERGY,  'String', lcaGet ( sprintf ( 'SIOC:SYS0:ML00:AO122' ) ) );
set ( handles.MODEL_BUNCH_CHARGE, 'String', lcaGet ( sprintf ( 'SIOC:SYS0:ML00:AO104' ) ) * 1e3 );
set ( handles.MODEL_PEAK_CURRENT, 'String', lcaGet ( sprintf ( 'SIOC:SYS0:ML00:AO188' ) ) );

if ( handles.printTo_Files || handles.printTo_e_Log )
    handles.log_fig  = figure ( 'Visible', 'Off' );
    handles.log_axes = axes;
end

for slot = 1 : handles.Segments
    handles.UndConsts.Z_US { slot }   = handles.UndConsts.Z_US { slot } + handles.dZ;

    handles.EnergyLoss { slot }.z_ini = handles.UndConsts.Z_US { slot } - handles.SegmentFieldLength / 2;
    handles.EnergyLoss { slot }.z_end = handles.UndConsts.Z_US { slot } + handles.SegmentFieldLength / 2;
    
    try
        handles.isInstalled ( slot )  = lcaGet ( sprintf ( 'USEG:UND1:%d50:INSTALTNSTAT', slot ), 0, 'double' );
    catch       
        handles.isInstalled ( slot )  = 0;
    end
end

handles.fstSegment   = findFirstSegment ( handles.Segments );
fstK                 = getEquivalentKvalue ( handles.fstSegment );

%fstK = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', handles.fstSegment ) );
set ( handles.FST_K, 'String', sprintf ( '%6.4f', fstK ) );
set ( handles.FST_K, 'Value',  fstK );

manageBeamEnergyRadioButtons  ( handles, 2 )
manageBunchChargeRadioButtons ( handles, 2 )
managePeakCurrentRadioButtons ( handles, 2 )

automove_state = lcaGet ( [handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'] ); %Read Matlab PV to see if automove is enabled by any instance; JR 4/15/11

if ( automove_state )
    resp = questdlg ( 'Keep K values at red line is enabled. Change?', 'Autoadjust K', 'Enable', 'Disable', 'Disable' );
    set ( handles.AUTO_MOVE_CHECKBOX, 'Value', strcmp ( resp, 'Enable' ) );
end

AUTO_MOVE_CHECKBOX_Callback ( hObject, eventdata, handles );

timerData.handles = handles;
handles           = updateDisplay ( handles );

% Update handles structure
guidata ( hObject, handles );

% UIWAIT makes UndulatorTaperControl_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


% --- Outputs from this function are returned to the command line.
function varargout = UndulatorTaperControl_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

% Get default command line output from handles structure
varargout { 1 } = handles.output;

handles.presentTaperParms   = loadTaperParmsFromSOFTPVs ( handles.presentTaperParms );
handles.initialTaperParms   = handles.presentTaperParms;

setContinuousRefreshMode ( handles );

timerData.handles = handles;

% Update handles structure
guidata ( hObject, handles );

end


function listTaperParms ( Parms )

for j = 1 : length ( Parms )
    PV = Parms { j }.PV;
    vl = Parms { j }.VAL;
    
    fprintf ( '%2.2d: PV %s -> %f.\n', j, PV, vl );
end

end


function new_Parms = writeTaperParmsFromStruct ( Parms )

for j = 1 : length ( Parms )
    parm2gui  ( Parms { j }.VAL, Parms { j } );
    setSOFTPV ( Parms, j );
end

new_Parms = Parms;

end


function new_Parms = readTaperParmsToStruct ( Parms )

for j = 1 : length ( Parms )
    Parms { j }.VAL = gui2parm ( Parms { j } );
end

new_Parms = Parms;

end


function new_Parms = loadTaperParmsFromSOFTPVs ( Parms )

for j = 1 : length ( Parms )
    Parms = loadSOFTPV ( Parms, j );
end

new_Parms = Parms;

end


function writeTaperParmsToSOFTPVs ( Parms )

for j = 1 : length ( Parms )
    setSOFTPV ( Parms, j );
end

end


function new_Parms = loadSOFTPV ( Parms, ID )

PV      = Parms { ID }.PV;
success = true;

try
    vl = lcaGet ( strcat ( PV, '.VAL' ) );
catch
    fprintf ( 'Unable to get taper parameter PV %s.\n', PV );
    success = false;
end

if ( success )
    parm2gui ( vl, Parms { ID } );
    Parms { ID }.VAL = vl;
end

new_Parms = Parms;

end


function parm2gui ( value, parm )

hObject = parm.hobj;

if ( any ( parm.set_callback ) )
    f = str2func ( parm.set_callback );
    f ( hObject, value );
else
    if  ( parm.str )
        set ( hObject, 'String', sprintf ( '%.0f', value ) );
    else
        set ( hObject, 'Value', value );
    end
end

end


function value = gui2parm ( parm )

hObject = parm.hobj;

if ( any ( parm.get_callback ) )
    f = str2func ( parm.get_callback );
    value = f ( hObject );
else
    if  ( parm.str )
        value = str2double ( get ( hObject, 'String' ) );
    else
        value = get ( hObject, 'Value' );
    end
end

end


 function setRadioButton ( hObject, value )

global timerData;

handles = timerData.handles;

switch hObject
    case handles.SET_ENERGY_RADIO_BTN
        manageBeamEnergyRadioButtons  ( handles, value + 1 )
    case handles.SET_BUNCH_CHARGE_RADIO_BTN
        manageBunchChargeRadioButtons ( handles, value + 1 )
    case handles.SET_PEAK_CURRENT_RADIO_BTN
        managePeakCurrentRadioButtons ( handles, value  + 1 );
end

end


function setCompressionStatus ( hObject, value )

global timerData;

handles = timerData.handles;

if ( value == 2 )
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Overcompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Undercompression' );
else
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Undercompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Overcompression' );
end

end

function setAutomoveStatus ( hObject, value )

global timerData;

handles = timerData.handles;

if ( lcaGet ( [handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'] ) == 0 )
    set ( handles.AUTO_MOVE_CHECKBOX, 'Value', 0);
%     AUTO_MOVE_CHECKBOX_Callback(handles.AUTO_MOVE_CHECKBOX, [], handles);
end

end

function value = getCompressionStatus ( hObject )

COMPRESSION_STATUS = get ( hObject, 'String' );

if ( strfind ( upper ( COMPRESSION_STATUS ), 'UNDER' ) )
    value = 1;
else
    value = 2;
end

end


function setPostTaperType ( hObject, value )
global timerData;

handles = timerData.handles;

set ( hObject, 'Value', value );

manageTaperTypeMenu ( handles )

end


function setSOFTPV ( Parms, ID )

PV = Parms { ID }.PV;
vl = gui2parm ( Parms { ID } );

try
    lcaPut ( strcat ( PV, '.VAL' ), vl );
catch
    fprintf ( 'Unable to set taper parameter PV %s to %f.\n', PV, vl );
end

end


% --- Executes on button press in SAVE_REFERENCE_BTN.
function SAVE_REFERENCE_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SAVE_REFERENCE_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

handles.referenceDate    = sprintf ( '%s', datestr ( now,'mm/dd/yyyy HH:MM:SS' ) );
handles.referenceKvalues = loadPresentKvalues ( handles );

%handles                     = updateDisplay ( handles );

%if ( isfield ( handles, 'fstSegment' ) )
%    if ( isActive ( handles.fstSegment ) && newKvalue > 0 )        
%        x = setKofSlot ( handles, newKvalue, handles.fstSegment );
%    end
%end

handles           = saveData ( handles );
timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


function new_handles = saveData ( handles )

new_handles                  = handles;
new_handles.referenceXvalues = zeros ( 1, new_handles.Segments );

for slot = 1 : new_handles.Segments
    new_handles.referenceXvalues ( slot ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:TM2MOTOR.RBV', slot ) );
end

refDate         = now;
[ fp, success ] = createFolder ( new_handles.fb, refDate );

if  ( success )    
    new_handles.fp     = fp;
    new_handles.fn     = sprintf ( 'TaperCtrl_%05.0fMeV_%04.0fpC--%s.mat', ...
                                   new_handles.ActualBeamEnergy * 1e3, ...
                                   new_handles.BunchCharge, ...
                                   datestr ( now,'yyyy-mm-dd-HHMMSS' ) );
    new_handles.fd     = sprintf ( '%s%s', new_handles.fp, new_handles.fn );
    save ( new_handles.fd, 'handles' );
    
    fprintf ( 'Saved data to %s\n', new_handles.fn ); 
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


% --- Executes on button press in RESTORE_REFERENCE_BTN.
function RESTORE_REFERENCE_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to RESTORE_REFERENCE_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

%listTaperParms ( handles.referenceTaperParms );
%listTaperParms ( handles.presentTaperParms   );

%handles.presentTaperParms = writeTaperParmsFromStruct ( handles.referenceTaperParms );
%handles                   = updateDisplay ( handles );

if ( ~isfield ( handles, 'fn' ) )
%    handles.fn = 'UndulatorTaperControl--2009-05-04-233809.mat';
    handles.fn = 'TaperCtrl_13700Mev_0250pC--2009-05-04-233809.mat';
end

%handles.FilterSpec  = sprintf ( '%sUndulatorTaperControl--*.mat', handles.fb );
%handles.FilterSpec  = sprintf ( '%sTaperCtrl_*.mat', handles.fb );
refDate         = now;
handles.FilterSpec  = sprintf ( '%sTaperCtrl_*.mat', getFilterSpec ( handles.fb, refDate ) );
handles.DialogTitle = 'DialogTitle';

%FilterSpec = handles.FilterSpec;

success = true;

try
    [ FileName, PathName, FilterIndex ] = uigetfile ( handles.FilterSpec, handles.DialogTitle, '' );
catch
    success = false;
end

if ( ~success )
    return;
end

if ( ~FileName )
    return;
end

handles.LastRestore_fd   = sprintf ( '%s%s', PathName, FileName );
saved                    = load ( handles.LastRestore_fd );
handles.referenceKvalues = saved.handles.referenceKvalues;

setKvalues ( handles, handles.referenceKvalues );

%listTaperParms ( handles.presentTaperParms   );

timerData.handles = handles;

% Update handles structure
guidata ( hObject, handles );

end


function FilterSpec = getFilterSpec ( base, refDate )
	FilterSpec  = sprintf ( '%s%s/%s/%s/', base, datestr ( refDate, 'yyyy' ), datestr ( refDate, 'yyyy-mm' ), datestr ( refDate, 'yyyy-mm-dd' ) );
    
    if ( exist ( FilterSpec, 'dir' ) )
        return;
    end
    
	FilterSpec  = sprintf ( '%s%s/%s/', base, datestr ( refDate, 'yyyy' ), datestr ( refDate, 'yyyy-mm' ) );
    
    if ( exist ( FilterSpec, 'dir' ) )
        return;
    end
    
	FilterSpec  = sprintf ( '%s%s/', base, datestr ( refDate, 'yyyy' ) );
    
    if ( exist ( FilterSpec, 'dir' ) )
        return;
    end
    
	FilterSpec  = base;
end


% --- Executes on button press in RESTORE_INITIAL_BTN.
function RESTORE_INITIAL_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to RESTORE_INITIAL_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global timerData;

setKvalues ( handles, handles.initialKvalues );
%handles.presentTaperParms = writeTaperParmsFromStruct ( handles.initialTaperParms );
%handles                   = updateDisplay ( handles );

%timerData.handles = handles;

% Update handles structure
%guidata ( hObject, handles );

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

timerObj     = timer ( 'TimerFcn', @Timer_Callback_fcn, 'Period', timerDelay, 'ExecutionMode', 'fixedRate' );
timerRestart = true;

if ( debug )
    fprintf ( 'Starting Timer\n' );
end

timerData.handles = handles;
start ( timerObj );
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

set ( handles.DATESTRING, 'String', sprintf ( '%s%s', datestr ( now,'dddd, ' ), datestr ( now,'mmmm dd, yyyy HH:MM:SS' ) ) );
set ( handles.DATESTRING, 'Visible', 'On' );

handles = updateDisplay ( handles );

% Update handles structure
guidata ( hObject, handles );

timerData.handles = handles;

if ( debug )
    fprintf ( '%s event occurred at %s\n', event.Type, datestr ( event.Data.time ) );
    get ( obj );
end

end


function new_handles = calculateEnergyLoss ( handles )

handles.BeamEnergy = getBeamEnergy ( handles );

Kact               = UndKact ( 1 : handles.Segments );
SpontRamp          = handles.PhyConsts.c^3 * handles.PhyConsts.Z_0 * handles.PhyConsts.echarge / ( 12 * pi * handles.PhyConsts.mc2_e^4 );  % 1/(T^2 Vm)
ku                 = 2 * pi / handles.UndConsts.lambda_u;
Bact               = ( handles.PhyConsts.mc2_e * ku ) * Kact / handles.PhyConsts.c;

cur_Spont_dE       = 0;
cur_Wake_dE        = 0;

avgCore_WakeRate   = getAverageCoreWakeRate ( handles );

for slot = 1 : handles.Segments
    handles.EnergyLoss { slot }.Spont_dE_ini = cur_Spont_dE;
    handles.EnergyLoss { slot }.Wake_dE_ini  = cur_Wake_dE;

    if ( useSpontaneous ( handles ) )
        DE_spont_dz    = -SpontRamp * ( handles.BeamEnergy * 10^9 )^2 * Bact ( slot )^2;    % V/m
        cur_Spont_dE   = cur_Spont_dE + DE_spont_dz * handles.SegmentFieldLength;
    end

    if ( useWakefields ( handles ) )
        DE_wake_dz     = avgCore_WakeRate;                                                 % V/m
        
        if ( slot == 1 )
            WakeLength = handles.UndConsts.SegmentLength;
        elseif ( slot == 33 )
            WakeLength = handles.UndConsts.SegmentLength;
        else
            WakeLength = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { slot - 1 };
        end
        
        cur_Wake_dE        = cur_Wake_dE + DE_wake_dz * WakeLength;
    end

    handles.EnergyLoss { slot }.Spont_dE_end = cur_Spont_dE;
    handles.EnergyLoss { slot }.Wake_dE_end  = cur_Wake_dE;
    
%    fprintf ( '%f -> %f\n', handles.EnergyLoss { slot }.Spont_dE_ini, handles.EnergyLoss { slot }.Spont_dE_end );
end

%for slot = 1 : handles.Segments
%    fprintf ( '%2.2d %f %f\n', slot, handles.EnergyLoss { slot }.Spont_dE_ini, handles.EnergyLoss { slot }.Spont_dE_end );
%end

new_handles = handles;

end

function new_handles = estimateOptimumGainTaper ( handles )

iniSeg                   = str2double ( get ( handles.GAIN_TAPER_START_SEGMENT, 'String' ) );
endSeg                   = str2double ( get ( handles.GAIN_TAPER_END_SEGMENT,   'String' ) );

iniSeg                   = min ( handles.Segments, max (      1, iniSeg ) );
endSeg                   = min ( handles.Segments, max ( iniSeg, endSeg ) );

emittance                = 0.5;
rmsLB                    = handles.BunchCharge * handles.PhyConsts.c / ( handles.PeakCurrent * sqrt ( 12 ) );
dgamma                   = 2.8;

handles.FELp             = util_LCLS_FEL_Performance_Estimate ( handles.BeamEnergy, emittance, handles.PeakCurrent, rmsLB, dgamma );

sectionLength            = handles.UndConsts.Z_US { endSeg } - handles.UndConsts.Z_US { iniSeg } + handles.UndConsts.SegmentLength;

handles.OptimumGainTaper =  -2 * handles.FELp.rho_3D * handles.FELp.gamma / handles.FELp.L_sat_c * handles.PhyConsts.mc2_e * sectionLength / 1e6;

new_handles              = handles;

end


function new_handles = calculateGainTaper ( handles )

iniSeg             = str2double ( get ( handles.GAIN_TAPER_START_SEGMENT, 'String' ) );
endSeg             = str2double ( get ( handles.GAIN_TAPER_END_SEGMENT,   'String' ) );
TapAmp             = str2double ( get ( handles.GAIN_TAPER_AMPLITUDE,     'String' ) ) * 1e6; % eV

iniSeg             = min ( handles.Segments, max (      1, iniSeg ) );
endSeg             = min ( handles.Segments, max ( iniSeg, endSeg ) );

nSegs              = endSeg - iniSeg + 1;

for slot = 1 : handles.Segments
    handles.EnergyLoss { slot }.Gain_dE_ini  = 0;
    handles.EnergyLoss { slot }.Gain_dE_end  = 0;
end

if ( ~nSegs )
    new_handles = handles;
    return;
end

TapRate            = TapAmp / ( handles.UndConsts.Z_US { endSeg } - handles.UndConsts.Z_US { iniSeg } + handles.UndConsts.SegmentLength );

cur_Gain_dE        = 0;

for slot = iniSeg : handles.Segments
    handles.EnergyLoss { slot }.Gain_dE_ini  = cur_Gain_dE;

    if ( addGainTaper ( handles )  && slot <= endSeg )
        DE_gain_dz     = TapRate;                                                 % V/m
        
        if ( slot == 1 )
            SegLength = handles.UndConsts.SegmentLength;
        elseif ( slot == 33 )
            SegLength = handles.UndConsts.SegmentLength;
        else
            SegLength = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { slot - 1 };
        end
        
        cur_Gain_dE        = cur_Gain_dE + DE_gain_dz * SegLength;
    end

    handles.EnergyLoss { slot }.Gain_dE_end  = cur_Gain_dE;
end

new_handles = handles;

end


function new_handles = calculateSatTaper ( handles )

iniSeg = str2double ( get ( handles.POST_TAPER_START_SEGMENT, 'String' ) );
endSeg = str2double ( get ( handles.POST_TAPER_END_SEGMENT,   'String' ) );
TapAmp = str2double ( get ( handles.POST_TAPER_AMPLITUDE,     'String' ) ) * 1e6; % eV

iniSeg = min ( handles.Segments, max (      1, iniSeg ) );
endSeg = min ( handles.Segments, max ( iniSeg, endSeg ) );

nSegs  = endSeg - iniSeg + 1;

for slot = 1 : handles.Segments
    handles.EnergyLoss { slot }.Sat_dE_ini  = 0;
    handles.EnergyLoss { slot }.Sat_dE_end  = 0;
end

if ( ~nSegs )
    new_handles = handles;
    return;
end

sectionLength = handles.UndConsts.Z_US { endSeg } - handles.UndConsts.Z_US { iniSeg };
LG            = str2double ( get ( handles.POST_TAPER_LG, 'String' ) );
expFact       = - TapAmp / ( LG * ( 1 - exp ( sectionLength / LG ) ) );
cur_Sat_dE    = 0;

for slot = iniSeg : handles.Segments
    handles.EnergyLoss { slot }.Sat_dE_ini  = cur_Sat_dE;
    zposition                               = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { iniSeg };

    if ( addPostSaturationTaper ( handles ) && slot <= endSeg )
        switch get ( handles.POST_TAPER_MENU, 'Value' )
            case handles.PostTaperLinearID
                DE_sat_dz = TapAmp / sectionLength;                           % V/m
            case handles.PostTaperSquareID
                DE_sat_dz = 2 * TapAmp * zposition / sectionLength^2;         % V / m
            case handles.PostTaperExpontID
                DE_sat_dz = expFact * exp ( zposition / LG );                 % V / m
        end
    
        if ( slot == 1 || slot == 33 )
            SegCenterDistance = handles.UndConsts.SegmentLength;
        else
            SegCenterDistance = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { slot - 1 };
        end
        
        cur_Sat_dE        = cur_Sat_dE + DE_sat_dz * SegCenterDistance;
    end

    handles.EnergyLoss { slot }.Sat_dE_end  = cur_Sat_dE;
end

new_handles = handles;

end


function avgCore_WakeRate   = getAverageCoreWakeRate ( handles )

peakCurrent = getPeakCurrent ( handles );
bunchCharge = getBunchCharge ( handles );
compStatus  = isUndercompressed ( handles );

avgCore_WakeRate = util_UndulatorWakeAmplitude ( peakCurrent / 1000, bunchCharge, compStatus ) * 1000;

end


function firstSegment = findFirstSegment ( n )

firstSegment = 0;

for slot = 1 : n
    if ( isActive ( slot ) )
        firstSegment = slot;
        break;
    end
end

end


function new_handles = calculateTaperRequirement ( handles )

handles.BeamEnergy = getBeamEnergy ( handles );
Kact               = zeros ( 1 , handles.Segments );

for slot = 1 : handles.Segments
    Kact ( slot ) = getEquivalentKvalue ( slot );

%    Kact ( slot ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
    
    if ( ~Kact ( slot ) )
        Kact ( slot ) = UndKact ( slot );
    end
end

handles.fstSegment  = findFirstSegment ( handles.Segments );

if ( handles.fstSegment )
    Kini     = Kact ( handles.fstSegment );
%    Kini     = 3.507;
    dKK_dgg  = ( 2 / Kini^2 + 1 );
else    
    Kini     = 0;
    dKK_dgg  = 0;
end

handles = calculateGainTaper ( handles );
handles = calculateSatTaper  ( handles );

if ( handles.fstSegment )
    for slot = 1 : handles.Segments
        dE_ini = 0;
        
        if ( useSpontaneous ( handles ) )
            if ( Kact ( slot ) > 0 )
                dE_ini = dE_ini +  handles.EnergyLoss { slot }.Spont_dE_ini - handles.EnergyLoss { handles.fstSegment }.Spont_dE_ini;
            end
        end

        if ( useWakefields ( handles ) )
            dE_ini = dE_ini + handles.EnergyLoss { slot }.Wake_dE_ini  - handles.EnergyLoss { handles.fstSegment }.Wake_dE_ini;
        end

        if ( addGainTaper ( handles ) )
            dE_ini = dE_ini + handles.EnergyLoss { slot }.Gain_dE_ini  - handles.EnergyLoss { handles.fstSegment }.Gain_dE_ini;
        end
        
        if ( addPostSaturationTaper ( handles ) )
            dE_ini = dE_ini + handles.EnergyLoss { slot }.Sat_dE_ini  - handles.EnergyLoss { handles.fstSegment }.Sat_dE_ini;
        end
        
        handles.EnergyLoss { slot }.Kt_ini = Kini * dE_ini   / (handles.BeamEnergy * 10^9 ) * dKK_dgg + Kini;

        dE_end = 0;     
        
        if ( useSpontaneous ( handles ) )
            if ( Kact ( slot ) > 0 )
                dE_end = dE_end +  handles.EnergyLoss { slot }.Spont_dE_end - handles.EnergyLoss { handles.fstSegment }.Spont_dE_ini;
            end
        end

        if ( useWakefields ( handles ) )
            dE_end = dE_end + handles.EnergyLoss { slot }.Wake_dE_end  - handles.EnergyLoss { handles.fstSegment }.Wake_dE_ini;
        end
    
        if ( addGainTaper ( handles ) )
            dE_end = dE_end + handles.EnergyLoss { slot }.Gain_dE_end  - handles.EnergyLoss { handles.fstSegment }.Gain_dE_ini;
        end
        
        if ( addPostSaturationTaper ( handles ) )
            dE_end = dE_end + handles.EnergyLoss { slot }.Sat_dE_end  - handles.EnergyLoss { handles.fstSegment }.Sat_dE_ini;
        end
        
        handles.EnergyLoss { slot }.Kt_end = Kini * dE_end   / (handles.BeamEnergy * 10^9 ) * dKK_dgg + Kini;
    
%        fprintf ( '%2.2d %f -> %f\n', slot, handles.EnergyLoss { slot }.Kt_ini, handles.EnergyLoss { slot }.Kt_end );
    end
else
    for slot = 1 : handles.Segments
        handles.EnergyLoss { slot }.Kt_ini = 0;
        handles.EnergyLoss { slot }.Kt_end = 0;
    end
end

%    for slot = 1 : handles.Segments
%        fprintf ( 'slot %2.2d: Kt_ini: %6.4f; Kt_end: %6.4f\n', slot, handles.EnergyLoss { slot }.Kt_ini, handles.EnergyLoss { slot }.Kt_end );
%    end

new_handles = handles;

end


function plotK ( axes_handle, handles )

plot ( 1:100, 0 * sin ( ( 1 : 100 ) *pi / 50 ), 'Parent', axes_handle );

hold ( axes_handle, 'on' );
grid ( axes_handle, 'on' );

xlabel ( 'z [m]', 'Parent', axes_handle );
ylabel ( 'K',     'Parent', axes_handle );

zini = 510 + handles.dZ;
zend = 650 + handles.dZ;

xinmax =  getXINMAX ( 1 : 33 );

%axis ( axes_handle, [ zini zend 3.465 3.515 ]);
%axis ( axes_handle, [ zini zend 3.445 3.515 ]);
axis ( axes_handle, [ zini zend 3.4125 3.515 ]);

Kmax_reg = UndKact ( 1 : 33, ( 1 : 33 ) * 0 -  5 );
Kmin_reg = UndKact ( 1 : 33, xinmax );

Kmax_ext = UndKact ( 1 : 33, xinmax );
Kmin_ext = UndKact ( 1 : 33, xinmax + 4 );

segP     = zeros ( 1, 2 );
segK     = zeros ( 1, 2 );

MntCount = 0;
EquCount = 0;

for slot = 1 : handles.Segments
    segP ( 1 ) = handles.EnergyLoss { slot }.z_ini;
    segP ( 2 ) = handles.EnergyLoss { slot }.z_end;

    segK ( 1 ) = getEquivalentKvalue ( slot );
%    segK ( 1 ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
    segK ( 2 ) = segK ( 1 );

    [ segRx_reg, segRy_reg ] = calcRange ( handles, Kmin_reg, Kmax_reg, slot );
    [ segRx_ext, segRy_ext ] = calcRange ( handles, Kmin_ext, Kmax_ext, slot );

    if ( isInstalled ( slot ) )
        fill ( segRx_reg, segRy_reg, 'y', 'Parent', axes_handle ); 
        fill ( segRx_ext, segRy_ext, [ 1, 153/255, 0], 'Parent', axes_handle ); 
    end
    
    if ( isActive ( slot ) )
        if ( getHarm ( slot ) == 2 )
            EquCount = EquCount + 1;
            plot ( segP, segK,  '-m', 'Parent', axes_handle ); 
        else
            plot ( segP, segK,  '-k', 'Parent', axes_handle ); 
        end
        
        avg_segP = ( segP ( 1 ) + segP ( 2 ) ) / 2;
        avg_segK = ( segK ( 1 ) + segK ( 2 ) ) / 2;

        if ( isUnderMaintenance ( slot ) )
            MntCount = MntCount + 1;
            useColor = [ 0.7, 0.7, 0.7 ];
        elseif ( getHarm ( slot ) == 2 )
            useColor = [ 1.0, 0.0, 1.0 ];
%            useColor = 'm';
        else
            useColor = [ 0.0, 0.0, 0.0 ];
        end
        
        text ( avg_segP, avg_segK, sprintf ( '%2.2d', slot ), ...
            'FontSize', 6, ...
            'FontWeight', 'bold', ...
            'Color', useColor, ...
            'HorizontalAlignment', 'Center', ...
            'VerticalAlignment', 'Bottom', ...
            'Parent', axes_handle );
        
        segT ( 1 ) = handles.EnergyLoss { slot }.Kt_ini;
        segT ( 2 ) = handles.EnergyLoss { slot }.Kt_end;
        
        plot ( segP, segT, '-r', 'LineWidth', 3, 'Parent', axes_handle );
    end
end

if ( MntCount )
    if ( EquCount )
        set ( handles.MSG_LINE_1, 'String', 'Gray Slot Number: In Maintenance' );
        set ( handles.MSG_LINE_2, 'String', 'Will not be moved' );
        set ( handles.MSG_LINE_3, 'String', 'Magenta Slot Number: Equivalent K' );
    else
        set ( handles.MSG_LINE_1, 'String', 'Gray Slot Number: In Maintenance' );
        set ( handles.MSG_LINE_2, 'String', 'Will not be moved' );
        set ( handles.MSG_LINE_3, 'String', '' );
    end
else
    if ( EquCount )
        set ( handles.MSG_LINE_1, 'String', 'Magenta Slot Number: Equivalent K' );
        set ( handles.MSG_LINE_2, 'String', '' );
        set ( handles.MSG_LINE_3, 'String', '' );
    else
        set ( handles.MSG_LINE_1, 'String', '' );
        set ( handles.MSG_LINE_2, 'String', '' );
        set ( handles.MSG_LINE_3, 'String', '' );
    end
end

if ( MntCount || EquCount )
    set ( handles.MSG_PANEL, 'Visible', 'On' );
else
    set ( handles.MSG_PANEL, 'Visible', 'Off' );
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


function new_handles = updateDisplay ( handles )

global timerData;
global debug;

if ( debug )
    fprintf ( 'entering "updateDisplay"\n' ); 
end

handles.BunchCharge        = getBunchCharge ( handles );
handles.BeamEnergy         = getBeamEnergy ( handles );
handles.PeakCurrent        = getPeakCurrent ( handles );
handles                    = calculateEnergyLoss ( handles );
handles                    = calculateTaperRequirement ( handles );
handles.ActualBunchCharge  = getActualBunchCharge ( handles ) * 1000;
handles.ActualBeamEnergy   = getActualBeamEnergy;
handles.ActualPeakCurrent  = getActualPeakCurrent;
handles                    = estimateOptimumGainTaper ( handles );

set ( handles.USE_ACTUAL_ENERGY_RADIO_BTN,       'String', sprintf ( 'Use Actual Energy (%6.3f GeV)',      handles.ActualBeamEnergy ) );
set ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'String', sprintf ( 'Use Actual Bunch Charge (%4.1f pC)', handles.ActualBunchCharge ) );
set ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'String', sprintf ( 'Use Actual Peak Current (%5.1f A)',  handles.ActualPeakCurrent ) );

set ( handles.SUGGESTED_GAIN_TAPER,              'String', sprintf ( '(%+3.0f)',  handles.OptimumGainTaper ) );
set ( handles.ESTIMATED_SATURATION_POINT,        'String', sprintf ( '(%3.0f)',  ...
                                                       floor ( handles.FELp.L_sat_c / 132.9 * 33 )  ) );
                                                   

set ( handles.REFERENCE_DATE,                    'String', handles.referenceDate );
set ( handles.INITIAL_DATE,                      'String', handles.initialDate   );

handles.presentTaperParms = loadTaperParmsFromSOFTPVs ( handles.presentTaperParms );
set ( handles.AUTOMOVE_SOFT_PV_VAL,              'String', sprintf ( '(%d)',  handles.presentTaperParms{handles.ID_AUTOMOVE}.VAL) );

if ( handles.fstSegment )
    E        = handles.BeamEnergy * 10^9 - ...
               handles.EnergyLoss { handles.fstSegment }.Spont_dE_ini - ...
               handles.EnergyLoss { handles.fstSegment }.Wake_dE_ini - ...
               handles.LTU_Wake_Loss * 10^6;
    gamma    = E / handles.PhyConsts.mc2_e;
    lambda_r = handles.UndConsts.lambda_u / ( 2 * gamma^2 ) * ( 1 + UndKact ( handles.fstSegment )^2 / 2 );
    Ephoton  = handles.PhyConsts.h_bar * 2 * pi * handles.PhyConsts.c / lambda_r / handles.PhyConsts.echarge;
    
%    handles.fstSegment   = findFirstSegment ( handles.Segments );

    fstK = getEquivalentKvalue ( handles.fstSegment );
%    fstK = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', handles.fstSegment ) );

    if ( handles.moving_fstK )
        if ( abs ( fstK - get ( handles.FST_K, 'Value' ) ) < 1e-4 )
            handles.movign_fstK = false;
        end
    else
        fstK = getEquivalentKvalue ( handles.fstSegment );
%        fstK = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', handles.fstSegment ) );
        
        if ( abs ( fstK - get ( handles.FST_K, 'Value' ) ) > 1e-4 )
            set ( handles.FST_K, 'String', sprintf ( '%6.4f', fstK ) );
            set ( handles.FST_K, 'Value',  fstK );    
        end
    end
    
%    handles.xray_profmon = 'YAGS:DMP1:500';
    
    if ( handles.YAGXRAYavailable )
        if (isnan ( lcaGet ( 'YAGS:DMP1:500:FOIL1_PNEU', 0, 'double' ) ) )
            handles.YAGXRAYavailable =false;
            
            fprintf ( 'YAGXRAY is not available. Continuing without ...\n' );
        end
    end

    
    if ( handles.YAGXRAYavailable )
        YAGXRAYinserted = ( lcaGet ( 'YAGS:DMP1:500:FOIL1_PNEU', 0, 'double' ) ~= 1 );
    else
        YAGXRAYinserted = false;
    end
    
    if ( handles.ActualBunchCharge > 15 ) % 1500 pC means: deactivated. Don't use as long as FEE is not yet ready.
%        opts.nBG             = 0;
%        opts.bufd            = 0;
%        opts.doPlot          = 0;
%        handles.num_shots    = 1;
%        dataList             = profmon_measure ( handles.xray_profmon,handles.num_shots,opts );
%        YAGXRAY              =  max ( max ( dataList.img ) );

        if ( YAGXRAYinserted )
            YAGXRAY = lcaGetSmart ( 'SIOC:SYS0:ML00:AO594' );
            
            set ( handles.YAGXRAY_AMPLITUDE, 'String', sprintf ( 'YAGXRAY Amplitude = %5.1f AU',      YAGXRAY ) );    
            set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'On' );    
            set ( handles.GASDET1_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.GASDET2_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );    
        else
            set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.GASDET1_AMPLITUDE, 'Visible', 'On' );    
            set ( handles.GASDET2_AMPLITUDE, 'Visible', 'On' );    
            set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );
%%            GASDET1              = ( lcaGetSmart ( 'GDET:FEE1:11:ENRC' ) + lcaGetSmart ( 'GDET:FEE1:11:ENRC' ) ) / 2;
            GASDET1 = NaN;
%            SLDTRANSMISSION      = 0.8;%lcaGetSmart ( 'SATT:FEE1:320:RACT' );
%            GASTRANSMISSION      = lcaGetSmart ( 'GATT:FEE1:310:R_ACT' );
%%            GASDET2              = ( lcaGetSmart ( 'GDET:FEE1:21:ENRC' ) + lcaGetSmart ( 'GDET:FEE1:22:ENRC' ) ) / 2;        
            GASDET2 = NaN;
%           GASDET2              = GASDET2 / SLDTRANSMISSION / GASTRANSMISSION;
            XENERGY              = NaN;
%            XENERGY              = ( lcaGetSmart ( 'ELEC:FEE1:452:DATA' ) + lcaGetSmart ( 'ELEC:FEE1:453:DATA' ) ) * 500 ;
            DIMAGER              = NaN;
%            DIMAGER              = lcaGetSmart ( 'DIAG:FEE1:481:RawMax' );
            set ( handles.GASDET1_AMPLITUDE, 'String', sprintf ( 'Gas Detector 1 = %5.3f mJ',         GASDET1 ) );    
            set ( handles.GASDET2_AMPLITUDE, 'String', sprintf ( 'Gas Detector 2 = %5.3f mJ',         GASDET2 ) );    
            set ( handles.XENERGY_AMPLITUDE, 'String', sprintf ( 'Calorimeter = %5.3f mJ',            XENERGY ) );    
            set ( handles.DIMAGER_AMPLITUDE, 'String', sprintf ( 'Direct Imager = %5.3f AU',          DIMAGER ) );    
        end
    else
        set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.GASDET1_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.GASDET2_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );
    end

    set ( handles.FUNDAMENTAL_WAVELENGTH,            'String', sprintf ( 'Fundamental Wavelength = %6.4f nm', lambda_r * 1e9 ) );
    set ( handles.PHOTON_ENERGY,                     'String', sprintf ( 'Photon Energy = %5.1f eV',          Ephoton ) );    
else
    set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.GASDET1_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.GASDET2_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );
end

if ( get ( handles.AUTO_MOVE_CHECKBOX, 'Value' )  )
    changeKvalues ( handles );
    set ( handles.APPLY, 'Visible', 'Off' );
else
    set ( handles.APPLY, 'Visible', 'On' );
end

plotK ( handles.TAPERDISPLAY, handles );
hold  ( handles.TAPERDISPLAY, 'off' );

timerData.handles = handles;

new_handles       = handles;

drawnow;

if ( debug )
    fprintf ( 'leaving "updateDisplay"\n' ); 
end

end


function answer = useSpontaneous ( handles )

answer = get ( handles.USE_SPONT_RAD_BOX, 'Value' );

end


function answer = useWakefields ( handles )

answer = get ( handles.USE_WAKEFIELDS_BOX, 'Value' );

end


function answer = addGainTaper ( handles )

answer = get ( handles.ADD_GAIN_TAPER_BOX, 'Value' );

end


function answer = addPostSaturationTaper ( handles )

answer = get ( handles.ADD_POST_SATURATION_TAPER_BOX, 'Value' );

end


% --- Executes on button press in USE_SPONT_RAD_BOX.
function USE_SPONT_RAD_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_SPONT_RAD_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_SPONT_RAD_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_USE_SPONT_RAD_BOX );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in USE_WAKEFIELDS_BOX.
function USE_WAKEFIELDS_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_WAKEFIELDS_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_WAKEFIELDS_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_USE_WAKEFIELDS_BOX );
timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in ADD_GAIN_TAPER_BOX.
function ADD_GAIN_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_GAIN_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_GAIN_TAPER_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_ADD_GAIN_TAPER_BOX );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in ADD_POST_SATURATION_TAPER_BOX.
function ADD_POST_SATURATION_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_POST_SATURATION_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_POST_SATURATION_TAPER_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_ADD_POST_SATURATION_TAPER_BOX );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in USE_ACTUAL_ENERGY_RADIO_BTN.
function USE_ACTUAL_ENERGY_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_ENERGY_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_ENERGY_RADIO_BTN

global timerData;

manageBeamEnergyRadioButtons ( handles, 1 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_ENERGY );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in SET_ENERGY_RADIO_BTN.
function SET_ENERGY_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_ENERGY_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_ENERGY_RADIO_BTN

global timerData;

manageBeamEnergyRadioButtons ( handles, 2 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_ENERGY );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


function MODEL_BEAM_ENERGY_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_BEAM_ENERGY as text
%        str2double(get(hObject,'String')) returns contents of MODEL_BEAM_ENERGY as a double

global timerData;

%handles = updateDisplay ( handles );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function MODEL_BEAM_ENERGY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ( ispc && isequal ( get ( hObject, 'BackgroundColor' ), get ( 0, 'defaultUicontrolBackgroundColor' ) ) )
    set ( hObject, 'BackgroundColor','white' );
end

end


function manageBeamEnergyRadioButtons ( handles, b )

if ( exist ( 'b', 'var' ) )
    if ( b > 0 && b < 3 )
        btn = b;
    else
        btn = 0;
    end
else
    btn = 0;
end

if ( ~btn )
    b1 = get ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value' );
    b2 = get ( handles.SET_ENERGY_RADIO_BTN,        'Value' );

    if ( b1 )
        if ( ~b2 )
            btn = 1;
        end
    else
        if ( b2 )
            btn = 2;
        end
    end
end

if ( btn == 1 )
    set ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value', 1 );
    set ( handles.SET_ENERGY_RADIO_BTN,        'Value', 0 );
else
    set ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value', 0 );
    set ( handles.SET_ENERGY_RADIO_BTN,        'Value', 1 );
end

end


function actualBeamEnergy = getActualBeamEnergy

E1                = lcaGet ( 'BEND:DMP1:400:BDES' );            % GeV
E2                = lcaGet ( 'SIOC:SYS0:ML00:AO289') / 1000;    % GeV  -> Vernier
actualBunchCharge = lcaGet ( 'BPMS:UND1:190:TMIT' ) * 1.6e-19 * 1e9;  % [nC]'

if ( actualBunchCharge > 10 )
    E3 = lcaGet ( 'BPMS:LTU1:250:XBR' ) / 1000;    % GeV
else
    E3 = 0;
end

actualBeamEnergy = E1 + E2 + E3;    % GeV

end


function BeamEnergy = getBeamEnergy ( handles )

if ( get ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value' ) )
    BeamEnergy  = getActualBeamEnergy;    % GeV
else
    BeamEnergy  = str2double ( get ( handles.MODEL_BEAM_ENERGY, 'String' ) );
end

set ( handles.BEAM_ENERGY, 'String', sprintf ( 'Beam Energy = %6.3f GeV', BeamEnergy ) );

end


% --- Executes on button press in USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN.
function USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN

global timerData;

manageBunchChargeRadioButtons ( handles, 1 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_BUNCH_CHARGE );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in SET_BUNCH_CHARGE_RADIO_BTN.
function SET_BUNCH_CHARGE_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_BUNCH_CHARGE_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_BUNCH_CHARGE_RADIO_BTN

global timerData;

manageBunchChargeRadioButtons ( handles, 2 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_BUNCH_CHARGE );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


function MODEL_BUNCH_CHARGE_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_BUNCH_CHARGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_BUNCH_CHARGE as text
%        str2double(get(hObject,'String')) returns contents of MODEL_BUNCH_CHARGE as a double

%global timerData;

%handles = updateDisplay ( handles );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function MODEL_BUNCH_CHARGE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BUNCH_CHARGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function manageBunchChargeRadioButtons ( handles, b )

if ( exist ( 'b', 'var' ) )
    if ( b > 0 && b < 3 )
        btn = b;
    else
        btn = 0;
    end
else
    btn = 0;
end

if ( ~btn )
    b1 = get ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value' );
    b2 = get ( handles.SET_BUNCH_CHARGE_RADIO_BTN,        'Value' );

    if ( b1 )
        if ( ~b2 )
            btn = 1;
        end
    else
        if ( b2 )
            btn = 2;
        end
    end
end

if ( btn == 1 )
    set ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value', 1 );
    set ( handles.SET_BUNCH_CHARGE_RADIO_BTN,        'Value', 0 );
else
    set ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value', 0 );
    set ( handles.SET_BUNCH_CHARGE_RADIO_BTN,        'Value', 1 );
end

end


function actualBunchCharge = getActualBunchCharge ( handles )

try
    actualBunchCharge  = lcaGet ( 'BPMS:UND1:190:TMIT' ) * handles.PhyConsts.echarge * 1e9;  % [nC]'
catch
    actualBunchCharge = 0;
end

end


function BunchCharge = getBunchCharge ( handles )

if ( get ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value' ) )
    BunchCharge  = getActualBunchCharge ( handles ) * 1000;  % [pC]'
else
    BunchCharge  = str2double ( get ( handles.MODEL_BUNCH_CHARGE, 'String' ) ); % [pC]
end

end


% --- Executes on button press in USE_ACTUAL_PEAK_CURRENT_RADIO_BTN.
function USE_ACTUAL_PEAK_CURRENT_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_PEAK_CURRENT_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_PEAK_CURRENT_RADIO_BTN

global timerData;

managePeakCurrentRadioButtons ( handles, 1 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_PEAK_CURRENT );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in SET_PEAK_CURRENT_RADIO_BTN.
function SET_PEAK_CURRENT_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_PEAK_CURRENT_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_PEAK_CURRENT_RADIO_BTN

%global timerData;

managePeakCurrentRadioButtons ( handles, 2 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_PEAK_CURRENT );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


function MODEL_PEAK_CURRENT_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_PEAK_CURRENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_PEAK_CURRENT as text
%        str2double(get(hObject,'String')) returns contents of MODEL_PEAK_CURRENT as a double

%global timerData;

%handles = updateDisplay ( handles );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function MODEL_PEAK_CURRENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_PEAK_CURRENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function managePeakCurrentRadioButtons ( handles, b )

if ( exist ( 'b', 'var' ) )
    if ( b > 0 && b < 3 )
        btn = b;
    else
        btn = 0;
    end
else
    btn = 0;
end

if ( ~btn )
    b1 = get ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value' );
    b2 = get ( handles.SET_PEAK_CURRENT_RADIO_BTN,        'Value' );

    if ( b1 )
        if ( ~b2 )
            btn = 1;
        end
    else
        if ( b2 )
            btn = 2;
        end
    end
end

if ( btn == 1 )
    set ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value', 1 );
    set ( handles.SET_PEAK_CURRENT_RADIO_BTN,        'Value', 0 );
else
    set ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value', 0 );
    set ( handles.SET_PEAK_CURRENT_RADIO_BTN,        'Value', 1 );
end

end


function v = getActualPeakCurrent
   global OPctrl;

   v    = 0;
   Ipk  = lcaGet ( 'BLEN:LI24:886:BIMAX' );    % A

    if ( isnan ( Ipk )  )
        return
    end
    
    if ( Ipk <= 0 || Ipk > 1e5 )
        return
    end

if ( OPctrl.Ipklvl < OPctrl.bufSize )
    OPctrl.Ipklvl                            = OPctrl.Ipklvl + 1;
else
    OPctrl.IpkBuf ( 1 : OPctrl.bufSize - 1 ) = OPctrl.IpkBuf ( 2 : OPctrl.bufSize );
end

OPctrl.IpkBuf ( OPctrl.Ipklvl )   = Ipk;
v                                 = mean ( OPctrl.IpkBuf ( 1 : OPctrl.Ipklvl ) );

end


function PeakCurrent = getPeakCurrent ( handles )

if ( get ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value' ) )
   PeakCurrent  = getActualPeakCurrent;    % A
else
   PeakCurrent  = str2double ( get ( handles.MODEL_PEAK_CURRENT, 'String' ) );
end

if ( isnan ( PeakCurrent )  )
    PeakCurrent = 0;
end

end


function    [ segRx, segRy ] = calcRange ( handles, Kmin, Kmax, slot )

xLF = handles.EnergyLoss { slot }.z_ini;
xRT = handles.EnergyLoss { slot }.z_end;
yUP = Kmax ( slot );
yDN = Kmin ( slot );

segRx = [ xLF xLF xRT xRT xRT ];
segRy = [ yDN yUP yUP yDN yDN ];

end


% --- Executes on button press in APPLY.
function APPLY_Callback(hObject, eventdata, handles)
% hObject    handle to APPLY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

changeKvalues ( handles );

end


function changeKvalues ( handles )

Kvalues = zeros ( 1, handles.Segments );

for slot = 1 : handles.Segments
    if ( isActive ( slot ) )        
        Kvalues ( slot ) = handles.EnergyLoss { slot }.Kt_ini;
    end
end

setKvalues ( handles, Kvalues );

end


function GAIN_TAPER_START_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_START_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_START_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_GAIN_TAPER_START_SEGMENT );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_START_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function GAIN_TAPER_END_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_END_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_GAIN_TAPER_END_SEGMENT );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_END_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function GAIN_TAPER_AMPLITUDE_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_AMPLITUDE as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_GAIN_TAPER_AMPLITUDE );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_AMPLITUDE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_START_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_START_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_START_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_START_SEGMENT );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_START_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_END_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_END_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_END_SEGMENT );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_END_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_AMPLITUDE_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_AMPLITUDE as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_AMPLITUDE );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes on selection change in POST_TAPER_MENU.
function POST_TAPER_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns POST_TAPER_MENU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from POST_TAPER_MENU

manageTaperTypeMenu ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_TYPE );

end


function manageTaperTypeMenu ( handles )

if ( get ( handles.POST_TAPER_MENU, 'Value' ) == handles.PostTaperExpontID )
    set ( handles.POST_TAPER_LG_LABEL, 'Visible', 'On' );
    set ( handles.POST_TAPER_LG,       'Visible', 'On' );
    set ( handles.POST_TAPER_LG_UNIT,  'Visible', 'On' );
else
    set ( handles.POST_TAPER_LG_LABEL, 'Visible', 'Off' );
    set ( handles.POST_TAPER_LG,       'Visible', 'Off' );
    set ( handles.POST_TAPER_LG_UNIT,  'Visible', 'Off' );
end

end

% --- Executes during object creation, after setting all properties.
function POST_TAPER_MENU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_AMPLITUDE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_LG_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_LG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_LG as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_LG as a double

LG = str2double ( get ( handles.POST_TAPER_LG, 'String' ) );

if ( isnan ( LG ) || LG < 4 )
    LG = 4;
end

set ( handles.POST_TAPER_LG, 'String', sprintf ( '%.2f', LG ) );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_LG );

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_LG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_LG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function activeStatus = isActive ( slot )

if ( UndKact ( slot ) > 0 )
    activeStatus = true;
else
    activeStatus = false;
end

end


function  undulatorHarmonics =  getHarm ( slot )

undulatorHarmonics = lcaGet ( sprintf ( 'USEG:UND1:%d50:TYPE', slot ), 0, 'double' );

%x if ( slot == 33 )
%x     undulatorHarmonics = 2;
%x end

end


function  installedStatus =  isInstalled ( slot )

installedStatus = lcaGet ( sprintf ( 'USEG:UND1:%d50:INSTALTNSTAT', slot ), 0, 'double' );

end


function  underMaintenance =  isUnderMaintenance ( slot )

underMaintenance = lcaGet ( sprintf ( 'USEG:UND1:%d50:MAINTENANCEM', slot ), 0, 'double' );

end


function  xinmax =  getXINMAX ( slot )

n      = length ( slot );
xinmax = zeros ( 1, n );

for j = 1 : n
    xinmax ( j ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:XINMAX', j ), 0, 'double' );
end

end


function K = UndKact ( slots, xpos )

global hh;
  
K = 0;

n = length ( slots );

if  ( ~n )
    return;
end

K = zeros ( 1, n );

if ( exist ( 'xpos', 'var' ) )
    xisgiven = true;
    m        = length ( xpos );
    
    if ( n ~= m )
        error ( 'Length mismatch between slots (%d) and xpos (%d).', n, m );
    end
else
    xisgiven = false;
end

for k = 1 : n
    slot = slots ( k );
    
    if ( slot < 1 || slot > 33 )
        continue;
    end

    if ( isInstalled ( slot ) && ~isUnderMaintenance ( slot ) )
        SliderPV = sprintf ( 'USEG:UND1:%d50:TM2MOTOR.RBV', slot ); 
%        SliderPV = sprintf ( 'USEG:UND1:%d50:TMXPOSC', slot );
%        KactPV   = sprintf ( 'USEG:UND1:%d50:KACT',    slot );
  
        if ( xisgiven )
            x = xpos ( k );
        else
            try
                x = lcaGet ( SliderPV );
            catch
                x = 0;
            end
        end

        if ( x > -6 && x < 30 )
            Xoffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:XOFF', slot ) );

            K ( k ) = evalPoly ( -x - Xoffset, slot, hh.Kcoeffs );
           
         else
            K ( k ) = 0;
        end
    else
        K ( k ) =  0;
        x       = 84;
    end

    if ( slot == 35 ) 
        xisgiven
        x
        slot
        K ( k )
        Koffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:KOFFSET', slot ) );
        Xoffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:XOFF',    slot ) );
        
        xcheck = - evalPoly ( K ( k ) - Koffset, slot, hh.Xcoeffs ) - Xoffset;
        Kcheck = evalPoly ( -x - Xoffset, slot, hh.Kcoeffs );

        fprintf ( 'Koeffs ( %2.2d ) = %g', slot, hh.Kcoeffs { slot, 1 } );
        for poly = 2 : 6
            fprintf ( ', %g', hh.Kcoeffs { slot, poly } );
        end
        
        fprintf ( '\n' );
         
        fprintf ( 'Xoeffs ( %2.2d ) = %g', slot, hh.Xcoeffs { slot, 1 } );

        for poly = 2 : 6
            fprintf ( ', %g', hh.Xcoeffs { slot, poly } );
        end
         
        fprintf ( '\n' );
         
    end
end

for k = 1 : n
    if ( K ( k ) > 0 )
        K ( k ) = K2equK ( K ( k ), getHarm ( k ) );
    end
end

end


function y = evalPoly ( x, slot, coeffs )

[ nsl, ncf ] = size ( coeffs ) ;

y = coeffs { slot, 1 };

for j = 2 : ncf
    y = y + coeffs { slot, j } * ( x )^( j - 1 );
end

end


function new_handles = getKcoeffs ( handles )

ncoeffs =  6;
slots   = 33;

handles.KcoeffPVs  = cell ( slots, ncoeffs );
handles.Kcoeffs    = cell ( slots, ncoeffs );
handles.XcoeffPVs  = cell ( slots, ncoeffs );
handles.Xcoeffs    = cell ( slots, ncoeffs );
%handles.InstallPVs = cell ( slots );
handles.Installed  = zeros ( 1, slots );

for slot = 1 : slots
%    handles.InstallPVs { slot } = sprintf ( 'USEG:UND1:%d50:INSTALTNSTAT', slot );    
%    handles.Installed  ( slot ) = lcaGet  ( handles.InstallPVs { slot }, 0, 'double' );
    handles.Installed  ( slot ) = isInstalled ( slot );
    
    for p = 1 : ncoeffs;
        handles.KcoeffPVs  { slot, p } = sprintf ( 'USEG:UND1:%d50:POLYKACT.%c', slot, char ( p + 64 ) );
        handles.Kcoeffs   { slot, p }  = lcaGet ( handles.KcoeffPVs { slot, p } );

        handles.XcoeffPVs  { slot, p } = sprintf ( 'USEG:UND1:%d50:POLYXDES.%c', slot, char ( p + 64 ) );
        handles.Xcoeffs   { slot, p }  = lcaGet ( handles.XcoeffPVs { slot, p } );

%        fprintf ( '%s = %f\n', handles.KcoeffPVs { slot , p }, handles.Kcoeffs { slot , p }  );
    end
end
    

new_handles = handles;

end


function Kvalues = loadPresentKvalues ( handles )

Kvalues = zeros ( 1, handles.Segments );

for slot = 1 : handles.Segments
    if ( isActive ( slot ) )
        Kvalues ( slot ) = getEquivalentKvalue ( slot );
    end
end

end


function equKvalue = getEquivalentKvalue ( slot )

equKvalue = 0;

if ( isActive ( slot ) )
    actKvalue = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
    
%x    if ( slot == 33 )
%x        actKvalue = equK2K ( actKvalue, getHarm ( slot ) );
%x    end
    
    equKsquare = getHarm ( slot ) * ( actKvalue^2 + 2 ) - 2;
    
    if ( equKsquare > 0 )
        equKvalue = sqrt ( equKsquare );
    else
%fprintf ( 'slot %2.2d => actK : %6.4f (h=%d), equKsquare = %f.\n', slot, actKvalue, getHarm ( slot ), equKsquare );
        equKvalue = 0;
    end
else
    return
end

end


function K = equK2K ( equK, harm )

K = sqrt ( ( equK^2 + 2 ) / harm - 2 );

end


function equK = K2equK ( K, harm )

equKsquare = harm * ( K^2 + 2 ) - 2;
    
if ( equKsquare > 0 )
    equK = sqrt ( equKsquare );
else
    equK = 0;
end

end


function setKvalues ( handles, Kvalues )

start = 0;

for slot = 1 : handles.Segments
    if ( isActive ( slot ) && Kvalues ( slot ) > 0 )        
        if ( ~start )
            start = Kvalues ( slot );
        end
        
        if ( start )
            relK = ( Kvalues ( slot ) - start ) / start * 10000;
        else
            relK = 0;
        end
%bbbbfunction K = equK2K ( equK, harm )

        Kact = equK2K ( getEquivalentKvalue ( slot ), getHarm ( slot ) );

%        Kact = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );

        [ x, usedKvalue, changed ] = setKofSlot ( handles, Kvalues ( slot ), slot );
        
        if ( changed )
            fprintf ( '%2.2d: newK = %6.4f [was %+6.4f] (%5.1f 10^-4); x = %+6.3f mm [was %+6.3f mm].\n', ...
                slot, usedKvalue, ...
                Kact, ...
                relK, ...
                x, ...
                lcaGet ( sprintf ( 'USEG:UND1:%d50:TMXPOSC', slot ) ) ...
                );
        end
    end
end

end


function [ x, usedKvalue, changed ] = setKofSlot ( handles, equK, slot )

changed           = false;
xThr              = 12; % mm
Kact              = getEquivalentKvalue ( slot );

Kvalue            = equK2K ( equK, getHarm ( slot ) );
%Kact              = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
[ x, usedKvalue ] = get_inLimit_K ( handles, Kvalue, slot );

if ( isUnderMaintenance ( slot ) || ~isInstalled ( slot ) )
    return;
end

if ( abs ( Kact - Kvalue ) > 5e-4 )
    changed = true;

    if ( x <  xThr )
%fprintf ( 'Setting slot %2.2d to %f.\n', slot, usedKvalue );        
%        lcaPut ( sprintf ( 'USEG:UND1:%d50:KDES',      slot ), equK2K ( usedKvalue, 1 ) );
%??        lcaPut ( sprintf ( 'USEG:UND1:%d50:KDES',      slot ), usedKvalue );
%??        lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:TRIM.PROC', slot ), 1    );
        lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:TMXPOSC',   slot ), x );
        fprintf ( 'Setting slot %2.2d to x = %f; K = %f.\n', slot, x, usedKvalue );        
    else
        lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:TMXPOSC',   slot ), x );
    end
   
    lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:KDES', slot ), usedKvalue );
end

end


function [ x, K ] = get_inLimit_K ( handles, setK, slot )

xmin =  -5; % mm
xmax = +16; % mm

Koffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:KOFFSET', slot ) );
Xoffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:XOFF',    slot ) );

x = min ( max ( - evalPoly ( setK - Koffset, slot, handles.Xcoeffs ) - Xoffset, xmin ), xmax );
K = evalPoly ( -x - Xoffset, slot, handles.Kcoeffs );

if ( abs ( K - setK ) < 5e-5 )
    K = setK;
end

end


function slide_adjust = getSlideAdjusts % temporary with slide adustments as suggested by MET.

slide_adjust = cell ( 33 );

slide_adjust { 13 } =   41;
slide_adjust { 14 } =   48;
slide_adjust { 15 } =  -17;
slide_adjust { 16 } =  146;
slide_adjust { 17 } =  -17;
slide_adjust { 18 } =  -45;
slide_adjust { 19 } =    8;
slide_adjust { 20 } =   28;
slide_adjust { 21 } =   -4;
slide_adjust { 22 } =  226;
slide_adjust { 23 } =  -54;
slide_adjust { 24 } =  -36;
slide_adjust { 25 } =   56;
slide_adjust { 26 } =  -18;
slide_adjust { 27 } =  136;
slide_adjust { 28 } =  197;
slide_adjust { 29 } =   27;
slide_adjust { 30 } =    9;
slide_adjust { 31 } =   37;
slide_adjust { 32 } =   64;
slide_adjust { 33 } =   91;

end


% --- Executes on button press in MAKE_TAPER_OFFICIAL.
function MAKE_TAPER_OFFICIAL_Callback(hObject, eventdata, handles)
% hObject    handle to MAKE_TAPER_OFFICIAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( isfield ( handles, 'fstSegment' ) )
    for slot = handles.fstSegment : 33
        if ( isActive ( slot ) )
            lcaPut ( sprintf ( 'USEG:UND1:%d50:UPDATEXIN.PROC', slot ), 1 )
        end
    end
end

end


function  status = isUndercompressed ( handles )

compressionString = get ( handles.COMPRESSION_STATUS, 'String' );

if ( strfind ( upper ( compressionString ), 'UNDER' ) )
    status = true;
else
    status = false;
end

end


% --- Executes on button press in CHANGE_COMPRESSION_STATUS_BTN.
function CHANGE_COMPRESSION_STATUS_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to CHANGE_COMPRESSION_STATUS_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( isUndercompressed ( handles ) )
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Overcompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Undercompression' );
else
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Undercompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Overcompression' );
end

setSOFTPV ( handles.presentTaperParms, handles.ID_COMPRESSION_STATUS );

end


% --- Executes on button press in PRINTLOGBOOK.
function PRINTLOGBOOK_Callback(hObject, eventdata, handles)
% hObject    handle to PRINTLOGBOOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

if ( handles.printTo_Files || handles.printTo_e_Log )
    plotK ( handles.log_axes, handles );

    title ( 'LCLS Undulator Taper Configuration', 'Parent', handles.log_axes  );
    
    textPos = estimatePosition ( 20, 16,  axis ( handles.log_axes ) );
    textStr = sprintf ( 'Energy: %6.3f GeV', getBeamEnergy ( handles ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    textPos = estimatePosition ( 20, 12,  axis ( handles.log_axes ) );
    textStr = sprintf ( 'Bunch Charge: %4.1f pC', getBunchCharge ( handles ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    textPos = estimatePosition ( 20,  8,  axis ( handles.log_axes ) );
    textStr = sprintf ( 'PeakCurrent: %7.1f A', getPeakCurrent ( handles ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    if ( useSpontaneous ( handles ) ) 
        textStr = sprintf ( 'SpontRad' );
    else
        textStr = sprintf ( 'No SpontRad' );
    end

    textPos = estimatePosition (  1,  16,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    if ( useWakefields ( handles ) )
        textStr = sprintf ( 'WakeFields' );
    else
        textStr = sprintf ( 'No WakeFields' );
    end

    textPos = estimatePosition (  1,  12,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    if ( addGainTaper ( handles ) )
        textStr = sprintf ( 'GainTaper' );
    else
        textStr = sprintf ( 'No GainTaper' );
    end

    textPos = estimatePosition (  1,   8,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );

    if ( addPostSaturationTaper ( handles ) )
        textStr = sprintf ( 'PostSatTaper' );
    else
        textStr = sprintf ( 'No PostSatTaper' );
    end

    textPos = estimatePosition ( 1 ,  4,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );

    hold ( handles.log_axes, 'off' );
end

%fig = handles.log_fig;

% if ( fig )
    if ( handles.printTo_e_Log )
        print ( handles.log_fig, '-dpsc2', '-Pphysics-lclslog', '-adobecset' );
    end
    
    if ( handles.printTo_Files )
        figName = 'LCLS_TaperConfiguration';
        print ( handles.log_fig, '-dpdf',  '-r300', figName ); 
        print ( handles.log_fig, '-djpeg', '-r300', figName ); 
    end
    
    if ( handles.printTo_e_Log || handles.printTo_Files )
 %       delete ( handles.log_fig );
    end
% end
    
handles = saveData ( handles );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

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

fprintf ( 'Closing  UndulatorTaperControl_gui.\n' );

util_appClose ( hObject );
%lcaClear ( );
lcaClear;

end


function FST_K_Callback(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FST_K as text
%        str2double(get(hObject,'String')) returns contents of FST_K as a double

global timerData;

got_newK = false;
old_fstK = get ( handles.FST_K, 'Value' );
fstK     = str2double ( get ( handles.FST_K, 'String' ) );

if ( isnan ( fstK ) )
    fstK        = old_fstK;
elseif ( isfield ( handles, 'fstSegment' ) )
    [ x, corrected_K ] = get_inLimit_K ( handles, fstK, handles.fstSegment );

    if ( abs ( corrected_K - fstK ) > 5e-4 )
        fstK= old_fstK;
    else
        got_newK = true;
    end
end

if ( got_newK )
    set ( handles.FST_K, 'String', sprintf ( '%6.4f', fstK ) );
    set ( handles.FST_K, 'Value',  fstK );

    setKofSlot ( handles, fstK, handles.fstSegment );
    handles.moving_fstK = true;
end

timerData.handles = handles;

% Update handles structure
guidata ( hObject, handles );

end


% --- Executes during object creation, after setting all properties.
function FST_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set ( hObject,'BackgroundColor','white' );
end

end


% --- Executes on button press in AUTO_MOVE_CHECKBOX.
function AUTO_MOVE_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to AUTO_MOVE_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AUTO_MOVE_CHECKBOX
hobj_state=get ( handles.AUTO_MOVE_CHECKBOX, 'Value' );
if ( hobj_state )
%     set ( handles.APPLY, 'Visible', 'Off' );
    lcaPut([handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'], 0);
    pause (2);                                                             % pause to allow all instances to update
    lcaPut([handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'], 1);
    set ( handles.AUTO_MOVE_CHECKBOX, 'Value', 1 );
else
%     set ( handles.APPLY, 'Visible', 'On' );
    lcaPut([handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'], 0);
end
end
