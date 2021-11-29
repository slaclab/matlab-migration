function varargout = shift_save(varargin)
% SHIFT_SAVE M-file for shift_save.fig
%      SHIFT_SAVE, by itself, creates a new SHIFT_SAVE or raises the existing
%      singleton*.
%
%      H = SHIFT_SAVE returns the handle to a new SHIFT_SAVE or the handle to
%      the existing singleton*.
%
%      SHIFT_SAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHIFT_SAVE.M with the given input arguments.
%
%      SHIFT_SAVE('Property','Value',...) creates a new SHIFT_SAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before shift_save_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to shift_save_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help shift_save

% Last Modified by GUIDE v2.5 09-Aug-2007 17:20:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @shift_save_OpeningFcn, ...
                   'gui_OutputFcn',  @shift_save_OutputFcn, ...
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


% --- Executes just before shift_save is made visible.
function shift_save_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to shift_save (see VARARGIN)

% Choose default command line output for shift_save
handles.output = hObject;
set(handles.PV_LIST,'Visible','off')
set(handles.SAVEPVS,'Visible','off')
handles.newdata = 0;
handles.showdiffs = 0;
handles.dirstr = [getenv('MATLABDATAFILES') '/script/'];
handles.data_dirstr = [getenv('MATLABDATAFILES') '/script/savefiles/'];
if ~exist([handles.dirstr 'shift_save.mat'],'file')
  handles.pv_list = get(handles.PV_LIST,'String');
  set(handles.MSGBOX,'String','PV list file not found - using display list')
  set(handles.MSGBOX,'ForegroundColor','red')
else
  handles.load_cmnd = ['load ' handles.dirstr 'shift_save.mat'];
  eval(handles.load_cmnd)
  handles.pv_list = pv_list;
  set(handles.PV_LIST,'String',handles.pv_list)
  set(handles.MSGBOX,'String','PV list file loaded')
  set(handles.MSGBOX,'ForegroundColor','black')
end
Nfiles = update_filelist(handles);
set(handles.FILELIST1,'Value',Nfiles);
guidata(hObject, handles);

% UIWAIT makes shift_save wait for user response (see UIRESUME)
% uiwait(handles.FILELIST);


% --- Outputs from this function are returned to the command line.
function varargout = shift_save_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function PV_LIST_Callback(hObject, eventdata, handles)
handles.pv_list = get(handles.PV_LIST,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PV_LIST_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GETDATA.
function GETDATA_Callback(hObject, eventdata, handles)
filelist_visible = get(handles.FILELIST1,'Visible');
if strcmp(filelist_visible,'off')
  set(handles.MSGBOX,'String','Cannot get new data when "edit list" is ON')
  set(handles.MSGBOX,'ForegroundColor','red')
  return
end
handles.newdata = 1;
handles.datestring = datestr(now);
set(handles.MSGBOX,'String','working...')
set(handles.MSGBOX,'ForegroundColor','red')
drawnow
units_pv = handles.pv_list;
desc_pv  = handles.pv_list;
for j = 1:length(handles.pv_list)
  units_pv(j) = {[handles.pv_list{j} '.EGU']};
  desc_pv(j)  = {[handles.pv_list{j} '.DESC']};
end
handles.data   = lcaGet(handles.pv_list,1,'double');
handles.units  = lcaGet(units_pv,1,'char');
handles.desc   = lcaGet(desc_pv,1,'char');
handles = compare_data(handles);
handles = fill_data_display(handles);
guidata(hObject, handles);


function handles = compare_data(handles)
ifn = get(handles.FILELIST1,'Value');
fns = get(handles.FILELIST1,'String');
fn = [fns(ifn,:) '.mat'];
cmnd = ['load ' handles.data_dirstr fn];
eval(cmnd);     % load pv_list0 and data0
handles.data0 = 0*handles.data;
handles.i0 = 0*handles.data0;
n = length(handles.pv_list);
n0 = length(pv_list0);
cpv_list  = char(handles.pv_list);
cpv_list0 = char(pv_list0);
for j = 1:n
  i = find(cpv_list(j,:)==' ');
  if length(i)>0
    pvstr = cpv_list(j,1:(i(1)-1));
  else
    pvstr = cpv_list(j,:);
  end
  for jj = 1:n0
    i0 = find(cpv_list0(jj,:)==' ');
    if length(i0)>0
      pvstr0 = cpv_list0(jj,1:(i0(1)-1));
    else
      pvstr0 = cpv_list0(jj,:);
    end
    if strcmp(pvstr,pvstr0);
      handles.data0(j) = data0(jj);
      handles.i0(j) = 1;
      break
    end
  end
end

function handles = fill_data_display(handles)
pvtxt = char(handles.pv_list);
[r,c] = size(pvtxt);
table_text = char(zeros(r,2+24+1+c+4+11+1+11+1+15));
jflg = 0;
for j = 1:r
  desc = char(handles.desc{j});
  nd = 24 - length(desc);
  np = c - length(pvtxt(j,:));
  valu = sprintf('%0.5g',handles.data(j));
  nv = 11 - length(valu);
  if handles.i0(j)
    valu0 = sprintf('%0.5g',handles.data0(j));
  else
    valu0 = '?';
  end
  if strcmp(valu,valu0)
    flg = '  ';
  else
    flg = '* ';
  end
  nv0 = 11 - length(valu0);
  unit = char(handles.units{j});
  nu = 15 - length(unit);
  if ~handles.showdiffs
    if flg(1) == '*'
      jflg = jflg + 1;
    end
    table_text(j,:) = [flg desc blanks(nd) '(' pvtxt(j,:) ') = ' valu blanks(nv+1) valu0 blanks(nv0+1) unit blanks(nu)];
  else
    if flg(1) == '*'
      jflg = jflg + 1;
      table_text(jflg,:) = [flg desc blanks(nd) '(' pvtxt(j,:) ') = ' valu blanks(nv+1) valu0 blanks(nv0+1) unit blanks(nu)];
    end
  end
end
if jflg==0
  table_text = 'no differences';
end
datestring = handles.datestring;
set(handles.MSGBOX,'String',['New data taken ' datestring sprintf(': TOTAL=%3.0f, DIFF=%3.0f',r,jflg)])
set(handles.MSGBOX,'ForegroundColor','black')
set(handles.DATAVALUES,'String',table_text);


% --- Executes on button press in SAVEPVS.
function SAVEPVS_Callback(hObject, eventdata, handles)
yn = questdlg('This will over-write the present PV SAVE list.  Do you really want to do this?','CAUTION');
if strcmp(yn,'Yes')
  handles.pv_list = get(handles.PV_LIST,'String');
  pv_list = handles.pv_list;
  handles.save_cmnd = ['save ' handles.dirstr 'shift_save.mat pv_list'];
  eval(handles.save_cmnd)
  handles.pv_list = pv_list;
  set(handles.MSGBOX,'String','PV list file saved')
  set(handles.MSGBOX,'ForegroundColor','black')
else
  set(handles.MSGBOX,'String','file NOT saved')
  set(handles.MSGBOX,'ForegroundColor','black')
end
guidata(hObject, handles);


function DATAVALUES_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DATAVALUES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DATAUNITS_Callback(hObject, eventdata, handles)
set(handles.PV_LIST,'Visible','on')
set(handles.SAVEPVS,'Visible','on')
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DATAUNITS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EDITPVLIST.
function EDITPVLIST_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1
  set(hObject,'ForegroundColor','red')
  set(handles.PV_LIST,'Visible','on')
  set(handles.SAVEPVS,'Visible','on')
  set(handles.FILELIST1,'Visible','off')
  set(handles.FILELISTTITLE,'Visible','off')
else
  set(hObject,'ForegroundColor','black')
  set(handles.PV_LIST,'Visible','off')
  set(handles.SAVEPVS,'Visible','off')
  set(handles.FILELIST1,'Visible','on')
  set(handles.FILELISTTITLE,'Visible','on')
end
guidata(hObject, handles);


% --- Executes on button press in SAVEDATA.
function SAVEDATA_Callback(hObject, eventdata, handles)
if handles.newdata == 1
  ilist = get(handles.FILELIST1,'Value');
  fn = handles.datestring;
  handles.datestring = fn;
  i=find(fn==':' | fn==' ' | fn=='-');
  fn(i) = '_';
  data0 = handles.data;
  pv_list0 = handles.pv_list;
  datasave_cmnd = ['save ' handles.data_dirstr fn ' pv_list0 data0'];
  eval(datasave_cmnd)
%  set(handles.MSGBOX,'String','Data file saved')
%  set(handles.MSGBOX,'ForegroundColor','black')
  Nfiles = update_filelist(handles);
  set(handles.FILELIST1,'Value',ilist);
else
  set(handles.MSGBOX,'String','No new data to save')
  set(handles.MSGBOX,'ForegroundColor','red')
end
guidata(hObject, handles);


function Nfiles = update_filelist(handles)
fill_cmnd = ['file_names = dir(''' handles.data_dirstr ''');'];
eval(fill_cmnd);
sorted_names = sortrows({file_names.name}');
sorted_names(1:2) = [];
names = char(sorted_names);
Nfiles = length(sorted_names);
nf = zeros(Nfiles,1);
for j = 1:Nfiles
  d = datestr(names(j,1:11),26);
  nf(j) = datenum(str2int(d(1:4)),str2int(d(6:7)),str2int(d(9:10)),str2int(names(1,13:14)),str2int(names(1,16:17)),str2int(names(1,19:20)));
end
[nfs,inf] = sort(nf);
set(handles.FILELIST1,'String',names(inf,1:20));


% --- Executes on selection change in FILELIST1.
function FILELIST1_Callback(hObject, eventdata, handles)
Nfiles = update_filelist(handles);
if handles.newdata == 1
  handles = compare_data(handles);
  handles = fill_data_display(handles);
else
  set(handles.MSGBOX,'String','No new data to compare')
  set(handles.MSGBOX,'ForegroundColor','black')
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function FILELIST1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DELETEFILE.
function DELETEFILE_Callback(hObject, eventdata, handles)
filelist_visible = get(handles.FILELIST1,'Visible');
if strcmp(filelist_visible,'on')
  ifn = get(handles.FILELIST1,'Value');
  fns = get(handles.FILELIST1,'String');
  fn = [fns(ifn,:) '.mat'];
  yn = questdlg(['This will remove data file ' fn ' permanently.  Do you really want to do this?'],'CAUTION');
  if strcmp(yn,'Yes')
    cmnd = ['delete ' handles.data_dirstr fn];
    eval(cmnd)
    Nfiles = update_filelist(handles);
    set(handles.FILELIST1,'Value',Nfiles);
    set(handles.MSGBOX,'String','Data file deleted')
    set(handles.MSGBOX,'ForegroundColor','black')
  else
    set(handles.MSGBOX,'String','nothing deleted')
    set(handles.MSGBOX,'ForegroundColor','black')
  end
else
  set(handles.MSGBOX,'String','Cannot delete when "edit list" is ON')
  set(handles.MSGBOX,'ForegroundColor','red')
end
guidata(hObject, handles);


% --- Executes on button press in SHOWDIFFS.
function SHOWDIFFS_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1
  handles.showdiffs = 1;
  set(hObject,'ForegroundColor','red')
  set(handles.MSGBOX,'String','Now displaying only PVs with difference values')
  set(handles.MSGBOX,'ForegroundColor','red')
else
  handles.showdiffs = 0;
  set(hObject,'ForegroundColor','black')
  set(handles.MSGBOX,'String','Now displaying all PVs')
  set(handles.MSGBOX,'ForegroundColor','black')
end
if handles.newdata == 1
  handles = fill_data_display(handles);
end
guidata(hObject, handles);


% --- Executes when user attempts to close FILELIST.
function FILELIST_CloseRequestFcn(hObject, eventdata, handles)
delete (hObject);
if strcmp('/usr/local/lcls/tools/matlab/toolbox/shift_save.m', which('shift_save'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end
