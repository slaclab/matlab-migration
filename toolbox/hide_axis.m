%
% hide_axis(ax)
%
% Hides the x and y axis of the specified axes object by removing
% their ticks and giving them the default background color.
%
% Lars Froehlich, 06/2007
%
function hide_axis(ax)
    bgr_color = get(0, 'DefaultUIControlBackgroundColor');

    set(ax, 'XColor', bgr_color, 'YColor', bgr_color, ...
        'XTick', [], 'YTick', []);
return
