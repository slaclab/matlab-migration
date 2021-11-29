classdef tab < base
    % Self implementation of tab for R2012, see tabgroup for more
    % info.
    %
    % By marcg@slac.stanford.edu
    
    properties
        pan
        button
        id
        tabgroup
        name
    end
    
    properties (Constant)
        BUTTON_HEIGHT = 2
    end
    
    methods
        function o = tab(name, pan, id, tabgroup)
            o.name = name;
            o.id = id;
            o.tabgroup = tabgroup;
            pos = tabgroup.pos;
            
            o.button = o.create.button(name, ...
                        [pos(1) pos(2)+pos(4)-o.BUTTON_HEIGHT pos(4) o.BUTTON_HEIGHT],...
                        pan, @o.set_active, o.COLOR(o.DEF),'on');
                    
            o.pan = o.create.pan('', pos - [0 0 0 o.BUTTON_HEIGHT], pan);
            
            o.add_listener(tabgroup, 'active', 'PostSet', @o.toggle_active)
            o.add_listener(o, 'status', 'PostSet', @o.setStatus)
        end
        
        function setStatus(o, ~, ~)
            set(o.button, 'BackGroundColor', o.COLOR(o.status))
        end
        
        function rearange_buttons(o)
            pos = o(1).tabgroup.pos;
            dx = pos(3)/length(o);
            
            for tab = o'
                set(tab.button, 'Position',...
                    [pos(1) + (tab.id-1)*dx pos(2)+pos(4)-tab.BUTTON_HEIGHT dx tab.BUTTON_HEIGHT]);
            end
        end
        
        function toggle_active(o, ~, ~)
            if o.tabgroup.active == o.id
                set(o.pan, 'visible', 'on')
                set(o.button, 'FontWeight', 'Bold', 'string', ['>' o.name '<'])
                
                set(get(o.pan, 'children'), 'visible', 'on')
            else
                set(o.pan, 'visible', 'off')
                set(o.button, 'FontWeight', 'normal', 'string', o.name)
                
                set(get(o.pan, 'children'), 'visible', 'off')
            end
        end
        
        function set_active(o, ~, ~)
            o.tabgroup.active = o.id;
        end
    end
end