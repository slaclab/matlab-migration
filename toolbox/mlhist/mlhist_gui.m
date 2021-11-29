function varargout = mlhist_gui(varargin)
% MLHIST_GUI M-file for mlhist_gui.fig
%      MLHIST_GUI, by itself, creates a new MLHIST_GUI or raises the existing
%      singleton*.
%
%      H = MLHIST_GUI returns the handle to a new MLHIST_GUI or the handle to
%      the existing singleton*.
%
%      MLHIST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MLHIST_GUI.M with the given input arguments.
%
%      MLHIST_GUI('Property','Value',...) creates a new MLHIST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mlhist_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mlhist_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mlhist_gui

% Last Modified by GUIDE v2.5 06-Oct-2016 15:01:00

% Because the production network [once utilized] R2007b, this [once used] the
% undocumented version of uitable.

% Author: Tim Maxwell
% Initial release: Sep 29, 2016

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mlhist_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @mlhist_gui_OutputFcn, ...
                   'gui_CloseRequestFcn', @mainFigure_CloseRequestFcn, ...
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





% --- Executes just before mlhist_gui is made visible.
function mlhist_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mlhist_gui (see VARARGIN)

% Choose default command line output for mlhist_gui
handles.output = hObject;
set(handles.editDirSet,'string',pwd)

if ispc
    handles.pathsep = '\';
else
    handles.pathsep = '/';
end


% Check if on the controls network...
if exist('/u1/lcls/matlab/data/','dir')
    pushDirToday_Callback(hObject, [], handles)
end

% Max number of days allowed when scanning multiple folders:
handles.maxNdays = 365*3;

% A long tooltip...
set(handles.pushPopulateWithPath,'tooltipstring',...
    sprintf(['Scan the specified path. \n',...
    'Any files of the types to be included will be \n',...
    'appended to the list of available records below. \n',...
    'Duplicate file entries in the old record are overwritten.']))
set(handles.pushScanDates,'tooltipstring',...
    sprintf(['Similar to Scan Path, but will scan across up to\n',...
             num2str(handles.maxNdays) ' days of data iteratively, range specified above.']))

set(handles.editStartDate,'string',datestr(now-1/3,'mm/dd/yyyy HH:MM:SS'))
set(handles.editEndDate,'string',datestr(now,'mm/dd/yyyy HH:MM:SS'))

% Load the browser config
try
    load('mlhist_config.mat','fileTypes','archList')
catch ex
    warning('Error loading matDataBrowserConfig.mat!')
    throw(ex)
end
% Alphaphetize it
[~,ind] = sort(fileTypes.dispName);
n = fieldnames(fileTypes);
for k = 1:numel(n)
    fileTypes.(n{k}) = fileTypes.(n{k})(ind);
end
handles.fileTypes = fileTypes;
handles.archList = archList;
handles.props.names = {'Path/File','File','Type','PV','Date','Time','Date Num','Size (MB)'};
handles.props.incl = [0,0,1,1,1,1,0,0];

% Who are you?
[~,iam] = system('echo $PHYSICS_USER');
if length(iam) > 1;iam = [iam(1:end-1) '/'];else;iam = '';end
handles.savepath = ['~/' iam];

set(handles.popupToDoList,'string',cat(1,{'[All]';'[Selected]'},handles.fileTypes.dispName));
guidata(hObject,handles);

handles.recordData = [];
cname = {'n/a'};
dat = {'No files found yet. Load above.'};
cwidth = 300;
cenab = false;
set(handles.tableOfRecord,...
    'data',dat,...
    'columnname',cname,...
    'columnwidth',{cwidth});

set(handles.mainFigure,'units','pixels');
pos = get(handles.mainFigure,'position');
handles.resizeData.minSizePix = [pos(3),pos(4)];
handles.tableSel = [];
fillRecordPanel(handles)
handles.exportInclude = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mlhist_gui wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);



function [m,h] = uitableOLD(varargin)
% Since Controls [used to use] R2007b (undocumented uitable support only), force all
% version of the GUI to use this less awesome, deprecated version. Requires
% the 'v0' flag to fall back in newer versions. Don't know what will happen
% in versions early than R2007b (I think this was also present in R2007a,
% but I'm not sure...)
%
% Basically this command is the same as uitable in R2007b, but is a wrapper
% to force the version of uitable back.

% 7.4 = R2007a
% 7.5 = R2007b
% 7.6 = R2008a, etc...

% Note, use of uitableOLD for forcing the table type deprecated before
% release. Controls now has >v2012.
try
    if verLessThan('matlab','7.6')
        [m,h] = uitable(varargin{:});
    else
        [m,h] = uitable('v0',varargin{:});
    end
catch ex
    warning('Failure making a uitable. Maybe your Matlab is too old for this GUI!')
	error(ex)
end

% --- Outputs from this function are returned to the command line.
function varargout = mlhist_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function mainFigure_ResizeFcn(hObject, eventdata, handles)
fillRecordPanel(handles);


function editDirSet_Callback(hObject, eventdata, handles)


function editDirSet_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushDirBrowse_Callback(hObject, eventdata, handles)
a = get(handles.editDirSet,'string');
newpath = uigetdir(a,'Choose path to parse...');
if ischar(newpath)
    set(handles.editDirSet,'string',newpath);
end
guidata(hObject,handles);

function pushDirToday_Callback(hObject, eventdata, handles)
% Sets the next load path to the LCLS matlab data folder for today. Note
% that this button is disabled when the GUI loads if the path is
% unavailable.
a = now;
% eg: /u1/lcls/matlab/data/2014/2014-01/2014-01-21
todaypath = ['/u1/lcls/matlab/data/' datestr(a,'yyyy')...
    '/' datestr(a,'yyyy-mm')...
    '/' datestr(a,'yyyy-mm-dd')];
if exist(todaypath,'dir')
    set(handles.editDirSet,'string',todaypath);
    guidata(hObject,handles);
end


% --- Executes on button press in pushDirDate.
function pushDirDate_Callback(hObject, eventdata, handles)
% hObject    handle to pushDirDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = get(handles.mainFigure,'position');
a = datenum(calendar_pop(now,[a(1)+100, a(2)+a(4)-200]));
if isempty(a);return;end;
% eg: /u1/lcls/matlab/data/2014/2014-01/2014-01-21
todaypath = ['/u1/lcls/matlab/data/' datestr(a,'yyyy')...
    '/' datestr(a,'yyyy-mm')...
    '/' datestr(a,'yyyy-mm-dd')];
if exist(todaypath,'dir')
    set(handles.editDirSet,'string',todaypath);
    guidata(hObject,handles);
end



function pushDirCurrent_Callback(hObject, eventdata, handles)
set(handles.editDirSet,'string',pwd)
guidata(hObject,handles);



function panelRecords_ResizeFcn(hObject, eventdata, handles)
set(handles.panelRecords,'units','pixels');
pos = get(handles.mainFigure,'position');
posf = get(handles.panelRecords,'position');
if isfield(handles.resizeData,'recordVOffsetPix')
    posf(4) = pos(4)-handles.resizeData.recordVOffsetPix;
    posf(2) = handles.resizeData.recordVStart;
end
set(handles.panelRecords,'position',posf);
set(handles.panelRecords,'units','normalized');

%also make the table match.
%set(handles.tableOfRecord,'parent',handles.panelRecords);
fillRecordPanel(handles)

function fillRecordPanel(handles)
set(handles.tableOfRecord,'Units','pixels');
pos = get(handles.tableOfRecord,'position');
set(handles.tableOfRecord,'units','normalized');
d = get(handles.tableOfRecord,'data');
set(handles.tableOfRecord,'columnwidth',...
    {max([round(pos(3)/size(d,2)-10),75])});

function pushPopulateWithPath_Callback(hObject, eventdata, handles)
newfiles = parseFolderMatData(handles,...
    get(handles.editDirSet,'string'));
if ~isempty(newfiles)
    disableMe(handles);
    try
        handles.recordData = appendMatDataFiles(handles.recordData,newfiles);
        guidata(hObject,handles);
        enableMe(handles);
    catch ex
        enableMe(handles);
        throw(ex)
    end
end
updateMatDataUitable(handles);




function pushScanDates_Callback(hObject, eventdata, handles)
try
    startdate = datenum(get(handles.editStartDate,'string'), 'mm/dd/yyyy HH:MM:SS');
catch
    errordlg('Bad start date specified. Please try again.','ML Data GUI','modal');
    return
end
try
    enddate = datenum(get(handles.editEndDate,'string'), 'mm/dd/yyyy HH:MM:SS');
catch
    errordlg('Bad start date specified. Please try again.','ML Data GUI','modal');
    return
end
if enddate > now
    enddate = now;
end
if startdate > now
    startdate = now;
    errordlg('Start date not in the past. Nothing done.','ML Data GUI','modal');
    return
end
if startdate >= enddate
    errordlg('Start date must be before end date. Please try again.','ML Data GUI','modal');
    return
end
if enddate - startdate > handles.maxNdays
    errordlg(['Maximum number of days allowed is ' num2str(handles.maxNdays) '. Please reduce range and try again.'],...
        'ML Data GUI','modal');
    return
end
% Starting with first date in start date, bump up by one day until hit
% enddate.
thedate = datevec(startdate);thedate = datenum(thedate(1:3));
stopdate = datevec(enddate);stopdate = datenum(stopdate(1:3));
buff = [];todo = [];
disableMe(handles);
try
    while thedate <= stopdate
        if strcmpi(get(handles.pushStop,'visible'),'off');break;end
        workdir = ['/u1/lcls/matlab/data/' datestr(thedate,'yyyy')...
        '/' datestr(thedate,'yyyy-mm')...
        '/' datestr(thedate,'yyyy-mm-dd')];
        if ~exist(workdir,'dir')
            thedate = thedate + 1;
            continue
        end
        set(handles.textStatus,'string',workdir);drawnow
        newfiles = parseFolderMatData(handles, workdir);
        if ~isempty(newfiles)
            buff = appendMatDataFiles(buff,newfiles);
        end
        thedate = thedate + 1;
        drawnow
    end
    % Remove values with right day, wrong time...
    if ~isempty(buff)
        todo = find(([buff.dnum] < startdate) | ([buff.dnum] > enddate));
    end
    for k = length(todo):-1:1
        buff(todo(k)) = [];
    end
    if ~isempty(buff)
        handles.recordData = appendMatDataFiles(handles.recordData,buff);
        guidata(hObject,handles);
        updateMatDataUitable(handles);
    end
    enableMe(handles);
catch ex
    enableMe(handles);
    rethrow(ex);
end


function files = parseFolderMatData(handles,workdir)
% Return structure 'files' for data in specified path, sorted by
% acquisition time.
incl = handles.fileTypes.incl;
files = [];
for j = 1:length(incl)
    if incl{j}
        tmp = dir([workdir handles.pathsep handles.fileTypes.prefix{j} '*']);
        if isempty(handles.fileTypes.dateFormat{j})
            dateFormat = 'yyyy-mm-dd-HHMMSS';
        else
            dateFormat = handles.fileTypes.dateFormat{j};
        end
        stopper = length(dateFormat)+3;
        starter = length(handles.fileTypes.prefix{j})+1;
        ispscan = strcmp(handles.fileTypes.prefix{j},'PhaseScan');
        for k = 1:length(tmp)
            try
                tmp2.name = tmp(k).name;
                tmp2.path = workdir;
                tmp2.fullname = [workdir handles.pathsep tmp(k).name];
                dstr = tmp(k).name((end-stopper):(end-4)); %extract date str from file name
                tmp2.dnum = datenum(dstr,dateFormat); %convert to date number
                tmp2.type = j;
                tmp2.bytes = tmp(k).bytes;
                if handles.fileTypes.hasPV{j}
                    if ~ispscan
                        %a = regexp(tmp(k).name,'-[A-Z0-9_]+-','match');
                        a = tmp(k).name(starter:(end-stopper-1));
                        tmp2.scanPV = regexprep(a(2:(end-1)),'_',':');
                    else
                        tmp2.scanPV = tmp(k).name(11:(end-stopper-2));
                    end
                else
                    tmp2.scanPV = '';
                end
                if isempty(files)
                    files = tmp2;
                else
                    files(end+1) = tmp2;
                end
            end
        end
    end
end
if isempty(files)
    return;
end
files = util_sortStruct(files,'dnum'); %resort data in order recorded

function handles = fetchArch(handles,todo)
% For every record, get data from archive for any PVs that haven't been
% scanned yet and add it to recordData
if isempty(handles.archList) || isempty(todo);return;end
% To reduce calls to history, retrieve in one-day blocks.
% Start by sort todo list chronologically.
[~,ord] = sort([handles.recordData(todo).dnum]);todo = todo(ord);
steps = min([14,... % days per archive grab
    max([handles.recordData(todo).dnum]) - min([handles.recordData(todo).dnum])+1/24]);
hstbuff.timerange = [0,0]; %to trigger a setup call below on first pass
% Can't figure why I can't just use for k=todo directly...
for kk = 1:length(todo)
    k = todo(kk);
    if ~isfield(handles.recordData(k),'arch') || isempty(handles.recordData(k).arch) %we have a newcomer
        handles.recordData(k).arch.PV = handles.archList.PV;
        handles.recordData(k).arch.val = nan(size(handles.archList.PV));
    end
    [~,iL,iR] = union(handles.archList.PV,handles.recordData(k).arch.PV);
	% Now iR are PVs that already have entries. iL are wanted, but not
	% there yet for this file. For those with entries, see which actually
	% have data and try getting them again.
    missing = find(isempty(handles.recordData(k).arch.PV) | ...
        isnan(handles.recordData(k).arch.val));
    tryagain = intersect(missing,iR);
    pvs = [handles.recordData(k).arch.PV(tryagain,1);...
        handles.archList.PV(iL,1)];
    if ~isempty(pvs)
        if hstbuff.timerange(end) < handles.recordData(k).dnum
            drawnow
            if strcmpi(get(handles.pushStop,'visible'),'off');break;end
            set(handles.textStatus,'string',['Archiver at ', ...
                datestr(handles.recordData(k).dnum,'mm/dd/yyyy'), '...'])
            drawnow
            hstbuff = setupHistBuff(handles.archList.PV,handles.recordData(k).dnum,steps);
        end
        val = getFromHistBuff(pvs,handles.recordData(k).dnum,hstbuff);
        % now the first length(iR) values can be assigned directly
        if ~isempty(tryagain)
            handles.recordData(k).arch.val(tryagain) = val(1:length(tryagain));
        end
        % and we have to append the remaining ones.
        handles.recordData(k).arch.PV = [handles.recordData(k).arch.PV;...
            handles.archList.PV(iL,1)];
        handles.recordData(k).arch.val = [handles.recordData(k).arch.val;...
            val((1:length(iL))+length(tryagain))];
    end
end

function hstbuff = setupHistBuff(pvs,starttime,days)
hstbuff.pvs = pvs;
hstbuff.timerange = [starttime,starttime+days];
tr = {datestr(hstbuff.timerange(1)-10/86400,'mm/dd/yyyy HH:MM:SS'),...
        datestr(hstbuff.timerange(2)+10/86400,'mm/dd/yyyy HH:MM:SS')};
[~,hstbuff.time, hstbuff.val] = evalc('history(pvs,tr)');
if ~iscell(hstbuff.val)
    hstbuff.val = {hstbuff.val};
end
if ~iscell(hstbuff.time)
    hstbuff.time = {hstbuff.time};
end

function val = getFromHistBuff(pvs,time,hstbuff)
val = nan(size(pvs));
for k = 1:length(val)
    ind = find(strcmp(hstbuff.pvs,pvs{k}),1,'first');
    t = find(hstbuff.time{ind} <= time,1,'last');
    % do some averaging if a fast value
    if isempty(t);continue;end
    % wanted to do averaging, but no es bueno
    %if (t > 1) && (t + 1 < length(hstbuff.time{ind}))...
    %        && ((hstbuff.time{ind}(t-1) - hstbuff.time{ind}(t+1)) <= 6/86400)
    %    val(k) = mean(hstbuff.val{ind}((-1:1)+t));
    %else
        val(k) = hstbuff.val{ind}(t);
    %end
end



function files = appendMatDataFiles(files,newfiles)
% Parses the two file structures, merging only new file entries to files
if isempty(newfiles) %no new files to speak of! return input files
    return
elseif isempty(files) %no old files! everything in new is new!
    for k = 1:length(newfiles) %append a record number
        newfiles(k).recordNum = k;
        newfiles(k).wasScraped = false;
        newfiles(k).scrape = [];
        newfiles(k).arch = [];
    end
    files = newfiles;
    return
else
    strec = max([files.recordNum]);
    for k = 1:length(newfiles) %append a record number
        newfiles(k).recordNum = k+strec;
        newfiles(k).wasScraped = false;
        newfiles(k).scrape = [];
        newfiles(k).arch = [];
    end
    [~,new] = setdiff({newfiles.name},{files.name});
    if isempty(new)
        return
    end
    files = [files,newfiles(new)];
end

function updateMatDataUitable(handles)
if isempty(handles.recordData)
    cname = {'n/a'};
    data = {'No files known.'};
    cwidth = 300;
else
    % sort first!
    handles.recordData = doRecordSort(handles); %resort data in order requested first
    % compile the four we always do.
    cname = handles.props.names;
    data = cell(length(handles.recordData),6);
    sigfigs = 4;
    Nmin = length(cname);
    Nrec = length(handles.recordData);
    % We'll also aggregate unique archive PVs available.
    archnames = {};
    for k = 1:Nrec
        data{k,1} = handles.recordData(k).fullname;
        data{k,2} = handles.recordData(k).name;
        data{k,3} = handles.fileTypes.dispName{handles.recordData(k).type};
        data{k,4} = handles.recordData(k).scanPV;
        data{k,5} = datestr(handles.recordData(k).dnum,'yyyy/mm/dd');
        data{k,6} = datestr(handles.recordData(k).dnum,'HH:MM:SS');
        data{k,7} = handles.recordData(k).dnum;
        %data{k,8} = num2str(handles.recordData(k).bytes*1e-6,sigfigs);
        data{k,8} = handles.recordData(k).bytes*1e-6;
        if isfield(handles.recordData(k),'arch') && ...
                isfield(handles.recordData(k).arch,'PV')
            % only include if there's data available
            filt = ~isnan(handles.recordData(k).arch.val) & ~isempty(handles.recordData(k).arch.val);
            archnames = union(archnames,handles.recordData(k).arch.PV(filt));
        end
    end
    % Remove entries user wants hidden:
    cname = cname(logical(handles.props.incl));
    data = data(:,logical(handles.props.incl));
    % With the list archnames, check which the user wants in the table.
    incl = logical(handles.archList.incl);
    for k = 1:length(incl)
        if ~any(strcmp(archnames,handles.archList.PV{k}))
            incl(k) = false; %user wanted it, but no data available.
        end
    end
    % make list of PVs to build
    archList = handles.archList.PV(incl);
    % and column headers
    archname = strcat(handles.archList.desc(incl),...
        ' (', handles.archList.egu(incl),')');
    % Another pass to pull out the retrieved data...
    npv = length(archname);
    archdata = cell(Nrec,npv);
    for k = 1:Nrec
        if isfield(handles.recordData(k).arch,'PV')
            for j = 1:npv
                ind = find(strcmp(handles.recordData(k).arch.PV, archList(j)),1,'first');
                if ~isempty(ind) && ~isnan(handles.recordData(k).arch.val(ind))
                    archdata{k,j} = handles.recordData(k).arch.val(ind);
                end
            end
        end
    end
    cname = cat(2,cname,archname.');
    data = cat(2,data,archdata);
%   In handles.recordData is field .wasScraped. When set to true, this file
%   has been scraped and has more information available. Collate that data.
    if any([handles.recordData.wasScraped])
        scrapedTypes = [handles.recordData.type];
        scrapedTypes = unique(scrapedTypes([handles.recordData.wasScraped]));
        % what are the (unique) associated labels?
        scrnames = {};
        for k = 1:length(scrapedTypes)
            if ~isempty(handles.fileTypes.scrapeFunc{scrapedTypes(k)})
                scr = handles.fileTypes.scrapeFunc{scrapedTypes(k)}([]);
                for j = 1:length(scr)
                    newname = setdiff(scr(j).dispName,scrnames);
                    if ~isempty(newname) %if new, add to list.
                        scrnames = cat(2,scrnames,newname);
                    end
                end
            end
        end
        % now scrnames has a list of (merged) column header names. go
        % through each record and make a corresponding entry in the correct
        % column.
        scrdata = cell(Nrec,length(scrnames));
        for k = 1:Nrec
            if handles.recordData(k).wasScraped
                for j = 1:length(handles.recordData(k).scrape)
                    putHere = find(strcmp(scrnames,handles.recordData(k).scrape(j).dispName),1,'first');
                    %don't truncate me bro.
                    %if isfloat(handles.recordData(k).scrape(j).val);
                    %    scrdata{k,putHere} = num2str(handles.recordData(k).scrape(j).val,sigfigs);
                    %else
                        scrdata{k,putHere} = handles.recordData(k).scrape(j).val;
                    %end
                end
            end
        end
        cname = cat(2,cname,scrnames);
        data = cat(2,data,scrdata);
    end
end
set(handles.tableOfRecord,...
    'data',data,...
    'columnname',cname,...
    'ColumnEditable',false);
guidata(handles.mainFigure,handles);
fillRecordPanel(handles);

function sortedrec = doRecordSort(handles)
opt(1).fields = 'dnum';
opt(1).dir = 1;
opt(2).fields = 'dnum';
opt(2).dir = -1;
opt(3).fields = 'type';
opt(3).dir = 1;
opt(4).fields = {'type','dnum'};
opt(4).dir = 1;
opt(5).fields = {'type','dnum'};
opt(5).dir = [1,-1];
opt(6).fields = 'scanPV';
opt(6).dir = 1;
sw = get(handles.popupSortRecords,'value');
sortedrec = util_nestedSortStruct(handles.recordData,opt(sw).fields,opt(sw).dir);



function scrapeRecords(handles,toScrape)
% Scrapes different file types for information known to be embedded. In
% handles.recordData is field .wasScraped. When set to true, this file has
% already been scraped and should be skipped.

% Only scalars should be scraped from files. They should be added to the
% recordData(k) of a file as a new structure array .scrape(j) with fields
% .val, .dispName, and dispName string should include units!

% In the future, somehow these instructions should be hardlinked to the
% fileTypes config file... ha, done! The functions that scrape different
% file types for scalar values are defined externally with a prototype link
% to the associated function saved in the fileTypes config data.
needupdate = false;
maxfsize = str2double(get(handles.editMaxScrSize,'string'))*1e6;
if ~isempty(toScrape)
    for k = 1:length(toScrape)
        if strcmpi(get(handles.pushStop,'visible'),'off');break;end
        j = toScrape(k);
        if (handles.recordData(j).bytes > maxfsize) ||... % too big, don't open.
                (handles.recordData(j).wasScraped) %skip file if already scraped
            continue
        end
        if ~isempty(handles.fileTypes.scrapeFunc{handles.recordData(j).type}) % then a scrape function exists for this type.
            set(handles.textStatus,'string',[handles.recordData(j).name '...']);
            drawnow;
            scrape = handles.fileTypes.scrapeFunc{handles.recordData(j).type}([handles.recordData(j).path handles.pathsep handles.recordData(j).name]);
            if ~isempty(scrape)
                handles.recordData(j).scrape = scrape; %scrape was success, save it to the record
                handles.recordData(j).wasScraped = true; %flag as success.
                needupdate = true;
            end
        end
        % Note that next I set the flag for the file being scraped
        % regardless of success/failure. I presume if it doesn't load on one
        % attempt, it won't ever load again.
        % Note also that we marked it as scraped regardless of if it
        % has a method or not so we skip it next attempt. I presume if
        % it didn't have a method the first time, it won't later either
        
        %(Correction: The above will be the future behavior. For now, since
        %the scraping functions may be getting tested on the fly, I only
        %flag as scraped if successful, so it will always try again.
    end
    if needupdate;guidata(handles.mainFigure,handles);updateMatDataUitable(handles);end;
end
                    
function pushbutton6_Callback(hObject, eventdata, handles)
%a=get(handles.tableOfRecord,'data');
%if findstr(class(a),'java.lang.Object') % is R2007b undocumented uitable
%    a = cell(a);
%end



function popupFileType_Callback(hObject, eventdata, handles)
k = get(handles.popupFileType,'value');
set(handles.checkInclType,'value',handles.fileTypes.incl{k});


function popupFileType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function todo = makeToDoList(handles)
todo = [];
if ~isempty(handles.recordData)
    choice = get(handles.popupToDoList,'value')-2;
    %then -1 = all, 0 = selected, 1-N = corresponding file type
    switch choice
        case -1
            todo = 1:length(handles.recordData);
        case 0
            todo = handles.tableSel;
            todo = unique(todo(:,1));
        otherwise
            todo = find([handles.recordData.type] == choice);
    end
end

function pushScrapeFiles_Callback(hObject, eventdata, handles)
todo = makeToDoList(handles);
if ~isempty(todo)
    disableMe(handles);
    drawnow;
    try
        scrapeRecords(handles,todo);
        enableMe(handles);
    catch ex
        enableMe(handles);
        throw(ex)
    end
end
    

function pushRemoveFiles_Callback(hObject, eventdata, handles)
resp = questdlg('Remove specified records from list?',...
    [get(handles.mainFigure,'name') '?'],'OK','Cancel','OK');
if strcmp(resp,'OK')
    todo = makeToDoList(handles);
    if ~isempty(todo)
        disableMe(handles);
        try
            todo = sort(todo);
            for k = length(todo):-1:1
                handles.recordData(todo(k)) = [];
            end
            guidata(handles.mainFigure,handles);
            updateMatDataUitable(handles)
            enableMe(handles);
        catch ex
            enableMe(handles);
            throw(ex);
        end 
    end
end

function pushFetchArch_Callback(hObject, eventdata, handles)
todo = makeToDoList(handles);
if ~isempty(todo)
    disableMe(handles);
    drawnow;
    try
        handles = fetchArch(handles,todo);
        updateMatDataUitable(handles);
    catch ex
        enableMe(handles)
        throw(ex)
    end
    enableMe(handles);
end


function popupToDoList_Callback(hObject, eventdata, handles)


function popupToDoList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushSortRecords_Callback(hObject, eventdata, handles)
guidata(handles.mainFigure,handles);
updateMatDataUitable(handles)


function popupSortRecords_Callback(hObject, eventdata, handles)


function popupSortRecords_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [ml_table,data] = makeSavePackage(handles,fields)
ml_table.header = get(handles.tableOfRecord,'columnname').';
ml_table.data = get(handles.tableOfRecord,'data');
data = [];
if nargin < 2
    fields = {...
        'recordData',...
        'fileTypes',...
        'archList',...
        'props'};
end     
for k = 1:length(fields)
    data.(fields{k}) = handles.(fields{k});
end


function pushSaveRecords_Callback(hObject, eventdata, handles)
suggfn = ['MLData-' datestr(now,'yyyy-mm-dd-HHMMSS') '.mat'];
[fn,pn] = uiputfile([handles.savepath suggfn],'Save as...');
if fn
    handles.savepath = pn;guidata(hObject,handles);
    [ml_table,data] = makeSavePackage(handles);
    data.ml_table = ml_table;
    save([pn fn],'data');
end

function pushLoadRecords_Callback(hObject, eventdata, handles)
suggfn = ['*.mat'];
[fn,pn] = uigetfile([handles.savepath suggfn],'Load old browser record...');
if fn
    try
        handles.savepath = pn;guidata(hObject,handles);
        load([pn fn],'data');
        if (~isfield(data,'recordData'))||~isfield(data,'fileTypes')||...
                ~isfield(data,'archList')||~isfield(data,'props')
            uiwait(msgbox('Load failed! Was that the right file?','Fail','modal'))
            return
        end
        % merge file types
        flds = fieldnames(handles.fileTypes);
        for k = 1:length(data.fileTypes.prefix)
            ind = find(strcmp(handles.fileTypes.prefix,data.fileTypes.prefix{k}),1,'first');
            if isempty(ind)
                % I don't know this one...
                for j = 1:length(flds)
                    handles.fileTypes.(flds{j}) = ...
                        [handles.fileTypes.(flds{j}); data.fileTypes.(flds{j}){k}];
                end
            else
                % I do know this one, update inclusion choice.
                handles.fileTypes.incl{ind} = data.fileTypes.incl{k};
            end
        end
        % copy the archList
        resp = questdlg('Merge current PV list with list from file, or discard and replace with file?',...
            'ML Data Gui','Merge','Replace','Merge');
        switch resp
            case 'Replace'
                handles.archList = data.archList;
            case 'Merge'
                flds = fieldnames(handles.archList);
                for k = 1:length(data.archList.PV)
                    ind = find(strcmp(handles.archList.PV,data.archList.PV{k}),1,'first');
                    if isempty(ind)
                        for j = 1:length(flds)
                            handles.archList.(flds{j}) = ...
                                [handles.archList.(flds{j});data.archList.(flds{j})(k)];
                        end
                    else
                        for j = 1:length(flds)
                            handles.archList.(flds{j})(ind) = data.archList.(flds{j})(k);
                        end
                    end
                end
        end
        % copy property inclusion if same names
        for k = 1:length(data.props.names)
            ind = find(strcmp(handles.props.names,data.props.names{k}),1,'first');
            if ~isempty(ind)
                handles.props.incl(ind) = data.props.incl(k);
            end
        end
        handles.recordData = data.recordData;
        guidata(handles.mainFigure,handles);
        updateMatDataUitable(handles);
    catch ex
        warning(ex.message)
        uiwait(msgbox('Load failed! Error message in workspace.','Fail','modal'));
        return
    end
end         

% --- Executes on button press in pushLogbook.
function pushLogbook_Callback(hObject, eventdata, handles)
%exportHeaderList(handles,hObject);


function exportHeaderList(handles,hObject)
% Create a popup figure showing the list of headers available

% In progress for printing to logbook...
header = get(handles.tableOfRecord,'columnname');
width = 400;
height = 400;
mainpos = get(handles.mainFigure,'position');
fpos = [mainpos(1) + 100,...
    mainpos(2)+mainpos(4)-height-100,...
    width,...
    height];
if length(header) < 2
    handles.exportInclude = [];
    guidata(handles.mainFigure,handles);
    return
end
handles.exportInclude = zeros(1,length(header));
handles.exportInclude(2:5) = 1;
table = [header,num2cell(logical(handles.exportInclude.'))];
inclfig = figure('menubar','none',...
    'name','Export Column Selection',...
    'numbertitle','off',...
    'units','pixels',...
    'position',fpos,...
    'windowstyle','modal');

table = uitable('parent',inclfig,...
    'units','normalized',...
    'position',[0, .05, 1, 0.90],...
    'columnname',{'Header','Include'},...
    'columnformat',{'char','logical'},...
    'columnwidth',{width/2 - 50},...
    'columneditable',[false,true],...
    'data',table,...
    'tag','thetable');
buttonHandle = uicontrol(inclfig,'Style','pushbutton',...
                'String','Okay',...
                'Value',0,...
                'units','normalized',...
                'Position',[0,0,.5,.05],...
                'Callback',@(handles)okaybuttonCallback);
uiwait(inclfig);
handles = guidata(handles.mainFigure);
handles.exportInclude

function okaybuttonCallback(hObject,event,handles)
%handles = guidata(hObject);
a = get(handles.thetable,'data');
handles.exportInclude = a(:,2);
guidata(hObject,handles);
a = get(hObject,'parent');
delete(a);


% --- Executes when selected cell(s) is changed in tableOfRecord.
function tableOfRecord_CellSelectionCallback(hObject, eventdata, handles)
handles.tableSel = eventdata.Indices;
guidata(hObject,handles);


% --- Executes on button press in pushInclTypes.
function pushInclTypes_Callback(hObject, eventdata, handles)
[sel,ok]=listdlg('liststring',handles.fileTypes.dispName,...
    'selectionmode','multiple',...
    'InitialValue',find([handles.fileTypes.incl{:}]==1),...
    'Name','ML Data GUI',...
    'promptstring','Select types to include:');
if ok
    [handles.fileTypes.incl{:}] = deal(0);
    [handles.fileTypes.incl{sel}] = deal(1);
    set(hObject,'string',['File Types (' num2str(length(sel)) ')']);
end
guidata(hObject,handles);


function pushEditPVs_Callback(hObject, eventdata, handles)
resp = mlhist_pvListBuilder(...
    [handles.archList.PV,...
    handles.archList.desc,...
    handles.archList.egu],....
    'block');
incl = ones(size(resp,1),1);
% flagged all to include, then reset ones that already are deselected
for k = 1:size(resp,1)
    ind = find(strcmp(handles.archList.PV,resp(k,1)),1,'first');
    if ~isempty(ind)
        incl(k) = handles.archList.incl(k);
    end
end
% find PVs that have been removed
remv = setdiff(handles.archList.PV,resp(:,1));
% update the archlist
handles.archList.PV = resp(:,1);
handles.archList.desc = resp(:,2);
handles.archList.egu = resp(:,3);
handles.archList.incl = incl;
% remove the removed PVs from recorddata and update
if ~isempty(remv)
    for j = 1:length(remv)
        for k = 1:length(handles.recordData)
            if isfield(handles.recordData(k).arch,'PV')
                ind = find(strcmp(handles.recordData(k).arch.PV,...
                    remv(j)),1,'first');
                if ~isempty(ind)
                    handles.recordData(k).arch.PV(ind) = [];
                    handles.recordData(k).arch.val(ind) = [];
                end
            end
        end
    end
    updateMatDataUitable(handles);
end
guidata(hObject,handles);

% --- Executes on button press in pushSelPVs.
function pushSelPVs_Callback(hObject, eventdata, handles)
% hObject    handle to pushSelPVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list = strcat(handles.archList.PV, '   [',...
    handles.archList.desc, ...
    ' (', handles.archList.egu, ') ]');
init = find(handles.archList.incl==1).';
[sel,ok]=listdlg('liststring',list,...
    'selectionmode','multiple',...
    'InitialValue',init,...
    'Name','ML Data GUI',...
    'promptstring','Select Arch PVs to include:',...
    'listsize',[400,300]);
if ok && ~isequal(sel, init)
    handles.archList.incl(:) = 0;
    handles.archList.incl(sel) = 1;
    guidata(hObject,handles);
    updateMatDataUitable(handles);
end


function pushSelProps_Callback(hObject, eventdata, handles)
init = find(handles.props.incl==1);
[sel,ok]=listdlg('liststring',handles.props.names,...
    'selectionmode','multiple',...
    'InitialValue',init,...
    'Name','ML Data GUI',...
    'promptstring','Select file properties to show:',...
    'listsize',[150,150]);
if ok && ~isequal(sel, init)
    handles.props.incl(:) = 0;
    handles.props.incl(sel) = 1;
    guidata(hObject,handles);
    updateMatDataUitable(handles);
end


% --- Executes on button press in pushSaveExcel.
function pushSaveExcel_Callback(hObject, eventdata, handles)
ml_table = makeSavePackage(handles,[]);
if ~(size(ml_table.data,1) > 1 || size(ml_table.data,2) > 1);
    return
end
%suggfn = ['MLData-' datestr(now,'yyyy-mm-dd-HHMMSS') '.xls'];
[fn,pn] = uiputfile([handles.savepath '*.xls'],'Save as...');
if fn
    handles.savepath = pn;guidata(hObject,handles);
    ml_table.data(cellfun(@isempty,ml_table.data)) = {' '};
    try
        resp = xlwrite([pn fn],[ml_table.header;ml_table.data],'Matlab Historian');
    catch
        % sometimes fails on first attempt
        resp = xlwrite([pn fn],[ml_table.header;ml_table.data],'Matlab Historian');
    end
    if resp
        resp = questdlg([fn ' written. Open in LibreOffice now?'],...
            'XLS Saved','Yes','No','Yes');
        if strcmp(resp,'Yes')
            system(['libreoffice "' pn fn '" &']);
        end
    end 
end


function editMaxScrSize_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxScrSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaxScrSize as text
%        str2double(get(hObject,'String')) returns contents of editMaxScrSize as a double


% --- Executes during object creation, after setting all properties.
function editMaxScrSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxScrSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushExportToWS.
function pushExportToWS_Callback(hObject, eventdata, handles)
% hObject    handle to pushExportToWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ml_table.header = get(handles.tableOfRecord,'columnname').';
ml_table.data = get(handles.tableOfRecord,'data');
if size(ml_table.data,1) > 1 || size(ml_table.data,2) > 1
    if evalin('base','exist(''ml_table'',''var'')')
        resp = questdlg('Variable ''ml_table'' already exists in base workspace. Overwrite?',...
            'Matlab Data GUI','Overwrite','Cancel','Cancel');
        if strcmp(resp,'Overwrite');
            assignin('base','ml_table',ml_table);
        end
        return
    end
    assignin('base','ml_table',ml_table);
    msgbox('Variable ''ml_table'' created in base workspace.','Matlab Data GUI','modal');
end


function editStartDate_Callback(hObject, eventdata, handles)
% hObject    handle to editStartDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartDate as text
%        str2double(get(hObject,'String')) returns contents of editStartDate as a double


% --- Executes during object creation, after setting all properties.
function editStartDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushStartDate_Callback(hObject, eventdata, handles)
updateDateEdit(handles.editStartDate, handles);



function updateDateEdit(hObject,handles)
a = get(handles.mainFigure,'position');
try
    st = datenum(get(hObject,'string'),'mm/dd/yyyy HH:MM:SS');
catch
    st = now;
end
a = datenum(calendar_pop(st,[a(1)+100, a(2)+a(4)-200]));
if isempty(a);return;end;
set(hObject,'string',datestr(a,'mm/dd/yyyy HH:MM:SS'))


function editEndDate_Callback(hObject, eventdata, handles)
% hObject    handle to editEndDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEndDate as text
%        str2double(get(hObject,'String')) returns contents of editEndDate as a double


% --- Executes during object creation, after setting all properties.
function editEndDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushEndDate_Callback(hObject, eventdata, handles)
updateDateEdit(handles.editEndDate,handles);


function disableMe(handles)
set(handles.pushScanDates,'enable','off')
set(handles.pushScrapeFiles,'enable','off')
set(handles.pushRemoveFiles,'enable','off')
set(handles.pushPopulateWithPath,'enable','off')
set(handles.pushFetchArch,'enable','off')
set(handles.pushStop,'visible','on')

function enableMe(handles)
set(handles.pushScanDates,'enable','on')
set(handles.pushScrapeFiles,'enable','on')
set(handles.pushRemoveFiles,'enable','on')
set(handles.pushPopulateWithPath,'enable','on')
set(handles.pushFetchArch,'enable','on')
set(handles.textStatus,'string','')
set(handles.pushStop,'visible','off')

function pushStop_Callback(hObject, eventdata, handles)
set(handles.pushStop,'visible','off')


% --- Executes when user attempts to close mainFigure.
function mainFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
util_appClose(hObject);
