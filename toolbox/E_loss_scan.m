function varargout = E_loss_scan(varargin)   
% E_LOSS_SCAN M-file for E_loss_scan.fig
%      E_LOSS_SCAN, by itself, creates a new E_LOSS_SCAN or raises the
%      existing
%      singleton*.
%
%      H = E_LOSS_SCAN returns the handle to a new E_LOSS_SCAN or the handle to
%      the existing singleton*.
%
%      E_LOSS_SCAN('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in E_LOSS_SCAN.M with the given input arguments.
%
%      E_LOSS_SCAN('Property','Value',...) creates a new E_LOSS_SCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before E_loss_scan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to E_loss_scan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help E_loss_scan

% Last Modified by GUIDE v2.5 29-Jul-2020 09:53:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @E_loss_scan_OpeningFcn, ...
                   'gui_OutputFcn',  @E_loss_scan_OutputFcn, ...
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



% --- Executes just before E_loss_scan is made visible.
function E_loss_scan_OpeningFcn(hObject, eventdata, handles, varargin)

handles.fakedata = epicsSimul_status;
set(handles.JG,'CData',imread('JG.bmp'));

handles = pvList(handles);
HS = handles.undulator;
% 9/12/2020: This no longer applies: 4/20/2016 S Hoobler:
% BAD NEWS for maintainer of this program: It now writes to MPS PVs when
% 1. Implementing calibration
% 2. Undoing calibration
% 3. Zeroing out calibration
% It assumes the order of the detector_PVs matches the order of MPS PVs
% (for GDET only). Do not change any of this without consulting MPS expert.
%
set(handles.figure1,'Color', [202 214 230]/255)
handles.detector_PVs = {
                        'GDET:FEE1:241:ENRCCUHBR', 'GDET:FEE1:241:CALI', 'GDET:FEE1:241:OFFS', 'GDET:FEE1:241:CALTIME', 'HVCH:FEE1:241:VoltageMeasure', 'SMPS:FEE1:201:I', 'VGBA:FEE1:240:P'
                        'GDET:FEE1:242:ENRCCUHBR', 'GDET:FEE1:242:CALI', 'GDET:FEE1:242:OFFS', 'GDET:FEE1:242:CALTIME', 'HVCH:FEE1:242:VoltageMeasure', 'SMPS:FEE1:201:I', 'VGBA:FEE1:240:P'
                        'GDET:FEE1:361:ENRCCUHBR', 'GDET:FEE1:361:CALI', 'GDET:FEE1:361:OFFS', 'GDET:FEE1:361:CALTIME', 'HVCH:FEE1:361:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
                        'GDET:FEE1:362:ENRCCUHBR', 'GDET:FEE1:362:CALI', 'GDET:FEE1:362:OFFS', 'GDET:FEE1:362:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
                        'KMON:FEE1:421:ENRC', 'KMON:FEE1:421:CALI', 'KMON:FEE1:421:OFFS', 'KMON:FEE1:421:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
                        'KMON:FEE1:422:ENRC', 'KMON:FEE1:422:CALI', 'KMON:FEE1:422:OFFS', 'KMON:FEE1:422:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
                        'KMON:FEE1:423:ENRC', 'KMON:FEE1:423:CALI', 'KMON:FEE1:423:OFFS', 'KMON:FEE1:423:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
                        'KMON:FEE1:424:ENRC', 'KMON:FEE1:424:CALI', 'KMON:FEE1:424:OFFS', 'KMON:FEE1:424:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
%                         'TEM:FEE1:018:ENRC' , 'TEM:FEE1:018:CALI' , 'TEM:FEE1:018:OFFS' , 'TEM:FEE1:018:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
%                         'TEM:FEE1:022:ENRC' , 'TEM:FEE1:022:CALI' , 'TEM:FEE1:022:OFFS' , 'TEM:FEE1:022:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
%                         'TEM:FEE1:032:ENRC' , 'TEM:FEE1:032:CALI' , 'TEM:FEE1:032:OFFS' , 'TEM:FEE1:032:CALTIME', 'HVCH:FEE1:362:VoltageMeasure', 'SMPS:FEE1:202:I', 'VGBA:FEE1:360:P'
                                            };  % FEE detectors also read during E-loss scan (for optional calibration)
                                                                              
handles.detector_PVs(5:end,:)=[]; % Kludge for GDET 2 IOC not working if enabled
handles.Ndet = length(handles.detector_PVs(:,1));
set(handles.DETS,'String',handles.detector_PVs(:,1)) %TODO
handles.mpsCalDone_PVs  = { 'GDET:FEE1:241:MPS_CAL_DONE', 'GDET:FEE1:242:MPS_CAL_DONE', 'GDET:FEE1:361:MPS_CAL_DONE', 'GDET:FEE1:362:MPS_CAL_DONE'};
handles.mpsCalUndone_PVs= { 'GDET:FEE1:241:MPS_CAL_UNDONE', 'GDET:FEE1:242:MPS_CAL_UNDONE', 'GDET:FEE1:361:MPS_CAL_UNDONE', 'GDET:FEE1:362:MPS_CAL_UNDONE'};
handles.mpsCalZero_PVs  = { 'GDET:FEE1:241:MPS_CAL', 'GDET:FEE1:242:MPS_CAL', 'GDET:FEE1:361:MPS_CAL', 'GDET:FEE1:362:MPS_CAL'};
handles.idet = get(handles.DETS,'Value');
handles.cal_time = lcaGetSmart(handles.detector_PVs(:,4));
handles.cal_done(1:handles.Ndet) = 0;
%handles.atten_PV = 'GDSA:FEE1:TATT:R_ACT';
handles.atten_PV = handles.modesPVs.atten_PV.(HS);
handles.atten_trans_at_cal_time = -1; % Gets recorded when the e_loss scan is run
set(handles.CAL_TIME,'String',handles.cal_time(handles.idet,:))
handles.Eloss_plots = 1;
handles.output = hObject;
%handles.E0 = lcaGetSmart('BEND:DMP1:400:BDES');
handles.E0 = lcaGetSmart(handles.modesPVs.E0.(HS));
handles.navg = str2double(get(handles.NAVG,'String'));
handles.ncal = str2double(get(handles.NCAL,'String'));
handles.npoints = str2double(get(handles.NPOINTS,'String'));
handles.init = 0;       % have not yet initialized the ref orbit or gotten model
if handles.E0 > 10
  handles.maxbdes = 200;
  set(handles.MAXBDES,'String',num2str(handles.maxbdes));
else
  handles.maxbdes = 250;
  set(handles.MAXBDES,'String',num2str(handles.maxbdes));
end
handles.show_fee = get(handles.SHOW_FEE,'Value');
handles.fitoffset=1;
set(handles.fitoffset_box,'Value',1);
handles.elossperamp = lcaGetSmart(handles.modesPVs.elossperamp.(['CU' HS 'XR']));
handles.mean_Ipk0 = lcaGetSmart(handles.modesPVs.mean_Ipk0.(['CU' HS 'XR']));
set(handles.IPK0,'String',handles.mean_Ipk0)
handles.have_Eloss = 0;
handles.have_calibration = 0;
handles.have_HeaterData = 0;
handles.delay = 1;  % delay after setting XCOR 
handles.plot_scale = [-handles.maxbdes handles.maxbdes -10 10];     % no real plot scale determined yet
handles.plot_scale_fit = [0 10 -10 10];     % no real plot scale determined yet
set(handles.ELOSSPERAMP,'String',sprintf('%6.4f',handles.elossperamp));
xcors = model_nameConvert({'XCOR' 'YCOR'}, 'EPICS', ['UND' HS]);
%for ii = 1:length(xcors), und_xcors{ii} = strrep(xcors(ii,:),'XCOR:',''); end
set(handles.XCOR,'String', xcors)
handles.fdbkList = handles.modesPVs.fdbkList.(HS);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = E_loss_scan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ------------------------------------------------------------------------
function data = appRemote(hObject)

%init=~any(strcmp(get(util_appFind,'Name'),'E_loss_scan'));
[hObject,handles]=util_appFind('E_loss_scan');
init=1;

if init
    CALIBRATE_Callback(handles.CALIBRATE,[],handles);
    handles=guidata(hObject);
end
set(handles.START,'Value',1);
START_Callback(handles.START,[],handles);
handles=guidata(hObject);
data.energy=handles.xray_energy;
data.energyStd=handles.dEloss*handles.charge;
% Set PVs to zero if they were not updated before
M = handles.lclsMode;
if ~(handles.dEloss < abs(handles.Eloss) && abs(handles.Eloss)<100)
    lcaPutSmart(handles.modesPVs.result.(M),0);
    lcaPutSmart(handles.modesPVs.photons.(M),0);
    lcaPutSmart(handles.modesPVs.intensity(M),0);
end

% --- Executes when user attempts to close E_loss_scan_gui.
function E_loss_scan_CloseRequestFcn(hObject, eventdata, handles)
util_appClose(hObject);

% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
M = handles.lclsMode; 
HS = handles.undulator;
set(hObject,'Value',~get(hObject,'Value'));  
if gui_acquireStatusSet(hObject,handles,1);return, end

start_time = tic;

setDataSliderVisibility(handles,'off');
TDUND = lcaGetSmart( handles.modesPVs.tdund.(HS) );
if strcmp(TDUND,'IN')
  display_message(handles,['TDUND ' HS ' is IN - scan aborted.'])
  warndlg('TDUND is IN - no beam - scan aborted.','Stopper is IN')
  if ~handles.fakedata
    return  %forInvasive
  end
end
set(hObject,'BackgroundColor','white')
set(hObject,'String','Init...')
drawnow
%checkGDetPressure(hObject,handles);
%fdbk_state = lcaGetSmart(handles.fdbkList,0,'double');
fdbk_state = lcaGetSmart(handles.modesPVs.fdbkList.(HS),0,'double');
handles.E0 = lcaGetSmart(handles.modesPVs.E0.(HS) ); %BEND:DMP1:400:BDES'
handles.atten_trans_at_cal_time = lcaGetSmart(handles.modesPVs.atten_PV.(HS));
if ~handles.fakedata
  lcaPutSmart(handles.fdbkList,0); %forInvasive
  display_message(handles,[M 'Undulator feedback disabled']);
end

xtcavstate=control_klysStatGet(['KLYS:DMP' HS ':1']); 
if xtcavstate == 1 && get(handles.deactXTCAV_box,'Value')
    control_klysStatSet(['KLYS:DMP' HS ':1'],0); %ForInvasive
    display_message(handles,['Turning off XTCAV: KLYS:DMP' HS ':1']');
    pause(3);
end

IN_struc.initialize = 1;
IN_struc.navg = 1;
loss_per_Ipk = lcaGetSmart(handles.modesPVs.elossperamp.(M) );
handles.mean_Ipk0 = lcaGetSmart(handles.modesPVs.mean_Ipk0.(M) );
IN_struc.Loss_per_Ipk = loss_per_Ipk;
OUT_struc = DL2toDumpEnergyLoss(IN_struc,handles.lclsMode);
dE0 = OUT_struc.dE;
handles.init = 1;           % remember that we have initialized the ref orbit and gotten the model

IN_struc.initialize = 0;
IN_struc.navg = 1;
BDES0 = lcaGetSmart(strcat(handles.XCOR_PV,':BDES'));
handles.BDES  = linspace(handles.maxbdes,-handles.maxbdes,handles.npoints);
TMIT        = zeros(size(handles.BDES));
TMITj       = zeros(1,handles.navg);
handles.dE  = zeros(size(handles.BDES));
handles.ddE = zeros(size(handles.BDES));
handles.Ipk = zeros(size(handles.BDES));
handles.GD  = zeros(length(handles.BDES),handles.Ndet);
handles.dGD = zeros(length(handles.BDES),handles.Ndet);
dEj  = zeros(1,handles.navg);
Ipkj = zeros(1,handles.navg);
GDj  = zeros(handles.navg,handles.Ndet);
GDt  = zeros(handles.navg, handles.Ndet);
valid = zeros(1, handles.navg);
gvalid = zeros(handles.navg, handles.Ndet);
display_message(handles,'Starting scan...')
handles.time = datestr(now);
everythingok=1;
try
    if ~handles.fakedata &&  strcmp(handles.lclsMode,'CUHXR')
        lcaSetMonitor(handles.detector_PVs(:,1)); %TODO check for CU_SXR
    end
    
    %Calculate closed bump
    
    Sol = undulatorClosedBumpSolver(handles);
    %handles.BDES = Sol.KickTable(1,:);
    handles.BDES = Sol.KickTableForgetClosing(1,:);
    handles.XCOR_PV = strrep( Sol.CorrPV{1},':BCTRL','');
    
    for j = 1:handles.npoints
      handles.Eloss_scan_index = j;
      set(hObject,'String',sprintf('%2.0f...',j))
      drawnow
      bstart = lcaGetSmart(strcat(handles.XCOR_PV,':BCTRL'));
      bdiff = abs(bstart - handles.BDES(j));
      %db = bdiff / max(Sol.KickTable(1,:)); %  bdiff /handles.maxbdes; 
      db = bdiff / max(Sol.KickTableForgetClosing(1,:));
      if ~handles.fakedata
        lcaPut( Sol.CorrPV, Sol.KickTableForgetClosing(:,j))  %forInvasive
      else
          db = db/10;
      end
      pause(handles.delay * db); 
      display_message(handles,['Set ' handles.XCOR_PV '=' sprintf('%8.5f kG-m',handles.BDES(j))])
      tstart = now;
      for jj = 1:handles.navg
        if ~handles.fakedata
          OUT_struc = DL2toDumpEnergyLoss(IN_struc, handles.lclsMode);
          dEj(jj)   = OUT_struc.dE - dE0;
          Ipkj(jj)  = OUT_struc.Ipk;
          valid(jj) = OUT_struc.valid;
        end
        if handles.fakedata
          valid(jj) = 1;
          Ipkj(jj) = 3000 + 50*randn;
          TMITj(jj) = 0.25 + 0.005*randn;    % fake charge
          dEj(jj)   = 18*gauss(handles.BDES(j),0,8E-4)*sqrt(2*pi)*8E-4 + 3 + 0.0002*randn(1);       % fake data
          for kk = 1:handles.Ndet
            X = 4000*1.5*gauss(handles.BDES(j),0,8E-4)*sqrt(2*pi)*8E-4 - 3000*0.1*kk + 100*0.00015*randn(1);   % temporary test (Aug. 7, 2009 - PE)
            GDj(jj,kk) = 2*X/7960.84 + 1 - (-9549.01/7960.84*0.25) - 3.98*0.25;
            GDt(jj,kk) = now; %fake timestamps J. Rzepiela 1/26/12
          end
        else
          TMITj(jj) = lcaGetSmart(handles.modesPVs.ltuBpm.(HS) )*1.602E-10;
          if strcmp(handles.lclsMode,'CUHXR') %TODO add CUSXR GMD when available
              lcaNewMonitorWait(handles.detector_PVs(:,1));
              [val, ts] = lcaGetSmart(handles.detector_PVs(:,1));
              GDj(jj,:) = val';
              for kk = 1:handles.Ndet
                  GDt(jj,kk) = lca2matlabTime(ts(kk));
              end
          end
        end
       if ~gui_acquireStatusGet(hObject,handles),  
           %keyboard
           dbstack
           fprintf('%s Scan aborted by user\nRestoring Correctors...\n', datestr(now))
           lcaPut( Sol.Cor, Sol.RestoreDest)  %forInvasive
           break, 
       end
      end

      deltaT= GDt - tstart;
      gvalid = deltaT > 0;
      disp((min(GDt(:,1:min(end,4)))-tstart)*24*60*60);
      gdet_valid = (sum(gvalid(:,1:min(end,4)), 2) == min(size(gvalid,2),4))';
      n_gdet_valid = sum(gdet_valid);
      gdet_valids = find(gdet_valid);

      %valid = valid & gdet_valid;  
      n_valid = sum(valid);
      valids = find(valid);

      display_message(handles,strcat({'Valid data: '}, num2str(n_valid), '/' , ...
          num2str(handles.navg), {' Eloss, '}, num2str(n_gdet_valid), '/' , ...
          num2str(handles.navg),{' GDET.'}));
      
      % filter by distance to Ipk setpoint % TODO fix this
      %IpkSP = lcaGetSmart('FBCK:FB04:LG01:S5DES');
      %sigmaCut = str2double(get(handles.sigmaCutEdit,'String'));
      %IpkStd = util_stdNan(handles.Ipkj);
      %keepI = (handles.Ipkj > (IpkSP - sigmaCut*IpkStd)) & (handles.Ipkj < (IpkSP + sigmaCut*IpkStd));
      
      %valids = find(valid & keepI);

      TMIT(j)          = mean(TMITj(valids));
      handles.dE(j)    = mean(dEj(valids));
      handles.Ipk(j)   = mean(Ipkj(valids));
      handles.GD(j,:)  = mean(GDj(gdet_valids, :));

      if n_valid <= 1
          handles.ddE(j) = 0;
      else
          handles.ddE(j)   = std(dEj(valids))/sqrt(n_valid-1);
      end

      if n_gdet_valid <= 1
          handles.dGD(j,:) = zeros(1, handles.Ndet);
      else
          handles.dGD(j,:) = std(GDj(gdet_valids, :))/sqrt(n_gdet_valid-1);
      end


    %  iTMIT = find(TMIT);
      iTMIT = find(TMIT > 0.005); % H. Loos, 04/03/2010
      if ~isempty(iTMIT)
        handles.charge = mean(TMIT(iTMIT));
      else
        handles.charge = 0;
      end
      guidata(hObject,handles);
      handles = plot_Eloss(0,hObject,handles);
      if ~gui_acquireStatusGet(hObject,handles), break, end 
    end
catch ex
    everythingok=0; % We'll get back to this exception later...
    rethrow(ex)
    keyboard
end


if handles.Eloss < 10
  set(handles.JG,'Visible','off')
  set(handles.LUCKYDOG,'Visible','off')
elseif (handles.Eloss >= 10) && (handles.Eloss < 15)
  set(handles.JG,'CData',imread('JG.bmp'));
  set(handles.LUCKYDOG,'String','Lucky dog!')
  set(handles.JG,'Visible','on')
  set(handles.LUCKYDOG,'Visible','on')
elseif (handles.Eloss >= 15) && (handles.Eloss < 100)
  set(handles.JG,'CData',imread('Guy.bmp'));
  set(handles.LUCKYDOG,'String','Yikes!')
  set(handles.JG,'Visible','on')
  set(handles.LUCKYDOG,'Visible','on')
else
  set(handles.JG,'Visible','off')
  set(handles.LUCKYDOG,'Visible','off')
end

display_message(handles,['Restore ' handles.XCOR_PV '=' sprintf('%8.5f kG-m',BDES0)])
if ~handles.fakedata
  try
      lcaClear(handles.detector_PVs(:,1)); 
  end
  %lcaPutSmart(strcat(handles.XCOR_PV,':BCTRL'),BDES0);
  lcaPut(Sol.CorrPV,Sol.RestoreDest)
  pause(handles.delay)
  outoftol = sum(check_magnet(Sol.CorrPV));
  if outoftol
    trim_magnet(Sol.CorrPV,Sol.RestoreDest,'T');
  end
  display_message(handles,['Restoring feedbacks to ' num2str(fdbk_state')]);
  lcaPutSmart(handles.fdbkList,fdbk_state);
  if handles.dEloss < abs(handles.Eloss) && abs(handles.Eloss)<100 
    lcaPutSmart(handles.modesPVs.result.(M),handles.Eloss); %Was PHYS:SYS0:1:ELOSSRESULT
    lcaPutSmart(handles.modesPVs.photons.(M),handles.Nphotons/1E12); %was PHYS:SYS0:1:ELOSSNPHOTONS
    lcaPutSmart(handles.modesPVs.intensity.(M),handles.xray_energy);%was PHYS:SYS0:1:ELOSSENERGY
    
    lcaPutSmart(handles.modesPVs.electronEnergy.(M), handles.E0);
    
  end
end
for j = 1:handles.Ndet
  handles.cal_done(j) = 0;
end
display_message(handles,'All done.')
set(hObject,'BackgroundColor','green')
set(hObject,'String','Start')
set(handles.CAL_DET,'Enable','on')
drawnow
handles.have_Eloss = 1;
handles.have_calibration = 0;
handles.have_HeaterData = 0;
if abs(handles.mean_Ipk - handles.mean_Ipk0) > 500
  helpdlg(sprintf('Mean peak current is %4.0f A, while last calibration current was %4.0f A.  Running a new calibration might improve the data quality.',handles.mean_Ipk,handles.mean_Ipk0),'')
end
gui_acquireStatusSet(hObject,handles,0);
% if xtcavstate == 1 && get(handles.deactXTCAV_box,'Value')
%   control_klysStatSet('KLYS:DMPH:1',1); %TODO TEST does this work?
%   display_message(handles,'Turning on XTCAV');
% end


%Make a copy of all the data collected, so we can manipulate which
%datapoints we use with the slider.

handles.fulldE = handles.dE;
handles.fullddE = handles.ddE;
handles.fullIpk = handles.Ipk;
handles.fullBDES = handles.BDES;
handles.fullGD = handles.GD;
% usePoints is an array of logicals that has a 1 at the index of a point we want to use, 0 at a point we won't.
% When you click useSelectedPointCheckbox, it toggles the value of this
% array for whatever index the slider was set to. (See the callback for the
% checkbox)
handles.usePoints = ones(1,numel(handles.fullBDES));

%Set up the slider, checkbox, and labels.
set(handles.dataSlider,'Min',1);
set(handles.dataSlider,'Max',numel(handles.fullBDES));
set(handles.dataSlider,'SliderStep',[1/(numel(handles.fullBDES)-1) 1/(numel(handles.fullBDES)-1)]);
set(handles.dataSlider,'Value',1);
set(handles.selectedPointLabel,'String','1');
set(handles.useSelectedPointCheckbox,'Value',get(handles.useSelectedPointCheckbox,'Max'));
%reveal the dataSlider stuff!
setDataSliderVisibility(handles,'on');
    

%Restore OTR Filters
if handles.have_calibration
    filterRestore = handles.filterRestore.(HS);
    filterStatPV = {handles.modesPVs.carbonFilter1.(HS), handles.modesPVs.carbonFilter2.(HS)};
    commandString = strrep(filterRestore,'INSERTED', 'IN_CMD');
    commandString = strrep(commandString, 'RETRACTED', 'OUT_CMD');
    commandPV{1} = strrep(filterStatPV{1}, 'POS_STATE_RBV', commandString{1} );
    commandPV{2} = strrep(filterStatPV{2}, 'POS_STATE_RBV', commandString{2} );
    lcaPutSmart(commandPV, 1);
end

% record elapsed time
elapsed_time = toc(start_time);
%old_value = lcaGetSmart('PHYS:SYS0:1:ELOSSACQCUMUL', 0, 'double');
old_value = lcaGetSmart(handles.modesPVs.elapsedTime.(M), 0, 'double');
%lcaPutSmart('PHYS:SYS0:1:ELOSSACQCUMUL', old_value + elapsed_time);
lcaPutSmart(handles.modesPVs.elapsedTime.(M), old_value + elapsed_time);

guidata(hObject,handles);

if ~everythingok
    % Okay, recovered things. Time to barf out previous error.
    if strcmp(ex.identifier,'labca:timedOut')
        errordlg('Timed out getting data from some/all GDET or KMON PVs!','E Loss Fail');
    else
        errordlg('E Loss scan failed! See Matlab terminal for error messages.')
    end
    rethrow(ex)
end



function setDataSliderVisibility(handles,state)
set(handles.dataSlider,'Visible',state);
set(handles.dataSliderLabel,'Visible',state);
set(handles.selectedPointLabel,'Visible',state);
set(handles.useSelectedPointCheckbox,'Visible',state);




function handles = plot_Eloss(Elog_fig, hObject,handles)
handles.Eloss_plots = 1;
handles.show_fee = get(handles.SHOW_FEE,'Value');
persistent pltH  pltH_show_fee pltH1;

if ~isfield(handles, 'Eloss_scan_index'), handles.Eloss_scan_index = handles.npoints; end
if handles.Eloss_scan_index == 1 || handles.Eloss_scan_index == handles.npoints,
    fullPlot = 1;
else
    fullPlot = 0;
end

if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(1,1,1);
else
  ax1 = handles.AXES1;
end
% axes(ax1);
% cla(ax1, 'reset');
iOK = intersect(find(handles.dE), find(~isnan(handles.dE)));
gOK = intersect(iOK, find(~isnan(handles.GD)));
if length(iOK) > 4
%         xf = linspace(min(handles.BDES(iOK)), max(handles.BDES(iOK)));
  if any(handles.ddE(iOK)==0)
%    [q,dq,xf,yf] = gauss_plot(handles.BDES(iOK),handles.dE(iOK));                   % fit Gaussian without error bars (some are zero)

    [par, yFit, parstd, yFitStd, mse, pcov, rfe] = ...
        util_gaussFit(handles.BDES(iOK), handles.dE(iOK), 1, 0, handles.ddE(iOK), 0);
  else  
    [par, yFit, parstd, yFitStd, mse, pcov, rfe] = ...
        util_gaussFit(handles.BDES(iOK), handles.dE(iOK), 1, 0);
%    [q,dq,xf,yf] = gauss_plot(handles.BDES(iOK),handles.dE(iOK),handles.ddE(iOK));  % fit Gaussian with error bars
  end  
    q = circshift(par, [1 1])';
    dq = circshift(parstd, [1 1])';
    xf = linspace(min(handles.BDES(iOK)), max(handles.BDES(iOK)));
    yf = par(1) .* exp(-(xf-par(2)).^2./2./par(3).^2) + par(4);
  
  handles.offs = q(1);
else
  q  = [0 0 0 0];   % no good fit yet
  dq = [0 0 0 0];
  xf = 0;
  yf = 0;
  handles.offs = mean(handles.dE(iOK));
end
handles.Eloss  =  q(2);
handles.dEloss = dq(2);
if fullPlot
    axes(ax1); 
    cla(ax1, 'reset');
    errorbar(handles.BDES(iOK),handles.dE(iOK)-handles.offs,handles.ddE(iOK),'ro','MarkerFaceColor','red','MarkerSize',7)
    hold on
    pltH = plot(xf,yf-handles.offs,'b-');
    pltH1 = plot(handles.BDES(iOK),handles.dE(iOK)-handles.offs, 'ro', 'MarkerFaceColor','red','MarkerSize',5);
else
    set(pltH,'XData', xf, 'YData', yf-handles.offs)
    set(pltH1,'XData', handles.BDES(iOK), 'YData', handles.dE(iOK)-handles.offs);
end


xlabel([handles.XCOR_PV ' (kG-m)'])
ylabel('FEL Energy Loss (MeV)')
handles.xray_energy = q(2)*handles.charge;
handles.GD_Eloss    = handles.GD/handles.charge;
handles.dGD_Eloss   = handles.dGD/handles.charge;
if handles.show_fee
    if fullPlot
        plot_bars(handles.BDES(gOK),handles.GD_Eloss(gOK,handles.idet),handles.dGD_Eloss(gOK,handles.idet),'g.','c')
        pltH_show_fee = plot(handles.BDES(gOK),handles.GD_Eloss(gOK,handles.idet),'g.');
    else
        set(pltH_show_fee,'XData', handles.BDES(gOK), 'YData', handles.GD_Eloss(gOK,handles.idet))
    end
end
try
handles.dE_Gauss = q(2)*gauss(handles.BDES(gOK),q(3),q(4))*q(4)*sqrt(2*pi);
catch
    dbstack
    keyboard
end
if (length(iOK) > 1) && (length(gOK) > 1)
  [maxE ,imax ] = max(handles.dE_Gauss);
  [minEl,iminl] = min(handles.BDES(gOK));
  [minEr,iminr] = max(handles.BDES(gOK));
  ii = [imax iminl iminr];
% [cal,dcal] = plot_polyfit(handles.dE_Gauss,handles.GD_Eloss(iOK,handles.idet),handles.dGD_Eloss(iOK,handles.idet),1,'E-loss','Gas-Det','MeV','MeV',1); % no plot
  err=handles.dGD_Eloss(gOK(ii),handles.idet);if ~all(err), err(:)=1;end
 [cal,dcal] = plot_polyfit(handles.dE_Gauss(ii),handles.GD_Eloss(gOK(ii),handles.idet),err,1,'E-loss','Gas-Det','MeV','MeV',1); % no plot
%*  [cal,dcal] = plot_polyfit(handles.dE_Gauss(ii),handles.GD_Eloss(iOK(ii),handles.idet),handles.dGD_Eloss(iOK(ii),handles.idet),[0 1],'E-loss','Gas-Det','MeV','MeV',1); % no plot
  if handles.show_fee && fullPlot 
      plot(handles.BDES(gOK(ii)),handles.GD_Eloss(gOK(ii),handles.idet),'kv')
  end
  handles.GD_offset(handles.idet)  =  cal(1);
  handles.GD_doffset(handles.idet) = dcal(1);
%*  handles.GD_offset(handles.idet)  = 0;
%*  handles.GD_doffset(handles.idet) = 0;
  handles.GD_slope(handles.idet)   =  cal(2);
  handles.GD_dslope(handles.idet)  = dcal(2);
%*  handles.GD_slope(handles.idet)   =  cal(1);
%*  handles.GD_dslope(handles.idet)  = dcal(1);
else
  handles.GD_offset(handles.idet)  =  0;
  handles.GD_doffset(handles.idet) =  0;
  handles.GD_slope(handles.idet)   =  0;
  handles.GD_dslope(handles.idet)  =  0;
end
title([sprintf('E-Loss=%4.2f+-%4.2f MeV (%4.2f mJ), ',q(2), ...
    dq(2),handles.xray_energy) handles.time sprintf(' (%5.2f GeV)',handles.E0), ...
    sprintf(' %s', handles.lclsMode)])

switch handles.lclsMode; 
    case 'CUHXR', Ephoton = lcaGetSmart('SIOC:SYS0:ML00:AO627');
    case 'CUSXR', Ephoton = lcaGetSmart('SIOC:SYS0:ML00:AO628');
end

%photonEnergyeV([HS 'XR'],1);
%Ephoton = 4.13566733E-15*2.99792458E8/(0.03/2/(handles.E0/511E-6)^2*(1 + (undulatorK^2)/2));
switch handles.lclsMode
    case 'CUHXR', undulatorK = lcaGetSmart('USEG:UNDH:2450:KAct');
    case 'CUSXR', undulatorK = lcaGetSmart('USEG:UNDS:2650:KAct');
end

if ~isempty(iOK)
  handles.mean_Ipk = mean(handles.Ipk(iOK));
else
  handles.mean_Ipk = 0;
end
if ~Elog_fig
  handles.plot_scale = axis;    % E-log call uses original scale set when first plotted
else
  axis(handles.plot_scale)
end
dx = handles.plot_scale(2) - handles.plot_scale(1);
dy = handles.plot_scale(4) - handles.plot_scale(3);
handles.Nphotons = q(2)*handles.charge*1E-3/1.602E-19/Ephoton;
if handles.Eloss_scan_index == handles.npoints
    text(handles.plot_scale(1)+dx/40,handles.plot_scale(4)-1*dy/18,sprintf('N-photons = %4.2e',handles.Nphotons))
    text(handles.plot_scale(1)+dx/40,handles.plot_scale(4)-2*dy/18,sprintf('E-photon  = %4.2f keV',Ephoton/1E3))
    text(handles.plot_scale(1)+dx/40,handles.plot_scale(4)-3*dy/18,sprintf('<Ipk> = %4.0f A',handles.mean_Ipk))
    text(handles.plot_scale(1)+dx/40,handles.plot_scale(4)-4*dy/18,sprintf('K = %4.2f',undulatorK))
    if handles.show_fee
        text(handles.plot_scale(1)+0.62*dx,handles.plot_scale(4)-1*dy/18,handles.detector_PVs(handles.idet,1),'Color','cyan')
        text(handles.plot_scale(1)+0.62*dx,handles.plot_scale(4)-2*dy/18,sprintf('slope=%5.2f+-%4.2f',handles.GD_slope(handles.idet),handles.GD_dslope(handles.idet)),'Color','cyan')
        text(handles.plot_scale(1)+0.62*dx,handles.plot_scale(4)-3*dy/18,sprintf('offset=%5.2f+-%4.2f MeV',handles.GD_offset(handles.idet),handles.GD_doffset(handles.idet)),'Color','cyan')
    end
end
enhance_nofocus;
handles.Ephoton = Ephoton;
handles.undulatorK = undulatorK;
hold off

function read_assoc_PVs(hObject, handles)
handles.NdetCols = length(handles.detector_PVs(1,:));
for j = 1:(handles.NdetCols-4)
  handles.assoc_values(j,:) = lcaGetSmart(handles.detector_PVs(:,j+4));
end
guidata(hObject,handles);



function ELOG_Callback(hObject, eventdata, handles)
if handles.have_Eloss
    fig=1;
    plot_Eloss(fig,hObject,handles);
    switch handles.lclsMode
        case 'CUHXR', set(fig, 'Color', [202 214 230]/255)
        case 'CUSXR', set(fig, 'Color', [230 184 179]/255)
    end
    set(fig,'InvertHardcopy', 'off')     
    hAxes=findobj(fig,'Type','axes');
    util_printLog(fig,'title','FEL Energy Loss Scan','text',get(get(hAxes(1),'Title'),'String'));
    dataSave(hObject,handles,0);
end



function display_message(handles,msgstr)

gui_statusDisp(handles.MSG,msgstr);
drawnow



function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
guidata(hObject,handles);

function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NPOINTS_Callback(hObject, eventdata, handles)
handles.npoints = str2double(get(hObject,'String'));
guidata(hObject,handles);

function NPOINTS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MAXBDES_Callback(hObject, eventdata, handles)
BMAX  = lcaGetSmart(strcat(handles.XCOR_PV,':BMAX'));
maxbdes = str2double(get(hObject,'String'));
%if abs(maxbdes)>BMAX || maxbdes<0.0005
%if abs(maxbdes)>BMAX || maxbdes<0.0001
%  set(hObject,'String','0.005')
%  return
%end
handles.maxbdes = str2double(get(hObject,'String'));
guidata(hObject,handles);

function MAXBDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ELOSSPERAMP_Callback(hObject, eventdata, handles)
handles.elossperamp = str2double(get(hObject,'String'));
M = handles.lclsMode;
if ~handles.fakedata
    %  lcaPutSmart('PHYS:SYS0:1:ELOSSPERIPK',handles.elossperamp);
    lcaPutSmart(handles.modesPVs.elossperamp.(M),handles.elossperamp);
end
guidata(hObject,handles);

function ELOSSPERAMP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XCOR_Callback(hObject, eventdata, handles)
xcor = get(hObject,'Value');
handles.XCOR_PV = ['XCOR:UND1:' sprintf('%1.0f',xcor) '80'];
guidata(hObject,handles);

function XCOR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

und_xcors =  strrep({model_nameConvert('XCOR', 'EPICS', 'UNDH')},'XCOR:', ''); 
und_xcors = und_xcors{:};
set(hObject,'String', und_xcors)



function CALIBRATE_Callback(hObject, eventdata, handles)
M = handles.lclsMode; 
HS = M(3);
start_time = tic;

%TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
TDUND = lcaGetSmart( handles.modesPVs.tdund.(HS) );
if strcmp(TDUND,'IN')
  display_message(handles,'TDUND is IN - calibration aborted.')
  warndlg('TDUND is IN - no beam - calibration aborted.','Stopper is IN')
  if ~handles.fakedata
    return  %forInvasive
  end
end

%OTR carbon filter check
if ~handles.fakedata
    filterStatPV = {handles.modesPVs.carbonFilter1.(HS), handles.modesPVs.carbonFilter2.(HS)};
    filterStatus = lcaGetSmart(filterStatPV);
    
    switch handles.lclsMode
        case 'CUHXR'
            electronEnergy = lcaGetSmart(handles.modesPVs.E0.H);
            electronPeakI = lcaGetSmart('FBCK:FB04:LG01:S5DES');
            
            if electronEnergy > 12 && electronPeakI > 3000
                filterDes = {'INSERTED'; 'INSERTED'};
            else
                filterDes = {'RETRACTED'; 'RETRACTED'};
            end
            filterRestore = filterDes;
        case 'CUSXR'
            filterDes = {'RETRACTED'; 'RETRACTED'};
            filterRestore = filterStatus;
    end
    handles.filterRestore.(HS) = filterRestore;
    commandString = strrep(filterDes,'INSERTED', 'IN_CMD');
    commandString = strrep(commandString, 'RETRACTED', 'OUT_CMD');
    
    if any(~strcmp(filterStatus,filterDes))
        display_message(handles, 'OTR filters status missmatch. Correcting...')
        commandPV{1} = strrep(filterStatPV{1}, 'POS_STATE_RBV', commandString{1} );
        commandPV{2} = strrep(filterStatPV{2}, 'POS_STATE_RBV', commandString{2} );
        lcaPutSmart(commandPV, 1);
        for weWait =1:10 %5 seconds to actuate
            pause(0.5)
            filterStatus = lcaGetSmart(filterStatPV);
            if all(strcmp(filterStatus, filterDes)), break, end
        end
        if weWait ==14,
            warndlg('Trouble controlling OTR RTDS filters.  Will continue scan.')
            display_message(handles,'OTR RTDS filter control failed (?) Continuing...')
        end      
    end
end


set(hObject,'BackgroundColor','white')
drawnow
fdbk_state = lcaGetSmart(handles.fdbkList,0,'double');  
%BDES0 = lcaGetSmart(strcat(handles.XCOR_PV,':BDES')); 
if ~handles.fakedata
  Sol = undulatorClosedBumpSolver(handles); 
  handles.XCOR_PV =  Sol.CorrPV{1};
  lcaPutSmart(handles.fdbkList,0);
  display_message(handles,'Undulator feedback disabled');
  pause(0.5)
  lcaPut(Sol.CorrPV, Sol.KickTableForgetClosing(:,1)); 
  pause(handles.delay)
end
%display_message(handles,['Set ' handles.XCOR_PV '=' sprintf('%8.5f kG-m',-handles.maxbdes)])
display_message(handles, 'Set multi-corrector closed bump')

xtcavstate=control_klysStatGet(['KLYS:DMP' HS ':1']); 
if xtcavstate == 1 && get(handles.deactXTCAV_box,'Value')
     control_klysStatSet(['KLYS:DMP' HS ':1'],0); 
     display_message(handles,'Turning off XTCAV');
     pause(3);    
 end

if handles.init==0           % if we have not yet initialized the ref orbit or gotten the model...
  IN_struc.initialize = 1;
  IN_struc.navg = 1;
  IN_struc.Loss_per_Ipk = 0;
  handles.dEj  = zeros(size(1,handles.ncal));
  handles.Ipkj = zeros(size(1,handles.ncal));
  set(hObject,'String','init...')
  drawnow
  OUT_struc = DL2toDumpEnergyLoss(IN_struc,handles.lclsMode);
end
handles.init = 1;           % remember that we have initialized the ref orbit and gotten the model

IN_struc.initialize = 0;
IN_struc.navg = 1;
IN_struc.Loss_per_Ipk = 0;
handles.dEj  = zeros(size(1,handles.ncal));
handles.Ipkj = zeros(size(1,handles.ncal));
for jj = 1:handles.ncal
  set(hObject,'String',sprintf('%2.0f...',jj))
  OUT_struc = DL2toDumpEnergyLoss(IN_struc,handles.lclsMode);
  handles.dEj(jj)  = OUT_struc.dE;
%  handles.ddEj(jj) = OUT_struc.ddE;
  handles.Ipkj(jj) = OUT_struc.Ipk;
end

handles.time = datestr(now);
handles = plot_calibration(0,hObject,handles);
handles.have_calibration = 1;
handles.have_Eloss = 0;
handles.have_HeaterData = 0;
display_message(handles,'Restore multi-corrector closed bump')
if ~handles.fakedata  
  lcaPut(Sol.CorrPV, Sol.RestoreDest)
  pause(handles.delay)
  outoftol = sum(check_magnet(Sol.CorrPV));
  if outoftol
    trim_magnet(Sol.CorrPV,Sol.RestoreDest,'T');
  end
  display_message(handles,['Restoring feedbacks to ' num2str(fdbk_state')]);
  lcaPutSmart(handles.fdbkList,fdbk_state);
end
 if xtcavstate == 1 && get(handles.deactXTCAV_box,'Value')
    control_klysStatSet(['KLYS:DMP' HS ':1'],1);                                          
    display_message(handles,'Turning on XTCAV'); 
 end

set(hObject,'BackgroundColor',[255 180 0]/255)
set(hObject,'String','Calibrate')
drawnow
yn = questdlg(sprintf('Old slope is %7.4f and new slope is %7.4f MeV/A.  Do you want to update the slope?',handles.elossperamp,handles.slope),'UPDATE CALIBRATION?');
if strcmp(yn,'Yes')
  if ~handles.fakedata
    lcaPutSmart(handles.modesPVs.elossperamp.(M),handles.slope);
    lcaPutSmart(handles.modesPVs.mean_Ipk0.(M),handles.mean_Ipk0);
    set(handles.IPK0,'String',handles.mean_Ipk0)
    
    %Restore OTR Filters
    commandString = strrep(filterRestore,'INSERTED', 'IN_CMD');
    commandString = strrep(commandString, 'RETRACTED', 'OUT_CMD');
    commandPV{1} = strrep(filterStatPV{1}, 'POS_STATE_RBV', commandString{1} );
    commandPV{2} = strrep(filterStatPV{2}, 'POS_STATE_RBV', commandString{2} );
    lcaPutSmart(commandPV, 1);
  end
  
  handles.elossperamp = handles.slope;
  set(handles.ELOSSPERAMP,'String',sprintf('%6.4f',handles.elossperamp));
end



% record elapsed time
elapsed_time = toc(start_time);
old_value = lcaGetSmart(handles.modesPVs.calCumul.(M), 0, 'double');
lcaPutSmart(handles.modesPVs.calCumul.(M), old_value + elapsed_time);

display_message(handles,'Calibration done')
guidata(hObject,handles);



function handles = plot_calibration(Elog_fig,hObject,handles)

lclsMode = handles.lclsMode;
IpkSP = lcaGetSmart(handles.modesPVs.IpkSetPointPV.(lclsMode));
if strcmp(lclsMode,'CUSXR') %CU_SXR is an offset for now tags: TODO DUALENERGY
    IpkSP = lcaGetSmart(handles.modesPVs.IpkSetPointPV.CUHXR) + lcaGetSmart(handles.modesPVs.IpkSetPointPV.(lclsMode));
end

sigmaCut = str2double(get(handles.sigmaCutEdit,'String'));
IpkStd = util_stdNan(handles.Ipkj);
keepI = (handles.Ipkj > (IpkSP - sigmaCut*IpkStd)) & (handles.Ipkj < (IpkSP + sigmaCut*IpkStd));

if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(1,1,1);
else
  ax1 = handles.AXES1;
end
axes(ax1)
plot(handles.Ipkj(keepI),handles.dEj(keepI),'dg','MarkerFaceColor','green','MarkerSize',5)
[q,dq,xf,yf,chisq,V] = plot_polyfit(handles.Ipkj(keepI),handles.dEj(keepI),1,1,'','','','',1);
handles.slope  =  q(2);
handles.dslope = dq(2);
handles.mean_Ipk0 = mean(handles.Ipkj(keepI));
xx = linspace(min(handles.Ipkj(keepI)),max(handles.Ipkj(keepI)),100);
xxs = sort(xx);
yy = q(1) + handles.slope*xxs;
hold on
plot(xx,yy,'-b','LineWidth',2);
ver_line(handles.mean_Ipk0,'c:')
xlabel('BC2 Peak Current (A)')
ylabel('Wake Energy Loss (MeV)')
title([sprintf('slope=%5.2e+-%4.2e MeV/A, ',handles.slope,handles.dslope) handles.time sprintf(' (%5.2f GeV)',handles.E0)])
enhance_plot('times',16,2,5)
hold off



function NCAL_Callback(hObject, eventdata, handles)
handles.ncal = str2double(get(hObject,'String'));
guidata(hObject,handles);

function NCAL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ELOG_CAL_Callback(hObject, eventdata, handles)
if handles.have_calibration
    fig=1;
    plot_calibration(fig,hObject,handles);
    hAxes=findobj(fig,'Type','axes');
    util_printLog(fig,'title','FEL Energy Loss Calibration','text',get(get(hAxes(1),'Title'),'String'));
    dataSave(hObject,handles,0);
end


function handles=DETS_Callback(hObject, eventdata, handles)
handles.idet = get(hObject,'Value');
if handles.have_Eloss
  if handles.Eloss_plots
    handles = plot_Eloss(0,hObject,handles);
  else
    handles = plot_linear_fit(0,hObject,handles);
  end
end
set(handles.CAL_TIME,'String',handles.cal_time(handles.idet,:))
if handles.cal_done(handles.idet)
  set(handles.CAL_DET,'Enable','off')
  set(handles.Undo_button,'Enable','on')
else
  set(handles.CAL_DET,'Enable','on')
  set(handles.Undo_button,'Enable','off')
end
guidata(hObject,handles);

function DETS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function handles=CAL_DET_Callback(hObject, eventdata, handles)
if ~handles.have_Eloss
  return
end
set(handles.CAL_DET,'BackgroundColor','white')
set(handles.CAL_DET,'String','wait...')
drawnow
if handles.idet < 3
  trans = 1;                        % attenuator transmission is always 1 for gas detector #1
else
  trans = handles.atten_trans_at_cal_time;
  if trans == -1
      warndlg('Attenuation factor was not properly recorded at scan time.  Using current value instead.');
      trans = lcaGetSmart(handles.atten_PV);
  end
  % trans = lcaGetSmart(handles.atten_PV);    % read expected gas + solid transmission factor (0 < trans <= 1)
end
if trans < 0.90
  ynt = questdlg(sprintf('Solid + gas attenuator transmission is < 90%% (= %4.1f%%).  This questionable factor will be used in the calibration.  Do you want to continue?',trans*100),'ATTENUATION IS SIGNIFICANT?');
else
  ynt = 'Yes';
end
if ~strcmp(ynt,'Yes')
  set(handles.CAL_DET,'String','Calib. Detector')
  set(handles.CAL_DET,'BackgroundColor','yellow')
  return
end
handles.old_slope  = lcaGetSmart(handles.detector_PVs(handles.idet,2));     % in mJ/raw
handles.old_offset = lcaGetSmart(handles.detector_PVs(handles.idet,3));     % in mJ
new_slope  = trans*handles.old_slope/handles.GD_slope(handles.idet);        % simply scale old slope (& include transmission beyond Gas-Det #1)
new_offset = handles.old_offset - handles.GD_offset(handles.idet)/handles.GD_slope(handles.idet)*handles.charge; % convert MeV offset to mJ offset with charge
yn = questdlg([handles.detector_PVs(handles.idet,1) sprintf('Old slope & offset are %7.4e and %7.4e, while new slope & offset are %7.4e and %7.4e.  Do you really want to calibrate?',handles.old_slope,handles.old_offset,new_slope,new_offset)],'UPDATE CALIBRATION?');
if strcmp(yn,'Yes')
  handles.cal_time{handles.idet} = datestr(now);
  set(handles.CAL_TIME,'String',handles.cal_time(handles.idet,:))
  disp(sprintf('Old slope  (%s) = %7.4e',cell2mat(handles.detector_PVs(handles.idet,2)),handles.old_slope))
  disp(sprintf('Old offset (%s) = %7.4e',cell2mat(handles.detector_PVs(handles.idet,3)),handles.old_offset))
  disp(sprintf('New slope  (%s) = %7.4e',cell2mat(handles.detector_PVs(handles.idet,2)),new_slope))
  disp(sprintf('New offset (%s) = %7.4e',cell2mat(handles.detector_PVs(handles.idet,3)),new_offset))
  if isfinite(new_slope) && isfinite(new_offset)
    if ~handles.fakedata
      lcaPutSmart(handles.detector_PVs(handles.idet,2),new_slope)
      lcaPutSmart(handles.detector_PVs(handles.idet,3),new_offset)
      lcaPutSmart(handles.detector_PVs(handles.idet,4),handles.cal_time(handles.idet,:))
      % Next line for MPS. Do not change without consulting MPS expert
      lcaPutSmart(handles.mpsCalDone_PVs(handles.idet),'1')
      set(handles.MSG,'String','Calibration done.')
    end
  else
    warndlg('New slope and/or new offset values are "NaN" or "Inf".  No calibration done.','BAD CALIBRATION VALUES')
    set(handles.MSG,'String','No calibration done.')
  end
  handles.cal_done(handles.idet) = 1;   % mark as calibrated so two ca;s are not possible
  set(handles.CAL_DET,'Enable','off')
  set(handles.Undo_button,'Enable','on')
end
set(handles.CAL_DET,'String','Calib. Detector')
set(handles.CAL_DET,'BackgroundColor','yellow')
guidata(hObject,handles);

% --- Executes on button press in CAL_ALL_DET.
function handles=CAL_ALL_DET_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_ALL_DET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for idx = 1:min(handles.Ndet,4)
    handles.idet=idx;
    set (handles.DETS,'Value',idx);
    guidata(hObject,handles);
    handles=DETS_Callback(handles.DETS, eventdata, handles);
    guidata(hObject,handles);
    handles=CAL_DET_Callback(handles.CAL_DET, eventdata, handles);
    guidata(hObject,handles);
end


function ELOG_DET_CAL_Callback(hObject, eventdata, handles)
if handles.have_Eloss
    fig=1;
    plot_linear_fit(fig,hObject,handles);
    hAxes=findobj(fig,'Type','axes');
    util_printLog(fig,'title','FEL Gas Detector Calibration','text',get(get(hAxes(1),'Title'),'String'));
    dataSave(hObject,handles,0);
end


function PLOT_LIN_FIT_Callback(hObject, eventdata, handles)
if handles.have_Eloss
  handles.Eloss_plots = 0;
  handles = plot_linear_fit(0,hObject,handles);
  guidata(hObject,handles);
end


% --- Executes on button press in Undo_button.
function Undo_button_Callback(hObject, eventdata, handles)

handles.cal_time{handles.idet} = datestr(now);
set(handles.CAL_TIME,'String',handles.cal_time(handles.idet,:));
lcaPutSmart(handles.detector_PVs(handles.idet,2),handles.old_slope);
lcaPutSmart(handles.detector_PVs(handles.idet,3),handles.old_offset);
lcaPutSmart(handles.detector_PVs(handles.idet,4),handles.cal_time(handles.idet,:));
% Next line for MPS. Do not change without consulting MPS expert
lcaPutSmart(handles.mpsCalUndone_PVs(handles.idet),'1')
set(handles.MSG,'String','Calibration Undone.');
handles.cal_done(handles.idet) = 0;   % mark as uncalibrated so two undo's are not possible
set(handles.CAL_DET,'Enable','on');
set(handles.Undo_button,'Enable','off');


function handles = plot_linear_fit(Elog_fig,hObject,handles)
if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(1,1,1);
else
  ax1 = handles.AXES1;
end
axes(ax1)
try % J. Rzepiela, 12/10/10
    iOK = intersect(find(handles.dE), find(~isnan(handles.dE)));
    gOK = intersect(iOK, find(~isnan(handles.GD)));
    errorbar(handles.dE_Gauss,handles.GD_Eloss(gOK,handles.idet),handles.dGD_Eloss(gOK,handles.idet),'^b','MarkerFaceColor','blue','MarkerSize',7)
catch
    str=sprintf('Vector length mismatch when plotting.\n');
    disp(str)
    if isfield(handles, 'dE_Gauss'), X=size(handles.dE_Gauss), end
    if isfield(handles, 'GD_Eloss'), Y=size(handles.GD_Eloss(:,handles.idet)), end
    if isfield(handles, 'dGD_Eloss'),E=size(handles.dGD_Eloss(:,handles.idet)),end
end


% Change to fit only 2 points, to prevent stupid fits 7/22/2011 nate
% [maxE ,imax ] = max(handles.dE_Gauss);
% [minEl,iminl] = min(handles.BDES(gOK));
% [minEr,iminr] = max(handles.BDES(gOK));
% ii = [imax iminl iminr];
[maxE ,imax ] = max(handles.dE_Gauss);
[minE, imin ] = min(handles.dE_Gauss);

if handles.fitoffset
    ii = [imax imin];
else
    % Change to fit only the max, to prevent stupid fits 7/22/2011 nate
    ii = imax;
end

hold on
plot(handles.dE_Gauss((ii)),handles.GD_Eloss(gOK(ii),handles.idet),'or')

xx = linspace(min(handles.dE-handles.offs),max(handles.dE-handles.offs),100);
xxs = sort(xx);

err=handles.dGD_Eloss(gOK(ii),handles.idet);if ~all(err), err(:)=1;end
if handles.fitoffset
    %[cal,dcal] = plot_polyfit(handles.dE_Gauss,handles.GD_Eloss(:,handles.idet),handles.dGD_Eloss(:,handles.idet),1,'','','','',1);
    [cal,dcal] = plot_polyfit(handles.dE_Gauss(ii),handles.GD_Eloss(gOK(ii),handles.idet),err,1,'','','','',1);
    handles.GD_offset(handles.idet)  =  cal(1);
    handles.GD_doffset(handles.idet) = dcal(1);
    handles.GD_slope(handles.idet)   =  cal(2);
    handles.GD_dslope(handles.idet)  = dcal(2);
    yy = cal(1) + handles.GD_slope(handles.idet)*xxs;
else
    [cal,dcal] = plot_polyfit(handles.dE_Gauss(ii),handles.GD_Eloss(gOK(ii),handles.idet),err,[0 1],'','','','',1);
    handles.GD_offset(handles.idet)  = 0;
    handles.GD_doffset(handles.idet) = 0;
    handles.GD_slope(handles.idet)   =  cal(1);
    handles.GD_dslope(handles.idet)  = dcal(1);
    yy = 0 + handles.GD_slope(handles.idet)*xxs;
end

%hold on
plot(xx,yy,'-c','LineWidth',2);
xlabel('BPM Energy Loss (MeV)')
ylabel([cell2mat(handles.detector_PVs(handles.idet)) ' Energy Loss (MeV)'])
title([sprintf('slope=%5.2e+-%4.2e, ',handles.GD_slope(handles.idet),handles.GD_dslope(handles.idet)) handles.time sprintf(' (%5.2f GeV)',handles.E0)])
if ~Elog_fig
  handles.plot_scale_fit = axis;    % E-log call uses original scale set when first plotted
else
  axis(handles.plot_scale_fit)
end
dx = handles.plot_scale_fit(2) - handles.plot_scale_fit(1);
dy = handles.plot_scale_fit(4) - handles.plot_scale_fit(3);
text(handles.plot_scale_fit(1)+dx/40,handles.plot_scale_fit(4)-1*dy/18,sprintf('slope=%5.2f+-%4.2f',handles.GD_slope(handles.idet),handles.GD_dslope(handles.idet)),'Color','cyan')
text(handles.plot_scale_fit(1)+dx/40,handles.plot_scale_fit(4)-2*dy/18,sprintf('offset=%5.2f+-%4.2f MeV',handles.GD_offset(handles.idet),handles.GD_doffset(handles.idet)),'Color','cyan')
enhance_plot('times',16,2,5)
hold off



function REPLOT_Callback(hObject, eventdata, handles)
if handles.have_Eloss
  handles.Eloss_plots = 1;
  plot_Eloss(0,hObject,handles);
  guidata(hObject,handles);
end



function SHOW_FEE_Callback(hObject, eventdata, handles)
handles.show_fee = get(hObject,'Value');
if handles.have_Eloss
  plot_Eloss(0,hObject,handles);
end
guidata(hObject,handles);



function JG_Callback(hObject, eventdata, handles)
%x = get(hObject,'Value');
%if x ==1
%  set(handles.Dave,'Visible','on')
%else
%  set(handles.Dave,'Visible','off')
%end



function checkGDetPressure(hObject, handles)


%{ 
2020
*em1l0_PMT_voltage_241          >    HVCH:FEE1:241:VoltageMeasure
*em1l01_PMT_voltage_242       >    HVCH:FEE1:242:VoltageMeasure
*em1l0_GEM_10T_pressure       >    EM1L0:GEM:GCM:41:PRESS_RBV
*em1l0_GEM_50mT_pressure   >    EM1L0:GEM:GCM:42:PRESS_RBV
*em2l0_PMT_voltage_361          >    HVCH:FEE1:361:VoltageMeasure
*em2l0_PMT_voltage_362          >    HVCH:FEE1:362:VoltageMeasure
*em2l0_GEM_10T_pressure      >    EM2L0:GEM:GCM:41:PRESS_RBV
*em2l0_GEM_50mT_pressure   >    EM2L0:GEM:GCM:42:PRESS_RBV
%}

if strmcp(handles.lclsMode,'CUHXR')
[d,energy]=control_magnetGet('BYD1');
eXray=0.82/4.3^2*energy^2;
%gpAct=lcaGetSmart(strcat('VFC:FEE1:E',{'202';'207'},':P_DES_RB'));
gpAct = lcaGetSmart({'EM1L0:GEM:GCM:41:PRESS_RBV' 'EM1L0:GEM:GCM:42:PRESS_RBV' 'EM2L0:GEM:GCM:41:PRESS_RBV' 'EM2L0:GEM:GCM:42:PRESS_RBV'});
eps=1e-10;
eXList=[0.4 1.2 1.2+eps 1.8 1.8+eps 3 3+eps 4.5-eps 4.5 8.3];
gpList=[0.02 0.02 0.03 0.03 0.05 0.05 2 2 2 2];
gpDes=interp1(eXList,gpList,eXray,'nearest');

if any(gpAct ~= gpDes)
    str=sprintf(['Gas Detector Pressures are %6.3f & %6.3f Torr\n' ...
        'They should be %6.3f Torr at %6.3f GeV'],gpAct,gpDes,energy);
    warndlg(str,'Wrong Gas Detector Pressure');
end

end

% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

listEL={'BDES' 'dE' 'ddE' 'Ipk' 'GD' 'dGD' 'dE_Gauss' 'GD_Eloss' 'dGD_Eloss' ...
        'charge' 'E0' 'lclsMode' 'Ephoton' 'Nphotons' 'undulatorK' 'xray_energy'};
listCAL={'E0' 'Ipkj' 'dEj'};
list={};
if handles.have_Eloss, list=[list listEL];end
if handles.have_calibration, list=[list listCAL];end
if isempty(list), return, end

data.name='';
data.ts=datenum(handles.time);
for j=list
    if isfield(handles,j{:})
        data.(j{:})=handles.(j{:});
    end
end

fileName=util_dataSave(data,'E_loss','',data.ts,val);
if ~ischar(fileName), return, end
% -----------------------------------------------------------
function handles = dataOpen(hObject, handles)

[data,fileName]=util_dataLoad('Open E-loss Scan');
if ~ischar(fileName), return, end

list={'BDES' 'dE' 'ddE' 'Ipk' 'GD' 'dGD' 'dE_Gauss' 'GD_Eloss' 'dGD_Eloss' ...
    'charge' 'E0' 'lclsMode' 'Ephoton' 'Nphotons' 'undulatorK' 'xray_energy' ...
    'E0' 'Ipkj' 'dEj'};

for j=list
    if isfield(data,j{:})
        handles.(j{:})=data.(j{:});
    end
end
handles.time=datestr(data.ts);
handles.have_calibration=isfield(data,'dEj');
if handles.have_calibration, handles=plot_calibration(0,hObject,handles);end
handles.have_Eloss=isfield(data,'dE');
handles.Eloss_plots=isfield(data,'dE');
if handles.have_Eloss, handles=plot_Eloss(0,hObject,handles);end
guidata(hObject,handles);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

dataSave(hObject,handles,0);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in fitoffset_box.
function fitoffset_box_Callback(hObject, eventdata, handles)

handles.fitoffset = get(handles.fitoffset_box,'Value');
guidata(hObject,handles);

function enhance_nofocus(fontname,fontsize,linewid,markersiz)
% this is like enhance_plot, but doesn't call figure() at the end.  should
% keep the thing from stealing focus every time it replots.

if (~exist('fontname')|(fontname==0))
  fontname = 'times';
end
if (~exist('fontsize')|(fontsize==0))
  fontsize = 16;
end
if (~exist('linewid')|(linewid==0))
  linewid=2;
end
if (~exist('markersiz')|(markersiz==0))
  markersiz = 8;
end

Hf=gcf;
Ha=gca;
Hx=get(Ha,'XLabel');
Hy=get(Ha,'YLabel');
Ht=get(Ha,'Title');
set(Ha,'LineWidth',.75);
set(Hx,'fontname',fontname);
set(Hx,'fontsize',fontsize);
set(Hy,'fontname',fontname);
set(Hy,'fontsize',fontsize);
set(Ha,'fontname',fontname);
set(Ha,'fontsize',fontsize);
%set(Ha,'YaxisLocation','right')
%set(Ha,'YaxisLocation','left')
set(Ht,'fontname',fontname);
set(Ht,'fontsize',fontsize);
set(Hy,'VerticalAlignment','bottom');
set(Hx,'VerticalAlignment','cap');
set(Ht,'VerticalAlignment','baseline');
Hn = get(Ha,'Children');
n = length(Hn);
if n > 0
  typ = get(Hn,'Type');
  for j = 1:n
    if strcmp('text',typ(j,:))
      set(Hn(j),'fontname',fontname);
      set(Hn(j),'fontsize',fontsize);
    end
    if strcmp('line',typ(j,:))
      set(Hn(j),'LineWidth',linewid);
      set(Hn(j),'MarkerSize',markersiz);
    end
  end
end
legh=legend;
Hn=get(legh,'Children');
n = length(Hn);
if n > 0
  typ = get(Hn,'Type');
  for j = 1:n
    if strcmp('text',typ(j,:))
      set(Hn(j),'fontname',fontname);
      set(Hn(j),'fontsize',fontsize-2);
    end
    if strcmp('line',typ(j,:))
      set(Hn(j),'LineWidth',linewid);
      set(Hn(j),'MarkerSize',markersiz);
    end
  end
end


% --- Executes on slider movement.  Whenever the slider moves, check the
% list of excluded points to keep the checkbox's state in sync with the
% list.
function dataSlider_Callback(hObject, eventdata, handles)
set(handles.selectedPointLabel,'String',get(hObject,'Value'));
if(handles.usePoints(get(hObject,'Value'))==1)
    set(handles.useSelectedPointCheckbox,'Value',get(handles.useSelectedPointCheckbox,'Max'));
else
    set(handles.useSelectedPointCheckbox,'Value',get(handles.useSelectedPointCheckbox,'Min'));
end
guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function dataSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in useSelectedPointCheckbox.  When the
% checkbox is clicked, update the list of excluded points, filter the data
% using the list, then re-calculate and re-draw the E-Loss plot.
function handles = useSelectedPointCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to useSelectedPointCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useSelectedPointCheckbox
handles.usePoints(get(handles.dataSlider,'Value')) = (get(hObject,'Value')==get(hObject,'Max'));
handles.BDES = handles.fullBDES(logical(flipdim(handles.usePoints,2)));
handles.dE = handles.fulldE(logical(flipdim(handles.usePoints,2)));
handles.ddE = handles.fullddE(logical(flipdim(handles.usePoints,2)));
handles.Ipk = handles.fullIpk(logical(flipdim(handles.usePoints,2)));
handles.GD = handles.fullGD(logical(flipdim(handles.usePoints,2)),:);
guidata(hObject,handles);
handles = plot_Eloss(0,hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in zero_offs_button.
function zero_offs_button_Callback(hObject, eventdata, handles)

pvs=handles.detector_PVs(1:min(4,end),3);
origoffset=lcaGet(pvs);
lcaPutSmart(pvs,0);
pause(.1);
offset=lcaGetSmart(pvs);
if any(offset ~= 0)
   warndlg( 'Zeroing failed' )
   lcaPutSmart(pvs,origoffset);
else
    % Next line for MPS. Do not change without consulting MPS expert
    lcaPutSmart(handles.mpsCalZero_PVs,'0')
end



% --- Executes on button press in ELOG_HEATER.
function ELOG_HEATER_Callback(hObject, eventdata, handles)
% hObject    handle to ELOG_HEATER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.have_HeaterData
    fig=2;
    plot_heaterGain(fig,hObject,handles);
    hAxes=findobj(fig,'Type','axes');
    txtStr = handles.heaterTitle;
    txtStr = sprintf('%s (%.0f pC, %.2f GeV, %.0f A, Heater at %.0f uJ )', txtStr, handles.heaterElectronCharge*1000, ...
    handles.E0, handles.mean_Ipk0,  handles.heaterPower);
    util_printLog(fig,'title','Heater Gain','text', txtStr);
    %dataSave(hObject,handles,0);
end


% --- Executes on button press in START_HEATER.
function START_HEATER_Callback(hObject, eventdata, handles)
% hObject    handle to START_HEATER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of START_HEATER
%function checkHeaterGain
%Get gas detector signal with Laser Heater ON/OFF to see how much the 
%Laser Heater contributes to the FEL performance.

%William Colocho Feb. 2013 :( or :)
handles.have_calibration = 0;
handles.have_Eloss = 0;
handles.have_HeaterData = 1;
guidata(hObject,handles);
set(hObject,'Value',~get(hObject,'Value'));
%if gui_acquireStatusSet(hObject,handles,1);return, end
set(hObject,'BackgroundColor','white')
set(hObject,'String','Init...')
drawnow

debugOn = 0;
if debugOn
    handles.fakedata =1;
else
    handles.fakedata = 0;
end


 %Heater off?
 laserHeaterShutter = lcaGetSmart('IOC:BSY0:MP01:LSHUTCTL');
 beamRate = lcaGetSmart('EVNT:SYS0:1:LCLSBEAMRATE');
 nPts = fix(str2double(get(handles.N_PULSES_edit, 'String'))); %300;
 
 if strmatch('Yes',laserHeaterShutter)    
     if beamRate < 100
         nPts = ceil(nPts * beamRate / 120);
     end
     % Get Heater ON BSA data
     display_message(handles,'Getting Heater ON BSA gas detector data...')
     set(hObject,'String','Heater ON...')
     pauseTime = nPts / beamRate;
     eDefN = eDefReserve('Laser Heater mJ check');
     if ~eDefN, warndlg('Failed to Reserve event definition. Quitting...');  return; end
     eDefS = num2str(eDefN);
     lcaPutSmart(['EDEF:SYS0:', eDefS, ':AVGCNT'], 1);
     lcaPutSmart(['EDEF:SYS0:' , eDefS, ':MEASCNT'], nPts);
     eDefOn(eDefN);
     pause(pauseTime)
     
     for waiting = 1:5
       isDone = lcaGetSmart(['EDEF:SYS0:' , eDefS, ':CTRL']);
       if strcmp(isDone, 'OFF'), break, end
       pause(1)
     end
     isDone = lcaGetSmart(['EDEF:SYS0:' , eDefS, ':CTRL']);
     if strcmp(isDone, 'ON')
         warndlg('It is taking too long to get data.  I am giving up...');
         eDefRelease(eDefN);
         return
     end
     handles.heaterPower = lcaGetSmart('LASR:IN20:475:PWR1H');
     gasDetValOn = lcaGetSmart(['GDET:FEE1:241:ENRCHST', eDefS]);
     handles.gasDetValOn = gasDetValOn(1:nPts);
     
     %Put Laser Heater shutter in and get heater OFF BSA data
     if ~debugOn
         lcaPutSmart('IOC:BSY0:MP01:LSHUTCTL',0);
         pause(1)
         laserHeaterShutter = lcaGetSmart('IOC:BSY0:MP01:LSHUTCTL');
         if strcmp(laserHeaterShutter, 'Yes')
             warndlg('Failed to insert Heater Shutter. Giving up.')
             eDefRelease(eDefN);
         end
     end
     set(hObject,'String','Heater OFF...')
     display_message(handles,'Getting Heater OFF BSA gas detector data...')
     drawnow
     eDefOn(eDefN);
     pause(pauseTime)
     for waiting = 1:5
         isDone = lcaGetSmart(['EDEF:SYS0:' , eDefS, ':CTRL']);
         if strcmp(isDone, 'OFF'), break, end
         pause(1)
     end

     isDone = lcaGetSmart(['EDEF:SYS0:' , eDefS, ':CTRL']);
     if strcmp(isDone, 'ON')
         warndlg('It is taking too long to get data.  I am giving up...');
         eDefRelease(eDefN);
         if ~debugOn
             lcaPutSmart('IOC:BSY0:MP01:LSHUTCTL',1);
         end    
         return
     end
  
     gasDetValOff = lcaGetSmart(['GDET:FEE1:241:ENRCHST', eDefS]);
     if (length(gasDetValOff) < nPts)
         errStr = ['Failed to get GDET:FEE1:241:ENRCHST', eDefS  ' I am giving up...'];
         warndlg(errStr);
         disp(errStr);
         if ~debugOn
             lcaPutSmart('IOC:BSY0:MP01:LSHUTCTL',1);
         end
         return
     end
     
     handles.gasDetValOff = gasDetValOff(1:nPts);
     eDefRelease(eDefN);
     %pause(7)
     if ~debugOn
         lcaPutSmart('IOC:BSY0:MP01:LSHUTCTL',1);
     end
 else
     warndlg({'Laser Heater Shutter is In.', 'No action taken'});
     return
 end
 
 handles.heaterElectronCharge = lcaGetSmart('SIOC:SYS0:ML00:AO470');
 handles = plot_heaterGain(0,hObject, handles, debugOn);

set(hObject,'String','Start','BackgroundColor','green')
drawnow
display_message(handles,'Heater FEL gain check done')
guidata(hObject,handles);

function handles = plot_heaterGain(Elog_fig,hObject,handles, debugOn)
M = handles.lclsMode;
if Elog_fig
    figure(Elog_fig)
    ax1 = subplot(1,1,1);
else
    ax1 = handles.AXES1;
end
axes(ax1)
onVal = util_meanNan(handles.gasDetValOn);
offVal = util_meanNan(handles.gasDetValOff);
onStd = util_stdNan(handles.gasDetValOn);
offStd = util_stdNan(handles.gasDetValOff);
if ~handles.fakedata
    %lcaPutSmart(strcat('SIOC:SYS0:ML01:AO', {'152', '153', '154', '155', '156', '157'}) , ...
    %    [onVal ; offVal; onVal-offVal; onStd; offStd; onVal/offVal]);
    lcaPutSmart({handles.modesPVs.heaterOn.(M); ...
                 handles.modesPVs.heaterOff.(M) ; ...
                 handles.modesPVs.heaterGain.(M)}, [onVal ; offVal; onVal-offVal]);
                 
                 
end
nPts = fix(str2double(get(handles.N_PULSES_edit, 'String'))); %300;
n = fix(nPts/10);

[nOn, xOn] = hist(handles.gasDetValOn,n);
[nOff, xOff] = hist(handles.gasDetValOff,n);

plot(ax1, xOn, nOn, 'o-', xOff, nOff, '*-')

legend({sprintf('Heater ON %.2f  \\pm %.2f mJ',onVal, onStd); sprintf('Heater OFF %.2f  \\pm %.2f mJ', offVal, offStd)}, ...
    'Location','NorthWest');
xlabel('FEE 241 ENRC (mJ)')
ylabel('Histogram Counts (#)')
handles.heaterTitle = sprintf('Heater gain: %.2f / %.2f = %.1f ', ...
    onVal, offVal, onVal/offVal  ) ;
title(handles.heaterTitle )
enhance_plot('times',16,2,5)
hold off

function N_PULSES_edit_Callback(hObject, eventdata, handles)
% hObject    handle to N_PULSES_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N_PULSES_edit as text
%        str2double(get(hObject,'String')) returns contents of N_PULSES_edit as a double
%handles = plot_calibration(1,hObject,handles);
dataSave(hObject,handles,0);

a = 1;


% --- Executes during object creation, after setting all properties.
function N_PULSES_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N_PULSES_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in deactXTCAV_box.
function deactXTCAV_box_Callback(hObject, eventdata, handles)
% hObject    handle to deactXTCAV_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of deactXTCAV_box


% --- Executes on selection change in lclsMode_popupmenu.
function lclsMode_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to lclsMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lclsMode_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lclsMode_popupmenu
contents = cellstr(get(hObject,'String'));
lclsMode = upper(strrep((contents{get(hObject,'Value')}),'_',''));
handles.lclsMode = lclsMode;
handleList = [handles.uipanel4, handles.CAL_TIME, handles.text17, handles.CAL_DET, handles.ELOG_DET_CAL];
switch lclsMode
    case 'CUHXR', 
        set(handles.figure1,'Color',[202 214 230]/255)
        set(handleList, 'Visible', 'On')   
        set(handles.SHOW_FEE, 'Value', 1)
        handles.show_fee = get(handles.SHOW_FEE,'Value');
        set(handles.MAXBDES,'String', '250'); %Kick amplitude in microns
    case 'CUSXR', 
        set(handles.figure1,'Color',[230 184 179]/255)
        set(handleList, 'Visible', 'Off')
        set(handles.SHOW_FEE, 'Value', 0)  %TODO remove once we have FEES Detector PVs
        handles.show_fee = get(handles.SHOW_FEE,'Value');
        set(handles.MAXBDES,'String', '600'); %Kick amplitude in microns
    case 'SCHXR', set(handles.figure1,'Color','c') 
    case 'SCSXR', set(handles.figure1,'Color','c')
end

HS = lclsMode(3); %H or S

handles.have_Eloss = 0;
handles.have_calibration = 0;
handles.have_HeaterData = 0;
handles.plot_scale = [-handles.maxbdes handles.maxbdes -10 10];     % no real plot scale determined yet
handles.plot_scale_fit = [0 10 -10 10];     % no real plot scale determined yet
handles = pvList(handles);
handles.elossperamp = lcaGetSmart(handles.modesPVs.elossperamp.(lclsMode));
set(handles.ELOSSPERAMP,'String',sprintf('%6.4f',handles.elossperamp));
xcors = model_nameConvert('XCOR', 'EPICS', ['UND' HS]);
for ii = 1:length(xcors), und_xcors{ii} = strrep(xcors(ii,:),'XCOR:',''); end
set(handles.XCOR,'String', und_xcors)
handles.fdbkList = handles.modesPVs.fdbkList.(HS);

%Sol = undulatorClosedBumpSolver(handles)

guidata(hObject,handles);





% --- Executes during object creation, after setting all properties.
function lclsMode_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lclsMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%set(hObject,'String', {'Cu_HXR','Cu_SXR','SC_HXR','SC_SXR'}, 'Value',1)
set(hObject,'String', {'Cu_HXR','Cu_SXR'}, 'Value',1)

function handles = pvList(handles)
%Provide PV list given a machineMode, return it in handles.
str = get(handles.lclsMode_popupmenu,'String');
val = get(handles.lclsMode_popupmenu,'Value');
lclsMode = upper(strrep(str{val},'_','')) ;
und = lclsMode(3); 
handles.undulator = und;
handles.lclsMode = lclsMode;
und_xcors =  strrep({model_nameConvert('XCOR', 'EPICS', ['UND' und])},'XCOR:', ''); 
und_xcors = und_xcors{:};
set(handles.XCOR,'String', und_xcors)
xcorIndx = get(handles.XCOR,'Value');
handles.XCOR_PV = und_xcors(xcorIndx,:);

handles.modesPVs.tdund.H = 'DUMP:LTUH:970:TGT_STS';
handles.modesPVs.tdund.S = 'DUMP:LTUS:972:TGT_STS'; 
handles.modesPVs.carbonFilter1.H ='RTDSL0:MPA:01:POS_STATE_RBV';  
handles.modesPVs.carbonFilter2.H ='RTDSL0:MPA:02:POS_STATE_RBV';  
handles.modesPVs.carbonFilter1.S ='RTDSK0:MPA:01:POS_STATE_RBV';  
handles.modesPVs.carbonFilter2.S ='RTDSK0:MPA:02:POS_STATE_RBV'; 
handles.modesPVs.atten_PV.H = 'GDSA:FEE1:TATT:R_ACT'; %TODO update needed 
handles.modesPVs.atten_PV.S = ''; %TODO
handles.modesPVs.E0.H = 'BEND:DMPH:400:BDES';
handles.modesPVs.E0.S = 'BEND:DMPS:400:BDES';
handles.modesPVs.elossperamp.CUHXR = 'PHYS:SYS0:11:ELOSSPERIPK';
handles.modesPVs.elossperamp.CUSXR = 'PHYS:SYS0:14:ELOSSPERIPK';
handles.modesPVs.elossperamp.SCHXR = 'PHYS:SYS0:21:ELOSSPERIPK';
handles.modesPVs.elossperamp.SCSXR = 'PHYS:SYS0:24:ELOSSPERIPK';
handles.modesPVs.mean_Ipk0.CUHXR = 'PHYS:SYS0:11:ELOSSIPK';
handles.modesPVs.mean_Ipk0.CUSXR = 'PHYS:SYS0:14:ELOSSIPK';
handles.modesPVs.mean_Ipk0.SCHXR = 'PHYS:SYS0:21:ELOSSIPK';
handles.modesPVs.mean_Ipk0.SCSXR = 'PHYS:SYS0:24:ELOSSIPK';
handles.modesPVs.fdbkList.H = {'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE';'SIOC:SYS0:ML00:AO818';...
    'IOC:IN20:EV01:BYKIK_ABTACT'}; %  BYKIK Abort every N beam shots,to disable during meas/calib
handles.modesPVs.fdbkList.S = {'FBCK:FB04:TR02:MODE'}; %
handles.modesPVs.ltuBpm.H = 'BPMS:LTUH:880:TMITCUHBR';
handles.modesPVs.ltuBpm.S = 'BPMS:LTUS:880:TMITCUSBR';

handles.modesPVs.IpkSetPointPV.CUHXR = 'FBCK:FB04:LG01:S5DES';
handles.modesPVs.IpkSetPointPV.CUSXR = 'FBCK:FB04:LG01:S5OFFSET2';
handles.modesPVs.IpkSetPointPV.SCHXR = '';
handles.modesPVs.IpkSetPointPV.SCSXR = '';

handles.modesPVs.result.CUHXR = 'PHYS:SYS0:11:ELOSSRESULT';
handles.modesPVs.result.CUSXR = 'PHYS:SYS0:14:ELOSSRESULT';
handles.modesPVs.result.SCHXR = 'PHYS:SYS0:21:ELOSSRESULT';
handles.modesPVs.result.SCSXR = 'PHYS:SYS0:24:ELOSSRESULT';

handles.modesPVs.photons.CUHXR = 'PHYS:SYS0:11:ELOSSNPHOTONS';
handles.modesPVs.photons.CUSXR = 'PHYS:SYS0:14:ELOSSNPHOTONS';
handles.modesPVs.photons.SCHXR = 'PHYS:SYS0:21:ELOSSNPHOTONS';
handles.modesPVs.photons.SCSXR = 'PHYS:SYS0:24:ELOSSNPHOTONS';

handles.modesPVs.intensity.CUHXR = 'PHYS:SYS0:11:ELOSSINTENSITY';
handles.modesPVs.intensity.CUSXR = 'PHYS:SYS0:14:ELOSSINTENSITY';
handles.modesPVs.intensity.SCHXR = 'PHYS:SYS0:21:ELOSSINTENSITY';
handles.modesPVs.intensity.SCSXR = 'PHYS:SYS0:24:ELOSSINTENSITY';

handles.modesPVs.electronEnergy.CUHXR = 'PHYS:SYS0:11:ELOSSELENERGY';
handles.modesPVs.electronEnergy.CUSXR = 'PHYS:SYS0:14:ELOSSELENERGY';
handles.modesPVs.electronEnergy.SCHXR = 'PHYS:SYS0:21:ELOSSELENERGY';
handles.modesPVs.electronEnergy.SCSXR = 'PHYS:SYS0:24:ELOSSELENERGY';

handles.modesPVs.elapsedTime.CUHXR = 'PHYS:SYS0:11:ELOSSACQCUMUL';
handles.modesPVs.elapsedTime.CUSXR = 'PHYS:SYS0:14:ELOSSACQCUMUL';
handles.modesPVs.elapsedTime.SCHXR = 'PHYS:SYS0:21:ELOSSACQCUMUL';
handles.modesPVs.elapsedTime.SCSXR = 'PHYS:SYS0:24:ELOSSACQCUMUL';

handles.modesPVs.calCumul.CUHXR = 'PHYS:SYS0:11:ELOSSCALCUMUL';
handles.modesPVs.calCumul.CUSXR = 'PHYS:SYS0:14:ELOSSCALCUMUL';
handles.modesPVs.calCumul.SCHXR = 'PHYS:SYS0:21:ELOSSCALCUMUL';
handles.modesPVs.calCumul.SCSXR = 'PHYS:SYS0:24:ELOSSCALCUMUL';

handles.modesPVs.heaterOn.CUHXR = 'PHYS:SYS0:11:ELOSSHEATERON';
handles.modesPVs.heaterOn.CUSXR = 'PHYS:SYS0:14:ELOSSHEATERON';

handles.modesPVs.heaterOff.CUHXR = 'PHYS:SYS0:11:ELOSSHEATEROFF';
handles.modesPVs.heaterOff.CUSXR = 'PHYS:SYS0:11:ELOSSHEATEROFF';

handles.modesPVs.heaterGain.CUHXR =  'PHYS:SYS0:11:ELOSSHEATERGAIN'; 
handles.modesPVs.heaterGain.CUSXR =  'PHYS:SYS0:14:ELOSSHEATERGAIN'; 



function sigmaCutEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sigmaCutEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmaCutEdit as text
%        str2double(get(hObject,'String')) returns contents of sigmaCutEdit as a double


% --- Executes during object creation, after setting all properties.
function sigmaCutEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmaCutEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function  Sol = undulatorClosedBumpSolver(handles)
    % Sol = undulatorClosedBumpSolver(handles)
    % Computes bumps from undulatorClosedBump.m
    % TODO Allow user to change these (?)
HS = handles.undulator;
addpath ~/aal/matlab/toolbox
ULT_ScriptToLoadAllFunctions
Options.direction='X'; %'XY'
Options.xCorStart= handles.XCOR_PV; 
%options.yCorStart='';
kickAmplitude = 1E-6 * str2double(get(handles.MAXBDES,'String')); %meters
%Options.ySize = 300e-6; %meters
Options.closeBump = 1;
Options.closeAngle = 1;
switch(HS)
    case 'H'
        I = 1; 
        RelevantArea={'RFBHX13','RFBHX46'};
        handles.XCOR_PV={'XCOR:LTUH:758','XCOR:LTUH:818','XCOR:LTUH:858','XCOR:UNDH:1380'};
        %XCOR_PV={'XCOR:LTUH:758','XCOR:LTUH:818','XCOR:LTUH:858', handles.XCOR_PV};    
        Options.closeAt=['BPMS:UND' HS ':4690'];

    case 'S'
        I = 2; 
        RelevantArea={'RFBSX25','RFBSX47'};
        handles.XCOR_PV={'XCOR:LTUS:768','XCOR:LTUS:826','XCOR:LTUS:858','XCOR:UNDS:1680','XCOR:UNDS:1980','XCOR:UNDS:2180','XCOR:UNDS:2480'};
        Options.closeAt=['BPMS:UND' HS ':4790'];

        %XCOR_PV={handles.XCOR_PV};
        
    otherwise
        disp('Unknown undulator line ... ')
end %index to static 1 = CU_HXR, 2 = CU_SXR



Options.RelevantBPM = true(size(static(I).bpmList));

Options.RelevantBPMs(find(strcmp(static(I).bpmList,RelevantArea{1})) : find(strcmp(static(I).bpmList,RelevantArea{2}))) = true;


Options.MODEL_TYPE = 'TYPE=EXTANT';
Options.BEAMPATH = ['CU_' HS 'XR'];
Options.steps = handles.npoints;


for AKs=1:numel(handles.XCOR_PV)
    Options.xCorStart=handles.XCOR_PV{AKs};
    for JJ=1:2
        Options.xSize = (-1)^(JJ-1)*kickAmplitude;
        if((AKs==1) && (JJ==1))
            [Solutions{2*(AKs-1)+JJ},MODEL] = undulatorClosedBump([HS 'XR'], Options);
            Options.MODEL=MODEL;
        else
            Solutions{2*(AKs-1)+JJ} = undulatorClosedBump([HS 'XR'], Options);
        end
    end
end

%Solution Ranking

DisplacementTable=zeros(2*numel(handles.XCOR_PV),4);
MaxScanCoefficientTable=zeros(2*numel(handles.XCOR_PV),4);
DisplacementTableForget=zeros(2*numel(handles.XCOR_PV),4);
MaxScanCoefficientTableForget=zeros(2*numel(handles.XCOR_PV),4);
Max2SidesAvailableForgetClosingResidualTable=zeros(2*numel(handles.XCOR_PV),4);
%Sol(II).Max2SidesAvailableForgetClosingResidual

for JJ=1:4
    for II=numel(handles.XCOR_PV):-1:1
        for AA=1:2
            SOLDID=(II-1)*2+AA;
            DisplacementTable(SOLDID,JJ)=Solutions{SOLDID}(JJ).KickScanMaximum2SidesOrbitDisplacement;
            DisplacementTableForget(SOLDID,JJ)=Solutions{SOLDID}(JJ).KickScanForgetClosingMaximum2SidesOrbitDisplacement;
            MaxScanCoefficientTable(SOLDID,JJ)=Solutions{SOLDID}(JJ).Max2SidesAvailable;
            MaxScanCoefficientTableForget(SOLDID,JJ)=Solutions{SOLDID}(JJ).Max2SidesAvailableForgetClosing;
            Max2SidesAvailableForgetClosingResidualTable(SOLDID,JJ)=Solutions{SOLDID}(JJ).Max2SidesAvailableForgetClosingResidual;
        end
    end
end

% Try to rank actually closed scans with requested kick

MINIMO=min(min(abs(DisplacementTable - abs(kickAmplitude))));
[IA,IB]=find(abs(DisplacementTable - abs(kickAmplitude))==MINIMO);

if(MINIMO>10^-7) % not succeeded... look at something else
    Sol=Solutions{IA(1)}(IB(1)); %largest fully closed kick
    MINIMO_FORGET=min(min(abs(DisplacementTableForget - abs(kickAmplitude))));
    [KA,KB]=find(abs(DisplacementTableForget - abs(kickAmplitude))==MINIMO_FORGET);
    ClosedKickScanCoefficient=Max2SidesAvailableForgetClosingResidualTable(KA,KB);
    [~,MP]=max(ClosedKickScanCoefficient);
    SolF=Solutions{KA(MP(1))}(KB(MP(1)));
else % there are good solutions, we need to rank them, according to something else, smaller corrector number?
    for I=1:length(IA)
        CN(I) = numel(Solutions{IA(I)}(IB(I)).CorrPV);
    end
    [~,K]=min(CN);
    Sol=Solutions{IA(K(1))}(IB(K(1)));
    SolF=Solutions{IA(K(1))}(IB(K(1)));
end

disp(['Kick Requested [mm] = ',num2str(Options.xSize*1000)]);
if(MINIMO>10^-7)
    disp(['Fully Closed kick UNAVAILABLE. Max fully closed kick [mm] ',num2str(1000*Sol.KickScanMaximum2SidesOrbitDisplacement)]);
    disp(['Max partially closed kick (mm) ',num2str(1000*SolF.KickScanForgetClosingMaximum2SidesOrbitDisplacement)]);
    disp(['Closing partially closed kick would require decreasing it by (mul coefficient) ',num2str(SolF.Max2SidesAvailableForgetClosingResidual)]);
    disp('NOTE: Fully Closed kick might use a corrector that does not produced reuqested kick');
else
    disp(['Fully Closed kick AVAILABLE: closed kick [mm] ',num2str(1000*Sol.KickScanMaximum2SidesOrbitDisplacement)]);
end


%Return SolF as Sol since they will be the same if a closed bump is found.
Sol = SolF;


rmpath  ~/aal/matlab/toolbox
