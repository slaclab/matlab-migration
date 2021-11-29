function beamAnalysis_sigmaPlot(par, data, datastd, fpar, fdata, fdatastd, opts)
%SIGMAPLOT
%  SIGMAPLOT(PAR, DATA, DATASTD, FPAR, FDATA, FDATASTD, OPTS) plots the
%  results of the sigma-fit.

% Features:

% Input arguments:
%    PAR: Values for x-axis
%    DATA: Values for y-axis
%    DATASTD: Std of values
%    FPAR: Values for fit-line for x-axis
%    FDATA: Fit-line values for y-axis
%    FDATASTD: Std of fit-line
%    OPTS: Options stucture with fields (optional):
%        FIGURE: Figure handle
%        AXES: Axes handle
%        XLAB: Label for x-axis
%        UNITS: Units label for y-axis
%        SCALE: Scale factor for y-axis
%        STR: String to display in plot
%        XLIM, YLIM: Limits for x- and y-axis

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',1, ...
    'axes',[], ...
    'xlab','Parameter', ...
    'ylab','Beam Size', ...
    'units','pixel', ...
    'scale',1, ...
    'str','', ...
    'title','', ...
    'res',0, ...
    'xlim',[], ...
    'ylim',[]);

% Use default options if OPTS undefined.
if nargin < 7, opts=struct;end
opts=util_parseOptions(opts,optsdef);

% Setup figure and axes.
hAxes=util_plotInit(opts);hAxes=hAxes(1);

if isempty(opts.xlim), opts.xlim=[min(par) max(par)]*[1.1 -.1;-.1 1.1];end
if isempty(opts.ylim), opts.ylim=[0 max(data)*1.1];end
if ~diff(opts.xlim), opts.xlim=mean(opts.xlim)+[-.5 .5];end
if ~diff(opts.ylim), opts.ylim=mean(opts.ylim)+[-.5 .5];end
util_errorBand(fpar,fdata*opts.scale,fdatastd*opts.scale,'k','Parent',hAxes);
hold(hAxes,'on');
if any(datastd), errorbar(par,data*opts.scale,datastd*opts.scale,'r.','Parent',hAxes);
else plot(par,data*opts.scale,'r.','Parent',hAxes);end
if any(opts.res)
    plot(par,opts.res(min(1:length(par),end))*opts.scale,'ok','Parent',hAxes);
end
set(hAxes,'XLim',opts.xlim,'YLim',opts.ylim*opts.scale);
hold(hAxes,'off');
xlabel(hAxes,opts.xlab);
ylabel(hAxes,[opts.ylab '  (' opts.units ')']);
title(hAxes,opts.title);
text(.2,.95,opts.str,'Units','normalized','VerticalAlignment','top','Parent',hAxes);
