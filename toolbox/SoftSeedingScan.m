function varargout = SoftSeedingScan(varargin)
% SOFTSEEDINGSCAN MATLAB code for SoftSeedingScan.fig
%      SOFTSEEDINGSCAN, by itself, creates a new SOFTSEEDINGSCAN or raises the existing
%      singleton*.
%
%      H = SOFTSEEDINGSCAN returns the handle to a new SOFTSEEDINGSCAN or the handle to
%      the existing singleton*.
%
%      SOFTSEEDINGSCAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOFTSEEDINGSCAN.M with the given input arguments.
%
%      SOFTSEEDINGSCAN('Property','Value',...) creates a new SOFTSEEDINGSCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SoftSeedingScan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SoftSeedingScan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SoftSeedingScan

% Last Modified by GUIDE v2.5 09-Mar-2015 12:26:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SoftSeedingScan_OpeningFcn, ...
                   'gui_OutputFcn',  @SoftSeedingScan_OutputFcn, ...
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


% --- Executes just before SoftSeedingScan is made visible.
function SoftSeedingScan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SoftSeedingScan (see VARARGIN)
SCANPVNAME='MCC:USR:PHOTON:ENERGY';
set(handles.energypv,'string',['Energy PV: ',SCANPVNAME]);
% Choose default command line output for SoftSeedingScan
handles.output = hObject;
set(handles.START,'enable','off');
set(handles.SetupSteps,'Value',2);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SoftSeedingScan wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SoftSeedingScan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
set(handles.START,'enable','off');drawnow;
WRITEPVS=get(handles.WritePVs,'value');set(handles.WritePVs,'enable','off');

MOVINGPV='SIOC:SYS0:ML03:AO334';
RAMPING=get(handles.RAMPING,'value');
NATEALGORITHMPv='SIOC:SYS0:ML00:AO98';
TOLERANCE=10^-3;

SCANPVNAME='MCC:USR:PHOTON:ENERGY';
set(handles.energypv,'string',['Energy PV: ',SCANPVNAME]);

%read angle 
AnglePVACT='MIRR:UND1:936:P:ACT';
AnglePVDES='MIRR:UND1:936:P:MOTOR';
%CentralAngle=lcaGet(AnglePVACT);
%read vernier
VernierPV='FBCK:FB04:LG01:DL2VERNIER';
%CentralVernier=lcaGet(VernierPV)
%DeltaEV

OLDVALUE=lcaGet(SCANPVNAME);

DestinationAngle=lcaGetSmart(AnglePVDES);
ReadoutAngle=lcaGetSmart(AnglePVACT);


POLANGOLI=handles.PolinomioAngoli;
POLVERNIERS=handles.PolinomioVerniers;

MinAllowed=min(POLANGOLI.breaks);
MaxAllowed=max(POLANGOLI.breaks);

while(1)
   COLOR=get(handles.STOP,'Backgroundcolor') ;
   if(COLOR(1)==1)
       set(handles.START,'String','START');
       set(handles.STOP,'Backgroundcolor',[0.7,0.7,0.7]);drawnow
       if(WRITEPVS)
%            lcaPutNoWait(AnglePVDES,CentralAngle);
%            lcaPutSmart(VernierPV,CentralVernier);
%            lcaPut('MCC:USR:PHOTON:ENERGY',REFERENCEVALUE)  
       end
       set(handles.START,'enable','on');set(handles.WritePVs,'enable','on');
       return
   end
      
   CurrentValue=lcaGet(SCANPVNAME);
   
   
   if(CurrentValue~=OLDVALUE)
      if((CurrentValue< MinAllowed) || (CurrentValue>MaxAllowed))
         disp('Requested Energy out of allowed range')
      else
        
        NewAngle = ppval(POLANGOLI,CurrentValue);
        NewVernier = ppval(POLVERNIERS,CurrentValue);
        
          if(WRITEPVS)
              lcaPutNoWait(AnglePVDES,NewAngle);
              lcaPutSmart(VernierPV,NewVernier);
              lcaPutSmart(MOVINGPV,1);
          end
          
          StateString=['Status',char(10),'Current Energy = ',num2str(CurrentValue),char(10),'New Angle = ',num2str(NewAngle),char(10),'New Vernier = ',num2str(NewVernier)];
          set(handles.State,'String',StateString,'FontWeight','bold');drawnow
          OLDVALUE=CurrentValue;
          pause(0.001)
          set(handles.State,'String',StateString,'FontWeight','normal');drawnow
          
      end
   else
       pause(0.1);
   end
   
   DestinationAngle=lcaGetSmart(AnglePVDES);
   ReadoutAngle=lcaGetSmart(AnglePVACT);
   TOL=10^-3;
   if(abs(DestinationAngle-ReadoutAngle)<TOL)
     lcaPutSmart(MOVINGPV,0);
   end
   
   
end


% NA=ppval(handles.PolinomioAngoli,NEWVALUE);
% NV=ppval(handles.PolinomioVerniers,NEWVALUE);
% 
% if(get(handles.WritePVs,'value'))
%   lcaPutNoWait(AnglePVDES,NewAngle);
%   lcaPutSmart(VernierPV,NewVernier);
% else
%   disp(['New Angle ->  ',num2str(NA)]);
%   disp(['New Vernier ->  ',num2str(NV)]);
% end
% 
% Matrice=[VettoreEnergie ; AngoloNuovo ; VernierNuovo ; VernierNuovo].';
% set(handles.Tabella,'data',Matrice)
% OLDVALUE=lcaGet(SCANPVNAME);
% REFERENCEVALUE=OLDVALUE;
% set(handles.STOP,'Backgroundcolor',[0,0.6,1]);drawnow
% set(handles.Reference,'String',['Reference',char(13),char(10),'Mirror = ',num2str(CentralAngle),char(13),char(10),'Vernier = ',num2str(CentralVernier),char(13),char(10),'Photon En. = ',num2str(OLDVALUE)])
% set(handles.START,'String','Running');
% StateString=['Status',char(10),'Delta Energy = ',num2str(0),char(10),'New Angle = ',num2str(CentralAngle),char(10),'New Vernier = ',num2str(CentralVernier)];
% set(handles.State,'String',StateString,'FontWeight','normal');drawnow

% while(1)
%    COLOR=get(handles.STOP,'Backgroundcolor') ;
%    if(COLOR(1)==1)
%        set(handles.START,'String','START');
%        set(handles.STOP,'Backgroundcolor',[0.7,0.7,0.7]);drawnow
%        if(WRITEPVS)
%            lcaPutNoWait(AnglePVDES,CentralAngle);
%            lcaPutSmart(VernierPV,CentralVernier);
%            lcaPut('MCC:USR:PHOTON:ENERGY',REFERENCEVALUE)  
%        end
%        set(handles.START,'enable','on');set(handles.WritePVs,'enable','on');
%        return
%    end
%    CurrentValue=lcaGet(SCANPVNAME);
%    
%    if(CurrentValue~=OLDVALUE)
%       if(abs(CurrentValue - REFERENCEVALUE)>MAXENERGYMOVE)
%          %do nothing 
%       else
%           MatriceAttuale = get(handles.Tabella,'data');
%           PhotonEnergies=MatriceAttuale(:,1);
%           Angles=MatriceAttuale(:,2);
%           Verniers=MatriceAttuale(:,4);
%           
%           PolinomioAngoli=pchip(PhotonEnergies,Angles);
%           PolinomioVerniers=pchip(PhotonEnergies,Verniers);
%           
%           NewAngle=ppval(PolinomioAngoli,CurrentValue);
%           NewVernier=ppval(PolinomioVerniers,CurrentValue);
% 
%           if(WRITEPVS)
%               lcaPutNoWait(AnglePVDES,NewAngle);
%               lcaPutSmart(VernierPV,NewVernier);
%           end
%           StateString=['Status',char(10),'Delta Energy = ',num2str(REFERENCEVALUE-CurrentValue),char(10),'New Angle = ',num2str(NewAngle),char(10),'New Vernier = ',num2str(NewVernier)];
%           set(handles.State,'String',StateString,'FontWeight','bold');drawnow
%           OLDVALUE=CurrentValue;
%           pause(0.5)
%           set(handles.State,'String',StateString,'FontWeight','normal');drawnow
%           
%       end
%    else
%        pause(0.5);
%    end
%    
% end

% --- Executes on button press in STOP.
function STOP_Callback(hObject, eventdata, handles)
set(handles.STOP,'Backgroundcolor',[1,1,0]);
drawnow


% --- Executes on button press in WritePVs.
function WritePVs_Callback(hObject, eventdata, handles)
% hObject    handle to WritePVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WritePVs


% --- Executes on button press in SETUP.
function SETUP_Callback(hObject, eventdata, handles)
set(handles.START,'enable','off');
I1=str2num(get(handles.SetupPE,'string'));
I2=str2num(get(handles.SetupDelta,'string'));
I3=str2num(get(handles.SetupVernier,'string'));
I4=str2num(get(handles.SetupAngle,'string'));

STEPS=get(handles.SetupSteps,'value')*2+1;

VernierPV='FBCK:FB04:LG01:DL2VERNIER';
AnglePVACT='MIRR:UND1:936:P:ACT';
AnglePVDES='MIRR:UND1:936:P:MOTOR';
PhotonEPV='SIOC:SYS0:ML00:AO627';

if(isempty(I1))
  CentralPE=lcaGet(PhotonEPV);
else
  CentralPE=I1;
end

DeltaE=I2;
if(isempty(I2))
  DeltaE=[-10,10];
else
  if(length(I2)~=2)
    DeltaE=[-10,10];
  end
  if(I2(1)>I2(2))
    DeltaE=[-10,10];
  end
  if(any(abs(I2)>400))
    DeltaE=[-10,10];
  end
end
set(handles.SetupDelta,'string',['[',num2str(DeltaE(1)) ,',',num2str(DeltaE(2)),']']);

if(length(I3)~=1)
  CentralVE=lcaGet(VernierPV);
else
  if(abs(I3)>100)
    CentralVE=lcaGet(VernierPV);
  else
    CentralVE=I3;
  end
end

if(length(I4)~=1)
  CentralAngle=lcaGet(AnglePVACT);
else
  CentralAngle=I4;
end

set(handles.SetupVernier,'string',num2str(CentralVE));
set(handles.SetupAngle,'string',num2str(CentralAngle));

USE_RAMPNIG=get(handles.RAMPING,'value');

h=4.135667516*10^-15;
c=299792458;
startingK=3.5;
gratingPeriod=1e-3/1123;
Me=0.51099891;
UndulatorPeriod=0.03;

VettoreEnergie=linspace(CentralPE+DeltaE(1),CentralPE+DeltaE(2),STEPS);

for KK=1:length(VettoreEnergie)
  AlphaS=acos(cos( pi / 180) - h*c/CentralPE/gratingPeriod);
  AlphaE=acos(cos( pi / 180) - h*c/(VettoreEnergie(KK))/gratingPeriod);
  DeltaAngle2=(AlphaE-AlphaS)/2;
  
  ConstantVernier=sqrt(1+startingK^2/2)*Me*sqrt(UndulatorPeriod)/sqrt(2*c*h);
  EbeamS=sqrt(CentralPE)*ConstantVernier;
  EbeamE=sqrt(VettoreEnergie(KK))*ConstantVernier;
  
  DeltaVernier2=EbeamE-EbeamS;
  
  NewAngle=CentralAngle-DeltaAngle2*1000;
  NewVernier=(CentralVE+DeltaVernier2)*(1-USE_RAMPNIG);
  
  Matrice(KK,1) = VettoreEnergie(KK);
  Matrice(KK,2) = NewAngle;
  Matrice(KK,3) = NewVernier;
  Matrice(KK,4) = NewVernier;
  
end

set(handles.Tabella,'data',Matrice)

handles=Correct_Callback(hObject, eventdata, handles);
guidata(hObject, handles);
set(handles.CheckScanValues,'enable','on')


function SetupPE_Callback(hObject, eventdata, handles)
% hObject    handle to SetupPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetupPE as text
%        str2double(get(hObject,'String')) returns contents of SetupPE as a double


% --- Executes during object creation, after setting all properties.
function SetupPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetupPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetupDelta_Callback(hObject, eventdata, handles)
% hObject    handle to SetupDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetupDelta as text
%        str2double(get(hObject,'String')) returns contents of SetupDelta as a double


% --- Executes during object creation, after setting all properties.
function SetupDelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetupDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetupVernier_Callback(hObject, eventdata, handles)
% hObject    handle to SetupVernier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetupVernier as text
%        str2double(get(hObject,'String')) returns contents of SetupVernier as a double


% --- Executes during object creation, after setting all properties.
function SetupVernier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetupVernier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetupAngle_Callback(hObject, eventdata, handles)
% hObject    handle to SetupAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetupAngle as text
%        str2double(get(hObject,'String')) returns contents of SetupAngle as a double


% --- Executes during object creation, after setting all properties.
function SetupAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetupAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Correct.
function handles=Correct_Callback(hObject, eventdata, handles)
try
  Matrice = get(handles.Tabella,'data');
  Angoli=Matrice(:,2);
  Verniers=Matrice(:,4);
  PhotonE=Matrice(:,1);
  handles.PolinomioVerniers=pchip(PhotonE,Verniers);
  handles.PolinomioAngoli=pchip(PhotonE,Angoli);
  TE=linspace(min(PhotonE),max(PhotonE),50);
  plot(handles.axes1,TE,ppval(handles.PolinomioVerniers,TE));
  plot(handles.axes2,TE,ppval(handles.PolinomioAngoli,TE));
  set(handles.axes1,'xlim',[min(TE),max(TE)]);
  set(handles.axes2,'xlim',[min(TE),max(TE)]);
  set(handles.axes1,'ylim',[min(Verniers),max(Verniers)]);
  set(handles.axes2,'ylim',[min(Angoli),max(Angoli)]);
  
  set(handles.START,'enable','on');
  guidata(hObject, handles);
  set(handles.Correct,'foregroundcolor',[0,0,0]);
  drawnow
catch ME
  set(handles.START,'enable','off');
end

function GOTO_Callback(hObject, eventdata, handles)
% hObject    handle to GOTO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GOTO as text
%        str2double(get(hObject,'String')) returns contents of GOTO as a double


% --- Executes during object creation, after setting all properties.
function GOTO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GOTO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GOTO_Button.
function GOTO_Button_Callback(hObject, eventdata, handles)
NEWVALUE=str2num(get(handles.GOTO,'string'));
if(length(NEWVALUE)~=1)
  return
end
if(NEWVALUE<min(handles.PolinomioAngoli.breaks))
  return
end
if(NEWVALUE>max(handles.PolinomioAngoli.breaks))
  return
end
AnglePVDES='MIRR:UND1:936:P:MOTOR';
VernierPV='FBCK:FB04:LG01:DL2VERNIER';
SCANPVNAME='MCC:USR:PHOTON:ENERGY';
try
  NA=ppval(handles.PolinomioAngoli,NEWVALUE);
  NV=ppval(handles.PolinomioVerniers,NEWVALUE);
catch ME
  set(handles.State,'string','You have to set it up first');
  return
end
StateString=['Status',char(10),'Current Energy = ',num2str(NEWVALUE),char(10),'New Angle = ',num2str(NA),char(10),'New Vernier = ',num2str(NV)];
set(handles.State,'String',StateString,'FontWeight','normal');drawnow

if(get(handles.WritePVs,'value'))
  lcaPutNoWait(AnglePVDES,NA);
  lcaPutSmart(VernierPV,NV);
  lcaPut(SCANPVNAME,NEWVALUE);
else
  disp(['New Angle ->  ',num2str(NA)]);
  disp(['New Vernier ->  ',num2str(NV)]);
  disp(['New PhotonEnergy ->  ',num2str(NEWVALUE)]);
end


% --- Executes on selection change in SetupSteps.
function SetupSteps_Callback(hObject, eventdata, handles)
% hObject    handle to SetupSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SetupSteps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SetupSteps


% --- Executes during object creation, after setting all properties.
function SetupSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetupSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckScanValues.
function CheckScanValues_Callback(hObject, eventdata, handles)
set(handles.START,'enable','off');
set(handles.CheckScanValues,'enable','off');
set(handles.STOP,'enable','on');
SCANPVNAME='MCC:USR:PHOTON:ENERGY';

WritePVs=get(handles.WritePVs,'value');

NUMBEROFVALIDPOINTS=1000;
MINIMUMGDETVALUE=0.001;
READINGBLOCK=200;
PAUSE=1/960;
TOLERANCE=10^-3;

RAMPING=get(handles.RAMPING,'value');
NATEALGORITHMPv='SIOC:SYS0:ML00:AO98';

GDETPV='GDET:FEE1:241:ENRC';
ENERGYBPM='BPMS:LTU1:250:X';
PhotonEPV='SIOC:SYS0:ML00:AO500';

RB1=zeros(1,READINGBLOCK);
RB1ts=zeros(1,READINGBLOCK);
RB2=zeros(1,READINGBLOCK);
RB2ts=zeros(1,READINGBLOCK);

%read angle 
AnglePVACT='MIRR:UND1:936:P:ACT';
AnglePVDES='MIRR:UND1:936:P:MOTOR';
%CentralAngle=lcaGet(AnglePVACT);
%read vernier
VernierPV='FBCK:FB04:LG01:DL2VERNIER';
Dispersion=125;
ReturnAngle=lcaGet(AnglePVACT);
ReturnVernier=lcaGet(VernierPV);
CurrentEnergy=lcaGet(PhotonEPV);
POLANGOLI=handles.PolinomioAngoli;
POLVERNIERS=handles.PolinomioVerniers;
ENERGIES=handles.PolinomioAngoli.breaks;

NewAngles = ppval(POLANGOLI,ENERGIES);
NewVerniers = ppval(POLVERNIERS,ENERGIES);

if(WritePVs)
  lcaPutNoWait(AnglePVDES,NewAngles(1));
  lcaPutSmart(VernierPV,NewVerniers(1));
end
lcaPutSmart(SCANPVNAME,handles.PolinomioAngoli.breaks(1));
lcaPutSmart('SIOC:SYS0:ML02:AO309',1);

CurrentAngle=lcaGetSmart(AnglePVACT);
set(handles.State,'String',['Moving to ',num2str(NewAngles(1)),' / ',num2str(NewVerniers(1))]);
for KK=1:length(NewAngles)
    while( (abs(CurrentAngle - NewAngles(KK))>TOLERANCE))% || (lcaGetSmart(NATEALGORITHMPv) && RAMPING) )
      
      if(WritePVs)
        lcaPutNoWait(AnglePVDES,NewAngles(KK));
        lcaPutSmart(VernierPV,NewVerniers(KK));
        lcaPutSmart('SIOC:SYS0:ML02:AO309',1);
      end
      
      lcaPutSmart(SCANPVNAME,handles.PolinomioAngoli.breaks(KK));
      
      
      if ( (abs(CurrentAngle - NewAngles(KK))>TOLERANCE)  )
        grstr='Grating not arrived yet';
      else
        grstr='Grating is arrived';
        lcaPutSmart('SIOC:SYS0:ML02:AO309',0);
      end
      
      if ( RAMPING  )
        if(lcaGetSmart(NATEALGORITHMPv))
          rampstr='Ramping not arrived yet';
        else
          rampstr='Ramping is arrived';
        end
      else
        rampstr='Not ramping';
      end
      
      set(handles.State,'String',{['Moving to ',num2str(NewAngles(KK)),' / ',num2str(NewVerniers(KK))],grstr,rampstr});
      
      CurrentAngle=lcaGetSmart(AnglePVACT);
      pause(0.25);drawnow
      
      COLOR=get(handles.STOP,'Backgroundcolor') ;
      if(COLOR(1)==1)
       set(handles.STOP,'Backgroundcolor',[0.7,0.7,0.7]);drawnow
       set(handles.START,'enable','on');set(handles.CheckScanValues,'enable','on');
       set(handles.STOP,'enable','off');
       drawnow
       if(WritePVs)
        lcaPutNoWait(AnglePVDES,ReturnAngle);
        lcaPutSmart(VernierPV,ReturnVernier);
       end
       return
      end
      if(~WritePVs) %If you don't change pvs... it's never going to arrive...
        pause(0.5)
        break
      end
    end
    goodbpm=[];
    goodgdet=[];
    while(length(goodbpm)<=NUMBEROFVALIDPOINTS)
      COLOR=get(handles.STOP,'Backgroundcolor') ;
      if(COLOR(1)==1)
       set(handles.STOP,'Backgroundcolor',[0.7,0.7,0.7]);drawnow
       set(handles.START,'enable','on');set(handles.CheckScanValues,'enable','on');
       set(handles.STOP,'enable','off');
       drawnow
       if(WritePVs)
        lcaPutNoWait(AnglePVDES,ReturnAngle);
        lcaPutSmart(VernierPV,ReturnVernier);
       end
       return
      end
      
      for TT=1:READINGBLOCK
        [RB1(TT),RB1ts(TT)]=lcaGetSmart(GDETPV);
        [RB2(TT),RB2ts(TT)]=lcaGetSmart(ENERGYBPM);
        pause(PAUSE);
      end
      %First, match the timestamps
      TSGEDT=bitand(uint32(imag(RB1ts)),hex2dec('1FFFF'));
      TSBPM=bitand(uint32(imag(RB2ts)),hex2dec('1FFFF'));
      
      [UniqueID,WhereGDET,WhereBPM]=intersect(TSGEDT,TSBPM);
      
      GDETvalues=RB1(WhereGDET);
      BPMvalues=RB2(WhereBPM);

      HighGDET=find(GDETvalues>=MINIMUMGDETVALUE);
      BPMvalues=BPMvalues(HighGDET);
      GDETvalues=GDETvalues(HighGDET);
  
      goodbpm=[goodbpm,BPMvalues];
      goodgdet=[goodgdet,GDETvalues];
      
      set(handles.State,'string',['Getting Data ',num2str(length(goodgdet)),' / ',num2str(NUMBEROFVALIDPOINTS),char(32),char(13),'Intersect Size ',num2str(length(UniqueID))]);

    end
    
    figure(KK)
    
    STDK=std(goodbpm);
    KEEP= (goodbpm - mean(goodbpm) );
    KEEP= find(abs(KEEP)<(3*STDK));
    EnergiaMedia = mean(goodbpm(KEEP));
    EnergiaTenuti=goodbpm(KEEP);
    MostacciPV=goodgdet;
    MOSTACCITenuti=MostacciPV(KEEP);
    Bins=round(length(MOSTACCITenuti)/35);
    
    MIN=min(EnergiaTenuti);
    MAX=max(EnergiaTenuti);
    Indice=round(Bins*(EnergiaTenuti-MIN)/(MAX-MIN))+1;

    VettoreMedie=zeros(1,Bins+1);

    for SS=1:(Bins+1)
      try
      VettoreMedie(SS) = mean(MOSTACCITenuti(Indice==SS));
      end
    end

    [~,MP]=max(VettoreMedie);
    MigliorBPM=mean(EnergiaTenuti(Indice==MP));

    Differenza = MigliorBPM - EnergiaMedia;
    CambioVernier= Differenza/Dispersion*CurrentEnergy*1000;
    SuggestedVernier(KK) = NewVerniers(KK) + CambioVernier;
    plot(EnergiaTenuti,MOSTACCITenuti,'.')
    hold on
    plot([MigliorBPM,MigliorBPM],[min(MOSTACCITenuti),max(MOSTACCITenuti)],'k')
    plot([EnergiaMedia,EnergiaMedia],[min(MOSTACCITenuti),max(MOSTACCITenuti)],'r')
    title(['Moving to ',num2str(NewAngles(KK)),' / ',num2str(NewVerniers(KK)),' -> ',num2str(SuggestedVernier(KK))])
    hold off 
    
end

if(WritePVs)
    lcaPutNoWait(AnglePVDES,ReturnAngle);
    lcaPutSmart(VernierPV,ReturnVernier);   
end



set(handles.CheckScanValues,'Userdata',SuggestedVernier);
set(handles.STOP,'Backgroundcolor',[0.7,0.7,0.7]);drawnow
set(handles.START,'enable','on');set(handles.CheckScanValues,'enable','on');
set(handles.STOP,'enable','off');
set(handles.APPLY,'visible','on');


% --- Executes on button press in APPLY.
function APPLY_Callback(hObject, eventdata, handles)
MEASUREDVERNIER = get(handles.CheckScanValues,'Userdata');
CurrentValues = get(handles.Tabella,'data');
if(isrow(MEASUREDVERNIER))
  MEASUREDVERNIER=transpose(MEASUREDVERNIER);
end
CurrentValues(:,4)= MEASUREDVERNIER;
set(handles.Tabella,'data',CurrentValues);
handles=Correct_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in Tabella.
function Tabella_CellEditCallback(hObject, eventdata, handles)
set(handles.Correct,'foregroundcolor',[1,0,0]);
drawnow


% --- Executes on button press in SAVE.
function SAVE_Callback(hObject, eventdata, handles)
DatiMatrice=get(handles.Tabella,'data');
POLANGOLI=handles.PolinomioAngoli;
POLVERNIERS=handles.PolinomioVerniers;
save('/u1/lcls/matlab/config/SXRSS_SCAN_LATEST_CONFIGURATION','DatiMatrice','POLANGOLI','POLVERNIERS');


% --- Executes on button press in RESTORE.
function RESTORE_Callback(hObject, eventdata, handles)
try
load('/u1/lcls/matlab/config/SXRSS_SCAN_LATEST_CONFIGURATION','DatiMatrice','POLANGOLI','POLVERNIERS');
set(handles.Tabella,'data',DatiMatrice);
handles.PolinomioAngoli=POLANGOLI;
handles.PolinomioVerniers=POLVERNIERS;
set(handles.CheckScanValues,'enable','on');
set(handles.START,'enable','on');
guidata(hObject, handles);
catch ME
  disp('FILE not found or corrupted')
end


% --- Executes on button press in RAMPING.
function RAMPING_Callback(hObject, eventdata, handles)
% hObject    handle to RAMPING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RAMPING
