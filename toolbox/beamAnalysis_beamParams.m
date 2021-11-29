function beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs, varargin)
%BEAMPARAMS
%  BEAMPARAMS(IMG,X,Y,OPTS) calculates distribution moments and profiles.

% Input arguments:
%    IMG: image array NxM, M horizontal, N vertical pixels
%    XSUB, YSUB: horizontal and vertical pixel index vector with the
%    pixels coordinates of the cropped image relative to the original
%    OPTS: options, see IMGPROC()

% Output arguments:
%    BEAMLIST: structure array for the different analysis methods
%        STATS:    [XMEAN YMEAN XRMS YRMS CORR SUM]
%        PROFX:    [XCOORD;XPROF;FIT]
%        PROFY:    [YCOORD;YPROF;FIT]
%        PROFU:    [UCOORD;UPROF;FIT]
%        STATSSTD: Std of STATS
%        XSTAT:    [SUM MEAN RMS SKEW KURTOSIS];
%        XSTATSTD: Std of XSTAT
%        YSTAT, YSTATSTD, USTAT, USTATSTD: if profile available
%        METHOD:   string to identify the calculation method
%            'Gaussian':     Gaussian fit to raw profile
%            'Assymetric':   Assymetric Gaussian fit to raw profile
%            'RMS raw':      rms without base line cut
%            'RMS cut peak': rms with base line cut relative to peak
%            'RMS cut area': rms with base line cut relative to area
%            'RMS floor':    rms with noise cut in image

% Compatibility: Version 2007b, 2012a
% Called functions: util_moments, util_gaussfit, util_bgLevel

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'isimage',1, ...
    'fitbg',0, ...
    'floor',1, ...
    'cut',.05, ...
    'usemethod',[] ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
if isempty(opts.usemethod), opts.usemethod=1:7;end

% Set defaults.
beam=struct('gauss',[],'asym',[],'super',[],'rms_raw',[],'rms_cut_peak',[], ... 
    'rms_cut_area',[],'rms_floor',[],'gauss4th',[],'doublegauss',[],'superasym',[]);

% Get beam profiles.
if opts.isimage, profs=get_profiles(img,xsub,ysub);
else profs=img;end

% Get background for fitbg.
opts.fitbg=get_bg(profs,opts);

% Get Gaussian fits of beam profile.
if any(opts.usemethod == 1)
    beam.gauss=get_stats('get_gaussfit',profs,opts);
end

% Get 2-sided Gaussian fits of beam profile.
if any(opts.usemethod == 2)
    beam.asym=get_stats('get_2sidefit',profs,opts);
end

% Get super Gaussian fits of beam profile.
if any(opts.usemethod == 3)
    beam.super=get_stats('get_superfit',profs,opts);
end

% Get 4th order Gaussian fits of beam profile.
if any(opts.usemethod == 8)
    beam.gauss4th=get_stats('get_gauss4thfit',profs,opts);
end

% Get double Gaussian fits of beam profile.
if any(opts.usemethod == 9)
    beam.doublegauss=get_stats('get_doublegaussfit',profs,opts);
end

% Get 2-sided super Gaussian fits of beam profile.
if any(opts.usemethod == 10)
    beam.superasym=get_stats('get_superasymfit',profs,opts);
end

% Get beam and profile moments w/o cut.
if any(opts.usemethod == 4)
    beam.rms_raw=get_stats('get_rms',profs,opts);
end

% Get beam and profile moments w/ peak cut.
if any(opts.usemethod == 5)
    beam.rms_cut_peak=get_stats('get_rms',profs,opts,opts.cut);
end

% Get beam and profile moments w/ area cut.
if any(opts.usemethod == 6)
    beam.rms_cut_area=get_stats('get_rms',profs,opts,[],opts.cut);
end

% Get beam and profile moments with floor.
if opts.isimage
    img(img < opts.floor*bgs)=0;
    profs=get_profiles(img,xsub,ysub);
else
    profs=img;
end
if any(opts.usemethod == 7)
    beam.rms_floor=get_stats('get_rms',profs,opts);
    beam.rms_floor.method='RMS floor';
end

% Pack everything into array.
beamlist=[beam.gauss beam.asym beam.super beam.rms_raw beam.rms_cut_peak ...
          beam.rms_cut_area beam.rms_floor beam.gauss4th beam.doublegauss beam.superasym];


%--------------------------------------------------------------
function profs = get_profiles(img, xsub, ysub)
% Get beam profiles

%delta=sqrt(abs(mean(diff(xsub))*mean(diff(ysub))));
delta=sqrt(mean(diff(xsub))^2+mean(diff(ysub))^2)/2;
uprof=util_diagSum(img)';
%usub=(0:length(uprof)-1)/sqrt(2)*delta+(xsub(1)-ysub(1))/sqrt(2);
usub=(0:length(uprof)-1)*delta;
usub=usub-mean(usub)+(mean(xsub)-mean(ysub))/sqrt(2);

profs.x=[xsub;sum(img,1)];
profs.y=[ysub;sum(img,2)'];
profs.u=[usub;uprof];


%--------------------------------------------------------------
function bg = get_bg(profs, opts)
% Get background of beam profiles

for tag='xyu'
    bg.(tag)=0;
    if isfield(profs,tag) && opts.fitbg
        bg.(tag)=util_bgLevel(profs.(tag));
    end
end


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_gaussfit(prof, bg)
% Get Gaussian fits of beam profile

name='Gaussian';fitbg=0;
prof(2,:)=prof(2,:)-bg;
[par,prof(3,:),parstd,d,d,pcov]=util_gaussFit(prof(1,:),prof(2,:),fitbg,'0');
stat=[sqrt(2*pi)*par(3)*par(1) par(2:3)' 0 0];
dstat=[sqrt(2*pi)*[par(3) 0 par(1)];0 1 0;0 0 1;0 0 0;0 0 0];
statStd=sqrt(diag(dstat*pcov(1:3,1:3)*dstat'))';
prof(2:3,:)=prof(2:3,:)+bg;


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_2sidefit(prof, bg)
% Get 2-sided Gaussian fits of beam profile

name='Asymmetric';fitbg=0;
prof(2,:)=prof(2,:)-bg;
[par,prof(3,:),parstd,d,d,pcov]=util_gaussFit(prof(1,:),prof(2,:),fitbg,'1');
s=sqrt(1+par(4)^2*(3-8/pi));m1=sqrt(8/pi)*par(3)*par(4);
xmean=par(2)+m1;
xrms=par(3)*s;m3=m1*par(3)^2*(1+par(4)^2*(16/pi-5));
skew=m3/xrms^3;m4=par(3)^4*(3+10*par(4)^2*(3-8/pi)+par(4)^4*(15+16/pi*(1-12/pi)));
kurt=m4/xrms^4-3;
stat=[sqrt(2*pi)*par(3)*par(1) xmean xrms skew kurt];
dstat=[sqrt(2*pi)*[par(3) 0 par(1) 0]; ...
        0 1 sqrt(8/pi)*[par(4) par(3)]; ...
        0 0 s par(3)/s*par(4)*(3-8/pi); ...
        0 0 0 sqrt(8/pi)/s^3*(1+24*par(4)^2*(3/pi-1)/s^2); ...
        0 0 0 0]; %Kurtosis error to be calculated...
statStd=sqrt(diag(dstat*pcov(1:4,1:4)*dstat'))';
prof(2:3,:)=prof(2:3,:)+bg;


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_superfit(prof, bg)
% Get super-Gaussian fits of beam profile

name='Super';fitbg=0;
prof(2,:)=prof(2,:)-bg;
[par,prof(3,:),parstd,d,d,pcov]=util_gaussFit(prof(1,:),prof(2,:),fitbg,'2');
n=par(4);int=2/n*gamma(1/n)*sqrt(2)*par(3);
gam2=gamma(5/n)*gamma(1/n)/gamma(3/n)^2-3;
sig=sqrt(2*gamma(3/n)/gamma(1/n))*par(3);
stat=[int*par(1) par(2) sig 0 gam2];
%stat=[sqrt(2*pi)*par(3)*par(1) par(2:3)' 0 0];
%dstat=[sqrt(2*pi)*[par(3) 0 par(1)];0 1 0;0 0 1;0 0 0;0 0 0];
%statStd=sqrt(diag(dstat*pcov(1:3,1:3)*dstat'))';
%par(end+1)=0;
%[int,xmean,xrms,xvar,skew,kurt]=util_moments(prof(1,:),prof(3,:)-par(5));
%dx=abs(mean(diff(prof(1,:))));
%stat=[int*dx xmean xrms skew kurt];
statStd=stat*0;
prof(2:3,:)=prof(2:3,:)+bg;


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_superasymfit(prof, bg)
% Get asym super-Gaussian fits of beam profile

name='SuperAsym';fitbg=0;
prof(2,:)=prof(2,:)-bg;
[par,prof(3,:),parstd,d,d,pcov]=util_gaussFit(prof(1,:),prof(2,:),fitbg,'3');
%stat=[sqrt(2*pi)*par(3)*par(1) par(2:3)' 0 0];
%dstat=[sqrt(2*pi)*[par(3) 0 par(1)];0 1 0;0 0 1;0 0 0;0 0 0];
%statStd=sqrt(diag(dstat*pcov(1:3,1:3)*dstat'))';
par(end+1)=0;
[int,xmean,xrms,xvar,skew,kurt]=util_moments(prof(1,:),prof(3,:)-par(6));
dx=abs(mean(diff(prof(1,:))));
stat=[int*dx xmean xrms skew kurt];
statStd=stat*0;
prof(2:3,:)=prof(2:3,:)+bg;


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_gauss4thfit(prof, bg)
% Get asym super-Gaussian fits of beam profile

name='Gauss4th';fitbg=0;
prof(2,:)=prof(2,:)-bg;
[par,prof(3,:),parstd,d,d,pcov]=util_gaussFit(prof(1,:),prof(2,:),fitbg,'6');
%stat=[sqrt(2*pi)*par(3)*par(1) par(2:3)' 0 0];
%dstat=[sqrt(2*pi)*[par(3) 0 par(1)];0 1 0;0 0 1;0 0 0;0 0 0];
%statStd=sqrt(diag(dstat*pcov(1:3,1:3)*dstat'))';
par(end+1)=0;
[int,xmean,xrms,xvar,skew,kurt]=util_moments(prof(1,:),prof(3,:)-par(6));
dx=abs(mean(diff(prof(1,:))));
stat=[int*dx xmean xrms skew kurt];
statStd=stat*0;
prof(2:3,:)=prof(2:3,:)+bg;


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_doublegaussfit(prof, bg)
% Get double-Gaussian fits of beam profile

name='DoubleGauss';fitbg=0;%fitbg=1;
prof(2,:)=prof(2,:)-bg;
[par,prof(3,:),parstd,d,d,pcov]=util_gaussDoubleFit(prof(1,:),prof(2,:),fitbg);
stat=[sqrt(2*pi)*par(3)*par(1) par(2:3)' sqrt(2*pi)*par(6)*par(4) par(5:6)'];
dstat=blkdiag([sqrt(2*pi)*[par(3) 0 par(1)];0 1 0;0 0 1],[sqrt(2*pi)*[par(3) 0 par(1)];0 1 0;0 0 1]);
statStd=sqrt(diag(dstat*pcov(1:6,1:6)*dstat'))';
prof(2:3,:)=prof(2:3,:)+bg;


%--------------------------------------------------------------
function [stat, prof, name, statStd] = get_rms(prof, bg, cut_peak, cut_area)
% Get integrated moments. Cut optional, defaults to no cut

name='RMS';%bg=0;
if nargin < 4, cut_area=[];end
if nargin < 3, cut_peak=[];end

%if fitbg
%    bg=util_bgLevel(prof);
%    [a,b]=hist(prof(2,:),size(prof,2)*2);a(end)=0;
%    par=util_gaussFit(b,a,0,0);
%    if par(2) < min(b)
%        [d,idx]=max(a);
%        par(2)=b(idx);
%    end
%    bg=par(2);
    prof(2,:)=prof(2,:)-bg;
%end

if ~isempty(cut_peak)
    idx=prof(2,:) < cut_peak*max(prof(2,:));
    prof(2,idx)=0;
    name='RMS cut peak';
end

if ~isempty(cut_area)
    int=cumsum(prof(2,:));
    idLow=find(int < cut_area/2*int(end),1,'last');
    idHigh=find(int > (1-cut_area/2)*int(end),1,'first');
    prof(2,[1:idLow idHigh:end])=0;
    name='RMS cut area';
end

[int,xmean,xrms,xvar,skew,kurt]=util_moments(prof(1,:),prof(2,:));
dx=abs(mean(diff(prof(1,:))));
prof(3,:)=prof(1,:)*0+bg;
if xrms ~= 0
    prof(3,:)=prof(3,:)+int*dx/sqrt(2*pi)/xrms*exp(-((prof(1,:)-xmean)/xrms).^2./2);
end
prof(2,:)=prof(2,:)+bg;
stat=[int*dx xmean xrms skew kurt];
statStd=stat*0;


%--------------------------------------------------------------
function data = get_stats(method, profs, opts, varargin)
% Calculate correlation and pack everything into DATA.

[s.x,s.y,s.u,s.xStd,s.yStd,s.uStd]=deal([0 0 0 0 0]);
m='';int=0;intStd=0;
for tag='xyu'
    is.(tag)=isfield(profs,tag);
    if is.(tag)
        [s.(tag),data.(['prof' tag]),m, ...
            s.([tag 'Std'])]=feval(method,profs.(tag),opts.fitbg.(tag),varargin{:});
        dx=1;
        if opts.isimage && size(profs.(tag),2) > 1
            dx=abs(mean(diff(profs.(tag)(1,:))));
        end
        s.(tag)(1)=s.(tag)(1)/dx;
        data.([tag 'Stat'])=s.(tag);
        data.([tag 'StatStd'])=s.([tag 'Std']);
        int=s.(tag)(1);intStd=s.([tag 'Std'])(1);
    end
end

c=1;
if opts.isimage
    c=abs(mean(diff(profs.y(1,:)))/mean(diff(profs.x(1,:))));
end
xy=-s.u(3)^2*2*c/(1+c^2)+s.x(3)^2/2*c+s.y(3)^2/2/c;
dxy=[s.x(3)*c s.y(3)/c -2*s.u(3)*2*c/(1+c^2)];
xyStd=sqrt(diag(dxy*diag([s.xStd(3)^2 s.yStd(3)^2 s.uStd(3)^2])*dxy'))';

if is.x && is.y
    int=real(sqrt(s.x(1)*s.y(1)));
    dint=[sqrt(s.y(1)) sqrt(s.x(1))]/2/(int+1e-20);
    intStd=sqrt(diag(dint*diag([s.xStd(1)^2 s.yStd(1)^2])*dint'))';
end

data.method=m;
data.stats=[s.x(2) s.y(2) s.x(3) s.y(3) xy int];
data.statsStd=[s.xStd(2) s.yStd(2) s.xStd(3) s.yStd(3) xyStd intStd];
