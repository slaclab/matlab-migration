function varargout = stdzbsyltu(varargin)
% STDZBSYLTU M-file for stdzbsyltu.fig
%      STDZBSYLTU, by itself, creates a new STDZBSYLTU
%      or raises the existing
%      singleton*.
%
%      H = STDZBSYLTU returns the handle to a new STDZBSYLTU or the handle to
%      the existing singleton*.
%
%      STDZBSYLTU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STDZBSYLTU.M with the given input arguments.
%
%      STDZBSYLTU('Property','Value',...) creates a new STDZBSYLTU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stdzbsyltu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stdzbsyltu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stdzbsyltu

% Last Modified by GUIDE v2.5 29-Oct-2020 19:04:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stdzbsyltu_OpeningFcn, ...
                   'gui_OutputFcn',  @stdzbsyltu_OutputFcn, ...
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


% --- Executes just before stdzbsyltu is made visible.
function stdzbsyltu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stdzbsyltu (see VARARGIN)

% Choose default command line output for stdzbsyltu
handles.output = hObject;

% initialize the list of magnet PVs

%handles.magnetCTRL_PVs = {}; 
disp('Initializing list of magnets to scale...');
handles = InitMagnetList(handles);
handles = InitMagnetListSXR(handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = stdzbsyltu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close stdzbsyltu.
function stdzbsyltu_CloseRequestFcn(hObject, eventdata, handles)
%util_appClose(hObject);
delete(gcf);
% exit from Matlab when not running the desktop
if usejava('desktop')
  % don't exit from Matlab
  disp('Goodbye!')
else
   exit
end
%util_appClose(hObject);


function handles = InitMagnetList(handles)
% dynamically generate a list of all magnets needing to be scaled during the energy
% ramp

% "magnet" type primaries
primList = {'BEND', 'QUAD'};
region = {'CLTH','BSYH','LTUH','DMPH'};
magnet_PVs = model_nameRegion(primList,region);

% select only those which are online, not under feedback control and healthy

OkStatusList = {'Good', 'BCON Warning', 'BDES Change', 'Not Stdz''d', 'Out-of-Tol', 'BAD Ripple'};

magnet_stats = lcaGetSmart(strcat(magnet_PVs, ':STATMSG'));
good_magnet_PVs = [];

for stat = OkStatusList
    good_magnet_PVs = [good_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, char(stat)))))];
end

% ask user if they want to standardizee sickly magnets

BadStatusList = {'In Trouble', 'Turned Off', 'Not Cal''d', 'Tripped', 'DAC Error', 'ADC Error', 'BAD BACT'};

bad_magnet_PVs = [];

for stat = BadStatusList
    bad_magnet_PVs = [bad_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, char(stat)))))];
end

for mag = bad_magnet_PVs'
    response = questdlg(['The magnet ' mag ' has status ' magnet_stats(strmatch(mag, magnet_PVs)) '.  Include it in the list of magnets to standardize anyway?'], ...
        'Include ?', 'No');
    if strcmp(response, 'Yes')
        good_magnet_PVs = [good_magnet_PVs; mag];
    end
end


% add on :CTRL to build list of PVs to control
handles.magnetCTRL_PVs = strcat(good_magnet_PVs, ':CTRL');

%Print list of Magnets to Standardize
handles.magnetCTRL_PVs

%str=sprintf('BYD Status = %s',lcaGet('BEND:DMPH:400:CTRL')');

set(handles.BYDStat,'String',lcaGetSmart('BEND:DMPH:400:CTRL'));


function handles = InitMagnetListSXR(handles)
% dynamically generate a list of all magnets needing to be standardized

% "magnet" type primaries
primList = {'BEND', 'QUAD'};
region = {'CLTS','BSYS','LTUS','DMPS'};
magnet_PVs = model_nameRegion(primList,region);

%remove BEND:LTUS:166 from standardize list
magnet_PVs(ismember(magnet_PVs,'BEND:LTUS:166')) = [];

% select only those which are online, not under feedback control and healthy
OkStatusList = {'Good', 'BCON Warning', 'BDES Change', 'Not Stdz''d', 'Out-of-Tol', 'BAD Ripple'};

magnet_stats = lcaGetSmart(strcat(magnet_PVs, ':STATMSG'));
good_magnet_PVs = [];

for stat = OkStatusList
    good_magnet_PVs = [good_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, char(stat)))))];
end

% ask user if they want to standardize sickly magnets

BadStatusList = {'In Trouble', 'Turned Off', 'Not Cal''d', 'Tripped', 'DAC Error', 'ADC Error', 'BAD BACT'};

bad_magnet_PVs = [];

for stat = BadStatusList
    bad_magnet_PVs = [bad_magnet_PVs; magnet_PVs(find(~cellfun(@isempty, strfind(magnet_stats, char(stat)))))];
end

for mag = bad_magnet_PVs'
    response = questdlg(['The magnet ' mag ' has status ' magnet_stats(strmatch(mag, magnet_PVs)) '.  Include it in the list of magnets to standardize anyway?'], ...
        'Include ?', 'No');
    if strcmp(response, 'Yes')
        good_magnet_PVs = [good_magnet_PVs; mag];
    end
end

% add on :CTRL to build list of PVs to control
handles.magnetCTRL_PVsSXR = strcat(good_magnet_PVs, ':CTRL');

%Print list of Magnets to Standardize
handles.magnetCTRL_PVsSXR

set(handles.BYDStatSXR,'String',lcaGetSmart('BEND:DMPS:400:CTRL'));


% --- Executes on button press in HXR stdz.
function Stand_Mag(hObject, eventdata, handles)
set(hObject,'Enable','off');
while ~strcmp(lcaGet('BEND:DMPH:400:CTRL'), 'Ready')
   set(handles.BYDStat,'String',lcaGet('BEND:DMPH:400:CTRL'));
   pause(2);
   guidata(hObject, handles);
end
handles.magnetCTRL_PVs
!StripTool /u1/lcls/tools/StripTool/config/byd_by1_stdz.stp &
disp('Suppressing beam and STDZing HXR BSY LTU and DMP magnets...');
lcaPutSmart('IOC:BSY0:MP01:MSHUTCTL', 'No');
pause(0.5);
lcaPutSmart(handles.magnetCTRL_PVs, 'STDZ');
%set(hObject,'Enable','off');
while ~strcmp(lcaGet('BEND:DMPH:400:CTRL'), 'Ready')
   pause(2);
   set(handles.BYDStat,'String',lcaGet('BEND:DMPH:400:CTRL'));
   guidata(hObject, handles);
end


% --- Executes on button press in SXR stdz.
function Stand_Mag_SXR(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Enable','off');
while ~strcmp(lcaGet('BEND:DMPS:400:CTRL'), 'Ready')
   set(handles.BYDStatSXR,'String',lcaGet('BEND:DMPS:400:CTRL'));
   pause(2);
   guidata(hObject, handles);
end
handles.magnetCTRL_PVsSXR
!StripTool /u1/lcls/tools/StripTool/config/byd_by1_stdzSXR.stp &
disp('Suppressing beam and STDZing SXR BSY LTU and DMP magnets...');
lcaPutSmart('IOC:BSY0:MP01:MSHUTCTL', 'No');
pause(0.5);
lcaPutSmart(handles.magnetCTRL_PVsSXR, 'STDZ');
%set(hObject,'Enable','off');
while ~strcmp(lcaGet('BEND:DMPS:400:CTRL'), 'Ready')
   pause(2);
   set(handles.BYDStatSXR,'String',lcaGet('BEND:DMPS:400:CTRL'));
   guidata(hObject, handles);
end
%test
%test
