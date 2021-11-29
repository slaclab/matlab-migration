classdef dechirper_bpm < base
    % Creates an overview for the bpms
    %
    % By marcg@slac.stanford.edu
    
    properties (Transient)
        val_bpm
        val_jaw
        n_bpm
        n_jaws
        lines_bpm
        lines_jaw
    end
    
    properties
        bpm_pv
        jaw_pv
        history
    end
    
    methods
        function o = dechirper_bpm(ini, num, n_num, pan)
            o.str2obj(ini)
            o.n_bpm = length(ini.bpm_pv);
            o.n_jaws = length(ini.jaw_pv);
            
            pos = get(pan, 'Position');
            dy = 1/n_num*(pos(4) - n_num-2);
            pos = [pos(1)+6 (num-1)*(dy+1)+1 pos(3)+3 dy];

            ax = o.create.axes([], pos, pan, [], []);
            set(ax, 'XTickLabel', [])
            
            o.val_bpm = zeros(ini.history, o.n_bpm);
            o.lines_bpm = plot(ax, o.val_bpm);
            
            o.val_jaw = zeros(ini.history, o.n_jaws);
            o.lines_jaw = plot(ax, o.val_jaw, 'color', 'k');
            
            o.val_bpm = mat2cell(o.val_bpm, ini.history, ones(1,o.n_bpm));
            o.val_jaw = mat2cell(o.val_jaw, ini.history, ones(1,o.n_jaws));
            legend(ax, o.bpm_pv, 'FontSize', o.create.SMALL, 'Interpreter', 'none','location','NorthWest')

            o.add_listener(o.tic, 'tic', @o.update)
            
%             tic
%             o.add_listener(o.tic, 'tic', @(varargin) disp(toc))
        end
        
        function update(o, ~, ~)
            % We only update the lines instead of reploting to reduce the
            % load. This is beneficial here since the bpms will likely be
            % updated with a high frequeny.
            
            val = lcaGetSmart(o.bpm_pv);
            for i = 1:o.n_bpm
                o.val_bpm{i} = [o.val_bpm{i}(2:end); val(i)];
            end
            set(o.lines_bpm, {'ydata'}, o.val_bpm(:))
            
            for i = 1:o.n_jaws
                val = min(lcaGetSmart(o.jaw_pv{i}));
                o.val_jaw{i} = [o.val_jaw{i}(2:end); val];
            end
            set(o.lines_jaw, {'ydata'}, o.val_jaw(:))
        end
    end
end