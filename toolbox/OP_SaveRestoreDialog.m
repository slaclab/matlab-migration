function varargout = OP_SaveRestoreDialog ( varargin )
% OP_SAVERESTORE_DIALOG M-file for OP_SAVERESTORE_DIALOG.fig
%      OP_SAVERESTORE_DIALOG, by itself, creates a new OP_SAVERESTORE_DIALOG or raises the existing
%      singleton*.
%
%      H = OP_SAVERESTORE_DIALOG returns the handle to a new OP_SAVERESTORE_DIALOG or the handle to
%      the existing singleton*.
%
%      OP_SAVERESTORE_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OP_SAVERESTORE_DIALOG.M with the given input arguments.
%
%      OP_SAVERESTORE_DIALOG('Property','Value',...) creates a new OP_SAVERESTORE_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OP_SAVERESTORE_DIALOG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OP_SAVERESTORE_DIALOG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OP_SAVERESTORE_DIALOG

% Last Modified by Heinz-Dieter Nuhn 17-November-2008

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', [], ...
                   'gui_OutputFcn',  [], ...
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


function handles = CreateDialog ( parentHandles )
% save_restore_UIcontrol generates a control window to allow
%           the user to save and/or restore configurations.

global OPctrl;
global SaveRestoreWindowExists;

scrsz          = get ( 0, 'ScreenSize' );
figWidth       = 900;
figHeight      = 400;
figX           = ( scrsz ( 3 ) - figWidth  ) / 6;
figY           = ( scrsz ( 4 ) - figHeight ) / 6;

newObj = figure ( 'Position', [ figX figY figWidth figHeight ], 'NumberTitle', 'Off', 'Name', 'Save/Restore OP fields'  );

SaveRestoreWindowExists = true;

btnHeight = 30;

set ( newObj, 'Menubar',     'None' );
set ( newObj, 'color',       [ 0.8 0.8 0.8 ] );
set ( newObj, 'Tag',         'SAVE_RESTORE' );

handles.parentHandles             = parentHandles;
handles.( get ( newObj, 'Tag' ) ) = newObj;       
CallbackFMT                       = sprintf ( '%s(''%%s_Callback'',gcbo,[],guidata(gcbo))', mfilename );

handles.TITLE_TEXT    = uicontrol ( newObj, ...
                                    'Style', 'text', ...
                                    'Units', 'Pixels',  ...
                                    'String', 'Operating Point Save/Restore Menu', ... 
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 18, ... 
                                    'FontWeight', 'bold', ... 
                                    'FontAngle',  'oblique', ... 
                                    'ForegroundColor', [ 0.25 0 0.5 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( newObj, 'Position' ), 1, 100, 425, 32 ), ...
                                    'Tag',      'TILE_TEXT');
                                
handles.CLOSE_WINDOW_BUTTON = uicontrol ( newObj, ...
                                    'Style', 'pushbutton', ... 
                                    'Position', calcPosition ( get ( newObj, 'Position' ), 55, 100, 70, 30 ), ...
                                    'String'  , 'Close', ...
                                    'Callback', sprintf ( CallbackFMT, 'CLOSE_WINDOW_BUTTON' ), ...
                                    'Tag',      'CLOSE_WINDOW_BUTTON');
                                                               
handles.FOLDER_TEXT   = uicontrol ( newObj, ...
                                    'Style', 'text', ...
                                    'Units', 'Pixels',  ...
                                    'String', sprintf ( 'File Location: %s', handles.parentHandles.SaveRestoreFolder ), ... 
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 10, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( newObj, 'Position' ), 2, 92, 500, 25 ), ...
                                    'HorizontalAlignment', 'left', ...
                                    'Tag',      'FOLDER_TEXT');

handles.CONFIG_PANEL = uipanel ( newObj, ...
                                    'Units', 'Pixels',  ...
                                    'Position', calcPosition ( get ( newObj, 'Position' ), 93, 97, 180,  50 ), ...
                                    'BackgroundColor',    [ 0.8 0.8 0.8 ], ...
                                    'Title', 'Current Config', ...
                                    'Tag',   'CONFIG_PANEL');
                                
if ( ~isfield ( OPctrl, 'configNo' ) )
    OPctrl.configNo = 0;
end

if ( OPctrl.configNo > 0 && OPctrl.saved )
    configText = sprintf ( '%04.4d', OPctrl.configNo );
else                                   
    configText = 'not saved';                                
end

handles.CONFIG_TEXT   = uicontrol ( handles.CONFIG_PANEL, ...
                                    'Style', 'text', ...
                                    'Units', 'Pixels',  ...
                                    'String', configText, ... 
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 10, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( handles.CONFIG_PANEL, 'Position' ), 17,  35, 140, 15 ), ...
                                    'HorizontalAlignment', 'center', ...
                                    'Tag',      'CONFIG_TEXT');

handles.SAVE_PANEL = uipanel ( newObj, ...
                                    'Units', 'Pixels',  ...
                                    'Position', calcPosition ( get ( newObj, 'Position' ), 50, 78, 800,  90 ), ...
                                    'HighlightColor',     [ 0.0 0.0 1.0 ], ...
                                    'BackgroundColor',    [ 0.8 0.8 0.8 ], ...
                                    'Title', 'Save Operating Point Target', ...
                                    'Tag',      'SAVE_PANEL');

handles.SAVE_BUTTON = uicontrol ( handles.SAVE_PANEL, ...
                                    'Style', 'pushbutton', ... 
                                    'Position', calcPosition ( get ( handles.SAVE_PANEL, 'Position' ), 50, 50, 200, btnHeight ), ...
                                    'String'  , 'Save Current Target Values', ...
                                    'Callback', sprintf ( CallbackFMT, 'SAVE_BUTTON' ), ...
                                    'ForegroundColor',    [ 1 1 1 ], ...
                                    'BackgroundColor',    [ 51/256 153/256 0.0 ], ...
                                    'Tag',      'SAVE_BUTTON');
                                
handles.RESTORE_PANEL = uipanel ( newObj, ...
                                    'Units', 'Pixels',  ...
                                    'Position', calcPosition ( get ( newObj, 'Position' ), 50, 08, 800, 220 ), ...
                                    'HighlightColor',     [ 0.0 0.0 1.0 ], ...
                                    'BackgroundColor',    [ 0.8 0.8 0.8 ], ...
                                    'Title', 'Restore Operating Point Target from File', ...
                                    'Tag',      'RESTORE_PANEL');

handles.parentHandles.savedTargetInfo.Options = 0;
handles.parentHandles.savedTargetInfo.Folder  = handles.parentHandles.SaveRestoreFolder;
handles.savedTargetInfo                       = getSavedTargetInfo ( handles.parentHandles.savedTargetInfo );

if ( ~handles.savedTargetInfo.Options )
    set ( handles.RESTORE_PANEL, 'Visible', 'Off' );
end

handles.OPTIONS_TEXT   = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'text', ...
                                    'Units', 'Pixels',  ...
                                    'String', sprintf ( 'Number of restorable configs: %d', handles.savedTargetInfo.Options ), ... 
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 10, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 88,  91, 200, 15 ), ...
                                    'HorizontalAlignment', 'right', ...
                                    'Tag',      'OPTIONS_TEXT');

handles.FILE_SELECTOR = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'listbox', ... 
                                    'Units', 'Pixels',  ...
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 50, 60, 750, 120 ), ...
                                    'BackgroundColor',    [ 1 1 1 ], ...
                                    'Callback', sprintf ( CallbackFMT, 'FILE_SELECTOR' ), ...
                                    'Tag',      'FILE_SELECTOR');

set ( handles.FILE_SELECTOR, 'String', setFileSelectorOptions ( handles.savedTargetInfo ) );
set ( handles.FILE_SELECTOR, 'Value',  handles.savedTargetInfo.Options );

handles.RESTORE_BUTTON = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'pushbutton', ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 55,  9, 100, btnHeight ), ...
                                    'String'  , 'Restore', ...
                                    'Callback', sprintf ( CallbackFMT, 'RESTORE_BUTTON' ), ...
                                    'ForegroundColor',    [ 1 1 1 ], ...
                                    'BackgroundColor',    [ 0.0 0.0 208/256 ], ...
                                    'Tag',      'RESTORE_BUTTON');
                                
handles.DELETE_BUTTON = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'pushbutton', ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 96,  9, 100, btnHeight ), ...
                                    'String'  , 'Delete', ...
                                    'Callback', sprintf ( CallbackFMT, 'DELETE_BUTTON' ), ...
                                    'ForegroundColor',    [ 1 1 1 ], ...
                                    'BackgroundColor',    [ 204/256 0.0 0.0 ], ...
                                    'Tag',      'DELETE_BUTTON');
                                
handles.RESTORE_TARGETS_CHECKBOX   = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'checkbox', ...
                                    'Units', 'Pixels',  ...
                                    'String', 'Restore Target Values', ... 
                                    'Value', 1.0, ...
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 9, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 1, 15, 200, 25 ), ...
                                    'HorizontalAlignment', 'left', ...
                                    'Tag',      'RESTORE_TARGETS_CHECKBOX');
                                
handles.RESTORE_TOLS_CHECKBOX   = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'checkbox', ...
                                    'Units', 'Pixels',  ...
                                    'String', 'Restore Tolerances', ... 
                                    'Value', 1.0, ...
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 9, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 1,  5, 200, 25 ), ...
                                    'HorizontalAlignment', 'left', ...
                                    'Tag',      'RESTORE_TOLS_CHECKBOX');
                                
handles.RESTORE_UNITS_CHECKBOX   = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'checkbox', ...
                                    'Units', 'Pixels',  ...
                                    'String', 'Restore Units', ... 
                                    'Value', 0.0, ...
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 9, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 25, 15, 200, 25 ), ...
                                    'HorizontalAlignment', 'left', ...
                                    'Tag',      'RESTORE_UNITS_CHECKBOX');
                                
handles.RESTORE_COMMENTS_CHECKBOX   = uicontrol ( handles.RESTORE_PANEL, ...
                                    'Style', 'checkbox', ...
                                    'Units', 'Pixels',  ...
                                    'String', 'Restore Comments', ... 
                                    'Value', 1.0, ...
                                    'FontName', 'TimesRoman', ... 
                                    'FontSize', 9, ... 
                                    'FontWeight', 'normal', ... 
                                    'ForegroundColor', [ 0 0 0 ], ... 
                                    'BackgroundColor', get ( newObj, 'Color' ), ... 
                                    'Position', calcPosition ( get ( handles.RESTORE_PANEL, 'Position' ), 25,  5, 200, 25 ), ...
                                    'HorizontalAlignment', 'left', ...
                                    'Tag',      'RESTORE_COMMENTS_CHECKBOX');
         
%% % JAVA hack to force the window on top. [APPEARS NOT TO WORK]
%% drawnow;
%% JAVAframe  = get ( newObj, 'javaframe' );
%% JAVAfigure = JAVAframe.fFigureClient.getWindow;
%% JAVAfigure.setAlwaysOnTop ( 1 );

% Force dialog window to stay on top. This will not work if run through X-Windows
if ( false )
    drawnow; %need to make sure that the figures have been rendered or Java error can occur
    JAVAframe = get ( newObj, 'javaframe' );
    awtinvoke ( JAVAframe.fFigureClient.getWindow, 'setAlwaysOnTop', { 'true' } );
    fprintf ( 'Forcing SaveRestore window to top.\n' ); 
end

% Update handles structure
guidata ( newObj, handles );

end


function savedTargetInfo = getSavedTargetInfo ( oldTargetInfo )

%fprintf ( 'getSavedTargetInfo called.\n' );

savedTargetInfo.Options   = 0;
savedTargetInfo.Folder    = oldTargetInfo.Folder;
folder                    = savedTargetInfo.Folder;
                                
savedTargetInfo.nxtConfig = 1;

fileNumber                = 0;
highestConfigNo           = 0;

if ( exist ( folder, 'dir' ) )
    files = dir ( strcat ( folder, 'OP_*.mat' ) );
    
    savedTargetInfo.Options = length ( files );
    
    if ( savedTargetInfo.Options )
        for j = 1 : savedTargetInfo.Options
            % Check if we already have read info about this file.
            
            oldFile = 0;
            
            if ( oldTargetInfo.Options )
                for k = 1 : oldTargetInfo.Options
                    if ( strcmp ( oldTargetInfo.fileNames { k }, files ( j ).name ) )
                        oldFile = k;
                        break;
                    end
                end
            end

            savedTargetInfo.fileNames { j } = files ( j ).name;
            fileNumber                      = fileNumber + 1;
            
            if ( oldFile )
                savedTargetInfo.configNo  { j } = oldTargetInfo.configNo  { oldFile };
                savedTargetInfo.fileDescr { j } = oldTargetInfo.fileDescr { oldFile };
%                fprintf ( 'Used old descriptor for %04.4d "%s"\n', savedTargetInfo.configNo { j }, savedTargetInfo.fileNames { j } );
            else
                path_fn                         = sprintf ( '%s%s', folder, files ( j ).name );
                p                               = load  ( path_fn, 'OPctrl' );
                OPctrl                          = p.OPctrl;
                savedTargetInfo.fileDescr { j } = char ( OPctrl.DescrText );
                
                if ( isfield ( OPctrl, 'configNo' ) )
                    savedTargetInfo.configNo  { j } = OPctrl.configNo;
                else
                    savedTargetInfo.configNo  { j } = fileNumber;
                end
                
%                fprintf ( 'Got descriptor "%s" for %04.4d "%s" \n', savedTargetInfo.fileDescr { j }, savedTargetInfo.configNo { j }, savedTargetInfo.fileNames { j } );
            end            
            
            highestConfigNo = max ( highestConfigNo, savedTargetInfo.configNo  { j } );
        end
        
        savedTargetInfo.ndx = iSort ( savedTargetInfo.configNo, 'ascend' );
    end
end

if ( highestConfigNo )
    savedTargetInfo.nxtConfig = highestConfigNo + 1;    
else
    savedTargetInfo.nxtConfig = fileNumber + 1;    
end

end


function ndx = iSort ( A, mode )

if ( iscellstr ( A ) )
    [ s, ndx ] = sort ( A );
    
    if ( strcmpi ( mode, 'ascend' ) )
        return
    else
        tmp = ndx;
        n   = length ( tmp );
        
        for j = 1 : n
            ndx ( j ) = tmp ( n + 1 - j );
        end
    end
else
    [ s, ndx ] = sort ( cell2mat ( A ), mode );
end

end


function Options = setFileSelectorOptions ( savedTargetInfo )

if ( ~savedTargetInfo.Options )
    Options = '';
    return;
end

ndx = savedTargetInfo.ndx;

Options = sprintf ( '%04.4d    %s    %s', ...
                    savedTargetInfo.configNo  { ndx ( 1 ) }, ...
                    savedTargetInfo.fileNames { ndx ( 1 ) }, ...
                    savedTargetInfo.fileDescr { ndx ( 1 ) } );

for j = 2 : savedTargetInfo.Options
    Options = sprintf ( '%s|%04.4d    %s    %s', Options, ...
                        savedTargetInfo.configNo  { ndx ( j ) }, ...
                        savedTargetInfo.fileNames { ndx ( j ) }, ...
                        savedTargetInfo.fileDescr { ndx ( j ) } );
end

end


function position = calcPosition ( ParentPos, pctx, pcty, w, h )

w = min ( ParentPos ( 3 ), w );
h = min ( ParentPos ( 4 ), h );

pctx = max ( 0, min ( 100, pctx ) );
pcty = max ( 0, min ( 100, pcty ) );

xCtrRange ( 1 ) = w / 2;
xCtrRange ( 2 ) = ParentPos ( 3 ) - xCtrRange ( 1 );
yCtrRange ( 1 ) = h / 2;
yCtrRange ( 2 ) = ParentPos ( 4 ) - yCtrRange ( 1 );

xCtr = ( xCtrRange ( 2 ) - xCtrRange ( 1 ) ) * pctx / 100 + xCtrRange ( 1 );
yCtr = ( yCtrRange ( 2 ) - yCtrRange ( 1 ) ) * pcty / 100 + yCtrRange ( 1 );

position ( 1 ) = xCtr - w / 2;
position ( 2 ) = yCtr - h / 2;
position ( 3 ) = w;
position ( 4 ) = h;

end


% --- Executes on button press in FILE_SELECTOR.
function FILE_SELECTOR_Callback ( hObject, eventdata, handles )
% hObject    handle to FILE_SELECTOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global OPctrl;
%fprintf ( 'FILE_SELECTOR_Callback called.\n' );

if ( strcmpi ( get ( handles.SAVE_RESTORE, 'SelectionType' ), 'open' ) )
    if ( OPctrl.saved )
        answ = 'Yes';
    else
        id = handles.savedTargetInfo.ndx ( get ( handles.FILE_SELECTOR, 'Value' ) );
        fn = handles.savedTargetInfo.fileNames { id };
        cf = handles.savedTargetInfo.configNo  { id };

        answ = questdlg( sprintf ( 'Restore config %04.4d "%s"?\n', cf, fn ), 'OP Restore Confirmation', 'Yes', 'No', 'No');
    end
    
    if ( strcmpi ( answ, 'yes' ) )
        RESTORE_BUTTON_Callback ( hObject, eventdata, handles );
    elseif ( strcmpi ( answ, 'CLOSE_WINDOW' ) )
        msgbox ( sprintf ( 'Restore action CLOSE_WINDOWled!\n' ), 'Failure Message');
    end
end

end


% --- Executes on button press SAVE_BUTTON.
function SAVE_BUTTON_Callback ( hObject, eventdata, handles )
% hObject    handle to SAVE_BUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fprintf ( 'SAVE_BUTTON_Callback called.\n' );

maxText              =  80;
default              = 'Standard Target Config';
options.Resize       = 'on';
options.WindowStyle  = 'normal';
options.Interpreter  = 'tex';
options.minFigWidth  = 600;
options.minFigHeight = 100;
options.DefBtnWidth  =  70;
options.DefBtnHeight =  30;

answer               = util_inputdlg ( sprintf ( 'Enter description [up to %d characters]', maxText ), ...
                                       'OP Target Save', 1, { default }, options );

if ( ~isempty ( answer ) )
    DescrText           = strtrim ( answer { 1 } );

    givenChars = length ( DescrText );
    
    if ( givenChars > maxText )
        trncMsg = msgbox ( sprintf ( 'Your description will be truncated by %d characters!', givenChars - maxText ), 'Info Message', 'modal' );
        uiwait ( trncMsg );
    end
    
    DescrText           = strtrim ( DescrText ( 1 : min ( givenChars, maxText ) ) );

%    fprintf ( 'Descriptor Text : "%s"\n', DescrText );

%    if ( saveOP ( handles, DescrText ) && hObject == handles.CANCEL_BUTTON )
%        terminateSaveRestoreWindow ( handles );
%    end
        
    saveOP ( handles, DescrText );
    
    handles = updateOptions ( handles );
    
    % Update handles structure
    guidata ( handles.SAVE_RESTORE, handles );
else
    failMsg = msgbox ( sprintf ( 'Save action cancelled!' ), 'Failure Message', 'modal' );
    uiwait ( failMsg );
%    fprintf ( 'Save Function Cancelled.\n' );
end

end


function success = saveOP ( handles, DescrText )

global OPctrl;

OP = handles.parentHandles.OP;
c  = clock;
fn = sprintf ( 'OP_%04.0fpC_%4.4d-%02.2d-%02.2d_%02.0f%02.0f.mat', ...
               OP { OPctrl.ID.BunchCharge }.Target * 1e3, ...
               c ( 1 ), c ( 2 ), c ( 3 ), c ( 4 ), c ( 5 ) ) ;

%fprintf ( 'Selected filename "%s"\n.', fn );
orgOPctrl        = OPctrl;
OPctrl.DescrText = DescrText;
OPctrl.SaveDate  = clock;
OPctrl.SaveName  = fn;
OPctrl.configNo  = handles.savedTargetInfo.nxtConfig;

pathString = handles.parentHandles.SaveRestoreFolder;

foundPath = exist ( pathString, 'dir' );

if ( ~foundPath )
    folder = strLastToken ( pathString, '/' );
    fp     = strfind ( pathString, folder );
    base   = pathString ( 1 : fp ( length ( fp ) ) - 1 );
    
    fprintf ('Folder "%s" does not exist.\nTrying to create new folder "%s" in "%s".\n', pathString, folder, base );

    [ s, mess, messid ] = mkdir ( base, folder );
    
    if ( ~ s )
        fprintf ( 'Unable to create %s folder (%s%s). Target values are NOT being saved.\n', folder, mess, messid );
        return;
    end

    fprintf ( 'Created %s folder (%s%s). \n', folder, mess, messid );    
%else
%    fprintf ('Folder "%s" exists.\n', pathString );
end

path_fn = sprintf ( '%s%s', pathString, fn );

if ( exist ( path_fn, 'file' ) )
    success      = false;
    msgbox ( sprintf ( 'Only one file can be saved per minute!\n' ), 'Failure Message');
    OPctrl       = orgOPctrl;
else
    save ( path_fn, 'OPctrl', 'OP', '-MAT' );

    success      = true;
    fprintf ( 'Target values saved to %s".\n', path_fn );
    savedMsg     = msgbox ( sprintf ( 'Target values saved to file %s [Config %04.4d]!\n', fn, OPctrl.configNo ), 'Success Message', 'modal' );
    uiwait ( savedMsg );
    
    OPctrl.saved = true;
end

end


% --- Executes on button press RESTORE_BUTTON.
function RESTORE_BUTTON_Callback ( hObject, eventdata, handles )
% hObject    handle to RESTORE_BUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global OPctrl;

%fprintf ( 'RESTORE_BUTTON_Callback called.\n' );

ndx = handles.savedTargetInfo.ndx;
j   = ndx ( get ( handles.FILE_SELECTOR, 'Value' ) );
fn  = handles.savedTargetInfo.fileNames { j };

if ( ~OPctrl.saved )
    answ = questdlg ( 'Save current Operating Point before restore?', 'Data Overwrite Check', 'Yes', 'No', 'Cancel', 'Yes' );
    
    if ( strcmpi ( answ, 'yes' ) )
        SAVE_BUTTON_Callback ( hObject, eventdata, handles )
    elseif ( strcmpi ( answ, 'cancel' ) )
        return;
    end
end

restoreOP ( handles, fn );

handles = updateOptions ( handles );
    
% Update handles structure
guidata ( hObject, handles );

%terminateSaveRestoreWindow ( handles );

end


function restoreOP ( handles, fn )

global OPctrl;

%fprintf ( 'RESTORE function called.\n' );

OP              = handles.parentHandles.OP;
folder          = handles.savedTargetInfo.Folder;
path_fn         = sprintf ( '%s%s', folder, fn );
loaded          = load  ( path_fn, 'OPctrl', 'OP' );

%fprintf ( 'OP { 1 }.Target = %f\n', OP { 1 }.Target );
%fprintf ( 'Loaded OP with %d elements. Current OP has %d elements.\n', length ( loaded.OP), length ( OP ) );

restoreTargets  = get ( handles.RESTORE_TARGETS_CHECKBOX,  'Value' );
restoreTols     = get ( handles.RESTORE_TOLS_CHECKBOX,     'Value' );
restoreUnits    = get ( handles.RESTORE_UNITS_CHECKBOX,    'Value' );
restoreComments = get ( handles.RESTORE_COMMENTS_CHECKBOX, 'Value' );

updatedTargets  = 0;
updatedTols     = 0;
updatedUnits    = 0;
updatedComments = 0;

for j = 1 : length ( OP )
%    fprintf ( '%d %s', j, OP { j }.ParamCode ); 
    
    ld = 0;
    
    for k = 1 : length ( loaded.OP )
        if ( strcmpi ( OP { j }.ParamCode, loaded.OP { k }.ParamCode ) )
            ld = k;
            break;
        end
    end
    
    if ( ld )
%        fprintf ( ' -> found at pos %3.3d.\n', ld );
        
        if ( restoreTargets && OP { j }.Tar_editbl && OP { j }.Target ~= loaded.OP { ld }.Target )
%            fmt = sprintf ( 'Updating Target to %s %s (from %s %s).\\n', OP { j }.Vfmt, OP { j }.Unit, OP { j }.Vfmt, OP { j }.Unit );
%            fprintf ( fmt, loaded.OP { ld }.Target, OP { j }.Target );
            OP { j }.Target           = loaded.OP { ld }.Target;
            OP { j }.Target_modified  = true;
            updatedTargets            = updatedTargets + 1;
        end

        if ( restoreTols && OP { j }.Tol ~= loaded.OP { ld }.Tol )
%            fmt = sprintf ( 'Updating Tol to %s %s (from %s %s).\\n', OP { j }.Tfmt, OP { j }.Unit, OP { j }.Tfmt, OP { j }.Unit );
%            fprintf ( fmt, loaded.OP { ld }.Tol, OP { j }.Tol );
            OP { j }.Tol              = loaded.OP { ld }.Tol;
            OP { j }.Tol_modified     = true;
            updatedTols               = updatedTols + 1;
        end

        if ( restoreUnits && OP { j }.Unit ~= loaded.OP { ld }.Unit )
%            fprintf ( 'Updating Unit to %s (from %s).\\n', loaded.OP { ld }.Unit, OP { j }.Unit );
            OP { j }.Unit             = loaded.OP { ld }.Unit;
            OP { j }.Unit_modified    = true;
            updatedUnits              = updatedUnits + 1;
        end

        if ( restoreComments && OP { j }.Comeditbl && ~strcmpi ( strtrim ( OP { j }.Comment ), strtrim ( loaded.OP { ld }.Comment ) ) )
%            fprintf ( 'Updating Comment to "%s" (from "%s").\n', loaded.OP { ld }.Comment, OP { j }.Comment );
            OP { j }.Comment          = loaded.OP { ld }.Comment;
            OP { j }.Comment_modified = true;
            updatedComments            = updatedComments + 1;
        end
    else
 %       fprintf ( ' -> not found.\n' );
    end    
end

updatedItems = updatedTargets + updatedTols + updatedUnits + updatedComments;

if ( updatedItems )
    handles.parentHandles.OP = OP;
    checkOP_gui ( 'SINGLE_SHOT_REFRESH_PUSHBUTTON_Callback', handles.parentHandles.SINGLE_SHOT_REFRESH_PUSHBUTTON, [], handles.parentHandles);
    OPctrl.saved             = true;

%    fprintf ( 'Target values restored from %s".\n', path_fn );
end

OPctrl.DescrText = loaded.OPctrl.DescrText;
OPctrl.SaveDate  = loaded.OPctrl.SaveDate;
OPctrl.SaveName  = loaded.OPctrl.SaveName;
OPctrl.configNo  = loaded.OPctrl.configNo;
OPctrl.saved     = true;

%fprintf ( 'Set OPctrl.configNo to %d.\n', OPctrl.configNo );

msg { 1 } = sprintf ( 'Config %04.4d restored from file %s!', OPctrl.configNo, fn );

if ( ~updatedItems )
    msg { 2 } = 'No updates were required.';
else
    msg { 2 } = sprintf ( 'Total updates: %d', updatedItems );
end

j = 2;

if ( updatedTargets )
    j = j + 1;
    msg { j } = sprintf ( 'Updated Target fields: %d', updatedTargets );
end

if ( updatedTols )
    j = j + 1;
    msg { j } = sprintf ( 'Updated Tol fields: %d', updatedTols );
end

if ( updatedUnits )
    j = j + 1;
    msg { j } = sprintf ( 'Updated Unit fields: %d', updatedUnits );
end

if ( updatedComments )
    j = j + 1;
    msg { j } = sprintf ( 'Updated Comment fields: %d', updatedComments );
end

msgbox ( msg, 'Success Message');

end


% --- Executes on button press DELETE_BUTTON.
function DELETE_BUTTON_Callback ( hObject, eventdata, handles )
% hObject    handle to DELETE_BUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fprintf ( 'DELETE_BUTTON_Callback called.\n' );

id = handles.savedTargetInfo.ndx ( get ( handles.FILE_SELECTOR, 'Value' ) );
fn = handles.savedTargetInfo.fileNames { id };
cf = handles.savedTargetInfo.configNo  { id };

answ = questdlg ( sprintf ( 'Permanently delete config %04.4d "%s"?\n', cf, fn ), 'File Removal Confirmation', 'yes', 'No', 'No' );

if ( strcmpi ( answ, 'yes' ) )
    fd   = sprintf ( '%s%s', handles.parentHandles.SaveRestoreFolder, fn );
%    fprintf ( 'Deleting "%s"\n', fd );    
    delete ( fd );

    handles = updateOptions ( handles );
    
    msgbox ( sprintf ( 'Config %04.4d "%s" deleted!\n', cf, fn ), 'Success Message');
end

% Update handles structure
guidata ( handles.SAVE_RESTORE, handles );

end


function handles = updateOptions ( handles )

global OPctrl;

handles.savedTargetInfo  = getSavedTargetInfo     ( handles.savedTargetInfo );
Options                  = setFileSelectorOptions ( handles.savedTargetInfo );

if ( OPctrl.saved )
    found_config = false;

    for j = 1 : handles.savedTargetInfo.Options
        if ( handles.savedTargetInfo.configNo { j } == OPctrl.configNo )
            found_config = true;
            break;
        end
    end
    
    OPctrl.saved = found_config;
end

set ( handles.FILE_SELECTOR, 'Value', handles.savedTargetInfo.Options );
set ( handles.FILE_SELECTOR, 'String', Options );
    
set ( handles.OPTIONS_TEXT, 'String', sprintf ( 'Number of restorable files: %d', handles.savedTargetInfo.Options ) );

if ( OPctrl.saved )    
    set ( handles.parentHandles.LAST_SAVE_RESTORE_CONFIG, 'String', sprintf ( 'Last save/restore config: %d', OPctrl.configNo ) );
end

if ( handles.savedTargetInfo.Options )
    set ( handles.parentHandles.LAST_SAVE_RESTORE_CONFIG, 'Visible', 'On' );
    set ( handles.RESTORE_PANEL, 'Visible', 'On' );
else
    set ( handles.parentHandles.LAST_SAVE_RESTORE_CONFIG, 'Visible', 'Off' );
    set ( handles.RESTORE_PANEL, 'Visible', 'Off' );
end

if ( OPctrl.configNo > 0 && OPctrl.saved && handles.savedTargetInfo.Options )
    set ( handles.CONFIG_TEXT, 'String', sprintf ( '%04.4d',OPctrl.configNo ) );
else                                   
    set ( handles.CONFIG_TEXT, 'String', 'not saved' );
end

end

function last = strLastToken ( t, s )

last   = t;
remain = t;
tok    = '';

while ( any ( remain ) )
    last = tok;
    [ tok, remain ] = strtok ( remain, s);
end

end


% --- Executes on button press in CLOSE_WINDOW_BUTTON.
function CLOSE_WINDOW_BUTTON_Callback ( hObject, eventdata, handles )
% hObject    handle to CLOSE_WINDOW_BUTTON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fprintf ( 'CLOSE_WINDOW_BUTTON_Callback called.\n' );

terminateSaveRestoreWindow ( handles );

end


function terminateSaveRestoreWindow ( handles )

global SaveRestoreWindowExists;

%fprintf ( 'SaveRestoreWindowExists = ' );

if ( SaveRestoreWindowExists )
%    fprintf ( 'true\n' );
%    fprintf ( 'destroying SAVE/Restore window.\n' );
else
%    fprintf ( 'false\n' );
%    fprintf ( 'Code error: terminateSaveRestoreWindow called for non-existing window.' );
    exit;
end

%fprintf ( 'Unsetting SaveRestoreWindowExists flag\n' );

SaveRestoreWindowExists = false;

%fprintf ( 'SaveRestoreWindowExists = ' );

%if ( SaveRestoreWindowExists )
%    fprintf ( 'true\n' );
%else
%    fprintf ( 'false\n' );
%end

parentHandles = handles.parentHandles;

if ( isfield ( parentHandles, 'SAVE_RESTORE' ) );
%    fprintf ( 'Removing SAVE_RESTORE handle from parents handle list.\n' );
    parentHandles = rmfield ( parentHandles, 'SAVE_RESTORE' );
end

if ( isfield ( parentHandles, 'SaveRestoreHandles' ) );
%    fprintf ( 'Removing SaveRestoreHandles structure from parents handle list.\n' );
    parentHandles = rmfield ( parentHandles, 'SaveRestoreHandles' );
end

guidata ( parentHandles.output, parentHandles );

% delete entire SAVE/RESTORE window
delete ( handles.SAVE_RESTORE );

end
