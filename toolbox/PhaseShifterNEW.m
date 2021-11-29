function varargout = untitled1NEW(varargin)
% PHASESHIFTERNEW MATLAB code for PhaseShifterNEW.fig
%      PHASESHIFTERNEW, by itself, creates a new PHASESHIFTERNEW or raises the existing
%      singleton*.
%
%      H = PHASESHIFTERNEW returns the handle to a new PHASESHIFTERNEW or the handle to
%      the existing singleton*.
%
%      PHASESHIFTERNEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHASESHIFTERNEW.M with the given input arguments.
%
%      PHASESHIFTERNEW('Property','Value',...) creates a new PHASESHIFTERNEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PhaseShifterNEW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PhaseShifterNEW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PhaseShifterNEW

% Last Modified by GUIDE v2.5 16-Jul-2015 20:48:20

% Begin initialization code - DO NOT EDIT

% Commented out all lcaput for testing
%Corrected an error that when setting the optimal phase. Also made SXRSS
%first in the figure. -- Marioooo!! 7/17/2015


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PhaseShifterNEW_OpeningFcn, ...
                   'gui_OutputFcn',  @PhaseShifterNEW_OutputFcn, ...
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


% --- Executes just before PhaseShifterNEW is made visible.
function PhaseShifterNEW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PhaseShifterNEW (see VARARGIN)

% Choose default command line output for PhaseShifterNEW
handles.output = hObject;
handles.fdbkList={'SIOC:SYS0:ML00:AO818','FBCK:UND0:1:ENABLE','FBCK:FB03:TR04:MODE','SIOC:SYS0:ML02:AO127'};
handles.phaseConv = 32;
handles.phaseConvSXR = 38*360/200;
handles.fdbkState = lcaGetSmart(handles.fdbkList,0,'double');
handles.abortHXR = 0;
handles.fitParametersHXR = [0; 0; 0; 0;];
handles.fitParametersSXR = [0; 0; 0; 0;];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PhaseShifterNEW wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PhaseShifterNEW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function phase0_Callback(hObject, eventdata, handles)
% hObject    handle to phase0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (sefunction handles = dataSave(hObject, handles, val) data=handles.data;


% Hints: get(hObject,'String') returns contents of phase0 as text
%        str2double(get(hObject,'String')) returns contents of phase0 as a double


% --- Executes during object creation, after setting all properties.
function phase0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phase1_Callback(hObject, eventdata, handles)
% hObject    handle to phase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phase1 as text
%        str2double(get(hObject,'String')) returns contents of phase1 as a double


% --- Executes during object creation, after setting all properties.
function phase1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - h  
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function kick_Callback(hObject, eventdata, handles)
% hObject    handle to kick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kick as text
%        str2double(get(hObject,'String')) returns contents of kick as a double


% --- Executes during object creation, after setting all properties.
function kick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function nsteps_Callback(hObject, eventdata, handles)
% hObject    handle to nsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsteps as text
%        str2double(get(hObject,'String')) returns contents of nsteps as a double


% --- Executes during object creation, after setting all properties.
function nsteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function settle_time_Callback(hObject, eventdata, handles)
% hObject    handle to settle_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of settle_time as text
%        str2double(get(hObject,'String')) returns contents of settle_time as a double


% --- Executes during object creation, after setting all properties.
function settle_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to settle_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%kick
%phase0
%phase1
%nsteps



% --- Executes during object creation, after setting all properties.
function boh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.trimHXR1_old = lcaGetSmart('BTRM:UND1:1630:BACT');
handles.trimHXR2_old = lcaGetSmart('BTRM:UND1:1640:BACT');
handles.trimHXR3_old = lcaGetSmart('BTRM:UND1:1660:BACT');
handles.trimHXR4_old = lcaGetSmart('BTRM:UND1:1670:BACT');

Nsteps = str2num(get(handles.nsteps,'String'))

Nsamples = str2num(get(handles.n_samples,'String'))


phase0 = str2num(get(handles.phase0,'String'))

phase1 = str2num(get(handles.phase1,'String'))

kick = str2num(get(handles.kick,'String'));
kick

kickPV = strcat('XCU',sprintf('%02d',kick))

kick_settle = str2num(get(handles.kick_settle,'String'))

%kick_val = 0;  %Here is the zero kick. 

kick_val = 500e-6;

settle_time = str2num(get(handles.settle_time,'String'));

repRate= lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');

%kick at undulator "kick". Default kick is 5e-4

[handles.namesBump,coeffs] = control_undCloseOsc(kickPV,kick_val);
kickPV

handles.namesBump
% now namesBump is which correctors to tweak, coeffs are the new bmags.

% save the old orbit model
handles.bDesOld = control_magnetGet(handles.namesBump); %save current bmags

guidata(hObject,handles);

% disable first three PVs for feedback (NOT THE STATUS ONE!)
lcaPutSmart(handles.fdbkList(1:3),0);

% set the mags corresponding to desired bump made above.
control_magnetSet(handles.namesBump,coeffs); %put in bump


%CorrPV=strcat('XCOR:UND1:',num2str(kick),'80:BCTRL');
%KickerMAX = 0.002;
%lcaPut(CorrPV, kickerMAX);

BL=0;
handles.trimHXR1 =    lcaGet('BTRM:UND1:1630:BCTRL');
handles.trimHXR2 =    lcaGet('BTRM:UND1:1640:BCTRL');
handles.trimHXR3 =    lcaGet('BTRM:UND1:1660:BCTRL');
handles.trimHXR4 =    lcaGet('BTRM:UND1:1670:BCTRL');
  
guidata(hObject,handles);


pause(kick_settle);

for nst = 1:Nsteps
    if(handles.abortHXR==0);
    nst;
    phase(nst) = phase0 + ((nst-1)/(Nsteps-1))*(phase1-phase0) ;
    phase(nst) = phase(nst);
    %Phi_HXRSS = 360 degXray * ( BL / 0.006124 kGm)^2
    
    BL= 0.006124*sqrt(phase(nst)/handles.phaseConv);
      lcaPut('BTRM:UND1:1630:BCTRL',BL);
      lcaPut('BTRM:UND1:1640:BCTRL',BL);
      lcaPut('BTRM:UND1:1660:BCTRL',BL);
      lcaPut('BTRM:UND1:1670:BCTRL',BL);
    bufftstamp = 0;
    %%lcaPut(phaseshifterPV, phase(nst));
    pause(settle_time);
    for n = 1:Nsamples
    [pE(n), tstamp]=lcaGet('GDET:FEE1:241:ENRC');
    %if(tstamp ==bufftstamp)
    %    n=n-1;
    %end
    bufftstamp = tstamp;
    pause(1/repRate);
    end
    pulseEnergy(nst)= mean(pE);
    pulseEnergERRORBAR(nst) = std(pE)/sqrt(Nsamples);
    else
    break;
  end
end

%fit to a sin function

y = pulseEnergy;
x = phase;
yu = max(y);
yl = min(y);
yr = (yu-yl);                               % Range of �y�
yz = y-yu+(yr/2);
zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
per = 2*mean(diff(zx));                     % Estimate period
ym = mean(y);                               % Estimate offset
fit = @(b,x)  b(1).*(sin(2*pi*x./b(2) - 2*pi*b(3))) + b(4);    % Function to fit
fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
sHXR = fminsearch(fcn, [yr;  per;  -1;  ym])                       % Minimise Least-Squares
xp = linspace(min(x),max(x));

handles.fitParametersHXR = sHXR;

%plot results
plot(handles.axes2,xp,fit(sHXR,xp), 'r');
axes(handles.axes2);
hold(handles.axes2);
errorbar(phase,pulseEnergy,pulseEnergERRORBAR,'xb');
hold(handles.axes2);
xlabel('Phase(deg.)');
ylabel('Pulse Energy (mJ)');


plotdata.phase=phase;
plotdata.xp=xp;
plotdata.pulseEnergy=pulseEnergy;
plotdata.fit=fit(sHXR,xp);
plotdata.pulseEnergERRORBAR =pulseEnergERRORBAR ;

set(handles.procedure_log,'userdata',plotdata);

guidata(hObject,handles);
%hold(handles.axes2);
%plot(handles.axes2, xp,fit(sHXR,xp), 'r')
%hold(handles.axes2);
%errorbar(handles.axes3,phase,pulseEnergy,pulseEnergERRORBAR);

%put the phase shifter where you found it
% 
      %lcaPut('BTRM:UND1:1630:BCTRL',handles.trimHXR1);
      %lcaPut('BTRM:UND1:1640:BCTRL',handles.trimHXR2);
      %lcaPut('BTRM:UND1:1660:BCTRL',handles.trimHXR3);
      %lcaPut('BTRM:UND1:1670:BCTRL',handles.trimHXR4);

[a,b]=max(pulseEnergy);

%set(handle.optimalPhase,phase(b));

%unkick the beam

control_magnetSet(handles.namesBump,handles.bDesOld); %restore bmags
pause(0.5); % let it settle in
lcaPutSmart(handles.fdbkList(1:3),handles.fdbkState(1:3)); %restore feedbacks (NOT THE STATUS PV!)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function kick_settle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kick_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




function optimalPhase_Callback(hObject, eventdata, handles)
% hObject    handle to optimalPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of optimalPhase as text
%        str2double(get(hObject,'String')) returns contents of optimalPhase as a double


% --- Executes during object creation, after setting all properties.
function optimalPhase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimalPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_phase.
function set_phase_Callback(hObject, eventdata, handles)

phaseOpt =  str2num(get(handles.optimalPhase,'String'));
%lcaPut(phaseShifterPV,phaseOpt);

% hObject    handle to set_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trimHXR1_old = lcaGetSmart('BTRM:UND1:1630:BACT');
handles.trimHXR2_old = lcaGetSmart('BTRM:UND1:1640:BACT');
handles.trimHXR3_old = lcaGetSmart('BTRM:UND1:1660:BACT');
handles.trimHXR4_old = lcaGetSmart('BTRM:UND1:1670:BACT');
% Hint: get(hObject,'Value') returns toggle state of set_phase


% --- Executes on button press in setPhase.
function setPhase_Callback(hObject, eventdata, handles)
%save xxx

sHXR = handles.fitParametersHXR;

if(sHXR(1) == 0);
  return
end

axes(handles.axes3);
uiwait(msgbox('Click close to desired peak','Peak-Picker'));
[xP,yP] = ginput(1);
floor(xP/sHXR(2))
sHXR(3) = mod(sHXR(3),1);
start = sHXR(2)*sHXR(3);
if(sHXR(1)>0)
maxXHXR = start+sHXR(2)/4;
else
maxXHXR=start-sHXR(2)/4;
end


while((maxXHXR-xP) > sHXR(2)/2)
    maxXHXR = maxXHXR -sHXR(2);
end

while((maxXHXR-xP) < -sHXR(2)/2)
    maxXHXR = maxXHXR +sHXR(2);
end


xbeg = str2num(get(handles.phase0,'String'));

if(maxXHXR<xbeg)
    maxXHXR = maxXHXR+sHXR(2);
end

maxXHXR





phaseOpt =  maxXHXR;
set(handles.optimalPhase,'String',num2str(maxXHXR) );

BL= 0.006124*sqrt(phaseOpt/handles.phaseConv);
      lcaPut('BTRM:UND1:1630:BCTRL',BL);
      lcaPut('BTRM:UND1:1640:BCTRL',BL);
      lcaPut('BTRM:UND1:1660:BCTRL',BL);
      lcaPut('BTRM:UND1:1670:BCTRL',BL);

%%lcaPut(phaseShifterPV,phaseOpt);

% hObject    handle to setPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function n_samples_Callback(hObject, eventdata, handles)
% hObject    handle to n_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_samples as text
%        str2double(get(hObject,'String')) returns contents of n_samples as a double


% --- Executes during object creation, after setting all properties.
function n_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phase02_Callback(hObject, eventdata, handles)
% hObject    handle to phase02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phase02 as text
%        str2double(get(hObject,'String')) returns contents of phase02 as a double


% --- Executes during object creation, after setting all properties.
function phase02_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phase12_Callback(hObject, eventdata, handles)
% hObject    handle to phase12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phase12 as text
%        str2double(get(hObject,'String')) returns contents of phase12 as a double


% --- Executes during object creation, after setting all properties.
function phase12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phase12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kick2_Callback(hObject, eventdata, handles)
% hObject    handle to kick2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kick2 as text
%        str2double(get(hObject,'String')) returns contents of kick2 as a double


% --- Executes during object creation, after setting all properties.
function kick2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kick2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until handles.trimHXR1_old = lcaGetSmart('BTRM:UND1:1630:BACT');


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nsteps2_Callback(hObject, eventdata, handles)
% hObject    handle to nsteps2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsteps2 as text
%        str2double(get(hObject,'String')) returns contents of nsteps2 as a double


% --- Executes during object creation, after setting all properties.
function nsteps2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsteps2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function settle_time2_Callback(hObject, eventdata, handles)

%set(handle.optimalPhase,phase(b));
% hObject    handle to settle_time2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of settle_time2 as text
%        str2double(get(hObject,'String')) 50returns contents of settle_time2 as a double


% --- Executes during object creation, after setting all properties.
function settle_time2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to settle_time2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kick_settle2_Callback(hObject, eventdata, handles)
% hObject    handle to kick_settle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kick_settle2 as text
%        str2double(get(hObject,'String')) returns contents of kick_settle2 as a double



% --- Executes during object creation, after setting all properties.
function kick_settle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kick_settle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function optimalPhase2_Callback(hObject, eventdata, handles)
% hObject    handle to optimalPhase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of optimalPhase2 as text
%        str2double(get(hObject,'String')) returns contents of optimalPhase2 as a double


% --- Executes during object creation, after setting all properties.
function optimalPhase2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimalPhase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function n_samples2_Callback(hObject, eventdata, handles)
% hObject    handle to n_samples2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_samples2 as text
%        str2double(get(hObject,'String')) returns contents of n_samples2 as a double


% --- Executes during object creation, after setting all properties.
function n_samples2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_samples2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.trimSXR1_old = lcaGetSmart('BTRM:UND1:930:BACT');
handles.trimSXR2_old = lcaGetSmart('BTRM:UND1:940:BACT');
handles.trimSXR3_old = lcaGetSmart('BTRM:UND1:960:BACT');
handles.trimSXR4_old = lcaGetSmart('BTRM:UND1:970:BACT');



handles.abortSXR = 0;

Nsteps = str2num(get(handles.nsteps,'String'))

Nsamples = str2num(get(handles.n_samples2,'String'))


phase0 = str2num(get(handles.phase02,'String'))         %Initial Phase

phase1 = str2num(get(handles.phase12,'String'))         %Final Phase

kick = str2num(get(handles.kick2,'String'))

kickPV = strcat('XCU',sprintf('%02d',kick));

%kick_val = 0;
kick_val = 5e-4;

kick_settle = str2num(get(handles.kick_settle2,'String'))

settle_time = str2num(get(handles.settle_time2,'String'));

repRate = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');

%kick at undulator "kick". Default kick is 5e-4

[handles.namesBump,coeffs] = control_undCloseOsc(kickPV,kick_val);
% now namesBump is which correctors to tweak, coeffs are the new bmags.

% save the old orbit model
handles.bDesOld = control_magnetGet(handles.namesBump); %save current bmags

guidata(hObject,handles);

% disable first three PVs for feedback (NOT THE STATUS ONE!)
lcaPutSmart(handles.fdbkList(1:3),0);

% set the mags corresponding to desired bump made above.
control_magnetSet(handles.namesBump,coeffs); %put in bump



%lcaPut(CorrPV, kickerMAX);

pause(kick_settle);

handles.trimSXR1=    lcaGet('BTRM:UND1:930:BCTRL');
handles.trimSXR2=    lcaGet('BTRM:UND1:940:BCTRL');
handles.trimSXR3=    lcaGet('BTRM:UND1:960:BCTRL');
handles.trimSXR4=    lcaGet('BTRM:UND1:970:BCTRL');
  
guidata(hObject,handles);


for nst = 1:Nsteps
  if(handles.abortSXR==0);
    nst;
    phase(nst) = phase0 + ((nst-1)/(Nsteps-1))*(phase1-phase0) ;
    phase(nst) = phase(nst); 
    
    %Phi_HXRSS = 360 degXray * ( BL / 0.006124 kGm)^2
    
    BL= 0.006124*sqrt(phase(nst)/handles.phaseConvSXR);
      lcaPut('BTRM:UND1:930:BCTRL',BL);
      lcaPut('BTRM:UND1:940:BCTRL',BL);
      lcaPut('BTRM:UND1:960:BCTRL',BL);
      lcaPut('BTRM:UND1:970:BCTRL',BL);
    
    %%lcaPut(phaseshifterPV, phase(nst));
    pause(settle_time);
    for n = 1:Nsamples
    [pE(n), tstamp]=lcaGet('GDET:FEE1:241:ENRC');
    %if(tstamp ==bufftstamp)
    %    n=n-1;
    %end
   
    pause(1/repRate);
    end
    pulseEnergy(nst)= mean(pE);
    pulseEnergERRORBAR(nst) = std(pE)/sqrt(Nsamples);
  else
    break;
  end
end


y = pulseEnergy;
x = phase;
yu = max(y);
yl = min(y);
yr = (yu-yl);                               % Range of �y�
yz = y-yu+(yr/2);
zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
per = 2*mean(diff(zx));                     % Estimate period
ym = mean(y);                               % Estimate offset
fit = @(b,x)  b(1).*(sin(2*pi*x./b(2) - 2*pi*b(3))) + b(4);    % Function to fit
fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
sSXR = fminsearch(fcn, [yr;  per;  -1;  ym])                       % Minimise Least-Squares
xp = linspace(min(x),max(x));

handles.fitParametersSXR = sSXR;

guidata(hObject,handles);

plot(handles.axes3,xp,fit(sSXR,xp), 'r'); 
axes(handles.axes3);
hold(handles.axes3);
errorbar(phase,pulseEnergy,pulseEnergERRORBAR,'xb');
hold(handles.axes3);
xlabel('Phase(deg.)');
ylabel('Pulse Energy (mJ)');

plotdata.phase=phase;
plotdata.xp=xp;
plotdata.pulseEnergy=pulseEnergy;
plotdata.fit=fit(sSXR,xp);
plotdata.pulseEnergERRORBAR =pulseEnergERRORBAR ;
set(handles.procedure_log2,'userdata',plotdata);
%errorbar(handles.axes3,phase,pulseEnergy,pulseEnergERRORBAR);

    %puts shifter back to initial value
      %lcaPut('BTRM:UND1:930:BCTRL',handles.trimSXR1);
      %lcaPut('BTRM:UND1:940:BCTRL',handles.trimSXR2);
      %lcaPut('BTRM:UND1:960:BCTRL',handles.trimSXR3);
      %lcaPut('BTRM:UND1:970:BCTRL',handles.trimSXR4);
 

[a,b]=max(pulseEnergy);
%set(handles.optimalPhase2,'String',num2str(phase(b)) );

control_magnetSet(handles.namesBump,handles.bDesOld); %restore bmags
pause(0.5); % let it settle in
lcaPutSmart(handles.fdbkList(1:3),handles.fdbkState(1:3)); %restore feedbacks (NOT THE STATUS PV!)



% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sSXR = handles.fitParametersSXR;
if(sSXR(1) == 0);
  return
end


axes(handles.axes3);
uiwait(msgbox('Click close to desired peak','Peak-Picker'));
[xP,yP] = ginput(1);
floor(xP/sSXR(2))
sHXR(3) = mod(sSXR(3),1);
start = sSXR(2)*sSXR(3);
if(sSXR(1)>0)
maxXSXR = start+sSXR(2)/4;
else
maxXSXR=start-sSXR(2)/4;
end


while((maxXSXR-xP) > sSXR(2)/2)
    maxXSXR = maxXSXR -sSXR(2);
end

while((maxXSXR-xP) < -sSXR(2)/2)
    maxXSXR = maxXSXR +sSXR(2);
end


xbeg = str2num(get(handles.phase02,'String'));

if(maxXSXR<xbeg)
    maxXSXR = maxXSXR+sSXR(2);
end

maxXSXR
set(handles.optimalPhase2,'String',num2str(maxXSXR) )

handles.maxXSXR = maxXSXR;


phaseOpt =  maxXSXR;
BL= 0.006124*sqrt(phaseOpt/handles.phaseConvSXR);
      lcaPut('BTRM:UND1:930:BCTRL',BL);            %This is the section that puts the trims to the optimal phase you select.
      lcaPut('BTRM:UND1:940:BCTRL',BL);
      lcaPut('BTRM:UND1:960:BCTRL',BL);
      lcaPut('BTRM:UND1:970:BCTRL',BL);


% --- Executes on button press in abort_button.
function abort_button_Callback(hObject, eventdata, handles)


handles = guidata(hObject);
handles.abortHXR = 0;
kick_val = 0;
guidata(hObject,handles);



% --- Executes on button press in abort_button_SXR.
function abort_button_SXR_Callback(hObject, eventdata, handles)
% hObject    handle to abort_button_SXR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.abortSXR = 0;
kick_val = 0;
guidata(hObject,handles);

  


function procedure_log_Callback(hObject, eventdata, handles)
util_dataSave(handles,'HXRSS phase', 'Phase shifter scan', datestr(clock,0) );


plotdata=get(handles.procedure_log,'userdata');
if(~isstruct(plotdata))
  return
end
NewFigure = figure(1);

% set(1,'visible','off')  %not working???
%plot(plotdata.phase,plotdata.pulseEnergy,'b',plotdata.xp,plotdata.fit, 'r');

plot(plotdata.xp,plotdata.fit, 'r');
axes(gca);
hold
errorbar(plotdata.phase,plotdata.pulseEnergy,plotdata.pulseEnergERRORBAR,'xb');
hold

xlabel('Phase(deg.)');
ylabel('Pulse Energy (mJ)');
w=warning('off','MATLAB:childAddedCbk:CallbackWillBeOverwritten');
%axes(handles.axes2);
%hNew=copyobj(gca,1);
%warning(w);
%delete(findobj(hNew,'Visible','off'))
%Then print figure 1 which should only have the visible objects from the GUI.
%if ~epicsSimul_status, 


%handles.trimHXR1_old = lcaGetSmart('BTRM:UND1:1630:BACT');
%handles.trimHXR1 = lcaGetSmart('BTRM:UND1:1630:BACT');
util_printLog(NewFigure,'author','HXRSS PHASE SHIFTER SCAN','title','Phase Shifter Scan', 'text',[' Initial = ' num2str(handles.trimHXR1_old) ' kG' , ', Final = ' num2str(handles.trimHXR1) ' kG']);

%util_printLog_wComments(NewFigure,'HXRSS PHASE SHIFTER SCAN','Phase Shifter Scan','');
delete(1);





% --- Executes on button press in procedure_log2.
function procedure_log2_Callback(hObject, eventdata, handles)

util_dataSave(handles,'SXRSS phase', 'Phase shifter scan', datestr(clock,0) );

plotdata=get(handles.procedure_log2,'userdata');
if(~isstruct(plotdata))
  returnhandles
end



%Now i need to save the data in the handle term when I click this hObject
%function. This makes me think 
% Determine callback function, set to GUIDE generated name as default. 


NewFigure = figure(1);
% set(1,'visible','off')  %not working???
%plot(plotdata.phase,plotdata.pulsedaEnergy,'b',plotdata.xp,plotdata.fit, 'r');

plot(plotdata.xp,plotdata.fit, 'r');

hold
errorbar(plotdata.phase,plotdata.pulseEnergy,plotdata.pulseEnergERRORBAR,'xb');
hold

xlabel('Phase(deg.)');
ylabel('Pulse Energy (mJ)');
w=warning('off','MATLAB:childAddedCbk:CallbackWillBeOverwritten');
%axes(handles.axes2);
%hNew=copyobj(gca,1);
%warning(w);
%delete(findobj(hNew,'Visible','off'))
%Then print figure 1 which should only have the visible objects from the GUI.
%if ~epicsSimul_status, 

%handles.trimSXR1_old = lcaGetSmart('BTRM:UND1:930:BACT');


util_printLog(NewFigure,'author','SXRSS PHASE SHIFTER SCAN','title','Phase Shifter Scan', 'text',[' Initial =' num2str(handles.trimSXR1_old) ' kG', ', Final = ' num2str(handles.trimSXR1) ' kG']);


delete(1);




% hObject    handle to procedure_log2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)     

     


% --- Executes on button press in UndoSXR.
function UndoSXR_Callback(hObject, eventdata, handles)
% hObject    handle to UndoSXR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
     lcaPutSmart('BTRM:UND1:930:BCTRL', handles.trimSXR1_old);
     lcaPutSmart('BTRM:UND1:940:BCTRL', handles.trimSXR2_old);
     lcaPutSmart('BTRM:UND1:960:BCTRL', handles.trimSXR3_old);
     lcaPutSmart('BTRM:UND1:970:BCTRL', handles.trimSXR4_old);
     
     lcaPutSmart('BTRM:UND1:930:TRIM.PROC', 1);
     lcaPutSmart('BTRM:UND1:940:TRIM.PROC', 1);
     lcaPutSmart('BTRM:UND1:960:TRIM.PROC', 1);
     lcaPutSmart('BTRM:UND1:970:TRIM.PROC', 1);
     

% --- Executes on button press in UndoHXR.
function UndoHXR_Callback(hObject, eventdata, handles)
% hObject    handle to UndoHXR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
     lcaPutSmart('BTRM:UND1:1630:BCTRL', handles.trimHXR1_old);
     lcaPutSmart('BTRM:UND1:1640:BCTRL', handles.trimHXR2_old);
     lcaPutSmart('BTRM:UND1:1660:BCTRL', handles.trimHXR3_old);
     lcaPutSmart('BTRM:UND1:1670:BCTRL', handles.trimHXR4_old);
       
     lcaPutSmart('BTRM:UND1:1630:TRIM.PROC', 1);
     lcaPutSmart('BTRM:UND1:1640:TRIM.PROC', 1);
     lcaPutSmart('BTRM:UND1:1660:TRIM.PROC', 1);
     lcaPutSmart('BTRM:UND1:1670:TRIM.PROC', 1);
     



function kick_settle_Callback(hObject, eventdata, handles)
% hObject    handle to kick_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kick_settle as text
%        str2double(get(hObject,'String')) returns contents of kick_settle as a double
function figure1_CloseRequestFcn(hObject, eventdata, handles) 
util_appClose(hObject);


