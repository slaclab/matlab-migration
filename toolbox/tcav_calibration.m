function [cal, calstd] = tcav_calibration(phase, data, opts, dataStd)
%CALIBRATION
%  [CAL, CALSTD] = CALIBRATION(PHASE, DATA) calculates the calibration of
%  the transverse deflecting cavity from the beam centroids measured at
%  different phases of the TCAV.

% Features: 

% Input arguments:
%    PHASE: List of phase values of TCAV
%    DATA: List of data structures returned from beamParams()
%    OPTS: Options structure for plotting.
%          DOPLOT: Show results figure. Defaults to 1

% Output arguments:
%    CAL: TCAV calibration (pixel/degree or m/degree, depends on units in DATA)
%    CALSTD: Standard deviation of CAL

% Compatibility: Version 7 and higher
% Called functions: sigmaPlot

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 4, dataStd=[];end

% Set default options.
optsdef=struct( ...
    'doPlot',1, ...
    'figure',2, ...
    'axes',[], ...
    'plane','y', ...
    'xlab','TCAV phase  (Degree)', ...
    'ylab','Beam position', ...
    'title','', ...
    'ylim',[-Inf Inf], ...
    'units','pixel', ...
    'unitsT','degree');

% Use default options if OPTS undefined.
if nargin < 3, opts=struct;end
opts=util_parseOptions(opts,optsdef);

data=vertcat(data.stats);
plane=opts.plane == 'y';
data=data(:,1+plane);phase=phase(:);
if ~isempty(dataStd)
    dataStd=vertcat(dataStd.stats);
    dataStd=dataStd(:,1+plane);
end
%r(1,2,:)=cal*amp;r(1:2,1,:)=1;
%[par,covar,parstd,famp,fdata,fdatastd]=beamAnalysis_orbitFit(amp,r,data,dataStd);

datastd=dataStd;
if isempty(datastd) || ~all(datastd(:)), datastd=data*0+1;end
par=phase;

%r=reshape(r,4,[])';
m=[par*0+1 par];
[cal,calstd,mse,calcov]=lscov(m,data,1./datastd.^2);

fpar=linspace(min(par),max(par),100)';
fm=[fpar*0+1 fpar];
fdata=fm*cal;fdatastd=sqrt(diag(fm*calcov*fm'));
cal=cal(2);calstd=calstd(2);

opts.str=sprintf('cal = %5.0f\\pm+-%5.0f %s', ...
    cal,calstd,[opts.units '/' opts.unitsT]);

if opts.doPlot
    beamAnalysis_sigmaPlot(par,data,dataStd,fpar,fdata,fdatastd,opts);
end
