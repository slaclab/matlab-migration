%
% LEM_Menu
%
% Main routine for Linac Energy Management (LEM) Application

% ------------------------------------------------------------------------------
% 21-FEB-2009, M. Woodley
%    Load magnet EDES PVs after Scale Magnets; reset magnet EDES PVs on unLEM
% 21-JAN-2009, M. Woodley
%    Bug fixes; new and upgraded displays; etc.
% 15-JAN-2009, M. Woodley
%    Switch from file-based reference energy values to EPICS PVs (no more optics
%    file); use jca to get and put EDES and EACT PVs; all subbooster phases from
%    EPICS; remove old SLC LI27/LI28 fast energy feedback phases; KLYS phase
%    from SLC for globally phased units is optional; write energy profile values
%    directly into XAL java objects (no more patch-file)
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Hello, world!
% ------------------------------------------------------------------------------

% LEM softIOC PVs

global lemPVs lemPVdesc lemGlobalPhasePVs
lemPVs=[ ...
  {'SIOC:SYS0:ML00:AO401'}; ... % ( 1) L0 fudge
  {'SIOC:SYS0:ML00:AO402'}; ... % ( 2) L1 fudge
  {'SIOC:SYS0:ML00:AO403'}; ... % ( 3) L2 fudge
  {'SIOC:SYS0:ML00:AO404'}; ... % ( 4) L3 fudge
  {'SIOC:SYS0:ML00:AO405'}; ... % ( 5) Eref(1) [GUN]
  {'SIOC:SYS0:ML00:AO406'}; ... % ( 6) Eref(2) [BX0]
  {'SIOC:SYS0:ML00:AO407'}; ... % ( 7) Eref(3) [BC1]
  {'SIOC:SYS0:ML00:AO408'}; ... % ( 8) Eref(4) [BC2]
  {'SIOC:SYS0:ML00:AO409'}; ... % ( 9) Eref(5) [BSY]
  {'SIOC:SYS0:ML00:AO410'}  ... % (10) spare
];
lemPVdesc=[ ...
  {'LEM L0 fudge'}; ...
  {'LEM L1 fudge'}; ...
  {'LEM L2 fudge'}; ...
  {'LEM L3 fudge'}; ...
  {'LEM reference energy (GUN)'}; ...
  {'LEM reference energy (BX0)'}; ...
  {'LEM reference energy (BC1)'}; ...
  {'LEM reference energy (BC2)'}; ...
  {'LEM reference energy (BSY)'}; ...
  {'spare'}  ...
];
lemGlobalPhasePVs=[ ...
  {'SIOC:SYS0:ML00:AO061'}; ... % (1) L2 global phase
  {'SIOC:SYS0:ML00:AO064'}; ... % (2) L3 global phase
  {'ACCL:LI29:0:KLY_PDES'}; ... % (3) LI29 energy feedback phase
  {'ACCL:LI30:0:KLY_PDES'}  ... % (4) LI30 energy feedback phase
];

disp(' ')
disp('Welcome to LEM!')
disp(' ')
disp('LEM uses the following softIOC PVs:')
disp(' ')
for n=1:length(lemPVs)
  if (~strcmp(lemPVdesc{n},'spare'))
    disp(sprintf('%s = %s',lemPVs{n},lemPVdesc{n}))
  end
end

% ------------------------------------------------------------------------------
% initialize
% ------------------------------------------------------------------------------

disp(' ')
disp('LEM initialization (this could take up to a few minutes) ...')
et=clock;ct=cputime;

% external packages (AIDA, XAL, and jca)

global da dav
aidainit
da=edu.stanford.slac.aida.lib.da.DaObject;da.reset
dav=edu.stanford.slac.aida.lib.util.common.DaValue;dav.reset

xalImport

% control flags

global controlFlags
controlFlags(1)=1; % use magnet BDES values
controlFlags(2)=1; % use "ideal" fudge factors for energy profile calculation
controlFlags(3)=0; % use design optics in XAL runs
controlFlags(4)=0; % magnet scaling algorithm
                   %  0 = linear with energy : B=(E/E0)*B0
                   %  1 = K-to-B : B=brho*KL
controlFlags(5)=0; % include SLC KLYS PDES for units with "global" phase control
controlFlags(6)=0; % inhibit beam during TRIMs

global debugFlags
debugFlags(1)=0; % use test model area
debugFlags(2)=1; % report time required for various operations
debugFlags(3)=0; % use design energy profile
debugFlags(4)=0; % don't actually set/TRIM magnets or otherwise change the
                 %  database when doing Scale Magnets or unLEM

% options:
% - lemRegions=[L0,L1,L2,L3,LTU,GSPEC,LSPEC,52LINE]
% - lemGroups=[non-optional magnets,non-undulator XYCORs,undulator QUADs,undulator XYCORs]

global lemRegions lemGroups
lemRegions=[0,0,1,1,0,0,0,0]; % the default ... L3+LTU
lemGroups=[1,1,0,0]; % the default (lemGroups(1) must always be 1)

% physical constants

global lemConstants
lemConstants(1)=0.510998918e-3; % electron rest mass (GeV)
lemConstants(2)=299792458; % speed of light (m/s)
lemConstants(3)=-1; % sign of electron charge

% file names

global xalDir accFile structFile

xalDir=strcat(getenv('PHYSICS_TOP'),'/config/model/'); % XAL input files
if (debugFlags(1))
  xalDir=strcat(xalDir,'test/');
end
accFile=strcat(xalDir,'main.xal');

lemDir=strcat(getenv('LCLS_DATA'),'/physics/LEM/'); % for LEM structures file
structFile=strcat(lemDir,'LEM_Structures.mat');

% sequence names (order is important!)

global seqName
seqName=[ ...
  {'CATHODE TO BXG'}; ...             %  1
  {'BXG TO BX01'}; ...                %  2
  {'BX01 TO BX02'}; ...               %  3
  {'BX02 TO QM15'}; ...               %  4
  {'QM15 TO FV2'}; ...                %  5
  {'FV2 TO 50B1'}; ...                %  6
  {'50B1 TO BX31'}; ...               %  7
  {'BX31 TO WS31'}; ...               %  8
  {'WS31 TO UNDSTART'}; ...           %  9
  {'UNDSTART TO DUMP'}; ...           % 10
  {'BXG TO GUN SPECT DUMP'}; ...      % 11
  {'BX01 TO 135-MEV SPECT DUMP'}; ... % 12
  {'50B1 TO 52SL2'}; ...              % 13
];

% XAL (design) accelerator object

global theAccelerator
theAccelerator=gov.sns.xal.smf.data.XMLDataManager.acceleratorWithPath(accFile);

% LEM data structures

global LCAV KLYS MAGNET PS unLEM
LCAV=[];
KLYS=[];
MAGNET=[];
PS=[];
unLEM=[];

% jca channel arrays

global lemEdesChannels lemEactChannels
lemEdesChannels=[];
lemEactChannels=[];

% LEM data collection and event times

global lemDataTime lemDataTimeout lemDataOld
lemDataTime=now;
lemDataTimeout=3; % LEM data is "old" after this amount of time (minutes)
lemDataOld=0;

% LEM magnet scaling

global lemEref lemFudge lemScaleTime noFudgeCalc
lemEref=[0.006;0.135;0.25;4.3;13.64]; % design values
lemFudge=[1;1;1;1];
lemScaleTime=0;
noFudgeCalc=isempty(intersect(find(lemRegions),[1,2,3,4]));

% LEM actions list

opList=[ ...
  {'Select Regions'}; ...       %  1 = select region to be LEMed
  {'Select Magnet Groups'}; ... %  2 = select magnets to be LEMed
  {'Load Design Optics'}; ...   %  3 = read design optics from XAL ("prime the pump")
  {'Load Saved Optics'}; ...    %  4 = read optics from file ("prime the pump")
  {'Collect Data'}; ...         %  5 = collect LEM data
  {'Save Optics'}; ...          %  6 = save optics to file ("prime the pump")
  {'Scale Magnets'}; ...        %  7 = scale and trim magnets
  {'Undo Scale Magnets'}; ...   %  8 = unLEM
  {'Displays'}; ...             %  9 = LEM displays (graphics and text)
  {'Reinitialize'}; ...         % 10 = force reinitialization of LEM structures
  {'Quit'}; ...                 % 11 = quit LEM
];
opVerify=[0;0;1;1;0;1;0;0;0;1]; % issue "Are you sure?" prompt before action

% initialize LEM data structures

stat=LEM_Initialize();

% load magnet reference values

tempRegions=lemRegions;
lemRegions=ones(size(lemRegions)); % load reference values for all regions
tempGroups=lemGroups;
lemGroups=ones(size(lemGroups)); % load reference values for all magnet groups
stat=LEM_DesignOptics(); % to get design values for quadrupole BMAG display
stat=LEM_LoadOptics();
if (~stat)
  disp('*** Please Load Saved Optics later')
end
lemRegions=tempRegions;
lemGroups=tempGroups;

disp(sprintf('... done (t= %.1f s, cpu= %.3f s)',etime(clock,et),cputime-ct))

% ------------------------------------------------------------------------------
% user interface
% ------------------------------------------------------------------------------

opQuit=strmatch('Quit',opList);
opVal=menu('Select LEM Operation',opList);

while (opVal~=opQuit)
  if (opVerify(opVal))
    stat=LEM_Prompt(5,opList{opVal});
    if (~stat)
      opVal=menu('Select LEM Operation',opList);
      continue
    end
  else
    disp(' ')
  end
  et=clock;ct=cputime;
  disp(['LEM ',opList{opVal},' ...'])
  if (ismember(opVal,[6,7,9])) % operations that require LEM data
    if (lemDataOld==0)
      disp('*** No LEM data has been collected')
      disp('*** Select "Collect Data" from the LEM menu to get data')
    end
  end
  switch opVal
    case 1 % Select Region
      stat=LEM_SelectRegions();
    case 2 % Select Magnets
      stat=LEM_SelectGroups();
    case 3 % Load Design Optics
      stat=LEM_DesignOptics();
    case 4 % Load Saved Optics
      stat=LEM_LoadOptics();
      if (~stat)
        disp('*** Please Load Saved Optics later')
      end
    case 5 % Collect LEM Data
      stat=LEM_CollectData();
      if (~stat)
        disp('*** Please Collect Data later')
      end
    case 6 % Save Optics
      if (lemDataOld==0)
        stat=0;
      else
        stat=LEM_SaveOptics();
      end
    case 7 % Scale Magnets
      if (lemDataOld==0)
        stat=0;
      else
        stat=LEM_ScaleMagnets();
      end
    case 8 % Undo Scale Magnets
      stat=LEM_Undo();
    case 9 % Displays
      if (lemDataOld==0)
        stat=0;
      else
        stat=LEM_SelectDisplayGUI();
      end
    case 10 % Reinitialize
      stat=LEM_Initialize(1);
  end
  disp(sprintf('... done (t= %.3f s, cpu= %.3f s)',etime(clock,et),cputime-ct))
  opVal=menu('Select LEM Operation',opList);
end
disp(' ')

% cleanup

scratchFile='LEM_TextDisplay.fig';
if (exist(scratchFile,'file')==2)
  delete(scratchFile)
end

% ------------------------------------------------------------------------------

return
