function varargout = BC2_match(varargin)
% BC2_MATCH MATLAB code for BC2_match.fig
%      BC2_MATCH, by itself, creates a new BC2_MATCH or raises the existing
%      singleton*.
%
%      H = BC2_MATCH returns the handle to a new BC2_MATCH or the handle to
%      the existing singleton*.
%
%      BC2_MATCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BC2_MATCH.M with the given input arguments.
%
%      BC2_MATCH('Property','Value',...) creates a new BC2_MATCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BC2_match_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BC2_match_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BC2_match

% Last Modified by GUIDE v2.5 30-Jul-2021 16:09:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BC2_match_OpeningFcn, ...
                   'gui_OutputFcn',  @BC2_match_OutputFcn, ...
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


% --- Executes just before BC2_match is made visible.
function BC2_match_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BC2_match (see VARARGIN)

% Choose default command line output for BC2_match
handles.output = hObject;

handles.PV = ['QUAD:LI24:501:    '
              'QUAD:LI24:601:    '
              'QUAD:LI24:701:    '
              'QUAD:LI24:713:    '
              'QUAD:LI24:892:    '
              'QUAD:LI24:901:    '
              'QUAD:LI25:201:    '
              'QUAD:LI25:301:    '
              'QUAD:LI25:401:    '
              'QUAD:LI25:501:    '];    % partial PV names for LI24-LI25 quads (in BC2 area)

%            QuadName  Leff/m     K0(5,-0.5)   K4(2.5/0) K5(2.0/0) K6(3.0/0) K7(4.0/0) K8(5.0/0) K9(8./0) K10(as)
%================================================================================================================
handles.M = {'Q24501' 0.10680  -0.93167508116  -0.9088   -0.8559   -0.9212   -0.9239   -0.9103   -0.9236  -0.9241
             'Q24601' 0.10680   0.60316058417   0.3230    0.1756    0.4146    0.5342    0.6103    0.7507   0.8468
             'Q24701' 0.10680  -1.28603013804  -1.2963   -1.2392   -1.3038   -1.2909   -1.2667   -1.2541  -1.1919
             'QM21  ' 0.46092   0.50811530935   0.5195    0.5143    0.5163    0.5059    0.4943    0.4737   0.4876
             'QM22  ' 0.46092  -0.59041898063  -0.6194   -0.7142   -0.5391   -0.4158   -0.3349   -0.3049  -0.6651
             'Q24901' 0.10680   1.08204224509   1.1718    1.4756    0.9316    0.5895    0.3791    0.3059   1.3291
             'Q25201' 0.10680   0.69799359257   0.8251    0.8344    0.8118    0.7852    0.7591    0.6775   0.4652
             'Q25301' 0.10680  -0.47838822637  -0.5128   -0.5274   -0.4946   -0.4684   -0.4481   -0.4200  -0.4942
             'Q25401' 0.10680   0.42896785871   0.4410    0.4460    0.4346    0.4253    0.4179    0.4144   0.4348
             'Q25501' 0.10680  -0.39986495651  -0.4032   -0.4046   -0.4014   -0.3988   -0.3968   -0.3958  -0.4015};

[r,c] = size(handles.M);

handles.K = zeros(r,c-2);
handles.L = cell2mat(handles.M(:,2));       % effective magnetic length (m)
handles.K(:,1) = cell2mat(handles.M(:,3));  % K values for 1-nC nominal setup
handles.K(:,2) = cell2mat(handles.M(:,4));
handles.K(:,3) = cell2mat(handles.M(:,5));
handles.K(:,4) = cell2mat(handles.M(:,6));
handles.K(:,5) = cell2mat(handles.M(:,7));
handles.K(:,6) = cell2mat(handles.M(:,8));
handles.K(:,7) = cell2mat(handles.M(:,9));
handles.K(:,8) = cell2mat(handles.M(:,10));

handles.Brho  = 1E10/2.99792458E8;
handles.k = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BC2_match wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BC2_match_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in read.
function read_Callback(hObject, eventdata, handles)
% hObject    handle to read (see GCBO)

[rpv,cpv] = size(handles.PV);

PV = handles.PV;
handles.PVB = PV;
handles.PVE = PV;

for j = 1:rpv
  handles.PVE(j,:) = [PV(j,1:(cpv-4)) 'EDES'];    % PV names for EDES
  handles.PVB(j,:) = [PV(j,1:(cpv-4)) 'BDES'];    % PV names for BDES
end
handles.BDES = lcaGetSmart(handles.PVB);    % present lengt-integrated gradient (kG)
handles.EDES = lcaGetSmart(handles.PVE);    % present energy at each quad (GeV)

k = handles.k;
handles.BDES0 = handles.K(:,1).*handles.L.*handles.EDES*handles.Brho;   % design BDES for the present energy (kG)
handles.BDESj = handles.K(:,k).*handles.L.*handles.EDES*handles.Brho;   % new BDES
disp(' ')
disp('QuadName  EDES   BDES0  BDESj')
disp('==============================')
s = get(handles.K_select,'string');
todisp = {s{get(handles.K_select,'value')};...
    ' '; 'QuadName    EDES     BDES0    BDESj';'========================'};
for j=1:rpv
  fprintf('%s   %5.3f  %6.3f %6.3f\n',handles.M{j,1},handles.EDES(j),handles.BDES0(j),handles.BDESj(j));    % list results to screen
  todisp = [todisp;...
      sprintf('%s    %5.3f    %6.3f    %6.3f',handles.M{j,1},handles.EDES(j),handles.BDES0(j),handles.BDESj(j))];    % list results to string
end
set(handles.set,'Enable','on')
set(handles.trimall,'Enable','on')
set(handles.DISPEDIT,'string',todisp);
guidata(hObject, handles);


% --- Executes on button press in set.
function set_Callback(hObject, eventdata, handles)
% hObject    handle to set (see GCBO)
goahead = questdlg('Change the BC2 quad BDES values to BDESj?', ...
 'BC2 Match', ...
 'Yes', 'No', 'No');
if strcmp(goahead,'No')
        return
end
disp_log('Setting BC2 quad BDES values...');
lcaPutSmart(handles.PVB,handles.BDESj);    % set, but don't trim new BDES values
PVB = handles.PVB
BDESj = handles.BDESj

guidata(hObject, handles);

% --- Executes on selection change in K_select.
function K_select_Callback(hObject, eventdata, handles)
% hObject    handle to K_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns K_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from K_select

contents = cellstr(get(hObject,'String'));
kstr = contents{get(hObject,'Value')};
handles.k = str2num(kstr(1));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function K_select_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DISPEDIT_Callback(hObject, eventdata, handles)
% hObject    handle to DISPEDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DISPEDIT as text
%        str2double(get(hObject,'String')) returns contents of DISPEDIT as a double


% --- Executes during object creation, after setting all properties.
function DISPEDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPEDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trimall.
function trimall_Callback(hObject, eventdata, handles)
% hObject    handle to trimall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goahead = questdlg('Trim BC2 quads to BDES?', ...
 'BC2 Match', ...
 'Yes', 'No', 'No');
if strcmp(goahead,'No')
        return
end
[rpv,cpv] = size(handles.PV);
PV = cell(rpv,1);
for j = 1:rpv
  PV{j,1} = [handles.PV(j,1:(cpv-5)) ];    % PV names for EDES
end
disp_log('Trimming BC2 quadrupoles...');
control_magnetSet(PV,[],'action','TRIM')
