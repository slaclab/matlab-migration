function varargout = dispersionLive(varargin)
% DISPERSIONLIVE MATLAB code for dispersionLive.fig
%      DISPERSIONLIVE, by itself, creates a new DISPERSIONLIVE or raises the existing
%      singleton*.
%
%      H = DISPERSIONLIVE returns the handle to a new DISPERSIONLIVE or the handle to
%      the existing singleton*.
%
%      DISPERSIONLIVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPERSIONLIVE.M with the given input arguments.
%
%      DISPERSIONLIVE('Property','Value',...) creates a new DISPERSIONLIVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dispersionLive_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dispersionLive_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dispersionLive

% Last Modified by GUIDE v2.5 18-Aug-2020 00:55:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dispersionLive_OpeningFcn, ...
                   'gui_OutputFcn',  @dispersionLive_OutputFcn, ...
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


% --- Executes just before dispersionLive is made visible.
function dispersionLive_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dispersionLive (see VARARGIN)

% Choose default command line output for dispersionLive
handles.output = hObject;

% I got your appInit right here, buddy...

% LCLS beamline/region definitions
handles.area(1).name = 'L2'; % Human-readable name for region
handles.area(1).region = {'LI21:277:Inf','LI22','LI23','LI24:1:702'};% Devices included in region
handles.area(1).refbpm = 'BPMS11'; % nearest upstream, dispersive BPM
handles.area(1).refplane = 1; %1 = x, 2 = y
handles.area(1).beampath = 'CU_HXR';
handles.area(1).edef = 'BR';

handles.area(2).name = 'L3';
handles.area(2).region = {'LI24:900:Inf','LI25','LI26','LI27','LI28','LI29','LI30'}; % neglect BSY, not reg. lattice
handles.area(2).refbpm = 'BPMS21';
handles.area(2).refplane = 1; %1 = x, 2 = y
handles.area(2).beampath = 'CU_HXR';
handles.area(2).edef = 'BR';

handles.area(3).name = 'LTUH';
handles.area(3).region = {'LTUH:491:Inf'};
handles.area(3).refbpm = 'BPMDL1';
handles.area(3).refplane = 1; %1 = x, 2 = y
handles.area(3).beampath = 'CU_HXR';
handles.area(3).edef = 'CUHBR';

handles.area(4).name = 'UNDH';
handles.area(4).region = {'UNDH:1:5100'};
handles.area(4).refbpm = 'BPMDL1';
handles.area(4).refplane = 1; %1 = x, 2 = y
handles.area(4).beampath = 'CU_HXR';
handles.area(4).edef = 'CUHBR';

handles.area(5).name = 'CLTS';
handles.area(5).region = {'CLTS:865:Inf' 'BSYS:10:Inf' 'LTUS:10:151'};
handles.area(5).refbpm = 'BPMCUS8';
handles.area(5).refplane = 2; %1 = x, 2 = y
handles.area(5).beampath = 'CU_SXR';
handles.area(5).edef = 'CUSBR';

handles.area(6).name = 'LTUS';
handles.area(6).region = {'LTUS:461:Inf'};
handles.area(6).refbpm = 'BPMDL17';
handles.area(6).refplane = 1; %1 = x, 2 = y
handles.area(6).beampath = 'CU_SXR';
handles.area(6).edef = 'CUSBR';

handles.area(7).name = 'UNDS';
handles.area(7).region = {'UNDS:1:5100'};
handles.area(7).refbpm = 'BPMDL17';
handles.area(7).refplane = 1; %1 = x, 2 = y
handles.area(7).beampath = 'CU_SXR';
handles.area(7).edef = 'CUSBR';

set(handles.popupRegion,'string',{handles.area.name}.');
% Fetch names/properties
model_init;
for k=1:length(handles.area)
    handles.area(k).refbpm = model_nameConvert(handles.area(k).refbpm);
    names = model_nameRegion('BPMS',handles.area(k).region);
    if strcmp(handles.area(k).name,'LTUS')
        names = setdiff(names,...
            ['BPMS:LTUS:550';'BPMS:LTUS:720';'BPMS:LTUS:730';...
            'BPMS:LTUS:760';'BPMS:LTUS:780']);
    end %  deferred BPMs
    [~,z] = model_rMatGet(names,'',{['BEAMPATH=' ...
        handles.area(k).beampath]},'z');
    [handles.area(k).z,ind] = sort(z);
    handles.area(k).bpms = names(ind);
    handles.area(k).etax = zeros(1,numel(handles.area(k).bpms));
    handles.area(k).etay = zeros(1,numel(handles.area(k).bpms));
    handles.area(k).etaxref = zeros(1,numel(handles.area(k).bpms));
    handles.area(k).etayref = zeros(1,numel(handles.area(k).bpms));
    props = model_rMatGet(handles.area(k).refbpm,[],['BEAMPATH=' ...
        handles.area(k).beampath],'twiss');
    handles.area(k).refeta = ...
        props(5*handles.area(k).refplane)*1e3; % dispersion (mm)
    if ismember(k,[5,6])
        handles.area(k).refeta = 425;
    end % Temporary, getting strange DL2B dispersion
    handles.area(k).etaxhist = zeros(1,500);
    handles.area(k).etayhist = zeros(1,500);
    handles.area(k).ts = 0;
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dispersionLive wait for user response (see UIRESUME)
% uiwait(handles.dispersionLive);


% --- Outputs from this function are returned to the command line.
function varargout = dispersionLive_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushAcqStart.
function pushAcqStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushAcqStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushAcqStart
v = get(handles.pushAcqStart,'value');
if v
    set(handles.pushAcqStart,'BackgroundColor',[1 0 0],'String','Stop Acq.')
    set(handles.popupRegion,'enable','off')
    set(handles.pushLoad,'enable','off')
    %set(handles.pushClear,'enable','off')
    try
        regSel = get(handles.popupRegion,'value');
        while get(handles.pushAcqStart,'value');
            handles = guidata(hObject);
            handles = updateArea(handles,regSel);
            guidata(hObject,handles);
            updatePlots(handles,regSel);
            drawnow
            pause(0.01)
        end
    catch ex
        set(handles.pushAcqStart,'value',0);
        set(handles.pushAcqStart,'BackgroundColor',[0 1 0],'String','Start Acq.')
        set(handles.popupRegion,'enable','on')
        set(handles.pushLoad,'enable','on')
        %set(handles.pushClear,'enable','on')
        rethrow(ex)
    end
else
    set(handles.pushAcqStart,'BackgroundColor',[0 1 0],'String','Start Acq.')
    set(handles.popupRegion,'enable','on')
    set(handles.pushLoad,'enable','on')
    %set(handles.pushClear,'enable','on')
end

function handles = updateArea(handles,regSel)
Nget = 2800; % get whole buffer so we can get mose recent data.
Nmin = 2000; % Minimum required to be used
Nuse = 300; % only work off of last Nuse points
etamaxmax = 500; % (mm) if max eta is larger than this, call it a glitch
Nbpms = numel(handles.area(regSel).bpms);
Qthresh = 1e7; % tmit threshhold
pl = {':X';':Y'};
pvs = [strcat(handles.area(regSel).refbpm,pl{handles.area(regSel).refplane});...
    strcat(handles.area(regSel).refbpm,':TMIT');...
    strcat(handles.area(regSel).bpms,':X');...
    strcat(handles.area(regSel).bpms,':Y');...
    strcat(handles.area(regSel).bpms,':TMIT')];
[data,ts,ispv] = lcaGetSyncHST(pvs,2800,handles.area(regSel).edef);
ts = lca2matlabTime(ts(end));
if isempty(data) || size(data,2) < Nmin
    disp('No data / not enough data acquired! Loop skipped.')
    return
end
if ~ispv(1)
    disp('Where''s the reference BPM...?')
    return
end
% use most recent data
data = data(:,(end-Nuse+1):end);
% filter on incoming ref tmit
data(:,isnan(data(1,:))) = [];
data(:,isnan(data(2,:))) = [];
data(:,data(2,:)<Qthresh) = [];
% is the beam even getting there?
if isempty(data) || size(data,2) < 20
    disp(['No beam at ' handles.area(regSel).name '? Loop skipped']);
    return
end
del = data(1,:)/handles.area(regSel).refeta;
x = data((1:Nbpms)+2,:);
y = data((1:Nbpms)+2+Nbpms,:);
tmit = data((1:Nbpms)+2+2*Nbpms,:);
eta = zeros(size(x));
for k = 1:Nbpms
    if ~ispv(k+1) | ~ispv(k+2+Nbpms)
        etax(k) = 0;
        etay(k) = 0;
        continue
    end
    use = (~isnan(x(k,:)) & tmit(k,:) > Qthresh) & ~isnan(tmit(k,:));
    if sum(use) < 20
        etax(k) = 0;
    else
        p = polyfit(del(use),x(k,use),1);
        etax(k) = p(1);
    end
    use = (~isnan(y(k,:)) & tmit(k,:) > Qthresh) & ~isnan(tmit(k,:));
    if sum(use) < 20
        etay(k) = 0;
    else
        p = polyfit(del(use),y(k,use),1);
        etay(k) = p(1);
    end
end
handles.area(regSel).ts = ts;
handles.area(regSel).etax = etax;
handles.area(regSel).etay = etay;
eta = max(abs(etax));
if eta > etamaxmax,eta = 0;end
handles.area(regSel).etaxhist = circshift(handles.area(regSel).etaxhist,[0,-1]);
handles.area(regSel).etaxhist(end) = eta;
eta = max(abs(etay));
if eta > etamaxmax,eta = 0;end
handles.area(regSel).etayhist = circshift(handles.area(regSel).etayhist,[0,-1]);
handles.area(regSel).etayhist(end) = eta;

function updatePlots(handles,regSel,ax)
if nargin < 3
    ax = [handles.axesDisp, handles.axesHist];
    dotitle = false;
else
    dotitle = true;
end
Navg = 10; % number of points for averaging
flt = ones(1,Navg)/Navg; % our filter...
yl = ylim(ax(1));
plot(ax(1),handles.area(regSel).z,handles.area(regSel).etax,'-b','linewidth',2)
hold(ax(1),'on')
plot(ax(1),handles.area(regSel).z,handles.area(regSel).etay,'-r','linewidth',2)
plot(ax(1),handles.area(regSel).z,handles.area(regSel).etaxref,'--b')
plot(ax(1),handles.area(regSel).z,handles.area(regSel).etayref,'--r')
plot(ax(1),xlim(ax(1)),[0 0],'--k')
hold(ax(1),'off')
xlim(ax(1),[min(handles.area(regSel).z),...
    max(handles.area(regSel).z)]);
if get(handles.checkLockDisp,'value')
    if ~dotitle
        ylim(ax(1),yl);
    else
        ylim(ax(1),ylim(handles.axesDisp));
    end
end
if dotitle,title(ax(1),[handles.area(regSel).name ' Jitter Dispersion, ' ...
        datestr(handles.area(regSel).ts,'dd-mmm-yyyy HH:MM:SS')]);end
xlabel(ax(1),'{\itz} (m)');
ylabel(ax(1),'\eta (mm)');

yl = ylim(ax(2));
plot(ax(2),handles.area(regSel).etaxhist,'--b','markersize',2)
hold(ax(2),'on')
plot(ax(2),handles.area(regSel).etayhist,'--r','markersize',2)
plot(ax(2),filter(flt,1,handles.area(regSel).etaxhist),'-b','linewidth',2)
plot(ax(2),filter(flt,1,handles.area(regSel).etayhist),'-r','linewidth',2)
hold(ax(2),'off')
xlim(ax(2),[0 numel(handles.area(regSel).etaxhist)]);
if get(handles.checkLockHist,'value')
    if ~dotitle
        ylim(ax(2),yl);
    else
        ylim(ax(2),ylim(handles.axesHist));
    end
end
xlabel(ax(2),'Shot #');
ylabel(ax(2),'\eta_{max} (mm)');
legend(ax(2),'X','Y','location','northwest')
    

% --- Executes during object creation, after setting all properties.
function pushAcqStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushAcqStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupRegion.
function popupRegion_Callback(hObject, eventdata, handles)
% hObject    handle to popupRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupRegion contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupRegion
regSel = get(handles.popupRegion,'value');
updatePlots(handles,regSel);

% --- Executes during object creation, after setting all properties.
function popupRegion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushMakeRef.
function pushMakeRef_Callback(hObject, eventdata, handles)
% hObject    handle to pushMakeRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regSel = get(handles.popupRegion,'value');
handles.area(regSel).etaxref = handles.area(regSel).etax;
handles.area(regSel).etayref = handles.area(regSel).etay;
guidata(hObject,handles);
updatePlots(handles,regSel);


% --- Executes on button press in pushLogBook.
function pushLogBook_Callback(hObject, eventdata, handles)
% hObject    handle to pushLogBook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regSel = get(handles.popupRegion,'value');
if handles.area(regSel).ts == 0,return;end
f = figure('color','w');
ax=[subplot(2,1,1),subplot(2,1,2)];
updatePlots(handles,regSel,ax);
data.area = handles.area;
data.regSel = regSel;
util_dataSave(data,'EtaLive','',handles.area(regSel).ts);
util_printLog(f,'title',[handles.area(regSel).name ' Jitter Dispersion'])


% --- Executes when user attempts to close dispersionLive.
function dispersionLive_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to dispersionLive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

util_appClose(hObject);



% --- Executes on button press in pushExport.
function pushExport_Callback(hObject, eventdata, handles)
% hObject    handle to pushExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regSel = get(handles.popupRegion,'value');
if handles.area(regSel).ts == 0,return;end
figure('color','w');
ax=[subplot(2,1,1),subplot(2,1,2)];
updatePlots(handles,regSel,ax);


% --- Executes on button press in pushLoad.
function pushLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = util_dataLoad('Dispersion Live',0,'EtaLive-*.mat');
if ~isfield(data,'area')
    errordlg('No data found in file!','Dispersion Live');
    return
end
handles.area = data.area;
set(handles.popupRegion,'value',data.regSel);
updatePlots(handles,regSel);


% --- Executes on button press in checkLockDisp.
function checkLockDisp_Callback(hObject, eventdata, handles)
% hObject    handle to checkLockDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLockDisp


% --- Executes on button press in checkLockHist.
function checkLockHist_Callback(hObject, eventdata, handles)
% hObject    handle to checkLockHist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLockHist


% --- Executes on button press in pushClear.
function pushClear_Callback(hObject, eventdata, handles)
% hObject    handle to pushClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.popupRegion,'value');
handles.area(k).etax = zeros(1,numel(handles.area(k).bpms));
handles.area(k).etay = zeros(1,numel(handles.area(k).bpms));
% Hmm. Maybe you don't want to lose the reference. And if you do, you can
% make zero the reference after clearing the data.
%handles.area(k).etaxref = zeros(1,numel(handles.area(k).bpms));
%handles.area(k).etayref = zeros(1,numel(handles.area(k).bpms));
handles.area(k).etaxhist = zeros(1,500);
handles.area(k).etayhist = zeros(1,500);
handles.area(k).ts = 0;
updatePlots(handles,k);
guidata(hObject,handles);
