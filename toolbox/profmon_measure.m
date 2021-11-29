function data = profmon_measure(pv, nSample, varargin)
%PROFMON_MEASURE
%  PROFMON_MEASURE() takes NSAMPLE beam and NBG background measurements of
%  profile monitors PV.

% Features:

% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211
%    NSAMPLE: number of beam images, default 1
%    OPTS: options struct
%          NBG: number of background images to average (default 1)
%          INSSCREEN: flag to insert the screen and rectract all others,
%                     defaults to 0 (don't change)
%          DOPLOT: Show images and stats
%          DOPROCESS: Do image processing and return stats
%          METHOD: Number of method to show results for
%          BUFD: Use buffered free run images, default is 0

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
% Called functions: profmon_evrSet, profmon_activate, beamAnalysis_imgProc,
%                   beamAnalysis_beamParams, beamAnalysis_imgPlot
%                   profmon_grabBG, profmon_grabSeries

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'spontBG', 0, ...
    'nSlice',0, ...
    'sliceDir','x', ...
    'sliceWin',3, ...
    'nBG',1, ...
    'insScreen',0, ...
    'doProcess',1, ...
    'doPlot',1, ...
    'useCal',1, ...
    'method',1, ...
    'figure',2, ...
    'axes',[], ...
    'bits',8, ...
    'cal',0, ...
    'bufd',0, ...
    'buffer',0, ...
    'crop',1, ...
    'median',0, ...
    'hsig',1.5, ...
    'xsig',4.6, ...
    'ysig',4.6, ...
    'cut',.05, ...
    'back',1, ...
    'average',0, ...
    'nAvg',1, ...
    'type','int16', ...
    'saves',0, ...
    'keepBack',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Check input arguments.
if nargin < 2, nSample=1;end

[pv,is]=profmon_names(pv);%pv=char(pv);

if opts.insScreen, profmon_activate(pv);
else profmon_evrSet(pv);end

bufd=opts.bufd & is.Bufd;
if any(bufd) && ~opts.buffer
    lcaPutSmart(strcat(pv(bufd),':SAVE_IMG'),1);
    pause(.1);
end
if any(bufd) && opts.buffer
    lcaPutSmart(strcat(pv(bufd),':SAVE_IMG'),0); % Freeze buffer
    pause(.1);
end

back=cell(1,numel(pv));ts=0;
if isnumeric(opts.nBG) && numel(opts.nBG) == 1
    [backD,ts]=profmon_grabBG(pv,opts.nBG,opts);
    for j=1:numel(pv)
        back{j}=mean(cat(4,backD(:,j).img),4);
    end
elseif iscell(opts.nBG)
    back(:)=opts.nBG;
else
    back(:)={opts.nBG};
end

data=profmon_grabSeries(pv,opts.nAvg*nSample,ts,opts);

if any(bufd) && opts.buffer
    lcaPutSmart(strcat(pv(bufd),':SAVE_IMG'),1); % Unfreeze buffer
    pause(.1);
end

data=reshape(data,opts.nAvg,nSample,numel(pv));
for j=1:nSample
    for k=1:numel(pv)
        if size(data,1) > 1
            data(1,j,k).img=feval(class(data(1,j,k).img),mean(cat(4,data(:,j,k).img),4));
        end
        if opts.keepBack && j == 1
            data(1,j,k).back=back{k};
        elseif ~isempty(back{k})
            type=opts.type;
            if strcmp(class(data(1,j,k).img),'int32'), type='int32';end
            if strcmp(class(data(1,j,k).img),'double'), type='double';end
            data(1,j,k).img=feval(type,data(1,j,k).img)-feval(type,back{k});
        end
    end
end
data(2:end,:)=[];

if opts.insScreen, profmon_activate(pv,0);end

if ~opts.doProcess, return, end

for j=1:numel(data)
    data(j).beam=profmon_process(data(j),opts);
    data(j).beamPV=beamAnalysis_convert2PV(data(j));
end