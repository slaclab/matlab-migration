function varargout = ULT(varargin)
% ULT MATLAB code for ULT.fig
%      ULT, by itself, creates a new ULT or raises the existing
%      singleton*.
%
%      H = ULT returns the handle to a new ULT or the handle to
%      the existing singleton*.
%
%      ULT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT.M with the given input arguments.
%
%      ULT('Property','Value',...) creates a new ULT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT

% Last Modified by GUIDE v2.5 15-Jul-2021 10:23:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ULT_OpeningFcn, ...
    'gui_OutputFcn',  @ULT_OutputFcn, ...
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


% --- Executes just before ULT is made visible.
function ULT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT (see VARARGIN)
handles.SaveDir='/u1/lcls/matlab/ULT_GuiData';
handles.TaperSave='Stored_Taper_Configurations';
handles.ONLINE=1;
handles.MinimumRange=0.11;
handles.UndulatorLineFunctions_handler=ULT_UndulatorLine_functions();
handles.sf=Steering_Functions();
if (isnan(handles.ONLINE))
    handles.ONLINE=0;
    InitUndulatorLine;
    handles.MODEL=MODEL;
    save FAKE_Beamlinestate UL
else
    try
        load([handles.SaveDir,'/UL.mat']);
    catch
        InitUndulatorLine_Machine;
    end
    handles.ONLINE=1;
   %good 
end

% Choose default command line output for ULT
handles.output = hObject;
ColorOn=[0,1,0]; ColorWait=[1,1,0]; ColorOff=[1,0,0]; Color_CU_SXR=[230/255,184/255,179/255]; Color_CU_HXR=[202/255,214/255,230/255]; Color_FACET=[230,184,179]; Color_Unknown=[0.7,0.7,0.7];

handles.ColorIdle=get(handles.Timer_Reset,'backgroundcolor');
handles.ColorOn=ColorOn; handles.ColorOff=ColorOff; handles.ColorWait=ColorWait; handles.ColorLogBook=[0.4,0.4,1];
handles.Color_CU_HXR=Color_CU_HXR; handles.Color_CU_SXR=Color_CU_SXR; handles.Color_FACET=Color_FACET; handles.Color_Unknown=Color_Unknown;
set(handles.FullRange,'value',0);set(handles.AutoRange,'value',1),set(handles.ManualRange,'value',0); 
set(handles.FullRange,'userdata',2); %This is the actual setting !!! The dot is cosmetic.
set(handles.U2,'Userdata',[]);

   handles.PhyConsts.c=299792458;
   handles.PhyConsts.mc2_e=5.109989180000000e+05;
   handles.PhyConsts.echarge=1.602176530000000e-19;
   handles.PhyConsts.mu_0=1.256637061435917e-06;
   handles.PhyConsts.eps_0=8.854187817620391e-12;
   handles.PhyConsts.r_e=2.817940318198647e-15;
   handles.PhyConsts.Z_0=3.767303134617707e+02;
   handles.PhyConsts.h_bar=1.054571682364455e-34; %J s
   handles.PhyConsts.alpha=0.007297352554051;
   handles.PhyConsts.Avogadro=6.022141500000000e+23;
   handles.PhyConsts.k_Boltzmann=1.380650500000000e-23;
   handles.PhyConsts.Stefan_Boltzmann=5.670401243654186e-08;
   handles.PhyConsts.hplanck=4.135667516*10^-15; %eV s -> photon energy [eV] = hplanck [eV s] cluce [m/s] / lambda [m]; 

handles.HarmonicColors(1,:)=[0,0,0]; %Fundamental
handles.HarmonicColors(2,:)=[1,0,1];
handles.HarmonicColors(3,:)=[0,0,1];
handles.HarmonicColors(4,:)=[1,0,0];
handles.HarmonicColors(5,:)=[0,1,0];
handles.HarmonicColors(6,:)=[0.5,1,1];
handles.HarmonicColors(7,:)=[0.75,0.75,0.5];
handles.HarmonicColors(8,:)=[0.25,1,0];
handles.HarmonicColors(9,:)=[0.5,0,1];
handles.HarmonicColors(10,:)=[1,1,0.7];
handles.MaxKToPlot=[2.8,5.7];
handles.MinKToPlot=[0,0];
handles.HarmonicRange=1:7;
handles.SubHarmonicRange=1./(2:7);

handles.ColorError=[1,0,0];
handles.ColorOk=[0,0,0];

set(handles.LogbookButton,'userdata',0);
%set(handles.AUTO_MOVE_CHECKBOX,'userdata',0)

FirstUndulatorInfo.FirstUndulatorIn=NaN;
FirstUndulatorInfo.FirstUndulatorInK=NaN;
set(handles.FST_K,'Userdata',FirstUndulatorInfo);
set(handles.GuiStatePanel,'visible','off');
set(handles.ULPLOT,'visible','on');
Messaggi{1}=[datestr(now), ' Undulator Taper Gui Started'];
set(handles.MessageList,'string',Messaggi);
handles.UL=UL;
handles.static=static;
%handles=ReadUndulatorBeamline(handles); %Questo legge dal modello e basta
set(handles.BeamLine,'string',{handles.UL.name}); set(handles.BeamLine,'value',1); %sets the default beamline;
guidata(hObject, handles);
handles=BeamLine_Callback(hObject, eventdata, handles);
set(handles.PlotFrom,'string',num2str(UL(1).Basic.K_range(1)));set(handles.PlotTo,'string',num2str(UL(1).Basic.K_range(2))); 

% for AA=1:numel(handles.UL)
%     lcaSetMonitor(handles.UL(AA).LcaSetMonitorList.')
% end

if(~isempty(varargin))  
   if(isfield(varargin{1},'Init')) 
      if(varargin{1}.Init)      
          if(isfield(handles,'TIMER'))
              stop(handles.TIMER); 
          end
          figure1_CloseRequestFcn(handles.figure1, eventdata, handles)
          return
      end
   end
end
handles.S=GuiSizes(handles);

% set(handles.EXCLUDE,'string','[1:4]');
% handles=ExcludeSegments_Callback(handles.ExcludeSegments, [], handles);

guidata(hObject, handles);

function S=GuiSizes(handles)
ResizeList={'MainPlotAxis','SaveReferenceKValues','RESTORE_REFERENCE_BTN','pushbutton35','BeamLine','text66','REFERENCE_DATE','ULPLOT','MessageList','GuiStatePanel'};
NewPosition(1,:)=[5.5,9.929, 94.5,32.214];
NewPosition(2,:)=[2,47.571, 31.167,1.714];
NewPosition(3,:)=[35.167,47.571, 31.167,1.714];
NewPosition(4,:)=[68.667,47.571, 31.167,1.714];
NewPosition(5,:)=[81,50.571, 51,1.786];
NewPosition(6,:)=[1.333,46.143, 15.167,1.143];
NewPosition(7,:)=[18.833,46.143, 33.667,1.143];
NewPosition(8,:)=[100, 0.143,50,49.143];
NewPosition(9,:)=[0,0,100,6.214];
NewPosition(10,:)=[100, 0.143,50,49.143];

for II=1:numel(ResizeList)
    S.(ResizeList{II}).POS=get(handles.(ResizeList{II}),'position');
    S.(ResizeList{II}).NPOS=NewPosition(II,:);
    %S.(ResizeList{II}).OPOS=get(handles.(ResizeList{II}),'outterposition');
end
S.figure1.POS=get(handles.figure1,'position');
NewPosition(end+1,:)=[103.667,9,151.333,52.928];
S.figure1.NPOS=NewPosition(end,:);



% --- Outputs from this function are returned to the command line.
function varargout = ULT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

% function handles=ReadUndulatorBeamline(handles)
% if(handles.ONLINE)
%     [handles.UL,ES]=UUT_BuildUndulatorLinesScript();
%     for II=1:numel(ES)
%         AddMessage(handles.MessageList,ES{II},50);
%     end
% else
%      load FAKE_Beamlinestate
%      handles.UL=UL;
% end

function Timer_Update(TimerObject,Type_and_when,handles,MODE)
Nunc=clock;
Date_String=['AD ',datestr(Nunc,'yyyy'), datestr(Nunc, ' dddd mmmm dd  HH:MM:SS.FFF')];
DCN=get(handles.GSP_UseCellNumber,'value');
switch(MODE)
    case -1
        AddMessage(handles.MessageList,[datestr(now),' Timer function Error - Try Taper Gui State & Timer Options, Reset and Restart the timer '],50);
    case 0
        AddMessage(handles.MessageList,[datestr(now),' Timer function Stopped '],50);
    case 1
        PlotData=get(handles.MainPlotAxis,'userdata');
        ADP=get(handles.U1,'Userdata');
        ADD=get(handles.U2,'Userdata');
        ReadPhase=get(handles.ReadoutPhase,'value');
        FirstUndulatorInfo.FirstUndulatorIn=NaN;
        FirstUndulatorInfo.FirstUndulatorInK=NaN;
        FirstKToBeFound=1;
        for AA=1:length(handles.UL)
            ULReadOut{AA}=handles.UL(AA).f.ReadAllLine(handles.UL(AA),ReadPhase);
            for TT=1:length(ULReadOut{AA})

                Kvals = eval_harmonic_K(ULReadOut{AA}(TT).K,handles.HarmonicRange);
                SubKvals = eval_harmonic_K(ULReadOut{AA}(TT).K,handles.SubHarmonicRange);
                KvalsE = eval_harmonic_K(ULReadOut{AA}(TT).Kend,handles.HarmonicRange);
                SubKvalsE = eval_harmonic_K(ULReadOut{AA}(TT).Kend,handles.SubHarmonicRange);
                ULReadOut{AA}(TT).K=Kvals(Kvals<handles.UL(AA).Basic.K_range(2));
                ULReadOut{AA}(TT).KSub=SubKvals((imag(SubKvals)==0)&(imag(SubKvalsE)==0));
                
                ULReadOut{AA}(TT).Kend=KvalsE(Kvals<handles.UL(AA).Basic.K_range(2));
                ULReadOut{AA}(TT).KendSub=SubKvalsE((imag(SubKvals)==0)&(imag(SubKvalsE)==0));
                
                if(FirstKToBeFound)
                    if(PlotData.ULID==AA)
                        if(Kvals(1)>handles.UL(AA).Basic.K_range(1))
                            FirstUndulatorInfo.FirstUndulatorIn=TT;
                            FirstUndulatorInfo.FirstUndulatorInK=Kvals(1);
                            FirstKToBeFound=0;
                        end  
                    end
                end
            end
        end
        
        UndulatorLineToRead=PlotData.ULID;
        
        PetizioneADP={};
        %save TEMP ADP ADD
        if(~isempty(ADP)) % ADDITIONAL PLOTS ADP, CHECKS IF YOU NEED TO DELETE SOME
            ADPtoBeDeleted=[];
            for II=1:ADP.nummerOfPlots
                if(ishandle(ADP.Plots(II)))
                    try
                        PetizioneADP{II}=get(ADP.PlotTags(II).tags.Petizione,'userdata');
                        if(PetizioneADP{II}.UpdateNow)
                            UndulatorLineToRead(end+1)=ADP.Beamline(II);
                            %ForceRead=1;
                            CopyPetizione=PetizioneADP{II};
                            CopyPetizione.UpdateNow=0;
                            set(ADP.PlotTags(II).tags.petizione,'userdata',CopyPetizione);
                        end
                    catch %This item has been deleted !
                        ADPtoBeDeleted(end+1)=II;
                    end
                else
                    ADPtoBeDeleted(end+1)=II;
                end
            end
        end
        
        Petizione1ADD={}; % ADDITIONAL DETAIL PLOTS, CHECKS IF YOU NEED TO DELETE SOME
        if(~isempty(ADD))
            ADDtoBeDeleted=[];
            for II=1:ADD.nummerOfDetails
                if(ishandle(ADD.DetailTags(II).tags.TABULA_NEW))
                    try
                        Petizione1ADD{II}=get(ADD.DetailTags(II).tags.Petizione1,'userdata');
                        if(Petizione1ADD{II}.Init || Petizione1ADD{II}.UpdateReadout || Petizione1ADD{II}.PlotNow);
                            UndulatorLineToRead(end+1)=ADD.Beamline(II);
                            CopyPetizione=Petizione1ADD{II};
                            CopyPetizione.Init=0;CopyPetizione.UpdateReadout=0;CopyPetizione.PlotNow=0;
                            set(ADD.DetailTags(II).tags.Petizione1,'userdata',CopyPetizione);
                            %get(ADD.DetailTags(II).tags.Petizione1,'userdata')
                        end
                    catch %This item has been deleted !
                    end
                else
                ADDtoBeDeleted(end+1)=II;   
                end
            end
        end

        if(get(handles.LogbookButton,'userdata'))
           LogBook=1; 
           set(handles.LogbookButton,'userdata',0);
        else
           LogBook=0; 
        end

        %UndulatorLineToRead=unique(UndulatorLineToRead,'stable');
        
        UndulatorLineToRead=PlotData.ULID;
        
        set(handles.FST_K,'userdata',FirstUndulatorInfo);
        FST_KString=get(handles.FST_K,'string');
        if(isempty(FST_KString) || isnan(str2double(FST_KString)))
            set(handles.FST_K,'string',num2str(FirstUndulatorInfo.FirstUndulatorInK));
        end
 
        if(LogBook)
              UndulatorLines=handles.UL;
              %UndulatorLineData.PhaseShifters=Phase;
              UndulatorLineData.Undulators=ULReadOut;
              %UndulatorLineData.Chicanes=Delay;
              AdditionalUndulatorSaveData=Get_AdditionalUndulatorSaveData(handles);
              [FILEPATH, FILENAME] = WriteIntoLogBook(handles);
              save([FILEPATH,FILENAME],'UndulatorLines','UndulatorLineData','AdditionalUndulatorSaveData');
        end
        %ULReadOut{ULID}
        PlotData=get(handles.MainPlotAxis,'userdata');
        if(~isempty(PlotData.toBeDeleted))
            try %This SHOULD BE REMOVED!!
                delete(PlotData.toBeDeleted)
            end
            PlotData.toBeDeleted=[];
        end
        MAXK=0.5; MINK=PlotData.MaxK;
        for KK=1:length(handles.UL(PlotData.ULID).slot)
            if(~isempty(ULReadOut{PlotData.ULID}(KK).K))
                if(~isnan((ULReadOut{PlotData.ULID}(KK).K(1))))
                    Kini=ULReadOut{PlotData.ULID}(KK).K;
                    Kend=ULReadOut{PlotData.ULID}(KK).Kend;
                else
                   Kini=[];Kend=[]; 
                end
                if(~isempty(Kini))
                   MAXK=max(MAXK,max(Kini(1),Kend(1)));
                   if(Kini(1)>0.5) %otherwise we consider out !?
                        MINK=min(MINK,min(Kini(1),Kend(1)));
                   end
                   PlotHarmonics=get(handles.MCP_SH,'value');
                   for TT=1:min(length(Kini),1+9*PlotHarmonics)
                        if(Kini(TT)<=PlotData.MaxK)
                            PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,[PlotData.z_in_end(KK,1),PlotData.z_in_end(KK,2)],[Kini(TT),Kend(TT)],'color',handles.HarmonicColors(TT,:));
                            if(TT==1)
                                if(DCN)
                                    if(handles.UL(PlotData.ULID).slot(KK).USEG.present)
                                        PlotData.toBeDeleted(end+1)=text((PlotData.z_in_end(KK,1)+PlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), handles.UL(PlotData.ULID).slot(KK).USEG.Cell_String, 'FontSize', 10, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', handles.MainPlotAxis);
                                    end
                                else
                                    PlotData.toBeDeleted(end+1)=text((PlotData.z_in_end(KK,1)+PlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), num2str(KK), 'FontSize', 10, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', handles.MainPlotAxis);
                                end
                            else
                                if(DCN)
                                    if(handles.UL(PlotData.ULID).slot(KK).USEG.present)
                                        PlotData.toBeDeleted(end+1)=text((PlotData.z_in_end(KK,1)+PlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), [handles.UL(PlotData.ULID).slot(KK).USEG.Cell_String,'h',num2str(TT)], 'FontSize', 6, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', handles.MainPlotAxis);
                                    end
                                else
                                    PlotData.toBeDeleted(end+1)=text((PlotData.z_in_end(KK,1)+PlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), [num2str(KK),'h',num2str(TT)], 'FontSize', 6, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', handles.MainPlotAxis);
                                end
                            end
                        end
                   end
                end
            end
        end

        %disp('Plotted K values')
       % xlim(handles.MainPlotAxis,[PlotData.z_in_end(1,1),PlotData.z_in_end(end,2)])
        
        if(get(handles.DisplayRedLine,'value'))
 
            Input.USE_SPONT_RAD_BOX=get(handles.USE_SPONT_RAD_BOX,'value');
            Input.USE_WAKEFIELDS_BOX=get(handles.USE_WAKEFIELDS_BOX,'value');
            Input.ADD_GAIN_TAPER_BOX=get(handles.ADD_GAIN_TAPER_BOX,'value');
            Input.ADD_POST_TAPER_BOX=get(handles.ADD_POST_TAPER_BOX,'value');
            Input.USE_CONT_TAPER=get(handles.USE_CONT_TAPER_BOX,'value');
            Input.USE_ALL_SEGMENTS=get(handles.USE_ALL_SEGMENTS,'value');
            %AUTO_MOVE_CHECKBOX_VALUE=get(handles.AUTO_MOVE_CHECKBOX,'value');
            Input.GAIN_TAPER_START_SEGMENT=str2num(get(handles.GAIN_TAPER_START_SEGMENT,'string')); 
            if(DCN)
                Input.GAIN_TAPER_START_SEGMENT=find(handles.UL(PlotData.ULID).slotcell==Input.GAIN_TAPER_START_SEGMENT);
            end
            [Result(1),ErrorString]=CheckRange(Input.GAIN_TAPER_START_SEGMENT, 1, 1, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Gain Taper Start Segment', Date_String);
            if(Result(1)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.GAIN_TAPER_END_SEGMENT=str2num(get(handles.GAIN_TAPER_END_SEGMENT,'string'));
            if(DCN)
                Input.GAIN_TAPER_END_SEGMENT=find(handles.UL(PlotData.ULID).slotcell==Input.GAIN_TAPER_END_SEGMENT);
            end
            [Result(2),ErrorString]=CheckRange(Input.GAIN_TAPER_END_SEGMENT, 1, Input.GAIN_TAPER_START_SEGMENT, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Gain Taper End Segment', Date_String);
            if(Result(2)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.GAIN_TAPER_AMPLITUDE=str2num(get(handles.GAIN_TAPER_AMPLITUDE,'string'));
            [Result(3),ErrorString]=CheckRange(Input.GAIN_TAPER_AMPLITUDE, 1, -500, 500, 'real', 0, 0, 'Gain Taper Amplitude', Date_String);
            if(Result(3)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.POST_TAPER_START_SEGMENT=str2num(get(handles.POST_TAPER_START_SEGMENT,'string'));
            if(DCN)
                Input.POST_TAPER_START_SEGMENT=find(handles.UL(PlotData.ULID).slotcell==Input.POST_TAPER_START_SEGMENT);
            end
            [Result(4),ErrorString]=CheckRange(Input.POST_TAPER_START_SEGMENT, 1, 1, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Post Saturation Taper Start Segment', Date_String);
            if(Result(4)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.POST_TAPER_END_SEGMENT=str2num(get(handles.POST_TAPER_END_SEGMENT,'string'));
            if(DCN)
                Input.POST_TAPER_END_SEGMENT=find(handles.UL(PlotData.ULID).slotcell==Input.POST_TAPER_END_SEGMENT);
            end
            [Result(5),ErrorString]=CheckRange(Input.POST_TAPER_START_SEGMENT, 1, Input.POST_TAPER_START_SEGMENT, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Post Saturation Taper End Segment', Date_String);
            if(Result(5)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.POST_TAPER_AMPLITUDE=str2num(get(handles.POST_TAPER_AMPLITUDE,'string'));
            [Result(6),ErrorString]=CheckRange(Input.POST_TAPER_AMPLITUDE, 1, -500, 500, 'real', 0, 0, 'Post Saturation Taper Amplitude', Date_String);
            if(Result(6)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Result(7)=1;
%            Input.POST_TAPER_LG=str2num(get(handles.POST_TAPER_LG,'string'));
%            [Result(7),ErrorString]=CheckRange(Input.POST_TAPER_LG, 1, 0.005, 500, 'real', 0, 0, 'Electrons Folding length', Date_String);
%            if(Result(7)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.POST_TAPER_MENU=get(handles.POST_TAPER_MENU,'string');
            Input.POST_TAPER_MENU_VALUE=get(handles.POST_TAPER_MENU,'value');
            Input.WakefieldModel=get(handles.WakefieldModel,'string');
            Input.WakefieldModel_VALUE=get(handles.WakefieldModel,'value');
            Input.First_K=str2num(get(handles.FST_K,'string'));
            [Result(8),ErrorString]=CheckRange(Input.First_K, 1, handles.UL(PlotData.ULID).Basic.K_range(1), handles.UL(PlotData.ULID).Basic.K_range(2), 'real', 0, 0, 'First Element K value', Date_String);
            if(Result(8)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.MODEL_BEAM_ENERGY=str2num(get(handles.MODEL_BEAM_ENERGY,'string'));
            [Result(9),ErrorString]=CheckRange(Input.MODEL_BEAM_ENERGY, 1, 0.1, 100, 'real', 0, 0, 'Electron Bunch Energy', Date_String);
            if(Result(9)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.MODEL_PEAK_CURRENT=str2num(get(handles.MODEL_PEAK_CURRENT,'string'));
            [Result(10),ErrorString]=CheckRange(Input.MODEL_PEAK_CURRENT, 1, 200, 50000, 'real', 0, 0, 'Electron Bunch Peak Current', Date_String);
            if(Result(10)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            Input.MODEL_BUNCH_CHARGE=str2num(get(handles.MODEL_BUNCH_CHARGE,'string'));
            [Result(11),ErrorString]=CheckRange(Input.MODEL_BUNCH_CHARGE, 1, 0.2, 2000, 'real', 0, 0, 'Electron Bunch charge', Date_String);
            if(Result(11)~=1), AddMessage(handles.MessageList,ErrorString,50); end
            if(~all(Result))
                %Wrong message !!
                AddMessage(handles.MessageList,[datestr(now),' Please clear errors before plotting the red line. Error raised: [', num2str(~Result),']'],50);
            else
                Input.ULReadOut=ULReadOut{PlotData.ULID};
                Input.FirstUndulatorInfo=FirstUndulatorInfo;
                RedLineRequirements = handles.UL(PlotData.ULID).Basic.f_Red_Line(handles.UL(PlotData.ULID), Input, handles.PhyConsts) ;
                RedLineRequirements.OrigInput=Input;
                RedLineRequirements.OrigInput.DCN=DCN;
                RedLineRequirements.OrigInput.ULID=PlotData.ULID;
                set(handles.pushbutton28,'userdata',RedLineRequirements);
                if(~RedLineRequirements.Failed)
                    AllKs=RedLineRequirements.Ktable(:);
                    Allz=PlotData.z_in_end(:);
                    [zAscend,SortingOrder]=sort(Allz(~isnan(AllKs)),'ascend');
                    Ks=AllKs(~isnan(AllKs));
                    PlotData.toBeDeleted(end+1) = plot(handles.MainPlotAxis,zAscend,Ks(SortingOrder),'-r', 'LineWidth', 3);
                    %lcaPutSmart(handles.UL(PlotData.ULID).Basic.RedLinePVs,[Input.USE_SPONT_RAD_BOX,Input.USE_WAKEFIELDS_BOX,Input.ADD_GAIN_TAPER_BOX,Input.ADD_POST_TAPER_BOX,Input.USE_CONT_TAPER,Input.USE_ALL_SEGMENTS,Input.GAIN_TAPER_START_SEGMENT,Input.GAIN_TAPER_END_SEGMENT,Input.GAIN_TAPER_AMPLITUDE,Input.POST_TAPER_START_SEGMENT,Input.POST_TAPER_END_SEGMENT,Input.POST_TAPER_AMPLITUDE,length(Input.POST_TAPER_MENU),Input.POST_TAPER_MENU_VALUE,Input.WakefieldModel_VALUE,Input.First_K,Input.MODEL_BEAM_ENERGY,Input.MODEL_PEAK_CURRENT,Input.MODEL_BUNCH_CHARGE,Input.FirstUndulatorInfo.FirstUndulatorIn,Input.FirstUndulatorInfo.FirstUndulatorInK]');
                else
                    AddMessage(handles.MessageList,[datestr(now),'Evaluation of Red Line Failed, No segment inserted'],50);
                end
%                 for II=1:handles.UL(PlotData.ULID).slotlength
%                     if(handles.UL(PlotData.ULID).slot(II).undulator.isInstalled && ~ handles.UL(PlotData.ULID).slot(II).undulator.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
%                         %Plots the "red line"
%                         PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,[PlotData.z_in_end(II,1),PlotData.z_in_end(II,2)],[RedLineRequirements.EnergyLoss(II).Kt_ini,RedLineRequirements.EnergyLoss(II).Kt_end],'-r', 'LineWidth', 3);
%                     end
%                 end
            end
            
        end
        
        set_plotKMinMax(handles.MainPlotAxis,PlotData,[MINK,MAXK],handles.FullRange,handles.PlotFrom,handles.PlotTo)
        Z=PlotData.z_in_end(:);
        Z(Z==0)=NaN;
        xlim(handles.MainPlotAxis,[min(Z)-1,max(Z)+1]);
        cla(handles.PSAxis); xlim(handles.PSAxis,[min(Z)-1,max(Z)+1]); ylim(handles.PSAxis,[0,1]); URO=ULReadOut{PlotData.ULID}; UpdatePhaseAct=get(handles.ReadoutPhase,'value');
        for KK=1:length(handles.UL(PlotData.ULID).slot)
            if(handles.UL(PlotData.ULID).slot(KK).PHAS.present)
                text(PlotData.z_in_end(KK,2),-0.1,num2str(URO(KK).PhaseDes,'%2.1f'),'fontsize',8,'Horizontalalignment','center','Verticalalignment','bottom','parent',handles.PSAxis);
                if(UpdatePhaseAct)
                    text(PlotData.z_in_end(KK,2),1.15,num2str(URO(KK).Phase,'%2.1f'),'fontsize',8,'Horizontalalignment','center','Verticalalignment','top','parent',handles.PSAxis);
                end
            end
            if(handles.UL(PlotData.ULID).slot(KK).BEND.present)
                text(mean(PlotData.z_in_end(KK,:)),-0.75,num2str(URO(KK).Delay,'%5.1f'),'fontsize',8,'fontweight','bold','Horizontalalignment','center','Verticalalignment','bottom','parent',handles.PSAxis);
                text(mean(PlotData.z_in_end(KK,:)),-1.2,'fs','fontsize',8,'Horizontalalignment','center','fontweight','bold','Verticalalignment','bottom','parent',handles.PSAxis);
            end
        end
        text(PlotData.z_in_end(1,1),-0.1,'DES','fontsize',8,'Horizontalalignment','center','Verticalalignment','bottom','parent',handles.PSAxis);
        if(UpdatePhaseAct)
            text(PlotData.z_in_end(1,1),1.15,'ACT','fontsize',8,'Horizontalalignment','center','Verticalalignment','top','parent',handles.PSAxis);
        end
        set(handles.MainPlotAxis,'userdata',PlotData);
        set(handles.(['UL',num2str(UndulatorLineToRead)]),'userdata',ULReadOut{PlotData.ULID});
        
        for II=1:numel(PetizioneADP)
            if(ishandle(ADP.Plots(II)))
                MyPlotData=get(ADP.PlotTags(II).tags.MainPlotAxis,'userdata');
                if(~isempty(MyPlotData.toBeDeleted))
                    delete(MyPlotData.toBeDeleted)
                    MyPlotData.toBeDeleted=[];
                end
                
                MAXK=0.5; MINK=MyPlotData.MaxK;
                for KK=1:length(handles.UL(MyPlotData.ULID).slot)
                    if(~isempty(ULReadOut{MyPlotData.ULID}(KK).K))
                        if(~isnan((ULReadOut{MyPlotData.ULID}(KK).K(1))))
                            Kini=ULReadOut{MyPlotData.ULID}(KK).K;
                            Kend=ULReadOut{MyPlotData.ULID}(KK).Kend;
                        else
                            Kini=[];Kend=[];
                        end
                        if(~isempty(Kini))
                            MAXK=max(MAXK,max(Kini(1),Kend(1)));
                            if(Kini(1)>0.5) %otherwise we consider out !?
                                MINK=min(MINK,min(Kini(1),Kend(1)));
                            end
                            for TT=1:min(length(Kini),10)
                                if(Kini(TT)<=MyPlotData.MaxK)
                                    MyPlotData.toBeDeleted(end+1)=plot(ADP.PlotTags(II).tags.MainPlotAxis,[MyPlotData.z_in_end(KK,1),MyPlotData.z_in_end(KK,2)],[Kini(TT),Kend(TT)],'color',handles.HarmonicColors(TT,:));
                                    if(TT==1)
                                        if(DCN)
                                            if(handles.UL(MyPlotData.ULID).slot(KK).USEG.present)
                                                MyPlotData.toBeDeleted(end+1)=text((MyPlotData.z_in_end(KK,1)+MyPlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), handles.UL(MyPlotData.ULID).slot(KK).USEG.Cell_String, 'FontSize', 10, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', ADP.PlotTags(II).tags.MainPlotAxis);
                                            end
                                        else
                                            MyPlotData.toBeDeleted(end+1)=text((MyPlotData.z_in_end(KK,1)+MyPlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), num2str(KK), 'FontSize', 10, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', ADP.PlotTags(II).tags.MainPlotAxis);
                                        end
                                    else
                                        if(DCN)
                                            if(handles.UL(MyPlotData.ULID).slot(KK).USEG.present)
                                                MyPlotData.toBeDeleted(end+1)=text((MyPlotData.z_in_end(KK,1)+MyPlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), [handles.UL(MyPlotData.ULID).slot(KK).USEG.Cell_String,'h',num2str(TT)], 'FontSize', 6, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', ADP.PlotTags(II).tags.MainPlotAxis);
                                            end
                                        else
                                            MyPlotData.toBeDeleted(end+1)=text((MyPlotData.z_in_end(KK,1)+MyPlotData.z_in_end(KK,2))/2, max(Kini(TT),Kend(TT)), [num2str(KK),'h',num2str(TT)], 'FontSize', 6, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', ADP.PlotTags(II).tags.MainPlotAxis);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                set_plotKMinMax(ADP.PlotTags(II).tags.MainPlotAxis,MyPlotData,[MINK,MAXK],ADP.PlotTags(II).tags.FullRange,ADP.PlotTags(II).tags.PlotFrom,ADP.PlotTags(II).tags.PlotTo)
                set(ADP.PlotTags(II).tags.MainPlotAxis,'userdata',MyPlotData);      
                Z=MyPlotData.z_in_end(:); Z(Z==0)=NaN;
                xlim(ADP.PlotTags(II).tags.MainPlotAxis,[min(Z)-1,max(Z)+1]);
 
            else %add plot to remove cue
                %disp(['To Be deleted side plot ',num2str(ADP.Plots(II))]);
                ADPtoBeDeleted(end+1)=II;
            end
        end
        set(handles.datetext,'string',Date_String);
        ADPtoBeDeleted=[];
        if(~isempty(ADP))    
            for II=1:ADP.nummerOfPlots
                if(~ishandle(ADP.Plots(II)))
                    ADPtoBeDeleted(end+1)=II;
                end
            end
        end
        
        if(~isempty(ADPtoBeDeleted))
            for II=length(ADPtoBeDeleted):-1:1
                try
                    close(ADP.Plots(ADPtoBeDeleted(II)))
                end
                ADP.nummerOfPlots=ADP.nummerOfPlots-1;
                ADP.Plots(ADPtoBeDeleted(II))=[];
                ADP.PlotTags(ADPtoBeDeleted(II))=[];
                ADP.Beamline(ADPtoBeDeleted(II))=[];
                ADP.PlotsString(ADPtoBeDeleted(II))=[];
                if(ADP.nummerOfPlots<1)
                    ADP=[];
                end
            end
            set(handles.U1,'userdata',ADP)
            if(~isempty(ADP))
                set(handles.LivePlotList,'string',ADP.PlotsString)
            else
                set(handles.LivePlotList,'string',ADP)
            end
        end
        
        ADDtoBeDeleted=[];
        if(~isempty(ADD))     
            for II=1:ADD.nummerOfDetails
                if(~ishandle(ADD.DetailTags(II).tags.TABULA_NEW))
                    ADDtoBeDeleted(end+1)=II;
                end
            end
        end    
        if(~isempty(ADDtoBeDeleted))
            for II=length(ADDtoBeDeleted):-1:1
                try
                    close(ADD.Details(ADDtoBeDeleted(II)))
                end
                ADD.nummerOfDetails=ADD.nummerOfDetails-1;
                ADD.Details(ADDtoBeDeleted(II))=[];
                ADD.DetailTags(ADDtoBeDeleted(II))=[];
                ADD.Beamline(ADDtoBeDeleted(II))=[];
                ADD.DetailsString(ADDtoBeDeleted(II))=[];
                if(ADD.nummerOfDetails<1)
                    ADD=[];
                end
            end
            set(handles.U2,'userdata',ADD)
            if(~isempty(ADD))
                set(handles.LiveTCList,'string',ADD.DetailsString)
            else
                set(handles.LiveTCList,'string',ADD)
            end
        end

    case 2
        AddMessage(handles.MessageList,[datestr(now),' Timer function Started'],50);
        Timer_Update(0,0,handles,1)
end

function [Result,ErrorString]=CheckRange(Value, NumEL, RangeLow,RangeHigh, tipo, AllowNaN, AllowInf, errorbase, Date_String)
Result=1;ErrorString='';
if(numel(Value)~=NumEL)
    ErrorString = [Date_String,' ',errorbase, ' has wrong number of elements ', num2str(numel(Value)), ' != ', num2str(NumEL)];
    Result=0; return
end
if(~AllowNaN)
    if(any(isnan(Value)))
       ErrorString = [Date_String,' ',errorbase, ' has at least one NaN element'];
       Result=0; return
    end
end
if(~AllowInf)
    if(any(isinf(Value)))
       ErrorString = [Date_String,' ',errorbase, ' has at least one inf element'];
       Result=0; return
    end
end
for TT=1:NumEL
    if(Value(TT)<RangeLow(TT))
        Result=0;
        ErrorString = [Date_String,' ',errorbase, ' Element number ',num2str(TT),' is too small (<',num2str(RangeLow(TT)),')'];
        return
    end
    if(Value(TT)>RangeHigh(TT))
        Result=0;
        ErrorString = [Date_String,' ',errorbase, ' Element number ',num2str(TT),' is too large (>',num2str(RangeHigh(TT)),')'];
        return
    end
end
switch(tipo)
    case('integer')
        if(any(~(Value==fix(Value))))
            ErrorString = [Date_String,' ',errorbase, ' has not integer numbers'];
            Result=0; return
        end
    case('real')
        if(any(~isreal(Value)))
            ErrorString = [Date_String,' ',errorbase, ' has complex numbers'];
            Result=0; return
        end
    case('positive')
        if(any(Value<0))
            ErrorString = [Date_String,' ',errorbase, ' has negative numbers'];
            Result=0; return
        end
    otherwise
end

function AdditionalUndulatorSaveData=Get_AdditionalUndulatorSaveData(handles)
AdditionalUndulatorSaveData=[];


function [FILEPATH, FILENAME] = WriteIntoLogBook(handles)
TEMPO=clock;
ANNO=num2str(TEMPO(1),'%.4d');
MESE=num2str(TEMPO(2),'%.2d');
GIORNO=num2str(TEMPO(3),'%.2d');
ORE=num2str(TEMPO(4),'%.2d');
MINUTI=num2str(TEMPO(5),'%.2d');
SECONDI=num2str(floor(TEMPO(6)),'%.2d');
MILLESIMI=num2str(round((TEMPO(6)-floor(TEMPO(6)))*1000),'%.3d');
STRINGATEMPO=[ANNO,'-',MESE,'-',GIORNO,'--',ORE,'-',MINUTI,'-',SECONDI,'-',MILLESIMI];
TITOLO=['UndulatorTaper UUT - ',STRINGATEMPO];
FILENAME=['UndulatorTaper_UUT_',STRINGATEMPO];
FILEPATH=['/u1/lcls/matlab/data/',ANNO,'/',ANNO,'-',MESE,'/',ANNO,'-',MESE,'-',GIORNO,'/'];

if(~isdir(FILEPATH(1:(end-1))))
    mkdir(FILEPATH(1:(end-1)));
end

NuovaFigura=figure;
copyobj(handles.MainPlotAxis,NuovaFigura);
PP=get(NuovaFigura,'position');
set(NuovaFigura,'position',PP+[0,0,550,400]);
ASSI=get(NuovaFigura,'children');
xlabel(ASSI,'X [m]');
ylabel(ASSI,'K');
title(ASSI,TITOLO);

try
    util_printLog(NuovaFigura,'title',TITOLO);
catch
    AddMessage(handles.MessageList,[datestr(now),' Failed to write image into logbook; data should still be saved properly'],50);
end

function AddMessage(List,String,MaxMessages)
Messaggi=get(List,'string');
NumeroMessaggi=numel(Messaggi);
if(NumeroMessaggi>=MaxMessages)
    Messaggi(1)=[];
    Messaggi{MaxMessages}=String;
    set(List,'value',NumeroMessaggi);
    set(List,'string',Messaggi);
else
    Messaggi{NumeroMessaggi+1}=String;
    set(List,'string',Messaggi);
    set(List,'value',NumeroMessaggi+1);
end

% function PlotK(handles)
% Date_String=datestr(now);
% set(handles.datetext,'string',Date_String);
% ADP=get(handles.U1,'Userdata'); toBeDeleted=[];
% %disp('Updating main plot');
% PlotData=get(handles.MainPlotAxis,'userdata');
% %Plot.toBeDeleted=[]; Plot.z_in_end=[]; Plot.full_K_range=[]; Plot.full_z_range=[];
% if(~isempty(PlotData.toBeDeleted))
%     %disp(['** length = ',num2str(length(PlotData.toBeDeleted))])
%     for II=length(PlotData.toBeDeleted):-1:1
%         delete(PlotData.toBeDeleted(II));
%         PlotData.toBeDeleted(II)=[];
%     end
% end
% 
% FirstUndulatorInfo.FirstUndulatorIn=NaN;
% FirstUndulatorInfo.FirstUndulatorInK=NaN;
% 
% for II=1:length(handles.UL(PlotData.ULID).slot)
%     if(handles.UL(PlotData.ULID).slot(II).USEG.isInstalled && ~ handles.UL(PlotData.ULID).slot(II).USEG.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
%         K{II}=handles.UL(PlotData.ULID).slot(II).undulator.properties.f_getK(handles.UL(PlotData.ULID).slot(II).undulator,[handles.UL(PlotData.ULID).Reference_lambda_u,PlotData.MaxK]);
%         if(isnan(FirstUndulatorInfo.FirstUndulatorIn))
%             if(~isempty(K{II}(1)))
%                 if(K{II}(1)~=0)
%                     FirstUndulatorInfo.FirstUndulatorIn=II;
%                     FirstUndulatorInfo.FirstUndulatorInK=K{II}(1);
%                 end
%             end
%             set(handles.FST_K,'userdata',FirstUndulatorInfo);
%         end
%         for TT=1:min(length(K{II}),10)
%             PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,[PlotData.z_in_end(II,1),PlotData.z_in_end(II,2)],[K{II}(TT),K{II}(TT)],'color',handles.HarmonicColors(TT,:));
%             PlotData.toBeDeleted(end+1)=text((PlotData.z_in_end(II,1)+PlotData.z_in_end(II,2))/2, K{II}(TT), num2str(II), 'FontSize', 10, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', handles.MainPlotAxis);
%         end
%     end
% end
% 
% if(get(handles.DisplayRedLine,'value'))
%      if(get(handles.ListenMode,'value')) %Updates soft PV controllable parameters.
%          GTAMP=lcaGetSmart(handles.UL(PlotData.ULID).Basic.GainTaperPV);
%          PSATLOCATION=lcaGetSmart(handles.UL(PlotData.ULID).Basic.PostTaperPV);
%          FIRSTK=lcaGetSmart(handles.UL(PlotData.ULID).Basic.FirstKPV);
%          DRAWNOW=0;
%          
%          [CheckResult,ErrorString]=CheckRange(GTAMP, 1, -500, 500, 'real', 0, 0, 'Soft PV Input Gain Taper Amplitude', Date_String);
%          if(CheckResult~=1), AddMessage(handles.MessageList,ErrorString,50); else
%             set(handles.GAIN_TAPER_AMPLITUDE,'string',num2str(GTAMP)); DRAWNOW=1;
%          end
%          
%          [CheckResult,ErrorString]=CheckRange(PSATLOCATION, 1, 1, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Soft PV input Post Saturation Start Segment', Date_String);
%          if(CheckResult~=1), AddMessage(handles.MessageList,ErrorString,50); else
%             set(handles.POST_TAPER_START_SEGMENT,'string',num2str(PSATLOCATION)); DRAWNOW=1;
%          end
%          
%          [CheckResult,ErrorString]=CheckRange(FIRSTK, 1, 1, 5, 'real', 0, 0, 'Soft PV input First K', Date_String);
%          if(CheckResult~=1), AddMessage(handles.MessageList,ErrorString,50); else
%             set(handles.FST_K,'string',num2str(FIRSTK)); DRAWNOW=1;
%          end
%          
%          if(DRAWNOW),drawnow;end
%          
%      end
%      
%     Input.USE_SPONT_RAD_BOX=get(handles.USE_SPONT_RAD_BOX,'value');
%     Input.USE_WAKEFIELDS_BOX=get(handles.USE_WAKEFIELDS_BOX,'value');
%     Input.ADD_GAIN_TAPER_BOX=get(handles.ADD_GAIN_TAPER_BOX,'value');
%     Input.ADD_POST_TAPER_BOX=get(handles.ADD_POST_TAPER_BOX,'value');
%     AUTO_MOVE_CHECKBOX_VALUE=get(handles.AUTO_MOVE_CHECKBOX,'value');
%     Input.GAIN_TAPER_START_SEGMENT=str2num(get(handles.GAIN_TAPER_START_SEGMENT,'string'));
%     [Result(1),ErrorString]=CheckRange(Input.GAIN_TAPER_START_SEGMENT, 1, 1, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Gain Taper Start Segment', Date_String);
%     if(Result(1)~=1), AddMessage(handles.MessageList,ErrorString,50); end
%     
%     Input.GAIN_TAPER_END_SEGMENT=str2num(get(handles.GAIN_TAPER_END_SEGMENT,'string'));
%     [Result(2),ErrorString]=CheckRange(Input.GAIN_TAPER_END_SEGMENT, 1, Input.GAIN_TAPER_START_SEGMENT, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Gain Taper End Segment', Date_String);
%     if(Result(2)~=1), AddMessage(handles.MessageList,ErrorString,50); end
%     
%     Input.GAIN_TAPER_AMPLITUDE=str2num(get(handles.GAIN_TAPER_AMPLITUDE,'string'));
%     [Result(3),ErrorString]=CheckRange(Input.GAIN_TAPER_AMPLITUDE, 1, -500, 500, 'real', 0, 0, 'Gain Taper Amplitude', Date_String);
%     if(Result(3)~=1), AddMessage(handles.MessageList,ErrorString,50); end
%     
%     Input.POST_TAPER_START_SEGMENT=str2num(get(handles.POST_TAPER_START_SEGMENT,'string'));
%     [Result(4),ErrorString]=CheckRange(Input.POST_TAPER_START_SEGMENT, 1, 1, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Post Saturation Taper Start Segment', Date_String);
%     if(Result(4)~=1), AddMessage(handles.MessageList,ErrorString,50); end
%     
%     Input.POST_TAPER_END_SEGMENT=str2num(get(handles.POST_TAPER_END_SEGMENT,'string'));
%     [Result(5),ErrorString]=CheckRange(Input.POST_TAPER_START_SEGMENT, 1, Input.POST_TAPER_START_SEGMENT, numel(handles.UL(PlotData.ULID).slot), 'integer', 0, 0, 'Post Saturation Taper End Segment', Date_String);
%     if(Result(5)~=1), AddMessage(handles.MessageList,ErrorString,50); end
% 
%     Input.POST_TAPER_AMPLITUDE=str2num(get(handles.POST_TAPER_AMPLITUDE,'string'));
%     [Result(6),ErrorString]=CheckRange(Input.POST_TAPER_AMPLITUDE, 1, -500, 500, 'real', 0, 0, 'Post Saturation Taper Amplitude', Date_String);
%     if(Result(6)~=1), AddMessage(handles.MessageList,ErrorString,50); end
%     
%     Input.POST_TAPER_LG=str2num(get(handles.POST_TAPER_LG,'string'));
%     [Result(7),ErrorString]=CheckRange(Input.POST_TAPER_LG, 1, 0.005, 500, 'real', 0, 0, 'Electrons Folding length', Date_String);
%     if(Result(7)~=1), AddMessage(handles.MessageList,ErrorString,50); end
% 
%     Input.POST_TAPER_MENU=get(handles.POST_TAPER_MENU,'string');
%     Input.POST_TAPER_MENU_VALUE=get(handles.POST_TAPER_MENU,'value');
%     Input.WakefieldModel=get(handles.WakefieldModel,'string');
%     Input.WakefieldModel_VALUE=get(handles.WakefieldModel,'value');
% 
%     Input.First_K=str2num(get(handles.FST_K,'string'));
%     [Result(8),ErrorString]=CheckRange(Input.First_K, 1, 1, 5, 'real', 0, 0, 'First Element K value', Date_String);
%     if(Result(8)~=1), AddMessage(handles.MessageList,ErrorString,50); end
% 
%     Input.MODEL_BEAM_ENERGY=str2num(get(handles.MODEL_BEAM_ENERGY,'string'));
%     [Result(9),ErrorString]=CheckRange(Input.MODEL_BEAM_ENERGY, 1, 0.1, 100, 'real', 0, 0, 'Electron Bunch Energy', Date_String);
%     if(Result(9)~=1), AddMessage(handles.MessageList,ErrorString,50); end
% 
%     Input.MODEL_PEAK_CURRENT=str2num(get(handles.MODEL_PEAK_CURRENT,'string'));
%     [Result(10),ErrorString]=CheckRange(Input.MODEL_PEAK_CURRENT, 1, 200, 50000, 'real', 0, 0, 'Electron Bunch Peak Current', Date_String);
%     if(Result(10)~=1), AddMessage(handles.MessageList,ErrorString,50); end
% 
%     Input.MODEL_BUNCH_CHARGE=str2num(get(handles.MODEL_BUNCH_CHARGE,'string'));
%     [Result(11),ErrorString]=CheckRange(Input.MODEL_BUNCH_CHARGE, 1, 0.2, 2000, 'real', 0, 0, 'Electron Bunch charge', Date_String);
%     if(Result(11)~=1), AddMessage(handles.MessageList,ErrorString,50); end
%      
%     if(~all(Result))
%          AddMessage(handles.MessageList,[datestr(now),' Clear errors before to plot read line ', num2str(~Result)],50);
%     else
%          Input.K=K;
%          Input.FirstUndulatorInfo=FirstUndulatorInfo;
%          RedLineRequirements = handles.UL(PlotData.ULID).Basic.f_MoveToRedLine(handles.UL(PlotData.ULID), Input, handles.PhyConsts) ;
%          
%          for II=1:length(handles.UL(PlotData.ULID).slot)
%              if(handles.UL(PlotData.ULID).slot(II).undulator.isInstalled && ~ handles.UL(PlotData.ULID).slot(II).undulator.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
%                  %Plots the "red line"
%                  PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,[PlotData.z_in_end(II,1),PlotData.z_in_end(II,2)],[RedLineRequirements.EnergyLoss(II).Kt_ini,RedLineRequirements.EnergyLoss(II).Kt_end],'-r', 'LineWidth', 3);
%                  
%                  if(AUTO_MOVE_CHECKBOX_VALUE) % Move the segment to the red line (only if K is different (?))
%                         CurrentAutoMoveValue=lcaGetSmart(handles.UL(PlotData.ULID).Basic.UndulatorAutoMovePV); 
%                         MyAutoMoveValue=get(handles.AUTO_MOVE_CHECKBOX,'userdata');
%                         if(MyAutoMoveValue == CurrentAutoMoveValue) 
%                             NewK=mean([RedLineRequirements.EnergyLoss(II).Kt_ini,RedLineRequirements.EnergyLoss(II).Kt_end]);
%                             if((NewK>0) && abs(NewK-Input.K{1}(1))>5*10^-5) % if it is far enough, then move it.
%                                 handles.UL(PlotData.ULID).slot(II).undulator.properties.f_setK(handles.UL(PlotData.ULID).slot(II).undulator , NewK, 1);
%                             end
%                         else
%                             set(handles.AUTO_MOVE_CHECKBOX,'foregroundcolor',handles.ColorError); AUTO_MOVE_CHECKBOX_VALUE=0;
%                             AddMessage(handles.MessageList,[datestr(now),' Control Stolen for "Move to Red Line" (uncheck/check to steal back)'],50);
%                         end
%                  end
%              end
%          end       
%     end
%      
%  end % END DISPLAY RED LINE
% 
% %Plot destination (or destinations?)
% ADD=get(handles.U2,'Userdata');
% if(~isempty(ADD))
%     for LL=1:ADD.nummerOfDetails
%         if(PlotData.ULID==ADD.Beamline(LL))
%             if(ishandle(ADD.DetailTags(LL).tags.TABULA_NEW))
%                 TABULA_NEW=get(ADD.DetailTags(LL).tags.TABULA_NEW,'data');
%                 S=get(ADD.DetailTags(LL).tags.S,'data');
%                 STYLE1=get(ADD.DetailTags(LL).tags.Style1,'string');
%                 STYLE2=get(ADD.DetailTags(LL).tags.Style2,'string');
%                 for II=1:length(handles.UL(PlotData.ULID).slot)
%                     if(handles.UL(PlotData.ULID).slot(II).undulator.isInstalled && ~ handles.UL(PlotData.ULID).slot(II).undulator.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
%                         if(S(II))
%                             if(~isempty(TABULA_NEW(II,2)))
%                                 PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,(PlotData.z_in_end(II,1)+PlotData.z_in_end(II,2))/2,TABULA_NEW{II,2},STYLE1,'markersize',10);
%                             end
%                         else
%                             if(~isempty(TABULA_NEW(II,2)))
%                                 PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,(PlotData.z_in_end(II,1)+PlotData.z_in_end(II,2))/2,TABULA_NEW{II,2},STYLE2);
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
% 
% %set_plotKMinMax(Ax,PlotData,K,Obj)
% set_plotKMinMax(handles.MainPlotAxis,PlotData,K,handles.FullRange,handles.PlotFrom,handles.PlotTo)
% set(handles.MainPlotAxis,'userdata',PlotData);
% % UP TO HERE THE MAIN PLOT IS UPDATED...
% 
% if(~isempty(ADP))
%     for II=1:ADP.nummerOfPlots
%         if(ishandle(ADP.Plots(II)))
%             disp(['Updating side plot ',num2str(ADP.Plots(II))]);
%             %savetempuut
%             MyPlotData=get(ADP.PlotTags(II).tags.MainPlotAxis,'userdata');
%             
%             if(~isempty(MyPlotData.toBeDeleted))
%                 disp(['**Side plot length = ',num2str(length(MyPlotData.toBeDeleted))])
%                 for KK=length(MyPlotData.toBeDeleted):-1:1
%                     delete(MyPlotData.toBeDeleted(KK));
%                     MyPlotData.toBeDeleted(KK)=[];
%                 end
%             end
%             
%             for KK=1:length(handles.UL(ADP.Beamline(II)).slot)
%                 if(handles.UL(ADP.Beamline(II)).slot(KK).undulator.isInstalled && ~ handles.UL(ADP.Beamline(II)).slot(KK).undulator.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
%                     K{KK}=handles.UL(ADP.Beamline(II)).slot(KK).undulator.properties.f_getK(handles.UL(ADP.Beamline(II)).slot(KK).undulator,[handles.UL(ADP.Beamline(II)).Reference_lambda_u,MyPlotData.MaxK]);
%                     for TT=1:min(length(K{KK}),10)
%                         MyPlotData.toBeDeleted(end+1)=plot(ADP.PlotTags(II).tags.MainPlotAxis,[MyPlotData.z_in_end(KK,1),MyPlotData.z_in_end(KK,2)],[K{KK}(TT),K{KK}(TT)],'color',handles.HarmonicColors(TT,:));
%                         MyPlotData.toBeDeleted(end+1)=text((MyPlotData.z_in_end(KK,1)+MyPlotData.z_in_end(KK,2))/2, K{KK}(TT), num2str(KK), 'FontSize', 10, 'FontWeight', 'bold', 'Color', handles.HarmonicColors(TT,:), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'Parent', ADP.PlotTags(II).tags.MainPlotAxis );
%                     end
%                 end
%             end
%   
%             if(~isempty(ADD))
%                 
%                 for LL=1:ADD.nummerOfDetails
%                     if(ADP.Beamline(II)==ADD.Beamline(LL))
%                         if(ishandle(ADD.DetailTags(LL).tags.TABULA_NEW))
%                             TABULA_NEW=get(ADD.DetailTags(LL).tags.TABULA_NEW,'data');
%                             S=get(ADD.DetailTags(LL).tags.S,'data');
%                             STYLE1=get(ADD.DetailTags(LL).tags.Style1,'string');
%                             STYLE2=get(ADD.DetailTags(LL).tags.Style2,'string');
%                             for TT=1:length(handles.UL(ADP.Beamline(II)).slot)
%                                 if(handles.UL(ADP.Beamline(II)).slot(TT).undulator.isInstalled && ~ handles.UL(ADP.Beamline(II)).slot(TT).undulator.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
%                                     if(S(TT))
%                                         if(~isempty(TABULA_NEW(TT,2)))
%                                             MyPlotData.toBeDeleted(end+1)=plot(ADP.PlotTags(II).tags.MainPlotAxis,(MyPlotData.z_in_end(TT,1)+MyPlotData.z_in_end(TT,2))/2,TABULA_NEW{TT,2},STYLE1);
%                                         end
%                                     else
%                                         if(~isempty(TABULA_NEW(TT,2)))
%                                             MyPlotData.toBeDeleted(end+1)=plot(ADP.PlotTags(II).tags.MainPlotAxis,(MyPlotData.z_in_end(TT,1)+MyPlotData.z_in_end(TT,2))/2,TABULA_NEW{TT,2},STYLE2);
%                                         end
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%             
%             set_plotKMinMax(ADP.PlotTags(II).tags.MainPlotAxis,MyPlotData,K,ADP.PlotTags(II).tags.FullRange,ADP.PlotTags(II).tags.PlotFrom,ADP.PlotTags(II).tags.PlotTo)
%             set(ADP.PlotTags(II).tags.MainPlotAxis,'userdata',MyPlotData);
%             
%         else %add plot to remove cue
%             disp(['To Be deleted side plot ',num2str(ADP.Plots(II))]);
%             toBeDeleted(end+1)=II;
%         end
%     end
% end
% 
% if(~isempty(toBeDeleted))
%     for II=length(toBeDeleted):-1:1
%         try
%             close(ADP.Plots(toBeDeleted(II)))
%         end
%         ADP.nummerOfPlots=ADP.nummerOfPlots-1;
%         ADP.Plots(II)=[];
%         ADP.PlotTags(II)=[];
%         ADP.Beamline(II)=[];
%         ADP.PlotsString(II)=[];
%         if(ADP.nummerOfPlots<1)
%             ADP=[];
%         end
%     end
%     set(handles.U1,'userdata',ADP)
%     if(~isempty(ADP))
%         set(handles.LivePlotList,'string',ADP.PlotsString)
%     else
%         set(handles.LivePlotList,'string',ADP)
%     end
% else
%     disp('No attached additional plots');
% end

function set_plotKMinMax(Ax,PlotData,K,Obj,Minstring,Maxstring)
switch(get(Obj,'userdata'))
    case 1 %show full range
        ylim(Ax,[PlotData.MinK,PlotData.MaxK]+[-0.03,+0.03])
    case 2 %show auto range (min/max fundamental K +/-0.03)
        if(K(1)<K(2))
            ylim(Ax,[K(1),K(2)]+[-0.055,+0.055]);
        else
            ylim(Ax,[K(2),K(1)]+[-0.055,+0.055]);
        end
        
    case 3 %show manual range (read it from input, if not available as full)
        MinVal=str2num(get(Minstring,'string'));
        MaxVal=str2num(get(Maxstring,'string'));
        if(isempty(MinVal))
            MinVal=PlotData.MinK;
        else
            MinVal=MinVal(1);
            if(isinf(MinVal) || isnan(MinVal))
                MinVal=PlotData.MinK;
            end
        end
        if(isempty(MaxVal))
            MaxVal=PlotData.MaxK;
        else
            MaxVal=MaxVal(1);
            if(isinf(MaxVal) || isnan(MaxVal))
                MaxVal=PlotData.MaxK;
            end
        end
        if(abs(MinVal-MaxVal)<0.11);
            MinVal=(MinVal+MaxVal)/2 -0.055;
            MaxVal=MinVal+0.11;
            set(handles.Minstring,'string',num2str(MinVal));
            set(handles.Maxstring,'string',num2str(MaxVal));
        end
        if(MinVal<MaxVal)
            ylim(Ax,[MinVal,MaxVal]);
        elseif(MinVal>MaxVal)
            ylim(Ax,[MaxVal,MinVal]);
        else
            ylim(Ax,MaxVal+[-0.055,0.055]);
        end
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in Timer_Start.
function Timer_Start_Callback(hObject, eventdata, handles)
Seconds=str2num(get(handles.Timer_s,'string'));
set(handles.TIMER,'Period',Seconds);
AddMessage(handles.MessageList,[datestr(now),' Timer function Started; period ',num2str(Seconds),' s'],50);
guidata(hObject, handles);
start(handles.TIMER);
set(hObject,'backgroundcolor',handles.ColorOn);
set(hObject,'enable','off')
set(handles.Timer_Stop,'enable','on');

function Timer_s_Callback(hObject, eventdata, handles)
% hObject    handle to Timer_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Timer_s as text
%        str2double(get(hObject,'String')) returns contents of Timer_s as a double


% --- Executes during object creation, after setting all properties.
function Timer_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Timer_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Timer_Stop.
function Timer_Stop_Callback(hObject, eventdata, handles)
stop(handles.TIMER);
set(handles.Timer_Start,'backgroundcolor',handles.ColorIdle);
set(handles.Timer_Start,'enable','on')


% --- Executes on button press in Timer_Reset.
function Timer_Reset_Callback(hObject, eventdata, handles)
try
    stop(handles.TIMER);
end
try
    delete(handles.TIMER);
end
PERIODO=0.4;
handles.TIMER=timer('StartDelay', 0, 'Period', PERIODO, 'TasksToExecute', inf, 'ExecutionMode', 'fixedSpacing','Busymode','drop');
handles.TIMER.StartFcn = {@Timer_Update,handles,2};
handles.TIMER.StopFcn = {@Timer_Update,handles,0};
handles.TIMER.TimerFcn = {@Timer_Update,handles,1};
handles.TIMER.ErrorFcn = {@Timer_Update,handles,-1};
guidata(hObject, handles);
set(handles.Timer_Start,'enable','on');
set(handles.Timer_Start,'backgroundcolor',handles.ColorIdle);
set(handles.Timer_Stop,'enable','off');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    stop(handles.TIMER);
end
try
    delete(handles.TIMER);
end
try
    delete(hObject);
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LivePlotList.
function LivePlotList_Callback(hObject, eventdata, handles)
% hObject    handle to LivePlotList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LivePlotList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LivePlotList


% --- Executes during object creation, after setting all properties.
function LivePlotList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LivePlotList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BeamLine.
function handles=BeamLine_Callback(hObject, eventdata, handles)
try
    stop(handles.TIMER)
end

%This one is executed every time a new beamline is selected. It changes the
%main plot starting it from scratch and checks for installed/in maintenance
%components. It inhibites the timer function from the beginning of the call
%to its end. So that the plots are not updated in the meanwhile
ULID=get(handles.BeamLine,'value');
set(handles.pushbutton28,'userdata',[]);
set(handles.UNDO_Steer,'userdata',[]); set(handles.UNDO_Steer,'enable','off'); set(handles.MainPlot_Markers,'userdata',[]);
%set(handles.AUTO_MOVE_CHECKBOX,'userdata',0); set(handles.ListenMode,'value',0); set(handles.AUTO_MOVE_CHECKBOX,'value',0);

guidata(hObject, handles);

LineReadout=handles.UL(ULID).f.ReadAllLine(handles.UL(ULID));

set(handles.RESTORE_REFERENCE_BTN,'userdata',LineReadout);
set(handles.REFERENCE_DATE,'string',datestr(now));

% Plotting
PlotUndulatorLineIntoAxis(handles,handles.MainPlotAxis,ULID);
%PlotDetails(handles)
%PlotK(handles);
FirstUndulatorInfo=get(handles.FST_K,'userdata');
set(handles.FST_K,'string',num2str(FirstUndulatorInfo.FirstUndulatorInK));
EbeamEnergy=lcaGetSmart(handles.UL(ULID).Basic.EBeamEnergyPV);
EbeamCurrent=lcaGetSmart(handles.UL(ULID).Basic.EBeamCurrentPV);
EbeamCharge=lcaGetSmart(handles.UL(ULID).Basic.EBeamChargePV)*1000;
if(isnan(EbeamEnergy))
    set(handles.MODEL_BEAM_ENERGY,'string',num2str(handles.UL(ULID).Basic.EBeamEnergy));
    set(handles.MODEL_BEAM_ENERGY,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_BEAM_ENERGY,'string',num2str(EbeamEnergy));
end
if(isnan(EbeamCurrent))
    set(handles.MODEL_PEAK_CURRENT,'string',num2str(handles.UL(ULID).Basic.EBeamCurrent));
    set(handles.MODEL_PEAK_CURRENT,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_PEAK_CURRENT,'string',num2str(EbeamCurrent));
end
if(isnan(EbeamCharge))
    set(handles.MODEL_BUNCH_CHARGE,'string',num2str(handles.UL(ULID).Basic.EBeamCharge));
    set(handles.MODEL_BUNCH_CHARGE,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_BUNCH_CHARGE,'string',num2str(EbeamCharge));
end

set(handles.DisplayRedLine,'value',handles.UL(ULID).Basic.DisplayRedLine);
%set(handles.AUTO_MOVE_CHECKBOX,'value',handles.UL(ULID).Basic.AutoMoveToRedLine);
%set(handles.ListenMode,'value',handles.UL(ULID).Basic.ListenToSoftPVs);
set(handles.USE_SPONT_RAD_BOX,'value',handles.UL(ULID).Basic.UseSpontaneousRadiation);
set(handles.ADD_GAIN_TAPER_BOX,'value',handles.UL(ULID).Basic.AddGainTaper);
set(handles.ADD_POST_TAPER_BOX,'value',handles.UL(ULID).Basic.AddPostSatTaper);
set(handles.USE_WAKEFIELDS_BOX,'value',handles.UL(ULID).Basic.UseWakeFields);
set(handles.USE_CONT_TAPER_BOX,'value',handles.UL(ULID).Basic.UseContTaper);
set(handles.GAIN_TAPER_START_SEGMENT,'string',num2str(handles.UL(ULID).Basic.GainTaperParameters(1)));
set(handles.POST_TAPER_START_SEGMENT,'string',num2str(handles.UL(ULID).Basic.PostSatTaperParameters(1)));
set(handles.GAIN_TAPER_END_SEGMENT,'string',num2str(numel(handles.UL(ULID).slot)))
set(handles.POST_TAPER_END_SEGMENT,'string',num2str(numel(handles.UL(ULID).slot)))
set(handles.GAIN_TAPER_AMPLITUDE,'string',num2str(handles.UL(ULID).Basic.GainTaperParameters(3)));
set(handles.POST_TAPER_AMPLITUDE,'string',num2str(handles.UL(ULID).Basic.PostSatTaperParameters(3)));
%set(handles.POST_TAPER_LG,'string',num2str(handles.UL(ULID).Basic.FoldingLength));
%set(handles.GAIN_TAPER_SOFT_PV,'string',handles.UL(ULID).Basic.GainTaperPV);
%set(handles.POST_TAPER_SOFT_PV,'string',handles.UL(ULID).Basic.PostTaperPV);
%set(handles.SET_FIRST_K_PV,'string',handles.UL(ULID).Basic.FirstKPV);

set(handles.PlotFrom,'string',num2str(handles.UL(ULID).Basic.K_range(1)));
set(handles.PlotTo,'string',num2str(handles.UL(ULID).Basic.K_range(2)));

ReadDataFromMachine_Callback(hObject, eventdata, handles);

switch(ULID)
    case 1
        set_gui_color(handles,handles.Color_CU_HXR)
    case 2
        set_gui_color(handles,handles.Color_CU_SXR)
    otherwise
        set_gui_color(handles,handles.Color_CU_HXR)
end

try stop(handles.TIMER), end
try delete(handles.TIMER), end

set(handles.PSAxis,'XTick',[]); set(handles.PSAxis,'YTick',[]);
RLR_Callback(hObject, eventdata, handles);
set(handles.uipanel16,'visible','off');
PERIODO=0.2;
set(handles.Timer_s,'string',num2str(PERIODO));

handles.TIMER=timer('StartDelay', 0, 'Period', PERIODO, 'TasksToExecute', inf, 'ExecutionMode', 'fixedSpacing','Busymode','drop');
handles.TIMER.StartFcn = {@Timer_Update,handles,2};
handles.TIMER.StopFcn = {@Timer_Update,handles,0};
handles.TIMER.TimerFcn = {@Timer_Update,handles,1};
handles.TIMER.ErrorFcn = {@Timer_Update,handles,-1};
guidata(hObject, handles);
start(handles.TIMER)

function set_gui_color(handles,COLOR)
set(handles.figure1,'color',COLOR);
set(handles.text70,'backgroundcolor',COLOR);
set(handles.TitleText,'backgroundcolor',COLOR);
set(handles.datetext,'backgroundcolor',COLOR);
set(handles.REFERENCE_DATE,'backgroundcolor',COLOR);
set(handles.text66,'backgroundcolor',COLOR);

function PlotUndulatorLineIntoAxis(handles,axname,ULID)
if(isfield(handles,'TIMER'))
    stop(handles.TIMER);
end
cla(axname);
Plot.toBeDeleted=[]; Plot.z_in_end=[]; Plot.full_K_range=[]; Plot.full_z_range=[];Plot.ULID=ULID;

Plot.MaxK=handles.UL(ULID).Basic.K_range(2);
Plot.MinK=handles.UL(ULID).Basic.K_range(1);

hold(axname,'on');
for II=1:numel(handles.UL(ULID).slot)
    if(handles.UL(ULID).slot(II).USEG.present)
        handles.UL(ULID).slot(II).USEG.f.plotUndulator(handles.UL(ULID).slot(II).USEG,axname,ULID,handles);
        Plot.z_in_end(II,:)=[handles.UL(ULID).slot(II).USEG.z_ini,handles.UL(ULID).slot(II).USEG.z_end];
    end
    if(handles.UL(ULID).slot(II).BEND.present)
        handles.UL(ULID).slot(II).BEND.f.plot_Chicane(handles.UL(ULID).slot(II).BEND,axname,ULID,handles);
        Plot.z_in_end(II,:)=[handles.UL(ULID).slot(II).BEND.z_ini,handles.UL(ULID).slot(II).BEND.z_end];
    end
end
grid(axname,'on');
set(axname,'userdata',Plot);
xlim(axname,[min(Plot.z_in_end(:,1)),max(Plot.z_in_end(:,2))]);
if(isfield(handles,'TIMER'))
    start(handles.TIMER);
end

% --- Executes during object creation, after setting all properties.
function BeamLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeamLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FullRange.
function FullRange_Callback(hObject, eventdata, handles)
set(handles.FullRange,'value',1);set(handles.AutoRange,'value',0);set(handles.ManualRange,'value',0);
set(handles.FullRange,'userdata',1);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ManualRange.
function ManualRange_Callback(hObject, eventdata, handles)
set(handles.FullRange,'value',0);set(handles.AutoRange,'value',0);set(handles.ManualRange,'value',1);
set(handles.FullRange,'userdata',3);



function PlotFrom_Callback(hObject, eventdata, handles)
% hObject    handle to PlotFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotFrom as text
%        str2double(get(hObject,'String')) returns contents of PlotFrom as a double


% --- Executes during object creation, after setting all properties.
function PlotFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PlotTo_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PlotTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in MorePlots.
function MorePlots_Callback(hObject, eventdata, handles)
%stop(handles.TIMER);
NewPlot=ULT_AdditionalPlot;

switch(get(handles.BeamLine,'value'))
    case 1
        set(NewPlot,'color',handles.Color_CU_HXR)
    case 2
        set(NewPlot,'color',handles.Color_CU_SXR)
    otherwise
        set(NewPlot,'color',handles.Color_CU_HXR)
end

ADP=get(handles.U1,'Userdata');
NewPlotTags=read_all_children(findall(NewPlot));
if(isempty(ADP))
    ADP.PlotTags.tags=NewPlotTags;
    ADP.Plots=NewPlot;
    try %This horrible statement maintains compatibility with Matlab 2012 !
        ADP.PlotsString{1}=[num2str(ADP.Plots.Name),' ',num2str(rand(1))];
    catch
        ADP.PlotsString{1}=num2str(ADP.Plots);  
    end
    ADP.nummerOfPlots=1;
    ADP.Beamline=get(handles.BeamLine,'value');
    set(handles.LivePlotList,'string',ADP.PlotsString)
else
    ADP.PlotTags(end+1).tags=NewPlotTags;
    ADP.Plots(end+1)=NewPlot;
    try %This horrible statement maintains compatibility with Matlab 2012 !
        ADP.PlotsString{end+1}=[num2str(ADP.Plots(end).Name),' ',num2str(rand(1))];
    catch
        ADP.PlotsString{end+1}=num2str(ADP.Plots(end));  
    end
    ADP.nummerOfPlots=ADP.nummerOfPlots+1;
    ADP.Beamline(end+1)=get(handles.BeamLine,'value');
    set(handles.LivePlotList,'string',ADP.PlotsString)
end
set(handles.U1,'Userdata',ADP);
set(ADP.PlotTags(end).tags.FullRange,'userdata',get(handles.FullRange,'userdata'));
set(ADP.PlotTags(end).tags.FullRange,'value',get(handles.FullRange,'value'));
set(ADP.PlotTags(end).tags.ManualRange,'value',get(handles.ManualRange,'value'));
set(ADP.PlotTags(end).tags.AutoRange,'value',get(handles.AutoRange,'value'));
set(ADP.PlotTags(end).tags.PlotTo,'string',get(handles.PlotTo,'string'));
set(ADP.PlotTags(end).tags.PlotFrom,'string',get(handles.PlotFrom,'string'));

PlotUndulatorLineIntoAxis(handles,ADP.PlotTags(end).tags.MainPlotAxis,ADP.Beamline(end));

function out=read_all_children(in)
for II=1:length(in)
    tagname=get(in(II),'tag');
    if(~isempty(tagname))
        out.(tagname)=in(II);
    end
end

% --- Executes on button press in MoreTaperControl.
function MoreTaperControl_Callback(hObject, eventdata, handles)
stop(handles.TIMER);
Beamline=get(handles.BeamLine,'value');
% handles.UL=varargin{1};
% handles.Beamline=varargin{2};
% handles.MostRecentKData=varargin{3};
% handles.MainAxis=varargin{4};
% handles.OtherAxis=varargin{5};
% handles.MainAxisMarkers=varargin{6};
% handles.MyUniqueIdentifier=hObject;
NewDetail=ULT_MoreTaperControl(handles.UL(Beamline),Beamline,handles.(['UL',num2str(Beamline)]),handles.MainPlotAxis,handles.U1,handles.MainPlot_Markers);
ADD=get(handles.U2,'Userdata');
NewDetailTags=read_all_children(findall(NewDetail));
if(isempty(ADD))
    ADD.DetailTags.tags=NewDetailTags;
    ADD.Details=NewDetail;
    ADD.nummerOfDetails=1;
    ADD.Beamline=Beamline;
    try %This horrible statement maintains compatibility with Matlab 2012 !
        ADD.DetailsString{1}=[num2str(ADD.Details.Name),' ',num2str(rand(1))];
    catch
        ADD.DetailsString{1}=num2str(ADD.Details);  
    end
    set(handles.LiveTCList,'string',ADD.DetailsString);
else
    ADD.DetailTags(end+1).tags=NewDetailTags;
    ADD.Details(end+1)=NewDetail;
    ADD.nummerOfDetails=ADD.nummerOfDetails+1;
    try %This horrible statement maintains compatibility with Matlab 2012 !
        ADD.DetailsString{end+1}=[num2str(ADD.Details(end).Name),' ',num2str(rand(1))];
    catch
        ADD.DetailsString{end+1}=num2str(ADD.Details(end));  
    end
    ADD.Beamline(end+1)=Beamline;
    set(handles.LiveTCList,'string',ADD.DetailsString);
end
set(handles.U2,'Userdata',ADD);
set(ADD.DetailTags(end).tags.TABULA_NEW,'userdata',1);
start(handles.TIMER);


% --- Executes on button press in AutoRange.
function AutoRange_Callback(hObject, eventdata, handles)
set(handles.FullRange,'value',0);set(handles.AutoRange,'value',1);set(handles.ManualRange,'value',0);
set(handles.FullRange,'userdata',2);


% --- Executes on button press in ManualRange.
function radiobutton3_Callback(hObject, eventdata, handles)

function K_harm=eval_harmonic_K(K, harm)
if(K>0)
    K_harm=sqrt(2.*harm-2+K(1).^2.*harm);
else
    K_harm=0;
end

% --- Executes on button press in DEBUG.
function DEBUG_Callback(hObject, eventdata, handles)
AddMessage(handles.MessageList,[datestr(now), ' You have to learn obedience !'],50); 
Timer_Update(0,0,handles,1)

% --- Executes on button press in CAP.
function CAP_Callback(hObject, eventdata, handles)
stop(handles.TIMER);
ADP=get(handles.U1,'Userdata');
disp('Deleting all plots');
if(~isempty(ADP))
    for II=ADP.nummerOfPlots:-1:1
        try
            close(ADP.Plots(II))
        end
        ADP.nummerOfPlots=ADP.nummerOfPlots-1;
        ADP.Plots(II)=[];
        ADP.PlotTags(II)=[];
        ADP.Beamline(II)=[];
        if(ADP.nummerOfPlots<1)
            ADP=[];
        end
    end
    set(handles.U1,'userdata',ADP)
    set(handles.LivePlotList,'string',ADP)
end
start(handles.TIMER);


% --- Executes on button press in CMTC.
function CMTC_Callback(hObject, eventdata, handles)
stop(handles.TIMER);
ADD=get(handles.U2,'Userdata');
disp('Deleting all plots');
if(~isempty(ADD))
    for II=ADD.nummerOfDetails:-1:1
        try
            close(ADD.Details(II))
        end
        ADD.nummerOfDetails=ADD.nummerOfDetails-1;
        ADD.Details(II)=[];
        ADD.DetailTags(II)=[];
        ADD.Beamline(II)=[];
        if(ADD.nummerOfDetails<1)
            ADD=[];
        end
    end
end
set(handles.U2,'userdata',ADD)
set(handles.LiveTCList,'string',ADD)
start(handles.TIMER);

function PlotDetails(handles)
ADD=get(handles.U2,'Userdata'); toBeDeleted=[];
disp('Updating detail windows');
% UL=handles.UL;
% save TEMPFILE UL ADD
if(~isempty(ADD))
    for II=1:ADD.nummerOfDetails
        if(ishandle(ADD.Details(II)))
            TABULA=get(ADD.DetailTags(II).tags.TABULA,'data');
            [SA,SB]=size(TABULA);
            for KK=1:length(handles.UL(ADD.Beamline(II)).slot)
                if(handles.UL(ADD.Beamline(II)).slot(KK).phaseShifter.isInstalled)
                    Phase=handles.UL(ADD.Beamline(II)).slot(KK).phaseShifter.properties.f_getState(handles.UL(ADD.Beamline(II)).slot(KK).phaseShifter);
                    TABULA{KK,1}=Phase;
                end
                if(handles.UL(ADD.Beamline(II)).slot(KK).undulator.isInstalled)
                    UndulatorState=handles.UL(ADD.Beamline(II)).slot(KK).undulator.properties.f_getState(handles.UL(ADD.Beamline(II)).slot(KK).undulator,[handles.UL(ADD.Beamline(II)).Reference_lambda_u,8]);
                    K=UndulatorState.K;
                    if(KK>SA)
                        TABULA{KK,3}=1;
                    end
                    if(isempty(TABULA{KK,3}))
                        TABULA{KK,3}=1;
                    end                 
                    if(length(K)<TABULA{KK,3})
                        TABULA{KK,2}=[];
                    else
                        TABULA{KK,2}=K(TABULA{KK,3});
                    end     
                    TABULA{KK,4}=UndulatorState.StatusString;
                end
                if(handles.UL(ADD.Beamline(II)).slot(KK).chicane.isInstalled)
                    Delay=handles.UL(ADD.Beamline(II)).slot(KK).chicane.properties.f_getDelay(handles.UL(ADD.Beamline(II)).slot(KK).chicane);
                    TABULA{KK,5}=Delay;
                end
                
            end
            set(ADD.DetailTags(II).tags.TABULA,'data',TABULA);
            if(get(ADD.DetailTags(II).tags.TABULA_NEW,'userdata')) %First use->initialize!
                set(ADD.DetailTags(II).tags.TABULA_NEW,'data',TABULA);
                set(ADD.DetailTags(II).tags.TABULA_NEW,'userdata',0);
                [SA,SB]=size(TABULA);
                False_Vector=false(SA,1);
                set(ADD.DetailTags(II).tags.S,'data',False_Vector);
                set(ADD.DetailTags(II).tags.S,'ColumnEditable',true);
                set(ADD.DetailTags(II).tags.S,'ColumnName','S');
            end
        else
            toBeDeleted(end+1)=II;
        end
    end
    
    if(~isempty(toBeDeleted))
        for II=length(toBeDeleted):-1:1
            try
                close(ADD.Plots(toBeDeleted(II)))
            end
            ADD.nummerOfDetails=ADD.nummerOfDetails-1;
            ADD.Details(II)=[];
            ADD.DetailTags(II)=[];
            ADD.Beamline(II)=[];
            if(ADD.nummerOfDetails<1)
                ADD=[];
            end
        end
        set(handles.U2,'userdata',ADD)
        if(~isempty(ADD))
            set(handles.LiveTCList,'string',ADD.Details)
        else
            set(handles.LiveTCList,'string',ADD)
        end
    else
        disp('No attached additional Details');
    end
end


% --- Executes on button press in CloseGuiState.
function CloseGuiState_Callback(hObject, eventdata, handles)
set(handles.GuiStatePanel,'visible','off');
set(handles.ULPLOT,'visible','on');


% --- Executes on button press in GuiState.
function GuiState_Callback(hObject, eventdata, handles)
set(handles.GuiStatePanel,'visible','on');
set(handles.ULPLOT,'visible','off');


% --- Executes on selection change in LiveTCList.
function LiveTCList_Callback(hObject, eventdata, handles)
% hObject    handle to LiveTCList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LiveTCList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LiveTCList


% --- Executes during object creation, after setting all properties.
function LiveTCList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LiveTCList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RESTORE_INITIAL_BTN.
function RESTORE_INITIAL_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to RESTORE_INITIAL_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SaveReferenceKValues.
function SaveReferenceKValues_Callback(hObject, eventdata, handles)
ULID=get(handles.BeamLine,'value');
ReadPhase=get(handles.ReadoutPhase,'value');
LineReadout=handles.UL(ULID).f.ReadAllLine(handles.UL(ULID),ReadPhase);
set(handles.RESTORE_REFERENCE_BTN,'userdata',LineReadout);
NUNC=clock;
FIRST_TAPER=0;
set(handles.REFERENCE_DATE,'string',datestr(now));
try
    load([handles.SaveDir,'/',handles.TaperSave],'StoredTapers')
catch
    FIRST_TAPER=1;
    StoredTapers(1).ULID=ULID;
    StoredTapers(1).LineReadout=LineReadout;
    StoredTapers(1).Description=get(handles.edit32,'string');
    StoredTapers(1).Y=NUNC(1);
    StoredTapers(1).M=NUNC(2);
    StoredTapers(1).D=NUNC(3);
    StoredTapers(1).H=NUNC(4);
    StoredTapers(1).Min=NUNC(5);
    StoredTapers(1).S=NUNC(6);
    StoredTapers(1).time=datenum(NUNC);
end

if(FIRST_TAPER)
    save([handles.SaveDir,'/',handles.TaperSave],'StoredTapers');
else
    StoredTapers(end+1).ULID=ULID;
    StoredTapers(end).LineReadout=LineReadout;
    StoredTapers(end).Description=get(handles.edit32,'string');
    StoredTapers(end).Y=NUNC(1);
    StoredTapers(end).M=NUNC(2);
    StoredTapers(end).D=NUNC(3);
    StoredTapers(end).H=NUNC(4);
    StoredTapers(end).Min=NUNC(5);
    StoredTapers(end).S=NUNC(6);
    StoredTapers(end).time=datenum(NUNC);
    save([handles.SaveDir,'/',handles.TaperSave],'StoredTapers');
end



% --- Executes on button press in RESTORE_REFERENCE_BTN.
function RESTORE_REFERENCE_BTN_Callback(hObject, eventdata, handles)
TargetState=get(handles.RESTORE_REFERENCE_BTN,'userdata');
ULID=get(handles.BeamLine,'value'); Harmonic=1; ins=0;
if(numel(handles.UL(ULID).slot)==numel(TargetState))
    for II=1:length(handles.UL(ULID).slot)
        if(handles.UL(ULID).slot(II).USEG.present)
            if(TargetState(II).K>0)    
            ins=ins+1;    
            NewDest=handles.UL(ULID).slot(II).USEG.f.Set_K_struct(handles.UL(ULID).slot(II).USEG,[TargetState(II).K,TargetState(II).Kend],Harmonic,handles.UL(ULID).Basic.Reference_lambda_u);    
            if(ins==1)
                Destination(1)=NewDest;
            else
                Destination(ins)=NewDest;
            end
            end
        end
        if(handles.UL(ULID).slot(II).PHAS.present)
            lcaPutSmart(handles.UL(ULID).slot(II).PHAS.pv.PDes,TargetState(II).PhaseDes)
        end
    end
end
handles.UL(ULID).f.UndulatorLine_K_set(handles.UL(ULID),Destination);

% --- Executes on button press in MAKE_TAPER_OFFICIAL.
function MAKE_TAPER_OFFICIAL_Callback(hObject, eventdata, handles)
% hObject    handle to MAKE_TAPER_OFFICIAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FST_K_Callback(hObject, eventdata, handles)
FirstK=str2double(get(handles.FST_K,'string'));
if(get(handles.checkbox18,'value'))
    ULID=get(handles.BeamLine,'value');
        if(FirstK<handles.UL(ULID).Basic.DiscouragedK) 
            warndlg(['Setting a K below ',num2str(handles.UL(ULID).Basic.DiscouragedK),' for the ',handles.UL(ULID).name ,' may result in poor performance and is generally not advised, unless there is a reason to do so. You have selected K = ',num2str(FirstK)]);
        end
end
Nunc=clock;
Date_String=[datestr(Nunc),'.',num2str(floor(100*(Nunc(6) - fix(Nunc(6)))))];
ULID=get(handles.BeamLine,'value');
[Result(8),ErrorString]=CheckRange(FirstK, 1, handles.UL(ULID).Basic.K_range(1), handles.UL(ULID).Basic.K_range(2), 'real', 0, 0, 'First Element K value', Date_String);
if(Result(8)~=1), AddMessage(handles.MessageList,ErrorString,50); 
    set(handles.FST_K,'string','');
end




% --- Executes during object creation, after setting all properties.
function FST_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AUTO_MOVE_CHECKBOX.
function AUTO_MOVE_CHECKBOX_Callback(hObject, eventdata, handles)
if(get(handles.AUTO_MOVE_CHECKBOX,'value'))
    ULID=get(handles.BeamLine,'value');
    Current=lcaGetSmart(handles.UL(ULID).Basic.UndulatorAutoMovePV);
    if(isnan(Current))
        Current=0;
    end
    lcaPutSmart(handles.UL(ULID).Basic.UndulatorAutoMovePV,Current+1); 
    set(handles.AUTO_MOVE_CHECKBOX,'userdata',Current+1); drawnow
    set(handles.AUTO_MOVE_CHECKBOX,'foregroundcolor',handles.ColorOk);
end

% --- Executes on button press in USE_SPONT_RAD_BOX.
function USE_SPONT_RAD_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_SPONT_RAD_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_SPONT_RAD_BOX


% --- Executes on button press in USE_WAKEFIELDS_BOX.
function USE_WAKEFIELDS_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_WAKEFIELDS_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_WAKEFIELDS_BOX


% --- Executes on button press in ADD_POST_TAPER_BOX.
function ADD_GAIN_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_POST_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_POST_TAPER_BOX


% --- Executes on button press in ADD_POST_TAPER_BOX.
function ADD_POST_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_POST_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_POST_TAPER_BOX



function GAIN_TAPER_START_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_START_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_START_SEGMENT as a double


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



function GAIN_TAPER_END_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_END_SEGMENT as a double


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



function GAIN_TAPER_AMPLITUDE_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of GAIN_TAPER_AMPLITUDE as a double


% --- Executes during object creation, after setting all properties.
function GAIN_TAPER_AMPLITUDE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function POST_TAPER_START_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_START_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_START_SEGMENT as a double


% --- Executes during object creation, after setting all properties.
function POST_TAPER_START_SEGMENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function POST_TAPER_END_SEGMENT_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_END_SEGMENT as a double


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



function POST_TAPER_AMPLITUDE_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_AMPLITUDE as a double


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


% --- Executes on selection change in POST_TAPER_MENU.
function POST_TAPER_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns POST_TAPER_MENU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from POST_TAPER_MENU


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



function POST_TAPER_LG_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_LG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_LG as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_LG as a double


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


% --- Executes on button press in CHANGE_COMPRESSION_STATUS_BTN.
function CHANGE_COMPRESSION_STATUS_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to CHANGE_COMPRESSION_STATUS_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function MODEL_PEAK_CURRENT_Callback(hObject, eventdata, handles)
MODEL_PEAK_CURRENT=str2num(get(handles.MODEL_PEAK_CURRENT,'string'));
Date_String=datestr(now);
[CheckResut,ErrorString]=CheckRange(MODEL_PEAK_CURRENT, 1, 200, 50000, 'real', 0, 0, 'Electron Bunch Peak Current', Date_String);
if(CheckResut~=1), AddMessage(handles.MessageList,ErrorString,50); 
    set(handles.MODEL_PEAK_CURRENT,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_PEAK_CURRENT,'foregroundcolor',handles.ColorOk);
end

% --- Executes during object creation, after setting all properties.
function MODEL_PEAK_CURRENT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_PEAK_CURRENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SET_PEAK_CURRENT_RADIO_BTN.
function SET_PEAK_CURRENT_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_PEAK_CURRENT_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_PEAK_CURRENT_RADIO_BTN


% --- Executes on button press in USE_ACTUAL_PEAK_CURRENT_RADIO_BTN.
function USE_ACTUAL_PEAK_CURRENT_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_PEAK_CURRENT_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_PEAK_CURRENT_RADIO_BTN



function MODEL_BUNCH_CHARGE_Callback(hObject, eventdata, handles)

MODEL_BUNCH_CHARGE=str2num(get(handles.MODEL_BUNCH_CHARGE,'string'));
Date_String=datestr(now);
[CheckResut,ErrorString]=CheckRange(MODEL_BUNCH_CHARGE, 1, 0.2, 2000, 'real', 0, 0, 'Electron Bunch charge', Date_String);
if(CheckResut~=1), AddMessage(handles.MessageList,ErrorString,50); 
    set(handles.MODEL_BUNCH_CHARGE,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_BUNCH_CHARGE,'foregroundcolor',handles.ColorOk);
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


% --- Executes on button press in SET_BUNCH_CHARGE_RADIO_BTN.
function SET_BUNCH_CHARGE_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_BUNCH_CHARGE_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_BUNCH_CHARGE_RADIO_BTN


% --- Executes on button press in USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN.
function USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_BUNCH_CHARGE_RADIO_BTN



function MODEL_BEAM_ENERGY_Callback(hObject, eventdata, handles)
MODEL_BEAM_ENERGY=str2num(get(handles.MODEL_BEAM_ENERGY,'string'));
Date_String=datestr(now);
[CheckResut,ErrorString]=CheckRange(MODEL_BEAM_ENERGY, 1, 0.1, 100, 'real', 0, 0, 'Input Electron Bunch Energy', Date_String);
if(CheckResut~=1), AddMessage(handles.MessageList,ErrorString,50); 
    set(handles.MODEL_BEAM_ENERGY,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_BEAM_ENERGY,'foregroundcolor',handles.ColorOk);
end

% --- Executes during object creation, after setting all properties.
function MODEL_BEAM_ENERGY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SET_ENERGY_RADIO_BTN.
function SET_ENERGY_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to SET_ENERGY_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SET_ENERGY_RADIO_BTN


% --- Executes on button press in USE_ACTUAL_ENERGY_RADIO_BTN.
function USE_ACTUAL_ENERGY_RADIO_BTN_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ACTUAL_ENERGY_RADIO_BTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ACTUAL_ENERGY_RADIO_BTN


% --- Executes on button press in FromModel.
function FromModel_Callback(hObject, eventdata, handles)
% hObject    handle to FromModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LogbookButton.
function LogbookButton_Callback(hObject, eventdata, handles)
set(handles.LogbookButton,'userdata',1);


% --- Executes on selection change in WakefieldModel.
function WakefieldModel_Callback(hObject, eventdata, handles)
% hObject    handle to WakefieldModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WakefieldModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WakefieldModel


% --- Executes during object creation, after setting all properties.
function WakefieldModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WakefieldModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_BEAM_ENERGY as text
%        str2double(get(hObject,'String')) returns contents of MODEL_BEAM_ENERGY as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BEAM_ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_BUNCH_CHARGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_BUNCH_CHARGE as text
%        str2double(get(hObject,'String')) returns contents of MODEL_BUNCH_CHARGE as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_BUNCH_CHARGE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to MODEL_PEAK_CURRENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MODEL_PEAK_CURRENT as text
%        str2double(get(hObject,'String')) returns contents of MODEL_PEAK_CURRENT as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MODEL_PEAK_CURRENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReadDataFromMachine.
function ReadDataFromMachine_Callback(hObject, eventdata, handles)
ULID=get(handles.BeamLine,'value');
EbeamEnergy=lcaGetSmart(handles.UL(ULID).Basic.EBeamEnergyPV);
EbeamCurrent=lcaGetSmart(handles.UL(ULID).Basic.EBeamCurrentPV);
EbeamCharge=lcaGetSmart(handles.UL(ULID).Basic.EBeamChargePV)*1000;
if(isnan(EbeamEnergy))
    set(handles.MODEL_BEAM_ENERGY,'string',num2str(handles.UL(ULID).Basic.EBeamEnergy));
    set(handles.MODEL_BEAM_ENERGY,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_BEAM_ENERGY,'string',num2str(EbeamEnergy));
    set(handles.MODEL_BEAM_ENERGY,'foregroundcolor',handles.ColorOk);
end
if(isnan(EbeamCurrent))
    set(handles.MODEL_PEAK_CURRENT,'string',num2str(handles.UL(ULID).Basic.EBeamCurrent));
    set(handles.MODEL_PEAK_CURRENT,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_PEAK_CURRENT,'string',num2str(EbeamCurrent));
    set(handles.MODEL_PEAK_CURRENT,'foregroundcolor',handles.ColorOk);
end
if(isnan(EbeamCharge))
    set(handles.MODEL_BUNCH_CHARGE,'string',num2str(handles.UL(ULID).Basic.EBeamCharge));
    set(handles.MODEL_BUNCH_CHARGE,'foregroundcolor',handles.ColorError);
else
    set(handles.MODEL_BUNCH_CHARGE,'string',num2str(EbeamCharge));
    set(handles.MODEL_BUNCH_CHARGE,'foregroundcolor',handles.ColorOk);
end

% --- Executes on button press in DisplayRedLine.
function DisplayRedLine_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayRedLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisplayRedLine


% --- Executes on button press in AUTO_MOVE_CHECKBOX.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to AUTO_MOVE_CHECKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AUTO_MOVE_CHECKBOX


% --- Executes on button press in ListenMode.
function ListenMode_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
disp(['Function to move undulators called at ',datestr(now)]);
RedLineRequirements=get(handles.pushbutton28,'userdata');
ID=get(handles.BeamLine,'value');
Harmonic=1; ins=0;
if(~isempty(RedLineRequirements))
   for II=1:handles.UL(ID).slotlength
      if(~isnan(RedLineRequirements.K(II)))
         %[RedLineRequirements.K(II),RedLineRequirements.Kend(II)]
         ins=ins+1;
         NewDest=handles.UL(ID).slot(II).USEG.f.Set_K_struct(handles.UL(ID).slot(II).USEG,[RedLineRequirements.K(II),RedLineRequirements.Kend(II)],Harmonic,handles.UL(ID).Basic.Reference_lambda_u); 
         if(ins==1)
             Destination(1)=NewDest;
         else
             Destination(ins)=NewDest; 
         end
         
      end
   end
end
handles.UL(ID).f.UndulatorLine_K_set(handles.UL(ID),Destination);
Input=RedLineRequirements.OrigInput;
ULID=Input.ULID;

lcaPutSmart(handles.UL(ULID).Basic.RedLinePVs,[Input.USE_SPONT_RAD_BOX,Input.USE_WAKEFIELDS_BOX,Input.ADD_GAIN_TAPER_BOX,Input.ADD_POST_TAPER_BOX,Input.USE_CONT_TAPER,Input.USE_ALL_SEGMENTS,Input.GAIN_TAPER_START_SEGMENT,Input.GAIN_TAPER_END_SEGMENT,Input.GAIN_TAPER_AMPLITUDE,Input.POST_TAPER_START_SEGMENT,Input.POST_TAPER_END_SEGMENT,Input.POST_TAPER_AMPLITUDE,length(Input.POST_TAPER_MENU),Input.POST_TAPER_MENU_VALUE,Input.WakefieldModel_VALUE,Input.First_K,Input.MODEL_BEAM_ENERGY,Input.MODEL_PEAK_CURRENT,Input.MODEL_BUNCH_CHARGE,Input.FirstUndulatorInfo.FirstUndulatorIn,Input.FirstUndulatorInfo.FirstUndulatorInK]');
%handles.UL(ID).f.Set_phase_shifters(handles.UL(ID),handles.PhyConsts)

function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FST_K as text
%        str2double(get(hObject,'String')) returns contents of FST_K as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FST_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
! libreoffice --impress /home/physics/aal/Presentazioni/ULT_UndulatorLineTaper.pptx &


% --- Executes on button press in ADD_GAIN_TAPER_BOX.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to ADD_GAIN_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ADD_GAIN_TAPER_BOX



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_START_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_START_SEGMENT as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_START_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_END_SEGMENT as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_END_SEGMENT as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_END_SEGMENT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of POST_TAPER_AMPLITUDE as text
%        str2double(get(hObject,'String')) returns contents of POST_TAPER_AMPLITUDE as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to POST_TAPER_AMPLITUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TypeOfFormula.
function TypeOfFormula_Callback(hObject, eventdata, handles)
% hObject    handle to TypeOfFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TypeOfFormula contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypeOfFormula


% --- Executes during object creation, after setting all properties.
function TypeOfFormula_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypeOfFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MessageList.
function MessageList_Callback(hObject, eventdata, handles)
% hObject    handle to MessageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MessageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MessageList


% --- Executes during object creation, after setting all properties.
function MessageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GSP_SetName_Callback(hObject, eventdata, handles)
% hObject    handle to GSP_SetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GSP_SetName as text
%        str2double(get(hObject,'String')) returns contents of GSP_SetName as a double


% --- Executes during object creation, after setting all properties.
function GSP_SetName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GSP_SetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GSP_SetValue_Callback(hObject, eventdata, handles)
% hObject    handle to GSP_SetValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GSP_SetValue as text
%        str2double(get(hObject,'String')) returns contents of GSP_SetValue as a double


% --- Executes during object creation, after setting all properties.
function GSP_SetValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GSP_SetValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GSP_SET_PV.
function GSP_SET_PV_Callback(hObject, eventdata, handles)
PV=get(handles.GSP_SetName,'string');
VAL=str2num(get(handles.GSP_SetValue,'string'));
lcaPutSmart(PV,VAL);



function SteeringReadingTime_Callback(hObject, eventdata, handles)
% hObject    handle to SteeringReadingTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SteeringReadingTime as text
%        str2double(get(hObject,'String')) returns contents of SteeringReadingTime as a double


% --- Executes during object creation, after setting all properties.
function SteeringReadingTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SteeringReadingTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UNDO_Steer.
function UNDO_Steer_Callback(hObject, eventdata, handles)
Solution=get(handles.UNDO_Steer,'userdata');
lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.OldCorr);
set(handles.UNDO_Steer,'enable','off');


% --- Executes on button press in SteerFlat.
function SteerFlat_Callback(hObject, eventdata, handles)
if(isfield(handles,'TIMER'))
      stop(handles.TIMER);
      AddMessage(handles.MessageList,[datestr(now), ' Timer function stopped.'],50);
end
ULID=get(handles.BeamLine,'value');
set(hObject,'backgroundcolor',handles.ColorWait);

DisableFeedBack_BeforeSteering=get(handles.ULDISABLE,'value');
if(DisableFeedBack_BeforeSteering)
    FeedbackState=handles.UL(ULID).f.LaunchFeedback_Get(handles.UL(ULID));
    if(~isnan(FeedbackState))
        if(DisableFeedBack_BeforeSteering && logical(FeedbackState))
           Restore_Feedback_on=1;
           handles.UL(ULID).f.LaunchFeedback_Set(handles.UL(ULID),false); pause(0.25);
        else
           Restore_Feedback_on=0;
        end
    else
       AddMessage(handles.MessageList,[datestr(now), ' State of feedback undefined.'],50); 
       Restore_Feedback_on=0;
    end
else
    Restore_Feedback_on=0;
end

options.BSA_HB=1; options.AcquisitionTime=2;
[~,options.startTime]=lcaGetSmart(strcat(handles.static(ULID).bpmList_e{1},':X'));
options.fitSVDRatio=0.005;
ReducedStatic=handles.static(ULID);
ReducedStatic.bpmList=ReducedStatic.bpmList(1:(end-2));
ReducedStatic.bpmList_e=ReducedStatic.bpmList_e(1:(end-2));
ReducedStatic.zBPM=ReducedStatic.zBPM(1:(end-2));
ReducedStatic.lBPM=ReducedStatic.lBPM(1:(end-2));
Solution=handles.sf.steer(ReducedStatic,options);

if(Solution.FAILED)
    set(hObject,'backgroundcolor',handles.ColorOff);
    OutOfRange=Solution.UsedCorr_e(Solution.OutOfRange);
    str='Steering Failed. Correctors out of range: ';
    for JJs=1:numel(OutOfRange)
        str=[str,OutOfRange{JJs},' '];
    end
    AddMessage(handles.MessageList,[datestr(now), ' ',str],50); 
    drawnow; pause(0.5);
else
   set(handles.UNDO_Steer,'userdata',Solution);
   set(handles.UNDO_Steer,'enable','on');
   lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr);
end

if(Restore_Feedback_on)
    handles.UL(ULID).f.LaunchFeedback_Set(handles.UL(ULID),true);
end

set(hObject,'backgroundcolor',handles.ColorIdle);

if(isfield(handles,'TIMER'))
    start(handles.TIMER); 
    AddMessage(handles.MessageList,[datestr(now), ' Timer function started.'],50);
end

% --- Executes on button press in Steertotarget.
function Steertotarget_Callback(hObject, eventdata, handles)
% hObject    handle to Steertotarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ULDISABLE.
function ULDISABLE_Callback(hObject, eventdata, handles)
% hObject    handle to ULDISABLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ULDISABLE


% --- Executes on button press in USE_CONT_TAPER_BOX.
function USE_CONT_TAPER_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to USE_CONT_TAPER_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_CONT_TAPER_BOX


% --- Executes on button press in USE_ALL_SEGMENTS.
function USE_ALL_SEGMENTS_Callback(hObject, eventdata, handles)
% hObject    handle to USE_ALL_SEGMENTS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USE_ALL_SEGMENTS


% --- Executes on button press in GSP_init.
function GSP_init_Callback(hObject, eventdata, handles)
InitUndulatorLine_Machine
save([handles.SaveDir,'/UL.mat'],'UL','static','ul');
handles.UL=UL;
set(handles.BeamLine,'value',1);
handles=BeamLine_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in MCP_SH.
function MCP_SH_Callback(hObject, eventdata, handles)



function Ph_e_Callback(hObject, eventdata, handles)
% hObject    handle to Ph_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ph_e as text
%        str2double(get(hObject,'String')) returns contents of Ph_e as a double


% --- Executes during object creation, after setting all properties.
function Ph_e_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ph_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_e_Callback(hObject, eventdata, handles)
% hObject    handle to K_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_e as text
%        str2double(get(hObject,'String')) returns contents of K_e as a double


% --- Executes during object creation, after setting all properties.
function K_e_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function en_e_Callback(hObject, eventdata, handles)
% hObject    handle to en_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of en_e as text
%        str2double(get(hObject,'String')) returns contents of en_e as a double


% --- Executes during object creation, after setting all properties.
function en_e_CreateFcn(hObject, eventdata, handles)
% hObject    handle to en_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
ULID=get(handles.BeamLine,'value');
ULT_TaperRestore(handles.UL,ULID,handles.SaveDir,handles.TaperSave);


% --- Executes on button press in KillGui.
function KillGui_Callback(hObject, eventdata, handles)
close(handles.figure1)

% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
MODE=get(handles.TypeOfFormula,'value');
e_ene=get(handles.en_e,'string');
K=get(handles.K_e,'string');
e_Ph=get(handles.Ph_e,'string');
ULID=get(handles.BeamLine,'value');

if(MODE==2) %New electron energy for some Delta Photon Energy
    e_ene_number=str2double(e_ene);
    K_number=str2double(K);
    DELTAe_Ph_number=str2double(e_Ph);
    
    if(~isnan(e_ene_number) && ~isnan(K_number) && ~isnan(DELTAe_Ph_number))
        NuovoGammaQuadrato = DELTAe_Ph_number/2/((handles.PhyConsts.hplanck * handles.PhyConsts.c / (handles.UL(ULID).Basic.Reference_lambda_u/1000 * (1+K_number^2/2)))) + (e_ene_number/(handles.PhyConsts.mc2_e/10^6))^2;
        DeltaE= sqrt(NuovoGammaQuadrato) * (handles.PhyConsts.mc2_e/10^6);
        set(handles.Risposta,'string',num2str(DeltaE))
    end 
end

if(MODE==3) %New K for some Delta Electron Energy
    e_ene_number=str2double(e_ene);
    K_number=str2double(K);
    DELTAe_Ph_number=str2double(e_Ph);
    if(~isnan(e_ene_number) && ~isnan(K_number) && ~isnan(DELTAe_Ph_number))
        ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio = DELTAe_Ph_number/(handles.PhyConsts.hplanck * handles.PhyConsts.c / (handles.UL(ULID).Basic.Reference_lambda_u/1000/(2*(e_ene_number/(handles.PhyConsts.mc2_e/10^6))^2)));
        Knuovo = sqrt(2*(1/(ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio + 1/(1+K_number^2/2)) -1));
        set(handles.Risposta,'string',num2str(Knuovo))
    end 
end

    
if((MODE==1) || (MODE==4) || (MODE==5) || (MODE==6)) %absolute
    e_ene_number=str2double(e_ene);
    K_number=str2double(K);
    e_Ph_number=str2double(e_Ph);
    if(MODE==4), e_ene_number=NaN; end;
    if(MODE==5), K_number=NaN; end;
    if(MODE==6), e_Ph_number=NaN; end;
    if(isnan(e_ene_number))
        if(~isnan(K_number) && ~isnan(e_Ph_number))
            GammaQuadro=(e_Ph_number / (handles.PhyConsts.hplanck * handles.PhyConsts.c / (handles.UL(ULID).Basic.Reference_lambda_u/1000 * (1+K_number^2/2))) )/2;
            Electron_Energy = sqrt(GammaQuadro) * (handles.PhyConsts.mc2_e/10^6);
        end
        set(handles.en_e,'string',num2str(Electron_Energy));
        if(get(handles.AutoSwitchFormula,'value'))
            set(handles.TypeOfFormula,'value',4);
        end
        return
    end
    if(isnan(K_number))
        if(~isnan(e_ene_number) && ~isnan(e_Ph_number))
            UnoPiuKappaQuadroMezzi = handles.PhyConsts.hplanck * handles.PhyConsts.c / (handles.UL(ULID).Basic.Reference_lambda_u/1000 * (e_Ph_number)/(2*(e_ene_number/(handles.PhyConsts.mc2_e/10^6))^2));
            K = sqrt(2*UnoPiuKappaQuadroMezzi - 2);
        end
        set(handles.K_e,'string',num2str(K));
        if(get(handles.AutoSwitchFormula,'value'))
            set(handles.TypeOfFormula,'value',5);
        end
        return
    end
    if(isnan(e_Ph_number))
        if(~isempty(K_number) && ~isempty(e_ene_number))
            Photon_Energy = handles.PhyConsts.hplanck * handles.PhyConsts.c / (handles.UL(ULID).Basic.Reference_lambda_u/1000 * (1+K_number^2/2)/(2*(e_ene_number/(handles.PhyConsts.mc2_e/10^6))^2));
        end
        set(handles.Ph_e,'string',num2str(Photon_Energy));
        if(get(handles.AutoSwitchFormula,'value'))
            set(handles.TypeOfFormula,'value',6);
        end
        return
    end
end

% handles.PhyConsts.c=299792458;
% handles.PhyConsts.mc2_e=5.109989180000000e+05;
% handles.PhyConsts.echarge=1.602176530000000e-19;
% handles.PhyConsts.mu_0=1.256637061435917e-06;
% handles.PhyConsts.eps_0=8.854187817620391e-12;
% handles.PhyConsts.r_e=2.817940318198647e-15;
% handles.PhyConsts.Z_0=3.767303134617707e+02;
% handles.PhyConsts.h_bar=1.054571682364455e-34; %J s
% handles.PhyConsts.alpha=0.007297352554051;
% handles.PhyConsts.Avogadro=6.022141500000000e+23;
% handles.PhyConsts.k_Boltzmann=1.380650500000000e-23;
% handles.PhyConsts.Stefan_Boltzmann=5.670401243654186e-08;
% handles.PhyConsts.hplanck=4.135667516*10^-15;



function EXCLUDE_Callback(hObject, eventdata, handles)
% hObject    handle to EXCLUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EXCLUDE as text
%        str2double(get(hObject,'String')) returns contents of EXCLUDE as a double


% --- Executes during object creation, after setting all properties.
function EXCLUDE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EXCLUDE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExcludeSegments.
function handles=ExcludeSegments_Callback(hObject, eventdata, handles)
ULID=get(handles.BeamLine,'value');

%Timer_Stop_Callback(handles.Timer_Stop, eventdata, handles)
%Timer_Reset_Callback(handles.Timer_Reset, eventdata, handles)
%pause(0.5);
%Timer_Start_Callback(handles.Timer_Start, eventdata, handles)

EXCLUDE=str2num(get(handles.EXCLUDE,'string'));
BACKUP=get(handles.ExcludeSegments,'userdata');
if(isempty(BACKUP))
    BACKUP=handles.UL;
    set(handles.ExcludeSegments,'userdata',BACKUP);
end
UL=BACKUP; 
if(~isempty(EXCLUDE))
    %Remove Excluded segments here!
    UL(ULID).slot(EXCLUDE)=[];
    UL(ULID).slotlength =length(UL(ULID).slot);
    UL(ULID).UsegPresent(EXCLUDE)=[];
    UL(ULID).DeviceMap(EXCLUDE,:)=[];
end

%End of Removing segments.
handles.UL=UL;
guidata(hObject, handles);
handles=BeamLine_Callback(hObject, eventdata, handles);
guidata(hObject, handles);
CloseGuiState_Callback(hObject, eventdata, handles);
handles=BeamLine_Callback(hObject, eventdata, handles);


% --- Executes on button press in AutoSwitchFormula.
function AutoSwitchFormula_Callback(hObject, eventdata, handles)
% hObject    handle to AutoSwitchFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoSwitchFormula


% --- Executes on button press in ReadoutPhase.
function ReadoutPhase_Callback(hObject, eventdata, handles)
% hObject    handle to ReadoutPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ReadoutPhase


% --- Executes on button press in GSP_UseCellNumber.
function GSP_UseCellNumber_Callback(hObject, eventdata, handles)
New_Value=get(handles.GSP_UseCellNumber,'value');
try stop(handles.TIMER), end
ULID=get(handles.BeamLine,'value');
if(New_Value) %switch to girder # mode
   GAIN_TAPER_START_SEGMENT=str2double(get(handles.GAIN_TAPER_START_SEGMENT,'string'));  
   GAIN_TAPER_END_SEGMENT=str2double(get(handles.GAIN_TAPER_END_SEGMENT,'string'));
   POST_TAPER_START_SEGMENT=str2double(get(handles.POST_TAPER_START_SEGMENT,'string'));
   POST_TAPER_END_SEGMENT=str2double(get(handles.POST_TAPER_END_SEGMENT,'string'));
   
   set(handles.GAIN_TAPER_START_SEGMENT,'string',num2str(handles.UL(ULID).slotcell(GAIN_TAPER_START_SEGMENT)));
   set(handles.GAIN_TAPER_END_SEGMENT,'string',num2str(handles.UL(ULID).slotcell(GAIN_TAPER_END_SEGMENT)));
   set(handles.POST_TAPER_START_SEGMENT,'string',num2str(handles.UL(ULID).slotcell(POST_TAPER_START_SEGMENT)));
   set(handles.POST_TAPER_END_SEGMENT,'string',num2str(handles.UL(ULID).slotcell(POST_TAPER_END_SEGMENT)));

else %switch to undulator # mode
   GAIN_TAPER_START_SEGMENT=str2double(get(handles.GAIN_TAPER_START_SEGMENT,'string'));  
   GAIN_TAPER_END_SEGMENT=str2double(get(handles.GAIN_TAPER_END_SEGMENT,'string'));
   POST_TAPER_START_SEGMENT=str2double(get(handles.POST_TAPER_START_SEGMENT,'string'));
   POST_TAPER_END_SEGMENT=str2double(get(handles.POST_TAPER_END_SEGMENT,'string'));
   
   set(handles.GAIN_TAPER_START_SEGMENT,'string',num2str(find(handles.UL(ULID).slotcell==GAIN_TAPER_START_SEGMENT)));
   set(handles.GAIN_TAPER_END_SEGMENT,'string',num2str(find(handles.UL(ULID).slotcell==GAIN_TAPER_END_SEGMENT)));
   set(handles.POST_TAPER_START_SEGMENT,'string',num2str(find(handles.UL(ULID).slotcell==POST_TAPER_START_SEGMENT)));
   set(handles.POST_TAPER_END_SEGMENT,'string',num2str(find(handles.UL(ULID).slotcell==POST_TAPER_END_SEGMENT)));
end

try,start(handles.TIMER); end

% --- Executes on button press in SmallVersion.
function SmallVersion_Callback(hObject, eventdata, handles)
get(handles.SmallVersion,'userdata');

function SetInputBoxes(RLPV,handles)
Input.USE_SPONT_RAD_BOX=RLPV(1);
Input.USE_WAKEFIELDS_BOX=RLPV(2);
Input.ADD_GAIN_TAPER_BOX=RLPV(3);
Input.ADD_POST_TAPER_BOX=RLPV(4);
Input.USE_CONT_TAPER=RLPV(5);
Input.USE_ALL_SEGMENTS=RLPV(6);
Input.GAIN_TAPER_START_SEGMENT=RLPV(7);
Input.GAIN_TAPER_END_SEGMENT=RLPV(8);
Input.GAIN_TAPER_AMPLITUDE=RLPV(9);
Input.POST_TAPER_START_SEGMENT=RLPV(10);
Input.POST_TAPER_END_SEGMENT=RLPV(11);
Input.POST_TAPER_AMPLITUDE=RLPV(12);
Input.POST_TAPER_MENU_VALUE=RLPV(14);
Input.WakefieldModel_VALUE=RLPV(15);
Input.First_K=RLPV(16);
Input.MODEL_BEAM_ENERGY=RLPV(17);
Input.MODEL_PEAK_CURRENT=RLPV(18);
Input.MODEL_BUNCH_CHARGE=RLPV(19);
Input.FirstUndulatorInfo.FirstUndulatorIn=RLPV(20);
Input.FirstUndulatorInfo.FirstUndulatorInK=RLPV(21);

set(handles.USE_SPONT_RAD_BOX,'value',Input.USE_SPONT_RAD_BOX);
set(handles.USE_WAKEFIELDS_BOX,'value',Input.USE_WAKEFIELDS_BOX);
set(handles.ADD_GAIN_TAPER_BOX,'value',Input.ADD_GAIN_TAPER_BOX);
set(handles.ADD_POST_TAPER_BOX,'value',Input.ADD_POST_TAPER_BOX);
set(handles.USE_CONT_TAPER_BOX,'value',Input.USE_CONT_TAPER);
set(handles.USE_ALL_SEGMENTS,'value',Input.USE_ALL_SEGMENTS);
set(handles.GAIN_TAPER_START_SEGMENT,'string',num2str(Input.GAIN_TAPER_START_SEGMENT));
set(handles.GAIN_TAPER_END_SEGMENT,'string',num2str(Input.GAIN_TAPER_END_SEGMENT));
set(handles.GAIN_TAPER_AMPLITUDE,'string',num2str(Input.GAIN_TAPER_AMPLITUDE));
set(handles.POST_TAPER_START_SEGMENT,'string',num2str(Input.POST_TAPER_START_SEGMENT));
set(handles.POST_TAPER_END_SEGMENT,'string',num2str(Input.POST_TAPER_END_SEGMENT));
set(handles.POST_TAPER_AMPLITUDE,'string',num2str(Input.POST_TAPER_AMPLITUDE));
set(handles.POST_TAPER_MENU,'value',Input.POST_TAPER_MENU_VALUE);
set(handles.WakefieldModel,'value',Input.WakefieldModel_VALUE);
set(handles.FST_K,'string',num2str(Input.First_K));
set(handles.MODEL_BEAM_ENERGY,'string',num2str(Input.MODEL_BEAM_ENERGY));
set(handles.MODEL_PEAK_CURRENT,'string',num2str(Input.MODEL_PEAK_CURRENT));
set(handles.MODEL_BUNCH_CHARGE,'string',num2str(Input.MODEL_BUNCH_CHARGE));
set(handles.FST_K,'userdata',Input.FirstUndulatorInfo);

% --- Executes on button press in RLR.
function RLR_Callback(hObject, eventdata, handles)
C_GSP=get(handles.GSP_UseCellNumber,'value');
try stop(handles.TIMER), end
set(handles.GSP_UseCellNumber,'value',0);
ULID=get(handles.BeamLine,'value');
RLPV=lcaGetSmart(handles.UL(ULID).Basic.RedLinePVs);

SetInputBoxes(RLPV,handles);
if(C_GSP)
    set(handles.GSP_UseCellNumber,'value',C_GSP); pause(0.01);
    GSP_UseCellNumber_Callback(hObject, C_GSP, handles);
end
try stop(handles.TIMER), end
pause(0.05);
try, start(handles.TIMER), end



% --- Executes on button press in ROL.
function ROL_Callback(hObject, eventdata, handles)
% hObject    handle to ROL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function e_MM_Callback(hObject, eventdata, handles)
% hObject    handle to e_MM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_MM as text
%        str2double(get(hObject,'String')) returns contents of e_MM as a double


% --- Executes during object creation, after setting all properties.
function e_MM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_MM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_DD_Callback(hObject, eventdata, handles)
% hObject    handle to e_DD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_DD as text
%        str2double(get(hObject,'String')) returns contents of e_DD as a double


% --- Executes during object creation, after setting all properties.
function e_DD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_DD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_YYYY_Callback(hObject, eventdata, handles)
% hObject    handle to e_YYYY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_YYYY as text
%        str2double(get(hObject,'String')) returns contents of e_YYYY as a double


% --- Executes during object creation, after setting all properties.
function e_YYYY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_YYYY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_hh_Callback(hObject, eventdata, handles)
% hObject    handle to e_hh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_hh as text
%        str2double(get(hObject,'String')) returns contents of e_hh as a double


% --- Executes during object creation, after setting all properties.
function e_hh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_hh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_mm_Callback(hObject, eventdata, handles)
% hObject    handle to e_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_mm as text
%        str2double(get(hObject,'String')) returns contents of e_mm as a double


% --- Executes during object creation, after setting all properties.
function e_mm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_ss_Callback(hObject, eventdata, handles)
% hObject    handle to fdsfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fdsfs as text
%        str2double(get(hObject,'String')) returns contents of fdsfs as a double


% --- Executes during object creation, after setting all properties.
function fdsfs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fdsfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, handles)

C_GSP=get(handles.GSP_UseCellNumber,'value');
try stop(handles.TIMER), end
set(handles.GSP_UseCellNumber,'value',0);
ULID=get(handles.BeamLine,'value');


str=get(handles.e_MM,'string');
str=[str,'/',get(handles.e_DD,'string')];
str=[str,'/',get(handles.e_YYYY,'string'),' '];
str=[str,get(handles.e_hh,'string')];
str=[str,':',get(handles.e_mm,'string')];
str=[str,':',get(handles.e_ss,'string')];

[~, HistoryOut] = history(handles.UL(ULID).Basic.RedLinePVs, {str,str});
for II=1:numel(HistoryOut)
    RLPV(II)=HistoryOut{II}(1);
end

SetInputBoxes(RLPV,handles);

if(C_GSP)
    set(handles.GSP_UseCellNumber,'value',C_GSP); pause(0.25);
    GSP_UseCellNumber_Callback(hObject, eventdata, handles);
end

set(handles.uipanel16,'visible','off');
try stop(handles.TIMER), end
pause(0.05);
start(handles.TIMER)


% --- Executes on button press in RestoreArchive.
function RestoreArchive_Callback(hObject, eventdata, handles)
D=clock;
set(handles.e_YYYY,'string',num2str(D(1)));
set(handles.e_MM,'string',num2str(D(2),'%2.2d'));
set(handles.e_DD,'string',num2str(D(3),'%2.2d'));
set(handles.e_mm,'string',num2str(D(5),'%2.2d'));
set(handles.e_hh,'string',num2str(D(4),'%2.2d'));
set(handles.e_ss,'string',num2str(floor(D(6)),'%2.2d'));
set(handles.uipanel16,'visible','on');


% --- Executes during object creation, after setting all properties.
function e_ss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_ss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MCP_PS.
function MCP_PS_Callback(hObject, eventdata, handles)
Beamline=get(handles.BeamLine,'value');
NewPSControl=ULT_PSControl(handles.UL(Beamline),Beamline,handles.(['UL',num2str(Beamline)]));


% --- Executes on button press in reinitline.
function reinitline_Callback(hObject, eventdata, handles)
if(get(handles.reinitline,'value'))
   set(handles.GSP_init,'enable','on'); 
else
   set(handles.GSP_init,'enable','off'); 
end


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes during object creation, after setting all properties.
function pushbutton28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
