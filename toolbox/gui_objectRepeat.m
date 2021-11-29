function handles = gui_objectRepeat(hObject, handles, tag, num, delta)
%
%
% This requires that the object's tag only contains a single underscore and
% that the object units are characters.

% DELTA: Offset vector (hor, vert) for new objects, positive is up or
%        right, default is 0.5 character units spacing
% NUM:   Total number of objects, existing one included

% Check arguments.
if nargin < 5, delta=[0 -Inf];end
if nargin < 4, num=2;end

% Get original objects.
tag=cellstr(tag);
nTag=numel(tag);

h0=zeros(nTag,1);
for j=1:nTag
    h0(j)=handles.(tag{j});
end
cb=get(h0,'CallBack');

p0=cell2mat(get(h0,'Position'));
if ~isfinite(delta(1))
    delta(1)=sign(delta(1))*(max(p0(:,3))+.5);
end
if ~isfinite(delta(2))
    delta(2)=sign(delta(2))*(max(p0(:,4))+.5);
end

% Create new entries
for j=2:num
    hh=copyobj(h0,handles.output);
    str=num2str(j);
    tagNew=strrep(tag,'_',[str '_']);
    for k=1:nTag
        handles.(tagNew{k})=hh(k);
        if ~isempty(cb{k})
            cbStr=strrep(char(cb{k}),'))',['),' num2str(j) ')']);
            if isa(cb{k},'function_handle')
                cbStr=str2func(cbStr);
            end
            set(hh(k),'CallBack',cbStr);
        end
    end
    set(hh,{'Position'},num2cell([p0(:,1:2)+(j-1)*ones(nTag,1)*delta p0(:,3:4)],2));
end

guidata(hObject,handles);
