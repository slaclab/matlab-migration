function varargout = wirescan_gui(varargin)
% WIRESCAN_GUI M-file for wirescan_gui.fig
%      WIRESCAN_GUI, by itself, creates a new WIRESCAN_GUI or raises the existing
%      singleton*.
%
%      H = WIRESCAN_GUI returns the handle to a new WIRESCAN_GUI or the handle to
%      the existing singleton*.
%
%      WIRESCAN_GUI('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in WIRESCAN_GUI.M with the given input arguments.
%
%      WIRESCAN_GUI('Property','Value',...) creates a new WIRESCAN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wirescan_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wirescan_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wirescan_gui

% Last Modified by GUIDE v2.5 25-Apr-2016 16:39:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wirescan_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @wirescan_gui_OutputFcn, ...
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

% -----------------------------------------------------------------------
% Mod:
%      06-Aug-2020, B. Jacobson
%      Updated to include LTUS FWS, detectors, & BPMs
%      11-Feb-2020, B. Jacobson
%      Updated area names and devices for CuHXR. LTU/UND/DMP(0/1) -> (H)
%      13-Nov-17, G. White
%      Replaced MOTR_HOME_CMD with MOTR_RETRACT. The
%      latter additionally disables the motor control, putting it in
%      open loop.
%      G. White, 26-Sep-17
%      Fixed IOC MC02->03 of hack for WS33 and WS34 MaxV.
%      Fixed screen shot and logging to elog
%      G. White 24-Apr-17.
%      Added WS02, WS03, WS11,WS12,WS13, and LI27 & LI28 wires to 
%     list of fast wire scanners.
%      G. White 21-Oct-16. 
%      Added screen-shot to log support.
% =======================================================================

% --- Executes just before wirescan_gui is made visible.
function wirescan_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wirescan_gui (see VARARGIN)

wirescan_const;         % wirescan messages
warning backtrace off;  % Don't give files and function names of warnings

% Choose default command line output for wirescan_gui
handles.output = hObject;

try
    % Application constants initialization
    handles=appInit(hObject,handles);
    
    % Add Menu Bar
    %
    % The follow adds File and Controls menu bar operations to the GUI
    %
    set(gcf,'MenuBar','None');
    
    % Add Files menubar menu
    %
    handles.menuFile=uimenu('Label','File');
    
    % File->View Log
    handles.menuFile_itemViewLog=...
        uimenu(handles.menuFile,'Label','Execution Log...');
    set(handles.menuFile_itemViewLog,'Callback',...
        {@viewLog_Callback,handles});

    % File->Screenshot
    handles.menuFile_itemScreenShot=...
        uimenu(handles.menuFile,'Label','Screen Shot to Physics Log');
    set(handles.menuFile_itemScreenShot,'Callback',...
        {@screenShot_Callback,handles});

    % File->Quit
    handles.menuFile_itemQuit=...
        uimenu(handles.menuFile,'Label','Quit Wirescans');
    set(handles.menuFile_itemQuit,'Callback',...
        {@quit_Callback,handles});
   
    
    % Add Controls menubar menu
    %
    % Controls menubar menu
    handles.menuControls=uimenu('Label','Controls');
    
    % Controls->LCLS Home = display lcls_main.edl
    handles.menuControls_itemGlobal=...
        uimenu(handles.menuControls,'Label','LCLS Home...');
    set(handles.menuControls_itemGlobal,'Callback',...
        {@controlsScreen_Callback,handles,'lcls_main.edl'});
  
    % Controls->Wire Stripchart = Striptool with wire config file
    %handles.menuControls_itemGlobal=...
    %    uimenu(handles.menuControls,'Label','Wires Stripchart...');
    %set(handles.menuControls_itemGlobal,'Callback',...
    %    {@striptool_Callback,handles});
    
    % Controls->Wire Scanners submenu
    handles.menuControls_smenuWireScanners=uimenu(handles.menuControls);
    set(handles.menuControls_smenuWireScanners,'Label','Wire Screens');
    
    % Controls->Wire Scanners->IN20 = display ws_in20_main.edl
    handles.menuControls_smenuWireScanners_itemIN20=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','IN20...');
    set(handles.menuControls_smenuWireScanners_itemIN20,'Callback',...
        {@controlsScreen_Callback,handles,'ws_in20_main.edl'});
    
    % Controls->Wire Scanners->LI21 = display ws_li21_main.edl
    handles.menuControls_smenuWireScanners_itemLI21=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI21...');
    set(handles.menuControls_smenuWireScanners_itemLI21,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li21_main.edl'});
    
    % Controls->Wire Scanners->LI24 = display ws_li24_main.edl
    handles.menuControls_smenuWireScanners_itemLI24=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI24...');
    set(handles.menuControls_smenuWireScanners_itemLI24,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li24_main.edl'});

    % Controls->Wire Scanners->LI28 = display ws_li27_main.edl
    handles.menuControls_smenuWireScanners_itemLI27=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI27...');
    set(handles.menuControls_smenuWireScanners_itemLI27,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li27_main.edl'});
    
    % Controls->Wire Scanners->LI28 = display ws_li28_main.edl
    handles.menuControls_smenuWireScanners_itemLI28=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI28...');
    set(handles.menuControls_smenuWireScanners_itemLI28,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li28_main.edl'});

    % Controls->Wire Scanners->LTUH = display ws_ltuh_main.edl
    handles.menuControls_smenuWireScanners_itemLTUH=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LTUH...');
    set(handles.menuControls_smenuWireScanners_itemLTUH,'Callback',...
        {@controlsScreen_Callback,handles,'ws_ltuh_main.edl'});
    
    % add LTUS support BTJ 08-06-2020
    % Controls->Wire Scanners->LTUS = display ws_ltus_main.edl
    handles.menuControls_smenuWireScanners_itemLTUS=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LTUS...');
    set(handles.menuControls_smenuWireScanners_itemLTUS,'Callback',...
        {@controlsScreen_Callback,handles,'ws_ltus_main.edl'});
    
    
    %%%%%%%%% No more beam finder wires, should clean this up.....%%%%%%%
    %           no more ws_und1_main.edl file                           %
    
    %Controls->Wire Scanners->UNDH = display ws_undh_main.edl
    handles.menuControls_smenuWireScanners_itemUNDH=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','UNDH...');
    set(handles.menuControls_smenuWireScanners_itemUNDH,'Callback',...
        {@controlsScreen_Callback,handles,'ws_undh_main.edl'});
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % never was DMPH... should clean up?? BTJ 08-06-2020
    % Controls->Wire Scanners->DMPH = display ws_dmph_main.edl
    handles.menuControls_smenuWireScanners_itemDMPH=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','DMPH...');
    set(handles.menuControls_smenuWireScanners_itemDMPH,'Callback',...
        {@controlsScreen_Callback,handles,'ws_dmph_main.edl'});
    
    % Controls->Wire Scanners Stripcharts submenu
    handles.menuControls_smenuWireStripcharts=uimenu(handles.menuControls);
    set(handles.menuControls_smenuWireStripcharts,'Label','Wire Stripcharts');
    
    % Controls->Wire Scanners Stripcharts -> LI28
    handles.menuControls_smenuWireStripcharts_itemLI28=...
        uimenu(handles.menuControls_smenuWireStripcharts,'Label','LI28...');
    set(handles.menuControls_smenuWireStripcharts_itemLI28,'Callback',...
        {@striptool_Callback,handles,'wires_motrandposn_li28.stp'});
    
    % Controls->Wire Scanners Stripcharts -> LTUH
    handles.menuControls_smenuWireStripcharts_itemLTUH=...
        uimenu(handles.menuControls_smenuWireStripcharts,'Label','LTUH...');
    set(handles.menuControls_smenuWireStripcharts_itemLTUH,'Callback',...
        {@striptool_Callback,handles,'wires_motrandposn_ltuh.stp'});
% 
 %  
  %
% % % do i need to replicte the stripchart for LTUS? BTJ 08/06/2020  
  % 
 %
%
    % Add Help menubar item
    %
    handles.menuHelp=uimenu('Label','Help');
    
    % Help->Ad-ops Wiki entry [of wirescans]
    handles.menuHelp_itemWiki=...
        uimenu(handles.menuHelp,'Label','Ad-ops wiki entry...');
    set(handles.menuHelp_itemWiki,'Callback',...
        {@help_Callback,handles});
     
    % Log successful application launch. 
    lprintf(STDOUT,'Instance of Wirescan GUI launched successfully');

catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
       lprintf(STDERR, '%s', ex.getReport());
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Could not complete GUI initialization. %s', ...
            ex.message)));
end

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = wirescan_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user closes wirescan_gui by closing figure.
function wirescan_gui_CloseRequestFcn(hObject, eventdata, handles)

wirescan_const;
EXITMSG=...
   'Wire scan GUI exits by user selection.';
lprintf(STDOUT, EXITMSG);

gui_BSAControl(hObject,handles,0);  %%%%%%%--Release the EDEF after gui exit
util_appClose(hObject);


% --------------------------------------------------------------------
function quit_Callback(hObject, eventdata, handles)
% quit_Callback is called when the File-Exit menu item is selected to 
% exit the GUI. 
%
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close all includes closing the application figure window and hence
% calls wirescan_gui_CloseRequestFcn above. 
close(handles.wirescan_gui);

% ------------------------------------------------------------------------
function progressBar(hObject, handles, tag, ratio)

%POSX=7.6, POSY=34, POSWIDTHFULL=185, POSHEIGHT=0.2;
%pos=[POSX,POSY,POSWIDTHFULL,POSHEIGHT];
pos=get(handles.([tag '_bck']),'Position');
pos(3)=max(0.1,pos(3)*ratio);
set(handles.([tag '_txt']),'BackgroundColor','green');
set(handles.([tag '_txt']),'Position',pos);
if handles.extGui
    pos1=get(handles.extHandle.scanWireProgress_bck, 'Position');
    pos1(3)=max(0.1,pos1(3)*ratio);
    set(handles.extHandle.([tag '_txt']),'Position',pos1)
end

% ------------------------------------------------------------------------
function progressBarInit(hObject, handles, tag)

% POSX=7.6, POSY=34, POSWIDTHFULL=185, POSHEIGHT=0.2;
% pos=[POSX,POSY,POSWIDTHFULL,POSHEIGHT];
pos=get(handles.([tag '_bck']),'Position');
% pos(3)=max(0.1,pos(3)*ratio;
set(handles.([tag '_txt']),'Position',pos);
set(handles.([tag '_txt']),'BackgroundColor',[.94 .94 .94]); % Grey.

% ------------------------------------------------------------------------
% appRemote is called when another application, such as emittance_gui,
% wants to drive a data acquisition of this app.
%
% See appQuery also. appQuery should be used when the other app wants
% to get setup and metadata from this app.
function data = appRemote(hObject, wireName, wireDir, moveAll)

[hObject,handles]=util_appFind('wirescan_gui');
[sector,wireId]=scanWireFind(hObject,handles,wireName);
if ~isempty(sector)
    handles.sector.(sector).wireId=wireId;
end
handles=sectorControl(hObject,handles,sector);
handles=scanWireDirControl(hObject,handles,'xyu','xyu' == wireDir);  % is this setting globally? BTJ 8/6/2020
if nargin < 4, moveAll=0;end
handles.moveAll=moveAll;
acquireStart(hObject,handles);
handles=guidata(hObject);
guidata(hObject,handles);
data=handles.sector.(sector).data(wireId,find('xyu' == wireDir,1));



% ------------------------------------------------------------------------
% appQuery is the API method that allows another app to 
% get data after an acquisition conducted within this app, or to get 
% setup data and metadata from this app.
%
% See also appRemote. appRemote should be used when another application, 
% such as emittance_gui, wants to drive a data acquisition of this app.
%
function data = appQuery(hObject, wireName, wireDir)

[hObject,handles]=util_appFind('wirescan_gui');
[sector,wireId]=scanWireFind(hObject,handles,wireName);
data=handles.sector.(sector).data(wireId,find('xyu' == wireDir,1));


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of index names.
handles.indexList={%
    'LCLS' {'IN20' 'LI21' 'LI24' 'LI28' 'LTUH' 'LTUS'}; % 'UNDH' }; % 'DMPH'}; ...
    'FACET' {'IN10' 'LI11' 'LI12' 'LI18' 'LI19' 'LI20'}; ...
%    'NLCTA' {'NLCTA'}; ...
    'LCLS2' {'IN10'}; ...
  %  
    % I think the line above should be facet2 where the new injector is, not LCLS2
  % Or combine into facet, as in lcls *** BTJ 2/11/20 
%
%    'LCLS2' {'IN10' 'LI11' 'LI14' 'LTU2' 'UNDH' 'UNDS' 'DMPH' 'DMPS'}; ...
    };

% Wire scanner MAD names by sector
%
% 25-Jul-17: Greg. Removed WS36 and WSDUMP per 05JUN17 deck.
handles.sector.IN10.wireMADList={ ... 
     'WS10561'};
handles.sector.LI11.wireMADList={ ...
    'WS11444' 'WS11614' 'WS11744'};
handles.sector.LI12.wireMADList={ ...
    'WS12214'};
handles.sector.LI18.wireMADList={ ...
    'WS18944'};
handles.sector.LI19.wireMADList={ ...
    'WS19144' 'WS19244' 'WS19344'};
handles.sector.LI20.wireMADList={ ... 
     'IPWS1' 'IPWS2' 'IPWS3'};

handles.sector.IN20.wireMADList={ ...
    'WS01' 'WS02' 'WS03' 'WS04'};
handles.sector.LI21.wireMADList={ ...
    'WS11' 'WS12' 'WS13'};
handles.sector.LI24.wireMADList={ ...
    'WS24'};
handles.sector.LI28.wireMADList={ ...
    'WS27644' 'WS28144' 'WS28444' 'WS28744'};
handles.sector.LTUH.wireMADList={ ...
    'WSVM2' 'WSDL31' 'WSDL4' 'WS31' 'WS32' 'WS33' 'WS34'};
handles.sector.LTUS.wireMADList={ ...
    'WS31B' 'WS32B' 'WS33B' 'WS34B'};

%%%%%%%%%%%%%% should remove BFW's and also dump wires %%%%%%%%%%%%%% 
%                                                                   %
handles.sector.UNDH.wireMADList=[ ...
     
    strcat({'BFW'},num2str((1:33)','%02d')); 'BOD10'; 'BOD13'];
handles.sector.DMPH.wireMADList={ ...
    'WSDUMP'};
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% PMT MAD names by sector
%
% 20-Aug-2018, Greg: Added PMT21350 to IN20 and LI21.
handles.sector.IN20.PMTMADList={ ...
    'PMT03' 'PMT04' 'PMT01' ...
    'PMT02' 'PMT05' 'PMT06' 'PMT21350'};
handles.sector.LI21.PMTMADList={ ...
    'PMT11' 'PMT12' 'PMT13' 'PMT21350' ...
    'PMT14' 'PMT15'};
handles.sector.LI24.PMTMADList={ ...
    'PMT24' 'PMT25' 'BLM24707' 'BLM740'};
% LI28:
% 07/Jul/16, Greg: Removed PMT62 
% 29/Nov/17, Greg: Added PMT430,431 .
% 15/Feb/18, Greg: Corrections to 14/Feb/18 CVS commit following tunnel inspection.
% Correct edits are: Remove PMT27644 PMT28144 PMT28444 PMT28744 PMT28750. Add PMT29150 
% 07/Mar/18, Greg: Rename PMT150 to PMT750, per discovery of true location
% 06/Aug/20, Bryce: Add PMT756 and PMT820 to LI28
handles.sector.LI28.PMTMADList={ ... 
    'PMT28750' 'PMT29150' ...
    'PMT756' 'PMT820' };        %%% 06/Aug/20, BTJ add LTUH PMTs to LI28 per FJD
%%%    'BLMH13' 'BLMH16' ...    %%% 06/Aug/20, BTJ add CBLMs at start of HXR per FJD
%%%    'PMT430' 'PMT431' };     %%% FJD sugests to remove these dump pmts BTJ 08/06/20
% LTUH:
% Greg: Removed PMT31 7/7/16. Verified list with Alan.
% Greg, 1/Dec/17: Added PMT756 for Alan's test.  
handles.sector.LTUH.PMTMADList={ ... 
    'PMT122' 'PMT246' 'PMT430' 'PMT431' ...
    'PMT550' 'PMT755' 'PMT756' ...
    'PMT820' 'PMT850' };
%%%    'BLMS26' 'BLMS27' ...    %%% 07/Aug/20, BTJ add CBLMs at start of SXR
%%%    'BLMH13' 'BLMH16' };     %%% 06/Aug/20, BTJ add CBLMs at start of HXR
%%% 'LBLMH' 'LBLMS' ...      %%% placeholder for fibers H/S  
% LTUS:
% 06/Aug/20, Bryce: added section for LTUS PMTs (include LTUH PMTs for now) 
handles.sector.LTUS.PMTMADList={ ... 
    'PMT122' 'PMT246' ...  
    'PMT550' 'PMT755' 'PMT:LTUS:756' ...
    'PMT820' 'PMT850' ...
    'PMT430' 'PMT431'}; 
%%%    'BLMS26' 'BLMS27' ...    %%% 07/Aug/20, BTJ add CBLMs at start of SXR
%%%    'BLMH13' 'BLMH16' };   %%% 06/Aug/20, BTJ add CBLMs at start of HXR
%%% 'LBLM:LTUS:606:A:'};     %%% 10/Aug/20, BTJ add fiber - need MAD name
%%% 'BLMLTUS606A'    <--- MAD name
%%% 'LBLMH' 'LBLMS' ...      %%% placeholder for fibers H/S
% UNDH: 
% Re 'PMT970' 'PMT971' 'PMT1690' Greg: Removed 24-Oct-16.
handles.sector.UNDH.PMTMADList={ 'PMT430' 'PMT431'}; 
    %'PMT970' 'PMT971' 'PMT1690' 
handles.sector.DMPH.PMTMADList={ ...
    'PMT696' 'PMT430' 'PMT431'};        %08/Aug/20 BTJ: PMT696 is PMT:DMPH:696 may no longer exist


% FACET:
handles.sector.IN10.PMTMADList={ ...
    'PMT561'};
handles.sector.LI11.PMTMADList={ ...
    'PMT561' 'PMT444' 'PMT614' 'PMT744'};
handles.sector.LI12.PMTMADList={ ...
    'PMT214'};
handles.sector.LI18.PMTMADList={ ...
    'PMT944'};
handles.sector.LI19.PMTMADList={ ...
    'PMT144' 'PMT244' 'PMT344'};
handles.sector.LI20.PMTMADList={ ... 
     'PMT3060' 'PMT3070' 'PMT3179' 'PMT3350' 'PMT3360'};

% Toroid MAD names by sector
handles.sector.IN20.toroMADList={ ...
    'IM01' 'IM02' 'IM03' 'BPM2'};
handles.sector.LI21.toroMADList={ ...
    'IMBC1I' 'IMBC1O' 'BPMM12'};
handles.sector.LI24.toroMADList={ ...
    'IMBC2I' 'IMBC2O' 'BPM24701'};
handles.sector.LI28.toroMADList={ ...
%    'BPM27701'};
    'BPM2'};
handles.sector.LTUH.toroMADList={ ...
    'BPMVM4' 'BPME31'};
handles.sector.LTUS.toroMADList={ ...
    'BPME33B'}; 
handles.sector.UNDH.toroMADList={ ...
    'RFBU00'};
handles.sector.DMPH.toroMADList={ ...
    'BPMQD'};


handles.sector.IN10.toroMADList={ ...
    'IM10591' 'IM11360'};
handles.sector.LI11.toroMADList={ ...
    'IM10591' 'IM11360'};
handles.sector.LI12.toroMADList={ ...
    'IM10591' 'IM11360' 'IM14890'};
handles.sector.LI18.toroMADList={ ...
    'IM10591' 'IM11360' 'IM14890' 'IM1988' ...
    'IM2040' 'IM2452' 'IM3163' 'IM3255'};
handles.sector.LI19.toroMADList={ ...
    'IM10591' 'IM11360' 'IM14890' 'IM1988' ...
    'IM2040' 'IM2452' 'IM3163' 'IM3255'};
handles.sector.LI20.toroMADList={ ...
    'IM10591' 'IM11360' 'IM14890' 'IM1988' ...
    'IM2040' 'IM2452' 'IM3163' 'IM3255'};



% BPM MAD names by sector
handles.sector.IN20.BPMMADList={ ...
    'BPM9' 'BPM10' 'BPM11' 'BPM13' 'BPM14'};
handles.sector.LI21.BPMMADList={ ...
    'BPMM12' 'BPM21301'};
handles.sector.LI24.BPMMADList={ ...
    'BPM24401' 'BPM24501' 'BPM24601' 'BPM24701'};
handles.sector.LI28.BPMMADList={ ...
    'BPM27201' 'BPM27301' 'BPM27401' 'BPM27501' 'BPM27601' 'BPM27701' ...
    'BPM27801' 'BPM27901' 'BPM28201' 'BPM28301' 'BPM28401'...
    'BPM28501' 'BPM28601' 'BPM28701' 'BPM28801' 'BPM28901'};
handles.sector.LTUH.BPMMADList={ ...
    'BPMEM4' 'BPME31' 'BPME32' 'BPME33' ...
    'BPME34' 'BPME35' 'BPME36' 'BPMUM1' ...
    'BPMVM3' 'BPMVM4' 'BPMDL1' 'BPMT12' ...
    'BPMBSYQ6' 'BPMBSYQA0' 'BPMVM1' 'BPMVM2' 'BPMDL4'};
handles.sector.LTUS.BPMMADList={ ...
    'BPMEM4B' 'BPME33B' 'BPME34B' 'BPMUM1B'};
handles.sector.UNDH.BPMMADList= ...
    strcat({'RFBU'},num2str((1:33)','%02d'));
handles.sector.DMPH.BPMMADList={ ...
    'BPMUE1' 'BPMUE2' 'BPMUE3' 'BPMQD' 'BPMDD'};

handles.sector.IN10.BPMMADList={ ...
    'BPM10525' 'BPM10581'};
%handles.sector.LI11.BPMMADList={ ...
%    'BPM1132' 'BPM11201' 'BPM11265'};
handles.sector.LI11.BPMMADList={};
handles.sector.LI12.BPMMADList={};
handles.sector.LI18.BPMMADList={};
handles.sector.LI19.BPMMADList={};
handles.sector.LI20.BPMMADList={};


% BPM orbit mode indices by sector
handles.sector.IN20.orbitBPMused={...
    [] [] [] []};
handles.sector.LI21.orbitBPMused={...
    [] [] []};
handles.sector.LI24.orbitBPMused={...
    []};
handles.sector.LI28.orbitBPMused={...
    3:6 6:9 9:12 12:15};
handles.sector.LTUH.orbitBPMused={...
    [] [] [] [] []};
handles.sector.LTUS.orbitBPMused={...
    [] [] [] [] []};
handles.sector.UNDH.orbitBPMused=[...
    repmat({1:33},1,33)];
handles.sector.DMPH.orbitBPMused={...
    []};

handles.sector.IN10.orbitBPMused={...
    []};
handles.sector.LI11.orbitBPMused={...
    []};
handles.sector.LI12.orbitBPMused={...
    []};
handles.sector.LI18.orbitBPMused={...
    []};
handles.sector.LI19.orbitBPMused={...
    []};
handles.sector.LI20.orbitBPMused={...
    []};
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% XCor MAD names by sector
handles.sector.IN20.XCorMADList={ ...
    'XC07' 'XC07' 'XC07' 'XC07'};
handles.sector.LI21.XCorMADList={ ...
    'XCM11' 'XCM13' 'XCM13'};
handles.sector.LI24.XCorMADList={ ...
    ''};
handles.sector.LI28.XCorMADList={ ...
    'XC27402' 'XC27702' 'XC28202' 'XC28502'; ...
    'XC27702' 'XC28202' 'XC28502' 'XC28802'; ...
    'XC28202' 'XC28502' 'XC28802' 'XC29302'};
%    'XC27202' 'XC27402' 'XC27802' 'XC28202'};
handles.sector.LTUH.XCorMADList={ ...
    'XCEM2' 'XCEM4' 'XCE33' 'XCE35'; ...
    'XCEM4' 'XCE33' 'XCE35' 'XCUM1'; ...
    'XCE33' 'XCE35' 'XCUM1' 'XCUM4'};
handles.sector.LTUS.XCorMADList={ ...
    'XCEM3B' 'XCEM31B' 'XCXL1' 'XCE33B'; ...
    'XCE35B' 'XCXL2' 'XCUM1B' 'XCUM3B'};
handles.sector.UNDH.XCorMADList=[ ...
    repmat({'XCE33';'XCUM4'},1,35); ...
    ];
handles.sector.DMPH.XCorMADList={''};

handles.sector.IN10.XCorMADList={''};
handles.sector.LI11.XCorMADList={''};
handles.sector.LI12.XCorMADList={''};
handles.sector.LI18.XCorMADList={''};
handles.sector.LI19.XCorMADList={''};
handles.sector.LI20.XCorMADList={''};

% YCor MAD names by sector
handles.sector.IN20.YCorMADList={ ...
    'YC07' 'YC07' 'YC07' 'YC07'};
handles.sector.LI21.YCorMADList={ ...
    'YCM11' 'YCM12' 'YCM12'};
handles.sector.LI24.YCorMADList={ ...
    ''};
handles.sector.LI28.YCorMADList={ ...
    'YC27403' 'YC27703' 'YC28203' 'YC28503'; ...
    'YC27703' 'YC28203' 'YC28503' 'YC28803'; ...
    'YC28203' 'YC28503' 'YC28803' 'YC29303'};
%    'YC27303' 'YC27503' 'YC27703' 'YC28303'};
handles.sector.LTUH.YCorMADList={''};
handles.sector.LTUS.YCorMADList={''};
handles.sector.UNDH.YCorMADList=[ ...
    repmat({'YCE34';'YCUM3'},1,35); ...
    ];
handles.sector.DMPH.YCorMADList={''};

handles.sector.IN10.YCorMADList={''};
handles.sector.LI11.YCorMADList={''};
handles.sector.LI12.YCorMADList={''};
handles.sector.LI18.YCorMADList={''};
handles.sector.LI19.YCorMADList={''};
handles.sector.LI20.YCorMADList={''};

% EPICS Control Screens
% Map for menu item callback to EPICS EDM panel definition file to run.
%CONTROLSMENUTAGS={'global','ltuh'};  % tag value
%CONTROLSMENUSCREENS={'ws_all_main.edl','ws_ltuh_main.edl'}; % EDM screen
%handles.areaToScreenMap=containers.Map(CONTROLSMENUTAGS,...
 %   CONTROLSMENUSCREENS);

% Devices to use and data initialization for each wire scanner by sector
for tag=fieldnames(handles.sector)'
    sector=handles.sector.(tag{:});
    if ~isstruct(sector), continue, end
    sector.wireNameList=model_nameConvert(sector.wireMADList,'EPICS');
    sector.PMTDevList=model_nameConvert(sector.PMTMADList,'EPICS');
    sector.toroDevList=model_nameConvert(sector.toroMADList,'EPICS');
    sector.BPMDevList=model_nameConvert(sector.BPMMADList,'EPICS');
    sector.XCorDevList=model_nameConvert(sector.XCorMADList,'EPICS');
    sector.YCorDevList=model_nameConvert(sector.YCorMADList,'EPICS');
    num=length(sector.wireNameList);
    
    %%% Fix/remove beam finder wires  %%%%%%%%%%%%%%%%%%%%%
    %
    if strcmp(tag,'UNDH')%added to ensure proper numbers
        [handles.BFW.wireDir(1:num).x]=deal(1);
        [handles.BFW.wireDir(1:num).y]=deal(0);
        [handles.BFW.wireDir(1:num).u]=deal(0);
        handles.BFW.wirePulses(1:num)=100;
        [handles.BFW.wireLimit(1:num).x]=deal([-500 500]);
        [handles.BFW.wireLimit(1:num).y]=deal([-500 500]);
        [handles.BFW.wireLimit(1:num).u]=deal([-500 500]);
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sector.wireId=1;
    sector.processBPMUsed=true(num,length(sector.BPMDevList));
    sector.processToroUsed=ones(num,1);
    sector.processPMTUsed=ones(num,1);
    sector.processBPMSel=ones(num,1);
    sector.processXCorCal=ones(num,length(sector.BPMDevList));
    sector.processYCorCal=ones(num,length(sector.BPMDevList));
    sector.processJitterCorr=zeros(num,1);
    sector.scanWirePark=zeros(num,1);
    sector.scanWireMode='wire';
    [sector.data(1:num,1:3).status]=deal(false);
    handles.sector.(tag{:})=sector;
end

% Initialize GUI control values.
handles.scanWireAutoRange=0;
handles.scanWireAutoPulses=0;
handles.scanWireMode='wire';
%handles.scanWirePark=1;
handles.scanWireStepNum=1;
handles.processSelectMethod=1;
handles.sectorSel='IN20';
handles.moveAll=0;
handles.scanWireLimUnits=0;
handles.processDisplayEllipse=0;
handles.fdbkList={'FBCK:INL0:1:ENABLE';'FBCK:INL1:1:ENABLE';'FBCK:IN20:TR01:MODE'; ...
                  'FBCK:L280:1:ENABLE';'FBCK:FB02:TR02:MODE'; ...
                  'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE'};

% Select fields to be saved in config file.
handles.configList={'scanWireAutoRange' 'scanWireStepNum' ...
    'processSelectMethod' 'BFW' 'scanWireAutoPulses'};
handles.sector.configList={'processBPMUsed' 'processToroUsed' ...
    'processJitterCorr' 'scanWireMode' 'scanWirePark' ...
    'processPMTUsed' 'processBPMSel' 'processXCorCal' 'processYCorCal'};

% Initialize indices (a.k.a. facilities).
handles=gui_indexInit(hObject,handles,'Wire Scans');

handles.extGui=0;
handles.extHandle=[];

% Finish initialization.
guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10,'markerSize',13);
handles=appSetup(hObject,handles);
handles=gui_BSAControl(hObject,handles,1);
handles=processInit(hObject,handles);
handles=gui_appLoad(hObject,handles);



% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=gui_indexControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, name)

handles=gui_radioBtnControl(hObject,handles,'sectorSel',name,1,'_btn');
sector=handles.sector.(handles.sectorSel);
if ~isempty(name)
    switch name
        case 'LTUH'
            lcaPutSmart('EVR:LTUH:MC03:EVENT11CTRL.OUT0',0);
            lcaPutSmart('EVR:LTUH:MC03:EVENT12CTRL.OUT0',1);
        case 'LTUS'
            lcaPutSmart('EVR:LTUH:MC03:EVENT11CTRL.OUT0',1);
            lcaPutSmart('EVR:LTUH:MC03:EVENT12CTRL.OUT0',0);
    end
end
set(handles.scanWireName_pmu,'String',sector.wireNameList);
set(handles.processPMT_pmu,'String',sector.PMTDevList);
set(handles.processToroid_pmu,'String',sector.toroDevList);
set(handles.processBPM_lbx,'String',sector.BPMDevList);
handles=scanWireInit(hObject,handles,[]);
handles=scanWireAutoRangeControl(hObject,handles,[]);
% 11-Apr-16 Greg. Since sectorChange always does scanWireInit first, 
% which itself does PulsesControl, should be safe to remove this 
% call. Which fixes doule call of WireScannerSpeedCheck.
% handles=scanWireAutoPulsesControl(hObject,handles,[]);
handles=scanWireModeControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);
progressBarInit(hObject,handles,'scanWireProgress');


% ------------------------------------------------------------------------
function [sector, wireId] = scanWireFind(hObject, handles, wireName)

wireName=model_nameConvert(wireName);
sector='';wireId=0;
for tag=fieldnames(handles.sector)'
    if ~isfield(handles.sector.(tag{:}),'wireNameList'), continue, end
    val=strcmpi(handles.sector.(tag{:}).wireNameList,wireName);
    if any(val)
        sector=tag{:};
        wireId=find(val);
    end
end


% ------------------------------------------------------------------------
function handles = scanWireInit(hObject, handles, wireId)

wirescan_const; % error messages.

try
    % Set wireName control.
    sector=handles.sector.(handles.sectorSel);
    if isempty(wireId)
        wireId=sector.wireId;
    end
    handles.sector.(handles.sectorSel).wireId=wireId;
    handles.scanWireId=wireId;
    set(handles.scanWireName_pmu,'Value',wireId);
    handles.scanWireName=sector.wireNameList{wireId};
    
    handles.isFWS = ismember(handles.scanWireName,...
        { ... % GUN-L3
          'WIRE:IN20:561' 'WIRE:IN20:611' ...
          'WIRE:LI21:285' 'WIRE:LI21:293' ...
          'WIRE:LI21:301' ... 
          'WIRE:LI27:644' 'WIRE:LI28:144' 'WIRE:LI28:444' ...
          'WIRE:LI28:744' ... 
          ... % LTUH
          'WIRE:LTUH:715' 'WIRE:LTUH:735' 'WIRE:LTUH:755' ...
          'WIRE:LTUH:775' 'WIRE:LTUH:122' 'WIRE:LTUH:246' ...
          ... % LTUS 06/Aug/20, BTJ added PVs for WS31b-WS34B
          'WIRE:LTUS:715' 'WIRE:LTUS:735' 'WIRE:LTUS:755' ...
          'WIRE:LTUS:785' ...
        });  
    handles.isBOD = strncmp(handles.scanWireName,'BOD',3);
    
    % Set other wire specific controls.
    handles=processBPMControl(hObject,handles,[]);
    set(handles.processToroid_pmu,'Value',sector.processToroUsed(wireId));
    set(handles.processPMT_pmu,'Value',sector.processPMTUsed(wireId)); 
    set(handles.processJitterCorr_box,'Value',sector.processJitterCorr(wireId));
    handles=scanWireParkControl(hObject,handles,[]);
    
    % Get wire status.
    handles=scanWireDirControl(hObject,handles,'xyu',[]);
    handles=scanWireLimitControl(hObject,handles,'xyu',1:2,[]);
    
    % If scanning a fast wire, run pre scan status check, since fast wires
    % known to stick, requiring reinit; and init MATLAb model.
    if handles.isFWS
        model_init('source','MATLAB');
        % wirescan_initFWS(handles.scanWireName);
    end
    
    if handles.isBOD
        status='Ready to scan BOD';
    elseif strcmp(handles.sectorSel,'UNDH')
        status='Ready to scan BFW';
    % elseif handles.isFWS
    %    status='READY to START Wire Scan';
    else
        status = char(char(lcaGetSmart([handles.scanWireName ':SCANTEXT'])));
    end
    %%%1 set(handles.scanWireStatus_txt,'String',status);
    if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',status), end
    status = sprintf('%s initialization completed. IOC status: %s',handles.scanWireName,status ); 
    gui_statusDisp(handles.scanWireStatus_txt, lprintf(STDOUT,status)); 

    handles=processUpdate(hObject,handles);
    
catch ex
    % If exception was generated by MATLAB then treat as internal error 
    % so print stacktrace to stderr for help debugging.
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s', ex.getReport());
    end
    % Issue and throw contextual exception (ie say what we were trying to
    % do)
    error('WS:SECTORINITERROR',[ WS_SECTORINITERROR_MSG '; ' ex.message ]);
end


% ------------------------------------------------------------------------
function handles = scanWireModeControl(hObject, handles, val)

modes={'wire' 'step' 'orbit'};
handles.scanWireMode=handles.sector.(handles.sectorSel).scanWireMode;
handles=gui_popupMenuControl(hObject,handles,'scanWireMode',val,modes,modes,1);
handles.sector.(handles.sectorSel).scanWireMode=handles.scanWireMode;

sector=handles.sector.(handles.sectorSel);
wireId=handles.scanWireId;
switch handles.scanWireMode
    case {'wire' 'step' 'orbit'}
        set(handles.processBPM_lbx,'Style','listbox','Value',find(sector.processBPMUsed(wireId,:)));
        set(handles.scanCalibrate_btn,'Visible','off');
    case 'corr'
        set(handles.processBPM_lbx,'Style','popupmenu','Value',sector.processBPMSel(wireId));
        set(handles.scanCalibrate_btn,'Visible','on');
end
h=[handles.scanRMatCalib_btn handles.scanBFWtestMode_box handles.scanRMatReset_btn];
set(h,'Visible','off');
if strcmp(handles.scanWireMode,'orbit') && strcmp(handles.sectorSel,'UNDH')
    set(h,'Visible','on');
end
handles=scanWireStepNumControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = dataPlaneControl(hObject, handles, tag)

if isempty(tag), tag='x';end
handles=gui_radioBtnControl(hObject,handles,'dataPlane',tag);
scanPlot(hObject,handles);
processPlot(hObject,handles);


% ------------------------------------------------------------------------
function handles = scanBFWDirControl(hObject, handles, tag, val)

if isempty(val)
    for j=1:length(tag)
        val(j)=handles.BFW.wireDir(handles.scanWireId).(tag(j));
    end
end

for j=1:length(tag)
    handles.BFW.wireDir(handles.scanWireId).(tag(j))=logical(val(min(j,end)));
    handles.scanWireDir.(tag(j))=logical(val(min(j,end)));
    set(handles.(['scanWire' upper(tag(j)) '_box']),'Value',val(min(j,end)));
end

if any(val)
    handles=dataPlaneControl(hObject,handles,tag(find(val == 1,1)));
end
guidata(hObject,handles);

%if ~val || strcmp(handles.scanWireMode,'wire'), return, end
if ~any(val)
    scanPlot(hObject,handles);
    processPlot(hObject,handles);
end
if ~all(val), return, end
handles=scanWireDirControl(hObject,handles,setdiff('xyu',tag),0);


% ------------------------------------------------------------------------
function handles = scanWireDirControl(hObject, handles, tag, val)

if strcmp(handles.sectorSel,'UNDH')
    handles=scanBFWDirControl(hObject,handles,tag,val);
    return
end

pv=strcat(handles.scanWireName,':USE',upper(cellstr(tag(:))),'WIRE');
if isempty(val)
    val=double(lcaGetSmart(pv,0,'double') == 1);
else
    lcaPutSmart(pv,double(val(:)));
end
for j=1:length(tag)
    handles.scanWireDir.(tag(j))=logical(val(min(j,end)));
    set(handles.(['scanWire' upper(tag(j)) '_box']),'Value',val(min(j,end)));
end
if any(val)
    handles=dataPlaneControl(hObject,handles,tag(find(val == 1,1)));
end
guidata(hObject,handles);

%if ~val || strcmp(handles.scanWireMode,'wire'), return, end
if ~any(val)
    scanPlot(hObject,handles);
    processPlot(hObject,handles);
end
if ~all(val) || strcmp(tag,'xyu'), return, end
if ~handles.isFWS  
    handles=scanWireDirControl(hObject,handles,setdiff('xyu',tag),0);
end

% Reevaluate Auto selected number of pulses.
scanAutoPulses(hObject, handles);




% ------------------------------------------------------------------------
function [flag, speed, range] = scanWireSpeedCheck(hObject, handles)
 
wirescan_const; % WS_INVALIDWIRESPEED
tooStr={'fast' 'slow'};
cols={'default' 'red'};
loc={'Inner' 'Outer'};
tag='xyu';

guimsg='';
dname=handles.scanWireName;
n=handles.scanWirePulses;
range=diff(cell2mat(struct2cell(handles.scanWireLimit)),1,2);
rate=lcaGetSmart(handles.beamRatePV);
speedMax=lcaGetSmart([handles.scanWireName ':MOTR.VMAX']);
speedMin=lcaGetSmart([handles.scanWireName ':MOTR.VBAS']);
speed=(range/n)*rate; % [ um / s ]
flagSlow=speed < speedMin;
flag=(speed > speedMax) | flagSlow;

set(handles.scanWirePulses_txt,'ForegroundColor',cols{any(flag)+1});
for k=1:length(flag)
    for j=1:2
        str=['scanWire' upper(tag(k)) loc{j} '_txt'];
        set(handles.(str),'ForegroundColor',cols{flag(k)+1});
    end
    if flag(k) 
        guimsg = sprintf(...
         '%s wire %s speed too %s ~ (%8.2f <= %8.2f <= %8.2f) [um/s].',...
          dname, tag(k), tooStr{any(flagSlow)+1}, ...
          speedMin, speed(k), speedMax);
        % gui_statusDisp(handles.scanWireStatus_txt, status);
        lprintf(STDOUT, WS_INVALIDWIRESPEED_MSG, guimsg);
    end
end

if any(flag)
    planesOutOfRange=tag(flag);
    if length(planesOutOfRange) > 1
        guimsg=...
           [ planesOutOfRange ' planes speeds out of recommended range ' ];
    else
        guimsg=...
           [ planesOutOfRange ' plane speed too ' tooStr{any(flagSlow)+1}];
    end
    guimsg=sprintf('%s %s (speed=range/Npules*rate [um/s])', ...
        dname, guimsg);   
    gui_statusDisp(handles.scanWireStatus_txt, lprintf(STDERR,guimsg)); 
end


% Issue IOCs status
guimsg = sprintf('%s speed check completed. IOC status: %s',...
    dname,char(lcaGetSmart([handles.scanWireName ':SCANTEXT']))); 
% status=char(status); % regularize status to char array for issuing message.
gui_statusDisp(handles.scanWireStatus_txt, lprintf(STDOUT,guimsg));
% set(handles.scanWireStatus_txt,'String',status);
% update ext GUI status (w/o full info)
if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',guimsg), end

% if any(flag)
%     warning('WS:INVALIDWIRESPEED', WS_INVALIDWIRESPEED, status);
% end



% ------------------------------------------------------------------------
function handles = scanBFWPulsesControl(hObject, handles, val)

if any(isnan(val))
    val=handles.scanWirePulses;
end
if isempty(val)
    val=handles.BFW.wirePulses(handles.scanWireId);
end
handles.BFW.wirePulses(handles.scanWireId)=val;
handles.scanWirePulses=val;
set(handles.scanWirePulses_txt,'String',num2str(val));
set(handles.scanWirePulses_txt,'TooltipString','');
guidata(hObject,handles);
%scanWireSpeedCheck(hObject,handles);


% ------------------------------------------------------------------------
function handles = scanWirePulsesControl(hObject, handles, val)
% Gets or sets the number of beam pulses over which to make wire scan in
% each plane.

wirescan_const;

if strcmp(handles.sectorSel,'UNDH')
    handles=scanBFWPulsesControl(hObject,handles,val);
    return
end

pv=[handles.scanWireName ':SCANPULSES'];
if isempty(val) || any(isnan(val))
    val=lcaGetSmart(pv);
else
    lcaPut(pv,val);
end
handles.scanWirePulses=val;
set(handles.scanWirePulses_txt,'String',num2str(val));
set(handles.scanWirePulses_txt,'TooltipString',pv);
guidata(hObject,handles);
scanWireSpeedCheck(hObject,handles);


% ------------------------------------------------------------------------ 
function handles = scanWireLimUnitsControl(hObject, handles, val)
% Interface for the "lim units" checkbox. "lim Units" refers to the units
% in which the wire scan range limits are expressed.

handles=gui_checkBoxControl(hObject,handles,'scanWireLimUnits',val);
handles=scanWireLimitControl(hObject,handles,'xyu',1:2,[]);


% ------------------------------------------------------------------------
function handles = scanBFWLimitControl(hObject, handles, tag, pos, val)

if isempty(val) || any(isnan(val))
    val=zeros(numel(tag),numel(pos));
    for k=1:numel(tag)
        val(k,:)=handles.BFW.wireLimit(handles.scanWireId).(tag(k))(pos);
    end
else
    val=round(val);
end

loc={'Inner' 'Outer'};
for k=1:numel(tag)
    handles.BFW.wireLimit(handles.scanWireId).(tag(k))(pos)=val(k,:);
    handles.scanWireLimit.(tag(k))(pos)=val(k,:);
    for j=1:length(pos)
        str=['scanWire' upper(tag(k)) loc{pos(j)} '_txt'];
        set(handles.(str),'String',num2str(val(k,j)));
        set(handles.(str),'TooltipString','');
    end
end
handles=scanWirePulsesControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = scanWireLimitControl(hObject, handles, tag, pos, val)

if strcmp(handles.sectorSel,'UNDH')
    handles=scanBFWLimitControl(hObject,handles,tag,pos,val);
    return
end
isPos=handles.scanWireLimUnits;
if isPos, data=scanReadWireData(hObject,handles);end

loc={'Inner' 'Outer'};
pv=cell(numel(tag),numel(pos));
for k=1:numel(tag)
    pv(k,:)=strcat(handles.scanWireName,':',upper(tag(k)),'WIRE',upper(loc(pos)'));
end
if isempty(val) || any(isnan(val))
    val=reshape(lcaGetSmart(pv(:)),numel(tag),[]);
else
    if isPos && any(gcbo) && regexp(get(gcbo,'Tag'),'scanWire(X|Y|U)(Inner|Outer)_txt')
        val=pos2wire(data,val);val=val.(tag(1));
    end
    lim=lcaGetSmart(strcat(handles.scanWireName,':MOTR.',{'LLM';'HLM'}));
    val=round(min(max(lim(1),val),lim(2)));
    lcaPut(pv(:),val(:));
end
for k=1:numel(tag)
    handles.scanWireLimit.(tag(k))(pos)=val(k,:);
    if isPos, val2=wire2pos(data,val(k,:));val(k,:)=round(val2.(tag(k)));end
    for j=1:length(pos)
        str=['scanWire' upper(tag(k)) loc{pos(j)} '_txt'];
        set(handles.(str),'String',num2str(val(k,j)));
        set(handles.(str),'TooltipString',pv{k,j});
    end
end
handles=scanWirePulsesControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = processBPMControl(hObject, handles, val)

switch handles.scanWireMode
    case {'wire' 'step' 'orbit'}
        if isempty(val)
            val=handles.sector.(handles.sectorSel).processBPMUsed(handles.scanWireId,:);
        end
        lval=false(1,size(handles.sector.(handles.sectorSel).processBPMUsed,2));
        lval(val)=true;
        handles.sector.(handles.sectorSel).processBPMUsed(handles.scanWireId,:)=lval;
        set(handles.processBPM_lbx,'Value',find(lval));
    case 'corr'
        if isempty(val)
            val=handles.sector.(handles.sectorSel).processBPMSel(handles.scanWireId);
        end
        handles.sector.(handles.sectorSel).processBPMSel(handles.scanWireId)=val;
        set(handles.processBPM_lbx,'Value',val);
end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataMethodControl(hObject, handles, iVal, nVal)

if isempty(iVal)
    iVal=handles.processSelectMethod;
end
handles=gui_sliderControl(hObject,handles,'dataMethod',iVal,nVal);

handles.processSelectMethod=iVal;
guidata(hObject,handles);
processPlot(hObject,handles);


% ------------------------------------------------------------------------
function handles = scanWireParkControl(hObject, handles, val)

handles.scanWirePark=handles.sector.(handles.sectorSel).scanWirePark(handles.scanWireId);
handles=gui_checkBoxControl(hObject,handles,'scanWirePark',val);
handles.sector.(handles.sectorSel).scanWirePark(handles.scanWireId)=handles.scanWirePark;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = scanWireStepNumControl(hObject, handles, val)

vis=ismember(handles.scanWireMode,{'step' 'orbit'});
handles=gui_editControl(hObject,handles,'scanWireStepNum',val,1,vis,1);


% ------------------------------------------------------------------------
function handles = scanWireAutoRangeControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'scanWireAutoRange',val);


% ------------------------------------------------------------------------
function handles = scanWireAutoPulsesControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'scanWireAutoPulses',val,~strcmp(handles.sectorSel,'UNDH'));
handles=scanAutoPulses(hObject, handles);


% ------------------------------------------------------------------------
function [tag, id, use, tagList] = scanWireCurrentDir(hObject, handles, order)

use=cell2mat(struct2cell(handles.scanWireDir));
id=find(use,1);
tagList='xyu';tag=tagList(id);tagList=tagList(use);
if any(use) && nargin > 2 && strcmp(order,'sort')
    scanDir=lcaGetSmart(strcat(handles.scanWireName,':SCANTOCENTER'),0,'double');
    str={'ascend' 'descend'};
    range=cell2mat(struct2cell(handles.scanWireLimit));
    range(~use,:)=Inf*(1-2*scanDir);
    [d,id]=sort(range(:,1),1,str{scanDir+1});
    id(~ismember(id,find(use)))=[];
    tagList='xyu';tagList=tagList(id);id=id(1);tag=tagList(1);
end


% ------------------------------------------------------------------------
function scanWireMove(handles, name, val)

wirescan_const; % Application specific include file

countOld=lcaGetRetryCount;
lcaSetRetryCount(60/lcaGetTimeout);
pv=strcat(name,':MOTR');
if any(isinf(val))
    if any(sign(val) == 1), str='HI';else str='LO';end
    pv=strcat(Sacquirename,':MOTR',str,'.PROC');
    val=1;
end
% Check for stalled motor and toggle SPMG field.
nTry=10;
while nTry && ~all(lcaGetSmart(strcat(name,':MOTR.DMOV')))
    lcaPutNoWait(strcat(name,':MOTR.SPMG'),0);
    pause(2);
    nTry=nTry-1;
end
try
    lcaPut(strcat(name,':MOTR.SPMG'),3);pause(.1);
    lcaPut(pv,val);
catch ex
    gui_statusDisp(handles.scanWireStatus_txt, ...
        lprintf(STDERR, 'Wire motion error'));
end
lcaSetRetryCount(countOld);
lcaPut(strcat(name,':MOTR.STOP'),1);


% ------------------------------------------------------------------------
function scanBFWInOut(name, val)

isBOD=any(strncmp(name,'BOD',3));
if any(val) && ~isBOD, lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);end
if isBOD
    countOld=lcaGetRetryCount;
    lcaSetRetryCount(60/lcaGetTimeout);
    str={'EXTRACT';'INSERT'};
    try
        lcaPut(strcat(name,':',str(val+1),'.PROC'),1); 
    catch
    end
    lcaSetRetryCount(countOld);
else
    lcaPut(strcat(name,':ACTC'),val); 
end
if ~any(val) && ~isBOD, lcaPut('IOC:BSY0:MP01:BYKIKCTL',1);end


% ------------------------------------------------------------------------
function handles = scanWireInsert(hObject, handles, wireDir)

if strcmp(handles.sectorSel,'UNDH')
    if get(handles.scanBFWtestMode_box,'Value'), return, end
    name=handles.scanWireName;val=1;
    if handles.isBOD
        name={'BOD:UNDH:1005';'BOD:UNDH:1305'};
        val=double(strcmp(name,handles.scanWireName));
    end
    scanBFWInOut(name,val);
    return
end

if nargin < 3, wireDir=scanWireCurrentDir(hObject,handles,'sort');end
name=handles.scanWireName;
scanDir=lcaGetSmart(strcat(name,':SCANTOCENTER'),0,'double');
if ismember(handles.sectorSel,{'LI28'}) && handles.moveAll
    nExcl={};
    if ~ismember(name,nExcl)
        name=handles.sector.(handles.sectorSel).wireNameList(:);
        name(ismember(name,nExcl))=[];
    end
end
str={'INNER' 'OUTER'};
pv=strcat(name,':',upper(wireDir),'WIRE',str{scanDir+1});
val=lcaGetSmart(pv);
if ismember(handles.sectorSel,{'LI28'}) && ~handles.moveAll
    name=[name;setdiff(handles.sector.(handles.sectorSel).wireNameList(:),name)];
%    val=[val;repmat(-10000,numel(name)-1,1)];
    val(2:numel(name),1)=-8000;
end
scanWireMove(handles,name,val);
%scanWireMove(handles,handles.scanWireName,handles.scanWireLimit.(wireDir)(1));


% ------------------------------------------------------------------------
function handles = scanWireRetract(hObject, handles)

if strcmp(handles.sectorSel,'UNDH')
    if get(handles.scanBFWtestMode_box,'Value'), return, end
    scanBFWInOut(handles.scanWireName,0);
    return
end

if handles.isFWS
    % 13-Nov-17, Greg: Replace MOTR_HOME_CMD with MOTR_RETRACT. The
    % latter additionally disables the motor control, putting it in
    % open loop.
    % lcaPut(strcat(handles.scanWireName,':MOTR_HOME_CMD'),1);
    % lcaPut(strcat(handles.scanWireName,':MOTR_RETRACT'),1);
    wirescan_termFWS(handles.scanWireName);
else
    posOut=20000;
    if strcmp(handles.sectorSel,'LI20'), posOut=25000;end
    if strcmp(handles.scanWireName,'WIRE:LI20:3206'), posOut=65000;end
    scanWireMove(handles,handles.scanWireName,posOut);
end
%scanWireMove(handles,handles.scanWireName,Inf);


% ------------------------------------------------------------------------
function handles = scanWireSynch(hObject, handles)

if strcmp(handles.sectorSel,'UNDH') || strcmp(handles.scanWireMode,'orbit'), return, end
if handles.isFWS, return, end %skip if special (No... this needs to happen but use encoder instead.
lcaPut([handles.scanWireName ':MOTR.STOP'],1);
pause(2);
lvdt=lcaGetSmart([handles.scanWireName ':LVPOS']);
if lvdt < lcaGetSmart([handles.scanWireName ':MOTR.HLM'])
    lcaPut([handles.scanWireName ':MOTR.SET'],1);
    lcaPut([handles.scanWireName ':MOTR'],lvdt);
    lcaPut([handles.scanWireName ':MOTR.SET'],0);pause(.5);
end


% ------------------------------------------------------------------------
function handles = scanAutoPulses(hObject, handles)

wirescan_const; % STDERR
persistent NOMINALRATE;
persistent MINRATE;             % Lowest rate at which param estimates work 
persistent ZERORATE_MSG;        % Can't compute estimate since now 0 rate
persistent BOUNDTOMINRATE_MSG;  % Warning usinfg setup at min rate.
NOMINALRATE=120;
MINRATE=10;
ZERORATE_MSG = ['Can''t estimate pulses to scan over since repetition '...
    'rate is presently zero. Leaving number of scan pulses unchanged.'];
BOUNDTOMINRATE_MSG = ['Rate of %3.1 is too low for sensibly automatically setting '...
    'number of pulses over which to scan. Using config as if %3.1f Hz.' ];

if ~handles.scanWireAutoPulses || strcmp(handles.sectorSel,'UNDH'), return, end

% Get current beam rate, and selected wire max velocity.
rate=lcaGetSmart(handles.beamRatePV);
if ~(rate > 0)  
    lprintf(STDERR, ZERORATE_MSG);
    return;
end

% Min velocity = 50 um/sec.
vmax=lcaGetSmart(strcat(handles.scanWireName,':MOTR.VMAX'));
vmin=lcaGetSmart(strcat(handles.scanWireName,':MOTR.VBAS'));

% Get selected wire scan range.
if handles.scanWireDir.x
    limits=handles.scanWireLimit.x;
elseif handles.scanWireDir.y
    limits=handles.scanWireLimit.y;
elseif handles.scanWireDir.u
    limits=handles.scanWireLimit.u;
end
range=abs(diff(limits));

% If extant rate is less than the rate which can sensibly be used for
% estimatng number of pulses to scan at, then bind the rate to use for num
% pulses estimate to a lower limit (MINRATE).
if rate < MINRATE
    lprintf(STDERR, sprintf( BOUNDTOMINRATE_MSG, rate, MINRATE));
    rate = MINRATE;
end

% Minpulses is the # of points such that the wire moves at 98% of vmax.
minpulses=ceil(range*rate/(0.98*vmax));
% Maxpulses is the # of points such that the wire moves at 102% of vmin.
maxpulses=floor(range*rate/(1.02*vmin));

% Calculate a reasonable number of pulses to scan. Start with a nominal
% number of 100, or 250 for fast wire scanners, assuming the nominal rate
% (120 Hz). Then scale to the actual rate. Finally check the interval, and
% if outside set to an interval bound.
nPulses_nom=100;
if handles.isFWS, nPulses_nom=250;end
nPulses_scaledToRate = ceil(nPulses_nom*rate/NOMINALRATE);    
nPulses = max(minpulses,min(maxpulses,nPulses_scaledToRate));

handles = scanWirePulsesControl(hObject,handles,nPulses);


% ------------------------------------------------------------------------
function handles = scanAutoRange(hObject, handles)

if ~handles.scanWireAutoRange, return, end

% Read wire scanner data.
data=scanReadWireData(hObject,handles);
sector=handles.sector.(handles.sectorSel);

% Read BPM data.
selectBPM=sector.processBPMUsed(handles.scanWireId,:);
if ~epicsSimul_status
    sampleNum=5;
    eDefParams(handles.eDefNumber,1,sampleNum);
    eDefOn(handles.eDefNumber);nTry=100;
    while ~eDefDone(handles.eDefNumber) && nTry, nTry=nTry-1;pause(.1);end
    if ~nTry, return, end % timed out, no valid data to get
    data=scanReadBSAData(hObject,handles,data,1,sampleNum);
    pvList=strcat(data.BPMList(:),':TMITHST',num2str(handles.eDefNumber));
    data.BPMTData=lcaGetSmart(pvList,sampleNum);
else
    data.BPMXData=lcaGetSmart(strcat(data.BPMList(:),':X'));
    data.BPMYData=lcaGetSmart(strcat(data.BPMList(:),':Y'));
    data.BPMTData=lcaGetSmart(strcat(data.BPMList(:),':TMIT'));
end
if ~all(all(data.BPMXData(selectBPM,:))), return, end
BPMXData=mean(data.BPMXData(selectBPM,:),2); % BPM in mm
BPMYData=mean(data.BPMYData(selectBPM,:),2);

% Calculate beam position at wire.
rMat=data.rMatList(:,:,selectBPM);
posX=beamAnalysis_orbitFit([],rMat(1:2,[1:2 6],:),BPMXData*1e-3); % in m
posY=beamAnalysis_orbitFit([],rMat(3:4,[3:4 6],:),BPMYData*1e-3);
WSPos=xy2pos(data,posX(1,:)*1e6,posY(1,:)*1e6); % Beam position in wire coordinates (um)

% Get new wire range centers.
val=pos2wire(data,WSPos);
for tag='xyu'
    range=diff(data.wireLimit.(tag));
    lim=val.(tag)+[-1 1]*range/2;
    if any(isinf(lim)), continue, end
    handles=scanWireLimitControl(hObject,handles,tag,1:2,lim);
end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function data = scanReadAidaBSA(hObject, handles, data, j, num)

if nargin < 3, data=[];end
if nargin < 4, j=1;end
if nargin < 5, num=0;end

% Limit to 30 sec acquisition time to avoid time out.
rate=lcaGetSmart(handles.beamRatePV);
num=min(num,15*rate);

if isempty(data)
    sector=handles.sector.(handles.sectorSel);
    data.toroList=sector.toroDevList;
    data.BPMList=sector.BPMDevList;
    data.toroData(:,:,j)=zeros(numel(data.toroList),num);
end

% Get Aida buffered data.
[x,y,tmit,pulseId]=control_bpmAidaGet(data.BPMList,num,'57');

[is,id]=ismember(data.toroList,data.BPMList);
data.pulseId(1,:,j)=pulseId(1,:);
data.BPMXData(:,:,j)=x;
data.BPMYData(:,:,j)=y;
data.toroData(is,:,j)=tmit(id(is),:);


% ------------------------------------------------------------------------
function data = scanReadWireData(hObject, handles)

% Read wire scanner data
data.status=false;
data.name=handles.scanWireName;
data.ts=now;
data.wireMode=handles.scanWireMode;
data.wireName=handles.scanWireName;
data.wireDir=handles.scanWireDir;
data.wireLimit=handles.scanWireLimit;
pvList=strcat(data.wireName,':',[{'INSTALLANGLE' 'SCANTOCENTER'} ...
    strcat({'X' 'Y' 'U'},'WIREOFFSET')]');
if strcmp(handles.sectorSel,'UNDH')
    wireDir=scanWireCurrentDir(hObject,handles);
    val=[90*(wireDir == 'x') 0 0 0 0]';
    pvList=strcat(data.wireName,':',{'X' 'Y'},'OFFSET')';
    if ~handles.isBOD
        val(3:4)=-lcaGetSmart(pvList,0,'double'); % BFW offsets have opposite polarity
    else val(3:4)=0;
    end
else
    val=lcaGetSmart(pvList,0,'double');
end
%val=[val;20;20;20]; % Dummies for wire diameter
val=[val;12.5;12.5;12.5]; % Dummies for wire diameter, LTUH 12.5 microns
data.wireAngle=val(1);
data.wireScanDir=val(2);
data.wireCenter.x=val(3);
data.wireCenter.y=val(4);
data.wireCenter.u=val(5);
data.wireSize.x=val(6);
data.wireSize.y=val(7);
data.wireSize.u=val(8);

sector=handles.sector.(handles.sectorSel);
data.PMTList=sector.PMTDevList;
data.toroList=sector.toroDevList;
data.BPMList=sector.BPMDevList;

% Get R matrices
data.rMatList=model_rMatGet(data.wireName,data.BPMList);


% ------------------------------------------------------------------------
function data = scanReadBSAData(hObject, handles, data, j, num)

if nargin < 4, j=1;end

% Test for util_readPVHst
%{
if nargin < 5, num=0;end
eDef=handles.eDefNumber;
pv=util_readPVHst(strcat(data.wireName,{':POSN';':MASK'}),eDef,0,num);
data.ts=pv(1).ts;
data.wireData(1,:,j)=pv(1).val;
data.wireMask(1,:,j)=pv(2).val == 1;

pv=util_readPVHst(strcat(data.PMTList(:),':QDCRAW'),eDef,0,num);
data.PMTData(:,:,j)=vertcat(pv.val);

pv=util_readPVHst(strcat(data.toroList(:),':TMIT'),eDef,0,num);
data.toroData(:,:,j)=vertcat(pv.val);

pv=util_readPVHst(strcat(data.BPMList(:),':X'),eDef,0,num);
data.BPMXData(:,:,j)=vertcat(pv.val);
pv=util_readPVHst(strcat(data.BPMList(:),':Y'),eDef,0,num);
data.BPMYData(:,:,j)=vertcat(pv.val);
%}
% End test.

% Get eDef stuff.
eDefNumStr=num2str(handles.eDefNumber);
pulseIdPV=sprintf('PATT:%s:1:PULSEIDHST%s',handles.system,eDefNumStr);
if nargin < 5
    num=lcaGetSmart([pulseIdPV '.NUSE']);
end

% Read wire position data.
pvList=strcat(data.wireName,':POSNHST',eDefNumStr);
if strcmp(handles.sectorSel,'UNDH')
    pvList=strcat(data.PMTList(end),':QDCRAWHST',eDefNumStr);
end
[data.wireData(1,:,j),ts]=lcaGetSmart(pvList,num);
if ~epicsSimul_status, data.ts=lca2matlabTime(ts);end
if strcmp(handles.sectorSel,'UNDH')
    wireDir=scanWireCurrentDir(hObject,handles);
    geo=girderGeo;z=geo.bfwz;
    if handles.isBOD, z=geo.bodz;end
    bfwName=model_nameConvert(data.wireName,'MAD');
    pos=girderAxisFind(str2double(bfwName(4:5)),z,geo.quadz);
    data.wireData(1,:,j)=pos(wireDir == 'xy')*1e3; % in mm
end
pvList=strcat(data.wireName,':MASKHST',eDefNumStr);
if strcmp(handles.sectorSel,'UNDH')
    pvList=strcat(data.PMTList(1),':QDCRAWHST',eDefNumStr);
    data.wireMask(1,:,j)=true(size(lcaGetSmart(pvList,num)));
else
%    data.wireMask(1,:,j)=logical(lcaGetSmart(pvList,num));
    if handles.isFWS %MASKHST is == 1 for 'WIRE:LTUH:775-7'
        data.wireMask(1,:,j) = true(1,num);
    else
        data.wireMask(1,:,j)=lcaGetSmart(pvList,num) == 1;
    end
end

% Read PMT data.
pvList=strcat(data.PMTList(:),':QDCRAWHST',eDefNumStr);
data.PMTData(:,:,j)=lcaGetSmart(pvList,num);

data.status=true;

%{
% Return if Aida BPM data already taken.
if strncmp(data.BPMList{1},'LI',2)
    data.pulseId=lcaGetSmart(pulseIdPV,num);
    return
end
%}

% Read toroid data.
pvList=strcat(data.toroList(:),':TMITHST',eDefNumStr);
data.toroData(:,:,j)=lcaGetSmart(pvList,num);

% Read BPM data.
pvList=strcat(data.BPMList(:),':XHST',eDefNumStr);
data.BPMXData(:,:,j)=lcaGetSmart(pvList,num);
pvList=strcat(data.BPMList(:),':YHST',eDefNumStr);
data.BPMYData(:,:,j)=lcaGetSmart(pvList,num);


% ------------------------------------------------------------------------
function handles = scanReadData(hObject, handles, data)

% Simulate data.
if epicsSimul_status
    data=wirescan_simulScan(data,handles.scanWirePulses);
end
data.status=true;

% Put acquired data in storage.
sector=handles.sector.(handles.sectorSel);
[tag,id,use]=scanWireCurrentDir(hObject,handles);
for tag=fieldnames(data)'
    [sector.data(handles.scanWireId,use).(tag{:})]=deal(data.(tag{:}));
end
handles.sector.(handles.sectorSel)=sector;
handles=processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processInit(hObject, handles)

handles.process.chargeNorm=0;
handles.processDisplayDispersion=0;
handles.processDisplaySel=1;  % Changed from 0 by Greg 12-Apr-16
handles=plotInit(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [handles, data] = scanCorrInit(hObject, handles)

% Read wire scanner data.
data=scanReadWireData(hObject,handles);
sector=handles.sector.(handles.sectorSel);
[wireDir,wireDirId]=scanWireCurrentDir(hObject,handles);

% Set motor and disable feedback.
%lcaPut([handles.scanWireName ':MOTR'],data.wireCenter.(wireDir));
lcaPut([handles.scanWireName ':MOTR'],mean(data.wireLimit.(wireDir)));

handles.fdbkStat=lcaGetSmart(handles.fdbkList,0,'double');
lcaPut(handles.fdbkList,0);

% Set corrector values.
handles.scanCorrName=sector.([upper(wireDir) 'CorDevList']){handles.scanWireId};
handles.scanCorrPV=[handles.scanCorrName ':BCTRL'];
handles.scanCorrVal=lcaGetSmart(handles.scanCorrPV);
handles.scanCorrNum=round(handles.scanWirePulses/10);
[rMat,en]=model_rMatGet(handles.scanCorrName,handles.scanWireName,[],{'R' 'EN'});
r12=rMat(1+wireDirId*2-2,2+wireDirId*2-2);
range=wire2pos(data,handles.scanWireLimit);
bp=en/299.792458*1e4; % kG m
corrLimit=num2cell(range.(wireDir)*1e-6/r12*bp); % kG m
handles.scanCorrValList=handles.scanCorrVal+linspace(corrLimit{:},handles.scanCorrNum);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [handles, data] = scanOrbitInit(hObject, handles)

% Read wire scanner data.
data=scanReadWireData(hObject,handles);
sector=handles.sector.(handles.sectorSel);
[wireDir,wireDirId]=scanWireCurrentDir(hObject,handles);

% Set motor and disable feedback.
%lcaPut([handles.scanWireName ':MOTR'],data.wireCenter.(wireDir));
%lcaPut([handles.scanWireName ':MOTR'],mean(data.wireLimit.(wireDir)));

fdbkList=handles.fdbkList(end-1:end);
if strcmp(handles.sectorSel,'LI28'), fdbkList=handles.fdbkList(4:5);end
handles.fdbkStat=lcaGetSmart(fdbkList,0,'double');
lcaPut(fdbkList,0);

% Set corrector values.
handles.scanCorrName=sector.([upper(wireDir) 'CorDevList'])(:,handles.scanWireId);
handles.scanCorrPV=strcat(handles.scanCorrName,':BCTRL');
handles.scanCorrVal=lcaGetSmart(handles.scanCorrPV);
pl=wireDirId*2-2;

%s.corrList={'YC27303' 'YC27703' 'YC28303'}';
%s.bpmList={'YC27303' handles.scanWireName 'YC28303' 'YC28403'}';
%[s.quadList,s.undList]=deal(cell(0,1));[s.zQuad,s.zUnd,s.lUnd]=deal(zeros(1,0));
%z=model_rMatGet([s.bpmList;s.corrList],[],[],'Z');s.zBPM=z(1:4);s.zCorr=z(5:7);
%r=bba_responseMatGet(s,1);

[rMat,z,en]=model_rMatGet(handles.scanCorrName,handles.scanWireName,[],{'R' 'Z' 'EN'});
zWire=model_rMatGet(handles.scanWireName,[],[],'Z');
bp=en/299.792458*1e4; % kG m
r=rMat((1:2)+pl,(1:2)+pl,:);

if isfield(sector,['process' 'CorCal']) && ~isempty(sector.(['process' 'CorCal']))
    corrName=[sector.XCorDevList(:,handles.scanWireId); ...
              sector.YCorDevList(:,handles.scanWireId)];
    [cIs,cId]=ismember(handles.scanCorrName,corrName);
    rMat=sector.(['process' 'CorCal'])(:,cId(cIs));
    rMat=reshape([rMat*0;rMat;rMat*0;rMat],4,4,[]);
    rW=model_rMatGet(sector.BPMDevList(1),handles.scanWireName);
    rMat=reshape(rW(1:4,1:4)*rMat(:,:),4,4,[]);
    r=rMat((1:2)+pl,(1:2)+pl,:);
end

if strcmp(handles.sectorSel,'UNDH')
    rCBm=max(abs(permute(data.rMatList(1+pl,(1:2)+pl,:),[3 2 1])*squeeze(r(:,2,:)))); % max response at all BPMs

    range=data.wireLimit;
    bfwName=model_nameConvert(handles.scanWireName,'MAD');
    bfwNum=str2double(bfwName(4:5));
    girderPos=lcaGetSmart(strcat(num2str(bfwNum,'USEG:UNDH:%d50'),':BFW',upper(wireDir),'READCALC'));
    range=num2cell((range.(wireDir)-girderPos)*1e-6);
    range=linspace(range{:},handles.scanWireStepNum);
%    corr=-diag(bp)*inv([r(:,:,1)*[0;1] r(:,:,2)*[0;1]])*[1;0]*range; % kG m
    corr=-diag(bp)*diag(1./rCBm)*pinv([r(1,2,1) r(1,2,2)]*diag(1./rCBm))*range; % kG m
%    handles.scanCorrValList=[handles.scanCorrVal(1)+corr(1,:);handles.scanCorrVal(2)+corr(2,:)];
else
%r1to3=inv(rMat(:,:,3))*rMat(:,:,1);
%r2to3=inv(rMat(:,:,3))*rMat(:,:,2);
%r12=rMat(1+pl,2+pl);
    range=wire2pos(data,handles.scanWireLimit);
    range.(wireDir)=range.(wireDir)-range.(wireDir)(1); % Wire already at lower range position

%opts.use=struct('init',0,'quad',0,'BPM',0,'corr',1);
%xMeas=zeros(2,4);
%xMeas(wireDirId,2)=-range.(wireDir)(1)*1e-6;
%f=bba_fitOrbit(s,r,xMeas,[],opts);cLow=f.corrOff(wireDirId,:)';
%xMeas(wireDirId,2)=-range.(wireDir)(2)*1e-6;
%f=bba_fitOrbit(s,r,xMeas,[],opts);cHigh=f.corrOff(wireDirId,:)';
%corrLimit=num2cell([cLow cHigh]); % kG m

%range=range.(wireDir)*1e-6;
%c1=-range/r12;
%c2=-r1to3(1+pl,2+pl)/r2to3(1+pl,2+pl)*c1;
%c3=(-r1to3(2+pl,2+pl)+r2to3(2+pl,2+pl)*r1to3(1+pl,2+pl)/r2to3(1+pl,2+pl))*c1;
%corr=[c1;c2;c3];
range=num2cell(range.(wireDir)*1e-6);
range=linspace(range{:},handles.scanWireStepNum);
corr=-diag(bp)*inv([[1 0]*r(:,:,1)*[0;1] [1 0]*r(:,:,2)*[0;1]*(z(2) < zWire) 0; ...
                    r(:,:,1)*[0;1] r(:,:,2)*[0;1] r(:,:,3)*[0;1]])*[1;0;0]*range;
%corrLimit=num2cell(corr); % kG m

%handles.scanCorrValList=[handles.scanCorrVal(1)+linspace(corrLimit{1,:},handles.scanWireStepNum); ...
%                         handles.scanCorrVal(2)+linspace(corrLimit{2,:},handles.scanWireStepNum); ...
%                         handles.scanCorrVal(3)+linspace(corrLimit{3,:},handles.scanWireStepNum)];
end
handles.scanCorrValList=repmat(handles.scanCorrVal,1,size(corr,2))+corr;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function data = doWireProcess(hObject, handles, data)

% Get useful data range from wireMask.
% Wire scanner is retracted at maximum value and moves into the beam with
% decreasing position value.
wireId=handles.scanWireId;
sector=handles.sector.(handles.sectorSel);
wireData=data.wireData(data.wireMask);

use.x=wireData <= max(data.wireLimit.x) & wireData >= min(data.wireLimit.x);
use.y=wireData <= max(data.wireLimit.y) & wireData >= min(data.wireLimit.y);
use.u=wireData <= max(data.wireLimit.u) & wireData >= min(data.wireLimit.u);

if ~any(diff(wireData)) || strcmp(data.wireMode,'step') % Corrector or orbit scan
    for tag='xyu'
        use.(tag)(:)=data.wireDir.(tag);
    end
end

% Select signal and position from saved PMT and wire data.
pos=wire2pos(data,wireData);
data.selectPMT=sector.processPMTUsed(wireId);
PMTData=data.PMTData(data.selectPMT,data.wireMask);

% Do charge normalization if selected.
data.selectToro=sector.processToroUsed(wireId);
charge=data.toroData(data.selectToro,data.wireMask);
if handles.process.chargeNorm
    PMTData=round(PMTData./charge*mean(charge(~isnan(charge))));
end
useCharge=charge > 1e7 | isnan(charge);
use.x=use.x & useCharge;
use.y=use.y & useCharge;
use.u=use.u & useCharge;

% Do jitter correction if selected.
data.selectBPM=sector.processBPMUsed(wireId,:);
if strcmp(data.wireMode,'orbit'), data.selectBPM=sector.orbitBPMused{wireId};end
WSPos.x=0;WSPos.y=0;WSPos.u=0; % no jitter correction
if sector.processJitterCorr(wireId)
    BPMPosX=data.BPMXData(data.selectBPM,data.wireMask); % BPM pos in mm
    BPMPosY=data.BPMYData(data.selectBPM,data.wireMask);
    isGood=~any(isnan([BPMPosX;BPMPosY]));
    BPMPosX(:,~isGood)=[];BPMPosY(:,~isGood)=[];
    BPMRefX=repmat(mean(BPMPosX,2),1,size(BPMPosX,2));
    BPMRefY=repmat(mean(BPMPosY,2),1,size(BPMPosY,2));
    if strcmp(data.wireMode,'orbit')
        BPMRefX=repmat(BPMPosX(:,1),1,size(BPMPosX,2))*0;
        BPMRefY=repmat(BPMPosY(:,1),1,size(BPMPosY,2))*0;
    end
    rMat=data.rMatList(:,:,data.selectBPM);
    posX(:,isGood)=beamAnalysis_orbitFit([],rMat(1:2,[1:2 6],:),(BPMPosX-BPMRefX)*1e-3); % in m
    posY(:,isGood)=beamAnalysis_orbitFit([],rMat(3:4,[3:4 6],:),(BPMPosY-BPMRefY)*1e-3);
    posX(:,~isGood)=NaN;posY(:,~isGood)=NaN;
    if size(posX,1) > 0 && size(posY,1) > 0
        WSPos=xy2pos(data,posX(1,:)*1e6,posY(1,:)*1e6); % Wire pos in um
    end
end

for tag='xyu'
    if data.wireDir.(tag) && ~any(use.(tag))
        disp('Either NO BEAM or no valid wire positions in requested scan range')
        disp(['  for ' tag ' plane for wire ' data.name '.']);
        disp('  If there was beam, may be motion control issue. Check readback matches ');
        disp('  motor values and wire motion actually executes in this range.');
        pos.(tag) = nan;
        data.pos.(tag) = nan;
        data.signal.(tag) = nan;
    else
        pos.(tag)=pos.(tag)-WSPos.(tag);
        data.pos.(tag)=pos.(tag)(use.(tag));
        data.signal.(tag)=PMTData(use.(tag));
    end
end
if sum(use.y) > 1
    [a,id(1)]=min(data.pos.y);[a,id(2)]=max(data.pos.y);
    data.pos.y(id)=[];data.signal.y(id)=[]; % Remove 1st & last point for TCAV3.
end

if sector.processJitterCorr(wireId) && isequal(WSPos.x,0)
    s=dbstack;
    if ismember('scanReadData',{s.name})
        data=processProfiles(data);
        data.beamPV=beamAnalysis_convert2PV(data);
        [dirTag,dirId]=scanWireCurrentDir(hObject,handles);
        for tag=fieldnames(data)'
            handles.sector.(handles.sectorSel).data(handles.scanWireId,dirId).(tag{:})=data.(tag{:});
        end
        dataSave(hObject,handles,0);
        errordlg({'Insufficient BPM data for jitter correction, aborting...';...
            'Please make logbook entry.'},'wirescan_gui:jitterCorrInsufficientData');
        error('wirescan_gui:jitterCorrInsufficientData',...
            'Insufficient BPM data for jitter correction');
    end
end

% Do TCAV
if 0
    data.pos.x=data.pos.y(1:4:end);
    data.pos.u=[data.pos.y(2:4:end) data.pos.y(3:4:end)];
    data.pos.y=data.pos.y(4:4:end);
    data.signal.x=data.signal.y(1:4:end);
    data.signal.u=[data.signal.y(2:4:end) data.signal.y(3:4:end)];
    data.signal.y=data.signal.y(4:4:end);
    data.wireDir.x=1;data.wireDir.u=1;
end


% ------------------------------------------------------------------------
function data = doCorrProcess(hObject, handles, data)

% Select signal and position from saved PMT and wire data.
wireId=handles.scanWireId;
sector=handles.sector.(handles.sectorSel);
data.selectPMT=sector.processPMTUsed(wireId);
PMTData=data.PMTData(data.selectPMT,:);

% Do charge normalization if selected.
data.selectToro=sector.processToroUsed(wireId);
if handles.process.chargeNorm
    charge=data.toroData(data.selectToro,:);
    PMTData=round(PMTData./charge*mean(charge));
end
data.signal.x=PMTData(:)';
data.signal.y=PMTData(:)';
data.signal.u=PMTData(:)';

data.selectBPM=sector.processBPMSel(wireId);

BPMPosX=data.BPMXData(data.selectBPM,:); % BPM pos in mm
BPMPosY=data.BPMYData(data.selectBPM,:);
len=size(BPMPosX,2);
use=[1:ceil(len/10) max(1,ceil(len-len/10)):len];
parX=polyfit(data.corrData(use),BPMPosX(use),1);
parY=polyfit(data.corrData(use),BPMPosY(use),1);
calX=sector.processXCorCal(wireId,data.selectBPM);
calY=sector.processYCorCal(wireId,data.selectBPM);
data.pos=xy2pos(data,polyval(parX,data.corrData)*calX,polyval(parY,data.corrData)*calY);


% ------------------------------------------------------------------------
function handles = processUpdate(hObject, handles)

guidata(hObject,handles);
scanPlot(hObject,handles);
sector=handles.sector.(handles.sectorSel);
[tag,dirId]=scanWireCurrentDir(hObject,handles);
wireId=handles.scanWireId;
data=sector.data(wireId,dirId);
if ~any([data.status]), processPlot(hObject,handles);return, end

switch data.wireMode
    case {'wire' 'step' 'orbit'}
        data=doWireProcess(hObject,handles,data);
    case 'corr'
        data=doCorrProcess(hObject,handles,data);
end

% Calculate beam statistics and fits.
data=processProfiles(data);
data.beamPV=beamAnalysis_convert2PV(data);

% Put processed data back in storage.
use=cell2mat(struct2cell(data.wireDir));
for tag=fieldnames(data)'
    [sector.data(wireId,use).(tag{:})]=deal(data.(tag{:}));
end
if all([sector.data(wireId,:).status])
    for tag={'x' 'y' 'u';1 2 3}
        dataAll.wireDir.(tag{1})=true;
        dataAll.pos.(tag{1})=sector.data(wireId,tag{2}).pos.(tag{1});
        dataAll.signal.(tag{1})=sector.data(wireId,tag{2}).signal.(tag{1});
    end
    sector.dataAll(wireId,1)=processProfiles(dataAll);
end

handles.sector.(handles.sectorSel)=sector;
handles=dataMethodControl(hObject,handles,[],length(data.beam));
if ~strncmp(data.name,'BFW',3) && ~handles.isFWS && ~handles.isBOD
    control_profDataSet(data.name, data.beam(handles.dataMethod.iVal), handles.dataPlane);
end


% ------------------------------------------------------------------------
function data = processProfiles(data)

wirescan_const;
persistent NANSSET2ZERO;
NANSSET2ZERO=...
    'NaNs found (% d) in profile signal data plane %s; setting those points to 0.';

profs=struct;
for tag='xyu'
    [pos,idx]=sort(data.pos.(tag));signal=data.signal.(tag)(idx);
    if data.wireDir.(tag) && ~isempty(pos)
        bad=isnan(signal);
        if any(bad)
           lprintf(STDOUT, NANSSET2ZERO, numel(bad), tag);
        end
        signal(bad)=0.0;
        profs.(tag)=[pos;signal];
    end
end
data.beam=beamAnalysis_beamParams(profs,[],[],0,'isimage',0,'fitbg',1);


% ------------------------------------------------------------------------
function handles = plotInit(hObject, handles)

ax=handles.plotRaw_ax;
col=get(ax,'ColorOrder');
handles.plotScan.wire=line(NaN,NaN,'Parent',ax,'Color','k','LineStyle',':');
handles.plotScan.wireMasked=line(NaN,NaN,'Parent',ax,'Color','k');
for j=1:40
    props={'Parent',ax,'Color',col(mod(j-1,7)+1,:)};
    handles.plotScan.PMT(j)=line(NaN,NaN,props{:},'LineStyle','-');
    handles.plotScan.BPMX(j)=line(NaN,NaN,props{:},'LineStyle',':');
    handles.plotScan.BPMY(j)=line(NaN,NaN,props{:},'LineStyle','-.');
    handles.plotScan.toro(j)=line(NaN,NaN,props{:},'LineStyle','--');
end
handles.plotScan.txt=text(0.1,0.9,'','units','normalized','Parent',ax, ...
    'VerticalAlignment','top');
xlabel(ax,'Scan Point');
ylabel(ax,'Wire Position  (mm)');

handles.plotProcessLim=-1;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function scanPlot(hObject, handles)

sector=handles.sector.(handles.sectorSel);
[tag,dirId]=scanWireCurrentDir(hObject,handles);
data=sector.data(handles.scanWireId,dirId);
hList=findobj(handles.plotRaw_ax,'Type','line');
set(hList,'XData',NaN,'YData',NaN);
set(findobj(handles.plotRaw_ax,'Type','text'),'String','');
if ~any([data.status]), return, end

x=1:length(data.wireData);y=data.wireData*1e-3;
set(handles.plotScan.wire,'XData',x,'YData',y);
y(~data.wireMask)=NaN;
set(handles.plotScan.wireMasked,'XData',x,'YData',y);
str={[data.wireName]};
dispSel=handles.processDisplaySel;

iVal=1:size(data.PMTData,1);
if dispSel, iVal=sector.processPMTUsed(handles.scanWireId);end
for j=iVal
    set(handles.plotScan.PMT(j),'XData',x,'YData',data.PMTData(j,:)*1e-2);
    str=[str {['\color[rgb]{' num2str(get(handles.plotScan.PMT(j),'Color')) '}' data.PMTList{j}]}];
end
iVal=1:size(data.BPMXData,1);
if dispSel, iVal=find(sector.processBPMUsed(handles.scanWireId,:));end
for j=iVal
    set(handles.plotScan.BPMX(j),'XData',x,'YData',data.BPMXData(j,:)*10);
    set(handles.plotScan.BPMY(j),'XData',x,'YData',data.BPMYData(j,:)*10);
    str=[str {['\color[rgb]{' num2str(get(handles.plotScan.BPMX(j),'Color')) '}' data.BPMList{j}]}];
end
iVal=1:size(data.toroData,1);
if dispSel, iVal=sector.processToroUsed(handles.scanWireId);end
for j=iVal
    set(handles.plotScan.toro(j),'XData',x,'YData',abs(data.toroData(j,:))*1e-8);
    str=[str {['\color[rgb]{' num2str(get(handles.plotScan.toro(j),'Color')) '}' data.toroList{j}]}];
end
set(handles.plotScan.txt,'String',str);


% ------------------------------------------------------------------------
function processPlot(hObject, handles)

try
sector=handles.sector.(handles.sectorSel);
data=sector.data(handles.scanWireId,handles.dataPlane == 'xyu');
if ~any([data.status])
    cla(handles.plotProcess_ax);legend(handles.plotProcess_ax,'off');
    xlabel(handles.plotProcess_ax,'');ylabel(handles.plotProcess_ax,'');
    title(handles.plotProcess_ax,'');
    return
end
method=handles.dataMethod.iVal;
opts.axes=handles.plotProcess_ax;dispstr='';
opts.xlab=[data.wireName ' Position  (\mum)'];
opts.ylab=[data.PMTList{data.selectPMT} ' Signal  ()'];
opts.title=['Wirescan on ' data.wireName ' ' datestr(data.ts)];
% if handles.processDisplayDispersion && isfield(data.beam(method),'profx')
if handles.processDisplayDispersion
%    rMat=model_rMatGet(data.wireName);
    rMat=inv(data.rMatList(:,:,1));
    if isfield(data.beam(method),'profx')
        cal=rMat(1,6)*1e6/1e4; % conversion from m to um and to 1e-4
    else
        cal=rMat(3,6)*1e6/1e4; % conversion from m to um and to 1e-4
    end
    if abs(cal) > .01*1e6/1e4
        opts.cal=1/cal;
        opts.xlab='Energy spread  (10^{-4})';
        dispstr=sprintf('%4.2f m',rMat(1,6));
    end
end
beamAnalysis_profilePlot(data.beam(method),handles.dataPlane,opts);
set(handles.dataMethod_txt,'String',data.beam(method).method);
set(handles.processDisplayDispersion_txt,'String',dispstr);
catch
end

% ------------------------------------------------------------------------

        
% ------------------------------------------------------------------------
function [range, speedMOTR] = startFWS(hObject, handles, wireDir)
%function for starting scan for FWS

countOld=lcaGetRetryCount;
lcaSetRetryCount(60/lcaGetTimeout);
[flag, speedMOTR, range] = scanWireSpeedCheck(hObject, handles);
n=wireDir == 'xyu';
speedMOTR = speedMOTR(n);  
range = range(n);  
lcaPut([handles.scanWireName ':MOTR.VELO'],speedMOTR);
scanDir=lcaGetSmart(strcat(handles.scanWireName,':SCANTOCENTER'),0,'double');
str={'INNER' 'OUTER'};
pv=strcat(handles.scanWireName,':',upper(wireDir),'WIRE',str{~scanDir+1});
val=lcaGetSmart(pv);  
try
    lcaPutNoWait(strcat(handles.scanWireName,':MOTR'),val);
catch ex
    lprintf(STDERR, 'Ignoring exception setting motor position (MOTR) %s',...
        ex.message);
end
lcaSetRetryCount(countOld);


% ------------------------------------------------------------------------
function stopFWS(hObject, handles)

pv=strcat(handles.scanWireName,':MOTR');
vmax=lcaGetSmart(strcat(pv,'.VMAX'));
lcaPut(strcat(pv,'.VELO'),vmax);pause(0.1);
val1=lcaGetSmart(strcat(pv,'.LLM'));
lcaPutNoWait(pv,val1);
if strcmp(handles.scanWireName,'WIRE:LTUH:755'), pause(1.);lcaPutNoWait(pv,val1);end


% ------------------------------------------------------------------------
function [handles, action, data] = scanStartWire(hObject, handles)

wirescan_const;

guidata(hObject,handles);
if ~epicsSimul_status
    par={};
%      if strcmp(handles.accelerator,'FACET') % before Mike Z had fixed the defaults for FACET
%          lcaPut(sprintf('EDEF:SYS1:%d:BEAMCODE',handles.eDefNumber),10);
%          par={{'TS5'} {} {'NO_GUN_PERM' 'TS1' 'TS2' 'TS3' ...
%              'TS4' 'TS6'} {'DUMP_2_9'}};
%      end
    eDefParams(handles.eDefNumber,1,handles.scanWireBufferNum,par{:});
    eDefOn(handles.eDefNumber);
end

%{
scanDir=lcaGetSmart(strcat(handles.scanWireName,':SCANTOCENTER'),0,'double');
use=cell2mat(struct2cell(handles.scanWireDir))';
tagList='xyu';
useTags=tagList(use);
range=cell2mat(struct2cell(handles.scanWireLimit));
str={'ascend' 'descend'};
[d,id]=sort(range(use,1),1,str{scanDir+1});

for tag = useTags(id)
    % Move wire to start position.
    if tag ~= useTags(id(1))
        scanWireInsert(hObject,handles,tag);
    end
%}
[d,d,d,tagList]=scanWireCurrentDir(hObject,handles,'sort');
for tag = tagList
    % Move wire to start position.
    if tag ~= tagList(1)
        scanWireInsert(hObject,handles,tag);
    end

    %reset the gui aquire status
    gui_acquireStatusSet(hObject,handles,1);
    
    % Loop while scan is active.
    ratio=0;currentPosn = 0;dataBPM=[];

    if handles.isFWS %need to use scanStartStep for WIRE:LTUH:775-7
        [range, speedMOTR] = startFWS(hObject, handles, tag);
%        pvName = strcat(handles.scanWireName,':',upper(tag),'WIREINNER');
%        currentPosn = lcaGetSmart(pvName);
        currentPosn = handles.scanWireLimit.(tag)(1);
    elseif strcmp(handles.sectorSel,'UNDH')
        [handles, action, data] = scanStartStep(hObject, handles);
        return
    else
        lcaPut([handles.scanWireName ':STARTSCAN'],1);
        range = 0;
        speedMOTR = 0;
    end

    % figure out when to start AIDA bpm acquisition
    %{
        rate = lcaGetSmart(handles.beamRatePV);
        aida_maxpts = 15 * rate;
        limits = handles.scanWireLimit.(handles.dataPlane);
        midpt = min(limits) + abs(diff(limits))/2;
        if handles.scanWireBufferNum > aida_maxpts
            aidastart = midpt - (rate * aida_maxpts/2);
        else
            aidastart = min(limits);
        end
    %}

    while gui_acquireStatusGet(hObject,handles)
        %{
            if isempty(dataBPM) && strncmp(handles.sector.(handles.sectorSel).BPMDevList{1},'LI',2)
                lvpos = lcaGetSmart([handles.scanWireName ':LVPOS']);
                if lvpos >= aidastart
                    dataBPM=scanReadAidaBSA(hObject,handles,[],1,handles.scanWireBufferNum);
                end
            end
        %}
        pause(0.25);
        handles=guidata(hObject);
        if epicsSimul_status
            lcaPut([handles.scanWireName ':SCANPROGRESS'],ratio+33.4);
            lcaPut([handles.scanWireName ':STARTSCAN'],ratio+33.4 < 100);
            lcaPut([handles.scanWireName ':SCANTEXT'],'In progress');
            lcaPut([handles.scanWireName ':MOTR.RBV'],currentPosn+speedMOTR);
%            pvName = strcat(handles.scanWireName,':',upper(tag),'WIREINNER');
%            WI = lcaGetSmart(pvName);
            inner = handles.scanWireLimit.(tag)(1);
            lcaPut([handles.scanWireName ':MOTR.MOVN'],...
                (currentPosn+speedMOTR-inner) < range);
        end

        if handles.isFWS %Need to account for PVs that are not found for WIRE:LTUH:775-7
            str = 'In progress';
            status = lcaGetSmart([handles.scanWireName ':MOTR.MOVN']);
            currentPosn = lcaGetSmart([handles.scanWireName ':MOTR.RBV']);
            inner = handles.scanWireLimit.(tag)(1);
            ratio = ((currentPosn-inner)/range)*100;
            if ratio > 100
                ratio = 100;
            end
            str = sprintf('%s; Plane: %s %3.1f %%  (%d of %d [um])', ...
                char(str), tag, ratio, ceil(currentPosn-inner), range);
        else
            str=lcaGetSmart([handles.scanWireName ':SCANTEXT']);
            ratio=lcaGetSmart([handles.scanWireName ':SCANPROGRESS']);
            status=lcaGetSmart([handles.scanWireName ':STARTSCAN'],0,'double');
            str = sprintf('%s; Plane: %s %3.1f%%', ...
                char(str), tag, ratio)
        end
        
        % Update progress status line and bar
        %
        gui_statusDisp(handles.scanWireStatus_txt, lprintf(STDOUT, str));
        if handles.extGui
            set(handles.extHandle.scanWireStatus_txt, 'String',str); 
        end
        progressBar(hObject,handles,'scanWireProgress',ratio/100);
        if ~status,gui_acquireStatusSet(hObject,handles,0);break,end

    end
    if handles.isFWS
%        handles.scanWireDir.(tag) = false;
%        guidata(hObject,handles);
        vmax=lcaGetSmart(strcat(handles.scanWireName,':MOTR.VMAX'));
        lcaPut(strcat(handles.scanWireName,':MOTR.VELO'),vmax);
    end
end
%{
if handles.isFWS
    handles.scanWireDir.x = logical(use(1)); 
    handles.scanWireDir.y = logical(use(2)); 
    handles.scanWireDir.u = logical(use(3)); 
    guidata(hObject,handles);
end 
%}
if ~epicsSimul_status
    eDefOff(handles.eDefNumber);
end
if epicsSimul_status
    lcaPut([handles.scanWireName ':SCANTEXT'],'READY to START Wire Scan');
    lcaPut([handles.scanWireName ':HADSUCCESS'],1);
end
if handles.isFWS %Need to account for PVs that are not found for WIRE:LTUH:775-7
    str = 'READY to START Wire Scan';
else
    str=lcaGetSmart([handles.scanWireName ':SCANTEXT']);
end
set(handles.scanWireStatus_txt,'String',str);

if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end

if handles.isFWS %Need to account for PVs that are not found for WIRE:LTUH:775-7
    status = 1;
    stopFWS(hObject,handles);
else
    status=lcaGetSmart([handles.scanWireName ':HADSUCCESS'],0,'double');
end

action=1;
if status == 2
    butList={'Proceed' 'Retry' 'Cancel'};
    button=questdlg('Scan was unsuccessfull!','Scan Result',butList{:},butList{2});
    action=find(strcmp(button,butList));
end
data=scanReadWireData(hObject,handles);

% Read wire scanner data.
if action == 1
    data=scanReadBSAData(hObject,handles,data);
%{
    if strncmp(handles.sector.(handles.sectorSel).BPMDevList{1},'LI',2)
        if ~isempty(dataBPM)
            [is,id]=ismember(data.pulseId,dataBPM.pulseId);
            data.BPMXData(:,is)=dataBPM.BPMXData(:,id(is));
            data.BPMYData(:,is)=dataBPM.BPMYData(:,id(is));
            data.toroData(:,is)=dataBPM.toroData(:,id(is));
        else
            is=false(size(data.pulseId));
        end
        [data.BPMXData(:,~is),data.BPMYData(:,~is),data.toroData(:,~is)]=deal(NaN);
    end
%}
end


% ------------------------------------------------------------------------
function [handles, action, data] = scanStartCorr(hObject, handles)

% Initialize corrector and read wire scanner data.
[handles,data]=scanCorrInit(hObject,handles);
sampleNum=10;

if ~epicsSimul_status
    eDefParams(handles.eDefNumber,1,sampleNum);
end
guidata(hObject,handles);

% Loop while scan is active.
for j=1:handles.scanCorrNum
    lcaPut([handles.scanCorrName ':BCTRL'],handles.scanCorrValList(j));
    guidata(hObject,handles);
    pause(1.);
    handles=guidata(hObject);
    if ~epicsSimul_status
        eDefOn(handles.eDefNumber);nTry=100;
        while ~eDefDone(handles.eDefNumber) && nTry, nTry=nTry-1;pause(.1);end
    end
    data=scanReadBSAData(hObject,handles,data,j,sampleNum);
    data.corrData(1,1:size(data.PMTData,2),j)=handles.scanCorrValList(j);
    str='Scanning';
    set(handles.scanWireStatus_txt,'String',str);
    if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end
    progressBar(hObject,handles,'scanWireProgress',j/handles.scanCorrNum);
    if ~gui_acquireStatusGet(hObject,handles), data.status=false;break, end
end

str='Done';
set(handles.scanWireStatus_txt,'String',str);
if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end
lcaPut(handles.scanCorrPV,handles.scanCorrVal);
lcaPut(handles.fdbkList,handles.fdbkStat);
gui_acquireStatusSet(hObject,handles,0);
action=1;

% Flatten data arrays.
data.wireData=data.wireData(:,:);
data.wireMask=data.wireMask(:,:);
data.PMTData=data.PMTData(:,:);
data.toroData=data.toroData(:,:);
data.BPMXData=data.BPMXData(:,:);
data.BPMYData=data.BPMYData(:,:);
data.corrData=data.corrData(:,:);


% ------------------------------------------------------------------------
function [handles, action, data] = scanStartOrbit(hObject, handles)

% Initialize corrector and read wire scanner data.
[handles,data]=scanOrbitInit(hObject,handles);

% Read wire scanner data.
sampleNum=round(handles.scanWirePulses/handles.scanWireStepNum);
rate=lcaGetSmart(handles.beamRatePV);

if ~epicsSimul_status
    eDefParams(handles.eDefNumber,1,handles.scanWirePulses*1.5);
end
guidata(hObject,handles);

if ~epicsSimul_status
    if strcmp(handles.sectorSel,'UNDH') && ~get(handles.scanBFWtestMode_box,'Value')
        % Turn burst control on.
        lcaPut('IOC:BSY0:MP01:REQBYKIKBRST',1);
        lcaPut('PATT:SYS0:1:MPSBURSTCNTMAX',handles.scanWirePulses*1.5);
        % Turn beam on.
        lcaPut('IOC:BSY0:MP01:BYKIKCTL',1);
        % Start burst.
        lcaPut('PATT:SYS0:1:MPSBURSTCTRL',1);pause(.1);
    end
    eDefOn(handles.eDefNumber);
end

% Loop while scan is active.
stepNum=handles.scanWireStepNum;
for j=1:stepNum
    lcaPut(strcat(handles.scanCorrName,':BCTRL'),handles.scanCorrValList(:,j));
    guidata(hObject,handles);
    pause(sampleNum/rate);
    handles=guidata(hObject);
    str='Scanning';
    set(handles.scanWireStatus_txt,'String',str);
    if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end
    progressBar(hObject,handles,'scanWireProgress',j/stepNum);
    if ~gui_acquireStatusGet(hObject,handles), data.status=false;break, end
end

if ~epicsSimul_status
%    nTry=100;
%    while ~eDefDone(handles.eDefNumber) && nTry, nTry=nTry-1;pause(.1);end
    eDefOff(handles.eDefNumber);
    if strcmp(handles.sectorSel,'UNDH') && ~get(handles.scanBFWtestMode_box,'Value')
        % Stop burst.
        pause(.1);lcaPut('PATT:SYS0:1:MPSBURSTCTRL',0);
        % Turn beam off
        lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
        % Turn burst control off.
        lcaPut('IOC:BSY0:MP01:REQBYKIKBRST',0);
        pause(1);
        lcaPut('SIOC:SYS0:ML00:CALC011',1);
    end
end

data=scanReadBSAData(hObject,handles,data);
data.wireMask(:)=true;

str='Done';
set(handles.scanWireStatus_txt,'String',str);
if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end
lcaPut(handles.scanCorrPV,handles.scanCorrVal);
fdbkList=handles.fdbkList(end-1:end);
if strcmp(handles.sectorSel,'LI28'), fdbkList=handles.fdbkList(4:5);end
lcaPut(fdbkList,handles.fdbkStat);
gui_acquireStatusSet(hObject,handles,0);
action=1;


% ------------------------------------------------------------------------
function [handles, action, data] = scanStartStep(hObject, handles)

% Read wire scanner data.
data=scanReadWireData(hObject,handles);
sampleNum=round(handles.scanWirePulses/handles.scanWireStepNum);
wireDir=scanWireCurrentDir(hObject,handles);

if ~epicsSimul_status
    eDefParams(handles.eDefNumber,1,sampleNum);
end
guidata(hObject,handles);

% Loop while scan is active.
stepNum=round(handles.scanWirePulses/sampleNum);
lim=data.wireLimit.(wireDir);
stepList=lim(1)+diff(lim)*linspace(.5,stepNum-.5,stepNum)/stepNum;
pv=[handles.scanWireName ':MOTR'];
if strcmp(handles.sectorSel,'UNDH')
    geo=girderGeo;z=geo.bfwz;
    if handles.isBOD, z=geo.bodz;end
    bfwName=model_nameConvert(handles.scanWireName,'MAD');
    bfwNum=str2double(bfwName(4:5));
    [pos0,posQ]=girderAxisFind(bfwNum,z,geo.quadz);
end
for j=1:stepNum
    if strcmp(handles.sectorSel,'UNDH')
        pos=pos0;
        pos(wireDir == 'xy')=stepList(j)/1e3; % in mm
        girderAxisSet(bfwNum,pos,posQ);
        girderCamWait(bfwNum);
    else
        lcaPut(pv,stepList(j));
        pause(1.);
    end
    if ~epicsSimul_status
        if strcmp(handles.sectorSel,'UNDH') && ~handles.isBOD
            % Turn beam on
            lcaPut('IOC:BSY0:MP01:BYKIKCTL',1);pause(.5);
        end
        eDefOn(handles.eDefNumber);nTry=100;
        while ~eDefDone(handles.eDefNumber) && nTry, nTry=nTry-1;pause(.1);end
        if strcmp(handles.sectorSel,'UNDH') && ~handles.isBOD
            % Turn beam off
            pause(.1);lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
        end
    end
    data=scanReadBSAData(hObject,handles,data,j,sampleNum);
    data.wireMask(1,:,j)=true;
    str='Scanning';
    set(handles.scanWireStatus_txt,'String',str);
    if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end
    progressBar(hObject,handles,'scanWireProgress',j/stepNum);
    if ~gui_acquireStatusGet(hObject,handles), data.status=false;break, end
end
if strcmp(handles.sectorSel,'UNDH')
    girderAxisSet(bfwNum,pos0,posQ);
    girderCamWait(bfwNum);
end
str='Done';
set(handles.scanWireStatus_txt,'String',str);
if handles.extGui,set(handles.extHandle.scanWireStatus_txt, 'String',str), end
gui_acquireStatusSet(hObject,handles,0);
action=1;

% Flatten data arrays.
data.wireData=data.wireData(:,:);
data.wireMask=data.wireMask(:,:);
data.PMTData=data.PMTData(:,:);
data.toroData=data.toroData(:,:);
data.BPMXData=data.BPMXData(:,:);
data.BPMYData=data.BPMYData(:,:);


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

wirescan_const; % STDERR etc

% Check if any wire direction is selected.
if ~any(cell2mat(struct2cell(handles.scanWireDir))), return, end

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end

% Check if event def is still valid.
handles=gui_BSAControl(hObject,handles,[]);
if ~handles.eDefNumber
    error('WS:NOEDEF', ...
          lprintf(STDOUT, ['No event definition slot available. ', ...
                        'Free a slot and try this app again.']));
end
toroid_comparator_bypassed = false;

try 
    
    % Set PMT delay times        % B. Jacobson removed 6/19/2020 
    %switch handles.scanWireName
    %    case {'WIRE:LTUH:246'}
    %        lcaPut('QADC:LTUH:300:TDES',-2150);
    %        lcaPut('QADC:LTUH:300:TWID',100);
    %    case {'WIRE:IN20:531' 'WIRE:IN20:561' 'WIRE:IN20:611' 'WIRE:IN20:741'}
    %        lcaPut('QADC:IN20:100:TDES',1270-30);
    %    case {'WIRE:LI21:285' 'WIRE:LI21:293' 'WIRE:LI21:301'}
    %        lcaPut('QADC:IN20:100:TDES',1300-30);
    %end
    
    pmtLTUS756voltage = 0; % if this is not zero later, the value will be restored...
    switch handles.scanWireName
        case {'WIRE:LTUS:755' 'WIRE:LTUS:785'}
            val = lcaGetSmart('HVM:LTUS:756:VoltageSet');
            if ~isnan(val) && val >= 500 && val <= 1200 % only act w/i a reasonable range, up to setting 1300 V
                pmtLTUS756voltage = val;
                % if it's in a good range, we have from experience that we
                % need to increase the voltage from the normal setting when
                % we do the second two wires, due to the location of the
                % PMT vs. wires, so we'll goose it and restore it later, in
                % a place after the try/catch in case of any failure
                lcaPutSmart('HVM:LTUS:756:VoltageSet',val + 100);
                pause(2)
            end
    end
    
    switch handles.sectorSel
        case {'IN20' 'LI21'}
            lcaPutSmart('QADC:IN20:100:QDCSETBASELN',200);  % G. White, 17-Apr-18. 160 -> 200 per
                                                            % A. Fisher
        case 'LI28'
            lcaPutSmart('QADC:LI28:100:QDCSETBASELN',110);
        case {'LTUH' 'UNDH' 'DMPH'}
            lcaPutSmart('QADC:LTUH:100:QDCSETBASELN',90);
            lcaPutSmart('QADC:LTUH:300:QDCSETBASELN',90);
            lcaPutSmart('QADC:DMPH:100:QDCSETBASELN',90);
        case 'LTUS'
            
    end
    
    % Check wire status of problematic fast wire scanners, and 
    % reset if necessary.
    if handles.isFWS 
        wirescan_initFWS(handles.scanWireName);
    end
    
    % Apply auto range if selected.
    handles=scanAutoRange(hObject,handles);
    
    % Check if ranges are valid and turn auto pulses on once if not.
    pState=[];
    if ~strcmp(handles.sectorSel,'UNDH') && any(scanWireSpeedCheck(hObject,handles))
        pState=handles.scanWireAutoPulses;
        handles=scanWireAutoPulsesControl(hObject,handles,1);
    end
    
    % Set scan pulses if auto selected.
    handles=scanWireAutoPulsesControl(hObject,handles,pState);

    % If we are running injector wire scans, bypass IM02/IM03 MPS toroid comparator interlocks.
    if strcmp(handles.scanWireName, 'WIRE:IN20:561')
	    toroid_comparator_bypassed = bypassDL1ToroidComparatorInterlock(handles, 60*5);
    end

    % Initialize acquisition.
    progressBarInit(hObject,handles,'scanWireProgress');
    % progressBar(hObject,handles,'scanWireProgress',0);
    pause(0.001);
    rate=lcaGetSmart(handles.beamRatePV);
    [d,d,use]=scanWireCurrentDir(hObject,handles);
    handles.scanWireBufferNum=min(handles.scanWirePulses*1.5*sum(use)+rate*6,2800);
    
    % Move wire to start position.
    scanWireInsert(hObject,handles);
    
    % Synchronize MOTR with LVDT.
    scanWireSynch(hObject,handles);
    
    % Do the scan
    switch handles.scanWireMode
        case 'wire'
            [handles,continueStatus_b,data]=scanStartWire(hObject,handles);
        case 'step'
            [handles,continueStatus_b,data]=scanStartStep(hObject,handles);
        case 'orbit'
            [handles,continueStatus_b,data]=scanStartOrbit(hObject,handles);
        case 'corr'
            [handles,continueStatus_b,data]=scanStartCorr(hObject,handles);
    end
    
    % If the Retract checkbox is checked, or wire is a fast wire scanner,
    % or "wire" is a beam finder wire in the undulator, then retract it.
    % Retract has a bit different meaning for different wires. 
    if handles.scanWirePark || ...     % Retract checkbox
            handles.isFWS || ...       % is Fast Wire Scanner
            strcmp(handles.sectorSel,'UNDH') && ~handles.isBOD
        scanWireRetract(hObject,handles);
    end
    
    % Synchronize MOTR with LVDT.
    scanWireSynch(hObject,handles);
    if strcmp(handles.sectorSel,'UNDH')
        lcaPut('SIOC:SYS0:ML00:CALC011',1);
    end
    
    % If scan was successful, or marginally successful and user elected
    % to continue, then in fact proceed, otherwise return now.
    if continueStatus_b ~= 1, return, end
    
    % Get optional simulation data and store and process data.
    handles=scanReadData(hObject,handles,data);
    
catch ex0
    try
        acquireAbort(hObject, handles);
        % If generated by MATLAB treat as internal error and print stacktrace
        % to stderr.
        if ~strncmp(ex0.identifier,WS_EXID_PREFIX,3)  
           lprintf(STDERR, '%s\n', getReport(ex0,'extended'));
        end
        uiwait(errordlg(...
            lprintf(STDERR,'Could not make scan. %s', ex0.message)));
    catch ex1
        if ~strncmp(ex0.identifier,WS_EXID_PREFIX,3)  
           lprintf(STDERR, '%s\n', getReport(ex0,'extended'));
        end
        message1 = sprintf('Could not make scan. %s. And could not cleanly abort. %s', ...
            ex0.message, ex1.message);
        uiwait(errordlg(lprintf(STDERR,message1)));
    end
end
if pmtLTUS756voltage ~= 0 % we changed this, put it back
    lcaPutSmart('HVM:LTUS:756:VoltageSet',pmtLTUS756voltage);
    pause(1)
end


gui_BSAControl(hObject,handles,0);  %--Release the EDEF after scan
if toroid_comparator_bypassed
	unbypassDL1ToroidComparatorInterlock(handles);
end

guidata(hObject, handles);

% --- Bypasses the MPS interlocks for IM02/IM03 (DL1 toroid comparators)
%     This function will do nothing if a bypass is already in place.
function bypass_implemented = bypassDL1ToroidComparatorInterlock(handles, duration)
wirescan_const;
msgtext='Bypassing IM02/IM03 toroid comparator MPS interlock...';
gui_statusDisp(handles.scanWireStatus_txt, ...
	lprintf(STDOUT,msgtext));
    
try
	level1_status = lcaGet('TORO:IN20:203:TC203L1_BYPS',0,'int');
	level2_status = lcaGet('TORO:IN20:203:TC203L2_BYPS',0,'int');
	if level1_status ~= 0 || level2_status ~= 0
        bypass_implemented = false;
		return;
	end
catch
	msgtext='Could not get IM02/IM03 MPS bypass status.';
	gui_statusDisp(handles.scanWireStatus_txt, ...
		lprintf(STDOUT,msgtext));
    bypass_implemented = false;
	return;
end
% OK, the interlock isn't already bypassed.
% We'll bypass it for the specified duration (in seconds).
try
	lcaPut('TORO:IN20:203:TC203L1_BYPC', duration);
	lcaPut('TORO:IN20:203:TC203L2_BYPC', duration);
	lcaPut('TORO:IN20:203:TC203L1_BYPV', 1);
	lcaPut('TORO:IN20:203:TC203L2_BYPV', 1);
    bypass_implemented = true;
	return;
catch
	msgtext='Could not change bypass state for IM02/IM03 MPS interlock.';
	gui_statusDisp(handles.scanWireStatus_txt, ...
		lprintf(STDOUT,msgtext));
    bypass_implemented = false;
	return;
end

% --- Unbypasses the MPS interlocks for IM02/IM03.
% This function will potentially unbypass a bypass
% which was generated via other means, so it needs
% to be used with caution.
function unbypassDL1ToroidComparatorInterlock(handles)
wirescan_const;

try
	lcaPut('TORO:IN20:203:TC203L1_BYPC', 0);
	lcaPut('TORO:IN20:203:TC203L2_BYPC', 0);
catch
	msgtext='Could not unbypass IM02/IM03 MPS interlock.';
	gui_statusDisp(handles.scanWireStatus_txt, ...
		lprintf(STDOUT,msgtext));
end

% ------------------------------------------------------------------------
function handles = acquireAbort(hObject, handles)

wirescan_const;

try
    
    gui_acquireAbortAll;
    if handles.isFWS %Reset motor for FWS
        stopFWS(hObject,handles);
    elseif handles.isBOD
        %    lcaPut(strcat(handles.scanWireName,':MOTR'),0);
    elseif ~strcmp(handles.sectorSel,'UNDH')
        lcaPut([handles.scanWireName ':STARTSCAN'],0);
    end
    if ~epicsSimul_status
        eDefAbort(handles.eDefNumber);
    end
    
catch ex 
    % If generated by MATLAB treat as internal error and print stacktrace
    % to stderr.
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s', ex.getReport());
    end
    error('WS:ERRORDURINGABORT', ...
        lprintf(STDERR, '%s %s',WS_ERRORDURINGABORT_MSG, ex.message));
    
end

% --- Executes on selection change in processToroid_pmu.
function processToroid_pmu_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.sector.(handles.sectorSel).processToroUsed(handles.scanWireId)=val;
processUpdate(hObject,handles);


% --- Executes on selection change in processPMT_pmu.
function processPMT_pmu_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.sector.(handles.sectorSel).processPMTUsed(handles.scanWireId)=val;
processUpdate(hObject,handles);


% --- Executes on selection change in processBPM_lbx.
function processBPM_lbx_Callback(hObject, eventdata, handles)

handles=processBPMControl(hObject,handles,get(handles.processBPM_lbx,'Value'));
processUpdate(hObject,handles);


% --- Executes on button press in processJitterCorr_box.
function processJitterCorr_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.sector.(handles.sectorSel).processJitterCorr(handles.scanWireId)=val;
processUpdate(hObject,handles);


% --- Executes on button press in scanWireX_box.
function processParam_box_Callback(hObject, eventdata, handles, tag)

handles.process.(tag)=get(hObject,'Value');
processUpdate(hObject,handles);


% --- Executes on mouse press over axes background.
function plotProcess_ax_ButtonDownFcn(hObject, eventdata, handles)

pos=get(hObject,'CurrentPoint');
tag=handles.scanWireLimitPick;
set(handles.plotProcess_ax,'HitTest','off');
set(gcbf,'Pointer','arrow');
if ishandle(handles.plotProcessLim), delete(handles.plotProcessLim);end
loc={'Inner' 'Outer'};
set(handles.(['scanWire' upper(tag{1}) loc{tag{2}} '_btn']),'Value',0);

[dirTag,dirId]=scanWireCurrentDir(hObject,handles);
data=handles.sector.(handles.sectorSel).data(handles.scanWireId,dirId);
if ~data.status || ~data.wireDir.(tag{1}), return, end
val=pos2wire(data,pos(1));val=val.(tag{1});
scanWireLimitControl(hObject,handles,tag{1},tag{2},val);


% --- Executes on button press in scanWireXInner_btn.
function scanWireLimit_btn_Callback(hObject, eventdata, handles, tags)

state=get(hObject,'Value');
hit={'off' 'on'};pointers={'arrow','crosshair'};
set(handles.plotProcess_ax,'HitTest',hit{state+1},'ButtonDownFcn', ...
    'wirescan_gui(''plotProcess_ax_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
if ishandle(handles.plotProcessLim), delete(handles.plotProcessLim);end
set(gcbf,'Pointer',pointers{state+1});
loc={'Inner' 'Outer'};
for tag={'x' 'y' 'u'}
    for j=1:2
        val=strcmp(tag,tags{1}) && j == tags{2} && state;
        set(handles.(['scanWire' upper(tag{:}) loc{j} '_btn']),'Value',val);
    end
end
handles.scanWireLimitPick=tags;
guidata(hObject,handles);

[dirTag,dirId]=scanWireCurrentDir(hObject,handles);
data=handles.sector.(handles.sectorSel).data(handles.scanWireId,dirId);
if ~data.status || ~data.wireDir.(tags{1}) || ~state, return, end
val=handles.scanWireLimit.(tags{1})(tags{2});
pos=wire2pos(data,val);pos=pos.(tags{1});
handles.plotProcessLim=line([1 1]*pos,get(handles.plotProcess_ax,'YLim'),'Parent',handles.plotProcess_ax,'Color','k','LineStyle',':');
guidata(hObject,handles);


% ------------------------------------------------------------------------
function pos = xy2pos(data, x, y)

pos.x=x;
pos.y=y;
pos.u=x*sind(data.wireAngle(1))+y*cosd(data.wireAngle(end));


% ------------------------------------------------------------------------
function pos = wire2pos(data, val)

if ~isstruct(val), val=struct('x',val,'y',val,'u',val);end
pos.x=(val.x-data.wireCenter.x)*sind(data.wireAngle(1));
pos.y=(val.y-data.wireCenter.y)*cosd(data.wireAngle(end));
pos.u=(val.u-data.wireCenter.u);


% ------------------------------------------------------------------------
function val = pos2wire(data, pos)

if ~isstruct(pos), pos=struct('x',pos,'y',pos,'u',pos);end
val.x=pos.x/sind(data.wireAngle(1))+data.wireCenter.x;
val.y=pos.y/cosd(data.wireAngle(end))+data.wireCenter.y;
val.u=pos.u                          +data.wireCenter.u;


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles, val)

[data,fileName]=util_dataLoad('Open wire scan');
if ~ischar(fileName), return, end
handles.fileName=fileName;

% Put data in handles.
if ~isfield(data,'name'), data.name=data.wireName;end
if ~isfield(data,'wireMode'), data.wireMode='wire';end
[handles.sectorSel,handles.scanWireId]=scanWireFind(hObject,handles,data.wireName);
use=cell2mat(struct2cell(data.wireDir));
for tag=fieldnames(data)'
    [handles.sector.(handles.sectorSel).data(handles.scanWireId,use).(tag{:})]=deal(data.(tag{:}));
end
tags='xyu';
handles=dataPlaneControl(hObject,handles,tags(find(use,1)));
handles=processUpdate(hObject,handles);


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

[dirTag,dirId]=scanWireCurrentDir(hObject,handles);
data=handles.sector.(handles.sectorSel).data(handles.scanWireId,dirId);
if ~any([data.status]), return, end
fileName=util_dataSave(data,'WireScan',data.wireName,data.ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

[dirTag,dirId]=scanWireCurrentDir(hObject,handles);
data=handles.sector.(handles.sectorSel).data(handles.scanWireId,dirId);
if ~any([data.status]), return, end

handles.exportFig=figure;
util_copyAxes(handles.plotProcess_ax);
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
if handles.processDisplayEllipse && isfield(handles.sector.(handles.sectorSel),'dataAll')
    axis equal
end
if val
    str='XYU';use=cell2mat(struct2cell(data.wireDir));
    util_printLog(handles.exportFig,'title',['Wirescan ' data.wireName ' ' str(use)]);
    dataSave(hObject,handles,0);
end


% --- Executes on button press in scanCalibrate_btn.
function scanCalibrate_btn_Callback(hObject, eventdata, handles)

set(handles.scanCalibrate_btn,'BackgroundColor','g');

% Read wire scanner data.
data=scanReadWireData(hObject,handles);
sector=handles.sector.(handles.sectorSel);
[wireDir,wireDirId]=scanWireCurrentDir(hObject,handles);

fdbkStat=lcaGetSmart(handles.fdbkList,0,'double');
lcaPut(handles.fdbkList,0);
handles.scanCorrName=sector.([upper(wireDir) 'CorDevList']){handles.scanWireId};
scanCorrPV=strcat(handles.scanCorrName,':BCTRL');
scanCorrVal=lcaGetSmart(scanCorrPV);
[rMat,en]=model_rMatGet(handles.scanCorrName,handles.scanWireName,[],{'R' 'EN'});
r12=rMat(1+wireDirId*2-2,2+wireDirId*2-2);
range=[-1000 1000 0];
bp=en/299.792458*1e4; % kG m
corrLimit=range*1e-6/r12*bp; % kg m
handles.scanCorrNum=length(range);
valList=scanCorrVal+corrLimit;
handles=scanWireModeControl(hObject,handles,'wire');
handles=scanWireAutoRangeControl(hObject,handles,1);
guidata(hObject,handles);

% Loop while scan is active.
for j=1:handles.scanCorrNum
    lcaPut([handles.scanCorrName ':BCTRL'],valList(j));
    pause(2.);
    handles=acquireStart(hObject,handles);
    calData=handles.sector.(handles.sectorSel).data(handles.scanWireId);
    calPos(j,1)=calData.beam(2).stats(wireDirId);
    pvList=strcat(data.BPMList(:),':',upper(wireDir));
    calBPM(j,:)=lcaGetSmart(pvList(:));
end

handles=scanWireModeControl(hObject,handles,'corr');
cal=lscov([calPos calPos*0+1],calBPM);
handles.sector.(handles.sectorSel).(['process' upper(wireDir) 'CorCal'])(handles.scanWireId,:)=1./cal(1,:);
guidata(hObject,handles);

set(handles.scanWireStatus_txt,'String','Done Calibration');
set(handles.scanCalibrate_btn,'BackgroundColor','default');
lcaPut(scanCorrPV,scanCorrVal);
lcaPut(handles.fdbkList,fdbkStat);


% --- Executes on button press in scanSetOffset_btn.
function scanSetOffset_btn_Callback(hObject, eventdata, handles)

sector=handles.sector.(handles.sectorSel);
[dirTag,dirId]=scanWireCurrentDir(hObject,handles);
data=sector.data(handles.scanWireId,dirId);
if ~any([data.status]), return, end
if strcmp(data.wireMode,'corr'), return, end

BPMPosX=data.BPMXData(data.selectBPM,data.wireMask); % BPM pos in mm
BPMPosY=data.BPMYData(data.selectBPM,data.wireMask);

% Calculate beam position at wire.
rMat=data.rMatList(:,:,data.selectBPM);
posX=beamAnalysis_orbitFit([],rMat(1:2,[1:2 6],:),(BPMPosX-0)*1e-3); % in m
posY=beamAnalysis_orbitFit([],rMat(3:4,[3:4 6],:),(BPMPosY-0)*1e-3);
WSPos=xy2pos(data,mean(posX(1,:))*1e6,mean(posY(1,:))*1e6); % Wire pos in um

% Get new wire range centers.
method=handles.dataMethod.iVal;
for tag='xyu'
    if data.wireDir.(tag)
        if tag == 'u'
            pos=0;
        else
            pos=data.beam(method).stats(tag-119);
        end
        if tag == 'u' && isfield(data.beam(method),'uStat') 
            pos=data.beam(method).uStat(2);
        end
        val=pos2wire(data,pos-WSPos.(tag));
        val.(tag)=round(val.(tag));
        pv=strcat(data.wireName,':',upper(tag),'WIREOFFSET');
        off=lcaGetSmart(pv);
        butList={'Proceed' 'Cancel'};
        button=questdlg({['Set new ' tag '-wire offset?'] ['New ' num2str(val.(tag))] ['Old ' num2str(off)]},'Wire Offset',butList{:},butList{2});
        if strcmp(button,butList{2}), continue, end
        lcaPut(pv,val.(tag));
        handles=scanWireLimitControl(hObject,handles,tag,1:2,[]);
    end
end
guidata(hObject,handles);


% --- Executes on button press in scanSetOffset_btn.
function scanSetWidth_btn_Callback(hObject, eventdata, handles)

sector=handles.sector.(handles.sectorSel);
[dirTag,dirId]=scanWireCurrentDir(hObject,handles);
data=sector.data(handles.scanWireId,dirId);
if ~any([data.status]), return, end
if strcmp(data.wireMode,'corr'), return, end

% Get new wire range width.
method=handles.dataMethod.iVal;
for tag='xyu'
    if data.wireDir.(tag)
        if tag == 'u'
            pos=0;width=diff(data.wireLimit.u)/10;
        else
            pos=data.beam(method).stats(tag-119);
            width=data.beam(method).stats(tag-119+2);
        end
        if tag == 'u' && isfield(data.beam(method),'uStat')
            pos=data.beam(method).uStat(2);
            width=data.beam(method).uStat(3);
        end
        val=pos2wire(data,pos+width*[-5 5]);
        limit=round(sort(val.(tag)));
        butList={'Proceed' 'Cancel'};
        button=questdlg({['Set new ' tag '-wire range?'] ['New ' num2str(limit)]},'Wire Range',butList{:},butList{2});
        if strcmp(button,butList{2}), continue, end
        handles=scanWireLimitControl(hObject,handles,tag,1:2,limit);
    end
end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = calLVDTRead(hObject, handles)

sevr=lcaGetStatus([handles.scanWireName ':SUBMPROF']);
if sevr, return, end
handles.posMot=lcaGetSmart([handles.scanWireName ':SUBMPROF']);
handles.posLVDT=lcaGetSmart([handles.scanWireName ':SUBLPROF']);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = calLVDTScan(hObject, handles)

scanWireMove(handles,handles.scanWireName,-Inf);
%lcaPut([handles.scanWireName ':MOTRLO.PROC'],1);
motMin=lcaGetSmart([handles.scanWireName ':MOTR.LLM']);
motMax=lcaGetSmart([handles.scanWireName ':MOTR.HLM']);
step=lcaGetSmart([handles.scanWireName ':CALSTEPSIZE']);
delay=lcaGetSmart([handles.scanWireName ':CALDELAYTIME']);

pos=motMin:step:motMax;posLVDT=pos*NaN;posMot=pos*NaN;
legend(handles.plotRaw_ax,'off');
hList=findobj(handles.plotRaw_ax,'Type','line');
set(hList,'XData',NaN,'YData',NaN);
set(findobj(handles.plotRaw_ax,'Type','text'),'String','');
for j=1:length(posMot)
    lcaPut([handles.scanWireName ':MOTR'],pos(j));
    pause(delay*1.5);
    posMot(j)=lcaGetSmart([handles.scanWireName ':MOTR']);
    posLVDT(j)=lcaGetSmart([handles.scanWireName ':LVRAW']);
    set(handles.plotScan.PMT(2),'XData',1:length(posMot),'YData',posMot);
    set(handles.plotScan.PMT(3),'XData',1:length(posMot),'YData',posLVDT);
end
scanWireMove(handles,handles.scanWireName,20000);
%lcaPut([handles.scanWireName ':MOTR'],20000);
handles.posMot=posMot;
handles.posLVDT=posLVDT;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = calLVDTPlot(hObject, handles)

if ~isfield(handles,'posMot'), return, end
posMot=handles.posMot;
posLVDT=handles.posLVDT;

poly=lcaGetSmart(strcat(handles.scanWireName,':LVPOS.',{'A';'B';'C';'D';'E';'F';'G';'H'}));
parOld=poly(end:-1:1);

scl=1e-3;fitOrd=handles.calLVDTOrder;

par=polyfit(posLVDT*scl,posMot*scl,fitOrd);
ex=length(par)-1:-1:0;
par=par.*scl.^(ex-1);
res=posMot-polyval(par,posLVDT);
resstd=std(res);

use=abs(res) <= 3*resstd;
par=polyfit(posLVDT(use)*scl,posMot(use)*scl,fitOrd);
ex=length(par)-1:-1:0;
par=par.*scl.^(ex-1);
posFit=polyval(par,posLVDT);
posFitOld=polyval(parOld,posLVDT);
res=posMot-posFit;resUse=res;resUse(~use)=NaN;
resstd=std(res(use));
handles.poly=par(end:-1:1);
guidata(hObject,handles);

str=sprintf('%+g x^%d ',[par;ex]);
motcal=1;ustr='mm';
%figure;
ax=handles.plotRaw_ax;
%ax=subplot(2,1,1);
hList=findobj(handles.plotRaw_ax,'Type','line');
set(hList,'XData',NaN,'YData',NaN);
set(handles.plotScan.PMT(2),'XData',posLVDT*1e-3,'YData',posMot*1e-3*motcal);
set(handles.plotScan.wireMasked,'XData',posLVDT*1e-3,'YData',posFit*1e-3*motcal);
set(handles.plotScan.PMT(3),'XData',posLVDT*1e-3,'YData',posFitOld*1e-3*motcal);
%plot(posLVDT*1e-3,posMot*1e-3*motcal,posLVDT*1e-3,posFit*1e-3*motcal,':r', ...
%    posLVDT*1e-3,posFitOld*1e-3*motcal,'g');
title(ax,[handles.scanWireName ' LVDT Calibration']);
%ylabel(ax,['Motor Position  (' ustr ')']);
%text(.1,.8,str,'Units','normalized','Parent',ax);
set(handles.plotScan.txt,'String',str);
legend(ax,'Data','Fit','Old Poly');legend(ax,'boxoff');

ax=handles.plotProcess_ax;
%ax=subplot(2,1,2);
plot(posLVDT*1e-3,res*motcal,posLVDT*1e-3,res*motcal,'--r', ...
    posLVDT*1e-3,(posMot-(posFitOld-parOld(end)+par(end)))*motcal,'g','Parent',ax);
title(ax,[handles.scanWireName ' LVDT Residual']);
xlabel(ax,'LVDT Rbck  (LVDT kBit)');
ylabel(ax,'Fit Residual  (\mum)');
text(.1,.8,sprintf('Residual std %5.0f \\mum',resstd*motcal),'Units','normalized','Parent',ax);
legend(ax,'Residual','Val. Res.','Old Poly');legend(ax,'boxoff');


% --- Executes on button press in scanSetOffset_btn.
function calLVDT_btn_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
if ~isfield(handles,'calLVDTOrder'), handles.calLVDTOrder=3;end
hList=[handles.calLVDTApply_btn;handles.calLVDTScan_btn; ...
    handles.calLVDTPlot_btn;handles.calLVDTOrder_txt;handles.calLVDTOrderLabel_txt];
if val
    gui_editControl(hObject,handles,'calLVDTOrder',[]);
    set(hList,'Visible','on');
    set(handles.calPMT_btn,'Visible','off');
    handles=calLVDTRead(hObject,handles);
    calLVDTPlot(hObject,handles);
else
    set(hList,'Visible','off');
    set(handles.calPMT_btn,'Visible','on');
    title(handles.plotRaw_ax,'');legend(handles.plotRaw_ax,'off');
    processUpdate(hObject,handles);
end


% --- Executes on button press in scanSetOffset_btn.
function calLVDTApply_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles,'poly'), return, end
poly=handles.poly;poly(end+1:8)=0;
lcaPut(strcat(handles.scanWireName,':LVPOS.',{'A';'B';'C';'D';'E';'F';'G';'H'}),poly');


% --- Executes on button press in calLVDTScan_btn.
function calLVDTScan_btn_Callback(hObject, eventdata, handles)

handles=calLVDTScan(hObject,handles);
calLVDTPlot(hObject,handles);


% --- Executes on button press in calLVDTPlot_btn.
function calLVDTPlot_btn_Callback(hObject, eventdata, handles)

calLVDTPlot(hObject,handles);


function calLVDTOrder_txt_Callback(hObject, eventdata, handles)

handles=gui_editControl(hObject,handles,'calLVDTOrder',str2double(get(hObject,'String')),1,1,0);
calLVDTPlot(hObject,handles);


% --- Executes on button press in sectorSelIN20_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag)

wirescan_const;
try
    sectorControl(hObject,handles,tag);
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Problem changing sector. %s', ex.message)));
end


% --- Executes on selection change in scanWireName_pmu.
function scanWireName_pmu_Callback(hObject, eventdata, handles)

wirescan_const;
try
    scanWireInit(hObject,handles,get(hObject,'Value'));
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        fprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Problem changing wire. %s', ex.message)));
end


% --- Executes on button press in scanWireX_box.
function scanWireDir_box_Callback(hObject, eventdata, handles, tag)

scanWireDirControl(hObject,handles,tag,get(hObject,'Value'));


function scanWirePulses_txt_Callback(hObject, eventdata, handles)

wirescan_const;
try
    scanWirePulsesControl(hObject,handles,...
        str2double(get(hObject,'String')));
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        fprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Problem auto setting scan pulses. %s', ex.message)));
end 

% ------------------------------------------------------------------------
function scanWireLimit_txt_Callback(hObject, eventdata, handles, tag, pos)

scanWireLimitControl(hObject,handles,tag,pos,str2double(get(hObject,'String')));

% ------------------------------------------------------------------------
function scanWireStepNum_txt_Callback(hObject, eventdata, handles)

scanWireStepNumControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on slider movement. ---------------------------------------
function dataMethod_sl_Callback(hObject, eventdata, handles)

dataMethodControl(hObject,handles,round(get(hObject,'Value')),[]);


% --- Executes on button press in scanWireAutoRange_box.
function scanWireAutoRange_box_Callback(hObject, eventdata, handles)

scanWireAutoRangeControl(hObject,handles,get(hObject,'Value'));


% --- Executes on selection change in scanWireMode_pmu.
function scanWireMode_pmu_Callback(hObject, eventdata, handles)

scanWireModeControl(hObject,handles,get(hObject,'Value'));


% --- Executes on selection change in scanWireMode_pmu.
function scanWirePark_box_Callback(hObject, eventdata, handles)

scanWireParkControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

acquireAbort(hObject,handles);


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);


% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

gui_appLoad(hObject,handles);


% --- Executes on button press in processDisplaySel_box.
function processDisplaySel_box_Callback(hObject, eventdata, handles)

handles=gui_checkBoxControl(hObject,handles,'processDisplaySel',get(hObject,'Value'));
scanPlot(hObject,handles);


% --- Executes on button press in processDisplayDispersion_box.
function processDisplayDispersion_box_Callback(hObject, eventdata, handles)

handles=gui_checkBoxControl(hObject,handles,'processDisplayDispersion',get(hObject,'Value'));
processPlot(hObject,handles);


% --- Executes on button press in processDisplayEllipse_box.
function processDisplayEllipse_box_Callback(hObject, eventdata, handles)

handles=gui_checkBoxControl(hObject,handles,'processDisplayEllipse',get(hObject,'Value'));
sector=handles.sector.(handles.sectorSel);
if handles.processDisplayEllipse && isfield(sector,'dataAll')
    data=sector.dataAll(handles.scanWireId);
    beamAnalysis_getEllipse(data.beam(handles.dataMethod.iVal).stats,[], ...
        'doPlot',1,'axes',handles.plotProcess_ax,'ts',min([sector.data(handles.scanWireId,:).ts]));
else
    processPlot(hObject,handles);
end


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in scanWireRetract_btn.
function scanWireRetract_btn_Callback(hObject, eventdata, handles)

scanWireRetract(hObject,handles);


% --- Executes on button press in dataPlaneX_rbn.
function dataPlane_rbn_Callback(hObject, eventdata, handles, tag)

dataPlaneControl(hObject,handles,tag);


% --- Executes on button press in scanWireAutoPulses_box.
function scanWireAutoPulses_box_Callback(hObject, eventdata, handles)

scanWireAutoPulsesControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in scanWireLimUnits_box.
function scanWireLimUnits_box_Callback(hObject, eventdata, handles)

scanWireLimUnitsControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in calPMT_btn.
function calPMT_btn_Callback(hObject, eventdata, handles)

lcaPut('IOC:BSY0:MP01:PCELLCTL',0); %turn off beam

data = scanReadWireData(hObject, handles);
PMTList=data.PMTList(:);
PMTdelta=zeros(length(PMTList),1);
if any(cell2mat(strfind(PMTList(:),'LTU')))
    % PMTdelta=[0;26;40;25;2;0;0;0;23]; %PMT715;755;820;970;971;1690;430;431;246
    %    PMTdelta=[0;23;0;0;40;0;0];
    % newPMT 122:246:550:755:820:850
    PMTdelta=[0;0;0;23;0;0;0;0];
end
% Read PMT data.
pvList=strcat(data.PMTList(:),':QDCRAWLO');
for j=1:100
    data.PMTData(:,:,j)=lcaGetSmart(pvList);
end
%Remove mean offset
pvList=strcat(data.PMTList(:),':QDCLOTHRESH');
lo_thresh=mean(data.PMTData,3);
hi_thresh=round(lo_thresh./8+PMTdelta);
lcaPut(pvList,lo_thresh);
pvList=strcat(data.PMTList(:),':QDCHITHRESH');
lcaPut(pvList,hi_thresh);
lcaPut('IOC:BSY0:MP01:PCELLCTL',1); %turn on beam

set(hObject,'Value',0)


% --- Executes on button press in scanRMatCalib_btn.
function scanRMatCalib_btn_Callback(hObject, eventdata, handles)

set(handles.scanWireStatus_txt,'String','Starting R-Mat Calibration ...');
set(handles.scanRMatCalib_btn,'BackgroundColor','g');
fdbkStat=lcaGetSmart(handles.fdbkList,0,'double');
lcaPut(handles.fdbkList,0);

sector=handles.sector.(handles.sectorSel);

corrName=[sector.XCorDevList(:,handles.scanWireId); ...
          sector.YCorDevList(:,handles.scanWireId)];
corrPlane=[ones(size(sector.XCorDevList(:,handles.scanWireId)));
           2*ones(size(sector.YCorDevList(:,handles.scanWireId)))];
scanCorrPV=strcat(corrName,':BCTRL');
scanCorrVal=lcaGetSmart(scanCorrPV);

bpmList=sector.BPMDevList;
selectBPM=sector.processBPMUsed(handles.scanWireId,:);
rMat=model_rMatGet(bpmList(1),bpmList);

% Loop through correctors.
for n=1:numel(corrName)
    [rMatC,en]=model_rMatGet(corrName(n),bpmList,[],{'R' 'EN'});
    r12=rMatC([1 3],[2 4],:);
    r12Max=diag(max(r12,[],3));
    range=[-300 300];
    bp=max(en/299.792458*1e4); % kG m
    corrLimit=range*1e-6/r12Max(corrPlane(n))*bp; % kG m
    valList=scanCorrVal(n)+corrLimit;
    num=numel(range);

    % Loop while scan is active.
    for j=1:num
        lcaPut(scanCorrPV(n),valList(j));
        pause(1);

        % Read BPM data.
        if ~epicsSimul_status
            sampleNum=10;
            eDefParams(handles.eDefNumber,1,sampleNum);
            eDefOn(handles.eDefNumber);nTry=100;
            while ~eDefDone(handles.eDefNumber) && nTry, nTry=nTry-1;pause(.1);end
            if ~nTry, return, end % timed out, no valid data to get
            pvList=strcat(bpmList,':XHST',num2str(handles.eDefNumber));
            BPMXData=lcaGetSmart(pvList,sampleNum);
            pvList=strcat(bpmList,':YHST',num2str(handles.eDefNumber));
            BPMYData=lcaGetSmart(pvList,sampleNum);
%            pvList=strcat(bpmList,':TMITHST',num2str(handles.eDefNumber));
%            BPMTData=lcaGetSmart(pvList,sampleNum);
        else
            BPMXData=lcaGetSmart(strcat(bpmList,':X'));
            BPMYData=lcaGetSmart(strcat(bpmList,':Y'));
%            BPMTData=lcaGetSmart(strcat(bpmList,':TMIT'));
        end
%        if ~all(all(BPMXData(selectBPM,:))), break, end
        BPMData(1,:,j)=mean(BPMXData(selectBPM,:),2); % BPM in mm
        BPMData(2,:,j)=mean(BPMYData(selectBPM,:),2);
    end
    lcaPut(scanCorrPV(n),scanCorrVal(n));
    BPMData=diff(BPMData,1,3);

    % Calculate beam position at wire.
    pos(:,n)=beamAnalysis_orbitFit([],rMat(1:4,1:4,:),BPMData(:)*1e-3); % in m
    cal(:,n)=pos(:,n)/diff(corrLimit)*bp;
end

handles.sector.(handles.sectorSel).(['process' 'CorCal'])=cal;
guidata(hObject,handles);

set(handles.scanWireStatus_txt,'String','Done R-Mat Calibration');
set(handles.scanRMatCalib_btn,'BackgroundColor','default');
lcaPut(scanCorrPV,scanCorrVal);
lcaPut(handles.fdbkList,fdbkStat);


% --- Executes on button press in scanRMatReset_btn.
function scanRMatReset_btn_Callback(hObject, eventdata, handles)

handles.sector.(handles.sectorSel).(['process' 'CorCal'])=[];
guidata(hObject,handles);


% --- Executes on button press in scanBFWtestMode_box.
function scanBFWtestMode_box_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function viewLog_Callback(hObject, eventdata, handles)
% ViewLog_Callback is called when View Log menu item is selected.
% A.t.t.o.w. Viewlog is under teh file menu.
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% vewLog_Callback finds and spawn a viewer of this application execution 
% instance specific log file.

wirescan_const;                  % Application constants
UNDEFLOGENV=...
   'Environment variable MATLAB_LOG_FILE_NAME is undefined or empty.';

try
    % Spawn command (defined by VIEWLOGCMD) to view log file. 
    logfile=getenv('MATLAB_LOG_FILE_NAME');
    if (~isempty(logfile))
        pid=feature('getpid');   % Pass pid to tail, to terminate tail 
                                 % when app process completes.
        [s,res]=system(sprintf(VIEWLOGCMD,logfile,logfile,pid));
        if s~=0
            uiwait(errordlg(sprintf('%s %s. Can not complete command %s',...
                WS_LOGFILEERR_MSG, res, VIEWLOGCMD)));
        end
    else
        uiwait(errordlg(sprintf('%s %s',WS_LOGFILEERR_MSG, UNDEFLOGENV)));
    end
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(....
        lprintf(STDERR,'Problem viewing log file. %s', ex.message)));
end

% -----------------------------------------------------------------------
function screenShot_Callback(hObject, eventdata, handles)
% screenShot_Callback is called when File->Screen Shot to Log menubar 
% item is selected. This function prints a screen shot of the GUI 
% to the Physics Log.
%
% hObject    handle to ScreenShot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find and spawn a viewer of the log file
wirescan_const;

% This function just sets a timer to execute screenShot_toLog in 1 second,
% since if the screenshot is actually done synchronously then the image
% would include the pulldown in action.
try
    screenShotTimer=timer;
    screenShotTimer.Name='ScreenShotTimer';
    screenShotTimer.StartDelay=1.0;
    screenShotTimer.ExecutionMode='singleShot';
    screenShotTimer.BusyMode='drop';
    screenShotTimer.TimerFcn=@(~,thisEvent)screenShot_toLog(handles);
    start(screenShotTimer);
catch ex
    delete(screenShotTimer);
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem putting screen shot in physics log. %s', ...
        ex.message)));
end

% ----------------------------------------------------------------------
function screenShot_toLog(handles)
% screenShot_toLog takes a screenshot of the GUI window and puts a png
% of it in the Physics logbook.

wirescan_const;
windowTitleText='Wire Scanner Control'; 
persistent SUCCESS; SUCCESS=0;
persistent ROWE; ROWE=1;

try
    % Find GUI screen id
    getWindowIdCmd=...
        sprintf('wmctrl -l | awk ''/%s/ {print $1}''',windowTitleText);
    [iss,winId_hextxt]=system(getWindowIdCmd);
    if ~isequal(iss,SUCCESS)
        error(lprintf(STDERR,...
            ['Could not get GUI window id for window %s. '...
            'System command %s got error %d.'],...
            windowTitleText, getWindowIdCmd, iss));
    end;
    if numel(winId_hextxt,ROWE) ~= 1
        error(lprintf(STDERR,...
            ['Could not get GUI window id. '...
            'More than one %s found on window manager. '...
            'Close others and try again.'],windowTitleText));
    end
    
    % Make screen capture of GUI screen
    pngfn=sprintf('%s.png',tempname);
    screencapture_cmd=sprintf('import -window "%s" %s',winId_hextxt,pngfn);
    [iss,msg]=system(screencapture_cmd);
    if ~isequal(iss,SUCCESS)
        error(lprintf(STDERR,...
            'Could not screen capture GUI window. %s',char(msg)));
    end;
    
    % Post screen capture to logbook
    loggerCmd='physicselog'; % Must be in PYTHONPATH. Note named as if module.
    logBookPostCmd=...
        sprintf('python -m %s lcls "Screenshot" %s "Wire Scan GUI Screenshot"',...
        loggerCmd, pngfn);
    [iss,msg]=system(logBookPostCmd);
    if ~isequal(iss,SUCCESS)
        error(lprintf(STDERR,...
            'Could not post screencapture png to log book. %s',char(msg)));
end;
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem putting screen shot in physics log. %s', ...
        ex.message)));
end

    



% [iss, winid]=system('screenshot.sh lcls "Wirescan GUI screen shot"');

function help_Callback(hObject, eventdata, handles)
% help_Callback is called when Help menubar item is selected. This
% function presents the online user guide documententation.
%
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find and spawn a viewer of the log file
wirescan_const;
try
    web(WIRESCANHELP_URL, '-browser');
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem viewing help. %s', ex.message)));
end


% ------------------------------------------------------------------
function controlsScreen_Callback(hObject, eventdata, handles, ...
                                 screenName)
% hObject    handle to Global (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% screenname The file name of the controls screen to launch. At the
% time
%            of writing this must be an EDM file *.edl which must
%            be 
%            in the path given by EDMDATAFILES.
%
% controlsScreen_Callback launches a given control "panel",
% specified by
% argument screenName.

wirescan_const;

try
    cmd=sprintf(SCREENCOMMAND,screenName);
    [iss,res]=system(cmd);
    if iss~=0
        uiwait(errordlg(WS_CANTOPENCONTROLSSCREEN_MSG,cmd,res));
    end
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(lprintf(STDERR,['Problem openning controls screen. ' ...
                        '%s'], ex.message)));
end


% ------------------------------------------------------------------
function striptool_Callback(hObject, eventdata, handles, striptool_fn)
% hObject    handle to Global (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% striptool_Callback launches the (one) wire scanner striptool with
% config file.

wirescan_const;

try
    cmd=sprintf(STRIPTOOLCMD,fullfile('${STRIP_CONFIGFILE_DIR}',striptool_fn));
    [iss,res]=system(cmd);
    if iss~=0
        uiwait(errordlg(WS_CANTLAUNCH_MSG,cmd,res));
    end
catch ex
    if ~strncmp(ex.identifier,WS_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(lprintf(STDERR,'Problem starting program. %s', ...
                            ex.message)));
end
