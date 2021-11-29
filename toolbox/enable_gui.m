%
% enable_gui(fig)
%
% Sets the 'Enable' property of all children of the given figure
% to 'on'.
%
% Lars Froehlich, 06/2007
%
function enable_gui(fig)
    chld = get(fig, 'Children');
    for i = 1:length(chld)
        try
            set(chld(i), 'Enable', 'on');
        end
    end
return
