
% TRACING VARIABLE. Set meme_trace to 1 at the command line to turn on
% debug traces in meme functions.
global meme_trace;
meme_trace=0;

Cb = 10^10/299792458;    % Speed of light in funny units

% Pathname of MAD 8 executable
MADCOMMAND='/usr/local/bin/mad8';

% MAD Command file for extant optics (CALLs patch file)
MADDATA_DIRECTORY='/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls';
MADCOMMANDS_FILENAME='LCLS_MAIN.mad8';

% MAD working directory (local copies of commands and definitions will be
% transferred to here. It is reinitialized once for each matlab process startup 
% (Startup.m sets MEME_REINITWD to true) or if user sets request.reinit true.
global MEME_REINITWD;
MEME_REINITWD=1;
MADWORKDIR='~/.meme';

% The "type" of model run (in SLACSpeak). actual machine settings, nominal
% setpoints in lattice file, or from archived data.
TYPE_UNDEFINED=0; % Not known what was the basis of model.
TYPE_EXTANT=1;    % Optics computed from existing beamline device settings.
TYPE_DESIGN=2;    % Optics computed from MAD matching results.
TYPE_HISTORY=3;   % Optics computed from archive data.
TYPE_NOMINAL=4;   % Optics as emitted using published mad deck with all default settings.
TYPE_NAMES={'Extant','Design','Historical','Nominal'};

% Modelled beampaths. This is the formal line name of the part of the
% accelelerator to be modelled - used to find which lines.dat file to use,
% and concequently which elements and devices from elementDevices.dat to 
% get data for. [Yes I know it's ungammatical, but it's clear]
BEAMLINE_LCLS=1;
BEAMLINE_GSPEC=2;
BEAMLINE_SPEC=3;
BEAMLINE_NAMES={'LCLS','GSPEC','SPEC'};
BEAMLINE_DESCRIPTIONS=...
    {'LCLS complete electron beamline', ...
     'Gun spectrometer beamline', ...
     '135 MeV spectrometer beamline'};
 
% Indexes of Twiss params in twss member of cell array output
% of xtffs2mat. Note this order is NOT the same as in TWISS survey 
% files theselves - alpha and mu are switched (see Mad manual A.3)
% 
ALPHAX=3; BETAX=2; MUX=1; DX=4; DPX=5;
ALPHAY=8; BETAY=7; MUY=6; DY=9; DPY=10;
PNAMES_LEN=10;                    % Num of twiss params
PNAMES={'mux','betax [m]','alphax','Dx [m]','Dpx','muy','betay [m]','alphay','Dy [m]','Dpy'};


% Plotting constants
% The 'Position' attribute of figure objects in Matlab is a 4 elem array,
% where the indeces have this meaning.
POSX=1; POSY=2; 
POSWIDTH=3; 
POSHEIGHT=4;

% Indexes of device names and element names in elems 2d array
DEVNAMEE=1;              % Index of cell containing device names
ELEMNAMEE=2;             % Index of cell containing element names

% Energy reference points
EREFNAMES={'E00','Ei','EBC1','EBC2','Ef'};
EREFPVNAMES={'SIOC:SYS0:ML00:AO405',...
    'SIOC:SYS0:ML00:AO406',...
    'SIOC:SYS0:ML00:AO407',...
    'SIOC:SYS0:ML00:AO408',...
    'SIOC:SYS0:ML00:AO409'};
EREFDEFVALUES=[0.006,0.135,0.250,4.3,13.64];

% Messages
unabletocreatedir = 'MEME:madmodel:unabletocreatedir';
unabletocreatedirmsg = 'Unable to create directory %s';
couldnotinit = 'MEME:madmodel:couldnotinit';
couldnotinitmsg = 'Unable to (re)initialize mad data input files, %s';
madmakeerror = 'MEME:madmodel:madmakeerror';
madmakeerrormsg = 'MAD processing was unsuccessful: %s';
maderror = 'MEME:mad:maderror';
maderrormsg = 'MAD generated error(s), see the echo file for details:\n %s';
madwarning = 'MEME:mad:madwarning';
madwarningmsg = 'MAD generated warning(s), see the echo file for details:\n %s';
somekcoeffsarezero = 'MEME:proc:kcoeffarezero';
somekcoeffsarezeromsg = ['In computation of magnet K, some magnets'' '...
    'Energy, effective Length or B were 0; corresponding K were set to 0'];
cantreinitandretrack = 'MEME:mademodel:cantsatisfybothreinitandretrack';
cantreinitandretrackmsg = 'Can not both reinitialize and retrack, neither, one or the other'; 
mustreinit = 'MEME:madmodel:mustreinit';
mustreinitmsg = ['Must reinitialize. '... 
    'Probably session directory was lost or persistent variables lost'];
cantretrack = 'MEME:madmodel:cantretrack';
cantretrackmsg = 'Not possible to retrack; Tracking directory empty so must reinitialize. ';
unabletogetinputdata = 'MEME:madmodel:unabletogetinputdata';
unabletogetinputdatamsg = 'Unable to get input data: %s %s. %s';
modelcomputationfailed = 'MEME:madmodel:computationfailed';
modelcomputationfailedmsg = 'MAD model computation failed. No output available';
outputseparator = '**********************************************';

MADERRORFLAG = 1;                % awk filter of errors & warnings ret this if errors found
MADWARNINGFLAG = 2;              % awk filter of errors & warnings ret this if warnings found
ISO8601DATEFMT=30;     % The datestr format number for IOS 8601 (yyyymmmddThhmmss)

% Filetypes of MAD input files.  
INPUTFILETYPES={'*.mad8';'*.xsif'};

% Default Mad input files. 
% 
% Files may be identified by http scheme URL, or by pathname. Note, file://
% scheme is not supported (because curl is not standard on all platforms).
MADCMDFILE_URL='http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/src/LCLS_MAIN.mad8';
% MADCMDFILE_URL='/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls/LCLS_MAIN.mad8';
MADCMSFILE_WITHPATCHFILE_SUFFIX='_WPATCH';
MADXSIFFILE_URLS={...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/src/LCLS_L1.xsif', ...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/src/LCLS_L2.xsif', ...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/src/LCLS_L3.xsif'};

% Arrays of linedata and twiss files, must be in order of beamlines as specified in BEAMLINES
LINEDATAFILE_URLS={...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/opt/LCLS_lines.dat', ...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/opt/GSPEC_lines.dat', ...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/opt/SPEC_lines.dat'};
NOMINALTWISSTAPE_URLS={...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/LCLS_twiss.tape',...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/GSPEC_twiss.tape', ...
    'http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/SPEC_twiss.tape'};
PATCH_FNAME='patch.mad8';
COMMENTINPATCH_AWK_FNAME='commentinpatch.awk';
ETCROOT='/Users/greg/Development/meme/lclscvs/matlab/toolbox/meme/etc';
TEMPROOT='/tmp/meme';

