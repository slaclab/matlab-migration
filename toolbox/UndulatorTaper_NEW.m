function varargout = UndulatorTaper_NEW(varargin)
% UNDULATORTAPER_NEW M-file for UndulatorTaper_NEW.fig
%      UNDULATORTAPER_NEW, by itself, creates a new UNDULATORTAPER_NEW or raises the existing
%      singleton*.
%
%      H = UNDULATORTAPER_NEW returns the handle to a new UNDULATORTAPER_NEW or the handle to
%      the existing singleton*.
%
%      UNDULATORTAPER_NEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDULATORTAPER_NEW.M with the given input arguments.
%
%      UNDULATORTAPER_NEW('Property','Value',...) creates a new UNDULATORTAPER_NEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UndulatorTaper_NEW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UndulatorTaper_NEW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UndulatorTaper_NEW

% Last Modified by GUIDE v2.5 21-Nov-2014 11:52:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UndulatorTaper_NEW_OpeningFcn, ...
                   'gui_OutputFcn',  @UndulatorTaper_NEW_OutputFcn, ...
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


% --- Executes just before UndulatorTaper_NEW is made visible.
function UndulatorTaper_NEW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UndulatorTaper_NEW (see VARARGIN)

global timerRunning;
global timerRestart;
global timerDelay;
global timerData;
global debug;
global hh;
global OPctrl;
%global APointer

handles.fb                  = '/u1/lcls/matlab/UndulatorTaperControl_gui/';
OPctrl.bufSize              = 20;                           % Number of integration samples for peak current averaging.
OPctrl.IpkBuf               = zeros ( 1, OPctrl.bufSize );
OPctrl.Ipklvl               = 0;

%try 
    handles.PhyConsts           = util_PhysicsConstants;
    handles.UndConsts           = util_UndulatorConstants;
    Online_Mode=1;
    handles=DeltaPvNames( handles );
    guidata ( hObject, handles );
%     
% catch notonline
%     Online_Mode=0;
%     load Costanti PhyConsts UndConsts
%     handles.PhyConsts=PhyConsts;
%     handles.UndConsts=UndConsts;
%     A=figure; 
%     APointer=A; 
%     save ThisSessionPointer APointer 
%     DegubOfflinePvList(handles);
%     handles=DeltaPvNames( handles ); %loads all the pvnames for the delta and relevant variables
%     writesomepvs %COMM
% end

timerRunning                = false;
timerRestart                = false;
timerDelay                  = 4;      % s
timerData.hObject           = hObject;
debug                       = false;

handles.printTo_e_Log       = true;
handles.printTo_Files       = true;

%if ( isnan ( lcaGet ( 'YAGS:DMP1:500:FOIL1_PNEU', 0, 'double' ) ) )
    handles.YAGXRAYavailable = false;
    fprintf ( 'YAGXRAY is not available. Continuing without ...\n' );
%else
%    handles.YAGXRAYavailable = true;
%end

% Choose default command line output for UndulatorTaper_NEW
handles.output              = hObject;
handles.Segments            = 33;
handles.EnergyLoss          = cell ( handles.Segments );
handles.dZ                  = 1033.340493;  % m z-Offset between LCLS and Station-100 Corrdinate system
handles.SegmentFieldLength  = handles.UndConsts.SegmentPeriods * handles.UndConsts.lambda_u;     % m
handles.isInstalled         = zeros ( 1, handles.Segments );
handles.moving_fstK         = false;
handles.LTU_Wake_Loss       = 30.0; % MeV

% For reason of compatibility, never change IDs, just add numbers.

handles.ID_ADD_GAIN_TAPER_BOX            =  1;
handles.ID_GAIN_TAPER_START_SEGMENT      =  2;
handles.ID_GAIN_TAPER_END_SEGMENT        =  3;
handles.ID_GAIN_TAPER_AMPLITUDE          =  4;
handles.ID_ADD_POST_SATURATION_TAPER_BOX =  5;
handles.ID_POST_TAPER_START_SEGMENT      =  6;
handles.ID_POST_TAPER_END_SEGMENT        =  7;
handles.ID_POST_TAPER_AMPLITUDE          =  8;

handles.ID_POST_TAPER_TYPE               =  9;
handles.ID_POST_TAPER_LG                 = 10;
handles.ID_USE_SPONT_RAD_BOX             = 11;
handles.ID_USE_WAKEFIELDS_BOX            = 12;
handles.ID_SET_ENERGY                    = 13;
handles.ID_SET_BUNCH_CHARGE              = 14;
handles.ID_SET_PEAK_CURRENT              = 15;
handles.ID_COMPRESSION_STATUS            = 16;
handles.ID_AUTOMOVE                      = 17;

handles.presentTaperParms { handles.ID_ADD_GAIN_TAPER_BOX }.PV              = 'SIOC:SYS0:ML00:AO422';
handles.presentTaperParms { handles.ID_GAIN_TAPER_START_SEGMENT }.PV        = 'SIOC:SYS0:ML00:AO423';
handles.presentTaperParms { handles.ID_GAIN_TAPER_END_SEGMENT }.PV          = 'SIOC:SYS0:ML00:AO424';
handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.PV            = 'SIOC:SYS0:ML00:AO425';
handles.presentTaperParms { handles.ID_ADD_POST_SATURATION_TAPER_BOX }.PV   = 'SIOC:SYS0:ML00:AO426';
handles.presentTaperParms { handles.ID_POST_TAPER_START_SEGMENT }.PV        = 'SIOC:SYS0:ML00:AO427';
handles.presentTaperParms { handles.ID_POST_TAPER_END_SEGMENT }.PV          = 'SIOC:SYS0:ML00:AO428';
handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.PV            = 'SIOC:SYS0:ML00:AO429';
handles.presentTaperParms { handles.ID_AUTOMOVE }.PV                        = 'SIOC:SYS0:ML00:AO430';

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE }.PV                 = 'SIOC:SYS0:ML00:AO411'; 
handles.presentTaperParms { handles.ID_POST_TAPER_LG }.PV                   = 'SIOC:SYS0:ML00:AO412'; 
handles.presentTaperParms { handles.ID_USE_SPONT_RAD_BOX }.PV               = 'SIOC:SYS0:ML00:AO413'; 
handles.presentTaperParms { handles.ID_USE_WAKEFIELDS_BOX }.PV              = 'SIOC:SYS0:ML00:AO414'; 
handles.presentTaperParms { handles.ID_SET_ENERGY }.PV                      = 'SIOC:SYS0:ML00:AO415'; 
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE }.PV                = 'SIOC:SYS0:ML00:AO416'; 
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT }.PV                = 'SIOC:SYS0:ML00:AO417'; 
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.PV              = 'SIOC:SYS0:ML00:AO418'; 

handles.presentTaperParms { handles.ID_ADD_GAIN_TAPER_BOX }.str             = false;
handles.presentTaperParms { handles.ID_GAIN_TAPER_START_SEGMENT }.str       = true;
handles.presentTaperParms { handles.ID_GAIN_TAPER_END_SEGMENT }.str         = true;
handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.str           = true;
handles.presentTaperParms { handles.ID_ADD_POST_SATURATION_TAPER_BOX }.str  = false;
handles.presentTaperParms { handles.ID_POST_TAPER_START_SEGMENT }.str       = true;
handles.presentTaperParms { handles.ID_POST_TAPER_END_SEGMENT }.str         = true;
handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.str           = true;
handles.presentTaperParms { handles.ID_AUTOMOVE }.str                       = false;

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE }.str                = false; 
handles.presentTaperParms { handles.ID_POST_TAPER_LG }.str                  = false; 
handles.presentTaperParms { handles.ID_USE_SPONT_RAD_BOX }.str              = false; 
handles.presentTaperParms { handles.ID_USE_WAKEFIELDS_BOX }.str             = false; 
handles.presentTaperParms { handles.ID_SET_ENERGY }.str                     = false; 
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE }.str               = false; 
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT }.str               = false; 
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.str             = false; 
 
handles.presentTaperParms { handles.ID_ADD_GAIN_TAPER_BOX }.hobj            = handles.ADD_GAIN_TAPER_BOX;
handles.presentTaperParms { handles.ID_GAIN_TAPER_START_SEGMENT }.hobj      = handles.GAIN_TAPER_START_SEGMENT;
handles.presentTaperParms { handles.ID_GAIN_TAPER_END_SEGMENT }.hobj        = handles.GAIN_TAPER_END_SEGMENT;
handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.hobj          = handles.GAIN_TAPER_AMPLITUDE;
handles.presentTaperParms { handles.ID_ADD_POST_SATURATION_TAPER_BOX }.hobj = handles.ADD_POST_SATURATION_TAPER_BOX;
handles.presentTaperParms { handles.ID_POST_TAPER_START_SEGMENT }.hobj      = handles.POST_TAPER_START_SEGMENT;
handles.presentTaperParms { handles.ID_POST_TAPER_END_SEGMENT }.hobj        = handles.POST_TAPER_END_SEGMENT;
handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.hobj          = handles.POST_TAPER_AMPLITUDE;
handles.presentTaperParms { handles.ID_AUTOMOVE }.hobj                      = handles.AUTO_MOVE_CHECKBOX;

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE }.hobj               = handles.POST_TAPER_MENU; 
handles.presentTaperParms { handles.ID_POST_TAPER_LG }.hobj                 = handles.POST_TAPER_LG; 
handles.presentTaperParms { handles.ID_USE_SPONT_RAD_BOX }.hobj             = handles.USE_SPONT_RAD_BOX; 
handles.presentTaperParms { handles.ID_USE_WAKEFIELDS_BOX }.hobj            = handles.USE_WAKEFIELDS_BOX; 
handles.presentTaperParms { handles.ID_SET_ENERGY }.hobj                    = handles.SET_ENERGY_RADIO_BTN; 
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE }.hobj              = handles.SET_BUNCH_CHARGE_RADIO_BTN; 
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT }.hobj              = handles.SET_PEAK_CURRENT_RADIO_BTN; 
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.hobj            = handles.COMPRESSION_STATUS; 

handles.ntps = length ( handles.presentTaperParms );
handles.DeltaUndulatorList={};

for j = 1 : handles.ntps
    handles.presentTaperParms { j }.set_callback = '';
    handles.presentTaperParms { j }.get_callback = '';
end

handles.presentTaperParms { handles.ID_POST_TAPER_TYPE    }.set_callback    = 'setPostTaperType';
handles.presentTaperParms { handles.ID_SET_ENERGY         }.set_callback    = 'setRadioButton';
handles.presentTaperParms { handles.ID_SET_BUNCH_CHARGE   }.set_callback    = 'setRadioButton';
handles.presentTaperParms { handles.ID_SET_PEAK_CURRENT   }.set_callback    = 'setRadioButton';
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.set_callback    = 'setCompressionStatus';
handles.presentTaperParms { handles.ID_COMPRESSION_STATUS }.get_callback    = 'getCompressionStatus';
handles.presentTaperParms { handles.ID_AUTOMOVE           }.set_callback    = 'setAutomoveStatus';

handles.PostTaperModes    = { 'Linear', 'Quadratic', 'Exponential' };
handles.PostTaperLinearID = 1;
handles.PostTaperSquareID = 2;
handles.PostTaperExpontID = 3;

set ( handles.POST_TAPER_MENU, 'String', handles.PostTaperModes );

handles                     = getKcoeffs ( handles );
handles.slideAdjust         = getSlideAdjusts;
hh                          = handles;

handles.initialDate         = sprintf ( '%s', datestr ( now,'mm/dd/yyyy HH:MM:SS' ) );

set ( handles.GAIN_TAPER_SOFT_PV, 'String', handles.presentTaperParms { handles.ID_GAIN_TAPER_AMPLITUDE }.PV );
set ( handles.POST_TAPER_SOFT_PV, 'String', handles.presentTaperParms { handles.ID_POST_TAPER_AMPLITUDE }.PV );
set ( handles.AUTOMOVE_SOFT_PV,   'String', handles.presentTaperParms { handles.ID_AUTOMOVE }            .PV );

set ( handles.MODEL_BEAM_ENERGY,  'String', lcaGet ( sprintf ( 'SIOC:SYS0:ML00:AO122' ) ) );
set ( handles.MODEL_BUNCH_CHARGE, 'String', lcaGet ( sprintf ( 'SIOC:SYS0:ML00:AO104' ) ) * 1e3 );
set ( handles.MODEL_PEAK_CURRENT, 'String', lcaGet ( sprintf ( 'SIOC:SYS0:ML00:AO188' ) ) );

if ( handles.printTo_Files || handles.printTo_e_Log )
    handles.log_fig  = figure ( 'Visible', 'Off' );
    handles.log_axes = axes;
end

for slot = 1 : handles.Segments
    handles.UndConsts.Z_US { slot }   = handles.UndConsts.Z_US { slot } + handles.dZ;
    handles.EnergyLoss { slot }.z_ini = handles.UndConsts.Z_US { slot } - handles.SegmentFieldLength / 2;
    handles.EnergyLoss { slot }.z_end = handles.UndConsts.Z_US { slot } + handles.SegmentFieldLength / 2;
    try
        handles.isInstalled ( slot )  = lcaGet ( sprintf ( 'USEG:UND1:%d50:INSTALTNSTAT', slot ), 0, 'double' );
        handles.Type(slot) = getHarm ( slot );
        if(handles.Type(slot)==handles.DeltaType) %there is a delta ! writes a list of all the delta undulators installed
            handles.DeltaUndulatorList{end+1}=sprintf ( '%d50', slot);
        end
    catch       
        handles.isInstalled ( slot )  = 0;
        handles.Type(slot) = NaN;
    end
end

set(handles.TAPERDISPLAY,'userdata',1);

%Main part for the delta setup
%Before loading K values needs all the delta names!
set(handles.Open_DeltaPanel,'enable','off'); set(handles.DeltaActiveString,'userdata',0);
% This sets up for the Delta
if(numel(handles.DeltaUndulatorList))
    load PureModeFits PureModeFits
    load FreeFitParameters2 FreeFit
    load UnifiedMode AdditionalDisplacement
    set(handles.KindOfFit,'Value',1);
    set(handles.Open_DeltaPanel,'enable','on'); set(handles.DeltaActiveString,'userdata',1);
    for KK=1:numel(handles.DeltaUndulatorList) %build pv names list
        handles.DeltaUndulatorFits{KK}.PureModeFits=PureModeFits;
        handles.DeltaUndulatorFits{KK}.FreeFit=FreeFit;
        handles.DeltaUndulatorFits{KK}.AdditionalDisplacement=AdditionalDisplacement;
        handles.SlotToDeltaUndulatorsConversion(str2double(handles.DeltaUndulatorList{KK}(1:2)))=KK;
        for JJ=1:handles.NumberOfDeltaParameters
            for LL=1:11
                if((LL==9) || (LL==10))
                    handles.AllDeltaUndulators{KK,JJ,LL}=regexprep(handles.DeltaPvNamesCell{JJ,LL},'3350',handles.DeltaUndulatorList{KK});
                else
                    handles.AllDeltaUndulators{KK,JJ,LL}=handles.DeltaPvNamesCell{JJ,LL};
                end
            end
        end
        %This adds off pvs and may add more pvs if needed in future
        for JJ=(handles.NumberOfDeltaParameters+1):(handles.NumberOfDeltaParameters +  handles.NumberOfDeltaSpecialPVs)
            for LL=1:4
                if(ischar(handles.DeltaPvNamesCell{JJ,LL}))
                    handles.AllDeltaUndulators{KK,JJ,LL}=regexprep(handles.DeltaPvNamesCell{JJ,LL},'3350',handles.DeltaUndulatorList{KK});
                else
                    handles.AllDeltaUndulators{KK,JJ,LL}=handles.DeltaPvNamesCell{JJ,LL};
                end
            end
        end
        for LL=1:11
             handles.AllDeltaUndulators{KK,JJ+1,LL}=regexprep(handles.PhaseShifterNamesCell{1,LL},'3350',[handles.DeltaUndulatorList{KK}(1:2),'4',handles.DeltaUndulatorList{KK}(4)]);
        end
    end
    if(~Online_Mode)
      %writesomepvs %COMM
    end
    set(handles.WhichDeltaUndulator,'String',handles.DeltaUndulatorList);
    set(handles.WhichDeltaUndulator,'value',1);
    disp(handles.AllDeltaUndulators{1,handles.NumberOfDeltaParameters+1,1})
    IsFirstDeltaOff=strcmpi(lcaGet(handles.AllDeltaUndulators{1,handles.NumberOfDeltaParameters+1,1}),'Off');
    if(IsFirstDeltaOff)
        set(handles.DeltaOffButton,'userdata',1); set(handles.MoveButton,'enable','off'); set(handles.Deltalistenbutton,'enable','off');
        set(handles.DeltaActiveString,'String','Delta is OFF','backgroundcolor',[1,1,0]);
    else
        set(handles.DeltaOffButton,'userdata',0); set(handles.MoveButton,'enable','on'); set(handles.Deltalistenbutton,'enable','on');
        set(handles.DeltaActiveString,'String','Delta is ON','backgroundcolor',[0,1,0]);
    end
    %Should Try to fill up PVs for each undulator for zmax, zmin (each
    %row), Kmax, Undulator Period, if it doesn't work, just set default
    %value
    
    for KK=1:numel(handles.DeltaUndulatorList)
        try %Reads maximum and minimum z from each row of the undulator, default is +/-17
            for JJ=1:4
                Minimum(JJ)=lcaGet([handles.AllDeltaUndulators{KK,10+JJ,9},'.LOPR']);
                Maximum(JJ)=lcaGet([handles.AllDeltaUndulators{KK,10+JJ,9},'.HOPR']);
                handles.AllDeltaUndulators{KK,10+JJ,2}=Minimum(JJ);
                handles.AllDeltaUndulators{KK,10+JJ,3}=Maximum(JJ);
            end
            handles.AllDeltaUndulators{KK,6,2}=max(Minimum); handles.AllDeltaUndulators{KK,6,3}=min(Maximum);
            handles.AllDeltaUndulators{KK,7,2}=-2*min([abs(Minimum),abs(Maximum)]); handles.AllDeltaUndulators{KK,7,3}=-handles.AllDeltaUndulators{KK,7,2};
            handles.AllDeltaUndulators{KK,8,2}=-min(abs([Minimum,abs(Maximum)])); handles.AllDeltaUndulators{KK,8,3} = - handles.AllDeltaUndulators{KK,8,2};
            handles.AllDeltaUndulators{KK,9,2}=-2*min([abs(Minimum),abs(Maximum)]); handles.AllDeltaUndulators{KK,9,3}=-handles.AllDeltaUndulators{KK,9,2};
            handles.AllDeltaUndulators{KK,10,2}=-min(abs([Minimum,abs(Maximum)])); handles.AllDeltaUndulators{KK,10,3} = - handles.AllDeltaUndulators{KK,10,2};
        catch ME
            %Uses Default values.
        end
        try %Reads Max K and Undulator period from the undulator.
            handles.AllDeltaUndulators{KK,17,2}=lcaGet(handles.AllDeltaUndulators{KK,17,1});
            handles.AllDeltaUndulators{KK,17,4}=lcaGet(handles.AllDeltaUndulators{KK,17,3});
        catch ME
            
        end
        %handles.AllDeltaConstants(KK).lambda_u=handles.AllDeltaUndulators{KK,17,4};
        handles.AllDeltaConstants(KK).lambda_u=32;
        %handles.AllDeltaConstants(KK).KMax=handles.AllDeltaUndulators{KK,17,2};
        handles.AllDeltaConstants(KK).KMax=3.6461;
        %handles.AllDeltaConstants(KK).Zmin=max([handles.AllDeltaUndulators{KK,11:14,2}]);
        handles.AllDeltaConstants(KK).Zmin=-17;
        %handles.AllDeltaConstants(KK).Zmax=min([handles.AllDeltaUndulators{KK,11:14,3}]);
        handles.AllDeltaConstants(KK).Zmax=17;
%         try %% Override this until there are no meaningful numbers !!
%         handles.AllPhaseShifters(KK).minimum=lcaGet(handles.AllDeltaUndulators{KK,handles.FirstPhaseShifterPVLocation,4});
%         handles.AllPhaseShifters(KK).maximum=lcaGet(handles.AllDeltaUndulators{KK,handles.FirstPhaseShifterPVLocation,5});
%         handles.AllPhaseShifters(KK).encminimum=lcaGet(handles.AllDeltaUndulators{KK,handles.FirstPhaseShifterPVLocation,9});
%         handles.AllPhaseShifters(KK).encmaximum=lcaGet(handles.AllDeltaUndulators{KK,handles.FirstPhaseShifterPVLocation,10});
%         end
        handles.AllPhaseShifters(KK).minimum=10000;
        handles.AllPhaseShifters(KK).maximum=100000;
        handles.AllPhaseShifters(KK).encminimum=10000;
        handles.AllPhaseShifters(KK).encmaximum=100000;
    end
else
    set(handles.Open_DeltaPanel,'enable','off');
end

%End of the main part for the delta setup

handles.initialKvalues      = loadPresentKvalues ( handles );
handles.referenceDate       = handles.initialDate;
handles.referenceKvalues    = handles.initialKvalues;
handles.fstSegment   = findFirstSegment ( handles.Segments, handles );
try
fstK                 = getEquivalentKvalue ( handles.fstSegment, handles );
catch 
    fstK=3.5
end

%fstK = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', handles.fstSegment ) );
set ( handles.FST_K, 'String', sprintf ( '%6.4f', fstK ) );
set ( handles.FST_K, 'Value',  fstK );

manageBeamEnergyRadioButtons  ( handles, 2 )
manageBunchChargeRadioButtons ( handles, 2 )
managePeakCurrentRadioButtons ( handles, 2 )

automove_state = lcaGet ( [handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'] ); %Read Matlab PV to see if automove is enabled by any instance; JR 4/15/11

if ( automove_state )
    resp = questdlg ( 'Keep K values at red line is enabled. Change?', 'Autoadjust K', 'Enable', 'Disable', 'Disable' );
    set ( handles.AUTO_MOVE_CHECKBOX, 'Value', strcmp ( resp, 'Enable' ) );
end

AUTO_MOVE_CHECKBOX_Callback ( hObject, eventdata, handles );

set(handles.Deltalistenbutton,'UserData',0); set(handles.Deltalistenbutton,'String','Listening for scans: OFF');
set(handles.SynchronizeDesActAlways,'UserData',0); set(handles.SynchronizeDesActAlways,'String','Always Synch. In.: OFF');

% Additional Set-up for the delta
if (get(handles.DeltaActiveString,'userdata'))
    deltaslot=1;
    SynchronizaDesActOnce_Callback(hObject, eventdata, handles);
    handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
    DeltaResetScan_Callback(hObject, eventdata, handles);
end
%here finishes the additional setup for the delta

handles.ColorOff=get(handles.DeltaResetScan,'backgroundcolor');
handles.ColorOn=[0,1,0.3];

% This sets up for the iSASE
handles.iSASEConsts.iSASETaperScanName='SIOC:SYS0:ML02:AO350'; %This is the pv used for iSASE scans
iSASETableData=zeros(handles.Segments,4);
SelectableUndulators=logical(handles.isInstalled) & logical(handles.Type);
iSASETableData(SelectableUndulators,2)=handles.initialKvalues(SelectableUndulators);
iSASETableData(~SelectableUndulators,2)=NaN; iSASETableData(SelectableUndulators,3)=handles.initialKvalues(SelectableUndulators);
iSASETableData(~SelectableUndulators,3)=NaN; iSASETableData(SelectableUndulators,4)=0;
iSASETableData(~SelectableUndulators,4)=NaN; iSASETableData=mat2cell(iSASETableData,ones(handles.Segments,1),ones(1,4));
RowName=cell(handles.Segments,1);
ColumnName={'Select','Actual','Desired','Differ'};
for slot=1:handles.Segments
   if(handles.Type(slot)==1)
       RowName{slot}=['U',num2str(slot)];iSASETableData{slot,1}=true;
   elseif((handles.Type(slot)>1) && (handles.Type(slot)<=99))
       RowName{slot}=[num2str(handles.Type(slot)),'H',num2str(slot)];iSASETableData{slot,1}=true;
   elseif(handles.Type(slot)==handles.DeltaType) %This is a delta
       RowName{slot}=['D',num2str(slot)];iSASETableData{slot,1}=true;
   else
       RowName{slot}='';iSASETableData{slot,1}=false;
   end
end
set(handles.iSASE_State,'ColumnName',ColumnName); set(handles.iSASE_State,'RowName',RowName); set(handles.InandOutTable,'RowName',RowName);
UpdateInAndOutTable(handles); set(handles.iSASE_State,'data',iSASETableData);
set(handles.iSASE_ScanType,'backgroundcolor',[1,1,1],'Fontweight','normal');
set(handles.Open_DeltaPanel,'backgroundcolor',handles.ColorOff); set(handles.Open_iSASEpanel,'backgroundcolor',handles.ColorOff);set(handles.Open_StandardPanel,'backgroundcolor',handles.ColorOn);
set(handles.iSASE_ListeningMode,'backgroundcolor',handles.ColorOff); set(handles.iSASE_ListeningMode,'string','Listening Mode is OFF');
set(handles.uipanel9,'visible','off'); set(handles.uipanel8,'visible','off');set(handles.uipanel15,'visible','on');
set(handles.Open_DeltaPanel,'UserData',0); set(handles.Open_iSASEpanel,'UserData',0);set(handles.Open_StandardPanel,'UserData',1);
set(handles.iSASE_ListeningMode,'backgroundcolor',handles.ColorOff); set(handles.iSASE_ListeningMode,'string','Listening Mode is OFF'); set(handles.iSASE_ListeningMode,'UserData',0);
set(handles.iSASE_Scan_Pv_Name,'String',handles.iSASEConsts.iSASETaperScanName); set(handles.iSASEScansStartPosition,'string',''); set(handles.iSASEScansCurrentPosition,'string','');
set(handles.iSASE_Absolute_c,'value',1); set(handles.iSASE_relative_c,'value',0);
iSASE_Enable_All(handles, 1);set(handles.iSASE_undo,'enable','off');
% Here finishes the iSASE setup part

%In and Out setup
reset_in_and_out_buttons(handles);

guidata ( hObject, handles );

timerData.handles = handles;
handles           = updateDisplay ( handles );

% Update handles structure
guidata ( hObject, handles );

% UIWAIT makes UndulatorTaper_NEW wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end


% --- Outputs from this function are returned to the command line.
function varargout = UndulatorTaper_NEW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

% Get default command line output from handles structure
varargout { 1 } = handles.output;

handles.presentTaperParms   = loadTaperParmsFromSOFTPVs ( handles.presentTaperParms );
handles.initialTaperParms   = handles.presentTaperParms;

setContinuousRefreshMode ( handles );

timerData.handles = handles;

% Update handles structure
guidata ( hObject, handles );

end


function listTaperParms ( Parms )

for j = 1 : length ( Parms )
    PV = Parms { j }.PV;
    vl = Parms { j }.VAL;
    
    fprintf ( '%2.2d: PV %s -> %f.\n', j, PV, vl );
end

end


function new_Parms = writeTaperParmsFromStruct ( Parms )

for j = 1 : length ( Parms )
    parm2gui  ( Parms { j }.VAL, Parms { j } );
    setSOFTPV ( Parms, j );
end

new_Parms = Parms;

end


function new_Parms = readTaperParmsToStruct ( Parms )

for j = 1 : length ( Parms )
    Parms { j }.VAL = gui2parm ( Parms { j } );
end

new_Parms = Parms;

end


function new_Parms = loadTaperParmsFromSOFTPVs ( Parms )

for j = 1 : length ( Parms )
    Parms = loadSOFTPV ( Parms, j );
end

new_Parms = Parms;

end


function writeTaperParmsToSOFTPVs ( Parms )

for j = 1 : length ( Parms )
    setSOFTPV ( Parms, j );
end

end


function new_Parms = loadSOFTPV ( Parms, ID )

PV      = Parms { ID }.PV;
success = true;

try
    vl = lcaGet ( strcat ( PV, '.VAL' ) );
catch
    fprintf ( 'Unable to get taper parameter PV %s.\n', PV );
    success = false;
end

if ( success )
    parm2gui ( vl, Parms { ID } );
    Parms { ID }.VAL = vl;
end

new_Parms = Parms;

end


function parm2gui ( value, parm )

hObject = parm.hobj;

if ( any ( parm.set_callback ) )
    f = str2func ( parm.set_callback );
    f ( hObject, value );
else
    if  ( parm.str )
        set ( hObject, 'String', sprintf ( '%.0f', value ) );
    else
        set ( hObject, 'Value', value );
    end
end

end


function value = gui2parm ( parm )

hObject = parm.hobj;

if ( any ( parm.get_callback ) )
    f = str2func ( parm.get_callback );
    value = f ( hObject );
else
    if  ( parm.str )
        value = str2double ( get ( hObject, 'String' ) );
    else
        value = get ( hObject, 'Value' );
    end
end

end


 function setRadioButton ( hObject, value )

global timerData;

handles = timerData.handles;

switch hObject
    case handles.SET_ENERGY_RADIO_BTN
        manageBeamEnergyRadioButtons  ( handles, value + 1 )
    case handles.SET_BUNCH_CHARGE_RADIO_BTN
        manageBunchChargeRadioButtons ( handles, value + 1 )
    case handles.SET_PEAK_CURRENT_RADIO_BTN
        managePeakCurrentRadioButtons ( handles, value  + 1 );
end

end


function setCompressionStatus ( hObject, value )

global timerData;

handles = timerData.handles;

if ( value == 2 )
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Overcompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Undercompression' );
else
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Undercompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Overcompression' );
end

end

function setAutomoveStatus ( hObject, value )

global timerData;

handles = timerData.handles;

if ( lcaGet ( [handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'] ) == 0 )
    set ( handles.AUTO_MOVE_CHECKBOX, 'Value', 0);
%     AUTO_MOVE_CHECKBOX_Callback(handles.AUTO_MOVE_CHECKBOX, [], handles);
end

end

function value = getCompressionStatus ( hObject )

COMPRESSION_STATUS = get ( hObject, 'String' );

if ( strfind ( upper ( COMPRESSION_STATUS ), 'UNDER' ) )
    value = 1;
else
    value = 2;
end

end


function setPostTaperType ( hObject, value )
global timerData;

handles = timerData.handles;

set ( hObject, 'Value', value );

manageTaperTypeMenu ( handles )

end


function setSOFTPV ( Parms, ID )

PV = Parms { ID }.PV;
vl = gui2parm ( Parms { ID } );

try
    lcaPut ( strcat ( PV, '.VAL' ), vl );
catch
    fprintf ( 'Unable to set taper parameter PV %s to %f.\n', PV, vl );
end

end


% --- Executes on button press in SAVE_REFERENCE_BTN.
function SAVE_REFERENCE_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SAVE_REFERENCE_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

handles.referenceDate    = sprintf ( '%s', datestr ( now,'mm/dd/yyyy HH:MM:SS' ) );
handles.referenceKvalues = loadPresentKvalues ( handles );

%handles                     = updateDisplay ( handles );

%if ( isfield ( handles, 'fstSegment' ) )
%    if ( isActive ( handles.fstSegment ) && newKvalue > 0 )        
%        x = setKofSlot ( handles, newKvalue, handles.fstSegment );
%    end
%end

handles           = saveData ( handles );
timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


function new_handles = saveData ( handles )

new_handles                  = handles;
new_handles.referenceXvalues = zeros ( 1, new_handles.Segments );

for slot = 1 : new_handles.Segments
    new_handles.referenceXvalues ( slot ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:TM2MOTOR.RBV', slot ) );
end

refDate         = now;
[ fp, success ] = createFolder ( new_handles.fb, refDate );

if  ( success )    
    new_handles.fp     = fp;
    new_handles.fn     = sprintf ( 'TaperCtrl_%05.0fMeV_%04.0fpC--%s.mat', ...
                                   new_handles.ActualBeamEnergy * 1e3, ...
                                   new_handles.BunchCharge, ...
                                   datestr ( now,'yyyy-mm-dd-HHMMSS' ) );
    new_handles.fd     = sprintf ( '%s%s', new_handles.fp, new_handles.fn );
    save ( new_handles.fd, 'handles' );
    
    fprintf ( 'Saved data to %s\n', new_handles.fn ); 
else
    fprintf ( 'Unable to save data.\n' ); 
end

end


function [ path, success ] = createFolder ( base, refDate )

path    = sprintf ( '%s%s/%s/%s/', base, datestr ( refDate, 'yyyy' ), datestr ( refDate, 'yyyy-mm' ), datestr ( refDate, 'yyyy-mm-dd' ) );
success = true;

if ( exist ( path, 'dir' ) )
    return;
else
    mkdir ( path )
end

if ( ~exist ( path, 'dir' ) )
    success = false;
    return;
end

end


% --- Executes on button press in RESTORE_REFERENCE_BTN.
function RESTORE_REFERENCE_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to RESTORE_REFERENCE_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

%listTaperParms ( handles.referenceTaperParms );
%listTaperParms ( handles.presentTaperParms   );

%handles.presentTaperParms = writeTaperParmsFromStruct ( handles.referenceTaperParms );
%handles                   = updateDisplay ( handles );

if ( ~isfield ( handles, 'fn' ) )
%    handles.fn = 'UndulatorTaperControl--2009-05-04-233809.mat';
    handles.fn = 'TaperCtrl_13700Mev_0250pC--2009-05-04-233809.mat';
end

%handles.FilterSpec  = sprintf ( '%sUndulatorTaperControl--*.mat', handles.fb );
%handles.FilterSpec  = sprintf ( '%sTaperCtrl_*.mat', handles.fb );
refDate         = now;
handles.FilterSpec  = sprintf ( '%sTaperCtrl_*.mat', getFilterSpec ( handles.fb, refDate ) );
handles.DialogTitle = 'DialogTitle';

%FilterSpec = handles.FilterSpec;

success = true;

try
    [ FileName, PathName, FilterIndex ] = uigetfile ( handles.FilterSpec, handles.DialogTitle, '' );
catch
    success = false;
end

if ( ~success )
    return;
end

if ( ~FileName )
    return;
end

handles.LastRestore_fd   = sprintf ( '%s%s', PathName, FileName );
saved                    = load ( handles.LastRestore_fd );
handles.referenceKvalues = saved.handles.referenceKvalues;

setKvalues ( handles, handles.referenceKvalues );

%listTaperParms ( handles.presentTaperParms   );

timerData.handles = handles;

% Update handles structure
guidata ( hObject, handles );

end


function FilterSpec = getFilterSpec ( base, refDate )
	FilterSpec  = sprintf ( '%s%s/%s/%s/', base, datestr ( refDate, 'yyyy' ), datestr ( refDate, 'yyyy-mm' ), datestr ( refDate, 'yyyy-mm-dd' ) );
    
    if ( exist ( FilterSpec, 'dir' ) )
        return;
    end
    
	FilterSpec  = sprintf ( '%s%s/%s/', base, datestr ( refDate, 'yyyy' ), datestr ( refDate, 'yyyy-mm' ) );
    
    if ( exist ( FilterSpec, 'dir' ) )
        return;
    end
    
	FilterSpec  = sprintf ( '%s%s/', base, datestr ( refDate, 'yyyy' ) );
    
    if ( exist ( FilterSpec, 'dir' ) )
        return;
    end
    
	FilterSpec  = base;
end


% --- Executes on button press in RESTORE_INITIAL_BTN.
function RESTORE_INITIAL_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to RESTORE_INITIAL_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global timerData;

setKvalues ( handles, handles.initialKvalues );
%handles.presentTaperParms = writeTaperParmsFromStruct ( handles.initialTaperParms );
%handles                   = updateDisplay ( handles );

%timerData.handles = handles;

% Update handles structure
%guidata ( hObject, handles );

end


function setContinuousRefreshMode ( handles )

global timerObj;
global timerDelay;
global timerRestart;
global timerRunning;
global timerData;
global debug

if ( debug )
    fprintf ( 'setContinousRefreshMode called.\n' );
end

if ( timerRunning )
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
end

if ( debug )
    fprintf ( 'Setting Timer Delay to %.0f sec.\n', timerDelay );
end

timerObj     = timer ( 'TimerFcn', @Timer_Callback_fcn, 'Period', timerDelay, 'ExecutionMode', 'fixedRate' );
timerRestart = true;

if ( debug )
    fprintf ( 'Starting Timer\n' );
end

timerData.handles = handles;
start ( timerObj );
timerRunning = true;

end


% --- Executes when timer completes. Used for periodic refreshes.
function Timer_Callback_fcn ( obj, event )

global timerData;
global debug;

if ( debug )
    fprintf ( 'Timer_Callback_fcn called\n' );
end

handles    = timerData.handles;
hObject    = timerData.hObject;

set ( handles.DATESTRING, 'String', sprintf ( '%s%s', datestr ( now,'dddd, ' ), datestr ( now,'mmmm dd, yyyy HH:MM:SS' ) ) );
set ( handles.DATESTRING, 'Visible', 'On' );

handles = updateDisplay ( handles );

% Update handles structure
guidata ( hObject, handles );

timerData.handles = handles;

if ( debug )
    fprintf ( '%s event occurred at %s\n', event.Type, datestr ( event.Data.time ) );
    get ( obj );
end

end


function new_handles = calculateEnergyLoss ( handles )

handles.BeamEnergy = getBeamEnergy ( handles );

Kact               = UndKact ( 1 : handles.Segments );
SpontRamp          = handles.PhyConsts.c^3 * handles.PhyConsts.Z_0 * handles.PhyConsts.echarge / ( 12 * pi * handles.PhyConsts.mc2_e^4 );  % 1/(T^2 Vm)
ku                 = 2 * pi / handles.UndConsts.lambda_u;
Bact               = ( handles.PhyConsts.mc2_e * ku ) * Kact / handles.PhyConsts.c;

cur_Spont_dE       = 0;
cur_Wake_dE        = 0;

avgCore_WakeRate   = getAverageCoreWakeRate ( handles );

for slot = 1 : handles.Segments
    handles.EnergyLoss { slot }.Spont_dE_ini = cur_Spont_dE;
    handles.EnergyLoss { slot }.Wake_dE_ini  = cur_Wake_dE;

    if ( useSpontaneous ( handles ) )
        DE_spont_dz    = -SpontRamp * ( handles.BeamEnergy * 10^9 )^2 * Bact ( slot )^2;    % V/m
        cur_Spont_dE   = cur_Spont_dE + DE_spont_dz * handles.SegmentFieldLength;
    end

    if ( useWakefields ( handles ) )
        DE_wake_dz     = avgCore_WakeRate;                                                 % V/m
        
        if ( slot == 1 )
            WakeLength = handles.UndConsts.SegmentLength;
        elseif ( slot == 33 )
            WakeLength = handles.UndConsts.SegmentLength;
        else
            WakeLength = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { slot - 1 };
        end
        
        cur_Wake_dE        = cur_Wake_dE + DE_wake_dz * WakeLength;
    end

    handles.EnergyLoss { slot }.Spont_dE_end = cur_Spont_dE;
    handles.EnergyLoss { slot }.Wake_dE_end  = cur_Wake_dE;
    
%    fprintf ( '%f -> %f\n', handles.EnergyLoss { slot }.Spont_dE_ini, handles.EnergyLoss { slot }.Spont_dE_end );
end

%for slot = 1 : handles.Segments
%    fprintf ( '%2.2d %f %f\n', slot, handles.EnergyLoss { slot }.Spont_dE_ini, handles.EnergyLoss { slot }.Spont_dE_end );
%end

new_handles = handles;

end

function new_handles = estimateOptimumGainTaper ( handles )

iniSeg                   = str2double ( get ( handles.GAIN_TAPER_START_SEGMENT, 'String' ) );
endSeg                   = str2double ( get ( handles.GAIN_TAPER_END_SEGMENT,   'String' ) );

iniSeg                   = min ( handles.Segments, max (      1, iniSeg ) );
endSeg                   = min ( handles.Segments, max ( iniSeg, endSeg ) );

emittance                = 0.5;
rmsLB                    = handles.BunchCharge * handles.PhyConsts.c / ( handles.PeakCurrent * sqrt ( 12 ) );
dgamma                   = 2.8;

handles.FELp             = util_LCLS_FEL_Performance_Estimate ( handles.BeamEnergy, emittance, handles.PeakCurrent, rmsLB, dgamma );

sectionLength            = handles.UndConsts.Z_US { endSeg } - handles.UndConsts.Z_US { iniSeg } + handles.UndConsts.SegmentLength;

handles.OptimumGainTaper =  -2 * handles.FELp.rho_3D * handles.FELp.gamma / handles.FELp.L_sat_c * handles.PhyConsts.mc2_e * sectionLength / 1e6;

new_handles              = handles;

end


function new_handles = calculateGainTaper ( handles )

iniSeg             = str2double ( get ( handles.GAIN_TAPER_START_SEGMENT, 'String' ) );
endSeg             = str2double ( get ( handles.GAIN_TAPER_END_SEGMENT,   'String' ) );
TapAmp             = str2double ( get ( handles.GAIN_TAPER_AMPLITUDE,     'String' ) ) * 1e6; % eV

iniSeg             = min ( handles.Segments, max (      1, iniSeg ) );
endSeg             = min ( handles.Segments, max ( iniSeg, endSeg ) );

nSegs              = endSeg - iniSeg + 1;

for slot = 1 : handles.Segments
    handles.EnergyLoss { slot }.Gain_dE_ini  = 0;
    handles.EnergyLoss { slot }.Gain_dE_end  = 0;
end

if ( ~nSegs )
    new_handles = handles;
    return;
end

TapRate            = TapAmp / ( handles.UndConsts.Z_US { endSeg } - handles.UndConsts.Z_US { iniSeg } + handles.UndConsts.SegmentLength );

cur_Gain_dE        = 0;

for slot = iniSeg : handles.Segments
    handles.EnergyLoss { slot }.Gain_dE_ini  = cur_Gain_dE;

    if ( addGainTaper ( handles )  && slot <= endSeg )
        DE_gain_dz     = TapRate;                                                 % V/m
        
        if ( slot == 1 )
            SegLength = handles.UndConsts.SegmentLength;
        elseif ( slot == 33 )
            SegLength = handles.UndConsts.SegmentLength;
        else
            SegLength = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { slot - 1 };
        end
        
        cur_Gain_dE        = cur_Gain_dE + DE_gain_dz * SegLength;
    end

    handles.EnergyLoss { slot }.Gain_dE_end  = cur_Gain_dE;
end

new_handles = handles;

end


function new_handles = calculateSatTaper ( handles )

iniSeg = str2double ( get ( handles.POST_TAPER_START_SEGMENT, 'String' ) );
endSeg = str2double ( get ( handles.POST_TAPER_END_SEGMENT,   'String' ) );
TapAmp = str2double ( get ( handles.POST_TAPER_AMPLITUDE,     'String' ) ) * 1e6; % eV

iniSeg = min ( handles.Segments, max (      1, iniSeg ) );
endSeg = min ( handles.Segments, max ( iniSeg, endSeg ) );

nSegs  = endSeg - iniSeg + 1;

for slot = 1 : handles.Segments
    handles.EnergyLoss { slot }.Sat_dE_ini  = 0;
    handles.EnergyLoss { slot }.Sat_dE_end  = 0;
end

if ( ~nSegs )
    new_handles = handles;
    return;
end

sectionLength = handles.UndConsts.Z_US { endSeg } - handles.UndConsts.Z_US { iniSeg };
LG            = str2double ( get ( handles.POST_TAPER_LG, 'String' ) );
expFact       = - TapAmp / ( LG * ( 1 - exp ( sectionLength / LG ) ) );
cur_Sat_dE    = 0;

for slot = iniSeg : handles.Segments
    handles.EnergyLoss { slot }.Sat_dE_ini  = cur_Sat_dE;
    zposition                               = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { iniSeg };

    if ( addPostSaturationTaper ( handles ) && slot <= endSeg )
        switch get ( handles.POST_TAPER_MENU, 'Value' )
            case handles.PostTaperLinearID
                DE_sat_dz = TapAmp / sectionLength;                           % V/m
            case handles.PostTaperSquareID
                DE_sat_dz = 2 * TapAmp * zposition / sectionLength^2;         % V / m
            case handles.PostTaperExpontID
                DE_sat_dz = expFact * exp ( zposition / LG );                 % V / m
        end
    
        if ( slot == 1 || slot == 33 )
            SegCenterDistance = handles.UndConsts.SegmentLength;
        else
            SegCenterDistance = handles.UndConsts.Z_US { slot } - handles.UndConsts.Z_US { slot - 1 };
        end
        
        cur_Sat_dE        = cur_Sat_dE + DE_sat_dz * SegCenterDistance;
    end

    handles.EnergyLoss { slot }.Sat_dE_end  = cur_Sat_dE;
end

new_handles = handles;

end


function avgCore_WakeRate   = getAverageCoreWakeRate ( handles )

peakCurrent = getPeakCurrent ( handles );
bunchCharge = getBunchCharge ( handles );
compStatus  = isUndercompressed ( handles );

avgCore_WakeRate = util_UndulatorWakeAmplitude ( peakCurrent / 1000, bunchCharge, compStatus ) * 1000;

end


function firstSegment = findFirstSegment ( n, handles )

firstSegment = 0;

for slot = 1 : n
    if ( isActive ( slot,handles) )
        firstSegment = slot;
        break;
    end
end

end


function new_handles = calculateTaperRequirement ( handles )

handles.BeamEnergy = getBeamEnergy ( handles );
Kact               = zeros ( 1 , handles.Segments );

for slot = 1 : handles.Segments
    Kact ( slot ) = getEquivalentKvalue ( slot, handles );

%    Kact ( slot ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
    try
        if ( ~Kact ( slot ) )
            Kact ( slot ) = UndKact ( slot );
        end
    end
end

handles.fstSegment  = findFirstSegment ( handles.Segments, handles );

if ( handles.fstSegment )
    Kini     = Kact ( handles.fstSegment );
%    Kini     = 3.507;
    dKK_dgg  = ( 2 / Kini^2 + 1 );
else    
    Kini     = 0;
    dKK_dgg  = 0;
end

handles = calculateGainTaper ( handles );
handles = calculateSatTaper  ( handles );

if ( handles.fstSegment )
    for slot = 1 : handles.Segments
        dE_ini = 0;
        
        if ( useSpontaneous ( handles ) )
            if ( Kact ( slot ) > 0 )
                dE_ini = dE_ini +  handles.EnergyLoss { slot }.Spont_dE_ini - handles.EnergyLoss { handles.fstSegment }.Spont_dE_ini;
            end
        end

        if ( useWakefields ( handles ) )
            dE_ini = dE_ini + handles.EnergyLoss { slot }.Wake_dE_ini  - handles.EnergyLoss { handles.fstSegment }.Wake_dE_ini;
        end

        if ( addGainTaper ( handles ) )
            dE_ini = dE_ini + handles.EnergyLoss { slot }.Gain_dE_ini  - handles.EnergyLoss { handles.fstSegment }.Gain_dE_ini;
        end
        
        if ( addPostSaturationTaper ( handles ) )
            dE_ini = dE_ini + handles.EnergyLoss { slot }.Sat_dE_ini  - handles.EnergyLoss { handles.fstSegment }.Sat_dE_ini;
        end
        
        handles.EnergyLoss { slot }.Kt_ini = Kini * dE_ini   / (handles.BeamEnergy * 10^9 ) * dKK_dgg + Kini;

        dE_end = 0;     
        
        if ( useSpontaneous ( handles ) )
            if ( Kact ( slot ) > 0 )
                dE_end = dE_end +  handles.EnergyLoss { slot }.Spont_dE_end - handles.EnergyLoss { handles.fstSegment }.Spont_dE_ini;
            end
        end

        if ( useWakefields ( handles ) )
            dE_end = dE_end + handles.EnergyLoss { slot }.Wake_dE_end  - handles.EnergyLoss { handles.fstSegment }.Wake_dE_ini;
        end
    
        if ( addGainTaper ( handles ) )
            dE_end = dE_end + handles.EnergyLoss { slot }.Gain_dE_end  - handles.EnergyLoss { handles.fstSegment }.Gain_dE_ini;
        end
        
        if ( addPostSaturationTaper ( handles ) )
            dE_end = dE_end + handles.EnergyLoss { slot }.Sat_dE_end  - handles.EnergyLoss { handles.fstSegment }.Sat_dE_ini;
        end
        
        handles.EnergyLoss { slot }.Kt_end = Kini * dE_end   / (handles.BeamEnergy * 10^9 ) * dKK_dgg + Kini;
    
%        fprintf ( '%2.2d %f -> %f\n', slot, handles.EnergyLoss { slot }.Kt_ini, handles.EnergyLoss { slot }.Kt_end );
    end
else
    for slot = 1 : handles.Segments
        handles.EnergyLoss { slot }.Kt_ini = 0;
        handles.EnergyLoss { slot }.Kt_end = 0;
    end
end

%    for slot = 1 : handles.Segments
%        fprintf ( 'slot %2.2d: Kt_ini: %6.4f; Kt_end: %6.4f\n', slot, handles.EnergyLoss { slot }.Kt_ini, handles.EnergyLoss { slot }.Kt_end );
%    end

new_handles = handles;

end


function plotK ( axes_handle, handles )
plot ( 1:2, 0 * sin ( ( 1 : 2 ) *pi / 50 ), 'Parent', axes_handle );
%cla(axes_handle);
hold ( axes_handle, 'on' );
grid ( axes_handle, 'on' );

xlabel ( 'z [m]', 'Parent', axes_handle );
ylabel ( 'K',     'Parent', axes_handle );

zini = 510 + handles.dZ;
zend = 650 + handles.dZ;

xinmax =  getXINMAX ( 1 : 33 );

%axis ( axes_handle, [ zini zend 3.465 3.515 ]);
%axis ( axes_handle, [ zini zend 3.445 3.515 ]);
axis ( axes_handle, [ zini zend 3.4125 3.515 ]);

Kmax_reg = UndKact ( 1 : 33, ( 1 : 33 ) * 0 -  5 );
Kmin_reg = UndKact ( 1 : 33, xinmax );

Kmax_ext = UndKact ( 1 : 33, xinmax );
Kmin_ext = UndKact ( 1 : 33, xinmax + 4 );

segP     = zeros ( 1, 2 );
segK     = zeros ( 1, 2 );

MntCount = 0;
EquCount = 0;

Plot_iSASE_Line=0;
if(get(handles.Open_iSASEpanel,'Userdata'))
    Plot_iSASE_Line=1;
    Current_iSASE_Table=get(handles.iSASE_State,'data');
    iSASE_K_Values=[Current_iSASE_Table{:,3}];
    iSASELine=[];
end

for slot = 1 : handles.Segments
    segP ( 1 ) = handles.EnergyLoss { slot }.z_ini;
    segP ( 2 ) = handles.EnergyLoss { slot }.z_end;

    segK ( 1 ) = getEquivalentKvalue ( slot, handles );
%    segK ( 1 ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
    segK ( 2 ) = segK ( 1 );
    
    [ segRx_reg, segRy_reg ] = calcRange ( handles, Kmin_reg, Kmax_reg, slot );
    [ segRx_ext, segRy_ext ] = calcRange ( handles, Kmin_ext, Kmax_ext, slot );

    if ( isInstalled ( slot ) )
        if(handles.Type(slot)<=99) %Off, Normal or SHAB
            fill ( segRx_reg, segRy_reg, 'y', 'Parent', axes_handle ); 
            fill ( segRx_ext, segRy_ext, [ 1, 153/255, 0], 'Parent', axes_handle ); 
        else
            [ segRx_reg, segRy_reg ] = calcRange_delta ( handles, 3.4, 3.52, slot );
            fill ( segRx_reg, segRy_reg,[1,1,0.6], 'Parent', axes_handle ); 
        end
    end
    
    if ( isActive ( slot,handles ) )
        if ( getHarm ( slot ) == 2 )
            EquCount = EquCount + 1;
            plot ( segP, segK,  '-m', 'Parent', axes_handle ); 
        elseif ( getHarm ( slot ) == 1 )
            plot ( segP, segK,  '-k', 'Parent', axes_handle ); 
        elseif ( getHarm ( slot ) == handles.DeltaType ) %Delta Must get equivalent delta K for that harmonic or for all harmonics?
            plot ( segP, segK,  '-k', 'Parent', axes_handle );
           [Keff,Full_Status]=read_delta_K_value(handles.SlotToDeltaUndulatorsConversion(slot),handles);
            if(Keff>3.47)
               text ( mean(segP), 3.425, sprintf ( '%2d', Full_Status(2) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle );
               text ( mean(segP), 3.423, sprintf ( '%2d', Full_Status(3) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle );
               text ( mean(segP), 3.421, sprintf ( '%2.1f', Full_Status(4) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle ); 
               text ( mean(segP), 3.419, sprintf ( '%2d', Full_Status(5) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle ); 
            else
               text ( mean(segP), 3.513, sprintf ( '%2d', Full_Status(2) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle );
               text ( mean(segP), 3.511, sprintf ( '%2d', Full_Status(3) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle );
               text ( mean(segP), 3.509, sprintf ( '%2.1f', Full_Status(4) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle ); 
               text ( mean(segP), 3.507, sprintf ( '%2d', Full_Status(5) ), 'FontSize', 6,'FontWeight', 'bold', 'Color', [0,0,0], 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom','Parent', axes_handle );  
            end
        end
        
        if(Plot_iSASE_Line)
            Current_iSASE_Table{slot,2}=segK ( 1 );
            if ( getHarm ( slot ) == 2 )
                iSASELine(1,end+1)=mean(segP);
                iSASELine(2,end)=iSASE_K_Values(slot);
            elseif ( getHarm ( slot ) == 1 )
                iSASELine(1,end+1)=mean(segP);
                iSASELine(2,end)=iSASE_K_Values(slot);
                %plot ( mean(segP), [1,1]*iSASE_K_Values(slot),  'b*', 'Parent', axes_handle ); 
            elseif ( getHarm ( slot ) == handles.DeltaType ) %Delta 
                iSASELine(1,end+1)=mean(segP);
                iSASELine(2,end)=iSASE_K_Values(slot);
            end    
        end
        
        
        avg_segP = ( segP ( 1 ) + segP ( 2 ) ) / 2;
        avg_segK = ( segK ( 1 ) + segK ( 2 ) ) / 2;

        if ( isUnderMaintenance ( slot ) )
            MntCount = MntCount + 1;
            useColor = [ 0.7, 0.7, 0.7 ];
        elseif ( getHarm ( slot ) == 2 )
            useColor = [ 1.0, 0.0, 1.0 ];
%            useColor = 'm';
        elseif ( getHarm ( slot ) == 1 )
            useColor = [ 0.0, 0.0, 0.0 ];
        elseif ( getHarm ( slot ) == handles.DeltaType )
            useColor = [ 0.0, 0.0, 0.0 ];
        end
        
        text ( avg_segP, avg_segK, sprintf ( '%2.2d', slot ), ...
            'FontSize', 6, ...
            'FontWeight', 'bold', ...
            'Color', useColor, ...
            'HorizontalAlignment', 'Center', ...
            'VerticalAlignment', 'Bottom', ...
            'Parent', axes_handle );
        
        segT ( 1 ) = handles.EnergyLoss { slot }.Kt_ini;
        segT ( 2 ) = handles.EnergyLoss { slot }.Kt_end;
        
        plot ( segP, segT, '-r', 'LineWidth', 3, 'Parent', axes_handle );
    end
end
if(Plot_iSASE_Line)
    LineaDaCancellare=plot ( iSASELine(1,:), iSASELine(2,:),  'b*', 'Parent', axes_handle ); 
    set(handles.MoveSelectedToBlueStars,'userdata',LineaDaCancellare);
    set(handles.iSASE_State,'data',Current_iSASE_Table);
end

if ( MntCount )
    if ( EquCount )
        set ( handles.MSG_LINE_1, 'String', 'Gray Slot Number: In Maintenance' );
        set ( handles.MSG_LINE_2, 'String', 'Will not be moved' );
        set ( handles.MSG_LINE_3, 'String', 'Magenta Slot Number: Equivalent K' );
    else
        set ( handles.MSG_LINE_1, 'String', 'Gray Slot Number: In Maintenance' );
        set ( handles.MSG_LINE_2, 'String', 'Will not be moved' );
        set ( handles.MSG_LINE_3, 'String', '' );
    end
else
    if ( EquCount )
        set ( handles.MSG_LINE_1, 'String', 'Magenta Slot Number: Equivalent K' );
        set ( handles.MSG_LINE_2, 'String', '' );
        set ( handles.MSG_LINE_3, 'String', '' );
    else
        set ( handles.MSG_LINE_1, 'String', '' );
        set ( handles.MSG_LINE_2, 'String', '' );
        set ( handles.MSG_LINE_3, 'String', '' );
    end
end

if ( MntCount || EquCount )
    set ( handles.MSG_PANEL, 'Visible', 'On' );
else
    set ( handles.MSG_PANEL, 'Visible', 'Off' );
end

end


function pos = estimatePosition ( pctX, pctY, frame )

X0 = frame ( 1 );
Y0 = frame ( 3 );
W  = frame ( 2 ) - frame ( 1 );
H  = frame ( 4 ) - frame ( 3 );

X = X0 + W * pctX / 100;
Y = Y0 + H * pctY / 100;

pos = [ X, Y ];

end


function new_handles = updateDisplay ( handles )

global timerData;
global debug;

if ( debug )
    fprintf ( 'entering "updateDisplay"\n' ); 
end

UpdateInAndOutTable(handles);

handles.BunchCharge        = getBunchCharge ( handles );
handles.BeamEnergy         = getBeamEnergy ( handles );
handles.PeakCurrent        = getPeakCurrent ( handles );
handles                    = calculateEnergyLoss ( handles );
handles                    = calculateTaperRequirement ( handles );
handles.ActualBunchCharge  = getActualBunchCharge ( handles ) * 1000;
handles.ActualBeamEnergy   = getActualBeamEnergy;
handles.ActualPeakCurrent  = getActualPeakCurrent;
handles                    = estimateOptimumGainTaper ( handles );

set ( handles.USE_ACTUAL_ENERGY_RADIO_BTN,       'String', sprintf ( 'Use Actual Energy (%6.3f GeV)',      handles.ActualBeamEnergy ) );
set ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'String', sprintf ( 'Use Actual Bunch Charge (%4.1f pC)', handles.ActualBunchCharge ) );
set ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'String', sprintf ( 'Use Actual Peak Current (%5.1f A)',  handles.ActualPeakCurrent ) );

set ( handles.SUGGESTED_GAIN_TAPER,              'String', sprintf ( '(%+3.0f)',  handles.OptimumGainTaper ) );
set ( handles.ESTIMATED_SATURATION_POINT,        'String', sprintf ( '(%3.0f)',  ...
                                                       floor ( handles.FELp.L_sat_c / 132.9 * 33 )  ) );
                                                   

set ( handles.REFERENCE_DATE,                    'String', handles.referenceDate );
set ( handles.INITIAL_DATE,                      'String', handles.initialDate   );

handles.presentTaperParms = loadTaperParmsFromSOFTPVs ( handles.presentTaperParms );
set ( handles.AUTOMOVE_SOFT_PV_VAL,              'String', sprintf ( '(%d)',  handles.presentTaperParms{handles.ID_AUTOMOVE}.VAL) );

if ( handles.fstSegment )
    E        = handles.BeamEnergy * 10^9 - ...
               handles.EnergyLoss { handles.fstSegment }.Spont_dE_ini - ...
               handles.EnergyLoss { handles.fstSegment }.Wake_dE_ini - ...
               handles.LTU_Wake_Loss * 10^6;
    gamma    = E / handles.PhyConsts.mc2_e;
    lambda_r = handles.UndConsts.lambda_u / ( 2 * gamma^2 ) * ( 1 + UndKact ( handles.fstSegment )^2 / 2 );
    Ephoton  = handles.PhyConsts.h_bar * 2 * pi * handles.PhyConsts.c / lambda_r / handles.PhyConsts.echarge;
    
%    handles.fstSegment   = findFirstSegment ( handles.Segments );

    fstK = getEquivalentKvalue ( handles.fstSegment, handles );
%    fstK = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', handles.fstSegment ) );

    if ( handles.moving_fstK )
        if ( abs ( fstK - get ( handles.FST_K, 'Value' ) ) < 1e-4 )
            handles.movign_fstK = false;
        end
    else
        fstK = getEquivalentKvalue ( handles.fstSegment, handles );
%        fstK = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', handles.fstSegment ) );
        
        if ( abs ( fstK - get ( handles.FST_K, 'Value' ) ) > 1e-4 )
            set ( handles.FST_K, 'String', sprintf ( '%6.4f', fstK ) );
            set ( handles.FST_K, 'Value',  fstK );    
        end
    end
    
%    handles.xray_profmon = 'YAGS:DMP1:500';
    
    if ( handles.YAGXRAYavailable )
        if (isnan ( lcaGet ( 'YAGS:DMP1:500:FOIL1_PNEU', 0, 'double' ) ) )
            handles.YAGXRAYavailable =false;
            
            fprintf ( 'YAGXRAY is not available. Continuing without ...\n' );
        end
    end

    
    if ( handles.YAGXRAYavailable )
        YAGXRAYinserted = ( lcaGet ( 'YAGS:DMP1:500:FOIL1_PNEU', 0, 'double' ) ~= 1 );
    else
        YAGXRAYinserted = false;
    end
    
    if ( handles.ActualBunchCharge > 15 ) % 1500 pC means: deactivated. Don't use as long as FEE is not yet ready.
%        opts.nBG             = 0;
%        opts.bufd            = 0;
%        opts.doPlot          = 0;
%        handles.num_shots    = 1;
%        dataList             = profmon_measure ( handles.xray_profmon,handles.num_shots,opts );
%        YAGXRAY              =  max ( max ( dataList.img ) );

        if ( YAGXRAYinserted )
            YAGXRAY = lcaGetSmart ( 'SIOC:SYS0:ML00:AO594' );
            
            set ( handles.YAGXRAY_AMPLITUDE, 'String', sprintf ( 'YAGXRAY Amplitude = %5.1f AU',      YAGXRAY ) );    
            set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'On' );    
            set ( handles.GASDET1_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.GASDET2_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );    
        else
            set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.GASDET1_AMPLITUDE, 'Visible', 'On' );    
            set ( handles.GASDET2_AMPLITUDE, 'Visible', 'On' );    
            set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
            set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );
%%            GASDET1              = ( lcaGetSmart ( 'GDET:FEE1:11:ENRC' ) + lcaGetSmart ( 'GDET:FEE1:11:ENRC' ) ) / 2;
            GASDET1 = NaN;
%            SLDTRANSMISSION      = 0.8;%lcaGetSmart ( 'SATT:FEE1:320:RACT' );
%            GASTRANSMISSION      = lcaGetSmart ( 'GATT:FEE1:310:R_ACT' );
%%            GASDET2              = ( lcaGetSmart ( 'GDET:FEE1:21:ENRC' ) + lcaGetSmart ( 'GDET:FEE1:22:ENRC' ) ) / 2;        
            GASDET2 = NaN;
%           GASDET2              = GASDET2 / SLDTRANSMISSION / GASTRANSMISSION;
            XENERGY              = NaN;
%            XENERGY              = ( lcaGetSmart ( 'ELEC:FEE1:452:DATA' ) + lcaGetSmart ( 'ELEC:FEE1:453:DATA' ) ) * 500 ;
            DIMAGER              = NaN;
%            DIMAGER              = lcaGetSmart ( 'DIAG:FEE1:481:RawMax' );
            set ( handles.GASDET1_AMPLITUDE, 'String', sprintf ( 'Gas Detector 1 = %5.3f mJ',         GASDET1 ) );    
            set ( handles.GASDET2_AMPLITUDE, 'String', sprintf ( 'Gas Detector 2 = %5.3f mJ',         GASDET2 ) );    
            set ( handles.XENERGY_AMPLITUDE, 'String', sprintf ( 'Calorimeter = %5.3f mJ',            XENERGY ) );    
            set ( handles.DIMAGER_AMPLITUDE, 'String', sprintf ( 'Direct Imager = %5.3f AU',          DIMAGER ) );    
        end
    else
        set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.GASDET1_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.GASDET2_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
        set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );
    end

    set ( handles.FUNDAMENTAL_WAVELENGTH,            'String', sprintf ( 'Fundamental Wavelength = %6.4f nm', lambda_r * 1e9 ) );
    set ( handles.PHOTON_ENERGY,                     'String', sprintf ( 'Photon Energy = %5.1f eV',          Ephoton ) );    
else
    set ( handles.YAGXRAY_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.GASDET1_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.GASDET2_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.XENERGY_AMPLITUDE, 'Visible', 'Off' );    
    set ( handles.DIMAGER_AMPLITUDE, 'Visible', 'Off' );
end

if ( get ( handles.AUTO_MOVE_CHECKBOX, 'Value' )  )
    changeKvalues ( handles );
    set ( handles.APPLY, 'Visible', 'Off' );
else
    set ( handles.APPLY, 'Visible', 'On' );
end

plotK ( handles.TAPERDISPLAY, handles );

hold  ( handles.TAPERDISPLAY, 'off' );

% DELTA PART is run during callback only when at least one delta undulator
% is installed.
if(get(handles.DeltaActiveString,'userdata'))
    DeltaUpdate(handles);
end
% iSASE PART, Only if Scan is active
if(get(handles.iSASE_ListeningMode,'userdata'))
    DoiSASEScan(handles);
end


timerData.handles = handles;

new_handles       = handles;

drawnow;

if ( debug )
    fprintf ( 'leaving "updateDisplay"\n' ); 
end

end


function answer = useSpontaneous ( handles )

answer = get ( handles.USE_SPONT_RAD_BOX, 'Value' );

end


function answer = useWakefields ( handles )

answer = get ( handles.USE_WAKEFIELDS_BOX, 'Value' );

end


function answer = addGainTaper ( handles )

answer = get ( handles.ADD_GAIN_TAPER_BOX, 'Value' );

end


function answer = addPostSaturationTaper ( handles )

answer = get ( handles.ADD_POST_SATURATION_TAPER_BOX, 'Value' );

end


% --- Executes on button press in USE_SPONT_RAD_BOX.
function USE_SPONT_RAD_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_SPONT_RAD_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_SPONT_RAD_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_USE_SPONT_RAD_BOX );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in USE_WAKEFIELDS_BOX.
function USE_WAKEFIELDS_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_WAKEFIELDS_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_WAKEFIELDS_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_USE_WAKEFIELDS_BOX );
timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in ADD_GAIN_TAPER_BOX.
function ADD_GAIN_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_GAIN_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_GAIN_TAPER_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_ADD_GAIN_TAPER_BOX );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in ADD_POST_SATURATION_TAPER_BOX.
function ADD_POST_SATURATION_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_POST_SATURATION_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_POST_SATURATION_TAPER_BOX

global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_ADD_POST_SATURATION_TAPER_BOX );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in USE_ACTUAL_ENERGY_RADIO_BTN.
function USE_ACTUAL_ENERGY_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_ENERGY_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_ENERGY_RADIO_BTN

global timerData;

manageBeamEnergyRadioButtons ( handles, 1 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_ENERGY );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in SET_ENERGY_RADIO_BTN.
function SET_ENERGY_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_ENERGY_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_ENERGY_RADIO_BTN

global timerData;

manageBeamEnergyRadioButtons ( handles, 2 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_ENERGY );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


function MODEL_BEAM_ENERGY_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_BEAM_ENERGY as text
%        str2double(get(hObject,'String')) returns contents of MODEL_BEAM_ENERGY as a double

global timerData;

%handles = updateDisplay ( handles );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function MODEL_BEAM_ENERGY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ( ispc && isequal ( get ( hObject, 'BackgroundColor' ), get ( 0, 'defaultUicontrolBackgroundColor' ) ) )
    set ( hObject, 'BackgroundColor','white' );
end

end


function manageBeamEnergyRadioButtons ( handles, b )

if ( exist ( 'b', 'var' ) )
    if ( b > 0 && b < 3 )
        btn = b;
    else
        btn = 0;
    end
else
    btn = 0;
end

if ( ~btn )
    b1 = get ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value' );
    b2 = get ( handles.SET_ENERGY_RADIO_BTN,        'Value' );

    if ( b1 )
        if ( ~b2 )
            btn = 1;
        end
    else
        if ( b2 )
            btn = 2;
        end
    end
end

if ( btn == 1 )
    set ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value', 1 );
    set ( handles.SET_ENERGY_RADIO_BTN,        'Value', 0 );
else
    set ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value', 0 );
    set ( handles.SET_ENERGY_RADIO_BTN,        'Value', 1 );
end

end


function actualBeamEnergy = getActualBeamEnergy

E1                = lcaGet ( 'BEND:DMP1:400:BDES' );            % GeV
E2                = lcaGet ( 'SIOC:SYS0:ML00:AO289') / 1000;    % GeV  -> Vernier
actualBunchCharge = lcaGet ( 'BPMS:UND1:190:TMIT' ) * 1.6e-19 * 1e9;  % [nC]'

if ( actualBunchCharge > 10 )
    E3 = lcaGet ( 'BPMS:LTU1:250:XBR' ) / 1000;    % GeV
else
    E3 = 0;
end

actualBeamEnergy = E1 + E2 + E3;    % GeV

end


function BeamEnergy = getBeamEnergy ( handles )

if ( get ( handles.USE_ACTUAL_ENERGY_RADIO_BTN, 'Value' ) )
    BeamEnergy  = getActualBeamEnergy;    % GeV
else
    BeamEnergy  = str2double ( get ( handles.MODEL_BEAM_ENERGY, 'String' ) );
end

set ( handles.BEAM_ENERGY, 'String', sprintf ( 'Beam Energy = %6.3f GeV', BeamEnergy ) );

end


% --- Executes on button press in USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN.
function USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN

global timerData;

manageBunchChargeRadioButtons ( handles, 1 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_BUNCH_CHARGE );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in SET_BUNCH_CHARGE_RADIO_BTN.
function SET_BUNCH_CHARGE_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_BUNCH_CHARGE_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_BUNCH_CHARGE_RADIO_BTN

global timerData;

manageBunchChargeRadioButtons ( handles, 2 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_BUNCH_CHARGE );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


function MODEL_BUNCH_CHARGE_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_BUNCH_CHARGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_BUNCH_CHARGE as text
%        str2double(get(hObject,'String')) returns contents of MODEL_BUNCH_CHARGE as a double

%global timerData;

%handles = updateDisplay ( handles );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function MODEL_BUNCH_CHARGE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BUNCH_CHARGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function manageBunchChargeRadioButtons ( handles, b )

if ( exist ( 'b', 'var' ) )
    if ( b > 0 && b < 3 )
        btn = b;
    else
        btn = 0;
    end
else
    btn = 0;
end

if ( ~btn )
    b1 = get ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value' );
    b2 = get ( handles.SET_BUNCH_CHARGE_RADIO_BTN,        'Value' );

    if ( b1 )
        if ( ~b2 )
            btn = 1;
        end
    else
        if ( b2 )
            btn = 2;
        end
    end
end

if ( btn == 1 )
    set ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value', 1 );
    set ( handles.SET_BUNCH_CHARGE_RADIO_BTN,        'Value', 0 );
else
    set ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value', 0 );
    set ( handles.SET_BUNCH_CHARGE_RADIO_BTN,        'Value', 1 );
end

end


function actualBunchCharge = getActualBunchCharge ( handles )

try
    actualBunchCharge  = lcaGet ( 'BPMS:UND1:190:TMIT' ) * handles.PhyConsts.echarge * 1e9;  % [nC]'
catch
    actualBunchCharge = 0;
end

end


function BunchCharge = getBunchCharge ( handles )

if ( get ( handles.USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN, 'Value' ) )
    BunchCharge  = getActualBunchCharge ( handles ) * 1000;  % [pC]'
else
    BunchCharge  = str2double ( get ( handles.MODEL_BUNCH_CHARGE, 'String' ) ); % [pC]
end

end


% --- Executes on button press in USE_ACTUAL_PEAK_CURRENT_RADIO_BTN.
function USE_ACTUAL_PEAK_CURRENT_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_PEAK_CURRENT_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_PEAK_CURRENT_RADIO_BTN

global timerData;

managePeakCurrentRadioButtons ( handles, 1 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_PEAK_CURRENT );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in SET_PEAK_CURRENT_RADIO_BTN.
function SET_PEAK_CURRENT_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_PEAK_CURRENT_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_PEAK_CURRENT_RADIO_BTN

%global timerData;

managePeakCurrentRadioButtons ( handles, 2 )
%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_SET_PEAK_CURRENT );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


function MODEL_PEAK_CURRENT_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_PEAK_CURRENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_PEAK_CURRENT as text
%        str2double(get(hObject,'String')) returns contents of MODEL_PEAK_CURRENT as a double

%global timerData;

%handles = updateDisplay ( handles );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function MODEL_PEAK_CURRENT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function managePeakCurrentRadioButtons ( handles, b )

if ( exist ( 'b', 'var' ) )
    if ( b > 0 && b < 3 )
        btn = b;
    else
        btn = 0;
    end
else
    btn = 0;
end

if ( ~btn )
    b1 = get ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value' );
    b2 = get ( handles.SET_PEAK_CURRENT_RADIO_BTN,        'Value' );

    if ( b1 )
        if ( ~b2 )
            btn = 1;
        end
    else
        if ( b2 )
            btn = 2;
        end
    end
end

if ( btn == 1 )
    set ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value', 1 );
    set ( handles.SET_PEAK_CURRENT_RADIO_BTN,        'Value', 0 );
else
    set ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value', 0 );
    set ( handles.SET_PEAK_CURRENT_RADIO_BTN,        'Value', 1 );
end

end


function v = getActualPeakCurrent
   global OPctrl;

   v    = 0;
   Ipk  = lcaGet ( 'BLEN:LI24:886:BIMAX' );    % A

    if ( isnan ( Ipk )  )
        return
    end
    
    if ( Ipk <= 0 || Ipk > 1e5 )
        return
    end

if ( OPctrl.Ipklvl < OPctrl.bufSize )
    OPctrl.Ipklvl                            = OPctrl.Ipklvl + 1;
else
    OPctrl.IpkBuf ( 1 : OPctrl.bufSize - 1 ) = OPctrl.IpkBuf ( 2 : OPctrl.bufSize );
end

OPctrl.IpkBuf ( OPctrl.Ipklvl )   = Ipk;
v                                 = mean ( OPctrl.IpkBuf ( 1 : OPctrl.Ipklvl ) );

end


function PeakCurrent = getPeakCurrent ( handles )

if ( get ( handles.USE_ACTUAL_PEAK_CURRENT_RADIO_BTN, 'Value' ) )
   PeakCurrent  = getActualPeakCurrent;    % A
else
   PeakCurrent  = str2double ( get ( handles.MODEL_PEAK_CURRENT, 'String' ) );
end

if ( isnan ( PeakCurrent )  )
    PeakCurrent = 0;
end

end


function    [ segRx, segRy ] = calcRange ( handles, Kmin, Kmax, slot )

xLF = handles.EnergyLoss { slot }.z_ini;
xRT = handles.EnergyLoss { slot }.z_end;
yUP = Kmax ( slot );
yDN = Kmin ( slot );

segRx = [ xLF xLF xRT xRT xRT ];
segRy = [ yDN yUP yUP yDN yDN ];

end

function    [ segRx, segRy ] = calcRange_delta ( handles, Kmin, Kmax, slot )

xLF = handles.EnergyLoss { slot }.z_ini;
xRT = handles.EnergyLoss { slot }.z_end;
yUP = Kmax ;
yDN = Kmin ;

segRx = [ xLF xLF xRT xRT xRT ];
segRy = [ yDN yUP yUP yDN yDN ];

end


% --- Executes on button press in APPLY.
function APPLY_Callback(hObject, eventdata, handles)
% hObject    handle to APPLY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

changeKvalues ( handles );

end


function changeKvalues ( handles )

Kvalues = zeros ( 1, handles.Segments );

for slot = 1 : handles.Segments
    if ( isActive ( slot,handles ) )        
        Kvalues ( slot ) = handles.EnergyLoss { slot }.Kt_ini;
    end
end

setKvalues ( handles, Kvalues );

end


function GAIN_TAPER_START_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_START_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_START_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_GAIN_TAPER_START_SEGMENT );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_START_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function GAIN_TAPER_END_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_END_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_GAIN_TAPER_END_SEGMENT );

%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_END_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function GAIN_TAPER_AMPLITUDE_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_AMPLITUDE as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_GAIN_TAPER_AMPLITUDE );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_AMPLITUDE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_START_SEGMENT_Callback(hObject, eventdata, handles)


setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_START_SEGMENT );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_START_SEGMENT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_END_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_END_SEGMENT as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_END_SEGMENT );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_END_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_AMPLITUDE_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_AMPLITUDE as a double

%global timerData;

%handles = updateDisplay ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_AMPLITUDE );
    
%timerData.handles = handles;

% Update handles structure
%guidata(hObject, handles);

end


% --- Executes on selection change in POST_TAPER_MENU.
function POST_TAPER_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns POST_TAPER_MENU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from POST_TAPER_MENU

manageTaperTypeMenu ( handles );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_TYPE );

end


function manageTaperTypeMenu ( handles )

if ( get ( handles.POST_TAPER_MENU, 'Value' ) == handles.PostTaperExpontID )
    set ( handles.POST_TAPER_LG_LABEL, 'Visible', 'On' );
    set ( handles.POST_TAPER_LG,       'Visible', 'On' );
    set ( handles.POST_TAPER_LG_UNIT,  'Visible', 'On' );
else
    set ( handles.POST_TAPER_LG_LABEL, 'Visible', 'Off' );
    set ( handles.POST_TAPER_LG,       'Visible', 'Off' );
    set ( handles.POST_TAPER_LG_UNIT,  'Visible', 'Off' );
end

end

% --- Executes during object creation, after setting all properties.
function POST_TAPER_MENU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_AMPLITUDE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function POST_TAPER_LG_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_LG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_LG as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_LG as a double

LG = str2double ( get ( handles.POST_TAPER_LG, 'String' ) );

if ( isnan ( LG ) || LG < 4 )
    LG = 4;
end

set ( handles.POST_TAPER_LG, 'String', sprintf ( '%.2f', LG ) );

setSOFTPV ( handles.presentTaperParms, handles.ID_POST_TAPER_LG );

end


% --- Executes during object creation, after setting all properties.
function POST_TAPER_LG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_LG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function activeStatus = isActive ( slot, handles)
if(handles.Type(slot)~=handles.DeltaType)
    if ( UndKact ( slot ) > 0 )
        activeStatus = true;
    else
        activeStatus = false;
    end
else %Per il Delta
    if ( isInstalled ( slot ) && ~isUnderMaintenance ( slot ) )
       activeStatus=logical(strcmpi(lcaGet(handles.AllDeltaUndulators{handles.SlotToDeltaUndulatorsConversion(slot),15,2}),'On'));
    else
       activeStatus=false; 
    end
    return
end

end


function  undulatorHarmonics =  getHarm ( slot )

undulatorHarmonics = lcaGet ( sprintf ( 'USEG:UND1:%d50:TYPE', slot ), 0, 'double' );

%x if ( slot == 33 )
%x     undulatorHarmonics = 2;
%x end

end


function  installedStatus =  isInstalled ( slot )

installedStatus = lcaGet ( sprintf ( 'USEG:UND1:%d50:INSTALTNSTAT', slot ), 0, 'double' );

end


function  underMaintenance =  isUnderMaintenance ( slot )

underMaintenance = lcaGet ( sprintf ( 'USEG:UND1:%d50:MAINTENANCEM', slot ), 0, 'double' );

end


function  xinmax =  getXINMAX ( slot )

n      = length ( slot );
xinmax = zeros ( 1, n );

for j = 1 : n
    xinmax ( j ) = lcaGet ( sprintf ( 'USEG:UND1:%d50:XINMAX', j ), 0, 'double' );
end

end


function K = UndKact ( slots, xpos )

global hh;
  
K = 0;

n = length ( slots );

if  ( ~n )
    return;
end

K = zeros ( 1, n );

if ( exist ( 'xpos', 'var' ) )
    xisgiven = true;
    m        = length ( xpos );
    
    if ( n ~= m )
        error ( 'Length mismatch between slots (%d) and xpos (%d).', n, m );
    end
else
    xisgiven = false;
end

for k = 1 : n
    slot = slots ( k );
    
    if ( slot < 1 || slot > 33 )
        continue;
    end

    if ( isInstalled ( slot ) && ~isUnderMaintenance ( slot ) )
        SliderPV = sprintf ( 'USEG:UND1:%d50:TM2MOTOR.RBV', slot ); 
%        SliderPV = sprintf ( 'USEG:UND1:%d50:TMXPOSC', slot );
%        KactPV   = sprintf ( 'USEG:UND1:%d50:KACT',    slot );
  
        if ( xisgiven )
            x = xpos ( k );
        else
            try
                x = lcaGet ( SliderPV );
            catch
                x = 0;
            end
        end

        if ( x > -6 && x < 30 )
            Xoffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:XOFF', slot ) );

            K ( k ) = evalPoly ( -x - Xoffset, slot, hh.Kcoeffs );
           
         else
            K ( k ) = 0;
        end
    else
        K ( k ) =  0;
        x       = 84;
    end

    if ( slot == 35 ) 
        xisgiven
        x
        slot
        K ( k )
        Koffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:KOFFSET', slot ) );
        Xoffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:XOFF',    slot ) );
        
        xcheck = - evalPoly ( K ( k ) - Koffset, slot, hh.Xcoeffs ) - Xoffset;
        Kcheck = evalPoly ( -x - Xoffset, slot, hh.Kcoeffs );

        fprintf ( 'Koeffs ( %2.2d ) = %g', slot, hh.Kcoeffs { slot, 1 } );
        for poly = 2 : 6
            fprintf ( ', %g', hh.Kcoeffs { slot, poly } );
        end
        
        fprintf ( '\n' );
         
        fprintf ( 'Xoeffs ( %2.2d ) = %g', slot, hh.Xcoeffs { slot, 1 } );

        for poly = 2 : 6
            fprintf ( ', %g', hh.Xcoeffs { slot, poly } );
        end
         
        fprintf ( '\n' );
         
    end
end

for k = 1 : n
    if ( K ( k ) > 0 )
        K ( k ) = K2equK ( K ( k ), getHarm ( k ) );
    end
end

end


function y = evalPoly ( x, slot, coeffs )

[ nsl, ncf ] = size ( coeffs ) ;

y = coeffs { slot, 1 };

for j = 2 : ncf
    y = y + coeffs { slot, j } * ( x )^( j - 1 );
end

end


function new_handles = getKcoeffs ( handles )

ncoeffs =  6;
slots   = 33;

handles.KcoeffPVs  = cell ( slots, ncoeffs );
handles.Kcoeffs    = cell ( slots, ncoeffs );
handles.XcoeffPVs  = cell ( slots, ncoeffs );
handles.Xcoeffs    = cell ( slots, ncoeffs );
%handles.InstallPVs = cell ( slots );
handles.Installed  = zeros ( 1, slots );

for slot = 1 : slots
%    handles.InstallPVs { slot } = sprintf ( 'USEG:UND1:%d50:INSTALTNSTAT', slot );    
%    handles.Installed  ( slot ) = lcaGet  ( handles.InstallPVs { slot }, 0, 'double' );
    handles.Installed  ( slot ) = isInstalled ( slot );
    
    for p = 1 : ncoeffs;
        handles.KcoeffPVs  { slot, p } = sprintf ( 'USEG:UND1:%d50:POLYKACT.%c', slot, char ( p + 64 ) );
        handles.Kcoeffs   { slot, p }  = lcaGet ( handles.KcoeffPVs { slot, p } );

        handles.XcoeffPVs  { slot, p } = sprintf ( 'USEG:UND1:%d50:POLYXDES.%c', slot, char ( p + 64 ) );
        handles.Xcoeffs   { slot, p }  = lcaGet ( handles.XcoeffPVs { slot, p } );

%        fprintf ( '%s = %f\n', handles.KcoeffPVs { slot , p }, handles.Kcoeffs { slot , p }  );
    end
end
    

new_handles = handles;

end


function Kvalues = loadPresentKvalues ( handles )

Kvalues = zeros ( 1, handles.Segments );

for slot = 1 : handles.Segments
    %disp(slot)
    if ( isActive ( slot,handles ) )
        Kvalues ( slot ) = getEquivalentKvalue ( slot, handles );
    end
end

end


function equKvalue = getEquivalentKvalue ( slot, handles )

equKvalue = 0;

if ( isActive ( slot,handles ) )
    if( getHarm ( slot ) <= 99 )
        actKvalue = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
        equKsquare = getHarm ( slot ) * ( actKvalue^2 + 2 ) - 2;
    else 
        equKvalue = read_delta_K_value(handles.SlotToDeltaUndulatorsConversion(slot),handles);
        return
    end
    
    if ( equKsquare > 0 )
        equKvalue = sqrt ( equKsquare );
    else
%fprintf ( 'slot %2.2d => actK : %6.4f (h=%d), equKsquare = %f.\n', slot, actKvalue, getHarm ( slot ), equKsquare );
        equKvalue = 0;
    end
else
    return
end

end


function K = equK2K ( equK, harm )

K = sqrt ( ( equK^2 + 2 ) / harm - 2 );

end


function equK = K2equK ( K, harm )

equKsquare = harm * ( K^2 + 2 ) - 2;
    
if ( equKsquare > 0 )
    equK = sqrt ( equKsquare );
else
    equK = 0;
end

end


function setKvalues ( handles, Kvalues )

start = 0;

for slot = 1 : handles.Segments
    if ( isActive ( slot,handles ) && Kvalues ( slot ) > 0 )        
        if ( ~start )
            start = Kvalues ( slot );
        end
        
        if ( start )
            relK = ( Kvalues ( slot ) - start ) / start * 10000;
        else
            relK = 0;
        end
%bbbbfunction K = equK2K ( equK, harm )

        if( getHarm ( slot ) <= 99 ) %this is not a delta!
            Kact = equK2K ( getEquivalentKvalue ( slot, handles ), getHarm ( slot ) );

    %        Kact = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );

            [ x, usedKvalue, changed ] = setKofSlot ( handles, Kvalues ( slot ), slot );

            if ( changed )
                fprintf ( '%2.2d: newK = %6.4f [was %+6.4f] (%5.1f 10^-4); x = %+6.3f mm [was %+6.3f mm].\n', ...
                    slot, usedKvalue, ...
                    Kact, ...
                    relK, ...
                    x, ...
                    lcaGet ( sprintf ( 'USEG:UND1:%d50:TMXPOSC', slot ) ) ...
                    );
            end
        else %this is a delta moving k corresponds to a move by ellipse settings, double-check is done in order to ensure that configuration is doable
            [ x, usedKvalue, changed ] = setKofSlot_for_delta ( handles, Kvalues ( slot ), slot );
            if ( changed )
                fprintf ( '%2.2d: newK = %6.4f \n', slot, usedKvalue );
            end
        end
    end
end

end

function setKvalues_with_undulator_selection ( handles, Kvalues, SelectionVector )

start = 0;

for slot = 1 : handles.Segments
    if(SelectionVector(slot))
    if ( isActive ( slot,handles ) && Kvalues ( slot ) > 0 )        
        if ( ~start )
            start = Kvalues ( slot );
        end
        
        if ( start )
            relK = ( Kvalues ( slot ) - start ) / start * 10000;
        else
            relK = 0;
        end
%bbbbfunction K = equK2K ( equK, harm )

        if( getHarm ( slot ) <=99 ) %this is not a delta!
            Kact = equK2K ( getEquivalentKvalue ( slot, handles ), getHarm ( slot ) );

    %        Kact = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );

            [ x, usedKvalue, changed ] = setKofSlot ( handles, Kvalues ( slot ), slot );

            if ( changed )
                fprintf ( '%2.2d: newK = %6.4f [was %+6.4f] (%5.1f 10^-4); x = %+6.3f mm [was %+6.3f mm].\n', ...
                    slot, usedKvalue, ...
                    Kact, ...
                    relK, ...
                    x, ...
                    lcaGet ( sprintf ( 'USEG:UND1:%d50:TMXPOSC', slot ) ) ...
                    );
            end
        else %this is a delta moving k corresponds to a move by ellipse settings, double-check is done in order to ensure that configuration is doable
            [ x, usedKvalue, changed ] = setKofSlot_for_delta ( handles, Kvalues ( slot ), slot );
            if ( changed )
                fprintf ( '%2.2d: newK = %6.4f \n', slot, usedKvalue );
            end
        end
    end
    end
end

end

function [ NewRows, usedKvalue, changed ] = setKofSlot_for_delta ( handles, Kvalue , slot )
changed           = false;
deltaslot = handles.SlotToDeltaUndulatorsConversion(slot);
%xThr              = 12; % mm
[DestinationKeff,DestinationFullState]=read_delta_K_destination_value(deltaslot,handles);
NewRows=DestinationFullState(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2));
usedKvalue=DestinationFullState(1);

disp('TESTING K Movement')
disp(['Desired K = ',num2str(Kvalue),'  Current Destination is ',num2str(DestinationKeff(1))])

if ( isUnderMaintenance ( slot ) || ~isInstalled ( slot ) || (strcmpi(lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1}),'Off')==1) )
    return;
end

if ( abs ( DestinationKeff - Kvalue ) > 5e-4 )
    
    if checkifinsiderange_for_scans(Kvalue, 1, handles, DestinationFullState,deltaslot) 
        [Stokes_Destination, Full_New_State]=update_parameters_from_ellipse_for_scans([Kvalue,DestinationFullState(2:end)],handles,deltaslot);
        Move_Rows_to_destination(Full_New_State, handles, deltaslot) %Reset Entire Destination and move rods
        changed = true;
        Deltaphi=deltagui_rod2Deltaphi(Full_New_State(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2)),handles, deltaslot);
        S=deltagui_Deltaphi2Stokes(Deltaphi,handles,deltaslot);
        usedKvalue=deltagui_S0toKeff(S(1),Full_New_State(2),handles, deltaslot);
        NewRows=Full_New_State(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2));
    end
end

end


function [ x, usedKvalue, changed ] = setKofSlot ( handles, equK, slot )

changed           = false;
xThr              = 12; % mm
Kact              = getEquivalentKvalue ( slot, handles );

Kvalue            = equK2K ( equK, getHarm ( slot ) );
%Kact              = lcaGet ( sprintf ( 'USEG:UND1:%d50:KACT', slot ) );
[ x, usedKvalue ] = get_inLimit_K ( handles, Kvalue, slot );

if ( isUnderMaintenance ( slot ) || ~isInstalled ( slot ) )
    return;
end

if ( abs ( Kact - Kvalue ) > 5e-4 )
    changed = true;

    if ( x <  xThr )
%fprintf ( 'Setting slot %2.2d to %f.\n', slot, usedKvalue );        
%        lcaPut ( sprintf ( 'USEG:UND1:%d50:KDES',      slot ), equK2K ( usedKvalue, 1 ) );
%??        lcaPut ( sprintf ( 'USEG:UND1:%d50:KDES',      slot ), usedKvalue );
%??        lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:TRIM.PROC', slot ), 1    );
        lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:TMXPOSC',   slot ), x );
        fprintf ( 'Setting slot %2.2d to x = %f; K = %f.\n', slot, x, usedKvalue );        
    else
        lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:TMXPOSC',   slot ), x );
    end
   
    lcaPutNoWait ( sprintf ( 'USEG:UND1:%d50:KDES', slot ), usedKvalue );
end

end


function [ x, K ] = get_inLimit_K ( handles, setK, slot )

xmin =  -5; % mm
xmax = +16; % mm

Koffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:KOFFSET', slot ) );
Xoffset = lcaGet ( sprintf ( 'USEG:UND1:%d50:XOFF',    slot ) );

x = min ( max ( - evalPoly ( setK - Koffset, slot, handles.Xcoeffs ) - Xoffset, xmin ), xmax );
K = evalPoly ( -x - Xoffset, slot, handles.Kcoeffs );

if ( abs ( K - setK ) < 5e-5 )
    K = setK;
end

end


function slide_adjust = getSlideAdjusts % temporary with slide adustments as suggested by MET.

slide_adjust = cell ( 33 );

slide_adjust { 13 } =   41;
slide_adjust { 14 } =   48;
slide_adjust { 15 } =  -17;
slide_adjust { 16 } =  146;
slide_adjust { 17 } =  -17;
slide_adjust { 18 } =  -45;
slide_adjust { 19 } =    8;
slide_adjust { 20 } =   28;
slide_adjust { 21 } =   -4;
slide_adjust { 22 } =  226;
slide_adjust { 23 } =  -54;
slide_adjust { 24 } =  -36;
slide_adjust { 25 } =   56;
slide_adjust { 26 } =  -18;
slide_adjust { 27 } =  136;
slide_adjust { 28 } =  197;
slide_adjust { 29 } =   27;
slide_adjust { 30 } =    9;
slide_adjust { 31 } =   37;
slide_adjust { 32 } =   64;
slide_adjust { 33 } =   91;

end


% --- Executes on button press in MAKE_TAPER_OFFICIAL.
function MAKE_TAPER_OFFICIAL_Callback(hObject, eventdata, handles)
% hObject    handle to MAKE_TAPER_OFFICIAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( isfield ( handles, 'fstSegment' ) )
    for slot = handles.fstSegment : 33
        if ( isActive ( slot,handles ) )
            lcaPut ( sprintf ( 'USEG:UND1:%d50:UPDATEXIN.PROC', slot ), 1 )
        end
    end
end

end


function  status = isUndercompressed ( handles )

compressionString = get ( handles.COMPRESSION_STATUS, 'String' );

if ( strfind ( upper ( compressionString ), 'UNDER' ) )
    status = true;
else
    status = false;
end

end


% --- Executes on button press in CHANGE_COMPRESSION_STATUS_BTN.
function CHANGE_COMPRESSION_STATUS_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to CHANGE_COMPRESSION_STATUS_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ( isUndercompressed ( handles ) )
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Overcompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Undercompression' );
else
    set ( handles.COMPRESSION_STATUS,            'String', 'Using Wakefields for Undercompression' );
    set ( handles.CHANGE_COMPRESSION_STATUS_BTN, 'String', 'Change to Overcompression' );
end

setSOFTPV ( handles.presentTaperParms, handles.ID_COMPRESSION_STATUS );

end


% --- Executes on button press in PRINTLOGBOOK.
function PRINTLOGBOOK_Callback(hObject, eventdata, handles)
% hObject    handle to PRINTLOGBOOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global timerData;

if ( handles.printTo_Files || handles.printTo_e_Log )
    plotK ( handles.log_axes, handles );

    title ( 'LCLS Undulator Taper Configuration', 'Parent', handles.log_axes  );
    
    textPos = estimatePosition ( 20, 16,  axis ( handles.log_axes ) );
    textStr = sprintf ( 'Energy: %6.3f GeV', getBeamEnergy ( handles ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    textPos = estimatePosition ( 20, 12,  axis ( handles.log_axes ) );
    textStr = sprintf ( 'Bunch Charge: %4.1f pC', getBunchCharge ( handles ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    textPos = estimatePosition ( 20,  8,  axis ( handles.log_axes ) );
    textStr = sprintf ( 'PeakCurrent: %7.1f A', getPeakCurrent ( handles ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    if ( useSpontaneous ( handles ) ) 
        textStr = sprintf ( 'SpontRad' );
    else
        textStr = sprintf ( 'No SpontRad' );
    end

    textPos = estimatePosition (  1,  16,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    if ( useWakefields ( handles ) )
        textStr = sprintf ( 'WakeFields' );
    else
        textStr = sprintf ( 'No WakeFields' );
    end

    textPos = estimatePosition (  1,  12,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );
    
    if ( addGainTaper ( handles ) )
        textStr = sprintf ( 'GainTaper' );
    else
        textStr = sprintf ( 'No GainTaper' );
    end

    textPos = estimatePosition (  1,   8,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );

    if ( addPostSaturationTaper ( handles ) )
        textStr = sprintf ( 'PostSatTaper' );
    else
        textStr = sprintf ( 'No PostSatTaper' );
    end

    textPos = estimatePosition ( 1 ,  4,  axis ( handles.log_axes ) );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'left', 'FontSize', 9, 'Parent', handles.log_axes );

    hold ( handles.log_axes, 'off' );
end

%fig = handles.log_fig;

% if ( fig )
    if ( handles.printTo_e_Log )
        print ( handles.log_fig, '-dpsc2', '-Pphysics-lclslog', '-adobecset' );
    end
    
    if ( handles.printTo_Files )
        figName = 'LCLS_TaperConfiguration';
        print ( handles.log_fig, '-dpdf',  '-r300', figName ); 
        print ( handles.log_fig, '-djpeg', '-r300', figName ); 
    end
    
    if ( handles.printTo_e_Log || handles.printTo_Files )
 %       delete ( handles.log_fig );
    end
% end
    
handles = saveData ( handles );

timerData.handles = handles;

% Update handles structure
guidata(hObject, handles);

end


% --- Executes when user attempts to close checkOP_gui.
function CloseRequestFcn ( hObject, eventdata, handles )

global timerRunning;
global timerObj;
global debug;

if ( timerRunning)
    if ( debug )
        fprintf ( 'Stopping Timer\n' );
    end
    
    stop ( timerObj );
    timerRunning = false;    
end

fprintf ( 'Closing  UndulatorTaperControl_gui.\n' );

util_appClose ( hObject );
%lcaClear ( );
lcaClear;

end


function FST_K_Callback(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FST_K as text
%        str2double(get(hObject,'String')) returns contents of FST_K as a double

global timerData;

got_newK = false;
old_fstK = get ( handles.FST_K, 'Value' );
fstK     = str2double ( get ( handles.FST_K, 'String' ) );

if ( isnan ( fstK ) )
    fstK        = old_fstK;
elseif ( isfield ( handles, 'fstSegment' ) )
    [ x, corrected_K ] = get_inLimit_K ( handles, fstK, handles.fstSegment );

    if ( abs ( corrected_K - fstK ) > 5e-4 )
        fstK= old_fstK;
    else
        got_newK = true;
    end
end

if ( got_newK )
    set ( handles.FST_K, 'String', sprintf ( '%6.4f', fstK ) );
    set ( handles.FST_K, 'Value',  fstK );

    setKofSlot ( handles, fstK, handles.fstSegment );
    handles.moving_fstK = true;
end

timerData.handles = handles;

% Update handles structure
guidata ( hObject, handles );

end


% --- Executes during object creation, after setting all properties.
function FST_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set ( hObject,'BackgroundColor','white' );
end

end


% --- Executes on button press in AUTO_MOVE_CHECKBOX.
function AUTO_MOVE_CHECKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to AUTO_MOVE_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AUTO_MOVE_CHECKBOX
hobj_state=get ( handles.AUTO_MOVE_CHECKBOX, 'Value' );
if ( hobj_state )
%     set ( handles.APPLY, 'Visible', 'Off' );
    lcaPut([handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'], 0);
    pause (2);                                                             % pause to allow all instances to update
    lcaPut([handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'], 1);
    set ( handles.AUTO_MOVE_CHECKBOX, 'Value', 1 );
else
%     set ( handles.APPLY, 'Visible', 'On' );
    lcaPut([handles.presentTaperParms{handles.ID_AUTOMOVE}.PV '.VAL'], 0);
end
end

% --- Executes on button press in DeltaMoveWhenValueChanges.
function DeltaMoveWhenValueChanges_Callback(hObject, eventdata, handles)
set(hObject,'value',1); set(handles.DeltaMovesWhenMOVE,'value',0);
end

% --- Executes on button press in DeltaMovesWhenMOVE.
function DeltaMovesWhenMOVE_Callback(hObject, eventdata, handles)
set(hObject,'value',1); set(handles.DeltaMoveWhenValueChanges,'value',0);
end

% --- Executes on button press in MoveButton.
function MoveButton_Callback(hObject, eventdata, handles) %this moves the rows for the selected undulator
deltaslot=get(handles.WhichDeltaUndulator,'value');
for II=1:(handles.NumberOfDeltaParameters-4)
    if(II<=4)
      ZVector_GuiInput(II)=str2double(get(handles.DeltaPvNamesCell{handles.DeltaRodsParameters(1)+II-1,7},'String'));
      lcaPutNoWait(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9},ZVector_GuiInput(II)); %Writes Rows
    end
    GuiInput_Status(II)=str2double(get(handles.DeltaPvNamesCell{II,7},'String'));
end
for II=1:5
    lcaPut(handles.AllDeltaUndulators{deltaslot,II,9},GuiInput_Status(II)); %Writes the other parameters to destination (even if not used yet)
end
Status_Destination=[GuiInput_Status,ZVector_GuiInput];
for II=1:handles.NumberOfDeltaParameters %After moving resets any scan
    lcaPut(handles.DeltaPvNamesCell{II,4},Status_Destination(II));
end
end

function Move_Rows_to_destination(Destination, handles, deltaslot)
for II=1:4
   lcaPutNoWait(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9},Destination(handles.DeltaRodsParameters(1)+II-1));
   lcaPutNoWait(handles.AllDeltaUndulators{deltaslot,II,9},Destination(II));
end
lcaPut(handles.AllDeltaUndulators{deltaslot,II+1,9},Destination(II+1));
for II=1:handles.NumberOfDeltaParameters %After moving resets any scan
    lcaPutNoWait(handles.DeltaPvNamesCell{II,4},Destination(II));
end
end

% --- Executes on button press in DeltaOffButton.
function DeltaOffButton_Callback(hObject, eventdata, handles) %Turns The Delta Off, to be rewritten according to OFF PV
deltaslot=get(handles.WhichDeltaUndulator,'value');
CurrentStatus=strcmpi(lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1}),'Off'); %checks for the destination and eventually changes it
if(CurrentStatus) % it is off, turn it on
    lcaPut(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1},'On'); %Corretto
    set(handles.DeltaActiveString,'String','Delta is ON','backgroundcolor',[0,1,0]);
    DeltaResetScan_Callback(hObject, eventdata, handles);
    set(handles.MoveButton,'enable','on'); set(handles.Deltalistenbutton,'enable','on');  
else %it is on, turn it off
    set(handles.DeltaActiveString,'String','Delta going OFF','backgroundcolor',[1,1,0]);
    set(handles.MoveButton,'enable','off'); set(handles.Deltalistenbutton,'enable','off');
    lcaPut(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1},'Off');
    Harmonic=1;
    for II=1:4
        DeltaParkPosition(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+2,II});
    end    
        Deltaphi=deltagui_rod2Deltaphi(DeltaParkPosition,handles, deltaslot);
        S=deltagui_Deltaphi2Stokes(Deltaphi,handles,deltaslot);
        EP=deltagui_Stokes2Ellipse(S); EP(3)=0;
        ZAvgs=deltagui_Rods2RodsAverages(DeltaParkPosition);
        Keff=deltagui_S0toKeff(S,Harmonic,handles, deltaslot);
        Status_Destination=[Keff,Harmonic,EP(2:4),ZAvgs,DeltaParkPosition];
        for II=1:4 %this resets twice the status, not really needed
               lcaPut(handles.AllDeltaUndulators{deltaslot,II,9},Status_Destination(II));
               lcaPut(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9},DeltaParkPosition(II));
        end
        lcaPut(handles.AllDeltaUndulators{deltaslot,II+1,9},Status_Destination(II+1));
        for II=1:handles.NumberOfDeltaParameters % Resets entire scan destination
             lcaPut(handles.DeltaPvNamesCell{II,4},Status_Destination(II));
        end
end
end

% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end

% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end

% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end


function p_des13_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=13;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,1,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des12_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=12;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,1,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des14_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=14;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,1,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function p_des10_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=10;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,2,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function p_des5_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=5; deltaslot=get(handles.WhichDeltaUndulator,'value');
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_ellipse(handles,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function p_des3_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=3; deltaslot=get(handles.WhichDeltaUndulator,'value');
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_ellipse(handles, deltaslot);
save TEMPP3
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des4_Callback(hObject, eventdata, handles) %Angle
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=4; deltaslot=get(handles.WhichDeltaUndulator,'value');
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
if(PASS==1)
   if(NewNumericInput<1)
      if(str2double(get(handles.p_des5,'String') )==0)
          set(handles.p_des5,'String','1');
      end
   else
       set(handles.p_des5,'String','0');
   end
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_ellipse(handles, deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des2_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=2; deltaslot=get(handles.WhichDeltaUndulator,'value');
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_ellipse(handles, deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
end

function update_parameters_from_ellipse(handles,deltaslot)
    Keff=str2double(get(handles.p_des1,'String'));
    Harmonic=str2double(get(handles.p_des2,'String'));
    Ellipse_Destination=[deltagui_Keff2S0(Keff,Harmonic,handles,deltaslot),str2double(get(handles.p_des3,'String')),str2double(get(handles.p_des4,'String')),str2double(get(handles.p_des5,'String'))];
    CurrentRodPosition=[lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1),10}),lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+1,10}),lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+2,10}),lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+3,10})];
    Stokes=deltagui_Ellipse2Stokes(Ellipse_Destination);
    if(Stokes(1)==0)
       Restorep4=str2double(get(handles.p_des4,'String'));
    end
    [~,DeltaPhiMatrix]=deltagui_Stokes2Deltaphi(Stokes,handles, deltaslot);
    Movement_type=get(handles.DeltaMovementType,'value');
    Rods=deltagui_Deltaphi2Rods(DeltaPhiMatrix,CurrentRodPosition,Movement_type,handles,deltaslot);
    Status_Destination=[Keff,Harmonic,Ellipse_Destination(2:4),deltagui_Rods2RodsAverages(Rods),Rods];
    if(Stokes(1)==0)
        Status_Destination(4)=Restorep4;
    end
    for II=1:handles.NumberOfDeltaParameters
       set(handles.DeltaPvNamesCell{II,7},'String',num2str(Status_Destination(II),handles.DeltaPvNamesCell{II,11})); 
    end
end

function [New_Rows_Position, Full_New_State]=update_parameters_from_ellipse_for_scans(Destination,handles,deltaslot) %Destination is the full destination with one value changed   
    Keff=Destination(1); Keff_Old=Keff;
    Harmonic=Destination(2);
    Ellipse_Destination=[deltagui_Keff2S0(Keff,Harmonic,handles,deltaslot),Destination(3:5)];
    CurrentRodPosition=[lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1),10}),lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+1,10}),lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+2,10}),lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+3,10})];
    Stokes=deltagui_Ellipse2Stokes(Ellipse_Destination);
    [~,DeltaPhiMatrix]=deltagui_Stokes2Deltaphi(Stokes,handles, deltaslot);
    Movement_type=get(handles.DeltaMovementType,'value');
    New_Rows_Position=deltagui_Deltaphi2Rods(DeltaPhiMatrix,CurrentRodPosition,Movement_type,handles,deltaslot);
    
    %Reevaluate initial state from rods !
    
    Deltaphi=deltagui_rod2Deltaphi(New_Rows_Position,handles, deltaslot);
    S=deltagui_Deltaphi2Stokes(Deltaphi,handles,deltaslot);
    Keff=deltagui_S0toKeff(S,Harmonic,handles, deltaslot);
    disp(['Evaluated Keff = ',num2str(Keff),'Required Keff = ',num2str(Keff_Old)])
    EP=deltagui_Stokes2Ellipse(S);
    Full_New_State=[Keff,Harmonic,EP(2:4),deltagui_Rods2RodsAverages(New_Rows_Position),New_Rows_Position];
end

function [Stokes, Full_New_State]=update_parameters_from_rods_for_scans(Destination,handles,BoxChanged,deltaslot)
%BoxChanged=1 Rods changes, BoxChanged=2 Rods AVGs changes, BoxChanged=3,
%4 Rods AVG changed
switch(BoxChanged)
    case 1
        New_Rows_Position=Destination(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2));
    case 2
        RodsAVGs=Destination(-4+(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2)));
        New_Rows_Position=deltagui_RodsAverages2Rods(RodsAVGs);
    case 3
        Rods=Destination(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2));
        FourRodsAVg=Destination(-5+handles.DeltaRodsParameters(1));
        New_Rows_Position=Rods-mean(Rods)+FourRodsAVg;
end
Stokes=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(New_Rows_Position,handles, deltaslot),handles,deltaslot);
Ellipse_Destination=deltagui_Stokes2Ellipse(Stokes);
Keff=deltagui_S0toKeff(Stokes,Destination(2),handles, deltaslot);
Full_New_State=[Keff,Destination(2),Ellipse_Destination(2:4),deltagui_Rods2RodsAverages(New_Rows_Position),New_Rows_Position];
end

function update_parameters_from_rods(handles,BoxChanged,deltaslot)
%BoxChanged=1 Rods changes, BoxChanged=2 Rods AVGs changes, BoxChanged=3,
%4 Rods AVG changed
Harmonic=str2double(get(handles.p_des2,'String'));
switch(BoxChanged)
    case 1
        for II=1:4
            Rods(II)=str2double(get(handles.DeltaPvNamesCell{handles.DeltaRodsParameters(1)+II-1,7},'String'));
        end
    case 2
        for II=1:4
            RodsAVGs(II)=str2double(get(handles.DeltaPvNamesCell{6+II,7},'String'));
        end
        Rods=deltagui_RodsAverages2Rods(RodsAVGs);
    case 3
        for II=1:4
            Rods(II)=str2double(get(handles.DeltaPvNamesCell{handles.DeltaRodsParameters(1)+II-1,7},'String'));
        end
        FourRodsAVg=str2double(get(handles.DeltaPvNamesCell{6,7},'String'));
        Rods=Rods-mean(Rods)+FourRodsAVg;
end
Stokes=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(Rods,handles, deltaslot),handles,deltaslot);
if(Stokes(1)==0)
    Restorep4=str2double(get(handles.p_des4,'String'));
end
Ellipse_Destination=deltagui_Stokes2Ellipse(Stokes);
Keff=deltagui_S0toKeff(Stokes,Harmonic,handles, deltaslot);
Status_Destination=[Keff,Harmonic,Ellipse_Destination(2:4),deltagui_Rods2RodsAverages(Rods),Rods];
if(Stokes(1)==0)
        Status_Destination(4)=Restorep4;
end
    for II=1:handles.NumberOfDeltaParameters
       set(handles.DeltaPvNamesCell{II,7},'String',num2str(Status_Destination(II),handles.DeltaPvNamesCell{II,11})); 
    end
end

% --- Executes during object creation, after setting all properties.
function p_des2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des9_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=9;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,2, deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des11_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=11;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,1,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des7_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=7;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,2,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function p_des6_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=6;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,3,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function OUT=check_if_scalar_double(IN)
    INn=str2num(IN);
    if(numel(INn)~=1)
        OUT=NaN;return
    else
        if(isnan(INn))
            OUT=NaN;return
        end
        if(isinf(INn))
            OUT=NaN;return
        end
    end
    OUT=INn;
end

function OUT=check_if_scalar_double_for_scans(INn)
    if(~isnumeric(INn))
       OUT=NaN; return 
    end
    if(numel(INn)~=1)
        OUT=NaN;return
    else
        if(isnan(INn))
            OUT=NaN;return
        end
        if(isinf(INn))
            OUT=NaN;return
        end
    end
    OUT=INn;
end

function OUT=checkifinsiderange(INNumeric, ID, handles,PASS, deltaslot)
    OUT=PASS;
    Gui_Input=ReadAllGuiInput(handles);
    Range=deltagui_InputParameterLimits(handles,ID,Gui_Input, deltaslot);
    S=size(Range);
    for II=1:S(1)
        if(strcmp(handles.DeltaPvNamesCell{ID,5},'double'))
            if( (INNumeric>=Range(II,1) ) && (INNumeric<=Range(II,2) ) )
                OUT=1;
            end
        else
            if(any(INNumeric==Range))
                OUT=1;
            end
        end
    end
end

function OUT=checkifinsiderange_for_scans(INNumeric, ID, handles, Destination_Vector, deltaslot)
    OUT=0;
    Range=deltagui_InputParameterLimits(handles,ID,Destination_Vector, deltaslot);
    S=size(Range);
    for II=1:S(1)
        if(strcmp(handles.DeltaPvNamesCell{ID,5},'double'))
            if( (INNumeric>=Range(II,1) ) && (INNumeric<=Range(II,2) ) )
                OUT=1;
            end
        else
            if(any(INNumeric==Range))
                OUT=1;
            end
        end
    end
end

function RestoreOrUpdate(handles,PASS,NewInput,ID)
    switch PASS
        case -1
            set(handles.delta_dialogBox,'String',[handles.DeltaPvNamesCell{ID,1},' change denied because of value outside allowed range']); 
            OldInput=get(handles.DeltaPvNamesCell{ID,7},'UserData');
            set(handles.DeltaPvNamesCell{ID,7},'String',OldInput);
        case 0
            set(handles.delta_dialogBox,'String',[handles.DeltaPvNamesCell{ID,1},' change denied because of unrecognized input']) 
            OldInput=get(handles.DeltaPvNamesCell{ID,7},'UserData');
            set(handles.DeltaPvNamesCell{ID,7},'String',OldInput);
        case 1
            set(handles.DeltaPvNamesCell{ID,7},'UserData',NewInput);
            set(handles.DeltaPvNamesCell{ID,7},'String',num2str(str2num(NewInput),handles.DeltaPvNamesCell{ID,11}));
            set(handles.delta_dialogBox,'String','') ;
    end
end

function p_des1_Callback(hObject, eventdata, handles)
PASS=-1; ID=1; deltaslot=get(handles.WhichDeltaUndulator,'value');
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_ellipse(handles, deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
end

% --- Executes during object creation, after setting all properties.
function p_des1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in SynchronizaDesActOnce.
function SynchronizaDesActOnce_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
for II=1:4
      ZVector_Current(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,10});
end
Deltaphi_Current=deltagui_rod2Deltaphi(ZVector_Current,handles, deltaslot);
Stokes_Current=deltagui_Deltaphi2Stokes(Deltaphi_Current,handles,deltaslot);
Ellipse_Current=deltagui_Stokes2Ellipse(Stokes_Current);
Harmonic_Current=lcaGet(handles.AllDeltaUndulators{deltaslot,2,10});
Keff=deltagui_S0toKeff(Stokes_Current,Harmonic_Current,handles, deltaslot);

Status_Current=[Keff,Harmonic_Current,Ellipse_Current(2:4),deltagui_Rods2RodsAverages(ZVector_Current),ZVector_Current];
if(Stokes_Current(1)==0)
    Status_Current(4)=0; Status_Current(5)=1; %if unknown set circular, with chirality=1
end
for II=1:handles.NumberOfDeltaParameters
   set(handles.DeltaPvNamesCell{II,7},'String',num2str(Status_Current(II),handles.DeltaPvNamesCell{II,11})); 
   set(handles.DeltaPvNamesCell{II,7},'UserData',num2str(Status_Current(II),handles.DeltaPvNamesCell{II,11}));
end

CurrentPhaseShifter=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.FirstPhaseShifterPVLocation,6});
set(handles.p_des15,'String',num2str(CurrentPhaseShifter,handles.AllDeltaUndulators{deltaslot,handles.FirstPhaseShifterPVLocation,11}));
set(handles.p_des15,'UserData',CurrentPhaseShifter);
set(handles.p_readback15,'String',num2str(CurrentPhaseShifter,handles.AllDeltaUndulators{deltaslot,handles.FirstPhaseShifterPVLocation,11}));

CurrentKindOfFit=get(handles.KindOfFit,'value');
if(CurrentKindOfFit>2)
    KindOfFit_Callback(hObject, eventdata, handles)
end

end


% --- Executes on button press in SynchronizeDesActAlways.
function SynchronizeDesActAlways_Callback(hObject, eventdata, handles)
if(strcmp(get(hObject,'string'),'Always Synch. In.: OFF'))
   set(handles.SynchronizeDesActAlways,'UserData',1); 
   set(handles.SynchronizeDesActAlways,'String','Always Synch. In.: ON'); 
else
   set(handles.SynchronizeDesActAlways,'UserData',0); 
   set(handles.SynchronizeDesActAlways,'String','Always Synch. In.: OFF'); 
end
end


% --- Executes on button press in DeltaMoveSingleRods.
function DeltaMoveSingleRods_Callback(hObject, eventdata, handles)
% hObject    handle to DeltaMoveSingleRods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in DeltaMoveUndulator12.
function DeltaMoveUndulator12_Callback(hObject, eventdata, handles)
% hObject    handle to DeltaMoveUndulator12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function handles=BuildDeltaMenuHelp(handles, Current_GuiInput, deltaslot)
    for II=1:handles.NumberOfDeltaParameters
       helpstring='';
       Range=deltagui_InputParameterLimits(handles,II,Current_GuiInput, deltaslot);
       if(strcmpi(handles.DeltaPvNamesCell{II,5},'double_or_integer_angle'))
          if(get(handles.KindOfFit,'value')==1)
                helpstring=[handles.DeltaPvNamesCell{II,1} ,char(32),char(13),'Allowed Values {'];
                for KK=1:length(Range)
                   if(KK>1)
                       helpstring=[helpstring,','];
                   end
                   helpstring=[helpstring,num2str(Range(KK))]; 
                end    
                helpstring=[helpstring,'}',char(32),char(13),'Scan Pv: ',handles.DeltaPvNamesCell{II,4}]; 
          else
               SizeRange=size(Range);
               helpstring=[handles.DeltaPvNamesCell{II,1} ,char(32),char(13),'Allowed Range '];
               for KK=1:SizeRange(1)
                   if(KK>1)
                       helpstring=[helpstring,' OR '];
                   end
                   helpstring=[helpstring,'[',num2str(Range(KK,1)),',',num2str(Range(KK,2)),']']; 
               end
               helpstring=[helpstring,char(13),char(32),'Scan Pv: ',handles.DeltaPvNamesCell{II,4}]; 
          end
       elseif(strcmpi(handles.DeltaPvNamesCell{II,5},'double'))
           SizeRange=size(Range);
           helpstring=[handles.DeltaPvNamesCell{II,1} ,char(32),char(13),'Allowed Range '];
           for KK=1:SizeRange(1)
               if(KK>1)
                   helpstring=[helpstring,' OR '];
               end
               helpstring=[helpstring,'[',num2str(Range(KK,1)),',',num2str(Range(KK,2)),']']; 
           end
           helpstring=[helpstring,char(13),char(32),'Scan Pv: ',handles.DeltaPvNamesCell{II,4}];
       elseif(strcmpi(handles.DeltaPvNamesCell{II,5},'integer'))
            helpstring=[handles.DeltaPvNamesCell{II,1} ,char(32),char(13),'Allowed Values {'];
            for KK=1:length(Range)
               if(KK>1)
                   helpstring=[helpstring,','];
               end
               helpstring=[helpstring,num2str(Range(KK))]; 
           end    
            helpstring=[helpstring,'}',char(32),char(13),'Scan Pv: ',handles.DeltaPvNamesCell{II,4}]; 
            %helpstring={[handles.DeltaPvNamesCell{II,1} ,char(32),char(13)],['Allowed Values {',num2str(handles.DeltaPvNamesCell{II,2}:handles.DeltaPvNamesCell{II,3}),'}',char(32),char(13)],['PvName: ',handles.DeltaPvNamesCell{II,4}]}; 
       end
       set(handles.DeltaPvNamesCell{II,6},'TooltipString',helpstring);
    end
    set(handles.p_name15,'TooltipString',['Phase Shifter; Range: [',num2str(handles.AllPhaseShifters(deltaslot).minimum), ',' ,num2str(handles.AllPhaseShifters(deltaslot).maximum) ,']; Scan PV: ',handles.PhaseShifterScanPVName(1:10),handles.DeltaUndulatorList{deltaslot}(1:2),handles.PhaseShifterScanPVName(13:19)]);
end

function new_handles=DeltaPvNames(handles)
    new_handles=handles;
    % K value
    DeltaPvNamesCell{1,1}='Equivalent K'; %K 
    DeltaPvNamesCell{1,2}=0; %min
    DeltaPvNamesCell{1,3}=50; %max
    DeltaPvNamesCell{1,4}='SIOC:SYS0:ML02:AO336'; %scan pvname
    DeltaPvNamesCell{1,5}='double'; %type
    DeltaPvNamesCell{1,6}=handles.p_name1;
    DeltaPvNamesCell{1,7}=handles.p_des1;
    DeltaPvNamesCell{1,8}=handles.p_readback1;
    DeltaPvNamesCell{1,9}='USEG:UND1:3350:KDES'; 
    DeltaPvNamesCell{1,10}='USEG:UND1:3350:KACT'; 
    DeltaPvNamesCell{1,11}='%.4f'; 
    
    
    % Harmonic Number
    DeltaPvNamesCell{2,1}='Harmonic Number';
    DeltaPvNamesCell{2,2}=1;
    DeltaPvNamesCell{2,3}=5;
    DeltaPvNamesCell{2,4}='SIOC:SYS0:ML02:AO337';
    DeltaPvNamesCell{2,5}='integer';
    DeltaPvNamesCell{2,6}=handles.p_name2;
    DeltaPvNamesCell{2,7}=handles.p_des2;
    DeltaPvNamesCell{2,8}=handles.p_readback2;
    DeltaPvNamesCell{2,9}='USEG:UND1:3350:HARMDES'; 
    DeltaPvNamesCell{2,10}='USEG:UND1:3350:HARMACT'; 
    DeltaPvNamesCell{2,11}='%d';
    
    % Angle Degree Chirality
    DeltaPvNamesCell{3,1}='Angle';
    DeltaPvNamesCell{3,2}=-90;
    DeltaPvNamesCell{3,3}=90;
    DeltaPvNamesCell{3,4}='SIOC:SYS0:ML02:AO338';
    DeltaPvNamesCell{3,5}='double_or_integer_angle';
    DeltaPvNamesCell{3,6}=handles.p_name3;
    DeltaPvNamesCell{3,7}=handles.p_des3;
    DeltaPvNamesCell{3,8}=handles.p_readback3;
    DeltaPvNamesCell{3,9}='USEG:UND1:3350:POLANGLEDES'; 
    DeltaPvNamesCell{3,10}='USEG:UND1:3350:POLANGLEACT'; % FIN QUI OK
    DeltaPvNamesCell{3,11}='%.4f'; 
    
    DeltaPvNamesCell{4,1}='Degree of linear polarization';
    DeltaPvNamesCell{4,2}=0;
    DeltaPvNamesCell{4,3}=1;
    DeltaPvNamesCell{4,4}='SIOC:SYS0:ML02:AO339';
    DeltaPvNamesCell{4,5}='double';
    DeltaPvNamesCell{4,6}=handles.p_name4;
    DeltaPvNamesCell{4,7}=handles.p_des4;
    DeltaPvNamesCell{4,8}=handles.p_readback4;
    DeltaPvNamesCell{4,9}='USEG:UND1:3350:DEGREELINPOLDES'; 
    DeltaPvNamesCell{4,10}='USEG:UND1:3350:DEGREELINPOLACT';
    DeltaPvNamesCell{4,11}='%.5f'; 
    
    DeltaPvNamesCell{5,1}='Chirality';
    DeltaPvNamesCell{5,2}=-1;
    DeltaPvNamesCell{5,3}=1;
    DeltaPvNamesCell{5,4}='SIOC:SYS0:ML02:AO340';
    DeltaPvNamesCell{5,5}='integer';
    DeltaPvNamesCell{5,6}=handles.p_name5;
    DeltaPvNamesCell{5,7}=handles.p_des5;
    DeltaPvNamesCell{5,8}=handles.p_readback5;
    DeltaPvNamesCell{5,9}='USEG:UND1:3350:CHIRALITYDES'; 
    DeltaPvNamesCell{5,10}='USEG:UND1:3350:CHIRALITYACT';
    DeltaPvNamesCell{5,11}='%d';
    
    % Undulator 1 and 2 z motions
    
    DeltaPvNamesCell{6,1}='<z>';
    DeltaPvNamesCell{6,2}=-17;
    DeltaPvNamesCell{6,3}=17;
    DeltaPvNamesCell{6,4}='SIOC:SYS0:ML02:AO341';
    DeltaPvNamesCell{6,5}='double';
    DeltaPvNamesCell{6,6}=handles.p_name6;
    DeltaPvNamesCell{6,7}=handles.p_des6;
    DeltaPvNamesCell{6,8}=handles.p_readback6;
    DeltaPvNamesCell{6,9}='';
    DeltaPvNamesCell{6,10}='';
    DeltaPvNamesCell{6,11}='%.4f';
    
    DeltaPvNamesCell{7,1}='Delta z13';
    DeltaPvNamesCell{7,2}=-34;
    DeltaPvNamesCell{7,3}=34;
    DeltaPvNamesCell{7,4}='SIOC:SYS0:ML02:AO342';
    DeltaPvNamesCell{7,5}='double';
    DeltaPvNamesCell{7,6}=handles.p_name7;
    DeltaPvNamesCell{7,7}=handles.p_des7;
    DeltaPvNamesCell{7,8}=handles.p_readback7;
    DeltaPvNamesCell{7,9}='';
    DeltaPvNamesCell{7,10}='';
    DeltaPvNamesCell{7,11}='%.4f';
    
    DeltaPvNamesCell{8,1}='<z13>';
    DeltaPvNamesCell{8,2}=-17;
    DeltaPvNamesCell{8,3}=17;
    DeltaPvNamesCell{8,4}='SIOC:SYS0:ML02:AO343';
    DeltaPvNamesCell{8,5}='double';
    DeltaPvNamesCell{8,6}=handles.p_name8;
    DeltaPvNamesCell{8,7}=handles.p_des8;
    DeltaPvNamesCell{8,8}=handles.p_readback8;
    DeltaPvNamesCell{8,9}='';
    DeltaPvNamesCell{8,10}='';
    DeltaPvNamesCell{8,11}='%.4f';
    
    DeltaPvNamesCell{9,1}='Delta z24';
    DeltaPvNamesCell{9,2}=-34;
    DeltaPvNamesCell{9,3}=34;
    DeltaPvNamesCell{9,4}='SIOC:SYS0:ML02:AO344';
    DeltaPvNamesCell{9,5}='double';
    DeltaPvNamesCell{9,6}=handles.p_name9;
    DeltaPvNamesCell{9,7}=handles.p_des9;
    DeltaPvNamesCell{9,8}=handles.p_readback9;
    DeltaPvNamesCell{9,9}='';
    DeltaPvNamesCell{9,10}='';
    DeltaPvNamesCell{9,11}='%.4f';
    
    DeltaPvNamesCell{10,1}='<z24>';
    DeltaPvNamesCell{10,2}=-17;
    DeltaPvNamesCell{10,3}=17;
    DeltaPvNamesCell{10,4}='SIOC:SYS0:ML02:AO345';
    DeltaPvNamesCell{10,5}='double';
    DeltaPvNamesCell{10,6}=handles.p_name10;
    DeltaPvNamesCell{10,7}=handles.p_des10;
    DeltaPvNamesCell{10,8}=handles.p_readback10;
    DeltaPvNamesCell{10,9}='';
    DeltaPvNamesCell{10,10}='';
    DeltaPvNamesCell{10,11}='%.4f';
     
    % Single Rods control
    DeltaPvNamesCell{11,1}='Row 1';
    DeltaPvNamesCell{11,2}=-17;
    DeltaPvNamesCell{11,3}=17;
    DeltaPvNamesCell{11,4}='SIOC:SYS0:ML02:AO346';
    DeltaPvNamesCell{11,5}='double';
    DeltaPvNamesCell{11,6}=handles.p_name11;
    DeltaPvNamesCell{11,7}=handles.p_des11;
    DeltaPvNamesCell{11,8}=handles.p_readback11;
    DeltaPvNamesCell{11,9}='USEG:UND1:3350:1:MOTR'; %Delta Row 1 Destination
    DeltaPvNamesCell{11,10}='USEG:UND1:3350:1:MOTR.RBV'; %Delta Rod 1 ReadBackValue
    DeltaPvNamesCell{11,11}='%.4f';
    
    DeltaPvNamesCell{12,1}='Row 2';
    DeltaPvNamesCell{12,2}=-17;
    DeltaPvNamesCell{12,3}=17;
    DeltaPvNamesCell{12,4}='SIOC:SYS0:ML02:AO347';
    DeltaPvNamesCell{12,5}='double';
    DeltaPvNamesCell{12,6}=handles.p_name12;
    DeltaPvNamesCell{12,7}=handles.p_des12;
    DeltaPvNamesCell{12,8}=handles.p_readback12;
    DeltaPvNamesCell{12,9}='USEG:UND1:3350:2:MOTR'; %Delta Row 2 Destination
    DeltaPvNamesCell{12,10}='USEG:UND1:3350:2:MOTR.RBV'; %Delta Rod 2 ReadBackValue
    DeltaPvNamesCell{12,11}='%.4f';
    
    DeltaPvNamesCell{13,1}='Row 3';
    DeltaPvNamesCell{13,2}=-17;
    DeltaPvNamesCell{13,3}=17;
    DeltaPvNamesCell{13,4}='SIOC:SYS0:ML02:AO348';
    DeltaPvNamesCell{13,5}='double';
    DeltaPvNamesCell{13,6}=handles.p_name13;
    DeltaPvNamesCell{13,7}=handles.p_des13;
    DeltaPvNamesCell{13,8}=handles.p_readback13;
    DeltaPvNamesCell{13,9}='USEG:UND1:3350:3:MOTR'; %Delta Row 1 Destination
    DeltaPvNamesCell{13,10}='USEG:UND1:3350:3:MOTR.RBV'; %Delta Rod 1 ReadBackValue
    DeltaPvNamesCell{13,11}='%.4f';
    
    DeltaPvNamesCell{14,1}='Row 4';
    DeltaPvNamesCell{14,2}=-17;
    DeltaPvNamesCell{14,3}=17;
    DeltaPvNamesCell{14,4}='SIOC:SYS0:ML02:AO349';
    DeltaPvNamesCell{14,5}='double';
    DeltaPvNamesCell{14,6}=handles.p_name14;
    DeltaPvNamesCell{14,7}=handles.p_des14;
    DeltaPvNamesCell{14,8}=handles.p_readback14;
    DeltaPvNamesCell{14,9}='USEG:UND1:3350:4:MOTR'; %Delta Row 1 Destination
    DeltaPvNamesCell{14,10}='USEG:UND1:3350:4:MOTR.RBV'; %Delta Rod 1 ReadBackValue
    DeltaPvNamesCell{14,11}='%.4f';
        
    DeltaPvNamesCell{15,1}='USEG:UND1:3350:OFFCMD';
    DeltaPvNamesCell{15,2}='USEG:UND1:3350:OFFACT';
    DeltaPvNamesCell{15,3}='USEG:UND1:3350:OFF.TOL';
    DeltaPvNamesCell{15,4}='USEG:UND1:3350:OFF.DIS';
        
    DeltaPvNamesCell{16,1}='USEG:UND1:3350:1:MOFF';
    DeltaPvNamesCell{16,2}='USEG:UND1:3350:2:MOFF';
    DeltaPvNamesCell{16,3}='USEG:UND1:3350:3:MOFF';
    DeltaPvNamesCell{16,4}='USEG:UND1:3350:4:MOFF';
    
    DeltaPvNamesCell{17,1}='USEG:UND1:3350:KMAX';
    DeltaPvNamesCell{17,2}=3.66;
    DeltaPvNamesCell{17,3}='USEG:UND1:3350:UNDPERIOD';
    DeltaPvNamesCell{17,4}=32;
    
    PhaseShifterNamesCell{1,1}='PHAS:UND1:3350:MOTR';
    PhaseShifterNamesCell{1,2}='PHAS:UND1:3350:MOTR.DESC';
    PhaseShifterNamesCell{1,3}='PHAS:UND1:3350:MOTR.EGU';
    PhaseShifterNamesCell{1,4}='PHAS:UND1:3350:MOTR.LOPR';
    PhaseShifterNamesCell{1,5}='PHAS:UND1:3350:MOTR.HOPR';
    
%     PhaseShifterNamesCell{1,1}='PHAS:UND1:3350:MOTR';
%     PhaseShifterNamesCell{1,2}='PHAS:UND1:3350:MOTR.DESC';
%     PhaseShifterNamesCell{1,3}='PHAS:UND1:3350:MOTR.EGU';
%     PhaseShifterNamesCell{1,4}='PHAS:UND1:3350:MOTR.LOPR';
%     PhaseShifterNamesCell{1,5}='PHAS:UND1:3350:MOTR.HOPR';
    
    PhaseShifterNamesCell{1,6}='PHAS:UND1:3350:ENC';
    PhaseShifterNamesCell{1,7}='PHAS:UND1:3350:ENC.DESC';
    PhaseShifterNamesCell{1,8}='PHAS:UND1:3350:ENC.EGU';
    PhaseShifterNamesCell{1,9}='PHAS:UND1:3350:ENC.LOPR';
    PhaseShifterNamesCell{1,10}='PHAS:UND1:3350:ENC.HOPR';
    PhaseShifterNamesCell{1,11}='%.4f';
    
    new_handles.PhaseShifterNamesCell=PhaseShifterNamesCell;
    new_handles.DeltaPvNamesCell=DeltaPvNamesCell;
    new_handles.NumberOfDeltaParameters=14;
    new_handles.NumberOfDeltaSpecialPVs=3; %Off Positions, and more stuff
    new_handles.FirstPhaseShifterPVLocation=new_handles.NumberOfDeltaParameters+new_handles.NumberOfDeltaSpecialPVs+1;
    new_handles.DeltaRodsParameters=[11,14];
  
    new_handles.DeltaType=100;
    new_handles.iSASEConsts.iSASETaperScanName='SIOC:SYS0:ML02:AO350';
    new_handles.PhaseShifterScanPVName='PHAS:UND1:3340:MOTR';
end

function DegubOfflinePvListX(handles)
load ThisSessionPointer APointer
DebOfPv{1,1}='SIOC:SYS0:ML00:AO411';
DebOfPv{1,2}=2;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO412';
DebOfPv{end,2}=24;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO413';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO414';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO415';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO416';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO417';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO418';
DebOfPv{end,2}=2;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO421';
DebOfPv{end,2}=0.1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO422';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO423';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO424';
DebOfPv{end,2}=33;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO425';
DebOfPv{end,2}=-22;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO426';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO427';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO428';
DebOfPv{end,2}=33;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO429';
DebOfPv{end,2}=-125;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO411.VAL';
DebOfPv{end,2}=2;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO412.VAL';
DebOfPv{end,2}=24;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO413.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO414.VAL';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO415.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO416.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO417.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO418.VAL';
DebOfPv{end,2}=2;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO421.VAL';
DebOfPv{end,2}=0.1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO422.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO423.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO424.VAL';
DebOfPv{end,2}=33;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO425.VAL';
DebOfPv{end,2}=-22;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO426.VAL';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO427.VAL';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO428.VAL';
DebOfPv{end,2}=33;
DebOfPv{end+1,1}='SIOC:SYS0:ML00:AO429.VAL';
DebOfPv{end,2}=-125;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO336';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO337';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO338';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO339';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO340';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO341';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO342';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO343';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO344';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO345';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO346';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO347';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO348';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO349';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='SIOC:SYS0:ML02:AO350';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:1:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:2:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:3:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:4:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:1:MOTR.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:2:MOTR.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:3:MOTR.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:4:MOTR.RBV';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3350:KDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:KACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3350:HARMDES';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='USEG:UND1:3350:HARMACT';
DebOfPv{end,2}=1;

DebOfPv{end+1,1}='USEG:UND1:3350:POLANGLEDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:POLANGLEACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3350:DEGREELINPOLDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:DEGREELINPOLACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3350:CHIRALITYDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:CHIRALITYACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3350:1:MOFF';
DebOfPv{end,2}=8;
DebOfPv{end+1,1}='USEG:UND1:3350:2:MOFF';
DebOfPv{end,2}=8;
DebOfPv{end+1,1}='USEG:UND1:3350:3:MOFF';
DebOfPv{end,2}=-8;
DebOfPv{end+1,1}='USEG:UND1:3350:4:MOFF';
DebOfPv{end,2}=-8;

DebOfPv{end+1,1}='USEG:UND1:3350:OFF.VAL';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:OFF.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3350:OFF.TOL';
DebOfPv{end,2}=0.01;
DebOfPv{end+1,1}='USEG:UND1:3350:OFF.DIS';
DebOfPv{end,2}=32;

DebOfPv{end+1,1}='USEG:UND1:3350:KMAX';
DebOfPv{end,2}=3.6461;
DebOfPv{end+1,1}='USEG:UND1:3350:UNDPERIOD';
DebOfPv{end,2}=32;

DebOfPv{end+1,1}='USEG:UND1:3350:1:MOTR.LOPR';
DebOfPv{end,2}=-17;
DebOfPv{end+1,1}='USEG:UND1:3350:2:MOTR.LOPR';
DebOfPv{end,2}=-17;
DebOfPv{end+1,1}='USEG:UND1:3350:3:MOTR.LOPR';
DebOfPv{end,2}=-17;
DebOfPv{end+1,1}='USEG:UND1:3350:4:MOTR.LOPR';
DebOfPv{end,2}=-17;

DebOfPv{end+1,1}='USEG:UND1:3350:1:MOTR.HOPR';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='USEG:UND1:3350:2:MOTR.HOPR';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='USEG:UND1:3350:3:MOTR.HOPR';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='USEG:UND1:3350:4:MOTR.HOPR';
DebOfPv{end,2}=17;

DebOfPv{end+1,1}='USEG:UND1:3250:1:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:2:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:3:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:4:MOTR';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3250:1:MOTR.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:2:MOTR.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:3:MOTR.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:4:MOTR.RBV';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3250:KDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:KACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3250:HARMDES';
DebOfPv{end,2}=1;
DebOfPv{end+1,1}='USEG:UND1:3250:HARMACT';
DebOfPv{end,2}=1;

DebOfPv{end+1,1}='USEG:UND1:3250:POLANGLEDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:POLANGLEACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3250:DEGREELINPOLDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:DEGREELINPOLACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3250:CHIRALITYDES';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:CHIRALITYACT';
DebOfPv{end,2}=0;

DebOfPv{end+1,1}='USEG:UND1:3250:1:MOFF';
DebOfPv{end,2}=8+2;
DebOfPv{end+1,1}='USEG:UND1:3250:2:MOFF';
DebOfPv{end,2}=8-4;
DebOfPv{end+1,1}='USEG:UND1:3250:3:MOFF';
DebOfPv{end,2}=-8+2;
DebOfPv{end+1,1}='USEG:UND1:3250:4:MOFF';
DebOfPv{end,2}=-8-4;

DebOfPv{end+1,1}='USEG:UND1:3250:OFF.VAL';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:OFF.RBV';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='USEG:UND1:3250:OFF.TOL';
DebOfPv{end,2}=0.01;
DebOfPv{end+1,1}='USEG:UND1:3250:OFF.DIS';
DebOfPv{end,2}=32;

DebOfPv{end+1,1}='USEG:UND1:3250:KMAX';
DebOfPv{end,2}=3.6461;
DebOfPv{end+1,1}='USEG:UND1:3250:UNDPERIOD';
DebOfPv{end,2}=32;

DebOfPv{end+1,1}='USEG:UND1:3250:1:MOTR.LOPR';
DebOfPv{end,2}=-17;
DebOfPv{end+1,1}='USEG:UND1:3250:2:MOTR.LOPR';
DebOfPv{end,2}=-17;
DebOfPv{end+1,1}='USEG:UND1:3250:3:MOTR.LOPR';
DebOfPv{end,2}=-17;
DebOfPv{end+1,1}='USEG:UND1:3250:4:MOTR.LOPR';
DebOfPv{end,2}=-17;

DebOfPv{end+1,1}='USEG:UND1:3250:1:MOTR.HOPR';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='USEG:UND1:3250:2:MOTR.HOPR';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='USEG:UND1:3250:3:MOTR.HOPR';
DebOfPv{end,2}=17;
DebOfPv{end+1,1}='USEG:UND1:3250:4:MOTR.HOPR';
DebOfPv{end,2}=17;

DebOfPv{end+1,1}='PHAS:UND1:3340:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='PHAS:UND1:3340:MOTR.DESC';
DebOfPv{end,2}='banana';
DebOfPv{end+1,1}='PHAS:UND1:3340:MOTR.EGU';
DebOfPv{end,2}='mm';
DebOfPv{end+1,1}='PHAS:UND1:3340:MOTR.LOPR';
DebOfPv{end,2}=10;
DebOfPv{end+1,1}='PHAS:UND1:3340:MOTR.HOPR';
DebOfPv{end,2}=100;
DebOfPv{end+1,1}='PHAS:UND1:3340:ENC';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='PHAS:UND1:3340:ENC.DESC';
DebOfPv{end,2}='banana';
DebOfPv{end+1,1}='PHAS:UND1:3340:ENC.EGU';
DebOfPv{end,2}='mm';
DebOfPv{end+1,1}='PHAS:UND1:3340:ENC.LOPR';
DebOfPv{end,2}=10;
DebOfPv{end+1,1}='PHAS:UND1:3340:ENC.HOPR';
DebOfPv{end,2}=100;

DebOfPv{end+1,1}='PHAS:UND1:3240:MOTR';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='PHAS:UND1:3240:MOTR.DESC';
DebOfPv{end,2}='banana';
DebOfPv{end+1,1}='PHAS:UND1:3240:MOTR.EGU';
DebOfPv{end,2}='mm';
DebOfPv{end+1,1}='PHAS:UND1:3240:MOTR.LOPR';
DebOfPv{end,2}=10;
DebOfPv{end+1,1}='PHAS:UND1:3240:MOTR.HOPR';
DebOfPv{end,2}=100;
DebOfPv{end+1,1}='PHAS:UND1:3240:ENC';
DebOfPv{end,2}=0;
DebOfPv{end+1,1}='PHAS:UND1:3240:ENC.DESC';
DebOfPv{end,2}='banana';
DebOfPv{end+1,1}='PHAS:UND1:3240:ENC.EGU';
DebOfPv{end,2}='mm';
DebOfPv{end+1,1}='PHAS:UND1:3240:ENC.LOPR';
DebOfPv{end,2}=10;
DebOfPv{end+1,1}='PHAS:UND1:3240:ENC.HOPR';
DebOfPv{end,2}=100;

DebOfPv{end+1,1}='USEG:UND1:3350:OFFCMD';
DebOfPv{end,2}='On';
DebOfPv{end+1,1}='USEG:UND1:3350:OFFACT';
DebOfPv{end,2}='On';

DebOfPv{end+1,1}='USEG:UND1:3250:OFFCMD';
DebOfPv{end,2}='On';
DebOfPv{end+1,1}='USEG:UND1:3250:OFFACT';
DebOfPv{end,2}='On';

set(APointer,'UserData',DebOfPv);
disp('Debug Setup Done')

end

function DeltaPlotUpdate(handles,Status_Current,Status_Destination,Status_Input)
%save TEMP
    PointNumber=360;ArrowHead1=Status_Input(1)*[-1/4,-1]/8;ArrowHead2=Status_Input(1)*[1/4,-1]/8; PlotPhaseDelay=[pi/2,pi/4,0];
    %Status_Input
    show_destination=get(handles.Delta_ShowDestination,'value'); show_current=get(handles.Delta_ShowCurrent,'value'); show_input=get(handles.Delta_ShowInput,'value');
    
    DXY=[Status_Destination(1)*sqrt(Status_Destination(2)),Status_Destination(1)*sqrt(1-Status_Destination(2)),Status_Destination(3)];
    CXY=[Status_Current(1)*sqrt(Status_Current(2)),Status_Current(1)*sqrt(1-Status_Current(2)),Status_Current(3)];
    IXY=[Status_Input(1)*sqrt(Status_Input(2)),Status_Input(1)*sqrt(1-Status_Input(2)),Status_Input(3)];
    
    ARD=sqrt(Status_Destination(2))*sqrt(1-Status_Destination(2))*cos(Status_Destination(3))*Status_Destination(1);
    ARC=sqrt(Status_Current(2))*sqrt(1-Status_Current(2))*cos(Status_Current(3))*Status_Current(1);
    ARI=sqrt(Status_Input(2))*sqrt(1-Status_Input(2))*cos(Status_Input(3))*Status_Input(1);
    
    t=linspace(0,2*pi,PointNumber);
    XC=CXY(1)*cos(t-CXY(3)/180*pi);
    YC=CXY(2)*cos(t);
    XI=IXY(1)*cos(t-IXY(3)/180*pi);
    YI=IXY(2)*cos(t);
    XD=DXY(1)*cos(t-DXY(3)/180*pi);
    YD=DXY(2)*cos(t);
    Range=1;
    cla(handles.DELTAUNDULATORDISPLAY,'reset');
    hold(handles.DELTAUNDULATORDISPLAY,'on');
    if(show_destination && (Status_Destination(1)>0))
        XD=DXY(1)*cos(t-DXY(3)/180*pi+PlotPhaseDelay(1));
        YD=DXY(2)*cos(t+PlotPhaseDelay(1));
        plot(handles.DELTAUNDULATORDISPLAY,XD,YD,'b','LineWidth',1.25);
        Range=max(Range(1),max(max(XD*1.1,YD*1.1)));
        if(ARD~=0)
            RotationAngle=pi/2+angle(-DXY(1)*sin(t(10)-DXY(3)/180*pi+PlotPhaseDelay(1))-1i*DXY(2)*sin(t(10)+PlotPhaseDelay(1)));
            Arrow1=[XD(1),YD(1)].'+[cos(RotationAngle),-sin(RotationAngle) ; sin(RotationAngle), cos(RotationAngle) ]*ArrowHead1.';
            Arrow2=[XD(1),YD(1)].'+[cos(RotationAngle),-sin(RotationAngle) ; sin(RotationAngle), cos(RotationAngle) ]*ArrowHead2.';
            plot(handles.DELTAUNDULATORDISPLAY,[XD(1),Arrow1(1)],[YD(1),Arrow1(2)],'b','LineWidth',2);
            plot(handles.DELTAUNDULATORDISPLAY,[XD(1),Arrow2(1)],[YD(1),Arrow2(2)],'b','LineWidth',2);
            plot(handles.DELTAUNDULATORDISPLAY,XD(1:45),YD(1:45),'b','LineWidth',2);
        end
    end
    
    if(show_input && (Status_Input(1)>0))
        XI=IXY(1)*cos(t-IXY(3)/180*pi+PlotPhaseDelay(2));
        YI=IXY(2)*cos(t+PlotPhaseDelay(2));
        plot(handles.DELTAUNDULATORDISPLAY,XI,YI,'r','LineWidth',1.25);
        Range=max(Range(1),max(max(XI*1.1,YI*1.1)));
        if(ARI~=0)
            RotationAngle=pi/2+angle(-IXY(1)*sin(t(10)-IXY(3)/180*pi+PlotPhaseDelay(2))-1i*IXY(2)*sin(t(10)+PlotPhaseDelay(2)));
            Arrow1=[XI(1),YI(1)].'+[cos(RotationAngle),-sin(RotationAngle) ; sin(RotationAngle), cos(RotationAngle) ]*ArrowHead1.';
            Arrow2=[XI(1),YI(1)].'+[cos(RotationAngle),-sin(RotationAngle) ; sin(RotationAngle), cos(RotationAngle) ]*ArrowHead2.';
            plot(handles.DELTAUNDULATORDISPLAY,[XI(1),Arrow1(1)],[YI(1),Arrow1(2)],'r','LineWidth',2);
            plot(handles.DELTAUNDULATORDISPLAY,[XI(1),Arrow2(1)],[YI(1),Arrow2(2)],'r','LineWidth',2);
            plot(handles.DELTAUNDULATORDISPLAY,XI(1:45),YI(1:45),'r','LineWidth',2);
        end
    end
    
    if(show_current && (Status_Current(1)>0))
        XC=CXY(1)*cos(t-CXY(3)/180*pi+PlotPhaseDelay(2));
        YC=CXY(2)*cos(t+PlotPhaseDelay(2));
        plot(handles.DELTAUNDULATORDISPLAY,XC,YC,'k','LineWidth',1.25);
        Range=max(Range(1),max(max(XC*1.1,YC*1.1)));
        if(ARC~=0)
            RotationAngle=pi/2+angle(-CXY(1)*sin(t(10)-CXY(3)/180*pi+PlotPhaseDelay(2))-1i*CXY(2)*sin(t(10)+PlotPhaseDelay(2)));
            Arrow1=[XC(1),YC(1)].'+[cos(RotationAngle),-sin(RotationAngle) ; sin(RotationAngle), cos(RotationAngle) ]*ArrowHead1.';
            Arrow2=[XC(1),YC(1)].'+[cos(RotationAngle),-sin(RotationAngle) ; sin(RotationAngle), cos(RotationAngle) ]*ArrowHead2.';
            plot(handles.DELTAUNDULATORDISPLAY,[XC(1),Arrow1(1)],[YC(1),Arrow1(2)],'k','LineWidth',2);
            plot(handles.DELTAUNDULATORDISPLAY,[XC(1),Arrow2(1)],[YC(1),Arrow2(2)],'k','LineWidth',2);
            plot(handles.DELTAUNDULATORDISPLAY,XC(1:45),YC(1:45),'k','LineWidth',2);
        end
    end 
    hold(handles.DELTAUNDULATORDISPLAY,'off');
    xlim(handles.DELTAUNDULATORDISPLAY,[-Range,Range]);
    ylim(handles.DELTAUNDULATORDISPLAY,[-Range,Range]);
    set(handles.DELTAUNDULATORDISPLAY,'XTick',[]);
    set(handles.DELTAUNDULATORDISPLAY,'YTick',[]);
    set(handles.DELTAUNDULATORDISPLAY,'box','on');
    grid(handles.DELTAUNDULATORDISPLAY,'on');
    %disp('Display Updated Succesfully')
end

function DeltaUpdate(handles) %This function has all that happens when the timer function is called for what regards the delta undulator
handles.Delta_scan_threshold=10^-5;
%set(handles.DeltaActiveString,'String','Delta is ON','backgroundcolor',[0,1,0]);

deltaslot=get(handles.WhichDeltaUndulator,'value');

% lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1})
% lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,2})
DestinationOff=strcmpi(lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1}),'Off');
CurrentlyOff=strcmpi(lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1}),'Off');

% DestinationOff=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1},0,'double')
% CurrentlyOff=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,2},0,'double')

% if(DestinationOff==0)
%     set(handles.DeltaActiveString,'String','Delta is ON','backgroundcolor',[0,1,0]); 
%     set(handles.MoveButton,'enable','on'); set(handles.Deltalistenbutton,'enable','on');
%     return 
% end
% if(CurrentlyOff==0)
%     set(handles.DeltaActiveString,'String','Delta is ON','backgroundcolor',[0,1,0]); 
%     set(handles.MoveButton,'enable','on'); set(handles.Deltalistenbutton,'enable','on');
%     return 
% end

set(handles.DeltaActiveString,'String','Delta is OFF','backgroundcolor',[1,1,0]); 
set(handles.MoveButton,'enable','off'); set(handles.Deltalistenbutton,'enable','off');

if(DestinationOff && ~ CurrentlyOff)
   set(handles.DeltaActiveString,'String','Delta going OFF','backgroundcolor',[1,1,0]);
   set(handles.MoveButton,'enable','off'); set(handles.Deltalistenbutton,'enable','off');
elseif(CurrentlyOff)
   set(handles.DeltaActiveString,'String','Delta is OFF','backgroundcolor',[1,1,0]); 
   set(handles.MoveButton,'enable','off'); set(handles.Deltalistenbutton,'enable','off');
else
   set(handles.DeltaActiveString,'String','Delta is ON','backgroundcolor',[0,1,0]); 
   set(handles.MoveButton,'enable','on'); set(handles.Deltalistenbutton,'enable','on');
end

CurrentPhaseShifter=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.FirstPhaseShifterPVLocation,6});
set(handles.p_readback15,'String',num2str(CurrentPhaseShifter,handles.AllDeltaUndulators{deltaslot,handles.FirstPhaseShifterPVLocation,11}));

for II=1:4
      ZVector_Current(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,10});
      ZVector_Destination(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9});
      ZVector_GuiInput(II)=str2double(get(handles.DeltaPvNamesCell{handles.DeltaRodsParameters(1)+II-1,7},'String'));
end
Harmonic_Current=lcaGet(handles.AllDeltaUndulators{deltaslot,2,10});
Harmonic_Destination=lcaGet(handles.AllDeltaUndulators{deltaslot,2,9});
Harmonic_GuiInput=str2double(get(handles.DeltaPvNamesCell{2,7},'String'));

Stokes_Current=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(ZVector_Current,handles, deltaslot),handles,deltaslot);
Stokes_Destination=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(ZVector_Destination,handles, deltaslot),handles,deltaslot);
Stokes_GuiInput=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(ZVector_GuiInput,handles, deltaslot),handles,deltaslot);

Keff_Current=deltagui_S0toKeff(Stokes_Current,Harmonic_Current,handles, deltaslot);
Keff_Destination=deltagui_S0toKeff(Stokes_Destination,Harmonic_Destination,handles, deltaslot);
Keff_GuiInput=deltagui_S0toKeff(Stokes_GuiInput,Harmonic_GuiInput,handles, deltaslot);

Ellipse_Current=deltagui_Stokes2Ellipse(Stokes_Current);
ExEy_C=deltagui_Stokes2ExEy(Stokes_Current);
Status_Current=[Keff_Current,Harmonic_Current,Ellipse_Current(2:4),deltagui_Rods2RodsAverages(ZVector_Current),ZVector_Current];

Ellipse_Destination=deltagui_Stokes2Ellipse(Stokes_Destination);
ExEy_D=deltagui_Stokes2ExEy(Stokes_Destination);
Status_Destination=[Keff_Destination,Harmonic_Destination,Ellipse_Destination(2:4),deltagui_Rods2RodsAverages(ZVector_Destination),ZVector_Destination];

% disp(['Keff_Destination = ',num2str(Keff_Destination)]);
% disp(['Status_Destination 1 = ',num2str(Status_Destination(1))]);

Ellipse_GuiInput=deltagui_Stokes2Ellipse(Stokes_GuiInput);
ExEy_I=deltagui_Stokes2ExEy(Stokes_GuiInput);
Status_GuiInput=[Keff_GuiInput,Harmonic_GuiInput,Ellipse_GuiInput(2:4),deltagui_Rods2RodsAverages(ZVector_GuiInput),ZVector_GuiInput];

if(get(handles.Deltalistenbutton,'userdata')) % FROM HERE CHECKS FOR SCANS
%     disp('*** Current State ***');
%     disp(Status_Destination)
    PASS=0; %Status_Destination is already calculated 
    for II=1:handles.NumberOfDeltaParameters
        DeltaParameters_Read=lcaGet(handles.DeltaPvNamesCell{II,4});
        DeltaParameters_Input(II)=check_if_scalar_double_for_scans(DeltaParameters_Read);
        if(~isnan(DeltaParameters_Input(II)))
            if(abs( DeltaParameters_Input(II) - Status_Destination(II)) > handles.Delta_scan_threshold) %A new value has been set
                PASS=checkifinsiderange_for_scans(DeltaParameters_Input(II), II, handles, Status_Destination,deltaslot);
                disp(['PASS will be: ',num2str(DeltaParameters_Input(II)) ,' ***  was:',num2str(Status_Destination(II))])
                %PASS Must ignore if it is a circle any angle rotation !!
                if(PASS==1)
                    break
                else
                    disp([handles.DeltaPvNamesCell{II,4},' set to out of range value'])
                end
            end
        else
            disp([handles.DeltaPvNamesCell{II,4},' set to unrecognized value'])
        end
    end
    if(PASS==1)
        Status_Destination(II)=DeltaParameters_Input(II);
%         disp('*** Required New State *** ' );
%         disp(Status_Destination)
        disp(['*** Scan Called on:',num2str(II)])
        if(II<=5) %Is moving as an ellipse
            if(II==4) % if changing degree of linear goes to 1 sets chirality to 0
               if(Status_Destination(II)==1)
                   Status_Destination(II+1)=0;
               elseif(Status_Destination(II)<1) %if it goes to <1, if chirality was 0 sets it to 1
                   if(Status_Destination(II+1)==0)
                       Status_Destination(II+1)=+1;
                   end
               end
            end
            [Stokes_Destination, Full_New_State]=update_parameters_from_ellipse_for_scans(Status_Destination,handles,deltaslot);
        elseif(II==6) %Is moving all the rows at the same time
            [Stokes_Destination, Full_New_State]=update_parameters_from_rods_for_scans(Status_Destination,handles,3,deltaslot);
        elseif(II<handles.DeltaRodsParameters(1)) %Is moving a single 45 degree undulator
            [Stokes_Destination, Full_New_State]=update_parameters_from_rods_for_scans(Status_Destination,handles,2,deltaslot);
        else %Is moving a single 45 degree undulator
            [Stokes_Destination, Full_New_State]=update_parameters_from_rods_for_scans(Status_Destination,handles,1,deltaslot);
        end
        %save TEMP2
%         disp('*** New State *** ' );
%         disp(Full_New_State)
    Move_Rows_to_destination(Full_New_State, handles, deltaslot) %Reset Entire Destination and move rods
    disp([handles.DeltaPvNamesCell{II,4},' set to new value, scan performed']);
    disp('New Rows Locations:')
    Full_New_State(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2))
    Deltaphi=deltagui_rod2Deltaphi(Full_New_State(handles.DeltaRodsParameters(1):handles.DeltaRodsParameters(2)),handles, deltaslot);
    Stokes_Destination=deltagui_Deltaphi2Stokes(Deltaphi,handles,deltaslot);
    ExEy_D=deltagui_Stokes2ExEy(Stokes_Destination);
    end
end

%TO HERE CHECKS FOR SCANS

%UPDATES THE SCREEN
for II=1:handles.NumberOfDeltaParameters
   set(handles.DeltaPvNamesCell{II,8},'String',num2str(Status_Current(II),handles.DeltaPvNamesCell{II,11})); 
end
set(handles.DeltaS0string,'string',{['S0 = ',num2str(Stokes_Current(1))],['S1 = ',num2str(Stokes_Current(2))],['S2 = ',num2str(Stokes_Current(3))],['S3 =', num2str(Stokes_Current(4)) ]}) ;
set(handles.DeltaS0des,'string',{['S0 = ',num2str(Stokes_Destination(1))],['S1 = ',num2str(Stokes_Destination(2))],['S2 = ',num2str(Stokes_Destination(3))],['S3 =', num2str(Stokes_Destination(4)) ]}) ;
set(handles.DeltaS0in,'string',{['S0 = ',num2str(Stokes_GuiInput(1))],['S1 = ',num2str(Stokes_GuiInput(2))],['S2 = ',num2str(Stokes_GuiInput(3))],['S3 =', num2str(Stokes_GuiInput(4)) ]}) ;
DeltaPlotUpdate(handles,ExEy_C,ExEy_D,ExEy_I);
if(get(handles.SynchronizeDesActAlways,'UserData'))
   for II=1:handles.NumberOfDeltaParameters
     set(handles.DeltaPvNamesCell{II,7},'String',num2str(Status_Current(II),handles.DeltaPvNamesCell{II,11})); 
   end
end

%disp('DeltaUpdate run Succesfully')
end

% --- Executes on button press in Delta_ShowCurrent.
function Delta_ShowCurrent_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in Delta_ShowDestination.
function Delta_ShowDestination_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in Delta_ShowInput.
function Delta_ShowInput_Callback(hObject, eventdata, handles)
end

% --- Executes on selection change in DeltaMovementType.
function DeltaMovementType_Callback(hObject, eventdata, handles)
end


% --- Executes during object creation, after setting all properties.
function DeltaMovementType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Gui_Input=ReadAllGuiInput(handles)
    for II=1:handles.NumberOfDeltaParameters
        Gui_Input(II)=str2double(get(handles.DeltaPvNamesCell{II,7},'String'));
    end
end


% --- Executes on button press in DeltaResetScan.
function DeltaResetScan_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
for II=1:4
      ZVector_Destination(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9});
end
Harmonic_Destination=lcaGet(handles.AllDeltaUndulators{deltaslot,2,9});
Stokes_Destination=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(ZVector_Destination,handles, deltaslot),handles,deltaslot);
Ellipse_Destination=deltagui_Stokes2Ellipse(Stokes_Destination);
Keff=deltagui_S0toKeff(Stokes_Destination(1),Harmonic_Destination,handles, deltaslot);
Status_Destination=[Keff,Harmonic_Destination,Ellipse_Destination(2:4),deltagui_Rods2RodsAverages(ZVector_Destination),ZVector_Destination];
if(Stokes_Destination(1)==0)
    Status_Destination(4)=0;
end
for II=1:handles.NumberOfDeltaParameters
    lcaPut(handles.DeltaPvNamesCell{II,4},Status_Destination(II));
end
end


% --- Executes on button press in Deltalistenbutton.
function Deltalistenbutton_Callback(hObject, eventdata, handles)
CurrentStatus=get(hObject,'UserData');
if(CurrentStatus)
    set(handles.Deltalistenbutton,'UserData',0);
    set(handles.Deltalistenbutton,'String','Listening for scans: OFF');
else
    DeltaResetScan_Callback(hObject, eventdata, handles);
    if(get(handles.iSASE_ListeningMode,'userdata'))
       iSASE_ListeningMode_Callback(hObject, eventdata, handles) ;
    end
    set(handles.Deltalistenbutton,'UserData',1);
    set(handles.Deltalistenbutton,'String','Listening for scans: ON');
end
end


% --- Executes on button press in Open_DeltaPanel.
function Open_DeltaPanel_Callback(hObject, eventdata, handles)
set(handles.Open_DeltaPanel,'UserData',1); set(handles.Open_iSASEpanel,'UserData',0);set(handles.Open_StandardPanel,'UserData',0);
% handles = updateDisplay ( handles );
set(handles.Open_DeltaPanel,'backgroundcolor',handles.ColorOn); set(handles.Open_iSASEpanel,'backgroundcolor',handles.ColorOff);set(handles.Open_StandardPanel,'backgroundcolor',handles.ColorOff);
set(handles.uipanel8,'visible','off');set(handles.uipanel15,'visible','off'); set(handles.uipanel9,'visible','on');
end


% --- Executes on button press in Open_iSASEpanel.
function Open_iSASEpanel_Callback(hObject, eventdata, handles)
set(handles.Open_DeltaPanel,'UserData',0); set(handles.Open_iSASEpanel,'UserData',1);set(handles.Open_StandardPanel,'UserData',0);
% handles = updateDisplay ( handles );
set(handles.Open_DeltaPanel,'backgroundcolor',handles.ColorOff); set(handles.Open_iSASEpanel,'backgroundcolor',handles.ColorOn);set(handles.Open_StandardPanel,'backgroundcolor',handles.ColorOff);
set(handles.uipanel9,'visible','off'); set(handles.uipanel15,'visible','off'); set(handles.uipanel8,'visible','on');
iSASE_ApplyDifference_Callback(hObject, eventdata, handles);
end


% --- Executes on button press in Open_StandardPanel.
function Open_StandardPanel_Callback(hObject, eventdata, handles)
set(handles.Open_DeltaPanel,'UserData',0); set(handles.Open_iSASEpanel,'UserData',0);set(handles.Open_StandardPanel,'UserData',1);
% handles = updateDisplay ( handles );
set(handles.Open_DeltaPanel,'backgroundcolor',handles.ColorOff); set(handles.Open_iSASEpanel,'backgroundcolor',handles.ColorOff);set(handles.Open_StandardPanel,'backgroundcolor',handles.ColorOn);
set(handles.uipanel9,'visible','off'); set(handles.uipanel8,'visible','off');set(handles.uipanel15,'visible','on');
end

% --- Executes on button press in iSASE_KUnits_checkbox.
function iSASE_KUnits_checkbox_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in iSASE_EnergyUnits_Checkbox.
function iSASE_EnergyUnits_Checkbox_Callback(hObject, eventdata, handles)
end


function edit51_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
end


function edit50_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function edit50_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
end


function iSASE_ISS_edit_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function iSASE_ISS_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in iSASE_ISS_Expression.
function iSASE_ISS_Expression_Callback(hObject, eventdata, handles)
Expression=str2num(get(handles.iSASE_ISS_edit,'string'));
if(~isempty(Expression))
    CurrentTable=get(handles.iSASE_State,'data');
    for slot=1:handles.Segments
        if(handles.isInstalled(slot) && any(Expression==slot))
            CurrentTable{slot,1}=true;
        else
            CurrentTable{slot,1}=false;
        end
    end
    set(handles.iSASE_State,'data',CurrentTable);
end
end


% --- Executes on button press in iSASE_ISS_Alternate.
function iSASE_ISS_Alternate_Callback(hObject, eventdata, handles)
Expression=str2num(get(handles.iSASE_ISS_edit,'string'));
if(~isempty(Expression))
    if(length(Expression)==1)
        if(~isnan(Expression) && (~isinf(Expression)) && (Expression>1/2))
            Expression=round(Expression);
            CurrentTable=get(handles.iSASE_State,'data');
            insertedIN=Expression/2;
            for slot=1:handles.Segments
                if(handles.isInstalled(slot))
                    if(mod(round(insertedIN/Expression),2))
                        CurrentTable{slot,1}=true;
                    else
                        CurrentTable{slot,1}=false;
                    end
                    insertedIN=insertedIN+1;
                end
            end
            set(handles.iSASE_State,'data',CurrentTable);
        end
    end
end

end

% --- Executes on button press in iSASE_ISS_All.
function iSASE_ISS_All_Callback(hObject, eventdata, handles)
CurrentTable=get(handles.iSASE_State,'data');
for slot=1:handles.Segments
    if(handles.isInstalled(slot))
       CurrentTable{slot,1}=true;
    else
       CurrentTable{slot,1}=false;
    end
end
set(handles.iSASE_State,'data',CurrentTable);
end

% --- Executes on button press in iSASE_ISS_None.
function iSASE_ISS_None_Callback(hObject, eventdata, handles)
CurrentTable=get(handles.iSASE_State,'data');
for slot=1:handles.Segments
    if(handles.isInstalled(slot))
       CurrentTable{slot,1}=false;
    else
       CurrentTable{slot,1}=false;
    end
end
set(handles.iSASE_State,'data',CurrentTable);
end

% --- Executes on button press in iSASE_ISS_Complement.
function iSASE_ISS_Complement_Callback(hObject, eventdata, handles)
CurrentTable=get(handles.iSASE_State,'data');
for slot=1:handles.Segments
    if(handles.isInstalled(slot))
       CurrentTable{slot,1}=~CurrentTable{slot,1};
    end
end
set(handles.iSASE_State,'data',CurrentTable);
end


function iSASE_Enable_All(handles, ON)
if (ON) %enables all
    set(handles.iSASE_State,'enable','on');
    set(handles.iSASE_ISS_Expression,'enable','on');
    set(handles.iSASE_ISS_Complement,'enable','on');
    set(handles.iSASE_ISS_Alternate,'enable','on');
    set(handles.iSASE_ISS_None,'enable','on');
    set(handles.iSASE_ISS_All,'enable','on');
    set(handles.iSASE_ApplyDifference,'enable','on');
    set(handles.iSASEDifferenceSetTo0,'enable','on');
    set(handles.iSASE_TaperShapeApply,'enable','on');
    set(handles.MoveSelectedToBlueStars,'enable','on');
    set(handles.iSASE_undo,'enable','on');
    set(handles.iSASE_ScanType,'enable','on');
    set(handles.iSASE_Absolute_c,'enable','on');
    set(handles.iSASE_relative_c,'enable','on');
    set(handles.iSASE_TaperShape0,'enable','on');
    set(handles.iSASE_TaperShape1,'enable','on');
    set(handles.iSASE_TaperShape2,'enable','on');
    set(handles.iSASE_TaperShape3,'enable','on');
else %diables all
    set(handles.iSASE_State,'enable','off');
    set(handles.iSASE_ISS_Expression,'enable','off');
    set(handles.iSASE_ISS_Complement,'enable','off');
    set(handles.iSASE_ISS_Alternate,'enable','off');
    set(handles.iSASE_ISS_None,'enable','off');
    set(handles.iSASE_ISS_All,'enable','off');
    set(handles.iSASE_ApplyDifference,'enable','off');
    set(handles.iSASEDifferenceSetTo0,'enable','off');
    set(handles.iSASE_TaperShapeApply,'enable','off');
    set(handles.MoveSelectedToBlueStars,'enable','off');
    set(handles.iSASE_undo,'enable','off');
    set(handles.iSASE_ScanType,'enable','off');
    set(handles.iSASE_Absolute_c,'enable','off');
    set(handles.iSASE_relative_c,'enable','off');
    set(handles.iSASE_TaperShape0,'enable','off');
    set(handles.iSASE_TaperShape1,'enable','off');
    set(handles.iSASE_TaperShape2,'enable','off');
    set(handles.iSASE_TaperShape3,'enable','off');
end
end

function DoiSASEScan(handles)
    ScanStartState=get(handles.iSASEScansStartPosition,'userdata');
    ScanPv=lcaGet(handles.iSASEConsts.iSASETaperScanName);
    if(~isnumeric(ScanPv)), set(handles.iSASEScansCurrentPosition,'string','Current: Unrecognized'),return , end
    if(~isscalar(ScanPv)), set(handles.iSASEScansCurrentPosition,'string', 'Current: Unrecognized'),return , end
    if(isinf(ScanPv) || isnan(ScanPv)), set(handles.iSASEScansCurrentPosition,'Current: Unrecognized') , return , end
    LastScanPvRead=get(handles.TaperScans,'userdata'); set(handles.iSASEScansCurrentPosition,'string',['Current: ',num2str(ScanPv)],'FontWeight','normal');
    
    if(ScanPv ~= LastScanPvRead)
        ScanStartState.InitialStateValue
        set(handles.TaperScans,'userdata',ScanPv);
        set(handles.iSASEScansCurrentPosition,'string',['Current: ',num2str(ScanPv)],'FontWeight','bold');
        %try to do something with the new value ...
        switch(ScanStartState.iSASE_ScanValue)
            case 1 %K offset
                New_K_Values = ScanStartState.ReferenceKValues - ScanStartState.InitialStateValue + ScanPv;
                setKvalues_with_undulator_selection ( handles, New_K_Values, ScanStartState.ActiveSlots); 
                return
            case 2
                ScanStartState.TaperShaping(1)=ScanPv + (1-ScanStartState.FromAbsoluteValue)*ScanStartState.InitialStateValue;
            case 3
                ScanStartState.TaperShaping(2)=ScanPv + (1-ScanStartState.FromAbsoluteValue)*ScanStartState.InitialStateValue;
            case 4
                ScanStartState.TaperShaping(3)=ScanPv + (1-ScanStartState.FromAbsoluteValue)*ScanStartState.InitialStateValue;
            case 5
                ScanStartState.TaperShaping(4)=ScanPv + (1-ScanStartState.FromAbsoluteValue)*ScanStartState.InitialStateValue;  
        end
        if(any(ScanStartState.iSASE_ScanValue==(2:5)))
        Start=ScanStartState.TaperShaping(1); Linear=ScanStartState.TaperShaping(2); QuadStart=ScanStartState.TaperShaping(3); Quadratic=ScanStartState.TaperShaping(4);

        Inserted=0;
        InsertedQuadratic=0;
        for j=1:handles.Segments
            if ( ScanStartState.ActiveSlots(j) )
                if(j>=QuadStart)
                   InsertedQuadratic=InsertedQuadratic+1;
                end
                New_K_Values(j)= Start + Inserted*Linear + (InsertedQuadratic*(InsertedQuadratic+1))/2*Quadratic + ScanStartState.AppliedDifference(j);
                Inserted=Inserted+1;
            else
                New_K_Values(j)=0;
            end
        end
        New_K_Values
        ScanStartState.ActiveSlots
        setKvalues_with_undulator_selection ( handles, New_K_Values, ScanStartState.ActiveSlots); 
        return    
            
        end
    end
end

% --- Executes on button press in iSASE_ListeningMode.
function iSASE_ListeningMode_Callback(hObject, eventdata, handles)
CurrentState=get(handles.iSASE_ListeningMode,'UserData');
if(~CurrentState) %turn it on...
    iSASE_Enable_All(handles, 0);
    CurrentState=get(handles.iSASE_State,'Data');
    ScanStartState.ActiveSlots=[CurrentState{:,1}];
    Start=check_if_scalar_double(get(handles.iSASE_TaperShape0,'String'));
    Linear=check_if_scalar_double(get(handles.iSASE_TaperShape1,'String'));
    Quadratic=check_if_scalar_double(get(handles.iSASE_TaperShape3,'String'));
    QuadStart=round(abs(check_if_scalar_double(get(handles.iSASE_TaperShape2,'String'))));
    if(~any(ScanStartState.ActiveSlots) || isnan(Start*Linear*Quadratic*QuadStart))
        iSASE_Enable_All(handles, 1);
    else
        if(get(handles.Deltalistenbutton,'userdata'))
            Deltalistenbutton_Callback(hObject, eventdata, handles);
        end
        set(handles.iSASE_ListeningMode,'backgroundcolor',handles.ColorOn);
        set(handles.iSASE_ScanType,'backgroundcolor',handles.ColorOn,'Fontweight','bold');
        set(handles.iSASE_ListeningMode,'string','Listening Mode is ON');
        ScanStartState.iSASE_ScanValue=get(handles.iSASE_ScanType,'value');
        set(handles.iSASE_ScanType,'userdata',ScanStartState.iSASE_ScanValue);
        TaperShaping(1)=Start; TaperShaping(2)=Linear; TaperShaping(3)=QuadStart; TaperShaping(4)=Quadratic; 
        ScanStartState.ReferenceKValues=[CurrentState{:,2}];
        ScanStartState.AppliedDifference=[CurrentState{:,4}];
        ScanStartState.FromAbsoluteValue=get(handles.iSASE_Absolute_c,'value');
        ScanStartState.TaperShaping=TaperShaping;
        switch(ScanStartState.iSASE_ScanValue)
            case 1
                if(ScanStartState.FromAbsoluteValue)
                    Kvalues=ScanStartState.ReferenceKValues(ScanStartState.ActiveSlots);
                    ScanStartState.InitialStateValue=Kvalues(1);
                    lcaPut(handles.iSASEConsts.iSASETaperScanName,ScanStartState.InitialStateValue);
                    set(handles.iSASEScansStartPosition,'String',['Initial State:',num2str(ScanStartState.InitialStateValue)]);
                else
                    ScanStartState.InitialStateValue=0;
                    lcaPut(handles.iSASEConsts.iSASETaperScanName,ScanStartState.InitialStateValue);
                    set(handles.iSASEScansStartPosition,'String',['Initial State:',num2str(ScanStartState.InitialStateValue)]);
                end
            case 2
                ScanStartState.InitialStateValue=TaperShaping(1);
            case 3
                ScanStartState.InitialStateValue=TaperShaping(2);
            case 4
                ScanStartState.InitialStateValue=TaperShaping(3);
            case 5
                ScanStartState.InitialStateValue=TaperShaping(4);
        end
        if((ScanStartState.iSASE_ScanValue>=1) && (ScanStartState.iSASE_ScanValue<=5))
            if(ScanStartState.FromAbsoluteValue)
               lcaPut(handles.iSASEConsts.iSASETaperScanName,ScanStartState.InitialStateValue);
               set(handles.iSASEScansStartPosition,'String',['Initial State:',num2str(ScanStartState.InitialStateValue)]);
            else
               lcaPut(handles.iSASEConsts.iSASETaperScanName,0);
               set(handles.iSASEScansStartPosition,'String','Initial State: 0'); 
            end
        end 
        set(handles.iSASEScansCurrentPosition,'String',['Current:',num2str( lcaGet(handles.iSASEConsts.iSASETaperScanName))]);
        set(handles.TaperScans,'userdata',ScanStartState.InitialStateValue);
        set(handles.iSASEScansStartPosition,'userdata',ScanStartState);
        set(handles.iSASE_ListeningMode,'UserData',1); %Only now it is really on and will act on the machine
    end
else 
    set(handles.iSASE_ScanType,'backgroundcolor',[1,1,1],'Fontweight','normal');
    set(handles.iSASE_ListeningMode,'backgroundcolor',handles.ColorOff);
    set(handles.iSASE_ListeningMode,'string','Listening Mode is OFF');
    set(handles.iSASE_ListeningMode,'UserData',0);
    set(handles.iSASEScansStartPosition,'String','');
    set(handles.iSASEScansCurrentPosition,'String','');
    iSASE_Enable_All(handles, 1);

end

end


% --- Executes when selected cell(s) is changed in iSASE_State.
function iSASE_State_CellSelectionCallback(hObject, eventdata, handles)
end

% --- Executes when entered data in editable cell(s) in iSASE_State.
function iSASE_State_CellEditCallback(hObject, eventdata, handles)
if(eventdata.Indices(2)==1) %changes a selection
    if((~isActive( eventdata.Indices(1), handles)) || (handles.Type(eventdata.Indices(1)) ==0)) %If it is not installed overrides with no
        CurrentTable=get(handles.iSASE_State,'data');
        CurrentTable{eventdata.Indices(1),1}=false;
        set(handles.iSASE_State,'data',CurrentTable);  
    end
end
if(eventdata.Indices(2)==2) %cannot do it
disp('second column selected')
end
if(eventdata.Indices(2)==3) %sets new value manually 
disp('first column selected')
end
if(eventdata.Indices(2)==4) %sets new difference manually 
disp('third column selected')
end
end


% --- Executes on button press in iSASE_Absolute_c.
function iSASE_Absolute_c_Callback(hObject, eventdata, handles)
set(handles.iSASE_Absolute_c,'value',1);
set(handles.iSASE_relative_c,'value',0);
end

% --- Executes on button press in iSASE_relative_c.
function iSASE_relative_c_Callback(hObject, eventdata, handles)
set(handles.iSASE_Absolute_c,'value',0);
set(handles.iSASE_relative_c,'value',1);
end


function iSASE_TaperShape0_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_TaperShape0 as text
%        str2double(get(hObject,'String')) returns contents of iSASE_TaperShape0 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_TaperShape0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function iSASE_TaperShape1_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_TaperShape1 as text
%   e     str2double(get(hObject,'String')) returns contents of iSASE_TaperShape1 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_TaperShape1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function iSASE_TaperShape2_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_TaperShape2 as text
%        str2double(get(hObject,'String')) returns contents of iSASE_TaperShape2 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_TaperShape2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function iSASE_TaperShape3_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_TaperShape3 as text
%        str2double(get(hObject,'String')) returns contents of iSASE_TaperShape3 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_TaperShape3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_TaperShape3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in iSASE_TaperShapeApply.
function iSASE_TaperShapeApply_Callback(hObject, eventdata, handles)
Start=check_if_scalar_double(get(handles.iSASE_TaperShape0,'String'));
Linear=check_if_scalar_double(get(handles.iSASE_TaperShape1,'String'));
Quadratic=check_if_scalar_double(get(handles.iSASE_TaperShape3,'String'));
QuadStart=round(abs(check_if_scalar_double(get(handles.iSASE_TaperShape2,'String'))));
CurrentTable=get(handles.iSASE_State,'data');
if(~isnan(Start*Linear*Quadratic*QuadStart))
    Inserted=0;
    InsertedQuadratic=0;
        for j=1:handles.Segments
           if(handles.isInstalled(j))
               if(CurrentTable{j,1})
                   if(j>=QuadStart)
                       InsertedQuadratic=InsertedQuadratic+1;
                   end
                   CurrentTable {j,3} = Start + Inserted*Linear + (InsertedQuadratic*(InsertedQuadratic+1))/2*Quadratic + CurrentTable {j,4};
                   Inserted=Inserted+1;    
               else

               end
           else
               CurrentTable {j,4} = NaN;
               CurrentTable {j,3} = NaN;
               CurrentTable {j,2} = NaN;
           end
        end
        set(handles.iSASE_State,'data',CurrentTable);
    
end
Add_Blue_Stars_To_Plot(handles)
end


function iSASE_Difference0_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_Difference0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_Difference0 as text
%        str2double(get(hObject,'String')) returns contents of iSASE_Difference0 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_Difference0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_Difference0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function iSASE_Difference1_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_Difference1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_Difference1 as text
%        str2double(get(hObject,'String')) returns contents of iSASE_Difference1 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_Difference1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_Difference1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function iSASE_Difference2_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_Difference2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSASE_Difference2 as text
%        str2double(get(hObject,'String')) returns contents of iSASE_Difference2 as a double
end

% --- Executes during object creation, after setting all properties.
function iSASE_Difference2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_Difference2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in iSASE_ApplyDifference.
function iSASE_ApplyDifference_Callback(hObject, eventdata, handles)
PresentK=loadPresentKvalues ( handles );
Constant=check_if_scalar_double(get(handles.iSASE_Difference0,'String'));
Linear=check_if_scalar_double(get(handles.iSASE_Difference1,'String'));
Quadratic=check_if_scalar_double(get(handles.iSASE_Difference2,'String'));
CurrentTable=get(handles.iSASE_State,'data');
Inserted=0;
if(~isnan(Constant*Linear*Quadratic))
    for j=1:handles.Segments
       if(handles.isInstalled(j))
           if(CurrentTable{j,1})
               CurrentTable {j,4} = Constant + Inserted*Linear + (Inserted*(Inserted+1))/2*Quadratic;
               CurrentTable {j,3} = PresentK(j) + CurrentTable {j,4} ;
               Inserted=Inserted+1;
           else
               CurrentTable {j,4} = 0;
               CurrentTable {j,3} = PresentK(j);
               
           end
           CurrentTable {j,2} = PresentK(j);
       else
           CurrentTable {j,4} = NaN;
           CurrentTable {j,3} = NaN;
           CurrentTable {j,2} = NaN;
       end
    end
    set(handles.iSASE_State,'data',CurrentTable);
end
Add_Blue_Stars_To_Plot(handles);
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
end

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in iSASEDifferenceSetTo0.
function iSASEDifferenceSetTo0_Callback(hObject, eventdata, handles)
set(handles.iSASE_Difference0,'String','0');
set(handles.iSASE_Difference1,'String','0');
set(handles.iSASE_Difference2,'String','0');
iSASE_ApplyDifference_Callback(hObject, eventdata, handles);
Add_Blue_Stars_To_Plot(handles);
end

% --- Executes on button press in MoveSelectedToBlueStars.
function MoveSelectedToBlueStars_Callback(hObject, eventdata, handles)
Current_iSASE_Table=get(handles.iSASE_State,'data');
Present_K=loadPresentKvalues( handles );
iSASE_K_Values=[Current_iSASE_Table{:,3}];
iSASE_SELECTED=[Current_iSASE_Table{:,1}];
iSASE_OldStatus=[Present_K;iSASE_SELECTED];
set(handles.iSASE_undo,'UserData',iSASE_OldStatus,'enable','on');
setKvalues_with_undulator_selection ( handles, iSASE_K_Values, iSASE_SELECTED);
end

function Add_Blue_Stars_To_Plot(handles)
    Current_iSASE_Table=get(handles.iSASE_State,'data');
    iSASE_K_Values=[Current_iSASE_Table{:,3}];
    iSASELine=[];
    for slot = 1 : handles.Segments
        segP ( 1 ) = handles.EnergyLoss { slot }.z_ini;
        segP ( 2 ) = handles.EnergyLoss { slot }.z_end;

        segK ( 1 ) = iSASE_K_Values ( slot );
        segK ( 2 ) = segK ( 1 );
        
        if ( isActive ( slot, handles ) )
            iSASELine(1,end+1)=mean(segP);
            if ( getHarm ( slot ) == 2 )
                EquCount = EquCount + 1;
                iSASELine(2,end)=iSASE_K_Values(slot);
            %plot ( mean(segP), iSASE_K_Values(slot),  'b*', 'Parent', axes_handle ); 
            elseif ( getHarm ( slot ) == 1 )
                iSASELine(2,end)=iSASE_K_Values(slot);
            elseif ( getHarm ( slot ) == handles.DeltaType ) %Delta 
                iSASELine(2,end)=iSASE_K_Values(slot);
            end 
        end
    end
    LineaDaCancellare=get(handles.MoveSelectedToBlueStars,'userdata');
    try
        delete(LineaDaCancellare)
    end
    hold  ( handles.TAPERDISPLAY, 'on' );
    CurrentBlueLine=plot (iSASELine(1,:), iSASELine(2,:),  'b*', 'Parent', handles.TAPERDISPLAY ); 
    hold  ( handles.TAPERDISPLAY, 'off' );
    set(handles.MoveSelectedToBlueStars,'userdata',CurrentBlueLine)
    
end


% --- Executes during object creation, after setting all properties.
function p_des8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function p_des8_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
PASS=-1; ID=8;
NewInput=get(hObject,'String');
NewNumericInput=check_if_scalar_double(NewInput);
if(~isnan(NewNumericInput))
    PASS=checkifinsiderange(NewNumericInput, ID, handles,PASS,deltaslot);
else
    PASS=0;
end
RestoreOrUpdate(handles,PASS,NewInput,ID);
update_parameters_from_rods(handles,2,deltaslot);
handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles),deltaslot);
end

function [Keff_Current,Full_Status]=read_delta_K_value(deltaslot,handles) %undulatorpv for future use (if more than 1 delta installed)
    for II=1:4
      ZVector_Current(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,10});
    end
Harmonic_Current=lcaGet(handles.AllDeltaUndulators{deltaslot,2,10});
Stokes_Current=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(ZVector_Current,handles, deltaslot),handles,deltaslot);
Ellipse_Status=deltagui_Stokes2Ellipse(Stokes_Current);
Keff_Current=deltagui_S0toKeff(Stokes_Current,Harmonic_Current,handles, deltaslot);
Full_Status=[Keff_Current, Harmonic_Current, Ellipse_Status(2:4),deltagui_Rods2RodsAverages(ZVector_Current),ZVector_Current];
end

function [Keff_Current,Full_Status]=read_delta_K_destination_value(deltaslot,handles) %undulatorpv for future use (if more than 1 delta installed)
    for II=1:4
      ZVector_Current(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9});
    end
Harmonic_Current=lcaGet(handles.AllDeltaUndulators{deltaslot,2,9});
Stokes_Current=deltagui_Deltaphi2Stokes(deltagui_rod2Deltaphi(ZVector_Current,handles, deltaslot),handles,deltaslot);
Ellipse_Status=deltagui_Stokes2Ellipse(Stokes_Current);
Keff_Current=deltagui_S0toKeff(Stokes_Current,Harmonic_Current,handles, deltaslot);
Full_Status=[Keff_Current, Harmonic_Current, Ellipse_Status(2:4),deltagui_Rods2RodsAverages(ZVector_Current),ZVector_Current];
end


% --- Executes on selection change in iSASE_ScanType.
function iSASE_ScanType_Callback(hObject, eventdata, handles)
% hObject    handle to iSASE_ScanType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns iSASE_ScanType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from iSASE_ScanType
end

% --- Executes during object creation, after setting all properties.
function iSASE_ScanType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSASE_ScanType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in iSASE_undo.
function iSASE_undo_Callback(hObject, eventdata, handles)
set(handles.iSASE_undo,'enable','off')
Old_K=get(handles.iSASE_undo,'UserData');
size(Old_K)
setKvalues_with_undulator_selection ( handles, Old_K(1,:), Old_K(2,:));
end


% --- Executes on selection change in WhichDeltaUndulator.
function WhichDeltaUndulator_Callback(hObject, eventdata, handles)
SynchronizaDesActOnce_Callback(hObject, eventdata, handles)
DeltaUpdate(handles);
if(get(handles.Deltalistenbutton,'userdata'))
    Deltalistenbutton_Callback(hObject, eventdata, handles);
end
DeltaResetScan_Callback(hObject, eventdata, handles);
deltaslot=get(handles.WhichDeltaUndulator,'value');
BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
end


% --- Executes during object creation, after setting all properties.
function WhichDeltaUndulator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WhichDeltaUndulator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function S=deltagui_Deltaphi2Stokes(Deltaphi,handles, deltaslot)
Deltaphi(3)=-Deltaphi(3);
S=deltagui_Deltaphi2Stokes_Version1(Deltaphi,handles, deltaslot);
end
function [Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi(S,handles, deltaslot)
[Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi_Version1(S,handles, deltaslot);
end

function S=deltagui_Deltaphi2Stokes_OLD(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)=-handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));
end

function S=deltagui_Deltaphi2Stokes_Version1(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= -handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));
end

function S=deltagui_Deltaphi2Stokes_Version2(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= -handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)= -handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));
end

function S=deltagui_Ellipse2Stokes(EP)
S(1)=EP(1);
S(2)=EP(1)*EP(3)*cos(EP(2)*2*pi/180);
S(3)=EP(1)*EP(3)*sin(EP(2)*2*pi/180);
S(4)=EP(1)*sqrt(1-EP(3)^2)*EP(4);
end

function S=deltagui_ExEy2Stokes(ExEyV)

S(1)=ExEyV(1);
S(2)=ExEyV(1)*(2*ExEyV(2)-1);
S(3)=2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*cos(ExEyV(3)/180*pi);
S(4)=-2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*sin(ExEyV(3)/180*pi);
end

function Range=deltagui_InputParameterLimits(handles,InputParameter,AllInputs, deltaslot)
%InputParameter
%1: Keff
%2: Harmonic
%3: e2
%4: e3
%5: e4
%6: Avgz
%7: deltaz13
%8: avgz13
%9: deltaz24
%10: avgz24
%11: z1
%12: z2
%13: z3
%14: z4

% (handles.UndConsts.lambda_u*1000)
% handles.AllDeltaConstants(deltaslot).lambda_u
% handles.AllDeltaConstants(deltaslot).KMax
% handles.AllDeltaConstants(deltaslot).Zmin
% handles.AllDeltaConstants(deltaslot).Zmax
KindOfFit=get(handles.KindOfFit,'value');
HardMin=handles.DeltaPvNamesCell{InputParameter,2};
HardMax=handles.DeltaPvNamesCell{InputParameter,3};

switch(InputParameter)
    case 1 %keff
        SoftMin=sqrt(2*( AllInputs(2)*handles.AllDeltaConstants(deltaslot).lambda_u - (handles.UndConsts.lambda_u*1000))/(handles.UndConsts.lambda_u*1000) );
        SoftMax=sqrt( 2*AllInputs(2)*handles.AllDeltaConstants(deltaslot).lambda_u/(handles.UndConsts.lambda_u*1000) + handles.AllDeltaConstants(deltaslot).KMax^2*AllInputs(2)*handles.AllDeltaConstants(deltaslot).lambda_u/((handles.UndConsts.lambda_u*1000)+AllInputs(4)*(handles.UndConsts.lambda_u*1000)*abs(sin(AllInputs(3)*pi/90)))- 2 ) ;
        SoftMin2=sqrt(2*AllInputs(2)*handles.AllDeltaConstants(deltaslot).lambda_u/(handles.UndConsts.lambda_u*1000)-2);
        Range=[max(SoftMin,SoftMin2),SoftMax];
    case 2 %harmonics
        SoftMin=ceil( (2+AllInputs(1)^2)*((handles.UndConsts.lambda_u*1000)/handles.AllDeltaConstants(deltaslot).lambda_u)*(1+AllInputs(4)*abs(sin(AllInputs(3)*pi/90))) / (2 + handles.AllDeltaConstants(deltaslot).KMax^2 + 2*AllInputs(4)*abs(sin(AllInputs(3)*pi/90)) )   );
        SoftMax=floor(((handles.UndConsts.lambda_u*1000)*(2+AllInputs(1)^2))/(2*handles.AllDeltaConstants(deltaslot).lambda_u));
        Range=SoftMin:min(HardMax,SoftMax);
    case 3 %angle
        if(KindOfFit==1)
            Range=[-90,0,90];
            return
        end
        if(abs(handles.AllDeltaConstants(deltaslot).KMax^2/deltagui_Keff2S0(AllInputs(1),AllInputs(2),handles,deltaslot)-1)/AllInputs(4)>=1)
            Range=[HardMin,HardMax]; 
            return 
        end
        MaxAngle=90/pi*asin(abs(handles.AllDeltaConstants(deltaslot).KMax^2/deltagui_Keff2S0(AllInputs(1),AllInputs(2),handles,deltaslot)-1)/AllInputs(4));
        Range(1,1:2)= [HardMin,HardMin+MaxAngle];
        Range(2,1:2)= [-MaxAngle,MaxAngle];
        Range(3,1:2)= [HardMax-MaxAngle,HardMax];
        
%         if( ( (-(2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) + AllInputs(2)*(2+ handles.AllDeltaConstants(deltaslot).KMax^2)*(handles.UndConsts.lambda_u*1000) )  / (AllInputs(4)*(2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) - 2*AllInputs(4)*AllInputs(2)*(handles.UndConsts.lambda_u*1000) )  ) >=1 )
%            Range=[HardMin,HardMax]; 
%         else
%            MaxAngle=abs(90/pi*asin( (-(2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) + AllInputs(2)*(2+ handles.AllDeltaConstants(deltaslot).KMax^2)*(handles.UndConsts.lambda_u*1000) )  / (AllInputs(4)*(2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) - 2*AllInputs(4)*AllInputs(2)*(handles.UndConsts.lambda_u*1000) )  ));
%            Range(1,1:2)= [HardMin,HardMin+MaxAngle];
%            Range(2,1:2)= [-MaxAngle,MaxAngle];
%            Range(3,1:2)= [HardMax-MaxAngle,HardMax];
%         end
    case 4 %degree of linear polarization
        MustBePositive=handles.AllDeltaConstants(deltaslot).KMax^2/deltagui_Keff2S0(AllInputs(1),AllInputs(2),handles,deltaslot)-1;
        if(MustBePositive<0)
            Range=[];
            return
        end
        Range=[HardMin,min(HardMax,MustBePositive/sin(2*AllInputs(3)*pi/180))];
%          SoftMax= (-(2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) + AllInputs(2)*(2+ handles.AllDeltaConstants(deltaslot).KMax^2)*(handles.UndConsts.lambda_u*1000) )  / ((2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) - 2*AllInputs(2)*(handles.UndConsts.lambda_u*1000) )/abs(sin(pi*AllInputs(3)/90));
%          SoftMax=abs(SoftMax);
% %          (-(2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) + AllInputs(2)*(2+ handles.AllDeltaConstants(deltaslot).KMax^2)*(handles.UndConsts.lambda_u*1000) )
% %          ((2+AllInputs(1)^2)*(handles.UndConsts.lambda_u*1000) - 2*AllInputs(2)*(handles.UndConsts.lambda_u*1000) )
% %          abs(sin(pi*AllInputs(3)/90))
%          Range=[HardMin,min(SoftMax,HardMax)];
    case 5
        if(AllInputs(4)==1)
            Range=0;
        else
            Range=[-1,1];
        end        
    case 6
        SpaceLeft=min(AllInputs(11:14)) - handles.AllDeltaConstants(deltaslot).Zmin;
        SpaceRight=handles.AllDeltaConstants(deltaslot).Zmax - max(AllInputs(11:14));
        CurrentAvg=mean(AllInputs(11:14));
        SoftMin=CurrentAvg - SpaceLeft; SoftMax=CurrentAvg + SpaceRight;
        Range=[max(HardMin,SoftMin),min(SoftMax,HardMax)];
    case 7 %opening of u13 keeping avg of u13 
        SoftMax=2*(handles.AllDeltaConstants(deltaslot).Zmax-abs(AllInputs(8))/2);
        SoftMin=-SoftMax;
        Range=[max(HardMin,SoftMin),min(SoftMax,HardMax)];
    case 8        
        SoftMax=handles.AllDeltaConstants(deltaslot).Zmax-abs(AllInputs(7))/2;
        SoftMin=-SoftMax;
        Range=[max(HardMin,SoftMin),min(SoftMax,HardMax)];
    case 9
        SoftMax=2*(handles.AllDeltaConstants(deltaslot).Zmax-abs(AllInputs(10)/2));
        SoftMin=-SoftMax;
        Range=[max(HardMin,SoftMin),min(SoftMax,HardMax)];
    case 10
        SoftMax=handles.AllDeltaConstants(deltaslot).Zmax-abs(AllInputs(9))/2;
        SoftMin=-SoftMax;
        Range=[max(HardMin,SoftMin),min(SoftMax,HardMax)];
    case 11
        Range=[HardMin,HardMax];
    case 12
        Range=[HardMin,HardMax];
    case 13
        Range=[HardMin,HardMax];
    case 14
        Range=[HardMin,HardMax];
end
end

function S0=deltagui_Keff2S0(Keff,Harmonic,handles, deltaslot)
S0= -2 + (2*(handles.UndConsts.lambda_u*1000) + Keff^2*(handles.UndConsts.lambda_u*1000))/(handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic );
end

function RodsAvgs=deltagui_Rods2RodsAverages(Rods)
RodsAvgs(1)=mean(Rods);
RodsAvgs(2)=Rods(1)-Rods(3);
RodsAvgs(3)=(Rods(1)+Rods(3))/2;
RodsAvgs(4)=Rods(2)-Rods(4);
RodsAvgs(5)=(Rods(2)+Rods(4))/2;
end

function [Zpositions,ZAverages]=deltagui_RodsAverages2Rods(RodsAVGs)

ZAverages=[(RodsAVGs(2)+RodsAVGs(4))/2,RodsAVGs];

Zpositions(1)=RodsAVGs(2) + RodsAVGs(1)/2;
Zpositions(2)=RodsAVGs(4) + RodsAVGs(3)/2;
Zpositions(3)=RodsAVGs(2) - RodsAVGs(1)/2;
Zpositions(4)=RodsAVGs(4) - RodsAVGs(3)/2;

end

function Keff=deltagui_S0toKeff(S,Harmonic,handles, deltaslot)
Keff=sqrt( ( 2*handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic - 2*(handles.UndConsts.lambda_u*1000) + S(1)*handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic  ) / (handles.UndConsts.lambda_u*1000));
end

function [Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi_OLD(S,handles, deltaslot)
Deltaphi(1)=acos(2*(S(1)+S(3))/handles.AllDeltaConstants(deltaslot).KMax^2 -1);
Deltaphi(2)=acos(2*(S(1)-S(3))/handles.AllDeltaConstants(deltaslot).KMax^2 -1);
Deltaphi(3)=angle(S(2)-S(4)*1i);
Deltaphistar=angle(-S(2)+S(4)*1i);

DeltaphiMatrix=zeros(32,3);
DeltaphiMatrix(1:4,1)=Deltaphi(1);
DeltaphiMatrix(5:8,1)=-Deltaphi(1);
DeltaphiMatrix(9:12,1)=DeltaphiMatrix(1:4,1)-2*pi;
DeltaphiMatrix(13:16,1)=DeltaphiMatrix(5:8,1)+2*pi;
DeltaphiMatrix(17:32,1)=DeltaphiMatrix(1:16,1);
DeltaphiMatrix(1:4:32,2)=Deltaphi(2);
DeltaphiMatrix(2:4:32,2)=-Deltaphi(2);
DeltaphiMatrix(3:4:32,2)=Deltaphi(2)-2*pi;
DeltaphiMatrix(4:4:32,2)=-Deltaphi(2)+2*pi;
DeltaphiMatrix(4:4:32,2)=-Deltaphi(2)+2*pi;
DeltaphiMatrix([1,2,5,6,11,12,15,16],3)=Deltaphi(3);
DeltaphiMatrix([3,4,7,8,9,10,13,14],3)=Deltaphistar;%-Deltaphi(3);
DeltaphiMatrix([1,2,5,6,11,12,15,16]+16,3)=Deltaphi(3)+2*pi*sign(S(4));
DeltaphiMatrix([3,4,7,8,9,10,13,14]+16,3)=Deltaphistar-2*pi*sign(S(4));
end

function [Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi_Version1(S,handles, deltaslot)
Deltaphi(1)=acos(2*(S(1)-S(3))/handles.AllDeltaConstants(deltaslot).KMax^2 -1);
Deltaphi(2)=acos(2*(S(1)+S(3))/handles.AllDeltaConstants(deltaslot).KMax^2 -1);
Deltaphi(3)=angle(S(2)-S(4)*1i);
Deltaphistar=-angle(-S(2)-S(4)*1i);

DeltaphiMatrix=zeros(32,3);
DeltaphiMatrix(1:4,1)=Deltaphi(1);
DeltaphiMatrix(5:8,1)=-Deltaphi(1);
DeltaphiMatrix(9:12,1)=DeltaphiMatrix(1:4,1)-2*pi;
DeltaphiMatrix(13:16,1)=DeltaphiMatrix(5:8,1)+2*pi;
DeltaphiMatrix(17:32,1)=DeltaphiMatrix(1:16,1);
DeltaphiMatrix(1:4:32,2)=Deltaphi(2);
DeltaphiMatrix(2:4:32,2)=-Deltaphi(2);
DeltaphiMatrix(3:4:32,2)=Deltaphi(2)-2*pi;
DeltaphiMatrix(4:4:32,2)=-Deltaphi(2)+2*pi;
DeltaphiMatrix(4:4:32,2)=-Deltaphi(2)+2*pi;
DeltaphiMatrix([1,2,5,6,11,12,15,16],3)=Deltaphi(3);
DeltaphiMatrix([3,4,7,8,9,10,13,14],3)=Deltaphistar;%-Deltaphi(3);
DeltaphiMatrix([1,2,5,6,11,12,15,16]+16,3)=Deltaphi(3)+2*pi*sign(S(4));
DeltaphiMatrix([3,4,7,8,9,10,13,14]+16,3)=Deltaphistar-2*pi*sign(S(4));
end


function [Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi_Version2(S,handles, deltaslot)
Deltaphi(1)=acos(2*(S(1)-S(3))/handles.AllDeltaConstants(deltaslot).KMax^2 -1);
Deltaphi(2)=acos(2*(S(1)+S(3))/handles.AllDeltaConstants(deltaslot).KMax^2 -1);
Deltaphi(3)=angle(S(2)+S(4)*1i);
Deltaphistar=-angle(-S(2)+S(4)*1i);

DeltaphiMatrix=zeros(32,3);
DeltaphiMatrix(1:4,1)=Deltaphi(1);
DeltaphiMatrix(5:8,1)=-Deltaphi(1);
DeltaphiMatrix(9:12,1)=DeltaphiMatrix(1:4,1)-2*pi;
DeltaphiMatrix(13:16,1)=DeltaphiMatrix(5:8,1)+2*pi;
DeltaphiMatrix(17:32,1)=DeltaphiMatrix(1:16,1);
DeltaphiMatrix(1:4:32,2)=Deltaphi(2);
DeltaphiMatrix(2:4:32,2)=-Deltaphi(2);
DeltaphiMatrix(3:4:32,2)=Deltaphi(2)-2*pi;
DeltaphiMatrix(4:4:32,2)=-Deltaphi(2)+2*pi;
DeltaphiMatrix(4:4:32,2)=-Deltaphi(2)+2*pi;
DeltaphiMatrix([1,2,5,6,11,12,15,16],3)=Deltaphi(3);
DeltaphiMatrix([3,4,7,8,9,10,13,14],3)=Deltaphistar;%-Deltaphi(3);
DeltaphiMatrix([1,2,5,6,11,12,15,16]+16,3)=Deltaphi(3)+2*pi*sign(S(4));
DeltaphiMatrix([3,4,7,8,9,10,13,14]+16,3)=Deltaphistar-2*pi*sign(S(4));
end

function EP=deltagui_Stokes2Ellipse(S)
EP(1)=S(1);
EP(2)=angle(S(2)+1i*S(3))/2*(180/pi);
EP(3)=sqrt(S(2)^2+S(3)^2)/S(1);
EP(4)=sign(S(4));

if(S(1)==0) % for S0=1 gives the undefined state of degree of linear polarization to 0.
   EP(3)=0; 
end
end

function ExEyV=deltagui_Stokes2ExEy(S)
ExEyV(1)=S(1);
ExEyV(2)=(S(2)/S(1)+1)/2;
ExEyV(3)=angle(S(3)-1i*S(4))*180/pi;
end


% --- Executes on button press in DebugCodeOnTheFlyButton.
function DebugCodeOnTheFlyButton_Callback(hObject, eventdata, handles)
set(handles.Open_DeltaPanel,'UserData',1); set(handles.Open_iSASEpanel,'UserData',0);set(handles.Open_StandardPanel,'UserData',0);
% handles = updateDisplay ( handles );
set(handles.Open_DeltaPanel,'backgroundcolor',handles.ColorOn); set(handles.Open_iSASEpanel,'backgroundcolor',handles.ColorOff);set(handles.Open_StandardPanel,'backgroundcolor',handles.ColorOff);
set(handles.uipanel8,'visible','off');set(handles.uipanel15,'visible','off'); set(handles.uipanel9,'visible','on');
end


% --- Executes during object creation, after setting all properties.
function TAPERDISPLAY_CreateFcn(hObject, eventdata, handles)
end



function p_des15_Callback(hObject, eventdata, handles)
PASS=-1; ID=15; deltaslot=get(handles.WhichDeltaUndulator,'value');
In=get(handles.p_des15,'string');
NewNumericInput=check_if_scalar_double(In);

if(~isnan(NewNumericInput))
    if((handles.AllPhaseShifters(deltaslot).minimum<=NewNumericInput) && (NewNumericInput<=handles.AllPhaseShifters(deltaslot).maximum))
        PASS=1;
    else
        PASS=-1;
    end
else
    PASS=0;
end
    switch PASS
        case -1
            set(handles.delta_dialogBox,'String',' change denied because of value outside allowed range'); 
            OldInput=get(handles.p_des15,'UserData');
            set(handles.p_des15,'String',OldInput);
        case 0
            set(handles.delta_dialogBox,'String',' change denied because of unrecognized input') 
            OldInput=get(handles.p_des15,'UserData');
            set(handles.p_des15,'String',OldInput);
        case 1
            set(handles.p_des15,'UserData',NewNumericInput);
            set(handles.p_des15,'String',num2str(str2num(In),handles.DeltaPvNamesCell{1,11}));
            set(handles.delta_dialogBox,'String','') ;
    end
end

% --- Executes during object creation, after setting all properties.
function p_des15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_des15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end,end



function InAndOutExpression_Callback(hObject, eventdata, handles)
% hObject    handle to InAndOutExpression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InAndOutExpression as text
%        str2double(get(hObject,'String')) returns contents of InAndOutExpression as a double
end


% --- Executes during object creation, after setting all properties.
function InAndOutExpression_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InAndOutExpression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end,end

function UpdateInAndOutTable(handles)
RowValue=cell(handles.Segments,1); 
for slot=1:handles.Segments
    if(handles.Type(slot)==0)
        RowValue{slot}='***';
    elseif(~handles.isInstalled)
        RowValue{slot}='***';
    elseif isUnderMaintenance ( slot )
        RowValue{slot}='Maint.';
    elseif isActive(slot,handles)
        RowValue{slot}='IN';
    else
        RowValue{slot}='OUT';
    end
end
set(handles.InandOutTable,'data',RowValue);
end

% --- Executes on button press in StandardMoveIn.
function StandardMoveIn_Callback(hObject, eventdata, handles)
UpdateInAndOutTable(handles);
CurrentStatus=get(handles.StandardMoveIn,'userdata')
if(~CurrentStatus) 
    InputExpression=str2num(get(handles.InAndOutExpression,'String'));
    if((any(isnan(InputExpression))) || (any(isinf(InputExpression))) || (isempty(InputExpression)) || (numel(InputExpression)>handles.Segments) )
       reset_in_and_out_buttons(handles);
       return
    else
       inserted=0;
       CurrentState=get(handles.InandOutTable,'data');
       CurrentOut=strcmp(CurrentState,'OUT');
       anymove=unique(round(InputExpression));
       for KK=1:length(anymove)
          if((anymove(KK)>=1) && (anymove(KK)<=handles.Segments))
              if(CurrentOut(anymove(KK)))
                    inserted=inserted+1;
                    ToBeMovedIn(inserted)=anymove(KK);
              end
          end
       end
       %check if it there is any reasonable move to do
       if(inserted)
           set(handles.StandardMoveIn,'userdata',ToBeMovedIn);
           set(handles.StandardMoveIn,'userdata',1); set(handles.StandardMoveIn,'string','No, please stop!'); set(handles.StandardMoveOut,'userdata',2); set(handles.StandardMoveIn,'string','Yes, Move in!');
       else
          reset_in_and_out_buttons(handles);
          return 
       end
       
    end
    
elseif(CurrentStatus==1)
        reset_in_and_out_buttons(handles);
elseif(CurrentStatus==2)
    anymoves=get(handles.StandardMoveOut,'userdata');
    %Move them OUT !
    for KK=1:length(anymoves)
       if((handles.Type(anymoves(KK))>=0) && (handles.Type(anymoves(KK))<=99) )
           lcaPut ( sprintf ( 'USEG:UND1:%d50:TM2MOTOR', anymoves(KK) ), 80 );
       elseif (handles.Type(anymoves(KK))==handles.DeltaType)
           deltaslot=handles.SlotToDeltaUndulatorsConversion(anymoves(KK));
           lcaPut(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1},'Off');
           Harmonic=1;
            for II=1:4
                DeltaParkPosition(II)=lcaGet(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+2,II});
            end    
            Deltaphi=deltagui_rod2Deltaphi(DeltaParkPosition,handles, deltaslot);
            S=deltagui_Deltaphi2Stokes(Deltaphi,handles,deltaslot);
            EP=deltagui_Stokes2Ellipse(S); EP(3)=0;
            ZAvgs=deltagui_Rods2RodsAverages(DeltaParkPosition);
            Keff=deltagui_S0toKeff(S,Harmonic,handles, deltaslot);
            Status_Destination=[Keff,Harmonic,EP(2:4),ZAvgs,DeltaParkPosition];
            for II=1:4 %this resets twice the status, not really needed
                   lcaPut(handles.AllDeltaUndulators{deltaslot,II,9},Status_Destination(II));
                   lcaPut(handles.AllDeltaUndulators{deltaslot,handles.DeltaRodsParameters(1)+II-1,9},DeltaParkPosition(II));
            end
            lcaPut(handles.AllDeltaUndulators{deltaslot,II+1,9},Status_Destination(II+1));
            for II=1:handles.NumberOfDeltaParameters % Resets entire scan destination
                 lcaPut(handles.DeltaPvNamesCell{II,4},Status_Destination(II));
            end
       end
    end
    reset_in_and_out_buttons(handles);
end

end


% --- Executes on button press in StandardMoveOut.
function StandardMoveOut_Callback(hObject, eventdata, handles)
UpdateInAndOutTable(handles);
CurrentStatus=get(handles.StandardMoveIn,'userdata')
if(~CurrentStatus) 
    InputExpression=str2num(get(handles.InAndOutExpression,'String'));
    if((any(isnan(InputExpression))) || (any(isinf(InputExpression))) || (isempty(InputExpression)) || (numel(InputExpression)>handles.Segments) )
       reset_in_and_out_buttons(handles);
       return
    else
       inserted=0;
       CurrentState=get(handles.InandOutTable,'data');
       CurrentIn=strcmp(CurrentState,'IN');
       anymove=unique(round(InputExpression));
       for KK=1:length(anymove)
          if((anymove(KK)>=1) && (anymove(KK)<=handles.Segments))
              if(CurrentIn(anymove(KK)))
                    inserted=inserted+1;
                    ToBeMovedOut(inserted)=anymove(KK);
              end
          end
       end
       %check if it there is any reasonable move to do
       if(inserted)
           set(handles.StandardMoveOut,'userdata',ToBeMovedOut);
           set(handles.StandardMoveOut,'userdata',1); set(handles.StandardMoveOut,'string','No, please stop!'); set(handles.StandardMoveIn,'userdata',2); set(handles.StandardMoveIn,'string','Yes, Pull Out!');
       else
          reset_in_and_out_buttons(handles);
          return 
       end
       
    end
elseif(CurrentStatus==1)
        reset_in_and_out_buttons(handles);
elseif(CurrentStatus==2)
    anymoves=get(handles.StandardMoveIn,'userdata');
    for KK=1:length(anymoves)
       if((handles.Type(anymoves(KK))>=0) && (handles.Type(anymoves(KK))<=99) )
           lcaPut ( sprintf ( 'USEG:UND1:%d50:TM2MOTOR', anymoves(KK) ), 0 );
       elseif (handles.Type(anymoves(KK))==handles.DeltaType)
           deltaslot=handles.SlotToDeltaUndulatorsConversion(anymoves(KK));
           lcaPut(handles.AllDeltaUndulators{deltaslot,handles.NumberOfDeltaParameters+1,1},'On');
       end
    end
    reset_in_and_out_buttons(handles);
end
end

function reset_in_and_out_buttons(handles)
set(handles.StandardMoveIn,'userdata',0); set(handles.StandardMoveIn,'string','Move In'); set(handles.StandardMoveOut,'userdata',0); set(handles.StandardMoveOut,'string','Move Out');
end


% --- Executes on button press in PhaseShifterMove.
function PhaseShifterMove_Callback(hObject, eventdata, handles)
deltaslot=get(handles.WhichDeltaUndulator,'value');
valore=str2num(get(handles.p_des15,'string'));
lcaPutNoWait(handles.AllDeltaUndulators{deltaslot,handles.FirstPhaseShifterPVLocation,1},valore);
end


% --- Executes on selection change in KindOfFit.
function KindOfFit_Callback(hObject, eventdata, handles)
 switch(get(handles.KindOfFit,'value'))
     case 1
         TurnInputBoxes(1,handles);
         set(handles.KindOfFit,'backgroundcolor','w');
         deltaslot=get(handles.WhichDeltaUndulator,'value');
         update_parameters_from_rods(handles,1,deltaslot);
         handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
     case 2
         TurnInputBoxes(1,handles);
         set(handles.KindOfFit,'backgroundcolor','w');
         deltaslot=get(handles.WhichDeltaUndulator,'value');
         update_parameters_from_rods(handles,1,deltaslot);
         handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
     case 3
         TurnInputBoxes(1,handles);
         set(handles.KindOfFit,'backgroundcolor','w');
         deltaslot=get(handles.WhichDeltaUndulator,'value');
         update_parameters_from_rods(handles,1,deltaslot);
         handles=BuildDeltaMenuHelp(handles, ReadAllGuiInput(handles), deltaslot);
 end
end

function TurnInputBoxes(OnOff,handles)
    if(OnOff)
           for II=3:14
              set(handles.DeltaPvNamesCell{II,7},'enable','on');
           end
    else
           for II=3:14
              set(handles.DeltaPvNamesCell{II,7},'enable','off');
           end
    end
end

% --- Executes during object creation, after setting all properties.
function KindOfFit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KindOfFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function [Z,ErrorState]=deltagui_Deltaphi2Rods(DeltaphiMatrix,CurrentPosition,MovementType,handles, deltaslot)
ErrorState=0;
ZMatrix(:,1)=handles.AllDeltaConstants(deltaslot).lambda_u/(2*pi)*(DeltaphiMatrix(:,1)/2 + DeltaphiMatrix(:,3)/2);
ZMatrix(:,2)=handles.AllDeltaConstants(deltaslot).lambda_u/(2*pi)*(DeltaphiMatrix(:,2)/2 - DeltaphiMatrix(:,3)/2);
ZMatrix(:,3)=handles.AllDeltaConstants(deltaslot).lambda_u/(2*pi)*(-DeltaphiMatrix(:,1)/2 + DeltaphiMatrix(:,3)/2);
ZMatrix(:,4)=handles.AllDeltaConstants(deltaslot).lambda_u/(2*pi)*(-DeltaphiMatrix(:,2)/2 - DeltaphiMatrix(:,3)/2);

KIND_OF_FIT=get(handles.KindOfFit,'value');

    if(KIND_OF_FIT==3)
        if(MovementType>3)
           KIND=MovementType-3;
           Z=ZMatrix(KIND,:);
           if(any(abs(Z)>16))
              KIND=1;
              Z=ZMatrix(1,:);
              set(handles.DeltaMovementType,'value',4);
              set(handles.delta_dialogBox,'string',[datestr(clock), 'Mov. Type forced to 1'])
           end
           return
        end
        CurrentDeltaphi=deltagui_rod2Deltaphi(CurrentPosition,handles, deltaslot);
        Displacement=max(ZMatrix,[],2)-min(ZMatrix,[],2);
        DoableDeltaPhi=Displacement < (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin);
        DistanceMatrix=DeltaphiMatrix-ones(32,1)*CurrentDeltaphi;
        [~,ClosestConfiguration]=min((1-DoableDeltaPhi)*96+sum(abs(DistanceMatrix),2));
        ClosestConfiguration=1;
        ZVector=ZMatrix(ClosestConfiguration,:)
        CurrentMeanZ=mean(CurrentPosition);
        if((MovementType==1) || (MovementType==2))
            if(abs(CurrentMeanZ)< ( handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration)) )
                %Ok to keep current baricenter of the configuration
                Z=ZVector+CurrentMeanZ;
            elseif(CurrentMeanZ > 0)
                Z=ZVector+ (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
            elseif(CurrentMeanZ < 0)
                Z=ZVector- (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
            end
        else
           NewDesiredAvg=str2num(get(handles.p_des6,'string')); 
           if(abs(NewDesiredAvg)< ( handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration)) )
               Z=ZVector+NewDesiredAvg;
           elseif(CurrentMeanZ > 0)
                Z=ZVector+ (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
           elseif(CurrentMeanZ < 0)
                Z=ZVector- (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
           end 
        end
        return
    end
    if(KIND_OF_FIT==2)%This uses the big polynomial fitting all of it
        if(MovementType>3)
           KIND=MovementType-3;
           ZSTART=ZMatrix(KIND,:);
           if(any(abs(ZSTART)>16))
              KIND=1;
              ZSTART=ZMatrix(1,:);
              set(handles.DeltaMovementType,'value',4);
              set(handles.delta_dialogBox,'string',[datestr(clock), 'Mov. Type forced to 1'])
           end
        end
        CurrentDeltaphi=deltagui_rod2Deltaphi(CurrentPosition,handles, deltaslot);
        Displacement=max(ZMatrix,[],2)-min(ZMatrix,[],2);
        DoableDeltaPhi=Displacement < (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin);
        DistanceMatrix=DeltaphiMatrix-ones(32,1)*CurrentDeltaphi;
        [~,ClosestConfiguration]=min((1-DoableDeltaPhi)*96+sum(abs(DistanceMatrix),2));
        ClosestConfiguration=1;
        ZVector=ZMatrix(ClosestConfiguration,:)
        CurrentMeanZ=mean(CurrentPosition);
        if((MovementType==1) || (MovementType==2))
            if(abs(CurrentMeanZ)< ( handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration)) )
                %Ok to keep current baricenter of the configuration
                ZSTART=ZVector+CurrentMeanZ;
            elseif(CurrentMeanZ > 0)
                ZSTART=ZVector+ (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
            elseif(CurrentMeanZ < 0)
                ZSTART=ZVector- (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
            end
        else
           NewDesiredAvg=str2num(get(handles.p_des6,'string')); 
           if(abs(NewDesiredAvg)< ( handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration)) )
               ZSTART=ZVector+NewDesiredAvg;
           elseif(CurrentMeanZ > 0)
                ZSTART=ZVector+ (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
           elseif(CurrentMeanZ < 0)
                ZSTART=ZVector- (handles.AllDeltaConstants(deltaslot).Zmax-handles.AllDeltaConstants(deltaslot).Zmin - Displacement(ClosestConfiguration));
           end 
        end
        
        %Now go from a ZSTART with the basic formula to same polarization
        %state with the measured undulator strengths. Z should be "close to
        %Z Start ... is supposed to make the following delta phases
        %format long
        DF(1)= 2*pi*(ZSTART(1)-ZSTART(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
        DF(2)= 2*pi*(ZSTART(2)-ZSTART(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        DF(3)=  pi*(ZSTART(1)-ZSTART(2)+ZSTART(3)-ZSTART(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        %format short
        B13 = handles.AllDeltaConstants(deltaslot).KMax/sqrt(2)*cos(DF(1)/2)
        B24 = handles.AllDeltaConstants(deltaslot).KMax/sqrt(2)*cos(DF(2)/2)
        Phase=DF(3)
        
        SearchStart=[ZSTART(1)-ZSTART(3),ZSTART(2)-ZSTART(4),(ZSTART(1)-ZSTART(2)+ZSTART(3)-ZSTART(4))/2]
        SearchDestination=[B13,B24,Phase];
        OPTIONS=optimset;
        OPTIONS.TolX=10^-5;
        SearchEnd=fminsearch(@(DeltaZ) deltagui_funzionale_free_fit(DeltaZ,handles.DeltaUndulatorFits{deltaslot}.FreeFit,SearchDestination),SearchStart,OPTIONS)
        
        Z(1)= SearchEnd(1)/2 + SearchEnd(3)/2;
        Z(2)=-SearchEnd(1)/2 - SearchEnd(3)/2;
        Z(3)= SearchEnd(2)/2 + SearchEnd(3)/2;
        Z(4)=-SearchEnd(2)/2 - SearchEnd(3)/2;
        
        StartCheck=deltagui_free_fit(SearchStart,handles.DeltaUndulatorFits{deltaslot}.FreeFit)
        TargetCheck=deltagui_free_fit(SearchEnd,handles.DeltaUndulatorFits{deltaslot}.FreeFit)
        SearchDestination=[B13,B24,Phase]
        deltagui_funzionale_free_fit(SearchEnd,handles.DeltaUndulatorFits{deltaslot}.FreeFit,SearchDestination)
   
    end
    if(KIND_OF_FIT==1)% NON ROTATED MODE FIT
        %DeltaPhi 1324 translated into "Displacement parameter"
        %DeltaPhi 13 and DeltaPhi24 translated into "DeltaZ13, DeltaZ24 parameter"
        if((abs(abs(DeltaphiMatrix(1,1)) - abs(DeltaphiMatrix(1,2)) )>0.03) || (abs( DeltaphiMatrix(1,2) - pi/2)>0.1) )
            ErrorState=1; 
        end
        Stokes=deltagui_Deltaphi2Stokes(DeltaphiMatrix(1,:),handles,deltaslot);
        KValue=sqrt(Stokes(1));
        SingleParameterFit=deltagui_KValue2SingleParameter(KValue,handles,'CPLMF',deltaslot);%Serve un polinomio leggermente diverso
        Displacement=delta_gui_DeltaPhi1324ToDisplacement(handles,DeltaphiMatrix(1,3),deltaslot);
        Correction=ppval(handles.DeltaUndulatorFits{deltaslot}.AdditionalDisplacement,Displacement);
%         disp(['Displacement', num2str(Displacement)]);
%         disp(['Correction', num2str(Correction)]);
%         disp(['SingleParameterFit',num2str(SingleParameterFit)])
        %RESONANCE WAS AT 3.475
        
%         SingleParameterFit=deltagui_KValue2SingleParameter(KValue,handles,Displacement,deltaslot);
%         Displacement=delta_gui_DeltaPhi1324ToDisplacement(DeltaphiMatrix(1,3));
        
        Z(1)=Displacement/2+SingleParameterFit+Correction/2;
        Z(2)=-Displacement/2+SingleParameterFit+Correction/2;
        Z(3)=Displacement/2-SingleParameterFit-Correction/2;
        Z(4)=-Displacement/2-SingleParameterFit-Correction/2;
%         disp(['gap = ',num2str(Z(1)-Z(3)),' same as ',num2str(Z(2)-Z(4))])
    end
end

function [Deltaphi,ErrorState]=deltagui_rod2Deltaphi(rod,handles, deltaslot)
ErrorState=0;
KIND_OF_FIT=get(handles.KindOfFit,'value');
switch(KIND_OF_FIT)
    case 2 % Fitting All The Parameters.
        %This is straightforward, calculate the parameters and calculate
        %the K values, then assigns DeltaPhi depending on what found.
        ZAVG1 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Avg13;
        ZAVG2 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Avg24;
        ZD1 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Dif13;
        ZD2 = handles.DeltaUndulatorFits{deltaslot}.FreeFit.Dif24;
        Z1= rod(1) + ZAVG1 -ZD1/2;
        Z2= rod(2) + ZAVG2 -ZD2/2;
        Z3= rod(3) + ZAVG1 +ZD1/2;
        Z4= rod(4) + ZAVG2 +ZD2/2;
        Argument1=cos((2*pi*( Z1-Z3 )/32)/2);
        Argument2=cos((2*pi*( Z2-Z4 )/32)/2);
        Argument3=pi*( Z1 + Z3 - Z2 - Z4 )/32;     
        PowerMatrix=handles.DeltaUndulatorFits{deltaslot}.FreeFit.PowerMatrix;    
        B13=handles.DeltaUndulatorFits{deltaslot}.FreeFit.PolB13*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
        B24=handles.DeltaUndulatorFits{deltaslot}.FreeFit.PolB24*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
        Phase=handles.DeltaUndulatorFits{deltaslot}.FreeFit.Phase*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
        
        DeltaphiActual(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u; %such to make B13
        DeltaphiActual(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u; %such to make B24
        
        if(B13*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax>1)
            AllowedDeltaPhi=[-2*pi,0,2*pi];
        else 
            DeltaPhiDetermination=2*acos(B13*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax );
            DeltaPhiDetermination2=-DeltaPhiDetermination;
            AllowedDeltaPhi=[DeltaPhiDetermination,DeltaPhiDetermination+2*pi,DeltaPhiDetermination-2*pi,DeltaPhiDetermination2,DeltaPhiDetermination2+2*pi,DeltaPhiDetermination2-2*pi];
        end
        [~,MinLocation]=min(abs(AllowedDeltaPhi- DeltaphiActual(1)) );
        Deltaphi(1)=AllowedDeltaPhi(MinLocation);
        
        if(B24*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax>1)
            AllowedDeltaPhi=[-2*pi,0,2*pi];
        else 
            DeltaPhiDetermination=2*acos(B24*sqrt(2)/handles.AllDeltaConstants(deltaslot).KMax );
            DeltaPhiDetermination2=-DeltaPhiDetermination;
            AllowedDeltaPhi=[DeltaPhiDetermination,DeltaPhiDetermination+2*pi,DeltaPhiDetermination-2*pi,DeltaPhiDetermination2,DeltaPhiDetermination2+2*pi,DeltaPhiDetermination2-2*pi];
        end
        [~,MinLocation]=min(abs(AllowedDeltaPhi- DeltaphiActual(2)) );
        Deltaphi(2)=AllowedDeltaPhi(MinLocation);      
        Deltaphi(3)=Phase;
    case 3
        Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
        Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
    case 1
        ConfigurationLockThreshold=0.05;
        SetPointDistanceThreshold=0.02;
        ConfigurationCheck=[rod(1)-rod(3),rod(2)-rod(4)];
        Displacement=(rod(1)+rod(3))/2  - (rod(2)+rod(4))/2;
        SingleParameter=ConfigurationCheck(1)/2;
        CCC=ConfigurationCheck(2)-ConfigurationCheck(1);
%         (abs(CCC)<SetPointDistanceThreshold)
%         abs(Displacement)
        if ((abs(CCC)>SetPointDistanceThreshold)||(abs(Displacement) > handles.AllDeltaConstants(deltaslot).lambda_u/2) || (SingleParameter<(-SetPointDistanceThreshold)) || (SingleParameter>(handles.AllDeltaConstants(deltaslot).lambda_u/4+SetPointDistanceThreshold)) ) %readback as if it was in free-mode
            %disp('out of mode')
            Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
            Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
        else
            %disp('in mode')
            Correction=ppval(handles.DeltaUndulatorFits{deltaslot}.AdditionalDisplacement,Displacement);
            SingleParameter=SingleParameter-Correction/2;
            if(SingleParameter<0), SingleParameter=0;, end
            if(SingleParameter>8), SingleParameter=8;, end
            Kvalue=ppval(handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPLMF,cos(2*pi*2*SingleParameter/2/handles.AllDeltaConstants(deltaslot).lambda_u));
%             Kvalue
            deltagui_S0toKeff(Kvalue^2,1,handles, deltaslot);
            SingleParameterFit=deltagui_KValue2SingleParameter(Kvalue,handles,'CPLMF',deltaslot);
            Deltaphi(1)=2*acos(Kvalue/handles.AllDeltaConstants(deltaslot).KMax);
            Deltaphi(2)=2*acos(Kvalue/handles.AllDeltaConstants(deltaslot).KMax);
            Deltaphi(3)=pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
            S=deltagui_Deltaphi2Stokes(Deltaphi,handles,deltaslot);
            usedKvalue=deltagui_S0toKeff(S(1),1, handles, deltaslot);
            
        end
end
end

function Displacement=delta_gui_DeltaPhi1324ToDisplacement(handles,DeltaPhi1324,deltaslot)
% handles.AllDeltaConstants(deltaslot).lambda_u
% handles.AllDeltaConstants(deltaslot).KMax
% handles.AllDeltaConstants(deltaslot).Zmin
% handles.AllDeltaConstants(deltaslot).Zmax
    Displacement=DeltaPhi1324/pi*handles.AllDeltaConstants(deltaslot).lambda_u/2;
end

function SingleParameter=deltagui_KValue2SingleParameter(KValue,handles,PolType,deltaslot)
    switch(PolType)
        case 'CPLMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPLMF;
        case 'CPRMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPRMF;
        case 'LPHMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.LPHMF;
        case 'LPVMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.LPVMF;
    end
    %disp(['Kvalue=',num2str(KValue)])
    Nodes=ppval(PS,PS.breaks);
    [~,Coeffs]=unmkpp(PS);
    if(KValue<Nodes(1)) %go to the off position and forget about it.
        SingleParameter=8;
        return
    end
%     disp(Nodes)
%     pause(0.5)
    PolinomialPiece=find(KValue>=Nodes,1,'last');
%     disp([PolinomialPiece])

    if(PolinomialPiece==length(Nodes))
        PolinomialPiece=length(Nodes)-1;
    end
    if(abs(ppval(PS,PS.breaks(PolinomialPiece)) - KValue)<10^-4)
        SingleParameter=acos(PS.breaks(PolinomialPiece))*32/pi/2;
        return
    end
    try
    CPOL=Coeffs(PolinomialPiece,:);
    CPOL(4)=CPOL(4)-KValue;
    Solution=roots(CPOL);
    SingleParameter=acos(PS.breaks(PolinomialPiece)+Solution(3))*32/pi/2;
    if(~isreal(SingleParameter))
        SingleParameter=0;
    end
    catch
        SingleParameter=8;
    end
end

% --- Executes during object creation, after setting all properties.
function p_name15_CreateFcn(hObject, eventdata, handles)
end

% --- Executes on button press in MoreDeltaScans.
function MoreDeltaScans_Callback(hObject, eventdata, handles)
BasicDeltaScans_V4
end
