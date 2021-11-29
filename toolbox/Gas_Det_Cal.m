function varargout = Gas_Det_Cal(varargin)
% GAS_DET_CAL M-file for Gas_Det_Cal.fig
%      GAS_DET_CAL, by itself, creates a new GAS_DET_CAL or
%      raises the existing
%      singleton*.
%
%      H = GAS_DET_CAL returns the handle to a new GAS_DET_CAL or the handle to
%      the existing singleton*.
%
%      GAS_DET_CAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAS_DET_CAL.M with the given input arguments.
%
%      GAS_DET_CAL('Property','Value',...) creates a new GAS_DET_CAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Gas_Det_Cal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Gas_Det_Cal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Gas_Det_Cal

% Last Modified by GUIDE v2.5 26-Jul-2009 15:33:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gas_Det_Cal_OpeningFcn, ...
                   'gui_OutputFcn',  @Gas_Det_Cal_OutputFcn, ...
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



% --- Executes just before Gas_Det_Cal is made visible.
function Gas_Det_Cal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Gas_Det_Cal (see VARARGIN)

handles.fakedata   = 0;     % if ==1, uses fake data
handles.nosettings = 0;     % if ==1, does NOT change any machine settings
handles.navg   = str2double(get(handles.NAVG,'String'));
handles.Be_min = str2double(get(handles.BE_MIN,'String'));
handles.Be_max = str2double(get(handles.BE_MAX,'String'));
handles.minfit = str2double(get(handles.MINFIT,'String'));
handles.maxfit = str2double(get(handles.MAXFIT,'String'));
handles.miny   = str2double(get(handles.MINY,'String'));
handles.maxy   = str2double(get(handles.MAXY,'String'));
steps = str2double(get(handles.BE_STEPSIZE,'String'));
handles.Be_stepsize = steps(get(handles.BE_STEPSIZE,'Value'));
if ~handles.nosettings
  handles.delay = 5;      % pause to let Be move full IN or OUT (sec)
else
  handles.delay = 0.5;    % short testing pause (sec)
end
set(handles.printLog_btn1,'Enable','off')
set(handles.EXPORT,'Enable','off')
handles.have_data = 0;

handles.assoc_data_pvs = {
                    'HVCH:FEE1:241:VoltageMeasure'
                    'HVCH:FEE1:242:VoltageMeasure'
                    'HVCH:FEE1:361:VoltageMeasure'
                    'HVCH:FEE1:362:VoltageMeasure'
                    'SMPS:FEE1:201:I'
                    'SMPS:FEE1:202:I'
                    'VGBA:FEE1:240:P'
                    'VGBA:FEE1:360:P'
                    'PHYS:SYS0:1:ELOSSENERGY'
                    'BEND:DMP1:400:BDES'
                    'STEP:FEE1:151:MOTR.RBV'
                    'STEP:FEE1:152:MOTR.RBV'
                    'STEP:FEE1:153:MOTR.RBV'
                    'STEP:FEE1:154:MOTR.RBV'
                                                };  % associated data (machine conditions)

handles.calib_pvs = {
                    'GDET:FEE1:241:OFFS'
                    'GDET:FEE1:241:CALI'
                    'GDET:FEE1:242:OFFS'
                    'GDET:FEE1:242:CALI'
                    'GDET:FEE1:361:OFFS'
                    'GDET:FEE1:361:CALI'
                    'GDET:FEE1:362:OFFS'
                    'GDET:FEE1:362:CALI'
                                        };  % slopes and offsets for gas det. calibrations

handles.dev_pvs = { 'GDET:FEE1:241:ENRC'
                    'GDET:FEE1:242:ENRC'
                    'GDET:FEE1:361:ENRC'
                    'GDET:FEE1:362:ENRC'
                    'DIAG:FEE1:481:RoiAttnPulseE'
                    'DIAG:FEE1:482:RoiAttnPulseE'
                    'DIAG:FEE1:481:RoiSumGrays'
                    'DIAG:FEE1:482:RoiSumGrays'
                    'DIAG:FEE1:481:RoiMax'
                    'DIAG:FEE1:482:RoiMax'
                    'DIAG:FEE1:481:RoiMin'
                    'DIAG:FEE1:482:RoiMin'
                    'TEM:FEE1:018:ENRC'
                    'TEM:FEE1:032:ENRC'
                    'TEM:FEE1:020:ENRC'
                    'TEM:FEE1:022:ENRC'
                    'KMON:FEE1:421:ENRC'
                    'KMON:FEE1:422:ENRC'
                    'KMON:FEE1:423:ENRC'
                    'KMON:FEE1:424:ENRC'
                                            };  % various FEl power readback device PVs

set(handles.DEVS,'String',handles.dev_pvs)  % load list of readable PVs (above)
set(handles.DEVS,'Value',3)                 % default to GD #2, PMT #1
handles.nd = get(handles.DEVS,'Value');

handles.Be_thickness_PVs = {
                    'SATT:FEE1:320:_SUM_1_4.E'
                    'SATT:FEE1:320:_SUM_1_4.F'
                    'SATT:FEE1:320:_SUM_1_4.G'
                    'SATT:FEE1:320:_SUM_1_4.H'
                    'SATT:FEE1:320:_SUM_5_9.E'
                    'SATT:FEE1:320:_SUM_5_9.F'
                    'SATT:FEE1:320:_SUM_5_9.G'
                    'SATT:FEE1:320:_SUM_5_9.H'
                    'SATT:FEE1:320:_SUM_5_9.J'};
                  
handles.Be_cmd_pvs = {
                    'SATT:FEE1:321:CMD'
                    'SATT:FEE1:322:CMD'
                    'SATT:FEE1:323:CMD'
                    'SATT:FEE1:324:CMD'
                    'SATT:FEE1:325:CMD'
                    'SATT:FEE1:326:CMD'
                    'SATT:FEE1:327:CMD'
                    'SATT:FEE1:328:CMD'
                    'SATT:FEE1:329:CMD'};

handles.Be_read_pvs = {
                    'SATT:FEE1:321:STATE'
                    'SATT:FEE1:322:STATE'
                    'SATT:FEE1:323:STATE'
                    'SATT:FEE1:324:STATE'
                    'SATT:FEE1:325:STATE'
                    'SATT:FEE1:326:STATE'
                    'SATT:FEE1:327:STATE'
                    'SATT:FEE1:328:STATE'
                    'SATT:FEE1:329:STATE'};

handles.Be_total = 'SATT:FEE1:320:TACT';

handles.Be_thickness = lcaGetSmart(handles.Be_thickness_PVs)*25.4E-3; % each Be attenuator thickness, in mm

handles.Be_matrix = flipud(...
                    [32.0  0 0 1 1 1 1 1 1 1
                     31.5  0 0 0 1 1 1 1 1 1
                     31.0  0 0 0 0 1 1 1 1 1
                     30.5  0 0 0 1 0 1 1 1 1
                     30.0  0 0 0 0 0 1 1 1 1
                     29.5  0 0 0 1 1 0 1 1 1
                     29.0  0 0 0 0 1 0 1 1 1
                     28.5  0 0 0 1 0 0 1 1 1
                     28.0  0 0 0 0 0 0 1 1 1
                     27.5  0 0 0 1 1 1 0 1 1
                     27.0  0 0 0 0 1 1 0 1 1
                     26.5  0 0 0 1 0 1 0 1 1
                     26.0  0 0 0 0 0 1 0 1 1
                     25.5  0 0 0 1 1 0 0 1 1
                     25.0  0 0 0 0 1 0 0 1 1
                     24.5  0 0 0 1 0 0 0 1 1
                     24.0  0 0 0 0 0 0 0 1 1
                     23.5  0 0 0 1 1 1 1 0 1
                     23.0  0 0 0 0 1 1 1 0 1
                     22.5  0 0 0 1 0 1 1 0 1
                     22.0  0 0 0 0 0 1 1 0 1
                     21.5  0 0 0 1 1 0 1 0 1
                     21.0  0 0 0 0 1 0 1 0 1
                     20.5  0 0 0 1 0 0 1 0 1
                     20.0  0 0 0 0 0 0 1 0 1
                     19.5  0 0 0 1 1 1 0 0 1
                     19.0  0 0 0 0 1 1 0 0 1
                     18.5  0 0 0 1 0 1 0 0 1
                     18.0  0 0 0 0 0 1 0 0 1
                     17.5  0 0 0 1 1 0 0 0 1
                     17.0  0 0 0 0 1 0 0 0 1
                     16.5  0 0 0 1 0 0 0 0 1
                     16.0  0 0 0 0 0 0 0 0 1
                     15.5  0 0 0 1 1 1 1 1 0
                     15.0  0 0 0 0 1 1 1 1 0
                     14.5  0 0 0 1 0 1 1 1 0
                     14.0  0 0 0 0 0 1 1 1 0
                     13.5  0 0 0 1 1 0 1 1 0
                     13.0  0 0 0 0 1 0 1 1 0
                     12.5  0 0 0 1 0 0 1 1 0
                     12.0  0 0 0 0 0 0 1 1 0
                     11.5  0 0 0 1 1 1 0 1 0
                     11.0  0 0 0 0 1 1 0 1 0
                     10.5  0 0 0 1 0 1 0 1 0
                     10.0  0 0 0 0 0 1 0 1 0
                      9.5  0 0 0 1 1 0 0 1 0
                      9.0  0 0 0 0 1 0 0 1 0
                      8.5  0 0 0 1 0 0 0 1 0
                      8.0  0 0 0 0 0 0 0 1 0
                      7.5  0 0 0 1 1 1 1 0 0
                      7.0  0 0 0 0 1 1 1 0 0
                      6.5  0 0 0 1 0 1 1 0 0
                      6.0  0 0 0 0 0 1 1 0 0
                      5.5  0 0 0 1 1 0 1 0 0
                      5.0  0 0 0 0 1 0 1 0 0
                      4.5  0 0 0 1 0 0 1 0 0
                      4.0  0 0 0 0 0 0 1 0 0
                      3.5  0 0 0 1 1 1 0 0 0
                      3.0  0 0 0 0 1 1 0 0 0
                      2.5  0 0 0 1 0 1 0 0 0
                      2.0  0 0 0 0 0 1 0 0 0
                      1.5  0 0 0 1 1 0 0 0 0
                      1.0  0 0 0 0 1 0 0 0 0
                      0.5  0 0 0 1 0 0 0 0 0
                      0.0  0 0 0 0 0 0 0 0 0]);

handles.output = hObject;
guidata(hObject, handles);
% UIWAIT makes Gas_Det_Cal wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = Gas_Det_Cal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
ST1   = lcaGetSmart('PPS:FEE1:1:STPR01');
ST2   = lcaGetSmart('PPS:FEE1:1:STPR02');
if strcmp(TDUND,'IN') || strcmp(ST1,'IN') || strcmp(ST2,'IN')
  set(handles.MSG,'String','TDUND, ST1, or ST2 are IN - scan aborted.')
  warndlg('TDUND, ST1, or ST2 are IN - no beam - scan aborted.','Stopper is IN')
  if ~handles.fakedata
    return
  end
end
Q0   = lcaGetSmart('IOC:IN20:BP01:QANN');           % Get lower charge limit from BPM attenuation factor (nC)
[sys,accelerator]=getSystem();
rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);   % rep. rate [Hz]
if rate < 10
  yn = questdlg('Beam rate is <10 Hz.  Do you want to continue?','Low Beam Rate');
  if ~strcmp(yn,'Yes')
    set(handles.MSG,'String','Beam rate is <10 Hz - scan aborted.')
    return
  else
    if handles.fakedata
      rate = 10;    % for testing only, when rate is zero
    end
  end
end
set(handles.START,'BackgroundColor','white')
set(handles.START,'String','wait...')
set(handles.MSG,'String','In progress...')
drawnow

[mn,imn] = min(abs(handles.Be_matrix(:,1)-handles.Be_min));
[mx,imx] = min(abs(handles.Be_matrix(:,1)-handles.Be_max));
if handles.Be_stepsize==0.5
  ss = 1;
elseif handles.Be_stepsize==1
  ss = 2;
elseif handles.Be_stepsize==2
  ss = 4;
elseif handles.Be_stepsize==4
  ss = 8;
elseif handles.Be_stepsize==8
  ss = 16;
elseif handles.Be_stepsize==16
  ss = 32;
elseif handles.Be_stepsize==32
  ss = 64;
end
handles.Be_scan_index = imn:ss:imx;
sub_matrix = handles.Be_matrix(handles.Be_scan_index,:);

handles.Nset     = length(sub_matrix(:,1));
handles.Ndevs    = length(handles.dev_pvs);
init_Be_settings = 2 - lcaGetSmart(handles.Be_read_pvs,0,'double'); % 2 means OUT and 1 means IN, but 2 becomes 0 for the lcaPut 
dev_bkj           = zeros(handles.Ndevs,handles.navg);
handles.dev_mean  = zeros(handles.Nset,handles.Ndevs);
handles.dev_std   = zeros(handles.Nset,handles.Ndevs);
handles.Tact     = zeros(1,handles.Nset);

if ~handles.nosettings
  lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',0);
end
pause(0.5)
for j = 1:handles.navg
  if ~handles.fakedata
    dev_bkj(:,j) = lcaGetSmart(handles.dev_pvs);
  else
    dev_bkj(:,j) = rand(size(handles.dev_pvs))-1;
  end
  pause(1/rate)
end
if ~handles.nosettings
  lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',1);
end
handles.dev_bk = mean(dev_bkj',1);      % take gas detector background with beam OFF

for k = 1:handles.Nset
  if ~handles.nosettings
    lcaPutSmart(handles.Be_cmd_pvs,sub_matrix(k,2:end)');
  end
  set(handles.MSG,'String',['Be thickness: ' num2str(sub_matrix(k,1)) ' mm: ' num2str(sub_matrix(k,2:end))])
  drawnow
  pause(handles.delay)
  if ~handles.nosettings
    handles.Tact(k) = lcaGetSmart(handles.Be_total)*25.4E-3;    % Steve Lewis' total thickness PV based on present insertions (mils->mm)
  else
    handles.Tact(k) = sub_matrix(k,1);    % fake the readback
  end
  set(handles.START,'String',[num2str(handles.Tact(k))  ' mm...'])
  drawnow
  if handles.Tact(k) > 0
    if abs(handles.Tact(k) - sub_matrix(k,1))/handles.Tact(k) > 0.02
      warndlg(sprintf(['Total Be thickness from ' handles.Be_total ' PV (%4.1f mm) does not agree within <2%% of expected value (%4.1f mm).'],handles.Tact(k),sub_matrix(k,1)),'Beryllium THICKNESS WARNING')
    end
  else
    if abs(handles.Tact(k) - sub_matrix(k,1)) > 0.1
      warndlg(sprintf(['Total Be thickness from ' handles.Be_total ' PV (%4.1f mm) does not agree within 0.1 mm of expected value (%4.1f mm).'],handles.Tact(k),sub_matrix(k,1)),'Beryllium THICKNESS WARNING')
    end
  end
  dev = zeros(handles.Ndevs,handles.navg);
  for j = 1:handles.navg
    if ~handles.fakedata
      dev(:,j) = lcaGetSmart(handles.dev_pvs);
    else
      dev(:,j) = rand(size(handles.dev_pvs)); % fake data
    end
    pause(1/rate)
  end
  handles.dev_mean(k,:) = mean(dev',1);
  if handles.navg == 1
    handles.dev_std(k,:)  = zeros(1,handles.Ndevs);    % no error bars with navg = 1
  else
    handles.dev_std(k,:)  = std(dev')/sqrt(handles.navg-1);
  end
  handles.date_time = get_time;
  handles.assoc_data = lcaGetSmart(handles.assoc_data_pvs); % get associated data (PMT voltages, etc)
  plot_dev_data(0,hObject,handles,k)
end
set(handles.MSG,'String','Restoring intial Be settings...')
drawnow
pause(1)
if ~handles.nosettings
  lcaPutSmart(handles.Be_cmd_pvs,init_Be_settings);
end

set(handles.START,'BackgroundColor','green')
set(handles.START,'String','Start Scan')
set(handles.printLog_btn1,'Enable','on')
set(handles.EXPORT,'Enable','on')
handles.have_data = 1;
set(handles.MSG,'String','Done')
drawnow
guidata(hObject,handles);



function plot_dev_data(Elog_fig,hObject,handles,k)
if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(1,1,1);
else
  ax1 = handles.AXES1;
end
y  = handles.dev_mean(1:k,handles.nd)-handles.dev_bk(handles.nd);
dy = handles.dev_std(1:k,handles.nd)./y;
x  = handles.Tact(1:k);
axes(ax1)
idy = find(dy==0);
if ~isempty(idy)
  plot(x,log(y),'*g');
else
  plot_bars(x,log(y),dy,'*g','k');
end
hold on
ifit = find(x>=handles.minfit & x<=handles.maxfit);
if std(y(ifit))>0 && std(x(ifit))>0
  if ~isempty(idy)
    [q,dq] = plot_polyfit(x(ifit),log(y(ifit)),1,1,' ',' ',' ',' ',1);
    plot(x(ifit),log(y(ifit)),'ro')
  else
    [q,dq] = plot_polyfit(x(ifit),log(y(ifit)),dy(ifit),1,' ',' ',' ',' ',1);
    plot_bars(x(ifit),log(y(ifit)),dy(ifit),'ro')
  end
  xf = min(x):(max(x)-min(x))/10:max(x);
  yf = q(1) + q(2)*xf;
  plot(xf,yf,'b-')
  attn_lng = -1/q(2);
  dattn_lng = abs(dq(2))/q(2)^2;
  I0 = exp(q(1));
  title([handles.date_time ', ' sprintf('attenL=%4.2f+-%4.2f mm, I0fit=%5.3e, I0=%5.3e',attn_lng,dattn_lng,I0,y(1))])
end
xlabel('Total Be Thickness (mm)')
ylabel(['ln(' handles.dev_pvs{handles.nd} ' [mJ])'])
axis([-1 34 handles.miny handles.maxy])
v = axis;
dxplot = v(2) - v(1);
dyplot = v(4) - v(3);
text(v(1)+dxplot/40,v(3)+1*dyplot/20,sprintf('Eloss= %4.2f mJ',handles.assoc_data(9)))
text(v(1)+dxplot/40,v(3)+2*dyplot/20,sprintf('E = %5.2f GeV',handles.assoc_data(10)))
text(v(1)+dxplot/40,v(3)+3*dyplot/20,sprintf('slitX = %3.1f, %3.1f mm',handles.assoc_data(13),handles.assoc_data(14)))
text(v(1)+dxplot/40,v(3)+4*dyplot/20,sprintf('slitY = %3.1f, %3.1f mm',handles.assoc_data(11),handles.assoc_data(12)))
if handles.nd<5
  text(v(1)+dxplot/40,v(3)+5*dyplot/20,sprintf('PMT = %4.0f V',handles.assoc_data(handles.nd)))
  text(v(1)+dxplot/40,v(3)+6*dyplot/20,sprintf('Sol = %4.2f A',handles.assoc_data(round(handles.nd/2)+4)))
  text(v(1)+dxplot/40,v(3)+7*dyplot/20,sprintf('Press= %5.3f Torr',handles.assoc_data(round(handles.nd/2)+6)))
end
enhance_plot
hold off



function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
if handles.navg < 1
  handles.navg = 1;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be < 1','WARNING')
end
if handles.navg > 100
  handles.navg = 100;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be > 100','WARNING')
end
guidata(hObject,handles);

function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printLog_btn1_Callback(hObject, eventdata, handles)
plot_dev_data(1,hObject,handles,handles.Nset)
util_printLog(1);



% --- Executes on button press in EXPORT.
function EXPORT_Callback(hObject, eventdata, handles)
plot_dev_data(1,hObject,handles,handles.Nset)



function figure1_CloseRequestFcn(hObject, eventdata, handles)
util_appClose(hObject);



function BE_MIN_Callback(hObject, eventdata, handles)
handles.Be_min = str2double(get(hObject,'String'));
if handles.Be_min < 0
  handles.Be_min = 0;
  set(handles.BE_MIN,'String',num2str(handles.Be_min))
  warndlg('Minimum Be thickness cannot be < 0','WARNING')
end
if handles.Be_min > 33
  handles.Be_min = 33;
  set(handles.BE_MIN,'String',num2str(handles.Be_min))
  warndlg('Minimum Be thickness cannot be > 33 mm','WARNING')
end
if handles.Be_min > handles.Be_max
  handles.Be_min = handles.Be_max;
  set(handles.BE_MIN,'String',num2str(handles.Be_min))
  warndlg(sprintf('Minimum Be thickness cannot be > present max. of %2.0f mm',handles.Be_max),'WARNING')
end
guidata(hObject,handles);

function BE_MIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BE_MAX_Callback(hObject, eventdata, handles)
handles.Be_max = str2double(get(hObject,'String'));
if handles.Be_max < 0
  handles.Be_max = 0;
  set(handles.BE_MAX,'String',num2str(handles.Be_max))
  warndlg('Maximum Be thickness cannot be < 0','WARNING')
end
if handles.Be_max > 33
  handles.Be_max = 33;
  set(handles.BE_MAX,'String',num2str(handles.Be_max))
  warndlg('Maximum Be thickness cannot be > 33 mm','WARNING')
end
if handles.Be_max < handles.Be_min
  handles.Be_max = handles.Be_min;
  set(handles.BE_MAX,'String',num2str(handles.Be_max))
  warndlg(sprintf('Maximum Be thickness cannot be < present min. of %2.0f mm',handles.Be_min),'WARNING')
end
guidata(hObject,handles);

function BE_MAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BE_STEPSIZE_Callback(hObject, eventdata, handles)
steps = str2double(get(hObject,'String'));
handles.Be_stepsize = steps(get(hObject,'Value'));
guidata(hObject,handles);

function BE_STEPSIZE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MAXFIT_Callback(hObject, eventdata, handles)
handles.maxfit = str2double(get(hObject,'String'));
if handles.maxfit < 0
  handles.maxfit = 0;
  set(handles.MAXFIT,'String',num2str(handles.maxfit))
  warndlg('Maximum of fit cannot be < 0','WARNING')
end
if handles.maxfit > 33
  handles.maxfit = 33;
  set(handles.MAXFIT,'String',num2str(handles.maxfit))
  warndlg('Maximum of fit cannot be > 33 mm','WARNING')
end
if handles.maxfit < handles.minfit
  handles.maxfit = handles.minfit;
  set(handles.MAXFIT,'String',num2str(handles.maxfit))
  warndlg(sprintf('Maximum of fit cannot be < present min. of %2.0f mm',handles.minfit),'WARNING')
end
if handles.have_data
  plot_dev_data(0,hObject,handles,handles.Nset)
end
guidata(hObject,handles);

function MAXFIT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MINFIT_Callback(hObject, eventdata, handles)
handles.minfit = str2double(get(hObject,'String'));
if handles.minfit < 0
  handles.minfit = 0;
  set(handles.MINFIT,'String',num2str(handles.minfit))
  warndlg('Minimum of fit cannot be < 0','WARNING')
end
if handles.minfit > 33
  handles.minfit = 33;
  set(handles.MINFIT,'String',num2str(handles.minfit))
  warndlg('Minimum of fit cannot be > 33 mm','WARNING')
end
if handles.minfit > handles.maxfit
  handles.minfit = handles.maxfit;
  set(handles.MINFIT,'String',num2str(handles.minfit))
  warndlg(sprintf('Minimum of fit cannot be > present max. of %2.0f mm',handles.maxfit),'WARNING')
end
if handles.have_data
  plot_dev_data(0,hObject,handles,handles.Nset)
end
guidata(hObject,handles);

function MINFIT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MINY_Callback(hObject, eventdata, handles)
handles.miny = str2double(get(hObject,'String'));
if handles.miny < -100
  handles.miny = -100;
  set(handles.MINY,'String',num2str(handles.miny))
  warndlg('Minimum of Y plot scale cannot be < -100','WARNING')
end
if handles.miny > 100
  handles.miny = 100;
  set(handles.MINY,'String',num2str(handles.miny))
  warndlg('Minimum of plot scale cannot be > 100','WARNING')
end
if handles.miny > handles.maxy
  handles.miny = handles.maxy-1;
  set(handles.MINY,'String',num2str(handles.miny))
  warndlg(sprintf('Minimum of plot scale cannot be > present max. of %2.0f',handles.maxy),'WARNING')
end
if handles.have_data
  plot_dev_data(0,hObject,handles,handles.Nset)
end
guidata(hObject,handles);

function MINY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MAXY_Callback(hObject, eventdata, handles)
handles.maxy = str2double(get(hObject,'String'));
if handles.maxy > 100
  handles.maxy = 100;
  set(handles.MAXY,'String',num2str(handles.maxy))
  warndlg('Maximum of Y plot scale cannot be > 100','WARNING')
end
if handles.maxy < -100
  handles.maxy = -100;
  set(handles.MAXY,'String',num2str(handles.maxy))
  warndlg('Maximum of plot scale cannot be < -100','WARNING')
end
if handles.maxy < handles.miny
  handles.maxy = handles.miny+1;
  set(handles.MAXY,'String',num2str(handles.maxy))
  warndlg(sprintf('Maximum of plot scale cannot be < present min. of %2.0f',handles.miny),'WARNING')
end
if handles.have_data
  plot_dev_data(0,hObject,handles,handles.Nset)
end
guidata(hObject,handles);

function MAXY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DEVS_Callback(hObject, eventdata, handles)
handles.nd = get(hObject,'Value');
if handles.have_data
  plot_dev_data(0,hObject,handles,handles.Nset)
end
guidata(hObject,handles);

function DEVS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


