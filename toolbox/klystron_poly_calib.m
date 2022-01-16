function [varargout] = klystron_poly_calib(varargin)
%--------------------------------------------------------------------------
%   Date: June 2012
%
%   Author: Chris Eckman, SLAC
%           Henrik Loos,  SLAC
%
%   Description:
%
%Klystron phase calibration is preformed to find a relation between the
%requested position of the rotery Fox Phase Shifter in degrees (KPHR) and
%the actual phase (PRAW).  The relation is expressed as a polynomial
%function, in the database for each unit, such that KPHR = f(PRAW).
%The data for the klystron calibration is obtained by stepping
%through 360 degrees in the klystron phase (KPHR) and then reading
% back the detected phase from the PAD (PRAW).  Since the
%klystrons are independent form each other, they can all be phased
%for the data collection at the same time.
%
%This program will generate a text file in which the data KPHR, PRAW,
%WOBBLED and STAT are placed.  The first line of the file will be the record
%for the scan,  it will contain the date and time of the scan, the PAD ID
%in HEX form and the list of what bin is what, the data is listed
%underneath this first line.  All files are located in:
%"/u1/lcls/physics/amrf/klydata/PADcalibration"
%
%
%Modified June 2014
%made to make spare files and fixed minor issues
%Chris Eckman
%
%
% Modified December 11, 2017 J. Mock
% Fitting algorithm changed to stop data from being fit twice.
% Some asthetic changes were made to improve the look and feel
%--------------------------------------------------------------------------

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @klystron_poly_calib_OpeningFcn, ...
    'gui_OutputFcn',  @klystron_poly_calib_OutputFcn, ...
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

% --- Executes just before klystron_poly_calib is made visible.
function klystron_poly_calib_OpeningFcn(hObject,eventdata,handles,varargin)
handles.output = hObject;
%This is the time it was generated and this is printed onto the screenLI
handles.time_loaded = 0;
handles.newtime = 0;

%count and downstream...
handles.count = 0;
handles.downstream = 0;

%this is the loaded PAD
handles.PAD_ID_Loaded = '00000';
handles.PAD_ID_Database = '00000';

%For making spares
handles.is_SPARE = 0;

%pause for equiptment to catch up with electronic feedback, old code
%says 5 seconds is best, but no less then 1 and no more then 10 sec
handles.sleep_time = 5;

%storing oldp and newp
handles.oldpoly = [];
handles.newpoly = [];
handles.newvfnp = [];
handles.oldvfnp = [];

%initialise type, micro and unit
handles.type_choice = 'KLYS';
handles.sector_choice = 'LI';
handles.unit_choice = '11';
[a,process_variable_handle] = control_klysName([handles.type_choice ':' handles.sector_choice ':' handles.unit_choice]);
handles.process_variable = char(process_variable_handle);
handles.use_filename = [];

%grabs all the KLYS of type DR and LI and puts them into the list
a = aidalist('KLYS:LI% POLY')';
b = aidalist('SBST:LI% POLY')';
c = aidalist('KLYS:RF% POLY')';

list_needs_cleanup = [a;b;c];
list = strtrim(strrep(list_needs_cleanup,'        POLY',''));
[KLYS_list] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration','KLYS_unuseable_list.txt'),'%s','headerlines',6);
[SBST_list] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration','SBST_unuseable_list.txt'),'%s','headerlines',6);
handles.KLYS_list = setdiff(list,KLYS_list);
handles.SBST_list = setdiff(list,SBST_list);

%Sets the polynomial to nothing
set(handles.old,'String',sprintf('In Database:'),'fontsize', 12);
set(handles.new,'String',sprintf('New:'),'fontsize', 12);
set(handles.sector, 'Value', 28)
set(handles.unit, 'Value', 1)
set(handles.type, 'Value', 1)

%this calls the function to help set the unit and sector properly
%is_btn_changed(hObject,handles);

% Update handles structure
guidata(hObject,handles);

% ------------------------------------------------------------------------

function beginWork(hObject,handles)
    set(handles.type,'Enable','off')
    set(handles.sector,'Enable','off')
    set(handles.unit,'Enable','off')
    set(handles.SELECT_button,'Enable','off')
    set(handles.update,'Enable','off')
    set(handles.load,'Enable','off')
    set(handles.spare,'Enable','off')
    set(handles.START,'Enable','off')
    set(handles.SELECT_button,'String','Working...')
    set(handles.path,'String','Working...')
    guidata(hObject,handles);
    pause(.1)

function endWork(hObject,handles)
    set(handles.type,'Enable','on')
    set(handles.sector,'Enable','on')
    set(handles.unit,'Enable','on')
    set(handles.SELECT_button,'Enable','on')
    set(handles.SELECT_button,'String','Select')
    set(handles.update,'Enable','on')
    set(handles.load,'Enable','on')
    set(handles.spare,'Enable','on')
    set(handles.START,'Enable','on')
    guidata(hObject,handles);



function appRemote(hObject, type_in, sector_in, unit_in)

[hObject,handles]=util_appFind('klystron_poly_calib');
set(0,'ShowHiddenHandles','on')
set(handles.type, 'value',find(strcmp(get(handles.type,'string'),type_in)))
type_Callback(hObject,[],handles)
%makes sure this is the current handles structrure...
handles = guidata(hObject);

set(handles.sector, 'value',find(strcmp(get(handles.sector,'string'),sector_in)))
sector_Callback(hObject,[],handles)
handles = guidata(hObject);

set(handles.unit, 'value',find(strcmp(get(handles.unit,'string'),unit_in)))
unit_Callback(hObject,[],handles)
set(0,'ShowHiddenHandles','off')

% ------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function sector_CreateFcn(hObject,eventdata,handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function type_CreateFcn(hObject,eventdata,handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function unit_CreateFcn(hObject,eventdata,handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Outputs from this function are returned to the command line.
function varargout = klystron_poly_calib_OutputFcn(hObject,eventdata,handles)
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%Callbacks for buttons

% --- Executes on button press in abort.
function abort_Callback(hObject,eventdata,handles)
gui_acquireAbortAll;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    util_appClose(hObject);
end

% --- Executes on button press in spare.
function spare_Callback(hObject, eventdata, handles)
if get(handles.START,'value') ~= 1
    make_spare(hObject,handles);
end

% --- Executes on button press in load.
function load_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    beginWork(hObject,handles)
    [hObject, handles] = load_file_btn(hObject,handles)
    endWork(hObject,handles)
end

% --- Executes on button press in help.
function help_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    open('klystron_poly_calib.pdf');
end

% --- Executes on selection change in type.
function type_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    set(handles.unit,'Value',1)
    handles = guidata(hObject);
    %is_btn_changed(hObject,handles);
    select_stations(hObject,handles);
    handles = guidata(hObject);
    set(handles.sector, 'value',find(strcmp(get(handles.sector,'string'),handles.sector_choice)))
    handles = guidata(hObject);

    if get(handles.type, 'value') == 2
        set(handles.plot1, 'position', [60 30 70 14])
        cla(handles.plot2,'reset');
        set(handles.plot2, 'visible', 'off')
        set(handles.plot3, 'position', [60 8 70 14])
    else
        set(handles.plot1, 'position', [56.933 35.288 75 9])
        set(handles.plot2, 'visible', 'on')
        set(handles.plot3, 'position', [56.767 6.66 75 9])
    end
end
% --- Executes on button press in SELECT_button.
function [handles] =  SELECT_button_Callback(hObject, eventdata, handles)
% hObject    handle to SELECT_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.START,'value') ~= 1
    beginWork(hObject,handles)
    handles = is_btn_changed(hObject,handles);
    endWork(hObject,handles)
end

% --- Executes on selection change in sector.  For klystron sector
function sector_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    set(handles.unit, 'Value', 1)
    %is_btn_changed(hObject,handles)
    select_stations(hObject,handles);
end

% --- Executes on selection change in unit. For klystron unit
function unit_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    %is_btn_changed(hObject,handles);
    select_stations(hObject,handles);
end

% --- Executes on button press in POLY_radio_btn.
function [handles] = POLY_radio_btn_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    set(handles.VFNP_radio_btn,'value',0)
    handles.oldpoly = lcaGetSmart([handles.process_variable ':POLY']);
    if isempty(handles.newpoly)
        set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);
        set(handles.new,'String','New:', 'fontsize', 12);
    else
        set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);
        set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
    end
    set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')
end

% --- Executes on button press in VFNP_radio_btn.
function [handles] = VFNP_radio_btn_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    set(handles.POLY_radio_btn,'value',0)
    handles.oldvfnp = lcaGetSmart([handles.process_variable ':VFNP']);
    if isempty(handles.newpoly)
        set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldvfnp)), 'fontsize', 12);
        set(handles.new,'String','New:', 'fontsize', 12);
    else
        set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldvfnp)), 'fontsize', 12);
        set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newvfnp)), 'fontsize', 12);
    end
    set(handles.fit_compair,'title','Polynomial VFNP Fit Comparison')
end

%These next two callbacks are for buttons that can change Process Varibles
% --- Executes on button press in update.
function update_Callback(hObject,eventdata,handles)
if get(handles.START,'value') ~= 1
    beginWork(hObject,handles)
    update_poly_btn(hObject,handles);
    endWork(hObject,handles)
end

% --- Executes on button press in START.
function START_Callback(hObject,eventdata,handles)
handles.PAD_ID_Loaded = '00000';
handles.PAD_ID_Database = '00000';
[status_klys,handles] = sector_unit(hObject,handles);
if strcmp(handles.type_choice,'KLYS')
    %warns the user that it can kill the beam, needs to be replaced with a
    %check that will tell if klystron is on and deactivated from the beam Also
    %tell user that (if clicked on active on klystron) it can not be done
    if status_klys == 1
        set(handles.check,'string',sprintf('Klystron Status:Accelerate'),'Backgroundcolor', 'red','ForegroundColor', 'black','fontsize',12)
        questdlg(['Can not run scan on ',handles.process_variable,'  This klystron is active and this action will kill the beam.'] , ...
            'Warning!', ...
            'Cancel','Cancel');
        %Need to set the button back to default
        abort_Callback(hObject,handles)

    elseif status_klys == 2

        set(handles.check,'string',sprintf('Klystron Status:No Accelerate'),'Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
        %needed for turning on the start button
        if ~gui_acquireStatusSet(hObject,handles,1);return, end
        if handles.is_SPARE
            choice = questdlg(['Running scan to make a SPARE file.  This action will create new data.  Would you like to continue?'] , ...
                'Warning!', ...
                'Yes','No','No');
            switch choice
                case 'Yes'
                    [hObject,handles] = klys_scan(hObject,handles);
            end
        else
            choice = questdlg(['Running scan on ',handles.process_variable,'  This action will replace current data or create new data.  Would you like to continue?'] , ...
                'Warning!', ...
                'Yes','No','No');
            switch choice
                case 'Yes'
                    [hObject,handles] = klys_scan(hObject,handles);
            end
        end
        gui_acquireStatusSet(hObject,handles,0);

    else
        set(handles.check,'string',sprintf('Klystron Status:Maintenance'),'Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
        %needed for turning on the start button
        if ~gui_acquireStatusSet(hObject,handles,1);return, end
        if handles.is_SPARE
            choice = questdlg(['Running scan to make a SPARE file.  This action will create new data.  Would you like to continue?'] , ...
                'Warning!', ...
                'Yes','No','No');
            switch choice
                case 'Yes'
                    [hObject,handles] = klys_scan(hObject,handles);
            end
        else
            choice = questdlg(['Running scan on ',handles.process_variable,'  This action will replace current data or create new data.  Would you like to continue?'] , ...
                'Warning!', ...
                'Yes','No','No');
            switch choice
                case 'Yes'
                    [hObject,handles] = klys_scan(hObject,handles);
            end
        end
        gui_acquireStatusSet(hObject,handles,0);

    end
end

if strcmp(handles.type_choice,'SBST')
    set(handles.check,'string','Subbooster Systems','Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
    %needed for turning on the start button
    if ~gui_acquireStatusSet(hObject,handles,1);return, end
    choice = questdlg(['Running Subbooster scan on ',handles.process_variable,'  This action will replace current data or create new data.  DO NOT RUN ON ACTIVE BEAM!  Would you like to continue?'] , ...
        'Warning!', ...
        'Yes','No','No');
    switch choice
        case 'Yes'
            [handles] = sbst_scan(hObject,handles);
    end
    gui_acquireStatusSet(hObject,handles,0);
end

%--------------------------------------------------------------------------
%Files for buttons

function [handles] = make_spare(hObject,handles)
handles.is_SPARE = cell2mat(get(handles.spare,{'value'}));
guidata(hObject, handles);

function [handles] = update_poly_btn(hObject,handles)
%This will update the polynomials that were just generated or loaded...
handles.PAD_ID_Loaded = '00000';
handles.PAD_ID_Database = '00000';
[status_klys,handles] = sector_unit(hObject,handles);

if strcmp(handles.type_choice, 'KLYS')
    [handles] = KLYS_read_txt(hObject,handles,handles.use_filename);
    if status_klys == 1
        set(handles.check,'string',sprintf('Klystron Status:Accelerate'),'Backgroundcolor', 'red','ForegroundColor', 'black','fontsize', 12)
        questdlg(['Can not update ',handles.process_variable,'  This klystron is active and this action can disrupt the beam.'] , ...
            'Warning!', ...
            'Cancel','Cancel');
    elseif status_klys == 2
        set(handles.check,'string',sprintf('Klystron Status:No Accelerate'),'Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
        [handles] = update_putin_KLYS(hObject,handles);
    else
        set(handles.check,'string',sprintf('Klystron Status:Maintenance'),'Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
        [handles] = update_putin_KLYS(hObject,handles);
    end
    %re-evaluate and plots again
    handles.PAD_ID_Loaded = '00000';
    handles.PAD_ID_Database = '00000';
    [status_klys,handles] = sector_unit(hObject,handles);
    [handles] = KLYS_read_txt(hObject,handles,handles.use_filename);
else
    [hObject,handles] = SBST_read_txt(hObject,handles,handles.use_filename);
    set(handles.check,'string','Subbooster Systems','Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
    [handles] = update_putin_SBST(hObject,handles);
    %re-evaluate and plots again
    handles.PAD_ID_Loaded = '00000';
    handles.PAD_ID_Database = '00000';
    [status_klys,handles] = sector_unit(hObject,handles);
    [hObject,handles] = SBST_read_txt(hObject,handles,handles.use_filename);
end
guidata(hObject, handles);

function [handles] = update_putin_KLYS(hObject,handles)
if isempty(handles.newpoly)
    questdlg(['No new gennerated data or loaded data from files to update ',handles.process_variable, ',  please generate or load file to update'] , ...
        'Warning!', ...
        'Cancel','Cancel');
else
    choice = questdlg(['This will overwrite the polynomial data in the database for ',handles.process_variable,' with recently generated data or data from a loaded spare file. Would you like to continue?'], ...
        'Warning!', ...`
        'Yes','No','No');
    switch choice
        case 'Yes'
            if handles.use_filename ~= 0
                spare_only = cell2mat(regexp(handles.use_filename,'[\w]{0,5}(?=_)','match'));
            elseif handles.is_SPARE
                questdlg(['No spare file loaded... Please load spare file before trying again.'] , ...
                    'Warning!', ...
                    'Cancel','Cancel');
            end
            if handles.is_SPARE && strcmp(spare_only,'SPARE') && strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded)
                filename = ['KLYS_' handles.sector_choice '_00' handles.unit_choice '_' datestr(handles.time_loaded(17:end),'yyyy-mm-dd_HHMMSS') '.txt'];
                rename_file = fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename);
                spare_file = fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',handles.use_filename);
                %PUTTING INFO IN!!!!!!!!!!!!!!!!!!!!!!!
                system(['mv -f ', spare_file,' ', rename_file]);
                %PUTTING INFO IN!!!!!!!!!!!!!!!!!!!!!!!
                handles.use_filename = filename;
            elseif handles.is_SPARE && ~strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded)
                questdlg(['The PAD ID for the spare file (', handles.PAD_ID_Database, ') and the PAD ID for the database (', handles.PAD_ID_Loaded,') do not match.'] , ...
                    'Warning!', ...
                    'Cancel','Cancel');
                return
            end
            [type_raw,micro,unit] = model_nameSplit(handles.process_variable);
            on_scp = strcmp(micro,'KLYS') || strcmp(micro,'SBST');
            %PUTTING INFO IN!!!!!!!!
            if on_scp
                [process_variable_handle] = control_klysName(handles.process_variable);
                pvaSet([process_variable_handle{:} ':POLY'], single(handles.newpoly));
            else
                lcaPut([handles.process_variable ':POLY'],handles.newpoly);
            end
            %PUTTING INFO IN!!!!!!!!

            handles.oldpoly = lcaGetSmart([handles.process_variable ':POLY']);
            handles.newpoly = 0;

            set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);
            set(handles.new,'String',sprintf('New:'),'fontsize', 12);
            guidata(hObject, handles);
    end
end


function [handles] = update_putin_SBST(hObject,handles)
if isempty(handles.newpoly) && isempty(handles.newvfnp)
    questdlg(['No new gennerated data or loaded data from files to update ',handles.process_variable, ',  please generate or load file to update'], ...
        'Warning!', ...
        'Cancel','Cancel');
else
    choice = questdlg(['This will overwrite the polynomial data in the database for ',handles.process_variable,' with recently generated data or loaded data from file. Which polynomial would you like to update?'], ...
        'Warning!', ...
        'Ok','Cancel','Cancel');

            set(handles.VFNP_radio_btn,'value',0)
            set(handles.POLY_radio_btn,'value',1)
            set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')

            [type_raw,micro,unit] = model_nameSplit(handles.process_variable);
            on_scp = strcmp(micro,'KLYS') || strcmp(micro,'SBST');

            disp('New Poly')
            disp(handles.newpoly)

            %PUTTING INFO IN!!!!!!!!
            if on_scp
            	[process_variable_handle] = control_klysName(handles.process_variable);
            	pvaSet([process_variable_handle{:} ':POLY'],single(handles.newpoly));
            else
            	lcaPut([handles.process_variable ':POLY'],handles.newpoly);
            end
            %PUTTING INFO IN!!!!!!!!

            handles.oldpoly = lcaGetSmart([handles.process_variable ':POLY']);
            handles.newpoly = [];

            set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);
            set(handles.new,'String',sprintf('New:'),'fontsize', 12);


            %set(handles.VFNP_radio_btn,'value',1)
            %set(handles.POLY_radio_btn,'value',0)
            %set(handles.fit_compair,'title','Polynomial VFNP Fit Comparison')

            disp('New VFNP')
            disp(handles.newvfnp)

            [type_raw,micro,unit] = model_nameSplit(handles.process_variable);
            %PUTTING INFO IN!!!!!!!!
            if on_scp
            	[process_variable_handle] = control_klysName(handles.process_variable);
            	pvaSet([process_variable_handle{:} ':VFNP'],single(handles.newvfnp));
            else
            	lcaPut([handles.process_variable ':VFNP'],handles.newvfnp);
            end
            %PUTTING INFO IN!!!!!!!!

            handles.oldvfnp = lcaGetSmart([handles.process_variable ':VFNP']);
            handles.newvfnp = [];

            set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldvfnp)), 'fontsize', 12);
            set(handles.new,'String',sprintf('New:'),'fontsize', 12);
end
guidata(hObject, handles);

function [hObject,handles,filename] = load_file_btn(hObject,handles)
%this will load any found file that is a .txt then displays the
%infromation and extracts the unit and sector automattacally
set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')
handles.PAD_ID_Loaded = '00000';
handles.PAD_ID_Database = '00000';
handles.oldpoly = [];
handles.newpoly = [];
handles.newvfnp = [];
handles.oldvfnp = [];

filename = uigetfile(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration','*.txt'),'select file');

handles.use_filename = filename;
guidata(hObject,handles);

set(handles.status_box,'String',sprintf(''))
%checks if there is a file, but if not return
if filename ~= 0 % exist(filename)
    sh = cell2mat(regexp(filename,'(?<=_)[\w]+(?=_00)','match'));
    uh = cell2mat(regexp(filename,'(?<=_00)[\d]+(?=.)','match'));
    type = cell2mat(regexp(filename,'[\w]{0,4}(?=_L)','match'));

    spare_only = cell2mat(regexp(filename,'[\w]{0,5}(?=_)','match'));
else
    return
end

%checks to see if it is the unusable list
if strcmp(filename,'SBST_unuseable_list.txt') || strcmp(filename,'KLYS_unuseable_list.txt')
    system(['emacs ' fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename)])
    a = aidalist('KLYS:LI% POLY')';
    b = aidalist('SBST:LI% POLY')';
    c = aidalist('KLYS:RF% POLY')';
    list_needs_cleanup = [a;b;c];
    list = strtrim(strrep(list_needs_cleanup,'        POLY',''));
    [SBST_list] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration','SBST_unuseable_list.txt'),'%s','headerlines',6);
    [KLYS_list] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration','KLYS_unuseable_list.txt'),'%s','headerlines',6);
    handles.KLYS_list = setdiff(list,KLYS_list);
    handles.SBST_list = setdiff(list,SBST_list);
    guidata(hObject,handles);
elseif ~strcmp(type,'KLYS') && ~strcmp(type,'SBST') && ~strcmp(spare_only,'SPARE')
    %abort if wrong file name/type
    questdlg('File does not have the right format.'  , ...
        'Warning!', ...
        'Cancel','Cancel');
elseif strcmp(handles.type_choice, 'SBST') && strcmp(spare_only,'SPARE')
    questdlg('Subbooster Systems can not load a SPARE file.' , ...
        'Warning!', ...
        'Cancel','Cancel');
elseif strcmp(type,'KLYS') || strcmp(spare_only,'SPARE')
    if ~strcmp(spare_only,'SPARE')
        [hObject,handles] = prep_load(hObject,handles,handles.KLYS_list,filename,type,sh,uh);
    end
    [status_klys,handles] = sector_unit(hObject,handles);
    [handles] = KLYS_read_txt(hObject,handles,filename);
    set(handles.spare, 'visible', 'on')
    set(handles.POLY_radio_btn,'value',1)
    set(handles.VFNP_radio_btn,'value',0)
    set(handles.VFNP_radio_btn, 'visible','off')
    set(handles.POLY_radio_btn, 'visible','off')
    set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')

    if strcmp(spare_only,'SPARE')
        set(handles.status_box,'string',sprintf('SPARE file name: %s', filename))
        set(handles.spare,'value',1)
        [handles] = make_spare(hObject,handles);
        set(handles.record,'String',sprintf('Loaded SPARE data file for Klystron Phase Calibration \n With loaded PAD ID: %s  (HEX)', handles.PAD_ID_Loaded), 'fontsize', 12);
        set(handles.path,'String',sprintf('Loaded SPARE data file to replace file for: %s', handles.process_variable),'fontsize', 15);
        set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
        if handles.is_SPARE && strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded)
            choice = questdlg(['PAD ID for spare file (', handles.PAD_ID_Loaded, ') matches the PAD ID for current database (', handles.PAD_ID_Database,').  Would you like to use spare file to overwrite file for ',handles.process_variable,'?'], ...
                'Warning!', ...`
                'Yes','No','No');
            switch choice
                case 'Yes'
                    [handles] = update_putin_KLYS(hObject,handles);
            end
        end
    else
        set(handles.record,'String',sprintf('Loaded data file for Klystron Phase Calibration for %s \n With loaded PAD ID: %s  (HEX)',handles.process_variable, handles.PAD_ID_Loaded), 'fontsize', 12);
        set(handles.path,'String',sprintf('Loaded data file for: %s', handles.process_variable),'fontsize', 15);
        set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
    end
elseif strcmp(type,'SBST')
    [hObject,handles] = prep_load(hObject,handles,handles.SBST_list,filename,type,sh,num2str(str2num(uh)));

    set(handles.spare, 'visible', 'off')
    set(handles.check,'string','Subbooster Systems','Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
    set(handles.POLY_radio_btn,'value',1)
    set(handles.VFNP_radio_btn,'value',0)
    set(handles.VFNP_radio_btn, 'visible','on')
    set(handles.POLY_radio_btn, 'visible','on')
    set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')

    [status_klys,handles] = sector_unit(hObject,handles);
    [hObject,handles] = SBST_read_txt(hObject,handles,filename);

    set(handles.path,'String',sprintf('Loaded data file for: %s', handles.process_variable),'fontsize', 15);
    set(handles.record,'String',sprintf('Loaded data file for Subbooster Phase Calibration for %s \n With loaded PAD ID:%s  (HEX)',handles.process_variable, handles.PAD_ID_Loaded), 'fontsize', 12);
    set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
end


function [hObject,handles] = prep_load(hObject,handles,list,filename,type,sh,uh)
set(handles.status_box,'string',sprintf('File name of last scan taken: %s', filename))
[type_raw,micro,unit] = model_nameSplit(list);

type_list = unique(type_raw);
micro_list = unique(micro);
selected_micro = strcmp(micro,sh);
selected_type = strcmp(type_raw,type);

%seprates and chooses only the unit choices for the type and for the sector
unit_choices = unit(selected_micro & selected_type);
unit_choices = sort(unit_choices);

set(handles.unit, 'string', unit_choices)
set(handles.sector, 'string', micro_list)
set(handles.type, 'string', type_list)
set(handles.spare,'value',0)

P = get(handles.sector,{'string','value'});
val_sect = strmatch(sh,P{1});

Q = get(handles.type,{'string','value'});
val_type = strmatch(type,Q{1});

Q = get(handles.unit,{'string','value'});
val_unit = strmatch(uh,Q{1});
set(handles.type,'Value',val_type);
set(handles.sector,'Value',val_sect);
set(handles.unit,'Value',val_unit);

handles.type_choice = type;
handles.sector_choice = sh;
handles.unit_choice = uh;
[a,process_variable_handle] = control_klysName([type ':' sh ':' uh]);
handles.process_variable = char(process_variable_handle);
guidata(hObject,handles);

%--------------------------------------------------------------------------
%The most used files, these detect the change in the Type, Section and
%Unit.  This will put the approprate information where it needs to be and
%will give the mojority of storage for the handles used in calculation and
%determineing the right type,section and unit.

function[handles] = select_stations(hObject,handles)
[status_klys,handles] = sector_unit(hObject,handles);
%guidata(hObject,handles);

function [handles] = is_btn_changed(hObject,handles)
%If you go to a sector/unit with existing data then it will automattically
%extract data and output the data on the screen.  If there is nothing there
%then it clears the plots, if the button is pushed then it will do
%nothing. The same goes for the function sector_Callback
%reseting things
handles.PAD_ID_Loaded = '00000';
handles.PAD_ID_Database = '00000';
handles.oldpoly = [];
handles.newpoly = [];
handles.newvfnp = [];
handles.oldvfnp = [];
handles.use_filename = [];
guidata(hObject,handles);

set(handles.status_box,'String',sprintf(''))
set(handles.time, 'string', ' ')
set(handles.old,'String',sprintf('In Database:'),'fontsize', 12);
set(handles.new,'String',sprintf('New:'),'fontsize', 12);

cla(handles.plot1,'reset');
cla(handles.plot3,'reset');
if strcmp(get(handles.plot2, 'visible'), 'on')
    cla(handles.plot2,'reset');
end

[status_klys,handles] = sector_unit(hObject,handles);

%finds files in directory
klys_filename = char(['KLYS_' handles.sector_choice '_00' handles.unit_choice '_*.txt']);
sbst_filename = char(['SBST_' handles.sector_choice '_000' handles.unit_choice '_*.txt']);
d_KLYS = dir(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',klys_filename));
d_SBST = dir(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',sbst_filename));

%deleting old files for klys and for sbst
deleting_old_files(d_KLYS);
deleting_old_files(d_SBST);

%resetting Spare
set(handles.spare,'value',0)
handles.is_SPARE = 0;

%checks to see if there is a file avabile to user
if ~isempty(d_KLYS) && strcmp(handles.type_choice,'KLYS')
    [x_KLYS,y_KLYS]=sort(datenum(char({d_KLYS.date})));
    most_recent_file_KLYS=char(d_KLYS(y_KLYS(end)).name);
    file_of_intrest_KLYS = sprintf('%s',most_recent_file_KLYS);
    handles.use_filename = file_of_intrest_KLYS;%NEW!!!
    file_of_intrest_SBST = 'NaN';
elseif ~isempty(d_SBST) && strcmp(handles.type_choice,'SBST')
    [x_SBST,y_SBST]=sort(datenum(char({d_SBST.date})));
    most_recent_file_SBST=char(d_SBST(y_SBST(end)).name);
    file_of_intrest_SBST = sprintf('%s',most_recent_file_SBST);
    handles.use_filename = file_of_intrest_SBST;
    file_of_intrest_KLYS = 'NaN';
else
    file_of_intrest_KLYS = 'NaN';
    file_of_intrest_SBST = 'NaN';
end

%test to see if file is loaded or not for both SBST and KLYS
if (exist(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',file_of_intrest_KLYS)) == 2) && strcmp(handles.type_choice,'KLYS')
    filename = file_of_intrest_KLYS;
    [handles] = KLYS_read_txt(hObject,handles,filename);

    set(handles.spare, 'visible', 'on')
    set(handles.path,'string',sprintf('Current data from file for %s', handles.process_variable),'fontsize', 15);
    set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
    set(handles.status_box,'string',sprintf('File Name of Last Scan Taken:%s', filename))
elseif (exist(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',file_of_intrest_SBST)) == 2) && strcmp(handles.type_choice,'SBST')
    handles.oldvfnp = lcaGetSmart([handles.process_variable ':VFNP']);

    filename = file_of_intrest_SBST;
    [hObject,handles] = SBST_read_txt(hObject,handles,filename);

    set(handles.spare, 'visible', 'off')
    set(handles.path,'string',sprintf('Current data from file for %s', handles.process_variable),'fontsize', 15);
    set(handles.new,'String',(sprintf('From File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
    set(handles.status_box,'string',sprintf('File Name of Last Scan Taken:%s', filename))
elseif strcmp(handles.type_choice,'KLYS')
    set(handles.spare, 'visible', 'on')
    set(handles.POLY_radio_btn,'value',1)
    set(handles.VFNP_radio_btn,'value',0)
    set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')
    set(handles.VFNP_radio_btn, 'visible','off')
    set(handles.POLY_radio_btn, 'visible','off')
    set(handles.path,'String',sprintf('Create New Data for %s', handles.process_variable),'fontsize', 15);
    set(handles.status_box,'String',sprintf(''))
    handles.oldpoly = lcaGetSmart([handles.process_variable ':POLY']);

    [handles] = check_PAD_ID(hObject,handles);
    set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);
    set(handles.new,'String',sprintf('New File:'),'fontsize', 12);
    set(handles.time, 'string', ' ')

else
    set(handles.spare, 'visible', 'off')
    set(handles.POLY_radio_btn,'value',1)
    set(handles.VFNP_radio_btn,'value',0)
    set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')
    set(handles.VFNP_radio_btn, 'visible','on')
    set(handles.POLY_radio_btn, 'visible','on')
    set(handles.path,'String',sprintf('Create New Data for %s', handles.process_variable),'fontsize', 15);
    set(handles.status_box,'String',sprintf(''))
    handles.oldvfnp = lcaGetSmart([handles.process_variable ':VFNP']);
    handles.oldpoly = lcaGetSmart([handles.process_variable ':POLY']);

    [handles] = check_PAD_ID(hObject,handles);
    set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);
    set(handles.new,'String',sprintf('New file:'),'fontsize', 12);
    set(handles.time, 'string', ' ')

end
guidata(hObject,handles);

function deleting_old_files(List_needs_deleting)
%for deleting old files, will delete any extra files after the limit of 1
if ~isempty(List_needs_deleting) && ~(size(List_needs_deleting,1) <= 1)
    [x,y]=sort(datenum(char({List_needs_deleting.date})));
    r = char(List_needs_deleting(y).name);
    r = flipud(r);
    del = r(3:end,:);
    del = cellstr(del);
    s = size(del,1);
    n = 1;
    %While del is not empty, aka filled with file to delete
    while ~isempty(del{n})
        delete(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',del{n}))
        n = n+1;
        if n == (s+1)
            break
        end
    end
end

function [status_klys,handles] = sector_unit(hObject,handles)
%For Klystron sector
sector_val = get(handles.sector,'Value');
sector_str  = get(handles.sector,'String');
sh = sector_str{sector_val};

type_val = get(handles.type,'Value');
type_str = get(handles.type,'String');
type = type_str{type_val};

%handles the aida list information to usable info
if strcmp(type,'KLYS')
    list = handles.KLYS_list;
else
    list = handles.SBST_list;
end
[type_raw,micro,unit] = model_nameSplit(list);

type_list = unique(type_raw);
micro_list = unique(micro);
if strcmp(micro,sh) == 0
    sh = 'LI11';
end
selected_micro = strcmp(micro,sh);
selected_type = strcmp(type_raw,type);

%seprates and chooses only the unit choices for the type and for the sector
unit_choices = unit(selected_micro & selected_type);
unit_choices = sort(unit_choices);

set(handles.unit, 'string', unit_choices)
set(handles.sector, 'string', micro_list,'value',find(strcmp(micro_list,sh)))
set(handles.type, 'string', type_list)

unit_val = get(handles.unit,'Value');
unit_str = get(handles.unit,'String');
uh = unit_str{unit_val};

[a,process_variable] = control_klysName([type ':' sh ':' uh]);

handles.type_choice = type;
handles.sector_choice = sh;
handles.unit_choice = uh;
handles.process_variable = char(process_variable);

%TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% [type_raw,micro,unit] = model_nameSplit(handles.process_variable);
% on_scp = strcmp(micro,'KLYS') || strcmp(micro,'SBST');
% if on_scp == 1
%     status_klys = bitand(control_klysStatGet(handles.process_variable,6),7) %TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% else
    status_klys = control_klysStatGet(handles.process_variable); %TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% end
%TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

if strcmp(handles.type_choice,'KLYS')
    if status_klys == 1
        set(handles.check,'string',sprintf('Klystron Status:Accelerate'),'Backgroundcolor', 'red','ForegroundColor', 'black','fontsize', 12)
    elseif status_klys == 2
        set(handles.check,'string',sprintf('Klystron Status:No Accelerate'),'Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
    else
        set(handles.check,'string',sprintf('Klystron Status:Maintenance'),'Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
    end
else
    set(handles.check,'string','Subbooster Systems','Backgroundcolor', 'green','ForegroundColor', 'black','fontsize', 12)
end

[handles] = check_PAD_ID(hObject,handles);
guidata(hObject,handles)

function [handles] = check_PAD_ID(hObject,handles)
%if PAD does not have value in it, find it and run this code
% % %TEST!!!
% if epicsSimul_status == 1 %REMOVE!!!
%     try %REMOVE!!!
%         lcaGet('yoyo')%REMOVE!!!
%     catch%REMOVE!!!
%         return%REMOVE!!!
%     end%REMOVE!!!
%     lcaPut([handles.process_variable ':SID'],[0 round(rand*9999)]);%REMOVE!!!
% end%REMOVE!!!
% %TEST!!!
PAD_ID_check = lcaGetSmart([handles.process_variable ':SID']);
if PAD_ID_check(2) < 0
    PAD_ID_m = (typecast(int16(PAD_ID_check),'uint16'));
else
    PAD_ID_m = PAD_ID_check;
end
PAD_ID = dec2hex(PAD_ID_m(2));
handles.PAD_ID_Database = PAD_ID;
str_compare_val = '00000';
if strcmp(handles.type_choice, 'KLYS')
    if ~strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded) && ~strcmp(handles.PAD_ID_Loaded,str_compare_val)
        %check to see if PAD is the different for loaded as for current and prints both
        set(handles.record,'String',sprintf('Klystron Phase Calibration for %s \n With current database PAD ID: %s  (HEX) and loaded PAD ID from the file: %s  (HEX)',handles.process_variable, handles.PAD_ID_Database, handles.PAD_ID_Loaded), 'fontsize', 12);
    elseif strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded) && ~strcmp(handles.PAD_ID_Loaded,str_compare_val)
        set(handles.record,'String',sprintf('Klystron Phase Calibration for %s \n With current database and loaded file PAD ID: %s  (HEX)',handles.process_variable, handles.PAD_ID_Database), 'fontsize', 12);
    else
        %if PAD has no loaded and prints current
        set(handles.record,'String',sprintf('Klystron Phase Calibration for %s \n With current database PAD ID: %s  (HEX)',handles.process_variable, handles.PAD_ID_Database), 'fontsize', 12);
    end
else
    if ~strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded) && ~strcmp(handles.PAD_ID_Loaded,str_compare_val)
        %check to see if PAD is the different for loaded as for current and prints both
        set(handles.record,'String',sprintf('Subbooster Phase Calibration for %s \n With current database PAD ID: %s  (HEX) and loaded PAD ID from the file: %s  (HEX)',handles.process_variable, handles.PAD_ID_Database, handles.PAD_ID_Loaded), 'fontsize', 12);
    elseif strcmp(handles.PAD_ID_Database,handles.PAD_ID_Loaded) && ~strcmp(handles.PAD_ID_Loaded,str_compare_val)
        set(handles.record,'String',sprintf('Subbooster Phase Calibration for %s \n With current database and loaded file PAD ID: %s  (HEX)',handles.process_variable, handles.PAD_ID_Database), 'fontsize', 12);
    else
        %if PAD has no loaded and prints current
        set(handles.record,'String',sprintf('Subbooster Phase Calibration for %s \n With current database PAD ID: %s  (HEX)',handles.process_variable, handles.PAD_ID_Database), 'fontsize', 12);
    end
end
guidata(hObject,handles)

%--------------------------------------------------------------------------
%SBST Files

function [handles] = sbst_scan(hObject,handles)
% AIDA-PVA imports
global pvaSet;
global AIDA_BOOLEAN;

handles.newtime = now;
PAD_ID_check = lcaGetSmart([handles.process_variable ':SID']);
if PAD_ID_check(2) < 0
    PAD_ID_m = (typecast(int16(PAD_ID_check),'uint16'));
else
    PAD_ID_m = PAD_ID_check;
end
PAD_ID = dec2hex(PAD_ID_m(2));
handles.PAD_ID_Database = PAD_ID;

set(handles.new,'String','From File:','fontsize',12);
val_VFNP=get(handles.VFNP_radio_btn,'Value');
val_POLY=get(handles.POLY_radio_btn,'Value');
val_type=get(handles.type,'Value');
val_sect=get(handles.sector,'Value');
val_unit=get(handles.unit,'Value');
val_pos=get(handles.scanProgress_txt,'Position');

%handles the aida list information to usable info
[type_raw,micro,unit] = model_nameSplit(handles.SBST_list);

selected_micro = strcmp(micro,handles.sector_choice);
type_wanted = 'KLYS';
selected_type = strcmp(type_raw,type_wanted);

%seprates and chooses only the unit choices for the type and for the sector
unit_choices = unit(selected_micro & selected_type);
unit_choices = sort(unit_choices);

%gets the initial information and stores it for later to set back to initial
SBST_old = lcaGetSmart([handles.process_variable ':KPHR']);

%PUTTING INFO IN!!!!!!!!
[type_raw,micro,unit] = model_nameSplit(handles.process_variable);
on_scp = strcmp(micro,'KLYS') || strcmp(micro,'SBST');
%if it is 1 then it is on scp
if on_scp == 1
    [process_variable,a] = control_klysName(handles.process_variable);
    old_FEMN = pvaGet(strcat(process_variable,':FEMN'), AIDA_BOOLEAN);
    pvaSet(strcat(process_variable,':FEMN'), true);
else
    KPHR_trim = lcaGetSmart([handles.process_variable ':PTRM']);
    lcaPut([handles.process_variable ':PTRM'],0)
      for counter = 1:length(unit_choices)
          KLYS_old(counter) = lcaGetSmart(['KLYS:' handles.sector_choice ':' unit_choices{counter} ':KPHR.DISP']);
          lcaPut(['KLYS:' handles.sector_choice ':' unit_choices{counter} ':KPHR.DISP'],1);
      end
end
%PUTTING INFO IN!!!!!!!!

handles.downstream = num2str(numel(unit_choices));
guidata(hObject,handles)

%turn KPHR back into voltage, use the polyniomial function
SVFNP = lcaGetSmart([handles.process_variable ':VFNP']);

pause(handles.sleep_time-3);

n = 0;
for phase = [-180:8:180 172:-8:-180]
    n = n + 1;
    set(handles.status_box,'String',sprintf('Setting KPHR to %7.2f, this takes several minutes....',phase), 'fontsize', 10)

    %PUTTING INFO IN!!!!!!!!
    control_phaseSet(handles.process_variable,phase,0,0,'KPHR');
    %PUTTING INFO IN!!!!!!!!

    %extra time for first point
    if n == 1
        pause(handles.sleep_time);
    end

    %for abort button, checks to see if pushed
    pause(handles.sleep_time);
    if ~gui_acquireStatusGet(hObject,handles), break, end

    SPRAW = lcaGetSmart([handles.process_variable ':PRAW']);
    SSTAT = lcaGetSmart([handles.process_variable ':STAT']);

    [a,process_varible_name] = control_klysName(strcat('KLYS:', handles.sector_choice, ':', unit_choices)); %NEW!!!
    KPRAW = lcaGetSmart(strcat(process_varible_name,':PRAW'),0,'double'); %NEW!!!
    KSTAT = lcaGetSmart(strcat(process_varible_name,':STAT'),0,'double');%NEW!!!
    KPPAD = lcaGetSmart(strcat(process_varible_name,':PPAD'),0,'double');%NEW!!!

    if on_scp == 1
        SWOBBLED = double(bitand(bitshift(typecast(SPRAW,'uint64'),-29),3));
        KWOBBLED = double(bitand(bitshift(typecast(KPRAW,'uint64'),-29),3));
    else
        SWOBBLED = lcaGetSmart([handles.process_variable ':WOBBLED'],0,'double')*2+1;
        KWOBBLED = lcaGetSmart(strcat(process_varible_name,':WOBBLED'),0,'double')*2+1;%NEW!!!
    end

    DACV = polyval(fliplr(SVFNP),phase);

    SBST_Data(:,n) = [DACV SPRAW SWOBBLED SSTAT];
    SBST_klys(:,:,n) = [KPRAW KWOBBLED KSTAT KPPAD];

    handles = guidata(hObject);
    set(handles.VFNP_radio_btn,'Value',val_VFNP);
    set(handles.POLY_radio_btn,'Value',val_POLY);
    set(handles.type,'Value',val_type);
    set(handles.sector,'Value',val_sect);
    set(handles.unit,'Value',val_unit);
    BOTH_progressBar(hObject,handles,n/90);

end

%PUTTING INFO IN!!!!!!!!
control_phaseSet(handles.process_variable,SBST_old,0,0,'KPHR');
if on_scp == 1
    [process_variable,a] = control_klysName(handles.process_variable);
    pvaSet(strcat(process_variable,':FEMN'), old_FEMN);
else
    lcaPut([handles.process_variable ':PTRM'],KPHR_trim);
      for counter = 1:length(unit_choices)
          lcaPut(['KLYS:' handles.sector_choice ':' unit_choices{counter} ':KPHR.DISP'],KLYS_old(counter));
      end
end
%PUTTING INFO IN!!!!!!!!

set(handles.status_box,'String',sprintf(''))
set(handles.scanProgress_txt,'Position',val_pos);

if ~gui_acquireStatusGet(hObject,handles), return, end

set(handles.path,'String',sprintf('New Data for %s', handles.process_variable),'fontsize', 15);
filename = ['SBST_' handles.sector_choice '_000' handles.unit_choice '_' datestr(handles.newtime,'yyyy-mm-dd_HHMMSS') '.txt'];
set(handles.status_box,'string',sprintf('New File Name:%s', filename))
file_1 = fopen(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename),'w');
fprintf(file_1,'DACV   PRAW   WOBBLED   STAT   PAD ID: %s\nDate Taken:%s   Number of downstream klystrons: %s\n', handles.PAD_ID_Database, datestr(handles.newtime),handles.downstream);
g = 0;
for I = 1:91
    g = 1 + g;
    fprintf(file_1,'%8.3f %8.3f %3d %5d\n', SBST_Data(:,g)');
    fprintf(file_1,'%8.3f %8.3f %3d %8.3f\n', SBST_klys(:,:,g)');
end
fclose(file_1);
[hObject,handles] = SBST_read_txt(hObject,handles,filename);
handles.use_filename = filename;

%finds files in directory
sbst_filename = char(['SBST_' handles.sector_choice '_000' handles.unit_choice '_*.txt']);
d_SBST = dir(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',sbst_filename));

%deleting old files for klys and for sbst
deleting_old_files(d_SBST);
guidata(hObject,handles)

function [hObject,handles] = SBST_read_txt(hObject,handles,filename)
set(handles.POLY_radio_btn,'value',1)
set(handles.VFNP_radio_btn,'value',0)
set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')
set(handles.VFNP_radio_btn, 'visible','on')
set(handles.POLY_radio_btn, 'visible','on')

%ensures that the right filename is being inputed into the text read
if filename == 0
    wanted_filename = ['SBST_' handles.sector_choice '_000' handles.unit_choice '_*.txt'];
    d_SBST = dir(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',wanted_filename));
    [x_SBST,y_SBST]=sort(datenum(char({d_SBST.date})));
    most_recent_file_SBST=char(d_SBST(y_SBST(end)).name);
    filename = sprintf('%s',most_recent_file_SBST);
end

%clear and properly set stuff
cla(handles.plot1,'reset');
cla(handles.plot3,'reset');
if strcmp(get(handles.plot2, 'visible'), 'on')
    cla(handles.plot2,'reset');
end
set(handles.plot1, 'position', [60 30 70 14])
set(handles.plot2, 'visible', 'off')
set(handles.plot3, 'position', [60 8 70 14])

[head] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename), '%s');
header_line = head([7 9 10 15]);
PAD_ID = cell2mat(header_line(1));
DATE = cell2mat(header_line(2));
TIME = cell2mat(header_line(3));
downstream = cell2mat(header_line(4));

handles.PAD_ID_Loaded = PAD_ID;
handles.time_loaded = ['Date Data ' DATE '  ' TIME];
handles.downstream = str2num(downstream);
guidata(hObject,handles)

set(handles.time,'String',sprintf('%s',handles.time_loaded))
%reads file and pulls out the usefull data
fid = fopen(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename));
unneeded = fgets(fid);
unneeded = fgets(fid);
m = 0;
for n = 1:90
    m = m+1;
    read_out = fgets(fid);
    SBST_data(m,:) = sscanf(read_out,'%f')';

    for p = 1:handles.downstream
        read_out = fgets(fid);
        KLYS_data(p,:) = sscanf(read_out,'%f')';
    end

    KPRAW(n,:) = KLYS_data(:,1)';
    KWOBBLED(n,:) = KLYS_data(:,2)';
    KSTAT(n,:) = KLYS_data(:,3)';
    KPPAD(n,:) = KLYS_data(:,4)';
end

AACT = SBST_data(:,1);
SPRAW = SBST_data(:,2);
SWOBBLED = SBST_data(:,3);
SSTAT = SBST_data(:,4);
[hObject,handles,True_Phase,AACT,SPRAW,SWOBBLED,SSTAT] = SBST_calculations(hObject,handles,AACT,SPRAW,SWOBBLED,SSTAT,KPRAW,KWOBBLED,KSTAT);
fclose(fid);
[handles] = check_PAD_ID(hObject,handles);

function [hObject,handles,True_Phase,AACT,SPRAW,SWOBBLED,SSTAT] = SBST_calculations(hObject,handles,AACT,SPRAW,SWOBBLED,SSTAT,KPRAW,KWOBBLED,KSTAT)
%This makes the PPAD from KPRAW and KWOBBLED and then check them for error
%and then averages the good ones...
handles.count = size(AACT,1);
guidata(hObject,handles)
True_Phase = [];
AACT_tol = 40 + (720/handles.count);
BAD_AACT = 6;
maxerr = 60;

%handles the aida list information to usable info
[type_raw,micro,unit] = model_nameSplit(handles.SBST_list);

selected_micro = strcmp(micro,handles.sector_choice);
type_wanted = 'KLYS';
selected_type = strcmp(type_raw,type_wanted);

%seprates and chooses only the unit choices for the type and for the sector
unit_choices = unit(selected_micro & selected_type);
unit_choices = sort(unit_choices);

%Makes PPADs
for I = 1:handles.count

    SWOBBLED_intrested = SWOBBLED(I);

    [SPRAW(I)] = SBST_bound(SPRAW(I), SWOBBLED_intrested);

    if I <= (handles.count/2)
        PDES = -180 + (I-1)*(360/(handles.count/2));
    else
        PDES = -180 + (handles.count-(I-1))*(360/(handles.count/2));
    end

    if (abs((AACT(I) - 5)*37 - PDES) > AACT_tol)||((I>2)&&(SPRAW(I) == SPRAW(I-1)))
        SWOBBLED(I) = SWOBBLED(I) + BAD_AACT;
    end

    %klystron calculation for PPADs stuff
    for J = 1:handles.downstream
        KWOBBLED_intrested = KWOBBLED(I,J);
        KPRAW_intrested = KPRAW(I,J);

        [KPRAW_intrested] = SBST_bound(KPRAW_intrested, KWOBBLED_intrested);

        if KWOBBLED_intrested == 3
            KPRAW_intrested = KPRAW_intrested + 180;
        end

        [a,process_varible_name] = control_klysName(['KLYS:' handles.sector_choice ':' unit_choices{J}]); %NEW!!!
        KPOLY = lcaGetSmart(strcat(process_varible_name, ':POLY')); %NEW!!!

%         KPOLY = lcaGetSmart(['KLYS:' handles.sector_choice ':' unit_choices{J} ':POLY']);

        if KWOBBLED_intrested ~= 0
            KPPAD_intrested = polyval(fliplr(KPOLY),KPRAW_intrested);
        end

        if KWOBBLED_intrested == 3
            KPPAD_intrested = KPPAD_intrested - 180;
        end
        KDATA_ppad(I,J) = KPPAD_intrested;
    end
end

%Error handling
for J = 1:handles.downstream
    n = find(bitand(KWOBBLED(:,J),(SWOBBLED < BAD_AACT)),1);
    if n <= handles.count
        diff =  KDATA_ppad(n,J) - (AACT(n) - 5)*37;
        KDATA_ppad(n,J) = KDATA_ppad(n,J) - diff;
        sigma = KDATA_ppad(n,J);
        KLYS_good(J) = 1;
    else
        KLYS_good(J) = 0;
    end
    for I = n+1:handles.count
        if bitand(KWOBBLED(I,J),KLYS_good(J))
            KDATA_ppad(I,J) = KDATA_ppad(I,J)-diff;
            KDATA_ppad(I,J) =  KDATA_ppad(I,J) + 360*(round((sigma-KDATA_ppad(I,J))/360));
            sigma = KDATA_ppad(I,J);
            if SWOBBLED(I) < BAD_AACT && ~isnan(KDATA_ppad(I,J))
                KLYS_good(J) = abs(KDATA_ppad(I,J)-(AACT(I)-5)*37) < maxerr;
            end
        end
    end
end

if sum(KLYS_good) == 0
    questdlg(['No good data produced from klystrons for subbooster:  ',handles.process_variable, '.  Please redo scan and/or delete bad file.'] , ...
        'Warning!', ...
        'Cancel','Cancel');
else
    %Averages the PPADS of the klystrons
    Bad_Step = 4;
    for I = 1:handles.count

        is_good = bitand(KLYS_good(:)',KWOBBLED(I,:)) & ~isnan(KDATA_ppad(I,:));
        True_Phase(I) = mean(KDATA_ppad(I,is_good));

        if ~any(is_good)
            True_Phase(I) = 0;
            SWOBBLED(I) = Bad_Step;
        end
    end
    True_Phase = True_Phase';
    %Remove bad data from the list for subboosters
    n = 0;
    for I = 1:handles.count
        if (SWOBBLED(I) ~= Bad_Step) && (SWOBBLED(I) < BAD_AACT)
            AACT(I-n) = AACT(I);
            SPRAW(I-n) = SPRAW(I);
            SWOBBLED(I-n)= SWOBBLED(I);
            SSTAT(I-n) = SSTAT(I);
            True_Phase(I-n) = True_Phase(I);
        else
            n = n+1;
        end
    end
    %triming all vectors
    AACT(end-n+1:end) = [];
    SPRAW(end-n+1:end) = [];
    SWOBBLED(end-n+1:end) = [];
    SSTAT(end-n+1:end) = [];
    True_Phase(end-n+1:end) = [];

    handles.count = handles.count - n;
    guidata(hObject,handles)

    if isempty(True_Phase) %|| sum(is_good) == 0
        questdlg(['No good data produced from klystrons for subbooster:  ',handles.process_variable, '.  Please redo scan and/or delete bad file.'] , ...
            'Warning!', ...
            'Cancel','Cancel');
    else
        [handles] = SBST_plotting(hObject,handles,True_Phase,AACT,SPRAW,SWOBBLED,SSTAT);
    end
end

function [handles] = SBST_plotting(hObject,handles,True_Phase,AACT,SPRAW,SWOBBLED,SSTAT)
%------plot 1------
axes(handles.plot1)
True_Phase_plot1 = True_Phase;
[True_Phase_plot1,AACT_plot,v,newVFNP,handles] = SBST_ploynomial(handles,True_Phase_plot1,AACT,hObject);
plot(handles.plot1,True_Phase_plot1,AACT_plot,'r.')
hold on
[True_Phase_plot1,AACT_plot,v,newVFNP,handles,old_vfnp_plot] = SBST_error_check(hObject,handles,True_Phase_plot1,AACT);
plot(handles.plot1,True_Phase_plot1,AACT_plot,'.',-200:200,v,'g-',-200:200, old_vfnp_plot,'r-')
hold off
legend('Excluded Data','Raw Data', 'New VFNP Fit', 'Old VFNP Fit','Location','SouthWest')
xlim([-200 200])
graph2d.constantline(0);
title('True Phase vs (True Phase - SBST DACV) in degrees','fontsize', 12)
set(gca,'FontSize',9)

%------plot 2------
axes(handles.plot3)
[True_Phase,SPRAW,SWOBBLED,SSTAT] = BOTH_stat_check(True_Phase,SPRAW,SWOBBLED,SSTAT);
[True_Phase, SPRAW] = BOTH_corrections(True_Phase, SPRAW);
[True_Phase, SPRAW] = BOTH_wobble(True_Phase, SPRAW, SWOBBLED);
[KPHR_plot,PRAW,v,newp,handles] = BOTH_ploynomial(hObject,handles,True_Phase, SPRAW);
plot(handles.plot3,PRAW,KPHR_plot-PRAW,'r.')
hold on
[PRAW,KPHR_plot,v,newp,handles,old_poly_plot] = BOTH_error_check(hObject,handles,SPRAW,True_Phase);
plot(handles.plot3,PRAW,KPHR_plot-PRAW,'.',0:200,v-(0:200),'g-',0:200, old_poly_plot-(0:200),'r-')
hold off
legend('Excluded Data','Raw Data', 'New Poly Fit', 'Old Poly Fit','Location','NorthWest')
xlim([0 200])
graph2d.constantline(0);
title('SBST PRAW vs (True Phase - SBST PRAW) in degrees','fontsize', 12)
set(gca,'FontSize',9);
handles.newtime = 0;
guidata(hObject,handles)

function [True_Phase,AACT_plot,v,newVFNP,handles] = SBST_ploynomial(handles,True_Phase,AACT,hObject)
%used for VFNP
[True_Phase,AACT] = BOTH_outliers(True_Phase, AACT);

xfit1 = -180:180;
VFNP_cal = fliplr(polyfit(True_Phase,AACT,5));
v_cal = polyval(fliplr(VFNP_cal),xfit1);

diff =  ((xfit1(1) - (v_cal(1) - 5)*37)+ (xfit1(end) - (v_cal(end) - 5)*37))/2;
True_Phase = True_Phase - diff;

xfit = -200:200;

newVFNP = fliplr(polyfit(True_Phase,AACT,5));
v = polyval(fliplr(newVFNP),xfit);

AACT_plot = (AACT-5)*37 -True_Phase;
v =  (v-5)*37 - xfit;

function [True_Phase,AACT_plot,v,newVFNP,handles,old_vfnp_plot] = SBST_error_check(hObject,handles,True_Phase,AACT)
r = polyfit(True_Phase,AACT,5);
t = polyval(r,True_Phase);
diff = (AACT-t);
%Finds outliers that are n*sigma or more and removes the outliers
s = std(diff);
outliers = abs(diff) > 2*s;
%removes outliers from PRAW and KPHR for cleaner polyfit's
True_Phase(any(outliers,2),:) = [];
AACT(any(outliers,2),:) = [];

newVFNP = fliplr(polyfit(True_Phase,AACT,5));
xfit=-200:200;
v = polyval(fliplr(newVFNP),xfit);
v=(v-5)*37-xfit;
handles.newvfnp = newVFNP;
AACT_plot = (AACT-5)*37-True_Phase;

handles.oldvfnp = lcaGetSmart([handles.process_variable ':VFNP']);
xfit = -200:200;
old_vfnp_plot = polyval(fliplr(handles.oldvfnp),xfit);
old_vfnp_plot =  (old_vfnp_plot-5)*37 - xfit;
guidata(hObject,handles)
set(handles.new,'String',(sprintf('New File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newvfnp)), 'fontsize', 12);
set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldvfnp)), 'fontsize', 12);

function [FIXED_PRAW,handles] = SBST_bound(PRAW,WOBBLED,handles)
FIXED_PRAW = PRAW;
if WOBBLED == 3
    min = -270;
    max = 90;
elseif WOBBLED == 1
    min = -90;
    max = 270;
else
    FIXED_PRAW = 0;
end

if WOBBLED == 1 || WOBBLED == 3
    if PRAW > max
        FIXED_PRAW = PRAW - 360;
    elseif PRAW < min
        FIXED_PRAW = PRAW + 360;
    end
else
    FIXED_PRAW = 0;
end

%--------------------------------------------------------------------------
%KLYS Files

function [hObject,handles,filename] = klys_scan(hObject,handles)
%Scans through -180 to 180 degrees for the KPHR, also gets PRAW, STAT and
%produces the WOBBLED by working with PRAW
global da;
set(handles.new,'String','From File:','fontsize',12);
val_VFNP=get(handles.VFNP_radio_btn,'Value');
val_POLY=get(handles.POLY_radio_btn,'Value');
val_type=get(handles.type,'Value');
val_sect=get(handles.sector,'Value');
val_unit=get(handles.unit,'Value');
val_pos=get(handles.scanProgress_txt,'Position');
filename = [];

handles.newtime = now;
PAD_ID_check = lcaGetSmart([handles.process_variable ':SID']);
if PAD_ID_check(2) < 0
    PAD_ID_m = (typecast(int16(PAD_ID_check),'uint16'));
else
    PAD_ID_m = PAD_ID_check;
end
PAD_ID = dec2hex(PAD_ID_m(2));
handles.PAD_ID_Database = PAD_ID;
guidata(hObject,handles);

%get initial values
KPHR_old = lcaGetSmart([handles.process_variable ':KPHR']);

%PUTTING INFO IN!!!!!!!!
%turns of PTRM to prevent it from reseting our scan
[type_raw,micro,unit] = model_nameSplit(handles.process_variable);
on_scp = strcmp(micro,'KLYS') || strcmp(micro,'SBST');
%if it is 1 then it is on scp
if on_scp == 1
    [process_variable,a] = control_klysName(handles.process_variable);
    response = pvaGetM(strcat(process_variable,':FEMN'));
    old_FEMN = response(1);
    pvaSet(strcat(process_variable,':FEMN'), 1);
else
    KPHR_trim = lcaGetSmart([handles.process_variable ':PTRM']);
    lcaPut([handles.process_variable ':PTRM'],0);
end
%PUTTING INFO IN!!!!!!!!

pause(handles.sleep_time-3);

n = 0;
%starts at KPHR_old and cycles through 360 degrees
for phase = KPHR_old + [0:8:360 352:-8:0]
    n = 1 + n;
    KPHR(n) = phase;

    set(handles.status_box,'String',sprintf('Setting KPHR to %7.2f, this takes several minutes....',KPHR(n)), 'fontsize', 10)

    %PUTTING INFO IN!!!!!!!!
    control_phaseSet(handles.process_variable,phase,0,0,'KPHR');
    %PUTTING INFO IN!!!!!!!!

    %extra time for first point
    if n == 1
        pause(handles.sleep_time);
    end

    %for abort button, checks to see if pushed
    pause(handles.sleep_time);
    if ~gui_acquireStatusGet(hObject,handles), break, end

    PRAW(n) = lcaGetSmart([handles.process_variable ':PRAW']);
    STAT(n) = lcaGetSmart([handles.process_variable ':STAT']);
    if on_scp == 1
        WOBBLED(n) = double(bitand(bitshift(typecast(PRAW(n),'uint64'),-29),3));
    else
        WOBBLED(n) = lcaGetSmart([handles.process_variable ':WOBBLED'],0,'double')*2+1;
    end

    handles = guidata(hObject);

    %for progress bar
    BOTH_progressBar(hObject,handles,n/90);

    %keeps the pulldown menu from being changed
    set(handles.VFNP_radio_btn,'Value',val_VFNP);
    set(handles.POLY_radio_btn,'Value',val_POLY);
    set(handles.type,'Value',val_type);
    set(handles.sector,'Value',val_sect);
    set(handles.unit,'Value',val_unit);
end
%reset handles...
set(handles.status_box,'String',sprintf(''))
set(handles.scanProgress_txt,'Position',val_pos);

%PUTTING INFO IN!!!!!!!!
control_phaseSet(handles.process_variable,KPHR_old,0,0,'KPHR');
if on_scp == 1
    [process_variable,a] = control_klysName(handles.process_variable);
    pvaSet(strcat(process_variable,':FEMN'), old_FEMN);
else
    lcaPut([handles.process_variable ':PTRM'],KPHR_trim);
end
%PUTTING INFO IN!!!!!!!!

%this is for abort, prevents the program from going further if aborted
if ~gui_acquireStatusGet(hObject,handles), return, end

KPHR = KPHR';
PRAW = PRAW';
WOBBLED = WOBBLED';
STAT = STAT';
KLYS_KPWS = [KPHR PRAW WOBBLED STAT];

if handles.is_SPARE == 1
    set(handles.path,'String',sprintf('New SPARE made on %s', handles.process_variable),'fontsize', 15);
    filename = ['SPARE_', handles.PAD_ID_Database,'.txt'];
    %Delete's any other spares of PAD_ID type, leaving only one left
    d_KLYS = dir(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename));
else
    set(handles.path,'String',sprintf('New Data for %s', handles.process_variable),'fontsize', 15);
    filename = ['KLYS_' handles.sector_choice '_00' handles.unit_choice '_' datestr(handles.newtime,'yyyy-mm-dd_HHMMSS') '.txt'];
    klys_filename = char(['KLYS_' handles.sector_choice '_00' handles.unit_choice '_*.txt']);
    d_KLYS = dir(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',klys_filename));
end
file_1 = fopen(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename),'w');
fprintf(file_1,'KPHR   PRAW   WOBBLED   STAT   PAD ID: %s    Date Taken:%s\n', handles.PAD_ID_Database, datestr(handles.newtime));
fprintf(file_1,'%8.3f %8.3f %3d %5d\n', KLYS_KPWS');
fclose(file_1);
set(handles.status_box,'string',sprintf('New File Name:%s', filename))
[handles] = KLYS_read_txt(hObject,handles,filename);
handles.use_filename = filename;
%deleting old files for klys and for sbst
deleting_old_files(d_KLYS);
guidata(hObject,handles)

function [handles] = KLYS_read_txt(hObject,handles,filename)
[KPHR,PRAW,WOBBLED,STAT] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename), '%f %f %f %f', 'headerlines', 1);
set(handles.POLY_radio_btn,'value',1)
set(handles.VFNP_radio_btn,'value',0)
set(handles.fit_compair,'title','Polynomial POLY Fit Comparison')
set(handles.VFNP_radio_btn, 'visible','off')
set(handles.POLY_radio_btn, 'visible','off')
set(handles.plot1, 'position', [56.933 35.288 75 9])
set(handles.plot2, 'visible', 'on')
set(handles.plot3, 'position', [56.767 6.66 75 9])
cla(handles.plot1,'reset');
cla(handles.plot3,'reset');
cla(handles.plot2,'reset');

%1 = PAD ID, 2 = DATE and 3 = TIME
[head] = textread(fullfile('/u1/lcls/physics/amrf/klydata/PADcalibration',filename), '%s');
header_line = head([7 9 10]);
PAD_ID = cell2mat(header_line(1));
DATE = cell2mat(header_line(2));
TIME = cell2mat(header_line(3));

handles.PAD_ID_Loaded = PAD_ID;
handles.time_loaded = ['Date Data ' DATE '  ' TIME];
guidata(hObject,handles)
set(handles.time,'String',sprintf('%s',handles.time_loaded))
[handles] = KLYS_plotting(hObject,handles,KPHR,PRAW,WOBBLED,STAT);
[handles] = check_PAD_ID(hObject,handles);

function [handles] = KLYS_plotting(hObject,handles,KPHR,PRAW,WOBBLED,STAT)
PRAW = PRAW(2:length(PRAW));
KPHR = KPHR(2:length(KPHR));
WOBBLED = WOBBLED(2:length(WOBBLED));
STAT = STAT(2:length(STAT));
[KPHR, PRAW, WOBBLED, STAT] = BOTH_stat_check(KPHR, PRAW, WOBBLED, STAT);
if isempty(KPHR)
    questdlg(['No good data produced from klystron:  ',handles.process_variable, '.  Please redo scan and/or delete bad file.'] , ...
        'Warning!', ...
        'Cancel','Cancel');
else
    %------plot 1------
    axes(handles.plot1)
    %This show the orignal and unwrapped data
    %keeps data in the right place
    if max(KPHR) > 361
        KPHR = KPHR - 360;
    end
    if min(KPHR) < -361
        KPHR = KPHR + 360;
    end
    plot(handles.plot1,PRAW,KPHR,'r.')
    [KPHR, PRAW] = BOTH_corrections(KPHR,PRAW);
    hold on
    plot(handles.plot1,PRAW,KPHR,'gs')
    hold off
    axis([-200 200 -360 360])
    graph2d.constantline(0);
    title('Raw and Unwrapped Data','fontsize', 12)
    legend('Raw Data', 'Unwrapped Data','Location','Best')
    xlabel('PRAW','fontsize', 12)
    ylabel('KPHR','fontsize', 12)
    set(gca,'FontSize',9,'YTick', [-360 0 360])

    %------plot 2------
    axes(handles.plot2)
    %This shows the unwobbled data
    [KPHR, PRAW] = BOTH_wobble(KPHR,PRAW,WOBBLED);
    plot(handles.plot2,PRAW,KPHR, '+')
    axis([0 200 0 200])
    title('Unwobbled Data','fontsize', 12)
    xlabel('PRAW','fontsize',12)
    ylabel('KPHR','fontsize',12)
    set(gca,'FontSize',9)

    %------plot 3------
    axes(handles.plot3)
    %Plots the polynomial and computes the diffrence of KPHR and the line PRAW
    %This finds the polynomial needed for the polyfit then plots
    [KPHR,PRAW,v,newp,handles] = BOTH_ploynomial(hObject,handles,KPHR,PRAW);
    plot(handles.plot3,PRAW,KPHR-PRAW,'r.')
    hold on
    [PRAW,KPHR,v,newp,handles,old_poly_plot] = BOTH_error_check(hObject,handles,PRAW,KPHR);
    plot(handles.plot3,PRAW,KPHR-PRAW,'.',0:200,v-(0:200),'g-',0:200, old_poly_plot-(0:200),'r-')
    hold off
    legend('Excluded Data','Raw Data', 'New Poly Fit', 'Old Poly Fit','Location','NorthWest')
    xlim([0 200])
    graph2d.constantline(0);
    title('KPHR-PRAW for Unwobbled Data and Polynomial Fit','fontsize', 12)
    xlabel('PRAW','fontsize',12)
    ylabel('KPHR-PRAW','fontsize',12)
    set(gca,'FontSize',9)
end
handles.newtime = 0;
guidata(hObject,handles)

%--------------------------------------------------------------------------
%files for SBST and KLYS

function [KPHR,PRAW,WOBBLED,STAT,handles,is_good] = BOTH_stat_check(KPHR,PRAW,WOBBLED,STAT,handles)
%checking to see if the stats are good or bad, changing KPHR, WOBBLED and PRAW
STAT_GOOD = hex2dec('0001');
STAT_OK = hex2dec('0002');
STAT_SWRDBITS = hex2dec('0020');
STAT_PHASE_MEAN = hex2dec('0200');
STAT_PHAS_DRIFT = hex2dec('0400');
STAT_SICK = hex2dec('0008');

PCB_KLYS_OK = bitor(STAT_GOOD,STAT_OK);
PCB_KLYS_SICK_OK = bitor(STAT_SICK,STAT_PHASE_MEAN);
PCB_DONT_CARE_MASK = bitxor(2^16-1,(bitor(STAT_PHAS_DRIFT,STAT_SWRDBITS)));

AWOBBLE = WOBBLED;
AKPHR = KPHR;
APRAW = PRAW;

STAT = bitand(STAT,PCB_DONT_CARE_MASK);

is_good = bitand(AWOBBLE,((bitand(STAT, PCB_KLYS_OK) ~= 0)|(STAT == PCB_KLYS_SICK_OK))) & ~isnan(APRAW);
KPHR = AKPHR(is_good);
PRAW = APRAW(is_good);
WOBBLED = AWOBBLE(is_good);

function [KPHR,PRAW,handles] = BOTH_corrections(KPHR,PRAW,handles)
%This removes the discontiunity out in the phase KPHR
for n = 2:numel(KPHR);
    KPHR(n) = KPHR(n) + 360*(round((KPHR(n-1)-KPHR(n))/360) - round((PRAW(n-1)-PRAW(n))/360));
end
%Moves up the data if needed to place about the 0 axis
if min(KPHR)<-360
    KPHR = KPHR + 360;
end
if max(KPHR)>360
    KPHR = KPHR - 360;
end

function [KPHR,PRAW,WOBBLED,handles] = BOTH_wobble(KPHR,PRAW,WOBBLED,handles)
%Moves the KPHR data closer to line KPHR = PRAW
diff =  KPHR(1) - PRAW(1);
KPHR = KPHR - diff;
%checks to see when data needs to be unwobbled, plots the unwobbled data
check_WOBBLE = WOBBLED == 3;
KPHR(check_WOBBLE) = KPHR(check_WOBBLE) + 180;
PRAW(check_WOBBLE) = PRAW(check_WOBBLE) + 180;

function [KPHR,PRAW,handles] = BOTH_outliers(KPHR,PRAW,handles)
%Finds outliers that are 3*sigma or more and removes the outliers
m = mean(PRAW);
s = std(PRAW);
outliers = abs(PRAW - m) > 3*s;
%removes outliers from PRAW and KPHR for cleaner polyfit's
PRAW(any(outliers,2),:) = [];
KPHR(any(outliers,2),:) = [];

function [KPHR_plot,PRAW,v,newp,handles] = BOTH_ploynomial(hObject,handles,KPHR,PRAW)
%Fits the polynomial
[KPHR, PRAW] = BOTH_outliers(KPHR, PRAW);

newp = fliplr(polyfit(PRAW,KPHR,5));
v = polyval(fliplr(newp),0:200);

%Another offset to help correct for fitting it in plot1
diff =  ((v(1) + v(181) - 180)/2);
KPHR_plot = KPHR - diff;
v = v - diff;
newp(end) = newp(end) - diff;

function [PRAW,KPHR_plot,v,newp,handles,old_poly_plot] = BOTH_error_check(hObject,handles,PRAW,KPHR)
%r = polyfit(PRAW,KPHR,5);
%t = polyval(r,PRAW);
m = mean(PRAW);
s = std(PRAW);
%diff = (KPHR-t);
diff = PRAW-m;
%Finds outliers that are n*sigma or more and removes the outliers
outliers = abs(diff) > 3*s;
%removes outliers from PRAW and KPHR for cleaner polyfit's
PRAW(any(outliers,2),:) = [];
KPHR(any(outliers,2),:) = [];

newp = fliplr(polyfit(PRAW,KPHR,5));
v = polyval(fliplr(newp),0:200);
format short g
diff = ((v(1) + v(181)-180)/2);
KPHR_plot = KPHR - diff;
v = v-diff;
% get the structure in the subfunction
handles.newpoly = newp;
handles.oldpoly = lcaGetSmart([handles.process_variable ':POLY']);
guidata(hObject,handles)

%shows old values of POLY to new values of POLY
old_poly_plot = polyval(fliplr(handles.oldpoly),0:200);
set(handles.new,'String',(sprintf('New File:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.newpoly)), 'fontsize', 12);
set(handles.old,'String',(sprintf('In Database:\n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e \n\n %1.2e', handles.oldpoly)), 'fontsize', 12);

function BOTH_progressBar(hObject,handles,ratio)
pos=get(handles.scanProgress_bck,'Position');
pos(3)=max(0.1,pos(3)*ratio);
set(handles.scanProgress_txt,'Position',pos);


