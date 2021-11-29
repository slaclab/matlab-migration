function emittance_beamEllipsePlot(rMat, data, datastd, sigmaAct, sigmaDes, varargin)
%BEAMELLIPSEPLOT
%  BEAMELLIPSEPLOT(RMAT, DATA, DATASTD, SIGMAACT, SIGMADES, OPTS) plots
%  beam ellipse and data points.

% Features:

% Input arguments:
%    RMAT: List of transport matrices for data points
%    DATA: Measured beamsizes
%    DATASTD: Std of measured beam sizes
%    SIGMAACT: Measured sigma matrix of beam
%    SIGMADES: Design sigma matrix of beam
%    OPTS: Options stucture with fields (optional):
%        FIGURE: Figure handle
%        AXES:   Axes handle
%        XLAB:   Label for x-axis
%        YLAB:   Label for y-axis
%        TITLE:  Title
%        NORMPS: Plot normalized phase space, default 0

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',2, ...
    'axes',[], ...
    'normPS',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Setup figure and axes.
hAxes=util_plotInit(opts);hAxes=hAxes(end);

rNorm=eye(2)*1e6; % display in um
if opts.normPS
%    [v,lam]=eig(sigmaDes);ei=v*sqrt(lam);
%    eps=sqrt(det(sigmaDes));
%    rNorm=[1 0;-sigmaDes(2)/eps sigmaDes(1)/eps]/sqrt(sigmaDes(1));
    twiss=model_sigma2Twiss(sigmaDes([1 2 4])'); % Unnormalized emittance
    rNorm=inv(model_twissB(twiss))/sqrt(twiss(1)); % x_norm = r_norm * x
%    eps=sqrt(det(sigmaAct));
%    rNorm=[1 0;-sigmaAct(2)/eps sigmaAct(1)/eps]/sqrt(sigmaAct(1));
    set(hAxes,'PlotBoxAspectRatio',[1 1 1]);
end

if isempty(datastd)
    datastd=data*0;
end

sigma=rNorm*sigmaAct*rNorm';
sigmaDes=rNorm*sigmaDes*rNorm';
ellipseAct=beamAnalysis_getEllipse([0 0 sqrt(sigma([1 4])) sigma(2) 0]);
ellipseDes=beamAnalysis_getEllipse([0 0 sqrt(sigmaDes([1 4])) sigmaDes(2) 0]);

h=plot(ellipseAct(1,:),ellipseAct(2,:),'Color','k','Parent',hAxes);
%xl=max(ellipseAct(1,:));yl=max(ellipseAct(2,:));
col=get(hAxes,'ColorOrder');
n=ones(3,1)*linspace(-1,1,100)*1.3;
x=n*real(sqrt(sigma(1)));y=n*real(sqrt(sigma(4)));
if opts.normPS
    lim=max([x(:);y(:)])/1.3;
    x=n*lim;y=n*lim;
end
for j=1:size(rMat,3)
    x0=data(j)+repmat([0;[-1;1]*datastd(j)],1,100);
    m=inv(rMat(:,:,j)*inv(rNorm));
    if sqrt(sigma(1))*abs(m(2,2)) < sqrt(sigma(4))*abs(m(1,2))
        yp=(m(2,2)*x-det(m)*x0)/m(1,2);xp=x;
        use=abs(yp(1,:)) < y(1,end);
    else
        xp=(m(1,2)*y+det(m)*x0)/m(2,2);yp=y;
        use=abs(xp(1,:)) < x(1,end);
    end
    xp=xp(:,use);yp=yp(:,use);
    patch([xp(2,:) fliplr(xp(3,:))],[yp(2,:) fliplr(yp(3,:))], ...
        1-.25+.25*col(mod(j-1,size(col,1))+1,:),'EdgeColor','none','Parent',hAxes);
    line(xp(1,:),yp(1,:),'Color',col(mod(j-1,size(col,1))+1,:),'LineStyle','--','Parent',hAxes);
    if opts.normPS
       ph=atan2(-m(1,2),m(2,2));
%        ph=atan2(eps*rMat(1,2,j),sigmaAct(2)*rMat(1,2,j)+sigmaAct(1)*rMat(1,1,j));
        line([0 cos(ph)],[0 sin(ph)],'Color',col(mod(j-1,size(col,1))+1,:),'LineStyle','--','Parent',hAxes);
    end
end
line(ellipseDes(1,:),ellipseDes(2,:),'Color','g','LineStyle','-.','Parent',hAxes);
xLim=real(x(1,[1 end]));yLim=real(y(1,[1 end]));
if any(xLim) && any(yLim)
    set(hAxes,'XLim',xLim,'YLim',yLim);
end
xLab='Position  (\mum)';
yLab='Angle  (\murad)';
tLab='Phase Space';
if opts.normPS
    xLab='Norm. Position';
    yLab='Norm. Angle';
    tLab='Normalized Phase Space';
end
xlabel(hAxes,xLab);
ylabel(hAxes,yLab);
title(hAxes,tLab);
uistack(h,'top');
if opts.normPS
    set(hAxes,'PlotBoxAspectRatio',[1 1 1]);
end
