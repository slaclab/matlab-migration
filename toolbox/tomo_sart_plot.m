function tomo_sart_plot(x,y,f,varargin)
%TOMO_SART_PLOT
%  TOMO_SAR_PLOT(X,Y,F,...)
%  Plot function for tomographic reconstruction methods.
%
% Features:

% Input arguments:
%    X: x coordinates of reconstruction domain
%    Y: y coordinates of reconstruction domain
%    F: Reconstructed density function
%
% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if isempty(varargin), figure(2);varargin{1}=gca;end

ax=varargin{1};h=findobj(ax,'Type','Image');

if isempty(h)
    hFig=get(ax,'Parent');
    if ~strcmp(get(hFig,'Type'),'figure'), hFig=get(hFig,'Parent');end
    set(hFig,'Colormap',jet(256));
    set(ax,'YDir','normal','XLim',x([1 end]),'YLim',y([1 end]));
    h=image('Parent',ax,'CDataMapping','scaled','XData',x,'YData',y,'EraseMode','none');
end

mf=[max(f(~isnan(f))) 1]+1e-10;
set(h(end),'CData',f);set(ax,'CLim',[0 mf(1)],'CLimMode','auto');
drawnow;%input('');

return
