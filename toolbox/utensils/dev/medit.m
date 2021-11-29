classdef medit < base
    % Wrapper for the uicontrol type style
    % It already performs basic input checking and offers the an interface
    % to signal its status by the background color. If the value is changed
    % by the user it fires change. 
    %
    % If tooltip is defined it gives the possibility do define a tooltip.
    %
    % If vector is set to true the field allows vector input (including 
    % empty) without bound checking. Caution due to this I use str2num
    % which evaluates any string feed into the edit.
    %
    % If val is txt (comming from ini) the edit box will stay text for as
    % long as it exists.
    %
    % By marcg@slac.stanford.edu
    
    events
        change
    end
    
    properties (SetObservable, AbortSet)
        val = 0
    end
    
    properties
        min = -1e10
        max =  1e10
        vector = false
    end
    
    properties (Transient)
        box
    end

    properties(Constant, Transient)
        WIDTH = 16
        HEIGTH = 2.5
    end
    
    properties (Dependent)
        width
        enable
    end

    methods
        function o = medit(x, y, pan, ini, tooltip)         
            o.str2obj(ini)
            
            o.box = o.create.edit([x y o.WIDTH o.HEIGTH], num2str(o.val), pan);
            set(o.box, 'Callback', @o.check)
            
            if exist('tooltip', 'var')
                set(o.box, 'tooltipstring', tooltip)
            end
            
            o.add_listener(o, 'status', 'PostSet', @o.setStatus);
        end
        
        function out = add_caption(o, txt, direction, distance)
            pos = get(o.box, 'position');
            
            switch direction
                case 'north'
                    align = 'center';
                    pos = [pos(1) pos(2)+pos(4)+distance pos(3) 2];
                case 'west'
                    align = 'left';
                    pos = [pos(1)-distance pos(2)-.5 distance pos(4)];
                otherwise
                    error('Unknown direction')
            end
            out = o.create.text(txt, pos, get(o.box, 'parent'), align);
        end
        
        function check(o, ~, ~)
            if isnumeric(o.val)
                txt = get(o.box, 'String');
                [neu, OK] = str2num(txt); %#ok, I want to use arrays

                if (~o.vector && length(neu) ~= 1) || ~OK
                    o.log.warn('Invalid Number')
                    set(o.box, 'String', num2str(o.val))
                elseif (length(neu) == 1) && (o.min > neu || o.max < neu)
                    o.log.warn('Out of Bounds')
                    set(o.box, 'String', num2str(o.val))
                else
                    o.val = neu;
                    notify(o, 'change')
                end
            else
                o.val = get(o.box, 'String');
                notify(o, 'change')
            end
        end
        
        function setStatus(o, ~, ~)
            set(o.box, 'BackgroundColor', o.COLOR(o.status));
        end
        
        function set.width(o, neu)
            pos = get(o.box, 'Position');
            set(o.box, 'Position', [pos(1:2) neu pos(4)]);
        end
        
        function set.enable(o, neu)
            set(o.box, 'enable', neu)
        end
        
        function set_val(o, neu)
            o.val = neu;
            
            if isnumeric(neu)
                if neu == floor(neu)
                    set(o.box, 'String', num2str(neu))
                else
                    set(o.box, 'String', sprintf('%.3f', neu))
                end
            else
                set(o.box, 'String', neu)
            end
        end
    end
end