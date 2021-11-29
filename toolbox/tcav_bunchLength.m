function [sigx,sigt,sigxstd,sigtstd,r35,r35std] = tcav_bunchLength(amp, data, cal, calstd, opts, dataStd)
%TCAV_BUNCHLENGTH
%  [SIGX, SIGT, SIGXSTD, SIGTSTD, R35, R35STD] = TCAV_BUNCHLENGTH(AMP, DATA, CAL, CALSTD, OPTS, DATASTD)
%  calculates the bunchlength from the beam sizes measured with three
%  different settings of the transverse deflecting cavity.

% Features:
% TCAV amplitude AMP is normalized to +-1.TCAV off is AMP = 0,
% The parameter DATA contains the beam fit data as returned from
% BEAMANALYSIS_BEAMPARAMS().
% The calibration CAL is m/Degree or pixel/Degree and must match the units
% in DATA. CALSTD is the uncertaincy of the calibration factor.
% The return value SIGX is the uncorrelated transverse beam size in the
% same units as DATA.
% SIGT is the bunch length in degrees.
% SIGXSTD and SIGTSTD are the respective standard deviations.
% R35 and R35STD are the transverse time correlation and std deviation.
% OPTS is a struct with options for the plotting.

% Compatibility: Version 7 and higher
% Called functions: sigmaFit, sigmaPlot

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 6, dataStd=[];end
if nargin < 4, calstd=0;end
if nargin < 3, cal=1;end

% Set default options.
optsdef=struct( ...
    'doPlot',1, ...
    'figure',2, ...
    'axes',[], ...
    'plane','y', ...
    'xlab','TCAV amplitude  (norm.)', ...
    'title','', ...
    'units','pixel', ...
    'unitsT','degree');

% Use default options if OPTS undefined.
if nargin < 5, opts=struct;end
opts=util_parseOptions(opts,optsdef);

data=vertcat(data.stats);
plane=opts.plane == 'y';
data=data(:,3+plane);amp=amp(:);
if ~isempty(dataStd)
    dataStd=vertcat(dataStd.stats);
    dataStd=dataStd(:,3+plane);
end
r(1,2,:)=cal*amp;r(1:2,1,:)=1;
[par,covar,parstd,famp,fdata,fdatastd]=beamAnalysis_sigmaFit(amp,r,data,dataStd);

sizes=sqrt(par([1 3]));
sizesstd=parstd([1 3])./sizes/2;
sigx=sizes(1);sigt=sizes(2);sigxstd=sizesstd(1);sigtstd=sizesstd(2);
sigtstd=sigt*sqrt((sigtstd/sigt)^2+(calstd/cal)^2);
r35=par(2)/prod(sizes);dr35=[-1/par(1) 2/par(2) -1/par(3)]*r35/2;
r35std=sqrt(dr35*covar*dr35');

opts.str=sprintf(['\\sigma_%s = %5.2f\\pm%5.2f %s\n' ...
                  '\\sigma_z = %5.3f\\pm%5.3f %s\n' ...
                  'r_{%1d5} = %5.3f\\pm%5.3f\n' ...
                  'cal = %5.3f\\pm%5.3f %s/%s'], ...
    opts.plane,sizes(1),sizesstd(1),opts.units,sizes(2),sigtstd,opts.unitsT, ...
    1+2*plane,r35,r35std,cal,calstd,opts.units,opts.unitsT);

if opts.doPlot
    beamAnalysis_sigmaPlot(amp,data,dataStd,famp,fdata,fdatastd,opts);
end
