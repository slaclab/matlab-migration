function util_appFonts(varargin)
%UTIL_APPFONTS
%  UTIL_APPFONTS([FIG,] OPTS) sets present and default text and line
%  properties for font name, font size, line width and marker size. Options
%  not set are kept unchanged.

% Features:

% Input arguments:
%    FIG: Figure handle(s) to apply settings to (optional, default to gca)
%    OPTS: Options stucture with fields (optional):
%        FONTNAME: Name of font to use
%        FONTSIZE: Size of font to use
%        LINEWIDTH: Line width to use
%        MARKERSIZE: Marker size to use

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if mod(nargin,2), fig=varargin{1};varargin(1)=[];else fig=gca;end

% Set default options.
optsdef=struct( ...
    'fontName','Helvetica', ...
    'fontSize',8, ...
    'lineWidth',.5, ...
    'markerSize',6);
optsdef=struct( ...
    'fontName',[], ...
    'fontSize',[], ...
    'lineWidth',[], ...
    'markerSize',[]);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Check FIG handle
fig(~ishandle(fig))=[];
if isempty(fig), return, end

% Find calling handle
%{
hMenu=[];hObj=[];
if strcmp(get(gcbo,'Type'),'uimenu')
    hMenu=get(gcbo,'Parent');
    if any(strfind(get(hMenu,'Label'),'Font'))
        hMenu=get(hMenu,'Children');
        hObj=gcbo;
    else hMenu=[];
    end
end
%}

% Find axes, text, and line objects in figure
hAxes=findobj(fig,'Type','axes');
hText=findall(hAxes,'Type','text');
hLine=findobj(hAxes,'Type','line');
hLabel=get(hAxes,{'xlabel' 'ylabel' 'title'});

if ~isempty(opts.fontName)
    set(fig,'DefaultTextFontName',opts.fontName);
    set(fig,'DefaultAxesFontName',opts.fontName);
    set(hAxes,'DefaultTextFontName',opts.fontName);
    set(hAxes,'FontName',opts.fontName);
    set(hText,'FontName',opts.fontName);
    set([hLabel{:}],'FontName',opts.fontName);
%    set(hMenu,'Checked','off');
%    set(hObj,'Checked','on');
end

if ~isempty(opts.fontSize)
    set(fig,'DefaultTextFontSize',opts.fontSize);
    set(hAxes,'DefaultTextFontSize',opts.fontSize);
    set(hAxes,'FontSize',opts.fontSize);
    set(hText,'FontSize',opts.fontSize);
    set([hLabel{:}],'FontSize',opts.fontSize);
%    set(hMenu,'Checked','off');
%    set(hObj,'Checked','on');
end

if ~isempty(opts.lineWidth)
    set(fig,'DefaultLineLineWidth',opts.lineWidth);
    set(hAxes,'DefaultLineLineWidth',opts.lineWidth);
    set(hLine,'LineWidth',opts.lineWidth);
    set(fig,'DefaultAxesLineWidth',max(0.5,opts.lineWidth/2));
    set(hAxes,'LineWidth',max(0.5,opts.lineWidth/2));
%    set(hMenu,'Checked','off');
%    set(hObj,'Checked','on');
end

if ~isempty(opts.markerSize)
    set(fig,'DefaultLineMarkerSize',opts.markerSize);
    set(hAxes,'DefaultLineMarkerSize',opts.markerSize);
    set(hLine,'MarkerSize',opts.markerSize);
%    set(hMenu,'Checked','off');
%    set(hObj,'Checked','on');
end
