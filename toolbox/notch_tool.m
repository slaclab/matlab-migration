function varargout = notch_tool(varargin)
% NOTCH_TOOL M-file for notch_tool.fig
%      NOTCH_TOOL, by itself, creates a new NOTCH_TOOL or raises the existing
%      singleton*.
%
%      H = NOTCH_TOOL returns the handle to a new NOTCH_TOOL or the handle to
%      the existing singleton*.
%
%      NOTCH_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOTCH_TOOL.M with the given input arguments.
%
%      NOTCH_TOOL('Property','Value',...) creates a new NOTCH_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before notch_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to notch_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help notch_tool

% Last Modified by GUIDE v2.5 29-Jun-2013 02:28:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @notch_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @notch_tool_OutputFcn, ...
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


% --- Executes just before notch_tool is made visible.
function notch_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to notch_tool (see VARARGIN)

global test;

if size(varargin,1) ~= 0
    test = varargin{1};
else
    test = [];
end

% Choose default command line output for notch_tool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Add Litrack path
addpath(genpath('/home/fphysics/sgess/ES'));

% Set initial plot options
set(handles.plot_syag,'Value',1);
set(handles.plot_tcav,'Value',1);
set(handles.plot_li_spec,'Value',0);
set(handles.plot_li_prof,'Value',0);
set(handles.fit_tcav,'Value',0);
set(handles.fit_litrack,'Value',0);
set(handles.plot_tcav_fit,'Value',0);
set(handles.plot_li_fit,'Value',0);
set(handles.use_machine,'Value',1);

% Set initial YAG and TCAV cals
set(handles.tcav_cal,'String','416');
init_disp = lcaGet('SIOC:SYS1:ML00:AO782');
set(handles.yag_disp,'String',num2str(1000*init_disp,'%0.2f'));

% Grab initial images
set(handles.select_tcav_otr,'Value',9);
select_tcav_otr_Callback(handles.select_tcav_otr, [], handles);
set(handles.get_syag,'Value',1);
set(handles.get_tcav_otr,'Value',1);
get_image_Callback(handles.get_image, [], handles);
%--------------------------------------------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = notch_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------

function select_tcav_otr_Callback(hObject, eventdata, handles)

global OTR_PV;

otr_val = get(hObject,'Value');
switch otr_val
    case 1
        OTR_PV = 'OTRS:LI20:3070';
    case 2
        OTR_PV = 'OTRS:LI20:3075';
    case 3
        OTR_PV = 'OTRS:LI20:3158';
    case 4
        OTR_PV = 'OTRS:LI20:3175';
    case 5
        OTR_PV = 'OTRS:LI20:3180';
    case 6
        OTR_PV = 'EXPT:LI20:3208';
    case 7
        OTR_PV = 'OTRS:LI20:3206';
    case 8
        OTR_PV = 'MIRR:LI20:3202';
    case 9
        %OTR_PV = 'MIRR:LI20:3230';
        %OTR_PV = 'PROF:LI20:B104';
        OTR_PV = 'PROF:LI20:3230';
end
%--------------------------------------------------------------------------

function get_image_Callback(hObject, eventdata, handles)

global OTR_PV;
global syag_img;
global tcav_img;
global test;
global charge;

charge = lcaGet('LI20:TORO:3255:DATA');
%syag_img = profmon_grab('YAGS:LI20:2432');
syag_img = profmon_grab('PROF:LI20:2432');
if isempty(test);
    tcav_img = profmon_grab(OTR_PV);
    charge = lcaGet('LI20:TORO:3255:DATA');
    %syag_img = profmon_grab('YAGS:LI20:2432');
    syag_img = profmon_grab('PROF:LI20:2432');
else
    load(test{1});
    tcav_img = data;
    load(test{2});
    syag_img = data;
    charge = 2E10;
end

if get(handles.get_syag,'Value') == 1; update_spectrum(handles); end;
if get(handles.get_tcav_otr,'Value') == 1; update_tcav(handles); end;
%--------------------------------------------------------------------------

function update_spectrum(handles)

global syag_img syag_box;
im_dat = syag_img;

% calculate image axis
[xx, yy] = CalculateAxes(im_dat);

% Plot image and lineout region
axes(handles.axes7);
cla;
hold on;
hs = image(xx,yy,im_dat.img,'CDataMapping','scaled');
set(hs,'HitTest','off');
axis(handles.axes7,'xy');
caxis([0 256]);
axis([xx(1) xx(end) yy(end) yy(1)]);
if ~isempty(syag_box)
    rectangle('Position',syag_box,'edgecolor','r','linewidth',2,'linestyle','--');
end
set(gca,'fontsize',8);
xlabel('x (mm)','fontsize',10);
ylabel('y (mm)','fontsize',10);
title('sYAG','fontsize',10);

% plot lineouts if selected
if ~isempty(syag_box)
    get_syag_lineout(handles);
    plot_spectra(handles);
end
%--------------------------------------------------------------------------

function update_tcav(handles)

global tcav_img tcav_box;
im_dat = tcav_img;

% calculate image axis
[xx, yy] = CalculateAxes(im_dat);

axes(handles.axes3);
cla;
hold on;
ht = image(xx,yy,im_dat.img,'CDataMapping','scaled');
set(ht,'HitTest','off');
caxis([0 512]);
axis([xx(1) xx(end) yy(end) yy(1)]);
if ~isempty(tcav_box)
    rectangle('Position',tcav_box,'edgecolor','r','linewidth',2,'linestyle','--');
end
set(gca,'fontsize',8);
xlabel('x (mm)','fontsize',10);
ylabel('y (mm)','fontsize',10);
name = get(handles.select_tcav_otr,'String');
otr_val = get(handles.select_tcav_otr,'Value');
title(name(otr_val),'fontsize',10);

% plot lineouts if selected
if ~isempty(tcav_box)
    get_tcav_lineout(handles);
    plot_profiles(handles); 
end
%--------------------------------------------------------------------------

function get_syag_lineout(handles)

global syag_img syag_box;
global spec_axis del_axis syag_spec syag_max;
im_dat = syag_img;

% calculate image axis
[xx, yy] = CalculateAxes(im_dat);

% get axes of boxed region
xInd = (xx > syag_box(1) & xx < syag_box(1)+syag_box(3));
yInd = (yy > syag_box(2) & yy < syag_box(2)+syag_box(4));
BoxX = xx(xInd);

% get Lineout of boxed region
Lineout = mean(im_dat.img(yInd,xInd),1);
Line_minBG = Lineout-Lineout(1);

% Get maximum and sum
[MaxLine,max_ind] = max(Line_minBG);

yag_disp = str2double(get(handles.yag_disp,'String'));
spec_cent = sum(BoxX.*Line_minBG)/sum(Line_minBG);

spec_axis = BoxX;
del_axis  = 100*(BoxX-spec_cent)/yag_disp;
syag_spec = Line_minBG;
syag_max  = MaxLine;
%--------------------------------------------------------------------------

function plot_spectra(handles)

global spec_axis syag_spec del_axis syag_max;
global Li_Spectrum Li_Profile;

ProfXLi = Li_Spectrum/max(Li_Spectrum);
spectrum_axis = del_axis;
spectrum = syag_spec/syag_max;

if isempty(spectrum_axis); return; end;
if isempty(syag_spec); set(handles.plot_syag,'Value',0); end;
if isempty(ProfXLi); set(handles.plot_li_spec,'Value',0); end;
if get(handles.plot_li_spec,'Value') == 1 && numel(ProfXLi) ~= numel(spectrum)
    txt1 = 'Cannot plot LiTrack spectrum';
    txt2 = 'Lineout region changed';
    gui_statusDisp(handles,{txt1;txt2});
    set(handles.plot_li_spec,'Value',0);
end

axes(handles.axes4);
if get(handles.plot_syag,'Value') == 1 && get(handles.plot_li_spec,'Value') == 1
    clear('l1');
    plot(ProfXLi,spectrum_axis,'g.',spectrum,spectrum_axis,'b.');
    l1 = legend('LiTrack','sYAG');
    set(l1,'box','off','fontsize',10);
    set(gca,'fontsize',8);
elseif get(handles.plot_syag,'Value') == 1 && get(handles.plot_li_spec,'Value') == 0
    clear('l1');
    plot(spectrum,spectrum_axis,'b.');
    l1 = legend('sYAG');
    set(l1,'box','off','fontsize',10);
    set(gca,'fontsize',8);
elseif get(handles.plot_syag,'Value') == 0 && get(handles.plot_li_spec,'Value') == 1
    clear('l1');
    plot(ProfXLi,spectrum_axis,'g.');
    l1 = legend('LiTrack');
    set(l1,'box','off','fontsize',10);
    set(gca,'fontsize',8);
else
    clear('l1');
    cla;
end

axis([0 1 spectrum_axis(1) spectrum_axis(end)]);

ylabel('\delta (%)','fontsize',10);
title('Bunch Spectra','fontsize',10);
%--------------------------------------------------------------------------

function get_tcav_lineout(handles)

global tcav_img tcav_box;
global tcav_axis zz_axis tcav_prof tcav_max;
im_dat = tcav_img;

% calculate image axis
[xx, yy] = CalculateAxes(im_dat);

% get axes of boxed region
xInd = (xx > tcav_box(1) & xx < tcav_box(1)+tcav_box(3));
yInd = (yy > tcav_box(2) & yy < tcav_box(2)+tcav_box(4));
BoxY = yy(yInd);

% get Lineout of boxed region
Lineout = mean(im_dat.img(yInd,xInd),2);
Line_minBG = Lineout-Lineout(1);

% Get maximum and sum
[MaxLine,max_ind] = max(Line_minBG);

tcav_cal = str2double(get(handles.tcav_cal,'String'));
degXband = 72.9; % um
prof_cent = sum((BoxY').*Line_minBG)/sum(Line_minBG);

tcav_axis = BoxY;
zz_axis  = flipud(1000*degXband*(BoxY-prof_cent)'/tcav_cal);
tcav_prof = flipud(Line_minBG);
tcav_max  = MaxLine;
%--------------------------------------------------------------------------

function plot_profiles(handles)

global tcav_axis zz_axis tcav_prof tcav_max;
global Li_Spectrum Li_Profile;
global tcav_fitobject tcav_bunchfit1 tcav_bunchfit2;
global li_fitobject li_bunchfit1 li_bunchfit2;

if isempty(zz_axis); return; end;
if isempty(tcav_prof); set(handles.plot_tcav,'Value',0); end;
if isempty(Li_Profile); set(handles.plot_li_prof,'Value',0); end; 
if get(handles.plot_li_prof,'Value') == 1 && numel(Li_Profile) ~= numel(tcav_prof)
    txt1 = 'Cannot plot LiTrack profile';
    txt2 = 'Lineout region changed';
    gui_statusDisp(handles,{txt1;txt2});
    set(handles.plot_li_prof,'Value',0);
end
if isempty(tcav_bunchfit1) || isempty(tcav_bunchfit2) 
    set(handles.plot_tcav_fit,'Value',0);
end
if get(handles.plot_tcav_fit,'Value') == 1 && (numel(tcav_bunchfit1) ~= numel(tcav_prof) || numel(tcav_bunchfit2) ~= numel(tcav_prof))
    txt1 = 'Cannot plot TCAV fit';
    txt2 = 'Lineout region changed';
    gui_statusDisp(handles,{txt1;txt2});
    set(handles.plot_tcav_fit,'Value',0);
end
if isempty(li_bunchfit1) || isempty(li_bunchfit2) 
    set(handles.plot_li_fit,'Value',0);
end
if get(handles.plot_li_fit,'Value') == 1 && (numel(li_bunchfit1) ~= numel(tcav_prof) || numel(li_bunchfit2) ~= numel(tcav_prof))
    txt1 = 'Cannot plot LiTrack fit';
    txt2 = 'Lineout region changed';
    gui_statusDisp(handles,{txt1;txt2});
    set(handles.plot_tcav_fit,'Value',0);
end


% assingment and normalization
dz = zz_axis(2) - zz_axis(1);
prof = tcav_prof/sum(dz*tcav_prof);
ProfZLi = Li_Profile/sum(dz*Li_Profile);
sumtc = sum(dz*(tcav_bunchfit1+tcav_bunchfit2));
tcfit1 = tcav_bunchfit1/sumtc;
tcfit2 = tcav_bunchfit2/sumtc;
sumli = sum(dz*(li_bunchfit1+li_bunchfit2));
lifit1 = li_bunchfit1/sumli;
lifit2 = li_bunchfit2/sumli;

axes(handles.axes2);
cla;
if get(handles.plot_tcav,'Value') == 1 && get(handles.plot_li_prof,'Value') == 1
    clear('l2');
    plot(zz_axis,ProfZLi,'g.',zz_axis,prof,'b.');
    l2 = legend('LiTrack','TCAV');
    set(l2,'box','off','fontsize',10);
    set(gca,'fontsize',8);
    h = get(gca,'children');
    


elseif get(handles.plot_tcav,'Value') == 1 && get(handles.plot_li_prof,'Value') == 0
    clear('l2');
    plot(zz_axis,prof,'b.');
    l2 = legend('TCAV');
    set(l2,'box','off','fontsize',10);
    set(gca,'fontsize',8);
    h = get(gca,'children');
    if get(handles.plot_tcav_fit,'Value') == 1
        clear('l2');
        hold on;
        plot(zz_axis,tcfit1,'r--',zz_axis,tcfit2,'r--','linewidth',2);
        hold off;
        l2 = legend('TCAV','TCAV Fits');
        set(l2,'box','off','fontsize',10);
        set(gca,'fontsize',8);
        h = get(gca,'children');
    end



elseif get(handles.plot_tcav,'Value') == 0 && get(handles.plot_li_prof,'Value') == 1
    plot(zz_axis,ProfZLi,'g.');
    l2 = legend('LiTrack');
    set(l2,'box','off','fontsize',10);
    set(gca,'fontsize',8);
    h = get(gca,'children');
    if get(handles.plot_li_fit,'Value') == 1
        hold on;
        plot(zz_axis,lifit1,'k--',zz_axis,lifit2,'k--','linewidth',2);
        hold off;
        l2 = legend('LiTrack','LiTrack Fits');
        set(l2,'box','off','fontsize',10);
        set(gca,'fontsize',8);
        h = get(gca,'children');
    end



else
    cla;
end
if exist('h','var')
    minx = inf;
    maxx = -inf;
    maxy = -inf;
    for i=1:numel(h)
        xdat = get(h(i),'XData');
        ydat = get(h(i),'YData');
        if max(xdat) > maxx; maxx = max(xdat); end
        if min(xdat) < minx; minx = min(xdat); end
        if max(ydat) > maxy; maxy = max(ydat); end
    end
    axis([minx maxx 0 maxy]);
end
xlabel('Z (um)','fontsize',10);
title('Beam Profile','fontsize',10);
%--------------------------------------------------------------------------

function fit_peaks(handles)

global tcav_axis zz_axis tcav_prof tcav_max;
global Li_Spectrum Li_Profile Li_Charge;
global tcav_fitobject tcav_bunchfit1 tcav_bunchfit2;
global li_fitobject li_bunchfit1 li_bunchfit2;
global charge;

tccharge = charge/1E10;
licharge = Li_Charge/1E10;

if isempty(zz_axis); return; end;
if isempty(tcav_prof); set(handles.fit_tcav,'Value',0); end;
if isempty(Li_Profile); set(handles.fit_litrack,'Value',0); end;
if get(handles.fit_litrack,'Value') == 1 && numel(Li_Profile) ~= numel(tcav_prof)
    txt1 = 'Cannot fit LiTrack Profile';
    txt2 = 'Lineout region changed';
    gui_statusDisp(handles,{txt1;txt2});
    set(handles.fit_litrack,'Value',0); 
end

prof = tcav_prof;
zz = zz_axis;
zz_cen = mean(zz);
zz_win = zz(end) - zz(1);
dz = zz(2) - zz(1);
zz_area = sum(dz*prof);

ProfZLi = Li_Profile;
zzLi = zz_axis;
zzLi_cen = zz_cen;
zzLi_win = zz_win;
zzLi_area = sum(dz*ProfZLi);

if get(handles.fit_tcav,'Value') == 1

    % fit simulate bunch profile
    tcav_fitobject = peakfit([zz prof],zz_cen,zz_win,2,1,0,0,0,0,0,0);
    tcav_bunchfit1 = tcav_fitobject(1,3)*exp(-((zz-tcav_fitobject(1,2))/(tcav_fitobject(1,4)/2.354)).^2/2);
    tcav_bunchfit2 = tcav_fitobject(2,3)*exp(-((zz-tcav_fitobject(2,2))/(tcav_fitobject(2,4)/2.354)).^2/2);

    set(handles.dbrms,'string',num2str(tcav_fitobject(1,4)/2.354,'%0.2f'));
    set(handles.dbc,'string',num2str(tccharge*tcav_fitobject(1,5)/zz_area,'%0.2f'));
    set(handles.wbrms,'string',num2str(tcav_fitobject(2,4)/2.354,'%0.2f'));
    set(handles.wbc,'string',num2str(tccharge*tcav_fitobject(2,5)/zz_area,'%0.2f'));
    set(handles.bs,'string',num2str(tcav_fitobject(2,2)-tcav_fitobject(1,2),'%0.2f'));
    
end

if get(handles.fit_litrack,'Value') == 1

    % fit simulate bunch profile
    li_fitobject = peakfit([zzLi ProfZLi],zzLi_cen,zzLi_win,2,1,0,0,0,0,0,0);
    li_bunchfit1 = li_fitobject(1,3)*exp(-((zzLi-li_fitobject(1,2))/(li_fitobject(1,4)/2.354)).^2/2);
    li_bunchfit2 = li_fitobject(2,3)*exp(-((zzLi-li_fitobject(2,2))/(li_fitobject(2,4)/2.354)).^2/2);

    set(handles.lidbrms,'string',num2str(li_fitobject(1,4)/2.354,'%0.2f'));
    set(handles.lidbc,'string',num2str(licharge*li_fitobject(1,5)/zzLi_area,'%0.2f'));
    set(handles.liwbrms,'string',num2str(li_fitobject(2,4)/2.354,'%0.2f'));
    set(handles.liwbc,'string',num2str(licharge*li_fitobject(2,5)/zzLi_area,'%0.2f'));
    set(handles.libs,'string',num2str((li_fitobject(2,2)-li_fitobject(1,2)),'%0.2f'));
    
end
%--------------------------------------------------------------------------

% --- Executes on button press in simulate_mach.
function simulate_mach_Callback(hObject, eventdata, handles)
% hObject    handle to simulate_mach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global tcav_axis zz_axis tcav_prof tcav_max;
global spec_axis del_axis syag_spec syag_max;
global Li_Spectrum Li_Profile Li_Charge;

if isempty(zz_axis) || isempty(del_axis); return; end;

% get info
% yag_disp = str2double(get(handles.yag_disp,'String'));
% phase_ramp = str2double(get(handles.phase_ramp,'String'));
% nrtl_fact = str2double(get(handles.nrtl_fact,'String'));
% jaw_low = str2double(get(handles.jaw_low,'String'));
% jaw_high = str2double(get(handles.jaw_high,'String'));
% notch_low = str2double(get(handles.notch_low,'String'));
% notch_high = str2double(get(handles.notch_high,'String'));


nOut = 3;

global A;
A = load('slac.dat');

global PARAM;
param_06_27_13;

if get(handles.use_machine,'Value') == 1
    PARAM = get_mach_param(PARAM,handles,'machine');
else
    PARAM = get_mach_param(PARAM,handles,'LiES');
end

% Simulate
OUT = LiTrackOpt('FACETconNOTCH');

Li_Charge = OUT.I.PART(nOut)/PARAM.INIT.NESIM*PARAM.INIT.NPART;

% Get simulated spectrum
%SimDisp = interpSimX(OUT,spectrum_axis,PARAM.SIMU.BIN,spectrum_center-spectrum_xavg);
%MaxX = max(SimDisp);
%ProfXLi = SimDisp/MaxX;
ee = OUT.E.AXIS(:,nOut);
dE = ee(2) - ee(1);
eeLi = [ee(1)-dE; ee; ee(end)+dE];
ProfELi = [0; OUT.E.HIST(:,nOut); 0];
eeLi_cen = sum(eeLi.*ProfELi)/sum(ProfELi);
Li_Spectrum = interp1(eeLi-eeLi_cen,ProfELi,del_axis,'linear',0);


% Get simulated bunch profile
zz = 1000*OUT.Z.AXIS(:,nOut);
dZ = zz(2) - zz(1);
zzLi = [zz(1)-dZ; zz; zz(end)+dZ];
ProfZLi = [0; OUT.Z.HIST(:,nOut); 0];
zzLi_cen = sum(zzLi.*ProfZLi)/sum(ProfZLi);
Li_Profile = interp1(zzLi-zzLi_cen,ProfZLi,zz_axis,'linear',0);

% Get simulated z-d space
zd_space = util_hist2(1e6*OUT.Z.DIST(1:OUT.I.PART(nOut),nOut)-zzLi_cen, 100*OUT.E.DIST(1:OUT.I.PART(nOut),nOut), zz_axis, del_axis);

% Display Phase Space
axes(handles.axes1);
image(zz_axis,del_axis,zd_space,'CDataMapping','scaled');
xlabel('Z (\mum)','fontsize',10);
ylabel('\delta (%)','fontsize',10);
title('Z-\delta Phase Space','fontsize',10);
set(handles.axes1,'YDir','normal');
set(gca,'fontsize',8);

fit_peaks(handles);
plot_spectra(handles);
plot_profiles(handles);
%--------------------------------------------------------------------------

% --- Executes on button press in plot_syag.
function plot_syag_Callback(hObject, eventdata, handles)
% hObject    handle to plot_syag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_syag
%plot_spectra(handles);
%--------------------------------------------------------------------------

% --- Executes on button press in plot_tcav.
function plot_tcav_Callback(hObject, eventdata, handles)
% hObject    handle to plot_tcav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_tcav

%--------------------------------------------------------------------------

% --- Executes on button press in plot_li_spec.
function plot_li_spec_Callback(hObject, eventdata, handles)
% hObject    handle to plot_li_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_li_spec
%plot_spectra(handles);

%--------------------------------------------------------------------------

% --- Executes on button press in plot_li_prof.
function plot_li_prof_Callback(hObject, eventdata, handles)
% hObject    handle to plot_li_prof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_li_prof

%--------------------------------------------------------------------------

% --- Executes on button press in fit_tcav.
function fit_tcav_Callback(hObject, eventdata, handles)
% hObject    handle to fit_tcav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fit_tcav

%--------------------------------------------------------------------------

% --- Executes on button press in fit_litrack.
function fit_litrack_Callback(hObject, eventdata, handles)
% hObject    handle to fit_litrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fit_litrack

%--------------------------------------------------------------------------

% --- Executes on button press in plot_tcav_fit.
function plot_tcav_fit_Callback(hObject, eventdata, handles)
% hObject    handle to plot_tcav_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_tcav_fit
%plot_profiles(handles);

%--------------------------------------------------------------------------

% --- Executes on button press in plot_li_fit.
function plot_li_fit_Callback(hObject, eventdata, handles)
% hObject    handle to plot_li_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_li_fit
%plot_profiles(handles);

%--------------------------------------------------------------------------

function tcav_cal_Callback(hObject, eventdata, handles)
% hObject    handle to tcav_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tcav_cal as text
%        str2double(get(hObject,'String')) returns contents of tcav_cal as a double

%--------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function tcav_cal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tcav_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------

% --- Executes on mouse press over axes background.
function axes7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global syag_box;

if get(handles.select_syag_box,'Value') == 0
    return
else
    point1 = get(gca,'CurrentPoint');
    finalRect = rbbox;
    point2 = get(gca,'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    p1 = min(point1,point2);
    p2 = max(point1,point2);
    syag_box = [p1(1),p1(2),p2(1)-p1(1),p2(2)-p1(2)];
    hold on;
    rectangle('Position',syag_box,'edgecolor','r','linewidth',2,'linestyle','--');
    hold off;
    set(handles.select_syag_box,'Value',0);
    get_syag_lineout(handles);
    plot_spectra(handles);
end
%--------------------------------------------------------------------------

% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tcav_box;

if get(handles.select_tcav_box,'Value') == 0
    return
else
    point1 = get(gca,'CurrentPoint');
    finalRect = rbbox;
    point2 = get(gca,'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    p1 = min(point1,point2);
    p2 = max(point1,point2);
    tcav_box = [p1(1),p1(2),p2(1)-p1(1),p2(2)-p1(2)];
    hold on;
    rectangle('Position',tcav_box,'edgecolor','r','linewidth',2,'linestyle','--');
    hold off;
    set(handles.select_tcav_box,'Value',0);
    get_tcav_lineout(handles);
    fit_peaks(handles);
    plot_profiles(handles);
end
%--------------------------------------------------------------------------

% --- Executes on button press in select_syag_box.
function select_syag_box_Callback(hObject, eventdata, handles)
% hObject    handle to select_syag_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_syag_box
global syag_box;
syag_box = [];
set(handles.plot_syag,'Value',1);
set(handles.plot_li_spec,'Value',0);
update_spectrum(handles);
%--------------------------------------------------------------------------

% --- Executes on button press in select_tcav_box.
function select_tcav_box_Callback(hObject, eventdata, handles)
% hObject    handle to select_tcav_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_tcav_box
global tcav_box;
tcav_box = [];
set(handles.plot_tcav,'Value',1);
set(handles.plot_li_prof,'Value',0);
set(handles.plot_li_fit,'Value',0);
set(handles.fit_litrack,'Value',0);
update_tcav(handles);
%--------------------------------------------------------------------------

% --- Executes on button press in get_syag.
function get_syag_Callback(hObject, eventdata, handles)
% hObject    handle to get_syag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of get_syag
%--------------------------------------------------------------------------


% --- Executes on button press in get_tcav_otr.
function get_tcav_otr_Callback(hObject, eventdata, handles)
% hObject    handle to get_tcav_otr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of get_tcav_otr
%--------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function select_tcav_otr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_tcav_otr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------



function yag_disp_Callback(hObject, eventdata, handles)
% hObject    handle to yag_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yag_disp as text
%        str2double(get(hObject,'String')) returns contents of yag_disp as a double


% --- Executes during object creation, after setting all properties.
function yag_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yag_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prof_toLog.
function prof_toLog_Callback(hObject, eventdata, handles)
% hObject    handle to prof_toLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

marker_list = {'r--','r--','b.'};
if ~get(handles.plot_tcav_fit,'Value')
    marker_list = {'b.'};
end
axes(handles.axes2);
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
chld_plz=get(gca,'children');
xx = get(chld_plz(1),'XData');
h1 = figure;
hold on;
for i=1:numel(chld_plz)
    plot(xx,get(chld_plz(i),'YData'),marker_list{i},'linewidth',2);
end
axis([xlim ylim]);
set(gca,'fontsize',8);
xlabel('Z (um)','fontsize',9);
if get(handles.plot_tcav_fit,'Value')
    dbrms = get(handles.dbrms,'string');
    dbc = get(handles.dbc,'string');
    wbrms = get(handles.wbrms,'string');
    wbc = get(handles.wbc,'string');
    bs = get(handles.bs,'string');
    tit = ['\sigma_{db}: ' dbrms '\mum, N_{DB}: ' dbc 'E10, \sigma_{WB}: ' wbrms '\mum, N_{WB}: ' wbc 'E10, Sep. ' bs '\mum'];
    title(tit,'fontsize',10,'fontweight','bold');
end
util_printLog(1);
%[filename, pathname] = util_dataSave(handles.data, 'notch_tool', handles.data.knob, handles.data.ts);
%gui_statusDisp(handles, sprintf('Data saved to %s/%s', pathname, filename));

    


% --- Executes on button press in update_plots.
function update_plots_Callback(hObject, eventdata, handles)
% hObject    handle to update_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fit_peaks(handles);
plot_spectra(handles);
plot_profiles(handles);



function phase_ramp_Callback(hObject, eventdata, handles)
% hObject    handle to phase_ramp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phase_ramp as text
%        str2double(get(hObject,'String')) returns contents of phase_ramp as a double


% --- Executes during object creation, after setting all properties.
function phase_ramp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase_ramp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nrtl_fact_Callback(hObject, eventdata, handles)
% hObject    handle to nrtl_fact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nrtl_fact as text
%        str2double(get(hObject,'String')) returns contents of nrtl_fact as a double


% --- Executes during object creation, after setting all properties.
function nrtl_fact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nrtl_fact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jaw_low_Callback(hObject, eventdata, handles)
% hObject    handle to jaw_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jaw_low as text
%        str2double(get(hObject,'String')) returns contents of jaw_low as a double


% --- Executes during object creation, after setting all properties.
function jaw_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jaw_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jaw_high_Callback(hObject, eventdata, handles)
% hObject    handle to jaw_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jaw_high as text
%        str2double(get(hObject,'String')) returns contents of jaw_high as a double


% --- Executes during object creation, after setting all properties.
function jaw_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jaw_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notch_low_Callback(hObject, eventdata, handles)
% hObject    handle to notch_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notch_low as text
%        str2double(get(hObject,'String')) returns contents of notch_low as a double


% --- Executes during object creation, after setting all properties.
function notch_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notch_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notch_high_Callback(hObject, eventdata, handles)
% hObject    handle to notch_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notch_high as text
%        str2double(get(hObject,'String')) returns contents of notch_high as a double


% --- Executes during object creation, after setting all properties.
function notch_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notch_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_machine.
function use_machine_Callback(hObject, eventdata, handles)
% hObject    handle to use_machine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_machine

set(handles.phase_ramp,'Enable','on');
set(handles.nrtl_fact,'Enable','on');
set(handles.jaw_low,'Enable','on');
set(handles.jaw_high,'Enable','on');
set(handles.notch_low,'Enable','on');
set(handles.notch_high,'Enable','on');


% --- Executes on button press in use_es.
function use_es_Callback(hObject, eventdata, handles)
% hObject    handle to use_es (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_es

set(handles.phase_ramp,'Enable','off');
set(handles.nrtl_fact,'Enable','off');
set(handles.jaw_low,'Enable','off');
set(handles.jaw_high,'Enable','off');
set(handles.notch_low,'Enable','off');
set(handles.notch_high,'Enable','off');
