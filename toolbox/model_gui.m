% Changelog:
% Cosmetics:
%  - Make plot markers more visible
%  - Suppress MATLAB:lscov:RankDefDesignMat warning
%  - Set default of second model to extant
%  - Change loader name filter to OrbitGrid*.mat
%  - Show reference location
%  - Datapicker shows name of bpm
%  - Default Sample# set to 60
% Core:
%  - Only disables feedbacks downstream of the first kicker (model_orbitAcq.m)
%  - Change magnet set from perturb to trim (had to revert this one because of bug in trim, change in model_orbitAcq.m (ACTION))
%  - Added phase advance
%  - Get both models when clicking start (Callback of Start button)

% Pointers to Henricks code:
% -> 0 seems to be indicator to design: r0List, etc
% -> Check switch off feedback



function varargout = model_gui(varargin)
% MODEL_GUI M-file for model_gui.fig
%      MODEL_GUI, by itself, creates a new MODEL_GUI or raises the existing
%      singleton*.
%
%      H = MODEL_GUI returns the handle to a new MODEL_GUI or the handle to
%      the existing singleton*.
%
%      MODEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODEL_GUI.M with the given input arguments.
%
%      MODEL_GUI('Property','Value',...) creates a new MODEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before model_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to model_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help model_gui

% Last Modified by GUIDE v2.5 11-Nov-2019 14:07:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @model_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @model_gui_OutputFcn, ...
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


% --- Executes just before model_gui is made visible.
function model_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to model_gui (see VARARGIN)

% Choose default command line output for model_gui
handles.output = hObject;

handles.region={};
%handles.regionDef.LCLS = {'BC2_L3END' 'BSY' 'LTU0' 'LTU1' 'UND1'};
handles.regionDef.LCLS = {'BC2_L3END' 'CLTH_0' 'CLTH_1' 'CLTH_2' 'BSYH_1' 'BSYH_2' 'LTUH' 'UNDH' };
handles.regionDef.FACET = {'LI19' 'LI20'};
handles.opts.iG = 2;
handles.modelRef='';
handles.modelSource1='MATLAB';
handles.modelSource2='MATLAB';
handles.modelType1='DESIGN';
handles.modelType2='DESIGN';
handles.displayR=0;
handles.displayTwiss=0;
handles.displayDiff=0;
handles=modelSourceControl(hObject,handles,1,[]);
handles=modelSourceControl(hObject,handles,2,[]);
handles=modelTypeControl(hObject,handles,1,[]);
handles=modelTypeControl(hObject,handles,2,[]);
handles=modelRefControl(hObject,handles,[]);
handles=displayBoxControl(hObject,handles,'displayR',[]);
handles=displayBoxControl(hObject,handles,'displayTwiss',[]);
handles=displayBoxControl(hObject,handles,'displayDiff',[]);

set([handles.iRef_txt handles.nGrid_txt handles.range_txt handles.nSig_txt ...
    handles.nOrbit_txt handles.nJitt_txt handles.nCorr_txt handles.iBad_txt ...
    handles.iKick_txt], ...
    {'String'},{'1' '6' '5' '0.5' '100' '2800' '30' '' ''}');
handles=gui_sliderControl(hObject,handles,'iBPM',1,1);
handles=gui_sliderControl(hObject,handles,'iOrb',1,1);

handles.simul=struct( ...
    'useBeamJitt',1, ...
    'useBPMNoise',1, ...
    'useBPMScale',1, ...
    'useBPMRoll',1, ...
    'useQuadErr',1, ...
    'useBeamEnerJitt',1, ...
    'beamJitt',10, ... % um
    'beamAngle',.5, ... % urad
    'bpmNoise',1, ... % um
    'bpmScale',1, ... % (%)
    'bpmRoll',1, ... % Deg
    'quadErr',1, ... % (%)
    'beamEnerJitt',1 ... % 1e-4
    );

handles.opts=struct( ...
    'useCorr',0, ...
    'nJitt',2800, ...
	'nCorr',60, ...
	'nGrid',6, ...
	'nSig',.5, ...
    ...
    'range',5, ...
    'iBad',[], ...
	'nOrbit',100, ...
	'iRef',1, ...
	'show3D',0, ...
	'showPS',0, ...
	'iKick',[], ...
	'iKickSk',[], ...
    'showDiff',0, ...
    'showNorm',0, ...
    'showDeriv',0 ...
    );

handles=appSetup(hObject,handles);
handles = regionControl(hObject,handles,'');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes model_gui wait for user response (see UIRESUME)
% uiwait(handles.model_gui);

modelGet1_btn_Callback(hObject, [], handles);
handles = guidata(hObject); % Necessary since struct is a value class
modelGet2_btn_Callback(hObject, [], handles);


% --- Outputs from this function are returned to the command line.
function varargout = model_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% --- Executes when user attempts to close model_gui.
function model_gui_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

txtList={'bpmNoise' 'beamJitt' 'beamAngle' 'bpmScale' 'bpmRoll' 'quadErr' 'beamEnerJitt'};
for tag=txtList
    txtControl(hObject,handles,tag{:},[]);
end
boxList=strcat('use',{'BPMNoise' 'BeamJitt' 'BPMScale' 'BPMRoll' 'QuadErr'});
for tag=boxList
    boxControl(hObject,handles,tag{:},[]);
end
txtList={'nJitt' 'nCorr' 'nGrid' 'nSig' 'range' 'iBad' 'nOrbit' 'iRef' 'iKick' 'iKickSk'};
for tag=txtList
    optsTextControl(hObject,handles,tag{:},[]);
end
boxList=[strcat('use',{'Corr'}) strcat('show',{'3D' 'PS' 'Diff' 'Norm' 'Deriv'})];
for tag=boxList
    optsBoxControl(hObject,handles,tag{:},[]);
end
[~,accel] = getSystem;
bpmnames = model_nameConvert(model_nameRegion('XCOR',accel),'MAD');
set(handles.xcor1_popup,'string',bpmnames);

    

% ------------------------------------------------------------------------
function handles = boxControl(hObject, handles, tag, val)

if isempty(val)
    val=handles.simul.(tag);
end
handles.simul.(tag)=val;
set(handles.([tag '_box']),'Value',val);
guidata(hObject, handles);
assignin('base','simul',handles.simul);


% ------------------------------------------------------------------------
function handles = txtControl(hObject, handles, tag, val)

if isempty(val) || any(isnan(val))
    val=handles.simul.(tag);
end
handles.simul.(tag)=val;
set(handles.([tag '_txt']),'String',num2str(val,'%g '));
guidata(hObject, handles);
assignin('base','simul',handles.simul);


% ------------------------------------------------------------------------
function handles = modelSourceControl(hObject, handles, num, tag)

handles=gui_popupMenuControl(hObject,handles,['modelSource' num2str(num)], ...
    tag,{'EPICS' 'MATLAB' 'SLC'},{'XAL' 'Matlab' 'DIMAD'});


% ------------------------------------------------------------------------
function handles = modelTypeControl(hObject, handles, num, tag)

handles=gui_popupMenuControl(hObject,handles,['modelType' num2str(num)], ...
    tag,{'EXTANT' 'DESIGN' 'DATABASE'},{'Extant' 'Design' 'Database'});


% ------------------------------------------------------------------------
function handles = regionControl(hObject, handles, name)

if isempty(name) || any(strcmp(name,''))
    [~,accel] = getSystem;
    
    handles.region = handles.regionDef.(accel);
    set(handles.region_txt,'String',sprintf('%s ',handles.region{:}));
else
    handles.region=name;
    set(handles.region_txt,'String',sprintf('%s ',name{:}))
end

%handles=gui_textControl(hObject,handles,'region',name);

prim={'PROF' 'OTRS' 'YAGS' 'WIRE' 'BPMS' 'QUAD' 'QUAS' 'BEND' 'BNDS' 'XCOR' 'YCOR' 'SOLN'};
n=model_nameConvert(model_nameRegion(prim,handles.region),'MAD');
n(ismember(n,{'SOL1BK'}))=[];
handles.names=n;
set(handles.gridBPM_popup,'string',...
    model_nameConvert(model_nameRegion({'BPMS'},handles.region),'MAD'));
handles=region2bpm(handles);
guidata(hObject,handles);



function handles = region2bpm(handles)
[~,accel] = getSystem;
try
    n = model_nameConvert(model_nameRegion('XCOR',handles.region),'MAD');
    set(handles.xcor1_popup,'value',...
        find(strcmp(get(handles.xcor1_popup,'string'),n{1}),1,'first'));
    lab = strcat(', ', n{2});
    n = model_nameConvert(model_nameRegion('YCOR',handles.region),'MAD');
    lab = strcat(lab, ', ', n{1}, ', ', n{2});
    set(handles.corrsUsed_txt,'string',lab);
    r = model_nameDevToEnd(n{2});
    r = model_nameRegion('BPMS',r);
    handles.opts.iG = find(...
        strcmp(model_nameConvert(get(handles.gridBPM_popup,'string')),r{1}),1,'first');
    set(handles.gridBPM_popup,'value',handles.opts.iG);
catch
    handles.opts.iG = handles.regionDef.iG;
    handles = regionControl(handles.region_txt,handles,'');
end



function region = model_nameDevToEnd(dev)
% For a given device, construct a model_nameRegion compatible string that
% describes the region from that device to the end of the line.

% Get this into a standard external funciton at some point.

% In case MAD was given
dev = model_nameConvert(dev);
[prim,micro,unit] = model_nameSplit(dev);
[~,accel] = getSystem;
if strcmp(accel,'LCLS')
    micros = {'IN20','LI21','LI22','LI23','LI24','LI25','LI26','LI27',...
        'LI28','LI29','LI30','CLTH','BSYH','LTU0','LTU1','UND1','DMP1'};
elseif strcmp(accel,'FACET')
    micros = {'LI11','LI12','LI13','LI14','LI15','LI16','LI17','LI18',...
        'LI19','LI20'};
end
micros(1:(find(strcmp(micros,micro))-1)) = [];
micros{1} = [micros{1},':',num2str(str2num(unit{1})-1),':','9999'];
region = micros;



% ------------------------------------------------------------------------
function handles = modelRefControl(hObject, handles, name)

handles=gui_textControl(hObject,handles,'modelRef',name);


% ------------------------------------------------------------------------
function handles = displayBoxControl(hObject, handles, tag, val)

handles=gui_checkBoxControl(hObject,handles,tag,val);
modelPlot(hObject,handles);


% ------------------------------------------------------------------------
function modelPlot(hObject, handles)

if ~handles.displayTwiss && ~handles.displayR, return, end

nBPM=numel(handles.names);


z=max(handles.z1,handles.z2);
[z,id]=sort(z);
z1=handles.z1(id);z2=handles.z2(id);
id1=1:nBPM;id2=1:nBPM;
bad1=~z1;bad2=~z2;
z1(bad1)=NaN;z2(bad2)=NaN;

if handles.displayTwiss
fig=4;
figure(fig);
t1=reshape(handles.twiss1([2:6 1 7:end 1],id),[],2,nBPM);
t2=reshape(handles.twiss2([2:6 1 7:end 1],id),[],2,nBPM);
t1(:,:,bad1)=NaN;t2(:,:,bad2)=NaN;
use1=any(t1(2,1:2,:));use2=any(t2(2,1:2,:));
t1(:,:,~use1)=NaN;t2(:,:,~use2)=NaN;
if handles.displayDiff, t1=t1-t2;t2(:)=NaN;end

ind=[2 2 3 3 4 4 5 5 1 1;1 2 1 2 1 2 1 2 1 2];
nAx=size(ind,2);ax=zeros(1,nAx);lab={'\beta' '\alpha' '\eta' '\eta'''};l2={'x' 'y'};
for j=1:nAx-2
    k=ind(1,j);l=ind(2,j);
    ax(j)=subplot(nAx/2,2,j);
    plot(z1(use1),squeeze(t1(k,l,use1)),'-',z2(use2),squeeze(t2(k,l,use2)),'-r');
%    ylabel([lab{k-1} '_' l2{l}]);
    text(.1,.8,[lab{k-1} '_' l2{l}],'Units','normalized');
end
ax(j+1)=subplot(nAx/2,2,j+(1:2));
plot(z1,squeeze(t1(6,1,id1)),'-',z2,squeeze(t2(6,1,id2)),'-r');
%ylabel('Energy');
text(.1,.8,'Energy','Units','normalized');
xlabel(ax(end-1),'z  (m)');
%xlabel(ax(end),'z  (m)');
%title(ax(1),['Reference ' handles.data.static.bpmList{iRef}]);
set(ax(1:end-2),'XTicklabel',[]);
set(ax(1:end-1),'XLim',[min(z(~~z)) max(z(~~z))]);
util_marginSet(fig,[.08 .08 .04],[.08 repmat(.02,1,nAx/2-1) .04]);
end

if handles.displayR
fig=3;
figure(fig);clf
r1=reshape(handles.r1,[],6,nBPM);
r2=reshape(handles.r2,[],6,nBPM);
r1=r1(:,:,id);r2=r2(:,:,id);r1(:,:,bad1)=NaN;r2(:,:,bad2)=NaN;
use1=any(r1(2:6,1,:));use2=any(r2(2:6,1,:));
r1(:,:,~use1)=NaN;r2(:,:,~use2)=NaN;
if handles.displayDiff, r1=r1-r2;r2(:)=NaN;end

rMax=max(r1(:,:,use1 & use2),r2(:,:,use1 & use2));
m(1,1)=max(max(max(abs(rMax([1 3],[1 3],:)))));
m(2,1)=max(max(max(abs(rMax([2 4],[1 3],:)))));
m(1,2)=max(max(max(abs(rMax([1 3],[2 4],:)))));
m(2,2)=max(max(max(abs(rMax([2 4],[2 4],:)))));
m(1,3)=max(max(max(abs(rMax([1 3],   6 ,:)))));
m(2,3)=max(max(max(abs(rMax([2 4],   6 ,:)))));
m(~m)=1;

leg={};
%ind=[1 1 2 2 3 3 4 4 1 2 3 4 5 5 6 6;1 2 1 2 3 4 3 4 6 6 6 6 5 6 5 6];nCol=2;
[i2,i1]=ndgrid(1:6);ind=[i1(:) i2(:)]';nCol=6;
nAx=size(ind,2);ax=zeros(1,nAx);
for j=1:nAx
    k=ind(1,j);l=ind(2,j);
    ax(j)=subplot(ceil(nAx/nCol),nCol,j);
%    plot(z(iRef),0,'xg');
    h=plot(z1(use1),squeeze(r1(k,l,use1)),'-',z2(use2),squeeze(r2(k,l,use2)),'r');
%    ylabel(['R_{' num2str([k l],'%d') '}']);hold off
    text(.1,.8,['R_{' num2str([k l],'%d') '}'],'Units','normalized');hold off
    if j==1 && ~isempty(leg), legend(h,leg);legend boxoff, end
    if j > (ceil(nAx/nCol)-1)*nCol, xlabel(ax(j),'z  (m)');
    else set(ax(j),'XTicklabel',[]);end
    if k < 5 && l < 5
        ylim(ax(j),m(mod(k-1,2)+1,mod(l-1,2)+1)*[-1 1]);
    end
    if k < 5 && l == 6
        ylim(ax(j),m(mod(k-1,2)+1,3)*[-1 1]);
    end
end
set(ax,'XLim',[min(z(~~z)) max(z(~~z))]);
%title(ax(1),['Reference ' handles.data.static.bpmList{iRef}]);
util_marginSet(fig,[.08 repmat(.04,1,nCol-1) .04],[.08 repmat(.02,1,ceil(nAx/nCol)-1) .04]);
end


% --- Executes on button press in modelGet1_btn.
function modelGet_btn_Callback(hObject, eventdata, handles, num)
set(handles.output,'Pointer','watch');drawnow;
num=num2str(num);
source=handles.(['modelSource' num]);
mType=handles.(['modelType' num]);
beamPath = get(handles.beamPath_btn,'String');
model_init('source',source,'online',~strcmp(source,'MATLAB'));
[r,z,lEff,twiss,en]=model_rMatGet(handles.names,[],{['TYPE=' mType], ['BEAMPATH=' beamPath]});

if ~isempty(handles.modelRef) && ~strcmp(mType,'DESIGN')
    r=model_rMatGet(handles.modelRef,handles.names,['TYPE=' mType]);
    t=model_twissGet(handles.modelRef,['TYPE=' 'DESIGN']);
    tw=model_twissTrans(t,r);
    twiss([3 4 8 9],:)=reshape(tw(2:3,:,:),4,[]);
    twiss([5 6 10 11],:)=squeeze(r(1:4,6,:))./repmat(squeeze(r(6,6,:))',4,1); % Dispersion, R_16,26/R_66
end
handles.(['z' num])=z;handles.(['r' num])=r;
handles.(['twiss' num])=twiss;handles.(['en' num])=en;
set(handles.output,'Pointer','arrow');drawnow;
guidata(hObject,handles);


% --- Executes on button press in modelGet1_btn.
function modelGet1_btn_Callback(hObject, eventdata, handles)

modelGet_btn_Callback(hObject,[],handles,1);


% --- Executes on button press in modelGet2_btn.
function modelGet2_btn_Callback(hObject, eventdata, handles)

modelGet_btn_Callback(hObject,[],handles,2);


% --- Executes on selection change in modelSource1_pmu.
function modelSource1_pmu_Callback(hObject, eventdata, handles)

modelSourceControl(hObject,handles,1,get(hObject,'Value'));


% --- Executes on selection change in modelSource2_pmu.
function modelSource2_pmu_Callback(hObject, eventdata, handles)

modelSourceControl(hObject,handles,2,get(hObject,'Value'));


% --- Executes on button press in modelType1_pmu.
function modelType1_pmu_Callback(hObject, eventdata, handles)

modelTypeControl(hObject,handles,1,get(hObject,'Value'));


% --- Executes on button press in modelType2_pmu.
function modelType2_pmu_Callback(hObject, eventdata, handles)

modelTypeControl(hObject,handles,2,get(hObject,'Value'));


function modelRef_txt_Callback(hObject, eventdata, handles)

modelRefControl(hObject,handles,get(hObject,'String'));


% --- Executes on button press in displayR_box.
function displayR_box_Callback(hObject, eventdata, handles)

displayBoxControl(hObject,handles,'displayR',get(hObject,'Value'));


% --- Executes on button press in displayDiff_box.
function displayDiff_box_Callback(hObject, eventdata, handles)

displayBoxControl(hObject,handles,'displayDiff',get(hObject,'Value'));


% --- Executes on button press in displayTwiss_box.
function displayTwiss_box_Callback(hObject, eventdata, handles)

displayBoxControl(hObject,handles,'displayTwiss',get(hObject,'Value'));


function region_txt_Callback(hObject, eventdata, handles)

regionControl(hObject,handles,regexp(strtrim(get(hObject,'String')),' ','split'));


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

data=evalin('base','handles.data');
name='';
if isfield(data,'name') && 0
    name=cellstr(data.name);
    if numel(name) == 1, name=name{1};
    else name=[name{1} '-' name{end}];
    end
end
util_dataSave(data,'OrbitGrid',name,data.ts);
%save(['slidOrbit_' datestr(data.ts,'yyyy-mm-dd-HHMMSS')],'data');


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles, val)

%[file,pName]=uigetfile;if ~ischar(file), return, end
%data=load(fullfile(pName,file));
if nargin == 4, fileName=val;
    load(fileName,'data');
else
    [data,fileName]=util_dataLoad('Open image file', 0, 'OrbitGrid*.mat');
end
if ~ischar(fileName), return, end

if ~isfield(data,'ts')
    data.ts=datenum(file(11:end-4),'yyyy-mm-dd-HHMMSS');
end
handles.data = data;
assignin('base','handles',handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

if val
    util_printLog(3,'title','Model Measurement');
    dataSave_btn_Callback(hObject,[],handles);
end


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

modelGet1_btn_Callback(hObject, eventdata, handles);
modelGet2_btn_Callback(hObject, eventdata, handles);


set(hObject,'Value',~get(hObject,'Value'));
if gui_acquireStatusSet(hObject,handles,1);return, end

opts=handles.opts;
opts.simul=handles.simul;
opts.sector=handles.region;
opts.guihandles = handles;

try
    extModel = getAllMatlabModel();
catch ex
    disp('Couldn''t get model!')
    disp(ex.message);
    extModel = [];
end
derp=model_orbitAcq(opts);
if ~isempty(derp)
    data.data = derp;
    out=model_orbitProc(data.data,opts);
    data.data.procOrbits = out;
    data.data.opts = opts;
    data.data.extModel = extModel;
    assignin('base','handles',data);
    assignin('base','out',out);
end

gui_acquireStatusSet(hObject,handles,0);


% --- Executes on button press in aquireAbort_btn.
function aquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% ------------------------------------------------------------------------
function handles = optsTextControl(hObject, handles, tag, val)

if isempty(val) || any(isnan(val))
    val=handles.opts.(tag);
end
handles.opts.(tag)=val;
set(handles.([tag '_txt']),'String',num2str(val,'%g '));
guidata(hObject, handles);
assignin('base',tag,val);


% ------------------------------------------------------------------------
function handles = optsBoxControl(hObject, handles, tag, val)

if isempty(val)
    val=handles.opts.(tag);
end
handles.opts.(tag)=val;
set(handles.([tag '_box']),'Value',val);
guidata(hObject, handles);
assignin('base',tag,val);


% --- Executes on button press in useCorr_box.
function useCorr_box_Callback(hObject, eventdata, handles)

optsBoxControl(hObject,handles,'useCorr',get(hObject,'Value'));


function nJitt_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'nJitt',str2double(get(hObject,'String')));


function nCorr_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'nCorr',str2double(get(hObject,'String')));


function nGrid_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'nGrid',str2double(get(hObject,'String')));


function nSig_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'nSig',str2double(get(hObject,'String')));


function range_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'range',str2double(get(hObject,'String')));


function iBad_txt_Callback(hObject, eventdata, handles)

assignin('base','iBad',str2num(char(get(hObject,'String'))));
optsTextControl(hObject,handles,'iBad',str2num(get(hObject,'String')));


function nOrbit_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'nOrbit',str2double(get(hObject,'String')));


function iRef_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'iRef',str2double(get(hObject,'String')));


% --- Executes on button press in show3D_box.
function show3D_box_Callback(hObject, eventdata, handles)

optsBoxControl(hObject,handles,'show3D',get(hObject,'Value'));


% --- Executes on button press in showPS_box.
function showPS_box_Callback(hObject, eventdata, handles)

optsBoxControl(hObject,handles,'showPS',get(hObject,'Value'));


function iKick_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'iKick',str2num(get(hObject,'String')));


function iKickSk_txt_Callback(hObject, eventdata, handles)

optsTextControl(hObject,handles,'iKickSk',str2num(get(hObject,'String')));


% --- Executes on button press in showDiff_box.
function showDiff_box_Callback(hObject, eventdata, handles)

optsBoxControl(hObject,handles,'showDiff',get(hObject,'Value'));


% --- Executes on button press in showNorm_box.
function showNorm_box_Callback(hObject, eventdata, handles)

optsBoxControl(hObject,handles,'showNorm',get(hObject,'Value'));


% --- Executes on button press in showDeriv_box.
function showDeriv_box_Callback(hObject, eventdata, handles)

optsBoxControl(hObject,handles,'showDeriv',get(hObject,'Value'));


% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)

data=evalin('base','handles.data');
handles.opts.iBPM=handles.iBPM.iVal;
out=model_orbitProc(data,handles.opts);
assignin('base','out',out);

handles=gui_sliderControl(hObject,handles,'iBPM',[],numel(data.static.bpmList));
gui_sliderControl(hObject,handles,'iOrb',[],out.nOrb);


% --- Executes on slider movement.
function iBPM_sl_Callback(hObject, eventdata, handles)

handles=gui_sliderControl(hObject,handles,'iBPM',round(get(hObject,'Value')),[]);

plotPS(hObject,handles);
plotOrbit(hObject,handles);


% --- Executes on slider movement.
function iOrb_sl_Callback(hObject, eventdata, handles)

handles=gui_sliderControl(hObject,handles,'iOrb',round(get(hObject,'Value')),[]);

plotOrbit(hObject,handles);
plotPS(hObject,handles);


% ------------------------------------------------------------------------
function plotPS(hObject, handles)

data=evalin('base','handles.data');
out=evalin('base','out');

nSig=handles.opts.nSig;
model_orbitPSPlot(data,out.orbitXY,out.posxy,out.r,handles.iBPM.iVal,handles.iOrb.iVal,nSig);
set(handles.iBPMLabel_txt,'String',data.static.bpmList(handles.iBPM.iVal));


% ------------------------------------------------------------------------
function plotOrbit(hObject, handles)

data=evalin('base','handles.data');
out=evalin('base','out');

%iPS=[1 2 3 4 5];iDa=[1 0 2 0 0];
iPS=[1 3];iDa=[1 2];
nAx=numel(iPS);nCol=1;nRow=nAx;
[ax,fig]=util_plotInit('figure',6,'axes',{{nAx nCol}},'keep',1);
z=data.static.zBPM;iOrb=handles.iOrb.iVal;iBPM=handles.iBPM.iVal;
xLim=[min(z(z>0)) max(z)]*[21 -1;-1 21]/20;
if strcmp(get(zoom(fig),'Enable'),'on') && ~any(cellfun('isempty',get(ax,'Children')))
    xLim=cell2mat(get(ax,'XLim'));xLim=[max(xLim(:,1)) min(xLim(:,2))];
end
leg={'Measured' 'Local Fit' 'Fit'};

for j=1:nAx
    use=z > xLim(1) & z < xLim(2) & z ~= 0;
    yLim=max(max(abs(out.orbitXY(iPS(j),:,use))))*1e6;if yLim == 0, yLim=1;end
    if iDa(j)
        plot(ax(j),z,out.posxy(iDa(j),:,iOrb)*1e6,'.-');
        hold(ax(j),'on');
        y = out.posxyf(iDa(j),:,iOrb,iBPM)*1e6;
        y(~use) = nan;
        plot(ax(j),z,y,'.--g');
    end
    
%    errorbar(ax(j),z,squeeze(out.orbitXY(iPS(j),iOrb,:))*1e6, ...
%        squeeze(out.orbitStdXY(iPS(j),iOrb,:))*1e6,':r');
    plot(ax(j),z,squeeze(out.orbitXY(iPS(j),iOrb,:))*1e6,':xr');
    hold(ax(j),'on');
    plot(ax(j),z(iBPM)*[1 1],yLim*[-1.1 1.1],'k-');
    plot(ax(j),z([1 end]),[0 0],'k-');
    hold(ax(j),'off');
    set(ax(j),'YLim',yLim*[-1.1 1.1]);
    xlim(ax(j),xLim);
%    if j==1, legend(h,leg);legend(ax(j),'boxoff');end
    if j > (nRow-1)*nCol, xlabel(ax(j),'z  (m)');
    else set(ax(j),'XTicklabel',[]);end
end
title(ax(1),[data.static.bpmList{iBPM} ' ' num2str(z(iBPM),'z = %6.2f m')]);
legend(ax(1),leg);
util_marginSet(fig,[.1 repmat(.01,1,nCol-1) .05],[.08 repmat(.01,1,nRow-1) .05]);


% --- Executes on button press in useBeamJitt_box.
function useBeamJitt_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBeamJitt',get(hObject,'Value'));


% --- Executes on button press in useBPMNoise_box.
function useBPMNoise_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBPMNoise',get(hObject,'Value'));


% --- Executes on button press in useBPMScale_box.
function useBPMScale_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBPMScale',get(hObject,'Value'));


% --- Executes on button press in useBPMRoll_box.
function useBPMRoll_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBPMRoll',get(hObject,'Value'));


% --- Executes on button press in useQuadErr_box.
function useQuadErr_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useQuadErr',get(hObject,'Value'));


function beamJitt_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'beamJitt',str2num(get(hObject,'String')));


function beamAngle_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'beamAngle',str2num(get(hObject,'String')));


function bpmNoise_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'bpmNoise',str2num(get(hObject,'String')));


function bpmScale_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'bpmScale',str2num(get(hObject,'String')));


function bpmRoll_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'bpmRoll',str2num(get(hObject,'String')));


function quadErr_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'quadErr',str2num(get(hObject,'String')));


function beamEnerJitt_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'beamEnerJitt',str2num(get(hObject,'String')));


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on selection change in xcor1_popup.
function xcor1_popup_Callback(hObject, eventdata, handles)
% hObject    handle to xcor1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selected BPM and reset region
devlist = get(hObject,'string');
dev = devlist{get(hObject,'value')};
regionControl(hObject,handles,model_nameDevToEnd(dev));



% --- Executes during object creation, after setting all properties.
function xcor1_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xcor1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in gridBPM_popup.
function gridBPM_popup_Callback(hObject, eventdata, handles)
% hObject    handle to gridBPM_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns gridBPM_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gridBPM_popup


% --- Executes during object creation, after setting all properties.
function gridBPM_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridBPM_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function extModel = getAllMatlabModel()
[r,extModel.z,...
    extModel.lEff,...
    extModel.energy,...
    reg]=model_rMatModel('FullMachine',[],'TYPE=EXTANT');
extModel.R = r{1};
extModel.name = r{2};
% Twiss parameters are [En (mu b a D Dp)_x (mu b a D Dp)_y]
[twissT,~,~,psi]=model_twissGet(extModel.name,'TYPE=EXTANT','rMat',...
    extModel.R,'en',extModel.energy,'reg',reg);
twiss([1 2 7 3 4 8 9],1:numel(extModel.energy))=[extModel.energy;psi;reshape(twissT(2:3,:),4,[])];
twiss([5 6 10 11],:)=squeeze(extModel.R(1:4,6,:))./repmat(squeeze(extModel.R(6,6,:))',4,1); % Dispersion, R_16,26/R_66
extModel.twiss = twiss;


% --- Executes on button press in beamPath_btn.
function beamPath_btn_Callback(hObject, eventdata, handles)
% hObject    handle to beamPath_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=gui_beamPathControl(hObject,handles,[]);
gui_beamPathControl(hObject,handles,mod(val,2)+1);
beamPath = get(handles.beamPath_btn,'String');
switch beamPath
    case 'CU_HXR'
        beamPathRegions = {'BC2_L3END' 'CLTH_0' 'CLTH_1' 'CLTH_2' 'BSYH_1' 'BSYH_2' 'LTUH' 'UNDH' };
    case 'CU_SXR'
        beamPathRegions = {'BC2_L3END' 'CLTH_0' 'CLTH_1' 'CLTS'  'BSYS' 'LTUS' 'UNDS' };
end
set(handles.region_txt,'String',  sprintf('%s ',beamPathRegions{:}) )
handles.regionDef.LCLS = beamPathRegions;
handles = regionControl(hObject, handles, '');

%modelGet1_btn_Callback(hObject, [], handles);
modelGet1_btn_Callback(handles.model_gui, [], handles);
handles = guidata(handles.model_gui); % Necessary since struct is a value class
%modelGet2_btn_Callback(hObject, [], handles);
modelGet2_btn_Callback(handles.model_gui, [], handles);
handles = guidata(handles.model_gui);
guidata(handles.model_gui,handles);
 
