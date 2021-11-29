function handles = gui_rangeControl(hObject, handles, name, pos, val, num, vis)
%GUI_RANGECONTROL
%  GUI_RANGECONTROL(HOBJECT, HANDLES, NAME, POS, VAL, NUM) .

% Features:

% Input arguments:

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: 

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
if nargin < 7, vis=[];end
if nargin < 6, num=1;end

if isempty(val) || any(isnan(val))
    val=cell2mat(handles.(name)(min(num,end),pos));
end
handles.(name)(num,pos)=num2cell(val);

loc={'Low' 'High'};
state={'off' 'on'};
for j=1:length(num)
    str=num2str(num(j));if num(j) == 1, str='';end
    for k=1:length(pos)
        set(handles.([name loc{pos(k)} str '_txt']),'String',num2str(val(j,k)));
        if ~isempty(vis)
            set(handles.([name loc{pos(k)} str '_txt']),'Visible',state{vis+1});
        end
    end
end
guidata(hObject,handles);
