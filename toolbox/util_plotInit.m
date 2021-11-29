function [hAxes, hFig] = util_plotInit(varargin)
%PLOTINIT
%  [HAXES, HFIG] = PLOTINIT(OPTS) sets figure HFIG and axes HAXES from
%  OPTS.

% Features:

% Input arguments:
%    OPTS: Options stucture with fields (optional):
%        FIGURE: Figure handle
%        AXES: Axes handle
%        XLAB: Label for x-axis
%        YLAB: Label for y-axis
%        TITLE: Title

% Output arguments:
%    HAXES: Handle of axes to plot to
%    HFIG: Handle of parent figure

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',[], ...
    'axes',[], ...
    'keep',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Setup figure and axes.
if isempty(opts.axes),opts.axes={1 1 1};end
if iscell(opts.axes)
    if ~isempty(opts.figure), hFig=opts.figure;
    else hFig=gcf;end
    if ~ishandle(hFig), figure(hFig);end
    if size(opts.axes,2) < 3
        opts.axes=repmat(opts.axes,times(opts.axes{:}),1);
        opts.axes(:,3)=num2cell(1:size(opts.axes,1));
    end
    hAxes=zeros(1,size(opts.axes,1));
    h=setdiff(findobj(hFig,'Type','axes'),findobj(hFig,'Tag','legend')); % Existing axes
    if opts.keep && numel(h) == numel(hAxes)
        hAxes(:)=h;
    else
        for j=1:numel(hAxes)
            hAxes(j)=subplot(opts.axes{j,:},'Parent',hFig,'Box','on');
        end
    end
else
    hAxes=opts.axes;
    hFig=ancestor(hAxes(1),'figure');
end
