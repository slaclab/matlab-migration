function varargout = myIPMgui(varargin)
% MYIPMGUI MATLAB code for myIPMgui.fig
%      MYIPMGUI, by itself, creates a new MYIPMGUI or raises the existing
%      singleton*.
%
%      H = MYIPMGUI returns the handle to a new MYIPMGUI or the handle to
%      the existing singleton*.
%
%      MYIPMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYIPMGUI.M with the given input arguments.
%
%      MYIPMGUI('Property','Value',...) creates a new MYIPMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before myIPMgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to myIPMgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help myIPMgui

% Last Modified by GUIDE v2.5 14-May-2015 13:09:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @myIPMgui_OpeningFcn, ...
                   'gui_OutputFcn',  @myIPMgui_OutputFcn, ...
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


% --- Executes just before myIPMgui is made visible.
function myIPMgui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.intensityPV = {'GDET:FEE1:241:ENRC'};
handles.intensityPVs = {
    'GDET:FEE1:241:ENRC'
    'HFX:DG1:IPM:01:SUM'
    'HFX:DG2:IPM:01:SUM'
    'HFX:DG3:IPM:01:SUM'
    'HX2:SB1:IPM:01:SUM'
    'MEC:HXM:IPM:01:SUM'
    'MEC:HXM:PIM:01:SUM'
    'MEC:TC1:IMB:01:CH0'
    'MEC:TC1:IMB:01:CH1'
    'MEC:TC1:IMB:01:CH2'
    'MEC:TC1:IMB:01:CH3'
    'MEC:TC1:IMB:01:SUM'
    'MEC:USR:IMB:01:SUM'
    'MEC:USR:IMB:02:SUM'
    'MEC:XT2:IPM:02:SUM'
    'MEC:XT2:IPM:03:SUM'
    'MEC:XT2:PIM:02:SUM'
    'MEC:XT2:PIM:03:SUM'
    'SXR:GMD:BLD:AvgPulseIntensity'
    'SXR:GMD:BLD:CumSumAllPeaks'
    'SXR:GMD:BLD:milliJoulesPerPulse'
    'XCS:DG1:IMB:01:SUM'
    'XCS:DG1:IMB:02:SUM'
    'XCS:DG3:IMB:03:SUM'
    'XCS:USR:IMB:01:CH0'
    'XPP:MON:IPM:01:SUM'
    'XPP:MON:IPM:02:SUM'
    'XPP:SB2:IPM:01:SUM'
    'XPP:SB3:IPM:01:SUM'
    'XPP:SB4:IPM:01:SUM'
    'XPP:USR:IPM:01:SUM'
    'XPP:USR:IPM:02:SUM'};
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = myIPMgui_OutputFcn(hObject, eventdata, handles) 
%varargout{1} = handles.output;

function  setTag(string,tag)
%string and tag in single quotes
r = findobj(gcf,'Tag',tag);
set(r,'String', string);

% --- Executes on button press in startstop.
function startstop_Callback(hObject, eventdata, handles)
handles.startstop = get(hObject,'Value');
if handles.startstop == 0; return, end
set(hObject, 'string', 'Stop', 'BackgroundColor', [1 0 0]);
% intensityPvs = {
%     'GDET:FEE1:241:ENRC'
%     'HFX:DG1:IPM:01:SUM'
%     'HFX:DG2:IPM:01:SUM'
%     'HFX:DG3:IPM:01:SUM'
%     'HX2:SB1:IPM:01:SUM'
%     'MEC:HXM:IPM:01:SUM'
%     'MEC:HXM:PIM:01:SUM'
%     'MEC:TC1:IMB:01:CH0'
%     'MEC:TC1:IMB:01:CH1'
%     'MEC:TC1:IMB:01:CH2'
%     'MEC:TC1:IMB:01:CH3'
%     'MEC:TC1:IMB:01:SUM'
%     'MEC:USR:IMB:01:SUM'
%     'MEC:USR:IMB:02:SUM'
%     'MEC:XT2:IPM:02:SUM'
%     'MEC:XT2:IPM:03:SUM'
%     'MEC:XT2:PIM:02:SUM'
%     'MEC:XT2:PIM:03:SUM'
%     'SXR:GMD:BLD:AvgPulseIntensity'
%     'SXR:GMD:BLD:CumSumAllPeaks'
%     'SXR:GMD:BLD:milliJoulesPerPulse'
%     'XCS:DG1:IMB:01:SUM'
%     'XCS:DG1:IMB:02:SUM'
%     'XCS:DG3:IMB:03:SUM'
%     'XPP:MON:IPM:01:SUM'
%     'XPP:MON:IPM:02:SUM'
%     'XPP:SB2:IPM:01:SUM'
%     'XPP:SB3:IPM:01:SUM'
%     'XPP:SB4:IPM:01:SUM'
%     'XPP:USR:IPM:01:SUM'
%     'XPP:USR:IPM:02:SUM'};
% 
% [selection ok] = listdlg('ListString', intensityPvs,'SelectionMode', 'Single');

%if ~ok, return, end
usePV = handles.intensityPV;
engPV = {'BLD:SYS0:500:PHOTONENERGY'};
bufflen = 1800;
pulseIntensity = nan(1,bufflen);
energy = nan(1,bufflen);


while 1
tmit = lcaGet('BPMS:UND1:2290:TMIT1H');
while tmit <5e7
    pause(3)
    tmit = lcaGet('BPMS:UND1:2290:TMIT1H');
end
handles.startstop = get(hObject,'Value');
if handles.startstop == 0, break, end
for ii = 1:120
    [v(ii,:) t1(ii,:)] = lcaGetSmart([engPV;usePV]);
    t = lcaTs2PulseId(t1);
    pause(0.005)
    
end
[C, ia, ib] = intersect(t(:,1), t(:,2));
N = length(C);

energy =  circshift(energy,[1 -N]);
pulseIntensity = circshift(pulseIntensity,[1 -N]);

energy(end-N+1:end) = v(ia,1);
pulseIntensity(end-N+1:end) = v(ia,2);

filt = ~isnan(energy);
filt(filt) = filt(filt) & (abs(energy(filt)-median(energy(filt))) < 4 *std(energy(filt)));

plot(handles.axes1,energy(filt),pulseIntensity(filt),'x')
%xlabel(handles.axes1,engPV{:});
ylabel(handles.axes1,usePV{:})
xl = xlim(handles.axes1);
yl = ylim(handles.axes1);

cla(handles.axes2)
[x,y] = hist(pulseIntensity(filt),round(sqrt(bufflen)));
%bar(handles.axes2,y)
plot(handles.axes2,x,y,'-')
%ylabel(handles.axes2,usePV{:});
ylim(handles.axes2,yl);
xlim(handles.axes2,[0 1.1]*max(x));
intenseMean = mean(pulseIntensity(filt));
intensePeak = max(pulseIntensity(filt));
hold(handles.axes2,'on')
plot(handles.axes2,xlim(handles.axes2),[1 1]*intenseMean,'-.r');
hold(handles.axes2,'off');
hold(handles.axes1,'on')
plot(handles.axes1,xl,[1 1]*intenseMean,'-.r');
hold(handles.axes1,'off');
%title(handles.axes2,['Mean = ' num2str(m,3)]);

cla(handles.axes3)
hold(handles.axes3, 'on')
xlabel(handles.axes3,engPV{:});
xlim(handles.axes3,xl);
ylim(handles.axes3,[-0.2 1.1]*max(x));
m = mean(energy(filt));
plot(handles.axes3,[1 1]*m,ylim(handles.axes3),'-.r');
%hold(handles.axes3,'off');
hold(handles.axes1,'on')
plot(handles.axes1,[1 1]*m,yl,'-.r');
hold(handles.axes1,'off');
ylabel(handles.axes3,['Mean = ' num2str(m,3)]);
[counts,barnum]=hist(energy(filt),round(sqrt(bufflen)));
[yfit,p,dp,chisq]=gauss_fit(barnum, counts);
%yyf = p(1)*ones(size(barnum)) + p(2)*sqrt(2*pi)*p(4)*gauss(barnum,p(3),p(4)); 
bar(handles.axes3, barnum,counts); 
plot(handles.axes3,barnum,yfit,'-.g');
hold(handles.axes3, 'off')
setTag(intenseMean, 'meanI')
lcaPut('SIOC:SYS0:ML03:AO501', intenseMean)
setTag(intensePeak, 'peakI')
lcaPut('SIOC:SYS0:ML03:AO502', intensePeak)
setTag(m, 'meanE')
lcaPut('SIOC:SYS0:ML03:AO503', m)
setTag(p(4), 'gaussSig')
lcaPut('SIOC:SYS0:ML03:AO504', p(4))
end
set(hObject, 'Enable', 'on', 'String', 'Start', 'BackgroundColor', [0 1 0], 'Value', 0);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(gcf)
if ~usejava('desktop')
    exit
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
str = get(hObject, 'String');
switch str{val}
    case 'GDET:FEE1:241:ENRC'
        handles.intensityPV = handles.intensityPVs(1);
    case 'HFX:DG1:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(2);
    case 'HFX:DG2:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(3);
    case 'HFX:DG3:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(4);
    case 'HX2:SB1:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(5);
    case 'MEC:HXM:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(6);
    case 'MEC:HXM:PIM:01:SUM'
        handles.intensityPV = handles.intensityPVs(7);
    case 'MEC:TC1:IMB:01:CH0'
        handles.intensityPV = handles.intensityPVs(8);
    case 'MEC:TC1:IMB:01:CH1'
        handles.intensityPV = handles.intensityPVs(9);
    case 'MEC:TC1:IMB:01:CH2'
        handles.intensityPV = handles.intensityPVs(10);
    case 'MEC:TC1:IMB:01:CH3'
        handles.intensityPV = handles.intensityPVs(11);
    case 'MEC:TC1:IMB:01:SUM'
        handles.intensityPV = handles.intensityPVs(12);
    case 'MEC:USR:IMB:01:SUM'
        handles.intensityPV = handles.intensityPVs(13);
    case 'MEC:USR:IMB:02:SUM'
        handles.intensityPV = handles.intensityPVs(14);
    case 'MEC:XT2:IPM:02:SUM'
        handles.intensityPV = handles.intensityPVs(15);
    case 'MEC:XT2:IPM:03:SUM'
        handles.intensityPV = handles.intensityPVs(16);
    case 'MEC:XT2:PIM:02:SUM'
        handles.intensityPV = handles.intensityPVs(17);
    case 'MEC:XT2:PIM:03:SUM'
        handles.intensityPV = handles.intensityPVs(18);
    case 'SXR:GMD:BLD:AvgPulseIntensity'
        handles.intensityPV = handles.intensityPVs(19);
    case 'SXR:GMD:BLD:CumSumAllPeaks'
        handles.intensityPV = handles.intensityPVs(20);
    case 'SXR:GMD:BLD:milliJoulesPerPulse'
        handles.intensityPV = handles.intensityPVs(21);
    case 'XCS:DG1:IMB:01:SUM'
        handles.intensityPV = handles.intensityPVs(22);
    case 'XCS:DG1:IMB:02:SUM'
        handles.intensityPV = handles.intensityPVs(23);
    case 'XCS:DG3:IMB:03:SUM'
        handles.intensityPV = handles.intensityPVs(24);
    case 'XCS:USR:IMB:01:CH0'
        handles.intensityPV = handles.intensityPVs(25);
    case 'XPP:MON:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(26);
    case 'XPP:MON:IPM:02:SUM'
        handles.intensityPV = handles.intensityPVs(27);
    case 'XPP:SB2:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(28);
    case 'XPP:SB3:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(29);
    case 'XPP:SB4:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(30);
    case 'XPP:USR:IPM:01:SUM'
        handles.intensityPV = handles.intensityPVs(31);
    case 'XPP:USR:IPM:02:SUM'
        handles.intensityPV = handles.intensityPVs(32);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function logbutton_Callback(hObject, eventdata, handles) 
h = gcf;
set(gcf, 'InvertHardcopy', 'off')
util_printLog(h, 'author', 'tunageddon')

