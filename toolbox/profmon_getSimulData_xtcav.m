function data = profmon_getSimulData_xtcav(pv, nSample, opts)
%PROFMON_getSimulData_xtcav()
%  PROFMON_getSimulData_xtcav() makes NSAMPLE simulated beam through scaling a saved dataList 

% Features: used model twiss parameters and emittance to calculate beam
% size, then generate a general beamList for the Non-Deflected beam size of
% the XTCAV (cannot get the measured beam image at non-deflecting point due
% to off-axis screen.)

% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211
%    NSAMPLE: number of beam images, default 1
%    OPTS: options struct
%          NBG: number of background images to average (default 0)
%          emit: the normalized emittance used for calcualtion of the beam
%          size
%       

% Output arguments:
%    DATA: Structure array [nSamp x nPV] of camera image and camera properties
%        IMG:        Image data as uint16 or uint8 array, depending on bit depth
%        TS:         Time stamp of image in Matlab time units
%        PULSEID:    Pulse Id of image
%        NCOL, NROW: Number of columns and rows of full image
%        BITDEPTH:   Bit depth of image
%        RES:        Screen resolution in um/pixel
%        ROIX,Y:     Offset x and y of partial image
%        ROIXN, YN:  Number of columns and rows of actual (partial) image
%        ORIENTX, Y: Camera orientation, 1 means image has to be flipped
%        CENTERX, Y: Screen center in pixels
%        ISRAW:      Indicates raw image, 0 means flipped, 1 raw
%        BEAM:       results from image processing and profile analysis,
%                    only returned if DOPROCESS is 1 (see
%                    beamAnalysis_beamParams)

% Compatibility: Version 2007b, 2012a
% Called functions: model_twissGet, load a saved beam data.

% Author: 6-Jul-2020, Yuantao Ding, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'emit',1, ...
    'nBG',0);

% Use default options if OPTS undefined.
if nargin < 3, opts=struct;end
opts=util_parseOptions(opts,optsdef);

% Check input arguments.
if nargin < 2, nSample=1;end

if strcmp(pv,'OTRS:DMPH:695') | strcmp(pv,'OTRDMP')
 rOpts = {'TYPE=DESIGN' 'BEAMPATH=CU_HXR'}; 
 [twi1, sig1, eng1, pha1] = model_twissGet(pv,rOpts);
 beamSize=sqrt(opts.emit*1e-6.*twi1(2,:)./(eng1*1000/0.511))*1e6; % um
 beamPos=[0.1 0.1]'*1e-3;
elseif  strcmp(pv,'OTRS:DMPS:695') | strcmp(pv,'OTRDMPB')
 rOpts = {'TYPE=DESIGN' 'BEAMPATH=CU_SXR'}; 
 [twi1, sig1, eng1, pha1] = model_twissGet(pv,rOpts);
 beamSize=sqrt(opts.emit*1e-6.*twi1(2,:)./(eng1*1000/0.511))*1e6; % um
 beamPos=[0.1 0.1]';  % mm
end

stats0    = [beamPos(1) beamPos(2) beamSize(1) beamSize(2) 1e-6 1e4]; % beam size is from model
stats0Std = [beamPos(1) beamPos(2) beamSize(1) beamSize(2) 1e-6 1e4].*0.5e-2; % use 0.5% as std
xStat0    = [1e4 beamPos(1) beamSize(1) 0 0];
xStat0Std = [1e4 beamPos(1) beamSize(1) 0 0].*0.5e-2;
aa=load('XTCAVsimul_dataListExamp.mat');
scl=beamSize(1)./280;% 280 um is the beam size in the Exampl data.

for j=1:nSample
    
    
    data(j)=aa.dataList(1);
    data(j).name=pv;
    data(j).pulseId =j;

    for nn=1:length(data(1).beam)
    rd=0.9 + 0.05*rand(1,1);
    data(j).beam(nn).stats=stats0.*rd;
    data(j).beam(nn).xStat=xStat0.*rd;
    rd=0.9 + 0.05*rand(1,1);
    data(j).beam(nn).statsStd=stats0Std.*rd;
    data(j).beam(nn).xStatStd=xStat0Std.*rd;    
    
    data(j).beam(nn).profx(1,:)=data(j).beam(nn).profx(1,:).*scl;
    
    end
end














