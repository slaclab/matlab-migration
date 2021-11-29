function handles = matching_updateMagnets(handles, tag, optics)

if nargin < 3, optics=handles.optics;end

if isstruct(optics)
    if strcmp(tag,'magnetBG')
        name = {optics(optics(1).location).type};
        value = repmat(' ',1,numel(name));
    else
        value = [optics(optics(1).location).KL];
    end
else
    value = optics;
end

state={'off' 'on'};
for j=1:8
    vis = state{(numel(value) >= j)+1};
    str = num2str(value(j:min(j,end)),'%6.3f');
    tStr='';if j > 1, tStr=num2str(j);end
    set(handles.([tag tStr '_txt']),'String',str,'Visible',vis);
    if strcmp(tag,'magnetBG')
        set(handles.(['magnet' tStr '_txt']),'String',name(j:min(j,end)),'Visible',vis);
    end
end
