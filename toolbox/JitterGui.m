function varargout = JitterGui(varargin)
% JITTERGUI M-file for JitterGui.fig
%      JITTERGUI, by itself, creates a new JITTERGUI or raises the existing
%      singleton*.
%
%      H = JITTERGUI returns the handle to a new JITTERGUI or the handle to
%      the existing singleton*.
%
%      JITTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JITTERGUI.M with the given input arguments.
%
%      JITTERGUI('Property','Value',...) creates a new JITTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JitterGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JitterGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE'JitterGui Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JitterGui

% Last Modified by GUIDE v2.5 16-Dec-2008 13:34:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JitterGui_OpeningFcn, ...
                   'gui_OutputFcn',  @JitterGui_OutputFcn, ...
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




% --- Executes just before JitterGui is made visible.
function JitterGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JitterGui (see VARARGIN)

% Choose default command line output for JitterGui
handles.output = hObject;


% Read in default values
handles.numavg = str2double(get(handles.NUMAVG,'String'));
handles.wait = str2double(get(handles.WAIT,'String'));
handles.abort = 0;
handles.LogE = get(handles.LOGE,'Value');
handles.LogInj = get(handles.LOGINJ,'Value');
handles.Log28Und = get(handles.LOG28,'Value');


handles.DLGood = .06;
handles.BC1Good = .12;
handles.BC2Good = .2;
handles.BSYGood = .06;
handles.TRMSGood = 3;
handles.XUVLasGood = 5;
handles.YUVLasGood = 5;
handles.UVLasPowGood = 4;
handles.XIRLasGood = 15;
handles.YIRLasGood = 15;
handles.IRLasPowGood = 4;
handles.XInjGood = 6;
handles.YInjGood = 6;
handles.LBC1Good = 10;
handles.X28UndGood = 20;
handles.Y28UndGood = 12;
handles.LBC2Good = 15;

handles.statusLTU = 0;
handles.statusUnd = 0;

% Color order for energy plot
TempColorOrder = get(gca,'ColorOrder');
handles.EnergyColorOrder = TempColorOrder;
handles.EnergyColorOrder(3,:) = [129 77 15]/255;
hold(handles.EHISTAX,'off');
set(gcf,'DefaultAxesColorOrder',handles.EnergyColorOrder);



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes JitterGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes when user attempts to close JitterGui.
function JitterGui2_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);




% --- Outputs from this function are returned to the command line.
function varargout = JitterGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATApushbutton4)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
% hObject    handle to START (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.START,'String','Abort');
set(hObject,'BackgroundColor',[1 1 0]);
%set(handles.START,'BackgroundColor',

% If abort called end program
handles.abort = get(hObject,'Value');
if handles.abort == 0
    return;
end


handles.exportFigT = gcf;

% Update status in GUI
set(handles.STATUS,'String','Initializing...');
drawnow

% Read in "Points per Avg" from Gui
% (navg and RunNum both used for historical reasons...)
navg = handles.numavg;
RunNum = handles.numavg;

% Energy BPMs
EBPM_pvs =            {'BPMS:IN20:221'
                       'BPMS:IN20:731'
                       'BPMS:LI21:233'
                       'BPMS:LI24:801'
                       %'BPMS:BSY0:52' 4/6/17 Sonya: comment obsolete bpm
                       'BPMS:LTU1:250'
                       'BPMS:LTU1:450'
                       %'CA11:BPMS:52'
                                        };


% Injector Jitter BPMs
XYInjBPM_pvs =        {'BPMS:IN20:771'
                       'BPMS:IN20:781'
                       'BPMS:LI21:131'
                       'BPMS:LI21:161'
                       'BPMS:LI21:201'
                       'BPMS:LI21:278'
                       'BPMS:LI21:301'
                                        };

% Sector 28 Jitter BPMs
XY28BPM_pvs =        {'BPMS:LI27:301'
                       'BPMS:LI27:401'
                       'BPMS:LI27:701'
                       'BPMS:LI27:801'
                       'BPMS:LI28:301'
                       'BPMS:LI28:401'
                       'BPMS:LI28:701'
                       'BPMS:LI28:801'
                                        };

% Undulator Jitter BPMs
XYUndBPM_pvs =        {'BPMS:UND1:190'
                       'BPMS:UND1:490'
                       'BPMS:UND1:790'
                       'BPMS:UND1:1090'
                       'BPMS:UND1:1390'
                       'BPMS:UND1:1690'
                       'BPMS:UND1:1990'
                       'BPMS:UND1:2290'
                       'BPMS:UND1:2590'
                       'BPMS:UND1:2890'
                       'BPMS:UND1:3190'
                                        };


% LTU Jitter BPMs
XYLTUBPM_pvs =        {'BPMS:LTU1:720'
                       'BPMS:LTU1:730'
                       'BPMS:LTU1:740'
                       'BPMS:LTU1:750'
                       'BPMS:LTU1:760'
                       'BPMS:LTU1:770'
                                        };




% Initialize BSY_mag as on;
BSY_mag = 2;


% Number of Energy BPMs
NE = size((EBPM_pvs),1);
NxyInj = length(XYInjBPM_pvs);
Nxy28 = length(XY28BPM_pvs);
NxyUnd = length(XYUndBPM_pvs);
NxyLTU = length(XYLTUBPM_pvs);

% Injector BPMs initialization
XsInj = zeros(RunNum,NxyInj);
YsInj = zeros(RunNum,NxyInj);
ioksInj = zeros(RunNum,NxyInj);

% Sector 28 BPMs initialization
Xs28 = zeros(RunNum,Nxy28);
Ys28 = zeros(RunNum,Nxy28);
ioks28 = zeros(RunNum,Nxy28);

% Undulator BPMs initialization
XsUnd = zeros(RunNum,NxyUnd);
YsUnd = zeros(RunNum,NxyUnd);
ioksUnd = zeros(RunNum,NxyUnd);

% LTU BPMs initialization
XsLTU = zeros(RunNum,NxyLTU);
YsLTU = zeros(RunNum,NxyLTU);
ioksLTU = zeros(RunNum,NxyLTU);


% Retrieve twiss parameters from model (for dispersion)
for j = 1:(NE)
    handles.output = hObject;
    %BPM_SLC_name = model_nameConvert(EBPM_pvs{j},'SLC');
    % handles.BPM_micrs(j,:) = BPM_SLC_name(6:9);
    % handles.BPM_units(j)   = str2int(BPM_SLC_name(11:end));
    try
      %twiss = aidaget([BPM_SLC_name ':twiss'],'doublea',{'TYPE=DATABASE'});
      requestBuilder = pvaRequest([EBPM_pvs{j} ':twiss']);
      requestBuilder.with('TYPE','DESIGN');
      requestBuilder.returning(AIDA_DOUBLE_ARRAY);
      twiss = ML(requestBuilder.get());
    catch
      disp (sprintf('pvaGet failed for %s:twiss', BPM_SLC_name));
    end
    handles.twiss(:,j) = cell2mat(twiss(1:11));
end

handles.etax  = abs(handles.twiss(5,:))*1000;       % factor of 1000 conv m to mm
handles.etax(end) = -handles.etax(end);
for i=2:size(handles.etax,2);
    if handles.etax(i) == 0
        disp('Error on aidaget for twiss values');
        return;
    end
end




% Hard code LTU dispersion value  (is this in model yet?)
%BSY_eta = 84.6158;
%handles.etax(NE-1) = 125;
%handles.etax(NE) = -125;
etax = handles.etax


% Initialize Histories.5
ERun = zeros(NE-2,RunNum);
EHist = zeros(NE-2,RunNum);
TRun = zeros(1,RunNum);
THist = zeros(1,RunNum);
LBC1Run = zeros(1,RunNum);
LBC2Run = zeros(1,RunNum);
LBC1Hist = zeros(1,RunNum);
LBC2Hist = zeros(1,RunNum);

XHistInj = zeros(1,RunNum);
YHistInj = zeros(1,RunNum);
XHist28Und = zeros(1,RunNum);
YHist28Und = zeros(1,RunNum);


XUVLasRun = zeros(1,RunNum);
YUVLasRun = zeros(1,RunNum);
UVLasPowRun = zeros(1,RunNum);
XUVLasHist = zeros(1,RunNum);
YUVLasHist = zeros(1,RunNum);
UVLasPowHist = zeros(1,RunNum);

XIRLasRun = zeros(1,RunNum);
YIRLasRun = zeros(1,RunNum);
IRLasPowRun = zeros(1,RunNum);
XIRLasHist = zeros(1,RunNum);
YIRLasHist = zeros(1,RunNum);
IRLasPowHist = zeros(1,RunNum);

% initialize counts (tracks when averaging buffer is full)
count = 0;
count28Und = 0;
countUnd = 0;
countLTU = 0;
count28 = 0;


% setup for XY jitter
JSetInj = XYJitter_Setup(XYInjBPM_pvs,NxyInj,hObject, eventdata, handles);
JSet28 = XYJitter_Setup(XY28BPM_pvs,Nxy28,hObject, eventdata, handles);
JSetUnd = XYJitter_Setup(XYUndBPM_pvs,NxyUnd,hObject, eventdata, handles);
JSetLTU = XYJitter_Setup(XYLTUBPM_pvs,NxyLTU,hObject, eventdata, handles);

% plot handles for XY jitter
JSetInj.X_AX = handles.XJITTERAX_INJ;
JSetInj.Y_AX = handles.YJITTERAX_INJ;
JSet28.X_AX = handles.XJITTERAX_28;
JSet28.Y_AX = handles.YJITTERAX_28;
JSetUnd.X_AX = handles.XJITTERAX_28;
JSetUnd.Y_AX = handles.YJITTERAX_28;
JSetLTU.X_AX = handles.XJITTERAX_28;
JSetLTU.Y_AX = handles.YJITTERAX_28;



% [Xsf,Ysf,ps,dps,uvx,uvy,dux,dvx,duy,dvy] = BPM_jitter_plots(XYBPM_pvs,N,hObject, eventdata, handles);

% Incrementor to show gui is alive
JoesInc = 0;

% Get data indefinitely
while(1)

    tic;

    % Show gui still alive
    % print out incrementor
    set(handles.INC,'String',['Inc: ',num2str(JoesInc)]);
    JoesInc = JoesInc+1

    % Make Start/Abort button flash green
    set(handles.START,'BackgroundColor',[0 1 0 ]);
    drawnow
    pause(.05);
    set(handles.START,'BackgroundColor',[1 1 0]);
    drawnow

    % If abort called end program
    handles.abort = get(hObject,'Value');
    if handles.abort == 0
        disp('User abort');
        set(handles.START,'String','Start');
        set(hObject,'BackgroundColor',[0 1 0]);
        set(handles.STATUS,'String','Ready');
        return;
    end



    %'Laser Mark'

    % Laser shape RMS (completely flat is 0)
    try
        LasRMS = lcaGetSmart('SIOC:SYS0:ML00:AO071');
    catch
        disp('Error on lcaGet for Laser RMS SIOC:SYS0:ML00:AO071')
    end

    % Laser aperture
    try
        UVLasAp = lcaGetSmart('SIOC:SYS0:ML00:AO072');
    catch
        disp('Error on lcaGet for Laser Aperture SIOC:SYS0:ML00:AO072')
    end



    % UV Laser X position
    XUVLasRun = circshift(XUVLasRun,[0,-1]);
    try
        XUVLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:186:CTRD_H');
    catch
        disp('Error on lcaGet for Laser XPos CAMR:IN20:186:CTRD_H')
    end
    % X variation relative to measured aperture diameter divided by 4
    % (approx RMS)
    XUVLasRMS = std(XUVLasRun)/(UVLasAp/4);



    % UV Laser Y Position
    YUVLasRun = circshift(YUVLasRun,[0,-1]);
    try
        YUVLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:186:CTRD_V');
    catch
        disp('Error on lcaGet for Laser YPos CAMR:IN20:186:CTRD_V')
    end
    % X variation relative to measured aperture diameter divided by 4 (approx RMS)
    YUVLasRMS = std(YUVLasRun)/(UVLasAp/4);



    % UV Laser Power
    UVLasPowRun = circshift(UVLasPowRun,[0,-1]);
    try
        UVLasPowRun(:,RunNum) = lcaGetSmart('LASR:IN20:196:PWR');
    catch
        disp('Error on lcaGet for Laser Power LASR:IN20:196:PWR')
    end
    UVLasPowMean = mean(UVLasPowRun);
    UVLasPowRMS = std(UVLasPowRun)/UVLasPowMean;

    % hard coded IR laser size in mm
    IRLasAp = 0.2;

    % IR Laser X position
    XIRLasRun = circshift(XIRLasRun,[0,-1]);
    try
        XIRLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:469:CTRD_H');
    catch
        disp('Error on lcaGet for Laser XPos CAMR:IN20:469:CTRD_H')
    end
    % X variation relative to 200um approx RMS
    % (approx RMS)
    XIRLasRMS = std(XIRLasRun)/(IRLasAp);



    % IR Laser Y Position
    YIRLasRun = circshift(YIRLasRun,[0,-1]);
    try
        YIRLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:469:CTRD_V');
    catch
        disp('Error on lcaGet for Laser YPos CAMR:IN20:469:CTRD_V')
    end
    % X variation relative to 200um approx RMS
    YIRLasRMS = std(YIRLasRun)/(IRLasAp);



    % IR Laser Power
    IRLasPowRun = circshift(IRLasPowRun,[0,-1]);
    try
        IRLasPowRun(:,RunNum) = lcaGetSmart('LASR:IN20:475:PWR');
    catch
        disp('Error on lcaGet for Laser Power LASR:IN20:475:PWR')
    end
    IRLasPowMean = mean(IRLasPowRun);
    IRLasPowRMS = std(IRLasPowRun)/IRLasPowMean;


    % default status of beam in sector 28
    status28Und = 1;


    %'Beamrate Mark'
    handles.tstr = get_time;
    try
      [sys,accelerator]=getSystem();
      rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);  % rep. rate [Hz]
    catch
      disp(['Error on lcaGet for EVNT:' sys ':1:' accelerator 'BEAMRATE - defaulting to 1 Hz rate.'])
      rate = 1;
    end

    % Some old programs die on rate=0
    if rate < 1
        rate = 1;
    end





    %'YAG02 Mark'

    % Skip scan if YAG02 is in.  (Schottky scan will mess up RMS)
    try
        YAG02 = lcaGetSmart('YAGS:IN20:241:PNEUMATIC');
    catch
        disp('Error on lcaGet for YAGS:IN20:241:PNEUMATIC.  Assume YAG02 not in')
    end
    if ~(strcmp(YAG02,'OUT'))
        disp('YAG02 is in.  Wait for scan to finish');
        set(handles.STATUS,'String','YAG02 is in.  Waiting for scan to finish...');
        disp(handles.tstr);
        pause(handles.wait);
        continue;
    end


    % Check LTU status and adjust energy BPMs accordingly
    BSY_mag = 0;
    if BSY_mag < 1
        statusLTU = 1;
        handles.statusLTU = 1;
        set(handles.RMS4,'String','LTU dE/E RMS (%) =');
    else
        statusLTU = 0;
        handles.statusLTU = 0;
        set(handles.RMS4,'String','BSY dE/E RMS (%) =');
    end

    % Check TDUND status and adjust XY Jitter BPMs accordingly
    try
        TDUND = lcaGetSmart('DUMP:LTU1:970:TDUND_PNEU');
    catch
        disp('Error on lcaGet for DUMP:LTU1:970:TDUND_PNEU. Assume TDUND in.')
        TDUND = 'IN';
    end

    % For now, assume 'IN'
    TDUND = 'IN';
    if strcmp(TDUND,'OUT')
        statusUnd = 1;
        handles.statusUnd = 1;
    else
        statusUnd = 0;
        handles.statusUnd = 0;
    end


    if statusUnd;
        set(handles.S28PANEL,'Title','XY Undulator Jitter');
        set(handles.X28TEXT,'String','Und dX/Xsig RMS(%) =');
        set(handles.Y28TEXT,'String','Und dY/Ysig RMS(%) =');
        set(handles.LOG28,'String','Log Undulator');
        TotBPM_pvs = cat(1,EBPM_pvs,XYInjBPM_pvs,XYUndBPM_pvs);
    elseif statusLTU
        set(handles.S28PANEL,'Title','XY LTU Jitter');
        set(handles.X28TEXT,'String','LTU dX/Xsig RMS(%) =');
        set(handles.Y28TEXT,'String','LTU dY/Ysig RMS(%) =');
        set(handles.LOG28,'String','Log LTU');
        TotBPM_pvs = cat(1,EBPM_pvs,XYInjBPM_pvs,XYLTUBPM_pvs);
    else
        set(handles.S28PANEL,'Title','XY Sector 28 Jitter');
        set(handles.X28TEXT,'String','28 dX/Xsig RMS(%) =');
        set(handles.Y28TEXT,'String','28 dY/Ysig RMS(%) =');
        set(handles.LOG28,'String','Log Sector 28');
        TotBPM_pvs = cat(1,EBPM_pvs,XYInjBPM_pvs,XY28BPM_pvs);
    end



    'All BPMs Mark'
    %lcaPut('SIOC:SYS0:ML00:AO186',1);
    % Read in all BPMs
    try
        [TotX,TotY,TotT,TotdX,TotdY,TotdT,Totiok] = read_BPMsSmart(TotBPM_pvs,1,rate);  % read first BPM, X, Y, & TMIT with averaging
    catch
        disp('Error with read_BPMsSmart')
    end

    'Done Reading BPMs'
    %lcaPut('SIOC:SYS0:ML00:AO186',3);
    % Separate out Energy, Injector and Sector 28 BPMs
    EX = TotX(1:NE);
    ET = TotT(1:NE);
    XInj = TotX(NE+1:NE+NxyInj);
    YInj = TotY(NE+1:NE+NxyInj);
    iokInj = Totiok(NE+1:NE+NxyInj);
    X28Und = TotX(NE+NxyInj+1:end);
    Y28Und = TotY(NE+NxyInj+1:end);
    iok28Und = Totiok(NE+NxyInj+1:end);




    % Check if beam is down
    if 1.602E-10*ET(1) < 1e-3
        disp('Error: charge too low');
        disp(handles.tstr);
        pause(handles.wait);
        set(handles.STATUS,'String','No Charge: Waiting for beam...');
        continue;
    end

    % Running Average of energy and TMIT
    % There are NE BPMs being read, but we only use NE-2 dispersive regions.
    % Use BPM NE-2 for the BSY, and BPMs NE,NE-1 for LTU.
    ERun = circshift(ERun,[0,-1]);      % Shift register of energy values from last iteration
    ERun(:,RunNum) = EX(1:NE-2)./etax(1:NE-2);      % convert X to energy and add to last value in ERun register
    % Check if in LTU. In this case, use LTU BPMs for final energy jitter
    if statusLTU
        % Check beam reaches end of DL2.  If not, just use first LTU BPM
        if ET(NE) > ET(NE-1)/2
            ERun(NE-2,RunNum) = (EX(NE-1)/etax(NE-1)+EX(NE)/etax(NE))/2;
        else
            ERun(NE-2,RunNum) = EX(NE-1)/etax(NE-1);
        end
    end
    ERMS = std(ERun,0,2);               % Calculate new standard deviation



    TRun = circshift(TRun,[0,-1]);      % Shift register of TMIT values
    TRun(1,RunNum) = ET(1);              % update last value of register to TMIT from BPM2
    handles.Tmean = mean(TRun);        % Calc mean value of charge
    TRMS = std(TRun)/abs(handles.Tmean);    % Calc rms variation of charge



    %'Bunch Length Mark'

    % Bunch Length Measurements
    LBC1Run = circshift(LBC1Run,[0,-1]);
    try
        LBC1Run(:,RunNum) = lcaGetSmart('BLEN:LI21:265:AIMAX');
    catch
        disp('Error on lcaGet for BC monitor BLEN:LI21:265:AIMAX')
    end
    LBC1Mean = mean(LBC1Run);
    LBC1RMS = std(LBC1Run)/abs(LBC1Mean);

    LBC2Run = circshift(LBC2Run,[0,-1]);
    try
        LBC2Run(:,RunNum) = lcaGetSmart('BLEN:LI24:886:BIMAX');
    catch
        disp('Error on lcaGet for BC Monitor BLEN:LI24:886:BIMAX')
    end
    LBC2Mean = mean(LBC2Run);
    LBC2RMS = std(LBC2Run)/abs(LBC2Mean);


    % Check for beam at all injector BPMs
    if ~(all(iokInj))
        disp('Error reading Injector BPMs');
        disp(handles.tstr);
        pause(handles.wait);
        set(handles.STATUS,'String','No Inj BPM Signal: Waiting for beam...');
        continue
    end

    % Count successful run in injector
    count = count+1;

    % Check for beam at all sector 28/Und BPMs
    if ~(all(iok28Und))
        disp('Error reading Sector 28/Und BPMs');
        disp(handles.tstr);
        set(handles.STATUS,'String','No beam in sector 28/Und');
        status28Und = 0;
        countUnd = 0;
        countLTU = 0;
        count28 = 0;
    end




    % Update register with new inj XY jitter values
    XsInj = circshift(XsInj,[-1,0]);
    YsInj = circshift(YsInj,[-1,0]);
    ioksInj = circshift(ioksInj,[-1,0]);
    XsInj(end,:)  =  XInj;
    YsInj(end,:)  =  YInj;
    ioksInj(end,:) = iokInj;

    % Update sector 28/Und jitters only if beam seen there
    if status28Und
        if statusUnd
            XsUnd = circshift(XsUnd,[-1,0]);
            YsUnd = circshift(YsUnd,[-1,0]);
            ioksUnd = circshift(ioksUnd,[-1,0]);
            XsUnd(end,:)  =  X28Und;
            YsUnd(end,:)  =  Y28Und;
            ioksUnd(end,:) = iok28Und;
            % Count successful run in sector 28/Und
            countUnd = countUnd + status28Und;
        elseif statusLTU
            XsLTU = circshift(XsLTU,[-1,0]);
            YsLTU = circshift(YsLTU,[-1,0]);
            ioksLTU = circshift(ioksLTU,[-1,0]);
            XsLTU(end,:)  =  X28Und;
            YsLTU(end,:)  =  Y28Und;
            ioksLTU(end,:) = iok28Und;
            % Count successful run in sector 28/Und
            countLTU = countLTU + status28Und;
        else
            Xs28 = circshift(Xs28,[-1,0]);
            Ys28 = circshift(Ys28,[-1,0]);
            ioks28 = circshift(ioks28,[-1,0]);
            Xs28(end,:)  =  X28Und;
            Ys28(end,:)  =  Y28Und;
            ioks28(end,:) = iok28Und;
            % Count successful run in sector 28/Und
            count28 = count28 + status28Und;
        end
    end


    %dat_time1 = toc;

    % If register not full yet, restart loop
    if count < RunNum
        disp(RunNum - count)
        set(handles.STATUS,'String',['Loading buffer. Runs left: ',num2str(RunNum-count)]);
        %pause(handles.wait)
        pause(1/rate)
        continue
    end

    % Update status in GUI
    if ~status28Und
        set(handles.STATUS,'String','Running in injector, no beam in sector 28/Und');
    elseif count28Und<RunNum
        set(handles.STATUS,'String','Running in injector, buffering in sector 28/Und');
    else
        set(handles.STATUS,'String','Running...');
    end

    'Inj XY Mark'

    % Calculate injector XY jitter
    [XInjRMS,YInjRMS,uvxInj,duxInj,dvxInj,uvyInj,duyInj,dvyInj] = XYJitter_loop(XYInjBPM_pvs,RunNum,hObject, eventdata, handles,XsInj,YsInj,ioksInj,JSetInj);



    '28Und XY Mark'

    % If buffer full in sector 28/Und, calculate 28/Und jitter

    if statusUnd && countUnd>= RunNum
        [X28UndRMS,Y28UndRMS,uvx28Und,dux28Und,dvx28Und,uvy28Und,duy28Und,dvy28Und] = ...
            XYJitter_loop(XYUndBPM_pvs,RunNum,hObject, eventdata, handles,XsUnd,YsUnd,ioksUnd,JSetUnd);
        count28Und = RunNum;
    elseif statusLTU && countLTU>= RunNum
        [X28UndRMS,Y28UndRMS,uvx28Und,dux28Und,dvx28Und,uvy28Und,duy28Und,dvy28Und] = ...
            XYJitter_loop(XYLTUBPM_pvs,RunNum,hObject, eventdata, handles,XsLTU,YsLTU,ioksLTU,JSetLTU);
        count28Und = RunNum;
    elseif count28>= RunNum
        [X28UndRMS,Y28UndRMS,uvx28Und,dux28Und,dvx28Und,uvy28Und,duy28Und,dvy28Und] = ...
            XYJitter_loop(XY28BPM_pvs,RunNum,hObject, eventdata, handles,Xs28,Ys28,ioks28,JSet28);
        count28Und = RunNum;
    end



    % total time to read BPMs, etc.
    %dat_time = toc;

    % times for measurements in register
    %mytime = (-(RunNum-1)*(handles.wait+dat_time):(handles.wait+dat_time):0);
    mytime = (-(RunNum-1)*handles.wait:handles.wait:0);



    %'Data Formatting Mark'

    ERMS = ERMS*100;    % Convert ERMS to percent
    TRMS = TRMS*100;    % Convert TRMS to percent
    XUVLasRMS = XUVLasRMS*100;
    YUVLasRMS = YUVLasRMS*100;
    UVLasPowRMS = UVLasPowRMS*100;
    XIRLasRMS = XIRLasRMS*100;
    YIRLasRMS = YIRLasRMS*100;
    IRLasPowRMS = IRLasPowRMS*100;
    XInjRMS = XInjRMS*100;
    YInjRMS = YInjRMS*100;
    LBC1RMS = LBC1RMS*100;
    LBC2RMS = LBC2RMS*100;

    if count28Und>=RunNum
        X28UndRMS = X28UndRMS*100;
        Y28UndRMS = Y28UndRMS*100;
    end
    % History register used to make strip chart
    EHist = circshift(EHist,[0,-1]);        % shift history register of Energy RMS values
    EHist(:,RunNum) = ERMS;                 % update latest ERMS value in register
    THist = circshift(THist,[0,-1]);        % shift history register of Charge RMS values
    THist(RunNum) = TRMS;                   % update latest TRMS value in register
    XUVLasHist = circshift(XUVLasHist,[0,-1]);
    XUVLasHist(:,RunNum) = XUVLasRMS;
    YUVLasHist = circshift(YUVLasHist,[0,-1]);
    YUVLasHist(:,RunNum) = YUVLasRMS;
    UVLasPowHist = circshift(UVLasPowHist,[0,-1]);
    UVLasPowHist(:,RunNum) = UVLasPowRMS;
    XIRLasHist = circshift(XIRLasHist,[0,-1]);
    XIRLasHist(:,RunNum) = XIRLasRMS;
    YIRLasHist = circshift(YIRLasHist,[0,-1]);
    YIRLasHist(:,RunNum) = YIRLasRMS;
    IRLasPowHist = circshift(IRLasPowHist,[0,-1]);
    IRLasPowHist(:,RunNum) = IRLasPowRMS;
    LBC1Hist = circshift(LBC1Hist,[0,-1]);
    LBC1Hist(RunNum) = LBC1RMS;
    LBC2Hist = circshift(LBC2Hist,[0,-1]);
    LBC2Hist(RunNum) = LBC2RMS;
    XHistInj = circshift(XHistInj,[0,-1]);
    XHistInj(RunNum) = XInjRMS;
    YHistInj = circshift(YHistInj,[0,-1]);
    YHistInj(RunNum) = YInjRMS;
    if count28Und>=RunNum
        XHist28Und = circshift(XHist28Und,[0,-1]);
        XHist28Und(RunNum) = X28UndRMS;
        YHist28Und = circshift(YHist28Und,[0,-1]);
        YHist28Und(RunNum) = Y28UndRMS;
    end

    %'Plot Mark'

    %mycolor = [129,77,15];


    % Plot Energy History
    Eax=handles.EHISTAX;
    plot(mytime,EHist(2,:),mytime,EHist(3,:),mytime,EHist(4,:),mytime,EHist(5,:),'Parent',Eax);
    %xlabel(Eax,'Time (sec)');
    ylabel(Eax,'dE/E RMS (%)');
    xlim(Eax,[fix(mytime(1)) mytime(RunNum)]);
    if isfinite(max(max(EHist((2:5),:))))
        ylim(Eax,[0 1.1*max(max(EHist((2:5),:)))+.1]);
    end


    % Plot TMIT History
    TMITax=handles.TMITHISTAX;
    plot(mytime,THist,'Parent',TMITax);
    hold(TMITax,'on');
    plot(mytime,UVLasPowHist,'k','Parent',TMITax);
    hold(TMITax,'off');
    %xlabel(TMITax,'Time (sec)');
    ylabel(TMITax,'e- RMS (%)');
    xlim(TMITax,[fix(mytime(1)) mytime(RunNum)]);
    if isfinite(max(max(THist),max(UVLasPowHist)))
        ylim(TMITax,[0 1.1*max(max(THist),max(UVLasPowHist))+.1]);
    end



    % Plot Laser History
    LASax=handles.LASHISTAX;
    plot(mytime,XUVLasHist,mytime,YUVLasHist,'Parent',LASax);
    hold(LASax,'on');
    plot(mytime,XIRLasHist,'-.',mytime,YIRLasHist,'-.','Parent',LASax);
    plot(mytime,UVLasPowHist,'k',mytime,IRLasPowHist,'k-.','Parent',LASax);
    hold(LASax,'off');
    %xlabel(Eax,'Time (sec)');
    ylabel(LASax,'Laser RMS (%)');
    xlim(LASax,[fix(mytime(1)) mytime(RunNum)]);
    if isfinite(max([max(XUVLasHist), max(YUVLasHist), max(UVLasPowHist),...
            max(XIRLasHist), max(YIRLasHist), max(IRLasPowHist)]))
        ylim(LASax,[0 1.1*max([max(XUVLasHist), max(YUVLasHist), max(UVLasPowHist),...
            max(XIRLasHist), max(YIRLasHist), max(IRLasPowHist)])+.1]);
    end
    xlabel(LASax,'Time (sec)');

    % Plot Length History
    LBCax=handles.LBCHISTAX;

    % Plot Bunch Length History
%     if count28Und>=RunNum
        plot(mytime,LBC1Hist,mytime,LBC2Hist,'Parent',LBCax);
        if isfinite(max(LBC1Hist)) && isfinite(max(LBC2Hist))
            ylim(LBCax,[0 1.1*max(max(LBC1Hist), max(LBC2Hist))+.1]);
        elseif isfinite(max(LBC1Hist))
            ylim(LBCax,[0 1.1*max(LBC1Hist)+.1]);
        end
%     else
%         plot(mytime,LBC1Hist,'Parent',LBCax);
%         if isfinite(max(LBC1Hist))
%             ylim(LBCax,[0 1.1*max(LBC1Hist)+.1]);
%         end
%     end
    xlabel(LBCax,'Time (sec)');
    ylabel(LBCax,'BC RMS (%)');
    xlim(LBCax,[fix(mytime(1)) mytime(RunNum)]);


    % Plot XY Injector Jitter History
    XYInjax=handles.XYHISTAX_INJ;
    plot(mytime,XHistInj,'b',mytime,YHistInj,'g','Parent',XYInjax);
    xlabel(XYInjax,'Time (sec)');
    ylabel(XYInjax,'dX/Xsig RMS (%)');
    xlim(XYInjax,[fix(mytime(1)) mytime(RunNum)]);
    if isfinite(max(max(XHistInj), max(YHistInj)))
        ylim(XYInjax,[0 1.1*max(max(XHistInj), max(YHistInj))+.1]);
    end

    % Plot XY LI28Und Jitter History
    if count28Und>=RunNum
        XY28Undax=handles.XYHISTAX_28;
        plot(mytime,XHist28Und,'b',mytime,YHist28Und,'g','Parent',XY28Undax);
        xlabel(XY28Undax,'Time (sec)');
        ylabel(XY28Undax,'dX/Xsig RMS (%)');
        xlim(XY28Undax,[fix(mytime(1)) mytime(RunNum)]);
        if isfinite(max(max(XHist28Und),max(YHist28Und)))
            ylim(XY28Undax,[0 1.1*max(max(XHist28Und),max(YHist28Und))+.1]);
        end
    end

    handles.mytime = mytime;
    handles.EHist = EHist;
    handles.THist = THist;
    handles.XUVLasHist = XUVLasHist;
    handles.YUVLasHist = YUVLasHist;
    handles.UVLasPowHist = UVLasPowHist;
    handles.XIRLasHist = XIRLasHist;
    handles.YIRLasHist = YIRLasHist;
    handles.IRLasPowHist = IRLasPowHist;
    handles.LBC1Hist = LBC1Hist;
    handles.XHistInj = XHistInj;
    handles.YHistInj = YHistInj;
    handles.XHist28Und = XHist28Und;
    handles.YHist28Und = YHist28Und;
    handles.uvxInj = uvxInj;
    handles.duxInj = duxInj;
    handles.dvxInj = dvxInj;
    handles.uvyInj = uvyInj;
    handles.duyInj = duyInj;
    handles.dvyInj = dvyInj;
        handles.LBC2Hist = LBC2Hist;
    if count28Und>=RunNum
        handles.uvx28Und = uvx28Und;
        handles.dux28Und = dux28Und;
        handles.dvx28Und = dvx28Und;
        handles.uvy28Und = uvy28Und;
        handles.duy28Und = duy28Und;
        handles.dvy28Und = dvy28Und;

    end

    % Add to handles (all digits used for PV)
    handles.ERMS = ERMS;
    handles.TRMS = TRMS;
    handles.XUVLasRMS = XUVLasRMS;
    handles.YUVLasRMS = YUVLasRMS;
    handles.UVLasPowRMS = UVLasPowRMS;
    handles.UVLasPowMean = UVLasPowMean;
    handles.XIRLasRMS = XIRLasRMS;
    handles.YIRLasRMS = YIRLasRMS;
    handles.IRLasPowRMS = IRLasPowRMS;
    handles.IRLasPowMean = IRLasPowMean;
    handles.XInjRMS = XInjRMS;
    handles.YInjRMS = YInjRMS;
    handles.LBC1RMS = LBC1RMS;
    handles.LBC2RMS = LBC2RMS;
    handles.LBC1Mean = LBC1Mean;
        handles.LBC2Mean = LBC2Mean;
    if count28Und>=RunNum
        handles.X28UndRMS = X28UndRMS;
        handles.Y28UndRMS = Y28UndRMS;

    end

    handles.count28Und = count28Und;
    handles.RunNum = RunNum;
    SetWarnings(hObject, eventdata, handles)


    % Pare down digits for GUI
    ERMS = round(ERMS*1000)/1000;
    TRMS = round(TRMS*100)/100;
    LasRMS = round(LasRMS*1000)/1000;
    XUVLasRMS = round(XUVLasRMS*100)/100;
    YUVLasRMS = round(YUVLasRMS*100)/100;
    UVLasPowRMS = round(UVLasPowRMS*100)/100;
    XIRLasRMS = round(XIRLasRMS*100)/100;
    YIRLasRMS = round(YIRLasRMS*100)/100;
    IRLasPowRMS = round(IRLasPowRMS*100)/100;
    XInjRMS = round(XInjRMS*100)/100;
    YInjRMS = round(YInjRMS*100)/100;
    LBC1RMS = round(LBC1RMS*100)/100;
    LBC1Mean = round(LBC1Mean);
        LBC2RMS = round(LBC2RMS*100)/100;
        LBC2Mean = round(LBC2Mean);
    if count28Und>=RunNum
        X28UndRMS = round(X28UndRMS*100)/100;
        Y28UndRMS = round(Y28UndRMS*100)/100;

    end


    % write values to GUImytime,XUVLasHist,mytime,YUVLasHist,
    set(handles.DLRMS,'String',num2str(ERMS(2)));
    set(handles.BC1RMS,'String',num2str(ERMS(3)));
    set(handles.BC2RMS,'String',num2str(ERMS(4)));
    set(handles.BSYRMS,'String',num2str(ERMS(5)));
    set(handles.DLTMIT,'String',num2str(TRMS));
    set(handles.LASRMS,'String',num2str(LasRMS));
    set(handles.XUV_RMS,'String',num2str(XUVLasRMS));
    set(handles.YUV_RMS,'String',num2str(YUVLasRMS));
    set(handles.UVLASPOWRMS,'String',num2str(UVLasPowRMS));
    set(handles.XIR_RMS,'String',num2str(XIRLasRMS));
    set(handles.YIR_RMS,'String',num2str(YIRLasRMS));
    set(handles.IRLASPOWRMS,'String',num2str(IRLasPowRMS));
    set(handles.XINJ_RMS,'String',num2str(XInjRMS));
    set(handles.YINJ_RMS,'String',num2str(YInjRMS));
    set(handles.LBC1_RMS,'String',num2str(LBC1RMS));
    set(handles.LBC1MEAN,'String',num2str(LBC1Mean));
        set(handles.LBC2_RMS,'String',num2str(LBC2RMS));
        set(handles.LBC2MEAN,'String',num2str(LBC2Mean));
    if count28Und>=RunNum
        set(handles.X28_RMS,'String',num2str(X28UndRMS));
        set(handles.Y28_RMS,'String',num2str(Y28UndRMS));

    end


    %'lcaPut Mark'

    % write Energy RMS and TMIT with corresponding times to PVs
    % Change PV precision in MATLAB using, for example:
    % lcaPut('SIOC:SYS0:ML00:AO170.PREC',3)
    try
        lcaPut('SIOC:SYS0:ML00:AO170',handles.ERMS(2));
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO170');
        disp(['Val: ',num2str(handles.ERMS(2))]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0170',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0170');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO171',handles.ERMS(3));
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO171');
        disp(['Val: ',num2str(handles.ERMS(3))]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0171',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0171');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO172',handles.ERMS(4));
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO172');
        disp(['Val: ',num2str(handles.ERMS(4))]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0172',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0172');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO173',handles.ERMS(5));
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO173');
        disp(['Val: ',num2str(handles.ERMS(5))]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0173',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0173');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO174',handles.TRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO174');
        disp(['Val: ',num2str(handles.TRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0174',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0174');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO175',1.602E-10*handles.Tmean)    % Charge in pC
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO175');
        disp(['Val: ',num2str(handles.Tmean)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0175',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0175');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO176',handles.XInjRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO176');
        disp(['Val: ',num2str(handles.XInjRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0176',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0176');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO177',handles.YInjRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO177');
        disp(['Val: ',num2str(handles.YInjRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0177',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0177');
    end
    if count28Und>=RunNum
        try
            lcaPut('SIOC:SYS0:ML00:AO178',handles.X28UndRMS);
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:AO178');
            disp(['Val: ',num2str(handles.X28UndRMS)]);
        end
        try
            lcaPut('SIOC:SYS0:ML00:SO0178',handles.tstr)
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:SO0178');
        end
        try
            lcaPut('SIOC:SYS0:ML00:AO179',handles.Y28UndRMS);
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:AO179');
            disp(['Val: ',num2str(handles.Y28UndRMS)]);
        end
        try
            lcaPut('SIOC:SYS0:ML00:SO0179',handles.tstr)
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:SO0179');
        end
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO180',handles.LBC1RMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO180');
        disp(['Val: ',num2str(handles.LBC1RMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0180',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0180');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO181',handles.LBC1Mean);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO181');
        disp(['Val: ',num2str(handles.LBC1Mean)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0181',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0181');
    end
%     if (count28Und>=RunNum && isfinite(LBC2RMS))
        try
            lcaPut('SIOC:SYS0:ML00:AO182',handles.LBC2RMS);
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:AO182');
            disp(['Val: ',num2str(handles.LBC2RMS)]);
        end
        try
            lcaPut('SIOC:SYS0:ML00:SO0182',handles.tstr)
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:SO0182');
        end
        try
            lcaPut('SIOC:SYS0:ML00:AO183',handles.LBC2Mean);
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:AO183');
            disp(['Val: ',num2str(handles.LBC2Mean)]);
        end
        try
            lcaPut('SIOC:SYS0:ML00:SO0183',handles.tstr)
        catch
            disp('Error writing to PV: SIOC:SYS0:ML00:SO0183');
        end
%     end

    % Laser
    try
        lcaPut('SIOC:SYS0:ML00:AO184',handles.XUVLasRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO184');
        disp(['Val: ',num2str(handles.XUVLasRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0184',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0184');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO185',handles.YUVLasRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO185');
        disp(['Val: ',num2str(handles.YUVLasRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0185',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0185');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO186',handles.UVLasPowRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO186');
        disp(['Val: ',num2str(handles.UVLasPowRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0186',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0186');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO187',handles.UVLasPowMean);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO187');
        disp(['Val: ',num2str(handles.UVLasPowMean)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0187',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0187');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO501',handles.XIRLasRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO501');
        disp(['Val: ',num2str(handles.XIRLasRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0501',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0501');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO502',handles.YIRLasRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO502');
        disp(['Val: ',num2str(handles.YIRLasRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0502',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0501');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO503',handles.IRLasPowRMS);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO503');
        disp(['Val: ',num2str(handles.IRLasPowRMS)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0503',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0503');
    end
    try
        lcaPut('SIOC:SYS0:ML00:AO504',handles.IRLasPowMean);
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:AO504');
        disp(['Val: ',num2str(handles.IRLasPowMean)]);
    end
    try
        lcaPut('SIOC:SYS0:ML00:SO0504',handles.tstr)
    catch
        disp('Error writing to PV: SIOC:SYS0:ML00:SO0504');
    end


    guidata(hObject, handles);

    loop_time = toc;

    % Pause before taking more data.  Subtract off read time from total
    % wait time
    pause(handles.wait-loop_time);


    %'finished loop'
end

set(handles.START,'String','Start');


guidata(hObject, handles);




function SetWarnings(hObject, eventdata, handles)



energy_flag = 0;
inj_flag = 0;
S28Und_flag = 0;
las_flag = 0;
bl_flag = 0;

if handles.ERMS(2) > handles.DLGood;
  energy_flag = 1;
  set(handles.RMS1,'ForegroundColor',[1 0 0]);
else
  set(handles.RMS1,'ForegroundColor',[0 0 0]);
end
if handles.ERMS(3) >  handles.BC1Good;
  energy_flag = 1;
  set(handles.RMS2,'ForegroundColor',[1 0 0]);
else
  set(handles.RMS2,'ForegroundColor',[0 0 0]);
end
if handles.ERMS(4) > handles.BC2Good;
  energy_flag = 1;
  set(handles.RMS3,'ForegroundColor',[1 0 0]);
else
  set(handles.RMS3,'ForegroundColor',[0 0 0]);
end
if handles.ERMS(5) > handles.BSYGood;
  energy_flag = 1;
  set(handles.RMS4,'ForegroundColor',[1 0 0]);
else
  set(handles.RMS4,'ForegroundColor',[0 0 0]);
end
if handles.TRMS > handles.TRMSGood;
  energy_flag = 1;
  set(handles.TMITTEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.TMITTEXT,'ForegroundColor',[0 0 0]);
end


if handles.XUVLasRMS > handles.XUVLasGood || handles.XIRLasRMS > handles.XIRLasGood;
  las_flag = 1;
  set(handles.XLASTEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.XLASTEXT,'ForegroundColor',[0 0 0]);
end
if handles.YUVLasRMS > handles.YUVLasGood || handles.YIRLasRMS > handles.YIRLasGood;
  las_flag = 1;
  set(handles.YLASTEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.YLASTEXT,'ForegroundColor',[0 0 0]);
end
if handles.UVLasPowRMS > handles.UVLasPowGood || handles.IRLasPowRMS > handles.IRLasPowGood
  las_flag = 1;
  set(handles.PLASTEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.PLASTEXT,'ForegroundColor',[0 0 0]);
end


if handles.XInjRMS > handles.XInjGood;
  inj_flag = 1;
  set(handles.XINJTEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.XINJTEXT,'ForegroundColor',[0 0 0])
end
if handles.YInjRMS > handles.YInjGood;
  inj_flag = 1;
  set(handles.YINJTEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.YINJTEXT,'ForegroundColor',[0 0 0]);
end
if handles.LBC1RMS > handles.LBC1Good;
  bl_flag = 1;
  set(handles.BL1TEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.BL1TEXT,'ForegroundColor',[0 0 0]);
end
if handles.count28Und >= handles.RunNum
    if handles.X28UndRMS > handles.X28UndGood;
        S28Und_flag = 1;
      set(handles.X28TEXT,'ForegroundColor',[1 0 0]);
    else
      set(handles.X28TEXT,'ForegroundColor',[0 0 0]);
    end
    if handles.Y28UndRMS > handles.Y28UndGood;
      S28Und_flag = 1;
      set(handles.Y28TEXT,'ForegroundColor',[1 0 0]);
    else
      set(handles.Y28TEXT,'ForegroundColor',[0 0 0]);
    end
end
if handles.LBC2RMS > handles.LBC2Good;
  bl_flag = 1;
  set(handles.BL2TEXT,'ForegroundColor',[1 0 0]);
else
  set(handles.BL2TEXT,'ForegroundColor',[0 0 0]);
end



set(handles.ENERGYPANEL,'HighlightColor',[energy_flag 0 0]);
set(handles.ENERGYPANEL,'ForegroundColor',[energy_flag 0 0]);
set(handles.LASPANEL,'HighlightColor',[las_flag 0 0]);
set(handles.LASPANEL,'ForegroundColor',[las_flag 0 0]);
set(handles.INJPANEL,'HighlightColor',[inj_flag 0 0]);
set(handles.INJPANEL,'ForegroundColor',[inj_flag 0 0]);
set(handles.S28PANEL,'HighlightColor',[S28Und_flag 0 0]);
set(handles.S28PANEL,'ForegroundColor',[S28Und_flag 0 0]);
set(handles.BLPANEL,'HighlightColor',[bl_flag 0 0]);
set(handles.BLPANEL,'ForegroundColor',[bl_flag 0 0]);







function NUMAVG_Callback(hObject, eventdata, handles)
% hObject    handle to NUMAVG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.numavg = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of NUMAVG as text
%        str2double(get(hObject,'String')) returns contents of NUMAVG as a double


% --- Executes during object creation, after setting all properties.
function NUMAVG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NUMAVG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WAIT_Callback(hObject, eventdata, handles)
% hObject    handle to WAIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.wait = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of WAIT as text
%        str2double(get(hObject,'String')) returns contents of WAIT as a double


% --- Executes during object creation, after setting all properties.
function WAIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WAIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in START.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to START (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of START


% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)
% --- Executes on button press in printLog_btn.

mytime = handles.mytime;

LogE = get(handles.LOGE,'Value');
if LogE
    % Plot Energy History
    figure(101);
    EHist = handles.EHist;
    if isfinite(EHist(2,end))
      set(gcf,'DefaultAxesColorOrder',handles.EnergyColorOrder);
      EHist = round(EHist*1000)/1000;
      subplot(2,1,1),plot(mytime,EHist(2,:),mytime,EHist(3,:),mytime,EHist(4,:),mytime,EHist(5,:));
      %xlabel(Eax,'Time (sec)');
      ylabel('dE/E RMS (%)');
      xlim([fix(mytime(1)) mytime(end)]);
      ylim([0 1.1*max(max(EHist((2:5),:)))]);
      if handles.statusLTU
        mytitle = ['Energy Jitter dE/E (%): DL1=',num2str(EHist(2,end)),' BC1=',num2str(EHist(3,end)),...
          ' BC2=',num2str(EHist(4,end)),' BSY=',num2str(EHist(5,end))];
      else
        mytitle = ['Energy Jitter dE/E (%): DL1=',num2str(EHist(2,end)),' BC1=',num2str(EHist(3,end)),...
          ' BC2=',num2str(EHist(4,end)),' LTU=',num2str(EHist(5,end))];
      end
      title(mytitle);


      % Plot TMIT History
      THist=handles.THist;
      UVLasPowHist=handles.UVLasPowHist;
      THist = round(THist*1000)/1000;
      subplot(2,1,2),plot(mytime,THist);
      hold on
      subplot(2,1,2),plot(mytime,UVLasPowHist,'k');
      hold off
      xlabel('Time (sec)');
      ylabel('Charge RMS (%)');
      xlim([fix(mytime(1)) mytime(end)]);
      ylim([0 1.1*max(max(THist),max(UVLasPowHist))]);
      util_printLog(101);
    end
end

LogL = get(handles.LOGL,'Value');
if LogL
    % Plot Energy History
    figure(201);
    LBC1Hist = handles.LBC1Hist;
    if isfinite(LBC1Hist)

      LBC1Hist = round(LBC1Hist*1000)/1000;
      LBC2Hist = handles.LBC2Hist;
      LBC2Hist = round(LBC2Hist*1000)/1000;
      plot(mytime,LBC1Hist,mytime,LBC2Hist);
      %xlabel(Eax,'Time (sec)');
      ylabel('dL/L RMS (%)');
      xlim([fix(mytime(1)) mytime(end)]);
      ylim([0 1.1*max(max(LBC1Hist),max(LBC2Hist))]);
      mytitle = ['Inverse Length Jitter (%): BC1=',num2str(LBC1Hist(end)),' BC2=',num2str(LBC2Hist(end))];
      title(mytitle);
      util_printLog(201);
    end
end

LogLas = get(handles.LOGLAS,'Value');
if LogLas
    figure(501);
    XUVLasHist = handles.XUVLasHist;
    XUVLasHist = round(XUVLasHist*1000)/1000;
    YUVLasHist = handles.YUVLasHist;
    YUVLasHist = round(YUVLasHist*1000)/1000;
    UVLasPowHist = handles.UVLasPowHist;
    UVLasPowHist = round(UVLasPowHist*1000)/1000;
    XIRLasHist = handles.XIRLasHist;
    XIRLasHist = round(XIRLasHist*1000)/1000;
    YIRLasHist = handles.YIRLasHist;
    YIRLasHist = round(YIRLasHist*1000)/1000;
    IRLasPowHist = handles.IRLasPowHist;
    IRLasPowHist = round(IRLasPowHist*1000)/1000;

    if isfinite([XUVLasHist YUVLasHist  UVLasPowHist  XIRLasHist YIRLasHist  IRLasPowHist])

      plot(mytime,XUVLasHist,mytime,YUVLasHist);
      hold on
      plot(mytime,XIRLasHist,'-.',mytime,YIRLasHist,'-.');
      plot(mytime,UVLasPowHist,'k',mytime,IRLasPowHist,'k-.')
      hold off
      ylabel('Laser RMS (%)');
      xlim([fix(mytime(1)) mytime(end)]);
      if isfinite(max([max(XUVLasHist), max(YUVLasHist), max(UVLasPowHist)]))
          ylim([0 1.1*max([max(XUVLasHist), max(YUVLasHist), max(UVLasPowHist),max(XIRLasHist), max(YIRLasHist), max(IRLasPowHist)])+.1]);
      end
      mytitle = ['UV(-) and IR(-.) Laser Jitter (%): UV XPos=',num2str(XUVLasHist(end)),...
          ' UV YPos=',num2str(YUVLasHist(end)), ' UV Power=',num2str(UVLasPowHist(end)),...
          ' IR XPos=',num2str(XIRLasHist(end)),' IR YPos=',num2str(YIRLasHist(end)),...
          ' IR Power=',num2str(IRLasPowHist(end))];
      title(mytitle);
      util_printLog(501);
    end
end

LogInj = get(handles.LOGINJ,'Value');
if LogInj
    % Plot XY Injector Jitter History
    figure(301);
    XHistInj=handles.XHistInj;
    YHistInj=handles.YHistInj;

    if isfinite([XHistInj YHistInj])

      subplot(2,1,1),plot(mytime,XHistInj,'b',mytime,YHistInj,'g');
      xlabel('Time (sec)');
      ylabel('dX/Xsig RMS (%)');
      xlim([fix(mytime(1)) mytime(end)]);
      ylim([0 1.1*max(max(XHistInj)+1, max(YHistInj))+1]);
      mytitle = ['Injector XY Jitter: X=',num2str(XHistInj(end)),' Y=',num2str(YHistInj(end))];
      title(mytitle);

      uvxInj = handles.uvxInj;
      duxInj = handles.duxInj;
      dvxInj = handles.dvxInj;
      %subplot(2,2,3),plot_bars2_parent(uvxInj(1,:)',uvxInj(2,:)',duxInj,dvxInj,'.r',Xax)
      subplot(2,2,3),plot_bars2(uvxInj(1,:)',uvxInj(2,:)',duxInj,dvxInj,'.b')
      hold on;
      plot(uvxInj(1,:)',uvxInj(2,:)','.b')
      xlabel('\it{x_N}')
      ylabel('\it{x_N}^{\prime}')
      plot_ellipse([1 0; 0 1],1,'c-')
      hor_line
      ver_line
      hold off
      axis('equal');


      uvyInj = handles.uvyInj;
      duyInj = handles.duyInj;
      dvyInj = handles.dvyInj;
      subplot(2,2,4),plot_bars2(uvyInj(1,:)',uvyInj(2,:)',duyInj,dvyInj,'.g')
      hold on;
      plot(uvyInj(1,:)',uvyInj(2,:)','.g')
      xlabel('\it{y_N}')
      ylabel('\it{y_N}^{\prime}')
      plot_ellipse([1 0; 0 1],1,'c-')
      hor_line
      ver_line
      hold off
      axis('equal');
      util_printLog(301);
    end
end

Log28Und = get(handles.LOG28,'Value');
if Log28Und
    % Plot XY 28/Und Jitter History
    XHist28Und=handles.XHist28Und;
    YHist28Und=handles.YHist28Und;
    if isfinite([XHist28Und YHist28Und])

      %plot(mytime,XHist28Und,mytime,YHist28Und,'Parent',XY28Undax);
      figure(401);
      subplot(2,1,1),plot(mytime,XHist28Und,'b',mytime,YHist28Und,'g');
      xlabel('Time (sec)');
      ylabel('dX/Xsig RMS (%)');
      xlim([fix(mytime(1)) mytime(end)]);
      ylim([0 1.1*max(max(XHist28Und)+1,max(YHist28Und))+1]);
      if handles.statusUnd
        mytitle = ['Undulator XY Jitter: X=',num2str(XHist28Und(end)),' Y=',num2str(YHist28Und(end))];
      elseif handles.statusLTU
        mytitle = ['LTU XY Jitter: X=',num2str(XHist28Und(end)),' Y=',num2str(YHist28Und(end))];
      else
        mytitle = ['Sector 28 XY Jitter: X=',num2str(XHist28Und(end)),' Y=',num2str(YHist28Und(end))];
      end
      title(mytitle);

      uvx28Und = handles.uvx28Und;
      dux28Und = handles.dux28Und;
      dvx28Und = handles.dvx28Und;
      subplot(2,2,3),plot_bars2(uvx28Und(1,:)',uvx28Und(2,:)',dux28Und,dvx28Und,'.b')
      hold on;
      plot(uvx28Und(1,:)',uvx28Und(2,:)','.b')
      xlabel('\it{x_N}')
      ylabel('\it{x_N}^{\prime}')
      plot_ellipse([1 0; 0 1],1,'-c')
      hor_line
      ver_line
      hold off
      axis('equal');


      uvy28Und = handles.uvy28Und;
      duy28Und = handles.duy28Und;
      dvy28Und = handles.dvy28Und;
      subplot(2,2,4),plot_bars2(uvy28Und(1,:)',uvy28Und(2,:)',duy28Und,dvy28Und,'.g')
      hold on;
      plot(uvy28Und(1,:)',uvy28Und(2,:)','.g')
      xlabel('\it{y_N}')
      ylabel('\it{y_N}^{\prime}')
      plot_ellipse([1 0; 0 1],1,'c-')
      hor_line
      ver_line
      hold off
      axis('equal');
      util_printLog(401);
    end
end



if ~any(ishandle(handles.exportFigT)), return, end


function JSet = XYJitter_Setup(BPM_pvs,Nsamp, hObject, eventdata, handles,norbit,rate)
if ~exist('rate','var')
  try
    [sys,accelerator]=getSystem();
    rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);  % rep. rate [Hz]
  catch
    disp(['Error on lcaGet for EVNT:' sys ':1:' accelerator 'BEAMRATE - defaulting to 1 Hz rate.'])
    rate = 1;
  end
  if rate < 1
    rate = 1;
  end
end

if ~exist('norbit','var')
  norbit = 1;
end

JSet.ifit = [1 1 1 1 0];                     % fit x0, x0', y0, y0'
gex  = 1.2E-6;
gey  = 1.2E-6;
mc2  = 511E-6;

nbpms = length(BPM_pvs);
BPM_micrs = zeros(nbpms,4);
BPM_units = zeros(nbpms,1);
energy = zeros(nbpms,1);
betax  = zeros(nbpms,1);
alfax  = zeros(nbpms,1);
betay  = zeros(nbpms,1);
alfay  = zeros(nbpms,1);
etax   = zeros(nbpms,1);

global modelSource;

if isempty(strfind(BPM_pvs{1},'LTU')) && isempty(strfind(BPM_pvs{1},'UND'))
    modelSource='SLC';
else
    modelSource='EPICS';
end

for j = 1:nbpms
  BPM_SLC_name = model_nameConvert(BPM_pvs{j},'SLC');
  BPM_micrs(j,:) = BPM_SLC_name(6:9);
  BPM_units(j)   = str2int(BPM_SLC_name(11:end));
  try
    %twiss2 = aidaget([BPM_SLC_name ':twiss'],'doublea',{'TYPE=DATABASE'});
    twiss = model_rMatGet(BPM_pvs{j},[],'TYPE=DESIGN','twiss');
  catch
    disp(['You have angered the EPICS Gods by asking for twiss params from ',BPM_pvs{j}]);
  end
  %twiss = cell2mat(twiss);
  energy(j) = twiss(1,:);
  betax(j)  = twiss(3,:);
  alfax(j)  = twiss(4,:);
  betay(j)  = twiss(8,:);
  alfay(j)  = twiss(9,:);
  etax(j)   = twiss(5,:);
end




r=model_rMatGet(BPM_pvs{end},BPM_pvs);
JSet.R1s = permute(r(1,[1 2 3 4 6],:),[3 2 1]);
JSet.R3s = permute(r(3,[1 2 3 4 6],:),[3 2 1]);



JSet.ex = gex*mc2/energy(end);
JSet.ey = gey*mc2/energy(end);
JSet.bx = betax(end);
JSet.by = betay(end);
JSet.ax = alfax(end);
JSet.ay = alfay(end);

% [JSet.R1s,JSet.R3s,JSet.Zs,JSet.Zs0] = ...
%         ('BPMS',BPM_micrs(end,1:4),BPM_units(end),BPM_micrs,BPM_units);






% JSet.R1s = zeros(nbpms,5);
% JSet.R3s = zeros(nbpms,5);
% d.setParam('TYPE','DATABASE');
% for j = 1:nbpms
%   try
%     R = d.geta([BPM_pvs{j} ':R'], 54);
%   catch
%     disp(['You have angered the AIDA Gods by asking for the R matrix from',BPM_pvs{j}]);
%   end
%   Rm       = reshape(double(R),6,6);
%   Rm       = Rm';
%   JSet.R1s(j,:) = Rm(1,[1:4,6]);
%   JSet.R3s(j,:) = Rm(3,[1:4,6]);
% end
% d.reset();





navg = 1;
% [X0,Y0,T0] = read_BPMsSmart(BPM_pvs,navg,rate);  % read all BPMs, X, Y, & TMIT with averaging
% %Xs0  =  X0;                 % mean X-position for all BPMs [mm]
% %Ys0  =  Y0;                 % mean Y-position for all BPMs [mm]
% %Ts0  =  1.602E-10*T0;       % mean charge for all BPMs [nC]
% if all(T0==0)
%   disp('No beam')
%   Xsf=0;
%   Ysf=0;
%   ps=0;
%   dps=0;
%   uvx=0;
%   uvy=0;
%   dux=0;
%   dvx=0;
%   duy=0;
%   dvy=0;
%   guidata(hObject, handles);
%   return
% end
guidata(hObject, handles);

%--------------------------------------------------------------
function [Xstd,Ystd,uvx,dux,dvx,uvy,duy,dvy] = XYJitter_loop(BPM_pvs, Nsamp, hObject,eventdata, handles,Xs,Ys,ioks,JSet)


R1s = JSet.R1s;
R3s = JSet.R3s;
%Zs = JSet.Zs;
%Zs0 = JSet.Zs0;
ifit = JSet.ifit;
ex = JSet.ex;
ey = JSet.ey;
bx = JSet.bx;
by = JSet.by;
ax = JSet.ax;
ay = JSet.ay;


nbpms = length(BPM_pvs);
Xsf  = zeros(Nsamp,nbpms);
Ysf  = zeros(Nsamp,nbpms);
ps   = zeros(Nsamp,sum(ifit));
dps  = zeros(Nsamp,sum(ifit));
dps12= zeros(Nsamp,1);
dps34= zeros(Nsamp,1);


% tstr = get_time;

Xs0 = mean(Xs);
Ys0 = mean(Ys);

dXs = Xs - ones(Nsamp,1)*Xs0;
dYs = Ys - ones(Nsamp,1)*Ys0;


Xs
Ys
BPM_pvs

for j = 1:Nsamp
    [Xf,Yf,p,dp,chisq,Q,Vv] = ...
      xy_traj_fit(dXs(j,ioks(j,:)&1),1,dYs(j,ioks(j,:)&1),1,0*dXs(j,ioks(j,:)&1),0*dYs(j,ioks(j,:)&1),R1s(ioks(j,:)&1,:),R3s(ioks(j,:)&1,:),ifit);	% fit trajectory
    Xsf(j,ioks(j,:)&1) = Xf;
    Ysf(j,ioks(j,:)&1) = Yf;
    ps(j,:)  = p;
    dps(j,:) = dp;
    V = reshape(Vv,sum(ifit),sum(ifit));
    dps12(j,:) = V(1,2);
    dps34(j,:) = V(3,4);
end




Xax = JSet.X_AX;
ii = 1:Nsamp;
iQx = [1 0; ax bx]/sqrt(ex*bx);
uvx = 1E-3*iQx*[ps(ii,1)'; ps(ii,2)'];
dux = 1E-3*dps(ii,1)/sqrt(ex*bx);
dvx = 1E-3*sqrt(( ax^2*dps(ii,1).^2 + bx^2*dps(ii,2).^2 + ax*bx*dps12(ii) ))/sqrt(ex*bx);
plot_bars2_parent(uvx(1,:)',uvx(2,:)',dux,dvx,'.b',Xax)
hold(Xax,'on');
rx = sqrt(uvx(1,:).^2 + uvx(2,:).^2);
plot(uvx(1,:)',uvx(2,:)','.b','parent',Xax)
%title(Xax,'\it{x}')
xlabel(Xax,'\it{x}')
ylabel(Xax,'\it{x}''')
plot_ellipse_parent([1 0; 0 1],Xax)
hor_line_parent(Xax)
ver_line_parent(Xax)
% ver_line
% title(['RMS {\itA_{xN}}=' sprintf('%3.1f%%; ',100*std(rx)) ' BPM ' BPM_micrs(end,1:4) ' ' int2str(BPM_units(end))])
% enhance_plot('times',16,1,15)
hold(Xax,'off')
axis(Xax,'equal');



Yax = JSet.Y_AX;
iQy = [1 0; ay by]/sqrt(ey*by);
uvy = 1E-3*iQy*[ps(ii,3)'; ps(ii,4)'];
duy = 1E-3*dps(ii,3)/sqrt(ey*by);
dvy = 1E-3*sqrt(( ay^2*dps(ii,3).^2 + by^2*dps(ii,4).^2 + ay*by*dps34(ii) ))/sqrt(ey*by);
plot_bars2_parent(uvy(1,:)',uvy(2,:)',duy,dvy,'.g',Yax)
hold(Yax,'on');
ry = sqrt(uvy(1,:).^2 + uvy(2,:).^2);
plot(uvy(1,:)',uvy(2,:)','.g','parent',Yax)
%title(Yax,'\it{y}')
xlabel(Yax,'\it{y}')
ylabel(Yax,'\it{y}''')
plot_ellipse_parent([1 0; 0 1],Yax)
hor_line_parent(Yax)
ver_line_parent(Yax)
% title(['RMS {\itA_{yN}}=' sprintf('%3.1f%%; ',100*std(ry)) tstr])
% enhance_plot('times',16,1,15)
hold(Yax,'off')
axis(Yax,'equal')

Xstd = std(rx);
Ystd = std(ry);




%--------------------------------------------------------------
function plot_ellipse_parent(X,myhandle,no_grid,mrk)

%       plot_ellipse(X[,no_grid,mrk])
%
%	Plots the ellipse described by the 2X2 symmetric matrix "X".
%
%    INPUTS:	X:	        A 2X2 symmetric matrix which describes
%                               the ellipse follows:
%
%			            [x y]*X*[x y]' = 1,
%				    	  	or, with X = [a b]
%                                                            [b c],
%			              2     	  2
%			            ax + 2bxy + cy  = 1
%               no_grid:        (Optional,DEF=1) no_grid=0: a grid is plotted
%                                                no_grid=1: no grid is plotted
%               mrk:            (Optional,DEF='b-') Plot symbol (see plot)

%===============================================================================

[r,c] = size(X);
if r~=2 | c~=2
  error('X must be 2X2 matrix')
end
if abs(X(1,2)) > 10*eps
  if abs(X(1,2)-X(2,1)) > (abs(.001*X(1,2)) + eps)
    error('X must be a symmetric matrix')
  end
else
  if abs(X(2,1)) > 10*eps
    error('X must be a symmetric matrix')
  end
end

if ~exist('no_grid')
  no_grid = 1;
end

if ~exist('mrk')
  mrk = 'c-';
end

a = X(1,1);
b = X(1,2);
c = X(2,2);

theta = 0:0.01:pi;
C = cos(theta);
S = sin(theta);

r = sqrt( (a*(C.^2) + 2*b*(C.*S) + c*(S.^2)).^(-1) );
r = [r r];
C = [C -C];
S = [S -S];

x = r.*C;
y = r.*S;

plot(x,y,mrk,'parent',myhandle)


if no_grid==0
  hor_line(0)
  ver_line(0)
end



%--------------------------------------------------------------
function plot_bars2_parent(x,y,dx,dy,char,myhandle)

%               plot_bars2(x,y,dx,dy,char)
%
%               Function to plot with 2 dimensional error bars of x +/- dx,
%               and y +/- dy.
%
%     INPUTS:   x:      The horizontal axis data vector (column or row)
%               y:      The vertical axis data vector (column or row)
%               dx:     The half length of the error bar on "x" (column, row,
%                       or scalar)
%               dy:     The half length of the error bar on "y" (column, row,
%                       or scalar)
%               char:   The plot character at the point (x,y)
%                       (see plot)

%=============================================================================

x  = x(:)';
y  = y(:)';
dx = dx(:)';
dy = dy(:)';

[rx,cx] = size(x);
[ry,cy] = size(y);
[rdx,cdx] = size(dx);
[rdy,cdy] = size(dy);

if (rx~=1) || (ry~=1) || (rdx~=1) || (rdy~=1)
  disp(' ')
  disp('*** PLOT_BARS only plots vectors ***')
  disp(' ')
  return
end

n = cx;

if cdx==1
  dx = dx*ones(1,n);
end

if cdy==1
  dy = dy*ones(1,n);
end

x_barv = [x; x];
y_barv = [y+dy; y-dy];

x_barh = [x-dx; x+dx];
y_barh = [y; y];

%[ss,vv]=inquire('axis');
%if ~(inquire('hold') | ss)
%  xmax = max(x_barh(2,:));
%  xmin = min(x_barh(1,:));
%  ymax = max(y_barv(1,:));
%  ymin = min(y_barv(2,:));
%  axis([xmin xmax ymin ymax])
%end

if length(char)<2
  char(2) = 'b';
end
plot(x_barv,y_barv,['-' char(2)],...
     x_barh,y_barh,['-' char(2)],...
     x,y,char,'parent',myhandle);


%--------------------------------------------------------------
function hor_line_parent(myhandle,y,mrk)

%HOR_LINE       hor_line([y,mrk]);
%
%               Draws a horizontal dotted line along "y" on current plot
%               and leaves plot in "hold" state it was in
%
%     INPUTS:   y:      (Optional, DEF=0) The value of the vertical axis to draw a
%                       horizontal line.
%		mrk:	(Optional, DEF=':') The line type used.
%     OUTPUTS:          Plot line on current plot
%
%Emma     5/26/88: original
%Woodley  6/16/95: Matlab 4.1
%
%===========================================================================

if exist('y')==0,
  y = 0;                           % default to line at 0 if not given
end
if exist('mrk')==0,
  mrk = ':';                       % default to ':'
end

hold_state = get(myhandle,'NextPlot');  % get present hold state
XLim = get(myhandle,'XLim');            % get present axis limits

hold(myhandle,'on')                            % hold current plot
plot(XLim,y*ones(size(XLim)),mrk,'parent',myhandle)  % draw line
hold(myhandle,'off')                           % remove hold

set(myhandle,'NextPlot',hold_state);    % restore original hold state


%--------------------------------------------------------------
function ver_line_parent(myhandle,x,mrk)

%VER_LINE       ver_line([x,mrk]);
%
%               Draws a vertical dotted line along "x" on current plot
%               and leaves plot in "hold" state it was in
%
%     INPUTS:   x:      (Optional, DEF=0) The value of the horizontal axis to draw a
%                       vertical line.
%		mrk:	(Optional, DEF=':') The line type used.
%
%     OUTPUTS:          Plots line on current plot
%
%Emma     5/26/88: original
%Woodley  6/16/95: Matlab 4.1
%
%===========================================================================

if exist('x')==0,
  x = 0;                           % default to line at 0 if not given
end
if exist('mrk')==0,
  mrk = ':';                       % default to ':'
end

hold_state = get(myhandle,'NextPlot');  % get present hold state
YLim = get(myhandle,'YLim');            % get present axis limits
hold(myhandle,'on')                            % hold current plot
plot(x*ones(size(YLim)),YLim,mrk,'parent',myhandle)  % draw line
hold(myhandle,'off')                           % remove hold

set(myhandle,'NextPlot',hold_state);    % restore original hold state


% --- Executes on button press in LOGE
function LOGE_Callback(hObject, eventdata, handles)
% hObject    handle to LOGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LOGE


% --- Executes on button press in LOGINJ.
function LOGINJ_Callback(hObject, eventdata, handles)
% hObject    handle to LOGINJ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LOGINJ
guidata(hObject, handles);

% --- Executes on button press in LOG28.
function LOG28_Callback(hObject, eventdata, handles)
% hObject    handle to LOG28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LOG28

guidata(hObject, handles);


% --- Executes on button press in LOGL.
function LOGL_Callback(hObject, eventdata, handles)
% hObject    handle to LOGL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LOGL


% --- Executes on button press in LOGLAS.
function LOGLAS_Callback(hObject, eventdata, handles)
% hObject    handle to LOGLAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LOGLAS


function [X,Y,T,dX,dY,dT,iok] = read_BPMsSmart(BPM_pv_list,navg,rate)

%   [X,Y,T,dX,dY,dT,iok] = read_BPMs(BPM_pv_list,navg,rate);
%
%   Function to read a list of BPMs in X, Y, and TMIT with averaging and
%   beam status returned.
%
%   INPUTS:     BPM_pv_list:    An array list of BPM PVs (cell or character array, transposed OK)
%                               (e.g., [{'BPMS:IN20:221'  'BPMS:IN20:731'}]')
%               navg:           Number of shots to average (e.g., navg=5)
%               rate:           Pause 1/rate between BPM reads [Hz] (e.g., rate=10 Hz)
%
%   OUTPUTS:    X:              BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               Y:              BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               T:              BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               dX:             Standard error on mean of BPM X readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dY:             Standard error on mean of BPM Y readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [mm]
%               dT:             Standard error on mean of BPM TMIT readings (1 per BPM) after averaging (not incl. TMIT=0 pulses) [ppb]
%               iok:            Readback status based on TMIT (1 per BPM): (iok=0 per BPM if no beam on it)

%====================================================================================================



[nbpms,c] = size(BPM_pv_list);
if iscell(BPM_pv_list)          % if BPM pv list is a cell array...
  if c>1 && nbpms>1             % ...if cell is a matrix, quit
    error('Must use cell array for BPM PV input list')
  elseif c>1                    % if cell is transposed...
    nbpms = c;                  % ...fix it
    BPM_pv_list = BPM_pv_list';
  end
else                            % if NOT a cell...
  BPM_pv_list = {BPM_pv_list};  % ...make it a cell
end

pvlist = {};
for j = 1:nbpms
  pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':X'];
  pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':Y'];
  pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':TMIT'];
end

Xs  = zeros(navg,nbpms);
Ys  = zeros(navg,nbpms);
Ts  = zeros(navg,nbpms);
X   = zeros(1,nbpms);
Y   = zeros(1,nbpms);
T   = zeros(1,nbpms);
dX  = zeros(1,nbpms);
dY  = zeros(1,nbpms);
dT  = zeros(1,nbpms);
iok = zeros(1,nbpms);

% rate should be greater than 1
if rate < 1
    return;
end

for jj = 1:navg
  try
    data = lcaGetSmart(pvlist,0,'double');    % read X, Y, and TMIT of all BPMs
  catch
    disp('Error with lcaGetSmart in read_BPMsSmart')
  end

  pause(1/rate);
  %pause(.02);
  for j = 1:nbpms
    Xs(jj,j) = data(3*j-2);
    Ys(jj,j) = data(3*j-1);
    Ts(jj,j) = data(3*j);
  end
end

for j = 1:nbpms
  i = find(Ts(:,j)>0);
  if isempty(i)
    iok(j) = 0;
  else
    iok(j) = 1;
    X(j)  = mean(Xs(i,j));
    Y(j)  = mean(Ys(i,j));
    T(j)  = mean(Ts(i,j));
    dX(j) = std(Xs(i,j))/sqrt(navg);
    dY(j) = std(Ys(i,j))/sqrt(navg);
    dT(j) = std(Ts(i,j))/sqrt(navg);
  end
end
