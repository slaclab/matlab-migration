function handles = gui_sliderControl(hObject, handles, name, jVal, nVal, vis, num, val)
%GUI_SLIDERCONTROL
%  HANDLES = GUI_SLIDERCONTROL(HOBJECT, HANDLES, NAME, JVAL, NVAL, VIS, NUM, VAL) .

% Features:

% Input arguments:
%    HOBJECT: Handle of current object
%    HANDLES: Structure as returned from GUIDATA
%    NAME: reference name for Name of slider
%    JVAL:
%    NVAL:
%    VIS:
%    NUM:
%    VAL:

% Output arguments:
%    HANDLES: Updated HANDLES structure
%    HANDLES.(NAME).

% Compatibility: Version 7 and higher
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 7, num=1;end
if isempty(nVal)
    nVal=handles.(name).nVal(num);
end
nVal=max(1,nVal);
handles.(name).nVal(num)=nVal;

if isempty(jVal)
    jVal=handles.(name).jVal(num);
end
jVal=max(1,min(jVal,nVal));
handles.(name).jVal(num)=jVal;
handles.(name).jVal=min(handles.(name).jVal,handles.(name).nVal);
jValCell=num2cell(fliplr(handles.(name).jVal));
handles.(name).iVal=sub2ind([fliplr(handles.(name).nVal) 1],jValCell{:});
guidata(hObject,handles);

nStr='';if num > 1, nStr=num2str(num);end
if ~isfield(handles,[name nStr '_sl']), return, end
hLabel=handles.([name nStr 'Label_txt']);
hText=handles.([name nStr '_txt']);
hSlider=handles.([name nStr '_sl']);

if nargin < 6, vis=true;end
state={'off' 'on'};
set([hLabel hText hSlider],'Visible',state{(nVal > 1 & vis)+1});

slMin=get(hSlider,'Min');
set(hSlider,'Max',max(nVal,2),'Value',jVal, ...
    'SliderStep',[1 1]./(max(nVal,2)-slMin));

if nargin < 8, val=1:nVal;end
if isnumeric(val), str=num2str(val(jVal));
else val=cellstr(val);str=val{min(jVal,end)};end
set(hText,'String',str);
