function varargout = THz_E_loss_scan(varargin)
% THZ_E_LOSS_SCAN M-save for THz_E_loss_scan.fig
%  The usual FEL energy-loss measurement scans the angle of the electrons
%  entering the FEL to find the change in the energy at the dump due to
%  lasing. This program modifies the idea by leaving the FEL alone but
%  instead inserting and removing the terahertz foil several times, to
%  measure the energy loss due to the foil. Only a small fraction of this
%  loss is due to electron scattering in the thin foil; instead, most is
%  due to THz radiation. Half of that is forward radiation, as electrons
%  exit the foil; this is not collected or used. The other half is the
%  radiation emitted on entry and sent down to the THz table.

% Last Modified by GUIDE v2.5 30-Sep-2011 16:26:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @THz_E_loss_scan_OpeningFcn, ...
                   'gui_OutputFcn',  @THz_E_loss_scan_OutputFcn, ...
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
end


% --- Executes just before THz_E_loss_scan is made visible.
function THz_E_loss_scan_OpeningFcn(hObject, eventdata, handles, varargin)

global savePath loadPath
savePath = '';
loadPath = '';
handles.fakedata = 0;
%...(removed unneeded code from Paul's program)
handles.Eloss_plots = 1;
handles.output = hObject;
handles.E0 = lcaGetSmart('BEND:DMP1:400:BDES');
handles.navg = str2double(get(handles.NAVG,'String'));
handles.ncal = str2double(get(handles.NCAL,'String'));
handles.npoints = str2double(get(handles.NPOINTS,'String'));
handles.init = 0;       % have not yet initialized the ref orbit or gotten model
%...
% Reuse calibration from previous THz scan, if not too old
if now - datenum(lcaGetSmart('SIOC:SYS0:ML00:AO724TS')) < 1
    handles.mean_Ipk0   = lcaGetSmart('SIOC:SYS0:ML00:AO723');
    handles.elossperamp = lcaGetSmart('SIOC:SYS0:ML00:AO724');
else
    handles.mean_Ipk0   = lcaGetSmart('PHYS:SYS0:1:ELOSSIPK');
    handles.elossperamp = lcaGetSmart('PHYS:SYS0:1:ELOSSPERIPK');
    lcaPutSmart('SIOC:SYS0:ML00:AO723',handles.mean_Ipk0);
    lcaPutSmart('SIOC:SYS0:ML00:AO724',handles.elossperamp);
end
set(handles.IPK0,'String',handles.mean_Ipk0)
handles.have_Eloss = 0;
handles.have_calibration = 0;
%...
set(handles.ELOSSPERAMP,'String',sprintf('%6.4f',handles.elossperamp));
%...
guidata(hObject, handles);
% UIWAIT makes THz_E_loss_scan wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = THz_E_loss_scan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% ------------------------------------------------------------------------
% function data = appRemote(hObject)
% 
% %init=~any(strcmp(get(util_appFind,'Name'),'THz_E_loss_scan'));
% [hObject,handles]=util_appFind('THz_E_loss_scan');
% init=1;
% 
% if init
%     CALIBRATE_Callback(handles.CALIBRATE,[],handles);
%     handles=guidata(hObject);
% end
% set(handles.START,'Value',1);
% START_Callback(handles.START,[],handles);
% handles=guidata(hObject);
% data.energy=handles.xray_energy;
% data.energyStd=handles.dEloss*handles.charge;
% % Set PVs to zero if they were not updated before
% if ~(handles.dEloss < abs(handles.Eloss) && abs(handles.Eloss)<100)
%     lcaPutSmart('PHYS:SYS0:1:ELOSSRESULT',0);
%     lcaPutSmart('PHYS:SYS0:1:ELOSSNPHOTONS',0);
%     lcaPutSmart('PHYS:SYS0:1:ELOSSENERGY',0);
% end
% end



% --- Executes when user attempts to close E_loss_scan_gui.
function THz_E_loss_scan_CloseRequestFcn(hObject, eventdata, handles)
util_appClose(hObject);
end



%------------------------------------------------------
function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
guidata(hObject,handles);
end


function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function NPOINTS_Callback(hObject, eventdata, handles)
handles.npoints = str2double(get(hObject,'String'));
guidata(hObject,handles);
end


function NPOINTS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)
gui_acquireAbortAll;
end



function ELOSSPERAMP_Callback(hObject, eventdata, handles)
handles.elossperamp = str2double(get(hObject,'String'));
if ~handles.fakedata
    lcaPutSmart('SIOC:SYS0:ML00:AO724',handles.elossperamp);
end
guidata(hObject,handles);
end


function ELOSSPERAMP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function NCAL_Callback(hObject, eventdata, handles)
handles.ncal = str2double(get(hObject,'String'));
guidata(hObject,handles);
end


function NCAL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function display_message(handles,msgstr)
disp(msgstr)
set(handles.MSG,'String',msgstr)
drawnow
end



function REPLOT_Callback(hObject, eventdata, handles)
if handles.have_Eloss
    handles.Eloss_plots = 1;
    plot_Eloss(0,hObject,handles);
    guidata(hObject,handles);
end
end



function ELOG_Callback(hObject, eventdata, handles)
if handles.have_Eloss
    plot_Eloss(1,hObject,handles);
    util_printLog(1);
    % dataSave(hObject,handles,0);
end
end



function ELOG_CAL_Callback(hObject, eventdata, handles)
if handles.have_calibration
    plot_calibration(1,hObject,handles);
    util_printLog(1);
    % dataSave(hObject,handles,0);
end
end



function CALIBRATE_Callback(hObject, eventdata, handles)
%lcaPutSmart('SIOC:SYS0:ML00:CALC126', 1);  %Stop Energy Change beam-pulse accounting counter
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN')
    display_message(handles,'TDUND is IN - calibration aborted.')
    warndlg('TDUND is IN - no beam - calibration aborted.','Stopper is IN')
    if ~handles.fakedata
        return
    end
end
set(hObject,'BackgroundColor','white')
drawnow
%...
if handles.init==0	% if we have not yet initialized the ref orbit or gotten the model...
    IN_struc.initialize = 1;
    IN_struc.navg = 1;
    IN_struc.Loss_per_Ipk = 0;
    handles.dEj  = zeros(size(1,handles.ncal));
    handles.Ipkj = zeros(size(1,handles.ncal));
    set(hObject,'String','init...')
    drawnow
    OUT_struc = DL2toDumpEnergyLoss(IN_struc);
end
handles.init = 1;

IN_struc.initialize = 0;
IN_struc.navg = 1;
IN_struc.Loss_per_Ipk = 0;
handles.dEj  = zeros(size(1,handles.ncal));
handles.Ipkj = zeros(size(1,handles.ncal));
for jj = 1:handles.ncal
    set(hObject,'String',sprintf('%2.0f...',jj))
    OUT_struc = DL2toDumpEnergyLoss(IN_struc);
    handles.dEj(jj)  = OUT_struc.dE;
%   handles.ddEj(jj) = OUT_struc.ddE;
    handles.Ipkj(jj) = OUT_struc.Ipk;
end
handles = plot_calibration(0,hObject,handles);
handles.have_calibration = 1;
handles.have_Eloss = 0;
handles.time = datevec(now);
%...
set(hObject,'BackgroundColor',[255 180 0]/255)
set(hObject,'Value',0,'String','Calibrate')
drawnow
yn = questdlg(sprintf(['Old slope is %7.4f and new slope is %7.4f MeV/A. ',...
    'Do you want to update the slope?'],handles.elossperamp,handles.slope),...
    'UPDATE CALIBRATION?');
if strcmp(yn,'Yes')
    if ~handles.fakedata
        lcaPutSmart('SIOC:SYS0:ML00:AO723',handles.mean_Ipk0);
        lcaPutSmart('SIOC:SYS0:ML00:AO724',handles.slope);
        set(handles.IPK0,'String',handles.mean_Ipk0)
    end
    handles.elossperamp = handles.slope;
    set(handles.ELOSSPERAMP,'String',sprintf('%6.4f',handles.elossperamp));
end
display_message(handles,'Calibration done')
guidata(hObject,handles);
end



function handles = plot_calibration(Elog_fig,hObject,handles)
if Elog_fig
    figure(Elog_fig)
    ax1 = subplot(1,1,1);
else
    ax1 = handles.AXES1;
end
axes(ax1)
plot(handles.Ipkj,handles.dEj,'dg','MarkerFaceColor','green','MarkerSize',5)
[q,dq,xf,yf,chisq,V] = plot_polyfit(handles.Ipkj,handles.dEj,1,1,'','','','',1);
handles.slope  =  q(2);
handles.dslope = dq(2);
handles.mean_Ipk0 = mean(handles.Ipkj);
xx = linspace(min(handles.Ipkj),max(handles.Ipkj),100);
xxs = sort(xx);
yy = q(1) + handles.slope*xxs;
hold on
plot(xx,yy,'-b','LineWidth',2);
ver_line(handles.mean_Ipk0,'c:')
xlabel('BC2 Peak Current (A)',  'FontSize',14)
ylabel('Wake Energy Loss (MeV)','FontSize',14)
title([sprintf('slope=%5.2e+-%4.2e MeV/A, ',handles.slope,handles.dslope),...
       sprintf('%d-%02d-%02d %02d:%02d:%02d',...
           handles.time(1),handles.time(2),handles.time(3),...
           handles.time(4),handles.time(5),round(handles.time(6))),...
       sprintf(' (%5.2f GeV)',handles.E0)],'FontSize',14)
% enhance_plot('times',16,2,5)
hold off
end



% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global savePath
set(handles.MSG,'String','')
dateVector = datevec(now);
savePath = sprintf('/u1/lcls/matlab/THz/%d/%d-%02d/%d-%02d-%02d/',...
            dateVector(1),dateVector(1),dateVector(2),...
            dateVector(1),dateVector(2),dateVector(3));
fileName = sprintf('lclsELoss-%d%02d%02d-%02d%02d%02d.txt',...
            dateVector(1),dateVector(2),dateVector(3),...
            dateVector(4),dateVector(5),round(dateVector(6)));
mkdirStatus = mkdir(savePath);
if mkdirStatus == 1
    try
        [fileName,savePath] = uiputfile('*.txt','Save File As',...
            [savePath,fileName]);
        if isequal(fileName,0) || isequal(savePath,0)
            set(handles.MSG,'String','Save canceled by user.')
        else
            data = [handles.npoints, 0;...
                    handles.charge,  0;
                    handles.E0,      0];
            data = vertcat(data,[handles.dE',handles.ddE']);
            save([savePath,fileName],'data','-ascii','-double','-tabs')
            set(handles.MSG,'String','File saved.')
        end
    catch
        set(handles.MSG,'String',...
            'Error in opening file diaglog. Please try again.')
    end
end
end



% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global savePath loadPath
set(handles.MSG,'String','')

if isempty(loadPath)
    if isempty(savePath)
        dateVector = datevec(now);
        loadPath = sprintf('/u1/lcls/matlab/THz/%d/%d-%02d/',...
                   dateVector(1),dateVector(1),dateVector(2));
    else
        loadPath = savePath;
    end
end

mkdirStatus = mkdir(loadPath);
if mkdirStatus == 1
    try
        [fileName,path] = ...
            uigetfile('lclsELoss-*.txt','Reload Data File',loadPath);
        if isequal(fileName,0) || isequal(path,0)
            set(handles.MSG,'String','Save canceled by user.')
        elseif ~isequal(fileName(1:9),'lclsELoss')
            set(handles.MSG,'String','Choose only an E-Loss scan.')
        else
            loadPath = path;
            data = load([loadPath,fileName],'-ascii');
            r = size(data,1);
            handles.npoints = data(1,1);
            handles.charge  = data(2,1);
            handles.E0      = data(3,1);
            handles.dE      = data(4:r,1);
            handles.ddE     = data(4:r,2);
            dash = strfind(fileName,'-');
            if length(dash) == 2 && dash(2)-dash(1) == 9
                handles.time(1) = str2double(fileName(dash(1)+1:dash(1)+4));
                handles.time(2) = str2double(fileName(dash(1)+5:dash(1)+6));
                handles.time(3) = str2double(fileName(dash(1)+7:dash(1)+8));
                handles.time(4) = str2double(fileName(dash(2)+1:dash(2)+2));
                handles.time(5) = str2double(fileName(dash(2)+3:dash(2)+4));
                handles.time(6) = str2double(fileName(dash(2)+5:dash(2)+6));
            else
                handles.time = [2011 1 1 0 0 0];
            end
            set(handles.MSG,'String','File reloaded.')
            handles = plot_Eloss(0,hObject,handles);
            handles.have_Eloss = 1;
            guidata(hObject,handles);
        end
    catch ME
        set(handles.MSG,'String',...
            ['Error while opening file: ',ME.message])
    end
end
end



% -----------------------------------------------------------
% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)

% set(hObject,'Value',~get(hObject,'Value'));
% if gui_acquireStatusSet(hObject,handles,1)
%     return
% end

TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN')
    display_message(handles,'TDUND is IN - scan aborted.')
    warndlg('TDUND is IN - no beam - scan aborted.','Stopper is IN')
    if ~handles.fakedata
        return
    end
end

set(hObject,'BackgroundColor','white')
set(hObject,'String','Init...')
drawnow
%...
handles.E0 = lcaGetSmart('BEND:DMP1:400:BDES');
%...
IN_struc.initialize = 1;
IN_struc.navg = 1;
loss_per_Ipk      = lcaGetSmart('SIOC:SYS0:ML00:AO724');
handles.mean_Ipk0 = lcaGetSmart('SIOC:SYS0:ML00:AO723');
IN_struc.Loss_per_Ipk = loss_per_Ipk;
OUT_struc = DL2toDumpEnergyLoss(IN_struc);
dE0 = OUT_struc.dE;
handles.init = 1; % Remember that we've initialized the ref orbit and gotten the model

IN_struc.initialize = 0;
IN_struc.navg = 1;
%...
TMIT        = zeros(1,handles.npoints);
handles.dE  = zeros(1,handles.npoints);
handles.ddE = zeros(1,handles.npoints);
handles.Ipk = zeros(1,handles.npoints);
dEj   = zeros(1,handles.navg);
TMITj = zeros(1,handles.navg);
Ipkj  = zeros(1,handles.navg);
valid = zeros(1,handles.navg);
%...
display_message(handles,'Starting scan...')
handles.time = datevec(now);
rate = max(1,lcaGetSmart('IOC:IN20:MC01:LCLSBEAMRATE'));   % rep rate [Hz]
pauseTime = 1/rate;

% Check foil status by reading THZR:DMP1:350:IN_LMTSW and OUT_LMTSW
% Get the initial position of the foil, and restore it after the scan.
switches   = {'THZR:DMP1:350:IN_LMTSW';'THZR:DMP1:350:OUT_LMTSW'};
limits     = lcaGetSmart(switches);
foilBefore = double(strcmp(limits{1},'Active') && strcmp(limits{2},'Inactive'));
OutIn = {'OUT','IN'};
% Move foil in by setting THZR:DMP1:350:PNEUMATIC
% Start the scan with the foil in, and alternate for each point.

for j = 1:handles.npoints
    %...
    foilPosition = mod(j,2);	% Foil out = 0, foil in = 1
    if ~handles.fakedata
        %...
        lcaPutSmart('THZR:DMP1:350:PNEUMATIC',foilPosition);
        moving = 1;
        while moving
            pause(1)
            limits = lcaGetSmart(switches);
            moving = all(strcmp(limits,'Inactive'));
        end
        pause(1)    % Wait for beam to come back
    end
    set(hObject,'String',['Foil ',OutIn{foilPosition+1}])
    drawnow
    %...
    for jj = 1:handles.navg
        if ~handles.fakedata
            pause(pauseTime)
            OUT_struc = DL2toDumpEnergyLoss(IN_struc);
            dEj(jj)   = OUT_struc.dE - dE0;
            Ipkj(jj)  = OUT_struc.Ipk;
            valid(jj) = OUT_struc.valid;
            TMITj(jj) = lcaGetSmart('BPMS:IN20:221:TMIT')*1.602E-10; % nC
            %...
        else
            dEj(jj)   = mod(j,2) + 0.3*randn;	% Fake energy loss [MeV]
            Ipkj(jj)  = 1000 * 0.1*randn;       % Fake peak currenvart [A]
            valid(jj) = 1;
            TMITj(jj) = 0.25 + 0.005*randn;     % Fake charge [nC]
            %...
        end
        if ~gui_acquireStatusGet(hObject,handles)
            break
        end
    end
    %...
    n_valid = sum(valid);
    valids  = find(valid);
    TMIT(j)        = mean(TMITj(valids));
    handles.dE(j)  = mean(dEj(valids));
    handles.Ipk(j) = mean(Ipkj(valids));
    %...  
    if n_valid <= 1
        handles.ddE(j) = 0;
    else
        handles.ddE(j) = std(dEj(valids))/sqrt(n_valid-1);
    end
    %...
    s1 = [' ',num2str(j)];
    s1 = s1(length(s1)-1:length(s1));
    s2 = [OutIn{foilPosition+1},'.  '];
    s2 = s2(1:5);
    display_message(handles,[s1,'.  Foil is ',s2,'Energy = ',...
        num2str(handles.dE(j),'%+6.3f'),' +- ',...
        num2str(handles.ddE(j),'%5.3f'),' MeV'])
    iTMIT = find(TMIT > 0.005); % H. Loos, 04/03/2010
    if ~isempty(iTMIT)
        handles.charge = mean(TMIT(iTMIT));
    else
        handles.charge = 0;
    end
    handles = plot_Eloss(0,hObject,handles);
    i = find(handles.Ipk);
    if ~isempty(i)
        handles.mean_Ipk = mean(handles.Ipk(i));
    else
        handles.mean_Ipk = 0;
    end
%     if ~gui_acquireStatusGet(hObject,handles)
%         break
%     end
end
%...
if ~handles.fakedata
    %...
    lcaPutSmart('THZR:DMP1:350:PNEUMATIC',foilBefore);
    pause(0.5)
end
%...
display_message(handles,['Finished. Foil is ',OutIn{foilBefore+1},'.'])
set(hObject,'BackgroundColor','green')
set(hObject,'Value',0,'String','Start Scan')
%...
drawnow
handles.have_Eloss = 1;
handles.have_calibration = 0;
if abs(handles.mean_Ipk - handles.mean_Ipk0) > 500 && ~handles.fakedata
    helpdlg(sprintf(['The mean peak current is ',num2str(handles.mean_Ipk),...
        ' A.\nThe last calibration current was for ',num2str(handles.mean_Ipk0),...
        ' A.\nA new calibration might improve the data quality.']),'')
end
% gui_acquireStatusSet(hObject,handles,0);
guidata(hObject,handles);
end



function handles = plot_Eloss(Elog_fig,hObject,handles)
% handles.Eloss_plots = 1;
if Elog_fig
    figure(Elog_fig)
    ax1 = subplot(1,1,1);
else
    ax1 = handles.AXES1;
end
axes(ax1)
cla(ax1,'reset')
iOK  = intersect(find(handles.dE),find(~isnan(handles.dE)));
odd  = intersect(iOK,1:2:handles.npoints);
even = intersect(iOK,2:2:handles.npoints);
full = 1:handles.npoints;
%...
if isempty(iOK(odd)) || isempty(iOK(even))
    return
end
if any(handles.ddE(iOK)==0)
    ddE_exists = 0;
    ddE = ones(1,handles.npoints);
else
    ddE_exists = 1;
    ddE = handles.ddE;
end
weight   = ddE.^(-2);
oddMean  = sum(handles.dE(odd) .*weight(odd)) /sum(weight(odd));
evenMean = sum(handles.dE(even).*weight(even))/sum(weight(even));
% Get errors in oddMean and evenMean
if length(odd) == 1
    oddMeanErr  = ddE(odd(1));
else
    oddMeanErr  = 1/sqrt(sum(weight(odd)));
    %sqrt(var(handles.dE(odd),weight(odd))/length(odd));
end
if length(even) == 1
    evenMeanErr = ddE(even(1));
else
    evenMeanErr = 1/sqrt(sum(weight(even)));
    %sqrt(var(handles.dE(even),weight(even))/length(even));
end
diffMean = oddMean - evenMean;
diffMeanErr  = sqrt(oddMeanErr^2 + evenMeanErr^2);
handles.THz_energy = diffMean*handles.charge;
if ddE_exists
    errorbar(odd, handles.dE(odd), ddE(odd), 'or')
    hold on
    errorbar(even,handles.dE(even),ddE(even),'^b')
    text(1,evenMean+diffMean*0.6,sprintf('%6.3f + - %5.3f MeV per electron',...
        diffMean,diffMeanErr),'FontSize',14)
    text(1,evenMean+diffMean*0.4,sprintf('%6.3f + - %5.3f mJ for %3.0f pC',...
          [diffMean,diffMeanErr,1000]*handles.charge),'FontSize',14)
else
    plot(odd, handles.dE(odd), 'or')
    hold on
    plot(even,handles.dE(even),'^b')
    text(1,evenMean+diffMean*0.6,sprintf('%6.3f MeV per electron',...
        diffMean),'FontSize',14)
    text(1,evenMean+diffMean*0.4,sprintf('%6.3f mJ for %3.0f pC',...
          [diffMean,1000]*handles.charge),'FontSize',14)
end
plot(full,evenMean*ones(handles.npoints,1),'b',...
     full,oddMean *ones(handles.npoints,1),'r')
hold off
handles.offs = evenMean;
title(['Energy Loss Scan   ',...
        sprintf('%d-%02d-%02d %02d:%02d:%02d',...
            handles.time(1),handles.time(2),handles.time(3),...
            handles.time(4),handles.time(5),round(handles.time(6))),...
        sprintf('   %5.2f GeV',handles.E0)],'FontSize',14)
xlim([0,handles.npoints+1])
set(ax1,'FontSize',14)
text(0.5,oddMean  - 0.2 *diffMean,'Foil In' ,'Color','r','FontSize',14)
text(0.5,evenMean + 0.15*diffMean,'Foil Out','Color','b','FontSize',14)
xlabel('Measurement Sequence','FontSize',14)
ylabel('Energy Loss [MeV]','FontSize',14)
handles.Eloss  = diffMean;
handles.dEloss = diffMeanErr;
guidata(hObject,handles);
% if ~Elog_fig
%   handles.plot_scale = axis;    % E-log call uses original scale set when first plotted
% else
%   axis(handles.plot_scale)
% end
%...
end
