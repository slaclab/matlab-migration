function varargout = speedracer(varargin)
% Last Modified by GUIDE v2.5 21-Aug-2012 14:21:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @speedracer_OpeningFcn, ...
                   'gui_OutputFcn',  @speedracer_OutputFcn, ...
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

function speedracer_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for speedracer.
handles.output = hObject;
handles = intialize(hObject,handles);

% Display background images.
handles.bkgd = axes('Tag','bkgd','Units','pixels','Position',[0 5 650 700]);
image(importdata('/usr/local/lcls/tools/matlab/toolbox/images/Speedracer2.bmp'))
uistack(handles.bkgd,'bottom')
handles.flag = axes('Tag','flag','Units','pixels','Position',[390 493 300 207]);
image(importdata('/usr/local/lcls/tools/matlab/toolbox/images/flag.bmp'))
axis off

% Update handles structure.
guidata(hObject, handles);


function varargout = speedracer_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function handles = intialize(hObject, handles)
% List of PMTs for that 'group' parameter in the parameter list below, and
% each PMT's value for the low charge and high charge states.

% Items of type 'group' have an extra list of PVs and values. 
handles.PMTs = {...
%     'HVM:LI21:401:VoltageSet','725','600';
    'HVM:LI28:150:VoltageSet','800','650';
    'HVM:LTU1:246:VoltageSet','1100','900';
    'HVM:LTU1:755:VoltageSet','1000','800';
    'HVM:LTU1:820:VoltageSet','1050','800'};


% List of parameters in charge change, including a name, PV, "type"
% (double, binary, range, group or iris), and config values for 20 pC,
% 40 pC, 150 pC and 250 pC.
handles.param = {...
    'Bunch Charge Fbck Setpt', 'FBCK:FB02:GN01:S1DES', 'dbl', ...
    '0.02', '0.04', '0.15', '0.25';
    %     'Laser Iris', 'IRIS:LR20:118:CONFG_SEL', 'iris', ...
    %           '8', '8', '6', '5';
    %     'Laser Power %','IOC:IN20:LS11:PCTRL', 'range', ...
    %     '6', '8', '10', '15';
    'BPM Global Attenuation',  'IOC:IN20:BP01:QANN', 'dbl', ...
    '0.02', '0.04', '0.15', '0.25';
    %     'Gun Phase', 'GUN:IN20:1:GN1_PDES', 'dbl', ...
    %           '-8', '-8', '0', '0';
    %     'Schottky (Laser) Phase', 'LASR:IN20:1:LSR_PDES2856', 'dbl', ...
    %           '-23', '-23', '-30', '-30';
    %     'L0B Phase', 'ACCL:IN20:400:L0B_PDES', 'dbl', ...
    %           '-0.5', '-0.5', '-2.5', '-2.5';
    'BC1 Peak I 6x6 control', 'SIOC:SYS0:ML00:AO293', 'bin', ...
    '0', '0', '1', '1';
    %     'L1S Phase', 'ACCL:LI21:1:L1S_PDES', 'dbl', ...
    %           '-23', '-23', '-30', '-30';
    'Guardian min TMIT', 'SIOC:SYS0:ML00:AO453', 'dbl', ...
    '0.01', '0.01', '0.02', '0.02';
    'Fbcks low TMIT limit', 'SIOC:SYS0:FB00:TMITLOW', 'dbl', ...
    '5e+07', '5e+07', '2e+08', '2e+08';
    %     'VCC P2P threshold', 'CAMR:IN20:186:TSHD_P2P', 'dbl', ...
    %     '2', '2', '3', '3';
    %     'VCC noise ratio', 'CAMR:IN20:186:NOISE_RATIO', 'dbl', ...
    %     '0.18', '0.18', '0.15', '0.15';
    %     'OTR2 Filter 2', 'OTRS:IN20:571:FLT2_PNEU', 'bin', ...
    %     'Out', 'Out', 'In', 'In';
    %     'BC2 30 um Filter', 'BLEN:LI24:886:P1FLT1_PNEU', 'bin', ...
    %           'Out', 'Out', 'In', 'In';
    'Wirescan PMT voltages', handles.PMTs, 'group', ...
    'High HVs','High HVs','Low HVs','Low HVs'};



% List of stoppers.
handles.stopper = {...
    'Gun RF Rate',  'IOC:BSY0:MP01:PCELLCTL';
    'Mech Shutter', 'IOC:BSY0:MP01:MSHUTCTL';
    'LH Shutter',   'IOC:BSY0:MP01:LSHUTCTL';
%     'TD11',         'DUMP:LI21:305:TD11_PNEU';
    'BYKICK',       'IOC:BSY0:MP01:BYKIKCTL';
    'TDUND',        'DUMP:LTU1:970:TDUND_PNEU'};


% Define a cell showing which pushbutton is selected (blank at opening).
handles.selected = {};


% Set "evaluate" variable handles.win to an array of 0's.
handles.win = zeros(1,length(handles.param(:,1)));


handles = populate_gui(hObject,handles);
guidata(hObject,handles);
update_vals(hObject,handles);


function handles = populate_gui(hObject,handles)
% Create stopper buttons. The button's Tag is the stopper's PV.
for s = 1:length(handles.stopper(:,1))
    handles.sbutton(s) = uicontrol('Style','pushbutton','Position',[536 454-s*35 94 24], ...
        'BackgroundColor',[.1 .1 .1],'FontWeight','bold','String',handles.stopper{s,1}, ...
        'Callback',@stopper_insert, 'Tag',handles.stopper{s,2},'SelectionHighlight','off');
    state = lcaGet(handles.stopper{s,2},0,'double');
    if state == 0
        set(handles.sbutton(s),'ForegroundColor',[1 0 0]);
    elseif state == 1
        set(handles.sbutton(s),'ForegroundColor',[0 1 0]);
    end
end

% Create display fields for "Parameter", "Current", "Config" and "Same?".
for z = 1:length(handles.param(:,1))
    handles.name(z) = uicontrol('Style','text','Position',[15 460-z*30 160 15], ...
        'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1], ...
        'String',handles.param{z,1},'FontWeight','normal');
    handles.current(z) = uicontrol('Style','text','Position',[190 460-z*30 70 15], ...
        'BackgroundColor',[.75 .75 .75],'ForegroundColor',[0 0 0],'FontWeight','bold');
    if strcmp(handles.param(z,3),'dbl') || strcmp(handles.param(z,3),'range')
        egustr = strcat(handles.param{z,2}, '.EGU');
        eguval = lcaGet(egustr,0,'char');
        if strcmp(eguval,'percent')
            eguval = '%';
        end
        handles.egu1(z) = uicontrol('Style','text','Position',[261 460-z*30 28 15], ...
            'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'String',eguval);
        handles.egu2(z) = uicontrol('Style','text','Position',[376 460-z*30 28 15], ...
            'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'String',eguval);
    else
        handles.egu1(z) = uicontrol('Style','text','Position',[261 460-z*30 28 15], ...
            'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'String',' ');
        handles.egu2(z) = uicontrol('Style','text','Position',[376 460-z*30 28 15], ...
            'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'String',' ');
    end
    handles.config(z) = uicontrol('Style','text','Position',[305 460-z*30 70 15], ...
        'BackgroundColor',[.75 .75 .75],'ForegroundColor',[0 0 0],'FontWeight','bold');
    handles.same(z) = uipanel('Units','pixels','BackgroundColor',[0 0 0], ...
        'Position',[430 460-z*30 20 16]);
end

handles.success = uicontrol('Style','togglebutton','Units','pixels','Position',[510 10 120 120], ...
    'Visible','off','BackgroundColor',[0 0 0],'String','','CData',imread('/usr/local/lcls/tools/matlab/toolbox/images/robin1.bmp'));

guidata(hObject,handles);


function stopper_insert(hObject, handles)
% Change state of stopper and color of button text when button is pressed.

PV = get(hObject,'Tag');
state = lcaGet(PV,1,'String');
if state == 0
    lcaPut(PV,1);
    set(hObject,'ForegroundColor','green');
elseif state == 1
    lcaPut(PV,0);
    set(hObject,'ForegroundColor','red');
end


function handles = update_vals(hObject,handles)
% Get current value of every parameter, and write it to "current".

for x = 1:length(handles.param(:,1))
    type = cellstr(handles.param(x,3));

    if strcmp(type,'dbl') || strcmp(type,'range')
        set(handles.current(x),'String',lcaGet(handles.param(x,2)));

    elseif strcmp(type,'iris')
        set(handles.current(x),'String',lcaGetSmart(handles.param(x,2)));

    elseif strcmp(type,'group')
        handles = compare_group(hObject, handles, x);

    elseif strcmp(type,'bin')
        controlPV = handles.param(x,2);
        if strcmp(controlPV,'BLEN:LI24:886:P1FLT1_PNEU') || strcmp(controlPV,'OTRS:IN20:571:FLT2_PNEU')
            readbackPV = strrep(controlPV,'PNEU','IN');
            if lcaGet(readbackPV,0,'int') == 0
                set(handles.current(x),'String','Out');
            else
                set(handles.current(x),'String','In');
            end
        else
            set(handles.current(x),'String',lcaGetSmart(handles.param(x,2)));
        end
    end
end

for s = 1:length(handles.stopper(:,1))
    state = lcaGet(handles.stopper{s,2},0,'int');
    if state == 0
        set(handles.sbutton(s),'ForegroundColor','red');
    elseif state == 1
        set(handles.sbutton(s),'ForegroundColor','green');
    end
end

guidata(hObject,handles);


function handles = compare(hObject,handles)
% Turn the current and config values into numbers. For parameters of type
% "dbl", "bin" or "iris", make the "same?" box green if current = config, or red otherwise.
% For type "range", green if current is within 20% of the config value.
% For type "group", call function compare_group.

for x = 1:length(handles.param(:,1))
    type = cellstr(handles.param(x,3));

    if strcmp(type,'bin')
        bin_curr = cellstr(get(handles.current(x),'String'));
        bin_conf = get(handles.config(x),'String');
        if strcmp(bin_curr,bin_conf)
            set(handles.same(x),'BackgroundColor',[0 1 0]);
        else
            set(handles.same(x),'BackgroundColor',[1 0 0]);
        end

    else
        curr = str2num(char(get(handles.current(x),'String')));
        conf = str2num(char(get(handles.config(x),'String')));

        if strcmp(type,'dbl') || strcmp(type,'iris')
            if curr == conf
                set(handles.same(x),'BackgroundColor',[0 1 0]);
            else
                set(handles.same(x),'BackgroundColor',[1 0 0]);
            end

        elseif strcmp(type,'range')
            if conf ~= 0
                if curr/conf >= 0.8 && curr/conf <= 1.2
                    set(handles.same(x),'BackgroundColor',[0 1 0]);
                else
                    set(handles.same(x),'BackgroundColor',[1 0 0]);
                end
            else
                set(handles.same(x),'BackgroundColor',[1 0 0]);
            end

        elseif strcmp(type,'group')
            handles = compare_group(hObject, handles, x);
            group_curr = get(handles.current(x),'String');
            group_conf = char(get(handles.config(x),'String'));

            if strcmp(group_curr,group_conf)
                set(handles.same(x),'BackgroundColor',[0 1 0]);
            else
                set(handles.same(x),'BackgroundColor',[1 0 0]);
            end
        end
    end
end

guidata(hObject,handles);


function handles = compare_group(hObject, handles, x)
% Load group's PV list, and compare current values for each PV to config
% values for each defined group state. If all PVs equal their config
% values, make "same?" box green; else red.

group = handles.param(x,2);
group_elements = cellstr(group{:,1});
PVlist = char(group_elements(:,1));

if strcmp(handles.PMTs{1,1},char(group{1}(1,1)))
    for z = 1:length(PVlist(:,1))
        state(z,1) = lcaGet(PVlist(z,:),0,'String');
    end

    highHV = str2double(group_elements(:,2));
    lowHV = str2double(group_elements(:,3));

    if state == highHV
        set(handles.current(x),'String','High HVs');
    elseif state == lowHV
        set(handles.current(x),'String','Low HVs');
    else
        set(handles.current(x),'String','Unknown');
    end
end


function handles = refresh(hObject,handles)
% Refresh GUI displayed numbers and colors.

handles = update_vals(hObject,handles);
handles = compare(hObject,handles);
guidata(hObject,handles);


function handles = putvals(hObject,handles)
% Function that actually changes charge to the config values. For
% parameters of type double, binary or range, simply put the config value
% to the control PV. For iris, disable pockels cell, change iris, pause 5
% seconds and re-enable pockels cell. For type group, put config values
% for all control PVs from that group's PV list.

for s = 1:length(handles.stopper(:,1))
    lcaPut(handles.stopper{s,2},'0');
end

for p = 1:length(handles.param(:,1))
    type = cellstr(handles.param(p,3));

    if strcmp(type,'dbl') || strcmp(type,'range')
        PV = char(handles.param(p,2));
        configval = get(handles.config(p),'String');
        lcaPut(PV,configval);

    elseif strcmp(type,'bin')
        
        configval = get(handles.config(p),'String');
        controlPV = char(handles.param(p,2));

        if strcmp(controlPV,'BLEN:LI24:886:P1FLT1_PNEU') || strcmp(controlPV,'OTRS:IN20:571:FLT2_PNEU')
            if strcmp(configval,'Out')
                lcaPut(controlPV,'0')
            elseif strcmp(configval,'In')
                lcaPut(controlPV,'1')
            end
        else         
            lcaPut(controlPV,configval)
        end


    elseif strcmp(type,'iris')
        PV = char(handles.param(p,2));
        configval = get(handles.config(p),'String');
        pockels = lcaGet('TRIG:LR20:LS01:TCTL',0,'int');

        if pockels == 1
            lcaPut(pockels,'0')

            lcaPut(PV,configval);
            pause(5);
            lcaPut(pockels,'1')

        elseif pockels == 0
            lcaPut(PV,configval);
        end

    elseif strcmp(type,'group')
        group = handles.param(p,2);
        group_elements = cellstr(group{:,1});
        PVlist = char(group_elements(:,1));

        if strcmp(handles.PMTs{1,1},char(group{1}(1,1)))
            conf = get(handles.config(p),'String');
            for g = 1:length(handles.PMTs(:,1))
                highHV(g,:) = str2double(group_elements(g,2));
                lowHV(g,:) = str2double(group_elements(g,3));
                PV = PVlist(g,:);

                if strcmp(conf,'High HVs')
                    lcaPut(PV,highHV(g));
                elseif strcmp(conf,'Low HVs')
                    putval = lowHV(g,:);
                    lcaPut(PV,lowHV(g));
                end
            end
        end
    end
end

guidata(hObject,handles);


function handles = evaluate(hObject,handles)
% Look at the color of the "same?" box for each element. If it is green,
% write a 1 to that element of handles.win; else, write a 0.

for n = 1:length(handles.same)
    color = get(handles.same(n),'BackgroundColor');
    if color == [0 1 0]
        handles.win(n) = 1;
    else
        handles.win(n) = 0;
    end
end

guidata(hObject,handles);


function robin(hObject,handles)
% Runs after putvals during Execute function. If all "same?" boxes are
% green after an Execute, display a random Robin. Else give an error
% message stating that the Execute did not succeed.

handles = evaluate(hObject,handles);

if isequal(handles.win,ones(1,length(handles.same)))
    whichrobin = round(rand(1)*4)+1;
    str = sprintf('set(handles.success,''CData'',imread(''/usr/local/lcls/tools/matlab/toolbox/images/robin%d.bmp''))',whichrobin);
    eval(str)
    set(handles.success,'Visible','on')
else
    errordlg('Something did not succeed. :(')
end


%%%%%%%%%%%%%%%%%%%%%%  BUTTON CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function refreshGUI_Callback(hObject, eventdata, handles)
% Run the refresh function when Refresh button is pressed.
handles = refresh(hObject,handles);


function pushbutton1_Callback(hObject, eventdata, handles)
% Load 20 pC vals

handles.selected = get(hObject,'String');

for x = 1:length(handles.param(:,1))
    set(handles.config(x),'String',handles.param(x,4))
end

set(handles.pushbutton1,'BackgroundColor',[0 0 1]);
set(handles.pushbutton2,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton3,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton4,'BackgroundColor',[.2 .2 .2]);
set(handles.success,'Visible','off');

handles = refresh(hObject,handles);

function pushbutton2_Callback(hObject, eventdata, handles)
% Load 40 pC vals

handles.selected = get(hObject,'String');

for x = 1:length(handles.param(:,1))
    set(handles.config(x),'String',handles.param(x,5))
end

set(handles.pushbutton2,'BackgroundColor',[0 0 1]);
set(handles.pushbutton1,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton3,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton4,'BackgroundColor',[.2 .2 .2]);
set(handles.success,'Visible','off');

handles = refresh(hObject,handles);

function pushbutton3_Callback(hObject, eventdata, handles)
% Load 150 pC vals

handles.selected = get(hObject,'String');

for x = 1:length(handles.param(:,1))
    set(handles.config(x),'String',handles.param(x,6))
end

set(handles.pushbutton3,'BackgroundColor',[0 0 1]);
set(handles.pushbutton1,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton2,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton4,'BackgroundColor',[.2 .2 .2]);
set(handles.success,'Visible','off');

handles = refresh(hObject,handles);

function pushbutton4_Callback(hObject, eventdata, handles)
% Load 250 pC vals

handles.selected = get(hObject,'String');

for x = 1:length(handles.param(:,1))
    set(handles.config(x),'String',handles.param(x,7))
end

set(handles.pushbutton4,'BackgroundColor',[0 0 1]);
set(handles.pushbutton1,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton2,'BackgroundColor',[.2 .2 .2]);
set(handles.pushbutton3,'BackgroundColor',[.2 .2 .2]);
set(handles.success,'Visible','off');

handles = refresh(hObject,handles);


function handles = execute_Callback(hObject, eventdata, handles)
% Confirm that user wants to put in stoppers and change charge. Then
% evaluate if any changes are needed. If so, put in all stoppers and execute
% putvals function to change charge.

msg = sprintf('Put in stoppers and change charge to %s?',char(handles.selected));
confirm = questdlg(msg,'Execute Confirmation','Yes');

switch confirm
    case 'Yes'
        if isempty(handles.selected)
            errordlg('No config is selected')
        else
            handles = evaluate(hObject,handles);
            if handles.win == ones(1,length(handles.same))
                errordlg('It appears there is nothing to change for this config.')
                set(handles.success,'Visible','off')
            else
                handles = putvals(hObject,handles);
                pause(1);
                handles = refresh(hObject,handles);
                pause(1);
                robin(hObject,handles);
            end
        end

    case 'No'
    case 'Cancel'
end

guidata(hObject,handles);



