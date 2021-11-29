function handles = gui_editControl(hObject, handles, name, val, num, vis, prec)
%GUI_EDITCONTROL
%  HANDLES = GUI_EDITCONTROL(HOBJECT, HANDLES, NAME, VAL, NUM) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: Reference name for base name of buttons
%    VAL: New value
%    NUM: Index for multiple controls
%    PREC: [# significant digits, {min {max}}]
%    VIS: Visibility flag for buttons

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(TAG).

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 5, num=1;end
if nargin < 7, prec=Inf;end
prec(1)=10^prec(1);prec(end+1:2)=-Inf;prec(end+1:3)=Inf;

if isempty(val) || any(isnan(val))
    val=handles.(name)(min(num,end));
end

if ~isinf(prec(1))
    val=round(val*prec(1))/prec(1);
end
val=min(max(prec(2),val),prec(3));

handles.(name)(num)=val;

if nargin < 6, vis=true;end
state={'off' 'on'};

for j=1:length(num)
    str=num2str(num(j));if num(j) == 1, str='';end
    hEdit=handles.([name str '_txt']);
    hLabel=[];sLabel=[name str 'Label_txt'];
    if isfield(handles,sLabel), hLabel=handles.(sLabel);end
    set(hEdit,'String',num2str(val(j)));
    set([hEdit hLabel],'Visible',state{logical(vis)+1});
end

guidata(hObject,handles);
