classdef knob < base
	% Hold's all the meta information of an individual knob
    
    properties
        meta
        select
        val
        invalid = false
    end
    
    methods
        function o = knob(ini, select, start_at_zero)
            o.meta = ini;
        
            % Selects either BC1 or BC2 - it furthermore sets the initial
            % values to zero or reads them from the machine
            o.select = o.meta.(select);
            
            for knob = 1:length(o.select)
                o.select(knob).valid = true;
                
                if start_at_zero
                    o.val = control_magnetSet({o.select.name}, [0 0]);
                else
                    o.val = control_magnetGet({o.select.name});
                end
            end
        end
        
        function valid = perturb(o, index, perturbation)
            % Perturbs the magnet with index. Set's all the other magnets
            % down to the exact value. In case the magnet in question is 
            % invalid (out-of bands) it returns false without setting anything.
            
            valid = o.select(index).valid;
            if ~valid, return, end
                
            control_magnetSet({o.select.name}, ...
                              o.val(:, end) + perturbation * [2-index; index-1]);
        end
        
        function set_value(o, change)
            % Set's the incremential value and checks if the magnets are
            % still within the bounds, if not it deactivates the magnet
            
            o.val(:, end + 1) = o.val(:, end) + change;
            
            for i = 1:length(change)
                if o.select(i).valid
                    if (o.val(i, end) > o.select(i).max) || (o.val(i, end) < o.select(i).min)
                        o.log.warn([o.select(i).name ' out of bounds. Remove from optimisation'])
                        o.select(i).valid = false;
                        o.invalid = ~logical(sum([o.select.valid]));
                        
                        if o.val(i, end) > o.select(i).max
                            o.val(i, end) = o.select(i).max;
                        else
                            o.val(i, end) = o.select(i).min;
                        end
                    end
                    
                    control_magnetSet({o.select(i).name}, o.val(i, end));
                end
            end
        end
    end
end

