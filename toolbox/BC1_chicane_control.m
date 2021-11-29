function varargout = BC1_chicane_control(varargin)
% BC1_CHICANE_CONTROL M-file for BC1_chicane_control.fig
%      BC1_CHICANE_CONTROL, by itself, creates a new BC1_CHICANE_CONTROL or
%      raises the existing
%      singleton*.
%
%      H = BC1_CHICANE_CONTROL returns the handle to a new BC1_CHICANE_CONTROL or the handle to
%      the existing singleton*.
%
%      BC1_CHICANE_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BC1_CHICANE_CONTROL.M with the given input arguments.
%
%      BC1_CHICANE_CONTROL('Property','Value',...) creates a new BC1_CHICANE_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BC1_chicane_control_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BC1_chicane_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help BC1_chicane_control

% Last Modified by GUIDE v2.5 26-Feb-2008 21:32:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BC1_chicane_control_OpeningFcn, ...
                   'gui_OutputFcn',  @BC1_chicane_control_OutputFcn, ...
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


% --- Executes just before BC1_chicane_control is made visible.
function BC1_chicane_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BC1_chicane_control (see VARARGIN)

% Choose default command line output for BC1_chicane_control
handles.output = hObject;

% Update handles structure
%handles.beamOffPV='MPS:IN20:1:SHUTTER_TCTL';
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
handles.r56max = 65;        % max. R56 (mm) - should be 65 mm, but hits vac. manifiold (4/14/07)
handles.r56min =  0;        % min. R56 (mm)
handles.energymax = 0.300;  % max. e- energy (GeV)
handles.energymin = 0.010;  % min. e- energy (GeV)
%
set(handles.R56SLIDER,'Max',handles.r56max);
set(handles.R56SLIDER,'Min',handles.r56min);
set(handles.R56SLIDER,'SliderStep',[0.5 5]/(handles.r56max-handles.r56min));
set(handles.R56MAX,'String',handles.r56max);
set(handles.R56MIN,'String',handles.r56min);
handles.R56_pv    = 'SIOC:SYS0:ML00:AO116';         % operating point BC1 R56 target value (mm)
handles.Energy_pv = 'SIOC:SYS0:ML00:AO123';         % operating point BC1 energy target value (MeV)
handles.r56    = abs(lcaGet(handles.R56_pv)/1E3);   % read OP target value for BC1 R56 (mm -> m)
handles.energy = lcaGet(handles.Energy_pv)/1E3;     % read OP target value for BC1 energy (MeV -> GeV)
set(handles.R56DES,'String',handles.r56*1E3);
set(handles.ENERGY,'String',handles.energy);
set(handles.R56SLIDER,'Value',handles.r56*1E3);

handles.name='BC1';
handles.nQuad={'QA12';'Q21201';'QM11';'QM12';'QM13'};
handles.quadPV=model_nameConvert(handles.nQuad);
handles.nUse=[1 3:5];
handles.nTrim={'BX11T';'BX13T';'BX14T'};
handles.trimPV=model_nameConvert(handles.nTrim);
handles.nCQ={'CQ11';'CQ12'};
handles.cqPV=model_nameConvert(handles.nCQ);
handles.phasePV  = 'SIOC:SYS0:ML00:AO060';     % beam phase prior to BC1 [deg-2856 MHz] (move PDES more neg. if |R56| decreases)
handles.bendPV    = 'BEND:LI21:231';            % BC1 chicane main bend [kG-m]
handles.XMOVD_pv  = 'BMLN:LI21:235:MOTR';       % BC1 chicane stage desired position [mm]
handles.XMOVA_pv  = 'BMLN:LI21:235:LVPOS';      % BC1 chicane stage actual LVDT position [mm]

handles.fdbkPV = { ...
    'FBCK:LNG2:1:ENABLE';              % longitudinal DL1/BC1 energy feedback (0=OFF,1=ON)
    'FBCK:LNG3:1:ENABLE';              % longitudinal DL1/BC1 energy/sigZ feedback (0=OFF,1=ON)
    'SIOC:SYS0:ML00:AO292';            % Joe's longitudinal BC1 energy feedback (0=OFF,1=ON)
    'SIOC:SYS0:ML00:AO293';            % Joe's longitudinal BC1 energy feedback (0=OFF,1=ON)
};

guidata(hObject, handles);
calc_all(handles,0);

% UIWAIT makes BC1_chicane_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BC1_chicane_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


function calc_all(handles, act_trim)

handles.bact   = lcaGet([handles.bendPV   ':BACT']);
handles.r56    = str2double(get(handles.R56DES,'String'))/1E3;
handles.energy = str2double(get(handles.ENERGY,'String'));

%[BDES,xpos,dphi] = BC1_adjust(handles.r56,handles.energy);
%[BDES,xpos,d,theta,eta,r560] = BC1_adjust(handles.r56,handles.energy,handles.bact);
[BDES,xpos,dphi,theta,eta,r560] = BC_adjust(handles.name,handles.r56,handles.energy,handles.bact);

% Check if R_56 already there.
if act_trim && abs(r560-handles.r56) < 1e-3
    yn = questdlg('R56 is already at the actual value.  Do you want to continue?','CAUTION');
    if ~strcmp(yn,'Yes')
        act_trim=0;
    end
end

%   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
%               BDES(2):    The BX11 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(3):    The BX13 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(4):    The BX14 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(5):    The QA12 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(6):    The Q21201 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(7):    The QM11 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(8):    The QM12 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(9):    The QM13 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)

handles.qbdes = lcaGet(strcat(handles.quadPV,':BDES'));
BDESn = BDES((1:numel(handles.qbdes))+4)+handles.qbdes';

if act_trim
    fdbkOn = lcaGet(handles.fdbkPV,0,'double');   % check if longitudinal feedback is ON

% Close Pockels cell shutter:
    write_message('Beam OFF - working - please wait...','MESSAGE',handles);
    shutter_open = lcaGet(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of Pockels cell shutter
    lcaPut(handles.beamOffPV,0);                              % turn off beam at Pockels cell shutter

% shift injector RF_ref_phase and its tolerances:
%    phi0 = lcaGet(handles.phasePV);              % read initial PDES first
%    phi  = phi0 - dphi;                   % (minus for MALAB variable)
    phi = -dphi;                                % (minus for MALAB variable)
    write_message(sprintf('Beam OFF - adjusting RF_ref_setpoint to %5.1f deg (& tols)',phi),'MESSAGE',handles);
    lcaPut(handles.phasePV,phi);                 % act_trim (set absolute PDES) for pre-BC1 beam phase

% set BC1 mover to new position:
    write_message(sprintf('Beam OFF - BC1 mover set to %5.1f mm',xpos*1E3),'MESSAGE',handles);
    if xpos <= 0
        xpost = xpos - 1.0E-3;              % make sure chicane hits limit swith with an extra 1 mm
    else
        xpost = xpos;
    end
    lcaPutNoWait(handles.XMOVD_pv,xpost*1E3,'double'); % set abs position for BC1 chicane mover
    lcaDelay(0.0000001);                      % delay is just for the NoWait above

    if abs(BDES(1)) < abs(handles.bact)       % if reducing main supply setting...
        BMAX = lcaGet([handles.bendPV   ':BDES.HOPR']);

        write_message('Beam OFF - trimming BC1 main supply to BMAX for STDZ','MESSAGE',handles);
        trim_magnet(handles.bendPV,BMAX,'T',120);       % set BC1 main supply to max for 10 sec    

        write_message('Beam OFF - pause for 10 sec at BMAX for STDZ','MESSAGE',handles);
        pause(10);

        write_message('Beam OFF - trimming BC1 main supply to zero for STDZ','MESSAGE',handles);
        trim_magnet(handles.bendPV,0,'T',120);          % set BC1 supply to zero
    
        if BDES(1) <= 0
            write_message('Beam OFF - DAC-zeroing BC1 main supply','MESSAGE',handles);
            lcaPut([handles.bendPV ':CTRL'],'DAC_ZERO');
            pause(5)
            write_message('Beam OFF - writing BC1 BACT -> BDES','MESSAGE',handles);
            bact = lcaGet([handles.bendPV   ':BACT']);
            lcaPut([handles.bendPV ':BDES'],bact);
        else
            pause(5);
        end
    end
    if BDES(1) > 0
        write_message(sprintf('Beam OFF - trimming BC1 BDES to %7.4f kG-m',BDES(1)),'MESSAGE',handles);
        trim_magnet(handles.bendPV,BDES(1),'T',120);    % act & trim BC1 main supply, if not to be left OFF
    end

    write_message('Beam OFF - setting BC1 trim & quad supplies to new settings','MESSAGE',handles);
    pvs = [handles.trimPV(1:3);handles.quadPV(handles.nUse)];
    BDESt = [BDES(2:4) BDESn(handles.nUse)];
    trim_magnet(pvs,BDESt,'T');           % act & trim 3 BTRMs + 4 quads (not Q21201)

    n=[{handles.bendPV};handles.quadPV(handles.nUse)];
    lcaPut(strcat(n,':EDES'),handles.energy); % Set EDES PVs

    if BDES(1) <= 0                                   % if BC1 being switched off...
        lcaPut(handles.fdbkPV,0);                         % turn off feedbacks
        write_message('BC1 OFF, so energy feedback disabled','MESSAGE',handles);
    end

% Now wait for BC1 mover to converge to its proper position...
    for j = 1:40
        xpos_act = lcaGet(handles.XMOVA_pv);                    % read BC1 LVDT position (mm)
        if abs(xpos_act - xpos*1E3) < 5
            iok = 1;
            break
        else
            if j==40
                write_message('BC1 mover is not converging - beam left OFF','MESSAGE',handles);
                iok = 0;
                break
            end
            write_message(sprintf('Waiting for BC1 mover: %5.1f mm should be %5.1f mm',xpos_act,xpos*1E3),'MESSAGE',handles);
            pause(3);
        end
    end
    if iok
        write_message('All finished - Pockels cell shutter restored','MESSAGE',handles);
        lcaPut(handles.beamOffPV,shutter_open);       % restore state of Pockels cell shutter
    end
end

handles.bact       = lcaGet([handles.bendPV    ':BACT']);           % read final BACT (kG-m)
%[BDESf,xposf,dphif,thetaf,etaf,r56f] = BC1_adjust(handles.r56,handles.energy,handles.bact); % update actual R56 (r56f)
[BDESf,xposf,phif,thetaf,etaf,r56f] = BC_adjust(handles.name,handles.r56,handles.energy,handles.bact); % update actual R56 (r56f)
str = sprintf('%5.2f',r56f*1E3);
set(handles.R56ACT,'String',str);

handles.btrmact    = lcaGet(strcat(handles.trimPV,':BACT'));
handles.cqact    = lcaGet(strcat(handles.cqPV,':BACT'));
handles.qbact      = lcaGet(strcat(handles.quadPV,':BACT'));
handles.xact       = lcaGet(handles.XMOVA_pv);       % read pos. of BC1 (mm)

str = sprintf('%6.4f',handles.bact);
set(handles.BACT,'String',str);
str = sprintf('%6.4f',BDES(1));
set(handles.BDES,'String',str);
str = sprintf('%6.3f',BDES(2));
set(handles.BTRM1,'String',str);
str = sprintf('%6.3f',BDES(3));
set(handles.BTRM3,'String',str);
str = sprintf('%6.3f',BDES(4));
set(handles.BTRM4,'String',str);
str = sprintf('%6.3f',handles.btrmact(1));
set(handles.BTRM1ACT,'String',str);
str = sprintf('%6.3f',handles.btrmact(2));
set(handles.BTRM3ACT,'String',str);
str = sprintf('%6.3f',handles.btrmact(3));
set(handles.BTRM4ACT,'String',str);
str = sprintf('%7.1f',dphi);
set(handles.PHASE,'String',str);
str = sprintf('%5.1f',xpos*1E3);
set(handles.XDES,'String',str);
str = sprintf('%5.1f',handles.xact);
set(handles.XACT,'String',str);
str = sprintf('%6.3f',handles.cqact(1));
set(handles.CQ11ACT,'String',str);
str = sprintf('%6.3f',handles.cqact(2));
set(handles.CQ12ACT,'String',str);

tags={'QA12' 'Q21201' 'QM11' 'QM12' 'QM13'};
for j=1:5
    str = sprintf('%6.3f',handles.qbact(j));
    set(handles.(tags{j}),'String',str);
    str = sprintf('%6.3f',BDESn(j));
    set(handles.([tags{j} 'NEW']),'String',str);
end

set(handles.DATE,'String',get_time);
drawnow;


% --- Executes on slider movement.
function R56SLIDER_Callback(hObject, eventdata, handles)

handles.r56 = get(hObject,'Value')/1E3;
set(handles.R56DES,'String',handles.r56*1E3);
guidata(hObject, handles);
calc_all(handles,0);


function R56DES_Callback(hObject, eventdata, handles)

handles.r56 = str2double(get(hObject,'String'))/1E3;
if (handles.r56*1E3 > handles.r56max)
    errordlg(sprintf('R56 must be <= %5.2f mm',handles.r56max),'Error');
    set(handles.R56DES,'String',handles.r56max);
    handles.r56 = handles.r56max/1E3;
end
if (handles.r56*1E3 < handles.r56min)
    errordlg(sprintf('R56 must be >= %5.2f mm',handles.r56min),'Error');
    set(handles.R56DES,'String',handles.r56min);
    handles.r56 = handles.r56min/1E3;
end
set(handles.R56SLIDER,'Value',handles.r56*1E3)
calc_all(handles,0);
guidata(hObject, handles);


function ENERGY_Callback(hObject, eventdata, handles)

handles.energy = str2double(get(hObject,'String'));
if (handles.energy < handles.energymin)
    errordlg(sprintf('Energy must be >= %5.3f GeV',handles.energymin),'Error');
    set(handles.ENERGY,'String',handles.energymin);
    handles.energy = handles.energymin;
end
if (handles.energy > handles.energymax)
    errordlg(sprintf('Energy must be <= %5.3f GeV',handles.energymax),'Error');
    set(handles.ENERGY,'String',handles.energymax);
    handles.energy = handles.energymax;
end
guidata(hObject, handles);
calc_all(handles,0);


% --- Executes on button press in UPDATE.
function UPDATE_Callback(hObject, eventdata, handles)

calc_all(handles,0);


% --- Executes on button press in ACT_TRIM.
function ACT_TRIM_Callback(hObject, eventdata, handles)

yn = questdlg('This will put the Pockels cell shutter IN, change the BC1 chicane position, adjust its magnet settings, change the injector phase, and then open the Pockels cell shutter when done.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
    return
end
calc_all(handles,1);


% --- Executes on button press in BC1OFF.
function BC1OFF_Callback(hObject, eventdata, handles)

yn = questdlg('Caution, this will temporaily switch off beam and turn off and straighten out the BC1 chicane.  Do you really want to do this?','CAUTION');
if ~strcmp(yn,'Yes')
    return
end
handles.r56 = 0;
set(handles.R56SLIDER,'Value',handles.r56*1E3)
set(handles.R56DES,'String',handles.r56*1E3)
guidata(hObject, handles);
calc_all(handles,1)


% --- Executes on button press in BC1ON.
function BC1ON_Callback(hObject, eventdata, handles)

yn = questdlg('Caution, this will turn ON and displace the BC1 chicane to its nominal settings.  Do you really want to do this?','CAUTION');
if ~strcmp(yn,'Yes')
    return
end
handles.r56    = abs(lcaGet(handles.R56_pv)/1E3);   % read OP target value for BC1 R56 (mm -> m)
handles.energy = lcaGet(handles.Energy_pv)/1E3;     % read OP target value for BC1 energy (MeV -> GeV)
set(handles.R56SLIDER,'Value',handles.r56*1E3)
set(handles.R56DES,'String',handles.r56*1E3);
set(handles.ENERGY,'String',handles.energy);
guidata(hObject, handles);
calc_all(handles,1)


% ----------------------------------------------------------
% Create functions and inactive edit uicontrol callbacks
% ----------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function R56SLIDER_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function R56DES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function XDES_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function XDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ11ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CQ11ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ12ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CQ12ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BDES_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHASE_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM1ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM3ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BTRM4ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function XACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function XACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56ACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function R56ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QA12_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QA12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QA12NEW_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QA12NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q21201_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Q21201_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q21201NEW_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Q21201NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM11_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QM11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM11NEW_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QM11NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM12_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QM12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM12NEW_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QM12NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM13_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QM13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM13NEW_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QM13NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
