function hAxes = bba_plotOrbit(static, xMeas, xMeasStd, xMeasF, en, varargin)
%BBA_PLOTORBIT
%  BBA_PLOTORBIT(STATIC, XMEAS, XMEASSTD, XMEASF, EN, OPTS) .

% Features:

% Input arguments:
%    STATIC: Struct of device lists
%    OPTS:   Options stucture with fields (optional):
%        FIGURE: Figure handle
%        AXES: Axes handle
%        TITLE: Plot title
%        XLIM: Limits for x-axes
%        YLIM: Limits for y-axes

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',1, ...
    'axes',{{2 1}}, ...
    'title','', ...
    'useBPMNoise',1, ...
    'bpmNoise',3, ... % um
    'nEnergy',3, ...
    'enRange',[4.3 13.64], ...
    'fitResult',[], ...
    'corrB',[], ...
    'R',[], ...
    'iVal',[], ...
    'xlim',[], ...
    'ylim',[]);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Setup figure and axes.
hAxes=util_plotInit(opts);

% Plot Orbit.
[zBPM,idZ]=sort(static.zBPM);zQuad=static.zQuad;
xM=permute(xMeas,[2 3 1]);xMF=permute(xMeasF,[2 3 1]);
xMStd=permute(xMeasStd,[2 3 1]);

if isempty(xM), xM=nan(length(zBPM),1,2);xMF=xM;end
if isempty(xMF), xMF=nan*xM;end

if ~isempty(xM), xM(:,:)=xM(idZ,:);xMF(:,:)=xMF(idZ,:);end
if ~isempty(xMStd), xMStd(:,:)=xMStd(idZ,:);end

if ~isempty(opts.corrB)
    isX=strncmp(static.corrList,'X',1);
    isY=strncmp(static.corrList,'Y',1);
    if ~any(isY), isY=isX;end
    opts.corrB(~[isX isY]')=NaN;
    [zUq,iUq]=unique(static.zCorr);
end

%if ~isempty(opts.fitResult)
%    xM=xM+repmat(reshape(opts.fitResult.bpmOff',[],1,2),1,size(xM,2));
%    xMF=xMF+repmat(reshape(opts.fitResult.bpmOff',[],1,2),1,size(xM,2));
%end
%if ~isempty(opts.R) && ~isempty(opts.fitResult)
%    iVal=find(opts.iVal);
%    for j=1:length(iVal)
%        R=opts.R{iVal(j)};
%        xM(:,j,:)=xM(:,j,:)-reshape(reshape(R(:,1:4)*opts.fitResult.xInit(:,iVal(j)),2,[])',[],1,2);
%        xMF(:,j,:)=reshape(reshape(R(:,5:(4+66))*[opts.fitResult.quadOff(:)],2,[])',[],1,2);
%    end
%end

[legX,legY]=deal({});
if ~isempty(en)
    legX=cellstr(num2str([en(:) util_stdNan(xM(:,:,1),0,1)'*1e6],'En = %6.2f GeV, \\sigma_x = %6.1f \\mum'));
    legY=cellstr(num2str([en(:) util_stdNan(xM(:,:,2),0,1)'*1e6],'En = %6.2f GeV, \\sigma_y = %6.1f \\mum'));
end

ax=hAxes(1);
col='r';siz=size(xM,2);
if siz > 1, col='';end
scl=1e6;units='\mum';
if max(abs(xM(:))) > 1e-3, scl=1e3;units='mm';end
if ~isempty(opts.corrB)
    h3=bar(ax,zUq,opts.corrB(1,iUq)*scl/10,'g','EdgeColor','g');
    set(get(h3,'BaseLine'),'LineStyle','none');
    legX{end+1}='Predicted Orbit';
    hold(ax,'on');
end
if ~isempty(xMeasStd)
    h=errorbar(ax,repmat(zBPM(:),1,siz),xM(:,:,1)*scl,xMStd(:,:,1)*scl);
else
    h=plot(ax,zBPM,xM(:,:,1)*scl);
end
hold(ax,'on');
h2=plot(ax,zBPM,xM(:,:,1)*NaN,zBPM,xMF(:,:,1)*scl,[col '.--']);
plot(ax,zQuad,zQuad*0,'k.','Color',[.5 .5 .5]);
plot(ax,zBPM,zBPM*0,'k.');
isW=strncmp(static.bpmList(idZ),'W',1);plot(ax,zBPM(isW),xMF(isW,:,1)*scl,'bx');
if ~isempty(opts.corrB)
    h=[h(:);h2(end/2+1)];
end
hold(ax,'off');
ylabel(ax,['x Pos  (' units ')']);
if ~isempty(en), legend(ax,h,legX,'Location','NorthWest');legend(ax,'boxoff');end
if ~isempty(opts.title)
    title(ax,opts.title);
end

ax=hAxes(2);
if ~isempty(opts.corrB)
    h3=bar(ax,zUq,opts.corrB(2,iUq)*scl/10,'g','EdgeColor','g');
    set(get(h3,'BaseLine'),'LineStyle','none');
    legY{end+1}='Predicted Orbit';
    hold(ax,'on');
end
if ~isempty(xMeasStd)
    h=errorbar(ax,repmat(zBPM(:),1,siz),xM(:,:,2)*scl,xMStd(:,:,2)*scl);
else
    h=plot(ax,zBPM,xM(:,:,2)*scl);
end
hold(ax,'on');
h2=plot(ax,zBPM,xM(:,:,2)*NaN,zBPM,xMF(:,:,2)*scl,[col '.--']);
plot(ax,zQuad,zQuad*0,'k.','Color',[.5 .5 .5]);
plot(ax,zBPM,zBPM*0,'k.');
isW=strncmp(static.bpmList(idZ),'W',1);plot(ax,zBPM(isW),xMF(isW,:,2)*scl,'bx');
if ~isempty(opts.corrB)
    h=[h(:);h2(end/2+1)];
end
hold(ax,'off');
ylabel(ax,['y Pos  (' units ')']);
xlabel(ax,'z  (m)');
if ~isempty(en), legend(ax,h,legY,'Location','NorthWest');legend(ax,'boxoff');end

if ~isempty(opts.ylim), set(hAxes(1:2),'YLim',opts.ylim*scl/1e6);end
