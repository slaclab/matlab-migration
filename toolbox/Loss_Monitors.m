function varargout = Loss_Monitors(varargin)
% Loss_Monitors M-file for Loss_Monitors.fig
%      Loss_Monitors, by itself, creates a new Loss_Monitors or raises
%      the existing singleton*.
%
%      H = Loss_Monitors returns the handle to a new Loss_Monitors or the
%      handle to the existing singleton*.
%
%      Loss_Monitors('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in Loss_Monitors.m with the given
%      input arguments.
%
%      Loss_Monitors('Property','Value',...) creates a new Loss_Monitors
%      or raises the existing singleton*.  Starting from the left,
%      property value pairs are applied to the GUI before
%      Loss_Monitors_OpeningFcn gets called.  An unrecognized property
%      name or invalid value makes property application stop.
%      All inputs are passed to Loss_Monitors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Loss_Monitors

% Last Modified by GUIDE v2.5 05-Aug-2010 17:17:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Loss_Monitors_OpeningFcn, ...
                   'gui_OutputFcn',  @Loss_Monitors_OutputFcn, ...
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


% --- Executes just before Loss_Monitors is made visible.
function Loss_Monitors_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Loss_Monitors (see VARARGIN)

% Choose default command line output for Loss_Monitors
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Loss_Monitors wait for user response (see UIRESUME)
% uiwait(handles.Loss_Monitors);

jar = '/usr/local/lcls/physics/beamlineZplot/jar/beamlineZplot.jar';
if exist(jar,'file')
    javaaddpath(jar);
end

jar = '/usr/local/lcls/physics/xyplot/jar/xyplot.jar';
if exist(jar,'file')
    javaaddpath(jar);
end

jar = '/usr/local/lcls/physics/xyplot/lib/jcommon-1.0.13.jar';
if exist(jar,'file')
    javaaddpath(jar);
end

jar = '/usr/local/lcls/physics/xyplot/lib/servlet.jar';
if exist(jar,'file')
    javaaddpath(jar);
end

jar = '/usr/local/lcls/physics/SLAColors/jar/SLAColors.jar';
if exist(jar,'file')
    javaaddpath(jar);
end

javaclasspath

global gBLM

try
% 	myCounter_pv = 'SIOC:SYS0:ML00:AO399';
% 	lcaPut(myCounter_pv, 1+lcaGet(myCounter_pv))
%     counter = lcaGet(myCounter_pv)
%     myName = sprintf('Loss monitor %d',counter)
%     myNAVG = 1;
%     myNRPOS = 1;
%     gBLM.myeDefNumber = eDefReserve(myName);
%     event = sprintf('%d',gBLM.myeDefNumber)
%     eDefParams (gBLM.myeDefNumber, myNAVG, myNRPOS, {''},...
%         {'TS4';'pockcel_perm'},{''},{''})
    
    
%     % Beam-position monitors (with SumL coordinates in meters)
%     gBLM.BPM_list = { ...
%         'BPMS:LTU1:720'     'BPME31'  1418.523 ; % BPMs at collimators
%         'BPMS:LTU1:730'     'BPME32'  1436.155 ;
%         'BPMS:LTU1:740'     'BPME33'  1453.786 ;
%         'BPMS:LTU1:750'     'BPME34'  1471.418 ;
%         'BPMS:LTU1:760'     'BPME35'  1489.050 ;
%         'BPMS:LTU1:770'     'BPME36'  1506.682 ;
%         'BPMS:LTU1:910'     'RFB07'   1541.868 ;
%         'BPMS:LTU1:960'     'RFB08'   1544.616 ;
%         'BPMS:UND1:100'     'RFBU00'  1548.468 ; % BPMs at undulator girders
%         'BPMS:UND1:190'     'RFBU01'  1552.338 ;
%         'BPMS:UND1:290'     'RFBU02'  1556.208 ;
%         'BPMS:UND1:390'     'RFBU03'  1560.078 ;
%         'BPMS:UND1:490'     'RFBU04'  1564.376 ;
%         'BPMS:UND1:590'     'RFBU05'  1568.246 ;
%         'BPMS:UND1:690'     'RFBU06'  1572.116 ;
%         'BPMS:UND1:790'     'RFBU07'  1576.414 ;
%         'BPMS:UND1:890'     'RFBU08'  1580.284 ;
%         'BPMS:UND1:990'     'RFBU09'  1584.154 ;
%         'BPMS:UND1:1090'    'RFBU10'  1588.452 ;
%         'BPMS:UND1:1190'    'RFBU11'  1592.322 ;
%         'BPMS:UND1:1290'    'RFBU12'  1596.192 ;
%         'BPMS:UND1:1390'    'RFBU13'  1600.490 ;
%         'BPMS:UND1:1490'    'RFBU14'  1604.360 ;
%         'BPMS:UND1:1590'    'RFBU15'  1608.230 ;
%         'BPMS:UND1:1690'    'RFBU16'  1612.528 ;	
%         'BPMS:UND1:1790'    'RFBU17'  1616.398 ;	
%         'BPMS:UND1:1890'    'RFBU18'  1620.268 ;
%         'BPMS:UND1:1990'    'RFBU19'  1624.566 ;
%         'BPMS:UND1:2090'    'RFBU20'  1628.436 ;	
%         'BPMS:UND1:2190'    'RFBU21'  1632.306 ;
%         'BPMS:UND1:2290'    'RFBU22'  1636.604 ;
%         'BPMS:UND1:2390'    'RFBU23'  1640.474 ;
%         'BPMS:UND1:2490'    'RFBU24'  1644.344 ;
%         'BPMS:UND1:2590'    'RFBU25'  1648.642 ;
%         'BPMS:UND1:2690'    'RFBU26'  1652.512 ;
%         'BPMS:UND1:2790'    'RFBU27'  1656.382 ;
%         'BPMS:UND1:2890'    'RFBU28'  1660.680 ;
%         'BPMS:UND1:2990'    'RFBU29'  1664.550 ;
%         'BPMS:UND1:3090'    'RFBU30'  1668.420 ;
%         'BPMS:UND1:3190'    'RFBU31'  1672.718 ;	
%         'BPMS:UND1:3290'    'RFBU32'  1676.588 ;
%         'BPMS:UND1:3390'    'RFBU33'  1680.458 ;
%         'BPMS:UND1:3390'    'RFBU33'  1680.458 ;
%         'BPMS:DMP1:299'     'BPMUE1'  1692.044 ;
%         'BPMS:DMP1:381'     'BPMUE2'  1705.588 ;
%         'BPMS:DMP1:398'     'BPMUE3'  1720.054 ;
%         'BPMS:DMP1:502'     'BPMQD'   1737.557 ;
%         'BPMS:DMP1:693'     'BPMDD'   1746.333};
    
    % PEP-II BLMs (BLMPs)
    gBLM.BLMP_list = { ...         
        'BLM:LTU1:722'      'BLMP-CX31'   1419.813 ; % PEP-II BLMs at the
        'BLM:LTU1:732'      'BLMP-CY32'   1437.445 ; % collimatorsin the LTU
        'BLM:LTU1:762'      'BLMP-CX35'   1490.340 ;
        'BLM:LTU1:772'      'BLMP-CY36'   1507.972 ;
        'BLM:LTU1:980'      'BLMP-PCMUON' 1547.691 ;
        'BLM:UND1:121'      'BLMP-U01'    1548.600 ; % PEP-II BLMs at the
        'BLM:UND1:221'      'BLMP-U02'    1552.470 ; % beam-finder wires
        'BLM:UND1:321'      'BLMP-U03'    1556.340 ; % on the undulator girders
        'BLM:UND1:421'      'BLMP-U04'    1560.638 ;
        'BLM:UND1:521'      'BLMP-U05'    1564.508 ;
        'BLM:UND1:621'      'BLMP-U06'    1568.378 ;
        'BLM:UND1:721'      'BLMP-U07'    1572.676 ;
        'BLM:UND1:821'      'BLMP-U08'    1576.546 ;
        'BLM:UND1:921'      'BLMP-U09'    1580.416 ;
        'BLM:UND1:1021'     'BLMP-U10'    1584.714 ;
        'BLM:UND1:1121'     'BLMP-U11'    1588.584 ;
        'BLM:UND1:1221'     'BLMP-U12'    1592.454 ;
        'BLM:UND1:1321'     'BLMP-U13'    1596.752 ;
        'BLM:UND1:1421'     'BLMP-U14'    1600.622 ;
        'BLM:UND1:1521'     'BLMP-U15'    1604.492 ;
        'BLM:UND1:1621'     'BLMP-U16'    1608.790 ;
        'BLM:UND1:1721'     'BLMP-U17'    1612.660 ;
        'BLM:UND1:1821'     'BLMP-U18'    1616.530 ;
        'BLM:UND1:1921'     'BLMP-U19'    1620.828 ;
        'BLM:UND1:2021'     'BLMP-U20'    1624.668 ;
        'BLM:UND1:2121'     'BLMP-U21'    1628.568 ;
        'BLM:UND1:2221'     'BLMP-U22'    1632.866 ;
        'BLM:UND1:2321'     'BLMP-U23'    1636.736 ;
        'BLM:UND1:2421'     'BLMP-U24'    1640.606 ;
        'BLM:UND1:2521'     'BLMP-U25'    1644.904 ;
        'BLM:UND1:2621'     'BLMP-U26'    1648.774 ;
        'BLM:UND1:2721'     'BLMP-U27'    1652.644 ;
        'BLM:UND1:2821'     'BLMP-U28'    1656.942 ;
        'BLM:UND1:2921'     'BLMP-U29'    1660.812 ;
        'BLM:UND1:3021'     'BLMP-U30'    1664.682 ;
        'BLM:UND1:3121'     'BLMP-U31'    1668.980 ;
        'BLM:UND1:3221'     'BLMP-U32'    1672.850 ;
        'BLM:UND1:3321'     'BLMP-U33'    1676.720};
  
    % Argonne BLMs (BLMAs) at undulator girders
    gBLM.BLMA_list = {...                
        'BLM:UND1:120'      'BLMA-U01'    1548.580 ;
        'BLM:UND1:920'      'BLMA-U09'    1580.396 ;
        'BLM:UND1:1720'     'BLMA-U17'    1612.640 ;
        'BLM:UND1:2520'     'BLMA-U25'    1644.884 ;
        'BLM:UND1:3320'     'BLMA-U33'    1676.700};

% Until the link nodes are ready, a few channels are available on scopes.
% PEP-II BLMs at collimators
%     gBLM.BLMP_list = {               
%         'SCOP:UND1:BLF1'       'BLMP-CX31'    1419.813  1 ;
%         'SCOP:UND1:BLF1'       'BLMP-CY32'    1437.445  2 ;
%         'SCOP:UND1:BLF1'       'BLMP-CX35'    1490.340  3 ;
%         'SCOP:UND1:BLF1'       'BLMP-CY36'    1507.972  4};
% PEP-II BLMs at undulator girders
%     gBLM.BLMP_list = { ...         
%         'SCOP:UND1:BLF1'            'BLMP-U01'	1548.600  1 ;
%         'SCOP:UND1:BLF1'            'BLMP-U09'	1580.416  3 ;
%         'SCOP:UND1:BLF2'            'BLMP-U17'	1612.660  1 ;
%         'SCOP:UND1:BLF2'            'BLMP-U25'	1644.904  2 ;
%         'SCOP:UND1:BLF2'            'BLMP-U33'	1676.720  3 ;
%         'BLM:UND1:2221:1S_BE_DOSE1' 'BLMP-U22'	1632.866  0 ;
%         'BLM:UND1:2321:1S_BE_DOSE2' 'BLMP-U23'	1636.736  0 ;
%         'BLM:UND1:2421:1S_BE_DOSE3' 'BLMP-U24'	1640.606  0 ;
%         'BLM:UND1:2621:1S_BE_DOSE5' 'BLMP-U26'	1648.774  0 ;
%         'BLM:UND1:2721:1S_BE_DOSE6' 'BLMP-U27'	1652.644  0 ;
%         'BLM:UND1:2821:1S_BE_DOSE7' 'BLMP-U28'  1656.942  0 ;
%         'BLM:UND1:2921:1S_BE_DOSE8' 'BLMP-U29'  1660.812  0};
% Argonne BLMs at undulator girders
%     gBLM.BLMA_list = {...               
%         'SCOP:UND1:BLF1'            'BLMA-U01'	1548.580  2 ;
%         'SCOP:UND1:BLF1'            'BLMA-U09'	1580.396  4 ;
%         'SCOP:UND1:BLF2'            'BLMA-U33'	1676.720  4 ;
%         'BLM:UND1:2520:1S_BE_DOSE4' 'BLMA-U25'	1644.904  0};
    
    % Loss detectors at vertical bend leading to beam dump
	gBLM.Cher_list = {...
        'PMT:DMP1:430:QDCRAW'	'DMP-PMT' 1725.95}; % Cherenkov
	gBLM.Scint_list = {...
        'PMT:DMP1:431:QDCRAW'	'DMP-PMT' 1726.00}; % Scintillator

    % Fiber-optic PLICs, read two ways:
    % First, total loss from an integrating digitizer
    gBLM.FiberI_list = {...
        'PMT:LTU1:755:QDCRAW'	'WS33'    1480.234  1545.531 ;    % Along the LTU
        'PMT:LTU1:820:QDCRAW'	'QUM1'    1521.478  1542.368 ;
        'BLM:UND1:BLF1:LOSS_1'	'BFW-U01' 1548.570  1612.528 ;    % Along the undulator
        'BLM:UND1:BLF17:LOSS_1' 'BFW-U17' 1612.630  1685.030};
    % Next, the trace from the waveform digitizer.
    % We include the digitizer's channel number, and the range of indices
    % in the ~4-us waveform that have actual loss data.
    % Channels 1 and 2 are along the LTU, but 2 has loops two fiber strands
    % and so has no clear time-space relationship.
    % Channels 3 and 4 are along the undulator.
    gBLM.FiberP_list = {...
        'UBLF:UND1:500:BLF1'	'WS33'    1480.234  1545.531  1 164 246 ;
        'UBLF:UND1:500:BLF1'	'QUM1'    1521.478  1542.368  2   1   2 ;
        'UBLF:UND1:500:BLF1'	'BFW-U01' 1548.570  1612.528  3 194 260 ;
        'UBLF:UND1:500:BLF1'	'BFW-U17' 1612.630  1685.030  4 264 336};
    
    % Count the number of devices.
    % Each is in a matrix, with row 1 being the number installed and row 2
    % being the number in use now. Column 1 is for the LTU, column 2 is for
    % the undulator, and column 3 is the total.
    
%     gBLM.nBPM(1)    = size(gBLM.BPM_list,1);
%     gBLM.nBPM(2)    = 0;
    
    gBLM.nBLMP(1)   = size(gBLM.BLMP_list,1);
    gBLM.nBLMP(2)   = 0;
    
    gBLM.nBLMA(1)   = size(gBLM.BLMA_list,1);
    gBLM.nBLMA(2)   = 0;
    
    gBLM.nCher(1)   = size(gBLM.Cher_list,1);
    gBLM.nCher(2)   = 0;
    
    gBLM.nScint(1)  = size(gBLM.Scint_list,1);
    gBLM.nScint(2)  = 0;
    
    gBLM.nFiberI(1) = size(gBLM.FiberI_list,1);
    gBLM.nFiberI(2) = 0;
    
    gBLM.nFiberP(1) = size(gBLM.FiberP_list,1);
    gBLM.nFiberP(2) = 0;
    
    
    % Initialize arrays.
%     gBLM.BPMx_PVs    =  cell(gBLM.nBPM(1),  1);
%     gBLM.BPMy_PVs    =  cell(gBLM.nBPM(1),  1);
%     gBLM.BPM_names   =  cell(gBLM.nBPM(1),  1);
%     gBLM.BPM_z       = zeros(gBLM.nBPM(1),  1);

    gBLM.BLMP_PVs    =  cell(gBLM.nBLMP(1), 1);
    gBLM.BLMP_names  =  cell(gBLM.nBLMP(1), 1);
    gBLM.BLMP_z      = zeros(gBLM.nBLMP(1), 1);
    % gBLM.BLMP_chan   = zeros(gBLM.nBLMP(1), 1);

    gBLM.BLMA_PVs    =  cell(gBLM.nBLMA(1), 1);
    gBLM.BLMA_names  =  cell(gBLM.nBLMA(1), 1);
    gBLM.BLMA_z      = zeros(gBLM.nBLMA(1), 1);
    % gBLM.BLMA_chan   = zeros(gBLM.nBLMA(1), 1);

    gBLM.Cher_PVs    =  cell(gBLM.nCher(1), 1);
    gBLM.Cher_names  =  cell(gBLM.nCher(1), 1);
    gBLM.Cher_z      = zeros(gBLM.nCher(1), 1);

    gBLM.Scint_PVs   =  cell(gBLM.nScint(1), 1);
    gBLM.Scint_names =  cell(gBLM.nScint(1), 1);
    gBLM.Scint_z     = zeros(gBLM.nScint(1), 1);

    gBLM.FiberI_PVs  =  cell(gBLM.nFiberI(1),1);
    gBLM.FiberI_names=  cell(gBLM.nFiberI(1),1);
    gBLM.FiberI_z    = zeros(gBLM.nFiberI(1),2);
    % gBLM.FiberI_chan = zeros(gBLM.nFiberI(1),1);

    gBLM.FiberP_PVs  =  cell(gBLM.nFiberP(1),1);
    gBLM.FiberP_names=  cell(gBLM.nFiberP(1),1);
    gBLM.FiberP_z    = zeros(gBLM.nFiberP(1),2);
    gBLM.FiberP_chan = zeros(gBLM.nFiberP(1),1);
    gBLM.FiberP_index= zeros(gBLM.nFiberP(1),2);

    % Fill out the lists for these devices.

%     % BPM
%     suffix=num2str(gBLM.myeDefNumber);
%     if(gBLM.nBPM(1) > 0)
%         for n=1:gBLM.nBPM(1)
%             gBLM.BPMx_PVs{n}  =[gBLM.BPM_list{n,1},':X',suffix];
%             gBLM.BPMy_PVs{n}  =[gBLM.BPM_list{n,1},':Y',suffix];
%             gBLM.BPMt_PVs{n}  =[gBLM.BPM_list{n,1},':TMIT',suffix];
%             gBLM.BPM_names{n} = gBLM.BPM_list{n,2};
%             gBLM.BPM_z(n)     = gBLM.BPM_list{n,3};
%         end
%     end

    % BLMPs (PEP BLMs)
    if(gBLM.nBLMP(1) > 0)
        for n=1:gBLM.nBLMP(1)
            gBLM.BLMP_PVs{n}  =[gBLM.BLMP_list{n,1},':LOSS_1'];
            gBLM.BLMP_names{n}= gBLM.BLMP_list{n,2};
            gBLM.BLMP_z(n)    = gBLM.BLMP_list{n,3};
            % gBLM.BLMP_chan(n) = gBLM.BLMP_list{n,4};
        end
    end

    % BLMAs (Argonne BLMs)
    if(gBLM.nBLMA(1) > 0)
        for n=1:gBLM.nBLMA(1)
            gBLM.BLMA_PVs{n}  =[gBLM.BLMA_list{n,1},':LOSS_1'];
            gBLM.BLMA_names{n}= gBLM.BLMA_list{n,2};
            gBLM.BLMA_z(n)    = gBLM.BLMA_list{n,3};
            % gBLM.BLMA_chan(n) = gBLM.BLMA_list{n,4};
        end
    end

    % PMT with Cherenkov detector at beam dump
    if(gBLM.nCher(1) > 0)
        for n=1:gBLM.nCher(1)
            gBLM.Cher_PVs{n}  = gBLM.Cher_list{n,1};
            gBLM.Cher_names{n}= gBLM.Cher_list{n,2};
            gBLM.Cher_z(n)    = gBLM.Cher_list{n,3};
        end
    end

    % PMT with scintillator at beam dump
    if(gBLM.nScint(1) > 0)
        for n=1:gBLM.nScint(1)
            gBLM.Scint_PVs{n}  = gBLM.Scint_list{n,1};
            gBLM.Scint_names{n}= gBLM.Scint_list{n,2};
            gBLM.Scint_z(n)    = gBLM.Scint_list{n,3};
        end
    end

    % Fiber-Optic PLICs using the integrating digitizer
    if(gBLM.nFiberI(1) > 0)
        for n=1:gBLM.nFiberI(1)
            gBLM.FiberI_PVs{n}  = gBLM.FiberI_list{n,1};
            gBLM.FiberI_names{n}= gBLM.FiberI_list{n,2};
            gBLM.FiberI_z(n,:)  =[gBLM.FiberI_list{n,3} gBLM.FiberI_list{n,4}];
        end
    end

    % Fiber-Optic PLICs using the peak from the waveform digitizer
    if(gBLM.nFiberP(1) > 0)
        for n=1:gBLM.nFiberP(1)
            gBLM.FiberP_PVs{n}    = gBLM.FiberP_list{n,1};
            gBLM.FiberP_names{n}  = gBLM.FiberP_list{n,2};
            gBLM.FiberP_z(n,:)    =[gBLM.FiberP_list{n,3} gBLM.FiberP_list{n,4}];
            gBLM.FiberP_chan(n)   = gBLM.FiberP_list{n,5};
            gBLM.FiberP_index(n,:)=[gBLM.FiberP_list{n,6} gBLM.FiberP_list{n,7}];
        end
    end
    
%     ActiveDevices(get(handles.BPM,    'Value'),...
    ActiveDevices(get(handles.BLMP,   'Value'),...
                  get(handles.BLMA,   'Value'),...
                  get(handles.Cher,   'Value'),...
                  get(handles.Scint,  'Value'),...
                  get(handles.FiberI, 'Value'),...
                  get(handles.FiberP, 'Value'))

catch
    disp('Error: eDef setup didn''t work.')
end
end


% --- Set up the lists of devices.
function ActiveDevices(... % BPM_on,
    BLMP_on,BLMA_on,...
    Cher_on,Scint_on,FiberI_on,FiberP_on)
% The user selects which BLMs (and BPMs) are active (using the GUI).

global gBLM

% How many devices are active?
% gBLM.nBPM(2)   = gBLM.nBPM(1)   *BPM_on;
gBLM.nBLMP(2)  = gBLM.nBLMP(1)  *BLMP_on;
gBLM.nBLMA(2)  = gBLM.nBLMA(1)  *BLMA_on;
gBLM.nCher(2)  = gBLM.nCher(1)  *Cher_on;
gBLM.nScint(2) = gBLM.nScint(1) *Scint_on;
gBLM.nFiberI(2)= gBLM.nFiberI(1)*FiberI_on;
gBLM.nFiberP(2)= gBLM.nFiberP(1)*FiberP_on;

end




% --- Outputs from this function are returned to the command line.
function varargout = Loss_Monitors_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% --- Executes when user attempts to close Loss_Monitors.
function Loss_Monitors_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Loss_Monitors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBLM

if isfield(gBLM, 't')
    stop(gBLM.t);
end
if isfield(gBLM,'myeDefNumber')
    sprintf('Release eDef %d on exit',gBLM.myeDefNumber);
    eDefRelease(gBLM.myeDefNumber)
end
util_appClose (hObject)
lcaClear()
end



% --- Executes during object creation, after setting all properties.
function Loss_Monitors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Loss_Monitors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

end



% --- Executes during object creation, after setting all properties.
%Commented out function line. Axes are not needed, but just in case...
%function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1



% --- Executes on button press in BPM.
% function BPM_Callback(hObject, eventdata, handles)
% % hObject    handle to BPM (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of BPM
% 
% ActiveDevices(get(handles.BPM,    'Value'),...
%               get(handles.BLMP,   'Value'),...
%               get(handles.BLMA,   'Value'),...
%               get(handles.Cher,   'Value'),...
%               get(handles.Scint,  'Value'),...
%               get(handles.FiberI, 'Value'),...
%               get(handles.FiberP, 'Value'))
% end



% --- Executes on button press in BLMP.
function BLMP_Callback(hObject, eventdata, handles)
% hObject    handle to BLMP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BLMP

% ActiveDevices(get(handles.BPM,    'Value'),...
ActiveDevices(get(handles.BLMP,   'Value'),...
              get(handles.BLMA,   'Value'),...
              get(handles.Cher,   'Value'),...
              get(handles.Scint,  'Value'),...
              get(handles.FiberI, 'Value'),...
              get(handles.FiberP, 'Value'))
end

    

% --- Executes on button press in BLMA.
function BLMA_Callback(hObject, eventdata, handles)
% hObject    handle to BLMA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BLMA

% ActiveDevices(get(handles.BPM,    'Value'),...
ActiveDevices(get(handles.BLMP,   'Value'),...
              get(handles.BLMA,   'Value'),...
              get(handles.Cher,   'Value'),...
              get(handles.Scint,  'Value'),...
              get(handles.FiberI, 'Value'),...
              get(handles.FiberP, 'Value'))
end



% --- Executes on button press in Cher.
function Cher_Callback(hObject, eventdata, handles)
% hObject    handle to Cher (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cher

% ActiveDevices(get(handles.BPM,    'Value'),...
ActiveDevices(get(handles.BLMP,   'Value'),...
              get(handles.BLMA,   'Value'),...
              get(handles.Cher,   'Value'),...
              get(handles.Scint,  'Value'),...
              get(handles.FiberI, 'Value'),...
              get(handles.FiberP, 'Value'))
end



% --- Executes on button press in Scint.
function Scint_Callback(hObject, eventdata, handles)
% hObject    handle to Scint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Scint

% ActiveDevices(get(handles.BPM,    'Value'),...
ActiveDevices(get(handles.BLMP,   'Value'),...
              get(handles.BLMA,   'Value'),...
              get(handles.Cher,   'Value'),...
              get(handles.Scint,  'Value'),...
              get(handles.FiberI, 'Value'),...
              get(handles.FiberP, 'Value'))
end


       
% --- Executes on button press in FiberI.
function FiberI_Callback(hObject, eventdata, handles)
% hObject    handle to FiberI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FiberI

% ActiveDevices(get(handles.BPM,    'Value'),...
ActiveDevices(get(handles.BLMP,   'Value'),...
              get(handles.BLMA,   'Value'),...
              get(handles.Cher,   'Value'),...
              get(handles.Scint,  'Value'),...
              get(handles.FiberI, 'Value'),...
              get(handles.FiberP, 'Value'))
end



% --- Executes on button press in FiberP.
function FiberP_Callback(hObject, eventdata, handles)
% hObject    handle to FiberP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FiberP

% ActiveDevices(get(handles.BPM,    'Value'),...
ActiveDevices(get(handles.BLMP,   'Value'),...
              get(handles.BLMA,   'Value'),...
              get(handles.Cher,   'Value'),...
              get(handles.Scint,  'Value'),...
              get(handles.FiberI, 'Value'),...
              get(handles.FiberP, 'Value'))
end



% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopButton

set(handles.StartButton,'Value',0)
set(handles.StopButton, 'Value',0)

global gBLM

if isfield(gBLM, 't')
    stop(gBLM.t);
end
end


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StartButton

global gBLM

if(isfield(gBLM,'t'))
  	% Don't start a duplicate plot, and keep button in True state.
  	set(handles.StartButton,'Value',1)
else
    import edu.stanford.slac.util.zplot.*
%     numPlots=4;
    numPlots=1;
    panel = javax.swing.JPanel();
    frame = javax.swing.JFrame();
    gBLM.zPlot = edu.stanford.slac.util.zplot.ZPlot(numPlots);
    gBLM.zPlotPanel = edu.stanford.slac.util.zplot.ZPlotPanel(panel, gBLM.zPlot);
%     setPreferredSize(frame, java.awt.Dimension(800,1000));
    setPreferredSize(frame, java.awt.Dimension(800,500));
    pack(frame);
    add(frame,panel);
    setVisible(frame,1);
    
%     PlotX      = getSubplot(gBLM.zPlot, 0);
%     PlotY      = getSubplot(gBLM.zPlot, 1);
%     PlotT      = getSubplot(gBLM.zPlot, 2);
%     PlotL      = getSubplot(gBLM.zPlot, 3);
    PlotL      = getSubplot(gBLM.zPlot, 0);

%     xRangeAxis    = getRangeAxis(Plot1);
%     yRangeAxis    = getRangeAxis(Plot2);
%     tRangeAxis    = getRangeAxis(Plot3);
%     lossRangeAxis = getRangeAxis(Plot4);
    lossRangeAxis = getRangeAxis(PlotL);

%     setLabel(xRangeAxis,'BPM X [mm]');
%     setLabel(yRangeAxis,'BPM Y [mm]');
%     setLabel(tRangeAxis,'BPM TMIT [1E9]');
    setLabel(lossRangeAxis,'Beam Loss [V]');

    % Fixed scale or autorange?
    % setAutoRangeIncludesZero(tRangeAxis, true);
%     setAutoRange(xRangeAxis, false);
%     setRange(xRangeAxis, -1, 1);
%     setAutoRange(yRangeAxis, false);
%     setRange(yRangeAxis, -1, 1);
%     setAutoRange(tRangeAxis, false);
%     setRange(tRangeAxis, 0, 2);
    setAutoRange(lossRangeAxis, false);
    setRange(lossRangeAxis, -1, 10);

    % Set up the beamline cartoon, from any combination of devices.
    % If you want to skip the cartoon:
    % matlabUtil = edu.stanford.slac.util.zplot.MatlabUtil();
    % matlabUtil.skipSubplot(gBLM.zPlot, numPlots)
%     BPM_cartoon    = 1;
    BLMP_cartoon   = 1;
    BLMA_cartoon   = 0;
    Cher_cartoon   = 1;
    Scint_cartoon  = 0;
    FiberI_cartoon = 0;
    FiberP_cartoon = 0;
    Wire_cartoon   = 1;
    XColl_cartoon  = 1;
    YColl_cartoon  = 1;
    
    if(Wire_cartoon)
        Wire_names = {'WS31'  ; 'WS32'  ; 'WS33'  ; 'WS34'  };
        Wire_z     = [1409.707; 1444.970; 1480.234; 1515.497];
        nWire      = length(Wire_z);
    else
        nWire      = 0;
    end
    
    if(XColl_cartoon)
        XColl_names = {'CX31'  ; 'CX35'  };
        XColl_z     = [1419.413; 1489.940];
        nXColl      = length(XColl_z);
    else
        nXColl      = 0;
    end
    
    if(YColl_cartoon)
        YColl_names = { 'CY32' ; 'CY36'  };
        YColl_z     = [1437.045; 1507.572];
        nYColl      = length(YColl_z);
    else
        nYColl      = 0;
    end
    
    nCartoon  = 0;
    NCartoons = ... % gBLM.nBPM(1)    * BPM_cartoon...
              + gBLM.nBLMP(1)   * BLMP_cartoon...
              + gBLM.nBLMA(1)   * BLMA_cartoon...
              + gBLM.nCher(1)   * Cher_cartoon...
              + gBLM.nScint(1)  * Scint_cartoon...
              + gBLM.nFiberI(1) * FiberI_cartoon...
              + gBLM.nFiberP(1) * FiberP_cartoon...
              + nWire           * Wire_cartoon...
              + nXColl          * XColl_cartoon...
              + nYColl          * YColl_cartoon;
         
    cartoonDevices = javaArray(...
        'edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice', NCartoons);
    
%     if(BPM_cartoon && gBLM.nBPM(1) > 0)
%         for n=1:gBLM.nBPM(1)
%         cartoonDevices(nCartoon + n) = ...
%             edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.BPM_names{n},...
%             gBLM.BPM_z(n),...
%             edu.stanford.slac.util.zplot.cartoon.model.widget.BPMWidget());
%         end
%         nCartoon=nCartoon + gBLM.nBPM(1);
%     end
    
    if(BLMP_cartoon && gBLM.nBLMP(1) > 0)
        for n=1:gBLM.nBLMP(1)
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.BLMP_names{n},...
                gBLM.BLMP_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.LossMonitorWidget());
        end
        nCartoon=nCartoon + gBLM.nBLMP(1);
    end
    
    if(BLMA_cartoon && gBLM.nBLMA(1) > 0)
        for n=1:gBLM.nBLMA(1)
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.BLMA_names{n},...
                gBLM.BLMA_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.LossMonitorWidget());
        end
        nCartoon=nCartoon + gBLM.nBLMA(1);
    end
    
    if(Cher_cartoon && gBLM.nCher(1) > 0)
        for n=1:gBLM.nCher(1)
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.Cher_names{n},...
                gBLM.Cher_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.LossMonitorWidget());
        end
        nCartoon=nCartoon + gBLM.nCher(1);
    end
    
    if(Scint_cartoon && gBLM.nScint(1) > 0)
        for n=1:gBLM.nScint(1)
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.Scint_names{n},...
                gBLM.Scint_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.LossMonitorWidget());
        end
        nCartoon=nCartoon + gBLM.nScint(1);
    end
    
    if(FiberI_cartoon && gBLM.nFiberI(1) > 0)
        for n=1:gBLM.nFiberI(1)
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.FiberI_names{n},...
                gBLM.FiberI_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.LossMonitorWidget());
        end
        nCartoon=nCartoon + gBLM.nFiberI(1);
    end
    
    if(FiberP_cartoon && gBLM.nFiberP(1) > 0)
        for n=1:gBLM.nFiberP(1)
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(gBLM.FiberP_names{n},...
                gBLM.FiberP_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.LossMonitorWidget());
        end
        nCartoon=nCartoon + gBLM.nFiberP(1);
    end
    
    if(Wire_cartoon && nWire > 0)
        for n=1:nWire
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(Wire_names{n},...
                Wire_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.WireScannerWidget());
        end
        nCartoon=nCartoon + nWire;
    end
    
    if(XColl_cartoon && nXColl > 0)
        for n=1:nXColl
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(XColl_names{n},...
                XColl_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.XCollimatorWidget());
        end
        nCartoon=nCartoon + nXColl;
    end
    
    if(YColl_cartoon && nYColl > 0)
        for n=1:nYColl
            cartoonDevices(nCartoon + n) = ...
                edu.stanford.slac.util.zplot.cartoon.model.CartoonDevice(YColl_names{n},...
                YColl_z(n),...
                edu.stanford.slac.util.zplot.cartoon.model.widget.YCollimatorWidget());
        end
        nCartoon=nCartoon + nYColl;
    end
    
    setCartoonDevices(gBLM.zPlot, cartoonDevices)
    
	% z-axis labels, from any combination of devices
%     BPM_label    = 0;
    BLMP_label   = 1;
    BLMA_label   = 0;
    Cher_label   = 1;
    Scint_label  = 0;
    FiberI_label = 0;
    FiberP_label = 0;
    Wire_label   = 1;
    XColl_label  = 0;
    YColl_label  = 0;
    
    nLabel  = 0;
    NLabels = ... % gBLM.nBPM(1)    * BPM_label...
            + gBLM.nBLMP(1)   * BLMP_label...
            + gBLM.nBLMA(1)   * BLMA_label...
            + gBLM.nCher(1)   * Cher_label...
            + gBLM.nScint(1)  * Scint_label...
            + gBLM.nFiberI(1) * FiberI_label...
            + gBLM.nFiberP(1) * FiberP_label...
            + nWire           * Wire_label...
            + nXColl          * XColl_label...
            + nYColl          * YColl_label;
    
    BPM_Widget = getBPMWidget(...
        edu.stanford.slac.util.zplot.model.WidgetsRepository,1);
    dataArray=javaArray(...
        'edu.stanford.slac.util.zplot.model.Device', NLabels);
   
%     if(BPM_label && gBLM.nBPM(1) > 0)
%         for n=1:gBLM.nBPM(1)
%             dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
%                 gBLM.BPM_names{n}, gBLM.BPM_z(n), 0, BPM_Widget);
%         end
%         nLabel=nLabel + gBLM.nBPM(1);
%     end
    
    if(BLMP_label && gBLM.nBLMP(1) > 0)
        for n=1:gBLM.nBLMP(1)
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                gBLM.BLMP_names{n}, gBLM.BLMP_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + gBLM.nBLMP(1);
    end
    
    if(BLMA_label && gBLM.nBLMA(1) > 0)
        for n=1:gBLM.nBLMA(1)
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                gBLM.BLMA_names{n}, gBLM.BLMA_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + gBLM.nBLMA(1);
    end
    
    if(Cher_label && gBLM.nCher(1) > 0)
        for n=1:gBLM.nCher(1)
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                gBLM.Cher_names{n}, gBLM.Cher_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + gBLM.nCher(1);
    end
    
    if(Scint_label && gBLM.nScint(1) > 0)
        for n=1:gBLM.nScint(1)
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                gBLM.Scint_names{n}, gBLM.Scint_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + gBLM.nScint(1);
    end
    
    if(FiberI_label && gBLM.nFiberI(1) > 0)
        for n=1:gBLM.nFiberI(1)
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                gBLM.FiberI_names{n}, gBLM.FiberI_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + gBLM.nFiberI(1);
    end
    
    if(FiberP_label && gBLM.nFiberP(1) > 0)
        for n=1:gBLM.nFiberP(1)
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                gBLM.FiberP_names{n}, gBLM.FiberP_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + gBLM.nFiberP(1);
    end
    
    if(Wire_label && nWire > 0)
        for n=1:nWire
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                Wire_names{n}, Wire_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + nWire;
    end
    
    if(XColl_label && nXColl > 0)
        for n=1:nXColl
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                XColl_names{n}, XColl_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + nXColl;
    end
    
    if(YColl_label && nYColl > 0)
        for n=1:nYColl
            dataArray(nLabel + n) = edu.stanford.slac.util.zplot.model.Device(...
                YColl_names{n}, YColl_z(n), 0, BPM_Widget);
        end
        nLabel=nLabel + nYColl;
    end
    
    labelDevices(gBLM.zPlot, dataArray, []);
    
    % setup GUI timer
    gBLM.t = timer;
    set (gBLM.t, 'TimerFcn', 'Loss_Monitor_Plot');
    set (gBLM.t, 'ExecutionMode', 'fixedSpacing');
    set (gBLM.t, 'StartDelay', 1);
    set (gBLM.t, 'Period', 1.5); % delay between each GUI update
    set (gBLM.t, 'StopFcn', '');
end

start(gBLM.t);
if(get(handles.Once,'Value'))
    pause(0.5)
    set(handles.StartButton,'Value',0)
    set(handles.StopButton, 'Value',0)
    pause(0.5)
    stop(gBLM.t);
end
end


% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Exit
exit
end


