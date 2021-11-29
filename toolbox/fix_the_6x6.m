function varargout = fix_the_6x6(varargin)
% FIX_THE_6X6 M-file for fix_the_6x6.fig
%      With a button push, grabs the 6x6 setpoints from a pre-selected time in
%      the past.  With another button, disables stuff (MPS shutter, BYKICK,
%      the 6x6) to push the new setpoints to the 6x6 feedback.
%
%      Designed to help recover from longitudinal feedback runaways and
%      energy changes more quickly.
%
%      FIX_THE_6X6, by itself, creates a new FIX_THE_6X6 or raises the existing
%      singleton*.
%
%      H = FIX_THE_6X6 returns the handle to a new FIX_THE_6X6 or the handle to
%      the existing singleton*.
%
%      FIX_THE_6X6('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIX_THE_6X6.M with the given input arguments.
%
%      FIX_THE_6X6('Property','Value',...) creates a new FIX_THE_6X6 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fix_the_6x6_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fix_the_6x6_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fix_the_6x6

% Last Modified by Lauren 15-Apr-2013

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fix_the_6x6_OpeningFcn, ...
                   'gui_OutputFcn',  @fix_the_6x6_OutputFcn, ...
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


% --- Executes just before fix_the_6x6 is made visible.
function fix_the_6x6_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fix_the_6x6 (see VARARGIN)

% Choose default command line output for fix_the_6x6
handles.output = hObject;

% Defaults the "Mess w 6x6" button to "harmless" mode
set(handles.fixit,'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fix_the_6x6 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fix_the_6x6_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function pickatime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pickatime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

tvec = [ 2013 2 28 2 0 0];
handles.tvec = tvec;
guidata(hObject, handles)


% --- Executes when selected object is changed in pickatime.
function pickatime_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pickatime 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pickedTime = get(hObject,'Tag');

if strcmp(pickedTime,'enterTime')
    prompt = {'Enter date in mm/dd/yyyy format',...
            'Enter time in HH:MM format'};
    dlg_title = 'Pick a time';
    num_lines = 1;
    dayago = clock - [0 0 0 13 0 0];
    def_day = datestr(dayago, 'mm/dd/yyyy');
    def_time = datestr(dayago, 'HH:MM');
    def = {def_day, def_time};
    time_input_cell = inputdlg(prompt, dlg_title, num_lines, def);
    if isempty(time_input_cell)
        time_input_cell = {def_day; def_time};
    end
    time_input_char = char(time_input_cell);
    time_input_cat = [time_input_char(1,:) ' ' time_input_char(2,:)];
    tvec = datevec(time_input_cat, 'mm/dd/yyyy HH:MM');
    handles.tvec = tvec;
    guidata(hObject, handles)
end


% --- Executes on button press in getVals.
function getVals_Callback(hObject, eventdata, handles)
% hObject    handle to getVals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set names for the PVs we're interested in pulling
l2a_pv = 'ACCL:LI22:1:ADES';
l2p_pv = 'ACCL:LI22:1:PDES';
l2i_pv = 'FBCK:FB04:LG01:S5DES';
l3e_pv = 'ACCL:LI25:1:ADES';
l3p_pv = 'ACCL:LI25:1:PDES';


% Set the time range
time = clock;  % Get current time

tpick = get(get(handles.pickatime,'SelectedObject'),'Tag'); % Figure out which time preference is selected

switch tpick   % Based on the time preference, set subtraction time
    case 'tminus5'
        tminus = [ 0 0 0 0 5 0];
    case 'tminus10'
        tminus = [ 0 0 0 0 10 0];
    case 'tminus30'
        tminus = [ 0 0 0 0 30 0];
    case 'tminus60'
        tminus = [ 0 0 0 1 0 0];
end

deltaT = [ 0 0 0 0 0 30]; % Create a 30-second time window on either side

if strcmp(tpick,'enterTime')
  timeDes = handles.tvec; % Use time entered under "Enter time," or default
else
  timeDes = time - tminus;
end

t_lo = timeDes - deltaT;
t_hi = timeDes + deltaT;

t_lo_str = datestr(t_lo, 'mm/dd/yy HH:MM:SS');
t_hi_str = datestr(t_hi, 'mm/dd/yy HH:MM:SS');

timeRange = {t_lo_str; t_hi_str};


% Get archived data
[t, l2a_val] = getHistory(l2a_pv, timeRange);
[t, l2p_val] = getHistory(l2p_pv, timeRange);
[t, l2i_val] = getHistory(l2i_pv, timeRange);
[t, l3e_val] = getHistory(l3e_pv, timeRange);
[t, l3p_val] = getHistory(l3p_pv, timeRange);


% Find the medians
l2a = median(l2a_val);
l2p = median(l2p_val);
l2i = median(l2i_val);
l3e = median(l3e_val);
l3p = median(l3p_val);


% Make some fancy text strings
l2a_disp = [ 'L2 ampl: ' int2str(l2a)];
l2p_disp = [ 'L2 phase: ' mat2str(l2p,3)];  % I wanted a digit after the decimal point.
l2i_disp = [ 'L2 pk curr: ' int2str(l2i)];
l3e_disp = [ 'L3 energy: ' int2str(l3e)];
l3p_disp = [ 'L3 phase: ' int2str(l3p)];
dstr = datestr(timeDes);


% Display those fancy text strings
set(handles.L2ampl, 'String', l2a_disp);
set(handles.L2phase, 'String', l2p_disp);
set(handles.L2ipk, 'String', l2i_disp);
set(handles.L3eng, 'String', l3e_disp);
set(handles.L3phase, 'String', l3p_disp);
set(handles.valsTime, 'String', dstr,'Visible','on');


% Save the pv vals and timeDes to handles so they can be used later
handles.l2a = l2a;
handles.l2p = l2p;
handles.l2i = l2i;
handles.l3e = l3e;
handles.l3p = l3p;
handles.timeDes = timeDes;
handles.dstr = dstr;
guidata(hObject, handles)


% Enable the "Mess w 6x6" or fixit function
set(handles.fixit,'Enable','on');


% --- Executes on button press in fixit.
function fixit_Callback(hObject, eventdata, handles)
% hObject    handle to fixit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Put some text on the panel to let people know that you started
set(handles.whatsUp, 'String', 'Doing stuff...','Visible','on','FontAngle','italic');


% Put in some stoppers before you do anything heinous
disp('Putting in BYKIK')

% lcaPut('IOC:BSY0:MP01:MSHUTCTL', 0); Experimenting with NOT doing this!
lcaPut('IOC:BSY0:MP01:BYKIKCTL', 0);
pause(1);


% Turn off the longitudinal feedback; BC2 energy, BC2 pk current, DL2
% energy disabled
disp('Stopping the 6x6')
disp('Disabling BC2 energy and I_pk')
disp('Disabling DL2 energy')

lcaPut('FBCK:FB04:LG01:STATE', 0);
lcaPut('FBCK:FB04:LG01:S4USED', 0);
lcaPut('FBCK:FB04:LG01:S5USED', 0);
lcaPut('FBCK:FB04:LG01:S6USED', 0);
pause(1);


% Change the setpoints
disp('Restoring L2 ampl, L2 phase, L2 pk curr, and L3 energy')
disp(['     from ' handles.dstr]);

lcaPut('ACCL:LI22:1:ADES',handles.l2a);
lcaPut('ACCL:LI22:1:PDES',handles.l2p);
lcaPut('FBCK:FB04:LG01:S5DES',handles.l2i);
lcaPut('ACCL:LI25:1:ADES',handles.l3e);
lcaPut('ACCL:LI25:1:PDES',handles.l3p);
pause(1);


% Start the 6x6 again
disp('Starting the 6x6')

lcaPut('FBCK:FB04:LG01:STATE', 1);
pause(1);


% And we're done!
set(handles.whatsUp, 'String', 'Done!','FontAngle','normal');

disp('Done messing with the 6x6')
disp('Time to enable sub-feedbacks and BYKIK')
disp('Wishing you a stress-free recovery!')
disp('<3 <3 <3')


% --- Executes on button press in helpMe.
function helpMe_Callback(hObject, eventdata, handles)
% hObject    handle to helpMe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Makes a little help page


% Stole this neat little sizing/positioning code from Shawn
pos = get(gcf,'Position');
set(0,'Units','characters');
scrnsz=get(0,'ScreenSize');
set(0,'Units','pixels');
newx = pos(1) + 110;
newy = pos(2) + 14.6;

if newx > (scrnsz(3) - 76)
    newx = pos(1) - 76;
end


% Launch a new figure for the help page
figure('Units','characters','Position',[newx newy 75 28],'Color',[0.763 0.775 1], ...
                'Name','Help for Fix the 6x6','NumberTitle','off','MenuBar','none','Resize','off');
uipanel('Title','Fix the 6x6: WTF?','units','characters', ...
           'Position',[0 0 75 28],'BorderType','none', ...
            'FontSize',15,'BackgroundColor',[0.85 0.85 0.85],'HighlightColor','white', ...
            'BorderWidth',1,'TitlePosition','centertop');


% All the text nonsense
props={'Style','text','HorizontalAlignment','left','units','characters'};
uicontrol(props{:},'String','* What happens when I "Get vals?"', ...
           'FontSize',10,'FontWeight','bold','Position',[2 23 73 2.8],'BackgroundColor',[0.85 0.85 0.85]); 
uicontrol(props{:},'String','The GUI finds values for L2 amplitude, phase, and peak current and L3 energy for a 30-second window around your time selected under "Pick a time."  It takes a median of these values, displays them, and saves them for use with "Mess with the 6x6."', ...
           'FontSize',10,'FontWeight','normal','Position',[5 18 65 6],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','* What happens when I "Mess w 6x6?"', ...
           'FontSize',10,'FontWeight','bold','Position',[2 14 73 2.8],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','First, the GUI disables BYKIK.  It then stops the 6x6 and disables the BC2 Energy, BC2 Pk Curr, and DL2 Energy sub-feedbacks.  Next, it pushes the setpoints displayed under "Get PV values" to their respective PVs.  Finally, it restarts the 6x6.', ...
           'FontSize',10,'FontWeight','normal','Position',[5 9 65 6],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','* After "messing" with the 6x6, how do I recover the beam?', ...
           'FontSize',10,'FontWeight','bold','Position',[2 5 73 2.8],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','Pull the MPS shutter, potentially lowering the rate.  Let the beam run to BYKIK for a few seconds before enabling 1. BC2 energy 2. BC2 Pk Curr and 3. DL2 Energy, in that order.  Pull BYKIK when ready.', ...
           'FontSize',10,'FontWeight','normal','Position',[5 1 65 5],'BackgroundColor',[0.85 0.85 0.85]);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

% Exit from Matlab when not running the desktop 
if usejava('desktop') 
   % Don't exit from
   disp('Goodbye!')
else
   exit 
end
