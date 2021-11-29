function varargout = moveUndulatorQuadrupole_gui(varargin)
% MOVEUNDULATORQUADRUPOLE_GUI M-file for moveUndulatorQuadrupole_gui.fig
%      MOVEUNDULATORQUADRUPOLE_GUI, by itself, creates a new MOVEUNDULATORQUADRUPOLE_GUI or raises the existing
%      singleton*.
%
%      H = MOVEUNDULATORQUADRUPOLE_GUI returns the handle to a new MOVEUNDULATORQUADRUPOLE_GUI or the handle to
%      the existing singleton*.
%
%      MOVEUNDULATORQUADRUPOLE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVEUNDULATORQUADRUPOLE_GUI.M with the given input arguments.
%
%      MOVEUNDULATORQUADRUPOLE_GUI('Property','Value',...) creates a new MOVEUNDULATORQUADRUPOLE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before moveUndulatorQuadrupole_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to moveUndulatorQuadrupole_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help moveUndulatorQuadrupole_gui

% Last Modified by GUIDE v2.5 19-Dec-2008 10:37:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @moveUndulatorQuadrupole_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @moveUndulatorQuadrupole_gui_OutputFcn, ...
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


% --- Executes just before moveUndulatorQuadrupole_gui is made visible.
function moveUndulatorQuadrupole_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to moveUndulatorQuadrupole_gui (see VARARGIN)

% Choose default command line output for moveUndulatorQuadrupole_gui
handles.output = hObject;

global PhysicsConsts;
global UndulatorConsts;

PhysicsConsts        = util_PhysicsConstants;
UndulatorConsts      = util_UndulatorConstants;

handles.GirderNumber = 1;
handles.geo          = girderGeo;
handles.MotionPermit = false;

if ( isQuad ( handles ) )
    handles = getCurrentQuadPosition ( handles );
else
    handles = getCurrentBFWPosition  ( handles );
end

handles.XMoveTo      = handles.CurrentXPosition;
handles.YMoveTo      = handles.CurrentYPosition;

handles.XMoveBy      = 0;
handles.YMoveBy      = 0;

handles = updateDisplayData ( handles );

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes moveUndulatorQuadrupole_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


function handles = updateDisplayData ( handles )

global PhysicsConsts;
global UndulatorConsts;

set ( handles.GIRDER_NUMBER, 'String', sprintf ( '%2.2d',  handles.GirderNumber ) );

if ( handles.MotionPermit )
    set ( handles.MOTION_STATUS, 'String', '' );
else
    set ( handles.MOTION_STATUS, 'String', '''GO'' Buttons Deactivated' );    
end

if ( isQuad ( handles ) )
    handles.BeamEnergy   = lcaGet ( 'BEND:DMP1:400:BACT' );                      % GeV
    handles.QuadStrength = lcaGet ( sprintf ( 'QUAD:UND1:%d80:BACT', handles.GirderNumber ) );

    if ( handles.GirderNumber < 33 )
        handles.NextGirder  = handles.GirderNumber + 1;
        distToNextBPM       = UndulatorConsts.Z_BPM { handles.NextGirder } - UndulatorConsts.Z_QUAD { handles.GirderNumber };
    else
%        handles.NextGirderX = 0;
%        handles.NextGirderY = 0;
        handles.NextGirder  = 0;
        distToNextBPM       = UndulatorConsts.Z_BPM { 34 } - UndulatorConsts.Z_QUAD { handles.GirderNumber };
    end

    if ( handles.NextGirder )
        set ( handles.NEXT_GIRDER_X, 'String', sprintf ( '%2.2d',  handles.NextGirder   ) );
        set ( handles.NEXT_GIRDER_Y, 'String', sprintf ( '%2.2d',  handles.NextGirder   ) );
    else
        set ( handles.NEXT_GIRDER_X, 'String', 'UE1' );
        set ( handles.NEXT_GIRDER_Y, 'String', 'UE1' );
    end
    
    set ( handles.BEAM_ENERGY,   'String', sprintf ( '%6.3f',  handles.BeamEnergy   ) );
    set ( handles.QUAD_STRENGTH, 'String', sprintf ( '%+6.3f', handles.QuadStrength ) );

    handles.Brho    = handles.BeamEnergy * 1e9 / PhysicsConsts.c;
    handles.dBPMdxQ = handles.QuadStrength / 10 * distToNextBPM / handles.Brho;

    set ( handles.DBPM_DXQ, 'String', sprintf ( '%+5.2f',  handles.dBPMdxQ ) );
    set ( handles.DBPM_DYQ, 'String', sprintf ( '%+5.2f', -handles.dBPMdxQ ) );

    handles  = getCurrentQuadPosition ( handles );

    set ( handles.CURRENT_X_POSITION,   'String', sprintf ( '%+6.1f', handles.CurrentXPosition ) );
    set ( handles.CURRENT_Y_POSITION,   'String', sprintf ( '%+6.1f', handles.CurrentYPosition ) );

    handles.CurrentXKickAngle = handles.CurrentXPosition * handles.QuadStrength / 10 / handles.Brho;
    handles.CurrentYKickAngle = handles.CurrentYPosition * handles.QuadStrength / 10 / handles.Brho;

    set ( handles.CURRENT_X_KICK_ANGLE, 'String', sprintf ( '%+6.1f', handles.CurrentXKickAngle ) );
    set ( handles.CURRENT_Y_KICK_ANGLE, 'String', sprintf ( '%+6.1f', handles.CurrentYKickAngle ) );

    set ( handles.X_MOVE_TO,            'String', sprintf ( '%+6.1f', handles.XMoveTo ) );
    set ( handles.Y_MOVE_TO,            'String', sprintf ( '%+6.1f', handles.YMoveTo ) );

    set ( handles.X_MOVE_BY,            'String', sprintf ( '%+6.1f', handles.XMoveBy ) );
    set ( handles.Y_MOVE_BY,            'String', sprintf ( '%+6.1f', handles.YMoveBy ) );
else
    handles  = getCurrentBFWPosition ( handles );

    set ( handles.CURRENT_X_POSITION,   'String', sprintf ( '%+6.1f', handles.CurrentXPosition ) );
    set ( handles.CURRENT_Y_POSITION,   'String', sprintf ( '%+6.1f', handles.CurrentYPosition ) );

    set ( handles.X_MOVE_TO,            'String', sprintf ( '%+6.1f', handles.XMoveTo ) );
    set ( handles.Y_MOVE_TO,            'String', sprintf ( '%+6.1f', handles.YMoveTo ) );

    set ( handles.X_MOVE_BY,            'String', sprintf ( '%+6.1f', handles.XMoveBy ) );
    set ( handles.Y_MOVE_BY,            'String', sprintf ( '%+6.1f', handles.YMoveBy ) );
end

end


function handles = getCurrentQuadPosition ( handles )

quad_rb1 = girderAxisFromCamAngles ( handles.GirderNumber, handles.geo.quadz, handles.geo.bfwz );

handles.CurrentXPosition = quad_rb1 ( 1 ) * 1000.0;
handles.CurrentYPosition = quad_rb1 ( 2 ) * 1000.0;

end


function handles = getCurrentBFWPosition ( handles )

[ quad_rb1, bfw_rb1 ] = girderAxisFromCamAngles ( handles.GirderNumber, handles.geo.quadz, handles.geo.bfwz );

handles.CurrentXPosition = bfw_rb1 ( 1 ) * 1000.0;
handles.CurrentYPosition = bfw_rb1 ( 2 ) * 1000.0;

end


function [ pa, pb, r ] = girderAxisFromCamAngles ( Slots, za, zb )

n = length ( Slots );

pa = zeros ( n, 3 );
pb = zeros ( n, 3 );
r  = zeros ( 1, n );

for j = 1 : n
    slot = Slots ( j );

    camAngles = girderCamMotorRead ( slot ); % find the present motor angles

% calculate theoretical pa and pb and roll

    [ a, ra ] = girderAngle2Axis ( za, camAngles );
    [ b, rb ] = girderAngle2Axis ( zb, camAngles );
    
    pa ( j, : ) = a;
    pb ( j, : ) = b;
    r  ( j )    = ( ra + rb ) / 2;
end

end


% --- Outputs from this function are returned to the command line.
function varargout = moveUndulatorQuadrupole_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end


function GIRDER_NUMBER_Callback(hObject, eventdata, handles)
% hObject    handle to GIRDER_NUMBER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GIRDER_NUMBER as text
%        str2double(get(hObject,'String')) returns contents of GIRDER_NUMBER as a double

handles.GirderNumber = str2double ( get ( hObject, 'String') );

handles.GirderNumber = max ( 1, min ( 33, handles.GirderNumber ) );

if ( isQuad ( handles ) )
    handles          = getCurrentQuadPosition ( handles );
    handles.XMoveTo  = handles.CurrentXPosition;
    handles.YMoveTo  = handles.CurrentYPosition;
else
    handles          = getCurrentBFWPosition ( handles );
    handles.XMoveTo  = handles.CurrentXPosition;
    handles.YMoveTo  = handles.CurrentYPosition;
end

handles = updateDisplayData ( handles );

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GIRDER_NUMBER_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GIRDER_NUMBER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to CURRENT_X_POSITION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CURRENT_X_POSITION as text
%        str2double(get(hObject,'String')) returns contents of CURRENT_X_POSITION as a double

end


% --- Executes during object creation, after setting all properties.
function CURRENT_X_POSITION_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CURRENT_X_POSITION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to CURRENT_Y_POSITION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CURRENT_Y_POSITION as text
%        str2double(get(hObject,'String')) returns contents of CURRENT_Y_POSITION as a double

end


% --- Executes during object creation, after setting all properties.
function CURRENT_Y_POSITION_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CURRENT_Y_POSITION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set ( hObject, 'BackgroundColor', 'white' );
end

end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to CURRENT_X_KICK_ANGLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CURRENT_X_KICK_ANGLE as text
%        str2double(get(hObject,'String')) returns contents of CURRENT_X_KICK_ANGLE as a double

end


% --- Executes during object creation, after setting all properties.
function CURRENT_X_KICK_ANGLE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CURRENT_X_KICK_ANGLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to CURRENT_Y_KICK_ANGLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CURRENT_Y_KICK_ANGLE as text
%        str2double(get(hObject,'String')) returns contents of CURRENT_Y_KICK_ANGLE as a double

end


% --- Executes during object creation, after setting all properties.
function CURRENT_Y_KICK_ANGLE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CURRENT_Y_KICK_ANGLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function X_MOVE_BY_Callback(hObject, eventdata, handles)
% hObject    handle to X_MOVE_BY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of X_MOVE_BY as text
%        str2double(get(hObject,'String')) returns contents of X_MOVE_BY as a double

handles.XMoveBy = str2double ( get ( hObject, 'String' ) );

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function X_MOVE_BY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_MOVE_BY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function Y_MOVE_BY_Callback(hObject, eventdata, handles)
% hObject    handle to Y_MOVE_BY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y_MOVE_BY as text
%        str2double(get(hObject,'String')) returns contents of Y_MOVE_BY as a double

handles.YMoveBy = str2double ( get ( hObject, 'String' ) );

handles = updateDisplayData ( handles );

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function Y_MOVE_BY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_MOVE_BY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function X_MOVE_TO_Callback(hObject, eventdata, handles)
% hObject    handle to X_MOVE_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of X_MOVE_TO as text
%        str2double(get(hObject,'String')) returns contents of X_MOVE_TO as a double

handles.XMoveTo = str2double ( get ( hObject, 'String' ) );

handles = updateDisplayData ( handles );

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function X_MOVE_TO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_MOVE_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function Y_MOVE_TO_Callback(hObject, eventdata, handles)
% hObject    handle to Y_MOVE_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y_MOVE_TO as text
%        str2double(get(hObject,'String')) returns contents of Y_MOVE_TO as a double

handles.YMoveTo = str2double ( get ( hObject, 'String' ) );

handles = updateDisplayData ( handles );

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function Y_MOVE_TO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_MOVE_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in GO_MOVE_BY.
function GO_MOVE_BY_Callback(hObject, eventdata, handles)
% hObject    handle to GO_MOVE_BY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( handles.MotionPermit )
    fprintf ( 'got permission to move girder\n' );

    [ quad_rb1, bfw_rb1 ] = girderAxisFromCamAngles ( handles.GirderNumber, handles.geo.quadz, handles.geo.bfwz );

    if ( isQuad ( handles ) )
        bfw_sp  = bfw_rb1;
        quad_sp = quad_rb1  + [ handles.XMoveBy, handles.YMoveBy, 0] / 1000;

        fprintf ( 'Moving Quad %2.2d by distance (% +6.1f µm,% +6.1f µm).\n', ...
            handles.GirderNumber, ...
            handles.XMoveBy, ...
            handles.YMoveBy  ...
            );

        set ( handles.MOTION_STATUS, 'String', 'MOVING' );    

        girderAxisSet ( handles.GirderNumber, bfw_sp, quad_sp );
        girderCamWait ( handles.GirderNumber );
        
        set ( handles.MOTION_STATUS, 'String', '' );
    else
        bfw_sp  = bfw_rb1  + [ handles.XMoveBy, handles.YMoveBy, 0] / 1000;
        quad_sp = quad_rb1;

        fprintf ( 'Moving BFW %2.2d by distance (% +6.1f µm,% +6.1f µm).\n', ...
            handles.GirderNumber, ...
            handles.XMoveBy, ...
            handles.YMoveBy ...
            );
    
        set ( handles.MOTION_STATUS, 'String', 'MOVING' );    

        girderAxisSet ( handles.GirderNumber, bfw_sp, quad_sp );
        girderCamWait ( handles.GirderNumber );

        set ( handles.MOTION_STATUS, 'String', '' );    
    end

    handles = updateDisplayData ( handles );

    % Update handles structure
    guidata(hObject, handles);
end

end


% --- Executes on button press in GO_MOVE_TO.
function GO_MOVE_TO_Callback(hObject, eventdata, handles)
% hObject    handle to GO_MOVE_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( handles.MotionPermit )
    fprintf ( 'got permission to move girder\n' );

    [ quad_rb1, bfw_rb1 ] = girderAxisFromCamAngles ( handles.GirderNumber, handles.geo.quadz, handles.geo.bfwz );

    if ( isQuad ( handles ) )
        fprintf ( 'Moving Quad %2.2d by distance  (% +6.1f µm,% +6.1f µm).\n', ...
            handles.GirderNumber, ...
            handles.XMoveTo - handles.CurrentXPosition, ...
            handles.YMoveTo - handles.CurrentYPosition  ...
            );

        quad_sp = [ handles.XMoveTo/1000, handles.YMoveTo/1000, quad_rb1(3) ];
        bfw_sp  = bfw_rb1;
    
        set ( handles.MOTION_STATUS, 'String', 'MOVING' );    

        girderAxisSet ( handles.GirderNumber, bfw_sp, quad_sp );
        girderCamWait ( handles.GirderNumber );

        set ( handles.MOTION_STATUS, 'String', '' );    
    else
        fprintf ( 'Moving BFW %2.2d  by distance  (% +6.1f µm,% +6.1f µm).\n', ...
            handles.GirderNumber, ...
            handles.XMoveTo - handles.CurrentXPosition, ...
            handles.YMoveTo - handles.CurrentYPosition  ...
            );
    
        quad_sp = quad_rb1;
        bfw_sp  = [ handles.XMoveTo/1000, handles.YMoveTo/1000, bfw_rb1(3) ];
    
        set ( handles.MOTION_STATUS, 'String', 'MOVING' );    

        girderAxisSet ( handles.GirderNumber, bfw_sp, quad_sp );
        girderCamWait ( handles.GirderNumber );

        set ( handles.MOTION_STATUS, 'String', '' );    
    end

    handles = updateDisplayData ( handles );

    % Update handles structure
    guidata(hObject, handles);
end

end


% --- Executes on button press in SWAP_QUAD_BFW.
function SWAP_QUAD_BFW_Callback(hObject, eventdata, handles)
% hObject    handle to SWAP_QUAD_BFW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf ( 'SWAP_QUAD_BFW_Callback called.\n' );

fprintf ( 'isQuad = %d\n', isQuad ( handles ) );

if ( isQuad ( handles ) )
    set ( handles.QUAD_STRENGTH_LABEL,    'Visible', 'off' );
    set ( handles.QUAD_STRENGTH,          'Visible', 'off' );
    set ( handles.QUAD_STRENGTH_UNIT,     'Visible', 'off' );
    set ( handles.BEAM_ENERGY_LABEL,      'Visible', 'off' );
    set ( handles.BEAM_ENERGY,            'Visible', 'off' );
    set ( handles.BEAM_ENERGY_UNIT,       'Visible', 'off' );
    set ( handles.CURRENT_KICK_TITLE,     'Visible', 'off' );
    set ( handles.CURRENT_X_KICK_LABEL,   'Visible', 'off' );
    set ( handles.CURRENT_X_KICK_ANGLE,   'Visible', 'off' );
    set ( handles.CURRENT_X_KICK_UNIT,    'Visible', 'off' );
    set ( handles.CURRENT_Y_KICK_LABEL,   'Visible', 'off' );
    set ( handles.CURRENT_Y_KICK_ANGLE,   'Visible', 'off' );
    set ( handles.CURRENT_Y_KICK_UNIT,    'Visible', 'off' );
    set ( handles.LEGEND_TITLE,           'Visible', 'off' );
    set ( handles.DBPM_DXQ,               'Visible', 'off' );
    set ( handles.X_LEGEND_LABEL,         'Visible', 'off' );
    set ( handles.X_LEGEND_TARGET,        'Visible', 'off' );
    set ( handles.NEXT_GIRDER_X,          'Visible', 'off' );
    set ( handles.DBPM_DYQ,               'Visible', 'off' );
    set ( handles.Y_LEGEND_LABEL,         'Visible', 'off' );
    set ( handles.Y_LEGEND_TARGET,        'Visible', 'off' );
    set ( handles.NEXT_GIRDER_Y,          'Visible', 'off' );
    set ( handles.SWAP_QUAD_BFW,          'String',  'Switch to Quad' );
    set ( handles.USE_LABEL,              'String',  'Use BFW' );
    set ( handles.TITLE,                  'String',  'Move x/y Position of a Beam Finder Wire' );
    
    handles              = getCurrentBFWPosition ( handles );
    handles.XMoveTo      = handles.CurrentXPosition;
    handles.YMoveTo      = handles.CurrentYPosition;
else
    set ( handles.QUAD_STRENGTH_LABEL,    'Visible', 'on' );
    set ( handles.QUAD_STRENGTH,          'Visible', 'on' );
    set ( handles.QUAD_STRENGTH_UNIT,     'Visible', 'on' );
    set ( handles.BEAM_ENERGY_LABEL,      'Visible', 'on' );
    set ( handles.BEAM_ENERGY,            'Visible', 'on' );
    set ( handles.BEAM_ENERGY_UNIT,       'Visible', 'on' );
    set ( handles.CURRENT_KICK_TITLE,     'Visible', 'on' );
    set ( handles.CURRENT_X_KICK_LABEL,   'Visible', 'on' );
    set ( handles.CURRENT_X_KICK_ANGLE,   'Visible', 'on' );
    set ( handles.CURRENT_X_KICK_UNIT,    'Visible', 'on' );
    set ( handles.CURRENT_Y_KICK_LABEL,   'Visible', 'on' );
    set ( handles.CURRENT_Y_KICK_ANGLE,   'Visible', 'on' );
    set ( handles.CURRENT_Y_KICK_UNIT,    'Visible', 'on' );
    set ( handles.LEGEND_TITLE,           'Visible', 'on' );
    set ( handles.DBPM_DXQ,               'Visible', 'on' );
    set ( handles.X_LEGEND_LABEL,         'Visible', 'on' );
    set ( handles.X_LEGEND_TARGET,        'Visible', 'on' );
    set ( handles.NEXT_GIRDER_X,          'Visible', 'on' );
    set ( handles.DBPM_DYQ,               'Visible', 'on' );
    set ( handles.Y_LEGEND_LABEL,         'Visible', 'on' );
    set ( handles.Y_LEGEND_TARGET,        'Visible', 'on' );
    set ( handles.NEXT_GIRDER_Y,          'Visible', 'on' );
    set ( handles.SWAP_QUAD_BFW,          'String',  'Switch to BFW' );
    set ( handles.USE_LABEL,              'String',  'Use Quad QU' );
    set ( handles.TITLE,                  'String',  'Move an Undulator Quadrupole for Orbit Correction' );

    handles              = getCurrentQuadPosition ( handles );
    handles.XMoveTo      = handles.CurrentXPosition;
    handles.YMoveTo      = handles.CurrentYPosition;
end

handles = updateDisplayData ( handles );

% Update handles structure
guidata(hObject, handles);

end


function answer = isQuad ( handles )

answer = strcmp ( get ( handles.SWAP_QUAD_BFW, 'String'), 'Switch to BFW' );

end


function answer = isActive ( handles )

answer = strcmp ( get ( handles.ACTIVATE, 'String'), 'Deactivate' );

end


% --- Executes on button press in ACTIVATE.
function ACTIVATE_Callback(hObject, eventdata, handles)
% hObject    handle to ACTIVATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( isActive ( handles ) )
    set ( handles.ACTIVATE,         'String', 'Activate' );
    set ( handles.ACTIVATION_LABEL, 'String', 'Motion Control Deactivated' );
    set ( handles.MOTION_STATUS, 'String', '''GO'' Buttons Deactivated' );    
    handles.MotionPermit = false;
else
    set ( handles.ACTIVATE,         'String', 'Deactivate' );
    set ( handles.ACTIVATION_LABEL, 'String', 'Motion Control Activated' );
    set ( handles.MOTION_STATUS, 'String', '' );
    handles.MotionPermit = true;
end

% Update handles structure
guidata(hObject, handles);

end


% --- Executes when user attempts to close checkOP_gui.
function CloseRequestFcn ( hObject, eventdata, handles )

fprintf ( 'Closing  moveUndulatorQuadrupole_gui.\n' );

util_appClose ( hObject );
lcaClear ( );

end
