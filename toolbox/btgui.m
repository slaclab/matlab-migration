function varargout = btgui(varargin)
%BTGUI M-file for btgui.fig
%      BTGUI, by itself, creates a new BTGUI or raises the existing
%      singleton*.
%
%      H = BTGUI returns the handle to a new BTGUI or the handle to
%      the existing singleton*.
%
%      BTGUI('Property','Value',...) creates a new BTGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to btgui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      BTGUI('CALLBACK') and BTGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in BTGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help btgui

% Last Modified by GUIDE v2.5 29-Nov-2011 17:43:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @btgui_OpeningFcn, ...
                   'gui_OutputFcn',  @btgui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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

% --- Executes just before btgui is made visible.
function btgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
% UIWAIT makes btgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Choose default command line output for btgui
handles.output = hObject;

global modelSource
aidainit;

handles.ScanComplete = 0;

% Get current machine server (FACET or LCLS)
[handles.sys,handles.accel]=getSystem;
disp(['Running for ',handles.accel,' beamline.'])
if strcmp(handles.accel,'FACET')
    set([handles.offset,handles.undo],'Visible','off');
    model_init('source', 'SLC');
end

[handles.BPMS.names, handles.BPMS.pos] = model_devlist('BPMS',handles.accel);
[handles.XCOR.names, handles.XCOR.pos] = model_devlist('XCOR',handles.accel);
[handles.YCOR.names, handles.YCOR.pos] = model_devlist('YCOR',handles.accel);

set(handles.QMAX,'String',2);
set([handles.XMAX,handles.YMAX],'String',0.004);
set(handles.numSteps,'String',9);
set(handles.numAve,'String',10);
set([handles.offset,handles.undo],'Enable','off');

% Update handles structure
guidata(hObject, handles);


function varargout = btgui_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function btgui_CloseRequestFcn(hObject, eventdata, handles)
% --- Executes when user attempts to close test_btplot.

% Hint: delete(hObject) closes the figure 
delete(gcf); 

% exit from Matlab when not running the desktop 
if usejava('desktop') 
  % don't exit from Matlab
else
  exit 
end


function START_SCAN_Callback(hObject, eventdata, handles)
% --- Executes on button press in START_SCAN.
%
% hObject    handle to START_SCAN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.DANGER = 1; % Value of 0 sets gui to Safe Mode - No beam devices will be altered
handles.ScanComplete = 0;
set(handles.ErrorMsg,'String',[],'Visible','off')

Proceed = questdlg('Warning!  Doing this will effect the steering of the beam. Are you sure you wish to proceed?', ...
                   'Warning!', 'Yes', 'No', 'No');
if strcmp(Proceed,'No')
    disp('Scan Aborted!')
    return
end

if isempty(get(handles.Man_QUAD,'STRING'))
    msgbox('Please choose a quad to scan.','Scan Warning','error');
    return
elseif isempty(get(handles.Man_QUAD_BPM,'STRING')) || isempty(get(handles.Man_TARGET_BPM,'STRING'))
    msgbox('Please choose BPMs to scan.','Scan Warning','error');
    return
elseif isempty(get(handles.Man_XCOR,'STRING')) && isempty(get(handles.Man_YCOR,'STRING'))
    msgbox('Please choose corrector to scan.','Scan Warning','error');
    return
else
    [maglist, samplist, ranges] = scan_array(hObject, handles);
end

% Set initial scan parameters
corrsteps = str2double(get(handles.numSteps,'String'));
numave = str2double(get(handles.numAve,'String'));
if isnan(ranges(1))
    ranges(1) = 2;
end
if isnan(ranges(2))
    ranges(2) = 0.004;
end
if handles.DANGER
%    try
        % Launch StripTool for selected Boost supply sector
        if get(handles.striptool,'Value')
            limopts = ' ';
            lgps = [];
            if strcmp(handles.accel,'FACET')
                limopts = 'l ';
                lgps = [maglist{1}(1:4),':LGPS:1:IACT '];
            end
            stcmd=['/usr/local/lcls/tools/script/quickSTP -x',limopts,maglist{1},':BACT ',maglist{2},':BACT ',lgps,'&'];
            unix(stcmd)
            pause(0.1)  % Pause to let system command finish
        end
        
        disp_log(['Starting bow tie scan for quad ',maglist{1},'.'])  % print msg to cmLog on start
        set(hObject,'String','Scanning...','BackgroundColor','white');
        set([handles.START_SCAN,handles.SCAN_X,handles.SCAN_Y,handles.Man_QUAD,handles.Man_XCOR, ...
            handles.Man_YCOR,handles.Man_TARGET_BPM,handles.Man_QUAD_BPM,handles.GetModel,handles.offset, ...
            handles.SCAN_X,handles.SCAN_Y,handles.QMAX,handles.XMAX,handles.YMAX,handles.striptool],'Enable','off');
        % Launch Howard's scan function and return figure and data
        if strcmp(handles.accel,'LCLS')
            [handles.data,handles.fig] = scanbowtie(maglist{1}, maglist{2}, samplist{1}, samplist{2}, ...
                                                    corrsteps, ranges(2), ranges(1), numave);
        else
            [handles.data,handles.fig] = facet_scanbowtie(maglist{1}, maglist{2}, samplist, ...
                                                          corrsteps, ranges(2), ranges(1), numave);
        end
        if isempty(handles.data)
            errordlg('Error occured, scan unable to proceed!  Check if magnets are restored and see xterm for further info.')
            reset_Controls(hObject, eventdata, handles);
            return
        end
%     catch
%         set(handles.ErrorMsg,'String','Aida error, Scan Aborted!  Check magnets!','Visible','on');
%         reset_Controls(hObject, eventdata, handles);
%         return
%     end
    disp_log(['Bow tie scan for quad ',maglist{1},' successfully finished.'])  % print msg to cmLog on end
else
    disp('Using Safe Mode...')
    maglist{1}, maglist{2}, samplist{1}, samplist{2} %#ok<NOPRT,NOPRT>
    corrsteps, ranges(2), ranges(1), numave %#ok<NOPRT>
    handles.fig = figure;
    [X,Y,Z] = peaks(30);
    surfc(X,Y,Z)
    if get(handles.striptool,'Value')
        stcmd=['!/usr/local/lcls/tools/script/quickSTP -x ',maglist{1}, ':BACT ',maglist{2}, ':BACT &'];
        disp(stcmd)
        eval(stcmd);
    end
end

reset_Controls(hObject, eventdata, handles);
        
disp('Scan completed!')
handles.ScanComplete = 1;

guidata(hObject, handles);


function reset_Controls(hObject, eventdata, handles)
% Return all gui statuses to initial state
set(handles.START_SCAN,'String','Start','BackgroundColor','green','Value',0);
set([handles.START_SCAN,handles.SCAN_X,handles.SCAN_Y,handles.Man_QUAD,handles.Man_XCOR, ...
     handles.Man_YCOR,handles.Man_TARGET_BPM,handles.Man_QUAD_BPM,handles.GetModel,handles.offset, ...
     handles.SCAN_X,handles.SCAN_Y,handles.QMAX,handles.XMAX,handles.YMAX,handles.striptool],'Enable','on');
set(handles.undo,'Enable','off')


function offset_Callback(hObject, eventdata, handles)
% --- Executes on button press in offset.
%
% hObject    handle to offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set active plane and generate offset PV name
switch handles.plane
    case 'X'
        secondary = ':XAOFF';
    case 'Y'
        secondary = ':YAOFF';
    otherwise
        disp('No plane recognized!')
        return
end

devname = get(handles.Man_QUAD_BPM,'String');
handles.old_offset = lcaGet([devname,secondary]);
offsetdiff = handles.old_offset - handles.data.center;

%  Check that new offset error is within 20% of difference 
if handles.data.dcenter <= (0.2*offsetdiff)
    warning = 'Proceed?';
else
    warning = 'Warning!  Offset error is LARGE! Proceed?';
end

query = questdlg({['This will set the BPM offset for ',devname], ...
                  [' to ',num2str(offsetdiff),' from the current value of ',num2str(handles.old_offset),'.'], ...
                  [],warning},'Warning!','Yes','No','No');

if strcmp(query,'Yes')
    try
       lcaPut([devname,secondary],offsetdiff)  % If Proceed, set new offset value in channel access
    catch
        disp('Error occurred while setting offset!  Please check values and set by hand.')
        errstr = ['Error writing to ',devname,secondary,'.  Process aborting!'];
        disp_log(errstr)  % print msg to cmLog on error
        set(handles.ErrorMsg,'String',errstr,'Visible','on')
        return
    end
       disp('Offset succesfully updated!')
       set(handles.undo,'Enable','on')
       set(handles.offset,'Enable','off')
       logmsg = ['Changed BPM offset for ',devname,' from ', ...
                 num2str(handles.old_offset),' to ',num2str(offsetdiff)];
       disp_log(logmsg)  % print msg to cmLog of change
end

guidata(hObject,handles);


function undo_Callback(hObject, eventdata, handles)
% --- Executes on button press in undo.
%
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set active plane and generate offset PV name
switch handles.plane
    case 'X'
        secondary = ':XAOFF';
    case 'Y'
        secondary = ':YAOFF';
    otherwise
        disp('No plane recognized!')
        return
end
devname = get(handles.Man_QUAD_BPM,'String');
current_offset = lcaGet([devname,secondary]);

query = questdlg({['This will re-set the BPM offset for ',devname,' to ',num2str(handles.old_offset),'.'], ...
                  [],'Are you sure you wish to proceed?'},'Warning!','Yes','No','No');

%err = Err.getInstance('btgui'); % Initiate cmLog error printing.

if strcmp(query,'Yes')
    try
        lcaPut([devname,secondary],handles.old_offset)  % If Proceed, set new offset value in channel access
    catch
        disp('Error occurred while resetting offset!  Please check values and reset by hand.')
        errstr = ['Error writing to ',devname,secondary,'.  Process aborting!'];
        disp_log(errstr)  % print msg to cmLog on error
        set(handles.ErrorMsg,'String',errstr,'Visible','on')
        return
    end
       disp('Offset succesfully updated!')
       set(handles.undo,'Enable','off')
       set(handles.offset,'Enable','on')
       logmsg = ['Changed BPM offset for ',devname,' from ', ...
                 num2str(current_offset),' to ',num2str(handles.old_offset)];
       disp_log(logmsg)  % print msg to cmLog of change
end


function LOGBOOK_Callback(hObject, eventdata, handles)
% --- Executes on button press in LOGBOOK.
%
% hObject    handle to LOGBOOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set Logbook to print to and folder to save data
util_dataSave(handles, 'bowtie', get(handles.Man_QUAD,'STRING'), now);

opts.title = ['Bowtie data for ', get(handles.Man_QUAD,'STRING')];
opts.author = 'MATLAB';
if get(handles.SCAN_X, 'value')
    opts.text = ['Corrector scanned: ', get(handles.Man_XCOR,'STRING')];
else
    opts.text = ['Corrector scanned: ', get(handles.Man_YCOR,'STRING')];
end
util_printLog(handles.fig, opts)


function [maglist, samplist, ranges] = scan_array(hObject, handles)
% Creates cell array of devices (datalist) to pass to scan function
% maglist - 1st cell (i.e. maglist(1) is the quadrupole to be scanned
%           2nd cell is the XCOR if scanning the x-plane 
%           3rd cell is the YCOR if scanning the y-plane
% samplist - lists all of the BPMs to be sampled during the scan in cells
% modes - lists whether the quad and correctors are LCLS or SLC type
%         0 = SLC, 1 = EPICS, [] = Plane not selected
% ranges - 2x3 array of magnet mins (col1) and maxes (col2)
%          1st row is QUAD range, 2nd is XCOR, 3rd is YCOR

%%%%%%% HVS - took out MINs, MAXs are actually just range values %%%%%%%
if get(handles.SCAN_X,'Value')
    maglist{1} = get(handles.Man_QUAD,'STRING');
    maglist{2} = get(handles.Man_XCOR,'STRING');
    ranges = [str2double(get(handles.QMAX,'STRING')); ...
              str2double(get(handles.XMAX,'STRING'))];
elseif get(handles.SCAN_Y,'Value')
    maglist{1} = get(handles.Man_QUAD,'STRING');
    maglist{2} = get(handles.Man_YCOR,'STRING');
    ranges = [str2double(get(handles.QMAX,'STRING')); ...
              str2double(get(handles.YMAX,'STRING'))];
else
    maglist = [];
end

samplist{1} = get(handles.Man_QUAD_BPM,'String');
if strcmp(handles.accel,'LCLS')
    samplist{2} = get(handles.Man_TARGET_BPM,'String');
else
    % Find 6 BPMs around model selection to make sure scan gets good data
    model_ind = find(strcmp(handles.BPMS.names,get(handles.Man_TARGET_BPM,'String')));
    start_ind = model_ind - 2;
    for i=0:5
        samplist{2+i} = handles.BPMS.names{start_ind+i};
    end
end


function [name, init] = mag_chk(name,type,handles)
% mag_chk checks model_nameConvert for device name to decide if it is an SLC or
%   EPICS type PV and returns the proper name, BDES for magnets, mode (0
%   for SLC, 1 for EPICS), and a success bit.
name = char(upper(name));
if ~isempty(name)
    % Format PV name and remove any secondaries
    if strfind(name,type)
        n_colon = find(name == ':');
        if length(n_colon) > 2; name = name(1:(n_colon(3)-1));end   
        [name, stat, isSLC] = model_nameConvert(name, 'EPICS');
        if ~isSLC && name(1) ~= type
            name = [name(6:9),':',name(1:4),name(10:end)];
        end
        
        % If device is magnet, retrieve current BDES
        if strcmp(type,'B')
            init = [];
        else
            init = sprintf('%3.4f',lcaGetSmart([name,':BDES']));
            % Format exponential notation
            init = strrep(init,'e+0','e+');
            init = strrep(init,'e-0','e-');
        end
    else
        msgbox('Device entered is not of correct type, please check PV!','Scan Warning','error')
        init = [];
    end
else
    init = [];
end


function modelcheck(hObject, eventdata, handles)

quad = get(handles.Man_QUAD,'STRING'); 
if get(handles.GetModel,'Value') && ~isempty(quad)
   if get(handles.SCAN_X,'Value') || get(handles.SCAN_Y,'Value')
       disp('Querying Model for optimal devices for Quad...')
       
       set([handles.Man_QUAD_BPM,handles.Man_TARGET_BPM,handles.Man_XCOR,handles.Man_YCOR], ...
           'String','Finding device ...','BackgroundColor','red'); pause(0.1)
       try
           [target_bpm, corrector, quad_bpm] = rmat_device(char(quad),handles);
       catch
           disp_log('Model query failed, check PV name.')
           set([handles.Man_QUAD_BPM, handles.Man_TARGET_BPM,...
                handles.Man_XCOR,handles.Man_YCOR],'String',[],'BackgroundColor','white');
           set([handles.XDES, handles.YDES],'String',[]);
           return
       end
       
       disp('Model query successful!')
       set(handles.Man_QUAD_BPM,'String',deblank(char(quad_bpm)),'BackgroundColor','white');
       set(handles.Man_TARGET_BPM,'String',deblank(char(target_bpm)),'BackgroundColor','white');
       
       if get(handles.SCAN_X,'Value')
           set(handles.Man_XCOR,'String',deblank(char(corrector)),'BackgroundColor','white');
           set(handles.Man_YCOR,'String',[],'BackgroundColor','white');
           Man_XCOR_Callback(hObject,eventdata,handles);
       else
           set(handles.Man_YCOR,'String',deblank(char(corrector)),'BackgroundColor','white');
           set(handles.Man_XCOR,'String',[],'BackgroundColor','white');
           Man_YCOR_Callback(hObject,eventdata,handles);
       end
   end
end


function [target_bpm, corrector, qbpm] = rmat_device(QUAD,handles)
%   Given a PV for a quadrupole magnet in the linac, rmat_device will
%   return a corrector and a target bpm for use in a bowtie plot based on
%   optimal R-matrix values from the MAD model.
%   QUAD PV must contain Sector, Primary, and Unit in correct SLC format.
%   status returns status bit on success (= 0), and err_msg returns a
%   failure message for any faults if status = 1.
%
%   Current Issues:
%   - Currently this functions will only work for one corrector at a time.
%
%   Function utilizes Henrik Loos' matlab model functions 'model_nameConvert'
%   and 'model_rMatGet'.
%
%   Author: Shawn Alverson
%   Modified: 08-Jul-2008

qbpm = [];
corrector = [];
target_bpm = [];

if get(handles.SCAN_X,'Value')
    index = 0;
else
    index = 2;
end

[rMat, Qpos] = model_rMatGet(QUAD); % Get QUAD Z-position

% Find QUAD BPM
qbpm = handles.BPMS.names(handles.BPMS.pos == Qpos);
if isempty(qbpm)
    disp(['No BPM at z-position for ',char(QUAD),'.  Using next best BPM...'])
    prev_bpm = handles.BPMS.pos(find(handles.BPMS.pos < Qpos,1,'last'));
    next_bpm = handles.BPMS.pos(find(handles.BPMS.pos > Qpos,1,'first'));  
    if abs(Qpos - next_bpm) > abs(Qpos - prev_bpm)
        qbpm = handles.BPMS.names(handles.BPMS.pos == prev_bpm);
        ind = find(handles.BPMS.pos == prev_bpm) + 1;
    else
        qbpm = handles.BPMS.names(handles.BPMS.pos == next_bpm);
        ind = find(handles.BPMS.pos == next_bpm) + 1;
    end
else
    ind = find(handles.BPMS.pos == Qpos) + 1;
end

% Find downstream BPM next
rMat = model_rMatGet(handles.BPMS.names(ind:ind+10),QUAD); % Gets full transfer matrix
MatCmp = 0;
for k = 1:10
  tmpmat = inv(rMat(:,:,k));
  MatCmp1 = abs(tmpmat(1+index,2+index));
  
  %   Look for largest R12 for x or R34 for y
  if MatCmp1 > MatCmp
    MatCmp = MatCmp1;
    target_bpm = handles.BPMS.names(ind+k);
  end  
end

% Now find upstream corrector
if get(handles.SCAN_X,'Value')
    corr = handles.XCOR.names;
    pos = handles.XCOR.pos;
else
    corr = handles.YCOR.names;
    pos = handles.YCOR.pos;
end
corr = corr(find(pos < Qpos,10,'last'));
ind = find(pos < Qpos,1,'last') + 1;
rMat = model_rMatGet(corr,QUAD); % Gets full transfer matrix
MatCmp = 0;
for k = 10:-1:1
  tmpmat = rMat(:,:,k);
  MatCmp1 = abs(tmpmat(1+index,2+index));
  
  %   Look for largest R12 for x or R34 for y
  if MatCmp1 > MatCmp
    MatCmp = MatCmp1;
    corrector = corr(k);
  end 
end


function Man_QUAD_Callback(hObject, eventdata, handles)
% hObject    handle to Man_QUAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ScanComplete = 0;

[name, init] = mag_chk(get(handles.Man_QUAD,'STRING'),'Q',handles);
set(handles.Man_QUAD,'STRING',name);
modelcheck(hObject, eventdata, handles)

set(handles.QDES,'STRING',init);

guidata(hObject, handles);


function Man_XCOR_Callback(hObject, eventdata, handles)
% hObject    handle to Man_XCOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ScanComplete = 0;

[name, init] = mag_chk(get(handles.Man_XCOR,'STRING'),'X',handles);

set(handles.Man_XCOR,'STRING',name);
set(handles.XDES,'STRING',init);

guidata(hObject, handles);


function Man_YCOR_Callback(hObject, eventdata, handles)
% hObject    handle to Man_YCOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ScanComplete = 0;

[name, init] = mag_chk(get(handles.Man_YCOR,'STRING'),'Y',handles);

set(handles.Man_YCOR,'STRING',name);
set(handles.YDES,'STRING',init);

guidata(hObject, handles);


function Man_QUAD_BPM_Callback(hObject, eventdata, handles)
% hObject    handle to Man_QUAD_BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ScanComplete = 0;

name = get(hObject,'String');

[name] = mag_chk(name,'B');
set(hObject,'STRING',name);

guidata(hObject, handles);


function Man_TARGET_BPM_Callback(hObject, eventdata, handles)
% hObject    handle to Man_TARGET_BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ScanComplete = 0;

name = get(hObject,'String');

[name] = mag_chk(name,'B');
set(hObject,'STRING',name);

guidata(hObject, handles);


function SCAN_X_Callback(hObject, eventdata, handles)
% --- Executes on button press in SCAN_X.
%
% hObject    handle to SCAN_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
  set(handles.Man_XCOR,'Visible','on');
  set(handles.SCAN_Y,'Value',0);
  handles.plane = 'X';
  set(handles.Man_YCOR,'Visible','off');
  set(handles.YDES,'String',[])
  pause(0.1)
  
  if ~isempty(get(handles.Man_QUAD,'String'))
     modelcheck(hObject, eventdata, handles)
     Man_XCOR_Callback(hObject, eventdata, handles)
  end  
else
  set(handles.Man_XCOR,'Visible','off')
  set(handles.SCAN_X,'Value',0);
end
guidata(hObject, handles);


function SCAN_Y_Callback(hObject, eventdata, handles)
% --- Executes on button press in SCAN_Y.
%
% hObject    handle to SCAN_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.SCAN_Y,'Value')
  set(handles.Man_YCOR,'Visible','on');
  set(handles.Man_XCOR,'Visible','off');
  handles.plane = 'Y';
  set(handles.SCAN_X,'Value',0);
  set(handles.XDES,'String',[])
  pause(0.1)
  
  if ~isempty(get(handles.Man_QUAD,'String'))
     modelcheck(hObject, eventdata, handles)
     Man_YCOR_Callback(hObject, eventdata, handles)
  end  
else
  set(handles.Man_YCOR,'Visible','off');
  set(handles.SCAN_Y,'Value',0);
end
guidata(hObject, handles);


function QMAX_Callback(hObject, eventdata, handles)
% hObject    handle to QMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function XMAX_Callback(hObject, eventdata, handles)
% hObject    handle to XMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function YMAX_Callback(hObject, eventdata, handles)
% hObject    handle to YMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function GetModel_Callback(hObject, eventdata, handles)
% hObject    handle to GetModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

modelcheck(hObject, eventdata, handles)


function [devlist, pos] = model_devlist(type,accel)

devlist = model_nameRegion(type, accel);     %Get all devices of 'type' for given machine
[rMat, pos] = model_rMatGet(devlist);        %Get relative z-positions for all devices from model
[devlist, pos] = cell_sort(devlist, pos);    %Sort device list based on z-position


function [out_cell, npos] = cell_sort(in_cell, pos)
% Sorts cell arrays based on relative position vector
out_cell = in_cell;
if length(in_cell) ~= length(pos)
    disp('Array size mismatch!')
    return
end

[npos, ind] = sort(pos);

for i = 1:length(in_cell)
    out_cell{i} = in_cell{ind(i)};
end


function striptool_Callback(hObject, eventdata, handles)
% --- Executes on button press in striptool.
%
% hObject    handle to striptool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of striptool
   

function numSteps_Callback(hObject, eventdata, handles)
% hObject    handle to numSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function numAve_Callback(hObject, eventdata, handles)
% hObject    handle to numAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%% Creation Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.

function Man_TARGET_BPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Man_TARGET_BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Man_QUAD_BPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Man_QUAD_BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Man_QUAD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Man_QUAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Man_XCOR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Man_XCOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Man_YCOR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Man_YCOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function QMAX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function XMAX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function YMAX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YMAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function QDES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function XDES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function YDES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function numAve_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end