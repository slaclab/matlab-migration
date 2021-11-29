function [img, xsub, ysub, flag, bgs] = beamAnalysis_imgProc(data, varargin)
%IMGPROC
%  IMGPROC(DATA, OPTS) processes image data in DATA depending on flags set
%  in OPTS.

% Features: No target ROI, images will not contain target frame (except YAGG1)
% Selectable median filter
% auto ROI or user ROI
% No plotting
% Background level determination
% Find background noise level
% Doesn't need image processing toolbox

% Background use cases:
%     Use background: opts.back=1, subtract given BG and don't fit BG
%                     opts.back=0, fit BG and subtract
%     Background image present: data.back=[NxM], subtract and don't fit BG
%     Background constant or 0: data.back=bg, subtract and don't fit BG
%     Background not given: data.back=[] or no field, fit BG and subtract
%     Assume background subtracted if image has signed int class

% Input arguments:
%    DATA: stucture with required fields:
%        IMG: image array NxM, M horizontal, N vertical pixels
%        FULL: uses this image if set, otherwise uses IMG
%        BACK: (optional), background image, same size as full
%        BITDEPTH: bit depth of image

% Output arguments:
%    IMG: Processed and cropped image
%    XSUB, YSUB: pixel coordinates of cropped region
%    FLAG: Flag to indicate image validity: Bit 1 set for low intensity,
%          bit 2 set for saturation
%    BGS: Standard deviation of background noise

% Compatibility: Version 7 and higher
% Called functions: medfilt2, moments, gaussFit, marquardt
% Optional: Image processing toolbox (executes slower if unavailable)

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'crop',0, ...
    'median',1, ...
    'floor',1, ...
    'hsig',1.5, ...
    'xsig',3.6, ...
    'ysig',3.6, ...
    'cut',.05, ...
    'debug',0, ...
    'scaleBG',0, ...
    'back',1);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Parse input parameters.
if ~isfield(data,'bitdepth'), data.bitdepth=12;end
if ~isfield(data,'back'), data.back=[];end

% Sum over color dimension.
img=sum(data.img,3,'native');

% Determine background.
if isempty(data.back) && strncmp(class(img),'int',3), data.back=0;end
if isempty(data.back), opts.back=0;end

backimg=0;
if opts.back, backimg=data.back;end

if opts.scaleBG && numel(backimg) == numel(img)
    use=backimg < 1000;
    par=polyfit(double(backimg(use)),double(img(use)),1);
    backimg=polyval(par,double(backimg));
end

typ='int16';if isa(img,'int32'), typ='int32';end
img=feval(typ,img)-feval(typ,backimg);

% Get background and noise level from image. BG = 0 if background subtracted.
[bg,bgs]=get_bg(img,opts);

% Subtract fitted background.
if ~opts.back, img=img-feval(typ,bg);end

% Get automatic bounding box.
[xsub,ysub,img,peak]=get_bb(img,opts);

% Apply median filter to remove salt & pepper noise.
if opts.median
    if exist('medfilt2','file')
        try img=medfilt2(img);
        catch
            img=util_medfilt2(img);
        end
    else img=util_medfilt2(img);
    end
end

% Test image validity.
% Detect if peak image intensity within noise level.
flag=0;
flag=flag+1*(peak < 3*bgs);

% Detect saturated image.
flag=flag+2*(max(img(:)) == (2^data.bitdepth-1));

%Plot debug results
if opts.debug, %figure(3);subplot(2,1,1); % Plot if debug flag set.
%    line(profx(1,:),profx(4,:),'Color','r');
%    line(profxg(1,:),profxg(2,:),'Color','k');subplot(2,1,2);
%    line(profy(1,:),profy(4,:),'Color','r');
%    line(profyg(1,:),profyg(2,:),'Color','k');
end


%--------------------------------------------------------------
function [bg, bgs] = get_bg(img, opts)
% Get background and noise level from image.

nPx=numel(img);nHst=100000;                   % Use no more than 100000 pixels.
if nPx > nHst, idx=ceil(nPx*rand(nHst,1));    % Sample random pixels for histogram.
else idx=1:nPx;end                            % Use all pixels if < 100000
intmax=double(max(255,max(img(:))));          % Get at least 255 bins.
step=1;if intmax > 2^12, step=pow2(fix(log2(intmax))-12);end
intmin=double(min(0,min(img(:))))-step;       % Add bin at low end.
bins=intmin:step:intmax;
[counts,intens]=hist(img(idx),bins);          % Get color histogram.
countsf=counts;                               % Histogram to fit Gaussian.
countsf(intens == intmax)=NaN;                % Set counts at max color to NaN.
if all(intmin == -step) && all(countsf(intens == step) > 0)
    countsf(intens == 0)=NaN;                 % Set counts at 0 to NaN.
end
parc=util_gaussFit(intens,countsf);           % Fit Gaussian to color distribution.
use=intens < parc(2)+opts.hsig*parc(3);       % Restrict fit to lower part of backgound.
if sum(use) > 2, countsf(~use)=NaN;end        % Keep at least three data points.
[parc,yfc]=util_gaussFit(intens,countsf);     % Fit again Gaussian to color distribution.
bg=parc(2);                                   % Set background level.
bgs=parc(3)*opts.hsig;                        % Set floor level to 1.5 sigma above background.

if opts.debug, counts(1)=0;figure(2);         % Plot if debug flag set.
    semilogy(intens,counts,intens,fix(yfc),'--',(bg+bgs)*[1 1],[1 max(counts)]);
    set(gca,'XLim',min(max(intmin,bg+bgs/opts.hsig*[-10 200]),intmax));
    xlabel('Intensity level');ylabel('Level histogram');
end


%--------------------------------------------------------------
function [xsub, ysub, imgsub, peak] = get_bb(img, opts)
% Get beam size and location estimates. (are quite exact ...) 

xcoord=1:size(img,2);ycoord=1:size(img,1);

% Find horizontal beam size and position
xprof=util_medfilt2(sum(img,1),[1 5]);          % Filter noise
parx=util_gaussFit(xcoord,xprof,1);             % Fit Gaussian
xsub=xcoord(abs(xcoord-parx(2)) <= 3*parx(3));  % Crop to +- 3 sigma

% Find vertical beam size and position
yprof=util_medfilt2(sum(img(:,xsub),2)',[1 5]); % Crop and filter noise
[pary,yf]=util_gaussFit(ycoord,yprof,1);        % Fit Gaussian
lim=opts.ysig(1)*pary(3);                       % Crop to +- ysig*sigma
if opts.ysig(1) < 0, lim=abs(opts.ysig(1));end  % ysig < 0 crop to +- |ysig|
ysub=ycoord(abs(ycoord-pary(2)) <= lim);
if numel(opts.ysig) > 1, ysub=opts.ysig(1):opts.ysig(2);end % crop ysig_1 to ysig_2

% Refine horizontal beam size and position
xprof=util_medfilt2(sum(img(ysub,:),1),[1 5]);  % Crop and filter noise
[parx,xf]=util_gaussFit(xcoord,xprof,1);        % Fit Gaussian
lim=opts.xsig(1)*parx(3);                       % Crop to +- xsig*sigma
if opts.xsig(1) < 0, lim=abs(opts.xsig(1));end  % xsig < 0 crop to +- |xsig|
xsub=xcoord(abs(xcoord-parx(2)) <= lim);
if numel(opts.xsig) > 1, xsub=opts.xsig(1):opts.xsig(2);end % crop xsig_1 to xsig_2

% Discard bounding box if too small
if length(xsub) < 3 || ~opts.crop, xsub=xcoord;end
if length(ysub) < 3 || ~opts.crop, ysub=ycoord;end

% Crop image
if opts.crop
    imgsub=img(ysub,xsub);
else
    imgsub=img;
end

% Get peak intensity from Gaussian fits.
peak=sqrt(parx(1)*pary(1)/parx(3)/pary(3)/2/pi);

if opts.debug % Plot if debug flag set.
    figure(3);subplot(2,1,1);
    plot(xcoord,[xprof;xf]);subplot(2,1,2);
    plot(ycoord,[yprof;yf]);
end
