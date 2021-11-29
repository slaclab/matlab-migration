function beamAnalysis_profilePlot(beam, plane, varargin)
%PROFILEPLOT
%  PROFILEPLOT(BEAM, PLANE, OPTS) plots the profiles in BEAM struct.

% Features:

% Input arguments:
%    BEAM: Beam parameter structure as returned from beamParams()
%    PLANE: Plane of list of planes to plot ('x', 'y', 'u')
%    OPTS: Options stucture with fields (optional):
%        FIGURE: Figure handle
%        AXES: Axes handle
%        XLAB: Label for x-axis
%        YLAB: Label for y-axis
%        TITLE: Title

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, util_plotInit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',[], ...
    'axes',[], ...
    'xlab','Position  (\mum)', ...
    'ylab','Counts  ()', ...
    'title','', ...
    'cal',[1 1e-3], ...
    'units', [], ...
    'num',1);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Get axes from opts.
hAxes=util_plotInit(opts);
colList=get(hAxes,'ColorOrder');colList=colList([1 3 2 4 5 7 6],:);

% Determine units.
if opts.cal(1) ~= 1
    str=regexp(opts.xlab,'\(|\)','split');
    opts.units=str(2);
end
if isempty(opts.units), opts.units={'\mum' 'mm'};end
units=strrep(cellstr(opts.units),'\','\\');

cal=[1e-6 opts.cal([end 1])];
prop={'b.:' 'r'};pos=.1;str='';n=opts.num;
if opts.num > 1, prop={'g.:' 'm'};pos=.6;hold(hAxes,'on');end
iDrew = false;
for j=char(plane(:))'
    if isfield(beam,['prof' j])
        prof=beam.(['prof' j]);col=colList(mod(2*n-2,7)+1,:);
        plot(prof(1,:)*opts.cal(1),prof(2,:),'Color',col,'LineStyle',':','Marker','.','Parent',hAxes);
        line(prof(1,:)*opts.cal(1),prof(3,:),'Color',colList(mod(2*n-1,7)+1,:),'Parent',hAxes);
%        plot(prof(1,:)*opts.cal(1),prof(2,:),prop{1}, ...
%            prof(1,:)*opts.cal(1),prof(3,:),prop{2},'Parent',hAxes);
        hold(hAxes,'on');n=n+1;

        fmtExt='';stdStr='';valStd=[];
        if isfield(beam,[j 'Stat'])
            stdStr='\\pm%5.2f';
            val=beam.([j 'Stat'])(1:5).*[cal 1 1];
            valStd=beam.([j 'StatStd'])(1:5).*[cal 1 1];
            fmtExt=[j 'skew = %5.2f' stdStr '\n' ...
                    j 'kurt = %5.2f' stdStr '\n'];
        elseif j ~= 'u'
            val=[beam.stats(6) beam.stats([1 3]+(j == 'y'))].*cal;
            if isfield(beam,'statsStd')
                stdStr='\\pm%5.2f';
                valStd=[beam.statsStd(6) beam.statsStd([1 3]+(j == 'y'))].*cal;
            end
        else
            val=[beam.stats(6) 0 sqrt(abs((beam.stats(3)^2+beam.stats(4)^2)/2-beam.stats(5)))].*cal;
        end
        fmtBase=[j 'area = %6.3f' stdStr ' Mcts\n' ...
                 j 'mean = %5.2f' stdStr ' ' units{end} '\n' ...
                 j 'rms = %5.1f' stdStr ' ' units{1} '\n'];
        str=[str '\color[rgb]{' num2str(col) '}' sprintf([fmtBase fmtExt '\n'],[val;valStd])];
        iDrew = true;
    elseif ~iDrew % if no data for this plane and haven't drawn yet, clear plot.
        cla(hAxes);legend(hAxes,'off');
        xlabel(hAxes,'');ylabel(hAxes,'');
        title(hAxes,'');
    end
end
hold(hAxes,'off');

text(pos,0.9,str,'units','normalized','VerticalAlignment','top', ...
    'Color',prop{1}(1),'Parent',hAxes);
xlabel(hAxes,opts.xlab);
ylabel(hAxes,opts.ylab);
title(hAxes,opts.title);
