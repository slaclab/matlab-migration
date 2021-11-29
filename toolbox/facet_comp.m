function varargout = facet_comp(varargin)
%Author: Shawn Alverson
%        Klystron graphical representation by Paul Emma
% Last Modified: 8/25/2011 by alverson
% Last Modified by GUIDE v2.5 25-Aug-2011 05:12:53
% FYI: full complement PV = FCUDKLYS:MCC0:ONBC10SUMY
%
% facet_comp M-file for facet_comp.fig
%      facet_comp, by itself, creates gui and allows user to collect and
%      print current klystron complement to the facet physcis logbook
%
%      H = facet_comp returns the handle to a new facet_comp or the handle to
%      the existing singleton*.
%
%      facet_comp('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in facet_comp.M with the given input arguments.
%
%      facet_comp('Property','Value',...) creates a new facet_comp or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_comp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_comp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_comp_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_comp_OutputFcn, ...
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


% --- Executes just before facet_comp is made visible.
function facet_comp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_comp (see VARARGIN)

calendar_icon = importdata(fullfile(fileparts(get(hObject,'FileName')),'images','calendar.jpg'));
%calendar_icon = importdata('/usr/local/lcls/tools/matlab/toolbox/images/calendar.jpg');
set([handles.calendar_start,handles.calendar_stop],'CDATA',calendar_icon);

% Choose default command line output for facet_comp
handles.output = hObject;

set(handles.slider_date,'String',datestr(now));
handles.hist_stat = 0;
handles.CompRest = [];
handles.time_index = [];
handles.klys_stat = [];

handles.sbstN=(2:19)';
handles.klysN=(1:8)';

%create remaining interface components and setup klys status array
sPos=-4.5;
for j=1:length(handles.sbstN)
    sbst=handles.sbstN(j);
    sPos=sPos+8.7;
    props={'Style','text','HorizontalAlignment','center','units','characters'};

    %display sector numbers across top row
    handles.sKlys(j) = uicontrol(props{:},'String',num2str(sbst),'FontSize',20, ...
        'FontWeight','bold','Position',[sPos 35.9 7 1.8]);
    kPos=35.1;
    for k=handles.klysN'
        handles.klys_names{1,k} = [num2str(i),'-',num2str(k)];
        kPos=kPos-2.5;
        if mod(k,3) == 1, kPos=kPos-.3;end  %extra spacing params
        %create klys status array starting display properties
        handles.hKlys(k,j)=uipanel('Title',num2str(k),'units','characters', ...
            'Position',[sPos kPos 7 2.5],'BorderType','line', ...
            'FontSize',20,'BackgroundColor',[0.5 0.5 0.5],'HighlightColor','black', ...
            'ForegroundColor','black', ...
            'BorderWidth',3,'FontWeight','bold','TitlePosition','centertop');
        %ignore 20-1, 20-2, 20-3, 20-4, and 24-7 since not used for facet
        if (sbst == 19 && k == 7) || (sbst == 10 && k == 8) || (sbst == 11 && k == 3)
            set(handles.hKlys(k,j),'Visible','off')
        end
    end
end

handles = history_Callback(hObject,eventdata,handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = facet_comp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close test_btplot.
function facet_comp_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% --- Executes on button press in Update.
function Update_Callback(hObject, eventdata, handles)
% hObject    handle to Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Collecting data for current klystron complement...')
set(handles.Update,'BackgroundColor','white','String','Processing...');pause(0.1);

%Get current klystron complement from Channel Access
handles = getCurrent(hObject, eventdata, handles);

%display time and date at time of data collection and update display
set(handles.DATE_TIME,'String',['Last update: ',datestr(now,'mm/dd/yyyy HH:MM:SS')]);

if handles.hist_stat
    disp('Updating difference comparison...')
end

set(handles.Update,'BackgroundColor','green','String','Update');
disp('Update complete!')

guidata(hObject, handles);


function handles = getCurrent(hObject, eventdata, handles)
%Update current complement state

if handles.hist_stat
    new_ts = length(handles.time_index)+1;
    time_inc = 1/(new_ts-1);
    set(handles.slider,'SliderStep',[time_inc,time_inc*12]);
else
    new_ts = 1;
end

klysmatrix = lcaGet('FCUDKLYS:MCC1:ONBC10SUMY');
handles.klys_stat(new_ts,1:144) = klysmatrix(1:144);
handles.time_index(new_ts) = now;

handles = plot_klys(hObject, eventdata, handles);


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

handles = plot_klys(hObject, eventdata, handles);

guidata(hObject,handles);


function handles = plot_klys(hObject, eventdata, handles)
%Update gui to display selected complement state

time_inc = get(handles.slider,'SliderStep');
slide_index = (int32(get(handles.slider,'Value')/(time_inc(1)))+1);
timestamp=datestr(handles.time_index(slide_index),'mm/dd/yyyy HH:MM:SS');
set(handles.slider_date,'String',timestamp);

handles.sel_state = reshape(handles.klys_stat(slide_index,:),8,18);

if get(handles.diff_toggle,'Value') %Show difference to current if selected
    current = reshape(handles.klys_stat(end,:),8,18);
    set(handles.hKlys(current==0),'HighlightColor','White','BackgroundColor',[0.2 0.2 0.2],'ForegroundColor','White');
    set(handles.hKlys(current==1),'HighlightColor','Black','BackgroundColor','Green','ForegroundColor','Black');
    set(handles.hKlys(handles.sel_state~=current),'HighlightColor','Red','ForegroundColor','Red');
else
    set(handles.hKlys(handles.sel_state==0),'HighlightColor','White','BackgroundColor',[0.2 0.2 0.2],'ForegroundColor','White');
    set(handles.hKlys(handles.sel_state==1),'HighlightColor','Black','BackgroundColor','Green','ForegroundColor','Black');    
end


% --- Executes on button press in history.
function handles = history_Callback(hObject, eventdata, handles)
% hObject    handle to history (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check for proper date/time entries
if datenum(get(handles.stopdate,'String')) <= datenum(get(handles.startdate,'String'))
  errordlg('Start date must be a date/time which is EARLIER than the End date!','Error!')
  return
end

set(handles.history,'String','Processing...','BackgroundColor','white');pause(0.1);
timerange={get(handles.startdate,'String');get(handles.stopdate,'String')};

%Clear current history data
handles.time_index = [];
handles.klys_stat = [];
handles.hist_stat = 0;

%Get archive history of full complement (Complement waveform PV created on
%*/*/2011, no history for older timestamps)

try
    [arch_times,arch_data] = getHistoryWfm('FCUDKLYS:MCC1:ONBC10SUMY',timerange);
    [handles.time_index,handles.klys_stat] = bit_interp(arch_times,arch_data,timerange);
catch
    disp('Error retrieving archive waveform! Check status of PV: FCUDKLYS:MCC1:ONBC10SUMY')
    set(handles.history,'String','Get History','BackgroundColor','green','Value',0);
    return;
end

handles.hist_stat = 1; %Flag history complete

% get fresh update of current complement
handles = getCurrent(hObject, eventdata, handles);
set(handles.slider_date,'String',datestr(handles.time_index(end)))

% set slider for 5 minute and 1 hour increments respectively within given time range
time_inc = 1/(length(handles.time_index)-1);
set(handles.slider,'SliderStep',[time_inc,time_inc*12],'Value',1,'Visible','on');
handles = plot_klys(hObject,eventdata,handles);

set(handles.history,'String','Get History','BackgroundColor','green','Value',0);
set(handles.roll_back,'Visible','on');

guidata(hObject, handles);


function [new_time, new_value] = bit_interp(time, value, time_range) %remove time_range from output
%Step function interpolator for archive data

interpStep = 300/24/60/60;
theTime = datenum(time_range{1}):interpStep:datenum(time_range{2}); 
new_time = theTime;

new_value(1,:) = value(1,:);
counter = 1;
for index = 2:1:length(theTime)
    if counter == length(time)
        new_value(index,:) = new_value(index - 1,:);
    elseif theTime(index) >= time(counter) && theTime(index) < time(counter + 1)
        new_value(index,:) = value(counter,:);
    elseif theTime(index) >= theTime(counter + 1)
        new_value(index,:) = value(counter+1,:);
        counter = counter + 1;
    end
end


% --- Executes on button press in roll_back.
function roll_back_Callback(hObject, eventdata, handles)
% hObject    handle to roll_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get fresh update of current complement if needed
if handles.time_index(end) < (now - 0.0208)
    disp('Complement last updated over 30 min. ago, getting new update...')
    handles = getCurrent(hObject, eventdata, handles);
end

current = reshape(handles.klys_stat(end,:),8,18);
%Check to ensure changes are to be made
if handles.sel_state == current
    errordlg('No differences detected to current state.  No changes made.','No change','modal')
    return
end

%Format list of changes and display for confirmation
chglst = cell(1,5);
handles.diff_index = [];
[handles.diff_index(:,1),handles.diff_index(:,2)] = find(handles.sel_state~=current);

if  length(handles.diff_index)<= 7
    toomany = [];
else
    toomany = 'Warning! Be sure to park beam on 2-9.';
end

numklys = length(handles.diff_index(:,1));
rows = ceil(numklys/5);
cols = ceil(numklys/rows);
counter = 1;
for i = 1:cols
    state = [];
    for j = 1:rows
        if counter <= numklys
            dev = [num2str(handles.diff_index(counter,2)+1),'-',num2str(handles.diff_index(counter,1))];
            if length(dev) < 4
                dev = [' ',dev];
            end
            if handles.sel_state(handles.diff_index(counter,1),handles.diff_index(counter,2)) == 1
                state = [state;[dev,' ON  |  ']];
            else
                state = [state;[dev,' OFF |  ']];
            end
            counter = counter + 1;
        else
            state = [state;'            '];
        end
    end
    chglst{i} = state;
end

changed = [chglst{1},chglst{2},chglst{3},chglst{4},chglst{5}];
quest = {'This action will add/drop the following klystrons to match the selected complement.  Are you sure you wish to proceed?', ...
    [],'Changes to be made: ',[],changed,[],toomany};
popup = questdlg(quest,'Are you sure?','Proceed','Cancel','Cancel');

if popup(1) == 'P'  %if proceed, put in MPS Shutter and BYKIK and make changes
    undochk = 0;
    set(handles.roll_back,'BackgroundColor','white','String','Processing...');
    handles.CompRest = handles.klys_stat(end,:); % copy current state in case of errors
    [errchk] = setKLYS(undochk,handles); %Change complement
    Update_Callback(hObject,eventdata,handles)  %Get fresh update of current state
    %handles = plot_klys(hObject,eventdata,handles);
    if any(errchk)
        errpop = questdlg('Errors were encountered while restoring complement, check xterm for details. Do you wish to undo changes?','Error!','Yes','No','No');
        disp_log('Errors encountered while restoring klystron complement.')
        if errpop(1) == 'Y'
            undo_Callback(hObject,eventdata,handles)
            set(handles.roll_back,'BackgroundColor','red','String','Restore Comp');
            return
        end
    else
        %Ask to print changes to logbook
        whichlog = questdlg('Print changes to log?','Print','MCC Log','Facet Log','No thanks','No thanks');
        if whichlog == 'L' | whichlog == 'M' %#ok<OR2>
            print_fnc(whichlog,changed,handles);
        end
    end

    disp('Done!')
    msgbox({'Operation completed!',[],strcat('Be sure to check LEM!')},'Reminder','help','modal')
    set(handles.roll_back,'BackgroundColor','red','String','Restore Comp');
    set(handles.undo,'Visible','on');
end

guidata(hObject,handles)


% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check to ensure changes are to be made
if handles.CompRest == handles.klys_stat(end,:)
  errordlg('No changes detected.  No need to undo.','No action recquired','modal')
  return
end

popup = questdlg({'This action will add/drop klystrons in order to undo recent changes to the complement.', ...
                  'Are you sure you wish to proceed?'},'Are you sure?','Proceed','Cancel','Cancel');
if popup(1) == 'P'
  set(handles.undo,'BackgroundColor','white','String','Processing...');
  undochk = 1;
  [errchk,handles] = setKLYS(undochk,handles);  %resets errchk and backs out klys changes
  %handles = plot_klys(hObject,eventdata,handles);
  Update_Callback(hObject,eventdata,handles)  %Get fresh update of current state
  if any(errchk)
    errordlg('Errors encountered while attempting to restore.  Please check xterm for further information.','Error!');
  end

  disp('Done!')
  msgbox({'Operation completed!',[],'Be sure to check LEM!'},'Reminder','help','modal')
  set(handles.undo,'BackgroundColor','yellow','String','Undo Change','Visible','off');
end

guidata(hObject,handles)


function [errchk,handles] = setKLYS(undochk,handles)
%Uses function control_klysStatSet to activate or deactivate a cell array
%of klystron tube names.
%control_klysStatSet returns 'act' of which the first three bits are as
%follows: bit1 = Activated on beam code 1
%         bit2 = On standby for beam code 1
%         bit3 = Station Offline

switch undochk
    case 0
        state = handles.sel_state;
        timestmp = get(handles.slider_date,'string');
        disp_log(['Restoring klystron complement from ',timestmp,'.'])
    case 1
        state = reshape(handles.CompRest(end,:),8,18);
        disp_log('Undoing most recent complement change.')
end

errchk = 0; % Clear error flag

%Create device and state lists for effected klystrons
klysnum = size(handles.diff_index);
klys_list = cell(klysnum(1),1);
stat_list = zeros(klysnum(1),1);
for i = 1:1:klysnum(1)
%    klys_list{i} = strtrim(char(handles.klys_names(handles.diff_index(i,2),handles.diff_index(i,1))));
    klys_list{i} = [num2str(handles.diff_index(i,2)+1),'-',num2str(handles.diff_index(i,1))];
    stat_list(i) = state(handles.diff_index(i,1),handles.diff_index(i,2));
end

try
    %Activate/De-Activate selected stations on Beam Code 10
    act = control_klysStatSet(klys_list,stat_list,10);
    if ~isequal(bitget(act,1),stat_list) %Check to make sure klystrons changed as requested
        errchk = 1;
        disp('End complement does not equal request!')
    end
catch
    errchk = 1;
end

%diff_index = sub2ind([11,144],handles.diff_index(:,1),handles.diff_index(:,2));
%handles.klys_stat(:,end+1) = handles.klys_stat(:,end);
%handles.klys_stat(diff_index,end) = bitget(act,1)
pause(1); %Pause to wait for PVs to reflect change

% --- Executes on button press in diff_toggle.
function diff_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to diff_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of diff_toggle

if handles.hist_stat
    plot_klys(hObject, eventdata, handles);
end

guidata(hObject,handles)


% --- Executes on button press in Logbook.
function Logbook_Callback(hObject, eventdata, handles)
% hObject    handle to Logbook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Ask which log to print to
whichlog = questdlg('Choose a log to print to:','Print','MCC Log','FACET Log','Cancel','FACET Log');

if ~isempty(whichlog) && whichlog(1) ~= 'C'
    print_fnc(whichlog,[],handles);
end


function print_fnc(whichlog,changed,handles)

if whichlog(1) == 'F'
    log = '-Pphysics-facetlog';
else
    log = '-Pelog_mcc';
end

if ~isempty(changed)
    %print text entry of complement changes
    lasti = size(changed);
    fig = fopen('/tmp/KlysChange.txt','wt');
    for i = 1:1:lasti(1)
        fprintf(fig,'%s\n',changed(i,:));
    end
    printstr = ['lpr ',log,' /tmp/KlysChange.txt'];
    unix(printstr);
    fclose(fig);
    unix('rm /tmp/KlysChange.txt');
else
    %create new figure and sets basics attributes
    newFig = figure('Units','characters','Position',[10 10 163 32.5],'Color',[0.702 0.702 0.702], ...
        'Name','FACET Klystron Complement','NumberTitle','off','MenuBar','none','Resize','off');

    %copy data onto new figure
    uipanel('Title','FACET Klystron Complement','units','characters','Position',[-0.167 0 163 32.5], ...
        'BorderType','etchedin','FontSize',24,'BackgroundColor',[0.702 0.702 0.702], ...
        'HighlightColor','white', 'ForegroundColor','blue','BorderWidth',1, ...
        'FontWeight','bold','TitlePosition','centertop');

    handles.sKlys_copy = copyobj(handles.sKlys,newFig);
    handles.Status_Msg_copy = copyobj(handles.Status_Msg,newFig);

    for sector = 1:1:18
        set(handles.sKlys_copy(sector),'Position',get(handles.sKlys_copy(sector),'Position') - [0 10 0 0]);
        for unit = 1:1:8
            handles.hKlys_copy(unit,sector) = copyobj(handles.hKlys(unit,sector),newFig);
            if (sector == 9 && unit == 8) || (sector == 10 && unit == 3) || (sector == 18 && unit == 7)
            else
                set(handles.hKlys_copy(unit,sector),'Position',get(handles.hKlys_copy(unit,sector),'Position') - [0 10 0 0]);
            end
        end
    end

    % check if showing difference or current state and label figure as such
    if get(handles.diff_toggle,'Value') == 0
        fig_label = ['Absolute Complement on: ',get(handles.slider_date,'String')];
    else
        fig_label = ['Complement difference to ',get(handles.slider_date,'String')];
    end

    uicontrol('Style','text','HorizontalAlignment','center','units','characters', ...
        'String',fig_label,'FontSize',12,'ForegroundColor','black',...
        'FontWeight','bold','Position',[0 27.7 163 1.643]);

    % Make figure smaller so that it fits into the logbook.
    set(newFig,'Position',get(newFig,'Position').*[1 1 1 .7]);
    gui_resize(newFig);

    %try to print new figure to logbook and checks for errors
    ErrChk = 0;
    try
        set(gcf,'PaperPositionMode','auto','InvertHardcopy','off')
        print('-f1','-loose',log)
    catch
        ErrChk = 1;
        rethrow(lasterror)
    end

    %close the figure
    close(newFig)

    if ErrChk == 0
        disp('Print Successful!')
    else
        set(handles.Status_Msg,'String','Error(s) occured - See command window for details.', ...
            'BackgroundColor','Red','ForegroundColor',[0.5 0.5 0.5])
    end
end


% --- Executes on button press in Help_Button.
function Help_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Help_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    close Help  % Close all prior help windows
catch
end

% Original size: [50 50 75 28]
pos = get(gcf,'Position');
set(0,'Units','characters');
scrnsz=get(0,'ScreenSize');
set(0,'Units','pixels');
newx = pos(1) + 110;
newy = pos(2) + 14.6;

if newx > (scrnsz(3) - 76)
    newx = pos(1) - 76;
end

figure('Units','characters','Position',[newx newy 75 28],'Color',[0.702 0.702 0.702], ...
                'Name','Help','NumberTitle','off','MenuBar','none','Resize','off');
uipanel('Title','FACET Klystron Complement Help','units','characters', ...
           'Position',[0 0 75 28],'BorderType','etchedin', ...
            'FontSize',15,'BackgroundColor',[0.702 0.702 0.702],'HighlightColor','white', ...
            'ForegroundColor','blue', ...
            'BorderWidth',1,'FontWeight','bold','TitlePosition','centertop');

props={'Style','text','HorizontalAlignment','left','units','characters'};
% uicontrol(props{:},'String','21','FontSize',20, ...
%         'FontWeight','bold','Position',[8 19 7 1.8]);
uicontrol(props{:},'String','Absolute statuses are shown when the "Show difference" box is left Unchecked.', ...
           'FontSize',10,'FontWeight','bold','Position',[2 23 73 2.8]); 
props2={'units','characters','BorderType','line','FontSize',20, ...
        'BorderWidth',3,'FontWeight','bold','TitlePosition','centertop'};
uipanel(props2{:},'Title','3','Position',[6 19 7 2.5], ...
             'BackgroundColor',[0.2 0.2 0.2],'HighlightColor','white', ...
            'ForegroundColor','white');
uicontrol(props{:},'String','Gray interior with white border means klystron was OFF at this timestamp.', ...
           'FontSize',10,'FontWeight','normal','Position',[15 19 55 2.8]);
uipanel(props2{:},'Title','3','Position',[6 16 7 2.5], ...
             'BackgroundColor','green','HighlightColor','black', ...
            'ForegroundColor','black');
uicontrol(props{:},'String','Green interior with black border means klystron was ON at this timestamp.', ...
           'FontSize',10,'FontWeight','normal','Position',[15 16 55 2.8]);
uicontrol(props{:},'String','Difference statuses are shown when the "Show difference" box is Checked.  Difference is compared to current state.', ...
           'FontSize',10,'FontWeight','bold','Position',[2 12 73 2.8]);
uipanel(props2{:},'Title','3','Position',[6 8 7 2.5], ...
             'BackgroundColor',[0.2 0.2 0.2],'HighlightColor','red', ...
            'ForegroundColor','red');
uicontrol(props{:},'String','Gray interior with red border means klystron was ON at this timestamp, but is OFF currently.', ...
           'FontSize',10,'FontWeight','normal','Position',[15 8 55 2.8]);
uipanel(props2{:},'Title','3','Position',[6 5 7 2.5], ...
             'BackgroundColor','green','HighlightColor','red', ...
            'ForegroundColor','red');
uicontrol(props{:},'String','Green interior with red border means klystron was OFF at this timestamp, but is ON currently.', ...
           'FontSize',10,'FontWeight','normal','Position',[15 5 55 2.8]);
uicontrol(props{:},'String','When a change is found, the Klystron count for L2 and L3 will turn red.  The number in parentheses is the count at the current state.', ...
           'FontSize',10,'FontWeight','normal','Position',[4 1 71 2.8]);

guidata(hObject,handles)


function startdate_Callback(hObject, eventdata, handles)
% hObject    handle to startdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startdate as text
%        str2double(get(hObject,'String')) returns contents of startdate as a double

str = get(handles.startdate,'String');
if isempty(str)
    str = datenum(get(handles.stopdate,'String'))-1;
end

try
    str = datestr(str,'mm/dd/yyyy HH:MM:SS');
catch
    disp('Non-recognizable date input, reverting to default!')
    str = datestr(now-1,'mm/dd/yyyy HH:MM:SS');   
end

if datenum(str) < datenum('09/16/2011 20:40:00')
    disp('Cannot display data from before 09/16/2011 20:40:00, please enter a new date!')
    str = '09/16/2011 20:40:00';  %Creation date of complement waveform PV
end
set(handles.startdate,'String',str);

guidata(hObject,handles);


function stopdate_Callback(hObject, eventdata, handles)
% hObject    handle to stopdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopdate as text
%        str2double(get(hObject,'String')) returns contents of stopdate as a double

str = get(handles.stopdate,'String');
if isempty(str)
    str = now;
end

try
    str = datestr(str,'mm/dd/yyyy HH:MM:SS');
catch
    disp('Non-recognizable date input, reverting to default!')
    str = datestr(now,'mm/dd/yyyy HH:MM:SS');
end

set(handles.stopdate,'String',str);
    
guidata(hObject,handles);

% --- Executes on button press in calendar_start.
function calendar_start_Callback(hObject, eventdata, handles)
% hObject    handle to calendar_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf,'Units','pixels')
pos = get(gcf,'Position');
set(gcf,'Units','characters')
pos = pos + [ 190 80 0 0 ];

date_pick = calendar_pop(now-1,pos);
if ~isempty(date_pick)
   set(handles.startdate,'String',date_pick)
end
startdate_Callback(hObject,eventdata,handles)

% --- Executes on button press in calendar_stop.
function calendar_stop_Callback(hObject, eventdata, handles)
% hObject    handle to calendar_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf,'Units','pixels')
pos = get(gcf,'Position');
set(gcf,'Units','characters')
pos = pos + [ 190 30 0 0 ];

date_pick = calendar_pop(now,pos);
if ~isempty(date_pick)
   set(handles.stopdate,'String',date_pick)
end
stopdate_Callback(hObject,eventdata,handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%% Creation Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function startdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',datestr(now-1,'mm/dd/yyyy HH:MM:SS'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stopdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',datestr(now,'mm/dd/yyyy HH:MM:SS'));

guidata(hObject, handles);