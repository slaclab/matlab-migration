function gui_resize(hObject, scale)
%GUI_RESIZE
%  GUI_RESIZE(HOBJECT, SCALE) resizes GUI objects to fit within the GUI
%  figure. It assumes that GUI objects have character units.  If the
%  optional SCALE parameter is given, the GUI will be scaled by that
%  amount.

% Input arguments:
%    HOBJECT: Handle of current object
%    SCALE:   Scale factor (optional)

% Output arguments:

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

h=get(hObject,'Children');
h=findobj(h,'-property','Units');h=setdiff(h,findobj(h,'Type','text'));
set(h,'Units','normalized');
pos=cell2mat(get(h,'Position'));
if nargin < 2, scale=1/max(pos(:,2)+pos(:,4));end

if (nargin == 1 && scale < 1) || nargin > 1
    set(h,{'Position'},num2cell(pos*scale,2));
    set(h,{'FontSize'},num2cell(max(1,cell2mat(get(h,'FontSize')))*scale));
end

set(h,'Units','characters');

if nargin == 1 && scale < 1
    set(hObject,'Position',get(hObject,'Position').*[1 1 max(pos(:,1)+pos(:,3))*scale 1]);
elseif nargin > 1
    set(hObject,'Position',get(hObject,'Position').*[1 1 scale scale]);
end
