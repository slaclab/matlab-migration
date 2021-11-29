classdef tabgroup < base
    % This class implements the tab functionality which is only
    % semidocumented in R2012, event thought it would be fully supported in
    % R2014up.
    %
    % By marcg@slac.stanford.edu
    
    properties
        tab
        pan
        pos
    end
    
    properties(SetObservable, AbortSet)
        active = 1
    end
    
    methods
        function o = tabgroup(pos, pan)
            o.pan = pan;
            o.pos = pos;
        end
        
        function tabs = add_tab(o, name)
            % create and rearange existing buttons
            tabs = tab(name, o.pan, length(o.tab)+1, o);
            
            o.tab = [o.tab; tabs];
            
            if length(o.tab) > 1
                o.tab.rearange_buttons
            end
            
            o.active = length(o.tab);
        end
    end
end