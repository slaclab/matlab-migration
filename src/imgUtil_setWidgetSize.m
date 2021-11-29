%if width or height <=0, they won't be changed
function imgUtil_setWidgetSize(h, width, height)
pos = get(h, 'position');
%[left, bottom, width, height]
if(width > 0)
    pos(3) = width;
end
if(height>0)
    pos(4) = height;
end
set(h, 'position', pos);