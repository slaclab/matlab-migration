function matching_updateGoals(handles, tag, value)

if nargin < 3, value = handles.goals;end
if nargin < 2, tag='goal';end

state={'off' 'on'};
ext={'bx' 'ax' 'by' 'ay'};
for k=1:2
    lab='';if k > 1, lab=num2str(k);end
    for l = 1:4
        j=(k-1)*4+l;
        str = sprintf('%6.3f',value(j:min(j,end)));
        vis=state{(numel(value) >= j)+1};
        set(handles.([tag ext{l} lab '_txt']),'String',str,'Visible',vis);
        if nargin < 2, set(handles.(['fit' ext{l} lab '_txt']),'String','','Visible',vis);end
    end
end

if nargin > 1, return, end
ref=cellstr(handles.optics(1).reference);
str = sprintf('Twiss at %s ',ref{1});
set(handles.goal_pan,'Title',str);
