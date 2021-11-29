function bba_setBPM(static, bpmDelta, appMode, varargin)
%BBA_SETBPM
%  BBA_SETBPM(STATIC, BPMDELTA, APPMODE, OPTS) changes BPM BBA offsets
%  by BPMDELTA based on device information in STATIC structure. Simulation
%  mode is determined by APPMODE.

% Features:

% Input arguments:
%    STATIC:   As created by BBA_INIT
%    BPMDELTA: Change for BPM BBA offsets
%    APPMODE:  Production mode (1 production, 0 simulation)
%    OPTS:     Options struct

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, model_nameConvert, lcaGet, lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit girdPos

% Set default options.
optsdef=struct( ...
    'init',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Change BPM offsets by desired shift.
if ~appMode
    bpmOff=bpmOff+bpmDelta;
end

if appMode
    pvList=model_nameConvert(static.bpmList,'EPICS');
    pvOff=[strcat(pvList(:),':XAOFF') strcat(pvList(:),':YAOFF')]';
    off=lcaGet(pvOff(:));
    if opts.init, off=0;end
    lcaPut(pvOff(:),off-bpmDelta(:)*1e3);
    cData=[static.bpmList num2cell(reshape([off;off-bpmDelta(:)*1e3],[],4))]';
    disp('BPM Off   Old x    Old Y    New X    New Y');
    disp(sprintf('%-6s %8.3f %8.3f %8.3f %8.3f\n',cData{:}));
end
