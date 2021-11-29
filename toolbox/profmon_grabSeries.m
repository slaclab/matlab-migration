function data = profmon_grabSeries(pv, nSample, ts, varargin)
%PROFMON_GRABSERIES
%  PROFMON_GRABSERIES(PV, NSAMPLE, TS, OPTS) takes NSAMPLE images of profile
%  monitors PV.

% Features:

% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211
%    NSAMPLE: number of beam images, default 1
%    TS: Time stamp(s) to get images after
%    OPTS: options struct
%          BUFD: get buffered images, default is 0
%          DOPLOT: show image if set to 1, default is 0

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

% Compatibility: Version 2007b, 2012a
% Called functions: profmon_grab

% Author: Henrik Loos, SLAC
% Mod:
%       5-Apr-2017, Sonya Hoobler
%                   Removed reference to obsolete PROF:BSY0:55
% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'bufd',0, ...
    'buffer',0, ...
    'doPlot',0, ...
    'figure',2, ...
    'axes',[], ...
    'bits',8, ...
    'cal',0, ...
    'saves',0, ...
    'title','Image #%d');

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Check input arguments.
if nargin < 3, ts=0;end
if nargin < 2, nSample=1;end

pv=cellstr(pv);
tsNew=repmat(-Inf,1,numel(pv));
wait=.1;
if all(strncmp(pv,'SXR:EXS:CVV:01',14))
    wait=1/120/2*.2;
end
for j=1:nSample
    nTry=15;
    while any(tsNew <= ts) && nTry
        bad=tsNew <= ts;
        n=0;
        if opts.buffer, n=j-nSample;end
        if ~opts.bufd, n=[];pause(2*wait);end
        data(j,bad)=profmon_grab(pv(bad),0,n);
        tsNew=[data(j,:).ts];
        nTry=nTry-1;
        if any(tsNew <= ts), pause(wait);end
    end
    if ~nTry, disp('Timeout for image on:');disp(pv);end
    ts=max(tsNew);
    if opts.doPlot
        pOpts=opts;pOpts.title=sprintf(opts.title,j);
        if any(isa(data(j).img,'int32')), pOpts.bits=0;end
        if any(isa(data(j).img,'double')), pOpts.bits=0;end
        profmon_imgPlot(data(j,1),pOpts);
        profmon_imgPlot(data(j,1),'saves',opts.saves);
    end
end