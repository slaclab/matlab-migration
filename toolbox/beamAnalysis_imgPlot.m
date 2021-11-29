function beamAnalysis_imgPlot(beam, img, data, varargin)
%BEAMANALYSIS_IMGPLOT
%  BEAMANALYSIS_IMGPLOT(BEAM, IMG, DATA, OPTS)

% Input arguments:
%    BEAM: Structure returned from beamAnalysis_beamParams
%    IMG:  Full or cropped imaged to display
%    DATA: Image data struct from profmon_grab
%    OPTS: Options stucture with fields (optional):
%          FIGURE:
%          FULL:
%          XLIM, YLIM:

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: parseOptions, profmon_coordTrans, util_plotInit,
%                   beamAnalysis_getEllipse

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'figure',[], ...
    'axes',{{2 2}}, ...
    'full',0, ...
    'xlim',[], ...
    'ylim',[], ...
    'title','', ...
    'units','', ...
    'unitsY','');

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if isempty(opts.unitsY), opts.unitsY=opts.units;end
lim.x=beam.profx(1,[1 end]);
lim.y=beam.profy(1,[1 end]);
if opts.full
    if isfield(data,'full')
        imgFull=data.full;
    else
        imgFull=data.img;
    end
    bin=[data.roiYN data.roiXN]./size(imgFull);
    pos.x=beam.profx(1,:);pos.y=beam.profy(1,:);
    if strcmp(opts.units,'um'), pos=profmon_coordTrans(pos,data,'Pixel');end
    imgFull((pos.y-data.roiY)/bin(1),(pos.x-data.roiX)/bin(2))=img;
    img=imgFull;
    lim.x=data.roiX+[1 data.roiXN];lim.y=data.roiY+[1 data.roiYN];
    lim.units='Pixel';
    lim=profmon_coordTrans(lim,data,opts.units);
end
if ~diff(lim.x), lim.x=lim.x+[-.5 .5];end
if ~diff(lim.y), lim.y=lim.y+[-.5 .5];end

[hAxes,hFig]=util_plotInit(opts);
set(hFig,'Colormap',jet(256));
%util_marginSet(hFig,[.12 0.02 .05],[.12 0.02 .05]);

ax=hAxes(2);
if max(img(:)) <= 255
    image(lim.x,lim.y,img,'Parent',ax);
else
    imagesc(lim.x,lim.y,img,'Parent',ax);
end
yDir='normal';
if lim.y(1) < lim.y(2), yDir='reverse';beam.stats(5)=-beam.stats(5);end
[ell,cross]=beamAnalysis_getEllipse(beam.stats,2);
hold(ax,'on');
plot(real(ell(1,:)),real(ell(2,:)),'y',real(cross(1,:)),real(cross(2,:)),'k','Parent',ax);
hold(ax,'off');
if ~isempty(opts.xlim), lim.x=opts.xlim;end
if ~isempty(opts.ylim), lim.y=opts.ylim;end
set(ax,'XLim',lim.x,'YLim',sort(lim.y),'YDir',yDir);
title(ax,opts.title);

ax=hAxes(4);
plot(beam.profx(1,:),beam.profx(2,:),beam.profx(1,:),beam.profx(3,:),'--r','Parent',ax);
set(ax,'XLim',lim.x);
xlabel(ax,['x  (' opts.units ')']);

ax=hAxes(1);
plot(beam.profy(2,:),beam.profy(1,:),beam.profy(3,:),beam.profy(1,:),'--r','Parent',ax);
set(ax,'YLim',sort(lim.y),'YDir',yDir);
ylabel(ax,['y  (' opts.unitsY ')']);

ax=hAxes(3);cla(ax);set(ax,'Visible','off');
beam.stats(5)=beam.stats(5)/prod(beam.stats(3:4));
str=[strcat('x',{'mean' 'rms'},[' = %5.2f ' opts.units '\n']);
     strcat('y',{'mean' 'rms'},[' = %5.2f ' opts.unitsY '\n'])];
%text(0,.7,sprintf([str{:} 'corr = %5.2f ' opts.units '^2\nsum = %5.2f Mcts'], ...
set(get(hAxes(4),'XLabel'),'Units','normalized');
yPos=get(get(hAxes(4),'XLabel'),'Extent');
text(0,yPos(2),sprintf([str{:} 'corr = %5.2f ' '\nsum = %6.3f Mcts' '\n\n%s'], ...
    beam.stats.*[1 1 1 1 1 1e-6],datestr(data.ts)),'Parent',ax,'VerticalAlignment','bottom');
drawnow;
