function varargout = pointingGUInew(varargin)
% POINTINGGUINEW MATLAB code for pointingGUInew.fig
%      POINTINGGUINEW, by itself, creates a new POINTINGGUINEW or raises the existing
%      singleton*.
%
%      H = POINTINGGUINEW returns the handle to a new POINTINGGUINEW or the handle to
%      the existing singleton*.
%
%      POINTINGGUINEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POINTINGGUINEW.M with the given input arguments.
%
%      POINTINGGUINEW('Property','Value',...) creates a new POINTINGGUINEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pointingGUInew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pointingGUInew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pointingGUInew

% Last Modified by GUIDE v2.5 12-Dec-2017 08:25:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pointingGUInew_OpeningFcn, ...
                   'gui_OutputFcn',  @pointingGUInew_OutputFcn, ...
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

% --- Executes just before pointingGUInew is made visible.
function pointingGUInew_OpeningFcn(hObject, eventdata, handles, varargin)
%set(cal_glbl_data.out_msg_solver, 'Max', 2);
handles.runNum=0;
handles.stopPres = 0;
handles.initX = 0;
handles.initY = 0;
handles.finalX = 0;
handles.finalY = 0;
handles.presOrig=lcaGet('GATT:FEE1:310:P_DES');
handles.DIxref = lcaGet('SIOC:SYS0:ML03:AO801');%Symmetric, 500 um right now;
handles.DIyref = lcaGet('SIOC:SYS0:ML03:AO802');%2350;
handles.DIxgain = lcaGet('SIOC:SYS0:ML03:AO821');
handles.DIygain = lcaGet('SIOC:SYS0:ML03:AO822');
handles.P3S1xref = lcaGet('SIOC:SYS0:ML03:AO803');%12480;
handles.P3S1yref = lcaGet('SIOC:SYS0:ML03:AO804');%1295;
handles.P3S1xgain = lcaGet('SIOC:SYS0:ML03:AO823');
handles.P3S1ygain = lcaGet('SIOC:SYS0:ML03:AO824');
handles.P3S2xref = lcaGet('SIOC:SYS0:ML03:AO805');%-17074;
handles.P3S2yref = lcaGet('SIOC:SYS0:ML03:AO806');%603;
handles.P3S2xgain = lcaGet('SIOC:SYS0:ML03:AO825');
handles.P3S2ygain = lcaGet('SIOC:SYS0:ML03:AO826');
handles.newImg = 0;
handles.text100=0;
handles.retract = 1
setTag(handles.text100, 'shotNum')
newMessage = [datestr(now), ' Point me in the right direction'];
setTag(newMessage, 'messages')
if lcaGet('VVPC:FEE1:311:OPN_DO', 0,'float') == 1;
    setTag('On', 'gasAtten')
else
    setTag('Off', 'gasAtten')
end
transmissionAct = lcaGet('GDSA:FEE1:TATT:R_ACT');
transmissionUse = round(100* transmissionAct);
setTag(transmissionUse, 'trans')
handles.mirror = lcaGet('MIRR:FEE1:0561:POSITION');
handles.softMir = lcaGet('STEP:FEE1:1811:MOTR.RBV');
if strcmp('IN',handles.mirror)%handles.mirror == 1
     dest = 'Soft Line';
     if handles.softMir < -1; 
        handles.camera = 3;
        setTag(handles.P3S2xref, 'xRef')
        setTag(handles.P3S2yref, 'yRef')
        setTag(handles.P3S2xgain, 'xGain')
        setTag(handles.P3S2ygain, 'yGain')
     else
        handles.camera = 2;
        setTag(handles.P3S1xref, 'xRef')
        setTag(handles.P3S1yref, 'yRef')
        setTag(handles.P3S1xgain, 'xGain')
        setTag(handles.P3S1ygain, 'yGain')
     end
else
    set(handles.attenOn, 'Enable', 'off')
    dest = 'Hard Line';
    handles.camera = 1;
    setTag(handles.DIxref, 'xRef')
    setTag(handles.DIyref, 'yRef')
    setTag(handles.DIxgain, 'xGain')
    setTag(handles.DIygain, 'yGain')
end
set(handles.popupmenu1, 'Value', handles.camera)
setTag(dest, 'destination')
handles.attenDes = lcaGet('SATT:FEE1:320:RACT');
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = pointingGUInew_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function  setTag(string,tag)
%string and tag in single quotes
r = findobj(gcf,'Tag',tag);
set(r,'String', string);

function appendList(handles,msg)
curr = cellstr(get(handles.messages, 'string'));
msgUse=[datestr(now),msg];
currNew=[{msgUse};curr];
set(handles.messages,'String', currNew);

function clearList(handles)
currNew=[];
set(handles.messages,'String', currNew);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(gcf)
if ~usejava('desktop')
    exit
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
%put in appropriate screen
camera = handles.camera
cams = {'DIAG:FEE1:481', 'CAMR:FEE1:1953', 'CAMR:FEE1:2953'}
camID = cams{camera}
if(handles.retract)
    if camera == 2 || camera == 3
        if camera == 3 
            appendList(handles, '  Putting in P3S2')
            lcaPut('CAMR:XTOD:SELECT', 6)
	    while(~strcmp(lcaGet('CAMR:FEE1:2953:STATE'), 'IN')) 
                pause(1)
            end
        elseif camera == 2
            appendList(handles, '  Putting in P3S1')
            lcaPut('CAMR:XTOD:SELECT', 5)
            while(~strcmp(lcaGet('CAMR:FEE1:1953:STATE'), 'IN')) 
                pause(1)
            end
        end
    else 
        %Put in DI
        appendList(handles, '  Putting in DI target ladder')
        lcaPutNoWait('TRGT:FEE1:483:SELECT', 2)
        %wait for DI target ladder to reach desired station
        pause(2)
        while(lcaGet('STEP:FEE1:483:MOTR.DMOV') == 0 | lcaGet('SSI:FEE1:483.VAL') > 0) 
            pause(1)
        end
    end
    pause(1)
end

appendList(handles, '  Averaging 50 shots')
try
    handles = runScan(camID,hObject, handles);
catch ME
    appendList(handles, '  Scan Failed, check camera.')
end
if(handles.retract)      
    if camera == 2 || camera == 3
        %Pull P2S
        appendList(handles, '  Pulling screen')
        lcaPut('CAMR:XTOD:SELECT', 0)
        pause(3)
        lcaPut('SIOC:SYS0:ML00:AO452',1)
    else 
    %Pull out DI 
        appendList(handles, '  Pulling target ladder, please wait.')
        lcaPutNoWait('TRGT:FEE1:483:SELECT', 1)
        pause(2)
        while(lcaGet('STEP:FEE1:483:MOTR.DMOV') == 0 | lcaGet('SSI:FEE1:483.VAL') < 0)
            pause(1)
        end
        appendList(handles, ' Target ladder retracted')
    end
end
handles.data
util_dataSave(handles, 'Pointing', camID, now)
util_appPrintLog(1,'Pointing GUI Stats',handles.data.name,handles.data.ts);
guidata(hObject, handles)

function handles = runScan(camID,hObject,handles)
data = profmon_grabSeries(camID,50,0,'bufd',1);
camID
handles.data=data(1);
b=profmon_process(handles.data, 'doPlot', 1);
%control_profDataSet(camID,b)
%handles.data.img=feval(class(data(1).img),mean(cat(4,data.img),4));
%sumY = 1000*(lcaGet(strcat(camID, ':X')));
%sumX = 1000*(lcaGet(strcat(camID, ':Y')));
b(1)
sumX = b(1).stats(1);
sumY = b(1).stats(2);
profmon_imgPlot(handles.data, 'axes', handles.axes1)
handles.yPos = round(sumY);
handles.xPos = round(sumX);
setTag(handles.yPos, 'yMeas')
setTag(handles.xPos, 'xMeas')
camera = handles.camera
if camera == 3
    handles.finalX = round((handles.P3S2xref - handles.xPos)*handles.P3S2xgain);
    handles.finalY = round((handles.P3S2yref - handles.yPos)*handles.P3S2ygain);
elseif camera == 2
    handles.finalX = round((handles.P3S1xref - handles.xPos)*handles.P3S1xgain);
    handles.finalY = round((handles.P3S1yref - handles.yPos)*handles.P3S1ygain);
else
    handles.finalX = round((handles.DIxref - handles.xPos)*handles.DIxgain);
    handles.finalY = round((handles.DIyref-handles.yPos)*handles.DIygain);
end
setTag(handles.finalX, 'finalX')
setTag(handles.finalY, 'finalY')
guidata(hObject, handles)

% --- Executes on selection change in messages.
function messages_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function messages_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InitialX_Callback(hObject, eventdata, handles)
initialX = str2double(get(hObject,'String'));
if ~isnan(initialX)
    handles.initX = initialX;
end
setTag(handles.initialX, 'initialX')
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function InitialX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InitialY_Callback(hObject, eventdata, handles)
initialY = str2double(get(hObject,'String'));
if ~isnan(initialY)
    handles.initY = initialY;
end
setTag(handles.initialY, 'initialY')
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function InitialY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function finalX_Callback(hObject, eventdata, handles)
finalX = str2double(get(hObject,'String'));
if ~isnan(finalX)
    handles.finalX = finalX;
end
setTag(handles.finalX, 'finalX')
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function finalX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function finalY_Callback(hObject, eventdata, handles)
finalY = str2double(get(hObject,'String'));
if ~isnan(finalY)
    handles.finalY = finalY;
end
setTag(handles.finalY, 'finalY')
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function finalY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
appendList(handles, '  Repointing')
repointUndulatorLine(handles.initX, handles.initY, handles.finalX, handles.finalY)
appendList(handles, '  Finished Repointing')

% --- Executes on button press in logbutton.
function logbutton_Callback(hObject, eventdata, handles)
h = gcf;
set(gcf, 'InvertHardcopy', 'off')
util_printLog(h, 'author', 'Pointing GUI')
camID = 'CAMR:IN20:186';
%util_dataSave(handles.dat, 'Pointing GUI', camID ,now)

function util_printLog2(fig, varargin)
optsdef=struct( ...
    'title','Matlab', ...
    'text','', ...
    'author','Matlab' ...
    );
opts=util_parseOptions(varargin{:},optsdef);
fig(~ishandle(fig))=[];

[sys,accel]=getSystem;
queue=['physics-' lower(accel) 'log'];


for f=fig(:)'
    if ~isempty(varargin) && ismember(accel,{'FACET'})
        util_printLog_wComments(f,opts.author,opts.title,opts.text,[500 375],0);
        continue
    end 
    print(f,'-dpsc2','-noui',['-P' queue]);
   
end

function util_printLog_wComments(fig,author,title,text,dim,invert)
% Parse input arguments.
if nargin< 6, invert=1; end
if nargin< 5, dim=[480 400]; end
if nargin< 4, text='Matlab'; end
if nargin< 3, title='Matlab'; end
if nargin< 2, author='Matlab'; end

% Check if FIG is handle.
fig(~ishandle(fig))=[];

%Render tag strings to comply with XML.
text=make_XML(text);
title=make_XML(title);
author=make_XML(author);

% Determine accelerator.
[sys,accel]=getSystem;
pathName=['/u1/' lower(reshape(char(accel)',1,[])) '/physics/logbook/data'];
if ~exist(pathName,'dir'), return, end

fileIndex=0;

for f=fig(:)'
    tstamp=datestr(now,31);
    [dstr, tstr] = strtok(tstamp);
    fileName=[strrep(tstamp, ' ', 'T') sprintf('-0%d',fileIndex)];
    if invert, set(fig,'InvertHardcopy','off');end  
    ext='.png';
     print(fig,'-dpng','-r75',(fullfile(pathName,[fileName ext])));
     print(fig,'-dpsc2' ,'-loose',(fullfile(pathName,[fileName '.ps'])));
    fid=fopen(fullfile(pathName,[fileName '.xml']),'w');
    if fid~=-1
        fprintf(fid,'<author>%s</author>\n',author);
        fprintf(fid,'<category>USERLOG</category>\n');
        fprintf(fid,'<title>%s</title>\n',title);
        fprintf(fid,'<isodate>%s</isodate>\n',dstr);
        fprintf(fid,'<time>%s</time>\n',tstr(2:end));
        fprintf(fid,'<severity>NONE</severity>\n');
        fprintf(fid,'<keywords></keywords>\n');
        fprintf(fid,'<location></location>\n');
        fprintf(fid,'<metainfo>%s</metainfo>\n',[fileName '.xml']);
        fprintf(fid,'<file>%s</file>\n',[fileName ext]);
        fprintf(fid,'<link>%s</link>\n',[fileName '.ps']);
        fprintf(fid,'<text>%s</text>\n',text);
        fclose (fid);
    end
    fileIndex=fileIndex+1;
end

function xRef_Callback(hObject, eventdata, handles)
newX = str2double(get(hObject,'String'));
camera = handles.camera
if camera == 3
    handles.P3S2xref = newX;
elseif camera == 2
    handles.P3S1xref = newX;
else
    handles.DIxref = newX;
end
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function xRef_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function yRef_Callback(hObject, eventdata, handles)
newY = str2double(get(hObject, 'String'));
camera = handles.camera
if camera == 3        
    handles.P3S2yref = newY;
elseif camera == 2
    handles.P3S1yref = newY;
else
    handles.DIyref = newY;
end
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function yRef_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in setTen.
function setTen_Callback(hObject, eventdata, handles)
appendList(handles, '  Setting Machine Rate to 10 hz')
lcaPut('IOC:IN20:EV01:RG02_DESRATE',12)


% --- Executes on button press in restTen.
function restTen_Callback(hObject, eventdata, handles)
appendList(handles, '  Restoring Machine Rate to 120 Hz')
lcaPut('IOC:IN20:EV01:RG02_DESRATE',10)


% --- Executes on button press in transmission.
function transmission_Callback(hObject, eventdata, handles)
if strcmp('IN',handles.mirror);
    appendList(handles, '  Setting Gas Attenuator for <10% transmission, this could take a few seconds')
    lcaPut('GATT:FEE1:310:R_DES', 0.07)
    newPres = lcaGet('GATT:FEE1:310:P_DES_ATT');
    lcaPut('FEE:VAC:VCN:10:SetOperatingMode', 2)
    lcaPut('GATT:FEE1:310:P_DES', newPres)
    curPres = lcaGet('FEE:VAC:VCN:10:GetActualValueRaw');
    while curPres<(newPres-0.1) || curPres>(newPres+0.1)
        pause(3)
        curPres = lcaGet('FEE:VAC:VCN:10:GetActualValueRaw');
        appendList(handles, '  Waiting for pressure')
    end
    appendList(handles, '  Gas attenuation set')
else
    appendList(handles, '  Setting solid attenuators for <10% transmission')
    lcaPut('SATT:FEE1:320:RDES', 0.07)
    lcaPut('SATT:FEE1:320:GO', 3)
    pause(5)
end

transmissionAct = lcaGet('GDSA:FEE1:TATT:R_ACT');
transmissionUse = round(100* transmissionAct);
setTag(transmissionUse, 'trans')

% --- Executes on button press in attenOff.
function attenOff_Callback(hObject, eventdata, handles)
appendList(handles, '  Turning Gas Attenuator Off')
lcaPut('GATT:FEE1:310:P_DES', 0)
pause(2)
lcaPut('FEE:VAC:VCN:10:CloseValve.PROC', 1)
lcaPut('VVPR:FEE1:261:CLOSE_CMD', 1)
lcaPut('VVPR:FEE1:262:CLOSE_CMD', 1)
lcaPut('VVPR:FEE1:341:CLOSE_CMD', 1)
lcaPut('VVPR:FEE1:342:CLOSE_CMD', 1)
lcaPut('VPRO:FEE1:261:STOP_CMD', 1)
lcaPut('VPRO:FEE1:262:STOP_CMD', 1)
lcaPut('VPRO:FEE1:341:STOP_CMD', 1)
lcaPut('VPRO:FEE1:342:STOP_CMD', 1)
setTag('Off', 'gasAtten')


% --- Executes on button press in attenOn.
function attenOn_Callback(hObject, eventdata, handles)
appendList(handles, '  Turning Gas Attenuator On')
lcaPut('VPRO:FEE1:261:START_CMD', 1)
lcaPut('VPRO:FEE1:262:START_CMD', 1)
lcaPut('VPRO:FEE1:341:START_CMD', 1)
lcaPut('VPRO:FEE1:342:START_CMD', 1)
pause(25)
lcaPut('VVPR:FEE1:261:OPEN_CMD', 1)
lcaPut('VVPR:FEE1:262:OPEN_CMD', 1)
lcaPut('VVPR:FEE1:341:OPEN_CMD', 1)
lcaPut('VVPR:FEE1:342:OPEN_CMD', 1)
pause(2)
lcaPut('VVPC:FEE1:311:OPEN_CMD', 1)
pause(4)
lcaPut('FEE:VAC:VCN:10:SetOperatingMode', 1)
setTag('On', 'gasAtten')

% --- Executes on button press in restTrans.
function restTrans_Callback(hObject, eventdata, handles)
if strcmp('IN',handles.mirror);
    handles.stopPres=1;
    appendList(handles, '  Setting gas attenuator back to original pressure')
    lcaPut('GATT:FEE1:310:P_DES', handles.presOrig)
else
    appendList(handles, '  Setting solid attenuator back to original setting')
    lcaPut('SATT:FEE1:320:RDES', handles.attenDes)
    lcaPut('SATT:FEE1:320:GO', 3)
end
transmissionAct = lcaGet('GDSA:FEE1:TATT:R_ACT');
transmissionUse = round(100* transmissionAct);
setTag(transmissionUse, 'trans')
guidata(hObject,handles)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
pos = get(gcf,'Position');
set(0,'Units','characters');
scrnsz=get(0,'ScreenSize');
set(0,'Units','pixels');
newx = pos(1) + 90;
newy = pos(2);

if newx > (scrnsz(3) - 76)
    newx = pos(1) - 76;
end

% Launch a new figure for the help page
figure('Units','characters','Position',[newx newy 105 24],'Color',[1 0 1], ...
                'Name','Aidalist','NumberTitle','off','MenuBar','none','Resize','off');
uipanel('Title','Pointing GUI Help','units','characters', ...
           'Position',[0 0 105 24],'BorderType','none', ...
            'FontSize',15,'BackgroundColor',[0.85 0.85 0.85],'HighlightColor','white', ...
            'BorderWidth',1,'TitlePosition','centertop');

% All the text
props={'Style','text','HorizontalAlignment','left','units','characters'};
uicontrol(props{:},'String','What Does It Do?', ...
           'FontSize',14,'FontWeight','bold','Position',[2 19 73 2.8],'BackgroundColor',[0.85 0.85 0.85]); 
uicontrol(props{:},'String','This GUI allows the user to turn on/off the gas attenuator, set the machine rate to 10 Hz, set the attenuation to 10%, and measure the pointing on the appropriate screen.', ...
           'FontSize',10,'FontWeight','normal','Position',[5 14 85 6],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','What Does Each Button Do?', ...
           'FontSize',14,'FontWeight','bold','Position',[2 13 93 2.8],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String',{'Gas Attenuator On/Off: Turning the gas attenuator on/off starts/stops pumps and opens/closes valves for attenuator system' '10% Transmission:  Setting 10% transmission will automatically set gas/solid attenuation for soft/hard x-rays' 'Set/Restore 10 Hz:  Sets the machine rate to 10 or 120 Hz using IOC:IN20:EV01:RG01_DESRATE' 'Check Pointing Measure:  Puts in appropriate screen and measures 100 shots to find centroid, then removes screen' 'Repoint(Xi, Yi, Xf, Yf):  Button takes xi, yi, xf, yf from enter boxes and repoints undulators' 'Update Ref Pos: Updates reference positions for cameras if they change'}, ...      
           'FontSize',10,'FontWeight','normal','Position',[5 2 95 12],'BackgroundColor',[0.85 0.85 0.85]);
       


% --- Executes on button press in updateRef.
function updateRef_Callback(hObject, eventdata, handles)
% hObject    handle to updateRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('SIOC:SYS0:ML03:AO801',handles.DIxref);
lcaPut('SIOC:SYS0:ML03:AO802',handles.DIyref);
lcaPut('SIOC:SYS0:ML03:AO803',handles.P3S1xref);
lcaPut('SIOC:SYS0:ML03:AO804',handles.P3S1yref);
lcaPut('SIOC:SYS0:ML03:AO805',handles.P3S2xref);
lcaPut('SIOC:SYS0:ML03:AO806', handles.P3S2yref);


% --- Executes on button press in resetGUI.
function resetGUI_Callback(hObject, eventdata, handles)
close(gcbf)
pointingGUInew



function xGain_Callback(hObject, eventdata, handles)
% hObject    handle to xGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xGain as text
%        str2double(get(hObject,'String')) returns contents of xGain as a double
newX = str2double(get(hObject,'String'));
camera = handles.camera
if camera == 3        
    handles.P3S2xgain = newX;
elseif camera == 2
    handles.P3S1xgain = newX;
else
    handles.DIxgain = newX;
end
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function xGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yGain_Callback(hObject, eventdata, handles)
% hObject    handle to yGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yGain as text
%        str2double(get(hObject,'String')) returns contents of yGain as a double

newY = str2double(get(hObject,'String'));
camera = handles.camera
if camera == 3
    handles.P3S2ygain = newY;
elseif camera == 2
    handles.P3S1ygain = newY;
else
    handles.DIygain = newY;
end
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function yGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('SIOC:SYS0:ML03:AO821',handles.DIxgain);
lcaPut('SIOC:SYS0:ML03:AO822',handles.DIygain);
lcaPut('SIOC:SYS0:ML03:AO823',handles.P3S1xgain);
lcaPut('SIOC:SYS0:ML03:AO824',handles.P3S1ygain);
lcaPut('SIOC:SYS0:ML03:AO825',handles.P3S2xgain);
lcaPut('SIOC:SYS0:ML03:AO826', handles.P3S2ygain);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String')) 
camera = get(hObject,'Value')
if(handles.camera ~= camera) 
    setTag(0, 'finalX')
    setTag(0, 'finalY')
    setTag('', 'yMeas')
    setTag('', 'xMeas')
end

handles.camera = camera
if camera == 3
    setTag(handles.P3S2xref, 'xRef')
    setTag(handles.P3S2yref, 'yRef')
    setTag(handles.P3S2xgain, 'xGain')
    setTag(handles.P3S2ygain, 'yGain')
elseif camera == 2
    setTag(handles.P3S1xref, 'xRef')
    setTag(handles.P3S1yref, 'yRef')
    setTag(handles.P3S1xgain, 'xGain')
    setTag(handles.P3S1ygain, 'yGain')
else
    setTag(handles.DIxref, 'xRef')
    setTag(handles.DIyref, 'yRef')
    setTag(handles.DIxgain, 'xGain')
    setTag(handles.DIygain, 'yGain')
end


guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.retract = get(hObject, 'Value')
guidata(hObject, handles)
