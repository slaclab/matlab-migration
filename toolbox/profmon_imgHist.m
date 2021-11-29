function profmon_imgHist(pv, varargin)
%PROFMON_IMGHIST
%  PROFMON_IMGHIST(PV, OPTIONS) plots an intensity histogram of the image
%  either obtained for camera named in string PV, or from data in struct PV
%  as returned from profmon_grab.

% Features:

% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211 or struct returned
%    from profmon_grab

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, util_plotInit, profmon_grab,
%                   util_gaussFit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'figure',[], ...
    'axes',[], ...
    'useAll',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Setup figure and axes.
hAxes=util_plotInit(opts);

if isstruct(pv)
    data=pv;
else
    data=profmon_grab(pv,1);
end
if ~isfield(data,'bitdepth'), data.bitdepth=12;end
intmin=min([0 double(min(data.img(:)))]);
intmax=2^data.bitdepth-1;
idx=ceil(numel(data.img)*rand(100000,1));
if opts.useAll, idx=1:numel(data.img);end
[counts,intens]=hist(data.img(idx),intmin:intmax);
counts(1)=0;countsF=counts;countsF(end)=0;
[parc,yfc]=util_gaussFit(intens,countsF);
if counts(end), intens(end+1)=intmax;counts(end+1)=1;yfc(end+1)=0;end
plot(intens,counts,'-b',intens,yfc,'-r','Parent',hAxes);
set(hAxes,'YScale','log');
if parc(2) <= max(intens)
    line(parc(2)*[1 1],[1 max(counts*1.5)],'Parent',hAxes,'LineStyle','-','Color','k');
end
text(.4,.8,sprintf('BG_{Mean} = %5.1f\nBG_{RMS} = %5.1f',parc(2:3)),'units','normalized','Parent',hAxes);
set(hAxes,'YLim',[1 Inf]);
%set(hAxes,'XLim',[0 Inf]);
xlabel(hAxes,'Intensity');
ylabel(hAxes,'Counts');
title(hAxes,['Intensity Histogram ' data.name ' ' datestr(data.ts)]);
