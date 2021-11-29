function varargout = SXRSS_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SXRSS_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SXRSS_gui_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function SXRSS_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;

timerRunning= false;
timerRestart= false;
timerDelay= 1;      % sec
timerData.hObject= hObject;

% Choose default command line output for GUI
handles.output = hObject;

set(handles.M3X_slider,'Value',20);
set(handles.energy_slider,'Value',650);

handles=appInit(hObject,handles);
%----------------------------------------------------------- 
%Move Restructuring 
set(handles.text71,'String','f','FontName','symbol') %phi
set(handles.text70,'String','q','FontName','symbol') %theta
set(handles.text274,'String','D','FontName','symbol') %delta
set(handles.text279,'String','m','FontName','symbol') %mu
set(handles.text183,'String','m','FontName','symbol') %
set(handles.text272, 'String',char(229))
set(handles.profmon_ax,'PlotBoxAspectRatio',[1392 1040 1]);  

handles.bufd=1;
handles.PVId=1;

% set(handles.main_ax,'Visible','on');
%axes(handles.main_ax);
im=imread('SXRSS.jpg','jpeg');
image(im,'Parent',handles.main_ax);
axis(handles.main_ax,'off');
%image(im)
%axis off;

set(handles.procedure_btn,'value',1);
set(handles.experts_btn,'value',0);
setting_displays(hObject, handles);


set(handles.uipanel140, 'SelectionChangeFcn', ...
    {@uipanel140_SelectionChangeFcn, handles}) %setup uipanel

set(handles.uipanel389, 'SelectionChangeFcn', ...
    {@uipanel389_SelectionChangeFcn, handles}) %setup uipanel


set(handles.uipanel399, 'SelectionChangeFcn', ...
    {@uipanel399_SelectionChangeFcn, handles}) %setup uipanel

set(handles.uipanel401, 'SelectionChangeFcn', ...
    {@uipanel401_SelectionChangeFcn, handles}) %setup uipanel


handles=bitsControl(hObject,handles,8,16);

handles.PVList={ ...
    'YAGS:UND1:1005'
    'YAGS:UND1:1305'
    };

for j=1:length(handles.PVList)
    handles.bg{j}=0;
end

%--------------------------------For Procedure-----------------------------
handles.step.currentStep = 1;
handles.step.incrementStepWith = 0;
handles.step.maxStep = 7;
handles.step.whatBtnPressed = '';

handles.step.state1.value = 0;
handles.step.state1.color = [0.502 1 0.502]; 
handles.step.state1.string = 'Start Procedure';

handles.step.state2.value = 0;
handles.step.state2.color = [0.502 1 0.502]; 
handles.step.state2.string = 'Continue >>';

handles.step.state3.value = 1;
handles.step.state3.color = [1 0.961 0.07]; 
handles.step.state3.string = 'Running... Press to Abort';

handles.step.state4.value = 0;
handles.step.state4.color = [0.502 1 0.502]; 
handles.step.state4.string = 'Start Step >>';

handles.step.state5.value = 0;
handles.step.state5.color = [1 0.377 0.419]; 
handles.step.state5.string = 'Aborted: Press to Reset';

handles.step.state6.value = 0;
handles.step.state6.color = [0.502 1 0.502]; 
handles.step.state6.string = 'Finished';

handles.step.state7.value = 0;
handles.step.state7.color = [0.502 1 0.502]; 
handles.step.state7.string = 'Start Step';

handles.step.state8.value = 0;
handles.step.state8.color = [0.502 1 0.502]; 
handles.step.state8.string = 'Show Next Step';

%Moves all panels to the same position as the first step panel
for n = 2:handles.step.maxStep;
    set(handles.(strcat('step', num2str(n))),'position',get(handles.step1,'position'))
    set(handles.(strcat('step', num2str(n))),'parent',handles.procedure_panel)
    set(handles.(strcat('step', num2str(n))),'visible','off')
end


postMessage(handles,'Please press Start button to begin...');
%--------------------------------------------------------------------------
% Update handles structure
guidata(hObject, handles);


function getInitialValues(hObject, handles) 
%Gets the list of orignal values
PVNames = {'GRAT:UND1:934:X';'GRAT:UND1:934:Y';'MIRR:UND1:936:P';...
    'SLIT:UND1:962:Y';'MIRR:UND1:964:X';'MIRR:UND1:966:X';...
    'MIRR:UND1:966:P';'MIRR:UND1:966:O'};

PVNames=reshape([strcat(PVNames',':DES');strcat(PVNames',':IN');strcat(PVNames',':MOTOR')],[],1);
for j = 1:numel(PVNames)
	handles.orig.(['PV' num2str(j)]) = lcaGetSmart(PVNames(j));
end

%other
handles.orig.PV29 = lcaGetSmart('SIOC:SYS0:ML01:AO861');
handles.orig.PV30 = lcaGetSmart('SIOC:SYS0:ML01:AO873');
handles.orig.PV31 = lcaGetSmart('SIOC:SYS0:ML01:AO872');
handles.orig.PV32 = lcaGetSmart(handles.energyCalculatedFromM1P');

%Had some kind of handle name associated with these
handles.orig.PV33 = lcaGetSmart('SIOC:SYS0:ML01:AO808');
handles.orig.PV34 = lcaGetSmart('SIOC:SYS0:ML01:AO809');
handles.orig.PV35 = lcaGetSmart('SIOC:SYS0:ML01:AO810');
handles.orig.PV36 = lcaGetSmart('SIOC:SYS0:ML01:AO812');
handles.orig.PV37 = lcaGetSmart('SIOC:SYS0:ML01:AO813');
handles.orig.PV38 = lcaGetSmart(handles.energyCalculatedFromM1P');
handles.orig.PV39 = lcaGetSmart('SIOC:SYS0:ML01:AO865');
handles.orig.PV40 = lcaGetSmart('SIOC:SYS0:ML01:AO866');
handles.orig.PV41 = lcaGetSmart('SIOC:SYS0:ML01:AO867');
handles.orig.PV42 = lcaGetSmart('SIOC:SYS0:ML01:AO900');
handles.orig.PV43 = lcaGetSmart('SIOC:SYS0:ML01:AO908');
handles.orig.PV44 = lcaGetSmart('IOC:BSY0:MP01:BYKIKCTL');
handles.orig.PV45 = lcaGetSmart('BEND:UND1:940:BDES');
handles.orig.PV46 = lcaGetSmart('DUMP:LTU1:970:TDUND_PNEU');

for x = setdiff(1:33,[9 16 33])
    PV = ['USEG:UND1:',num2str(x), '50:'];
    handles.orig.(['PV' num2str(46+x)]) = lcaGetSmart(strcat(PV,'KDES'));
end

handles.orig.und16Feedback = lcaGetSmart('SIOC:SYS0:ML00:AO818');
handles.orig.bykik = lcaGetSmart('IOC:BSY0:MP01:BYKIKCTL');
handles.orig.PMT = lcaGetSmart(handles.voltPVs);
props1=strcat(model_nameConvert('YAGSLIT'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
handles.orig.yagslitROI = lcaGetSmart(props1);
props2=strcat(model_nameConvert('YAGBOD1'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
handles.orig.yagBOD1ROI = lcaGetSmart(props2);
handles.orig.XTCAV = control_klysStatGet('XTCAV');
guidata(hObject, handles);


function putInitialValues(hObject, handles) 
%Puts the list of orignal values back into the accelerator
PVNames = {'GRAT:UND1:934:X';'GRAT:UND1:934:Y';'MIRR:UND1:936:P';...
    'SLIT:UND1:962:Y';'MIRR:UND1:964:X';'MIRR:UND1:966:X';...
    'MIRR:UND1:966:P';'MIRR:UND1:966:O'};

PVNames=reshape([strcat(PVNames',':DES');strcat(PVNames',':IN');strcat(PVNames',':MOTOR')],[],1);
for j = 1:numel(PVNames)
	lcaGetSmart(PVNames(j),handles.orig.(['PV' num2str(j)]));
end

%other
lcaPutSmart('SIOC:SYS0:ML01:AO861',handles.orig.PV29);
lcaPutSmart('SIOC:SYS0:ML01:AO873',handles.orig.PV30);
lcaPutSmart('SIOC:SYS0:ML01:AO872',handles.orig.PV31);
lcaPutSmart(handles.energyCalculatedFromM1P',handles.orig.PV32);

%Had some kind of handle name associated with these
lcaPutSmart('SIOC:SYS0:ML01:AO808',handles.orig.PV33);
lcaPutSmart('SIOC:SYS0:ML01:AO809',handles.orig.PV34);
lcaPutSmart('SIOC:SYS0:ML01:AO810',handles.orig.PV35);
lcaPutSmart('SIOC:SYS0:ML01:AO812',handles.orig.PV36);
lcaPutSmart('SIOC:SYS0:ML01:AO813',handles.orig.PV37);
lcaPutSmart(handles.energyCalculatedFromM1P',handles.orig.PV38);
lcaPutSmart('SIOC:SYS0:ML01:AO865',handles.orig.PV39);
lcaPutSmart('SIOC:SYS0:ML01:AO866',handles.orig.PV40);
lcaPutSmart('SIOC:SYS0:ML01:AO867',handles.orig.PV41);
lcaPutSmart('SIOC:SYS0:ML01:AO900',handles.orig.PV42);
lcaPutSmart('SIOC:SYS0:ML01:AO908',handles.orig.PV43);
lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',handles.orig.PV44);
lcaPutSmart('BEND:UND1:940:BDES',handles.orig.PV45);
lcaPutSmart('DUMP:LTU1:970:TDUND_PNEU',handles.orig.PV46);

for x = setdiff(1:33,[9 16 33])
    PV = ['USEG:UND1:',num2str(x), '50:'];
    lcaPutSmart(strcat(PV,'KDES'),handles.orig.(['PV' num2str(46+x)]));
end

lcaPutSmart('SIOC:SYS0:ML00:AO818',handles.orig.und16Feedback);
lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL',handles.orig.bykik);
lcaPutSmart(handles.voltPVs,handles.orig.PMT);
props1=strcat(model_nameConvert('YAGSLIT'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
lcaPutSmart(props1,handles.orig.yagslitROI);
props2=strcat(model_nameConvert('YAGBOD1'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
lcaPutSmart(props2,handles.orig.yagBOD1ROI);
control_klysStatSet('XTCAV',handles.orig.XTCAV);


% --- Outputs from this function are returned to the command line.
function varargout = SXRSS_gui_OutputFcn(hObject, eventdata, handles) 

global timerData;
global timerRunning;
% Get default command line output from handles structure
varargout{1} = handles.output;
handles=RefreshGUI(handles);
if timerRunning
timerData.handles = handles;
end

% Update handles structure
guidata(hObject, handles);


function handles=appInit(hObject,handles)


handles.allMirrorTags={'GRATX';'GRATY';'M1P';'SLITX';'SLITY';'M2X';...
    'M3X';'M3P';'M3O'};

handles.bodEditTags={'GirderX_txt';'GirderY_txt';'EbeamX_txt';...
    'EbeamY_txt';'WireX_txt';'WireY_txt';'XrayX_txt';...
    'XrayY_txt';'SepX_txt';'SepY_txt';'MoveBODX_txt';'MoveBODY_txt';...
    'Offset10_txt';'Offset13_txt'};
       
handles.bodTags={'readGirderX_txt';'readGirderY_txt';'readEbeamX_txt';...
    'readEbeamY_txt';'readWireX_txt';'readWireY_txt';'readXrayX_txt';...
    'readXrayY_txt';'readSepX_txt';'readSepY_txt';'readMoveBODX_txt';...
    'readMoveBODY_txt';'readOffset10_txt';'readOffset13_txt'};

handles.bod10Tags={'AO820';'AO821';'AO826';'AO827';'AO838';'AO839';...
    'AO831';'AO832';'AO801';'AO802';'AO824';'AO825';'AO835';'AO836'};

handles.bod13Tags={'AO822';'AO823';'AO828';'AO829';'AO840';'AO841';...
    'AO833';'AO834';'AO803';'AO804';'AO830';'AO837';'AO835';'AO836'};

handles.matlabPvTags={'AO820';'AO821';'AO822';'AO823';'AO826';'AO827';'AO828';...
    'AO829';   'AO831'; 'AO832'; 'AO833'; 'AO834';'AO835'; 'AO836';...
    'AO838'; 'AO839'; 'AO840'; 'AO841'};


handles.editBoxTags={'energy_txt';'delay_txt';'phase_txt';'M1Pitch_txt';'slitx_txt';
'slity_txt';'G1X_txt';'G1Y_txt';'M2X_txt';'M3X_txt';'M3Pitch_txt';
'M3Roll_txt'};

handles.editBoxPvs={'SIOC:SYS0:ML00:AO627';'SIOC:SYS0:ML01:AO809';'SIOC:SYS0:ML01:AO810';
    'MIRR:UND1:936:P:DES';'SLIT:UND1:962:Y:DES';'SLIT:UND1:962:X:DES';
    'GRAT:UND1:934:X:DES';'GRAT:UND1:934:Y:DES';'MIRR:UND1:964:X:DES';
    'MIRR:UND1:966:X:DES';'MIRR:UND1:966:P:DES';'MIRR:UND1:966:O:DES'};

%text entry fields integer
handles.readback.tag.int={...
    'readEnergyMono_txt';...
    'readDelayMono_txt';...
    'readMode_txt';...
    };

handles.readback.readPV.int={...
    'SIOC:SYS0:ML01:AO856';...
    'SIOC:SYS0:ML01:AO809';... 
    'SIOC:SYS0:ML01:AO900';....
    };

%double2
handles.readback.tag.double2={...
    'readR56Mono_txt';...
    'readCharge_txt';...
    'readEnergyPhoton1_txt';...
    'readCurrent_txt';...
    'readElectronEnergy_txt';...
    'readDxMono_txt';...
    'readPulseEnergyBod_txt';...
    'readBOD10X_txt';...
    'readBOD13X_txt';...
    };

handles.readback.readPV.double2={...
    'SIOC:SYS0:ML01:AO813';... 'r56Mono_txt';
    'SIOC:SYS0:ML00:AO470';... 'charge_txt';
    'SIOC:SYS0:ML00:AO627';...'energyPhoton1_txt';
    'SIOC:SYS0:ML00:AO195';...'current_txt';
    'SIOC:SYS0:ML00:AO500';...'Electron Energy'
    'SIOC:SYS0:ML01:AO812';...   
    'SIOC:SYS0:ML01:AO874';...
    'BOD:UND1:1005:ACT';... 
    'BOD:UND1:1305:ACT';... 
    };

%double3
handles.readback.tag.double3={...
    'readPhaseMono_txt';...
    'readBdes_txt';...
    'readBact_txt';...
    'readG1X_txt';...
    'readG1Y_txt';...
    'readChicane1_txt';...
    'readChicane2_txt';...
    'readChicane3_txt';...
    'readChicane4_txt';...
    'readChicane5_txt';...
    'readChicane6_txt';...
    'readChicane7_txt';...
    'readChicane8_txt';...
    'readSlitx_txt';...
    'readSlity_txt';...
    'readM3X_txt';...
    'readM3Theta_txt';...
    'readM3Phi_txt';...
    'readG1X_txt';...
    'readG1Y_txt';...
    'readM2X_txt';...  
    'readPitchMono_txt';...
    };


handles.readback.readPV.double3={...
    'SIOC:SYS0:ML01:AO810';...
    'BEND:UND1:940:BDES';  % DELETED 'SIOC:SYS0:ML01:AO829';...
    'BEND:UND1:940:BACT';  %DELETED 'SIOC:SYS0:ML01:AO830';...
    'GRAT:UND1:934:X:ACT'
    'GRAT:UND1:934:Y:ACT';
    'BEND:UND1:930:IDES';...
    'BEND:UND1:930:IACT';...        
    'BEND:UND1:940:IDES';...
    'BEND:UND1:940:IACT';...
    'BEND:UND1:960:IDES';...
    'BEND:UND1:960:IACT';...
    'BEND:UND1:970:IDES';...
    'BEND:UND1:970:IACT';...
    'SLIT:UND1:962:X:ACT';...   %Slit X 
    'SLIT:UND1:962:Y:ACT';...   %Slit Y 
    'MIRR:UND1:966:X:ACT';...   %M3X 
    'MIRR:UND1:966:P:ACT';...   %M3P 
    'MIRR:UND1:966:O:ACT';...   %M3O 
    'GRAT:UND1:934:X:ACT';...   %Grating X 
    'GRAT:UND1:934:Y:ACT';...   %Grating Y 
    'MIRR:UND1:964:X:ACT';...   %M2X 
    'MIRR:UND1:936:P:ACT';...   
    };  


%string
handles.readback.tag.string={...
    'readUndefinedMpsStat_txt';...
    'readChicanePower_txt';...
    'readSlit_txt';...
    'readG1_txt';...
    'readM2_txt';...
    'readM3_txt';...
    'readChicaneStatus_txt';...
    'bod10Status_txt';...
    'bod13Status_txt';...
    'readU10_txt';...
    'readU13_txt';...
   };


handles.readback.readPV.string={...
    'MPS:UND1:950:SXRSS_MODE';...
    'BEND:UND1:940:STATE';... %'readChicanePower_txt'
    'SLIT:UND1:962:Y:LOCATIONSTAT';...
    'GRAT:UND1:934:X:LOCATIONSTAT';...
    'MIRR:UND1:964:X:LOCATIONSTAT';...
    'MIRR:UND1:966:X:LOCATIONSTAT';...
    'BEND:UND1:940:CTRLSTATE';...  %'readChicaneStatus_txt'
    'BOD:UND1:1005:LOCATIONSTAT';...
    'BOD:UND1:1305:LOCATIONSTAT';...
    'BOD:UND1:1005:LOCATIONSTAT';...
    'BOD:UND1:1305:LOCATIONSTAT';...
    };

handles.readback.tag.stringblank={...
    'readTDUND_txt'...
    'readPump1_txt'...
    'readPump2_txt'...
    'readSlit_txt'...
    'readG1_txt'...
    'readM2_txt'...
    'readM3_txt'...
    'seeded_button'...
    'sase_button'...
    'harmonic_button'...
    'slitMove_button'...
    'slitOut_button'...
    'opticsAllOut_button'...
    'opticsALLIn_button'...
     };

handles.readback.readPV.stringblank={...
    'SIOC:SYS0:ML01:AO857';... % 'readTDUND_txt'
    'SIOC:SYS0:ML01:AO859';... % 'readPump1_txt'
    'SIOC:SYS0:ML01:AO860';... % 'readPump2_txt'
    'SLIT:UND1:962:IN_LIMIT_MPS.SEVR';...% 'readSlit_txt'  delete'SIOC:SYS0:ML01:AO861'
    'GRAT:UND1:934:IN_LIMIT_MPS.SEVR';...% 'readG1_txt'    deleted 'SIOC:SYS0:ML01:AO862' 
    'MIRR:UND1:964:IN_LIMIT_MPS.SEVR';...% 'readM2_txt'    deleted 'SIOC:SYS0:ML01:AO863'
    'MIRR:UND1:966:IN_LIMIT_MPS.SEVR';...%'readM3_txt'     deleted SIOC:SYS0:ML01:AO864' 
    'SIOC:SYS0:ML01:AO865';... % 'seeded_button'
    'SIOC:SYS0:ML01:AO866';... % 'sase_button'
    'SIOC:SYS0:ML01:AO867';... % 'harmonic_button'
    'SIOC:SYS0:ML01:AO868';... % 'slitMove_button'
    'SIOC:SYS0:ML01:AO869';... % 'slitOut_button'
    'SIOC:SYS0:ML01:AO870';... % 'opticsAllOut_button'
    'SIOC:SYS0:ML01:AO871';... % 'opticsALLIn_button'
    };

%exp
handles.readback.tag.exp={...
    'pump1_txt';...
    'gauge1_txt';...
    'pump2_txt';...
    'gauge2_txt';...
    };

handles.readback.readPV.exp={...
    'VPIO:UND1:934:PMON';...  
    'VGXX:UND1:936:P';...    
    'VPIO:UND1:964:PMON';... 
    'VGXX:UND1:966:P';... 
    };

handles.pvCtr={...
'YAGS:UND1:1005:X_BM_CTR';
'YAGS:UND1:1005:Y_BM_CTR';
'YAGS:UND1:1305:X_BM_CTR';
'YAGS:UND1:1305:Y_BM_CTR';
};

handles.pvCtrTags={...
    'readScreenX_txt'...
    'readScreenY_txt'...
};



handles.readback.undPV.double={...
    'USEG:UND1:150:TMXPOSC';...
    'USEG:UND1:250:TMXPOSC';...
    'USEG:UND1:350:TMXPOSC';...
    'USEG:UND1:450:TMXPOSC';...
    'USEG:UND1:550:TMXPOSC';...
    'USEG:UND1:650:TMXPOSC';...
    'USEG:UND1:750:TMXPOSC';...
    'USEG:UND1:850:TMXPOSC';...
    'USEG:UND1:950:TMXPOSC';...
    'USEG:UND1:1050:TMXPOSC';...
    'USEG:UND1:1150:TMXPOSC';...
    'USEG:UND1:1250:TMXPOSC';...
    'USEG:UND1:1350:TMXPOSC';...
    'USEG:UND1:1450:TMXPOSC';...
    'USEG:UND1:1550:TMXPOSC';...
    'USEG:UND1:1650:TMXPOSC';...
    'USEG:UND1:1750:TMXPOSC';...
    'USEG:UND1:1850:TMXPOSC';...
    'USEG:UND1:1950:TMXPOSC';...
    'USEG:UND1:2050:TMXPOSC';...
    'USEG:UND1:2150:TMXPOSC';...
    'USEG:UND1:2250:TMXPOSC';...
    'USEG:UND1:2350:TMXPOSC';...
    'USEG:UND1:2450:TMXPOSC';...
    'USEG:UND1:2550:TMXPOSC';...
    'USEG:UND1:2650:TMXPOSC';...
    'USEG:UND1:2750:TMXPOSC';...
    'USEG:UND1:2850:TMXPOSC';...
    'USEG:UND1:2950:TMXPOSC';...
    'USEG:UND1:3050:TMXPOSC';...
    'USEG:UND1:3150:TMXPOSC';...
    'USEG:UND1:3250:TMXPOSC';...
    'USEG:UND1:3350:TMXPOSC';...
    };

handles.readback.undtag.double={...
    'uipanel47'...
    'uipanel48'...
    'uipanel49'...
    'uipanel50'...
    'uipanel51'...
    'uipanel52'...
    'uipanel53'...
    'uipanel54'...
    'uipanel55'...
    'uipanel56'...
    'uipanel57'...
    'uipanel58'...
    'uipanel59'...
    'uipanel60'...
    'uipanel61'...
    'uipanel62'...
    'uipanel63'...
    'uipanel64'...
    'uipanel65'...
    'uipanel66'...
    'uipanel67'...
    'uipanel68'...
    'uipanel69'...
    'uipanel70'...
    'uipanel71'...
    'uipanel72'...
    'uipanel73'...
    'uipanel74'...
    'uipanel75'...
    'uipanel76'...
    'uipanel77'...
    'uipanel78'...
    'uipanel79'...
    };

handles.readback.undtag2.double={...
    'text147'...
    'text148'...
    'text149'...
    'text150'...
    'text151'...
    'text152'...
    'text153'...
    'text154'...
    'text155'...
    'text156'...
    'text157'...
    'text158'...
    'text159'...
    'text160'...
    'text161'...
    'text162'...
    'text163'...
    'text164'...
    'text165'...
    'text166'...
    'text167'...
    'text168'...
    'text169'...
    'text170'...
    'text171'...
    'text172'...
    'text173'...
    'text174'...
    'text175'...
    'text176'...
    'text177'...
    'text178'...
    'text179'...
    };

handles.optics.status={...
    'GRAT:UND1:934:X:LOCATIONSTAT'...
    'SLIT:UND1:962:Y:LOCATIONSTAT'...
    'MIRR:UND1:964:X:LOCATIONSTAT'...
    'MIRR:UND1:966:X:LOCATIONSTAT'...
    'BOD:UND1:1005:LOCATIONSTAT'...
    'BOD:UND1:1305:LOCATIONSTAT'...
    };

handles.sepPV = {...
    'SIOC:SYS0:ML01:AO801';...
    'SIOC:SYS0:ML01:AO802';...
    'SIOC:SYS0:ML01:AO803';...
    'SIOC:SYS0:ML01:AO804';...
    };

handles.delayPV='SIOC:SYS0:ML01:AO809'; %delay 
handles.delay_old=lcaGetSmart(handles.delayPV);
handles.phasePV='SIOC:SYS0:ML01:AO810'; %Angstroms
handles.phaseDegPV='SIOC:SYS0:ML01:AO908'; %Degrees
handles.xposPV='SIOC:SYS0:ML01:AO812'; %displacement of ebeam
handles.R56PV='SIOC:SYS0:ML01:AO813'; %R56 Matrix Element
handles.modePV='SIOC:SYS0:ML01:AO900'; % Mode
handles.bdesPV='BEND:UND1:940:BDES';
handles.magnetMainPV='BEND:UND1:940';
handles.magnetTrimPV={'BTRM:UND1:940'; 'BTRM:UND1:930'; 'BTRM:UND1:960'; 'BTRM:UND1:970'};

handles.M1PitchActPV='MIRR:UND1:936:P:ACT';
handles.M1PitchInPV='MIRR:UND1:936:P:IN';
handles.M1PitchDesPV='MIRR:UND1:936:P:DES';
handles.M1PitchTrimPV='MIRR:UND1:936:P:TRIM.PROC';
handles.bod10status = 'BOD:UND1:1005:LOCATIONSTAT';
handles.bod10Insert = 'BOD:UND1:1005:INSERT.PROC';
handles.bod10Extract = 'BOD:UND1:1005:EXTRACT.PROC';

handles.bod13status = 'BOD:UND1:1305:LOCATIONSTAT';
handles.bod13Insert = 'BOD:UND1:1305:INSERT.PROC';
handles.bod13Extract = 'BOD:UND1:1305:EXTRACT.PROC';


handles.optics.PitchMono2='MIRR:UND1:936:P';
handles.energyPV='SIOC:SYS0:ML01:AO808';
handles.energyCalculatedFromM1P='SIOC:SYS0:ML01:AO856';
handles.optics.G1X='GRAT:UND1:934:X';
handles.optics.G1Y='GRAT:UND1:934:Y'; 
handles.optics.M2X='MIRR:UND1:964:X';

handles.optics.M3X='MIRR:UND1:966:X'; 
handles.M3XActPV='MIRR:UND1:966:X:ACT';

handles.optics.M3Theta='MIRR:UND1:966:P'; 
handles.M3PitchActPV='MIRR:UND1:966:P:ACT';

handles.optics.M3Phi='MIRR:UND1:966:O';
handles.slit.slitx='SLIT:UND1:962:X';  
handles.slit.slity='SLIT:UND1:962:Y'; 
handles.slitYInsertPV='SLIT:UND1:962:Y:INSERT.PROC';
handles.logPV='SIOC:SYS0:ML01:AO807';
handles.tdundPV='DUMP:LTU1:970:TDUND_PNEU';   %0 IN 1 OUT
handles.bykikPV='IOC:BSY0:MP01:BYKIKCTL';  %O-OFF 1-0N
handles.gasPV='GDET:FEE1:241:ENRCHSTBR';
handles.readback.readPV.image='PROF:UND1:960';
handles.chicaneStatusPV='BEND:UND1:940:STATE';
handles.photonEnergyPV='SIOC:SYS0:ML00:AO627';


%handles.readback.readPV.image='YAGS:UND1:1005';
%handles.gasPV='GDET:FEE1:241:ENRCHST10';
handles.PV=handles.readback.readPV.image;
handles.zeroOrder=0; %mrad
handles.XraySlitPosX= 'SIOC:SYS0:ML01:AO844';
handles.XraySlitPosY= 'SIOC:SYS0:ML01:AO845';
handles.intensityFirst='SIOC:SYS0:ML01:AO842';
handles.intensityZeroth='SIOC:SYS0:ML01:AO843';
handles.intensityRatio='SIOC:SYS0:ML01:AO850';
handles.intensityMode=[];

handles.voltPVs=strcat('HVCH:FEE1:',{'241';'242';'361';'362'},':VoltageSet');

handles.step3_from = 5;
handles.step3_to = 8;

handles.yagSelect=1;
handles.yagpv='YAGS:UND1:1005';
handles.show.bmCross = 0;
handles.show.bmCross2=0;
handles.getFull=0;
handles.useBG=0;
%handles.bg=0;

handles.show.cal=1;
handles.fileName='';
handles.buttonPushDownActive=0;
handles.scale2=[];
handles.show.stats = 0;
handles.BG10_full=[];
handles.BG13_full=[];
handles.BG10_zoom=[];
handles.BG13_zoom=[];
handles.axes=[];

handles.iSASE_ISS_edit =10;
handles.iSASE_TaperShape1=-0.0005;
handles.iSASE_TaperShape2=15;
handles.iSASE_TaperShape3=-0.0005;

set(handles. gainTaperStartSegment_txt,'String', num2str(handles.iSASE_ISS_edit))
set(handles. gainTaperAmplitude_txt,'String', num2str(handles.iSASE_TaperShape1))
set(handles. postTaperStartSegment_txt,'String', num2str(handles.iSASE_TaperShape2))
set(handles. postTaperAmplitude_txt,'String', num2str(handles.iSASE_TaperShape3))

set(handles.dx_txt, 'String', num2str(lcaGetSmart('BOD:UND1:1005:MOTOR.TWV'),'%3.3f'));


pitchM1=lcaGetSmart(handles.readback.readPV.double3{22});
if pitchM1 > 14 || pitchM1 < -59
    lcaPutSmart(handles.readback.readPV.int{1}, 'NaN');
else
    energy=SXRSS_mono(pitchM1,2);
    lcaPutSmart(handles.readback.readPV.int{1}, energy);
end

handles = modeManager(hObject, handles);
handles = initGUI(handles);

%step 7
handles.step7ctrlPVtransf = 'SIOC:SYS0:ML01:AO846';
handles.step7ctrlSteps =5;

pvs=handles.readback.readPV;
monitorPVs = unique([pvs.string;pvs.stringblank;pvs.double2;pvs.double3;pvs.int;pvs.exp; ...
              handles.readback.undPV.double; handles.phaseDegPV;handles.tdundPV; handles.editBoxPvs]);
lcaSetMonitor(monitorPVs);


function handles=updateGUIvals(hObject,handles)
set (handles.datestr_txt,'String',datestr(now));

if ~ispc

    idx = find(lcaNewMonitorValue(handles.readback.readPV.string));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.string(idx));
        for loopcnt=1:length(idx)
            set(handles.(handles.readback.tag.string{idx(loopcnt)}),'String',val(loopcnt));
        end
    end

    idx = find(lcaNewMonitorValue(handles.readback.readPV.stringblank));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.stringblank(idx));
        for loopcnt=1:length(idx)
            if val(loopcnt) ==0
                set(handles.(handles.readback.tag.stringblank{idx(loopcnt)}),'BackgroundColor','red');
            elseif val(loopcnt) ==1
                set(handles.(handles.readback.tag.stringblank{idx(loopcnt)}),'BackgroundColor','green');
            end
        end
    end

    idx = find(lcaNewMonitorValue(handles.readback.readPV.double2));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.double2(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%6.2f',val(loopcnt));
            set(handles.(handles.readback.tag.double2{idx(loopcnt)}),'String',str);
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.readback.readPV.double3));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.double3(idx),0,'double');     
        for loopcnt=1:length(idx)
            str=sprintf('%6.3f',val(loopcnt));
            set(handles.(handles.readback.tag.double3{idx(loopcnt)}),'String',str);   
        end
        
               
        if any(idx==22)
            M1P=lcaGetSmart(handles.readback.readPV.double3{(22)});
            if M1P > 14 || M1P < -59
                lcaPutSmart(handles.readback.readPV.int{1}, 'NaN')
            else
                energy=SXRSS_mono(M1P,2);
                lcaPutSmart(handles.readback.readPV.int{1}, energy);
%                 set(handles.M1Pitch_slider,'Value', M1P);
            end
              
        end
        

        
        listenval= get(handles.listen_checkbox, 'Value'); % 1 is checked
        if listenval == 1
            if idx(1) ==1
                set_button_Callback(hObject, [], handles)
            end
        end
    end
    
%     j= lcaGetSmart(handles.readback.readPV.int);
    idx = find(lcaNewMonitorValue(handles.readback.readPV.int));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.int(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%3.0f',val(loopcnt));
            set(handles.(handles.readback.tag.int{idx(loopcnt)}),'String',str);
        end

        listenval= get(handles.listen_checkbox, 'Value'); % 1 is checked
        if listenval == 1
            if idx ==2
                handles=adjustChicane(handles,1,0);
            end
        end
       
        if idx ==5
            %change color of mode buttons
            val=get(handles.active_checkbox, 'Value');
            if val ==1
                set(handles.seeded_button, 'BackgroundColor', [0 1 0])
                set(handles.sase_button, 'BackgroundColor', [0.6 0.6 0.6])
                set(handles.harmonic_button, 'BackgroundColor', [0.6 0.6 0.6])
            elseif val == 2
                set(handles.seeded_button, 'BackgroundColor', [0.6 0.6 0.6])
                set(handles.sase_button, 'BackgroundColor', [0 1 0])
                set(handles.harmonic_button, 'BackgroundColor', [0.6 0.6 0.6])
            elseif val ==3
                set(handles.seeded_button, 'BackgroundColor', [0.6 0.6 0.6])
                set(handles.sase_button, 'BackgroundColor',    [0.6 0.6 0.6])
                set(handles.harmonic_button, 'BackgroundColor', [0 0 1])
            end
        end

    end
    
    idx = find(lcaNewMonitorValue(handles.readback.readPV.exp));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.exp(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%0.3g',val(loopcnt));
            set(handles.(handles.readback.tag.exp{idx(loopcnt)}),'String',str);
        end
    end

    idx = find(lcaNewMonitorValue(handles.readback.undPV.double));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.undPV.double(idx),0,'double');
        for loopcnt=1:length(idx)
            if val > 50
                set(handles.(handles.readback.undtag.double{idx(loopcnt)}),'BackgroundColor', [1 0 0]);
                set(handles.(handles.readback.undtag2.double{idx(loopcnt)}),'BackgroundColor', [1 0 0]);
            elseif val < 50
                set(handles.(handles.readback.undtag.double{idx(loopcnt)}),'BackgroundColor', [0 1 0]);
                set(handles.(handles.readback.undtag2.double{idx(loopcnt)}),'BackgroundColor', [0 1 0]);
            end

            set(handles.uipanel55 ,'BackgroundColor', [0.7 0.7 0.7]);
            set(handles.text155 ,'BackgroundColor', [0.7 0.7 0.7]);
            set(handles.uipanel62 ,'BackgroundColor', [0.7 0.7 0.7]);
            set(handles.text162 ,'BackgroundColor', [0.7 0.7 0.7]);
            set(handles.uipanel79 ,'BackgroundColor', [0.7 0.7 0.7]);
            set(handles.text179 ,'BackgroundColor', [0.7 0.7 0.7]);
            
            
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.tdundPV));
    if ~isempty(idx)
        val=lcaGetSmart(handles.tdundPV,0,'double');
        if val == 0
            set(handles.tdundText,'String', 'IN','BackgroundColor', [1 0 0])
            set(handles.readTDUND_txt,'BackgroundColor', [1 0 0]);
        elseif val == 1
            set(handles.tdundText,'String', 'OUT','BackgroundColor', [0 1 0])
            set(handles.readTDUND_txt,'BackgroundColor', [0 1 0]);
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.editBoxPvs));
    if ~isempty(idx)
            val=lcaGetSmart(handles.editBoxPvs);
            for loopcnt=1:length(val)
                if loopcnt == 2
                    prec = '%3.0f';
                else
                    prec = '%6.3f';
                end
                str=sprintf(prec,val(loopcnt));
                set(handles.(handles.editBoxTags{(loopcnt)}),'String',str);
            end
    end
    
end


function updateGUInow(hObject,handles)
val=lcaGetSmart(handles.readback.readPV.double3,0,'double');

for loopcnt=1:length(val)
str=sprintf('%6.3f',val(loopcnt));
set(handles.(handles.readback.tag.double3{(loopcnt)}), 'String', str);
end

val=lcaGetSmart(handles.readback.readPV.double2,0,'double');

for loopcnt=1:length(val)
str=sprintf('%6.2f',val(loopcnt));
set(handles.(handles.readback.tag.double2{(loopcnt)}), 'String', str);
end

val=lcaGetSmart(handles.readback.readPV.exp,0,'double');

for loopcnt=1:length(val)
str=sprintf('%0.3g',val(loopcnt));
set(handles.(handles.readback.tag.exp{(loopcnt)}), 'String', str);
end

val=lcaGetSmart(handles.readback.readPV.string);

for loopcnt=1:length(val)
str=val(loopcnt);  
set(handles.(handles.readback.tag.string{(loopcnt)}), 'String', str);
end

val=lcaGetSmart(handles.editBoxPvs);

for loopcnt=1:length(val)
    if loopcnt == 2
        prec = '%3.0f';
    else
        prec = '%6.3f';
    end
    str=sprintf(prec,val(loopcnt));
    set(handles.(handles.editBoxTags{(loopcnt)}),'String',str);
end

RefreshGUI(handles);

function handles=initGUI(handles)

val=lcaGetSmart(handles.readback.readPV.string(:));
for loopcnt=1:length(val)
    set(handles.(handles.readback.tag.string{loopcnt}),'String',val(loopcnt));
end

val=lcaGetSmart(handles.readback.readPV.double2(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.2f',val(loopcnt));
    set(handles.(handles.readback.tag.double2{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.readPV.double3(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.3f',val(loopcnt));
    set(handles.(handles.readback.tag.double3{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.readPV.int(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%d',val(loopcnt));
    set(handles.(handles.readback.tag.int{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.readPV.exp(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%0.3g',val(loopcnt));
    set(handles.(handles.readback.tag.exp{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.undPV.double(:),0,'double');
for loopcnt=1:length(val)
    if val(loopcnt) > 50
        set(handles.(handles.readback.undtag.double{(loopcnt)}),'BackgroundColor', [1 0 0]);
        set(handles.(handles.readback.undtag2.double{(loopcnt)}),'BackgroundColor', [1 0 0]);
    elseif val(loopcnt) < 50
        set(handles.(handles.readback.undtag.double{(loopcnt)}),'BackgroundColor', [0 1 0]);
        set(handles.(handles.readback.undtag2.double{(loopcnt)}),'BackgroundColor', [0 1 0]);
        
    end
    
    set(handles.uipanel55 ,'BackgroundColor', [0.7 0.7 0.7]);
    set(handles.text155 ,'BackgroundColor', [0.7 0.7 0.7]);
    set(handles.uipanel62 ,'BackgroundColor', [0.7 0.7 0.7]);
    set(handles.text162 ,'BackgroundColor', [0.7 0.7 0.7]);
    set(handles.uipanel79 ,'BackgroundColor', [0.7 0.7 0.7]);
    set(handles.text179 ,'BackgroundColor', [0.7 0.7 0.7]);
    
end

val=lcaGetSmart(handles.tdundPV,0,'double');
if val == 0
    set(handles.tdundText,'String', 'IN','BackgroundColor', [1 0 0])
    set(handles.readTDUND_txt,'BackgroundColor', [1 0 0]);
elseif val == 1
    set(handles.tdundText,'String', 'OUT','BackgroundColor', [0 1 0])
    set(handles.readTDUND_txt,'BackgroundColor', [0 1 0]);
end

val=lcaGetSmart(handles.editBoxPvs);

for loopcnt=1:length(val)
    if loopcnt == 2
        prec = '%3.0f';
    else
        prec = '%6.3f';
    end
    str=sprintf(prec,val(loopcnt));
    set(handles.(handles.editBoxTags{(loopcnt)}),'String',str);
'BOD:UND1:1005:LOCATIONSTAT';end


function handles=RefreshGUI(handles)
global timerObj;
global timerDelay;
global timerRestart;
global timerRunning;
global timerData;
if (timerRunning)
    stop (timerObj);
end

ff=handles.output;
timerObj=timer('TimerFcn', @(obj, eventdata) timer_Callback(ff) , 'Period', timerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop' );
timerRestart = true;
timerData.handles = handles;
start(timerObj);
timerRunning = true;



function timer_Callback (handleToGuiFigure0)
% global timerData;
% global timerRunning;
% handles    = timerData.handles;
% hObject    = timerData.hObject;
handles = guidata(handleToGuiFigure0); % added to unlock handles 
handles = updateGUIvals(handleToGuiFigure0, handles);
guidata (handleToGuiFigure0, handles );
%timerData.handles = handles;



% --- Executes during object creation, after setting all properties.
function delay_slider_CreateFcn(hObject, eventdata, handles)
set(hObject,'Min',500,'Max',1200,'Value',lcaGetSmart( 'SIOC:SYS0:ML01:AO809'));
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]); 
end


% --- Executes during object creation, after setting all properties.
function energy_slider_CreateFcn(hObject, eventdata, handles)
set(hObject,'Min',300,'Max',1200,'Value',lcaGetSmart('SIOC:SYS0:ML00:AO627'));
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]); 
end


% --- Executes on button press in seeded_button.
function seeded_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value');
if val ==1
    lcaPutSmart(handles.modePV, 1);
    lcaPutSmart(handles.bykikPV, 0); 
    SXRSS_log(handles.listbox1,'Beam Disabled -- BYKIK',val)
    
    power=strcmp(lcaGetSmart(handles.chicaneStatusPV),'ON');
    calculateM1PandDelay(handles, power)
    %energy_txt_Callback(hObject, [], handles);
    opticsALLIn_button_Callback(hObject, [], handles,1);
    
    if power == 0
        control_magnetSet('BXSS2',0,'action','TURN_ON');
        SXRSS_log(handles.listbox1,'TURNED CHICANE POWER ON', val)
        pause(2);
    end

    stdzOK=strcmp(lcaGetSmart('BEND:UND1:940:STDZOK'),'YES');

    if (stdzOK == 0) && (power == 0)
        pause(2);
        control_magnetSet({'BXSS1T' 'BXSS2T' 'BXSS3T' 'BXSS4T'}, 0,'action','TRIM');
        SXRSS_log(handles.listbox1,'Magnet Trims set to Zero',val)
        SXRSS_log(handles.listbox1,'Now Standardizing - this takes a few minutes',val)
        control_magnetSet('BXSS2',[],'action','STDZ');
        SXRSS_log(handles.listbox1,'Standardizing SXRSS Main complete',val)
    end
    
    [act,step,msgs]=SXRSS_MPS('SEEDED');
    [a,b]=size(msgs);
    for i=1:b
        text=msgs(i);
        pause(1);
        SXRSS_logMPS(handles.listbox1, text);
    end
    set_button_Callback(hObject, [], handles) 
    lcaPutSmart(handles.readback.readPV.stringblank(8), 1);
    lcaPutSmart(handles.readback.readPV.stringblank(9), 0);
    lcaPutSmart(handles.readback.readPV.stringblank(10), 0);
    lcaPutSmart(handles.bykikPV, 1); %Enable Beam
    SXRSS_log(handles.listbox1,'Beam Enabled -- BYKIK',val);
    SXRSS_log(handles.listbox1,'Seed Button Process Complete',val);
else
end


% --- Executes on button press in sase_button.
function sase_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value');
if val ==1

    lcaPutSmart(handles.modePV, 2);
    lcaPutSmart(handles.bykikPV, 0); %Disable
    lcaPutSmart(handles.tdundPV, 0); %Disable
    SXRSS_log(handles.listbox1,'Beam Disabled -- BYKIK/TDUND',val);

    SXRSS_log(handles.listbox1,'Extracting Slit',val);
    lcaPutSmart('SLIT:UND1:962:Y:EXTRACT.PROC', 1);
    opticsAllOut_button_Callback(hObject, [], handles, 1); % Don't wait for optics
    BDES=[0 0 0 0];
    
    SXRSS_log(handles.listbox1,'Setting Trims to Zero',val);
    control_magnetSet({'BXSS1T' 'BXSS2T' 'BXSS3T' 'BXSS4T'}, 0,'action','TRIM');
    
    SXRSS_log(handles.listbox1,'Degaussing the Chicane - this takes a few minutes',val);
    control_magnetSet('BXSS2',BDES(1),'action','DEGAUSS');
    SXRSS_log(handles.listbox1,'Degaussing the Chicane - complete',val);

    opticsWait(handles); % Wait until optics move finished

    [act,step,msgs]=SXRSS_MPS('SASE');
    [a,b]=size(msgs);
    for i=1:b
        text=msgs(i);
        pause(1);
        SXRSS_logMPS(handles.listbox1, text);
    end
    set_button_Callback(hObject, [], handles)

    lcaPutSmart(handles.readback.readPV.stringblank(8), 0);
    lcaPutSmart(handles.readback.readPV.stringblank(9), 1);
    lcaPutSmart(handles.readback.readPV.stringblank(10), 0);
    
    SXRSS_log(handles.listbox1,'Beam Enabled -- TDUND/BYKIK',val);
    lcaPutSmart(handles.tdundPV, 1);
    lcaPutSmart(handles.bykikPV, 1);
end


% --- Executes on button press in harmonic_button.
function harmonic_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value');
if val ==1
    lcaPutSmart(handles.modePV, 3);
    SXRSS_log(handles.listbox1,'Beam Disabled -- BYKIK',val);
    lcaPutSmart(handles.bykikPV, 0); %Disable

    SXRSS_log(handles.listbox1,'Slit Trimmed to 9.4',val);
    lcaPutSmart('SLIT:UND1:962:Y:DES', 9.4)
    lcaPutSmart('SLIT:UND1:962:Y:TRIM.PROC', 1)
    p1=0;p2=1;
    while p1~=p2
        slitY_old=lcaGetSmart([handles.slit.slity ':ACT']);
        pause(1);
        slitY_new=lcaGetSmart([handles.slit.slity ':ACT']);
        if slitY_old ~= slitY_new
            text='Slit Moving';
            SXRSS_log(handles.listbox1, text);
            disp(text);
            pause(1);
        else
            text='Slit Finished Moving';
            SXRSS_log(handles.listbox1, text);
            p1=1;
        end
    end
    [act,step,msgs]=SXRSS_MPS('HARMONIC');
    [a,b]=size(msgs); % size(msgs,2) would also have worked...
    for i=1:b
        text=msgs(i);
        pause(1);
        SXRSS_logMPS(handles.listbox1, text);
    end
    lcaPutSmart(handles.readback.readPV.stringblank(8), 0);
    lcaPutSmart(handles.readback.readPV.stringblank(9), 0);
    lcaPutSmart(handles.readback.readPV.stringblank(10), 1);
    SXRSS_log(handles.listbox1,'Beam Enabled -- BYKIK',val);
    lcaPutSmart(handles.bykikPV, 1);
end


% --- Executes on button press in set_button.
function set_button_Callback(hObject, eventdata, handles)
mode = lcaGetSmart(handles.modePV);
val=get(handles.active_checkbox, 'Value');
listenval= get(handles.listen_checkbox, 'Value'); % 1 is checked
if mode ==1 || mode ==3
    %SEEDED or HARMONIC
    pitch_old=lcaGetSmart(handles.M1PitchActPV);
    energy=str2double(get(handles.energy_txt,'String'));
    pitch=str2double(get(handles.M1Pitch_txt, 'String'));

    if val == 1
        lcaPutSmart(handles.energyCalculatedFromM1P, energy);
             
        if pitch ~= pitch_old
            lcaPutSmart(handles.bykikPV, 0)
            SXRSS_log(handles.listbox1,'Beam Disabled -- BYKIK',val);
            lcaPutSmart(handles.M1PitchDesPV, pitch);
            lcaPutSmart(handles.M1PitchTrimPV, 1);
            if epicsSimul_status, lcaPutSmart(handles.M1PitchActPV, pitch); end
            SXRSS_log(handles.listbox1, 'Moved M1P');
            
            
            if handles.delay_old ~= lcaGetSmart(handles.delayPV)
                handles=adjustChicane(handles,1,0);
                SXRSS_log(handles.listbox1, 'Chicane Adjusted');
            end
            SXRSS_log(handles.listbox1,'Beam Enabled -- BYKIK',val);
            lcaPutSmart(handles.bykikPV, 1); %Beam Enabled
        end
    end

elseif mode ==2
    %SASE
    if listenval == 1
        if val ==1
            handles=adjustChicane(handles,1,0);
            SXRSS_log(handles.listbox1,'Chicane Adjusted');
        elseif val == 0
            SXRSS_log(handles.listbox1, 'GUI Not Active ...SET BUTTON')
        end
    elseif listenval == 0
        phase=str2double(get(handles.phase_txt, 'String'));
        if val ==1
            lcaPutSmart(handles.phasePV, phase);
            handles=adjustChicane(handles,1,0);
            SXRSS_log(handles.listbox1,'Chicane Adjusted');
        end
    end
end

       
% --- Executes on button press in zeroOrder_button.
function zeroOrder_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value'); 
if val == 0
    SXRSS_log(handles.listbox1,'GUI NOT ACTIVE')
elseif val ==1
    lcaPutSmart(handles.M1PitchDesPV, handles.zeroOrder)
    pause(0.2);
    lcaPutSmart(handles.M1PitchTrimPV, 1)
    text='M1 moved to Zero order';
    SXRSS_log(handles.listbox1,text)
end


% --- Executes on button press in yagElog_button.
function yagElog_button_Callback(hObject,handles,data)


% --- Executes on button press in elog_button.
function elog_button_Callback(hObject, eventdata, handles)
set(handles.SXRSS_gui,'Units','characters')
figColor=get(handles.SXRSS_gui,'Color');
pos=get(handles.SXRSS_gui,'Position');

handles.exportFig=figure;
set(handles.exportFig,'Units','characters','Position',pos);
set(handles.exportFig,'PaperSize',[pos(3) pos(4)+2]);
set (handles.exportFig,'Color',figColor);
ch = get(handles.SXRSS_gui, 'children');

if ~isempty(ch)
    nh = copyobj(ch,handles.exportFig);
end;
set (nh,'Units','characters');

mode = lcaGetSmart(handles.modePV);
switch mode
    case 1
        modeStr='Seeded';
    case 2
        modeStr='SASE';
    case 3
        modeStr='Harmonic';
    otherwise
        modeStr='';
end
pause(0.5)
delete(findobj(handles.exportFig,'Visible','off'))
util_printLog_wComments(handles.exportFig,'SXRSS_gui',modeStr,'',[960 800]);
close(handles.exportFig);


% --- Executes on button press in tdund_button.
function tdund_button_Callback(hObject, eventdata, handles)
status=lcaGetSmart(handles.tdundPV,0,'double');
if status == 1
    lcaPutSmart(handles.tdundPV, 0); %Insert
    set(handles.readTDUND_txt, 'BackgroundColor', 'green','Foreground','red') 
    str1='IN';
elseif status == 0
    lcaPutSmart(handles.tdundPV, 1); %Extract
    set(handles.readTDUND_txt, 'BackgroundColor', 'red','Foreground','green') 
    str1='OUT';
end
text=['TDUND State Changed to' str1];
SXRSS_log(handles.listbox1, text);


% --- Executes on button press in slitOut_button.
function slitOut_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value'); 
if val == 0
    disp('GUI not Active...SlitExtract')
elseif val ==1
    disp('GUI Active ...SlitExtract')
    lcaPutSmart('SLIT:UND1:962:Y:EXTRACT.PROC', 1)
end


% --- Executes on button press in slitMove_button.
function slitMove_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value'); 
if val == 0
    disp('GUI not Active...SlitInsert')
elseif val ==1
    disp('GUI Active ...SlitInsert')
    lcaPutSmart('SLIT:UND1:962:Y:INSERT.PROC', 1)
end


% --- Executes on button press in opticsAllOut_button.
function opticsAllOut_button_Callback(hObject, eventdata, handles, noWait)
val=get(handles.active_checkbox, 'Value');
if val == 0
    text='GUI not Active...Optics All OUT Button';
    SXRSS_log(handles.listbox1, text);
    return
elseif val ==1
    lcaPutSmart(handles.tdundPV, 1); %Insert
    SXRSS_log(handles.listbox1,'Beam Disabled - BYKIK',val)
    lcaPutSmart('SLIT:UND1:962:Y:EXTRACT.PROC', 1);
    lcaPutSmart('GRAT:UND1:934:X:EXTRACT.PROC', 1);
    lcaPutSmart('MIRR:UND1:964:X:EXTRACT.PROC', 1); %M2
    lcaPutSmart('MIRR:UND1:966:X:EXTRACT.PROC', 1); %M3
    text='Moving All Optics Out - this takes a few moments';
    SXRSS_log(handles.listbox1, text);
end

if nargin == 4 && noWait, return, end

opticsWait(handles);

%lcaPutSmart(handles.bykikPV, 1); %Enable Beam
lcaPutSmart(handles.tdundPV, 1); %Insert

function opticsWait(handles)

moving=1;
while moving
    pause(1);
    val=lcaGetSmart(handles.optics.status(1:4));
    moving=any(strcmp(val,'MOVING'));
end
text='Optics Finished Moving';
SXRSS_log(handles.listbox1, text);


% --- Executes on button press in opticsALLIn_button.
function opticsALLIn_button_Callback(hObject, eventdata, handles,slit)
if nargin < 4, slit=0; end;
lcaPutSmart(handles.bykikPV, 0)
SXRSS_log(handles.listbox1,'Beam Disabled - BYKIK',1)
text='Moving All Optics In - takes a few moments';
SXRSS_log(handles.listbox1, text);

lcaPutSmart('GRAT:UND1:934:X:INSERT.PROC',1); %G-M1
lcaPutSmart('MIRR:UND1:964:X:INSERT.PROC', 1); %M2X
lcaPutSmart('MIRR:UND1:966:X:INSERT.PROC',1); %M3X
lcaPutSmart('GRAT:UND1:934:Y:INSERT.PROC', 1); %GY
lcaPutSmart('MIRR:UND1:936:P:INSERT.PROC',1); %M1P
lcaPutSmart('MIRR:UND1:966:P:INSERT.PROC',1); %M3P
lcaPutSmart('MIRR:UND1:966:O:INSERT.PROC',1); %M3Roll
if slit == 1
    lcaPutSmart(handles.slitYInsertPV, 1);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
%


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
%


% --- Executes on button press in active_checkbox.
function active_checkbox_Callback(hObject, eventdata, handles)
set(handles.procedure_active,'value',get(handles.active_checkbox,'value')) 
val=get(handles.active_checkbox, 'Value');
if val==0
    set(handles.active_text3,'Visible','On')
    set(handles.active_text2,'Visible','On')
elseif val ==1 
    set(handles.active_text3,'Visible','Off')
    set(handles.active_text2,'Visible','Off')
end
handles=appInit(hObject, handles);


function slitx_txt_Callback(hObject, eventdata, handles)
SXRSS_textBox(handles.slit.slitx, handles.slitx_txt,handles.active_checkbox,'SLIT X',handles.listbox1)




function slity_txt_Callback(hObject, ~, handles)
SXRSS_textBox(handles.slit.slity, handles.slity_txt,handles.active_checkbox,'SLIT Y',handles.listbox1)



function G1X_txt_Callback(hObject, eventdata, handles)
SXRSS_textBox(handles.optics.G1X, handles.G1X_txt,handles.active_checkbox,'G1 X',handles.listbox1)




function G1Y_txt_Callback(hObject, eventdata, handles)
SXRSS_textBox(handles.optics.G1Y, handles.G1Y_txt,handles.active_checkbox,'G1 Y',handles.listbox1)







function M3Roll_txt_Callback(hObject, eventdata, handles)
SXRSS_textBox(handles.optics.M3Phi, handles.M3Roll_txt,handles.active_checkbox,'M3 Roll',handles.listbox1)





function phase_txt_Callback(hObject, eventdata, handles)
phase_txt_input_old = lcaGetSmart(handles.phasePV);
phase_txt_input = str2double(get(hObject,'String'));

if isnan(phase_txt_input)
    set(hObject,'String', phase_txt_input_old);
    else lcaPutSmart(handles.phasePV, phase_txt_input);

    set(handles.listbox1,'String', cat(1, get(handles.listbox1, 'String'),...
        {['Phase Changed from ' num2str(phase_txt_input_old) ' Ang to ' num2str(phase_txt_input) 'Ang  ' datestr(now)]})); drawnow;   
end




function M1Pitch_txt_Callback(hObject, eventdata, handles, tag)
switch tag
    case 'step0', i=3;
    case 'step4', i=2;
    case 'step5', i=1;
end
val = get(handles.M1Pitch_txt,'String');
val = str2double(val{i});
if isnan(val), val=lcaGetSmart(handles.M1PitchActPV); end
M1Pitch_coordinator(handles, val)


function M1Pitch_coordinator(handles, val)
set(handles.M1Pitch_txt,'string',num2str(val, '%.3f'));
set(handles.M1Pitch_slider,'value',val);
SXRSS_textBox(handles.optics.PitchMono2, handles.M1Pitch_txt,handles.active_checkbox,'M1P',handles.listbox1);

function syncSliders(handles)
M1P=lcaGetSmart(handles.M1PitchActPV);  
M3P=lcaGetSmart(handles.M3PitchActPV);      
M3X=lcaGetSmart(handles.M3XActPV);        
delay=lcaGetSmart(handles.delayPV)
set(handles.M1Pitch_slider,'Value', M1P);    
set(handles.M3Pitch_slider,'Value', M3P);    
set(handles.M3X_slider,'Value', M3X);    
set(handles.delay_slider,'Value', delay);    
M1Pitch_coordinator(handles, M1P)
M3Pitch_coordinator(handles, M3P)
M3X_coordinator(handles, M3X)
delay_coordinator(handles, delay)


  
 % --- Executes on slider movement.
function M1Pitch_slider_Callback(hObject, eventdata, handles,tag)
switch tag
    case 'step4', i=2;
    case 'step5', i=1;
end
newVal = get(handles.(['M1Pitch' '_slider']),'value');
M1Pitch_coordinator(handles, newVal{i});



function M3Pitch_txt_Callback(hObject, eventdata, handles, tag)
switch tag
    case 'step0', i=3;
    case 'step4', i=2;
    case 'step5', i=1;
end
val = get(handles.M3Pitch_txt,'String');
val = str2double(val{i});
if isnan(val), val=lcaGetSmart(handles.M3PitchActPV); end
M3Pitch_coordinator(handles, val)


function M3Pitch_coordinator(handles, val)
set(handles.M3Pitch_txt,'string',num2str(val, '%.3f'));
set(handles.M3Pitch_slider,'value',val);
SXRSS_textBox(handles.optics.M3Theta, handles.M3Pitch_txt,handles.active_checkbox,'M3P',handles.listbox1);


% --- Executes on slider movement.
function M3Pitch_slider_Callback(hObject, eventdata, handles,tag)
switch tag
    case 'step4', i=2;
    case 'step5', i=1;
end
newVal = get(handles.(['M3Pitch' '_slider']),'value');
M3Pitch_coordinator(handles, newVal{i});



function M3X_txt_Callback(hObject, eventdata, handles, tag)
switch tag
    case 'step0', i=2;
    case 'step5', i=1;
end
val = get(handles.M3X_txt,'String');
val = str2double(val{i});
if isnan(val), val=lcaGetSmart(handles.M3XActPV); end
M3X_coordinator(handles, val)

function M3X_coordinator(handles, val)
set(handles.M3X_txt,'string',num2str(val, '%.3f'));
set(handles.M3X_slider,'value',val);
SXRSS_textBox(handles.optics.M3X, handles.M3X_txt,handles.active_checkbox,'M3X',handles.listbox1);

    % --- Executes on slider movement.
function M3X_slider_Callback(hObject, eventdata, handles)
newVal = get(handles.(['M3X' '_slider']),'value');
M3X_coordinator(handles, newVal);



function delay_txt_Callback(hObject, eventdata, handles, tag)
switch tag
    case 'step0', i=2;
    case 'step5', i=1;
end
val = get(handles.delay_txt,'String');
val = str2double(val{i});
if isnan(val), val=lcaGetSmart(handles.delayPV); end
delay_coordinator(handles, val)


function delay_slider_Callback(hObject, eventdata, handles)
set(handles.listen_checkbox, 'Value', 1)
newVal = get(handles.(['delay' '_slider']),'value');   
delay_coordinator(handles, newVal);


function delay_coordinator(handles, val)
set(handles.delay_txt,'string',num2str(val, '%3.0f'));
SXRSS_textBoxDelay(handles,'Delay')

function [] =SXRSS_textBoxDelay(handles,logText)
new = str2double(get(handles.delay_txt,'String'));

if strcmp(handles.delayPV(1:4), 'SIOC')
    oldValue =  lcaGetSmart(handles.delayPV);
    handles.delay_old=oldValue;
    guidata(handles.output, handles)
    lcaPutSmart(handles.delayPV, new(1));
    currentValue = lcaGetSmart(handles.delayPV);
else
    lcaPutSmart([handles.delayPV ':DES'], new(1));
    lcaPutSmart([handles.delayPV ':TRIM.PROC'], 1);
    currentValue = lcaGetSmart([handles.delayPV ':ACT']);
end
texts=[logText ' moved from ' num2str(oldValue)   ' to ' num2str(new(1))];
SXRSS_log(handles.listbox1, texts, 1)
if epicsSimul_status
    if strcmp(handles.delayPV(1:4), 'SIOC')
        lcaPutSmart(handles.delayPV, new(1));
    else
        lcaPutSmart([handles.delayPV ':ACT'], new);
    end
end
set(handles.delay_slider,'Value', new(1));  
set(handles.readDelayMono_txt, 'String', num2str(currentValue)) 
handles=adjustChicane(handles,1,0);






function energy_txt_Callback(hObject, eventdata, handles)
val = str2double(get(handles.energy_txt,'String'));
if isnan(val) || val < get(handles.energy_slider,'Min') ...
        || val> get(handles.energy_slider,'Max')
    val= lcaGetSmart(handles.energyPV);
end
energy_coordination(handles, val)


function energy_slider_Callback(hObject, eventdata, handles)
val = get(handles.energy_slider,'value');
energy_coordination(handles, val) 


function energy_coordination(handles, val)
set(handles.energy_txt,'string',num2str(val, '%3.0f'));
set(handles.energy_slider,'value',val);
M1P=SXRSS_mono(val,1);
str_M1P=sprintf('%6.3f', M1P);
set(handles.M1Pitch_txt,'String', str_M1P)
delay=SXRSS_delay(3.85,3.85,0,M1P,15);
str_delay=sprintf('%6.0f', delay);
set(handles.delay_txt,'String', str_delay)


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% 


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor','white',...
             'String', {'Messages'});

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chicanePowerOn_button.
function chicanePowerOn_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value'); % 1 is checked
if val == 1
    lcaPutSmart(handles.tdundPV, 0); %Insert
    control_magnetSet('BXSS2',[],'action','TURN_ON');
    SXRSS_log(handles.listbox1,'TURNED CHICANE POWER ON', val)
    pause(2);
    control_magnetSet('BXSS2',[],'action','STDZ');
    SXRSS_log(handles.listbox1,'Standardizing SXRSS Main complete',val)
    control_magnetSet({'BXSS1T' 'BXSS2T' 'BXSS3T' 'BXSS4T'}, 0,'action','TRIM');
    SXRSS_log(handles.listbox1,'Trim SXRSS Chicane Complete');
elseif val ==0
    SXRSS_log(handles.listbox1,'Not Active...Push Chicane Power ON Button',val)
end


% --- Executes on button press in chicanePowerOff_button.
function chicanePowerOff_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value'); % 1 is checked
if val == 1
    control_magnetSet({'BXSS1T' 'BXSS2T' 'BXSS3T' 'BXSS4T'}, 0,'action','TRIM');
    SXRSS_log(handles.listbox1,'Trim SXRSS Chicane Complete');
    control_magnetSet('BXSS2',[],'action','DEGAUSS');
    SXRSS_log(handles.listbox1,'Chicane Degaussed', val)
elseif val ==0
    SXRSS_log(handles.listbox1,'Not Active...Push Chicane Power OFF Button',val)
end


function handles=adjustChicane(handles,adjust,stdz)
if nargin<3, stdz=0; end;
if nargin<2, adjust=0;end;

energy=lcaGetSmart('BEND:DMP1:400:BDES');

chicanePower=strcmp(lcaGetSmart('BEND:UND1:940:STATE'),'ON');

mode=lcaGetSmart(handles.modePV);   %mode=get(handles.chicaneControl_pmu,'Value');

if chicanePower == 0
    %phase adjust
    Angstroms=lcaGet(handles.phasePV);
    set(handles.phase_txt,'String',sprintf('%3.2f',Angstroms));
    adjust=1;
    lambda=12398.4/lcaGet('SIOC:SYS0:ML00:AO627');
    phase=360*Angstroms/lambda;   %Degrees
    period=floor(phase/360.0);
    phaseDeg=phase-period*360;

    [BDES,theta,Itrim,R56] = BC_phase(Angstroms,energy,'SXRSS');

    if  adjust
        val=get(handles.active_checkbox, 'Value');

        if val == 1
            disp('GUI Active...Setting Mags')
            lcaPutSmart(handles.phaseDegPV, phaseDeg);
            lcaPutSmart(handles.R56PV,R56);
            BDES(1:4)=BDES;
            %lcaPutSmart(handles.bdesPV, BDES(1));
            %removed per Henrik req 8/13
            handles=setMags(handles, BDES);
            handles.delay_old = lcaGetSmart(handles.delayPV);
            guidata(handles.output, handles);
            
        elseif val ==0
            disp('GUI Not Active...Mags Not Set')
            BDES
        end
    end

else
    %delay adjust
    delay=lcaGetSmart(handles.delayPV);
    adjust=1;
    [BDES,iMain,xpos,theta,R56] = BCSS_adjust(delay,energy,'SXRSS');

    val=get(handles.active_checkbox, 'Value');
    if val == 0
        disp('GUI not Active ...Seeded')
    elseif val ==1
        disp('GUI Active ...BDES Change')
        lcaPutSmart(handles.bdesPV, BDES(1));
        lcaPutSmart(handles.R56PV,R56);
        lcaPutSmart(handles.xposPV, 1000*xpos);
    end

    if stdz
        valbykik=lcaGet(handles.bykikPV,0,'short');
        if valbykik == 0  %If beam Disabled
            lcaPutSmart(handles.bykikPV,1); %Enable Beam
        end
        pause(1.);
        val=get(handles.active_checkbox, 'Value'); % 1 is checked
        if val == 1
            disp_log('Standardizing SXRSS Main ...');
            control_magnetSet('BXSS2',BDES(1),'action','STDZ');
            disp_log('Standardizing SXRSS Main complete');
        elseif val ==0
            disp('GUI Not Active...Mags Not STDZ')
        end
    end

    if  adjust
        val=get(handles.active_checkbox, 'Value');

        if val == 1
            disp('GUI Active...Setting Mags')
            handles=setMags(handles, BDES);
        elseif val ==0
            disp('GUI Not Active...Mags Not Set')
            BDES
        end
    end
end
guidata(handles.SXRSS_gui, handles);


function handles=setMags(handles, BDES)
chicanePower=strcmp(lcaGetSmart('BEND:UND1:940:STATE'),'ON');

if chicanePower == 1
    delay=lcaGetSmart(handles.delayPV);
    disp_log(['Delay:' delay]);
    magPV=[handles.magnetMainPV;handles.magnetTrimPV(2:4)];   
else
    phase=lcaGetSmart(handles.phasePV);
    phaseDeg=lcaGetSmart(handles.phaseDegPV);
    disp_log(['Phase: ' phase ' Angstroms; ' sprintf('%6.3f',phaseDeg) ' Degrees']);
    magPV=handles.magnetTrimPV;
end
disp_log('Setting SXRSS magnets to BDES ...');
control_magnetSet(magPV,BDES,'wait',.25)
guidata(handles.SXRSS_gui,handles);


% --- Executes on button press in listen_checkbox.
function listen_checkbox_Callback(hObject, eventdata, handles)
% 


% --- Executes when selected object is changed in uipanel140.
function uipanel140_SelectionChangeFcn(hObject, eventdata, handles)
newButton=get(eventdata.NewValue,'tag');

YVal=[-5.8 -4.3 -2.8 -1.3 0.2 1.5 9.7];
XVal=[0.39 0.37 0.35 0.33 0.31 0.29 0.27];

switch newButton
    case 'radiobutton17'
        YVal=YVal(1);
        XVal=XVal(1);
    case 'radiobutton12'
        YVal=YVal(2);
        XVal=XVal(2);
    case 'radiobutton13'
        YVal=YVal(3);
        XVal=XVal(3);
    case 'radiobutton14'
        YVal=YVal(4);
        XVal=XVal(4);
    case 'radiobutton15'
        YVal=YVal(5);
        XVal=XVal(5);
    case 'radiobutton16'
        YVal=YVal(6);
        XVal=XVal(6);
    case 'radiobutton18'
        YVal=YVal(7);
        XVal=XVal(7);

end

val=get(handles.active_checkbox, 'Value'); % 1 is checked
if val == 1
    disp('GUI Active...Changing SlitY')
    lcaPutSmart('SLIT:UND1:962:Y:DES', YVal);
    lcaPutSmart('SLIT:UND1:962:Y:TRIM.PROC', 1);
    lcaPutSmart('SLIT:UND1:962:X:DES', XVal);
    lcaPutSmart('SLIT:UND1:962:X:TRIM.PROC', 1);
elseif val ==0
    disp('GUI Not Active...')
    disp(YVal)
end

     
% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)
acquireStart(hObject, handles);


function acquireStart(hObject, handles)
handles=appInit(hObject,handles);
tags={'Start' 'Stop'};
cols=[.502 1 .502;1 .502 .502];
style=strcmp(get(hObject,'Type'),'uicontrol');
state=gui_acquireStatusGet(hObject,handles);
if style, set(hObject,'String',tags{state+1},'BackgroundColor',cols(state+1,:));end
if state, profmon_evrSet(handles.PV);end
while gui_acquireStatusGet(hObject,handles)
    handles = grab_image(hObject,handles);
    pause(0.05);
    guidata(hObject,handles); 
    handles=guidata(hObject);
end


function handles = grab_image(hObject, handles)
guidata(hObject,handles);
[d,is]=profmon_names(handles.PV);
nImg=[];
if handles.bufd && is.Bufd
    nImg=0;
    lcaPutSmart([handles.PV ':SAVE_IMG'],1);
end
handles.data=profmon_grab(handles.PV,0,nImg);

profmon_imgPlot(handles.data,'axes',handles.profmon_ax);
guidata(hObject,handles);


function []=SXRSS_logMPS(handle, text,active)
if nargin<3, active=0; end

set(handle,'String', cat(1, get(handle, 'String'),datestr(now), text)); drawnow;
NumItems=get(handle,'String');
[a,b]=size(NumItems);
set(handle,'Listboxtop',a);

if active == 1
    disp_log(text)
end

    
function []=SXRSS_log(handle, text,active)
if nargin<3, active=1; end
set(handle,'String', cat(1, get(handle, 'String'), {[datestr(now) ' ' text ]})); drawnow;
NumItems=get(handle,'String');
[a,b]=size(NumItems);
set(handle,'Listboxtop',a);

if active == 1
    disp_log(text)
end


% --- Executes on button press in lampPowSlit_button.
function lampPowSlit_button_Callback(hObject, eventdata, handles)
status=get(handles.lampPowSlit_button, 'Value');
%profmon_lampSet('YAGBOD1',status,1); %YAGSLIT Lamp is controlled by BOD1 Grid Lamp
profmon_lampSet('YAGS:UND1:1005',status,1);


% --- Executes on button press in updateEnergy_button.
function updateEnergy_button_Callback(hObject, eventdata, handles)
measurePulseEnergy(handles, 0, 5);


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
%



% --- Executes on button press in updateReadbacks.
function updateReadbacks_Callback(hObject, eventdata, handles)
    updateGUInow(hObject,handles)


% --- Executes on button press in bykik_button.
function bykik_button_Callback(hObject, eventdata, handles)
status=lcaGetSmart(handles.bykikPV,0,'double');
if status == 1
    SXRSS_log(handles.listbox1,'Beam Disabled -- BYKIK')
    lcaPutSmart(handles.bykikPV, 0); %Disable Beam
elseif status == 0
    SXRSS_log(handles.listbox1,'Beam Enabled -- BYKIK')
    lcaPutSmart(handles.bykikPV, 1); %Enable Beam
end


function M2X_txt_Callback(hObject, eventdata, handles)
SXRSS_textBox(handles.optics.M2X, handles.M2X_txt,handles.active_checkbox,'M2 X',handles.listbox1)




% --- Executes on button press in trimIn_button.
function trimIn_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value');
if val == 0
    text='GUI not Active...Optics All In Button';
    SXRSS_log(handles.listbox1, text);
elseif val ==1
    SXRSS_log(handles.listbox1,'Beam Disabled -- BYKIK', val)
    lcaPutSmart(handles.bykikPV, 0) %Disable Beam
    lcaPutSmart('GRAT:UND1:934:X:TRIM.PROC',1); %G-M1
    lcaPutSmart('MIRR:UND1:964:X:TRIM.PROC', 1); %M2X
    lcaPutSmart('MIRR:UND1:966:X:TRIM.PROC',1); %M3X
    lcaPutSmart('GRAT:UND1:934:Y:TRIM.PROC', 1); %GY
    lcaPutSmart(handles.M1PitchTrimPV,1); %M1P
    lcaPutSmart('MIRR:UND1:966:P:TRIM.PROC',1); %M3P
    lcaPutSmart('MIRR:UND1:966:O:TRIM.PROC',1); %M3Roll
    
    text='Moving All Optics In - takes a few moments';
    SXRSS_log(handles.listbox1, text);
end
p1=0;p2=1;
while p1~=p2
    G1_old=lcaGetSmart([handles.optics.G1X ':ACT']);
    M2_old=lcaGetSmart([handles.optics.M2X ':ACT']);
    M3_old=lcaGetSmart([handles.optics.M3X ':ACT']);
    slitY_old=lcaGetSmart([handles.slit.slity ':ACT']);
    pause(1);
    G1_new=lcaGetSmart([handles.optics.G1X ':ACT']);
    M2_new=lcaGetSmart([handles.optics.M2X ':ACT']);
    M3_new=lcaGetSmart([handles.optics.M3X ':ACT']);
    slitY_new=lcaGetSmart([handles.slit.slity ':ACT']);

    if G1_old ~= G1_new || M2_old ~= M2_new || M3_old ~= M3_new || slitY_old ~= slitY_new
        text='Insertion Optics Still Moving';
        %SXRSS_log(handles.listbox1, text);
        %disp(text);
    else
        text='Insertion Optics Finished Moving';
        SXRSS_log(handles.listbox1, text);
        p1=1;
    end
end


% --- Executes when user attempts to close SXRSS_gui.
function SXRSS_gui_CloseRequestFcn(hObject, eventdata, handles)

global timerObj;
if ~isempty(timerObj), stop ( timerObj );end
pause (2);
util_appClose(hObject);
pause(2.5);


% --- Executes on button press in updateIn_btn.
function updateIn_btn_Callback(hObject, eventdata, handles)
lcaPutSmart('GRAT:UND1:934:X:IN',lcaGetSmart('GRAT:UND1:934:X:ACT')); 
lcaPutSmart('MIRR:UND1:964:X:IN',lcaGetSmart('MIRR:UND1:964:X:ACT')); 
lcaPutSmart('MIRR:UND1:966:X:IN',lcaGetSmart(handles.M3XActPV)); 
lcaPutSmart('GRAT:UND1:934:Y:IN',lcaGetSmart('GRAT:UND1:934:Y:ACT')); 
lcaPutSmart(handles.M1PitchInPV,lcaGetSmart(handles.M1PitchActPV)); 
lcaPutSmart('MIRR:UND1:966:P:IN',lcaGetSmart(handles.M3PitchActPV)); 
lcaPutSmart('MIRR:UND1:966:O:IN',lcaGetSmart('MIRR:UND1:966:O:ACT')); 




%----General Support Functions

function undKick(handles, nUnd, val)
if isempty(nUnd), return, end
ctrlPV = ['XCOR:UND1:' num2str(nUnd) '80:BCTRL'];
if val
    handles.savedXcor = lcaGetSmart(ctrlPV);
    lcaPutSmart(ctrlPV, -0.006);
    guidata(handles.output, handles)
else
    if isempty(handles.savedXcor)
        lcaPutSmart(ctrlPV, handles.savedXcor)
    else
        lcaPutSmart(ctrlPV, 0)
    end
end


%--------------------------------PROCEDURE START---------------------------
%Procedure for SXRSS GUI, code added by Chris Eckman

%Continue Button is the most important button, this allow the user to move
%to the next step, it also has 8 states that it can exist in, these are:
%handles.step.state1.string = 'Start Procedure';
%handles.step.state2.string = 'Continue >>';
%handles.step.state3.string = 'Running... Press to Abort';
%handles.step.state4.string = 'Start Step >>';
%handles.step.state5.string = 'Aborted: Press to Reset';
%handles.step.state6.string = 'Finished';
%handles.step.state7.string = 'Start Step';
%handles.step.state8.string = 'Show Next Step';
%Coorsponding color and value info for each state are found in:
%handles.step.state??.value 
%handles.step.state??.color 
%where ?? = state number

% --- Executes on button press in continue_btn.
function continue_btn_Callback(hObject, eventdata, handles)

%Make handles first
handles.step.whatBtnPressed = 'continue_btn';
start_btn = handles.step.state1.string;
continue_btn = handles.step.state2.string;
running_btn = handles.step.state3.string;
redo_btn = handles.step.state4.string;
finished_btn = handles.step.state6.string;
startStep_btn = handles.step.state7.string;
showStep_btn = handles.step.state8.string;
btnState = get(handles.continue_btn,'string');
if any(strcmp(btnState,{start_btn; redo_btn; startStep_btn}))
    handles.step.incrementStepWith = 0;
elseif any(strcmp(btnState,{continue_btn; finished_btn; showStep_btn}))
   handles.step.incrementStepWith = 1;
elseif strcmp(btnState,running_btn)
    handles.step.incrementStepWith = NaN;
    makeContinueBtn(handles,5)
end
guidata(hObject, handles);
%Then need to Check the Status 
if checkStatus(hObject, handles); return; end
handles = guidata(hObject);
if changeButtonState(hObject, handles); return; end
handles = guidata(hObject);
%IMPORTANT: This is the peice of code that STARTS EVERY STEP!!!
if strcmp('Running... Press to Abort', get(handles.continue_btn, 'String'))
    eval(strcat('step', num2str(handles.step.currentStep), '_startup(hObject, handles);'));
end
handles = guidata(hObject);
guidata(hObject, handles);   


% --- Executes on button press in go_back_btn.
%This will go back a step
function go_back_btn_Callback(hObject, eventdata, handles)

%do all handles
handles.step.whatBtnPressed = 'go_back_btn';
handles.step.incrementStepWith = -1;
guidata(hObject, handles);
%Check Status
if checkStatus(hObject, handles); return; end
%Change Button accordingly
start_btn = handles.step.state1.string;
if get(handles.step_pause,'value') && ~strcmp(get(handles.continue_btn,'string'),start_btn)
    makeContinueBtn(handles,7)
elseif ~strcmp(get(handles.continue_btn,'string'),start_btn)
    makeContinueBtn(handles,4)
end


% --- Executes on button press in redostep_btn.
%This will redo the current step you are on
function redostep_btn_Callback(hObject, eventdata, handles)

%do all handles
handles.step.whatBtnPressed = 'redostep_btn';    
handles.step.incrementStepWith = 0;
guidata(hObject, handles);
%Check Status
if checkStatus(hObject, handles); return; end
%Change Button accordingly
str=questdlg(['Start Step ', num2str(handles.step.currentStep), '?']);
if strcmp('Yes', str)
    start_btn = handles.step.state1.string;
    if get(handles.step_pause,'value') && ~strcmp(get(handles.continue_btn,'string'),start_btn)
        makeContinueBtn(handles,7)
    elseif ~strcmp(get(handles.continue_btn,'string'),start_btn)
        makeContinueBtn(handles,4)
    end
end


%This will check the status of the the procedure before allowing the code 
%from buttons to run, also checks for possible issues that may arise when 
%pressing buttons
function needReturn = checkStatus(hObject, handles)

running_btn = handles.step.state3.string;
abort_btn = handles.step.state5.string;
showStep_btn = handles.step.state8.string;
finished_btn = handles.step.state6.string;
btnPressed = handles.step.whatBtnPressed;
btnState = get(handles.continue_btn,'string');
needReturn = 1;
if ~get(handles.active_checkbox,'value') 
    waitfor(warndlg('GUI is not active...  Please check "GUI Active".'))
    set(handles.continue_btn,'value',0)
    return
elseif strcmp(get(handles.continue_btn,'string'),running_btn) 
    waitfor(warndlg('Cannot proceed with action when running'))
    set(handles.continue_btn,'value',1)
    return
elseif strcmp(get(handles.continue_btn,'string'),abort_btn)
    %If there are any buttons that need to be reset after abort, put here
    watchoff
    if handles.step.currentStep == 1
        set(handles.step1_start, 'value', 0)
        set(handles.step1_start,'string','Start PMTs Data')
        set(handles.step1_start,'BackgroundColor',[0.502 1 0.502])
    elseif handles.step.currentStep == 4
        if ~strcmp(get(handles.step4_BOD_OR_SLIT_BTN,'string'),'Initialize and Check BOD10')
            str=questdlg('Reset BOD10 to initial conditions?');
            if strcmp('Yes', str)
                sc4d = 'Step4 Comfirmed d:  Move M3 pitch by +1.2 mrad to move back to original.';
                postMessage(handles,sc4d);
                step4_undo_BOD10(hObject, handles)
            end
        end
        set(handles.step4_BOD_OR_SLIT_BTN,'value',0)
        set(handles.step4_BOD_OR_SLIT_BTN,'string','Initialize and Check BOD10')
        set(handles.step4_BOD_OR_SLIT_BTN,'BackgroundColor',[1 0.694 0.392])
        set(handles.step4_BOD_OR_SLIT_TXT,'string','YAGSLIT')
    elseif handles.step.currentStep == 5
        %reset this button
        set(handles.step5_blocked_txt,'visible','off')
        set(handles.step5_block_btn,'value',0)
        set(handles.step5_block_btn,'string','Block Seeding')
        set(handles.step5_block_btn,'BackgroundColor',[0.502 1 0.502])
    elseif handles.step.currentStep == 6
        if strcmp(lcaGetSmart(handles.bod10status),'IN') || strcmp(lcaGetSmart(handles.bod10status),'IN')
            str=questdlg('Reset BOD to initial conditions?');
            if strcmp('Yes', str)
              step6_undo(hObject, handles);
            end
        end
    end
    %avoid the first instance of "abort" being pressed
    if isnan(handles.step.incrementStepWith)
        handles.step.incrementStepWith = 0;
        guidata(hObject, handles);
        return
    end
%    str=questdlg(['Reset Abort for Step ', num2str(handles.step.currentStep), '?']);
    str='Yes';
    if strcmp('Yes', str)
        handles.step.whatBtnPressed = '';
        handles.step.incrementStepWith = 0;
        guidata(hObject, handles);
        changeButtonState(hObject, handles);
    else
        makeContinueBtn(handles,5)
        return
    end
elseif strcmp(get(handles.continue_btn,'string'),finished_btn) && (handles.step.incrementStepWith == 1)
    set(handles.continue_btn,'value',0)
    waitfor(warndlg('Procedure finished, nothing else to run'))
    return
end
needReturn = 0;
handles.step.currentStep = handles.step.incrementStepWith + handles.step.currentStep;
%checks for limits of steps
if handles.step.currentStep >= handles.step.maxStep
    handles.step.currentStep = handles.step.maxStep;
elseif handles.step.currentStep <= 1
    if any(strcmp(btnPressed,{'go_back_btn', 'redostep_btn', 'step_popup'}))
        makeContinueBtn(handles,1)
    end
    handles.step.currentStep = 1;
end
handles.step.incrementStepWith = 0;
guidata(hObject, handles);

%turns off visible for all steps
for n = 1:handles.step.maxStep;
    set(handles.(strcat('step', num2str(n))),'visible','off')
end

%turns on step your intrested in and places the message box in right area
panel_name = strcat('step', num2str(handles.step.currentStep));
set(handles.(panel_name),'visible','on')
set(handles.procedure,'parent',handles.(panel_name))
set(handles.step_popup,'value',handles.step.currentStep)


%This is another inportant function, it allows the button to change states
%and ensures that the correct state is present in the continue button.
function needReturn = changeButtonState(hObject, handles)

start_btn = handles.step.state1.string;
continue_btn = handles.step.state2.string;
redo_btn = handles.step.state4.string;
abort_btn = handles.step.state5.string;
finished_btn = handles.step.state6.string;
startStep_btn = handles.step.state7.string;
showStep_btn = handles.step.state8.string;
btnPressed = handles.step.whatBtnPressed;
btnState = get(handles.continue_btn,'string');
handles.step.whatBtnPressed = '';
guidata(hObject, handles);
needReturn = 1;
%USE CARE when changing any code in this function, fine tuned
if strcmp(btnState,start_btn)
    if strcmp(btnPressed,'continue_btn')
        makeContinueBtn(handles,3)
        needReturn = 0;
    else
        if  handles.step.currentStep == 1;
            makeContinueBtn(handles,1)
        elseif get(handles.step_pause,'value')
            makeContinueBtn(handles,7)
        else
            makeContinueBtn(handles,4)
        end
    end
end

if strcmp(btnState,continue_btn)
    if get(handles.step_pause,'value')
        makeContinueBtn(handles,8)
    elseif ~isempty(btnPressed) && ~strcmp(btnPressed,'step_popup')
        makeContinueBtn(handles,3)
        needReturn = 0;
    else
        makeContinueBtn(handles,4)
    end
end

if strcmp(btnState,finished_btn)
    if get(handles.step_pause,'value')
        makeContinueBtn(handles,7)
    else
        makeContinueBtn(handles,4)
    end
end

if strcmp(btnState,redo_btn)
    if get(handles.step_pause,'value')
        makeContinueBtn(handles,7)
    elseif ~isempty(btnPressed) && ~strcmp(btnPressed,'step_popup')
        makeContinueBtn(handles,3) 
    end
    needReturn = 0;
end

if strcmp(btnState,abort_btn) 
    if  handles.step.currentStep == 1;
        makeContinueBtn(handles,1)
    elseif get(handles.step_pause,'value')
        makeContinueBtn(handles,7)
    else
        makeContinueBtn(handles,4)
    end
end

if strcmp(get(handles.continue_btn,'string'),startStep_btn) 
    if strcmp(btnPressed,'continue_btn')
        makeContinueBtn(handles,3)
        needReturn = 0;
    elseif get(handles.step_pause,'value')
        makeContinueBtn(handles,7)
    else
        makeContinueBtn(handles,4)
    end
end

if strcmp(btnState,showStep_btn) 
    if ~get(handles.step_pause,'value')
        makeContinueBtn(handles,2)
    else
        makeContinueBtn(handles,7)
    end
end


%This checks if a step is ready to be closed out
function needReturn = closeoutCheck(hObject, handles)

start_btn = handles.step.state1.string;
continue_btn = handles.step.state2.string;
redo_btn = handles.step.state4.string;
abort_btn = handles.step.state5.string;
finished_btn = handles.step.state6.string;
startStep_btn = handles.step.state7.string;
showStep_btn = handles.step.state8.string;
btnState = get(handles.continue_btn,'string');    
needReturn = 1;
if ~get(handles.active_checkbox,'value')
    waitfor(warndlg('GUI is not active...  Please check "GUI Active".'))
    return
elseif any(strcmp(btnState,{start_btn; startStep_btn; redo_btn}))
    waitfor(warndlg('Need to start the step first.'))
    return
elseif any(strcmp(btnState,{continue_btn; showStep_btn; finished_btn}))
    waitfor(warndlg('Step already finished.'))
    return
elseif strcmp(btnState,abort_btn)
    waitfor(warndlg('Need to reset the abort button.'))
    return
end
needReturn = 0;
postMessage(handles,'Ending step, one moment please...');

%This closes out a step
function closeoutStep(hObject, handles)
if get(handles.step_pause,'value')
    makeContinueBtn(handles,8)
else
    makeContinueBtn(handles,2)
end
note =  'Ready for new step';
postMessage(handles,note);
set(handles.step4_BOD_OR_SLIT_BTN,'value',0)
set(handles.step4_BOD_OR_SLIT_BTN,'string','Initialize and Check BOD10')
set(handles.step4_BOD_OR_SLIT_BTN,'BackgroundColor',[1 0.694 0.392])

%This checks if a step is not running, used for buttons or inputs that should 
%only work if the step is running, note this is not the case for every 
%button or input.  IF NOT RUNNING = 1 and IF RUNNING = 0
function needReturn = isNotRunning(hObject, handles)

running_btn = handles.step.state3.string;
btnState = get(handles.continue_btn,'string');
if ~strcmp(btnState,running_btn) 
	waitfor(warndlg('This function needs the step to be running first.'))
    needReturn = 1;
    return
end
needReturn = 0;


%The procedure_btn, experts_btn and setting_displays function are used to
%allow access to the SXRSS part of the gui or the procedure part or both
% --- Executes on button press in procedure_btn.
function procedure_btn_Callback(hObject, eventdata, handles)

setting_displays(hObject, handles)


% --- Executes on button press in experts_btn.
function experts_btn_Callback(hObject, eventdata, handles)

setting_displays(hObject, handles)


function setting_displays(hObject, handles)

%main figure = mf and procedure panel = pp
mf = get(handles.SXRSS_gui,'position');
pp = get(handles.procedure_panel,'position');
set(0,'Units','characters');
ss = get(0,'ScreenSize');
set(0,'Units','pixels');

show_procedure = get(handles.procedure_btn,'value');
show_SXRSS = get(handles.experts_btn,'value');

if show_procedure == 0 && show_SXRSS == 1
    set(handles.procedure_btn,'string','Show Procedure')
    set(handles.SXRSS_gui,'position',[mf(1) mf(2) 196 68.75])
elseif show_procedure == 1 && show_SXRSS == 0
    set(handles.experts_btn,'string','Show SXRSS GUI')
    set(handles.SXRSS_panel,'visible','off')
    set(handles.procedure_panel,'position',[0 0 pp(3) pp(4)])
    set(handles.SXRSS_gui,'position',[mf(1) mf(2) 196 55])
elseif  show_procedure == 1 || show_SXRSS == 1
    set(handles.procedure_btn,'string','Hide Procedure')
    set(handles.experts_btn,'string','Hide SXRSS GUI')
    set(handles.procedure_btn,'value',1)
    set(handles.experts_btn,'value',1)
    set(handles.SXRSS_panel,'visible','on')
    if ss(4) < 123.75
        set(handles.SXRSS_gui,'position',[mf(1) mf(2) 2*196 68.75-.35])
        set(handles.procedure_panel,'position',[196 68.75-55 pp(3) pp(4)])
    else
        set(handles.SXRSS_gui,'position',[mf(1) mf(2) 196 123.75])
        set(handles.procedure_panel,'position',[0 68.75 pp(3) pp(4)])
    end
end


%This allows user to bypass to any step
% --- Executes on selection change in step_popup.
function step_popup_Callback(hObject, eventdata, handles)

btnState = get(handles.continue_btn,'string');
abort_btn = handles.step.state5.string;
if strcmp(btnState,abort_btn)
    waitfor(warndlg('Need to reset the abort button.'))
    set(handles.step_popup,'value',handles.step.currentStep)
    return
end
if ~strcmp(get(handles.continue_btn,'string'),'Running... Press to Abort') && get(handles.active_checkbox,'value') 
    str=questdlg('Warning! Other steps may not have been done yet.  Continue?');
    if strcmp('Yes', str)
        handles.step.whatBtnPressed = 'step_popup';
        handles.step.currentStep = get(handles.step_popup,'value');
        handles.step.incrementStepWith = 0;
        guidata(hObject, handles);
        %Check Status
        if checkStatus(hObject, handles); return; end
        handles = guidata(hObject);
        if changeButtonState(hObject, handles); return; end
    else
        set(handles.step_popup,'value',handles.step.currentStep)
    end
else
    if ~get(handles.active_checkbox,'value') 
        waitfor(warndlg('GUI is not active...  Please check "GUI Active".'))
    elseif ~get(handles.continue_btn,'value') || strcmp(get(handles.continue_btn,'string'),'Running... Press to Abort')
        waitfor(warndlg('Cannot skip to step if procedure is running'))
    end
    set(handles.step_popup,'value',handles.step.currentStep)
end


% --- Executes on button press in procedure_log, LOG BUTTON
function procedure_log_Callback(hObject, eventdata, handles, step, comment)
if ishandle(1)
    close(1)
end
if ishandle(2)
    close(2)
end
Pos = get(handles.(step),'position');
Uni = get(handles.(step),'units');
figure(1);
set(1,'units',Uni)
set(1,'position',Pos)
w=warning('off','MATLAB:childAddedCbk:CallbackWillBeOverwritten');
hNew=copyobj(allchild(handles.(step)),1);
pause(0.5)
warning(w);
delete(findobj(hNew,'Visible','off'))
%Then print figure 1 which should only have the visible objects from the GUI.
if ~epicsSimul_status, util_printLog_wComments(1,step,comment,'');end
delete(1);



%This post all the messages and aborts if necessary
function isAborted = postMessage(handles,str)

if strcmp(get(handles.continue_btn,'string'),handles.step.state5.string)
    str = ['Aborted on ' str];
    isAborted = 1;
else
    isAborted = 0;
end
SM = cat(1, get(handles.procedure, 'String'), {[datestr(now), ' ',  str]});
set(handles.procedure,'String', SM); 
set(handles.procedure,'value',size(get(handles.procedure,'String'),1))
disp_log(str);


%This activates the gui, linked to the one on the SXRSS gui
% --- Executes on button press in procedure_active.
function procedure_active_Callback(hObject, eventdata, handles)

set(handles.active_checkbox,'value',get(handles.procedure_active,'value')) 
active_checkbox_Callback(hObject, [], handles)


%This allows a pause before every step
% --- Executes on button press in step_pause.
function step_pause_Callback(hObject, eventdata, handles)

if checkStatus(hObject, handles); return; end
changeButtonState(hObject, handles);


%This moves the undulators in and out
function isAborted = move_undulators_in_out(handles,moveList,InOrOut)

%Only effects undulators that have a check mark in the box...
undulatorCheckBoxCoordinate(handles,moveList)
if InOrOut
    str=questdlg(['These are the undulators to be inserted: ' sprintf('%.0f,', moveList'), '.  Continue?']);
    wordNeeded = 'Inserting';
else
    str=questdlg(['These are the undulators to be extracted: ' sprintf('%.0f,', moveList'), '  Continue?' ]);
    wordNeeded = 'Retracting';
end
isAborted = 0;
if strcmp('Yes', str)
    if postMessage(handles,[wordNeeded, ' Undulators: ' sprintf('%.0f,', moveList')]); return; end
    segmentMoveInOut(moveList,InOrOut);
    if postMessage(handles,['Finished ', wordNeeded, ' Undulators']); return; end
elseif strcmp('Cancel', str)
    isAborted = 1;
end


function isAborted = kick_undulators(handles,moveList,onOrOff)

%Only effects undulators that have a check mark in the box...
undulatorCheckBoxCoordinate(handles,moveList)
if onOrOff
    str=questdlg(['Place a kick in this undulator: ' sprintf('%.0f,', moveList'), '.  Continue?']);
    wordNeeded = 'placeKick';
else
    str=questdlg(['Remove a kick in this undulator: ' sprintf('%.0f,', moveList'), '  Continue?' ]);
    wordNeeded = 'removeKick';
end
isAborted = 0;
if strcmp('Yes', str)
    if postMessage(handles,[wordNeeded, ' Undulators: ' sprintf('%.0f,', moveList')]); return; end
    undKick(handles,moveList,onOrOff);
    if postMessage(handles,['Finished ', wordNeeded, ' Undulators']); return; end
elseif strcmp('Cancel', str) || strcmp('No', str)
    if get(handles.step_und_kick, 'Value') == 1
        set(handles.step_und_kick, 'Value', 0)
        set(handles.step_und_kick, 'String', 'Kick')
    elseif get(handles. step_und_kick, 'Value') ==0
        set(handles.step_und_kick, 'Value', 1)
        set(handles.step_und_kick, 'String', 'Unkick')
    end
    isAborted = 1;
end


function undulatorCheckBoxCoordinate(handles,moveList)

%Only effects undulators that have a check mark in the box...
for x = 1:33
    name = ['und', num2str(x)];
    if ~ismember(x,[9 16 33])
        set(handles.(name),'value',ismember(x,moveList));
    end
end


%This makes the continue button into the proper state by only needing state number
function makeContinueBtn(handles,state)

set(handles.continue_btn, 'string',eval(['handles.step.state',num2str(state),'.string']))
set(handles.continue_btn, 'value',eval(['handles.step.state',num2str(state),'.value']))
set(handles.continue_btn,'BackgroundColor',eval(['handles.step.state',num2str(state),'.color']))


%step_und_kick, step_und_in, and step_und_out all work with moving the
%undulators in and out and kicking them, it will work with the buttons at
%the bottom of the SXRSS gui
% --- Executes on button press in step_und_kick.
function step_und_kick_Callback(hObject, eventdata, handles) %NEED TO ADD
if get(handles.step_und_kick,'value')
    set(handles.step_und_kick,'string','Unkick')
    kick=1;
else
    set(handles.step_und_kick,'string','Kick')
    kick=0;
end
n=1;
moveList = setdiff(1:33,[9 16 33]);
for x = moveList
    name = ['und', num2str(x)];
    undCheckBox(n) = get(handles.(name),'value');
    n = n + 1;
end
moveList = moveList';
moveList(~undCheckBox) = [];
if kick_undulators(handles,moveList,kick); return; end


% --- Executes on button press in step_und_in.
function step_und_in_Callback(hObject, eventdata, handles)

moveList = setdiff(1:33,[9 16 33]);
n = 1;
for x = moveList
    name = ['und', num2str(x)];
    undCheckBox(n) = get(handles.(name),'value');
    n = n + 1;
end
moveList = moveList';
moveList(~undCheckBox) = [];
if move_undulators_in_out(handles,moveList',1); return; end


% --- Executes on button press in step_und_out.
function step_und_out_Callback(hObject, eventdata, handles)

moveList = setdiff(1:33,[9 16 33]);
n = 1;
for x = moveList
    name = ['und', num2str(x)];
    undCheckBox(n) = get(handles.(name),'value');
    n = n + 1;
end
moveList = moveList';
moveList(~undCheckBox) = [];
if move_undulators_in_out(handles,moveList,0); return; end


% --- Executes on button press in steps_revert_btn.
function steps_revert_btn_Callback(hObject, eventdata, handles)

%checks to see if the first and last listed PV exist, it they dont, run the
%initial code that makes the list of PV values
try 
    handles.orig.PV1;
    handles.orig.XTCAV;
catch
   str=questdlg('No initial vlaues yet. Would you like to create them?');
    if strcmp('Yes', str)
        getInitialValues(hObject, handles) 
    end
    return
end
%if the inital list is present, then revert back to the initial values
str=questdlg('This will revert ALL PV''s back to the inital states (when start button was pressed), continue?');
if strcmp('Yes', str)
    putInitialValues(hObject, handles)
end


%Every step is separated by "------STEP??------" and has the following:
%Where ?? = the step number...
%"step??_startup"  --> Used for initialization, seting up or the like...
%"step??_main"     --> Used for main bulk of the step
%Each step also has the comments
% "%Step?? support functions:" --> Used for functions the support step
% "%Step?? Callbacks:"         --> Used for buttons, edits, chk boc, etc...
%ALL FUNCTIONS ASSOCATED WITH A STEP HAVE THE FIRST PART OF THEIR NAME AS:
%                           "step??_   "

%------------------------------STEP1---------------------------------------

function step1_startup(hObject, handles)

%Grabs most of the PV's that are changed in this program, and saves 
%and saves them to "handles.orig.???"...

pause(0.1);

% Reset PMT min colors to black.
for j = 1:4
    set(handles.(['PMT',num2str(j),'_min_txt']),'ForegroundColor',[0 0 0]);
end

% Check gas attenuators.
gasAttnFac =lcaGetSmart('GATT:FEE1:310:R_ACT');

if gasAttnFac < 0.9
    str=questdlg({'Gas Attenuation Factor < 90%' 'Gas attenuators need to be set properly, then proceed with procedure, or abort step now.'}, ...
        'User decision','Proceed','Abort Step','Abort Step');
    if strcmp(str,'Abort Step'),return, end
end

% Get undulator insertion status.
undStat = undStatGet(handles);

% Check if all downstream undulators are inserted.
moveUnd=intersect([10:15 17:32],find(~undStat));
if ~isempty(moveUnd)
    s1a = 'Step 1a:  Inserts all U10-32 undulators.';
    if postMessage(handles,s1a); return; end

    watchon;
    if move_undulators_in_out(handles,moveUnd,1); return; end
    watchoff;
end

str=questdlg({'Is undulator orbit flat (no kick anywhere) and SASE established?' 'Is LEM green?' 'Is the taper from U1-8 linear?' ...
    'Are all undulators inserted?' 'Set laser heater to max energy that preserves FEL performance' 'Were optics motors homed?'...
    'If ALL yes, then proceed with procedure, or abort step now.'}, ...
    'User decision','Proceed','Abort Step','Abort Step');
if strcmp(str,'Abort Step'),return, end

s1note = 'Getting initial PV values...';
if postMessage(handles,s1note); return; end
getInitialValues(hObject, handles) 

s1 = 'Step 1:  PMT Setup';
if postMessage(handles,s1); return; end

s1Note = 'Note: User can manually change PMT''s gain if necessary.';
if postMessage(handles,s1Note); return; end

PMT_VS=lcaGetSmart(handles.voltPVs);
step1_PMT_VSet_Stuff(hObject,handles,1:4,PMT_VS);

step1WhileLoop(hObject, handles)


function PMT = step1_main(hObject, handles, counter, PMT)
    
n = mod(counter,31);
if n == 0
    for j=1:4
        AvgMinPMT = step1_outlierSearch(min(PMT(:,:,j),[],2));
        set(handles.(['PMT' num2str(j) '_min_txt']),'String',AvgMinPMT);
    end
    PMT = [];
    step1_PMTGainAutoChange(hObject,handles)
    return
end

PMT(n,:,:) = PMT_acquireData(handles);


%Step1 support functions:

function step1WhileLoop(hObject, handles)

s1a = 'Step 1a:  Display the four PMT''s and display average minimum point.';
if postMessage(handles,s1a); return; end

%setting the button up
set(handles.step1_start,'String','Stop PMTs Data','BackgroundColor',[1 0.377 0.419],'Value',1);

%Runs the loop for the PMTs
PMT = [];
n = 0;
while get(handles.step1_start,'Value') 
    handles = guidata(hObject);
    n = n + 1;
    if strcmp(get(handles.continue_btn,'String'),'Aborted: Press to Reset');break, end
    PMT = step1_main(hObject,handles,n,PMT);
    pause(0.001);
end
if postMessage(handles,'Stopped Reading PMT Data'); return; end


function PMT = PMT_acquireData(handles)

PVs = strcat('DIAG:FEE1:202:',{'241';'242';'361';'362'},':Data');
PMT = lcaGetSmart(PVs)';

numRange = -30000:10000:30000;
axisRange = [0 500 -33000 33000];

for j=1:4
    h=handles.(['PMT' num2str(j)]);
    plot(h,PMT(:,j));
    axis(h,axisRange);
    grid(h);
    title(h,['PMT ' num2str(j)]);
    set(h,'YTick',numRange,'YTickLabel',numRange);
end


function check_gDetNoise(handles)

s2i = ['checks GDET setup for the RMS jitter with the beam on BYKick to see if it is >> 1 ',char(956),'J'];
if postMessage(handles,s2i); return; end
gasAttnFac =lcaGetSmart('GATT:FEE1:310:R_ACT');

if gasAttnFac < 0.9
   waitfor(warndlg('Gas Attenuation Factor < 90%'))
   return
end

rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE'); 
pause(120/rate);
gasData=lcaGet(handles.gasPV);
gasData(1:end-120)=[];
stdError=std(gasData)/sqrt(120);
meanGasBG=mean(gasData);
stdErrorstr = sprintf('%.2f',stdError*1e3);
if postMessage(handles,['Standard Error for background ',num2str(stdErrorstr),' ',char(956),'J.']); return; end 
meanGasBGstr = sprintf('%.2f',meanGasBG*1e3);
if postMessage(handles,['Mean for background ',num2str(meanGasBGstr),' ',char(956),'J.']); return; end
if postMessage(handles,'BYKick set to enable beam'); return; end
lcaPutSmart(handles.bykikPV, 1); 
set(handles.step2_display,'String',stdErrorstr)
if stdError > 1e-3
    if postMessage(handles,['More than 1 ',char(956),'J noise. Aborting']); return; end
    waitfor(warndlg('More than 1 uJ noise. Aborting'))
    return
else
    if postMessage(handles,['Within the 1 ',char(956),'J noise limit.']); return; end
end


function step1_PMTGainAutoChange(hObject, handles)

CheckVal(1) = str2double(get(handles.PMT1_min_txt,'String'));
CheckVal(2) = str2double(get(handles.PMT2_min_txt,'String'));
CheckVal(3) = str2double(get(handles.PMT3_min_txt,'String'));
CheckVal(4) = str2double(get(handles.PMT4_min_txt,'String'));

maxR = str2double(get(handles.step1_PMT_max,'String'));
minR = str2double(get(handles.step1_PMT_min,'String'));
%+ or - 10000 to existing range for big steps
bigStepsMax = maxR + 10000;
bigStepsMin = minR - 10000;
%wanted range is in (minR < VSetChange < maxR)

if (minR > 32000 || minR < -32000) || isnan(minR)
    warndlg('Please choose a number between 32000 to -32000')
    set(handles.step1_PMT_min,'String',-1000)
    minR = str2double(get(handles.step1_PMT_min,'String'));
end
if (maxR > 32000 || maxR < -32000) || isnan(maxR)
    warndlg('Please choose a number between 32000 to -32000')
    set(handles.step1_PMT_max,'String',1000)
    maxR = str2double(get(handles.step1_PMT_max,'String'));
end
if (maxR < minR || minR > maxR) 
    warndlg('Check your Min and Max range limits')
    set(handles.step1_PMT_max,'String',1000)
    set(handles.step1_PMT_min,'String',-1000)
    maxR = str2double(get(handles.step1_PMT_max,'String'));
    minR = str2double(get(handles.step1_PMT_min,'String'));
end
%For big steps, Voltage steps of +15
biginRange = find(bigStepsMin < CheckVal & CheckVal < bigStepsMax);
bigaboveRange = find(bigStepsMax < CheckVal);
bigbelowRange = find(bigStepsMin > CheckVal);
biga = [biginRange' (zeros(length(biginRange),1))];
bigb = [bigaboveRange' (ones(length(bigaboveRange),1)*15)];
bigc = [bigbelowRange' (ones(length(bigbelowRange),1)*-15)];
bigVSetChange = sortrows([biga; bigb; bigc],1);

%for small steps, Voltage steps of 10
inRange = find(minR < CheckVal & CheckVal < maxR);
aboveRange = find(maxR < CheckVal);
belowRange = find(minR > CheckVal);
a = [inRange' (zeros(length(inRange),1))];
b = [aboveRange' (ones(length(aboveRange),1)*10)];
c = [belowRange' (ones(length(belowRange),1)*-10)];
VSetChange = sortrows([a; b; c],1);

VSetChange = [VSetChange(:,1) (bigVSetChange(:,2)+VSetChange(:,2))];

%show red or green on display for values out of and in the range defined
for goodVal = a(:,1)'
    set(handles.(['PMT',num2str(goodVal),'_min_txt']),'ForegroundColor',[0.502 1 0.502])%green
end
for badVal = [b(:,1); c(:,1)]'
    set(handles.(['PMT',num2str(badVal),'_min_txt']),'ForegroundColor',[1 0.377 0.419])%red
end   

if ~get(handles.step1_manually,'Value')    
    f1 = get(handles.PMT1_min_txt,'ForegroundColor') == [0.502 1 0.502];
    f2 = get(handles.PMT2_min_txt,'ForegroundColor') == [0.502 1 0.502];
    f3 = get(handles.PMT3_min_txt,'ForegroundColor') == [0.502 1 0.502];
    f4 = get(handles.PMT4_min_txt,'ForegroundColor') == [0.502 1 0.502];
    if (length(a(:,1)) == 4) && all([f1 f2 f3 f4])
        step1_confirmed_Callback(hObject, [], handles)
        return
    end
    VSetOrig = lcaGetSmart(handles.voltPVs);
    step1_PMT_VSet_Stuff(hObject,handles,1:4,VSetOrig+VSetChange(:,2));
end


function outlist = step1_outlierSearch(inlist)

sortedlist = sort(inlist);
%any discontinuities with difference of over 10000 will be cut
D = find(diff(sortedlist) > 10000);
if isempty(D)
    D = size(sortedlist,1);
end
minlist = sortedlist(1:D);
outlist = mean(minlist);


function step1_PMT_VSet_Stuff(hObject, handles, PMTNum, setvalue)

PV = handles.voltPVs(PMTNum);
origVal = lcaGetSmart(PV);

if isNotRunning(hObject, handles)
    setvalue = origVal;
end

for j=1:numel(PMTNum)
    name = ['step1_PMT',num2str(PMTNum(j)),'_VSet_edt'];
    if origVal(j) ~= setvalue(j)
        str = ['Changing PMT' num2str(PMTNum(j)) ' with a PV of ' PV{j} ' from ' ...
           num2str(origVal(j)) ' to ' num2str(setvalue(j))];
        postMessage(handles,str);
        lcaPutSmart(PV(j),setvalue(j));
    end
    set(handles.(name),'String',setvalue(j));
end
PMT_acquireData(handles);


%Step1 Callbacks:

function step1_PMT1_VSet_edt_Callback(hObject, eventdata, handles)

step1_PMT_VSet_Stuff(hObject,handles,1,str2double(get(hObject,'String')));


function step1_PMT2_VSet_edt_Callback(hObject, eventdata, handles)

step1_PMT_VSet_Stuff(hObject,handles,2,str2double(get(hObject,'String')));


function step1_PMT3_VSet_edt_Callback(hObject, eventdata, handles)

step1_PMT_VSet_Stuff(hObject,handles,3,str2double(get(hObject,'String')));


function step1_PMT4_VSet_edt_Callback(hObject, eventdata, handles)

step1_PMT_VSet_Stuff(hObject,handles,4,str2double(get(hObject,'String')));


% --- Executes on button press in step1_start.
function step1_start_Callback(hObject, eventdata, handles)

if isNotRunning(hObject, handles)
    set(handles.step1_start,'Value',0);
end
if get(handles.step1_start,'Value')  
    step1WhileLoop(hObject, handles)
else
    set(handles.step1_start,'String','Start PMTs Data','BackgroundColor',[0.502 1 0.502],'Value',0);
end


function step1_manually_Callback(hObject, eventdata, handles)


function step1_PMT_max_Callback(hObject, eventdata, handles)


function step1_PMT_min_Callback(hObject, eventdata, handles)


% --- Executes on button press in step1_confirmed.
function step1_confirmed_Callback(hObject, eventdata, handles)

if closeoutCheck(hObject, handles); return; end
set(handles.step1_start,'Value',0)
step1_start_Callback(hObject, [], handles)
s1b =  'Step 1b:  Presses ''-->E-Log'' button in SXRSS GUI.';
if postMessage(handles,s1b); return; end
procedure_log_Callback(hObject, [], handles,'step1','SXRSS PMT Calibration')
closeoutStep(hObject, handles);


%------------------------------STEP2---------------------------------------

function step2_startup(hObject, handles)

s2 = 'Step 2:  Recalibrate gas detector with Eloss';
if postMessage(handles,s2); return; end
cla(handles.step2_plot);
step2_main(hObject, handles)


function step2_main(hObject, handles)

s2a = 'Step 2a:  Disables undulator 16 feedback.';
if postMessage(handles,s2a); return; end
lcaPutSmart('SIOC:SYS0:ML00:AO818',0)

s2b = 'Step 2b:  Opens E loss scan GUI.';
if postMessage(handles,s2b); return; end
[ho,h]=util_appFind('E_loss_scan');

s2b2 = 'Step 2b2:  Presses ''Calibrate'' button in ''E-loss/Ampere Calibration'' section in E loss scan GUI.';
if postMessage(handles,s2b2); return; end
set(h.CALIBRATE,'value',1)
E_loss_scan('CALIBRATE_Callback',h.CALIBRATE,[],guidata(ho));

s2c = 'Step 2c:  Presses ''Start'' button in ''E-loss Data Acquisition'' section in E loss scan GUI.';
if postMessage(handles,s2c); return; end
set(h.START,'value',1)
E_loss_scan('START_Callback',h.START,[],guidata(ho));

s2d = 'Step 2d:  Presses ''Cal all GDET'' button in ''FEE Detector Calibrations'' section in E loss scan GUI.';
if postMessage(handles,s2d); return; end
E_loss_scan('CAL_ALL_DET_Callback',ho,[],guidata(ho));

s2e = 'Step 2e:  BYKick set to disable beam';
if postMessage(handles,s2e); return; end
lcaPutSmart(handles.bykikPV, 0);

s2f = 'Step 2f:  Presses ''Zero offsets'' button in ''FEE Detector Calibrations'' section in E loss scan GUI.';
if postMessage(handles,s2f); return; end
E_loss_scan('zero_offs_button_Callback',ho,[],guidata(ho));

s2g = 'Step 2g:  Displays plot generated in the GUI.';
if postMessage(handles,s2g); return; end
cla(handles.step2_plot);
copyobj(allchild(h.AXES1),handles.step2_plot);

s2h = 'Step 2g:  Presses ''-->E-Log'' button in ''FEE Detector Calibrations'' and in ''E-loss Data Acquisition'' sections in E loss scan GUI.';
if postMessage(handles,s2h); return; end
E_loss_scan('ELOG_Callback',ho,[],guidata(ho));
E_loss_scan('ELOG_DET_CAL_Callback',ho,[],guidata(ho));

%moved to beginning of the first step
check_gDetNoise(handles); 

s2h =  'Step 2h:  Presses ''-->E-Log'' button in SXRSS GUI.';
if postMessage(handles,s2h); return; end

close(ho);

if closeoutCheck(hObject, handles); return; end
closeoutStep(hObject, handles);


%Step2 support functions:


%Step2 Callbacks:


%------------------------------STEP3---------------------------------------

function step3_startup(hObject, handles)

s3 = 'Step 3:  Measures gain lengths for undulators 5-8';
if postMessage(handles,s3); return; end

step3_main(hObject, handles)


% ------------------------------------------------------------------------
function step3_main(hObject, handles)

% Provide option for "quick" energy check.
s3aa = 'User query for recheck mode during step 3';
if postMessage(handles,s3aa); return; end
str=questdlg(['This provides the option to do a recheck version of step 3 which should only ' ...
    'be used to recheck the U1-8 pulse energy after changes to the accelerator setup'], ...
    'Recheck Mode','Normal','Recheck','Cancel','Normal');
if strcmp(str,'Cancel')
    return
end
fullMode=strcmp(str,'Normal');
updateGUInow(hObject,handles);
s3a = 'Step 3a:  Checks to see if optics and undulators 10-33 are inserted, if so, user dialog will appear.';
if postMessage(handles,s3a); return; end

% Get undulator insertion status.
undStat = undStatGet(handles);

% Move detuned undulator back.
use=find(undStat(1:8),3);
if numel(use == 3)
    PV = model_nameConvert(cellstr(num2str(use(:),'US%02d')));
    kDes = lcaGetSmart(strcat(PV,':KDES'));
    kDes1=kDes(2)-diff(kDes(2:3));
    lcaPutSmart(strcat(PV(1),':KDES'),kDes1);
    lcaPutNoWait(strcat(PV(1),':TRIM.PROC'),1);
end

moveInUnd = [];choice1='';
if any(~undStat(1:8)) && fullMode
    choice1 = questdlg('Do you want to insert undulators 1-8 or keep current configuration?', ...
        'User decision','Insert 1-8','Keep current configuration','Cancel','Cancel');
    if strcmp(choice1,'Insert 1-8')
        moveInUnd = 1:8;
        undulatorCheckBoxCoordinate(handles,moveInUnd)
        segmentMoveInOut(moveInUnd,1,1);
    elseif strcmp(choice1,'Cancel')
        return
    end
end

moveOutUnd = [];
if any(undStat([10:15 17:32]))
    choice = questdlg('Remove Undulators 10-32 (default)?', ...
        'User decision', ...
        'Remove 10-32','Keep Current Configuration','Cancel','Remove 10-32');
    if strcmp(choice,'Remove 10-32')
        moveOutUnd = setdiff(10:33,[9 16 33]);
        undulatorCheckBoxCoordinate(handles,moveOutUnd)
        segmentMoveInOut(moveOutUnd,0,1);
    elseif strcmp(choice,'Cancel')
        return
    end
end

opticsStat=lcaGetSmart(handles.optics.status);
if ~all(strcmp(opticsStat,'OUT'))
    if postMessage(handles,'Taking a moment to remove optics'); return; end
    watchon;
    opticsAllOut_button_Callback(hObject, [], handles);
end

watchon;
segmentMoveWait(union(moveInUnd,moveOutUnd));
lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL', 1); % Enable beam no matter what
watchoff;

% Get present undulator insertion status.
undStat = undStatGet(handles);

% Do gain length measurement.
if fullMode

    % Provide chance to clean up dump orbit.
    questdlg({'Check if dump orbit is good to avoid MPS trips.' 'Manually steer if necessary.' 'Will now proceed with gain length.'}, ...
        'Check Dump Orbit','Proceed','Proceed');

    s3b = 'Gain Length GUI opened';
    if postMessage(handles,s3b); return; end
    [ho,h]=util_appFind('GainLengthGUI');

    s3c = 'Step 3c:  Changes values to 5-8 ''Undulator range:'' edit boxes in ...''Acquisition:Auto Run'' section in GainLengthGUI.';
    if postMessage(handles,s3c); return; end

    %measures gain length for undulators From (F) 5 To (T) 8
    % F = str2double(get(handles.step3_from,'string'));
    % T = str2double(get(handles.step3_to,'string'));
    F=handles.step3_from;
    T=handles.step3_to;
    if ~undStat(8), T=7; end

    set(h.LOOPBEG,'string', F)
    set(h.LOOPEND,'string', T)
    notestep1 = ['Running scan for undulators ' num2str(F) ' - ' num2str(T)];
    if postMessage(handles,notestep1); return; end 

    %Presses Start button in Acquisition(Auto Run) section in GainLengthGUI
    s3d = 'Start Gain Length Data Acquisition';
    if postMessage(handles,s3d); return; end

    h.online=~epicsSimul_status;
    set(h.STARTMEAS,'value',1)
    GainLengthGUI('STARTMEAS_Callback',h.STARTMEAS,[],h)

    %Changes values to 5-7 "First Und for GL Fit" and "Last Und for GL Fit" 
    %edit boxes in "Analysis: Gain Length Fit" section in GainLengthGUI
    s3e = 'Set Cut Off Low/High in GL GUI';
    if postMessage(handles,s3e); return; end
    set(h.CUTOFFLOW,'string','5')
    set(h.CUTOFFHIGH,'string','7')

    %Displays the plot generated and the ''Measured Gain Length(m)'' value 
    %found in ...''Gain Length Results'' section in GainLengthGUI (gain 
    %length should be <= 2 m).
    s3f = 'Display Measured GL(m) (should be <= 2 m)';

    if postMessage(handles,s3f); return; end
    h = guidata(ho);
    if isempty(h.data)
        waitfor(warndlg('GUI not returning data, please check GUI'))
        return
    end
    Position = [h.data.pos]';
    Energies = [h.data.plot_power]';
    if epicsSimul_status
        Energies=[.1 1 10 100]'*1e-3;
        Position=[5 6 7 8]'*3.35;
    end
    semilogy(handles.step3_plot,Position,Energies,'go');
    set(handles.step3_plot,'YMinorTick','on');
    grid(handles.step3_plot,'on');
    set(handles.step3_plot,'YMinorGrid','off');
    numberofundulators = h.und_num;
    %undulatorlength = 3.35
    xlim(handles.step3_plot,[0 (numberofundulators+1)*3.35]);
    ylim(handles.step3_plot,[min(Energies)/5 max(Energies)*5])
    copyobj(allchild(h.GLAX),handles.step3_plot);
    %post the measured gain length
    set(handles.measured_gain_txt,'string',get(h.MEASGAINL,'string'))
    if postMessage(handles,['Measured Gain Length (m): ', get(h.MEASGAINL,'string')]); return; end

    s3g = 'Step 3g:  Presses ''-->Log Book'' button in GainLengthGUI.';
    if postMessage(handles,s3g); return; end
    if ~epicsSimul_status, GainLengthGUI('LOG_Callback',ho,[],h);end
    close(ho)
end

% Check for undulator 8.
keepUnds = undStat(1:8);
fudge=1;
if fullMode && undStat(8) && ~strcmp(choice1,'Keep Current Configuration')
    str=questdlg('Remove Undulator 8? (Default OUT unless PhotE < 700eV)');
    if strcmp('Yes', str)
        keepUnds(8) = [];
        Energies(1) = []; % Energies are in order U8 - 5
        fudge=4;
    elseif strcmp('Cancel', str)
        return
    end
end

if fullMode
    dropUnd = sum(Energies > 2e-3/fudge)-1;
    if dropUnd > 0, keepUnds(find(keepUnds,dropUnd))=0;end
    if dropUnd < 0, keepUnds(find(~keepUnds(1:7),1,'last'))=1;end
end

keepUnds = find(keepUnds)';
% Note 9 and 16 are not undulators, so keep out of list
moveUnd3 = setdiff(1:33,[keepUnds 9 16 33]);

%Pulse Energy min's and max's
fudgeFactor = 1+3*ismember(8,keepUnds);
PEmin = 2/fudgeFactor;
PEmax = 5/fudgeFactor;
s3h = ['Step 3h:  Finds the first ''n'' undulators needed to produce pulse energies above ',num2str(PEmin),' ', char(956),'J.'];
if postMessage(handles,s3h); return; end
notestep2 = ['Chosen undulator(s) are: ', num2str(keepUnds)];
if postMessage(handles,notestep2); return; end

% Insert undulator if not enough undulators.
moveUnd4=intersect(keepUnds,find(~undStat(1:8)));
if ~isempty(moveUnd4)
    s3error=['Pulse energy too low, insert Und ' num2str(moveUnd4) ' ?'];
    if postMessage(handles,s3error); return; end
    str=questdlg(s3error);
    if strcmp('Yes', str)
        undulatorCheckBoxCoordinate(handles,moveUnd4);
        segmentMoveInOut(moveUnd4,1,1);
    end
end

% Only move presently inserted undulators.
moveUnd3=intersect(moveUnd3,find(undStat));
if ~isempty(moveUnd3)
    s3i = 'Step 3i:  Retracts all except the ''n'' undulators chosen.';
    if postMessage(handles,s3i); return; end

    watchon;
    if move_undulators_in_out(handles,moveUnd3,0); return; end
    watchoff;
end

segmentMoveWait(union(moveUnd3,moveUnd4));
lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL', 1); % Enable beam no matter what

% Provide option to do SVD steering.
if fullMode
    s3gi = 'Check if orbit flat between U1-8.  If not, do you want to do SVD steering?';
    if postMessage(handles,s3gi); return; end
    str=questdlg(s3gi, 'Steering', 'Steer', 'Leave As is','Cancel','Steer');
    if strcmp('Steer', str)
	    [ho,h]=util_appFind('bba_gui');
        bba_gui('setOrbitCorr_btn_Callback',ho,[],h);
        bba_gui('sectorControl',ho,guidata(ho),'UND');
        bba_gui('acquireCurrentGet_btn_Callback',ho,[],guidata(ho));
        bba_gui('txtControl',ho,guidata(ho),'corrGain',1);
        bba_gui('applyCorrs_btn_Callback',ho,[],guidata(ho));
	    close(ho);
    elseif strcmp('Cancel', str)
        return
    end
end

s3j = ['Step 3j:  Checks to see if the pulse energy is between ', num2str(PEmin),' ', char(956),'J and ', num2str(PEmax),' ', char(956),'J.'];
if postMessage(handles,s3j); return; end

[meanGas,inRange,aboveRange] = measurePulseEnergy(handles, PEmin, PEmax);

% Get present undulator insertion status.
undStat = undStatGet(handles);

if ~(inRange || aboveRange)
    insertUnd=find(~undStat(1:7),1,'last');
    if isempty(insertUnd)
       s3berror='No more upstream undulators to insert, pulse energy too low, abort step to continue';
        if postMessage(handles,s3berror); return; end
        return
    end
    s3error=['Pulse energy found below range, insert Und ' num2str(insertUnd) ' ?'];
    if postMessage(handles,s3error); return; end
    
    str=questdlg(s3error);
    if strcmp('Yes', str)
        watchon;
        if move_undulators_in_out(handles,insertUnd,1); return; end
        watchoff;
        [meanGas,inRange,aboveRange] = measurePulseEnergy(handles,PEmin,PEmax);
        
        if ~(inRange || aboveRange)
            s3berror='Pulse energy still found below range, please check unds';
            if postMessage(handles,s3berror); return; end
            return
        end
    else
        if postMessage(handles,'Insert Und Aborted'); return; end
        return
    end
end

if aboveRange
    str=questdlg('Run undulator K detune process. Proceed?');
    if strcmp('Yes', str)
        s3k = 'Step 3k:  Run undulator K detune process. Proceed?';
        if postMessage(handles,s3k); return; end
    else
        if postMessage(handles,'Undulator K detune process Aborted'); return; end
        return
    end

    s3l = ['Step 3l:  Changing K for the first undulator in chosen range till pulse energy is between ', num2str(PEmin),char(956),'J and ', num2str(PEmax),char(956),'J.'];
    if postMessage(handles,s3l); return; end
    %then if while condition met, detune the first undulator 

    % Find detuning undulator.
    taperingUnd=find(undStat,1);

    PV = ['USEG:UND1:',num2str(taperingUnd), '50:'];
    currVal = lcaGetSmart([PV, 'KDES']); 
    detune_start = ['Detuning undulator number ',num2str(taperingUnd),' with initial field strength at: ', num2str(currVal)];
    if postMessage(handles,detune_start); return; end
    set(handles.step3_detune_panel,'title',detune_start)
    newVal = currVal;
    %Increment Amount = IA
    IA = 0.003;
end

while aboveRange
    pause(1)
    prevVal = newVal;
    newVal = newVal-IA;
    field_txt = ['Moving field strength from: ', num2str(prevVal),' to ', num2str(newVal)];
    if postMessage(handles,field_txt); return; end
    set(handles.step3_detune1,'string',field_txt)

    lcaPutSmart([PV, 'KDES'], newVal);
    lcaPutNoWait([PV, 'TRIM.PROC'], 1);

    while any(strcmp(lcaGet([PV, 'LOCATIONSTAT']),'MOVING')), pause(1);end

    [meanGas,inRange,aboveRange] = measurePulseEnergy(handles, PEmin, PEmax);
    meanGasstr = sprintf('%.2f',meanGas*1e3);

    detune_txt = ['Field strength of ',num2str(newVal),' with energy of ',num2str(meanGasstr),' ',char(956),'J.'];
    set(handles.step3_detune2,'string',detune_txt)

    if postMessage(handles,detune_txt); return; end
    if newVal <= 3.43 && (~inRange || aboveRange)
        if postMessage(handles,'Could not find right energy range. Aborted'); end
        lcaPutSmart([PV, 'KDES'], currVal);
        lcaPutNoWait([PV, 'TRIM.PROC'], 1);
        waitfor(warndlg('Could not find right energy range, Please check it manually.'))
        set(handles.step3_manually,'value',1)
        step3_manually_Callback(hObject, [], handles)
        return
    end
end

if closeoutCheck(hObject, handles); return; end
closeoutStep(hObject, handles);


%Step3 support functions:

function val = undStatGet(handles)

% Returns logical array of undulator status, Inserted (1), retracted (0)
val=lcaGetSmart(handles.readback.undPV.double) <= 50;


%Step3 Callbacks:

% --- Executes on button press in step3_manually.
function step3_manually_Callback(hObject, eventdata, handles)

str={'off' 'on'};
set([handles.step3_E_btn handles.step3_confirmed], ...
    'Visible',str{get(handles.step3_manually,'Value')+1});


% --- Executes on button press in step3_E_btn.
function step3_E_btn_Callback(hObject, eventdata, handles)
if closeoutCheck(hObject, handles); return; end
Val = get(handles.uipanel54,'BackgroundColor');   %out[1 0 0]
if all(ismember(Val{1},[1 0 0]))
    fudgeFactor = 1;
else
    fudgeFactor = 4;
end
PEmin = 3/fudgeFactor;
PEmax = 5/fudgeFactor;
measurePulseEnergy(handles,PEmin,PEmax);


function step3_to_Callback(hObject, eventdata, handles)


function step3_from_Callback(hObject, eventdata, handles)


% --- Executes on button press in step3_confirmed.
function step3_confirmed_Callback(hObject, eventdata, handles)
if closeoutCheck(hObject, handles); return; end
closeoutStep(hObject, handles);


%------------------------------STEP4---------------------------------------


function step4_startup(hObject, handles)
s4 =  'Step 4:  Change to Seeded Mode and checks optics setup';
if postMessage(handles,s4); return; end
step4_main(hObject, handles)


function step4_main(hObject, handles) 

s4a = 'Step 4a:  Presses ''Seeded'' button in ''SXRSS_gui'', this will set the photon energy, turn on the chicane, and inserts optics.';
if postMessage(handles,s4a); return; end
%and at the same time...
s4b = 'Step 4b:  Inserts undulators';
if postMessage(handles,s4b); return; end

%moveunds = checkUnds(handles, 10,32,'IN');
%Move undulators 10:33
moveUnd4 = setdiff(10:33,[9 16 33]);
str=questdlg(['Do you want to go to seeded mode and insert undulators 10-32? ' '      (Default = Yes) ' ]);
if strcmp('Yes', str)
    if postMessage(handles,'This will take a few minutes...'); return; end
        lcaPutSmart(handles.tdundPV, 0);
        undulatorCheckBoxCoordinate(handles,moveUnd4)
        segmentMoveInOut(moveUnd4,1,1);
        watchon;
        seeded_button_Callback(hObject, [], handles);
        segmentMoveWait(moveUnd4);
        watchoff;
        checkOptics(handles,'IN');
        lcaPutSmart(handles.tdundPV, 1);
        lcaPutSmart(handles.bykikPV, 1);
elseif strcmp('Cancel', str)
    return
end

syncSliders(handles)

s4c = 'Step 4c:  Would you like to SVD Steer?';
if postMessage(handles,s4c); return; end
str=questdlg(s4c,'Steering', 'Steer','Leave As is','Cancel','Steer');
if strcmp('Steer', str)
	[ho,h]=util_appFind('bba_gui');
    bba_gui('setOrbitCorr_btn_Callback',ho,[],h)
    bba_gui('sectorControl',ho,guidata(ho),'UND');
    bba_gui('acquireCurrentGet_btn_Callback',ho,[],guidata(ho))
    bba_gui('txtControl',ho,guidata(ho),'corrGain',1);
    bba_gui('applyCorrs_btn_Callback',ho,[],guidata(ho))
	close(ho);
elseif strcmp('Cancel', str)
    return
end


s4d = 'Step 4d:  Undulator 16 feedback enabled';
if postMessage(handles,s4d); return; end

    lcaPutSmart('SIOC:SYS0:ML00:AO818',1)


s4e = 'Step 4e:  Turn OFF XTCAV (or it will disturb orbit in dump and screw up wirescans)';
if postMessage(handles,s4e); return; end
    control_klysStatSet('XTCAV',0);
s4f = 'Step 4f:  Hit radio button to move to 100 um position.';
if postMessage(handles,s4f); return; end
    set(handles.radiobutton12,'value',1)
    uipanel140_SelectionChangeFcn(hObject, struct('NewValue',handles.radiobutton12), handles)

str=questdlg('Intensity Measurement? (Default = No)');
if strcmp('Yes', str)
    intensity_Callback(hObject, [], handles)
end

step4_BOD_OR_SLIT_BTN_Callback(hObject, [], handles)


%Step4 support functions:

function step4_undo_BOD10(hObject, handles) 
status=lcaGetSmart('BOD:UND1:1005:LOCATIONSTAT');
if strcmp(status, 'IN')
    str=questdlg('Extract BOD10?');
    if strcmp('Yes', str)
        sc4b = 'Extracts BOD10';
        postMessage(handles,sc4b);
        set(handles.radiobuttonU10, 'Value',1)
        eventdata.NewValue = handles.radiobuttonU10;
        uipanel401_SelectionChangeFcn(handles.output, eventdata, handles)
        set(handles.radioU10_btn, 'Value',1)
        eventdata.NewValue = handles.radioU10_btn;
        uipanel389_SelectionChangeFcn(handles.output, eventdata, handles);
        bodOut_btn_Callback(hObject, [], handles)
        sc4d = 'Moving M3 pitch back to insert position.';
        postMessage(handles,sc4d);
        lcaPutSmart('MIRR:UND1:966:P:INSERT.PROC',1)
        warndlg('Change beam rate 120 Hz?');
        
    elseif strcmp('No', str) || strcmp('Cancel', str)
        return
    end
end

function handles = step6_undo(hObject, handles) 
set(handles.overlap_btn, 'Value',0)  
bodOut_btn_Callback(hObject, [], handles)
warndlg('Rate 120 Hz? Extracting BOD. Moving all optics to the insert position');
opticsALLIn_button_Callback(hObject, [], handles,0);
guidata(hObject, handles);
    
    



function step4_do_BOD10(hObject, handles)
st4a = 'Inserts BOD10';
if postMessage(handles,st4a); return; end
set(handles.radiobuttonU10, 'Value',1)
eventdata.NewValue = handles.radiobuttonU10;
uipanel401_SelectionChangeFcn(handles.output, eventdata, handles)
set(handles.radioU10_btn, 'Value',1)
eventdata.NewValue = handles.radioU10_btn;
uipanel389_SelectionChangeFcn(handles.output, eventdata, handles);
bodIn_btn_Callback(hObject, [], handles);
st4c = 'Confirm beam rate changed to 10 Hz';
if postMessage(handles,st4c); return; end
warndlg('Please change beam rate to 10 Hz');
st4d = 'Moved M3 pitch by -1 mrad';
if postMessage(handles,st4d); return; end
Val = lcaGetSmart(handles.M3PitchActPV);
newVal = Val-1;
M3Pitch_coordinator(handles, newVal);
st4e = 'If X-rays not visible, Nudge M3 pitch to move around BOD10.';
if postMessage(handles,st4e); return; end
handles = step4_grabImage(handles);


function handles = step4_grab_image(hObject, handles, PV)
[d,is]=profmon_names(PV);
nImg=[];
if handles.bufd && is.Bufd
    nImg=0;
    lcaPutSmart([PV ':SAVE_IMG'],1);
end
handles.data=profmon_grab(PV,0,nImg,'getFull',handles.getFull);
% profmon_imgPlot(handles.data,'axes',handles.step4_real,'cal',1,'scale2',handles.scale2);
guidata(hObject,handles);
plot_image(hObject,handles,1);

function step4_refrencePlot(handles, path)
img = imread(path); 
image(img,'parent',handles.step4_reference)
set(handles.step4_reference,'xtick',[])
set(handles.step4_reference,'ytick',[])


%Step4 Callbacks:


% --- Executes on button press in step4_BOD_OR_SLIT_BTN.
function step4_BOD_OR_SLIT_BTN_Callback(hObject, eventdata, handles)
if isNotRunning(hObject, handles)
    set(handles.step4_BOD_OR_SLIT_BTN,'value',0)
    return
end

if get(handles.step4_BOD_OR_SLIT_BTN,'value')
    
    if strcmp(get(handles.step4_BOD_OR_SLIT_BTN,'string'),'Check BOD10')
        step4_do_BOD10(hObject, handles)
    end

    s4f = 'Step 4h:  USER checks that X-rays are visible on BOD10. Tweak M1 pitch to align.';
    if postMessage(handles,s4f); return; end
    
    %Modify button...
    set(handles.step4_BOD_OR_SLIT_TXT,'string','BOD10')
    set(handles.step4_BOD_OR_SLIT_BTN,'string','YAGSLIT')
    set(handles.step4_BOD_OR_SLIT_BTN,'BackgroundColor',[1 0.4 1])
    
   
    %Check the zoom reference image and zoom for real image here
    step4_ref_zoom_Callback(hObject, eventdata, handles)
    
    %Runs the loop where it grabs the new image and displays it
    while get(handles.step4_BOD_OR_SLIT_BTN,'value') && get(handles.continue_btn,'value')
         handles = step4_grab_image(hObject,handles,'YAGS:UND1:1005');
       
        pause(0.05);
        guidata(hObject,handles);
        handles=guidata(hObject);
        if ~get(handles.step4_BOD_OR_SLIT_BTN,'value') && get(handles.continue_btn,'value')
            close(ho)
            break
        end
    end
else
    s4f = 'Step 4h:  USER checks that X-rays are visible and roughly aligned with slit. Tweak M1 pitch to align';
    s4f2 ='Once complete, press "Check BOD10" button to verify xrays on BOD10 (optional)';
    s4f3 ='Press "User Confirmed" button to proceed to next step';
    if postMessage(handles,s4f); return; end
    if postMessage(handles,s4f2); return; end
    if postMessage(handles,s4f3); return; end
     %Modify button... IF BOD10 process are already done 
    if strcmp(get(handles.step4_BOD_OR_SLIT_BTN,'string'),'Initialize and Check BOD10')
        set(handles.step4_BOD_OR_SLIT_TXT,'string','YAGSLIT')
        set(handles.step4_BOD_OR_SLIT_BTN,'string','Check BOD10')
        set(handles.step4_BOD_OR_SLIT_BTN,'BackgroundColor',[1 0.694 0.392])
    end
    
    %Check the zoom refrence image and zoom for real image here
    step4_ref_zoom_Callback(hObject, eventdata, handles)
    
    %Runs the loop where it grabs the new image and displays it
    while ~get(handles.step4_BOD_OR_SLIT_BTN,'value') && get(handles.continue_btn,'value')
        str=get(handles.step4_BOD_OR_SLIT_TXT,'string');
        if strcmp(str,'YAGSLIT') 
            handles.yagpv='PROF:UND1:960';
        elseif strcmp(str, 'BOD10')
            handles.yagpv='YAGS:UND1:1005';
        end
        profmon_ROISet(handles.yagpv, [700;375;400;400]);
        handles.nAverage=1;
        handles.show.stats=0;
        handles = step6_grab_image(hObject,handles);
        %handles = step4_grab_image(hObject,handles,'PROF:UND1:960');
        pause(0.05);

        guidata(hObject,handles);
        handles=guidata(hObject);
        if get(handles.step4_BOD_OR_SLIT_BTN,'value') && get(handles.continue_btn,'value')
            close(ho)
            break
        end
        
    end
end




% --- Executes on button press in step4_ref_zoom.
function step4_ref_zoom_Callback(hObject, eventdata, handles)
if get(handles.step4_BOD_OR_SLIT_BTN,'value')
    if get(handles.step4_ref_zoom,'value') 
        %Zoom in YAGSLIT
        path = 'BOD10.png';
        
        %YAGSLIT: Y=440:540, X=880:960
        props1=strcat(model_nameConvert('YAGSLIT'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
        lcaPutSmart(props1,[880;440;960-880+1;540-440+1]);
    else
      
        props1=strcat(model_nameConvert('YAGSLIT'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
        lcaPutSmart(props1,handles.orig.yagslitROI);
    end
else
    
    if get(handles.step4_ref_zoom,'value')
        path = 'YAGSLIT_zoom.png';
        %Zoom in BOD10
        %BOD10: Y=550:590, X=920:1150
        props2=strcat(model_nameConvert('YAGBOD1'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
        lcaPutSmart(props2,[920;550;1150-920+1;590-550+1]);
    else
        %Zoom out BOD10
          %Zoom out YAGSLIT
        path = 'YAGSLIT.png';
        props2=strcat(model_nameConvert('YAGBOD1'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
        lcaPutSmart(props2,handles.orig.yagBOD1ROI);
    end
end
step4_refrencePlot(handles, path)

    
% --- Executes on button press in step4_confirmed.
function step4_confirmed_Callback(hObject, eventdata, handles)    
set(handles.overlap_btn, 'Value',0);
if closeoutCheck(hObject, handles); return; end
redo_btn = handles.step.state4.string;
abort_btn = handles.step.state5.string;

if ~any(strcmp(get(handles.continue_btn,'string'),{redo_btn, abort_btn}))
    if strcmp(get(handles.step4_BOD_OR_SLIT_BTN,'string'),'Check BOD10')
        step4_undo_BOD10(hObject, handles)
    end
    %Reset Button
    set(handles.step4_BOD_OR_SLIT_BTN,'value',0)
    set(handles.step4_BOD_OR_SLIT_BTN,'string','Initialize and Check BOD10')
    set(handles.step4_BOD_OR_SLIT_BTN,'BackgroundColor',[1 0.694 0.392])
    set(handles.step4_BOD_OR_SLIT_TXT,'string','YAGSLIT')
    props1=strcat(model_nameConvert('YAGSLIT'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
    
    %try-catch added because handles.orig.yagslitROI doesn't exist 
    %if step 1 is skipped
    if ~epicsSimul_status
        try lcaPutSmart(props1,handles.orig.yagslitROI);
        catch
            handles.orig.yagslitROI=[880;440;81;101];
            lcaPutSmart(props1,handles.orig.yagslitROI);
        end
        try lcaPutSmart(props1,handles.orig.yagslitROI);
            
        catch
            handles.orig.yagslitROI=[880;440;81;101];
            lcaPutSmart(props1,handles.orig.yagslitROI);
        end
    
        props2=strcat(model_nameConvert('YAGBOD1'),':ROI_',{'X';'Y';'XNP';'YNP'},'_SET');
        lcaPutSmart(props2,handles.orig.yagBOD1ROI);
    end
    
    s4i =  'Step 4i:  Presses ''-->E-Log'' button in SXRSS GUI.';
    if postMessage(handles,s4i); return; end
    procedure_log_Callback(hObject, [], handles,'step4', 'SXRSS Insert Optics')
else
    waitfor(warndlg('Procedure has not started yet'))
end
closeoutStep(hObject, handles);




%------------------------------STEP5---------------------------------------


function step5_startup(hObject, handles)
M1_val = lcaGetSmart(handles.M1PitchActPV);
M3_val = lcaGetSmart(handles.M3PitchActPV);
M3X_val = lcaGetSmart(handles.M3XActPV);
delay_val = lcaGetSmart('SIOC:SYS0:ML01:AO809');
set(handles.step5_M1_initial,'string',num2str(M1_val, '%.3f'));
set(handles.step5_M3_initial,'string',num2str(M3_val, '%.3f'));
set(handles.step5_M3X_initial,'string',num2str(M3X_val, '%.3f'));
set(handles.step5_delay_initial,'string',delay_val)
step5_main(hObject, handles)


function step5_main(hObject, handles)
set(handles.listen_checkbox, 'Value', 1);
syncSliders(handles)
undStat = undStatGet(handles);   
if any(~undStat(10:20))
    ps1 = 'Step 5a:  Inserts undulators 10-20';
    if postMessage(handles,ps1); return; end
    moveUnd5 = setdiff(10:20,[9 16 33]);
    if move_undulators_in_out(handles,moveUnd5,1); return; end
end

selectAll_btn_Callback(hObject, [],handles)
set(handles.und17, 'Value', 1)
handles.savedXcor='XCOR:UND1:1780:BCTRL';
guidata(hObject, handles);
set(handles.step_und_kick, 'Value', 1)
step_und_kick_Callback(hObject, [],handles)

ps2 = 'Moved M3 pitch to insert position.';
if postMessage(handles,ps2); return; end
lcaPut('MIRR:UND1:966:P:INSERT.PROC',1)
syncSliders(handles)
ps4 = 'Moved slit to 700 um position.';
if postMessage(handles,ps4); return; end
    set(handles.radiobutton17,'value',1)
    uipanel140_SelectionChangeFcn(hObject, struct('NewValue',handles.radiobutton17), handles)

ps5 = 'USER: Tweak M3 X, Delay, and M3 Pitch to find the seeding signal';
if postMessage(handles,ps5); return; end

ps5b = 'OPTIONAL: Use the Spectrometer GUI to scan relevant parameters';
if postMessage(handles,ps5b); return; end

ps5c = 'OPTIONAL: Optimize taper using Und Taper Ctrl GUI';
if postMessage(handles,ps5c); return; end

ps6 = 'Seeding Not found? Review FAQ in Help section';
if postMessage(handles,ps6); return; end

ps6b = 'Press "User Confirmed" button to proceed to Overlap Step (WARNING THIS STEP IS NOT COMPLETE)';
if postMessage(handles,ps6b); return; end


%Step5 Callbacks:
function taperSetup_txt_Callback(hObject, eventdata,handles, tag,val)
[ho,h]=util_appFind('UndulatorTaper_NEW');
UndulatorTaper_NEW('Open_iSASEpanel_Callback',ho,[],h)
switch val
    case 1
        num=get(handles.gainTaperStartSegment_txt, 'String');
        str=[num2str(num) ':25'];
        set(h.iSASE_ISS_edit,'String',str)
        UndulatorTaper_NEW('iSASE_ISS_Expression_Callback', ho,[],h);
        startPV=['USEG:UND1:',num2str(num), '50:KACT'];
        set(h.iSASE_TaperShape0,'String',num2str(lcaGetSmart(startPV)))
        
    case 2
        num=get(handles.gainTaperAmplitude_txt, 'String');
        set(h.iSASE_TaperShape1,'String', num)
        
    case 3
        num=get(handles.postTaperStartSegment_txt, 'String');
        set(h.iSASE_TaperShape2,'String', num)
        
    case 4
        num=get(handles.postTaperAmplitude_txt, 'String');
        set(h.iSASE_TaperShape3,'String', num)       
end
UndulatorTaper_NEW('iSASE_TaperShapeApply_Callback',ho,[],h)


% --- Executes on button press in step5_block_btn.
%Blocks and unblocks the xrays
function step5_block_btn_Callback(hObject, eventdata, handles)
if get(handles.step5_block_btn,'value')
    set(handles.step5_blocked_txt,'visible','on')
    set(handles.step5_block_btn,'string','Unblock Seeding')
    set(handles.step5_block_btn,'BackgroundColor',[1 0.377 0.419])
    val = lcaGetSmart(handles.M1PitchActPV)+0.5;
else
    set(handles.step5_blocked_txt,'visible','off')
    set(handles.step5_block_btn,'string','Block Seeding')
    set(handles.step5_block_btn,'BackgroundColor',[0.502 1 0.502])
    val = lcaGetSmart(handles.M1PitchActPV)-0.5;
end
 M1Pitch_coordinator(handles, val)

% --- Executes on button press in launchPhaseShifter_btn.
function launchPhaseShifter_btn_Callback(hObject, eventdata, handles)
[ho,h]=util_appFind('PhaseShifterNEW');  

%------------------------------STEP6--------------------------------------

function step6_startup(hObject, handles)
handles.yagSelect = 2;
handles.yagPV='YAGS:UND1:1005';
handles.axes = handles.step6_image;
handles.scale2=0;
handles=autoZoom(handles);
set(handles.overlap_btn, 'Value', 1);
guidata(hObject, handles);
step6_main(hObject, handles);


function step6_main(hObject, handles) 
if get(handles.radioU10_btn, 'Value') ==1
    SXRSS_historyConfig(handles.allMirrorTags , 'IN', 0);
    bodIn_btn_Callback(hObject, [], handles)
        
    msg = 'USER: Tweak M3 Pitch until Xrays are visible';
    if postMessage(handles,msg); return; end
    msg = 'USER: press "Confirm Xrays" button once complete';
    if postMessage(handles,msg); return; end
    guidata(handles.output,handles);
    handles = grabImage(handles);
    str=questdlg('Proceed w/ Overlap');
    if strcmp(str, 'Yes')
    else
        return
    end
    handles.buttonPushDownActive =1;
    screenClick(handles);
    M3P=lcaGetSmart(handles.M3PitchActPV);
    lcaPutSmart('SIOC:SYS0:ML01:AO835',M3P)
    SXRSS_historyConfig(handles.allMirrorTags , 'BOD10', 0);
    measureWire(handles)
    wireScan(hObject, handles);
    pause(2)
    
    set(handles.radioU13_btn, 'Value', 1)
    eventdata.NewValue = handles.radioU13_btn;
    uipanel389_SelectionChangeFcn(handles.output, eventdata, handles);
    handles=guidata(handles.output);
    bodIn_btn_Callback(hObject, [], handles)
 
end

handles.yagpv='YAGS:UND1:1305';
status = lcaGetSmart(handles.bod13status);
if strcmp(status, 'OUT')
set(handles.radioU13_btn, 'Value', 1)
eventdata.NewValue = handles.radioU13_btn;
uipanel389_SelectionChangeFcn(handles.output, eventdata, handles);
handles=guidata(handles.output);
bodIn_btn_Callback(hObject, [], handles)
end

msg = 'Moving M3P & M1P to block seeding';
if postMessage(handles,msg); return; end

DX=1;
SXRSS_moveMirrors({'M3P'}, DX, 0);
blockSeed_btn_Callback(hObject, [], handles,1);
        
msg = ['Taking ' get(handles.nAvg_txt, 'String') 'shot back ground'];
if postMessage(handles,msg); return; end

handles=BG_btn_Callback(hObject, [], handles);

msg = 'Moving M1P to unblock seeding';
if postMessage(handles,msg); return; end
msg = 'BG Subtracted from Image';
if postMessage(handles,msg); return; end
msg = 'press "Confirm Xrays" button once complete';
if postMessage(handles,msg); return; end
blockSeed_btn_Callback(hObject, [], handles,0);
set(handles.overlap_btn, 'Value', 1);
handles = grabImage(handles);
handles.buttonPushDownActive =1;
screenClick(handles);
handles.useBG=0;
guidata(handles.output,handles);
M3P=lcaGetSmart(handles.M3PitchActPV);
lcaPutSmart('SIOC:SYS0:ML01:AO836',M3P)
SXRSS_historyConfig(handles.allMirrorTags , 'BOD13', 0);
measureWire(handles) 
wireScan(hObject, handles);
overlapCalc(handles);

selectAll_btn_Callback(hObject, [],handles)
set(handles.und17, 'Value', 1)
set(handles.step_und_kick, 'Value', 1)
step_und_kick_Callback(hObject, [],handles)

if closeoutCheck(hObject, handles); return; end
closeoutStep(hObject, handles);



function handles = grabImage(handles)
while get(handles.overlap_btn, 'Value')
     handles=guidata(handles.output);
     [d,is]=profmon_names(handles.yagpv);
     PV=handles.yagpv;
     nImg=1;
     if handles.bufd && is.Bufd
         nImg=0;
         lcaPutSmart([PV ':SAVE_IMG'],1);
     end
     
     if handles.useBG
         background=handles.data.back;
         handles.data=profmon_grab(PV,0,nImg);
         handles.data.back=background;
     else
         
         handles.data=profmon_grab(PV,0,nImg);
         handles.data.bg=0;
         handles.data.back=0;
     end
     
     guidata(handles.output, handles)
     profmon_imgPlot(handles.data,'axes', handles.axes,'cal',1,'scale2', handles.scale2,'useBG', handles.useBG);
     guidata(handles.output,handles);
     
     if ~get(handles.overlap_btn, 'Value')
         break
     end
end
 
function handles = step4_grabImage(handles)
set(handles.overlap_btn, 'Value',1); 
while get(handles.overlap_btn, 'Value')
     handles=guidata(handles.output);
     [d,is]=profmon_names(handles.yagpv);
     PV=handles.yagpv;
     nImg=1;
     if handles.bufd && is.Bufd
         nImg=0;
         lcaPutSmart([PV ':SAVE_IMG'],1);
     end
     
     if handles.useBG
         background=handles.data.back;
         handles.data=profmon_grab(PV,0,nImg);
         handles.data.back=background;
     else
         
         handles.data=profmon_grab(PV,0,nImg);
         handles.data.bg=0;
         handles.data.back=0;
     end
     
     guidata(handles.output, handles)
     profmon_imgPlot(handles.data,'axes', handles.step4_real,'cal',1,'scale2', handles.scale2,'useBG', handles.useBG);
     guidata(handles.output,handles);
     
     if ~get(handles.overlap_btn, 'Value')
         break
     end
end
 


%Step6 support functions:
function handles = overlapCalc(handles)
offsetCalc(handles);
tags=cell(size(handles.matlabPvTags));
[tags{:}]=deal('ML01');
[list, ~]= SXRSS_pvBuilder(tags, handles.matlabPvTags);
vals=lcaGetSmart(list);
G0=vals(1:4); G=vals(5:8); X=vals(9:12); Off=vals(13:14); W=vals(15:18);
[D,eScCoords, dx]=SXRSS_overlapCalc(G0,G,W,X,Off);

lcaPutSmart(handles.pvCtr, eScCoords);


%DX10,DY10,DX13,DY13
moveTags={'AO824';'AO825';'AO830';'AO837'};
tags=cell(size(moveTags));
[tags{:}]=deal('ML01');
[list, ~]= SXRSS_pvBuilder(tags, moveTags);
lcaPutSmart(list, D); %changed from ..(list, dx)

%Move Mirrors
str1 = ['G1Y = ' num2str(D(1),'%3.0f') 'um  M3X = ' ...
    num2str(D(2), '%3.3f') ' mm M3P = ' num2str(D(3),'%3.3f') ...
    ' mrad M3O = ' num2str(D(4),'%3.3f') ' mrad '];

if postMessage(handles,str1); return; end

str=questdlg('Move Mirrors?');
if strcmp('Yes', str)
    SXRSS_moveMirrors({'GRATY', 'M3X', 'M3P','M3O'}, D', 0) 
    SXRSS_historyConfig(handles.allMirrorTags , 'calcSEED', 0);
    
elseif strcmp('No', str) || strcmp('Cancel', str)
    guidata(handles.output, handles)
    return

end

function handles = overlapCalcManual(handles)
tags=cell(size(handles.matlabPvTags));
[tags{:}]=deal('ML01');
[list, ~]= SXRSS_pvBuilder(tags, handles.matlabPvTags);
vals=lcaGetSmart(list);
G0=vals(1:4); G=vals(5:8); X=vals(9:12); Off=vals(13:14); W=vals(15:18);
[D,eScCoords, dx]=SXRSS_overlapCalc(G0,G,W,X,Off);
lcaPutSmart(handles.pvCtr, eScCoords);
moveTags={'AO824';'AO825';'AO830';'AO837'};
tags=cell(size(moveTags));
[tags{:}]=deal('ML01');
[list, ~]= SXRSS_pvBuilder(tags, moveTags);
lcaPutSmart(list, D);

%Move Mirrors
str1 = ['G1Y = ' num2str(D(1),'%3.0f') 'um  M3X = ' ...
    num2str(D(2), '%3.3f') ' mm M3P = ' num2str(D(3),'%3.3f') ...
    ' mrad M3O = ' num2str(D(4),'%3.3f') ' mrad '];

if postMessage(handles,str1); return; end
refreshBodGui(handles)
SXRSS_moveMirrors({'GRATY', 'M3X', 'M3P','M3O'}, D', 0) 



function refreshBodGui(handles)
if get(handles.radioU10_btn, 'Value')== 1
    str='bod10Tags';
    num =1;
elseif get(handles.radioU13_btn, 'Value')== 1
    str='bod13Tags';
    num =2;
end

tags=cell(size(handles.(str)));
[tags{:}]=deal('ML01');
[list, ~]= SXRSS_pvBuilder(tags, handles.(str));
val=lcaGetSmart(list);
val2=lcaGetSmart(handles.pvCtr);
if num == 1 
    val2=val2(1:2);
elseif num==2
    val2=val2(3:4);
end
for i=1:length(val)
    set(handles.(handles.bodTags{i}),'String', num2str(val(i),'%3.0f'));
end
for i=1:length(val2)
    set(handles.(handles.pvCtrTags{i}),'String', num2str(val2(i),'%3.0f'));
end
updateGUI2(handles);

    
    
function offsetCalc(handles) 
[bod10]=SXRSS_historyConfig(handles.allMirrorTags , 'BOD10', 1);
[bod13]=SXRSS_historyConfig(handles.allMirrorTags , 'BOD13', 1);
% lcaPutSmart('SIOC:SYS0:ML01:AO835', bod10(8));
% lcaPutSmart('SIOC:SYS0:ML01:AO836', bod13(8));


        
function handles=autoZoom(handles)
if handles.yagSelect == 1
    handles.scale2 = 0;
    profmon_ROISet(handles.yagpv, [800;375;300;400]);
elseif  handles.yagSelect ==2
    handles.scale2 = [-4 0 -2 1];
elseif handles.yagSelect ==3
    profmon_ROISet(handles.yagpv, [700;375;400;400]);
    handles.scale2 = 0;
else
    handles.scale2 = 0;
    profmon_ROISet(handles.yagpv, [0;0;1392;1040]);
end

if handles.buttonPushDownActive == 3
pos.isRaw=0;
pos.x=lcaGetSmart(handles.XraySlitPosX)*1e-3; %mm
pos.y=lcaGetSmart(handles.XraySlitPosY)*1e-3; %mm
pos.units = 'mm';

data=handles.data;
pixelPos=profmon_coordTrans(pos,data,'pixel');
profmon_ROISet(handles.yagpv, [pixelPos.y-20; 1000-pixelPos.x ;40;80]);
handles = step6_grab_image(handles.output,handles);
end

guidata(handles.output);


function handles= screenClick(handles)

msg='USER: Use cursor to click on xrays';
if postMessage(handles,msg); return; end
handles.show.bmCross2=1;
guidata(handles.output, handles)
step6_image_ButtonDownFcn(handles.output, [], handles);


function measureWire(handles)  
profmon_ROISet(handles.yagpv, [0;0;1392;1040]);
lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL', 0); % Disable beam
profmon_lampSet(handles.yagpv,1,0); % Turn on target lamp
pause(0.5)
msg='Now measuring wire positions...(~30s)';
if postMessage(handles,msg); return; end
data1=profmon_measure(handles.yagpv,1,'nBG',0,'doProcess',0,'doPlot',0,'bufd',1,'nAvg',1);
val = get(handles.radioU10_btn, 'Value');

if val == 1
    posx=[640 710 425 465];    % BOD10 crop area for X-wire (Pixels)
    posy=[640 670 480 510];   % BOD10 crop area for Y-wire (Pixels)
    pvTags={'AO838';'AO839'};
    
else
    posx=[640 740 530 560]; %BOD13 crop area for X-wire
    posy=[660 700 470 510]; %BOD13 crop area for Y-wire
    pvTags={'AO840';'AO841'};
    
end

datax=profmon_imgCrop(data1,posx); % Crop image for X-wire
datay=profmon_imgCrop(data1,posy); % Crop image for Y-wire
beamx=profmon_process(datax,'doPlot', 1); % Get stats
util_appFonts(1,'fontName','Times','lineWidth',1,'fontSize',14);
if ~epicsSimul_status
util_appPrintLog(1,'ProfMon Stats',datax.name,datax.ts);
close(1)
end
beamy=profmon_process(datay,'doPlot', 1); % Get stats
util_appFonts(1,'fontName','Times','lineWidth',1,'fontSize',14);
if ~epicsSimul_status
util_appPrintLog(1,'ProfMon Stats',datay.name,datay.ts);
close(1)
end
profmon_lampSet(handles.yagpv,0,0); 
lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL', 1); 
xy=[beamx(1).stats(1);beamy(1).stats(2)];
tags=cell(size(pvTags));
[tags{:}]=deal('ML01');
[list, ~]= SXRSS_pvBuilder(tags, pvTags);
lcaPutSmart(list, xy);
handles.buttonPushDownActive=2;
guidata(handles.output, handles)
refreshBodGui(handles);
confirmMeasurement(handles)


function confirmMeasurement(handles)
 if handles.buttonPushDownActive==1
     label ='X-ray beam (screen coords):  ';
     X=lcaGetSmart(handles.XrayPosX);
     Y=lcaGetSmart(handles.XrayPosY);
     msg2=['X =' num2str(X,'%3.0f\n')   'um, Y=' num2str(Y,'%3.0f\n') 'um'];
     text(0.1,0.9,msg2,'units','normalized','VerticalAlignment','top', ...
         'Color','r','Parent',handles.step6_image);
     strlogbook=' SXRSS BOD10 ';
 elseif handles.buttonPushDownActive==2
     label ='Wires (screen coords):  ';
     X=lcaGetSmart(handles.WirePosX);
     Y=lcaGetSmart(handles.WirePosY);
 elseif handles.buttonPushDownActive==3
     label ='Xray beam (screen coords) on yag:  ';
     X=lcaGetSmart(handles.XraySlitPosX);
     Y=lcaGetSmart(handles.XraySlitPosY);
     strlogbook=' SXRSS YAGSLIT ';
 end
 
 msg=[label 'X =' num2str(X,'%3.0f\n')   'um, Y=' num2str(Y,'%3.0f\n') 'um'];
 
 if postMessage(handles,msg); return; end
 str=questdlg('Would you like to accept this measurement');
 if strcmp('Yes', str)
     if handles.buttonPushDownActive==1 || handles.buttonPushDownActive==3
         if ~epicsSimul_status
         dataExport(handles.output, handles, strlogbook);
         dataSave(handles.output, handles,'ProfMon');
         end
     end
     handles.show.bmCross2=0;
     handles.buttonPushDownActive = 0;
     handles.show.bmCross2 =0;
     guidata(handles.output, handles);
 else
     screenClick(handles)
 end


function handles = bitsControl(hObject, handles, val, nVal)
handles=gui_sliderControl(hObject,handles,'bits',val,max(5,nVal));
str=num2str(handles.bits.iVal);if handles.bits.iVal == 4, str='Auto';end
set(handles.bits_txt,'String',str);
guidata(hObject, handles)
plot_image(hObject,handles);

% --- Executes when selected object is changed in uipanel140.
function handles = uipanel389_SelectionChangeFcn(hObject, eventdata, handles)
handles = guidata(hObject);
newButton=get(eventdata.NewValue,'tag');
switch newButton
    case 'radioU10_btn'
        handles.yagSelect=1;
        handles.yagpv='YAGS:UND1:1005';
        handles.dxPV='BOD:UND1:1005:MOTOR.TWV';
        handles.useBG = 0;
    case 'radioU13_btn'
         handles.yagSelect=2;
         handles.yagpv='YAGS:UND1:1305';
         handles.dxPV='BOD:UND1:1305:MOTOR.TWV';
end
set(handles.blockSeed_btn, 'Value', 0)
set(handles.(newButton), 'Value', 1)
set(handles.dx_txt, 'String', num2str(lcaGetSmart(handles.dxPV),'%3.3f'));
refreshBodGui(handles); 
handles=modeManager(hObject, handles);
handles.buttonPushDownActive =0;

s=length(handles.bodEditTags);
for i=1:s
    set(handles.(handles.bodEditTags{i}) ,'String', '  ');
end
guidata(hObject, handles);

function handles = step6_grab_image(hObject, handles)
guidata(hObject,handles);
[d,is]=profmon_names(handles.yagpv);
nImg=[];
if handles.bufd && is.Bufd
    nImg=0;
    lcaPutSmart([handles.yagpv ':SAVE_IMG'],1);
end
ts=-Inf;if isfield(handles,'data'), ts=handles.data.ts;end

for j=1:handles.nAverage
    set(handles.text683,'String',num2str(j,'%d /'));drawnow;
    ts0=ts;
     while ts <= ts0
        data(j)=profmon_grab(handles.yagpv,0,nImg,'getFull',handles.getFull);ts=data(j).ts;
         if handles.nAverage < 2, ts=Inf;end
     end
end
set(handles.text683,'String','# Av.');drawnow;


handles=guidata(hObject);
handles.data=data(1);

if numel(data) > 1
    handles.data.img=feval(class(data(1).img),mean(cat(4,data.img),4));
end

if handles.useBG==0
    handles.data.back=0;
else
    handles.data.back=handles.bg{handles.PVId};
end
plot_image(hObject,handles,1);


function [data]=useBG(hObject,handles)
if handles.useBG
    data=handles.data;
    [dataBG]=grabBG(handles);
    data.back = dataBG;
    foreground=int16(data.img);
    background=int16(data.back);
    if size(foreground)==size(background)
        data.img=foreground-background;
    end
    handles.data=data;
    guidata(hObject, handles)
end



function handles = makeBG(hObject, handles)
if ~isfield(handles,'data'), return, end
handles.bg{handles.PVId}=handles.data.img;
handles.data.back=handles.bg{handles.PVId};
val=handles.scale2;
if val(1) == 0
    str2='_full';
else
    str2='_zoom';
end

if handles.yagSelect ==1
    str1='BG10';
elseif handles.yagSelect ==2
    str1='BG13';
end
str=strcat(str1, str2);
handles.(str)=handles.bg{handles.PVId};
guidata(hObject,handles);


function [dataBG]=grabBG(handles)
val=handles.scale2;
if val(1) == 0
    str2='_full';
else
    str2='_zoom';
end

if handles.yagSelect ==1
    str1='BG10';
elseif handles.yagSelect ==2
    str1='BG13';
end
str=strcat(str1, str2);
dataBG = handles.(str);




function [cross1, cross2, crossColor] = crossPosition(handles)
unit='mm';
data=handles.data;
if handles.show.bmCross
crossV=lcaGetSmart(strcat(data.name,{':X';':Y'},'_BM_CTR'));
[cross1.x,cross1.y,cross1.units,cross1.isRaw]=deal(crossV(1),crossV(2),unit,0);
else
    cross1=[];
    crossColor='r';
    cross2=[];
end
if handles.show.bmCross2
    %pause(0.1)
    if handles.buttonPushDownActive ==1
        crossColor='r';
        crossV2X=lcaGetSmart(handles.XrayPosX)/1000; %mm
        crossV2Y=lcaGetSmart(handles.XrayPosY)/1000; %mm
        [cross2.x,cross2.y,cross2.units,cross2.isRaw]=deal(crossV2X,crossV2Y,unit,0);
    elseif handles.buttonPushDownActive ==3
        crossColor='r';
        crossV2X=lcaGetSmart(handles.XraySlitPosX)/1000; %mm
        crossV2Y=lcaGetSmart(handles.XraySlitPosY)/1000; %mm
        [cross2.x,cross2.y,cross2.units,cross2.isRaw]=deal(crossV2X,crossV2Y,unit,0);
    else
        handles.scale2=0;
    end
else
    cross2=[];
    crossColor='r';
end



    

% -----------------------------------------------------------
function handles = plot_image(hObject, handles, update)
pause(0.1)

if ~isfield(handles,'data'), return, end

data=handles.data;

if ~data.img(end), data.img(end)=max([min(data.img(1:end-1)) 0]);end

if handles.step.currentStep == 6
    ax=handles.step6_image;
elseif handles.step.currentStep == 7
    ax=handles.step7plotData_ax;
elseif handles.step.currentStep == 4
    ax=handles.step4_real;
end

[cross1, cross2, crossColor] = crossPosition(handles);

bits=handles.bits.iVal;

profmon_imgPlot(data,'axes',ax,'useBG',handles.useBG,...
    'cal',handles.show.cal,...
    'title',['Profile Monitor %s '],...
    'bits',bits,'cross',cross1,'cross2',cross2,...
    'crossColor',crossColor,'scale2', handles.scale2);

if handles.show.stats
    
    if handles.step.currentStep == 4
        data=profmon_measure(handles.yagpv,1,'nBG',0,'doProcess',0,'doPlot',0,'bufd',1,'nAvg',1);
    end
        
    beam=profmon_process(data,'useCal', handles.show.cal,'back',0,'usemethod',1,'doPlot', 1);
    
    if handles.intensityMode ==1
        lcaPutSmart(handles.intensityFirst, beam.stats(6));
        label = '  SXRSS YAGSLIT 1st Order Intensity Measurement';
    elseif handles.intensityMode ==2
        lcaPutSmart(handles.intensityZeroth, beam.stats(6));
        label = '  SXRSS YAGSLIT Zeroth Order Intensity Measurement';
    end
    
    if ~epicsSimul_status
    util_appFonts(1,'fontName','Times','lineWidth',1,'fontSize',14);
    util_appPrintLog(1,'ProfMon Stats',[data.name label],data.ts);
    dataSave(hObject, handles,'ProfMon');
    handles.show.stats=0;
    end
    
    if ~ismember(data.name(6:min(9,end)),{'M6:C' 'XS:C' 'PAL1' 'G2:C'}) && nargin == 3 && update
        control_profDataSet(data.name,beam);
    end
end

guidata(hObject, handles)



function handles=modeManager(hObject, handles)
if handles.yagSelect ==1 
    
    handles.motors.pv={...
        'BOD:UND1:1005:DES';...
        'BOD:UND1:1005:TRIM.PROC';...
        'BOD:UND1:1005:ACT';...
        'BOD:UND1:1005:MOTOR.TWV';...
        };
    
    bod ='bod10Tags';
    states = 1;
    handles.XrayPosX= 'SIOC:SYS0:ML01:AO831';
    handles.XrayPosY= 'SIOC:SYS0:ML01:AO832';    
    handles.WirePosX= 'SIOC:SYS0:ML01:AO838';
    handles.WirePosY= 'SIOC:SYS0:ML01:AO839';
    handles.yagpv='YAGS:UND1:1005';
    DevName = 'BOD10';
    n = 10;
    
elseif handles.yagSelect ==2  
    handles.motors.pv={...
        'BOD:UND1:1305:DES';...
        'BOD:UND1:1305:TRIM.PROC';...
        'BOD:UND1:1305:ACT';...
        'BOD:UND1:1305:MOTOR.TWV';...
        };
    
    bod ='bod13Tags';
    states = 2;
    handles.XrayPosX= 'SIOC:SYS0:ML01:AO833';
    handles.XrayPosY= 'SIOC:SYS0:ML01:AO834';
    handles.WirePosX= 'SIOC:SYS0:ML01:AO840';
    handles.WirePosY= 'SIOC:SYS0:ML01:AO841';
    handles.yagpv='YAGS:UND1:1305';...
    DevName = 'BOD13';
    n = 13;
  
end

if handles.buttonPushDownActive ==3 || handles.yagSelect ==3
    handles.yagpv = 'PROF:UND1:960';
    bod ='bod10Tags';
    states = 1;
end

tags=cell(size(handles.(bod)));
[tags{:}]=deal('ML01');
[handles.parameters.pvs, ~]= SXRSS_pvBuilder(tags, handles.(bod));
handles.states=states;
guidata(hObject, handles);
refreshBodGui(handles); 



function handles = updateGUI2(handles)
pvs=cellstr(handles.parameters.pvs);
motorpvs = handles.motors.pv;
states =  handles.states;
vals = lcaGetSmart(pvs,0,'double');
GX=vals(3); GY=vals(4);
GX0=vals(1); GY0=vals(2);
XrayX=lcaGetSmart(handles.XrayPosX);  %um
XrayY=lcaGetSmart(handles.XrayPosY);  %um
WX=lcaGetSmart(handles.WirePosX); %confirm units
WY=lcaGetSmart(handles.WirePosY); % WX=vals(5); WY=vals(6);
EbeamScreenX= WX+GX-GX0; %mm
EbeamScreenY= WY+GY-GY0; %mm
lcaPutSmart(strcat(handles.yagpv,':X_BM_CTR'), EbeamScreenX*1e-3); %mm
lcaPutSmart(strcat(handles.yagpv,':Y_BM_CTR'), EbeamScreenY*1e-3); %mm
SepX = XrayX - EbeamScreenX;
SepY = XrayY - EbeamScreenY;
lcaPutSmart(pvs(9), SepX);
lcaPutSmart(pvs(10), SepY);
set(handles.readGirderX_txt, 'string', sprintf('%6.0f', vals(1)));
set(handles.readGirderY_txt, 'string', sprintf('%6.0f', vals(2)));
set(handles.readEbeamX_txt, 'string', sprintf('%6.0f', vals(3)));
set(handles.readEbeamY_txt, 'string', sprintf('%6.0f', vals(4)));
set(handles.readWireX_txt, 'string', sprintf('%3.0f', lcaGetSmart(handles.WirePosX)));
set(handles.readWireY_txt, 'string', sprintf('%3.0f', lcaGetSmart(handles.WirePosY)));  
set(handles.readScreenX_txt, 'string', sprintf('%6.0f', EbeamScreenX));
set(handles.readScreenY_txt, 'string', sprintf('%6.0f', EbeamScreenY));
set(handles.readXrayX_txt, 'string', sprintf('%6.0f', lcaGetSmart(handles.XrayPosX)));
set(handles.readXrayY_txt, 'string', sprintf('%6.0f', lcaGetSmart(handles.XrayPosY)));  
set(handles.readSepX_txt, 'string', sprintf('%6.0f', SepX));
set(handles.readSepY_txt, 'string', sprintf('%6.0f', SepY)); 
vals2=lcaGetSmart(motorpvs,0,'double');
set(handles.BODX_txt,  'string', sprintf('%6.3f',lcaGetSmart(motorpvs(3))));
% set(handles.wirex_txt,'string', sprintf('%6.0f',lcaGetSmart(pvs(5))));
% set(handles.wirey_txt, 'string', sprintf('%6.0f',lcaGetSmart(pvs(6))));
G1Y=lcaGetSmart('GRAT:UND1:934:Y:ACT');
M3X=lcaGetSmart(handles.M3XActPV);
M3P=lcaGetSmart(handles.M3PitchActPV);
M3Roll=lcaGetSmart('MIRR:UND1:966:O:ACT');
sep = lcaGetSmart(handles.sepPV);
M3P10 = lcaGetSmart('SIOC:SYS0:ML01:AO835');
M3P13 = lcaGetSmart('SIOC:SYS0:ML01:AO836');
off1 = 0;
off2 = M3P10 - M3P13;
off = [str2double(off1) str2double(off2)];
off = off*-1;
[A, B] = SXRSS_bodSteer(sep, off);
newG1Y = G1Y+A(1);
newM3X = M3X+A(2);
newM3P = M3P+A(3);
newM3Roll =  M3Roll+A(4);
lcaPutSmart('SIOC:SYS0:ML01:AO815', newG1Y);
lcaPutSmart('SIOC:SYS0:ML01:AO817', newM3X);
lcaPutSmart('SIOC:SYS0:ML01:AO818', newM3P);
lcaPutSmart('SIOC:SYS0:ML01:AO819', newM3Roll);
guidata(handles.output, handles);




%Step6 Callbacks:

% --- Executes on button press in bodIn_btn.
function bodIn_btn_Callback(hObject, eventdata, handles)
if get(handles.radioU10_btn, 'Value')
    if strcmp(lcaGetSmart(handles.bod10status),'IN')
        return
    else
        lcaPutSmart(handles.bod10Insert, 1);
        lcaPutSmart(handles.bod13Extract, 1);
        if epicsSimul_status
            lcaPutSmart(handles.bod10status,'IN');
            lcaPutSmart(handles.bod13status,'OUT');
        end
    end
    eventdata.OldValue=handles.radioU13_btn;
    eventdata.NewValue=handles.radioU10_btn;
    pv = handles.bod10status;
    str='INSERTING BOD10';
    
elseif get(handles.radioU13_btn, 'Value')
    lcaPutSmart(handles.bod13Insert, 1);
    lcaPutSmart(handles.bod10Extract, 1);
    eventdata.OldValue=handles.radioU10_btn;
    eventdata.NewValue=handles.radioU13_btn;
    pv = handles.bod13status;
    str='INSERTING BOD13';
    if epicsSimul_status
        lcaPutSmart(handles.bod10status,'OUT');
        lcaPutSmart(handles.bod13status,'IN');
    end
end
eventdata.EventName='SelectionChanged';
uipanel389_SelectionChangeFcn(hObject, eventdata,handles);
checkBodStatus(handles, pv, str);



function checkBodStatus(handles, pv, str)
postMessage(handles,str);
while ~strcmp(lcaGetSmart(pv), 'IN')
    pause(0.5)
    disp('waiting')
    disp(lcaGetSmart(pv))
    if strcmp(lcaGetSmart(pv), 'IN')
        break 
    end
end
str='Finished Moving';
postMessage(handles,str);


% --- Executes on button press in bodOut_btn.
function bodOut_btn_Callback(hObject, eventdata, handles)
lcaPutSmart(handles.bod10Extract, 1);
lcaPutSmart(handles.bod13Extract, 1);
if epicsSimul_status
    lcaPutSmart(handles.bod10status,'OUT');
    lcaPutSmart(handles.bod13status,'OUT');
end



% --- Executes on button press in blockSeed_btn.
function blockSeed_btn_Callback(hObject, eventdata, handles, val)
if nargin < 4, val = 0; end
if val ==1
    set(handles.blockSeed_btn,'Value',1)
else
    set(handles.blockSeed_btn,'Value',0)
end
M1P=lcaGetSmart(handles.M1PitchActPV,0,'double');
buttonState=get(handles.blockSeed_btn,'Value');
switch buttonState
    case 1
        SXRSS_moveMirrors({'M1P'}, 0.5, 0);
        set(handles.seed_disabled_txt, 'Visible', 'on');
    case 0
        SXRSS_moveMirrors({'M1P'}, -0.5, 0);
        set(handles.seed_disabled_txt, 'Visible', 'off');
        pause(2)
end

% --- Executes on button press in acquireStart_btn.
function startScan_btn_Callback(hObject, eventdata, handles)
% Not used at this time

% --- Executes on button press in radioU13_btn.
function radioU13_btn_Callback(hObject, eventdata, handles)
% 

% --- Executes on button press in radioU10_btn.
function radioU10_btn_Callback(hObject, eventdata, handles)
% Not used at this time


% --- Executes on button press in overlap_btn.
 function overlap_btn_Callback(hObject, eventdata, handles)


% --- Executes on button press in BG_btn.
function handles=BG_btn_Callback(hObject, eventdata, handles)
handles.nAverage =str2double(get(handles.nAvg_txt, 'String'));
profmon_evrSet(handles.yagpv);
handles = step6_grab_image(hObject,handles);
handles=makeBG(hObject, handles);
handles.useBG=1;
guidata(hObject,handles);


% --- Executes on slider movement.
function bits_sl_Callback(hObject, eventdata, handles)
bitsControl(hObject,handles,round(get(hObject,'Value')),[]);



% --- Executes during object creation, after setting all properties.
function bits_sl_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in scale_box.
function scale_box_Callback(hObject, eventdata, handles)
val=get(handles.scale_box, 'Value');
if val == 1 
    handles.scale=1;
else
    handles.scale=0;
end
plot_image(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in autoZoom_box.
function autoZoom_box_Callback(hObject, eventdata, handles)

autoZoom(handles);


% --- Executes on button press in test_btn2.
function test_btn_Callback(hObject, eventdata, handles)
appInit(hObject,handles)




 % --- Executes on mouse press over axes background.
 function step6_image_ButtonDownFcn(hObject, eventdata, handles)
if handles.buttonPushDownActive ==1 || handles.buttonPushDownActive ==3
waitforbuttonpress
msg='Processing image ...';
if postMessage(handles,msg); return; end

handles=modeManager(hObject, handles);
loc=get(gca,'Currentpoint');
%pos in calibrated units ('mm') loc(1) - X loc(2) - Y
loc=loc(1,1:2)*1000; %um
if handles.buttonPushDownActive ==1
    lcaPutSmart(handles.XrayPosX, loc(1));
    lcaPutSmart(handles.XrayPosY, loc(2));
    plot_image(hObject, handles)
elseif handles.buttonPushDownActive ==3
    lcaPutSmart(handles.XraySlitPosX, loc(1));
    lcaPutSmart(handles.XraySlitPosY, loc(2));
    handles.show.stats=1;
    guidata(hObject, handles);
    handles=autoZoom(handles);
end

pause(0.2)
refreshBodGui(handles);
confirmMeasurement(handles);
end




 





% --- Executes on button press in minusX.
function minusX_Callback(hObject, eventdata, handles, val)
plusMinus_Callback(handles, val)
    



% --- Executes on button press in plusX.
function plusX_Callback(hObject, eventdata, handles, val)
plusMinus_Callback(handles, val)
    
    
    


function plusMinus_Callback(handles, num)
if handles.yagSelect ==1 
    pv1='BOD:UND1:1005:ACT';
    pv2='BOD:UND1:1005:MOTOR.TWV';
    pv3='BOD:UND1:1005:DES';
    pv4='BOD:UND1:1005:TRIM.PROC';...
 
elseif handles.yagSelect ==2
    pv1='BOD:UND1:1305:ACT';
    pv2='BOD:UND1:1305:MOTOR.TWV';
    pv3='BOD:UND1:1005:DES';
    pv4='BOD:UND1:1005:TRIM.PROC';...
        
end

val=lcaGetSmart(pv1);
dx=lcaGetSmart(pv2);

if num == 1
    newVal= val-dx;
elseif num ==2
    newVal= val+dx;
end

    lcaPutSmart(pv3, newVal);
    lcaPutSmart(pv4, 1);



% --- Executes on button press in undo_button.
function undo_button_Callback(hObject, eventdata, handles)
%  

% --- Executes on button press in expert_box.
function expert_box_Callback(hObject, eventdata, handles)
val = get(handles.expert_box, 'Value');
if val == 1
    str='on';
else
    str='off';
end
s=length(handles.bodEditTags);
for i=1:s
    set(handles.(handles.bodEditTags{i}) ,'Visible', str);
    set(handles.(handles.bodEditTags{i}) ,'String', '  ');
end

 % --- Executes on button press in wireScan_btn.
function wireScan_btn_Callback(hObject, eventdata, handles)
if get(handles.step6remote_box, 'Value') == 1
    wireScanControlQuery(hObject, handles);  
elseif get(handles.step6remote_box, 'Value') == 0
    wireScan(hObject, handles);  
end
    
    
function wireScan(hObject, handles)    
cla(handles.step6_image,'reset');   
val=get(handles.radioU10_btn, 'Value');

if val == 1
    handles.devName = 'BOD10';
    n = 10;
    handles.yagSelect = 1;
else
    handles.devName = 'BOD13';
    n = 13;
    handles.yagSelect = 2;
end

guidata(hObject, handles);
handles=modeManager(hObject, handles);
pvs = cellstr(handles.parameters.pvs);

%find girder coords
geo=girderGeo;
p=girderAxisFind(n,geo.bodz,geo.quadz);
p=p(:,1:2)*1e3;
girderX=p(1); girderY=p(2); %Both in um
lcaPutSmart(pvs(1), girderX);
lcaPutSmart(pvs(2), girderY);
refreshBodGui(handles);

%Wire Scan
for i = 1:2
    
    if i == 1
       handles.processSelectPlane = 'x';
        
    elseif i == 2
         handles.processSelectPlane = 'y';
    end
    
    guidata(hObject, handles);
    [data, ii] = wireScanControl(hObject, handles);
    
    switch ii
        case 1
            pv=pvs(3);
            str1=strcat(handles.devName,  ' X Wire Scan Complete');
        case 2
            pv=pvs(4);
            str1=strcat(handles.devName,  ' Y Wire Scan Complete');
    end
    
    if exist('data','var') && ~isempty(data.beam(2).stats)
        lcaPutSmart(pv,data.beam(2).stats(i));
        refreshBodGui(handles);
        if postMessage(handles,str1); return; end
        guidata(handles.output, handles);
    else
        str1='No data, Acquire Data from WireScan gui or deslect remote check box';
        if postMessage(handles,str1); return; end
        return
    end
end


function [data,j] = wireScanControl(hObject, handles)
[hoScan, hScan]=util_appFind('wirescan_gui');
hScan.extGui=1;
hScan.extHandle=handles;
hScan.extObject=hObject;
guidata(hoScan, hScan);
if get(handles.step6remote_box, 'Value') == 0
    data=wirescan_gui('appRemote',0,handles.devName,handles.processSelectPlane);
    if ~epicsSimul_status
        confirmWireScan(handles)
        axesChildHandles=get(hScan.plotProcess_ax,'children');
        cla(handles.step6_image);
        copyobj(axesChildHandles, handles.step6_image);
        handles.data=data;
        handles.buttonPushDownActive =2;
        dataExport(hObject, handles, 'WireScan');
        dataSave(hObject, handles, 'WireScan');
    end
    if strcmp(handles.processSelectPlane, 'x')
        j=1;
    else
        j=2;
    end
elseif get(handles.step6remote_box, 'Value') == 1
    [data,j] = wireScanControlQuery(hObject, handles);
end
    
function [data,j] = wireScanControlQuery(hObject, handles)
bod=get(handles.radioU10_btn, 'Value');
if bod ==1
    devName ='BOD10';
else
    devName ='BOD13';
end

[hoScan, hScan]=util_appFind('wirescan_gui');
if get(hScan.dataPlaneX_rbn, 'Value')
    j=1;
    processSelectPlane='x';
else
    j=2;
    processSelectPlane='y';
end

data=wirescan_gui('appQuery',0,devName,processSelectPlane);
if ~exist('data','var')
    if isempty(data.beam)
        str1='Confirm Selected Radio Button Matches Device Name';
        if postMessage(handles,str1); return; end
        return
    end
else
    str1='No data, Acquire Data from WireScan gui or deselect remote check box';
    if postMessage(handles,str1); return; end
    return
end
axesChildHandles=get(hScan.plotProcess_ax,'children');
cla(handles.step6_image);
disp('do these pvs change if radio button 389 pressed')
pvs = cellstr(handles.parameters.pvs);

copyobj(axesChildHandles, handles.step6_image);

switch j
    case 1
        pv=pvs(3);
        
    case 2
        pv=pvs(4);
end
lcaPutSmart(pv,data.beam(2).stats(j));
refreshBodGui(handles);
str1='Data Transfered from Wirescan Gui';
if postMessage(handles,str1); return; end
guidata(handles.output, handles);



function data = confirmWireScan(handles)
str=questdlg('Accept Wire Scan & Proceed');
if strcmp('Yes', str)
    return
elseif   strcmp('No', str) || strcmp('Cancel', str)
    set(handles.step6remote_box, 'Value', 1)
    data.beam(2).stats=[0 0];
end
%------------------------------STEP7--------------------------------------


function step7_startup(hObject, handles)
step7_main(hObject, handles)

function step7_main(hObject, handles)
handles.step.currentStep 

% function step7_main(hObject, handles)%TUNING STUFF
% stat=checkUnds(handles,9,16,'OUT');
% if stat ~= 0
%     s7a = 'Step 7a:  Inserts undulators 10-18';
%     if postMessage(handles,s7a); return; end
%     moveUnd5 = setdiff(10:18,[9 16 33]);
%     watchon;
%     if move_undulators_in_out(handles,moveUnd5,1); return; end
%     watchoff;
% end
% 
% s7b = 'Move to 700 um position.';
% if postMessage(handles,s7b); return; end
% set(handles.radiobutton17,'value',1)
% uipanel140_SelectionChangeFcn(hObject, struct('NewValue',handles.radiobutton17), handles)
% 
% 
% s7c = 'Enables undulator 16 feedback.';
% if postMessage(handles,s7c); return; end
% lcaPutSmart('SIOC:SYS0:ML00:AO818',1)
% 
% 
% s7d = 'Step 7d:  If spectrometer is available, look for narrow peak in averaged image (Lutman plot or projected).';
% if postMessage(handles,s7d); return; end
% loadSpectr_btn_Callback(hObject, [], handles);
% 
% 
% s7e = 'Step 7e:  Correlation plot of M3X, chicane delay, M1 pitch, grating Y, M3 roll, M3 pitch..';
% if postMessage(handles,s7e); return; end
% % step7acquireStart_btn_Callback(hObject, [], handles)

if closeoutCheck(hObject, handles); return; end
closeoutStep(hObject, handles);
makeContinueBtn(handles,6)


%Step7 support functions:


function handles = step7_ctrlSetup(handles)
val=get(handles.test_popupmenu, 'Value');
switch val 
    case 1
        %G1Y 
        %moves 70 um in each direction
        dx=70;
        handles.step7ctrlPVtransf = 'GRAT:UND1:934:Y:MOTOR';
        val=lcaGetSmart('GRAT:UND1:934:Y:ACT');
        handles.step7ctrlHigh = val + dx;
        handles.step7ctrlLow = val - dx;
        
    case 2
        %M3X
        %moves 0.2 um in each direction
        dx=0.2;
        handles.step7ctrlPVtransf = 'MIRR:UND1:966:X:MOTOR';
        val=lcaGetSmart(handles.M3XActPV);
        handles.step7ctrlHigh = val + dx;
        handles.step7ctrlLow = val - dx;
        
    case 3
        %M3P
        dx = 0.2;
        handles.step7ctrlPVtransf = 'MIRR:UND1:966:P:MOTOR';
        val=lcaGetSmart(handles.M3PitchActPV);
        handles.step7ctrlHigh = val + dx;
        handles.step7ctrlLow = val - dx;
        
    case 4 
        %M3O
        dx=1.75;
        handles.step7ctrlPVtransf = 'MIRR:UND1:966:O:MOTOR';
        val=lcaGetSmart('MIRR:UND1:966:O:ACT');
        handles.step7ctrlHigh = val + dx;
        handles.step7ctrlLow = val - dx;
        
    case 5
        %M1P
        dx=0.1;
        disp('check slave box On main gui');
        set(handles.listen_checkbox, 'Value', 1);
        handles.step7ctrlPVtransf = 'MIRR:UND1:936:P:MOTOR';
        val=lcaGetSmart(handles.M1PitchActPV);
        handles.step7ctrlHigh = val + dx;
        handles.step7ctrlLow = val - dx;
      
    case 6
        %Delay
        dx=75;
        handles.step7ctrlPVtransf = 'SIOC:SYS0:ML01:AO809';
        val=lcaGetSmart('SIOC:SYS0:ML01:AO809');
        handles.step7ctrlHigh = val + dx;
        handles.step7ctrlLow = val - dx;
          
end

[ho, h]=util_appFind('corrPlot_gui');
set(h.ctrlPVName_txt, 'String', handles.step7ctrlPVtransf);
corrPlot_gui('ctrlPVControl',ho,h,handles.step7ctrlPVtransf,1)

set(h.readPVNameList_txt,'String', ['BPMS:IN20:221:TMIT';'GDET:FEE1:241:ENRC'])

set(h.ctrlPVRangeLow_txt, 'String', handles.step7ctrlLow);
set(h.ctrlPVRangeHigh_txt, 'String',handles.step7ctrlHigh);

corrPlot_gui('ctrlPVRange_txt_Callback',h.ctrlPVRangeLow_txt, [], h, 1, 1)
corrPlot_gui('ctrlPVRange_txt_Callback',h.ctrlPVRangeHigh_txt, [], h, 2, 1)



set(h.acquireBSA_box, 'Value', 6)
corrPlot_gui('acquireBSA_box_Callback', h.acquireBSA_box, [], h);

set(h.acquireSampleNum_txt, 'String','120')
corrPlot_gui('acquireSampleNum_txt_Callback', h.acquireSampleNum_txt, [], h)

set(h.ctrlPVWaitInit_txt, 'String', '3')
corrPlot_gui('ctrlPVWaitInit_txt_Callback', h.ctrlPVWaitInit_txt, [], h)

set(h.ctrlPVWait_txt, 'String', '2')
corrPlot_gui('ctrlPVWait_txt_Callback',h.ctrlPVWait_txt, [], h, 1)

set(h.ctrlPVValNum_txt, 'String', '12')
corrPlot_gui('ctrlPVValNum_txt_Callback',h.ctrlPVValNum_txt, [], h, 1)



   % --- Executes on button press in intensity.
function intensity_Callback(hObject, eventdata, handles)
%reset ROI
handles.yagpv='PROF:UND1:960';
profmon_evrSet(handles.yagpv);
handles.buttonPushDownActive=0;
handles.yagSelect=3; 
handles = autoZoom(handles);   
    
M1P=lcaGetSmart(handles.M1PitchActPV,0,'double');
DX=0.5;
SXRSS_moveMirrors({'M1P'}, DX, 0);
msg='M1 Pitch moved 0.5 mrad away from the SLIT';
if postMessage(handles,msg); return; end
    
%image acquisition starts 
set(handles.intensity2_btn, 'Value',1)
msg='USER: To Confirm Xrays are visible press "Visible" button';
if postMessage(handles,msg); return; end
msg='OPTIONAL: You may tweak M1 Pitch if Xrays are not visible';
if postMessage(handles,msg); return; end
handles = grabImageIntensity(handles);

%image acquisition starts 
handles.show.stats=0;
handles.intensityMode=1;
handles.show.bmCross2=0;
handles.buttonPushDownActive=3;
handles.nAverage =5;
handles.useBG=0;
handles.yagpv='PROF:UND1:960';
guidata(hObject, handles);
profmon_evrSet(handles.yagpv);
handles = step6_grab_image(hObject,handles);

%reset a few things if aborted
if ~strcmp(get(handles.continue_btn,'String'),'Running... Press to Abort')
    set(handles.intensity2_btn, 'Value', 0)
    msg='Step Aborted; Returning M1P to initial value';
    if postMessage(handles,msg); return; end
    SXRSS_moveMirrors({'M1P'}, M1P, 1);
    return
end

%user clicks image, autoZoom invoked, record image in small window,
%and calculate the intensity
str=questdlg('Is the Xray beam visible in this image?');
if strcmp('Yes', str)
    handles.buttonPushDownActive =3;
    handles = screenClick(handles);
elseif strcmp('No', str) || strcmp('Cancel', str)
    msg='Exiting Step...Change to correct ROI and M1P settings. Press "Meas. Intensity" button to restart';
    if postMessage(handles,msg); return; end
    return
end

%Move M1P by 0.5 mrad (from 0th order position) & get new image
%(confirm image taken after M1P get to the location)
handles.yagSelect=3; 
handles.buttonPushDownActive=0;
handles = autoZoom(handles);
handles.intensityMode=2;
handles.scale2=0;
handles.show.bmCross2=0;
msg='M1 Pitch moved 0.5 mrad away from 0th order position';
if postMessage(handles,msg); return; end
SXRSS_moveMirrors({'M1P'}, DX, 1); 

%image acquisition starts 
set(handles.intensity2_btn, 'Value',1)
msg='USER: To Confirm Xrays are visible press "Visible" button';
if postMessage(handles,msg); return; end
handles = grabImageIntensity(handles);
handles = step6_grab_image(hObject,handles);

%reset a few things if aborted
if ~strcmp(get(handles.continue_btn,'String'),'Running... Press to Abort')
    set(handles.intensity2_btn, 'Value', 0)
    msg='Step Aborted; Returning M1P to initial value';
    if postMessage(handles,msg); return; end
    SXRSS_moveMirrors({'M1P'}, M1P, 1);
    return
end

%Step 5: Record image in a small window around the beam (send to logbook)
handles.show.bmCross2=1;
str=questdlg('Is the Xray beam visible in this image?');
if strcmp('Yes', str)
    handles.buttonPushDownActive =3;
    handles = screenClick(handles);
elseif strcmp('No', str) || strcmp('Cancel', str)
    msg='Exiting Step...Change to correct ROI and M1P settings. Press "Meas. Intensity" button to restart';
    if postMessage(handles,msg); return; end
    return
end

msg='M1 Pitch returning to initial position';
if postMessage(handles,msg); return; end
%Return M1P to orginal position 
SXRSS_moveMirrors({'M1P'}, M1P, 1);

msg='Intensity Ratio Value updated';
if postMessage(handles,msg); return; end
%Post logbook entries of both images and ratio of intensities 
ratio=(lcaGetSmart(handles.intensityFirst)/lcaGetSmart(handles.intensityZeroth));

%Record ratio to a PV
lcaPutSmart(handles.intensityRatio, ratio)
set(handles.readIntensity_txt, 'String', num2str(ratio));
handles.yagSelect=3; 
handles.buttonPushDownActive=0;
handles = autoZoom(handles);
guidata(hObject, handles);

function handles = grabImageIntensity(handles)
while get(handles.intensity2_btn, 'Value')
%      handles=guidata(handles.output);
     [d,is]=profmon_names(handles.yagpv);
     PV=handles.yagpv;
     nImg=1;
     if handles.bufd && is.Bufd
         nImg=0;
         lcaPutSmart([PV ':SAVE_IMG'],1);
     end
     
     if handles.useBG
         background=handles.data.back;
         handles.data=profmon_grab(PV,0,nImg);
         handles.data.back=background;
     else
         
         handles.data=profmon_grab(PV,0,nImg);
         handles.data.bg=0;
         handles.data.back=0;
     end
     
     guidata(handles.output, handles)
     profmon_imgPlot(handles.data,'axes', handles.step4_real,'cal',1,'scale2', handles.scale2,'useBG', handles.useBG);
     guidata(handles.output,handles);
     
     if ~get(handles.intensity2_btn, 'Value') || ~strcmp(get(handles.continue_btn,'String'),'Running... Press to Abort')
         break
     end
end

% --- Executes on button press in step7acquireStart_btn.
function step7acquireStart_btn_Callback(hObject, eventdata, handles)
handles=step7_ctrlSetup(handles);
set(handles.step7dataDeviceLabel_txt, 'String', {handles.step7ctrlPVtransf})
initVal=lcaGetSmart(handles.step7ctrlPVtransf);
set(handles.step7ctrlPVInitVal_txt, 'String', sprintf('%6.0f',initVal))
[ho, h]=util_appFind('corrPlot_gui');
set(h.corrPlot_gui,'Visible','off');
h.extGui = 1;
h.pv=handles.step7ctrlPVtransf;
h.ctrlPVSteps =handles.step7ctrlSteps;
h.ctrlPVControlHigh =handles.step7ctrlHigh;
h.ctrlPVControlLow=handles.step7ctrlLow;
h.acquireSampleDelay =handles.step7delay;
h.acquireSampleNum = handles.step7SampleNum;
guidata(ho, h);
corrPlot_gui('acquireStart', ho, h);
[ho, h]=util_appFind('corrPlot_gui');

str=questdlg('Set to Best?');
if strcmp('Yes', str)
corrPlot_gui('setBest_btn_Callback', ho, [], h)          
elseif strcmp('No', str)
    return
elseif strcmp('Cancel', str)
    return
end







% --- Executes on button press in step7acquireAbort_btn.
function step7acquireAbort_btn_Callback(hObject, eventdata, handles)
set(handles.step7acquireStart_btn,'Value',0)

gui_acquireAbortAll;


% --- Executes on button press in step7setBest_btn.
function step7setBest_btn_Callback(hObject, eventdata, handles)
[ho, h]=util_appFind('corrPlot_gui');
corrPlot_gui('setBest_btn_Callback',ho, [],h)



% --- Executes on selection change in step7plotYAxisId_lbx.
function step7plotYAxisId_lbx_Callback(hObject, eventdata, handles)
val=get(handles.step7plotYAxisId_lbx, 'Value');
[ho, h]=util_appFind('corrPlot_gui');
set(h.plotYAxisId_lbx, 'Value', val)
corrPlot_gui('plotYAxisId_lbx_Callback', ho, [], h)

% --- Executes during object creation, after setting all properties.
function step7plotYAxisId_lbx_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in step7useCal_box.
function step7useCal_box_Callback(hObject, eventdata, handles)

handles.step7useCal=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on selection change in test_popupmenu.
function test_popupmenu_Callback(hObject, eventdata, handles)

handles = step7_ctrlSetup(handles);



function step7ctrlSteps_txt_Callback(hObject, eventdata, handles)
handles.step7ctrlSteps=str2double(get(handles.step7ctrlSteps_txt,'String'));
guidata(hObject, handles)



function step7ctrlHigh_txt_Callback(hObject, eventdata, handles)
handles.step7ctrlHigh=str2double(get(handles.step7ctrlHigh_txt,'String'));
guidata(hObject, handles)



function step7ctrlLow_txt_Callback(hObject, eventdata, handles)
handles.step7ctrlLow=str2double(get(handles.step7ctrlLow_txt,'String'));
guidata(hObject, handles)


function step7delay_txt_Callback(hObject, eventdata, handles)
handles.step7delay=str2double(get(handles.step7delay_txt,'String'));
guidata(hObject, handles)


function step7InitSettle_txt_Callback(hObject, eventdata, handles)
handles.step7InitSettle=str2double(get(handles.step7InitSettle_txt,'String'));
guidata(hObject, handles)


function step7Settle_txt_Callback(hObject, eventdata, handles)
handles.step7Settle=str2double(get(handles.step7Settle_txt,'String'));
guidata(hObject, handles)


function step7SampleNum_txt_Callback(hObject, eventdata, handles)
handles.step7SampleNum=str2double(get(handles.step7SampleNum_txt,'String'));
guidata(hObject, handles)


% --- Executes on button press in loadSpectr_btn.
function loadSpectr_btn_Callback(hObject, eventdata, handles)
[ho2, h2]=util_appFind('CVCRCI2');
set(h2.CVCRCI2, 'Visible', 'off');
h2.pauseSXRSS=1;
h2.extGui = 1;
set(h2.ProfileMonitorMenu,'value',1); 
%set(h2.ProfileMonitorMenu,'value',2);
CVCRCI2('ProfileMonitorMenu_Callback', ho2, [], h2);
CVCRCI2('AddVisPan_Callback',ho2, [], h2);
[ho3, h3]=util_appFind('CVCRCI2_visualization_gui');
set(h3.CVCRCI2_visualization_gui, 'Visible', 'off');
h2.h3=h3;
h2.h1=handles;
h2.ho3=ho3;
handles.h3=h3;
guidata(ho2, h2);
guidata(hObject, handles);
startRead_btn_Callback(hObject,[], handles)

% --- Executes on button press in unfreeze_btn.
function unfreeze_btn_Callback(hObject, eventdata, handles)
CVCRCI2('DEBUG_Callback',handles.ho2, [], handles.h2);

% --- Executes on button press in startRead_btn.
function startRead_btn_Callback(hObject, eventdata, handles)
[ho2, h2]=util_appFind('CVCRCI2');
CVCRCI2('Start3_Callback',ho2, [], h2);

% --- Executes on button press in stopRead_btn.
function stopRead_btn_Callback(hObject, eventdata, handles)
[ho2, h2]=util_appFind('CVCRCI2');
CVCRCI2('Stop3_Callback',ho2, [], h2);

% --- Executes on button press in vizPanel_btn.
function vizPanel_btn_Callback(hObject, eventdata, handles)
[ho2, h2]=util_appFind('CVCRCI2');
CVCRCI2('AddVisPan_Callback',ho2, [], h2);



% --- Executes on button press in copyImg_btn.
function copyImg_btn_Callback(hObject, eventdata, handles)
[ho2, h2]=util_appFind('CVCRCI2');
CVCRCI2('grabExtPlot', ho2, h2)


function handles = cpyImg(hObject, handles)
axesChildHandles=get(handles.h3.axes1,'children');
cla(handles.step7vizPanel_ax);
copyobj(axesChildHandles, handles.step7vizPanel_ax);


% --- Executes on button press in step7Expert_box.
function step7Expert_box_Callback(hObject, eventdata, handles)
val = get(handles.step7Expert_box, 'Value');
if val == 1
    str='on';
else
    str='off';
end
set(handles.uipanel392, 'Visible', str)

% --- Executes on selection change in step7_popup.
function step7_popup_Callback(hObject, eventdata, handles)


%--------------------------------------------------------------------------
%Unused but needed 

% --- Executes during object creation, after setting all properties.
function M3Pitch_slider_CreateFcn(hObject, eventdata, handles)
set(hObject,'Min',-4,'Max',10,'Value',lcaGetSmart('MIRR:UND1:966:P:ACT'));   
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function M1Pitch_slider_CreateFcn(hObject, eventdata, handles)
set(hObject,'Min',-59,'Max',14,'Value',lcaGetSmart('MIRR:UND1:936:P:ACT'));
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function step1_PMT_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step1_PMT_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function procedure_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step1_PMT1_VSet_edt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step1_PMT2_VSet_edt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step1_PMT3_VSet_edt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step1_PMT4_VSet_edt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function step_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function step3_from_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step3_to_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step7_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step5_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function M3X_slider_CreateFcn(hObject, eventdata, handles)
set(hObject,'Min',-4,'Max',29,'Value',lcaGetSmart('MIRR:UND1:966:X:ACT'));    
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end






% --- Executes during object creation, after setting all properties.
function step7ctrlHigh_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step7ctrlSteps_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step7ctrlLow_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step7SampleNum_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step7settle_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function step7InitSettle_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function procedure_Callback(hObject, eventdata, handles)

% --- Executes on button press in und3.
function und3_Callback(hObject, eventdata, handles)

% --- Executes on button press in und4.
function und4_Callback(hObject, eventdata, handles)

% --- Executes on button press in und5.
function und5_Callback(hObject, eventdata, handles)

% --- Executes on button press in und2.
function und2_Callback(hObject, eventdata, handles)

% --- Executes on button press in und1.
function und1_Callback(hObject, eventdata, handles)

% --- Executes on button press in und8.
function und8_Callback(hObject, eventdata, handles)

% --- Executes on button press in und10.
function und10_Callback(hObject, eventdata, handles)

% --- Executes on button press in und7.
function und7_Callback(hObject, eventdata, handles)

% --- Executes on button press in und6.
function und6_Callback(hObject, eventdata, handles)

% --- Executes on button press in und13.
function und13_Callback(hObject, eventdata, handles)

% --- Executes on button press in und14.
function und14_Callback(hObject, eventdata, handles)

% --- Executes on button press in und15.
function und15_Callback(hObject, eventdata, handles)

% --- Executes on button press in und12.
function und12_Callback(hObject, eventdata, handles)

% --- Executes on button press in und11.
function und11_Callback(hObject, eventdata, handles)

% --- Executes on button press in und18.
function und18_Callback(hObject, eventdata, handles)

% --- Executes on button press in und19.
function und19_Callback(hObject, eventdata, handles)

% --- Executes on button press in und20.
function und20_Callback(hObject, eventdata, handles)

% --- Executes on button press in und17.
function und17_Callback(hObject, eventdata, handles)

% --- Executes on button press in und23.
function und23_Callback(hObject, eventdata, handles)

% --- Executes on button press in und24.
function und24_Callback(hObject, eventdata, handles)

% --- Executes on button press in und25.
function und25_Callback(hObject, eventdata, handles)

% --- Executes on button press in und22.
function und22_Callback(hObject, eventdata, handles)

% --- Executes on button press in und21.
function und21_Callback(hObject, eventdata, handles)

% --- Executes on button press in und28.
function und28_Callback(hObject, eventdata, handles)

% --- Executes on button press in und29.
function und29_Callback(hObject, eventdata, handles)

% --- Executes on button press in und30.
function und30_Callback(hObject, eventdata, handles)

% --- Executes on button press in und27.
function und27_Callback(hObject, eventdata, handles)

% --- Executes on button press in und26.
function und26_Callback(hObject, eventdata, handles)

% --- Executes on button press in und31.
function und31_Callback(hObject, eventdata, handles)

% --- Executes on button press in und32.
function und32_Callback(hObject, eventdata, handles)

% --- Executes on button press in und33.
function und33_Callback(hObject, eventdata, handles)

    





% --- Executes during object creation, after setting all properties.
function test_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to test_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton13.
function togglebutton13_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton13


% --- Executes on button press in pushbutton89.
function pushbutton89_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton89 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton90.
function pushbutton90_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton91.
function pushbutton91_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton91 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox28.
function listbox28_Callback(hObject, eventdata, handles)
% hObject    handle to listbox28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox28 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox28


% --- Executes during object creation, after setting all properties.
function listbox28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox66.
function checkbox66_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox66


% --- Executes on button press in pushbutton92.
function pushbutton92_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton92 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox29.
function listbox29_Callback(hObject, eventdata, handles)
% hObject    handle to listbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox29 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox29


% --- Executes during object creation, after setting all properties.
function listbox29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in startSpec_btn.
function startSpec_btn_Callback(hObject, eventdata, handles)
[ho,h]=util_appFind('CVCRCI2');

% --- Executes on selection change in bodMode_popup.
function bodMode_popup_Callback(hObject, eventdata, handles)
val = get(handles.bodMode_popup, 'Value');
switch val
    case 1
        return
    case 2
        str='IN';
    case 3
        str='BOD10';
    case 4
        str='BOD13';
    case 5
        str='calcSEED';
end
val=SXRSS_historyConfig(handles.allMirrorTags , str, 1);
val=val';
SXRSS_moveMirrors(handles.allMirrorTags, val, 1);



% --- Executes during object creation, after setting all properties.
function bodMode_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in step6_testbtn.
function step6_testbtn_Callback(hObject, eventdata, handles)
%measureWire(handles)
overlapCalcManual(handles);

% --- Executes on selection change in listbox30.
function listbox30_Callback(hObject, eventdata, handles)
get(handles.listbox30, 'Value')

% --- Executes during object creation, after setting all properties.
function listbox30_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkOptics(handles,str)
% 0-MID-RANGE, 1-IN, 2-OUT, 3-INVALID, 4-MOVING
val=lcaGetSmart(handles.optics.status);
if strcmp(str,'OUT')
    if ~all(strcmp(val,'OUT'))
        str=questdlg('Retract optics?');
        if strcmp('Yes', str)
                opticsAllOut_button_Callback(handles.output, [], handles);
        else
            return
        end
    end
    
elseif strcmp(str, 'IN')
    if ~all(strcmp(val(1:4),'IN'))
        waitfor(warndlg('All optics not in insert position'))
    end
    
end




function [meanGasV inRange aboveRange] = measurePulseEnergy(handles, PEmin, PEmax)
lcaPutSmart(handles.bykikPV, 0);

checkOptics(handles,'OUT')
[meanGasBG stdError]= measurePEcalc(handles);
lcaPutSmart(handles.bykikPV, 1); % Permit Beam

if stdError > 1e-3
    warndlg('More than 1uJ noise. Aborting')
end

%checkUnds(handles, 10, 32,'OUT'); Doesn't do anything
[meanGas ~]= measurePEcalc(handles);
value=meanGas-meanGasBG;
if epicsSimul_status, value=0.004;end

meanGasV=value;
inRange = ((PEmin*0.001) < value & value < (PEmax*0.001));
aboveRange = (value >= (PEmax*0.001));
belowRange = (value <= (PEmax*0.001));

if inRange == 1 && aboveRange == 0
    meanGasstr = sprintf('%.2f',value*1e3);
    notesetp3 = ['The power of the undulators is : ',num2str(meanGasstr),' ',char(956),'J.'];
    if postMessage(handles,notesetp3); return; end
    
    s3n =  'Step 3n:  Presses ''-->E-Log'' button in SXRSS GUI.';
    if postMessage(handles,s3n); return; end
    set(handles.step3_E_txt,'string',[meanGasstr,' ', char(956),'J'])
    set(handles.bodDateStr_txt,'string',datestr(now));
    set(handles.readPulseEnergyBod_txt,'string',sprintf('%6.3f', value*1000)) 
    procedure_log_Callback(handles.output, [], handles,'step3','SXRSS Gain Length')
    lcaPutSmart('SIOC:SYS0:ML01:AO861', value*1000);
    lcaPutSmart('SIOC:SYS0:ML01:AO873', 1); %Did we measure pulse energy
    SXRSS_log(handles.listbox1,'Pulse Energy Updated', 1)
    set(handles.readPulseEnergyBod_txt,'string',sprintf('%6.3f', lcaGetSmart('SIOC:SYS0:ML01:AO861')));
    lcaPutSmart('SIOC:SYS0:ML01:AO872', 1); %Guardian - SAVE FEL Parameters
end


function [meanGas stdError]= measurePEcalc(handles)
rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE'); 
pause(120/rate);
gasData=lcaGet(handles.gasPV);
gasData(1:end-120)=[];
stdError=std(gasData)/sqrt(120);
meanGas=mean(gasData);


% --- Executes on button press in launchUndTaper_btn.
function launchUndTaper_btn_Callback(hObject, eventdata, handles)
[ho,h]=util_appFind('UndulatorTaper_NEW');  
UndulatorTaper_NEW('Open_iSASEpanel_Callback',ho,[],h)
str=[num2str(handles.iSASE_ISS_edit) ':25'];
set(h.iSASE_ISS_edit,'String',str)
UndulatorTaper_NEW('iSASE_ISS_Expression_Callback', ho,[],h);
startPV=['USEG:UND1:',num2str(handles.iSASE_ISS_edit), '50:KACT'];
set(h.iSASE_TaperShape0,'String',num2str(lcaGetSmart(startPV)))
set(h.iSASE_TaperShape1,'String', num2str(handles.iSASE_TaperShape1))
set(h.iSASE_TaperShape2,'String', num2str(handles.iSASE_TaperShape2))
set(h.iSASE_TaperShape3,'String',num2str(handles.iSASE_TaperShape3))
UndulatorTaper_NEW('iSASE_TaperShapeApply_Callback',ho,[],h)
guidata(hObject, handles)


function calculateM1PandDelay(handles, val) 
    
switch val
    case 0 
    photonEnergy=lcaGetSmart(handles.photonEnergyPV);
    photonEnergy_str=sprintf('%6.2f', photonEnergy);
    set(handles.energy_txt, 'String', photonEnergy_str)
    M1P = SXRSS_mono(photonEnergy,1);
    set(handles.M1Pitch_txt,'String', num2str(M1P))
    
    delay=SXRSS_delay(3.85,3.85,0,M1P,15);
    lcaPutSmart(handles.delayPV,round(delay))
    str_delay=sprintf('%6.0f', delay);
    set(handles.delay_txt,'String', str_delay)
    
    case 1
    M1P=lcaGetSmart(handles.M1PitchActPV);  
    
end

lcaPutSmart(handles.M1PitchInPV,M1P); 
SXRSS_log(handles.listbox1,'Delay & M1P Insert Postion updated ')



    
    


% --- Executes on button press in bodOut_button.
function bodOut_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value');
if val==0
    disp('GUI NOT ACTIVE....bodOut_button');
elseif val ==1
    lcaPutSmart(handles.bod10Extract, 1);
    lcaPutSmart(handles.bod13Extract, 1);
end


% --- Executes on button press in bodIn_button.
function bodIn_button_Callback(hObject, eventdata, handles)
val=get(handles.active_checkbox, 'Value');
bod=get(handles.radiobuttonU10, 'Value');
if bod ==1
    lcaPutSmart(handles.bod10Insert, 1);
    lcaPutSmart(handles.bod13Extract, 1);
else
    lcaPutSmart(handles.bod13Insert, 1);
    lcaPutSmart(handles.bod10Extract, 1);
end


% --- Executes when selected object is changed in uipanel399.
function uipanel399_SelectionChangeFcn(hObject, eventdata, handles)
newButton=get(eventdata.NewValue,'tag');
switch newButton
    case 'radiobuttonX'


    case 'radiobuttonY'

end


% --- Executes when selected object is changed in uipanel401.
function uipanel401_SelectionChangeFcn(hObject, eventdata, handles)
handles = guidata(hObject);
newButton=get(eventdata.NewValue,'tag');
switch newButton
    case 'radiobuttonU10'
        handles.yagSelect=1;
        handles.yagpv='YAGS:UND1:1005';
        handles.dxPV='BOD:UND1:1005:MOTOR.TWV';
        handles.useBG = 0;
        
    case 'radiobuttonU13'
        handles.yagSelect=2;
        handles.yagpv='YAGS:UND1:1305';
        handles.dxPV='BOD:UND1:1305:MOTOR.TWV';
end
set(handles.blockSeed_btn, 'Value', 0)
set(handles.(newButton), 'Value', 1)
set(handles.dx_txt, 'String', num2str(lcaGetSmart(handles.dxPV),'%3.3f'));
refreshBodGui(handles);
handles=modeManager(hObject, handles);
handles.buttonPushDownActive =0;

s=length(handles.bodEditTags);
for i=1:s
    set(handles.(handles.bodEditTags{i}) ,'String', '  ');
end
guidata(hObject, handles);


 
% --- Executes on button press in step6remote_box.
function step6remote_box_Callback(hObject, eventdata, handles)
%


function bodEditBoxes_Callback(hObject, eventdata, handles, tag)
index=find(strcmp(tag, handles.bodEditTags));
if get(handles.radioU10_btn, 'Value') ==1
   str='bod10Tags';
elseif get(handles.radioU13_btn, 'Value') ==1
     str='bod13Tags';
end
tags=cell(size({tag}));
[tags{:}]=deal('ML01');w
[pv, ~]= SXRSS_pvBuilder(tags, handles.(str)(index));
disp(pv)
SXRSS_textBox(pv, handles.(tag),handles.active_checkbox,tag,handles.listbox1);
overlapCalcManual(handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, title)
handles.exportFig=figure;
if handles.buttonPushDownActive ==1 || handles.buttonPushDownActive ==2
    str='step6_image';
elseif handles.buttonPushDownActive ==3
    str='step4_real';
end

util_copyAxes(handles.(str));
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
util_printLog(handles.exportFig,'title', [title ' ' handles.yagpv]);


if isfield(handles, 'exportFig')
    cla(handles.exportFig);
    close(handles.exportFig);
end


function handles = dataSave(hObject, handles, title)
if ~isfield(handles,'data'), return, end
data=handles.data;
if strcmp(title, 'ProfMon')
    name=data.name;
elseif strcmp(title, 'WireScan')
    name=data.wireName;
end
fileName=util_dataSave(data,title,name,data.ts);
if ~ischar(fileName), return, end
handles.fileName=fileName;
guidata(hObject,handles);


% --- Executes on button press in scan_btn.
function scan_btn_Callback(hObject, eventdata, handles)
[ho,h]=util_appFind('SoftSeedingScan');


function nAvg_txt_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in selectAll_btn.
function selectAll_btn_Callback(hObject, eventdata, handles)
val=get(handles.selectAll_btn, 'Value');
nums=[1:8 10:15 17:32];
for i=1:length(nums)
    str=strcat('und',num2str(nums(i)));
    set(handles.(str), 'Value', val)
end

    
% --- Executes on button press in profmon_gui_btn.
function profmon_gui_btn_Callback(hObject, eventdata, handles)
openProfmon_Gui(handles)


% --- Executes on button press in profmon_gui_btn2.
function profmon_gui_btn2_Callback(hObject, eventdata, handles)
openProfmon_Gui(handles)

function openProfmon_Gui(handles)
[ho,h]=util_appFind('profmon_gui');
set(h.pv_txt,'String',model_nameConvert('YAGBOD1'));
profmon_gui('pv_txt_Callback',h.pv_txt, [], h);
%profmon_gui('single_btn_Callback',ho, [], guidata(ho))


% --- Executes on button press in intensity_btn.
function intensity_btn_Callback(hObject, eventdata, handles)
intensity_Callback(hObject, [], handles)


% --- Executes on button press in step5_confirmed.
function step5_confirmed_Callback(hObject, eventdata, handles)
closeoutStep(hObject, handles);
  


% --- Executes on button press in intensity2_btn.
function intensity2_btn_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in help_btn.
function help_btn_Callback(hObject, eventdata, handles)
if isempty(handles.step.currentStep)
    handles.step.currentStep=1;
end
system(['firefox -new-window https://www.slac.stanford.edu/grp/ad/idea/sxrss_documentation.html#step' num2str(handles.step.currentStep) ' &']);
