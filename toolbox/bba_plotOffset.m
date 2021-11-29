function hAxes = bba_plotOffset(static, quadOffF, bpmOffF, appMode, varargin)
%BBA_PLOTOFFSET
%  BBA_PLOTOFFSET(STATIC, QUADOFF, BPMOFF, APPMODE, OPTS) .

% Features:

% Input arguments:
%    STATIC:  Struct of device lists
%    QUADOFF: Array or cell array of quad offsets
%    BPMOFF:  Array or cell array of bpm offsets
%    OPTS:    Options stucture with fields (optional):
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

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit

% Set default options.
optsdef=struct( ...
    'figure',2, ...
    'axes',[], ...
    'title','', ...
    'xlim',[], ...
    'ylim',[]);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

zQuad=static.zQuad;
zBPM=static.zBPM;
bOff=bpmOff;qOff=quadOff;leg={'BPM Offset Fit' 'Quad Offset Fit' 'BPM Simul' 'Quad Simul'};
if numel(zBPM) ~= size(bOff,2), appMode=1;end
nSub=3;
if appMode
    nSub=2;bOff=zeros(2,0);qOff=bOff;leg={'BPM Offset Fit' 'Quad Offset Fit'};
end

if iscell(bpmOffF)
    bpmOffFStd=bpmOffF{2};bpmOffF=bpmOffF{1};
    quadOffFStd=quadOffF{2};quadOffF=quadOffF{1};
else
    bpmOffFStd=[];
end
if all(isnan(bpmOffF(:))), bOff(:)=NaN;end

% Setup figure and axes.
if isempty(opts.axes), opts.axes={nSub 1};end
hAxes=util_plotInit(opts);

% Plot results.
scl=1e6;units='\mum';
if max(abs([bpmOffF(:);quadOffF(:)])) > 1e-3, scl=1e3;units='mm';end
if ~isempty(bpmOffFStd)
    errorbar(hAxes(1),zBPM,bpmOffF(1,:,1)*scl,bpmOffFStd(1,:,1)*scl,'.-b');
    hold(hAxes(1),'on');
    errorbar(hAxes(1),zQuad,quadOffF(1,:,1)*scl,quadOffFStd(1,:,1)*scl,'.-r');
else
    plot(hAxes(1),zBPM,bpmOffF(1,:,1)*scl,'.-b',zQuad,quadOffF(1,:,1)*scl,'.-r');
    hold(hAxes(1),'on');
end
if ~appMode
    plot(hAxes(1),zBPM,bOff(1,:,1)*scl,'.:m',zQuad,qOff(1,:,1)*scl,'.:g');
end
hold(hAxes(1),'off');
ylabel(hAxes(1),['x Off  (' units ')']);
legend(hAxes(1),leg,'Location','NorthWest');legend(hAxes(1),'boxoff');
if ~isempty(opts.title)
    title(hAxes(1),opts.title);
end

if ~isempty(bpmOffFStd)
    errorbar(hAxes(2),zBPM,bpmOffF(2,:,1)*scl,bpmOffFStd(2,:,1)*scl,'.-b');
    hold(hAxes(2),'on');
    errorbar(hAxes(2),zQuad,quadOffF(2,:,1)*scl,quadOffFStd(2,:,1)*scl,'.-r');
else
    plot(hAxes(2),zBPM,bpmOffF(2,:,1)*scl,'.-b',zQuad,quadOffF(2,:,1)*scl,'.-r');
    hold(hAxes(2),'on');
end
if ~appMode
    plot(hAxes(2),zBPM,bOff(2,:,1)*scl,'.:m',zQuad,qOff(2,:,1)*scl,'.:g');
end
hold(hAxes(2),'off');
ylabel(hAxes(2),['y Off  (' units ')']);
legend(hAxes(2),leg,'Location','NorthWest');legend(hAxes(2),'boxoff');

if ~isempty(opts.ylim), set(hAxes(1:2),'YLim',opts.ylim*scl/1e6);end

if appMode, return, end

useB=any(bpmOffF(:,:,1));useQ=any(quadOffF(:,:,1));
errBPM=bpmOffF(:,:,1)-bpmOff(:,:,1);errQuad=quadOffF(:,:,1)-quadOff(:,:,1);
errBPM=errBPM-[polyval(polyfit(zBPM(useB),errBPM(1,useB),1),zBPM);polyval(polyfit(zBPM(useB),errBPM(2,useB),1),zBPM)];
errQuad=errQuad-[polyval(polyfit(zQuad(useQ),errQuad(1,useQ),1),zQuad);polyval(polyfit(zQuad(useQ),errQuad(2,useQ),1),zQuad)];
errBPM(:,~useB)=NaN;errQuad(:,~useQ)=NaN;
plot(hAxes(3),zBPM,errBPM*scl,'.-',zQuad,errQuad*scl,'.-');
ylabel(hAxes(3),['\DeltaOff  (' units ')']);
xlabel(hAxes(3),'z  (m)');
s=[util_stdNan(errBPM,1,2);util_stdNan(errQuad,1,2)];
str=strcat({'BPM x';'BPM y';'Quad x';'Quad y'},{', '},num2str(s*scl,'\\sigma = %4.2f'),{' '},units);
legend(hAxes(3),str,'Location','NorthWest');legend(hAxes(3),'boxoff');
