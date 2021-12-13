function varargout = retroconfigurator(varargin)
% RETROCONFIGURATOR M-file for retroconfigurator.fig
%      RETROCONFIGURATOR, by itself, creates a new RETROCONFIGURATOR or raises the existing
%      singleton*.
%
%      H = RETROCONFIGURATOR returns the handle to a new RETROCONFIGURATOR or the handle to
%      the existing singleton*.
%
%      RETROCONFIGURATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RETROCONFIGURATOR.M with the given input arguments.
%
%      RETROCONFIGURATOR('Property','Value',...) creates a new RETROCONFIGURATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before retroconfigurator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to retroconfigurator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help retroconfigurator

% Last Modified by GUIDE v2.5 23-Feb-2013 16:07:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @retroconfigurator_OpeningFcn, ...
                   'gui_OutputFcn',  @retroconfigurator_OutputFcn, ...
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


% --- Executes just before retroconfigurator is made visible.
function retroconfigurator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to retroconfigurator (see VARARGIN)
setenv('TNS_ADMIN','/usr/local/lcls/tools/oracle/wallets/epics_mon_user');
% Choose default command line output for retroconfigurator
handles.output = hObject;

% set up SCORE API stuff
% this mostly cut and pasted from FromSCORE.m
handles.logger = edu.stanford.slac.err.Err.getInstance('config_generator.m');

stack = dbstack; % call stack
if length(stack) > 1
    handles.caller = stack(2).file;
else
    handles.caller = getenv('PHYSICS_USER');
end

if ~isequal(8,exist('edu.stanford.slac.score.api.ScoreAPI','class'))
    handles.logger.logl(sprintf('Sorry, %s unable to find SCORE Java classes in config_generator.m',caller));
    return;
end

try
    handles.ScoreAPI = edu.stanford.slac.score.api.ScoreAPI();
    handles.logger.logl(sprintf('successfully connected to SCORE'));
catch
    handles.logger.logl(sprintf('Sorry, unable to connect to SCORE'));
end

handles.regions = cell(getScoreRegions(handles.ScoreAPI));

set(handles.popupmenu_regions, 'String', handles.regions);

% set default timestamp to NOW

set(handles.edit_timestamp, 'String', datestr(now));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes retroconfigurator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = retroconfigurator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_timestamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timestamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timestamp as text
%        str2double(get(hObject,'String')) returns contents of edit_timestamp as a double


% --- Executes during object creation, after setting all properties.
function edit_timestamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timestamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_regions.
function popupmenu_regions_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_regions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_regions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_regions


% --- Executes during object creation, after setting all properties.
function popupmenu_regions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_regions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_collect.
function pushbutton_collect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_collect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'Enable', 'off');
set(hObject, 'BackgroundColor', [0.9 0.9 0.2]);

% draw the progressbar

barpixels = getpixelposition(handles.progressbar);
newpixels = barpixels;
newpixels(3) = 1;
setpixelposition(handles.progressbar, newpixels);
drawnow;

% get the region selection and timestamp from the GUI

handles.region = handles.regions{get(handles.popupmenu_regions, 'Value')};
handles.timestamp = datenum(get(handles.edit_timestamp, 'String'));

set(hObject, 'String', 'Get PVs from SCORE');
drawnow;

% initialize SCORe for that region
try
    initialize(handles.ScoreAPI, handles.caller, handles.region);
    handles.logger.logl(sprintf('%s successfully connected to SCORE region %s', handles.caller, handles.region));
catch
    handles.logger.logl(sprintf('Sorry, %s unable to connect to SCORE region %s', handles.caller, handles.region));
    return;
end

% find the most recent snapshot here

jnow = java.util.Date();
before = java.sql.Timestamp(jnow.getTime()); % this is "now"
after = java.sql.Timestamp(jnow.getTime() - (1000 * 60 * 60));  % this is one hour before "now"

snapshots = [];

while isempty(snapshots) && ((after.getYear() + 1900) > 2000)
    % get a list of snapshots from the archiver for the last hour,
    % if none found, double the length of time and search again
    % bail out if you get all the way back to year 2000, something is wrong
    snapshots = handles.ScoreAPI.readSnapshots(after, before);
    after.setTime(before.getTime() - (2 * (before.getTime() - after.getTime())));
end

% get the last snapshot
LastSnapshot = snapshots(length(snapshots));

try
    handles.ScoreAPI.readData(LastSnapshot.getTimestamp());
    ScoreData = getData(handles.ScoreAPI);
    handles.logger.logl(sprintf('%s successfully fetched most recent config from SCORE region %s', handles.caller, handles.region));
catch
    handles.logger.logl(sprintf('Sorry, %s unable to fetch most recent config from SCORE region %s', handles.caller, handles.region));
    return;
end

% extract the the SCORE data into a matlab data structure that Save2SCORE
% will like

handles.numrows = size(ScoreData);
handles.data = cell(0);

for i=1:handles.numrows

    try
        ScoreRow = get(ScoreData,i-1);
        handles.data{i}.region       = char(getRegion(ScoreRow));
        handles.data{i}.area         = char(getArea(ScoreRow));
        handles.data{i}.readbackName = char(getReadbackName(ScoreRow));
        handles.data{i}.readbackVal  = getReadbackVal(ScoreRow);
        handles.data{i}.setpointName = char(getSetpointName(ScoreRow));
        handles.data{i}.setpointVal  = getSetpointVal(ScoreRow);
        handles.data{i}.aliasName    = char(getAliasName(ScoreRow));
        handles.data{i}.configTitle  = char(getConfigTitle(ScoreRow));
    catch
        disp('Failed to extract PV names from Score Data');
    end
end


% % % strip from desnames the 'null' entries (i.e. no "DES" defined in score)
%
% nulls = strcmp(desnames, 'null');
%
% newdesnames = cell(sum(~nulls), 1);
%
% j = 1;
% for i = 1:length(desnames)
%     if ~nulls(i)
%         newdesnames{j} = desnames{i};
%         j = j + 1;
%     end
% end
%
% % strip from actnames the 'null' entries (i.e. no "ACT" defined in score)
%
% nulls = strcmp(actnames, 'null');
%
% newactnames = cell(sum(~nulls), 1);
%
% j = 1;
% for i = 1:length(actnames)
%     if ~nulls(i)
%         newactnames{j} = actnames{i};
%         j = j + 1;
%     end
% end
%
% handles.actnames = newactnames;
% handles.desnames = newdesnames;
%
% % allocate some space for the history data
%
% desdata = cell(1, length(handles.desnames));
% actdata = cell(1, length(handles.actnames));

% get a 5 minute block of data

starttime = handles.timestamp - datenum(0, 0, 0, 0, 2, 30);
endtime = handles.timestamp + datenum(0, 0, 0, 0, 2, 30);

%setting up the PV values for the comment section
a = datestr(handles.timestamp, 'mm/dd/yyyy HH:MM:SS');
b = datestr(endtime, 'mm/dd/yyyy HH:MM:SS');
timeRange = {a;b};
[time, elecenergy] = aidaGetHistory('SIOC:SYS0:ML00:AO500:HIST.lcls', timeRange);
a = elecenergy(1);
handles.elecE = num2str(a, '%6.3f');
[time, ipk2cur] = aidaGetHistory('SIOC:SYS0:ML00:AO195:HIST.lcls', timeRange);
b = ipk2cur(1);
handles.ipk2 = num2str(b, 4);
[time, pulseenergy] = aidaGetHistory('PHYS:SYS0:1:ELOSSENERGY:HIST.lcls', timeRange);
c = pulseenergy(1);
handles.pulseE = num2str(c, '%6.2f');
[time, photonenergy] = aidaGetHistory('SIOC:SYS0:ML00:AO627:HIST.lcls', timeRange);
d = photonenergy(1);
handles.photonE = num2str(d, '%6.0f');
[time, chargei] = aidaGetHistory('SIOC:SYS0:ML00:AO470:HIST.lcls', timeRange);
e = chargei(1);
handles.charge = num2str(e, '%6.3f');

% set up what's needed for ArchiveData() call
url = 'http::lcls-archsrv/cgi-bin/ArchiveDataServer.cgi';
addpath /home/physics/nate/dev/matarch/O.linux-x86/;

i = 1;
last = handles.numrows;

not_archived = [];

tic;

disp('Getting data from the archiver:');
j = 1;
disp('                PV name                     Value           Timestamp      Retrieval Time ');
disp('----------------------------------------  ----------  -------------------- ---------------');
disp(handles.region)
for i = 1:handles.numrows

    % get the DES value
    name = handles.data{i}.setpointName;

    % clear the "no data in archiver" flag
    nodata = 0;

    % fancy UI progress bar update stuff
    newpixels(3) = ceil(barpixels(3) * (i/last));
    setpixelposition(handles.progressbar, newpixels);
    drawnow;

    if ~strcmp(name, 'null')    %if this row has a DES value

        set(hObject, 'String', [num2str(i), '/', num2str(last), ': ', char(name)]);
        drawnow;

        % actually get the data

        tic();
        try
            data = ArchiveData(url, 'values', 1, name, starttime, endtime, 100, 0);
        catch
            nodata = 1;
        end
        elapsed = toc();

        if nodata
            % if the archivedata() call failed, it's not in the archiver
            % probably should check via meme_names for archived
            % things eg meme_names('name','BPMS:LI30:401:YENERGYJITTER','filter','hist')
            % and then be smart about adding it to the "to be archived" list
            % for now, just use the live value instead
            not_archived = [not_archived; cellstr(name)];
            savedata = lcaGet(name, 0, 'double');
            fprintf(1, '%-40s  %-10.3f  %-20s %11f sec ***\n', char(name), savedata, datestr(now), elapsed);
        else % if there was data returned
            % count how many values there were
            num = size(data, 2);

            if num < 1
                % there is nothing in data
                % this should never happen
                % put some smarts in here in case it does
                warndlg('Something is really wrong with nate''s logic, please tell him', 'oops');
            elseif num == 1
                % there was only one DES value, so use it
                % this is how it should be for DES for most things
                % except maybe feedback actuators
                savedata = data(3);
                ts = datestr(data(1));
                fprintf(1, '%-40s  %-10.3f  %-20s %11f sec\n', char(name), savedata, ts, elapsed);
                % fprintf(1, '%-40s  %-10.3f  %-20s\n', char(name), savedata, ts);
            else
                % the DES changed during the 5 minute window

                values = data(3,:);
                times = data(1,:);

                % find the closest data point to the timestamp entered by user
                diffs = handles.timestamp - times;
                [val, index] = min(abs(diffs));
                savedata = values(index);
                ts = datestr(times(index));
                fprintf(1, '%-40s  %-10.3f  %-20s %11f sec\n', char(name), savedata, ts, elapsed);
                % fprintf(1, '%-40s  %-10.3f  %-20s\n', char(name), savedata, ts);
            end
        end

        % store the value in the score-friendly data structure
        handles.data{i}.setpointVal = savedata;
    else
        % do something about 'null' PVs here
    end

    % now get the corresponding ACT value

    name = handles.data{i}.readbackName;

    % clear the "no data in archiver" flag
    nodata = 0;

    set(hObject, 'String', [num2str(i), '/', num2str(last), ': ', char(name)]);

    if ~strcmp(name, 'null')    %if this row has an ACT value

        set(hObject, 'String', [num2str(i), '/', num2str(last), ': ', char(name)]);
        drawnow;

        % actually get the data

        tic();
        try
            data = ArchiveData(url, 'values', 1, name, starttime, endtime, 100, 0);
        catch
            nodata = 1;
        end
        elapsed = toc();

        if nodata
            % if the archivedata() call failed, it's not in the archiver
            % probably should check via aidalist here for a :HIST.lcls thing
            % and then be smart about adding it to the "to be archived" list
            % for now, just use the live value instead

            not_archived = [not_archived; cellstr(name)];
            savedata = lcaGet(name, 0, 'double');
            fprintf(1, '%-40s  %-10.3f  %-20s %11f sec ***\n', char(name), savedata, datestr(now), elapsed);
        else % if there was data returned
            % count how many values there were
            num = size(data, 2);

            if num < 1
                % there is nothing in data
                % this should never happen
                % put some smarts in here in case it does
                warndlg('Something is really wrong with nate''s logic, please tell him', 'oops');
            else
                values = data(3,:);
                times = data(1,:);

                % find the closest data point to the timestamp entered by user
                diffs = handles.timestamp - times;
                [val, index] = min(abs(diffs));
                savedata = values(index);
                ts = datestr(times(index));
                fprintf(1, '%-40s  %-10.3f  %-20s %11f sec\n', char(name), savedata, ts, elapsed);
            end
        end

        % store the value in the score-friendly data structure
        handles.data{i}.readbackVal = savedata;
    else
        % do something about 'null' PVs here
    end

    i = i + 1;
end

toc;

set(handles.pushbutton_save, 'Enable', 'on');

% found any unarchived PVs?

if ~isempty(not_archived)
    warndlg(['The following PVs were not found in the archiver:'; not_archived; 'I am putting the current (live) values into the config instead.'], 'PVs not found');
    % add them to the "to be added to archiver" list.
    fd = fopen('/home/physics/nate/dev/config/notarchived.txt', 'a');
    fprintf(fd, '  %s\n', char(handles.region));
    for line = not_archived'
        fprintf(fd, '%s\n', char(line));
    end
    fclose(fd);
end


set(hObject, 'BackgroundColor', [0.702 0.702 0.702]);
set(hObject, 'String', 'Collect');
set(hObject, 'Enable', 'on');

guidata(hObject, handles);





% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', 'Saving...');
set(hObject, 'Enable', 'off');

jdate = java.util.Date(datestr(handles.timestamp));
sqldate = java.sql.Timestamp(jdate.getTime());

blah = struct('region', [], 'ts', [], 'comment', [], 'data', []);
blah.region = handles.region;
blah.ts = sqldate;
blah.comment = [handles.elecE, ' GeV, ', handles.ipk2, ' A, ', handles.pulseE, ' mJ, ', handles.photonE, ' eV, ', handles.charge, ' nC'];
blah.data = handles.data;
blah.configTitle = 'stuff';

try
    Save2SCORE(blah);
    success = 1;
catch
    disp('Save to SCORE failed!');
    success = 0;
end

if success
    warndlg('Config save completed!', 'Saved to SCORE');
end

set(hObject, 'String', 'Save to SCORE');
set(hObject, 'Enable', 'on');


% --- Executes on button press in macrocollect_save.
function macrocollect_save_Callback(hObject, eventdata, handles)
set(hObject, 'Enable', 'off');
set(hObject, 'BackgroundColor', [0.9 0.9 0.2]);

macroregions = {'Gun to TD11-LEM', 'TD11 to BSY-LEM', 'LTU-LEM', 'Undulator Taper'};
% draw the progressbar

barpixels = getpixelposition(handles.progressbar);
newpixels = barpixels;
newpixels(3) = 1;
setpixelposition(handles.progressbar, newpixels);
drawnow;

% get the region selection and timestamp from the GUI
for z =1:4
handles.region = macroregions{z};%handles.regions{get(handles.popupmenu_regions, 'Value')};
handles.timestamp = datenum(get(handles.edit_timestamp, 'String'));

set(hObject, 'String', 'Get PVs from SCORE');
drawnow;

% initialize SCORe for that region
try
    initialize(handles.ScoreAPI, handles.caller, handles.region);
    handles.logger.logl(sprintf('%s successfully connected to SCORE region %s', handles.caller, handles.region));
catch
    handles.logger.logl(sprintf('Sorry, %s unable to connect to SCORE region %s', handles.caller, handles.region));
    return;
end

% find the most recent snapshot here

jnow = java.util.Date();
before = java.sql.Timestamp(jnow.getTime()); % this is "now"
after = java.sql.Timestamp(jnow.getTime() - (1000 * 60 * 60));  % this is one hour before "now"

snapshots = [];

while isempty(snapshots) && ((after.getYear() + 1900) > 2000)
    % get a list of snapshots from the archiver for the last hour,
    % if none found, double the length of time and search again
    % bail out if you get all the way back to year 2000, something is wrong
    snapshots = handles.ScoreAPI.readSnapshots(after, before);
    after.setTime(before.getTime() - (2 * (before.getTime() - after.getTime())));
end

% get the last snapshot
LastSnapshot = snapshots(length(snapshots));

try
    handles.ScoreAPI.readData(LastSnapshot.getTimestamp());
    ScoreData = getData(handles.ScoreAPI);
    handles.logger.logl(sprintf('%s successfully fetched most recent config from SCORE region %s', handles.caller, handles.region));
catch
    handles.logger.logl(sprintf('Sorry, %s unable to fetch most recent config from SCORE region %s', handles.caller, handles.region));
    return;
end

% extract the the SCORE data into a matlab data structure that Save2SCORE
% will like

handles.numrows = size(ScoreData);
handles.data = cell(0);

for i=1:handles.numrows

    try
        ScoreRow = get(ScoreData,i-1);
        handles.data{i}.region       = char(getRegion(ScoreRow));
        handles.data{i}.area         = char(getArea(ScoreRow));
        handles.data{i}.readbackName = char(getReadbackName(ScoreRow));
        handles.data{i}.readbackVal  = getReadbackVal(ScoreRow);
        handles.data{i}.setpointName = char(getSetpointName(ScoreRow));
        handles.data{i}.setpointVal  = getSetpointVal(ScoreRow);
        handles.data{i}.aliasName    = char(getAliasName(ScoreRow));
        handles.data{i}.configTitle  = char(getConfigTitle(ScoreRow));
    catch
        disp('Failed to extract PV names from Score Data');
    end
end


% % % strip from desnames the 'null' entries (i.e. no "DES" defined in score)
%
% nulls = strcmp(desnames, 'null');
%
% newdesnames = cell(sum(~nulls), 1);
%
% j = 1;
% for i = 1:length(desnames)
%     if ~nulls(i)
%         newdesnames{j} = desnames{i};
%         j = j + 1;
%     end
% end
%
% % strip from actnames the 'null' entries (i.e. no "ACT" defined in score)
%
% nulls = strcmp(actnames, 'null');
%
% newactnames = cell(sum(~nulls), 1);
%
% j = 1;
% for i = 1:length(actnames)
%     if ~nulls(i)
%         newactnames{j} = actnames{i};
%         j = j + 1;
%     end
% end
%
% handles.actnames = newactnames;
% handles.desnames = newdesnames;
%
% % allocate some space for the history data
%
% desdata = cell(1, length(handles.desnames));
% actdata = cell(1, length(handles.actnames));

% get a 5 minute block of data

starttime = handles.timestamp - datenum(0, 0, 0, 0, 2, 30);
endtime = handles.timestamp + datenum(0, 0, 0, 0, 2, 30);

%setting up the PV values for the comment section
a = datestr(handles.timestamp, 'mm/dd/yyyy HH:MM:SS');
b = datestr(endtime, 'mm/dd/yyyy HH:MM:SS');
timeRange = {a;b};
[time, elecenergy] = aidaGetHistory('SIOC:SYS0:ML00:AO500:HIST.lcls', timeRange);
a = elecenergy(1);
handles.elecE = num2str(a, '%6.3f');
[time, ipk2cur] = aidaGetHistory('SIOC:SYS0:ML00:AO195:HIST.lcls', timeRange);
b = ipk2cur(1);
handles.ipk2 = num2str(b, 4);
[time, pulseenergy] = aidaGetHistory('PHYS:SYS0:1:ELOSSENERGY:HIST.lcls', timeRange);
c = pulseenergy(1);
handles.pulseE = num2str(c, '%6.2f');
[time, photonenergy] = aidaGetHistory('SIOC:SYS0:ML00:AO627:HIST.lcls', timeRange);
d = photonenergy(1);
handles.photonE = num2str(d, '%6.0f');
[time, chargei] = aidaGetHistory('SIOC:SYS0:ML00:AO470:HIST.lcls', timeRange);
e = chargei(1);
handles.charge = num2str(e, '%6.3f');

% set up what's needed for ArchiveData() call
url = 'http::lcls-archsrv/cgi-bin/ArchiveDataServer.cgi';
addpath /home/physics/nate/dev/matarch/O.linux-x86/;

i = 1;
last = handles.numrows;

not_archived = [];

tic;

disp('Getting data from the archiver:');
j = 1;
disp('                PV name                     Value           Timestamp      Retrieval Time ');
disp('----------------------------------------  ----------  -------------------- ---------------');
disp(handles.region)
for i = 1:handles.numrows

    % get the DES value
    name = handles.data{i}.setpointName;

    % clear the "no data in archiver" flag
    nodata = 0;

    % fancy UI progress bar update stuff
    newpixels(3) = ceil(barpixels(3) * (i/last));
    setpixelposition(handles.progressbar, newpixels);
    drawnow;

    if ~strcmp(name, 'null')    %if this row has a DES value

        set(hObject, 'String', [num2str(i), '/', num2str(last), ': ', char(name)]);
        drawnow;

        % actually get the data

        tic();
        try
            data = ArchiveData(url, 'values', 1, name, starttime, endtime, 100, 0);
        catch
            nodata = 1;
        end
        elapsed = toc();

        if nodata
            % if the archivedata() call failed, it's not in the archiver
            % probably should check via aidalist here for a :HIST.lcls thing
            % and then be smart about adding it to the "to be archived" list
            % for now, just use the live value instead
            not_archived = [not_archived; cellstr(name)];
            savedata = lcaGet(name, 0, 'double');
            fprintf(1, '%-40s  %-10.3f  %-20s %11f sec ***\n', char(name), savedata, datestr(now), elapsed);
        else % if there was data returned
            % count how many values there were
            num = size(data, 2);

            if num < 1
                % there is nothing in data
                % this should never happen
                % put some smarts in here in case it does
                warndlg('Something is really wrong with nate''s logic, please tell him', 'oops');
            elseif num == 1
                % there was only one DES value, so use it
                % this is how it should be for DES for most things
                % except maybe feedback actuators
                savedata = data(3);
                ts = datestr(data(1));
                fprintf(1, '%-40s  %-10.3f  %-20s %11f sec\n', char(name), savedata, ts, elapsed);
                % fprintf(1, '%-40s  %-10.3f  %-20s\n', char(name), savedata, ts);
            else
                % the DES changed during the 5 minute window

                values = data(3,:);
                times = data(1,:);

                % find the closest data point to the timestamp entered by user
                diffs = handles.timestamp - times;
                [val, index] = min(abs(diffs));
                savedata = values(index);
                ts = datestr(times(index));
                fprintf(1, '%-40s  %-10.3f  %-20s %11f sec\n', char(name), savedata, ts, elapsed);
                % fprintf(1, '%-40s  %-10.3f  %-20s\n', char(name), savedata, ts);
            end
        end

        % store the value in the score-friendly data structure
        handles.data{i}.setpointVal = savedata;
    else
        % do something about 'null' PVs here
    end

    % now get the corresponding ACT value

    name = handles.data{i}.readbackName;

    % clear the "no data in archiver" flag
    nodata = 0;

    set(hObject, 'String', [num2str(i), '/', num2str(last), ': ', char(name)]);

    if ~strcmp(name, 'null')    %if this row has an ACT value

        set(hObject, 'String', [num2str(i), '/', num2str(last), ': ', char(name)]);
        drawnow;

        % actually get the data

        tic();
        try
            data = ArchiveData(url, 'values', 1, name, starttime, endtime, 100, 0);
        catch
            nodata = 1;
        end
        elapsed = toc();

        if nodata
            % if the archivedata() call failed, it's not in the archiver
            % probably should check via aidalist here for a :HIST.lcls thing
            % and then be smart about adding it to the "to be archived" list
            % for now, just use the live value instead

            not_archived = [not_archived; cellstr(name)];
            savedata = lcaGet(name, 0, 'double');
            fprintf(1, '%-40s  %-10.3f  %-20s %11f sec ***\n', char(name), savedata, datestr(now), elapsed);
        else % if there was data returned
            % count how many values there were
            num = size(data, 2);

            if num < 1
                % there is nothing in data
                % this should never happen
                % put some smarts in here in case it does
                warndlg('Something is really wrong with nate''s logic, please tell him', 'oops');
            else
                values = data(3,:);
                times = data(1,:);

                % find the closest data point to the timestamp entered by user
                diffs = handles.timestamp - times;
                [val, index] = min(abs(diffs));
                savedata = values(index);
                ts = datestr(times(index));
                fprintf(1, '%-40s  %-10.3f  %-20s %11f sec\n', char(name), savedata, ts, elapsed);
            end
        end

        % store the value in the score-friendly data structure
        handles.data{i}.readbackVal = savedata;
    else
        % do something about 'null' PVs here
    end

    i = i + 1;
end

toc;

set(handles.pushbutton_save, 'Enable', 'on');

% found any unarchived PVs?

if ~isempty(not_archived)
    warndlg(['The following PVs were not found in the archiver:'; not_archived; 'I am putting the current (live) values into the config instead.'], 'PVs not found');
    % add them to the "to be added to archiver" list.
    fd = fopen('/home/physics/nate/dev/config/notarchived.txt', 'a');
    fprintf(fd, '  %s\n', char(handles.region));
    for line = not_archived'
        fprintf(fd, '%s\n', char(line));
    end
    fclose(fd);
end

jdate = java.util.Date(datestr(handles.timestamp));
sqldate = java.sql.Timestamp(jdate.getTime());

blah = struct('region', [], 'ts', [], 'comment', [], 'data', []);
blah.region = handles.region;
blah.ts = sqldate;
blah.comment = [handles.elecE, ' GeV, ', handles.ipk2, ' A, ', handles.pulseE, ' mJ, ', handles.photonE, ' eV, ', handles.charge, ' nC'];
blah.data = handles.data;
blah.configTitle = 'stuff';

try
    Save2SCORE(blah);
    success = 1;
catch
    disp('Save to SCORE failed!');
    success = 0;
end
end
if success
    warndlg('Config save completed!', 'Saved to SCORE');
%set(hObject, 'Enable', 'on');
end
% set(hObject, 'String', 'Save to SCORE');
% set(hObject, 'Enable', 'on');
% set(hObject, 'BackgroundColor', [0.702 0.702 0.702]);
% set(hObject, 'String', 'Collect');
%set(hObject, 'Enable', 'on');


guidata(hObject, handles);

