function bba_plotCorr(static, corrOff, appMode, varargin)
%BBA_PLOTCORR
%  BBA_PLOTCORR(STATIC, CORROFF, APPMODE, OPTS) .

% Features:

% Input arguments:
%    STATIC: Struct of device lists
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
    'figure',3, ...
    'axes',{{2 1}}, ...
    'title','Orbit Steering Corrector Strength', ...
    'useBPMNoise',1, ...
    'bpmNoise',3, ... % um
    'nEnergy',3, ...
    'enRange',[4.3 13.64], ...
    'fitResult',[], ...
    'corrB',[], ...
    'R',[], ...
    'iVal',[], ...
    'init',1);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Setup figure and axes.
hAxes=util_plotInit(opts);

% Plot Orbit.
zCorr=static.zCorr;
[corrB,bMax]=bba_corrGet(static,appMode);
isX=strncmp(static.corrList,'X',1);
isY=strncmp(static.corrList,'Y',1);
if ~any(isY), isY=isX;end
corrOff(~[isX isY]')=NaN;
if numel(zCorr) ~= size(corrB,2), corrB=corrOff*0;bMax=corrOff*NaN;end
[zUq,iUq]=unique(zCorr);

isX=~isnan(corrOff(1,:));
strX=sprintf('RMS Present/New\n%5.2f / %5.2f G-m',std(corrB(1,isX))*1e3,std(corrB(1,isX)+corrOff(1,isX))*1e3);
isY=~isnan(corrOff(2,:));
strY=sprintf('RMS Present/New\n%5.2f / %5.2f G-m',std(corrB(2,isY))*1e3,std(corrB(2,isY)+corrOff(2,isY))*1e3);

%legX=cellstr(num2str([en(:) std(xM(:,:,1),0,1)'*1e6],'En = %6.2f GeV, \\sigma_x = %6.1f um'));
%legY=cellstr(num2str([en(:) std(xM(:,:,2),0,1)'*1e6],'En = %6.2f GeV, \\sigma_y = %6.1f um'));

%yLim=max(bMax(:))*[-1.1 1.1];
yLim=max(abs([corrB(:);corrOff(:)]))*[-1.1 1.1];
if ~abs(diff(yLim)), yLim=[-1 1];end

ax=hAxes(1);
bar(ax,zUq,corrB(1,iUq),2,'k');
hold(ax,'on');
h=bar(ax,zUq,corrOff(1,iUq),'g','EdgeColor','g');
set(get(h(1),'BaseLine'),'LineStyle',':');
line(zCorr,bMax,'LineStyle',':','Parent',ax);
line(zCorr,-bMax,'LineStyle',':','Parent',ax);
h(1)=line(zCorr,zCorr*NaN,'Color','k','Parent',ax);
h(2)=line(zCorr,zCorr*NaN,'Color','g','Parent',ax);
text(.5,.95,strX,'Units','normalized','VerticalAlignment','top','Parent',ax);
line(static.zBPM,static.zBPM*0,'Color','k','Parent',ax);
set(ax,'YLim',yLim);

hold(ax,'off');
ylabel(ax,'Strength X (kG-m)');
legend(ax,h,{'Present Strength' 'Fit Strength Change'},'Location','NorthWest');legend(ax,'boxoff');
if ~isempty(opts.title)
    title(ax,opts.title);
end

ax=hAxes(2);
bar(ax,zUq,corrB(2,iUq),2,'k');
hold(ax,'on');
h=bar(ax,zUq,corrOff(2,iUq),'g','EdgeColor','g');
set(get(h(1),'BaseLine'),'LineStyle',':');
line(zCorr,bMax,'LineStyle',':','Parent',ax);
line(zCorr,-bMax,'LineStyle',':','Parent',ax);
h(1)=line(zCorr,zCorr*NaN,'Color','k','Parent',ax);
h(2)=line(zCorr,zCorr*NaN,'Color','g','Parent',ax);
text(.5,.95,strY,'Units','normalized','VerticalAlignment','top','Parent',ax);
line(static.zBPM,static.zBPM*0,'Color','k','Parent',ax);
set(ax,'YLim',yLim);%,'xLim',get(hAxes(1),'XLim'));

hold(ax,'off');
ylabel(ax,'Strength Y (kG-m)');
xlabel(ax,'z  (m)');
legend(ax,h,{'Present Strength' 'Fit Strength Change'},'Location','NorthWest');legend(ax,'boxoff');
