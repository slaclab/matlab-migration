function [mSource, mOnline, mSimul, mUseBDES mBeamPath] = model_init(varargin)
%MODEL_INIT
% [MSOURCE, MONLINE, MSIMUL, MUSEBDES MBEAMPATH] = MODEL_INIT(opts)
% initializes global variables for model queries.

% Features:

% Input arguments:

% Output arguments:
%    SOURCE:  String for source of model data, 'EPICS' (default), 'SLC',
%             'MATLAB' (Matlab online calculation), 'XAL' alias for 'EPICS'
%    ONLINE:  Acts like MODELSOURCE is 'MAD' when 1 (obsolete)
%    SIMUL:   State for simulating machine parameters for model
%             calculations
%    USEBDES: Use BDES instead of BACT for model calculations

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

global modelSource modelOnline modelSimul modelUseBDES modelBeamPath

global modelUseNewBSY
if isempty(modelUseNewBSY), modelUseNewBSY=1;end

[sys,accel]=getSystem;

% Set defaults.
if isempty(modelOnline)
    modelOnline=1;
end

if isempty(modelSource)
    switch accel
        case 'LCLS'
            modelSource='MATLAB';
        case 'FACET'
            modelSource='MATLAB';
        case {'NLCTA' 'XTA' 'ASTA'}
            modelSource='MATLAB';
        case 'LCLS2'
            modelSource='MATLAB';
        otherwise
            modelSource='EPICS';
    end
    if ispc
        modelSource='MATLAB';
    end
end

if isempty(modelBeamPath)
    switch accel
        case 'LCLS'
            modelBeamPath = 'CU_HXR';
        case 'FACET'
            modelBeamPath = 'F2_SCAV';
        case {'NLCTA' 'XTA' 'ASTA'}
            modelBeamPath='';
        case 'LCLS2'
            modelBeamPath='';
        otherwise
            modelBeamPath='';
    end
    if ispc
        modelBeamPath = 'CU_HXR';
    end
end

if isempty(modelSimul)
    modelSimul=0;
end

if isempty(modelUseBDES)
    modelUseBDES=0;
end

% Set default options.
optsdef=struct( ...
    'source',modelSource, ...
    'online',modelOnline, ...
    'simul',modelSimul, ...
    'useBDES',modelUseBDES, ...
    'beamPath',modelBeamPath ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

modelSource=opts.source;
modelOnline=opts.online;
modelSimul=opts.simul;
modelUseBDES=opts.useBDES;
modelBeamPath=opts.beamPath;

mSource=modelSource;
mOnline=modelOnline;
mSimul=modelSimul;
mUseBDES=modelUseBDES;
mBeamPath=modelBeamPath;
