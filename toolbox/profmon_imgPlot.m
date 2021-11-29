function profmon_imgPlot(data, varargin)
%PROFMON_IMGPLOT
%  PROFMON_IMGPLOT(DATA, OPTS) plots image in DATA with options OPTS.

% Features:

% Input arguments:
%    DATA: Structure of camera image and camera properties
%    OPTS: options struct
%          BUFD: get buffered images, default is 0
%          DOPLOT: show image if set to 1, default is 0

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, util_plotInit, profmon_imgFlip,
%                   profmon_coordTrans, util_dataSave

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',2, ...
    'axes',[], ...
    'aspect',0, ...
    'cal',0, ...
    'scale',1, ...
    'useBG',0, ...
    'rawImg',0, ...
    'bits',[], ...
    'target',[], ...
    'lineOut',1, ...
    'tag',0, ... % Put screen name on image for TAG > 0 with intensity TAG
    'tcav',0, ...
    'ener',0, ...
    'colormap','jet', ...
    'cross',[], ...
    'cross2',[], ... % places second cross on the figure
    'crossColor',[],... %designates color of cross
    'scale2',[], ...
    'saves', 0, ... % Saves .figs images to a directory
    'title','%s');

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Setup figure and axes.
[hAxes,hFig]=util_plotInit(opts);
if size(get(gcf,'Colormap'),1) < 256
    set(hFig,'Colormap',feval(opts.colormap,256));
end

if ~all(data.res), data.res(:)=1;end

% Subtract background.
if opts.useBG && isfield(data,'back')
    data.img=int16(data.img)-int16(data.back);
end
if data.isRaw ~= opts.rawImg
    data=profmon_imgFlip(data);
    if ~isempty(opts.target)
        opts.target=profmon_coordTrans(opts.target,data,'pixel');
    end
    if ~isempty(opts.cross)
        opts.cross=profmon_coordTrans(opts.cross,data,'mm');
    end
    if ~isempty(opts.cross2)
        opts.cross2=profmon_coordTrans(opts.cross2,data,'mm');
    end
end

% Get image coordinates.
yDirList={'normal' 'reverse'};
pos.x=data.roiX+[1 data.roiXN]+.5*[-1 1];
pos.y=data.roiY+[1 data.roiYN]+.5*[-1 1];
pos.units='Pixel';
xLab='x';yLab='y';
if ~isempty(opts.target)
    iTarget=min(max(1,ceil(opts.target.x)-data.roiX),data.roiXN);
    jTarget=min(max(1,ceil(opts.target.y)-data.roiY),data.roiYN);
    iTarget=ceil(iTarget*size(data.img,2)/data.roiXN);
    jTarget=ceil(jTarget*size(data.img,1)/data.roiYN);
end
if opts.cal
    pos=profmon_coordTrans(pos,data,'mm');
    if ~isempty(opts.target)
        opts.target=profmon_coordTrans(opts.target,data,'mm');
    end
    if opts.tcav
        data.tcavCal=lcaGet([data.name ':BLEN_P'])*1e3;
        pos.y=pos.y/data.tcavCal*1e3;
        unitsY='Degree';yLab='\phi';
    end
    if opts.ener && isfield(data,'enerCal')
        if numel(data.enerCal) == 2
            y0=pos.y;
            y=data.enerCal(2)./(1-linspace(y0(1),y0(2),10)/data.enerCal(1));
            dy1=abs(diff(y));
            dum=round(log10(dy1)*5)/5;
            dy2=10.^floor(dum).*round(10.^mod(dum,1));dy2(end+1)=dy2(end);
            pos.y=data.enerCal(2)./(1-pos.y/data.enerCal(1));
            unitsY='GeV';yLab='Energy';
%            dy0=abs(diff(pos.y))/10;
%            dy=10^floor(round(log10(dy0)*3)/3)*round(10^mod(round(log10(dy0)*3)/3,1));
%            yTLab=ceil(min(pos.y)/dy)*dy:dy:floor(max(pos.y)/dy)*dy;
            yTLab=sort(round(y./dy2).*dy2);
            y1=(1-data.enerCal(2)./yTLab)*data.enerCal(1);
            yTick=interp1(y0,pos.y,y1);
        else
            pos.x=pos.x*data.enerCal/data.res(1)*1e3;
            unitsY=pos.units;pos.units='eV';xLab='Energy';
        end
        
    end
else
    if ~isempty(opts.cross)
        opts.cross=profmon_coordTrans(opts.cross,data,'pixel');
    end
    if ~isempty(opts.cross2)
        opts.cross2=profmon_coordTrans(opts.cross2,data,'pixel');
    end
end
if ~exist('unitsY','var'), unitsY=pos.units;end
yDir=yDirList{sign(diff(pos.y))/2+1.5};

% Plot image and set axes.
delete(get(hAxes,'Children'));
pOpts={'Parent',hAxes,'HitTest','off'};
if size(data.img,3) > 1
    data.img(:,:,2)=.6*data.img(:,:,2);
    if isempty(opts.bits)
        data.img=double(data.img)/double(max(data.img(:)));
    else
        data.img=min(double(data.img)/2^min(opts.bits,data.bitdepth),1);
    end
end
plot_img=image('CData',data.img,'CDataMapping','scaled',pOpts{:});
set(plot_img,'XData',pos.x,'YData',pos.y);

if opts.aspect
    if ~any([data.roiXN data.roiYN] == 1)
        set(hAxes,'PlotBoxAspectRatio',[data.roiXN*data.res(1) data.roiYN*data.res(end) 1]);
    end
end
if opts.scale
    if opts.scale2
        pos.x = opts.scale2(1:2);
        pos.y = opts.scale2(3:4);
    end
    set(hAxes,'XLim',pos.x,'YLim',sort(pos.y));
end
%if opts.xyEqual
%    xl=get(hAxes,'XLim');xd=diff(xl);
%    yl=get(hAxes,'YLim');yd=diff(yl);
%    sc=sqrt(prod([xd yd]));
%    set(hAxes,'XLim',mean(xl)+sc/2*[-1 1]);
%    set(hAxes,'YLim',mean(yl)+sc/2*[-1 1]);
%end

set(hAxes,'YTickMode','auto','YTickLabelMode','auto');
if exist('yTick','var')
    set(hAxes,'YTick',yTick,'YTickLabel',num2str(yTLab','%g'));
end

if ~all(opts.bits)
    set(hAxes,'CLimMode','auto');
elseif ~isempty(opts.bits)
    %bins=data.roiXN*data.roiYN/numel(data.img);
    bins=1;
    set(hAxes,'CLim',[0 2^min(opts.bits,max(data.bitdepth,1))*bins-1]);
end
set(hAxes,'YDir',yDir);
xlabel(hAxes,[xLab '  (' pos.units ')']);
ylabel(hAxes,[yLab '  (' unitsY ')']);
if ~any(strfind(opts.title,'%s')), opts.title=['%s ' opts.title];end
title(hAxes,sprintf(opts.title,data.name));
if opts.tag
    text('Units','normalized','Position',[.95 .95 0],pOpts{:},'Interpreter','none', ...
        'String',model_nameConvert(data.name,'MAD'),'FontSize',30, ...
        'Color',[1 1 0]*opts.tag, ...
        'HorizontalAlignment','right','VerticalAlignment','top');
end
x=get(hAxes,'XLim');y=get(hAxes,'YLim');
if opts.cal, y=y([2 1]);end
if ~isempty(opts.target)
    scl=[diff(x) -diff(y)]/2;
    if size(data.img,3) > 1, scl=scl/3*2^opts.bits;end
    scl=scl/(get(hAxes,'CLim')*[0;1]);
    line(pos.x,opts.target.y*[1 1],'Color','w','LineStyle','--',pOpts{:});
    line(opts.target.x*[1 1],pos.y,'Color','w','LineStyle','--',pOpts{:});
    if opts.lineOut
        line(linspace(pos.x(1),pos.x(2),size(data.img,2)),y(2)+sum(double(data.img(jTarget,:,:)),3)*scl(2),'Color','y',pOpts{:});
        line(x(1)+sum(double(data.img(:,iTarget,:)),3)'*scl(1),linspace(pos.y(1),pos.y(2),size(data.img,1)),'Color','y',pOpts{:});
    end
end
if ~isempty(opts.cross)
    scl=[diff(x) -diff(y)]/20;
    pOptsC=[{'LineWidth',2,'Color','w','LineStyle','-',} pOpts];
    line(opts.cross.x+scl(1)*[-1 1],opts.cross.y*[1 1],pOptsC{:});
    line(opts.cross.x*[1 1],opts.cross.y+scl(end)*[-1 1],pOptsC{:});
end
if ~isempty(opts.cross2)
    scl=[diff(x) -diff(y)]/20;
%     pOptsC=[{'LineWidth',2,'Color','r','LineStyle','-',} pOpts];
    pOptsC=[{'LineWidth',2,'Color',opts.crossColor,'LineStyle','-',} pOpts];
    line(opts.cross2.x+scl(1)*[-1 1],opts.cross2.y*[1 1],pOptsC{:});
    line(opts.cross2.x*[1 1],opts.cross2.y+scl(end)*[-1 1],pOptsC{:});
end

if opts.saves
    data.back=0;
    util_dataSave(data,'ProfMon',data.name,now,0);
else
    drawnow;
end
