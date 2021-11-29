function varargout = undOrbituner(varargin)
% UNDORBITUNER M-file for undOrbituner.fig
%      UNDORBITUNER, by itself, creates a new UNDORBITUNER or raises the existing
%      singleton*.
%
%      H = UNDORBITUNER returns the handle to a new UNDORBITUNER or the handle to
%      the existing singleton*.
%
%      UNDORBITUNER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDORBITUNER.M with the given input arguments.
%
%      UNDORBITUNER('Property','Value',...) creates a new UNDORBITUNER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before undOrbituner_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to undOrbituner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help undOrbituner

% Last Modified by GUIDE v2.5 02-Jul-2014 12:43:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @undOrbituner_OpeningFcn, ...
                   'gui_OutputFcn',  @undOrbituner_OutputFcn, ...
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

% --- Executes just before undOrbituner is made visible.
function undOrbituner_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.currentIPM = 'GDET';
handles.undNumber = '20';
handles.redrawNum = 120;

handles.curFeed = lcaGet('SIOC:SYS0:ML02:AO127');
if handles.curFeed == 2
    read = 'Matlab';
else
    read = 'Fast';
end

a = findobj(gcf,'Tag','read');
set(a,'String',read);

undNumber = handles.undNumber;
b = findobj(gcf,'Tag','undNumber');
set(b,'String',undNumber);

redrawNum = handles.redrawNum;
c = findobj(gcf,'Tag','redrawNum');
set(c,'String',redrawNum);

if handles.curFeed == 2;
    positionUnd = lcaGet('FBCK:UND0:1:XPOSSP');
    d = findobj(gcf,'Tag','positionUnd');
    set(d,'String', positionUnd);
    angleUnd = lcaGet('FBCK:UND0:1:XANGSP');
    e = findobj(gcf,'Tag','angleUnd');
    set(e,'String', angleUnd);
else
    positionUnd = lcaGet('FBCK:FB03:TR04:S1DES');
    d = findobj(gcf,'Tag','positionUnd');
    set(d,'String', positionUnd);
    angleUnd = lcaGet('FBCK:FB03:TR04:S2DES');
    e = findobj(gcf,'Tag','angleUnd');
    set(e,'String', angleUnd);
end

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = undOrbituner_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
str = get(hObject, 'String');
FocusToFig(hObject);
switch str{val};
    case 'GDET' 
        handles.currentIPM = 'GDET';
    case 'SXR'
        handles.currentIPM = 'SXR';
    case 'XPP1' 
        handles.currentIPM = 'XPP1';
    case 'XPP2'
        handles.currentIPM = 'XPP2';
    case 'XPP3'
        handles.currentIPM = 'XPP3';
    case 'XPP4' 
        handles.currentIPM = 'XPP4';
    case 'XPP5' 
        handles.currentIPM = 'XPP5';
    case 'XPP6'
        handles.currentIPM = 'XPP6';
    case 'XCS1'
        handles.currentIPM = 'XCS1';
    case 'XCS2' 
        handles.currentIPM = 'XCS2';
    case 'MEC1'
        handles.currentIPM = 'MEC1';
    case 'MEC2'
        handles.currentIPM = 'MEC2';
    case 'MEC3'
        handles.currentIPM = 'MEC3';
    case 'MEC4' 
        handles.currentIPM = 'MEC4';
    case 'MEC5' 
        handles.currentIPM = 'MEC5';
    case 'MEC6'
        handles.currentIPM = 'MEC6';
    case 'MEC7'
        handles.currentIPM = 'MEC7';
    case 'MEC8' 
        handles.currentIPM = 'MEC8';
    case 'MEC9' 
        handles.currentIPM = 'MEC9';
end
guidata(hObject, handles);

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function undNumber_Callback(hObject, eventdata, handles)
handles.undNumber = get(hObject, 'String');
guidata(hObject, handles);

function undNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FocusToFig(ObjH, EventData) 
% Move focus to figure, keep pop up menu from changing colors
if any(ishandle(ObjH))   % Catch no handle and empty ObjH
   FigH = ancestor(ObjH, 'figure');
   if strcmpi(get(ObjH, 'Type'), 'uicontrol')
      set(ObjH, 'enable', 'off');
      drawnow;
      set(ObjH, 'enable', 'on');
   end
     figure(FigH);
     set(0, 'CurrentFigure', FigH);
end
return;

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
set(hObject, 'string', 'Stop', 'BackgroundColor', [1 0 0]);
colordef black
handles.startStop = get(hObject, 'Value');
lcaPut('SIOC:SYS0:ML01:AO724', handles.startStop)
IPMall2(handles.currentIPM, handles.redrawNum, [handles.undNumber, '90'])
set(hObject, 'Value', 0)
set(hObject, 'string', 'Start', 'BackgroundColor', [0 1 0]); 

function IPMall2(dev,num,xx20)
%  function IPMall(dev,num,UND_BPM_num)
%  e.g.:    IPMall('GDET') plots the Gas detector versus DL2 Energy
%  e.g.:    IPMall('GDET',120,2090) plots versus x at BPMS:UND1:2090 
%
%  Devices (dev) can be: 
%  'HX21' 'XPP1' 'XPP2' 'XPP3' 'XPP4' 'XPP5' 'XPP6' 'XCS1' 'XCS2' 'MEC1' 
%  'MEC2' 'MEC3' 'MEC4' 'MEC5' 'MEC6' 'MEC7' 'MEC8' 'MEC9' 'GDET'
%  optional: num is about time in sec display runs, default = 100 sec
%  optional: UND_BPM_num than versus orbit in x

% FJD 10-Mar-2014
%
if ~exist('dev')
    dev='GDET';
end

if ~exist('num')
    num=100;
end
dev=upper(dev);
ipmall={   'HX2:SB1:IPM:01:SUM'        %XPP in SXR
% XPP
'SXR:GMD:BLD:milliJoulesPerPulse'
'XPP:MON:IPM:01:SUM'
'XPP:MON:IPM:02:SUM'
'XPP:SB2:IPM:01:SUM'
'XPP:SB3:IPM:01:SUM'
%'XPP:SB3:IPM:02:SUM'
'XPP:SB4:IPM:01:SUM'


'XPP:USR:IPM:01:SUM'
%'XPP:USR:IPM:02:SUM'

% XRT -- these 2 sets are not accessible yet
%       there should also be a DG2 set

%HFX:DG1:IPM:01:SUM'
%'HFX:DG2:IPM:01:SUM'
%'HFX:DG3:IPM:01:SUM'

% XCS

'XCS:DG1:IMB:01:SUM'
'XCS:DG1:IMB:02:SUM'

% MEC line in XRT

'MEC:HXM:IPM:01:SUM'
'MEC:HXM:PIM:01:SUM'


'MEC:XT2:IPM:02:SUM'

'MEC:XT2:PIM:02:SUM'

'MEC:XT2:IPM:03:SUM'

'MEC:XT2:PIM:03:SUM'


'MEC:USR:IMB:01:SUM'


'MEC:USR:IMB:02:SUM'

% Not working yet
%MEC:TC1:IMB:01:CH0
%MEC:TC1:IMB:01:CH1
%MEC:TC1:IMB:01:CH2
%MEC:TC1:IMB:01:CH3
'MEC:TC1:IMB:01:SUM' 
'GDET:FEE1:241:ENRC'
%'BPMS:UND1:2090:X'};
'BPMS:LTU1:250:X'};
if exist('xx20')
    ipmall(21)=cellstr(['BPMS:UND1:', num2str(xx20),':X']);
end
ipmalldum = {'HX21'
    'SXR'
    'XPP1'
    'XPP2'
    'XPP3'
    'XPP4'
    'XPP5'
    'XPP6'
    'XCS1'
    'XCS2'
    'MEC1'
    'MEC2'
    'MEC3'
    'MEC4'
    'MEC5'
    'MEC6'
    'MEC7'
    'MEC8'
    'MEC9'
    'GDET'};
 ispec=find(strcmp(ipmalldum, dev) == 1);   
    
energy=lcaGet('BEND:LTU0:125:BDES');
photonE=lcaGet('SIOC:SYS0:ML00:AO627');
scale=1;
if energy>8
    scale=2;
end
    
sumall0=lcaGet(ipmall);
[i20, idd]=size(ipmall);
i600=30;
tt1=0;
tcount=0;
tbad=0;
for j=1:num
    stopcall = lcaGet('SIOC:SYS0:ML01:AO724');
if stopcall == 0, break, end
sumall=zeros(i20,i600);
ts=zeros(i20,i600);
tic;
i=0;
ID=zeros(i600,1);
IDint=zeros(i600,1);
while i<=i600-1
    i=i+1;
    [sumall(:,i), ts(:,i)]=lcaGet(ipmall);
    ID(i)=lcaTs2PulseId(ts(end,i));
    IDint(i)=lcaTs2PulseId(ts(ispec,i));
    if(i>1 && ID(i)==ID(i-1))  || (ID(i)~=IDint(i)+3* max(~strcmp(dev,'GDET'),tt1)); 
        i=i-1; 
    %elseif (ID(i)~=IDint(i))
    end  
pause(0.002)
end
t=toc;

i10=3;
tcount=tcount+1;
if t>0.38
    maybe_out_of_Sync = t;
    tbad=tbad+1;
    %tt1=1;
end
if tbad/(i10+tcount) >0.5
    tt1=1;
end
if ~exist('E0') E0=[]; Int0=[]; end
tmax=1200;
if length(E0) > tmax
    E0=E0(1:tmax-i600);
    Int0=Int0(1:tmax-i600);
end
E =[sumall(end,:)/1.25 E0];
E0=E;
Int=[sumall(ispec,:) Int0];
Int0=Int;
%meaInt=mean(Int);
maxInt = min(ceil(max(Int)), 1.25*max(Int));  %, 3*meaInt);
%plot(sumall(end,:)/1.25,sumall(end-1,:),'*')
h1m=plot(E,Int,'.');
plotfj18
rmsE = round(1000*std(E))/1000;
rmsInt = std(Int)./mean(Int)*100;
xlabel(['e-Beam Energy [%], rms =  ', num2str(rmsE,'%0.3f'), ' %'])
if exist('xx20')
    xlabel(['BPMS:UND1:', num2str(xx20), ' x [mm]'])
    scale=10;
end
if strcmp(dev,'GDET')
    ylabel(['FEL Inensity [mJ], rms =  ', num2str(rmsInt,'%4.1f'), ' %'])
    title(['Gas Detector vs Energy   (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    if exist('xx20')
        title(['Gas Detector vs Undulator X  (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    end
else
    ylabel([dev(1:3) ' IPM Sum, rms =  ', num2str(rmsInt,'%4.1f'), ' %'])
    title([char(ipmall{ispec}(1:14)) ' vs Energy   (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    if exist('xx20')
        title([char(ipmall{ispec}(1:14)) ' vs Undulator X   (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    end
end

axis([-.4/scale .4/scale 0 maxInt])
grid on
drawnow
pause(0.1)
end

function redrawNum_Callback(hObject, eventdata, handles)
handles.redrawNum = str2double(get(hObject, 'String'));
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function redrawNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
if handles.curFeed == 2
    ang = lcaGet('FBCK:UND0:1:XANGSP');
    angleUnd = ang + 0.0002;
    lcaPut('FBCK:UND0:1:XANGSP', angleUnd);
    f = findobj(gcf,'Tag','angleUnd');
    set(f,'String', angleUnd);
else
    ang = lcaGet('FBCK:FB03:TR04:S2DES');
    angleUnd = ang + 0.0002;
    lcaPut('FBCK:FB03:TR04:S2DES', angleUnd);
    f = findobj(gcf,'Tag','angleUnd');
    set(f,'String', angleUnd);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
if handles.curFeed == 2
    ang = lcaGet('FBCK:UND0:1:XANGSP');
    angleUnd = ang - 0.0002;
    lcaPut('FBCK:UND0:1:XANGSP', angleUnd);
    f = findobj(gcf,'Tag','angleUnd');
    set(f,'String', angleUnd);
else
    ang = lcaGet('FBCK:FB03:TR04:S2DES');
    angleUnd = ang - 0.0002;
    lcaPut('FBCK:FB03:TR04:S2DES', angleUnd);
    f = findobj(gcf,'Tag','angleUnd');
    set(f,'String', angleUnd);
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
if handles.curFeed == 2
    pos = lcaGet('FBCK:UND0:1:XPOSSP');
    positionUnd = pos + 0.005;
    lcaPut('FBCK:UND0:1:XPOSSP', positionUnd);
    f = findobj(gcf,'Tag','positionUnd');
    set(f,'String',positionUnd);
else
    pos = lcaGet('FBCK:FB03:TR04:S1DES');
    positionUnd = pos + 0.005;
    lcaPut('FBCK:FB03:TR04:S1DES', positionUnd);
    f = findobj(gcf,'Tag','positionUnd');
    set(f,'String',positionUnd);
end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
if handles.curFeed == 2
    pos = lcaGet('FBCK:UND0:1:XPOSSP');
    positionUnd = pos - 0.005;
    lcaPut('FBCK:UND0:1:XPOSSP', positionUnd);
    f = findobj(gcf,'Tag','positionUnd');
    set(f,'String',positionUnd);
else
    pos = lcaGet('FBCK:FB03:TR04:S1DES');
    positionUnd = pos - 0.005;
    lcaPut('FBCK:FB03:TR04:S1DES', positionUnd);
    f = findobj(gcf,'Tag','positionUnd');
    set(f,'String',positionUnd);
end

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
h = gcf;
set(gcf, 'InvertHardcopy', 'off')
util_printLog2(h, 'author', 'tunageddon')
util_dataSave(data, 'Tunageddon', handles.currentmatch_mag, now)

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

function str = make_XML(str)

str=strrep(str,'&','&amp;');
str=strrep(str,'"','&quot;');
str=strrep(str,'''','&apos;');
str=strrep(str,'<','&lt;');
str=strrep(str,'>','&gt;');
