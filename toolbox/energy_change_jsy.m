function varargout = energy_change_jsy(varargin)
% ENERGY_CHANGE_JSY M-file for energy_change_jsy.fig
%      ENERGY_CHANGE_JSY, by itself, creates a new ENERGY_CHANGE_JSY or raises the existing
%      singleton*.
%
%      H = ENERGY_CHANGE_JSY returns the handle to a new ENERGY_CHANGE_JSY or the handle to
%      the existing singleton*.
%
%      ENERGY_CHANGE_JSY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENERGY_CHANGE_JSY.M with the given input arguments.
%
%      ENERGY_CHANGE_JSY('Property','Value',...) creates a new ENERGY_CHANGE_JSY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before energy_change_jsy_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to energy_change_jsy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help energy_change_jsy

% Last Modified by GUIDE v2.5 07-Aug-2009 18:54:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @energy_change_jsy_OpeningFcn, ...
                   'gui_OutputFcn',  @energy_change_jsy_OutputFcn, ...
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


% --- Executes just before energy_change_jsy is made visible.
function energy_change_jsy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to energy_change_jsy (see VARARGIN)

% Choose default command line output for energy_change_jsy
handles.output = hObject;
handles.sectorList={'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30' 'CLTH' 'BSYH' 'LTU0' 'LTU1' 'UND1' 'DMP1'};
handles.static=[];
handles=getKlys(hObject,handles);
% Update handles structure
handles=initJavaLEM(handles);
guidata(hObject, handles);

function energy_change_jsy_CloseRequestFcn(hObject, eventdata, handles)

% Get file name of GUI program instance.
file=get(hObject,'FileName');
[pname,file]=fileparts(file);

% Delete GUI.
delete(hObject);
% exit from Matlab when not running the desktop
if usejava('desktop') 
    % don't exit from Matlab
else
    exit
end


% --- Outputs from this function are returned to the command line.
function varargout = energy_change_jsy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function handles = energy_end_Callback(hObject, eventdata, handles)
handles.E_end=str2double(get(hObject,'String'));
guidata(hObject,handles)
msg(cat(2,'Energy set to ',handles.E_end,' ', ''),handles);
set(hObject,'BackgroundColor',[0 .5 .5])
set(handles.fboff_stppr,'BackgroundColor','green')


% --- Executes during object creation, after setting all properties.
function energy_end_CreateFcn(hObject, eventdata, handles)
en=model_energySetPoints;
set(hObject,'String',en(5));
%set(hObject,'String',lcaGet('SIOC:SYS0:ML00:AO409'))
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'ToolTip','Set desired energy')

% --- Executes on button press in fboff_stppr.
function fboff_stppr_Callback(hObject, eventdata, handles)
set(hObject,'ToolTipString','Turn off FB, put in stoppers')
step_one_e_change;
set(hObject,'BackgroundColor',[0 .5 .5])
set(handles.uipanel1,'BackgroundColor','green')

function step_one_e_change(handles)

lcaPut('DUMP:LI21:305:TD11_PNEU',0);
lcaPut('DUMP:LTU1:970:TDUND_PNEU',0);
lcaPut('SIOC:SYS0:ML00:AO296',0);
lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
lcaPut('FBCK:BSY0:1:ENABLE',0);
lcaPut('FBCK:DL20:1:ENABLE',0);
lcaPut('FBCK:FB03:TR01:MODE',0);        
lcaPut('FBCK:UND0:1:ENABLE',0);

control_ampSet('L3',(handles.E_end-4.3)*1e3)
model_energySetPoints(handles.E_end,5);
%lcaPut('SIOC:SYS0:ML00:AO409',handles.E_end);

function config_but_CreateFcn(hObject, eventdata, handles)
set(hObject,'Value',0)

% --- Executes on button press in config_but.
function config_but_Callback(hObject, eventdata, handles)
set(hObject,'Value',1)
config='yes';
set(handles.klys_comp,'Visible','on')
set(handles.SCORELEM,'Visible','on')
set(handles.runModel,'Visible','on')
set(handles.undGMat,'Visible','on')
set(handles.taperBTN,'Visible','on')
set(handles.make_klys,'Visible','off')
set(handles.handLEM,'Visible','off')
set(handles.betaMatchUND,'Visible','off')
set(handles.klys_comp,'BackgroundColor','green')
set(handles.uipanel1,'BackgroundColor',[0 .5 .5])

% --- Executes on button press in scaleLEM_but.
function scaleLEM_but_Callback(hObject, eventdata, handles)
set(hObject,'Value',1)
config='no';
set(handles.uipanel1,'BackgroundColor',[0 .5 .5])
set(handles.make_klys,'Visible','on')
set(handles.handLEM,'Visible','on')
set(handles.betaMatchUND,'Visible','on')
set(handles.runModel,'Visible','on')
set(handles.undGMat,'Visible','on')
set(handles.taperBTN,'Visible','on')
set(handles.klys_comp,'Visible','off')
set(handles.SCORELEM,'Visible','off')
set(handles.make_klys,'BackgroundColor','green')



%%%%%%%%%%%%%%%%%
%% "Borrowed" from Henrik...
%%%%%%%%%%%%%%%%%
% ------------------------------------------------------------------------
function handles = getKlys(hObject,handles)

names=model_nameConvert({'KLYS'},'MAD',handles.sectorList);
[act,d,d,d,d,enld]=control_klysStatGet(names);
handles.deviceList.klys.name=names;
handles.deviceList.klys.act=act;
handles.deviceList.klys.enld=enld;
plotKlys(handles);
guidata(hObject,handles);

function plotKlys(handles, act)

if nargin < 2
    act=handles.deviceList.klys.act;
end
img=zeros(8*6,3);
bad=bitand(act(:),4) > 0;
on=bitand(act(:),1) > 0;
off=bitand(act(:),2) > 0;
img(bad,1:2)=1;
img(on,2)=1;
img(off,1:3)=1;
img=reshape(img,8,6,3);
image(25:30,1:8,img,'Parent',handles.axes1);
xlabel(handles.axes1,'Sector');
ylabel(handles.axes1,'Klystron #');
title(handles.axes1,'Klystron Complement');
[a,b]=meshgrid(24.5:30.5,.5:8.5);
line(a,b,'Color','k','Parent',handles.axes1);
line(a',b','Color','k','Parent',handles.axes1);
axis(handles.axes1,'equal','tight');
set(handles.axes1,'XTick',25:30,'YTick',1:8,'TickLength',[0 0]);

% ------------------------------------------------------------------------
function setKlys(handles)

klys=handles.deviceList.klys;
use=~bitand(klys.act,4);
control_klysStatSet(klys.name(use),bitand(klys.act(use),1));

function [k1, z, lEff] = design_k1Get(name)

[rBeg,z,lEff]=model_rMatGet(name,[],{'POS=BEG' 'TYPE=DESIGN'});
rEnd=model_rMatGet(name,[],{'POS=END' 'TYPE=DESIGN'});
n=size(rBeg,3);
r=zeros(6,6,n);

for j=1:n
    r(:,:,j)=rEnd(:,:,j)*inv(rBeg(:,:,j));
end

r11=squeeze(r(1,1,:))';
phix=acos(r11);
k1=real((phix./lEff).^2);


%%%%%%%%%%%%%%%%%
%% ^^^^^^^^^^^^^^^^^^^^^^^^"Borrowed" from Henrik...
%%%%%%%%%%%%%%%%%


function td11Stat_CreateFcn(hObject, eventdata, handles)

set(hObject,'String',lcaGet('DUMP:LI21:305:TD11_PNEU'))

function bykickStat_CreateFcn(hObject, eventdata, handles)

set(hObject,'String',lcaGet('IOC:BSY0:MP01:BYKIKCTL'))

function tdundStat_CreateFcn(hObject, eventdata, handles)

set(hObject,'String',lcaGet('DUMP:LTU1:970:TDUND_PNEU'))

function td11Stat_ButtonDownFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('DUMP:LI21:305:TD11_PNEU'))

function bykickStat_ButtonDownFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('IOC:BSY0:MP01:BYKIKCTL'))

function tdundStat_ButtonDownFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('DUMP:LTU1:970:TDUND_PNEU'))

% --- Executes on button press in klys_comp.
function klys_comp_Callback(hObject, eventdata, handles)

lcls_comp
set(hObject,'BackgroundColor',[0 .5 .5])
msg(cat(2,'Match Klystron Complement to SCORE config ', ''),handles);
set(handles.SCORELEM,'BackgroundColor','green')


% --- Executes on button press in SCORELEM.
function SCORELEM_Callback(hObject, eventdata, handles)

set(hObject,'BackgroundColor',[0 .5 .5])
!/usr/local/lcls/physics/score/score.bash &
msg(cat(2,'Load config from SCORE-LEM (launch manually) ', ''),handles);
msg(cat(2,'Allow SCORE to perform LEM ', ''),handles);
set(handles.runModel,'BackgroundColor','green')

% --- Executes on button press in make_klys.
function lem=make_klys_Callback(hObject, eventdata, handles)
% Get present klystron complement
msg(cat(2,'Calculated klystron complement based on energy ', ''),handles);
handles=getKlys(hObject,handles);
act=reshape(handles.deviceList.klys.act,8,[]);
%act([4 6],5)=4;act([3],6)=4;act(4,2)=4;

% Useable klystrons in 29,30
good=bitand(act,4) == 0;
use29_30=min(sum(good(:,5:6)));

% Get energy
en=handles.E_end;
%dKlys=0.220*ones(size(act));
dKlys=reshape(handles.deviceList.klys.enld*1e-3,8,[]);
dE=en-4.3;
if en < 4.3 || en > 14
    gui_statusDisp(handles,'Energy out of range');
    return
end

% Needed klystrons in 29,30

% Needed klystrons in 29,30
%use29_30=min(round(interp1([4.3 13.64],[2 8],en,'linear',7)),use29_30);
use29_30=min(7,use29_30);
use2=cumsum(good(:,5:6)) <= use29_30;
%phi=45;
phi=interp1([4.3 13.64],[145 45],en,'linear',45);
dE29_30=sum(sum(use2.*dKlys(:,5:6)))*cosd(phi);

% Needed klyystrons in 25-28
dE25_28=dE-dE29_30;
%use25_28=round(dE25_28/dKlys);

% Set klystrons in 25-28
use1=reshape(cumsum(reshape(good(:,1:4).*dKlys(:,1:4),[],1)) <= dE25_28,8,[]);
%use1=reshape(cumsum(reshape(good(:,1:4),[],1)) <= use25_28,8,[]);
act([use1 use2] & good)=1;act(~[use1 use2] & good)=2;

handles.deviceList.klys.act=act(:);
guidata(hObject,handles);
plotKlys(handles,act);
set(hObject,'BackgroundColor',[0 .5 .5])
set(handles.actKlys,'BackgroundColor','green')
set(handles.actKlys,'Visible','on')

% --- Executes on button press in handLEM.
function handLEM_Callback(hObject, eventdata, handles)
msg(cat(2,'Java LEM calculating...(make sure fudge is reasonable) ', ''),handles);
set(hObject,'BackgroundColor',[0 .5 .5])
handles=initJavaLEM(handles);
handles=CollectJavaLEM(handles);
guidata(hObject,handles);
set(handles.LEMactivate,'Visible','on')
set(handles.LEMactivate,'BackgroundColor','green')

function handles=initJavaLEM(handles)
% include LEM API in the path
javaclasspath /home/softegr/pchu/workspace/LEM/jar/lemapi_zplot.jar;

% import necessary classes
import javax.swing.JFrame;
import java.util.ArrayList;
import edu.stanford.lcls.xal.tools.lem.*;
import edu.stanford.slac.lem.display.*;

% create a Java JFrame
handles.myFrame = JFrame();

function handles=CollectJavaLEM(handles)
javaclasspath /home/softegr/pchu/workspace/LEM/jar/lemapi_zplot.jar;

% import necessary classes
import javax.swing.JFrame;
import java.util.ArrayList;
import edu.stanford.lcls.xal.tools.lem.*;
import edu.stanford.slac.lem.display.*;
% create a Java JFrame
handles.myFrame = JFrame();
% create a LEM display panel
dd = DataDisplay();

% put the LEM display panel into the Java frame
handles.myFrame.add(dd.getDisplay());
handles.myFrame.pack();
handles.myFrame.setVisible(true);

% initialize LEM 
lem = LEM.getInstance('/usr/local/lcls/physics/config/model/main.xal');

% Select regions and magnet groups.  If not specified, default is
% LEM._QM15_TO_BC2 & LEM._BC2_TO_50B1
%
% available regions:
% 'L0' -- GUN_TO_BX02
% 'L1' -- BX02_TO_QM15
% 'L2' -- QM15_TO_BC2
% 'L3' -- BC2_TO_50B1
% 'LTU' -- 50B1_TO_DUMP
% 'GSPEC' -- GUN_SPECT
% 'LSPEC' -- 135_MEV_SPECT
% '52LINE' -- 52_LINE
regions = ArrayList();
regions.add('L3');
regions.add('LTU');
lem.setSelectedRegions(regions);

% Select magnet groups
% available magnet groups:
% LEM.NON_OPT_MAGS
% LEM.XYCORS
% LEM.UND_XYCORS
% LEM.UND_QUADS
magGroups = ArrayList();
magGroups.add(LEM.NON_OPT_MAGS);
magGroups.add(LEM.XYCORS);
lem.setMagnetGroups(magGroups);

% run LEM 'Lite' to get RF/klystron energy profile
lem.init()

% collect LEM data, false means not to write to EACT PVs
lem.collectData(true)

% update the LEM display panel
dd.updateLem(lem)

% refresh the plot
handles.myFrame.repaint()
handles.lem=lem;


% --- Executes on button press in LEMactivate.
function LEMactivate_Callback(hObject,eventdata,handles)
scaleLEM(handles);
set(hObject,'BackgroundColor',[0 .5 .5])
set(handles.runModel,'BackgroundColor','green')

function scaleLEM(handles)
if ~strcmp('Yes',questdlg('Do you want to scale magnets?','Scale Magnets')), return, end
msg(cat(2,'Scaling magnets ...',''),handles);
handles.lem.applyScaleMagnets();
msg(cat(2,'Scaling magnets done.',''),handles);

% --- Executes on button press in betaMatchUND.
function betaMatchUND_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
matching_gui
msg(cat(2,'Select "UND" region and rematch into undulator ', ''),handles);
set(handles.undGMat,'BackgroundColor','green')

% --- Executes on button press in runModel.
function runModel_Callback(hObject, eventdata, handles)
!modelMan &
msg(cat(2,'Launching Model Manager-- ', ''),handles);
msg(cat(2,'...Run/Save extant model ', ''),handles);
msg(cat(2,'...back prop. Twiss calc from WS28144 ', ''),handles);
set(hObject,'BackgroundColor',[0 .5 .5])
set(handles.betaMatchUND,'BackgroundColor','green')

% --- Executes on button press in actKlys.
function actKlys_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
setKlys(handles);
set(handles.handLEM,'BackgroundColor','green')


% --- Executes on button press in undGMat.
function undGMat_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
msg(cat(2,'Go to Undulator launch feedback config panel... ', ''),handles);
msg(cat(2,'...and calc new GMat in the Matrices Configuration panel ', ''),handles);
set(handles.taperBTN,'Visible','on','BackgroundColor','green')



% --- Executes on button press in resetBTN.
function resetBTN_Callback(hObject, eventdata, handles)
set(handles.klys_comp,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.SCORELEM,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.runModel,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.undGMat,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.make_klys,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.klys_comp,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.handLEM,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.betaMatchUND,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.actKlys,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.LEMactivate,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.td11BSYoutON,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.LTUon,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.TDUNDOUT,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.taperBTN,'Visible','off','BackgroundColor',[.5 .5 .5])
set(handles.fboff_stppr,'BackgroundColor',[.5 .5 .5])
set(handles.klys_comp,'BackgroundColor',[.5 .5 .5])
set(handles.uipanel1,'BackgroundColor',[.5 .5 .5])
set(handles.energy_end,'BackgroundColor',[.5 .5 .5])
msg(cat(2,'GUI Reset ', datestr(now)),handles);

% --- Executes on selection change in log.
function handles=log_Callback(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function log_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',cat(2,'GUI Started ',datestr(now)))

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function msg(text,handles)

ACT{1} = char(get(handles.log,'String'));
ACT{2} = char(text);
set(handles.log,'String',ACT);

% --- Executes on button press in td11BSYoutON.
function td11BSYoutON_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
msg(cat(2,'Check orbit and FB for convergence... ', ''),handles);
set(handles.LTUon,'Visible','on','BackgroundColor','green')
lcaPut('DUMP:LI21:305:TD11_PNEU',1);
lcaPut('FBCK:BSY0:1:ENABLE',1);
lcaPut('FBCK:DL20:1:ENABLE',1);
lcaPut('SIOC:SYS0:ML00:AO296',1);

% --- Executes on button press in LTUon.
function LTUon_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
msg(cat(2,'Check orbit and FB for convergence... ', ''),handles);
msg(cat(2,'...and go to 1Hz before continuing ', ''),handles);
set(handles.TDUNDOUT,'Visible','on','BackgroundColor','green')
lcaPut('FBCK:FB03:TR01:MODE',1);  
lcaPut('IOC:BSY0:MP01:BYKIKCTL',1);


% --- Executes on button press in TDUNDOUT.
function TDUNDOUT_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
msg(cat(2,'Check orbit and FB for convergence... ', ''),handles);
msg(cat(2,'...and hand steer if necessary ', ''),handles);
lcaPut('FBCK:UND0:1:ENABLE',1);
lcaPut('DUMP:LTU1:970:TDUND_PNEU',1);

% --- Executes on button press in taperBTN.
function taperBTN_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[0 .5 .5])
msg(cat(2,'Launching Heinz-Deiter`s taper GUI... ', ''),handles);
set(handles.td11BSYoutON,'Visible','on','BackgroundColor','green')
UndulatorTaperControl_gui
