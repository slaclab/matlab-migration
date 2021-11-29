function varargout = Field_Integral_GUI(varargin)
% FIELD_INTEGRAL_GUI M-file for Field_Integral_GUI.fig
%      FIELD_INTEGRAL_GUI, by itself, creates a new FIELD_INTEGRAL_GUI or raises the existing
%      singleton*.
%
%      H = FIELD_INTEGRAL_GUI returns the handle to a new FIELD_INTEGRAL_GUI or the handle to
%      the existing singleton*.
%
%      FIELD_INTEGRAL_GUI('CALLBACK',hObject,eventData,handles,...) calls
%      the local
%      function named CALLBACK in FIELD_INTEGRAL_GUI.M with the given input arguments.
%
%      FIELD_INTEGRAL_GUI('Property','Value',...) creates a new FIELD_INTEGRAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Field_Integral_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Field_Integral_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Field_Integral_GUI

% Last Modified by GUIDE v2.5 07-Oct-2012 08:36:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Field_Integral_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Field_Integral_GUI_OutputFcn, ...
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


% --- Executes just before Field_Integral_GUI is made visible.
function Field_Integral_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Field_Integral_GUI (see VARARGIN)

model_init('source','MATLAB','useBDES',1); % if ==1: uses BDES, if ==0: uses BACT
handles.fakedata = 0;
handles.girder = get(handles.GIRDERS,'Value');
handles.xmin = str2double(get(handles.XMIN,'String'));
handles.xmax = str2double(get(handles.XMAX,'String'));
handles.stepsize = str2double(get(handles.STEPSIZE,'String'));
handles.navg = str2double(get(handles.NAVG,'String'));
handles.fitmax = str2double(get(handles.FITMAX,'String'));
handles.E0  = lcaGetSmart('BEND:DMP1:400:BDES');    % beam energy [GeV]
set(handles.ENERGY,'String',sprintf('Energy=%5.2f GeV',handles.E0))
drawnow

handles.BPM_pvs   =   {
                       'BPMS:LTU1:820'
                       'BPMS:LTU1:840'
                       'BPMS:LTU1:860'
                       'BPMS:LTU1:880'
                       'BPMS:LTU1:910'
                       'BPMS:LTU1:960'
                       'BPMS:UND1:100'
                       'BPMS:UND1:190'  % this is where US01 is located (handles.BPM_ioffset=7 here)
                       'BPMS:UND1:290'
                       'BPMS:UND1:390'
                       'BPMS:UND1:490'
                       'BPMS:UND1:590'
                       'BPMS:UND1:690'
                       'BPMS:UND1:790'
                       'BPMS:UND1:890'
                       'BPMS:UND1:990'
                       'BPMS:UND1:1090'
                       'BPMS:UND1:1190'
                       'BPMS:UND1:1290'
                       'BPMS:UND1:1390'
                       'BPMS:UND1:1490'
                       'BPMS:UND1:1590'
                       'BPMS:UND1:1690'
                       'BPMS:UND1:1790'
                       'BPMS:UND1:1890'
                       'BPMS:UND1:1990'
                       'BPMS:UND1:2090'
                       'BPMS:UND1:2190'
                       'BPMS:UND1:2290'
                       'BPMS:UND1:2390'
                       'BPMS:UND1:2490'
                       'BPMS:UND1:2590'
                       'BPMS:UND1:2690'
                       'BPMS:UND1:2790'
                       'BPMS:UND1:2890'
                       'BPMS:UND1:2990'
                       'BPMS:UND1:3090'
                       'BPMS:UND1:3190'
                       'BPMS:UND1:3290'
                       'BPMS:UND1:3390'
                       'BPMS:DMP1:299'
                       'BPMS:DMP1:381'
                       'BPMS:DMP1:398'};

handles.BPM_ioffset = 7;
handles.nbpms  = length(handles.BPM_pvs);
und = ['US' num2str(handles.girder,'%02d')];
installed_PV = ['USEG:UND1:' num2str(handles.girder) '50:INSTALTNSTAT'];
installed = lcaGetSmart(installed_PV,0,'double');
if ~installed
  set(handles.START,'Enable','off')
  set(handles.START,'String','not installed')
  set(handles.INSTALLED,'String','not installed')
else
  set(handles.START,'Enable','on')
  set(handles.START,'String','START')
  set(handles.INSTALLED,'String','installed')
end
write_message('Reading model and Z-values...',handles)
handles.Z0  = model_rMatGet(und,[],{},'Z');
handles.Zs  = model_rMatGet(handles.BPM_pvs,[],{},'Z')';
R = model_rMatGet(und,handles.BPM_pvs,{'POS=END' 'POSB=MID'});
handles.R1s = permute(R(1,[1 2 3 4 6],:),[3 2 1]);
handles.R3s = permute(R(3,[1 2 3 4 6],:),[3 2 1]);
set(handles.MSG,'String','Ready...')
drawnow
handles.fdbkList={'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE'};

% Add undulator orbit correction PVs.
undPV=model_nameRegion('USEG','UND1');
handles.fdbkList=[handles.fdbkList; ...
    strcat(undPV,':BPMXCORSTAT');strcat(undPV,':BPMYCORSTAT'); ...
    strcat(undPV,':XCORCORSTAT');strcat(undPV,':YCORCORSTAT')];

% Choose default command line output for Field_Integral_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Field_Integral_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Field_Integral_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function write_message(str,handles)
disp(str)
set(handles.MSG,'String',str)
drawnow



% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN')
  set(handles.MSG,'String','TDUND is IN - scan aborted.')
  warndlg('TDUND is IN - no beam - scan aborted.','Stopper is IN')
  if ~handles.fakedata
    return
  end
end
[sys,accelerator]=getSystem();
rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);   % rep. rate [Hz]
if rate < 10
  yn = questdlg('Beam rate is <10 Hz.  Do you want to continue?','Low Beam Rate');
  if ~strcmp(yn,'Yes')
    set(handles.MSG,'Beam rate is <10 Hz - scan aborted.')
    if ~handles.fakedata
      return
    end
  end
end

Xv = segmentTranslate();
X_0 = Xv(handles.girder);
if X_0 > 16
  yn = questdlg(sprintf('Undulator %2.0f is presently set at >16 mm.  Do you want to scan it anyway?',handles.girder),'WARNING');
  if ~strcmp(yn,'Yes')
    write_message('Scan aborted by user',handles)
    return
  end
end
set(handles.START,'BackgroundColor','white')
set(handles.START,'String','wait...')
write_message(sprintf('Translation stage #%2.0f was initially set to %5.2f mm',handles.girder,X_0),handles)
handles.E0  = lcaGetSmart('BEND:DMP1:400:BDES');    % beam energy [GeV]
set(handles.ENERGY,'String',sprintf('Energy=%5.2f GeV',handles.E0))
Brho = handles.E0*1E10/2.99792458E8;    % kG-m

write_message('Switching off undulator feedback',handles)
fdbk_on = lcaGetSmart(handles.fdbkList,0,'double');     % get state of und feedback
if ~handles.fakedata
  lcaPutSmart(handles.fdbkList,0);                      % turn off und feedback
end

Lpot_PVs = strcat('USEG:UND1:',num2str(handles.girder),'50:LP',{'4';'8'},'POSCALC');
nsamples = 1 + round((handles.xmax - handles.xmin)/handles.stepsize);
handles.X = linspace(handles.xmin,handles.xmax,nsamples);
[handles.Lpot,handles.I1X,handles.I1Y,handles.dI1X,handles.dI1Y] = deal(zeros(size(handles.X)));

setGirder(handles,Lpot_PVs,0);
%{
write_message(sprintf('Setting translation stage #%2.0f to X=0',handles.girder),handles)
if ~handles.fakedata
  Xv = segmentTranslate();
  Xv(handles.girder) = 0;
  segmentTranslate(Xv);                     % move undulator to X=0 first (ref orbit here)
  segmentTranslateWait(handles.girder)      % wait until it gets there
  pause(1);                                 % wait until LVDT updates
  XX0 = mean(lcaGetSmart(Lpot_PVs));        % linear pot average [mm]
  write_message(sprintf('Translation stage #%2.0f is at %5.2f mm (Lpots)',handles.girder,XX0),handles)
  if abs(XX0-0) > 0.05
    warndlg(sprintf('Translation stage #%2.0f converge error of %5.2f mm',handles.girder,XX0-0),'CONVERGENCE WARNING')
  end
end
pause(0.5);
%}

[Xs0,Ys0,Ts,dXs,dYs,dTs,beam,abort] = read_orbit(handles.BPM_pvs,handles.navg,0.01,handles.fakedata);
if abort
  set(handles.START,'BackgroundColor','green')
  set(handles.START,'String','START')
  write_message('BPM read aborted by user',handles)
  return
end

%handles.Lpot(1)=setGirder(handles,Lpot_PVs,handles.X(1));
%{
write_message(sprintf('Setting translation stage #%2.0f to %5.2f mm',handles.girder,handles.X(1)),handles)
if ~handles.fakedata
  Xv = segmentTranslate();
  Xv(handles.girder) = handles.X(1);
  segmentTranslate(Xv);                     % move undulator to 1st position: X(1)
  segmentTranslateWait(handles.girder)      % wait until it gets there
  pause(1);                                 % wait until LVDT updates
  handles.Lpot(1) = mean(lcaGetSmart(Lpot_PVs));   % linear pot average [mm]
  write_message(sprintf('Translation stage #%2.0f is at %5.2f mm (Lpots)',handles.girder,handles.Lpot(1)),handles)
  if abs(handles.X(1)-handles.Lpot(1)) > 0.05
    warndlg(sprintf('Translation stage #%2.0f converge error of %5.2f mm',handles.girder,handles.X(1)-handles.Lpot(1)),'CONVERGENCE WARNING')
  end
end
pause(0.5);
%}

for j = 1:nsamples
  handles.Lpot(j)=setGirder(handles,Lpot_PVs,handles.X(j));
  set(handles.START,'String',sprintf('step %2.0f...',j))
  drawnow
  ibpm = (max(handles.girder+handles.BPM_ioffset-10,1)):1:(min(handles.girder+handles.BPM_ioffset+10,length(handles.BPM_pvs)));
  [Xs,Ys,Ts,dXs,dYs,dTs,beam,abort] = read_orbit(handles.BPM_pvs,handles.navg,0.01,handles.fakedata);
  if abort
    break
  end
  [Xsf,Ysf,p,dp,chisq,Q] = ...
    xy_traj_fit_kick(Xs(ibpm),1,Ys(ibpm),1,Xs0(ibpm),Ys0(ibpm),handles.R1s(ibpm,:),handles.R3s(ibpm,:),handles.Zs(ibpm),handles.Z0,[1 1 1 1 0 1 1]);	% fit trajectory inludig X & Y kicks at scanned undulator 
  handles.I1X(j)  = -p(6)*Brho*1E2;                 % Bx field integral (uT-m)
  handles.I1Y(j)  =  p(5)*Brho*1E2;                 % By field integral (uT-m)
  handles.dI1X(j) = dp(6)*Brho*1E2*sqrt(chisq);     % Bx field integral error (uT-m)
  handles.dI1Y(j) = dp(5)*Brho*1E2*sqrt(chisq);     % By field integral error (uT-m)
%  if j < nsamples
%    handles.Lpot(j+1)=setGirder(handles,Lpot_PVs,handles.X(j+1));
%{
    write_message(sprintf('Setting translation stage #%2.0f to %5.2f mm',handles.girder,handles.X(j+1)),handles)
    if ~handles.fakedata
      Xv = segmentTranslate();
      Xv(handles.girder) = handles.X(j+1);
      segmentTranslate(Xv);                     % move undulator to each position
      segmentTranslateWait(handles.girder)      % wait until it gets there
      pause(1);                                 % wait until LVDT updates
      handles.Lpot(j+1) = mean(lcaGetSmart(Lpot_PVs));
      write_message(sprintf('Translation stage #%2.0f is at %5.2f mm (Lpots)',handles.girder,handles.Lpot(j+1)),handles)
      if abs(handles.X(j+1)-handles.Lpot(j+1)) > 0.05
        warndlg(sprintf('Translation stage #%2.0f converge error of %5.2f mm',handles.girder,handles.X(j+1)-handles.Lpot(j+1)),'CONVERGENCE WARNING')
      end
    end
    pause(0.5);
%}
%  end
end

if X_0 > 16      % only ask to restore if initial setting was > 16 mm
  yn = questdlg(sprintf('The stage is at %5.2f mm.  Do you want to restore the stage to %5.2f mm?',handles.X(end),X_0),'RESTORE STAGE?');
else
  yn = 'Yes';
end
if strcmp(yn,'Yes')
  set(handles.START,'String','wait...')
  setGirder(handles,Lpot_PVs,X_0);
%{
  write_message(sprintf('Restoring translation stage #%2.0f back to %5.2f mm',handles.girder,X_0),handles);
  if ~handles.fakedata
    Xv = segmentTranslate();
    Xv(handles.girder) = X_0;
    segmentTranslate(Xv);                         % move undulator back to original position
    segmentTranslateWait(handles.girder)          % wait until it gets there
    pause(1);                                     % wait until LVDT updates
    XXN = mean(lcaGetSmart(Lpot_PVs));
    write_message(sprintf('Translation stage #%2.0f is at %5.2f mm (Lpots)',handles.girder,XXN),handles)
    if abs(XXN-X_0) > 0.05
      warndlg(sprintf('Translation stage #%2.0f converge error of %5.2f mm',handles.girder,XXN-X_0),'CONVERGENCE WARNING')
    end
  end
  pause(0.5);
%}
end

write_message('Restoring undulator feedback',handles);
if ~handles.fakedata
  lcaPutSmart(handles.fdbkList,fdbk_on);    % restore und feedback
end

sernum_PV = ['USEG:UND1:' num2str(handles.girder) '50:UNDSERIALNUM'];
handles.sernum = lcaGetSmart(sernum_PV);        % get undulator serial number...

temp_PV = ['USEG:UND1:' num2str(handles.girder) '50:MEANTEMP'];
handles.temp = lcaGetSmart(temp_PV);            % get undulator mean temperature (deg-C)...

poly_PV = ['USEG:UND1:' num2str(handles.girder) '50:POLYI1X.'];
handles.px = lcaGetSmart(strcat(poly_PV,{'B';'C';'D';'E';'F'}));     % get I1X polynomial coefficients...
%handles.px(2) = lcaGetSmart([poly_PV 'C']);
%handles.px(3) = lcaGetSmart([poly_PV 'D']);
%handles.px(4) = lcaGetSmart([poly_PV 'E']);
%handles.px(5) = lcaGetSmart([poly_PV 'F']);
poly_PV = ['USEG:UND1:' num2str(handles.girder) '50:POLYI1Y.'];
handles.py = lcaGetSmart(strcat(poly_PV,{'B';'C';'D';'E';'F'}));     % get I1Y polynomial coefficients...
%handles.py(2) = lcaGetSmart([poly_PV 'C']);
%handles.py(3) = lcaGetSmart([poly_PV 'D']);
%handles.py(4) = lcaGetSmart([poly_PV 'E']);
%handles.py(5) = lcaGetSmart([poly_PV 'F']);
handles = fit_center(hObject,handles);

set(handles.START,'BackgroundColor','green')
set(handles.START,'String','START')

handles=write_field_integrals(handles);

handles.time=get_time;
plot_field_integrals(0,hObject,handles)

write_message('Done',handles);
guidata(hObject,handles);


function Lpot = setGirder(handles, Lpot_PVs, X)

write_message(sprintf('Setting translation stage #%2.0f to %5.2f mm',handles.girder,X),handles);
if ~handles.fakedata
    Xv = segmentTranslate();
    Xv(handles.girder) = X;
    segmentTranslate(Xv);                     % move undulator to X=0 first (ref orbit here)
    segmentTranslateWait(handles.girder)              % wait until it gets there
    pause(1);                                 % wait until LVDT updates
    Lpot = mean(lcaGetSmart(Lpot_PVs));        % linear pot average [mm]
    write_message(sprintf('Translation stage #%2.0f is at %5.2f mm (Lpots)',handles.girder,Lpot),handles)
    if abs(Lpot-X) > 0.05
        warndlg(sprintf('Translation stage #%2.0f converge error of %5.2f mm',handles.girder,Lpot-X),'CONVERGENCE WARNING')
    end
else
    Lpot=0;
end
pause(0.5);


function handles = write_field_integrals(handles, flag)

% Fit measured data within fit range.
x=handles.X;use=x <= handles.fitmax;
handles.pI1X=polyfit(-x(use),handles.I1X(use),5); % Bx field integral (uT-m)
handles.pI1Y=polyfit(-x(use),handles.I1Y(use),5); % By field integral (uT-m)

%Write polynomials to PVs.
if nargin > 1 && ~flag, return, end

undPV=model_nameConvert(num2str(handles.girder,'US%02d'));
lcaPut(strcat(undPV,':POLYI1XBB_',{'F' 'E' 'D' 'C' 'B' 'A'}'),handles.pI1X');
lcaPut(strcat(undPV,':POLYI1YBB_',{'F' 'E' 'D' 'C' 'B' 'A'}'),handles.pI1Y');
pv=strcat(undPV,':TMXSVDPOS1');
lcaPut(pv,lcaGet(pv));


function plot_field_integrals(Elog_fig,hObject,handles)
if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(2,1,1);
  ax2 = subplot(2,1,2);
else
  ax1 = handles.AXES1;
  ax2 = handles.AXES2;
end

axes(ax1)
errorbar(handles.X,handles.I1X,handles.dI1X,'sb','MarkerFace','blue')
hold on
v = axis;
x = linspace(max(v(1),-6),min(6,v(2)),100);
xm = linspace(min(handles.X),handles.fitmax,100);
%x = v(1):((v(2)-v(1))/100):v(2);
I1X  = calculate_I1(hObject,handles,x,0,'x');
I1Xo = calculate_I1(hObject,handles,x,handles.X0fit,'x');
plot(x,I1X,'b-',x,I1Xo,'c--',xm,polyval(handles.pI1X,-xm),'g-.')
ylabel('I1X:  First {\itB_x} Field Integral (\muT-m)')
title([sprintf('X0 = %5.2f +- %4.2f mm, ',handles.X0fit,handles.dX0fit) handles.time])
enhance_plot('times',12,2,5)
vy = ylim;
plot([0 0],[vy(1) vy(2)],'k:','LineWidth',1)
plot([handles.X0fit handles.X0fit],[vy(1) vy(2)],'b:','LineWidth',1)
hold off

axes(ax2)
errorbar(handles.X,handles.I1Y,handles.dI1Y,'or','MarkerFace','red')
hold on
I1Y  = calculate_I1(hObject,handles,x,0,'y');
I1Yo = calculate_I1(hObject,handles,x,handles.Y0fit,'y');
plot(x,I1Y,'r-',x,I1Yo,'m--',xm,polyval(handles.pI1Y,-xm),'g-.')
xlabel(sprintf('Undulator #%1.0f X-Translation (mm) [und. ser. # %2.0f]',handles.girder,handles.sernum))
ylabel('I1Y:  First {\itB_y} Field Integral (\muT-m)')
title(sprintf('Y0 = %5.2f +- %4.2f mm, <T> = %5.2f degC',handles.Y0fit,handles.dY0fit,handles.temp))
enhance_plot('times',12,2,5)
vy = ylim;
plot([0 0],[vy(1) vy(2)],'k:','LineWidth',1)
plot([handles.Y0fit handles.Y0fit],[vy(1) vy(2)],'r:','LineWidth',1)
hold off



function I1 = calculate_I1(hObject,handles,X,dX,x_or_y)
x  = -X;        % reverse sign of X, as Heinz-Dieter did in his calculation of the polynomials
dx = -dX;       % reverse sign of dX, as Heinz-Dieter did in his calculation of the polynomials
xx = x - dx;
if strcmp(x_or_y,'x')
  I1 = handles.px(1)*xx + handles.px(2)*xx.^2 + handles.px(3)*xx.^3 + handles.px(4)*xx.^4 + handles.px(5)*xx.^5;
  I1 = I1 + handles.px(1)*dx - handles.px(2)*dx^2 + handles.px(3)*dx^3 - handles.px(4)*dx^4 + handles.px(5)*dx^5;
else
  I1 = handles.py(1)*xx + handles.py(2)*xx.^2 + handles.py(3)*xx.^3 + handles.py(4)*xx.^4 + handles.py(5)*xx.^5;
  I1 = I1 + handles.py(1)*dx - handles.py(2)*dx^2 + handles.py(3)*dx^3 - handles.py(4)*dx^4 + handles.py(5)*dx^5;
end



function handles = fit_center(hObject,handles)
Xmin = -2;      % best-fit-search min (mm)
Xmax =  2;      % search max (mm)
Xstep = 0.01;   % fit resolution (mm)
Xs = Xmin:Xstep:Xmax;
nXs = length(Xs);
chisqx = zeros(size(Xs));
chisqy = zeros(size(Xs));
Brho = handles.E0*1E10/2.99792458E8;    % kG-m
for j = 1:nXs
  I1Xj = calculate_I1(hObject,handles,handles.X,Xs(j),'x');
  I1Yj = calculate_I1(hObject,handles,handles.X,Xs(j),'y');
  chisqx(j) = sum(((I1Xj - handles.I1X)./handles.dI1X).^2);
  chisqy(j) = sum(((I1Yj - handles.I1Y)./handles.dI1Y).^2);
end
[dum,ix] = min(chisqx);
[dum,iy] = min(chisqy);
handles.X0fit = Xs(ix);
handles.Y0fit = Xs(iy);

%figure(1)
%subplot(2,1,1)
ix1 = max([1 (ix-5)]);
ix2 = min([nXs (ix+5)]);
iy1 = max([1 (iy-5)]);
iy2 = min([nXs (iy+5)]);
qx = plot_parab(Xs(ix1:ix2),chisqx(ix1:ix2),1,' ',' ',' ',' ',1);
%subplot(2,1,2)
qy = plot_parab(Xs(iy1:iy2),chisqy(iy1:iy2),1,' ',' ',' ',' ',1);
x1x =  sqrt(qx(3)/qx(1)) + qx(2);
x2x = -sqrt(qx(3)/qx(1)) + qx(2);
x1y =  sqrt(qy(3)/qy(1)) + qy(2);
x2y = -sqrt(qy(3)/qy(1)) + qy(2);
handles.dX0fit = abs(x1x - x2x)/2;  % estimated error on X0fit
handles.dY0fit = abs(x1y - x2y)/2;  % estimated error on Y0fit

guidata(hObject, handles);



% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)
plot_field_integrals(1,hObject,handles)
util_printLog(1);

% Save the data
path_name=([getenv('MATLABDATAFILES') '/undulator/integrals/']);
fname = datestr(now,30);
filename = [path_name 'U' num2str(handles.girder) '_' fname];
save(filename, 'handles');
display(['All gui data written to file ' filename]);

dataSave(hObject,handles,0);


function XMIN_Callback(hObject, eventdata, handles)
handles.xmin = str2double(get(hObject,'String'));
if handles.xmin < -5
  handles.xmin = -5;
  set(handles.XMIN,'String',num2str(handles.xmin))
  warndlg('Minumum X-translation cannot be < -5 mm','WARNING')
end
if handles.xmin > 0
  handles.xmin = 0;
  set(handles.XMIN,'String',num2str(handles.xmin))
  warndlg('Minumum X-translation cannot be > 0','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function XMIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XMAX_Callback(hObject, eventdata, handles)
handles.xmax = str2double(get(hObject,'String'));
if handles.xmax > 16
  handles.xmax = 16;
  set(handles.XMAX,'String',num2str(handles.xmax))
  warndlg('Maximum X-translation cannot be > 16 mm','WARNING')
end
if handles.xmax < 0
  handles.xmax = 0;
  set(handles.XMAX,'String',num2str(handles.xmax))
  warndlg('Maximum X-translation cannot be < 0','WARNING')
end
handles.fitmax=handles.xmax;
set(handles.FITMAX,'String',num2str(handles.xmax));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function XMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function STEPSIZE_Callback(hObject, eventdata, handles)
handles.stepsize = str2double(get(hObject,'String'));
if handles.stepsize > 5
  handles.stepsize = 5;
  set(handles.STEPSIZE,'String',num2str(handles.stepsize))
  warndlg('X-translation step-size cannot be > 5 mm','WARNING')
end
if handles.stepsize < 0.1
  handles.stepsize = 0.1;
  set(handles.STEPSIZE,'String',num2str(handles.stepsize))
  warndlg('X-translation step-size cannot be < 0.1 mm','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function STEPSIZE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in GIRDERS.
function GIRDERS_Callback(hObject, eventdata, handles)
handles.girder = get(hObject,'Value');
installed_PV = ['USEG:UND1:' num2str(handles.girder) '50:INSTALTNSTAT'];
installed = lcaGetSmart(installed_PV,0,'double');
if ~installed
  set(handles.START,'Enable','off')
  set(handles.START,'String','not installed')
  set(handles.INSTALLED,'String','not installed')
  write_message(sprintf('Undulator #%2.0f not yet installed.',handles.girder),handles);
  return
else
  set(handles.START,'Enable','on')
  set(handles.START,'String','START')
  set(handles.INSTALLED,'String','installed')
end
set(handles.START,'Enable','off')
set(handles.START,'String','wait...')
set(handles.XMIN,'Enable','off')
set(handles.XMAX,'Enable','off')
set(handles.STEPSIZE,'Enable','off')
set(handles.NAVG,'Enable','off')
write_message('Reading model and Z-values...',handles);
und = ['US' num2str(handles.girder,'%02d')];
handles.Z0  = model_rMatGet(und,[],{},'Z');
R = model_rMatGet(und,handles.BPM_pvs,{'POS=END' 'POSB=MID'});
handles.R1s = permute(R(1,[1 2 3 4 6],:),[3 2 1]);
handles.R3s = permute(R(3,[1 2 3 4 6],:),[3 2 1]);
set(handles.START,'Enable','on')
set(handles.START,'String','START')
set(handles.XMIN,'Enable','on')
set(handles.XMAX,'Enable','on')
set(handles.STEPSIZE,'Enable','on')
set(handles.NAVG,'Enable','on')
handles.E0  = lcaGetSmart('BEND:DMP1:400:BDES');    % beam energy [GeV]
set(handles.ENERGY,'String',sprintf('Energy=%5.2f GeV',handles.E0))
xinmax=lcaGet(['USEG:UND1:' num2str(handles.girder) '50:XINMAX']);
[handles.xmax,handles.fitmax]=deal(xinmax+4);
set([handles.XMAX,handles.FITMAX],'String',num2str(xinmax+4));
write_message('Ready...',handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GIRDERS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
if handles.navg < 2
  handles.navg = 2;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be < 2','WARNING')
end
if handles.navg > 100
  handles.navg = 100;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be > 100','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
util_appClose(hObject);


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

data.name=num2str(handles.girder,'US%02d');
data.ts=datenum(handles.time);

list={'X' 'I1X' 'dI1X' 'px' 'X0fit' 'pI1X' 'dX0fit' 'I1Y' 'dI1Y' 'py' 'Y0fit' 'pI1Y' 'girder' 'sernum' 'dY0fit' 'temp' 'time'};
for tag=list
    if isfield(handles,tag{:})
        data.(tag{:})=handles.(tag{:});
    end
end

fileName=util_dataSave(data,'FieldInt',data.name,data.ts,val);
if ~ischar(fileName), return, end


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles)

[data,fileName]=util_dataLoad('Open field integral measurement');
if ~ischar(fileName), return, end

% Put data in storage.
list={'X' 'I1X' 'dI1X' 'px' 'X0fit' 'pI1X' 'dX0fit' 'I1Y' 'dI1Y' 'py' 'Y0fit' 'pI1Y' 'girder' 'sernum' 'dY0fit' 'temp' 'time'};
for tag=list
    if isfield(data,tag{:})
        handles.(tag{:})=data.(tag{:});
    end
end
guidata(hObject,handles);

plot_field_integrals(0,hObject,handles);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

dataSave(hObject,handles,0);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


function FITMAX_Callback(hObject, eventdata, handles)

handles.fitmax = str2double(get(hObject,'String'));
guidata(hObject,handles);
handles=write_field_integrals(handles,0);
plot_field_integrals(0,hObject,handles);


% --- Executes on button press in recalc_btn.
function recalc_btn_Callback(hObject, eventdata, handles)

handles=write_field_integrals(handles);
plot_field_integrals(0,hObject,handles);
