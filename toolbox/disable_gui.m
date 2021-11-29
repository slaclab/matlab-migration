%
% disable_gui(fig)
%
% Sets the 'Disable' property of all children of the given figure
% to 'off'.
%
% Lars Froehlich, 06/2007
%
function disable_gui(fig)
    chld = get(fig, 'Children');
    for i = 1:length(chld)
        try
            set(chld(i), 'Enable', 'off');
        end
    end
return
