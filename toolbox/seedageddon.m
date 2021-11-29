function varargout = seedageddon(varargin)
% SEEDAGEDDON M-file for seedageddon.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seedageddon_OpeningFcn, ...
                   'gui_OutputFcn',  @seedageddon_OutputFcn, ...
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

function seedageddon_OpeningFcn(hObject, eventdata, handles, varargin)
handles.matchmagnetlist = {'FBCK:FB04:LG01:DL2VERNIER'
                           'XTAL:UND1:1653:MOTOR'
                           'SIOC:SYS0:ML01:AO901'
                           'QUAD:LI21:201:BCTRL'
                           'QUAD:LI21:211:BCTRL' 
                           'QUAD:LI21:271:BCTRL' 
                           'QUAD:LI21:278:BCTRL'
                           'QUAD:LI26:201:BCTRL'
                           'QUAD:LI26:301:BCTRL' 
                           'QUAD:LI26:401:BCTRL' 
                           'QUAD:LI26:501:BCTRL'
                           'QUAD:LI26:601:BCTRL'
                           'QUAD:LI26:701:BCTRL'
                           'QUAD:LI26:801:BCTRL'
                           'QUAD:LI26:901:BCTRL'
                           'QUAD:LTU1:620:BCTRL' 
                           'QUAD:LTU1:640:BCTRL' 
                           'QUAD:LTU1:660:BCTRL'
                           'QUAD:LTU1:680:BCTRL'
                           'QUAD:LI21:221:BCTRL'
                           'QUAD:LI21:251:BCTRL'
                           'QUAD:LI24:740:BCTRL'
                           'QUAD:LI24:860:BCTRL'
                           'QUAD:LTU1:440:BCTRL'
                           'QUAD:LTU1:460:BCTRL'  
                           'SIOC:SYS0:ML01:AO902'                                         
                           'WPLT:LR20:117:LHWP_ANGLE'
                           'FBCK:FB01:TR03:S1DES'
                                                       };

handles.currentmatch_mag = handles.matchmagnetlist(1);
handles.output = hObject;

handles.zigzag = 1;
handles.numsteps = 10;
numsteps = handles.numsteps;
d = findobj(gcf, 'Tag', 'numsteps');
set(d, 'String', numsteps);

handles.percent = 10;
percent = handles.percent;
r = findobj(gcf,'Tag','percent');
set(r,'String',percent);

handles.numpulses = 120;
numpulses = handles.numpulses;
nump = findobj(gcf, 'Tag', 'numpulses');
set(nump, 'String', numpulses);

handles.rejection = 0.1;
rejection = handles.rejection;
q = findobj(gcf,'Tag', 'rejection');
set(q, 'String',rejection);

handles.settle = 3;
settle = handles.settle;
z = findobj(gcf, 'Tag', 'settle');
set(z, 'String', settle);

currentmag = handles.currentmatch_mag;
a = findobj(gcf,'Tag','currentmag');
set(a,'String',currentmag);

value1 = lcaGet(handles.currentmatch_mag);
b = findobj(gcf,'Tag','value1');
set(b,'String',value1);
value2 = lcaGet(handles.currentmatch_mag);

handles.best = value1;
best = handles.best;
e = findobj(gcf,'Tag','best');
set(e, 'String',best);

c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
disp(handles.currentmatch_mag);

handles.setval = 0;

range = (handles.percent/100)*value1;

if value1>0
    handles.startval = value1 - 0.5*range;
    handles.endval = value1 + 0.5*range;
else
    handles.startval = value1 + 0.5*range;
    handles.endval = value1 - 0.5*range;
end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject, handles);
grid off

function varargout = seedageddon_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function matchmags_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
str = get(hObject, 'String');
FocusToFig(hObject);
switch str{val};
    case 'L3 Vernier'
        handles.currentmatch_mag = handles.matchmagnetlist(1);
    case 'XTAL Angle' 
        handles.currentmatch_mag = handles.matchmagnetlist(2);
    case 'HXRSS Delay' 
        handles.currentmatch_mag = handles.matchmagnetlist(3);   
    case '21:201' 
        handles.currentmatch_mag = handles.matchmagnetlist(4);
    case 'QM11' 
        handles.currentmatch_mag = handles.matchmagnetlist(5);
    case 'QM12'
        handles.currentmatch_mag = handles.matchmagnetlist(6);
    case 'QM13'
        handles.currentmatch_mag = handles.matchmagnetlist(7);
    case '26:201' 
        handles.currentmatch_mag = handles.matchmagnetlist(8);
    case '26:301' 
        handles.currentmatch_mag = handles.matchmagnetlist(9);
    case '26:401'
        handles.currentmatch_mag = handles.matchmagnetlist(10);
    case '26:501'
        handles.currentmatch_mag = handles.matchmagnetlist(11);
    case '26:601' 
        handles.currentmatch_mag = handles.matchmagnetlist(12);
    case '26:701'
        handles.currentmatch_mag = handles.matchmagnetlist(13);
    case '26:801'
        handles.currentmatch_mag = handles.matchmagnetlist(14);
    case '26:901'
        handles.currentmatch_mag = handles.matchmagnetlist(15);
    case 'LTU:620' 
        handles.currentmatch_mag = handles.matchmagnetlist(16);
    case 'LTU:640' 
        handles.currentmatch_mag = handles.matchmagnetlist(17);
    case 'LTU:660'
        handles.currentmatch_mag = handles.matchmagnetlist(18);
    case 'LTU:680'
        handles.currentmatch_mag = handles.matchmagnetlist(19);
    case 'CQ11' 
        handles.currentmatch_mag = handles.matchmagnetlist(20);
    case 'CQ12' 
        handles.currentmatch_mag = handles.matchmagnetlist(21);
    case 'CQ21'
        handles.currentmatch_mag = handles.matchmagnetlist(22);
    case 'CQ22'
        handles.currentmatch_mag = handles.matchmagnetlist(23);
    case 'CQ31' 
        handles.currentmatch_mag = handles.matchmagnetlist(24);
    case 'CQ32' 
        handles.currentmatch_mag = handles.matchmagnetlist(25);
    case 'HXRSS Phase'
        handles.currentmatch_mag = handles.matchmagnetlist(26);
    case 'LHWP'
        handles.currentmatch_mag = handles.matchmagnetlist(27);
    case 'XCAV'
        handles.currentmatch_mag = handles.matchmagnetlist(28);
end

currentmag = handles.currentmatch_mag;
a = findobj(gcf,'Tag','currentmag');
set(a,'String',currentmag);

value1 = lcaGet(handles.currentmatch_mag);
b = findobj(gcf,'Tag','value1');
set(b,'String',value1);

handles.best = value1;

handles.value1 = value1;

best = handles.best;
e = findobj(gcf,'Tag','best');
set(e, 'String',best);

value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
handles.currentmag = value1;

range = (handles.percent/100)*value1;
    if value1>0
        handles.startval = value1 - 0.5*range;
        handles.endval = value1 + 0.5*range;
    else
        handles.startval = value1 + 0.5*range;
        handles.endval = value1 - 0.5*range;
    end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject,handles)

function matchmags_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispmags_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function startstop_Callback(hObject, eventdata, handles)
set(hObject, 'string', 'Stop', 'BackgroundColor', [1 0 0]);
x = [];
f = [];
y = [];
y2 = [];
peakcounts = zeros(handles.numpulses,1);
peaklocate = zeros(handles.numpulses,1);
fwhm = zeros(handles.numpulses,1);
spectInt = zeros(handles.numpulses,1);
rate = lcaGet('SIOC:SYS0:ML00:AO467');
value = lcaGet(handles.currentmatch_mag);
best = handles.value1;
if handles.startstop == 1
    value1 = lcaGet(handles.currentmatch_mag);
    handles.value1 = value1;
    b = findobj(gcf,'Tag','value1');
    set(b,'String',value1);
end
startval = handles.startval;
endval = handles.endval;
if value > 0
    range = endval - startval;
else
    range = startval - endval;
end
stepsize = range/(handles.numsteps-1);
handles.startstop = 1;
settlet = handles.settle;
if value > 0
    startlim = handles.startval - stepsize;
    endlim = handles.endval + stepsize;
else
    startlim = handles.startval + stepsize;
    endlim = handles.endval - stepsize;
end
rangearray = [startlim endlim];
for k = 1:handles.numsteps;
    if value>0
        f(k) = startval + stepsize*(k-1);
    else
        f(k) = startval - stepsize*(k-1);
    end
end
handles.startstop = 1;
colordef black
for i = 1:handles.numsteps;
    rate1 = lcaGet('SIOC:SYS0:ML00:AO467');
    while rate1<rate
        rate1 = lcaGet('SIOC:SYS0:ML00:AO467');
        pause(3)
    end
    Fs = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
    T = 1/Fs*handles.numpulses;
    handles.startstop = get(hObject,'Value');
    if handles.startstop == 0, lcaput(handles.currentmatch_mag, value), break, end
     if handles.zigzag == 0
        if value > 0
            lcaPut(handles.currentmatch_mag, handles.startval+stepsize*(i-1))
        else
            lcaPut(handles.currentmatch_mag, handles.startval-stepsize*(i-1))
        end    
     else
        if mod(handles.numsteps,2) 
            scan_array=[handles.numsteps:-2:1 2:2:handles.numsteps-1];
        else
            scan_array=[handles.numsteps:-2:2 1:2:handles.numsteps-1];
        end 
        if value > 0
            scan_array = fliplr(scan_array);
        end
        diff = f - value;
        ind = find(abs(diff) == min(abs(diff)));
        ind2 = find(scan_array == ind(1));
        scan_array_use = transpose(circshift(transpose(scan_array),ind2));
        [order, arrangeI] = sort(scan_array_use);
        lcaPut(handles.currentmatch_mag, f(scan_array_use(i)))
     end            
    value2 = lcaGet(handles.currentmatch_mag);
    c = findobj(gcf,'Tag','value2');
    set(c,'String',value2);
    pause(settlet)
    for u = 1:handles.numpulses
    peakcounts(u) = lcaGetSmart('SIOC:SYS0:ML00:AO681');
    peaklocate(u) = lcaGetSmart('SIOC:SYS0:ML00:AO680');
    fwhm(u) = lcaGetSmart('SIOC:SYS0:ML00:AO682');
    spectInt(u) = lcaGetSmart('SIOC:SYS0:ML00:AO683');
    end
    peakcountsmean = mean(peakcounts);
    peakcountsStdDev = std(peakcountsmean);
    peaklocatemean = mean(peaklocate);
    fwhmmean = mean(fwhm);
    spectIntmean = mean(spectInt);
    x(i) = value2;
    y(i) = peakcountsmean;
    y2(i) = peakcountsStdDev;
    errorbar(x,y,y2, '*', 'Color', 'yellow')
    xlim([min(rangearray) max(rangearray)]);
    xlabel(['Signal Value of ' handles.currentmatch_mag], 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Peak Counts with jitter error bars', 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold');
    if i == handles.numsteps
        hold on
        x3 = x(arrangeI);
        y3 = y(arrangeI);
        coefficients = polyfit(x3, y3, 2);
        newy = polyval(coefficients, x3);
        plot(x3, newy, '-', 'Color', 'yellow')
        d = polyder(coefficients);
        if isnan(d) == 1
            d = [0 0];
        end
        best1 = roots(d);
        second = polyder(d);
        handles.data.x = x;
        handles.data.y = y;
        handles.data.PV = handles.currentmatch_mag;
        if second < 0 && startval<best1 && endval>best1
            handles.best = best1;
            best = handles.best;
        else
            disp('bad fit')
            j = find(y==max(y));
            handles.best = x(j);
            best = handles.best;
        end
          hold off
    end
end
aa = findobj(gcf,'Tag', 'peaklocatemean');
set(aa, 'String', peaklocatemean)
bb = findobj(gcf,'Tag', 'fwhmmean');
set(bb, 'String', fwhmmean)
cc = findobj(gcf,'Tag', 'spectIntmean');
set(cc, 'String', spectIntmean)
q = findobj(gcf,'Tag', 'best');
set(q, 'String', best)
lcaPut(handles.currentmatch_mag, value)
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
set(hObject, 'Enable', 'on', 'String', 'Start', 'BackgroundColor', [0 1 0], 'Value', 0);
guidata(hObject, handles);

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

function percent_Callback(hObject, eventdata, handles)
percent = get(hObject, 'String');
handles.percent = str2double(percent);
value1 = lcaGet(handles.currentmatch_mag);
range = (handles.percent/100)*value1;
if value1>0
    handles.startval = value1 - 0.5*range;
    handles.endval = value1 + 0.5*range;
else
    handles.startval = value1 + 0.5*range;
    handles.endval = value1 - 0.5*range;
end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject, handles);

function percent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numpulses_Callback(hObject, eventdata, handles)
numpulses = str2double(get(hObject, 'String'));
if ~isnan(numpulses)
    handles.numpulses = numpulses;
end
guidata(hObject, handles);

function numpulses_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rejection_Callback(hObject, eventdata, handles)
rejection = str2double(get(hObject, 'String'));
if ~isnan(rejection)
    handles.rejection = rejection;
end
guidata(hObject, handles);

function rejection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function settle_Callback(hObject, eventdata, handles)
settle = str2double(get(hObject, 'String'));
if ~isnan(settle)
    handles.settle = settle;
end
guidata(hObject, handles);

function settle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numsteps_Callback(hObject, eventdata, handles)
numsteps = str2double(get(hObject, 'String'));
if ~isnan(numsteps)
    handles.numsteps = numsteps;
end
guidata(hObject, handles);

function numsteps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function magDes_Callback(hObject, eventdata, handles)
magDes1 = get(hObject, 'String');
magDes = str2double(magDes1);
w = findobj(gcf, 'Tag', 'magDes1');
set(w, 'String', magDes1);
if ~isnan(magDes)
    lcaPut(handles.currentmatch_mag, magDes)
end
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);

function magDes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function putVal_Callback(hObject, eventdata, handles)
lcaPut(handles.currentmatch_mag, handles.best)
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);

function logbutton_Callback(hObject, eventdata, handles) 
h = gcf;
set(gcf, 'InvertHardcopy', 'off')
util_printLog2(h, 'author', 'tunageddon')
data = {handles.data.x
        handles.data.y
        handles.data.PV
                        };
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

function startval_Callback(hObject, eventdata, handles)
startval = str2double(get(hObject, 'String'));
if ~isnan(startval)
    handles.startval = startval;
end
guidata(hObject, handles)

function startval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function endval_Callback(hObject, eventdata, handles)
endval = str2double(get(hObject, 'String'));
if ~isnan(endval)
    handles.endval = endval;
end
guidata(hObject, handles)

function endval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton3_Callback(hObject, eventdata, handles)
lcaPut(handles.currentmatch_mag, handles.value1)
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(gcf)
if ~usejava('desktop')
    exit
end

function edit10_Callback(hObject, eventdata, handles)
handles.currentmatch_mag = get(hObject, 'String');
z = aidalist(handles.currentmatch_mag);
if numel(z) == 1
currentmag = handles.currentmatch_mag;
a = findobj(gcf,'Tag','currentmag');
set(a,'String',currentmag);

value1 = lcaGet(handles.currentmatch_mag);
b = findobj(gcf,'Tag','value1');
set(b,'String',value1);
handles.best = value1;
handles.value1 = value1;

best = handles.best;
e = findobj(gcf,'Tag','best');
set(e, 'String',best);

value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
handles.currentmag = value1;

range = (handles.percent/100)*value1;
    if value1>0
        handles.startval = value1 - 0.5*range;
        handles.endval = value1 + 0.5*range;
    else
        handles.startval = value1 + 0.5*range;
        handles.endval = value1 - 0.5*range;
    end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject,handles)
guidata(hObject, handles)
elseif numel(z) >1
    disp('Multiple PVs available, options are:')
    disp(z)
else
    disp('Not a PV')
end

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


