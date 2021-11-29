classdef dechirper_instrument < base
    % Holds the different alignment procedures
    %
    % by marcg@slac.stanford.edu
    properties
        methoden
        val
    end
    
    properties (Transient)
        handle
    end
    
    events
        change_instrument
    end
    
    properties (Dependent)
        data
    end
    
    methods
        function o = dechirper_instrument(ini, x, dx, y, pan)
            o.str2obj(ini)
            
            names = arrayfun(@(in) in.PV, o.methoden, 'uniformoutput', 0);
            names{end + 1} = 'Add ...';
            
            o.handle = o.create.popup(names, [x y dx 2], pan, ini.val, @o.callback);
        end
        
        function callback(o, ~, ~)
            % Calls a redraw for the new slected method. In case of Add...
            % it allows adding a new correction channel.
            
            val = get(o.handle, 'Value');
            
            if val > length(o.methoden)
                inp = inputdlg({'PV Adress' sprintf('Function string:\n -Supergaussian\n -Errorfunction\n -@(fitPar, edge1, edge2, x) ...') 'Start Values'}, 'Create New Imstrument');
                
                if isempty(inp)
                    set(o.handle, 'Value', o.val)
                    return
                end
                
                funOut = eval(inp{2});
                funOut = @(x) funOut(x, inp{3}(1), inp{3}(2), inp{3}(3:end));
                
                o.methoden(end + 1) = struct(...
                    'PV',inp{1},...
                    'x', [], ...
                    'y', [],...
                    'err', [],...
                    'center', [], ...
                    'edge1', [],...
                    'edge2', [],...
                    'fit', num2str(inp{3}));
                
                names = get(o.handle, 'string');
                set(o.handle, 'string', {names{1:end-1} inp{1} names{end}})
            else
                o.val = val;
            end
            
            notify(o, 'change_instrument')
        end
        
        function out = get.data(o)
            out = o.methoden(o.val);
        end
        
        function update(o, data)
            o.methoden(o.val) = data;
        end
    end
end