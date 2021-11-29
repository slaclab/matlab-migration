function varargout = sext_gui(varargin)
% SEXT_GUI M-file for sext_gui.fig
%      SEXT_GUI, by itself, creates a new SEXT_GUI or raises the existing
%      singleton*.
%
%      H = SEXT_GUI returns the handle to a new SEXT_GUI or the handle to
%      the existing singleton*.
%
%      SEXT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEXT_GUI.M with the given input arguments.
%
%      SEXT_GUI('Property','Value',...) creates a new SEXT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sext_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sext_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sext_gui

% Last Modified by GUIDE v2.5 14-Mar-2013 15:53:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sext_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sext_gui_OutputFcn, ...
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


% --- Executes just before sext_gui is made visible.
function sext_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sext_gui (see VARARGIN)


% Choose default command line output for sext_gui
handles.output = hObject;

% set default plotting flags
handles.plot.lvdt = 1;
handles.plot.bpms = 1;
handles.plot.pots = 1;
handles.plot.des = 1;
handles.plot.gold = 1;

% initialize
[handles.geom, handles.pvs] = sext_init();

handles.names = {'SEXT:LI20:2145' 'SEXT:LI20:2165' 'SEXT:LI20:2335' 'SEXT:LI20:2365'};
handles.tags = {'S1E-L (2145)' 'S2E-L (2165)' 'S2E-R (2335)' 'S1E-R (2365)'};
handles.family = 1;
handles.movers = [1 4];

handles.enable = ~get(handles.checkbox_disable, 'Value');
handles.server = get(handles.checkbox_server, 'Value');
[handles.d.val, handles.d.ts] = lcaGetStruct(handles.pvs);

handles.refresh = str2double(get(handles.edit_refresh, 'String'));
handles.roll_scale = str2double(get(handles.edit_roll_scale, 'String'));

% run first iteration of control calculation
handles = read_data(handles);
handles.act = zeros(2,3);
gui_statusDisp(handles, 'FACET sext GUI loaded.  Press "Run" to begin updating.');

global timerObj;
timerObj = timer('ExecutionMode', 'fixedDelay', 'Period', handles.refresh);
set(timerObj, 'TimerFcn', @(obj, event) timer_function(obj, event, hObject));

% plottools(hObject);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sext_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function timer_function(obj, event, guifig)
try
    % read everything in and update the GUI display
    handles = read_data(guidata(guifig));

    % control the movers if the server is on
    if handles.server && handles.enable  && handles.newsetpoints
        gui_statusDisp(handles, 'Moving...');
        for ix = 1:4
            if handles.des.valid(ix)
                handles.act(ix,:) = reshape(lcaPutSmart(handles.pvs.motr(ix,:)', handles.des.cam(ix,:)'), 1, 3);
            end
        end
        gui_statusDisp(handles, 'Done.');
    end
            
catch 
    err = lasterror;
    err.stack(:).file
    err.stack(:).name
    err.stack(:).line
end    
guidata(guifig, handles);

% --- Outputs from this function are returned to the command line.
function varargout = sext_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_1_lvdt_1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_lvdt_1 as text
%        str2double(get(hObject,'String')) returns contents of edit_1_lvdt_1 as a double


% --- Executes during object creation, after setting all properties.
function edit_1_lvdt_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_lvdt_2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_lvdt_2 as text
%        str2double(get(hObject,'String')) returns contents of edit_1_lvdt_2 as a double


% --- Executes during object creation, after setting all properties.
function edit_1_lvdt_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_lvdt_3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_lvdt_3 as text
%        str2double(get(hObject,'String')) returns contents of edit_1_lvdt_3 as a double


% --- Executes during object creation, after setting all properties.
function edit_1_lvdt_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_update.
function pushbutton_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerObj;
coords = {'x' 'y' 't'};
lcaSetMonitor(reshape(handles.pvs.setpoint, [], 1));

buttonstate = get(hObject, 'Value');
switch buttonstate
    case 1
        set(hObject, 'BackgroundColor', [0 0.5 0], 'String', 'Running...');
        set(handles.checkbox_server, 'Enable', 'off');
        data = lcaGetStruct(handles.pvs);
%         for ix = 1:2
%             for jx = 1:3
%                 set(handles.(strcat('edit_', num2str(ix), '_', char(coords(jx)), 'des')), 'String', num2str(data.setpoint(ix, jx)));
%             end
%         end
        handles = read_data(handles);
        start(timerObj);
    case 0
        set(hObject, 'BackgroundColor', [0 0.5 0], 'String', 'Run');
        set(handles.checkbox_server, 'Enable', 'on');
        stop(timerObj);
end

guidata(hObject, handles);


function handles = read_data(handles)

% read in pvs
handles.d.old = handles.d.val;
[handles.d.val, handles.d.ts] = lcaGetStruct(handles.pvs);

% check for new controls
if any(any(handles.d.val.setpoint ~= handles.d.old.setpoint))
    handles.newsetpoints = 1;
    %disp(sprintf('new setpoints! handles.server = %d', handles.server))
else
    handles.newsetpoints = 0;
end
% 
% handles.newsetpoints = 0;
% if lcaNewMonitorValue(reshape(handles.pvs.setpoint, [], 1))
%     handles.newsetpoints = 1;
% end
% 
% [handles.d.val, handles.d.ts] = lcaGetStruct(handles.pvs);



% apply offsets and calibrations to readbacks - if needed

% calculate realspace coordinates
for ix = 1:4
    handles.lvdt.real(ix,:)     = sext_lvdt2real(ix, handles.d.val.lvdtpos(ix,:),   handles.geom);
    handles.motr.real(ix,:)     = sext_cams2real(ix, handles.d.val.motr(ix,:),      handles.geom);
    handles.motrrbv.real(ix,:)  = sext_cams2real(ix, handles.d.val.motrrbv(ix,:),   handles.geom);
    handles.pots.real(ix,:)     = sext_cams2real(ix, handles.d.val.potpos(ix,:),    handles.geom);
end

handles.gold.real = handles.d.val.gold;

% update control points
coords = {'x' 'y' 't'};
if ~handles.newsetpoints
    for ix = 1:2
        mx = handles.movers(ix);
        for jx = 1:3
            set(handles.(strcat('edit_', num2str(ix), '_', char(coords(jx)), 'des')), ...
                'String', num2str(handles.d.val.setpoint(mx, jx)));
        end
    end
end

handles = calc_cam_des(handles);        
%disp(sprintf('handles.server = %d', handles.server))
handles = update_gui(handles);

function [xpts, ypts] = draw_cross(x, y, theta, cross_size)

theta = theta * 1e-3;  % theta is mrad

rotmat = [cos(theta)    -sin(theta);
          sin(theta)     cos(theta)];

% generate a cross
xs = [0  1 -1  0  0  0  0] * cross_size;
ys = [0  0  0  0  1 -1  0] * cross_size;

% rotate by theta
xy = [xs; ys];
xyrot = xy' * rotmat;

% offset by x, y
xpts = xyrot(:,1)' + x;
ypts = xyrot(:,2)' + y;

function handles = update_gui(handles)


if get(handles.radiobutton_family_1, 'Value')
    handles.family = 1;
    handles.movers = [1 4];
elseif get(handles.radiobutton_family_2, 'Value')
    handles.family = 2;
    handles.movers = [2 3];
end


% update textboxes
%disp(sprintf('in update_gui, handles.server = %d', handles.server));

coords = {'x' 'y' 't'};
units = {'mm' 'mm' 'mr'};
ax = [handles.axes1, handles.axes2];

for ix = 1:2
    % update UIpanels
    movertags = handles.tags(handles.movers);
    movernames = handles.names(handles.movers);
    mx = handles.movers(ix);
    
    set(handles.(strcat('uipanel_control_', num2str(ix))), 'Title', ...
        strcat({'Control '}, movertags(ix), {' '}, movernames(ix)));
    
    set(handles.(strcat('uipanel_lvdt_', num2str(ix))), 'Title', ...
        strcat({'LVDT '}, movertags(ix), {' '}, movernames(ix)));
    
    set(handles.(strcat('uipanel_pot_', num2str(ix))), 'Title', ...
        strcat({'Pots '}, movertags(ix), {' '}, movernames(ix)))
    
    for jx = 1:3
        
        %update setpoint boxes
        if handles.server
            set(handles.(strcat('edit_', num2str(ix), '_', char(coords(jx)), 'des')),...
                'String', num2str(handles.d.val.setpoint(mx, jx)));         
        end
        
        % update LVDT boxes
        set(handles.(strcat('edit_', num2str(ix), '_lvdt_', num2str(jx))), ...
            'String', sprintf('%.4f mm', handles.d.val.lvdtpos(mx, jx)));
        set(handles.(strcat('edit_', num2str(ix), '_lvdt_', char(coords(jx)))), ...
            'String', sprintf('%.4f %s', handles.lvdt.real(mx, jx), char(units(jx))));

        % update POT boxes
        set(handles.(strcat('edit_', num2str(ix), '_pot_', num2str(jx))), ...
            'String', sprintf('%.3f deg', handles.d.val.potpos(mx, jx)));
        set(handles.(strcat('edit_', num2str(ix), '_pot_', char(coords(jx)))), ...
            'String', sprintf('%.3f %s', handles.pots.real(mx, jx), char(units(jx))));
        
        % update output PVs

            lcaPutSmart(reshape(handles.pvs.output.lvdt, [], 1), reshape(handles.lvdt.real, [], 1));
            lcaPutSmart(reshape(handles.pvs.output.pots, [], 1), reshape(handles.pots.real, [], 1));
            lcaPutSmart(reshape(handles.pvs.valid, [], 1),       reshape(handles.des.valid, [], 1));
    end
 
    handles = doplot(handles, mx, ax(ix), 0);

end
drawnow;


function handles = doplot(handles, num, ax, forLogbook)
colors = {'b' 'k'};
% handles.roll_scale = 100;        % plot scale exaggerate theta by this amt
scale = 0.5;           % plot scale size of crosses (mm)

% if ~forLogbook
%     ax = handles.(strcat('axes', num2str(num)));
% end

cla(ax);
hold(ax, 'all');

% plot "des" cross
if handles.plot.des
    [xcross, ycross] = draw_cross(handles.des.real(num, 1), handles.des.real(num, 2), ...
        handles.roll_scale * handles.des.real(num, 3), scale);
    if handles.des.valid(num), color = 'g'; else color = 'r'; end
    handles.plots.des = plot(ax, xcross, ycross, color, 'LineWidth', 3);
end

% plot LVDT cross
if handles.plot.lvdt
    [xcross, ycross] = draw_cross(handles.lvdt.real(num, 1), handles.lvdt.real(num, 2), ...
        handles.roll_scale * handles.lvdt.real(num, 3), scale);
    handles.plots.lvdt = plot(ax, xcross, ycross, char(strcat(colors(1), '-')), 'LineWidth', 2);
end

% plot POT cross
if handles.plot.pots
    [xcross, ycross] = draw_cross(handles.pots.real(num, 1), handles.pots.real(num, 2), ...
        handles.roll_scale * handles.pots.real(num, 3), scale);
    handles.plots.pots = plot(ax, xcross, ycross, char(strcat(colors(2), '-')), 'LineWidth', 2);
end

% plot GOLD cross
if handles.plot.gold
    [xcross, ycross] = draw_cross(handles.gold.real(num, 1), handles.gold.real(num, 2), ...
        handles.roll_scale * handles.gold.real(num, 3), scale);
    handles.plots.gold = plot(ax, xcross, ycross, 'Color', [1 0.8 0], 'LineWidth', 2);
end

% plot BPM position
if handles.plot.bpms
    if handles.d.val.bpms(num,3) <= 1e9
        markspec = 'ro';
    else
        markspec = 'bo';
    end        
    handles.plots.bpms = plot(ax, handles.d.val.bpms(num, 1), handles.d.val.bpms(num, 2), markspec, 'MarkerSize', 16);
end





function edit_1_lvdt_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_lvdt_x as text
%        str2double(get(hObject,'String')) returns contents of edit_1_lvdt_x as a double


% --- Executes during object creation, after setting all properties.
function edit_1_lvdt_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_lvdt_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_lvdt_y as text
%        str2double(get(hObject,'String')) returns contents of edit_1_lvdt_y as a double


% --- Executes during object creation, after setting all properties.
function edit_1_lvdt_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_lvdt_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_lvdt_t as text
%        str2double(get(hObject,'String')) returns contents of edit_1_lvdt_t as a double


% --- Executes during object creation, after setting all properties.
function edit_1_lvdt_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_lvdt_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_lvdt_1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_lvdt_1 as text
%        str2double(get(hObject,'String')) returns contents of edit_2_lvdt_1 as a double


% --- Executes during object creation, after setting all properties.
function edit_2_lvdt_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_lvdt_2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_lvdt_2 as text
%        str2double(get(hObject,'String')) returns contents of edit_2_lvdt_2 as a double


% --- Executes during object creation, after setting all properties.
function edit_2_lvdt_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_lvdt_3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_lvdt_3 as text
%        str2double(get(hObject,'String')) returns contents of edit_2_lvdt_3 as a double


% --- Executes during object creation, after setting all properties.
function edit_2_lvdt_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_lvdt_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_lvdt_x as text
%        str2double(get(hObject,'String')) returns contents of edit_2_lvdt_x as a double


% --- Executes during object creation, after setting all properties.
function edit_2_lvdt_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_lvdt_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_lvdt_y as text
%        str2double(get(hObject,'String')) returns contents of edit_2_lvdt_y as a double


% --- Executes during object creation, after setting all properties.
function edit_2_lvdt_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_lvdt_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_lvdt_t as text
%        str2double(get(hObject,'String')) returns contents of edit_2_lvdt_t as a double


% --- Executes during object creation, after setting all properties.
function edit_2_lvdt_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_lvdt_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = calc_cam_des(handles)

dims = ['x' 'y' 't'];

mv = handles.movers;
        

if handles.server
    for ix = 1:4
        for jx = 1:3
            handles.des.real(ix, jx) = handles.d.val.setpoint(ix, jx);
            [handles.des.cam(ix,:), handles.des.valid(ix)] = sext_real2cams(ix, handles.des.real(ix,:), handles.geom);
        end
    end
end
            
for ix = 1:2
    mx = handles.movers(ix);
    for jx = 1:3
        if ~handles.server
            handles.des.real(mx, jx) = str2double(get(...
                handles.(strcat('edit_', num2str(ix), '_', dims(jx), 'des')), 'String'));      
        end
    end
    [handles.des.cam(mx,:), handles.des.valid(mx)] = sext_real2cams(mx, handles.des.real(mx,:), handles.geom);
end

for ix = 1:2
    mx = handles.movers(ix);
    for jx = 1:3
        ok = isreal(handles.des.cam(mx, jx));
        if ok, color = 'green'; else color = 'red'; end
        set(handles.(strcat('edit_', num2str(ix), '_c', num2str(jx), 'des')), ...
            'String', sprintf('%.3f deg', real(handles.des.cam(mx, jx))), ...
            'ForegroundColor', color);
    end
    if handles.des.valid(mx)
        set(handles.(strcat('text_', num2str(ix), '_valid')), 'String', 'VALID', 'ForegroundColor', 'green');
    else
        set(handles.(strcat('text_', num2str(ix), '_valid')), 'String', 'INVALID', 'ForegroundColor', 'red');
    end
    
end


function edit_1_xdes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_xdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_xdes as text
%        str2double(get(hObject,'String')) returns contents of edit_1_xdes as a double
lcaPutSmart(handles.pvs.setpoint(handles.movers(1),1), str2double(get(hObject, 'String')));
handles = calc_cam_des(handles);
handles = update_gui(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_1_xdes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_xdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_ydes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_ydes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_ydes as text
%        str2double(get(hObject,'String')) returns contents of edit_1_ydes as a double
lcaPutSmart(handles.pvs.setpoint(handles.movers(1),2), str2double(get(hObject, 'String')));
handles = calc_cam_des(handles);
handles = update_gui(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_1_ydes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_ydes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_tdes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_tdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_tdes as text
%        str2double(get(hObject,'String')) returns contents of edit_1_tdes as a double
lcaPutSmart(handles.pvs.setpoint(handles.movers(1),3), str2double(get(hObject, 'String')));
handles = calc_cam_des(handles);
handles = update_gui(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_1_tdes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_tdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_c1des_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_c1des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_c1des as text
%        str2double(get(hObject,'String')) returns contents of edit_1_c1des as a double


% --- Executes during object creation, after setting all properties.
function edit_1_c1des_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_c1des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_c2des_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_c2des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_c2des as text
%        str2double(get(hObject,'String')) returns contents of edit_1_c2des as a double


% --- Executes during object creation, after setting all properties.
function edit_1_c2des_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_c2des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_c3des_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_c3des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_c3des as text
%        str2double(get(hObject,'String')) returns contents of edit_1_c3des as a double


% --- Executes during object creation, after setting all properties.
function edit_1_c3des_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_c3des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_xdes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_xdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_xdes as text
%        str2double(get(hObject,'String')) returns contents of edit_2_xdes as a double
lcaPutSmart(handles.pvs.setpoint(handles.movers(2),1), str2double(get(hObject, 'String')));
handles = calc_cam_des(handles);
handles = update_gui(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_2_xdes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_xdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_ydes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_ydes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_ydes as text
%        str2double(get(hObject,'String')) returns contents of edit_2_ydes as a double
lcaPutSmart(handles.pvs.setpoint(handles.movers(2),2), str2double(get(hObject, 'String')));
handles = calc_cam_des(handles);
handles = update_gui(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_2_ydes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_ydes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_tdes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_tdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_tdes as text
%        str2double(get(hObject,'String')) returns contents of edit_2_tdes as a double
lcaPutSmart(handles.pvs.setpoint(handles.movers(2),3), str2double(get(hObject, 'String')));
handles = calc_cam_des(handles);
handles = update_gui(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_2_tdes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_tdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_c1des_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_c1des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_c1des as text
%        str2double(get(hObject,'String')) returns contents of edit_2_c1des as a double


% --- Executes during object creation, after setting all properties.
function edit_2_c1des_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_c1des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_c2des_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_c2des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_c2des as text
%        str2double(get(hObject,'String')) returns contents of edit_2_c2des as a double


% --- Executes during object creation, after setting all properties.
function edit_2_c2des_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_c2des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_c3des_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_c3des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_c3des as text
%        str2double(get(hObject,'String')) returns contents of edit_2_c3des as a double


% --- Executes during object creation, after setting all properties.
function edit_2_c3des_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_c3des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_2_go.
function handles = pushbutton_2_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(2);
if handles.enable && handles.des.valid(mx)
    lcaPutSmart(handles.pvs.setpoint(mx,:)', handles.des.real(mx,:)');
    handles.act(mx,:) = reshape(lcaPutSmart(handles.pvs.motr(mx,:)', handles.des.cam(mx,:)'), 1, 3);
end
guidata(hObject, handles)

% --- Executes on button press in pushbutton_1_go.
function handles = pushbutton_1_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(1);
if handles.enable && handles.des.valid(mx)
    lcaPutSmart(handles.pvs.setpoint(mx,:)', handles.des.real(mx,:)');
    handles.act(mx,:) = reshape(lcaPutSmart(handles.pvs.motr(mx,:)', handles.des.cam(mx,:)'), 1, 3);
end
guidata(hObject, handles)


function edit_2_pot_1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_pot_1 as text
%        str2double(get(hObject,'String')) returns contents of edit_2_pot_1 as a double


% --- Executes during object creation, after setting all properties.
function edit_2_pot_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_pot_2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_pot_2 as text
%        str2double(get(hObject,'String')) returns contents of edit_2_pot_2 as a double


% --- Executes during object creation, after setting all properties.
function edit_2_pot_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_pot_3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_pot_3 as text
%        str2double(get(hObject,'String')) returns contents of edit_2_pot_3 as a double


% --- Executes during object creation, after setting all properties.
function edit_2_pot_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_pot_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_pot_x as text
%        str2double(get(hObject,'String')) returns contents of edit_2_pot_x as a double


% --- Executes during object creation, after setting all properties.
function edit_2_pot_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_pot_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_pot_y as text
%        str2double(get(hObject,'String')) returns contents of edit_2_pot_y as a double


% --- Executes during object creation, after setting all properties.
function edit_2_pot_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_pot_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_2_pot_t as text
%        str2double(get(hObject,'String')) returns contents of edit_2_pot_t as a double


% --- Executes during object creation, after setting all properties.
function edit_2_pot_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2_pot_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_pot_1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_pot_1 as text
%        str2double(get(hObject,'String')) returns contents of edit_1_pot_1 as a double


% --- Executes during object creation, after setting all properties.
function edit_1_pot_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_pot_2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_pot_2 as text
%        str2double(get(hObject,'String')) returns contents of edit_1_pot_2 as a double


% --- Executes during object creation, after setting all properties.
function edit_1_pot_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_pot_3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_pot_3 as text
%        str2double(get(hObject,'String')) returns contents of edit_1_pot_3 as a double


% --- Executes during object creation, after setting all properties.
function edit_1_pot_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_pot_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_pot_x as text
%        str2double(get(hObject,'String')) returns contents of edit_1_pot_x as a double


% --- Executes during object creation, after setting all properties.
function edit_1_pot_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_pot_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_pot_y as text
%        str2double(get(hObject,'String')) returns contents of edit_1_pot_y as a double


% --- Executes during object creation, after setting all properties.
function edit_1_pot_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_1_pot_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_1_pot_t as text
%        str2double(get(hObject,'String')) returns contents of edit_1_pot_t as a double


% --- Executes during object creation, after setting all properties.
function edit_1_pot_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1_pot_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_plot_lvdt.
function checkbox_plot_lvdt_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_lvdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_lvdt
handles.plot.lvdt = get(hObject, 'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_plot_pot.
function checkbox_plot_pot_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_pot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_pot
handles.plot.pots = get(hObject, 'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_plot_BPMs.
function checkbox_plot_BPMs_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_BPMs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_BPMs
handles.plot.bpms = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes on button press in checkbox_plot_des.
function checkbox_plot_des_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_des
handles.plot.des = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_1_trim.
function pushbutton_1_trim_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1_trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(1);
response = questdlg(sprintf('This will use POT readbacks on %s to trim the motors to desired angles:\nCam 1 = %.3f\nCam 2 = %.3f\nCam 3 = %.3f\nOK to proceed?', ...
    handles.names{mx}, handles.des.cam(mx,1), handles.des.cam(mx,2), handles.des.cam(mx,3)), ...
    'Confirm offset fudge', 'OK', 'Cancel', 'OK');
if strcmp(response, 'OK')
    set(hObject, 'String', 'Trimming');
    handles = pushbutton_1_go_Callback(handles.pushbutton_1_go, [], handles);
    lcaSetMonitor(handles.pvs.potpos(1,:)');
    for ix = 1:20
        lcaNewMonitorWait(handles.pvs.potpos(mx,:)');
        pots(:,ix) = lcaGetSmart(handles.pvs.potpos(mx,:)');
        gui_statusDisp(handles, sprintf('Acquired POT readback %d / %d...', ix, 20));        
    end
    potpos = mean(pots, 2);
    potdiff = potpos - handles.des.cam(mx,:)';
    new_offset = handles.d.val.motroffs(mx,:)' + potdiff;
    gui_statusDisp(handles, sprintf('Setting %s motor offsets to [%.3f, %.3f, %.3f] ...', ...
        handles.names{mx}, new_offset(1), new_offset(2), new_offset(3)));
    lcaPutSmart(strcat(handles.pvs.motr(mx,:)', '.SET'), [1 1 1]');
    pause(0.5);
    lcaPutSmart(handles.pvs.motroffs(mx,:)', new_offset);
    pause(0.5);
    lcaPutSmart(strcat(handles.pvs.motr(mx,:)', '.SET'), [0 0 0]');
    pause(0.5);
    handles = calc_cam_des(handles);
    handles = update_gui(handles);
    handles = pushbutton_1_go_Callback(handles.pushbutton_1_go, [], handles);
    gui_statusDisp(handles, 'Trim completed');
    set(hObject, 'String', 'Trim');
end

guidata(hObject, handles);



% --- Executes on button press in pushbutton_2_trim.
function pushbutton_2_trim_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2_trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(1);
response = questdlg(sprintf('This will use POT readbacks on %s to trim the motors to desired angles:\nCam 1 = %.3f\nCam 2 = %.3f\nCam 3 = %.3f\nOK to proceed?', ...
    handles.names{mx}, handles.des.cam(mx,1), handles.des.cam(mx,2), handles.des.cam(mx,3)), ...
    'Confirm gold', 'OK', 'Cancel', 'OK');
if strcmp(response, 'OK')
    set(hObject, 'String', 'Trimming');
    handles = pushbutton_2_go_Callback(handles.pushbutton_2_go, [], handles);
    lcaSetMonitor(handles.pvs.potpos(mx,:)');
    for ix = 1:20
        lcaNewMonitorWait(handles.pvs.potpos(mx,:)');
        pots(:,ix) = lcaGetSmart(handles.pvs.potpos(mx,:)');
        gui_statusDisp(handles, sprintf('Acquired POT readback %d / %d...', ix, 20));        
    end
    potpos = mean(pots, 2);
    potdiff = potpos - handles.des.cam(mx,:)';
    new_offset = handles.d.val.motroffs(mx,:)' - potdiff;
    gui_statusDisp(handles, sprintf('Setting %s motor offsets to [%.3f, %.3f, %.3f] ...', ...
        handles.names{mx}, new_offset(1), new_offset(2), new_offset(3)));
    lcaPutSmart(strcat(handles.pvs.motr(mx,:)', '.SET'), [1 1 1]');
    pause(0.5);
    lcaPutSmart(handles.pvs.motroffs(mx,:)', new_offset);
    pause(0.5);
    lcaPutSmart(strcat(handles.pvs.motr(mx,:)', '.SET'), [0 0 0]');
    pause(0.5);
    handles = calc_cam_des(handles);
    handles = update_gui(handles);
    handles = pushbutton_2_go_Callback(handles.pushbutton_2_go, [], handles);
    gui_statusDisp(handles, 'Trim completed');
    set(hObject, 'String', 'Trim');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerObj;

stop(timerObj);
delete(timerObj);
% Hint: delete(hObject) closes the figure
util_appClose(hObject);



function edit_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_refresh as text
%        str2double(get(hObject,'String')) returns contents of edit_refresh as a double
global timerObj;

handles.refresh = str2double(get(handles.edit_refresh, 'String'));
stop(timerObj);
set(timerObj, 'Period', handles.refresh);
if get(handles.pushbutton_update, 'Value')
    start(timerObj);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_refresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_print.
function pushbutton_print_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerObj;
stop(timerObj);

fig = figure;

for ix = 1:2
    mx = handles.movers(ix);
    ax = subplot(1,2,ix);
    axis square;
    set(ax, 'XLim', [-3 3], 'YLim', [-3 3], 'XTick', [-3:1:3], 'YTick', [-3:1:3], 'XGrid', 'on', 'YGrid', 'on');
    handles = doplot(handles, mx, ax, 1);
    xlabel('X (mm)'); ylabel('Y (mm)');
    title(strcat(handles.names(mx)));

    leg = {};
    plothandles = [];

    if handles.plot.des
        leg = [leg; sprintf('Setpt = %+.2f, %+.2f, %+.2f', ...
            handles.des.real(mx,1), handles.des.real(mx,2), handles.des.real(mx,3))];
    end

    if handles.plot.lvdt
        leg = [leg; sprintf('LVDT  = %+.2f, %+.2f, %+.2f', ...
            handles.lvdt.real(mx,1), handles.lvdt.real(mx,2), handles.lvdt.real(mx,3))];
    end    

    if handles.plot.pots
        leg = [leg; sprintf('Pots  = %+.2f, %+.2f, %+.2f', ...
            handles.pots.real(mx,1), handles.pots.real(mx,2), handles.pots.real(mx,3))];
    end
    
    if handles.plot.gold
        leg = [leg; sprintf('Gold  = %+.2f, %+.2f, %+.2f', ...
            handles.gold.real(mx,1), handles.gold.real(mx,2), handles.gold.real(mx,3))];
    end
    
    if handles.plot.bpms
        leg = [leg; sprintf('BPMS  = %+.2f, %+.2f', ...
            handles.d.val.bpms(mx,1), handles.d.val.bpms(mx,2))];
    end
    
    h(ix) = legend(leg);
    set(h(ix), 'Fontsize', 10, 'FontName', 'FixedWidth', 'Location', 'NorthOutside', 'Box', 'off');
end

txtstr = sprintf('%s setpoint is [%+.2f, %+.2f, %+.2f] (X, Y, roll)\n%s setpoint is [%+.2f, %+.2f, %+.2f] (X, Y, roll)', ...
    handles.names{handles.movers(1)}, handles.des.real(handles.movers(1),1), ...
    handles.des.real(handles.movers(1),2), handles.des.real(handles.movers(1),3), ...
    handles.names{handles.movers(2)}, handles.des.real(handles.movers(2),1), ...
    handles.des.real(handles.movers(2),2), handles.des.real(handles.movers(2),3));

util_printLog_wComments(fig, 'Matlab', ...
    char(strcat({'FACET Sextupole S'}, num2str(handles.family), {'E positions'})), txtstr);

pause(handles.refresh);
start(timerObj);

% --- Executes on button press in checkbox_disable.
function checkbox_disable_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_disable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerObj;
stop(timerObj);

% Hint: get(hObject,'Value') returns toggle state of checkbox_disable
handles.enable = ~get(hObject, 'Value');
guidata(hObject, handles);

pause(handles.refresh);
start(timerObj);


% --- Executes on button press in checkbox_server.
function checkbox_server_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerObj;
stop(timerObj);

% Hint: get(hObject,'Value') returns toggle state of checkbox_server
handles.server = get(hObject, 'Value');
[stat, hostname] = system('hostname');
if handles.server
    gui_statusDisp(handles, strcat({'Server mode enabled on '}, hostname));
    enablestr = 'off';
else
    gui_statusDisp(handles, strcat({'Server mode disabled on '}, hostname));
    enablestr = 'on';
end

% get current PV state
vals = lcaGetStruct(handles.pvs);
setpoints = vals.setpoint;

% enable/disable GUI controls
dims = {'x' 'y' 't'};
for ix = 1:2
    for jx = 1:3
        hedit = strcat('edit_', num2str(ix), '_', char(dims(jx)), 'des');
        set(handles.(hedit), 'Enable', enablestr);
        setpoints(ix, jx) = str2double(get(handles.(hedit), 'String'));
    end
    set(handles.(strcat('pushbutton_', num2str(ix), '_go')), 'Enable', enablestr);
end

% update control PVs with current GUI values
if handles.server
    %lcaPutSmart(reshape(handles.pvs.setpoint, [], 1), reshape(setpoints, [], 1));
end

drawnow;
guidata(hObject, handles);

if get(handles.pushbutton_update, 'Value')
    start(timerObj);
end




function edit_roll_scale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roll_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.roll_scale = str2double(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_roll_scale as text
%        str2double(get(hObject,'String')) returns contents of edit_roll_scale as a double


% --- Executes during object creation, after setting all properties.
function edit_roll_scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_roll_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_plot_gold.
function checkbox_plot_gold_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_gold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plot.gold = get(hObject, 'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_gold


% --- Executes on button press in pushbutton_1_gold.
function pushbutton_1_gold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1_gold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(1);
response = questdlg(sprintf('This will set the GOLD values for %s to:\nX = %.3f\nY=%.3f\nROLL=%.3f\nOK to proceed?', ...
    handles.names{mx}, handles.des.real(mx,1), handles.des.real(mx,2), handles.des.real(mx,3)), ...
    'Confirm gold', 'OK', 'Cancel', 'OK');
if strcmp(response, 'OK')
    lcaPutSmart(handles.pvs.gold(mx,:)', handles.des.real(mx,:)');
end

% --- Executes on button press in pushbutton_1_gotogold.
function pushbutton_1_gotogold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1_gotogold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(1);
golds = handles.gold.real(mx,:)';
response = questdlg(sprintf('This will move %s to:\nX = %.3f\nY=%.3f\nROLL=%.3f\nOK to proceed?', ...
    handles.names{mx}, golds(1), golds(2), golds(3)), ...
    'Confirm goto', 'OK', 'Cancel', 'OK');
if strcmp(response, 'OK')
    coords = {'x' 'y' 't'};
    for ix = 1:3
        set(handles.(strcat('edit_1_', coords{ix}, 'des')), ...
            'String', num2str(handles.gold.real(mx,ix)));
    end
    handles = calc_cam_des(handles);
    handles = update_gui(handles);
    handles = pushbutton_1_go_Callback(handles.pushbutton_1_go, [], handles);
end

% --- Executes on button press in pushbutton_2_gold.
function pushbutton_2_gold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2_gold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(2);
response = questdlg(sprintf('This will set the GOLD values for %s to:\nX = %.3f\nY=%.3f\nROLL=%.3f\nOK to proceed?', ...
    handles.names{mx}, handles.des.real(mx,1), handles.des.real(mx,2), handles.des.real(mx,3)), ...
    'Confirm gold', 'OK', 'Cancel', 'OK');
if strcmp(response, 'OK')
    lcaPutSmart(handles.pvs.gold(mx,:)', handles.des.real(mx,:)');
end

% --- Executes on button press in pushbutton_2_gotogold.
function pushbutton_2_gotogold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2_gotogold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mx = handles.movers(2);
golds = handles.gold.real(mx,:)';
response = questdlg(sprintf('This will move %s to:\nX = %.3f\nY=%.3f\nROLL=%.3f\nOK to proceed?', ...
    handles.names{mx}, golds(1), golds(2), golds(3)), ...
    'Confirm goto', 'OK', 'Cancel', 'OK');
if strcmp(response, 'OK')
    coords = {'x' 'y' 't'};
    for ix = 1:3
        set(handles.(strcat('edit_2_', coords{ix}, 'des')), ...
            'String', num2str(handles.gold.real(mx,ix)));
    end
    handles = calc_cam_des(handles);
    handles = update_gui(handles);
    handles = pushbutton_2_go_Callback(handles.pushbutton_2_go, [], handles);
end



function uipanel10_SelectionChangeFcn(hObject, eventdata, handles)

