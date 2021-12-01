function [inp_struc] = LiTrack_prepData_LCLS(type,varargin)
% 
% LiTrack_prepData_LCLS prepares an input file for LiTrack 
% that describes the longitudinal parameters of the LCLS
% accelerator.
%
% INPUTS
%    type: 0 = design machine. Parameters from constants
%          1 = extant machine. Parameters from control system.
%
%    The following arguments are given as name value pairs: 
%
%    ParamFn param file name (OPTIONAL, default = None)
%          If you give a name-value argument where the name is 'ParamFn', 
%          the value is interpretted as the name of the file to which you 
%          want the control
%          system process variables of the accelerator saved. This
%          file would then be loaded in LiTrack. If no ParamFn is
%          given, no file will be written. See examples.
%
%    ParticleFn Particle file name (OPTIONAL, 
%                                   default = PulseStacker_150pC_1p7psDelay.zd')
%          If you give a name-value argument where the name is 'ParticleFn', 
%          the value is interpretted as the name of the particle 
%          distribution file (*.zd) you
%          want to be named in the returned inp_struc and saved in
%          the parameter file named in the argument described above. 
%
% OUTPUT
%    inp_struc
%          A structure describing the longitudinal parameters of LCLS. 
%          This structure is suitable for being passed directly to LiTrack.
%
% EXAMPLES
%    Prepare design inp_struc, don't write an ouptut file:
%    lclsparams = LiTrack_prepData_LCLS(0) 
%    Prepare extant machine inp_struc, naming PulseStacker.zd as partcile file:
%    lclsparams = LiTrack_prepData_LCLS(1, 'ParticleFn','PulseStacker.zd')

% * TODO make run successfully when no template_LCLS.mat is in directory
% * TODO Verify proper behavior when ParamIn and ParamOut files are given..

% Constants
LiTrack_globals;
NOPARAMFILE='None';
PARAMOUTFILENAME_DEF=NOPARAMFILE;
PARAMINFILENAME_DEF='template_LCLS.mat';
PARTICLEFILE_DEF='PulseStacker_150pC_1p7psDelay.zd';

% Init
LiTrack_messages; % Include LiTrack message codes and text.
dirname = fileparts(which('LiTrack_prepData_LCLS.m'));
paramfp = [dirname filesep 'SaveFiles/'];

% Argument Processing
p = inputParser;
p.addRequired('type', @(x) ismember(x,[DESIGN,EXTANT]));
p.addParamValue('paramFileInFn',PARAMINFILENAME_DEF, @(x) validParamInFile(x)); 
p.addParamValue('paramFileOutFn',PARAMOUTFILENAME_DEF, @(x) validParamOutFile(x));  
p.addParamValue('particleFn', PARTICLEFILE_DEF, @(x) validParticleFile(x));
p.parse( type, varargin{:});
inputargs = p.Results;
type = inputargs.type;
savename = inputargs.paramFileOutFn;
partfile = inputargs.particleFn;

% Base output on given mat file, defaulted to PARAMINFILENAME_DEF by
% argument processing if not given.
load([inputargs.paramFileInFn],'inp_struc'); 

STAT = [...
1,  1;...    %  1 = free (1)
0,  10;...   %  2 = L0A (10)
0,  10;...   %  3 = L0B (10)
1,  22;...   %  4 = LH (22)
0,  6;...    %  5 = DL1 (6)
0,  10;...   %  6 = L1S (10)
0,  10;...   %  7 = L1X (10)
1,  7;...    %  8 = BC1 (7)
0,  1;...   %  9 = CSR (17)
0,  1;...    % 10 = free (1)
0,  10;...   % 11 = L2 (10)
1,  7;...    % 12 = BC2 (7)
0,  17;...   % 13 = CSR (17)
0,  10;...   % 14 = L3 (10)
0,  15;...   % 15 = BSY RW (15)
0,  6;...    % 16 = DL2 (6)
0,  1;...   % 17 = CSR (17)
0,  15;...   % 18 = LTU RW (15)
0,  1;...   % 19 = SE growth (22)
0,  15];     % 20 = UND RW (15)


partstart = 4; %first included
partend = 18; %last included
Qstart = 150;
Estart = 0.135;

if ( type == DESIGN )
    disp('Preparing parameter data from constants');
    GunE = .006;
    L0Aamp = 0.0575;
    L0Aphi = 0;
    L0Bphi = -2.5;
    DL1E = 0.135;
    L1Sphi = -25.5;
    L1Xphi = -160;
    L1Xamp = 0.017;
    BC1E = 0.22;
    BC1R56 = -0.0463;
    L2phi = -33.7;
    BC2E = 5;
    BC2R56 = -0.028;
    L3phi = 0;
    DL2E = sqrt(9800/45);
elseif ( type == EXTANT )
    disp('Preparing parameter data from control system and model');
    GunE = lcaGetSmart('SIOC:SYS0:ML00:AO471')*MEV2GEV;
    L0Aamp = lcaGetSmart('ACCL:IN20:300:L0A_S_AV')*MEV2GEV;
    L0Aphi = lcaGetSmart('ACCL:IN20:300:L0A_S_PV');
    L0Bphi = lcaGetSmart('ACCL:IN20:400:L0B_S_PV');
    DL1E = lcaGetSmart('SIOC:SYS0:ML00:AO513')*MEV2GEV;
    L1Sphi = lcaGetSmart('ACCL:LI21:1:L1S_S_PV');
    L1Xphi = lcaGetSmart('ACCL:LI21:180:L1X_S_PV');
    L1Xamp = lcaGetSmart('ACCL:LI21:180:L1X_S_AV')*MEV2GEV;
    BC1E = lcaGetSmart('SIOC:SYS0:ML00:AO483')*MEV2GEV;
    % bc1Rmat = model_rMatGet('BLEN:LI21:265');  % BLEN is 1st device in BC1
    % BC1R56 = bc1Rmat(5,6);
    BC1R56 = lcaGetSmart('SIOC:SYS0:ML00:AO484')*MM2M; % PV from CUD
    L2phi = lcaGetSmart('SIOC:SYS0:ML00:CALC204');
    BC2E = lcaGetSmart('SIOC:SYS0:ML00:AO489'); % Already in GeV
    % bc2Rmat = model_rMatGet('BLEN:LI24:886');  
    % BC2R56 = bc2Rmat(5,6);
    BC2R56 = lcaGetSmart('SIOC:SYS0:ML00:AO490')*MM2M; % PV from CUD
    L3phi = lcaGetSmart('SIOC:SYS0:ML00:AO499');
    DL2E = lcaGetSmart('SIOC:SYS0:ML00:AO500'); 
else
    error('Unrecognized type argument value: %d',type);
end

% Format inputs:
STAT(1:(partstart-1),2) = 1; %turn off upstream stuff
STAT(2:(partstart-1),1) = 0; %and don't plot
STAT((partend+1):end,2) = 99; %turn off downstream stuff
STAT((partend+1):end,1) = 0; %and don't plot
inp_struc.p(1:size(STAT,1)) = STAT(:,1).';
inp_struc.save_fn = savename;
inp_struc.inp = partfile;
inp_struc.zd_file = partfile;
inp_struc.comment = 'Generated by script...';
inp_struc.Ne = Qstart*1e-12/1.602e-19;
inp_struc.E0 = Estart;
% setup linac
inp_struc.beamline(2,2) = L0Aamp; %L0A amp
inp_struc.beamline(2,3) = L0Aphi; %L0A phase
inp_struc.beamline(3,2) = DL1E; %L0B amp
inp_struc.beamline(3,3) = L0Bphi; %L0B amp
inp_struc.beamline(5,4) = DL1E; %DL1 E
inp_struc.beamline(6,2) = BC1E - L1Xamp*cosd(L1Xphi);
inp_struc.beamline(6,3) = L1Sphi;
inp_struc.beamline(7,2) = BC1E;
inp_struc.beamline(7,3) = L1Xphi;
inp_struc.beamline(8,2) = BC1R56;
inp_struc.beamline(8,3) = BC1E;
inp_struc.beamline(11,2) = BC2E+2e-3;
inp_struc.beamline(11,3) = L2phi;
inp_struc.beamline(12,2) = BC2R56;
inp_struc.beamline(12,3) = BC2E;
inp_struc.beamline(14,2) = DL2E + 2e-3;
inp_struc.beamline(14,3) = L3phi;
inp_struc.beamline(16,4) = DL2E;
inp_struc.beamline(1:size(STAT,1),1) = STAT(:,2);

if ( ~strcmp(savename, NOPARAMFILE ))
    save([paramfp,savename],'inp_struc');
end

function [isvalid] = validParticleFile( particleFn )
% validParticleFile checks whether the given string names an existing
% LiTrack particle file. Particle files must have extension .zd.

LiTrack_messages;
LiTrack_globals;

isvalid=false;
if (exist(particleFn,'file') == FILEEXISTS)
    [ ~, ~, ext ] = fileparts( particleFn );
    if strcmp(ext,PARTICLEFILEEXT)
        isvalid=true;
    end
end
if ~isvalid
     error(LIT_PARTICLEFILENOTFOUND, LIT_PARTICLEFILENOTFOUNDMSG, particleFn);
end

function [isvalid] = validParamInFile( paramFn )
% validParamInFile checks the validity of any input parameter file. By
% default this is the template_LCLS input file.

LiTrack_messages;
LiTrack_globals;
                 
isvalid=false;
if (exist(paramFn,'file') == FILEEXISTS)
    [ ~, ~, ext ] = fileparts( paramFn );
    if strcmp(ext,PARAMFILEEXT)
        isvalid=true;
    end
end
if ~isvalid
     error(LIT_PARAMFILENOTFOUND, LIT_PARAMFILENOTFOUNDMSG, paramFn);
end

function [isvalid] = validParamOutFile( paramFn )
% validParamOutFile checks the validity of any output parameter file. 
% In particular, it checks taht someone doesn't accidentaly try to write
% the default template LCLS input file.

LiTrack_messages;
LiTrack_globals;

isvalid=false;
[ ~, ~, extpart ] = fileparts( paramFn );
if ( ~strcmp(extpart,PARAMFILEEXT))
    error(LIT_FILENAMEINVALID, LIT_FILENAMEINVALIDMSG, ...
        [paramFn ' must have extention ' PARAMFILEEXT ]);
end
if strcmp( paramFn, PARAMINFILENAME_DEF )
    error(LIT_FILENAMEINVALID, LIT_FILENAMEINVALIDMSG, ...
        [paramFn ' must NOT be the template file ' PARAMINFILENAME_DEF ]);
end
isvalid=true;







